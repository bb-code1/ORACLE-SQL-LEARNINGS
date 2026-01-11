# Phase 2: E-Commerce Analytics Database - Interview Practice Questions

This document contains 30 highly detailed, production-relevant interview questions and answers covering joins, subqueries, CTEs, set operators, analytic functions, and hierarchical queries in Oracle SQL.

---

### Part 1: Advanced Relational Joins and Join Optimization

#### Q1: What is the technical difference between an `INNER JOIN` and a `LEFT OUTER JOIN`? What is the performance impact when filtering on the outer table?
**Answer:**
* **`INNER JOIN`** returns rows only when the join condition is satisfied in both tables.
* **`LEFT OUTER JOIN`** returns all rows from the left table, plus matching rows from the right table. If no match exists, NULLs are returned for the right table columns.
* **Filtering Impact:** If you filter on the outer table in the `WHERE` clause (e.g. `WHERE right_table.status = 'ACTIVE'`), Oracle implicitly converts the query into an `INNER JOIN` because NULLs do not satisfy equality. To maintain the outer join behavior, you must place the filter in the `ON` clause instead:
  ```sql
  LEFT JOIN right_table ON (left.id = right.id AND right.status = 'ACTIVE')
  ```

#### Q2: What is a `CROSS JOIN`? Give a production scenario where generating a Cartesian product is useful.
**Answer:**
A `CROSS JOIN` returns the Cartesian product of two tables, where every row from the first table is paired with every row from the second table.
* **Scenario:** Generating a base grid for reporting. For example, if you want a dashboard to show sales for every product across every month (even months with 0 sales), you `CROSS JOIN` your `products` table and a `months` dimension table first. Then, you `LEFT JOIN` the transaction ledger to this base grid to compute sums.

#### Q3: How does a `SELF JOIN` work? Write a query finding all customers who share the same last name but have different customer IDs.
**Answer:**
A `SELF JOIN` joins a table to itself by creating two alias names for the table.
```sql
SELECT c1.customer_id, c1.first_name, c2.customer_id, c2.first_name, c1.last_name
FROM customers c1
JOIN customers c2 ON (c1.last_name = c2.last_name AND c1.customer_id < c2.customer_id);
```
*(Note: Using `<` instead of `!=` prevents duplicate mirror pairs like `(A, B)` and `(B, A)` from appearing in the results).*

#### Q4: Why is joining tables using non-key columns (columns without indexes or primary/foreign keys) a major performance risk?
**Answer:**
The Cost-Based Optimizer (CBO) cannot use index leaf block traversals to resolve the join. It is forced to fall back on heavy join methods like **Hash Joins** (which builds a hash table in PGA memory, causing temp tablespace paging if the table is large) or **Nested Loops with Full Table Scans**, causing high disk I/O and blocking other operations.

#### Q5: Explain the legacy Oracle join operator `(+)`. What is the limitation of this syntax compared to ANSI JOINs?
**Answer:**
* **Legacy Syntax:** `(+)` indicates the outer table in an outer join.
  ```sql
  SELECT c.name, o.order_id FROM customers c, orders o WHERE c.customer_id = o.customer_id (+);
  ```
* **Limitations:**
  1. It cannot be used with `FULL OUTER JOIN` directly (requires UNION blocks).
  2. You cannot mix `(+)` and ANSI join syntax in the same query block.
  3. Placing `(+)` on self-joins or nested outer joins is extremely prone to parsing errors. Always use modern ANSI SQL `LEFT/RIGHT/FULL JOIN` syntax.

---

### Part 2: Subqueries and Conditional Filtering

#### Q6: Explain the execution difference between a Correlated Subquery and a Non-Correlated Subquery.
**Answer:**
* **Non-Correlated Subquery:** Independent of the outer query. The SQL engine executes it once, caches the result, and feeds it to the outer query.
* **Correlated Subquery:** References columns from the outer query. The SQL engine must conceptually evaluate the subquery row-by-row for every candidate row processed by the outer query, which can cause severe performance degradation if the inner table lacks indexes.

#### Q7: Why is `EXISTS` generally faster than `IN` for subquery filters when the outer table is large?
**Answer:**
* **`IN`** evaluates the subquery first, creates an in-memory list, and then performs matching. It checks the entire inner dataset unless optimized.
* **`EXISTS`** uses **semi-join optimization**. It returns `TRUE` the millisecond it finds a single match, stopping further scans of the inner table blocks. If the inner table has an index, `EXISTS` is highly performant because it only needs to perform an index lookup.

#### Q8: When would you use a Scalar Subquery? What is the performance risk of putting a scalar subquery in the `SELECT` projection list?
**Answer:**
A Scalar Subquery returns exactly one row and one column.
* **Risk:** If placed in the `SELECT` list, the query engine evaluates it for every row returned by the outer query. If your outer query returns 100,000 rows, the scalar subquery will execute 100,000 times. Always replace select list scalar subqueries with a `LEFT JOIN` to allow block-level join operations.

#### Q9: What does the error `ORA-01427: single-row subquery returns more than one row` mean? How do you prevent it?
**Answer:**
This occurs when you use a scalar operator (like `=`, `<`, or `>`) with a subquery that returns multiple rows.
* **Prevention:** Change the operator to a multi-row operator (like `IN`, `ANY`, or `ALL`), or ensure the subquery uses a unique key lookup or limit clause:
  ```sql
  -- Error:
  WHERE salary = (SELECT salary FROM employees WHERE job_id = 'IT_PROG')
  -- Fixed:
  WHERE salary IN (SELECT salary FROM employees WHERE job_id = 'IT_PROG')
  ```

#### Q10: How does `ANY` differ from `ALL` when comparing values against a subquery list?
**Answer:**
* **`> ANY (list)`** means "greater than the minimum value in the list".
* **`> ALL (list)`** means "greater than the maximum value in the list".
```sql
-- Evaluates to > 10
WHERE price > ANY (10, 20, 30)
-- Evaluates to > 30
WHERE price > ALL (10, 20, 30)
```

---

### Part 3: Common Table Expressions (CTEs)

#### Q11: What is a Common Table Expression (CTE)? How does it improve readability over Inline Views?
**Answer:**
A CTE (defined using the `WITH` clause) acts as a temporary named result set within the execution scope of a single query.
* **Readability:** Inline views nest code inside the `FROM` clause, forcing developers to read from the inside out. CTEs let you define modular query blocks sequentially, letting you write the final query top-to-bottom.

#### Q12: How does the Oracle optimizer handle CTEs under the hood? Explain the `INLINE` and `MATERIALIZE` hints.
**Answer:**
By default, the CBO decides whether to inline the CTE (parse it as a subquery) or materialize it (write the results to a temporary table segment in PGA memory).
* **`/*+ INLINE */`** forces Oracle to compile the CTE inline, re-running its logic every time it is referenced.
* **`/*+ MATERIALIZE */`** forces Oracle to write the CTE results to a temp segment. This is highly beneficial if the CTE is referenced multiple times in the query, preventing recalculation of complex aggregations.

#### Q13: Write a basic template for a Chained CTE.
**Answer:**
```sql
WITH phase_1 AS (
    SELECT order_id, total_amount FROM orders WHERE status = 'DELIVERED'
),
phase_2 AS (
    SELECT order_id, quantity FROM order_items
)
SELECT p1.order_id, p1.total_amount, p2.quantity 
FROM phase_1 p1
JOIN phase_2 p2 ON p1.order_id = p2.order_id;
```

#### Q14: Explain how a Recursive CTE works. What are the Anchor and Recursive members?
**Answer:**
A Recursive CTE references its own name. It has two parts:
1. **Anchor Member:** The base query that runs first to seed the initial rows (does not reference the CTE).
2. **Recursive Member:** The query that references the CTE. It runs iteratively, joining the output of the previous step to the source tables until it returns zero rows.
These two parts are combined using a `UNION ALL`.

#### Q15: What is the safety mechanism to prevent infinite loops in Recursive CTEs?
**Answer:**
You must define a termination condition in the recursive join clause (e.g. `n < 10` or parent-child key links like `child_id = parent_id`). Oracle will automatically terminate execution if it detects a duplicate row in the recursive cycle, preventing infinite memory usage.

---

### Part 4: Window (Analytic) Functions

#### Q16: Explain the difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`.
**Answer:**
If three rows share the identical sort key value (e.g. salary = $5,000, ranks 2nd, 3rd, and 4th):
* **`ROW_NUMBER()`** assigns sequential, unique integers: `[2, 3, 4]`.
* **`RANK()`** assigns the same rank but skips the next rank numbers: `[2, 2, 2, 5]`.
* **`DENSE_RANK()`** assigns the same rank and does not skip the next rank numbers: `[2, 2, 2, 3]`.

#### Q17: What are `LAG()` and `LEAD()`? Give a real-world scenario for using them.
**Answer:**
* **`LAG(col, offset)`** fetches value from a preceding row in the window partitions.
* **`LEAD(col, offset)`** fetches value from a succeeding row in the window partitions.
* **Scenario:** Calculating month-over-month revenue growth. You use `LAG` to retrieve the previous month's revenue to calculate the percentage difference:
  ```sql
  SELECT month, revenue,
         revenue - LAG(revenue, 1) OVER (ORDER BY month) AS mom_diff
  FROM monthly_sales;
  ```

#### Q18: How do you calculate a moving average (e.g. 7-day average) using a window clause?
**Answer:**
Use the window physical frame clause `ROWS` or `RANGE`:
```sql
SELECT transaction_date, amount,
       AVG(amount) OVER (
           ORDER BY transaction_date 
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS moving_7day_avg
FROM transactions;
```

#### Q19: Why are analytic window functions faster than self-joining tables for calculations?
**Answer:**
A self-join requires Oracle to read the table blocks twice (one for each side of the join) and perform join mapping. Analytic functions calculate values using an in-memory sort window. Oracle reads the table blocks **only once**, sorts the data in the PGA cache, and computes the window values, reducing disk I/O.

#### Q20: What is the purpose of `FIRST_VALUE` and `LAST_VALUE`? What is the common trap with `LAST_VALUE`?
**Answer:**
* **`FIRST_VALUE(col)`** gets the first value in the sorted window.
* **`LAST_VALUE(col)`** gets the last value in the sorted window.
* **The Trap:** By default, the window frame is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. This means `LAST_VALUE` will only look at the rows processed *so far*, returning the current row's value rather than the true last value. To fix this, you must specify `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`.

---

### Part 5: Set Operators

#### Q21: What is the mechanical difference between `UNION` and `UNION ALL`? Which is faster and why?
**Answer:**
* **`UNION`** combines rows and executes a **Sort Unique** operation to remove duplicates.
* **`UNION ALL`** combines rows without sorting or checking for duplicates.
* **Performance:** `UNION ALL` is significantly faster because it bypasses the CPU-heavy sorting phase and does not write to the temporary tablespace. Always use `UNION ALL` unless you explicitly require duplicate removal.

#### Q22: What are the conditions for using Set Operators (`UNION`, `INTERSECT`, `MINUS`) on two queries?
**Answer:**
1. Both queries must select the **same number of columns**.
2. The columns in the matching positions must have **compatible data types** (e.g. matching `NUMBER` with `NUMBER`, `VARCHAR2` with `VARCHAR2`).

#### Q23: How does `MINUS` work? How does it differ from a `LEFT JOIN ... WHERE right.id IS NULL`?
**Answer:**
* **`MINUS`** returns unique rows from the first query that are not present in the second query. It performs a sort operation to find differences.
* **`LEFT JOIN`** approach is more performant on large tables because it can utilize join indexes rather than sorting the entire datasets in PGA memory.

#### Q24: How does `INTERSECT` handle duplicate rows in the matching datasets?
**Answer:**
`INTERSECT` returns only unique rows common to both queries. If multiple identical rows exist in both tables, `INTERSECT` returns only a single instance of that row.

#### Q25: Can you use `ORDER BY` in individual queries combined by Set Operators?
**Answer:**
**No.** You can only place a single `ORDER BY` clause at the very end of the final query. This sorts the combined result set.

---

### Part 6: Hierarchical Queries

#### Q26: What is a Hierarchical Query? Explain the `START WITH` and `CONNECT BY` clauses.
**Answer:**
A hierarchical query processes tree-structured parent-child relations (like employee-manager trees).
* **`START WITH`** specifies the root node(s) of the tree.
* **`CONNECT BY`** defines the relationship between parent and child rows.
  ```sql
  CONNECT BY PRIOR employee_id = manager_id
  ```
This tells Oracle: "To find the next row, find where the manager ID equals the parent employee ID."

#### Q27: What is the purpose of the `PRIOR` keyword? How does moving `PRIOR` change the tree traversal direction?
**Answer:**
`PRIOR` refers to the parent row's evaluated value.
* **Top-Down Traversal:** `CONNECT BY PRIOR id = parent_id` (travels from manager to employee).
* **Bottom-Up Traversal:** `CONNECT BY id = PRIOR parent_id` (travels from employee to manager).

#### Q28: How do you detect and prevent infinite loops in hierarchical data?
**Answer:**
If the data has cyclic references (e.g., A reports to B, B reports to C, C reports to A), Oracle will fail with `ORA-01436: CONNECT BY loop in user data`.
* **Fix:** Add the `NOCYCLE` keyword and query the `CONNECT_BY_ISCYCLE` pseudocolumn to isolate loops:
  ```sql
  CONNECT BY NOCYCLE PRIOR employee_id = manager_id
  ```

#### Q29: What is `SYS_CONNECT_BY_PATH`? What is the formatting danger of using it in production?
**Answer:**
`SYS_CONNECT_BY_PATH(column, char)` builds a delimited string representing the path from root to leaf node.
* **Danger:** If the delimiter character exists inside the column values (e.g. path using `/` on text containing `/`), the function will crash with `ORA-30004: when using SYS_CONNECT_BY_PATH, helper cannot overlap`. Always choose a safe delimiter character (like `|` or `~`).

#### Q30: What is `CONNECT_BY_ROOT`? How is it useful for mapping leaf nodes to parent nodes?
**Answer:**
`CONNECT_BY_ROOT column` returns the value of the column from the root row of the current hierarchy branch. It allows leaf rows to display their ultimate top-level parent in reports without writing self-joins.
