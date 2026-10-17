# [SkuldX] Trading Sessions

- url: https://www.tradingview.com/script/Lxlxd6LN-SkuldX-Trading-Sessions/
- type: indicator
- pine_id: PUB;2f731fca660844dda8b700507e684868
- version: 1.0

## Description

SkuldX Trading Sessions — Professional Session Structure Visualizer
by SkuldX Trading Systems

[b]What is it?[/b]
SkuldX Trading Sessions maps the full 24-hour trading day into its distinct institutional phases and displays each session's High, Low, and Midpoint directly on the chart. Every session has independent controls — color, labels, levels, and visibility — so you see exactly what you need without clutter. Two optional sessions cover the low-liquidity transition zones that most traders ignore but institutions actively use to position before major opens.

[b]Sessions covered[/b]
The indicator tracks six distinct market phases using New York timezone with automatic DST adjustment:
⬛ [b]Overnight — 16:00–19:00 NY[/b] (off by default). The quiet window between NY close and Asian open. Extremely low liquidity. Useful for identifying where price settles after the US session before Asia takes over. Gaps between the NY close and Asian open often get filled during London or NY.
🟠 [b]Asian Session — 19:00–04:00 NY[/b]. The accumulation and liquidity-building phase. Asian High and Low define the range boundaries that London and New York will interact with throughout the day. The size of the Asian range is a leading indicator of the day's volatility — a tight Asian range often precedes a large directional move in London or NY.
🩵 [b]Pre-London — 04:00–09:00 NY[/b] (off by default). The transition window between Asian close and London open. Price often uses this period to retest Asian levels or build a new directional bias before the first major institutional session. Useful for traders who want visibility into what happens between sessions.
🔵 [b]London Session — 03:00–12:00 NY[/b]. The first major institutional session. London frequently initiates the directional move of the day — breaking Asian range boundaries, sweeping liquidity, and establishing bias. The London High and Low often become the key reference levels for NY entries.
🟢 [b]New York Session — 09:30–16:00 NY[/b]. The highest-liquidity session. NY either continues the London move or reverses it. The most significant OI events and volume spikes occur during this window.
🟡 [b]London + NY Overlap — 09:30–12:00 NY[/b]. The single most volatile window of the trading day. Both institutional pools are simultaneously active. The largest moves, cleanest breakouts, and highest-conviction signals consistently appear during this period.

[b]Asian levels extended to NY close[/b]
When Extend Asian Levels to NY Close is enabled, the Asian High, Low, and Midpoint lines remain visible across London, Overlap, and NY — stretching all the way to 16:00 NY. A label showing the Asian range size in percentage stays at the right edge of the lines throughout the day.
This is one of the most useful features for intraday traders. The Asian range acts as a reference structure for the entire day — London often targets one extreme while NY targets the other. Keeping these levels visible at all times eliminates the need to draw them manually or switch to a daily timeframe.

[b]Session size %[/b]
Every session displays its range as a percentage of price. This appears in two places — as a small label at the session close and in the Data Window when hovering over any bar.
Session size % is immediately useful for several reasons. Comparing today's Asian size to recent averages tells you whether the day is likely to be trending or ranging. A London range that is much larger than the Asian range signals strong directional conviction. A NY range smaller than London suggests exhaustion or consolidation.

[b]H/L/Mid levels[/b]
Each session draws its High, Low, and optional Midpoint as horizontal lines for the duration of that session. These become permanent historical reference levels once the session closes — visible on the chart for backtesting and pattern recognition across multiple days.
The Midpoint is particularly valuable. Price consistently gravitates toward session midpoints during retracement phases, and a session that closes near its midpoint signals indecision rather than conviction.

[b]Settings reference[/b]
Each session has its own independent group of settings:
Show [Session] — master visibility toggle
Color — fully customizable background and level color
Show Label — toggles the session name label at open
Show H/L/Mid Levels — toggles the horizontal level lines
Extend Asian Levels to NY Close — keeps Asian H/L/Mid visible all day (Asian only)
Show Session Size % — includes the range percentage in session close labels
Level Line Width / Style — global line appearance for all session levels
Show Midpoint — global toggle for all session midpoint lines

[b]Data Window[/b]
Hovering over any bar shows the current High, Low, Mid, and Size % for all sessions simultaneously. This is useful for quickly checking where the Asian range sits relative to current price, or comparing session sizes without reading the chart visually.

[b]How to use it in practice[/b]
Building daily bias — check the Asian range size at 04:00 NY when it closes. A range above your recent average suggests an active overnight session with strong positioning. A tight range suggests consolidation and a potentially large London move ahead.
Identifying key levels — Asian High and Low with extension enabled are your primary reference levels for the full day. London frequently sweeps one of these before reversing. NY often targets the opposite extreme. These two levels alone define the day's structural framework.
Reading London intent — when London opens, watch whether it immediately respects Asian levels or drives through them. A clean break with a strong London candle signals directional conviction. A false break that returns inside Asian range signals a potential reversal setup.
Overlap as the signal window — the yellow Overlap zone is where the day's move typically reaches its conclusion or inflection. If price has been trending since London open and reaches a significant level during Overlap, the probability of at least a partial reversal or consolidation increases significantly.
Pre-London context — enable Pre-London to see where price travels in the quiet window before London opens. A Pre-London session that makes a new high above Asian High and then returns inside the range before London opens is a classic setup signal — the stop hunt has already occurred and London may drive aggressively in the opposite direction.
Session size comparison — when London Size % is significantly larger than Asian Size %, the day has strong institutional momentum. When NY Size % exceeds London Size %, NY is driving the day rather than following it — often signals a reversal of the London direction.

[b]Built for SkuldX ecosystem[/b]
SkuldX Trading Sessions is the structural foundation of the SkuldX suite. Session High/Low/Mid levels feed directly into the London Analysis scoring system.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] Trading Sessions", overlay = true, max_lines_count = 500, max_labels_count = 500)


// ══════════════════════════════════════════════════════
// INPUTS — SESSIONS
// ══════════════════════════════════════════════════════

// Asian Session — 19:00–04:00 NY (accumulation phase)
showAsian       = input.bool(true,  "Show Asian Session",        group = "Asian")
colorAsian      = input.color(color.new(color.orange, 88), "Color", group = "Asian")
labelAsian      = input.bool(true,  "Show Label",                group = "Asian")
showAsianLevels = input.bool(true,  "Show H/L/Mid Levels",       group = "Asian")
extendAsian     = input.bool(true,  "Extend Asian Levels to NY Close", group = "Asian")

// Pre-London — 04:00–09:00 NY (transition phase between Asian and London)
showPreLondon       = input.bool(false, "Show Pre-London (04:00–09:00 NY)", group = "Pre-London")
colorPreLondon      = input.color(color.new(color.teal, 88), "Color",       group = "Pre-London")
labelPreLondon      = input.bool(true,  "Show Label",                        group = "Pre-London")
showPreLondonLevels = input.bool(true,  "Show H/L/Mid Levels",               group = "Pre-London")

// London Session — 03:00–12:00 NY (first institutional session)
showLondon       = input.bool(true,  "Show London Session",      group = "London")
colorLondon      = input.color(color.new(color.blue, 88), "Color", group = "London")
labelLondon      = input.bool(true,  "Show Label",               group = "London")
showLondonLevels = input.bool(true,  "Show H/L/Mid Levels",      group = "London")

// New York Session — 09:30–16:00 NY (highest liquidity)
showNY       = input.bool(true,  "Show New York Session",        group = "New York")
colorNY      = input.color(color.new(color.green, 88), "Color",  group = "New York")
labelNY      = input.bool(true,  "Show Label",                   group = "New York")
showNYLevels = input.bool(true,  "Show H/L/Mid Levels",          group = "New York")

// London + NY Overlap — 09:30–12:00 NY (most volatile window)
showOverlap  = input.bool(true,  "Show London+NY Overlap",       group = "Overlap")
colorOverlap = input.color(color.new(color.yellow, 80), "Color", group = "Overlap")
labelOverlap = input.bool(true,  "Show Label",                   group = "Overlap")

// Overnight — 16:00–19:00 NY (low liquidity between NY close and Asian open)
showOvernight       = input.bool(false, "Show Overnight (16:00–19:00 NY)", group = "Overnight")
colorOvernight      = input.color(color.new(color.gray, 88), "Color",      group = "Overnight")
labelOvernight      = input.bool(true,  "Show Label",                       group = "Overnight")
showOvernightLevels = input.bool(false, "Show H/L/Mid Levels",              group = "Overnight")

// Level appearance
levelWidth = input.int(1,        "Level Line Width", group = "Levels", minval = 1, maxval = 4)
levelStyle = input.string("dashed", "Level Style",  group = "Levels", options = ["solid", "dashed", "dotted"])
showMid    = input.bool(true,    "Show Midpoint",    group = "Levels")
showSizePct = input.bool(true,   "Show Session Size %", group = "Levels")


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

nyHour()   => hour(time,   "America/New_York")
nyMinute() => minute(time, "America/New_York")

inAsian() =>
    h = nyHour()
    h >= 19 or h < 4

inPreLondon() =>
    h = nyHour()
    h >= 4 and h < 9

inLondon() =>
    h = nyHour()
    m = nyMinute()
    (h == 3 and m >= 0) or (h > 3 and h < 12) or (h == 12 and m == 0)

inNY() =>
    h = nyHour()
    m = nyMinute()
    (h == 9 and m >= 30) or (h > 9 and h < 16) or (h == 16 and m == 0)

inOverlap() =>
    h = nyHour()
    m = nyMinute()
    (h == 9 and m >= 30) or (h == 10) or (h == 11) or (h == 12 and m == 0)

inOvernight() =>
    h = nyHour()
    h >= 16 and h < 19

lineStyleVal() =>
    switch levelStyle
        "dashed" => line.style_dashed
        "dotted" => line.style_dotted
        =>          line.style_solid

// Draw permanent H/L/Mid lines for completed sessions
drawLevels(float h, float l, int startBar, int endBar, color clr) =>
    line.new(startBar, h, endBar, h,
         color = color.new(clr, 20), width = levelWidth, style = lineStyleVal())
    line.new(startBar, l, endBar, l,
         color = color.new(clr, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        line.new(startBar, (h + l) / 2, endBar, (h + l) / 2,
             color = color.new(clr, 50), width = 1, style = line.style_dotted)

// Session size as % of price — shown in label
sizePct(float h, float l) =>
    l > 0 ? (h - l) / l * 100 : 0.0


// ══════════════════════════════════════════════════════
// STATE — ASIAN
// ══════════════════════════════════════════════════════

var float asianHigh     = na
var float asianLow      = na
var int   asianStartBar = na
var int   asianEndBar   = na
var bool  asianActive   = false
var bool  asianDrawn    = false

// Extended Asian lines — drawn at asianEnd, extended to NY close
var line  asianLineH    = na
var line  asianLineL    = na
var line  asianLineMid  = na
var label asianSizeLbl  = na

// Live lines during Asian session
var line liveAsianH = na
var line liveAsianL = na
var line liveAsianM = na

bool asianStart = nyHour() == 19 and nyMinute() == 0
bool asianEnd   = nyHour() == 4  and nyMinute() == 0
bool nyClose    = nyHour() == 16 and nyMinute() == 0

if asianStart
    // Freeze previous extended Asian lines at start of new Asian
    if not na(asianLineH)
        asianLineH   := na
        asianLineL   := na
        asianLineMid := na
        asianSizeLbl := na

    asianHigh     := high
    asianLow      := low
    asianStartBar := bar_index
    asianActive   := true
    asianDrawn    := false

if asianActive and inAsian()
    asianHigh   := math.max(asianHigh, high)
    asianLow    := math.min(asianLow,  low)
    asianEndBar := bar_index

if asianEnd and asianActive and not asianDrawn
    asianActive := false
    asianDrawn  := true

    if showAsianLevels and not na(asianHigh)
        if extendAsian
            // Create extended lines — will be stretched to NY close each bar
            asianLineH := line.new(asianStartBar, asianHigh, bar_index, asianHigh,
                 color = color.new(color.orange, 20), width = levelWidth, style = lineStyleVal())
            asianLineL := line.new(asianStartBar, asianLow, bar_index, asianLow,
                 color = color.new(color.orange, 20), width = levelWidth, style = lineStyleVal())
            if showMid
                asianLineMid := line.new(asianStartBar, (asianHigh + asianLow) / 2, bar_index, (asianHigh + asianLow) / 2,
                     color = color.new(color.orange, 50), width = 1, style = line.style_dotted)
            if showSizePct
                asianSizeLbl := label.new(bar_index, asianHigh,
                     "Asia " + str.tostring(sizePct(asianHigh, asianLow), "#.##") + "%",
                     style     = label.style_label_left,
                     color     = color.new(color.orange, 60),
                     textcolor = color.white,
                     size      = size.small)
        else
            drawLevels(asianHigh, asianLow, asianStartBar, asianEndBar, color.orange)

// Extend Asian lines and label to end of NY each bar
if not na(asianLineH) and extendAsian and not asianActive
    line.set_x2(asianLineH, bar_index)
    line.set_x2(asianLineL, bar_index)
    if not na(asianLineMid)
        line.set_x2(asianLineMid, bar_index)
    if not na(asianSizeLbl)
        label.set_x(asianSizeLbl, bar_index)

// Live lines during Asian session
if showAsianLevels and asianActive and not na(asianHigh)
    line.delete(liveAsianH)
    line.delete(liveAsianL)
    line.delete(liveAsianM)
    liveAsianH := line.new(asianStartBar, asianHigh, bar_index, asianHigh,
         color = color.new(color.orange, 20), width = levelWidth, style = lineStyleVal())
    liveAsianL := line.new(asianStartBar, asianLow, bar_index, asianLow,
         color = color.new(color.orange, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        liveAsianM := line.new(asianStartBar, (asianHigh + asianLow) / 2, bar_index, (asianHigh + asianLow) / 2,
             color = color.new(color.orange, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// STATE — PRE-LONDON (04:00–09:00 NY)
// ══════════════════════════════════════════════════════

var float preLondonHigh     = na
var float preLondonLow      = na
var int   preLondonStartBar = na
var int   preLondonEndBar   = na
var bool  preLondonActive   = false
var bool  preLondonDrawn    = false
var line  livePLH = na
var line  livePLL = na
var line  livePLM = na

bool preLondonStart = nyHour() == 4 and nyMinute() == 0
bool preLondonEnd   = nyHour() == 9 and nyMinute() == 0

if preLondonStart
    preLondonHigh     := high
    preLondonLow      := low
    preLondonStartBar := bar_index
    preLondonActive   := true
    preLondonDrawn    := false

if preLondonActive and inPreLondon()
    preLondonHigh   := math.max(preLondonHigh, high)
    preLondonLow    := math.min(preLondonLow,  low)
    preLondonEndBar := bar_index

if preLondonEnd and preLondonActive and not preLondonDrawn
    preLondonActive := false
    preLondonDrawn  := true
    if showPreLondon and showPreLondonLevels and not na(preLondonHigh)
        drawLevels(preLondonHigh, preLondonLow, preLondonStartBar, preLondonEndBar, color.teal)

if showPreLondon and showPreLondonLevels and preLondonActive and not na(preLondonHigh)
    line.delete(livePLH)
    line.delete(livePLL)
    line.delete(livePLM)
    livePLH := line.new(preLondonStartBar, preLondonHigh, bar_index, preLondonHigh,
         color = color.new(color.teal, 20), width = levelWidth, style = lineStyleVal())
    livePLL := line.new(preLondonStartBar, preLondonLow, bar_index, preLondonLow,
         color = color.new(color.teal, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        livePLM := line.new(preLondonStartBar, (preLondonHigh + preLondonLow) / 2, bar_index, (preLondonHigh + preLondonLow) / 2,
             color = color.new(color.teal, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// STATE — LONDON
// ══════════════════════════════════════════════════════

var float londonHigh     = na
var float londonLow      = na
var int   londonStartBar = na
var int   londonEndBar   = na
var bool  londonActive   = false
var bool  londonDrawn    = false
var line  liveLondonH = na
var line  liveLondonL = na
var line  liveLondonM = na

bool londonStart = nyHour() == 3 and nyMinute() == 0
bool londonEnd   = nyHour() == 12 and nyMinute() == 0

if londonStart
    londonHigh     := high
    londonLow      := low
    londonStartBar := bar_index
    londonActive   := true
    londonDrawn    := false

if londonActive and inLondon()
    londonHigh   := math.max(londonHigh, high)
    londonLow    := math.min(londonLow,  low)
    londonEndBar := bar_index

if londonEnd and londonActive and not londonDrawn
    londonActive := false
    londonDrawn  := true
    if showLondonLevels and not na(londonHigh)
        drawLevels(londonHigh, londonLow, londonStartBar, londonEndBar, color.blue)

if showLondonLevels and londonActive and not na(londonHigh)
    line.delete(liveLondonH)
    line.delete(liveLondonL)
    line.delete(liveLondonM)
    liveLondonH := line.new(londonStartBar, londonHigh, bar_index, londonHigh,
         color = color.new(color.blue, 20), width = levelWidth, style = lineStyleVal())
    liveLondonL := line.new(londonStartBar, londonLow, bar_index, londonLow,
         color = color.new(color.blue, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        liveLondonM := line.new(londonStartBar, (londonHigh + londonLow) / 2, bar_index, (londonHigh + londonLow) / 2,
             color = color.new(color.blue, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// STATE — NEW YORK
// ══════════════════════════════════════════════════════

var float nyHigh     = na
var float nyLow      = na
var int   nyStartBar = na
var int   nyEndBar   = na
var bool  nyActive   = false
var bool  nyDrawn    = false
var line  liveNYH = na
var line  liveNYL = na
var line  liveNYM = na

bool nyOpen = nyHour() == 9 and nyMinute() == 30

if nyOpen
    nyHigh     := high
    nyLow      := low
    nyStartBar := bar_index
    nyActive   := true
    nyDrawn    := false

if nyActive and inNY()
    nyHigh   := math.max(nyHigh, high)
    nyLow    := math.min(nyLow,  low)
    nyEndBar := bar_index

if nyClose and nyActive and not nyDrawn
    nyActive := false
    nyDrawn  := true
    if showNYLevels and not na(nyHigh)
        drawLevels(nyHigh, nyLow, nyStartBar, nyEndBar, color.green)

if showNYLevels and nyActive and not na(nyHigh)
    line.delete(liveNYH)
    line.delete(liveNYL)
    line.delete(liveNYM)
    liveNYH := line.new(nyStartBar, nyHigh, bar_index, nyHigh,
         color = color.new(color.green, 20), width = levelWidth, style = lineStyleVal())
    liveNYL := line.new(nyStartBar, nyLow, bar_index, nyLow,
         color = color.new(color.green, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        liveNYM := line.new(nyStartBar, (nyHigh + nyLow) / 2, bar_index, (nyHigh + nyLow) / 2,
             color = color.new(color.green, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// STATE — OVERNIGHT (16:00–19:00 NY)
// ══════════════════════════════════════════════════════

var float overnightHigh     = na
var float overnightLow      = na
var int   overnightStartBar = na
var int   overnightEndBar   = na
var bool  overnightActive   = false
var bool  overnightDrawn    = false
var line  liveONH = na
var line  liveONL = na
var line  liveONM = na

bool overnightStart = nyHour() == 16 and nyMinute() == 0
bool overnightEnd   = nyHour() == 19 and nyMinute() == 0

if overnightStart
    overnightHigh     := high
    overnightLow      := low
    overnightStartBar := bar_index
    overnightActive   := true
    overnightDrawn    := false

if overnightActive and inOvernight()
    overnightHigh   := math.max(overnightHigh, high)
    overnightLow    := math.min(overnightLow,  low)
    overnightEndBar := bar_index

if overnightEnd and overnightActive and not overnightDrawn
    overnightActive := false
    overnightDrawn  := true
    if showOvernight and showOvernightLevels and not na(overnightHigh)
        drawLevels(overnightHigh, overnightLow, overnightStartBar, overnightEndBar, color.gray)

if showOvernight and showOvernightLevels and overnightActive and not na(overnightHigh)
    line.delete(liveONH)
    line.delete(liveONL)
    line.delete(liveONM)
    liveONH := line.new(overnightStartBar, overnightHigh, bar_index, overnightHigh,
         color = color.new(color.gray, 20), width = levelWidth, style = lineStyleVal())
    liveONL := line.new(overnightStartBar, overnightLow, bar_index, overnightLow,
         color = color.new(color.gray, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        liveONM := line.new(overnightStartBar, (overnightHigh + overnightLow) / 2, bar_index, (overnightHigh + overnightLow) / 2,
             color = color.new(color.gray, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// BGCOLOR
// ══════════════════════════════════════════════════════

bgcolor(showOvernight  and inOvernight()                       ? colorOvernight : na, title = "Overnight")
bgcolor(showAsian      and inAsian()                           ? colorAsian     : na, title = "Asian Session")
bgcolor(showPreLondon  and inPreLondon()                       ? colorPreLondon : na, title = "Pre-London")
bgcolor(showLondon     and inLondon()  and not inOverlap()     ? colorLondon    : na, title = "London Session")
bgcolor(showNY         and inNY()      and not inOverlap()     ? colorNY        : na, title = "New York Session")
bgcolor(showOverlap    and inOverlap()                         ? colorOverlap   : na, title = "London+NY Overlap")


// ══════════════════════════════════════════════════════
// SESSION LABELS
// ══════════════════════════════════════════════════════

// Helper: session size string
sizeStr(float h, float l) =>
    showSizePct and not na(h) and not na(l) ?
     "\n" + str.tostring(sizePct(h, l), "#.##") + "%" : ""

if showOvernight and labelOvernight and overnightStart
    label.new(bar_index, high, "Overnight" + sizeStr(overnightHigh, overnightLow),
         style = label.style_label_down, color = color.new(color.gray, 40),
         textcolor = color.white, size = size.small)

if showAsian and labelAsian and asianStart
    label.new(bar_index, high, "Asian",
         style = label.style_label_down, color = color.new(color.orange, 40),
         textcolor = color.white, size = size.small)

if showPreLondon and labelPreLondon and preLondonStart
    label.new(bar_index, high, "Pre-London" + sizeStr(preLondonHigh, preLondonLow),
         style = label.style_label_down, color = color.new(color.teal, 40),
         textcolor = color.white, size = size.small)

if showLondon and labelLondon and londonStart
    label.new(bar_index, high, "London",
         style = label.style_label_down, color = color.new(color.blue, 40),
         textcolor = color.white, size = size.small)

if nyOpen
    if showOverlap and labelOverlap
        label.new(bar_index, high, "NY | Overlap",
             style = label.style_label_down, color = color.new(colorOverlap, 40),
             textcolor = color.black, size = size.small)
    else if showNY and labelNY
        label.new(bar_index, high, "New York",
             style = label.style_label_down, color = color.new(color.green, 40),
             textcolor = color.white, size = size.small)

bool overlapEnd = nyHour() == 12 and nyMinute() == 0
if showNY and labelNY and overlapEnd
    label.new(bar_index, high, "NY only" + sizeStr(nyHigh, nyLow),
         style = label.style_label_down, color = color.new(color.green, 40),
         textcolor = color.white, size = size.small)

// Asian size label at session close
if asianEnd and showAsian and labelAsian and not na(asianHigh)
    label.new(bar_index, asianHigh,
         "Asia closed  " + str.tostring(sizePct(asianHigh, asianLow), "#.##") + "%",
         style = label.style_label_down, color = color.new(color.orange, 50),
         textcolor = color.white, size = size.tiny)

// London size label at session close
if londonEnd and showLondon and labelLondon and not na(londonHigh)
    label.new(bar_index, londonHigh,
         "London closed  " + str.tostring(sizePct(londonHigh, londonLow), "#.##") + "%",
         style = label.style_label_down, color = color.new(color.blue, 50),
         textcolor = color.white, size = size.tiny)


// ══════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════

plot(asianHigh,                    "Asian High",        color = color.new(color.orange, 100), display = display.data_window)
plot(asianLow,                     "Asian Low",         color = color.new(color.orange, 100), display = display.data_window)
plot((asianHigh + asianLow) / 2,   "Asian Mid",         color = color.new(color.orange, 100), display = display.data_window)
plot(sizePct(asianHigh, asianLow), "Asian Size %",      color = color.new(color.orange, 100), display = display.data_window)

plot(preLondonHigh,                        "Pre-London High",  color = color.new(color.teal,   100), display = display.data_window)
plot(preLondonLow,                         "Pre-London Low",   color = color.new(color.teal,   100), display = display.data_window)
plot(sizePct(preLondonHigh, preLondonLow), "Pre-London Size %",color = color.new(color.teal,   100), display = display.data_window)

plot(londonHigh,                    "London High",   color = color.new(color.blue,   100), display = display.data_window)
plot(londonLow,                     "London Low",    color = color.new(color.blue,   100), display = display.data_window)
plot((londonHigh + londonLow) / 2,  "London Mid",    color = color.new(color.blue,   100), display = display.data_window)
plot(sizePct(londonHigh, londonLow),"London Size %", color = color.new(color.blue,   100), display = display.data_window)

plot(nyHigh,                       "NY High",           color = color.new(color.green,  100), display = display.data_window)
plot(nyLow,                        "NY Low",            color = color.new(color.green,  100), display = display.data_window)
plot((nyHigh + nyLow) / 2,         "NY Mid",            color = color.new(color.green,  100), display = display.data_window)
plot(sizePct(nyHigh, nyLow),       "NY Size %",         color = color.new(color.green,  100), display = display.data_window)

plot(overnightHigh,                        "Overnight High",   color = color.new(color.gray,   100), display = display.data_window)
plot(overnightLow,                         "Overnight Low",    color = color.new(color.gray,   100), display = display.data_window)
plot(sizePct(overnightHigh, overnightLow), "Overnight Size %", color = color.new(color.gray,   100), display = display.data_window)
````
