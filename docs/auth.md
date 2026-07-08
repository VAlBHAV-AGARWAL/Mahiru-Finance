# Auth & Multi-User

## Current Setup

- **Better Auth** with email/password
- Single `data/finance.db` for both auth + app data
- Auth handler mounted at `/api/auth/*`
- Client uses `better-auth/react` with `createAuthClient`

## Architecture

```
lib/auth.js          — Server: creates betterAuth() with better-sqlite3
lib/auth-client.js   — Browser: createAuthClient, exports signIn, signUp, signOut, useSession
app/api/auth/[...all]/route.js — Next.js route handler
```

## Multi-User Design (5 family members)

| Persona | Access |
|---------|--------|
| Admin (you) | Full access to all accounts |
| Spouse | Own accounts + shared accounts |
| Parents | Own accounts + view-only on shared |
| Children | Own accounts (limited) |

## Implementation Plan

1. **Row-level ownership**: Every table has `user_id TEXT REFERENCES user(id)` — data is naturally partitioned by user.
2. **Shared accounts**: `shared_accounts` table maps account_id → user_id with permission_level (`read` / `write`).
3. **Household view**: Queries can JOIN across users for shared accounts to build family net worth.
4. **Permissions middleware**: API routes check ownership OR shared_accounts permissions before returning data.

## Future Plugins

Better Auth plugins we might add:
- **API keys** — for Telegram bot integration
- **Two-factor auth** — for sensitive actions
