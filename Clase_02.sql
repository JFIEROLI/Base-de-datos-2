Drop database if exists imdb;
CREATE DATABASE IF NOT EXISTS imdb;
USE imdb;


CREATE TABLE IF NOT EXISTS pelicula (
    id_pelicula INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    anio_de_estreno YEAR NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS  actor (
    id_actor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS  actor_de_pelicula (
    id_actor INT,
    id_pelicula INT,
    PRIMARY KEY (id_actor, id_pelicula),
    FOREIGN KEY (id_actor) REFERENCES actor(id_actor) ON DELETE CASCADE,
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula) ON DELETE CASCADE
);


INSERT INTO pelicula (titulo, descripcion, anio_de_estreno) VALUES
('El Padrino', 'Un drama sobre la mafia', 1972),
('Titanic', 'Historia de un barco legendario', 1997),
('Matrix', 'Realidad simulada y luchas cibernéticas', 1999);


INSERT INTO actor (nombre, apellido) VALUES
('Marlon', 'Brando'),
('Leonardo', 'DiCaprio'),
('Keanu', 'Reeves');


INSERT INTO actor_de_pelicula (id_actor, id_pelicula) VALUES
(1, 1), -- Marlon Brando en El Padrino
(2, 2), -- Leonardo DiCaprio en Titanic
(3, 3); -- Keanu Reeves en Matrix

