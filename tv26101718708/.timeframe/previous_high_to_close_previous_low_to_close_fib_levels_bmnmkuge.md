# Previous high to Close Previous low to Close fib levels

- url: https://www.tradingview.com/script/bmNMKuGE-Previous-high-to-Close-Previous-low-to-Close-fib-levels/
- type: indicator
- pine_id: PUB;446fd34d2b4f4e10be5c36455b005e83
- version: 1.0

## Description

This script, Fib Bridge: H/L to First Close, is a specialized technical analysis tool designed to identify intraday support and resistance levels based on the relationship between previous period extremes and the opening price action.

Core Functionality
Anchor Periods: Automatically calculates levels based on the Previous Day or Previous Week high/low.

The "Fib Bridge": It constructs Fibonacci-style "bridges" between the previous period's high/low and the closing price of the first candle of the current session.

ORB Levels: Visualizes the Opening Range Breakout (ORB) High, Low, and Midpoint of the first candle for immediate bias.

Bull & Bear Zones: * Bull Bridge: Projects the 50% midpoint between the Previous Low and the first Close.

Bear Bridge: Projects the 50% midpoint between the Previous High and the first Close.

Dynamic Visuals: Includes real-time line extensions and customizable labels for price precision.

## Source Code

````pine
//@version=6
indicator("Fib Bridge: H/L to First Close with Prices", overlay=true, max_lines_count=500)

//----------------------
// User Inputs
//----------------------
tfMode       = input.string("Daily", "Anchor Period", options=["Daily", "Weekly"])
showLabels   = input.bool(true, "Show Labels")
hideHistory  = input.bool(true, "Hide Historical Levels")

groupFirst   = "First Candle Visuals"
colorFirstHL = input.color(color.yellow, "ORB H/L/Mid Color", group=groupFirst)
styleFirstHL = input.string("Dotted", "ORB Line Style", options=["Solid", "Dotted", "Dashed"], group=groupFirst)

//----------------------
// Global Functions (Must be outside 'if' blocks)
//----------------------
getStyle(s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

f_price(p) => 
    str.tostring(p, format.mintick)

//----------------------
// Logic Helpers
//----------------------
isNewPeriod = tfMode == "Daily" ? ta.change(time("D")) != 0 : ta.change(time("W")) != 0
rawHigh = request.security(syminfo.tickerid, tfMode == "Daily" ? "D" : "W", high[1], lookahead=barmerge.lookahead_on)
rawLow  = request.security(syminfo.tickerid, tfMode == "Daily" ? "D" : "W", low[1], lookahead=barmerge.lookahead_on)

//----------------------
// Persistent Arrays for Cleanup
//----------------------
var line[]  allLines  = array.new_line()
var label[] allLabels = array.new_label()

//----------------------
// Logic: Reset and Draw
//----------------------
if isNewPeriod
    // Cleanup
    if hideHistory
        if array.size(allLines) > 0
            for l in allLines
                line.delete(l)
        if array.size(allLabels) > 0
            for lb in allLabels
                label.delete(lb)
    
    array.clear(allLines)
    array.clear(allLabels)

    int startBar    = bar_index
    float pdh       = rawHigh
    float pdl       = rawLow
    float fClose    = close
    float fHigh     = high
    float fLow      = low
    float fMid      = (high + low) / 2

    // 1. Draw First Candle H/L/Mid (ORB Levels)
    lineStyle = getStyle(styleFirstHL)
    array.push(allLines, line.new(startBar, fHigh, startBar + 5, fHigh, color=colorFirstHL, style=lineStyle))
    array.push(allLines, line.new(startBar, fLow,  startBar + 5, fLow,  color=colorFirstHL, style=lineStyle))
    array.push(allLines, line.new(startBar, fMid,  startBar + 5, fMid,  color=colorFirstHL, style=lineStyle))

    if showLabels
        array.push(allLabels, label.new(startBar, fHigh, "ORB H: " + f_price(fHigh), style=label.style_label_right, color=#00000000, textcolor=colorFirstHL, size=size.small))
        array.push(allLabels, label.new(startBar, fLow,  "ORB L: " + f_price(fLow), style=label.style_label_right, color=#00000000, textcolor=colorFirstHL, size=size.small))
        array.push(allLabels, label.new(startBar, fMid,  "ORB Mid: " + f_price(fMid), style=label.style_label_right, color=#00000000, textcolor=colorFirstHL, size=size.small))

    // 2. LOW TO CLOSE FIB (Bull Bridge)
    float bullMid = (pdl + fClose) / 2
    
    array.push(allLines, line.new(startBar, pdl,     startBar + 5, pdl,     color=color.blue, width=1))
    array.push(allLines, line.new(startBar, bullMid, startBar + 5, bullMid, color=color.blue, width=1, style=line.style_dashed))
    array.push(allLines, line.new(startBar, fClose,  startBar + 5, fClose,  color=color.white, width=2))

    if showLabels
        array.push(allLabels, label.new(startBar, pdl, "Low Fib 0.0 (PDL): " + f_price(pdl), style=label.style_label_right, color=#00000000, textcolor=color.blue, size=size.small))
        array.push(allLabels, label.new(startBar, bullMid, "Low-Close 0.5: " + f_price(bullMid), style=label.style_label_right, color=#00000000, textcolor=color.blue, size=size.small))
        array.push(allLabels, label.new(startBar, fClose, "Low-Close 1.0: " + f_price(fClose), style=label.style_label_right, color=#00000000, textcolor=color.white, size=size.small))

    // 3. HIGH TO CLOSE FIB (Bear Bridge)
    float bearMid = (pdh + fClose) / 2
    
    array.push(allLines, line.new(startBar, pdh,     startBar + 5, pdh,     color=color.red, width=1))
    array.push(allLines, line.new(startBar, bearMid, startBar + 5, bearMid, color=color.red, width=1, style=line.style_dashed))

    if showLabels
        array.push(allLabels, label.new(startBar, pdh, "High Fib 0.0 (PDH): " + f_price(pdh), style=label.style_label_right, color=#00000000, textcolor=color.red, size=size.small))
        array.push(allLabels, label.new(startBar, bearMid, "High-Close 0.5: " + f_price(bearMid), style=label.style_label_right, color=#00000000, textcolor=color.red, size=size.small))
        array.push(allLabels, label.new(startBar, fClose, "High-Close 1.0: " + f_price(fClose), style=label.style_label_left, color=#00000000, textcolor=color.red, size=size.small))

//----------------------
// Real-time Line Extension
//----------------------
if array.size(allLines) > 0
    for i = 0 to array.size(allLines) - 1
        line.set_x2(array.get(allLines, i), bar_index)
````
