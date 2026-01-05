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

-- Day 5: Conditional Expressions (DECODE vs CASE)
-- Concept: 
--   DECODE: Legacy Oracle proprietary function. It performs value comparisons equivalent to simple IF-THEN-ELSE.
--   CASE: ANSI SQL compliant. More powerful. Supports compound range conditions (Searched CASE).

SELECT first_name, last_name, job_id, salary,
       DECODE(job_id, 'AD_PRES', 'Executive Director', 
                      'IT_PROG', 'System Developer', 
                      'SA_REP',  'Commercial Sales', 
                                 'Administrative Staff') AS job_title_translation,
       CASE 
           WHEN salary >= 15000 THEN 'Grade A'
           WHEN salary BETWEEN 8000 AND 14999 THEN 'Grade B'
           ELSE 'Grade C'
       END AS salary_grade
FROM employees;
