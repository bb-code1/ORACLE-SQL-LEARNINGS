-- Day 18: Database Views
-- Concept: Standard Views are virtual tables defined by queries.
-- They do not store data themselves; they execute their underlying query 
-- every time they are called.
-- They simplify complex queries and restrict user access to specific rows and columns.

CREATE OR REPLACE VIEW view_customer_revenue AS
SELECT c.customer_id, c.first_name, c.last_name,
       NVL(SUM(o.total_amount), 0) AS total_revenue,
       COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;
