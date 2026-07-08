# Mahiru Finance

Personal/household finance manager for India. Double-entry accounting, multi-user, built with Next.js.

## Stack

- **Framework**: Next.js 16 (Turbopack)
- **Styling**: Tailwind CSS v4 + shadcn/ui
- **Database**: SQLite via better-sqlite3
- **Auth**: Better Auth (email/password)
- **Charts**: Recharts

## Quick Start

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

The database (`data/finance.db`) is created automatically on first request.

## Features

| Area | Status |
|------|--------|
| Auth (sign-up, sign-in, sessions) | ✅ Working |
| Database schema (34 tables) | ✅ Complete |
| UI component library (shadcn) | ✅ Installed |
| Dark mode | ✅ Ready |
| Accounts & Transactions | 🚧 Planned |
| Dashboard & Net Worth | 🚧 Planned |
| Budgets | 🚧 Planned |
| Loans & EMI | 🚧 Planned |
| Investments (India) | 🚧 Planned |
| Bank Reconciliation | 🚧 Planned |
| Tax Planning (India) | 🚧 Planned |
| Multi-user sharing | 🚧 Planned |

## Planning Docs

See [docs/](docs/) for detailed per-feature plans.

## Project Structure

```
app/          — Next.js app router pages & API routes
components/   — shadcn/ui components
lib/          — Database, auth, utilities
docs/         — Feature planning documents
data/         — SQLite database (gitignored)
```

## License

MIT
