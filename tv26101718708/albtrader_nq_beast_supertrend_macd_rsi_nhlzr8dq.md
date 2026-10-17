# Albtrader NQ Beast  Supertrend  MACD RSI

- url: https://www.tradingview.com/script/NHlZr8dq-Albtrader-NQ-Beast-Supertrend-MACD-RSI/
- type: strategy
- pine_id: PUB;4652b361148b407ebcd81fb0a55a6801
- version: 1.0

## Description

The ultimate all-in-one strategy designed specifically for NQ / MNQ (Nasdaq futures) scalping and intraday trading.
This strategy combines 4 powerful elements for high-probability entries with built-in risk management:

Supertrend (Factor 3, Period 10) – Dynamic trend direction + built-in trailing stop
MACD (12,26,9) – Momentum confirmation on crossovers
RSI (14) – Filters out overbought/oversold entries
200 EMA – Overall market bias filter
ATR-based Stop Loss & Target – Smart risk-reward (default 1:2)

Key Features:

Clear visual Buy/Sell arrows with entry labels showing SL & TP levels
Automatic dynamic Stop Loss (1.2 × ATR)
Take-Profit at chosen Risk:Reward ratio
Optional Supertrend trailing exit
Background coloring for quick trend bias
Built-in alerts for Long & Short signals

Best Used On:

Timeframes: 1m, 3m, or 5m
Session: NY Regular Trading Hours (especially 9:30–12:00 ET)
Instrument: NQ or MNQ futures

How to Trade:
Enter only when all conditions align (Supertrend flip + MACD cross + RSI filter + EMA bias). Exit on TP, trailing stop, or opposite signal.
Warning: This is a high-volatility instrument. Always use proper risk management (max 0.5–1% risk per trade). Backtest thoroughly and forward-test in simulation before going live.
No indicator is 100% accurate — combine with your own price action reading and market context for best results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gntfrx

//@version=5
strategy("Albtrader NQ Beast – Supertrend + MACD + RSI", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10, commission_type=strategy.commission.percent, commission_value=0.04)

// === INPUTS ===
stFactor   = input.float(3.0,  "Supertrend Factor",     minval=1)
stPeriod   = input.int(10,    "Supertrend Period",      minval=1)
macdFast   = input.int(12,    "MACD Fast")
macdSlow   = input.int(26,    "MACD Slow")
macdSig    = input.int(9,     "MACD Signal")
rsiLen     = input.int(14,    "RSI Length")
rsiOB      = input.int(70,    "RSI Overbought")
rsiOS      = input.int(30,    "RSI Oversold")
emaLen     = input.int(200,   "EMA Bias Length")
atrLen     = input.int(14,    "ATR Length")
rrRatio    = input.float(2.0, "Risk:Reward Ratio",      minval=1)

// === INDICATORS ===
[supertrend, direction] = ta.supertrend(stFactor, stPeriod)
[macdLine, signalLine, _] = ta.macd(close, macdFast, macdSlow, macdSig)
rsi      = ta.rsi(close, rsiLen)
emaBias  = ta.ema(close, emaLen)
atr      = ta.atr(atrLen)

// === CONDITIONS ===
longTrend  = direction < 0
shortTrend = direction > 0

macdBull = ta.crossover(macdLine, signalLine)
macdBear = ta.crossunder(macdLine, signalLine)

longCond  = longTrend and macdBull and rsi > rsiOS and close > emaBias
shortCond = shortTrend and macdBear and rsi < rsiOB and close < emaBias

// === ENTRIES ===
if (longCond)
    strategy.entry("Long", strategy.long)

if (shortCond)
    strategy.entry("Short", strategy.short)

// === EXITS ===
slLong  = strategy.position_avg_price - (atr * 1.2)
tpLong  = strategy.position_avg_price + (atr * rrRatio)
slShort = strategy.position_avg_price + (atr * 1.2)
tpShort = strategy.position_avg_price - (atr * rrRatio)

// Fixed exits with SL + TP
if (strategy.position_size > 0)
    strategy.exit("Exit Long", "Long", stop=slLong, limit=tpLong)

if (strategy.position_size < 0)
    strategy.exit("Exit Short", "Short", stop=slShort, limit=tpShort)

// === SUPER TREND TRAILING EXIT (Best method) ===
if (strategy.position_size > 0 and direction > 0)  // Supertrend flipped red while long
    strategy.close("Long", comment="Supertrend Trail Exit")

if (strategy.position_size < 0 and direction < 0)  // Supertrend flipped green while short
    strategy.close("Short", comment="Supertrend Trail Exit")

// === PLOTS ===
plot(supertrend, "Supertrend", color = direction < 0 ? color.green : color.red, linewidth=2)
plot(emaBias, "EMA 200 Bias", color=color.orange)

plotshape(longCond,  title="Buy Signal",  location=location.belowbar, color=color.green, style=shape.triangleup,   size=size.large)
plotshape(shortCond, title="Sell Signal", location=location.abovebar, color=color.red,   style=shape.triangledown, size=size.large)

// Entry Labels
if (longCond)
    label.new(bar_index, low,  "LONG\nSL: " + str.tostring(slLong, "#.##") + "\nTP: " + str.tostring(tpLong, "#.##"), 
              color=color.green, style=label.style_label_up, textcolor=color.white, size=size.normal)

if (shortCond)
    label.new(bar_index, high, "SHORT\nSL: " + str.tostring(slShort, "#.##") + "\nTP: " + str.tostring(tpShort, "#.##"), 
              color=color.red, style=label.style_label_down, textcolor=color.white, size=size.normal)

// Alerts
alertcondition(longCond,  "Long Entry",  "🚀 NQ LONG Signal!")
alertcondition(shortCond, "Short Entry", "🔻 NQ SHORT Signal!")

// Background
bgcolor(close > emaBias ? color.new(color.green, 90) : color.new(color.red, 90))
````
