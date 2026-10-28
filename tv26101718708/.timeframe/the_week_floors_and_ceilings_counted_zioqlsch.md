# The Week: floors and ceilings, counted

- url: https://www.tradingview.com/script/ZIOQLsCh-The-Week-floors-and-ceilings-counted/
- type: indicator
- pine_id: PUB;e11109cc07f34f4da4c5a6e369826c9c
- version: 2.0

## Description

Last week's high is this week's ceiling. Last week's low is this week's floor. The Week draws both, with last week's close, and counts how often each one has held on the chart you load it on.

The rule is the one I grade my own levels by. Floor: the week must close above it. Ceiling: the week must close under it. Only Friday's close counts. A line can be taken during the week and still hold, if Friday closes back on its side.

WHAT IS DRAWN

The ceiling, last week's high, in blue, from the week's open to Friday's close, with its price at the right end. The floor, last week's low, in gold, the same way. Last week's close, faint and dashed. A dot on the first bar that takes each line during the week, marked when that bar closes. When the week is done, HELD or BROKE beside each line, from Friday's close.

THE PANEL

THIS WEEK: the ceiling, the floor, the close line, and where price sits against them now. ON THIS CHART: counted over every week of the chart's weekly history. How often the week closed under the ceiling, how often the ceiling was taken during the week, and how many of those weeks still closed back under it. The same for the floor, and how many weeks closed up. The count is never reset and always shows how many weeks it rests on. ALL-TIME HIGH: the top of the chart's daily history, with its date.

WHAT WE MEASURED ON GOLD

On TVC:GOLD's weekly history, the 590 weeks from the week of 15 June 2015 to the week of 28 September 2026: the floor held 477 times (81 in 100) and the ceiling 411 (70 in 100). The ceiling was taken in 321 weeks and the week closed back under it in 142 of them (44 in 100). The floor was taken in 243 weeks and the week closed back over it in 130 (53 in 100). 318 weeks closed up (54 in 100). Gold rose over those years and a rising market flatters floors, so read the floor and the ceiling as a pair. Past counts describe the past only.

HOW TO USE IT

Read the panel before the week opens: it tells you how much respect last week's range has had on this symbol. During the week, a dot on a line says it has been taken; only Friday's close says whether it held. The script calls no direction and places no orders.

ALERTS

Closed over the ceiling, and closed under the floor, each on a bar's close.

SETTINGS

Weeks drawn (8): how many weeks of lines stay on the chart; the count always uses every week. Close line: on or off. Panel and count: on or off.

Runs on any symbol, on daily and intraday charts. Nothing repaints: last week's lines are fixed when the week opens, and the dots and tags print on closed bars. Our own maths and code, written from scratch. Free and open source.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bradleypve
//@version=6
indicator("The Week: floors and ceilings, counted", shorttitle = "The Week", overlay = true, max_lines_count = 200, max_labels_count = 250)

//  THE WEEK · version 1.1 · 15 October 2026
//  Last week's high is this week's ceiling, its low this week's floor, its close the close line. Each line carries its
//  own count from the chart's weekly history: how often the week closed back on its side, and how often it was taken.
//  The live week is lit from each line inward, and tagged just right of the last bar, beside the price.
//  Floor: the week must close above it. Ceiling: the week must close under it. Only Friday's close counts.
//  1.1: the count starts at the Count from date and leaves out any week with no range, so years when a price was
//  held fixed do not enter it. Prices of 100 or more print to two decimals.

// ─────────────────────────────────────────────── inputs
int  nWeeks    = input.int(8, "Weeks drawn", minval = 1, maxval = 52, tooltip = "How many weeks of lines stay on the chart. The count uses every week from the Count from date.")
int  tFrom     = input.time(timestamp("01 Jan 1975 00:00 +0000"), "Count from", tooltip = "Weeks before this date are not counted, and neither is a week with no range. On gold the default leaves out the years when its price was held fixed.")
bool showClose = input.bool(true, "Close line", tooltip = "Last week's close, drawn faint.")
bool showPanel = input.bool(true, "Panel and count")

// ─────────────────────────────────────────────── the house palette
color C_GOLD = #E0A93B
color C_BLUE = #6F9CF2
color C_MUTE = #8A94A6
color C_INK  = #F3EFE6
color C_BG   = #0B1730
color C_RED  = #E5625A

// ─────────────────────────────────────────────── the count, on the weekly context
// Each week is graded against the week before it. Returned as it stood before the current week, so nothing repaints.
f_count(int t1) =>
    var array<int> s    = array.new<int>(8, 0)    // weeks, ceiling held, ceiling taken, taken and back under, floor held, floor taken, taken and back over, up weeks
    var int        t0   = na
    array<int> o  = array.copy(s)
    int        oT = t0
    float ceil = high[1]
    float flo  = low[1]
    float pc   = close[1]
    if not na(ceil) and time >= t1 and high > low and high[1] > low[1]
        if na(t0)
            t0 := time
        array.set(s, 0, array.get(s, 0) + 1)
        array.set(s, 1, array.get(s, 1) + (close < ceil ? 1 : 0))
        array.set(s, 2, array.get(s, 2) + (high > ceil ? 1 : 0))
        array.set(s, 3, array.get(s, 3) + (high > ceil and close < ceil ? 1 : 0))
        array.set(s, 4, array.get(s, 4) + (close > flo ? 1 : 0))
        array.set(s, 5, array.get(s, 5) + (low < flo ? 1 : 0))
        array.set(s, 6, array.get(s, 6) + (low < flo and close > flo ? 1 : 0))
        array.set(s, 7, array.get(s, 7) + (close > pc ? 1 : 0))
    [array.get(o, 0), array.get(o, 1), array.get(o, 2), array.get(o, 3), array.get(o, 4), array.get(o, 5), array.get(o, 6), array.get(o, 7), oT]

// the all-time high on the daily context, dated by the gold day it closed on, as it stood before today
f_ath() =>
    var float ath  = na
    var int   athT = na
    float oA  = ath
    int   oAT = athT
    if na(ath) or high > ath
        ath  := high
        athT := time_close
    [oA, oAT]

bool tfOk = timeframe.isintraday or timeframe.isdaily
[wN, cHeld, cTaken, cBack, fHeld, fTaken, fBack, wUp, wT0] = request.security(syminfo.tickerid, "W", f_count(tFrom), lookahead = barmerge.lookahead_on)
[athD, athDT] = request.security(syminfo.tickerid, "D", f_ath(), lookahead = barmerge.lookahead_on)
[ceil, flo, pc] = request.security(syminfo.tickerid, "W", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

// ─────────────────────────────────────────────── this week, bar by bar
bool  newW   = timeframe.change("W")
bool  newD   = timeframe.change("D")
int   dEnd   = time_close("D")
int   wEnd   = time_close("W")
var float dHi  = na
var int   dHiT = na
if newD or na(dHi) or high > dHi
    dHi  := high
    dHiT := dEnd
var bool  cTook = false
var bool  fTook = false
if newW
    cTook := false
    fTook := false

// ─────────────────────────────────────────────── drawing: three lines a week, tags on Friday's close
var array<line>  lns  = array.new<line>()
var array<label> tags = array.new<label>()
var line  lC = na
var line  lF = na
var line  lP = na
var float wkCeil = na
var float wkFlo  = na
var float wkPc   = na
var array<line>     glow  = array.new<line>()       // the live week's light: three bands inside each line, fading inward
var array<linefill> glowF = array.new<linefill>()

f_fmt(float p) =>
    math.abs(p) >= 100 ? str.tostring(p, "#,##0.00") : str.tostring(p, format.mintick)

if tfOk and newW
    // the week that just closed: its lines end at Friday's close, each tagged HELD or BROKE
    if not na(lC)
        float wc = close[1]
        array.push(tags, label.new(time[1], wkCeil, wc < wkCeil ? "HELD" : "BROKE", xloc = xloc.bar_time, style = label.style_label_lower_right,
             color = color.new(C_BG, 15), textcolor = wc < wkCeil ? C_BLUE : C_RED, size = size.tiny))
        array.push(tags, label.new(time[1], wkFlo, wc > wkFlo ? "HELD" : "BROKE", xloc = xloc.bar_time, style = label.style_label_upper_right,
             color = color.new(C_BG, 15), textcolor = wc > wkFlo ? C_GOLD : C_RED, size = size.tiny))
    for f in glowF
        linefill.delete(f)
    for g in glow
        line.delete(g)
    array.clear(glowF)
    array.clear(glow)
    if not na(ceil) and not na(flo)
        wkCeil := ceil
        wkFlo  := flo
        wkPc   := pc
        lC := line.new(time, ceil, wEnd, ceil, xloc = xloc.bar_time, color = C_BLUE, width = 2)
        lF := line.new(time, flo, wEnd, flo, xloc = xloc.bar_time, color = C_GOLD, width = 2)
        array.push(lns, lC)
        array.push(lns, lF)
        if showClose
            lP := line.new(time, pc, wEnd, pc, xloc = xloc.bar_time, color = color.new(C_MUTE, 35), style = line.style_dashed)
            array.push(lns, lP)
        // the light: three bands from each line into the week's range, a twenty-fourth of the range each
        float band = (ceil - flo) / 24.0
        if band > 0
            line prevC = lC
            line prevF = lF
            for k = 1 to 3
                line gC = line.new(time, ceil - band * k, wEnd, ceil - band * k, xloc = xloc.bar_time, color = color(na))
                line gF = line.new(time, flo + band * k, wEnd, flo + band * k, xloc = xloc.bar_time, color = color(na))
                array.push(glow, gC)
                array.push(glow, gF)
                array.push(glowF, linefill.new(prevC, gC, color.new(C_BLUE, 76 + 7 * k)))
                array.push(glowF, linefill.new(prevF, gF, color.new(C_GOLD, 76 + 7 * k)))
                prevC := gC
                prevF := gF
    // keep the chosen number of weeks on the chart
    int per = showClose ? 3 : 2
    while array.size(lns) > nWeeks * per
        line.delete(array.shift(lns))
    while array.size(tags) > (nWeeks - 1) * 4
        label.delete(array.shift(tags))

// the first bar that takes each line this week, marked on its close
if tfOk and barstate.isconfirmed and not na(wkCeil)
    if not cTook and high > wkCeil
        cTook := true
        array.push(tags, label.new(time, wkCeil, "", xloc = xloc.bar_time, style = label.style_circle, color = color.new(C_BLUE, 20), size = size.tiny))
    if not fTook and low < wkFlo
        fTook := true
        array.push(tags, label.new(time, wkFlo, "", xloc = xloc.bar_time, style = label.style_circle, color = color.new(C_GOLD, 20), size = size.tiny))

// the live week's tags just right of the last bar, beside the price
var label tC = na
var label tF = na
var label tP = na
if tfOk and barstate.islast and not na(wkCeil)
    label.delete(tC)
    label.delete(tF)
    label.delete(tP)
    tC := label.new(bar_index + 3, wkCeil, "CEILING " + f_fmt(wkCeil), style = label.style_label_left, color = color(na), textcolor = C_BLUE, size = size.small)
    tF := label.new(bar_index + 3, wkFlo, "FLOOR " + f_fmt(wkFlo), style = label.style_label_left, color = color(na), textcolor = C_GOLD, size = size.small)
    if showClose and not na(wkPc)
        tP := label.new(bar_index + 3, wkPc, "CLOSE LINE " + f_fmt(wkPc), style = label.style_label_left, color = color(na), textcolor = C_MUTE, size = size.tiny)

// ─────────────────────────────────────────────── the panel
var table tb = table.new(position.top_right, 3, 14, bgcolor = color.new(C_BG, 6), border_color = color.new(C_INK, 88), border_width = 1,
     frame_color = color.new(C_INK, 80), frame_width = 1)
f_row(int r, string a, string b, color cb, string c) =>
    table.cell(tb, 0, r, a, text_color = C_MUTE, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, b, text_color = cb, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 2, r, c, text_color = C_MUTE, text_size = size.small, text_halign = text.align_right)
f_sec(int r, string a) =>
    table.cell(tb, 0, r, a, text_color = C_GOLD, text_size = size.tiny, text_halign = text.align_left)
f_pct(int a, int b) =>
    b > 0 ? str.tostring(100.0 * a / b, "0") + " in 100" : ""
if barstate.isfirst
    for r in array.from(1, 6, 13)
        table.merge_cells(tb, 0, r, 2, r)
if showPanel and barstate.islast
    table.cell(tb, 0, 0, "THE WEEK", text_color = C_GOLD, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 2, 0, syminfo.ticker, text_color = C_MUTE, text_size = size.small, text_halign = text.align_right)
    if not tfOk
        f_sec(1, "OPEN A DAILY OR INTRADAY CHART")
    else
        f_sec(1, "THIS WEEK")
        f_row(2, "CEILING", f_fmt(ceil), C_BLUE, "last week's high")
        f_row(3, "FLOOR", f_fmt(flo), C_GOLD, "last week's low")
        f_row(4, "CLOSE LINE", f_fmt(pc), C_INK, "last Friday")
        string now = close > ceil ? "over the ceiling, for now" : close < flo ? "under the floor, for now" : "between the two"
        f_row(5, "NOW", f_fmt(close), C_INK, now)
        f_sec(6, wN > 0 ? "ON THIS CHART SINCE " + str.upper(str.format_time(wT0, "MMM yyyy", "America/New_York")) + " · " + str.tostring(wN) + " WEEKS" : "THE COUNT NEEDS TWO WEEKS")
        f_row(7, "CEILING HELD", str.tostring(cHeld) + " of " + str.tostring(wN), C_BLUE, f_pct(cHeld, wN))
        f_row(8, "CEILING TAKEN", str.tostring(cTaken), C_INK, str.tostring(cBack) + " closed back under")
        f_row(9, "FLOOR HELD", str.tostring(fHeld) + " of " + str.tostring(wN), C_GOLD, f_pct(fHeld, wN))
        f_row(10, "FLOOR TAKEN", str.tostring(fTaken), C_INK, str.tostring(fBack) + " closed back over")
        f_row(11, "UP WEEKS", str.tostring(wUp) + " of " + str.tostring(wN), C_INK, f_pct(wUp, wN))
        bool  newAth = not na(dHi) and (na(athD) or dHi > athD)
        float ath    = newAth ? dHi : athD
        int   athT   = newAth ? dHiT : athDT
        f_row(12, "ALL-TIME HIGH", f_fmt(ath), C_INK, na(athT) ? "" : str.format_time(athT, "d MMM yyyy", "America/New_York"))
        f_sec(13, "ONLY FRIDAY'S CLOSE COUNTS")

// ─────────────────────────────────────────────── alerts, on the bar's close
alertcondition(barstate.isconfirmed and not na(ceil) and close > ceil and close[1] <= ceil, "Closed over the ceiling", "The Week: a bar closed over last week's high.")
alertcondition(barstate.isconfirmed and not na(flo) and close < flo and close[1] >= flo, "Closed under the floor", "The Week: a bar closed under last week's low.")
````
