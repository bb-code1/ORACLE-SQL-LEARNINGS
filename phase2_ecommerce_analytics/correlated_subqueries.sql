-- Day 12: Correlated Subqueries
-- Concept: Unlike non-correlated subqueries which execute once, a correlated subquery 
-- references one or more columns from the outer query. It evaluates once for every candidate 
-- row processed by the outer query.

SELECT p.product_name, p.category, p.price
FROM products p
WHERE p.price > (
    SELECT AVG(sub.price)
    FROM products sub
    WHERE sub.category = p.category
);
