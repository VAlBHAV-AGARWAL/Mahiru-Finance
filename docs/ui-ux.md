# UI/UX Design

## Design System

- **Framework**: shadcn/ui (base-nova style)
- **Colors**: Tailwind CSS v4 CSS variables with OKLCH
- **Dark mode**: Full support via `next-themes` + `.dark` class
- **Fonts**: Geist Sans (body) + Geist Mono (code)
- **Icons**: Lucide React
- **Animation**: Motion
- **Charts**: Recharts

## Installed Components

Button, Card, Input, Label, Tooltip, Avatar, DropdownMenu, Select, Table, Badge, Separator, Checkbox, Dialog, Sheet, Calendar, Popover, Command, ScrollArea, Tabs, Toggle, Textarea

## Page Layout

```
+----------------------------------+
| Navbar (Logo + Search + Profile) |
+------+---------------------------+
|      |                           |
| Side | Main Content             |
| bar  |                           |
|      |                           |
+------+---------------------------+
```

## Theme

- **Shadcn neutral** base color
- Sidebar: default color
- Border radius: 0.625rem base
- Menu: default color, subtle accent

## Page Inventory (from shadcn-fintech reference)

| Page | Route | Status |
|------|-------|--------|
| Sign In | `/sign-in` | To build |
| Dashboard | `/dashboard` | To build |
| Accounts | `/accounts` | To build |
| Account Detail | `/accounts/[id]` | To build |
| Transactions | `/transactions` | To build |
| Transaction Detail | `/transactions/[id]` | To build |
| Budgets | `/budgets` | To build |
| Loans | `/loans` | To build |
| Investments | `/investments` | To build |
| Partners | `/partners` | To build |
| Piggy Banks | `/piggy-banks` | To build |
| Recurring | `/recurring` | To build |
| Reconciliation | `/reconciliation` | To build |
| Reports | `/reports` | To build |
| Settings | `/settings` | To build |
| Notifications | `/notifications` | To build |

## Mobile

- Responsive layout with collapsible sidebar
- Bottom nav on mobile (or sheet menu)
- Touch-friendly transaction entry
