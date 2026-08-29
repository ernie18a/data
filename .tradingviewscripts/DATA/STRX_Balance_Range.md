<!-- tradingview-pine-id: PUB;7c3195f02de14962b75259f8e78ac6a9 -->
<!-- tradingviewscripts-format: 1 -->
# STRX - Balance Range

Source: https://www.tradingview.com/script/haGZyl42/

## Description

STRX - Balance Range is a price-structure indicator designed to identify and track balanced trading ranges directly on the chart.

It detects periods of compression by comparing the recent price box width to ATR-based volatility, then validates the structure using persistence, edge interaction, and price position inside the range.

The script draws historical range boxes, can optionally connect consecutive ranges, and includes a compact statistics table showing the last closed range, the average of the last 10 ranges, and the average of the last 100 ranges.

This makes it useful for traders who want to study how current balance conditions compare with recent and broader market structure.

How it works:

A reference range is built from the highest high and lowest low of the previous lookback window.

The range is accepted only when its width remains compressed relative to ATR and the current price continues to behave inside that structure.

Additional filters help reduce random consolidations by requiring repeated interaction with the range boundaries and a minimum confirmation period.

How to use it:

Use the boxes to locate areas where price is rotating in balance rather than expanding directionally.

Compare the latest closed range with the 10-range and 100-range averages to judge whether current balance conditions are relatively small, typical, or expanded.

The tool is designed for structure reading and contextual analysis, not as a standalone buy/sell signal generator.

Inputs overview:

Range Length controls how many bars are used to define the reference box.

ATR Length and ATR Multiplier control how strict the volatility compression filter is.

Center Distance, Edge Touches, and Confirmation Bars refine the quality of detected ranges.

Visual options allow you to show or hide historical boxes, range markers, connection lines, and the statistics table.

Notes:

The statistics table uses closed historical ranges, so the values remain stable and easier to compare.

This indicator is intended for standard chart types and discretionary structure analysis.

It does not guarantee future performance and should be used together with your own risk management and market context reading.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stridex_STRX

//@version=6
indicator("STRX - Balance Range", overlay = true, max_boxes_count = 300, max_lines_count = 300)

//────────────────────────────────────────────
// INPUT GROUPS
//────────────────────────────────────────────
grpRange   = "Range Detection"
grpFilter  = "Validation Filters"
grpVisual  = "Visual Settings"
grpHistory = "Historical Connections"
grpTable   = "Statistics Table"

//────────────────────────────────────────────
// RANGE DETECTION
//────────────────────────────────────────────
length = input.int(
     10,
     title = "Range Length",
     minval = 2,
     group = grpRange,
     tooltip = "Numero di barre usate per costruire il box di riferimento del trading range. Valori più bassi rendono il detector più reattivo."
)

atrLength = input.int(
     14,
     title = "ATR Length",
     minval = 1,
     group = grpRange,
     tooltip = "Periodo ATR usato per adattare la soglia del range alla volatilità corrente."
)

atrMultiplier = input.float(
     3.0,
     title = "ATR Multiplier",
     minval = 0.1,
     step = 0.1,
     group = grpRange,
     tooltip = "Ampiezza massima consentita per il range in rapporto all'ATR. Valori più bassi selezionano range più stretti."
)

//────────────────────────────────────────────
// VALIDATION FILTERS
//────────────────────────────────────────────
centerPct = input.float(
     0.45,
     title = "Center Distance %",
     minval = 0.05,
     maxval = 0.80,
     step = 0.05,
     group = grpFilter,
     tooltip = "Distanza massima del prezzo dal centro del range, espressa come percentuale dell'ampiezza del box."
)

minTouches = input.int(
     1,
     title = "Min Edge Touches",
     minval = 1,
     maxval = 10,
     group = grpFilter,
     tooltip = "Numero minimo di contatti approssimativi richiesti sui bordi superiore e inferiore del range."
)

confirmBars = input.int(
     3,
     title = "Confirmation Bars",
     minval = 1,
     group = grpFilter,
     tooltip = "Numero minimo di barre consecutive che devono rispettare i filtri per confermare il trading range."
)

//────────────────────────────────────────────
// VISUAL SETTINGS
//────────────────────────────────────────────
showBoxes = input.bool(
     true,
     title = "Show Historical Boxes",
     group = grpVisual,
     tooltip = "Mostra tutti i trading range storici confermati come box sul grafico."
)

showStartDot = input.bool(
     true,
     title = "Show Start Marker",
     group = grpVisual,
     tooltip = "Mostra un marker sulla barra in cui un nuovo trading range viene confermato."
)

freezeOnBreak = input.bool(
     true,
     title = "Freeze Box On Breakout",
     group = grpVisual,
     tooltip = "Quando attivo, il box storico smette di estendersi quando il prezzo rompe il range."
)

boxBorderColor = input.color(
     color.new(color.yellow, 0),
     title = "Box Border",
     group = grpVisual,
     inline = "boxcol"
)

boxFillColor = input.color(
     color.new(color.yellow, 85),
     title = "Box Fill",
     group = grpVisual,
     inline = "boxcol",
     tooltip = "Colori del bordo e del riempimento dei box storici."
)

startDotColor = input.color(
     color.new(color.yellow, 0),
     title = "Start Marker Color",
     group = grpVisual,
     tooltip = "Colore del marker che segnala l'inizio di un nuovo trading range confermato."
)

//────────────────────────────────────────────
// HISTORICAL CONNECTIONS
//────────────────────────────────────────────
showConnectionLine = input.bool(
     true,
     title = "Connect Historical Ranges",
     group = grpHistory,
     tooltip = "Disegna una linea tra il centro del range precedente e quello del range successivo."
)

connectionStyleInput = input.string(
     "Dashed",
     title = "Line Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = grpHistory,
     inline = "conn",
     tooltip = "Stile della linea che collega i diversi range storici."
)

connectionWidth = input.int(
     1,
     title = "Width",
     minval = 1,
     maxval = 4,
     group = grpHistory,
     inline = "conn"
)

connectionColor = input.color(
     color.new(color.orange, 0),
     title = "Color",
     group = grpHistory,
     inline = "conn"
)

//────────────────────────────────────────────
// STATISTICS TABLE
//────────────────────────────────────────────
showStatsTable = input.bool(
     true,
     title = "Show Statistics Table",
     group = grpTable,
     tooltip = "Mostra una tabella semplice con ultimo range chiuso, media ultimi 10 range e media ultimi 100 range."
)

tablePositionInput = input.string(
     "Top Right",
     title = "Table Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group = grpTable,
     inline = "tbl"
)

tableTextSizeInput = input.string(
     "Small",
     title = "Text Size",
     options = ["Tiny", "Small", "Normal"],
     group = grpTable,
     inline = "tbl"
)

tableBgColor = input.color(
     color.new(color.black, 15),
     title = "Background",
     group = grpTable,
     inline = "tbl2"
)

tableFrameColor = input.color(
     color.new(color.gray, 40),
     title = "Frame",
     group = grpTable,
     inline = "tbl2"
)

tableTextColor = input.color(
     color.white,
     title = "Text",
     group = grpTable,
     inline = "tbl2"
)

//────────────────────────────────────────────
// CORE LOGIC
//────────────────────────────────────────────
atrValue = ta.atr(atrLength)

rangeHigh = ta.highest(high, length)[1]
rangeLow = ta.lowest(low, length)[1]
rangeSize = rangeHigh - rangeLow
rangeCenter = (rangeHigh + rangeLow) / 2.0

isCompressed = not na(rangeSize) and rangeSize <= atrValue * atrMultiplier
isInsideBox = not na(rangeHigh) and high <= rangeHigh and low >= rangeLow
priceNearCenter = not na(rangeCenter) and math.abs(close - rangeCenter) <= rangeSize * centerPct

touchTolerance = math.max(syminfo.mintick * 2, rangeSize * 0.15)
topTouches = 0
bottomTouches = 0

for i = 1 to length
    topTouches += math.abs(high[i] - rangeHigh) <= touchTolerance ? 1 : 0
    bottomTouches += math.abs(low[i] - rangeLow) <= touchTolerance ? 1 : 0

hasAcceptance = topTouches >= minTouches and bottomTouches >= minTouches
baseRange = isCompressed and isInsideBox and priceNearCenter and hasAcceptance

var int count = 0
count := baseRange ? count + 1 : 0

confirmedRange = count >= confirmBars
newRange = confirmedRange and not confirmedRange[1]

//────────────────────────────────────────────
// STORAGE
//────────────────────────────────────────────
var box currentBox = na
var bool boxOpen = false
var float lockedHigh = na
var float lockedLow = na
var float lockedCenter = na
var int lockedStartBar = na

var float prevRangeCenter = na
var int prevRangeBar = na

var float[] histRangeSizes = array.new_float()
var int[] histRangeBars = array.new_int()

var bool virtualRangeOpen = false
var float virtualRangeHigh = na
var float virtualRangeLow = na
var int virtualRangeStartBar = na

//────────────────────────────────────────────
// LINE STYLE
//────────────────────────────────────────────
lineStyle =
     connectionStyleInput == "Solid"  ? line.style_solid  :
     connectionStyleInput == "Dotted" ? line.style_dotted :
     line.style_dashed

//────────────────────────────────────────────
// NEW RANGE EVENT
//────────────────────────────────────────────
if newRange
    lockedHigh := rangeHigh
    lockedLow := rangeLow
    lockedCenter := (lockedHigh + lockedLow) / 2.0
    lockedStartBar := bar_index - count + 1

    if showBoxes
        currentBox := box.new(
             left = lockedStartBar,
             top = lockedHigh,
             right = bar_index,
             bottom = lockedLow,
             border_color = boxBorderColor,
             border_width = 1,
             bgcolor = boxFillColor
         )
        boxOpen := true
    else
        currentBox := na
        boxOpen := false

    if not showBoxes
        virtualRangeOpen := true
        virtualRangeHigh := lockedHigh
        virtualRangeLow := lockedLow
        virtualRangeStartBar := lockedStartBar

    if showConnectionLine and not na(prevRangeCenter) and not na(prevRangeBar)
        line.new(
             x1 = prevRangeBar,
             y1 = prevRangeCenter,
             x2 = bar_index,
             y2 = lockedCenter,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = connectionColor,
             style = lineStyle,
             width = connectionWidth
         )

    prevRangeCenter := lockedCenter
    prevRangeBar := bar_index

//────────────────────────────────────────────
// BOX MANAGEMENT
//────────────────────────────────────────────
if boxOpen and not na(currentBox)
    upBreak = close > lockedHigh
    downBreak = close < lockedLow
    stopUpdating = freezeOnBreak and (upBreak or downBreak)

    if confirmedRange and not stopUpdating
        box.set_right(currentBox, bar_index)
    else
        finalBars = math.max(1, bar_index - lockedStartBar + 1)
        finalSize = lockedHigh - lockedLow

        array.push(histRangeSizes, finalSize)
        array.push(histRangeBars, finalBars)

        boxOpen := false

//────────────────────────────────────────────
// VIRTUAL RANGE MANAGEMENT
//────────────────────────────────────────────
if virtualRangeOpen
    upBreakVirtual = close > virtualRangeHigh
    downBreakVirtual = close < virtualRangeLow
    stopVirtual = freezeOnBreak and (upBreakVirtual or downBreakVirtual)

    if not (confirmedRange and not stopVirtual)
        finalBarsVirtual = math.max(1, bar_index - virtualRangeStartBar + 1)
        finalSizeVirtual = virtualRangeHigh - virtualRangeLow

        array.push(histRangeSizes, finalSizeVirtual)
        array.push(histRangeBars, finalBarsVirtual)

        virtualRangeOpen := false

//────────────────────────────────────────────
// HELPER FUNCTIONS
//────────────────────────────────────────────
calcLastNFloatAvg(float[] arr, int sampleSize) =>
    arrSize = array.size(arr)
    useSize = math.min(sampleSize, arrSize)
    float sum = 0.0
    if useSize == 0
        na
    else
        for i = arrSize - useSize to arrSize - 1
            sum += array.get(arr, i)
        sum / useSize

calcLastNIntAvg(int[] arr, int sampleSize) =>
    arrSize = array.size(arr)
    useSize = math.min(sampleSize, arrSize)
    float sum = 0.0
    if useSize == 0
        na
    else
        for i = arrSize - useSize to arrSize - 1
            sum += array.get(arr, i)
        sum / useSize

//────────────────────────────────────────────
// STATS
//────────────────────────────────────────────
totalRanges = array.size(histRangeSizes)

lastRangeSize = totalRanges > 0 ? array.get(histRangeSizes, totalRanges - 1) : na
lastRangeBars = array.size(histRangeBars) > 0 ? array.get(histRangeBars, array.size(histRangeBars) - 1) : na

avg10Size = calcLastNFloatAvg(histRangeSizes, 10)
avg10Bars = calcLastNIntAvg(histRangeBars, 10)

avg100Size = calcLastNFloatAvg(histRangeSizes, 100)
avg100Bars = calcLastNIntAvg(histRangeBars, 100)

//────────────────────────────────────────────
// TABLE SETTINGS
//────────────────────────────────────────────
tablePos =
     tablePositionInput == "Top Left"     ? position.top_left :
     tablePositionInput == "Bottom Right" ? position.bottom_right :
     tablePositionInput == "Bottom Left"  ? position.bottom_left :
     position.top_right

tableTextSize =
     tableTextSizeInput == "Tiny"   ? size.tiny :
     tableTextSizeInput == "Normal" ? size.normal :
     size.small

var table statsTable = table.new(
     tablePos,
     2,
     4,
     border_width = 1,
     frame_color = tableFrameColor
)

//────────────────────────────────────────────
// TABLE RENDER
//────────────────────────────────────────────
if barstate.islast and showStatsTable
    table.cell(statsTable, 0, 0, "STRX Range Stats", text_color = tableTextColor, text_size = tableTextSize, bgcolor = tableBgColor)
    table.cell(statsTable, 1, 0, "Points / Bars", text_color = tableTextColor, text_size = tableTextSize, bgcolor = tableBgColor)

    table.cell(statsTable, 0, 1, "Last Range", text_color = tableTextColor, text_size = tableTextSize, bgcolor = tableBgColor)
    table.cell(statsTable, 1, 1,
         na(lastRangeSize) or na(lastRangeBars) ? "n/a" : str.format("{0} / {1}", str.tostring(lastRangeSize, format.mintick), str.tostring(lastRangeBars)),
         text_color = tableTextColor, text_size = tableTextSize, bgcolor = tableBgColor)

    table.cell(statsTable, 0, 2, "Avg Last 10", text_color = tableTextColor, text_size = tableTextSize, bgcolor = tableBgColor)
    table.cell(statsTable, 1, 2,
         na(avg10Size) or na(avg10Bars) ? "n/a" : str.format("{0} / {1}", str.tostring(avg10Size, format.mintick), str.tostring(avg10Bars, "#.0")),
         text_color = tableTextColor, text_size = tableTextSize, bgcolor = tableBgColor)

    table.cell(statsTable, 0, 3, "Avg Last 100", text_color = tableTextColor, text_size = tableTextSize, bgcolor = tableBgColor)
    table.cell(statsTable, 1, 3,
         na(avg100Size) or na(avg100Bars) ? "n/a" : str.format("{0} / {1}", str.tostring(avg100Size, format.mintick), str.tostring(avg100Bars, "#.0")),
         text_color = tableTextColor, text_size = tableTextSize, bgcolor = tableBgColor)

if barstate.islast and not showStatsTable
    table.clear(statsTable, 0, 0, 1, 3)

//────────────────────────────────────────────
// VISUAL MARKERS
//────────────────────────────────────────────
plotshape(
     showStartDot and newRange,
     title = "Range Start",
     style = shape.circle,
     location = location.abovebar,
     color = startDotColor,
     size = size.tiny
)
````
