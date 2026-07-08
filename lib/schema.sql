-- Mahiru-Finance Schema
-- SQLite double-entry personal finance manager (India-ready)
-- Sign convention: transactions.amount = positive for debit, negative for credit

PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

-- =============================================
-- 1. LOOKUP TABLES
-- =============================================

CREATE TABLE IF NOT EXISTS account_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL UNIQUE CHECK(type IN ('Asset','Expense','Revenue','Liability','Equity'))
);

CREATE TABLE IF NOT EXISTS transaction_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL UNIQUE CHECK(type IN ('Withdrawal','Deposit','Transfer','Opening Balance','Reconciliation'))
);

CREATE TABLE IF NOT EXISTS currencies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  symbol TEXT NOT NULL DEFAULT '',
  decimal_places INTEGER NOT NULL DEFAULT 2,
  is_default INTEGER NOT NULL DEFAULT 0
);

-- =============================================
-- 2. AUTH (Better Auth)
-- =============================================

CREATE TABLE IF NOT EXISTS user (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  emailVerified INTEGER NOT NULL DEFAULT 0,
  image TEXT,
  createdAt TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updatedAt TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE TABLE IF NOT EXISTS session (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL REFERENCES user(id),
  token TEXT NOT NULL UNIQUE,
  expiresAt TEXT NOT NULL,
  ipAddress TEXT,
  userAgent TEXT,
  createdAt TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updatedAt TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE INDEX IF NOT EXISTS idx_session_userId ON session(userId);
CREATE INDEX IF NOT EXISTS idx_session_token ON session(token);

CREATE TABLE IF NOT EXISTS account (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL REFERENCES user(id),
  accountId TEXT NOT NULL,
  providerId TEXT NOT NULL,
  accessToken TEXT,
  refreshToken TEXT,
  accessTokenExpiresAt TEXT,
  refreshTokenExpiresAt TEXT,
  scope TEXT,
  idToken TEXT,
  password TEXT,
  createdAt TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updatedAt TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE INDEX IF NOT EXISTS idx_account_userId ON account(userId);
CREATE INDEX IF NOT EXISTS idx_account_provider ON account(providerId, accountId);

CREATE TABLE IF NOT EXISTS verification (
  id TEXT PRIMARY KEY,
  identifier TEXT NOT NULL,
  value TEXT NOT NULL,
  expiresAt TEXT NOT NULL,
  createdAt TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updatedAt TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- =============================================
-- 3. ACCOUNTS
-- =============================================

CREATE TABLE IF NOT EXISTS accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  account_type_id INTEGER NOT NULL REFERENCES account_types(id),
  name TEXT NOT NULL,
  currency_id INTEGER NOT NULL DEFAULT 1 REFERENCES currencies(id),
  virtual_balance REAL,
  iban TEXT,
  account_number TEXT,
  ifsc_code TEXT,
  credit_limit REAL,
  billing_date INTEGER,
  due_date INTEGER,
  active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS account_meta (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  value TEXT NOT NULL
);

CREATE INDEX idx_account_meta_account ON account_meta(account_id);

-- =============================================
-- 4. DOUBLE-ENTRY TRANSACTIONS
-- =============================================

CREATE TABLE IF NOT EXISTS transaction_journals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  transaction_type_id INTEGER NOT NULL REFERENCES transaction_types(id),
  currency_id INTEGER NOT NULL DEFAULT 1 REFERENCES currencies(id),
  description TEXT NOT NULL,
  date TEXT NOT NULL,
  date_tz TEXT,
  interest_date TEXT,
  book_date TEXT,
  process_date TEXT,
  payment_mode TEXT CHECK(payment_mode IN ('upi','neft','imps','rtgs','cheque','cash','card','emi')),
  ref_no TEXT,
  tax_head TEXT DEFAULT 'personal' CHECK(tax_head IN ('personal','business','exempt')),
  completed INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE INDEX idx_journals_user ON transaction_journals(user_id);
CREATE INDEX idx_journals_date ON transaction_journals(date);
CREATE INDEX idx_journals_type ON transaction_journals(transaction_type_id);

CREATE TABLE IF NOT EXISTS transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  journal_id INTEGER NOT NULL REFERENCES transaction_journals(id) ON DELETE CASCADE,
  account_id INTEGER NOT NULL REFERENCES accounts(id),
  description TEXT,
  amount REAL NOT NULL,
  balance_before REAL,
  balance_after REAL,
  reconciled INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE INDEX idx_transactions_journal ON transactions(journal_id);
CREATE INDEX idx_transactions_account ON transactions(account_id);

CREATE TABLE IF NOT EXISTS journal_meta (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  journal_id INTEGER NOT NULL REFERENCES transaction_journals(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  value TEXT NOT NULL
);

CREATE INDEX idx_journal_meta_journal ON journal_meta(journal_id);

-- =============================================
-- 5. CATEGORIES
-- =============================================

CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  name TEXT NOT NULL,
  color TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE UNIQUE INDEX idx_categories_user_name ON categories(user_id, name);

CREATE TABLE IF NOT EXISTS category_journal (
  journal_id INTEGER NOT NULL REFERENCES transaction_journals(id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (journal_id, category_id)
);

-- =============================================
-- 6. TAGS
-- =============================================

CREATE TABLE IF NOT EXISTS tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  name TEXT NOT NULL,
  color TEXT DEFAULT '#825600',
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE UNIQUE INDEX idx_tags_user_name ON tags(user_id, name);

CREATE TABLE IF NOT EXISTS tag_journal (
  journal_id INTEGER NOT NULL REFERENCES transaction_journals(id) ON DELETE CASCADE,
  tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (journal_id, tag_id)
);

-- =============================================
-- 7. BUDGETS
-- =============================================

CREATE TABLE IF NOT EXISTS budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  name TEXT NOT NULL,
  currency_id INTEGER NOT NULL DEFAULT 1 REFERENCES currencies(id),
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS budget_limits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  budget_id INTEGER NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
  category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
  amount REAL NOT NULL,
  period TEXT NOT NULL CHECK(period IN ('weekly','monthly','quarterly','yearly')),
  start_date TEXT NOT NULL,
  end_date TEXT
);

CREATE TABLE IF NOT EXISTS budget_journal (
  journal_id INTEGER NOT NULL REFERENCES transaction_journals(id) ON DELETE CASCADE,
  budget_id INTEGER NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
  budget_limit_id INTEGER REFERENCES budget_limits(id) ON DELETE SET NULL,
  PRIMARY KEY (journal_id, budget_id)
);

-- =============================================
-- 8. LOANS
-- =============================================

CREATE TABLE IF NOT EXISTS loans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  type TEXT NOT NULL CHECK(type IN ('borrowed','lent')),
  lender_name TEXT,
  borrower_name TEXT,
  principal REAL NOT NULL,
  interest_rate REAL NOT NULL DEFAULT 0,
  tenure_months INTEGER NOT NULL,
  monthly_emi REAL,
  start_date TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','settled')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS loan_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  loan_id INTEGER NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
  date TEXT NOT NULL,
  amount REAL NOT NULL,
  principal_portion REAL NOT NULL,
  interest_portion REAL NOT NULL DEFAULT 0,
  payment_type TEXT NOT NULL DEFAULT 'regular_emi' CHECK(payment_type IN ('regular_emi','prepayment','settlement')),
  account_id INTEGER REFERENCES accounts(id),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- =============================================
-- 9. PARTNERS & BUSINESS
-- =============================================

CREATE TABLE IF NOT EXISTS partners (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  name TEXT NOT NULL,
  profit_share_ratio REAL NOT NULL DEFAULT 0,
  email TEXT,
  phone TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS partner_ledger (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  partner_id INTEGER NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
  date TEXT NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('capital_contribution','drawing','profit_share','loss_share')),
  amount REAL NOT NULL,
  description TEXT,
  account_id INTEGER REFERENCES accounts(id),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- =============================================
-- 10. BANK RECONCILIATION
-- =============================================

CREATE TABLE IF NOT EXISTS bank_statements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id INTEGER NOT NULL REFERENCES accounts(id),
  filename TEXT NOT NULL,
  uploaded_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  period_start TEXT,
  period_end TEXT
);

CREATE TABLE IF NOT EXISTS statement_rows (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  statement_id INTEGER NOT NULL REFERENCES bank_statements(id) ON DELETE CASCADE,
  date TEXT NOT NULL,
  description TEXT,
  ref_no TEXT,
  withdrawal REAL DEFAULT 0,
  deposit REAL DEFAULT 0,
  balance REAL,
  reconciled INTEGER NOT NULL DEFAULT 0,
  matched_journal_id INTEGER REFERENCES transaction_journals(id) ON DELETE SET NULL
);

CREATE INDEX idx_statement_rows_statement ON statement_rows(statement_id);
CREATE INDEX idx_statement_rows_matched ON statement_rows(matched_journal_id);

-- =============================================
-- 11. PIGGY BANKS (Savings Goals)
-- =============================================

CREATE TABLE IF NOT EXISTS piggy_banks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  name TEXT NOT NULL,
  account_id INTEGER REFERENCES accounts(id),
  target_amount REAL NOT NULL,
  current_amount REAL NOT NULL DEFAULT 0,
  currency_id INTEGER NOT NULL DEFAULT 1 REFERENCES currencies(id),
  start_date TEXT,
  target_date TEXT,
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS piggy_bank_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  piggy_bank_id INTEGER NOT NULL REFERENCES piggy_banks(id) ON DELETE CASCADE,
  journal_id INTEGER REFERENCES transaction_journals(id) ON DELETE SET NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- =============================================
-- 12. RECURRING TRANSACTIONS
-- =============================================

CREATE TABLE IF NOT EXISTS recurrences (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  transaction_type_id INTEGER NOT NULL REFERENCES transaction_types(id),
  description TEXT NOT NULL,
  amount REAL NOT NULL,
  source_account_id INTEGER NOT NULL REFERENCES accounts(id),
  destination_account_id INTEGER REFERENCES accounts(id),
  currency_id INTEGER NOT NULL DEFAULT 1 REFERENCES currencies(id),
  frequency TEXT NOT NULL CHECK(frequency IN ('weekly','monthly','quarterly','yearly')),
  interval_count INTEGER NOT NULL DEFAULT 1,
  day_of_month INTEGER,
  day_of_week INTEGER,
  start_date TEXT NOT NULL,
  end_date TEXT,
  next_date TEXT,
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS recurrence_meta (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recurrence_id INTEGER NOT NULL REFERENCES recurrences(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  value TEXT NOT NULL
);

-- =============================================
-- 13. INVESTMENTS
-- =============================================

CREATE TABLE IF NOT EXISTS investments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  type TEXT NOT NULL CHECK(type IN ('gold','mutual_fund','stock','fd','ppf','nps','crypto','other')),
  name TEXT NOT NULL,
  symbol TEXT,
  units REAL,
  buy_price REAL,
  current_price REAL,
  buy_date TEXT,
  currency_id INTEGER NOT NULL DEFAULT 1 REFERENCES currencies(id),
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  deleted_at TEXT
);

CREATE TABLE IF NOT EXISTS investment_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  investment_id INTEGER NOT NULL REFERENCES investments(id) ON DELETE CASCADE,
  journal_id INTEGER REFERENCES transaction_journals(id) ON DELETE SET NULL,
  type TEXT NOT NULL CHECK(type IN ('buy','sell','dividend')),
  units REAL NOT NULL,
  price_per_unit REAL NOT NULL,
  total REAL NOT NULL,
  date TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- =============================================
-- 14. NOTIFICATIONS
-- =============================================

CREATE TABLE IF NOT EXISTS notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES user(id),
  type TEXT NOT NULL CHECK(type IN ('due_reminder','budget_warning','tax_alert','system_info')),
  message TEXT NOT NULL,
  associated_date TEXT,
  is_read INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

CREATE INDEX idx_notifications_user ON notifications(user_id);

-- =============================================
-- 15. FEATURE SWITCHES
-- =============================================

CREATE TABLE IF NOT EXISTS module_switches (
  key TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  description TEXT,
  is_enabled INTEGER NOT NULL DEFAULT 1,
  category TEXT NOT NULL DEFAULT 'general'
);

-- =============================================
-- 16. MULTI-USER PERMISSIONS
-- =============================================

CREATE TABLE IF NOT EXISTS shared_accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES user(id) ON DELETE CASCADE,
  permission_level TEXT NOT NULL DEFAULT 'read' CHECK(permission_level IN ('read','write')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  UNIQUE(account_id, user_id)
);

-- =============================================
-- SEED DATA
-- =============================================

INSERT OR IGNORE INTO account_types (id, type) VALUES (1, 'Asset'), (2, 'Expense'), (3, 'Revenue'), (4, 'Liability'), (5, 'Equity');

INSERT OR IGNORE INTO transaction_types (id, type) VALUES (1, 'Withdrawal'), (2, 'Deposit'), (3, 'Transfer'), (4, 'Opening Balance'), (5, 'Reconciliation');

INSERT OR IGNORE INTO currencies (id, code, name, symbol, decimal_places, is_default) VALUES (1, 'INR', 'Indian Rupee', '₹', 2, 1);
INSERT OR IGNORE INTO currencies (code, name, symbol, decimal_places) VALUES ('USD', 'US Dollar', '$', 2);
INSERT OR IGNORE INTO currencies (code, name, symbol, decimal_places) VALUES ('EUR', 'Euro', '€', 2);
INSERT OR IGNORE INTO currencies (code, name, symbol, decimal_places) VALUES ('GBP', 'British Pound', '£', 2);

INSERT OR IGNORE INTO module_switches (key, label, description, category, is_enabled) VALUES
  ('core', 'Core Finance', 'Accounts, transactions, and basic tracking', 'general', 1),
  ('bank_reconciliation', 'Bank Reconciliation', 'Upload and match bank statements', 'features', 0),
  ('loans', 'Loans & EMI', 'Track loans and amortization schedules', 'features', 0),
  ('partnership', 'Partnership Ledger', 'Business partnership capital and profit sharing', 'features', 0),
  ('investments', 'Investments', 'Track stocks, mutual funds, gold, FD, PPF, NPS', 'features', 0),
  ('telegram_bot', 'Telegram Bot', 'Log transactions via Telegram', 'integrations', 0),
  ('tax', 'Tax Engine', 'Indian income tax, GST, TDS tracking', 'features', 0);
