# Phase 3 - Performance & PL/SQL

Completed stored code creation, materialized view optimizations, execution plan evaluation, and PL/SQL package design.

### Core Concepts Implemented:
1. **Views & Materialized Views**: Standard view boundaries and fast-refresh MV logs.
2. **Indexing**: B-Tree vs. Bitmap indexing and function-based index constraints.
3. **Execution Plans**: Query tuning using `EXPLAIN PLAN` and Optimizer Hints.
4. **PL/SQL Blocks**: Anonymous scripts, procedural logic loops, and cursor processing.
5. **Stored Abstractions**: Packages, stored procedures, functions, and exceptions.

---

## Technical Interview Q&A (Real-World Experience)

#### Q1: When does a Materialized View with `REFRESH FAST ON COMMIT` cause severe database locking?
**Answer:**
`REFRESH FAST ON COMMIT` refreshes the Materialized View (MV) inside the *same transaction scope* as the DML statement. 
When user session A commits an update on the base table, Oracle must immediately insert into the MV logs, calculate the diff, and update the physical MV table before releasing Session A's transaction lock.
* **The Lock Contention:** If multiple concurrent sessions are updating the base table, they will block each other trying to serialize updates to the same MV table and the MV logs. This turns a high-concurrency OLTP system into a serialized lock bottleneck.
* **The Solution:** In high-concurrency systems, use `REFRESH FORCE ON DEMAND` and orchestrate the refresh asynchronously using `DBMS_SCHEDULER` at regular intervals (e.g. every 5 minutes).

#### Q2: You run `EXPLAIN PLAN` and see a "TABLE ACCESS FULL" scan on a column that has a B-Tree index. Why is the Cost-Based Optimizer (CBO) ignoring your index?
**Answer:**
This is a common production issue. The CBO will skip a B-Tree index for several reasons:
1. **Stale Statistics:** If the tables have not been analyzed (`DBMS_STATS.GATHER_TABLE_STATS`) recently, the CBO might think the table contains 10 rows (making a Full Table Scan cheaper) when it actually contains millions.
2. **Low Cardinality:** B-Tree indexes are inefficient for low-cardinality columns (e.g. `status` with values `['ACTIVE', 'INACTIVE']`). The CBO knows reading the entire table via multi-block read is faster than bouncing back and forth using row identifiers.
3. **Implicit Type Conversions:** If the column `phone_number` is a `VARCHAR2`, and you query `WHERE phone_number = 5551234` (passing a number), Oracle implicitly rewrites it to `TO_NUMBER(phone_number) = 5551234`. The function call disables the index scan. To fix this, always pass matching data types: `phone_number = '5551234'`.
4. **Function Wrappers:** Querying `WHERE UPPER(email) = 'USER@EMAIL.COM'` disables the standard index on `email`. You must create a Function-Based Index: `CREATE INDEX idx_emp_up_email ON employees(UPPER(email))`.

#### Q3: Why should we always package PL/SQL code instead of writing standalone stored procedures?
**Answer:**
Packaging stored code is an industry standard due to several key design reasons:
1. **Reduced Compilations (Dependency Management):** When a standalone procedure changes, all database objects depending on it are marked `INVALID` and must be compiled. In a package, you separate the **Specification** (interface) from the **Body** (implementation). If you update only the Package Body, dependent objects remain `VALID`.
2. **Session State Persistence:** Package variables declared in the specification persist for the duration of the user's session. This allows you to cache configuration values or session-specific states in PGA memory, avoiding repetitive database tables queries.
3. **PGA Memory Cache:** When any part of a package is invoked, the entire package is loaded into the Shared Pool (memory) at once. Subsequent calls to other procedures inside that package execute instantly without disk I/O.
