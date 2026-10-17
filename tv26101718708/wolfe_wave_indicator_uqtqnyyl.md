# Wolfe Wave Indicator

- url: https://www.tradingview.com/script/UqtQNYyl-Wolfe-Wave-Indicator/
- type: indicator
- pine_id: PUB;3ab1fd5f96bd487f9cd5ac4d99e28fcd
- version: 7.0

## Description

**Wolfe Wave Indicator Description**

This indicator is a strict Wolfe Wave scanner and trade tracker built for cleaner pattern identification, trade-level plotting, and simple performance tracking.

It detects bullish and bearish Wolfe Wave structures from confirmed pivot highs and lows. A bullish setup requires a five-point sequence where point 3 is lower than point 1, point 5 is lower than point 3, point 4 remains inside the point 1 to point 2 price range, and point 5 forms near the projected point 1 to point 3 line. A bearish setup uses the inverse structure, requiring point 3 above point 1, point 5 above point 3, point 4 inside the point 1 to point 2 range, and point 5 near the projected point 1 to point 3 line.

The pattern begins as a pending Wolfe Wave once the five-point structure is detected. A trade confirms only after price closes back inside the point 1 to point 3 line. The script supports two entry styles: confirmation close or point 4 break. The stop loss is placed beyond point 5, with an optional tick buffer.

Targets are based on the Wolfe Wave EPA line. The EPA line is drawn from point 1 to point 4. TP1, TP2, and TP3 are calculated as user-defined portions or extensions of the distance from entry to the EPA line value at confirmation. By default, TP1 is halfway to the EPA line, TP2 is the EPA line target, and TP3 is an extension beyond the EPA line.

Trades remain open until either the stop loss is hit or TP3 is reached. TP1 and TP2 are tracked as partial target achievements, but they do not close the trade. Stats update only when a trade is fully closed. If the stop and TP3 are both touched on the same candle, the stop has priority.

By default, the indicator allows only one open Wolfe trade at a time. While one trade is open, no new Wolfe pattern will form or confirm. This is intentional and keeps the stats cleaner by avoiding overlapping trade signals. A user toggle is included to allow multiple open trades for those who want to use it more like a pattern scanner.

Visual behavior is simple. Pending patterns are yellow. Confirmed active trades are orange and display entry, stop loss, TP1, TP2, and TP3 levels. Closed historical patterns are purple. A display option allows the EPA line and point 1 to point 3 projection line to appear only on pending or active patterns, keeping historical patterns cleaner and reducing chart clutter.

This indicator is designed as a structured Wolfe Wave trade model, not a loose discretionary drawing tool. It uses strict validation rules, confirmed pivots, defined entry logic, defined stop logic, EPA-based targets, and closed-trade statistics.

## Source Code

````pine
//@version=6
indicator("Wolfe Wave", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 2000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pivotLeft   = input.int(8, "Pivot Bars Left",  minval = 1, group = "Zigzag")
pivotRight  = input.int(3, "Pivot Bars Right", minval = 1, group = "Zigzag")
searchDepth = input.int(2000, "Search Depth (Bars)", minval = 100, maxval = 5000, step = 100, group = "Zigzag", tooltip = "How many bars back the indicator scans for Wolfe Wave patterns.")

historicalLookback = input.int(20, "Historical Pattern Lookback", minval = 1, maxval = 500, group = "Historical Patterns")

min12AtrMultiplier  = input.float(5.0,  "Min 1-2 Size (ATR Multiplier)", minval = 0.1, maxval = 20.0, step = 0.1,  group = "Pattern", tooltip = "The price distance from point 1 to point 2 must be at least this multiple of the ATR at the time point 2 forms.")
min12AtrLength      = input.int(14,     "Min 1-2 ATR Length",             minval = 1,   maxval = 200,               group = "Pattern")
maxLineDeviationPct = input.float(0.25, "Max 5-Point Line Deviation %",   minval = 0.01, maxval = 5.0, step = 0.01, group = "Pattern")
useSymmetryFilter   = input.bool(true,  "Enable Symmetry Filter",                                                    group = "Pattern")
symmetryMin         = input.float(0.5,  "Min Symmetry Ratio",             minval = 0.01, maxval = 10.0, step = 0.05, group = "Pattern")
symmetryMax         = input.float(1.5,  "Max Symmetry Ratio",             minval = 0.01, maxval = 10.0, step = 0.05, group = "Pattern")
disallowOverlap     = input.bool(true,  "Disallow Pattern Overlap",                                                  group = "Pattern")

useP4RetracementFilter = input.bool(false, "Enable Point 4 Retracement Filter", group = "Point 4 Retracement Filter")
p4RetracementMin       = input.float(38.0, "Min Retracement %", minval = 1.0, maxval = 99.0, step = 0.5, group = "Point 4 Retracement Filter")
p4RetracementMax       = input.float(79.0, "Max Retracement %", minval = 1.0, maxval = 99.0, step = 0.5, group = "Point 4 Retracement Filter")

projectionBarsForward = input.int(50, "EPA Projection Bars Forward", minval = 1, maxval = 100, group = "Display")

showWaveLines  = input.bool(true, "Show Wolfe Lines",  group = "Display")
showWaveLabels = input.bool(true, "Show 1-5 Labels",   group = "Display")
showEPALine    = input.bool(true, "Show EPA Line 1-4", group = "Display")
showLine13     = input.bool(true, "Show 1-3-5 Line",   group = "Display")

showTriangle123  = input.bool(true, "Shade 1-2-3 Triangle", group = "Display")
triangle123Color = input.color(color.new(color.blue,   80), "1-2-3 Triangle Color", group = "Display")
showTriangle345  = input.bool(true, "Shade 3-4-5 Triangle", group = "Display")
triangle345Color = input.color(color.new(color.orange, 80), "3-4-5 Triangle Color", group = "Display")

showConfirmationTriangles     = input.bool(true, "Show Confirmation Triangles", group = "Display")
bullTriangleColor             = input.color(color.green, "Bull Triangle Color",   group = "Display")
bearTriangleColor             = input.color(color.red,   "Bear Triangle Color",   group = "Display")
confirmationTriangleSizeInput = input.string("Tiny", "Confirmation Triangle Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Display")

epaColor    = input.color(color.aqua, "EPA Line Color",   group = "Display")
line13Color = input.color(color.gray, "1-3-5 Line Color", group = "Display")

bullWaveColor   = input.color(color.green,  "Confirmed Bull Wave Color", group = "Wave Pattern Colors")
bearWaveColor   = input.color(color.red,    "Confirmed Bear Wave Color", group = "Wave Pattern Colors")
historicalColor = input.color(color.purple, "Historical Wave Color",     group = "Wave Pattern Colors")

showStatsWindow    = input.bool(true, "Show Stats Window", group = "Stats Window")
statsPositionInput = input.string("Top Right", "Stats Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = "Stats Window")
statsSizeInput     = input.string("Small", "Stats Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Stats Window")
statsBgColor       = input.color(color.new(color.black, 15), "Stats Background Color", group = "Stats Window")
statsHeaderColor   = input.color(color.new(color.blue, 0),   "Stats Header Color",     group = "Stats Window")
statsTextColor     = input.color(color.white, "Stats Text Color",   group = "Stats Window")
statsBorderColor   = input.color(color.gray,  "Stats Border Color", group = "Stats Window")

transparentColor = color.new(color.white, 100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Types
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

type WaveDrawing
    line p12
    line p23
    line p34
    line p45
    line line13
    line epaLine
    label p1Label
    label p2Label
    label p3Label
    label p4Label
    label p5Label
    label confirmationTriangle
    linefill fill123a
    linefill fill123b
    linefill fill345a
    linefill fill345b
    line fillBorder123_1
    line fillBorder123_2
    line fillBorder123_3
    line fillBorder123_4
    line fillBorder345_1
    line fillBorder345_2
    line fillBorder345_3
    line fillBorder345_4

type WavePattern
    int   p1Index
    int   p2Index
    int   p3Index
    int   p4Index
    int   p5Index
    float p1Price
    float p2Price
    float p3Price
    float p4Price
    float p5Price
    int   direction
    WaveDrawing drawing

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<int>   pivotIndexes = array.new<int>()
var array<float> pivotPrices  = array.new<float>()
var array<int>   pivotTypes   = array.new<int>()

var WavePattern        currentPattern  = na
var array<WavePattern> patternLookback = array.new<WavePattern>()

var array<int> confirmedPatternStarts = array.new<int>()
var array<int> confirmedPatternEnds   = array.new<int>()

newWolfeDetectedSignal    = false
bullishConfirmationSignal = false
bearishConfirmationSignal = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

getStatsPosition(string pos) =>
    pos == "Top Left"       ? position.top_left      :
     pos == "Top Center"    ? position.top_center    :
     pos == "Top Right"     ? position.top_right     :
     pos == "Middle Left"   ? position.middle_left   :
     pos == "Middle Center" ? position.middle_center :
     pos == "Middle Right"  ? position.middle_right  :
     pos == "Bottom Left"   ? position.bottom_left   :
     pos == "Bottom Center" ? position.bottom_center :
     position.bottom_right

getStatsSize(string sz) =>
    sz == "Tiny" ? size.tiny : sz == "Small" ? size.small : sz == "Normal" ? size.normal : size.large

getTriangleSize(string sz) =>
    sz == "Tiny" ? size.tiny : sz == "Small" ? size.small : sz == "Normal" ? size.normal : size.large

getConfirmedColor(int direction) =>
    direction > 0 ? bullWaveColor : bearWaveColor

lineValueAt(int x1, float y1, int x2, float y2, int x) =>
    x2 != x1 ? y1 + (y2 - y1) * (x - x1) / (x2 - x1) : y2

priceInsideRange(float price, float a, float b) =>
    price >= math.min(a, b) and price <= math.max(a, b)

linesIntersectX(int x1, float y1, int x2, float y2, int x3, float y3, int x4, float y4) =>
    m1 = (y2 - y1) / (x2 - x1)
    m2 = (y4 - y3) / (x4 - x3)
    slopeDiff = m1 - m2
    if math.abs(slopeDiff) < 1e-10
        float(na)
    else
        b1 = y1 - m1 * x1
        b2 = y3 - m2 * x3
        (b2 - b1) / slopeDiff

addConfirmedPatternRange(int startIndex, int endIndex) =>
    array.push(confirmedPatternStarts, startIndex)
    array.push(confirmedPatternEnds,   endIndex)
    if array.size(confirmedPatternStarts) > 500
        array.shift(confirmedPatternStarts)
        array.shift(confirmedPatternEnds)

startsInsideConfirmedPattern(int startIndex) =>
    inside = false
    if array.size(confirmedPatternStarts) > 0
        for i = 0 to array.size(confirmedPatternStarts) - 1
            if startIndex >= array.get(confirmedPatternStarts, i) and startIndex <= array.get(confirmedPatternEnds, i)
                inside := true
    inside

deleteDrawing(WaveDrawing d) =>
    if not na(d.p12)
        line.delete(d.p12)
        d.p12 := na
    if not na(d.p23)
        line.delete(d.p23)
        d.p23 := na
    if not na(d.p34)
        line.delete(d.p34)
        d.p34 := na
    if not na(d.p45)
        line.delete(d.p45)
        d.p45 := na
    if not na(d.line13)
        line.delete(d.line13)
        d.line13 := na
    if not na(d.epaLine)
        line.delete(d.epaLine)
        d.epaLine := na
    if not na(d.fill123a)
        linefill.delete(d.fill123a)
        d.fill123a := na
    if not na(d.fill123b)
        linefill.delete(d.fill123b)
        d.fill123b := na
    if not na(d.fill345a)
        linefill.delete(d.fill345a)
        d.fill345a := na
    if not na(d.fill345b)
        linefill.delete(d.fill345b)
        d.fill345b := na
    if not na(d.fillBorder123_1)
        line.delete(d.fillBorder123_1)
        d.fillBorder123_1 := na
    if not na(d.fillBorder123_2)
        line.delete(d.fillBorder123_2)
        d.fillBorder123_2 := na
    if not na(d.fillBorder123_3)
        line.delete(d.fillBorder123_3)
        d.fillBorder123_3 := na
    if not na(d.fillBorder123_4)
        line.delete(d.fillBorder123_4)
        d.fillBorder123_4 := na
    if not na(d.fillBorder345_1)
        line.delete(d.fillBorder345_1)
        d.fillBorder345_1 := na
    if not na(d.fillBorder345_2)
        line.delete(d.fillBorder345_2)
        d.fillBorder345_2 := na
    if not na(d.fillBorder345_3)
        line.delete(d.fillBorder345_3)
        d.fillBorder345_3 := na
    if not na(d.fillBorder345_4)
        line.delete(d.fillBorder345_4)
        d.fillBorder345_4 := na
    if not na(d.p1Label)
        label.delete(d.p1Label)
        d.p1Label := na
    if not na(d.p2Label)
        label.delete(d.p2Label)
        d.p2Label := na
    if not na(d.p3Label)
        label.delete(d.p3Label)
        d.p3Label := na
    if not na(d.p4Label)
        label.delete(d.p4Label)
        d.p4Label := na
    if not na(d.p5Label)
        label.delete(d.p5Label)
        d.p5Label := na
    if not na(d.confirmationTriangle)
        label.delete(d.confirmationTriangle)
        d.confirmationTriangle := na

setLineColor(line ln, color clr) =>
    if not na(ln)
        line.set_color(ln, clr)

setLabelColors(label lbl, color bgClr, color txtClr) =>
    if not na(lbl)
        label.set_color(lbl, bgClr)
        label.set_textcolor(lbl, txtClr)

setPatternVisible(WaveDrawing d, bool visible, color clr) =>
    patternClr = visible ? clr : transparentColor
    textClr    = visible ? chart.bg_color : transparentColor
    epaClr     = visible ? epaColor    : color.new(epaColor,    100)
    guideClr   = visible ? line13Color : color.new(line13Color, 100)
    setLineColor(d.p12,     patternClr)
    setLineColor(d.p23,     patternClr)
    setLineColor(d.p34,     patternClr)
    setLineColor(d.p45,     patternClr)
    setLineColor(d.line13,  guideClr)
    setLineColor(d.epaLine, epaClr)
    setLabelColors(d.p1Label, patternClr, textClr)
    setLabelColors(d.p2Label, patternClr, textClr)
    setLabelColors(d.p3Label, patternClr, textClr)
    setLabelColors(d.p4Label, patternClr, textClr)
    setLabelColors(d.p5Label, patternClr, textClr)
    hide = color.new(color.white, 100)
    if not na(d.fill123a)
        linefill.set_color(d.fill123a, visible and showTriangle123 ? triangle123Color : hide)
    if not na(d.fill123b)
        linefill.set_color(d.fill123b, visible and showTriangle123 ? triangle123Color : hide)
    if not na(d.fill345a)
        linefill.set_color(d.fill345a, visible and showTriangle345 ? triangle345Color : hide)
    if not na(d.fill345b)
        linefill.set_color(d.fill345b, visible and showTriangle345 ? triangle345Color : hide)

setProjectionLinesVisible(WaveDrawing d, bool visible) =>
    setLineColor(d.line13,  visible ? line13Color : color.new(line13Color, 100))
    setLineColor(d.epaLine, visible ? epaColor    : color.new(epaColor,    100))

setConfirmationTriangleVisible(WaveDrawing d, bool visible, int direction) =>
    if not na(d.confirmationTriangle)
        clr = visible ? (direction > 0 ? bullTriangleColor : bearTriangleColor) : transparentColor
        label.set_color(d.confirmationTriangle, clr)
        label.set_textcolor(d.confirmationTriangle, clr)

addPivot(int pIndex, float pPrice, int pType) =>
    pivotCount = array.size(pivotIndexes)
    if pivotCount == 0
        array.push(pivotIndexes, pIndex)
        array.push(pivotPrices,  pPrice)
        array.push(pivotTypes,   pType)
    else
        lastType  = array.get(pivotTypes,  pivotCount - 1)
        lastPrice = array.get(pivotPrices, pivotCount - 1)
        if pType == lastType
            if (pType == 1 and pPrice > lastPrice) or (pType == -1 and pPrice < lastPrice)
                array.set(pivotIndexes, pivotCount - 1, pIndex)
                array.set(pivotPrices,  pivotCount - 1, pPrice)
                array.set(pivotTypes,   pivotCount - 1, pType)
        else
            array.push(pivotIndexes, pIndex)
            array.push(pivotPrices,  pPrice)
            array.push(pivotTypes,   pType)
    if array.size(pivotIndexes) > 30
        array.shift(pivotIndexes)
        array.shift(pivotPrices)
        array.shift(pivotTypes)

drawTriangleFill(int xA, float yA, int xB, float yB, int xC, float yC, color fillClr) =>
    hide     = color.new(color.white, 100)
    yBaseAtB = lineValueAt(xA, yA, xC, yC, xB)
    base1 = line.new(xA, yA,       xB, yBaseAtB, color = hide, width = 1)
    leg1  = line.new(xA, yA,       xB, yB,       color = hide, width = 1)
    lf1   = linefill.new(base1, leg1, fillClr)
    base2 = line.new(xB, yBaseAtB, xC, yC,       color = hide, width = 1)
    leg2  = line.new(xB, yB,       xC, yC,       color = hide, width = 1)
    lf2   = linefill.new(base2, leg2, fillClr)
    [base1, leg1, lf1, base2, leg2, lf2]

drawWave(WavePattern p) =>
    WaveDrawing d = WaveDrawing.new()
    waveClr = p.direction > 0 ? bullWaveColor : bearWaveColor

    if showWaveLines
        d.p12 := line.new(p.p1Index, p.p1Price, p.p2Index, p.p2Price, color = waveClr, width = 2)
        d.p23 := line.new(p.p2Index, p.p2Price, p.p3Index, p.p3Price, color = waveClr, width = 2)
        d.p34 := line.new(p.p3Index, p.p3Price, p.p4Index, p.p4Price, color = waveClr, width = 2)
        d.p45 := line.new(p.p4Index, p.p4Price, p.p5Index, p.p5Price, color = waveClr, width = 2)

    if showTriangle123
        [b123_1, l123_1, lf123a, b123_2, l123_2, lf123b] = drawTriangleFill(p.p1Index, p.p1Price, p.p2Index, p.p2Price, p.p3Index, p.p3Price, triangle123Color)
        d.fill123a        := lf123a
        d.fill123b        := lf123b
        d.fillBorder123_1 := b123_1
        d.fillBorder123_2 := l123_1
        d.fillBorder123_3 := b123_2
        d.fillBorder123_4 := l123_2

    if showTriangle345
        [b345_1, l345_1, lf345a, b345_2, l345_2, lf345b] = drawTriangleFill(p.p3Index, p.p3Price, p.p4Index, p.p4Price, p.p5Index, p.p5Price, triangle345Color)
        d.fill345a        := lf345a
        d.fill345b        := lf345b
        d.fillBorder345_1 := b345_1
        d.fillBorder345_2 := l345_1
        d.fillBorder345_3 := b345_2
        d.fillBorder345_4 := l345_2

    if showLine13
        line13End      = p.p5Index + projectionBarsForward
        line13EndPrice = lineValueAt(p.p1Index, p.p1Price, p.p3Index, p.p3Price, line13End)
        d.line13 := line.new(p.p1Index, p.p1Price, line13End, line13EndPrice, color = line13Color, width = 1, style = line.style_dotted)

    if showEPALine
        epaEnd      = p.p5Index + projectionBarsForward
        epaEndPrice = lineValueAt(p.p1Index, p.p1Price, p.p4Index, p.p4Price, epaEnd)
        d.epaLine := line.new(p.p1Index, p.p1Price, epaEnd, epaEndPrice, color = epaColor, width = 2, style = line.style_dashed)

    if showWaveLabels
        d.p1Label := label.new(p.p1Index, p.p1Price, "1", color = waveClr, textcolor = chart.bg_color, style = label.style_label_center)
        d.p2Label := label.new(p.p2Index, p.p2Price, "2", color = waveClr, textcolor = chart.bg_color, style = label.style_label_center)
        d.p3Label := label.new(p.p3Index, p.p3Price, "3", color = waveClr, textcolor = chart.bg_color, style = label.style_label_center)
        d.p4Label := label.new(p.p4Index, p.p4Price, "4", color = waveClr, textcolor = chart.bg_color, style = label.style_label_center)
        d.p5Label := label.new(p.p5Index, p.p5Price, "5", color = waveClr, textcolor = chart.bg_color, style = label.style_label_center)
    d

drawConfirmationTriangle(bool bullish, int x) =>
    label.new(
         x         = x,
         y         = na,
         text      = "",
         xloc      = xloc.bar_index,
         yloc      = bullish ? yloc.belowbar : yloc.abovebar,
         style     = bullish ? label.style_triangleup : label.style_triangledown,
         color     = bullish ? bullTriangleColor : bearTriangleColor,
         textcolor = bullish ? bullTriangleColor : bearTriangleColor,
         size      = getTriangleSize(confirmationTriangleSizeInput)
     )

atr14 = ta.atr(min12AtrLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pivot Detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low,  pivotLeft, pivotRight)

newPivot = false
if not na(ph)
    addPivot(bar_index - pivotRight, ph, 1)
    newPivot := true
if not na(pl)
    addPivot(bar_index - pivotRight, pl, -1)
    newPivot := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Wolfe Wave Detection
// Pattern confirmed as soon as P5 is valid.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if newPivot and array.size(pivotIndexes) >= 5
    pivotCount = array.size(pivotIndexes)

    p1Index = array.get(pivotIndexes, pivotCount - 5)
    p2Index = array.get(pivotIndexes, pivotCount - 4)
    p3Index = array.get(pivotIndexes, pivotCount - 3)
    p4Index = array.get(pivotIndexes, pivotCount - 2)
    p5Index = array.get(pivotIndexes, pivotCount - 1)

    p1Price = array.get(pivotPrices, pivotCount - 5)
    p2Price = array.get(pivotPrices, pivotCount - 4)
    p3Price = array.get(pivotPrices, pivotCount - 3)
    p4Price = array.get(pivotPrices, pivotCount - 2)
    p5Price = array.get(pivotPrices, pivotCount - 1)

    p1Type = array.get(pivotTypes, pivotCount - 5)
    p2Type = array.get(pivotTypes, pivotCount - 4)
    p3Type = array.get(pivotTypes, pivotCount - 3)
    p4Type = array.get(pivotTypes, pivotCount - 2)
    p5Type = array.get(pivotTypes, pivotCount - 1)

    bullishShape = p1Type == -1 and p2Type == 1  and p3Type == -1 and p4Type == 1  and p5Type == -1
    bearishShape = p1Type == 1  and p2Type == -1 and p3Type == 1  and p4Type == -1 and p5Type == 1
    direction    = bullishShape ? 1 : bearishShape ? -1 : 0

    p12SwingSize = math.abs(p2Price - p1Price)
    atrAtP2      = ta.valuewhen(not na(ta.pivothigh(high, pivotLeft, pivotRight)) or not na(ta.pivotlow(low, pivotLeft, pivotRight)), atr14, 3)
    min12SizeOk  = not na(atrAtP2) and atrAtP2 > 0 and p12SwingSize >= min12AtrMultiplier * atrAtP2

    leg13Bars     = p3Index - p1Index
    leg35Bars     = p5Index - p3Index
    symmetryRatio = leg13Bars > 0 ? leg35Bars / leg13Bars : float(na)
    symmetryOk    = not useSymmetryFilter or (not na(symmetryRatio) and symmetryRatio >= symmetryMin and symmetryRatio <= symmetryMax)

    p5LinePrice  = lineValueAt(p1Index, p1Price, p3Index, p3Price, p5Index)
    deviationPct = math.abs(p5Price - p5LinePrice) / p5Price * 100.0
    lineTouchOk  = deviationPct <= maxLineDeviationPct

    point4InsideOk    = priceInsideRange(p4Price, p1Price, p2Price)
    point3Beyond1Ok   = (direction > 0 and p3Price < p1Price) or (direction < 0 and p3Price > p1Price)
    point5Beyond3Ok   = (direction > 0 and p5Price < p3Price) or (direction < 0 and p5Price > p3Price)
    point2CorrectSide = (direction > 0 and p2Price > p1Price) or (direction < 0 and p2Price < p1Price)

    apexX              = linesIntersectX(p1Index, p1Price, p3Index, p3Price, p2Index, p2Price, p4Index, p4Price)
    trendlinesConverge = not na(apexX) and apexX > p5Index

    p23Range            = math.abs(p3Price - p2Price)
    p4Retracement       = p23Range > 0 ? math.abs(p4Price - p3Price) / p23Range * 100.0 : 0.0
    point4RetracementOk = not useP4RetracementFilter or (p4Retracement >= p4RetracementMin and p4Retracement <= p4RetracementMax)

    withinSearchDepth = (bar_index - p1Index) <= searchDepth

    duplicate      = not na(currentPattern) and currentPattern.p5Index == p5Index
    overlapBlocked = disallowOverlap and startsInsideConfirmedPattern(p1Index)

    validPattern = direction != 0 and min12SizeOk and symmetryOk and lineTouchOk and point4InsideOk and point4RetracementOk and point3Beyond1Ok and point5Beyond3Ok and point2CorrectSide and trendlinesConverge and not duplicate and not overlapBlocked and withinSearchDepth

    if validPattern
        if not na(currentPattern)
            deleteDrawing(currentPattern.drawing)

        p = WavePattern.new(p1Index, p2Index, p3Index, p4Index, p5Index, p1Price, p2Price, p3Price, p4Price, p5Price, direction, WaveDrawing.new())
        p.drawing      := drawWave(p)
        currentPattern := p

        addConfirmedPatternRange(p1Index, p5Index)

        if showConfirmationTriangles
            currentPattern.drawing.confirmationTriangle := drawConfirmationTriangle(direction > 0, bar_index)

        array.push(patternLookback, currentPattern)
        if array.size(patternLookback) > historicalLookback
            oldPattern = array.shift(patternLookback)
            deleteDrawing(oldPattern.drawing)

        bullishConfirmationSignal := direction > 0
        bearishConfirmationSignal := direction < 0
        newWolfeDetectedSignal    := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pattern Display Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if array.size(patternLookback) > 0
    lastIdx = array.size(patternLookback) - 1
    for i = 0 to lastIdx
        p         = array.get(patternLookback, i)
        isCurrent = i == lastIdx

        if isCurrent
            setPatternVisible(p.drawing, true, getConfirmedColor(p.direction))
            setProjectionLinesVisible(p.drawing, true)
            setConfirmationTriangleVisible(p.drawing, true, p.direction)
        else
            setPatternVisible(p.drawing, true, historicalColor)
            setProjectionLinesVisible(p.drawing, false)
            setConfirmationTriangleVisible(p.drawing, true, p.direction)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Stats Window
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table statsTable = table.new(getStatsPosition(statsPositionInput), 2, 6, border_width = 1, border_color = statsBorderColor)

if barstate.islast
    if showStatsWindow
        bullCount = 0
        bearCount = 0
        total     = array.size(patternLookback)
        if total > 0
            for i = 0 to total - 1
                p = array.get(patternLookback, i)
                if p.direction > 0
                    bullCount += 1
                else
                    bearCount += 1

        sz = getStatsSize(statsSizeInput)
        table.cell(statsTable, 0, 0, "Wolfe Wave",       text_color = statsTextColor, bgcolor = statsHeaderColor, text_size = sz)
        table.merge_cells(statsTable, 0, 0, 1, 0)
        table.cell(statsTable, 0, 1, "Pivot Bars Left",  text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 1, 1, str.tostring(pivotLeft),  text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 0, 2, "Pivot Bars Right", text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 1, 2, str.tostring(pivotRight), text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 0, 3, "Search Depth",     text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 1, 3, str.tostring(searchDepth), text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 0, 4, "Bull Patterns",    text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 1, 4, str.tostring(bullCount), text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 0, 5, "Bear Patterns",    text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
        table.cell(statsTable, 1, 5, str.tostring(bearCount), text_color = statsTextColor, bgcolor = statsBgColor, text_size = sz)
    else
        table.clear(statsTable, 0, 0, 1, 5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Conditions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(newWolfeDetectedSignal,    title = "New Wolfe Wave Detected",     message = "New Wolfe Wave Detected")
alertcondition(bullishConfirmationSignal, title = "Bullish Wolfe Wave Detected", message = "Bullish Wolfe Wave Detected")
alertcondition(bearishConfirmationSignal, title = "Bearish Wolfe Wave Detected", message = "Bearish Wolfe Wave Detected")
````
