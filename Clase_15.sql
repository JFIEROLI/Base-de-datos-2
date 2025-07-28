USE sakila;

-- 1. Vista list_of_customers con estructura alternativa
CREATE VIEW list_of_customers_v2 AS
SELECT 
    c.customer_id AS Id,
    CONCAT(c.first_name, ' ', c.last_name) AS `Full Name`,
    a.address AS Address,
    a.postal_code AS `ZIP Code`,
    a.phone AS Phone,
    ci.city AS City,
    co.country AS Country,
    c.store_id AS `Store Id`,
    CASE 
        WHEN c.active = 1 THEN 'active'
        ELSE 'inactive'
    END AS Status
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

SELECT * FROM list_of_customers_v2;

-- 2. Vista film_details con subconsulta para actores
CREATE VIEW film_details_v2 AS
SELECT 
    f.film_id AS Id,
    f.title AS Title,
    f.description AS Description,
    cat.name AS Category,
    f.rental_rate AS Price,
    f.length AS Length,
    f.rating AS Rating,
    (
        SELECT GROUP_CONCAT(CONCAT(act.first_name, ' ', act.last_name) SEPARATOR ', ')
        FROM film_actor fa2
        JOIN actor act ON fa2.actor_id = act.actor_id
        WHERE fa2.film_id = f.film_id
    ) AS Actors
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id;

SELECT * FROM film_details_v2;

-- 3. Vista sales_by_film_category reestructurada sin subconsulta
CREATE VIEW sales_by_film_category_v2 AS
SELECT 
    cat.name AS Category,
    SUM(p.amount) AS total_rental
FROM category cat
JOIN film_category fc ON cat.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY cat.name;

SELECT * FROM sales_by_film_category_v2;

-- 4. Vista actor_information con subconsulta para contar películas
CREATE VIEW actor_information_v2 AS
SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    (
        SELECT COUNT(*) 
        FROM film_actor fa2
        WHERE fa2.actor_id = a.actor_id
    ) AS amount
FROM actor a;

SELECT * FROM actor_information_v2;



-- 5 Analyze view actor_info, explain the entire query and specially how the subquery works. Be very specific, 
-- break down each part and explain how everything connects.

SELECT * FROM actor_info a;

# Esta vista te muestra no solo en cuántas películas actuó cada actor, sino también exactamente cuáles fueron esas películas,
# y además las agrupa según el tipo de categoría (como acción, comedia, etc.).

# Para hacer esto, hay que meter varias consultas una dentro de otra. Primero se recorre cada categoría (por ejemplo: Horror),
# y después, por cada una, se buscan las películas que el actor haya hecho en ese género.

# Se puede armar algo así:

SELECT 
  a.actor_id,
  a.first_name,
  a.last_name,
  (
    SELECT GROUP_CONCAT(
      CONCAT(c.name, ': ', (
        SELECT GROUP_CONCAT(f.title SEPARATOR ', ')
        FROM film f
        JOIN film_category fc ON f.film_id = fc.film_id
        WHERE fc.category_id = c.category_id
          AND f.film_id IN (
            SELECT fa.film_id
            FROM film_actor fa
            WHERE fa.actor_id = a.actor_id
          )
      )) SEPARATOR ' | '
    )
    FROM category c
  ) AS films
FROM actor a;

# Lo que hace esa consulta es:
# - Agarra un actor.
# - Busca todas las categorías que existen.
# - Para cada categoría, junta los nombres de las pelis que el actor hizo en esa categoría.
# - Después usa CONCAT para pegar el nombre del género adelante (como "Drama: Película1, Película2").
# - Y al final, todo eso lo une con otro GROUP_CONCAT separado con barras (|) para que quede ordenado en una sola fila.

# Ejemplo de cómo quedaría la columna films:
# "Action: Die Hard, Terminator | Comedy: The Mask, Dumb and Dumber"

# Es una forma de mostrar mucho en poco espacio, y queda bastante más clara que solo tirar una lista de películas sin contexto.

---------------------------------------------------------------------

-- 6 Materialized views, write a description, why they are used, alternatives, DBMS where they exist, etc.

# Las vistas comunes en SQL funcionan como si fueran consultas que ya están escritas y guardadas con nombre.
# Pero no guardan datos. O sea, cada vez que usás una vista, en realidad está ejecutando la consulta desde cero otra vez.

# Las vistas materializadas son distintas: sí guardan el resultado en la base como si fuera una tabla.
# Por eso son útiles cuando una consulta tarda mucho o se usa muchas veces y no querés que se recalculen siempre los datos.

# ¿Por qué sirven?
# - Porque hacen que las consultas pesadas se vuelvan rápidas.
# - Si sabés que los datos no cambian todo el tiempo, podés tener algo guardado y listo para consultar.
# - Por ejemplo, si hacés reportes todos los días con los mismos datos, es mejor tener una vista materializada.

# Problema:
# - Si cambian los datos reales, esta vista no se actualiza sola (a menos que la refresques con un comando).

# ¿Dónde se pueden usar?
# - En PostgreSQL: se crean con `CREATE MATERIALIZED VIEW` y se actualizan con `REFRESH MATERIALIZED VIEW`.
# - En Oracle también existen, incluso tienen más opciones.
# - En MySQL o SQL Server no vienen por defecto, pero podés hacer algo parecido con tablas normales y programando cuándo se actualizan.

# Alternativas:
# - Hacer una tabla con la info precalculada y actualizarla cada tanto.
# - Guardar la info en caché desde la app.
# - Usar procedimientos almacenados para generar los datos cuando los necesitás.

# En resumen, las vistas materializadas son como sacar una foto de un resultado y guardarlo,
# en vez de estar sacando la misma foto todo el tiempo. Te ahorra tiempo y recursos si sabés cuándo usarlas.
