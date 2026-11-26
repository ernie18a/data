# HTF Liquidity + Swept + FVG / IFVG - FixedAAA

- url: https://www.tradingview.com/script/fRxiNwxa-HTF-Liquidity-Swept-FVG-IFVG-FixedAAA/
- type: indicator
- pine_id: PUB;0cee2f71e3444998a966dcd5a70d64fc
- version: 1.0

## Description

HTF Liquidity + Swept + FVG / IFVG is a multi-timeframe liquidity tool designed for traders who use Smart Money Concepts and ICT-style analysis.

The script plots previous Daily, 4H and 1H highs and lows as potential liquidity levels. When price sweeps one of these levels, the script marks it as swept and can trigger separate alerts for Daily, 4H and 1H liquidity sweeps.

It also detects bullish and bearish Fair Value Gaps, marks inverted FVGs, and includes a daily range midline. The goal is to help identify areas where liquidity has been taken and where price may react after displacement or imbalance.

Main features:
- Daily, 4H and 1H high/low liquidity levels
- Swept liquidity marking
- Separate alerts for Daily, 4H and 1H sweeps
- Bullish and bearish FVG detection
- IFVG detection
- Daily range midline
- Customizable colors, labels and level limits

This indicator is intended as an analysis aid only and should be used together with your own trading plan, market structure analysis and risk management.

## Source Code

````pine
//@version=5
indicator("HTF Liquidity + Swept + FVG / IFVG - FixedAAA", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
grpLiq = "LIQUIDITY LEVELS"

showDaily = input.bool(true, "Daily Highs/Lows", group=grpLiq)
show4H = input.bool(true, "4H Highs/Lows", group=grpLiq)
show1H = input.bool(true, "1H Highs/Lows", group=grpLiq)

levelsPerType = input.int(3, "High/Low levels per type", minval=1, maxval=20, group=grpLiq)
sweptKeep = input.int(2, "Swept levels to keep total", minval=0, maxval=20, group=grpLiq)

lineForward = input.int(80, "Line length to right", minval=5, maxval=500, group=grpLiq)
labelOffset = input.int(5, "Text after line", minval=1, maxval=50, group=grpLiq)

activeColor = input.color(color.white, "Active color", group=grpLiq)
sweptColor = input.color(color.gray, "Swept color", group=grpLiq)

lineWidth = input.int(1, "Line width", minval=1, maxval=5, group=grpLiq)
labelSizeIn = input.string("Small", "Label Size", options=["Tiny", "Small", "Medium", "Large"], group=grpLiq)

//━━━━━━━━━━━━━━━━━━━
// FVG / IFVG
//━━━━━━━━━━━━━━━━━━━
grpFvg = "FVG / IFVG"

showFVG = input.bool(true, "Show FVG / IFVG", group=grpFvg)
maxFVG = input.int(5, "Max active FVG to show", minval=0, maxval=50, group=grpFvg)
maxIFVG = input.int(1, "Max IFVG to show", minval=0, maxval=50, group=grpFvg)
ifvgLength = input.int(2, "IFVG Length", minval=1, maxval=50, group=grpFvg)
fvgLength = input.int(30, "Length of FVG", minval=1, maxval=500, group=grpFvg)
minPoints = input.float(6, "Minimum price points", minval=0, group=grpFvg)
autoMinPts = input.bool(true, "Auto minimum points for NQ / ES / Gold", group=grpFvg)
showSize = input.bool(true, "Show size", group=grpFvg)
fvgDetection = input.string("Wick", "FVG Detection", options=["Wick", "Body"], group=grpFvg)

bearFvgColor = input.color(color.new(color.red, 80), "Bearish color", group=grpFvg)
bullFvgColor = input.color(color.new(color.green, 80), "Bullish color", group=grpFvg)
ifvgColor = input.color(color.new(color.gray, 80), "IFVG color", group=grpFvg)

//━━━━━━━━━━━━━━━━━━━
// DAILY RANGE MIDLINE
//━━━━━━━━━━━━━━━━━━━
grpDailyMid = "DAILY MIDLINE"

showDailyMid = input.bool(true, "Show Daily Range Midline", group=grpDailyMid)
dailyMidColor = input.color(color.yellow, "Daily Midline Color", group=grpDailyMid)
dailyMidWidth = input.int(1, "Daily Midline Width", minval=1, maxval=5, group=grpDailyMid)
dailyMidBack = input.int(300, "Daily Midline left length", minval=1, maxval=1000, group=grpDailyMid)

//━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━
labelSize(string x) =>
    x == "Tiny" ? size.tiny :
     x == "Small" ? size.small :
     x == "Large" ? size.large :
     size.normal

getMinPoints() =>
    ticker = syminfo.ticker
    str.contains(ticker, "NQ") or str.contains(ticker, "MNQ") ? 10.0 :
     str.contains(ticker, "ES") or str.contains(ticker, "MES") or str.contains(ticker, "SPX") or str.contains(ticker, "US500") ? 4.0 :
     str.contains(ticker, "GC") or str.contains(ticker, "MGC") or str.contains(ticker, "XAU") ? 2.0 :
     minPoints

minPricePoints = autoMinPts ? getMinPoints() : minPoints

//━━━━━━━━━━━━━━━━━━━
// TYPES
//━━━━━━━━━━━━━━━━━━━
type HTFLevel
    line ln
    label lb
    float price
    bool isHigh
    string txt

var HTFLevel[] dHighs = array.new<HTFLevel>()
var HTFLevel[] dLows = array.new<HTFLevel>()
var HTFLevel[] h4Highs = array.new<HTFLevel>()
var HTFLevel[] h4Lows = array.new<HTFLevel>()
var HTFLevel[] h1Highs = array.new<HTFLevel>()
var HTFLevel[] h1Lows = array.new<HTFLevel>()
var HTFLevel[] sweptAll = array.new<HTFLevel>()

//━━━━━━━━━━━━━━━━━━━
// HTF LIQUIDITY FUNCTIONS
//━━━━━━━━━━━━━━━━━━━
addLevel(HTFLevel[] arr, float price, string txt, bool isHigh) =>
    if not na(price)
        l = line.new(bar_index, price, bar_index + lineForward, price, extend=extend.none, color=activeColor, width=lineWidth, style=line.style_solid)
        lab = label.new(bar_index + lineForward + labelOffset, price, txt, style=label.style_none, textcolor=activeColor, color=color.new(color.black, 100), size=labelSize(labelSizeIn))
        lv = HTFLevel.new(l, lab, price, isHigh, txt)
        array.push(arr, lv)

        while array.size(arr) > levelsPerType
            old = array.shift(arr)
            line.delete(old.ln)
            label.delete(old.lb)

checkSweep(HTFLevel[] arr) =>
    sweptAny = false
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            lv = array.get(arr, i)
            swept = lv.isHigh ? high > lv.price : low < lv.price

            if swept
                sweptAny := true
                line.set_x2(lv.ln, bar_index)
                line.set_color(lv.ln, sweptColor)
                line.set_style(lv.ln, line.style_dotted)

                midX = math.floor((line.get_x1(lv.ln) + line.get_x2(lv.ln)) / 2)
                label.set_x(lv.lb, midX)
                label.set_y(lv.lb, lv.price + syminfo.mintick * 8)
                label.set_text(lv.lb, lv.txt + " swept")
                label.set_textcolor(lv.lb, sweptColor)

                array.push(sweptAll, lv)
                array.remove(arr, i)

                while array.size(sweptAll) > sweptKeep
                    old = array.shift(sweptAll)
                    line.delete(old.ln)
                    label.delete(old.lb)
    sweptAny

moveLevels(HTFLevel[] arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            lv = array.get(arr, i)
            line.set_x2(lv.ln, bar_index + lineForward)
            label.set_x(lv.lb, bar_index + lineForward + labelOffset)

//━━━━━━━━━━━━━━━━━━━
// HTF DATA
//━━━━━━━━━━━━━━━━━━━
newDay = ta.change(time("D")) != 0
new4H = ta.change(time("240")) != 0
new1H = ta.change(time("60")) != 0

dHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
dLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
h4High = request.security(syminfo.tickerid, "240", high[1], lookahead=barmerge.lookahead_on)
h4Low = request.security(syminfo.tickerid, "240", low[1], lookahead=barmerge.lookahead_on)
h1High = request.security(syminfo.tickerid, "60", high[1], lookahead=barmerge.lookahead_on)
h1Low = request.security(syminfo.tickerid, "60", low[1], lookahead=barmerge.lookahead_on)

if showDaily and newDay
    addLevel(dHighs, dHigh, "Daily High", true)
    addLevel(dLows, dLow, "Daily Low", false)

if show4H and new4H
    addLevel(h4Highs, h4High, "4H High", true)
    addLevel(h4Lows, h4Low, "4H Low", false)

if show1H and new1H
    addLevel(h1Highs, h1High, "1H High", true)
    addLevel(h1Lows, h1Low, "1H Low", false)

dHighSwept = checkSweep(dHighs)
dLowSwept = checkSweep(dLows)
h4HighSwept = checkSweep(h4Highs)
h4LowSwept = checkSweep(h4Lows)
h1HighSwept = checkSweep(h1Highs)
h1LowSwept = checkSweep(h1Lows)

dailySwept = dHighSwept or dLowSwept
h4Swept = h4HighSwept or h4LowSwept
h1Swept = h1HighSwept or h1LowSwept
anyHtfSwept = dailySwept or h4Swept or h1Swept

alertcondition(dHighSwept, title="Daily High Swept", message="Daily High swept on {{ticker}} {{interval}}")
alertcondition(dLowSwept, title="Daily Low Swept", message="Daily Low swept on {{ticker}} {{interval}}")
alertcondition(dailySwept, title="Daily Liquidity Swept", message="Daily liquidity swept on {{ticker}} {{interval}}")

alertcondition(h4HighSwept, title="4H High Swept", message="4H High swept on {{ticker}} {{interval}}")
alertcondition(h4LowSwept, title="4H Low Swept", message="4H Low swept on {{ticker}} {{interval}}")
alertcondition(h4Swept, title="4H Liquidity Swept", message="4H liquidity swept on {{ticker}} {{interval}}")

alertcondition(h1HighSwept, title="1H High Swept", message="1H High swept on {{ticker}} {{interval}}")
alertcondition(h1LowSwept, title="1H Low Swept", message="1H Low swept on {{ticker}} {{interval}}")
alertcondition(h1Swept, title="1H Liquidity Swept", message="1H liquidity swept on {{ticker}} {{interval}}")

alertcondition(anyHtfSwept, title="Any HTF Liquidity Swept", message="HTF liquidity swept on {{ticker}} {{interval}}")

if barstate.islast
    moveLevels(dHighs)
    moveLevels(dLows)
    moveLevels(h4Highs)
    moveLevels(h4Lows)
    moveLevels(h1Highs)
    moveLevels(h1Lows)

//━━━━━━━━━━━━━━━━━━━
// FVG / IFVG ARRAYS
//━━━━━━━━━━━━━━━━━━━
var box[] fvgBoxes = array.new_box()
var line[] fvgMidLines = array.new_line()
var label[] fvgLabels = array.new_label()
var bool[] fvgIsBull = array.new_bool()
var bool[] fvgIsInv = array.new_bool()

deleteFVG(int idx) =>
    box.delete(array.get(fvgBoxes, idx))
    line.delete(array.get(fvgMidLines, idx))

    oldLab = array.get(fvgLabels, idx)
    if not na(oldLab)
        label.delete(oldLab)

    array.remove(fvgBoxes, idx)
    array.remove(fvgMidLines, idx)
    array.remove(fvgLabels, idx)
    array.remove(fvgIsBull, idx)
    array.remove(fvgIsInv, idx)

pruneFVGs() =>
    activeCount = 0
    invCount = 0

    if array.size(fvgBoxes) > 0
        for i = array.size(fvgBoxes) - 1 to 0
            if array.get(fvgIsInv, i)
                invCount += 1
                if invCount > maxIFVG
                    deleteFVG(i)
            else
                activeCount += 1
                if activeCount > maxFVG
                    deleteFVG(i)

addFVG(float top, float bottom, bool bull, float sizePoints) =>
    c = bull ? bullFvgColor : bearFvgColor
    textCol = color.new(c, 0)
    mid = (top + bottom) / 2

    b = box.new(bar_index - 2, top, bar_index + fvgLength, bottom, bgcolor=c, border_color=color.new(c, 90))
    midLine = line.new(bar_index - 2, mid, bar_index + fvgLength, mid, extend=extend.none, color=textCol, width=1, style=line.style_dotted)

    array.push(fvgBoxes, b)
    array.push(fvgMidLines, midLine)
    array.push(fvgIsBull, bull)
    array.push(fvgIsInv, false)

    if showSize
        lab = label.new(bar_index + fvgLength, top, str.tostring(sizePoints, "#.##"), style=label.style_none, textcolor=textCol, color=color.new(color.black, 100), size=size.small)
        array.push(fvgLabels, lab)
    else
        array.push(fvgLabels, na)

    pruneFVGs()

//━━━━━━━━━━━━━━━━━━━
// FVG DETECTION
//━━━━━━━━━━━━━━━━━━━
bullTop = fvgDetection == "Body" ? math.min(open, close) : low
bullBot = fvgDetection == "Body" ? math.max(open[2], close[2]) : high[2]
bearTop = fvgDetection == "Body" ? math.min(open[2], close[2]) : low[2]
bearBot = fvgDetection == "Body" ? math.max(open, close) : high

bullFVG = bullTop > bullBot
bearFVG = bearTop > bearBot

bullSize = bullTop - bullBot
bearSize = bearTop - bearBot

validBull = showFVG and bullFVG and bullSize >= minPricePoints
validBear = showFVG and bearFVG and bearSize >= minPricePoints

if validBull
    addFVG(bullTop, bullBot, true, bullSize)

if validBear
    addFVG(bearTop, bearBot, false, bearSize)

//━━━━━━━━━━━━━━━━━━━
// IFVG DETECTION
//━━━━━━━━━━━━━━━━━━━
if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        b = array.get(fvgBoxes, i)
        midLine = array.get(fvgMidLines, i)
        lab = array.get(fvgLabels, i)
        isBull = array.get(fvgIsBull, i)
        inverted = array.get(fvgIsInv, i)

        top = box.get_top(b)
        bot = box.get_bottom(b)

        if not inverted
            inv = isBull ? close < bot : close > top

            if inv
                box.set_bgcolor(b, ifvgColor)
                box.set_border_color(b, color.new(ifvgColor, 90))
                line.set_color(midLine, color.new(ifvgColor, 0))
                line.set_x2(midLine, bar_index + ifvgLength)
                box.set_right(b, bar_index + ifvgLength)

                if not na(lab)
                    label.set_textcolor(lab, color.new(ifvgColor, 0))
                    label.set_x(lab, bar_index + ifvgLength)

                array.set(fvgIsInv, i, true)

pruneFVGs()

//━━━━━━━━━━━━━━━━━━━
// DAILY RANGE MIDLINE
//━━━━━━━━━━━━━━━━━━━
var line dailyMidLine = na
var label dailyMidLabel = na
var float todayHigh = na
var float todayLow = na

if newDay
    todayHigh := high
    todayLow := low
else
    todayHigh := math.max(nz(todayHigh, high), high)
    todayLow := math.min(nz(todayLow, low), low)

dailyMid = (todayHigh + todayLow) / 2

if barstate.islast
    if showDailyMid and not na(dailyMid)
        if na(dailyMidLine)
            dailyMidLine := line.new(bar_index - dailyMidBack, dailyMid, bar_index + lineForward, dailyMid, extend=extend.none, color=dailyMidColor, width=dailyMidWidth, style=line.style_dotted)
        else
            line.set_xy1(dailyMidLine, bar_index - dailyMidBack, dailyMid)
            line.set_xy2(dailyMidLine, bar_index + lineForward, dailyMid)
            line.set_color(dailyMidLine, dailyMidColor)
            line.set_width(dailyMidLine, dailyMidWidth)

        if na(dailyMidLabel)
            dailyMidLabel := label.new(bar_index + lineForward + labelOffset, dailyMid, "Daily Mid", style=label.style_none, textcolor=dailyMidColor, color=color.new(color.black, 100), size=size.small)
        else
            label.set_x(dailyMidLabel, bar_index + lineForward + labelOffset)
            label.set_y(dailyMidLabel, dailyMid)
            label.set_textcolor(dailyMidLabel, dailyMidColor)
    else
        if not na(dailyMidLine)
            line.delete(dailyMidLine)
            dailyMidLine := na
        if not na(dailyMidLabel)
            label.delete(dailyMidLabel)
            dailyMidLabel := na
````
