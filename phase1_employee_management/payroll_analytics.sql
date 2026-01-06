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

-- Day 6: Aggregate Null Handling
-- Concept: Aggregate functions (except COUNT(*)) ignore NULLs.
-- This changes average outcomes depending on whether nulls are transformed to 0 first.
-- AVG(commission_pct) calculates sum(commission_pct) / count(commission_pct).
-- AVG(NVL(commission_pct, 0)) calculates sum(commission_pct) / count(*).

SELECT ROUND(AVG(commission_pct), 4) AS average_commission_active_earners,
       ROUND(AVG(NVL(commission_pct, 0)), 4) AS average_commission_all_employees
FROM employees;
