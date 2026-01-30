# Phase 4 - Banking Capstone Project

This project implements a secure, auditable, and performant Banking Transaction ledger.

### Schema Blueprint:
- **`accounts`**: Stores balances and statuses (ACTIVE, SUSPENDED, CLOSED).
- **`transactions`**: Records individual transaction ledger items.
- **`audit_log`**: Captures all balance changes for compliance auditing.

### Advanced Scripts:
- **`bulk_processing.sql`**: Production-grade bulk operations using a cursor loop with a `LIMIT` clause to protect PGA memory, and `FORALL ... SAVE EXCEPTIONS` to handle bulk update failures gracefully.
- **`pipelined_analytics.sql`**: Pipelined table function (`fn_detect_high_risk_txns`) that streams transaction logs incrementally to SQL queries using custom object types.

---

## Technical Interview Q&A (Real-World Experience)

#### Q1: Why are database triggers considered an anti-pattern in high-throughput transactional systems?
**Answer:**
While triggers are useful for auditing (like inserting into `audit_log` on balance changes), they present critical production risks under load:
1. **Mutating Table Error (`ORA-04091`):** A row-level trigger cannot query or modify the same table that fired it. This makes complex validations (like checking aggregate limits on the parent table) fail.
2. **Context Switching Overhead:** Row-level triggers fire row-by-row. If you update 10,000 accounts, Oracle context-switches 10,000 times between the SQL DML engine and the PL/SQL trigger execution engine, degrading performance.
3. **Hidden Logic:** Triggers execute implicitly. Developers debugging a performance bottleneck or transactional lock may not realize a trigger is running a heavy subquery in the background. It is better to encapsulate this logic within a Package API (like `pkg_banking`).

#### Q2: How does `FORALL ... SAVE EXCEPTIONS` differ from a standard PL/SQL cursor loop for batch updates?
**Answer:**
* **Standard Cursor Loop:** Sends updates to the SQL engine one-by-one. If row 500 fails constraint validation, the execution stops, throws an exception, and rolls back the work completed so far.
* **`FORALL`:** Batches all update statements and sends them in a single context switch.
* **`SAVE EXCEPTIONS`:** If row 500 fails, the engine logs the failure details in `SQL%BULK_EXCEPTIONS` and continues processing the rest of the batch (e.g. the remaining 9,500 rows). This prevents one validation failure from crashing an entire nightly batch upload or interest payout.

#### Q3: You implemented sorted locking in `pkg_banking.sp_transfer` to prevent deadlocks. What happens if a new developer creates a different procedure that locks the same tables in a different order?
**Answer:**
A **deadlock will still occur**. 
Deadlock avoidance requires complete lock ordering consistency across the entire database. If `sp_transfer` locks Account 1 (lower ID) and then Account 2 (higher ID), but a new procedure `sp_monthly_reconcile` locks Account 2 first and then Account 1, a circular dependency will occur under concurrent execution:
* Session A runs `sp_transfer` and locks Account 1, waiting for Account 2.
* Session B runs `sp_monthly_reconcile` and locks Account 2, waiting for Account 1.
Neither session can release its lock, causing the database to raise `ORA-00060: deadlock detected` and roll back one of the statements. Locking sequences must be strictly standard across all codebase modules.
