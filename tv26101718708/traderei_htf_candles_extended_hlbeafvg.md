# Traderei HTF Candles extended

- url: https://www.tradingview.com/script/hlbeAfVG/
- type: indicator
- pine_id: PUB;2c13a1a6fa53417696ea4d450f4c0e2d
- version: 1.0

## Description

Traderei HTF Candles extended shows  HTF Candles from the chart.

set up to 24 candles

## Source Code

````pine
//@version=6
indicator("Traderei HTF Candles extended", overlay = true, max_bars_back = 1200, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ~~ Inputs
tf       = input.timeframe("60", "Timeframe", group = "Higher Timeframe Candles")
numb     = input.int(4, "Amount of Candles", minval = 0, maxval = 48, group = "Higher Timeframe Candles") + 1
dn_col   = input.color(color.new(color.red, 10), title = "Dn", inline = "Candles", group = "Higher Timeframe Candles")
dn_wick  = input.color(color.new(color.red, 0), title = "Wick", inline = "Candles", group = "Higher Timeframe Candles")
up_col   = input.color(color.new(color.lime, 10), title = "Up", inline = "Candles", group = "Higher Timeframe Candles")
up_wick  = input.color(color.new(color.lime, 0), title = "Wick", inline = "Candles", group = "Higher Timeframe Candles")

Range    = input.bool(false, "Range High/Low", inline = "range", group = "Range")
Mid      = input.bool(true, "Range Mid", inline = "range", group = "Range")
high_col = input.color(color.red, title = "High", inline = "range 1", group = "Range")
low_col  = input.color(color.lime, title = "Low", inline = "range 1", group = "Range")
mid_col  = input.color(color.rgb(20, 69, 246), title = "Mid", inline = "range 1", group = "Range")

loc      = input.int(1, "Location", group = "Location Settings")

// ~~ Time Labels
showTimes  = input.bool(true, "Show Candle Times", group = "Time Labels")
timeCol    = input.color(color.white, "Text Color", group = "Time Labels")
timeBgCol  = input.color(color.new(color.black, 100), "Background", group = "Time Labels")
timeSize   = input.string(size.small, "Text Size", options = [size.tiny, size.small, size.normal, size.large, size.huge], group = "Time Labels")
timeFormat = input.string("HH:mm", "Time Format", options = ["HH:mm", "dd.MM HH:mm", "dd.MM.yyyy HH:mm"], group = "Time Labels")

// ~~ Table Inputs
showTable = input.bool(true, title = "Show Table", inline = "tbl", group = "Table")
TblSize   = input.string(size.normal, title = "", options = [size.auto, size.tiny, size.small, size.normal, size.large, size.huge], inline = "tbl", group = "Table")
pos       = input.string(position.top_right, title = "", options = [position.top_right, position.top_center, position.top_left, position.bottom_right, position.bottom_center, position.bottom_left, position.middle_right, position.middle_left], inline = "tbl", group = "Table")
textcolor = input.color(color.white, title = "Text", inline = "tbl_col", group = "Table")
bgcolor   = input.color(color.new(color.blue, 30), title = "Bg", inline = "tbl_col", group = "Table")

// ~~ HTF Error Check
chartTfSec = timeframe.in_seconds(timeframe.period)
htfSec     = timeframe.in_seconds(tf)
error      = chartTfSec >= htfSec

// ~~ UDT
type HTF
    array<box> candle
    array<line> wickH
    array<line> wickL
    array<float> hl
    array<label> timeLbl
    array<int> times

// ~~ Variables
b = bar_index

var candle = HTF.new(
     array.new<box>(),
     array.new<line>(),
     array.new<line>(),
     array.new<float>(),
     array.new<label>(),
     array.new<int>())

[htfTime, o, h, l, c] = request.security(syminfo.tickerid, tf, [time, open, high, low, close], lookahead = barmerge.lookahead_on)

newHTF = ta.change(htfTime) != 0

// ~~ Create / Update Candles
if newHTF or array.size(candle.candle) == 0
    if array.size(candle.candle) >= numb
        oldBox = array.shift(candle.candle)
        oldWH  = array.shift(candle.wickH)
        oldWL  = array.shift(candle.wickL)
        oldLbl = array.shift(candle.timeLbl)

        box.delete(oldBox)
        line.delete(oldWH)
        line.delete(oldWL)
        label.delete(oldLbl)

        if array.size(candle.hl) >= 2
            array.shift(candle.hl)
            array.shift(candle.hl)

        if array.size(candle.times) > 0
            array.shift(candle.times)

    array.push(candle.candle, box.new(b, math.max(o, c), b + 2, math.min(o, c), border_color = color.new(color.black, 100), bgcolor = o > c ? dn_col : up_col))
    array.push(candle.wickH, line.new(b + 1, math.max(o, c), b + 1, h, color = o > c ? dn_wick : up_wick))
    array.push(candle.wickL, line.new(b + 1, math.min(o, c), b + 1, l, color = o > c ? dn_wick : up_wick))
    array.push(candle.hl, h)
    array.push(candle.hl, l)
    array.push(candle.times, htfTime)

    newLbl = label.new(
         b,
         l,
         str.format_time(htfTime, timeFormat, syminfo.timezone),
         style = label.style_label_up,
         textcolor = timeCol,
         color = timeBgCol,
         size = timeSize)

    array.push(candle.timeLbl, newLbl)
else
    last = array.size(candle.candle) - 1

    if last >= 0 and array.size(candle.hl) >= last * 2 + 2
        array.set(candle.hl, last * 2, h)
        array.set(candle.hl, last * 2 + 1, l)

// ~~ Relocate Candles + Time Labels
for [i, x] in candle.candle
    d = loc + i * 2
    isCurrent = i == array.size(candle.candle) - 1

    left  = b + d * 2
    right = b + d * 2 + 2
    midX  = b + d * 2 + 1

    if isCurrent
        box.set_lefttop(x, left, math.max(o, c))
        box.set_rightbottom(x, right, math.min(o, c))
        box.set_bgcolor(x, o > c ? dn_col : up_col)

        line.set_xy1(array.get(candle.wickH, i), midX, math.max(o, c))
        line.set_xy2(array.get(candle.wickH, i), midX, h)
        line.set_color(array.get(candle.wickH, i), o > c ? dn_wick : up_wick)

        line.set_xy1(array.get(candle.wickL, i), midX, math.min(o, c))
        line.set_xy2(array.get(candle.wickL, i), midX, l)
        line.set_color(array.get(candle.wickL, i), o > c ? dn_wick : up_wick)
    else
        box.set_left(x, left)
        box.set_right(x, right)

        line.set_x1(array.get(candle.wickH, i), midX)
        line.set_x2(array.get(candle.wickH, i), midX)
        line.set_x1(array.get(candle.wickL, i), midX)
        line.set_x2(array.get(candle.wickL, i), midX)

    // Time Labels
    if array.size(candle.timeLbl) > i and array.size(candle.times) > i
        lbl = array.get(candle.timeLbl, i)
        t   = array.get(candle.times, i)

        labelY = array.size(candle.hl) > i * 2 + 1 ? array.get(candle.hl, i * 2 + 1) : l

        label.set_x(lbl, midX)
        label.set_y(lbl, labelY)
        label.set_text(lbl, showTimes ? str.format_time(t, timeFormat, syminfo.timezone) : "")
        label.set_textcolor(lbl, timeCol)
        label.set_color(lbl, timeBgCol)
        label.set_size(lbl, timeSize)

// ~~ Range
var line rangeHighLine = na
var line rangeLowLine  = na
var line rangeMidLine  = na

hasHL = array.size(candle.hl) >= 2

if hasHL
    hi = array.max(candle.hl)
    lo = array.min(candle.hl)
    mi = math.avg(hi, lo)

    if Range
        if not na(rangeHighLine)
            line.delete(rangeHighLine)
        if not na(rangeLowLine)
            line.delete(rangeLowLine)

        rangeHighLine := line.new(b, hi, b + numb * 4 + loc + 2, hi, color = high_col)
        rangeLowLine  := line.new(b, lo, b + numb * 4 + loc + 2, lo, color = low_col)

    if Mid
        if not na(rangeMidLine)
            line.delete(rangeMidLine)

        rangeMidLine := line.new(b, mi, b + numb * 4 + loc + 2, mi, color = mid_col)

// ~~ Table
var table tbl = table.new(pos, 2, 11, frame_color = chart.bg_color, frame_width = 2, border_width = 2, border_color = chart.bg_color)

if barstate.islast and showTable
    table.cell(tbl, 0, 0, text = error ? "Error" : "TF", text_color = textcolor, bgcolor = bgcolor, text_size = TblSize)
    table.cell(tbl, 0, 1, text = error ? "The chart's timeframe must be less than the HTF '" + tf + "' timeframe.\n\nor please select a higher timeframe in the setting panel of the indicator." : str.tostring(timeframe.period), text_halign = text.align_center, bgcolor = bgcolor, text_color = textcolor, text_size = TblSize)
    table.cell(tbl, 1, 0, text = "HTF", text_color = textcolor, bgcolor = bgcolor, text_size = TblSize)
    table.cell(tbl, 1, 1, text = str.tostring(tf), text_halign = text.align_center, bgcolor = bgcolor, text_color = textcolor, text_size = TblSize)
````
