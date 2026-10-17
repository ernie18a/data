# XAUUSD Family Scalping

- url: https://www.tradingview.com/script/V7i5G4PF-XAUUSD-Family-Scalping/
- type: indicator
- pine_id: PUB;4af3dca35bb7484dbffb7627c52c54e4
- version: 1.0

## Description

XAUUSD Family Scalping Indicator

Professional scalping tool designed for Gold (XAUUSD).

Features:
• Clear BUY / SELL arrows
• Supertrend + EMA trend filter
• RSI confirmation
• Background color for trend
• Live dashboard on chart

Best timeframes: 5m, 15m, 1H

Enjoy and good luck in trading! 🚀

## Source Code

````pine
//@version=6
indicator("XAUUSD Family Scalping", shorttitle="Family Scalping", overlay=true, max_bars_back=500)

// ── Inputs ──
fastLen   = input.int(9,  "Fast EMA", minval=1, group="Moving Averages")
slowLen   = input.int(21, "Slow EMA", minval=1, group="Moving Averages")
stPeriod  = input.int(10, "Supertrend Period", minval=1, group="Supertrend")
stMult    = input.float(3.0, "Supertrend Multiplier", minval=0.1, group="Supertrend")
rsiLen    = input.int(14, "RSI Length", minval=1, group="RSI")

// ── Calculations ──
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)

[superTrend, direction] = ta.supertrend(stMult, stPeriod)
trendUp   = direction < 0
trendDown = direction > 0

rsi = ta.rsi(close, rsiLen)

// ── Signals ──
longCondition  = ta.crossover(emaFast, emaSlow) and trendUp and rsi > 50
shortCondition = ta.crossunder(emaFast, emaSlow) and trendDown and rsi < 50

// ── Plots ──
plot(emaFast, color=#2962FF, title="Fast EMA", linewidth=2)
plot(emaSlow, color=#FF5252, title="Slow EMA", linewidth=2)

plot(superTrend, "Supertrend", color = trendUp ? color.new(#00E676, 0) : color.new(#FF5252, 0), linewidth=3)

// Signals
plotshape(longCondition,  title="Buy Arrow",  location=location.belowbar, color=color.new(#00E676,0), style=shape.triangleup,   size=size.large, text="BUY", textcolor=color.white)
plotshape(shortCondition, title="Sell Arrow", location=location.abovebar, color=color.new(#FF5252,0), style=shape.triangledown, size=size.large, text="SELL", textcolor=color.white)

// Background
bgcolor(trendUp ? color.new(#00E676, 92) : color.new(#FF5252, 92), title="Trend Background")

// ── Dashboard ──
var table infoTable = table.new(position.top_right, 1, 4, bgcolor = color.new(color.black, 80), border_width = 1, border_color = color.white)

if barstate.islast
    table.cell(infoTable, 0, 0, "XAUUSD Family Scalping", text_color = color.yellow, text_size = size.normal)
    table.cell(infoTable, 0, 1, "Trend: " + (trendUp ? "BULLISH ↑" : "BEARISH ↓"), text_color = trendUp ? #00E676 : #FF5252, text_size = size.normal)
    table.cell(infoTable, 0, 2, "RSI: " + str.tostring(rsi, "#.##"), text_color = rsi > 70 ? color.red : rsi < 30 ? color.lime : color.white, text_size = size.normal)
    table.cell(infoTable, 0, 3, "Signal: " + (longCondition ? "BUY" : shortCondition ? "SELL" : "WAIT"), text_color = longCondition ? #00E676 : shortCondition ? #FF5252 : color.gray, text_size = size.normal)

// ── Alerts ──
alertcondition(longCondition,  title="Family Scalping BUY",  message="🚀 XAUUSD Family Scalping BUY Signal on {{ticker}} {{interval}}")
alertcondition(shortCondition, title="Family Scalping SELL", message="🔻 XAUUSD Family Scalping SELL Signal on {{ticker}} {{interval}}")
````
