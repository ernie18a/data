# Round Number Rejection Planner [AGPro Series]

- url: https://www.tradingview.com/script/wVFp6dc3-Round-Number-Rejection-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;65338ca674664d53bb7e509c90b668c1
- version: 6.0

## Description

# Round Number Rejection Planner [AGPro Series]

🧠 Core Idea

Is the round number acting as rejection, magnet, or failed reference?

📌 Overview / What it does

Round Number Rejection Planner is a psychological price level decision-support script built to evaluate how price reacts around nearby round numbers.

The script maps adaptive round-number bands, detects wick-based rejection behavior, separates rejection from magnet conditions, scores the context from 0 to 100, and summarizes the current state inside a compact AG Pro panel.

It does not predict price direction, automate trades, or provide guaranteed signals. It is designed to organize round-number context, rejection quality, distance, failure risk, and action state into a clean visual workflow.

🎯 Purpose & Design Philosophy

Round numbers often attract attention because they are easy reference points for traders, algorithms, stops, targets, and liquidity.

This script was built for traders who want to evaluate whether price is respecting a psychological level, getting pulled toward it, or failing to reject it cleanly.

The design supports structured observation instead of treating every round-number touch as a signal.

⚡ Why This Script Is Different

Most tools draw psychological levels or mark round numbers.

This script does NOT stop at drawing levels.

Instead, it evaluates the behavior around the level: wick rejection, close location, distance, reaction count, volatility fit, and failure risk.

⚙️ Methodology

1. Adaptive Round Level Detection
2. Psychological Band Mapping
3. Wick Rejection Evaluation
4. Magnet And Failure Risk Detection
5. 0-100 Rejection Score
6. Panel And Alert Output

🗺️ How to Read the Chart

The active round band marks the nearest psychological price zone.

Nearby round rails show the next upper and lower round references.

READY REJECTION labels appear when wick response, close location, and score quality align.

Magnet or failed-reference states appear when price interacts with the level without a clean rejection.

The panel summarizes Round Level, Rejection Score, Distance, Failure Risk, and Action.

🚦 Signals & States

• READY → A qualified round-number rejection has formed.

• MONITOR → Price is near the round number but rejection quality is not yet strong enough.

• WAIT → No active round-number context is close enough to evaluate.

• INVALIDATED → Price failed through the level instead of rejecting it.

• BLOCKED → The script cannot define a valid round-number context.

🔔 Alerts Logic

Bullish Round Number Rejection Ready triggers when price rejects upward from a round-number band with enough quality.

Bearish Round Number Rejection Ready triggers when price rejects downward from a round-number band with enough quality.

Round Number Magnet Warning triggers when price is close to the level but rejection quality is weak.

Round Number Rejection Invalidated triggers when price fails through the level instead of respecting it.

Alerts are attention markers, not trade instructions.

🧩 Confluence Logic

The rejection score combines wick strength, close distance from the level, proximity, recent reaction count, relative volume, and volatility fit.

When several of these conditions align, the context becomes stronger.

When they do not align, the script remains in WAIT, MONITOR, INVALIDATED, or BLOCKED state.

📊 When to Use

• Psychological level analysis

• Intraday price action workflows

• Round-number rejection setups

• Stop and liquidity reaction observation

• Support and resistance context around visible price levels

⚠️ When NOT to Use

Avoid relying on this script in extremely illiquid markets, very noisy symbols, holiday sessions, or conditions where round numbers are not meaningful to participants.

It should not be used as a standalone decision tool without broader market context, risk planning, and independent confirmation.

🎛️ Key Inputs

• Round Level Mode controls whether level spacing is automatic or manual.

• Manual Round Step defines custom level spacing when manual mode is selected.

• Round Band ATR controls the width of the psychological level band.

• Max Active Distance controls how close price must be before evaluation begins.

• Minimum Ready Score controls how strong the rejection must be before READY appears.

• Failure Risk Threshold controls when weak rejection or magnet behavior blocks READY.

• Visual settings control bands, rails, labels, right-side tags, panel location, and font size.

🖥️ Interface & Visual Design

The interface is designed to make the active psychological level readable without flooding the chart.

The chart shows the active round band, nearby round rails, failure shelf, and relevant rejection labels.

The AG Pro panel provides compact decision context while preserving chart visibility.

🧪 Practical Usage Workflow

1. Check the active round level in the panel.

2. Observe whether price is touching or rejecting the round band.

3. Read the rejection score and failure risk.

4. Check whether the action state is READY, MONITOR, WAIT, INVALIDATED, or BLOCKED.

5. Confirm the context with broader trend, liquidity, volatility, and risk structure.

🔍 Interpretation Guidelines

A higher rejection score means the round-number reaction is cleaner according to the script logic.

A high failure risk means the level may be acting more like a magnet or failed reference.

READY means the rejection context deserves attention, not that price must reverse.

MONITOR means price is near the level but the reaction is not yet clean enough.

🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.

It does not replace risk management or independent analysis.

⚠️ Limitations & Transparency

Round-number behavior changes across markets, symbols, timeframes, volatility regimes, and liquidity conditions.

The score is rule-based and depends on wick behavior, close location, distance, relative volume, and ATR normalization.

Different symbols may require different round-step or sensitivity settings.

🧠 Market Context Notes

Round-number rejection can be more meaningful when aligned with liquidity response, trend context, session timing, volume participation, and nearby structure.

Weak rejection near a level can become magnet behavior instead of a clean turn.

🔐 Non-Promise Statement

No script can guarantee future price behavior.

This tool provides structured visual context only.

📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions.

This script is for educational and analytical purposes only and does not provide financial advice or guaranteed trading outcomes.

## Source Code

````pine
// -------------------------------------------------
// Round Number Rejection Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.4.1
//
// Round Number Rejection Planner is a psychological price level decision
// engine that evaluates whether the nearest round number is acting as a
// clean rejection point, a magnet, or a failed reference. It maps adaptive
// round-number bands, nearby rails, invalidation shelf context, 0-100
// rejection quality, and a clear next-action state.
// Version 2.4.1 adds full badge coverage for every visible guide line,
// including compact nearby rails, while preserving the Version 2.4 logic
// for Proof integrity, confirmed calls, and right-edge efficiency.
// -------------------------------------------------

//@version=6
indicator("Round Number Rejection Planner [AGPro Series]",
     shorttitle       = "AG Pro RNR",
     overlay          = true,
     max_boxes_count  = 16,
     max_labels_count = 100,
     max_lines_count  = 20,
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

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttLevelMode = "Auto adapts the round-number step to the symbol price. Manual lets users define the exact level step."
string ttManualStep = "Manual round-number interval used when Round Level Mode is set to Manual."
string ttAtr = "ATR normalizes band width, distance, failure risk, label offsets, and shelf height."
string ttBand = "ATR-based width around the selected round number where rejection and magnet behavior are evaluated."
string ttDistance = "Maximum distance from the nearest round number before the planner waits instead of evaluating."
string ttConfirm = "Fast reacts earlier, Balanced requires cleaner wick and close response, and Strict demands stronger rejection quality."
string ttMinScore = "Minimum rejection score required before READY appears."
string ttLookback = "Lookback used to count recent interactions around the active round number."
string ttVolume = "Adds relative volume participation to the rejection score."
string ttVolLen = "Lookback used to compare current volume against recent average participation."
string ttRisk = "High failure risk prevents READY and indicates that price may be treating the level as a magnet or failed reference."
string ttInvalid = "ATR-based close-through distance that invalidates a rejection context."
string ttBandShow = "Shows the active psychological level band around the nearest round number. Text is centered inside the band."
string ttRails = "Shows nearby upper and lower round-number rails as subtle context so the chart does not feel empty."
string ttShelf = "Shows a compact shelf beyond the level where rejection failure becomes more likely."
string ttLabels = "Shows premium READY rejection labels on the chart."
string ttMagnet = "Shows magnet warning labels. Disabled by default for cleaner publication screenshots."
string ttFailed = "Shows failed-reference labels. Disabled by default to keep publication screenshots clean."
string ttTags = "Shows compact right-side tags for the active round level and optional nearby context."
string ttTagDetail = "Controls right-side tag density. Compact shows only the decision-critical active/failure reference, while Full also shows nearby upper and lower rails."
string ttTagOffset = "Horizontal offset used to place right-side tags beyond the projected level lines."
string ttBars = "Colors bars lightly when a round-number state is active."
string ttProjection = "How far the active band, rails, and invalidation shelf project to the right."
string ttLabelSize = "Controls chart label, right-side tag, and centered zone text size. Normal is the recommended publication default."
string ttOffset = "ATR-based vertical spacing used to keep labels away from candles."
string ttMaxLabels = "Maximum number of event labels retained on chart."
string ttCooldown = "Minimum bars between repeated event labels. Higher values reduce clustering."
string ttPanel = "Displays the AG Pro decision panel. Enabled by default."
string ttPanelLoc = "Controls where the AG Pro panel appears on chart."
string ttPanelTheme = "Switches the panel between the premium AGPro dark theme and a clean light theme."
string ttPanelSize = "Controls text size inside the decision panel. Normal is the recommended publication default."
string ttAlertReady = "Creates an alert condition when a round-number rejection becomes READY."
string ttAlertMagnet = "Creates an alert condition when price is close to a round number but rejection quality is weak."
string ttAlertInvalid = "Creates an alert condition when rejection fails through the round number."

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

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

f_panel_bg(string themeText) =>
    themeText == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string themeText) =>
    themeText == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string themeText) =>
    themeText == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeText) =>
    themeText == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeText, int row) =>
    bool evenRow = row % 2 == 0
    if themeText == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string themeText, string fontSizeText) =>
    color rowBg = f_row_bg(themeText, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(themeText), bgcolor = rowBg, text_size = f_text_size(fontSizeText), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSizeText), text_halign = text.align_right)

f_grade(float score) =>
    string result = "D"
    if score >= 85
        result := "A+"
    else if score >= 75
        result := "A"
    else if score >= 65
        result := "B"
    else if score >= 55
        result := "C"
    result

f_score_text(float score) =>
    na(score) ? "-" : str.tostring(math.round(score)) + "/100 " + f_grade(score)

f_score_color(float score, int readyScore, int watchScore) =>
    score >= readyScore ? bullColor : score >= watchScore ? accentColor : score >= 40 ? neutralColor : bearColor

f_action_color(string actionText) =>
    switch actionText
        "READY" => bullColor
        "MONITOR" => accentColor
        "WAIT" => neutralColor
        "INVALIDATED" => bearColor
        "BLOCKED" => panelLabelCol
        => panelValueCol

f_rate_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_auto_step(float priceValue) =>
    float p = math.abs(priceValue)
    p >= 10000 ? 1000.0 : p >= 1000 ? 100.0 : p >= 100 ? 10.0 : p >= 10 ? 1.0 : p >= 1 ? 0.1 : p >= 0.1 ? 0.01 : p >= 0.01 ? 0.001 : 0.0001

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_badge_set(label id, int xValue, float yValue, string textValue, color bgValue, string sizeValue) =>
    label result = id
    if na(result)
        result := label.new(x = xValue, y = yValue, text = textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bgValue, 0), textcolor = headerText, size = f_text_size(sizeValue), textalign = text.align_center)
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, textValue)
        label.set_color(result, color.new(bgValue, 0))
        label.set_textcolor(result, headerText)
        label.set_size(result, f_text_size(sizeValue))
    result

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupLevel = "Round Level Engine"
string groupScore = "Rejection Engine"
string groupVisual = "Chart Visuals"
string groupPanel = "Panel"
string groupAlerts = "Alerts"

levelMode = input.string("Auto", "Round Level Mode", options = ["Auto", "Manual"], group = groupLevel, tooltip = ttLevelMode)
manualStep = input.float(1.0, "Manual Round Step", minval = 0.00000001, maxval = 1000000.0, step = 0.0001, group = groupLevel, tooltip = ttManualStep)
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupLevel, tooltip = ttAtr)
bandAtr = input.float(0.18, "Round Band ATR", minval = 0.02, maxval = 3.00, step = 0.01, group = groupLevel, tooltip = ttBand)
maxDistanceAtr = input.float(1.20, "Max Active Distance ATR", minval = 0.10, maxval = 10.00, step = 0.05, group = groupLevel, tooltip = ttDistance)

confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = groupScore, tooltip = ttConfirm)
minReadyScore = input.int(64, "Minimum Ready Score", minval = 1, maxval = 100, group = groupScore, tooltip = ttMinScore)
watchScore = input.int(52, "Monitor Score", minval = 1, maxval = 100, group = groupScore, tooltip = "Score used for MONITOR context in the panel and data window.")
reactionLookback = input.int(80, "Reaction Count Lookback", minval = 10, maxval = 500, group = groupScore, tooltip = ttLookback)
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = groupScore, tooltip = ttVolume)
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = groupScore, tooltip = ttVolLen)
failureRiskThreshold = input.int(68, "Failure Risk Threshold", minval = 1, maxval = 100, group = groupScore, tooltip = ttRisk)
invalidationBufferAtr = input.float(0.08, "Invalidation Buffer ATR", minval = 0.0, maxval = 3.0, step = 0.01, group = groupScore, tooltip = ttInvalid)

showRoundBand = input.bool(true, "Show Active Round Band", group = groupVisual, tooltip = ttBandShow)
showNearbyLevels = input.bool(true, "Show Nearby Round Rails", group = groupVisual, tooltip = ttRails)
showInvalidationShelf = input.bool(true, "Show Invalidation Shelf", group = groupVisual, tooltip = ttShelf)
showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = ttLabels)
showMagnetLabels = input.bool(false, "Show Magnet Labels", group = groupVisual, tooltip = ttMagnet)
showFailedLabels = input.bool(false, "Show Failed Level Labels", group = groupVisual, tooltip = ttFailed)
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttTags)
rightTagDetail = input.string("Compact", "Right Tag Detail", options = ["Compact", "Full"], group = groupVisual, tooltip = ttTagDetail)
rightTagOffsetBars = input.int(4, "Right Tag Offset Bars", minval = 1, maxval = 30, group = groupVisual, tooltip = ttTagOffset)
showBarColors = input.bool(false, "Color Bars By State", group = groupVisual, tooltip = ttBars)
projectionBars = input.int(90, "Projection Bars", minval = 10, maxval = 600, group = groupVisual, tooltip = ttProjection)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = ttLabelSize)
labelOffsetAtr = input.float(0.70, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = groupVisual, tooltip = ttOffset)
maxEventLabels = input.int(5, "Max Visible Labels", minval = 2, maxval = 60, group = groupVisual, tooltip = ttMaxLabels)
labelCooldownBars = input.int(32, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = ttCooldown)

showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLoc)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelSize)

alertReady = input.bool(true, "Alert: Round Rejection Ready", group = groupAlerts, tooltip = ttAlertReady)
alertMagnet = input.bool(false, "Alert: Round Magnet Warning", group = groupAlerts, tooltip = ttAlertMagnet)
alertInvalidated = input.bool(true, "Alert: Round Rejection Invalidated", group = groupAlerts, tooltip = ttAlertInvalid)

string groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across READY round-number rejections on the current symbol and timeframe. Follow means a rejection continued one risk unit (1R) away from the round number before price closed back through it. These are historical outcome rates, not predictions.")
proofHorizonBars = input.int(20, "Proof Horizon Bars", minval = 3, maxval = 200, group = groupProof, tooltip = "Maximum number of bars each rejection is tracked for the proof measurement before it resolves at its current outcome.")
reactBars = input.int(2, "Reaction Window Bars", minval = 1, maxval = 30, group = groupProof, tooltip = "Number of bars after a rejection used to detect an immediate favorable reaction away from the round number.")
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = "Minimum favorable progress toward the 1R target, within the reaction window, required to count as an early React.")

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
int engineWarmup = math.max(reactionLookback, math.max(volumeLength, atrLength)) + 5
bool engineReady = bar_index > engineWarmup
bool proofConfirmedBar = barstate.isconfirmed
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float volAvg = ta.sma(volume, volumeLength)
float rvol = not na(volAvg) and volAvg > 0 ? volume / volAvg : 1.0
float stepSize = levelMode == "Auto" ? f_auto_step(close) : manualStep
float roundLevel = stepSize > 0 ? math.round(close / stepSize) * stepSize : na
float upperLevel = stepSize > 0 ? roundLevel + stepSize : na
float lowerLevel = stepSize > 0 ? roundLevel - stepSize : na
float bandWidth = atr * bandAtr
float invalidBuffer = atr * invalidationBufferAtr
bool levelReady = engineReady and not na(roundLevel) and atr > 0 and stepSize > 0
float distanceAtr = levelReady ? math.abs(close - roundLevel) / atr : na
bool withinActiveDistance = levelReady and not na(distanceAtr) and distanceAtr <= maxDistanceAtr
bool inBand = withinActiveDistance and high >= roundLevel - bandWidth and low <= roundLevel + bandWidth

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float rangeSize = math.max(high - low, syminfo.mintick)
bool closeAbove = close > roundLevel + bandWidth * 0.15
bool closeBelow = close < roundLevel - bandWidth * 0.15
bool bullReject = inBand and low <= roundLevel + bandWidth and closeAbove and lowerWick / rangeSize >= 0.30
bool bearReject = inBand and high >= roundLevel - bandWidth and closeBelow and upperWick / rangeSize >= 0.30
int rejectDir = bullReject ? 1 : bearReject ? -1 : 0
bool magnetContext = inBand and rejectDir == 0 and math.abs(close - roundLevel) <= bandWidth
float previousRoundLevel = nz(roundLevel[1], roundLevel)
bool sameRoundLevel = math.abs(roundLevel - previousRoundLevel) <= math.max(syminfo.mintick * 0.5, stepSize * 0.000001)
bool failedReference = withinActiveDistance and sameRoundLevel and ((close > roundLevel + invalidBuffer and close[1] < roundLevel - invalidBuffer) or (close < roundLevel - invalidBuffer and close[1] > roundLevel + invalidBuffer))

bool reactionHit = high >= roundLevel - bandWidth and low <= roundLevel + bandWidth
float reactionCount = nz(ta.sma(reactionHit ? 1.0 : 0.0, reactionLookback) * reactionLookback, 0.0)
float reactionScore = f_clamp(reactionCount / 6.0, 0.0, 1.0) * 12.0
float wickRatio = rejectDir == 1 ? lowerWick / rangeSize : rejectDir == -1 ? upperWick / rangeSize : 0.0
float wickScore = f_clamp(wickRatio / 0.65, 0.0, 1.0) * 28.0
float closeDistance = rejectDir == 1 ? (close - roundLevel) / atr : rejectDir == -1 ? (roundLevel - close) / atr : 0.0
float closeScore = f_clamp(closeDistance / 0.85, 0.0, 1.0) * 24.0
float distanceScore = withinActiveDistance ? f_clamp(1.0 - distanceAtr / maxDistanceAtr, 0.0, 1.0) * 12.0 : 0.0
float volScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 12.0 : 9.0
float volatilityScore = atr > 0 and stepSize > 0 ? f_clamp(stepSize / (atr * 3.0), 0.0, 1.0) * 12.0 : 0.0
float candidateScore = f_clamp(wickScore + closeScore + distanceScore + reactionScore + volScore + volatilityScore, 0.0, 100.0)
float failureRisk = f_clamp((magnetContext ? 28.0 : 0.0) + (failedReference ? 38.0 : 0.0) + (100.0 - closeScore) * 0.18 + math.min(reactionCount, 8.0) * 2.5, 0.0, 100.0)
int requiredScoreRaw = confirmationMode == "Fast" ? math.max(minReadyScore - 5, 1) : confirmationMode == "Strict" ? math.min(minReadyScore + 8, 100) : minReadyScore
int requiredScore = math.max(requiredScoreRaw, watchScore + 1)
int effectiveWatchScore = math.min(watchScore, requiredScore - 1)

bool readyEvent = levelReady and rejectDir != 0 and candidateScore >= requiredScore and failureRisk < failureRiskThreshold
bool magnetEvent = levelReady and magnetContext and failureRisk >= 35 and not readyEvent
bool invalidatedEvent = levelReady and failedReference and failureRisk >= failureRiskThreshold

bool readyAnchor = proofConfirmedBar and readyEvent and not readyEvent[1]
bool magnetAnchor = proofConfirmedBar and magnetEvent and not magnetEvent[1]
bool invalidatedAnchor = proofConfirmedBar and invalidatedEvent and not invalidatedEvent[1]

var int lastReadyLabelBar = na
var int lastMagnetLabelBar = na
var int lastFailedLabelBar = na
bool canReadyLabel = na(lastReadyLabelBar) or bar_index - lastReadyLabelBar >= labelCooldownBars
bool canMagnetLabel = na(lastMagnetLabelBar) or bar_index - lastMagnetLabelBar >= labelCooldownBars
bool canFailedLabel = na(lastFailedLabelBar) or bar_index - lastFailedLabelBar >= labelCooldownBars

var string actionState = "WAIT"
var string levelState = "Waiting Level"
var string sideState = "Neutral"
var float lastScore = na
var float lastFailureRisk = na

if not levelReady
    actionState := "BLOCKED"
    levelState := "Level Blocked"
    sideState := "Neutral"
    lastScore := na
    lastFailureRisk := na
else if readyEvent
    actionState := "READY"
    levelState := rejectDir == 1 ? "Bull Rejection" : "Bear Rejection"
    sideState := rejectDir == 1 ? "Bullish" : "Bearish"
    lastScore := candidateScore
    lastFailureRisk := failureRisk
else if invalidatedEvent
    actionState := "INVALIDATED"
    levelState := "Failed Reference"
    sideState := close > roundLevel ? "Above Level" : "Below Level"
    lastScore := candidateScore
    lastFailureRisk := failureRisk
else if magnetEvent
    actionState := "MONITOR"
    levelState := "Magnet Watch"
    sideState := "Neutral"
    lastScore := candidateScore
    lastFailureRisk := failureRisk
else if withinActiveDistance
    actionState := "MONITOR"
    levelState := "Near Round Level"
    sideState := close > roundLevel ? "Above Level" : close < roundLevel ? "Below Level" : "At Level"
    lastScore := na
    lastFailureRisk := failureRisk
else
    actionState := "WAIT"
    levelState := "Waiting Level"
    sideState := "Neutral"
    lastScore := na
    lastFailureRisk := na

// -------------------------------------------------
// Visuals
// -------------------------------------------------
var box levelBandBox = na
var box invalidBox = na
var line levelLine = na
var line upperLine = na
var line lowerLine = na
var label tagLevel = na
var label tagUpper = na
var label tagLower = na
var label tagInvalid = na
var label bandBadge = na
var array<label> eventLabels = array.new_label()

int effectiveProjectionBars = timeframe.ismonthly ? math.min(projectionBars, 12) : timeframe.isweekly ? math.min(projectionBars, 28) : timeframe.isdaily ? math.min(projectionBars, 55) : projectionBars
int rightX = bar_index + effectiveProjectionBars
int tagBaseX = bar_index + rightTagOffsetBars
int levelTagX = tagBaseX
int invalidTagX = tagBaseX + 2
int upperTagX = tagBaseX + 4
int lowerTagX = tagBaseX + 6
bool compactTags = rightTagDetail == "Compact"
bool showMainRoundTag = not showRoundBand
int levelLineRightX = showRightTags and showMainRoundTag ? levelTagX : rightX
int invalidRightX = showRightTags ? invalidTagX : rightX
int upperRailRightX = showRightTags ? upperTagX : rightX
int lowerRailRightX = showRightTags ? lowerTagX : rightX
color bandColor = actionState == "READY" ? (rejectDir == 1 ? bullColor : bearColor) : actionState == "INVALIDATED" ? bearColor : actionState == "MONITOR" ? accentColor : neutralColor
float invalidLevel = rejectDir == 1 ? roundLevel - invalidBuffer : rejectDir == -1 ? roundLevel + invalidBuffer : close >= roundLevel ? roundLevel - invalidBuffer : roundLevel + invalidBuffer
float invalidTop = math.max(roundLevel, invalidLevel)
float invalidBottom = math.min(roundLevel, invalidLevel)
string bandText = actionState == "READY" ? (rejectDir == 1 ? "BULL REJECT | Q " : "BEAR REJECT | Q ") + str.tostring(math.round(candidateScore)) : actionState == "INVALIDATED" ? "FAILED REF" : actionState == "MONITOR" ? "MONITOR | " + str.tostring(roundLevel, format.mintick) : str.tostring(roundLevel, format.mintick)

// -------------------------------------------------
// Confirmation-anchored proof (READY rejections: Follow = continued 1R away before closing back through the level)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var int pLastResolveBar = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var float pEvalRoundLevel = na
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
            pLastResolveBar := bar_index

    // Start one non-overlapping Proof evaluation for each confirmed READY call.
    bool proofRestartReady = na(pLastResolveBar) or bar_index > pLastResolveBar
    if readyAnchor and not pEvalActive and proofRestartReady and rejectDir != 0
        float pRiskDist = math.max(math.abs(close - invalidLevel), syminfo.mintick)
        pEvalActive := true
        pEvalDir := rejectDir
        pEvalEntry := close
        pEvalStop := invalidLevel
        pEvalTarget := close + rejectDir * pRiskDist
        pEvalRoundLevel := roundLevel
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

if barstate.islast and levelReady and showRoundBand
    if na(levelBandBox)
        levelBandBox := box.new(left = bar_index, top = roundLevel + bandWidth, right = rightX, bottom = roundLevel - bandWidth, xloc = xloc.bar_index, bgcolor = color.new(bandColor, 88), border_color = color.new(bandColor, 24), border_width = 1)
    else
        box.set_left(levelBandBox, bar_index)
        box.set_right(levelBandBox, rightX)
        box.set_top(levelBandBox, roundLevel + bandWidth)
        box.set_bottom(levelBandBox, roundLevel - bandWidth)
        box.set_bgcolor(levelBandBox, color.new(bandColor, 88))
        box.set_border_color(levelBandBox, color.new(bandColor, 24))
    bandBadge := f_badge_set(bandBadge, int(math.round((bar_index + rightX) * 0.5)), roundLevel, bandText, bandColor, labelSizeInput)
    if na(levelLine)
        levelLine := line.new(bar_index, roundLevel, levelLineRightX, roundLevel, xloc = xloc.bar_index, color = color.new(neutralColor, 6), width = 1, style = line.style_dotted)
    else
        line.set_xy1(levelLine, bar_index, roundLevel)
        line.set_xy2(levelLine, levelLineRightX, roundLevel)
else if barstate.islast
    if not na(levelBandBox)
        box.delete(levelBandBox)
        levelBandBox := na
    if not na(bandBadge)
        label.delete(bandBadge)
        bandBadge := na
    if not na(levelLine)
        line.delete(levelLine)
        levelLine := na

if barstate.islast and levelReady and showNearbyLevels
    if na(upperLine)
        upperLine := line.new(bar_index, upperLevel, upperRailRightX, upperLevel, xloc = xloc.bar_index, color = color.new(accentColor, 48), width = 1, style = line.style_dashed)
    else
        line.set_xy1(upperLine, bar_index, upperLevel)
        line.set_xy2(upperLine, upperRailRightX, upperLevel)
    if na(lowerLine)
        lowerLine := line.new(bar_index, lowerLevel, lowerRailRightX, lowerLevel, xloc = xloc.bar_index, color = color.new(accentColor, 48), width = 1, style = line.style_dashed)
    else
        line.set_xy1(lowerLine, bar_index, lowerLevel)
        line.set_xy2(lowerLine, lowerRailRightX, lowerLevel)
else if barstate.islast
    if not na(upperLine)
        line.delete(upperLine)
        upperLine := na
    if not na(lowerLine)
        line.delete(lowerLine)
        lowerLine := na

if barstate.islast and levelReady and showInvalidationShelf and withinActiveDistance
    if na(invalidBox)
        invalidBox := box.new(left = bar_index, top = invalidTop, right = invalidRightX, bottom = invalidBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 92), border_color = color.new(bearColor, 42), border_width = 1)
    else
        box.set_left(invalidBox, bar_index)
        box.set_right(invalidBox, invalidRightX)
        box.set_top(invalidBox, invalidTop)
        box.set_bottom(invalidBox, invalidBottom)
else if barstate.islast
    if not na(invalidBox)
        box.delete(invalidBox)
        invalidBox := na

if showEventLabels and readyAnchor and canReadyLabel
    string readyText = (rejectDir == 1 ? "Bull Reject" : "Bear Reject") + "\nQ " + str.tostring(math.round(candidateScore))
    label readyLabel = label.new(bar_index, rejectDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr, readyText, xloc = xloc.bar_index, yloc = yloc.price, style = rejectDir == 1 ? label.style_label_up : label.style_label_down, textcolor = headerText, color = color.new(rejectDir == 1 ? bullColor : bearColor, 0), size = f_text_size(labelSizeInput))
    lastReadyLabelBar := bar_index
    array.push(eventLabels, readyLabel)
    f_trim_labels(eventLabels, maxEventLabels)

if showEventLabels and showMagnetLabels and magnetAnchor and canMagnetLabel
    label magnetLabel = label.new(bar_index, close >= roundLevel ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr, "MAGNET WATCH", xloc = xloc.bar_index, yloc = yloc.price, style = close >= roundLevel ? label.style_label_down : label.style_label_up, textcolor = headerText, color = color.new(neutralColor, 0), size = f_text_size(labelSizeInput))
    lastMagnetLabelBar := bar_index
    array.push(eventLabels, magnetLabel)
    f_trim_labels(eventLabels, maxEventLabels)

if showEventLabels and showFailedLabels and invalidatedAnchor and canFailedLabel
    label invalidLabel = label.new(bar_index, close >= roundLevel ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr, "FAILED LEVEL", xloc = xloc.bar_index, yloc = yloc.price, style = close >= roundLevel ? label.style_label_down : label.style_label_up, textcolor = headerText, color = color.new(bearColor, 0), size = f_text_size(labelSizeInput))
    lastFailedLabelBar := bar_index
    array.push(eventLabels, invalidLabel)
    f_trim_labels(eventLabels, maxEventLabels)

// Right-side badge coverage: every visible guide line keeps a matching badge.
if barstate.islast
    if levelReady and showRightTags
        if showMainRoundTag
            string levelTagText = "Round " + str.tostring(roundLevel, format.mintick)
            if na(tagLevel)
                tagLevel := label.new(levelTagX, roundLevel, levelTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(neutralColor, 12), size = f_text_size(labelSizeInput))
            else
                label.set_xy(tagLevel, levelTagX, roundLevel)
                label.set_text(tagLevel, levelTagText)
                label.set_style(tagLevel, label.style_label_left)
                label.set_textcolor(tagLevel, headerText)
                label.set_color(tagLevel, color.new(neutralColor, 12))
                label.set_size(tagLevel, f_text_size(labelSizeInput))
        else if not na(tagLevel)
            label.delete(tagLevel)
            tagLevel := na

        if showNearbyLevels
            string upperTagText = compactTags ? "Upper" : "Upper " + str.tostring(upperLevel, format.mintick)
            string lowerTagText = compactTags ? "Lower" : "Lower " + str.tostring(lowerLevel, format.mintick)

            if na(tagUpper)
                tagUpper := label.new(upperTagX, upperLevel, upperTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(accentColor, 28), size = f_text_size(labelSizeInput))
            else
                label.set_xy(tagUpper, upperTagX, upperLevel)
                label.set_text(tagUpper, upperTagText)
                label.set_style(tagUpper, label.style_label_left)
                label.set_textcolor(tagUpper, headerText)
                label.set_color(tagUpper, color.new(accentColor, 28))
                label.set_size(tagUpper, f_text_size(labelSizeInput))

            if na(tagLower)
                tagLower := label.new(lowerTagX, lowerLevel, lowerTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(accentColor, 28), size = f_text_size(labelSizeInput))
            else
                label.set_xy(tagLower, lowerTagX, lowerLevel)
                label.set_text(tagLower, lowerTagText)
                label.set_style(tagLower, label.style_label_left)
                label.set_textcolor(tagLower, headerText)
                label.set_color(tagLower, color.new(accentColor, 28))
                label.set_size(tagLower, f_text_size(labelSizeInput))
        else
            if not na(tagUpper)
                label.delete(tagUpper)
                tagUpper := na
            if not na(tagLower)
                label.delete(tagLower)
                tagLower := na

        if showInvalidationShelf and withinActiveDistance
            string invalidTagText = "Fail " + str.tostring(invalidLevel, format.mintick)
            if na(tagInvalid)
                tagInvalid := label.new(invalidTagX, invalidLevel, invalidTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(bearColor, 22), size = f_text_size(labelSizeInput))
            else
                label.set_xy(tagInvalid, invalidTagX, invalidLevel)
                label.set_text(tagInvalid, invalidTagText)
                label.set_style(tagInvalid, label.style_label_left)
                label.set_textcolor(tagInvalid, headerText)
                label.set_color(tagInvalid, color.new(bearColor, 22))
                label.set_size(tagInvalid, f_text_size(labelSizeInput))
        else if not na(tagInvalid)
            label.delete(tagInvalid)
            tagInvalid := na
    else
        if not na(tagLevel)
            label.delete(tagLevel)
            tagLevel := na
        if not na(tagUpper)
            label.delete(tagUpper)
            tagUpper := na
        if not na(tagLower)
            label.delete(tagLower)
            tagLower := na
        if not na(tagInvalid)
            label.delete(tagInvalid)
            tagInvalid := na

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(candidateScore, title = "Round Rejection Score", color = f_score_color(candidateScore, requiredScore, effectiveWatchScore), display = display.data_window)
plot(failureRisk, title = "Failure Risk", color = failureRisk >= failureRiskThreshold ? bearColor : neutralColor, display = display.data_window)
plot(distanceAtr, title = "Distance To Round ATR", color = accentColor, display = display.data_window)
plot(reactionCount, title = "Round Interaction Count", color = neutralColor, display = display.data_window)
plot(rvol, title = "Relative Volume", color = panelValueCol, display = display.data_window)
plot(followRate, title = "RNR Follow Rate", display = display.none)
plot(holdRate, title = "RNR Hold Rate", display = display.none)
plot(reactRate, title = "RNR React Rate", display = display.none)
plot(flipRate, title = "RNR Flip Rate", display = display.none)
plot(proofAmbiguous, title = "RNR Ambiguous Proof Count", display = display.none)
plot(roundLevel, title = "RNR Active Round Level", display = display.none)
plot(stepSize, title = "RNR Round Step", display = display.none)
plot(rejectDir, title = "RNR Rejection Direction", display = display.none)
plot(readyAnchor ? 1 : 0, title = "RNR Confirmed Ready Call", display = display.none)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string levelText = levelReady ? str.tostring(roundLevel, format.mintick) : "-"
string scoreText = f_score_text(lastScore)
string distanceText = levelReady and not na(distanceAtr) ? str.tostring(distanceAtr, "#.0") + " ATR" : "-"
string riskText = na(lastFailureRisk) ? "-" : str.tostring(math.round(lastFailureRisk)) + "/100"
color scoreColor = na(lastScore) ? f_panel_value(panelTheme) : f_score_color(lastScore, requiredScore, effectiveWatchScore)
color riskColor = na(lastFailureRisk) ? f_panel_value(panelTheme) : lastFailureRisk >= failureRiskThreshold ? bearColor : neutralColor
color actionColor = f_action_color(actionState)

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
int panelRowCount = showProof ? 11 : 6
var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""
var bool lastProofMode = false

if barstate.islast
    if showPanel
        if na(panel) or panelLocationInput != lastPanelLocation or panelTheme != lastPanelTheme or panelFontSizeInput != lastPanelFont or showProof != lastProofMode
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
            lastPanelLocation := panelLocationInput
            lastPanelTheme := panelTheme
            lastPanelFont := panelFontSizeInput
            lastProofMode := showProof
        table.clear(panel, 0, 0, 1, panelRowCount - 1)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Round Number Rejection Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Round Level", levelText, f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 2, "Rejection Score", scoreText, scoreColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 3, "Distance", distanceText, not na(distanceAtr) and distanceAtr <= maxDistanceAtr ? accentColor : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
        f_panel_row(panel, 4, "Failure Risk", riskText, riskColor, panelTheme, panelFontSizeInput)
        f_panel_row(panel, 5, "Action", actionState, actionColor, panelTheme, panelFontSizeInput)
        if showProof
            color proofHeadBg = f_row_bg(panelTheme, 6)
            table.cell(panel, 0, 6, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_text_size(panelFontSizeInput), text_halign = text.align_left)
            table.cell(panel, 1, 6, proofSampleText, text_color = f_panel_label(panelTheme), bgcolor = proofHeadBg, text_size = f_text_size(panelFontSizeInput), text_halign = text.align_right)
            f_panel_row(panel, 7, "Follow Rate", proofTotal > 0 ? f_rate_pct(followRate) : "-", proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
            f_panel_row(panel, 8, "Hold Rate", proofTotal > 0 ? f_rate_pct(holdRate) : "-", proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
            f_panel_row(panel, 9, "React Rate", proofTotal > 0 ? f_rate_pct(reactRate) : "-", proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
            f_panel_row(panel, 10, "Flip Rate", proofTotal > 0 ? f_rate_pct(flipRate) : "-", proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelTheme), panelTheme, panelFontSizeInput)
    else if not na(panel)
        table.delete(panel)
        panel := na
        lastPanelLocation := ""
        lastPanelTheme := ""
        lastPanelFont := ""

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
color barStateColor = actionState == "READY" ? color.new(rejectDir == 1 ? bullColor : bearColor, 76) : actionState == "MONITOR" ? color.new(accentColor, 84) : actionState == "INVALIDATED" ? color.new(bearColor, 80) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertReady and readyAnchor and rejectDir == 1, "Bullish Round Number Rejection Ready", "Round Number Rejection Planner: bullish round-number rejection reached READY context. This is an attention marker, not a trade instruction.")
alertcondition(alertReady and readyAnchor and rejectDir == -1, "Bearish Round Number Rejection Ready", "Round Number Rejection Planner: bearish round-number rejection reached READY context. This is an attention marker, not a trade instruction.")
alertcondition(alertMagnet and magnetAnchor, "Round Number Magnet Warning", "Round Number Rejection Planner: price is near a round number but rejection quality is weak.")
alertcondition(alertInvalidated and invalidatedAnchor, "Round Number Rejection Invalidated", "Round Number Rejection Planner: rejection failed through the round-number reference.")
````
