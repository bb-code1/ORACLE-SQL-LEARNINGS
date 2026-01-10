-- Day 10: Self-Joins
-- Concept: A self-join connects a table to itself.
-- You must assign unique table aliases (e.g. e1 for employee, e2 for manager) 
-- to prevent namespace conflicts.

SELECT e.first_name AS employee, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- Day 10: Cross Joins
-- Concept: CROSS JOIN generates a Cartesian product, matching every row of the 
-- first table with every row of the second.
-- Useful for generating combinatorial options (like product options). 
-- Avoid accidentally executing CROSS JOINs on large tables as it will cause severe performance degradation.

SELECT p1.product_name AS product_a, p2.product_name AS product_b
FROM products p1
CROSS JOIN products p2
WHERE p1.product_id < p2.product_id;
