# Swing High/Low Lines

- url: https://www.tradingview.com/script/NZ4lVlX2-Swing-High-Low-Lines/
- type: indicator
- pine_id: PUB;d08352125aaa449bbf401d8117c032d9
- version: 1.0

## Description

This indicator automatically detects swing highs and swing lows on the chart and draws horizontal lines from those points with the following behavior:

Detects Swings: Uses ta.pivothigh() and ta.pivotlow() to find significant turning points based on a configurable number of bars to the left and right.
Draws Horizontal Lines: When a swing high or low is confirmed, it draws a horizontal line starting from the actual swing bar and extending to the right.
Extends Until Hit: The line continues extending to the right as long as price has not revisited that level.
Ends When Price Hits It: As soon as price touches or breaks the level again (using wick or close — your choice), the extending line is deleted and replaced with a fixed horizontal line segment that ends exactly at the bar where price first revisited it.
Visual Differentiation: Active (unbroken) lines are solid and bright. Broken lines turn dashed and faded so you can easily see which levels have already been tested.
Optional Markers: You can toggle on/off triangle markers and labels at the swing points.

In Simple Terms:
This script finds important highs and lows, draws lines from them that keep going right until price comes back and touches them, at which point the line stops extending and becomes a fixed historical level.

## Source Code

````pine
//@version=6
indicator("Swing High/Low Lines", overlay=true, 
     max_lines_count=500, max_labels_count=300, max_bars_back=5000)

// ====================== INPUTS ======================
leftBars     = input.int(5,  "Left Bars for Swing", minval=1, group="Swing Detection")
rightBars    = input.int(5,  "Right Bars for Swing", minval=1, group="Swing Detection")

activeHighColor = input.color(color.red,          "Active High Line Color", group="Colors")
brokenHighColor = input.color(color.new(color.red, 75), "Broken High Line Color", group="Colors")
activeLowColor  = input.color(color.green,        "Active Low Line Color", group="Colors")
brokenLowColor  = input.color(color.new(color.green, 75), "Broken Low Line Color", group="Colors")

lineWidth     = input.int(2, "Line Width", minval=1, maxval=5, group="Style")
useWickBreak  = input.bool(true, "Use Wick (High/Low) for Break Detection", 
     tooltip="True = breaks on wick touch. False = breaks on close cross.", group="Break Detection")

showShapes = input.bool(true,  "Show Swing Point Markers", group="Visuals")
showLabels = input.bool(false, "Show Swing Labels (SH/SL + Price)", group="Visuals")

// ====================== PIVOT DETECTION ======================
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low,  leftBars, rightBars)

// Plot swing markers
plotshape(showShapes ? ph : na, title="Swing High", location=location.abovebar, style=shape.triangledown, 
          size=size.small, color=activeHighColor, offset=-rightBars)

plotshape(showShapes ? pl : na, title="Swing Low",  location=location.belowbar, style=shape.triangleup,   
          size=size.small, color=activeLowColor, offset=-rightBars)

// ====================== LINE MANAGEMENT ======================
var line[]  activeHighs  = array.new_line()
var float[] highLevels   = array.new_float()
var line[]  activeLows   = array.new_line()
var float[] lowLevels    = array.new_float()

// === Create new swing high line ===
if not na(ph)
    int   swingIdx = bar_index - rightBars
    float lvl      = ph
    line  ln       = line.new(swingIdx, lvl, bar_index, lvl, 
                              color=activeHighColor, width=lineWidth, extend=extend.right)
    array.push(activeHighs, ln)
    array.push(highLevels,  lvl)
    
    if showLabels
        label.new(swingIdx, lvl, text="SH " + str.tostring(lvl, format.mintick), 
                  style=label.style_label_down, color=activeHighColor, 
                  textcolor=color.white, size=size.tiny)

// === Create new swing low line ===
if not na(pl)
    int   swingIdx = bar_index - rightBars
    float lvl      = pl
    line  ln       = line.new(swingIdx, lvl, bar_index, lvl, 
                              color=activeLowColor, width=lineWidth, extend=extend.right)
    array.push(activeLows, ln)
    array.push(lowLevels,  lvl)
    
    if showLabels
        label.new(swingIdx, lvl, text="SL " + str.tostring(lvl, format.mintick), 
                  style=label.style_label_up, color=activeLowColor, 
                  textcolor=color.white, size=size.tiny)

// ====================== CHECK FOR HITS (Improved) ======================
// High lines (resistance)
if array.size(activeHighs) > 0
    for i = array.size(activeHighs) - 1 to 0
        line  ln        = array.get(activeHighs, i)
        float lvl       = array.get(highLevels, i)
        int   lineStart = line.get_x2(ln)
        
        if bar_index > lineStart
            bool hit = useWickBreak ? high >= lvl : close >= lvl
            if hit
                // Replace extending line with a fixed line that ends at this bar
                line.new(line.get_x1(ln), lvl, bar_index, lvl, 
                         color=brokenHighColor, width=lineWidth, extend=extend.none, style=line.style_dashed)
                line.delete(ln)
                array.remove(activeHighs, i)
                array.remove(highLevels, i)

// Low lines (support)
if array.size(activeLows) > 0
    for i = array.size(activeLows) - 1 to 0
        line  ln        = array.get(activeLows, i)
        float lvl       = array.get(lowLevels, i)
        int   lineStart = line.get_x2(ln)
        
        if bar_index > lineStart
            bool hit = useWickBreak ? low <= lvl : close <= lvl
            if hit
                // Replace extending line with a fixed line that ends at this bar
                line.new(line.get_x1(ln), lvl, bar_index, lvl, 
                         color=brokenLowColor, width=lineWidth, extend=extend.none, style=line.style_dashed)
                line.delete(ln)
                array.remove(activeLows, i)
                array.remove(lowLevels, i)
````
