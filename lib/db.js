const initSqlJs = require('sql.js');
const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(process.cwd(), 'data', 'finance.db');

let db = null;
let initPromise = null;

async function getDb() {
  if (db) return db;
  if (initPromise) return initPromise;

  initPromise = (async () => {
    const wasmPath = path.join(process.cwd(), 'node_modules', 'sql.js', 'dist', 'sql-wasm.wasm');
    const wasmBinary = fs.readFileSync(wasmPath);
    const SQL = await initSqlJs({ wasmBinary });

    if (fs.existsSync(DB_PATH)) {
      const buffer = fs.readFileSync(DB_PATH);
      db = new SQL.Database(buffer);
    } else {
      db = new SQL.Database();
    }

    db.run('PRAGMA journal_mode=WAL');
    db.run('PRAGMA foreign_keys=ON');

    initSchema();
    saveDb();
    return db;
  })();

  return initPromise;
}

function initSchema() {
  db.run(`
    CREATE TABLE IF NOT EXISTS accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      label TEXT NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('savings','current','credit_card','cash','wallet')),
      bank_name TEXT,
      account_last4 TEXT,
      owner TEXT NOT NULL,
      credit_limit REAL DEFAULT 0,
      billing_date INTEGER,
      due_date INTEGER,
      current_balance REAL DEFAULT 0,
      currency TEXT DEFAULT 'INR',
      is_active INTEGER DEFAULT 1
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      account_id INTEGER NOT NULL,
      amount REAL NOT NULL,
      direction TEXT NOT NULL CHECK(direction IN ('debit','credit')),
      category TEXT NOT NULL,
      subcategory TEXT,
      description TEXT,
      payment_mode TEXT CHECK(payment_mode IN ('upi','neft','imps','rtgs','cheque','cash','card','emi')),
      reference_no TEXT,
      tax_head TEXT DEFAULT 'personal' CHECK(tax_head IN ('personal','business','exempt')),
      is_reconciled INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (account_id) REFERENCES accounts(id)
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS recurring_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      label TEXT NOT NULL,
      account_id INTEGER,
      amount REAL NOT NULL,
      frequency TEXT NOT NULL CHECK(frequency IN ('monthly','quarterly','yearly')),
      due_day_of_month INTEGER,
      category TEXT,
      next_due_date TEXT,
      is_active INTEGER DEFAULT 1,
      FOREIGN KEY (account_id) REFERENCES accounts(id)
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS investments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      label TEXT NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('gold','mutual_fund','stock','fd','ppf','nps','other')),
      units REAL,
      avg_buy_price REAL,
      buy_date TEXT,
      symbol TEXT,
      current_price REAL,
      last_price_update TEXT,
      notes TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT CHECK(type IN ('due_reminder','info')),
      message TEXT NOT NULL,
      due_date TEXT,
      is_read INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now'))
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      color TEXT DEFAULT '#825600'
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS transaction_tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_id INTEGER NOT NULL,
      tag_id INTEGER NOT NULL,
      FOREIGN KEY (transaction_id) REFERENCES transactions(id),
      FOREIGN KEY (tag_id) REFERENCES tags(id)
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS piggy_banks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      account_id INTEGER,
      target_amount REAL NOT NULL,
      current_amount REAL DEFAULT 0,
      target_date TEXT,
      start_date TEXT,
      notes TEXT,
      is_active INTEGER DEFAULT 1,
      FOREIGN KEY (account_id) REFERENCES accounts(id)
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS transaction_links (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      source_id INTEGER NOT NULL,
      destination_id INTEGER NOT NULL,
      link_type TEXT NOT NULL DEFAULT 'related',
      FOREIGN KEY (source_id) REFERENCES transactions(id),
      FOREIGN KEY (destination_id) REFERENCES transactions(id)
    )
  `);
}

function saveDb() {
  const dir = path.dirname(DB_PATH);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  const data = db.export();
  const buffer = Buffer.from(data);
  fs.writeFileSync(DB_PATH, buffer);
}

async function queryAll(sql, params = []) {
  await getDb();
  const stmt = db.prepare(sql);
  if (params.length) stmt.bind(params);
  const rows = [];
  while (stmt.step()) {
    rows.push(stmt.getAsObject());
  }
  stmt.free();
  return rows;
}

async function queryOne(sql, params = []) {
  const rows = await queryAll(sql, params);
  return rows.length ? rows[0] : null;
}

async function run(sql, params = []) {
  await getDb();
  db.run(sql, params);
  saveDb();
}

async function runGetId(sql, params = []) {
  await getDb();
  const result = db.run(sql, params);
  saveDb();
  return result;
}

module.exports = { getDb, queryAll, queryOne, run, runGetId, saveDb };
