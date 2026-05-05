# 🎬 Proyecto Análisis Sakila — Limpieza y Exploración de Datos
# Descripción del proyecto

Análisis de la base de datos Sakila (MySQL) con limpieza y transformación de datos en SQL, seguida de exploración y visualización en Google Colab con Python/Pandas.

## Estructura del proyecto

## 📁 Estructura del proyecto

- SQL/
  - dataframe_2_catalogo_peliculas.sql
  - dataframe_3_elenco_popularidad.sql
- Notebooks/
  - analisis_sakila.ipynb
- Data/
  - Dataframe_2_CatalogoPeliculasFinal.csv
- README.md

## 🗄️ Pasos SQL
## Dataframe 2 — Catálogo de Películas
Creación de una vista limpia con normalización de texto y conteo de inventario.
``` python
USE sakila;

CREATE VIEW Vista_catalogo AS
SELECT
    f.film_id,
    CONCAT(UPPER(LEFT(f.title, 1)), LOWER(SUBSTRING(f.title, 2)))             AS title_clean,
    CONCAT(UPPER(LEFT(f.description, 1)), LOWER(SUBSTRING(f.description, 2))) AS description_clean,
    CONCAT(UPPER(LEFT(c.name, 1)), LOWER(SUBSTRING(c.name, 2)))               AS category_name,
    CONCAT(UPPER(LEFT(l.name, 1)), LOWER(SUBSTRING(l.name, 2)))               AS language_name,
    f.length,
    COUNT(i.inventory_id) AS Copias_en_inventario
FROM film f
INNER JOIN film_category fc ON f.film_id     = fc.film_id
INNER JOIN category      c  ON fc.category_id = c.category_id
INNER JOIN language      l  ON f.language_id  = l.language_id
LEFT  JOIN inventory     i  ON f.film_id      = i.film_id
WHERE
    f.length > 0
    AND i.inventory_id IS NOT NULL
GROUP BY f.film_id, f.title, f.description, f.release_year, c.name, l.name;
```
## Dataframe 3 — Elenco y Popularidad
Consulta base de películas con categoría, idioma y copias disponibles, más una vista limpia con normalización de texto.

```python
USE sakila;

-- Consulta base
SELECT
    f.film_id,
    f.title           AS Pelicula,
    f.description     AS Descripcion,
    f.release_year    AS Año_lanzamiento,
    c.name            AS Categoria,
    l.name            AS Idioma,
    COUNT(i.inventory_id) AS Copias_en_inventario
FROM film f
INNER JOIN film_category fc ON f.film_id     = fc.film_id
INNER JOIN category      c  ON fc.category_id = c.category_id
INNER JOIN language      l  ON f.language_id  = l.language_id
LEFT  JOIN inventory     i  ON f.film_id      = i.film_id
GROUP BY f.film_id, f.title, f.description, f.release_year, c.name, l.name;

-- Vista limpia con normalización
CREATE OR REPLACE VIEW Vista_catalogo AS
SELECT
    f.film_id,
    CONCAT(UPPER(LEFT(f.title, 1)),       LOWER(SUBSTRING(f.title, 2)))       AS title_clean,
    CONCAT(UPPER(LEFT(f.description, 1)), LOWER(SUBSTRING(f.description, 2))) AS description_clean,
    CONCAT(UPPER(LEFT(c.name, 1)),        LOWER(SUBSTRING(c.name, 2)))        AS category_name,
    CONCAT(UPPER(LEFT(l.name, 1)),        LOWER(SUBSTRING(l.name, 2)))        AS language_name,
    f.length,
    f.rating,
    i.inventory_id
FROM film f
INNER JOIN film_category fc ON f.film_id     = fc.film_id
INNER JOIN category      c  ON fc.category_id = c.category_id
INNER JOIN language      l  ON f.language_id  = l.language_id
INNER JOIN inventory     i  ON f.film_id      = i.film_id
WHERE
    f.length > 0
    AND f.rating IS NOT NULL;

SELECT * FROM Vista_catalogo;
```

## 🧹 Criterios de limpieza
| Criterio | Implementación |
|---|---|
| Normalización de texto | `CONCAT(UPPER(LEFT(x,1)), LOWER(SUBSTRING(x,2)))` |
| Películas con duración inválida | `WHERE f.length > 0` |
| Películas sin rating | `AND f.rating IS NOT NULL` |
| Películas sin inventario | `LEFT JOIN inventory` |
| Integridad referencial | `INNER JOIN` en category y language |

## 🐍 Instrucciones para ejecutar el notebook
## Requisitos previos

## Cuenta en Google Colab
*Librerías:* pandas, numpy, matplotlib, seaborn (ya incluidas en Colab)
Archivo CSV exportado desde MySQL: Dataframe_2_CatalogoPeliculasFinal.csv

## Pasos

- Ejecutar el script SQL en MySQL Workbench y exportar el resultado como CSV.
- Subir el archivo CSV a Google Colab (panel lateral → icono de carpeta → subir archivo).
- Abrir el notebook analisis_sakila.ipynb en Google Colab.
- Ejecutar las celdas en orden de arriba hacia abajo (Shift + Enter celda a celda, o Runtime > Run all).

## 📓 Código del notebook
1. Carga y análisis previo del dataset

 ```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Cargamos el archivo CSV
df_cp = pd.read_csv('/content/Dataframe_2_CatalogoPeliculasFinal.csv')

# Vista previa
df_cp.head()

# Dimensiones del dataset
print(f"Nº Filas:    {df_cp.shape[0]}")
print(f"Nº Columnas: {df_cp.shape[1]}")

# Resumen estadístico de variables numéricas
df_cp.describe()
```
## 2. Agrupación por categoría
```python
# Conteo de películas por categoría
peliculas_por_categoria = (
    df_cp.groupby('category_name')['film_id']
    .count()
    .sort_values(ascending=False)
)
print(peliculas_por_categoria)

# Gráfico circular
category_counts = df_cp['category_name'].value_counts()

plt.figure(figsize=(10, 8))
plt.pie(
    category_counts,
    labels=category_counts.index,
    autopct='%1.1f%%',
    startangle=90,
    colors=sns.color_palette('pastel')
)
plt.title('Distribución de Categorías de Películas')
plt.axis('equal')
plt.show()
```
## 3. Columna derivada — duración
```python
# Columna binaria: 1 si la película dura más de 120 min
df_cp['is_long_film'] = (df_cp['length'] > 120).astype(int)

display(df_cp.head())
```
## Decisiones tomadas en el proyecto 👍

- Normalización con CONCAT + LEFT + SUBSTRING  en lugar de INITCAP() MySQL no dispone de la función INITCAP()
(exclusiva de PostgreSQL/Oracle). Se optó por construir el equivalente manualmente para mantener compatibilidad
 con el entorno de trabajo.

- LEFT JOIN en inventario para el catálogo general se usa LEFT JOIN con la tabla inventory para no incluir las peliculas
que aun no tienen copias físicas registradas. Esto permite tener una visión más completa del catálogo.

- INNER JOIN en inventario para vista limpia. En la vista vista_catalogo final se usa INNER JOIN con inventory
porque el análisis de popularidad requiere peliculas que esten en alquiler.

- Filtro f.length > 0 Garantiza que no se incluyan registros corruptos o placeholders con duración cero que distorsionarían
los análisis de duración.

- is_long_film como entero (0/1) Se eligió formato numérico sobre booleano o texto para facilitar operaciones posteriores como sum(),
 mean() o filtros directos en pandas.

- Alias descriptivos en SQL Se usaron alias en español (copias_inventario) en la consulta base para facilitar la lectura del equipo,
y en inglés (title_clean, category_name) en la vista limpia para mantener consistencia con el análisis en Python.

## Resultados del análisis

✔ Se ha agrupado las peliculas por categoria el top 5: Sports 73, Family 67, Foreign 67
y Animation 64.

✔ length: la película promedio dura 115.5 minutos (casi 2 horas).

Desviación Estándar ($40.4$): Es relativamente alta, lo que significa que tienes mucha variedad de formatos; el catálogo no está estancado en una sola duración estándar.

✔ Copias_en_inventario, el Promedio de Copias: tenemos unas 4.78 copias por título. 

 Mediana (50%): El 50% de tus películas tienen 5 copias o menos.
