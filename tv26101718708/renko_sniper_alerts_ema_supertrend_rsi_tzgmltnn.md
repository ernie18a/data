# Renko Sniper Alerts (EMA + Supertrend + RSI)

- url: https://www.tradingview.com/script/tZGMLtNN-Renko-Sniper-Alerts-EMA-Supertrend-RSI/
- type: indicator
- pine_id: PUB;37db2504b9674ba68e1a67efb063db78
- version: 1.0

## Description

This script ONLY alerts when:

9 EMA crosses 21 EMA
Price is on correct side of trend
Supertrend agrees
RSI confirms momentum

👉 So you’re getting confluence-based signals, not junk alerts.

This works BEST on Renko charts (ATR-based)
Alerts trigger only after brick closes
You still need to watch key levels / liquidity sweeps

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zachsprad

//@version=5
indicator("Renko Sniper Alerts", overlay=true)

// === INPUTS ===
emaFastLen = input.int(9, "Fast EMA")
emaSlowLen = input.int(21, "Slow EMA")
rsiLen = input.int(14, "RSI Length")
rsiBull = input.int(50, "RSI Bull Threshold")
rsiBear = input.int(50, "RSI Bear Threshold")

atrLen = input.int(10, "Supertrend ATR Length")
factor = input.float(3.0, "Supertrend Factor")

// === CALCULATIONS ===
// EMAs
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// RSI
rsi = ta.rsi(close, rsiLen)

// Supertrend
[supertrend, direction] = ta.supertrend(factor, atrLen)

// === CONDITIONS ===
// Bullish Conditions
bullCross = ta.crossover(emaFast, emaSlow)
bullTrend = close > emaSlow
bullRSI = rsi > rsiBull
bullST = direction == 1

longCondition = bullCross and bullTrend and bullRSI and bullST

// Bearish Conditions
bearCross = ta.crossunder(emaFast, emaSlow)
bearTrend = close < emaSlow
bearRSI = rsi < rsiBear
bearST = direction == -1

shortCondition = bearCross and bearTrend and bearRSI and bearST

// === ALERTS ===
if (longCondition)
    alert("🟢 LONG: EMA Cross + Supertrend Bullish + RSI Confirmed", alert.freq_once_per_bar_close)

if (shortCondition)
    alert("🔴 SHORT: EMA Cross + Supertrend Bearish + RSI Confirmed", alert.freq_once_per_bar_close)

// === PLOTS ===
plot(emaFast, color=color.blue, title="EMA 9")
plot(emaSlow, color=color.yellow, title="EMA 21")

plot(supertrend, color=direction == 1 ? color.green : color.red, title="Supertrend")
````
