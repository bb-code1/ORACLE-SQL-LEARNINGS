-- Day 16: Hierarchical Queries - CONNECT BY
-- Concept: CONNECT BY is Oracle's proprietary mechanism for traversing hierarchical structures.
--   START WITH: Defines the root row(s) of the hierarchy.
--   CONNECT BY PRIOR: Specifies the relationship between parent and child rows.
--                     PRIOR column_id = parent_id maps parent columns to children.

-- See phase2_ecommerce_analytics/schema.sql for product_categories table setup.
SELECT LEVEL, category_name
FROM product_categories
START WITH parent_category_id IS NULL
CONNECT BY PRIOR category_id = parent_category_id;

-- Day 16: Hierarchical Helper Functions
-- Concept:
--   SYS_CONNECT_BY_PATH(col, char): Concatenates column values along the path 
--                                    from the root row to the current row.
--   CONNECT_BY_ROOT(col): Returns the value of a column in the root row.

SELECT LEVEL,
       SYS_CONNECT_BY_PATH(category_name, ' -> ') AS hierarchy_path,
       CONNECT_BY_ROOT(category_name) AS root_category
FROM product_categories
START WITH parent_category_id IS NULL
CONNECT BY PRIOR category_id = parent_category_id;
