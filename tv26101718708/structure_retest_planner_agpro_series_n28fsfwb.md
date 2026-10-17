# Structure Retest Planner [AGPro Series]

- url: https://www.tradingview.com/script/n28FSFWb-Structure-Retest-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;751209b1a0dc4375aa66b462b6452e95
- version: 4.0

## Description

Structure Retest Planner [AGPro Series]

🧠 Core Idea

Is the active structure retest being accepted, rejected, or invalidated?


📌 Overview / What it does

Structure Retest Planner [AGPro Series] is a structure-based trade planning overlay designed to help traders evaluate how price behaves when it returns to an important swing-derived structure rail.

The script maps the active support-side or resistance-side rail, draws a focused retest box around that rail, scores the retest from 0-100, and projects practical invalidation and target guides. The goal is to organize the retest decision process: structure state, score, acceptance, invalidation, and next action.

It does not predict the next move, does not automate trading, and does not turn every swing point into a generic support/resistance signal. It is a decision-support planner for reading acceptance and rejection around a live structure retest.


🎯 Purpose & Design Philosophy

This script was built for traders who use price structure but need a cleaner way to judge whether a retest deserves attention.

Most structure tools identify levels, breaks, or swing labels. Structure Retest Planner focuses on the next decision after a rail is present: is price responding cleanly enough, is invalidation nearby, and what should be reviewed next?

The design supports a planning mindset rather than a signal-chasing mindset. It is meant to make the chart easier to interpret while keeping the trader responsible for context and risk.


⚡ Why This Script Is Different

Most tools focus on plotting structure breaks, BOS / CHoCH labels, or broad support and resistance zones.

This script does NOT clone a BOS / CHoCH detector and does NOT duplicate a first-break retest grader.

Instead, it treats the active structure rail as a planning reference and evaluates acceptance, rejection, volatility fit, trend agreement, invalidation distance, and next-action state in one workflow.


⚙️ Methodology

1. Context Detection
The script confirms swing-derived structure rails using pivot logic and identifies whether the active planning side is support retest, resistance retest, or automatic nearest-rail context.

2. Reference Mapping
It draws a retest box around the active rail, plus an invalidation shelf and target guide. These are planning references, not guaranteed outcomes.

3. Reaction Evaluation
The 0-100 score combines level origin quality, retest response, close location, volatility fit, and trend agreement.

4. Visual Output
The script shows a centered retest-box label, compact event labels, rail/invalidation/target guides, alerts, and a premium AG Pro panel.


🗺️ How to Read the Chart

Zones = the active retest box around the selected structure rail.

Labels = watch, accepted, rejected, invalidated, or risk-review states with optional score and grade.

Colors = teal for support-side acceptance, pink for resistance-side or rejection pressure, yellow for review states, and indigo for planning context.

Panel = structure state, retest score, acceptance state, invalidation shelf, and next action.


🚦 Signals & States

• Retest Watch → price is close enough to the active rail and the score is improving.

• Accepted → price tested the rail and closed constructively on the expected side.

• Ready → acceptance is active and the score reached the ready threshold.

• Rejected → price tested the rail but did not show clean acceptance.

• Invalidated → price closed beyond the invalidation shelf.

• Risk Review → retest behavior exists, but volatility is too hot for clean reading.


🔔 Alerts Logic

Alerts trigger when the script detects a new watch state, accepted retest, high-quality retest review, rejected retest, or invalidation shelf break.

Alerts are attention markers. They are not trade instructions and should always be interpreted with broader market context.


🧩 Confluence Logic

The score improves when the active rail has a cleaner structural origin, price reacts near the rail, the close lands on the expected side, volatility is not overheated, and trend context agrees with the retest side.

When these factors align, the retest context becomes easier to review. When they conflict, the panel shifts toward waiting, context confirmation, risk review, or reset.


📊 When to Use

• Pullbacks toward confirmed swing structure

• Trend continuation retests

• Resistance retests after bearish structure pressure

• Support retests after bullish structure pressure

• Markets where structure rails are visible and not excessively noisy


⚠️ When NOT to Use

• Very low-liquidity symbols

• Extremely noisy sideways markets

• News-driven volatility spikes

• Markets where pivot structure is too compressed to provide useful rails

• Any situation where the user expects automated entry or exit instructions


🎛️ Key Inputs

• Retest Side → selects Auto, Support Retest, or Resistance Retest.

• Structure Pivot Length → controls how structure rails are confirmed.

• Sensitivity → changes retest-box width and activation behavior.

• Retest Ready Score → sets the minimum score for stronger review states.

• Invalidation Shelf ATR → adjusts the planning invalidation reference.

• Target Guide R Multiple → projects the forward target guide from planning risk.

• Label and Panel Font Size → controls visual readability.

• Panel Location and Theme → adjusts interface placement and style.


🖥️ Interface & Visual Design

The panel is built as a compact planning dashboard with one merged blue AG Pro header row and five decision rows.

The chart visuals are intentionally restrained: one active retest box, centered box text, structure rail, invalidation shelf, target guide, and controlled labels.

The design goal is to make the active retest decision readable without turning the chart into a dense support/resistance map.


🧪 Practical Usage Workflow

1. Read the panel to identify the active structure state.

2. Check whether price is approaching or testing the retest box.

3. Review the retest score and acceptance state.

4. Compare the invalidation shelf and target guide.

5. Use your own broader context before making any decision.


🔍 Interpretation Guidelines

A higher score means the retest is cleaner within the script's rule set. It does not mean price must continue.

Acceptance means the bar closed constructively relative to the rail. Rejection means the rail is not holding cleanly. Invalidation means the planning reference has been crossed and the setup should be reviewed again.

Use the script to organize thinking, not to outsource judgment.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a BOS / CHoCH auto detector

• Not a generic support/resistance zone map


⚠️ Limitations & Transparency

The script uses pivot-based structure, so rails appear only after pivots are confirmed.

Timeframe choice, volatility, liquidity, and symbol behavior can materially change how retests appear.

Fast markets may pass through a rail before the retest can be evaluated cleanly. Sideways markets may create repeated low-quality tests.


🧠 Market Context Notes

Structure retests are easier to interpret when liquidity, trend context, and volatility are aligned.

A clean rail is not enough on its own. The reaction, close location, invalidation distance, and broader environment all matter.


🧾 Use Case Examples

When price returns to a prior support rail and closes back above it with a strong lower wick, the planner may shift from watch to accepted if the score is high enough.

When price tests resistance but closes back below the rail with volatility under control, the planner may mark a cleaner resistance-side review state.

When price closes beyond the invalidation shelf, the planner marks the context as invalidated and the plan should be reset.


🧱 System Philosophy

Structure Retest Planner is part of the AGPro Series decision-engine direction: tools should help traders answer what is valid, how strong it is, where risk is, and what should be reviewed next.


🔐 Non-Promise Statement

No signal from this script guarantees continuation, reversal, or profit.

The output is a structured analytical read, not certainty.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk management, and decisions.

This script does not provide financial advice and does not guarantee trading outcomes.


📚 Educational Note

Use the planner to study how structure retests behave across symbols and timeframes, especially how acceptance, rejection, volatility, and invalidation interact.

## Source Code

````pine
// -------------------------------------------------
// Structure Retest Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Structure Retest Planner is a chart-first structure retest decision engine.
// It maps the active structure rail, watches the next retest area, scores
// acceptance or rejection quality from 0-100, tracks a real follow-through rate,
// and keeps every active rail, invalidation shelf, and target guide visually
// owned so traders can review context, risk, and next action without relying
// on generic or repeatedly printed signal markers.
// -------------------------------------------------

//@version=6
indicator("Structure Retest Planner [AGPro Series]",
     shorttitle = "AG Pro STR",
     overlay = true,
     max_labels_count = 220,
     max_boxes_count = 20,
     max_lines_count = 80)

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
color darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSide = "Selects the structure side to plan. Auto chooses the closest active rail while respecting trend context. Manual modes force support-side or resistance-side retest planning."
string ttPivot = "Pivot length used to confirm structure rails. Lower values react faster but can be noisier. Higher values require more developed swing structure."
string ttAge = "Maximum rail age used in the origin-quality score. Very old rails are still visible but receive a lower planning score."
string ttAtr = "ATR length used for retest-box thickness, invalidation shelves, target guides, volatility fit, and label spacing."
string ttTrendFast = "Fast EMA used for trend agreement scoring. It supports context only and does not create buy or sell signals."
string ttTrendSlow = "Slow EMA used for trend agreement scoring. Retest quality improves when the selected rail agrees with this broader context."
string ttSensitivity = "Controls how wide the retest box and activation zone are. Conservative is tighter, Balanced is standard, and Aggressive is wider."
string ttConfirm = "Close Confirmed waits for bar close before labels and alerts are printed. Live Updating lets the planner update during the active bar."
string ttActivation = "ATR distance from the active rail where the planner starts treating price as a retest candidate."
string ttZone = "ATR thickness around the structure rail used to draw the retest box. The centered box label stays inside this area."
string ttClose = "Minimum ATR-normalized close beyond the rail required for a cleaner acceptance read."
string ttInvalidation = "ATR distance beyond the rail used to project the invalidation shelf. It is a planning reference, not a stop recommendation."
string ttTarget = "R multiple used to project the target guide from the current planning risk distance. The nearest opposite rail may cap this guide."
string ttReady = "Minimum 0-100 score required for a stronger retest-review state. This is an attention filter, not a trade instruction."
string ttWatch = "Minimum 0-100 score required for a watch state before full acceptance is present."
string ttHot = "ATR ratio above this level is treated as unstable volatility. Hot conditions reduce the volatility-fit score."
string ttProofWindow = "Bars observed after an accepted retest to measure real follow-through toward the target side before the invalidation shelf is broken. Unresolved cases inside the window are left uncounted, never scored as a failure. Keep at or below Label Cooldown Bars."
string ttProofGoal = "Directional distance from the acceptance close that counts as confirmed follow-through."
string ttProofSamples = "Resolved accepted retests required before the follow-through rate is reported instead of a building state."
string ttBox = "Shows the active structure retest box around the selected rail. Its label is centered horizontally and vertically inside the box."
string ttRails = "Shows the selected structure rail and the invalidation shelf for retest planning."
string ttTargetGuide = "Shows a forward target guide derived from planning risk and the nearest opposite structure rail."
string ttForward = "Controls how many bars the retest box, rail, invalidation, and target guides extend to the right."
string ttZoneOpacity = "Transparency for the retest box. Higher values make the zone lighter."
string ttLabels = "Shows compact Retest Watch, Accepted, Rejected, Invalidated, and Risk Review labels with controlled spacing."
string ttEventMode = "Decision Events keeps the default chart focused on new accepted, ready, rejected, risk-review, and invalidated transitions. All States also includes the first watch transition."
string ttContextLabels = "Adds optional sparse context labels while a retest is approaching. Keep this off for the cleanest publication view."
string ttCooldown = "Minimum bars between event labels. Higher values reduce repeated labels during active retests."
string ttContextSpacing = "Minimum bars between sparse context labels during ongoing structure retest monitoring."
string ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
string ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
string ttLabelScore = "Adds the 0-100 retest score and grade to chart labels."
string ttLabelSize = "Controls all chart labels and the centered retest-box label. Normal is the recommended publication default."
string ttBadgeLanes = "Keeps event and context badges in clear vertical lanes above or below the candles so meaningful labels remain readable without stacking on the same price band or sitting on the structure lines."
string ttBadgeSpacing = "Controls vertical distance between smart badge lanes. Increase it on compressed charts if labels need more breathing room."
string ttPanel = "Shows or hides the AG Pro planning panel. The default is visible for public-release readability."
string ttPanelLocation = "Moves the AG Pro planning panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between Elite Dark, Slate, and Clean Light themes."
string ttPanelFont = "Controls panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Structure Retest Engine"
string sideMode = input.string("Auto", "Retest Side", options = ["Auto", "Support Retest", "Resistance Retest"], group = groupEngine, tooltip = ttSide)
int structurePivotLength = input.int(6, "Structure Pivot Length", minval = 2, maxval = 40, group = groupEngine, tooltip = ttPivot)
int maxRailAge = input.int(180, "Rail Freshness Lookback", minval = 25, maxval = 600, group = groupEngine, tooltip = ttAge)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
int fastEmaLength = input.int(21, "Fast Context EMA", minval = 2, maxval = 200, group = groupEngine, tooltip = ttTrendFast)
int slowEmaLength = input.int(55, "Slow Context EMA", minval = 3, maxval = 300, group = groupEngine, tooltip = ttTrendSlow)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

string groupScoring = "Retest Score Model"
float activationDistanceAtr = input.float(1.35, "Activation Distance ATR", minval = 0.20, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttActivation)
float retestZoneAtr = input.float(0.42, "Retest Box ATR", minval = 0.08, maxval = 2.00, step = 0.02, group = groupScoring, tooltip = ttZone)
float closeAcceptanceAtr = input.float(0.12, "Acceptance Close ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupScoring, tooltip = ttClose)
float invalidationAtr = input.float(0.72, "Invalidation Shelf ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttInvalidation)
float targetRMultiple = input.float(1.60, "Target Guide R Multiple", minval = 0.50, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttTarget)
int readyScore = input.int(72, "Retest Ready Score", minval = 40, maxval = 95, group = groupScoring, tooltip = ttReady)
int watchScore = input.int(55, "Retest Watch Score", minval = 25, maxval = 90, group = groupScoring, tooltip = ttWatch)
float hotAtrRatio = input.float(2.15, "Hot Volatility Ratio", minval = 1.20, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttHot)
int proofWindow = input.int(12, "Follow-Through Proof Window", minval = 3, maxval = 60, group = groupScoring, tooltip = ttProofWindow)
float proofGoalAtr = input.float(1.00, "Follow-Through Goal ATR", minval = 0.30, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttProofGoal)
int proofMinSamples = input.int(6, "Follow-Through Min Samples", minval = 3, maxval = 50, group = groupScoring, tooltip = ttProofSamples)

string groupVisual = "Chart Visuals"
bool showRetestBox = input.bool(true, "Show Retest Box", group = groupVisual, tooltip = ttBox)
bool showStructureRails = input.bool(true, "Show Rail / Invalidation", group = groupVisual, tooltip = ttRails)
bool showTargetGuide = input.bool(true, "Show Target Guide", group = groupVisual, tooltip = ttTargetGuide)
int forwardBars = input.int(42, "Forward Render Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttForward)
int zoneTransparency = input.int(86, "Retest Box Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
string labelEventMode = input.string("Decision Events", "Label Event Mode", options = ["Decision Events", "All States"], group = groupLabels, tooltip = ttEventMode)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
int labelCooldownBars = input.int(14, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(42, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 4, maxval = 100, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupLabels, tooltip = ttLabelSize)
bool useSmartBadgeLanes = input.bool(true, "Use Smart Badge Lanes", group = groupLabels, tooltip = ttBadgeLanes)
float badgeLaneAtr = input.float(0.55, "Badge Lane Spacing ATR", minval = 0.10, maxval = 1.25, step = 0.05, group = groupLabels, tooltip = ttBadgeSpacing)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high(value, lowValue, idealValue)
    else
        result := f_norm_low(value, idealValue, highValue)
    result

// Luminance-aware contrast: dark text on light/amber/pink/indigo badges, light text on teal
f_text_on(color bgColor) =>
    float brightness = color.r(bgColor) * 0.299 + color.g(bgColor) * 0.587 + color.b(bgColor) * 0.114
    brightness > 145.0 ? darkText : headerText

// Anti-collision registry: keeps event/context labels in clear vertical lanes above/below candles
var int[] laneBars = array.new_int()
var float[] laneYs = array.new_float()

f_register_lane(int b, float y) =>
    array.push(laneBars, b)
    array.push(laneYs, y)
    if array.size(laneBars) > 30
        array.shift(laneBars)
        array.shift(laneYs)

f_resolve_lane(int b, float y, int dirSign, float atrValue) =>
    float sep = math.max(atrValue, syminfo.mintick) * 0.95
    int barWin = 16
    float adj = y
    int guard = 0
    bool collide = true
    while collide and guard < 10
        collide := false
        int n = array.size(laneBars)
        if n > 0
            for i = 0 to n - 1
                if math.abs(b - array.get(laneBars, i)) <= barWin and math.abs(adj - array.get(laneYs, i)) < sep
                    collide := true
        if collide
            adj := adj + dirSign * sep
        guard := guard + 1
    adj

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_pos(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score_grade(float score) =>
    string grade = "E"
    if score >= 86.0
        grade := "A+"
    else if score >= 76.0
        grade := "A"
    else if score >= 66.0
        grade := "B"
    else if score >= 55.0
        grade := "C"
    else if score >= 42.0
        grade := "D"
    grade

f_compact_score(int score, string grade) =>
    "Q" + str.tostring(score) + " " + grade

f_state_badge_text(string stateText) =>
    switch stateText
        "Invalidated" => "INVALIDATED"
        "Accepted" => "ACCEPTED"
        "Rejected" => "REJECTED"
        "Risk Review" => "RISK REVIEW"
        "Testing" => "TESTING"
        "Approaching" => "APPROACHING"
        => "WAITING"

f_panel_bg(string themeText) =>
    themeText == "Clean Light" ? color.rgb(241, 245, 249) : themeText == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border(string themeText) =>
    themeText == "Clean Light" ? color.rgb(148, 163, 184) : themeText == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label(string themeText) =>
    themeText == "Clean Light" ? color.rgb(71, 85, 105) : themeText == "Slate" ? color.rgb(203, 213, 225) : panelLabelCol

f_panel_value(string themeText) =>
    themeText == "Clean Light" ? color.rgb(15, 23, 42) : themeText == "Slate" ? color.rgb(248, 250, 252) : panelValueCol

f_row_bg(string themeText, int row) =>
    bool evenRow = row % 2 == 0
    if themeText == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else if themeText == "Slate"
        evenRow ? color.rgb(51, 65, 85) : color.rgb(30, 41, 59)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_state_color(string stateText) =>
    switch stateText
        "Support Retest" => bullColor
        "Resistance Retest" => bearColor
        "Accepted" => bullColor
        "Rejected" => bearColor
        "Invalidated" => dangerColor
        "Testing" => accentColor
        "Approaching" => neutralColor
        "Risk Review" => neutralColor
        => panelValueCol

f_badge_step(float atrValue) =>
    math.max(math.max(atrValue, syminfo.mintick) * badgeLaneAtr, syminfo.mintick * 20.0)

f_rail_badge_y(float basePrice, int side, int lane, float atrValue) =>
    float dir = side == 1 ? -1.0 : side == -1 ? 1.0 : 1.0
    useSmartBadgeLanes ? basePrice + dir * f_badge_step(atrValue) * lane : basePrice

f_target_badge_y(float basePrice, int side, int lane, float atrValue) =>
    float dir = side == 1 ? 1.0 : side == -1 ? -1.0 : 1.0
    useSmartBadgeLanes ? basePrice + dir * f_badge_step(atrValue) * lane : basePrice

f_panel_row(table target, int row, string labelText, string valueText, color valueColor, string themeText, string sizeText) =>
    color rowBg = f_row_bg(themeText, row)
    table.cell(target, 0, row, labelText, text_color = f_panel_label(themeText), bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_left)
    table.cell(target, 1, row, valueText, text_color = valueColor, bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
bool confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atrRaw, atrLength * 4)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? atrRaw / atrBase : 1.0
float fastEma = ta.ema(close, fastEmaLength)
float slowEma = ta.ema(close, slowEmaLength)
int trendSide = close >= slowEma and fastEma >= slowEma ? 1 : close <= slowEma and fastEma <= slowEma ? -1 : 0

float sensitivityMult = switch sensitivity
    "Conservative" => 0.82
    "Aggressive" => 1.18
    => 1.0

float pivotHigh = ta.pivothigh(high, structurePivotLength, structurePivotLength)
float pivotLow = ta.pivotlow(low, structurePivotLength, structurePivotLength)

var float lastPivotHigh = na
var float lastPivotLow = na
var int lastPivotHighBar = na
var int lastPivotLowBar = na

if not na(pivotHigh)
    lastPivotHigh := pivotHigh
    lastPivotHighBar := bar_index - structurePivotLength

if not na(pivotLow)
    lastPivotLow := pivotLow
    lastPivotLowBar := bar_index - structurePivotLength

bool hasSupport = not na(lastPivotLow)
bool hasResistance = not na(lastPivotHigh)
float supportDistanceAtr = hasSupport ? math.abs(close - lastPivotLow) / safeAtr : 99999.0
float resistanceDistanceAtr = hasResistance ? math.abs(close - lastPivotHigh) / safeAtr : 99999.0

int manualSide = sideMode == "Support Retest" ? 1 : sideMode == "Resistance Retest" ? -1 : 0
int autoSide = 0
if hasSupport and hasResistance
    if supportDistanceAtr <= activationDistanceAtr or resistanceDistanceAtr <= activationDistanceAtr
        autoSide := supportDistanceAtr <= resistanceDistanceAtr ? 1 : -1
    else
        autoSide := trendSide == 1 ? 1 : trendSide == -1 ? -1 : supportDistanceAtr <= resistanceDistanceAtr ? 1 : -1
else if hasSupport
    autoSide := 1
else if hasResistance
    autoSide := -1

int activeSide = manualSide != 0 ? manualSide : autoSide
bool hasRail = activeSide == 1 ? hasSupport : activeSide == -1 ? hasResistance : false
float activeRail = activeSide == 1 ? lastPivotLow : activeSide == -1 ? lastPivotHigh : na
int activeRailBar = activeSide == 1 ? lastPivotLowBar : activeSide == -1 ? lastPivotHighBar : na
float oppositeRail = activeSide == 1 ? lastPivotHigh : activeSide == -1 ? lastPivotLow : na

float zoneHalfWidth = safeAtr * retestZoneAtr * sensitivityMult
float zoneTop = hasRail ? activeRail + zoneHalfWidth : na
float zoneBottom = hasRail ? activeRail - zoneHalfWidth : na
float invalidationShelf = hasRail ? activeRail + (activeSide == 1 ? -1.0 : 1.0) * safeAtr * invalidationAtr * sensitivityMult : na
float distanceToRailAtr = hasRail ? math.abs(close - activeRail) / safeAtr : na
bool touchingZone = hasRail and low <= zoneTop and high >= zoneBottom
bool approachingRail = hasRail and distanceToRailAtr <= activationDistanceAtr * sensitivityMult

float barRange = math.max(high - low, syminfo.mintick)
float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)
float sideWickRatio = activeSide == 1 ? lowerWick / barRange : activeSide == -1 ? upperWick / barRange : 0.0
float closeResponseAtr = hasRail ? (activeSide == 1 ? close - activeRail : activeRail - close) / safeAtr : 0.0
float closePadding = closeAcceptanceAtr * sensitivityMult

bool sideAcceptedClose = hasRail and closeResponseAtr >= closePadding
bool sideRejectedClose = hasRail and closeResponseAtr <= -closePadding
bool invalidated = confirmedBar and hasRail and (activeSide == 1 ? close < invalidationShelf : close > invalidationShelf)

float structureSpanAtr = hasSupport and hasResistance ? math.abs(lastPivotHigh - lastPivotLow) / safeAtr : 0.0
float originDepthScore = f_norm_high(structureSpanAtr, 0.65, 3.10)
float railAge = hasRail and not na(activeRailBar) ? bar_index - activeRailBar : na
float freshnessScore = na(railAge) ? 0.0 : f_norm_low(railAge, 3.0, maxRailAge)
float originScore = originDepthScore * 0.55 + freshnessScore * 0.45

float proximityScore = na(distanceToRailAtr) ? 0.0 : f_norm_low(distanceToRailAtr, 0.0, activationDistanceAtr * sensitivityMult)
float wickScore = f_norm_high(sideWickRatio, 0.12, 0.48)
float responseCloseScore = f_norm_high(closeResponseAtr, -retestZoneAtr, closeAcceptanceAtr + 0.35)
float responseScore = touchingZone ? (wickScore * 0.52 + responseCloseScore * 0.48) : proximityScore * 0.62
float closeLocationRaw = activeSide == 1 ? (close - zoneBottom) / math.max(zoneTop - zoneBottom, syminfo.mintick) : activeSide == -1 ? (zoneTop - close) / math.max(zoneTop - zoneBottom, syminfo.mintick) : 0.0
float closeLocationScore = f_clamp(closeLocationRaw * 100.0, 0.0, 100.0)
float volatilityFitScore = f_peak_score(atrRatio, 0.55, 1.04, hotAtrRatio)
float trendAgreementScore = trendSide == activeSide ? 100.0 : trendSide == 0 ? 58.0 : 22.0

float scoreRaw = hasRail ? originScore * 0.22 + responseScore * 0.25 + closeLocationScore * 0.20 + volatilityFitScore * 0.15 + trendAgreementScore * 0.18 : 0.0
int retestScore = int(math.round(f_clamp(scoreRaw, 0.0, 100.0)))
string scoreGrade = f_score_grade(retestScore)

bool hotVolatility = atrRatio > hotAtrRatio
bool acceptedRetest = confirmedBar and touchingZone and sideAcceptedClose and retestScore >= watchScore and not invalidated
bool rejectedRetest = confirmedBar and touchingZone and sideRejectedClose and not invalidated
bool watchRetest = confirmedBar and approachingRail and retestScore >= watchScore and not acceptedRetest and not rejectedRetest and not invalidated
bool readyRetest = confirmedBar and acceptedRetest and retestScore >= readyScore and not hotVolatility
bool riskReview = confirmedBar and touchingZone and hotVolatility and not invalidated

float riskDistance = hasRail ? activeSide == 1 ? math.max(close - invalidationShelf, safeAtr * 0.20) : math.max(invalidationShelf - close, safeAtr * 0.20) : na
float rrTarget = hasRail ? activeSide == 1 ? close + riskDistance * targetRMultiple : close - riskDistance * targetRMultiple : na
float targetGuide = rrTarget
if hasRail and activeSide == 1 and not na(oppositeRail) and oppositeRail > close + safeAtr * 0.20
    targetGuide := math.min(oppositeRail, rrTarget)
if hasRail and activeSide == -1 and not na(oppositeRail) and oppositeRail < close - safeAtr * 0.20
    targetGuide := math.max(oppositeRail, rrTarget)

string structureState = not hasRail ? "No Rail" : activeSide == 1 ? "Support Retest" : "Resistance Retest"
string acceptanceState = "Waiting"
if invalidated
    acceptanceState := "Invalidated"
else if acceptedRetest
    acceptanceState := "Accepted"
else if rejectedRetest
    acceptanceState := "Rejected"
else if riskReview
    acceptanceState := "Risk Review"
else if touchingZone
    acceptanceState := "Testing"
else if approachingRail
    acceptanceState := "Approaching"

string actionState = "Wait For Rail"
if not hasRail
    actionState := "Build Structure"
else if invalidated
    actionState := "Retest Invalidated"
else if readyRetest
    actionState := "Review Ready Retest"
else if acceptedRetest
    actionState := "Monitor Acceptance"
else if rejectedRetest
    actionState := "Stand Aside"
else if riskReview
    actionState := "Review Volatility"
else if touchingZone and retestScore >= readyScore
    actionState := "Await Acceptance Close"
else if touchingZone
    actionState := "Monitor Zone Test"
else if watchRetest
    actionState := "Track Retest"
else if approachingRail
    actionState := "Wait For Zone Test"

color sideColor = activeSide == 1 ? bullColor : activeSide == -1 ? bearColor : neutralColor
color acceptanceColor = f_state_color(acceptanceState)
int leftX = hasRail and not na(activeRailBar) ? math.max(activeRailBar, bar_index - maxRailAge) : bar_index
int rightX = bar_index + forwardBars
int centerX = int(math.round((leftX + rightX) / 2.0))
float centerY = hasRail ? (zoneTop + zoneBottom) / 2.0 : close
float boxLabelY = hasRail ? f_rail_badge_y(centerY, activeSide, 0, safeAtr) : close

// -------------------------------------------------
// Follow-Through Proof (stop-aware: reach target side before invalidation shelf)
// -------------------------------------------------
bool prevAccepted = bar_index > 0 ? acceptedRetest[1] : false
bool prevReady = bar_index > 0 ? readyRetest[1] : false
bool prevRejected = bar_index > 0 ? rejectedRetest[1] : false
bool prevInvalidated = bar_index > 0 ? invalidated[1] : false
bool prevRiskReview = bar_index > 0 ? riskReview[1] : false
bool prevWatch = bar_index > 0 ? watchRetest[1] : false
bool newAccepted = acceptedRetest and not prevAccepted
bool newReady = readyRetest and not prevReady
bool newRejected = rejectedRetest and not prevRejected
bool newInvalidated = invalidated and not prevInvalidated
bool newRiskReview = riskReview and not prevRiskReview
bool newWatch = watchRetest and not prevWatch

var bool srpPending = false
var int srpDir = 0
var float srpGoal = na
var float srpStop = na
var int srpExpiry = na
var int srpStart = na
var int srpWins = 0
var int srpTotal = 0

if newAccepted and not srpPending and hasRail and activeSide != 0
    srpPending := true
    srpDir := activeSide
    srpGoal := activeSide == 1 ? close + safeAtr * proofGoalAtr : close - safeAtr * proofGoalAtr
    srpStop := invalidationShelf
    srpExpiry := bar_index + proofWindow
    srpStart := bar_index

if srpPending and barstate.isconfirmed and not na(srpStart) and bar_index > srpStart
    bool srpWin = srpDir == 1 ? high >= srpGoal : low <= srpGoal
    bool srpLoss = srpDir == 1 ? low <= srpStop : high >= srpStop
    if srpWin
        srpTotal += 1
        srpWins += 1
        srpPending := false
    else if srpLoss
        srpTotal += 1
        srpPending := false
    else if bar_index >= srpExpiry
        srpPending := false

float srpRate = srpTotal > 0 ? srpWins / srpTotal * 100.0 : na
bool srpReady = srpTotal >= proofMinSamples
string srpText = srpReady ? str.tostring(int(math.round(srpRate))) + "% (" + str.tostring(srpTotal) + ")" : "Building (" + str.tostring(srpTotal) + "/" + str.tostring(proofMinSamples) + ")"

// -------------------------------------------------
// Visual objects
// -------------------------------------------------
var box retestBox = na
var label retestBoxLabel = na
var line railLine = na
var line invalidationLine = na
var line targetLine = na
var label invalidationBadge = na
var label targetBadge = na

if showStructureRails and hasRail
    if na(railLine)
        railLine := line.new(leftX, activeRail, rightX, activeRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(sideColor, 0), width = 2)
    else
        line.set_xy1(railLine, leftX, activeRail)
        line.set_xy2(railLine, rightX, activeRail)
        line.set_color(railLine, color.new(sideColor, 0))
        line.set_width(railLine, 2)
    if na(invalidationLine)
        invalidationLine := line.new(leftX, invalidationShelf, rightX, invalidationShelf, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 0), style = line.style_dashed, width = 1)
    else
        line.set_xy1(invalidationLine, leftX, invalidationShelf)
        line.set_xy2(invalidationLine, rightX, invalidationShelf)
        line.set_color(invalidationLine, color.new(dangerColor, 0))
        line.set_style(invalidationLine, line.style_dashed)
else
    if not na(railLine)
        line.delete(railLine)
        railLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na

if showStructureRails and hasRail
    string invalidationText = "INVALIDATION  " + f_fmt_price(invalidationShelf)
    if na(invalidationBadge)
        invalidationBadge := label.new(rightX, invalidationShelf, invalidationText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bearColor), color = color.new(bearColor, 0), size = f_text_size(labelFontSize))
    else
        label.set_xy(invalidationBadge, rightX, invalidationShelf)
        label.set_text(invalidationBadge, invalidationText)
        label.set_color(invalidationBadge, color.new(bearColor, 0))
        label.set_textcolor(invalidationBadge, f_text_on(bearColor))
        label.set_size(invalidationBadge, f_text_size(labelFontSize))
else
    if not na(invalidationBadge)
        label.delete(invalidationBadge)
        invalidationBadge := na

if showTargetGuide and hasRail
    if na(targetLine)
        targetLine := line.new(bar_index, targetGuide, rightX, targetGuide, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), style = line.style_dotted, width = 1)
    else
        line.set_xy1(targetLine, bar_index, targetGuide)
        line.set_xy2(targetLine, rightX, targetGuide)
        line.set_color(targetLine, color.new(accentColor, 0))
        line.set_style(targetLine, line.style_dotted)
    string targetText = "TARGET GUIDE  " + f_fmt_price(targetGuide)
    if na(targetBadge)
        targetBadge := label.new(rightX, targetGuide, targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(accentColor), color = color.new(accentColor, 0), size = f_text_size(labelFontSize))
    else
        label.set_xy(targetBadge, rightX, targetGuide)
        label.set_text(targetBadge, targetText)
        label.set_color(targetBadge, color.new(accentColor, 0))
        label.set_textcolor(targetBadge, f_text_on(accentColor))
        label.set_size(targetBadge, f_text_size(labelFontSize))
else
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(targetBadge)
        label.delete(targetBadge)
        targetBadge := na

// Box fill and centered label are drawn after the lines so the label stays on top
if showRetestBox and hasRail
    color boxColor = color.new(sideColor, zoneTransparency)
    color borderColor = color.new(sideColor, 15)
    string boxText = (activeSide == 1 ? "SUPPORT RETEST" : "RESISTANCE RETEST") + " | " + f_state_badge_text(acceptanceState) + " " + f_compact_score(retestScore, scoreGrade)
    if na(retestBox)
        retestBox := box.new(left = leftX, top = zoneTop, right = rightX, bottom = zoneBottom, xloc = xloc.bar_index, bgcolor = boxColor, border_color = borderColor, border_width = 1)
    else
        box.set_lefttop(retestBox, leftX, zoneTop)
        box.set_rightbottom(retestBox, rightX, zoneBottom)
        box.set_bgcolor(retestBox, boxColor)
        box.set_border_color(retestBox, borderColor)
    if na(retestBoxLabel)
        retestBoxLabel := label.new(centerX, boxLabelY, boxText, xloc = xloc.bar_index, style = label.style_label_center, textcolor = f_text_on(sideColor), color = color.new(sideColor, 0), size = f_text_size(labelFontSize))
    else
        label.set_xy(retestBoxLabel, centerX, boxLabelY)
        label.set_text(retestBoxLabel, boxText)
        label.set_color(retestBoxLabel, color.new(sideColor, 0))
        label.set_textcolor(retestBoxLabel, f_text_on(sideColor))
        label.set_size(retestBoxLabel, f_text_size(labelFontSize))
else
    if not na(retestBox)
        box.delete(retestBox)
        retestBox := na
    if not na(retestBoxLabel)
        label.delete(retestBoxLabel)
        retestBoxLabel := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

bool canPrintEvent = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool canPrintContext = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
bool aboveBar = activeSide == -1
float candleLabelY = aboveBar ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
labelStyle = aboveBar ? label.style_label_down : label.style_label_up
string scoreSuffix = showLabelScore ? " " + f_compact_score(retestScore, scoreGrade) : ""
bool includeWatchEvent = labelEventMode == "All States"
bool eventCandidate = newInvalidated or newReady or newAccepted or newRejected or newRiskReview or (includeWatchEvent and newWatch)

if showEventLabels and hasRail and canPrintEvent and eventCandidate
    string eventText = ""
    color eventColor = sideColor
    if newInvalidated
        eventText := "INVALID"
        eventColor := dangerColor
    else if newReady
        eventText := "READY"
        eventColor := sideColor
    else if newAccepted
        eventText := "ACCEPT"
        eventColor := bullColor
    else if newRejected
        eventText := "REJECT"
        eventColor := bearColor
    else if newRiskReview
        eventText := "RISK"
        eventColor := neutralColor
    else if includeWatchEvent and newWatch
        eventText := "WATCH"
        eventColor := accentColor
    if eventText != ""
        float labelY = candleLabelY
        if useSmartBadgeLanes
            labelY := f_resolve_lane(bar_index, candleLabelY, aboveBar ? 1 : -1, safeAtr)
        label eventLabel = label.new(bar_index, labelY, eventText + scoreSuffix, xloc = xloc.bar_index, style = labelStyle, textcolor = f_text_on(eventColor), color = color.new(eventColor, 0), size = f_text_size(labelFontSize))
        if useSmartBadgeLanes
            f_register_lane(bar_index, labelY)
        array.push(eventLabels, eventLabel)
        lastEventLabelBar := bar_index
        f_trim_labels(eventLabels, maxVisibleLabels)

if showContextLabels and hasRail and approachingRail and canPrintContext and not eventCandidate
    string contextText = (activeSide == 1 ? "SUP PLAN" : "RES PLAN") + scoreSuffix
    float labelY = useSmartBadgeLanes ? f_resolve_lane(bar_index, candleLabelY, aboveBar ? 1 : -1, safeAtr) : candleLabelY
    label contextLabel = label.new(bar_index, labelY, contextText, xloc = xloc.bar_index, style = labelStyle, textcolor = f_text_on(accentColor), color = color.new(accentColor, 0), size = f_text_size(labelFontSize))
    if useSmartBadgeLanes
        f_register_lane(bar_index, labelY)
    array.push(eventLabels, contextLabel)
    lastContextLabelBar := bar_index
    f_trim_labels(eventLabels, maxVisibleLabels)

// -------------------------------------------------
// Panel
// -------------------------------------------------
color dashBg = f_panel_bg(panelTheme)
color frameColor = f_panel_border(panelTheme)
var table infoPanel = na
if na(infoPanel)
    infoPanel := table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)

if barstate.islast
    if showPanel
        table.clear(infoPanel, 0, 0, 1, 6)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        color ftTierCol = not srpReady ? f_panel_value(panelTheme) : srpRate >= 55.0 ? bullColor : srpRate >= 45.0 ? neutralColor : bearColor
        table.cell(infoPanel, 0, 0, "AG Pro Structure Retest Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(infoPanel, 1, "Structure State", structureState, f_state_color(structureState), panelTheme, panelFontSize)
        f_panel_row(infoPanel, 2, "Retest Score", str.tostring(retestScore) + " / 100  " + scoreGrade, retestScore >= readyScore ? bullColor : retestScore >= watchScore ? neutralColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(infoPanel, 3, "Acceptance", acceptanceState, acceptanceColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 4, "Follow-Through", srpText, ftTierCol, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 5, "Invalidation", f_fmt_price(invalidationShelf), dangerColor, panelTheme, panelFontSize)
        f_panel_row(infoPanel, 6, "Action", actionState, f_state_color(acceptanceState), panelTheme, panelFontSize)
    else
        table.clear(infoPanel, 0, 0, 1, 6)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool retestWatchAlert = barstate.isconfirmed and newWatch
bool acceptedAlert = barstate.isconfirmed and newAccepted
bool readyAlert = barstate.isconfirmed and newReady
bool rejectedAlert = barstate.isconfirmed and newRejected
bool invalidatedAlert = barstate.isconfirmed and newInvalidated

alertcondition(retestWatchAlert, "Structure Retest Watch", "Structure Retest Planner: price is approaching or testing an active structure rail with sufficient planning score. This is an attention marker, not a trade instruction.")
alertcondition(acceptedAlert, "Structure Retest Accepted", "Structure Retest Planner: the active structure retest is showing acceptance behavior. This is an attention marker, not a trade instruction.")
alertcondition(readyAlert, "High-Quality Retest Review", "Structure Retest Planner: retest score reached the ready threshold with acceptance context. This is an attention marker, not a trade instruction.")
alertcondition(rejectedAlert, "Structure Retest Rejected", "Structure Retest Planner: the active structure rail is showing rejection or weak acceptance. This is an attention marker, not a trade instruction.")
alertcondition(invalidatedAlert, "Invalidation Shelf Broken", "Structure Retest Planner: price closed beyond the active invalidation shelf. Review the plan context.")
````
