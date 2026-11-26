# Dau Gia DH

- url: https://www.tradingview.com/script/clXDoTIx/
- type: indicator
- pine_id: PUB;fecd29a9f9a843bdb308877ea0f6c9e3
- version: 1.0

## Description

This indicator displays Higher Timeframe (HTF) price levels directly on lower timeframe charts in TradingView.
It automatically draws the previous candle’s High, Low, and Close levels from two customizable higher timeframes.

Features:

* Supports 2 independent HTF levels (example: H1 and H4)
* Toggle ON/OFF for each timeframe separately
* Displays:

  * Previous candle High
  * Previous candle Low
  * Previous candle Close
* Automatic labels for each level
* Customizable line width
* Dashed line style for the newest HTF candle
* Older HTF levels remain solid for better visual distinction
* Automatically removes old levels based on user-defined candle history
* Works on all chart timeframes
* Optimized for TradingView Pine Script v5

Color Settings:

* High = Green
* Low = Red
* Close = Yellow

Visual Logic:

* The most recent HTF candle levels are displayed with dashed lines
* Older HTF candle levels are displayed with solid lines
* This helps traders quickly identify the latest active HTF levels

Typical Usage:

* Intraday trading
* Multi-timeframe analysis
* Support & resistance mapping
* Liquidity level tracking
* Market structure confirmation

Compatible with:

* Forex
* Crypto
* Indices
* Stocks
* Commodities

Built with Pine Script Version 5 for TradingView.

## Source Code

````pine
//@version=5
indicator("Đấu Giá ĐH", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
enableTF1 = input.bool(true, "Biên độ nến 1")
tf1       = input.timeframe("60", "Khung thời gian:")

enableTF2 = input.bool(true, "Biên độ nến 2")
tf2       = input.timeframe("240", "Khung thời gian:")

numberOfCandles = input.int(3, "Tùy chọn số nến:", minval=1, maxval=20)

showCloseLine   = input.bool(true, "Hiển thị mức giá đóng cửa")
showHighLowLine = input.bool(true, "Hiển thị mức giá cao/thấp")
showLabels      = input.bool(true, "Show Labels")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
highColor  = color.green
lowColor   = color.red
closeColor = color.yellow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORAGE TF1
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line[] tf1CloseLines = array.new_line()
var line[] tf1HighLines  = array.new_line()
var line[] tf1LowLines   = array.new_line()

var label[] tf1CloseLabels = array.new_label()
var label[] tf1HighLabels  = array.new_label()
var label[] tf1LowLabels   = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORAGE TF2
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line[] tf2CloseLines = array.new_line()
var line[] tf2HighLines  = array.new_line()
var line[] tf2LowLines   = array.new_line()

var label[] tf2CloseLabels = array.new_label()
var label[] tf2HighLabels  = array.new_label()
var label[] tf2LowLabels   = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELETE FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
deleteLines(line[] arr) =>
    while array.size(arr) > 0
        ln = array.pop(arr)
        line.delete(ln)

deleteLabels(label[] arr) =>
    while array.size(arr) > 0
        lb = array.pop(arr)
        label.delete(lb)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRIM FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trimLines(line[] arr) =>
    while array.size(arr) > numberOfCandles
        ln = array.pop(arr)
        line.delete(ln)

trimLabels(label[] arr) =>
    while array.size(arr) > numberOfCandles
        lb = array.pop(arr)
        label.delete(lb)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TF1 DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tf1High  = request.security(syminfo.tickerid, tf1, high)
tf1Low   = request.security(syminfo.tickerid, tf1, low)
tf1Close = request.security(syminfo.tickerid, tf1, close)

tf1Time      = request.security(syminfo.tickerid, tf1, time)
tf1TimeClose = request.security(syminfo.tickerid, tf1, time_close)

newTF1 = ta.change(tf1Time)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW TF1
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if enableTF1

    if newTF1

        highValue  = tf1High[1]
        lowValue   = tf1Low[1]
        closeValue = tf1Close[1]

        startTime = tf1Time[1]

        duration = tf1TimeClose[1] - tf1Time[1]

        endTime = tf1TimeClose[1] + duration

        //━━━━━━━━ CLOSE ━━━━━━━━
        if showCloseLine

            closeLine = line.new(
                 x1 = startTime,
                 y1 = closeValue,
                 x2 = endTime,
                 y2 = closeValue,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = closeColor,
                 width = lineWidth)

            array.unshift(tf1CloseLines, closeLine)

            if showLabels

                closeLabel = label.new(
                     x = endTime,
                     y = closeValue,
                     text = "C " + tf1,
                     xloc = xloc.bar_time,
                     style = label.style_label_left,
                     color = closeColor,
                     textcolor = color.black)

                array.unshift(tf1CloseLabels, closeLabel)

        //━━━━━━━━ HIGH / LOW ━━━━━━━━
        if showHighLowLine

            highLine = line.new(
                 x1 = startTime,
                 y1 = highValue,
                 x2 = endTime,
                 y2 = highValue,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = highColor,
                 width = lineWidth)

            lowLine = line.new(
                 x1 = startTime,
                 y1 = lowValue,
                 x2 = endTime,
                 y2 = lowValue,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = lowColor,
                 width = lineWidth)

            array.unshift(tf1HighLines, highLine)
            array.unshift(tf1LowLines, lowLine)

            if showLabels

                highLabel = label.new(
                     x = endTime,
                     y = highValue,
                     text = "H " + tf1,
                     xloc = xloc.bar_time,
                     style = label.style_label_left,
                     color = highColor,
                     textcolor = color.white)

                lowLabel = label.new(
                     x = endTime,
                     y = lowValue,
                     text = "L " + tf1,
                     xloc = xloc.bar_time,
                     style = label.style_label_left,
                     color = lowColor,
                     textcolor = color.white)

                array.unshift(tf1HighLabels, highLabel)
                array.unshift(tf1LowLabels, lowLabel)

else

    deleteLines(tf1CloseLines)
    deleteLines(tf1HighLines)
    deleteLines(tf1LowLines)

    deleteLabels(tf1CloseLabels)
    deleteLabels(tf1HighLabels)
    deleteLabels(tf1LowLabels)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TF2 DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tf2High  = request.security(syminfo.tickerid, tf2, high)
tf2Low   = request.security(syminfo.tickerid, tf2, low)
tf2Close = request.security(syminfo.tickerid, tf2, close)

tf2Time      = request.security(syminfo.tickerid, tf2, time)
tf2TimeClose = request.security(syminfo.tickerid, tf2, time_close)

newTF2 = ta.change(tf2Time)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW TF2
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if enableTF2

    if newTF2

        highValue  = tf2High[1]
        lowValue   = tf2Low[1]
        closeValue = tf2Close[1]

        startTime = tf2Time[1]

        duration = tf2TimeClose[1] - tf2Time[1]

        endTime = tf2TimeClose[1] + duration

        //━━━━━━━━ CLOSE ━━━━━━━━
        if showCloseLine

            closeLine = line.new(
                 x1 = startTime,
                 y1 = closeValue,
                 x2 = endTime,
                 y2 = closeValue,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = closeColor,
                 width = lineWidth)

            array.unshift(tf2CloseLines, closeLine)

            if showLabels

                closeLabel = label.new(
                     x = endTime,
                     y = closeValue,
                     text = "C " + tf2,
                     xloc = xloc.bar_time,
                     style = label.style_label_left,
                     color = closeColor,
                     textcolor = color.black)

                array.unshift(tf2CloseLabels, closeLabel)

        //━━━━━━━━ HIGH / LOW ━━━━━━━━
        if showHighLowLine

            highLine = line.new(
                 x1 = startTime,
                 y1 = highValue,
                 x2 = endTime,
                 y2 = highValue,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = highColor,
                 width = lineWidth)

            lowLine = line.new(
                 x1 = startTime,
                 y1 = lowValue,
                 x2 = endTime,
                 y2 = lowValue,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = lowColor,
                 width = lineWidth)

            array.unshift(tf2HighLines, highLine)
            array.unshift(tf2LowLines, lowLine)

            if showLabels

                highLabel = label.new(
                     x = endTime,
                     y = highValue,
                     text = "H " + tf2,
                     xloc = xloc.bar_time,
                     style = label.style_label_left,
                     color = highColor,
                     textcolor = color.white)

                lowLabel = label.new(
                     x = endTime,
                     y = lowValue,
                     text = "L " + tf2,
                     xloc = xloc.bar_time,
                     style = label.style_label_left,
                     color = lowColor,
                     textcolor = color.white)

                array.unshift(tf2HighLabels, highLabel)
                array.unshift(tf2LowLabels, lowLabel)

else

    deleteLines(tf2CloseLines)
    deleteLines(tf2HighLines)
    deleteLines(tf2LowLines)

    deleteLabels(tf2CloseLabels)
    deleteLabels(tf2HighLabels)
    deleteLabels(tf2LowLabels)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRIM TF1
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trimLines(tf1CloseLines)
trimLines(tf1HighLines)
trimLines(tf1LowLines)

trimLabels(tf1CloseLabels)
trimLabels(tf1HighLabels)
trimLabels(tf1LowLabels)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRIM TF2
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trimLines(tf2CloseLines)
trimLines(tf2HighLines)
trimLines(tf2LowLines)

trimLabels(tf2CloseLabels)
trimLabels(tf2HighLabels)
trimLabels(tf2LowLabels)
````
