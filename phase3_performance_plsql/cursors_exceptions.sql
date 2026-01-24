-- Day 24: PL/SQL Cursors
-- Concept: A cursor is a pointer to the private SQL memory area allocated by Oracle to execute queries.
--   Implicit Cursor: Created automatically by Oracle for all DML statements and single-row SELECT INTO statements.
--   Explicit Cursor: Declared manually for multi-row queries. 
--                    Managed using OPEN, FETCH, and CLOSE commands.
--   Cursor FOR Loop: Automatically opens, fetches, and closes the cursor, avoiding boilerplate code.

SET SERVEROUTPUT ON;

DECLARE
    CURSOR cur_orders IS
        SELECT order_id, total_amount FROM orders;
BEGIN
    -- Cursor FOR loop
    FOR rec IN cur_orders LOOP
        DBMS_OUTPUT.PUT_LINE('Order: ' || rec.order_id || ' | Amount: ' || rec.total_amount);
    END LOOP;
END;
/
