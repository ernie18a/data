# The Clockface: is the day's high in yet

- url: https://www.tradingview.com/script/85tayZVd-The-Clockface-is-the-day-s-high-in-yet/
- type: indicator
- pine_id: PUB;447e3a7a8d454a8186f596d4baa0eba7
- version: 1.0

## Description

Is today's high already in? The low? The Clockface puts odds on both three times a day, grades every one at the day's close on the chart you load it on, and prints beside each how often odds like it came true on that chart.

HOW THE ODDS ARE MADE

A random walk, sized by yesterday's ATR and the hours left in the gold day. The day's spread is taken as ATR divided by 1.596, the ratio of a random walk's average daily range to its spread, and shrinks with the square root of the hours left. The further price sits from the day's high, and the less time is left, the higher the odds that the high is already in. The same for the low.

On gold that walk says too little in the middle: when it said 50, the high or low was already in 67 times in 100 on our chart. So the script never shows the walk's odds alone. Beside every call it prints what came on your chart at that level.

WHAT IS DRAWN

The day's high and low so far, stepped, each with its price and the time it was made, and the range between them shaded from the high (blue) to the low (gold). Three stamps a day, at 03:00, 10:00 and 14:00 New York: the odds the high (H) and the low (L) were already in. At the day's close each stamp gets its grade: H IN or H OUT, L IN or L OUT. At the live bar: HIGH IN and LOW IN with their odds, and CAME beside each, once that tenth of the scale has 20 graded calls on the chart. The desk's hours as dotted marks: London's open (08:00 London), the LBMA gold auctions (10:30 and 15:00 London), New York's data hour (08:30 New York) and the COMEX settle (13:30 New York). London's first hour and New York's first hour from the data, shaded. Along the bottom, a strip of 24 hours: where each of the last 60 days made its high (blue) and its low (gold).

THE PANEL

NOW, with HIGH IN and LOW IN and what came at those odds on this chart. SAID AND CAME ON THIS CHART: every stamp graded since the chart's first whole day, in five bands of what was said, each with its average said, what came, and how many calls. Never reset. BRIER: the average squared miss of every call, with the number of calls. Lower is closer.

WHAT WE MEASURED

On TVC:GOLD's 10 minute chart, 24 March to 7 October 2026, 137 whole days and 822 calls: said 11, came 13; said 30, came 36; said 50, came 67; said 69, came 82; said 94, came 95. Brier 0.136, against 0.226 for a flat guess at the overall rate. On a longer XAUUSD 15 minute history, 641 days from January 2024, the same walk said 50 and came 57. On both, the walk allowed for more travel than gold made.

The common rule of thumb asks how much of the average daily range is already used. We turned it into odds from gold's own past days, at the same three hours, and wrote the comparison down before running it. On the same 137 days the walk scored 0.136 against the rule's 0.199. Then we ran it once on palladium's 10 minute chart, a metal the script was never built or tested on: 125 days, 0.130 against 0.185. The walk leaned the same way there: said 50, came 58.

We also wrote down a walk run on gold's own clock, the hours sized by how much gold has moved in each, and tested it against this plain walk on that longer history before building. It did not beat it, so the plain walk ships with its miss printed beside it. Past counts describe the past only.

HOW TO USE IT

Read the odds against the clock: the same distance below the high counts for more at 14:00 than at 03:00, because less of the day is left. Read CAME before SAID. The heat strip shows which hours of your clock have been making the day's extremes lately. The script describes the day and calls no direction.

SETTINGS

Clock (New York): New York, London or Madrid, for the times written on the stamps, the desk's hours and the strip. Desk hours: on or off. Panel, ledger and heat strip: on or off. The lines and the shading can each be switched off in the Style tab.

Runs on intraday charts of 30 minutes or less that divide the half hour (1, 5, 10, 15 or 30 minutes, for example). Built on gold's day, 18:00 to 17:00 New York; on another symbol the walk and the ledger run on that symbol's daily bars. The stamps and grades print on closed bars; the live odds move with the price, as they should. Our own maths and code, written from scratch. Free and open source.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bradleypve
//@version=6
indicator("The Clockface: is the day's high in yet", shorttitle = "The Clockface", overlay = true, max_lines_count = 100, max_labels_count = 200, max_boxes_count = 20)

//  THE CLOCKFACE · version 1.0 · 16 October 2026
//  Is today's high already in? The low? The odds from a random walk sized by yesterday's ATR and the hours left in the
//  gold day, stamped three times a day and graded at the close. Beside each call, how often calls like it came true on
//  this chart. The day's high and low so far, marked where they were made, the range between them shaded. The desk's
//  hours on the dial: London's open, the LBMA auctions, New York's data hour, the COMEX settle.

// ─────────────────────────────────────────────── inputs
string clockIn   = input.string("New York", "Clock", options = ["New York", "London", "Madrid"], tooltip = "The time zone the stamps, the desk's hours and the heat strip are written in.")
bool   showDesk  = input.bool(true, "Desk hours", tooltip = "London's open, the LBMA gold auctions, New York's data hour and the COMEX settle, with London's and New York's first hours shaded.")
bool   showPanel = input.bool(true, "Panel, ledger and heat strip")

// ─────────────────────────────────────────────── the house palette
color C_GOLD = #E0A93B
color C_BLUE = #6F9CF2
color C_MUTE = #8A94A6
color C_INK  = #F3EFE6
color C_BG   = #0B1730
color C_RED  = #E5625A

string NY  = "America/New_York"
string LDN = "Europe/London"
string TZ  = clockIn == "New York" ? NY : clockIn == "London" ? LDN : "Europe/Madrid"
int    HR  = 3600000

int  tfSec = timeframe.in_seconds()
bool tfOk  = timeframe.isintraday and tfSec >= 60 and tfSec <= 1800 and 1800 % tfSec == 0

// prices of 100 or more print to two decimals
f_px(float p) =>
    math.abs(p) >= 100 ? str.tostring(p, "#,##0.00") : str.tostring(p, format.mintick)

// yesterday's ATR, from the daily context
float atrD = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead = barmerge.lookahead_on)

// the standard normal distribution, Abramowitz and Stegun 7.1.26
f_phi(float x) =>
    float z = math.abs(x) / math.sqrt(2.0)
    float t = 1.0 / (1.0 + 0.3275911 * z)
    float e = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * math.exp(-z * z)
    x >= 0 ? 0.5 * (1.0 + e) : 0.5 * (1.0 - e)

// ─────────────────────────────────────────────── the gold day so far
bool newD  = timeframe.change("D")
int  dEnd  = time_close("D")
var bool  whole = false                             // the day was seen from its first bar; the chart's first day never counts
var float dHi  = na
var float dLo  = na
var int   dHiT = na
var int   dLoT = na
if newD or na(dHi)
    whole := newD and bar_index > 0
    dHi  := high
    dLo  := low
    dHiT := time
    dLoT := time
else
    if high > dHi
        dHi  := high
        dHiT := time
    if low < dLo
        dLo  := low
        dLoT := time

// the day's high and low so far, stepped, each marked where it was made; the range between them shaded from the high
// (blue) to the low (gold), so the day fills in as it is made
pHiP = plot(tfOk ? dHi : na, "Day's high so far", color = newD ? color(na) : color.new(C_BLUE, 30), style = plot.style_stepline)
pLoP = plot(tfOk ? dLo : na, "Day's low so far", color = newD ? color(na) : color.new(C_GOLD, 30), style = plot.style_stepline)
fill(pHiP, pLoP, dHi, dLo, newD ? color(na) : color.new(C_BLUE, 90), newD ? color(na) : color.new(C_GOLD, 90), "The day so far")
var array<label> exL = array.new<label>()
var label        hiL = na
var label        loL = na
if tfOk and newD
    hiL := label.new(time, dHi, "", xloc = xloc.bar_time, style = label.style_label_down, color = color.new(C_BG, 10), textcolor = C_BLUE, size = size.small)
    loL := label.new(time, dLo, "", xloc = xloc.bar_time, style = label.style_label_up, color = color.new(C_BG, 10), textcolor = C_GOLD, size = size.small)
    array.push(exL, hiL)
    array.push(exL, loL)
    while array.size(exL) > 6
        label.delete(array.shift(exL))
if tfOk and not na(hiL) and (newD or dHiT == time or dLoT == time)
    label.set_xy(hiL, dHiT, dHi)
    label.set_text(hiL, "DAY HIGH " + f_px(dHi) + " AT " + str.format_time(dHiT, "HH:mm", TZ))
    label.set_xy(loL, dLoT, dLo)
    label.set_text(loL, "DAY LOW " + f_px(dLo) + " AT " + str.format_time(dLoT, "HH:mm", TZ))

// the walk's odds that the high (low) is already in
float left = (dEnd - time_close) / float(HR)
float sdW  = atrD / 1.596 * math.sqrt(math.max(left, 0.0) / 23.0)
float pHi  = left > 0 and sdW > 0 ? 2.0 * f_phi((dHi - close) / sdW) - 1.0 : 1.0
float pLo  = left > 0 and sdW > 0 ? 2.0 * f_phi((close - dLo) / sdW) - 1.0 : 1.0

// ─────────────────────────────────────────────── the ledger: three stamps a day, graded at the close
var array<float> sSaidH = array.new<float>()       // today's stamps
var array<float> sSaidL = array.new<float>()
var array<float> sHiAt  = array.new<float>()
var array<float> sLoAt  = array.new<float>()
var array<label> sLab   = array.new<label>()
var array<float> b10N   = array.new<float>(10, 0.0) // ten bins of what was said, for the lookup beside each call
var array<float> b10C   = array.new<float>(10, 0.0)
var array<float> b5N    = array.new<float>(5, 0.0)  // five bins for the panel
var array<float> b5S    = array.new<float>(5, 0.0)
var array<float> b5C    = array.new<float>(5, 0.0)
var array<float> acc = array.new<float>(2, 0.0)    // the Brier sum and the number of calls
var int   nDays  = 0
var array<int> heatH = array.new<int>()            // the hour each of the last 60 days made its high and its low
var array<int> heatL = array.new<int>()

f_bin10(float p) =>
    math.min(int(math.floor(p * 10.0)), 9)
f_add(float p, bool came) =>
    int i10 = f_bin10(p)
    array.set(b10N, i10, array.get(b10N, i10) + 1.0)
    array.set(b10C, i10, array.get(b10C, i10) + (came ? 1.0 : 0.0))
    int i5 = math.min(int(math.floor(p * 5.0)), 4)
    array.set(b5N, i5, array.get(b5N, i5) + 1.0)
    array.set(b5S, i5, array.get(b5S, i5) + p)
    array.set(b5C, i5, array.get(b5C, i5) + (came ? 1.0 : 0.0))
    array.set(acc, 0, array.get(acc, 0) + math.pow(p - (came ? 1.0 : 0.0), 2))
    array.set(acc, 1, array.get(acc, 1) + 1.0)
f_came(float p) =>
    int i = f_bin10(p)
    float n = array.get(b10N, i)
    n >= 20 ? str.tostring(100.0 * array.get(b10C, i) / n, "0") : "·"

// a day that never reached its close (a short session) drops its stamps ungraded
if newD
    array.clear(sSaidH)
    array.clear(sSaidL)
    array.clear(sHiAt)
    array.clear(sLoAt)

if tfOk and barstate.isconfirmed and not na(atrD)
    // a stamp at 03:00, 10:00 and 14:00 New York
    if whole and minute(time_close, NY) == 0 and (hour(time_close, NY) == 3 or hour(time_close, NY) == 10 or hour(time_close, NY) == 14) and left > 0
        array.push(sSaidH, pHi)
        array.push(sSaidL, pLo)
        array.push(sHiAt, dHi)
        array.push(sLoAt, dLo)
        label lb = label.new(time, dLo, str.format_time(time_close, "HH:mm", TZ) + " SAID\nH " + str.tostring(pHi * 100, "0") + " · L " + str.tostring(pLo * 100, "0"),
             xloc = xloc.bar_time, style = label.style_label_up, color = color.new(C_BG, 10), textcolor = C_INK, size = size.small)
        array.push(sLab, lb)
    // the gold day's last bar grades the day's stamps
    if time_close >= dEnd and whole
        int m = array.size(sSaidH)
        if m > 0
            for j = 0 to m - 1
                bool hIn = dHi <= array.get(sHiAt, j)
                bool lIn = dLo >= array.get(sLoAt, j)
                f_add(array.get(sSaidH, j), hIn)
                f_add(array.get(sSaidL, j), lIn)
                label lb = array.get(sLab, array.size(sLab) - m + j)   // today's stamps are the last m labels
                label.set_text(lb, label.get_text(lb) + "\n" + (hIn ? "H IN" : "H OUT") + " · " + (lIn ? "L IN" : "L OUT"))
        nDays += 1
        array.push(heatH, hour(dHiT, TZ))
        array.push(heatL, hour(dLoT, TZ))
        if array.size(heatH) > 60
            array.shift(heatH)
            array.shift(heatL)
        array.clear(sSaidH)
        array.clear(sSaidL)
        array.clear(sHiAt)
        array.clear(sLoAt)
        while array.size(sLab) > 6
            label.delete(array.shift(sLab))

// ─────────────────────────────────────────────── the desk's hours and the two opens
var array<line>  dLines = array.new<line>()
var array<label> dTags  = array.new<label>()
var array<box>   oBoxes = array.new<box>()
var float lonH = na
var float lonL = na
var int   lonT = na
var float nyH  = na
var float nyL  = na
var int   nyT  = na
f_deskMark(string name) =>
    array.push(dLines, line.new(time, high, time, low, xloc = xloc.bar_time, extend = extend.both, color = color.new(C_MUTE, 55), style = line.style_dotted))
    array.push(dTags, label.new(time, high, name + " " + str.format_time(time, "HH:mm", TZ), xloc = xloc.bar_time, yloc = yloc.abovebar,
         style = label.style_none, textcolor = C_MUTE, size = size.tiny))
    while array.size(dLines) > 10
        line.delete(array.shift(dLines))
        label.delete(array.shift(dTags))

if tfOk and showDesk and barstate.isconfirmed
    int lh = hour(time, LDN)
    int lm = minute(time, LDN)
    int nh = hour(time, NY)
    int nm = minute(time, NY)
    if lh == 8 and lm == 0
        f_deskMark("LONDON OPENS")
    if lh == 10 and lm == 30
        f_deskMark("LBMA AM")
    if nh == 8 and nm == 30
        f_deskMark("NEW YORK DATA")
    if lh == 15 and lm == 0
        f_deskMark("LBMA PM")
    if nh == 13 and nm == 30
        f_deskMark("COMEX SETTLE")
    // London's first hour, 08:00 to 09:00 London, and New York's, 08:30 to 09:30 New York, shaded
    if lh == 8
        lonH := lm == 0 or na(lonH) ? high : math.max(lonH, high)
        lonL := lm == 0 or na(lonL) ? low : math.min(lonL, low)
        lonT := lm == 0 or na(lonT) ? time : lonT
        if hour(time_close, LDN) == 9 and minute(time_close, LDN) == 0
            array.push(oBoxes, box.new(lonT, lonH, time_close, lonL, xloc = xloc.bar_time, bgcolor = color.new(C_BLUE, 85), border_color = color.new(C_BLUE, 40)))
            lonH := na
            lonL := na
            lonT := na
    bool inNy = (nh == 8 and nm >= 30) or (nh == 9 and nm < 30)
    if inNy
        bool first = nh == 8 and nm == 30
        nyH := first or na(nyH) ? high : math.max(nyH, high)
        nyL := first or na(nyL) ? low : math.min(nyL, low)
        nyT := first or na(nyT) ? time : nyT
        if hour(time_close, NY) == 9 and minute(time_close, NY) == 30
            array.push(oBoxes, box.new(nyT, nyH, time_close, nyL, xloc = xloc.bar_time, bgcolor = color.new(C_GOLD, 85), border_color = color.new(C_GOLD, 40)))
            nyH := na
            nyL := na
            nyT := na
    while array.size(oBoxes) > 4
        box.delete(array.shift(oBoxes))

// ─────────────────────────────────────────────── the live call, at the last bar
var label liveL = na
if barstate.islast and tfOk and not na(atrD)
    label.delete(liveL)
    string txt = "HIGH IN " + str.tostring(pHi * 100, "0") + " · CAME " + f_came(pHi) + " HERE\nLOW IN " + str.tostring(pLo * 100, "0") + " · CAME " + f_came(pLo) + " HERE"
    liveL := label.new(bar_index + 2, close, txt, style = label.style_label_left, color = color.new(C_BG, 8), textcolor = C_INK, size = size.small)

// ─────────────────────────────────────────────── the panel and the heat strip
var table tb = table.new(position.top_right, 3, 13, bgcolor = color.new(C_BG, 6), border_color = color.new(C_INK, 88), border_width = 1,
     frame_color = color.new(C_INK, 80), frame_width = 1)
var table hs = table.new(position.bottom_center, 25, 3, bgcolor = color.new(C_BG, 15), border_color = color.new(C_BG, 0), border_width = 1)
f_row(int r, string a, string b, color cb, string c) =>
    table.cell(tb, 0, r, a, text_color = C_MUTE, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, b, text_color = cb, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 2, r, c, text_color = C_MUTE, text_size = size.small, text_halign = text.align_right)
f_sec(int r, string a) =>
    table.cell(tb, 0, r, a, text_color = C_GOLD, text_size = size.tiny, text_halign = text.align_left)
if barstate.isfirst
    for r in array.from(4, 11, 12)
        table.merge_cells(tb, 0, r, 2, r)
if showPanel and barstate.islast
    table.cell(tb, 0, 0, "THE CLOCKFACE", text_color = C_GOLD, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 2, 0, syminfo.ticker, text_color = C_MUTE, text_size = size.small, text_halign = text.align_right)
    if not tfOk
        f_sec(4, "OPEN A 1, 5, 10, 15 OR 30 MINUTE CHART")
    else
        f_row(1, "NOW", str.format_time(time_close, "HH:mm", TZ), C_INK, clockIn + " · graded at the close")
        f_row(2, "HIGH IN", str.tostring(pHi * 100, "0") + " in 100", C_BLUE, "came " + f_came(pHi) + " here")
        f_row(3, "LOW IN", str.tostring(pLo * 100, "0") + " in 100", C_GOLD, "came " + f_came(pLo) + " here")
        f_sec(4, "SAID AND CAME ON THIS CHART · " + str.tostring(nDays) + " DAYS")
        for i = 0 to 4
            float n = array.get(b5N, i)
            f_row(5 + i, "said " + str.tostring(i * 20) + " to " + str.tostring((i + 1) * 20),
                 n > 0 ? "said " + str.tostring(100 * array.get(b5S, i) / n, "0") : "·", C_INK,
                 n > 0 ? "came " + str.tostring(100 * array.get(b5C, i) / n, "0") + " · " + str.tostring(n, "0") : "")
        float nC = array.get(acc, 1)
        f_row(10, "BRIER", nC > 0 ? str.tostring(array.get(acc, 0) / nC, "0.000") : "·", C_INK, str.tostring(nC, "0") + " calls")
        f_sec(11, "THE WALK, SIZED BY YESTERDAY'S ATR")
        f_sec(12, "DESCRIBES THE DAY; CALLS NO DIRECTION")
    // the heat strip: where the day's high (blue) and low (gold) were made, by hour, the last 60 days
    int nh = array.size(heatH)
    if nh > 0 and tfOk
        array<int> cH = array.new<int>(24, 0)
        array<int> cL = array.new<int>(24, 0)
        for v in heatH
            array.set(cH, v, array.get(cH, v) + 1)
        for v in heatL
            array.set(cL, v, array.get(cL, v) + 1)
        int mx = int(math.max(array.max(cH), array.max(cL)))
        table.cell(hs, 0, 0, clockIn, text_color = C_MUTE, text_size = size.tiny)
        table.cell(hs, 0, 1, "HIGH", text_color = C_BLUE, text_size = size.tiny)
        table.cell(hs, 0, 2, "LOW", text_color = C_GOLD, text_size = size.tiny)
        for h = 0 to 23
            table.cell(hs, h + 1, 0, h % 3 == 0 ? str.tostring(h, "00") : "", text_color = C_MUTE, text_size = size.tiny)
            int a = array.get(cH, h)
            int b = array.get(cL, h)
            table.cell(hs, h + 1, 1, "", width = 1.2, height = 1.5, bgcolor = color.new(C_BLUE, a == 0 ? 92 : 85 - 75 * a / mx))
            table.cell(hs, h + 1, 2, "", width = 1.2, height = 1.5, bgcolor = color.new(C_GOLD, b == 0 ? 92 : 85 - 75 * b / mx))
````
