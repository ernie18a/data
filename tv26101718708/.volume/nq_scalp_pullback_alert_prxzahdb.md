# NQ Scalp Pullback Alert

- url: https://www.tradingview.com/script/pRxzaHDB-NQ-Scalp-Pullback-Alert/
- type: indicator
- pine_id: PUB;e468e381059e44089842509dde56fef8
- version: 1.0

## Description

Here’s the breakdown of the script’s logic, piece by piece:
Inputs (adjustable settings at the top)
Fast EMA length: 9, Slow EMA length: 21 — these are the two trend lines


Volume multiplier: 1.0x — how much volume is required relative to the 20-period average for a signal to count


Two session windows (9:30-11:00 AM ET and 3:00-4:00 PM ET) — restricts signals to your highest-volume trading hours


A toggle to turn the session restriction on/off


What it calculates
9 EMA and 21 EMA of closing price


VWAP (volume-weighted average price) for the session


20-period average volume, used as the baseline for the volume filter


What it plots
Blue line = 9 EMA, orange line = 21 EMA, purple line = VWAP — all drawn directly on your price chart


Trend filter logic
Bullish trend = price is above VWAP AND the 9 EMA is above the 21 EMA


Bearish trend = the opposite — price below VWAP AND 9 EMA below 21 EMA


Entry signal logic
For a long: trend must be bullish, the candle’s wick must touch the 9 EMA (low ≤ EMA ≤ high), the candle must close back above the 9 EMA, volume must meet the threshold, and it must be within your session window


For a short: mirror conditions, all bearish


Visual output
Green triangle below the candle when a long setup triggers


Red triangle above the candle when a short setup triggers


Alerts
Two alert conditions are built in, so when you set up a TradingView alert, you can choose “NQ Long Pullback” or “NQ Short Pullback” and get notified the moment either fires — no need to watch the chart constantly


In short: it’s a trend-confirmation tool that taps you on the shoulder when price pulls back to the fast EMA inside an established trend, during your best trading hours, on real volume — matching the entry rules from the strategy we built.

## Source Code

````pine
//@version=6
indicator("NQ Scalp Pullback Alert", overlay=true)

// === Inputs ===
fastLen = input.int(9, "Fast EMA")
slowLen = input.int(21, "Slow EMA")
volMultiplier = input.float(1.0, "Min Volume vs Avg (x)")
sessionStart1 = input.session("0930-1100", "AM Session (ET)")
sessionStart2 = input.session("1500-1600", "PM Session (ET)")
useSessionFilter = input.bool(true, "Restrict to AM/PM sessions only")

// === Indicators ===
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
vwapVal = ta.vwap(hlc3)
avgVol = ta.sma(volume, 20)

plot(emaFast, color=color.blue, title="9 EMA")
plot(emaSlow, color=color.orange, title="21 EMA")
plot(vwapVal, color=color.purple, title="VWAP")

// === Trend Filter ===
bullTrend = close > vwapVal and emaFast > emaSlow
bearTrend = close < vwapVal and emaFast < emaSlow

// === Session Filter ===
inSession1 = not na(time(timeframe.period, sessionStart1))
inSession2 = not na(time(timeframe.period, sessionStart2))
inSession = useSessionFilter ? (inSession1 or inSession2) : true

// === Pullback Touch Condition ===
touchedFastEMA = low <= emaFast and high >= emaFast
volOK = volume >= avgVol * volMultiplier

// === Entry Signals ===
longSignal = bullTrend and touchedFastEMA and close > emaFast and volOK and inSession
shortSignal = bearTrend and touchedFastEMA and close < emaFast and volOK and inSession

plotshape(longSignal, title="Long Setup", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(shortSignal, title="Short Setup", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

alertcondition(longSignal, title="NQ Long Pullback", message="NQ Long setup: pullback to 9EMA, trend + VWAP aligned bullish")
alertcondition(shortSignal, title="NQ Short Pullback", message="NQ Short setup: pullback to 9EMA, trend + VWAP aligned bearish")
````
