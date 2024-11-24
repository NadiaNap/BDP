-- Zad. 1.
CREATE TEMP TABLE buildings_change_analysis AS
WITH new_buildings AS (
    SELECT 
        b2019.polygon_id AS new_building_id,
        NULL AS old_building_id,
        NULL AS old_geom,
        b2019.geom AS new_geom
    FROM t2019_kar_buildings b2019
    LEFT JOIN t2018_kar_buildings b2018 
        ON b2018.polygon_id = b2019.polygon_id
    WHERE b2018.polygon_id IS NULL
),
changed_buildings AS (
    SELECT 
        b2018.polygon_id AS old_building_id,
        b2019.polygon_id AS new_building_id,
        b2018.geom AS old_geom,
        b2019.geom AS new_geom
    FROM t2018_kar_buildings b2018
    JOIN t2019_kar_buildings b2019 
        ON b2018.polygon_id = b2019.polygon_id
    WHERE NOT ST_Equals(b2019.geom, b2018.geom) OR b2019.height <> b2018.height
)
SELECT * FROM new_buildings
UNION ALL
SELECT * FROM changed_buildings;

-- Zad. 2.
WITH poi_buffer AS (
    SELECT ST_Buffer(geom, 0.005) AS buffer_geom
    FROM buildings_change_analysis
),
new_poi AS (
    SELECT 
        NULL AS old_poi_id,
        p2019.poi_id AS new_poi_id,
        p2019.geom AS poi_geom,
        p2019.type AS poi_type
    FROM t2019_kar_poi_table p2019
    LEFT JOIN t2018_kar_poi_table p2018 
        ON p2018.poi_id = p2019.poi_id
    WHERE p2018.poi_id IS NULL
),
poi_count_by_type AS (
    SELECT 
        poi_type,
        COUNT(*) AS total_poi
    FROM new_poi np
    JOIN poi_buffer pb 
        ON ST_Intersects(np.poi_geom, pb.buffer_geom)
    GROUP BY poi_type
)
SELECT * 
FROM poi_count_by_type
WHERE total_poi > 0;

-- Zad. 3.
CREATE TABLE streets_reprojected AS
SELECT 
    *,
    ST_Transform(geom, 3068) AS geom_3068
FROM t2019_kar_streets;

-- Zad. 4.
CREATE TABLE input_coordinates AS
VALUES
    (1, ST_GeomFromText('POINT(8.36093 49.03174)', 4326)),
    (2, ST_GeomFromText('POINT(8.39876 49.00644)', 4326));

-- Zad. 5.
ALTER TABLE input_coordinates 
ALTER COLUMN geom TYPE GEOMETRY(POINT, 3068) USING ST_Transform(geom, 3068);

-- Zad. 6.
WITH buffered_points AS (
    SELECT ST_Buffer(ST_Union(geom), 0.002) AS buffer_geom
    FROM input_coordinates
),
intersecting_nodes AS (
    SELECT 
        n.* 
    FROM t2019_kar_street_node n
    JOIN buffered_points b 
        ON ST_Intersects(n.geom, b.buffer_geom)
)
SELECT * FROM intersecting_nodes;

-- Zad. 7.
WITH park_buffers AS (
    SELECT ST_Buffer(geom, 0.003) AS buffer_geom
    FROM t2019_kar_land_use_a
    WHERE type = 'Park (City/County)'
),
sport_stores AS (
    SELECT geom 
    FROM t2019_kar_poi_table
    WHERE type = 'Sporting Goods Store'
)
SELECT COUNT(*) AS sport_stores_in_parks
FROM park_buffers pb
JOIN sport_stores ss 
    ON ST_Intersects(pb.buffer_geom, ss.geom);

-- Zad. 8.
CREATE TABLE railway_water AS
SELECT 
    r.gid AS railway_gid,
    w.gid AS water_gid,
    ST_Intersection(r.geom, w.geom) AS crossing_geom
FROM t2019_kar_railways r
JOIN t2019_kar_water_lines w 
    ON ST_Intersects(r.geom, w.geom);
