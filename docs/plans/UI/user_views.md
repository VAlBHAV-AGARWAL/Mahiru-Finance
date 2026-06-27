# UI Design: At-a-Glance Dashboard Views

This document defines what a user (both Admin and Member) will see immediately upon logging into the application, focusing on critical metrics and quick insights.

---

## 👑 The Admin "At-a-Glance" View

The Family Head or Business Manager needs a comprehensive macro-view of the entire wealth portfolio:

1.  **Portfolio Balance Summary:**
    *   `Net Worth` (Total Assets minus Liabilities).
    *   `Liquid Cash` (Available money in savings accounts + wallets).
    *   `Committed Liabilities` (Total outstanding bank and family loans + credit card dues).
2.  **CA Alert Box (The Tax Due Stat):**
    *   A bold widget displaying: *"Estimated Tax Liability for FY: ₹XX,XXX"*
    *   Sub-items showing: *Crypto Tax Due (₹X,XXX)*, *FD Interest Tax (₹X,XXX)*, *TDS Credits Claimed (₹X,XXX)*.
3.  **Family Member Allocations:**
    *   A clean donut chart showing which family member is holding or spending how much cash.

---

## 👥 The Member "At-a-Glance" View

Standard family members should have a simplified view focused on their own spending limit:

1.  **Individual Cash Balance:**
    *   `My Wallets & Accounts` (Only shows the accounts owned by this specific member).
    *   `My Credit Dues` (Their credit card limit vs. current spend).
2.  **Daily Allowance / Budget Check:**
    *   `Monthly Allowance Left` (A progress bar showing how much of their budget remains).
    *   `Recent Purchases` (List of transactions logged by them).
3.  **Quick Add Section:**
    *   A prominent input box: *"Log what you just spent"* with shortcuts for category selections.
