-- Day 19: Sequences and Identity columns
-- Concept: Sequences generate unique, sequential integers.
--   CACHE N: Pre-allocates N numbers in memory to improve performance. 
--            If the database crashes, unused cached values are lost, creating gaps in sequences.
--   NOCACHE: Avoids gaps, but requires a disk write for every sequence value retrieved.

CREATE SEQUENCE seq_audit_log_id
    START WITH 100
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Day 19: Indexes (B-Tree vs Function-Based)
-- Concept: Indexes speed up data retrieval by avoiding Full Table Scans.
--   B-Tree Index: Default index type. Good for high-cardinality columns (many unique values).
--   Function-Based Index: Indexes the result of a function applied to a column. 
--                          Normal indexes are ignored if a function is used on the column in the WHERE clause.

-- Standard B-Tree Indexes:
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);

-- Function-Based Index:
CREATE INDEX idx_cust_email_lower ON customers(LOWER(email));
