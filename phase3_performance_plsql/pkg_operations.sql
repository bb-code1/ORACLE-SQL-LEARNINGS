-- Day 25: PL/SQL Packages - Specification
-- Concept: Packages group related procedures, functions, variables, and types into a single database object.
--   Package Specification: Declares the public interface (signatures of public procedures and functions).
--   Package Body: Implements the code for the declared procedures and functions, 
--                 plus any private variables or subprograms.

CREATE OR REPLACE PACKAGE pkg_operations AS
    FUNCTION fn_get_avg_price(p_category IN VARCHAR2) RETURN NUMBER;
    PROCEDURE sp_add_product(p_name IN VARCHAR2, p_category IN VARCHAR2, p_price IN NUMBER);
END pkg_operations;
/

-- Day 25: PL/SQL Packages - Body
-- Concept: The package body contains the implementation logic. 
-- Variables declared inside the package body are private to the package, 
-- while variables declared in the specification are public.

CREATE OR REPLACE PACKAGE BODY pkg_operations AS
    FUNCTION fn_get_avg_price(p_category IN VARCHAR2) RETURN NUMBER IS
        v_avg NUMBER;
    BEGIN
        SELECT AVG(price) INTO v_avg FROM products WHERE category = p_category;
        RETURN NVL(v_avg, 0);
    END fn_get_avg_price;
    
    PROCEDURE sp_add_product(p_name IN VARCHAR2, p_category IN VARCHAR2, p_price IN NUMBER) IS
    BEGIN
        INSERT INTO products(product_name, category, price, stock_quantity)
        VALUES (p_name, p_category, p_price, 0);
    END sp_add_product;
END pkg_operations;
/

-- Day 25: Package Encapsulation and Package State
-- Concept:
--   1. Encapsulation: Hiding implementation details in the package body protects code 
--      and allows changes without breaking dependent objects.
--   2. Package State: Package variables persist for the duration of the user session, 
--      storing state across multiple database calls.
