-- Day 6: SQL Aggregation
-- Concept: Aggregations calculate summary outputs over collections of rows.
-- Standard aggregates: SUM (sum total), AVG (arithmetic mean), MIN (minimum), MAX (maximum).

SELECT SUM(salary) AS total_payroll,
       ROUND(AVG(salary), 2) AS average_salary,
       MIN(salary) AS entry_salary,
       MAX(salary) AS ceiling_salary
FROM employees;

-- Day 6: COUNT Mechanics
-- Concept:
--   COUNT(*): Counts every row in the result set, including rows with NULL columns.
--   COUNT(column_name): Counts only rows where the specified column contains a non-NULL value.

SELECT COUNT(*) AS total_records,
       COUNT(email) AS records_with_email,
       COUNT(commission_pct) AS records_with_commission
FROM employees;
