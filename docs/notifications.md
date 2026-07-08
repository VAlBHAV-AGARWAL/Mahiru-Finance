# Notifications

## Types

| Type | Trigger | Example |
|------|---------|---------|
| `due_reminder` | Recurring transaction approaching | "Rent due in 3 days" |
| `budget_warning` | Budget limit crossed threshold | "Groceries at 85% of monthly limit" |
| `tax_alert` | Tax-related date or limit | "80C limit unused — 3 months left" |
| `system_info` | General information | "Reconciliation completed" |

## Features

1. **Bell icon** — shows unread count in nav
2. **Notification list** — `/notifications` page with read/unread
3. **Click to action** — clicking a notification navigates to relevant page
4. **Dismiss** — mark as read or delete
5. **Future: Push** — browser notifications via Service Worker
6. **Future: Telegram** — notification via Telegram bot

## Delivery (Future)

| Channel | For |
|---------|-----|
| In-app | All notifications |
| Email | Daily/weekly digest |
| Telegram | Urgent: missed EMI, low balance |
| SMS | Critical: large withdrawal, password change |
