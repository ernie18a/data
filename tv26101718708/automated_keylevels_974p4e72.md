# Automated KeyLevels

- url: https://www.tradingview.com/script/974P4e72-Automated-KeyLevels/
- type: indicator
- pine_id: PUB;c6c4ed7f03de4c39a9f031628f48cf46
- version: 1.0

## Description

Indicator set that plots key levels and includes a “next move probability” table based on historical level breaks/retests from chart data.

Use it best on 1-minute, 3-minute, or 5-minute charts. The probability table is based on historical first breaks from the data loaded on your chart, so it is a guide, not a guarantee.

## Source Code

````pine
//@version=5
indicator("PM + ORB + Midnight Levels Extended Right", overlay=true, max_lines_count=500, max_labels_count=500)

// Settings
tz = input.string("America/New_York", "Market Time Zone")
premarketSession = input.session("0400-0929", "Premarket Session")
midnightSession  = input.session("0000-0929", "Midnight Range Session")

showPM    = input.bool(true, "Show Premarket Levels")
showMID   = input.bool(true, "Show Midnight Levels")
showORB   = input.bool(true, "Show ORB Levels")
showTable = input.bool(true, "Show Stats Table")

labelOffset = input.int(15, "Label Offset To Right", minval=1, maxval=100)

// Time Logic
newDay = ta.change(time("D", tz))
rthStart = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 9, 30)

inPM  = not na(time(timeframe.period, premarketSession, tz))
inMID = not na(time(timeframe.period, midnightSession, tz))

// Premarket Levels
var float pmHigh = na
var float pmLow  = na

if newDay
    pmHigh := na
    pmLow  := na

if inPM
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow) ? low : math.min(pmLow, low)

// Midnight Levels
var float midHigh = na
var float midLow  = na

if newDay
    midHigh := na
    midLow  := na

if inMID
    midHigh := na(midHigh) ? high : math.max(midHigh, high)
    midLow  := na(midLow) ? low : math.min(midLow, low)

// ORB Levels
orb15Active = time >= rthStart and time < rthStart + 15 * 60000
orb30Active = time >= rthStart and time < rthStart + 30 * 60000
orb60Active = time >= rthStart and time < rthStart + 60 * 60000

var float orb15High = na
var float orb15Low  = na
var float orb30High = na
var float orb30Low  = na
var float orb60High = na
var float orb60Low  = na

if newDay
    orb15High := na
    orb15Low  := na
    orb30High := na
    orb30Low  := na
    orb60High := na
    orb60Low  := na

if orb15Active
    orb15High := na(orb15High) ? high : math.max(orb15High, high)
    orb15Low  := na(orb15Low) ? low : math.min(orb15Low, low)

if orb30Active
    orb30High := na(orb30High) ? high : math.max(orb30High, high)
    orb30Low  := na(orb30Low) ? low : math.min(orb30Low, low)

if orb60Active
    orb60High := na(orb60High) ? high : math.max(orb60High, high)
    orb60Low  := na(orb60Low) ? low : math.min(orb60Low, low)

// Line and Label Arrays
var line[] levelLines = array.new_line(10)
var label[] levelLabels = array.new_label(10)

// Draw Level Function
f_drawLevel(_index, _show, _price, _name, _color) =>
    line ln = array.get(levelLines, _index)
    label lb = array.get(levelLabels, _index)

    if _show and not na(_price)
        if na(ln)
            ln := line.new(bar_index, _price, bar_index + 1, _price, extend=extend.right, color=_color, width=2)
            array.set(levelLines, _index, ln)
        else
            line.set_xy1(ln, bar_index - 1, _price)
            line.set_xy2(ln, bar_index + 1, _price)
            line.set_extend(ln, extend.right)
            line.set_color(ln, _color)
            line.set_width(ln, 2)

        if na(lb)
            lb := label.new(bar_index + labelOffset, _price, _name, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=_color, textcolor=color.white, size=size.small)
            array.set(levelLabels, _index, lb)
        else
            label.set_x(lb, bar_index + labelOffset)
            label.set_y(lb, _price)
            label.set_text(lb, _name)
            label.set_color(lb, _color)
            label.set_textcolor(lb, color.white)

    else
        if not na(ln)
            line.delete(ln)
            array.set(levelLines, _index, na)

        if not na(lb)
            label.delete(lb)
            array.set(levelLabels, _index, na)

// Draw All Levels
f_drawLevel(0, showPM, pmHigh, "PM High", color.blue)
f_drawLevel(1, showPM, pmLow, "PM Low", color.blue)

f_drawLevel(2, showMID, midHigh, "Midnight High", color.purple)
f_drawLevel(3, showMID, midLow, "Midnight Low", color.purple)

f_drawLevel(4, showORB, orb15High, "ORB 15 High", color.green)
f_drawLevel(5, showORB, orb15Low, "ORB 15 Low", color.green)

f_drawLevel(6, showORB, orb30High, "ORB 30 High", color.orange)
f_drawLevel(7, showORB, orb30Low, "ORB 30 Low", color.orange)

f_drawLevel(8, showORB, orb60High, "ORB 60 High", color.red)
f_drawLevel(9, showORB, orb60Low, "ORB 60 Low", color.red)

// Probability Counters
var int pmUp = 0
var int pmDown = 0
var int midUp = 0
var int midDown = 0
var int orb15Up = 0
var int orb15Down = 0
var int orb30Up = 0
var int orb30Down = 0
var int orb60Up = 0
var int orb60Down = 0

var bool pmDone = false
var bool midDone = false
var bool o15Done = false
var bool o30Done = false
var bool o60Done = false

if newDay
    pmDone := false
    midDone := false
    o15Done := false
    o30Done := false
    o60Done := false

pmReady = not inPM and not na(pmHigh) and not na(pmLow)
midReady = not inMID and not na(midHigh) and not na(midLow)
orb15Ready = time >= rthStart + 15 * 60000 and not na(orb15High) and not na(orb15Low)
orb30Ready = time >= rthStart + 30 * 60000 and not na(orb30High) and not na(orb30Low)
orb60Ready = time >= rthStart + 60 * 60000 and not na(orb60High) and not na(orb60Low)

if pmReady and not pmDone
    if high > pmHigh
        pmUp += 1
        pmDone := true
    else if low < pmLow
        pmDown += 1
        pmDone := true

if midReady and not midDone
    if high > midHigh
        midUp += 1
        midDone := true
    else if low < midLow
        midDown += 1
        midDone := true

if orb15Ready and not o15Done
    if high > orb15High
        orb15Up += 1
        o15Done := true
    else if low < orb15Low
        orb15Down += 1
        o15Done := true

if orb30Ready and not o30Done
    if high > orb30High
        orb30Up += 1
        o30Done := true
    else if low < orb30Low
        orb30Down += 1
        o30Done := true

if orb60Ready and not o60Done
    if high > orb60High
        orb60Up += 1
        o60Done := true
    else if low < orb60Low
        orb60Down += 1
        o60Done := true

// Table Helper
f_tableRow(_table, _row, _name, _up, _down) =>
    total = _up + _down
    upPct = total > 0 ? math.round(_up / total * 100) : na
    downPct = total > 0 ? math.round(_down / total * 100) : na
    bias = na(upPct) ? "N/A" : upPct > downPct ? "UP" : downPct > upPct ? "DOWN" : "NEUTRAL"
    table.cell(_table, 0, _row, _name)
    table.cell(_table, 1, _row, na(upPct) ? "N/A" : str.tostring(upPct) + "%")
    table.cell(_table, 2, _row, na(downPct) ? "N/A" : str.tostring(downPct) + "%")
    table.cell(_table, 3, _row, bias)

// Stats Table
var table stats = table.new(position.top_right, 4, 6, border_width=1)

if barstate.islast and showTable
    table.cell(stats, 0, 0, "Level", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 1, 0, "Upside %", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 2, 0, "Downside %", bgcolor=color.black, text_color=color.white)
    table.cell(stats, 3, 0, "Bias", bgcolor=color.black, text_color=color.white)

    f_tableRow(stats, 1, "Premarket", pmUp, pmDown)
    f_tableRow(stats, 2, "Midnight", midUp, midDown)
    f_tableRow(stats, 3, "ORB 15", orb15Up, orb15Down)
    f_tableRow(stats, 4, "ORB 30", orb30Up, orb30Down)
    f_tableRow(stats, 5, "ORB 60", orb60Up, orb60Down)
````
