DROP REMOTE SOURCE SPARK CASCADE;
CREATE REMOTE SOURCE "SPARK" ADAPTER "sparksql"
CONFIGURATION 'port=7860;ssl_mode=disabled;server=52.3.82.2;'
WITH CREDENTIAL TYPE 'PASSWORD' USING 'user=hduser;password=hduser';
