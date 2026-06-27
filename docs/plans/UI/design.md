# UI Design: Style Guide & Aesthetic Tokens

This document establishes the UI/UX framework for Mahiru Finance OS, prioritizing a modern, premium look suitable for both mobile and desktop screens.

---

## 🎨 Theme & Palette

We follow a sleek **dark-mode first** aesthetic with vibrant accents, glassmorphic card boundaries, and readable typography.

*   **Primary Background:** Deep charcoal-black (`#0D0F12` / `HSL(220, 18%, 6%)`)
*   **Card Background:** Slightly lighter grey with opacity for overlay (`#161A1F` / `HSL(215, 15%, 10%)`)
*   **Aesthetic Overlay:** 1px borders with subtle semi-transparent white/grey (`rgba(255,255,255,0.06)`) and soft background blur (`backdrop-filter: blur(12px)`).
*   **Core Color Accents:**
    *   `Emerald / Mint` for positive cash flows, gains, and assets (`#10B981` / `HSL(150, 84%, 40%)`)
    *   `Rose / Crimson` for expenses, liabilities, and outgoing payments (`#EF4444` / `HSL(0, 84%, 60%)`)
    *   `Gold / Indigo` for investment assets (`#F59E0B` / `HSL(38, 92%, 50%)`)

---

## ✍️ Typography

We use modern sans-serif typefaces from Google Fonts (loaded via Next.js Font Optimization):
*   **Primary Typeface:** **Outfit** or **Inter** for standard labels, body text, and tables.
*   **Numerical Display Typeface:** **JetBrains Mono** or **Space Grotesk** for values, account balances, and numbers (ensures tabular alignment and clean reading of financial data).

---

## ✨ Micro-Animations & Hover Effects

*   **Interactive Hover:** Navigation links and cards lift slightly on hover (`transform: translateY(-2px)`) with smooth CSS transitions (`transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1)`).
*   **Glow Accents:** Action buttons (like "Add Transaction") will have a subtle radial-gradient background glow.
*   **Charts Transitions:** Recharts animations set to `duration={800}` with custom ease curves.
