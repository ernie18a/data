# Custom 4 MA & Probability (KenshinC) [English]

- url: https://www.tradingview.com/script/tfA1MYS1-Custom-4-MA-Probability-KenshinC-English/
- type: indicator
- pine_id: PUB;e9ba03f8318c4d06884354c37fcc5fd6
- version: 1.0

## Description

[b]Custom 4 MA - Fast / Normal / Slow / Super Slow with Deviation Analysis[/b]
This powerful multi-timeframe moving average indicator combines four strategically chosen Simple Moving Averages with advanced deviation analysis to help traders identify extreme price levels and mean-reversion opportunities.Key Features:Flexible MA Modes: Choose between calculating All 4 MAs simultaneously or Single MA Only for cleaner charts and better performance.
Four Strategic Periods:Fast MA (16) – Short-term momentum
Normal MA (100) – Medium-term trend
Slow MA (365) – Long-term trend (approximately 1 year on daily)
Super Slow MA (1460) – Very long-term trend (approximately 4–5 years on daily)

[b]Advanced Deviation Analysis: [/b]
Automatically detects and tracks the strongest Top and Bottom percentage deviations from each MA within a configurable lookback window.
Visual Extreme Levels: Displays dashed horizontal lines for the top 5 highest and lowest deviation levels of each active MA, making overextended zones clearly visible.
Historical Labels: Marks significant Top and Bottom deviation points directly on the chart with detailed information (price + % deviation).
Statistics Table: Real-time table showing Start Date, Candles Above/Below MA, and percentage distribution for each active MA.
Fully Customizable: Colors, label sizes, number of extreme points, and lookback period are all adjustable.

[b]Ideal For:[/b]
Mean-reversion traders
Swing and position traders
Traders who use multiple timeframe moving averages
Identifying high-probability reversal zones when price deviates significantly from long-term averages

Whether you're trading breakouts, pullbacks, or looking for exhaustion points, this indicator provides clear visual references for both trend strength and extreme price behavior.

## Source Code

````pine
//@version=5
indicator("Custom 4 MA & Probability (KenshinC) [English]", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
calcMode = input.string("All 4 MA", "Calculation Mode", 
     options=["All 4 MA", "Single MA Only"], group="General Settings")

singleMA = input.string("Slow", "Select MA (when using Single Mode)", 
     options=["Fast", "Normal", "Slow", "Super Slow"], group="General Settings")

// MA Lengths
fastLen   = input.int(16,   "Fast MA Length",   minval=1, group="MA Settings")
normalLen = input.int(100,  "Normal MA Length", minval=1, group="MA Settings")
slowLen   = input.int(365,  "Slow MA Length",   minval=1, group="MA Settings")
superLen  = input.int(1460, "Super Slow MA Length", minval=1, group="MA Settings")

// Display Options
showFast   = input.bool(true, "Show Fast MA",   group="MA Display")
showNormal = input.bool(true, "Show Normal MA", group="MA Display")
showSlow   = input.bool(true, "Show Slow MA",   group="MA Display")
showSuper  = input.bool(true, "Show Super Slow MA", group="MA Display")

// Colors
fastLineColor   = input.color(color.blue,    "Fast MA Color",   group="Line Colors")
normalLineColor = input.color(color.orange,  "Normal MA Color", group="Line Colors")
slowLineColor   = input.color(color.red,     "Slow MA Color",   group="Line Colors")
superLineColor  = input.color(color.purple,  "Super Slow MA Color", group="Line Colors")

fastTopColor   = input.color(color.new(#00FF00, 0), "Fast Top Line Color",   group="Line Colors")
fastBotColor   = input.color(color.new(#FF0000, 0), "Fast Bottom Line Color", group="Line Colors")
normalTopColor = input.color(color.new(#00AAFF, 0), "Normal Top Line Color", group="Line Colors")
normalBotColor = input.color(color.new(#FF00AA, 0), "Normal Bottom Line Color", group="Line Colors")
slowTopColor   = input.color(color.new(#AAFF00, 0), "Slow Top Line Color",   group="Line Colors")
slowBotColor   = input.color(color.new(#FFAA00, 0), "Slow Bottom Line Color", group="Line Colors")
superTopColor  = input.color(color.new(#FF00FF, 0), "Super Slow Top Line Color", group="Line Colors")
superBotColor  = input.color(color.new(#00FFFF, 0), "Super Slow Bottom Line Color", group="Line Colors")

// Deviation Settings
lookbackPeriod = input.int(75,  "Lookback Period (bars)", minval=10, maxval=150, group="Deviation Settings")
numPoints      = input.int(10,  "Number of Top/Bottom Points", minval=1, maxval=20, group="Deviation Settings")

// Label Settings
labelSizeStr   = input.string("Normal", "Label Size", options=["Tiny","Small","Normal","Large","Huge","Auto"], group="Label Settings")
labelColorTop  = input.color(color.black, "Top Label Text Color", group="Label Settings")
labelColorBot  = input.color(color.black, "Bottom Label Text Color", group="Label Settings")
bgColorTop     = input.color(color.new(color.green, 40), "Top Label Background", group="Label Settings")
bgColorBot     = input.color(color.new(color.red, 40), "Bottom Label Background", group="Label Settings")

// ─────────────────────────────────────────────────────────────
// DETERMINE WHICH MA TO CALCULATE
// ─────────────────────────────────────────────────────────────
bool useFast   = calcMode == "All 4 MA" ? showFast   : (singleMA == "Fast")
bool useNormal = calcMode == "All 4 MA" ? showNormal : (singleMA == "Normal")
bool useSlow   = calcMode == "All 4 MA" ? showSlow   : (singleMA == "Slow")
bool useSuper  = calcMode == "All 4 MA" ? showSuper  : (singleMA == "Super Slow")

// ─────────────────────────────────────────────────────────────
// USER-DEFINED TYPE
// ─────────────────────────────────────────────────────────────
type MAData
    int          startDate
    int          candlesAbove
    int          candlesBelow
    array<float> deviationBuffer
    array<float> topDeviations
    array<int>   topBars
    array<float> topPrices
    array<float> bottomDeviations
    array<int>   bottomBars
    array<float> bottomPrices

var array<MAData> maDataArray = array.new<MAData>()

if barstate.isfirst
    for i = 0 to 3
        data = MAData.new(na, 0, 0, array.new_float(201, 0.0), array.new_float(numPoints, 0.0), array.new_int(numPoints, 0), array.new_float(numPoints, 0.0), array.new_float(numPoints, 0.0), array.new_int(numPoints, 0), array.new_float(numPoints, 0.0))
        array.push(maDataArray, data)

maNames      = array.from("Fast", "Normal", "Slow", "Super Slow")
maLineColors = array.from(fastLineColor, normalLineColor, slowLineColor, superLineColor)
maTopColors  = array.from(fastTopColor, normalTopColor, slowTopColor, superTopColor)
maBotColors  = array.from(fastBotColor, normalBotColor, slowBotColor, superBotColor)

// ─────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────
getLabelSize(str) =>
    switch str
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.auto

updateArray(array<float> deviations, array<int> bars, array<float> prices, int index, float value, int currentBar, float currentPrice) =>
    if index < array.size(deviations) - 1
        for i = array.size(deviations) - 2 to index
            array.set(deviations, i + 1, array.get(deviations, i))
            array.set(bars, i + 1, array.get(bars, i))
            array.set(prices, i + 1, array.get(prices, i))
    array.set(deviations, index, value)
    array.set(bars, index, currentBar)
    array.set(prices, index, currentPrice)

processMA(int maIdx, float ma) =>
    if na(ma)
        na
    MAData data = array.get(maDataArray, maIdx)
    float deviationPercent = ma != 0 ? (close - ma) / ma * 100 : 0.0
    array.unshift(data.deviationBuffer, deviationPercent)
    if array.size(data.deviationBuffer) > 201
        array.pop(data.deviationBuffer)

    if barstate.isconfirmed and bar_index > lookbackPeriod and array.size(data.deviationBuffer) > lookbackPeriod * 2
        bool isMax = true
        bool isMin = true
        float currentDev = array.get(data.deviationBuffer, lookbackPeriod)
        for i = 0 to lookbackPeriod * 2
            if i != lookbackPeriod
                float checkDev = array.get(data.deviationBuffer, i)
                if not na(checkDev)
                    if checkDev > currentDev
                        isMax := false
                    if checkDev < currentDev
                        isMin := false
        if close > ma and isMax
            for j = 0 to numPoints - 1
                if currentDev > array.get(data.topDeviations, j)
                    updateArray(data.topDeviations, data.topBars, data.topPrices, j, currentDev, bar_index - lookbackPeriod, close[lookbackPeriod])
                    break
        if close < ma and isMin
            for j = 0 to numPoints - 1
                if currentDev < array.get(data.bottomDeviations, j)
                    updateArray(data.bottomDeviations, data.bottomBars, data.bottomPrices, j, currentDev, bar_index - lookbackPeriod, close[lookbackPeriod])
                    break

drawLabels(int maIdx, string maName) =>
    MAData data = array.get(maDataArray, maIdx)
    for i = 0 to numPoints - 1
        float tDev = array.get(data.topDeviations, i)
        if tDev > 0 and not na(tDev)
            label.new(array.get(data.topBars, i), array.get(data.topPrices, i), 
                 text = maName + " Top " + str.tostring(i + 1) + "\nPrice: " + str.tostring(array.get(data.topPrices, i), "#.##") + "\n+" + str.tostring(math.round(tDev, 2)) + "%", 
                 color = bgColorTop, style = label.style_label_down, textcolor = labelColorTop, size = getLabelSize(labelSizeStr))
        float bDev = array.get(data.bottomDeviations, i)
        if bDev < 0 and not na(bDev)
            label.new(array.get(data.bottomBars, i), array.get(data.bottomPrices, i), 
                 text = maName + " Bot " + str.tostring(i + 1) + "\nPrice: " + str.tostring(array.get(data.bottomPrices, i), "#.##") + "\n" + str.tostring(math.round(bDev, 2)) + "%", 
                 color = bgColorBot, style = label.style_label_up, textcolor = labelColorBot, size = getLabelSize(labelSizeStr))

// ─────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────
float maFast   = useFast   ? ta.sma(close, fastLen)   : na
float maNormal = useNormal ? ta.sma(close, normalLen) : na
float maSlow   = useSlow   ? ta.sma(close, slowLen)   : na
float maSuper  = useSuper  ? ta.sma(close, superLen)  : na

mas = array.from(maFast, maNormal, maSlow, maSuper)

// Process each MA
for i = 0 to 3
    if (i == 0 and useFast) or (i == 1 and useNormal) or (i == 2 and useSlow) or (i == 3 and useSuper)
        MAData data = array.get(maDataArray, i)
        float ma = array.get(mas, i)
        if na(data.startDate) and not na(ma)
            data.startDate := time
        if not na(ma)
            if close > ma
                data.candlesAbove += 1
            else
                data.candlesBelow += 1
        processMA(i, ma)

// ─────────────────────────────────────────────────────────────
// PLOT MA LINES
// ─────────────────────────────────────────────────────────────
plot(useFast   ? maFast   : na, title="Fast MA",     color=fastLineColor,   linewidth=2)
plot(useNormal ? maNormal : na, title="Normal MA",   color=normalLineColor, linewidth=2)
plot(useSlow   ? maSlow   : na, title="Slow MA",     color=slowLineColor,   linewidth=2)
plot(useSuper  ? maSuper  : na, title="Super Slow MA", color=superLineColor, linewidth=2)

// ─────────────────────────────────────────────────────────────
// TABLE, LINES & LABELS (Last Bar Only)
// ─────────────────────────────────────────────────────────────
var table maTable = table.new(position.top_right, 2, 20, border_width = 1, bgcolor = color.new(color.white, 80))

if barstate.islast
    table.clear(maTable, 0, 0, 1, 19)
    
    int row = 0
    for i = 0 to 3
        bool shouldShow = (i == 0 and useFast) or (i == 1 and useNormal) or (i == 2 and useSlow) or (i == 3 and useSuper)
        if shouldShow
            MAData data = array.get(maDataArray, i)
            string name = array.get(maNames, i)
            int total = data.candlesAbove + data.candlesBelow
            float pAbove = total > 0 ? math.round(data.candlesAbove * 100.0 / total, 2) : 0.0
            color maCol = array.get(maLineColors, i)
            
            table.cell(maTable, 0, row, name + " - Start Date:", bgcolor = color.new(maCol, 85), text_color = color.black)
            table.cell(maTable, 1, row, na(data.startDate) ? "Calculating..." : str.format("{0,date,yyyy-MM-dd}", data.startDate), bgcolor = color.new(maCol, 85), text_color = color.black)
            row += 1

            table.cell(maTable, 0, row, name + " - Candles Above/Below:", bgcolor = color.new(maCol, 85), text_color = color.black)
            table.cell(maTable, 1, row, str.tostring(data.candlesAbove) + "/" + str.tostring(data.candlesBelow) + " (" + str.tostring(pAbove) + "% / " + str.tostring(100 - pAbove) + "%)", bgcolor = color.new(maCol, 85), text_color = color.black)
            row += 1

            table.cell(maTable, 0, row, name + " - Total Candles:", bgcolor = color.new(maCol, 85), text_color = color.black)
            table.cell(maTable, 1, row, str.tostring(total) + " candles", bgcolor = color.new(maCol, 85), text_color = color.black)
            row += 2

    // Draw Top/Bottom Lines
    for i = 0 to 3
        bool shouldShow = (i == 0 and useFast) or (i == 1 and useNormal) or (i == 2 and useSlow) or (i == 3 and useSuper)
        if shouldShow
            MAData data = array.get(maDataArray, i)
            float maVal = array.get(mas, i)
            for j = 0 to 4
                float dev = array.get(data.topDeviations, j)
                if not na(dev) and dev > 0
                    float level = maVal * (1 + dev / 100)
                    line.new(bar_index - 50, level, bar_index, level, color = array.get(maTopColors, i), style = line.style_dashed, width = 2)
                    label.new(bar_index, level, array.get(maNames, i) + " Top " + str.tostring(j+1), color = array.get(maTopColors, i), textcolor = color.white, style = label.style_label_left, size = size.small)
            for j = 0 to 4
                float dev = array.get(data.bottomDeviations, j)
                if not na(dev) and dev < 0
                    float level = maVal * (1 + dev / 100)
                    line.new(bar_index - 50, level, bar_index, level, color = array.get(maBotColors, i), style = line.style_dashed, width = 2)
                    label.new(bar_index, level, array.get(maNames, i) + " Bot " + str.tostring(j+1), color = array.get(maBotColors, i), textcolor = color.white, style = label.style_label_left, size = size.small)

    // Draw Historical Labels
    for i = 0 to 3
        bool shouldShow = (i == 0 and useFast) or (i == 1 and useNormal) or (i == 2 and useSlow) or (i == 3 and useSuper)
        if shouldShow
            drawLabels(i, array.get(maNames, i))
````
