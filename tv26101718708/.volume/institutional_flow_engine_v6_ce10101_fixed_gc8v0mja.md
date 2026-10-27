# Institutional Flow Engine v6 (CE10101 FIXED)

- url: https://www.tradingview.com/script/gC8v0mja-Institutional-Flow-Engine-v6-CE10101-FIXED/
- type: indicator
- pine_id: PUB;397fe62645a84e37a5e154bdcacc94d1
- version: 1.0

## Description

Chat gpt based charting. 9ema, vwap, rvol, rsi, momentum, predictive

## Source Code

````pine
//@version=6
indicator("Institutional Flow Engine v6 (CE10101 FIXED)", overlay=true, max_labels_count=500, max_boxes_count=500)

// =====================================================
// INPUTS
// =====================================================

showFVG       = input.bool(true, "Show FVGs")
showFBD       = input.bool(true, "Show Failed Breaks")
showLiquidity = input.bool(true, "Show Liquidity Sweeps")
showORB       = input.bool(true, "Show ORB (15m)")
showPDHL      = input.bool(true, "Show PDH / PDL")

rvolThresh    = input.float(1.5, "RVOL Threshold")

// =====================================================
// EMAs
// =====================================================

ema9   = ta.ema(close, 9)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)

emaSlope = ema9 - ema9[3]

plot(ema9,   "EMA 9",   color=color.blue,   linewidth=3)
plot(ema20,  "EMA 20",  color=color.yellow)
plot(ema50,  "EMA 50",  color=color.orange)
plot(ema100, "EMA 100", color=color.red)

// =====================================================
// RVOL
// =====================================================

avgVol = ta.sma(volume, 20)
rvol = avgVol > 0 ? volume / avgVol : 0.0
highRVOL = rvol > rvolThresh

// =====================================================
// MOMENTUM
// =====================================================

rsi = ta.rsi(close, 14)
[_, _, hist] = ta.macd(close, 12, 26, 9)

bullMom = rsi > 55 and hist > hist[1]
bearMom = rsi < 45 and hist < hist[1]

// =====================================================
// FLOW CONDITIONS
// =====================================================

bullFlow = emaSlope > 0 and close > ema9 and close > open and highRVOL and bullMom
bearFlow = emaSlope < 0 and close < ema9 and close < open and highRVOL and bearMom

if bullFlow
    label.new(bar_index, low, "LONG FLOW", style=label.style_label_up, color=color.green, textcolor=color.white)

if bearFlow
    label.new(bar_index, high, "SHORT FLOW", style=label.style_label_down, color=color.red, textcolor=color.white)

// =====================================================
// FVG
// =====================================================

bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(bar_index-2, low, bar_index, high[2], bgcolor=color.new(color.green, 85), border_color=color.green)
    label.new(bar_index, low, "BULL FVG", color=color.green, textcolor=color.white)

if showFVG and bearFVG
    box.new(bar_index-2, low[2], bar_index, high, bgcolor=color.new(color.red, 85), border_color=color.red)
    label.new(bar_index, high, "BEAR FVG", color=color.red, textcolor=color.white)

// =====================================================
// FAILED BREAKS
// =====================================================

support = ta.lowest(low, 10)[1]
resist  = ta.highest(high, 10)[1]

failedDown = low < support and close > support and highRVOL
failedUp   = high > resist and close < resist and highRVOL

if showFBD and failedDown
    label.new(bar_index, low, "FAILED BREAKDOWN", color=color.lime, textcolor=color.black)

if showFBD and failedUp
    label.new(bar_index, high, "FAILED BREAKOUT", color=color.maroon, textcolor=color.white)

// =====================================================
// LIQUIDITY SWEEPS
// =====================================================

bullSweep = low < ta.lowest(low, 5)[1] and close > open
bearSweep = high > ta.highest(high, 5)[1] and close < open

if showLiquidity and bullSweep
    label.new(bar_index, low, "LIQ SWEEP", color=color.aqua, textcolor=color.black)

if showLiquidity and bearSweep
    label.new(bar_index, high, "LIQ SWEEP", color=color.purple, textcolor=color.white)

// =====================================================
// PDH / PDL
// =====================================================

pdHigh = request.security(syminfo.tickerid, "D", high[1])
pdLow  = request.security(syminfo.tickerid, "D", low[1])

plot(showPDHL ? pdHigh : na, "PDH", color=color.green, linewidth=2)
plot(showPDHL ? pdLow : na, "PDL", color=color.red, linewidth=2)

// =====================================================
// ORB (CE10101 FIX APPLIED HERE)
// =====================================================

// FIX: ta.change() returns int → must convert to bool
newDay = ta.change(time("D")) != 0

var float orbHigh = na
var float orbLow = na
var int orbStartTime = na

if newDay
    orbHigh := na
    orbLow := na
    orbStartTime := time

orbActive = not na(orbStartTime) and (time < orbStartTime + 15 * 60 * 1000)

if orbActive
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

plot(showORB and not na(orbHigh) ? orbHigh : na, "ORB High", color=color.white, linewidth=2)
plot(showORB and not na(orbLow) ? orbLow : na, "ORB Low", color=color.white, linewidth=2)

// =====================================================
// BACKGROUND FLOW
// =====================================================

bgcolor(bullFlow ? color.new(color.green, 90) : bearFlow ? color.new(color.red, 90) : na)

// =====================================================
// ALERTS
// =====================================================

alertcondition(bullFlow, "Bull Flow", "Bullish Flow Detected")
alertcondition(bearFlow, "Bear Flow", "Bearish Flow Detected")
alertcondition(failedDown, "Failed Breakdown", "Failed Breakdown Detected")
alertcondition(failedUp, "Failed Breakout", "Failed Breakout Detected")
alertcondition(bullFVG, "Bull FVG", "Bullish FVG Detected")
alertcondition(bearFVG, "Bear FVG", "Bearish FVG Detected")
````
