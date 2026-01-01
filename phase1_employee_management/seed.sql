-- Day 1: Seeding reference data
-- Concept: Data Manipulation Language (DML) - INSERT Statement
-- DML statements are used to manage data within tables. Unlike DDL, DML modifications 
-- are transactional and require a COMMIT to be permanently written to disk.
-- CONCEPT - COMMIT:
--   COMMIT saves all changes made since the start of the transaction, making them visible to other sessions.
--   Until a COMMIT is executed, changes can be undone using ROLLBACK.

INSERT INTO departments (department_name, location) VALUES ('Executive', 'New York');
INSERT INTO departments (department_name, location) VALUES ('IT', 'San Francisco');
INSERT INTO departments (department_name, location) VALUES ('Sales', 'Boston');
INSERT INTO departments (department_name, location) VALUES ('Finance', 'Chicago');

INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('AD_PRES', 'President', 20000, 40000);
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('IT_PROG', 'Programmer', 5000, 15000);
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('SA_REP', 'Sales Representative', 4000, 12000);
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('FI_MGR', 'Finance Manager', 8000, 18000);

COMMIT;

-- Day 1: Oracle Proprietary DML - INSERT ALL
-- Concept: INSERT ALL allows a developer to perform multiple INSERT operations in a single statement.
-- It is highly efficient in Oracle because it reduces database engine context-switching overhead.
-- CONCEPT - DUAL Table:
--   DUAL is a special one-row, one-column table present by default in Oracle. It is used to evaluate 
--   functions or execute expressions that do not reference real tables.

INSERT ALL
  INTO employees (first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
    VALUES ('Steven', 'King', 'steven.king@company.com', '515.123.4567', TO_DATE('2020-06-17', 'YYYY-MM-DD'), 'AD_PRES', 24000, NULL, NULL, 1)
  INTO employees (first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
    VALUES ('Alexander', 'Hunold', 'alex.hunold@company.com', '590.423.4567', TO_DATE('2023-01-03', 'YYYY-MM-DD'), 'IT_PROG', 9000, NULL, 1, 2)
  INTO employees (first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
    VALUES ('David', 'Austin', 'david.austin@company.com', '590.423.4568', TO_DATE('2023-05-20', 'YYYY-MM-DD'), 'IT_PROG', 4800, NULL, 2, 2)
  INTO employees (first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
    VALUES ('John', 'Russell', 'john.russell@company.com', '011.44.1344.429268', TO_DATE('2024-03-10', 'YYYY-MM-DD'), 'SA_REP', 14000, 0.4, 1, 3)
  INTO employees (first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
    VALUES ('Karen', 'Partners', 'karen.partners@company.com', '011.44.1344.467268', TO_DATE('2025-01-05', 'YYYY-MM-DD'), 'SA_REP', 13500, 0.3, 1, 3)
SELECT * FROM DUAL;

COMMIT;
