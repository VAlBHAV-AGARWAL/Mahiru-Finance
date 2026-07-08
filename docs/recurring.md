# Recurring Transactions

## Model

| Field | Description |
|-------|-------------|
| `recurrences` | Template: type, amount, source/destination accounts, frequency |
| `recurrence_meta` | Custom key-value metadata |
| `source_account_id` | Debit from this account |
| `destination_account_id` | Credit to this account (for transfers) |

## Frequencies

| Frequency | Example |
|-----------|---------|
| `weekly` | Pocket money, maid salary |
| `monthly` | Rent, salary, insurance, SIP, EMI |
| `quarterly` | Mutual fund dividends, property tax |
| `yearly` | Insurance premium, subscription, LIC |

## Features

1. **Create template** — description, amount, accounts, frequency
2. **Upcoming view** — shows next N scheduled transactions
3. **Auto-generate** — on the due date, create a journal entry
4. **Skip once** — postpone without breaking the schedule
5. **Adjust** — change amount or date for next occurrence
6. **Notifications** — alert N days before due

## India Examples

| Recurring | Frequency | Typical Amount |
|-----------|-----------|----------------|
| Rent | Monthly | ₹5K-₹50K |
| SIP | Monthly | ₹500-₹50K |
| Insurance premium | Yearly | ₹10K-₹1L |
| LIC premium | Half-yearly/yearly | ₹5K-₹50K |
| Maid salary | Monthly | ₹2K-₹10K |
| Club/gym membership | Monthly/yearly | ₹1K-₹20K |
| Newspaper | Monthly | ₹200-₹500 |
| Broadband plan | Monthly/yearly | ₹500-₹2K |
