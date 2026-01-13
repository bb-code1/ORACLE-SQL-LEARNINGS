-- Day 13: Common Table Expressions (WITH clause)
-- Concept: CTEs define temporary result sets that can be referenced multiple times 
-- within a single SELECT, INSERT, UPDATE, or DELETE query.
-- They improve code readability by replacing complex nested inline views.

WITH customer_spending AS (
    SELECT customer_id, SUM(total_amount) AS total_spent, COUNT(*) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT c.first_name, c.last_name, cs.total_spent
FROM customers c
JOIN customer_spending cs ON c.customer_id = cs.customer_id;

-- Day 13: Recursive CTEs
-- Concept: Recursive CTEs consist of an Anchor member (base case) and a Recursive member 
-- linked by a UNION ALL. The recursive member references the CTE itself, executing iteratively 
-- until no further rows are returned.

WITH category_tree (category_id, category_name, parent_id, path_string) AS (
    -- Anchor Member
    SELECT category_id, category_name, parent_category_id, CAST(category_name AS VARCHAR2(200))
    FROM product_categories
    WHERE parent_category_id IS NULL
    UNION ALL
    -- Recursive Member
    SELECT child.category_id, child.category_name, child.parent_category_id,
           CAST(parent.path_string || ' -> ' || child.category_name AS VARCHAR2(200))
    FROM product_categories child
    JOIN category_tree parent ON child.parent_category_id = parent.category_id
)
SELECT category_id, path_string FROM category_tree;

-- Day 13: Materialization vs Inline Expansion
-- Concept: Oracle has two strategies for executing CTEs:
--   1. INLINE (default / internal expansion): The CTE text is substituted directly 
--      into the main query, similar to an inline view.
--   2. MATERIALIZED: Oracle creates a temporary table to store the CTE output, 
--      then joins against it. This is useful for expensive CTEs referenced multiple times.
--   Hints /*+ INLINE */ and /*+ MATERIALIZE */ can force these behaviors.
