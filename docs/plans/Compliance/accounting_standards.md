# Compliance: Accounting Standards & Double-Entry Design

This document outlines how Mahiru Finance OS implements traditional Double-Entry Bookkeeping principles in compliance with General Accounting Standards (AS) and Indian Accounting Standards (Ind AS) for small entities.

---

## ⚖️ Double-Entry System (Dual Aspect Concept)

Every financial transaction has a dual effect—a debit in one account must be offset by a matching credit in another account. This keeps the fundamental accounting equation balanced:

$$\text{Assets} = \text{Liabilities} + \text{Equity}$$

### Database Representation:
While the database has a simplified `transactions` ledger for quick logging, under the hood it tracks the source and destination ledger accounts:
*   **Income transaction:** Debit the Bank/Cash Account (Asset Increases), Credit the Income Account (Equity Increases).
*   **Expense transaction:** Credit the Bank/Cash Account (Asset Decreases), Debit the Expense Account (Equity Decreases).
*   **Asset Purchase (e.g. Land/Gold):** Credit the Bank Account (Asset Decreases), Debit the Gold/Property Asset Account (Asset Increases).
*   **Loan Borrowed:** Debit the Bank Account (Asset Increases), Credit the Loan Liability Account (Liability Increases).

---

## 📘 AS & Ind AS Principles Implemented

1.  **AS 1 / Ind AS 1: Presentation of Financial Statements**
    *   Ensures clean generation of **Balance Sheets** and **Profit & Loss (P&L) Accounts** structured under standard assets, liabilities, incomes, and expenses.
2.  **AS 10 / Ind AS 16: Property, Plant and Equipment (PPE)**
    *   Governs land and physical assets tracking. Allows inputting the purchase cost and logging subsequent property valuation adjustments (appreciation/depreciation) under separate asset adjustment ledgers.
3.  **AS 26 / Ind AS 38: Intangible Assets & Financial Instruments**
    *   Ensures stock investments and mutual funds are recorded at **Amortized Cost** (purchase price) but display **Fair Market Value** (live tickers) side-by-side on the dashboard.
4.  **Accrual Concept (AS 9 / Ind AS 115):**
    *   Taxes and loans are accounted for when they accrue. For example, interest on FDs is tracked when it is accrued (quarterly/annually) rather than only when the FD matures.

---

## 📑 Core Financial Statements Generated

*   **Trial Balance:** Verifies that Total Debits = Total Credits across all ledgers.
*   **Income Statement (P&L):** Computes Total Income - Total Expenses to show Net Personal/Business Savings.
*   **Balance Sheet:** Displays the financial position (Cash + Investments + Land vs. Loans + Dues + Equity) at any specific date.
