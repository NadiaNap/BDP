CREATE EXTENSION postgis;
CREATE TABLE obiekty (
    id SERIAL PRIMARY KEY,
    nazwa TEXT,
    geometria GEOMETRY
);

INSERT INTO obiekty (nazwa, geometria) VALUES
('obiekt1', ST_Collect(
				ARRAY[(ST_GeomFromText('LINESTRING(0 1, 1 1)')),
        			  (ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)'))),
        			  (ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)'))),
        			  (ST_GeomFromText('LINESTRING(5 1, 6 1)'))])),
('obiekt2', ST_Collect(
				ARRAY[
					ST_GeomFromText('LINESTRING(10 6, 14 6)'),
					ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(14 6, 16 4, 14 2)')),
					ST_CurveToLine(ST_GeomFromText('CIRCULARSTRING(14 2, 12 0, 10 2)')),
					ST_GeomFromText('LINESTRING(10 2, 10 6)'),
					ST_Buffer(ST_POINT(12, 2), 1)
				])),
('obiekt3', 'Polygon((7 15,10 17, 12 13, 7 15))'),
('obiekt4', 'LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)'),
('obiekt5', ST_Collect(
			'POINT(30 30 59)',
			'POINT(38 32 234)')),
('obiekt6', ST_Collect(
			'LINESTRING(1 1, 3 2)',
			'POINT(4 2)'));
			
--zad. 2.			
SELECT ST_Area(ST_Buffer(ST_ShortestLine(o1.geometria, o2.geometria), 5)) AS pole_bufora
FROM obiekty o1, obiekty o2
WHERE o1.nazwa = 'obiekt3' AND o2.nazwa = 'obiekt4';

--zad. 3.
UPDATE obiekty
SET geometria = ST_MakePolygon(ST_AddPoint(geometria, 'POINT(20 20)'))
WHERE "nazwa" = 'obiekt4';

--zad. 4.
INSERT INTO obiekty("nazwa", geometria)
VALUES (
    'obiekt7',
    ST_Collect(
        (SELECT geometria FROM obiekty WHERE "nazwa" = 'obiekt3'),
        (SELECT geometria FROM obiekty WHERE "nazwa" = 'obiekt4')
    )
);

--zad. 5.
SELECT SUM(ST_Area(ST_Buffer(geometria, 5)))
FROM obiekty
WHERE NOT ST_HasArc(geometria);
