# Post-Breakout Risk Ladder [AGPro Series]

- url: https://www.tradingview.com/script/PVGhWeG3-Post-Breakout-Risk-Ladder-AGPro-Series/
- type: indicator
- pine_id: PUB;d8c3ddb491734ac2b690ee2f286c5e67
- version: 3.0

## Description

Post-Breakout Risk Ladder [AGPro Series]

🧠 Core Idea

After a breakout happens, is the move still offering clean target room or is pullback risk taking control?


📌 Overview / What it does

Post-Breakout Risk Ladder [AGPro Series] maps a breakout base, locks the breakout edge, and converts the post-breakout move into a structured R-based risk ladder.

The script displays a breakout base, pullback risk shelf, entry rail, invalidation rail, 1R / 2R / 3R target rails, target defense labels, pullback test labels, and a compact AG Pro dashboard.

It does not predict that a breakout will continue. It helps organize what happens after a breakout: current R, pullback risk, target room, invalidation, and action state.


🎯 Purpose & Design Philosophy

Many breakout tools focus only on the breakout candle.

This script was built for the part that comes next: the risk management phase after the breakout is already visible.

It helps traders read whether the breakout is still structured, whether the pullback is healthy, whether the next target has room, and whether the breakout context has failed.


⚡ Why This Script Is Different

Most breakout indicators highlight the break itself.

This script does NOT treat the breakout as the end of the analysis.

Instead, it builds a post-breakout planning map with a base, entry reference, invalidation shelf, R ladder, pullback risk score, target room, and target defense context.


⚙️ Methodology

1. Breakout Base Detection

The script defines a recent base using completed bars and checks whether price closes beyond the base edge with enough displacement quality.

2. Breakout Lock

When the breakout qualifies, the script locks the base high/low, breakout edge, entry reference, and invalidation edge.

3. Risk Ladder Mapping

Risk is standardized into R units from the breakout entry to invalidation. Target rails are projected as 1R, 2R, and 3R references.

4. Pullback and Defense Evaluation

The script tracks pullback tests into the breakout shelf, current R, target room, and target defense behavior.


🗺️ How to Read the Chart

The breakout base shows the structure that price broke from.

The pullback shelf marks the zone where a retest may remain constructive or become risky.

The entry rail and invalidation rail define the R unit.

The 1R, 2R, and 3R rails show post-breakout target references.

Labels highlight breakout locks, pullback tests, target defense, and invalidation.

The panel summarizes:
• Breakout state
• Current R
• Pullback risk
• Target room
• Action state


🚦 Signals & States

• Bull Breakout → price closed above the breakout base with acceptable quality

• Bear Breakout → price closed below the breakout base with acceptable quality

• Pullback Test → price is testing the post-breakout shelf

• Target Defense → price has reached or interacted with an R target rail

• Invalidated → price lost the active breakout structure

• Expired → the breakout ladder is too old to remain active


🔔 Alerts Logic

Alerts can trigger when a breakout ladder is locked, when the breakout context is READY, when price tests the pullback shelf, when the ladder invalidates, or when target defense appears.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The breakout context becomes stronger when base quality, breakout body strength, relative volume, pullback shelf behavior, and target room align.

The R ladder helps separate structured continuation from late or overextended movement.


📊 When to Use

• After clear range breaks

• During breakout retests

• In trending markets with continuation attempts

• When evaluating post-breakout risk-to-room structure

• On liquid symbols with readable candles and volume


⚠️ When NOT to Use

• Very low-liquidity markets

• Extremely noisy sideways ranges

• Random spike candles without structure

• News candles with unstable spreads

• When no meaningful base exists before the breakout


🎛️ Key Inputs

• Base Lookback Bars → controls how the breakout base is detected

• Break Buffer ATR → controls how far beyond the base price must close

• Minimum Break Body Ratio → filters weak wick-only breaks

• Minimum Relative Volume → filters low-participation breaks

• Retest Shelf ATR → controls the pullback shelf around the broken edge

• Invalidation Buffer ATR → controls where the ladder fails

• Target R Settings → control the 1R / 2R / 3R ladder rails


🖥️ Interface & Visual Design

The visual hierarchy is designed around post-breakout planning.

The base defines context, the shelf defines pullback risk, the rails define R structure, and the panel provides a quick state read.

The goal is to keep the chart useful, structured, and premium without turning it into a cluttered signal board.


🧪 Practical Usage Workflow

1. Check whether a breakout ladder is active

2. Read current R in the panel

3. Inspect the pullback shelf

4. Compare target room with pullback risk

5. Watch invalidation and target defense labels


🔍 Interpretation Guidelines

A READY state means the breakout ladder has enough structure to monitor.

Current R helps measure how far price has moved from the breakout reference.

Pullback risk helps evaluate whether price is still respecting the breakout shelf.

Target room helps avoid treating late moves the same as early moves.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a guaranteed breakout system.

It is not an automated trading tool.

It does not provide financial advice.

It does not guarantee continuation, reversal, targets, or profit.


⚠️ Limitations & Transparency

Breakout quality depends on market structure, volatility, liquidity, and timeframe.

Some breakouts may fail quickly.

Some slow breakouts may not trigger if candle quality or volume is too weak.

R levels are planning references, not guaranteed destinations.


🧠 Market Context Notes

Breakouts are often strongest when structure, participation, and follow-through align.

A breakout with clean target room and controlled pullback risk is different from a late breakout already pressing into extension.

Use the ladder as context, not certainty.


🧾 Use Case Examples

When price breaks above a recent base, the script locks the breakout edge and projects 1R / 2R / 3R references.

If price later pulls back into the shelf, the script marks pullback risk so the user can evaluate whether the structure remains intact.

If price reaches a target rail, target defense labels help identify where the move may need confirmation.


🧱 System Philosophy

AGPro Series tools are built as decision-support engines.

The purpose is to organize market behavior into structure, score, state, and risk context rather than providing blind buy or sell calls.


🔐 Non-Promise Statement

No breakout is certain.

No target rail is guaranteed.

No script can remove risk.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, decisions, risk management, and execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use this tool to study how breakout bases, retests, invalidation, current R, and target room interact across different markets and timeframes.

## Source Code

````pine
// -------------------------------------------------
// Post-Breakout Risk Ladder [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.2
//
// Post-Breakout Risk Ladder maps a breakout base, converts the post-breakout
// move into a structured R ladder, and evaluates pullback risk, target room,
// target defense, invalidation context, and a stop-aware 1R Hit Rate. It is
// designed for breakout retest, continuation risk, price action, support
// resistance, and risk-reward planning.
// -------------------------------------------------

//@version=6
indicator("Post-Breakout Risk Ladder [AGPro Series]",
     shorttitle = "AG Pro PBR",
     overlay = true,
     max_boxes_count = 80,
     max_lines_count = 180,
     max_labels_count = 240)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)
color targetBlue    = color.rgb(59, 130, 246)
color inkDark       = color.rgb(15, 23, 42)
color inkLight      = color.rgb(245, 247, 250)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string G_BASE = "Breakout Base"
string G_RISK = "Risk Ladder"
string G_VISUAL = "Visuals"
string G_PANEL = "Panel"
string G_ALERTS = "Alerts"

int baseLookback = input.int(42, "Base Lookback Bars", minval = 10, maxval = 300, group = G_BASE, tooltip = "Number of finished bars used to define the breakout base high and low.")
int atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_BASE, tooltip = "ATR length used to normalize breakout buffers, pullback shelves, invalidation, labels, and target spacing.")
float minBaseRangeAtr = input.float(0.55, "Minimum Base Range ATR", minval = 0.10, step = 0.05, group = G_BASE, tooltip = "Minimum base height measured in ATR. Very small bases are ignored to reduce noisy breakouts.")
float maxBaseRangeAtr = input.float(5.00, "Maximum Base Range ATR", minval = 0.50, step = 0.25, group = G_BASE, tooltip = "Maximum base height measured in ATR. Very large bases are ignored because risk becomes hard to standardize.")
float breakBufferAtr = input.float(0.08, "Break Buffer ATR", minval = 0.00, step = 0.01, group = G_BASE, tooltip = "Close distance beyond the base edge required to lock a breakout.")
float minBreakBodyRatio = input.float(0.38, "Minimum Break Body Ratio", minval = 0.05, maxval = 0.95, step = 0.01, group = G_BASE, tooltip = "Minimum breakout candle body-to-range ratio required to avoid weak wick-only breaks.")
int volumeLength = input.int(24, "Relative Volume Length", minval = 5, maxval = 300, group = G_BASE, tooltip = "Lookback used to compare breakout volume against recent average volume.")
float minRelativeVolume = input.float(0.85, "Minimum Relative Volume", minval = 0.10, step = 0.05, group = G_BASE, tooltip = "Minimum relative volume required for breakout acceptance.")

int minReadyScore = input.int(64, "Minimum Ready Score", minval = 1, maxval = 100, group = G_RISK, tooltip = "Minimum 0-100 score required before the breakout ladder becomes READY.")
float retestShelfAtr = input.float(0.24, "Retest Shelf ATR", minval = 0.03, step = 0.01, group = G_RISK, tooltip = "ATR shelf around the breakout edge where pullback quality is evaluated.")
float invalidationAtr = input.float(0.18, "Invalidation Buffer ATR", minval = 0.00, step = 0.01, group = G_RISK, tooltip = "ATR buffer beyond the opposite side of the retest shelf where the breakout context invalidates.")
int maxBreakoutAge = input.int(140, "Maximum Breakout Age", minval = 10, maxval = 800, group = G_RISK, tooltip = "Maximum bars a breakout ladder can remain active before it expires.")
float targetOneR = input.float(1.0, "Target 1 R", minval = 0.25, step = 0.25, group = G_RISK, tooltip = "First R-based reference rail from the breakout entry.")
float targetTwoR = input.float(2.0, "Target 2 R", minval = 0.50, step = 0.25, group = G_RISK, tooltip = "Second R-based reference rail from the breakout entry.")
float targetThreeR = input.float(3.0, "Target 3 R", minval = 0.75, step = 0.25, group = G_RISK, tooltip = "Third R-based reference rail from the breakout entry.")
int followWindow = input.int(40, "1R Hit Window", minval = 8, maxval = 400, group = G_RISK, tooltip = "Bars allowed for a locked breakout to reach its 1R target (counts) or return to invalidation (counts as a miss) before the sample times out uncounted. Used by the 1R Hit Rate.")

bool showBaseBox = input.bool(true, "Show Breakout Base", group = G_VISUAL, tooltip = "Shows the breakout base used to define the break edge and risk context.")
bool showBaseBadge = input.bool(true, "Show Base / Shelf Badges", group = G_VISUAL, tooltip = "Shows separate centered badges for the breakout base and retest shelf without embedding text into boxes.")
bool showRetestShelf = input.bool(true, "Show Retest Shelf", group = G_VISUAL, tooltip = "Shows the pullback shelf around the broken base edge.")
bool showRiskCorridor = input.bool(true, "Show Risk Corridor", group = G_VISUAL, tooltip = "Shows the post-breakout risk corridor between entry and invalidation.")
bool showTargetRails = input.bool(true, "Show R Rails", group = G_VISUAL, tooltip = "Shows R-based target rails after a breakout is locked.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL, tooltip = "Shows breakout, retest, defense, and invalidation labels.")
bool showBreakLabels = input.bool(true, "Show Breakout Labels", group = G_VISUAL, tooltip = "Shows labels when a new breakout ladder is locked.")
bool showRetestLabels = input.bool(false, "Show Pullback Labels", group = G_VISUAL, tooltip = "Shows labels when price tests the post-breakout retest shelf. Disabled by default to reduce repeated label clusters.")
bool showDefenseLabels = input.bool(true, "Show Target Defense Labels", group = G_VISUAL, tooltip = "Shows labels when price reaches or defends target rails.")
bool showInvalidLabels = input.bool(true, "Show Invalidation Labels", group = G_VISUAL, tooltip = "Shows labels when the active breakout ladder is invalidated.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL, tooltip = "Shows compact right-side tags for entry, invalidation, and R rails.")
bool adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL, tooltip = "Shortens projection on higher timeframes so boxes and rails do not dominate the chart.")
int projectionBars = input.int(64, "Projection Bars", minval = 10, maxval = 400, group = G_VISUAL, tooltip = "Number of bars used for projected boxes, shelves, rails, and right-side tags.")
int maxEventLabels = input.int(10, "Maximum Event Labels", minval = 2, maxval = 60, group = G_VISUAL, tooltip = "Maximum historical event labels retained on the chart.")
int labelCooldownBars = input.int(16, "Label Cooldown Bars", minval = 1, maxval = 80, group = G_VISUAL, tooltip = "Minimum spacing between repeated event labels.")
float labelOffsetAtr = input.float(0.65, "Label Offset ATR", minval = 0.05, step = 0.05, group = G_VISUAL, tooltip = "ATR-based label offset so labels remain readable around candles.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL, tooltip = "Controls all chart labels, centered badges, and right-side tag font size.")
bool showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL, tooltip = "Colors bars lightly according to the active breakout state.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL, tooltip = "Shows or hides the AG Pro dashboard panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL, tooltip = "Controls dashboard location.")
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL, tooltip = "Controls dashboard theme while preserving the blue merged header row.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL, tooltip = "Controls dashboard font size.")

bool alertBreakout = input.bool(true, "Alert: Breakout Locked", group = G_ALERTS, tooltip = "Enables alerts when a new breakout ladder is locked.")
bool alertReady = input.bool(true, "Alert: Breakout Ready", group = G_ALERTS, tooltip = "Enables alerts when breakout score reaches READY conditions.")
bool alertRetest = input.bool(true, "Alert: Pullback Test", group = G_ALERTS, tooltip = "Enables alerts when price tests the retest shelf.")
bool alertInvalidated = input.bool(true, "Alert: Invalidated", group = G_ALERTS, tooltip = "Enables alerts when the active breakout ladder is invalidated.")
bool alertTargetDefense = input.bool(false, "Alert: Target Defense", group = G_ALERTS, tooltip = "Enables alerts when price reaches or defends target rails.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

// Luminance-aware text color: dark ink on light fills, light ink on dark fills.
f_text_on(color bg) =>
    float r = color.r(bg)
    float g = color.g(bg)
    float b = color.b(bg)
    float lum = 0.299 * r + 0.587 * g + 0.114 * b
    lum > 145 ? inkDark : inkLight

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(245, 247, 250) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(int row) =>
    bool evenRow = row % 2 == 0
    panelTheme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(245, 247, 250)) : panelTheme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string fontSize) =>
    color rowBg = f_row_bg(row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(), bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_price(float value) =>
    str.tostring(value, format.mintick)

f_r(float value) =>
    str.tostring(value, "#.##") + "R"

f_set_center_label(label id, int x, float y, string txt, color bg, string sizeInput) =>
    label.set_xy(id, x, y)
    label.set_text(id, txt)
    label.set_color(id, bg)
    label.set_textcolor(id, f_text_on(bg))
    label.set_size(id, f_size(sizeInput))
    label.set_style(id, label.style_label_center)
    label.set_textalign(id, text.align_center)

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
float atr = ta.atr(atrLength)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float volAvg = ta.sma(volume, volumeLength)
float rvol = volAvg > 0.0 ? volume / volAvg : 1.0
float barRange = math.max(high - low, syminfo.mintick)
float bodyRatio = math.abs(close - open) / barRange

float baseHigh = ta.highest(high[1], baseLookback)
float baseLow = ta.lowest(low[1], baseLookback)
float baseRange = baseHigh - baseLow
bool baseValid = not na(baseHigh) and not na(baseLow) and baseRange >= safeAtr * minBaseRangeAtr and baseRange <= safeAtr * maxBaseRangeAtr
float breakBuffer = safeAtr * breakBufferAtr

bool bullBreakRaw = baseValid and close > baseHigh + breakBuffer and close[1] <= baseHigh + breakBuffer
bool bearBreakRaw = baseValid and close < baseLow - breakBuffer and close[1] >= baseLow - breakBuffer
bool breakQualityOk = bodyRatio >= minBreakBodyRatio and rvol >= minRelativeVolume
bool newBreakout = (bullBreakRaw or bearBreakRaw) and breakQualityOk

// -------------------------------------------------
// Persistent state
// -------------------------------------------------
var bool hasBreakout = false
var int activeDir = 0
var int breakBar = na
var float lockedBaseHigh = na
var float lockedBaseLow = na
var float breakEdge = na
var float entryPrice = na
var float invalidationEdge = na
var float riskUnit = na
var int breakScore = na
var int lastRetestBar = na
var int lastDefenseBar = na
var int lastLabelBar = na
var bool resetAfterRender = false
var bool targetOneDone = false
var bool targetTwoDone = false
var bool targetThreeDone = false

var box baseBox = na
var box retestBox = na
var box riskBox = na
var line entryLine = na
var line invalidLine = na
var line rLine1 = na
var line rLine2 = na
var line rLine3 = na
var label baseBadge = na
var label retestBadge = na
var label entryTag = na
var label invalidTag = na
var label rTag1 = na
var label rTag2 = na
var label rTag3 = na
var array<label> eventLabels = array.new<label>()

if newBreakout
    activeDir := bullBreakRaw ? 1 : -1
    breakBar := bar_index
    lockedBaseHigh := baseHigh
    lockedBaseLow := baseLow
    breakEdge := activeDir == 1 ? baseHigh : baseLow
    entryPrice := close
    invalidationEdge := activeDir == 1 ? breakEdge - safeAtr * (retestShelfAtr + invalidationAtr) : breakEdge + safeAtr * (retestShelfAtr + invalidationAtr)
    riskUnit := math.max(math.abs(entryPrice - invalidationEdge), safeAtr * 0.25)
    float bodyScore = f_clamp(bodyRatio * 35.0, 0.0, 28.0)
    float volumeScore = f_clamp(rvol * 16.0, 0.0, 24.0)
    float expansionScore = f_clamp(math.abs(close - breakEdge) / safeAtr * 24.0, 0.0, 24.0)
    float baseScore = f_clamp((baseRange / safeAtr) * 8.0, 0.0, 14.0)
    breakScore := f_score(28.0 + bodyScore + volumeScore + expansionScore + baseScore)
    lastRetestBar := na
    lastDefenseBar := na
    targetOneDone := false
    targetTwoDone := false
    targetThreeDone := false
    hasBreakout := true
    resetAfterRender := false

int breakAge = hasBreakout ? bar_index - breakBar : na
bool expired = hasBreakout and breakAge > maxBreakoutAge
float retestTop = hasBreakout ? breakEdge + safeAtr * retestShelfAtr : na
float retestBottom = hasBreakout ? breakEdge - safeAtr * retestShelfAtr : na
bool insideRetest = hasBreakout and high >= retestBottom and low <= retestTop

if insideRetest
    lastRetestBar := bar_index

bool invalidated = hasBreakout and activeDir == 1 ? close < invalidationEdge : hasBreakout and activeDir == -1 ? close > invalidationEdge : false
float currentR = hasBreakout and riskUnit > 0.0 ? activeDir * (close - entryPrice) / riskUnit : na
float target1 = hasBreakout ? entryPrice + activeDir * riskUnit * targetOneR : na
float target2 = hasBreakout ? entryPrice + activeDir * riskUnit * targetTwoR : na
float target3 = hasBreakout ? entryPrice + activeDir * riskUnit * targetThreeR : na

bool targetOneReached = hasBreakout and activeDir == 1 ? high >= target1 : hasBreakout and activeDir == -1 ? low <= target1 : false
bool targetTwoReached = hasBreakout and activeDir == 1 ? high >= target2 : hasBreakout and activeDir == -1 ? low <= target2 : false
bool targetThreeReached = hasBreakout and activeDir == 1 ? high >= target3 : hasBreakout and activeDir == -1 ? low <= target3 : false
bool targetOneEvent = targetOneReached and not targetOneDone
bool targetTwoEvent = targetTwoReached and not targetTwoDone
bool targetThreeEvent = targetThreeReached and not targetThreeDone
bool targetDefense = targetOneEvent or targetTwoEvent or targetThreeEvent
string targetDefenseText = targetThreeEvent ? "T3 DEFENSE\n" + f_r(targetThreeR) : targetTwoEvent ? "T2 DEFENSE\n" + f_r(targetTwoR) : targetOneEvent ? "T1 DEFENSE\n" + f_r(targetOneR) : "TARGET DEFENSE"

if targetDefense
    lastDefenseBar := bar_index
    targetOneDone := targetOneDone or targetOneEvent
    targetTwoDone := targetTwoDone or targetTwoEvent
    targetThreeDone := targetThreeDone or targetThreeEvent

float roomToNext = hasBreakout ? currentR < targetOneR ? targetOneR - currentR : currentR < targetTwoR ? targetTwoR - currentR : currentR < targetThreeR ? targetThreeR - currentR : 0.0 : na
float pullbackRiskRaw = hasBreakout ? insideRetest ? 28.0 : activeDir == 1 ? f_clamp((breakEdge - close) / safeAtr * 80.0, 0.0, 100.0) : f_clamp((close - breakEdge) / safeAtr * 80.0, 0.0, 100.0) : na
int pullbackRisk = hasBreakout ? f_score(pullbackRiskRaw) : na
bool readyBreakout = hasBreakout and breakScore >= minReadyScore and not invalidated and not expired

if expired or invalidated
    resetAfterRender := true

// -------------------------------------------------
// 1R Hit Rate (stop-aware, confirmed-bar gated, resolve-then-open)
// Of past locked breakouts, how many reached the 1R target before returning to
// the script's own invalidation. Levels frozen at the lock bar. Times out
// uncounted if neither side is reached inside the window.
// -------------------------------------------------
var int hitWins = 0
var int hitTotal = 0
var bool hitPending = false
var int hitDir = 0
var float hitTarget = na
var float hitStop = na
var int hitStartBar = na

if barstate.isconfirmed
    if hitPending
        bool reachedTarget = hitDir == 1 ? high >= hitTarget : low <= hitTarget
        bool reachedStop = hitDir == 1 ? low <= hitStop : high >= hitStop
        if reachedTarget
            hitWins += 1
            hitTotal += 1
            hitPending := false
        else if reachedStop
            hitTotal += 1
            hitPending := false
        else if not na(hitStartBar) and bar_index - hitStartBar >= followWindow
            hitPending := false
    if not hitPending and newBreakout
        hitDir := activeDir
        hitTarget := target1
        hitStop := invalidationEdge
        hitStartBar := bar_index
        hitPending := true

int hitPct = hitTotal > 0 ? int(math.round(hitWins / hitTotal * 100.0)) : na
bool hitBuilding = hitTotal < 6
string followText = hitBuilding ? "Building (" + str.tostring(hitTotal) + ")" : str.tostring(hitPct) + "% (" + str.tostring(hitTotal) + ")"
color followColor = hitBuilding ? neutralColor : hitPct >= 52 ? bullColor : hitPct >= 44 ? neutralColor : bearColor

string breakoutState = hasBreakout ? activeDir == 1 ? "Bull Breakout" : "Bear Breakout" : "No Active Breakout"
string currentRText = hasBreakout ? f_r(currentR) : "n/a"
string pullbackRiskText = hasBreakout ? str.tostring(pullbackRisk) + "/100" : "n/a"
string roomText = hasBreakout ? f_r(roomToNext) : "n/a"
string scoreText = hasBreakout ? str.tostring(breakScore) + "/100  " + f_grade(breakScore) : "n/a"
string actionState = invalidated ? "INVALIDATED" : expired ? "EXPIRED" : readyBreakout ? "READY" : insideRetest ? "MONITOR" : hasBreakout ? "WAIT" : "WAIT"

// -------------------------------------------------
// Labels
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
float labelOffset = safeAtr * labelOffsetAtr
bool canPrintLabel = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars

f_push_label(label newLabel) =>
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label oldLabel = array.shift(eventLabels)
        label.delete(oldLabel)

if showEventLabels and showBreakLabels and canPrintLabel and newBreakout
    bool bullEvent = activeDir == 1
    color brkBg = color.new(bullEvent ? bullColor : bearColor, 4)
    label newLabel = label.new(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? "BULL BREAKOUT\nRisk ladder" : "BEAR BREAKOUT\nRisk ladder", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = brkBg, textcolor = f_text_on(brkBg), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showRetestLabels and canPrintLabel and insideRetest and not newBreakout
    bool bullEvent = activeDir == 1
    label newLabel = label.new(bar_index, bullEvent ? low - labelOffset : high + labelOffset, "PULLBACK TEST\nRisk " + pullbackRiskText, xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showDefenseLabels and canPrintLabel and targetDefense
    bool bullEvent = activeDir == 1
    color defBg = color.new(targetBlue, 4)
    label newLabel = label.new(bar_index, bullEvent ? high + labelOffset : low - labelOffset, targetDefenseText, xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = defBg, textcolor = f_text_on(defBg), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showInvalidLabels and canPrintLabel and invalidated
    bool bullEvent = activeDir == 1
    label newLabel = label.new(bar_index, bullEvent ? high + labelOffset : low - labelOffset, "INVALIDATED\nLost breakout base", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

// -------------------------------------------------
// Drawings
// -------------------------------------------------
int forwardBars = adaptiveProjection and not timeframe.isintraday ? math.max(24, int(math.round(projectionBars * 0.68))) : projectionBars
int rightEdge = bar_index + forwardBars
color stateColor = activeDir == 1 ? bullColor : bearColor

if hasBreakout and showBaseBox
    if na(baseBox)
        baseBox := box.new(breakBar - baseLookback, lockedBaseHigh, rightEdge, lockedBaseLow, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 95), border_color = color.new(accentColor, 54), border_width = 1)
    else
        box.set_lefttop(baseBox, breakBar - baseLookback, lockedBaseHigh)
        box.set_rightbottom(baseBox, rightEdge, lockedBaseLow)
        box.set_bgcolor(baseBox, color.new(accentColor, 95))
        box.set_border_color(baseBox, color.new(accentColor, 54))
    if showBaseBadge
        int badgeX = breakBar + int(math.round((rightEdge - breakBar) * 0.50))
        float badgeY = (lockedBaseHigh + lockedBaseLow) * 0.5
        string badgeText = activeDir == 1 ? "BREAKOUT BASE\nBULL CONTEXT" : "BREAKOUT BASE\nBEAR CONTEXT"
        if na(baseBadge)
            baseBadge := label.new(badgeX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 10), textcolor = f_text_on(accentColor), size = labelSize, textalign = text.align_center)
        else
            f_set_center_label(baseBadge, badgeX, badgeY, badgeText, color.new(accentColor, 10), labelSizeInput)
    else if not na(baseBadge)
        label.delete(baseBadge)
        baseBadge := na
else
    if not na(baseBox)
        box.delete(baseBox)
        baseBox := na
    if not na(baseBadge)
        label.delete(baseBadge)
        baseBadge := na

if hasBreakout and showRetestShelf
    if na(retestBox)
        retestBox := box.new(breakBar, retestTop, rightEdge, retestBottom, xloc = xloc.bar_index, bgcolor = color.new(neutralColor, 90), border_color = color.new(neutralColor, 28), border_width = 1)
    else
        box.set_lefttop(retestBox, breakBar, retestTop)
        box.set_rightbottom(retestBox, rightEdge, retestBottom)
        box.set_bgcolor(retestBox, color.new(neutralColor, 90))
        box.set_border_color(retestBox, color.new(neutralColor, 28))
    if showBaseBadge
        int shelfX = breakBar + int(math.round((rightEdge - breakBar) * 0.55))
        float shelfY = (retestTop + retestBottom) * 0.5
        if na(retestBadge)
            retestBadge := label.new(shelfX, shelfY, "PULLBACK\nRISK SHELF", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(neutralColor, 4), textcolor = f_text_on(neutralColor), size = labelSize, textalign = text.align_center)
        else
            f_set_center_label(retestBadge, shelfX, shelfY, "PULLBACK\nRISK SHELF", color.new(neutralColor, 4), labelSizeInput)
    else if not na(retestBadge)
        label.delete(retestBadge)
        retestBadge := na
else
    if not na(retestBox)
        box.delete(retestBox)
        retestBox := na
    if not na(retestBadge)
        label.delete(retestBadge)
        retestBadge := na

if hasBreakout and showRiskCorridor
    float riskTop = math.max(entryPrice, invalidationEdge)
    float riskBottom = math.min(entryPrice, invalidationEdge)
    if na(riskBox)
        riskBox := box.new(breakBar, riskTop, rightEdge, riskBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 93), border_color = color.new(stateColor, 46), border_width = 1)
    else
        box.set_lefttop(riskBox, breakBar, riskTop)
        box.set_rightbottom(riskBox, rightEdge, riskBottom)
        box.set_bgcolor(riskBox, color.new(stateColor, 93))
        box.set_border_color(riskBox, color.new(stateColor, 46))
else if not na(riskBox)
    box.delete(riskBox)
    riskBox := na

if hasBreakout
    if na(entryLine)
        entryLine := line.new(breakBar, entryPrice, rightEdge, entryPrice, xloc = xloc.bar_index, color = color.new(accentColor, 8), width = 1, style = line.style_dotted)
    else
        line.set_xy1(entryLine, breakBar, entryPrice)
        line.set_xy2(entryLine, rightEdge, entryPrice)
    if na(invalidLine)
        invalidLine := line.new(breakBar, invalidationEdge, rightEdge, invalidationEdge, xloc = xloc.bar_index, color = color.new(bearColor, 8), width = 1, style = line.style_dashed)
    else
        line.set_xy1(invalidLine, breakBar, invalidationEdge)
        line.set_xy2(invalidLine, rightEdge, invalidationEdge)
else
    if not na(entryLine)
        line.delete(entryLine)
        entryLine := na
    if not na(invalidLine)
        line.delete(invalidLine)
        invalidLine := na

if hasBreakout and showTargetRails
    if na(rLine1)
        rLine1 := line.new(breakBar, target1, rightEdge, target1, xloc = xloc.bar_index, color = color.new(neutralColor, 8), width = 1, style = line.style_dashed)
    else
        line.set_xy1(rLine1, breakBar, target1)
        line.set_xy2(rLine1, rightEdge, target1)
    if na(rLine2)
        rLine2 := line.new(breakBar, target2, rightEdge, target2, xloc = xloc.bar_index, color = color.new(targetBlue, 8), width = 1, style = line.style_dashed)
    else
        line.set_xy1(rLine2, breakBar, target2)
        line.set_xy2(rLine2, rightEdge, target2)
    if na(rLine3)
        rLine3 := line.new(breakBar, target3, rightEdge, target3, xloc = xloc.bar_index, color = color.new(stateColor, 18), width = 1, style = line.style_dashed)
    else
        line.set_xy1(rLine3, breakBar, target3)
        line.set_xy2(rLine3, rightEdge, target3)
else
    if not na(rLine1)
        line.delete(rLine1)
        rLine1 := na
    if not na(rLine2)
        line.delete(rLine2)
        rLine2 := na
    if not na(rLine3)
        line.delete(rLine3)
        rLine3 := na

// -------------------------------------------------
// Right-side tags
// -------------------------------------------------
f_update_tag(label tag, float y, string txt, color bg) =>
    label result = tag
    if na(result)
        result := label.new(rightEdge, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bg, textcolor = f_text_on(bg), size = labelSize)
    else
        label.set_x(result, rightEdge)
        label.set_y(result, y)
        label.set_text(result, txt)
        label.set_color(result, bg)
        label.set_textcolor(result, f_text_on(bg))
        label.set_size(result, labelSize)
    result

if hasBreakout and showRightTags
    entryTag := f_update_tag(entryTag, entryPrice, "Entry " + f_price(entryPrice), accentColor)
    invalidTag := f_update_tag(invalidTag, invalidationEdge, "Invalid " + f_price(invalidationEdge), bearColor)
    if showTargetRails
        rTag1 := f_update_tag(rTag1, target1, "1R " + f_price(target1), neutralColor)
        rTag2 := f_update_tag(rTag2, target2, "2R " + f_price(target2), targetBlue)
        rTag3 := f_update_tag(rTag3, target3, "3R " + f_price(target3), stateColor)
    // De-collision: right tags share x, so nudge them apart vertically when they crowd.
    if barstate.islast
        array<label> rt = array.new_label()
        if not na(entryTag)
            array.push(rt, entryTag)
        if not na(invalidTag)
            array.push(rt, invalidTag)
        if showTargetRails
            if not na(rTag1)
                array.push(rt, rTag1)
            if not na(rTag2)
                array.push(rt, rTag2)
            if not na(rTag3)
                array.push(rt, rTag3)
        int rn = array.size(rt)
        if rn > 1
            array<float> ry = array.new_float()
            for ri = 0 to rn - 1
                array.push(ry, label.get_y(array.get(rt, ri)))
            for a = 0 to rn - 2
                int mi = a
                for b = a + 1 to rn - 1
                    if array.get(ry, b) < array.get(ry, mi)
                        mi := b
                if mi != a
                    float ty = array.get(ry, a)
                    array.set(ry, a, array.get(ry, mi))
                    array.set(ry, mi, ty)
                    label tl = array.get(rt, a)
                    array.set(rt, a, array.get(rt, mi))
                    array.set(rt, mi, tl)
            float rGap = math.max(safeAtr * 0.55, syminfo.mintick * 20.0)
            for a = 1 to rn - 1
                float py = array.get(ry, a - 1)
                float cy = array.get(ry, a)
                if cy - py < rGap
                    float ny = py + rGap
                    array.set(ry, a, ny)
                    label.set_y(array.get(rt, a), ny)
else
    if not na(entryTag)
        label.delete(entryTag)
        entryTag := na
    if not na(invalidTag)
        label.delete(invalidTag)
        invalidTag := na
    if not na(rTag1)
        label.delete(rTag1)
        rTag1 := na
    if not na(rTag2)
        label.delete(rTag2)
        rTag2 := na
    if not na(rTag3)
        label.delete(rTag3)
        rTag3 := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
color actionColor = actionState == "READY" ? bullColor : actionState == "MONITOR" ? accentColor : actionState == "INVALIDATED" ? bearColor : actionState == "EXPIRED" ? panelBorder : neutralColor
color scoreColor = hasBreakout and activeDir == 1 ? bullColor : hasBreakout and activeDir == -1 ? bearColor : neutralColor

var table panel = table.new(f_panel_position(panelPositionInput), 2, 7, bgcolor = f_panel_bg(), border_width = 1, frame_width = 1, border_color = f_panel_border(), frame_color = f_panel_border())

if barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Post-Breakout Risk Ladder", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Breakout", breakoutState + "  " + scoreText, hasBreakout ? scoreColor : f_panel_value(), panelFontSizeInput)
        f_panel_row(panel, 2, "Current R", currentRText, hasBreakout ? scoreColor : f_panel_value(), panelFontSizeInput)
        f_panel_row(panel, 3, "Pullback Risk", pullbackRiskText, not na(pullbackRisk) and pullbackRisk >= 70 ? bearColor : f_panel_value(), panelFontSizeInput)
        f_panel_row(panel, 4, "Target Room", roomText, hasBreakout and roomToNext > 0.75 ? targetBlue : f_panel_value(), panelFontSizeInput)
        f_panel_row(panel, 5, "1R Hit Rate", followText, followColor, panelFontSizeInput)
        f_panel_row(panel, 6, "Action", actionState, actionColor, panelFontSizeInput)

color barStateColor = actionState == "READY" ? color.new(scoreColor, 72) : actionState == "MONITOR" ? color.new(accentColor, 78) : actionState == "INVALIDATED" ? color.new(bearColor, 70) : na
barcolor(showBarColors ? barStateColor : na)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertBreakout and newBreakout and activeDir == 1, "PBR Bull Breakout Locked", "Post-Breakout Risk Ladder: a bullish post-breakout risk ladder has been locked.")
alertcondition(alertBreakout and newBreakout and activeDir == -1, "PBR Bear Breakout Locked", "Post-Breakout Risk Ladder: a bearish post-breakout risk ladder has been locked.")
alertcondition(alertReady and readyBreakout and activeDir == 1, "PBR Bull Breakout Ready", "Post-Breakout Risk Ladder: bullish post-breakout context is READY.")
alertcondition(alertReady and readyBreakout and activeDir == -1, "PBR Bear Breakout Ready", "Post-Breakout Risk Ladder: bearish post-breakout context is READY.")
alertcondition(alertRetest and insideRetest, "PBR Pullback Test", "Post-Breakout Risk Ladder: price is testing the post-breakout pullback shelf.")
alertcondition(alertInvalidated and invalidated, "PBR Breakout Invalidated", "Post-Breakout Risk Ladder: the active post-breakout risk ladder has been invalidated.")
alertcondition(alertTargetDefense and targetDefense, "PBR Target Defense", "Post-Breakout Risk Ladder: price reached or defended an R target rail.")

if resetAfterRender
    hasBreakout := false
    activeDir := 0
    breakBar := na
    lockedBaseHigh := na
    lockedBaseLow := na
    breakEdge := na
    entryPrice := na
    invalidationEdge := na
    riskUnit := na
    breakScore := na
    lastRetestBar := na
    lastDefenseBar := na
    targetOneDone := false
    targetTwoDone := false
    targetThreeDone := false
    resetAfterRender := false
````
