-- Day 27: Database Triggers
-- Concept: Triggers automatically execute in response to specific events (INSERT, UPDATE, DELETE) on a table.
--   Row-Level Trigger (FOR EACH ROW): Executes once for each row affected. 
--                                    Accesses row state using :OLD and :NEW values.
--   Statement-Level Trigger (default): Executes once for the entire SQL statement, 
--                                      regardless of how many rows are affected.

CREATE OR REPLACE TRIGGER trg_audit_balance_change
AFTER UPDATE OF balance ON accounts
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (account_number, old_balance, new_balance, changed_by, changed_at)
    VALUES (:old.account_number, :old.balance, :new.balance, USER, SYSTIMESTAMP);
END;
/
