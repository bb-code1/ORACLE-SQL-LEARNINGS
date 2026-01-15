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
