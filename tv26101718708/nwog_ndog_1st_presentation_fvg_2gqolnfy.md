# NWOG - NDOG - 1st Presentation FVG

- url: https://www.tradingview.com/script/2gQoLnFY-NWOG-NDOG-1st-Presentation-FVG/
- type: indicator
- pine_id: PUB;a42f39ebd00b44b4be638eed74694680
- version: 7.0

## Description

NWOG – NDOG – 1st Presentation FVG Indicator

This script identifies and plots key ICT-based price delivery concepts, including New Week Opening Gap (NWOG), New Day Opening Gap (NDOG), and the first presentation Fair Value Gap (FVG) of the session.

NWOG (New Week Opening Gap):
Highlights the price gap between the previous week’s close and the current week’s open. This level is used to track potential rebalancing or mean reversion during the week.

NDOG (New Day Opening Gap):
Marks the gap between the previous day’s close and the current day’s open, often acting as an intraday liquidity or target level.

1st Presentation FVG:
Detects the first Fair Value Gap formed after the session begins (typically London or New York). This is considered a high-probability imbalance zone where price may return for mitigation.
The indicator automatically draws these zones on the chart, helping traders identify key liquidity levels, inefficiencies, and potential entry or target areas based on ICT concepts.

## Source Code

````pine
//@version=6
indicator("NWOG - NDOG - 1st Presentation FVG", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ╔══════════════════════════════════════════════╗
// ║           SECTION 1: FVG                     ║
// ╚══════════════════════════════════════════════╝

showFVG        = input.bool(false, "Enable FVG", group="FVG")
showBullish    = input.bool(true, "Bullish", inline="fvgtype", group="FVG")
showBearish    = input.bool(true, "Bearish", inline="fvgtype", group="FVG")
fvgDaysBack    = input.int(5, "Days to Show", minval=1, maxval=365, group="FVG")
amColor        = input.color(color.new(#02a005, 80), "AM Session Fill", inline="fvgcol1", group="FVG")
pmColor        = input.color(color.new(#ff0000, 80), "PM Session Fill", inline="fvgcol1", group="FVG")
amBorderColor  = input.color(color.new(#02a005, 79), "AM Border", inline="fvgcol2", group="FVG")
pmBorderColor  = input.color(color.new(#ff0000, 77), "PM Border", inline="fvgcol2", group="FVG")
amMidColor     = input.color(color.rgb(0, 0, 0), "AM Midline", inline="fvgcol3", group="FVG")
pmMidColor     = input.color(color.rgb(0, 0, 0), "PM Midline", inline="fvgcol3", group="FVG")
fvgLabelColor  = input.color(color.rgb(0, 0, 0), "Label", inline="fvgcol4", group="FVG")

am_startHH     = input.int(9, "AM Start", inline="am", group="FVG AM Session")
am_startMM     = input.int(31, "", inline="am", group="FVG AM Session")
am_endHH       = input.int(10, "AM End", inline="amend", group="FVG AM Session")
am_endMM       = input.int(0, "", inline="amend", group="FVG AM Session")

pm_startHH     = input.int(13, "PM Start", inline="pm", group="FVG PM Session")
pm_startMM     = input.int(0, "", inline="pm", group="FVG PM Session")
pm_endHH       = input.int(14, "PM End", inline="pmend", group="FVG PM Session")
pm_endMM       = input.int(0, "", inline="pmend", group="FVG PM Session")

// ╔══════════════════════════════════════════════╗
// ║           SECTION 2: NWOG                    ║
// ╚══════════════════════════════════════════════╝

showNWOG       = input.bool(true, "Enable NWOG", group="NWOG")
nwogsAmount    = input.int(4, "Count", minval=1, maxval=50, group="NWOG")
nwogColor      = input.color(color.new(color.purple, 80), "Fill", inline="nwcol", group="NWOG")
nwogBorderCol  = input.color(color.rgb(153, 34, 174, 65), "Border", inline="nwcol", group="NWOG")
nwogMidColor   = input.color(color.rgb(0, 0, 0), "Midline", inline="nwcol2", group="NWOG")
nwogLabelCol   = input.color(color.rgb(3, 2, 3), "Label", inline="nwcol2", group="NWOG")

// ╔══════════════════════════════════════════════╗
// ║           SECTION 3: NDOG                    ║
// ╚══════════════════════════════════════════════╝

showNDOG       = input.bool(true, "Enable NDOG", group="NDOG")
ndogsAmount    = input.int(4, "Count", minval=1, maxval=50, group="NDOG")
ndogColor      = input.color(color.new(color.orange, 80), "Fill", inline="ndcol", group="NDOG")
ndogBorderCol  = input.color(color.rgb(255, 153, 1, 77), "Border", inline="ndcol", group="NDOG")
ndogMidColor   = input.color(color.rgb(0, 0, 0), "Midline", inline="ndcol2", group="NDOG")
ndogLabelCol   = input.color(color.rgb(16, 16, 16), "Label", inline="ndcol2", group="NDOG")

// ╔══════════════════════════════════════════════╗
// ║            COMMON                            ║
// ╚══════════════════════════════════════════════╝

nyTZ       = "America/New_York"
nyDay      = dayofmonth(time, nyTZ)
newDay     = ta.change(nyDay) != 0
msPerDay   = 86400000
int EXT    = 3

isNewBar(res) =>
    t = time(res)
    na(t[1]) and not na(t) or t[1] < t

// ╔══════════════════════════════════════════════╗
// ║   FVG LOGIC — Always from 1-minute data      ║
// ╚══════════════════════════════════════════════╝

amStart    = am_startHH * 100 + am_startMM
amEnd      = am_endHH * 100 + am_endMM
pmStart    = pm_startHH * 100 + pm_startMM
pmEnd      = pm_endHH * 100 + pm_endMM

detectFirstFVGs() =>
    _nyH  = hour(time, "America/New_York")
    _nyM  = minute(time, "America/New_York")
    _nyT  = _nyH * 100 + _nyM

    _nyH1 = hour(time[1], "America/New_York")
    _nyM1 = minute(time[1], "America/New_York")
    _nyT1 = _nyH1 * 100 + _nyM1

    _bull = low > high[2] and close[1] > open[1]
    _bear = high < low[2] and close[1] < open[1]

    _day    = dayofmonth(time, "America/New_York")
    _newDay = ta.change(_day) != 0

    var bool  _amFound  = false
    var float _amTop    = na
    var float _amBot    = na
    var bool  _amIsBull = false
    var int   _amCount  = 0
    var bool  _pmFound  = false
    var float _pmTop    = na
    var float _pmBot    = na
    var bool  _pmIsBull = false
    var int   _pmCount  = 0

    if _newDay
        _amFound  := false
        _pmFound  := false
        _amTop    := na
        _amBot    := na
        _pmTop    := na
        _pmBot    := na

    _inAM = (_nyT >= amStart and _nyT <= amEnd) and (_nyT1 >= amStart and _nyT1 <= amEnd)
    _inPM = (_nyT >= pmStart and _nyT <= pmEnd) and (_nyT1 >= pmStart and _nyT1 <= pmEnd)

    _detected = _bull or _bear
    _isBull   = _bull
    _fTop     = _bull ? low : low[2]
    _fBot     = _bull ? high[2] : high

    if _inAM and not _amFound and _detected
        _amTop    := _fTop
        _amBot    := _fBot
        _amIsBull := _isBull
        _amFound  := true
        _amCount  += 1

    if _inPM and not _pmFound and _detected
        _pmTop    := _fTop
        _pmBot    := _fBot
        _pmIsBull := _isBull
        _pmFound  := true
        _pmCount  += 1

    [_amTop, _amBot, _amIsBull, _amCount, _pmTop, _pmBot, _pmIsBull, _pmCount]

[amFvgTop, amFvgBot, amIsBull, amCount, pmFvgTop, pmFvgBot, pmIsBull, pmCount] = request.security(syminfo.tickerid, "1", detectFirstFVGs(), lookahead=barmerge.lookahead_on)

fvgInRange = time >= (last_bar_time - (fvgDaysBack + 1) * msPerDay)

var array<box>   fvgBoxes  = array.new_box()
var array<line>  fvgLines  = array.new_line()
var array<label> fvgLabels = array.new_label()

var float amMidVal = na
var float pmMidVal = na

amJustFound = ta.change(amCount) != 0 and ((amIsBull and showBullish) or (not amIsBull and showBearish))
pmJustFound = ta.change(pmCount) != 0 and ((pmIsBull and showBullish) or (not pmIsBull and showBearish))

if newDay
    amMidVal := na
    pmMidVal := na

if showFVG and amJustFound and fvgInRange
    float mid     = (amFvgTop + amFvgBot) / 2
    array.push(fvgBoxes, box.new(bar_index - 1, amFvgTop, bar_index - 1, amFvgBot, border_color=amBorderColor, bgcolor=amColor))
    array.push(fvgLines, line.new(bar_index, mid, bar_index, mid, color=amMidColor, style=line.style_dotted, width=1))
    array.push(fvgLabels, label.new(bar_index, mid, "NY AM 1st", style=label.style_label_left, color=color.new(color.black, 100), textcolor=fvgLabelColor, size=size.small))
    amMidVal := mid

if showFVG and pmJustFound and fvgInRange
    float mid     = (pmFvgTop + pmFvgBot) / 2
    array.push(fvgBoxes, box.new(bar_index - 1, pmFvgTop, bar_index - 1, pmFvgBot, border_color=pmBorderColor, bgcolor=pmColor))
    array.push(fvgLines, line.new(bar_index, mid, bar_index, mid, color=pmMidColor, style=line.style_dotted, width=1))
    array.push(fvgLabels, label.new(bar_index, mid, "NY PM 1st", style=label.style_label_left, color=color.new(color.black, 100), textcolor=fvgLabelColor, size=size.small))
    pmMidVal := mid

if array.size(fvgBoxes) > 0
    for i = 0 to array.size(fvgBoxes) - 1
        box.set_right(array.get(fvgBoxes, i), bar_index + EXT)
if array.size(fvgLines) > 0
    for i = 0 to array.size(fvgLines) - 1
        line.set_x2(array.get(fvgLines, i), bar_index + EXT)
if array.size(fvgLabels) > 0
    for i = 0 to array.size(fvgLabels) - 1
        label.set_x(array.get(fvgLabels, i), bar_index + EXT)

// ╔══════════════════════════════════════════════╗
// ║       NWOG / NDOG LOGIC                      ║
// ╚══════════════════════════════════════════════╝

// NWOG strictly from 1H weekend transition: Friday close vs Sunday open (NY time).
detectNWOG_1H_FriClose_SunOpen() =>
    _h = hour(time, "America/New_York")
    _m = minute(time, "America/New_York")
    _dow = dayofweek(time, "America/New_York")
    _isSun6pmBar = _dow == dayofweek.sunday and _h == 18 and _m == 0

    var float _top = na
    var float _bot = na
    var int _count = 0

    if _isSun6pmBar
        // On this bar, close[1] is the last tradable bar before weekend (Friday close).
        _top := math.max(close[1], open)
        _bot := math.min(close[1], open)
        _count += 1

    [_top, _bot, _count]

[nwogH, nwogL, nwogCount] = request.security(
    syminfo.tickerid,
    "60",
    detectNWOG_1H_FriClose_SunOpen(),
    lookahead=barmerge.lookahead_on
)

// NDOG strictly from 1H at NY 6:00 PM bar: 5 PM close vs 6 PM open.
detectNDOG_1H_5to6() =>
    _h = hour(time, "America/New_York")
    _m = minute(time, "America/New_York")
    _dow = dayofweek(time, "America/New_York")
    // Skip Sunday 6 PM because that weekend gap is reserved for NWOG.
    _is6pmBar = _h == 18 and _m == 0 and _dow != dayofweek.sunday

    var float _top = na
    var float _bot = na
    var int _count = 0

    if _is6pmBar
        _top := math.max(close[1], open)
        _bot := math.min(close[1], open)
        _count += 1

    [_top, _bot, _count]

[ndogH, ndogL, ndogCount] = request.security(
    syminfo.tickerid,
    "60",
    detectNDOG_1H_5to6(),
    lookahead=barmerge.lookahead_on
)

nwogNew = ta.change(nwogCount) != 0
ndogNew = ta.change(ndogCount) != 0

var array<box>   nwogBoxes  = array.new_box()
var array<line>  nwogLines  = array.new_line()
var array<label> nwogLabels = array.new_label()
var float nwogMidVal = na

bool nwogAllowed = timeframe.isintraday or timeframe.isdaily or (timeframe.isweekly and timeframe.multiplier <= 1)

if showNWOG and nwogAllowed and nwogNew
    float ce = (nwogH + nwogL) / 2
    nwogMidVal := ce

    array.push(nwogBoxes, box.new(bar_index - 1, nwogH, bar_index - 1, nwogL, border_color=nwogBorderCol, bgcolor=nwogColor))
    array.push(nwogLines, line.new(bar_index, ce, bar_index, ce, color=nwogMidColor, style=line.style_dotted, width=1))
    array.push(nwogLabels, label.new(bar_index, ce, "NWOG", style=label.style_label_left, color=color.new(color.black, 100), textcolor=nwogLabelCol, size=size.small))

    if array.size(nwogBoxes) > nwogsAmount
        box.delete(array.shift(nwogBoxes))
    if array.size(nwogLines) > nwogsAmount
        line.delete(array.shift(nwogLines))
    if array.size(nwogLabels) > nwogsAmount
        label.delete(array.shift(nwogLabels))

if array.size(nwogBoxes) > 0
    for i = 0 to array.size(nwogBoxes) - 1
        box.set_right(array.get(nwogBoxes, i), bar_index + EXT)
if array.size(nwogLines) > 0
    for i = 0 to array.size(nwogLines) - 1
        line.set_x2(array.get(nwogLines, i), bar_index + EXT)
if array.size(nwogLabels) > 0
    for i = 0 to array.size(nwogLabels) - 1
        label.set_x(array.get(nwogLabels, i), bar_index + EXT)

var array<box>   ndogBoxes  = array.new_box()
var array<line>  ndogLines  = array.new_line()
var array<label> ndogLabels = array.new_label()
var float ndogMidVal = na

bool ndogAllowed = timeframe.isintraday or (timeframe.isdaily and timeframe.multiplier <= 1)

if showNDOG and ndogAllowed and ndogNew
    float ce = (ndogH + ndogL) / 2
    ndogMidVal := ce

    array.push(ndogBoxes, box.new(bar_index - 1, ndogH, bar_index - 1, ndogL, border_color=ndogBorderCol, bgcolor=ndogColor))
    array.push(ndogLines, line.new(bar_index, ce, bar_index, ce, color=ndogMidColor, style=line.style_dotted, width=1))
    array.push(ndogLabels, label.new(bar_index, ce, "NDOG", style=label.style_label_left, color=color.new(color.black, 100), textcolor=ndogLabelCol, size=size.small))

    if array.size(ndogBoxes) > ndogsAmount
        box.delete(array.shift(ndogBoxes))
    if array.size(ndogLines) > ndogsAmount
        line.delete(array.shift(ndogLines))
    if array.size(ndogLabels) > ndogsAmount
        label.delete(array.shift(ndogLabels))

if array.size(ndogBoxes) > 0
    for i = 0 to array.size(ndogBoxes) - 1
        box.set_right(array.get(ndogBoxes, i), bar_index + EXT)
if array.size(ndogLines) > 0
    for i = 0 to array.size(ndogLines) - 1
        line.set_x2(array.get(ndogLines, i), bar_index + EXT)
if array.size(ndogLabels) > 0
    for i = 0 to array.size(ndogLabels) - 1
        label.set_x(array.get(ndogLabels, i), bar_index + EXT)

// ╔══════════════════════════════════════════════╗
// ║            INFO TABLE                        ║
// ╚══════════════════════════════════════════════╝

var table infoTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Section",   text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, "Midline",   text_color=color.white, text_size=size.small)

    table.cell(infoTable, 0, 1, "NY AM 1st", text_color=fvgLabelColor, text_size=size.small)
    table.cell(infoTable, 1, 1, not na(amMidVal) ? str.tostring(amMidVal, format.mintick) : "—", text_color=fvgLabelColor, text_size=size.small)

    table.cell(infoTable, 0, 2, "NY PM 1st", text_color=fvgLabelColor, text_size=size.small)
    table.cell(infoTable, 1, 2, not na(pmMidVal) ? str.tostring(pmMidVal, format.mintick) : "—", text_color=fvgLabelColor, text_size=size.small)

    table.cell(infoTable, 0, 3, "─────",     text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 3, "─────",     text_color=color.gray, text_size=size.small)

    table.cell(infoTable, 0, 4, "NWOG",      text_color=nwogLabelCol, text_size=size.small)
    table.cell(infoTable, 1, 4, not na(nwogMidVal) ? str.tostring(nwogMidVal, format.mintick) : "—", text_color=nwogLabelCol, text_size=size.small)

    table.cell(infoTable, 0, 5, "NDOG",      text_color=ndogLabelCol, text_size=size.small)
    table.cell(infoTable, 1, 5, not na(ndogMidVal) ? str.tostring(ndogMidVal, format.mintick) : "—", text_color=ndogLabelCol, text_size=size.small)
````
