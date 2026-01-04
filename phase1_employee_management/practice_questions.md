# Phase 1: Employee Management Database - Interview Practice Questions

This document contains 30 highly detailed, production-relevant interview questions and answers covering schema design, constraints, aggregate queries, string/date parsing, and logic branching in Oracle SQL.

---

### Part 1: Schema Setup, Data Definition, and Relational Constraints

#### Q1: What is the mechanical difference between `CHAR` and `VARCHAR2` data types in Oracle? Why does it matter for index space?
**Answer:**
* **`CHAR(N)`** is a fixed-length string. If you store a 3-character string in a `CHAR(10)` column, Oracle pads it with 7 trailing spaces to fill the 10 bytes.
* **`VARCHAR2(N)`** is a variable-length string. If you store a 3-character string in `VARCHAR2(10)`, it consumes only 3 bytes on disk plus 1-2 bytes of length prefix metadata.
* **Index Space Impact:** B-Tree index leaf blocks store the key values. Since `CHAR` columns are padded to their maximum size, an index on a `CHAR(100)` column will store full 100-byte strings for every record, bloating the index size, reducing the caching efficiency in the Buffer Cache, and causing higher disk read I/O compared to a `VARCHAR2(100)` index.

#### Q2: What is a `CHECK` constraint, and why can it not reference dynamic values like `SYSDATE` or other tables?
**Answer:**
A `CHECK` constraint enforces domain integrity by ensuring that values in a row satisfy a logical expression (e.g. `salary > 0`). It cannot reference dynamic functions like `SYSDATE` or values in other tables because a constraint must be completely deterministic at the exact millisecond the DML row evaluation occurs. Checking other tables would require Oracle to lock and read external table structures during a simple insert/update, causing locking deadlocks. For dynamic or multi-table checks, you must use a Database Trigger or enforce it at the application layer.

#### Q3: Explain how Oracle handles a `DELETE CASCADE` constraint. What is the danger of missing an index on the Foreign Key column?
**Answer:**
* **`ON DELETE CASCADE`** automatically deletes child table records when a referenced parent record is deleted.
* **The Missing Index Danger:** When you delete a record from the parent table, Oracle must scan the child table to delete dependent rows. If there is no index on the child table's Foreign Key column, Oracle is forced to execute a **Full Table Scan (FTS)** on the child table. Under high concurrency, this locks the child table's blocks, causing severe queue latency. Additionally, it causes a share lock on the child table, preventing concurrent DML operations on unrelated child records.

#### Q4: Why does Oracle recommend putting Foreign Key constraints in `DISABLE NOVALIDATE` state during large data warehouse migration loads?
**Answer:**
* **`DISABLE`** stops Oracle from checking the constraint during inserts, avoiding validation overhead and speeding up bulk inserts.
* **`NOVALIDATE`** tells Oracle to assume existing data is correct without scanning the entire table to verify old records.
* **Production Context:** During migrations, data is cleaned in staging areas first. By setting keys to `DISABLE NOVALIDATE` during the load, you bypass the row-level check entirely. Once loaded, you can run `ENABLE NOVALIDATE` which validates future inserts without locking the table to scan historic rows.

#### Q5: If a column has a `DEFAULT` value of `SYSDATE`, and a batch job inserts a row explicitly setting that column to `NULL`, does the column get the default date?
**Answer:**
**No.** If an insert statement explicitly includes the column and sets it to `NULL` (e.g. `INSERT INTO t (col) VALUES (NULL)`), Oracle will overwrite the default and insert a physical `NULL` value. The `DEFAULT` value only kicks in if the column is completely omitted from the insertion list: `INSERT INTO t (other_col) VALUES (val)`.

---

### Part 2: Basic SELECT Queries, Sorting, and Filtering Logic

#### Q6: Explain Three-Valued Logic in SQL. How do `AND` and `OR` handle `UNKNOWN` (NULL) states?
**Answer:**
In SQL, conditional evaluations can result in `TRUE`, `FALSE`, or `UNKNOWN` (represented by NULL).
* **`AND` evaluations:** If any input is `FALSE`, the result is `FALSE`. If one input is `TRUE` and the other is `UNKNOWN`, the result is `UNKNOWN`.
* **`OR` evaluations:** If any input is `TRUE`, the result is `TRUE`. If one input is `FALSE` and the other is `UNKNOWN`, the result is `UNKNOWN`.
To query rows with nulls, standard comparisons like `column = NULL` fail because they resolve to `UNKNOWN`. You must explicitly use `IS NULL`.

#### Q7: How does `ORDER BY` handle NULL values in Oracle by default? How do you override this?
**Answer:**
* **Default Behavior:** In an ascending sort (`ASC`), Oracle places NULL values at the **end** (highest value). In a descending sort (`DESC`), Oracle places NULL values at the **beginning**.
* **Override:** You can control this using `NULLS FIRST` or `NULLS LAST`:
  ```sql
  SELECT name, salary FROM employees ORDER BY salary ASC NULLS FIRST;
  ```
This is critical for reporting so that empty records don't clutter the top or bottom of sorted user lists.

#### Q8: Why is the `LIKE` operator slower than equality `=`? How do wildcard placements (e.g. `%term` vs `term%`) affect index usage?
**Answer:**
`LIKE` is designed for pattern matching, which requires character-by-character scan comparison.
* **`term%` (Prefix Match):** The CBO can perform an **Index Range Scan** because the beginning characters are fixed, allowing the engine to traverse the B-Tree structure directly to the starting key.
* **`%term` (Suffix/Substring Match):** The index is useless because the beginning characters are unknown. The CBO is forced to do an **Index Full Scan** or a **Full Table Scan**, reading every single row to check if the suffix matches.

#### Q9: What is the danger of writing `WHERE salary BETWEEN min_val AND max_val` when dealing with inclusive boundaries?
**Answer:**
`BETWEEN` is strictly inclusive, equivalent to `(salary >= min_val AND salary <= max_val)`. If you want to filter salaries strictly between two ranges excluding the boundaries, `BETWEEN` is the wrong tool. Furthermore, if `min_val` is accidentally larger than `max_val`, the expression returns no rows without throwing an error.

#### Q10: How does `ESCAPE` work inside a `LIKE` filter? Write a query to find employees whose username contains a physical underscore `_`.
**Answer:**
Underscore `_` is a wildcard representing any single character. To search for it literally, you must define an escape character using the `ESCAPE` clause:
```sql
SELECT employee_id, email 
FROM employees 
WHERE email LIKE '%\_%' ESCAPE '\';
```
This tells Oracle to treat the character immediately following the backslash as a literal string.

---

### Part 3: Oracle Character and String Functions

#### Q11: Explain the difference between `INSTR` and `SUBSTR`. How do you use them together to extract an email domain?
**Answer:**
* **`INSTR(str, search_str)`** returns the 1-indexed position of a substring within a target string.
* **`SUBSTR(str, start_pos, length)`** extracts characters from a string starting at `start_pos`.
* **Extraction:** To extract the domain (e.g. everything after `@`) from an email column:
  ```sql
  SELECT SUBSTR(email, INSTR(email, '@') + 1) AS domain FROM employees;
  ```

#### Q12: What are `LPAD` and `RPAD`? Give a practical production scenario for them.
**Answer:**
`LPAD` and `RPAD` pad strings with specified characters to reach a target length.
* **Scenario:** Generating fixed-width files (like ACH payment files or credit reporting files) where account numbers must be left-padded with zeroes to be exactly 12 characters:
  ```sql
  SELECT LPAD(account_number, 12, '0') FROM accounts;
  ```

#### Q13: How do `TRIM`, `LTRIM`, and `RTRIM` handle specific characters, not just whitespace?
**Answer:**
By default, `TRIM` removes spaces. However, you can pass parameters to strip specific characters from the leading or trailing edges:
```sql
-- Removes leading zeroes from an account ID
SELECT LTRIM(account_id, '0') FROM transactions;
```

#### Q14: What is the performance danger of using `UPPER` or `LOWER` in a `WHERE` clause filter? How do you optimize it?
**Answer:**
Wrapping a filtered column in a function (e.g. `WHERE UPPER(email) = 'A@B.COM'`) prevents the Cost-Based Optimizer from using a standard B-Tree index on the `email` column.
* **Optimization:** Create a **Function-Based Index**:
  ```sql
  CREATE INDEX idx_emp_upper_email ON employees (UPPER(email));
  ```

#### Q15: How does `REPLACE` differ from `TRANSLATE` in Oracle SQL?
**Answer:**
* **`REPLACE(str, search, replace)`** looks for the exact, multi-character string match and replaces it as a whole unit.
* **`TRANSLATE(str, from_chars, to_chars)`** works character-by-character. It maps the 1st character of `from_chars` to the 1st of `to_chars`, the 2nd to the 2nd, etc.
```sql
-- Replace: returns 'ab-xyz'
SELECT REPLACE('ab-cd', 'cd', 'xyz') FROM dual;
-- Translate: replaces 'c' with 'x', 'd' with 'y' -> returns 'ab-xy'
SELECT TRANSLATE('ab-cd', 'cd', 'xyz') FROM dual;
```

---

### Part 4: Oracle Date Functions and Interval Arithmetic

#### Q16: Why should you avoid comparing dates using string comparisons like `WHERE hire_date = '2026-01-01'`?
**Answer:**
This relies on the database's session-level `NLS_DATE_FORMAT` parameter. If a client connects with a different locale setting (e.g. `DD-MON-RR`), the string format comparison will throw an `ORA-01861: literal does not match format string` error. Always use the `TO_DATE` function with an explicit format mask or use ANSI date literals:
```sql
WHERE hire_date = DATE '2026-01-01'
-- Or:
WHERE hire_date = TO_DATE('2026-01-01', 'YYYY-MM-DD')
```

#### Q17: What is the behavior of `TRUNC(date)`? How does it differ from `ROUND(date)`?
**Answer:**
* **`TRUNC(date)`** strips the time component, resetting the time to midnight (`00:00:00`). You can also truncate to the start of the month (`TRUNC(date, 'MM')`) or year (`TRUNC(date, 'YYYY')`).
* **`ROUND(date)`** rounds the date to the nearest unit. If the time is past noon (`12:00:00`), `ROUND(date)` rounds up to the next day. If past the 15th of the month, `ROUND(date, 'MM')` rounds up to the 1st of the next month.

#### Q18: How do you add exactly 3 hours to a timestamp in Oracle? Explain interval literals.
**Answer:**
You can add hours using interval literals:
```sql
SELECT SYSTIMESTAMP + INTERVAL '3' HOUR FROM dual;
-- Or add days and hours:
SELECT SYSTIMESTAMP + INTERVAL '1 03:00:00' DAY TO SECOND FROM dual;
```
Intervals are safer than raw number division (e.g. `+ 3/24`) because they preserve timestamp precision and handle timezone boundaries correctly.

#### Q19: Explain the difference between `DATE` and `TIMESTAMP` data types in Oracle.
**Answer:**
* **`DATE`** stores year, month, day, hour, minute, and second. It does not store fractional seconds or timezone offsets.
* **`TIMESTAMP`** stores fractional seconds (up to 9 decimal places). 
* **`TIMESTAMP WITH TIME ZONE`** stores fractional seconds plus timezone offsets, making it essential for international transactional systems.

#### Q20: How does `MONTHS_BETWEEN` handle partial months? Why is it useful for age calculation?
**Answer:**
`MONTHS_BETWEEN(date1, date2)` returns the number of months between two dates. If the days of the month are different, it calculates a fractional month based on a 31-day month scale. It is highly accurate for HR age and tenure calculations because it automatically handles leap years and variable month lengths.

---

### Part 5: Aggregations, Grouping, and Logical Branching

#### Q21: What is the strict execution order of a query containing `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `HAVING`, and `ORDER BY`?
**Answer:**
Oracle evaluates queries in this sequence:
1. **`FROM`** (loads base datasets and joins)
2. **`WHERE`** (filters individual rows *before* aggregation)
3. **`GROUP BY`** (aggregates rows into bucket groups)
4. **`HAVING`** (filters the aggregated bucket groups)
5. **`SELECT`** (projects columns and computes expressions)
6. **`ORDER BY`** (sorts the final output dataset)

#### Q22: Why can you not use a column alias defined in the `SELECT` list inside the `WHERE` clause?
**Answer:**
Because the `WHERE` clause executes **before** the `SELECT` projection list is processed (see Q21). When the SQL engine filters rows, the alias does not exist yet. You can only reference column aliases in the `ORDER BY` clause, which executes last.

#### Q23: Explain the difference between `COALESCE` and `NVL`. Which one is more efficient and why?
**Answer:**
* **`NVL(expr1, expr2)`** evaluates both expressions regardless of whether `expr1` is null.
* **`COALESCE(expr1, expr2, ... exprN)`** uses **short-circuit evaluation**. It evaluates arguments sequentially and stops at the first non-NULL value.
* **Performance:** `COALESCE` is more efficient if the secondary expressions involve heavy calculations, function calls, or subqueries, because those operations will be skipped if the first argument is not null.

#### Q24: What is `NVL2`? Write a query showing how it simplifies logic compared to `CASE`.
**Answer:**
`NVL2(expr1, value_if_not_null, value_if_null)` checks the first expression and returns the second argument if it is populated, or the third if it is empty.
```sql
-- Using NVL2:
SELECT NVL2(commission_pct, 'Has Commission', 'No Commission') FROM employees;

-- Equivalent CASE (more verbose):
SELECT CASE WHEN commission_pct IS NOT NULL THEN 'Has Commission' ELSE 'No Commission' END FROM employees;
```

#### Q25: How does `DECODE` differ from a `CASE` expression in Oracle?
**Answer:**
* **`DECODE`** is a proprietary Oracle-specific function. It only supports equality tests (`value = target`).
* **`CASE`** is an ANSI SQL standard expression. It supports full range evaluations, logical combinations (`AND`/`OR`), and inequality filters:
  ```sql
  -- CASE allows range scans (DECODE cannot do this):
  SELECT CASE WHEN salary > 10000 THEN 'High' ELSE 'Low' END FROM employees;
  ```
Always use `CASE` for readability, capability, and cross-database compatibility.

---

### Part 6: Practical Troubleshooting and Optimization Scenarios

#### Q26: You write `SELECT department_id, AVG(salary) FROM employees;`. Why does this throw an error? How do you fix it?
**Answer:**
It throws `ORA-00937: not a single-group group function`. 
You cannot mix scalar projections (`department_id`) and group aggregates (`AVG(salary)`) in the same query level without explicitly grouping the scalar columns.
* **The Fix:** Add a `GROUP BY` clause containing all non-aggregated columns:
  ```sql
  SELECT department_id, AVG(salary) FROM employees GROUP BY department_id;
  ```

#### Q27: How do you filter out aggregated groups? Write a query finding departments whose average salary exceeds $10,000.
**Answer:**
You must use the `HAVING` clause to filter aggregates (you cannot use `WHERE` because it filters rows before aggregation occurs):
```sql
SELECT department_id, AVG(salary) 
FROM employees 
GROUP BY department_id 
HAVING AVG(salary) > 10000;
```

#### Q28: How does the Oracle optimizer handle `COUNT(1)` vs `COUNT(*)`? Is one faster than the other?
**Answer:**
**They are identical in performance.** 
In legacy database engines, `COUNT(1)` was believed to be faster because `COUNT(*)` was thought to expand all columns. However, in modern Oracle database query optimizers, both expressions are compiled into the exact same execution plan node under the hood. The optimizer simply counts row counts in index leaf blocks or tables.

#### Q29: What is the behavior of a query when a check constraint fails during a single-row DML operation vs a PL/SQL batch DML operation?
**Answer:**
* **Single-row DML:** The database immediately throws an exception and rolls back that single statement.
* **Batch DML:** If running a standard multi-row insert, the entire batch statement fails and rolls back. To prevent this, you can run batch DML with error-logging capabilities using `DBMS_ERRLOG` or `SAVE EXCEPTIONS` in PL/SQL.

#### Q30: Why should you avoid storing formatted currency values (e.g. '$1,200.50') directly in database columns?
**Answer:**
Storing formatted strings instead of numeric data types (`NUMBER(15,2)`) prevents database arithmetic operations (like `SUM` or `AVG`), disables range indexes, wastes disk storage space, and creates localization bugs when formatting standards change (e.g., Euros vs Dollars). Always store raw numbers and format them in the application presentation layer or view output using `TO_CHAR(salary, '$99,999.00')`.
