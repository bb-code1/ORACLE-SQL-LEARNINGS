-- Day 11: Single-Row Subqueries
-- Concept: A single-row (scalar) subquery returns exactly one value (one row and one column).
-- It can be used anywhere a constant expression is valid.

SELECT product_name, price,
       (SELECT AVG(price) FROM products) AS avg_catalog_price,
       price - (SELECT AVG(price) FROM products) AS delta_price
FROM products;

-- Day 11: Multi-Row Subqueries (IN, ALL)
-- Concept: Multi-row subqueries return one or more columns with multiple rows.
-- Must use multi-row comparison operators (IN, ANY, ALL) rather than scalar equality (=).
--   IN: Matches any value in the returned set.
--   ALL: Compares the value with *all* values returned in the subquery.

SELECT product_name, price
FROM products
WHERE price >= ALL (SELECT price FROM products WHERE category = 'Electronics');

-- Day 11: Subquery Unnesting
-- Concept: Oracle's Cost-Based Optimizer (CBO) attempts to unnest (refactor) subqueries 
-- into standard joins whenever possible. This allows for more join methods (e.g. hash joins) 
-- and parallel execution paths.
