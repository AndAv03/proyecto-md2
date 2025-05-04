# Reglas de Asociación sobre Tipos de Ocupación en Bolivia (ECE 2T-2024)

## 🎯 Objetivo

Identificar combinaciones frecuentes de características sociodemográficas (sexo, edad, nivel educativo y zona geográfica) que se asocian con distintos tipos de ocupación en Bolivia, utilizando datos de la Encuesta Continua de Empleo del segundo trimestre de 2024 (INE).

## 💡 Justificación

El mercado laboral boliviano presenta altos niveles de informalidad y una diversidad significativa de trayectorias laborales según factores sociodemográficos. Comprender cómo se agrupan estas características en relación con las ocupaciones permite construir perfiles típicos de trabajadores. Estos perfiles pueden ser utilizados en:

- Diagnóstico de segmentación del mercado laboral.
- Políticas públicas focalizadas.
- Estudios sobre informalidad y precariedad.
- Investigaciones académicas y sociolaborales.

El uso de **reglas de asociación** permite detectar patrones implícitos en los datos sin requerir una variable dependiente predefinida, lo que lo convierte en un enfoque exploratorio útil para bases de datos grandes y heterogéneas.

## 🧠 Fundamento Metodológico

Se emplea el algoritmo **Apriori**, común en análisis de reglas de asociación (Market Basket Analysis), para identificar relaciones del tipo:

> **"Si A y B y C entonces D"**

Donde A, B y C son características del individuo (ej. sexo = mujer, edad = 25–39, zona = urbana) y D representa la ocupación principal.

El modelo se basa en métricas como:

- **Soporte**: Frecuencia relativa de la combinación completa en la base de datos.
- **Confianza**: Probabilidad de que se cumpla la ocupación dado el conjunto de condiciones.
- **Lift**: Indicador de fuerza de la regla respecto a la independencia (lift > 1 implica asociación positiva).

## 📌 Variables Utilizadas

Las siguientes variables fueron seleccionadas por su relevancia sociodemográfica y por estar presentes para prácticamente toda la población ocupada:

- `sexo`: Hombre / Mujer  
- `edad`: Agrupada en rangos (15–24, 25–39, 40–59, 60+)  
- `area`: Zona geográfica (Urbana / Rural)  
- `niv_ed_g`: Nivel educativo general (Ninguno, Primaria, Secundaria, Superior, Otros)  
- `s2_18`: Tipo de ocupación (clasificación principal del trabajo)

## 📈 Ejemplos de Reglas Esperadas

- **"Mujer, 25–39 años, secundaria, urbana → asalariada"**
- **"Varón, 40–59 años, primaria, rural → cuenta propia"**

Estas reglas ayudan a:

- Identificar patrones ocultos en la estructura laboral.
- Caracterizar grupos vulnerables o concentrados en sectores informales.
- Entender los vínculos entre educación, edad y empleo.
## 📂 Estructura del Proyecto
📁 _data/
└── ECE_2T2024.RData # Archivo principal de datos de la encuesta
📁 scripts/
├── 01_exploratorio.R # Análisis exploratorio de variables sociodemográficas
└── 02_reglas_asociacion.R # Generación de reglas de asociación sobre ocupación
📄 README.md # Documento explicativo del proyecto
## 🔧 Requisitos

- R >= 4.2.0  
- Paquetes: `tidyverse`, `arules`, `arulesViz`, `readr`, `haven`, `forcats`

---

Este análisis busca aprovechar técnicas de minería de datos para una comprensión más rica del empleo en Bolivia, utilizando herramientas reproducibles y accesibles en R.
