# Bank Reconciliation

## Model

| Table | Purpose |
|-------|---------|
| `bank_statements` | Uploaded file metadata (account, period, filename) |
| `statement_rows` | Individual statement lines (date, desc, withdrawal, deposit, balance) |
| `statement_rows.matched_journal_id` | Links to `transaction_journals` when reconciled |

## Workflow

1. **Upload** — user uploads PDF/CSV/XLS statement
2. **Parse** — extract rows (India-specific: HDFC, SBI, ICICI formats)
3. **Match** — auto-suggest matches with existing transactions by amount + date ± tolerance
4. **Review** — user confirms or overrides matches
5. **Reconcile** — matched rows are locked; unmatched rows can create new journals

## India-specific Parsing

Indian bank statements vary significantly:
- **HDFC**: password-protected PDF, specific column order
- **SBI**: passbook-style with opening/closing balance
- **ICICI**: CSV export with transaction ID
- **Paytm / PhonePe**: UPI-specific formats

## Features

1. Drag-and-drop file upload
2. Side-by-side comparison (statement vs app transactions)
3. Auto-match suggestions with confidence score
4. Manual match / create new transaction
5. Reconciliation report (difference, missing entries)
6. Period-end balance verification
