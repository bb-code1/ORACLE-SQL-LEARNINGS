-- Day 23: PL/SQL Stored Procedures
-- Concept: Procedures are named PL/SQL blocks stored in the database.
-- They run compiled code, reducing parsing overhead.
-- Procedures perform actions and do not return values directly (unlike functions).

CREATE OR REPLACE PROCEDURE sp_adjust_stock (
    p_product_id IN NUMBER,
    p_amount IN NUMBER
) IS
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity + p_amount
    WHERE product_id = p_product_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Product ID ' || p_product_id || ' not found.');
    END IF;
END sp_adjust_stock;
/

-- Day 23: PL/SQL Stored Functions
-- Concept: Functions must return a single value using a RETURN statement.
-- Stored functions can be called directly in SQL queries, but this can introduce 
-- context switch overhead.

CREATE OR REPLACE FUNCTION fn_calculate_tax (
    p_amount IN NUMBER,
    p_tax_rate IN NUMBER DEFAULT 0.08
) RETURN NUMBER IS
BEGIN
    RETURN ROUND(p_amount * p_tax_rate, 2);
END fn_calculate_tax;
/
