# Level Breakout & Consolidation

- url: https://www.tradingview.com/script/vy6UByYL-level-breakout-consolidation/
- type: indicator
- pine_id: PUB;4c8a22de14b94212874d5236ff18a561
- version: 1.0

## Description

1. Daily Levels: It uses request.security to extract 1D (Daily) pivot highs and lows without repainting. You can adjust the pivot length in the settings to control how significant a swing must be to become a tracked level.

2. Compression Tracking: Right as the breakout occurs, the script looks back on the current timeframe (e.g., the 5-minute chart) to check if the last N bars formed higher lows (for a resistance breakout) or lower highs (for a support breakout).

3. Consolidation: Once the price closes past the daily level, the script starts counting the bars. It waits for the specified Consolidation Bars (e.g., 3 bars) to ensure the price sustains the breakout and doesn't immediately pull back. If the lowest close over those 3 bars remains above the breakout level, it triggers the buy arrow.

4. False Breakouts: I've also built in a hidden cross shape condition for false breakouts (wicks that poke through but close back within). You can turn on the visibility for this inside the indicator settings under "Style" if you'd like to spot them.

You can customize the number of compression bars and consolidation bars via the indicator inputs.

## Source Code

````pine
//@version=6
indicator("Level Breakout & Consolidation", overlay = true)

// --- Inputs ---
// Level Settings
leftLen = input.int(15, "Daily Pivot Left Length", group = "Daily Level Settings")
rightLen = input.int(5, "Daily Pivot Right Length", group = "Daily Level Settings")

// Setup Settings
consolidationBars = input.int(3, "Consolidation Bars", minval = 1, tooltip = "Number of bars price must stay above/below the level after breakout", group = "Setup Settings")
compressionBars = input.int(3, "Compression Bars", minval = 0, tooltip = "Number of bars with higher lows (for longs) or lower highs (for shorts) before breakout", group = "Setup Settings")

// --- Daily Level Calculation ---
// We request the historical pivot from the Daily timeframe to avoid repainting
[ph, pl] = request.security(syminfo.tickerid, "1D", [ta.pivothigh(high, leftLen, rightLen), ta.pivotlow(low, leftLen, rightLen)])

var float dRes = na
var float dSup = na

if not na(ph)
    dRes := ph
if not na(pl)
    dSup := pl

// Plot Daily Levels
plot(dRes, "Daily Resistance", color = color.new(color.blue, 30), style = plot.style_linebr, linewidth = 2)
plot(dSup, "Daily Support", color = color.new(color.orange, 30), style = plot.style_linebr, linewidth = 2)

// --- Logic ---
// Breakouts
bullBreakout = ta.crossover(close, dRes)
bearBreakout = ta.crossunder(close, dSup)

// Tracking Breakouts
var int barsSinceBullBreakout = na
var int barsSinceBearBreakout = na

if bullBreakout
    barsSinceBullBreakout := 0
else if not na(barsSinceBullBreakout)
    barsSinceBullBreakout += 1
    // Reset if price drops significantly below the level
    if close < dRes * 0.999
        barsSinceBullBreakout := na

if bearBreakout
    barsSinceBearBreakout := 0
else if not na(barsSinceBearBreakout)
    barsSinceBearBreakout += 1
    // Reset if price rises significantly above the level
    if close > dSup * 1.001
        barsSinceBearBreakout := na

// Compression Check (Pre-breakout)
var bool hadBullCompression = false
var bool hadBearCompression = false

if bullBreakout
    comp = true
    if compressionBars > 0
        for i = 1 to compressionBars
            if low[i] <= low[i+1]
                comp := false
                break
    hadBullCompression := comp

if bearBreakout
    comp = true
    if compressionBars > 0
        for i = 1 to compressionBars
            if high[i] >= high[i+1]
                comp := false
                break
    hadBearCompression := comp

// Consolidation Check (Post-breakout)
bullConsolidation = not na(barsSinceBullBreakout) and barsSinceBullBreakout == consolidationBars and ta.lowest(close, consolidationBars) > dRes and hadBullCompression
bearConsolidation = not na(barsSinceBearBreakout) and barsSinceBearBreakout == consolidationBars and ta.highest(close, consolidationBars) < dSup and hadBearCompression

// --- Signals ---
plotshape(bullConsolidation, "Buy Signal", shape.triangleup, location.belowbar, color.new(#089981, 0), size = size.small)
plotshape(bearConsolidation, "Sell Signal", shape.triangledown, location.abovebar, color.new(#f23645, 0), size = size.small)

// False Breakouts (Wick above/below level but close below/above)
bullFalseBreakout = high > dRes and close < dRes and open < dRes
bearFalseBreakout = low < dSup and close > dSup and open > dSup

plotshape(bullFalseBreakout ? dRes : na, "False Bull Breakout", shape.xcross, location.absolute, color.new(color.gray, 50), size = size.tiny, display = display.none)
plotshape(bearFalseBreakout ? dSup : na, "False Bear Breakout", shape.xcross, location.absolute, color.new(color.gray, 50), size = size.tiny, display = display.none)
````
