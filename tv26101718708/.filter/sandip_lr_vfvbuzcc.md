# Sandip LR

- url: https://www.tradingview.com/script/vFvBuZcc-Sandip-LR/
- type: indicator
- pine_id: PUB;d7e82fc5c34a4189b9b5e9bf36784ea5
- version: 1.0

## Description

Sandip LR is a multi-level TradingView indicator designed to mark important intraday and daily reference levels on the chart.

It includes Previous Day High, Previous Day Low, Previous Day Close, CPR levels, traditional pivot points from R1 to R5 and S1 to S5, and Opening Range High/Low for a user-defined time period.

The script includes customization options for colors, line width, line style, label position, label font size, price-axis markers, and lookback periods for CPR, pivot points, and opening range levels.

This indicator is intended to help traders visually track key support, resistance, pivot, and session reference zones in one clean layout.

## Source Code

````pine
//@version=5
indicator("PDH PDL PDC CPR Pivot OR Levels", overlay=true, max_lines_count=500, max_labels_count=500)

groupPD = "1. PDH / PDL / PDC"
showPD = input.bool(true, "Show PDH / PDL / PDC", group=groupPD)
showPDH = input.bool(true, "Show PDH", group=groupPD)
showPDL = input.bool(true, "Show PDL", group=groupPD)
showPDC = input.bool(true, "Show PDC", group=groupPD)
pdhColor = input.color(color.blue, "PDH Color", group=groupPD)
pdlColor = input.color(color.blue, "PDL Color", group=groupPD)
pdcColor = input.color(color.orange, "PDC Color", group=groupPD)
pdWidth = input.int(2, "Line Width", minval=1, maxval=5, group=groupPD)
pdStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupPD)

groupCPR = "2. CPR"
showCPR = input.bool(true, "Show CPR", group=groupCPR)
showTC = input.bool(true, "Show TC", group=groupCPR)
showPivot = input.bool(true, "Show Pivot", group=groupCPR)
showBC = input.bool(true, "Show BC", group=groupCPR)
tcColor = input.color(color.purple, "TC Color", group=groupCPR)
pivotColor = input.color(color.gray, "Pivot Color", group=groupCPR)
bcColor = input.color(color.purple, "BC Color", group=groupCPR)
cprWidth = input.int(2, "Line Width", minval=1, maxval=5, group=groupCPR)
cprStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupCPR)
cprLookback = input.int(5, "Lookback Period", minval=1, maxval=30, group=groupCPR)

groupPivots = "3. Pivot Points"
showPivots = input.bool(true, "Show Pivot Points", group=groupPivots)
showR1 = input.bool(true, "Show R1", group=groupPivots)
showR2 = input.bool(true, "Show R2", group=groupPivots)
showR3 = input.bool(false, "Show R3", group=groupPivots)
showR4 = input.bool(false, "Show R4", group=groupPivots)
showR5 = input.bool(false, "Show R5", group=groupPivots)
showS1 = input.bool(true, "Show S1", group=groupPivots)
showS2 = input.bool(true, "Show S2", group=groupPivots)
showS3 = input.bool(false, "Show S3", group=groupPivots)
showS4 = input.bool(false, "Show S4", group=groupPivots)
showS5 = input.bool(false, "Show S5", group=groupPivots)
resColor = input.color(color.orange, "Resistance Color", group=groupPivots)
supColor = input.color(color.orange, "Support Color", group=groupPivots)
pivotPointWidth = input.int(1, "Line Width", minval=1, maxval=5, group=groupPivots)
pivotStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupPivots)
pivotLookback = input.int(5, "Lookback Period", minval=1, maxval=30, group=groupPivots)

groupOR = "4. Opening Range"
showOR = input.bool(true, "Show Opening Range", group=groupOR)
orSession = input.session("0915-0930", "Opening Range Time", group=groupOR)
showORH = input.bool(true, "Show OR High", group=groupOR)
showORL = input.bool(true, "Show OR Low", group=groupOR)
orHighColor = input.color(color.aqua, "OR High Color", group=groupOR)
orLowColor = input.color(color.fuchsia, "OR Low Color", group=groupOR)
orWidth = input.int(2, "Line Width", minval=1, maxval=5, group=groupOR)
orStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupOR)
orLookback = input.int(5, "Lookback Period", minval=1, maxval=30, group=groupOR)

groupLabels = "5. Labels / Price Axis"
showLevelLabels = input.bool(true, "Show CPR/Pivot/OR Level Labels", group=groupLabels)
labelPosition = input.string("Center", "Level Label Position", options=["Left", "Center", "Right"], group=groupLabels)
labelSizeInput = input.string("Small", "Label Font Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupLabels)
showRightLabels = input.bool(true, "Show PDH/PDL/PDC Right Labels", group=groupLabels)
showPriceScale = input.bool(true, "Show Latest Prices On Price Axis", group=groupLabels)
labelOffset = input.int(20, "Right Label Offset", minval=1, maxval=200, group=groupLabels)

lineStyle(styleText) =>
    styleText == "Dashed" ? line.style_dashed : styleText == "Dotted" ? line.style_dotted : line.style_solid

labelSize(sizeText) =>
    sizeText == "Tiny" ? size.tiny : sizeText == "Normal" ? size.normal : sizeText == "Large" ? size.large : sizeText == "Huge" ? size.huge : size.small

pdStyle = lineStyle(pdStyleInput)
cprStyle = lineStyle(cprStyleInput)
pivotStyle = lineStyle(pivotStyleInput)
orStyle = lineStyle(orStyleInput)
levelLabelSize = labelSize(labelSizeInput)

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pdc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

p = (pdh + pdl + pdc) / 3
bc = (pdh + pdl) / 2
tc = (p - bc) + p
rng = pdh - pdl

r1 = (2 * p) - pdl
s1 = (2 * p) - pdh
r2 = p + rng
s2 = p - rng
r3 = pdh + 2 * (p - pdl)
s3 = pdl - 2 * (pdh - p)
r4 = r3 + rng
s4 = s3 - rng
r5 = r4 + rng
s5 = s4 - rng

isNewDay = ta.change(time("D")) != 0

var int dayStartBar = na
if isNewDay
    dayStartBar := bar_index
if na(dayStartBar)
    dayStartBar := bar_index

txt(name, price) =>
    name + " (" + str.tostring(price, format.mintick) + ")"

addLevel(showLevel, name, price, levelColor, levelWidth, levelStyle, lookback, lineArr, labelArr) =>
    if showLevel
        newLine = line.new(bar_index, price, bar_index, price, color=levelColor, width=levelWidth, style=levelStyle)
        array.push(lineArr, newLine)

        if showLevelLabels
            newLabel = label.new(bar_index, price, txt(name, price), style=label.style_none, textcolor=levelColor, size=levelLabelSize)
            array.push(labelArr, newLabel)

        while array.size(lineArr) > lookback
            oldLine = array.shift(lineArr)
            line.delete(oldLine)

        while array.size(labelArr) > lookback
            oldLabel = array.shift(labelArr)
            label.delete(oldLabel)

updateLevels(lineArr, labelArr) =>
    if array.size(lineArr) > 0
        currentLine = array.get(lineArr, array.size(lineArr) - 1)
        line.set_x2(currentLine, bar_index)

        if array.size(labelArr) > 0
            currentLabel = array.get(labelArr, array.size(labelArr) - 1)
            x1 = line.get_x1(currentLine)
            x2 = line.get_x2(currentLine)
            labelX = labelPosition == "Left" ? x1 : labelPosition == "Right" ? x2 : math.round((x1 + x2) / 2)
            label.set_x(currentLabel, labelX)

var line pdhLine = na
var line pdlLine = na
var line pdcLine = na
var label pdhLabel = na
var label pdlLabel = na
var label pdcLabel = na

var line[] tcLines = array.new_line()
var line[] pLines = array.new_line()
var line[] bcLines = array.new_line()
var label[] tcLabels = array.new_label()
var label[] pLabels = array.new_label()
var label[] bcLabels = array.new_label()

var line[] r1Lines = array.new_line()
var line[] r2Lines = array.new_line()
var line[] r3Lines = array.new_line()
var line[] r4Lines = array.new_line()
var line[] r5Lines = array.new_line()
var line[] s1Lines = array.new_line()
var line[] s2Lines = array.new_line()
var line[] s3Lines = array.new_line()
var line[] s4Lines = array.new_line()
var line[] s5Lines = array.new_line()

var label[] r1Labels = array.new_label()
var label[] r2Labels = array.new_label()
var label[] r3Labels = array.new_label()
var label[] r4Labels = array.new_label()
var label[] r5Labels = array.new_label()
var label[] s1Labels = array.new_label()
var label[] s2Labels = array.new_label()
var label[] s3Labels = array.new_label()
var label[] s4Labels = array.new_label()
var label[] s5Labels = array.new_label()

var line[] orhLines = array.new_line()
var line[] orlLines = array.new_line()
var label[] orhLabels = array.new_label()
var label[] orlLabels = array.new_label()

inOR = not na(time(timeframe.period, orSession))
orStart = inOR and not inOR[1]
orEnd = not inOR and inOR[1]

var float orHigh = na
var float orLow = na

if orStart
    orHigh := high
    orLow := low

if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)

if isNewDay or barstate.isfirst
    addLevel(showCPR and showTC, "TC", tc, tcColor, cprWidth, cprStyle, cprLookback, tcLines, tcLabels)
    addLevel(showCPR and showPivot, "P", p, pivotColor, cprWidth, cprStyle, cprLookback, pLines, pLabels)
    addLevel(showCPR and showBC, "BC", bc, bcColor, cprWidth, cprStyle, cprLookback, bcLines, bcLabels)

    addLevel(showPivots and showR1, "R1", r1, resColor, pivotPointWidth, pivotStyle, pivotLookback, r1Lines, r1Labels)
    addLevel(showPivots and showR2, "R2", r2, resColor, pivotPointWidth, pivotStyle, pivotLookback, r2Lines, r2Labels)
    addLevel(showPivots and showR3, "R3", r3, resColor, pivotPointWidth, pivotStyle, pivotLookback, r3Lines, r3Labels)
    addLevel(showPivots and showR4, "R4", r4, resColor, pivotPointWidth, pivotStyle, pivotLookback, r4Lines, r4Labels)
    addLevel(showPivots and showR5, "R5", r5, resColor, pivotPointWidth, pivotStyle, pivotLookback, r5Lines, r5Labels)

    addLevel(showPivots and showS1, "S1", s1, supColor, pivotPointWidth, pivotStyle, pivotLookback, s1Lines, s1Labels)
    addLevel(showPivots and showS2, "S2", s2, supColor, pivotPointWidth, pivotStyle, pivotLookback, s2Lines, s2Labels)
    addLevel(showPivots and showS3, "S3", s3, supColor, pivotPointWidth, pivotStyle, pivotLookback, s3Lines, s3Labels)
    addLevel(showPivots and showS4, "S4", s4, supColor, pivotPointWidth, pivotStyle, pivotLookback, s4Lines, s4Labels)
    addLevel(showPivots and showS5, "S5", s5, supColor, pivotPointWidth, pivotStyle, pivotLookback, s5Lines, s5Labels)

if orEnd
    addLevel(showOR and showORH, "ORH", orHigh, orHighColor, orWidth, orStyle, orLookback, orhLines, orhLabels)
    addLevel(showOR and showORL, "ORL", orLow, orLowColor, orWidth, orStyle, orLookback, orlLines, orlLabels)

updateLevels(tcLines, tcLabels)
updateLevels(pLines, pLabels)
updateLevels(bcLines, bcLabels)

updateLevels(r1Lines, r1Labels)
updateLevels(r2Lines, r2Labels)
updateLevels(r3Lines, r3Labels)
updateLevels(r4Lines, r4Labels)
updateLevels(r5Lines, r5Labels)

updateLevels(s1Lines, s1Labels)
updateLevels(s2Lines, s2Labels)
updateLevels(s3Lines, s3Labels)
updateLevels(s4Lines, s4Labels)
updateLevels(s5Lines, s5Labels)

updateLevels(orhLines, orhLabels)
updateLevels(orlLines, orlLabels)

if barstate.islast
    labelX = bar_index + labelOffset

    line.delete(pdhLine)
    line.delete(pdlLine)
    line.delete(pdcLine)
    label.delete(pdhLabel)
    label.delete(pdlLabel)
    label.delete(pdcLabel)

    if showPD and showPDH
        pdhLine := line.new(dayStartBar, pdh, labelX, pdh, color=pdhColor, width=pdWidth, style=pdStyle)
        pdhLabel := showRightLabels ? label.new(labelX, pdh, "PDH " + str.tostring(pdh, format.mintick), style=label.style_label_left, textcolor=color.white, color=pdhColor, size=levelLabelSize) : na

    if showPD and showPDL
        pdlLine := line.new(dayStartBar, pdl, labelX, pdl, color=pdlColor, width=pdWidth, style=pdStyle)
        pdlLabel := showRightLabels ? label.new(labelX, pdl, "PDL " + str.tostring(pdl, format.mintick), style=label.style_label_left, textcolor=color.white, color=pdlColor, size=levelLabelSize) : na

    if showPD and showPDC
        pdcLine := line.new(dayStartBar, pdc, labelX, pdc, color=pdcColor, width=pdWidth, style=pdStyle)
        pdcLabel := showRightLabels ? label.new(labelX, pdc, "PDC " + str.tostring(pdc, format.mintick), style=label.style_label_left, textcolor=color.white, color=pdcColor, size=levelLabelSize) : na

plot(showPriceScale and showPD and showPDH ? pdh : na, "PDH", color=pdhColor, display=display.price_scale)
plot(showPriceScale and showPD and showPDL ? pdl : na, "PDL", color=pdlColor, display=display.price_scale)
plot(showPriceScale and showPD and showPDC ? pdc : na, "PDC", color=pdcColor, display=display.price_scale)

plot(showPriceScale and showCPR and showTC ? tc : na, "TC", color=tcColor, display=display.price_scale)
plot(showPriceScale and showCPR and showPivot ? p : na, "P", color=pivotColor, display=display.price_scale)
plot(showPriceScale and showCPR and showBC ? bc : na, "BC", color=bcColor, display=display.price_scale)

plot(showPriceScale and showPivots and showR1 ? r1 : na, "R1", color=resColor, display=display.price_scale)
plot(showPriceScale and showPivots and showR2 ? r2 : na, "R2", color=resColor, display=display.price_scale)
plot(showPriceScale and showPivots and showR3 ? r3 : na, "R3", color=resColor, display=display.price_scale)
plot(showPriceScale and showPivots and showR4 ? r4 : na, "R4", color=resColor, display=display.price_scale)
plot(showPriceScale and showPivots and showR5 ? r5 : na, "R5", color=resColor, display=display.price_scale)

plot(showPriceScale and showPivots and showS1 ? s1 : na, "S1", color=supColor, display=display.price_scale)
plot(showPriceScale and showPivots and showS2 ? s2 : na, "S2", color=supColor, display=display.price_scale)
plot(showPriceScale and showPivots and showS3 ? s3 : na, "S3", color=supColor, display=display.price_scale)
plot(showPriceScale and showPivots and showS4 ? s4 : na, "S4", color=supColor, display=display.price_scale)
plot(showPriceScale and showPivots and showS5 ? s5 : na, "S5", color=supColor, display=display.price_scale)

plot(showPriceScale and showOR and showORH ? orHigh : na, "ORH", color=orHighColor, display=display.price_scale)
plot(showPriceScale and showOR and showORL ? orLow : na, "ORL", color=orLowColor, display=display.price_scale)
````
