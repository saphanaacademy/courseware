One student is "Local", One student is "Remote"
http://10.??.??.??:8000/sap/hana/ide/ - Local
http://10.??.??.??:8000/sap/hana/ide/ - Remote

"Remote" table to replicate :
CREATE COLUMN TABLE LIVE4.H2H_TABLE (
ID INTEGER PRIMARY KEY, txt VARCHAR(50));
INSERT INTO LIVE4.H2H_TABLE VALUES (1, 'Manchester United');
INSERT INTO LIVE4.H2H_TABLE VALUES (2, 'Real Madrid');
INSERT INTO LIVE4.H2H_TABLE VALUES (3, 'Paris St Germain');

- "Local" Installs DP Agent
May have to open Windows FireWall ports (9091/2)
Show AGENTS and ADAPTERS views in SYS schema AFTER creating

- In WbDW/Catalog, create a remote source to the "Remote" System

- Create a Virtual Table from the "Remote" System, and demo

- In WbDW/Editor, create a Rep Task
[BUG :: Refresh Browser, and Attach Current Token] 

- Show LIVE4 schema where RepTask objects will be created

- Execute Rep Task

- On "Local", show schema where new objects have been created

- On "Remote", show schema where new objects have been created

- "Remote" executes following in Catalog :
INSERT INTO LIVE4.H2H_TABLE VALUES (4, 'New York City FC');
Open H2H_TABLE to show new row

- "Local" executes SELECT on table to show results :
