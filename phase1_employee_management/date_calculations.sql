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
