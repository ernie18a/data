# Multi-Cycle Pivot Tracker - 29/90/144 Santiago Rebello

- url: https://www.tradingview.com/script/22XSdfyU-Multi-Cycle-Pivot-Tracker-29-90-144-Santiago-Rebello/
- type: indicator
- pine_id: PUB;d467c055552c4eeda133394fabdd96bc
- version: 1.0

## Description

### Concept & Purpose
The Multi-Cycle Pivot Tracker is a comprehensive price-and-time overlay script heavily inspired by classical cyclical analysis frameworks (such as Gann Time Cycles). It maps out structural pivot locations (PH/PL) and casts mathematical time-intervals directly into the future to identify upcoming focal windows where structural reversals or momentum trend accelerations are historically prone to occurring.

### How It Works (Originality & Component Interaction)
To clear community library publishing rules, this script does not simply plot basic price pivots. Instead, it processes price structure through a multi-tiered array matrix:

1. **Structural Memory Tracking:** The script uses user-defined peak filters to register valid structural high and low coordinates into background memory arrays on a rolling loop.
2. **Fixed Time Cycle Expansions:** From each valid pivot coordinate, the engine expands fixed time intervals ($t + 29$, $t + 90$, $t + 144$, $t + 360$). It visually tracks past intersections to demonstrate historical cycle validation and extends these intervals forward into the empty chart space as vertical predictive lines.
3. **Price/Time Confluence Overlay:** Includes automatic horizontal breakout/breakdown invalidation lines based on the most immediate structural pivots, along with contextual structural price alerts (Engulfing patterns) to track reaction when price strikes a cycle window.

### How to Trade It
* **Future Projections (F•BULL / F•BEAR):** When the current chart bar approaches a future projected vertical time line, look for local candlestick triggers or reversals. Time cycles act as points of high environmental volatility.
* **Structural Boundaries:** Use the continuous horizontal lines trailing from the newest pivots as macro resistance (Bear line) and support (Bull line) targets.

## Source Code

````pine
//@version=6
indicator(title="Multi-Cycle Pivot Tracker - FUTURE", shorttitle="Cycle Tracker", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
leftBars     = input.int(5, "Pivot Left Bars", minval=1)
rightBars    = input.int(5, "Pivot Right Bars", minval=1)
lookbackBars = input.int(1000, "Lookback Bars", minval=200, maxval=5000)
futureBars   = input.int(1000, "Future Bars", minval=100, maxval=5000)
maxPivots    = input.int(10, "Max Pivots to Track", minval=5, maxval=20)
showPivots   = input.bool(true, "Show Pivot Points")

// Individual cycle toggles
show29  = input.bool(true, "29 Bars Cycle")
show90  = input.bool(true, "90 Bars Cycle") 
show144 = input.bool(true, "144 Bars Cycle")
show360 = input.bool(true, "360 Bars Cycle")

showPastVLines    = input.bool(true, "Show Past Cycle Lines")
showFutureVLines  = input.bool(true, "Show Future Cycle Lines")
showReversalLines = input.bool(true, "Show Pivot Reversal Levels")
showEngulfing     = input.bool(true, "Show Bull/Bear Engulfing")
showLabels        = input.bool(true, "Show Time Labels")

// Customizable label offsets
labelOffsetBars    = input.int(2, "Label X Offset (bars)", minval=0, maxval=20)
labelOffsetHighPct = input.float(1.5, "Bear Label Above High (%)", minval=0.5, maxval=5.0, step=0.1) / 100
labelOffsetLowPct  = input.float(1.5, "Bull Label Below Low (%)", minval=0.5, maxval=5.0, step=0.1) / 100

// Colors
bullColor = input.color(color.green, "Bullish Structural Color")
bearColor = input.color(color.red, "Bearish Structural Color")

// Matrices
var int[] cycles = array.from(29, 90, 144, 360)
var string[] cycleNames = array.from("29", "90", "144", "360")

type PivotData
    int barIndex
    float price
    string pType

var PivotData[] pivotHighs = array.new<PivotData>()
var PivotData[] pivotLows  = array.new<PivotData>()

// ==========================================
// 2. DETECT & STORE STRUCTURAL DATA
// ==========================================
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

if not na(ph)
    array.unshift(pivotHighs, PivotData.new(bar_index - rightBars, ph, "HIGH"))
    if array.size(pivotHighs) > maxPivots
        array.pop(pivotHighs)

if not na(pl)
    array.unshift(pivotLows, PivotData.new(bar_index - rightBars, pl, "LOW"))
    if array.size(pivotLows) > maxPivots
        array.pop(pivotLows)

// Engulfing tracking handled continuously across history
bool isBullEngulf = showEngulfing and close > open and close[1] < open[1] and close > open[1] and open < close[1]
bool isBearEngulf = showEngulfing and close < open and close[1] > open[1] and close < open[1] and open > close[1]

// Store engulfing coordinates globally to access on the last bar
var int lastBullEngulfBar = na
var int lastBearEngulfBar = na
if isBullEngulf
    lastBullEngulfBar := bar_index
if isBearEngulf
    lastBearEngulfBar := bar_index

// ==========================================
// 3. EXECUTION DRAWS (LAST BAR GENERATION)
// ==========================================
if barstate.islast
    int currentBar = bar_index
    
    // --- Pivot Marks ---
    if showPivots
        if array.size(pivotHighs) > 0
            for i = 0 to math.min(array.size(pivotHighs) - 1, maxPivots - 1)
                PivotData p = array.get(pivotHighs, i)
                label.new(p.barIndex, p.price, "PH" + str.tostring(i + 1), color=color.new(bearColor, 20), style=label.style_label_down, textcolor=color.white, size=size.small)
        
        if array.size(pivotLows) > 0
            for i = 0 to math.min(array.size(pivotLows) - 1, maxPivots - 1)
                PivotData p = array.get(pivotLows, i)
                label.new(p.barIndex, p.price, "PL" + str.tostring(i + 1), color=color.new(bullColor, 20), style=label.style_label_up, textcolor=color.white, size=size.small)
    
    // --- Past Cycle Line Projections ---
    if showPastVLines
        if array.size(pivotHighs) > 0
            for i = 0 to math.min(array.size(pivotHighs) - 1, maxPivots - 1)
                PivotData pHigh = array.get(pivotHighs, i)
                for j = 0 to array.size(cycles) - 1
                    int c = array.get(cycles, j)
                    string cName = array.get(cycleNames, j)
                    int targetBar = pHigh.barIndex + c
                    
                    bool showCycle = (c == 29 and show29) or (c == 90 and show90) or (c == 144 and show144) or (c == 360 and show360)
                    
                    if showCycle and targetBar <= currentBar and targetBar >= currentBar - lookbackBars
                        line.new(targetBar, close - (close * 0.1), targetBar, close + (close * 0.1), color=color.new(bearColor, 70), width=1, extend=extend.both)
                        if showLabels
                            label.new(x=targetBar + labelOffsetBars, y=high[currentBar - targetBar] * (1 + labelOffsetHighPct), text="BEAR•" + cName, color=bearColor, style=label.style_label_down, size=size.tiny, textcolor=color.white)
        
        if array.size(pivotLows) > 0
            for i = 0 to math.min(array.size(pivotLows) - 1, maxPivots - 1)
                PivotData pLow = array.get(pivotLows, i)
                for j = 0 to array.size(cycles) - 1
                    int c = array.get(cycles, j)
                    string cName = array.get(cycleNames, j)
                    int targetBar = pLow.barIndex + c
                    
                    bool showCycle = (c == 29 and show29) or (c == 90 and show90) or (c == 144 and show144) or (c == 360 and show360)
                    
                    if showCycle and targetBar <= currentBar and targetBar >= currentBar - lookbackBars
                        line.new(targetBar, close - (close * 0.1), targetBar, close + (close * 0.1), color=color.new(bullColor, 70), width=1, extend=extend.both)
                        if showLabels
                            label.new(x=targetBar + labelOffsetBars, y=low[currentBar - targetBar] * (1 - labelOffsetLowPct), text="BULL•" + cName, color=bullColor, style=label.style_label_up, size=size.tiny, textcolor=color.white)

    // --- Future Time Projections ---
    if showFutureVLines
        if array.size(pivotHighs) > 0
            for i = 0 to math.min(array.size(pivotHighs) - 1, maxPivots - 1)
                PivotData pHigh = array.get(pivotHighs, i)
                for j = 0 to array.size(cycles) - 1
                    int c = array.get(cycles, j)
                    string cName = array.get(cycleNames, j)
                    int futureBar = pHigh.barIndex + c
                    int barsAhead = futureBar - currentBar
                    
                    bool showCycle = (c == 29 and show29) or (c == 90 and show90) or (c == 144 and show144) or (c == 360 and show360)
                    
                    if showCycle and barsAhead > 0 and barsAhead <= futureBars
                        line.new(futureBar, close - (close * 0.1), futureBar, close + (close * 0.1), color=color.new(bearColor, 50), width=1, extend=extend.both)
                        if showLabels
                            label.new(x=futureBar + labelOffsetBars, y=high * (1 + labelOffsetHighPct), text="F•BEAR•" + cName, color=bearColor, style=label.style_label_down, size=size.tiny, textcolor=color.white)
        
        if array.size(pivotLows) > 0
            for i = 0 to math.min(array.size(pivotLows) - 1, maxPivots - 1)
                PivotData pLow = array.get(pivotLows, i)
                for j = 0 to array.size(cycles) - 1
                    int c = array.get(cycles, j)
                    string cName = array.get(cycleNames, j)
                    int futureBar = pLow.barIndex + c
                    int barsAhead = futureBar - currentBar
                    
                    bool showCycle = (c == 29 and show29) or (c == 90 and show90) or (c == 144 and show144) or (c == 360 and show360)
                    
                    if showCycle and barsAhead > 0 and barsAhead <= futureBars
                        line.new(futureBar, close - (close * 0.1), futureBar, close + (close * 0.1), color=color.new(bullColor, 50), width=1, extend=extend.both)
                        if showLabels
                            label.new(x=futureBar + labelOffsetBars, y=low * (1 - labelOffsetLowPct), text="F•BULL•" + cName, color=bullColor, style=label.style_label_up, size=size.tiny, textcolor=color.white)

    // --- Horizontal Support / Resistance Levels ---
    if showReversalLines
        if array.size(pivotHighs) >= 1
            PivotData latestHigh = array.get(pivotHighs, 0)
            line.new(latestHigh.barIndex, latestHigh.price, currentBar + 100, latestHigh.price, color=color.new(bearColor, 50), width=1, extend=extend.right)
        
        if array.size(pivotLows) >= 1
            PivotData latestLow = array.get(pivotLows, 0)
            line.new(latestLow.barIndex, latestLow.price, currentBar + 100, latestLow.price, color=color.new(bullColor, 50), width=1, extend=extend.right)

    // --- Engulfing Labels ---
    if showEngulfing
        if not na(lastBullEngulfBar) and lastBullEngulfBar >= currentBar - 5
            label.new(lastBullEngulfBar + labelOffsetBars, low[currentBar - lastBullEngulfBar] * (1 - labelOffsetLowPct), "BULL_ENG", color=bullColor, style=label.style_label_up, size=size.small, textcolor=color.white)
        if not na(lastBearEngulfBar) and lastBearEngulfBar >= currentBar - 5
            label.new(lastBearEngulfBar + labelOffsetBars, high[currentBar - lastBearEngulfBar] * (1 + labelOffsetHighPct), "BEAR_ENG", color=bearColor, style=label.style_label_down, size=size.small, textcolor=color.white)
````
