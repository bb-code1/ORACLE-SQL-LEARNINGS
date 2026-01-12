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

-- Day 12: EXISTS vs IN
-- Concept:
--   EXISTS: Evaluates to TRUE as soon as the first matching row is found in the subquery (short-circuit evaluation).
--           It does not return any data rows, making it highly efficient.
--   NOT EXISTS: Returns TRUE only if zero matching records are located.

SELECT c.first_name, c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.total_amount > 100
);

-- Day 12: The NOT IN NULL Trap
-- Concept: If a subquery evaluated by a NOT IN operator returns even a single NULL value, 
-- the entire query will return zero rows. This is because (val NOT IN (val1, NULL)) translates 
-- logically to (val != val1 AND val != NULL). Since (val != NULL) returns UNKNOWN, 
-- the compound AND evaluation yields UNKNOWN, filtering out all rows.
-- Use NOT EXISTS instead, which is immune to this issue.
