-- Day 21: Transactions and Isolation Levels
-- Concept: Transactions group operations into atomic units (ACID).
--   SAVEPOINT: Creates a checkpoint within a transaction, allowing you to rollback 
--              specific changes without undoing the entire transaction.

CREATE TABLE account_balances (
    account_id NUMBER PRIMARY KEY,
    owner_name VARCHAR2(50 CHAR),
    balance NUMBER(12,2)
);
INSERT INTO account_balances VALUES (1, 'Jane Doe', 5000.00);
INSERT INTO account_balances VALUES (2, 'John Smith', 2000.00);
COMMIT;

SAVEPOINT before_transfer;
UPDATE account_balances SET balance = balance - 500 WHERE account_id = 1;
-- Rollback to the savepoint if the credit step fails:
-- ROLLBACK TO before_transfer;
COMMIT;

-- Day 21: Locking Mechanisms
-- Concept: Locks manage concurrent access to database rows.
--   Row Locks (TX): Automatically acquired during UPDATE/DELETE statements.
--   SELECT ... FOR UPDATE: Locks selected rows, blocking other sessions from 
--                          modifying them until the current transaction commits or rolls back.

-- Session lock check:
-- SELECT balance FROM account_balances WHERE account_id = 1 FOR UPDATE;
