-- Day 2: Testing constraint safety
-- Concept: Oracle error codes are generated when database validations fail.
-- Common codes include:
--   ORA-02291: Integrity constraint violated - parent key not found (Foreign Key error)
--   ORA-02290: Integrity constraint violated - check constraint error

-- Attempting an insert with an invalid department_id (will fail with ORA-02291):
-- INSERT INTO employees (last_name, email, job_id, salary, department_id)
-- VALUES ('Tester', 'test@test.com', 'IT_PROG', 4000, 999);
