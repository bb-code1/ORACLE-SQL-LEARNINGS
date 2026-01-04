-- Day 4: Oracle Built-in Character Functions
-- Concept: Single-row functions transform data elements row-by-row.
-- CONCEPT - SUBSTR vs INSTR:
--   SUBSTR(str, start, length): Extracts a substring.
--   INSTR(str, substring): Returns the 1-indexed position of a substring in a target string.

SELECT LOWER(first_name || '.' || last_name || '@company.com') AS formatted_email,
       UPPER(last_name) || ', ' || INITCAP(first_name) AS full_name,
       SUBSTR(phone_number, 1, 3) AS region_code
FROM employees;


-- Day 4: Regular Expressions for Data Validation
-- Concept: REGEXP_* functions use standard POSIX regular expression matches for deep pattern validation.
--   REGEXP_LIKE: Checks if a column matches a regex pattern (similar to LIKE, but regex-powered).
--   REGEXP_SUBSTR: Extracts a substring matching a regex pattern.

-- 1. Validate employee email structures
SELECT employee_id, email,
       CASE 
           WHEN REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') THEN 'VALID'
           ELSE 'INVALID'
       END AS email_status
FROM employees;

-- 2. Extract area code, office prefix, and line number from phone_number (e.g. "515.123.4567")
SELECT phone_number,
       REGEXP_SUBSTR(phone_number, '[0-9]+', 1, 1) AS area_code,
       REGEXP_SUBSTR(phone_number, '[0-9]+', 1, 2) AS office_prefix,
       REGEXP_SUBSTR(phone_number, '[0-9]+', 1, 3) AS line_number
FROM employees;
