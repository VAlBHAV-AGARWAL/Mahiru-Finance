# Architecture

## Stack

| Layer | Choice |
|-------|--------|
| Framework | Next.js 16 (Turbopack) |
| Language | JavaScript (no TypeScript) |
| Styling | Tailwind CSS v4 + shadcn/ui (base-nova) |
| Database | SQLite via better-sqlite3 (one `finance.db` file) |
| Auth | Better Auth 1.6 (email/password, sessions) |
| Charts | Recharts |
| Animations | Motion (formerly framer-motion) |
| Icons | Lucide React |
| Fonts | Geist (sans + mono) via next/font |

## Data Flow

```
Browser ←→ Next.js API Routes ←→ better-sqlite3 ←→ data/finance.db
                            ↕
                    Better Auth Handler
```

- All API routes use synchronous better-sqlite3 calls (no async needed).
- Better Auth runs in the same process, sharing the same DB file via separate connection.
- Schema is auto-applied on every server start via `lib/db.js` (all tables use `CREATE IF NOT EXISTS`).

## Project Structure

```
app/
  api/
    auth/[...all]/route.js   — Better Auth handler
    test-db/route.js         — Health check (can remove later)
  globals.css                — Tailwind v4 + shadcn theme
  layout.js                  — Root layout (ThemeProvider + TooltipProvider)
  page.js                    — Landing / redirect
components/
  ui/                        — shadcn/ui components (21 installed)
lib/
  schema.sql                 — Full DB schema (34 tables)
  db.js                      — Database connection + query helpers
  auth.js                    — Better Auth server instance
  auth-client.js             — Better Auth client (browser)
  utils.js                   — cn() helper
docs/                        — Planning docs
```

## Conventions

- **Naming**: snake_case for DB columns, camelCase for JS
- **Foreign keys**: always use `REFERENCES` with `ON DELETE CASCADE` where appropriate
- **Timestamps**: ISO 8601 via `strftime('%Y-%m-%dT%H:%M:%fZ','now')`
- **Soft delete**: `deleted_at TEXT` on all major tables
- **Multi-user**: every entity has `user_id TEXT REFERENCES user(id)`
