# Breakout Base Defense Planner [AGPro Series]

- url: https://www.tradingview.com/script/z86jkih2-Breakout-Base-Defense-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;7fd14a493a9644d9819645bddfbfa49a
- version: 4.0

## Description

Breakout Base Defense Planner [AGPro Series]

🧠 Core Idea

After a breakout, is the original base being defended or is price losing control back into the base?


📌 Overview / What it does

Breakout Base Defense Planner [AGPro Series] maps the structure price broke from and tracks whether the broken base edge is being defended.

The script displays the breakout base, a projected base defense zone, defense rail, failure shelf, room reference, defense labels, pressure labels, invalidation labels, right-side tags, and a compact AG Pro dashboard.

It does not predict that a breakout will continue. It helps organize the post-breakout base context: defense score, pressure, room, failure risk, and action state.


🎯 Purpose & Design Philosophy

Many breakout tools focus on the breakout candle or the first follow-through move.

This script was built for a different question: does the original base still matter after the breakout?

It helps traders separate clean base defense from weak breaks that fall back into the structure they came from.


⚡ Why This Script Is Different

Most breakout indicators highlight breakouts or target projections.

This script does NOT build a full R ladder, position planner, or generic breakout continuation system.

Instead, it focuses on the broken base itself: the base box, defense zone, pressure behavior, failure shelf, target room reference, and clear action state.


⚙️ Methodology

1. Base Detection

The script defines a recent base using completed bars and filters it by ATR-based width.

2. Breakout Lock

When price closes beyond the base edge with enough displacement and participation, the base is locked as the active reference.

3. Defense Evaluation

The broken base edge becomes a defense zone. The script checks whether price holds, pressures, or loses that zone.

4. Visual Output

The chart receives a breakout base box, defense zone, defense rail, failure shelf, room rail, labels, right-side tags, optional bar coloring, and a dashboard panel.


🗺️ How to Read the Chart

The breakout base shows the structure price broke from.

The defense zone marks the broken edge that should act as support in bullish breaks or resistance in bearish breaks.

The failure shelf marks where the base defense context fails.

The room rail marks the nearest swing-room reference beyond the breakout direction.

Labels highlight base lock, base defended, defense pressure, room tests, and base lost events.

Colors represent context:

• Teal → bullish base defense

• Pink → bearish base defense or invalidation

• Gold → room reference or waiting context

• Indigo → pressure or monitoring context

The panel summarizes:

• Base

• Defense Score

• Pressure

• Room

• Action


🚦 Signals & States

• Bull Base Breakout → price closed above the base with acceptable quality

• Bear Base Breakout → price closed below the base with acceptable quality

• Base Defended → price tested the broken edge and closed back in the breakout direction

• Defense Pressure → price is testing the defense zone without a clean hold

• Room Test → price reached the active room reference

• Base Lost → price closed beyond the failure shelf

• READY → base defense quality is strong enough to monitor

• MONITOR → price is actively testing the base defense zone

• WAIT → no strong active context exists

• INVALIDATED → the base defense context failed

• EXPIRED → the locked base is too old to remain active


🔔 Alerts Logic

Alerts can trigger when a breakout base is locked, when the base is defended, when READY state appears, when defense pressure appears, when the room rail is reached, or when the base is lost.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The base defense context becomes stronger when the breakout base is well-sized, the breakout close has quality, the defense zone holds, participation is acceptable, and target room remains available.

When base defense and room align, the structure is cleaner. When price presses through the defense zone toward the failure shelf, the context weakens.


📊 When to Use

• After clear breakout moves

• During breakout retests

• When price returns to a broken range edge

• In trending markets where base defense matters

• On liquid symbols with readable structure and volume

• On 4h and 1D charts where base boxes remain visually clear


⚠️ When NOT to Use

• Very low-liquidity markets

• Extremely noisy sideways ranges

• Breakouts without a meaningful base

• News candles with unstable spreads

• Late moves where the base is already too far away to matter


🎛️ Key Inputs

• Base Lookback Bars → controls how the breakout base is detected

• Minimum / Maximum Base Range ATR → filters bases that are too small or too large

• Break Buffer ATR → controls how far beyond the base price must close

• Minimum Break Body Ratio → filters weak wick-only breaks

• Minimum Relative Volume → filters low-participation breaks

• Defense Zone ATR → controls the defended zone around the broken edge

• Failure Buffer ATR → controls where base defense fails

• Target Room Lookback → controls the nearest swing-room reference

• Visual settings → control boxes, rails, labels, tags, panel, and bar colors


🖥️ Interface & Visual Design

The visual design is built around the original base.

The base box provides context, the defense zone shows the key retest area, the failure shelf defines where the idea weakens, and the panel compresses the state into a quick decision-support read.

The goal is a premium, structured chart that feels like a breakout defense map, not a crowded signal board.


🧪 Practical Usage Workflow

1. Check whether a breakout base is active

2. Read the defense score and action state

3. Inspect the defense zone

4. Compare pressure with room

5. Watch the failure shelf for invalidation

6. Confirm the context with broader market structure


🔍 Interpretation Guidelines

A READY state means the base defense context has enough structure to monitor.

Defense pressure means price is testing the broken base edge and the context needs attention.

Base defended means price reacted at the edge, but it does not guarantee continuation.

Room measures available structure beyond the current price, not a promised target.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a guaranteed breakout system.

It is not an R-ladder tool.

It is not a position sizing tool.

It is not an automated trading tool.

It does not provide financial advice.

It does not guarantee continuation, reversal, profit, or a specific target.


⚠️ Limitations & Transparency

Breakout base behavior depends on market structure, volatility, liquidity, timeframe, and participation.

Some defended bases may later fail.

Some failed bases may reclaim again later.

The score is a rule-based context score, not a certainty model.


🧠 Market Context Notes

Breakout bases often become important memory zones.

When price breaks out and later defends the original edge, the structure can remain organized.

When price falls back through the edge and failure shelf, the breakout context becomes weaker.


🧾 Use Case Examples

When price breaks above a recent base, the script locks the base and projects a defense zone around the broken edge.

If price returns to the defense zone and closes back above the edge, the script can mark base defense.

If price closes through the failure shelf, the script marks the base as lost.


🧱 System Philosophy

This script follows the AGPro Series approach: turn one important market structure question into a focused decision-support map.

The focus is not prediction. The focus is base context, defense quality, pressure awareness, failure logic, and visual clarity.


🔐 Non-Promise Statement

No script can remove uncertainty from markets.

This tool does not promise accuracy, profitability, or future price movement.

Its purpose is to organize breakout base defense context so the user can interpret the chart more clearly.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly, and any analytical output can fail.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

A breakout is not complete just because price leaves a base.

The quality of the first base defense can often provide more useful context than the breakout candle alone.

## Source Code

````pine
// --------------------------------------------------
// Breakout Base Defense Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Breakout Base Defense Planner maps the original breakout base, tracks whether
// the broken edge is being defended, and organizes pressure, room, failure risk,
// and next action into a single 0-100 defense score with an empirical stop-aware
// proof rate. It is a breakout base, base defense, retest, target room, risk
// planning, and market structure decision engine for price action traders.
// --------------------------------------------------

//@version=6
indicator("Breakout Base Defense Planner [AGPro Series]",
     shorttitle = "AG Pro BBD",
     overlay = true,
     max_boxes_count = 60,
     max_lines_count = 140,
     max_labels_count = 220)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
targetBlue    = color.rgb(59, 130, 246)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_BASE = "Breakout Base"
G_DEFENSE = "Defense Logic"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

baseLookback = input.int(44, "Base Lookback Bars", minval = 10, maxval = 300, group = G_BASE, tooltip = "Number of prior bars used to define the breakout base high and low.")
atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_BASE, tooltip = "ATR length used to normalize base filters, defense zones, failure shelves, labels, room, and proof distances.")
minBaseRangeAtr = input.float(0.55, "Minimum Base Range ATR", minval = 0.10, step = 0.05, group = G_BASE, tooltip = "Minimum base height measured in ATR. Very small bases are ignored to reduce noisy breaks.")
maxBaseRangeAtr = input.float(4.50, "Maximum Base Range ATR", minval = 0.50, step = 0.25, group = G_BASE, tooltip = "Maximum base height measured in ATR. Very large bases are ignored because defense quality becomes harder to standardize.")
breakBufferAtr = input.float(0.08, "Break Buffer ATR", minval = 0.00, step = 0.01, group = G_BASE, tooltip = "ATR distance beyond the base edge required to lock a breakout.")
minBreakBodyRatio = input.float(0.34, "Minimum Break Body Ratio", minval = 0.05, maxval = 0.95, step = 0.01, group = G_BASE, tooltip = "Minimum breakout candle body-to-range ratio required to avoid weak wick-only breaks.")
volumeLength = input.int(24, "Relative Volume Length", minval = 5, maxval = 300, group = G_BASE, tooltip = "Lookback used to compare breakout and defense volume against recent average volume.")
minRelativeVolume = input.float(0.75, "Minimum Relative Volume", minval = 0.10, step = 0.05, group = G_BASE, tooltip = "Minimum relative volume required for breakout acceptance.")

minReadyScore = input.int(64, "Minimum Ready Score", minval = 1, maxval = 100, group = G_DEFENSE, tooltip = "Minimum 0-100 defense score required before the base defense context becomes READY.")
defenseZoneAtr = input.float(0.26, "Defense Zone ATR", minval = 0.03, step = 0.01, group = G_DEFENSE, tooltip = "ATR width around the broken base edge where defense behavior is evaluated.")
failureBufferAtr = input.float(0.18, "Failure Buffer ATR", minval = 0.00, step = 0.01, group = G_DEFENSE, tooltip = "ATR buffer beyond the far side of the defense zone where the breakout base is considered lost.")
roomMultiple = input.float(1.0, "Room Projection (x Base Height)", minval = 0.30, maxval = 4.00, step = 0.10, group = G_DEFENSE, tooltip = "Measured-move target room projected beyond the broken edge, expressed as a multiple of base height. The engine uses whichever is further: this projection or the nearest structure.")
targetRoomLookback = input.int(72, "Structure Room Lookback", minval = 10, maxval = 500, group = G_DEFENSE, tooltip = "Lookback used to detect a nearby structural target beyond the breakout direction. Combined with the measured-move projection.")
maxBaseAge = input.int(260, "Maximum Base Age", minval = 10, maxval = 800, group = G_DEFENSE, tooltip = "Maximum bars a breakout base can remain active before it expires.")
proofTimeout = input.int(30, "Proof Window Bars", minval = 5, maxval = 200, group = G_DEFENSE, tooltip = "Maximum bars a defense follow-through window stays open before it is left uncounted in the proof rate.")

showBaseBox = input.bool(true, "Show Breakout Base", group = G_VISUAL, tooltip = "Shows the original base that price broke from as faded historical context.")
showDefenseZone = input.bool(true, "Show Defense Zone", group = G_VISUAL, tooltip = "Shows the broken base edge as a defended zone.")
showZoneBadge = input.bool(true, "Show Centered Zone Badge", group = G_VISUAL, tooltip = "Shows a single centered badge inside the active defense zone.")
showFailureShelf = input.bool(true, "Show Failure Shelf", group = G_VISUAL, tooltip = "Shows where the base defense context fails.")
showRoomRail = input.bool(true, "Show Room Rail", group = G_VISUAL, tooltip = "Shows the projected target-room reference beyond the breakout direction.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL, tooltip = "Shows breakout, defense, pressure, ready, room, and invalidation labels on the chart.")
showBreakLabels = input.bool(true, "Show Breakout Labels", group = G_VISUAL, tooltip = "Shows labels when a new breakout base is locked.")
showDefenseLabels = input.bool(true, "Show Defense Labels", group = G_VISUAL, tooltip = "Shows labels when price tests and defends the broken base edge.")
showPressureLabels = input.bool(true, "Show Pressure Labels", group = G_VISUAL, tooltip = "Shows labels when price pressures the defense zone without a clean defense.")
showReadyLabels = input.bool(true, "Show READY Labels", group = G_VISUAL, tooltip = "Shows a filled decision badge when the active base defense context first reaches READY.")
showRoomLabels = input.bool(true, "Show Room Labels", group = G_VISUAL, tooltip = "Shows labels when price reaches the room reference.")
showInvalidLabels = input.bool(true, "Show Invalidation Labels", group = G_VISUAL, tooltip = "Shows labels when the active breakout base is lost.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL, tooltip = "Shows compact right-side tags for defense, failure, and room levels.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL, tooltip = "Colors bars lightly according to the active base defense state.")
projectionBars = input.int(84, "Projection Bars", minval = 10, maxval = 400, group = G_VISUAL, tooltip = "Number of bars used for projected boxes, rails, right-side tags, and the centered badge.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL, tooltip = "Automatically widens projections on higher timeframes so zones remain readable.")
labelCooldownBars = input.int(10, "Label Cooldown Bars", minval = 1, maxval = 80, group = G_VISUAL, tooltip = "Minimum spacing between repeated event labels.")
maxEventLabels = input.int(14, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL, tooltip = "Maximum historical event labels retained on the chart.")
labelOffsetAtr = input.float(0.72, "Label Offset ATR", minval = 0.05, step = 0.05, group = G_VISUAL, tooltip = "ATR-based label offset so labels remain readable above or below candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL, tooltip = "Controls chart labels, centered badge, and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL, tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL, tooltip = "Controls dashboard location.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL, tooltip = "Controls dashboard theme while preserving the single blue header row.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL, tooltip = "Controls dashboard font size.")

alertBreakout = input.bool(true, "Alert: Base Breakout", group = G_ALERTS, tooltip = "Enables alerts when a new breakout base is locked.")
alertDefense = input.bool(true, "Alert: Base Defended", group = G_ALERTS, tooltip = "Enables alerts when price defends the broken base edge.")
alertReady = input.bool(true, "Alert: Ready State", group = G_ALERTS, tooltip = "Enables alerts when the base defense context reaches READY conditions.")
alertPressure = input.bool(false, "Alert: Defense Pressure", group = G_ALERTS, tooltip = "Enables alerts when price presses into the defense zone without clean defense.")
alertRoom = input.bool(false, "Alert: Room Rail", group = G_ALERTS, tooltip = "Enables alerts when price reaches the target-room reference.")
alertInvalidated = input.bool(true, "Alert: Base Lost", group = G_ALERTS, tooltip = "Enables alerts when the active breakout base is lost.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

// Luminance-based contrast: dark ink on bright fills, light ink on dark fills.
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

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
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(241, 245, 249) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_alt_bg(int row) =>
    bool evenRow = row % 2 == 0
    panelTheme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : panelTheme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_price(float value) =>
    str.tostring(value, format.mintick)

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput, string alignInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput), text_halign = alignInput == "left" ? text.align_left : alignInput == "right" ? text.align_right : text.align_center)

f_push_label(array<label> labels, label newLabel, int maxLabels) =>
    array.push(labels, newLabel)
    while array.size(labels) > maxLabels
        label.delete(array.shift(labels))

// Vertical anti-collision: nudge a new label away from nearby existing labels.
// The bar window is kept wide so that labels which sit far apart in bar count
// but overlap visually on compressed or higher-timeframe charts are still caught.
f_avoid_overlap(array<label> labels, float desiredY, bool placeAbove, float safe) =>
    float y = desiredY
    float minGap = safe * 1.25
    int n = array.size(labels)
    if n > 0
        bool moved = true
        int guard = 0
        while moved and guard < 18
            moved := false
            for i = 0 to n - 1
                label lb = array.get(labels, i)
                if math.abs(label.get_x(lb) - bar_index) <= 26
                    if math.abs(label.get_y(lb) - y) < minGap
                        y := placeAbove ? y + minGap : y - minGap
                        moved := true
            guard += 1
    y

// --------------------------------------------------
// Core calculations
// --------------------------------------------------
atrSafe = math.max(nz(ta.atr(atrLength), ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0.0 ? volume / volAvg : 1.0
barRange = math.max(high - low, syminfo.mintick)
bodyRatio = math.abs(close - open) / barRange

baseHighRaw = ta.highest(high[1], baseLookback)
baseLowRaw = ta.lowest(low[1], baseLookback)
targetHighRaw = ta.highest(high[1], targetRoomLookback)
targetLowRaw = ta.lowest(low[1], targetRoomLookback)
baseRangeRaw = baseHighRaw - baseLowRaw
baseValid = not na(baseHighRaw) and not na(baseLowRaw) and baseRangeRaw >= atrSafe * minBaseRangeAtr and baseRangeRaw <= atrSafe * maxBaseRangeAtr
breakBuffer = atrSafe * breakBufferAtr

bullBreakRaw = baseValid and close > baseHighRaw + breakBuffer and close[1] <= baseHighRaw + breakBuffer
bearBreakRaw = baseValid and close < baseLowRaw - breakBuffer and close[1] >= baseLowRaw - breakBuffer
breakQualityOk = bodyRatio >= minBreakBodyRatio and rvol >= minRelativeVolume
breakoutEvent = (bullBreakRaw or bearBreakRaw) and breakQualityOk
confirmedBreakoutEvent = breakoutEvent and barstate.isconfirmed

var bool hasBase = false
var int activeDir = 0
var int baseBar = na
var float lockedBaseHigh = na
var float lockedBaseLow = na
var float defenseEdge = na
var float defenseTop = na
var float defenseBottom = na
var float failureRail = na
var float roomRail = na
var int lastPressureBar = na
var bool roomDone = false
var bool resetAfterRender = false

if confirmedBreakoutEvent
    hasBase := true
    activeDir := bullBreakRaw ? 1 : -1
    baseBar := bar_index
    lockedBaseHigh := baseHighRaw
    lockedBaseLow := baseLowRaw
    defenseEdge := activeDir == 1 ? baseHighRaw : baseLowRaw
    defenseTop := defenseEdge + atrSafe * defenseZoneAtr
    defenseBottom := defenseEdge - atrSafe * defenseZoneAtr
    failureRail := activeDir == 1 ? defenseBottom - atrSafe * failureBufferAtr : defenseTop + atrSafe * failureBufferAtr
    float lockedHeight = baseHighRaw - baseLowRaw
    float mmTarget = activeDir == 1 ? defenseEdge + lockedHeight * roomMultiple : defenseEdge - lockedHeight * roomMultiple
    float structTarget = activeDir == 1 ? targetHighRaw : targetLowRaw
    roomRail := activeDir == 1 ? math.max(mmTarget, structTarget) : math.min(mmTarget, structTarget)
    lastPressureBar := na
    roomDone := false

baseAge = hasBase and not na(baseBar) ? bar_index - baseBar : na
expired = hasBase and baseAge > maxBaseAge
insideDefense = hasBase and high >= defenseBottom and low <= defenseTop
defenseHold = (hasBase and activeDir == 1 and low <= defenseTop and close > defenseEdge and close > open) or (hasBase and activeDir == -1 and high >= defenseBottom and close < defenseEdge and close < open)
defenseEvent = barstate.isconfirmed and defenseHold and not defenseHold[1]
pressureEvent = barstate.isconfirmed and hasBase and insideDefense and not defenseHold and (na(lastPressureBar) or bar_index - lastPressureBar > labelCooldownBars)
baseLostRaw = (hasBase and activeDir == 1 and close < failureRail) or (hasBase and activeDir == -1 and close > failureRail)
baseLost = baseLostRaw and barstate.isconfirmed
roomReached = (hasBase and activeDir == 1 and high >= roomRail) or (hasBase and activeDir == -1 and low <= roomRail)
roomEvent = barstate.isconfirmed and roomReached and not roomDone

if pressureEvent
    lastPressureBar := bar_index
if roomEvent
    roomDone := true

baseHeight = hasBase ? lockedBaseHigh - lockedBaseLow : na
roomAtr = hasBase ? math.abs(roomRail - close) / atrSafe : na
pressureDistance = hasBase ? (activeDir == 1 ? (close - defenseEdge) / atrSafe : (defenseEdge - close) / atrSafe) : na

// 0-100 defense score (graded components, designed to spread, not saturate)
heightAtr = hasBase ? baseHeight / atrSafe : 0.0
baseWidthScore = hasBase ? f_clamp(16.0 - math.abs(heightAtr - 1.6) * 6.0, 0.0, 16.0) : 0.0
breakDistanceScore = hasBase ? f_clamp(math.abs(close - defenseEdge) / atrSafe * 12.0, 0.0, 16.0) : 0.0
defCloseRaw = hasBase ? (activeDir == 1 ? (close - defenseEdge) / atrSafe : (defenseEdge - close) / atrSafe) : 0.0
defenseCloseScore = hasBase ? f_clamp(10.0 + defCloseRaw * 10.0, 0.0, 20.0) : 0.0
retestScore = hasBase ? (insideDefense ? 16.0 : f_clamp(16.0 - math.abs(pressureDistance) * 5.0, 0.0, 16.0)) : 0.0
volumeScore = f_clamp((rvol - 0.5) * 12.0, 0.0, 12.0)
roomScore = hasBase ? f_clamp(roomAtr * 3.5, 0.0, 10.0) : 0.0
defenseScore = f_score(10.0 + baseWidthScore + breakDistanceScore + defenseCloseScore + retestScore + volumeScore + roomScore)

readyState = hasBase and defenseScore >= minReadyScore and not baseLost and not expired
readyEvent = barstate.isconfirmed and readyState and not readyState[1]

// --------------------------------------------------
// Stop-aware proof rate (defense follow-through, confirmed-bar gated)
// --------------------------------------------------
var int proofTotal = 0
var int proofWins = 0
var bool proofPending = false
var int proofDir = 0
var float proofTarget = na
var float proofStop = na
var int proofStartBar = na

if barstate.isconfirmed
    // Resolve any open window first
    if proofPending
        bool win = proofDir == 1 ? high >= proofTarget : low <= proofTarget
        bool los = proofDir == 1 ? low <= proofStop : high >= proofStop
        bool resolved = false
        if los and not win
            proofTotal += 1
            resolved := true
        else if win and not los
            proofWins += 1
            proofTotal += 1
            resolved := true
        else if win and los
            proofTotal += 1
            resolved := true
        if not resolved and not na(proofStartBar) and bar_index - proofStartBar >= proofTimeout
            resolved := true
        if resolved
            proofPending := false
    // Open a new window on a confirmed defense hold (resolve-then-open, single slot)
    if not proofPending and hasBase and defenseHold
        proofPending := true
        proofDir := activeDir
        proofTarget := activeDir == 1 ? close + atrSafe * 1.5 : close - atrSafe * 1.5
        proofStop := activeDir == 1 ? close - atrSafe * 1.0 : close + atrSafe * 1.0
        proofStartBar := bar_index

proofReady = proofTotal >= 6
proofRate = proofReady ? f_score(proofWins / proofTotal * 100.0) : na
proofText = proofReady ? str.tostring(proofRate) + "%  (" + str.tostring(proofTotal) + ")" : "Building (" + str.tostring(proofTotal) + ")"
proofColor = not proofReady ? neutralColor : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

// --------------------------------------------------
// State strings & colors
// --------------------------------------------------
baseState = not hasBase ? "No Active Base" : expired ? "Expired" : activeDir == 1 ? "Bull Base Defense" : "Bear Base Defense"
pressureText = not hasBase ? "n/a" : insideDefense ? "Testing Zone" : pressureDistance >= 0 ? "Holding  " + str.tostring(math.abs(pressureDistance), "#.##") + " ATR" : "Pressured  " + str.tostring(math.abs(pressureDistance), "#.##") + " ATR"
roomText = hasBase ? str.tostring(roomAtr, "#.##") + " ATR" : "n/a"
scoreText = hasBase ? str.tostring(defenseScore) + "/100  " + f_grade(defenseScore) : "n/a"
actionState = not hasBase ? "WAIT" : expired ? "EXPIRED" : baseLost ? "INVALIDATED" : readyState ? "READY" : insideDefense ? "MONITOR" : "WAIT"
stateColor = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : neutralColor
actionColor = actionState == "READY" ? stateColor : actionState == "MONITOR" ? accentColor : actionState == "INVALIDATED" ? bearColor : actionState == "EXPIRED" ? panelBorder : neutralColor
labelSize = f_size(labelSizeInput)
projectionBoost = adaptiveProjection ? (timeframe.isweekly ? 2 : timeframe.ismonthly ? 3 : 1) : 1
rightEdge = bar_index + projectionBars * projectionBoost

// --------------------------------------------------
// Visual objects
// --------------------------------------------------
var box baseBox = na
var box defenseBox = na
var line defenseLine = na
var line failLine = na
var line roomLine = na
var label defenseBadge = na

// Faded historical base box (no badge -> single active centered badge only)
if hasBase and showBaseBox and not expired
    int leftBase = math.max(0, baseBar - baseLookback)
    if na(baseBox)
        baseBox := box.new(leftBase, lockedBaseHigh, baseBar, lockedBaseLow, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 95), border_color = color.new(accentColor, 62), border_width = 1)
    else
        box.set_lefttop(baseBox, leftBase, lockedBaseHigh)
        box.set_rightbottom(baseBox, baseBar, lockedBaseLow)
        box.set_bgcolor(baseBox, color.new(accentColor, 95))
        box.set_border_color(baseBox, color.new(accentColor, 62))
else
    if not na(baseBox)
        box.delete(baseBox)
        baseBox := na

if hasBase and showDefenseZone and not expired
    int defenseMidX = baseBar + int(math.round((rightEdge - baseBar) * 0.54))
    float defenseMidY = math.avg(defenseTop, defenseBottom)
    if na(defenseBox)
        defenseBox := box.new(baseBar, defenseTop, rightEdge, defenseBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 90), border_color = color.new(stateColor, 32), border_width = 1)
    else
        box.set_lefttop(defenseBox, baseBar, defenseTop)
        box.set_rightbottom(defenseBox, rightEdge, defenseBottom)
        box.set_bgcolor(defenseBox, color.new(stateColor, 90))
        box.set_border_color(defenseBox, color.new(stateColor, 32))
    if showZoneBadge
        if na(defenseBadge)
            defenseBadge := label.new(defenseMidX, defenseMidY, "BASE DEFENSE\nZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(targetBlue, 6), textcolor = f_text_on(targetBlue), size = labelSize, textalign = text.align_center)
        else
            label.set_xy(defenseBadge, defenseMidX, defenseMidY)
            label.set_text(defenseBadge, "BASE DEFENSE\nZONE")
            label.set_color(defenseBadge, color.new(targetBlue, 6))
            label.set_textcolor(defenseBadge, f_text_on(targetBlue))
            label.set_size(defenseBadge, labelSize)
            label.set_style(defenseBadge, label.style_label_center)
    else
        if not na(defenseBadge)
            label.delete(defenseBadge)
            defenseBadge := na
else
    if not na(defenseBox)
        box.delete(defenseBox)
        defenseBox := na
    if not na(defenseBadge)
        label.delete(defenseBadge)
        defenseBadge := na

if hasBase and showDefenseZone and not expired
    if na(defenseLine)
        defenseLine := line.new(baseBar, defenseEdge, rightEdge, defenseEdge, xloc = xloc.bar_index, extend = extend.none, color = stateColor, width = 2)
    else
        line.set_xy1(defenseLine, baseBar, defenseEdge)
        line.set_xy2(defenseLine, rightEdge, defenseEdge)
        line.set_color(defenseLine, stateColor)
else
    if not na(defenseLine)
        line.delete(defenseLine)
        defenseLine := na

if hasBase and showFailureShelf and not expired
    if na(failLine)
        failLine := line.new(baseBar, failureRail, rightEdge, failureRail, xloc = xloc.bar_index, extend = extend.none, color = bearColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(failLine, baseBar, failureRail)
        line.set_xy2(failLine, rightEdge, failureRail)
        line.set_color(failLine, bearColor)
else
    if not na(failLine)
        line.delete(failLine)
        failLine := na

if hasBase and showRoomRail and not expired
    if na(roomLine)
        roomLine := line.new(baseBar, roomRail, rightEdge, roomRail, xloc = xloc.bar_index, extend = extend.none, color = neutralColor, width = 1)
    else
        line.set_xy1(roomLine, baseBar, roomRail)
        line.set_xy2(roomLine, rightEdge, roomRail)
        line.set_color(roomLine, neutralColor)
else
    if not na(roomLine)
        line.delete(roomLine)
        roomLine := na

// --------------------------------------------------
// Event labels (vertical anti-collision, on filled opaque badges)
// --------------------------------------------------
labelOffset = atrSafe * labelOffsetAtr
var int lastBreakLabelBar = na
var int lastBreakLabelDir = 0
var array<label> eventLabels = array.new<label>()
var label activeDecisionLabel = na

// One active lifecycle badge prevents PRESSURE / DEFENDED / READY / LOST states
// from stacking around the same base. Historical bases retain their final badge.
f_upsert_decision_badge(label current, bool bullEvent, bool oppositeSide, string txt, color bg) =>
    label result = current
    float baseY = oppositeSide ? (bullEvent ? high + labelOffset : low - labelOffset) : (bullEvent ? low - labelOffset : high + labelOffset)
    bool above = oppositeSide ? bullEvent : not bullEvent
    float yPos = na(result) ? f_avoid_overlap(eventLabels, baseY, above, atrSafe) : baseY
    string badgeStyle = oppositeSide ? (bullEvent ? label.style_label_down : label.style_label_up) : (bullEvent ? label.style_label_up : label.style_label_down)
    if na(result)
        result := label.new(bar_index, yPos, txt, xloc = xloc.bar_index, yloc = yloc.price, style = badgeStyle, color = bg, textcolor = f_text_on(bg), size = labelSize)
        f_push_label(eventLabels, result, maxEventLabels)
    else
        label.set_xy(result, bar_index, yPos)
        label.set_text(result, txt)
        label.set_style(result, badgeStyle)
        label.set_color(result, bg)
        label.set_textcolor(result, f_text_on(bg))
        label.set_size(result, labelSize)
    result

// Suppress same-side breakout label repeats so the chart alternates cleanly.
sameSideRepeat = not na(lastBreakLabelBar) and lastBreakLabelDir == activeDir and (bar_index - lastBreakLabelBar) < labelCooldownBars * 3
if confirmedBreakoutEvent
    activeDecisionLabel := na

if showEventLabels and showBreakLabels and confirmedBreakoutEvent and not sameSideRepeat
    bool bullEvent = activeDir == 1
    float baseY = bullEvent ? low - labelOffset : high + labelOffset
    float yPos = f_avoid_overlap(eventLabels, baseY, not bullEvent, atrSafe)
    color bg = bullEvent ? bullColor : bearColor
    label newLabel = label.new(bar_index, yPos, bullEvent ? "BULL BREAKOUT\nBase locked" : "BEAR BREAKOUT\nBase locked", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = bg, textcolor = f_text_on(bg), size = labelSize)
    f_push_label(eventLabels, newLabel, maxEventLabels)
    lastBreakLabelBar := bar_index
    lastBreakLabelDir := activeDir

if showEventLabels and showDefenseLabels and defenseEvent
    bool bullEvent = activeDir == 1
    color bg = bullEvent ? bullColor : bearColor
    activeDecisionLabel := f_upsert_decision_badge(activeDecisionLabel, bullEvent, false, bullEvent ? "BASE DEFENDED\nEdge held" : "BASE DEFENDED\nEdge rejected", bg)

if showEventLabels and showPressureLabels and pressureEvent
    bool bullEvent = activeDir == 1
    activeDecisionLabel := f_upsert_decision_badge(activeDecisionLabel, bullEvent, false, "DEFENSE PRESSURE\nTesting base", accentColor)

if showEventLabels and showReadyLabels and readyEvent
    bool bullEvent = activeDir == 1
    color bg = bullEvent ? bullColor : bearColor
    activeDecisionLabel := f_upsert_decision_badge(activeDecisionLabel, bullEvent, false, "READY  " + str.tostring(defenseScore) + "\nDefense confirmed", bg)

if showEventLabels and showRoomLabels and roomEvent
    bool bullEvent = activeDir == 1
    float baseY = bullEvent ? high + labelOffset : low - labelOffset
    float yPos = f_avoid_overlap(eventLabels, baseY, bullEvent, atrSafe)
    label newLabel = label.new(bar_index, yPos, "ROOM TEST\nReference reached", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_label(eventLabels, newLabel, maxEventLabels)

if showEventLabels and showInvalidLabels and baseLost
    bool bullEvent = activeDir == 1
    activeDecisionLabel := f_upsert_decision_badge(activeDecisionLabel, bullEvent, true, "BASE LOST\nDefense failed", bearColor)
    resetAfterRender := true

// --------------------------------------------------
// Right-side tags (fanned so defense / failure / room never overlap)
// --------------------------------------------------
var label defenseTag = na
var label failTag = na
var label roomTag = na

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

if showRightTags and hasBase and not expired
    float tagGap = atrSafe * 0.6
    float defY = defenseEdge
    float failY = failureRail
    float roomY = roomRail
    if math.abs(defY - failY) < tagGap
        float mid = math.avg(defY, failY)
        defY := defY >= failY ? mid + tagGap / 2.0 : mid - tagGap / 2.0
        failY := defY >= failY ? mid - tagGap / 2.0 : mid + tagGap / 2.0
    if math.abs(roomY - defY) < tagGap
        roomY := roomY >= defY ? defY + tagGap : defY - tagGap
    defenseTag := f_update_tag(defenseTag, defY, "Defense  " + f_price(defenseEdge), stateColor)
    failTag := f_update_tag(failTag, failY, "Base lost  " + f_price(failureRail), bearColor)
    if showRoomRail
        roomTag := f_update_tag(roomTag, roomY, "Room  " + f_price(roomRail), neutralColor)
    else
        if not na(roomTag)
            label.delete(roomTag)
            roomTag := na
else
    if not na(defenseTag)
        label.delete(defenseTag)
        defenseTag := na
    if not na(failTag)
        label.delete(failTag)
        failTag := na
    if not na(roomTag)
        label.delete(roomTag)
        roomTag := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = table.new(f_panel_position(panelPositionInput), 2, 7, border_width = 1, border_color = f_panel_border(), frame_width = 1, frame_color = f_panel_border())

if barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Breakout Base Defense Planner", f_text_on(headerBg), headerBg, panelFontSizeInput, "center")
        f_panel_cell(panel, 0, 1, "Base", f_panel_label(), f_panel_alt_bg(1), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 1, baseState, f_panel_value(), f_panel_alt_bg(1), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 2, "Defense Score", f_panel_label(), f_panel_alt_bg(2), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 2, scoreText, f_text_on(stateColor), stateColor, panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 3, "Proof", f_panel_label(), f_panel_alt_bg(3), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 3, proofText, f_text_on(proofColor), proofColor, panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 4, "Pressure", f_panel_label(), f_panel_alt_bg(4), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 4, pressureText, f_panel_value(), f_panel_alt_bg(4), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 5, "Room", f_panel_label(), f_panel_alt_bg(5), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 5, roomText, f_panel_value(), f_panel_alt_bg(5), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 6, "Action", f_panel_label(), f_panel_alt_bg(6), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 6, actionState, f_text_on(actionColor), actionColor, panelFontSizeInput, "right")

barStateColor = actionState == "READY" ? color.new(stateColor, 72) : actionState == "MONITOR" ? color.new(accentColor, 78) : actionState == "INVALIDATED" ? color.new(bearColor, 70) : na
barcolor(showBarColors ? barStateColor : na)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertBreakout and confirmedBreakoutEvent and activeDir == 1, "AG Pro BBD | BULL BASE BREAKOUT", "AG Pro BBD: A bullish breakout base has been locked on a confirmed close.")
alertcondition(alertBreakout and confirmedBreakoutEvent and activeDir == -1, "AG Pro BBD | BEAR BASE BREAKOUT", "AG Pro BBD: A bearish breakout base has been locked on a confirmed close.")
alertcondition(alertDefense and defenseEvent and activeDir == 1, "AG Pro BBD | BULL BASE DEFENDED", "AG Pro BBD: Bullish breakout base defense has been confirmed.")
alertcondition(alertDefense and defenseEvent and activeDir == -1, "AG Pro BBD | BEAR BASE DEFENDED", "AG Pro BBD: Bearish breakout base defense has been confirmed.")
alertcondition(alertReady and readyEvent and activeDir == 1, "AG Pro BBD | BULL READY", "AG Pro BBD: Bullish base defense context has entered READY.")
alertcondition(alertReady and readyEvent and activeDir == -1, "AG Pro BBD | BEAR READY", "AG Pro BBD: Bearish base defense context has entered READY.")
alertcondition(alertPressure and pressureEvent, "AG Pro BBD | DEFENSE PRESSURE", "AG Pro BBD: Price is pressuring the active base defense zone.")
alertcondition(alertRoom and roomEvent, "AG Pro BBD | ROOM RAIL", "AG Pro BBD: Price reached the active target-room reference.")
alertcondition(alertInvalidated and baseLost, "AG Pro BBD | BASE LOST", "AG Pro BBD: The active breakout base defense context has been invalidated.")

// --------------------------------------------------
// State reset (proof stats persist across bases)
// --------------------------------------------------
if (baseLost or expired) and not resetAfterRender
    resetAfterRender := true

if resetAfterRender
    hasBase := false
    activeDir := 0
    baseBar := na
    lockedBaseHigh := na
    lockedBaseLow := na
    defenseEdge := na
    defenseTop := na
    defenseBottom := na
    failureRail := na
    roomRail := na
    lastPressureBar := na
    roomDone := false
    resetAfterRender := false
````
