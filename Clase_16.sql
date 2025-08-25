USE sakila;



# Primero armamos la tabla employees (similar a la de staff, pero adaptada):

CREATE TABLE employees (
  employeeNumber INT(11) NOT NULL,
  lastName VARCHAR(50) NOT NULL,
  firstName VARCHAR(50) NOT NULL,
  extension VARCHAR(10) NOT NULL,
  email VARCHAR(100) NOT NULL,
  officeCode VARCHAR(10) NOT NULL,
  reportsTo INT(11) DEFAULT NULL,
  jobTitle VARCHAR(50) NOT NULL,
  PRIMARY KEY (employeeNumber)
);

INSERT INTO employees (employeeNumber,lastName,firstName,extension,email,officeCode,reportsTo,jobTitle) VALUES
(1002,'Murphy','Diane','x5800','dmurphy@classicmodelcars.com','1',NULL,'President'),
(1056,'Patterson','Mary','x4611','mpatterson@classicmodelcars.com','1',1002,'VP Sales'),
(1076,'Firrelli','Jeff','x9273','jfirrelli@classicmodelcars.com','1',1002,'VP Marketing');

# Creamos una tabla de auditoría para registrar cambios:
CREATE TABLE emp_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empNumber INT NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    change_date DATETIME,
    action VARCHAR(30)
);

DELIMITER $$
CREATE TRIGGER trg_emp_before_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO emp_audit (empNumber, lastname, change_date, action)
    VALUES (OLD.employeeNumber, OLD.lastName, NOW(), 'UPDATE');
END$$
DELIMITER ;

-- Probamos una actualización
UPDATE employees
SET lastName = 'Pham'
WHERE employeeNumber = 1056;

SELECT * FROM emp_audit;

-------------------------------------------------------------
-- 1) Insert con email NULL
-------------------------------------------------------------
INSERT INTO employees
(employeeNumber,lastName,firstName,extension,email,officeCode,reportsTo,jobTitle)
VALUES
(2001,'Perez','Juan','x101',NULL,'1',1002,'Tester');

-- Explicación:
-- Como la columna "email" se definió con NOT NULL, el insert falla.
-- Esto garantiza que siempre haya un correo válido almacenado,
-- incluso si se intentara saltar la validación desde la aplicación.

-------------------------------------------------------------
-- 2) UPDATE restando y sumando 20
-------------------------------------------------------------
UPDATE employees SET employeeNumber = employeeNumber - 20;
-- Esto intenta modificar TODOS los registros (sin WHERE).
-- Cada fila se actualiza y se guarda el valor previo en emp_audit.
-- El problema es que se pueden generar claves primarias duplicadas.

UPDATE employees SET employeeNumber = employeeNumber + 20;
-- Al hacer la operación inversa vuelve a chocar con la PK,
-- porque algunos valores ya quedaron repetidos al correrse todos.
-- MySQL no permite dos filas con la misma PK, por eso el error.

-------------------------------------------------------------
-- 3) Columna Age con rango 16–70
-------------------------------------------------------------
ALTER TABLE employees
ADD COLUMN age INT,
ADD CONSTRAINT chk_age CHECK (age BETWEEN 16 AND 70);

-- Ejemplo válido:
INSERT INTO employees
(employeeNumber,lastName,firstName,extension,email,officeCode,reportsTo,jobTitle,age)
VALUES
(3000,'Test','User','x200','test@empresa.com','1',NULL,'Sales Rep',25);

-- Ejemplo inválido:
INSERT INTO employees
(employeeNumber,lastName,firstName,extension,email,officeCode,reportsTo,jobTitle,age)
VALUES
(3001,'Otro','Usuario','x201','otro@empresa.com','1',NULL,'Sales Rep',10);

-------------------------------------------------------------
-- 4) Integridad referencial film, actor, film_actor
-------------------------------------------------------------
-- film tiene PK = film_id
-- actor tiene PK = actor_id
-- film_actor combina ambas en una PK compuesta (film_id, actor_id).
-- Además tiene 2 FKs que apuntan a las tablas principales.
-- Esto asegura que sólo se puedan relacionar actores y películas que existan,
-- y evita que haya registros "colgados".

-------------------------------------------------------------
-- 5) Columnas lastUpdate y lastUpdateUser con triggers
-------------------------------------------------------------
ALTER TABLE employees
ADD COLUMN lastUpdate DATETIME DEFAULT NOW(),
ADD COLUMN lastUpdateUser VARCHAR(50);

DELIMITER $$
CREATE TRIGGER trg_emp_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = NOW();
    SET NEW.lastUpdateUser = CURRENT_USER();
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_emp_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = NOW();
    SET NEW.lastUpdateUser = CURRENT_USER();
END$$
DELIMITER ;

INSERT INTO employees (employeeNumber,lastName,firstName,extension,email,officeCode,reportsTo,jobTitle)
VALUES (4000,'Lopez','Ana','x150','alopez@mail.com','1',1002,'Asistente');

SELECT * FROM employees;

-------------------------------------------------------------
-- 6) Triggers sobre film_text en Sakila
-------------------------------------------------------------
SHOW TRIGGERS LIKE 'film';

-- Explicación:
-- ins_film (AFTER INSERT): cada vez que se agrega una película,
-- inserta en film_text el id, título y descripción.
--
-- upd_film (AFTER UPDATE): cuando cambia título/descr/id,
-- actualiza los datos correspondientes en film_text.
--
-- del_film (AFTER DELETE): si se elimina una película,
-- borra la fila relacionada en film_text.
-- En resumen, estos triggers mantienen film_text sincronizado
-- con los datos de la tabla film.
