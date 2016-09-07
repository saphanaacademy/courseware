#################
## TEXT MINING ##
#################

-- as SYSTEM user
GRANT SELECT, INDEX, UPDATE ON TEXTMINING.TEXTMINING_AWARDS to DEVUSER;

-- back as DEVUSER user
SELECT AWARD_TITLE, AWARD_ABSTRACT, PROGRAM
FROM TEXTMINING.TEXTMINING_AWARDS;

SELECT PROGRAM, COUNT(*) as COUNT
FROM TEXTMINING.TEXTMINING_AWARDS
GROUP BY PROGRAM
ORDER BY COUNT(*) DESC;

SELECT AWARD_TITLE, AWARD_ABSTRACT, PROGRAM
FROM TEXTMINING.TEXTMINING_AWARDS
WHERE FEDERAL_AWARD_ID_NUMBER = 1348558;

DROP FULLTEXT INDEX TEXTMINING_INDEX;
CREATE FULLTEXT INDEX TEXTMINING_INDEX
ON TEXTMINING.TEXTMINING_AWARDS (AWARD_ABSTRACT)
FAST PREPROCESS OFF
SEARCH ONLY OFF
TEXT ANALYSIS ON
TEXT MINING ON;

MERGE DELTA OF TEXTMINING_AWARDS;

SELECT T.FEDERAL_AWARD_ID_NUMBER, T.AWARD_TITLE, T.AWARD_ABSTRACT, T.TOTAL_TERM_COUNT, T.SCORE
FROM TM_GET_RELATED_DOCUMENTS (
DOCUMENT IN FULLTEXT INDEX WHERE FEDERAL_AWARD_ID_NUMBER = 1348558
SEARCH "AWARD_ABSTRACT" FROM TEXTMINING.TEXTMINING_AWARDS
RETURN
TOP 10
FEDERAL_AWARD_ID_NUMBER, AWARD_TITLE, AWARD_ABSTRACT
) AS T;

SELECT RANK, TOTAL_TERM_COUNT, SCORE, AWARD_TITLE, AWARD_ABSTRACT, FEDERAL_AWARD_ID_NUMBER
FROM TM_GET_RELEVANT_DOCUMENTS (
TERM 'psychology'
SEARCH "AWARD_ABSTRACT" FROM TEXTMINING.TEXTMINING_AWARDS
RETURN
TOP 10 
FEDERAL_AWARD_ID_NUMBER, AWARD_TITLE, AWARD_ABSTRACT
) AS T;

SELECT T.TERM, T.NORMALIZED_TERM, T.TERM_TYPE, T.TERM_FREQUENCY,
T.DOCUMENT_FREQUENCY, T.SCORE
FROM TM_GET_RELATED_TERMS (
TERM 'privacy'
SEARCH "AWARD_ABSTRACT" FROM TEXTMINING.TEXTMINING_AWARDS
RETURN
TOP 10 ) AS T;

SELECT T.TERM, T.NORMALIZED_TERM, T.TERM_TYPE, T.TERM_FREQUENCY,
T.DOCUMENT_FREQUENCY, T.SCORE
FROM TM_GET_RELEVANT_TERMS (
DOCUMENT IN FULLTEXT INDEX WHERE FEDERAL_AWARD_ID_NUMBER = 1348558
SEARCH "AWARD_ABSTRACT" FROM TEXTMINING.TEXTMINING_AWARDS
RETURN
TOP 10 ) AS T;

SELECT T.TERM, T.NORMALIZED_TERM, T.TERM_TYPE, T.TERM_FREQUENCY,
T.DOCUMENT_FREQUENCY, T.SCORE
FROM TM_GET_SUGGESTED_TERMS (
TERM 'a'
SEARCH "AWARD_ABSTRACT" FROM TEXTMINING.TEXTMINING_AWARDS
RETURN
TOP 10 ) AS T;

SELECT UPPER(PROGRAM) AS PROGRAM , COUNT(*) AS COUNT 
FROM "TEXTMINING"."TEXTMINING_AWARDS"
GROUP BY PROGRAM
ORDER BY 2 DESC;

SELECT AWARD_TITLE, AWARD_ABSTRACT, PROGRAM
FROM TEXTMINING.TEXTMINING_AWARDS
WHERE FEDERAL_AWARD_ID_NUMBER = 1348558;

SELECT CATEGORY_COLUMN, RANK, CATEGORY_VALUE, NEIGHBOR_COUNT, SCORE
FROM TM_CATEGORIZE_KNN (
DOCUMENT IN FULLTEXT INDEX WHERE FEDERAL_AWARD_ID_NUMBER = 1348558
SEARCH NEAREST NEIGHBORS 20 "AWARD_ABSTRACT" FROM TEXTMINING.TEXTMINING_AWARDS
RETURN
TOP 10
PROGRAM FROM TEXTMINING.TEXTMINING_AWARDS
);
