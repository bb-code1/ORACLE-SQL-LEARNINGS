-- Day 28: Production-Grade PL/SQL Bulk Processing
-- Concept: Bulk operations minimize context switching between the PL/SQL engine and the SQL engine.
-- To make bulk operations safe in production:
--   1. Use 'LIMIT' on BULK COLLECT to restrict memory usage (PGA).
--   2. Use 'FORALL ... SAVE EXCEPTIONS' so one row validation error doesn't rollback the entire batch.

SET SERVEROUTPUT ON;

DECLARE
    -- Cursor to iterate through all active accounts
    CURSOR c_accounts IS 
        SELECT * FROM accounts WHERE status = 'ACTIVE';
        
    TYPE t_accounts IS TABLE OF accounts%ROWTYPE;
    v_acc_list t_accounts;
    
    -- Oracle error code for FORALL bulk errors
    bulk_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(bulk_error, -24381);
BEGIN
    OPEN c_accounts;
    LOOP
        -- Fetch records in safe chunks of 1000 (limits server memory usage)
        FETCH c_accounts BULK COLLECT INTO v_acc_list LIMIT 1000;
        EXIT WHEN v_acc_list.COUNT = 0;
        
        DBMS_OUTPUT.PUT_LINE('Fetched batch of ' || v_acc_list.COUNT || ' accounts.');
        
        BEGIN
            -- Execute updates in bulk, saving exceptions for later analysis
            FORALL i IN 1..v_acc_list.COUNT SAVE EXCEPTIONS
                UPDATE accounts 
                SET balance = balance + 50.00 -- Monthly dividend payout
                WHERE account_number = v_acc_list(i).account_number;
                
        EXCEPTION
            WHEN bulk_error THEN
                -- Inspect the exception array to report specific failures
                FOR j IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                    DBMS_OUTPUT.PUT_LINE(
                        'DML Error on Row Index ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX ||
                        ' (Account: ' || v_acc_list(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX).account_number || '): ' ||
                        SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE)
                    );
                END LOOP;
        END;
        
    END LOOP;
    CLOSE c_accounts;
END;
/
