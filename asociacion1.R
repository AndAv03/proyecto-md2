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
# Regla de ejemplo: Si sexo + edad + educación + zona → tipo de ocupación
reglas <- apriori(
  data = trans,
  parameter = list(supp = 0.01, conf = 0.6, minlen = 2, maxlen = 5),
  appearance = list(rhs = c("s2_18=Obrero/Empleado", "s2_18=Cuenta propia",
                            "s2_18=Empleador/a sin salario", "s2_18=Empleado/a del hogar",
                            "s2_18=Familiar no remunerado", "s2_18=Cooperativista"),
                    default = "lhs"),
  control = list(verbose = FALSE)
)

# ----------------------------
# 5. Inspeccionar y visualizar reglas
# ----------------------------
# Mostrar las 15 reglas con mayor lift
inspect(sort(reglas, by = "lift")[1:15])

# Graficar red de reglas
plot(reglas, method = "graph", engine = "htmlwidget")

# ----------------------------
# 6. Opcional: Guardar reglas como CSV
# ----------------------------
# reglas_df <- as(reglas, "data.frame")
# write.csv(reglas_df, "_data/reglas_ocupacion.csv", row.names = FALSE)
