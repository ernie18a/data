# Berg A.M.

- url: https://www.tradingview.com/script/1zMp5r12-Berg-A-M/
- type: indicator
- pine_id: PUB;9b379a65c7cd4549aefdcb119c624976
- version: 1.0

## Description

The Moving Average Trend System is a clean, powerful, and easy-to-use technical analysis indicator designed to help traders identify market direction, trend strength, potential entry zones, and possible reversal areas using a structured moving average methodology.

This indicator is built around one of the most widely used concepts in technical analysis: moving averages. By smoothing price action and filtering out short-term market noise, moving averages allow traders to focus on the broader market structure and make more objective trading decisions.

The purpose of this tool is to provide a clearer visual representation of trend behavior across different market conditions. Whether the market is trending upward, trending downward, consolidating, or preparing for a possible breakout, this indicator helps traders interpret price movement with greater confidence.

## Source Code

````pine
//@version=6
indicator("Berg M", shorttitle="Berg M", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// ==============================================================================
// Combined indicator based on:
// - Index Line With Top/Bottom Margins © jwatt123, MPL 2.0
// - Market Smith Indicators © adaml735, MPL 2.0
// - Swing Trade Info Panel
// EPS intentionally kept separate because it needs its own Scale B.
// ==============================================================================

grpGeneral = "General Display"
grpIndex   = "Index Line"
grpMA      = "Market Smith Moving Averages"
grpPivots  = "Pivot Labels"
grpRS      = "RS Line / RS Rating"
grpPanel   = "Swing Trade Info Panel"

showIndexLine = input.bool(true, "Show Index Line", group=grpGeneral)
showMSMAs     = input.bool(true, "Show Market Smith Moving Averages", group=grpGeneral)
showPivots    = input.bool(true, "Show Pivot Labels", group=grpGeneral)
showRSLine    = input.bool(true, "Show RS Line", group=grpGeneral)
showRSRating  = input.bool(true, "Show RS Rating Label", group=grpGeneral)

// ==============================================================================
// Helpers
// ==============================================================================
f_clear_lines(_arr) =>
    if array.size(_arr) > 0
        for _i = 0 to array.size(_arr) - 1
            line.delete(array.get(_arr, _i))
        array.clear(_arr)

f_clear_labels(_arr) =>
    if array.size(_arr) > 0
        for _i = 0 to array.size(_arr) - 1
            label.delete(array.get(_arr, _i))
        array.clear(_arr)

f_clamp(_value, _min, _max) =>
    na(_value) ? na : math.max(_min, math.min(_max, _value))

f_line_style(_style) =>
    _style == "Solid" ? line.style_solid : _style == "Dotted" ? line.style_dotted : line.style_dashed

// ==============================================================================
// Visible chart range for Index Line
// ==============================================================================
leftVisibleTime  = chart.left_visible_bar_time
rightVisibleTime = chart.right_visible_bar_time
inVisibleWindow  = time_close >= leftVisibleTime and time <= rightVisibleTime

var int visLeftIndex = na
var float visChartHigh = na
var float visChartLow = na

if inVisibleWindow
    if na(visLeftIndex)
        visLeftIndex := bar_index
    visChartHigh := na(visChartHigh) ? high : math.max(visChartHigh, high)
    visChartLow  := na(visChartLow)  ? low  : math.min(visChartLow, low)

visibleRangeBarsRaw = not na(visLeftIndex) ? math.max(1, bar_index - visLeftIndex) : math.min(bar_index, 300)
visibleRangeBars = math.min(visibleRangeBarsRaw, 4999)

// ==============================================================================
// INDEX LINE
// ==============================================================================
idxSymbol       = input.symbol("SP:SPX", "Index Symbol", group=grpIndex)
idxTopMargin    = input.int(0, "Top Margin (%)", minval=0, maxval=100, group=grpIndex) / 100.0
idxBottomMargin = input.int(66, "Bottom Margin (%)", minval=0, maxval=100, group=grpIndex) / 100.0
idxLineWidth    = input.int(1, "Line Width", minval=1, maxval=5, group=grpIndex)
idxLineColor    = input.color(#888888, "Line Color", group=grpIndex)
idxMaxSegments  = input.int(320, "Max Drawn Segments", minval=80, maxval=330, group=grpIndex)

idxClose = request.security(idxSymbol, timeframe.period, close, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)

var line[] idxLines = array.new_line()

if barstate.islast
    f_clear_lines(idxLines)

    if showIndexLine and not na(visLeftIndex)
        float idxVisHigh = na
        float idxVisLow = na
        float idxChartHigh = na
        float idxChartLow = na

        for i = 0 to visibleRangeBars
            if not na(idxClose[i])
                idxVisHigh := na(idxVisHigh) ? idxClose[i] : math.max(idxVisHigh, idxClose[i])
                idxVisLow  := na(idxVisLow)  ? idxClose[i] : math.min(idxVisLow, idxClose[i])
                idxChartHigh := na(idxChartHigh) ? high[i] : math.max(idxChartHigh, high[i])
                idxChartLow  := na(idxChartLow)  ? low[i]  : math.min(idxChartLow, low[i])

        float idxRange = idxVisHigh - idxVisLow
        float idxChartRange = idxChartHigh - idxChartLow
        float idxFracRemaining = 1.0 - idxTopMargin - idxBottomMargin

        if not na(idxRange) and not na(idxChartRange) and idxChartRange != 0 and idxFracRemaining > 0
            int idxStep = math.max(1, int(math.ceil(visibleRangeBars / idxMaxSegments)))
            float idxPrevY = na
            int idxPrevX = na

            for offsetStep = 0 to visibleRangeBars by idxStep
                int histOffset = visibleRangeBars - offsetStep
                float idxValue = idxClose[histOffset]

                if not na(idxValue)
                    float idxFrac = idxRange == 0 ? 0.5 : (idxValue - idxVisLow) / idxRange
                    float idxFracChart = idxBottomMargin + idxFrac * idxFracRemaining
                    int idxX = bar_index - histOffset
                    float idxY = idxChartLow + idxFracChart * idxChartRange

                    if not na(idxPrevY)
                        line idxNewLine = line.new(idxPrevX, idxPrevY, idxX, idxY, color=idxLineColor, width=idxLineWidth)
                        array.push(idxLines, idxNewLine)

                    idxPrevY := idxY
                    idxPrevX := idxX

// ==============================================================================
// MARKET SMITH MOVING AVERAGES
// ==============================================================================
isDaily = timeframe.isdaily

ma8Color    = input.color(color.yellow, "8 Day MA Color", group=grpMA)
ma21Color   = input.color(color.new(color.fuchsia, 0), "21 Day MA Color", group=grpMA)
ma50Color   = input.color(color.new(color.orange, 0), "50 Day MA Color", group=grpMA)
ma200Color  = input.color(color.new(color.green, 0), "200 Day MA Color", group=grpMA)
maLineWidth = input.int(1, "MA Line Width", minval=1, maxval=5, group=grpMA)

ma8   = ta.sma(close, 8)
ma21  = ta.sma(close, 21)
ma50  = ta.sma(close, 50)
ma200 = ta.sma(close, 200)

plot(showMSMAs ? ma8 : na, title="8 Day MA", color=ma8Color, linewidth=maLineWidth, display=display.all - display.status_line)
plot(showMSMAs ? ma21 : na, title="21 Day MA", color=ma21Color, linewidth=maLineWidth, display=display.all - display.status_line)
plot(showMSMAs ? ma50 : na, title="50 Day MA", color=ma50Color, linewidth=maLineWidth, display=display.all - display.status_line)
plot(showMSMAs ? ma200 : na, title="200 Day MA", color=ma200Color, linewidth=maLineWidth, display=display.all - display.status_line)

// ==============================================================================
// PIVOT LABELS + LAST PIVOT LINES
// ==============================================================================
pivotLeftHigh      = input.int(10, "High Pivot Left Bars", minval=1, maxval=50, group=grpPivots)
pivotRightHigh     = input.int(10, "High Pivot Right Bars", minval=1, maxval=50, group=grpPivots)
pivotLeftLow       = input.int(10, "Low Pivot Left Bars", minval=1, maxval=50, group=grpPivots)
pivotRightLow      = input.int(10, "Low Pivot Right Bars", minval=1, maxval=50, group=grpPivots)

pivotPriceTextColor = input.color(color.rgb(70, 130, 255), "Pivot Price Text Color", group=grpPivots)
pivotPctUpColor     = input.color(color.rgb(103, 255, 154), "Pivot % Up Text Color", group=grpPivots)
pivotPctDownColor   = input.color(color.rgb(255, 153, 153), "Pivot % Down Text Color", group=grpPivots)

pivotShowPct       = input.bool(true, "Show Pivot % Move", group=grpPivots)
pivotPctDecimals   = input.int(1, "Pivot % Decimals", minval=0, maxval=3, group=grpPivots)
pivotPctMode       = input.string("Previous Opposite Pivot", "Pivot % Calculation", options=["Previous Opposite Pivot", "Previous Same Pivot"], group=grpPivots)

showLastPivotLines = input.bool(true, "Show Last Pivot Lines", group=grpPivots)
pivotLineMode      = input.string("Both", "Last Pivot Line Mode", options=["Both", "Resistance Only", "Support Only", "None"], group=grpPivots)
pivotResLineColor  = input.color(color.new(color.rgb(120, 170, 255), 0), "Resistance Line Color", group=grpPivots)
pivotSupLineColor  = input.color(color.new(color.rgb(120, 170, 255), 0), "Support Line Color", group=grpPivots)
pivotLineStyleIn   = input.string("Dashed", "Last Pivot Line Style", options=["Solid", "Dashed", "Dotted"], group=grpPivots)
pivotLineWidth     = input.int(1, "Last Pivot Line Width", minval=1, maxval=5, group=grpPivots)

pivotMaxLabels     = input.int(120, "Max Pivot Labels", minval=20, maxval=240, group=grpPivots)

pivotHigh = ta.pivothigh(pivotLeftHigh, pivotRightHigh)
pivotLow  = ta.pivotlow(pivotLeftLow, pivotRightLow)

var label[] pivotLabels = array.new_label()

var float lastPivotHigh = na
var float lastPivotLow  = na
var int   lastPivotHighBar = na
var int   lastPivotLowBar  = na

var line lastResistanceLine = na
var line lastSupportLine    = na

formatPivotPct(float pct) =>
    string result = ""
    if not na(pct)
        string fmt = pivotPctDecimals == 0 ? "#0" : pivotPctDecimals == 1 ? "#0.0" : pivotPctDecimals == 2 ? "#0.00" : "#0.000"
        result := (pct >= 0 ? "+" : "") + str.tostring(pct, fmt) + "%"
    result

pivotPctTextColor(float pct) =>
    na(pct) ? pivotPriceTextColor : pct >= 0 ? pivotPctUpColor : pivotPctDownColor

if not na(pivotHigh)
    float pivotHighPct = na

    if pivotPctMode == "Previous Opposite Pivot"
        pivotHighPct := not na(lastPivotLow) and lastPivotLow != 0 ? ((pivotHigh - lastPivotLow) / lastPivotLow) * 100 : na
    else
        pivotHighPct := not na(lastPivotHigh) and lastPivotHigh != 0 ? ((pivotHigh - lastPivotHigh) / lastPivotHigh) * 100 : na

    if showPivots
        label phPriceLbl = label.new(
             bar_index[pivotRightHigh],
             pivotHigh,
             str.tostring(pivotHigh, format.mintick) + "\n",
             style=label.style_label_down,
             color=color.rgb(0, 0, 0, 100),
             textcolor=pivotPriceTextColor,
             textalign=text.align_center,
             yloc=yloc.price
        )
        array.push(pivotLabels, phPriceLbl)

        if pivotShowPct and not na(pivotHighPct)
            label phPctLbl = label.new(
                 bar_index[pivotRightHigh],
                 pivotHigh,
                 "\n" + formatPivotPct(pivotHighPct),
                 style=label.style_label_down,
                 color=color.rgb(0, 0, 0, 100),
                 textcolor=pivotPctTextColor(pivotHighPct),
                 textalign=text.align_center,
                 yloc=yloc.price
            )
            array.push(pivotLabels, phPctLbl)

    lastPivotHigh := pivotHigh
    lastPivotHighBar := bar_index[pivotRightHigh]

if not na(pivotLow)
    float pivotLowPct = na

    if pivotPctMode == "Previous Opposite Pivot"
        pivotLowPct := not na(lastPivotHigh) and lastPivotHigh != 0 ? ((pivotLow - lastPivotHigh) / lastPivotHigh) * 100 : na
    else
        pivotLowPct := not na(lastPivotLow) and lastPivotLow != 0 ? ((pivotLow - lastPivotLow) / lastPivotLow) * 100 : na

    if showPivots
        label plPriceLbl = label.new(
             bar_index[pivotRightLow],
             pivotLow,
             str.tostring(pivotLow, format.mintick) + "\n",
             style=label.style_label_up,
             color=color.rgb(0, 0, 0, 100),
             textcolor=pivotPriceTextColor,
             textalign=text.align_center,
             yloc=yloc.price
        )
        array.push(pivotLabels, plPriceLbl)

        if pivotShowPct and not na(pivotLowPct)
            label plPctLbl = label.new(
                 bar_index[pivotRightLow],
                 pivotLow,
                 "\n" + formatPivotPct(pivotLowPct),
                 style=label.style_label_up,
                 color=color.rgb(0, 0, 0, 100),
                 textcolor=pivotPctTextColor(pivotLowPct),
                 textalign=text.align_center,
                 yloc=yloc.price
            )
            array.push(pivotLabels, plPctLbl)

    lastPivotLow := pivotLow
    lastPivotLowBar := bar_index[pivotRightLow]

int pivotMaxStoredLabels = pivotShowPct ? pivotMaxLabels * 2 : pivotMaxLabels

while array.size(pivotLabels) > pivotMaxStoredLabels
    label oldPivot = array.shift(pivotLabels)
    label.delete(oldPivot)

if not showPivots and array.size(pivotLabels) > 0
    f_clear_labels(pivotLabels)

if barstate.islast
    if not na(lastResistanceLine)
        line.delete(lastResistanceLine)
        lastResistanceLine := na

    if not na(lastSupportLine)
        line.delete(lastSupportLine)
        lastSupportLine := na

    lineStyle = f_line_style(pivotLineStyleIn)

    bool showRes = showLastPivotLines and (pivotLineMode == "Both" or pivotLineMode == "Resistance Only")
    bool showSup = showLastPivotLines and (pivotLineMode == "Both" or pivotLineMode == "Support Only")

    if showRes and not na(lastPivotHigh) and not na(lastPivotHighBar)
        lastResistanceLine := line.new(
             lastPivotHighBar,
             lastPivotHigh,
             bar_index + 1,
             lastPivotHigh,
             extend=extend.right,
             color=pivotResLineColor,
             width=pivotLineWidth,
             style=lineStyle
        )

    if showSup and not na(lastPivotLow) and not na(lastPivotLowBar)
        lastSupportLine := line.new(
             lastPivotLowBar,
             lastPivotLow,
             bar_index + 1,
             lastPivotLow,
             extend=extend.right,
             color=pivotSupLineColor,
             width=pivotLineWidth,
             style=lineStyle
        )

// ==============================================================================
// RS LINE + RS RATING
// ==============================================================================
hideRSRat = not showRSRating
src = close

comparativeTickerId = input.symbol("SP:SPX", "Comparative Symbol", group=grpRS)
SpxValue = input.float(3900.0, "Value of Comparative Symbol", group=grpRS)
colorRS = input.color(color.rgb(120, 150, 255, 0), "RS Line Color", group=grpRS)
offset = input.int(80, "RS Offset", group=grpRS)

plotNewHigh = input.bool(false, "Show RS New High Dots", group=grpRS)
rsNewHigh = input.string("RS New Highs", "RS New High Mode", options=["Historical RS New Highs", "Historical RS New Highs Before Price", "RS New Highs", "RS New Highs Before Price"], group=grpRS)
blueDotCol = input.color(color.rgb(38, 198, 218, 60), "RS High Dot Color", group=grpRS)
lookback = input.int(40, "RS High Lookback", minval=2, group=grpRS)

plotNewLow = input.bool(false, "Show RS New Low Dots", group=grpRS)
rsNewLow = input.string("RS New Lows", "RS New Low Mode", options=["Historical RS New Lows", "Historical RS New Lows Before Price", "RS New Lows", "RS New Lows Before Price"], group=grpRS)
redDotCol = input.color(color.rgb(255, 82, 82, 60), "RS Low Dot Color", group=grpRS)
lookback2 = input.int(40, "RS Low Lookback", minval=2, group=grpRS)

W1Ma = 40.0
W2Ma = 20.0
W3Ma = 20.0
W4Ma = 20.0
W1P = 40.0
W2P = 20.0
W3P = 20.0
W4P = 20.0
spxW1Ma = 40.0
spxW2Ma = 20.0
spxW3Ma = 20.0
spxW4Ma = 20.0
w1 = 2.0
w2 = 1.0
w3 = 1.0

n63  = bar_index < 63  ? bar_index : 63
n126 = bar_index < 126 ? bar_index : 126
n189 = bar_index < 189 ? bar_index : 189
n252 = bar_index < 252 ? bar_index : 252

comparativeSymbol = request.security(comparativeTickerId, timeframe.period, close, ignore_invalid_symbol=true)
rsCurve = src / comparativeSymbol
rsRatio = timeframe.isweekly ? SpxValue * (offset - 10) / 100 : SpxValue * offset / 100
rs = rsCurve * rsRatio

rsPlot = plot(showRSLine ? rs : na, title="RS Line", style=plot.style_line, linewidth=1, color=colorRS)

prevlookback = lookback
prevlookback2 = lookback2

histNH = ta.highest(rs, prevlookback)
histCl = ta.highest(high, prevlookback)

if showRSLine and rsNewHigh == "Historical RS New Highs" and plotNewHigh and rs == histNH
    label.new(x=bar_index, y=rs, color=blueDotCol, style=label.style_circle, size=size.tiny)

if showRSLine and rsNewHigh == "Historical RS New Highs Before Price" and plotNewHigh and rs == histNH and high < histCl
    label.new(x=bar_index, y=rs, color=blueDotCol, style=label.style_circle, size=size.tiny)

if showRSLine and barstate.islast and rsNewHigh == "RS New Highs" and plotNewHigh and rs == histNH
    label.new(x=bar_index, y=rs, color=blueDotCol, style=label.style_circle, size=size.tiny)

if showRSLine and barstate.islast and rsNewHigh == "RS New Highs Before Price" and plotNewHigh and rs == histNH and high < histCl
    label.new(x=bar_index, y=rs, color=blueDotCol, style=label.style_circle, size=size.tiny)

histNL = ta.lowest(rs, prevlookback2)
histClL = ta.lowest(low, prevlookback2)

if showRSLine and rsNewLow == "Historical RS New Lows" and plotNewLow and rs == histNL
    label.new(x=bar_index, y=rs, color=redDotCol, style=label.style_circle, size=size.tiny)

if showRSLine and rsNewLow == "Historical RS New Lows Before Price" and plotNewLow and rs == histNL and low > histClL
    label.new(x=bar_index, y=rs, color=redDotCol, style=label.style_circle, size=size.tiny)

if showRSLine and barstate.islast and rsNewLow == "RS New Lows" and plotNewLow and rs == histNL
    label.new(x=bar_index, y=rs, color=redDotCol, style=label.style_circle, size=size.tiny)

if showRSLine and barstate.islast and rsNewLow == "RS New Lows Before Price" and plotNewLow and rs == histNL and low > histClL
    label.new(x=bar_index, y=rs, color=redDotCol, style=label.style_circle, size=size.tiny)

// ==============================================================================
// RS RATING CALCULATION
// ==============================================================================
limitDown = 25.0
limitUp = 75.0

rawAbove200 = request.security("MMTH", "D", close, ignore_invalid_symbol=true)
rawAbove150 = request.security("MMOF", "D", close, ignore_invalid_symbol=true)
rawAbove100 = request.security("MMOH", "D", close, ignore_invalid_symbol=true)
rawAbove50  = request.security("MMFI", "D", close, ignore_invalid_symbol=true)
rawAbove20  = request.security("MMTW", "D", close, ignore_invalid_symbol=true)

perStockAbove200 = f_clamp(rawAbove200, limitDown, limitUp)
perStockAbove150 = f_clamp(rawAbove150, limitDown, limitUp)
perStockAbove100 = f_clamp(rawAbove100, limitDown, limitUp)
perStockAbove50  = f_clamp(rawAbove50, limitDown, limitUp)
perStockAbove20  = f_clamp(rawAbove20, limitDown, limitUp)

closeDa = request.security(syminfo.tickerid, "D", close, ignore_invalid_symbol=true)
sma200 = request.security(syminfo.tickerid, "D", ta.sma(close, 200), ignore_invalid_symbol=true)
sma150 = request.security(syminfo.tickerid, "D", ta.sma(close, 150), ignore_invalid_symbol=true)
sma100 = request.security(syminfo.tickerid, "D", ta.sma(close, 100), ignore_invalid_symbol=true)
sma50  = request.security(syminfo.tickerid, "D", ta.sma(close, 50), ignore_invalid_symbol=true)
sma20  = request.security(syminfo.tickerid, "D", ta.sma(close, 20), ignore_invalid_symbol=true)
spxCloseDa = request.security(comparativeTickerId, "D", close, ignore_invalid_symbol=true)

bCloseAbove200 = closeDa > sma200 ? 1.0 : 0.0
bCloseAbove150 = closeDa > sma150 ? 1.0 : 0.0
bCloseAbove100 = closeDa > sma100 ? 1.0 : 0.0
bCloseAbove50  = closeDa > sma50  ? 1.0 : 0.0
bCloseAbove20  = closeDa > sma20  ? 1.0 : 0.0

bClose63Above200 = closeDa[n63] > sma200[n63] ? 1.0 : 0.0
bClose63Above150 = closeDa[n63] > sma150[n63] ? 1.0 : 0.0
bClose63Above100 = closeDa[n63] > sma100[n63] ? 1.0 : 0.0
bClose63Above50  = closeDa[n63] > sma50[n63]  ? 1.0 : 0.0
bClose63Above20  = closeDa[n63] > sma20[n63]  ? 1.0 : 0.0

bClose126Above200 = closeDa[n126] > sma200[n126] ? 1.0 : 0.0
bClose126Above150 = closeDa[n126] > sma150[n126] ? 1.0 : 0.0
bClose126Above100 = closeDa[n126] > sma100[n126] ? 1.0 : 0.0
bClose126Above50  = closeDa[n126] > sma50[n126]  ? 1.0 : 0.0
bClose126Above20  = closeDa[n126] > sma20[n126]  ? 1.0 : 0.0

bClose189Above200 = closeDa[n189] > sma200[n189] ? 1.0 : 0.0
bClose189Above150 = closeDa[n189] > sma150[n189] ? 1.0 : 0.0
bClose189Above100 = closeDa[n189] > sma100[n189] ? 1.0 : 0.0
bClose189Above50  = closeDa[n189] > sma50[n189]  ? 1.0 : 0.0
bClose189Above20  = closeDa[n189] > sma20[n189]  ? 1.0 : 0.0

bClose252Above200 = closeDa[n252] > sma200[n252] ? 1.0 : 0.0
bClose252Above150 = closeDa[n252] > sma150[n252] ? 1.0 : 0.0
bClose252Above100 = closeDa[n252] > sma100[n252] ? 1.0 : 0.0
bClose252Above50  = closeDa[n252] > sma50[n252]  ? 1.0 : 0.0
bClose252Above20  = closeDa[n252] > sma20[n252]  ? 1.0 : 0.0

zeroMonthWeight = (bCloseAbove200 == 1.0 ? 100 / perStockAbove200 : -100 / (100 - perStockAbove200)) +
     (bCloseAbove150 == 1.0 ? 100 / perStockAbove150 : -100 / (100 - perStockAbove150)) +
     (bCloseAbove100 == 1.0 ? 100 / perStockAbove100 : -100 / (100 - perStockAbove100)) +
     (bCloseAbove50 == 1.0 ? 100 / perStockAbove50 : -100 / (100 - perStockAbove50)) +
     (bCloseAbove20 == 1.0 ? 100 / perStockAbove20 : -100 / (100 - perStockAbove20))

threeMonthWeight = (bClose63Above200 == 1.0 ? 100 / perStockAbove200[n63] : -100 / (100 - perStockAbove200[n63])) +
     (bClose63Above150 == 1.0 ? 100 / perStockAbove150[n63] : -100 / (100 - perStockAbove150[n63])) +
     (bClose63Above100 == 1.0 ? 100 / perStockAbove100[n63] : -100 / (100 - perStockAbove100[n63])) +
     (bClose63Above50 == 1.0 ? 100 / perStockAbove50[n63] : -100 / (100 - perStockAbove50[n63])) +
     (bClose63Above20 == 1.0 ? 100 / perStockAbove20[n63] : -100 / (100 - perStockAbove20[n63]))

sixMonthWeight = (bClose126Above200 == 1.0 ? 100 / perStockAbove200[n126] : -100 / (100 - perStockAbove200[n126])) +
     (bClose126Above150 == 1.0 ? 100 / perStockAbove150[n126] : -100 / (100 - perStockAbove150[n126])) +
     (bClose126Above100 == 1.0 ? 100 / perStockAbove100[n126] : -100 / (100 - perStockAbove100[n126])) +
     (bClose126Above50 == 1.0 ? 100 / perStockAbove50[n126] : -100 / (100 - perStockAbove50[n126])) +
     (bClose126Above20 == 1.0 ? 100 / perStockAbove20[n126] : -100 / (100 - perStockAbove20[n126]))

nineMonthWeight = (bClose189Above200 == 1.0 ? 100 / perStockAbove200[n189] : -100 / (100 - perStockAbove200[n189])) +
     (bClose189Above150 == 1.0 ? 100 / perStockAbove150[n189] : -100 / (100 - perStockAbove150[n189])) +
     (bClose189Above100 == 1.0 ? 100 / perStockAbove100[n189] : -100 / (100 - perStockAbove100[n189])) +
     (bClose189Above50 == 1.0 ? 100 / perStockAbove50[n189] : -100 / (100 - perStockAbove50[n189])) +
     (bClose189Above20 == 1.0 ? 100 / perStockAbove20[n189] : -100 / (100 - perStockAbove20[n189]))

twelveMonthWeight = (bClose252Above200 == 1.0 ? 100 / perStockAbove200[n252] : -100 / (100 - perStockAbove200[n252])) +
     (bClose252Above150 == 1.0 ? 100 / perStockAbove150[n252] : -100 / (100 - perStockAbove150[n252])) +
     (bClose252Above100 == 1.0 ? 100 / perStockAbove100[n252] : -100 / (100 - perStockAbove100[n252])) +
     (bClose252Above50 == 1.0 ? 100 / perStockAbove50[n252] : -100 / (100 - perStockAbove50[n252])) +
     (bClose252Above20 == 1.0 ? 100 / perStockAbove20[n252] : -100 / (100 - perStockAbove20[n252]))

scoreWithoutBorder = W1Ma * (zeroMonthWeight + threeMonthWeight) + W2Ma * sixMonthWeight + W3Ma * nineMonthWeight + W4Ma * twelveMonthWeight
maxScore = W1Ma * (2 * 100 / limitDown) + W2Ma * (100 / limitDown) + W3Ma * (100 / limitDown) + W4Ma * (100 / limitDown)
minScore = -(W1Ma * (2 * 100 / (100 - limitUp)) + W2Ma * (100 / (100 - limitUp)) + W3Ma * (100 / (100 - limitUp)) + W4Ma * (100 / (100 - limitUp)))

adjustedScoreWithoutBorder = scoreWithoutBorder - minScore + 1
adjustedMaxScore = maxScore - minScore + 1
adjustedMinScore = minScore - minScore + 1
rsRating1 = math.round(adjustedScoreWithoutBorder * 99 / (adjustedMaxScore - adjustedMinScore))

if rsRating1 >= 50
    truncate = (rsRating1 - 50) / 2
    rsRating1 := math.round(rsRating1 + truncate)
if rsRating1 > 99
    rsRating1 := 99
if rsRating1 < 1
    rsRating1 := 1

limitPerf = 2.0

ThreeMthRS = closeDa / closeDa[n63]
if closeDa < closeDa[n63]
    ThreeMthRS := -(1 / ThreeMthRS)
ThreeMthRS := math.max(-limitPerf, math.min(limitPerf, ThreeMthRS))

SixMthRS = closeDa / closeDa[n126]
if closeDa < closeDa[n126]
    SixMthRS := -(1 / SixMthRS)
SixMthRS := math.max(-limitPerf, math.min(limitPerf, SixMthRS))

NineMthRS = closeDa / closeDa[n189]
if closeDa < closeDa[n189]
    NineMthRS := -(1 / NineMthRS)
NineMthRS := math.max(-limitPerf, math.min(limitPerf, NineMthRS))

TwelveMthRS = closeDa / closeDa[n252]
if closeDa < closeDa[n252]
    TwelveMthRS := -(1 / TwelveMthRS)
TwelveMthRS := math.max(-limitPerf, math.min(limitPerf, TwelveMthRS))

maxScore2 = limitPerf * W1P + limitPerf * W2P + limitPerf * W3P + limitPerf * W4P
minScore2 = -limitPerf * W1P - limitPerf * W2P - limitPerf * W3P - limitPerf * W4P

RSraw = W1P * ThreeMthRS + W2P * SixMthRS + W3P * NineMthRS + W4P * TwelveMthRS

adjustedPerfScoreWithoutBorder = RSraw - minScore2 + 1
adjustedPerfMaxScore = maxScore2 - minScore2 + 1
adjustedPerfMinScore = minScore2 - minScore2 + 1

rsRating2 = math.round(adjustedPerfScoreWithoutBorder * 99 / (adjustedPerfMaxScore - adjustedPerfMinScore))

if rsRating2 >= 50
    truncate2 = (rsRating2 - 50) / 2
    rsRating2 := math.round(rsRating2 + truncate2)
if rsRating2 > 99
    rsRating2 := 99
if rsRating2 < 1
    rsRating2 := 1

perfTicker63 = closeDa / closeDa[n63]
perfComp63 = spxCloseDa / spxCloseDa[n63]
perfTicker126 = closeDa / closeDa[n126]
perfComp126 = spxCloseDa / spxCloseDa[n126]
perfTicker189 = closeDa / closeDa[n189]
perfComp189 = spxCloseDa / spxCloseDa[n189]
perfTicker252 = closeDa / closeDa[n252]
perfComp252 = spxCloseDa / spxCloseDa[n252]

limiteComp = 2.0

spxThreeMthRS = perfTicker63 / perfComp63
if perfTicker63 < perfComp63
    spxThreeMthRS := -(1 / spxThreeMthRS)
spxThreeMthRS := math.max(-limiteComp, math.min(limiteComp, spxThreeMthRS))

spxSixMthRS = perfTicker126 / perfComp126
if perfTicker126 < perfComp126
    spxSixMthRS := -(1 / spxSixMthRS)
spxSixMthRS := math.max(-limiteComp, math.min(limiteComp, spxSixMthRS))

spxNineMthRS = perfTicker189 / perfComp189
if perfTicker189 < perfComp189
    spxNineMthRS := -(1 / spxNineMthRS)
spxNineMthRS := math.max(-limiteComp, math.min(limiteComp, spxNineMthRS))

spxTwelveMthRS = perfTicker252 / perfComp252
if perfTicker252 < perfComp252
    spxTwelveMthRS := -(1 / spxTwelveMthRS)
spxTwelveMthRS := math.max(-limiteComp, math.min(limiteComp, spxTwelveMthRS))

spxMaxScore2 = limiteComp * spxW1Ma + limiteComp * spxW2Ma + limiteComp * spxW3Ma + limiteComp * spxW4Ma
spxMinScore2 = -limiteComp * spxW1Ma - limiteComp * spxW2Ma - limiteComp * spxW3Ma - limiteComp * spxW4Ma

spxRSraw = spxW1Ma * spxThreeMthRS + spxW2Ma * spxSixMthRS + spxW3Ma * spxNineMthRS + spxW4Ma * spxTwelveMthRS

spxAdjustedPerfScoreWithoutBorder = spxRSraw - spxMinScore2 + 1
spxAdjustedPerfMaxScore = spxMaxScore2 - spxMinScore2 + 1
spxAdjustedPerfMinScore = spxMinScore2 - spxMinScore2 + 1

rsRating3 = math.round(spxAdjustedPerfScoreWithoutBorder * 99 / (spxAdjustedPerfMaxScore - spxAdjustedPerfMinScore))

if rsRating3 > 99
    rsRating3 := 99
if rsRating3 < 1
    rsRating3 := 1

float totalRsRating = math.round((w1 * rsRating1 + w2 * rsRating2 + w3 * rsRating3) / (w1 + w2 + w3))

if rsRating3 < 45 and rsRating3 < rsRating1 and rsRating3 < rsRating2
    totalRsRating := math.round((w2 * rsRating2 + w3 * rsRating3) / (w2 + w3))
if rsRating2 > 80 and rsRating1 < 70 and rsRating3 >= 68
    totalRsRating := rsRating2 - 1
if rsRating2 >= 59 and rsRating1 <= 30 and rsRating3 >= 50
    totalRsRating := rsRating2 - 1
if rsRating1 >= 80 and rsRating2 >= 49 and rsRating2 <= 65 and rsRating3 <= 45 and rsRating3 >= 33 and rsRating2 - rsRating3 >= 6
    totalRsRating := math.round((w1 * rsRating1 + w2 * rsRating2 + w3 * rsRating3) / (w1 + w2 + w3))
if rsRating1 <= 5
    totalRsRating := math.round((w2 * rsRating2 + w3 * rsRating3) / (w2 + w3))

var label rsLabel1 = na
var label rsLabel2 = na

if barstate.islast
    if not na(rsLabel1)
        label.delete(rsLabel1)
    if not na(rsLabel2)
        label.delete(rsLabel2)

    if showRSRating and showRSLine and isDaily
        rsLabel1 := label.new(bar_index, rs, text="RS Rating", color=color.rgb(0, 0, 0, 100), size=size.normal, textcolor=colorRS, style=label.style_label_left, textalign=text.align_left, yloc=yloc.price)
        rsLabel2 := label.new(bar_index, rs, text="\n\n" + str.tostring(totalRsRating, "#0"), color=color.rgb(0, 0, 0, 100), size=size.large, textcolor=colorRS, style=label.style_label_left, textalign=text.align_left, yloc=yloc.price)

// ==============================================================================
// SWING TRADE INFO PANEL
// ==============================================================================
panelSizeInput = input.string("Medium", "Panel Size", options=["Small", "Medium", "Large"], group=grpPanel)
panelPosInput  = input.string("Bottom Right", "Panel Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grpPanel)
adrLength      = input.int(20, "ADR Length", minval=1, group=grpPanel)
avgVolLength   = input.int(20, "Avg Volume Length", minval=1, group=grpPanel)
atrLength      = input.int(14, "ATR Length", minval=1, group=grpPanel)
showMktCap     = input.bool(true, "Show Market Cap", group=grpPanel)
showFloat      = input.bool(true, "Show Shares Float", group=grpPanel)

txtSize = panelSizeInput == "Small" ? size.small : panelSizeInput == "Large" ? size.large : size.normal

panelPos = panelPosInput == "Top Right"    ? position.top_right    :
           panelPosInput == "Top Left"     ? position.top_left     :
           panelPosInput == "Bottom Left"  ? position.bottom_left  : position.bottom_right

txtColor = color.rgb(210, 145, 60)
bgColor  = color.new(color.black, 100)

panelDailyClose  = request.security(syminfo.tickerid, "D", close,  barmerge.gaps_off, barmerge.lookahead_off)
panelDailyHigh   = request.security(syminfo.tickerid, "D", high,   barmerge.gaps_off, barmerge.lookahead_off)
panelDailyLow    = request.security(syminfo.tickerid, "D", low,    barmerge.gaps_off, barmerge.lookahead_off)
panelDailyVolume = request.security(syminfo.tickerid, "D", volume, barmerge.gaps_off, barmerge.lookahead_off)

panelDailyADR = request.security(syminfo.tickerid, "D", ta.sma(((high - low) / close) * 100, adrLength), barmerge.gaps_off, barmerge.lookahead_off)
panelAvgDollarVol = request.security(syminfo.tickerid, "D", ta.sma(volume * close, avgVolLength), barmerge.gaps_off, barmerge.lookahead_off)
panelAvgDailyVol = request.security(syminfo.tickerid, "D", ta.sma(volume, avgVolLength), barmerge.gaps_off, barmerge.lookahead_off)
panelDailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLength), barmerge.gaps_off, barmerge.lookahead_off)
panelSma21 = request.security(syminfo.tickerid, "D", ta.sma(close, 21), barmerge.gaps_off, barmerge.lookahead_off)

panelTotalShares = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol=true)
panelFloatShares = request.financial(syminfo.tickerid, "FLOAT_SHARES_OUTSTANDING", "FY", ignore_invalid_symbol=true)

formatBig(float val) =>
    string result = "NaN"
    if not na(val)
        absVal = math.abs(val)
        if absVal >= 1e12
            result := str.tostring(val / 1e12, "#.##") + "T"
        else if absVal >= 1e9
            result := str.tostring(val / 1e9, "#.##") + "B"
        else if absVal >= 1e6
            result := str.tostring(val / 1e6, "#.##") + "M"
        else if absVal >= 1e3
            result := str.tostring(val / 1e3, "#.##") + "K"
        else
            result := str.tostring(val, "#.##")
    result

formatPct(float val) =>
    na(val) ? "NaN" : str.tostring(val, "#.##") + "%"

formatDec(float val) =>
    na(val) ? "NaN" : str.tostring(val, "#.##")

panelMarketCap = (showMktCap and not na(panelTotalShares) and not na(panelDailyClose)) ? panelDailyClose * panelTotalShares : na
panelSharesFloat = showFloat ? panelFloatShares : na
panelLodDist = (not na(panelDailyClose) and not na(panelDailyLow) and panelDailyLow != 0) ? ((panelDailyClose - panelDailyLow) / panelDailyLow) * 100 : na
panelProjVol = panelDailyVolume
panelVolBuzz = (not na(panelDailyVolume) and not na(panelAvgDailyVol) and panelAvgDailyVol != 0) ? ((panelDailyVolume / panelAvgDailyVol) - 1) * 100 : na
panelAtrMultSma21 = (not na(panelDailyClose) and not na(panelSma21) and not na(panelDailyATR) and panelDailyATR != 0) ? (panelDailyClose - panelSma21) / panelDailyATR : na
panelPctGainSma21 = (not na(panelDailyClose) and not na(panelSma21) and panelSma21 != 0) ? ((panelDailyClose - panelSma21) / panelSma21) * 100 : na
panelAtrPct = (not na(panelDailyATR) and not na(panelDailyClose) and panelDailyClose != 0) ? (panelDailyATR / panelDailyClose) * 100 : na

var table panel = table.new(panelPos, 2, 10, bgcolor=bgColor, border_width=0, frame_width=0)

if barstate.islast
    table.cell(panel, 0, 0, "Market Cap", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 0, formatBig(panelMarketCap), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 1, "Shares Float", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 1, formatBig(panelSharesFloat), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 2, "ADR%", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 2, formatPct(panelDailyADR), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 3, "LoD dist.", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 3, formatPct(panelLodDist), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 4, "Avg $ Vol", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 4, formatBig(panelAvgDollarVol), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 5, "Proj. Vol", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 5, formatBig(panelProjVol), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 6, "Vol. Buzz", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 6, formatPct(panelVolBuzz), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 7, "ATR Multiple", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 7, formatDec(panelAtrMultSma21), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 8, "% Gain", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 8, formatPct(panelPctGainSma21), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

    table.cell(panel, 0, 9, "ATR %", text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_left)
    table.cell(panel, 1, 9, formatPct(panelAtrPct), text_color=txtColor, text_size=txtSize, bgcolor=bgColor, text_halign=text.align_right)

// ==============================================================================
// MA SETUP PANEL — integrated add-on
// ==============================================================================
grpSetupPanel = "MA Setup Panel"

showSetupPanel = input.bool(true, "Show MA Setup Panel", group=grpSetupPanel)

setupMaType = input.string("SMA", "Moving Average Type", options=["EMA", "SMA"], group=grpSetupPanel)
setupUseDailyMAs = input.bool(true, "Use Daily Moving Averages on Intraday Charts?", group=grpSetupPanel)

setupAcceptableDist21 = input.float(6.0, "Acceptable Distance from MA21 (%)", step=0.1, group=grpSetupPanel)
setupTooFarFrom8 = input.float(4.0, "Too Far from MA8 (%)", step=0.1, group=grpSetupPanel)

setupVolumeLength = input.int(50, "Volume Average Length", minval=5, group=grpSetupPanel)
setupRelVolThreshold = input.float(1.5, "Above Normal Volume if RelVol >=", step=0.1, group=grpSetupPanel)

setupPreMarketSession = input.session("0400-0929", "Premarket Session", group=grpSetupPanel)
setupPreMarketTimezone = input.string("America/New_York", "Premarket Timezone", group=grpSetupPanel)
setupPreMarketGapMode = input.string("Premarket Open", "Premarket Gap Mode", options=["Premarket Open", "Current Premarket", "Premarket High/Low"], group=grpSetupPanel)

setupPanelSizeInput = input.string("Small", "Table Size", options=["Small", "Medium", "Large"], group=grpSetupPanel)
setupPanelPositionInput = input.string("Top Right", "Table Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grpSetupPanel)

setupTextTransparency = input.int(35, "Text Transparency / Opacity Control", minval=0, maxval=90, group=grpSetupPanel)

setupPositiveBaseColor = input.color(color.rgb(0, 95, 0), "Positive Color - Dark Green", group=grpSetupPanel)
setupNegativeBaseColor = input.color(color.rgb(190, 0, 0), "Negative Color - Red", group=grpSetupPanel)
setupNeutralBaseColor = input.color(color.rgb(210, 145, 60), "Neutral Color - Yellow Orange", group=grpSetupPanel)

setupPositiveColor = color.new(setupPositiveBaseColor, setupTextTransparency)
setupNegativeColor = color.new(setupNegativeBaseColor, setupTextTransparency)
setupNeutralColor = color.new(setupNeutralBaseColor, setupTextTransparency)

setupPanelTextSize = setupPanelSizeInput == "Small" ? size.tiny : setupPanelSizeInput == "Medium" ? size.small : size.normal

setupPanelPos = setupPanelPositionInput == "Top Right" ? position.top_right :
     setupPanelPositionInput == "Top Left" ? position.top_left :
     setupPanelPositionInput == "Bottom Left" ? position.bottom_left : position.bottom_right

setupBgColor = color.new(color.black, 100)

// ==============================================================================
// Setup Panel Helpers
// ==============================================================================
setup_ma(_src, _len) =>
    setupMaType == "EMA" ? ta.ema(_src, _len) : ta.sma(_src, _len)

setup_pct(_value) =>
    na(_value) ? "N/A" : (_value >= 0 ? "+" : "") + str.tostring(_value, "#.##") + "%"

setup_yes_no(_condition) =>
    _condition ? "YES" : "NO"

setup_above_below(_ma) =>
    na(_ma) ? "N/A" : close > _ma ? "ABOVE " + setup_pct((close - _ma) / _ma * 100) : close < _ma ? "BELOW " + setup_pct((close - _ma) / _ma * 100) : "EQUAL"

setup_distance(_ma) =>
    na(_ma) ? na : (close - _ma) / _ma * 100

setup_price_color(_ma) =>
    na(_ma) ? setupNeutralColor : close > _ma ? setupPositiveColor : close < _ma ? setupNegativeColor : setupNeutralColor

setup_bool_color(_condition) =>
    _condition ? setupPositiveColor : setupNegativeColor

setup_gap_color(_gapValue) =>
    na(_gapValue) ? setupNeutralColor : _gapValue >= 0 ? setupPositiveColor : setupNegativeColor

// ==============================================================================
// Setup Panel Moving Averages
// ==============================================================================
setupMa8Daily = request.security(syminfo.tickerid, "D", setup_ma(close, 8), barmerge.gaps_off, barmerge.lookahead_off)
setupMa21Daily = request.security(syminfo.tickerid, "D", setup_ma(close, 21), barmerge.gaps_off, barmerge.lookahead_off)
setupMa50Daily = request.security(syminfo.tickerid, "D", setup_ma(close, 50), barmerge.gaps_off, barmerge.lookahead_off)
setupMa100Daily = request.security(syminfo.tickerid, "D", setup_ma(close, 100), barmerge.gaps_off, barmerge.lookahead_off)
setupMa150Daily = request.security(syminfo.tickerid, "D", setup_ma(close, 150), barmerge.gaps_off, barmerge.lookahead_off)
setupMa200Daily = request.security(syminfo.tickerid, "D", setup_ma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)
setupMa300Daily = request.security(syminfo.tickerid, "D", setup_ma(close, 300), barmerge.gaps_off, barmerge.lookahead_off)

setupMa8Chart = setup_ma(close, 8)
setupMa21Chart = setup_ma(close, 21)
setupMa50Chart = setup_ma(close, 50)
setupMa100Chart = setup_ma(close, 100)
setupMa150Chart = setup_ma(close, 150)
setupMa200Chart = setup_ma(close, 200)
setupMa300Chart = setup_ma(close, 300)

setupMa8 = setupUseDailyMAs ? setupMa8Daily : setupMa8Chart
setupMa21 = setupUseDailyMAs ? setupMa21Daily : setupMa21Chart
setupMa50 = setupUseDailyMAs ? setupMa50Daily : setupMa50Chart
setupMa100 = setupUseDailyMAs ? setupMa100Daily : setupMa100Chart
setupMa150 = setupUseDailyMAs ? setupMa150Daily : setupMa150Chart
setupMa200 = setupUseDailyMAs ? setupMa200Daily : setupMa200Chart
setupMa300 = setupUseDailyMAs ? setupMa300Daily : setupMa300Chart

// ==============================================================================
// Setup Panel Conditions
// ==============================================================================
setupDist21 = setup_distance(setupMa21)
setupDist8 = setup_distance(setupMa8)

setupMa8Above21 = setupMa8 > setupMa21
setupMa21Above50 = setupMa21 > setupMa50
setupMa50Above200 = setupMa50 > setupMa200

setupDistance21Ok = not na(setupDist21) and math.abs(setupDist21) <= setupAcceptableDist21
setupTooExtendedFrom8 = not na(setupDist8) and math.abs(setupDist8) > setupTooFarFrom8

// ==============================================================================
// Setup Panel Volume
// ==============================================================================
setupAvgVolume = ta.sma(volume, setupVolumeLength)
setupRelativeVolume = setupAvgVolume > 0 ? volume / setupAvgVolume : na
setupVolumeAboveNormal = not na(setupRelativeVolume) and setupRelativeVolume >= setupRelVolThreshold

setupVolumeText = na(setupRelativeVolume) ? "N/A" : setup_yes_no(setupVolumeAboveNormal) + " | " + str.tostring(setupRelativeVolume, "#.##") + "x"
setupVolumeColor = na(setupRelativeVolume) ? setupNeutralColor : setupVolumeAboveNormal ? setupPositiveColor : setupNegativeColor

// ==============================================================================
// Setup Panel Premarket Gap
// ==============================================================================
setupIsIntraday = timeframe.isintraday
setupNewDay = ta.change(time("D")) != 0
setupInPremarket = setupIsIntraday and not na(time(timeframe.period, setupPreMarketSession, setupPreMarketTimezone))

var float setupPmOpen = na
var float setupPmLast = na
var float setupPmHigh = na
var float setupPmLow = na

if setupNewDay
    setupPmOpen := na
    setupPmLast := na
    setupPmHigh := na
    setupPmLow := na

if setupInPremarket
    if na(setupPmOpen)
        setupPmOpen := open
    setupPmLast := close
    setupPmHigh := na(setupPmHigh) ? high : math.max(setupPmHigh, high)
    setupPmLow := na(setupPmLow) ? low : math.min(setupPmLow, low)

setupPreviousClose = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)

setupPmOpenGap = not na(setupPmOpen) and not na(setupPreviousClose) ? (setupPmOpen - setupPreviousClose) / setupPreviousClose * 100 : na
setupPmCurrentGap = not na(setupPmLast) and not na(setupPreviousClose) ? (setupPmLast - setupPreviousClose) / setupPreviousClose * 100 : na
setupPmHighGap = not na(setupPmHigh) and not na(setupPreviousClose) ? (setupPmHigh - setupPreviousClose) / setupPreviousClose * 100 : na
setupPmLowGap = not na(setupPmLow) and not na(setupPreviousClose) ? (setupPmLow - setupPreviousClose) / setupPreviousClose * 100 : na

float setupSelectedGap = na

if setupPreMarketGapMode == "Premarket Open"
    setupSelectedGap := setupPmOpenGap
else if setupPreMarketGapMode == "Current Premarket"
    setupSelectedGap := setupPmCurrentGap

string setupPremarketGapText = ""
color setupPremarketGapColor = setupNeutralColor

if not setupIsIntraday
    setupPremarketGapText := "Intraday only"
    setupPremarketGapColor := setupNeutralColor
else if setupPreMarketGapMode == "Premarket High/Low"
    setupPremarketGapText := na(setupPmHighGap) or na(setupPmLowGap) ? "N/A" : "H " + setup_pct(setupPmHighGap) + " | L " + setup_pct(setupPmLowGap)
    setupPremarketGapColor := na(setupPmHighGap) or na(setupPmLowGap) ? setupNeutralColor : setupPmHighGap >= 0 and setupPmLowGap >= 0 ? setupPositiveColor : setupPmHighGap < 0 and setupPmLowGap < 0 ? setupNegativeColor : setupNeutralColor
else
    setupPremarketGapText := na(setupSelectedGap) ? "N/A" : setupSelectedGap >= 0 ? "UP " + setup_pct(setupSelectedGap) : "DOWN " + setup_pct(setupSelectedGap)
    setupPremarketGapColor := setup_gap_color(setupSelectedGap)

// ==============================================================================
// Setup Panel Row Colors
// ==============================================================================
setupMa21DistanceColor = na(setupDist21) ? setupNeutralColor : setupDistance21Ok ? setupPositiveColor : setupNegativeColor
setupFarFrom8Color = na(setupDist8) ? setupNeutralColor : setupTooExtendedFrom8 ? setupNegativeColor : setupPositiveColor

// ==============================================================================
// Setup Panel Table
// ==============================================================================
var table setupPanel = table.new(setupPanelPos, 2, 14, bgcolor=setupBgColor, frame_color=setupBgColor, border_color=setupBgColor, border_width=0)

setup_row(_row, _label, _value, _valueColor) =>
    table.cell(setupPanel, 0, _row, _label, text_color=setupNeutralColor, bgcolor=setupBgColor, text_size=setupPanelTextSize, text_halign=text.align_left)
    table.cell(setupPanel, 1, _row, _value, text_color=_valueColor, bgcolor=setupBgColor, text_size=setupPanelTextSize, text_halign=text.align_right)

if barstate.islast
    if showSetupPanel
        setup_row(0, "Price vs MA8", setup_above_below(setupMa8), setup_price_color(setupMa8))
        setup_row(1, "Price vs MA21", setup_above_below(setupMa21), setup_price_color(setupMa21))
        setup_row(2, "Price vs MA50", setup_above_below(setupMa50), setup_price_color(setupMa50))
        setup_row(3, "Price vs MA100", setup_above_below(setupMa100), setup_price_color(setupMa100))
        setup_row(4, "Price vs MA150", setup_above_below(setupMa150), setup_price_color(setupMa150))
        setup_row(5, "Price vs MA200", setup_above_below(setupMa200), setup_price_color(setupMa200))
        setup_row(6, "Price vs MA300", setup_above_below(setupMa300), setup_price_color(setupMa300))
        setup_row(7, "MA8 > MA21", setup_yes_no(setupMa8Above21), setup_bool_color(setupMa8Above21))
        setup_row(8, "MA21 > MA50", setup_yes_no(setupMa21Above50), setup_bool_color(setupMa21Above50))
        setup_row(9, "MA50 > MA200", setup_yes_no(setupMa50Above200), setup_bool_color(setupMa50Above200))
        setup_row(10, "MA21 Distance", setup_yes_no(setupDistance21Ok) + " | " + setup_pct(setupDist21), setupMa21DistanceColor)
        setup_row(11, "Far from MA8", setup_yes_no(setupTooExtendedFrom8) + " | " + setup_pct(setupDist8), setupFarFrom8Color)
        setup_row(12, "Volume Above Normal", setupVolumeText, setupVolumeColor)
        setup_row(13, "Premarket Gap %", setupPremarketGapText, setupPremarketGapColor)
    else
        for setupClearRow = 0 to 13
            table.cell(setupPanel, 0, setupClearRow, "", bgcolor=setupBgColor)
            table.cell(setupPanel, 1, setupClearRow, "", bgcolor=setupBgColor)
````
