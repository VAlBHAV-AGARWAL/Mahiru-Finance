# Planning: Partnership & Business Ledger Design

This document details the tracking, drawing logs, capital accounts, and expense categorization logic for Business Owners and Partnerships.

---

## 🎯 Target Business Features

1. **Expense Deductibility (For Solo Proprietors / Business Owners):**
   - Tag transactions under a `tax_head`: `personal` vs `business`.
   - Tax-deductible business expenses (e.g., Office Rent, Server Hosting, Client Dinners) are tracked separately to deduct from business revenues for income tax calculations.
2. **Partnership Capital Ledger:**
   - Multiple partners can contribute capital.
   - Profit and loss are automatically split based on configured **Profit-Sharing Ratios**.
3. **Partner Drawings Tracker:**
   - Track personal cash withdrawals (**Drawings**) by partners from the business entity.
   - Balance drawings against partner capital contributions to show net ownership equity.

---

## 💾 Database Schema Additions

```sql
-- Track business partners
CREATE TABLE IF NOT EXISTS partners (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  profit_share_ratio REAL NOT NULL, -- e.g. 0.50 for 50%
  email TEXT,
  phone TEXT
);

-- Track partner capital accounts and drawings
CREATE TABLE IF NOT EXISTS partner_ledger (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  partner_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  type TEXT CHECK(type IN ('capital_contribution', 'drawing', 'profit_share', 'loss_share')),
  amount REAL NOT NULL,
  description TEXT,
  account_id INTEGER, -- Cash/bank account affected
  FOREIGN KEY (partner_id) REFERENCES partners(id),
  FOREIGN KEY (account_id) REFERENCES accounts(id)
);
```

---

## ⚙️ Partnership Logic (JavaScript API Design)

```javascript
// lib/businessEngine.js

/**
 * Distributes profit/loss among partners based on profit-sharing ratio
 */
async function distributeNetProfit(netProfit, date, dbInstance) {
  const partners = await dbInstance.queryAll("SELECT * FROM partners");
  
  for (const partner of partners) {
    const shareAmount = parseFloat((netProfit * partner.profit_share_ratio).toFixed(2));
    const type = netProfit >= 0 ? 'profit_share' : 'loss_share';
    
    await dbInstance.run(
      "INSERT INTO partner_ledger (partner_id, date, type, amount, description) VALUES (?, ?, ?, ?, ?)",
      [partner.id, date, type, Math.abs(shareAmount), `Automated profit share distribution`]
    );
  }
}

/**
 * Gets a summary of partner capital and drawings
 */
async function getPartnerSummary(partnerId, dbInstance) {
  const ledgerEntries = await dbInstance.queryAll(
    "SELECT type, SUM(amount) as total FROM partner_ledger WHERE partner_id = ? GROUP BY type",
    [partnerId]
  );
  
  let netCapital = 0;
  let totalDrawings = 0;

  ledgerEntries.forEach(entry => {
    if (entry.type === 'capital_contribution' || entry.type === 'profit_share') {
      netCapital += entry.total;
    } else if (entry.type === 'drawing' || entry.type === 'loss_share') {
      netCapital -= entry.total;
      if (entry.type === 'drawing') {
        totalDrawings = entry.total;
      }
    }
  });

  return { netCapital, totalDrawings };
}
```
