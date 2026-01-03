-- Day 3: SELECT and WHERE Filtering
-- Concept: The WHERE clause filters row datasets before projections (SELECT columns) are resolved.
-- CONCEPT - BETWEEN:
--   BETWEEN is inclusive. It checks if a value falls inside a low/high range, equivalent to (val >= low AND val <= high).

SELECT employee_id, first_name, last_name, salary 
FROM employees 
WHERE salary BETWEEN 5000 AND 15000;
