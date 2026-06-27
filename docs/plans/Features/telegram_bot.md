# Planning: Telegram Bot Integration Design

This document details the command regex parsing rules, telegram webhook/polling structure, message flows, and authentication linking for logging transactions.

---

## 🎯 Target Bot Features

1. **Quick Transaction Logging:**
   - Text a simple shorthand pattern to log expenses/incomes instantly.
   - Example syntax: `[amount] [category] [description]` (e.g., `500 Food lunch out`).
2. **Interactive Toggles:**
   - If information is missing (e.g., bank/payment mode), the bot presents interactive buttons (`UPI`, `Cash`, `Credit Card`) to fill the gap.
3. **Multi-User Security & Association:**
   - Verify sender's Telegram User ID against the `users` table (`telegram_username` or `telegram_id` column).
   - Log entries only if the sender is an authorized user, linking it directly to their `user_id`.

---

## ⚙️ Text Parsing Logic (JavaScript Regex design)

```javascript
// lib/botParser.js

/**
 * Parses shorthand text input.
 * Match formats: 
 *   - "500 Food lunch with friends" (Default expense: amount category description)
 *   - "+1000 Salary monthly paycheck" (Default income: prefix '+' amount category description)
 */
function parseTransactionText(text) {
  // Regex to match direction prefix (+/-), amount, category (single word), and description
  const regex = /^([+-]?)\s*(\d+(?:\.\d+)?)\s+(\w+)\s+(.*)$/i;
  const match = text.match(regex);

  if (!match) return null;

  const directionSymbol = match[1];
  const amount = parseFloat(match[2]);
  const category = match[3].toLowerCase();
  const description = match[4];

  // Default direction: '-' is debit (expense), '+' is credit (income)
  const direction = directionSymbol === '+' ? 'credit' : 'debit';

  return {
    amount,
    direction,
    category,
    description
  };
}
```

---

## 🤖 Telegraf Event Handler Flow (`lib/bot.js`)

```javascript
const { Telegraf, Markup } = require('telegraf');
const db = require('./db');

const bot = new Telegraf(process.env.TELEGRAM_BOT_TOKEN);

bot.use(async (ctx, next) => {
  const telegramUsername = ctx.from.username;
  // Verify user is registered in our database
  const user = await db.queryOne("SELECT * FROM users WHERE telegram_username = ? AND is_active = 1", [telegramUsername]);
  
  if (!user) {
    return ctx.reply("❌ Access Denied: Your Telegram username is not authorized in Mahiru Finance OS.");
  }
  
  ctx.state.user = user;
  await next();
});

bot.on('text', async (ctx) => {
  const parsed = parseTransactionText(ctx.message.text);
  
  if (!parsed) {
    return ctx.reply("❌ Invalid format.\nUse: `[amount] [category] [description]` (e.g., `350 Fuel office drive`) or use `+` for income (e.g., `+1000 Dividends tcs dividend`).");
  }

  // Store parsed transaction temporarily in session memory or context
  ctx.session = ctx.session || {};
  ctx.session.tempTransaction = parsed;

  // Ask for payment mode using inline buttons
  return ctx.reply("Select payment mode:", Markup.inlineKeyboard([
    [Markup.button.callback('UPI', 'pay_upi'), Markup.button.callback('Cash', 'pay_cash')],
    [Markup.button.callback('Card', 'pay_card'), Markup.button.callback('NEFT', 'pay_neft')]
  ]));
});

// Handle payment mode callbacks
bot.action(/pay_(.*)/, async (ctx) => {
  const paymentMode = ctx.match[1];
  const tx = ctx.session.tempTransaction;
  const user = ctx.state.user;

  if (!tx) {
    return ctx.reply("❌ Session expired. Please log the transaction again.");
  }

  try {
    // 1. Get default account for user (e.g. primary wallet/savings)
    const account = await db.queryOne("SELECT id FROM accounts WHERE user_id = ? AND is_active = 1 LIMIT 1", [user.id]);
    if (!account) throw new Error("No active bank account found for your profile.");

    // 2. Insert into transactions
    const dateStr = new Date().toISOString().split('T')[0];
    await db.run(
      `INSERT INTO transactions (user_id, account_id, date, amount, direction, category, description, payment_mode) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [user.id, account.id, dateStr, tx.amount, tx.direction, tx.category, tx.description, paymentMode]
    );

    // 3. Update account balances
    const balanceDiff = tx.direction === 'credit' ? tx.amount : -tx.amount;
    await db.run("UPDATE accounts SET current_balance = current_balance + ? WHERE id = ?", [balanceDiff, account.id]);

    ctx.session.tempTransaction = null;
    return ctx.editMessageText(`✅ Transaction Logged successfully!\n\n💰 Amount: ₹${tx.amount}\n📂 Category: ${tx.category}\n💳 Mode: ${paymentMode.toUpperCase()}`);
  } catch (err) {
    return ctx.reply(`❌ Failed to save transaction: ${err.message}`);
  }
});
```
