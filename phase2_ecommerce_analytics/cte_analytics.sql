-- Day 13: Common Table Expressions (WITH clause)
-- Concept: CTEs define temporary result sets that can be referenced multiple times 
-- within a single SELECT, INSERT, UPDATE, or DELETE query.
-- They improve code readability by replacing complex nested inline views.

WITH customer_spending AS (
    SELECT customer_id, SUM(total_amount) AS total_spent, COUNT(*) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT c.first_name, c.last_name, cs.total_spent
FROM customers c
JOIN customer_spending cs ON c.customer_id = cs.customer_id;
