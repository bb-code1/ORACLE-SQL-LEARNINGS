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

-- Day 27: Mutating Table Error (ORA-04091)
-- Concept: A mutating table is a table that is currently being modified 
-- by a DML statement (insert, update, delete).
-- A row-level trigger cannot query or modify a mutating table, as this could lead to inconsistent data states.
-- Oracle raises ORA-04091 if a row trigger attempts to query the table it is defined on.
-- Avoid mutating errors by using statement-level triggers, compound triggers, or refactoring logic to procedures.

CREATE OR REPLACE TRIGGER trg_prevent_overdraft
BEFORE UPDATE OF balance ON accounts
FOR EACH ROW
BEGIN
    IF :new.balance < 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 'Transaction declined: Insufficient funds. Overdrafts not permitted.');
    END IF;
END;
/

-- Day 27: Trigger Variables Scopes
-- Concept:
--   1. :OLD references pre-update values (available in UPDATE/DELETE triggers).
--   2. :NEW references post-update values (available in INSERT/UPDATE triggers).
--   3. Trigger predicates (`INSERTING`, `UPDATING`, `DELETING`) allow a single trigger 
--      to handle multiple DML actions differently.
