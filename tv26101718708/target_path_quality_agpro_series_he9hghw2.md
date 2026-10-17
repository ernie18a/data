# Target Path Quality [AGPro Series]

- url: https://www.tradingview.com/script/HE9HgHw2-Target-Path-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;ac97acf349ae4aac8e8557e47920bf02
- version: 4.0

## Description

Target Path Quality [AGPro Series]

🧠 Core Idea

Is the path toward the next practical target reference clean, blocked, or too risky to review?


📌 Overview / What it does

Target Path Quality [AGPro Series] is a chart-first target path planning tool built to evaluate the route between current price and a practical target reference.

Instead of drawing a target and implying certainty, the script studies the path itself. It maps a forward path corridor, recent structure blockers, target room, invalidation context, a 0-100 Path Quality score, state labels, alerts, and a clean AGPro decision panel.

It does not predict that a target will be reached, automate execution, print buy/sell commands, or replace broader market context. Its purpose is to help traders judge whether the route toward a target is clean enough to deserve attention.


🎯 Purpose & Design Philosophy

This script was built for traders who already have a directional idea but need a cleaner way to evaluate the target path before focusing on execution.

Many tools draw target levels, projection zones, or take-profit ladders. Those visuals can be useful, but they often skip the more important question: what is between current price and the target?

Target Path Quality fills that gap by converting path cleanliness, blockers, risk edge, target room, volatility fit, and reaction history into one readable decision workflow.


⚡ Why This Script Is Different

Most tools focus on where price could go.

This script does NOT promise a target hit, build a take-profit ladder, or behave like a projection suite.

Instead, it asks whether the route toward the target reference is structurally clean, blocked by recent pivots, too close to justify attention, or too exposed to invalidation risk.


⚙️ Methodology

1. Context Detection
The engine identifies the active path side using EMA context or the user-selected directional mode.

2. Reference Mapping
The script maps a practical target reference, an invalidation review rail, and a forward path corridor.

3. Reaction Evaluation
It evaluates structure blockers, target-room distance, risk edge, trend support, volatility fit, and recent directional reaction history.

4. Visual Output
The result is shown through a centered path corridor label, blocker markers, target/invalidation rails, compact event labels, deterministic alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Path Corridor = the active review route between current price and the practical target reference. Its label is centered inside the corridor.

Blocker Markers = recent confirmed pivots sitting inside the path. These represent possible structural obstacles.

Target Rail = the practical target reference used for path-quality review. It is not a guaranteed destination.

Invalidation Rail = the risk edge behind the active path. It is an analytical reference, not a stop recommendation.

Labels = compact state markers such as PATH READY, WATCH PATH, BLOCKED PATH, TARGET REVIEW, or INVALID REVIEW.

Colors = teal supports cleaner long-side path quality, pink supports short-side or risk context, amber marks blocker/review states, and indigo marks target-reference context.

Panel = summarizes Path Quality, Blockers, Target Room, Risk Edge, and Action.


🚦 Signals & States

• PATH READY → the path quality score is strong, target room is acceptable, and blockers are limited.

• WATCH PATH → the route is improving but does not meet the strongest review conditions.

• BLOCKED PATH → one or more structure blockers reduce route cleanliness.

• TARGET REVIEW → price has reached the active target reference area and context should be reviewed.

• INVALID REVIEW → price crossed the active invalidation rail and the path should be reassessed.

• WAIT → the current route does not provide enough path quality for active review.


🔔 Alerts Logic

Alerts can trigger when the path becomes ready, enters watch mode, becomes blocked, reaches the target reference review area, or crosses the invalidation review rail.

Each alert is an attention marker. Alerts are not trade instructions, entry commands, exit commands, or automated strategy rules.


🧩 Confluence Logic

Path quality improves when target room is practical, blockers are limited, EMA context supports the active side, volatility is neither too quiet nor overheated, and recent candles show directional reaction history.

When these elements align, the route becomes cleaner. When blockers or invalidation risk rise, the route becomes weaker.


📊 When to Use

• When reviewing a directional setup that already has a target idea

• During breakout continuation review

• During pullback continuation planning

• When comparing whether target room is clean or structurally blocked

• When a trader wants target context without a promise-based target tool


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy ranges where pivots form too frequently

• News-driven volatility spikes

• Markets where target references are too close to current price

• Situations where broader context contradicts the active path


🎛️ Key Inputs

• Path Side → controls whether the script evaluates Auto, Long Path, or Short Path context.

• Sensitivity → changes pivot strictness and blocker selectivity.

• Target Path Lookback → controls how far back the script searches for target references and blockers.

• Minimum / Ideal / Maximum Target Room ATR → controls how target room affects the score.

• Max Clean Path Blockers → defines how many blockers are tolerated before the path becomes blocked.

• Label and panel settings → control visibility, location, theme, and font sizes.


🖥️ Interface & Visual Design

The panel follows the AGPro public-release standard with one merged blue header row containing only the panel title.

The chart is designed to stay active without becoming crowded. It uses one main path corridor, up to three blocker markers, target and invalidation rails, and controlled state labels.

Label and panel font sizes are adjustable, with Normal as the default.


🧪 Practical Usage Workflow

1. Read the panel Path Quality score.

2. Check whether blockers appear inside the path corridor.

3. Compare target room against the invalidation rail.

4. Review whether the action state says Path review, Track path, Clear blockers, Review target, or Review risk.

5. Confirm the broader market context before making any independent decision.


🔍 Interpretation Guidelines

A clean path does not mean price must reach the target reference.

A blocked path does not mean price cannot continue.

The script is best read as a route-quality filter. It helps organize whether the path is clean, obstructed, risky, or ready for review.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto trading system

• Not guaranteed signals

• Not a take-profit ladder

• Not a promise that price will reach any target


⚠️ Limitations & Transparency

Target path quality can change quickly when volatility expands, pivots update, or price crosses a key reference.

Different timeframes may produce different blocker structures and target-room readings.

Low-liquidity or high-noise markets can create unstable path evaluations.


🧠 Market Context Notes

Target path analysis is strongest when combined with liquidity, structure, volatility, and trend context.

A route can look attractive by distance but still become lower quality when recent pivots block the path or the invalidation rail is too exposed.


🧾 Use Case Examples

When price trends upward and the path to the next swing reference is open, the script may show PATH READY.

When a recent pivot high sits between current price and the target reference, the script may show BLOCKED PATH.

When price reaches the target reference rail, the script may show TARGET REVIEW.

When price crosses the invalidation rail behind the path, the script may show INVALID REVIEW.


🧱 System Philosophy

AGPro Series tools are designed to support structured decision review, not emotional signal chasing.

Target Path Quality follows that philosophy by focusing on route cleanliness, blocker context, risk edge, and next-action state instead of a simple directional signal.


🔐 Non-Promise Statement

No target reference is certain.

No path score guarantees continuation.

No alert should be treated as a trade instruction.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, position sizing, risk controls, and market interpretation.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use this tool to study how target path quality changes as blockers appear, target room expands or contracts, and invalidation risk shifts.

The strongest value comes from comparing the path corridor, blocker markers, risk rail, and broader market context together.

## Source Code

````pine
// -------------------------------------------------
// Target Path Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Target Path Quality is a chart-first target path planning engine that
// evaluates whether the route toward a practical target reference is clean,
// blocked, risky, or ready for review. It maps path corridor quality,
// structure blockers, target room, invalidation context, a self-measured path
// follow-through rate, and next-action state without promising target hits or
// becoming a take-profit ladder.
// -------------------------------------------------

//@version=6
indicator("Target Path Quality [AGPro Series]",
     shorttitle = "AG Pro TPQ",
     overlay = true,
     max_boxes_count = 50,
     max_labels_count = 220,
     max_lines_count = 120)

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
color dangerColor   = color.rgb(239, 68, 68)
color targetBlue    = color.rgb(59, 130, 246)
color darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_SIDE = "Selects which target path the planner evaluates. Auto follows the active trend context, while directional modes restrict the engine to one side."
const string TT_SENS = "Controls pivot strictness and blocker selectivity. Responsive reacts faster, Balanced is the publication default, and Strict requires cleaner structure."
const string TT_ATR = "ATR normalizes target room, invalidation distance, blocker proximity, label offsets, and volatility scoring across symbols."
const string TT_BASE = "Longer ATR baseline used to judge whether current volatility is too quiet, constructive, or overheated."
const string TT_LOOKBACK = "Lookback used to search for practical target references and structure blockers in the active path direction."
const string TT_PIVOT = "Confirmed pivot strength used to store blocker references. This is not a support/resistance map; it is a compact path obstacle memory."
const string TT_MEMORY = "Maximum number of confirmed pivot obstacles retained by the planner. Lower values reduce historical memory and object work."
const string TT_INVALID = "Lookback used to locate the active invalidation reference behind the current path. This reference is analytical, not a stop instruction."
const string TT_FAST = "Fast EMA used for automatic side selection and trend support scoring. It does not create standalone buy or sell signals."
const string TT_SLOW = "Slow EMA used for broader path context and trend support scoring."
const string TT_CONFIRM = "Close Confirmed waits for closed bars before labels and alerts update. Realtime Allowed updates faster but can change before bar close."
const string TT_MIN_ROOM = "Minimum target-room distance in ATR units. Very close target references usually reduce planning value."
const string TT_IDEAL_ROOM = "Preferred target-room distance in ATR units for the strongest room score."
const string TT_MAX_ROOM = "Maximum target-room distance in ATR units before the path becomes too stretched for the highest score."
const string TT_RISK_BUFFER = "ATR padding beyond the invalidation reference. This creates a practical review rail behind the active path."
const string TT_NEAR_BLOCK = "Distance in ATR at which the nearest blocker becomes a close-path concern."
const string TT_MAX_BLOCK = "Maximum blocker count allowed before the route becomes a blocked path state."
const string TT_READY = "Minimum 0-100 Path Quality required for PATH READY. This is an attention state, not a trade instruction."
const string TT_WATCH = "Minimum 0-100 Path Quality required for WATCH PATH."
const string TT_PROOF = "After a PATH READY upgrade, the planner waits this many bars (or until the invalidation rail is touched) and checks whether price advanced toward the target. Feeds the Path Hit Rate as a directional follow-through measure."
const string TT_EMA_SHOW = "Shows or hides the EMA anchors used for context scoring."
const string TT_CORRIDOR = "Shows the active path corridor between current price and the practical target reference. The label is centered inside the corridor."
const string TT_BLOCKERS = "Shows the nearest current structure blocker inside the active path. This is an obstacle marker, not a generic support/resistance zone."
const string TT_RAILS = "Shows the target reference and invalidation review rail."
const string TT_RAIL_BADGES = "Shows filled ownership badges at the right edge of the active target and risk rails so no projected reference is left unidentified."
const string TT_PROJ = "Number of bars projected to the right for the path corridor, blocker lines, and reference rails."
const string TT_ZONE = "Transparency for the path corridor. Higher values make the corridor lighter."
const string TT_LABELS = "Shows compact PATH READY, WATCH PATH, BLOCKED PATH, TARGET REVIEW, and INVALID REVIEW labels with controlled spacing."
const string TT_CONTEXT = "Adds sparse ongoing path-check labels so public screenshots remain informative without crowding candles."
const string TT_SCORE_LABEL = "Adds the 0-100 Path Quality score to chart labels."
const string TT_DETAIL_LABEL = "Adds blocker and room details to labels. Disabled by default to keep the chart clean."
const string TT_COOLDOWN = "Minimum bars between event labels. Higher values reduce clustering."
const string TT_CONTEXT_SPACE = "Minimum bars between sparse context labels during ongoing path review."
const string TT_MAX_LABELS = "Maximum number of visible chart labels retained by the script. Older labels are removed first for performance."
const string TT_OFFSET = "ATR-based vertical offset that keeps labels above or below candles."
const string TT_LANE = "Adds vertical spacing between nearby chart labels so clustered state labels separate cleanly without reducing how many labels appear."
const string TT_LABEL_SIZE = "Controls all chart labels, blocker labels, and centered corridor labels. Normal is the recommended public-release default."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between AGPro dark, slate, and clean light themes while preserving the blue merged header row."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_ALERT_SCORE = "Minimum Path Quality required before ready and watch alert conditions can trigger."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Target Path Engine"
string sideMode = input.string("Auto", "Path Side", options = ["Auto", "Long Path", "Short Path"], group = groupEngine, tooltip = TT_SIDE)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int atrBaselineLength = input.int(55, "ATR Baseline Length", minval = 10, maxval = 300, group = groupEngine, tooltip = TT_BASE)
int targetLookback = input.int(90, "Target Path Lookback", minval = 20, maxval = 400, group = groupEngine, tooltip = TT_LOOKBACK)
int pivotLength = input.int(5, "Structure Pivot Strength", minval = 2, maxval = 30, group = groupEngine, tooltip = TT_PIVOT)
int obstacleMemory = input.int(48, "Blocker Memory Levels", minval = 10, maxval = 100, group = groupEngine, tooltip = TT_MEMORY)
int invalidationLookback = input.int(34, "Invalidation Lookback", minval = 8, maxval = 220, group = groupEngine, tooltip = TT_INVALID)
int fastEmaLength = input.int(21, "Fast Context EMA", minval = 2, maxval = 200, group = groupEngine, tooltip = TT_FAST)
int slowEmaLength = input.int(55, "Slow Context EMA", minval = 3, maxval = 300, group = groupEngine, tooltip = TT_SLOW)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Realtime Allowed"], group = groupEngine, tooltip = TT_CONFIRM)

string groupScoring = "Path Quality Model"
float minRoomAtr = input.float(0.95, "Minimum Target Room ATR", minval = 0.20, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = TT_MIN_ROOM)
float idealRoomAtr = input.float(2.35, "Ideal Target Room ATR", minval = 0.50, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = TT_IDEAL_ROOM)
float maxRoomAtr = input.float(5.20, "Maximum Practical Room ATR", minval = 1.00, maxval = 14.00, step = 0.10, group = groupScoring, tooltip = TT_MAX_ROOM)
float invalidationBufferAtr = input.float(0.24, "Invalidation Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = TT_RISK_BUFFER)
float nearBlockerAtr = input.float(1.10, "Near Blocker Distance ATR", minval = 0.20, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = TT_NEAR_BLOCK)
int maxCleanBlockers = input.int(1, "Max Clean Path Blockers", minval = 0, maxval = 6, group = groupScoring, tooltip = TT_MAX_BLOCK)
int readyThreshold = input.int(70, "PATH READY Threshold", minval = 40, maxval = 95, group = groupScoring, tooltip = TT_READY)
int watchThreshold = input.int(54, "WATCH PATH Threshold", minval = 20, maxval = 90, group = groupScoring, tooltip = TT_WATCH)
int proofWindowBars = input.int(10, "Path Proof Window", minval = 2, maxval = 80, group = groupScoring, tooltip = TT_PROOF)

string groupVisual = "Chart Visuals"
bool showEmaAnchors = input.bool(false, "Show EMA Anchors", group = groupVisual, tooltip = TT_EMA_SHOW)
bool showPathCorridor = input.bool(true, "Show Path Corridor", group = groupVisual, tooltip = TT_CORRIDOR)
bool showBlockerMarkers = input.bool(true, "Show Blocker Markers", group = groupVisual, tooltip = TT_BLOCKERS)
bool showReferenceRails = input.bool(true, "Show Target / Invalidation Rails", group = groupVisual, tooltip = TT_RAILS)
bool showReferenceBadges = input.bool(true, "Show Reference Rail Badges", group = groupVisual, tooltip = TT_RAIL_BADGES)
int projectionBars = input.int(42, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJ)
int zoneTransparency = input.int(88, "Corridor Transparency", minval = 72, maxval = 96, group = groupVisual, tooltip = TT_ZONE)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = TT_LABELS)
bool showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = TT_CONTEXT)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = TT_SCORE_LABEL)
bool showLabelDetails = input.bool(false, "Show Label Details", group = groupLabels, tooltip = TT_DETAIL_LABEL)
int labelCooldownBars = input.int(14, "Event Label Cooldown", minval = 1, maxval = 120, group = groupLabels, tooltip = TT_COOLDOWN)
int contextSpacingBars = input.int(44, "Context Label Spacing", minval = 6, maxval = 180, group = groupLabels, tooltip = TT_CONTEXT_SPACE)
int maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = TT_MAX_LABELS)
float labelOffsetAtr = input.float(0.85, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = TT_OFFSET)
float labelLaneSpreadAtr = input.float(0.75, "Label Lane Spread ATR", minval = 0.30, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = TT_LANE)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupLabels, tooltip = TT_LABEL_SIZE)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(62, "Minimum Alert Score", minval = 30, maxval = 95, group = groupAlerts, tooltip = TT_ALERT_SCORE)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_norm_high_good(float value, float weakValue, float strongValue) =>
    float span = math.max(strongValue - weakValue, 0.000001)
    f_clamp((value - weakValue) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float strongValue, float weakValue) =>
    float span = math.max(weakValue - strongValue, 0.000001)
    f_clamp((weakValue - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
    result

f_text_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_pos(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_grade(float scoreValue) =>
    string grade = "D"
    if scoreValue >= 86
        grade := "A+"
    else if scoreValue >= 76
        grade := "A"
    else if scoreValue >= 64
        grade := "B"
    else if scoreValue >= 52
        grade := "C"
    grade

f_short_state(string stateText) =>
    switch stateText
        "PATH READY" => "READY"
        "WATCH PATH" => "WATCH"
        "BLOCKED PATH" => "BLOCKED"
        "TARGET REVIEW" => "TARGET REVIEW"
        "INVALID REVIEW" => "RISK REVIEW"
        => stateText

f_score_color(float scoreValue) =>
    color result = dangerColor
    if scoreValue >= 76
        result := bullColor
    else if scoreValue >= 64
        result := accentColor
    else if scoreValue >= 52
        result := neutralColor
    result

f_side_color(int dir) =>
    dir == 1 ? bullColor : bearColor

f_state_color(string stateText, int dir, float scoreValue) =>
    color result = f_score_color(scoreValue)
    if stateText == "PATH READY"
        result := f_side_color(dir)
    else if stateText == "TARGET REVIEW"
        result := targetBlue
    else if stateText == "BLOCKED PATH"
        result := neutralColor
    else if stateText == "INVALID REVIEW"
        result := dangerColor
    result

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(245, 247, 250) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label_color() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value_color() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(bool evenRow) =>
    if panelTheme == "Clean Light"
        evenRow ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)
    else if panelTheme == "Slate"
        evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string fontInput) =>
    color rowBg = f_row_bg(row % 2 == 0)
    table.cell(target, 0, row, leftText, text_color = f_panel_label_color(), bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_right)

f_trim_levels(array<float> levels, array<int> bars, int maxCount) =>
    while array.size(levels) > maxCount
        array.pop(levels)
        array.pop(bars)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_clear_lines(array<line> lines) =>
    while array.size(lines) > 0
        line oldLine = array.pop(lines)
        line.delete(oldLine)

f_clear_labels(array<label> labels) =>
    while array.size(labels) > 0
        label oldLabel = array.pop(labels)
        label.delete(oldLabel)

f_add_label(array<label> labels, int x, float y, string labelText, bool upStyle, color bgColor, string sizeText, int maxCount) =>
    label newLabel = label.new(x = x, y = y, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = upStyle ? label.style_label_up : label.style_label_down, color = color.new(bgColor, 8), textcolor = f_text_on(bgColor), size = f_text_size(sizeText), textalign = text.align_center)
    array.push(labels, newLabel)
    f_trim_labels(labels, maxCount)

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
bool confirmReady = confirmationMode == "Realtime Allowed" or barstate.isconfirmed
int sensitivityPivotAdj = sensitivity == "Responsive" ? -1 : sensitivity == "Strict" ? 2 : 0
int activePivotLength = math.max(2, pivotLength + sensitivityPivotAdj)

float atrValue = ta.atr(atrLength)
float safeAtr = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atrValue, atrBaselineLength)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? safeAtr / atrBase : 1.0

float emaFast = ta.ema(close, fastEmaLength)
float emaSlow = ta.ema(close, slowEmaLength)
float emaSlope = (emaFast - nz(emaFast[5], emaFast)) / safeAtr

float pivotHigh = ta.pivothigh(high, activePivotLength, activePivotLength)
float pivotLow = ta.pivotlow(low, activePivotLength, activePivotLength)

var array<float> highBlockers = array.new_float()
var array<int> highBlockerBars = array.new_int()
var array<float> lowBlockers = array.new_float()
var array<int> lowBlockerBars = array.new_int()

if not na(pivotHigh)
    array.unshift(highBlockers, pivotHigh)
    array.unshift(highBlockerBars, bar_index - activePivotLength)
    f_trim_levels(highBlockers, highBlockerBars, obstacleMemory)

if not na(pivotLow)
    array.unshift(lowBlockers, pivotLow)
    array.unshift(lowBlockerBars, bar_index - activePivotLength)
    f_trim_levels(lowBlockers, lowBlockerBars, obstacleMemory)

bool autoLong = emaFast >= emaSlow and close >= emaFast
bool autoShort = emaFast <= emaSlow and close <= emaFast
int autoSide = autoLong ? 1 : autoShort ? -1 : close >= emaSlow ? 1 : -1
int pathSide = sideMode == "Long Path" ? 1 : sideMode == "Short Path" ? -1 : autoSide

float highestPath = ta.highest(high[1], targetLookback)
float lowestPath = ta.lowest(low[1], targetLookback)
float pivotTarget = na

if pathSide == 1
    int highCount = array.size(highBlockers)
    if highCount > 0
        for idx = 0 to highCount - 1
            float level = array.get(highBlockers, idx)
            int levelBar = array.get(highBlockerBars, idx)
            bool levelInRange = bar_index - levelBar <= targetLookback and level > close + safeAtr * 0.20
            if levelInRange and (na(pivotTarget) or level < pivotTarget)
                pivotTarget := level
else
    int lowCount = array.size(lowBlockers)
    if lowCount > 0
        for idx = 0 to lowCount - 1
            float level = array.get(lowBlockers, idx)
            int levelBar = array.get(lowBlockerBars, idx)
            bool levelInRange = bar_index - levelBar <= targetLookback and level < close - safeAtr * 0.20
            if levelInRange and (na(pivotTarget) or level > pivotTarget)
                pivotTarget := level

float rawTarget = pathSide == 1 ? nz(pivotTarget, nz(highestPath, close + safeAtr * idealRoomAtr)) : nz(pivotTarget, nz(lowestPath, close - safeAtr * idealRoomAtr))
float targetReference = pathSide == 1 ? math.max(rawTarget, close + safeAtr * minRoomAtr) : math.min(rawTarget, close - safeAtr * minRoomAtr)

float invalidBase = pathSide == 1 ? nz(ta.lowest(low[1], invalidationLookback), close - safeAtr * 2.0) : nz(ta.highest(high[1], invalidationLookback), close + safeAtr * 2.0)
float invalidationRef = pathSide == 1 ? invalidBase - safeAtr * invalidationBufferAtr : invalidBase + safeAtr * invalidationBufferAtr

int blockerCount = 0
float nearestBlocker = na
int nearestBlockerBar = na

if pathSide == 1
    int highCount = array.size(highBlockers)
    if highCount > 0
        for idx = 0 to highCount - 1
            float level = array.get(highBlockers, idx)
            int levelBar = array.get(highBlockerBars, idx)
            bool insidePath = bar_index - levelBar <= targetLookback and level > close and level < targetReference
            if insidePath
                blockerCount += 1
                if na(nearestBlocker) or level < nearestBlocker
                    nearestBlocker := level
                    nearestBlockerBar := levelBar
else
    int lowCount = array.size(lowBlockers)
    if lowCount > 0
        for idx = 0 to lowCount - 1
            float level = array.get(lowBlockers, idx)
            int levelBar = array.get(lowBlockerBars, idx)
            bool insidePath = bar_index - levelBar <= targetLookback and level < close and level > targetReference
            if insidePath
                blockerCount += 1
                if na(nearestBlocker) or level > nearestBlocker
                    nearestBlocker := level
                    nearestBlockerBar := levelBar

float targetRoomAtr = math.abs(targetReference - close) / safeAtr
float riskDistanceAtr = math.abs(close - invalidationRef) / safeAtr
float rrContext = riskDistanceAtr > 0.0 ? targetRoomAtr / riskDistanceAtr : 0.0
float nearestBlockerAtr = na(nearestBlocker) ? na : math.abs(nearestBlocker - close) / safeAtr

float roomDistanceScore = f_peak_score(targetRoomAtr, minRoomAtr, idealRoomAtr, maxRoomAtr)
float roomRiskScore = f_norm_high_good(rrContext, 0.55, 1.70)
float roomScore = f_clamp(roomDistanceScore * 0.72 + roomRiskScore * 0.28, 0.0, 100.0)

float nearPenalty = na(nearestBlockerAtr) ? 0.0 : nearestBlockerAtr < nearBlockerAtr ? (nearBlockerAtr - nearestBlockerAtr) / nearBlockerAtr * 28.0 : 0.0
float blockerScore = f_clamp(100.0 - blockerCount * 18.0 - nearPenalty, 0.0, 100.0)

float trendBase = pathSide == 1 ? (emaFast > emaSlow ? 48.0 : 20.0) : (emaFast < emaSlow ? 48.0 : 20.0)
float closeScore = pathSide == 1 ? (close > emaFast ? 28.0 : close > emaSlow ? 15.0 : 0.0) : (close < emaFast ? 28.0 : close < emaSlow ? 15.0 : 0.0)
float slopeScore = pathSide == 1 ? f_norm_high_good(emaSlope, -0.10, 0.30) * 0.24 : f_norm_high_good(-emaSlope, -0.10, 0.30) * 0.24
float trendScore = f_clamp(trendBase + closeScore + slopeScore, 0.0, 100.0)

float volatilityScore = f_peak_score(atrRatio, 0.55, 1.05, 2.35)

int directionalBars = 0
for look = 0 to 8
    bool validBar = not na(close[look]) and not na(open[look])
    if validBar
        bool alignedBar = pathSide == 1 ? close[look] > open[look] : close[look] < open[look]
        directionalBars += alignedBar ? 1 : 0
float reactionScore = f_norm_high_good(directionalBars, 2.0, 6.0)

float pathQualityRaw = blockerScore * 0.30 + roomScore * 0.25 + trendScore * 0.20 + volatilityScore * 0.15 + reactionScore * 0.10
int pathQuality = int(math.round(f_clamp(pathQualityRaw, 0.0, 100.0)))

bool invalidReview = pathSide == 1 ? close <= invalidationRef : close >= invalidationRef
bool targetReview = pathSide == 1 ? high >= targetReference : low <= targetReference
bool closeBlocker = not na(nearestBlockerAtr) and nearestBlockerAtr <= nearBlockerAtr
bool blockedPath = blockerCount > maxCleanBlockers or closeBlocker
bool roomConstrained = targetRoomAtr <= minRoomAtr or rrContext < 0.55
bool readyPath = not invalidReview and not targetReview and not blockedPath and pathQuality >= readyThreshold and roomScore >= 50.0
bool watchPath = not invalidReview and not targetReview and pathQuality >= watchThreshold

string pathState = "WAIT"
if invalidReview
    pathState := "INVALID REVIEW"
else if targetReview
    pathState := "TARGET REVIEW"
else if readyPath
    pathState := "PATH READY"
else if blockedPath and watchPath
    pathState := "BLOCKED PATH"
else if watchPath
    pathState := "WATCH PATH"

string actionText = "Wait"
if invalidReview
    actionText := "Review risk"
else if targetReview
    actionText := "Review target"
else if readyPath
    actionText := "Path review"
else if blockedPath
    actionText := watchPath ? "Clear blockers" : "Avoid path"
else if watchPath and roomConstrained
    actionText := "Review tight room"
else if watchPath
    actionText := "Monitor path"

color sideColor = f_side_color(pathSide)
color stateColor = f_state_color(pathState, pathSide, pathQuality)

// -------------------------------------------------
// Path Hit Rate (Proof Pass)
// -------------------------------------------------
// On each PATH READY upgrade, capture direction, entry, and invalidation rail.
// The path resolves as a miss if the invalidation rail is touched first;
// otherwise, after the proof window, it is a hit when price advanced toward the
// target. This measures directional follow-through (stop-aware), consistent with
// the attention-state design rather than a take-profit backtest.
var int pathProofHits = 0
var int pathProofTotal = 0
var bool pathProofPending = false
var int pathProofStart = na
var int pathProofDir = 0
var float pathProofEntry = na
var float pathProofInval = na

bool readyRising = confirmReady and pathState == "PATH READY" and pathState[1] != "PATH READY"

if confirmReady
    if readyRising and not pathProofPending
        pathProofPending := true
        pathProofStart := bar_index
        pathProofDir := pathSide
        pathProofEntry := close
        pathProofInval := invalidationRef
    if pathProofPending and not na(pathProofStart) and bar_index > pathProofStart
        bool stopHit = pathProofDir > 0 ? low <= pathProofInval : high >= pathProofInval
        if stopHit
            pathProofTotal += 1
            pathProofPending := false
        else if bar_index - pathProofStart >= proofWindowBars
            bool favorable = pathProofDir > 0 ? close > pathProofEntry : close < pathProofEntry
            pathProofTotal += 1
            if favorable
                pathProofHits += 1
            pathProofPending := false

float pathProofRate = pathProofTotal > 0 ? pathProofHits / pathProofTotal * 100.0 : na
string pathRateText = pathProofTotal > 0 ? str.tostring(int(math.round(pathProofRate))) + "% (" + str.tostring(pathProofHits) + "/" + str.tostring(pathProofTotal) + ")" : "Building"
color pathRateColor = pathProofTotal == 0 ? neutralColor : pathProofRate >= 60.0 ? bullColor : pathProofRate >= 45.0 ? neutralColor : dangerColor

// -------------------------------------------------
// Plots and Active Visuals
// -------------------------------------------------
plot(showEmaAnchors ? emaFast : na, "Fast Context EMA", color = color.new(accentColor, 48), linewidth = 1)
plot(showEmaAnchors ? emaSlow : na, "Slow Context EMA", color = color.new(panelLabelCol, 50), linewidth = 1)

var box pathBox = na
var label pathBoxLabel = na
var line targetLine = na
var line invalidationLine = na
var label targetRailBadge = na
var label invalidationRailBadge = na
var array<line> activeBlockerLines = array.new_line()
var array<label> activeBlockerLabels = array.new_label()

float corridorTop = math.max(close, targetReference)
float corridorBottom = math.min(close, targetReference)
float corridorMid = (corridorTop + corridorBottom) * 0.5
int renderRight = bar_index + projectionBars
int renderCenter = bar_index + int(math.round(projectionBars * 0.5))
string corridorText = "PATH " + str.tostring(pathQuality) + " " + f_grade(pathQuality) + "\n" + (blockerCount == 0 ? "CLEAR ROUTE" : str.tostring(blockerCount) + " BLOCKER" + (blockerCount == 1 ? "" : "S"))
string targetRailText = "TARGET REF  " + f_fmt_price(targetReference)
string invalidationRailText = "RISK EDGE  " + f_fmt_price(invalidationRef)

if barstate.islast
    if showPathCorridor
        if na(pathBox)
            pathBox := box.new(left = bar_index, top = corridorTop, right = renderRight, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(sideColor, zoneTransparency), border_color = color.new(sideColor, 32), border_width = 1)
        else
            box.set_left(pathBox, bar_index)
            box.set_right(pathBox, renderRight)
            box.set_top(pathBox, corridorTop)
            box.set_bottom(pathBox, corridorBottom)
            box.set_bgcolor(pathBox, color.new(sideColor, zoneTransparency))
            box.set_border_color(pathBox, color.new(sideColor, 32))
        if na(pathBoxLabel)
            pathBoxLabel := label.new(renderCenter, corridorMid, corridorText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 12), textcolor = f_text_on(stateColor), size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_x(pathBoxLabel, renderCenter)
            label.set_y(pathBoxLabel, corridorMid)
            label.set_text(pathBoxLabel, corridorText)
            label.set_color(pathBoxLabel, color.new(stateColor, 12))
            label.set_textcolor(pathBoxLabel, f_text_on(stateColor))
            label.set_size(pathBoxLabel, f_text_size(labelFontSize))
            label.set_style(pathBoxLabel, label.style_label_center)
    else
        if not na(pathBox)
            box.delete(pathBox)
            pathBox := na
        if not na(pathBoxLabel)
            label.delete(pathBoxLabel)
            pathBoxLabel := na

    if showReferenceRails
        if na(targetLine)
            targetLine := line.new(bar_index, targetReference, renderRight, targetReference, xloc = xloc.bar_index, color = color.new(targetBlue, 10), style = line.style_dashed, width = 1)
        else
            line.set_xy1(targetLine, bar_index, targetReference)
            line.set_xy2(targetLine, renderRight, targetReference)
            line.set_color(targetLine, color.new(targetBlue, 10))
        if na(invalidationLine)
            invalidationLine := line.new(bar_index, invalidationRef, renderRight, invalidationRef, xloc = xloc.bar_index, color = color.new(dangerColor, 12), style = line.style_dashed, width = 1)
        else
            line.set_xy1(invalidationLine, bar_index, invalidationRef)
            line.set_xy2(invalidationLine, renderRight, invalidationRef)
            line.set_color(invalidationLine, color.new(dangerColor, 12))
        if showReferenceBadges
            if na(targetRailBadge)
                targetRailBadge := label.new(renderRight, targetReference, targetRailText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(targetBlue, 0), textcolor = f_text_on(targetBlue), size = f_text_size(labelFontSize), textalign = text.align_center)
            else
                label.set_xy(targetRailBadge, renderRight, targetReference)
                label.set_text(targetRailBadge, targetRailText)
                label.set_color(targetRailBadge, color.new(targetBlue, 0))
                label.set_textcolor(targetRailBadge, f_text_on(targetBlue))
                label.set_size(targetRailBadge, f_text_size(labelFontSize))
            if na(invalidationRailBadge)
                invalidationRailBadge := label.new(renderRight, invalidationRef, invalidationRailText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = f_text_size(labelFontSize), textalign = text.align_center)
            else
                label.set_xy(invalidationRailBadge, renderRight, invalidationRef)
                label.set_text(invalidationRailBadge, invalidationRailText)
                label.set_color(invalidationRailBadge, color.new(bearColor, 0))
                label.set_textcolor(invalidationRailBadge, f_text_on(bearColor))
                label.set_size(invalidationRailBadge, f_text_size(labelFontSize))
        else
            if not na(targetRailBadge)
                label.delete(targetRailBadge)
                targetRailBadge := na
            if not na(invalidationRailBadge)
                label.delete(invalidationRailBadge)
                invalidationRailBadge := na
    else
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na
        if not na(invalidationLine)
            line.delete(invalidationLine)
            invalidationLine := na
        if not na(targetRailBadge)
            label.delete(targetRailBadge)
            targetRailBadge := na
        if not na(invalidationRailBadge)
            label.delete(invalidationRailBadge)
            invalidationRailBadge := na

    f_clear_lines(activeBlockerLines)
    f_clear_labels(activeBlockerLabels)
    if showBlockerMarkers
        int drawnBlockers = 0
        if pathSide == 1
            int highCount = array.size(highBlockers)
            if highCount > 0
                for idx = 0 to highCount - 1
                    float level = array.get(highBlockers, idx)
                    int levelBar = array.get(highBlockerBars, idx)
                    bool insidePath = bar_index - levelBar <= targetLookback and level > close and level < targetReference and drawnBlockers < 1
                    if insidePath
                        line blockerLine = line.new(bar_index, level, renderRight, level, xloc = xloc.bar_index, color = color.new(neutralColor, 48), style = line.style_dotted, width = 1)
                        label blockerLabel = label.new(renderRight, level, "BLOCKER", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_text_size(labelFontSize))
                        array.push(activeBlockerLines, blockerLine)
                        array.push(activeBlockerLabels, blockerLabel)
                        drawnBlockers += 1
        else
            int lowCount = array.size(lowBlockers)
            if lowCount > 0
                for idx = 0 to lowCount - 1
                    float level = array.get(lowBlockers, idx)
                    int levelBar = array.get(lowBlockerBars, idx)
                    bool insidePath = bar_index - levelBar <= targetLookback and level < close and level > targetReference and drawnBlockers < 1
                    if insidePath
                        line blockerLine = line.new(bar_index, level, renderRight, level, xloc = xloc.bar_index, color = color.new(neutralColor, 48), style = line.style_dotted, width = 1)
                        label blockerLabel = label.new(renderRight, level, "BLOCKER", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_text_size(labelFontSize))
                        array.push(activeBlockerLines, blockerLine)
                        array.push(activeBlockerLabels, blockerLabel)
                        drawnBlockers += 1

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
var array<label> eventLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var int lastAnyLabelBar = na
var int labelClusterLane = 0
int labelClusterWindow = math.max(6, int(math.round(labelCooldownBars * 0.6)))
var string priorState = ""

bool stateChanged = confirmReady and pathState != priorState
bool canEventLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool canContextLabel = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
bool farFromEvent = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool majorState = pathState == "PATH READY" or pathState == "BLOCKED PATH" or pathState == "TARGET REVIEW" or pathState == "INVALID REVIEW"
bool eventLabelNow = showEventLabels and confirmReady and canEventLabel and stateChanged and pathState != "WAIT" and (majorState or pathQuality >= watchThreshold)

if eventLabelNow
    string labelText = f_short_state(pathState)
    if showLabelScore
        labelText += "\nQ " + str.tostring(pathQuality)
    if showLabelDetails
        labelText += "\nRoom " + f_fmt(targetRoomAtr) + " ATR / B " + str.tostring(blockerCount)
    bool clusteredEvent = not na(lastAnyLabelBar) and bar_index - lastAnyLabelBar <= labelClusterWindow
    int eventLane = clusteredEvent ? math.min(labelClusterLane + 1, 2) : 0
    labelClusterLane := eventLane
    bool eventPrimaryAbove = pathSide == 1
    bool eventUseAbove = eventLane == 1 ? not eventPrimaryAbove : eventPrimaryAbove
    float eventLaneOffset = labelOffsetAtr + (eventLane >= 2 ? (eventLane - 1) * labelLaneSpreadAtr : 0.0)
    float labelY = eventUseAbove ? high + safeAtr * eventLaneOffset : low - safeAtr * eventLaneOffset
    bool upStyle = not eventUseAbove
    f_add_label(eventLabels, bar_index, labelY, labelText, upStyle, stateColor, labelFontSize, maxVisibleLabels)
    lastEventLabelBar := bar_index
    lastAnyLabelBar := bar_index

bool contextLabelNow = showContextLabels and confirmReady and canContextLabel and farFromEvent and not eventLabelNow and (pathState == "WATCH PATH" or pathState == "PATH READY" or pathState == "BLOCKED PATH") and pathQuality >= watchThreshold

if contextLabelNow
    string contextText = "PATH"
    if showLabelScore
        contextText += "\nQ " + str.tostring(pathQuality)
    bool clusteredContext = not na(lastAnyLabelBar) and bar_index - lastAnyLabelBar <= labelClusterWindow
    int contextLane = clusteredContext ? math.min(labelClusterLane + 1, 2) : 0
    labelClusterLane := contextLane
    bool contextPrimaryAbove = pathSide == 1
    bool contextUseAbove = contextLane == 1 ? not contextPrimaryAbove : contextPrimaryAbove
    float contextLaneOffset = labelOffsetAtr + (contextLane >= 2 ? (contextLane - 1) * labelLaneSpreadAtr : 0.0)
    float contextY = contextUseAbove ? high + safeAtr * contextLaneOffset : low - safeAtr * contextLaneOffset
    bool contextUpStyle = not contextUseAbove
    f_add_label(eventLabels, bar_index, contextY, contextText, contextUpStyle, stateColor, labelFontSize, maxVisibleLabels)
    lastContextLabelBar := bar_index
    lastAnyLabelBar := bar_index

if confirmReady
    priorState := pathState

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_panel_pos(panelLocation), 2, 8, bgcolor = f_panel_bg(), border_width = 1, frame_width = 1, border_color = f_panel_border(), frame_color = f_panel_border())

if barstate.islast
    table.set_position(panel, f_panel_pos(panelLocation))
    table.clear(panel, 0, 0, 1, 7)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Target Path Quality", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        string qualityText = str.tostring(pathQuality) + " / " + f_grade(pathQuality)
        string blockerText = blockerCount == 0 ? "Clear" : str.tostring(blockerCount) + " inside"
        string roomText = f_fmt(targetRoomAtr) + " ATR / R " + f_fmt(rrContext)
        string riskText = f_fmt_price(invalidationRef) + " / " + f_fmt(riskDistanceAtr) + " ATR"
        color actionColor = roomConstrained and watchPath ? neutralColor : stateColor
        f_panel_row(panel, 1, "Path State", pathState, stateColor, panelFontSize)
        f_panel_row(panel, 2, "Path Quality", qualityText, f_score_color(pathQuality), panelFontSize)
        f_panel_row(panel, 3, "Blockers", blockerText, blockerCount == 0 ? bullColor : blockerCount <= maxCleanBlockers ? neutralColor : dangerColor, panelFontSize)
        f_panel_row(panel, 4, "Target Room", roomText, roomScore >= 65 ? bullColor : roomScore >= 45 ? neutralColor : dangerColor, panelFontSize)
        f_panel_row(panel, 5, "Risk Edge", riskText, invalidReview ? dangerColor : f_panel_value_color(), panelFontSize)
        f_panel_row(panel, 6, "Path Hit Rate", pathRateText, pathRateColor, panelFontSize)
        f_panel_row(panel, 7, "Action", actionText, actionColor, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool readyAlert = confirmReady and pathState == "PATH READY" and pathQuality >= alertScoreThreshold and pathState[1] != "PATH READY"
bool watchAlert = confirmReady and pathState == "WATCH PATH" and pathQuality >= alertScoreThreshold and pathState[1] != "WATCH PATH"
bool blockedAlert = confirmReady and pathState == "BLOCKED PATH" and pathState[1] != "BLOCKED PATH"
bool targetAlert = confirmReady and pathState == "TARGET REVIEW" and pathState[1] != "TARGET REVIEW"
bool invalidAlert = confirmReady and pathState == "INVALID REVIEW" and pathState[1] != "INVALID REVIEW"

alertcondition(readyAlert, title = "Target Path Ready", message = "Target Path Quality: PATH READY attention marker.")
alertcondition(watchAlert, title = "Target Path Watch", message = "Target Path Quality: WATCH PATH attention marker.")
alertcondition(blockedAlert, title = "Target Path Blocked", message = "Target Path Quality: BLOCKED PATH attention marker.")
alertcondition(targetAlert, title = "Target Reference Review", message = "Target Path Quality: price reached the active target reference review area.")
alertcondition(invalidAlert, title = "Target Path Invalidation Review", message = "Target Path Quality: price crossed the active invalidation review rail.")
````
