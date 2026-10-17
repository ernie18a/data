# [SkuldX] Trading Sessions + ADR Targets

- url: https://www.tradingview.com/script/pApvNT77-SkuldX-Trading-Sessions-ADR-Targets/
- type: indicator
- pine_id: PUB;cc9da4da92ff49e089ecd293931eb768
- version: 1.0

## Description

SkuldX Trading Sessions + ADR Targets — Unified Session & Statistical Range Intelligence
by SkuldX Trading Systems

[b]What is it?[/b]
SkuldX Trading Sessions + ADR Targets combines two of the most powerful concepts in intraday technical analysis into a single overlay indicator. It visualizes all four major trading sessions with their High, Low, and Midpoint levels — and simultaneously projects statistically-derived daily price targets using the Average Daily Range. Instead of switching between multiple tools, you get the complete session and volatility picture on one chart.

[b]Session visualization[/b]
The indicator tracks four sessions using New York timezone with automatic DST adjustment:
🟠 [b]Asian Session — 19:00–04:00 NY[/b]. The accumulation phase where liquidity is built. Asian High and Low define the range that London and New York will interact with.
🔵 [b]London Session — 03:00–12:00 NY[/b]. The first major institutional session. Often initiates the directional move of the day by breaking Asian range boundaries.
🟢 [b]New York Session — 09:30–16:00 NY[/b]. Highest liquidity. Most significant price moves and OI events occur here.
🟡 [b]London + NY Overlap — 09:30–12:00 NY[/b]. The most volatile window of the trading day. Both institutional pools active simultaneously.
Each session displays its High, Low, and optional Midpoint as horizontal lines that extend across the chart for the duration of that session. Historical sessions remain visible for backtesting and pattern recognition.

[b]ADR Target levels[/b]
The Average Daily Range is calculated as the simple mean of completed daily High minus Low values over your chosen period. From this single number, the indicator projects price targets in two distinct modes — both can be active simultaneously.
[b]Mode 1 — Daily Open targets[/b]
Projects the ADR symmetrically above and below the 00:00 NY daily open:
Open + ADR — the statistical upside limit for the day
Open - ADR — the statistical downside limit for the day
This mode tells you where price is expected to reach if the day moves in either direction from its opening price.
[b]Mode 2 — Asian High/Low targets[/b]
Projects the ADR from the Asian session extremes after the Asian session closes at 04:00 NY:
Asian Low + ADR — the bullish daily target. If the day is trending up, this is where price statistically exhausts itself after departing from the Asian floor.
Asian High - ADR — the bearish daily target. If the day is trending down from the Asian ceiling, this is the statistical destination.
This mode is more practical for intraday directional trading because it accounts for where the day actually started its directional move rather than where the clock rolled over to midnight.
[b]Mode 3 — Both simultaneously[/b]
Shows all four levels at once. The Daily Open zone (solid fill) and the Asian target zone (lighter fill) overlay each other. When they converge at similar prices, those confluences carry significantly higher weight as targets and reversal points.

[b]Zone fill[/b]
The shaded area between the Bull and Bear target for each mode gives an immediate visual read on today's expected range. Price inside the zone has statistical room to move in either direction. Price approaching the zone boundary indicates potential exhaustion.

[b]Range Used %[/b]
Each ADR label shows how much of the average daily range has already been consumed today — for example Open+  [ADR 87.30]  72% used. This answers the core intraday question: how much room does the market have left?
Below 50% — substantial range remaining, directional moves viable
50–80% — range being consumed, watch ADR levels for slowdowns
Above 90% — statistical exhaustion, high reversal or consolidation risk
Above 100% — unusual expansion day, often news or institutional driven

[b]Alerts[/b]
A configurable alert fires when the daily range consumed exceeds your threshold. The message includes the ADR value, percentage consumed, and both Asian target levels — giving full context without needing to check the chart.

[b]Settings reference[/b]
Session groups — each session has independent color, label, and H/L/Mid level toggles
Level Line Width / Style — visual style for session H/L/Mid lines
Show Midpoint Level — toggle the session midpoint line
Show ADR Targets — master toggle for all ADR levels
ADR Period (days) — how many completed days to average. Default 14. Use 5 for recent volatility, 20 for longer-term reference.
ADR Base Mode — Daily Open / Asian High/Low / Both
ADR Target Color — color for all ADR target lines and fills
Show Zone Fill — toggle the shaded zone between bull and bear targets
Fill Transparency — opacity of the zone fill
Show ADR Labels — toggle right-edge labels
Show Range Used % — include consumption percentage in labels
Label Offset — horizontal distance from last bar to labels
ADR Line Width / Style / Label Size — visual customization
Enable Exhaustion Alert / Alert Threshold % — configure the range exhaustion notification

[b]How to use it in practice[/b]
Reading the day before it starts — when Asian session closes at 04:00 NY, the Asian Bull and Bear targets appear immediately. Combined with the London Bias (did London open above or below Asian Mid?), you have a directional hypothesis and a statistical price target before London and NY even reach full activity.
Identifying high-probability targets — when an ADR target level aligns with a session High or Low from a previous session, that confluence becomes a significant reference. For example, if Asian Bull Target coincides with the previous day's London High, price reaching that area carries double the structural significance.
Managing trades — use ADR targets as take-profit references. If price is approaching Asian Bull Target with 85%+ range consumed, the statistical case for further upside deteriorates. Consider taking profit rather than holding for extension.
Filtering entries — avoid entering new directional longs when price is already near the ADR Bull Target with high range used. The edge has diminished. Wait for a fresh session reset.
Overlap as the trigger — the Overlap zone (09:30–12:00 NY) highlighted in yellow is where ADR targets are most frequently reached or rejected. Watch how price behaves at ADR levels during this window. A clean rejection at Asian Bull Target during Overlap with declining momentum is a high-probability reversal setup.
Combining with OI data — if price reaches Asian Bull Target while OI Delta shows Short Squeeze conditions, the move is likely unsustained. If price reaches the same level with Bullish Trend OI, the day may extend beyond the statistical average.

[b]Why 00:00 NY as the daily open[/b]
Crypto trades 24/7 without a traditional open. The New York midnight open is used as the anchor because it aligns with institutional risk resets and matches the TDO reference used across the full SkuldX suite. All session times use America/New_York timezone with automatic DST handling — no manual adjustment needed across summer and winter.

[b]Built for SkuldX ecosystem[/b]
SkuldX Trading Sessions + ADR Targets is the central context layer of the SkuldX suite. Session structure and statistical range targets combined with OI Delta signals, Level Patterns reactions, and FVG analysis provide a complete institutional picture of where price is likely to move, pause, or reverse on any given day.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] Trading Sessions + ADR Targets", overlay = true, max_lines_count = 500, max_labels_count = 500)


// ══════════════════════════════════════════════════════
// INPUTS — SESSIONS
// ══════════════════════════════════════════════════════

showAsian        = input.bool(true,  "Show Asian Session",     group = "Asian")
colorAsian       = input.color(color.new(color.orange, 88),    "Color",          group = "Asian")
labelAsian       = input.bool(true,  "Show Label",             group = "Asian")
showAsianLevels  = input.bool(true,  "Show H/L/Mid Levels",    group = "Asian")

showLondon       = input.bool(true,  "Show London Session",    group = "London")
colorLondon      = input.color(color.new(color.blue, 88),      "Color",          group = "London")
labelLondon      = input.bool(true,  "Show Label",             group = "London")
showLondonLevels = input.bool(true,  "Show H/L/Mid Levels",    group = "London")

showNY           = input.bool(true,  "Show New York Session",  group = "New York")
colorNY          = input.color(color.new(color.green, 88),     "Color",          group = "New York")
labelNY          = input.bool(true,  "Show Label",             group = "New York")
showNYLevels     = input.bool(true,  "Show H/L/Mid Levels",    group = "New York")

showOverlap      = input.bool(true,  "Show London+NY Overlap", group = "Overlap")
colorOverlap     = input.color(color.new(color.yellow, 80),    "Color",          group = "Overlap")
labelOverlap     = input.bool(true,  "Show Label",             group = "Overlap")

levelWidth       = input.int(1,      "Level Line Width",       group = "Levels", minval = 1, maxval = 4)
levelStyle       = input.string("dashed", "Level Style",       group = "Levels", options = ["solid", "dashed", "dotted"])
showMid          = input.bool(true,  "Show Midpoint Level",    group = "Levels")


// ══════════════════════════════════════════════════════
// INPUTS — ADR
// ══════════════════════════════════════════════════════

showADR      = input.bool(true,   "Show ADR Targets",          group = "ADR")
adrDays      = input.int(14,      "ADR Period (days)",          group = "ADR", minval = 1, maxval = 100)
adrMode      = input.string("Both", "ADR Base Mode",           group = "ADR", options = ["Daily Open", "Asian High/Low", "Both"])
adrColor     = input.color(color.new(color.purple, 0), "ADR Target Color", group = "ADR")
adrFillAlpha = input.int(92,      "Fill Transparency",          group = "ADR", minval = 50, maxval = 99)
showADRFill  = input.bool(true,   "Show Zone Fill",             group = "ADR")
showADRLabel = input.bool(true,   "Show ADR Labels",            group = "ADR")
showADRUsage = input.bool(true,   "Show Range Used %",          group = "ADR")
adrLblOffset = input.int(8,       "Label Offset",               group = "ADR", minval = 1, maxval = 50)
adrLineWidth = input.int(1,       "ADR Line Width",             group = "ADR", minval = 1, maxval = 4)
adrLineStyle = input.string("solid", "ADR Line Style",          group = "ADR", options = ["solid", "dashed", "dotted"])
adrLabelSize = input.string("small", "ADR Label Size",          group = "ADR", options = ["tiny", "small", "normal"])

alertEnable  = input.bool(true,   "Enable Exhaustion Alert",    group = "ADR")
alertThresh  = input.float(90.0,  "Alert Threshold %",          group = "ADR", minval = 50.0, maxval = 100.0, step = 5.0)


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

nyHour()   => hour(time,   "America/New_York")
nyMinute() => minute(time, "America/New_York")

inAsian() =>
    h = nyHour()
    h >= 19 or h < 4

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

lineStyleVal() =>
    switch levelStyle
        "dashed" => line.style_dashed
        "dotted" => line.style_dotted
        =>          line.style_solid

adrLineStyleVal() =>
    switch adrLineStyle
        "dashed" => line.style_dashed
        "dotted" => line.style_dotted
        =>          line.style_solid

szVal() =>
    switch adrLabelSize
        "tiny"   => size.tiny
        "normal" => size.normal
        =>          size.small

drawLevels(float h, float l, int startBar, int endBar, color clr) =>
    line.new(startBar, h, endBar, h, color = color.new(clr, 20), width = levelWidth, style = lineStyleVal())
    line.new(startBar, l, endBar, l, color = color.new(clr, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        line.new(startBar, (h + l) / 2, endBar, (h + l) / 2,
             color = color.new(clr, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// SESSION STATE
// ══════════════════════════════════════════════════════

var float asianHigh      = na
var float asianLow       = na
var int   asianStartBar  = na
var int   asianEndBar    = na
var bool  asianActive    = false
var bool  asianDrawn     = false

var float londonHigh     = na
var float londonLow      = na
var int   londonStartBar = na
var int   londonEndBar   = na
var bool  londonActive   = false
var bool  londonDrawn    = false

var float nyHigh         = na
var float nyLow          = na
var int   nyStartBar     = na
var int   nyEndBar       = na
var bool  nyActive       = false
var bool  nyDrawn        = false

var line liveAsianH  = na, var line liveAsianL  = na, var line liveAsianM  = na
var line liveLondonH = na, var line liveLondonL = na, var line liveLondonM = na
var line liveNYH     = na, var line liveNYL     = na, var line liveNYM     = na


// ══════════════════════════════════════════════════════
// SESSION LOGIC — ASIAN
// ══════════════════════════════════════════════════════

bool asianStart = nyHour() == 19 and nyMinute() == 0
bool asianEnd   = nyHour() == 4  and nyMinute() == 0

if asianStart
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
        drawLevels(asianHigh, asianLow, asianStartBar, asianEndBar, color.orange)

if showAsianLevels and asianActive and not na(asianHigh)
    line.delete(liveAsianH)
    line.delete(liveAsianL)
    line.delete(liveAsianM)
    liveAsianH := line.new(asianStartBar, asianHigh, bar_index, asianHigh, color = color.new(color.orange, 20), width = levelWidth, style = lineStyleVal())
    liveAsianL := line.new(asianStartBar, asianLow,  bar_index, asianLow,  color = color.new(color.orange, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        liveAsianM := line.new(asianStartBar, (asianHigh + asianLow) / 2, bar_index, (asianHigh + asianLow) / 2, color = color.new(color.orange, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// SESSION LOGIC — LONDON
// ══════════════════════════════════════════════════════

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
    liveLondonH := line.new(londonStartBar, londonHigh, bar_index, londonHigh, color = color.new(color.blue, 20), width = levelWidth, style = lineStyleVal())
    liveLondonL := line.new(londonStartBar, londonLow,  bar_index, londonLow,  color = color.new(color.blue, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        liveLondonM := line.new(londonStartBar, (londonHigh + londonLow) / 2, bar_index, (londonHigh + londonLow) / 2, color = color.new(color.blue, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// SESSION LOGIC — NEW YORK
// ══════════════════════════════════════════════════════

bool nyOpen  = nyHour() == 9  and nyMinute() == 30
bool nyClose = nyHour() == 16 and nyMinute() == 0

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
    liveNYH := line.new(nyStartBar, nyHigh, bar_index, nyHigh, color = color.new(color.green, 20), width = levelWidth, style = lineStyleVal())
    liveNYL := line.new(nyStartBar, nyLow,  bar_index, nyLow,  color = color.new(color.green, 20), width = levelWidth, style = lineStyleVal())
    if showMid
        liveNYM := line.new(nyStartBar, (nyHigh + nyLow) / 2, bar_index, (nyHigh + nyLow) / 2, color = color.new(color.green, 50), width = 1, style = line.style_dotted)


// ══════════════════════════════════════════════════════
// ADR CALCULATION
// Tracks completed daily ranges in a rolling array
// Supports two modes:
//   Daily Open: targets projected from 00:00 NY open
//   Asian High/Low: targets from Asian session extremes
// ══════════════════════════════════════════════════════

var float adrTrackHigh = na
var float adrTrackLow  = na
var float todayOpen    = na
var float[] adrArr     = array.new_float(100, 0.0)
var float   adrValue   = na

bool isNewDay = nyHour() == 0 and nyMinute() == 0

if isNewDay
    if not na(adrTrackHigh) and not na(adrTrackLow)
        array.unshift(adrArr, math.round_to_mintick(adrTrackHigh - adrTrackLow))
        array.pop(adrArr)

        float s = 0.0
        for i = 0 to adrDays - 1
            s += array.get(adrArr, i)
        adrValue := math.round_to_mintick(s / adrDays)

    adrTrackHigh := high
    adrTrackLow  := low
    todayOpen    := open
else
    adrTrackHigh := na(adrTrackHigh) ? high : math.max(adrTrackHigh, high)
    adrTrackLow  := na(adrTrackLow)  ? low  : math.min(adrTrackLow,  low)
    todayOpen    := todayOpen[1]
    adrValue     := adrValue[1]

// Today's range consumed
float todayRange = not na(adrTrackHigh) and not na(adrTrackLow) ?
     adrTrackHigh - adrTrackLow : na
float usedPct = adrValue > 0 and not na(todayRange) ?
     todayRange / adrValue * 100 : na


// ══════════════════════════════════════════════════════
// ADR TARGET LEVELS
//
// Mode: Daily Open
//   bullTarget = Daily Open + ADR
//   bearTarget = Daily Open - ADR
//
// Mode: Asian High/Low
//   bullTarget = Asian Low  + ADR  (bullish day — up from Asian Low)
//   bearTarget = Asian High - ADR  (bearish day — down from Asian High)
//
// Mode: Both — shows all four levels simultaneously
// ══════════════════════════════════════════════════════

// Daily Open targets
float openBullTarget = not na(todayOpen) and adrValue > 0 ? todayOpen + adrValue : na
float openBearTarget = not na(todayOpen) and adrValue > 0 ? todayOpen - adrValue : na

// Asian targets — available after Asian session closes
float asianBullTarget = not na(asianLow)  and adrValue > 0 ? asianLow  + adrValue : na
float asianBearTarget = not na(asianHigh) and adrValue > 0 ? asianHigh - adrValue : na


// ══════════════════════════════════════════════════════
// ADR LINE AND FILL MANAGEMENT
// ══════════════════════════════════════════════════════

// Daily Open mode lines
var line lineOpenBull = na
var line lineOpenBear = na
var linefill fillOpen = na

// Asian mode lines
var line lineAsianBull = na
var line lineAsianBear = na
var linefill fillAsian = na

// Labels array — cleared and redrawn on last bar
var label[] adrLabels = array.new_label()

if isNewDay and showADR and adrValue > 0
    // Delete previous lines and fills
    line.delete(lineOpenBull)
    line.delete(lineOpenBear)
    line.delete(lineAsianBull)
    line.delete(lineAsianBear)
    linefill.delete(fillOpen)
    linefill.delete(fillAsian)

    // Draw Daily Open mode lines
    if adrMode == "Daily Open" or adrMode == "Both"
        if not na(openBullTarget)
            lineOpenBull := line.new(bar_index, openBullTarget, bar_index + 1, openBullTarget,
                 color = adrColor, width = adrLineWidth, style = adrLineStyleVal())
        if not na(openBearTarget)
            lineOpenBear := line.new(bar_index, openBearTarget, bar_index + 1, openBearTarget,
                 color = adrColor, width = adrLineWidth, style = adrLineStyleVal())
        if showADRFill and not na(lineOpenBull) and not na(lineOpenBear)
            fillOpen := linefill.new(lineOpenBull, lineOpenBear, color.new(adrColor, adrFillAlpha))

// Draw Asian mode lines — after Asian closes (04:00 NY)
if asianEnd and showADR and adrValue > 0 and (adrMode == "Asian High/Low" or adrMode == "Both")
    line.delete(lineAsianBull)
    line.delete(lineAsianBear)
    linefill.delete(fillAsian)

    if not na(asianBullTarget)
        lineAsianBull := line.new(bar_index, asianBullTarget, bar_index + 1, asianBullTarget,
             color = color.new(adrColor, 30), width = adrLineWidth, style = adrLineStyleVal())
    if not na(asianBearTarget)
        lineAsianBear := line.new(bar_index, asianBearTarget, bar_index + 1, asianBearTarget,
             color = color.new(adrColor, 30), width = adrLineWidth, style = adrLineStyleVal())
    if showADRFill and not na(lineAsianBull) and not na(lineAsianBear)
        fillAsian := linefill.new(lineAsianBull, lineAsianBear, color.new(adrColor, adrFillAlpha))

// Extend all active ADR lines rightward
if showADR and adrValue > 0
    if not na(lineOpenBull)
        line.set_x2(lineOpenBull, bar_index + adrLblOffset)
    if not na(lineOpenBear)
        line.set_x2(lineOpenBear, bar_index + adrLblOffset)
    if not na(lineAsianBull)
        line.set_x2(lineAsianBull, bar_index + adrLblOffset)
    if not na(lineAsianBear)
        line.set_x2(lineAsianBear, bar_index + adrLblOffset)


// ══════════════════════════════════════════════════════
// ADR LABELS — last bar only
// ══════════════════════════════════════════════════════

makeADRLabel(float y, string txt, color clr, int x, string sz, label[] lblArr) =>
    if not na(y)
        lbl = label.new(
             x         = x,
             y         = y,
             text      = txt,
             style     = label.style_label_left,
             color     = color.new(clr, 60),
             textcolor = clr,
             size      = szVal())
        array.push(lblArr, lbl)
        

if barstate.islast and showADR and showADRLabel and adrValue > 0
    for lbl in adrLabels
        label.delete(lbl)
    array.clear(adrLabels)

    int    x      = bar_index + adrLblOffset
    string sz     = adrLabelSize
    string usedStr = showADRUsage and not na(usedPct) ?
         "  " + str.tostring(math.min(usedPct, 999), "#") + "% used" : ""
    string adrStr  = "  [ADR " + str.tostring(adrValue, format.mintick) + "]"

    // Daily Open labels
    if adrMode == "Daily Open" or adrMode == "Both"
        makeADRLabel(openBullTarget, "Open+" + adrStr + usedStr, adrColor, x, sz, adrLabels)
        makeADRLabel(openBearTarget, "Open-" + adrStr + usedStr, adrColor, x, sz, adrLabels)
        if not na(todayOpen)
            makeADRLabel(todayOpen, "Daily Open  " + str.tostring(todayOpen, format.mintick), color.white, x, sz, adrLabels)

    // Asian High/Low labels
    if adrMode == "Asian High/Low" or adrMode == "Both"
        makeADRLabel(asianBullTarget, "Asian Low+"  + adrStr + usedStr, color.new(adrColor, 30), x, sz, adrLabels)
        makeADRLabel(asianBearTarget, "Asian High-" + adrStr + usedStr, color.new(adrColor, 30), x, sz, adrLabels)


// ══════════════════════════════════════════════════════
// BGCOLOR + SESSION LABELS
// ══════════════════════════════════════════════════════

bgcolor(showAsian  and inAsian()  and not inOverlap() ? colorAsian  : na, title = "Asian Session")
bgcolor(showLondon and inLondon() and not inOverlap() ? colorLondon : na, title = "London Session")
bgcolor(showNY     and inNY()     and not inOverlap() ? colorNY     : na, title = "New York Session")
bgcolor(showOverlap and inOverlap()                   ? colorOverlap: na, title = "London+NY Overlap")

if showAsian and labelAsian and asianStart
    label.new(bar_index, high, "Asian",
         style = label.style_label_down, color = color.new(color.orange, 40),
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
    label.new(bar_index, high, "NY only",
         style = label.style_label_down, color = color.new(color.green, 40),
         textcolor = color.white, size = size.small)


// ══════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════

if alertEnable and not na(usedPct) and usedPct >= alertThresh and adrValue > 0
    alert(
         str.tostring(adrDays) + "ADR " + str.tostring(usedPct, "#") +
         "% consumed — exhaustion risk" +
         " | ADR = " + str.tostring(adrValue, format.mintick) +
         " | Asian Bull Target = " + str.tostring(asianBullTarget, format.mintick) +
         " | Asian Bear Target = " + str.tostring(asianBearTarget, format.mintick),
         alert.freq_once_per_bar)


// ══════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════

// Session levels
plot(asianHigh,                  "Asian High",        color = color.new(color.orange, 100), display = display.data_window)
plot(asianLow,                   "Asian Low",         color = color.new(color.orange, 100), display = display.data_window)
plot((asianHigh + asianLow) / 2, "Asian Mid",         color = color.new(color.orange, 100), display = display.data_window)
plot(londonHigh,                 "London High",       color = color.new(color.blue,   100), display = display.data_window)
plot(londonLow,                  "London Low",        color = color.new(color.blue,   100), display = display.data_window)
plot((londonHigh+londonLow) / 2, "London Mid",        color = color.new(color.blue,   100), display = display.data_window)
plot(nyHigh,                     "NY High",           color = color.new(color.green,  100), display = display.data_window)
plot(nyLow,                      "NY Low",            color = color.new(color.green,  100), display = display.data_window)
plot((nyHigh + nyLow) / 2,       "NY Mid",            color = color.new(color.green,  100), display = display.data_window)

// ADR values
plot(adrValue,        "ADR Value",           color = color.new(color.purple, 100), display = display.data_window)
plot(todayOpen,       "Daily Open",          color = color.new(color.white,  100), display = display.data_window)
plot(openBullTarget,  "Open Bull Target",    color = color.new(color.purple, 100), display = display.data_window)
plot(openBearTarget,  "Open Bear Target",    color = color.new(color.purple, 100), display = display.data_window)
plot(asianBullTarget, "Asian Bull Target",   color = color.new(color.purple, 100), display = display.data_window)
plot(asianBearTarget, "Asian Bear Target",   color = color.new(color.purple, 100), display = display.data_window)
plot(usedPct,         "ADR Used %",          color = color.new(color.purple, 100), display = display.data_window)
plot(todayRange,      "Today Range",         color = color.new(color.gray,   100), display = display.data_window)
````
