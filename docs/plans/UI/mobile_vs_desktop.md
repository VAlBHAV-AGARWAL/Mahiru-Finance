# UI Design: Mobile-First vs. Desktop Layouts

This document details how the responsive layout hierarchy reorganizes components when accessed on mobile screens (like Termux views on phones) vs. desktop monitors.

---

## 📱 Mobile-First Layout Hierarchy

On mobile devices, screen real estate is limited. The interface prioritizes vertical stacking and thumb-friendly touch actions.

1.  **Tab-Based Navigation:** Desktop sidebars collapse into a sticky bottom navigation bar (similar to modern banking apps):
    *   `Dashboard` (Home) | `Accounts` | `Log (Add)` | `Investments` | `Settings`
2.  **Stat Cards Carousel:** Instead of showing 4 distinct summary cards in a row, mobile screens group them into a swipable horizontal carousel showing:
    *   *Slide 1:* Net Worth
    *   *Slide 2:* Estimated Tax Due
    *   *Slide 3:* Current Monthly Spend
3.  **Floating Action Button (FAB):** A permanent, glowing `+` button in the bottom center for quick transaction logs.
4.  **Tables to Cards:** Dense transaction grid tables collapse into scrollable lists of list-cards, showing only the category icon, payee description, payment mode, and amount.

---

## 🖥️ Desktop Layout Hierarchy

When viewed on desktop screens, the interface expands to display rich information side-by-side, avoiding empty space.

1.  **Persistent Sidebar Navigation:** Folders, modules, and settings remain visible on the left side of the screen with active route indicators.
2.  **Dashboard Grid:**
    *   *Top Row:* Large stat cards side-by-side (Net Worth, Monthly Inflow, Monthly Outflow, Tax Due).
    *   *Middle Row:* A split 70/30 layout. Left has the primary Cash Flow Chart (Recharts Area Chart); Right has the Asset Allocation Donut Chart (Cash vs. Gold vs. Stocks).
    *   *Bottom Row:* A list of recent transactions alongside upcoming bills/notifications.
3.  **Advanced Grids:** Data tables show full detail columns (Date, User, Account, Category, Tax Head, Payment Mode, Ref Number, TDS, and Action dropdowns).
