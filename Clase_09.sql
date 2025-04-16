USE sakila;

-- #1: Ciudades por país
SELECT co.country, COUNT(ci.city_id) AS cities_per_country
FROM country co
LEFT JOIN city ci ON co.country_id = ci.country_id
GROUP BY co.country, co.country_id
ORDER BY co.country_id;

-- #2: Ciudades por país con más de 10 ciudades
SELECT co.country, COUNT(ci.city_id) AS cities_per_country
FROM country co
LEFT JOIN city ci ON co.country_id = ci.country_id
GROUP BY co.country, co.country_id
HAVING COUNT(ci.city_id) > 10
ORDER BY cities_per_country;

-- #3: Películas rentadas y total gastado por cliente
SELECT c.first_name, c.last_name, a.address,
       COUNT(r.rental_id) AS total_films_rented,
       SUM(p.amount) AS total_spent
FROM customer c
JOIN address a ON c.address_id = a.address_id
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.first_name, c.last_name, a.address
ORDER BY total_spent DESC;

-- #4: Duración promedio de películas por categoría
SELECT ca.name AS category_name, AVG(f.length) AS average_film_duration
FROM category ca
JOIN film_category fc ON ca.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY ca.category_id, ca.name
ORDER BY average_film_duration DESC;

-- #5: Ganancias totales por rating
SELECT f.rating, SUM(p.amount) AS total_earnings
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.rating
ORDER BY f.rating;
