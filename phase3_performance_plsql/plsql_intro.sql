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

-- Day 22: Context Switches
-- Concept: The Oracle database runtime contains two engines: the SQL engine and the PL/SQL engine.
-- When PL/SQL code executes a SQL statement, control shifts from the PL/SQL engine 
-- to the SQL engine. This context switch consumes CPU cycles.
-- Minimize context switches by using bulk operations (BULK COLLECT, FORALL) and keeping 
-- logic in SQL where possible.
