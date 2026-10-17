# Timing (FxAlireza)

- url: https://www.tradingview.com/script/RgMzEGAv-Timing-FxAlireza/
- type: indicator
- pine_id: PUB;704c015def4d4907a047a3824260caad
- version: 1.0

## Description

Timing: Intraday Time Points and Session Windows for TradingView

Price behaves differently at different times of the day. Timing puts the day’s time structure directly on your chart, so you always know which part of the day you are in and what comes next, without checking a clock or a separate table.

What it shows

Time points. Vertical dotted lines with a time label at nine key moments (GMT+3): 03:00, 04:00, 08:00, 09:00, 10:00, 16:30, 18:00, 20:00 and 23:00.
Graded time windows. The full 24 hours is split into windows with no gaps or overlaps. Each window is shaded on the chart background and labeled with its grade and time range when it starts.
Grade A (highest priority, green): 02:30-03:00, 10:00-13:00, 15:30-18:00
Grade B (medium priority, orange): 03:00-10:00, 18:00-23:00
Grade C (lowest priority, gray): 23:00-02:30, 13:00-15:30
Live info panel. The current time, the active window and its grade, and the time left until the next time point.

Settings

Time reference: GMT+3 (default, fixed, no daylight saving shifts), the exchange timezone of the symbol, or a custom offset such as GMT+2 or GMT+3:30.
Days to draw: 1 to 30 days of history for lines and labels.
Colors, line style and width, background transparency, and an on/off switch for every element (lines, labels, windows, panel).

How to use it

Add the indicator to an intraday chart. Timeframes of 30 minutes or lower give the most accurate result.
Leave the time reference on GMT+3 unless you have a reason to change it.
Use the grades to plan your day. Concentrate your attention on A windows, be more selective in B windows, and stay cautious in C windows.
Use the time points as reference marks for planning entries, reviews and session transitions.

Good to know

It works on intraday timeframes only. On daily and higher, the panel will tell you to switch.
On timeframes above 30 minutes, a bar’s background color follows its opening time, so short windows may not appear exactly.
Timing is a time-structure reference. It does not generate buy or sell signals and does not open or close trades.

## Source Code

````pine
//@version=6
indicator('Timing', shorttitle = 'Timing', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================
// Timing - time points (vertical lines) + A/B/C time windows
// All times are defined in GMT+3 (fixed, no DST) by default.
// Works on intraday timeframes only.
// ============================================================

// ---------------- Inputs ----------------
G0 = 'General'
G1 = 'Time points'
G2 = 'Time windows (A / B / C)'
G3 = 'Panel'

tzMode = input.string('GMT+3', 'Time reference', options = ['GMT+3', 'Exchange timezone (auto)', 'Custom'], group = G0, tooltip = 'GMT+3: fixed, as the windows are defined.\nExchange timezone (auto): uses the timezone of the chart symbol.\nCustom: uses the text below.')
customTz = input.string('GMT+3:30', 'Custom time zone', group = G0, tooltip = 'Examples: GMT+2, GMT+3:30, GMT-5')
daysBack = input.int(10, 'Days to draw lines / labels', minval = 1, maxval = 30, group = G0, tooltip = 'Max 30 (TradingView limit of 500 drawing objects).')

showPoints = input.bool(true, 'Show time points', group = G1)
showPointLabels = input.bool(true, 'Show time labels', group = G1)
ptColor = input.color(color.new(color.aqua, 0), 'Line color', group = G1)
ptStyleIn = input.string('Dotted', 'Line style', options = ['Dotted', 'Dashed', 'Solid'], group = G1)
ptWidth = input.int(1, 'Line width', minval = 1, maxval = 4, group = G1)

showZones = input.bool(true, 'Show windows (background)', group = G2)
showZoneLabels = input.bool(true, 'Show window labels', group = G2)
zTransp = input.int(88, 'Background transparency', minval = 0, maxval = 100, group = G2)
colA = input.color(color.new(color.green, 0), 'Grade A color', group = G2)
colB = input.color(color.new(color.orange, 0), 'Grade B color', group = G2)
colC = input.color(color.new(color.gray, 0), 'Grade C color', group = G2)

showPanel = input.bool(true, 'Show info panel', group = G3)

// ---------------- Time zone ----------------
tz = tzMode == 'GMT+3' ? 'GMT+3' : tzMode == 'Custom' ? customTz : syminfo.timezone

// ---------------- Definitions ----------------
// Time points in minutes from midnight (GMT+3): 03,04,08,09,10,16:30,18,20,23
var ptMin = array.from(180, 240, 480, 540, 600, 990, 1080, 1200, 1380)
var ptTxt = array.from('03:00', '04:00', '08:00', '09:00', '10:00', '16:30', '18:00', '20:00', '23:00')

// Window index by minute of day
// 0: 00:00-02:30 (C)   1: 02:30-03:00 (A)   2: 03:00-10:00 (B)   3: 10:00-13:00 (A)
// 4: 13:00-15:30 (C)   5: 15:30-18:00 (A)   6: 18:00-23:00 (B)   7: 23:00-24:00 (C)
winIdx(int m) =>
    m < 150 ? 0 : m < 180 ? 1 : m < 600 ? 2 : m < 780 ? 3 : m < 930 ? 4 : m < 1080 ? 5 : m < 1380 ? 6 : 7

// Grade: 1 = A, 2 = B, 3 = C
winGrade(int i) =>
    i == 1 or i == 3 or i == 5 ? 1 : i == 2 or i == 6 ? 2 : 3

winColor(int i) =>
    g = winGrade(i)
    g == 1 ? colA : g == 2 ? colB : colC

winText(int i) =>
    i == 1 ? 'A  02:30-03:00' : i == 2 ? 'B  03:00-10:00' : i == 3 ? 'A  10:00-13:00' : i == 4 ? 'C  13:00-15:30' : i == 5 ? 'A  15:30-18:00' : i == 6 ? 'B  18:00-23:00' : 'C  23:00-02:30'

lineStyle = ptStyleIn == 'Solid' ? line.style_solid : ptStyleIn == 'Dashed' ? line.style_dashed : line.style_dotted

// ---------------- Per-bar calculations ----------------
mOfDay = hour(time, tz) * 60 + minute(time, tz)
zIdx = winIdx(mOfDay)
inRange = time >= last_bar_time - daysBack * 86400000

// Background of windows
bgcolor(showZones and timeframe.isintraday ? color.new(winColor(zIdx), zTransp) : na)

// Window labels (at the start of each window)
if showZoneLabels and timeframe.isintraday and inRange and zIdx != nz(zIdx[1], -1) and zIdx != 0
    label.new(bar_index, na, winText(zIdx), yloc = yloc.abovebar, style = label.style_label_down, color = color.new(winColor(zIdx), 15), textcolor = color.white, size = size.tiny)

// Time points (vertical lines)
if showPoints and timeframe.isintraday and inRange
    dayStart = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 0, 0)
    for i = 0 to 8 by 1
        for d = 0 to 1 by 1
            ts = dayStart + array.get(ptMin, i) * 60000 + d * 86400000
            if ts >= time and ts < time_close
                line.new(ts, 0, ts, 1, xloc = xloc.bar_time, extend = extend.both, color = ptColor, style = lineStyle, width = ptWidth)
                if showPointLabels
                    label.new(bar_index, na, array.get(ptTxt, i), yloc = yloc.belowbar, style = label.style_label_up, color = color.new(ptColor, 15), textcolor = color.white, size = size.tiny)

// ---------------- Info panel ----------------
var table pnl = table.new(position.top_right, 2, 4, border_width = 1, frame_color = color.new(color.gray, 50), frame_width = 1)

if barstate.islast and showPanel
    tzShown = tzMode == 'Exchange timezone (auto)' ? syminfo.timezone : tz
    table.cell(pnl, 0, 0, 'Time zone', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small, text_halign = text.align_left)
    table.cell(pnl, 1, 0, tzShown, text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small, text_halign = text.align_left)
    if timeframe.isintraday
        nowMin = hour(timenow, tz) * 60 + minute(timenow, tz)
        nIdx = winIdx(nowMin)
        int nextP = array.get(ptMin, 0) + 1440
        for i = 8 to 0 by 1
            if array.get(ptMin, i) > nowMin
                nextP := array.get(ptMin, i)
                nextP
        int remain = nextP - nowMin
        int nm = nextP % 1440
        nextTxt = str.tostring(math.floor(nm / 60), '00') + ':' + str.tostring(nm % 60, '00') + '  (in ' + str.tostring(math.floor(remain / 60)) + 'h ' + str.tostring(remain % 60) + 'm)'
        nowTxt = str.tostring(math.floor(nowMin / 60), '00') + ':' + str.tostring(nowMin % 60, '00')
        table.cell(pnl, 0, 1, 'Now', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small, text_halign = text.align_left)
        table.cell(pnl, 1, 1, nowTxt, text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small, text_halign = text.align_left)
        table.cell(pnl, 0, 2, 'Window', text_color = color.white, bgcolor = color.new(winColor(nIdx), 30), text_size = size.small, text_halign = text.align_left)
        table.cell(pnl, 1, 2, winText(nIdx == 0 ? 7 : nIdx), text_color = color.white, bgcolor = color.new(winColor(nIdx), 30), text_size = size.small, text_halign = text.align_left)
        table.cell(pnl, 0, 3, 'Next point', text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small, text_halign = text.align_left)
        table.cell(pnl, 1, 3, nextTxt, text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small, text_halign = text.align_left)
    else
        table.cell(pnl, 0, 1, 'Note', text_color = color.white, bgcolor = color.new(color.red, 30), text_size = size.small, text_halign = text.align_left)
        table.cell(pnl, 1, 1, 'Use an intraday timeframe', text_color = color.white, bgcolor = color.new(color.red, 30), text_size = size.small, text_halign = text.align_left)
        table.cell(pnl, 0, 2, '', bgcolor = color.new(color.black, 100))
        table.cell(pnl, 1, 2, '', bgcolor = color.new(color.black, 100))
        table.cell(pnl, 0, 3, '', bgcolor = color.new(color.black, 100))
        table.cell(pnl, 1, 3, '', bgcolor = color.new(color.black, 100))
````
