# ICT Daily & Weekly Liquidity Levels

- url: https://www.tradingview.com/script/9iGRhg3Q-ICT-Daily-Weekly-Liquidity-Levels/
- type: indicator
- pine_id: PUB;969a89923c0f41f69bc0ee8f63aee032
- version: 1.0

## Description

This TradingView indicator plots ICT-style higher-timeframe liquidity levels directly on your chart, including previous day high/low, current session high/low, previous week high/low, current week open, and previous week close. It uses daily and weekly data to calculate those levels, then draws horizontal rays from the candle where each level originated and extends them to the right. It also adds right-side labels with the level name and exact price, while allowing you to toggle each level, customize colors, adjust label spacing, and merge labels when multiple levels are close together. In simple terms, it gives you a clean map of major daily and weekly liquidity reference points for intraday trading.

## Source Code

````pine
//@version=6
indicator("ICT ETH Liquidity Levels", overlay=true, max_lines_count=100, max_labels_count=100)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
rightOffsetBars  = input.int(8, "Right Label Offset Bars", minval=1)
mergeTicks       = input.int(4, "Label Merge Threshold (ticks)", minval=0)
labelOffsetTicks = input.int(0, "Vertical Label Offset (ticks)", minval=-20, maxval=20)

showPDH = input.bool(true, "Show Previous Day High")
showPDL = input.bool(true, "Show Previous Day Low")
showCSH = input.bool(true, "Show Current Session High")
showCSL = input.bool(true, "Show Current Session Low")
showPWH = input.bool(true, "Show Previous Week High")
showPWL = input.bool(true, "Show Previous Week Low")
showCWO = input.bool(true, "Show Current Week Open")
showPWC = input.bool(true, "Show Previous Week Close")

colPDH = input.color(color.red, "PDH Color")
colPDL = input.color(color.lime, "PDL Color")
colCSH = input.color(color.orange, "Session High Color")
colCSL = input.color(color.aqua, "Session Low Color")
colPWH = input.color(color.fuchsia, "PWH Color")
colPWL = input.color(color.teal, "PWL Color")
colCWO = input.color(color.yellow, "Current Week Open Color")
colPWC = input.color(color.silver, "Previous Week Close Color")

labelTextColor = input.color(color.white, "Label Text Color")
labelBgColor   = input.color(color.black, "Label Background Color")

//--------------------------------------------------
// HTF prices
//--------------------------------------------------
pdh = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_off)
csh = request.security(syminfo.tickerid, "D", high,     lookahead=barmerge.lookahead_off)
csl = request.security(syminfo.tickerid, "D", low,      lookahead=barmerge.lookahead_off)

pwh = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_off)
cwo = request.security(syminfo.tickerid, "W", open,     lookahead=barmerge.lookahead_off)
pwc = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_off)

//--------------------------------------------------
// Detect new day / week
//--------------------------------------------------
isNewDay  = ta.change(time("D")) != 0
isNewWeek = ta.change(time("W")) != 0

//--------------------------------------------------
// Track source bars for day levels
//--------------------------------------------------
var float dayHigh = na
var float dayLow  = na
var int   dayHighBar = na
var int   dayLowBar  = na

var float prevDayHighTracked = na
var float prevDayLowTracked  = na
var int   prevDayHighBar     = na
var int   prevDayLowBar      = na

if isNewDay
    prevDayHighTracked := dayHigh
    prevDayLowTracked  := dayLow
    prevDayHighBar     := dayHighBar
    prevDayLowBar      := dayLowBar

    dayHigh    := high
    dayLow     := low
    dayHighBar := bar_index
    dayLowBar  := bar_index
else
    if na(dayHigh) or high >= dayHigh
        dayHigh    := high
        dayHighBar := bar_index
    if na(dayLow) or low <= dayLow
        dayLow    := low
        dayLowBar := bar_index

//--------------------------------------------------
// Track source bars for week levels
//--------------------------------------------------
var float weekHigh = na
var float weekLow  = na
var int   weekHighBar = na
var int   weekLowBar  = na

var float prevWeekHighTracked = na
var float prevWeekLowTracked  = na
var int   prevWeekHighBar     = na
var int   prevWeekLowBar      = na

var int currentWeekOpenBar = na
var int prevWeekCloseBar   = na

if barstate.isfirst
    currentWeekOpenBar := bar_index

if isNewWeek
    prevWeekHighTracked := weekHigh
    prevWeekLowTracked  := weekLow
    prevWeekHighBar     := weekHighBar
    prevWeekLowBar      := weekLowBar
    prevWeekCloseBar    := bar_index - 1

    weekHigh          := high
    weekLow           := low
    weekHighBar       := bar_index
    weekLowBar        := bar_index
    currentWeekOpenBar := bar_index
else
    if na(weekHigh) or high >= weekHigh
        weekHigh    := high
        weekHighBar := bar_index
    if na(weekLow) or low <= weekLow
        weekLow    := low
        weekLowBar := bar_index

//--------------------------------------------------
// Choose anchor bars
//--------------------------------------------------
pdhBar = prevDayHighBar
pdlBar = prevDayLowBar
cshBar = dayHighBar
cslBar = dayLowBar
pwhBar = prevWeekHighBar
pwlBar = prevWeekLowBar
cwoBar = currentWeekOpenBar
pwcBar = prevWeekCloseBar

//--------------------------------------------------
// Safe ray updater
//--------------------------------------------------
f_updateRay(_line, _show, _price, _bar, _color) =>
    line result = _line
    if _show and not na(_price) and not na(_bar)
        int xStart = _bar
        int xEnd   = math.max(bar_index, xStart + 1)

        if na(result)
            result := line.new(xStart, _price, xEnd, _price, xloc=xloc.bar_index, extend=extend.right, color=_color, width=2)
        else
            line.set_x1(result, xStart)
            line.set_y1(result, _price)
            line.set_x2(result, xEnd)
            line.set_y2(result, _price)
            line.set_extend(result, extend.right)
            line.set_color(result, _color)
            line.set_width(result, 2)
    else
        if not na(result)
            line.delete(result)
            result := na
    result

//--------------------------------------------------
// Persistent rays
//--------------------------------------------------
var line linePDH = na
var line linePDL = na
var line lineCSH = na
var line lineCSL = na
var line linePWH = na
var line linePWL = na
var line lineCWO = na
var line linePWC = na

linePDH := f_updateRay(linePDH, showPDH, pdh, pdhBar, colPDH)
linePDL := f_updateRay(linePDL, showPDL, pdl, pdlBar, colPDL)
lineCSH := f_updateRay(lineCSH, showCSH, csh, cshBar, colCSH)
lineCSL := f_updateRay(lineCSL, showCSL, csl, cslBar, colCSL)
linePWH := f_updateRay(linePWH, showPWH, pwh, pwhBar, colPWH)
linePWL := f_updateRay(linePWL, showPWL, pwl, pwlBar, colPWL)
lineCWO := f_updateRay(lineCWO, showCWO, cwo, cwoBar, colCWO)
linePWC := f_updateRay(linePWC, showPWC, pwc, pwcBar, colPWC)

//--------------------------------------------------
// Build raw level arrays
//--------------------------------------------------
var string[] levelNames  = array.new_string()
var float[]  levelPrices = array.new_float()

array.clear(levelNames)
array.clear(levelPrices)

if showPDH and not na(pdh)
    array.push(levelNames, "PDH")
    array.push(levelPrices, pdh)

if showPDL and not na(pdl)
    array.push(levelNames, "PDL")
    array.push(levelPrices, pdl)

if showCSH and not na(csh)
    array.push(levelNames, "Sess High")
    array.push(levelPrices, csh)

if showCSL and not na(csl)
    array.push(levelNames, "Sess Low")
    array.push(levelPrices, csl)

if showPWH and not na(pwh)
    array.push(levelNames, "PWH")
    array.push(levelPrices, pwh)

if showPWL and not na(pwl)
    array.push(levelNames, "PWL")
    array.push(levelPrices, pwl)

if showCWO and not na(cwo)
    array.push(levelNames, "CWO")
    array.push(levelPrices, cwo)

if showPWC and not na(pwc)
    array.push(levelNames, "PWC")
    array.push(levelPrices, pwc)

//--------------------------------------------------
// Merge labels by nearby prices
//--------------------------------------------------
var float[]  groupPrices = array.new_float()
var string[] groupTexts  = array.new_string()

array.clear(groupPrices)
array.clear(groupTexts)

mergeDistance = mergeTicks * syminfo.mintick
levelCount = array.size(levelPrices)

if levelCount > 0
    for i = 0 to levelCount - 1
        lvlPrice = array.get(levelPrices, i)
        lvlName  = array.get(levelNames, i)

        foundGroup = false
        groupCount = array.size(groupPrices)

        if groupCount > 0
            for g = 0 to groupCount - 1
                grpPrice = array.get(groupPrices, g)
                if math.abs(lvlPrice - grpPrice) <= mergeDistance
                    existingText = array.get(groupTexts, g)
                    array.set(groupTexts, g, existingText + " / " + lvlName)
                    foundGroup := true
                    break

        if not foundGroup
            array.push(groupPrices, lvlPrice)
            array.push(groupTexts, lvlName)

//--------------------------------------------------
// Right-side labels
//--------------------------------------------------
var label[] activeLabels = array.new_label()

oldLabelCount = array.size(activeLabels)
if oldLabelCount > 0
    for i = 0 to oldLabelCount - 1
        oldLbl = array.get(activeLabels, i)
        label.delete(oldLbl)
array.clear(activeLabels)

groupCountFinal = array.size(groupPrices)
labelX = bar_index + rightOffsetBars
labelYOffset = labelOffsetTicks * syminfo.mintick

if groupCountFinal > 0
    for i = 0 to groupCountFinal - 1
        priceVal = array.get(groupPrices, i)
        textVal  = array.get(groupTexts, i)

        lbl = label.new(
             labelX,
             priceVal + labelYOffset,
             textVal + "  " + str.tostring(priceVal, format.mintick),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             textcolor=labelTextColor,
             color=labelBgColor,
             size=size.small)

        array.push(activeLabels, lbl)
````
