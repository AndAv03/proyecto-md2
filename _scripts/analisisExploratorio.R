# ----------------------------
# 1. Cargar librerías necesarias
# ----------------------------
rm(list = ls())
library(tidyverse)
library(haven)     # Para importar .sav y .dta
library(janitor)   # Para limpiar nombres
library(forcats)   # Para manipulación de factores
library(ggplot2)   # Para visualización

# ----------------------------
# 2. Importar el dataset
# ----------------------------
# Usaremos el .csv con separador ";"
# ruta <- "_data/ECE_2T2024.csv"
# datos <- read_csv2(ruta)  # read_csv2 reconoce el separador ";"
load("_data/ECE_2T2024.RData")
# ----------------------------
# 3. Limpieza inicial
# ----------------------------
datos <- datos %>% clean_names()  # nombres en minúsculas y sin caracteres especiales

# ----------------------------
# 4. Filtrar solo personas ocupadas
# ----------------------------
# s2_01: "Durante la semana pasada, ¿trabajó al menos una hora?"
# 1 = Sí, 2 = No
datos_ocupados <- datos %>%
  filter(s2_01 == 1)

# ----------------------------
# 5. Seleccionar y transformar variables clave
# ----------------------------
datos_sub <- datos_ocupados %>%
  select(s1_02, s1_03a, area, niv_ed, s2_18) %>%
  mutate(
    sexo = factor(s1_02, levels = c(1, 2), labels = c("Hombre", "Mujer")),
    area = factor(area, levels = c(1, 2), labels = c("Urbana", "Rural")),
    niv_ed_g = factor(niv_ed, levels = c(0, 1, 2, 3, 5),
                      labels = c("Ninguno", "Primaria", "Secundaria", "Superior", "Otros")),
    s2_18 = factor(s2_18, levels = 1:7, labels = c(
      "Obrero/Empleado",
      "Cuenta propia",
      "Empleador/a sin salario",
      "Cooperativista",
      "Familiar no remunerado",
      "Aprendiz sin remuneración",
      "Empleado/a del hogar"
    )),
    edad = s1_03a
  )

# ----------------------------
# 6. Análisis exploratorio
# ----------------------------

# a. Distribución por sexo
datos_sub %>%
  count(sexo) %>%
  ggplot(aes(x = sexo, y = n, fill = sexo)) +
  geom_col() +
  labs(title = "Distribución por sexo", y = "Frecuencia", x = "Sexo") +
  theme_minimal()

# b. Distribución por nivel educativo
datos_sub %>%
  count(niv_ed_g) %>%
  ggplot(aes(x = niv_ed_g, y = n, fill = niv_ed_g)) +
  geom_col() +
  labs(title = "Nivel educativo de los ocupados", x = "Nivel educativo", y = "Frecuencia") +
  theme_minimal()

# c. Distribución por área
datos_sub %>%
  count(area) %>%
  ggplot(aes(x = area, y = n, fill = area)) +
  geom_col() +
  labs(title = "Distribución por área", x = "Área", y = "Frecuencia") +
  theme_minimal()

# d. Distribución por grupo ocupacional
ocupaciones <- datos_sub %>%
  count(s2_18) %>%
  arrange(desc(n))

print(ocupaciones)

ocupaciones %>%
  ggplot(aes(x = fct_reorder(s2_18, n), y = n, fill = s2_18)) +
  geom_col() +
  coord_flip() +
  labs(title = "Distribución de ocupaciones", x = "Ocupación", y = "Frecuencia") +
  theme_minimal()

# e. Histograma de edades
ggplot(datos_sub, aes(x = edad)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(title = "Distribución de edad de los ocupados", x = "Edad", y = "Frecuencia") +
  theme_minimal()



