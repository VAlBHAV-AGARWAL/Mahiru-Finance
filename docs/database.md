# Database

## Source

The single source of truth is `lib/schema.sql`. It runs on every server start via `lib/db.js`. All CREATE statements use `IF NOT EXISTS`, all inserts use `INSERT OR IGNORE` — safe to re-run.

## Tables (34 total)

### Auth (managed by Better Auth)
| Table | Purpose |
|-------|---------|
| `user` | User accounts |
| `session` | Auth sessions |
| `account` | OAuth/credential accounts |
| `verification` | Email verification codes |

### Finance (30 tables)

#### Lookups
| Table | Purpose |
|-------|---------|
| `account_types` | Asset, Expense, Revenue, Liability, Equity |
| `transaction_types` | Withdrawal, Deposit, Transfer, Opening Balance, Reconciliation |
| `currencies` | INR, USD, EUR, GBP (+ seeds) |

#### Core
| Table | Purpose |
|-------|---------|
| `accounts` | All financial accounts (bank, wallet, card, loan, investment) |
| `account_meta` | Custom key-value metadata per account |
| `transaction_journals` | Journal entries (one per transaction) |
| `transactions` | Individual ledger lines (double-entry) |
| `journal_meta` | Custom key-value per journal |

#### Classification
| Table | Purpose |
|-------|---------|
| `categories` | Income/expense categories per user |
| `category_journal` | Many-to-many: journals ↔ categories |
| `tags` | User-defined tags with color |
| `tag_journal` | Many-to-many: journals ↔ tags |

#### Budgets
| Table | Purpose |
|-------|---------|
| `budgets` | Budget plans per user |
| `budget_limits` | Category-level limits per period |
| `budget_journal` | Links journals to budgets |

#### Loans
| Table | Purpose |
|-------|---------|
| `loans` | Borrowed or lent loans |
| `loan_payments` | EMI/prepayment/settlement tracking |

#### Business
| Table | Purpose |
|-------|---------|
| `partners` | Business partners with profit share ratio |
| `partner_ledger` | Capital, drawings, profit/loss entries |

#### Reconciliation
| Table | Purpose |
|-------|---------|
| `bank_statements` | Uploaded statement metadata |
| `statement_rows` | Individual statement lines with match status |

#### Savings
| Table | Purpose |
|-------|---------|
| `piggy_banks` | Savings goals with target amount |
| `piggy_bank_events` | Contributions/withdrawals to/from goal |

#### Recurring
| Table | Purpose |
|-------|---------|
| `recurrences` | Recurring transaction templates |
| `recurrence_meta` | Custom metadata per recurrence |

#### Investments
| Table | Purpose |
|-------|---------|
| `investments` | Gold, MF, Stock, FD, PPF, NPS, Crypto |
| `investment_transactions` | Buy/sell/dividend entries |

#### Notifications
| Table | Purpose |
|-------|---------|
| `notifications` | System notifications per user |

#### Settings
| Table | Purpose |
|-------|---------|
| `module_switches` | Feature toggles (core, bank_rec, loans, etc.) |

#### Multi-user
| Table | Purpose |
|-------|---------|
| `shared_accounts` | Account sharing with read/write permissions |

## Sign Convention

`transactions.amount` is **positive for debit** and **negative for credit**.

## India-specific design choices

- `payment_mode` column with: `upi`, `neft`, `imps`, `rtgs`, `cheque`, `cash`, `card`, `emi`
- `ifsc_code` and `account_number` on accounts
- `tax_head` on journals: `personal`, `business`, `exempt`
- Currency seeded with INR as default
