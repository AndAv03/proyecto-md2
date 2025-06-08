# NIT COMO VARIABLE PREDICTORA DIRECTA
# ----------------------------
# 1. Cargar librerías necesarias
# ----------------------------
rm(list = ls())
library(arules)
library(arulesViz)
library(dplyr)
library(forcats)

# ----------------------------
# 2. Preparar el conjunto de datos
# ----------------------------

# Crear variable de edad en rangos y seleccionar variables
datos_rules <- datos_sub %>%
  mutate(
    edad_rango = cut(
      edad,
      breaks = c(14, 24, 39, 59, Inf),
      labels = c("15-24", "25-39", "40-59", "60+")
    )
  ) %>%
  select(sexo, edad_rango, area, niv_ed_g, nit, s2_18) %>%
  na.omit() %>%
  mutate(across(everything(), as.factor))

# ----------------------------
# 3. Convertir a transacciones
# ----------------------------
trans <- as(datos_rules, "transactions")

# ----------------------------
# 4. Aplicar algoritmo Apriori con optimización
# ----------------------------

reglas_con_nit <- apriori(
  data = trans,
  parameter = list(supp = 0.01, conf = 0.5, minlen = 3, maxlen = 6),
  appearance = list(
    rhs = grep("^s2_18=", itemLabels(trans), value = TRUE),
    lhs = grep("^(sexo=|edad_rango=|area=|niv_ed_g=|nit=)", itemLabels(trans), value = TRUE)
  ),
  control = list(verbose = FALSE)
)

# ----------------------------
# 5. Filtrar las reglas potentes (lift ≥ 2, support ≥ 0.01)
# ----------------------------
reglas_df <- as(reglas_con_nit, "data.frame")
reglas_df$rule <- paste(labels(lhs(reglas_con_nit)), "→", labels(rhs(reglas_con_nit)))

mejores_reglas <- reglas_df %>%
  filter(lift >= 2, support >= 0.01, confidence >= 0.5) %>%
  arrange(desc(lift)) %>%
  mutate(across(c(support, confidence, lift), round, 3)) %>%
  select(rule, support, confidence, lift)


# ----------------------------
# 6. Visualizar reglas top
# ----------------------------
View(mejores_reglas)

# ----------------------------
# 7. Visualización en red
# ----------------------------
plot(sort(reglas_con_nit, by = "lift")[1:20], method = "graph", engine = "htmlwidget")
