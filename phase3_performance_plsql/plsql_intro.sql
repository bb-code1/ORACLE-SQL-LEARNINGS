-- Day 22: Introduction to PL/SQL Blocks
-- Concept: PL/SQL extends SQL with procedural features like variables, loops, and exception handling.
--   Anonymous Block: A one-time execution script that is not stored in the database.
--   DBMS_OUTPUT.PUT_LINE: Prints text to the session output. Requires SET SERVEROUTPUT ON.

SET SERVEROUTPUT ON;

DECLARE
    v_emp_count NUMBER;
    v_threshold CONSTANT NUMBER := 3;
BEGIN
    SELECT COUNT(*) INTO v_emp_count FROM employees;
    DBMS_OUTPUT.PUT_LINE('Employee headcount is: ' || v_emp_count);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
