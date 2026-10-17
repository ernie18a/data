# Dynamic Fib Fan - Market Structure (BOS/CHoCH)

- url: https://www.tradingview.com/script/s0qh4tP5-Dynamic-Fib-Fan-Market-Structure-BOS-CHoCH/
- type: indicator
- pine_id: PUB;ff527388105a4588bf66eba465edcc1e
- version: 1.0

## Description

Fibonacci Fan Resistance indicator use as resistance or support integrated with support or resistance.

How this works
Pivot Period (Lookback): By default, this uses 10 candles on the left and right to confirm a swing high/low. You can tighten this to 5 for faster, short-term trends, or expand it to 20 for macroeconomic moves.

BoS & CHoCH Logic:

A Break of Structure (BoS) happens when a trend continues by breaking and closing past the most recently confirmed Pivot point.

A Change of Character (CHoCH) happens when the price reverses and breaks the structural extreme of the opposing side (e.g., in a Bull market, closing beneath the last valid Higher Low).

The Fibonacci Fan Dynamics: The script relies on barstate.islast to redraw the fan on the active ticker in real-time.

If the market is Bullish, the script locks the start of the Fan to the absolute lowest point before the run started. It tracks the highest high dynamically, extending the Fan support upwards.

If a Bearish CHoCH occurs, the script instantly anchors a new Fan to the highest peak of that bull run, and projects the Fan downwards tracking the fresh lows as resistance.

## Source Code

````pine
//@version=6
indicator("Dynamic Fib Fan - Market Structure (BOS/CHoCH)", overlay=true, max_lines_count=50, max_labels_count=500)

// =========================================================================
// INPUTS
// =========================================================================
grp_pivots = "Pivot & Market Structure Settings"
prd = input.int(10, title="Pivot Period (Lookback)", minval=2, group=grp_pivots, tooltip="Bars needed on left/right to confirm a swing point.")
showLabels = input.bool(true, title="Show BOS/CHoCH Labels", group=grp_pivots)

grp_fib = "Fibonacci Fan Settings"
colorBull = input.color(color.new(color.teal, 0), title="Bullish Fan Color", group=grp_fib)
colorBear = input.color(color.new(color.red, 0), title="Bearish Fan Color", group=grp_fib)

f1 = input.float(0.236, title="Level 1", group=grp_fib)
f2 = input.float(0.382, title="Level 2", group=grp_fib)
f3 = input.float(0.500, title="Level 3", group=grp_fib)
f4 = input.float(0.618, title="Level 4 (Golden)", group=grp_fib)
f5 = input.float(0.786, title="Level 5", group=grp_fib)

// =========================================================================
// PIVOT DETECTION
// =========================================================================
ph = ta.pivothigh(high, prd, prd)
pl = ta.pivotlow(low, prd, prd)

// Track most recent confirmed pivots
var float recentPH_Y = na
var int   recentPH_X = na
var float recentPL_Y = na
var int   recentPL_X = na

// Flags to ensure we only signal BOS once per pivot
var bool phBroken = true
var bool plBroken = true

if not na(ph)
    recentPH_Y := ph
    recentPH_X := bar_index[prd]
    phBroken := false // New pivot high formed, ready to be broken for a bullish BOS

if not na(pl)
    recentPL_Y := pl
    recentPL_X := bar_index[prd]
    plBroken := false // New pivot low formed, ready to be broken for a bearish BOS

// =========================================================================
// MARKET STRUCTURE STATE (BOS & CHoCH)
// =========================================================================
var int trend = 0 // 1 = Bullish, -1 = Bearish

// Track absolute extremes of the current leg to act as Fan Anchors/Targets
var float extremeHigh_Y = na
var int   extremeHigh_X = na
var float extremeLow_Y  = na
var int   extremeLow_X  = na

// Fib Fan Anchor coordinates
var int   startX = na
var float startY = na

// Initialize on first pivots
if trend == 0
    if not na(ph) and na(pl)
        trend := -1
        startX := recentPH_X
        startY := recentPH_Y
        extremeLow_Y := low
        extremeLow_X := bar_index
    else if not na(pl) and na(ph)
        trend := 1
        startX := recentPL_X
        startY := recentPL_Y
        extremeHigh_Y := high
        extremeHigh_X := bar_index

// Update extreme trackers for the current trend
if na(extremeHigh_Y) or high > extremeHigh_Y
    extremeHigh_Y := high
    extremeHigh_X := bar_index

if na(extremeLow_Y) or low < extremeLow_Y
    extremeLow_Y := low
    extremeLow_X := bar_index

bool isBullChoCh = false
bool isBearChoCh = false

// Check for CHoCH
if trend == -1
    // In Bear trend, if price closes above the last confirmed swing high -> Bull CHoCH
    if not na(recentPH_Y) and close > recentPH_Y
        isBullChoCh := true
        trend := 1
        // Set new anchor to the absolute lowest point of the bear trend
        startX := extremeLow_X
        startY := extremeLow_Y
        // Reset extreme high tracker for the new bull trend
        extremeHigh_Y := high
        extremeHigh_X := bar_index
        phBroken := true
        plBroken := true

else if trend == 1
    // In Bull trend, if price closes below the last confirmed swing low -> Bear CHoCH
    if not na(recentPL_Y) and close < recentPL_Y
        isBearChoCh := true
        trend := -1
        // Set new anchor to the absolute highest point of the bull trend
        startX := extremeHigh_X
        startY := extremeHigh_Y
        // Reset extreme low tracker for the new bear trend
        extremeLow_Y := low
        extremeLow_X := bar_index
        phBroken := true
        plBroken := true

// Check for BOS
bool isBullBOS = false
bool isBearBOS = false

if trend == 1 and not phBroken and not isBullChoCh
    if close > recentPH_Y
        isBullBOS := true
        phBroken := true

if trend == -1 and not plBroken and not isBearChoCh
    if close < recentPL_Y
        isBearBOS := true
        plBroken := true

// =========================================================================
// DRAW LABELS
// =========================================================================
if showLabels
    if isBullChoCh
        label.new(bar_index, low, "CHoCH", color=color.new(color.green, 50), style=label.style_label_up, textcolor=color.white, size=size.small)
    if isBearChoCh
        label.new(bar_index, high, "CHoCH", color=color.new(color.red, 50), style=label.style_label_down, textcolor=color.white, size=size.small)
    if isBullBOS
        label.new(bar_index, high, "BOS", color=color.new(colorBull, 50), style=label.style_label_down, textcolor=color.white, size=size.tiny)
    if isBearBOS
        label.new(bar_index, low, "BOS", color=color.new(colorBear, 50), style=label.style_label_up, textcolor=color.white, size=size.tiny)

// =========================================================================
// DRAW DYNAMIC FIBONACCI FAN
// =========================================================================
// Maintain lines to delete and redraw them seamlessly
var line lineBase = na
var line lineF1 = na
var line lineF2 = na
var line lineF3 = na
var line lineF4 = na
var line lineF5 = na

if barstate.islast
    // Clean up old lines before redrawing
    line.delete(lineBase)
    line.delete(lineF1)
    line.delete(lineF2)
    line.delete(lineF3)
    line.delete(lineF4)
    line.delete(lineF5)
    
    // Determine the End point of the fan based on current trend extreme
    int   endX = trend == 1 ? extremeHigh_X : extremeLow_X
    float endY = trend == 1 ? extremeHigh_Y : extremeLow_Y
    
    if not na(startX) and not na(endX) and startX != endX
        colorFan = trend == 1 ? colorBull : colorBear
        
        // Calculate Y projections at the X-coordinate of the end point
        float yDiff = endY - startY
        
        float yF1 = startY + (yDiff * f1)
        float yF2 = startY + (yDiff * f2)
        float yF3 = startY + (yDiff * f3)
        float yF4 = startY + (yDiff * f4)
        float yF5 = startY + (yDiff * f5)
        
        // Draw the Base trendline (0 to 100%)
        lineBase := line.new(startX, startY, endX, endY, color=colorFan, extend=extend.right, style=line.style_dashed, width=1)
        
        // Draw the Fan lines (projected to the right as infinite rays)
        lineF1 := line.new(startX, startY, endX, yF1, color=colorFan, extend=extend.right, width=1)
        lineF2 := line.new(startX, startY, endX, yF2, color=colorFan, extend=extend.right, width=1)
        lineF3 := line.new(startX, startY, endX, yF3, color=colorFan, extend=extend.right, width=1)
        lineF4 := line.new(startX, startY, endX, yF4, color=colorFan, extend=extend.right, width=2) // Golden pocket emphasized
        lineF5 := line.new(startX, startY, endX, yF5, color=colorFan, extend=extend.right, width=1)
````
