# PREVIOUS WEEK HIGH/LOW

- url: https://www.tradingview.com/script/94E7i8vF-PREVIOUS-WEEK-HIGH-LOW/
- type: indicator
- pine_id: PUB;b02572472ac44217851f5666c41cf2fa
- version: 1.0

## Description

Previous week levels high and low, works on all timeframes

## Source Code

````pine
//@version=6
indicator("Previous Week High & Low (Flat Trendlines + Labels)", overlay=true, shorttitle="Prev Week H/L")

// ───── Inputs ─────
lineColorHigh = input.color(color.new(color.lime, 0), "Previous Week High Line Color")
lineColorLow  = input.color(color.new(color.red, 0), "Previous Week Low Line Color")
lineStyle     = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
lineWidth     = input.int(2, "Line Width", minval=1, maxval=5)
textColor     = input.color(color.white, "Label Text Color")
textSize      = input.string("normal", "Label Text Size", options=["tiny", "small", "normal", "large"])

// ───── Style map ─────
styleMap = switch lineStyle
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

// ───── Secure, Stable Weekly Logic ─────
// CRITICAL FIX: Changing lookahead to ON while referencing high[1] / low[1]
// tells the daily bars to pull the accurate, immediately preceding week's data.
[pwh, pwl, wTime] = request.security(syminfo.tickerid, "W", [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)

// Detect when the fetched weekly tracking data shifts on our current chart scale
var float activeHigh = na
var float activeLow  = na
var int   lineStartX = na

if ta.change(wTime) != 0
    activeHigh := pwh
    activeLow  := pwl
    lineStartX := time[1] // Sets the line starting anchor to the true historical time coordinate

// ───── Persistent drawing variables ─────
var line lineHigh = na
var line lineLow  = na
var label labelHigh = na
var label labelLow  = na

// ───── Draw and Update Logic ─────
if timeframe.isintraday or timeframe.isdaily or timeframe.isweekly
    if ta.change(wTime) != 0
        // Clean up previous drawings so the chart stays crisp
        line.delete(lineHigh)
        line.delete(lineLow)
        label.delete(labelHigh)
        label.delete(labelLow)
        
        // Create new lines anchored to TIME coordinates rather than volatile bar indexes
        lineHigh := line.new(x1=lineStartX, y1=activeHigh, x2=time, y2=activeHigh, xloc=xloc.bar_time, color=lineColorHigh, width=lineWidth, style=styleMap)
        lineLow  := line.new(x1=lineStartX, y1=activeLow,  x2=time, y2=activeLow,  xloc=xloc.bar_time, color=lineColorLow,  width=lineWidth, style=styleMap)
        
        // Create labels pinned to the right edge
        labelHigh := label.new(x=time, y=activeHigh, text="Weekly High", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(lineColorHigh, 80), textcolor=textColor, size=textSize, textalign=text.align_left)
        labelLow  := label.new(x=time, y=activeLow,  text="Weekly Low",  xloc=xloc.bar_time, style=label.style_label_left, color=color.new(lineColorLow, 80), textcolor=textColor, size=textSize, textalign=text.align_left)
    else
        // Keep stretching the active lines forward to the live candle bar time
        if not na(lineHigh)
            line.set_x2(lineHigh, time)
        if not na(lineLow)
            line.set_x2(lineLow, time)
        if not na(labelHigh)
            label.set_x(labelHigh, time)
        if not na(labelLow)
            label.set_x(labelLow, time)
````
