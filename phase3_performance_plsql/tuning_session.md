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
