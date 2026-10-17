# Gap Continuation Planner [AGPro Series]

- url: https://www.tradingview.com/script/GRyJxOHC-Gap-Continuation-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;175e6bc12e464f3597fe37c348ed4850
- version: 6.0

## Description

TITLE
Gap Continuation Planner [AGPro Series]

🧠 Core Idea

Is the active gap being accepted for continuation, or is it losing the structure needed for a clean plan?


📌 Overview / What it does

Gap Continuation Planner [AGPro Series] is a chart-first gap planning tool built to evaluate what happens after a gap appears. Instead of treating every gap as an automatic fill candidate, it asks whether price is accepting the gap edge, following through away from the gap, and preserving a measurable defense line.

The script produces a gap defense zone, a continuation corridor, an acceptance edge, a defense line, a target guide, compact labels, alerts, and a clean AGPro decision panel. The panel converts the live context into a 0-100 continuation score, fill-risk reading, and next-action state.

It does not predict future price, automate trades, or tell the user to buy or sell. It organizes observable gap behavior into a more disciplined continuation-planning framework.


🎯 Purpose & Design Philosophy

This script was built for traders who do not want to reduce every gap to a simple fill-or-fade idea.

Many gaps initially look strong, but the important question is whether the market continues to accept the gap after the first reaction. Gap Continuation Planner focuses on that middle layer: gap acceptance, follow-through, volatility load, defense quality, fill pressure, and forward room.

The design supports a planner mindset. The goal is to slow the decision process down and review whether the structure is valid enough to deserve attention.


⚡ Why This Script Is Different

Most gap tools focus on gap detection, gap fill percentage, or historical gap zones.

This script does NOT work as a generic gap-fill reaction tool, support/resistance map, imbalance catalog, or automatic signal generator.

Instead, it treats the latest gap as a continuation planning object. The model studies whether price is accepting the continuation side of the gap, whether follow-through is developing, whether the defense line remains intact, whether fill risk is rising, and whether there is enough forward room for the plan to remain clean.


⚙️ Methodology

1. Context Detection
The script detects classic opening gaps, wick gaps, body-separation gaps, and controlled continuation launch windows when adaptive mode is enabled.

2. Reference Mapping
Each accepted gap creates a gap defense zone, an acceptance edge, a defense line, and a target guide.

3. Reaction Evaluation
The engine scores gap size, open acceptance, follow-through, volatility load, fill risk, and forward room.

4. Visual Output
The chart displays a centered gap-zone label, a centered continuation-corridor label, event labels, planner lines, and a compact AGPro panel.


🗺️ How to Read the Chart

Zones = the detected gap defense area.

Continuation corridor = the forward planning area between the accepted gap edge and target guide.

Acceptance edge = the side of the gap that price should hold for continuation structure to remain stronger.

Defense line = an ATR-buffered invalidation reference beyond the far side of the gap.

Labels = state changes such as new gap, acceptance watch, continuation ready, defense review, or failed acceptance.

Colors = bullish continuation context uses teal, bearish continuation context uses pink, watch states use indigo, and caution states use amber.

Panel = summarizes gap state, continuation score, defense line, fill risk, and next action.


🚦 Signals & States

• New Gap → a fresh gap continuation window has been detected.

• Acceptance Watch → price is holding the continuation side of the gap, but follow-through still needs confirmation.

• Continuation Ready → the gap has stronger acceptance, follow-through, room, and risk structure.

• Defense Test → price is retesting the gap edge or defense area.

• Fill Risk → the gap is being penetrated enough to reduce continuation quality.

• Gap Failed → the active gap has lost continuation acceptance.


🔔 Alerts Logic

Alerts trigger when a new gap continuation window appears, when the gap reaches READY state, when acceptance watch begins, when defense review becomes relevant, or when gap acceptance is lost.

Alerts are attention markers. They are not trade instructions and do not guarantee that continuation will occur.


🧩 Confluence Logic

The strongest continuation context appears when gap size, gap-edge acceptance, follow-through distance, stable volatility, low fill pressure, and enough forward room align.

When these elements align, the continuation score improves. When fill pressure rises or volatility becomes too hot, the score weakens.


📊 When to Use

• After opening gaps in stocks, indices, futures, or session-based markets

• During continuation attempts after a strong gap

• When reviewing whether a gap is holding acceptance or losing structure

• Around breakout continuation sessions where risk and target references need to be visible


⚠️ When NOT to Use

• Extremely low-liquidity markets

• Very noisy or overlapping session opens

• News-driven gaps with unstable spreads

• Markets where volume and session structure behave unusually

• Environments where price is already far beyond a reasonable risk reference


🎛️ Key Inputs

• Sensitivity → adjusts how strict the gap and score requirements are.

• Gap Mode → controls whether the script reads classic gaps only or adaptive continuation windows.

• Acceptance Bars → changes how many bars must hold the continuation side of the gap.

• Follow-Through ATR → controls the preferred travel away from the gap edge.

• Defense Buffer → sets the ATR spacing for the defense line.

• Forward Room Lookback → helps estimate whether nearby structure limits continuation room.

• Minimum Continuation Score → sets the READY threshold.

• Visual settings → control zones, corridors, lines, labels, object limits, and panel appearance.

• Show Failed / Stale Objects → controls whether old failed corridors remain visible. It is disabled by default for a cleaner publication view.


🖥️ Interface & Visual Design

The interface is built for quick planner-style review. The chart carries the structural map, while the panel provides the decision summary.

The first panel row follows the AGPro merged blue header standard. The remaining rows focus only on the practical planning fields: state, score, defense, fill risk, and action.

The visual hierarchy is intentionally restrained so the gap, corridor, and labels are readable without turning the chart into a crowded signal map.

By default, failed or stale gap objects are hidden after they lose live planning value. Event labels remain available so the chart keeps context without carrying too many old failed boxes.


🧪 Practical Usage Workflow

1. Read the panel state and continuation score.

2. Check whether price is holding the gap acceptance edge.

3. Review the continuation corridor and target guide.

4. Compare fill risk against the defense line.

5. Use alerts as review markers, not execution commands.

6. Confirm the context with broader market structure, liquidity, and personal risk rules.


🔍 Interpretation Guidelines

A high continuation score means the active gap has stronger structure inside this model. It does not mean the move must continue.

Low fill risk supports continuation structure. Rising fill risk means price is starting to challenge the gap.

The defense line is a planning reference. It is not a guaranteed stop level and should not replace the user's own risk process.

Continuation corridors are visual planning areas, not promised target zones.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an auto-trading system.

This script does not provide guaranteed signals.

This script does not replace independent confirmation, risk management, or execution discipline.


⚠️ Limitations & Transparency

Gap behavior varies heavily across asset classes, sessions, and timeframes.

Adaptive launch windows can help continuous markets, but they should still be interpreted as structured gap-like planning areas rather than classic exchange-session gaps.

High volatility can make defense and target references wider.

Low liquidity can distort gap quality, label timing, and fill-risk readings.

No rule-based script can fully account for news, slippage, spread changes, or sudden liquidity shifts.


🧠 Market Context Notes

Gap continuation is often more meaningful when it aligns with trend pressure, session participation, volatility structure, and clean forward room.

A gap is not important simply because it exists. It becomes more useful when price accepts one side of it and maintains a measurable defense structure.


🧾 Use Case Examples

When price gaps up, holds above the gap edge, and the continuation score improves, the script can help review whether the gap is being defended.

When price gaps down and repeatedly rejects back below the gap edge, the panel can help evaluate bearish continuation structure.

When fill risk rises quickly, the script highlights that the gap may be losing acceptance rather than continuing cleanly.


🧱 System Philosophy

AGProLabs tools are built around structured interpretation. The goal is not to add more signals to the chart. The goal is to turn market behavior into a cleaner review process.

Gap Continuation Planner follows that approach by converting a raw gap into a measurable planning object.


🔐 Non-Promise Statement

No indicator can remove uncertainty.

No score can guarantee continuation.

No planner can replace the trader's responsibility to manage risk.


📉 Risk Disclosure

Trading involves risk.

This script is provided for educational and analytical use only.

It does not provide financial advice, investment advice, trading advice, or guaranteed outcomes.

Users remain responsible for their own decisions, risk management, position sizing, and execution.


📚 Educational Note

The strongest use of this tool is to study whether a gap is being accepted or rejected as structure develops. It is designed to support review, patience, and disciplined interpretation.

## Source Code

````pine
// -------------------------------------------------
// Gap Continuation Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Gap Continuation Planner is a chart-first gap continuation decision engine
// that evaluates whether a new gap is gaining acceptance for continuation or
// losing structural control. It maps the gap zone, continuation corridor,
// defense line, fill-risk pressure, target guide, right-edge workflow tags,
// and next-action state for gap continuation planning and risk review.
// Version 1.5 strengthens confirmed acceptance counting, Proof integrity,
// gap-lifecycle reliability, critical-event visibility, and right-edge visual
// hierarchy while preserving the original continuation model and workflow.
// -------------------------------------------------

//@version=6
indicator("Gap Continuation Planner [AGPro Series]",
     shorttitle       = "AG Pro GCP",
     overlay          = true,
     max_boxes_count  = 30,
     max_labels_count = 120,
     max_lines_count  = 50,
     max_bars_back    = 700)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
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
dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_SENSITIVITY = "Controls how strict the planner is when accepting gap continuation windows. Conservative requires cleaner gaps and stronger continuation scores."
const string TT_CONFIRMATION = "Confirmed Close waits for bar close before creating labels and alerts. Realtime allows developing-bar attention markers."
const string TT_ATR = "ATR normalizes gap size, volatility load, defense distance, target projection, and label offsets across symbols."
const string TT_ATR_BASE = "Longer ATR baseline used to decide whether the gap is forming in normal volatility or an overheated environment."
const string TT_MODE = "Selects the gap detection style. Adaptive Continuation Gaps can include open gaps, wick gaps, body separation, and controlled launch windows for continuous markets."
const string TT_MIN_GAP = "Minimum gap height as a multiple of ATR before a new continuation planning window can be created."
const string TT_GAP_COOLDOWN = "Minimum bars between newly detected gap continuation windows. Higher values reduce clusters."
const string TT_ACTIVE_WINDOW = "Bars during which the latest gap remains a live continuation planning object before becoming stale."
const string TT_ACCEPTANCE = "Number of consecutive bars preferred above a bullish gap edge or below a bearish gap edge before acceptance quality improves."
const string TT_FOLLOW = "Minimum ATR-normalized travel away from the gap edge preferred before the script treats continuation pressure as meaningful."
const string TT_DEFENSE = "ATR buffer beyond the far side of the gap zone used to draw the defense line. This is an invalidation reference, not a stop recommendation."
const string TT_TARGET = "Target guide distance based on the original gap height. The target is a planning reference used to estimate forward room."
const string TT_OBSTACLE = "Lookback used to estimate whether recent structure leaves enough forward room for continuation."
const string TT_MIN_SCORE = "Minimum 0-100 continuation score required for READY state. Scores organize context; they do not predict outcomes."
const string TT_HOT_VOL = "ATR ratio above this level is treated as hot volatility. Hot conditions can reduce continuation quality because the gap may already be stretched."
const string TT_FAIL_FILL = "Fill-risk percentage that marks the active gap as structurally failed for continuation planning."
const string TT_SHOW_ZONE = "Shows the detected gap defense zone with centered text."
const string TT_SHOW_CORRIDOR = "Shows the forward continuation corridor from the accepted gap edge toward the target guide. The text is centered inside the corridor."
const string TT_SHOW_LINES = "Shows the acceptance edge, defense line, and target guide used by the planner."
const string TT_SHOW_FAILED = "Shows failed or stale gap objects. Disabled by default to keep old failed corridors from cluttering the chart."
const string TT_PROJECTION = "Bars projected forward for the active gap zone, continuation corridor, and planning lines."
const string TT_ZONE_HEIGHT = "Adds a minimum visual height to thin gap zones while preserving the true calculation boundaries."
const string TT_MAX_OBJECTS = "Maximum number of recent gap objects kept on the chart. Older objects are removed first for performance."
const string TT_EVENT_LABELS = "Shows compact gap, continuation, defense-test, and failure labels."
const string TT_CONTEXT_LABELS = "Adds sparse context labels during active gap continuation states. Disabled by default for a cleaner public-release chart."
const string TT_LABEL_COOLDOWN = "Minimum bars between event labels. Higher values reduce label density."
const string TT_CONTEXT_SPACING = "Minimum bars between sparse context labels while a live gap remains active."
const string TT_MAX_LABELS = "Maximum chart labels retained by the script. Older labels are removed first."
const string TT_LABEL_OFFSET = "ATR-based vertical offset that keeps labels away from candles."
const string TT_LABEL_SCORE = "Adds the 0-100 continuation score to chart labels."
const string TT_LABEL_SIZE = "Controls all chart label sizes. Normal is the recommended public-release default."
const string TT_SHOW_PANEL = "Shows or hides the AG Pro planning panel. The panel is shown by default."
const string TT_PANEL_LOCATION = "Selects where the AG Pro panel appears on the chart."
const string TT_PANEL_THEME = "Switches the panel between AGPro dark and clean light themes."
const string TT_PANEL_SIZE = "Controls the font size used inside the panel. Normal is the recommended default."
const string TT_ALERTS = "Enables alert conditions for new gap, ready, watch, defense review, and failed acceptance states."
const string TT_SHOWPROOF = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across detected gaps on the current symbol and timeframe. Follow means a detected gap continued one risk unit (1R) from its acceptance edge toward the target guide, or reached a nearer target, before the defense line was breached. These are historical outcome rates, not predictions."
const string TT_PROOF_HORIZON = "Maximum number of bars each detected gap is tracked for the proof measurement before it resolves at its current outcome."
const string TT_REACT_BARS = "Number of bars after a gap is detected used to detect an immediate favorable continuation reaction."
const string TT_REACT_PROGRESS = "Minimum favorable continuation progress toward the 1R target, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Gap Engine"
sensitivityInput = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = TT_SENSITIVITY)
confirmationMode = input.string("Confirmed Close", "Confirmation Mode", options = ["Confirmed Close", "Realtime"], group = groupEngine, tooltip = TT_CONFIRMATION)
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_ATR)
atrBaselineLength = input.int(55, "ATR Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = TT_ATR_BASE)
gapModeInput = input.string("Adaptive Continuation Gaps", "Gap Mode", options = ["Adaptive Continuation Gaps", "Classic Open Gap", "Open + Wick Gap", "Open + Body Separation"], group = groupEngine, tooltip = TT_MODE)
minimumGapAtrInput = input.float(0.16, "Minimum Gap Size (x ATR)", minval = 0.02, maxval = 3.00, step = 0.01, group = groupEngine, tooltip = TT_MIN_GAP)
gapCooldownBars = input.int(18, "Gap Cooldown Bars", minval = 0, maxval = 200, group = groupEngine, tooltip = TT_GAP_COOLDOWN)
activeWindowBars = input.int(72, "Active Gap Window", minval = 12, maxval = 300, group = groupEngine, tooltip = TT_ACTIVE_WINDOW)

groupScoring = "Continuation Scoring"
acceptanceBars = input.int(2, "Acceptance Bars", minval = 1, maxval = 12, group = groupScoring, tooltip = TT_ACCEPTANCE)
minimumFollowThroughAtr = input.float(0.35, "Follow-Through ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = TT_FOLLOW)
defenseBufferAtr = input.float(0.20, "Defense Buffer (x ATR)", minval = 0.00, maxval = 2.00, step = 0.05, group = groupScoring, tooltip = TT_DEFENSE)
targetGapMultiple = input.float(1.75, "Target Guide Gap Multiple", minval = 0.50, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = TT_TARGET)
obstacleLookback = input.int(34, "Forward Room Lookback", minval = 8, maxval = 220, group = groupScoring, tooltip = TT_OBSTACLE)
minimumContinuationScore = input.int(68, "Minimum Continuation Score", minval = 40, maxval = 95, group = groupScoring, tooltip = TT_MIN_SCORE)
hotVolatilityRatio = input.float(2.15, "Hot Volatility Ratio", minval = 1.20, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = TT_HOT_VOL)
failedFillRisk = input.float(88.0, "Failed Fill Risk (%)", minval = 50.0, maxval = 100.0, step = 1.0, group = groupScoring, tooltip = TT_FAIL_FILL)

groupVisual = "Chart Visuals"
showGapZone = input.bool(true, "Show Gap Zone", group = groupVisual, tooltip = TT_SHOW_ZONE)
showContinuationCorridor = input.bool(true, "Show Continuation Corridor", group = groupVisual, tooltip = TT_SHOW_CORRIDOR)
showPlannerLines = input.bool(true, "Show Planner Lines", group = groupVisual, tooltip = TT_SHOW_LINES)
showFailedObjects = input.bool(false, "Show Failed / Stale Objects", group = groupVisual, tooltip = TT_SHOW_FAILED)
projectionBars = input.int(42, "Projection Bars", minval = 10, maxval = 240, group = groupVisual, tooltip = TT_PROJECTION)
minimumVisualZoneAtr = input.float(0.24, "Minimum Visual Zone Height (x ATR)", minval = 0.00, maxval = 2.00, step = 0.01, group = groupVisual, tooltip = TT_ZONE_HEIGHT)
maxVisibleObjects = input.int(2, "Max Visible Objects", minval = 1, maxval = 20, group = groupVisual, tooltip = TT_MAX_OBJECTS)
showLivePlanTags = input.bool(true, "Show Live Plan Tags", group = groupVisual, tooltip = "Shows compact right-edge tags for workflow state, continuation score, and fill-risk context.")
rightTagOffsetBars = input.int(7, "Right Tag Offset Bars", minval = 1, maxval = 40, group = groupVisual, tooltip = "Horizontal offset for live right-edge tags. Increase it if tags overlap the price scale or corridor labels.")

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = TT_EVENT_LABELS)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = TT_CONTEXT_LABELS)
labelCooldownBars = input.int(26, "Label Cooldown Bars", minval = 1, maxval = 160, group = groupLabels, tooltip = TT_LABEL_COOLDOWN)
contextSpacingBars = input.int(96, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = TT_CONTEXT_SPACING)
maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = TT_MAX_LABELS)
labelOffsetAtr = input.float(1.18, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = TT_LABEL_OFFSET)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = TT_LABEL_SCORE)
labelFontSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = TT_LABEL_SIZE)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_SHOW_PANEL)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = TT_SHOWPROOF)
proofHorizonBars = input.int(40, "Proof Horizon Bars", minval = 5, maxval = 300, group = groupProof, tooltip = TT_PROOF_HORIZON)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = TT_REACT_BARS)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = TT_REACT_PROGRESS)

groupAlerts = "Alerts"
alertGapStates = input.bool(true, "Alert on Gap States", group = groupAlerts, tooltip = TT_ALERTS)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_label_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_state_color(string stateText) =>
    switch stateText
        "READY" => bullColor
        "WATCH" => accentColor
        "DEFENSE TEST" => neutralColor
        "FILL RISK" => neutralColor
        "FAILED" => bearColor
        "STALE" => panelLabelCol
        => panelLabelCol

f_state_display(string stateText) =>
    switch stateText
        "READY" => "PLAN READY"
        "WATCH" => "BUILD WATCH"
        "DEFENSE TEST" => "DEFENSE CHECK"
        "FILL RISK" => "FILL PRESSURE"
        "FAILED" => "ACCEPTANCE LOST"
        "STALE" => "WINDOW STALE"
        "NO GAP" => "WAIT GAP"
        => stateText

f_state_short(string stateText) =>
    switch stateText
        "READY" => "READY"
        "WATCH" => "WATCH"
        "DEFENSE TEST" => "DEFENSE"
        "FILL RISK" => "FILL PRESSURE"
        "FAILED" => "LOST"
        "STALE" => "STALE"
        "NO GAP" => "NO GAP"
        => stateText

f_direction_text(int direction) =>
    direction == 1 ? "BULL GAP" : direction == -1 ? "BEAR GAP" : "NO GAP"

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_percent(float value) =>
    str.tostring(value, "#.0") + "%"

f_fill_tier(float fillRisk) =>
    fillRisk >= 75.0 ? "HIGH" : fillRisk >= 45.0 ? "ELEVATED" : fillRisk >= 20.0 ? "MODERATE" : "LOW"

f_action_text(string stateText) =>
    switch stateText
        "READY" => "REVIEW PLAN"
        "WATCH" => "TRACK BUILD"
        "DEFENSE TEST" => "CHECK DEFENSE"
        "FILL RISK" => "REVIEW FILL"
        "FAILED" => "MARK LOST"
        "STALE" => "WAIT FRESH GAP"
        => "WAIT CLEAN GAP"

f_best_view_text(string stateText, float fillRisk, float roomAtr) =>
    string view = "STAND BY"
    if stateText == "READY"
        view := roomAtr >= 1.0 and fillRisk < 45.0 ? "ROOM OK" : "CHECK ROOM"
    else if stateText == "WATCH"
        view := "TRACK ACCEPTANCE"
    else if stateText == "DEFENSE TEST"
        view := "DEFENSE AREA"
    else if stateText == "FILL RISK"
        view := "FILL PRESSURE"
    else if stateText == "FAILED"
        view := "RESET PLAN"
    else if stateText == "STALE"
        view := "STALE WINDOW"
    view

f_compact_state(string stateText) =>
    switch stateText
        "READY" => "PLAN READY"
        "WATCH" => "BUILD WATCH"
        "DEFENSE TEST" => "DEFENSE CHECK"
        "FILL RISK" => "FILL PRESSURE"
        "FAILED" => "LOST"
        "STALE" => "WINDOW STALE"
        "NO GAP" => "NO GAP"
        => stateText

f_event_text(string stateText, int direction, int scoreValue, bool includeScore) =>
    string sideText = direction == 1 ? "BULL" : "BEAR"
    string baseText = switch stateText
        "NEW" => sideText + " GAP"
        "READY" => "PLAN READY"
        "WATCH" => "BUILD WATCH"
        "DEFENSE TEST" => "DEFENSE CHECK"
        "FAILED" => "ACCEPTANCE LOST"
        => "GAP"
    includeScore and stateText != "NEW" ? baseText + " | " + str.tostring(scoreValue) : baseText

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxCount) =>
    int boxCount = array.size(boxes)
    if boxCount > maxCount
        int removeCount = boxCount - maxCount
        for idx = 0 to removeCount - 1
            box oldBox = array.shift(boxes)
            box.delete(oldBox)

f_trim_lines(array<line> lines, int maxCount) =>
    int lineCount = array.size(lines)
    if lineCount > maxCount
        int removeCount = lineCount - maxCount
        for idx = 0 to removeCount - 1
            line oldLine = array.shift(lines)
            line.delete(oldLine)

f_add_label(array<label> labels, string labelText, int direction, color bgColor, float atrForOffset, float offsetAtr, int maxCount, string sizeText) =>
    bool isBull = direction == 1
    float yValue = isBull ? low - atrForOffset * offsetAtr : high + atrForOffset * offsetAtr
    label newLabel = label.new(x = bar_index, y = yValue, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = isBull ? label.style_label_up : label.style_label_down, color = color.new(bgColor, 8), textcolor = headerText, size = f_label_size(sizeText))
    array.push(labels, newLabel)
    f_trim_labels(labels, maxCount)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
float atrValue = ta.atr(atrLength)
float safeAtr = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
float atrBaseline = ta.sma(atrValue, atrBaselineLength)
float atrRatio = not na(atrBaseline) and atrBaseline > 0.0 ? atrValue / atrBaseline : 1.0

float sensitivityGapFactor = sensitivityInput == "Conservative" ? 1.20 : sensitivityInput == "Aggressive" ? 0.82 : 1.00
int sensitivityScoreAdjust = sensitivityInput == "Conservative" ? 5 : sensitivityInput == "Aggressive" ? -5 : 0
float effectiveMinGapAtr = minimumGapAtrInput * sensitivityGapFactor
int effectiveReadyScore = math.max(40, math.min(95, minimumContinuationScore + sensitivityScoreAdjust))
int effectiveWatchScore = math.max(30, effectiveReadyScore - 16)
int effectiveAcceptanceBars = math.min(acceptanceBars, math.max(activeWindowBars, 1))
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

int engineWarmup = math.max(atrBaselineLength, obstacleLookback) + atrLength + 5
bool engineReady = bar_index > engineWarmup
bool confirmationOk = confirmationMode == "Realtime" or barstate.isconfirmed
bool proofConfirmedBar = barstate.isconfirmed

float minimumGapDistance = safeAtr * effectiveMinGapAtr
bool hasPreviousBar = bar_index > 0
float previousClose = nz(close[1], close)
float currentBodyHigh = math.max(open, close)
float currentBodyLow = math.min(open, close)
float previousBodyHigh = math.max(nz(open[1], open), nz(close[1], close))
float previousBodyLow = math.min(nz(open[1], open), nz(close[1], close))
float candleRange = math.max(high - low, syminfo.mintick)
float closeEfficiencyBull = (close - low) / candleRange
float closeEfficiencyBear = (high - close) / candleRange
float obstacleHigh = ta.highest(high, obstacleLookback)[1]
float obstacleLow = ta.lowest(low, obstacleLookback)[1]

bool useWickGap = gapModeInput == "Adaptive Continuation Gaps" or gapModeInput == "Open + Wick Gap"
bool useBodyGap = gapModeInput == "Adaptive Continuation Gaps" or gapModeInput == "Open + Body Separation"
bool useLaunchWindow = gapModeInput == "Adaptive Continuation Gaps"

bool classicGapUp = hasPreviousBar and open - previousClose >= minimumGapDistance
bool classicGapDown = hasPreviousBar and previousClose - open >= minimumGapDistance
bool wickGapUp = useWickGap and not classicGapUp and hasPreviousBar and low - high[1] >= minimumGapDistance
bool wickGapDown = useWickGap and not classicGapDown and hasPreviousBar and low[1] - high >= minimumGapDistance
bool bodyGapUp = useBodyGap and not classicGapUp and not wickGapUp and hasPreviousBar and currentBodyLow - previousBodyHigh >= minimumGapDistance
bool bodyGapDown = useBodyGap and not classicGapDown and not wickGapDown and hasPreviousBar and previousBodyLow - currentBodyHigh >= minimumGapDistance
bool launchGapUp = useLaunchWindow and not classicGapUp and not wickGapUp and not bodyGapUp and hasPreviousBar and close - previousClose >= minimumGapDistance * 2.8 and closeEfficiencyBull >= 0.72 and low >= previousClose - minimumGapDistance * 0.20
bool launchGapDown = useLaunchWindow and not classicGapDown and not wickGapDown and not bodyGapDown and hasPreviousBar and previousClose - close >= minimumGapDistance * 2.8 and closeEfficiencyBear >= 0.72 and high <= previousClose + minimumGapDistance * 0.20

var int lastGapBar = na
bool gapCooldownOk = na(lastGapBar) or bar_index - lastGapBar >= gapCooldownBars
bool newBullGap = confirmationOk and engineReady and gapCooldownOk and (classicGapUp or wickGapUp or bodyGapUp or launchGapUp)
bool newBearGap = confirmationOk and engineReady and gapCooldownOk and (classicGapDown or wickGapDown or bodyGapDown or launchGapDown)
bool newGapEvent = newBullGap or newBearGap

// -------------------------------------------------
// Object state
// -------------------------------------------------
var array<box> gapBoxes = array.new_box()
var array<box> corridorBoxes = array.new_box()
var array<line> edgeLines = array.new_line()
var array<line> defenseLines = array.new_line()
var array<line> targetLines = array.new_line()
var array<label> eventLabels = array.new_label()

var box activeGapBox = na
var box activeCorridorBox = na
var label activeGapBadge = na
var label activeCorridorBadge = na
var label livePlanTag = na
var label liveScoreTag = na
var label liveRiskTag = na
var line livePlanConnector = na
var line activeEdgeLine = na
var line activeDefenseLine = na
var line activeTargetLine = na

var int activeDirection = 0
var int activeBirthBar = na
var int activeAcceptanceStreak = 0
var int lastAcceptanceCountBar = na
var float activeGapTop = na
var float activeGapBottom = na
var float activeGapHeight = na
var float activeDefense = na
var float activeTarget = na
var float activeFillRisk = 0.0
var int activeScore = 0
var string activeState = "NO GAP"
var string previousState = "NO GAP"
var int lastEventLabelBar = na
var int lastContextLabelBar = na

// -------------------------------------------------
// New gap creation
// -------------------------------------------------
if newGapEvent
    if not na(activeGapBadge)
        label.delete(activeGapBadge)
        activeGapBadge := na
    if not na(activeCorridorBadge)
        label.delete(activeCorridorBadge)
        activeCorridorBadge := na

    int newDirection = newBullGap ? 1 : -1
    float newTop = na
    float newBottom = na

    if newDirection == 1
        if classicGapUp
            newTop := open
            newBottom := previousClose
        else if wickGapUp
            newTop := low
            newBottom := high[1]
        else if bodyGapUp
            newTop := currentBodyLow
            newBottom := previousBodyHigh
        else
            float launchHeight = math.max(minimumGapDistance, math.min(math.abs(close - previousClose) * 0.32, safeAtr * 0.70))
            newTop := previousClose + launchHeight
            newBottom := previousClose
    else
        if classicGapDown
            newTop := previousClose
            newBottom := open
        else if wickGapDown
            newTop := low[1]
            newBottom := high
        else if bodyGapDown
            newTop := previousBodyLow
            newBottom := currentBodyHigh
        else
            float launchHeight = math.max(minimumGapDistance, math.min(math.abs(close - previousClose) * 0.32, safeAtr * 0.70))
            newTop := previousClose
            newBottom := previousClose - launchHeight

    if not na(newTop) and not na(newBottom) and newTop > newBottom
        float trueGapHeight = math.max(newTop - newBottom, syminfo.mintick)
        float visualHeight = math.max(trueGapHeight, safeAtr * minimumVisualZoneAtr)
        float zoneMid = (newTop + newBottom) * 0.5
        float visualTop = zoneMid + visualHeight * 0.5
        float visualBottom = zoneMid - visualHeight * 0.5
        float newDefense = newDirection == 1 ? newBottom - safeAtr * defenseBufferAtr : newTop + safeAtr * defenseBufferAtr
        float targetDistance = math.max(trueGapHeight * targetGapMultiple, safeAtr * minimumFollowThroughAtr * 2.0)
        float newTarget = newDirection == 1 ? newTop + targetDistance : newBottom - targetDistance
        float newEdge = newDirection == 1 ? newTop : newBottom
        color newColor = newDirection == 1 ? bullColor : bearColor
        int rightEdge = bar_index + projectionBars
        int midX = int(math.round((bar_index + rightEdge) * 0.5))
        float corridorTop = newDirection == 1 ? newTarget : newBottom
        float corridorBottom = newDirection == 1 ? newTop : newTarget
        float corridorMid = (corridorTop + corridorBottom) * 0.5

        activeDirection := newDirection
        activeBirthBar := bar_index
        activeAcceptanceStreak := 0
        lastAcceptanceCountBar := na
        activeGapTop := newTop
        activeGapBottom := newBottom
        activeGapHeight := trueGapHeight
        activeDefense := newDefense
        activeTarget := newTarget
        activeFillRisk := 0.0
        activeScore := 0
        activeState := "WATCH"
        previousState := "NEW"
        lastGapBar := bar_index

        activeGapBox := box.new(left = bar_index, top = visualTop, right = rightEdge, bottom = visualBottom, xloc = xloc.bar_index, bgcolor = showGapZone ? color.new(newColor, 88) : color.new(newColor, 100), border_color = showGapZone ? color.new(newColor, 18) : color.new(newColor, 100), border_width = 1)
        activeCorridorBox := box.new(left = bar_index, top = corridorTop, right = rightEdge, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = showContinuationCorridor ? color.new(newColor, 93) : color.new(newColor, 100), border_color = showContinuationCorridor ? color.new(newColor, 48) : color.new(newColor, 100), border_width = 1)
        activeEdgeLine := line.new(bar_index, newEdge, rightEdge, newEdge, xloc = xloc.bar_index, color = showPlannerLines ? color.new(accentColor, 10) : color.new(accentColor, 100), style = line.style_dotted, width = 2)
        activeDefenseLine := line.new(bar_index, newDefense, rightEdge, newDefense, xloc = xloc.bar_index, color = showPlannerLines ? color.new(newColor, 8) : color.new(newColor, 100), style = line.style_dashed, width = 2)
        activeTargetLine := line.new(bar_index, newTarget, rightEdge, newTarget, xloc = xloc.bar_index, color = showPlannerLines ? color.new(neutralColor, 20) : color.new(neutralColor, 100), style = line.style_solid, width = 1)

        if showGapZone
            activeGapBadge := label.new(midX, zoneMid, (newDirection == 1 ? "BULL GAP" : "BEAR GAP") + "\nDEFENSE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(newColor, 0), textcolor = headerText, size = f_label_size(labelFontSizeInput), textalign = text.align_center)
        if showContinuationCorridor
            activeCorridorBadge := label.new(midX, corridorMid, "CONTINUATION\nPLAN", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = headerText, size = f_label_size(labelFontSizeInput), textalign = text.align_center)

        array.push(gapBoxes, activeGapBox)
        array.push(corridorBoxes, activeCorridorBox)
        array.push(edgeLines, activeEdgeLine)
        array.push(defenseLines, activeDefenseLine)
        array.push(targetLines, activeTargetLine)
        f_trim_boxes(gapBoxes, maxVisibleObjects)
        f_trim_boxes(corridorBoxes, maxVisibleObjects)
        f_trim_lines(edgeLines, maxVisibleObjects)
        f_trim_lines(defenseLines, maxVisibleObjects)
        f_trim_lines(targetLines, maxVisibleObjects)

// -------------------------------------------------
// Active gap scoring
// -------------------------------------------------
bool hasActiveGap = activeDirection != 0 and not na(activeGapTop) and not na(activeGapBottom)
bool activeAccepted = false
bool activeFollowThrough = false
bool activeDefenseTest = false
bool activeFailed = false
bool activeStale = false
float currentFillRisk = 0.0
float edgeDistanceAtr = 0.0
float obstacleRoomAtr = 0.0
float gapAtr = 0.0

int activeGapAge = hasActiveGap ? bar_index - activeBirthBar : 0

if hasActiveGap
    int gapAge = activeGapAge
    activeStale := gapAge > activeWindowBars
    float gapHeight = math.max(activeGapHeight, syminfo.mintick)
    currentFillRisk := activeDirection == 1 ? f_clamp((activeGapTop - low) / gapHeight * 100.0, 0.0, 100.0) : f_clamp((high - activeGapBottom) / gapHeight * 100.0, 0.0, 100.0)
    activeFillRisk := math.max(activeFillRisk, currentFillRisk)
    activeAccepted := activeDirection == 1 ? close > activeGapTop : close < activeGapBottom

    // Acceptance Bars represent completed chart bars. Count once per confirmed
    // bar and do not count the original gap-detection bar as acceptance.
    if barstate.isconfirmed and (na(lastAcceptanceCountBar) or bar_index != lastAcceptanceCountBar)
        activeAcceptanceStreak := gapAge > 0 ? (activeAccepted ? activeAcceptanceStreak + 1 : 0) : 0
        lastAcceptanceCountBar := bar_index
    edgeDistanceAtr := activeDirection == 1 ? math.max(close - activeGapTop, 0.0) / safeAtr : math.max(activeGapBottom - close, 0.0) / safeAtr
    float continuationTravelAtr = activeDirection == 1 ? math.max(high - activeGapTop, 0.0) / safeAtr : math.max(activeGapBottom - low, 0.0) / safeAtr
    activeFollowThrough := continuationTravelAtr >= minimumFollowThroughAtr and activeAccepted
    activeDefenseTest := currentFillRisk >= 20.0 and currentFillRisk < failedFillRisk and not activeStale
    activeFailed := activeFillRisk >= failedFillRisk or (activeDirection == 1 ? close < activeDefense : close > activeDefense)

    gapAtr := activeGapHeight / safeAtr
    float gapSizeScore = f_peak_score(gapAtr, effectiveMinGapAtr, effectiveMinGapAtr * 3.2, effectiveMinGapAtr * 9.0) * 0.18
    float acceptanceStreakScore = f_clamp(float(activeAcceptanceStreak) / float(effectiveAcceptanceBars), 0.0, 1.0) * 16.0
    float edgeScore = f_norm_high_good(edgeDistanceAtr, 0.0, minimumFollowThroughAtr * 2.2) * 0.09
    float acceptanceScore = acceptanceStreakScore + edgeScore
    float closeEfficiency = activeDirection == 1 ? closeEfficiencyBull : closeEfficiencyBear
    float followTravelScore = f_norm_high_good(continuationTravelAtr, 0.0, minimumFollowThroughAtr * 2.8) * 0.16
    float closeEfficiencyScore = f_norm_high_good(closeEfficiency, 0.45, 0.82) * 0.09
    float followScore = followTravelScore + closeEfficiencyScore
    float volatilityScore = f_peak_score(atrRatio, 0.72, 1.12, hotVolatilityRatio) * 0.14
    float recentObstacle = activeDirection == 1 ? obstacleHigh : obstacleLow
    obstacleRoomAtr := activeDirection == 1 ? (recentObstacle > close ? (recentObstacle - close) / safeAtr : 3.0) : (recentObstacle < close ? (close - recentObstacle) / safeAtr : 3.0)
    float roomScore = f_norm_high_good(obstacleRoomAtr, 0.25, 2.60) * 0.18
    float fillPenalty = activeFillRisk * 0.30
    activeScore := int(math.round(f_clamp(gapSizeScore + acceptanceScore + followScore + volatilityScore + roomScore - fillPenalty, 0.0, 100.0)))

    if activeFailed
        activeState := "FAILED"
    else if activeStale
        activeState := "STALE"
    else if activeFillRisk >= 55.0
        activeState := "FILL RISK"
    else if activeDefenseTest and activeScore < effectiveReadyScore
        activeState := "DEFENSE TEST"
    else if activeScore >= effectiveReadyScore and activeFollowThrough and activeAcceptanceStreak >= effectiveAcceptanceBars
        activeState := "READY"
    else if activeScore >= effectiveWatchScore and activeAccepted
        activeState := "WATCH"
    else
        activeState := "DEFENSE TEST"

    color activeColor = activeDirection == 1 ? bullColor : bearColor
    int liveRight = activeStale or activeFailed ? activeBirthBar + projectionBars : bar_index + projectionBars
    int badgeX = int(math.round((activeBirthBar + liveRight) * 0.5))
    float visualHeight = math.max(activeGapHeight, safeAtr * minimumVisualZoneAtr)
    float zoneMid = (activeGapTop + activeGapBottom) * 0.5
    float visualTop = zoneMid + visualHeight * 0.5
    float visualBottom = zoneMid - visualHeight * 0.5
    float corridorTop = activeDirection == 1 ? activeTarget : activeGapBottom
    float corridorBottom = activeDirection == 1 ? activeGapTop : activeTarget
    float corridorMid = (corridorTop + corridorBottom) * 0.5
    bool showLiveObjects = showFailedObjects or (activeState != "FAILED" and activeState != "STALE")
    string zoneText = (activeDirection == 1 ? "BULL GAP" : "BEAR GAP") + "\n" + f_state_short(activeState)
    string corridorText = (activeState == "FAILED" or activeState == "STALE") ? "" : f_state_short(activeState) + "\nSCORE " + str.tostring(activeScore)
    float edgeLinePrice = activeDirection == 1 ? activeGapTop : activeGapBottom

    if not na(activeGapBox)
        box.set_right(activeGapBox, liveRight)
        box.set_top(activeGapBox, visualTop)
        box.set_bottom(activeGapBox, visualBottom)
        box.set_bgcolor(activeGapBox, showGapZone and showLiveObjects ? color.new(activeColor, (activeState == "FAILED" or activeState == "STALE") ? 94 : 89) : color.new(activeColor, 100))
        box.set_border_color(activeGapBox, showGapZone and showLiveObjects ? color.new(activeColor, (activeState == "FAILED" or activeState == "STALE") ? 62 : 22) : color.new(activeColor, 100))
    if not na(activeCorridorBox)
        box.set_right(activeCorridorBox, liveRight)
        box.set_top(activeCorridorBox, corridorTop)
        box.set_bottom(activeCorridorBox, corridorBottom)
        box.set_bgcolor(activeCorridorBox, showContinuationCorridor and showLiveObjects ? color.new(activeColor, activeState == "READY" ? 91 : (activeState == "FAILED" or activeState == "STALE") ? 96 : 94) : color.new(activeColor, 100))
        box.set_border_color(activeCorridorBox, showContinuationCorridor and showLiveObjects ? color.new(activeColor, activeState == "READY" ? 30 : (activeState == "FAILED" or activeState == "STALE") ? 70 : 58) : color.new(activeColor, 100))
    if showGapZone and showLiveObjects
        if na(activeGapBadge)
            activeGapBadge := label.new(badgeX, zoneMid, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(activeColor, 0), textcolor = headerText, size = f_label_size(labelFontSizeInput), textalign = text.align_center)
        else
            label.set_xy(activeGapBadge, badgeX, zoneMid)
            label.set_text(activeGapBadge, zoneText)
            label.set_color(activeGapBadge, color.new(activeColor, 0))
            label.set_textcolor(activeGapBadge, headerText)
            label.set_size(activeGapBadge, f_label_size(labelFontSizeInput))
    else if not na(activeGapBadge)
        label.delete(activeGapBadge)
        activeGapBadge := na
    if showContinuationCorridor and showLiveObjects and corridorText != ""
        if na(activeCorridorBadge)
            activeCorridorBadge := label.new(badgeX, corridorMid, corridorText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = headerText, size = f_label_size(labelFontSizeInput), textalign = text.align_center)
        else
            label.set_xy(activeCorridorBadge, badgeX, corridorMid)
            label.set_text(activeCorridorBadge, corridorText)
            label.set_color(activeCorridorBadge, color.new(accentColor, 0))
            label.set_textcolor(activeCorridorBadge, headerText)
            label.set_size(activeCorridorBadge, f_label_size(labelFontSizeInput))
    else if not na(activeCorridorBadge)
        label.delete(activeCorridorBadge)
        activeCorridorBadge := na
    if not na(activeEdgeLine)
        line.set_x2(activeEdgeLine, liveRight)
        line.set_y1(activeEdgeLine, edgeLinePrice)
        line.set_y2(activeEdgeLine, edgeLinePrice)
        line.set_color(activeEdgeLine, showPlannerLines and showLiveObjects ? color.new(accentColor, 18) : color.new(accentColor, 100))
    if not na(activeDefenseLine)
        line.set_x2(activeDefenseLine, liveRight)
        line.set_y1(activeDefenseLine, activeDefense)
        line.set_y2(activeDefenseLine, activeDefense)
        line.set_color(activeDefenseLine, showPlannerLines and showLiveObjects ? color.new(activeColor, 10) : color.new(activeColor, 100))
    if not na(activeTargetLine)
        line.set_x2(activeTargetLine, liveRight)
        line.set_y1(activeTargetLine, activeTarget)
        line.set_y2(activeTargetLine, activeTarget)
        line.set_color(activeTargetLine, showPlannerLines and showLiveObjects ? color.new(neutralColor, activeState == "READY" ? 12 : 48) : color.new(neutralColor, 100))
else
    activeState := "NO GAP"

// -------------------------------------------------
// Live plan tags
// -------------------------------------------------
if barstate.islast
    if showLivePlanTags and hasActiveGap
        color tagColor = f_state_color(activeState)
        int planTagX = bar_index + rightTagOffsetBars
        int scoreTagX = planTagX + 2
        int riskTagX = planTagX + 4
        float tagGap = math.max(safeAtr * 0.96, close * 0.008)
        float edgeY = activeDirection == 1 ? activeGapTop : activeGapBottom
        float planY = activeDirection == 1 ? edgeY + tagGap : edgeY - tagGap
        float scoreY = activeDirection == 1 ? planY + tagGap : planY - tagGap
        float riskY = activeDirection == 1 ? planY - tagGap : planY + tagGap
        string sideText = activeDirection == 1 ? "BULL" : "BEAR"
        string planText = sideText + " | " + f_state_short(activeState)
        string scoreText = "SCORE " + str.tostring(activeScore) + "/100"
        string riskText = "FILL " + f_percent(activeFillRisk)

        if na(livePlanTag)
            livePlanTag := label.new(planTagX, planY, planText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(tagColor, 0), textcolor = headerText, size = f_label_size(labelFontSizeInput))
        else
            label.set_xy(livePlanTag, planTagX, planY)
            label.set_text(livePlanTag, planText)
            label.set_style(livePlanTag, label.style_label_left)
            label.set_color(livePlanTag, color.new(tagColor, 0))
            label.set_textcolor(livePlanTag, headerText)
            label.set_size(livePlanTag, f_label_size(labelFontSizeInput))

        if na(liveScoreTag)
            liveScoreTag := label.new(scoreTagX, scoreY, scoreText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 4), textcolor = headerText, size = f_label_size(labelFontSizeInput))
        else
            label.set_xy(liveScoreTag, scoreTagX, scoreY)
            label.set_text(liveScoreTag, scoreText)
            label.set_style(liveScoreTag, label.style_label_left)
            label.set_color(liveScoreTag, color.new(accentColor, 4))
            label.set_textcolor(liveScoreTag, headerText)
            label.set_size(liveScoreTag, f_label_size(labelFontSizeInput))

        if na(liveRiskTag)
            liveRiskTag := label.new(riskTagX, riskY, riskText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 4), textcolor = color.rgb(15, 23, 42), size = f_label_size(labelFontSizeInput))
        else
            label.set_xy(liveRiskTag, riskTagX, riskY)
            label.set_text(liveRiskTag, riskText)
            label.set_style(liveRiskTag, label.style_label_left)
            label.set_color(liveRiskTag, color.new(neutralColor, 4))
            label.set_textcolor(liveRiskTag, color.rgb(15, 23, 42))
            label.set_size(liveRiskTag, f_label_size(labelFontSizeInput))

        if na(livePlanConnector)
            livePlanConnector := line.new(bar_index, edgeY, planTagX, planY, xloc = xloc.bar_index, color = color.new(tagColor, 38), width = 1)
        else
            line.set_xy1(livePlanConnector, bar_index, edgeY)
            line.set_xy2(livePlanConnector, planTagX, planY)
            line.set_color(livePlanConnector, color.new(tagColor, 38))
    else
        if not na(livePlanTag)
            label.delete(livePlanTag)
            livePlanTag := na
        if not na(liveScoreTag)
            label.delete(liveScoreTag)
            liveScoreTag := na
        if not na(liveRiskTag)
            label.delete(liveRiskTag)
            liveRiskTag := na
        if not na(livePlanConnector)
            line.delete(livePlanConnector)
            livePlanConnector := na

// -------------------------------------------------
// Labels and alerts
// -------------------------------------------------
bool readyEvent = confirmationOk and activeState == "READY" and previousState != "READY"
bool watchEvent = confirmationOk and activeState == "WATCH" and previousState != "WATCH"
bool defenseEvent = confirmationOk and activeState == "DEFENSE TEST" and previousState != "DEFENSE TEST"
bool failedEvent = confirmationOk and activeState == "FAILED" and previousState != "FAILED"
bool eventCooldownOk = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars

// -------------------------------------------------
// Confirmation-anchored proof (detected gaps, Follow = continued 1R from edge toward target before defense)
// -------------------------------------------------
bool proofGapEvent = proofConfirmedBar and engineReady and hasActiveGap and activeBirthBar == bar_index

var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false

if proofConfirmedBar and engineReady
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool ambiguousNow = targetTouched and stopTouched

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched
                    proofFlip := proofFlip + 1
            pEvalActive := false

    // Open one non-overlapping Proof sample for a confirmed gap call.
    // Later gap calls are ignored until the current sample resolves.
    if proofGapEvent and not pEvalActive and not na(activeDefense) and not na(activeTarget)
        pEvalActive := true
        pEvalDir := activeDirection
        float pGapEdge = activeDirection == 1 ? activeGapTop : activeGapBottom
        pEvalEntry := pGapEdge
        pEvalStop := activeDefense

        float pStopDist = math.max(math.abs(pGapEdge - activeDefense), syminfo.mintick)
        float pRoomDist = math.max(math.abs(activeTarget - pGapEdge), syminfo.mintick)
        float pFollowDist = math.min(pStopDist, pRoomDist)
        pEvalTarget := pGapEdge + activeDirection * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

if hasActiveGap and showEventLabels
    if newGapEvent
        f_add_label(eventLabels, f_event_text("NEW", activeDirection, activeScore, false), activeDirection, activeDirection == 1 ? bullColor : bearColor, safeAtr, labelOffsetAtr, maxVisibleLabels, labelFontSizeInput)
        lastEventLabelBar := bar_index
    else if failedEvent or (eventCooldownOk and (readyEvent or watchEvent or defenseEvent))
        string eventState = failedEvent ? "FAILED" : readyEvent ? "READY" : watchEvent ? "WATCH" : "DEFENSE TEST"
        color eventColor = eventState == "READY" ? (activeDirection == 1 ? bullColor : bearColor) : eventState == "WATCH" ? accentColor : eventState == "DEFENSE TEST" ? neutralColor : bearColor
        f_add_label(eventLabels, f_event_text(eventState, activeDirection, activeScore, showLabelScore), activeDirection, eventColor, safeAtr, labelOffsetAtr, maxVisibleLabels, labelFontSizeInput)
        lastEventLabelBar := bar_index

bool contextState = activeState == "READY" or activeState == "WATCH" or activeState == "DEFENSE TEST"
bool contextDue = hasActiveGap and showContextLabels and contextState and not activeStale and not activeFailed and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
if contextDue
    string contextText = activeState == "READY" ? "PLAN READY | " + str.tostring(activeScore) : activeState == "WATCH" ? "BUILD WATCH" : "DEFENSE CHECK"
    color contextColor = activeState == "READY" ? (activeDirection == 1 ? bullColor : bearColor) : activeState == "WATCH" ? accentColor : neutralColor
    f_add_label(eventLabels, contextText, activeDirection, contextColor, safeAtr, labelOffsetAtr, maxVisibleLabels, labelFontSizeInput)
    lastContextLabelBar := bar_index

if confirmationOk
    previousState := activeState

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(activeScore, title = "Gap Continuation Score", color = f_state_color(activeState), display = display.data_window)
plot(activeFillRisk, title = "Gap Fill Risk", color = activeFillRisk >= failedFillRisk ? bearColor : neutralColor, display = display.data_window)
plot(obstacleRoomAtr, title = "Forward Room ATR", color = bullColor, display = display.data_window)
plot(gapAtr, title = "Gap Size ATR", color = accentColor, display = display.data_window)
plot(followRate, title = "Follow Rate", color = f_rate_color(followRate), display = display.data_window)
plot(holdRate, title = "Hold Rate", color = f_rate_color(holdRate), display = display.data_window)
plot(reactRate, title = "React Rate", color = f_rate_color(reactRate), display = display.data_window)
plot(flipRate, title = "Flip Rate", color = f_flip_color(flipRate), display = display.data_window)
plot(proofAmbiguous, title = "Ambiguous Proof Count", color = panelValueCol, display = display.data_window)
plot(activeDirection, title = "Active Gap Direction", color = accentColor, display = display.data_window)
plot(activeAcceptanceStreak, title = "Confirmed Acceptance Streak", color = bullColor, display = display.data_window)
plot(hasActiveGap ? activeGapAge : na, title = "Active Gap Age", color = panelValueCol, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "n/a"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "n/a"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "n/a"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "n/a"
color followColPanel = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelThemeInput)
color holdColPanel = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelThemeInput)
color reactColPanel = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelThemeInput)
color flipColPanel = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelThemeInput)

int panelRowCount = showProof ? 12 : 7
color dashBg = f_panel_bg(panelThemeInput)
color dashBorder = f_panel_border(panelThemeInput)
var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastProofMode = false

panelNeedsReset = showPanel and (na(panel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or panelFontSizeInput != lastPanelSize or showProof != lastProofMode)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = dashBg, frame_color = dashBorder, frame_width = 1, border_color = dashBorder, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Gap Continuation Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput))
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelSize := panelFontSizeInput
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Gap Continuation Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)

    string panelState = hasActiveGap ? f_direction_text(activeDirection) + " / " + f_state_display(activeState) : "NO GAP"
    string scoreText = hasActiveGap ? str.tostring(activeScore) + " / 100" : "n/a"
    string defenseText = hasActiveGap ? f_price(activeDefense) : "n/a"
    string fillText = hasActiveGap ? f_percent(activeFillRisk) + " / " + f_fill_tier(activeFillRisk) : "n/a"
    string roomText = hasActiveGap ? str.tostring(obstacleRoomAtr, "#.00") + " ATR" : "n/a"
    string actionText = hasActiveGap ? f_action_text(activeState) + " | " + f_best_view_text(activeState, activeFillRisk, obstacleRoomAtr) : "WAIT CLEAN GAP"
    color stateColor = hasActiveGap ? f_state_color(activeState) : f_panel_value(panelThemeInput)
    color fillColor = activeFillRisk >= failedFillRisk ? bearColor : activeFillRisk >= 55.0 ? neutralColor : f_panel_value(panelThemeInput)

    f_set_row(panel, 1, "Gap State", panelState, stateColor, panelThemeInput, panelFontSizeInput)
    f_set_row(panel, 2, "Continuation Score", scoreText, stateColor, panelThemeInput, panelFontSizeInput)
    f_set_row(panel, 3, "Defense Line", defenseText, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
    f_set_row(panel, 4, "Fill Risk", fillText, fillColor, panelThemeInput, panelFontSizeInput)
    f_set_row(panel, 5, "Forward Room", roomText, obstacleRoomAtr >= 1.0 ? bullColor : neutralColor, panelThemeInput, panelFontSizeInput)
    f_set_row(panel, 6, "Action", actionText, stateColor, panelThemeInput, panelFontSizeInput)
    if showProof
        color proofHeadBg = f_row_bg(panelThemeInput, 7)
        table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_left)
        table.cell(panel, 1, 7, proofSampleText, text_color = f_panel_label(panelThemeInput), bgcolor = proofHeadBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_right)
        f_set_row(panel, 8, "Follow Rate", followTextPanel, followColPanel, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 9, "Hold Rate", holdTextPanel, holdColPanel, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 10, "React Rate", reactTextPanel, reactColPanel, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 11, "Flip Rate", flipTextPanel, flipColPanel, panelThemeInput, panelFontSizeInput)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertGapStates and newGapEvent, title = "GCP | New Gap Attention Marker", message = "Gap Continuation Planner: NEW GAP attention marker. Review the active gap zone, defense line, and broader market context.")
alertcondition(alertGapStates and readyEvent, title = "GCP | Plan Ready Attention Marker", message = "Gap Continuation Planner: PLAN READY attention marker. Review continuation score, fill risk, and forward room context.")
alertcondition(alertGapStates and watchEvent, title = "GCP | Build Watch Attention Marker", message = "Gap Continuation Planner: BUILD WATCH attention marker. Review acceptance quality and follow-through context.")
alertcondition(alertGapStates and defenseEvent, title = "GCP | Defense Check Attention Marker", message = "Gap Continuation Planner: DEFENSE CHECK attention marker. Review the gap defense area and fill-risk context.")
alertcondition(alertGapStates and failedEvent, title = "GCP | Acceptance Lost Attention Marker", message = "Gap Continuation Planner: ACCEPTANCE LOST attention marker. Review whether the active gap still belongs in the current plan.")
````
