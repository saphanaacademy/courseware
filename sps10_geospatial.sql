
----------------------------
--                        --
--                        --
--  Geo Spatial Overview  --
--                        --
--                        --
----------------------------


-------------------------------------------------------------
--
--  ST_Transform method
--
-------------------------------------------------------------


-------------------------------------------------------------
--
--  doing some distance calculations using different SRID's
--
-------------------------------------------------------------

WITH A AS
(
	SELECT 
	 -- Dublin office in 3 different SRS
	 NEW ST_Point('POINT(-121.8899999 37.7067592)') AS DU,
	 NEW ST_Point('POINT(-121.8899999 37.7067592)', 1000004326) AS DU_1000004326,
	 NEW ST_Point('POINT(-121.8899999 37.7067592)', 4326) AS DU_4326,	  
	 -- Vancouver office in 3 different SRS	 
	 NEW ST_Point('POINT(-123.1208974 49.2766576)') AS VN,
	 NEW ST_Point('POINT(-123.1208974 49.2766576)', 1000004326) AS VN_1000004326,	 
	 NEW ST_Point('POINT(-123.1208974 49.2766576)', 4326) AS VN_4326
	FROM DUMMY
)
SELECT
 DU.ST_AsWKT(),
 VN.ST_AsWKT(),
 VN.ST_DISTANCE(DU, 'kilometer') AS DIST_0,
 VN_1000004326.ST_DISTANCE(DU_1000004326, 'kilometer') AS DIST_1000004326,
 VN_4326.ST_DISTANCE(DU_4326, 'kilometer') AS DIST_4326
FROM A;


----------------------------------
--
--  performance of different SRS
--
----------------------------------


-- calculations using points within a polygon

-- st_within equivalent to st_contains
-- in both all geometries must be completely within the interior & not intersect the boundary
-- neither can be used in round earth calcs

-- st_within

-- srid 0
SELECT 
SUM(POPULATION_TOTAL) AS POP,
COUNT(*) AS POINTS
FROM CENSUS_GEO
WHERE LENGTH(CENSUS_GEO_ID) = 11
AND LONLAT_POINT_0.ST_Within(NEW ST_Polygon('Polygon(( 
            -138.9343338012695 40.47433077320648,
            -138.9343338012695 32.89135906381192,
            -100.5920486450195 32.89135906381192,
            -100.5920486450195 40.47433077320648,
            -138.9343338012695 40.47433077320648
       ))',0)) = 1;

-- srid 1000004326       
SELECT 
SUM(POPULATION_TOTAL) AS POP,
COUNT(*) AS POINTS
FROM CENSUS_GEO
WHERE LENGTH(CENSUS_GEO_ID) = 11
AND LONLAT_POINT_1000004326.ST_Within(NEW ST_Polygon('Polygon(( 
            -138.9343338012695 40.47433077320648,
            -138.9343338012695 32.89135906381192,
            -100.5920486450195 32.89135906381192,
            -100.5920486450195 40.47433077320648,
            -138.9343338012695 40.47433077320648
       ))',1000004326)) = 1; 
       
       
-- st_contains              

-- srid 1000004326           
SELECT 
SUM(POPULATION_TOTAL) AS POP,
COUNT(*) AS POINTS
FROM CENSUS_GEO
WHERE LENGTH(CENSUS_GEO_ID) = 11
AND NEW ST_Polygon('Polygon(( 
            -138.9343338012695 40.47433077320648,
            -138.9343338012695 32.89135906381192,
            -100.5920486450195 32.89135906381192,
            -100.5920486450195 40.47433077320648,
            -138.9343338012695 40.47433077320648
       ))',1000004326).ST_Contains(LONLAT_POINT_1000004326) = 1;


-- st_covered by          
                  
--srid 4326       
SELECT 
SUM(POPULATION_TOTAL) AS POP,
COUNT(*) AS POINTS
FROM CENSUS_GEO
WHERE LENGTH(CENSUS_GEO_ID) = 11
AND LONLAT_POINT_4326.ST_CoveredBy(NEW ST_Polygon('Polygon(( 
            -138.9343338012695 40.47433077320648,
            -138.9343338012695 32.89135906381192,
            -100.5920486450195 32.89135906381192,
            -100.5920486450195 40.47433077320648,
            -138.9343338012695 40.47433077320648
       ))',4326)) = 1;
       


-------------------------------------
--
--  using the ST_Transform() method
--
-------------------------------------

-- constructing a transform & using in a distance calc

SELECT TOP 10 
"ROWID", 
 LONLAT_POINT_1000004326.ST_SRID() AS SRID, 
 LONLAT_POINT_1000004326.ST_Transform(4326).ST_SRID() AS TRANS_SRID
 ,LONLAT_POINT_0.ST_Transform(4326)
 --,LONLAT_POINT_1000004326.ST_Transform(4326).ST_DISTANCE(LONLAT_POINT_4326, 'kilometer')
FROM CENSUS_GEO
ORDER BY "ROWID" ASC; 


SELECT TRANSFORM_DEFINITION, SRS_ID FROM ST_SPATIAL_REFERENCE_SYSTEMS; 




--------------------------------
--
--  multi-dimensional geo data
--
--------------------------------

-- create table and add data, some multi-dimensional, to table

DROP TABLE GEOMULTIDIM;
CREATE COLUMN TABLE GEOMULTIDIM (
	ID INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
 	GEO ST_GEOMETRY
 );  

INSERT INTO GEOMULTIDIM VALUES(NEW ST_POINT('POINT (5.0 6.0)'));
INSERT INTO GEOMULTIDIM VALUES(NEW ST_POINT('POINT Z(5.0 6.0 8.0)'));
INSERT INTO GEOMULTIDIM VALUES(NEW ST_POINT('POINT M(5.0 6.0 1400)'));
INSERT INTO GEOMULTIDIM VALUES(NEW ST_POINT('POINT ZM(2 3 4 1000)'));
INSERT INTO GEOMULTIDIM VALUES(NEW ST_POINT());
INSERT INTO GEOMULTIDIM VALUES(NEW ST_LINESTRING('LINESTRING ZM(3 3 4 2500, 5 4 2 2600, 6 3 3 2200)'));
INSERT INTO GEOMULTIDIM VALUES(NEW ST_LINESTRING());
INSERT INTO GEOMULTIDIM VALUES(NEW ST_POLYGON('POLYGON ZM((6 7 4 1800, 10 3 4 1850, 10 10 4 1900, 6 7 4 1800))'));
INSERT INTO GEOMULTIDIM VALUES(NEW ST_POLYGON());

-- Other Supported Spatial Types for Multi-Dimensional Data
	-- ST_MultiPoint
	-- ST_MultiLineString
	-- ST_MultiPolygon
	-- ST_GeometryCollection

-- use some multi-dimensional methods to retrieve values

SELECT 
 ID, 
 GEO.ST_AsWKT(),
 --GEO.ST_Z(), 
 GEO.ST_ZMAX(), 
 GEO.ST_ZMIN(),
 GEO.ST_M(), 
 GEO.ST_MMAX(), 
 GEO.ST_MMIN()
FROM GEOMULTIDIM; 

-- return only 3d or measured points

SELECT 
 ID, 
 GEO.ST_AsWKT(),
 --GEO.ST_Z(),
 CASE GEO.ST_Is3D()
 	WHEN 1 THEN GEO.ST_Z()
 	END,
 CASE GEO.ST_IsMeasured()
 	WHEN 1 THEN GEO.ST_M()
 	END
 FROM GEOMULTIDIM
 WHERE GEO.ST_GeometryType() = 'ST_Point' 
 AND (GEO.ST_Is3D() = 1 OR GEO.ST_IsMeasured() = 1);
