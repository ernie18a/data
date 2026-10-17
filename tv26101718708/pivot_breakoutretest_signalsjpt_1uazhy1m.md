# Pivot Breakout/Retest Signals[JPT]

- url: https://www.tradingview.com/script/1uAZhY1m-Pivot-Breakout-Retest-Signals-JPT/
- type: indicator
- pine_id: PUB;e8712f70e7cf4c8a86b15831f0734ceb
- version: 2.0

## Description

[b]🔷 OVERVIEW[/b]

The Pivot Breakout/Retest Signals [JPT] indicator identifies potential LONG and SHORT opportunities using confirmed pivot highs and pivot lows.

It detects when price breaks through a previous pivot level, then waits for price to retest that broken level. A signal is generated when the retest holds and price closes back in the breakout direction. An optional EMA Trend Filter can be enabled to help align signals with the prevailing market trend.

[b]🔷 HOW IT WORKS[/b]

The indicator works in three main stages:

[b]1. Pivot Detection[/b]
Identifies significant swing highs and swing lows using the selected Pivot Length.
The most recent pivot high and pivot low are displayed on the chart as horizontal levels.

[b]2. Breakout Detection[/b]
A bullish breakout occurs when price crosses above the latest pivot high.
A bearish breakout occurs when price crosses below the latest pivot low.
After a breakout, the indicator begins waiting for a possible retest of that level.

[b]3. Retest Confirmation[/b]
For a bullish setup, price must return toward the broken pivot high, remain within the selected retest tolerance, and close back above the level.

For a bearish setup, price must retest the broken pivot low and close back below it.

When the conditions are satisfied, a Long or Short signal is displayed.
The optional EMA filter further requires:

Long: Price must be above the EMA.
Short: Price must be below the EMA.

[b]🔷 HOW TO USE[/b]

LONG SIGNAL 🟢

Look for a sequence where:

Price breaks above a previous pivot high.

Price pulls back toward the breakout level.

The retest occurs within the selected tolerance.

Price closes back above the broken level.

If the EMA filter is enabled, price must also be above the EMA.

A green Long triangle is then displayed below the candle.

SHORT SIGNAL 🔴

Look for a sequence where:

Price breaks below a previous pivot low.

Price moves back toward the broken level.

The retest occurs within the selected tolerance.

Price closes back below the broken level.

If the EMA filter is enabled, price must also be below the EMA.

A red Short triangle is then displayed above the candle.

KEY SETTINGS

Pivot Length: Controls how significant a swing high/low must be before being recognized as a pivot.

Retest Tolerance: Defines how close price needs to come to the breakout level during the retest.

Use EMA Trend Filter: Enables or disables the EMA trend confirmation.
EMA Length: Controls the period of the EMA used for trend filtering.

[b]🔷 IMPORTANT NOTE[/b]

Pivot points require confirmation, meaning newly detected pivots are identified only after the selected pivot length has elapsed. Signals should therefore be evaluated in the context of overall market structure, volatility, volume, and other relevant factors.

The Retest Tolerance setting can significantly affect the number of signals:

Lower tolerance = stricter retests and potentially fewer signals.
Higher tolerance = wider retests and potentially more signals.

[quote][i]Always use appropriate risk management and stop-loss levels and consider confirming signals with additional technical analysis before entering a trade.[/i][/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Pivot Breakout/Retest Signals[JPT]", overlay=true, max_labels_count=500)

// ===== Inputs =====
pivotLen = input.int(14, "Pivot Length", minval=2)
retestTolerance = input.float(0.3, "Retest Tolerance (%)", step=0.1) / 100
emaFilter = input.bool(true, "Use EMA Trend Filter")
emaLength = input.int(50, "EMA Length")

// ===== EMA =====
ema = ta.ema(close, emaLength)
plot(emaFilter ? ema : na, color=color.orange, linewidth=2)

// ===== Pivot Detection =====
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPivotHigh = na
var float lastPivotLow = na

if not na(pivotHigh)
    lastPivotHigh := pivotHigh

if not na(pivotLow)
    lastPivotLow := pivotLow

plot(lastPivotHigh, color=color.red, linewidth=2, style=plot.style_linebr)
plot(lastPivotLow, color=color.lime, linewidth=2, style=plot.style_linebr)

// ===== Breakout Detection =====
bullBreakout = ta.crossover(close, lastPivotHigh)
bearBreakout = ta.crossunder(close, lastPivotLow)

// ===== Store Breakout Levels =====
var float bullLevel = na
var float bearLevel = na

var bool waitingBullRetest = false
var bool waitingBearRetest = false

if bullBreakout
    bullLevel := lastPivotHigh
    waitingBullRetest := true

if bearBreakout
    bearLevel := lastPivotLow
    waitingBearRetest := true

// ===== Retest Logic =====
bullRetest =
     waitingBullRetest and
     low <= bullLevel * (1 + retestTolerance) and
     low >= bullLevel * (1 - retestTolerance) and
     close > bullLevel

bearRetest =
     waitingBearRetest and
     high >= bearLevel * (1 - retestTolerance) and
     high <= bearLevel * (1 + retestTolerance) and
     close < bearLevel

// ===== EMA Filter =====
buySignal = bullRetest and (not emaFilter or close > ema)
sellSignal = bearRetest and (not emaFilter or close < ema)

// ===== Reset =====
if buySignal
    waitingBullRetest := false

if sellSignal
    waitingBearRetest := false

// ===== Plot Signals =====
plotshape(buySignal,
     title="Long",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.small,
     text="Long")

plotshape(sellSignal,
     title="Short",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.red,
     size=size.small,
     text="Short")

// ===== Alerts =====
alertcondition(buySignal, title="Buy Alert", message="Pivot Breakout Retest BUY")
alertcondition(sellSignal, title="Sell Alert", message="Pivot Breakout Retest SELL")
````
