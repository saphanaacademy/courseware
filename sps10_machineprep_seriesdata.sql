----------------------------
--                        --
--                        --
--  Series Data Overview  --
--                        --
--                        --
----------------------------


--------------------------------------
--
-- initial weather data
--
--------------------------------------

-- original / pristine data weather table creation to import data into

--DROP TABLE "SERIES_DATA"."WEATHER_ORIG";
CREATE COLUMN TABLE "SERIES_DATA"."WEATHER_ORIG" (
	 "station" NVARCHAR(5),
	 "station_name" NVARCHAR(20),
	 "lat" DECIMAL(18,6) CS_FIXED,
	 "lon" DECIMAL(18,6) CS_FIXED,
	 "valid(UTC)" NVARCHAR(20),
	 "tmpf" INTEGER CS_INT,
	 "dwpf" INTEGER CS_INT
);

-- import data into weather_orig table

-- create weather table (with timestamp instead of varchar)

DROP TABLE SERIES_DATA.WEATHER;
CREATE COLUMN TABLE SERIES_DATA.WEATHER (
	SENSOR VARCHAR(15), 
	TIMER TIMESTAMP, 
	TMP DECIMAL(10,2),
	DWP DECIMAL(10,2)
)
SERIES (
	SERIES KEY(SENSOR) 
	PERIOD FOR SERIES(TIMER)
	EQUIDISTANT INCREMENT BY INTERVAL 60 SECOND
	MINVALUE '2012-01-01 00:00:00'
	MAXVALUE '2015-12-31 23:59:00'
 );

-- add data to weather table
 
INSERT INTO SERIES_DATA.WEATHER (
	SELECT 
	 "station",
	 TO_TIMESTAMP ("valid(UTC)", 'YYYY-MM-DD HH24:MI'),
	 "tmpf",
	 "dwpf"
	FROM
	 SERIES_DATA.WEATHER_ORIG
);

SELECT * FROM SERIES_DATA.WEATHER
ORDER BY TIMER ASC;

SELECT W.GENERATED_PERIOD_START AS TS
FROM SERIES_GENERATE_TIMESTAMP (
 	SERIES TABLE "SERIES_DATA"."WEATHER"
) W;



--------------------------------------
--
-- weather table with NULLs creation
--
--------------------------------------

DROP TABLE SERIES_DATA.WEATHER_NULLS;
CREATE COLUMN TABLE SERIES_DATA.WEATHER_NULLS (
	SENSOR VARCHAR(15), 
	TIMER TIMESTAMP, 
	TMP DECIMAL(10,2),
	DWP DECIMAL(10,2)
)
SERIES (
	SERIES KEY(SENSOR) 
	PERIOD FOR SERIES(TIMER)
	EQUIDISTANT INCREMENT BY INTERVAL 60 SECOND
	MINVALUE '2012-01-01 00:00:00'
	MAXVALUE '2015-12-31 23:59:00'
 );


INSERT INTO SERIES_DATA.WEATHER_NULLS (
	SELECT  
	 "SENSOR",
	 "TIMER",
	 MAP(HOUR(TIMER), 8, NULL, 9, NULL, 10, NULL, 18, NULL, 19, NULL, 20, NULL, TMP),
	 MAP(HOUR(TIMER), 8, NULL, 9, NULL, 10, NULL, 18, NULL, 19, NULL, 20, NULL, DWP) 
	FROM SERIES_DATA.WEATHER
 	WHERE TIMER >= '2014-07-01 00:00:00'
	AND TIMER <= '2014-07-31 23:59:00'
	AND SENSOR = 'OTM'	
);

SELECT * FROM SERIES_DATA.WEATHER_NULLS;

DROP TABLE SERIES_DATA.WEATHER_NULLS_HOURLY;
CREATE COLUMN TABLE SERIES_DATA.WEATHER_NULLS_HOURLY (
	SENSOR VARCHAR(15), 
	TIMER TIMESTAMP, 
	TMP DECIMAL(10,2),
	DWP DECIMAL(10,2)
)
SERIES (
	SERIES KEY(SENSOR) 
	PERIOD FOR SERIES(TIMER)
	EQUIDISTANT INCREMENT BY INTERVAL 1 HOUR
	MINVALUE '2014-01-01 00:00:00'
	MAXVALUE '2014-12-31 23:00:00'
 );


INSERT INTO SERIES_DATA.WEATHER_NULLS_HOURLY (
	SELECT HOURLY.SENSOR, HOUR, AVG(TMP) AS AVG_TMP, AVG(DWP) AS AVG_DWP 
	FROM (
		SELECT W.SENSOR, SERIES_ROUND(TIMER, 'INTERVAL 1 HOUR', ROUND_DOWN) AS HOUR, TMP, DWP FROM SERIES_DATA.WEATHER_NULLS AS W
	) AS HOURLY 
	GROUP BY HOURLY.SENSOR, HOUR
);

SELECT * FROM SERIES_DATA.WEATHER_NULLS_HOURLY
ORDER BY TIMER;



--------------------------------------
--
-- create machine_readings table
--
--------------------------------------

DROP TABLE SERIES_DATA.MACHINE_READINGS;
CREATE COLUMN TABLE SERIES_DATA.MACHINE_READINGS (
	MACHINE VARCHAR(15), 
	TIMER TIMESTAMP, 
	READING DECIMAL(10,2)
)
SERIES (
	SERIES KEY(MACHINE) 
	PERIOD FOR SERIES(TIMER)
	EQUIDISTANT INCREMENT BY INTERVAL 60 SECOND
	MINVALUE '2012-01-01 00:00:00'
	MAXVALUE '2015-12-31 23:59:00'
 );
 
 INSERT INTO SERIES_DATA.MACHINE_READINGS (
 	select
	map("SENSOR", 'MCW', 1, 'OTM', 2) AS MACHINE,
	TIMER,
	ROUND(1000 + 100 * RAND() + RAND() * TMP, 1) AS READING
	 from "SERIES_DATA"."WEATHER"
	 union all
	select
	map("SENSOR", 'MCW', 4, 'OTM', 3) AS MACHINE,
	TIMER,
	ROUND(1000 + 80 * RAND() + RAND() * TMP, 1) AS READING
	 from "SERIES_DATA"."WEATHER"
);

SELECT * FROM SERIES_DATA.MACHINE_READINGS;



--------------------------------------
--
-- stock table creation
--
--------------------------------------


--SELECT MIN(DAY_TIME), MAX(DAY_TIME) FROM STOCK;
--MIN(DAY_TIME)
--Aug 24, 2009 9:30:00.0 AM
--MAX(DAY_TIME)
--Aug 23, 2010 4:00:00.0 PM

DROP TABLE "SERIES_DATA"."STOCK";
CREATE COLUMN TABLE "SERIES_DATA"."STOCK" (
	 "SYMBOL" NVARCHAR(4),
	 "DAY_TIME" TIMESTAMP,
	 "DAY" TINYINT CS_INT,
	 "OPEN" DECIMAL(7,2) CS_FIXED,
	 "HIGH" DECIMAL(7,2) CS_FIXED,
	 "LOW" DECIMAL(7,2) CS_FIXED,
	 "CLOSE" DECIMAL(7,2) CS_FIXED,
	 "VOLUME" INTEGER CS_INT
)
SERIES (
	SERIES KEY(SYMBOL) 
	PERIOD FOR SERIES(DAY_TIME)
	EQUIDISTANT INCREMENT BY INTERVAL 60 SECOND
	MINVALUE '2009-08-24 09:30:00'
	MAXVALUE '2010-08-23 16:00:00'
 );

INSERT INTO STOCK (
	select 
	"Symbol",
	TO_TIMESTAMP ("Timestamp", 'YYYY-MM-DD HH24:MI'),
	"Day",
	"Open",
	"High",
	"Low",
	"Close",
	"Volume"
	 from "SERIES_DATA"."STOCK_ORIG"
); 

SELECT * FROM STOCK;

----------------------
