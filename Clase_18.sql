USE sakila;

-- Clase 18 - Funciones y procedimientos en Sakila

/*
Ejercicios:
1) Función para contar copias de una película en una tienda.
2) Procedimiento que devuelve clientes de un país usando cursor.
3) Revisar función inventory_in_stock y procedimiento film_in_stock,
   explicar qué hacen y dar ejemplos.
*/


-- 1) Función: cantidad de copias de una película en determinada tienda
DELIMITER $$

CREATE FUNCTION copias_por_film(
    p_film_id INT,
    p_store_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE cantidad INT;

    SELECT COUNT(*)
    INTO cantidad
    FROM inventory inv
    WHERE inv.store_id = p_store_id
      AND inv.film_id = p_film_id;

    RETURN cantidad;
END$$

DELIMITER ;

-- Ejemplo
SELECT copias_por_film(1,1) AS total_copias;



-- 2) Procedimiento: clientes por país con cursor
DELIMITER $$

CREATE PROCEDURE clientes_por_pais(
    IN p_country VARCHAR(100),
    OUT p_lista TEXT
)
BEGIN
    DECLARE terminado INT DEFAULT 0;
    DECLARE cliente_nombre VARCHAR(200);

    DECLARE cur CURSOR FOR
        SELECT CONCAT(c.first_name,' ',c.last_name)
        FROM customer c
        JOIN address a ON c.address_id = a.address_id
        JOIN city ci ON a.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        WHERE co.country LIKE p_country;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET terminado = 1;

    SET p_lista = '';

    OPEN cur;

    loop_clientes: LOOP
        FETCH cur INTO cliente_nombre;
        IF terminado = 1 THEN
            LEAVE loop_clientes;
        END IF;

        SET p_lista = CONCAT(p_lista, cliente_nombre, '; ');
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

-- Ejemplo
CALL clientes_por_pais('Argentina', @clientes);
SELECT @clientes;



-- 3a) Función inventory_in_stock
SHOW CREATE FUNCTION inventory_in_stock;

-- Explicación:
-- Sirve para saber si una copia de película está disponible o no.
-- Si nunca se alquiló → devuelve 1 (sí está en stock).
-- Si se alquiló pero no la devolvieron → devuelve 0 (no está en stock).
-- Si ya la devolvieron → vuelve a 1.

-- Ejemplo:
SELECT inventory_in_stock(inventory_id) AS disponible
FROM inventory
LIMIT 10;



-- 3b) Procedimiento film_in_stock
SHOW CREATE PROCEDURE film_in_stock;

-- Explicación:
-- Recibe el id de una película y de una tienda.
-- Devuelve todas las copias que están en stock en esa tienda.
-- Además, con el parámetro OUT te da la cantidad total de copias disponibles.

-- Ejemplo:
CALL film_in_stock(1,1,@cantidad);
SELECT @cantidad AS disponibles;
