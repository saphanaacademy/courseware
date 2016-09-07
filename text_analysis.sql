###################################
# GRAMMATICAL_ROLE_ANALYSIS
###################################

-- simple example for entity extraction
DROP TABLE A_TA_GRA_EXAMPLE CASCADE;
CREATE COLUMN TABLE A_TA_GRA_EXAMPLE
(
ID INTEGER PRIMARY KEY, 
STRING nvarchar(200)
)
;

-- insert some data
INSERT INTO A_TA_GRA_EXAMPLE 
VALUES (1, 'Oracle was rumored to buy marketing-software maker Responsys Inc. for $1.5 billion.');

-- create index for text analysis
DROP FULLTEXT INDEX "MYINDEX_GRA";
CREATE FULLTEXT INDEX myindex_gra ON A_TA_GRA_EXAMPLE ("STRING")
CONFIGURATION 'EXTRACTION_CORE'
-- CONFIGURATION 'GRAMMATICAL_ROLE_ANALYSIS'
TEXT ANALYSIS ON;

-- results
select "ID", "TA_COUNTER", "TA_TYPE", "TA_TOKEN", "TA_RULE", "TA_PARENT", "TA_COUNTER"
from "$TA_MYINDEX_GRA"
order by 1,2;

###################################
# VOC IMPROVEMENTS
###################################

-- simple example for entity extraction
DROP TABLE A_TA_VOC_SPS11_EXAMPLE CASCADE;
CREATE COLUMN TABLE A_TA_VOC_SPS11_EXAMPLE
(
ID INTEGER PRIMARY KEY, 
STRING nvarchar(200)
)
;

-- insert some data
INSERT INTO A_TA_VOC_SPS11_EXAMPLE VALUES (1, 'I love my new phone.');
INSERT INTO A_TA_VOC_SPS11_EXAMPLE VALUES (2, 'He did not like the book.');

-- create index for text analysis
CREATE FULLTEXT INDEX myindex_voc_sps11 ON A_TA_VOC_SPS11_EXAMPLE ("STRING")
CONFIGURATION 'EXTRACTION_CORE_VOICEOFCUSTOMER'
TEXT ANALYSIS ON;

-- results
select 
"ID",
"TA_COUNTER",
"TA_TOKEN",
"TA_TYPE",
"TA_RULE"
 from "$TA_MYINDEX_VOC_SPS11";

###################################
# LANGUAGE COLUMN - SAP LANGUAGE CODES
###################################

-- to see language types
-- select * from SYS.M_TEXT_ANALYSIS_LANGUAGES

DROP TABLE A_TA_LC_NEW_EXAMPLE CASCADE;
CREATE COLUMN TABLE A_TA_LC_NEW_EXAMPLE
(
ID INTEGER PRIMARY KEY, 
STRING nvarchar(200),
TXTLANG nvarchar(1)
)
;

INSERT INTO A_TA_LC_NEW_EXAMPLE VALUES (1, 'Bob really likes Manchester United.','E');
INSERT INTO A_TA_LC_NEW_EXAMPLE VALUES (2, 'Ich hasse den FC Bayern München !!','D');
INSERT INTO A_TA_LC_NEW_EXAMPLE VALUES (3, 'ボブは東京を楽しんで','J');
INSERT INTO A_TA_LC_NEW_EXAMPLE VALUES (4, '밥은 서울을 즐긴다','3');
INSERT INTO A_TA_LC_NEW_EXAMPLE VALUES (5, '鲍勃喜欢上海','1');

CREATE FULLTEXT INDEX myindex_lc_new ON A_TA_LC_NEW_EXAMPLE ("STRING")
CONFIGURATION 'EXTRACTION_CORE_VOICEOFCUSTOMER'
LANGUAGE COLUMN TXTLANG
TEXT ANALYSIS ON;

SELECT * FROM "$TA_MYINDEX_LC_NEW" ORDER BY ID;

###################################
# IMPROVED STEMMING
###################################

DROP TABLE A_TA_STEM_SPS11_EXAMPLE CASCADE;

CREATE COLUMN TABLE A_TA_STEM_SPS11_EXAMPLE
(
ID INTEGER PRIMARY KEY, 
STRING nvarchar(200)
)
;

-- insert some data
INSERT INTO A_TA_STEM_SPS11_EXAMPLE VALUES 
(1, 'tom appreciated the behaviour of his motherinlaw.'); 

-- create index for text analysis
CREATE FULLTEXT INDEX myindex_stem_sps11 ON A_TA_STEM_SPS11_EXAMPLE ("STRING")
CONFIGURATION 'LINGANALYSIS_FULL'
TEXT ANALYSIS ON;

select "TA_TOKEN", "TA_NORMALIZED", "TA_STEM", "TA_TYPE"  from "$TA_MYINDEX_STEM_SPS11";

INSERT INTO A_TA_STEM_SPS11_EXAMPLE VALUES 
(2, 'Tom appreciated the behavior of his mother-in-law.'); 

