USE sakila;

WITH actor_cleaned AS (
    -- Estandarización y eliminación de duplicados por nombre (para evitar que cuenten los actores como personas distintas)
    SELECT 
        actor_id,
        LOWER(TRIM(first_name)) AS first_name,
        LOWER(TRIM(last_name)) AS last_name
    FROM actor
    -- Filtramos duplicados: nos quedamos solo con el primer ID para cada combinación de nombre/apellido
    WHERE actor_id IN (
        SELECT MIN(actor_id)
        FROM actor
        GROUP BY LOWER(TRIM(first_name)), LOWER(TRIM(last_name))
    )
),
film_actor_verified AS (
    -- Aseguramos joins consistentes (integridad referencial)
    -- Solo tomamos registros donde el actor y la película existen en sus respectivas tablas
    SELECT fa.film_id, fa.actor_id
    FROM film_actor fa
    INNER JOIN film f ON fa.film_id = f.film_id
    INNER JOIN actor_cleaned a ON fa.actor_id = a.actor_id
)
-- La función COUNT(*) OVER nos muestra cuántas veces aparece el actor, sin perder los títulos 
SELECT 
    f.title AS pelicula,
    ac.first_name,
    ac.last_name,
    COUNT(*) OVER(PARTITION BY ac.actor_id) AS frecuencia_actor_total
FROM film_actor_verified fav
JOIN film f ON fav.film_id = f.film_id
JOIN actor_cleaned ac ON fav.actor_id = ac.actor_id
ORDER BY frecuencia_actor_total DESC, f.title;