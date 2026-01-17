-- Day 17: Database Synchronization using MERGE
-- Concept: MERGE (UPSERT) consolidates conditional UPDATE and INSERT statements into a single, highly-performant operation.
-- It is the enterprise standard for syncing transaction and master tables without running separate SELECT/UPDATE/INSERT commands.

-- 1. Create a staging table representing incoming supplier product updates:
CREATE TABLE supplier_product_feed (
    product_name VARCHAR2(100 CHAR),
    category VARCHAR2(50 CHAR),
    price NUMBER(10,2),
    added_stock NUMBER
);

-- 2. Seed the staging feed
INSERT INTO supplier_product_feed (product_name, category, price, added_stock)
VALUES ('Laptop Pro', 'Electronics', 1150.00, 10); -- Matches existing product (updates price & stock)

INSERT INTO supplier_product_feed (product_name, category, price, added_stock)
VALUES ('Ergonomic Chair', 'Office', 250.00, 30); -- New product (inserts record)

-- 3. Execute MERGE to sync products inventory
MERGE INTO products p
USING supplier_product_feed s
ON (p.product_name = s.product_name)
WHEN MATCHED THEN
    UPDATE SET p.price = s.price,
               p.stock_quantity = p.stock_quantity + s.added_stock
WHEN NOT MATCHED THEN
    INSERT (product_name, category, price, stock_quantity)
    VALUES (s.product_name, s.category, s.price, s.added_stock);

-- 4. Clean up staging tables
DROP TABLE supplier_product_feed;
