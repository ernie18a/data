<!-- tradingview-pine-id: PUB;9f6c1abb9b8c4d1fbb3367cd56bf7253 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dual Time Opens (10:00 / 22:00) — 2H

Source: https://www.tradingview.com/script/AX24ut7o-10am-10pm-opens/

## Description

Dual Time Opens (10:00 / 22:00) — 2H

This indicator marks the opening price of two specific times of day and draws each as a horizontal line that stops after a set duration. By default it plots the 10:00 AM and 10:00 PM New York opens, with each line running exactly two hours forward.

WHY TIME-LIMITED LINES

Most opening-price scripts extend their levels to the right edge of the chart or to the end of the session. That works when you only care about one level, but it clutters quickly once you're tracking multiple times per day, and it visually implies the level still matters hours after it stopped being relevant. This script draws each line for a defined window and then ends it, so what you see on the chart is the period the level was actually in play.

HOW IT WORKS

On each trading day the script identifies the first bar that reaches the configured time and records that bar's open price. It then draws a horizontal line from that bar forward by the chosen duration, measured in clock time rather than in bar counts — so the line covers the same real-world window regardless of whether you're on a 1-minute or 15-minute chart. If the exact bar is missing due to a data gap or thin liquidity, the script falls back to the first available bar within the window rather than skipping the day.

Times are evaluated in a user-selected timezone, independent of the chart's own timezone setting. The default is America/New_York, so 10:00 and 22:00 mean 10am and 10pm Eastern no matter how your chart is configured.

SETTINGS

Clock to use — timezone the times are measured in, or "Exchange" for the symbol's native time
Open #1 / Open #2 — hour and minute for each level, plus color and label tag; either can be turned off
Extend for (hours) — line duration, adjustable from 15 minutes to 24 hours
Width / Style — solid, dashed or dotted
Price tag — optional label showing the level's price at the end of each line
Keep last N days — trims older drawings to stay under Pine's 500-object limit

Alerts are available for each level being marked.

NOTES

Requires an intraday timeframe of 1 hour or lower. On symbols with restricted sessions, a level only appears if the chart's session actually covers that time — for a 22:00 level on equities, extended hours must be enabled.

---

## Source Code

````pine
//@version=6
indicator("Dual Time Opens (10:00 / 22:00) — 2H", "Dual Opens", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── Timezone ───
grpTz = "Timezone"
tzIn = input.string("America/New_York", "Clock to use", group = grpTz,
     options = ["Exchange", "UTC", "America/New_York", "America/Chicago", "America/Denver",
                "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo",
                "Asia/Hong_Kong", "Asia/Kolkata", "Australia/Sydney"],
     tooltip = "'Exchange' uses the symbol's native exchange time. New York default: 10:00 = 10am ET, 22:00 = 10pm ET.")
tz = tzIn == "Exchange" ? syminfo.timezone : tzIn

// ─── Open #1 (10:00 AM) ───
g1 = "Open #1  (default 10:00 AM)"
show1 = input.bool(true,  "On",     group = g1, inline = "t1")
h1    = input.int(10, "Hour (0-23)", minval = 0, maxval = 23, group = g1, inline = "t1")
m1    = input.int(0,  "Min",         minval = 0, maxval = 59, group = g1, inline = "t1")
c1    = input.color(#2962FF,  "Color", group = g1, inline = "s1")
txt1  = input.string("10:00", "Tag",  group = g1, inline = "s1")

// ─── Open #2 (10:00 PM) ───
g2 = "Open #2  (default 10:00 PM)"
show2 = input.bool(true,  "On",     group = g2, inline = "t2")
h2    = input.int(22, "Hour (0-23)", minval = 0, maxval = 23, group = g2, inline = "t2")
m2    = input.int(0,  "Min",         minval = 0, maxval = 59, group = g2, inline = "t2")
c2    = input.color(#FF6D00,  "Color", group = g2, inline = "s2")
txt2  = input.string("22:00", "Tag",  group = g2, inline = "s2")

// ─── Line appearance ───
gL = "Line"
extHrs  = input.float(2.0, "Extend for (hours)", minval = 0.25, maxval = 24, step = 0.25, group = gL,
     tooltip = "How far RIGHT the line runs, in clock time. 2 = two hours, then it stops.")
lw      = input.int(2, "Width", minval = 1, maxval = 5, group = gL, inline = "ln")
styIn   = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = gL, inline = "ln")
showLbl = input.bool(true, "Show price tag at end of line", group = gL)
keepDays = input.int(15, "Keep last N days of lines", minval = 1, maxval = 200, group = gL,
     tooltip = "Older lines are removed so you don't hit TradingView's 500-drawing limit.")

lineStyle = styIn == "Dashed" ? line.style_dashed : styIn == "Dotted" ? line.style_dotted : line.style_solid

// ─── Engine ───
extMs = int(extHrs * 60 * 60 * 1000)

var line[]  lns = array.new<line>()
var label[] lbs = array.new<label>()

isOpenBar(int hh, int mm) =>
    ts = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), hh, mm, 0)
    time >= ts and time[1] < ts and (time - ts) < extMs

drawOpen(float px, color col, string tag) =>
    x1 = time
    x2 = x1 + extMs
    array.push(lns, line.new(x1, px, x2, px, xloc = xloc.bar_time, color = col, width = lw, style = lineStyle))
    if showLbl
        array.push(lbs, label.new(x2, px, tag + "  " + str.tostring(px, format.mintick),
             xloc = xloc.bar_time, style = label.style_label_left,
             color = color.new(col, 88), textcolor = col, size = size.small))
    maxKeep = keepDays * 2
    while array.size(lns) > maxKeep
        line.delete(array.shift(lns))
    while array.size(lbs) > maxKeep
        label.delete(array.shift(lbs))

okTf = timeframe.isintraday and timeframe.in_seconds() <= 3600

t1 = isOpenBar(h1, m1)
t2 = isOpenBar(h2, m2)

if okTf and show1 and t1
    drawOpen(open, c1, txt1)

if okTf and show2 and t2
    drawOpen(open, c2, txt2)

var label warn = na
if barstate.islast and not okTf
    label.delete(warn)
    warn := label.new(bar_index, high, "Dual Opens: switch to an intraday timeframe (1h or lower)",
         style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.small)

alertcondition(t1, "Open #1 hit", "Time Open #1 marked")
alertcondition(t2, "Open #2 hit", "Time Open #2 marked")
````
