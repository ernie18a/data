# Adaptive Regression Fibonacci Channel

- url: https://www.tradingview.com/script/VMncN70W/
- type: indicator
- pine_id: PUB;e8475f14533f46c584ccf16373386ce9
- version: 2.0

## Description

# Adaptive Regression Fibonacci Channel

Adaptive Regression Fibonacci Channel is a trend analysis tool that combines Linear Regression with Fibonacci-based channel levels to create a dynamic framework for identifying support, resistance, pullback, and trend continuation zones.

Unlike traditional Fibonacci retracements that require manually selected swing highs and lows, this indicator automatically calculates a regression trend line and builds an adaptive channel around recent price action.

## Features

• Dynamic Linear Regression Trend Line

• Adaptive Upper and Lower Channel Boundaries

• Automatic Fibonacci Levels:

* 0.236
* 0.382
* 0.500
* 0.618
* 0.786

• Real-Time Volatility Adjustment

• Dynamic Support and Resistance Visualization

• Compatible with Any Market and Timeframe

## How It Works

The indicator calculates a Linear Regression line using the selected lookback period.

It then measures the maximum deviation between the regression line and recent price extremes to create an adaptive channel that reflects current market conditions.

Fibonacci levels are distributed proportionally between the upper and lower channel boundaries, providing additional reference zones that may act as potential support, resistance, or reaction areas.

## Typical Applications

• Trend Analysis

Monitor the position of price within the channel structure.

• Pullback Identification

Use intermediate Fibonacci levels to identify potential retracement areas during established trends.

• Support and Resistance Mapping

Dynamic Fibonacci bands can highlight areas where price may react.

• Market Structure Assessment

Evaluate whether price is trading near channel extremes or near its regression mean.

## Notes

This indicator is designed as an analytical tool and should be used alongside other forms of technical analysis and risk management techniques.

No indicator can predict future market movements with certainty.

## Keywords

Linear Regression, Fibonacci Channel, Fibonacci Bands, Trend Analysis, Dynamic Support Resistance, Adaptive Channel, Market Structure, Technical Analysis, Price Action, TradingView

Short Description:
Dynamic Fibonacci channel built around a Linear Regression trend. Automatically adapts to market structure and volatility to highlight potential support, resistance, pullback, and trend continuation zones.

## Source Code

````pine
//@version=6
indicator('Adaptive Regression Fibonacci Channel', overlay = true, max_lines_count = 500)


// ─── SETTINGS ───────────────────────────────────────────────────────────────
length = input.int(500, 'Lookback Length', minval = 10, maxval = 5000)
showFibs = input.bool(true, 'Show Fibonacci Levels')
showMid = input.bool(true, 'Show Midline (0.500)')

colUp = input.color(color.new(color.teal, 0), 'Upper Channel Color')
colDn = input.color(color.new(color.red, 0), 'Lower Channel Color')
colMid = input.color(color.new(color.white, 20), 'Midline Color')
colFib = input.color(color.new(color.yellow, 40), 'Fibonacci Level Color')

// ─── LINEAR REGRESSION ──────────────────────────────────────────────────────
startBar = bar_index - length + 1

regStart = ta.linreg(close, length, length - 1)
regEnd = ta.linreg(close, length, 0)

// ─── HIGHEST / LOWEST OF LAST N BARS ────────────────────────────────────────
highestHigh = ta.highest(high, length)
lowestLow = ta.lowest(low, length)

halfRange = math.max(highestHigh - regEnd, regEnd - lowestLow)

// ─── LINE AND LABEL VARIABLES ───────────────────────────────────────────────
var line lineUp = na
var line lineDn = na
var line lineMid = na
var line linef236 = na
var line linef382 = na
var line linef618 = na
var line linef786 = na

var label lblUp = na
var label lblDn = na
var label lblf236 = na
var label lblf382 = na
var label lblf500 = na
var label lblf618 = na
var label lblf786 = na

// ─── HELPER FUNCTIONS ───────────────────────────────────────────────────────
drawLine(ln, y1, y2, col, w) =>
    line.delete(ln)
    line.new(startBar, y1, bar_index, y2, color = col, width = w)

drawLabel(lb, y, txt, col) =>
    label.delete(lb)
    label.new(bar_index + 1, y, txt, color = color.new(color.black, 100), textcolor = col, style = label.style_label_left, size = size.small)

if barstate.islast
    upStart = regStart + halfRange
    upEnd = regEnd + halfRange
    dnStart = regStart - halfRange
    dnEnd = regEnd - halfRange

    rangeStart = upStart - dnStart
    rangeEnd = upEnd - dnEnd

    f236s = dnStart + rangeStart * 0.236
    f236e = dnEnd + rangeEnd * 0.236

    f382s = dnStart + rangeStart * 0.382
    f382e = dnEnd + rangeEnd * 0.382

    f500s = dnStart + rangeStart * 0.500
    f500e = dnEnd + rangeEnd * 0.500

    f618s = dnStart + rangeStart * 0.618
    f618e = dnEnd + rangeEnd * 0.618

    f786s = dnStart + rangeStart * 0.786
    f786e = dnEnd + rangeEnd * 0.786

    // ─── CHANNEL LINES ──────────────────────────────────────────────────────
    lineUp := drawLine(lineUp, upStart, upEnd, colUp, 2)
    lineDn := drawLine(lineDn, dnStart, dnEnd, colDn, 2)

    if showMid
        lineMid := drawLine(lineMid, regStart, regEnd, colMid, 2)
        lineMid
    else
        line.delete(lineMid)

    // ─── MAIN LABELS ────────────────────────────────────────────────────────
    lblUp := drawLabel(lblUp, upEnd, '1.000  ' + str.tostring(upEnd, '#.##'), colUp)

    lblDn := drawLabel(lblDn, dnEnd, '0.000  ' + str.tostring(dnEnd, '#.##'), colDn)

    // ─── FIBONACCI LEVELS ───────────────────────────────────────────────────
    if showFibs
        linef236 := drawLine(linef236, f236s, f236e, colFib, 1)
        linef382 := drawLine(linef382, f382s, f382e, colFib, 1)
        linef618 := drawLine(linef618, f618s, f618e, colFib, 1)
        linef786 := drawLine(linef786, f786s, f786e, colFib, 1)

        lblf236 := drawLabel(lblf236, f236e, '0.236  ' + str.tostring(f236e, '#.##'), colFib)

        lblf382 := drawLabel(lblf382, f382e, '0.382  ' + str.tostring(f382e, '#.##'), colFib)

        lblf618 := drawLabel(lblf618, f618e, '0.618  ' + str.tostring(f618e, '#.##'), colFib)

        lblf786 := drawLabel(lblf786, f786e, '0.786  ' + str.tostring(f786e, '#.##'), colFib)

        if showMid
            lblf500 := drawLabel(lblf500, f500e, '0.500  ' + str.tostring(f500e, '#.##'), colFib)
            lblf500
    else
        line.delete(linef236)
        line.delete(linef382)
        line.delete(linef618)
        line.delete(linef786)

        label.delete(lblf236)
        label.delete(lblf382)
        label.delete(lblf500)
        label.delete(lblf618)
        label.delete(lblf786)
````
