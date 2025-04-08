USE sakila;

-- 1. Intérpretes con el mismo apellido que otro, pero con ID distinto
SELECT ac.first_name, ac.last_name
FROM actor ac
WHERE EXISTS (
    SELECT 1
    FROM actor a_comp
    WHERE ac.last_name = a_comp.last_name
      AND ac.actor_id <> a_comp.actor_id
)
ORDER BY ac.last_name, ac.first_name;

-- 2. Intérpretes que no trabajaron en ningún film
SELECT ac.first_name, ac.last_name
FROM actor ac
LEFT JOIN film_actor fa_map ON ac.actor_id = fa_map.actor_id
WHERE fa_map.film_id IS NULL;

-- 3. Clientes que solo alquilaron un solo ítem
SELECT cl.first_name, cl.last_name
FROM customer cl
WHERE cl.customer_id IN (
    SELECT rent.customer_id
    FROM rental rent
    GROUP BY rent.customer_id
    HAVING COUNT(DISTINCT rent.inventory_id) = 1
);

-- 4. Clientes que alquilaron más de un ítem diferente
SELECT cl.first_name, cl.last_name
FROM customer cl
WHERE cl.customer_id IN (
    SELECT rent.customer_id
    FROM rental rent
    GROUP BY rent.customer_id
    HAVING COUNT(DISTINCT rent.inventory_id) > 1
);

-- 5. Actores que participaron en 'BETRAYED REAR' o 'CATCH AMISTAD'
SELECT DISTINCT ac.first_name, ac.last_name
FROM actor ac
INNER JOIN film_actor fa ON ac.actor_id = fa.actor_id
WHERE fa.film_id IN (
    SELECT fl.film_id
    FROM film fl
    WHERE fl.title IN ('BETRAYED REAR', 'CATCH AMISTAD')
);

-- 6. Actores que estuvieron en 'BETRAYED REAR' pero no en 'CATCH AMISTAD'
SELECT ac.first_name, ac.last_name
FROM actor ac
WHERE ac.actor_id IN (
    SELECT f1.actor_id
    FROM film_actor f1
    INNER JOIN film m1 ON f1.film_id = m1.film_id
    WHERE m1.title = 'BETRAYED REAR'
)
AND ac.actor_id NOT IN (
    SELECT f2.actor_id
    FROM film_actor f2
    INNER JOIN film m2 ON f2.film_id = m2.film_id
    WHERE m2.title = 'CATCH AMISTAD'
);

-- 7. Actores que participaron en ambas películas
SELECT ac.first_name, ac.last_name
FROM actor ac
WHERE ac.actor_id IN (
    SELECT fa1.actor_id
    FROM film_actor fa1
    JOIN film f1 ON fa1.film_id = f1.film_id
    WHERE f1.title = 'BETRAYED REAR'
)
AND ac.actor_id IN (
    SELECT fa2.actor_id
    FROM film_actor fa2
    JOIN film f2 ON fa2.film_id = f2.film_id
    WHERE f2.title = 'CATCH AMISTAD'
);

-- 8. Actores que no actuaron en ninguna de las dos películas
SELECT ac.first_name, ac.last_name
FROM actor ac
WHERE ac.actor_id NOT IN (
    SELECT f_comb.actor_id
    FROM film_actor f_comb
    JOIN film movie ON f_comb.film_id = movie.film_id
    WHERE movie.title IN ('BETRAYED REAR', 'CATCH AMISTAD')
);
