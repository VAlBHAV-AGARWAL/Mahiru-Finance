# Loans & EMI

## Model

| Table | Purpose |
|-------|---------|
| `loans` | Loan master: type (borrowed/lent), lender/borrower, principal, rate, tenure, EMI |
| `loan_payments` | Payment schedule: date, amount, principal/interest split, type |

## Loan Types

| Type | Examples |
|------|----------|
| Borrowed | Home loan, car loan, personal loan, education loan |
| Lent | Money lent to friend/family, chit fund contributions |

## Features

1. **Add loan** — principal, interest rate, tenure, start date → auto-calculates EMI
2. **Amortization schedule** — generated table showing each payment's principal vs interest split
3. **Track payments** — log EMIs, prepayments, or full settlement
4. **Remaining balance** — shown on loan detail + dashboard
5. **Link to accounts** — payments can be linked to a transaction journal for full accounting

## India Context

| Loan Type | Relevance |
|-----------|-----------|
| Home loan | 80C + 24(b) interest deduction |
| Education loan | 80E interest deduction |
| Car loan | Common middle-class purchase |
| Personal loan | Short-term, higher interest |
| Gold loan | Secured loan against gold |
| Chit fund | Traditional savings + borrowing |

## Schema Notes

- `monthly_emi` is stored; it can be auto-calculated on creation
- `interest_portion` vs `principal_portion` allows tax computation
- `payment_type` distinguishes regular EMIs from prepayments/settlements
