# Trading SOP Checklist

- url: https://www.tradingview.com/script/6ugwkmGz-Trading-SOP-Checklist/
- type: indicator
- pine_id: PUB;c9080cb29f4b4058b3af8b20ff99f44c
- version: 1.0

## Description

📌 Trading SOP Checklist (Discipline-Based Entry Filter)
🔹 Overview

This indicator is designed to enforce strict trading discipline by converting a trader’s Standard Operating Procedure (SOP) into a visual checklist on the chart.

Instead of relying on emotions or memory, this tool ensures that every trade is validated through a structured, rule-based decision process before execution.

It is especially useful for traders following breakout strategies, CANSLIM-style setups, or any system where execution discipline is critical.

🔹 Core Concept

Every trade goes through 3 layers of validation:

✅ 1. Pre-Buy Conditions
Stock must be breaking out today
A valid chart pattern must be present (Cup & Handle, Base, Double Bottom, etc.)
Sufficient time before earnings (>3 days)
Pivot must be correctly marked on highs (not on close)
✅ 2. Order Execution Conditions
Price must close above pivot
Breakout must be supported by volume
Entry must strictly follow predefined system rules
✅ 3. Risk Management Conditions
Stop loss must be defined
Position size must be calculated correctly
🔹 Final Output
If all conditions are satisfied → TRADE ✅
If any condition fails → REJECT ❌

This prevents:

FOMO-based entries
Late or incorrect entries
Trades without proper risk control
🔹 How to Use
Apply the indicator on your chart
Manually toggle each checklist item based on your analysis
Only take the trade when the final status shows TRADE ✅
🔹 Who Should Use This
Breakout traders
Swing traders
Traders following rule-based systems (CANSLIM, Stage Analysis, etc.)
Anyone struggling with discipline or impulsive entries
🔹 Key Benefits
Eliminates emotional decision-making
Enforces consistency across trades
Improves execution quality
Acts as a real-time decision filter
🔹 Important Note

This indicator does not generate buy/sell signals.
It is a decision support tool, not a strategy.

## Source Code

````pine
//@version=6
indicator("Trading SOP Checklist", overlay=true)

// === INPUTS (Manual checklist toggles) ===
breakout_today = input.bool(false, "1. Breakout Today?")
pattern_valid = input.bool(false, "2. Valid Chart Pattern?")
earnings_ok = input.bool(false, "3. >3 Days Before Earnings?")
pivot_correct = input.bool(false, "4. Pivot on Highs?")

price_confirm = input.bool(false, "5. Price Breakout Confirmed?")
volume_confirm = input.bool(false, "6. Volume Confirmed?")
entry_rule = input.bool(false, "7. Entry as per Rules?")

sl_placed = input.bool(false, "8. Stop Loss Defined?")
position_size_ok = input.bool(false, "9. Position Size Correct?")

// === LOGIC ===
prebuy_ok = breakout_today and pattern_valid and earnings_ok and pivot_correct
order_ok = price_confirm and volume_confirm and entry_rule
risk_ok = sl_placed and position_size_ok

trade_allowed = prebuy_ok and order_ok and risk_ok

// === DISPLAY TABLE ===
var table t = table.new(position.top_right, 2, 12, border_width=1)

f_color(cond) =>
    cond ? color.green : color.red

if barstate.islast
    table.cell(t, 0, 0, "CHECK", bgcolor=color.gray)
    table.cell(t, 1, 0, "STATUS", bgcolor=color.gray)

    table.cell(t, 0, 1, "Breakout Today")
    table.cell(t, 1, 1, breakout_today ? "YES" : "NO", bgcolor=f_color(breakout_today))

    table.cell(t, 0, 2, "Pattern Valid")
    table.cell(t, 1, 2, pattern_valid ? "YES" : "NO", bgcolor=f_color(pattern_valid))

    table.cell(t, 0, 3, "Earnings OK")
    table.cell(t, 1, 3, earnings_ok ? "YES" : "NO", bgcolor=f_color(earnings_ok))

    table.cell(t, 0, 4, "Pivot Correct")
    table.cell(t, 1, 4, pivot_correct ? "YES" : "NO", bgcolor=f_color(pivot_correct))

    table.cell(t, 0, 5, "Price Confirm")
    table.cell(t, 1, 5, price_confirm ? "YES" : "NO", bgcolor=f_color(price_confirm))

    table.cell(t, 0, 6, "Volume Confirm")
    table.cell(t, 1, 6, volume_confirm ? "YES" : "NO", bgcolor=f_color(volume_confirm))

    table.cell(t, 0, 7, "Entry Rule")
    table.cell(t, 1, 7, entry_rule ? "YES" : "NO", bgcolor=f_color(entry_rule))

    table.cell(t, 0, 8, "SL Defined")
    table.cell(t, 1, 8, sl_placed ? "YES" : "NO", bgcolor=f_color(sl_placed))

    table.cell(t, 0, 9, "Position Size")
    table.cell(t, 1, 9, position_size_ok ? "YES" : "NO", bgcolor=f_color(position_size_ok))

    table.cell(t, 0, 10, "FINAL")
    table.cell(t, 1, 10, trade_allowed ? "TRADE ✅" : "REJECT ❌", bgcolor=trade_allowed ? color.green : color.red)
````
