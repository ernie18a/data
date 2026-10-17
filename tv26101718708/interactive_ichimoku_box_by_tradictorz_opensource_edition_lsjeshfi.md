# Interactive Ichimoku Box by Tradictorz | Open-Source Edition

- url: https://www.tradingview.com/script/LSJEshFi-Interactive-Ichimoku-Box-by-Tradictorz-Open-Source-Edition/
- type: indicator
- pine_id: PUB;ed488802a0d14431bfb7dbe38d263069
- version: 1.0

## Description

Interactive Ichimoku Box by Tradictorz | Open-Source Edition

This is the open-source release of Interactive Ichimoku Box by Tradictorz.

The script is designed as a visual Ichimoku-based analysis tool. It combines standard Ichimoku components with interactive projection boxes based on recent high/low ranges. The goal is to help traders visually study price structure, potential range expansion areas, and Tenkan/Kijun relationship directly on the chart.

Main features:
• Ichimoku Tenkan and Kijun lines
• Optional Ichimoku cloud display
• Chikou span display
• Interactive target boxes based on 9-period, 26-period, and 52-period high/low ranges
• Higher and lower projection box options
• Visual Tenkan/Kijun cross indication
• Position label showing current directional bias and price
• Buy/Sell alert conditions based on Tenkan/Kijun crossovers

How it works:
The indicator calculates Ichimoku-style Donchian midpoints for the Conversion Line and Base Line. It then uses recent high/low ranges to draw projected boxes above and below the selected range. These boxes are intended to provide a visual framework for studying possible continuation or expansion zones.

Position label:
The position label displays the current directional state:
• Long: Conversion Line is above Base Line
• Short: Conversion Line is below Base Line
• Range: Conversion Line and Base Line are equal

Alerts:
The script includes alert conditions for:
• Buy Alert: Conversion Line crosses above Base Line
• Sell Alert: Conversion Line crosses below Base Line

Important notes:
This indicator is an analytical and educational tool only. It does not provide financial advice, trade recommendations, or guaranteed buy/sell signals. Historical behavior does not guarantee future results. Always combine this tool with your own analysis, confirmation process, and risk management.

Open-source notice:
This version is published as open source for transparency, educational review, and community feedback. You may inspect the logic, learn from it, and modify it according to TradingView’s open-source rules. If you reuse or publish modified versions of this script, please follow TradingView’s House Rules and credit the original author where required.

License:
This source code is subject to the terms of the Mozilla Public License 2.0.
© parm79

## Source Code

````pine
// © parm79
// Open-source edition of Interactive Ichimoku Box by Tradictorz.
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator(     title="Interactive Ichimoku Box by Tradictorz | Open-Source Edition", shorttitle="Ichi Box by Tradictorz", overlay=true)

box9_color = input.color(defval=color.new(color.purple, 98), title="9 Periods Boxes Target Color", group="Target_Box")
box25_color = input.color(defval=color.new(color.blue, 98), title="26 Periods Boxes Target Color", group="Target_Box")
box52_color = input.color(defval=color.new(color.red, 98), title="52 Periods Boxes Target Color", group="Target_Box")

Box_Target_9 = input.int(defval=1, title="Target_Boxes_for_9 Bars_Peroids", minval=1, maxval=3, inline="target9", group="Target_Box")
Box_Target_26 = input.int(defval=1, title="Target_Boxes_for_26 Bars_Peroids", minval=1, maxval=3, inline="target26", group="Target_Box")
//Box_Target_52 = input.int(defval = 1, title = "Target_Boxes_for_52 Bars_Peroids", minval = 1, maxval = 3, inline = "target52", group = "Target_Box")

Upper_Box_9 = input.bool(title="Higher", defval=false, inline="target9", group="Target_Box")
Lower_Box_9 = input.bool(title="Lower", defval=false, inline="target9", group="Target_Box")
Upper_Box_26 = input.bool(title="Higher", defval=true, inline="target26", group="Target_Box")
Lower_Box_26 = input.bool(title="Lower", defval=false, inline="target26", group="Target_Box")
//Upper_Box_52 = input.bool(title='Higher', defval=false, inline = "target52", group= "Target_Box")
//Lower_Box_52 = input.bool(title='Lower', defval=false, inline = "target52", group= "Target_Box")

ShowCloud = input.bool(title="Show Ichimoku Cloud", defval=false, group="Ichimoku")
ShowIchiLines = input.bool(title="Show Ichimoku Lines", defval=false, group="Ichimoku")
ShowCross = input.bool(title="Show Ichimoku Cross", defval=true, group="Ichimoku", tooltip="Blue stars means conversionLine crossed over baseLine, Red means baseLine crossed over conversionLine and if both of them become equal then the stars become yellow ")
//ShowMiddleLine = input(title="Show Middle Line", defval=true, group="Target_Box")
//middleLineColor = input.color(defval = color.new(color.white, 98), title = "Middle Line Color", group="Target_Box")

ShowPLable = input.bool(title="Show Position Label", defval=true, group="Target_Box")
inLabelStyle = input.string(title="Position Label Style", options=["Upper Right", "Lower Right"], defval="Lower Right", group="Target_Box")

//////////////////////////////////
// Originally copy from builtin ichimoku Cloud
/////////////////////////////////

haclose = close
price = haclose

conversionPeriods = 9
basePeriods = 26
laggingSpan2Periods = 52
displacement = 26

donchian(len) =>
    math.avg(ta.lowest(len), ta.highest(len))

isValidFloat(x) =>
    not na(x) and x != 0

conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)
leadLine1 = math.avg(conversionLine, baseLine)
leadLine2 = donchian(laggingSpan2Periods)

SenkouA = donchian(laggingSpan2Periods)
SenkouB = (conversionLine[basePeriods] + baseLine[basePeriods]) / 2

plot(ShowIchiLines and isValidFloat(conversionLine) ? conversionLine : na, color=color.new(color.blue, 0), title="Tenkan")
plot(ShowIchiLines and isValidFloat(baseLine) ? baseLine : na, color=color.new(color.red, 0), title="Kijun")
plot(ShowIchiLines and isValidFloat(price) ? price : na, color=color.new(color.yellow, 40), title="Chikou", offset=-displacement + 1)

A = plot(ShowCloud and isValidFloat(leadLine1) ? leadLine1 : na, color=color.new(color.purple, 40), title="SenkouA", offset=displacement - 1)
B = plot(ShowCloud and isValidFloat(leadLine2) ? leadLine2 : na, color=color.new(color.green, 40), title="SenkouB", offset=displacement - 1)

fill(A, B, color=leadLine1 > leadLine2 ? color.rgb(67, 160, 71, 90) : color.rgb(244, 67, 54, 90), title="Komu Background")

//////////////////////////////////
// END of ichimoku
/////////////////////////////////

xAxisValue = bar_index
xAxisStyle = xloc.bar_index

ll = ta.lowest(26)
hh = ta.highest(26)
ll9 = ta.lowest(9)
hh9 = ta.highest(9)
ll52 = ta.lowest(52)
hh52 = ta.highest(52)

// This is for where to start
Time = input.time(timestamp("22 Nov 2021"), "Start Calculation", confirm=true)

// Drawing Target Boxes based on HH/LL of previous 26 & 52 candles
Box() =>
    var box1 = array.new_box(na)
    var box2 = array.new_box(na)
    var box3 = array.new_box(na)
    var box4 = array.new_box(na)
    var box5 = array.new_box(na)
    var box6 = array.new_box(na)
    var box7 = array.new_box(na)
    var box8 = array.new_box(na)
    var box9 = array.new_box(na)
    var middleHLine = array.new_line(na)

    if Time == time and Box_Target_9 == 1
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box9)
        array.push(box9, box.new(left=xAxisValue[8], top=hh9, right=xAxisValue, bottom=ll9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[25] + 25, top=hh + (hh - ll), right=xAxisValue + 25, bottom=hh, bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[25] + 25, top=ll, right=xAxisValue + 25, bottom=ll + (ll - hh), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    if Time == time and Box_Target_9 == 2 and Upper_Box_9 == true
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box5), array.clear(box9)
        array.push(box9, box.new(left=xAxisValue[8], top=hh9, right=xAxisValue, bottom=ll9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[8] + 8, top=hh9 + (hh9 - ll9), right=xAxisValue + 8, bottom=hh9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[8] + 8, top=ll9, right=xAxisValue + 8, bottom=ll9 + (ll9 - hh9), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box5, box.new(left=xAxisValue + 8, top=(hh9 + (hh9 - ll9)) + (hh9 - ll9), right=xAxisValue + 16, bottom=hh9 + (hh9 - ll9), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    if Time == time and Box_Target_9 == 2 and Lower_Box_9 == true
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box6), array.clear(box9)
        array.push(box9, box.new(left=xAxisValue[8], top=hh9, right=xAxisValue, bottom=ll9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[8] + 8, top=hh9 + (hh9 - ll9), right=xAxisValue + 8, bottom=hh9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[8] + 8, top=ll9, right=xAxisValue + 8, bottom=ll9 + (ll9 - hh9), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box6, box.new(left=xAxisValue + 8, top=ll9 + (ll9 - hh9), right=xAxisValue + 16, bottom=(ll9 + (ll9 - hh9)) - (hh9 - ll9), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    if Time == time and Box_Target_9 == 3 and Upper_Box_9 == true
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box5), array.clear(box6), array.clear(box7), array.clear(box9)
        array.push(box9, box.new(left=xAxisValue[8], top=hh9, right=xAxisValue, bottom=ll9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[8] + 8, top=hh9 + (hh9 - ll9), right=xAxisValue + 8, bottom=hh9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[8] + 8, top=ll9, right=xAxisValue + 8, bottom=ll9 + (ll9 - hh9), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box5, box.new(left=xAxisValue + 8, top=(hh9 + (hh9 - ll9)) + (hh9 - ll9), right=xAxisValue + 16, border_color=color.new(color.purple, 10), bottom=hh9 + (hh9 - ll9), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box7, box.new(left=xAxisValue + 16, top=(hh9 + (hh9 - ll9)) + (hh9 - ll9) + (hh9 - ll9), right=xAxisValue + 24, bottom=(hh9 + (hh9 - ll9)) + (hh9 - ll9), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    if Time == time and Box_Target_9 == 3 and Lower_Box_9 == true
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box5), array.clear(box6), array.clear(box8), array.clear(box9)
        array.push(box9, box.new(left=xAxisValue[8], top=hh9, right=xAxisValue, bottom=ll9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[8] + 8, top=hh9 + (hh9 - ll9), right=xAxisValue + 8, bottom=hh9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[8] + 8, top=ll9, right=xAxisValue + 8, bottom=ll9 + (ll9 - hh9), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box6, box.new(left=xAxisValue + 8, top=ll9 + (ll9 - hh9), right=xAxisValue + 16, bottom=(ll9 + (ll9 - hh9) + (ll9 - hh9)), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box8, box.new(left=xAxisValue + 16, top=(ll9 + (ll9 - hh9)) - (hh9 - ll9), right=xAxisValue + 24, bottom=(ll9 + (ll9 - hh9)) - (hh9 - ll9) - (hh9 - ll9), border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    // End of 9 Periods Bar

    if Time == time and Box_Target_26 == 1
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box9)
        array.push(box9, box.new(left=xAxisValue[8], top=hh9, right=xAxisValue, bottom=ll9, border_color=color.new(color.purple, 10), bgcolor=box9_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[25] + 25, top=hh + (hh - ll), right=xAxisValue + 25, bottom=hh, bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[25] + 25, top=ll, right=xAxisValue + 25, bottom=ll + (ll - hh), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    if Time == time and Box_Target_26 == 2 and Upper_Box_26 == true
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box5)
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[25] + 25, top=hh + (hh - ll), right=xAxisValue + 25, bottom=hh, bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[25] + 25, top=ll, right=xAxisValue + 25, bottom=ll + (ll - hh), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box5, box.new(left=xAxisValue + 25, top=(hh + (hh - ll)) + (hh - ll), right=xAxisValue + 50, bottom=hh + (hh - ll), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    if Time == time and Box_Target_26 == 2 and Lower_Box_26 == true
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box6)
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[25] + 25, top=hh + (hh - ll), right=xAxisValue + 25, bottom=hh, bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[25] + 25, top=ll, right=xAxisValue + 25, bottom=ll + (ll - hh), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box6, box.new(left=xAxisValue + 25, top=ll + (ll - hh), right=xAxisValue + 50, bottom=(ll + (ll - hh)) - (hh - ll), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    if Time == time and Box_Target_26 == 3 and Upper_Box_26 == true
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box5), array.clear(box6), array.clear(box7)
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[25] + 25, top=hh + (hh - ll), right=xAxisValue + 25, bottom=hh, bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[25] + 25, top=ll, right=xAxisValue + 25, bottom=ll + (ll - hh), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box5, box.new(left=xAxisValue + 25, top=(hh + (hh - ll)) + (hh - ll), right=xAxisValue + 50, bottom=hh + (hh - ll), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box7, box.new(left=xAxisValue + 50, top=(hh + (hh - ll)) + (hh - ll) + (hh - ll), right=xAxisValue + 76, bottom=(hh + (hh - ll)) + (hh - ll), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

    if Time == time and Box_Target_26 == 3 and Lower_Box_26 == true
        array.clear(box1), array.clear(box2), array.clear(box3), array.clear(box4), array.clear(box5), array.clear(box6), array.clear(box8)
        array.push(box1, box.new(left=xAxisValue[25], top=hh, right=xAxisValue, bottom=ll, border_color=color.new(color.blue, 10), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box2, box.new(left=xAxisValue[51], top=hh52, right=xAxisValue, bottom=ll52, border_color=color.new(color.red, 60), bgcolor=box52_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box3, box.new(left=xAxisValue[25] + 25, top=hh + (hh - ll), right=xAxisValue + 25, bottom=hh, bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box4, box.new(left=xAxisValue[25] + 25, top=ll, right=xAxisValue + 25, bottom=ll + (ll - hh), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box6, box.new(left=xAxisValue + 25, top=ll + (ll - hh), right=xAxisValue + 50, bottom=(ll + (ll - hh) + (ll - hh)), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))
        array.push(box8, box.new(left=xAxisValue + 50, top=(ll + (ll - hh)) - (hh - ll), right=xAxisValue + 76, bottom=(ll + (ll - hh)) - (hh - ll) - (hh - ll), bgcolor=box25_color, border_style=line.style_solid, xloc=xAxisStyle, extend=extend.none))

Box()

///////////////////
// End of Boxes
//////////////////

/////////////////////
// Plot Ichimoku Cross
/////////////////////

plotchar(ShowCross, title="Cross", location=location.bottom, color=conversionLine > baseLine ? color.blue : conversionLine < baseLine ? color.red : color.yellow)

///////////////////////////////////////////////////////////
// === Cross LOGIC ===
///////////////////////////////////////////////////////////

bullishCross = ta.crossover(conversionLine, baseLine)
bearishCross = ta.crossunder(conversionLine, baseLine)

PositionDirection = conversionLine > baseLine ? "Long" : conversionLine < baseLine ? "Short" : "Range"

var label lb = na
label.delete(lb)

if ShowPLable == true
    lb := label.new(
         bar_index,
         close,
         color=color.new(color.black, 0),
         textcolor=color.white,
         style=inLabelStyle == "Lower Right" ? label.style_label_upper_left : label.style_label_lower_left,
         text="╔═══════╗" + "\n" + "Position: " + PositionDirection + "\n" + "Price: " + str.tostring(close) + "\n" + "╚═══════╝"
     )
///////////
// Alerts
//////////

alertcondition(bullishCross, title="Buy Alert", message='{"content":"{{exchange}}:{{ticker}},   {{time}}, price = {{close}}, volume = {{volume}} order Buy"}')
alertcondition(bearishCross, title="Sell Alert", message='{"content":"{{exchange}}:{{ticker}},   {{time}}, price = {{close}}, volume = {{volume}} order Sell"}')

///////////
// End Of Alerts
//////////
````
