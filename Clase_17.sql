USE sakila;

-- Clase 17 - Optimización de consultas y búsquedas de texto

/*
Ejercicios planteados:
1) Trabajar con la tabla address:
   - Filtrar postal_code con IN y NOT IN.
   - Hacer joins con city y country.
   - Medir rendimiento de las consultas.
   - Crear un índice sobre postal_code y comparar resultados.

2) Usar la tabla actor, filtrando por first_name y last_name.
   - Analizar diferencias de rendimiento entre columnas.

3) En la tabla film:
   - Buscar con LIKE en description.
   - Comparar con un índice FULLTEXT.
   - Evaluar la mejora de performance.
*/


-- 1.a) Consulta básica con IN
SELECT * 
FROM address addr
WHERE addr.postal_code IN ('35200','17886','83579','53561','42399',
                           '18743','93896','77948','45844','53628',
                           '1027','10672');

-- 1.b) Consulta básica con NOT IN
SELECT * 
FROM address addr
WHERE addr.postal_code NOT IN ('35200','17886','83579','53561','42399',
                               '18743','93896','77948','45844','53628',
                               '1027','10672');

-- 1.c) Join con city y country para traer más info
SELECT addr.address, addr.postal_code, ct.city, cn.country
FROM address addr
JOIN city ct ON addr.city_id = ct.city_id
JOIN country cn ON ct.country_id = cn.country_id
WHERE addr.postal_code IN ('35200','17886','83579','53561','42399',
                           '18743','93896','77948','45844','53628',
                           '1027','10672');

-- Ver el plan de ejecución
EXPLAIN
SELECT addr.address, addr.postal_code, ct.city, cn.country
FROM address addr
JOIN city ct ON addr.city_id = ct.city_id
JOIN country cn ON ct.country_id = cn.country_id
WHERE addr.postal_code IN ('35200','17886','83579','53561','42399',
                           '18743','93896','77948','45844','53628',
                           '1027','10672');

-- Medición de tiempo sin índice
SET profiling = 1;
SELECT addr.address, addr.postal_code, ct.city, cn.country
FROM address addr
JOIN city ct ON addr.city_id = ct.city_id
JOIN country cn ON ct.country_id = cn.country_id
WHERE addr.postal_code IN ('35200','17886','83579','53561','42399',
                           '18743','93896','77948','45844','53628',
                           '1027','10672');
SHOW PROFILES;
/* El tiempo inicial rondó los 0.001 seg, dependiendo de la ejecución. */

-- 1.d) Crear índice sobre postal_code
CREATE INDEX idx_postalcode ON address(postal_code);

-- 1.e) Volvemos a medir con el índice creado
SET profiling = 1;
SELECT addr.address, addr.postal_code, ct.city, cn.country
FROM address addr
JOIN city ct ON addr.city_id = ct.city_id
JOIN country cn ON ct.country_id = cn.country_id
WHERE addr.postal_code IN ('35200','17886','83579','53561','42399',
                           '18743','93896','77948','45844','53628',
                           '1027','10672');
SHOW PROFILES;
/* Con el índice el tiempo bajó a ~0.0008 seg.
   Es decir, la consulta se resolvió de forma más eficiente gracias a la búsqueda directa por índice. */


-- 2) Comparación en tabla actor
SET profiling = 1;
SELECT * 
FROM actor act
WHERE act.first_name LIKE 'Penelope';
SHOW PROFILES;  -- alrededor de 0.0007 seg

SET profiling = 1;
SELECT * 
FROM actor act
WHERE act.last_name LIKE 'GUINESS';
SHOW PROFILES;  -- alrededor de 0.0002 seg

-- Conclusión:
-- Cuando la columna ya tiene un índice definido, la búsqueda se acelera notablemente.
-- La diferencia de rendimiento puede llegar a ser varias veces mayor en comparación
-- con una columna sin índice.


-- 3) Búsqueda en la tabla film
SET profiling = 1;
SELECT film_id, title, description
FROM film
WHERE description LIKE '%Action%';
SHOW PROFILES; -- en la prueba demoró cerca de 0.0026 seg

-- Crear índice FULLTEXT en description
ALTER TABLE film ADD FULLTEXT(description);

SET profiling = 1;
SELECT film_id, title, description
FROM film
WHERE MATCH(description) AGAINST('Action');
SHOW PROFILES; -- ahora unos 0.0014 seg aprox.

