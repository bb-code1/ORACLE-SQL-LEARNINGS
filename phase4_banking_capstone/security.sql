-- Day 28: Database Security (Grants and Roles)
-- Concept: Roles group privileges, which can then be granted to users.
-- This simplifies user administration and security management.
--   System Privileges: Grant authority to perform schema operations (e.g., CREATE TABLE).
--   Object Privileges: Grant authority to access specific database objects (e.g., SELECT on a table).

-- Simulation of security setups:
-- CREATE ROLE teller_role;
-- GRANT SELECT, INSERT ON transactions TO teller_role;
-- GRANT SELECT, UPDATE(balance) ON accounts TO teller_role;
