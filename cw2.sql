-- Zadanie 3
CREATE EXTENSION postgis;

-- Zadanie 4:
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY,
    name VARCHAR(100)
);

CREATE TABLE roads (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY,
    name VARCHAR(100)
);

CREATE TABLE poi (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY,
    name VARCHAR(100)
);

-- Zadanie 5: Wstawianie danych
INSERT INTO poi (id, geometry, name) VALUES 
(1, ST_GeomFromText('POINT(1 3.5)'), 'G'),
(2, ST_GeomFromText('POINT(5.5 1.5)'), 'H'),
(3, ST_GeomFromText('POINT(9.5 6)'), 'I'),
(4, ST_GeomFromText('POINT(6.5 6)'), 'J'),
(5, ST_GeomFromText('POINT(6 9.5)'), 'K');

INSERT INTO roads (id, geometry, name) VALUES 
(1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'), 'RoadX'),
(2, ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'), 'RoadY');

INSERT INTO buildings (id, geometry, name) VALUES 
(1, ST_GeomFromText('POLYGON((8 4, 8 1.5, 10.5 1.5, 10.5 4, 8 4))'), 'BuildingA'),
(2, ST_GeomFromText('POLYGON((4 7, 4 5, 6 5, 6 7, 4 7))'), 'BuildingB'),
(3, ST_GeomFromText('POLYGON((3 8, 3 6, 5 6, 5 8, 3 8))'), 'BuildingC'),
(4, ST_GeomFromText('POLYGON((9 9, 9 8, 10 8, 10 9, 9 9))'), 'BuildingD'),
(5, ST_GeomFromText('POLYGON((1 2, 1 1, 2 1, 2 2, 1 2))'), 'BuildingF');

-- Zadanie 6:

-- a:
SELECT 
    SUM(ST_Length(r.geometry)) AS total_length
FROM 
    roads r;

-- b:
SELECT 
    ST_AsText(b.geometry) AS wkt, 
    ST_Area(b.geometry) AS area, 
    ST_Perimeter(b.geometry) AS perimeter,
    ST_AsText(ST_Boundary(b.geometry)) AS boundary
FROM 
    buildings b
WHERE 
    b.name = 'BuildingA';

-- c:
SELECT 
    b.name, 
    ST_Area(b.geometry) AS area,
    ST_AsText(b.geometry) AS coordinates
FROM 
    buildings b
ORDER BY 
    b.name;

-- d:
SELECT 
    b.name, 
    ST_Perimeter(b.geometry) AS perimeter,
    ST_AsText(b.geometry) AS coordinates
FROM 
    buildings b
ORDER BY 
    ST_Area(b.geometry) DESC
LIMIT 2;

-- e:
SELECT 
    ST_Distance(b.geometry, p.geometry) AS distance,
    ST_AsText(b.geometry) AS building_coordinates,
    ST_AsText(p.geometry) AS poi_coordinates
FROM 
    buildings b 
CROSS JOIN 
    poi p
WHERE 
    b.name = 'BuildingC' AND p.name = 'K';

-- f:
SELECT 
    ST_Area(ST_Difference(bc.geometry, ST_Buffer(bb.geometry, 0.5))) AS area,
    ST_AsText(bc.geometry) AS buildingC_coordinates,
    ST_AsText(bb.geometry) AS buildingB_coordinates
FROM 
    buildings bc, buildings bb
WHERE 
    bc.name = 'BuildingC' AND bb.name = 'BuildingB';

-- g: 
SELECT 
    b.*, 
    ST_AsText(b.geometry) AS building_coordinates
FROM 
    buildings b
JOIN 
    roads r ON r.name = 'RoadX'
WHERE 
    ST_Y(ST_Centroid(b.geometry)) > ST_Y(ST_Centroid(r.geometry));

-- h:
SELECT 
    ST_Area(ST_SymDifference(b.geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))) AS area,
    ST_AsText(b.geometry) AS buildingC_coordinates
FROM 
    buildings b
WHERE 
    b.name = 'BuildingC';
