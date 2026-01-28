-- Day 28: Database Security (Grants and Roles)
-- Concept: Roles group privileges, which can then be granted to users.
-- This simplifies user administration and security management.
--   System Privileges: Grant authority to perform schema operations (e.g., CREATE TABLE).
--   Object Privileges: Grant authority to access specific database objects (e.g., SELECT on a table).

-- Simulation of security setups:
-- CREATE ROLE teller_role;
-- GRANT SELECT, INSERT ON transactions TO teller_role;
-- GRANT SELECT, UPDATE(balance) ON accounts TO teller_role;

-- Day 28: Row-Level Security (RLS) / Virtual Private Database (VPD)
-- Concept: VPD (Virtual Private Database) automatically appends a WHERE clause predicate 
-- to queries at runtime based on security rules.
-- This restricts user access to specific rows (e.g. customers can only see their own accounts) 
-- without modifying application code.
-- Implemented using Oracle's DBMS_RLS package.
