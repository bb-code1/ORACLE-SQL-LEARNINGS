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
