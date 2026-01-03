-- Day 3: SELECT and WHERE Filtering
-- Concept: The WHERE clause filters row datasets before projections (SELECT columns) are resolved.
-- CONCEPT - BETWEEN:
--   BETWEEN is inclusive. It checks if a value falls inside a low/high range, equivalent to (val >= low AND val <= high).

SELECT employee_id, first_name, last_name, salary 
FROM employees 
WHERE salary BETWEEN 5000 AND 15000;

-- Day 3: Precedence Rules
-- Concept: Logical operators have strict precedence rules: NOT -> AND -> OR.
-- Without proper grouping parentheses, unintended evaluations occur.

SELECT employee_id, first_name, last_name, salary, department_id, job_id
FROM employees
WHERE (department_id = 2 OR department_id = 3)
  AND salary > 5000;
