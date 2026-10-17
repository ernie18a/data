# MACD Histogram Cross

- url: https://www.tradingview.com/script/nZhd9znP-MACD-Histogram-Cross/
- type: indicator
- pine_id: PUB;9a9c7bddce80429288a349e071cabea6
- version: 1.0

## Description

The MACD Histogram Cross indicates where the histogram crosses the zero line and plots it on the candle chart. I use it with a fast moving average on smooth trending lower timeframes, and analysis on higher timeframes where price movement is more prominent. It is set to the standard MACD setting. Sometimes I use the 5,15,9 agressive setting. NOTE: This is only an indicator. It only indicates a swing in price action. Its not meant to be an entry signal or risk management although I use it in alerts. Use at own discretion. Trading is risky.

## Source Code

````pine
//@version=6
indicator("MACD Histogram Cross", overlay=true)

// ===== USER INPUTS =====
// MACD Settings
fastLength = input.int(12, "Fast Length", minval=1, maxval=100)
slowLength = input.int(26, "Slow Length", minval=1, maxval=200)
signalLength = input.int(9, "Signal Smoothing", minval=1, maxval=50)

// Arrow Settings
showArrows = input.bool(true, "Show Cross Arrows")
arrowSize = input.string("Small", "Arrow Size", options=["Tiny", "Small", "Normal"])

// ===== MACD CALCULATION =====
[macdLine, signalLine, histLine] = ta.macd(close, fastLength, slowLength, signalLength)

// ===== CROSS DETECTION =====
// Cross above zero (histogram goes from negative to positive)
crossAboveZero = histLine > 0 and histLine[1] <= 0

// Cross below zero (histogram goes from positive to negative)
crossBelowZero = histLine < 0 and histLine[1] >= 0

// ===== PLOTTING =====
// Determine if we should plot based on arrow size selection
plotTiny = arrowSize == "Tiny"
plotSmall = arrowSize == "Small"
plotNormal = arrowSize == "Normal"

// Plot green arrow BELOW the candle for cross above zero (bullish)
plotshape(showArrows and crossAboveZero and plotTiny, 
         style=shape.triangleup, location=location.belowbar, 
         color=color.new(color.green, 0), size=size.tiny, title="Cross Above Zero Tiny")

plotshape(showArrows and crossAboveZero and plotSmall, 
         style=shape.triangleup, location=location.belowbar, 
         color=color.new(color.green, 0), size=size.small, title="Cross Above Zero Small")

plotshape(showArrows and crossAboveZero and plotNormal, 
         style=shape.triangleup, location=location.belowbar, 
         color=color.new(color.green, 0), size=size.normal, title="Cross Above Zero Normal")

// Plot red arrow ABOVE the candle for cross below zero (bearish)
plotshape(showArrows and crossBelowZero and plotTiny, 
         style=shape.triangledown, location=location.abovebar, 
         color=color.new(color.red, 0), size=size.tiny, title="Cross Below Zero Tiny")

plotshape(showArrows and crossBelowZero and plotSmall, 
         style=shape.triangledown, location=location.abovebar, 
         color=color.new(color.red, 0), size=size.small, title="Cross Below Zero Small")

plotshape(showArrows and crossBelowZero and plotNormal, 
         style=shape.triangledown, location=location.abovebar, 
         color=color.new(color.red, 0), size=size.normal, title="Cross Below Zero Normal")

// ===== MACD INDICATOR IN SEPARATE PANE (Optional) =====
// Uncomment the lines below to see the MACD in a separate pane
// plot(macdLine, color=color.new(color.blue, 0), title="MACD Line")
// plot(signalLine, color=color.new(color.orange, 0), title="Signal Line")
// histColor = histLine >= 0 ? color.green : color.red
// plot(histLine, style=plot.style_columns, color=histColor, title="Histogram")
// hline(0, color=color.new(color.gray, 50), linestyle=hline.style_dotted, title="Zero Line")

// ===== INFO TABLE =====
var table infoTable = table.new(position.top_right, 2, 5, border_width=1, bgcolor=color.new(color.gray, 85))

if barstate.islast
    table.cell(infoTable, 0, 0, "MACD Histogram Cross", text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.gray, 70))
    table.cell(infoTable, 1, 0, "", text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.gray, 70))
    
    table.cell(infoTable, 0, 1, "MACD Settings", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    table.cell(infoTable, 1, 1, str.tostring(fastLength) + "/" + str.tostring(slowLength) + "/" + str.tostring(signalLength), text_color=color.white, text_size=size.small)
    
    table.cell(infoTable, 0, 2, "Current Histogram", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    histColor = histLine >= 0 ? color.green : color.red
    table.cell(infoTable, 1, 2, str.tostring(histLine), text_color=histColor, text_size=size.small)
    
    table.cell(infoTable, 0, 3, "Last Signal", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    lastSignal = crossAboveZero ? "Cross Above Zero ▲" : crossBelowZero ? "Cross Below Zero ▼" : "No Signal"
    signalColor = crossAboveZero ? color.green : crossBelowZero ? color.red : color.gray
    table.cell(infoTable, 1, 3, lastSignal, text_color=signalColor, text_size=size.small)
    
    table.cell(infoTable, 0, 4, "Arrow Size", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    table.cell(infoTable, 1, 4, arrowSize, text_color=color.white, text_size=size.small)

// ===== ALERTS =====
alertcondition(crossAboveZero, "MACD Cross Above Zero", "MACD histogram has crossed above the zero line (Bullish)")
alertcondition(crossBelowZero, "MACD Cross Below Zero", "MACD histogram has crossed below the zero line (Bearish)")
````
