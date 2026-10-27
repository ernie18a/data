# Kaiso EMA + FVG + Bias Toolkit

- url: https://www.tradingview.com/script/eQaLkf3f/
- type: indicator
- pine_id: PUB;50ff9ac4d9984dbeb26e4e1cb5f7c8e3
- version: 1.0

## Description

howBias = input.bool(true, "Show Daily Bias on H4 以下", group=groupBias)
biasOffset = input.int(20, "距離目前 K 棒", minval=5, maxval=200, group=groupBias)
candleGap = input.int(6, "D-2 / D-1 / D 間距", minval=2, maxval=50, group=groupBias)
candleWidth = input.int(2, "蠟燭寬度", minval=1, maxval=10, group=groupBias)

bullColor = input.color(color.white, "上漲蠟燭顏色", group=groupBias)
bearColor = input.color(color.blue, "下跌蠟燭顏色", group=groupBias)
wickColor = input.color(color.blue, "影線顏色", group=groupBias)
textColor = input.color(color.black, "文字顏色", group=groupBias)
prevHLColor = input.color(color.red, "前日高低顏色", group=groupBias)
ohlcLineColor = input.color(color.black, "O/H/L/C 線條顏色", group=groupBias)

isH4Below = timeframe.isintraday and timeframe.in_seconds(timeframe.period) <= 14400

d2O = request.security(syminfo.tickerid, "D", open[2], lookahead=barmerge.lookahead_on)
d2H = request.security(syminfo.tickerid, "D", high[2], lookahead=barmerge.lookahead_on)
d2L = request.security(syminfo.tickerid, "D", low[2], lookahead=barmerge.lookahead_on)
d2C = request.security(syminfo.tickerid, "D", close[2], lookahead=barmerge.lookahead_on)

d1O = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)
d1H = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
d1L = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
d1C = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

dO = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)

var line[] biasLines = array.new_line()
var box[] biasBoxes = array.new_box()
var label[] biasLabels = array.new_label()

f_clearBias() =>
    while array.size(biasLines) > 0
        line.delete(array.pop(biasLines))
    while array.size(biasBoxes) > 0
        box.delete(array.pop(biasBoxes))
    while array.size(biasLabels) > 0
        label.delete(array.pop(biasLabels))

f_line(_x1, _y1, _x2, _y2, _col, _style, _width) =>
    ln = line.new(_x1, _y1, _x2, _y2, color=_col, sty

## Source Code

````pine
//@version=6
indicator("Kaiso EMA + FVG + Bias Toolkit", overlay=true, max_boxes_count=300, max_labels_count=500, max_lines_count=300)

//━━━━━━━━━━━━━━━━━━
// 1. EMA 5 條
//━━━━━━━━━━━━━━━━━━
groupEMA = "EMA Settings"

showEma1 = input.bool(true, "Show EMA 1", group=groupEMA)
emaLen1  = input.int(20, "EMA 1 Length", group=groupEMA)
emaCol1  = input.color(color.yellow, "EMA 1 Color", group=groupEMA)
emaWid1  = input.int(2, "EMA 1 Width", minval=1, maxval=5, group=groupEMA)

showEma2 = input.bool(true, "Show EMA 2", group=groupEMA)
emaLen2  = input.int(50, "EMA 2 Length", group=groupEMA)
emaCol2  = input.color(color.orange, "EMA 2 Color", group=groupEMA)
emaWid2  = input.int(2, "EMA 2 Width", minval=1, maxval=5, group=groupEMA)

showEma3 = input.bool(true, "Show EMA 3", group=groupEMA)
emaLen3  = input.int(100, "EMA 3 Length", group=groupEMA)
emaCol3  = input.color(color.blue, "EMA 3 Color", group=groupEMA)
emaWid3  = input.int(2, "EMA 3 Width", minval=1, maxval=5, group=groupEMA)

showEma4 = input.bool(true, "Show EMA 4", group=groupEMA)
emaLen4  = input.int(200, "EMA 4 Length", group=groupEMA)
emaCol4  = input.color(color.purple, "EMA 4 Color", group=groupEMA)
emaWid4  = input.int(2, "EMA 4 Width", minval=1, maxval=5, group=groupEMA)

showEma5 = input.bool(false, "Show EMA 5", group=groupEMA)
emaLen5  = input.int(300, "EMA 5 Length", group=groupEMA)
emaCol5  = input.color(color.white, "EMA 5 Color", group=groupEMA)
emaWid5  = input.int(2, "EMA 5 Width", minval=1, maxval=5, group=groupEMA)

plot(showEma1 ? ta.ema(close, emaLen1) : na, "EMA 1", emaCol1, emaWid1)
plot(showEma2 ? ta.ema(close, emaLen2) : na, "EMA 2", emaCol2, emaWid2)
plot(showEma3 ? ta.ema(close, emaLen3) : na, "EMA 3", emaCol3, emaWid3)
plot(showEma4 ? ta.ema(close, emaLen4) : na, "EMA 4", emaCol4, emaWid4)
plot(showEma5 ? ta.ema(close, emaLen5) : na, "EMA 5", emaCol5, emaWid5)


//━━━━━━━━━━━━━━━━━━
// 2. FVG
// Bullish FVG: low > high[2]
// Bearish FVG: high < low[2]
// 突破 50% 失效
//━━━━━━━━━━━━━━━━━━
groupFVG = "FVG Settings"

showFVG      = input.bool(true, "Show FVG", group=groupFVG)
maxFreshFVG  = input.int(5, "保留最新 FVG 數量", minval=1, maxval=50, group=groupFVG)
fvgExtend    = input.int(80, "FVG 向右延伸 K 數", minval=5, maxval=500, group=groupFVG)
useWickBreak = input.bool(true, "用影線突破 50% 判定失效", group=groupFVG)

bullFvgColor = input.color(color.new(color.lime, 80), "FVG+ Color", group=groupFVG)
bearFvgColor = input.color(color.new(color.red, 80), "FVG- Color", group=groupFVG)
fvgTextColor = input.color(color.white, "FVG Text Color", group=groupFVG)

var box[]   fvgBoxes  = array.new_box()
var label[] fvgLabels = array.new_label()
var bool[]  fvgBull   = array.new_bool()

bullFVG = showFVG and low > high[2]
bearFVG = showFVG and high < low[2]

f_addFVG(_top, _bottom, _isBull) =>
    b = box.new(
         left=bar_index[2],
         top=_top,
         right=bar_index + fvgExtend,
         bottom=_bottom,
         bgcolor=_isBull ? bullFvgColor : bearFvgColor,
         border_color=color.new(color.white, 70)
    )
    txt = _isBull ? "FVG+" : "FVG-"
    l = label.new(
         x=bar_index + fvgExtend,
         y=_bottom,
         text=txt,
         style=label.style_label_left,
         textcolor=fvgTextColor,
         color=color.new(color.black, 100),
         size=size.small
    )
    array.push(fvgBoxes, b)
    array.push(fvgLabels, l)
    array.push(fvgBull, _isBull)

    while array.size(fvgBoxes) > maxFreshFVG
        oldB = array.shift(fvgBoxes)
        oldL = array.shift(fvgLabels)
        array.shift(fvgBull)
        box.delete(oldB)
        label.delete(oldL)

if bullFVG
    f_addFVG(low, high[2], true)

if bearFVG
    f_addFVG(low[2], high, false)

// 更新 / 失效刪除
if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        b = array.get(fvgBoxes, i)
        l = array.get(fvgLabels, i)
        isBull = array.get(fvgBull, i)

        top = box.get_top(b)
        bot = box.get_bottom(b)
        mid = (top + bot) / 2.0

        invalidBull = isBull and (useWickBreak ? low <= mid : close <= mid)
        invalidBear = not isBull and (useWickBreak ? high >= mid : close >= mid)

        box.set_right(b, bar_index + fvgExtend)
        label.set_x(l, bar_index + fvgExtend)
        label.set_y(l, bot)

        if invalidBull or invalidBear
            box.delete(b)
            label.delete(l)
            array.remove(fvgBoxes, i)
            array.remove(fvgLabels, i)
            array.remove(fvgBull, i)


//━━━━━━━━━━━━━━━━━━
// 3. WaterMark + 提醒事項
//━━━━━━━━━━━━━━━━━━
groupWM = "Watermark / Reminder"

showWatermark = input.bool(true, "Show Watermark", group=groupWM)
watermarkText = input.string("KAISO TRADING", "Watermark Text", group=groupWM)
wmTextColor   = input.color(color.new(color.white, 65), "Watermark Color", group=groupWM)

showNote   = input.bool(true, "Show Reminder", group=groupWM)
noteText   = input.string("等待確認，不追單。", "提醒文字", group=groupWM)
noteColor  = input.color(color.white, "提醒文字顏色", group=groupWM)
noteSizeIn = input.string("normal", "提醒文字大小", options=["tiny", "small", "normal", "large", "huge"], group=groupWM)

f_size(_s) =>
    _s == "tiny" ? size.tiny :
     _s == "small" ? size.small :
     _s == "large" ? size.large :
     _s == "huge" ? size.huge : size.normal

var table wmTable = table.new(position.top_right, 1, 2)

if barstate.islast
    table.cell(wmTable, 0, 0, showWatermark ? watermarkText : "", text_color=wmTextColor, text_size=size.huge)
    table.cell(wmTable, 0, 1, showNote ? noteText : "", text_color=noteColor, text_size=f_size(noteSizeIn))


//━━━━━━━━━━━━━━━━━━
// 4. 蠟燭偏見：像範例圖一樣投影 D-2 / D-1 / D
//━━━━━━━━━━━━━━━━━━
groupBias = "Daily Bias Projection"

showBias = input.bool(true, "Show Daily Bias on H4 以下", group=groupBias)
biasOffset = input.int(20, "距離目前 K 棒", minval=5, maxval=200, group=groupBias)
candleGap = input.int(6, "D-2 / D-1 / D 間距", minval=2, maxval=50, group=groupBias)
candleWidth = input.int(2, "蠟燭寬度", minval=1, maxval=10, group=groupBias)

bullColor = input.color(color.white, "上漲蠟燭顏色", group=groupBias)
bearColor = input.color(color.blue, "下跌蠟燭顏色", group=groupBias)
wickColor = input.color(color.blue, "影線顏色", group=groupBias)
textColor = input.color(color.black, "文字顏色", group=groupBias)
prevHLColor = input.color(color.red, "前日高低顏色", group=groupBias)
ohlcLineColor = input.color(color.black, "O/H/L/C 線條顏色", group=groupBias)

isH4Below = timeframe.isintraday and timeframe.in_seconds(timeframe.period) <= 14400

d2O = request.security(syminfo.tickerid, "D", open[2], lookahead=barmerge.lookahead_on)
d2H = request.security(syminfo.tickerid, "D", high[2], lookahead=barmerge.lookahead_on)
d2L = request.security(syminfo.tickerid, "D", low[2], lookahead=barmerge.lookahead_on)
d2C = request.security(syminfo.tickerid, "D", close[2], lookahead=barmerge.lookahead_on)

d1O = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)
d1H = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
d1L = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
d1C = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

dO = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)

var line[] biasLines = array.new_line()
var box[] biasBoxes = array.new_box()
var label[] biasLabels = array.new_label()

f_clearBias() =>
    while array.size(biasLines) > 0
        line.delete(array.pop(biasLines))
    while array.size(biasBoxes) > 0
        box.delete(array.pop(biasBoxes))
    while array.size(biasLabels) > 0
        label.delete(array.pop(biasLabels))

f_line(_x1, _y1, _x2, _y2, _col, _style, _width) =>
    ln = line.new(_x1, _y1, _x2, _y2, color=_col, style=_style, width=_width)
    array.push(biasLines, ln)

f_label(_x, _y, _txt, _col) =>
    lb = label.new(
         _x, _y, _txt,
         style=label.style_label_left,
         textcolor=_col,
         color=color.new(color.white, 100),
         size=size.small
    )
    array.push(biasLabels, lb)

f_candle(_x, _o, _h, _l, _c, _name) =>
    isBull = _c >= _o
    bodyTop = math.max(_o, _c)
    bodyBot = math.min(_o, _c)
    bodyColor = isBull ? bullColor : bearColor

    // wick
    f_line(_x, _h, _x, _l, wickColor, line.style_solid, 2)

    // body
    bx = box.new(
         left=_x - candleWidth,
         top=bodyTop,
         right=_x + candleWidth,
         bottom=bodyBot,
         bgcolor=bodyColor,
         border_color=wickColor
    )
    array.push(biasBoxes, bx)

    // title
    f_label(_x - candleWidth, _h, _name, textColor)

if barstate.islast
    f_clearBias()

    if showBias and isH4Below
        xD2 = bar_index + biasOffset
        xD1 = xD2 + candleGap
        xD  = xD1 + candleGap

        // D-2 candle
        f_candle(xD2, d2O, d2H, d2L, d2C, "D-2")

        // D-1 candle
        f_candle(xD1, d1O, d1H, d1L, d1C, "D-1")

        // D open
        f_line(xD, dO, xD + candleGap, dO, ohlcLineColor, line.style_dotted, 2)
        f_label(xD, dO, "D", textColor)

        // D-1 OHLC dashed lines
        lineEnd = xD1 + candleGap * 2

        f_line(xD1, d1H, lineEnd, d1H, ohlcLineColor, line.style_dashed, 2)
        f_line(xD1, d1O, lineEnd, d1O, ohlcLineColor, line.style_dashed, 2)
        f_line(xD1, d1L, lineEnd, d1L, ohlcLineColor, line.style_dashed, 2)
        f_line(xD1, d1C, lineEnd, d1C, ohlcLineColor, line.style_dashed, 2)

        f_label(lineEnd, d1H, "H", textColor)
        f_label(lineEnd, d1O, "O", textColor)
        f_label(lineEnd, d1L, "L", textColor)
        f_label(lineEnd, d1C, "C", textColor)

        // 前日高 / 前日低
        f_line(xD2 - candleGap, d1H, lineEnd, d1H, prevHLColor, line.style_dashed, 2)
        f_line(xD2 - candleGap, d1L, lineEnd, d1L, prevHLColor, line.style_dashed, 2)

        f_label(lineEnd, d1H, "前日高", prevHLColor)
        f_label(lineEnd, d1L, "前日低", prevHLColor)
````
