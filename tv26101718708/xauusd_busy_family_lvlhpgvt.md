# XAUUSD Busy Family

- url: https://www.tradingview.com/script/lvlHpgVT-XAUUSD-Busy-Family/
- type: indicator
- pine_id: PUB;42b1be6f868d419082e40c64f1b50dbe
- version: 1.0

## Description

XAUUSD Busy Family

A clean, high-precision scalping indicator built exclusively for XAUUSD (Gold).

It combines a fast Pips-based trend detection engine (Period 10 | Multiplier 39) with smart RSI filtering to deliver high-probability entries with minimal chart clutter.

Key Features:
• Instant Trend Background
  Green background = Bullish market state
  Red background = Bearish market state

• Clear BUY & SELL Signals
  Signals trigger only when the main Pips trend flips direction and RSI confirms the move (RSI > 50 for buys, RSI < 50 for sells).

• Real-time Dashboard (top-right corner)
  Shows:
  • Current trend (BULLISH ↑ or BEARISH ↓)
  • Live RSI value
  • Active signal (BUY, SELL, or WAIT)

• Three Smart Alerts
  1. BUY Signal
  2. SELL Signal
  3. Background / Trend Change (fires instantly when the market flips)

Completely simplified — no moving averages and no extra lines on the chart. Just the clean Pips Trend system and background coloring, making it perfect for fast scalping on M1 to M15 timeframes.

Settings are pre-optimized for Gold but remain fully adjustable in the inputs.

## Source Code

````pine
//@version=6
indicator("XAUUSD Busy Family", shorttitle="Busy Family", overlay=true, max_bars_back=500)

// ── Inputs ──
pipsPeriod = input.int(10, "Pips Period", minval=1, group="Pips")
pipsMult   = input.float(39.0, "Pips Multiplier", minval=0.1, group="Pips")   // ← changed to 39 as requested
rsiLen     = input.int(14, "RSI Length", minval=1, group="RSI")

// ── Calculations ──
[superTrend, direction] = ta.supertrend(pipsMult, pipsPeriod)

trendUp   = direction < 0
trendDown = direction > 0
rsi       = ta.rsi(close, rsiLen)

// Detect background/trend change
trendChanged = ta.change(trendUp)

// ── Signals (based on Pips trend flip + RSI)
longCondition  = trendChanged and trendUp and rsi > 50
shortCondition = trendChanged and trendDown and rsi < 50

// ── Plots ──
plot(superTrend, "Pips Trend", color = trendUp ? color.new(#00E676, 0) : color.new(#FF5252, 0), linewidth=3)

// Background
bgcolor(trendUp ? color.new(#00E676, 92) : color.new(#FF5252, 92), title="Trend Background")

// ── Dashboard ──
var table infoTable = table.new(position.top_right, 1, 4, bgcolor = color.new(color.black, 80), border_width = 1, border_color = color.white)
if barstate.islast
    table.cell(infoTable, 0, 0, "XAUUSD Busy Family", text_color = color.yellow, text_size = size.normal)
    table.cell(infoTable, 0, 1, "Trend: " + (trendUp ? "BULLISH ↑" : "BEARISH ↓"), text_color = trendUp ? #00E676 : #FF5252, text_size = size.normal)
    table.cell(infoTable, 0, 2, "RSI: " + str.tostring(rsi, "#.##"), text_color = rsi > 70 ? color.red : rsi < 30 ? color.lime : color.white, text_size = size.normal)
    table.cell(infoTable, 0, 3, "Signal: " + (longCondition ? "BUY" : shortCondition ? "SELL" : "WAIT"), text_color = longCondition ? #00E676 : shortCondition ? #FF5252 : color.gray, text_size = size.normal)

// ── Alerts ──
alertcondition(longCondition,  title="Busy Family BUY",               message="🚀 XAUUSD Busy Family BUY Signal on {{ticker}} {{interval}}")
alertcondition(shortCondition, title="Busy Family SELL",              message="🔻 XAUUSD Busy Family SELL Signal on {{ticker}} {{interval}}")
alertcondition(trendChanged,   title="Busy Family Background Change", message="🔄 XAUUSD Busy Family Background/Trend Changed on {{ticker}} {{interval}}")
````
