-- Day 11: Single-Row Subqueries
-- Concept: A single-row (scalar) subquery returns exactly one value (one row and one column).
-- It can be used anywhere a constant expression is valid.

SELECT product_name, price,
       (SELECT AVG(price) FROM products) AS avg_catalog_price,
       price - (SELECT AVG(price) FROM products) AS delta_price
FROM products;
