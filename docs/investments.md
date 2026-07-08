# Investments (India)

## Supported Types

| Type | Schema value | Examples |
|------|-------------|----------|
| Gold | `gold` | Physical gold, SGB, gold ETF |
| Mutual Fund | `mutual_fund` | Equity, debt, hybrid, ELSS, index funds |
| Stock | `stock` | Individual equity shares |
| Fixed Deposit | `fd` | Bank FD, corporate FD |
| PPF | `ppf` | Public Provident Fund |
| NPS | `nps` | National Pension System |
| Crypto | `crypto` | Bitcoin, Ethereum, etc. |
| Other | `other` | RBI bonds, NSC, recurring deposits |

## Model

| Table | Purpose |
|-------|---------|
| `investments` | Holding: type, name, symbol, units, buy/current price, buy date |
| `investment_transactions` | Activity: buy, sell, dividend with units + price per unit |

## Features

1. **Add holdings** — one-time buy or SIP with multiple lots
2. **Track current value** — manual price update or future API integration
3. **Transaction log** — buy/sell/dividend with P&L
4. **Portfolio view** — allocation by type, sector, or fund
5. **XIRR calculation** — Indian-standard returns metric
6. **Capital gains** — short vs long-term for tax reporting

## India-specific Considerations

| Investment | Lock-in | Tax Benefit | Tax on Returns |
|-----------|---------|-------------|----------------|
| PPF | 15 yrs | 80C up to ₹1.5L | Exempt |
| ELSS | 3 yrs | 80C up to ₹1.5L | LTCG > ₹1L @ 10% |
| NPS | 60 yrs | 80C + 80CCD(1B) | 60% lump sum tax-free |
| FD | Varies | None (or 5-yr 80C) | As per slab |
| SGB | 8 yrs | None | Redemption tax-free |
| Stocks | None | None | LTCG > ₹1L @ 10%, STCG @ 15% |

## Future

- **Indices integration** — Nifty 50, Sensex for portfolio benchmarking
- **Auto price fetch** — from BSE/NSE or mutual fund APIs
- **SIP calculator** — project future value
