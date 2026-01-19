-- Day 19: Sequences and Identity columns
-- Concept: Sequences generate unique, sequential integers.
--   CACHE N: Pre-allocates N numbers in memory to improve performance. 
--            If the database crashes, unused cached values are lost, creating gaps in sequences.
--   NOCACHE: Avoids gaps, but requires a disk write for every sequence value retrieved.

CREATE SEQUENCE seq_audit_log_id
    START WITH 100
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
