# Cross Broker Price Difference indicator

- url: https://www.tradingview.com/script/u4drO0x7-Cross-Broker-Price-Difference-indicator/
- type: indicator
- pine_id: PUB;81e04af7cff149919956c10aed43a51c
- version: 1.0

## Description

Cross ascacacacsaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ascaaaaaaaaaaaaaaaaaaa

## Source Code

````pine
//@version=6
indicator("Cross-Broker Price Difference", overlay=false)

// ==================== INPUTS ====================

secondarySymbol = input.symbol("OANDA:EURUSD", "Secondary Instrument", tooltip="Select the comparison instrument")

rangeAMin = input.float(10.0, "Range A Min", minval=0.0, step=0.5)
rangeAMax = input.float(15.0, "Range A Max", minval=0.0, step=0.5)

rangeBMin = input.float(16.0, "Range B Min", minval=0.0, step=0.5)
rangeBMax = input.float(25.0, "Range B Max", minval=0.0, step=0.5)

rangeCMin = input.float(26.0, "Range C Min", minval=0.0, step=0.5)
rangeCMax = input.float(40.0, "Range C Max", minval=0.0, step=0.5)

// Table settings
showTable = input.bool(true, "Show Info Table")
tablePosition = input.string("top_right", "Table Position", options=["top_right", "top_left", "bottom_right", "bottom_left"])
tableTextSize = input.string("normal", "Table Text Size", options=["tiny", "small", "normal", "large", "huge"])
tableCellWidth = input.int(12, "Cell Width", minval=5, maxval=30)
tableCellHeight = input.int(3, "Cell Height", minval=1, maxval=10)

// Table colors
tableHeaderBgColor = input.color(color.new(color.blue, 50), "Header Background Color")
tableBodyBgColor = input.color(color.new(color.black, 80), "Table Background Color")
tableBorderColor = input.color(color.gray, "Border Color")
tableFrameColor = input.color(color.white, "Frame Color")

// Text colors
headerTextColor = input.color(color.black, "Header Text Color")
labelTextColor = input.color(color.black, "Label Text Color")
primaryPriceColor = input.color(color.black, "Primary Price Color")
secondaryPriceColor = input.color(color.black, "Secondary Price Color")
rangeAColor = input.color(color.black, "Range A Color")
rangeBColor = input.color(color.black, "Range B Color")
rangeCColor = input.color(color.black, "Range C Color")
belowRangeColor = input.color(color.black, "Below Range Color")

// Optional direction colors
statusPrimaryHigherColor = input.color(color.red, "Primary Higher Color")
statusSecondaryHigherColor = input.color(color.green, "Secondary Higher Color")
statusNoMatchColor = input.color(color.gray, "No Match Color")

// Display settings
showSecondaryLine = input.bool(true, "Plot Secondary Price")
highlightBackground = input.bool(true, "Highlight When Range Is Hit")

// Secondary pane chart settings
showRangeAChart = input.bool(true, "Show Range A Chart")
rangeAChartStyle = input.string("Columns", "Range A Chart Style", options=["Columns", "Line", "Area"])
rangeAActiveColor = input.color(color.lime, "Range A Active Color")
rangeAInactiveColor = input.color(color.gray, "Range A Inactive Color")

// ==================== DATA ====================

primaryClose = close
secondaryClose = request.security(secondarySymbol, timeframe.period, close)
validData = not na(primaryClose) and not na(secondaryClose)

// ==================== CALCULATIONS ====================

priceDiff = primaryClose - secondaryClose
priceDiffAbs = math.abs(priceDiff)

avgPrice = (primaryClose + secondaryClose) / 2
priceDiffPct = validData and avgPrice != 0 ? (priceDiffAbs / avgPrice) * 100 : 0

primaryHigher = validData and primaryClose > secondaryClose
secondaryHigher = validData and secondaryClose > primaryClose

aMin = math.min(rangeAMin, rangeAMax)
aMax = math.max(rangeAMin, rangeAMax)

bMin = math.min(rangeBMin, rangeBMax)
bMax = math.max(rangeBMin, rangeBMax)

cMin = math.min(rangeCMin, rangeCMax)
cMax = math.max(rangeCMin, rangeCMax)

inRangeA = validData and priceDiffAbs >= aMin and priceDiffAbs <= aMax
inRangeB = validData and priceDiffAbs >= bMin and priceDiffAbs <= bMax
inRangeC = validData and priceDiffAbs >= cMin and priceDiffAbs <= cMax

anyRangeHit = inRangeA or inRangeB or inRangeC

activeRangeText = inRangeC ? "RANGE C HIT" : inRangeB ? "RANGE B HIT" : inRangeA ? "RANGE A HIT" : "NO RANGE HIT"
activeRangeColor = inRangeC ? rangeCColor : inRangeB ? rangeBColor : inRangeA ? rangeAColor : belowRangeColor

directionText = not validData ? "NO DATA" : primaryHigher ? "PRIMARY HIGHER" : secondaryHigher ? "SECONDARY HIGHER" : "EQUAL"

// ==================== SECONDARY WINDOW SERIES ====================

rangeASeries = inRangeA ? 1.0 : 0.0
rangeAColorPlot = inRangeA ? rangeAActiveColor : rangeAInactiveColor

plot(
    showRangeAChart and rangeAChartStyle == "Columns" ? rangeASeries : na,
    title="Range A vs Time",
    style=plot.style_columns,
    color=rangeAColorPlot,
    linewidth=2
)

plot(
    showRangeAChart and rangeAChartStyle == "Line" ? rangeASeries : na,
    title="Range A vs Time Line",
    style=plot.style_line,
    color=rangeAActiveColor,
    linewidth=2
)

plot(
    showRangeAChart and rangeAChartStyle == "Area" ? rangeASeries : na,
    title="Range A vs Time Area",
    style=plot.style_area,
    color=color.new(rangeAActiveColor, 35),
    linewidth=2
)

hline(1.0, "Range A Active", color=color.new(color.green, 50), linestyle=hline.style_dashed)
hline(0.0, "Range A Inactive", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// ==================== OPTIONAL VISUALIZATION ====================

plot(showSecondaryLine ? secondaryClose : na, "Secondary Price", color=secondaryPriceColor, linewidth=1)

// ==================== HELPERS ====================

getTextSize(sizeInput) =>
    switch sizeInput
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        "huge" => size.huge
        => size.normal

getTablePosition(posInput) =>
    switch posInput
        "top_right" => position.top_right
        "top_left" => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left" => position.bottom_left
        => position.top_right

formatRange(minVal, maxVal) =>
    str.tostring(minVal, "#.##") + " - " + str.tostring(maxVal, "#.##")

// ==================== INFO TABLE ====================

var table infoTable = table.new(
    getTablePosition(tablePosition),
    columns=2,
    rows=9,
    bgcolor=tableBodyBgColor,
    border_width=2,
    border_color=tableBorderColor,
    frame_width=2,
    frame_color=tableFrameColor
)

if barstate.islast
    table.clear(infoTable, 0, 0, 1, 8)

    if showTable
        textSize = getTextSize(tableTextSize)

        table.cell(infoTable, 0, 0, "Metric", text_color=headerTextColor, text_size=textSize, bgcolor=tableHeaderBgColor, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 0, "Value", text_color=headerTextColor, text_size=textSize, bgcolor=tableHeaderBgColor, width=tableCellWidth, height=tableCellHeight)

        table.cell(infoTable, 0, 1, "Primary Price", text_color=labelTextColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 1, validData ? str.tostring(primaryClose, format.mintick) : "N/A", text_color=primaryPriceColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)

        table.cell(infoTable, 0, 2, "Secondary Price", text_color=labelTextColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 2, validData ? str.tostring(secondaryClose, format.mintick) : "N/A", text_color=secondaryPriceColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)

        table.cell(infoTable, 0, 3, "Price Diff", text_color=labelTextColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 3, validData ? str.tostring(priceDiffAbs, "#.##") : "N/A", text_color=activeRangeColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)

        table.cell(infoTable, 0, 4, "Price Diff (%)", text_color=labelTextColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 4, validData ? str.tostring(priceDiffPct, "#.###") + "%" : "N/A", text_color=activeRangeColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)

        table.cell(infoTable, 0, 5, "Range A", text_color=labelTextColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 5, formatRange(aMin, aMax), text_color=rangeAColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)

        table.cell(infoTable, 0, 6, "Range B", text_color=labelTextColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 6, formatRange(bMin, bMax), text_color=rangeBColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)

        table.cell(infoTable, 0, 7, "Range C", text_color=labelTextColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 7, formatRange(cMin, cMax), text_color=rangeCColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)

        table.cell(infoTable, 0, 8, "Status", text_color=labelTextColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)
        table.cell(infoTable, 1, 8, activeRangeText + " | " + directionText, text_color=activeRangeColor, text_size=textSize, width=tableCellWidth, height=tableCellHeight)

// ==================== ALERTS ====================

alertcondition(inRangeA, "Range A Reached", "Price difference is within Range A")
alertcondition(inRangeB, "Range B Reached", "Price difference is within Range B")
alertcondition(inRangeC, "Range C Reached", "Price difference is within Range C")

rangeAEntry = inRangeA and not inRangeA[1]
rangeBEntry = inRangeB and not inRangeB[1]
rangeCEntry = inRangeC and not inRangeC[1]

if rangeAEntry
    alert("Range A Reached | Diff: " + str.tostring(priceDiffAbs, "#.##") + " | Configured Range: " + str.tostring(aMin, "#.##") + " to " + str.tostring(aMax, "#.##") + " | Direction: " + directionText, alert.freq_once_per_bar_close)

if rangeBEntry
    alert("Range B Reached | Diff: " + str.tostring(priceDiffAbs, "#.##") + " | Configured Range: " + str.tostring(bMin, "#.##") + " to " + str.tostring(bMax, "#.##") + " | Direction: " + directionText, alert.freq_once_per_bar_close)

if rangeCEntry
    alert("Range C Reached | Diff: " + str.tostring(priceDiffAbs, "#.##") + " | Configured Range: " + str.tostring(cMin, "#.##") + " to " + str.tostring(cMax, "#.##") + " | Direction: " + directionText, alert.freq_once_per_bar_close)
````
