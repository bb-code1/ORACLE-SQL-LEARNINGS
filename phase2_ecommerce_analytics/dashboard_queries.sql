-- Day 17: Consolidating Phase 2 E-Commerce analytics reports
-- Generates aggregate customer intelligence matrices

WITH customer_orders AS (
    SELECT customer_id, 
           COUNT(order_id) AS orders_count,
           SUM(total_amount) AS total_spending,
           DENSE_RANK() OVER (ORDER BY SUM(total_amount) DESC NULLS LAST) AS spending_rank
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, 
       NVL(co.orders_count, 0) AS total_orders,
       NVL(co.total_spending, 0) AS lifetime_value,
       co.spending_rank
FROM customers c
LEFT JOIN customer_orders co ON c.customer_id = co.customer_id;
