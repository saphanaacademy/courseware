#####################
# ESH_SEARCH/CONFIG #
#####################

DROP USER ESH_DEMO CASCADE;
CREATE USER ESH_DEMO PASSWORD Password1;
DELETE FROM _SYS_REPO.PACKAGE_CATALOG WHERE RESPONSIBLE = 'ESH_DEMO';
INSERT INTO _SYS_REPO.PACKAGE_CATALOG(PACKAGE_ID, SRC_SYSTEM, SRC_TENANT, DESCRIPTION, RESPONSIBLE, IS_STRUCTURAL) 
VALUES ('ESH_DEMO','HDB','','ESH_DEMO','ESH_DEMO',0);
CALL GRANT_ACTIVATED_ROLE('sap.hana.xs.ide.roles::Developer','ESH_DEMO');
GRANT EXECUTE ON REPOSITORY_REST TO ESH_DEMO;
GRANT EXECUTE ON GRANT_ACTIVATED_ROLE TO ESH_DEMO;
GRANT EXECUTE ON REVOKE_ACTIVATED_ROLE TO ESH_DEMO;
GRANT REPO.READ, REPO.EDIT_NATIVE_OBJECTS, REPO.ACTIVATE_NATIVE_OBJECTS, REPO.MAINTAIN_NATIVE_PACKAGES ON "ESH_DEMO" TO ESH_DEMO;
GRANT REPO.EDIT_IMPORTED_OBJECTS, REPO.ACTIVATE_IMPORTED_OBJECTS, REPO.MAINTAIN_IMPORTED_PACKAGES ON "ESH_DEMO" TO ESH_DEMO;

-- special rights needed for ESH_DEMO
GRANT EXECUTE ON ESH_CONFIG TO ESH_DEMO;
GRANT EXECUTE ON ESH_SEARCH TO ESH_DEMO;
GRANT SELECT ON _SYS_RT.ESH_MODEL TO ESH_DEMO;
GRANT SELECT ON _SYS_RT.ESH_MODEL_PROPERTY TO ESH_DEMO;

CONNECT ESH_DEMO PASSWORD SHALive1;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA ESH_DEMO to _SYS_REPO WITH GRANT OPTION;

DROP TABLE DOCUMENT CASCADE;
CREATE COLUMN TABLE DOCUMENT
(ID INTEGER PRIMARY KEY, 
TITLE NVARCHAR(50),
CONTENT NVARCHAR(50));

INSERT INTO DOCUMENT VALUES (1, 'Football in the 19th Century','This is a document about football...');
INSERT INTO DOCUMENT VALUES (2, 'Football in Europe','This is a document about european football...');
INSERT INTO DOCUMENT VALUES (3, 'Europe in the 19th Century','This is a document about Europe...');

DROP TABLE DOCUMENT_AUTHORS CASCADE;
CREATE COLUMN TABLE DOCUMENT_AUTHORS
(ID INTEGER, 
NAME VARCHAR(20));

INSERT INTO DOCUMENT_AUTHORS VALUES (1, 'Franz');
INSERT INTO DOCUMENT_AUTHORS VALUES (2, 'Franz');
INSERT INTO DOCUMENT_AUTHORS VALUES (2, 'Erwin');
INSERT INTO DOCUMENT_AUTHORS VALUES (3, 'Erwin');

-- DROP FULLTEXT INDEX "FTI_DOCUMENT_TITLE";
CREATE FULLTEXT INDEX "FTI_DOCUMENT_TITLE" ON DOCUMENT(TITLE);
-- DROP FULLTEXT INDEX "FTI_DOCUMENT_CONTENT";
CREATE FULLTEXT INDEX "FTI_DOCUMENT_CONTENT" ON DOCUMENT(CONTENT);

-- DROP VIEW V_DOCUMENTS;
CREATE VIEW V_DOCUMENTS AS (
SELECT D.ID, D.TITLE, D.CONTENT, A.NAME as AUTHOR
FROM DOCUMENT AS D
LEFT JOIN
DOCUMENT_AUTHORS as A
ON D.ID = A.ID);

SELECT COUNT(DISTINCT ID) AS COUNT FROM V_DOCUMENTS WHERE CONTAINS(*,'football');
SELECT DISTINCT ID, TITLE, CONTENT FROM V_DOCUMENTS WHERE CONTAINS(*,'football');
SELECT AUTHOR, COUNT(DISTINCT ID) AS COUNT FROM V_DOCUMENTS WHERE CONTAINS(*,'football') GROUP BY AUTHOR;

-- change setting preferences so can view JSON (Windows\Preferences; SAP HANA\Runtime\Result; check "Enable zoom of LOB columns")

CALL ESH_CONFIG('[{
  "uri":    "~/$metadata/EntitySets(ESH_DEMO/V_DOCUMENTS)",
  "method": "DELETE",
  "content":  {  }
}]',?);

-- various esh_config options can be viewed from ;
-- http://help.sap.com/saphelp_hanaplatform/helpdata/en/9d/659b938f83495b9ca409a31cb2e400/content.htm?frameset=/en/0c/2af3198cdf4218bb477657f5f3ac33/frameset.htm&current_toc=/en/fd/c71ac6a10b43cd97ff1bee7a3c3aab/plain.htm&node_id=53

CALL ESH_CONFIG('[{
"uri":    "~/$metadata/EntitySets",
"method": "PUT",
"content":{ 
	"Fullname": "ESH_DEMO/V_DOCUMENTS",
	"EntityType": {
		"@Search.searchable": true,
		"@EnterpriseSearch.enabled": true,
		"Properties": [
			{"Name": "ID",      "@Search.defaultSearchElement": true,             "@EnterpriseSearch.key": true, "@EnterpriseSearch.presentationMode": [ "TITLE" ]},
			{"Name": "TITLE",   "@Search.defaultSearchElement": true,             "@EnterpriseSearch.highlighted.enabled": true, "@Search.ranking":	"HIGH","@EnterpriseSearch.presentationMode": [ "TITLE" ]},
			{"Name": "CONTENT", "@Search.defaultSearchElement": true,             "@EnterpriseSearch.snippets.enabled": true, "@Search.fuzzinessThreshold": 0.9, "@Search.ranking": "MEDIUM","@EnterpriseSearch.presentationMode": [ "DETAIL" ]},
			{"Name": "AUTHOR",  "@EnterpriseSearch.usageMode": [ "AUTO_FACET" ],  "@EnterpriseSearch.presentationMode": [ "SUMMARY" ]}
		]
	}
}
}]',?);

CALL ESH_SEARCH('[ "/$metadata"]', ?);
-- view in http://codebeautify.org/xmlviewer

-- show following in http://codebeautify.org/jsonviewer# viewer 

CALL ESH_SEARCH('[ 
"/$all?facets=all&$filter=Search.search(query=''football'')"
]', ?);

CALL ESH_SEARCH('[ 
"/$all?facets=all&$filter=Search.search(query=''football AND 19th+Century'')"
]', ?);

CALL ESH_SEARCH('[ 
"/$all?facets=all&$filter=AUTHOR eq ''Franz'' and Search.search(query=''football'')"
]', ?);

CALL ESH_SEARCH('[ 
"/$all?facets=all&$filter=Search.search(query=''football'')&$count=true"
]', ?);

-- following explains esh_search functions ;
-- http://help.sap.com/saphelp_hanaplatform/helpdata/en/54/fad3bd725141d083d2a48b674bdd86/content.htm?frameset=/en/b2/8d8279c30740fb9e08334ff7ad9cb7/frameset.htm&current_toc=/en/fd/c71ac6a10b43cd97ff1bee7a3c3aab/plain.htm&node_id=72

##############################################
# Can also view in OData (as normal in HANA) #
##############################################

-- .xsapp
{}

-- .xsaccess
{"exposed": true,"authentication": [{"method" : "Basic"}]}

-- services.xsodata
service namespace "ESH_DEMO"
{
 "ESH_DEMO"."V_DOCUMENTS" as "DOCUMENTS"
  key ("ID")
  create forbidden update forbidden delete forbidden;
}

-- OData Queries
http://hana:8000/ESH_DEMO/services.xsodata/
http://hana:8000/ESH_DEMO/services.xsodata/$metadata
http://hana:8000/ESH_DEMO/services.xsodata/DOCUMENTS?search=football&facets=all&$format=json
http://hana:8000/ESH_DEMO/services.xsodata/DOCUMENTS?search=19th+Century&facets=all&$format=json
