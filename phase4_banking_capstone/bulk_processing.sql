-- Day 28: PL/SQL Bulk Processing (BULK COLLECT and FORALL)
-- Concept: Bulk operations reduce context switching by fetching or modifying 
-- multiple rows in a single step between the SQL and PL/SQL engines.
--   BULK COLLECT INTO: Fetches multiple rows into a collection in one step.
--   FORALL: Sends multiple DML operations from a collection to the SQL engine in one step.

SET SERVEROUTPUT ON;

DECLARE
    TYPE t_accounts IS TABLE OF accounts%ROWTYPE;
    v_acc_list t_accounts;
BEGIN
    -- Bulk collect query:
    SELECT * BULK COLLECT INTO v_acc_list FROM accounts;
    
    DBMS_OUTPUT.PUT_LINE('Bulk fetched account records count: ' || v_acc_list.COUNT);
END;
/
