# Compliance: Multi-User Access & Role Permissions Design

This document details the security model, user role mappings, and granular access control policies to support multiple family members or business partners in a single database.

---

## 👥 User Roles & Permissions Matrix

We support three roles with distinct access policies:

| Module / Action | `admin` (Family Head / Owner) | `member` (Family Member) | `partner` (Business Partner) |
| :--- | :--- | :--- | :--- |
| **Personal Accounts** | View / Add / Edit / Delete | View / Add / Edit (Own Only) | View / Add / Edit (Own Only) |
| **Joint / Shared Accounts** | View / Add / Edit / Delete | View / Log Transactions | N/A (Blocked) |
| **Family Net Worth Charts** | Full View (Aggregated) | Hidden (Restricted) | Hidden (Restricted) |
| **Taxes & TDS Dashboard** | Full View (All Members) | View (Own Only) | View (Own Business Share) |
| **Business Capital Ledger** | Full View | Hidden (Restricted) | View / Log Contributions |
| **System Settings (Toggles)** | Edit (Full Access) | Hidden (No Access) | Hidden (No Access) |

---

## 🔐 Access Control Logic (API & Database Level)

To secure SQLite rows, all data tables (`accounts`, `transactions`, `loans`, `investments`) contain a `user_id` column.

### 1. Simple Select Filter
When fetching data for a standard `member` user, query statements must append the user filter:
```sql
-- Standard User Query
SELECT * FROM transactions WHERE user_id = ?;
```
For `admin` users:
```sql
-- Admin Query (Consolidated)
SELECT t.*, u.username 
FROM transactions t 
JOIN users u ON t.user_id = u.id;
```

### 2. Joint Account Rules
For shared assets (e.g. Joint Bank Accounts or Shared Properties), we implement a shared access table:
```sql
CREATE TABLE IF NOT EXISTS shared_accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  permission_level TEXT DEFAULT 'read' CHECK(permission_level IN ('read', 'write')),
  FOREIGN KEY (account_id) REFERENCES accounts(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

If a user tries to write a transaction to an account, the system validates that they own the account OR have write access to it in the `shared_accounts` table:
```javascript
// lib/security.js
async function hasWriteAccess(userId, accountId, dbInstance) {
  const account = await dbInstance.queryOne("SELECT user_id FROM accounts WHERE id = ?", [accountId]);
  if (account && account.user_id === userId) return true;

  const shared = await dbInstance.queryOne(
    "SELECT id FROM shared_accounts WHERE account_id = ? AND user_id = ? AND permission_level = 'write'",
    [accountId, userId]
  );
  return !!shared;
}
```
