BEGIN;

-- Asegurarse de que no haya errores antes de aplicar los cambios
SET CONSTRAINTS ALL IMMEDIATE;

-- Creación de la tabla alembic_version si no existe
CREATE TABLE IF NOT EXISTS alembic_version (
    version_num VARCHAR(32) NOT NULL,
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);

-- Inserción de la versión solo si no existe
INSERT INTO alembic_version (version_num)
SELECT 'e2ca680bb785'
WHERE NOT EXISTS (SELECT 1 FROM alembic_version WHERE version_num = 'e2ca680bb785');

-- Creación de la tabla film
CREATE TABLE film (
    id SERIAL PRIMARY KEY,
    title VARCHAR,
    length INTEGER,
    year INTEGER,
    director VARCHAR
);

-- Inserción de datos en la tabla film de manera agrupada
INSERT INTO film (title, length, year, director) VALUES
('El Abrazo de la Serpiente', 125, 2015, 'Ciro Guerra'),
('La estrategia del caracol', 116, 1993, 'Sergio Cabrera'),
('Los colores de la montana', 90, 2010, 'Carlos Cesar Arbelaez'),
('La vendedora de rosas', 115, 1998, 'Victor Gaviria'),
('Paraiso Travel', 110, 2008, 'Simon Brand');

-- Creación de la tabla actor
CREATE TABLE actor (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    film_id INTEGER NOT NULL,
    FOREIGN KEY(film_id) REFERENCES film (id)
);

-- Inserción de datos en la tabla actor de manera agrupada
INSERT INTO actor (name, film_id) VALUES
('Antonio Bolivar', (SELECT id FROM film WHERE title = 'El Abrazo de la Serpiente')),
('Brionne Davis', (SELECT id FROM film WHERE title = 'El Abrazo de la Serpiente')),
('Hernan Mendez', (SELECT id FROM film WHERE title = 'La estrategia del caracol')),
('Florina Lemaitre', (SELECT id FROM film WHERE title = 'La estrategia del caracol')),
('Genaro Aristizabal', (SELECT id FROM film WHERE title = 'Los colores de la montana')),
('Hernan Mauricio Ocampo', (SELECT id FROM film WHERE title = 'La vendedora de rosas')),
('Leidy Tabares', (SELECT id FROM film WHERE title = 'La vendedora de rosas')),
('Mileider Gil', (SELECT id FROM film WHERE title = 'La vendedora de rosas')),
('Angelica Blandon', (SELECT id FROM film WHERE title = 'Paraiso Travel')),
('Pedro Capo', (SELECT id FROM film WHERE title = 'Paraiso Travel')),
('John Leguizamo', (SELECT id FROM film WHERE title = 'Paraiso Travel')),
('Carlos Mario Escobar', (SELECT id FROM film WHERE title = 'La estrategia del caracol')),
('Carlos Mario Escobar', (SELECT id FROM film WHERE title = 'Los colores de la montana')),
('Maria Alejandra Palacio', (SELECT id FROM film WHERE title = 'La estrategia del caracol')),
('Maria Alejandra Palacio', (SELECT id FROM film WHERE title = 'Paraiso Travel')),
('Ramiro Meneses', (SELECT id FROM film WHERE title = 'La vendedora de rosas'));


-- Antes de crear un rol, verificamos si ya existe y, en caso afirmativo, lo eliminamos
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'peliculas_db_consumer') THEN
        CREATE ROLE peliculas_db_consumer;
    END IF;
END
$$;

-- Otorgar permisos en tablas
GRANT SELECT, INSERT ON TABLE public.film TO peliculas_db_consumer;
GRANT SELECT, INSERT ON TABLE public.actor TO peliculas_db_consumer;

-- Otorgar permisos en secuencias
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO peliculas_db_consumer;

-- Verificar si el usuario ya existe y si no, entonces crearlo
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'braestqui') THEN
        CREATE USER braestqui WITH PASSWORD 'test1234';
        -- Una vez creado el usuario, concedemos el rol
        GRANT peliculas_db_consumer TO braestqui;
    END IF;
END
$$;
-- Más comandos para configurar la base de datos...


COMMIT;
