-- Day 29: PL/SQL Capstone Banking Package
-- Concept: Encapsulating critical financial transactions inside a single package interface

CREATE OR REPLACE PACKAGE pkg_banking AS
    PROCEDURE sp_deposit(p_acc VARCHAR2, p_amt NUMBER, p_desc VARCHAR2);
    PROCEDURE sp_withdraw(p_acc VARCHAR2, p_amt NUMBER, p_desc VARCHAR2);
    PROCEDURE sp_transfer(p_from VARCHAR2, p_to VARCHAR2, p_amt NUMBER, p_desc VARCHAR2);
END pkg_banking;
/
