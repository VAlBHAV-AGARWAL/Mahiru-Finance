# Compliance: Indian Taxation Engine Specifications

This document outlines the formulas, parameters, and database schemas for calculating taxes (Income Tax, TDS, Crypto, Dividends, GST Input Tax Credits) compliant with current Indian Tax Laws.

---

## 🏛️ Direct Taxes (Income Tax Regimes)

The engine calculates liabilities under both regimes to help the family make tax optimization decisions.

### Slabs: New Tax Regime (FY 2024-25 / FY 2025-26 Default)
*   **Up to ₹3,00,000:** 0%
*   **₹3,00,001 to ₹6,00,000:** 5%
*   **₹6,00,001 to ₹9,00,000:** 10%
*   **₹9,00,001 to ₹12,00,000:** 15%
*   **₹12,00,001 to ₹15,00,000:** 20%
*   **Above ₹15,00,000:** 30%
*   *Rebate:* Section 87A rebate makes taxable income up to ₹7,00,000 completely tax-free under the New Regime.

### Slabs: Old Tax Regime
*   **Up to ₹2,50,000:** 0%
*   **₹2,50,001 to ₹5,00,000:** 5%
*   **₹5,00,001 to ₹10,00,000:** 20%
*   **Above ₹10,00,000:** 30%
*   *Rebate:* Section 87A rebate makes taxable income up to ₹5,00,000 tax-free.
*   *Deductions supported:* Section 80C (PPF, ELSS, EPF, FDs up to ₹1.5L), Section 80D (Health Insurance up to ₹25K/₹50K), HRA, Standard Deduction (₹50,000/₹75,000 depending on budget updates).

---

## 🪙 Cryptocurrency / Virtual Digital Asset (VDA) Tax (Section 115BBH)

*   **Rule:** Flat 30% tax on gains from the transfer of any VDA.
*   **Calculation Formula:**
    $$\text{Tax Liability} = \sum (\text{Sell Price} - \text{Cost of Acquisition}) \times 0.30 \quad [\text{for each trade where Sell Price} > \text{Cost of Acquisition}]$$
*   **Restriction:** Losses from one crypto asset cannot offset gains in another. The loss is ignored (valued at 0), and gains are taxed individually at 30%. No deductions or expenses are allowed other than the acquisition cost.

---

## 📈 Dividend Tax (Section 56(2)(i))

*   **Rule:** Dividend income from domestic shares or mutual funds is taxable in the hands of the investor at their standard income tax slab rates.
*   **Formula:**
    $$\text{Taxable Dividend} = \sum \text{Dividend Receipts}$$
    *(This sum is added to the general taxable income bucket before slab calculation.)*

---

## 🧾 TDS (Tax Deductions) & GST Input Credits

### TDS Ledger:
*   We track TDS deducted by employers (Form 16) or banks (Form 16A on FD interest).
*   Stored inside `transactions` table in `tds_deducted` column.
*   Total TDS is subtracted directly from the final tax liability:
    $$\text{Net Tax Payable} = \text{Slab Tax} + \text{Crypto Tax} - \text{Total TDS Credits}$$

### GST Input Tax Credits (ITC) for Business Owners:
*   When a business owner makes a business purchase (e.g. buying a calculator with 18% GST), they can log the CGST/SGST/IGST components.
*   **Database Record:**
    *   Sub-columns in `transactions`: `gross_amount`, `gst_rate` (e.g. 18), `gst_amount` (calculated).
*   **Formula:**
    $$\text{GST Input Credit} = \text{Price} \times \frac{\text{GST Rate}}{100 + \text{GST Rate}}$$
    *(This is logged so business owners can claim GST refund/offset against their sales invoices.)*
