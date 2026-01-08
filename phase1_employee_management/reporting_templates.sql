-- Day 8: Consolidating Phase 1 Reports
-- Summarizing Employee Management analytics queries

SELECT department_id,
       COUNT(employee_id) AS total_employees,
       SUM(salary) AS payroll_spend,
       MAX(salary) - MIN(salary) AS salary_spread,
       LISTAGG(last_name, '; ') WITHIN GROUP (ORDER BY salary DESC) AS employees_ranked
FROM employees
GROUP BY department_id;
