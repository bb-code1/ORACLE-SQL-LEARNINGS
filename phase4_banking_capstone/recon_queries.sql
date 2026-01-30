-- Day 30: Banking Reconciliation queries
-- Concept: Reconciling ledger items using Common Table Expressions and aggregate functions.
-- This validates that current balances equal starting balances plus the net sum of transactions.

WITH tx_summary AS (
    SELECT account_number,
           SUM(CASE 
                 WHEN transaction_type IN ('DEPOSIT', 'TRANSFER_IN') THEN amount 
                 ELSE -amount 
               END) AS net_tx_amount
    FROM transactions
    GROUP BY account_number
)
SELECT a.account_number, a.customer_name, a.balance AS current_balance,
       NVL(t.net_tx_amount, 0) AS net_tx_balance,
       (a.balance - NVL(t.net_tx_amount, 0)) AS initial_starting_balance
FROM accounts a
LEFT JOIN tx_summary t ON a.account_number = t.account_number;

-- Day 30: Financial Transaction Auditing using Analytics
-- Concept: Analytics functions identify deviations from average transaction amounts.

SELECT transaction_id, account_number, amount, transaction_date,
       AVG(amount) OVER (PARTITION BY account_number) AS avg_account_tx,
       amount - AVG(amount) OVER (PARTITION BY account_number) AS deviation_from_avg
FROM transactions
WHERE amount > 500;
