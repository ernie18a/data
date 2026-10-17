# ICT Algo MACRO Tracker by Leveragedincome

- url: https://www.tradingview.com/script/c6y1pUxY-ICT-Algo-MACRO-Tracker-by-Leveragedincome/
- type: indicator
- pine_id: PUB;223e189e0e2c4939a3251143045f5219
- version: 1.0

## Description

# ICT Algo MACRO Tracker by Leveragedincome

A fully customizable visual tracker for ICT-style algorithmic macro time windows on intraday charts. Marks every active macro with a labeled bracket on chart (or a colored box in a separate pane), and projects a forward-looking marker for the next upcoming macro so you can prepare ahead of each session.

---

## What is a "macro"?

ICT methodology identifies recurring intraday windows — typically 20 minutes long, around the :50–:10 of each hour — when algorithmic order flow is observably more active in liquid instruments such as ES, NQ, YM, RTY, gold, oil, and FX majors. Traders use these windows to time entries, exits, and confirmations rather than reacting at random points during the session.

This indicator highlights every macro window directly on your chart in **America/New_York** time, regardless of your chart's timezone, so all bracketed regions line up with the algorithm's clock.

---

## Key features

- **26 fully customizable macro slots.** Every macro has an independent enable toggle and editable Start/End hour and minute. Re-time them, disable the ones you don't trade, or repurpose them for any session-based template — equity open, FX London/NY overlap, news prints, or your own playbook.
- **Two display modes.**
  - *On Chart*: bracket-style overlay drawn just above price, with a label and tooltip on each macro.
  - *New Pane*: compact colored boxes in a separate pane below the chart, ideal for keeping price clean.
- **Macro projections** *(optional)*: extend each macro's vertical lines down to current price for a clear visual anchor against highs/lows formed inside the window.
- **Next Upcoming Macro marker.** A forward-projected line + label on the right edge of the chart shows which macro fires next and when. Color, line style (Solid / Dashed / Dotted), and vertical span (Above Price / Full Visible Range) are all configurable. The marker updates in real time as macros come and go.
- **Friday weekend handling.** On non-crypto symbols, New-Pane macro boxes that close on Friday extend across the weekend so they remain visible at Sunday open.

---

## Default macro set

Out of the box, the indicator covers the standard ICT macros plus a few extras:

**Hourly Macros** (default-on for the active US session, off for overnight)
- 02:50 – 03:10
- 03:50 – 04:10
- 04:50 – 05:10
- 09:50 – 10:10
- 10:50 – 11:10
- 11:50 – 12:10
- 12:50 – 13:10
- 13:50 – 14:10
- (additional disabled-by-default hourly slots covering every other hour of the day, ready to enable or re-time)

**Other Macros**
- 14:50 – 15:10 (NY PM open)
- **Last Hr MACRO** — 15:15 – 15:45
- 15:50 – 16:10 (NY close)
- **Lunch MACRO** — 11:30 – 13:30 (the broader NY lunch consolidation window)

Every time and label is editable in the settings — defaults are merely a starting point.

---

## How to use

1. Add the indicator to an intraday chart. Works on any timeframe; **1m to 15m** is the typical range for ICT macro analysis.
2. Open the indicator settings. For each macro, toggle it on/off and edit the Start/End hour and minute fields if you want to depart from the default.
3. Choose your preferred display mode under the Macro Color row: *On Chart* or *New Pane*. If you pick New Pane, drag the indicator into its own pane (TradingView does not do this automatically).
4. Optional add-ons:
   - Enable **Macro Projections** to drop vertical guides from each macro down to price.
   - Enable **Show Next Macro Marker** to see the next session previewed on the right edge of the chart, with a tooltip naming the upcoming macro and its time.

---

## Notes

- All times are evaluated in **America/New_York** time (handles DST automatically). Your chart's display timezone does not need to match.
- On lower timeframes the macro window aligns precisely with bar boundaries. On higher timeframes (e.g. 1H), the window snaps to the nearest enclosing bar and may appear wider than the literal HH:MM range.
- The on-chart label is anchored just above recent price highs and tracks intrabar highs throughout the macro for visibility.

---

## Credits

Based on the open-source **ICT Algorithmic Macro Tracker°** by © **toodegrees**, released under MPL-2.0.

This version adds:
- Fully editable Start/End times for every macro
- A dedicated **Lunch MACRO** slot (11:30 – 13:30) and **Last Hr MACRO** rename for the 15:15 macro
- Forward-looking **Next Upcoming Macro** marker
- Updated to **Pine Script v6** with stricter type safety and defensive rendering fixes

---

*This script is a chart-marking tool. It does not generate trade signals or execute orders. Use it alongside your own analysis and risk management.*

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © toodegrees
// Modifications: customizable macro times, next-upcoming-macro preview, updated to Pine Script v6
//@version=6
indicator("ICT Algo MACRO Tracker by Leveragedincome"
         , shorttitle       = "ICT Algo MACRO Tracker"
         , overlay          = true
         , max_lines_count  = 500
         , max_labels_count = 500
         , max_boxes_count  = 500)


// ===== GLOBALS =====
var line[]  EXT      = array.new<line>()
var label[] LBL      = array.new<label>()
var line    nxtLine  = na
var label   nxtLbl   = na

oneDayMS    = 86400000
oneBarMS    = time_close - time
noColor     = color.new(#ffffff, 100)
one         = ta.highest(timeframe.in_seconds("15") / timeframe.in_seconds(timeframe.period)) + syminfo.mintick * 10
y_btm_Line1 = one
y_top_Line1 = one + syminfo.mintick * 5


// ===== DISPLAY INPUTS =====
_macroC = input.color(color.new(#000000, 0),  title="Macro Color",        inline='main')
_mode   = input.string("On Chart",            title="",                   inline='main',
                       options=["On Chart", "New Pane"],
                       tooltip='When "New Pane" is selected, make sure you move the indicator to a New Pane as well, it is not automatic.')

_showL  = input.bool(true,  title="Macro Label?",       inline='sh')
_mTxt   = input.bool(false, title="Show Time?",         inline='sh')
_extt   = input.bool(false, title="Macro Projections?", inline='sh',
                     tooltip='Extends On Chart Macro lines towards price.')

_bgm    = input.color(color.new(#4caf50, 70), title="Macro Color (Pane)", inline='bc',
                      tooltip='Visible only in "New Pane" mode')

// ===== NEXT-UPCOMING-MACRO INPUTS =====
gN        = "Next Upcoming Macro"
_showNext = input.bool(true,                          title="Show Next Macro Marker", group=gN)
_nextC    = input.color(color.new(#2196f3, 0),        title="Marker Color",            group=gN)
_nextStyle= input.string("Dashed",                    title="Line Style", options=["Dashed","Dotted","Solid"], group=gN)
_nextSpan = input.string("Above Price",               title="Vertical Span",
                          options=["Above Price","Full Visible Range"], group=gN,
                          tooltip="Above Price: small marker above current price (consistent with existing macro markers). Full Visible Range: vertical line that spans the visible chart range.")


// ===== HELPERS =====
fmtTime(int h, int m) =>
    (h < 10 ? "0" : "") + str.tostring(h) + ":" + (m < 10 ? "0" : "") + str.tostring(m)

makeLbl(int hs, int ms, int he, int me) =>
    fmtTime(hs, ms) + " - " + fmtTime(he, me)

nextMacroTime(int hs, int ms) =>
    y  = year(time, "America/New_York")
    mo = month(time, "America/New_York")
    d  = dayofmonth(time, "America/New_York")
    todayT = timestamp("America/New_York", y, mo, d, hs, ms, 0)
    todayT > time ? todayT : todayT + oneDayMS

styleFromName(string s) =>
    s == "Dotted" ? line.style_dotted : s == "Solid" ? line.style_solid : line.style_dashed


// ===== CORE FUNCTIONS =====
time_isMacro(int H_start, int M_start, int H_end, int M_end) =>
    h = hour(time, "America/New_York")
    m = minute(time, "America/New_York")
    h == H_start ? (H_start != H_end ? m >= M_start : m >= M_start and m < M_end) : (h > H_start ? (h == H_end ? m < M_end : h < H_end) : false)

_controlMacroLine(line[] _lines, label[] _lbl, bool _time) =>
    if _time
        if _lbl.size() > 0
            _lbl.last().set_x(math.round(math.avg(_lines.get(_lines.size()-2).get_x1(), time)))
        if high > _lines.last().get_y2() - syminfo.mintick * 10
            _lines.get(_lines.size()-2).set_y2(high + (syminfo.mintick * 10))
            _lines.last().set_y1(high + (syminfo.mintick * 10))
            _lines.last().set_y2(high + (syminfo.mintick * 10))
            if LBL.size() > 0
                LBL.last().set_y(high + (syminfo.mintick * 10))
        if _lines.last().get_x2() == time
            _lines.last().set_x2(time + oneBarMS)

_controlMacroBox(box[] _boxes, bool _time, bool _friday) =>
    dly = _friday ? oneDayMS * 3 : oneDayMS
    if _time
        _boxes.last().set_right(time + dly)

method memoryCleanLine(line[] A) =>
    if A.size() > 300
        for i = 0 to 3
            A.shift().delete()

method memoryCleanLabel(label[] A) =>
    if A.size() > 100
        A.shift().delete()

macroOC(line[] LINES, bool _time, string _kzTime, bool _friday, string _name = "MACRO") =>
    dly  = _friday ? oneDayMS * 3 : oneDayMS
    _txt = _mTxt ? _name + "\n" + _kzTime : _name
    _tt  = _name + "\n" + _kzTime

    if not _time[1] and _time
        _vline1 = line.new(time, y_btm_Line1, time, y_top_Line1, xloc=xloc.bar_time, color=_macroC)
        LINES.push(_vline1)
        _hline = line.new(time, y_top_Line1, time + oneBarMS, y_top_Line1, xloc=xloc.bar_time, color=_macroC)
        LINES.push(_hline)
        if _extt
            EXT.push(line.new(time, high, time, _vline1.get_y2(), xloc=xloc.bar_time, color=_macroC, style=line.style_dotted))
        if _mode == "On Chart"
            LBL.push(label.new(time
                             , LINES.get(LINES.size()-2).get_y2()
                             , _showL ? _txt : ""
                             , tooltip   = _tt
                             , xloc      = xloc.bar_time
                             , style     = label.style_label_down
                             , color     = noColor
                             , textcolor = _macroC
                             , size      = size.small))

    if _time[1] and not _time and LINES.size() > 0
        _vline2 = line.new(time, y_btm_Line1, time, y_top_Line1, xloc=xloc.bar_time, color=_macroC)
        if LBL.size() > 0
            LBL.last().set_x(math.round(math.avg(LINES.get(LINES.size()-2).get_x1(), time)))
        if y_top_Line1 > LINES.get(LINES.size()-2).get_y2()
            LINES.get(LINES.size()-2).set_y2(y_top_Line1)
            LINES.last().set_y1(y_top_Line1)
            LINES.last().set_y2(y_top_Line1)
            if LBL.size() > 0
                LBL.last().set_y(y_top_Line1)
        else if y_top_Line1 < LINES.get(LINES.size()-2).get_y2()
            _vline2.set_y2(LINES.get(LINES.size()-2).get_y2())
        if _extt
            EXT.push(line.new(time, high, time, _vline2.get_y2(), xloc=xloc.bar_time, color=_macroC, style=line.style_dotted))
        LINES.push(_vline2)

    if LINES.size() > 0
        _controlMacroLine(LINES, LBL, _time)


macroNP(box[] BOXES, bool _time, string _kzTime, bool _friday, string _name = "MACRO") =>
    dly  = _friday ? oneDayMS * 3 : oneDayMS
    _col = _bgm
    _tt  = _name + "\n" + _kzTime

    var _plotNP = false
    if not _time[1] and _time
        _macro = box.new(time + dly, 2, time + dly, 0, _macroC, xloc=xloc.bar_time, bgcolor=_col)
        BOXES.push(_macro)
        _plotNP := true

    if _time[1] and not _time and BOXES.size() > 0
        _controlMacroBox(BOXES, true, dayofweek(time) == dayofweek.friday and syminfo.type != 'crypto')
        _plotNP := false
        macroL = label.new(math.round(math.avg(BOXES.last().get_left(), BOXES.last().get_right()))
                         , 1
                         , xloc      = xloc.bar_time
                         , style     = label.style_label_center
                         , color     = noColor
                         , tooltip   = _tt
                         , text      = 'ⓘ\n\n\n\n\n\n'
                         , textcolor = _macroC
                         , size      = size.small)

    if _time and _plotNP
        _controlMacroBox(BOXES, _time, dayofweek(time) == dayofweek.friday and syminfo.type != 'crypto')


// ===== MACRO INPUTS & STATE (each macro: enable + start HH/MM + end HH/MM) =====
gH = "Hourly Macros"
gP = "Other Macros"

show1  = input.bool(false, "Macro 1",  group=gH, inline="1")
h1s    = input.int(0,  "Start", group=gH, inline="1", minval=0, maxval=23)
m1s    = input.int(50, ":",     group=gH, inline="1", minval=0, maxval=59)
h1e    = input.int(1,  "End",   group=gH, inline="1", minval=0, maxval=23)
m1e    = input.int(10, ":",     group=gH, inline="1", minval=0, maxval=59)
var line[] _LINES1 = array.new<line>()
var box[]  _BOXES1 = array.new<box>()
time1  = time_isMacro(h1s, m1s, h1e, m1e)
lbl1   = makeLbl(h1s, m1s, h1e, m1e)

show2  = input.bool(false, "Macro 2",  group=gH, inline="2")
h2s    = input.int(1,  "Start", group=gH, inline="2", minval=0, maxval=23)
m2s    = input.int(50, ":",     group=gH, inline="2", minval=0, maxval=59)
h2e    = input.int(2,  "End",   group=gH, inline="2", minval=0, maxval=23)
m2e    = input.int(10, ":",     group=gH, inline="2", minval=0, maxval=59)
var line[] _LINES2 = array.new<line>()
var box[]  _BOXES2 = array.new<box>()
time2  = time_isMacro(h2s, m2s, h2e, m2e)
lbl2   = makeLbl(h2s, m2s, h2e, m2e)

show3  = input.bool(true,  "Macro 3",  group=gH, inline="3")
h3s    = input.int(2,  "Start", group=gH, inline="3", minval=0, maxval=23)
m3s    = input.int(50, ":",     group=gH, inline="3", minval=0, maxval=59)
h3e    = input.int(3,  "End",   group=gH, inline="3", minval=0, maxval=23)
m3e    = input.int(10, ":",     group=gH, inline="3", minval=0, maxval=59)
var line[] _LINES3 = array.new<line>()
var box[]  _BOXES3 = array.new<box>()
time3  = time_isMacro(h3s, m3s, h3e, m3e)
lbl3   = makeLbl(h3s, m3s, h3e, m3e)

show4  = input.bool(true,  "Macro 4",  group=gH, inline="4")
h4s    = input.int(3,  "Start", group=gH, inline="4", minval=0, maxval=23)
m4s    = input.int(50, ":",     group=gH, inline="4", minval=0, maxval=59)
h4e    = input.int(4,  "End",   group=gH, inline="4", minval=0, maxval=23)
m4e    = input.int(10, ":",     group=gH, inline="4", minval=0, maxval=59)
var line[] _LINES4 = array.new<line>()
var box[]  _BOXES4 = array.new<box>()
time4  = time_isMacro(h4s, m4s, h4e, m4e)
lbl4   = makeLbl(h4s, m4s, h4e, m4e)

show5  = input.bool(true,  "Macro 5",  group=gH, inline="5")
h5s    = input.int(4,  "Start", group=gH, inline="5", minval=0, maxval=23)
m5s    = input.int(50, ":",     group=gH, inline="5", minval=0, maxval=59)
h5e    = input.int(5,  "End",   group=gH, inline="5", minval=0, maxval=23)
m5e    = input.int(10, ":",     group=gH, inline="5", minval=0, maxval=59)
var line[] _LINES5 = array.new<line>()
var box[]  _BOXES5 = array.new<box>()
time5  = time_isMacro(h5s, m5s, h5e, m5e)
lbl5   = makeLbl(h5s, m5s, h5e, m5e)

show6  = input.bool(false, "Macro 6",  group=gH, inline="6")
h6s    = input.int(5,  "Start", group=gH, inline="6", minval=0, maxval=23)
m6s    = input.int(50, ":",     group=gH, inline="6", minval=0, maxval=59)
h6e    = input.int(6,  "End",   group=gH, inline="6", minval=0, maxval=23)
m6e    = input.int(10, ":",     group=gH, inline="6", minval=0, maxval=59)
var line[] _LINES6 = array.new<line>()
var box[]  _BOXES6 = array.new<box>()
time6  = time_isMacro(h6s, m6s, h6e, m6e)
lbl6   = makeLbl(h6s, m6s, h6e, m6e)

show7  = input.bool(false, "Macro 7",  group=gH, inline="7")
h7s    = input.int(6,  "Start", group=gH, inline="7", minval=0, maxval=23)
m7s    = input.int(50, ":",     group=gH, inline="7", minval=0, maxval=59)
h7e    = input.int(7,  "End",   group=gH, inline="7", minval=0, maxval=23)
m7e    = input.int(10, ":",     group=gH, inline="7", minval=0, maxval=59)
var line[] _LINES7 = array.new<line>()
var box[]  _BOXES7 = array.new<box>()
time7  = time_isMacro(h7s, m7s, h7e, m7e)
lbl7   = makeLbl(h7s, m7s, h7e, m7e)

show8  = input.bool(false, "Macro 8",  group=gH, inline="8")
h8s    = input.int(7,  "Start", group=gH, inline="8", minval=0, maxval=23)
m8s    = input.int(50, ":",     group=gH, inline="8", minval=0, maxval=59)
h8e    = input.int(8,  "End",   group=gH, inline="8", minval=0, maxval=23)
m8e    = input.int(10, ":",     group=gH, inline="8", minval=0, maxval=59)
var line[] _LINES8 = array.new<line>()
var box[]  _BOXES8 = array.new<box>()
time8  = time_isMacro(h8s, m8s, h8e, m8e)
lbl8   = makeLbl(h8s, m8s, h8e, m8e)

show9  = input.bool(false, "Macro 9",  group=gH, inline="9")
h9s    = input.int(8,  "Start", group=gH, inline="9", minval=0, maxval=23)
m9s    = input.int(50, ":",     group=gH, inline="9", minval=0, maxval=59)
h9e    = input.int(9,  "End",   group=gH, inline="9", minval=0, maxval=23)
m9e    = input.int(10, ":",     group=gH, inline="9", minval=0, maxval=59)
var line[] _LINES9 = array.new<line>()
var box[]  _BOXES9 = array.new<box>()
time9  = time_isMacro(h9s, m9s, h9e, m9e)
lbl9   = makeLbl(h9s, m9s, h9e, m9e)

show10 = input.bool(true,  "Macro 10", group=gH, inline="10")
h10s   = input.int(9,  "Start", group=gH, inline="10", minval=0, maxval=23)
m10s   = input.int(50, ":",     group=gH, inline="10", minval=0, maxval=59)
h10e   = input.int(10, "End",   group=gH, inline="10", minval=0, maxval=23)
m10e   = input.int(10, ":",     group=gH, inline="10", minval=0, maxval=59)
var line[] _LINES10 = array.new<line>()
var box[]  _BOXES10 = array.new<box>()
time10 = time_isMacro(h10s, m10s, h10e, m10e)
lbl10  = makeLbl(h10s, m10s, h10e, m10e)

show11 = input.bool(true,  "Macro 11", group=gH, inline="11")
h11s   = input.int(10, "Start", group=gH, inline="11", minval=0, maxval=23)
m11s   = input.int(50, ":",     group=gH, inline="11", minval=0, maxval=59)
h11e   = input.int(11, "End",   group=gH, inline="11", minval=0, maxval=23)
m11e   = input.int(10, ":",     group=gH, inline="11", minval=0, maxval=59)
var line[] _LINES11 = array.new<line>()
var box[]  _BOXES11 = array.new<box>()
time11 = time_isMacro(h11s, m11s, h11e, m11e)
lbl11  = makeLbl(h11s, m11s, h11e, m11e)

show12 = input.bool(true,  "Macro 12", group=gH, inline="12")
h12s   = input.int(11, "Start", group=gH, inline="12", minval=0, maxval=23)
m12s   = input.int(50, ":",     group=gH, inline="12", minval=0, maxval=59)
h12e   = input.int(12, "End",   group=gH, inline="12", minval=0, maxval=23)
m12e   = input.int(10, ":",     group=gH, inline="12", minval=0, maxval=59)
var line[] _LINES12 = array.new<line>()
var box[]  _BOXES12 = array.new<box>()
time12 = time_isMacro(h12s, m12s, h12e, m12e)
lbl12  = makeLbl(h12s, m12s, h12e, m12e)

show13 = input.bool(true,  "Macro 13", group=gH, inline="13")
h13s   = input.int(12, "Start", group=gH, inline="13", minval=0, maxval=23)
m13s   = input.int(50, ":",     group=gH, inline="13", minval=0, maxval=59)
h13e   = input.int(13, "End",   group=gH, inline="13", minval=0, maxval=23)
m13e   = input.int(10, ":",     group=gH, inline="13", minval=0, maxval=59)
var line[] _LINES13 = array.new<line>()
var box[]  _BOXES13 = array.new<box>()
time13 = time_isMacro(h13s, m13s, h13e, m13e)
lbl13  = makeLbl(h13s, m13s, h13e, m13e)

show14 = input.bool(true,  "Macro 14", group=gH, inline="14")
h14s   = input.int(13, "Start", group=gH, inline="14", minval=0, maxval=23)
m14s   = input.int(50, ":",     group=gH, inline="14", minval=0, maxval=59)
h14e   = input.int(14, "End",   group=gH, inline="14", minval=0, maxval=23)
m14e   = input.int(10, ":",     group=gH, inline="14", minval=0, maxval=59)
var line[] _LINES14 = array.new<line>()
var box[]  _BOXES14 = array.new<box>()
time14 = time_isMacro(h14s, m14s, h14e, m14e)
lbl14  = makeLbl(h14s, m14s, h14e, m14e)

show17 = input.bool(false, "Macro 17", group=gH, inline="17")
h17s   = input.int(16, "Start", group=gH, inline="17", minval=0, maxval=23)
m17s   = input.int(50, ":",     group=gH, inline="17", minval=0, maxval=59)
h17e   = input.int(17, "End",   group=gH, inline="17", minval=0, maxval=23)
m17e   = input.int(10, ":",     group=gH, inline="17", minval=0, maxval=59)
var line[] _LINES17 = array.new<line>()
var box[]  _BOXES17 = array.new<box>()
time17 = time_isMacro(h17s, m17s, h17e, m17e)
lbl17  = makeLbl(h17s, m17s, h17e, m17e)

show18 = input.bool(false, "Macro 18", group=gH, inline="18")
h18s   = input.int(17, "Start", group=gH, inline="18", minval=0, maxval=23)
m18s   = input.int(50, ":",     group=gH, inline="18", minval=0, maxval=59)
h18e   = input.int(18, "End",   group=gH, inline="18", minval=0, maxval=23)
m18e   = input.int(10, ":",     group=gH, inline="18", minval=0, maxval=59)
var line[] _LINES18 = array.new<line>()
var box[]  _BOXES18 = array.new<box>()
time18 = time_isMacro(h18s, m18s, h18e, m18e)
lbl18  = makeLbl(h18s, m18s, h18e, m18e)

show19 = input.bool(false, "Macro 19", group=gH, inline="19")
h19s   = input.int(18, "Start", group=gH, inline="19", minval=0, maxval=23)
m19s   = input.int(50, ":",     group=gH, inline="19", minval=0, maxval=59)
h19e   = input.int(19, "End",   group=gH, inline="19", minval=0, maxval=23)
m19e   = input.int(10, ":",     group=gH, inline="19", minval=0, maxval=59)
var line[] _LINES19 = array.new<line>()
var box[]  _BOXES19 = array.new<box>()
time19 = time_isMacro(h19s, m19s, h19e, m19e)
lbl19  = makeLbl(h19s, m19s, h19e, m19e)

show20 = input.bool(false, "Macro 20", group=gH, inline="20")
h20s   = input.int(19, "Start", group=gH, inline="20", minval=0, maxval=23)
m20s   = input.int(50, ":",     group=gH, inline="20", minval=0, maxval=59)
h20e   = input.int(20, "End",   group=gH, inline="20", minval=0, maxval=23)
m20e   = input.int(10, ":",     group=gH, inline="20", minval=0, maxval=59)
var line[] _LINES20 = array.new<line>()
var box[]  _BOXES20 = array.new<box>()
time20 = time_isMacro(h20s, m20s, h20e, m20e)
lbl20  = makeLbl(h20s, m20s, h20e, m20e)

show21 = input.bool(false, "Macro 21", group=gH, inline="21")
h21s   = input.int(20, "Start", group=gH, inline="21", minval=0, maxval=23)
m21s   = input.int(50, ":",     group=gH, inline="21", minval=0, maxval=59)
h21e   = input.int(21, "End",   group=gH, inline="21", minval=0, maxval=23)
m21e   = input.int(10, ":",     group=gH, inline="21", minval=0, maxval=59)
var line[] _LINES21 = array.new<line>()
var box[]  _BOXES21 = array.new<box>()
time21 = time_isMacro(h21s, m21s, h21e, m21e)
lbl21  = makeLbl(h21s, m21s, h21e, m21e)

show22 = input.bool(false, "Macro 22", group=gH, inline="22")
h22s   = input.int(21, "Start", group=gH, inline="22", minval=0, maxval=23)
m22s   = input.int(50, ":",     group=gH, inline="22", minval=0, maxval=59)
h22e   = input.int(22, "End",   group=gH, inline="22", minval=0, maxval=23)
m22e   = input.int(10, ":",     group=gH, inline="22", minval=0, maxval=59)
var line[] _LINES22 = array.new<line>()
var box[]  _BOXES22 = array.new<box>()
time22 = time_isMacro(h22s, m22s, h22e, m22e)
lbl22  = makeLbl(h22s, m22s, h22e, m22e)

show23 = input.bool(false, "Macro 23", group=gH, inline="23")
h23s   = input.int(22, "Start", group=gH, inline="23", minval=0, maxval=23)
m23s   = input.int(50, ":",     group=gH, inline="23", minval=0, maxval=59)
h23e   = input.int(23, "End",   group=gH, inline="23", minval=0, maxval=23)
m23e   = input.int(10, ":",     group=gH, inline="23", minval=0, maxval=59)
var line[] _LINES23 = array.new<line>()
var box[]  _BOXES23 = array.new<box>()
time23 = time_isMacro(h23s, m23s, h23e, m23e)
lbl23  = makeLbl(h23s, m23s, h23e, m23e)

show24 = input.bool(false, "Macro 24", group=gH, inline="24")
h24s   = input.int(23, "Start", group=gH, inline="24", minval=0, maxval=23)
m24s   = input.int(50, ":",     group=gH, inline="24", minval=0, maxval=59)
h24e   = input.int(0,  "End",   group=gH, inline="24", minval=0, maxval=23)
m24e   = input.int(10, ":",     group=gH, inline="24", minval=0, maxval=59)
var line[] _LINES24 = array.new<line>()
var box[]  _BOXES24 = array.new<box>()
time24 = time_isMacro(h24s, m24s, h24e, m24e)
lbl24  = makeLbl(h24s, m24s, h24e, m24e)

show15 = input.bool(true, "Macro 15", group=gP, inline="15")
h15s   = input.int(14, "Start", group=gP, inline="15", minval=0, maxval=23)
m15s   = input.int(50, ":",     group=gP, inline="15", minval=0, maxval=59)
h15e   = input.int(15, "End",   group=gP, inline="15", minval=0, maxval=23)
m15e   = input.int(10, ":",     group=gP, inline="15", minval=0, maxval=59)
var line[] _LINES15 = array.new<line>()
var box[]  _BOXES15 = array.new<box>()
time15 = time_isMacro(h15s, m15s, h15e, m15e)
lbl15  = makeLbl(h15s, m15s, h15e, m15e)

showPM1 = input.bool(true, "Last Hr Macro", group=gP, inline="PM1")
hPM1s   = input.int(15, "Start", group=gP, inline="PM1", minval=0, maxval=23)
mPM1s   = input.int(15, ":",     group=gP, inline="PM1", minval=0, maxval=59)
hPM1e   = input.int(15, "End",   group=gP, inline="PM1", minval=0, maxval=23)
mPM1e   = input.int(45, ":",     group=gP, inline="PM1", minval=0, maxval=59)
var line[] _LINESPM1 = array.new<line>()
var box[]  _BOXESPM1 = array.new<box>()
timePM1 = time_isMacro(hPM1s, mPM1s, hPM1e, mPM1e)
lblPM1  = makeLbl(hPM1s, mPM1s, hPM1e, mPM1e)

show16 = input.bool(true, "Macro 16", group=gP, inline="16")
h16s   = input.int(15, "Start", group=gP, inline="16", minval=0, maxval=23)
m16s   = input.int(50, ":",     group=gP, inline="16", minval=0, maxval=59)
h16e   = input.int(16, "End",   group=gP, inline="16", minval=0, maxval=23)
m16e   = input.int(10, ":",     group=gP, inline="16", minval=0, maxval=59)
var line[] _LINES16 = array.new<line>()
var box[]  _BOXES16 = array.new<box>()
time16 = time_isMacro(h16s, m16s, h16e, m16e)
lbl16  = makeLbl(h16s, m16s, h16e, m16e)

showLunch = input.bool(true, "Lunch Macro", group=gP, inline="Lunch")
hLunchS   = input.int(11, "Start", group=gP, inline="Lunch", minval=0, maxval=23)
mLunchS   = input.int(30, ":",     group=gP, inline="Lunch", minval=0, maxval=59)
hLunchE   = input.int(13, "End",   group=gP, inline="Lunch", minval=0, maxval=23)
mLunchE   = input.int(30, ":",     group=gP, inline="Lunch", minval=0, maxval=59)
var line[] _LINESLunch = array.new<line>()
var box[]  _BOXESLunch = array.new<box>()
timeLunch = time_isMacro(hLunchS, mLunchS, hLunchE, mLunchE)
lblLunch  = makeLbl(hLunchS, mLunchS, hLunchE, mLunchE)


// ===== PLOT =====
isFri = dayofweek(time) == dayofweek.friday and syminfo.type != 'crypto'

if _mode == "On Chart"
    if show1
        macroOC(_LINES1, time1, lbl1, isFri)
    if show2
        macroOC(_LINES2, time2, lbl2, isFri)
    if show3
        macroOC(_LINES3, time3, lbl3, isFri)
    if show4
        macroOC(_LINES4, time4, lbl4, isFri)
    if show5
        macroOC(_LINES5, time5, lbl5, isFri)
    if show6
        macroOC(_LINES6, time6, lbl6, isFri)
    if show7
        macroOC(_LINES7, time7, lbl7, isFri)
    if show8
        macroOC(_LINES8, time8, lbl8, isFri)
    if show9
        macroOC(_LINES9, time9, lbl9, isFri)
    if show10
        macroOC(_LINES10, time10, lbl10, isFri)
    if show11
        macroOC(_LINES11, time11, lbl11, isFri)
    if show12
        macroOC(_LINES12, time12, lbl12, isFri)
    if show13
        macroOC(_LINES13, time13, lbl13, isFri)
    if show14
        macroOC(_LINES14, time14, lbl14, isFri)
    if show15
        macroOC(_LINES15, time15, lbl15, isFri)
    if show16
        macroOC(_LINES16, time16, lbl16, isFri)
    if show17
        macroOC(_LINES17, time17, lbl17, isFri)
    if show18
        macroOC(_LINES18, time18, lbl18, isFri)
    if show19
        macroOC(_LINES19, time19, lbl19, isFri)
    if show20
        macroOC(_LINES20, time20, lbl20, isFri)
    if show21
        macroOC(_LINES21, time21, lbl21, isFri)
    if show22
        macroOC(_LINES22, time22, lbl22, isFri)
    if show23
        macroOC(_LINES23, time23, lbl23, isFri)
    if show24
        macroOC(_LINES24, time24, lbl24, isFri)
    if showPM1
        macroOC(_LINESPM1, timePM1, lblPM1, isFri, "Last Hr MACRO")
    if showLunch
        macroOC(_LINESLunch, timeLunch, lblLunch, isFri, "Lunch MACRO")
else
    if show1
        macroNP(_BOXES1, time1, lbl1, isFri)
    if show2
        macroNP(_BOXES2, time2, lbl2, isFri)
    if show3
        macroNP(_BOXES3, time3, lbl3, isFri)
    if show4
        macroNP(_BOXES4, time4, lbl4, isFri)
    if show5
        macroNP(_BOXES5, time5, lbl5, isFri)
    if show6
        macroNP(_BOXES6, time6, lbl6, isFri)
    if show7
        macroNP(_BOXES7, time7, lbl7, isFri)
    if show8
        macroNP(_BOXES8, time8, lbl8, isFri)
    if show9
        macroNP(_BOXES9, time9, lbl9, isFri)
    if show10
        macroNP(_BOXES10, time10, lbl10, isFri)
    if show11
        macroNP(_BOXES11, time11, lbl11, isFri)
    if show12
        macroNP(_BOXES12, time12, lbl12, isFri)
    if show13
        macroNP(_BOXES13, time13, lbl13, isFri)
    if show14
        macroNP(_BOXES14, time14, lbl14, isFri)
    if show15
        macroNP(_BOXES15, time15, lbl15, isFri)
    if show16
        macroNP(_BOXES16, time16, lbl16, isFri)
    if show17
        macroNP(_BOXES17, time17, lbl17, isFri)
    if show18
        macroNP(_BOXES18, time18, lbl18, isFri)
    if show19
        macroNP(_BOXES19, time19, lbl19, isFri)
    if show20
        macroNP(_BOXES20, time20, lbl20, isFri)
    if show21
        macroNP(_BOXES21, time21, lbl21, isFri)
    if show22
        macroNP(_BOXES22, time22, lbl22, isFri)
    if show23
        macroNP(_BOXES23, time23, lbl23, isFri)
    if show24
        macroNP(_BOXES24, time24, lbl24, isFri)
    if showPM1
        macroNP(_BOXESPM1, timePM1, lblPM1, isFri, "Last Hr MACRO")
    if showLunch
        macroNP(_BOXESLunch, timeLunch, lblLunch, isFri, "Lunch MACRO")


// ===== NEXT-UPCOMING-MACRO MARKER =====
// Redrawn on every realtime tick of the last bar so it tracks "what's coming next".
if barstate.islast
    if not na(nxtLine)
        line.delete(nxtLine)
        nxtLine := na
    if not na(nxtLbl)
        label.delete(nxtLbl)
        nxtLbl := na

    if _showNext
        int    bestT = na
        string bestL = ""

        if show1
            t = nextMacroTime(h1s, m1s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl1
        if show2
            t = nextMacroTime(h2s, m2s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl2
        if show3
            t = nextMacroTime(h3s, m3s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl3
        if show4
            t = nextMacroTime(h4s, m4s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl4
        if show5
            t = nextMacroTime(h5s, m5s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl5
        if show6
            t = nextMacroTime(h6s, m6s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl6
        if show7
            t = nextMacroTime(h7s, m7s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl7
        if show8
            t = nextMacroTime(h8s, m8s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl8
        if show9
            t = nextMacroTime(h9s, m9s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl9
        if show10
            t = nextMacroTime(h10s, m10s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl10
        if show11
            t = nextMacroTime(h11s, m11s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl11
        if show12
            t = nextMacroTime(h12s, m12s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl12
        if show13
            t = nextMacroTime(h13s, m13s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl13
        if show14
            t = nextMacroTime(h14s, m14s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl14
        if show15
            t = nextMacroTime(h15s, m15s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl15
        if show16
            t = nextMacroTime(h16s, m16s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl16
        if show17
            t = nextMacroTime(h17s, m17s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl17
        if show18
            t = nextMacroTime(h18s, m18s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl18
        if show19
            t = nextMacroTime(h19s, m19s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl19
        if show20
            t = nextMacroTime(h20s, m20s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl20
        if show21
            t = nextMacroTime(h21s, m21s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl21
        if show22
            t = nextMacroTime(h22s, m22s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl22
        if show23
            t = nextMacroTime(h23s, m23s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl23
        if show24
            t = nextMacroTime(h24s, m24s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := lbl24
        if showPM1
            t = nextMacroTime(hPM1s, mPM1s)
            if na(bestT) or t < bestT
                bestT := t
                bestL := "Last Hr MACRO " + lblPM1
        if showLunch
            t = nextMacroTime(hLunchS, mLunchS)
            if na(bestT) or t < bestT
                bestT := t
                bestL := "Lunch MACRO " + lblLunch

        if not na(bestT)
            float yLo = _nextSpan == "Full Visible Range" ? ta.lowest(low, 500)  : y_btm_Line1
            float yHi = _nextSpan == "Full Visible Range" ? ta.highest(high, 500) : y_top_Line1
            nxtLine := line.new(bestT, yLo, bestT, yHi,
                                xloc  = xloc.bar_time,
                                color = _nextC,
                                style = styleFromName(_nextStyle),
                                width = 1)
            nxtLbl := label.new(bestT, yHi,
                                "⏰ Next: " + bestL,
                                xloc      = xloc.bar_time,
                                style     = label.style_label_lower_left,
                                color     = noColor,
                                textcolor = _nextC,
                                size      = size.small,
                                tooltip   = "Next upcoming macro\n" + bestL + "\nNY time")


// ===== MEMORY CLEANUP =====
if show1
    _LINES1.memoryCleanLine()
if show2
    _LINES2.memoryCleanLine()
if show3
    _LINES3.memoryCleanLine()
if show4
    _LINES4.memoryCleanLine()
if show5
    _LINES5.memoryCleanLine()
if show6
    _LINES6.memoryCleanLine()
if show7
    _LINES7.memoryCleanLine()
if show8
    _LINES8.memoryCleanLine()
if show9
    _LINES9.memoryCleanLine()
if show10
    _LINES10.memoryCleanLine()
if show11
    _LINES11.memoryCleanLine()
if show12
    _LINES12.memoryCleanLine()
if show13
    _LINES13.memoryCleanLine()
if show14
    _LINES14.memoryCleanLine()
if show15
    _LINES15.memoryCleanLine()
if show16
    _LINES16.memoryCleanLine()
if show17
    _LINES17.memoryCleanLine()
if show18
    _LINES18.memoryCleanLine()
if show19
    _LINES19.memoryCleanLine()
if show20
    _LINES20.memoryCleanLine()
if show21
    _LINES21.memoryCleanLine()
if show22
    _LINES22.memoryCleanLine()
if show23
    _LINES23.memoryCleanLine()
if show24
    _LINES24.memoryCleanLine()
if showPM1
    _LINESPM1.memoryCleanLine()
if showLunch
    _LINESLunch.memoryCleanLine()

EXT.memoryCleanLine()
LBL.memoryCleanLabel()
````
