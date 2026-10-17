# Multi-Timeframe MA Dashboard

- url: https://www.tradingview.com/script/52NgbCju-Multi-Timeframe-MA-Dashboard/
- type: indicator
- pine_id: PUB;0aabf22c922a481cbd956faea02ba5d7
- version: 1.0

## Description

## Multi-Timeframe EMA Dashboard (Pine Script v6)

This indicator provides a comprehensive tactical overview of price action relative to multiple moving averages across six different timeframes. It is designed for traders who prioritize multi-timeframe analysis to identify trend alignment and high-confluence "confluence zones."

---

### Key Features

* **Adaptive Moving Averages:** Choose between **EMA**, **SMA**, or **VIDYA** (Variable Index Dynamic Average). The VIDYA option adjusts its sensitivity based on market volatility using CMO or Standard Deviation.
* **6x6 Data Grid:** Monitors six user-defined moving average lengths across six customizable timeframes simultaneously.
* **Dynamic Clustering Logic:** The dashboard automatically identifies and color-codes "clusters" where different moving averages from various timeframes converge within a specific percentage threshold ($clusterPct$). This highlights significant structural support or resistance levels.
* **Real-Time Position Tracking:** Each cell displays the specific MA value and indicates whether the price on that timeframe is currently **Above**, **Below**, or **At** the moving average.
* **On-Chart Visuals:** Optionally plot all six moving averages directly on your current chart for immediate visual reference.

---

### How to Use

1.  **Trend Alignment:** Scan the columns to see if price is "Above" across all timeframes. Uniformity indicates a strong, high-probability trend.
2.  **Mean Reversion & Support:** Look for color-coded clusters. When multiple MAs converge, the market often treats that price zone as a major pivot point.
3.  **Volatility Adaptation:** Use the VIDYA setting during choppy markets; it slows down during consolidation and speeds up during breakouts to minimize lag.

### Strategic Advantage
By consolidating 36 data points into a single table, this tool eliminates the need to constantly flip between tabs, allowing for faster objective decision-making and better identification of power dynamics between different time horizons.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe MA Dashboard", shorttitle="MA Dash", overlay=true, max_labels_count=500)

maType   = input.string("EMA", "MA Type", options=["EMA", "SMA", "VIDYA"], group="Average Settings")
maSource = input.source(close, "Source", group="Average Settings")

vidyaFixedCmo      = input.bool(true, "Fixed CMO Length", group="VIDYA Settings")
vidyaCmoLength     = input.int(9, "CMO Length", minval=1, group="VIDYA Settings")
vidyaAdaptiveMethod = input.string("CMO", "Adaptive Method", options=["CMO", "StdDev"], group="VIDYA Settings")

ema1Len = input.int(9, "MA 1 Length", minval=1, group="MA Lengths")
ema2Len = input.int(20, "MA 2 Length", minval=1, group="MA Lengths")
ema3Len = input.int(50, "MA 3 Length", minval=1, group="MA Lengths")
ema4Len = input.int(100, "MA 4 Length", minval=1, group="MA Lengths")
ema5Len = input.int(200, "MA 5 Length", minval=1, group="MA Lengths")
ema6Len = input.int(400, "MA 6 Length", minval=1, group="MA Lengths")

showOnChart = input.bool(true, "Plot MAs On Current Chart", group="Chart MAs")

tf1Value = input.int(5, "TF 1 Value", minval=1, group="Dashboard Timeframes")
tf1Unit = input.string("Minutes", "TF 1 Unit", options=["Minutes", "Hours", "Days"], group="Dashboard Timeframes")
tf2Value = input.int(15, "TF 2 Value", minval=1, group="Dashboard Timeframes")
tf2Unit = input.string("Minutes", "TF 2 Unit", options=["Minutes", "Hours", "Days"], group="Dashboard Timeframes")
tf3Value = input.int(1, "TF 3 Value", minval=1, group="Dashboard Timeframes")
tf3Unit = input.string("Hours", "TF 3 Unit", options=["Minutes", "Hours", "Days"], group="Dashboard Timeframes")
tf4Value = input.int(4, "TF 4 Value", minval=1, group="Dashboard Timeframes")
tf4Unit = input.string("Hours", "TF 4 Unit", options=["Minutes", "Hours", "Days"], group="Dashboard Timeframes")
tf5Value = input.int(1, "TF 5 Value", minval=1, group="Dashboard Timeframes")
tf5Unit = input.string("Days", "TF 5 Unit", options=["Minutes", "Hours", "Days"], group="Dashboard Timeframes")
tf6Value = input.int(3, "TF 6 Value", minval=1, group="Dashboard Timeframes")
tf6Unit = input.string("Days", "TF 6 Unit", options=["Minutes", "Hours", "Days"], group="Dashboard Timeframes")

tablePosition = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Dashboard Style")
textSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group="Dashboard Style")
neutralColor = input.color(color.new(color.gray, 65), "Header Color", group="Dashboard Style")
baseCellColor = input.color(color.new(color.silver, 25), "Base Cell Color", group="Dashboard Style")
clusterPct = input.float(0.001, "EMA Cluster %", minval=0.001, step=0.001, group="Dashboard Style")
clusterColor1  = input.color(color.new(color.blue, 15), "Cluster Color 1", group="Dashboard Style")
clusterColor2  = input.color(color.new(color.orange, 15), "Cluster Color 2", group="Dashboard Style")
clusterColor3  = input.color(color.new(color.purple, 15), "Cluster Color 3", group="Dashboard Style")
clusterColor4  = input.color(color.new(color.teal, 15), "Cluster Color 4", group="Dashboard Style")
clusterColor5  = input.color(color.new(color.rgb(212, 175, 55), 15), "Cluster Color 5", group="Dashboard Style")
clusterColor6  = input.color(color.new(color.fuchsia, 15), "Cluster Color 6", group="Dashboard Style")
clusterColor7  = input.color(color.new(color.lime, 15), "Cluster Color 7", group="Dashboard Style")
clusterColor8  = input.color(color.new(color.rgb(255, 100, 100), 15), "Cluster Color 8", group="Dashboard Style")
clusterColor9  = input.color(color.new(color.rgb(0, 200, 255), 15), "Cluster Color 9", group="Dashboard Style")
clusterColor10 = input.color(color.new(color.rgb(180, 0, 255), 15), "Cluster Color 10", group="Dashboard Style")
clusterColor11 = input.color(color.new(color.rgb(255, 165, 0), 15), "Cluster Color 11", group="Dashboard Style")
textColor = input.color(color.white, "Text Color", group="Dashboard Style")

getTfString(int value, string unit) =>
    unit == "Minutes" ? str.tostring(value) : unit == "Hours" ? str.tostring(value * 60) : str.tostring(value) + "D"

getTfLabel(int value, string unit) =>
    suffix = unit == "Minutes" ? "m" : unit == "Hours" ? "h" : "D"
    str.tostring(value) + suffix

getPosition(string pos) =>
    pos == "Top Left" ? position.top_left : pos == "Bottom Left" ? position.bottom_left : pos == "Bottom Right" ? position.bottom_right : position.top_right

getSize(string sizeName) =>
    sizeName == "Tiny" ? size.tiny : sizeName == "Normal" ? size.normal : size.small

getCellText(float maValue, float tfClose) =>
    stateText = tfClose > maValue ? "Above" : tfClose < maValue ? "Below" : "At"
    str.tostring(maValue, format.mintick) + "\n" + stateText

getPctDiff(float valueA, float valueB) =>
    base = math.abs(valueA + valueB) / 2.0
    base == 0.0 ? 0.0 : math.abs(valueA - valueB) / base * 100.0

getPaletteColor(int paletteIndex) =>
    paletteIndex == 0 ? clusterColor1 : paletteIndex == 1 ? clusterColor2 : paletteIndex == 2 ? clusterColor3 : paletteIndex == 3 ? clusterColor4 : paletteIndex == 4 ? clusterColor5 : paletteIndex == 5 ? clusterColor6 : paletteIndex == 6 ? clusterColor7 : paletteIndex == 7 ? clusterColor8 : paletteIndex == 8 ? clusterColor9 : paletteIndex == 9 ? clusterColor10 : clusterColor11

getClusterCellColor(array<int> clusterIds, array<int> clusterSizes, array<int> uniqueIds, int index) =>
    sz = array.get(clusterSizes, index)
    if sz < 2
        baseCellColor
    else
        paletteIndex = array.indexof(uniqueIds, array.get(clusterIds, index))
        paletteIndex < 0 or paletteIndex >= 11 ? baseCellColor : getPaletteColor(paletteIndex)

getVidyaFactor(series float src, int adaptLen, string adaptMethod) =>
    cmoFactor = math.abs(ta.cmo(src, adaptLen)) / 100.0
    stdevValue = ta.stdev(src, adaptLen)
    stdevBaseline = nz(ta.sma(stdevValue, adaptLen), stdevValue)
    stdevFactor = stdevBaseline == 0.0 ? 0.0 : math.min(stdevValue / stdevBaseline, 1.0)
    adaptMethod == "StdDev" ? stdevFactor : cmoFactor

getVidya(series float src, int len, int adaptLen, string adaptMethod) =>
    alpha = 2.0 / (len + 1.0)
    factor = getVidyaFactor(src, adaptLen, adaptMethod)
    var float vidya = na
    vidya := na(vidya[1]) ? src : vidya[1] + alpha * factor * (src - vidya[1])

getAverage(series float src, int len) =>
    adaptLen = vidyaFixedCmo ? vidyaCmoLength : len
    maType == "SMA" ? ta.sma(src, len) : maType == "VIDYA" ? getVidya(src, len, adaptLen, vidyaAdaptiveMethod) : ta.ema(src, len)

maLabel = maType + " "

tf1 = getTfString(tf1Value, tf1Unit)
tf2 = getTfString(tf2Value, tf2Unit)
tf3 = getTfString(tf3Value, tf3Unit)
tf4 = getTfString(tf4Value, tf4Unit)
tf5 = getTfString(tf5Value, tf5Unit)
tf6 = getTfString(tf6Value, tf6Unit)

tf1Label = getTfLabel(tf1Value, tf1Unit)
tf2Label = getTfLabel(tf2Value, tf2Unit)
tf3Label = getTfLabel(tf3Value, tf3Unit)
tf4Label = getTfLabel(tf4Value, tf4Unit)
tf5Label = getTfLabel(tf5Value, tf5Unit)
tf6Label = getTfLabel(tf6Value, tf6Unit)

ma1Plot = getAverage(maSource, ema1Len)
ma2Plot = getAverage(maSource, ema2Len)
ma3Plot = getAverage(maSource, ema3Len)
ma4Plot = getAverage(maSource, ema4Len)
ma5Plot = getAverage(maSource, ema5Len)
ma6Plot = getAverage(maSource, ema6Len)

plot(showOnChart ? ma1Plot : na, "MA 1", color=color.new(color.aqua, 0), linewidth=2)
plot(showOnChart ? ma2Plot : na, "MA 2", color=color.new(color.orange, 0), linewidth=2)
plot(showOnChart ? ma3Plot : na, "MA 3", color=color.new(color.yellow, 0), linewidth=2)
plot(showOnChart ? ma4Plot : na, "MA 4", color=color.new(color.fuchsia, 0), linewidth=2)
plot(showOnChart ? ma5Plot : na, "MA 5", color=color.new(color.green, 0), linewidth=2)
plot(showOnChart ? ma6Plot : na, "MA 6", color=color.new(color.red, 0), linewidth=2)

getTfData(string tf) =>
    request.security(
         syminfo.tickerid,
         tf,
         [
             close,
             getAverage(maSource, ema1Len),
             getAverage(maSource, ema2Len),
             getAverage(maSource, ema3Len),
             getAverage(maSource, ema4Len),
             getAverage(maSource, ema5Len),
             getAverage(maSource, ema6Len)
         ],
         barmerge.gaps_off,
         barmerge.lookahead_off
     )

[tf1Close, tf1Ma1, tf1Ma2, tf1Ma3, tf1Ma4, tf1Ma5, tf1Ma6] = getTfData(tf1)
[tf2Close, tf2Ma1, tf2Ma2, tf2Ma3, tf2Ma4, tf2Ma5, tf2Ma6] = getTfData(tf2)
[tf3Close, tf3Ma1, tf3Ma2, tf3Ma3, tf3Ma4, tf3Ma5, tf3Ma6] = getTfData(tf3)
[tf4Close, tf4Ma1, tf4Ma2, tf4Ma3, tf4Ma4, tf4Ma5, tf4Ma6] = getTfData(tf4)
[tf5Close, tf5Ma1, tf5Ma2, tf5Ma3, tf5Ma4, tf5Ma5, tf5Ma6] = getTfData(tf5)
[tf6Close, tf6Ma1, tf6Ma2, tf6Ma3, tf6Ma4, tf6Ma5, tf6Ma6] = getTfData(tf6)

maGridValues = array.from(
    tf1Ma1, tf2Ma1, tf3Ma1, tf4Ma1, tf5Ma1, tf6Ma1,
    tf1Ma2, tf2Ma2, tf3Ma2, tf4Ma2, tf5Ma2, tf6Ma2,
    tf1Ma3, tf2Ma3, tf3Ma3, tf4Ma3, tf5Ma3, tf6Ma3,
    tf1Ma4, tf2Ma4, tf3Ma4, tf4Ma4, tf5Ma4, tf6Ma4,
    tf1Ma5, tf2Ma5, tf3Ma5, tf4Ma5, tf5Ma5, tf6Ma5,
    tf1Ma6, tf2Ma6, tf3Ma6, tf4Ma6, tf5Ma6, tf6Ma6
)

cellCount = array.size(maGridValues)
clusterIds = array.new_int(cellCount, 0)
clusterSizes = array.new_int(cellCount, 1)

for i = 0 to cellCount - 1
    array.set(clusterIds, i, i)

for i = 0 to cellCount - 2
    valueI = array.get(maGridValues, i)
    for j = i + 1 to cellCount - 1
        valueJ = array.get(maGridValues, j)
        if getPctDiff(valueI, valueJ) <= clusterPct
            clusterI = array.get(clusterIds, i)
            clusterJ = array.get(clusterIds, j)
            if clusterI != clusterJ
                keepId = math.min(clusterI, clusterJ)
                replaceId = math.max(clusterI, clusterJ)
                for k = 0 to cellCount - 1
                    if array.get(clusterIds, k) == replaceId
                        array.set(clusterIds, k, keepId)

for i = 0 to cellCount - 1
    clusterId = array.get(clusterIds, i)
    members = 0
    for j = 0 to cellCount - 1
        if array.get(clusterIds, j) == clusterId
            members += 1
    array.set(clusterSizes, i, members)

uniqueClusterIds = array.new_int(0)
for i = 0 to cellCount - 1
    if array.get(clusterSizes, i) >= 2
        cid = array.get(clusterIds, i)
        if array.indexof(uniqueClusterIds, cid) == -1
            array.push(uniqueClusterIds, cid)

var table dashboard = table.new(getPosition(tablePosition), 7, 7, border_width=1)

if barstate.islast
    table.cell(dashboard, 0, 0, maType + " / TF", bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 1, 0, tf1Label, bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 2, 0, tf2Label, bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 3, 0, tf3Label, bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 4, 0, tf4Label, bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 5, 0, tf5Label, bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 6, 0, tf6Label, bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))

    table.cell(dashboard, 0, 1, maLabel + str.tostring(ema1Len), bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 1, 1, getCellText(tf1Ma1, tf1Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 0), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 2, 1, getCellText(tf2Ma1, tf2Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 1), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 3, 1, getCellText(tf3Ma1, tf3Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 2), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 4, 1, getCellText(tf4Ma1, tf4Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 3), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 5, 1, getCellText(tf5Ma1, tf5Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 4), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 6, 1, getCellText(tf6Ma1, tf6Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 5), text_color=textColor, text_size=getSize(textSizeInput))

    table.cell(dashboard, 0, 2, maLabel + str.tostring(ema2Len), bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 1, 2, getCellText(tf1Ma2, tf1Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 6), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 2, 2, getCellText(tf2Ma2, tf2Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 7), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 3, 2, getCellText(tf3Ma2, tf3Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 8), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 4, 2, getCellText(tf4Ma2, tf4Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 9), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 5, 2, getCellText(tf5Ma2, tf5Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 10), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 6, 2, getCellText(tf6Ma2, tf6Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 11), text_color=textColor, text_size=getSize(textSizeInput))

    table.cell(dashboard, 0, 3, maLabel + str.tostring(ema3Len), bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 1, 3, getCellText(tf1Ma3, tf1Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 12), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 2, 3, getCellText(tf2Ma3, tf2Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 13), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 3, 3, getCellText(tf3Ma3, tf3Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 14), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 4, 3, getCellText(tf4Ma3, tf4Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 15), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 5, 3, getCellText(tf5Ma3, tf5Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 16), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 6, 3, getCellText(tf6Ma3, tf6Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 17), text_color=textColor, text_size=getSize(textSizeInput))

    table.cell(dashboard, 0, 4, maLabel + str.tostring(ema4Len), bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 1, 4, getCellText(tf1Ma4, tf1Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 18), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 2, 4, getCellText(tf2Ma4, tf2Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 19), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 3, 4, getCellText(tf3Ma4, tf3Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 20), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 4, 4, getCellText(tf4Ma4, tf4Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 21), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 5, 4, getCellText(tf5Ma4, tf5Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 22), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 6, 4, getCellText(tf6Ma4, tf6Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 23), text_color=textColor, text_size=getSize(textSizeInput))

    table.cell(dashboard, 0, 5, maLabel + str.tostring(ema5Len), bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 1, 5, getCellText(tf1Ma5, tf1Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 24), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 2, 5, getCellText(tf2Ma5, tf2Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 25), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 3, 5, getCellText(tf3Ma5, tf3Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 26), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 4, 5, getCellText(tf4Ma5, tf4Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 27), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 5, 5, getCellText(tf5Ma5, tf5Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 28), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 6, 5, getCellText(tf6Ma5, tf6Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 29), text_color=textColor, text_size=getSize(textSizeInput))

    table.cell(dashboard, 0, 6, maLabel + str.tostring(ema6Len), bgcolor=neutralColor, text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 1, 6, getCellText(tf1Ma6, tf1Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 30), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 2, 6, getCellText(tf2Ma6, tf2Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 31), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 3, 6, getCellText(tf3Ma6, tf3Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 32), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 4, 6, getCellText(tf4Ma6, tf4Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 33), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 5, 6, getCellText(tf5Ma6, tf5Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 34), text_color=textColor, text_size=getSize(textSizeInput))
    table.cell(dashboard, 6, 6, getCellText(tf6Ma6, tf6Close), bgcolor=getClusterCellColor(clusterIds, clusterSizes, uniqueClusterIds, 35), text_color=textColor, text_size=getSize(textSizeInput))
````
