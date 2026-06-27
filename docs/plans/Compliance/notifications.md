# Compliance: Notifications & Alert System Design

This document details the scheduling, event triggers, and UI delivery methods for user notifications (payment reminders, budget warnings, tax due dates).

---

## 🔔 Notification Categories

1.  **Bill & EMI Due Reminders:**
    *   **Trigger:** Checked every morning at 8:00 AM via cron job (`server.js`).
    *   **Alert threshold:** Triggers if an active `recurring_item` or `loan_emi` is due in 3 days or less.
2.  **Budget Warning Alerts:**
    *   **Trigger:** Logged immediately on transaction insert.
    *   **Alert threshold:** Triggers if a category spend exceeds 80% or 100% of the user's allocated monthly budget.
3.  **Tax Deadlines & Alerts:**
    *   **Trigger:** Generates warning notices for Indian tax cycles (e.g. Advance Tax installment dates: June 15, Sep 15, Dec 15, March 15; Income Tax Return filing deadline: July 31).

---

## 💾 Database Schema

```sql
-- Track system generated notifications
CREATE TABLE IF NOT EXISTS notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  type TEXT CHECK(type IN ('due_reminder', 'budget_warning', 'tax_alert', 'system_info')),
  message TEXT NOT NULL,
  associated_date TEXT, -- Due date or transaction date
  is_read INTEGER DEFAULT 0, -- 0 = Unread, 1 = Read
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## ⚙️ Cron reminder check logic

```javascript
// lib/cronReminders.js
import db from './db';

export async function checkDueReminders() {
  const dateToday = new Date();
  const dateStr = dateToday.toISOString().split('T')[0];

  // Fetch active recurring bills due in the next 3 days
  const dueBills = await db.queryAll(
    `SELECT r.*, u.username 
     FROM recurring_items r
     JOIN users u ON r.user_id = u.id
     WHERE r.is_active = 1 
       AND r.next_due_date IS NOT NULL 
       AND (julianday(r.next_due_date) - julianday(?)) BETWEEN 0 AND 3`,
    [dateStr]
  );

  for (const bill of dueBills) {
    // Check if notification already exists for this due date to avoid duplicates
    const existing = await db.queryOne(
      "SELECT id FROM notifications WHERE user_id = ? AND associated_date = ? AND message LIKE ?",
      [bill.user_id, bill.next_due_date, `%${bill.label}%`]
    );

    if (!existing) {
      await db.run(
        `INSERT INTO notifications (user_id, type, message, associated_date) 
         VALUES (?, 'due_reminder', ?, ?)`,
        [
          bill.user_id, 
          `🚨 Reminder: Your bill "${bill.label}" for ₹${bill.amount} is due on ${bill.next_due_date}.`, 
          bill.next_due_date
        ]
      );
    }
  }
}
```

---

## 🖥️ UI Delivery Methods

*   **Dashboard Alert Box:** Displays a notification badge in the top navigation header. Clicking it opens a dropdown list of recent unread alerts.
*   **Telegram Push Alerts:** If the user has linked their Telegram ID, the server can send a direct Telegram message (e.g. *"Hello Vaibhav, your SBI Home Loan EMI of ₹24,500 is due in 3 days."*) to them directly.
