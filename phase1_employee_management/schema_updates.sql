-- Day 2: Oracle Integrity Constraints
-- Concept: Integrity Constraints enforce business rules at the schema level.
-- Constraints prevent invalid data from being inserted or modified.
-- CONCEPT - FOREIGN KEY:
--   Enforces referential integrity between tables. The value in the child table column 
--   must match a value in the parent table primary key.

ALTER TABLE employees ADD CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD CONSTRAINT fk_emp_job FOREIGN KEY (job_id) REFERENCES jobs(job_id);
