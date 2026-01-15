-- Day 15: Analytic Functions - Ranks
-- Concept: Analytic functions compute aggregate values over partitions of rows 
-- without collapsing the result set (unlike GROUP BY).
--   ROW_NUMBER(): Assigns sequential, unique numbers starting from 1.
--   RANK(): Assigns ranks, skipping numbers if ties occur (e.g., 1, 2, 2, 4).
--   DENSE_RANK(): Assigns ranks, preserving contiguous sequences (e.g., 1, 2, 2, 3).

SELECT product_name, category, price,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rk,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS drk
FROM products;

-- Day 15: Analytic Functions - LAG and LEAD
-- Concept: Offset functions access other rows in the same result set 
-- without executing a self-join.
--   LAG(col, offset): Accesses rows *prior* to the current row.
--   LEAD(col, offset): Accesses rows *following* the current row.

SELECT order_id, customer_id, order_date, total_amount,
       LAG(total_amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_amt,
       LEAD(total_amount, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_amt
FROM orders;

-- Day 15: Running Totals (Windowing Clause)
-- Concept: The windowing clause (ROWS/RANGE BETWEEN) defines the set of rows 
-- included in the analytic calculation relative to the current row.
--   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW: Calculates running totals.

SELECT order_id, customer_id, order_date, total_amount,
       SUM(total_amount) OVER (
           PARTITION BY customer_id 
           ORDER BY order_date 
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_spending
FROM orders;
