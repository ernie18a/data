# Higher Timeframe Candles with Vector Coloring [PVSRA]

- url: https://www.tradingview.com/script/r8sDJypc-Higher-Timeframe-Candles-with-Vector-Coloring-PVSRA/
- type: indicator
- pine_id: PUB;6582a5fef56140b0bf5583bb04dcc41d
- version: 1.0

## Description

Draws higher timeframe candles directly on the main chart and applies PVSRA-style vector coloring based on volume and spread conditions. Useful for traders who want quick multi-timeframe candle context with volume-based candle classification in one overlay.

## Source Code

````pine
//@version=5
indicator("HTF Vector Candles (PVSRA Style)", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =========================
// Inputs
// =========================
groupTF = "Timeframes"
showTf1 = input.bool(true, "TF1", group=groupTF, inline="tf1")
tf1     = input.timeframe("1", "", group=groupTF, inline="tf1")

showTf2 = input.bool(true, "TF2", group=groupTF, inline="tf2")
tf2     = input.timeframe("2", "", group=groupTF, inline="tf2")

showTf3 = input.bool(true, "TF3", group=groupTF, inline="tf3")
tf3     = input.timeframe("3", "", group=groupTF, inline="tf3")

showTf4 = input.bool(true, "TF4", group=groupTF, inline="tf4")
tf4     = input.timeframe("5", "", group=groupTF, inline="tf4")

groupDraw = "Drawing"
completedToShow   = input.int(2, "Completed candles per TF", minval=1, maxval=5, group=groupDraw)
showCurrent       = input.bool(true, "Show current building candle", group=groupDraw)
startOffset       = input.int(10, "Start offset to the right (bars)", minval=1, maxval=200, group=groupDraw)
bodyWidth         = input.int(2, "Body width (bars)", minval=1, maxval=5, group=groupDraw)
gapBetweenCandles = input.int(1, "Gap between candles (bars)", minval=0, maxval=10, group=groupDraw)
gapBetweenGroups  = input.int(4, "Gap between TF groups (bars)", minval=1, maxval=20, group=groupDraw)
wickWidth         = input.int(1, "Wick width", minval=1, maxval=4, group=groupDraw)
bodyTransparency  = input.int(0, "Body transparency", minval=0, maxval=100, group=groupDraw)
showLabels        = input.bool(true, "Show TF labels", group=groupDraw)
labelBgColor      = input.color(color.new(color.black, 70), "Label background", group=groupDraw, inline="lbl")
labelTextColor    = input.color(color.white, "Text", group=groupDraw, inline="lbl")

groupPvsra = "Vector / PVSRA Logic"
useColorOverride = input.bool(false, "Use alternate symbol for vector colors", group=groupPvsra, inline="ovr")
overrideTicker   = input.symbol("INDEX:BTCUSD", "", group=groupPvsra, inline="ovr")
avgLen           = input.int(10, "Average volume length", minval=2, maxval=100, group=groupPvsra)
vectorMult       = input.float(2.0, "Vector threshold", minval=1.0, step=0.1, group=groupPvsra)
elevatedMult     = input.float(1.5, "Elevated threshold", minval=1.0, step=0.1, group=groupPvsra)
useSpreadXVolume = input.bool(true, "Use spread x volume override", group=groupPvsra)

groupColors = "Colors"
redVectorColor       = input.color(color.red, "Vector Red", group=groupColors, inline="v1")
greenVectorColor     = input.color(color.lime, "Vector Green", group=groupColors, inline="v1")
violetVectorColor    = input.color(color.fuchsia, "Vector Violet", group=groupColors, inline="v2")
blueVectorColor      = input.color(color.blue, "Vector Blue", group=groupColors, inline="v2")
regularCandleUpColor = input.color(#999999, "Regular Up", group=groupColors, inline="r1")
regularCandleDnColor = input.color(#4d4d4d, "Regular Down", group=groupColors, inline="r1")

// =========================
// PVSRA / Vector logic
// =========================
pvsraFlag(_len, _vectorMult, _elevatedMult, _useSpreadXVolume) =>
    avgVol = ta.sma(volume[1], _len)
    spread = high - low
    volSpread = spread * volume
    highestVolSpread = ta.highest(((high - low) * volume)[1], _len)
    bull = close >= open

    climactic = not na(avgVol) and (
         volume >= avgVol * _vectorMult or
         (_useSpreadXVolume and not na(highestVolSpread) and volSpread >= highestVolSpread)
     )

    elevated = not na(avgVol) and volume >= avgVol * _elevatedMult

    climactic ? (bull ? 1 : 2) : elevated ? (bull ? 3 : 4) : (bull ? 5 : 6)

flagToColor(_flag) =>
    switch _flag
        1 => greenVectorColor
        2 => redVectorColor
        3 => blueVectorColor
        4 => violetVectorColor
        5 => regularCandleUpColor
        6 => regularCandleDnColor
        => color.gray

// =========================
// Helpers
// =========================
updateStore(_t, _o, _h, _l, _c, _f, _arrO, _arrH, _arrL, _arrC, _arrF, _maxCount) =>
    if ta.change(_t) != 0
        array.unshift(_arrO, _o[1])
        array.unshift(_arrH, _h[1])
        array.unshift(_arrL, _l[1])
        array.unshift(_arrC, _c[1])
        array.unshift(_arrF, _f[1])

        if array.size(_arrO) > _maxCount
            array.pop(_arrO)
            array.pop(_arrH)
            array.pop(_arrL)
            array.pop(_arrC)
            array.pop(_arrF)

var boxes  = array.new_box()
var wicks  = array.new_line()
var labels = array.new_label()

clearDrawings() =>
    while array.size(boxes) > 0
        box.delete(array.pop(boxes))
    while array.size(wicks) > 0
        line.delete(array.pop(wicks))
    while array.size(labels) > 0
        label.delete(array.pop(labels))

drawOneCandle(_xLeft, _o, _h, _l, _c, _col) =>
    bodyTop = math.max(_o, _c)
    bodyBot = math.min(_o, _c)
    isDoji = bodyTop == bodyBot
    dojiPad = syminfo.mintick * 0.5
    bodyTopAdj = isDoji ? bodyTop + dojiPad : bodyTop
    bodyBotAdj = isDoji ? bodyBot - dojiPad : bodyBot

    wickX = _xLeft + int(math.floor(bodyWidth * 0.5))

    wick = line.new(
         x1 = wickX, y1 = _h,
         x2 = wickX, y2 = _l,
         xloc = xloc.bar_index,
         color = _col,
         width = wickWidth
     )

    body = box.new(
         left = _xLeft,
         top = bodyTopAdj,
         right = _xLeft + bodyWidth,
         bottom = bodyBotAdj,
         xloc = xloc.bar_index,
         border_color = _col,
         bgcolor = color.new(_col, bodyTransparency)
     )

    array.push(wicks, wick)
    array.push(boxes, body)

drawGroup(_enabled, _tfName, _curO, _curH, _curL, _curC, _curF, _histO, _histH, _histL, _histC, _histF, _startX) =>
    int nextX = _startX
    int total = 0
    float hiMax = na
    float loMin = na

    if _enabled
        histSize = array.size(_histO)

        if histSize > 0
            for j = 0 to histSize - 1
                i = histSize - 1 - j

                o = array.get(_histO, i)
                h = array.get(_histH, i)
                l = array.get(_histL, i)
                c = array.get(_histC, i)
                f = array.get(_histF, i)

                hiMax := na(hiMax) ? h : math.max(hiMax, h)
                loMin := na(loMin) ? l : math.min(loMin, l)

                drawOneCandle(nextX, o, h, l, c, flagToColor(f))
                nextX += bodyWidth + gapBetweenCandles
                total += 1

        if showCurrent and not na(_curO)
            hiMax := na(hiMax) ? _curH : math.max(hiMax, _curH)
            loMin := na(loMin) ? _curL : math.min(loMin, _curL)

            drawOneCandle(nextX, _curO, _curH, _curL, _curC, flagToColor(_curF))
            nextX += bodyWidth + gapBetweenCandles
            total += 1

        if showLabels and total > 0 and not na(hiMax) and not na(loMin)
            span = hiMax - loMin
            pad = math.max(span * 0.20, syminfo.mintick * 20)
            groupWidth = total * bodyWidth + math.max(total - 1, 0) * gapBetweenCandles
            labelX = _startX + int(math.floor(groupWidth * 0.5))

            lbl = label.new(
                 x = labelX,
                 y = hiMax + pad,
                 text = _tfName,
                 xloc = xloc.bar_index,
                 style = label.style_label_down,
                 color = labelBgColor,
                 textcolor = labelTextColor,
                 size = size.small
             )
            array.push(labels, lbl)

        if total > 0
            nextX := nextX - gapBetweenCandles + gapBetweenGroups

    nextX

// =========================
// Security calls
// =========================
priceTicker = syminfo.tickerid
colorTicker = useColorOverride ? overrideTicker : syminfo.tickerid

[tf1Time, tf1O, tf1H, tf1L, tf1C] = request.security(priceTicker, tf1, [time, open, high, low, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf1F = request.security(colorTicker, tf1, pvsraFlag(avgLen, vectorMult, elevatedMult, useSpreadXVolume), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[tf2Time, tf2O, tf2H, tf2L, tf2C] = request.security(priceTicker, tf2, [time, open, high, low, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf2F = request.security(colorTicker, tf2, pvsraFlag(avgLen, vectorMult, elevatedMult, useSpreadXVolume), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[tf3Time, tf3O, tf3H, tf3L, tf3C] = request.security(priceTicker, tf3, [time, open, high, low, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf3F = request.security(colorTicker, tf3, pvsraFlag(avgLen, vectorMult, elevatedMult, useSpreadXVolume), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[tf4Time, tf4O, tf4H, tf4L, tf4C] = request.security(priceTicker, tf4, [time, open, high, low, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
tf4F = request.security(colorTicker, tf4, pvsraFlag(avgLen, vectorMult, elevatedMult, useSpreadXVolume), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// =========================
// Historical candle stores
// =========================
var tf1HistO = array.new_float()
var tf1HistH = array.new_float()
var tf1HistL = array.new_float()
var tf1HistC = array.new_float()
var tf1HistF = array.new_int()

var tf2HistO = array.new_float()
var tf2HistH = array.new_float()
var tf2HistL = array.new_float()
var tf2HistC = array.new_float()
var tf2HistF = array.new_int()

var tf3HistO = array.new_float()
var tf3HistH = array.new_float()
var tf3HistL = array.new_float()
var tf3HistC = array.new_float()
var tf3HistF = array.new_int()

var tf4HistO = array.new_float()
var tf4HistH = array.new_float()
var tf4HistL = array.new_float()
var tf4HistC = array.new_float()
var tf4HistF = array.new_int()

updateStore(tf1Time, tf1O, tf1H, tf1L, tf1C, tf1F, tf1HistO, tf1HistH, tf1HistL, tf1HistC, tf1HistF, completedToShow)
updateStore(tf2Time, tf2O, tf2H, tf2L, tf2C, tf2F, tf2HistO, tf2HistH, tf2HistL, tf2HistC, tf2HistF, completedToShow)
updateStore(tf3Time, tf3O, tf3H, tf3L, tf3C, tf3F, tf3HistO, tf3HistH, tf3HistL, tf3HistC, tf3HistF, completedToShow)
updateStore(tf4Time, tf4O, tf4H, tf4L, tf4C, tf4F, tf4HistO, tf4HistH, tf4HistL, tf4HistC, tf4HistF, completedToShow)

// =========================
// Draw only on last bar
// =========================
if barstate.islast
    clearDrawings()

    x = bar_index + startOffset
    x := drawGroup(showTf1, tf1, tf1O, tf1H, tf1L, tf1C, tf1F, tf1HistO, tf1HistH, tf1HistL, tf1HistC, tf1HistF, x)
    x := drawGroup(showTf2, tf2, tf2O, tf2H, tf2L, tf2C, tf2F, tf2HistO, tf2HistH, tf2HistL, tf2HistC, tf2HistF, x)
    x := drawGroup(showTf3, tf3, tf3O, tf3H, tf3L, tf3C, tf3F, tf3HistO, tf3HistH, tf3HistL, tf3HistC, tf3HistF, x)
    x := drawGroup(showTf4, tf4, tf4O, tf4H, tf4L, tf4C, tf4F, tf4HistO, tf4HistH, tf4HistL, tf4HistC, tf4HistF, x)
````
