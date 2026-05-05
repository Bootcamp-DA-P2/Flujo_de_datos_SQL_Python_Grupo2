USE sakila;
CREATE VIEW Vista_catalogo AS
SELECT
    f.film_id,
    CONCAT(UPPER(LEFT(f.title,1)), LOWER(SUBSTRING(f.title,2))) AS title_clean,
    CONCAT(UPPER(LEFT(f.description,1)), LOWER(SUBSTRING(f.description,2))) AS description_clean,
    CONCAT(UPPER(LEFT(c.name,1)), LOWER(SUBSTRING(c.name,2))) AS category_name, 
    CONCAT(UPPER(LEFT(l.name,1)), LOWER(SUBSTRING(l.name,2))) AS language_name,
    f.length,
    COUNT(i.inventory_id) AS Copias_en_inventario
FROM film f
-- Relación con categorías (muchos a muchos)
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
-- Relación con idioma
INNER JOIN language l ON f.language_id = l.language_id
-- Relación con inventario (LEFT JOIN por si alguna película no tiene copias)
LEFT JOIN inventory i ON f.film_id = i.film_id
WHERE 
    -- Limpieza de registros inválidos
    f.length > 0 
    -- Verificación de integridad de inventario
    AND i.inventory_id IS NOT NULL

GROUP BY f.film_id, f.title, f.description, f.release_year, c.name, l.name;