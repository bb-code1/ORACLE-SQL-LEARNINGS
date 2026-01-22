-- Day 22: Loops and Control Flow in PL/SQL
-- Concept: PL/SQL supports conditional statements (IF-ELSIF-ELSE) and loop structures 
-- (LOOP, WHILE, FOR).

SET SERVEROUTPUT ON;

DECLARE
    v_counter NUMBER := 1;
BEGIN
    -- WHILE loop
    WHILE v_counter <= 3 LOOP
        DBMS_OUTPUT.PUT_LINE('WHILE loop counter: ' || v_counter);
        v_counter := v_counter + 1;
    END LOOP;

    -- FOR loop (implicitly declares the index variable)
    FOR idx IN 1..3 LOOP
        DBMS_OUTPUT.PUT_LINE('FOR loop index: ' || idx);
    END LOOP;
END;
/
