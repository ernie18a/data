<!-- tradingview-pine-id: PUB;bc40875613fa4ea89db45b0e4897d621 -->
<!-- tradingviewscripts-format: 1 -->
# [SkuldX] ADR Levels Pro

Source: https://www.tradingview.com/script/6AWuzfGL-SkuldX-ADR-Levels-Pro/

## Description

SkuldX ADR Levels Pro — Multi-Period Average Daily Range Intelligence
by SkuldX Trading Systems

What is it?
SkuldX ADR Levels Pro calculates the Average Daily Range across three fully independent user-defined periods and projects six statistical price levels per period directly on the chart. It tells you not only where today's expected range boundaries are, but also where the intermediate momentum zones sit — and how much of the daily range has already been consumed. The result is a complete statistical picture of daily price potential on a single overlay.

The core concept
Every instrument has a characteristic daily range — how far it typically moves from low to high in a single session. ADR measures this by averaging the daily High minus Low over N completed days. When today's price approaches an ADR level projected from the daily open, the market is reaching its statistical boundary for the day. The closer price is to the Full ADR level with a high Range Used %, the lower the probability of further extension — and the higher the risk of reversal or consolidation.
The 1/3 and 2/3 levels add depth to this picture. Price rarely moves from the open straight to the Full ADR in one sweep. It pauses at intermediate levels, consolidates, and then either continues or reverses. These fractional levels mark the natural checkpoints in that process.

Three periods — your choice
Unlike fixed-period indicators, SkuldX ADR Levels Pro lets you define each period yourself. Default values are 5, 10, and 20 days but any value from 1 to 100 is supported.
Each period has its own independent color and can be toggled on or off. Running three periods simultaneously gives you three nested zones — the tightest zone reflects recent volatility while the widest reflects the longer-term statistical norm. When all three align closely, the market is in a stable volatility regime. When they diverge significantly, volatility is shifting.

Common configurations:
5 / 10 / 20 — short, medium, long standard view
5 / 5 / 20 — current week vs monthly norm
3 / 7 / 14 — ultra short-term focus
1 / 5 / 20 — today's range vs week vs month

Six levels per period
For each enabled period the indicator draws six levels projected symmetrically above and below the daily open:
1/3 ADR+ and 1/3 ADR- — first momentum checkpoint. Price often pauses here before deciding direction. In a trending day these levels are crossed quickly. In a range day they become support and resistance.
2/3 ADR+ and 2/3 ADR- — second checkpoint. Reaching this level means the day has meaningful momentum. A reversal here often sends price back toward the open or the opposite 1/3 level.
Full ADR+ and Full ADR- — the statistical boundary of the day. Reaching this level means the day has consumed its average range. Continuation beyond is possible but statistically less probable without a catalyst.
A dotted midline marks the daily open — the anchor from which all six levels are measured.

Zone fill
The shaded area between Full ADR High and Full ADR Low gives an immediate visual read of today's expected range. Narrow zones indicate low volatility environments. Wide zones indicate high volatility. When price is inside the zone the day still has statistical room to move. When price approaches or exits the zone boundaries, exhaustion risk increases.
Fill transparency is configurable — reduce it for a stronger visual emphasis or increase it to keep the chart clean.

Range Used %
Each Full ADR label shows the percentage of today's average range that has already been consumed — for example 5ADR+  2415.50  [87.30]  72% used. This single number answers the most important intraday question: how much room does the market have left today?
Below 40% — significant range remaining, directional moves are viable
40–70% — range being consumed, watch for slowdowns near fractional levels
70–90% — approaching statistical limits, momentum may fade
Above 90% — range exhausted, high reversal or consolidation risk at Full ADR levels
Above 100% — unusual expansion day, often driven by news or institutional activity

Historical DR table
The table in the bottom right corner shows each completed day's range for all enabled periods alongside the current ADR value. Color coding is immediate — red cells indicate days where the range exceeded the ADR (above-average volatility), green cells indicate below-average days. Scanning the table gives you an instant read on whether recent volatility is expanding or contracting.

Historical lines
Toggle Show Historical Lines to keep previous days' ADR levels visible on the chart. This is useful for backtesting and identifying recurring price behavior at ADR levels across multiple sessions.

Alerts
A configurable exhaustion alert fires once per bar when the daily range consumed exceeds your threshold (default 90%). The alert message includes the period, exact percentage consumed, and both ADR level prices — so you always have context without looking at the chart.

Settings reference
Period 1 / 2 / 3 — enable, set the day count, and choose a color for each independent period
Show Full ADR — toggle the Full ADR High and Low lines
Show 2/3 ADR — toggle the two-thirds fractional lines
Show 1/3 ADR — toggle the one-third fractional lines
Show Daily Open — toggle the dotted midline
Show Zone Fill — toggle the shaded zone between Full ADR High and Low
Fill Transparency — control the opacity of the zone fill
Show Historical Lines — keep previous day lines on chart
Show Labels — toggle right-edge labels with price and range info
Show Range Used % — include consumption percentage in Full ADR labels
Show DR Table — toggle the historical daily range table
Line Width / Full Style / Frac Style — visual customization
Label Size / Offset — label positioning and size
Alert Threshold % — percentage consumed that triggers the exhaustion alert

How to use it in practice
Defining daily targets — set your take-profit at the nearest Full ADR level when entering an intraday trade. If price is already at 2/3 ADR with 70% of the range consumed, the remaining potential to Full ADR is smaller and the risk-reward deteriorates.
Filtering entries — avoid entering new directional trades when Range Used % exceeds 85–90% and price is near a Full ADR level. The statistical edge has diminished significantly.
Reading momentum — a day that reaches 2/3 ADR quickly and with conviction tends to continue to Full ADR. A day that struggles to hold 1/3 ADR is likely to consolidate or reverse.
Multi-period confluence — when all three period levels cluster at the same price, that area carries significantly more weight as a target or reversal zone. Look for price action confirmation at those confluences.
Combined with session analysis — ADR levels work most powerfully when they align with session structures like the Asian High or London High. A Full ADR level that matches the Asian range boundary becomes a strong institutional reference zone.
Combined with OI data — if price reaches Full ADR+ while OI Delta shows Short Squeeze conditions, the move is likely unsustained. If it reaches Full ADR+ with Bullish Trend OI, the day may extend beyond the statistical average.

Why 00:00 NY as the daily open
Crypto trades 24/7 without a traditional session open. The New York midnight open is used as the anchor because it aligns with institutional risk resets, matches the TDO reference used across the full SkuldX suite, and provides consistent behavior across all instruments and timezones with automatic DST adjustment.

Built for SkuldX ecosystem
SkuldX ADR Levels Pro is designed to complement the full SkuldX suite. ADR levels combined with TDO/TWO opens, OI Delta signals, Level Patterns reactions, and session analysis give a complete statistical and institutional picture of where price is likely to pause, reverse, or accelerate on any given day.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] ADR Levels Pro", overlay = true, max_lines_count = 500, max_labels_count = 500)


// ══════════════════════════════════════════════════════
// INPUTS — ADR PERIODS (user-defined)
// ══════════════════════════════════════════════════════

p1Enable = input.bool(true,  "Period 1", inline = "p1", group = "ADR Periods")
p1Days   = input.int(5,      "",         inline = "p1", group = "ADR Periods", minval = 1, maxval = 100)
p1Color  = input.color(color.new(color.yellow, 0), "days", inline = "p1", group = "ADR Periods")

p2Enable = input.bool(true,  "Period 2", inline = "p2", group = "ADR Periods")
p2Days   = input.int(10,     "",         inline = "p2", group = "ADR Periods", minval = 1, maxval = 100)
p2Color  = input.color(color.new(color.aqua,   0), "days", inline = "p2", group = "ADR Periods")

p3Enable = input.bool(true,  "Period 3", inline = "p3", group = "ADR Periods")
p3Days   = input.int(20,     "",         inline = "p3", group = "ADR Periods", minval = 1, maxval = 100)
p3Color  = input.color(color.new(color.orange, 0), "days", inline = "p3", group = "ADR Periods")


// ══════════════════════════════════════════════════════
// INPUTS — DISPLAY
// ══════════════════════════════════════════════════════

showFull   = input.bool(true,  "Show Full ADR (1/1)",  group = "Levels")
showTwoT   = input.bool(true,  "Show 2/3 ADR",         group = "Levels")
showThird  = input.bool(true,  "Show 1/3 ADR",         group = "Levels")
showOpen   = input.bool(true,  "Show Daily Open",       group = "Levels")
showFill   = input.bool(true,  "Show Zone Fill",        group = "Levels")
fillAlpha  = input.int(92,     "Fill Transparency",     group = "Levels", minval = 50, maxval = 99)
showHist   = input.bool(false, "Show Historical Lines", group = "Levels")
showLabels = input.bool(true,  "Show Labels",           group = "Levels")
showUsage  = input.bool(true,  "Show Range Used %",     group = "Levels")
showTable  = input.bool(true,  "Show DR Table",         group = "Levels")

lineWidth  = input.int(1,        "Line Width",   group = "Style", minval = 1, maxval = 4)
styleFull  = input.string("solid",  "Full Style",  group = "Style", options = ["solid", "dashed", "dotted"])
styleFrac  = input.string("dotted", "Frac Style",  group = "Style", options = ["solid", "dashed", "dotted"])
labelSz    = input.string("small",  "Label Size",  group = "Style", options = ["tiny", "small", "normal"])
lblOffset  = input.int(8, "Label Offset", group = "Style", minval = 1, maxval = 50)

alertEn    = input.bool(true,   "Enable Alert",        group = "Alerts")
alertPct   = input.float(90.0,  "Alert Threshold %",   group = "Alerts", minval = 50.0, maxval = 100.0, step = 5.0)


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

nyHour()   => hour(time,   "America/New_York")
nyMinute() => minute(time, "America/New_York")

lsVal(string s) =>
    switch s
        "dashed" => line.style_dashed
        "dotted" => line.style_dotted
        =>          line.style_solid

szVal(string s) =>
    switch s
        "tiny"   => size.tiny
        "normal" => size.normal
        =>          size.small


// ══════════════════════════════════════════════════════
// ADR CALCULATION ENGINE
// Rolling array stores completed day ranges
// ADR = simple mean over N days
// ══════════════════════════════════════════════════════

var float trackHigh  = na
var float trackLow   = na
var float todayOpen  = na

// Three independent rolling arrays — max period supported = 100
var float[] arr1 = array.new_float(100, 0.0)
var float[] arr2 = array.new_float(100, 0.0)
var float[] arr3 = array.new_float(100, 0.0)

var float adr1 = na
var float adr2 = na
var float adr3 = na

bool isNewDay = nyHour() == 0 and nyMinute() == 0

if isNewDay
    if not na(trackHigh) and not na(trackLow)
        float dr = math.round_to_mintick(trackHigh - trackLow)
        array.unshift(arr1, dr)
        array.pop(arr1)
        array.unshift(arr2, dr)
        array.pop(arr2)
        array.unshift(arr3, dr)
        array.pop(arr3)

    trackHigh := high
    trackLow  := low
    todayOpen := open

    // Calculate ADR using only the relevant period slice
    float sum1 = 0.0
    for i = 0 to p1Days - 1
        sum1 += array.get(arr1, i)
    adr1 := math.round_to_mintick(sum1 / p1Days)

    float sum2 = 0.0
    for i = 0 to p2Days - 1
        sum2 += array.get(arr2, i)
    adr2 := math.round_to_mintick(sum2 / p2Days)

    float sum3 = 0.0
    for i = 0 to p3Days - 1
        sum3 += array.get(arr3, i)
    adr3 := math.round_to_mintick(sum3 / p3Days)

else
    trackHigh := na(trackHigh) ? high : math.max(trackHigh, high)
    trackLow  := na(trackLow)  ? low  : math.min(trackLow,  low)
    todayOpen := todayOpen[1]
    adr1      := adr1[1]
    adr2      := adr2[1]
    adr3      := adr3[1]


// ══════════════════════════════════════════════════════
// DERIVED LEVELS
// Full = Open ± ADR
// 2/3  = Open ± ADR * 0.667
// 1/3  = Open ± ADR * 0.333
// ══════════════════════════════════════════════════════

calcLevels(float adr) =>
    float fullH  = not na(todayOpen) and adr > 0 ? todayOpen + adr          : na
    float fullL  = not na(todayOpen) and adr > 0 ? todayOpen - adr          : na
    float twoTH  = not na(todayOpen) and adr > 0 ? todayOpen + adr * 0.667  : na
    float twoTL  = not na(todayOpen) and adr > 0 ? todayOpen - adr * 0.667  : na
    float thirdH = not na(todayOpen) and adr > 0 ? todayOpen + adr * 0.333  : na
    float thirdL = not na(todayOpen) and adr > 0 ? todayOpen - adr * 0.333  : na
    [fullH, fullL, twoTH, twoTL, thirdH, thirdL]

[p1FH, p1FL, p1TH, p1TL, p1TrH, p1TrL] = calcLevels(adr1)
[p2FH, p2FL, p2TH, p2TL, p2TrH, p2TrL] = calcLevels(adr2)
[p3FH, p3FL, p3TH, p3TL, p3TrH, p3TrL] = calcLevels(adr3)

// Today range used %
float todayRange = not na(trackHigh) and not na(trackLow) ? trackHigh - trackLow : na
float used1 = adr1 > 0 and not na(todayRange) ? todayRange / adr1 * 100 : na
float used2 = adr2 > 0 and not na(todayRange) ? todayRange / adr2 * 100 : na
float used3 = adr3 > 0 and not na(todayRange) ? todayRange / adr3 * 100 : na


// ══════════════════════════════════════════════════════
// LINE MANAGEMENT
// One set of lines per period per level
// Recreated each day, extended rightward each bar
// ══════════════════════════════════════════════════════

// Period 1 lines
var line p1LineFH = na, var line p1LineFL = na
var line p1LineTH = na, var line p1LineTL = na
var line p1LineTrH = na, var line p1LineTrL = na
var line p1LineOpen = na

// Period 2 lines
var line p2LineFH = na, var line p2LineFL = na
var line p2LineTH = na, var line p2LineTL = na
var line p2LineTrH = na, var line p2LineTrL = na

// Period 3 lines
var line p3LineFH = na, var line p3LineFL = na
var line p3LineTH = na, var line p3LineTL = na
var line p3LineTrH = na, var line p3LineTrL = na

// Fill objects
var linefill fill1 = na
var linefill fill2 = na
var linefill fill3 = na

// Helper: draw one line
drawLine(float y, color clr, string sty, bool enabled) =>
    line result = na
    if enabled and not na(y)
        result := line.new(bar_index, y, bar_index + 1, y,
             color = clr, width = lineWidth, style = lsVal(sty))
    result

// Helper: freeze or delete previous day lines
freezeOrDelete(line ln) =>
    if not na(ln)
        if showHist
            line.set_x2(ln, bar_index)
        else
            line.delete(ln)

if isNewDay
    // Freeze or delete all previous lines
    freezeOrDelete(p1LineFH),  freezeOrDelete(p1LineFL)
    freezeOrDelete(p1LineTH),  freezeOrDelete(p1LineTL)
    freezeOrDelete(p1LineTrH), freezeOrDelete(p1LineTrL)
    freezeOrDelete(p1LineOpen)
    freezeOrDelete(p2LineFH),  freezeOrDelete(p2LineFL)
    freezeOrDelete(p2LineTH),  freezeOrDelete(p2LineTL)
    freezeOrDelete(p2LineTrH), freezeOrDelete(p2LineTrL)
    freezeOrDelete(p3LineFH),  freezeOrDelete(p3LineFL)
    freezeOrDelete(p3LineTH),  freezeOrDelete(p3LineTL)
    freezeOrDelete(p3LineTrH), freezeOrDelete(p3LineTrL)

    // Delete fills
    linefill.delete(fill1)
    linefill.delete(fill2)
    linefill.delete(fill3)

    // Draw Period 1
    if p1Enable
        p1LineFH  := drawLine(p1FH,  p1Color, styleFull, showFull)
        p1LineFL  := drawLine(p1FL,  p1Color, styleFull, showFull)
        p1LineTH  := drawLine(p1TH,  p1Color, styleFrac, showTwoT)
        p1LineTL  := drawLine(p1TL,  p1Color, styleFrac, showTwoT)
        p1LineTrH := drawLine(p1TrH, p1Color, styleFrac, showThird)
        p1LineTrL := drawLine(p1TrL, p1Color, styleFrac, showThird)
        p1LineOpen := showOpen ? line.new(bar_index, todayOpen, bar_index + 1, todayOpen,
             color = color.new(color.white, 60), width = 1, style = line.style_dotted) : na

        // Fill between Full High and Full Low
        if showFill and not na(p1LineFH) and not na(p1LineFL)
            fill1 := linefill.new(p1LineFH, p1LineFL, color.new(p1Color, fillAlpha))

    // Draw Period 2
    if p2Enable
        p2LineFH  := drawLine(p2FH,  p2Color, styleFull, showFull)
        p2LineFL  := drawLine(p2FL,  p2Color, styleFull, showFull)
        p2LineTH  := drawLine(p2TH,  p2Color, styleFrac, showTwoT)
        p2LineTL  := drawLine(p2TL,  p2Color, styleFrac, showTwoT)
        p2LineTrH := drawLine(p2TrH, p2Color, styleFrac, showThird)
        p2LineTrL := drawLine(p2TrL, p2Color, styleFrac, showThird)

        if showFill and not na(p2LineFH) and not na(p2LineFL)
            fill2 := linefill.new(p2LineFH, p2LineFL, color.new(p2Color, fillAlpha))

    // Draw Period 3
    if p3Enable
        p3LineFH  := drawLine(p3FH,  p3Color, styleFull, showFull)
        p3LineFL  := drawLine(p3FL,  p3Color, styleFull, showFull)
        p3LineTH  := drawLine(p3TH,  p3Color, styleFrac, showTwoT)
        p3LineTL  := drawLine(p3TL,  p3Color, styleFrac, showTwoT)
        p3LineTrH := drawLine(p3TrH, p3Color, styleFrac, showThird)
        p3LineTrL := drawLine(p3TrL, p3Color, styleFrac, showThird)

        if showFill and not na(p3LineFH) and not na(p3LineFL)
            fill3 := linefill.new(p3LineFH, p3LineFL, color.new(p3Color, fillAlpha))


// Extend all active lines on every bar
extendLine(line ln) =>
    if not na(ln)
        line.set_x2(ln, bar_index + lblOffset)

if not isNewDay
    if p1Enable
        extendLine(p1LineFH),  extendLine(p1LineFL)
        extendLine(p1LineTH),  extendLine(p1LineTL)
        extendLine(p1LineTrH), extendLine(p1LineTrL)
        extendLine(p1LineOpen)
    if p2Enable
        extendLine(p2LineFH),  extendLine(p2LineFL)
        extendLine(p2LineTH),  extendLine(p2LineTL)
        extendLine(p2LineTrH), extendLine(p2LineTrL)
    if p3Enable
        extendLine(p3LineFH),  extendLine(p3LineFL)
        extendLine(p3LineTH),  extendLine(p3LineTL)
        extendLine(p3LineTrH), extendLine(p3LineTrL)


// ══════════════════════════════════════════════════════
// LABELS — last bar only
// ══════════════════════════════════════════════════════

var label[] allLabels = array.new_label()

makeLabel(float y, string txt, color clr) =>
    if not na(y)
        label.new(
             x         = bar_index + lblOffset,
             y         = y,
             text      = txt,
             style     = label.style_label_left,
             color     = color.new(clr, 70),
             textcolor = clr,
             size      = szVal(labelSz))

if barstate.islast and showLabels
    // Delete all previous labels
    for lbl in allLabels
        label.delete(lbl)
    array.clear(allLabels)

    // Daily Open
    if showOpen and not na(todayOpen)
        makeLabel(todayOpen, "Open  " + str.tostring(todayOpen, format.mintick), color.white)

    // Period 1 labels
    if p1Enable and adr1 > 0
        string u1 = showUsage and not na(used1) ? "  " + str.tostring(math.min(used1, 999), "#") + "% used" : ""
        if showFull
            makeLabel(p1FH,  str.tostring(p1Days) + "ADR+  " + str.tostring(p1FH,  format.mintick) + "  [" + str.tostring(adr1, format.mintick) + "]" + u1, p1Color)
            makeLabel(p1FL,  str.tostring(p1Days) + "ADR-  " + str.tostring(p1FL,  format.mintick) + "  [" + str.tostring(adr1, format.mintick) + "]" + u1, p1Color)
        if showTwoT
            makeLabel(p1TH,  "2/3 ADR+  " + str.tostring(p1TH,  format.mintick), p1Color)
            makeLabel(p1TL,  "2/3 ADR-  " + str.tostring(p1TL,  format.mintick), p1Color)
        if showThird
            makeLabel(p1TrH, "1/3 ADR+  " + str.tostring(p1TrH, format.mintick), p1Color)
            makeLabel(p1TrL, "1/3 ADR-  " + str.tostring(p1TrL, format.mintick), p1Color)

    // Period 2 labels
    if p2Enable and adr2 > 0
        string u2 = showUsage and not na(used2) ? "  " + str.tostring(math.min(used2, 999), "#") + "% used" : ""
        if showFull
            makeLabel(p2FH,  str.tostring(p2Days) + "ADR+  " + str.tostring(p2FH,  format.mintick) + "  [" + str.tostring(adr2, format.mintick) + "]" + u2, p2Color)
            makeLabel(p2FL,  str.tostring(p2Days) + "ADR-  " + str.tostring(p2FL,  format.mintick) + "  [" + str.tostring(adr2, format.mintick) + "]" + u2, p2Color)
        if showTwoT
            makeLabel(p2TH,  "2/3 ADR+  " + str.tostring(p2TH,  format.mintick), p2Color)
            makeLabel(p2TL,  "2/3 ADR-  " + str.tostring(p2TL,  format.mintick), p2Color)
        if showThird
            makeLabel(p2TrH, "1/3 ADR+  " + str.tostring(p2TrH, format.mintick), p2Color)
            makeLabel(p2TrL, "1/3 ADR-  " + str.tostring(p2TrL, format.mintick), p2Color)

    // Period 3 labels
    if p3Enable and adr3 > 0
        string u3 = showUsage and not na(used3) ? "  " + str.tostring(math.min(used3, 999), "#") + "% used" : ""
        if showFull
            makeLabel(p3FH,  str.tostring(p3Days) + "ADR+  " + str.tostring(p3FH,  format.mintick) + "  [" + str.tostring(adr3, format.mintick) + "]" + u3, p3Color)
            makeLabel(p3FL,  str.tostring(p3Days) + "ADR-  " + str.tostring(p3FL,  format.mintick) + "  [" + str.tostring(adr3, format.mintick) + "]" + u3, p3Color)
        if showTwoT
            makeLabel(p3TH,  "2/3 ADR+  " + str.tostring(p3TH,  format.mintick), p3Color)
            makeLabel(p3TL,  "2/3 ADR-  " + str.tostring(p3TL,  format.mintick), p3Color)
        if showThird
            makeLabel(p3TrH, "1/3 ADR+  " + str.tostring(p3TrH, format.mintick), p3Color)
            makeLabel(p3TrL, "1/3 ADR-  " + str.tostring(p3TrL, format.mintick), p3Color)


// ══════════════════════════════════════════════════════
// HISTORICAL DR TABLE
// Shows each completed day range + ADR for each period
// Color coded: red = above ADR (high vol), green = below (low vol)
// ══════════════════════════════════════════════════════

var table drTable = na

addRow(table t, float[] arr, int days, float adr, color clr, bool enabled, int row, int validCols, string sz) =>
    int nextRow = row
    if enabled and adr > 0
        table.cell(t, 0, row,
             str.tostring(days) + "ADR=" + str.tostring(adr, format.mintick),
             text_color = color.white, text_size = szVal(sz), bgcolor = color.new(clr, 50))

        for i = 0 to validCols - 1
            float dr = i < days ? array.get(arr, i) : na
            if not na(dr) and dr > 0
                color cellBg = dr > adr ? color.new(color.red, 60) : color.new(color.green, 60)
                table.cell(t, i + 1, row,
                     str.tostring(dr, format.mintick),
                     text_color = color.white, text_size = szVal(sz), bgcolor = cellBg)
            else if not na(dr)
                table.cell(t, i + 1, row, "—",
                     text_color = color.gray, text_size = szVal(sz))

        nextRow := row + 1
    nextRow

if barstate.islast and showTable
    if not na(drTable)
        table.delete(drTable)

    int maxDays   = math.max(p1Enable ? p1Days : 0, p2Enable ? p2Days : 0, p3Enable ? p3Days : 0)
    int validCols = 0
    for i = 0 to maxDays - 1
        if array.get(arr1, i) > 0 or array.get(arr2, i) > 0 or array.get(arr3, i) > 0
            validCols += 1

    if validCols > 0
        int rows = 1
        if p1Enable 
            rows += 1
        if p2Enable 
            rows += 1
        if p3Enable
            rows += 1

        drTable := table.new(
             position     = position.bottom_right,
             columns      = validCols + 1,
             rows         = rows,
             bgcolor      = color.new(color.black, 75),
             frame_color  = color.new(color.gray,  50),
             border_color = color.new(color.gray,  70),
             frame_width  = 1,
             border_width = 1)

        string sz = labelSz

        // Header
        table.cell(drTable, 0, 0, "DR",
             text_color = color.gray, text_size = szVal(sz), bgcolor = color.new(color.black, 60))
        for i = 0 to validCols - 1
            table.cell(drTable, i + 1, 0, "-" + str.tostring(i + 1),
                 text_color = color.gray, text_size = szVal(sz), bgcolor = color.new(color.black, 60))

        // Period rows — addRow return next row index
        int row = 1
        row := addRow(drTable, arr1, p1Days, adr1, p1Color, p1Enable, row, validCols, sz)
        row := addRow(drTable, arr2, p2Days, adr2, p2Color, p2Enable, row, validCols, sz)
        row := addRow(drTable, arr3, p3Days, adr3, p3Color, p3Enable, row, validCols, sz)

// ══════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════

if alertEn
    if p1Enable and not na(used1) and used1 >= alertPct
        alert(str.tostring(p1Days) + "ADR " + str.tostring(used1, "#") + "% consumed — exhaustion risk", alert.freq_once_per_bar)
    if p2Enable and not na(used2) and used2 >= alertPct
        alert(str.tostring(p2Days) + "ADR " + str.tostring(used2, "#") + "% consumed — exhaustion risk", alert.freq_once_per_bar)
    if p3Enable and not na(used3) and used3 >= alertPct
        alert(str.tostring(p3Days) + "ADR " + str.tostring(used3, "#") + "% consumed — exhaustion risk", alert.freq_once_per_bar)


// ══════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════

plot(todayOpen, "Daily Open",    color = color.new(color.white,  100), display = display.data_window)
plot(todayRange,"Today Range",   color = color.new(color.gray,   100), display = display.data_window)

plot(adr1,   "ADR P1 Value",  color = color.new(color.yellow, 100), display = display.data_window)
plot(p1FH,   "P1 Full High",  color = color.new(color.yellow, 100), display = display.data_window)
plot(p1FL,   "P1 Full Low",   color = color.new(color.yellow, 100), display = display.data_window)
plot(p1TH,   "P1 2/3 High",   color = color.new(color.yellow, 100), display = display.data_window)
plot(p1TL,   "P1 2/3 Low",    color = color.new(color.yellow, 100), display = display.data_window)
plot(p1TrH,  "P1 1/3 High",   color = color.new(color.yellow, 100), display = display.data_window)
plot(p1TrL,  "P1 1/3 Low",    color = color.new(color.yellow, 100), display = display.data_window)
plot(used1,  "P1 Used %",     color = color.new(color.yellow, 100), display = display.data_window)

plot(adr2,   "ADR P2 Value",  color = color.new(color.aqua,   100), display = display.data_window)
plot(p2FH,   "P2 Full High",  color = color.new(color.aqua,   100), display = display.data_window)
plot(p2FL,   "P2 Full Low",   color = color.new(color.aqua,   100), display = display.data_window)
plot(p2TH,   "P2 2/3 High",   color = color.new(color.aqua,   100), display = display.data_window)
plot(p2TL,   "P2 2/3 Low",    color = color.new(color.aqua,   100), display = display.data_window)
plot(p2TrH,  "P2 1/3 High",   color = color.new(color.aqua,   100), display = display.data_window)
plot(p2TrL,  "P2 1/3 Low",    color = color.new(color.aqua,   100), display = display.data_window)
plot(used2,  "P2 Used %",     color = color.new(color.aqua,   100), display = display.data_window)

plot(adr3,   "ADR P3 Value",  color = color.new(color.orange, 100), display = display.data_window)
plot(p3FH,   "P3 Full High",  color = color.new(color.orange, 100), display = display.data_window)
plot(p3FL,   "P3 Full Low",   color = color.new(color.orange, 100), display = display.data_window)
plot(p3TH,   "P3 2/3 High",   color = color.new(color.orange, 100), display = display.data_window)
plot(p3TL,   "P3 2/3 Low",    color = color.new(color.orange, 100), display = display.data_window)
plot(p3TrH,  "P3 1/3 High",   color = color.new(color.orange, 100), display = display.data_window)
plot(p3TrL,  "P3 1/3 Low",    color = color.new(color.orange, 100), display = display.data_window)
plot(used3,  "P3 Used %",     color = color.new(color.orange, 100), display = display.data_window)
````
