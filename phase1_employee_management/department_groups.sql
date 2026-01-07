-- Day 7: GROUP BY Clause
-- Concept: GROUP BY partitions dataset rows into categories.
-- Any column in the SELECT list that is not part of an aggregate function 
-- MUST be included in the GROUP BY clause.

SELECT department_id,
       COUNT(*) AS total_staff,
       ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id;

-- Day 7: HAVING Clause
-- Concept: HAVING filters aggregated groups *after* GROUP BY execution.
-- In contrast, WHERE filters raw rows *before* aggregation begins.
-- You cannot reference column alias identifiers inside HAVING or GROUP BY clauses.

SELECT department_id,
       COUNT(*) AS total_staff,
       ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 1;
