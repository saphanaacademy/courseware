// Cleanse
US Add Directories

Login to http://hana:8000/sap/hana/ide/ as LIVE4

DROP TABLE "LIVE4"."T001W_OTHER" CASCADE;
CREATE COLUMN TABLE "LIVE4"."T001W_OTHER" (
"MANDT" NVARCHAR(3) DEFAULT '000' NOT NULL ,
"WERKS" NVARCHAR(4) DEFAULT '' NOT NULL , 
"NAME1" NVARCHAR(30) DEFAULT '' NOT NULL , 
"LIFNR" NVARCHAR(10) DEFAULT '' NOT NULL , 
"STRAS" NVARCHAR(30) DEFAULT '' NOT NULL , 
"PSTLZ" NVARCHAR(10) DEFAULT '' NOT NULL , 
"ORT01" NVARCHAR(25) DEFAULT '' NOT NULL , 
"LAND1" NVARCHAR(3) DEFAULT '' NOT NULL , 
"REGIO" NVARCHAR(3) DEFAULT '' NOT NULL , 
PRIMARY KEY ("MANDT", "WERKS")) UNLOAD PRIORITY 5  AUTO MERGE ;
COMMENT ON TABLE "LIVE4"."T001W_OTHER" is 'Plants/Branches';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."MANDT" is 'Client';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."WERKS" is 'Plant';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."NAME1" is 'Name';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."LIFNR" is 'Vendor number of plant';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."STRAS" is 'Street and House Number';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."PSTLZ" is 'Postal Code';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."ORT01" is 'City';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."LAND1" is 'Country Key';
COMMENT ON COLUMN "LIVE4"."T001W_OTHER"."REGIO" is 'Region (State, Province, County)';

delete from "LIVE4"."T001W_OTHER";
insert into "LIVE4"."T001W_OTHER"
values ('001','0099','Drugs R Us New York North','555','Madison Ave','10019','New York','US','NY');
insert into "LIVE4"."T001W_OTHER"
values ('001','0098','Dregs R Us New York North','555','Madisen Av.','10022','NYC','US','NY');
insert into "LIVE4"."T001W_OTHER"
values ('001','0097','Drugs Rus New York South','95','Morton St.','10014','Manhattan','US','NY');
insert into "LIVE4"."T001W_OTHER"
values ('001','0096','Drugs New York South','95','Morten Stre','10014','','USA','');

In WbDW Editor, New Flowgraph called "Cleanse"
Edit Defaults/Content Types
Make all content types as ADDRESSLINE, apart from LAND1 = Country
Customize Manually

Address Basic/Country 
Address Basic/Region
Address Basic/Postcode
Address Extended/Subregion
Address Extended/Streetname (Expanded)

Order Columns as ;

NAME1
LIFNR
STD_ADDR_PRIM_NAME_FULL
STD_ADDR_REGION2
STD_ADDR_REGION_FULL
STD_ADDR_POSTCODE_FULL
STD_ADDR_COUNTRY_NAME

Delete other columns ... 

TARGET is T001W_CLEANSED

select * from "SYS"."M_TASKS";
delete from "LIVE4"."T001W_CLEANSED";
start task "LIVE4"."live4::Cleanse";
select * from "LIVE4"."T001W_CLEANSED";

Login to http://hana:8000/sap/hana/ide/catalog/ as LIVE4 to see results

New Flowgraph called "Match"

T001W_CLEANSED as a source
Do a Firm, Address Match Policy

T001W_DUPS as a target

delete from "LIVE4"."T001W_DUPS";
start task "LIVE4"."live4::Match";
select * from "LIVE4"."T001W_DUPS";
