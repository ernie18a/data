# TriConfluence

- url: https://www.tradingview.com/script/XFLhk9Hg-TriConfluence/
- type: indicator
- pine_id: PUB;4fd5c9ab93a74693a8363dc2d38bfc45
- version: 1.0

## Description

This script takes account of the original 5 min candle (green or red) 15m ORB breakout and IB (1hour) break. If all three align it gives a buy or sell signal. Meant for those with patience looking for a high level win rate for daytrading. I use this and shoot for 30-50 points on NQ. Doesnt always gives indications to enter but when it does win rate is high.

## Source Code

````pine
//@version=6
indicator("TriConfluence", shorttitle="TriConf", overlay=true, max_labels_count=500, max_lines_count=500)

// ==================== INPUTS ====================
useRTH     = input.bool(true,  "Use Regular Trading Hours")
rthSession = input.session("0930-1600", "RTH Session (ET)")

orbBars    = input.int(3,  "ORB Bars (15m on 5m chart = 3)",  minval=1, maxval=20)
ibBars     = input.int(9,  "IB Bars (45m on 5m chart = 9)",   minval=2, maxval=40)

showLevels = input.bool(true,  "Show ORB & IB Levels")
showSignals= input.bool(true,  "Show Long/Short Signals")

// ==================== SESSION ====================
newDay     = ta.change(time("D")) != 0
inSession  = not useRTH or not na(time("1", rthSession))

// ==================== VARIABLES ====================
var float orbHigh = na
var float orbLow  = na
var float ibHigh  = na
var float ibLow   = na
var bool  orbBull = false
var bool  orbSet  = false
var bool  ibSet   = false
var int   barCount = 0

// Reset on new day
if newDay
    orbHigh := na
    orbLow  := na
    ibHigh  := na
    ibLow   := na
    orbBull := false
    orbSet  := false
    ibSet   := false
    barCount := 0

// Count bars in session
if inSession
    barCount := barCount + 1

// ==================== BUILD ORB ====================
if inSession and not orbSet
    if na(orbHigh)
        orbHigh := high
        orbLow  := low
        orbBull := close > open
    else
        orbHigh := math.max(orbHigh, high)
        orbLow  := math.min(orbLow, low)

    if barCount >= orbBars
        orbSet := true

// ==================== BUILD IB ====================
if inSession and not ibSet
    if na(ibHigh)
        ibHigh := high
        ibLow  := low
    else
        ibHigh := math.max(ibHigh, high)
        ibLow  := math.min(ibLow, low)

    if barCount >= ibBars
        ibSet := true

// ==================== BREAK CONDITIONS ====================
orbCrossUp   = ta.crossover(high, orbHigh)
orbCrossDown = ta.crossunder(low, orbLow)
ibCrossUp    = ta.crossover(high, ibHigh)
ibCrossDown  = ta.crossunder(low, ibLow)

orbBreakUp   = orbSet and orbCrossUp and orbBull
orbBreakDown = orbSet and orbCrossDown and not orbBull

ibBreakUp    = ibSet and ibCrossUp
ibBreakDown  = ibSet and ibCrossDown

// Triple Confluence
bullishTriple = orbSet and ibSet and orbBreakUp and ibBreakUp
bearishTriple = orbSet and ibSet and orbBreakDown and ibBreakDown

// ==================== PLOTTING ====================
plot(showLevels ? orbHigh : na, "ORB High", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)
plot(showLevels ? orbLow  : na, "ORB Low",  color=color.new(color.red,   0), linewidth=2, style=plot.style_linebr)

plot(showLevels ? ibHigh : na, "IB High", color=color.new(color.lime, 40), linewidth=1, style=plot.style_linebr)
plot(showLevels ? ibLow  : na, "IB Low",  color=color.new(color.maroon,40), linewidth=1, style=plot.style_linebr)

// Signals
plotshape(showSignals and bullishTriple, title="LONG",  location=location.belowbar, color=color.green, style=shape.triangleup,   size=size.large, text="LONG")
plotshape(showSignals and bearishTriple, title="SHORT", location=location.abovebar, color=color.red,   style=shape.triangledown, size=size.large, text="SHORT")

// Background
bgcolor(inSession and not orbSet ? color.new(color.blue, 92) : na, title="ORB Forming")
bgcolor(inSession and orbSet and not ibSet ? color.new(color.purple, 92) : na, title="IB Forming")

// Alerts
alertcondition(bullishTriple, "Bullish Triple", "🚀 LONG - Bullish Triple Confluence")
alertcondition(bearishTriple, "Bearish Triple", "🔻 SHORT - Bearish Triple Confluence")
````
