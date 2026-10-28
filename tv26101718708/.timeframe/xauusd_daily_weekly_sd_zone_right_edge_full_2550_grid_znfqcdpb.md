# XAUUSD Daily + Weekly SD Zone Right Edge + Full 25/50 Grid

- url: https://www.tradingview.com/script/ZNFQcDPB-XAUUSD-Daily-Weekly-SD-Zone-Right-Edge-Full-25-50-Grid/
- type: indicator
- pine_id: PUB;e327fe329b90401bb8cef05ac0864c1e
- version: 1.0

## Description

XAUUSD Daily + Weekly SD Zone Right Edge + Full 25/50 Grid

## Source Code

````pine
//@version=6
indicator("XAUUSD Daily + Weekly SD Zone Right Edge + Full 25/50 Grid", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50)

// ========================
// Daily Inputs
// ========================
futureOpen = input.float(4715.0, "Daily Gold Future Open", step=0.1)
dailyDiff  = input.float(15.0, "Daily Diff", step=0.1)

sd1 = input.float(62.0, "Daily 1SD Range", step=0.1)
sd2 = input.float(125.0, "Daily 2SD Range", step=0.1)
sd3 = input.float(189.0, "Daily 3SD Range", step=0.1)

// ========================
// Weekly Inputs
// ========================
showWeekly = input.bool(true, "Show Weekly SD Lines")

useChartWeeklyOpen = input.bool(true, "Weekly: Use Chart Weekly Open")
weeklyFutureOpenManual = input.float(4715.0, "Weekly Future Open Manual", step=0.1)
weeklyDiff = input.float(15.0, "Weekly Diff", step=0.1)

weeklySD1 = input.float(150.0, "Weekly 1SD Range", step=0.1)
weeklySD2 = input.float(300.0, "Weekly 2SD Range", step=0.1)
weeklySD3 = input.float(450.0, "Weekly 3SD Range", step=0.1)

// ========================
// Display Inputs
// ========================
showZoneFill = input.bool(true, "Show Daily SD Zone Box")
showGrid25   = input.bool(true, "Show 25 Grid Lines to Weekly 3SD")
showGrid50   = input.bool(true, "Show 50 Grid Lines to Weekly 3SD")
showGridLabels = input.bool(true, "Show Grid Price Labels")
showCurrent  = input.bool(true, "Show Current Price Line")
showDailyLabels  = input.bool(true, "Show Daily SD Labels Right")
showWeeklyLabels = input.bool(true, "Show Weekly SD Labels Left")

// ========================
// Colors
// ========================
meanColor    = input.color(color.yellow, "Daily Mean Color")
daily1Color  = input.color(color.lime, "Daily 1SD Color")
daily2Color  = input.color(color.orange, "Daily 2SD Color")
daily3Color  = input.color(color.red, "Daily 3SD Color")

weeklyMeanColor = input.color(color.white, "Weekly Mean Color")
weekly1Color    = input.color(color.blue, "Weekly 1SD Color")
weekly2Color    = input.color(color.purple, "Weekly 2SD Color")
weekly3Color    = input.color(color.fuchsia, "Weekly 3SD Color")

currentColor = input.color(color.aqua, "Current Price Color")

zone1Color = input.color(color.lime, "1SD Zone Fill")
zone2Color = input.color(color.yellow, "2SD Zone Fill")
zone3Color = input.color(color.red, "3SD Zone Fill")

// ========================
// Locked Setup
// ========================
rightExtendBars = 500
leftLookbackBars = 300

dailyLabelOffset = 470
weeklyLabelOffset = 295
gridLabelOffset = 175

// ========================
// Daily Calculation
// ========================
dailyMean = futureOpen - dailyDiff

dailySell1 = dailyMean + sd1
dailySell2 = dailyMean + sd2
dailySell3 = dailyMean + sd3

dailyBuy1 = dailyMean - sd1
dailyBuy2 = dailyMean - sd2
dailyBuy3 = dailyMean - sd3

// ========================
// Weekly Calculation
// ========================
chartWeeklyOpen = request.security(syminfo.tickerid, "W", open, barmerge.gaps_off, barmerge.lookahead_off)
weeklyOpenBase = useChartWeeklyOpen ? chartWeeklyOpen : weeklyFutureOpenManual

weeklyMean = weeklyOpenBase - weeklyDiff

weeklySell1 = weeklyMean + weeklySD1
weeklySell2 = weeklyMean + weeklySD2
weeklySell3 = weeklyMean + weeklySD3

weeklyBuy1 = weeklyMean - weeklySD1
weeklyBuy2 = weeklyMean - weeklySD2
weeklyBuy3 = weeklyMean - weeklySD3

// ========================
// Object Arrays
// ========================
var line[] allLines = array.new_line()
var label[] allLabels = array.new_label()
var box[] zoneBoxes = array.new_box()

clearAllLines() =>
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)

clearAllLabels() =>
    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1
            label.delete(array.get(allLabels, i))
        array.clear(allLabels)

clearZoneBoxes() =>
    if array.size(zoneBoxes) > 0
        for i = 0 to array.size(zoneBoxes) - 1
            box.delete(array.get(zoneBoxes, i))
        array.clear(zoneBoxes)

// ========================
// Helpers
// ========================
makeRightLine(_price, _color, _width, _style) =>
    _line = line.new(
         x1=bar_index - leftLookbackBars,
         y1=_price,
         x2=bar_index + rightExtendBars,
         y2=_price,
         xloc=xloc.bar_index,
         extend=extend.right,
         color=_color,
         style=_style,
         width=_width
    )
    array.push(allLines, _line)

makeLabel(_x, _price, _text, _bg, _txt, _size) =>
    _label = label.new(
         x=_x,
         y=_price,
         text=_text + " | " + str.tostring(_price, format.mintick),
         style=label.style_label_left,
         color=_bg,
         textcolor=_txt,
         size=_size
    )
    array.push(allLabels, _label)

makeZoneBox(_top, _bottom, _color) =>
    _b = box.new(
         left=bar_index - leftLookbackBars,
         top=_top,
         right=bar_index + rightExtendBars,
         bottom=_bottom,
         xloc=xloc.bar_index,
         bgcolor=color.new(_color, 88),
         border_color=color.new(_color, 100)
    )
    array.push(zoneBoxes, _b)

// 25 = เส้นประเล็ก / 50 = เส้นทึบขาวบาง
makeGridLine(_price, _step, _is50) =>
    _color = _is50 ? color.new(color.white, 8) : color.new(color.white, 76)
    _width = _is50 ? 1 : 1
    _style = _is50 ? line.style_solid : line.style_dashed
    _size  = _is50 ? size.tiny : size.tiny

    makeRightLine(_price, _color, _width, _style)

    if showGridLabels
        _txt = (_price > dailyMean ? "BOX +" : "BOX -") + str.tostring(_step)
        _bg = _is50 ? color.new(color.white, 10) : color.new(color.black, 86)
        _tc = _is50 ? color.black : color.white
        makeLabel(bar_index + gridLabelOffset, _price, _txt, _bg, _tc, _size)

// ========================
// Draw
// ========================
if barstate.islast
    clearAllLines()
    clearAllLabels()
    clearZoneBoxes()

    // ========================
    // Daily Lines
    // ========================
    makeRightLine(dailyMean,  meanColor,   3, line.style_solid)

    makeRightLine(dailySell1, daily1Color, 2, line.style_solid)
    makeRightLine(dailyBuy1,  daily1Color, 2, line.style_solid)

    makeRightLine(dailySell2, daily2Color, 2, line.style_solid)
    makeRightLine(dailyBuy2,  daily2Color, 2, line.style_solid)

    makeRightLine(dailySell3, daily3Color, 3, line.style_solid)
    makeRightLine(dailyBuy3,  daily3Color, 3, line.style_solid)

    // ========================
    // Weekly Lines
    // ========================
    if showWeekly
        makeRightLine(weeklyMean,  weeklyMeanColor, 2, line.style_solid)

        makeRightLine(weeklySell1, weekly1Color, 2, line.style_solid)
        makeRightLine(weeklyBuy1,  weekly1Color, 2, line.style_solid)

        makeRightLine(weeklySell2, weekly2Color, 2, line.style_solid)
        makeRightLine(weeklyBuy2,  weekly2Color, 2, line.style_solid)

        makeRightLine(weeklySell3, weekly3Color, 3, line.style_solid)
        makeRightLine(weeklyBuy3,  weekly3Color, 3, line.style_solid)

    // ========================
    // Daily Zone Boxes
    // ========================
    if showZoneFill
        makeZoneBox(dailySell1, dailyBuy1, zone1Color)
        makeZoneBox(dailySell2, dailySell1, zone2Color)
        makeZoneBox(dailyBuy1, dailyBuy2, zone2Color)
        makeZoneBox(dailySell3, dailySell2, zone3Color)
        makeZoneBox(dailyBuy2, dailyBuy3, zone3Color)

    // ========================
    // Full 25 / 50 Grid to Weekly 3SD
    // ========================
    upperDistance = math.abs(weeklySell3 - dailyMean)
    lowerDistance = math.abs(dailyMean - weeklyBuy3)
    maxGridDistance = math.max(upperDistance, lowerDistance)

    maxGridStepRaw = math.ceil(maxGridDistance / 25.0) * 25.0
    maxGridStep = int(maxGridStepRaw)

    for step = 25 to maxGridStep by 25
        is50 = step % 50 == 0

        if (is50 and showGrid50) or (not is50 and showGrid25)
            makeGridLine(dailyMean + step, step, is50)
            makeGridLine(dailyMean - step, step, is50)

    // ========================
    // Current Price
    // ========================
    if showCurrent
        makeRightLine(close, currentColor, 2, line.style_solid)

    // ========================
    // Weekly Labels Left
    // ========================
    if showWeekly and showWeeklyLabels
        weeklyX = bar_index - weeklyLabelOffset

        makeLabel(weeklyX, weeklyMean,  "W MEAN", color.new(weeklyMeanColor, 0), color.black, size.small)

        makeLabel(weeklyX, weeklySell1, "W +1SD", color.new(weekly1Color, 0), color.white, size.small)
        makeLabel(weeklyX, weeklyBuy1,  "W -1SD", color.new(weekly1Color, 0), color.white, size.small)

        makeLabel(weeklyX, weeklySell2, "W +2SD", color.new(weekly2Color, 0), color.white, size.small)
        makeLabel(weeklyX, weeklyBuy2,  "W -2SD", color.new(weekly2Color, 0), color.white, size.small)

        makeLabel(weeklyX, weeklySell3, "W +3SD", color.new(weekly3Color, 0), color.white, size.small)
        makeLabel(weeklyX, weeklyBuy3,  "W -3SD", color.new(weekly3Color, 0), color.white, size.small)

    // ========================
    // Daily Labels Right
    // ========================
    if showDailyLabels
        dailyX = bar_index + dailyLabelOffset

        makeLabel(dailyX, dailyMean,  "D MEAN", color.new(meanColor, 0), color.black, size.small)

        makeLabel(dailyX, dailySell1, "D +1SD", color.new(daily1Color, 0), color.black, size.small)
        makeLabel(dailyX, dailyBuy1,  "D -1SD", color.new(daily1Color, 0), color.black, size.small)

        makeLabel(dailyX, dailySell2, "D +2SD", color.new(daily2Color, 0), color.black, size.small)
        makeLabel(dailyX, dailyBuy2,  "D -2SD", color.new(daily2Color, 0), color.black, size.small)

        makeLabel(dailyX, dailySell3, "D +3SD", color.new(daily3Color, 0), color.white, size.small)
        makeLabel(dailyX, dailyBuy3,  "D -3SD", color.new(daily3Color, 0), color.white, size.small)
````
