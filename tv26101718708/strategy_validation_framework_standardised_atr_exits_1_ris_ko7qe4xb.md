#  Strategy Validation Framework - Standardised ATR Exits & 1% Ris

- url: https://www.tradingview.com/script/KO7Qe4Xb-Strategy-Validation-Framework-Standardised-ATR-Exits-1-Ris/
- type: strategy
- pine_id: PUB;a91a5f1ba7ff4e28886bbb581ee78434
- version: 1.0

## Description

A reusable backtesting template that applies consistent exit conditions to
any entry signal, allowing fair comparison between strategies.

HOW IT WORKS
Exits are driven entirely by ATR (Average True Range). Stop loss is placed
at a configurable multiple of ATR from entry (default: 3x ATR-14). Take
profit is set at a fixed multiple (default: 6x ATR, giving 2:1 R). Position
size is calculated so that the maximum loss on any trade equals a fixed
percentage of current equity (default: 1%), normalising risk across
instruments and account sizes.

WHY THIS EXISTS
Most strategy comparisons produce misleading results because each script
uses different stop distances, lot sizes, and commission assumptions. When
exits are standardised, you isolate the entry signal's actual edge rather
than comparing risk management decisions.

HOW TO USE
1. Paste your indicator logic below the INDICATOR comment line
2. Set longCondition / shortCondition to your entry signals
3. Open Strategy Tester — the framework handles exits, sizing, and costs
The placeholder entry (9/21 EMA cross) is an example only. Replace it.

DEFAULT PROPERTIES
ATR Length: 14 | Stop Loss: 3x ATR | Take Profit: 6x ATR (2:1 R)
Risk per trade: 1% | Commission: 0.01% per side | Slippage: 1 tick

LIMITATIONS
Results depend entirely on the entry logic substituted. The EMA cross
placeholder is for illustration only and does not represent a recommended
strategy. Backtesting results do not guarantee future performance.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
//@version=6
strategy("Strategy Validation Framework - Standardised ATR Exits and 1% Risk",
     overlay           = true,
     initial_capital   = 10000,
     default_qty_type  = strategy.fixed,
     default_qty_value = 1,
     commission_type   = strategy.commission.percent,
     commission_value  = 0.01,
     slippage          = 1,
     pyramiding        = 0)

// ─── STANDARDISED EXIT INPUTS ────────────────────────────────────────────────
atrLen  = input.int(14,    "ATR Length",         group="Exits")
slMult  = input.float(3.0, "SL ATR Multiplier",  group="Exits", step=0.1)
tpMult  = input.float(6.0, "TP ATR Multiplier",  group="Exits", step=0.1)
riskPct = input.float(1.0, "Risk % per Trade",   group="Exits", step=0.1)

atrVal      = ta.atr(atrLen)
sl_distance = math.max(atrVal * slMult, syminfo.mintick)
qty         = (strategy.equity * (riskPct / 100)) / sl_distance

// ─── INDICATOR LOGIC (paste your script here) ────────────────────────────────

// Example: replace with your actual entry signals
longCondition  = ta.crossover(ta.ema(close, 9), ta.ema(close, 21))
shortCondition = ta.crossunder(ta.ema(close, 9), ta.ema(close, 21))

// ─── ENTRIES (only when flat) ─────────────────────────────────────────────────
if longCondition and strategy.position_size == 0
    strategy.entry("Long", strategy.long, qty=qty)

if shortCondition and strategy.position_size == 0
    strategy.entry("Short", strategy.short, qty=qty)

// ─── EXITS (SL + TP only — no signal-based exits) ────────────────────────────
strategy.exit("LX", "Long",
     stop  = strategy.position_avg_price - slMult * atrVal,
     limit = strategy.position_avg_price + tpMult * atrVal)

strategy.exit("SX", "Short",
     stop  = strategy.position_avg_price + slMult * atrVal,
     limit = strategy.position_avg_price - tpMult * atrVal)
````
