# Opening (SYC)

- url: https://www.tradingview.com/script/oUtrRalA/
- type: indicator
- pine_id: PUB;84c55c0cff86442b9e37a7bd386297c5
- version: 1.0

## Description

This indicator visualizes the Opening Range of a trading session as a clean, customizable rectangle (box) along with its exact mathematical midpoint (50% level). It is specifically designed for traders executing breakout, fade, or mean reversion strategies based on early intraday volatility.

Unlike many standard tools that only show the current day's data, this indicator preserves the full historical data on your chart, allowing you to easily backtest and study how price reacted to the opening ranges of past days.

## Source Code

````pine
//@version=5
indicator("Opening Range Breakout (ORB) + Midpoint + Points (SYC)", shorttitle="ORB Points v3", overlay=true, max_boxes_count=500, max_lines_count=500)

// === SETTINGS ===
startHour     = input.int(8,   "Start Hour (EST)",      minval=0, maxval=23,  group="Time Settings")
startMin      = input.int(0,   "Start Minute",        minval=0, maxval=59,  group="Time Settings")
orbMinutes    = input.int(15,  "ORB Duration (Minutes)", minval=5, maxval=60, group="Time Settings")
extendMinutes = input.int(120, "Extend Right (Minutes) - 0 = Forever", minval=0, group="Time Settings")

orbBorder     = input.color(color.blue,   "ORB Border Color",   group="Style Settings")
orbBg         = input.color(color.new(color.blue, 85), "ORB Background Color", group="Style Settings")
midColor      = input.color(color.white,  "Midpoint Color",     group="Style Settings")
midStyle      = input.string("Dashed", "Midpoint Style", options=["Solid", "Dashed", "Dotted"], group="Style Settings")
midWidth      = input.int(2, "Midpoint Thickness", minval=1, maxval=5, group="Style Settings")

// === INFO BOX SETTINGS ===
showBox       = input.bool(true, "Show Info Box", group="Info Box Settings")
boxPos        = input.string("Top Right", "Box Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Info Box Settings")
boxBgColor    = input.color(color.new(color.black, 50), "Box Background Color", group="Info Box Settings")
boxTxtColor   = input.color(color.white, "Box Text Color", group="Info Box Settings")

// Timezone
tz = "America/New_York"

var box  orbBox = na
var line orbLine = na
var float orbHigh = na
var float orbLow  = na
var float orbStartTime = na
var int orbEndBar = na

// New ORB
isNewORB = hour(time("1", "", tz), tz) == startHour and minute(time("1", "", tz), tz) == startMin

if isNewORB
    orbHigh      := high
    orbLow       := low
    orbStartTime := time
    orbEndBar    := na
    
    orbBox := box.new(bar_index, orbLow, bar_index + 1, orbHigh, border_color = orbBorder, bgcolor = orbBg, border_width = 2)
    
    midPoint = (orbHigh + orbLow) / 2
    lineStyle = midStyle == "Dashed" ? line.style_dashed : midStyle == "Dotted" ? line.style_dotted : line.style_solid
    orbLine := line.new(bar_index, midPoint, bar_index + 1, midPoint, color=midColor, width=midWidth, style=lineStyle)

    label.new(bar_index, high, "ORB", style=label.style_label_down, color=color.new(color.blue, 0), textcolor=color.white)

// Update ORB & Extend
if not na(orbStartTime)
    minutesPassed = (time - orbStartTime) / 60000
    
    if minutesPassed < orbMinutes
        orbHigh  := math.max(orbHigh, high)
        orbLow   := math.min(orbLow, low)
        midPoint = (orbHigh + orbLow) / 2
        
        box.set_top(orbBox, orbHigh)
        box.set_bottom(orbBox, orbLow)
        box.set_right(orbBox, bar_index)
        
        line.set_y1(orbLine, midPoint)
        line.set_y2(orbLine, midPoint)
        line.set_x2(orbLine, bar_index)
    else
        if na(orbEndBar)
            orbEndBar := bar_index
            
        int extendBars = extendMinutes == 0 ? 1000 : math.round(extendMinutes * 60 / timeframe.in_seconds())
        int rightEdge = orbEndBar + extendBars
        
        box.set_right(orbBox, rightEdge)
        line.set_x2(orbLine, rightEdge)

// === INFO BOX LOGIC ===
var table infoTable = na

if showBox and barstate.islast
    // Determine Position
    t_pos = position.top_right
    if boxPos == "Top Left"
        t_pos := position.top_left
    else if boxPos == "Bottom Right"
        t_pos := position.bottom_right
    else if boxPos == "Bottom Left"
        t_pos := position.bottom_left
        
    // Add extra rows for padding if position is Top Right or Top Left to prevent overlap
    int totalRows = (boxPos == "Top Right" or boxPos == "Top Left") ? 3 : 1
    int activeRow = (boxPos == "Top Right" or boxPos == "Top Left") ? 2 : 0
    
    infoTable := table.new(position = t_pos, columns = 1, rows = totalRows)
    
    // Calculate real price difference (Points)
    float diffPoints = not na(orbHigh) and not na(orbLow) ? (orbHigh - orbLow) : 0.0
    
    // Format the text string
    string txt = "ORB: " + str.tostring(diffPoints, "#.##") + " Points"
    
    // Leave the upper cells transparent as a spacer if box is positioned at the top
    if totalRows == 3
        table.cell(infoTable, 0, 0, "", bgcolor=color.new(color.black, 100))
        table.cell(infoTable, 0, 1, "", bgcolor=color.new(color.black, 100))
        
    // Fill the visible info cell
    table.cell(infoTable, 0, activeRow, txt, bgcolor=boxBgColor, text_color=boxTxtColor, text_size=size.normal)
````
