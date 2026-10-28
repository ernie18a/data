# Day Trading (Indicator) - EMA/RSI/VWAP/Breakout

- url: https://www.tradingview.com/script/ajmwwwqw-Day-Trading-Indicator-EMA-RSI-VWAP-Breakout/
- type: indicator
- pine_id: PUB;144eb5703bbb403c969e45d5fce469f8
- version: 1.0

## Description

Indicator Overview
This script is a TradingView Indicator that generates Long (buy) entry signals based on the alignment of:

Trend filter (EMA)
Momentum filter (RSI)
Entry trigger (either Breakout + Volume OR VWAP Retest)
Chart visualization (labels + optional candle coloring)
Alert condition for TradingView notifications 13
1) Trend Filter (EMA)
The script calculates two exponential moving averages:

EMA Fast
EMA Slow
A long setup requires:

close > emaFast
emaFast > emaSlow
This means price is above the fast EMA and the fast EMA is above the slow EMA → bullish trend.

2) Momentum Filter (RSI)
It calculates RSI and requires:

RSI > rsiMid
Default midline is 50, but you can adjust it in inputs.

3) Two Possible Entry Triggers
The script allows entries using one of these two conditions (or both, depending on your settings):

A) Breakout + Volume Filter
It checks whether the current candle closes above the highest high of the previous brkLen bars:

breakUp = close > highestPrev
And it also requires a volume confirmation:

volume > SMA(volume, volLen) * volMult
You control this trigger using:

useBreakout
B) VWAP Retest Trigger
It looks for a VWAP retest behavior:

Candle low touches or goes below VWAP: low <= vwapVal
Then candle closes above VWAP: close > vwapVal
You control this trigger using:

useVWAPRetest
4) Final Long Signal Logic
A Long Entry signal is generated only when ALL trend + momentum conditions are true:

trendUp AND rsiOkUp AND ( Breakout condition OR VWAP retest condition )
5) Visual Output on the Chart
When longEntry becomes true:

The script draws a “دخول” (Entry) label on the chart
It colors the candle black for the signal bar
6) Alerts (TradingView)
The line below defines the alert trigger:

pinescript
alertcondition(longEntry, title="Long Entry", message="دخول LONG: شروط المضاربة اليومية متحققة")
Important:
To actually receive notifications, you must create an alert from TradingView:

Alerts → Create Alert
Choose this script’s “Long Entry” condition

## Source Code

````pine
//@version=6
indicator("Day Trading (Indicator) - EMA/RSI/VWAP/Breakout", overlay=true, max_labels_count=500)

// =========================
// Inputs
// =========================
emaFastLen = input.int(20,  "EMA Fast Length", minval=1)
emaSlowLen = input.int(50,  "EMA Slow Length", minval=1)

rsiLen     = input.int(14,  "RSI Length", minval=1)
rsiMid     = input.float(50,"RSI Midline")

volLen     = input.int(20,  "Volume SMA Length", minval=1)
volMult    = input.float(1.4,"Volume Multiplier", minval=0.1)

brkLen       = input.int(20,  "Breakout Lookback Bars", minval=2)

useVWAPRetest = input.bool(true, "Use VWAP Retest (Enter on VWAP cross + hold)")
useBreakout   = input.bool(true, "Use Breakout (Enter on breakout + volume)")

// =========================
// Calculations
// =========================
emaFast  = ta.ema(close, emaFastLen)
emaSlow  = ta.ema(close, emaSlowLen)
rsi14    = ta.rsi(close, rsiLen)
vwapVal  = ta.vwap(hlc3)

volSma   = ta.sma(volume, volLen)
volOk    = volume > volSma * volMult

trendUp  = close > emaFast and emaFast > emaSlow
rsiOkUp  = rsi14 > rsiMid

highestPrev = ta.highest(high, brkLen)[1]
breakUp     = close > highestPrev

crossUpRetest = (low <= vwapVal) and (close > vwapVal)

// =========================
// Long entry conditions
// =========================
longCondBreakout = useBreakout and breakUp and volOk
longCondVWAP     = useVWAPRetest and crossUpRetest

longEntry = trendUp and rsiOkUp and (longCondBreakout or longCondVWAP)

// =========================
// Plot & Label
// =========================
plot(emaFast, "EMA Fast", color=color.new(color.teal, 0))
plot(emaSlow, "EMA Slow", color=color.new(color.orange, 0))
plot(vwapVal, "VWAP", color=color.new(color.purple, 0))

if longEntry
    label.new(bar_index, low, "دخول", style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 0))

barcolor(longEntry ? color.black : na)

// =========================
// Alerts
// =========================
alertcondition(longEntry, title="Long Entry", message="دخول LONG: شروط المضاربة اليومية متحققة")
````
