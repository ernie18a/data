# Temporal Bias Architect [JOAT]

- url: https://www.tradingview.com/script/P5OESaPl-Temporal-Bias-Architect-JOAT/
- type: indicator
- pine_id: PUB;8cc394d6f62d4175bb8399734d1e6eb0
- version: 1.0

## Description

[b]Temporal Bias Architect [JOAT][/b]

[b]Introduction[/b]

Temporal Bias Architect is an open-source time-structure indicator that maps price action onto three nested cycle frameworks simultaneously: weekly, daily, and 90-minute. Each framework divides its period into four sequential phases — Accumulation (A), Manipulation (M), Distribution (D), and Continuation/Reversal (X) — derived from Daye Quarterly Theory. These phases correspond to observable behavioral patterns at each time level: accumulation of position, engineered moves against the dominant bias, distribution of that position, and the resulting continuation or reversal.

The resonance score adds a second analytical layer: when all three timeframe levels are in the same phase simultaneously, the market context is most aligned and the behavioral pattern is most likely to produce a tradeable move.

[b]Core Concepts[/b]

[b]1. Quarterly Theory Phase Mapping[/b]

Each trading week is divided into four days (Monday through Thursday). Each trading day is divided into four six-hour blocks. Each six-hour block is divided into four 90-minute segments. The indicator assigns each division the same four-phase labels in order (A, M, D, X), creating a fractal structure where the same behavioral sequence repeats at every time scale.

The phase for each level is derived directly from time to ensure accuracy:

[pine]
int dIdx = math.min(3, hour / 6)      // daily 6H phase
int qIdx = math.min(3, int((hour % 6) * 60 + minute) / 90)  // 90-min phase
[/pine]

Each phase is rendered as a color-coded box at its corresponding price row in the indicator pane.

[b]2. Three-Row Visual Layout[/b]

The indicator displays three horizontal rows of phase boxes: Weekly (top), Daily (middle), and 90-Minute (bottom). Each row is independently togglable. The boxes are sized proportionally and colored using configurable per-phase colors. Phase labels (A, M, D, X) are centered within each box.

[image]https://www.tradingview.com/x/hSJ1XI0r/[/image]

[b]3. Resonance Scoring[/b]

When two or more timeframe levels are in the same phase simultaneously, the resonance score increments. Score of 3/3 means weekly, daily, and 90-minute phases all show the same letter — a maximum alignment event. The background shading activates at 3/3 alignment to flag the condition visually.

[b]4. Fibonacci Time Zone Projection[/b]

From the start of each new trading day, the indicator projects Fibonacci time ratios (1.0, 1.272, 1.618, 2.0, 2.618) forward using a configurable time unit (90-minute, daily 6H block, or full day). These projections appear as vertical dotted lines with ratio labels. They mark the temporal points where price structure has historically been more likely to change character.

[b]5. Historical Phase Visibility[/b]

A toggle controls whether prior days' boxes remain visible or are hidden as each new period begins. With history enabled, the full phase map is visible across the visible chart range, providing context for how phases have sequenced in the past.

[b]Features[/b]

[list]
[*][b]Three-level phase mapping:[/b] Weekly, daily, and 90-minute Quarterly Theory phases displayed simultaneously
[*][b]Configurable phase colors:[/b] Accumulation, Manipulation, Distribution, and X colors independently adjustable
[*][b]Resonance score (1-3):[/b] Counts how many timeframe levels are in the same phase
[*][b]3/3 alignment background:[/b] Gold background tint when all three levels align
[*][b]Fibonacci time zone projection:[/b] Five Fibonacci ratios projected forward from session open
[*][b]Configurable Fib time unit:[/b] 90-min, 6H, or daily unit for projection scaling
[*][b]Historical phase boxes:[/b] Toggle to show or hide prior periods' phase mapping
[*][b]Row labels:[/b] Left-edge labels identifying each horizontal row
[*][b]Dashboard:[/b] Current weekly, daily, and 90-min phase, resonance score, and Fib time unit
[*][b]Three alerts:[/b] Full resonance (3/3), new daily quarter, new weekly quarter
[/list]

[b]Input Parameters[/b]

[b]General:[/b]
[list]
[*]Show Historical Quarters: Toggle past period box visibility (default: false)
[*]Auto-Detect Border Color: Adapts box border to chart background luminosity
[/list]

[b]Quarterly Cycles:[/b]
[list]
[*]Show Weekly / Daily / 90-Min toggles
[*]Show Phase Labels toggle
[*]Label Size: Tiny, Small, Normal, or Large
[*]Per-phase color inputs (A, M, D, X)
[/list]

[b]Fibonacci Time Zones:[/b]
[list]
[*]Show Fibonacci Time Zones toggle
[*]Fib Time Source: 0 = 90-min unit, 1 = daily 6H unit, 2 = weekly day unit
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Current Phase at Each Level[/b]
Check the dashboard rows for weekly, daily, and 90-minute phase. Each phase has a behavioral implication in Quarterly Theory: A = ranging accumulation, M = engineered spike against the prior move, D = directional distribution, X = reversal or continuation.

[b]Step 2: Use the Resonance Score[/b]
A 3/3 resonance reading means all three time levels are in the same phase. The background shading triggers at this condition. Cross-timeframe alignment amplifies the behavioral tendency associated with that phase.

[b]Step 3: Watch Fibonacci Time Projections[/b]
Fibonacci time ratios project when structural turning points may occur based on elapsed session time. Price approaching a projected Fib line while also in a key phase provides temporal context for setup timing.

[b]Indicator Limitations[/b]

[list]
[*]Quarterly Theory describes observed behavioral tendencies, not mechanical guarantees — the same phase can produce different outcomes depending on higher-timeframe context
[*]Fibonacci time projections are probabilistic reference zones, not precise reversal targets
[*]The three-level phase structure works best on liquid instruments during regular trading hours; crypto markets with no session boundaries produce less distinct phase behavior
[/list]

[b]Originality Statement[/b]

The simultaneous three-level Quarterly Theory phase renderer with a resonance scoring system and Fibonacci time zone projection in a single Pine Script v6 publication is the original contribution. The resonance score — quantifying cross-timeframe phase alignment from 1 to 3 — adds an analytical layer not present in standalone ADMX or ICT quarterly theory tools.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Quarterly Theory phase labels are observational frameworks and do not predict price direction. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Temporal Bias Architect [JOAT]", shorttitle="TBA [JOAT]", overlay=false,
     max_boxes_count=500, max_lines_count=200, max_labels_count=200)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM (Daye ADMX + Fib Time Palette)
// ═══════════════════════════════════════════════════════════════════════════════
color C_ACCUM   = color.rgb(120, 123, 134)
color C_MANIP   = color.rgb(255,  82,  82)
color C_DISTRIB = color.rgb( 76, 175,  80)
color C_REVERSAL= color.rgb( 41,  98, 255)
color C_FIB_1   = color.rgb(148,   0, 211)
color C_FIB_2   = color.rgb(138,  43, 226)
color NO_COLOR  = color.new(color.white, 100)
color VOID_BG   = color.rgb(10,   14,  26)
color SLATE_BRD = color.rgb(40,   55,  90)
color LAVEN_HDR = color.rgb(140, 160, 210)
color GOLD_VAL  = color.rgb(255, 215,  60)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_GEN  = "━━ General Settings ━━"
string G_CYC  = "━━ Quarterly Cycles ━━"
string G_FIB  = "━━ Fibonacci Time Zones ━━"
string G_VIZ  = "━━ Visual ━━"

bool   i_history   = input.bool(false, "Show Historical Quarters",  group=G_GEN)
bool   i_autoBdr   = input.bool(true,  "Auto-Detect Border Color",  group=G_GEN)
color  i_bdrCol    = input.color(color.white, "Manual Border Color", group=G_GEN)

bool   i_showW     = input.bool(true,  "Show Weekly Quarters",      group=G_CYC)
bool   i_showD     = input.bool(true,  "Show Daily Quarters",       group=G_CYC)
bool   i_showQ     = input.bool(true,  "Show 90-Min Quarters",      group=G_CYC)
bool   i_showLbls  = input.bool(true,  "Show Phase Labels",         group=G_CYC)
string i_lblSize   = input.string("Tiny","Label Size", options=["Tiny","Small","Normal","Large"], group=G_CYC)
color  i_cA        = input.color(color.new(#787b86, 85), "Accumulation (A)", group=G_CYC)
color  i_cM        = input.color(color.new(#ff5252, 85), "Manipulation (M)", group=G_CYC)
color  i_cD        = input.color(color.new(#4caf50, 85), "Distribution (D)", group=G_CYC)
color  i_cX        = input.color(color.new(#2962ff, 85), "Reversal/Cont (X)",group=G_CYC)

bool   i_showFib   = input.bool(true,  "Show Fibonacci Time Zones", group=G_FIB,
     tooltip="Projects Fibonacci time ratios forward from each quarter boundary.")
int    i_fibTfSel  = input.int(1, "Fib Time Source: 0=90m,1=Daily,2=Weekly", minval=0, maxval=2, group=G_FIB)

bool   i_showDash  = input.bool(true,  "Show Dashboard",            group=G_VIZ)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — CONSTANTS & UTILITIES
// ═══════════════════════════════════════════════════════════════════════════════
int MS_DAY  = 86400000
int MS_H6   = 21600000
int MS_Q90  = 5400000

bool newWeek = timeframe.change("W")
bool newDay  = timeframe.change("D")

getLblSize() =>
    switch i_lblSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.tiny

borderColor() =>
    i_autoBdr ?
         (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) +
          0.114 * color.b(chart.bg_color) < 128 ? color.new(color.white, 0) : color.new(color.black, 0)) :
         i_bdrCol

quarterColor(int idx) =>
    switch idx
        0 => i_cA
        1 => i_cM
        2 => i_cD
        => i_cX

quarterLabel(int idx) =>
    switch idx
        0 => "A"
        1 => "M"
        2 => "D"
        => "X"

hideBoxArr(box[] arr) =>
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            b = array.get(arr, i)
            box.set_bgcolor      (b, NO_COLOR)
            box.set_border_color (b, NO_COLOR)
            box.set_text_color   (b, NO_COLOR)

newBox(int t1, int t2, float top, float bot, int idx) =>
    color bdr = borderColor()
    box.new(t1, top, t2, bot, xloc=xloc.bar_time,
         border_color=bdr, bgcolor=quarterColor(idx), border_width=1,
         text=i_showLbls ? quarterLabel(idx) : "",
         text_color=bdr, text_size=getLblSize(),
         text_halign=text.align_center, text_valign=text.align_center)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — BOX STATE
// ═══════════════════════════════════════════════════════════════════════════════
var box[] wBoxes    = array.new_box()
var box[] dBoxes    = array.new_box()
var box[] qBoxes    = array.new_box()
var box[] allQBoxes = array.new_box()
var int   lastH6    = -1

var line[] fibLines  = array.new_line()
var label[] fibLabels= array.new_label()

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — QUARTERLY LOGIC
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.isfirst
    lastH6 := -1

if newWeek and i_showW
    if not i_history
        hideBoxArr(wBoxes)
    wBoxes := array.new_box()
    for i = 0 to 3
        int t1 = time + i * MS_DAY
        int t2 = time + (i + 1) * MS_DAY
        box b  = newBox(t1, t2, -4.0, -6.0, i)
        array.push(wBoxes, b)

if newDay
    if i_showD
        if not i_history
            hideBoxArr(dBoxes)
        dBoxes := array.new_box()
        for i = 0 to 3
            int t1 = time + i * MS_H6
            int t2 = time + (i + 1) * MS_H6
            box b  = newBox(t1, t2, -2.0, -4.0, i)
            array.push(dBoxes, b)

    if i_showQ
        if not i_history
            hideBoxArr(allQBoxes)
        allQBoxes := array.new_box()
        for h = 0 to 3
            int h6Start = time + h * MS_H6
            for q = 0 to 3
                int t1 = h6Start + q * MS_Q90
                int t2 = t1 + MS_Q90
                box b  = box.new(t1, 0.0, t2, -2.0, xloc=xloc.bar_time,
                     border_color=NO_COLOR, bgcolor=NO_COLOR, border_width=1,
                     text_size=getLblSize())
                array.push(allQBoxes, b)
        lastH6 := -1

// Determine current 90-min block
currentH6 = -1
if allQBoxes.size() == 16
    for h = 0 to 3
        int idx = h * 4
        if idx + 3 < allQBoxes.size()
            int leftT  = box.get_left(array.get(allQBoxes, idx))
            int rightT = box.get_right(array.get(allQBoxes, idx + 3))
            if time >= leftT and time < rightT
                currentH6 := h

if i_showQ and currentH6 != lastH6 and currentH6 != -1
    if not i_history
        hideBoxArr(qBoxes)
    qBoxes := array.new_box()
    int blockStart = currentH6 * 4
    color bdr      = borderColor()
    if allQBoxes.size() >= blockStart + 4
        for i = 0 to 3
            box b = array.get(allQBoxes, blockStart + i)
            box.set_bgcolor      (b, quarterColor(i))
            box.set_border_color (b, bdr)
            box.set_text         (b, i_showLbls ? quarterLabel(i) : "")
            box.set_text_color   (b, bdr)
            box.set_text_size    (b, getLblSize())
            array.push(qBoxes, b)
    lastH6 := currentH6

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — FIBONACCI TIME ZONE PROJECTION
// ═══════════════════════════════════════════════════════════════════════════════
float[] fibRatios = array.from(1.0, 1.272, 1.618, 2.0, 2.618)

if i_showFib and newDay
    // Clean old fib lines/labels
    for fl in fibLines
        line.delete(fl)
    fibLines.clear()
    for fl in fibLabels
        label.delete(fl)
    fibLabels.clear()

    // Project from current day start using selected TF unit
    int unitMs = i_fibTfSel == 0 ? MS_Q90 : i_fibTfSel == 1 ? MS_H6 : MS_DAY
    int baseT  = time  // current bar time = start of new day

    for r = 0 to fibRatios.size() - 1
        float ratio = array.get(fibRatios, r)
        int   projT = baseT + int(float(unitMs) * ratio)
        string lblTxt = str.tostring(ratio, "#.###")
        color  lCol   = r < 2 ? C_FIB_1 : C_FIB_2

        line fl = line.new(projT, 0.0, projT, -7.0, xloc=xloc.bar_time,
             color=color.new(lCol, 30), width=1, style=line.style_dotted)
        label ll = label.new(projT, -0.2, lblTxt, xloc=xloc.bar_time, yloc=yloc.price,
             color=NO_COLOR, textcolor=lCol, style=label.style_label_down, size=size.tiny)
        array.push(fibLines,  fl)
        array.push(fibLabels, ll)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — RESONANCE SCORE (how many TF levels align)
// ═══════════════════════════════════════════════════════════════════════════════
// Derive current phase from time — box.get_text() does not exist in Pine v6
// Weekly: Mon(dayofweek=2)=A, Tue=M, Wed=D, Thu+=X
int    wIdx      = math.min(3, math.max(0, dayofweek - 2))
// Daily: 00-06=A, 06-12=M, 12-18=D, 18-24=X
int    dIdx      = math.min(3, hour / 6)
// 90-min within current 6H block
int    qIdx      = math.min(3, int((hour % 6) * 60 + minute) / 90)
string curWPhase = quarterLabel(wIdx)
string curDPhase = quarterLabel(dIdx)
string curQPhase = quarterLabel(qIdx)

int resonance = 0
if curWPhase == curDPhase and curWPhase != ""
    resonance += 1
if curDPhase == curQPhase and curDPhase != ""
    resonance += 1
if curWPhase == curQPhase and curWPhase != ""
    resonance += 1

// Phase heat — subtle background when all 3 align
bgcolor(resonance == 3 ? color.new(GOLD_VAL, 96) : na, title="Full Phase Resonance")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — ROW LABELS
// ═══════════════════════════════════════════════════════════════════════════════
var label rowQ = na
var label rowD = na
var label rowW = na

if barstate.isfirst
    rowQ := label.new(chart.left_visible_bar_time, -1.0, i_showQ ? "90-Minute" : "",
         xloc=xloc.bar_time, style=label.style_label_left, color=NO_COLOR,
         textcolor=borderColor(), size=size.tiny)
    rowD := label.new(chart.left_visible_bar_time, -3.0, i_showD ? "Daily" : "",
         xloc=xloc.bar_time, style=label.style_label_left, color=NO_COLOR,
         textcolor=borderColor(), size=size.tiny)
    rowW := label.new(chart.left_visible_bar_time, -5.0, i_showW ? "Weekly" : "",
         xloc=xloc.bar_time, style=label.style_label_left, color=NO_COLOR,
         textcolor=borderColor(), size=size.tiny)

if time == chart.left_visible_bar_time
    label.set_x(rowQ, chart.left_visible_bar_time)
    label.set_x(rowD, chart.left_visible_bar_time)
    label.set_x(rowW, chart.left_visible_bar_time)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 6,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if i_showDash and barstate.islast
    string resStr = resonance == 3 ? "FULL (3/3)" : resonance == 2 ? "PARTIAL (2/3)" : resonance <= 1 ? str.tostring(resonance) + "/3" : "—"
    color  resCol = resonance == 3 ? GOLD_VAL : resonance == 2 ? color.new(GOLD_VAL, 40) : LAVEN_HDR

    table.cell(dash, 0, 0, "Temporal Bias Architect", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Weekly Phase",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    color  wCol   = curWPhase == "A" ? i_cA : curWPhase == "M" ? i_cM : curWPhase == "D" ? i_cD : i_cX
    string wLabel = curWPhase == "A" ? "Accumulation" : curWPhase == "M" ? "Manipulation" : curWPhase == "D" ? "Distribution" : curWPhase == "X" ? "Reversal/Cont" : "—"
    table.cell(dash, 1, 1, wLabel, text_color=wCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 2, "Daily Phase",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    color  dCol   = curDPhase == "A" ? i_cA : curDPhase == "M" ? i_cM : curDPhase == "D" ? i_cD : i_cX
    string dLabel = curDPhase == "A" ? "Accumulation" : curDPhase == "M" ? "Manipulation" : curDPhase == "D" ? "Distribution" : curDPhase == "X" ? "Reversal/Cont" : "—"
    table.cell(dash, 1, 2, dLabel, text_color=dCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 3, "90-Min Phase",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    color  qCol   = curQPhase == "A" ? i_cA : curQPhase == "M" ? i_cM : curQPhase == "D" ? i_cD : i_cX
    string qLabel = curQPhase == "A" ? "Accumulation" : curQPhase == "M" ? "Manipulation" : curQPhase == "D" ? "Distribution" : curQPhase == "X" ? "Reversal/Cont" : "—"
    table.cell(dash, 1, 3, qLabel, text_color=qCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 4, "Resonance",      text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, resStr,           text_color=resCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 5, "Fib TF Unit",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    string fibTfStr = i_fibTfSel == 0 ? "90-Minute" : i_fibTfSel == 1 ? "Daily (6H)" : "Weekly (Day)"
    table.cell(dash, 1, 5, fibTfStr,         text_color=GOLD_VAL,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(resonance == 3, "TBA Full Resonance",
     "Temporal Bias Architect [JOAT]: All 3 timeframes in same phase on {{ticker}}")
alertcondition(newDay, "TBA New Day Quarter",
     "Temporal Bias Architect [JOAT]: New daily quarter cycle beginning on {{ticker}}")
alertcondition(newWeek, "TBA New Week Quarter",
     "Temporal Bias Architect [JOAT]: New weekly quarter cycle beginning on {{ticker}}")
````
