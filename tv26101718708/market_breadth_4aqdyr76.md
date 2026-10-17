# Market Breadth

- url: https://www.tradingview.com/script/4aQDyR76-Market-Breadth/
- type: indicator
- pine_id: PUB;6b8cc6bea4b34a7c92793469e3c08d94
- version: 1.0

## Description

This script is an Advanced Market Breadth Dashboard that tracks the true underlying strength of the stock market by analyzing Up Volume versus Down Volume.

Specifically, it monitors three major exchanges—NYSE, NASDAQ, and ARCA—and provides:

Smart Ratios: A visual oscillator that plots bullish volume (more Up Volume) as positive numbers and bearish volume (more Down Volume) as negative numbers around a clear zero line.

Momentum Histogram: A color-coded histogram showing whether market breadth is gaining or losing momentum.

Real-Time Data Table: An on-chart dashboard displaying live Up/Down volume ratios, volume percentages, raw volume numbers, and a dynamic "Market State" assessment (e.g., Bullish, Neutral, Bearish).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © iMetaX

//@version=6
indicator("Market Breadth", overlay=false)

// Input parameters
showZeroLine = input.bool(true, "Show Zero Line")
showTable = input.bool(true, "Show Table")
market = input.string("NYSE", "Market", options=["NYSE", "NASDAQ", "ARCA", "AVG"])

// Plot visibility options
plotStyle = input.string("All Lines", "Plot Style", 
     options=["All Lines", "Histogram Only", "Selected Line Only", "Histogram + Selected Line", "Clean Mode"], display=display.none)
lineWidth = input.int(2, "Line Width", minval=1, maxval=5, display = display.none)
histogramOpacity = input.int(60, "Histogram Opacity %", minval=0, maxval=100, step=10, display = display.none)

tablePosition = input.string("top_right", "Table Position", 
     options=["top_left", "top_center", "top_right", 
              "middle_left", "middle_center", "middle_right", 
              "bottom_left", "bottom_center", "bottom_right"], display=display.none)
textSize = input.string("small", "Text Size", 
     options=["tiny", "small", "normal", "large", "huge", "auto"], display=display.none)

// Get volume data for different exchanges
// NYSE
UVOL = request.security("USI:UVOL", timeframe.period, close)
DVOL = request.security("USI:DVOL", timeframe.period, close)

// NASDAQ
UVOLQ = request.security("USI:UVOLQ", timeframe.period, close)
DVOLQ = request.security("USI:DVOLQ", timeframe.period, close)

// ARCA
UVOLA = request.security("USI:UVOLA", timeframe.period, close)
DVOLA = request.security("USI:DVOLA", timeframe.period, close)

// Select market volumes based on input
upVolMarket = switch market
    "NYSE" => UVOL
    "NASDAQ" => UVOLQ
    "ARCA" => UVOLA
    "AVG" => UVOL + UVOLQ + UVOLA

downVolMarket = switch market
    "NYSE" => DVOL
    "NASDAQ" => DVOLQ
    "ARCA" => DVOLA
    "AVG" => DVOL + DVOLQ + DVOLA

// Calculate total volume and % Up Volume for selected market
totalVolumeSelected = upVolMarket + downVolMarket
selectedDataValid = totalVolumeSelected > 1000 and downVolMarket > 100 and upVolMarket > 100
percentUpVolSelected = selectedDataValid ? 
     upVolMarket / totalVolumeSelected : na

// Calculate ratios for each exchange with error handling
// NYSE
nyseDataValid = (DVOL > 100 and UVOL > 100)
NYSEratio = if nyseDataValid
    UVOL >= DVOL ? math.min(UVOL / DVOL, 99.99) : math.max(-(DVOL / UVOL), -99.99)
else
    na
totalNYSE = UVOL + DVOL
pctUpNYSE = nyseDataValid and totalNYSE > 1000 ? UVOL / totalNYSE : na

// NASDAQ
nasdDataValid = (DVOLQ > 100 and UVOLQ > 100)
NASDratio = if nasdDataValid
    UVOLQ >= DVOLQ ? math.min(UVOLQ / DVOLQ, 99.99) : math.max(-(DVOLQ / UVOLQ), -99.99)
else
    na
totalNASD = UVOLQ + DVOLQ
pctUpNASD = nasdDataValid and totalNASD > 1000 ? UVOLQ / totalNASD : na

// ARCA
arcaDataValid = (DVOLA > 100 and UVOLA > 100)
ARCAratio = if arcaDataValid
    UVOLA >= DVOLA ? math.min(UVOLA / DVOLA, 99.99) : math.max(-(DVOLA / UVOLA), -99.99)
else
    na
totalARCA = UVOLA + DVOLA
pctUpARCA = arcaDataValid and totalARCA > 1000 ? UVOLA / totalARCA : na

// Average ratio - only calculate if at least one exchange has valid data
validExchanges = (nyseDataValid ? 1 : 0) + (nasdDataValid ? 1 : 0) + (arcaDataValid ? 1 : 0)
AVGratio = validExchanges > 0 ? (nz(NYSEratio, 0) + nz(NASDratio, 0) + nz(ARCAratio, 0)) / validExchanges : na

// Color functions
getPercentColor(pct) =>
    if pct >= 0.60
        color.green
    else if pct >= 0.50
        color.new(color.green, 30)
    else if pct >= 0.40
        color.new(color.orange, 30)
    else
        color.red

getRatioColor(ratio) =>
    if ratio >= 2
        color.green
    else if ratio >= 0
        color.new(color.green, 30)
    else if ratio <= -2
        color.red
    else
        color.new(color.orange, 30)

// Convert table position string to position
getTablePosition(pos) =>
    switch pos
        "top_left" => position.top_left
        "top_center" => position.top_center
        "top_right" => position.top_right
        "middle_left" => position.middle_left
        "middle_center" => position.middle_center
        "middle_right" => position.middle_right
        "bottom_left" => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right" => position.bottom_right
        => position.top_right

// Convert text size string to size
getTextSize(size) =>
    switch size
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        "huge" => size.huge
        "auto" => size.auto
        => size.normal

// Create table - AUTO ADAPTS TO THEME & BLOCKS LINES
var table breadthTable = table.new(
     getTablePosition(tablePosition), 5, 6, 
     bgcolor=chart.bg_color, // <-- This makes the background solid!
     border_width=1, 
     border_color=color.new(chart.fg_color, 80))

// Update table
if barstate.islast and showTable
    // Headers
    table.cell(breadthTable, 0, 0, "Exchange", 
         text_color=chart.fg_color, 
         bgcolor=color.new(color.blue, 80),
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 1, 0, "Ratio", 
         text_color=chart.fg_color, 
         bgcolor=color.new(color.blue, 80),
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 2, 0, "% Up Vol", 
         text_color=chart.fg_color, 
         bgcolor=color.new(color.blue, 80),
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 3, 0, "Up Volume", 
         text_color=chart.fg_color, 
         bgcolor=color.new(color.blue, 80),
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 4, 0, "Down Volume", 
         text_color=chart.fg_color, 
         bgcolor=color.new(color.blue, 80),
         text_size=getTextSize(textSize))
    
    // NYSE Row
    nyseRatioStr = if nyseDataValid and not na(NYSEratio)
        str.tostring(NYSEratio, "#.##") + ":1"
    else
        "---"
    nysePctStr = if nyseDataValid and not na(pctUpNYSE)
        str.tostring(pctUpNYSE * 100, "#.#") + "%"
    else
        "---"
        
    table.cell(breadthTable, 0, 1, "NYSE", 
         text_color=color.rgb(0, 153, 0), // Updated to high-contrast Green
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 1, 1, nyseRatioStr, 
         text_color=chart.fg_color, 
         bgcolor=nyseDataValid and not na(NYSEratio) ? getRatioColor(NYSEratio) : color.gray,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 2, 1, nysePctStr, 
         text_color=chart.fg_color, 
         bgcolor=nyseDataValid and not na(pctUpNYSE) ? getPercentColor(pctUpNYSE) : color.gray,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 3, 1, 
         UVOL > 0 ? str.tostring(UVOL/1000000, "#.#") + "M" : "0M", 
         text_color=chart.fg_color,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 4, 1, 
         DVOL > 0 ? str.tostring(DVOL/1000000, "#.#") + "M" : "0M", 
         text_color=chart.fg_color,
         text_size=getTextSize(textSize))
    
    // NASDAQ Row
    nasdRatioStr = if nasdDataValid and not na(NASDratio)
        str.tostring(NASDratio, "#.##") + ":1"
    else
        "---"
    nasdPctStr = if nasdDataValid and not na(pctUpNASD)
        str.tostring(pctUpNASD * 100, "#.#") + "%"
    else
        "---"
        
    table.cell(breadthTable, 0, 2, "NASDAQ", 
         text_color=color.rgb(255, 179, 0), // High-contrast Gold
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 1, 2, nasdRatioStr, 
         text_color=chart.fg_color, 
         bgcolor=nasdDataValid and not na(NASDratio) ? getRatioColor(NASDratio) : color.gray,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 2, 2, nasdPctStr, 
         text_color=chart.fg_color, 
         bgcolor=nasdDataValid and not na(pctUpNASD) ? getPercentColor(pctUpNASD) : color.gray,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 3, 2, 
         UVOLQ > 0 ? str.tostring(UVOLQ/1000000, "#.#") + "M" : "0M", 
         text_color=chart.fg_color,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 4, 2, 
         DVOLQ > 0 ? str.tostring(DVOLQ/1000000, "#.#") + "M" : "0M", 
         text_color=chart.fg_color,
         text_size=getTextSize(textSize))
    
    // ARCA Row
    arcaRatioStr = if arcaDataValid and not na(ARCAratio)
        str.tostring(ARCAratio, "#.##") + ":1"
    else
        "---"
    arcaPctStr = if arcaDataValid and not na(pctUpARCA)
        str.tostring(pctUpARCA * 100, "#.#") + "%"
    else
        "---"
        
    table.cell(breadthTable, 0, 3, "ARCA", 
         text_color=color.new(color.red, 30),
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 1, 3, arcaRatioStr, 
         text_color=chart.fg_color, 
         bgcolor=arcaDataValid and not na(ARCAratio) ? getRatioColor(ARCAratio) : color.gray,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 2, 3, arcaPctStr, 
         text_color=chart.fg_color, 
         bgcolor=arcaDataValid and not na(pctUpARCA) ? getPercentColor(pctUpARCA) : color.gray,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 3, 3, 
         UVOLA > 0 ? str.tostring(UVOLA/1000000, "#.#") + "M" : "0M", 
         text_color=chart.fg_color,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 4, 3, 
         DVOLA > 0 ? str.tostring(DVOLA/1000000, "#.#") + "M" : "0M", 
         text_color=chart.fg_color,
         text_size=getTextSize(textSize))
    
    // Average Row
    totalUpVol = UVOL + UVOLQ + UVOLA
    totalDownVol = DVOL + DVOLQ + DVOLA
    totalAllVol = totalUpVol + totalDownVol
    pctUpAvg = totalAllVol > 1000 ? 
         totalUpVol / totalAllVol : na
    avgDataValid = validExchanges > 0 and not na(AVGratio)
    
    avgRatioStr = if avgDataValid
        str.tostring(AVGratio, "#.##") + ":1"
    else
        "---"
    avgPctStr = if not na(pctUpAvg)
        str.tostring(pctUpAvg * 100, "#.#") + "%"
    else
        "---"
    
    table.cell(breadthTable, 0, 4, "AVERAGE", 
         text_color=chart.fg_color, 
         bgcolor=color.new(chart.fg_color, 85),
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 1, 4, avgRatioStr, 
         text_color=chart.fg_color, 
         bgcolor=avgDataValid ? getRatioColor(AVGratio) : color.gray,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 2, 4, avgPctStr, 
         text_color=chart.fg_color, 
         bgcolor=not na(pctUpAvg) ? getPercentColor(pctUpAvg) : color.gray,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 3, 4, 
         totalUpVol > 0 ? str.tostring(totalUpVol/1000000, "#.#") + "M" : "0M", 
         text_color=chart.fg_color,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 4, 4, 
         totalDownVol > 0 ? str.tostring(totalDownVol/1000000, "#.#") + "M" : "0M", 
         text_color=chart.fg_color,
         text_size=getTextSize(textSize))
    
    // Selected Market State
    marketState = if selectedDataValid
        percentUpVolSelected >= 0.60 ? "BULLISH" :  percentUpVolSelected >= 0.50 ? "MILD BULL" : percentUpVolSelected >= 0.40 ? "NEUTRAL" : "BEARISH"
    else
        "NO DATA"
    
    stateColor = if selectedDataValid
        percentUpVolSelected >= 0.60 ? color.green :  percentUpVolSelected >= 0.50 ? color.new(color.green, 30) : percentUpVolSelected >= 0.40 ? color.orange : color.red
    else
        color.gray
    
    table.cell(breadthTable, 0, 5, market + ":", 
         text_color=chart.fg_color,
         bgcolor=color.new(color.blue, 90),
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 1, 5, marketState, 
         text_color=chart.fg_color, 
         bgcolor=stateColor,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 2, 5, 
         selectedDataValid ? str.tostring(percentUpVolSelected * 100, "#.#") + "%" : "---", 
         text_color=chart.fg_color, 
         bgcolor=stateColor,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 3, 5, "", 
         bgcolor=stateColor,
         text_size=getTextSize(textSize))
    table.cell(breadthTable, 4, 5, "", 
         bgcolor=stateColor,
         text_size=getTextSize(textSize))

// Plot settings based on style selection
showAllLines = plotStyle == "All Lines"
showSelectedLine = plotStyle == "Selected Line Only" or plotStyle == "Histogram + Selected Line"
showCleanMode = plotStyle == "Clean Mode"
showHistogram = plotStyle != "Selected Line Only" and plotStyle != "Clean Mode"

// Determine which lines to show
showNYSE = showAllLines or (showSelectedLine and market == "NYSE") or showCleanMode
showNASDAQ = showAllLines or (showSelectedLine and market == "NASDAQ") or showCleanMode  
showARCA = showAllLines or (showSelectedLine and market == "ARCA") or showCleanMode

// Line appearance
nyseColor = showCleanMode ? color.new(color.rgb(0, 153, 0), 70) : color.rgb(0, 153, 0) // Updated to high-contrast Green
nasdColor = showCleanMode ? color.new(color.rgb(255, 179, 0), 70) : color.rgb(255, 179, 0) // High-contrast Gold
arcaColor = showCleanMode ? color.new(color.red, 50) : color.new(color.red, 30)
actualLineWidth = showCleanMode ? 1 : lineWidth

// Plot the ratios as lines (will show gaps when data is invalid)
plotNYSE = showNYSE ? NYSEratio : na
plotNASD = showNASDAQ ? NASDratio : na
plotARCA = showARCA ? ARCAratio : na

plot(plotNYSE, "NYSE Ratio", color=nyseColor, linewidth=actualLineWidth, style=plot.style_line)
plot(plotNASD, "NASDAQ Ratio", color=nasdColor, linewidth=actualLineWidth, style=plot.style_line)
plot(plotARCA, "ARCA Ratio", color=arcaColor, linewidth=actualLineWidth, style=plot.style_line)

// Plot histogram for selected market (will show gaps when data is invalid)
Breadth = market == "NYSE" ? NYSEratio :
          market == "NASDAQ" ? NASDratio :
          market == "ARCA" ? ARCAratio : AVGratio

histColorBase = if na(Breadth)
    color.gray
else
    Breadth >= 0 ?  (Breadth > Breadth[1] ? color.green : color.gray) : (Breadth < Breadth[1] ? color.fuchsia : color.gray)
              
histColor = color.new(histColorBase, 100 - histogramOpacity)

plot(showHistogram and not na(Breadth) ? Breadth : na, "Market Breadth", 
     style=plot.style_histogram, color=histColor, linewidth=1)

// Zero line
zeroLineColor = showCleanMode ? color.new(color.rgb(255, 179, 0), 50) : color.rgb(255, 179, 0) // Matched the Zero line to the new Gold
hline(showZeroLine ? 0 : na, "Zero Line", color=zeroLineColor, 
      linestyle=hline.style_solid)
````
