# Phase 2 - E-Commerce Analytics Database

Completed relational join operations and analytic reporting.

### Core Concepts Implemented:
1. **Joins**: INNER, LEFT, CROSS, and SELF-JOINs.
2. **Subqueries**: Evaluated single-row, multi-row, and correlated subqueries (`EXISTS`).
3. **CTEs**: Replaced nested queries with WITH blocks, writing recursive paths.
4. **Window Functions**: Ranked records (`DENSE_RANK`) and calculated intervals (`LAG`/`LEAD`).
5. **Hierarchies**: Mapped parent-child trees using CONNECT BY.

---

## Technical Interview Q&A (Real-World Experience)

#### Q1: You write a query using `WHERE column NOT IN (SELECT other_column FROM table)`. If the subquery returns even a single `NULL` value, what happens to the outer query results? Why?
**Answer:**
The outer query will return **zero rows**. 
In SQL's three-valued logic, `NULL` represents an "unknown" state. 
When evaluating `NOT IN (1, 2, NULL)`, SQL expands this to:
`column != 1 AND column != 2 AND column != NULL`

Since any comparison with `NULL` (like `column != NULL`) yields `UNKNOWN` rather than `TRUE`, the entire `AND` chain collapses to `UNKNOWN` or `FALSE`. Consequently, no row can satisfy the `WHERE` clause. 
* **The Fix:** Either filter out nulls in the subquery:
  ```sql
  WHERE column NOT IN (SELECT other_column FROM table WHERE other_column IS NOT NULL)
  ```
  Or rewrite the query using a correlated subquery with `NOT EXISTS`, which handles nulls safely.

#### Q2: When should you use a Hierarchical query (`CONNECT BY`) vs an ANSI Recursive CTE?
**Answer:**
* **`CONNECT BY` (Oracle Proprietary):** Use this for standard parent-child tree layouts (like organizational charts or product categories). It is highly optimized in the Oracle kernel, parses faster, and provides built-in pseudocolumns like `LEVEL`, `PRIOR`, and `SYS_CONNECT_BY_PATH` out-of-the-box.
* **ANSI Recursive CTE (`WITH` clause):** Use this when writing portable queries that must run on other databases (e.g. PostgreSQL, SQL Server). Also, recursive CTEs are necessary for complex graph algorithms (like finding the shortest path or cycle detection in network routing tables) where a row has multiple parents, which `CONNECT BY` cannot handle easily without throwing loop errors.

#### Q3: What is the practical difference between using `ROWS` and `RANGE` window frames in analytic queries?
**Answer:**
* **`RANGE` (Default):** Groups duplicate sorting values together. If you calculate a running total of transaction amounts ordered by transaction date (`RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`), and three transactions occur on the same day, `RANGE` adds all three together and displays the identical summed value for all three rows.
* **`ROWS`:** Evaluates physical rows chronologically, ignoring duplicate values in the sort key. It calculates the running total row-by-row, which is essential for audit ledgers where each transaction must display the exact chronological running balance.
