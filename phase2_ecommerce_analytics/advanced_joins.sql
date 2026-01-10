-- Day 10: Self-Joins
-- Concept: A self-join connects a table to itself.
-- You must assign unique table aliases (e.g. e1 for employee, e2 for manager) 
-- to prevent namespace conflicts.

SELECT e.first_name AS employee, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
