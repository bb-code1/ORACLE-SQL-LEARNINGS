-- Day 26: Seeding Capstone accounts

INSERT INTO accounts (account_number, customer_name, account_type, balance) VALUES ('ACC_1001', 'Alice Vance', 'CHECKING', 2500.00);
INSERT INTO accounts (account_number, customer_name, account_type, balance) VALUES ('ACC_1002', 'Bob Vance', 'SAVINGS', 15000.00);
INSERT INTO accounts (account_number, customer_name, account_type, balance) VALUES ('ACC_1003', 'Charlie Day', 'CHECKING', 120.00);
COMMIT;
