# Planning: Financial Integrations & Inputs Design

This document details plans for connecting the application to transaction feeds, utilizing Google Pay/UPI metadata hooks, SMS parsing, and API ingestion triggers.

---

## 🎯 Target Integration Features

1. **SMS Transaction Logger (Android Termux Specific):**
   - **Mechanism:** Running on Termux on Android, we can utilize `termux-sms-list` or task automation tools like **Tasker** to detect incoming SMS transaction alerts (from HDFC, SBI, ICICI, etc.) and post the message body to our API.
   - **Benefit:** Automatically tracks daily UPI payments (Google Pay, PhonePe, Paytm) since Indian banks send a real-time SMS receipt for every transaction.
2. **Standard SMS Format Parsers:**
   - Detect phrases like `debited by Rs.` or `credited with INR` and extract:
     - Amount
     - Bank Name (sender prefix like `AD-HDFCBK`)
     - Merchant/Beneficiary details
     - Reference number
3. **Manual Upload / Webhook Integrations:**
   - Expose an API endpoint (`/api/ingress/transaction`) protected by an Auth Token, allowing third-party finance scrapers or local automation scripts to ingest transactions.

---

## ⚙️ SMS Parsing Engine (Regex-based Heuristics)

```javascript
// lib/smsParser.js

/**
 * Parses transactional SMS from Indian banks
 * Example HDFC SMS: "Alert: Rs 500.00 debited from a/c **1234 to Merchant X on 27-06-2026. Ref No: 1234567"
 * Example SBI SMS: "Your a/c **4321 credited by Rs 10,000.00 on 27/06/2026 by salary."
 */
function parseIndianBankSMS(smsBody, senderAddress) {
  // Normalize string
  const text = smsBody.toLowerCase();
  
  const debitRegex = /(?:rs\.?|inr)\s*([\d,]+(?:\.\d{2})?)\s*(?:debited|spent|withdrawn|charged)/i;
  const creditRegex = /(?:rs\.?|inr)\s*([\d,]+(?:\.\d{2})?)\s*(?:credited|received|deposited)/i;
  const cardRegex = /card\s*(?:ending\s*with|xx)\s*(\d{4})/i;
  const acctRegex = /(?:a\/c|account|acct)\s*(?:ending\s*with|xx|in|no\.?)\s*([\*\w]{4,})/i;

  let amount = 0;
  let direction = null;
  let accountSuffix = null;

  const debitMatch = text.match(debitRegex);
  const creditMatch = text.match(creditRegex);

  if (debitMatch) {
    amount = parseFloat(debitMatch[1].replace(/,/g, ''));
    direction = 'debit';
  } else if (creditMatch) {
    amount = parseFloat(creditMatch[1].replace(/,/g, ''));
    direction = 'credit';
  } else {
    return null; // Not a standard transaction SMS
  }

  const acctMatch = text.match(acctRegex) || text.match(cardRegex);
  if (acctMatch) {
    accountSuffix = acctMatch[1].replace(/\*/g, '');
  }

  // Deduce merchant
  let merchant = 'unspecified merchant';
  const merchantMatch = text.match(/(?:to|at|info)\s+([a-zA-Z\d\s\-]+?)\s+(?:on|ref|via|by)/i);
  if (merchantMatch) {
    merchant = merchantMatch[1].trim();
  }

  return {
    amount,
    direction,
    accountSuffix,
    description: `SMS Alert: ${merchant}`,
    raw: smsBody
  };
}
```

---

## 🔗 Tasker integration (Termux Ingress API)

To bridge Android Google Pay notifications or SMS to our Termux node app:
1. Set up a profile in **Tasker** (Android automation app) to intercept notifications from `com.google.android.apps.nbu.paisa.user` (Google Pay) or incoming SMS.
2. Extract text variables `%NTITLE`, `%NTEXT`, or `%SMSRF`, `%SMSRB`.
3. Perform an HTTP POST to:
   `http://localhost:3000/api/ingress/transaction`
   Payload:
   ```json
   {
     "secret_token": "YOUR_SHARED_SECRET_KEY",
     "sender": "%SMSRF",
     "message": "%SMSRB"
   }
   ```
4. Next.js API processes the post, runs `parseIndianBankSMS`, and appends the entry to `finance.db` while triggering a push notification banner.
