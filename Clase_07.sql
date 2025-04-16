USE sakila;

-- ✅ 1. Películas con menor duración (título y calificación)
SELECT f.title, f.rating
FROM film f
JOIN (
    SELECT MIN(length) AS min_len
    FROM film
) AS min_film ON f.length = min_film.min_len;

-- ✅ 2. Película única con menor duración (si hay más de una, no muestra nada)
SELECT title
FROM film
WHERE length = (
    SELECT length
    FROM film
    GROUP BY length
    HAVING COUNT(*) = 1
    ORDER BY length ASC
    LIMIT 1
);

-- ✅ 3A. Pago mínimo por cliente usando MIN() con CTE
WITH min_payments AS (
    SELECT customer_id, MIN(amount) AS min_amount
    FROM payment
    GROUP BY customer_id
)
SELECT cu.first_name, cu.last_name, a.address, mp.min_amount AS min_payment
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN min_payments mp ON cu.customer_id = mp.customer_id;

-- ✅ 3B. Pago mínimo por cliente usando ALL y LIMIT (sin MIN())
SELECT cu.first_name, cu.last_name, a.address,
    (
        SELECT p.amount
        FROM payment p
        WHERE p.customer_id = cu.customer_id
        AND p.amount <= ALL (
            SELECT p2.amount
            FROM payment p2
            WHERE p2.customer_id = cu.customer_id
        )
        LIMIT 1
    ) AS min_payment
FROM customer cu
JOIN address a ON cu.address_id = a.address_id;

-- ✅ 4. Cliente con pago mínimo y máximo en una sola fila (concatenado con "|")
SELECT cu.first_name, cu.last_name, a.address,
       CONCAT_WS(' | ',
           (SELECT MIN(p.amount) FROM payment p WHERE p.customer_id = cu.customer_id),
           (SELECT MAX(p.amount) FROM payment p WHERE p.customer_id = cu.customer_id)
       ) AS min_max_payment
FROM customer cu
JOIN address a ON cu.address_id = a.address_id;
