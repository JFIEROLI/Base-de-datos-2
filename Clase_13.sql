-- Clase 9 - Proyecto SQL - Lucas Ramírez
USE sakila;

-- 1) Añadir un nuevo cliente ficticio
SELECT * FROM customer
ORDER BY customer_id DESC;

INSERT INTO customer (
    store_id, first_name, last_name, email, address_id, active
) VALUES (
    2,
    'Lucas',
    'Ramírez',
    'lucas.ramirez84@gmail.com',
    (
        SELECT ad.address_id
        FROM address ad
        JOIN city ci ON ad.city_id = ci.city_id
        JOIN country pa ON ci.country_id = pa.country_id
        ORDER BY ad.address_id DESC
        LIMIT 1
    ),
    1
);

-- 2) Registrar un nuevo alquiler de película
SELECT * FROM rental
ORDER BY rental_id DESC;

INSERT INTO rental (
    rental_date, inventory_id, customer_id, return_date, staff_id
) VALUES (
    NOW(),
    (
        SELECT inv.inventory_id
        FROM inventory inv
        JOIN film pel ON inv.film_id = pel.film_id
        WHERE pel.title = 'ZORRO UNCHAINED'
        LIMIT 1
    ),
    (
        SELECT cli.customer_id
        FROM customer cli
        ORDER BY cli.customer_id DESC
        LIMIT 1
    ),
    DATE_ADD(NOW(), INTERVAL 7 DAY),
    (
        SELECT emp.staff_id
        FROM staff emp
        WHERE emp.store_id = 1
        LIMIT 1
    )
);

-- 3) Modificar el año de estreno de las películas según clasificación
SELECT DISTINCT release_year FROM film
ORDER BY film_id DESC;

UPDATE film SET release_year = 1999 WHERE rating = 'G';
UPDATE film SET release_year = 2000 WHERE rating = 'R';
UPDATE film SET release_year = 2001 WHERE rating = 'NC-17';
UPDATE film SET release_year = 2002 WHERE rating = 'PG-13';
UPDATE film SET release_year = 2003 WHERE rating = 'PG';

-- 4) Actualizar el registro de devolución más reciente pendiente
SELECT ren.rental_id
FROM rental ren
WHERE ren.return_date IS NULL
ORDER BY ren.rental_date DESC
LIMIT 1;

UPDATE rental
SET return_date = NOW()
WHERE rental_id = 11739;

SELECT * FROM rental WHERE rental_id = 11739;

-- 5) Eliminar una película con todas sus referencias asociadas
SELECT * FROM film ORDER BY film_id DESC;

-- Borrar relaciones actor-película
DELETE FROM film_actor WHERE film_id = 1000;

-- Borrar relaciones categoría-película
DELETE FROM film_category WHERE film_id = 1000;

-- Borrar pagos asociados a sus alquileres (si es necesario)
DELETE FROM payment
WHERE rental_id IN (
    SELECT rental_id FROM rental
    WHERE inventory_id IN (
        SELECT inventory_id FROM inventory WHERE film_id = 1000
    )
);

-- Borrar alquileres relacionados
DELETE FROM rental
WHERE inventory_id IN (
    SELECT inventory_id FROM inventory WHERE film_id = 1000
);

-- Borrar del inventario
DELETE FROM inventory WHERE film_id = 1000;

-- Finalmente eliminar la película
DELETE FROM film WHERE film_id = 1000;

-- 6) Registrar nuevo alquiler y su correspondiente pago
SELECT inv.inventory_id
FROM inventory inv
WHERE inv.inventory_id NOT IN (
    SELECT rental.inventory_id FROM rental
)
LIMIT 1;

SELECT * FROM rental ORDER BY rental_id DESC;
SELECT * FROM payment ORDER BY payment_id DESC;

-- Agregar nuevo alquiler con ítem disponible
INSERT INTO rental (
    rental_date, inventory_id, customer_id, staff_id
) VALUES (
    NOW(),
    (
        SELECT inventory_id
        FROM inventory
        WHERE inventory_id NOT IN (
            SELECT inventory_id FROM rental
        )
        LIMIT 1
    ),
    2,
    1
);

-- Registrar el pago correspondiente al alquiler anterior
INSERT INTO payment (
    customer_id, staff_id, rental_id, amount, payment_date
) VALUES (
    (
        SELECT customer_id
        FROM rental
        ORDER BY rental_id DESC
        LIMIT 1
    ),
    (
        SELECT staff_id
        FROM rental
        ORDER BY rental_id DESC
        LIMIT 1
    ),
    (
        SELECT rental_id
        FROM rental
        ORDER BY rental_id DESC
        LIMIT 1
    ),
    12.50,
    NOW()
);
