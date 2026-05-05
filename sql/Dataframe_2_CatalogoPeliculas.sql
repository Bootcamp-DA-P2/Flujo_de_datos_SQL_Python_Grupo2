USE sakila;

SELECT
	f.film_id,
    f.title AS Pelicula,
    f.description AS Descripcion,
    f.release_year AS Año_lanzamiento,
    c.name AS Categoria,
    l.name AS Idioma,
    COUNT(i.inventory_id) AS Copias_en_inventario
FROM film f
-- Relación con categorías (muchos a muchos)
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
-- Relación con idioma
INNER JOIN language l ON f.language_id = l.language_id
-- Relación con inventario (LEFT JOIN por si alguna película no tiene copias)
LEFT JOIN inventory i ON f.film_id = i.film_id
GROUP BY f.film_id, f.title, f.description, f.release_year, c.name, l.name;

-- Limpieza de datos con SQL
CREATE OR REPLACE VIEW Vista_catalogo AS
SELECT 
-- Normalizamos títulos y descripciones
    f.film_id,
    LOWER(TRIM(f.title)) AS title_clean,
    LOWER(TRIM(f.description)) AS description_clean,
-- Unificamos nombres de categoría e idioma
    LOWER(c.name) AS category_name,
    LOWER(l.name) AS language_name,
    f.length,
    f.rating,
    i.inventory_id
-- Películas con la categoría asignada
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN language l ON f.language_id = l.language_id
INNER JOIN inventory i ON f.film_id = i.film_id
-- Eliminamos registros con duración 0 y/o valor nulo
WHERE 
	f.length > 0 
	AND f.rating IS NOT NULL;

SELECT * FROM Vista_catalogo LIMIT 10;