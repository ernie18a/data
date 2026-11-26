# COT-Trader Seasonality - Indexed Geometric Path

- url: https://www.tradingview.com/script/RpxmGNjD-COT-Trader-Seasonality-Indexed-Geometric-Path/
- type: indicator
- pine_id: PUB;6d7dff0248034574927ae98309088fc1
- version: 2.0

## Description

COT-Trader Seasonality is a visual research indicator designed to study seasonal tendencies in futures, commodities, indices and other markets.

The script focuses on one specific question:

How has a market typically behaved throughout the calendar year when historical years are compared on a normalized basis?

Instead of averaging raw historical prices, the indicator indexes each historical year to a base value of 100 at the first available trading day of that year. This makes different years comparable across changing price regimes.

This is especially useful for markets such as commodities and futures, where long-term price levels can change significantly over time.

[b]Methodology[/b]

The indicator uses an Indexed Geometric Seasonal Path approach:

1. Each historical year is indexed to 100 at its first available trading day.
2. Each following trading day is converted into a relative factor versus that year’s starting value.
3. For each calendar day, the geometric mean of the indexed historical factors is calculated.
4. The resulting seasonal curves are plotted on a synthetic January-to-December seasonal scale.

The geometric approach is used because price development is multiplicative. A 10% gain followed by a 10% loss does not return a market to its original level. Working with relative factors is therefore more appropriate than directly averaging absolute historical prices.

[b]Displayed Curves[/b]

The indicator can display:

• 10Y Main Seasonal Curve
• 5Y Seasonal Curve
• 15Y Seasonal Curve
• 20Y Seasonal Curve
• Current Year / YTD indexed path
• Previous Year indexed path
• Synthetic seasonal month scale

The 10Y curve is the main reference curve. The 5Y, 15Y and 20Y curves are included as comparison views to help evaluate whether shorter-term seasonal tendencies differ from longer-term historical behavior.

The current year line stops at the latest available data point. It is not extended into the future.

[b]How to Use[/b]

This indicator can be used to:

• compare the current year against historical seasonal tendencies
• identify periods where several seasonal curves move in a similar direction
• compare shorter-term and longer-term seasonal behavior
• study whether the current year is behaving normally or as an outlier
• support broader market research together with positioning, fundamentals, volatility and risk analysis

The month labels shown in the indicator are a synthetic seasonal month scale. They are not the same as the chart’s real time axis.

What This Indicator Does Not Do

This script does not generate buy or sell signals.

It does not predict future prices.

It does not automatically identify the best seasonal trading window.

It does not include stop-loss, take-profit, position sizing or strategy backtesting logic.

It is intended as a visual research tool, not as a standalone trading system.

[b]Limitations[/b]

Seasonality describes historical tendencies, not certainties. Markets can deviate significantly from historical seasonal patterns due to macroeconomic conditions, weather, supply-demand shocks, positioning, volatility, futures contract rolls or other market-specific factors.

For futures and continuous contracts, historical data quality and roll methodology can influence the visual result.

The indicator should be used as one part of a broader analytical process.


[b]Initial public release.[/b]

Features:
• Indexed geometric seasonal path calculation
• Fixed 10Y main seasonal curve
• 5Y, 15Y and 20Y comparison curves
• Current year / YTD indexed path
• Previous year indexed path
• Synthetic January-to-December seasonal month scale
• Built-in legend and methodology table

This indicator is designed for visual seasonal research and does not generate trading signals.

## Source Code

````pine
//@version=6
// Seasonality v1.0
//
// Methodology:
// Indexed Geometric Seasonal Path
// - Daily data is used internally.
// - Each historical year is indexed to 100 at its first available trading day.
// - For each calendar day, the geometric mean of indexed year factors is calculated.
// - This avoids averaging absolute historical prices across different price regimes.
// - Current Year and Previous Year are shown as indexed real year paths.
// - The indicator visualizes seasonal tendencies only and does not generate trading signals.

indicator("Seasonality - Indexed Geometric Path",
     overlay=false,
     max_lines_count=500,
     max_labels_count=150,
     max_bars_back=5000)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
baseValue   = input.float(100.0, "Base Index Start", minval=1)
plotAsPct   = input.bool(false, "Show as % vs Base")
displayBars = input.int(252, "Seasonal Chart Width (Bars)", minval=150, maxval=500)

showMain     = input.bool(true, "Show 10Y Main Seasonal Curve")
show5Y       = input.bool(true, "Show 5Y Seasonal Curve")
show15Y      = input.bool(true, "Show 15Y Seasonal Curve")
show20Y      = input.bool(true, "Show 20Y Seasonal Curve")
showCurrent  = input.bool(true, "Show Current Year")
showPrevious = input.bool(true, "Show Previous Year")

showLegend      = input.bool(true, "Show Legend / Info Table")
showMonthLabels = input.bool(true, "Show Seasonal Month Labels")
showMonthGuides = input.bool(true, "Show Seasonal Month Guide Lines")

// Color palette
colMain      = input.color(color.rgb(255, 215, 0), "Color 10Y Main Curve")
col5Y        = input.color(color.rgb(230, 126, 34), "Color 5Y Curve")
col15Y       = input.color(color.rgb(46, 204, 113), "Color 15Y Curve")
col20Y       = input.color(color.rgb(109, 76, 65), "Color 20Y Curve")
colCurrent   = input.color(color.rgb(44, 62, 80), "Color Current Year")
colPrevious  = input.color(color.rgb(52, 152, 219), "Color Previous Year")
colBase      = input.color(color.gray, "Color Base Line")
colMonth     = input.color(color.new(color.gray, 10), "Color Seasonal Month Scale")
colMonthLine = input.color(color.new(color.gray, 82), "Color Seasonal Month Guide Lines")

// ─────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────
const int DAYS = 366
const int ARR_SIZE = 367
const int MAX_YEARS = 50
const int MAIN_LOOKBACK = 10
const int SEGMENTS_PER_CURVE = 55

int refYear = year(timenow)

// ─────────────────────────────────────────────
// DAILY DATA
// ─────────────────────────────────────────────
dClose = request.security(syminfo.tickerid, "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dTime  = request.security(syminfo.tickerid, "D", time,  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bool hasDailyData = not na(dClose) and not na(dTime)
bool isNewDailyData = hasDailyData and (barstate.isfirst or dTime != dTime[1])

// ─────────────────────────────────────────────
// DATE HELPERS
// ─────────────────────────────────────────────
isLeapYear(int y) =>
    (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)

daysInMonth(int y, int m) =>
    int dim = 31
    if m == 2
        dim := isLeapYear(y) ? 29 : 28
    else if m == 4 or m == 6 or m == 9 or m == 11
        dim := 30
    else
        dim := 31
    dim

dayOfYearFromYMD(int y, int m, int d) =>
    int dd = math.min(d, daysInMonth(y, m))
    int sum = 0
    for mm = 1 to 12
        if mm < m
            sum += daysInMonth(y, mm)
    sum + dd

dayOfYearFromTime(int t) =>
    dayOfYearFromYMD(year(t), month(t), dayofmonth(t))

safeYearText(int y) =>
    na(y) ? "n/a" : str.tostring(y)

monthName(int m) =>
    string n = "Jan"
    if m == 2
        n := "Feb"
    else if m == 3
        n := "Mar"
    else if m == 4
        n := "Apr"
    else if m == 5
        n := "May"
    else if m == 6
        n := "Jun"
    else if m == 7
        n := "Jul"
    else if m == 8
        n := "Aug"
    else if m == 9
        n := "Sep"
    else if m == 10
        n := "Oct"
    else if m == 11
        n := "Nov"
    else if m == 12
        n := "Dec"
    n

// ─────────────────────────────────────────────
// ARRAY HELPERS
// ─────────────────────────────────────────────
newFloatArr(float init) => array.new_float(ARR_SIZE, init)
newIntArr(int init) => array.new_int(ARR_SIZE, init)
newBoolYearArr() => array.new_bool(MAX_YEARS, false)
newFloatYearArr() => array.new_float(MAX_YEARS, na)

clearFloatArr(float[] arr, float val) =>
    for i = 0 to ARR_SIZE - 1
        array.set(arr, i, val)
    0

clearIntArr(int[] arr, int val) =>
    for i = 0 to ARR_SIZE - 1
        array.set(arr, i, val)
    0

clearBoolYearArr(bool[] arr) =>
    for i = 0 to MAX_YEARS - 1
        array.set(arr, i, false)
    0

clearFloatYearArr(float[] arr) =>
    for i = 0 to MAX_YEARS - 1
        array.set(arr, i, na)
    0

outVal(float v) =>
    plotAsPct ? (v / baseValue - 1.0) * 100.0 : v

// ─────────────────────────────────────────────
// STORAGE ARRAYS
// ─────────────────────────────────────────────
var float[] prodMain = newFloatArr(1.0)
var int[]   cntMain  = newIntArr(0)
var float[] avgMain  = newFloatArr(na)
var float[] baseMain = newFloatYearArr()
var bool[]  seenMain = newBoolYearArr()

var float[] prod5Y = newFloatArr(1.0)
var int[]   cnt5Y  = newIntArr(0)
var float[] avg5Y  = newFloatArr(na)
var float[] base5Y = newFloatYearArr()
var bool[]  seen5Y = newBoolYearArr()

var float[] prod15Y = newFloatArr(1.0)
var int[]   cnt15Y  = newIntArr(0)
var float[] avg15Y  = newFloatArr(na)
var float[] base15Y = newFloatYearArr()
var bool[]  seen15Y = newBoolYearArr()

var float[] prod20Y = newFloatArr(1.0)
var int[]   cnt20Y  = newIntArr(0)
var float[] avg20Y  = newFloatArr(na)
var float[] base20Y = newFloatYearArr()
var bool[]  seen20Y = newBoolYearArr()

var float[] pathCurrent  = newFloatArr(na)
var float[] pathPrevious = newFloatArr(na)

var line[]  linesArr  = array.new_line()
var label[] labelsArr = array.new_label()

// Info values
var int infoMainYears = 0
var int infoFirstYear = na
var int infoLastYear = na

// Current / previous year base and last available day
var float currentBase = na
var float previousBase = na
var int currentLastDoy = na
var int previousLastDoy = na

// ─────────────────────────────────────────────
// RESET ON FIRST BAR
// ─────────────────────────────────────────────
if barstate.isfirst
    clearFloatArr(prodMain, 1.0)
    clearIntArr(cntMain, 0)
    clearFloatArr(avgMain, na)
    clearFloatYearArr(baseMain)
    clearBoolYearArr(seenMain)

    clearFloatArr(prod5Y, 1.0)
    clearIntArr(cnt5Y, 0)
    clearFloatArr(avg5Y, na)
    clearFloatYearArr(base5Y)
    clearBoolYearArr(seen5Y)

    clearFloatArr(prod15Y, 1.0)
    clearIntArr(cnt15Y, 0)
    clearFloatArr(avg15Y, na)
    clearFloatYearArr(base15Y)
    clearBoolYearArr(seen15Y)

    clearFloatArr(prod20Y, 1.0)
    clearIntArr(cnt20Y, 0)
    clearFloatArr(avg20Y, na)
    clearFloatYearArr(base20Y)
    clearBoolYearArr(seen20Y)

    clearFloatArr(pathCurrent, na)
    clearFloatArr(pathPrevious, na)

    currentBase := na
    previousBase := na
    currentLastDoy := na
    previousLastDoy := na

// ─────────────────────────────────────────────
// PROCESS DAILY DATA
// ─────────────────────────────────────────────
processLookback(int lookback, float[] prodArr, int[] cntArr, float[] baseArr, bool[] seenArr) =>
    int y = year(dTime)
    int startYear = refYear - lookback
    int endYear = refYear - 1

    if y >= startYear and y <= endYear and dClose > 0
        int idx = y - startYear

        if idx >= 0 and idx < MAX_YEARS
            float b = array.get(baseArr, idx)

            if na(b)
                b := dClose
                array.set(baseArr, idx, b)
                array.set(seenArr, idx, true)

            int doy = dayOfYearFromTime(dTime)

            if doy >= 1 and doy <= DAYS and b > 0
                float factor = dClose / b

                if factor > 0
                    array.set(prodArr, doy, array.get(prodArr, doy) * factor)
                    array.set(cntArr, doy, array.get(cntArr, doy) + 1)
    0

// ─────────────────────────────────────────────
// BAR-BY-BAR DATA COLLECTION
// Daily data is collected once per new daily bar.
// ─────────────────────────────────────────────
if isNewDailyData
    processLookback(MAIN_LOOKBACK, prodMain, cntMain, baseMain, seenMain)
    processLookback(5, prod5Y, cnt5Y, base5Y, seen5Y)
    processLookback(15, prod15Y, cnt15Y, base15Y, seen15Y)
    processLookback(20, prod20Y, cnt20Y, base20Y, seen20Y)

    int barYear = year(dTime)
    int barDoy = dayOfYearFromTime(dTime)

    if dClose > 0 and barDoy >= 1 and barDoy <= DAYS
        if barYear == refYear
            if na(currentBase)
                currentBase := dClose

            if not na(currentBase) and currentBase > 0
                array.set(pathCurrent, barDoy, baseValue * dClose / currentBase)
                currentLastDoy := barDoy

        if barYear == refYear - 1
            if na(previousBase)
                previousBase := dClose

            if not na(previousBase) and previousBase > 0
                array.set(pathPrevious, barDoy, baseValue * dClose / previousBase)
                previousLastDoy := barDoy

// ─────────────────────────────────────────────
// FINALIZE ARRAYS
// ─────────────────────────────────────────────
finalizeCurve(float[] prodArr, int[] cntArr, float[] avgArr) =>
    float lastAvg = na

    for d = 1 to DAYS
        int n = array.get(cntArr, d)

        if n > 0
            float geoFactor = math.pow(array.get(prodArr, d), 1.0 / n)
            float avgIndexed = baseValue * geoFactor
            array.set(avgArr, d, avgIndexed)
            lastAvg := avgIndexed
        else
            if not na(lastAvg)
                array.set(avgArr, d, lastAvg)
    0

fillPathUntil(float[] arr, int maxDay) =>
    float lastVal = na

    int limit = na(maxDay) ? 0 : math.min(maxDay, DAYS)

    if limit > 0
        for d = 1 to limit
            float v = array.get(arr, d)

            if not na(v)
                lastVal := v
            else
                if not na(lastVal)
                    array.set(arr, d, lastVal)
    0

countYears(bool[] seenArr, int lookback) =>
    int c = 0
    int firstY = na
    int lastY = na

    int startYear = refYear - lookback

    for i = 0 to lookback - 1
        if i < MAX_YEARS and array.get(seenArr, i)
            int y = startYear + i
            c += 1
            firstY := na(firstY) ? y : math.min(firstY, y)
            lastY  := na(lastY) ? y : math.max(lastY, y)

    [c, firstY, lastY]

// ─────────────────────────────────────────────
// DRAW HELPERS
// ─────────────────────────────────────────────
clearLinesAndLabels() =>
    int n = array.size(linesArr)

    if n > 0
        int i = n - 1
        while i >= 0
            line.delete(array.get(linesArr, i))
            i -= 1

        array.clear(linesArr)

    int ln = array.size(labelsArr)

    if ln > 0
        int j = ln - 1
        while j >= 0
            label.delete(array.get(labelsArr, j))
            j -= 1

        array.clear(labelsArr)

    0

xPos(int d) =>
    int left = bar_index - (displayBars - 1)
    left + int(math.round((d - 1) * (displayBars - 1) / 365.0))

xPosFloat(float d) =>
    int left = bar_index - (displayBars - 1)
    left + int(math.round((d - 1.0) * (displayBars - 1) / 365.0))

drawCurve(float[] arr, color col, int width, style) =>
    for seg = 0 to SEGMENTS_PER_CURVE - 1
        float day0 = 1.0 + (seg * 365.0) / SEGMENTS_PER_CURVE
        float day1 = 1.0 + ((seg + 1) * 365.0) / SEGMENTS_PER_CURVE

        int d0 = math.max(1, math.min(int(math.floor(day0)), DAYS))
        int d1 = math.max(1, math.min(int(math.floor(day1)), DAYS))

        float y0raw = array.get(arr, d0)
        float y1raw = array.get(arr, d1)

        if not na(y0raw) and not na(y1raw)
            line ln = line.new(xPosFloat(day0), outVal(y0raw), xPosFloat(day1), outVal(y1raw), extend=extend.none, color=col, width=width, style=style)
            array.push(linesArr, ln)
    0

drawSeasonalMonthScale() =>
    float yLabel = plotAsPct ? -2.0 : baseValue * 0.955
    float yLineTop = plotAsPct ? 25.0 : baseValue * 1.25
    float yLineBottom = plotAsPct ? -20.0 : baseValue * 0.80

    for m = 1 to 12
        int doy = dayOfYearFromYMD(refYear, m, 1)
        int x = xPos(doy)

        if showMonthGuides
            line ln = line.new(
                 x,
                 yLineBottom,
                 x,
                 yLineTop,
                 extend=extend.none,
                 color=colMonthLine,
                 width=1,
                 style=line.style_dotted)

            array.push(linesArr, ln)

        if showMonthLabels
            label lb = label.new(
                 x,
                 yLabel,
                 monthName(m),
                 style=label.style_none,
                 textcolor=colMonth,
                 color=color.new(color.white, 100),
                 size=size.tiny)

            array.push(labelsArr, lb)
    0

// ─────────────────────────────────────────────
// TABLE
// ─────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 10, border_width=1)

legendCell(int row, string name, color col) =>
    table.cell(infoTable, 0, row, "■", text_color=col)
    table.cell(infoTable, 1, row, name)

drawTable() =>
    if showLegend
        table.cell(infoTable, 0, 0, "Seasonality", text_color=color.white, bgcolor=color.rgb(44, 62, 80))
        table.cell(infoTable, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=color.rgb(44, 62, 80))

        table.cell(infoTable, 0, 1, "Method")
        table.cell(infoTable, 1, 1, "Indexed Geometric Path")

        table.cell(infoTable, 0, 2, "Main History")
        table.cell(infoTable, 1, 2, str.tostring(infoMainYears) + "Y, " + safeYearText(infoFirstYear) + "–" + safeYearText(infoLastYear))

        table.cell(infoTable, 0, 3, "Legend", text_color=color.white, bgcolor=color.rgb(44, 62, 80))
        table.cell(infoTable, 1, 3, "Lines", text_color=color.white, bgcolor=color.rgb(44, 62, 80))

        legendCell(4, "10Y Main", colMain)
        legendCell(5, "5Y", col5Y)
        legendCell(6, "15Y", col15Y)
        legendCell(7, "20Y", col20Y)
        legendCell(8, "Current Year", colCurrent)
        legendCell(9, "Previous Year", colPrevious)
    0

// ─────────────────────────────────────────────
// MAIN LAST BAR
// ─────────────────────────────────────────────
if barstate.islast
    finalizeCurve(prodMain, cntMain, avgMain)
    finalizeCurve(prod5Y, cnt5Y, avg5Y)
    finalizeCurve(prod15Y, cnt15Y, avg15Y)
    finalizeCurve(prod20Y, cnt20Y, avg20Y)

    fillPathUntil(pathPrevious, previousLastDoy)
    fillPathUntil(pathCurrent, currentLastDoy)

    [yearCountMain, firstYearMain, lastYearMain] = countYears(seenMain, MAIN_LOOKBACK)
    infoMainYears := yearCountMain
    infoFirstYear := firstYearMain
    infoLastYear := lastYearMain

    clearLinesAndLabels()

    drawSeasonalMonthScale()

    if show20Y
        drawCurve(avg20Y, col20Y, 1, line.style_dotted)

    if show15Y
        drawCurve(avg15Y, col15Y, 1, line.style_dashed)

    if show5Y
        drawCurve(avg5Y, col5Y, 1, line.style_solid)

    if showMain
        drawCurve(avgMain, colMain, 3, line.style_solid)

    if showPrevious
        drawCurve(pathPrevious, colPrevious, 2, line.style_dotted)

    if showCurrent
        drawCurve(pathCurrent, colCurrent, 2, line.style_solid)

    float bl = plotAsPct ? 0.0 : baseValue
    line baseLn = line.new(xPos(1), bl, xPos(DAYS), bl, extend=extend.none, color=colBase, width=1, style=line.style_dashed)
    array.push(linesArr, baseLn)

    drawTable()
````
