# Planning: Loans & Liability Ledger Design

This document details the tracking, calculations, and database mappings for bank loans, P2P loans, and amortization schedules.

---

## 🎯 Target Loan Features

1. **Loan Types:**
   - **Bank Loans:** Home, Car, Personal, and Educational loans.
   - **P2P Loans:** Money borrowed from or lent to family members and friends.
2. **EMI & Schedule Tracker:**
   - Input principal, rate of interest, and tenure.
   - Automatically generate a standard amortization schedule (calculating monthly EMI, Interest component, Principal component, and Remaining Balance).
3. **Repayment Logging:**
   - Tracks standard EMIs paid.
   - Tracks **pre-payments** or lump-sum repayments (which reduce the principal directly and recalculate future EMIs/tenure).

---

## 💾 Database Schema Additions

```sql
-- Track core loan specifications
CREATE TABLE IF NOT EXISTS loans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  type TEXT CHECK(type IN ('borrowed', 'lent')), -- Borrowed (Liability) or Lent (Asset)
  lender_name TEXT NOT NULL,
  borrower_name TEXT NOT NULL,
  principal_amount REAL NOT NULL,
  interest_rate REAL NOT NULL, -- Annual interest rate in percentage
  tenure_months INTEGER NOT NULL,
  monthly_emi REAL,
  start_date TEXT NOT NULL,
  status TEXT DEFAULT 'active' CHECK(status IN ('active', 'settled')),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Track repayments (both monthly EMI and prepayments)
CREATE TABLE IF NOT EXISTS loan_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  loan_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  amount_paid REAL NOT NULL,
  principal_component REAL NOT NULL,
  interest_component REAL NOT NULL,
  payment_type TEXT DEFAULT 'regular_emi' CHECK(payment_type IN ('regular_emi', 'prepayment', 'settlement')),
  account_id INTEGER, -- Link to bank/cash account
  FOREIGN KEY (loan_id) REFERENCES loans(id),
  FOREIGN KEY (account_id) REFERENCES accounts(id)
);
```

---

## ⚙️ Amortization Logic (JavaScript API Design)

```javascript
// lib/loanEngine.js

/**
 * Calculates Monthly EMI using standard formula:
 * EMI = [P x R x (1+R)^N]/[((1+R)^N)-1]
 * P = Principal, R = Monthly Interest Rate, N = Tenure in months
 */
function calculateMonthlyEMI(principal, annualRate, tenureMonths) {
  const monthlyRate = (annualRate / 12) / 100;
  if (monthlyRate === 0) return principal / tenureMonths;

  const emi = (principal * monthlyRate * Math.pow(1 + monthlyRate, tenureMonths)) / 
              (Math.pow(1 + monthlyRate, tenureMonths) - 1);
  return parseFloat(emi.toFixed(2));
}

/**
 * Generates Amortization Schedule
 */
function generateAmortizationSchedule(principal, annualRate, tenureMonths) {
  const emi = calculateMonthlyEMI(principal, annualRate, tenureMonths);
  const monthlyRate = (annualRate / 12) / 100;
  
  let remainingPrincipal = principal;
  const schedule = [];

  for (let month = 1; month <= tenureMonths; month++) {
    const interest = parseFloat((remainingPrincipal * monthlyRate).toFixed(2));
    const principalPaid = parseFloat((emi - interest).toFixed(2));
    remainingPrincipal = parseFloat((remainingPrincipal - principalPaid).toFixed(2));

    schedule.push({
      month,
      emi,
      interest,
      principalPaid,
      remainingPrincipal: Math.max(0, remainingPrincipal)
    });
  }

  return schedule;
}
```

---

## 🖥️ UI Dashboard Structure (`app/loans/page.js`)

*   **Active Loans List:** Summary cards showing Lender/Borrower, Initial Amount, Remaining Balance, and Next EMI due date.
*   **Detailed Amortization Chart:** Area charts comparing Principal vs. Interest over time using Recharts.
*   **Payment Modal:** Form to log a payment with toggles for `Regular EMI` or `Prepayment` (which prompts the system to recalculate the remaining amortization table).
