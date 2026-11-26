# HTF CANDEL 3D MEGA CUBE

- url: https://www.tradingview.com/script/CneY9mNJ/
- type: indicator
- pine_id: PUB;e8759282ae6f49b09648d461444caf89
- version: 1.0

## Description

Overview
The HTF CANDEL 3D MEGA CUBE is a specialized visualization tool for Pine Script® (TradingView). Its primary purpose is to display a Higher Time Frame (HTF) candle—such as a Weekly or Daily candle—directly onto your current, lower time frame chart. It uses a unique 3D cube design to make the price action of the "big picture" clear and easy to follow without needing to switch tabs.

How it Works
1. Multi-Timeframe Analysis
The indicator tracks price data from a higher timeframe (chosen by you in the settings, like "W" for Weekly). It calculates the Open, High, Low, and Close of that specific period and projects it as a 3D object on the right side of your chart.

2. 3D Cube Visualization
Instead of a flat candle, the script draws a "Mega Cube":

The Front Face: Represents the main body (the space between Open and Close).

The Side Shade: Adds a 3D effect to give the candle depth.

The Wick: A vertical line running through the center that shows the full price range (High to Low).

3. Real-Time Countdown
A unique feature of this script is the built-in timer. It calculates the remaining time until the current HTF candle closes and displays it as a label (e.g., "Ends In: 2h 15m 10s"). This is crucial for traders who wait for candle closures to confirm their entries.

Key Visual Components
Bullish/Bearish Coloring: The cube automatically changes color based on price action. If the price is above the opening, it turns green (Bullish); if below, it turns red (Bearish).

Price Level Labels: It plots horizontal lines and labels for the four critical price points: High, Low, Open, and Close. This helps you identify key support and resistance levels from the higher timeframe.

Dynamic Offset: The cube is drawn to the right of the current price action (in the "chart void"), so it doesn't overlap with your current candles or clutter your workspace.

Why Traders Use It
Trend Awareness: It helps you stay aware of the "Macro" trend while you are trading the "Micro" noise.

Confluence: If you see a bullish setup on your 15-minute chart and the 3D Mega Cube shows a strong bullish Weekly candle, it adds high-probability confirmation to your trade.

Efficiency: You no longer need to keep multiple charts open or constantly toggle between timeframes to see where the Daily or Weekly levels are.

Summary of Settings
TimeFrame: Choose which HTF to display.

Cube Width & Transparency: Control how large and solid the 3D box appears.

Horizontal Offset: Move the cube further to the right to keep your chart clean.

Visibility Toggles: Turn on or off specific lines like the High or Low levels to suit your trading style.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © HTF CANDEL

//@version=6
indicator("HTF CANDEL 3D MEGA CUBE", shorttitle="HTF CANDEL 3D", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --------------------------------------------------------------------------------------------------------------------
// USER INPUTS
// --------------------------------------------------------------------------------------------------------------------

tf_input = input.string("W", "TimeFrame", options = ["15", "30", "60", "45", "90", "120", "D", "W", "M"])

group_cube = "Cube Appearance & Size"
cubeWidth    = input.int(30, "Cube Total Width", minval = 5, maxval = 200)
showBorder   = input.bool(true, "Show Cube Borders")
borderWidth  = input.int(2, "Cube Border Thickness", minval = 1, maxval = 5)
cubeTransp   = input.int(20, "Cube Fill Transparency", minval = 0, maxval = 100)

group_levels = "Levels & Ultra Visibility"
offset       = input.int(40, "Horizontal Offset (Space on Right)")
hlThickness  = input.int(2, "High/Low Line Thickness", minval = 1, maxval = 10) // خيار السمك الجديد
dHigh  = input.bool(true, "Show High Line")
dLow   = input.bool(true, "Show Low Line")
dClose = input.bool(true, "Show Close Line")
dOpen  = input.bool(true, "Show Open Line")
showCD = input.bool(true, "Show Countdown Label")

bullishColor = input.color(#00ff88, "Bullish Color")
bearishColor = input.color(#ff1166, "Bearish Color")

// --------------------------------------------------------------------------------------------------------------------
// CALCULATIONS
// --------------------------------------------------------------------------------------------------------------------

htf_close_time = request.security(syminfo.tickerid, tf_input, time_close)
remaining_ms = htf_close_time - timenow

f_format_time(ms) =>
    string res = ""
    if ms < 0
        res := "Closed"
    else
        int seconds = math.floor(ms / 1000) % 60
        int minutes = math.floor(ms / (1000 * 60)) % 60
        int hours   = math.floor(ms / (1000 * 60 * 60)) % 24
        int days    = math.floor(ms / (1000 * 60 * 60 * 24))
        
        if days > 0 
            res += str.tostring(days) + "d "
        if hours > 0 or days > 0 
            res += str.tostring(hours) + "h "
        res += str.tostring(minutes) + "m " + str.tostring(seconds) + "s"
    res

countdown_text = f_format_time(remaining_ms)

var float Op = na
var float Cl = na
var float Hi = na
var float Lo = na
var int   start_bar = na

if timeframe.change(tf_input)
    Op := open
    start_bar := bar_index

Cl := close
Hi := ta.highest(bar_index - (na(start_bar) ? bar_index : start_bar) + 1)
Lo := ta.lowest(bar_index - (na(start_bar) ? bar_index : start_bar) + 1)

// --------------------------------------------------------------------------------------------------------------------
// 3D MEGA CUBE RENDERING
// --------------------------------------------------------------------------------------------------------------------

if barstate.islast
    // Cleanup previous drawings
    var box mainBody = na
    var box sideFace = na
    var line wick    = na
    var line hiLine  = na
    var line loLine  = na
    
    box.delete(mainBody)
    box.delete(sideFace)
    line.delete(wick)
    line.delete(hiLine)
    line.delete(loLine)

    color baseCol = Cl > Op ? bullishColor : bearishColor
    color shadow  = color.new(baseCol, 50)
    int leftPos   = bar_index + offset
    int rightPos  = leftPos + cubeWidth

    // 1. Central Wick (Vertical)
    wick := line.new(leftPos + (cubeWidth/2), Hi, leftPos + (cubeWidth/2), Lo, color = baseCol, width = 2)

    // 2. High & Low Horizontal Lines with Ultra Visibility (Thickness Control)
    if dHigh
        hiLine := line.new(bar_index, Hi, leftPos, Hi, color = color.new(baseCol, 20), style = line.style_solid, width = hlThickness)
    if dLow
        loLine := line.new(bar_index, Lo, leftPos, Lo, color = color.new(baseCol, 20), style = line.style_solid, width = hlThickness)

    // 3. Main Cube Body (Front Face)
    mainBody := box.new(left = leftPos, top = math.max(Op, Cl), 
                        right = rightPos, bottom = math.min(Op, Cl), 
                        border_color = showBorder ? baseCol : color(na), 
                        bgcolor = color.new(baseCol, cubeTransp), 
                        border_width = borderWidth)

    // 4. 3D Side Shade
    sideFace := box.new(left = rightPos, top = math.max(Op, Cl), 
                        right = rightPos + math.round(cubeWidth/4), bottom = math.min(Op, Cl), 
                        border_color = showBorder ? shadow : color(na), 
                        bgcolor = color.new(baseCol, cubeTransp + 20), 
                        border_width = borderWidth)

    // 5. Labels & Levels
    var label lH = na, var label lL = na, var label lC = na, var label lO = na, var label lCD = na
    label.delete(lH), label.delete(lL), label.delete(lC), label.delete(lO), label.delete(lCD)
    
    int label_x = rightPos + math.round(cubeWidth/3)

    if dHigh
        lH := label.new(label_x, Hi, "High: " + str.tostring(Hi, format.mintick), style=label.style_label_left, color=color(na), textcolor=chart.fg_color)
    if dLow
        lL := label.new(label_x, Lo, "Low: " + str.tostring(Lo, format.mintick), style=label.style_label_left, color=color(na), textcolor=chart.fg_color)
    if dClose
        lC := label.new(label_x, Cl, "Close: " + str.tostring(Cl, format.mintick), style=label.style_label_left, color=color(na), textcolor=chart.fg_color)
    if dOpen
        lO := label.new(label_x, Op, "Open: " + str.tostring(Op, format.mintick), style=label.style_label_left, color=color(na), textcolor=chart.fg_color)
    
    if showCD
        lCD := label.new(leftPos + (cubeWidth/2), math.max(Op, Cl), "Ends In: " + countdown_text, style=label.style_label_down, color=baseCol, textcolor=color.white)
````
