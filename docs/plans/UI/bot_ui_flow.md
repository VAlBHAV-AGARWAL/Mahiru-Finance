# UI Design: Chat Bot Button Flows

This document maps out the interactive user flows and inline keyboard layouts for logging transactions via Telegram.

---

## 🤖 Interaction Flowchart

```mermaid
graph TD
    User([User sends text]) -->|e.g., '350 Fuel office drive'| BotParse[Bot parses amount & category]
    BotParse -->|Asks for Payment Mode| BotButtons{Show Inline Buttons}
    BotButtons -->|Click 'UPI'| ConfirmUPI[Log to default UPI Bank Account]
    BotButtons -->|Click 'Cash'| ConfirmCash[Log to Cash Account]
    BotButtons -->|Click 'Credit Card'| ConfirmCard[Log to Credit Card Account]
    ConfirmUPI --> Output[Reply with ✅ Logged details]
    ConfirmCash --> Output
    ConfirmCard --> Output
```

---

## 🔘 Inline Keyboard UI layouts

When the bot needs user choices, it sends structured inline buttons to avoid typing:

### Layout 1: Payment Mode Selection
Sent after parsing the text transaction.
```
┌──────────────────────────────────────┐
│ Select payment mode:                 │
├───────────────────┬──────────────────┤
│ 📱 UPI            │ 💵 Cash          │
├───────────────────┼──────────────────┤
│ 💳 Credit Card    │ 🏦 Bank Transfer │
└───────────────────┴──────────────────┘
```

### Layout 2: Tax Classification Selection
Sent for large transactions (e.g. above ₹10,000) or if the category matches business expenses:
```
┌──────────────────────────────────────┐
│ Classify under which Tax Head?       │
├───────────────────┬──────────────────┤
│ 🏠 Personal       │ 💼 Business (ITC)│
├───────────────────┴──────────────────┤
│ 📜 Exempt Income                     │
└──────────────────────────────────────┘
```

### Layout 3: Missing Category Resolver
If the regex cannot determine the category, it prompts the user to select one:
```
┌──────────────────────────────────────┐
│ What was this expense for?           │
├─────────────┬─────────────┬──────────┤
│ 🍔 Food     │ 🚗 Fuel     │ 🛍️ Shop  │
├─────────────┼─────────────┼──────────┤
│ 🔌 Bills    │ 🏥 Medical  │ ✈️ Travel │
└─────────────┴─────────────┴──────────┘
```
