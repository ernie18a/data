# Candle Rejection Quality Planner [AGPro Series]

- url: https://www.tradingview.com/script/t5ySiees-Candle-Rejection-Quality-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;86a58c02242146369de130c68f7cda8e
- version: 4.0

## Description

Candle Rejection Quality Planner [AGPro Series]

🧠 Core Idea

Is the rejection candle strong enough to create a valid planning context, or is it only a noisy wick?


📌 Overview / What it does

Candle Rejection Quality Planner [AGPro Series] is a chart-first rejection candle decision tool designed to evaluate wick-led rejection without turning the chart into a generic candlestick signal map.

The script identifies bullish and bearish rejection candles, scores their quality from 0 to 100, then tracks what happens next through a confirmation rail, failure edge, target-room guide, wick quality zone, compact labels, alerts, and a clean AG Pro planning panel.

It does not predict future price movement, automate entries, print buy/sell commands, or replace broader market context. Its purpose is to help traders judge whether a rejection candle has enough structure to deserve attention.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between simple wick markers and broader reversal systems.

Many traders can see a long wick. The harder question is whether that wick has enough close quality, candle range, participation, and follow-through potential to become useful context.

The design supports a planner mindset: evaluate the candle, define the confirmation level, know where the idea weakens, and wait for the next state instead of reacting to every wick.


⚡ Why This Script Is Different

Most tools focus on detecting a named candle pattern such as a pin bar, engulfing candle, or generic rejection marker.

This script does NOT clone Pin Bar Quality Filter, Engulfing Candle Quality, Rejection Block Quality, order block logic, liquidity sweep logic, or a broad candlestick scanner.

Instead, it focuses on the planning process after a rejection candle appears: quality score, confirmation rail, failure edge, target-room guide, and next-action state. The candle is not treated as an entry by itself. It is treated as a context that must prove itself.


⚙️ Methodology

1. Context Detection
The script measures candle range, upper wick, lower wick, close location, and relative volume to detect wick-led rejection context.

2. Reference Mapping
When a qualified rejection candle appears, the planner maps a wick quality zone, confirmation rail, failure edge, and target-room guide.

3. Reaction Evaluation
The model updates the 0-100 Rejection Quality score as confirmation develops, pressure works against the candle, time passes, or price reaches the planning guide.

4. Visual Output
The chart displays the wick zone, rail, guide lines, controlled labels, candle tint, alerts, and AG Pro panel.


🗺️ How to Read the Chart

Zones = the rejected wick area of the qualifying candle. The zone is a candle-quality reference, not a support/resistance map.

Labels = rejection context, confirmation, failure edge breaks, target-room completion, and sparse active-state markers.

Colors = teal supports bullish rejection context, pink marks bearish rejection or failure pressure, yellow marks caution, and indigo marks confirmation review.

Panel = a compact decision view showing Candle Side, Rejection Quality, Confirmation, Failure Risk, and Action.


🚦 Signals & States

• Bullish Rejection → lower wick rejection with stronger close location and sufficient quality.

• Bearish Rejection → upper wick rejection with weaker close location and sufficient quality.

• Awaiting Confirmation → a qualified rejection exists, but price has not accepted beyond the rail.

• Confirmed → price accepted beyond the confirmation rail.

• Failure Edge Broken → the rejection context lost its defined failure edge.

• Target Room Reached → price reached the planning guide mapped from the rejection context.


🔔 Alerts Logic

Alerts can trigger when a qualified rejection candle opens a new context, when confirmation rail acceptance appears, when the failure edge breaks, when target room is reached, or when the active planner state changes.

Alerts are attention markers. They are not trade instructions and do not imply a guaranteed outcome.


🧩 Confluence Logic

The strongest planner states appear when wick dominance, close location, reasonable candle range, supportive volume, and confirmation beyond the rail align together.

When those elements are weaker or delayed, the planner shifts toward monitor, weak confirmation, expired context, or invalidated state.


📊 When to Use

• Price-action review around visible reaction candles

• Liquid symbols where candle range and volume are readable

• Intraday or swing charts where wick rejection can be evaluated with ATR context

• Discretionary planning workflows that need confirmation and failure references


⚠️ When NOT to Use

• Extremely low-liquidity symbols with unreliable candles

• Very noisy low-timeframe charts where wicks appear randomly

• News spikes where candle range is distorted

• Situations where broader market structure is being ignored


🎛️ Key Inputs

• Sensitivity → changes how selective the rejection engine is.

• Minimum Rejection Quality → sets the 0-100 score required before a context appears.

• Dominant Wick Share → controls how much wick dominance is required.

• Close Location Quality → controls how strongly price must close away from the rejected wick.

• Confirmation Window → controls how long the script waits for follow-through.

• Failure Edge Buffer → defines the invalidation reference beyond the rejection wick.

• Target-Room Guide R → draws the planning guide from rejection close to failure edge distance.

• Visual settings → control zones, rails, labels, candle tint, panel location, panel theme, and font sizes.


🖥️ Interface & Visual Design

The interface is intentionally compact and chart-first.

The wick quality zone keeps attention on the candle that created the context. The confirmation rail and failure edge create a structured review path. The AG Pro panel summarizes the current state without covering the chart with a broad dashboard.


🧪 Practical Usage Workflow

1. Read the panel and identify the active candle side.

2. Check the wick quality zone and confirmation rail.

3. Watch whether price confirms, weakens, expires, or breaks the failure edge.

4. Use the target-room guide as a planning reference, not as a promise.


🔍 Interpretation Guidelines

A stronger score means the rejection candle has cleaner wick dominance, better close location, a more useful candle range, and stronger participation support.

A confirmed state means price has accepted beyond the rail according to the script rules.

A failed state means the active rejection context lost its defined failure edge.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a pin bar clone

• Not an engulfing candle detector

• Not a generic support/resistance or order block map


⚠️ Limitations & Transparency

The script is rule-based and depends on candle structure, ATR, relative volume, and follow-through behavior.

Different timeframes can change how rejection appears. Volatility spikes can distort candle range and failure distance. Symbols with unreliable volume may produce weaker participation readings.

Outputs should always be interpreted within broader market structure, liquidity, volatility, and personal risk rules.


🧠 Market Context Notes

Rejection candles often matter more when they appear near meaningful structure, after a directional push, or during a volatility expansion attempt. The script intentionally does not build a full structure map because its narrow job is candle rejection planning.


🧾 Use Case Examples

When a candle prints a strong lower wick, closes high in its range, and then accepts above the confirmation rail, the planner may classify the context as ready for review.

When a strong upper wick appears but price fails to move beyond the confirmation rail and later breaks the failure edge, the planner marks the context as invalidated.


🧱 System Philosophy

AGPro Series tools are designed to convert visual market behavior into structured review states. This script follows that philosophy by turning a single rejection candle into a defined planning context with quality, confirmation, risk, and action fields.


🔐 Non-Promise Statement

No script can provide certainty.

No rejection candle guarantees continuation, reversal, or profitable execution.


📉 Risk Disclosure

Trading involves risk. This script is for technical analysis and educational use only.

Users remain responsible for their own analysis, position sizing, execution decisions, and risk management.

This script does not provide financial advice or guaranteed trading outcomes.


📚 Educational Note

Use the tool to study how rejection candles behave after they appear. The value is in structured observation, not automatic decision-making.

## Source Code

````pine
// -------------------------------------------------
// Candle Rejection Quality Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Candle Rejection Quality Planner is a chart-first rejection-candle decision
// engine that evaluates whether a single wick-led candle creates a useful
// planning context. It maps the wick quality zone, confirmation rail, failure
// edge, target-room guide, a 0-100 rejection quality score, a clear next-action
// state and a persistent confirm-rate proof layer - without becoming a generic
// pin bar marker, engulfing detector, or raw signal tool. Built for rejection
// candle, wick rejection, pin bar context and price-action planning review.
// -------------------------------------------------

//@version=6
indicator("Candle Rejection Quality Planner [AGPro Series]",
     shorttitle = "AG Pro CRQ",
     overlay = true,
     max_boxes_count = 8,
     max_labels_count = 60,
     max_lines_count = 16,
     max_bars_back = 800)

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
string ttSensitivity = "Controls how selective the planner is. Responsive finds more rejection contexts; Strict requires cleaner wick dominance, close location, candle range, and participation."
string ttConfirmMode = "Close Confirmed waits for completed bars before labels and alerts update. Live Updating allows intrabar visual updates."
string ttAtr = "ATR normalizes wick size, candle range, confirmation rail distance, failure edge, target-room guide, and label spacing."
string ttVolume = "Volume baseline used to estimate participation support. When volume is unreliable, disable volume support in the score model."
string ttMinScore = "Minimum 0-100 rejection quality score required before a candle can open a planning context."
string ttConfirmWindow = "Number of bars after the rejection candle where confirmation can still develop before the context ages out."
string ttWick = "Minimum dominant wick share of total candle range. This reads wick-led rejection without requiring a classic pin bar shape."
string ttClose = "Minimum close-location quality required. Bullish rejection prefers a stronger close away from the lower wick; bearish rejection prefers the opposite."
string ttRange = "Preferred candle range in ATR terms. Extremely small candles are weak context; extremely large candles can create distorted risk."
string ttUseVolume = "When enabled, relative volume contributes to rejection quality. When disabled, the volume component becomes neutral."
string ttVolumeWeight = "Controls how much participation affects the final 0-100 score."
string ttConfirmBuffer = "ATR buffer beyond the rejection candle used to draw the confirmation rail."
string ttFailureBuffer = "ATR buffer beyond the rejection wick used to draw the failure edge."
string ttTarget = "R-multiple used to draw the target-room guide from the rejection close and failure edge. It is a planning guide, not a target promise."
string ttMaxAge = "Maximum bars an active rejection context can remain alive without confirmation, failure, or target-room completion."
string ttResolvedBars = "Number of bars a completed, failed, or expired plan remains visible before its active objects are cleared."
string ttZone = "Shows the wick quality zone with centered text. The zone represents the rejected wick area, not a support/resistance zone."
string ttRail = "Shows the confirmation rail that price must accept beyond before the planner upgrades the state."
string ttGuides = "Shows failure edge and target-room guide lines for planning context."
string ttLabels = "Shows compact rejection, confirmation, failure, target-room, and context labels with controlled density."
string ttOutcomeLabels = "Shows failure-edge and target-room completion labels. Disabled by default for a cleaner publication preset; alerts and panel states still track these outcomes."
string ttContext = "Adds sparse active-context labels so the chart remains readable and alive between major events."
string ttScores = "Adds the 0-100 quality score to chart labels."
string ttCandles = "Applies a subtle tint while an active rejection context is being tracked."
string ttCooldown = "Minimum bars between primary event labels. Higher values reduce clustering."
string ttContextSpacing = "Minimum bars between sparse context labels during active planning states."
string ttMaxLabels = "Maximum visible labels retained by the script. Older labels are deleted first for performance."
string ttMaxZones = "Maximum visible wick zones and guide object sets retained on the chart."
string ttProjection = "Number of bars projected to the right for zones, rails, and guide lines."
string ttZoneTransp = "Transparency for wick quality zones. Higher values make the zones more subtle."
string ttOffset = "ATR-based vertical spacing that keeps labels above or below candles."
string ttLabelSize = "Controls every chart label and centered zone label. Normal is the recommended public-release default."
string ttBadgeLanes = "Separates wick-zone, confirmation, failure, target-room, and context badges into ATR-based visual lanes so meaningful labels remain readable without stacking on the same price band."
string ttBadgeSpacing = "Controls the vertical distance between smart badge lanes. Increase it on compressed charts if labels need more breathing room."
string ttPanelShow = "Shows or hides the AG Pro planning panel. It is visible by default for publication-ready first load."
string ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between the premium AGPro dark theme and a clean light theme."
string ttPanelSize = "Controls panel text size. Normal is the recommended public-release default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Candle Rejection Engine"
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = ttSensitivity)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirmMode)
int atrLength = input.int(14, "ATR Length", minval = 3, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 240, group = groupEngine, tooltip = ttVolume)
int minimumQuality = input.int(66, "Minimum Rejection Quality", minval = 30, maxval = 95, group = groupEngine, tooltip = ttMinScore)
int confirmationWindow = input.int(4, "Confirmation Window Bars", minval = 1, maxval = 20, group = groupEngine, tooltip = ttConfirmWindow)

string groupScoring = "Quality Model"
float minimumWickShare = input.float(0.40, "Minimum Dominant Wick Share", minval = 0.10, maxval = 0.90, step = 0.01, group = groupScoring, tooltip = ttWick)
float minimumCloseQuality = input.float(0.60, "Minimum Close Location Quality", minval = 0.35, maxval = 0.90, step = 0.01, group = groupScoring, tooltip = ttClose)
float idealRangeAtr = input.float(1.15, "Ideal Candle Range ATR", minval = 0.20, maxval = 6.00, step = 0.05, group = groupScoring, tooltip = ttRange)
float maximumRangeAtr = input.float(3.40, "Maximum Useful Range ATR", minval = 0.80, maxval = 10.00, step = 0.10, group = groupScoring, tooltip = ttRange)
bool useVolumeSupport = input.bool(true, "Use Volume Support", group = groupScoring, tooltip = ttUseVolume)
float volumeWeight = input.float(0.16, "Volume Score Weight", minval = 0.00, maxval = 0.35, step = 0.01, group = groupScoring, tooltip = ttVolumeWeight)
float confirmationBufferAtr = input.float(0.08, "Confirmation Rail Buffer ATR", minval = 0.00, maxval = 1.20, step = 0.01, group = groupScoring, tooltip = ttConfirmBuffer)
float failureBufferAtr = input.float(0.18, "Failure Edge Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttFailureBuffer)
float targetRoomR = input.float(1.45, "Target-Room Guide R", minval = 0.50, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttTarget)
int maxContextAge = input.int(24, "Max Context Age Bars", minval = 6, maxval = 180, group = groupScoring, tooltip = ttMaxAge)
int resolvedDisplayBars = input.int(12, "Resolved Plan Display Bars", minval = 3, maxval = 60, group = groupScoring, tooltip = ttResolvedBars)

string groupVisual = "Chart Visuals"
bool showWickZone = input.bool(true, "Show Wick Quality Zone", group = groupVisual, tooltip = ttZone)
bool showConfirmationRail = input.bool(true, "Show Confirmation Rail", group = groupVisual, tooltip = ttRail)
bool showRiskTargetGuides = input.bool(false, "Show Failure / Target Guides", group = groupVisual, tooltip = ttGuides)
bool tintActiveCandles = input.bool(true, "Tint Active Context Candles", group = groupVisual, tooltip = ttCandles)
int projectionBars = input.int(24, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
int zoneTransparency = input.int(90, "Zone Transparency", minval = 72, maxval = 96, group = groupVisual, tooltip = ttZoneTransp)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showOutcomeLabels = input.bool(false, "Show Failure / Target Labels", group = groupLabels, tooltip = ttOutcomeLabels)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
bool showLabelScore = input.bool(false, "Show Label Score", group = groupLabels, tooltip = ttScores)
int labelCooldownBars = input.int(24, "Event Label Cooldown", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(48, "Context Label Spacing", minval = 5, maxval = 220, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(10, "Max Visible Labels", minval = 4, maxval = 100, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)
bool useSmartBadgeLanes = input.bool(true, "Use Smart Badge Lanes", group = groupLabels, tooltip = ttBadgeLanes)
float badgeLaneAtr = input.float(0.34, "Badge Lane Spacing ATR", minval = 0.10, maxval = 1.25, step = 0.05, group = groupLabels, tooltip = ttBadgeSpacing)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanelShow)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelSize)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
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

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color bg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = bg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = bg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_grade(float score) =>
    score >= 88.0 ? "A+" : score >= 78.0 ? "A" : score >= 66.0 ? "B" : score >= 54.0 ? "C" : score >= 42.0 ? "D" : "E"

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score_text(float score) =>
    na(score) ? "-" : str.tostring(math.round(score)) + "/100 " + f_grade(score)

f_compact_score(float score) =>
    na(score) ? "Q -" : "Q " + str.tostring(math.round(score))

f_side_color(int side) =>
    side == 1 ? bullColor : side == -1 ? bearColor : neutralColor

f_state_color(string stateText, int side, float score) =>
    color result = score >= 72.0 ? bullColor : score >= 58.0 ? accentColor : neutralColor
    if stateText == "CONFIRMED"
        result := f_side_color(side)
    else if stateText == "FAILED"
        result := dangerColor
    else if stateText == "TARGET ROOM"
        result := bullColor
    else if stateText == "EXPIRED"
        result := color.rgb(100, 116, 139)
    result

f_action_color(string actionText) =>
    switch actionText
        "READY" => bullColor
        "MONITOR" => accentColor
        "WAIT" => neutralColor
        "INVALIDATED" => dangerColor
        "DONE" => bullColor
        "EXPIRED" => color.rgb(100, 116, 139)
        => panelValueCol

f_badge_step(float atrValue) =>
    math.max(atrValue, syminfo.mintick) * badgeLaneAtr

f_rejection_badge_y(float basePrice, int side, int lane, float atrValue) =>
    float dir = side == 1 ? -1.0 : side == -1 ? 1.0 : 1.0
    useSmartBadgeLanes ? basePrice + dir * f_badge_step(atrValue) * lane : basePrice

f_follow_badge_y(float basePrice, int side, int lane, float atrValue) =>
    float dir = side == 1 ? 1.0 : side == -1 ? -1.0 : 1.0
    useSmartBadgeLanes ? basePrice + dir * f_badge_step(atrValue) * lane : basePrice

f_short_state(string stateText) =>
    switch stateText
        "AWAIT CONFIRM" => "WAIT"
        "CONFIRM WEAK" => "WEAK"
        "TARGET ROOM" => "TARGET"
        "CONFIRMED" => "CONFIRM"
        => stateText

f_trim_labels(label[] ids, int limit) =>
    while array.size(ids) > limit
        label oldLabel = array.shift(ids)
        label.delete(oldLabel)

f_trim_boxes(box[] ids, int limit) =>
    while array.size(ids) > limit
        box oldBox = array.shift(ids)
        box.delete(oldBox)

f_trim_lines(line[] ids, int limit) =>
    while array.size(ids) > limit
        line oldLine = array.shift(ids)
        line.delete(oldLine)

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
bool confirmedBar = confirmationMode == "Live Updating" or barstate.isconfirmed
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float volumeAverage = ta.sma(volume, volumeLength)
bool hasVolume = not na(volume) and volumeAverage > 0.0
float rvol = hasVolume ? volume / volumeAverage : 1.0

float wickNeedAdjust = sensitivity == "Responsive" ? -0.04 : sensitivity == "Strict" ? 0.06 : 0.0
float closeNeedAdjust = sensitivity == "Responsive" ? -0.03 : sensitivity == "Strict" ? 0.04 : 0.0
float qualityAdjust = sensitivity == "Responsive" ? -6.0 : sensitivity == "Strict" ? 7.0 : 0.0

float wickNeed = f_clamp(minimumWickShare + wickNeedAdjust, 0.10, 0.88)
float closeNeed = f_clamp(minimumCloseQuality + closeNeedAdjust, 0.35, 0.92)
float qualityNeed = f_clamp(minimumQuality + qualityAdjust, 25.0, 96.0)

float candleRange = math.max(high - low, syminfo.mintick)
float rangeAtr = candleRange / safeAtr
float bodyTop = math.max(open, close)
float bodyBottom = math.min(open, close)
float upperWick = high - bodyTop
float lowerWick = bodyBottom - low
float upperWickShare = upperWick / candleRange
float lowerWickShare = lowerWick / candleRange
float closeLocation = (close - low) / candleRange

float bullCloseQuality = closeLocation
float bearCloseQuality = 1.0 - closeLocation
bool bullCandidateRaw = lowerWickShare >= wickNeed and bullCloseQuality >= closeNeed and lowerWick > upperWick
bool bearCandidateRaw = upperWickShare >= wickNeed and bearCloseQuality >= closeNeed and upperWick > lowerWick

float bullWickScore = f_norm_high_good(lowerWickShare, wickNeed, 0.72)
float bearWickScore = f_norm_high_good(upperWickShare, wickNeed, 0.72)
float bullCloseScore = f_norm_high_good(bullCloseQuality, closeNeed, 0.86)
float bearCloseScore = f_norm_high_good(bearCloseQuality, closeNeed, 0.86)
float rangeScore = f_peak_score(rangeAtr, 0.22, idealRangeAtr, maximumRangeAtr)
float volumeScore = useVolumeSupport ? f_norm_high_good(rvol, 0.80, 1.85) : 62.0
float volumeWeightClamped = f_clamp(volumeWeight, 0.0, 0.35)
float structuralWeight = 1.0 - volumeWeightClamped

float bullBaseScore = (bullWickScore * 0.36 + bullCloseScore * 0.34 + rangeScore * 0.30) * structuralWeight + volumeScore * volumeWeightClamped
float bearBaseScore = (bearWickScore * 0.36 + bearCloseScore * 0.34 + rangeScore * 0.30) * structuralWeight + volumeScore * volumeWeightClamped
int eventSide = bullCandidateRaw and bullBaseScore >= bearBaseScore ? 1 : bearCandidateRaw ? -1 : 0
float eventScore = eventSide == 1 ? bullBaseScore : eventSide == -1 ? bearBaseScore : na
bool qualifiedEvent = confirmedBar and eventSide != 0 and eventScore >= qualityNeed

// -------------------------------------------------
// State
// -------------------------------------------------
var label[] chartLabels = array.new_label()
var box[] wickZones = array.new_box()
var line[] guideLines = array.new_line()

var int activeSide = 0
var int activeStartBar = na
var float activeBaseScore = na
var float activeScore = na
var float activeRvol = na
var float activeWickShare = na
var float activeCloseQuality = na
var float activeRangeAtr = na
var float activeAtr = na
var float activeClose = na
var float activeConfirmRail = na
var float activeFailureEdge = na
var float activeTargetGuide = na
var string activeState = "WAIT"
var bool activeConfirmed = false
var bool activeFailed = false
var bool activeTargetReached = false
var bool activeExpired = false
var int activeResolvedBar = na
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var box activeZone = na
var label activeZoneLabel = na
var line activeConfirmLine = na
var line activeFailureLine = na
var line activeTargetLine = na
var label activeConfirmTag = na
var label activeFailureTag = na
var label activeTargetTag = na

// Confirm-rate proof layer
var bool proofArmed = false
var int proofTotal = 0
var int proofWin = 0

bool newRejectionEvent = false
bool newConfirmationEvent = false
bool newFailureEvent = false
bool newTargetRoomEvent = false
bool newStateShift = false

f_add_label(int x, float y, string labelText, string styleValue, color bgColor) =>
    if showEventLabels
        label newLabel = label.new(x = x, y = y, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = styleValue, color = color.new(bgColor, 6), textcolor = f_text_on(bgColor), size = f_text_size(labelFontSize))
        array.push(chartLabels, newLabel)
        f_trim_labels(chartLabels, maxVisibleLabels)

f_add_context_label(int x, float y, string labelText, string styleValue, color bgColor) =>
    if showContextLabels
        label newLabel = label.new(x = x, y = y, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = styleValue, color = color.new(bgColor, 35), textcolor = f_text_on(bgColor), size = f_text_size(labelFontSize))
        array.push(chartLabels, newLabel)
        f_trim_labels(chartLabels, maxVisibleLabels)

f_zone_badge(int x, float y, string labelText, color bgColor) =>
    label.new(x = x, y = y, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bgColor, 8), textcolor = f_text_on(bgColor), size = f_text_size(labelFontSize))

// -------------------------------------------------
// New Rejection Context
// -------------------------------------------------
bool labelCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars

if qualifiedEvent and labelCooldownReady
    // Resolve the previous context for the proof layer if it is being replaced
    if proofArmed
        proofTotal += 1
        if activeConfirmed or activeTargetReached
            proofWin += 1
    proofArmed := true

    if not na(activeZone)
        box.delete(activeZone)
        activeZone := na
    if not na(activeZoneLabel)
        label.delete(activeZoneLabel)
        activeZoneLabel := na
    if not na(activeConfirmLine)
        line.delete(activeConfirmLine)
        activeConfirmLine := na
    if not na(activeFailureLine)
        line.delete(activeFailureLine)
        activeFailureLine := na
    if not na(activeTargetLine)
        line.delete(activeTargetLine)
        activeTargetLine := na
    if not na(activeConfirmTag)
        label.delete(activeConfirmTag)
        activeConfirmTag := na
    if not na(activeFailureTag)
        label.delete(activeFailureTag)
        activeFailureTag := na
    if not na(activeTargetTag)
        label.delete(activeTargetTag)
        activeTargetTag := na
    activeSide := eventSide
    activeStartBar := bar_index
    activeBaseScore := eventScore
    activeScore := eventScore
    activeRvol := rvol
    activeWickShare := eventSide == 1 ? lowerWickShare : upperWickShare
    activeCloseQuality := eventSide == 1 ? bullCloseQuality : bearCloseQuality
    activeRangeAtr := rangeAtr
    activeAtr := safeAtr
    activeClose := close
    activeConfirmed := false
    activeFailed := false
    activeTargetReached := false
    activeExpired := false
    activeResolvedBar := na
    activeState := "AWAIT CONFIRM"

    float confirmBuffer = safeAtr * confirmationBufferAtr
    float failureBuffer = safeAtr * failureBufferAtr
    activeConfirmRail := eventSide == 1 ? high + confirmBuffer : low - confirmBuffer
    activeFailureEdge := eventSide == 1 ? low - failureBuffer : high + failureBuffer
    float riskDistance = math.max(math.abs(activeClose - activeFailureEdge), safeAtr * 0.25)
    activeTargetGuide := eventSide == 1 ? activeClose + riskDistance * targetRoomR : activeClose - riskDistance * targetRoomR

    float zoneTop = eventSide == 1 ? bodyBottom : high
    float zoneBottom = eventSide == 1 ? low : bodyTop
    string sideText = eventSide == 1 ? "BULL" : "BEAR"
    color sideColor = f_side_color(eventSide)
    string zoneText = sideText + " REJECTION | AWAIT " + f_compact_score(eventScore)
    if showLabelScore
        zoneText := sideText + " REJECTION | AWAIT " + f_compact_score(eventScore)
    int zoneCenterX = int(math.round((bar_index + bar_index + projectionBars) / 2.0))
    float zoneCenterY = (zoneTop + zoneBottom) / 2.0
    activeZone := box.new(left = bar_index, top = zoneTop, right = bar_index + projectionBars, bottom = zoneBottom, xloc = xloc.bar_index,
         bgcolor = showWickZone ? color.new(sideColor, zoneTransparency) : color.new(sideColor, 100),
         border_color = showWickZone ? color.new(sideColor, 8) : color.new(sideColor, 100),
         border_width = 1,
         text = "",
         text_color = headerText,
         text_size = f_text_size(labelFontSize),
         text_halign = text.align_center,
         text_valign = text.align_center)
    if showWickZone
        activeZoneLabel := f_zone_badge(zoneCenterX, zoneCenterY, zoneText, sideColor)
    activeConfirmLine := line.new(x1 = bar_index, y1 = activeConfirmRail, x2 = bar_index + projectionBars, y2 = activeConfirmRail, xloc = xloc.bar_index,
         color = showConfirmationRail ? color.new(accentColor, 0) : color.new(accentColor, 100), style = line.style_dashed, width = 1)
    activeFailureLine := line.new(x1 = bar_index, y1 = activeFailureEdge, x2 = bar_index + projectionBars, y2 = activeFailureEdge, xloc = xloc.bar_index,
         color = showRiskTargetGuides ? color.new(dangerColor, 0) : color.new(dangerColor, 100), style = line.style_dotted, width = 1)
    activeTargetLine := line.new(x1 = bar_index, y1 = activeTargetGuide, x2 = bar_index + projectionBars, y2 = activeTargetGuide, xloc = xloc.bar_index,
         color = showRiskTargetGuides ? color.new(bullColor, 0) : color.new(bullColor, 100), style = line.style_dashed, width = 1)

    int confirmTagX = bar_index + projectionBars + 2
    activeConfirmTag := label.new(confirmTagX, activeConfirmRail, "CONFIRM " + f_price(activeConfirmRail), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 6), textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize))
    activeFailureTag := label.new(confirmTagX + 8, activeFailureEdge, "FAIL " + f_price(activeFailureEdge), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 6), textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize))
    activeTargetTag := label.new(confirmTagX + 16, activeTargetGuide, "TARGET " + f_price(activeTargetGuide), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 6), textcolor = f_text_on(bullColor), size = f_text_size(labelFontSize))

    string labelText = sideText + " REJECTION"
    if showLabelScore
        labelText += " " + f_compact_score(eventScore)
    float labelY = useSmartBadgeLanes ? f_rejection_badge_y(activeClose, eventSide, 2, safeAtr) : (eventSide == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr)
    string labelStyle = eventSide == 1 ? label.style_label_up : label.style_label_down
    f_add_label(bar_index, labelY, labelText, labelStyle, sideColor)
    lastEventLabelBar := bar_index
    lastContextLabelBar := bar_index
    newRejectionEvent := true
    newStateShift := true

// -------------------------------------------------
// Active Context Tracking
// -------------------------------------------------
bool hasActive = activeSide != 0 and not na(activeStartBar)
int activeAge = hasActive ? bar_index - activeStartBar : 0

if hasActive
    float confirmProgress = activeSide == 1 ? (close - activeClose) / math.max(activeConfirmRail - activeClose, syminfo.mintick) : (activeClose - close) / math.max(activeClose - activeConfirmRail, syminfo.mintick)
    float targetProgress = activeSide == 1 ? (high - activeClose) / math.max(activeTargetGuide - activeClose, syminfo.mintick) : (activeClose - low) / math.max(activeClose - activeTargetGuide, syminfo.mintick)
    float pressureAgainst = activeSide == 1 ? (activeClose - low) / activeAtr : (high - activeClose) / activeAtr
    float confirmationBonus = f_clamp(confirmProgress, 0.0, 1.0) * 16.0
    float targetBonus = f_clamp(targetProgress, 0.0, 1.0) * 8.0
    float pressurePenalty = f_norm_high_good(pressureAgainst, 0.25, 1.75) * 0.12
    float timePenalty = f_norm_high_good(activeAge, confirmationWindow, maxContextAge) * 0.10
    if not activeFailed and not activeTargetReached and not activeExpired
        activeScore := f_clamp(activeBaseScore + confirmationBonus + targetBonus - pressurePenalty - timePenalty, 0.0, 100.0)

    bool transitionReady = confirmationMode == "Live Updating" or barstate.isconfirmed
    bool failHit = transitionReady and (activeSide == 1 ? close < activeFailureEdge : close > activeFailureEdge)
    bool confirmHit = transitionReady and (activeSide == 1 ? close > activeConfirmRail : close < activeConfirmRail)
    bool targetHit = transitionReady and (activeSide == 1 ? close >= activeTargetGuide : close <= activeTargetGuide)
    bool confirmExpired = activeAge > confirmationWindow and not activeConfirmed and not activeFailed
    bool contextExpired = activeAge > maxContextAge and not activeFailed and not activeTargetReached

    if not activeFailed and not activeTargetReached and not activeExpired and failHit
        activeFailed := true
        activeState := "FAILED"
        activeResolvedBar := bar_index
        float failY = useSmartBadgeLanes ? f_rejection_badge_y(activeFailureEdge, activeSide, 2, safeAtr) : (activeSide == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr)
        string failStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
        if showOutcomeLabels
            f_add_label(bar_index, failY, "FAILURE BROKEN", failStyle, dangerColor)
        newFailureEvent := true
        newStateShift := true

    else if not activeTargetReached and not activeExpired and targetHit
        activeConfirmed := true
        activeTargetReached := true
        activeState := "TARGET ROOM"
        activeResolvedBar := bar_index
        float targetY = useSmartBadgeLanes ? f_follow_badge_y(activeTargetGuide, activeSide, 1, safeAtr) : (activeSide == 1 ? high + safeAtr * (labelOffsetAtr + 0.22) : low - safeAtr * (labelOffsetAtr + 0.22))
        string targetStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
        if showOutcomeLabels
            f_add_label(bar_index, targetY, "TARGET REACHED", targetStyle, bullColor)
        newTargetRoomEvent := true
        newStateShift := true

    else if not activeConfirmed and not activeExpired and confirmHit
        activeConfirmed := true
        activeState := "CONFIRMED"
        newConfirmationEvent := true
        newStateShift := true

    if not activeFailed and not activeConfirmed and confirmExpired
        activeState := "CONFIRM WEAK"
        if showContextLabels and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
            float weakY = useSmartBadgeLanes ? f_follow_badge_y(activeConfirmRail, activeSide, 2, safeAtr) : (activeSide == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr)
            string weakStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
            f_add_context_label(bar_index, weakY, "CONFIRM WEAK", weakStyle, neutralColor)
            lastContextLabelBar := bar_index

    if not activeFailed and not activeTargetReached and not activeExpired and contextExpired
        activeExpired := true
        activeState := "EXPIRED"
        activeResolvedBar := bar_index
        if showContextLabels and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
            float expireY = useSmartBadgeLanes ? f_rejection_badge_y(activeClose, activeSide, 3, safeAtr) : (activeSide == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr)
            string expireStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
            f_add_context_label(bar_index, expireY, "CONTEXT EXPIRED", expireStyle, color.rgb(100, 116, 139))
            lastContextLabelBar := bar_index
        newStateShift := true

    if not activeFailed and not activeTargetReached and not activeExpired and showContextLabels and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
        string contextText = activeConfirmed ? "FOLLOW TRACK" : "AWAIT CONFIRM"
        float contextY = useSmartBadgeLanes ? (activeConfirmed ? f_follow_badge_y(activeConfirmRail, activeSide, 2, safeAtr) : f_rejection_badge_y(activeClose, activeSide, 3, safeAtr)) : (activeSide == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr)
        string contextStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
        f_add_context_label(bar_index, contextY, contextText, contextStyle, activeConfirmed ? f_side_color(activeSide) : accentColor)
        lastContextLabelBar := bar_index

    if not na(activeZone)
        string sideTextUpdate = activeSide == 1 ? "BULL" : "BEAR"
        string boxText = sideTextUpdate + " REJECTION | " + f_short_state(activeState)
        if showLabelScore
            boxText += " " + f_compact_score(activeScore)
        color zStateCol = f_state_color(activeState, activeSide, activeScore)
        box.set_right(activeZone, bar_index + projectionBars)
        box.set_text(activeZone, "")
        box.set_bgcolor(activeZone, showWickZone ? color.new(zStateCol, zoneTransparency) : color.new(zStateCol, 100))
        box.set_border_color(activeZone, showWickZone ? color.new(zStateCol, 8) : color.new(zStateCol, 100))
        if showWickZone and not na(activeZoneLabel)
            label.set_x(activeZoneLabel, int(math.round((activeStartBar + bar_index + projectionBars) / 2.0)))
            label.set_y(activeZoneLabel, (box.get_top(activeZone) + box.get_bottom(activeZone)) / 2.0)
            label.set_text(activeZoneLabel, boxText)
            label.set_color(activeZoneLabel, color.new(zStateCol, 8))
            label.set_textcolor(activeZoneLabel, f_text_on(zStateCol))
            label.set_size(activeZoneLabel, f_text_size(labelFontSize))
    if not na(activeConfirmLine)
        line.set_x2(activeConfirmLine, bar_index + projectionBars)
        line.set_color(activeConfirmLine, showConfirmationRail ? color.new(accentColor, 0) : color.new(accentColor, 100))
    if not na(activeFailureLine)
        line.set_x2(activeFailureLine, bar_index + projectionBars)
        line.set_color(activeFailureLine, showRiskTargetGuides ? color.new(dangerColor, 0) : color.new(dangerColor, 100))
    if not na(activeTargetLine)
        line.set_x2(activeTargetLine, bar_index + projectionBars)
        line.set_color(activeTargetLine, showRiskTargetGuides ? color.new(bullColor, 0) : color.new(bullColor, 100))
    int guideTagX = bar_index + projectionBars + 2
    if not na(activeConfirmTag)
        label.set_x(activeConfirmTag, guideTagX)
        label.set_y(activeConfirmTag, activeConfirmRail)
        label.set_color(activeConfirmTag, showConfirmationRail ? color.new(accentColor, 6) : color.new(accentColor, 100))
        label.set_textcolor(activeConfirmTag, showConfirmationRail ? f_text_on(accentColor) : color.new(headerText, 100))
    if not na(activeFailureTag)
        label.set_x(activeFailureTag, guideTagX + 8)
        label.set_y(activeFailureTag, activeFailureEdge)
        label.set_color(activeFailureTag, showRiskTargetGuides ? color.new(dangerColor, 6) : color.new(dangerColor, 100))
        label.set_textcolor(activeFailureTag, showRiskTargetGuides ? f_text_on(dangerColor) : color.new(headerText, 100))
    if not na(activeTargetTag)
        label.set_x(activeTargetTag, guideTagX + 16)
        label.set_y(activeTargetTag, activeTargetGuide)
        label.set_color(activeTargetTag, showRiskTargetGuides ? color.new(bullColor, 6) : color.new(bullColor, 100))
        label.set_textcolor(activeTargetTag, showRiskTargetGuides ? f_text_on(bullColor) : color.new(headerText, 100))

    bool resolvedDisplayComplete = not na(activeResolvedBar) and bar_index - activeResolvedBar > resolvedDisplayBars
    if resolvedDisplayComplete
        if not na(activeZone)
            box.delete(activeZone)
            activeZone := na
        if not na(activeZoneLabel)
            label.delete(activeZoneLabel)
            activeZoneLabel := na
        if not na(activeConfirmLine)
            line.delete(activeConfirmLine)
            activeConfirmLine := na
        if not na(activeFailureLine)
            line.delete(activeFailureLine)
            activeFailureLine := na
        if not na(activeTargetLine)
            line.delete(activeTargetLine)
            activeTargetLine := na
        if not na(activeConfirmTag)
            label.delete(activeConfirmTag)
            activeConfirmTag := na
        if not na(activeFailureTag)
            label.delete(activeFailureTag)
            activeFailureTag := na
        if not na(activeTargetTag)
            label.delete(activeTargetTag)
            activeTargetTag := na
        activeSide := 0
        activeStartBar := na

// -------------------------------------------------
// Confirm-rate proof resolution (confirmed-bar gated)
// -------------------------------------------------
if barstate.isconfirmed and proofArmed and hasActive and (activeFailed or activeExpired or activeTargetReached)
    proofTotal += 1
    if activeConfirmed or activeTargetReached
        proofWin += 1
    proofArmed := false

float confirmRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na

// -------------------------------------------------
// Output Text
// -------------------------------------------------
string candleSideText = hasActive ? activeSide == 1 ? "Bullish Rejection" : "Bearish Rejection" : "No active candle"
string qualityText = hasActive ? f_score_text(activeScore) : "-"
string confirmationText = "Waiting"
if hasActive
    confirmationText := activeFailed ? "Failed" : activeTargetReached ? "Target Room" : activeConfirmed ? "Confirmed" : activeExpired ? "Expired" : activeAge > confirmationWindow ? "Weak" : "Awaiting"
string failureRiskText = hasActive ? activeFailed ? "Broken" : activeConfirmed ? "Controlled" : "Watch " + f_price(activeFailureEdge) : "-"
string actionText = "WAIT"
if hasActive
    actionText := activeFailed ? "INVALIDATED" : activeTargetReached ? "DONE" : activeExpired ? "EXPIRED" : activeConfirmed and activeScore >= qualityNeed ? "READY" : activeScore >= qualityNeed ? "MONITOR" : "WAIT"
color activeValueColor = hasActive ? f_state_color(activeState, activeSide, activeScore) : f_panel_value(panelTheme)
string confirmRateText = na(confirmRate) ? "Building" : str.tostring(math.round(confirmRate)) + "% (" + str.tostring(proofTotal) + ")"
color confirmRateColor = na(confirmRate) ? f_panel_value(panelTheme) : confirmRate >= 55.0 ? bullColor : confirmRate >= 40.0 ? neutralColor : bearColor

barcolor(tintActiveCandles and hasActive and not activeFailed and not activeTargetReached and not activeExpired ? color.new(f_side_color(activeSide), 84) : na)
plot(hasActive and showConfirmationRail ? activeConfirmRail : na, "Confirmation Rail", color = color.new(accentColor, 65), linewidth = 1, style = plot.style_linebr)
plot(hasActive and showRiskTargetGuides ? activeFailureEdge : na, "Failure Edge", color = color.new(dangerColor, 68), linewidth = 1, style = plot.style_linebr)
plot(hasActive and showRiskTargetGuides ? activeTargetGuide : na, "Target-Room Guide", color = color.new(bullColor, 70), linewidth = 1, style = plot.style_linebr)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_panel_position(panelLocation), 2, 7,
     bgcolor = f_panel_bg(panelTheme),
     frame_color = f_panel_border(panelTheme),
     border_color = f_panel_border(panelTheme),
     border_width = 1)
if barstate.islast
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.cell(panel, 0, 0, "", bgcolor = headerBg)
        table.cell(panel, 1, 0, "", bgcolor = headerBg)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Candle Rejection Quality Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(panel, 1, "Candle Side", candleSideText, activeValueColor, panelTheme, panelFontSize)
        f_panel_row(panel, 2, "Rejection Quality", qualityText, activeValueColor, panelTheme, panelFontSize)
        f_panel_row(panel, 3, "Confirmation", confirmationText, activeValueColor, panelTheme, panelFontSize)
        f_panel_row(panel, 4, "Failure Risk", failureRiskText, activeFailed ? dangerColor : activeValueColor, panelTheme, panelFontSize)
        f_panel_row(panel, 5, "Action", actionText, f_action_color(actionText), panelTheme, panelFontSize)
        f_panel_row(panel, 6, "Confirm Rate", confirmRateText, confirmRateColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newRejectionEvent, title = "Candle Rejection Context", message = "Candle Rejection Quality Planner: a qualified rejection candle opened a planning context.")
alertcondition(newConfirmationEvent, title = "Confirmation Rail Accepted", message = "Candle Rejection Quality Planner: price accepted beyond the confirmation rail for the active rejection context.")
alertcondition(newFailureEvent, title = "Failure Edge Broken", message = "Candle Rejection Quality Planner: price broke the failure edge for the active rejection context.")
alertcondition(newTargetRoomEvent, title = "Target Room Reached", message = "Candle Rejection Quality Planner: the active rejection context reached its target-room guide.")
alertcondition(newStateShift, title = "Rejection Planner State Shift", message = "Candle Rejection Quality Planner: the active rejection context changed state.")
````
