# Phase 4 - Banking Capstone Project

This project implements a secure, auditable, and performant Banking Transaction ledger.

### Schema Blueprint:
- **`accounts`**: Stores balances and statuses (ACTIVE, SUSPENDED, CLOSED).
- **`transactions`**: Records individual transaction ledger items.
- **`audit_log`**: Captures all balance changes for compliance auditing.

### Advanced Scripts:
- **`bulk_processing.sql`**: Production-grade bulk operations using a cursor loop with a `LIMIT` clause to protect PGA memory, and `FORALL ... SAVE EXCEPTIONS` to handle bulk update failures gracefully.
- **`pipelined_analytics.sql`**: Pipelined table function (`fn_detect_high_risk_txns`) that streams transaction logs incrementally to SQL queries using custom object types.
