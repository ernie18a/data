# DTP's timeframe indicator

- url: https://www.tradingview.com/script/IWMOBiZ0-DTP-s-timeframe-indicator/
- type: indicator
- pine_id: PUB;ce77f710136149d5b5ca656177379ef7
- version: 1.0

## Description

Multiple time frames one chart - heiken-ashi

This allows you to choose how many candles and what time frames you want on your chart. You can also see when the next candle is closing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LWHubs

//@version=6
indicator("DTP's timeframe indicator", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, dynamic_requests=true)

// ───── Inputs
useHA = input.bool(false, "Use Heikin Ashi Candles")

showHTF1 = input.bool(true, "HTF 1")
tf1 = input.timeframe("5", "HTF 1 Timeframe")
num1 = input.int(10, "HTF 1 Candles", minval=1, maxval=50)

showHTF2 = input.bool(true, "HTF 2")
tf2 = input.timeframe("15", "HTF 2 Timeframe")
num2 = input.int(4, "HTF 2 Candles", minval=1, maxval=50)

showHTF3 = input.bool(true, "HTF 3")
tf3 = input.timeframe("60", "HTF 3 Timeframe")
num3 = input.int(12, "HTF 3 Candles", minval=1, maxval=50)

showHTF4 = input.bool(true, "HTF 4")
tf4 = input.timeframe("240", "HTF 4 Timeframe")
num4 = input.int(4, "HTF 4 Candles", minval=1, maxval=50)

showHTF5 = input.bool(true, "HTF 5")
tf5 = input.timeframe("D", "HTF 5 Timeframe")
num5 = input.int(2, "HTF 5 Candles", minval=1, maxval=50)

padding = input.int(10, "Padding From Current Candles", minval=1)
spaceGroups = input.int(10, "Space Between HTF Groups", minval=1)
candleSpacing = input.int(4, "Candle Spacing", minval=2, maxval=20)
bodyHalfWidth = input.int(1, "Body Half Width", minval=0, maxval=5)

showLabels = input.bool(true, "Show HTF Labels")
showTimeLeft = input.bool(true, "Show Remaining Time")

bullColor = input.color(color.lime, "Bull Body")
bearColor = input.color(color.red, "Bear Body")
wickColor = input.color(color.gray, "Wick / Border")

// ───── Drawing arrays
var box[] boxes = array.new_box()
var line[] lines = array.new_line()
var label[] labels = array.new_label()

clearDrawings() =>
    while array.size(boxes) > 0
        box.delete(array.pop(boxes))
    while array.size(lines) > 0
        line.delete(array.pop(lines))
    while array.size(labels) > 0
        label.delete(array.pop(labels))

// ───── HTF arrays
var float[] o1 = array.new_float()
var float[] h1 = array.new_float()
var float[] l1 = array.new_float()
var float[] c1 = array.new_float()
var int[] t1 = array.new_int()
var int[] tc1 = array.new_int()

var float[] o2 = array.new_float()
var float[] h2 = array.new_float()
var float[] l2 = array.new_float()
var float[] c2 = array.new_float()
var int[] t2 = array.new_int()
var int[] tc2 = array.new_int()

var float[] o3 = array.new_float()
var float[] h3 = array.new_float()
var float[] l3 = array.new_float()
var float[] c3 = array.new_float()
var int[] t3 = array.new_int()
var int[] tc3 = array.new_int()

var float[] o4 = array.new_float()
var float[] h4 = array.new_float()
var float[] l4 = array.new_float()
var float[] c4 = array.new_float()
var int[] t4 = array.new_int()
var int[] tc4 = array.new_int()

var float[] o5 = array.new_float()
var float[] h5 = array.new_float()
var float[] l5 = array.new_float()
var float[] c5 = array.new_float()
var int[] t5 = array.new_int()
var int[] tc5 = array.new_int()

symbolUsed = useHA ? ticker.heikinashi(syminfo.tickerid) : syminfo.tickerid

// ───── Update HTF arrays
updateHTF(_tf, float[] _oArr, float[] _hArr, float[] _lArr, float[] _cArr, int[] _tArr, int[] _tcArr) =>
    [oo, hh, ll, cc, tt, tcc] = request.security(symbolUsed, _tf, [open, high, low, close, time, time_close], lookahead=barmerge.lookahead_off)

    if not na(oo) and not na(tt)
        bool isEmpty = array.size(_oArr) == 0
        bool isNewHTF = isEmpty or array.size(_tArr) == 0 or tt != array.get(_tArr, 0)

        if isNewHTF
            array.unshift(_oArr, oo)
            array.unshift(_hArr, hh)
            array.unshift(_lArr, ll)
            array.unshift(_cArr, cc)
            array.unshift(_tArr, tt)
            array.unshift(_tcArr, tcc)
        else
            array.set(_oArr, 0, oo)
            array.set(_hArr, 0, hh)
            array.set(_lArr, 0, ll)
            array.set(_cArr, 0, cc)
            array.set(_tArr, 0, tt)
            array.set(_tcArr, 0, tcc)

        while array.size(_oArr) > 50
            array.pop(_oArr)
            array.pop(_hArr)
            array.pop(_lArr)
            array.pop(_cArr)
            array.pop(_tArr)
            array.pop(_tcArr)

// Update every bar
updateHTF(tf1, o1, h1, l1, c1, t1, tc1)
updateHTF(tf2, o2, h2, l2, c2, t2, tc2)
updateHTF(tf3, o3, h3, l3, c3, t3, tc3)
updateHTF(tf4, o4, h4, l4, c4, t4, tc4)
updateHTF(tf5, o5, h5, l5, c5, t5, tc5)

// ───── Time label
formatTimeLeft(_closeTime) =>
    remaining = math.max(_closeTime - timenow, 0)
    totalSec = math.floor(remaining / 1000)
    hrs = math.floor(totalSec / 3600)
    mins = math.floor((totalSec % 3600) / 60)
    secs = totalSec % 60
    hrs > 0 ? str.tostring(hrs) + ":" + str.tostring(mins, "00") + ":" + str.tostring(secs, "00") : str.tostring(mins) + ":" + str.tostring(secs, "00")

// ───── Draw group
drawGroup(_show, _count, _xStart, _title, float[] _oArr, float[] _hArr, float[] _lArr, float[] _cArr, int[] _tcArr) =>
    int nextX = _xStart

    if _show and array.size(_oArr) > 0
        int available = math.min(_count, array.size(_oArr))

        float groupHigh = na
        float groupLow = na

        for i = available - 1 to 0
            xo = _xStart + (available - 1 - i) * candleSpacing

            oo = array.get(_oArr, i)
            hh = array.get(_hArr, i)
            ll = array.get(_lArr, i)
            cc = array.get(_cArr, i)

            groupHigh := na(groupHigh) ? hh : math.max(groupHigh, hh)
            groupLow := na(groupLow) ? ll : math.min(groupLow, ll)

            bodyTop = math.max(oo, cc)
            bodyBottom = math.min(oo, cc)
            bodyColor = cc >= oo ? bullColor : bearColor

            wick = line.new(xo, hh, xo, ll, xloc=xloc.bar_index, color=wickColor, width=1)
            array.push(lines, wick)

            body = box.new(
                 left=xo - bodyHalfWidth,
                 top=bodyTop,
                 right=xo + bodyHalfWidth,
                 bottom=bodyBottom,
                 xloc=xloc.bar_index,
                 bgcolor=bodyColor,
                 border_color=wickColor
            )
            array.push(boxes, body)

        midX = _xStart + math.floor((available * candleSpacing) / 2)

        if showLabels
            lbl = label.new(midX, groupHigh, _title, xloc=xloc.bar_index, style=label.style_label_down, textcolor=color.gray, color=color.new(color.white, 100), size=size.large)
            array.push(labels, lbl)

        if showTimeLeft and array.size(_tcArr) > 0
            closeTime = array.get(_tcArr, 0)
            tl = label.new(midX, groupHigh - ((groupHigh - groupLow) * 0.08), "(" + formatTimeLeft(closeTime) + ")", xloc=xloc.bar_index, style=label.style_label_down, textcolor=color.gray, color=color.new(color.white, 100), size=size.small)
            array.push(labels, tl)

        nextX := _xStart + available * candleSpacing + spaceGroups

    nextX

// ───── Main draw
if barstate.islast
    clearDrawings()

    startX = bar_index + padding

    x1 = drawGroup(showHTF1, num1, startX, tf1, o1, h1, l1, c1, tc1)
    x2 = drawGroup(showHTF2, num2, x1, tf2, o2, h2, l2, c2, tc2)
    x3 = drawGroup(showHTF3, num3, x2, tf3, o3, h3, l3, c3, tc3)
    x4 = drawGroup(showHTF4, num4, x3, tf4, o4, h4, l4, c4, tc4)
    x5 = drawGroup(showHTF5, num5, x4, tf5, o5, h5, l5, c5, tc5)
````
