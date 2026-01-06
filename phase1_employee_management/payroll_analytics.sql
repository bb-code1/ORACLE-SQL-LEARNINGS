-- Day 6: SQL Aggregation
-- Concept: Aggregations calculate summary outputs over collections of rows.
-- Standard aggregates: SUM (sum total), AVG (arithmetic mean), MIN (minimum), MAX (maximum).

SELECT SUM(salary) AS total_payroll,
       ROUND(AVG(salary), 2) AS average_salary,
       MIN(salary) AS entry_salary,
       MAX(salary) AS ceiling_salary
FROM employees;
