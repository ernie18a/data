# Macro Candle Overlay

- url: https://www.tradingview.com/script/3CzIDSgZ-Macro-Candle-Overlay/
- type: indicator
- pine_id: PUB;e20aae84627144f1bef1056d9f9c6fc0
- version: 1.0

## Description

Macro Candle Overlay is a higher-timeframe candle visualization tool designed to display selected macro candles directly on the active chart.

The script draws candles from a selected higher timeframe, such as 15m, 30m, 1H, 2H, 4H, Daily, Weekly, or Monthly. Each higher-timeframe candle is represented with its own body and wick, allowing traders to view larger candle structure without switching away from the current chart timeframe.

This can help with visual analysis of broader market context, including higher-timeframe candle direction, wick behavior, candle body size, and developing macro candle structure.
[b]
Main features:[/b]

* Higher-timeframe candle overlay on the current chart;
* Selectable candle timeframe;
* Bullish and bearish body color settings;
* Wick and border color settings;
* Adjustable body transparency;
* Automatic candle updating while the current higher-timeframe candle is still developing;
* Clean chart-based visualization with no signal logic.

[b]How it works:[/b]

The indicator uses the selected higher timeframe to define candle open, high, low, close, start time, and end time. It then draws each candle as a chart object, including a candle body and a wick. The active candle updates as new price data appears.

This script does not generate buy or sell signals. It does not include strategy logic, alerts, backtesting, win-rate calculations, or performance projections. It is intended only as a visual charting tool for reading higher-timeframe candle structure.

[i]Traders can use it as an additional visual reference together with their own analysis, market structure, risk management, and trading plan.[/i]

## Source Code

````pine
//@version=6
// This source code is subject to the Mozilla Public License 2.0: https://mozilla.org/MPL/2.0/
// Macro Candle Overlay
// Displays selected higher-timeframe candles directly on the chart.

indicator("Macro Candle Overlay", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 5000)

// Inputs
string candleTf = input.timeframe("240", "Candle Timeframe", options = ["15", "30", "60", "120", "240", "D", "W", "M"])

groupStyle = "Style"

color bullBodyInput = input.color(color.rgb(34, 197, 94), "Bullish Body Color", group = groupStyle)
color bearBodyInput = input.color(color.rgb(239, 68, 68), "Bearish Body Color", group = groupStyle)
color bullWickInput = input.color(color.rgb(34, 197, 94), "Bullish Wick / Border Color", group = groupStyle)
color bearWickInput = input.color(color.rgb(239, 68, 68), "Bearish Wick / Border Color", group = groupStyle)

int bodyTransparency = input.int(68, "Body Transparency", minval = 0, maxval = 100, group = groupStyle)

int KEEP_CANDLES = 250

color bullBodyColor = color.new(bullBodyInput, bodyTransparency)
color bearBodyColor = color.new(bearBodyInput, bodyTransparency)
color bullBorderColor = color.new(bullWickInput, 0)
color bearBorderColor = color.new(bearWickInput, 0)

// Stored chart objects
var array<box> storedBodies = array.new_box()
var array<line> storedWicks = array.new_line()

f_storeBody(box body) =>
    if not na(body)
        array.push(storedBodies, body)

        if array.size(storedBodies) > KEEP_CANDLES
            box oldBody = array.shift(storedBodies)
            box.delete(oldBody)

f_storeWick(line wick) =>
    if not na(wick)
        array.push(storedWicks, wick)

        if array.size(storedWicks) > KEEP_CANDLES
            line oldWick = array.shift(storedWicks)
            line.delete(oldWick)

// Candle drawing update
f_updateCandle(box body, line wick, float candleOpen, float candleHigh, float candleLow, float candleClose, int candleStartTime, int candleEndTime) =>
    if not na(body) and not na(wick) and not na(candleOpen) and not na(candleHigh) and not na(candleLow) and not na(candleClose) and not na(candleStartTime) and not na(candleEndTime)
        int rangeMs = math.max(1, candleEndTime - candleStartTime)
        int bodyPaddingMs = int(math.round(float(rangeMs) * 0.15))
        int bodyLeftTime = candleStartTime + bodyPaddingMs
        int bodyRightTime = candleEndTime - bodyPaddingMs
        int wickTime = candleStartTime + int(math.round(float(rangeMs) / 2.0))

        float rawBodyTop = math.max(candleOpen, candleClose)
        float rawBodyBottom = math.min(candleOpen, candleClose)

        float bodyTop = rawBodyTop == rawBodyBottom ? rawBodyTop + syminfo.mintick : rawBodyTop
        float bodyBottom = rawBodyTop == rawBodyBottom ? rawBodyBottom - syminfo.mintick : rawBodyBottom

        bool isBull = candleClose >= candleOpen
        color bodyColor = isBull ? bullBodyColor : bearBodyColor
        color borderColor = isBull ? bullBorderColor : bearBorderColor

        line.set_x1(wick, wickTime)
        line.set_y1(wick, candleHigh)
        line.set_x2(wick, wickTime)
        line.set_y2(wick, candleLow)
        line.set_color(wick, borderColor)
        line.set_width(wick, 2)

        box.set_left(body, bodyLeftTime)
        box.set_right(body, bodyRightTime)
        box.set_top(body, bodyTop)
        box.set_bottom(body, bodyBottom)
        box.set_bgcolor(body, bodyColor)
        box.set_border_color(body, borderColor)
        box.set_border_width(body, 2)

// Timeframe data
int selectedTfSec = timeframe.in_seconds(candleTf)
int chartTfSec = timeframe.in_seconds(timeframe.period)

bool validTimeframe = na(selectedTfSec) or na(chartTfSec) ? true : selectedTfSec >= chartTfSec

int tfStartTime = time(candleTf)
int tfEndTime = time_close(candleTf)

bool hasTfTime = not na(tfStartTime) and not na(tfEndTime)
bool newTfCandle = hasTfTime and (na(tfStartTime[1]) or tfStartTime != tfStartTime[1])

// Active candle state
var box currentBody = na
var line currentWick = na

var float tfOpen = na
var float tfHigh = na
var float tfLow = na
var float tfClose = na

var int currentStartTime = na
var int currentEndTime = na

// Build and update candles
if validTimeframe and hasTfTime
    if newTfCandle
        tfOpen := open
        tfHigh := high
        tfLow := low
        tfClose := close

        currentStartTime := tfStartTime
        currentEndTime := tfEndTime

        bool isBull = tfClose >= tfOpen
        color bodyColor = isBull ? bullBodyColor : bearBodyColor
        color borderColor = isBull ? bullBorderColor : bearBorderColor

        int rangeMs = math.max(1, tfEndTime - tfStartTime)
        int wickTime = tfStartTime + int(math.round(float(rangeMs) / 2.0))

        currentBody := box.new(left = tfStartTime, top = math.max(tfOpen, tfClose), right = tfEndTime, bottom = math.min(tfOpen, tfClose), xloc = xloc.bar_time, bgcolor = bodyColor, border_color = borderColor, border_width = 2)
        currentWick := line.new(x1 = wickTime, y1 = tfHigh, x2 = wickTime, y2 = tfLow, xloc = xloc.bar_time, color = borderColor, width = 2)

        f_storeBody(currentBody)
        f_storeWick(currentWick)
    else
        tfHigh := na(tfHigh) ? high : math.max(tfHigh, high)
        tfLow := na(tfLow) ? low : math.min(tfLow, low)
        tfClose := close
        currentEndTime := tfEndTime

    f_updateCandle(currentBody, currentWick, tfOpen, tfHigh, tfLow, tfClose, currentStartTime, currentEndTime)
````
