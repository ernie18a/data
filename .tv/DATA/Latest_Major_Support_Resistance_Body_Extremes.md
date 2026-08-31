<!-- tradingview-pine-id: PUB;230a75e675454f0a99b2196d4cc57aba -->
<!-- tradingviewscripts-format: 1 -->
# Latest Major Support & Resistance (Body Extremes)

Source: https://www.tradingview.com/script/h2KaTxuZ-Latest-Major-Support-Resistance-Body-Extremes/

## Description

This Pinescript V6 does the following:

1. Pivot Detection via Candle Body Extremes. Unlike traditional support and resistance indicators that use candle wicks (high and low), this script measures price action using candle bodies to filter out market noise:
Resistance: Identified by looking for a local peak using bar close prices (ta.pivothigh(close, ...)).
Support: Identified by looking for a local valley using bar open prices (ta.pivotlow(open, ...)).
Validation Window: A pivot is confirmed only after 10 bars to the left and 10 bars to the right validate the peak or trough.

2. Visual Level Tracking & Clean Layout. 
Whenever a new valid pivot is confirmed: 
Lines & Labels: Draws a horizontal line starting at the pivot point extending rightward across the chart. Right-Aligned Labels: Places text tags (Support or Resistance) anchored to the far right edge of your chart for immediate visibility.
Colour Coding: Standardized to Green for Support and Red for Resistance.
Memory Management: Automatically cleans up older levels so you only keep the 2 most recent active Support lines and 2 most recent active Resistance lines on screen at any time.

3. Dynamic Auto-Flip (Role Reversal) Logic
The script actively evaluates price action against each drawn line on every bar close:
Support Breakout: If price drops below an active Support line (ta.crossunder), the level automatically turns Red and updates its label to Resistance. 
Resistance Breakout: If price breaks above an active Resistance line (ta.crossover), the level automatically turns Green and updates its label.

---

## Source Code

````pine
//@version=6
indicator("Latest Major Support & Resistance (Body Extremes)", overlay=true, max_lines_count=100, max_labels_count=100)

// ==========================================
// User Inputs
// ==========================================
leftBars    = input.int(10, title="Pivot Left Bars", minval=1, tooltip="Number of bars to the left required for pivot validation")
rightBars   = input.int(10, title="Pivot Right Bars", minval=1, tooltip="Number of bars to the right required for pivot validation")
maxLevels   = input.int(2, title="Max Active Levels (Each)", minval=1, maxval=20, tooltip="Set to 2 to show the 2 most recent Support & Resistance lines")
supColor    = input.color(color.green, title="Support Color")
resColor    = input.color(color.red, title="Resistance Color")
lineWidth   = input.int(2, title="Line Width", minval=1, maxval=5)
extendLines = input.bool(true, title="Extend Lines Rightward", tooltip="Extends active lines across the chart")

// Custom Types to keep line & label paired
type LevelMarker
    line  ln
    label lbl
    bool  isSupport

// Storage Arrays for separate Resistance and Support tracks
var LevelMarker[] resLevels = array.new<LevelMarker>()
var LevelMarker[] supLevels = array.new<LevelMarker>()

// ==========================================
// Pivot Detection using Open/Close Extremes
// ==========================================
// Resistance: Highest Close pivot
pHi = ta.pivothigh(close, leftBars, rightBars)

// Support: Lowest Open pivot
pLo = ta.pivotlow(open, leftBars, rightBars)

// Calculate exact bar index where the pivot occurred
pivotBarIndex = bar_index - rightBars

// Helper function to create LevelMarker
createLevel(float price, int barIdx, bool isSup) =>
    c = isSup ? supColor : resColor
    txt = isSup ? "Support" : "Resistance"
    lStyle = label.style_label_left
    extStyle = extendLines ? extend.right : extend.none

    newLine = line.new(x1=barIdx, y1=price, x2=bar_index, y2=price, color=c, width=lineWidth, extend=extStyle)
    newLbl  = label.new(x=bar_index, y=price, text=txt, color=c, textcolor=color.white, style=lStyle, size=size.small)
    LevelMarker.new(newLine, newLbl, isSup)

// ==========================================
// Add New Pivot Lines & Maintain Max Levels Limit
// ==========================================
if not na(pHi)
    array.push(resLevels, createLevel(pHi, pivotBarIndex, false))
    // Keep only the max active levels
    while array.size(resLevels) > maxLevels
        LevelMarker oldest = array.shift(resLevels)
        line.delete(oldest.ln)
        label.delete(oldest.lbl)

if not na(pLo)
    array.push(supLevels, createLevel(pLo, pivotBarIndex, true))
    // Keep only the max active levels
    while array.size(supLevels) > maxLevels
        LevelMarker oldest = array.shift(supLevels)
        line.delete(oldest.ln)
        label.delete(oldest.lbl)

// ==========================================
// Update Positions & Auto-Flip Logic
// ==========================================
processLevels(LevelMarker[] levels) =>
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            LevelMarker item = array.get(levels, i)
            float levelPrice = line.get_y1(item.ln)

            // Keep label anchored to the rightmost bar
            label.set_x(item.lbl, bar_index)

            // Non-extended line endpoint update
            if not extendLines
                line.set_x2(item.ln, bar_index)

            // Check for line crossing / break
            if item.isSupport and ta.crossunder(close, levelPrice)
                // Price broke BELOW Support -> Flip to Resistance (Red)
                item.isSupport := false
                line.set_color(item.ln, resColor)
                label.set_color(item.lbl, resColor)
                label.set_text(item.lbl, "Resistance")

            else if not item.isSupport and ta.crossover(close, levelPrice)
                // Price broke ABOVE Resistance -> Flip to Support (Green)
                item.isSupport := true
                line.set_color(item.ln, supColor)
                label.set_color(item.lbl, supColor)
                label.set_text(item.lbl, "Support")

processLevels(resLevels)
processLevels(supLevels)
````
