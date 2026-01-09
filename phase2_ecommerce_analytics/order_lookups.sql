-- Day 9: INNER and LEFT Joins
-- Concept: Joins associate matching rows across different datasets.
--   INNER JOIN: Returns only rows with matching values in both tables.
--   LEFT OUTER JOIN: Returns all rows from the left table, plus matched rows from the 
--                    right table (unmatched right rows return NULL values).

-- Query 1: INNER JOIN
SELECT c.first_name, c.last_name, o.order_id, o.order_date, p.product_name, oi.quantity
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Query 2: LEFT OUTER JOIN
SELECT c.first_name, c.last_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Day 9: Legacy Join Syntax (+)
-- Concept: Historically, Oracle executed outer joins using the proprietary (+) marker on the NULL-receiving side.
-- Avoid legacy syntax since it is harder to read, error-prone for compound outer joins, and non-portable.

-- Legacy Oracle Left Join:
SELECT c.first_name, o.order_id
FROM customers c, orders o
WHERE c.customer_id = o.customer_id(+);
