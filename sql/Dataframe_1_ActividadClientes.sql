use sakila;
-- Extracción de datos de Sakila
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.active,
    a.address,
    a.district,
    a.postal_code
FROM customer c
JOIN address a ON c.address_id = a.address_id;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.active,
    a.address,
    a.district,
    a.postal_code,
    ci.city,
    co.country
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.active,
    a.address,
    a.district,
    a.postal_code,
    ci.city,
    co.country,
    r.rental_date,
    r.return_date
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN rental r ON c.customer_id = r.customer_id;

CREATE VIEW vista_customer_activity AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.active,
    a.address,
    a.district,
    a.postal_code,
    ci.city,
    co.country,
    r.rental_date,
    r.return_date,
     p.amount,
    p.payment_date
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON p.rental_id = r.rental_id;

-- Limpieza de datos en SQL
SELECT
    customer_id,
    LOWER(first_name) AS first_name,
    LOWER(last_name) AS last_name,
    LOWER(email) AS email,
    active,
    LOWER(address) AS address,
    LOWER(district) AS district,
    postal_code,
    LOWER(city) AS city,
    LOWER(country) AS country,
    rental_date,
    return_date,
    amount,
    payment_date,
    DATEDIFF(return_date, rental_date) AS rental_duration
FROM vista_customer_activity
WHERE
    rental_date IS NOT NULL
    AND return_date IS NOT NULL
    AND amount > 0
    AND rental_date < return_date;
