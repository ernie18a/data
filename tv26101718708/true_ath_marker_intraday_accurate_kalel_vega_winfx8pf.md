# True ATH Marker - Intraday Accurate - Kalel Vega

- url: https://www.tradingview.com/script/wiNfX8pF/
- type: indicator
- pine_id: PUB;54778097ab4a4994a3ceaa8add582982
- version: 1.0

## Description

True ATH Marker is a TradingView indicator that dynamically plots the current All-Time High based on the intraday price data available on the chart. It updates bar by bar without relying on higher-timeframe candles, avoiding session or HTF mismatches during replay and intraday analysis. The ATH line stays anchored to the exact price level and extends to the right with a customizable label.

## Source Code

````pine
//@version=6
indicator("True ATH Marker - Intraday Accurate - Kalel Vega", overlay=true, scale=scale.right, max_lines_count=10, max_labels_count=10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lineColor   = input.color(color.black, "Line Color")
lineWidth   = input.int(1, "Ancho de línea", minval=1, maxval=5)
labelColor  = input.color(color.rgb(45, 50, 65), "Label Color")
textColor   = input.color(color.white, "Label Text Color")
labelOffset = input.int(10, "Label Offset Bars", minval=0, maxval=500)
labelText   = input.string("ATH", "Texto de etiqueta")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATH calculado barra por barra
// No usa HTF, por tanto no tiene desfase con PDH/session highs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float athPrice = na
var int   athTime  = na

if na(athPrice) or high > athPrice
    athPrice := high
    athTime  := time

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Línea y etiqueta
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line athLine = na
var label athLabel = na

barSeconds = timeframe.in_seconds(timeframe.period)
labelTime  = time + labelOffset * barSeconds * 1000

if barstate.islast and not na(athPrice) and not na(athTime)

    if na(athLine)
        athLine := line.new(
             x1 = athTime,
             y1 = athPrice,
             x2 = labelTime,
             y2 = athPrice,
             xloc = xloc.bar_time,
             extend = extend.none,
             color = lineColor,
             width = lineWidth
        )
    else
        line.set_xy1(athLine, athTime, athPrice)
        line.set_xy2(athLine, labelTime, athPrice)
        line.set_extend(athLine, extend.none)
        line.set_color(athLine, lineColor)
        line.set_width(athLine, lineWidth)

    if na(athLabel)
        athLabel := label.new(
             x = labelTime,
             y = athPrice,
             text = labelText,
             xloc = xloc.bar_time,
             style = label.style_label_left,
             color = labelColor,
             textcolor = textColor
        )
    else
        label.set_xy(athLabel, labelTime, athPrice)
        label.set_text(athLabel, labelText)
        label.set_color(athLabel, labelColor)
        label.set_textcolor(athLabel, textColor)
````
