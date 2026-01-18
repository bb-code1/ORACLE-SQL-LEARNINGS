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

-- Day 18: Materialized Views
-- Concept: Unlike standard views, Materialized Views precompute and store their results in a table.
-- They improve performance for expensive queries over large datasets, but must be refreshed 
-- when the underlying data changes.
--   REFRESH COMPLETE ON DEMAND: Refreshes the view on request by rebuilding the entire dataset.

CREATE MATERIALIZED VIEW mv_category_summary
REFRESH COMPLETE ON DEMAND
AS
SELECT category, COUNT(*) AS product_count, AVG(price) AS avg_price
FROM products
GROUP BY category;
