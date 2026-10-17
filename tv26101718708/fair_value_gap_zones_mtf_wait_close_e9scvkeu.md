# Fair Value Gap Zones MTF + Wait Close

- url: https://www.tradingview.com/script/E9scvKeU-Fair-Value-Gap-Zones-MTF-Wait-Close/
- type: indicator
- pine_id: PUB;9ef9d8cefef44748a38fd3ee7523bec5
- version: 1.0

## Description

Fair Value Gap Zones MTF + Wait Close

Fair Value Gap Zones MTF is a market imbalance and liquidity indicator designed to automatically identify and project Fair Value Gap (FVG) zones across customizable timeframes.

Fair Value Gaps represent areas where price moves aggressively enough to leave an imbalance between buyers and sellers, creating regions that may later act as areas of interest for reaction, continuation, retracement, or liquidity interaction.

This indicator allows for multi-timeframe FVG analysis, optional displacement filtering, customizable gap thresholds, and dynamic zone management to provide greater flexibility across different trading styles and market environments.

Features:

• Automatic bullish and bearish Fair Value Gap detection
• Multi-timeframe (MTF) support
• Optional "Wait Until Bar Close" confirmation logic
• Multiple minimum gap sizing methods:

• ATR-based
• Percentage-based
• Fixed points-based

• Optional displacement candle requirement
• Box or line display modes
• Optional FVG midline plotting
• Extend zones into future price action
• Adjustable zone count limits
• Optional automatic deletion when zones become filled
• Fully customizable colors and styles

Alerts Included:

• New Bullish Fair Value Gap
• New Bearish Fair Value Gap

Potential use cases:

• Identify market imbalances
• Locate potential retracement areas
• Monitor liquidity interaction zones
• Add confluence to existing strategies
• Study continuation versus rebalancing behavior
• Analyze higher timeframe market structure

Interpretation:

Bullish Fair Value Gap

Indicates an imbalance created by aggressive upward movement where price may revisit the area before continuing.

Bearish Fair Value Gap

Indicates an imbalance created by aggressive downward movement where price may revisit the area before continuing.

Midline

Displays the midpoint of the imbalance and can act as an additional area of interest.

Displacement Filter

Allows filtering for stronger moves by requiring a larger displacement candle before creating a zone.

This indicator is designed to provide a flexible way to visualize potential market imbalances while allowing traders to adapt the behavior to different instruments and strategies.

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Fair Value Gap Zones MTF + Wait Close", overlay=true, max_boxes_count=500, max_lines_count=500)

//====================================================
// Inputs
//====================================================
groupTF = "Timeframe Controls"
calcTF = input.timeframe("", "Calculation Timeframe (blank = chart)")
waitClose = input.bool(true, "Wait Until Bar Close", group=groupTF)

groupFVG = "Fair Value Gap Rules"
minGapMode = input.string("ATR", "Minimum Gap Size Mode", options=["ATR", "Percent", "Points"], group=groupFVG)
atrLen = input.int(14, "ATR Length", minval=1, group=groupFVG)
atrMult = input.float(0.25, "ATR Multiplier", minval=0.0, step=0.05, group=groupFVG)
percentGap = input.float(0.05, "Percent Gap", minval=0.0, step=0.01, group=groupFVG)
pointsGap = input.float(5.0, "Points Gap", minval=0.0, step=0.25, group=groupFVG)

requireDisplacement = input.bool(false, "Require Displacement Candle", group=groupFVG)
displacementAtrMult = input.float(1.0, "Displacement ATR Multiplier", minval=0.1, step=0.1, group=groupFVG)

groupDisplay = "Display"
drawMode = input.string("Box", "Draw Mode", options=["Box", "Line"], group=groupDisplay)
showLastXZones = input.int(20, "Show Last X Zones", minval=1, maxval=200, group=groupDisplay)
deleteIfFilled = input.bool(false, "Delete Zone If Filled", group=groupDisplay)
extendZonesRight = input.bool(true, "Extend Zones Right", group=groupDisplay)

bullZoneColor = input.color(color.new(color.green, 82), "Bullish FVG Fill", group=groupDisplay)
bearZoneColor = input.color(color.new(color.red, 82), "Bearish FVG Fill", group=groupDisplay)
bullBorderColor = input.color(color.green, "Bullish Border / Line", group=groupDisplay)
bearBorderColor = input.color(color.red, "Bearish Border / Line", group=groupDisplay)
borderWidth = input.int(1, "Border / Line Width", minval=1, maxval=5, group=groupDisplay)
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupDisplay)

groupMid = "Midline"
showMidline = input.bool(true, "Show FVG Midline", group=groupMid)
midlineColor = input.color(color.yellow, "Midline Color", group=groupMid)
midlineWidth = input.int(1, "Midline Width", minval=1, maxval=5, group=groupMid)

//====================================================
// Helpers
//====================================================
lineStyle = lineStyleInput == "Dashed" ? line.style_dashed : lineStyleInput == "Dotted" ? line.style_dotted : line.style_solid
zoneExtend = extendZonesRight ? extend.right : extend.none

tfUse = calcTF == "" ? timeframe.period : calcTF

//====================================================
// Get MTF Data
//====================================================
o = request.security(syminfo.tickerid, tfUse, open)
h = request.security(syminfo.tickerid, tfUse, high)
l = request.security(syminfo.tickerid, tfUse, low)
c = request.security(syminfo.tickerid, tfUse, close)
confirmed = request.security(syminfo.tickerid, tfUse, barstate.isconfirmed ? 1 : 0)

atrValue = request.security(syminfo.tickerid, tfUse, ta.atr(atrLen))

canCalc = waitClose ? confirmed == 1 : true

gapThreshold =
     minGapMode == "ATR" ? atrValue * atrMult :
     minGapMode == "Percent" ? c * (percentGap / 100.0) :
     pointsGap

displacementOk = not requireDisplacement or math.abs(c[1] - o[1]) >= atrValue * displacementAtrMult

//====================================================
// FVG Logic
//====================================================
bullGapSize = l - h[2]
bullFVG = canCalc and bullGapSize >= gapThreshold and displacementOk

bearGapSize = l[2] - h
bearFVG = canCalc and bearGapSize >= gapThreshold and displacementOk

bullTop = l
bullBot = h[2]
bullMid = (bullTop + bullBot) / 2.0

bearTop = l[2]
bearBot = h
bearMid = (bearTop + bearBot) / 2.0

//====================================================
// Storage
//====================================================
var box[] zoneBoxes = array.new_box()
var line[] zoneLines = array.new_line()
var line[] midLines = array.new_line()
var float[] zoneTops = array.new_float()
var float[] zoneBots = array.new_float()
var int[] zoneDirs = array.new_int()

createZone(_top, _bot, _mid, _dir) =>
    zoneFill = _dir == 1 ? bullZoneColor : bearZoneColor
    zoneBorder = _dir == 1 ? bullBorderColor : bearBorderColor

    if drawMode == "Box"
        newBox = box.new(bar_index, _top, bar_index + 1, _bot, xloc=xloc.bar_index, extend=zoneExtend, bgcolor=zoneFill, border_color=zoneBorder, border_width=borderWidth)
        array.push(zoneBoxes, newBox)

    if drawMode == "Line"
        newLine = line.new(bar_index, _mid, bar_index + 1, _mid, xloc=xloc.bar_index, extend=zoneExtend, color=zoneBorder, width=borderWidth, style=lineStyle)
        array.push(zoneLines, newLine)

    if showMidline and drawMode == "Box"
        newMid = line.new(bar_index, _mid, bar_index + 1, _mid, xloc=xloc.bar_index, extend=zoneExtend, color=midlineColor, width=midlineWidth, style=line.style_dotted)
        array.push(midLines, newMid)
    else
        array.push(midLines, na)

    array.push(zoneTops, _top)
    array.push(zoneBots, _bot)
    array.push(zoneDirs, _dir)

// Only trigger once on new MTF bar
newTFBar = ta.change(time(tfUse))

if newTFBar
    if bullFVG
        createZone(bullTop, bullBot, bullMid, 1)

    if bearFVG
        createZone(bearTop, bearBot, bearMid, -1)

//====================================================
// Delete Filled Zones
//====================================================
if deleteIfFilled and array.size(zoneTops) > 0
    for i = array.size(zoneTops) - 1 to 0
        top = array.get(zoneTops, i)
        bot = array.get(zoneBots, i)
        dir = array.get(zoneDirs, i)

        filled = dir == 1 ? low <= bot : high >= top

        if filled
            if drawMode == "Box"
                box.delete(array.get(zoneBoxes, i))
                array.remove(zoneBoxes, i)

            if drawMode == "Line"
                line.delete(array.get(zoneLines, i))
                array.remove(zoneLines, i)

            midObj = array.get(midLines, i)
            if not na(midObj)
                line.delete(midObj)

            array.remove(midLines, i)
            array.remove(zoneTops, i)
            array.remove(zoneBots, i)
            array.remove(zoneDirs, i)

//====================================================
// Limit Last X Zones
//====================================================
while array.size(zoneTops) > showLastXZones
    if drawMode == "Box"
        oldBox = array.shift(zoneBoxes)
        box.delete(oldBox)

    if drawMode == "Line"
        oldLine = array.shift(zoneLines)
        line.delete(oldLine)

    oldMid = array.shift(midLines)
    if not na(oldMid)
        line.delete(oldMid)

    array.shift(zoneTops)
    array.shift(zoneBots)
    array.shift(zoneDirs)

//====================================================
// Alerts
//====================================================
alertcondition(bullFVG, title="New Bullish FVG", message="New bullish fair value gap detected on {{ticker}} {{interval}}")
alertcondition(bearFVG, title="New Bearish FVG", message="New bearish fair value gap detected on {{ticker}} {{interval}}")
````
