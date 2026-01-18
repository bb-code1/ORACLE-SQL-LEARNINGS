# Phase 3: Performance & PL/SQL - Interview Practice Questions

This document contains 30 highly detailed, production-relevant interview questions and answers covering indexing, optimizer plans, materialized views, PL/SQL packages, stored logic, and custom exceptions in Oracle.

---

### Part 1: Indexing and Cost-Based Optimizer (CBO) Mechanics

#### Q1: What is the physical difference between a B-Tree Index and a Bitmap Index?
**Answer:**
* **B-Tree Index (Balanced Tree):** Stores column values alongside the exact row identifiers (`ROWID`). It is designed for high-cardinality columns (unique or highly selective values like `customer_id`, `email`) in OLTP databases.
* **Bitmap Index:** Stores a string of bits (0s and 1s) representing the key-to-row matching state. It is designed for low-cardinality columns (few distinct values like `gender`, `status`) in OLAP data warehouses.
* **Locking Danger:** DML updates on a bitmap column lock the entire bitmap segment (block of rows), killing concurrent write operations. B-Tree indexes only lock individual index leaf nodes.

#### Q2: What is a Function-Based Index? Write a scenario where creating one resolved an index-skip issue.
**Answer:**
A Function-Based Index pre-calculates the result of an expression on a column and indexes the computed value.
* **Scenario:** A search query uses `WHERE UPPER(last_name) = 'SMITH'`. A standard index on `last_name` is ignored because the `UPPER` function modifies the key. 
* **Fix:** Create a function-based index:
  ```sql
  CREATE INDEX idx_emp_upper_lname ON employees(UPPER(last_name));
  ```
This lets the CBO perform an **Index Range Scan** on the pre-computed uppercase names.

#### Q3: Explain what "Stale Statistics" means. How does it cause index corruption in CBO plans?
**Answer:**
Oracle's CBO relies on statistics (row counts, block counts, null counts, data distribution histograms) to choose execution paths. If you delete or load millions of rows without running `DBMS_STATS.GATHER_TABLE_STATS`, the statistics become stale. The CBO will think the table only has 100 rows, deciding a Full Table Scan (FTS) is cheaper than using an index, leading to query performance issues.

#### Q4: How does a composite B-Tree index (e.g. on `last_name, first_name`) handle query filters on the second column only? What is an Index Skip Scan?
**Answer:**
If the query only filters on `first_name`, the CBO cannot perform a standard index range scan. However, it can perform an **Index Skip Scan**. If the leading column (`last_name`) has very few distinct values, the CBO treats the composite index as multiple sub-indexes, skipping the leading key values to find matching `first_name` entries. If the leading column has high cardinality, the CBO will ignore the index and perform a Full Table Scan.

#### Q5: What is a covering index? How does it avoid table blocks access entirely?
**Answer:**
A covering index contains all the columns requested in the `SELECT` list and `WHERE` clauses. For example, if you have an index on `employee_id, email, salary`, and query:
```sql
SELECT email, salary FROM employees WHERE employee_id = 101;
```
Oracle performs an **Index Unique Scan** and reads the column values directly from the index leaf blocks, bypassing the physical table data block reads entirely.

---

### Part 2: Explain Plans and Join Performance

#### Q6: What is the difference between an Index Range Scan and an Index Unique Scan?
**Answer:**
* **Index Unique Scan:** Occurs when the database searches for a value on a column protected by a `PRIMARY KEY` or `UNIQUE` constraint, returning exactly one `ROWID`.
* **Index Range Scan:** Occurs when searching for a value on a non-unique column or using ranges (e.g. `salary > 5000`), returning multiple `ROWID` pointers.

#### Q7: Under what conditions does the CBO choose a Hash Join over a Nested Loop Join?
**Answer:**
* **Nested Loop Join:** Best for connecting a small driver table to a larger target table with an index. The engine reads a row from the driver table and looks up matching keys in the target table using index pointers.
* **Hash Join:** Best for connecting large tables without indexes. Oracle reads the smaller table, builds a hash table in PGA memory, and then scans the second table to match hash values. It is highly efficient for bulk queries but consumes memory.

#### Q8: Explain what a Sort-Merge Join is. When is it preferred over a Hash Join?
**Answer:**
A Sort-Merge Join sorts both datasets by the join key first, and then merges them. It is preferred over a Hash Join when the datasets are already sorted (e.g. by indexes) or when you use inequality operators (`<`, `>`, `<=`, `>=`) in the join condition, which Hash Joins cannot handle.

#### Q9: What does the "Optimizer Hint" `/*+ LEADING(t1) USE_NL(t2) */` do?
**Answer:**
It overrides the CBO's default plan. 
* **`LEADING(t1)`** forces Oracle to use table `t1` as the driver table.
* **`USE_NL(t2)`** forces Oracle to join table `t2` to the driver table using a **Nested Loop** join instead of a Hash Join.
Use hints cautiously; if data distribution changes, hints can lock in sub-optimal execution paths.

#### Q10: How do you identify a Cartesian Join in an execution plan? Why is it a production risk?
**Answer:**
In an execution plan, look for `MERGE JOIN (CARTESIAN)`. It occurs when tables are joined without a join condition, or when the join key columns don't match. It is a major risk because it generates a Cartesian product (matching every row with every row), causing temp tablespace exhaustion and CPU spikes.

---

### Part 3: Views and Materialized Views

#### Q11: What is the physical difference between a standard View and a Materialized View?
**Answer:**
* **Standard View:** A stored query definition. It consumes no physical storage space. Every time you query the view, Oracle expands the query definition and reads the base tables.
* **Materialized View (MV):** A physical table containing pre-computed query results. It consumes disk storage and must be updated when base tables change.

#### Q12: How does `REFRESH FAST` work on a Materialized View? What is required to use it?
**Answer:**
* **`REFRESH FAST`** updates only the changes since the last refresh, using **Materialized View Logs** created on the base tables.
* **Requirements:** Base tables must have Materialized View Logs (`CREATE MATERIALIZED VIEW LOG ON table`). The MV query must not contain analytic functions, non-deterministic values (like `SYSDATE`), or complex joins without primary keys.

#### Q13: What is Query Rewrite in the context of Materialized Views?
**Answer:**
If Query Rewrite is enabled (`ENABLE QUERY REWRITE`), the CBO automatically redirects queries on base tables to read a matching Materialized View instead. This speeds up analytics because the query reads the pre-aggregated MV table instead of scanning the raw base tables.

#### Q14: What is the performance risk of using complex subqueries inside a standard View?
**Answer:**
Standard views are merged into the outer query by the optimizer. If the view contains complex subqueries or aggregations, the optimizer may fail to merge them, forcing **View Materialization** (writing the entire view output to temp storage before filtering), which is slow.

#### Q15: Explain the difference between `REFRESH ON COMMIT` and `REFRESH ON DEMAND` for Materialized Views.
**Answer:**
* **`ON COMMIT`:** Refreshes the MV immediately when base tables change. It ensures data consistency but slows down DML write speed and causes locking issues under concurrent loads.
* **`ON DEMAND`:** Refreshes when you run `DBMS_MVIEW.REFRESH`. It keeps base table DML fast but the MV data becomes stale until refreshed.

---

### Part 4: Basic PL/SQL Blocks, Loops, and Conditions

#### Q16: What is a PL/SQL anonymous block? Explain the structure.
**Answer:**
An anonymous block is an unnamed, compile-on-the-fly PL/SQL block that is not stored in the database.
```sql
DECLARE
    -- Variable declarations
BEGIN
    -- Procedural code
EXCEPTION
    -- Exception handling
END;
/
```

#### Q17: What is the difference between a `FOR` loop and a `WHILE` loop in PL/SQL?
**Answer:**
* **`FOR` loop:** Iterates a fixed number of times defined by a range: `FOR i IN 1..10 LOOP`. The loop index `i` is defined implicitly and cannot be modified inside the loop.
* **`WHILE` loop:** Iterates as long as a condition evaluates to `TRUE`. You must declare and update the loop variable manually to prevent infinite loops.

#### Q18: What is a Cursor? Explain the difference between an Implicit and Explicit cursor.
**Answer:**
A Cursor is a pointer to the private SQL area in memory where a query executes.
* **Implicit Cursor:** Created automatically by Oracle for any single-row DML or `SELECT INTO` statement.
* **Explicit Cursor:** Declared manually in the `DECLARE` section. You manage it using `OPEN`, `FETCH`, and `CLOSE`. Use explicit cursors for processing multi-row queries.

#### Q19: Explain the %FOUND and %NOTFOUND cursor attributes.
**Answer:**
* **`%FOUND`** evaluates to `TRUE` if the last fetch returned a row.
* **`%NOTFOUND`** evaluates to `TRUE` if the last fetch returned no rows.
```sql
LOOP
    FETCH c_emp INTO v_emp;
    EXIT WHEN c_emp%NOTFOUND;
END LOOP;
```

#### Q20: What is the danger of missing a `CLOSE cursor_name` statement in PL/SQL?
**Answer:**
Explicit cursors consume private SQL memory in the PGA. Failing to close cursors leads to **resource leaks** and eventually causes the session to crash with `ORA-01000: maximum open cursors exceeded`.

---

### Part 5: PL/SQL Stored Code and Packages

#### Q21: What is the mechanical difference between a Stored Procedure and a Stored Function?
**Answer:**
* **Stored Procedure:** Executes an action (DML). It cannot be called inside a SQL query. It can return multiple values using `OUT` parameters.
* **Stored Function:** Calculates a value. It must return exactly one value using a `RETURN` statement. It can be called directly in SQL: `SELECT fn_calc(salary) FROM emp`.

#### Q22: Explain the compilation difference between a Package Specification and a Package Body.
**Answer:**
* **Package Specification:** Declares public variables, procedures, and functions. It is the interface exposed to other database objects.
* **Package Body:** Contains the actual implementation code for the declared procedures and functions.
* **Benefit:** If you update only the Package Body, dependent objects (like views or procedures) do not go `INVALID` and bypass compilation checks.

#### Q23: How do you declare and use Package Session Variables? What is their lifecycle?
**Answer:**
* **Declaration:** Declare a variable in the Package Specification (outside any procedure).
* **Lifecycle:** The variable persists in the session's PGA memory for the duration of the user's connection. It is private to that session. You can use it to store session-specific settings or cache lookup values.

#### Q24: What is the `PRAGMA AUTONOMOUS_TRANSACTION` directive? Give a production scenario.
**Answer:**
It tells Oracle that the procedure runs inside an independent transaction block. Any `COMMIT` or `ROLLBACK` inside the procedure does not affect the outer parent transaction.
* **Scenario:** Logging errors. If a banking transaction procedure fails and rolls back, you still want to write the error log to the database. By using an autonomous transaction inside your logger, you can insert the log and commit it without committing the incomplete banking transaction.

#### Q25: How does the Oracle optimizer handle function calls inside a SQL `WHERE` clause? Explain deterministic functions.
**Answer:**
Functions in SQL filters execute for every row. If a function is marked as `DETERMINISTIC`, Oracle caches the return values for given input values, bypassing function execution on duplicate inputs.

---

### Part 6: Exception Handling

#### Q26: What is the difference between Named System Exceptions and User-Defined Exceptions?
**Answer:**
* **Named System Exceptions:** Pre-defined by Oracle for common errors, like `NO_DATA_FOUND` (when `SELECT INTO` returns 0 rows) or `TOO_MANY_ROWS` (when `SELECT INTO` returns more than 1 row).
* **User-Defined Exceptions:** Declared in the `DECLARE` block to handle custom validations:
  ```sql
  insufficient_funds EXCEPTION;
  ```

#### Q27: How do you raise a custom error message with a specific error code in PL/SQL?
**Answer:**
Use the `RAISE_APPLICATION_ERROR(error_number, error_message)` procedure. The error number must be between `-20000` and `-20999`:
```sql
IF v_balance < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in the account.');
END IF;
```

#### Q28: What is the purpose of `PRAGMA EXCEPTION_INIT`?
**Answer:**
It binds a user-defined exception name to a specific numeric Oracle error code. This allows you to handle specific system errors by name in your exception block:
```sql
DECLARE
    dml_lock_timeout EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_lock_timeout, -54); -- Bind to ORA-00054 (Resource Busy)
BEGIN
    NULL;
END;
```

#### Q29: Explain the risk of using `WHEN OTHERS THEN NULL;` in exception handlers.
**Answer:**
This is known as the **empty exception block** anti-pattern. It catches every error silently, masking critical issues (like missing columns or runtime faults) and making debugging extremely difficult. Always log the error or use `RAISE` to pass it up the stack.

#### Q30: What is the scope of variables in nested PL/SQL blocks?
**Answer:**
Inner blocks have access to variables declared in parent blocks. However, parent blocks cannot access variables declared inside child blocks. If a variable is declared in both, the inner variable takes precedence.
