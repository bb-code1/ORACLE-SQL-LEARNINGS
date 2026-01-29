-- Day 29: PL/SQL Capstone Banking Package
-- Concept: Encapsulating critical financial transactions inside a single package interface

CREATE OR REPLACE PACKAGE pkg_banking AS
    PROCEDURE sp_deposit(p_acc VARCHAR2, p_amt NUMBER, p_desc VARCHAR2);
    PROCEDURE sp_withdraw(p_acc VARCHAR2, p_amt NUMBER, p_desc VARCHAR2);
    PROCEDURE sp_transfer(p_from VARCHAR2, p_to VARCHAR2, p_amt NUMBER, p_desc VARCHAR2);
END pkg_banking;
/

-- Day 29: Capstone Package implementation body
-- Concept: Row-level locking protects transfer operations from concurrent updates.
-- To prevent deadlocks, row locks are acquired in sorted order of the account numbers.

CREATE OR REPLACE PACKAGE BODY pkg_banking AS
    PROCEDURE sp_deposit(p_acc VARCHAR2, p_amt NUMBER, p_desc VARCHAR2) IS
    BEGIN
        UPDATE accounts SET balance = balance + p_amt WHERE account_number = p_acc;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Account ' || p_acc || ' does not exist.');
        END IF;
        INSERT INTO transactions (account_number, transaction_type, amount, description)
        VALUES (p_acc, 'DEPOSIT', p_amt, p_desc);
    END sp_deposit;
    
    PROCEDURE sp_withdraw(p_acc VARCHAR2, p_amt NUMBER, p_desc VARCHAR2) IS
    BEGIN
        UPDATE accounts SET balance = balance - p_amt WHERE account_number = p_acc AND status = 'ACTIVE';
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Account ' || p_acc || ' is inactive or does not exist.');
        END IF;
        INSERT INTO transactions (account_number, transaction_type, amount, description)
        VALUES (p_acc, 'WITHDRAWAL', p_amt, p_desc);
    END sp_withdraw;
    
    PROCEDURE sp_transfer(p_from VARCHAR2, p_to VARCHAR2, p_amt NUMBER, p_desc VARCHAR2) IS
        v_bal_from NUMBER;
    BEGIN
        -- Lock records in sorted order to avoid deadlocks:
        IF p_from < p_to THEN
            SELECT balance INTO v_bal_from FROM accounts WHERE account_number = p_from FOR UPDATE;
            SELECT balance FROM accounts WHERE account_number = p_to FOR UPDATE;
        ELSE
            SELECT balance FROM accounts WHERE account_number = p_to FOR UPDATE;
            SELECT balance INTO v_bal_from FROM accounts WHERE account_number = p_from FOR UPDATE;
        END IF;
        
        sp_withdraw(p_from, p_amt, p_desc || ' (Transfer Out to ' || p_to || ')');
        sp_deposit(p_to, p_amt, p_desc || ' (Transfer In from ' || p_from || ')');
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'One or both accounts do not exist.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END sp_transfer;
END pkg_banking;
/

-- Day 29: Transaction Isolation and Serialization Safety
-- Concept: Ordered locking (acquiring locks in a deterministic order, e.g. lower account ID first) 
-- prevents deadlocks where Session A holds Lock 1 and waits for Lock 2, while Session B holds 
-- Lock 2 and waits for Lock 1.
