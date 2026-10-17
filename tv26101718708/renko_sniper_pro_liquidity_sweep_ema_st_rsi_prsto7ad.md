# Renko Sniper PRO (Liquidity Sweep + EMA + ST + RSI)

- url: https://www.tradingview.com/script/PrSTo7aD-Renko-Sniper-PRO-Liquidity-Sweep-EMA-ST-RSI/
- type: indicator
- pine_id: PUB;0077de5b79f8432da6bf16d61f95a50f
- version: 1.0

## Description

🟢 LONG ALERT ONLY triggers when:
Price sweeps below recent lows (stop hunt)
Closes back above → trap confirmed
EMA 9 crosses above 21
Price is above trend
Supertrend flips bullish
RSI confirms strength

🔴 SHORT ALERT:
Same idea, flipped:
Sweeps highs → traps breakout buyers → dumps

⚡ How to set alerts (important)
After adding to chart:
1. Click Alerts
2. Condition → select this indicator
3. Choose: “Any alert() function call”

🔥 Pro settings (tune this = big difference)
Sensitivity tuning:
Lookback = 10
Lower = more signals (scalping)
Higher = stronger sweeps (swing trades)
Sweep Buffer = 0.1%
Increase to 0.2–0.3% for BTC (reduces noise)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zachsprad

//@version=6
indicator('Renko Sniper PRO', overlay = true)

// === INPUTS ===
emaFastLen = input.int(9, 'Fast EMA')
emaSlowLen = input.int(21, 'Slow EMA')
rsiLen = input.int(14, 'RSI Length')

atrLen = input.int(10, 'Supertrend ATR Length')
factor = input.float(3.0, 'Supertrend Factor')

lookback = input.int(10, 'Liquidity Lookback (bars)')
sweepBuffer = input.float(0.1, 'Sweep Sensitivity (%)')

// === CALCULATIONS ===
// EMAs
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// RSI
rsi = ta.rsi(close, rsiLen)

// Supertrend
[supertrend, direction] = ta.supertrend(factor, atrLen)

// === LIQUIDITY LEVELS ===
highestHigh = ta.highest(high, lookback)
lowestLow = ta.lowest(low, lookback)

// Sweep thresholds
sweepHigh = highestHigh * (1 + sweepBuffer / 100)
sweepLow = lowestLow * (1 - sweepBuffer / 100)

// Detect sweeps
liquiditySweepHigh = high > highestHigh and close < highestHigh
liquiditySweepLow = low < lowestLow and close > lowestLow

// === CONDITIONS ===
// LONG (after downside sweep)
bullCross = ta.crossover(emaFast, emaSlow)
bullTrend = close > emaSlow
bullST = direction == 1
bullRSI = rsi > 50

longCondition = liquiditySweepLow and bullCross and bullTrend and bullST and bullRSI

// SHORT (after upside sweep)
bearCross = ta.crossunder(emaFast, emaSlow)
bearTrend = close < emaSlow
bearST = direction == -1
bearRSI = rsi < 50

shortCondition = liquiditySweepHigh and bearCross and bearTrend and bearST and bearRSI

// === ALERTS ===
if longCondition
    alert('🟢 LONG SWEEP: Liquidity Grab + Bullish Confirmation', alert.freq_once_per_bar_close)

if shortCondition
    alert('🔴 SHORT SWEEP: Liquidity Grab + Bearish Confirmation', alert.freq_once_per_bar_close)

// === VISUALS ===
plot(emaFast, color = color.blue, title = 'EMA 9')
plot(emaSlow, color = color.yellow, title = 'EMA 21')
plot(supertrend, color = direction == 1 ? color.green : color.red, title = 'Supertrend')

// Mark sweeps
plotshape(liquiditySweepLow, location = location.belowbar, color = color.green, style = shape.triangleup, size = size.small, title = 'Sweep Low')
plotshape(liquiditySweepHigh, location = location.abovebar, color = color.red, style = shape.triangledown, size = size.small, title = 'Sweep High')
````
