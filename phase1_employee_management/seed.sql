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
