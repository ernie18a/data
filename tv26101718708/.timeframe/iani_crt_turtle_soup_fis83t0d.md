# IANI CRT Turtle Soup

- url: https://www.tradingview.com/script/Fis83t0d-IANI-CRT-Turtle-Soup/
- type: indicator
- pine_id: PUB;a2644614777d4e1683403a7caf0dbecc
- version: 1.0

## Description

IANI CRT Turtle Soup is a clean price-action tool designed around CRT and Turtle Soup concepts.

The indicator detects when price takes the previous candle high or low and then closes back inside the previous candle range. This behavior can indicate a liquidity sweep, failed breakout or potential reversal setup.

The script marks possible Turtle Soup zones, confirmed Turtle Soup levels and objective levels directly on the chart. It also includes optional CHoCH/MSS confirmation and Fair Value Gap visualization after a Turtle Soup setup.

Main features:

• CRT / Turtle Soup detection
• Possible Turtle Soup levels
• Confirmed Turtle Soup levels
• Objective levels
• Multi-timeframe support
• Use chart timeframe or fixed timeframe
• CHoCH / MSS confirmation
• FVG zones after Turtle Soup
• Objective reached alerts
• Clean horizontal levels
• Custom colors and line widths
• Adjustable text size
• Limited historical calculation for cleaner charts

How to use:

A bullish Turtle Soup setup appears when price sweeps below a previous low and closes back above that level.

A bearish Turtle Soup setup appears when price sweeps above a previous high and closes back below that level.

After a Turtle Soup setup, traders can wait for additional confirmation such as CHoCH, MSS, FVG or market structure shift before considering an entry.

This tool is useful for traders who work with liquidity sweeps, CRT, ICT-style concepts, market structure and intraday reversal setups.

Recommended use:

For lower timeframes such as M1 or M5, use a higher fixed timeframe like M15 or H1 to detect stronger Turtle Soup zones.

Example:
Use the indicator on M1 with Fixed Timeframe set to M15, then wait for CHoCH or FVG confirmation before entry.

Disclaimer:

This indicator is for educational and analytical purposes only. It does not guarantee profits and it is not financial advice. Always use proper risk management and test before using it in live trading.

## Source Code

````pine
//@version=6
indicator("IANI CRT Turtle Soup", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

//==================================================
// INPUTS
//==================================================
group_tf = "TIMEFRAME"
useChartTF = input.bool(true, "Use Chart Timeframe", group=group_tf)
selectedTF = input.timeframe("15", "Fixed Timeframe", group=group_tf)

group_style = "STYLE"
styleMode = input.string("TLAB colors", "Style", options=["TLAB colors", "standard colors", "Monochrome black BG", "Monochrome grey BG", "Custom"], group=group_style)
customColor = input.color(color.black, "Custom Color", group=group_style)
textSizeInput = input.string("small", "Text Size", options=["tiny", "small", "normal"], group=group_style)
lineExtension = input.int(1, "Line Extension", minval=1, maxval=10, group=group_style)
objLineWidth = input.int(2, "Objective Line Width", minval=1, maxval=5, group=group_style)
tsLineWidth = input.int(1, "Turtle Soup Line Width", minval=1, maxval=5, group=group_style)

group_ts = "TURTLE SOUP SETTINGS"
showOnlyOBJ = input.bool(false, "Show Only Objectives", group=group_ts)
showPossibleTS = input.bool(true, "Show Possible TS When High/Low Is Taken", group=group_ts)
rangesToShow = input.string("First", "TS Ranges To Show", options=["First", "Last 3", "Last 10"], group=group_ts)

group_confirm = "ENTRY CONFIRMATION"
showCHoCH = input.bool(true, "Show CHoCH / MSS", group=group_confirm)
swingLen = input.int(3, "CHoCH Swing Length", minval=1, maxval=20, group=group_confirm)
showFVG = input.bool(true, "Show FVG After TS", group=group_confirm)
fvgBars = input.int(20, "FVG Extension Bars", minval=5, maxval=200, group=group_confirm)

group_alert = "ALERTS"
alertObjReached = input.bool(true, "Objective Reached Alert", group=group_alert)

group_calc = "CALCULATION"
calculatedBars = input.int(1000, "Calculated Bars", minval=100, maxval=5000, group=group_calc)


//==================================================
// HELPERS
//==================================================
activeTF = useChartTF ? timeframe.period : selectedTF
lineBars = lineExtension * 20
withinCalc = bar_index >= last_bar_index - calculatedBars

getSize(txt) =>
    s = size.small
    if txt == "tiny"
        s := size.tiny
    else if txt == "normal"
        s := size.normal
    else
        s := size.small
    s

formatTF(tf) =>
    out = tf
    if tf == "1"
        out := "1m"
    else if tf == "3"
        out := "3m"
    else if tf == "5"
        out := "5m"
    else if tf == "15"
        out := "15m"
    else if tf == "30"
        out := "30m"
    else if tf == "60"
        out := "1H"
    else if tf == "120"
        out := "2H"
    else if tf == "240"
        out := "4H"
    else if tf == "D"
        out := "D"
    else if tf == "W"
        out := "W"
    else
        out := tf
    out

tfName = formatTF(activeTF)
txtSize = getSize(textSizeInput)

colorTS = color.gray
colorOBJ = color.gray
colorPossible = color.gray
colorBull = color.lime
colorBear = color.red
colorFVGbull = color.new(color.green, 82)
colorFVGbear = color.new(color.red, 82)

if styleMode == "TLAB colors"
    colorTS := color.new(color.gray, 0)
    colorOBJ := color.new(color.white, 0)
    colorPossible := color.new(color.gray, 25)
    colorBull := color.new(color.lime, 0)
    colorBear := color.new(color.red, 0)
else if styleMode == "standard colors"
    colorTS := color.new(color.blue, 0)
    colorOBJ := color.new(color.orange, 0)
    colorPossible := color.new(color.gray, 25)
    colorBull := color.green
    colorBear := color.red
else if styleMode == "Monochrome black BG"
    colorTS := color.new(color.white, 10)
    colorOBJ := color.new(color.white, 0)
    colorPossible := color.new(color.white, 45)
    colorBull := color.white
    colorBear := color.white
else if styleMode == "Monochrome grey BG"
    colorTS := color.new(color.black, 10)
    colorOBJ := color.new(color.black, 0)
    colorPossible := color.new(color.black, 45)
    colorBull := color.black
    colorBear := color.black
else
    colorTS := customColor
    colorOBJ := customColor
    colorPossible := color.new(customColor, 40)
    colorBull := customColor
    colorBear := customColor


//==================================================
// ARRAYS / CLEAN OBJECTS
//==================================================
var line[] storedLines = array.new_line()
var label[] storedLabels = array.new_label()
var box[] storedBoxes = array.new_box()

maxSetups = 1
if rangesToShow == "Last 3"
    maxSetups := 3
else if rangesToShow == "Last 10"
    maxSetups := 10
else
    maxSetups := 1

maxLines = maxSetups * 2
maxLabels = maxSetups * 2
maxBoxes = 25

pushLine(ln) =>
    array.push(storedLines, ln)
    if array.size(storedLines) > maxLines
        old = array.shift(storedLines)
        line.delete(old)
    0

pushLabel(lb) =>
    array.push(storedLabels, lb)
    if array.size(storedLabels) > maxLabels
        old = array.shift(storedLabels)
        label.delete(old)
    0

pushBox(bx) =>
    array.push(storedBoxes, bx)
    if array.size(storedBoxes) > maxBoxes
        old = array.shift(storedBoxes)
        box.delete(old)
    0


//==================================================
// CRT / TURTLE SOUP CORE
//==================================================
calcTS() =>
    prevH = high[1]
    prevL = low[1]

    possibleBear = high > prevH
    possibleBull = low < prevL

    confirmedBear = possibleBear and close < prevH
    confirmedBull = possibleBull and close > prevL

    bearTSLevel = prevH
    bearOBJLevel = prevL

    bullTSLevel = prevL
    bullOBJLevel = prevH

    [confirmedBear, confirmedBull, possibleBear, possibleBull, bearTSLevel, bearOBJLevel, bullTSLevel, bullOBJLevel, time]

[confirmedBearTS, confirmedBullTS, possibleBearTS, possibleBullTS, bearTSLevel, bearOBJLevel, bullTSLevel, bullOBJLevel, srcTime] =
     request.security(syminfo.tickerid, activeTF, calcTS(), lookahead=barmerge.lookahead_off)


//==================================================
// STATE
//==================================================
var int lastSignalTime = na
var int activeDirection = 0
var float activeOBJ = na
var float activeTS = na
var bool objWasHit = false
var bool chochPrinted = false

newBearTS = withinCalc and confirmedBearTS and srcTime != lastSignalTime
newBullTS = withinCalc and confirmedBullTS and srcTime != lastSignalTime


//==================================================
// DRAW CONFIRMED TS + OBJECTIVE
//==================================================
if newBearTS
    lastSignalTime := srcTime
    activeDirection := -1
    activeOBJ := bearOBJLevel
    activeTS := bearTSLevel
    objWasHit := false
    chochPrinted := false

    if not showOnlyOBJ
        lnTS = line.new(bar_index, bearTSLevel, bar_index + lineBars, bearTSLevel, color=colorTS, width=tsLineWidth, style=line.style_dotted)
        lbTS = label.new(bar_index + lineBars, bearTSLevel, "TS " + tfName, style=label.style_none, textcolor=colorTS, size=txtSize)
        pushLine(lnTS)
        pushLabel(lbTS)

    lnOBJ = line.new(bar_index, bearOBJLevel, bar_index + lineBars, bearOBJLevel, color=colorOBJ, width=objLineWidth, style=line.style_solid)
    lbOBJ = label.new(bar_index + lineBars, bearOBJLevel, "OBJ " + tfName, style=label.style_none, textcolor=colorOBJ, size=txtSize)
    pushLine(lnOBJ)
    pushLabel(lbOBJ)

if newBullTS
    lastSignalTime := srcTime
    activeDirection := 1
    activeOBJ := bullOBJLevel
    activeTS := bullTSLevel
    objWasHit := false
    chochPrinted := false

    if not showOnlyOBJ
        lnTS = line.new(bar_index, bullTSLevel, bar_index + lineBars, bullTSLevel, color=colorTS, width=tsLineWidth, style=line.style_dotted)
        lbTS = label.new(bar_index + lineBars, bullTSLevel, "TS " + tfName, style=label.style_none, textcolor=colorTS, size=txtSize)
        pushLine(lnTS)
        pushLabel(lbTS)

    lnOBJ = line.new(bar_index, bullOBJLevel, bar_index + lineBars, bullOBJLevel, color=colorOBJ, width=objLineWidth, style=line.style_solid)
    lbOBJ = label.new(bar_index + lineBars, bullOBJLevel, "OBJ " + tfName, style=label.style_none, textcolor=colorOBJ, size=txtSize)
    pushLine(lnOBJ)
    pushLabel(lbOBJ)


//==================================================
// POSSIBLE TS - LAST LIVE ONLY
//==================================================
var line pTsLine = na
var label pTsLabel = na
var line pObjLine = na
var label pObjLabel = na

if barstate.islast
    if not na(pTsLine)
        line.delete(pTsLine)
    if not na(pTsLabel)
        label.delete(pTsLabel)
    if not na(pObjLine)
        line.delete(pObjLine)
    if not na(pObjLabel)
        label.delete(pObjLabel)

    pTsLine := na
    pTsLabel := na
    pObjLine := na
    pObjLabel := na

    if showPossibleTS and not confirmedBearTS and possibleBearTS
        if not showOnlyOBJ
            pTsLine := line.new(bar_index, bearTSLevel, bar_index + lineBars, bearTSLevel, color=colorPossible, width=tsLineWidth, style=line.style_dashed)
            pTsLabel := label.new(bar_index + lineBars, bearTSLevel, "P.TS " + tfName, style=label.style_none, textcolor=colorPossible, size=txtSize)

        pObjLine := line.new(bar_index, bearOBJLevel, bar_index + lineBars, bearOBJLevel, color=colorPossible, width=objLineWidth, style=line.style_dotted)
        pObjLabel := label.new(bar_index + lineBars, bearOBJLevel, "P.OBJ " + tfName, style=label.style_none, textcolor=colorPossible, size=txtSize)

    if showPossibleTS and not confirmedBullTS and possibleBullTS
        if not showOnlyOBJ
            pTsLine := line.new(bar_index, bullTSLevel, bar_index + lineBars, bullTSLevel, color=colorPossible, width=tsLineWidth, style=line.style_dashed)
            pTsLabel := label.new(bar_index + lineBars, bullTSLevel, "P.TS " + tfName, style=label.style_none, textcolor=colorPossible, size=txtSize)

        pObjLine := line.new(bar_index, bullOBJLevel, bar_index + lineBars, bullOBJLevel, color=colorPossible, width=objLineWidth, style=line.style_dotted)
        pObjLabel := label.new(bar_index + lineBars, bullOBJLevel, "P.OBJ " + tfName, style=label.style_none, textcolor=colorPossible, size=txtSize)


//==================================================
// CHoCH / MSS CONFIRMATION
//==================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

lastSwingHigh = ta.valuewhen(not na(ph), ph, 0)
lastSwingLow = ta.valuewhen(not na(pl), pl, 0)

bullCHoCH = showCHoCH and activeDirection == 1 and not chochPrinted and not na(lastSwingHigh) and close > lastSwingHigh
bearCHoCH = showCHoCH and activeDirection == -1 and not chochPrinted and not na(lastSwingLow) and close < lastSwingLow

if bullCHoCH
    label.new(bar_index, low, "CHoCH ▲", style=label.style_label_up, color=color.new(colorBull, 85), textcolor=colorBull, size=size.tiny)
    chochPrinted := true

if bearCHoCH
    label.new(bar_index, high, "CHoCH ▼", style=label.style_label_down, color=color.new(colorBear, 85), textcolor=colorBear, size=size.tiny)
    chochPrinted := true


//==================================================
// FVG AFTER TS
//==================================================
bullFVG = showFVG and activeDirection == 1 and low > high[2]
bearFVG = showFVG and activeDirection == -1 and high < low[2]

if bullFVG
    bx = box.new(bar_index - 2, low, bar_index + fvgBars, high[2], bgcolor=colorFVGbull, border_color=color.new(color.green, 30))
    pushBox(bx)

if bearFVG
    bx = box.new(bar_index - 2, low[2], bar_index + fvgBars, high, bgcolor=colorFVGbear, border_color=color.new(color.red, 30))
    pushBox(bx)


//==================================================
// OBJECTIVE HIT
//==================================================
objHitBull = activeDirection == 1 and not objWasHit and not na(activeOBJ) and high >= activeOBJ
objHitBear = activeDirection == -1 and not objWasHit and not na(activeOBJ) and low <= activeOBJ
objHit = objHitBull or objHitBear

if objHit
    objWasHit := true
    label.new(bar_index, activeOBJ, "OBJ HIT", style=label.style_none, textcolor=colorOBJ, size=size.tiny)


//==================================================
// ALERTS
//==================================================
alertcondition(newBullTS, "Bullish Turtle Soup", "Bullish Turtle Soup confirmed")
alertcondition(newBearTS, "Bearish Turtle Soup", "Bearish Turtle Soup confirmed")
alertcondition(bullCHoCH, "Bullish CHoCH after TS", "Bullish CHoCH after Turtle Soup")
alertcondition(bearCHoCH, "Bearish CHoCH after TS", "Bearish CHoCH after Turtle Soup")
alertcondition(alertObjReached and objHit, "Objective Reached", "Turtle Soup objective reached")
````
