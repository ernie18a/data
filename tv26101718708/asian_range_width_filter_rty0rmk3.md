# Asian Range + Width Filter

- url: https://www.tradingview.com/script/rTY0rmK3-Asian-Range-Width-Filter/
- type: indicator
- pine_id: PUB;3289a26f7a7941c5a03ec5735f59306a
- version: 1.0

## Description

Asian Range + Width Filter draws the Asian session range every day and tells you whether that range is a normal size or too wide to trade.
 
WHAT IT SHOWS
- A box covering the Asian session high and low (00:00 to 07:00 UK time by default).
- The high, low and 50% midline extended into the London and New York sessions (to 16:00 UK time by default).
- The New York midnight open as a dashed line, a reference level many intraday traders use to judge whether price is at a premium or discount for the day.
- A label with the range size in pips.
 
THE WIDTH FILTER
The range is flagged TOO WIDE and the box turns red when either condition is true:
- The range is larger than a fixed pip limit. Left at 0, this is 30 pips on EUR pairs and 40 pips on GBP pairs.
- The range is more than a set multiple (1.5 by default) of the average range over the last N sessions (20 by default). The average only uses previous sessions, so today's range never influences its own comparison. At least half of N sessions are needed before this check switches on.
The label shows the range, the recent average and the ratio between them, so you can see why a range was flagged.
 
HOW TO USE IT
Use a timeframe of 1 hour or lower. Times are entered in UK time and the switch between GMT and BST is handled automatically. While the session is still forming, the label reads "(forming)". A wide Asian range often means much of the day's move has already happened, so many traders skip or reduce risk on those days.
 
SETTINGS
Session times, how long lines extend, days of history to keep, fixed pip limit, average period and multiplier, plus colours and on/off switches for the midline, NY open and label.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// Asian Range v4 - Power of 3 Asian Range for TradingView
// v4: branding removed for TradingView House Rules
// Draws the Asian session box, extended high/low/mid lines, range size in pips
// (flags "too wide" vs a fixed pip limit OR a multiple of the recent average range)
// and the NY midnight open. Times are UK time (GMT/BST automatic).

//@version=6
indicator("Asian Range + Width Filter", shorttitle = "Asian Range", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ───────── Inputs ─────────
const string TZ    = "Europe/London"
const string TZ_NY = "America/New_York"

grpS = "Session (UK time)"
sess      = input.session("0000-0700", "Asia session",        group = grpS)
extHour   = input.int(16, "Extend lines until (hour)",   minval = 0, maxval = 23, group = grpS, inline = "ext")
extMin    = input.int(0,  ":",                           minval = 0, maxval = 59, group = grpS, inline = "ext")
daysBack  = input.int(10, "Days to keep",                minval = 1, maxval = 60, group = grpS)

grpF = "Range filter"
maxPipsIn = input.float(0, "Fixed max pips (0 = auto: 30 EUR / 40 GBP)", minval = 0, group = grpF)
useAvg    = input.bool(true, "Also flag vs recent average", group = grpF)
avgDays   = input.int(20, "Average of last N days", minval = 5, maxval = 60, group = grpF)
avgMult   = input.float(1.5, "Too wide if more than X times average", minval = 1.0, step = 0.1, group = grpF)

grpD = "Display"
boxCol    = input.color(color.new(#4682B4, 80), "Box (normal)",   group = grpD)
wideCol   = input.color(color.new(#CD5C5C, 75), "Box (too wide)", group = grpD)
hiloCol   = input.color(#1E90FF,                "High / Low lines", group = grpD)
showMid   = input.bool(true,                    "Show 50% line",  group = grpD, inline = "mid")
midCol    = input.color(color.gray,             "",               group = grpD, inline = "mid")
showNY    = input.bool(true,                    "Show NY midnight open", group = grpD, inline = "ny")
nyCol     = input.color(color.orange,           "",               group = grpD, inline = "ny")
showLbl   = input.bool(true,                    "Show pips label", group = grpD, inline = "lbl")
lblCol    = input.color(color.silver,           "",               group = grpD, inline = "lbl")

// ───────── Helpers ─────────
pipSize = syminfo.type == "forex" ? syminfo.mintick * 10 : syminfo.mintick
maxPips = maxPipsIn > 0 ? maxPipsIn : (str.contains(syminfo.ticker, "GBP") ? 40.0 : 30.0)

extTime(int t) =>
    int e = timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), extHour, extMin)
    e <= t ? e + 86400000 : e

tfOK = timeframe.isintraday and timeframe.in_seconds() <= 3600

// ───────── State ─────────
var box   bx     = na
var label lb     = na
var line  mid    = na
var float sHi    = na
var float sLo    = na
var int   sStart = na
var int   sExt   = na

var array<box>   boxes  = array.new<box>()
var array<line>  lines  = array.new<line>()
var array<label> labels = array.new<label>()
var array<float> pastRanges = array.new<float>()   // completed Asian ranges (pips)

// Returns [tooWide, labelText] for a range of `pips`, using previous days only
f_status(float pips) =>
    int   minSamples = math.max(5, math.floor(avgDays / 2))
    float avg        = useAvg and pastRanges.size() >= minSamples ? pastRanges.avg() : na
    bool  wideFixed  = pips > maxPips
    bool  wideAvg    = not na(avg) and avg > 0 and pips > avg * avgMult
    string txt = str.format("Asia {0,number,#.0}p", pips)
    if not na(avg) and avg > 0
        txt += str.format(" | avg {0,number,#.0}p ({1,number,#.0}x)", avg, pips / avg)
    if wideFixed
        txt += str.format("  TOO WIDE (> {0,number,#}p)", maxPips)
    else if wideAvg
        txt += str.format("  TOO WIDE (> {0,number,#.0}x avg)", avgMult)
    [wideFixed or wideAvg, txt]

trim() =>
    while boxes.size() > daysBack
        boxes.shift().delete()
    while lines.size() > daysBack * 4
        lines.shift().delete()
    while labels.size() > daysBack * 2
        labels.shift().delete()

// ───────── Asian session ─────────
inSess  = tfOK and not na(time(timeframe.period, sess, TZ))
newSess = inSess and not inSess[1]
endSess = not inSess and inSess[1]

if newSess
    sHi    := high
    sLo    := low
    sStart := time
    sExt   := extTime(time)
    bx     := box.new(time, high, time_close, low, xloc = xloc.bar_time, bgcolor = boxCol, border_color = color.new(boxCol, 40))
    boxes.push(bx)
    if showLbl
        lb := label.new(time, high, "", xloc = xloc.bar_time, style = label.style_label_lower_left,
             color = color(na), textcolor = lblCol, size = size.small)
        labels.push(lb)
    if showMid
        mid := line.new(time, hl2, sExt, hl2, xloc = xloc.bar_time, color = midCol, style = line.style_dotted)
        lines.push(mid)
    trim()

if inSess
    sHi := math.max(sHi, high)
    sLo := math.min(sLo, low)
    float pips = (sHi - sLo) / pipSize
    [tooWide, txt] = f_status(pips)
    color c = tooWide ? wideCol : boxCol
    bx.set_top(sHi)
    bx.set_bottom(sLo)
    bx.set_right(time_close)
    bx.set_bgcolor(c)
    bx.set_border_color(color.new(c, 40))
    if showMid
        float m = (sHi + sLo) / 2
        mid.set_y1(m)
        mid.set_y2(m)
    if showLbl
        lb.set_y(sHi)
        lb.set_text(txt + "  (forming)")
        lb.set_textcolor(tooWide ? color.red : lblCol)

if endSess and not na(sHi)
    float pips = (sHi - sLo) / pipSize
    [tooWide, txt] = f_status(pips)
    color c = tooWide ? wideCol : boxCol
    bx.set_bgcolor(c)
    bx.set_border_color(color.new(c, 40))
    if sExt > time
        lines.push(line.new(time, sHi, sExt, sHi, xloc = xloc.bar_time, color = hiloCol, width = 1))
        lines.push(line.new(time, sLo, sExt, sLo, xloc = xloc.bar_time, color = hiloCol, width = 1))
    if showLbl
        lb.set_text(txt)
        lb.set_textcolor(tooWide ? color.red : lblCol)
    // store this range for future averages (after evaluating it)
    pastRanges.push(pips)
    while pastRanges.size() > avgDays
        pastRanges.shift()
    trim()

// ───────── NY midnight open ─────────
nyDay   = dayofmonth(time, TZ_NY)
isNYMid = tfOK and nyDay != nyDay[1] and hour(time, TZ_NY) == 0 and dayofweek(time, TZ_NY) != dayofweek.sunday

if showNY and isNYMid
    int e = extTime(time)
    lines.push(line.new(time, open, e, open, xloc = xloc.bar_time, color = nyCol, style = line.style_dashed))
    if showLbl
        labels.push(label.new(time, open, "NY 00:00", xloc = xloc.bar_time, style = label.style_label_upper_left,
             color = color(na), textcolor = nyCol, size = size.tiny))
    trim()

// ───────── Timeframe warning ─────────
if barstate.islast and not tfOK
    var label warn = label.new(bar_index, high, "Asian Range: use a timeframe of 1H or lower",
         style = label.style_label_down, color = color.new(color.orange, 20), textcolor = color.black)
    warn.set_xy(bar_index, high)
````
