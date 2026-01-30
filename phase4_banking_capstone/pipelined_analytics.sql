-- Day 30: PL/SQL Pipelined Table Functions
-- Concept: Pipelined functions return database rows incrementally to the calling SQL query 
-- using the PIPE ROW command before the function completely finishes execution.
-- This reduces memory overhead and improves performance when transforming large data feeds.

-- 1. Create SQL Object Types representing a single record and a table of those records:
CREATE OR REPLACE TYPE t_audit_rec IS OBJECT (
    account_number VARCHAR2(20 CHAR),
    txn_type VARCHAR2(15 CHAR),
    amount NUMBER(15,2),
    risk_flag VARCHAR2(3 CHAR)
);
/

CREATE OR REPLACE TYPE t_audit_table IS TABLE OF t_audit_rec;
/

-- 2. Create the Pipelined Function to detect transactions exceeding a threshold
CREATE OR REPLACE FUNCTION fn_detect_high_risk_txns(p_threshold NUMBER)
RETURN t_audit_table PIPELINED IS
BEGIN
    FOR r IN (
        SELECT account_number, transaction_type, amount 
        FROM transactions
    ) LOOP
        -- Flag transactions above the threshold as high risk
        IF r.amount >= p_threshold THEN
            PIPE ROW(t_audit_rec(r.account_number, r.transaction_type, r.amount, 'YES'));
        ELSE
            PIPE ROW(t_audit_rec(r.account_number, r.transaction_type, r.amount, 'NO'));
        END IF;
    END LOOP;
    
    RETURN; -- A pipelined function must contain an empty RETURN statement
END;
/

-- 3. Query the PL/SQL pipelined function directly in SQL using the TABLE operator:
SELECT * 
FROM TABLE(fn_detect_high_risk_txns(5000.00))
ORDER BY amount DESC;
