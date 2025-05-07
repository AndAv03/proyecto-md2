# ----------------------------
# 1. Cargar librerías necesarias
# ----------------------------
rm(list = ls())
library(arules)
library(arulesViz)
library(dplyr)
library(forcats)

# ----------------------------
# 2. Crear variable de rango de edad
# ----------------------------
datos_rules <- datos_sub %>%
  mutate(
    edad_rango = cut(
      edad,
      breaks = c(14, 24, 39, 59, Inf),
      labels = c("15-24", "25-39", "40-59", "60+"),
      right = TRUE
    )
  ) %>%
  select(sexo, edad_rango, area, niv_ed_g, s2_18) %>%
  na.omit()  # Eliminar filas con NA

# ----------------------------
# 3. Convertir a transacciones
# ----------------------------
trans <- as(datos_rules, "transactions")

# ----------------------------
# 4. Aplicar algoritmo Apriori
# ----------------------------

# Regla 1. Si sexo + edad + educación + zona → tipo de ocupación
regla1 <- apriori(
  data = trans,
  parameter = list(supp = 0.01, conf = 0.6, minlen = 2, maxlen = 5),
  appearance = list(rhs = c("s2_18=Obrero/Empleado", "s2_18=Cuenta propia",
                            "s2_18=Empleador/a sin salario", "s2_18=Empleado/a del hogar",
                            "s2_18=Familiar no remunerado", "s2_18=Cooperativista"),
                    default = "lhs"),
  control = list(verbose = FALSE)
)


# Regla 2. Perfiles asociados a tipos específicos de ocupación
reglas_cp <- apriori(
  data = trans,
  parameter = list(supp = 0.01, conf = 0.6, minlen = 2),
  appearance = list(rhs = "s2_18=Cuenta propia", default = "lhs"),
  control = list(verbose = FALSE)
)

# Regla 3. Factores comunes entre quienes trabajan en áreas rurales
reglas_rural <- apriori(
  data = trans,
  parameter = list(supp = 0.01, conf = 0.6),
  appearance = list(rhs = "area=Rural", default = "lhs"),
  control = list(verbose = FALSE)
)

# Regla 4. Revertir el análisis: qué factores se asocian con un determinado grupo (ej. mujeres con primaria)
reglas_mujer_primaria <- apriori(
  data = trans,
  parameter = list(supp = 0.005, conf = 0.5),
  appearance = list(rhs = c("sexo=Mujer", "niv_ed_g=Primaria"), default = "lhs"),
  control = list(verbose = FALSE)
)

# Regla 5. Ver qué perfiles tienen mayor probabilidad de estar en el grupo “Familiar no remunerado”
reglas_no_remun <- apriori(
  data = trans,
  parameter = list(supp = 0.005, conf = 0.4),
  appearance = list(rhs = "s2_18=Familiar no remunerado", default = "lhs"),
  control = list(verbose = FALSE)
)

# ----------------------------
# 5. Inspeccionar y visualizar reglas
# ----------------------------
# Mostrar las 10 reglas con mayor lift
inspect(sort(regla1, by = "lift")[1:10])
inspect(sort(reglas_no_remun, by = "lift")[1:10])
inspect(sort(reglas_cp, by = "lift")[1:10])
inspect(sort(reglas_rural, by = "lift")[1:5])
inspect(sort(reglas_mujer_primaria, by = "lift")[1:10])
inspect(sort(reglas_no_remun, by = "lift")[1:10])

# Graficar red de reglas
plot(regla1, method = "graph", engine = "htmlwidget")
plot(reglas_no_remun, method = "graph", engine = "htmlwidget")
plot(reglas_cp, method = "graph", engine = "htmlwidget")
plot(reglas_rural, method = "graph", engine = "htmlwidget")
plot(reglas_mujer_primaria, method = "graph", engine = "htmlwidget")
plot(reglas_no_remun, method = "graph", engine = "htmlwidget")

# Mejor visualizacion de las reglas
# Convertir reglas a data frame
reglas_df <- as(sort(regla1, by = "lift")[1:10], "data.frame")

# Separar LHS y RHS como texto
reglas_df$rule <- paste(labels(lhs(sort(regla1, by = "lift")[1:10])),
                        "→",
                        labels(rhs(sort(regla1, by = "lift")[1:10])))

# Reorganizar columnas
reglas_limpias <- reglas_df %>%
  select(rule, support, confidence, lift) %>%
  mutate(across(c(support, confidence, lift), ~ round(.x, 3)))

# Ver en consola (tabla limpia)
# Convertir reglas a data frame
regla1_df <- as(sort(regla1, by = "lift")[1:10], "data.frame")

# Separar LHS y RHS como texto
regla1_df$rule <- paste(labels(lhs(sort(regla1, by = "lift")[1:10])),
                        "→",
                        labels(rhs(sort(regla1, by = "lift")[1:10])))

# Reorganizar columnas
regla1_df_limpias <- regla1_df %>%
  select(rule, support, confidence, lift) %>%
  mutate(across(c(support, confidence, lift), ~ round(.x, 3)))

# Ver en consola (tabla limpia)
View(regla1_df_limpias)



