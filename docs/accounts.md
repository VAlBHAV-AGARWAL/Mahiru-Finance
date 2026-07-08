# Accounts & Transactions

## Account Types

Based on `account_types` lookup:
| Type | Examples |
|------|----------|
| Asset | Savings, cash, wallet, bank account |
| Expense | Groceries, rent, utilities, dining |
| Revenue | Salary, freelance, interest, dividends |
| Liability | Credit card, loan, borrowings |
| Equity | Opening balance, retained earnings |

## Supported Account Fields

- Bank-specific: `iban`, `account_number`, `ifsc_code`
- Credit cards: `credit_limit`, `billing_date`, `due_date`
- Virtual balance for investment accounts
- Soft-delete with `deleted_at`

## Transaction Types

| Type | Behavior |
|------|----------|
| Withdrawal | Asset → Expense (money spent) |
| Deposit | Revenue → Asset (money received) |
| Transfer | Asset → Asset (moving money between accounts) |
| Opening Balance | Initial balance setup |
| Reconciliation | Balance correction after bank match |

## Double-Entry Design

Each logical transaction has:
1. One `transaction_journals` row (the journal entry)
2. Two `transactions` rows (debit + credit ledger lines)

```
Journal: "Paid rent via UPI"
  → Debit:  Expenses:Rent  -15,000
  → Credit: Assets:Bank    +15,000
```

This keeps the accounting balanced and allows full audit trail.

## Payment Modes (India-specific)

| Mode | When |
|------|------|
| UPI | Most daily transactions |
| NEFT | Bank transfers (non-UPI) |
| IMPS | Instant transfers |
| RTGS | Large-value transfers |
| Cheque | Rent, bills |
| Cash | Small expenses |
| Card | POS, online, ATM |
| EMI | Equated monthly installments |

## Future: Bank Import

- PDF statement parser for Indian banks (SBI, HDFC, ICICI, etc.)
- CSV/Excel import for auto-generated statements
- Auto-categorization via ML or regex rules
