# Byakugan + First Presented FVG

- url: https://www.tradingview.com/script/K3xWdEdO-Byakugan-First-Presented-FVG/
- type: indicator
- pine_id: PUB;d420198b0ea44619b2cb0f4e53cce0e1
- version: 4.0

## Description

In Naruto, the Byakugan sees what’s hidden at range. This indicator does the same with the 7–9 AM ET range. Before New York opens, it maps where the range sits, which way it was travelling, which liquidity is in play and how far price has room to run. At 09:30 it hands over to the first presented fair value gap, the first imbalance New York prints.

This is a confluence map, not a signal. Every level belongs to its own day: it starts inside the 7–9 box and stops at 11:00 ET, so the chart only shows the morning that matters. It’s open source, so take it, test it, break it and build on it.
In homage to Michael J. Huddleston, the Inner Circle Trader

[b]None of this would exist without Michael J. Huddleston.
[/b]
The fair value gap, Consequent encroachment,Buy-side and sell-side liquidity, Session killzones, Projecting a range in standard deviations, Watching the first presented fair value gap after the 09:30 open. Every one of those ideas comes from him. He taught them for years, much of it for free, in public lectures and mentorships anyone could watch. In an industry that sells almost everything, that generosity is rare.

He changed how a generation of retail traders looks at a chart. Price stopped being random noise and became something delivered from one pool of liquidity to the next, through inefficiencies it leaves behind and comes back to most of the vocabulary you see on TradingView today traces back to him. Mine does too.

Byakugan is my own model, built and tested on top of that foundation: the 7–9 range, the travel-anchored extensions, the Asia/London target. The language it’s written in is his. If this tool helps you, the credit goes to the teacher first.

Thank you, Michael.

[i]This script isn’t affiliated with or endorsed by ICT. Any mistakes in how I’ve applied his ideas are mine alone. If you want the concepts taught properly, go to the source: his own lectures.[/i]
[b]New to this? Start here

The words on the chart
[/b]
Byakugan range: the high and low between 07:00 and 09:00 ET.
0.5: the midpoint of that range.
The scale:
0 is the extreme that formed first, and 1 is the extreme that formed last (the direction price was travelling into 09:00).
So 1.5 sits half a range past the last extreme, and −0.5 sits half a range past the first.
Asia / London: 20:00–00:00 and 02:00–05:00 ET. Their combined high and low mark resting liquidity: stops and orders sitting above the high and below the low.
Fair value gap (FVG): a three-candle pattern where the wicks of candle 1 and candle 3 don’t overlap. The middle candle moved so fast it left a gap that only traded one way.
CE (consequent encroachment): the 50% line of a fair value gap.
First presented FVG: the first fair value gap to form after the 09:30 open (within 30 minutes by default).

A morning on the chart (ET)

Time	What happens
07:00–09:00	The Byakugan box builds
09:00	The range is set. The high, low, 0.5 and extensions appear, drawn from 07:00
09:30	The bias marker prints (open above or below the 0.5), and the Asia/London target appears in that direction
09:30–10:00	The first presented FVG forms, drawn as a box with its CE
Until 11:00	Levels turn dashed when price trades through them. An “AL swept” marker prints if the target is taken
11:00	Everything stops. That morning is done, and tomorrow starts clean
What you see

The Byakugan range

The 7–9 box: shaded from 07:00 to 09:00.
High and low: each labelled with the time it formed.
0.5 midpoint: orange, and thicker than the other lines.
One day at a time: every level starts at 07:00 and stops at 11:00 ET. Nothing carries into the afternoon or the next day.

Extensions

Continuation (with the travel): 1.5 and 2.0 are on, 2.5 is optional. They sit beyond the extreme that formed last.
Opposing (against the travel): −0.25 and −0.5 are on, −1.25 and −1.5 are optional. They sit beyond the extreme that formed first.
Custom levels: type your own multiples, e.g. 0.25, 0.75, 3, -2.
Same scale as above, up to 20 levels.
They get their own colour and line style.
Anything already drawn is skipped.

09:30 bias

▲ BULL when the open is above the 0.5, ▼ BEAR when it’s below.

Asia / London target

What it is: the combined Asia + London high on a bull bias, or low on a bear bias.
Label: shows the distance from the open (under 0.15%, 0.15–0.30%, 0.30–1.00%, over 1.00%), or “swept pre-open” if it was taken before 09:30.
Sweep marker: “AL high swept 09:47” when NY takes it before 11:00.

First presented FVG

One drawing: the box, its CE and one label, e.g. “09:33 10/09 First presented”. Green is bullish, red is bearish.
The CE: starts dotted and turns dashed once price trades through it.
Reflection (optional): the first gap in the opposite direction after it.

Drawing

Labels: on the right with the time and date each level formed, or on the left like the Asian Range script.
Status: levels turn dashed once traded through and go grey after 5 trading days.
Settings

Byakugan · 7–9 AM range

Byakugan range (07:00–09:00)
Levels live from → cut-off (07:00–11:00)
Range high / low and midpoint colours
Shade the 7–9 box, with colour
09:30 bias marker, with bull / bear colours

Byakugan · extensions

Continuation: 1.5 and 2.0 (on), 2.5 (off)
Opposing: −0.25 and −0.5 (on), −1.25 and −1.5 (off)
Extension colour
Custom levels, with their own colour and line style (dotted, dashed or solid)

Byakugan · Asia / London target

Show the target on/off
Asia (20:00–00:00) and London (02:00–05:00)
Distance-zone tag on/off
Target colour

First presented FVG

Show on/off
Session (09:30–16:00)
Must complete within N minutes of the open (30; 0 = any time)
FVG length: Byakugan cut-off, until its session ends, or to the last candle
Bullish / bearish colours
CE colour
Reflection FVG on/off, with colour

Drawing

Label side (right or left)
Days to keep (10)
Label date format (HH:mm MM/dd)
Text colour and size
Fresh-for-N-days (5), then the aged colour

Use it on an intraday chart of 15 minutes or less. 1 minute is recommended for the first presented FVG.

Honest notes

I tested this on NQ 1-minute data (2018, 2022–2026). The rules were fixed first, built on 2018–24, then checked once on 2025–26.

The bias doesn’t call the close on its own.
Open vs 0.5 called the 16:59 close 51.5% of the time in-sample and 48.6% out of sample. Simply being long did better, at 54–55%.
Bull-bias days ran 56% / 53%, and bear-bias days 47% / 43%. That gap is the carry.
Where the bias earns its place is in which side gets tapped.
By 11:00, NY tapped the 7–9 extreme on the bias side on 85–87% of days, against 52% for the other extreme.
Part of that is distance, because the bias-side extreme is always the nearer one.
At matched distance, the bias side still led by about 5–12 points. This is the part that holds up.
The Asia/London target in the 0.30–1.00% zone mostly reflects the move itself.
Days where NY sweeps it close that way 74–86% of the time.
But any day NY travels that far in one direction closes that way 65–79% of the time, so the level adds only a few points.
The extensions are a ruler, not a forecast.
By 11:00, price reached each level on roughly this share of days:
Level	1.5	2.0	2.5	−0.25	−0.5	−1.25	−1.5
Reached by 11:00	54%	33%	20%	48%	39%	19%	15%
The rates held steady in both periods.
At the same distance from the 09:00 open, both sides get reached about equally. The continuation side only looks stronger because price usually sits nearer the last extreme at 09:00 (81% of days).
The first presented FVG is a reference, not a wall.
On 1-minute charts, one formed within 30 minutes on virtually every day tested.
Its direction called the close only 52–53% of the time from the candle that completes it, which doesn’t beat always-long.
By 11:00, its CE was revisited on about 86% of days, and price closed through its far side on about 76%. Expect it to be tested, and expect it to break more often than it holds.

Use the map to frame the morning, not to replace your execution. Not financial advice. Do your own testing.

Learn from the masters, test everything yourself, and keep showing up. Clear sight comes to the ones who refuse to look away.

— Unclehk2000

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
// First presented FVG concept: ICT. Inspired by "ICT 1st Presented FVG" (tristanlee85); detection written from scratch here.
//@version=6
indicator("Byakugan + First Presented FVG", "Byakugan", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

tz = "America/New_York"

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════
var g_D = "View"
themeI  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = g_D, tooltip = "Auto follows the chart background. Text and the colours left at their default follow it.", display = display.none)
lblSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = g_D, display = display.none)
txtColI = input.color(#000001, "Text colour", group = g_D, tooltip = "Left at the default it follows the theme; pick any colour to override.", display = display.none)
dateFmt = input.string("HH:mm MM/dd", "Label date format", group = g_D, display = display.none)
lblSide = input.string("Right", "Label side", options = ["Right", "Left"], tooltip = "Right: labels sit at the end of each level. Left: labels sit at the start, like the Asian Range script.", group = g_D, display = display.none)
maxDays = input.int(10, "Days to keep", minval = 1, group = g_D, display = display.none)
ageDays = input.int(5, "Fresh for first N trading days", minval = 1, group = g_D, display = display.none)
agedCol = input.color(color.gray, "Aged colour", group = g_D, display = display.none)

var g_B = "Byakugan · 7–9 AM range"
rngSess  = input.session("0700-0900", "Byakugan range", group = g_B, display = display.none)
cutSess  = input.session("0700-1100", "Levels live from → cut-off", tooltip = "Every Byakugan level starts at the range open and stops at the cut-off (11:00 ET by default), each day on its own.", group = g_B, display = display.none)
colRng   = input.color(#1e88e5, "Range high / low", inline = "r", group = g_B, display = display.none)
colMid   = input.color(#ff9800, "Midpoint (0.5)", inline = "r", group = g_B, display = display.none)
showFill = input.bool(true, "Shade the 7–9 box", inline = "f", group = g_B, display = display.none)
colFill  = input.color(color.new(#1e88e5, 90), "", inline = "f", group = g_B, display = display.none)
showBias = input.bool(true, "Mark the 09:30 bias (open vs midpoint)", group = g_B, display = display.none)
colBull  = input.color(color.green, "Bull", inline = "bb", group = g_B, display = display.none)
colBear  = input.color(color.red, "Bear", inline = "bb", group = g_B, display = display.none)

var g_X = "Byakugan · extensions (from the range)"
showC15  = input.bool(true, "1.5", inline = "c", group = g_X, display = display.none)
showC20  = input.bool(true, "2.0", inline = "c", group = g_X, display = display.none)
showC25  = input.bool(false, "2.5", inline = "c", group = g_X, tooltip = "Continuation levels: beyond the extreme that formed LATER (the direction price was travelling into 09:00), in multiples of the 7–9 range.", display = display.none)
showT025 = input.bool(true, "−0.25", inline = "t", group = g_X, display = display.none)
showT05  = input.bool(true, "−0.5", inline = "t", group = g_X, display = display.none)
showT125 = input.bool(false, "−1.25", inline = "t", group = g_X, display = display.none)
showT15  = input.bool(false, "−1.5", inline = "t", group = g_X, tooltip = "Terminus levels: beyond the extreme that formed FIRST (the origin), in multiples of the 7–9 range.", display = display.none)
colExt   = input.color(color.new(#1e88e5, 40), "Extension colour", group = g_X, display = display.none)
showCust = input.bool(true, "Custom levels", inline = "cu", group = g_X, display = display.none)
custTxt  = input.string("", "", inline = "cu", group = g_X, tooltip = "Type your own multiples of the 7–9 range, separated by commas, e.g. 0.25, 0.75, 3, -2\n\nSame scale as the presets: 0 = the extreme that formed FIRST, 1 = the extreme that formed LAST, 0.5 = the midpoint. Above 1 continues the way price travelled into 09:00; below 0 runs past the origin.\n\nUp to 20 levels. Anything already drawn (0, 0.5, 1 and any preset that is ticked) is skipped.", display = display.none)
colCust  = input.color(color.new(#00897b, 30), "Custom colour", inline = "cs", group = g_X, display = display.none)
custSty  = input.string("Dotted", "", options = ["Dotted", "Dashed", "Solid"], inline = "cs", group = g_X, display = display.none)

var g_A = "Byakugan · Asia / London target"
showAL   = input.bool(true, "Show the AL target in the bias direction", group = g_A, display = display.none)
asiaSess = input.session("2000-0000", "Asia", group = g_A, display = display.none)
ldnSess  = input.session("0200-0500", "London", group = g_A, display = display.none)
showZone = input.bool(true, "Tag the distance zone on the label", group = g_A, display = display.none)
colAL    = input.color(#8e24aa, "AL target colour", group = g_A, display = display.none)

var g_F = "First presented FVG"
showFP   = input.bool(true, "Show the first presented FVG", group = g_F, display = display.none)
fpSess   = input.session("0930-1600", "Session (FVG search starts at its open)", group = g_F, display = display.none)
fpWin    = input.int(30, "Must complete within (minutes of the open)", minval = 0, maxval = 390, tooltip = "0 = any time in the session.", group = g_F, display = display.none)
fpExt    = input.string("Byakugan cut-off", "FVG length", options = ["Byakugan cut-off", "Until its session ends", "To the day's last candle", "To the present"], group = g_F, tooltip = "How far each first presented FVG (and its CE and reflection) is drawn:\nByakugan cut-off: to the Byakugan cut-off, like the levels.\nUntil its session ends: to the end of the FVG session (16:00 by default).\nTo the day's last candle: to the trading day's last bar (16:59 on CME index futures).\nTo the present: every day's FVG keeps running to the latest bar, for as many days as are kept.", display = display.none)
colFPb   = input.color(color.new(color.green, 80), "Bullish", inline = "fc", group = g_F, display = display.none)
colFPs   = input.color(color.new(color.red, 80), "Bearish", inline = "fc", group = g_F, display = display.none)
colCEI   = input.color(#000001, "CE (50% of the gap)", tooltip = "The CE line is part of the gap: it is drawn, extended, cut off and aged with it.", group = g_F, display = display.none)
showRefl = input.bool(false, "Show the reflection FVG (first opposite-direction FVG after it)", group = g_F, display = display.none)
colRefl  = input.color(color.new(color.blue, 80), "Reflection colour", group = g_F, display = display.none)

// Theme: Auto follows the chart background; colours left at their default (#000001) follow it
bgLum  = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
isDark = themeI == "Dark" or (themeI == "Auto" and bgLum < 128)
autoC(color c) => color.r(c) == 0 and color.g(c) == 0 and color.b(c) == 1
fgAuto = isDark ? #d1d4dc : #131722
txtCol = autoC(txtColI) ? fgAuto : txtColI
colCE  = autoC(colCEI) ? fgAuto : colCEI


if not timeframe.isintraday or timeframe.in_seconds() > 15 * 60
    runtime.error("Use an intraday chart of 15 minutes or less (1 min recommended for the first presented FVG).")

tSize   = lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small
lblLeft = lblSide == "Left"
stampOf(int t) => str.format_time(t, dateFmt, tz)
hhmm(int t) => str.format_time(t, "HH:mm", tz)
custStyle = custSty == "Dashed" ? line.style_dashed : custSty == "Solid" ? line.style_solid : line.style_dotted

// custom Byakugan levels: commas, spaces or semicolons; accepts − as well as -
parseLevels(string txt) =>
    clean = str.replace_all(str.replace_all(str.replace_all(txt, "−", "-"), ";", ","), " ", ",")
    parts = str.split(clean, ",")
    out = array.new<float>()
    for part in parts
        v = str.tonumber(part)
        if not na(v) and out.size() < 20 and not out.includes(v)
            out.push(v)
    out
var array<float> custLv = parseLevels(custTxt)

alreadyDrawn(float v) =>
    v == 0 or v == 0.5 or v == 1 or (showC15 and v == 1.5) or (showC20 and v == 2.0) or (showC25 and v == 2.5) or (showT025 and v == -0.25) or (showT05 and v == -0.5) or (showT125 and v == -1.25) or (showT15 and v == -1.5)
fmtLv(float v) => v < 0 ? "−" + str.tostring(-v) : str.tostring(v)

// ═══════════════════════════════════════════════════════════════════
// SESSIONS & TRADING DAY
// ═══════════════════════════════════════════════════════════════════
sessOn(string s) => not na(time(timeframe.period, s, tz))
inRng  = sessOn(rngSess)
inCut  = sessOn(cutSess)
inAsia = sessOn(asiaSess)
inLdn  = sessOn(ldnSess)
inFP   = sessOn(fpSess)
inNYo  = sessOn("0930-1700")
rngStart  = inRng and not inRng[1]
rngEnd    = not inRng and inRng[1]
asiaStart = inAsia and not inAsia[1]
ldnEnd    = not inLdn and inLdn[1]
fpStart   = inFP and not inFP[1]
dayStart  = ta.change(time_tradingday) != 0   // new CME trading day (the 18:00 ET bar)
nyOpen    = inNYo and not inNYo[1]

var int dayCount = 0
if dayStart
    dayCount += 1

// ═══════════════════════════════════════════════════════════════════
// DRAWING STORE
// ═══════════════════════════════════════════════════════════════════
type Lv
    line   ln
    label  lb
    box    bx
    float  y
    bool   above
    int    day
    bool   hit
    bool   live
    bool   watch     // dash it when price trades through after it forms
    string grp       // "byk" (stops at the cut-off) or "fp" (follows the FVG length setting)

var array<Lv>    store = array.new<Lv>()
var array<label> evLbl = array.new<label>()
var array<int>   evDay = array.new<int>()

newLabel(int t0, float y, string txt) =>
    label.new(lblLeft ? t0 : time, y, txt, xloc = xloc.bar_time, style = lblLeft ? label.style_label_right : label.style_label_left, color = #ffffff00, textcolor = txtCol, size = tSize)

mkLv(int t0, float y, color col, int w, string st, string txt, bool above, bool watch, string grp) =>
    lv = Lv.new(line.new(t0, y, time, y, xloc = xloc.bar_time, color = col, style = st, width = w), newLabel(t0, y, txt), na, y, above, dayCount, false, true, watch, grp)
    store.push(lv)
    lv

// a gap and its CE are one object: one label, one box, one CE line (dashed once price trades through the CE)
mkGap(int t0, float gTop, float gBot, color col, string txt, bool ceAbove, string ceSty) =>
    ceY = (gTop + gBot) / 2
    ce  = line.new(t0, ceY, time, ceY, xloc = xloc.bar_time, color = colCE, style = ceSty, width = 1)
    lv  = Lv.new(ce, newLabel(t0, gTop, txt), box.new(t0, gTop, time, gBot, xloc = xloc.bar_time, bgcolor = col, border_color = color.new(col, 40)), ceY, ceAbove, dayCount, false, true, true, "fp")
    store.push(lv)
    lv

mkEvent(float y, string txt, color col, bool above) =>
    evLbl.push(label.new(time, y, txt, xloc = xloc.bar_time, style = above ? label.style_label_down : label.style_label_up, color = color.new(col, 80), textcolor = txtCol, size = tSize))
    evDay.push(dayCount)

if dayStart
    while store.size() > 0 and store.get(0).day <= dayCount - maxDays
        lv = store.shift()
        if not na(lv.ln)
            lv.ln.delete()
        if not na(lv.bx)
            lv.bx.delete()
        lv.lb.delete()
    while evDay.size() > 0 and evDay.get(0) <= dayCount - maxDays
        evLbl.shift().delete()
        evDay.shift()

// ═══════════════════════════════════════════════════════════════════
// ASIA / LONDON EXTREMES and the pre-open window (London end → 09:29)
// ═══════════════════════════════════════════════════════════════════
var float alH = na
var float alL = na
var float poH = na
var float poL = na
if asiaStart
    alH := high
    alL := low
else if inAsia or inLdn
    alH := math.max(alH, high)
    alL := math.min(alL, low)
if ldnEnd
    poH := high
    poL := low
else if not na(poH) and not inNYo
    poH := math.max(poH, high)
    poL := math.min(poL, low)

// ═══════════════════════════════════════════════════════════════════
// BYAKUGAN: 7–9 AM box, levels drawn at 09:00 from 07:00 → cut-off
// ═══════════════════════════════════════════════════════════════════
var float bH = na
var float bL = na
var int   bHt = na
var int   bLt = na
var int   bT0 = na
if rngStart
    bH := high
    bL := low
    bHt := time
    bLt := time
    bT0 := time
else if inRng
    if high > bH
        bH := high
        bHt := time
    if low < bL
        bL := low
        bLt := time

var float bMid = na
var int   bDay = na
if rngEnd and not na(bH)
    R    = bH - bL
    bMid := (bH + bL) / 2
    bDay := dayCount
    upTravel = bHt >= bLt            // the extreme that formed later is the "1"
    endE  = upTravel ? bH : bL       // recent extreme
    orgE  = upTravel ? bL : bH       // origin extreme
    s     = upTravel ? 1 : -1
    if showFill
        store.push(Lv.new(na, label.new(bT0, bH, "", xloc = xloc.bar_time, style = label.style_none), box.new(bT0, bH, time, bL, xloc = xloc.bar_time, bgcolor = colFill, border_color = color.new(colFill, 100)), bH, true, dayCount, false, false, false, "box"))
    mkLv(bT0, bH, colRng, 1, line.style_solid, stampOf(bHt) + " 7–9 high", true, true, "byk")
    mkLv(bT0, bL, colRng, 1, line.style_solid, stampOf(bLt) + " 7–9 low", false, true, "byk")
    mkLv(bT0, bMid, colMid, 2, line.style_solid, stampOf(bT0) + " Byakugan 0.5", true, false, "byk")
    if showC15
        mkLv(bT0, endE + s * 0.5 * R, colExt, 1, line.style_dotted, "Byakugan 1.5", upTravel, true, "byk")
    if showC20
        mkLv(bT0, endE + s * 1.0 * R, colExt, 1, line.style_dotted, "Byakugan 2.0", upTravel, true, "byk")
    if showC25
        mkLv(bT0, endE + s * 1.5 * R, colExt, 1, line.style_dotted, "Byakugan 2.5", upTravel, true, "byk")
    if showT025
        mkLv(bT0, orgE - s * 0.25 * R, colExt, 1, line.style_dotted, "Byakugan −0.25", not upTravel, true, "byk")
    if showT05
        mkLv(bT0, orgE - s * 0.5 * R, colExt, 1, line.style_dotted, "Byakugan −0.5", not upTravel, true, "byk")
    if showT125
        mkLv(bT0, orgE - s * 1.25 * R, colExt, 1, line.style_dotted, "Byakugan −1.25", not upTravel, true, "byk")
    if showT15
        mkLv(bT0, orgE - s * 1.5 * R, colExt, 1, line.style_dotted, "Byakugan −1.5", not upTravel, true, "byk")
    // custom levels: price = origin extreme + direction × level × range
    if showCust and custLv.size() > 0
        for v in custLv
            if not alreadyDrawn(v)
                yC = orgE + s * v * R
                mkLv(bT0, yC, colCust, 1, custStyle, "Byakugan " + fmtLv(v), v > 1 ? upTravel : v < 0 ? not upTravel : yC > close, true, "byk")

// ── 09:30: bias and the Asia/London target ──
var bool  biasBull = false
var float alTgt    = na
var bool  alDone   = true
if nyOpen and not na(bMid) and bDay == dayCount
    O = open
    biasBull := O > bMid
    if showBias
        mkEvent(biasBull ? low : high, biasBull ? "▲ Byakugan bias: BULL" : "▼ Byakugan bias: BEAR", biasBull ? colBull : colBear, not biasBull)
    alTgt  := biasBull ? alH : alL
    alDone := false
    if showAL and not na(alTgt)
        pre   = biasBull ? (not na(poH) and poH >= alTgt) : (not na(poL) and poL <= alTgt)
        dist  = 100 * math.abs(alTgt - O) / O
        zone  = dist < 0.15 ? "under 0.15%" : dist < 0.30 ? "0.15–0.30%" : dist <= 1.00 ? "0.30–1.00% zone" : "over 1.00%"
        txt   = "AL " + (biasBull ? "high" : "low") + " target" + (pre ? " · swept pre-open" : (showZone ? " · " + zone : ""))
        mkLv(bT0, alTgt, colAL, 1, line.style_dashed, txt, biasBull, true, "byk")
        alDone := pre

// AL target swept before the cut-off
if showAL and inNYo and inCut and not alDone and not na(alTgt) and (biasBull ? high >= alTgt : low <= alTgt)
    alDone := true
    mkEvent(alTgt, "AL " + (biasBull ? "high" : "low") + " swept " + hhmm(time), colAL, biasBull)

// ═══════════════════════════════════════════════════════════════════
// FIRST PRESENTED FVG from the session open (3-candle wick gap)
// ═══════════════════════════════════════════════════════════════════
var int   fpT0   = na
var bool  fpDone = false
var int   fpSign = 0
var bool  rfDone = false
if fpStart
    fpT0   := time
    fpDone := false
    fpSign := 0
    rfDone := false

bullGap = low > high[2]
bearGap = high < low[2]
// all three candles must sit inside the session
in3 = inFP and inFP[1] and inFP[2] and not fpStart and not fpStart[1]
withinWin = fpWin <= 0 or (time - fpT0) < fpWin * 60000

if showFP and in3 and not na(fpT0) and (bullGap or bearGap)
    s   = bullGap ? 1 : -1
    gTop = bullGap ? low : low[2]
    gBot = bullGap ? high[2] : high
    t0  = time[2]
    if not fpDone and withinWin
        fpDone := true
        fpSign := s
        mkGap(t0, gTop, gBot, s > 0 ? colFPb : colFPs, stampOf(t0) + " First presented", s < 0, line.style_dotted)
    else if fpDone and showRefl and not rfDone and s != fpSign
        rfDone := true
        mkGap(t0, gTop, gBot, colRefl, stampOf(t0) + " Reflection", s < 0, line.style_dotted)

// ═══════════════════════════════════════════════════════════════════
// EVERY BAR: grow to the current candle, stop at the cut-off, dash, age
// ═══════════════════════════════════════════════════════════════════
nS = store.size()
if nS > 0
    for i = 0 to nS - 1
        lv = store.get(i)
        if lv.live and lv.day != dayCount and not (lv.grp == "fp" and fpExt == "To the present")
            lv.live := false          // a past trading day: its drawings stop where that day ended (FVGs set to the present keep running)
        // Byakugan levels (and the FVG, by default) run up to the cut-off bar, end exactly there, then stop for good
        stopNow = lv.live and ((lv.grp == "byk" and not inCut) or (lv.grp == "fp" and ((fpExt == "Byakugan cut-off" and not inCut) or (fpExt == "Until its session ends" and not inFP))))
        if lv.live
            if not na(lv.ln)
                lv.ln.set_x2(time)
            if not na(lv.bx)
                lv.bx.set_right(time)
            if not lblLeft
                lv.lb.set_x(time)
        if lv.watch and lv.live and not stopNow and not lv.hit and not na(lv.ln) and (lv.above ? high >= lv.y : low <= lv.y)
            lv.hit := true
            lv.ln.set_style(line.style_dashed)
        if stopNow
            lv.live := false
        if dayCount - lv.day >= ageDays
            if not na(lv.ln)
                lv.ln.set_color(agedCol)
            if not na(lv.bx)
                lv.bx.set_bgcolor(color.new(agedCol, 85))
                lv.bx.set_border_color(color.new(agedCol, 60))
            lv.lb.set_textcolor(color.gray)
nE = evLbl.size()
if nE > 0
    for i = 0 to nE - 1
        if dayCount - evDay.get(i) >= ageDays
            evLbl.get(i).set_color(color.new(agedCol, 85))
            evLbl.get(i).set_textcolor(color.gray)
````
