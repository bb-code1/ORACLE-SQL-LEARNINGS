# Day 20 - Oracle SQL Execution Plans

Learned how to extract and evaluate execution plans in Oracle.

### Concept - EXPLAIN PLAN:
Shows the execution path chosen by the Cost-Based Optimizer (CBO).
`DBMS_XPLAN.DISPLAY` reads the system tables and formats the output.

```sql
EXPLAIN PLAN FOR
SELECT * FROM customers WHERE LOWER(email) = 'alice@email.com';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

### Concept - Optimizer Hints:
Hints pass instructions to the optimizer to override its default decisions. Use hints only as a last resort, 
as data changes can make them counterproductive.

```sql
-- Force the optimizer to use a specific index:
SELECT /*+ INDEX(c idx_cust_email_lower) */ * 
FROM customers c 
WHERE LOWER(email) = 'alice@email.com';
```

### Key Optimizer Terms:
1. **Full Table Scan (FTS)**: Reads every block in the table. Efficient for reading large portions of a table.
2. **Index Range Scan**: Scans an index for a range of values.
3. **Table Access by Index ROWID**: Retrieves specific rows from the table using row coordinates found in the index.
