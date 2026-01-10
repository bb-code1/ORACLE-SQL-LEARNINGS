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

-- Day 10: Join Mechanisms - Optimizer Decisions
-- Concept: The Oracle Optimizer chooses how to execute joins:
--   1. Nested Loops: Scans the inner table for each row in the outer table. 
--      Excellent for small datasets and quick first-row lookups.
--   2. Hash Join: Builds an in-memory hash table from the smaller dataset, 
--      then probes it using the larger dataset. Highly efficient for large datasets.
