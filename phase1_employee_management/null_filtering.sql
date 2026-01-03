-- Day 3: Three-valued Logic and LIKE queries
-- Concept: Oracle uses three-valued logic (TRUE, FALSE, UNKNOWN).
-- A comparison containing NULL evaluations yields UNKNOWN.
-- CONCEPT - IS NULL:
--   You cannot check NULLs using equal markers (salary = NULL) because NULL signifies 
--   the absence of value. You must evaluate using IS NULL / IS NOT NULL.

SELECT first_name, last_name, salary, commission_pct 
FROM employees 
WHERE commission_pct IS NULL;

-- Wildcards: '_' matches exactly one character, '%' matches zero or more characters.
SELECT first_name, last_name, job_id 
FROM employees 
WHERE job_id LIKE 'SA_%';
