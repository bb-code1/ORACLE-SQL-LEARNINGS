# Phase 4: Banking Capstone Project - Interview Practice Questions

This document contains 30 highly detailed, production-relevant interview questions and answers covering transactional concurrency, deadlock prevention, database triggers, bulk data processing, security context policies, and transaction boundary controls.

---

### Part 1: Transaction Concurrency, Row-Level Locking, and Deadlock Mitigation

#### Q1: What is the mechanical difference between `SELECT ... FOR UPDATE` and a standard `SELECT` query in Oracle?
**Answer:**
* **Standard `SELECT`:** Executes using **non-blocking reads** via Multi-Version Concurrency Control (MVCC). It fetches consistent data from the UNDO tablespace without acquiring locks, meaning readers never block writers and writers never block readers.
* **`SELECT ... FOR UPDATE`:** Acquires exclusive row-level locks on the returned rows. Concurrent updates or delete operations on those rows by other sessions are blocked until the lock-holding transaction issues a `COMMIT` or `ROLLBACK`.

#### Q2: What is the `WAIT N` and `NOWAIT` clause in `SELECT ... FOR UPDATE`? How do you prevent application threads hanging?
**Answer:**
* **Default behavior:** If a row is locked, `FOR UPDATE` will block indefinitely (hang) waiting for the lock to release.
* **`NOWAIT`:** Immediately throws `ORA-00054: resource busy` if a row is locked.
* **`WAIT N`:** Waits exactly `N` seconds before throwing the error.
* **Prevention:** In web applications, use `NOWAIT` or `WAIT 2` to fail fast and return a clean error to the user rather than letting database sessions pile up and consume connection pool resources.

#### Q3: Explain what a Deadlock (`ORA-00060`) is. How does the Oracle database resolve it?
**Answer:**
A deadlock is a circular dependency where Session A holds Lock 1 and waits for Lock 2, while Session B holds Lock 2 and waits for Lock 1. Neither can progress.
* **Resolution:** Oracle automatically detects deadlocks within seconds. It chooses one of the sessions as the "victim", terminates the statement that caused the block, rolls back *only that specific statement*, and throws `ORA-00060: deadlock detected` in that session. It does not roll back the entire transaction; the application must handle the exception and decide to issue a full `ROLLBACK`.

#### Q4: Why is sorted locking (e.g. locking rows in order of PK) a bulletproof way to prevent deadlocks?
**Answer:**
Deadlocks only occur if transactions lock resources in different sequences. If every procedure in the system sorts the primary keys (e.g., lower account number first) before acquiring locks, the dependency graph is always linear, never circular. 
* **Example:** If Session A and Session B both want to update Account 101 and Account 202, both will try to lock Account 101 first. Session A gets the lock, and Session B waits. Session A then locks Account 202 and commits, releasing both locks. No deadlock can occur.

#### Q5: Explain the difference between Row-Level Locking in Oracle vs SQL Server.
**Answer:**
* **SQL Server:** Uses a lock manager that consumes memory. Under heavy updates, SQL Server will perform **Lock Escalation**, converting thousands of row locks into a single table lock to save memory, blocking other users.
* **Oracle:** Stores lock metadata inside the data block itself (in the block header's **Interested Transaction List (ITL)**). Oracle never escalates row locks to table locks, meaning you can lock 10 million rows without consuming extra lock manager memory or blocking other rows.

---

### Part 2: Database Triggers and the Mutating Table Error

#### Q6: What is a Mutating Table Error (`ORA-04091`)? How does it occur?
**Answer:**
A mutating table is a table that is currently being modified by a DML statement (insert, update, delete).
* **The Error:** A row-level trigger (`FOR EACH ROW`) cannot query or modify the same table that fired the trigger. Doing so throws `ORA-04091` because the table is in a transient, inconsistent state. 
* **Why:** If the trigger read the table, it would see incomplete data, violating transaction isolation rules.

#### Q7: How do you bypass a Mutating Table Error without using compound triggers or package variables?
**Answer:**
Convert the trigger to a **Statement-Level Trigger** (remove the `FOR EACH ROW` clause). Statement-level triggers execute once after the entire DML statement completes, when the table is no longer mutating, allowing you to run audit checks or validations on the table.

#### Q8: Explain the difference between `:NEW` and `:OLD` bind variables. When are they populated?
**Answer:**
* **`INSERT`:** `:NEW` contains the incoming values; `:OLD` is completely `NULL`.
* **`UPDATE`:** `:NEW` contains the modified values; `:OLD` contains the pre-update values.
* **`DELETE`:** `:NEW` is `NULL`; `:OLD` contains the values of the deleted row.
These variables are only accessible in row-level triggers.

#### Q9: What is the performance danger of placing heavy business logic inside a `BEFORE INSERT` trigger?
**Answer:**
It forces a context switch between the SQL and PL/SQL engines for every single row insert. If you load 100,000 rows, the trigger executes 100,000 times, multiplying execution time. Triggers also bypass batch insert optimizations (like direct-path writes).

#### Q10: How does a Compound Trigger simplify PL/SQL code execution across multiple DML phases?
**Answer:**
Introduced in Oracle 11g, a Compound Trigger combines all trigger timing points (`BEFORE STATEMENT`, `BEFORE EACH ROW`, `AFTER EACH ROW`, `AFTER STATEMENT`) into a single code block. This allows you to share variables and collections in PGA memory across all execution phases, bypassing mutating table errors.

---

### Part 3: PL/SQL Bulk Processing Mechanics

#### Q11: What is the physical difference between a row-by-row cursor loop and `BULK COLLECT`?
**Answer:**
* **Row-by-row:** Bounces between the PL/SQL engine and the SQL engine for every row, causing high context-switching overhead.
* **`BULK COLLECT`:** Fetches multiple rows into a PL/SQL collection (array) in a single engine context switch, reducing CPU consumption.

#### Q12: Why is the `LIMIT` clause mandatory when using `BULK COLLECT` in production?
**Answer:**
Without a `LIMIT` clause, `BULK COLLECT` reads the entire target dataset into the session's PGA memory. If the table contains 10 million rows, this will exhaust server memory and crash the database. A `LIMIT 1000` clause ensures that only 1,000 records are loaded into memory at a time.

#### Q13: Explain how the `FORALL` statement works. How is it different from a standard `FOR` loop?
**Answer:**
* **`FOR` loop:** Iterates procedurally, sending one DML statement to the SQL engine at a time.
* **`FORALL`:** Sends the entire collection of DML operations to the SQL engine at once, executing the updates/inserts in a single batch.

#### Q14: Explain the `SQL%BULK_EXCEPTIONS` attribute. How do you loop through it?
**Answer:**
When using `FORALL ... SAVE EXCEPTIONS`, if any DML operations fail, Oracle stores the error details in `SQL%BULK_EXCEPTIONS`. You can iterate through this collection to log specific errors:
```sql
FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
    v_idx := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
    v_code := SQL%BULK_EXCEPTIONS(i).ERROR_CODE;
    -- Log error
END LOOP;
```

#### Q15: What is the difference between direct-path insert (`/*+ APPEND */`) and bulk binding in PL/SQL?
**Answer:**
* **`/*+ APPEND */`** bypasses the buffer cache and writes data blocks directly to the end of the tablespace datafile (above the high-water mark), which is fast but locks the table.
* **Bulk binding (`FORALL`)** writes data blocks via the standard buffer cache, allowing concurrent users to query and modify the table.

---

### Part 4: Database Security, VPD, and FGA

#### Q16: What is Oracle Virtual Private Database (VPD)? How does it implement Row-Level Security?
**Answer:**
VPD (also known as Row-Level Security) dynamically modifies incoming SQL queries. When a user queries a table protected by a VPD policy, Oracle runs a policy function that returns a `WHERE` clause predicate (e.g. `department_id = 10`), appending it to the query before execution. This ensures that users can only see the rows they are authorized to access.

#### Q17: What is the difference between Role-Based Security and Virtual Private Database (VPD)?
**Answer:**
* **Role-Based Security:** Grants access to object privileges (e.g., user can `SELECT` from `accounts`). It is all-or-nothing.
* **VPD:** Restricts access to specific *rows* within an object based on the user's session context.

#### Q18: What is Fine-Grained Auditing (FGA)? How does it differ from standard database auditing?
**Answer:**
* **Standard Auditing:** Audits access at the schema object level (e.g., "User A selected from `accounts`").
* **FGA (via `DBMS_FGA`):** Audits access based on data content. For example, it only logs the action if a user queries a specific column (`balance`) and the value exceeds a threshold (`balance > 50000`).

#### Q19: Explain the concept of SQL Injection. How do bind variables protect PL/SQL code from it?
**Answer:**
SQL Injection occurs when user input is concatenated directly into dynamic SQL queries (using `EXECUTE IMMEDIATE`), allowing malicious users to execute unauthorized commands.
* **Bind Variables:** Pass the user input as a parameters rather than concatenating it. This forces the SQL engine to treat the input as a literal string value, preventing it from being parsed as executable code.

#### Q20: What is the difference between System Privileges and Object Privileges?
**Answer:**
* **System Privileges:** Grant the ability to perform administrative database tasks (e.g., `CREATE TABLE`, `CREATE USER`).
* **Object Privileges:** Grant the ability to perform tasks on specific schema objects (e.g., `SELECT` or `UPDATE` on `accounts`).

---

### Part 5: Transaction Boundaries and Isolation

#### Q21: What is a transaction? Explain the ACID properties in database engines.
**Answer:**
A transaction is a logical unit of database work.
* **Atomicity:** All modifications in the transaction succeed, or all fail.
* **Consistency:** The transaction leaves the database in a valid state.
* **Isolation:** Uncommitted changes are invisible to other sessions.
* **Durability:** Committed changes are written to disk permanently.

#### Q22: What is the difference between `COMMIT` and `ROLLBACK`? What happens to locks on each?
**Answer:**
* **`COMMIT`:** Saves all transaction changes to disk and releases all row-level locks.
* **`ROLLBACK`:** Reverts all transaction changes using undo segments and releases all row-level locks.

#### Q23: What is a `SAVEPOINT`? How is it useful for partial rollbacks inside nested business logic?
**Answer:**
A `SAVEPOINT` marks a specific spot within a transaction. It allows you to roll back a portion of your modifications without rolling back the entire transaction:
```sql
SAVEPOINT before_transfer;
-- Run transfer
IF transfer_failed THEN
    ROLLBACK TO before_transfer;
END IF;
```

#### Q24: Explain what a Dirty Read is. Why is it impossible to experience a Dirty Read in an Oracle database?
**Answer:**
A Dirty Read occurs when Transaction A reads uncommitted modifications made by Transaction B.
* **Why it's impossible:** Oracle uses Multi-Version Concurrency Control (MVCC). Oracle reconstructs consistent data from the UNDO tablespace for any queries, making uncommitted modifications completely invisible to other sessions.

#### Q25: Explain the `SERIALIZABLE` isolation level in Oracle. What is the risk of using it?
**Answer:**
`SERIALIZABLE` forces transactions to act as if they are executing sequentially. If Transaction A queries a table, it cannot see any changes committed by other sessions after Transaction A started.
* **Risk:** If Transaction A tries to update a row that has been updated and committed by another session after Transaction A started, Oracle immediately throws `ORA-08177: can't serialize access for this transaction` and aborts the statement, requiring the application to retry the entire transaction.

---

### Part 6: Ledger Reconciliation and System Auditing

#### Q26: Why is keeping a double-entry ledger architecture critical in financial databases?
**Answer:**
Instead of simply updating a customer's balance, a ledger records every balance change as individual debit/credit rows. This provides a complete, mathematically verifiable trail of all financial movements. If you sum all transactions for an account, it must exactly match the account's current cached balance.

#### Q27: How do you design a database schema to prevent manual tamper updates on transactional records?
**Answer:**
1. Revoke direct `UPDATE` and `DELETE` object privileges on the ledger table from all user accounts.
2. Route all transactions through a secure Package API (`pkg_banking`) running with definer rights.
3. Implement Fine-Grained Auditing (FGA) to trigger alerts if direct SQL DML modifications are attempted.

#### Q28: What is the purpose of a reconciliation audit query in a banking ledger?
**Answer:**
A reconciliation audit verifies that the cached account balance matches the sum of the transaction ledger records. If a discrepancy exists, it indicates a database bug, constraint bypass, or manual data tampering.

#### Q29: How does Oracle's redo log file system ensure Durability during commits?
**Answer:**
When a transaction commits, Oracle writes the change vectors to the **Redo Log Buffer** in memory, and the Log Writer (LGWR) process flushes these logs to the physical **Redo Log Files** on disk immediately. The database changes are written to disk before the block is written to the datafile, ensuring that changes can be recovered if the server crashes.

#### Q30: What is the risk of using `ROLLBACK` inside a database trigger?
**Answer:**
It throws `ORA-04092: cannot ROLLBACK in a trigger`. 
Triggers run inside the parent transaction block and cannot control the transaction boundaries. Attempting to rollback inside a trigger will crash the session and roll back the entire transaction.
