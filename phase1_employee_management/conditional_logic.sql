-- Day 5: Null Substitution functions
-- Concept: Null handling functions replace NULL with alternative expressions.
-- CONCEPT - NVL vs COALESCE:
--   NVL(arg1, arg2): Takes only two arguments. Evaluates *both* arguments, even if arg1 is NOT null.
--   COALESCE(arg1, arg2, ...): ANSI standard. Evaluates arguments lazily (short-circuit evaluation).
--                              It stops at the first non-null value.

SELECT first_name, last_name, salary,
       NVL(commission_pct, 0) AS raw_commission,
       salary + (salary * COALESCE(commission_pct, 0)) AS total_compensation
FROM employees;
