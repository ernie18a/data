# MJRT ORB - NQ Optimized

- url: https://www.tradingview.com/script/ZJxcjaBm-MJRT-ORB-NQ-Optimized/
- type: indicator
- pine_id: PUB;e5b24f92b59f430a94e150d748ef2b95
- version: 1.0

## Description

works in any time frame Asia, London, NY. 
5, 15 minutes ORB.

## Source Code

````pine
//@version=5
indicator("MJRT ORB - NQ Optimized", overlay=true)

// --- Inputs ---
orbSession     = input.session("0930-0935", "ORB Capture Window")
displaySession = input.session("0930-1100", "Display Window")
highLabelText  = input.string("MJRT HIGH", "High Label")
lowLabelText   = input.string("MJRT LOW", "Low Label")

// --- Time Logic ---
// Specifically target New York time for NQ
in_orb     = time(timeframe.period, orbSession, "America/New_York")
in_display = time(timeframe.period, displaySession, "America/New_York")
is_new_day = ta.change(time("D", "America/New_York")) != 0

var float orbHigh = na
var float orbLow  = na

// Capture the High/Low of the 9:30-9:35 candle
if in_orb
    if not in_orb[1] or is_new_day
        orbHigh := high
        orbLow  := low
    else
        orbHigh := math.max(high, orbHigh)
        orbLow  := math.min(low, orbLow)

// --- Signals Logic ---
var bool hasBrokenOut = false
var bool retested = false
var int trendDirection = 0 

// Reset everything at market open
if in_orb and not in_orb[1]
    hasBrokenOut := false
    retested := false
    trendDirection := 0

if not in_orb and not na(orbHigh)
    if high > orbHigh and trendDirection == 0
        hasBrokenOut := true
        trendDirection := 1
    if low < orbLow and trendDirection == 0
        hasBrokenOut := true
        trendDirection := -1

is_inside = close <= orbHigh and close >= orbLow

// Retest logic: Price must have broken out, then touch the level, but not close inside
if hasBrokenOut and not is_inside
    if trendDirection == 1 and low <= orbHigh
        retested := true
    if trendDirection == -1 and high >= orbLow
        retested := true

longSignal  = retested and trendDirection == 1 and close > open and not is_inside and in_display
shortSignal = retested and trendDirection == -1 and close < open and not is_inside and in_display

if longSignal or shortSignal
    retested := false
    hasBrokenOut := false
    trendDirection := 0

// --- Plotting ---
// Using plot with style_linebr (Line Break) ensures lines only show during 09:30-11:00
plotHigh = in_display ? orbHigh : na
plotLow  = in_display ? orbLow : na

plot(plotHigh, color=color.new(color.green, 0), linewidth=2, title="ORB High", style=plot.style_linebr)
plot(plotLow, color=color.new(color.red, 0), linewidth=2, title="ORB Low", style=plot.style_linebr)

// Labels (Drawn only once at the start of the lines)
var label hiL = na
var label loL = na
if in_display and not in_display[1]
    label.delete(hiL)
    label.delete(loL)
    hiL := label.new(bar_index, orbHigh, highLabelText, color=color.green, style=label.style_label_down, textcolor=color.white, size=size.small)
    loL := label.new(bar_index, orbLow, lowLabelText, color=color.red, style=label.style_label_up, textcolor=color.white, size=size.small)

plotshape(longSignal, "Buy", shape.triangleup, location.belowbar, color.green, size=size.small, text="MJRT BUY")
plotshape(shortSignal, "Sell", shape.triangledown, location.abovebar, color.red, size=size.small, text="MJRT SELL")
````
