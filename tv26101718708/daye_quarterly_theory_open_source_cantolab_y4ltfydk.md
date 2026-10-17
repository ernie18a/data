# Daye Quarterly Theory (Open Source) [CantoLab]

- url: https://www.tradingview.com/script/y4LtFydK-Daye-Quarterly-Theory-Open-Source-CantoLab/
- type: indicator
- pine_id: PUB;d719ded669c143c6bfc230f8d037976f
- version: 1.0

## Description

[b]An open source implementation of Daye's Quarterly Theory, based on the work of traderdaye. Visualises the 4 quarterly cycles — Accumulation, Manipulation, Distribution and Reversal/Continuation — across Weekly, Daily and 90 Minute timeframes in a dedicated pane below the chart.[/b]

[b]Introduction[/b]
The underlying idea of Daye's Quarterly Theory is that time divides into repeating quarters for correct interpretation of market cycles. These quarters represent the same 4 phases regardless of which timeframe you are looking at:

[list]
[*]A — Accumulation 
[*]M — Manipulation
[*]D — Distribution
[*]X — Reversal / Continuation
[/list]

[quote]The sequence always follows A → M → D → X, however the cycle can begin at X depending on the analyst's discretion. This indicator focuses on the 3 most practical timeframes for day to day trading - Weekly, Daily and 90 Minute quarters.[/quote]

[b]Quarterly Cycles[/b]

Weekly Quarters
Daye determined the trading week is composed of 4 relevant days:

[list]
[*]Q1 — Monday (Accumulation)
[*]Q2 — Tuesday (Manipulation / True Open)
[*]Q3 — Wednesday (Distribution)
[*]Q4 — Thursday (Reversal / Continuation)
[/list]

Daily Quarters
The trading day breaks into four 6-hour blocks, which roughly align with the major trading sessions:

[list]
[*]Q1 — 18:00 – 00:00 (Asian Session)
[*]Q2 — 00:00 – 06:00 (London Session / True Open)
[*]Q3 — 06:00 – 12:00 (New York Session)
[*]Q4 — 12:00 – 18:00 (PM Session)
[/list]

Times based on New York time. Will vary by instrument, adjust according to preference.

90 Minute Quarters
Each 6-hour Daily block divides further into four 90-minute segments. The indicator automatically updates to display the active 6-hour block's quarters in real time. Using the Asian Session as an example:

[b]Q1 — 18:00 – 19:30
Q2 — 19:30 – 21:00 (
Q3 — 21:00 – 22:30
Q4 — 22:30 – 00:00
[/b]
The 90 Minute row is the most granular level included and is where most intraday traders will find their entry and exit timing.

[b]Settings[/b]

[list]
[*]Show History — keep or clear previous cycles as new ones form
[*]Weekly / Daily / 90 Minute Quarters — toggle each row independently
[*]Labels — toggle A/M/D/X labels on or off, with size control
[*]Colors — customise each phase color individually
[*]Border — auto-detects chart theme (light/dark) or set manually
[/list]


[b]Notes[/b]

[list]
[*]Displays in a separate pane, does not overlay on price
[*]Times are based on Futures trading in New York Time — adjust expectations for Forex, Metals, Crypto, Commodities and Equities
[*]best on timeframes of 15 minutes or lower to avoid visual clutter.
[*]Theory originally developed by traderdaye — study his material directly for full context on how to apply these cycles.
[/list]

## Source Code

````pine
//@version=6
indicator("Daye Quarterly Theory [CantoLab]", overlay=false, max_boxes_count=500)


//#region[User Inputs]
grp1      = "General Settings"
history   = input.bool(false, "Show History?", group=grp1)

grp2      = "Quarterly Cycles"
showW     = input.bool(true, "Weekly Quarters", group=grp2)
showD     = input.bool(true, " Daily Quarters", group=grp2)
showQ     = input.bool(true, " 90 Minute Quarters",   group=grp2)

grp3        = "Customisation"
showlabels  = input.bool(true,    "Labels?", group=grp3, inline="lbl")
labelSize   = input.string("Tiny", "",       group=grp3, inline="lbl", options=["Tiny", "Small", "Normal", "Large", "Huge"], active=showlabels)
c1          = input.color(color.new(#787b86, 85), "Accumulation (A)",   group=grp3)
c2          = input.color(color.new(#ff5252, 85), "Manipulation (M)",   group=grp3)
c3          = input.color(color.new(#4caf50, 85), "Distribution (D)",   group=grp3)
c4          = input.color(color.new(#2962ff, 85), "Reversal/Cont. (X)", group=grp3)
auto_detect = input.bool(true,                    "Automatic Border Color?", group=grp3, inline="Border")
borderInput = input.color(color.new(#000000, 0), "",                         group=grp3, inline="Border", active=not auto_detect)
//#endregion


//#region[Global & Utility]
NO_COLOR = color.new(color.white, 100)
FONT     = font.family_default
border = auto_detect ? (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color) < 128 ? color.new(#ffffff, 0) : color.new(#000000, 0)) : borderInput

size(string _size) =>
    switch _size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge

quarterColor(int idx) =>
    switch idx
        0 => c1
        1 => c2
        2 => c3
        => c4

quarterLabel(int idx) =>
    switch idx
        0 => "A"
        1 => "M"
        2 => "D"
        => "X"
//#endregion


//#region[Functions]
hideBoxes(box[] arr) =>
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            b = arr.get(i)
            b.set_bgcolor(NO_COLOR)
            b.set_border_color(NO_COLOR)
            b.set_text_color(NO_COLOR)

newBox(int t1, int t2, float top, float bot, int idx) =>
    box.new(t1, top, t2, bot, xloc=xloc.bar_time,
         border_color=border, bgcolor=quarterColor(idx), border_width=1,
         text=showlabels ? quarterLabel(idx) : "",
         text_color=border, text_size=size(labelSize),
         text_halign=text.align_center, text_valign=text.align_center)

rowLabel(int t, float y, string txt) =>
    label.new(t, y, txt, xloc=xloc.bar_time,
         style=label.style_label_left, color=NO_COLOR,
         textcolor=border, size=size(labelSize), text_font_family=FONT)

msPerDay = 86400000
msPerH6  = 21600000
msPerQ   = 5400000

isNewWeek = timeframe.change("W")
isNewDay  = timeframe.change("D")

var box[] wBoxes    = array.new_box()
var box[] dBoxes    = array.new_box()
var box[] qBoxes    = array.new_box()
var box[] allQBoxes = array.new_box()
var int   lastH6    = -1

var label rowLblQ = na
var label rowLblD = na
var label rowLblW = na
//#endregion


//#region[Logic]
if barstate.isfirst
    rowLblQ := rowLabel(chart.left_visible_bar_time, -1.0, showQ ? "90 Minute" : "")
    rowLblD := rowLabel(chart.left_visible_bar_time, -3.0, showD ? "Daily"     : "")
    rowLblW := rowLabel(chart.left_visible_bar_time, -5.0, showW ? "Weekly"    : "")

if time == chart.left_visible_bar_time
    rowLblQ.set_x(chart.left_visible_bar_time)
    rowLblD.set_x(chart.left_visible_bar_time)
    rowLblW.set_x(chart.left_visible_bar_time)

currentH6 = -1
if allQBoxes.size() == 16
    for h = 0 to 3
        if time >= allQBoxes.get(h * 4).get_left() and time < allQBoxes.get(h * 4 + 3).get_right()
            currentH6 := h

if isNewWeek and showW
    if not history
        hideBoxes(wBoxes)
    wBoxes := array.new_box()
    for i = 0 to 3
        wBoxes.push(newBox(time + i * msPerDay, time + (i + 1) * msPerDay, -4.0, -6.0, i))

if isNewDay
    if showD
        if not history
            hideBoxes(dBoxes)
        dBoxes := array.new_box()
        for i = 0 to 3
            dBoxes.push(newBox(time + i * msPerH6, time + (i + 1) * msPerH6, -2.0, -4.0, i))

    if showQ
        if not history
            hideBoxes(allQBoxes)
        allQBoxes := array.new_box()
        for h = 0 to 3
            h6Start = time + h * msPerH6
            for q = 0 to 3
                t1 = h6Start + q * msPerQ
                allQBoxes.push(box.new(t1, 0.0, t1 + msPerQ, -2.0, xloc=xloc.bar_time,
                     border_color=NO_COLOR, bgcolor=NO_COLOR, border_width=1,
                     text_size=size(labelSize)))
        lastH6 := -1

if showQ and currentH6 != lastH6
    if not history
        hideBoxes(qBoxes)
    qBoxes := array.new_box()
    blockStart = currentH6 * 4
    if allQBoxes.size() >= blockStart + 4
        for i = 0 to 3
            b = allQBoxes.get(blockStart + i)
            b.set_bgcolor(quarterColor(i))
            b.set_border_color(border)
            b.set_text(showlabels ? quarterLabel(i) : "")
            b.set_text_color(border)
            b.set_text_size(size(labelSize))
            qBoxes.push(b)
    lastH6 := currentH6
//#endregion
````
