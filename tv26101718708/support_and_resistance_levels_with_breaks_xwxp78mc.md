# Support and Resistance Levels with Breaks

- url: https://www.tradingview.com/script/xWXp78Mc-Support-and-Resistance-Levels-with-Breaks/
- type: indicator
- pine_id: PUB;940fe80e31c640cd8700c281744a0cf1
- version: 2.0

## Description

Shows support and resistance level, making the candle closure and not the wicks

## Source Code

````pine
// © MacJere

//@version=6
indicator(title="Support and Resistance Levels with Breaks", shorttitle="Support and Resistance Levels with Breaks [MacJere]", overlay=true, max_bars_back=1000)

// --- Inputs ---
toggleBreaks  = input.bool(true,  title="Show Standard Breaks")
showBOS       = input.bool(true,  title="Show BOS (Break of Structure)")
showCHoCH     = input.bool(true,  title="Show CHoCH (Change of Character)")
leftBars      = input.int(15,     title="Left Bars")
rightBars     = input.int(15,     title="Right Bars")
volumeThresh  = input.int(20,     title="Volume Threshold")

// Use body high/low instead of wick high/low
bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

// Pivots based on candle body only
rawPivotHigh = ta.pivothigh(bodyHigh, leftBars, rightBars)
rawPivotLow  = ta.pivotlow(bodyLow,  leftBars, rightBars)

// fixnan equivalent: carry forward the last non-na value, offset by 1
var float highUsePivot = na
var float lowUsePivot  = na

if not na(rawPivotHigh[1])
    highUsePivot := rawPivotHigh[1]

if not na(rawPivotLow[1])
    lowUsePivot := rawPivotLow[1]

// --- Plot resistance and support lines ---
// Extracting color logic into strict true/false checks to satisfy v6
color resColor = highUsePivot != highUsePivot[1] ? na : color.new(color.red, 0)
color supColor = lowUsePivot != lowUsePivot[1] ? na : color.new(color.blue, 0)

r1 = plot(highUsePivot, color=resColor, linewidth=3, offset=-(rightBars + 1), title="Resistance")
s1 = plot(lowUsePivot,  color=supColor, linewidth=3, offset=-(rightBars + 1), title="Support")

// Volume oscillator
short = ta.ema(volume, 5)
long  = ta.ema(volume, 10)
osc   = 100 * (short - long) / long

// --- Original Body-based Break Conditions ---
bearBreak = ta.crossunder(close, lowUsePivot)  and (close < open)            and osc > volumeThresh
bullBreak = ta.crossover(close,  highUsePivot) and (close > open)            and osc > volumeThresh
bullWick  = ta.crossover(close,  highUsePivot) and (close <= open)
bearWick  = ta.crossunder(close, lowUsePivot)  and (close >= open)

// Shapes for original breaks with volume
plotshape(toggleBreaks and bearBreak, title="Bear Break", text="B",         style=shape.labeldown, location=location.abovebar, color=color.red,   textcolor=color.white, size=size.tiny)
plotshape(toggleBreaks and bullBreak, title="Bull Break", text="B",         style=shape.labelup,   location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

// Shapes for wick-driven crossovers
plotshape(toggleBreaks and bullWick,  title="Bull Wick",  text="Bull Wick", style=shape.labelup,   location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(toggleBreaks and bearWick,  title="Bear Wick",  text="Bear Wick", style=shape.labeldown, location=location.abovebar, color=color.red,   textcolor=color.white, size=size.tiny)

// --- BOS and CHoCH Logic (Body Close Only) ---
var int trendDir = 0 // 1 for Uptrend, -1 for Downtrend
var float lastRes = na
var float lastSup = na
var bool resActive = false
var bool supActive = false

// Update active pivot states when a new pivot is established
// FIXED: Direct value comparison evaluates strictly to a bool, satisfying v6 "if" logic
if highUsePivot != highUsePivot[1]
    lastRes := highUsePivot
    resActive := true

if lowUsePivot != lowUsePivot[1]
    lastSup := lowUsePivot
    supActive := true

bool isBullBOS   = false
bool isBullCHoCH = false
bool isBearBOS   = false
bool isBearCHoCH = false

// Bullish Structure Break: Body closes above the active resistance
if resActive and close > lastRes
    if trendDir == 1
        isBullBOS := true
    else
        isBullCHoCH := true
        trendDir := 1 // Shift trend to bullish
    resActive := false // Deactivate to prevent duplicate labels on the same level

// Bearish Structure Break: Body closes below the active support
if supActive and close < lastSup
    if trendDir == -1
        isBearBOS := true
    else
        isBearCHoCH := true
        trendDir := -1 // Shift trend to bearish
    supActive := false 

// --- Plot Shapes for BOS & CHoCH ---
// Bullish Structural Changes
plotshape(showBOS and isBullBOS,       title="Bullish BOS",   text="BOS",   style=shape.labelup, location=location.belowbar, color=color.new(color.teal, 0),   textcolor=color.white, size=size.tiny)
plotshape(showCHoCH and isBullCHoCH,   title="Bullish CHoCH", text="CHoCH", style=shape.labelup, location=location.belowbar, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny)

// Bearish Structural Changes
plotshape(showBOS and isBearBOS,       title="Bearish BOS",   text="BOS",   style=shape.labeldown, location=location.abovebar, color=color.new(color.maroon, 0), textcolor=color.white, size=size.tiny)
plotshape(showCHoCH and isBearCHoCH,   title="Bearish CHoCH", text="CHoCH", style=shape.labeldown, location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny)

// --- Alerts ---
alertcondition(ta.crossunder(close, lowUsePivot)  and osc > volumeThresh, title="Support Broken",    message="Support Broken")
alertcondition(ta.crossover(close,  highUsePivot) and osc > volumeThresh, title="Resistance Broken", message="Resistance Broken")
alertcondition(isBullBOS or isBearBOS,                                    title="BOS Occurred",      message="Break of Structure (Body Close)")
alertcondition(isBullCHoCH or isBearCHoCH,                                title="CHoCH Occurred",    message="Change of Character (Body Close)")
````
