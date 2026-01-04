-- Day 4: Oracle Built-in Character Functions
-- Concept: Single-row functions transform data elements row-by-row.
-- CONCEPT - SUBSTR vs INSTR:
--   SUBSTR(str, start, length): Extracts a substring.
--   INSTR(str, substring): Returns the 1-indexed position of a substring in a target string.

SELECT LOWER(first_name || '.' || last_name || '@company.com') AS formatted_email,
       UPPER(last_name) || ', ' || INITCAP(first_name) AS full_name,
       SUBSTR(phone_number, 1, 3) AS region_code
FROM employees;
