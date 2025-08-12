USE sakila;

-- 1) Listar clientes residentes en México con nombre completo, dirección y ciudad
SELECT 
    CONCAT_WS(' ', c.first_name, c.last_name) AS cliente,
    a.address AS direccion,
    ci.city AS ciudad
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Mexico';


-- 2) Películas con idioma y detalle del rating en texto completo
SELECT 
    f.title AS titulo,
    l.name AS idioma,
    CASE f.rating
        WHEN 'G' THEN 'Apto para todos'
        WHEN 'PG' THEN 'Recomendación de guía paterna'
        WHEN 'PG-13' THEN 'Puede no ser apta para menores de 13'
        WHEN 'R' THEN 'Menores de 17 con adulto'
        WHEN 'NC-17' THEN 'Solo adultos'
        ELSE 'Sin especificar'
    END AS clasificacion
FROM film f
JOIN language l ON f.language_id = l.language_id;


-- 3) Buscar películas de un actor cuyo nombre se ingresa manualmente
SET @actor_nombre = 'Nick';

SELECT 
    f.title AS pelicula,
    f.release_year AS anio,
    CONCAT(a.first_name, ' ', a.last_name) AS actor
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
WHERE CONCAT(a.first_name, ' ', a.last_name) LIKE CONCAT('%', @actor_nombre, '%');


-- 4) Rentas hechas en julio y agosto con indicador de devolución
SELECT 
    f.title AS pelicula,
    CONCAT(c.first_name, ' ', c.last_name) AS cliente,
    IF(r.return_date IS NULL, 'No', 'Si') AS devuelta
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE MONTH(r.rental_date) IN (7, 8);


-- 5) Ejemplos CAST y CONVERT
-- CAST
SELECT f.title, CAST(f.rental_duration AS CHAR) AS duracion_texto
FROM film f;

-- CONVERT
SELECT f.title, CONVERT(f.rental_duration, CHAR) AS duracion_texto
FROM film f;


-- 6) Ejemplos con IFNULL y COALESCE
-- IFNULL
SELECT 
    f.title AS pelicula,
    CONCAT(c.first_name, ' ', c.last_name) AS cliente,
    IFNULL(r.return_date, 'No devuelta') AS fecha
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE r.return_date IS NULL;

-- COALESCE
SELECT 
    f.title AS pelicula,
    CONCAT(c.first_name, ' ', c.last_name) AS cliente,
    COALESCE(r.return_date, 'No devuelta') AS fecha
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE r.return_date IS NULL;
