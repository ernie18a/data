# Custom RSI (25/40/60/75 Levels)

- url: https://www.tradingview.com/script/ZqU8E7gN-Custom-RSI-25-40-60-75-Levels/
- type: indicator
- pine_id: PUB;57f591ce84c242f89e896d1204a9b753
- version: 1.0

## Description

RSI with Alters-75 = Overbought, 60= Bullish momentum, 40 = Bearish momentum, 25 = Oversold

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eagonzalez446

//@version=6
//@version=6
indicator("Custom RSI (25/40/60/75 Levels)", overlay=false)

// ─────────────────────────────────────────────
// RSI INPUT
// ─────────────────────────────────────────────
length = input.int(14, "RSI Length")
src     = input(close, "Source")

rsi = ta.rsi(src, length)

// ─────────────────────────────────────────────
// PLOT RSI
// ─────────────────────────────────────────────
plot(rsi, "RSI", color=color.new(color.blue, 0), linewidth=2)

// ─────────────────────────────────────────────
// CUSTOM LEVELS
// ─────────────────────────────────────────────
h75 = hline(75, "Overbought (75)", color=color.new(color.red, 0), linewidth=1)
h60 = hline(60, "Bull Trend (60)", color=color.new(color.green, 0), linewidth=1)
h40 = hline(40, "Bear Trend (40)", color=color.new(color.orange, 0), linewidth=1)
h25 = hline(25, "Oversold (25)", color=color.new(color.blue, 0), linewidth=1)

fill(h75, h60, color=color.new(color.red, 90))     // Overbought zone
fill(h40, h25, color=color.new(color.blue, 90))    // Oversold zone

// ─────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────
alertcondition(ta.crossover(rsi, 25), "RSI Crossed Above 25", "RSI crossed UP through 25")
alertcondition(ta.crossunder(rsi, 75), "RSI Crossed Below 75", "RSI crossed DOWN through 75")

alertcondition(ta.crossover(rsi, 60), "RSI Entered Bull Zone", "RSI crossed UP through 60 (bullish momentum)")
alertcondition(ta.crossunder(rsi, 40), "RSI Entered Bear Zone", "RSI crossed DOWN through 40 (bearish momentum)")
````
