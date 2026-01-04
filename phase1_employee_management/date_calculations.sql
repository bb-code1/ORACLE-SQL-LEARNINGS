-- Day 4: Oracle Date Functions and Arithmetic
-- Concept: Oracle represents dates internally as binary structures storing century, year, month, 
-- day, hour, minute, second.
-- CONCEPT - ADD_MONTHS vs MONTHS_BETWEEN:
--   ADD_MONTHS: Handles calendar shift calculations, resolving leap years and varying month days.
--   MONTHS_BETWEEN: Calculates fractional months between two calendar dates.

SELECT first_name, last_name, hire_date,
       TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date)) AS months_completed,
       ADD_MONTHS(hire_date, 3) AS probation_expiration_date
FROM employees;

-- Day 4: Explicit Conversions (TO_DATE, TO_CHAR)
-- Concept: Avoid implicit data type conversion. Explicit conversion patterns secure stability.
--   TO_CHAR(date, format): Extracts custom formatting tags like 'YYYY-MM-DD' or 'DD-MON-YYYY HH24:MI:SS'.
--   TRUNC(date): Strips off the time component, resetting to midnight (00:00:00).

SELECT last_name,
       TO_CHAR(hire_date, 'FMDD "of" Month, YYYY') AS structured_hire_date,
       TRUNC(hire_date) AS midnight_truncated_date
FROM employees;
