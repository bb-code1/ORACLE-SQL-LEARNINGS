-- Day 2: Oracle Integrity Constraints
-- Concept: Integrity Constraints enforce business rules at the schema level.
-- Constraints prevent invalid data from being inserted or modified.
-- CONCEPT - FOREIGN KEY:
--   Enforces referential integrity between tables. The value in the child table column 
--   must match a value in the parent table primary key.

ALTER TABLE employees ADD CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD CONSTRAINT fk_emp_job FOREIGN KEY (job_id) REFERENCES jobs(job_id);

-- Day 2: Character vs Byte Semantics in VARCHAR2
-- Concept: VARCHAR2 in Oracle can store character limits as either BYTE or CHAR semantics.
--   VARCHAR2(50 BYTE): Can store up to 50 bytes of data. Multi-byte characters (like Unicode) 
--                      will consume more than 1 byte, leading to premature overflow errors.
--   VARCHAR2(50 CHAR): Allocates enough storage to support exactly 50 characters, regardless of byte length.

-- Adding Check constraints and Self-referencing constraint:
ALTER TABLE employees ADD CONSTRAINT chk_emp_salary CHECK (salary > 0);
ALTER TABLE employees ADD CONSTRAINT chk_emp_email UNIQUE (email);
ALTER TABLE employees ADD CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
