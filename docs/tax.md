# Tax Planning (India)

## Tax Heads

From `transaction_journals.tax_head`:
| Value | Meaning |
|-------|---------|
| `personal` | Personal income/expenses |
| `business` | Business/professional income/expenses |
| `exempt` | Non-taxable transactions |

## Section 80C Tracker

Track investments eligible for 80C deduction (up to ₹1.5L):
- PPF contributions
- ELSS investments
- Life insurance premiums
- EPF contributions
- 5-year tax-saving FD
- NSC
- Tuition fees
- Home loan principal

## Old vs New Regime Comparison

Build a calculator showing which regime is better based on:
1. Gross income
2. 80C deductions available
3. 80D (medical insurance) premiums
4. HRA (if applicable)
5. NPS 80CCD(1B) additional
6. Home loan interest 24(b)
7. Standard deduction

## HRA Calculation

For salaried users with house rent:
- HRA exemption = min(actual HRA, 50% salary, rent − 10% salary)
- Needs: basic salary, HRA component, rent paid, city type (metro/non-metro)

## Capital Gains

Track purchase/sale of investments for:
- **Equity**: STCG (<1yr) @ 15%, LTCG (>1yr) > ₹1L @ 10%
- **Debt funds**: STCG as per slab, LTCG @ 20% with indexation
- **Gold/SGB**: STCG as per slab, LTCG @ 20% with indexation

## Reports

1. Annual tax summary (deductions claimed)
2. Regime comparison (old vs new)
3. Capital gains statement (for ITR filing)
4. TDS tracker (from salary/interest)
