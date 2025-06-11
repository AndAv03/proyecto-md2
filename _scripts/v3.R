# Identificar perfiles sociodemograficos asociados con tener NIT
# ----------------------------
# 1. Cargar librerías necesarias
# ----------------------------
rm(list = ls())
library(arules)
library(arulesViz)
library(dplyr)
library(forcats)

# ----------------------------
# 2. Preparar los datos
# ----------------------------
# Crear variable de edad en rangos
datos_rules <- datos_sub %>%
  mutate(
    edad_rango = cut(
      edad,
      breaks = c(14, 24, 39, 59, Inf),
      labels = c("15-24", "25-39", "40-59", "60+")
    )
  ) %>%
  select(sexo, edad_rango, area, niv_ed_g, s2_18, nit) %>%
  na.omit() %>%
  mutate(across(everything(), as.factor))

# ----------------------------
# 3. Convertir a transacciones
# ----------------------------
trans <- as(datos_rules, "transactions")

# ----------------------------
# 4. Aplicar Apriori con NIT como consecuencia
# ----------------------------
reglas_nit_target <- apriori(
  data = trans,
  parameter = list(supp = 0.01, conf = 0.5, minlen = 3, maxlen = 6),
  appearance = list(
    rhs = grep("^nit=", itemLabels(trans), value = TRUE),
    lhs = grep("^(sexo=|edad_rango=|area=|niv_ed_g=|s2_18=)", itemLabels(trans), value = TRUE)
  ),
  control = list(verbose = FALSE)
)

# ----------------------------
# 5. Filtrar reglas potentes (lift ≥ 2, support ≥ 0.01)
# ----------------------------
reglas_nit_df <- as(reglas_nit_target, "data.frame")
reglas_nit_df$rule <- paste(labels(lhs(reglas_nit_target)), "→", labels(rhs(reglas_nit_target)))

mejores_nit <- reglas_nit_df %>%
  filter(lift >= 2, support >= 0.01, confidence >= 0.5) %>%
  arrange(desc(lift)) %>%
  mutate(across(c(support, confidence, lift), round, 3)) %>%
  select(rule, support, confidence, lift)

# ----------------------------
# 6. Visualizar resultados
# ----------------------------
View(mejores_nit)

# (opcional) Exportar
# write.csv(mejores_nit, "_output/reglas_formalidad_nit.csv", row.names = FALSE)

# ----------------------------
# 7. Graficar las 20 mejores reglas
# ----------------------------
plot(sort(reglas_nit_target, by = "lift")[1:20], method = "graph", engine = "htmlwidget")
