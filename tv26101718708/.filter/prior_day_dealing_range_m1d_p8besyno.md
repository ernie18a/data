# Prior Day Dealing Range [M1D]

- url: https://www.tradingview.com/script/p8BesYNO-Prior-Day-Dealing-Range-M1D/
- type: indicator
- pine_id: PUB;dd71d48fc7364f53bc42f58d27c52a9f
- version: 2.0

## Description

Frames the previous day's range as an ICT dealing range — high, low, equilibrium, quartiles, and premium/discount extreme zones — with a session-selectable day boundary, sweep mitigation, and a live bias table.

WHAT IT DOES
This indicator plots the prior trading day's range and frames it the way an ICT trader reads a dealing range, rather than as three disconnected lines:
• PDH / PDL — previous day high and low
• PDEQ — equilibrium (the 0.5 midpoint of the prior range)
• 0.25 / 0.75 quartiles — the boundaries that split the range into premium, equilibrium and discount
• Premium & discount extreme zones — the top quartile (0.75→1.0) and bottom quartile (0.0→0.25) shaded as the areas where price most often reacts

All levels and zones share a single left anchor at the day's open, so they read as one stacked range projecting into the current session.

WHY A DEALING RANGE INSTEAD OF JUST PDH/PDL
Equilibrium tells you whether price is trading at a premium (above 0.5) or a discount (below 0.5); the quartile zones mark the extremes where reversions and sweeps tend to cluster. The bias table reduces that to a single read.

SESSION-ANCHORED DAY OPEN
The "day" can be anchored to Exchange (the chart's native daily boundary, works on all timeframes), or to NY Midnight / 8:30 NY / 9:30 NY. The NY options reset the range on the open that matters to your model and are intended for intraday charts (roughly 30m and below); Exchange is the safe default for any timeframe.

MITIGATION
When a confirmed bar sweeps PDH or PDL, that line fades to a dotted "mitigated" style and its label updates. This is sweep awareness only, evaluated on bar close (no intrabar repaint).

BIAS TABLE
Shows the PDEQ price, which zone price currently sits in (Premium / Discount, with an "extreme" flag in a quartile zone), and the exact position of price within the prior range as a percentage.

ALERTS
Cross above / below PDEQ, entry into the premium / discount extreme zone, and PDH / PDL swept.

HOW TO USE
1. Pick your day anchor — Exchange for a standard daily range, or an NY session open if your model resets there.
2. Read bias from PDEQ: above = premium (favor shorts), below = discount (favor longs).
3. Watch the extreme zones and PDH/PDL for sweeps; the mitigation styling flags when a level has been run.
4. Toggle any element (zones, quartiles, labels, table) off in settings to suit your chart.

NOTES / LIMITATIONS
• Levels are confirmed on the close of each day and held for the following session; they do not repaint.
• NY-anchored modes assume the session window aligns to a bar boundary, so they are best on intraday timeframes; on higher timeframes use Exchange.
• This is a contextual / discretionary tool — it marks levels and bias, it does not generate buy/sell signals.

The previous-day high/low/equilibrium calculation is standard; this script's contribution is the combination — a session-selectable day boundary, the full quartile dealing-range framing with premium/discount extreme zones, sweep mitigation, and a range-position bias table in one tool. All code is original and written in Pine Script v6.

## Source Code

````pine
//@version=6
indicator("Prior-Day Dealing Range — PDH / PDEQ / PDL [M1D]", shorttitle = "PD Range [M1D]", overlay = true, max_lines_count = 50, max_labels_count = 50, max_boxes_count = 10)
// Made by M1D — prior-day high/low/equilibrium framed as a ICT dealing range:
//   session-anchored day open · quartile levels (0.25/0.5/0.75) · premium & discount extreme zones · mitigation · bias table

// ============================================================
// CONSTANTS
// ============================================================
color COL_ABOVE = #2600ff     // premium (blue)
color COL_BELOW = #ff004c     // discount (red)

// ============================================================
// INPUTS
// ============================================================
string GRP_DAY    = "Day Anchor"
string GRP_EQ     = "PDEQ (Equilibrium)"
string GRP_HL     = "PDH / PDL"
string GRP_QRT    = "Quartiles (Dealing Range)"
string GRP_ZONE   = "Premium / Discount Zones"
string GRP_LABELS = "Labels"
string GRP_MIT    = "Mitigation"
string GRP_TABLE  = "Bias Table"

// Day anchor
string anchorInp = input.string("Exchange", "Day Open Anchor", options = ["Exchange", "NY Midnight", "8:30 NY", "9:30 NY"], group = GRP_DAY, tooltip = "Which 'day' the prior range is measured on. Exchange = chart's native day (works on all TFs). The NY options anchor the day boundary to that New York time and are intended for intraday charts (<= ~30m).")

// PDEQ
bool   showEqInp     = input.bool(true,                  "Show PDEQ",       group = GRP_EQ)
color  eqColorInp    = input.color(color.new(#000000, 0),"PDEQ Color",      group = GRP_EQ)
string eqStyleInp    = input.string("Solid",             "PDEQ Style", options = ["Solid", "Dotted", "Dashed"], group = GRP_EQ)
int    eqWidthInp    = input.int(1,                      "PDEQ Width", minval = 1, maxval = 4, group = GRP_EQ)

// PDH / PDL
bool   showHighInp   = input.bool(true,        "Show PDH",       group = GRP_HL)
bool   showLowInp    = input.bool(true,        "Show PDL",       group = GRP_HL)
color  hlColorInp    = input.color(color.gray, "PDH / PDL Color",group = GRP_HL)
int    hlWidthInp    = input.int(2,            "PDH / PDL Width",minval = 1, maxval = 4, group = GRP_HL)

// Quartiles
bool   showQrtInp    = input.bool(true,                       "Show 0.25 / 0.75 Lines", group = GRP_QRT)
color  qrtColorInp   = input.color(color.new(color.gray, 30), "Quartile Color",         group = GRP_QRT)
string qrtStyleInp   = input.string("Dotted",                 "Quartile Style", options = ["Solid", "Dotted", "Dashed"], group = GRP_QRT)

// Zones
bool   showZonesInp  = input.bool(true,                          "Shade Premium / Discount Extremes", group = GRP_ZONE, tooltip = "Fills the top quartile (0.75->1.0) as premium and the bottom quartile (0.0->0.25) as discount — the prior-range extremes where reactions cluster.")
color  premColorInp  = input.color(color.new(#2600ff, 88),      "Premium Fill",  group = GRP_ZONE)
color  discColorInp  = input.color(color.new(#ff004c, 88),      "Discount Fill", group = GRP_ZONE)

// Labels (shared)
int    lineExtendInp = input.int(3,        "Line Extension (bars right)", minval = 0, maxval = 200, group = GRP_LABELS, tooltip = "How many bars past the current bar every level line, both zones and every name run to the right. They all end together.")
bool   showLabelsInp = input.bool(true,    "Show Labels",               group = GRP_LABELS)
string labelSizeInp  = input.string("small","Label Size", options = ["tiny", "small", "normal"], group = GRP_LABELS)

// Mitigation (PDH / PDL)
bool   showMitInp    = input.bool(true,                        "Show Mitigation Text", group = GRP_MIT)
color  mitColorInp   = input.color(color.new(color.gray, 55), "Mitigated Color",       group = GRP_MIT)

// Bias Table
bool   showTableInp  = input.bool(true, "Show Bias Table", group = GRP_TABLE)

// ============================================================
// HELPERS
// ============================================================
//@function Maps a user size string to the Pine size constant
sizeFromStr(simple string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        =>          size.small

//@function A name at the right end of its line, centred on it, with no background
//@param x   (int)    Bar index of the line's right end
//@param y   (float)  Price of the line
//@param txt (string) Text
//@param col (color)  Text colour
//@param sz  (string) Text size
//@returns (label) The label
tagRight(int x, float y, string txt, color col, string sz) =>
    label lb = label.new(x, y, txt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#FFFFFF, 100), textcolor = col, size = sz, textalign = text.align_left)
    label.set_text_font_family(lb, font.family_monospace)
    lb

//@function Maps a style string to the line.style_* constant
styleFromStr(simple string s) =>
    switch s
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        =>          line.style_solid

// ============================================================
// DAY CHANGE DETECTION (session-anchored)
// ============================================================
// Session-window candidates evaluated at global scope so their history is reliable.
bool nyMid = not na(time(timeframe.period, "0000-0001:1234567", "America/New_York"))
bool ny830 = not na(time(timeframe.period, "0830-0831:1234567", "America/New_York"))
bool ny930 = not na(time(timeframe.period, "0930-0931:1234567", "America/New_York"))

//@variable True on the first bar of a new trading day per the chosen anchor
bool isNewDay = switch anchorInp
    "NY Midnight" => nyMid and not nyMid[1]
    "8:30 NY"     => ny830 and not ny830[1]
    "9:30 NY"     => ny930 and not ny930[1]
    =>               bool(ta.change(time("D")))

// ============================================================
// DEVELOPING DAY TRACKING (one tracker feeds every level)
// ============================================================
var float devHigh     = na
var float devLow      = na
var int   devDayStart = 0

//@variable Confirmed prior-day levels (locked at rollover)
var float pdHigh     = na
var float pdLow      = na
var float pdEq       = na
var float pdQ1       = na     // 0.25 — discount boundary
var float pdQ3       = na     // 0.75 — premium boundary
var int   pdDayStart = 0

if isNewDay
    pdHigh     := devHigh
    pdLow      := devLow
    if not na(devHigh)
        float rng = devHigh - devLow
        pdEq := devLow + rng * 0.5
        pdQ1 := devLow + rng * 0.25
        pdQ3 := devLow + rng * 0.75
    pdDayStart := devDayStart
    devHigh    := high
    devLow     := low
    devDayStart:= bar_index
else
    devHigh := math.max(nz(devHigh, high), high)
    devLow  := math.min(nz(devLow, low), low)

// ============================================================
// MITIGATION FLAGS (PDH / PDL)
// ============================================================
var bool highMitigated = false
var bool lowMitigated  = false

if isNewDay
    highMitigated := false
    lowMitigated  := false

// Drawing objects — declared before mitigation so it can restyle them
var line  eqLine    = na
var line  highLine  = na
var line  lowLine   = na
var line  q1Line    = na
var line  q3Line    = na
var label eqLabel   = na
var label highLabel = na
var label lowLabel  = na
var box   premBox   = na
var box   discBox   = na

// Mitigation fires ONCE — the exact confirmed bar the sweep completes
if barstate.isconfirmed
    if not highMitigated and not na(pdHigh) and high >= pdHigh
        highMitigated := true
        if not na(highLine)
            line.set_color(highLine, mitColorInp)
            line.set_style(highLine, line.style_dotted)
        if not na(highLabel) and showMitInp
            label.set_text(highLabel,      "PDH Mitigated  " + str.tostring(pdHigh, format.mintick))
            label.set_textcolor(highLabel, mitColorInp)
    if not lowMitigated and not na(pdLow) and low <= pdLow
        lowMitigated := true
        if not na(lowLine)
            line.set_color(lowLine, mitColorInp)
            line.set_style(lowLine, line.style_dotted)
        if not na(lowLabel) and showMitInp
            label.set_text(lowLabel,      "PDL Mitigated  " + str.tostring(pdLow, format.mintick))
            label.set_textcolor(lowLabel, mitColorInp)

// ============================================================
// DRAWING — create once per day on rollover, extend cheaply otherwise
// All levels + zones share the same left edge (the day open) for a clean stacked range.
// ============================================================
if isNewDay and not na(pdEq) and pdDayStart > 0
    // wipe prior day's objects
    line.delete(eqLine), line.delete(highLine), line.delete(lowLine), line.delete(q1Line), line.delete(q3Line)
    label.delete(eqLabel), label.delete(highLabel), label.delete(lowLabel)
    box.delete(premBox), box.delete(discBox)

    string lblSz = sizeFromStr(labelSizeInp)

    // Premium / Discount extreme zones (drawn first so lines sit on top)
    if showZonesInp
        premBox := box.new(pdDayStart, pdHigh, bar_index, pdQ3, xloc = xloc.bar_index, border_color = color.new(color.gray, 100), bgcolor = premColorInp)
        discBox := box.new(pdDayStart, pdQ1,  bar_index, pdLow, xloc = xloc.bar_index, border_color = color.new(color.gray, 100), bgcolor = discColorInp)

    // Quartile lines
    if showQrtInp
        q3Line := line.new(pdDayStart, pdQ3, bar_index, pdQ3, xloc = xloc.bar_index, color = qrtColorInp, style = styleFromStr(qrtStyleInp), width = 1)
        q1Line := line.new(pdDayStart, pdQ1, bar_index, pdQ1, xloc = xloc.bar_index, color = qrtColorInp, style = styleFromStr(qrtStyleInp), width = 1)

    // PDEQ
    if showEqInp
        eqLine := line.new(pdDayStart, pdEq, bar_index, pdEq, xloc = xloc.bar_index, color = eqColorInp, style = styleFromStr(eqStyleInp), width = eqWidthInp)
        if showLabelsInp
            eqLabel := tagRight(bar_index + lineExtendInp, pdEq, "PDEQ  " + str.tostring(pdEq, format.mintick), eqColorInp, lblSz)

    // PDH
    if showHighInp
        highLine := line.new(pdDayStart, pdHigh, bar_index, pdHigh, xloc = xloc.bar_index, color = hlColorInp, width = hlWidthInp, style = line.style_solid)
        if showLabelsInp
            highLabel := tagRight(bar_index + lineExtendInp, pdHigh, "PDH  " + str.tostring(pdHigh, format.mintick), hlColorInp, lblSz)

    // PDL
    if showLowInp
        lowLine := line.new(pdDayStart, pdLow, bar_index, pdLow, xloc = xloc.bar_index, color = hlColorInp, width = hlWidthInp, style = line.style_solid)
        if showLabelsInp
            lowLabel := tagRight(bar_index + lineExtendInp, pdLow, "PDL  " + str.tostring(pdLow, format.mintick), hlColorInp, lblSz)

// Extend right edges + reposition labels every bar — lightweight setters only
// Every line and both zones end at one x, lineExtendInp bars past the current bar, and every
// name sits at that same x, centred on its line.
int lineEndX  = bar_index + lineExtendInp
if not na(eqLine)
    line.set_x2(eqLine, lineEndX)
if not na(highLine)
    line.set_x2(highLine, lineEndX)
if not na(lowLine)
    line.set_x2(lowLine, lineEndX)
if not na(q1Line)
    line.set_x2(q1Line, lineEndX)
if not na(q3Line)
    line.set_x2(q3Line, lineEndX)
if not na(premBox)
    box.set_right(premBox, lineEndX)
if not na(discBox)
    box.set_right(discBox, lineEndX)
if not na(eqLabel)
    label.set_x(eqLabel, lineEndX)
if not na(highLabel)
    label.set_x(highLabel, lineEndX)
if not na(lowLabel)
    label.set_x(lowLabel, lineEndX)

// ============================================================
// BIAS TABLE — where price sits in the prior-day dealing range
// ============================================================
var table biasTable = table.new(position.top_right, 1, 3, bgcolor = color.new(#ffffff, 100), border_color = color.new(#000000, 0), border_width = 1)

if barstate.islast and showTableInp and not na(pdEq)
    float rng = pdHigh - pdLow
    float pos = rng > 0 ? (close - pdLow) / rng : na
    bool  aboveEq = close > pdEq
    color biasCol = aboveEq ? COL_ABOVE : COL_BELOW
    string zoneTxt = na(pos) ? "—" : pos >= 0.75 ? "Premium ▲▲ (extreme)" : pos >= 0.5 ? "Premium ▲" : pos >= 0.25 ? "Discount ▼" : "Discount ▼▼ (extreme)"
    table.cell(biasTable, 0, 0, "PDEQ  " + str.tostring(pdEq, format.mintick), text_color = color.rgb(0, 0, 0), text_size = size.small, text_font_family = font.family_monospace)
    table.cell(biasTable, 0, 1, zoneTxt, text_color = biasCol, text_size = size.small, text_font_family = font.family_monospace)
    table.cell(biasTable, 0, 2, na(pos) ? "" : "Range pos: " + str.tostring(pos * 100, "#.0") + "%", text_color = color.rgb(0, 0, 0), text_size = size.small, text_font_family = font.family_monospace)

// ============================================================
// ALERTS
// ============================================================
// The crosses run on every bar so their history stays whole; the gates come after.
bool xEqUp          = ta.crossover(close, pdEq)
bool xEqDn          = ta.crossunder(close, pdEq)
bool xQ3Up          = ta.crossover(close, pdQ3)
bool xQ1Dn          = ta.crossunder(close, pdQ1)
bool pdEqCrossAbove = barstate.isconfirmed and not na(pdEq) and xEqUp
bool pdEqCrossBelow = barstate.isconfirmed and not na(pdEq) and xEqDn
bool enterPremium   = barstate.isconfirmed and not na(pdQ3) and xQ3Up
bool enterDiscount  = barstate.isconfirmed and not na(pdQ1) and xQ1Dn
bool pdhJustSwept   = highMitigated and not highMitigated[1]
bool pdlJustSwept   = lowMitigated  and not lowMitigated[1]

alertcondition(pdEqCrossAbove, "Cross Above PDEQ",   "Price crossed above PDEQ on {{ticker}} @ {{close}}")
alertcondition(pdEqCrossBelow, "Cross Below PDEQ",   "Price crossed below PDEQ on {{ticker}} @ {{close}}")
alertcondition(enterPremium,   "Enter Premium Zone", "Price entered prior-day premium extreme on {{ticker}} @ {{close}}")
alertcondition(enterDiscount,  "Enter Discount Zone","Price entered prior-day discount extreme on {{ticker}} @ {{close}}")
alertcondition(pdhJustSwept,   "PDH Swept",          "PDH swept on {{ticker}} @ {{close}}")
alertcondition(pdlJustSwept,   "PDL Swept",          "PDL swept on {{ticker}} @ {{close}}")

// Buffer for time-based day detection on historical bars
max_bars_back(time, 2000)
````
