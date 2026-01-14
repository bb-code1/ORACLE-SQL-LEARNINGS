-- Day 14: Set Operators (UNION vs UNION ALL)
-- Concept: Set operators combine the results of two queries.
--   UNION: Combines datasets, eliminates duplicates, and sorts the output.
--   UNION ALL: Combines datasets, preserves duplicates, and does *not* sort.
--   UNION ALL is significantly faster because it avoids expensive memory sort operations.

-- Create campaign tables for simulation
CREATE TABLE campaign_mail (email VARCHAR2(100));
CREATE TABLE campaign_sms (email VARCHAR2(100));
INSERT INTO campaign_mail VALUES ('alice@email.com');
INSERT INTO campaign_mail VALUES ('bob@email.com');
INSERT INTO campaign_sms VALUES ('bob@email.com');
INSERT INTO campaign_sms VALUES ('charlie@email.com');
COMMIT;

SELECT email FROM campaign_mail
UNION ALL
SELECT email FROM campaign_sms;

-- Day 14: Set Operators - INTERSECT and MINUS
-- Concept:
--   INTERSECT: Returns only rows that exist in *both* query datasets.
--   MINUS: Returns rows from the first query that do *not* exist in the second.

SELECT email FROM campaign_mail
INTERSECT
SELECT email FROM campaign_sms;

SELECT email FROM campaign_mail
MINUS
SELECT email FROM campaign_sms;

-- Day 14: Set Rules
-- Concept: 
--   1. Both queries must select the same number of columns.
--   2. Matching columns must have compatible data types.
--   3. Column names in the final result set are inherited from the *first* SELECT query.
--   4. ORDER BY must reside at the very end of the compound query, referencing columns from the first SELECT.

DROP TABLE campaign_mail;
DROP TABLE campaign_sms;
