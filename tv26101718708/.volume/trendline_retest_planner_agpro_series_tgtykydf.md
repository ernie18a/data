# Trendline Retest Planner [AGPro Series]

- url: https://www.tradingview.com/script/TgTykyDF-Trendline-Retest-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;bc0c7c1521fc4c26a23e0f146ffcf728
- version: 3.0

## Description

Trendline Retest Planner [AGPro Series]

🧠 Core Idea

Is the active trendline retest constructive enough to keep the setup under review, or is it starting to fail?


📌 Overview / What it does

Trendline Retest Planner [AGPro Series] is a chart-first decision tool for traders who review price behavior around active support and resistance trendline retests.

Instead of drawing many trendlines or flagging every break, the script focuses on one active trendline retest context at a time. It measures line age, touch count, retest depth, close response, and volume support, then converts that evidence into a 0-100 Retest Score and a clear next-action state.

The script produces an active trendline, retest pocket, hold/fail labels, invalidation edge, target path, alerts, and a compact AGPro planning panel. It does not predict price movement, automate execution, or provide guaranteed outcomes.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between auto-trendline drawing and practical retest planning.

Many tools can draw diagonals or detect a break. The harder question is what to do after price returns to the line: is the retest holding, weakening, failing, or still waiting for confirmation?

Trendline Retest Planner supports a decision workflow: identify the active retest, read the score, locate the invalidation edge, compare the target path, and decide what deserves review next.


⚡ Why This Script Is Different

Most trendline tools focus on drawing many lines, ranking confluence, or detecting trendline breaks.

This script does NOT clone Auto Trendline Break Quality, Auto Trendlines MTF - Break/Retest, Trendline Confluence Map, Break-Retest Quality, Structure Retest Planner, Swing Retest Quality, or a generic support/resistance zone map.

Instead, it narrows the workflow to one active support or resistance trendline retest and evaluates whether that retest is constructive or failing. The main output is not a buy or sell signal. It is a decision state: READY, MONITOR, FAILING, INVALIDATED, WATCH, WAIT, or SCAN.


⚙️ Methodology

1. Context Detection
The script builds the latest support and resistance trendline candidates from confirmed swing pivots, then selects the nearest valid retest context.

2. Reference Mapping
It maps the active trendline, a retest pocket around the line, an invalidation edge, and a forward target path.

3. Reaction Evaluation
The 0-100 model scores line age, touch count, retest depth, close response, and volume support.

4. Visual Output
The chart shows the active planning objects, compact state labels, and a clean AGPro decision panel.


🗺️ How to Read the Chart

Trendline = the active support or resistance line being evaluated.

Retest Pocket = the ATR-based area around the trendline where a retest is considered active.

Invalidation Edge = the planning reference where the active retest context is considered broken.

Target Path = a forward guide based on the trendline-to-risk distance.

Labels = compact TEST, READY, MONITOR, WEAK, INVALID, PATH, and sparse context labels.

Colors = teal marks support-side retest context, pink marks resistance-side retest context, amber marks caution, indigo marks monitoring/follow-through, and red marks invalidation.

Panel = the AGPro panel summarizes Trendline Side, Retest Score, Hold State, Risk Edge, and Action.


🚦 Signals & States

• READY → the retest is active, holding on the correct side, and the score is strong enough for structured review.

• MONITOR → the retest is developing, but confirmation or score quality is still incomplete.

• FAILING → price touched the pocket, but the response is weak or on the wrong side.

• INVALIDATED → price crossed the invalidation edge and the active context should be rebuilt.

• WATCH → price is approaching the trendline pocket.

• WAIT → a valid trendline exists, but price is not close enough for useful retest review.

• SCAN → no valid trendline context is active yet.


🔔 Alerts Logic

Alerts trigger when price touches the active retest pocket, when READY state appears, when MONITOR state appears, when a failing retest is detected, when the invalidation edge is crossed, and when follow-through appears after an active retest.

Alerts are attention markers only. They are not trade instructions, automated strategy commands, or outcome promises.


🧩 Confluence Logic

The strongest context appears when the active line is fresh enough, has enough touches, retests with controlled depth, closes back on the correct side, and receives supportive relative volume.

When these components conflict, the panel moves toward MONITOR, FAILING, WATCH, WAIT, or INVALIDATED.


📊 When to Use

• Trendline support retests during constructive pullbacks

• Trendline resistance retests during bearish continuation attempts

• Price-action review after a diagonal support or resistance line is already visible

• Retest planning where invalidation and target path matter

• Liquid markets where pivots, candles, and volume behavior are readable


⚠️ When NOT to Use

• Very low-liquidity symbols with irregular candles

• Extremely noisy micro-timeframes

• News-driven spikes where trendline geometry becomes distorted

• Markets where swing pivots are too compressed to form useful lines

• Situations where the user expects a signal-only or auto-trading tool


🎛️ Key Inputs

• Trendline Side → selects Auto, Support Retest, or Resistance Retest.

• Trendline Pivot Length → controls how confirmed swing anchors are detected.

• Max Trendline Age → controls how old a trendline can be before it is ignored.

• Touch Count Lookback → controls how extra line touches are counted.

• Sensitivity → adjusts retest pocket width and activation distance.

• READY Score → sets the score threshold for stronger review states.

• Label and Panel Font Size → controls chart-label and panel readability.

• Panel Location and Theme → adjusts the AGPro panel layout.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first and decision-led.

The active trendline is the main reference. The retest pocket is drawn around that line with centered text so the chart stays readable. The invalidation edge and target path explain where the planning context weakens and what forward room is being mapped.

The AGPro panel uses a merged blue title row and five compact rows so the user can read side, score, hold state, risk edge, and action quickly.


🧪 Practical Usage Workflow

1. Read the panel state and Retest Score.

2. Check whether price is approaching or touching the retest pocket.

3. Compare current price with the invalidation edge.

4. Review whether the label says TEST, READY, MONITOR, WEAK, INVALID, or PATH.

5. Confirm the broader market context before making any decision.


🔍 Interpretation Guidelines

Think in terms of retest quality, not prediction.

A higher score means multiple retest components align inside the script's rule set. A weaker score means the line may be too old, the retest may be too shallow, too deep, missing a constructive close, or lacking participation.

The script helps organize the review process. It does not replace judgment.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed signal tool

• Not a broad auto-trendline map

• Not a trendline confluence scanner

• Not a break-and-retest scanner

• Not a generic support/resistance zone map

• Not an order block, FVG, or supply/demand tool


⚠️ Limitations & Transparency

• Pivot-based trendlines appear only after pivots are confirmed.

• Scores can vary across symbols, sessions, and timeframes.

• Volume scoring depends on exchange-provided volume data.

• Fast volatility can cross a trendline before a clean retest can be measured.

• In Live Updating mode, active-bar values can change before the bar closes.


🧠 Market Context Notes

Trendline retests are easiest to interpret when liquidity, volatility, and swing structure are readable.

A trendline touch is not enough by itself. Line quality, response, invalidation distance, and target path all matter.


🧾 Use Case Examples

When price returns to an upward support trendline and closes back above the pocket with a high score, the panel may move toward READY.

When price touches a downward resistance trendline but cannot close back below it, the planner may move toward FAILING or INVALIDATED.

When price is near the line but has not touched the pocket yet, the panel can stay in WATCH or WAIT.


🧱 System Philosophy

Trendline Retest Planner follows the AGPro decision-engine approach: identify context, score quality, map risk, show the next action, and keep the chart readable.

It is designed to help traders evaluate a specific planning question instead of adding another generic signal layer.


🔐 Non-Promise Statement

No score, label, alert, or chart object guarantees any market outcome.

The script organizes retest context and highlights conditions for review. It does not provide certainty.


📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions, position sizing, execution, and risk management.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the planner as a structured reading layer: trendline context first, retest quality second, invalidation and target path third, broader market context always.

## Source Code

````pine
// -------------------------------------------------
// Trendline Retest Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Trendline Retest Planner turns a single active support or resistance
// trendline retest into a decision-focused planning map. It scores line age,
// touch quality, retest depth, close response, and volume support, then maps
// hold/fail context, risk edge, target path, a stop-aware follow-through proof
// rate, and next action without becoming a generic auto-trendline, confluence
// map, or break scanner.
// -------------------------------------------------

//@version=6
indicator("Trendline Retest Planner [AGPro Series]",
     shorttitle = "AG Pro TRP",
     overlay = true,
     max_lines_count = 90,
     max_boxes_count = 30,
     max_labels_count = 220)

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

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSide = "Selects which trendline retest is evaluated. Auto chooses the nearest valid support or resistance trendline; manual modes force one side."
string ttPivot = "Pivot length used to build the active trendline from confirmed swing points. Lower values react faster, while higher values require cleaner structure."
string ttAge = "Maximum age of the second trendline anchor. Older trendlines are ignored so the planner stays focused on current retest context."
string ttLookback = "Bars used to count extra touches after the second anchor. This supports the touch-count part of the 0-100 score."
string ttAtr = "ATR length used for retest pocket width, invalidation edge, target path, and label spacing."
string ttVolume = "Volume baseline used to judge whether the retest response has participation. On symbols with weak volume data this should be treated as context."
string ttSensitivity = "Controls retest pocket width and activation distance. Responsive allows more reviews, Balanced is the publication default, and Strict requires cleaner behavior."
string ttConfirm = "Close Confirmed waits for closed bars before printing labels and alerts. Live Updating lets the planner update during the active bar."
string ttPocket = "ATR width around the active trendline used to create the retest pocket. The pocket label is centered inside the zone."
string ttActivation = "ATR distance from the active trendline where the planner starts treating price as approaching a retest."
string ttIdealDepth = "Preferred ATR-normalized probe through the trendline pocket. Very shallow retests and very deep violations score lower."
string ttMaxProbe = "Probe depth that becomes too deep for a clean retest read."
string ttClose = "ATR-normalized close back on the defended side of the trendline required for a stronger close-response score."
string ttRisk = "ATR distance behind the active trendline used to draw the invalidation edge. This is a planning reference, not a stop instruction."
string ttTarget = "R multiple used to project the target path from the active trendline and invalidation edge."
string ttWindow = "Number of bars after a pocket touch where the retest remains active for hold/fail evaluation."
string ttReady = "Minimum 0-100 score required for READY state. This is an attention filter, not a trade instruction."
string ttMonitor = "Minimum 0-100 score required for MONITOR state when the retest is developing but not ready."
string ttTouchNeed = "Touch count used as the full-score reference for line quality. The first two anchor pivots are included automatically."
string ttUseVolume = "When enabled, relative volume contributes to the 0-100 score. When disabled, the volume component is neutral."
string ttTrendline = "Shows the active trendline selected by the planner."
string ttPocketShow = "Shows the retest pocket around the active trendline with centered text."
string ttGuides = "Shows the invalidation edge and target path used by the planner."
string ttLabels = "Shows compact TEST, READY, MONITOR, WEAK, INVALID, and context labels with controlled spacing."
string ttContextLabels = "Adds sparse context labels so the chart remains readable without becoming crowded."
string ttLabelScore = "Adds the 0-100 retest score to chart labels."
string ttCooldown = "Minimum bars between event labels. Higher values reduce repeated labels during active retests."
string ttContextSpacing = "Minimum bars between sparse context labels during ongoing trendline review."
string ttMaxLabels = "Maximum number of visible chart labels retained by the script. Older labels are removed first for performance."
string ttProjection = "Controls how far the active pocket, trendline, invalidation edge, and target path extend to the right."
string ttOpacity = "Transparency for the retest pocket. Higher values make the pocket lighter."
string ttOffset = "ATR-based label offset that keeps labels above or below candles."
string ttLabelSize = "Controls all chart labels and centered pocket text. Normal is the recommended public-release default."
string ttPanel = "Shows or hides the AG Pro planning panel. The default is visible for public-release readability."
string ttPanelLocation = "Moves the AG Pro planning panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
string ttPanelFont = "Controls panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Trendline Retest Engine"
string sideMode = input.string("Auto", "Trendline Side", options = ["Auto", "Support Retest", "Resistance Retest"], group = groupEngine, tooltip = ttSide)
int pivotLength = input.int(6, "Trendline Pivot Length", minval = 2, maxval = 40, group = groupEngine, tooltip = ttPivot)
int maxLineAge = input.int(220, "Max Trendline Age", minval = 40, maxval = 800, group = groupEngine, tooltip = ttAge)
int touchLookbackBars = input.int(180, "Touch Count Lookback", minval = 30, maxval = 500, group = groupEngine, tooltip = ttLookback)
int atrLength = input.int(14, "ATR Length", minval = 3, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(30, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = ttSensitivity)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

string groupModel = "Retest Score Model"
float retestPocketAtr = input.float(0.42, "Retest Pocket Width ATR", minval = 0.08, maxval = 2.50, step = 0.02, group = groupModel, tooltip = ttPocket)
float activationDistanceAtr = input.float(1.15, "Activation Distance ATR", minval = 0.20, maxval = 5.00, step = 0.05, group = groupModel, tooltip = ttActivation)
float idealProbeAtr = input.float(0.16, "Ideal Retest Probe ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupModel, tooltip = ttIdealDepth)
float maxProbeAtr = input.float(0.92, "Deep Probe Risk ATR", minval = 0.12, maxval = 4.00, step = 0.04, group = groupModel, tooltip = ttMaxProbe)
float closeResponseAtr = input.float(0.16, "Close Response ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupModel, tooltip = ttClose)
float riskEdgeAtr = input.float(0.78, "Invalidation Edge ATR", minval = 0.15, maxval = 5.00, step = 0.05, group = groupModel, tooltip = ttRisk)
float targetRMultiple = input.float(1.80, "Target Path R Multiple", minval = 0.50, maxval = 6.00, step = 0.05, group = groupModel, tooltip = ttTarget)
int responseWindowBars = input.int(8, "Retest Response Window", minval = 1, maxval = 50, group = groupModel, tooltip = ttWindow)
int readyScore = input.int(70, "READY Score", minval = 40, maxval = 95, group = groupModel, tooltip = ttReady)
int monitorScore = input.int(55, "MONITOR Score", minval = 25, maxval = 90, group = groupModel, tooltip = ttMonitor)
int requiredTouches = input.int(4, "Full Touch Score Count", minval = 2, maxval = 12, group = groupModel, tooltip = ttTouchNeed)
bool useVolumeSupport = input.bool(true, "Use Volume Support", group = groupModel, tooltip = ttUseVolume)

string groupVisual = "Chart Visuals"
bool showActiveTrendline = input.bool(true, "Show Active Trendline", group = groupVisual, tooltip = ttTrendline)
bool showRetestPocket = input.bool(true, "Show Retest Pocket", group = groupVisual, tooltip = ttPocketShow)
bool showRiskTargetGuides = input.bool(true, "Show Invalidation / Target Path", group = groupVisual, tooltip = ttGuides)
int projectionBars = input.int(44, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
int pocketTransparency = input.int(86, "Pocket Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttOpacity)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
int labelCooldownBars = input.int(13, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(44, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(16, "Max Visible Labels", minval = 5, maxval = 100, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

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

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
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

f_project_line(int x1, float y1, int x2, float y2, int xTarget) =>
    float span = math.max(float(x2 - x1), 1.0)
    y1 + (y2 - y1) / span * float(xTarget - x1)

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_grade(float score) =>
    string result = "D"
    if score >= 88.0
        result := "A+"
    else if score >= 78.0
        result := "A"
    else if score >= 66.0
        result := "B"
    else if score >= 55.0
        result := "C"
    result

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

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_add_label(array<label> labels, int x, float y, string labelText, color bgColor, color textColor, bool upStyle, string sizeText, int maxCount) =>
    label newLabel = label.new(x = x, y = y, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = upStyle ? label.style_label_up : label.style_label_down, color = bgColor, textcolor = textColor, size = f_text_size(sizeText))
    array.push(labels, newLabel)
    f_trim_labels(labels, maxCount)

// -------------------------------------------------
// Core References
// -------------------------------------------------
bool confirmReady = confirmationMode == "Live Updating" or barstate.isconfirmed
float atrValue = ta.atr(atrLength)
float safeAtr = math.max(nz(atrValue, ta.tr(true)), syminfo.mintick)
float volumeBase = ta.sma(volume, volumeLength)
float relativeVolume = volumeBase > 0.0 ? volume / volumeBase : 1.0

float sensitivityMult = switch sensitivity
    "Responsive" => 1.22
    "Strict" => 0.78
    => 1.00

float pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
float pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

var int supportX1 = na
var float supportY1 = na
var int supportX2 = na
var float supportY2 = na
var int resistanceX1 = na
var float resistanceY1 = na
var int resistanceX2 = na
var float resistanceY2 = na

if not na(pivotLow)
    supportX1 := supportX2
    supportY1 := supportY2
    supportX2 := bar_index - pivotLength
    supportY2 := pivotLow

if not na(pivotHigh)
    resistanceX1 := resistanceX2
    resistanceY1 := resistanceY2
    resistanceX2 := bar_index - pivotLength
    resistanceY2 := pivotHigh

bool hasSupportLine = not na(supportX1) and not na(supportX2) and supportX2 > supportX1 and bar_index - supportX2 <= maxLineAge
bool hasResistanceLine = not na(resistanceX1) and not na(resistanceX2) and resistanceX2 > resistanceX1 and bar_index - resistanceX2 <= maxLineAge

float supportNow = hasSupportLine ? f_project_line(supportX1, supportY1, supportX2, supportY2, bar_index) : na
float resistanceNow = hasResistanceLine ? f_project_line(resistanceX1, resistanceY1, resistanceX2, resistanceY2, bar_index) : na
float supportDistanceAtr = hasSupportLine ? math.abs(close - supportNow) / safeAtr : na
float resistanceDistanceAtr = hasResistanceLine ? math.abs(close - resistanceNow) / safeAtr : na

bool supportCandidate = hasSupportLine and close >= supportNow - safeAtr * riskEdgeAtr
bool resistanceCandidate = hasResistanceLine and close <= resistanceNow + safeAtr * riskEdgeAtr

bool autoSupport = false
if supportCandidate and resistanceCandidate
    autoSupport := supportDistanceAtr <= resistanceDistanceAtr
else if supportCandidate
    autoSupport := true
else if not resistanceCandidate and hasSupportLine
    autoSupport := true

bool useSupportSide = sideMode == "Support Retest" ? true : sideMode == "Resistance Retest" ? false : autoSupport
bool activePlan = (useSupportSide and hasSupportLine) or (not useSupportSide and hasResistanceLine)

int activeDir = useSupportSide ? 1 : -1
int activeX1 = activePlan ? (useSupportSide ? supportX1 : resistanceX1) : na
float activeY1 = activePlan ? (useSupportSide ? supportY1 : resistanceY1) : na
int activeX2 = activePlan ? (useSupportSide ? supportX2 : resistanceX2) : na
float activeY2 = activePlan ? (useSupportSide ? supportY2 : resistanceY2) : na
int activeAge = activePlan ? bar_index - activeX2 : 0

float lineNow = activePlan ? f_project_line(activeX1, activeY1, activeX2, activeY2, bar_index) : na
float lineFuture = activePlan ? f_project_line(activeX1, activeY1, activeX2, activeY2, bar_index + projectionBars) : na
float pocketPad = safeAtr * retestPocketAtr * sensitivityMult
float activationDistance = safeAtr * activationDistanceAtr * sensitivityMult
float pocketTopNow = activePlan ? lineNow + pocketPad : na
float pocketBottomNow = activePlan ? lineNow - pocketPad : na
bool touchesPocket = activePlan and high >= pocketBottomNow and low <= pocketTopNow
bool nearPocket = activePlan and math.abs(close - lineNow) <= activationDistance

float riskShift = activePlan ? (activeDir == 1 ? -safeAtr * riskEdgeAtr : safeAtr * riskEdgeAtr) : na
float riskNow = activePlan ? lineNow + riskShift : na
float riskFuture = activePlan ? lineFuture + riskShift : na
float riskSpan = activePlan ? math.abs(lineNow - riskNow) : na
float targetNow = activePlan ? (activeDir == 1 ? lineNow + riskSpan * targetRMultiple : lineNow - riskSpan * targetRMultiple) : na
float targetFuture = activePlan ? (activeDir == 1 ? lineFuture + riskSpan * targetRMultiple : lineFuture - riskSpan * targetRMultiple) : na
bool invalidated = activePlan and (activeDir == 1 ? close < riskNow : close > riskNow)

var int activeMemoryX2 = na
var int activeMemoryDir = 0
var int lastRetestBar = na

if activePlan and (na(activeMemoryX2) or activeX2 != activeMemoryX2 or activeDir != activeMemoryDir)
    lastRetestBar := na
    activeMemoryX2 := activeX2
    activeMemoryDir := activeDir

if confirmReady and touchesPocket
    lastRetestBar := bar_index

int retestAge = na(lastRetestBar) ? 100000 : bar_index - lastRetestBar
bool touchedRecently = activePlan and retestAge <= responseWindowBars

// -------------------------------------------------
// Touch Count And Score Model
// -------------------------------------------------
int activeTouchCount = activePlan ? 2 : 0
if activePlan
    for offset = 0 to touchLookbackBars
        int sampleX = bar_index - offset
        if sampleX > activeX2
            float sampleLine = f_project_line(activeX1, activeY1, activeX2, activeY2, sampleX)
            float sampleAtr = math.max(nz(safeAtr[offset], safeAtr), syminfo.mintick)
            float samplePad = sampleAtr * retestPocketAtr * sensitivityMult
            bool sampleTouch = high[offset] >= sampleLine - samplePad and low[offset] <= sampleLine + samplePad
            bool sampleCorrectSide = activeDir == 1 ? close[offset] >= sampleLine - sampleAtr * riskEdgeAtr : close[offset] <= sampleLine + sampleAtr * riskEdgeAtr
            if sampleTouch and sampleCorrectSide
                activeTouchCount := activeTouchCount + 1

float ageScore = activePlan ? f_peak_score(float(activeAge), 6.0, math.min(float(maxLineAge) * 0.36, 90.0), float(maxLineAge)) : 0.0
float touchScore = activePlan ? f_norm_high(float(math.min(activeTouchCount, requiredTouches + 2)), 2.0, float(requiredTouches)) : 0.0
float probeDepthAtr = activePlan ? (activeDir == 1 ? math.max((lineNow - low) / safeAtr, 0.0) : math.max((high - lineNow) / safeAtr, 0.0)) : na
float distanceToLineAtr = activePlan ? math.abs(close - lineNow) / safeAtr : na
float depthScore = activePlan ? (touchedRecently ? f_peak_score(probeDepthAtr, 0.0, idealProbeAtr, maxProbeAtr) : f_norm_low(distanceToLineAtr, 0.0, activationDistanceAtr * sensitivityMult)) : 0.0
float closeResponseValue = activePlan ? (activeDir == 1 ? (close - lineNow) / safeAtr : (lineNow - close) / safeAtr) : na
float closeResponseScore = activePlan ? f_norm_high(closeResponseValue, -retestPocketAtr, closeResponseAtr) : 0.0
float volumeScore = useVolumeSupport ? f_norm_high(relativeVolume, 0.75, 1.60) : 70.0

float scoreRaw = activePlan ? ageScore * 0.18 + touchScore * 0.20 + depthScore * 0.22 + closeResponseScore * 0.25 + volumeScore * 0.15 : 0.0
float retestScore = scoreRaw
if activePlan and not nearPocket and not touchedRecently
    retestScore := math.min(retestScore, 44.0)
if invalidated
    retestScore := math.min(retestScore, 24.0)

bool closeOnCorrectSide = activePlan and (activeDir == 1 ? close >= lineNow : close <= lineNow)
bool readyState = activePlan and touchedRecently and retestScore >= readyScore and closeOnCorrectSide and not invalidated
bool monitorState = activePlan and touchedRecently and retestScore >= monitorScore and not readyState and not invalidated
bool failState = activePlan and touchedRecently and not invalidated and (not closeOnCorrectSide or retestScore < monitorScore)
bool approachState = activePlan and nearPocket and not touchedRecently and not invalidated
bool followThroughState = activePlan and touchedRecently and retestScore >= monitorScore and not invalidated and (activeDir == 1 ? close >= lineNow + safeAtr * 0.70 : close <= lineNow - safeAtr * 0.70)

string stateText = "SCAN"
if activePlan
    if invalidated
        stateText := "INVALIDATED"
    else if readyState
        stateText := "READY"
    else if monitorState
        stateText := "MONITOR"
    else if failState
        stateText := "FAILING"
    else if approachState
        stateText := "WATCH"
    else
        stateText := "WAIT"

string holdText = switch stateText
    "READY" => "Holding"
    "MONITOR" => "Testing"
    "FAILING" => "Failing"
    "INVALIDATED" => "Broken"
    "WATCH" => "Approach"
    "WAIT" => "Standby"
    => "No line"

string actionText = switch stateText
    "READY" => "Review hold"
    "MONITOR" => "Wait close"
    "FAILING" => "Risk review"
    "INVALIDATED" => "Reset line"
    "WATCH" => "Watch retest"
    "WAIT" => "Wait touch"
    => "Find line"

color directionColor = activePlan ? (activeDir == 1 ? bullColor : bearColor) : neutralColor
color stateColor = switch stateText
    "READY" => directionColor
    "MONITOR" => accentColor
    "FAILING" => neutralColor
    "INVALIDATED" => dangerColor
    "WATCH" => accentColor
    => neutralColor

string sideText = activePlan ? (activeDir == 1 ? "Support Retest" : "Resistance Retest") : "-"
string scoreText = activePlan ? str.tostring(math.round(retestScore)) + " / " + f_grade(retestScore) : "-"
string riskText = activePlan ? f_price(riskNow) + " / " + f_fmt(math.abs(close - riskNow) / safeAtr) + " ATR" : "-"
string targetText2 = activePlan ? f_price(targetNow) : "-"

// -------------------------------------------------
// Chart Objects
// -------------------------------------------------
var line trendLine = na
var line riskLine = na
var line targetLine = na
var line followLine = na
var box retestBox = na
var label pocketLabel = na

int rightEdge = bar_index + projectionBars
int pocketLeft = activePlan ? math.max(activeX2, bar_index - 14) : bar_index
float pocketLineLeft = activePlan ? f_project_line(activeX1, activeY1, activeX2, activeY2, pocketLeft) : na
float pocketHigh = activePlan ? math.max(pocketLineLeft, lineFuture) + pocketPad : na
float pocketLow = activePlan ? math.min(pocketLineLeft, lineFuture) - pocketPad : na
string pocketText = activePlan ? "RETEST\nQ " + str.tostring(math.round(retestScore)) : ""
int pocketLabelX = activePlan ? int(math.round((pocketLeft + rightEdge) / 2.0)) : bar_index
float pocketLabelY = activePlan ? (pocketHigh + pocketLow) / 2.0 : na
color pocketBadgeColor = invalidated ? dangerColor : readyState ? directionColor : monitorState ? accentColor : failState ? neutralColor : stateColor
color pocketTextColor = f_text_on(pocketBadgeColor)

if showActiveTrendline and activePlan
    if na(trendLine)
        trendLine := line.new(x1 = activeX1, y1 = activeY1, x2 = rightEdge, y2 = lineFuture, xloc = xloc.bar_index, extend = extend.none, color = directionColor, style = line.style_solid, width = 2)
    else
        line.set_xy1(trendLine, activeX1, activeY1)
        line.set_xy2(trendLine, rightEdge, lineFuture)
        line.set_color(trendLine, directionColor)
        line.set_style(trendLine, line.style_solid)
        line.set_width(trendLine, 2)
else if not na(trendLine)
    line.delete(trendLine)
    trendLine := na

if showRetestPocket and activePlan
    if na(retestBox)
        retestBox := box.new(left = pocketLeft, top = pocketHigh, right = rightEdge, bottom = pocketLow, xloc = xloc.bar_index, border_color = stateColor, bgcolor = color.new(directionColor, pocketTransparency))
    else
        box.set_lefttop(retestBox, pocketLeft, pocketHigh)
        box.set_rightbottom(retestBox, rightEdge, pocketLow)
        box.set_border_color(retestBox, stateColor)
        box.set_bgcolor(retestBox, color.new(directionColor, pocketTransparency))
    if na(pocketLabel)
        pocketLabel := label.new(x = pocketLabelX, y = pocketLabelY, text = pocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = pocketBadgeColor, textcolor = pocketTextColor, size = f_text_size(labelFontSize))
    else
        label.set_xy(pocketLabel, pocketLabelX, pocketLabelY)
        label.set_text(pocketLabel, pocketText)
        label.set_color(pocketLabel, pocketBadgeColor)
        label.set_textcolor(pocketLabel, pocketTextColor)
        label.set_size(pocketLabel, f_text_size(labelFontSize))
else
    if not na(retestBox)
        box.delete(retestBox)
        retestBox := na
    if not na(pocketLabel)
        label.delete(pocketLabel)
        pocketLabel := na

if showRiskTargetGuides and activePlan
    if na(riskLine)
        riskLine := line.new(x1 = bar_index, y1 = riskNow, x2 = rightEdge, y2 = riskFuture, xloc = xloc.bar_index, extend = extend.none, color = invalidated ? dangerColor : neutralColor, style = line.style_dashed, width = 2)
    else
        line.set_xy1(riskLine, bar_index, riskNow)
        line.set_xy2(riskLine, rightEdge, riskFuture)
        line.set_color(riskLine, invalidated ? dangerColor : neutralColor)
        line.set_style(riskLine, line.style_dashed)
        line.set_width(riskLine, 2)

    if na(targetLine)
        targetLine := line.new(x1 = bar_index, y1 = targetNow, x2 = rightEdge, y2 = targetFuture, xloc = xloc.bar_index, extend = extend.none, color = accentColor, style = line.style_dotted, width = 1)
    else
        line.set_xy1(targetLine, bar_index, targetNow)
        line.set_xy2(targetLine, rightEdge, targetFuture)
        line.set_color(targetLine, accentColor)
        line.set_style(targetLine, line.style_dotted)
else
    if not na(riskLine)
        line.delete(riskLine)
        riskLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

float followLevel = activePlan ? (activeDir == 1 ? lineNow + safeAtr * 0.70 : lineNow - safeAtr * 0.70) : na
float followFuture = activePlan ? (activeDir == 1 ? lineFuture + safeAtr * 0.70 : lineFuture - safeAtr * 0.70) : na
if showRiskTargetGuides and followThroughState
    if na(followLine)
        followLine := line.new(x1 = bar_index, y1 = followLevel, x2 = rightEdge, y2 = followFuture, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 5), style = line.style_dotted, width = 1)
    else
        line.set_xy1(followLine, bar_index, followLevel)
        line.set_xy2(followLine, rightEdge, followFuture)
        line.set_color(followLine, color.new(accentColor, 5))
else if not na(followLine)
    line.delete(followLine)
    followLine := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> chartLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

bool touchEvent = confirmReady and touchesPocket and not (touchesPocket[1] == true)
bool readyEvent = confirmReady and readyState and not (readyState[1] == true)
bool monitorEvent = confirmReady and monitorState and not (monitorState[1] == true)
bool failEvent = confirmReady and failState and not (failState[1] == true)
bool invalidEvent = confirmReady and invalidated and not (invalidated[1] == true)
bool followEvent = confirmReady and followThroughState and not (followThroughState[1] == true)

// -------------------------------------------------
// Stop-aware Proof — retest follow-through
// On a qualified retest (READY or MONITOR), did price CLOSE through the
// follow-through level (0.70 ATR off the line) before closing past the
// invalidation edge? Both sides are close-based so the race stays fair.
// Confirmed-bar gated, resolve-then-open, timeout uncounted, "Building (n)" < 6.
// -------------------------------------------------
var float trpProofTarget = na
var float trpProofStop   = na
var int   trpProofDir    = 0
var bool  trpProofOpen   = false
var int   trpProofAge    = na
var int   trpProofWins   = 0
var int   trpProofLosses = 0
int trpProofWindow = math.max(projectionBars, 30)

if (readyEvent or monitorEvent) and activePlan and barstate.isconfirmed and not trpProofOpen and not na(followLevel) and not na(riskNow)
    trpProofTarget := followLevel
    trpProofStop   := riskNow
    trpProofDir    := activeDir
    trpProofAge    := 0
    trpProofOpen   := true

if trpProofOpen and barstate.isconfirmed and not na(trpProofTarget) and not na(trpProofStop)
    bool proofHitStop   = trpProofDir == 1 ? close < trpProofStop : close > trpProofStop
    bool proofHitTarget = trpProofDir == 1 ? close >= trpProofTarget : close <= trpProofTarget
    if proofHitStop
        trpProofLosses += 1
        trpProofOpen := false
    else if proofHitTarget
        trpProofWins += 1
        trpProofOpen := false
    else
        trpProofAge := nz(trpProofAge) + 1
        if trpProofAge > trpProofWindow
            trpProofOpen := false   // timeout — uncounted

int trpProofTotal = trpProofWins + trpProofLosses
float trpProofRate = trpProofTotal == 0 ? 0.0 : 100.0 * trpProofWins / trpProofTotal
string proofText = trpProofTotal < 6 ? "Building (" + str.tostring(trpProofTotal) + ")" : str.tostring(math.round(trpProofRate)) + "% (" + str.tostring(trpProofTotal) + ")"
color proofColor = trpProofTotal < 6 ? f_panel_label(panelTheme) : trpProofRate >= 55 ? bullColor : trpProofRate >= 45 ? neutralColor : bearColor

bool eventCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
string scoreSuffix = showLabelScore ? "\nQ " + str.tostring(math.round(retestScore)) : ""

if showEventLabels and eventCooldownReady
    if invalidEvent
        float invalidY = activeDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, invalidY, "INVALID" + scoreSuffix, dangerColor, f_text_on(dangerColor), activeDir == -1, labelFontSize, maxVisibleLabels)
        lastEventLabelBar := bar_index
    else if readyEvent
        float readyY = activeDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, readyY, "READY" + scoreSuffix, directionColor, f_text_on(directionColor), activeDir == 1, labelFontSize, maxVisibleLabels)
        lastEventLabelBar := bar_index
    else if monitorEvent
        float monitorY = activeDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, monitorY, "MONITOR" + scoreSuffix, accentColor, f_text_on(accentColor), activeDir == 1, labelFontSize, maxVisibleLabels)
        lastEventLabelBar := bar_index
    else if failEvent
        float failY = activeDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, failY, "WEAK" + scoreSuffix, neutralColor, f_text_on(neutralColor), activeDir == -1, labelFontSize, maxVisibleLabels)
        lastEventLabelBar := bar_index
    else if followEvent
        float followY = activeDir == 1 ? low - safeAtr * (labelOffsetAtr + 0.45) : high + safeAtr * (labelOffsetAtr + 0.45)
        f_add_label(chartLabels, bar_index, followY, "PATH" + scoreSuffix, color.new(accentColor, 3), f_text_on(accentColor), activeDir == 1, labelFontSize, maxVisibleLabels)
        lastEventLabelBar := bar_index
    else if touchEvent
        float touchY = activeDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        f_add_label(chartLabels, bar_index, touchY, "TEST" + scoreSuffix, color.new(directionColor, 4), f_text_on(directionColor), activeDir == 1, labelFontSize, maxVisibleLabels)
        lastEventLabelBar := bar_index

bool contextReady = showContextLabels and confirmReady and activePlan and not invalidated and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
if contextReady
    string contextText = touchedRecently ? stateText : "WATCH"
    float contextY = activeDir == 1 ? low - safeAtr * (labelOffsetAtr + 0.62) : high + safeAtr * (labelOffsetAtr + 0.62)
    f_add_label(chartLabels, bar_index, contextY, contextText + scoreSuffix, color.new(stateColor, 5), f_text_on(stateColor), activeDir == 1, labelFontSize, maxVisibleLabels)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
color panelFrame = f_panel_border(panelTheme)
var table panel = table.new(f_panel_position(panelLocation), 2, 8, bgcolor = f_panel_bg(panelTheme), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)

if barstate.islast
    table.clear(panel, 0, 0, 1, 7)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Trendline Retest Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_set_row(panel, 1, "Trendline Side", sideText, directionColor, panelTheme, panelFontSize)
        f_set_row(panel, 2, "Retest Score", scoreText, stateColor, panelTheme, panelFontSize)
        f_set_row(panel, 3, "Hold State", holdText, stateColor, panelTheme, panelFontSize)
        f_set_row(panel, 4, "Target", targetText2, activePlan ? accentColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_set_row(panel, 5, "Risk Edge", riskText, invalidated ? dangerColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_set_row(panel, 6, "Action", actionText, stateColor, panelTheme, panelFontSize)
        f_set_row(panel, 7, "Proof", proofText, proofColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(touchEvent, title = "Trendline Retest Touch", message = "Trendline Retest Planner: price has touched the active trendline retest pocket.")
alertcondition(readyEvent, title = "Trendline Retest READY", message = "Trendline Retest Planner: the active retest has reached READY state with sufficient score.")
alertcondition(monitorEvent, title = "Trendline Retest MONITOR", message = "Trendline Retest Planner: the retest is developing but still needs confirmation.")
alertcondition(failEvent, title = "Trendline Retest Failing", message = "Trendline Retest Planner: the active retest is failing or response quality is weak.")
alertcondition(invalidEvent, title = "Trendline Retest Invalidated", message = "Trendline Retest Planner: the active invalidation edge has been crossed.")
alertcondition(followEvent, title = "Trendline Retest Follow-Through", message = "Trendline Retest Planner: price has moved away from the trendline pocket after an active retest.")
````
