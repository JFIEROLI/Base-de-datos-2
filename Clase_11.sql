
USE sakila;

-- 1) Películas que no se encuentran en el inventario
SELECT f.title AS peliculas_fuera_de_stock
FROM film f
WHERE NOT EXISTS (
    SELECT 1 
    FROM inventory i 
    WHERE i.film_id = f.film_id
);

-- 2) Películas que están en inventario pero que nunca fueron alquiladas
SELECT f.title, i.inventory_id
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE i.inventory_id NOT IN (
    SELECT inventory_id FROM rental
);

-- 3) Listado de alquileres con datos del cliente, tienda y película
SELECT 
    c.first_name, 
    c.last_name, 
    c.store_id,
    f.title AS pelicula,
    r.rental_date AS fecha_alquiler,
    r.return_date AS fecha_devolucion
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
ORDER BY c.store_id, c.last_name;

-- 4) Ventas totales por tienda incluyendo localización y gerente a cargo
SELECT 
    CONCAT(ci.city, ', ', co.country) AS ubicacion,
    CONCAT(st.first_name, ' ', st.last_name) AS encargado,
    (
        SELECT SUM(p.amount)
        FROM payment p
        JOIN rental r ON p.rental_id = r.rental_id
        JOIN customer c ON r.customer_id = c.customer_id
        WHERE c.store_id = s.store_id
    ) AS ventas_totales
FROM store s
JOIN staff st ON st.staff_id = s.manager_staff_id
JOIN address a ON a.address_id = s.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country co ON co.country_id = ci.country_id;

-- 5) Actor con mayor número de participaciones en películas
SELECT 
    a.first_name, 
    a.last_name,
    COUNT(fa.film_id) AS cantidad_peliculas
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY cantidad_peliculas DESC
LIMIT 1;
