# Market Structure Recovery Planner [AGPro Series]

- url: https://www.tradingview.com/script/jZrc2ZNY-Market-Structure-Recovery-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;16568af579b04eaa80ce743aa353e856
- version: 4.0

## Description

Market Structure Recovery Planner [AGPro Series]

🧠 Core Idea

Did damaged market structure recover with enough acceptance, risk clarity, and target room to deserve attention?


📌 Overview / What it does

Market Structure Recovery Planner is a chart-first planning tool for evaluating what happens after clean swing structure gets damaged and price attempts to repair the damaged rail.

The default design is strongest on 4H swing-structure charts, where the damage / recovery / repair-room sequence has enough space to be readable without becoming too sparse or too noisy.

The script maps a damaged structure rail, recovery pocket, risk edge, repair-room corridor, 0-100 recovery score, acceptance state, and a clear next-action panel. It does not try to predict price or automate decisions.

It is designed to make structure recovery easier to review: what broke, what was recovered, whether acceptance is building, where the plan becomes invalid, and whether enough structural room remains.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between generic structure labels and full break-retest systems.

Many tools show a BOS, CHOCH, or support/resistance touch. Market Structure Recovery Planner focuses on the recovery phase after damage: the moment where structure may be repairing but still needs proof.

It supports traders who want a decision-engine workflow instead of another raw signal marker.


⚡ Why This Script Is Different

Most tools focus on detecting a structure break or plotting broad support and resistance zones.

This script does NOT clone BOS / CHOCH scanners, Structure Retest Planner, Reclaim Breakout Planner, or generic S/R maps.

Instead, it studies damaged swing structure and asks whether the damaged rail has been recovered with acceptance, participation, risk clarity, and enough room to matter.


⚙️ Methodology

1. Context Detection
The script confirms swing structure using higher-high / higher-low or lower-high / lower-low behavior.

2. Damage Mapping
When clean structure loses its prior swing rail, the script records the damaged rail and the damage extreme.

3. Recovery Evaluation
Price must reclaim the damaged rail. The 0-100 score weighs damage depth, recovery close, acceptance hold, volume response, and room to target.

4. Visual Output
The chart shows the recovery pocket, risk edge, repair-room corridor, event labels, and a compact AG Pro panel.


🗺️ How to Read the Chart

Recovery Pocket = the area around the damaged structure rail where repair quality is evaluated.

Risk Edge = the level where the active recovery plan should be reviewed as failed or invalidated.

Repair Room = the available structural space between the recovered rail and the next room reference.

Labels = compact state markers for damage, recovery, ready state, thin room, or failed recovery.

Panel = structure state, recovery score, acceptance, risk edge, and next action.


🚦 Signals & States

• Structure Damage Detected → a clean swing structure rail has been broken.

• Structure Recovery Detected → price recovered the damaged rail.

• Recovery Planner Ready → score, acceptance, and repair room meet the configured threshold.

• Repair Room Thin → recovery exists but available room is limited.

• Recovery Failed → price crossed the active risk edge.


🔔 Alerts Logic

Alerts trigger when structure damage appears, recovery is detected, planner-ready state begins, repair room becomes thin, or the active recovery fails.

Alerts are attention markers only. They are not trade instructions and do not imply guaranteed outcomes.


🧩 Confluence Logic

The recovery context becomes stronger when structure damage is repairable, price closes back through the damaged rail, acceptance holds for several bars, volume participation improves, and room to the next structural reference remains open.


📊 When to Use

• 4H swing-structure review

• After a clean swing structure loses a key rail

• During trend repair attempts

• Around failed breakdown or failed breakout behavior

• When a trader needs risk / target / invalidation context after structural damage


⚠️ When NOT to Use

• Very low timeframes where structure damage appears too often

• Very high timeframes where recovery states can stay expired for long periods

• Extremely low-liquidity markets

• Very noisy chop where swing structure changes constantly

• Major news candles with abnormal displacement

• Markets where volume data is unreliable and structure is too compressed


🎛️ Key Inputs

• Structure Swing Length → controls how selective the swing structure model is.

• Sensitivity → adjusts damage and recovery rail strictness.

• Timely Recovery Window → controls how long a damaged rail remains relevant.

• Planner Ready Score → sets the required quality threshold.

• Panel / Label Settings → control location, theme, size, and visual density.


🖥️ Interface & Visual Design

The interface is designed around a compact premium panel and clean chart-first visuals.

The first panel row uses the AG Pro title format. Zones are restrained and centered, labels are offset away from candles, and the chart remains readable while still showing enough state markers to avoid an empty look.


🧪 Practical Usage Workflow

1. Read the panel structure state.

2. Check whether the damaged rail has a recovery pocket.

3. Review recovery score and acceptance.

4. Compare risk edge with repair room.

5. Treat the action row as a review state, not as an instruction.


🔍 Interpretation Guidelines

Think in stages: damage, recovery, acceptance, room, and failure.

A high score means the recovery context is cleaner according to the script rules. A low score means the repair is weak, late, thin, or poorly supported.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a generic BOS / CHOCH scanner

• Not a generic support / resistance zone map


⚠️ Limitations & Transparency

Swing confirmation depends on the selected timeframe and pivot length.

Volatility can widen recovery pockets and change the quality score.

Market conditions can shift quickly, especially during news, low liquidity, or abnormal volume.


🧠 Market Context Notes

Structure recovery is most useful when the trader already understands the broader trend, liquidity environment, and volatility regime.

The script gives a structured review of damaged structure, not certainty about future price movement.


🧾 Use Case Examples

When bullish structure loses a higher-low rail and later closes back above that rail with acceptance, the script can mark a bullish recovery review.

When bearish structure loses a lower-high rail and later closes back below that rail, the script can mark a bearish recovery review.


🧱 System Philosophy

Market Structure Recovery Planner follows the AGPro Series approach: clear structure, rule-based scoring, readable visuals, and decision support without outcome promises.


🔐 Non-Promise Statement

No script can guarantee market direction, trade success, or certainty.

This tool provides structured context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk management, and decisions.

This script does not provide financial advice.


📚 Educational Note

Use the script to study how structure damage and recovery behave across different symbols, sessions, and timeframes.

For public chart examples, 4H is the recommended default because it shows the structure-repair workflow most clearly.

## Source Code

````pine
// -------------------------------------------------
// Market Structure Recovery Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Market Structure Recovery Planner is a chart-first structure repair engine
// designed primarily for 4H swing-structure review. It studies what happens
// after a clean swing structure is damaged, then scores whether price has
// recovered the damaged rail with enough acceptance, risk clarity, volume
// support, and target room. The goal is to turn damaged market structure into
// a planning workflow rather than another BOS/CHOCH or generic retest marker.
// -------------------------------------------------

//@version=6
indicator("Market Structure Recovery Planner [AGPro Series]",
     shorttitle = "AG Pro MSR",
     overlay = true,
     max_labels_count = 220,
     max_boxes_count = 30,
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

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttPivot = "Confirmed swing length used to define higher-high / higher-low or lower-high / lower-low structure. Higher values reduce noise and make structure damage more selective."
string ttAtr = "ATR length used for structure-damage depth, recovery pocket thickness, invalidation edge, target room, and label spacing."
string ttVolume = "Volume baseline used to measure whether the recovery attempt has meaningful participation. Symbols with unreliable volume receive a neutral volume contribution."
string ttRoom = "Lookback used to estimate the next structural room reference after recovery. This is a planning reference, not a forecast."
string ttSensitivity = "Controls how strict the damage and recovery rail buffers are. Conservative requires cleaner breaks and recoveries; Aggressive reacts sooner."
string ttConfirm = "Close Confirmed waits for bar close before state changes, labels, and alerts. Live Updating lets the planner react during the active bar."
string ttBreakMin = "Minimum ATR-normalized break through the prior structure rail required to count as damaged structure."
string ttBreakIdeal = "Preferred damage depth. Shallow breaks may be noise; extremely deep breaks are treated as harder to repair."
string ttBreakMax = "Damage depth above this ATR value receives a lower repair score because the structure may be too displaced."
string ttRecoveryClose = "ATR-normalized close back through the damaged rail required for a strong recovery-close score."
string ttRecoveryWindow = "Number of bars after structure damage where recovery remains timely. Late recoveries can still show, but receive weaker planning quality."
string ttAcceptance = "Number of bars that should hold the recovered side of the rail before acceptance is considered mature."
string ttVolumeConfirm = "Relative volume level treated as meaningful participation during the recovery attempt."
string ttReady = "Minimum 0-100 recovery score required for Planner Ready state. This is a quality filter, not a trade instruction."
string ttWatch = "Minimum 0-100 score required for a Review state before full readiness."
string ttRoomMin = "Minimum ATR room to the structural target reference required before target room is considered acceptable."
string ttPocket = "Shows the recovery pocket around the damaged structure rail. The pocket label is centered vertically and horizontally inside the box."
string ttRails = "Shows the damaged structure rail and invalidation edge used for recovery planning."
string ttTarget = "Shows the repair-room corridor between the recovered rail and the next structural room reference."
string ttForward = "How far active rails, pockets, and repair-room visuals extend to the right."
string ttZoneOpacity = "Transparency for recovery pockets and repair-room zones. Higher values make zones lighter."
string ttTint = "Adds a subtle candle tint while a structure recovery plan is active."
string ttEvents = "Shows damage, recovery, ready, thin-room, and failed-recovery labels with controlled spacing."
string ttContext = "Adds sparse context labels while price is repairing around the damaged rail. These are state markers, not entry signals."
string ttExpired = "Shows a terminal RECOVERY EXPIRED badge when a repair window closes. Enabled by default so inactive charts retain the latest completed context."
string ttCooldown = "Minimum bars between event labels. Higher values reduce repeated labels during fast markets."
string ttContextSpacing = "Minimum bars between sparse context labels during an active recovery plan."
string ttMaxLabels = "Maximum number of chart labels retained. Older labels are deleted first to preserve performance."
string ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
string ttLabelScore = "Adds the 0-100 recovery score and grade to event labels."
string ttLabelSize = "Controls all chart labels and centered zone labels. Normal is the recommended publication default."
string ttPanel = "Shows or hides the AG Pro planning panel. The default is visible for public-release readability."
string ttPanelLocation = "Moves the AG Pro planning panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
string ttPanelFont = "Controls panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Structure Recovery Engine"
int swingLength = input.int(6, "Structure Swing Length", minval = 2, maxval = 40, group = groupEngine, tooltip = ttPivot)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)
int roomLookback = input.int(70, "Structure Room Lookback", minval = 15, maxval = 400, group = groupEngine, tooltip = ttRoom)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

string groupScoring = "Recovery Score Model"
float minDamageAtrInput = input.float(0.12, "Minimum Damage Depth ATR", minval = 0.02, maxval = 1.00, step = 0.01, group = groupScoring, tooltip = ttBreakMin)
float idealDamageAtr = input.float(0.46, "Ideal Repairable Damage ATR", minval = 0.05, maxval = 2.50, step = 0.01, group = groupScoring, tooltip = ttBreakIdeal)
float maxDamageAtr = input.float(1.55, "Maximum Repairable Damage ATR", minval = 0.25, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttBreakMax)
float strongRecoveryCloseAtr = input.float(0.30, "Strong Recovery Close ATR", minval = 0.02, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttRecoveryClose)
int timelyRecoveryBars = input.int(14, "Timely Recovery Window", minval = 2, maxval = 80, group = groupScoring, tooltip = ttRecoveryWindow)
int acceptanceBars = input.int(3, "Acceptance Hold Bars", minval = 1, maxval = 12, group = groupScoring, tooltip = ttAcceptance)
float volumeConfirmRatio = input.float(1.20, "Volume Response Ratio", minval = 0.50, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttVolumeConfirm)
int plannerReadyScore = input.int(72, "Planner Ready Score", minval = 40, maxval = 95, group = groupScoring, tooltip = ttReady)
int reviewScore = input.int(55, "Review Score", minval = 20, maxval = 90, group = groupScoring, tooltip = ttWatch)
float minimumRoomAtr = input.float(1.00, "Minimum Repair Room ATR", minval = 0.20, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttRoomMin)

string groupVisual = "Chart Visuals"
bool showRecoveryPocket = input.bool(true, "Show Recovery Pocket", group = groupVisual, tooltip = ttPocket)
bool showStructureRails = input.bool(true, "Show Rail / Risk Edge", group = groupVisual, tooltip = ttRails)
bool showRepairRoom = input.bool(true, "Show Repair Room", group = groupVisual, tooltip = ttTarget)
int forwardBars = input.int(42, "Forward Render Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttForward)
int zoneTransparency = input.int(87, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)
bool tintActiveBars = input.bool(true, "Tint Active Recovery Plan", group = groupVisual, tooltip = ttTint)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttEvents)
bool showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
bool showExpiredLabels = input.bool(true, "Show Expired Labels", group = groupLabels, tooltip = ttExpired)
int labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(46, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

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

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
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

f_panel_bg(string themeText) =>
    themeText == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_label(string themeText) =>
    themeText == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeText) =>
    themeText == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_row_bg(string themeText) =>
    themeText == "Clean Light" ? color.rgb(248, 250, 252) : color.new(panelBg, 0)

f_label_text(string baseText, float scoreValue) =>
    showLabelScore ? baseText + " | Q" + str.tostring(int(math.round(scoreValue))) + " " + f_score_grade(scoreValue) : baseText

// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

var array<label> eventLabels = array.new<label>()
var array<line> eventConnectors = array.new<line>()

f_add_label(string textValue, float yValue, float anchorValue, bool placeAbove, color labelColor) =>
    line newConnector = line.new(bar_index, anchorValue, bar_index, yValue, xloc = xloc.bar_index, extend = extend.none, color = color.new(labelColor, 28), width = 1)
    label newLabel = label.new(bar_index, yValue, textValue, xloc = xloc.bar_index, yloc = yloc.price, style = placeAbove ? label.style_label_down : label.style_label_up, color = color.new(labelColor, 0), textcolor = f_text_on(labelColor), size = f_text_size(labelFontSize))
    array.push(eventLabels, newLabel)
    array.push(eventConnectors, newConnector)
    if array.size(eventLabels) > maxVisibleLabels
        label oldLabel = array.shift(eventLabels)
        line oldConnector = array.shift(eventConnectors)
        label.delete(oldLabel)
        line.delete(oldConnector)

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
float atr = ta.atr(atrLength)
float safeAtr = math.max(nz(atr, syminfo.mintick), syminfo.mintick)
float volumeBase = ta.sma(volume, volumeLength)
float volumeRatio = volumeBase > 0 ? volume / volumeBase : na
float fastEma = ta.ema(close, 21)
float slowEma = ta.ema(close, 55)
bool confirmedUpdate = confirmationMode == "Live Updating" or barstate.isconfirmed

float sensitivityDamageBuffer = sensitivity == "Conservative" ? 0.10 : sensitivity == "Aggressive" ? 0.03 : 0.06
float sensitivityRecoveryBuffer = sensitivity == "Conservative" ? 0.08 : sensitivity == "Aggressive" ? 0.02 : 0.04
float recoveryPocketAtr = sensitivity == "Conservative" ? 0.30 : sensitivity == "Aggressive" ? 0.48 : 0.38
float riskEdgeAtr = sensitivity == "Conservative" ? 0.68 : sensitivity == "Aggressive" ? 0.48 : 0.56
float minDamageAtr = math.max(minDamageAtrInput, sensitivityDamageBuffer)

float pivotHigh = ta.pivothigh(high, swingLength, swingLength)
float pivotLow = ta.pivotlow(low, swingLength, swingLength)

var float lastPivotHigh = na
var float prevPivotHigh = na
var int lastPivotHighBar = na
var float lastPivotLow = na
var float prevPivotLow = na
var int lastPivotLowBar = na

if not na(pivotHigh)
    prevPivotHigh := lastPivotHigh
    lastPivotHigh := pivotHigh
    lastPivotHighBar := bar_index - swingLength

if not na(pivotLow)
    prevPivotLow := lastPivotLow
    lastPivotLow := pivotLow
    lastPivotLowBar := bar_index - swingLength

bool higherHigh = not na(lastPivotHigh) and not na(prevPivotHigh) and lastPivotHigh > prevPivotHigh
bool higherLow = not na(lastPivotLow) and not na(prevPivotLow) and lastPivotLow > prevPivotLow
bool lowerHigh = not na(lastPivotHigh) and not na(prevPivotHigh) and lastPivotHigh < prevPivotHigh
bool lowerLow = not na(lastPivotLow) and not na(prevPivotLow) and lastPivotLow < prevPivotLow
int structureTrend = higherHigh and higherLow ? 1 : lowerHigh and lowerLow ? -1 : 0

var int activeDirection = 0
var float activeRail = na
var float activeDamageExtreme = na
var int activeDamageBar = na
var float activeDamageDepthAtr = na
var bool recovered = false
var int recoveryBar = na
var int acceptanceHoldBars = 0
var bool failedRecovery = false
var bool expiredPlan = false
var int nextPlanAfterBar = na
var int lastEventLabelBar = na
var int lastContextLabelBar = na

// Stop-aware recovery proof: after a structure recovery, does the recovered
// direction follow through (1.5 ATR) before the risk side gives back (1.0 ATR)?
var float msrProofTarget = na
var float msrProofStop   = na
var int   msrProofDir    = 0
var bool  msrProofOpen   = false
var int   msrProofAge    = na
var int   msrProofWins   = 0
var int   msrProofLosses = 0

int activeAge = activeDirection != 0 and not na(activeDamageBar) ? bar_index - activeDamageBar : 100000
bool expiredReadyForNewPlan = expiredPlan and not na(nextPlanAfterBar) and bar_index > nextPlanAfterBar
bool canStartNewPlan = activeDirection == 0 or failedRecovery or expiredReadyForNewPlan or activeAge > timelyRecoveryBars * 4

bool bullishStructureDamage = confirmedUpdate and canStartNewPlan and structureTrend == 1 and not na(lastPivotLow) and close < lastPivotLow - safeAtr * minDamageAtr
bool bearishStructureDamage = confirmedUpdate and canStartNewPlan and structureTrend == -1 and not na(lastPivotHigh) and close > lastPivotHigh + safeAtr * minDamageAtr
bool damageStarted = bullishStructureDamage or bearishStructureDamage

if bullishStructureDamage
    activeDirection := 1
    activeRail := lastPivotLow
    activeDamageExtreme := low
    activeDamageBar := bar_index
    activeDamageDepthAtr := math.abs(activeRail - activeDamageExtreme) / safeAtr
    recovered := false
    recoveryBar := na
    acceptanceHoldBars := 0
    failedRecovery := false
    expiredPlan := false
    nextPlanAfterBar := na

if bearishStructureDamage
    activeDirection := -1
    activeRail := lastPivotHigh
    activeDamageExtreme := high
    activeDamageBar := bar_index
    activeDamageDepthAtr := math.abs(activeDamageExtreme - activeRail) / safeAtr
    recovered := false
    recoveryBar := na
    acceptanceHoldBars := 0
    failedRecovery := false
    expiredPlan := false
    nextPlanAfterBar := na

float recoveryBuffer = safeAtr * sensitivityRecoveryBuffer
float riskEdge = activeDirection == 1 ? activeDamageExtreme - safeAtr * riskEdgeAtr : activeDirection == -1 ? activeDamageExtreme + safeAtr * riskEdgeAtr : na
bool recoveryNow = confirmedUpdate and activeDirection != 0 and not recovered and not failedRecovery and not expiredPlan and (activeDirection == 1 ? close > activeRail + recoveryBuffer : close < activeRail - recoveryBuffer)

if recoveryNow
    recovered := true
    recoveryBar := bar_index
    acceptanceHoldBars := 1

bool holdsRecoveredSide = recovered and not failedRecovery and (activeDirection == 1 ? low >= activeRail - safeAtr * recoveryPocketAtr * 0.40 : high <= activeRail + safeAtr * recoveryPocketAtr * 0.40)
if recovered and not recoveryNow and not failedRecovery
    acceptanceHoldBars := holdsRecoveredSide ? math.min(acceptanceHoldBars + 1, acceptanceBars + 5) : math.max(acceptanceHoldBars - 1, 0)

bool failedNow = confirmedUpdate and recovered and not failedRecovery and activeDirection != 0 and (activeDirection == 1 ? close < riskEdge : close > riskEdge)
if failedNow
    failedRecovery := true

bool expiredNow = confirmedUpdate and activeDirection != 0 and not recovered and not failedRecovery and not expiredPlan and activeAge > timelyRecoveryBars * 2
if expiredNow
    expiredPlan := true
    nextPlanAfterBar := bar_index + timelyRecoveryBars

float rawSwingTarget = activeDirection == 1 ? math.max(nz(lastPivotHigh, high), ta.highest(high, roomLookback)) : activeDirection == -1 ? math.min(nz(lastPivotLow, low), ta.lowest(low, roomLookback)) : na
float targetGuide = activeDirection == 1 ? math.max(rawSwingTarget, activeRail + safeAtr * minimumRoomAtr) : activeDirection == -1 ? math.min(rawSwingTarget, activeRail - safeAtr * minimumRoomAtr) : na
float damageDepthScore = activeDirection != 0 and not na(activeDamageDepthAtr) ? f_peak_score(activeDamageDepthAtr, minDamageAtr, idealDamageAtr, maxDamageAtr) : 0.0
float closeBeyondRailAtr = activeDirection == 1 ? (close - activeRail) / safeAtr : activeDirection == -1 ? (activeRail - close) / safeAtr : 0.0
float recoveryCloseScore = activeDirection != 0 ? f_norm_high(closeBeyondRailAtr, 0.0, strongRecoveryCloseAtr) : 0.0
float acceptanceScore = recovered ? f_norm_high(acceptanceHoldBars, 0.0, acceptanceBars) : 0.0
float participationScore = na(volumeRatio) ? 50.0 : f_norm_high(volumeRatio, 0.70, volumeConfirmRatio)
float roomAtr = activeDirection == 1 ? math.max((targetGuide - close) / safeAtr, 0.0) : activeDirection == -1 ? math.max((close - targetGuide) / safeAtr, 0.0) : 0.0
float roomScore = f_norm_high(roomAtr, minimumRoomAtr * 0.35, minimumRoomAtr * 1.70)
float timelinessPenalty = activeDirection != 0 ? f_norm_low(activeAge, timelyRecoveryBars, timelyRecoveryBars * 2.0) : 100.0
float recoveryScoreRaw = damageDepthScore * 0.20 + recoveryCloseScore * 0.25 + acceptanceScore * 0.20 + participationScore * 0.15 + roomScore * 0.20
float recoveryScore = activeDirection != 0 ? f_clamp(recoveryScoreRaw * (0.70 + timelinessPenalty * 0.003), 0.0, 100.0) : 0.0

bool roomThin = activeDirection != 0 and recovered and not expiredPlan and roomAtr < minimumRoomAtr
bool meaningfulRoomThin = roomThin and recoveryScore >= reviewScore
bool plannerReady = activeDirection != 0 and recovered and not failedRecovery and not expiredPlan and recoveryScore >= plannerReadyScore and not roomThin
bool reviewReady = activeDirection != 0 and recovered and not failedRecovery and not expiredPlan and recoveryScore >= reviewScore and recoveryScore < plannerReadyScore
bool nearDamagedRail = activeDirection != 0 and not recovered and not expiredPlan and math.abs(close - activeRail) / safeAtr <= 0.80

string baseStructureText = structureTrend == 1 ? "Bull Structure" : structureTrend == -1 ? "Bear Structure" : "Mixed Structure"
string structureState = activeDirection == 0 ? baseStructureText : failedRecovery ? "Recovery Failed" : expiredPlan ? "Recovery Expired" : recovered ? (activeDirection == 1 ? "Bull Recovered" : "Bear Recovered") : (activeDirection == 1 ? "Bull Repair Watch" : "Bear Repair Watch")
string acceptanceText = failedRecovery ? "Failed" : expiredPlan ? "Expired" : not recovered and activeDirection != 0 ? "Pending" : recovered and acceptanceHoldBars >= acceptanceBars ? "Accepted" : recovered ? "Building" : "-"
string actionText = activeDirection == 0 ? "Wait For Damage" : failedRecovery ? "Reset Context" : expiredPlan ? "Wait For New Damage" : not recovered ? "Watch Repair Rail" : roomThin ? "Room Review" : plannerReady ? "Planner Ready" : reviewReady ? "Review Recovery" : "Acceptance Building"
color activeColor = activeDirection == 1 ? bullColor : activeDirection == -1 ? bearColor : neutralColor
color stateColor = failedRecovery ? dangerColor : plannerReady ? bullColor : reviewReady ? neutralColor : activeDirection == 1 ? bullColor : activeDirection == -1 ? bearColor : neutralColor

// -------------------------------------------------
// Recovery proof (stop-aware, confirmed-bar gated)
// -------------------------------------------------
bool recoveryEvent = recovered and not recovered[1]
if barstate.isconfirmed
    if recoveryEvent and not msrProofOpen and activeDirection != 0
        msrProofDir    := activeDirection
        msrProofTarget := activeDirection == 1 ? close + safeAtr * 1.5 : close - safeAtr * 1.5
        msrProofStop   := activeDirection == 1 ? close - safeAtr * 1.0 : close + safeAtr * 1.0
        msrProofAge    := 0
        msrProofOpen   := true
    if msrProofOpen and not na(msrProofTarget) and not na(msrProofStop)
        bool proofHitStop   = msrProofDir == 1 ? close <= msrProofStop : close >= msrProofStop
        bool proofHitTarget = msrProofDir == 1 ? close >= msrProofTarget : close <= msrProofTarget
        if proofHitStop
            msrProofLosses += 1
            msrProofOpen := false
        else if proofHitTarget
            msrProofWins += 1
            msrProofOpen := false
        else
            msrProofAge := nz(msrProofAge) + 1
            if msrProofAge > 50
                msrProofOpen := false

int   msrProofTotal = msrProofWins + msrProofLosses
float msrProofRate  = msrProofTotal == 0 ? 0.0 : 100.0 * msrProofWins / msrProofTotal
string proofText = msrProofTotal < 6 ? "Building (" + str.tostring(msrProofTotal) + ")" : str.tostring(math.round(msrProofRate)) + "% (" + str.tostring(msrProofTotal) + ")"
color proofCol = msrProofTotal < 6 ? neutralColor : msrProofRate >= 55 ? bullColor : msrProofRate >= 45 ? neutralColor : bearColor

// -------------------------------------------------
// Labels
// -------------------------------------------------
int labelLane = bar_index % 3
float laneStep = labelFontSize == "Tiny" ? 0.16 : labelFontSize == "Small" ? 0.20 : labelFontSize == "Large" ? 0.34 : 0.26
float yOffset = safeAtr * (labelOffsetAtr + labelLane * laneStep)
bool canEventLabel = showEventLabels and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)

if damageStarted and canEventLabel
    bool placeAbove = activeDirection == -1
    float yValue = placeAbove ? high + yOffset : low - yOffset
    f_add_label(activeDirection == 1 ? "BULL STRUCTURE | DAMAGED" : "BEAR STRUCTURE | DAMAGED", yValue, placeAbove ? high : low, placeAbove, neutralColor)
    lastEventLabelBar := bar_index

if recoveryNow and canEventLabel
    bool placeAbove = activeDirection == -1
    float yValue = placeAbove ? high + yOffset : low - yOffset
    f_add_label(f_label_text(activeDirection == 1 ? "BULL STRUCTURE RECOVERED" : "BEAR STRUCTURE RECOVERED", recoveryScore), yValue, placeAbove ? high : low, placeAbove, activeColor)
    lastEventLabelBar := bar_index

if plannerReady and not plannerReady[1] and canEventLabel
    bool placeAbove = activeDirection == -1
    float yValue = placeAbove ? high + yOffset : low - yOffset
    f_add_label(f_label_text(activeDirection == 1 ? "BULL PLANNER READY" : "BEAR PLANNER READY", recoveryScore), yValue, placeAbove ? high : low, placeAbove, activeColor)
    lastEventLabelBar := bar_index

if meaningfulRoomThin and not meaningfulRoomThin[1] and canEventLabel
    bool placeAbove = activeDirection == -1
    float yValue = placeAbove ? high + yOffset : low - yOffset
    f_add_label(f_label_text("REPAIR ROOM | THIN", recoveryScore), yValue, placeAbove ? high : low, placeAbove, neutralColor)
    lastEventLabelBar := bar_index

if failedNow and showEventLabels
    bool placeAbove = activeDirection == 1
    float yValue = placeAbove ? high + yOffset : low - yOffset
    f_add_label("RECOVERY | FAILED", yValue, placeAbove ? high : low, placeAbove, dangerColor)
    lastEventLabelBar := bar_index

if expiredNow and showExpiredLabels and canEventLabel
    bool placeAbove = activeDirection == -1
    float yValue = placeAbove ? high + yOffset : low - yOffset
    f_add_label("RECOVERY | EXPIRED", yValue, placeAbove ? high : low, placeAbove, neutralColor)
    lastEventLabelBar := bar_index

if showContextLabels and (nearDamagedRail or reviewReady) and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
    bool placeAbove = activeDirection == -1
    bool eventNearby = not na(lastEventLabelBar) and bar_index - lastEventLabelBar <= labelCooldownBars
    float ctxOffsetMult = eventNearby ? 2.10 : 1.15
    float yValue = placeAbove ? high + yOffset * ctxOffsetMult : low - yOffset * ctxOffsetMult
    string ctxText = recovered ? f_label_text("RECOVERY | REVIEW", recoveryScore) : "REPAIR | RAIL WATCH"
    f_add_label(ctxText, yValue, placeAbove ? high : low, placeAbove, recovered ? activeColor : accentColor)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Active visuals
// -------------------------------------------------
var box recoveryPocketBox = na
var box repairRoomBox = na
var label recoveryPocketLabel = na
var label repairRoomLabel = na
var line railLine = na
var line riskLine = na
var line targetLine = na
var label riskBadge = na
var label targetBadge = na

if activeDirection != 0 and not expiredPlan and showRecoveryPocket
    float pocketTop = activeRail + safeAtr * recoveryPocketAtr
    float pocketBottom = activeRail - safeAtr * recoveryPocketAtr
    string pocketState = recovered ? "RECOVERY POCKET" : "REPAIR POCKET"
    string pocketText = (activeDirection == 1 ? "BULL " : "BEAR ") + pocketState + " | Q" + str.tostring(int(math.round(recoveryScore))) + " " + f_score_grade(recoveryScore)
    int pocketX = int(math.round((activeDamageBar + bar_index + forwardBars) / 2.0))
    float pocketY = (pocketTop + pocketBottom) / 2.0
    if na(recoveryPocketBox)
        recoveryPocketBox := box.new(left = activeDamageBar, top = pocketTop, right = bar_index + forwardBars, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(activeColor, zoneTransparency), border_color = color.new(activeColor, 28), border_width = 1)
    else
        box.set_lefttop(recoveryPocketBox, activeDamageBar, pocketTop)
        box.set_rightbottom(recoveryPocketBox, bar_index + forwardBars, pocketBottom)
        box.set_bgcolor(recoveryPocketBox, color.new(activeColor, zoneTransparency))
        box.set_border_color(recoveryPocketBox, color.new(activeColor, 28))
    if na(recoveryPocketLabel)
        recoveryPocketLabel := label.new(pocketX, pocketY, pocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = activeColor, textcolor = f_text_on(activeColor), size = f_text_size(labelFontSize))
    else
        label.set_xy(recoveryPocketLabel, pocketX, pocketY)
        label.set_text(recoveryPocketLabel, pocketText)
        label.set_color(recoveryPocketLabel, activeColor)
        label.set_textcolor(recoveryPocketLabel, f_text_on(activeColor))
        label.set_size(recoveryPocketLabel, f_text_size(labelFontSize))
else
    if not na(recoveryPocketBox)
        box.delete(recoveryPocketBox)
        recoveryPocketBox := na
    if not na(recoveryPocketLabel)
        label.delete(recoveryPocketLabel)
        recoveryPocketLabel := na

bool showUsableRepairRoom = activeDirection != 0 and not expiredPlan and recovered and showRepairRoom and roomAtr >= minimumRoomAtr

if showUsableRepairRoom
    float roomTop = activeDirection == 1 ? targetGuide : activeRail
    float roomBottom = activeDirection == 1 ? activeRail : targetGuide
    string roomText = "REPAIR ROOM | " + str.tostring(math.max(roomAtr, 0.0), "0.0") + " ATR"
    int roomX = int(math.round((recoveryBar + bar_index + forwardBars) / 2.0))
    float roomY = (roomTop + roomBottom) / 2.0
    if na(repairRoomBox)
        repairRoomBox := box.new(left = recoveryBar, top = roomTop, right = bar_index + forwardBars, bottom = roomBottom, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = color.new(accentColor, 35), border_width = 1)
    else
        box.set_lefttop(repairRoomBox, recoveryBar, roomTop)
        box.set_rightbottom(repairRoomBox, bar_index + forwardBars, roomBottom)
        box.set_bgcolor(repairRoomBox, color.new(accentColor, 90))
        box.set_border_color(repairRoomBox, color.new(accentColor, 35))
    if na(repairRoomLabel)
        repairRoomLabel := label.new(roomX, roomY, roomText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = accentColor, textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize))
    else
        label.set_xy(repairRoomLabel, roomX, roomY)
        label.set_text(repairRoomLabel, roomText)
        label.set_color(repairRoomLabel, accentColor)
        label.set_textcolor(repairRoomLabel, f_text_on(accentColor))
        label.set_size(repairRoomLabel, f_text_size(labelFontSize))
else
    if not na(repairRoomBox)
        box.delete(repairRoomBox)
        repairRoomBox := na
    if not na(repairRoomLabel)
        label.delete(repairRoomLabel)
        repairRoomLabel := na

if activeDirection != 0 and not expiredPlan and showStructureRails
    if na(railLine)
        railLine := line.new(activeDamageBar, activeRail, bar_index + forwardBars, activeRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(activeColor, 0), style = line.style_solid, width = 2)
    else
        line.set_xy1(railLine, activeDamageBar, activeRail)
        line.set_xy2(railLine, bar_index + forwardBars, activeRail)
        line.set_color(railLine, color.new(activeColor, 0))
        line.set_style(railLine, line.style_solid)
        line.set_width(railLine, 2)

    if na(riskLine)
        riskLine := line.new(activeDamageBar, riskEdge, bar_index + forwardBars, riskEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 5), style = line.style_dashed, width = 1)
    else
        line.set_xy1(riskLine, activeDamageBar, riskEdge)
        line.set_xy2(riskLine, bar_index + forwardBars, riskEdge)
        line.set_color(riskLine, color.new(dangerColor, 5))
        line.set_style(riskLine, line.style_dashed)

    int badgeX = bar_index + forwardBars
    if na(riskBadge)
        riskBadge := label.new(badgeX, riskEdge, "RISK EDGE | " + f_fmt_price(riskEdge), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = dangerColor, textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize))
    else
        label.set_xy(riskBadge, badgeX, riskEdge)
        label.set_text(riskBadge, "RISK EDGE | " + f_fmt_price(riskEdge))
        label.set_color(riskBadge, dangerColor)
        label.set_textcolor(riskBadge, f_text_on(dangerColor))
        label.set_size(riskBadge, f_text_size(labelFontSize))

    if recovered
        if na(targetLine)
            targetLine := line.new(recoveryBar, targetGuide, bar_index + forwardBars, targetGuide, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), style = line.style_dotted, width = 2)
        else
            line.set_xy1(targetLine, recoveryBar, targetGuide)
            line.set_xy2(targetLine, bar_index + forwardBars, targetGuide)
            line.set_color(targetLine, color.new(accentColor, 0))
            line.set_style(targetLine, line.style_dotted)
            line.set_width(targetLine, 2)
        if na(targetBadge)
            targetBadge := label.new(badgeX, targetGuide, "TARGET | " + f_fmt_price(targetGuide), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize))
        else
            label.set_xy(targetBadge, badgeX, targetGuide)
            label.set_text(targetBadge, "TARGET | " + f_fmt_price(targetGuide))
            label.set_color(targetBadge, accentColor)
            label.set_textcolor(targetBadge, f_text_on(accentColor))
            label.set_size(targetBadge, f_text_size(labelFontSize))
    else
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na
        if not na(targetBadge)
            label.delete(targetBadge)
            targetBadge := na
else
    if not na(railLine)
        line.delete(railLine)
        railLine := na
    if not na(riskLine)
        line.delete(riskLine)
        riskLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(riskBadge)
        label.delete(riskBadge)
        riskBadge := na
    if not na(targetBadge)
        label.delete(targetBadge)
        targetBadge := na

barcolor(tintActiveBars and activeDirection == 1 and not failedRecovery ? color.new(bullColor, 86) : tintActiveBars and activeDirection == -1 and not failedRecovery ? color.new(bearColor, 86) : na)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = table.new(f_panel_pos(panelLocation), 2, 8, bgcolor = f_panel_bg(panelTheme), frame_color = panelBorder, frame_width = 1, border_width = 1)

if barstate.islast
    table.clear(infoPanel, 0, 0, 1, 7)
    if showPanel
        color rowBg = f_panel_row_bg(panelTheme)
        color labelCol = f_panel_label(panelTheme)
        color valueCol = f_panel_value(panelTheme)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Market Structure Recovery Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        table.cell(infoPanel, 0, 1, "Structure State", text_color = labelCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize))
        table.cell(infoPanel, 1, 1, structureState, text_color = stateColor, bgcolor = rowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
        table.cell(infoPanel, 0, 2, "Recovery Score", text_color = labelCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize))
        table.cell(infoPanel, 1, 2, activeDirection == 0 ? "-" : str.tostring(int(math.round(recoveryScore))) + " / 100 " + f_score_grade(recoveryScore), text_color = stateColor, bgcolor = rowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
        table.cell(infoPanel, 0, 3, "Acceptance", text_color = labelCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize))
        table.cell(infoPanel, 1, 3, acceptanceText, text_color = recovered and acceptanceHoldBars >= acceptanceBars ? bullColor : valueCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
        table.cell(infoPanel, 0, 4, "Risk Edge", text_color = labelCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize))
        table.cell(infoPanel, 1, 4, f_fmt_price(riskEdge), text_color = failedRecovery ? dangerColor : valueCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
        table.cell(infoPanel, 0, 5, "Target", text_color = labelCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize))
        table.cell(infoPanel, 1, 5, activeDirection == 0 ? "-" : f_fmt_price(targetGuide), text_color = activeDirection == 0 ? valueCol : accentColor, bgcolor = rowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
        table.cell(infoPanel, 0, 6, "Action", text_color = labelCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize))
        table.cell(infoPanel, 1, 6, actionText, text_color = stateColor, bgcolor = rowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
        table.cell(infoPanel, 0, 7, "Proof", text_color = labelCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize))
        table.cell(infoPanel, 1, 7, proofText, text_color = proofCol, bgcolor = rowBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(damageStarted, title = "Structure Damage Detected", message = "Market Structure Recovery Planner: confirmed structure damage detected. Review the damaged rail and recovery context.")
alertcondition(recoveryNow, title = "Structure Recovery Detected", message = "Market Structure Recovery Planner: price recovered the damaged structure rail. This is an attention marker, not a trade instruction.")
alertcondition(plannerReady and not plannerReady[1], title = "Recovery Planner Ready", message = "Market Structure Recovery Planner: recovery score, acceptance, and repair room meet the planner-ready threshold.")
alertcondition(meaningfulRoomThin and not meaningfulRoomThin[1], title = "Repair Room Thin", message = "Market Structure Recovery Planner: recovery exists, but structural repair room is thin.")
alertcondition(failedNow, title = "Recovery Failed", message = "Market Structure Recovery Planner: price crossed the active recovery risk edge. Review the plan context.")
````
