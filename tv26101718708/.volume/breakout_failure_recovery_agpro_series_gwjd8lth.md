# Breakout Failure Recovery [AGPro Series]

- url: https://www.tradingview.com/script/gwjD8ltH-Breakout-Failure-Recovery-AGPro-Series/
- type: indicator
- pine_id: PUB;3a872ac436634605a067b90981f8bb59
- version: 4.0

## Description

Breakout Failure Recovery [AGPro Series]

🧠 Core Idea

After a failed breakout, is price recovering through the reclaim level or confirming the failure?


📌 Overview / What it does

Breakout Failure Recovery is a chart-first failed-breakout lifecycle planner built to evaluate what happens after price probes outside a recent range and closes back inside.

The script maps a failure box, reclaim trigger, risk shelf, recovery/rejection labels, and a compact AGPro panel. It converts close-back-inside behavior, reclaim speed, retest response, volume behavior, and time decay into a 0-100 Recovery Score with a clear next-action state.

It does not predict the next move, automate execution, or act as a generic failed-break signal. Its purpose is to organize the post-failure decision context.


🎯 Purpose & Design Philosophy

This script was built for traders who do not want to treat every failed breakout the same way.

Some failed breaks recover quickly through the original breakout level. Others reject the boundary, lose time, and confirm that the attempt has failed. This tool focuses on that decision window.

The design supports a planner mindset: identify the failure, measure the reclaim attempt, locate the risk shelf, and decide whether the context deserves review or should be downgraded.


⚡ Why This Script Is Different

Most tools mark a failed break as a single event.

This script does NOT stop at the failed-break label, does not clone a Swing Failure Pattern engine, and does not become a generic breakout-failure signal board.

Instead, it evaluates the recovery path after the failure. The main output is a recovery state: Recovery Active, Recovery Watch, Failure Confirmed, Reclaim Pending, Window Decaying, or No Active Failure.


⚙️ Methodology

1. Context Detection
The script builds a recent range from prior bars and checks whether price probes beyond the upper or lower boundary before closing back inside.

2. Reference Mapping
When a failed break appears, it maps the failure box, reclaim trigger, and risk shelf around the failed boundary.

3. Reaction Evaluation
The model scores close-back-inside quality, reclaim speed, retest response, volume behavior, and time decay.

4. Visual Output
The result is shown through centered failure-box text, a centered risk-shelf label, reclaim/reject labels, alert conditions, and a clean AGPro planning panel.


🗺️ How to Read the Chart

Failure Box = the failed-break excursion outside the recent range.

Reclaim Trigger = the level that shows the original breakout attempt is trying to recover.

Risk Shelf = the boundary zone where retest response should be reviewed.

Labels = compact markers for failed break, reclaim, reject, decay, and watch context.

Colors = teal highlights constructive recovery context, pink highlights failure or rejection pressure, amber highlights shelf review, and indigo highlights watch states.

Panel = summarizes Failure State, Recovery Score, Reclaim Level, Risk Zone, and Action.


🚦 Signals & States

• Failed Breakout Detected → price probed outside the recent range and closed back inside.

• Recovery Watch → recovery conditions are developing, but reclaim confirmation is incomplete.

• Recovery Active → reclaim behavior and the Recovery Score have reached stronger review context.

• Failure Confirmed → price rejects the failed boundary or moves deeper back into the range.

• Reclaim Pending → an active failure exists, but recovery conditions are not strong enough yet.

• Window Decaying → the failed-break context is getting old and should carry less weight.


🔔 Alerts Logic

Alerts trigger when a failed breakout is detected, when Recovery Watch appears, when Recovery Active appears, or when Failure Confirmed appears.

Alerts are attention markers only. They are not trade instructions, entry commands, exit commands, or automated strategy rules.


🧩 Confluence Logic

The strongest recovery context appears when price closes back inside the range, reclaims the failed boundary quickly, shows a constructive retest response, receives supportive volume, and does not lose too much time after the failed break.

When these components weaken, the script can shift toward Reclaim Pending, Window Decaying, or Failure Confirmed.


📊 When to Use

• After a breakout attempt closes back inside a recent range

• During range-bound markets with frequent boundary tests

• Around failed expansion attempts where reclaim quality matters

• When deciding whether a failed breakout deserves continued monitoring

• On liquid symbols where range, volume, and candle behavior are readable


⚠️ When NOT to Use

• Very low-liquidity symbols with unstable candles

• Extremely noisy micro-timeframes

• News-driven spikes where levels lose structure quickly

• Markets with unreliable volume data

• Situations where the user expects a direct signal-only tool


🎛️ Key Inputs

• Failure Range Lookback → controls the recent range used to detect failed breaks.

• Failure Probe ATR → defines how far price must probe beyond the range boundary.

• Recovery Window Bars → controls how long the failed-break recovery window stays relevant.

• Retest / Shelf ATR → controls risk shelf thickness and boundary response tolerance.

• Recovery Active Threshold → sets the minimum score for the strongest recovery state.

• Label and Panel Font Size → controls chart labels, centered zone text, and panel readability.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The failure box gives the visual story. The reclaim trigger and risk shelf define the practical review frame. Labels remain compact and controlled so the chart stays active without becoming crowded.

The AGPro panel uses a merged blue title row and a compact decision layout for fast reading.


🧪 Practical Usage Workflow

1. Read the panel state and Recovery Score.

2. Check the failure box and failed boundary.

3. Compare price behavior against the reclaim trigger.

4. Review the risk shelf and rejection response.

5. Treat alerts as attention markers, then evaluate broader market context.


🔍 Interpretation Guidelines

Think in terms of failed-break lifecycle, not prediction.

A stronger Recovery Score means the failed breakout is attempting to reclaim quickly with better response and participation. A weaker score means the failure may be aging, rejecting, or losing structural quality.

Failure Confirmed does not mean the market must continue in one direction. It means the failed-break attempt is not recovering cleanly within the current rule set.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a generic failed-break signal

• Not a Swing Failure Pattern clone


⚠️ Limitations & Transparency

The script is rule-based and depends on recent price, volatility, range, volume, and candle behavior.

Different timeframes can change how failure and recovery appear. Volatility spikes can temporarily distort boundary behavior. Symbols with unreliable volume may produce weaker participation readings.

Outputs should always be interpreted with broader market structure, liquidity, and risk context.


🧠 Market Context Notes

Failed breakouts are most useful when the boundary is readable and the follow-up reaction is clear.

A quick reclaim can show that the failed attempt is recovering. A weak retest, slow response, or deep move back into the range can show that the failed break is confirming instead.


🧾 Use Case Examples

When price probes above a range, closes back inside, then quickly reclaims the upper boundary with supportive volume, the planner may classify the context as Recovery Active.

When price probes above a range, closes back inside, retests the boundary from below, and rejects again, the planner may classify the context as Failure Confirmed.


🧱 System Philosophy

AGPro planning tools are designed to help traders evaluate context before reacting.

This script follows that philosophy by turning failed breakouts into a structured decision question: is the attempt recovering, aging, or confirming failure?


🔐 Non-Promise Statement

No indicator can provide certainty.

This tool provides structured visual context and rule-based attention markers. It does not guarantee continuation, reversal, recovery, or rejection.


📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, and no script can remove uncertainty.

Users are responsible for their own analysis, risk management, and decisions.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the planner to study how failed breakouts behave after the first rejection, how reclaim speed affects context, and how risk shelves help organize post-failure review.

## Source Code

````pine
// -------------------------------------------------
// Breakout Failure Recovery [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.9
//
// Breakout Failure Recovery is a chart-first failed-breakout lifecycle
// planner. It tracks a failed break outside a recent range, maps the reclaim
// trigger and risk shelf, scores whether the failed breakout is recovering or
// confirming failure through close-back-inside behavior, reclaim speed, retest
// response, volume behavior and time decay, and proves how often flagged
// failed breaks actually reclaimed (Recovery Rate).
// Version 1.9 refines compact map labeling and event-label separation only.
// Failure detection, scoring, proof and alert behavior remain unchanged.
// -------------------------------------------------

//@version=6
indicator("Breakout Failure Recovery [AGPro Series]",
     shorttitle = "AG BFR",
     overlay = true,
     max_labels_count = 180,
     max_boxes_count = 40,
     max_lines_count = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgLight  = color.rgb(248, 250, 252)
panelBorderD  = color.rgb(51, 65, 85)
panelBorderL  = color.rgb(203, 213, 225)
panelLabelD   = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueD   = color.rgb(226, 232, 240)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
dangerColor   = color.rgb(239, 68, 68)
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Failure Engine"
rangeLookback = input.int(34, "Failure Range Lookback", minval = 12, maxval = 220, group = groupEngine, tooltip = "Lookback used to define the recent range that price attempted to break. The current bar is excluded so the failed-break test is evaluated against prior structure.")
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = "ATR length used for breakout probe tolerance, reclaim trigger width, risk shelf thickness, label spacing, and object projection.")
failureProbeAtr = input.float(0.16, "Failure Probe ATR", minval = 0.03, maxval = 1.50, step = 0.01, group = groupEngine, tooltip = "ATR-based distance beyond the range boundary required before a break can be evaluated as a failed breakout.")
recoveryWindowBars = input.int(24, "Recovery Window Bars", minval = 5, maxval = 120, group = groupEngine, tooltip = "Number of bars after the failed break where recovery or failure confirmation is actively evaluated. Older events gradually lose weight.")
retestToleranceAtr = input.float(0.24, "Retest / Shelf ATR", minval = 0.03, maxval = 1.50, step = 0.01, group = groupEngine, tooltip = "ATR-based tolerance around the failed boundary used for retest response and the visual risk shelf.")
volumeLength = input.int(24, "Volume Baseline Length", minval = 5, maxval = 160, group = groupEngine, tooltip = "Volume baseline used to judge whether a reclaim or rejection has participation. On weak-volume symbols this component should be interpreted carefully.")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = "Controls how strict the failed-break model is. Conservative requires a deeper probe and cleaner close back inside; Aggressive accepts earlier recovery context.")
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = "When enabled, failed-break labels and alerts are confirmed only after the bar closes. This keeps public chart behavior stable.")

groupScore = "Recovery Score"
minRecoveryScore = input.int(70, "Recovery Active Threshold", minval = 45, maxval = 95, group = groupScore, tooltip = "Minimum 0-100 Recovery Score required before the strongest Recovery Active state can appear.")
watchScore = input.int(54, "Recovery Watch Threshold", minval = 25, maxval = 90, group = groupScore, tooltip = "Minimum 0-100 Recovery Score required before the script marks a developing Recovery Watch context.")
volumeSupportLevel = input.float(1.05, "Volume Support Level", minval = 0.50, maxval = 3.00, step = 0.05, group = groupScore, tooltip = "Relative volume threshold used to classify reclaim or rejection participation as supportive.")

groupVisual = "Visual Settings"
showRangeContext = input.bool(true, "Show Range Context", group = groupVisual, tooltip = "Draws subtle rolling range rails from the failed-break engine so the chart keeps structural context before an active failure appears.")
rangeContextTransparency = input.int(84, "Range Context Transparency", minval = 50, maxval = 94, group = groupVisual, tooltip = "Transparency for the rolling range context rails. Higher values are quieter; lower values make historical range structure more visible.")
showFailureBox = input.bool(true, "Show Failure Box", group = groupVisual, tooltip = "Displays the active failed-break excursion as a concept-native failure box with a separate filled center badge.")
showRecoveryTrigger = input.bool(true, "Show Recovery Trigger", group = groupVisual, tooltip = "Displays the reclaim trigger level that would show the original breakout attempt is recovering after the failure.")
showRiskShelf = input.bool(true, "Show Risk Shelf", group = groupVisual, tooltip = "Displays a risk shelf around the failed boundary. It is a planning reference for recovery or rejection review, not an order level.")
showRightEdgeTags = input.bool(false, "Show Right-Edge Tags", group = groupVisual, tooltip = "Displays premium right-edge badges for the active reclaim trigger and recovery map state. Disabled by default to keep publication screenshots cleaner.")
showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Displays compact failed-break, reclaim, reject, and recovery-watch labels with controlled spacing.")
showWatchLabels = input.bool(false, "Show Sparse Watch Labels", group = groupVisual, tooltip = "Adds sparse context labels while a failed-break recovery window is active. Disabled by default because the active map and right-edge tags already carry live context.")
labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupVisual, tooltip = "Compact keeps labels short for publication screenshots. Detailed adds state and score context directly on the chart.")
labelCooldownBars = input.int(22, "Label Cooldown Bars", minval = 3, maxval = 90, group = groupVisual, tooltip = "Minimum bars between recurring labels. Critical failed-break and reclaim events can still print promptly.")
maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 40, group = groupVisual, tooltip = "Maximum number of recent labels retained on the chart. Older labels are removed first to protect performance.")
forwardBars = input.int(20, "Forward Render Bars", minval = 8, maxval = 140, group = groupVisual, tooltip = "Number of bars projected to the right for the failure box, reclaim trigger, and risk shelf.")
labelOffsetAtr = input.float(1.35, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "ATR-based label offset that keeps labels above or below candles.")
labelStackAtr = input.float(0.65, "Label Stack Offset ATR", minval = 0.00, maxval = 2.00, step = 0.05, group = groupVisual, tooltip = "Adds extra spacing when labels appear close together on the same side of price.")
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls all chart label sizes, including centered box and shelf labels. Normal is the default publication setting.")

groupPanel = "Panel Settings"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro planning panel. The default is visible for publication-ready chart context.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the AG Pro summary panel to the preferred chart location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Switches the panel between the premium AGPro dark theme and a light chart-friendly theme.")
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default AGPro publication setting.")

groupAlerts = "Alerts"
alertScore = input.int(70, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = "Minimum Recovery Score required for recovery-watch and recovery-active alerts.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_max, _value))

f_text_size(_size) =>
    switch _size
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(_pos) =>
    switch _pos
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt(_value) =>
    na(_value) ? "-" : str.tostring(_value, "#.##")

f_fmt_price(_value) =>
    na(_value) ? "-" : str.tostring(_value, format.mintick)

f_score_grade(_score) =>
    _score >= 85 ? "A+" : _score >= 76 ? "A" : _score >= 66 ? "B" : _score >= 55 ? "C" : _score >= 42 ? "D" : "E"

f_score_color(_score) =>
    _score >= minRecoveryScore ? bullColor : _score >= watchScore ? neutralColor : _score >= 42 ? accentColor : dangerColor

f_text_on(_bg) =>
    bright = (color.r(_bg) * 299 + color.g(_bg) * 587 + color.b(_bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_panel_row(_panel, _row, _label, _value, _valueColor, _bg, _labelColor, _textSize) =>
    table.cell(_panel, 0, _row, _label, text_color = _labelColor, bgcolor = _bg, text_size = _textSize, text_halign = text.align_left)
    table.cell(_panel, 1, _row, _value, text_color = _valueColor, bgcolor = _bg, text_size = _textSize, text_halign = text.align_right)

f_panel_focus_row(_panel, _row, _label, _value, _valueColor, _valueBg, _labelBg, _labelColor, _textSize) =>
    table.cell(_panel, 0, _row, _label, text_color = _labelColor, bgcolor = _labelBg, text_size = _textSize, text_halign = text.align_left)
    table.cell(_panel, 1, _row, _value, text_color = _valueColor, bgcolor = _valueBg, text_size = _textSize, text_halign = text.align_right)

// -------------------------------------------------
// Core Model
// -------------------------------------------------
confirmedBar = confirmOnClose ? barstate.isconfirmed : true
atrRaw = ta.atr(atrLength)
atr = math.max(nz(atrRaw, high - low), syminfo.mintick)
probeMultiplier = sensitivity == "Conservative" ? failureProbeAtr * 1.35 : sensitivity == "Aggressive" ? failureProbeAtr * 0.75 : failureProbeAtr
insideRequirement = sensitivity == "Conservative" ? 0.08 : sensitivity == "Aggressive" ? 0.02 : 0.04

upperRaw = ta.highest(high[1], rangeLookback)
lowerRaw = ta.lowest(low[1], rangeLookback)
validRange = not na(upperRaw) and not na(lowerRaw) and upperRaw > lowerRaw
upperRef = validRange ? upperRaw : high
lowerRef = validRange ? lowerRaw : low
rangeHeight = math.max(upperRef - lowerRef, syminfo.mintick)
rangeMid = (upperRef + lowerRef) * 0.5
probeBuffer = atr * probeMultiplier
shelfHalf = atr * retestToleranceAtr

closeInsideRange = close < upperRef and close > lowerRef
upperInsideDepth = validRange ? f_clamp((upperRef - close) / rangeHeight, 0.0, 1.0) : 0.0
lowerInsideDepth = validRange ? f_clamp((close - lowerRef) / rangeHeight, 0.0, 1.0) : 0.0
upperFailureCandidate = confirmedBar and validRange and high > upperRef + probeBuffer and closeInsideRange and upperInsideDepth >= insideRequirement
lowerFailureCandidate = confirmedBar and validRange and low < lowerRef - probeBuffer and closeInsideRange and lowerInsideDepth >= insideRequirement
bothFailureCandidates = upperFailureCandidate and lowerFailureCandidate
newUpperFailure = upperFailureCandidate and (not bothFailureCandidates or close <= rangeMid)
newLowerFailure = lowerFailureCandidate and (not bothFailureCandidates or close > rangeMid)
newFailure = newUpperFailure or newLowerFailure

var int activeFailureDir = 0
var int failureBar = na
var float failureBoundary = na
var float failureOpposite = na
var float failureTop = na
var float failureBottom = na
var float failureInsideScore = na
var float failureRangeMid = na

if newFailure
    activeFailureDir := newUpperFailure ? 1 : -1
    failureBar := bar_index
    failureBoundary := newUpperFailure ? upperRef : lowerRef
    failureOpposite := newUpperFailure ? lowerRef : upperRef
    failureTop := newUpperFailure ? math.max(high, upperRef + probeBuffer) : lowerRef
    failureBottom := newUpperFailure ? upperRef : math.min(low, lowerRef - probeBuffer)
    failureInsideScore := newUpperFailure ? upperInsideDepth * 100.0 : lowerInsideDepth * 100.0
    failureRangeMid := rangeMid

hasActiveFailure = activeFailureDir != 0 and not na(failureBar) and not na(failureBoundary)
failureAge = hasActiveFailure ? bar_index - failureBar : 0
failureExpired = hasActiveFailure and failureAge > recoveryWindowBars
reclaimLevel = hasActiveFailure ? failureBoundary + activeFailureDir * probeBuffer : na
riskLow = hasActiveFailure ? failureBoundary - shelfHalf : na
riskHigh = hasActiveFailure ? failureBoundary + shelfHalf : na
recoveryDenom = math.max(probeBuffer + shelfHalf, syminfo.mintick)
recoveryProgress = hasActiveFailure ? activeFailureDir == 1 ? (close - failureBoundary) / recoveryDenom : (failureBoundary - close) / recoveryDenom : 0.0
reclaimCondition = hasActiveFailure and (activeFailureDir == 1 ? close >= reclaimLevel : close <= reclaimLevel)
boundaryRejected = hasActiveFailure and failureAge > 0 ? activeFailureDir == 1 ? high >= failureBoundary and close < failureBoundary - shelfHalf : low <= failureBoundary and close > failureBoundary + shelfHalf : false
deepFailureMove = hasActiveFailure and (activeFailureDir == 1 ? close < failureRangeMid : close > failureRangeMid)
failureConfirmed = hasActiveFailure and not reclaimCondition and (boundaryRejected or (deepFailureMove and failureAge >= 2))

barRange = math.max(high - low, syminfo.mintick)
closeLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
bodyEfficiency = math.abs(close - open) / barRange
recoveryCandle = hasActiveFailure and (activeFailureDir == 1 ? close >= open : close <= open)
candleScore = hasActiveFailure ? recoveryCandle ? bodyEfficiency * 70.0 + (activeFailureDir == 1 ? closeLocation : 1.0 - closeLocation) * 30.0 : (activeFailureDir == 1 ? closeLocation : 1.0 - closeLocation) * 35.0 : 0.0
retestResponseScore = hasActiveFailure ? f_clamp(recoveryProgress * 70.0 + 35.0 + candleScore * 0.25, 0.0, 100.0) : 0.0
retestResponseScore := failureConfirmed ? math.min(retestResponseScore, 24.0) : retestResponseScore

volumeNow = na(volume) ? 0.0 : volume
volumeBase = nz(ta.sma(volume, volumeLength), volumeNow)
rvol = volumeBase > 0.0 ? volumeNow / volumeBase : 1.0
rvolSlope = rvol - nz(rvol[5], rvol)
volumeLevelScore = f_clamp((rvol - 0.65) / math.max(volumeSupportLevel - 0.65, 0.10) * 70.0, 0.0, 85.0)
volumeScore = f_clamp(volumeLevelScore + rvolSlope * 80.0 + (recoveryCandle ? 15.0 : 0.0), 0.0, 100.0)
volumeSupported = rvol >= volumeSupportLevel or (rvol > 0.90 and rvolSlope > 0.05 and recoveryCandle)

speedScore = hasActiveFailure ? f_clamp(100.0 - failureAge / math.max(recoveryWindowBars, 1) * 100.0, 0.0, 100.0) : 0.0
reclaimSpeedScore = reclaimCondition ? speedScore : f_clamp(speedScore * 0.62 + retestResponseScore * 0.38, 0.0, 100.0)
timeDecayScore = hasActiveFailure ? f_clamp(100.0 - failureAge / math.max(recoveryWindowBars * 1.35, 1.0) * 100.0, 0.0, 100.0) : 0.0
recoveryScore = hasActiveFailure ? f_clamp(nz(failureInsideScore) * 0.18 + reclaimSpeedScore * 0.20 + retestResponseScore * 0.31 + volumeScore * 0.16 + timeDecayScore * 0.15, 0.0, 100.0) : 0.0

failureSideText = hasActiveFailure ? activeFailureDir == 1 ? "Upper Break Failed" : "Lower Break Failed" : "No Active Failure"
stateText = not validRange ? "Building Range" : not hasActiveFailure ? "No Active Failure" : reclaimCondition and recoveryScore >= minRecoveryScore ? "Recovery Active" : failureConfirmed ? "Failure Confirmed" : recoveryScore >= watchScore and not failureExpired ? "Recovery Watch" : failureExpired ? "Window Decaying" : "Reclaim Pending"
actionText = stateText == "Recovery Active" ? "Review Reclaim" : stateText == "Failure Confirmed" ? "Respect Shelf" : stateText == "Recovery Watch" ? "Watch Response" : stateText == "Reclaim Pending" ? "Wait Reclaim" : stateText == "Window Decaying" ? "Reduce Weight" : stateText == "Building Range" ? "Build Range" : "Wait Failed Break"
stateColor = stateText == "Recovery Active" ? activeFailureDir == -1 ? bearColor : bullColor : stateText == "Failure Confirmed" ? activeFailureDir == -1 ? bullColor : bearColor : stateText == "Window Decaying" ? dangerColor : stateText == "Recovery Watch" or stateText == "Reclaim Pending" ? accentColor : neutralColor
failureColor = hasActiveFailure ? activeFailureDir == 1 ? bearColor : bullColor : neutralColor
recoveryColor = hasActiveFailure ? activeFailureDir == 1 ? bullColor : bearColor : accentColor
scoreText = hasActiveFailure ? str.tostring(math.round(recoveryScore)) + "/100 " + f_score_grade(recoveryScore) : "-"
reclaimText = hasActiveFailure ? f_fmt_price(reclaimLevel) : "-"
riskText = hasActiveFailure ? f_fmt_price(riskLow) + " - " + f_fmt_price(riskHigh) : "-"
volumeText = volumeSupported ? "Supported " + f_fmt(rvol) + "x" : "Light " + f_fmt(rvol) + "x"
workflowText = hasActiveFailure ? stateText == "Recovery Active" ? "Track Recovery" : stateText == "Failure Confirmed" ? "Review Failure" : "Track Failed Break" : "Standby"

// -------------------------------------------------
// Recovery-rate proof (Confirm Rate)
// -------------------------------------------------
var int  recTotal    = 0
var int  recWon      = 0
var bool pendActive  = false
var bool pendWon     = false

if confirmedBar
    if newFailure
        if pendActive
            recTotal += 1
            if pendWon
                recWon += 1
        pendActive := true
        pendWon := false
    if pendActive and hasActiveFailure and reclaimCondition
        pendWon := true
    if pendActive and not newFailure and (failureConfirmed or failureExpired)
        recTotal += 1
        if pendWon
            recWon += 1
        pendActive := false
        pendWon := false

recoveryRate = recTotal > 0 ? recWon / recTotal * 100.0 : na

// -------------------------------------------------
// Range Context Rails
// -------------------------------------------------
rangeMidTransparency = math.min(rangeContextTransparency + 8, 96)
plot(showRangeContext and validRange ? upperRef : na, "Range Upper Context", color = color.new(bearColor, rangeContextTransparency), linewidth = 1)
plot(showRangeContext and validRange ? lowerRef : na, "Range Lower Context", color = color.new(bullColor, rangeContextTransparency), linewidth = 1)
plot(showRangeContext and validRange ? rangeMid : na, "Range Mid Context", color = color.new(accentColor, rangeMidTransparency), linewidth = 1, style = plot.style_line)

// -------------------------------------------------
// Chart Objects
// -------------------------------------------------
rightX = bar_index + forwardBars
leftX = hasActiveFailure ? failureBar : math.max(0, bar_index - rangeLookback)
centerX = int(math.round((leftX + rightX) * 0.5))
failureBoxMid = hasActiveFailure ? (failureTop + failureBottom) * 0.5 : close
failureBoxHeight = hasActiveFailure ? math.max(math.abs(failureTop - failureBottom), syminfo.mintick) : syminfo.mintick
shelfBoxHeight = hasActiveFailure ? math.max(riskHigh - riskLow, syminfo.mintick) : syminfo.mintick
compactMapMode = hasActiveFailure and failureBoxHeight <= math.max(atr * 1.40, shelfBoxHeight * 2.40)
failureLabelY = hasActiveFailure and math.abs(failureBoxMid - failureBoundary) < atr * 0.70 ? (activeFailureDir == 1 ? failureTop - failureBoxHeight * 0.34 : failureBottom + failureBoxHeight * 0.34) : failureBoxMid
boxStateShort = stateText == "Recovery Active" ? "Recovery Active" : stateText == "Failure Confirmed" ? "Failure Confirmed" : stateText == "Recovery Watch" ? "Recovery Watch" : stateText == "Window Decaying" ? "Window Decay" : "Reclaim Pending"
mapLabelText = hasActiveFailure ? "Failure Map\n" + boxStateShort + " | " + str.tostring(math.round(recoveryScore)) + "/100" : ""
boxLabelText = mapLabelText
shelfLabelText = hasActiveFailure ? compactMapMode ? mapLabelText : "Risk Shelf | " + str.tostring(math.round(recoveryScore)) + "/100" : ""
reclaimTagText = hasActiveFailure ? "Reclaim\n" + f_fmt_price(reclaimLevel) : ""
failureBoxLabelAllowed = hasActiveFailure and not compactMapMode
mapBadgeColor = compactMapMode ? stateColor : neutralColor
mapBadgeTextColor = compactMapMode ? headerText : darkText
shelfZoneColor = compactMapMode ? stateColor : neutralColor

var box failureBox = na
var label failureBoxLabel = na
var box riskShelfBox = na
var label riskShelfLabel = na
var line reclaimLine = na
var label reclaimTag = na
var label mapStateTag = na

if showFailureBox and hasActiveFailure
    if na(failureBox)
        failureBox := box.new(leftX, failureTop, rightX, failureBottom, xloc = xloc.bar_index, border_color = color.new(failureColor, compactMapMode ? 24 : 6), bgcolor = color.new(failureColor, compactMapMode ? 92 : failureExpired ? 94 : 88), border_width = 2)
    else
        box.set_left(failureBox, leftX)
        box.set_right(failureBox, rightX)
        box.set_top(failureBox, failureTop)
        box.set_bottom(failureBox, failureBottom)
        box.set_border_color(failureBox, color.new(failureColor, compactMapMode ? 24 : 6))
        box.set_bgcolor(failureBox, color.new(failureColor, compactMapMode ? 92 : failureExpired ? 94 : 88))
        box.set_border_width(failureBox, 2)
    box.set_text(failureBox, "")
    if failureBoxLabelAllowed
        if na(failureBoxLabel)
            failureBoxLabel := label.new(centerX, failureLabelY, boxLabelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(failureColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_xy(failureBoxLabel, centerX, failureLabelY)
            label.set_text(failureBoxLabel, boxLabelText)
            label.set_color(failureBoxLabel, color.new(failureColor, 0))
            label.set_textcolor(failureBoxLabel, headerText)
            label.set_size(failureBoxLabel, f_text_size(labelFontSize))
    else
        if not na(failureBoxLabel)
            label.delete(failureBoxLabel)
            failureBoxLabel := na
else
    if not na(failureBox)
        box.delete(failureBox)
        failureBox := na
    if not na(failureBoxLabel)
        label.delete(failureBoxLabel)
        failureBoxLabel := na

if showRiskShelf and hasActiveFailure
    if na(riskShelfBox)
        riskShelfBox := box.new(leftX, riskHigh, rightX, riskLow, xloc = xloc.bar_index, border_color = color.new(shelfZoneColor, compactMapMode ? 20 : 10), bgcolor = color.new(shelfZoneColor, compactMapMode ? 92 : 90), border_width = 2)
    else
        box.set_left(riskShelfBox, leftX)
        box.set_right(riskShelfBox, rightX)
        box.set_top(riskShelfBox, riskHigh)
        box.set_bottom(riskShelfBox, riskLow)
        box.set_border_color(riskShelfBox, color.new(shelfZoneColor, compactMapMode ? 20 : 10))
        box.set_bgcolor(riskShelfBox, color.new(shelfZoneColor, compactMapMode ? 92 : 90))
        box.set_border_width(riskShelfBox, 2)
    if na(riskShelfLabel)
        riskShelfLabel := label.new(centerX, failureBoundary, shelfLabelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(mapBadgeColor, 0), textcolor = mapBadgeTextColor, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(riskShelfLabel, centerX, failureBoundary)
        label.set_text(riskShelfLabel, shelfLabelText)
        label.set_color(riskShelfLabel, color.new(mapBadgeColor, 0))
        label.set_textcolor(riskShelfLabel, mapBadgeTextColor)
        label.set_size(riskShelfLabel, f_text_size(labelFontSize))
else
    if not na(riskShelfBox)
        box.delete(riskShelfBox)
        riskShelfBox := na
    if not na(riskShelfLabel)
        label.delete(riskShelfLabel)
        riskShelfLabel := na

if showRecoveryTrigger and hasActiveFailure
    if na(reclaimLine)
        reclaimLine := line.new(leftX, reclaimLevel, rightX, reclaimLevel, xloc = xloc.bar_index, color = color.new(recoveryColor, 0), style = line.style_solid, width = 3)
    else
        line.set_xy1(reclaimLine, leftX, reclaimLevel)
        line.set_xy2(reclaimLine, rightX, reclaimLevel)
        line.set_color(reclaimLine, color.new(recoveryColor, 0))
        line.set_width(reclaimLine, 3)
else
    if not na(reclaimLine)
        line.delete(reclaimLine)
        reclaimLine := na

if showRightEdgeTags and hasActiveFailure
    tagX = rightX + 5
    mapY = activeFailureDir == 1 ? failureTop + atr * 0.70 : failureBottom - atr * 0.70
    mapStyle = activeFailureDir == 1 ? label.style_label_down : label.style_label_up
    mapText = stateText + "\n" + str.tostring(math.round(recoveryScore)) + "/100"
    if na(reclaimTag)
        reclaimTag := label.new(tagX, reclaimLevel, reclaimTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(recoveryColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(reclaimTag, tagX, reclaimLevel)
        label.set_text(reclaimTag, reclaimTagText)
        label.set_color(reclaimTag, color.new(recoveryColor, 0))
        label.set_textcolor(reclaimTag, headerText)
        label.set_size(reclaimTag, f_text_size(labelFontSize))
    if na(mapStateTag)
        mapStateTag := label.new(tagX + 5, mapY, mapText, xloc = xloc.bar_index, yloc = yloc.price, style = mapStyle, color = color.new(stateColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(mapStateTag, tagX + 5, mapY)
        label.set_text(mapStateTag, mapText)
        label.set_style(mapStateTag, mapStyle)
        label.set_color(mapStateTag, color.new(stateColor, 0))
        label.set_textcolor(mapStateTag, headerText)
        label.set_size(mapStateTag, f_text_size(labelFontSize))
else
    if not na(reclaimTag)
        label.delete(reclaimTag)
        reclaimTag := na
    if not na(mapStateTag)
        label.delete(mapStateTag)
        mapStateTag := na

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var int lastBelowLabelBar = na
var int lastAboveLabelBar = na
labelReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
criticalLabelGapBars = math.max(4, int(math.round(labelCooldownBars * 0.35)))
criticalLabelReady = na(lastLabelBar) or bar_index - lastLabelBar >= criticalLabelGapBars
prevReclaimCondition = reclaimCondition[1] == true
prevFailureConfirmed = failureConfirmed[1] == true
recoveryReclaimEvent = confirmedBar and reclaimCondition and not prevReclaimCondition
rejectionEvent = confirmedBar and failureConfirmed and not prevFailureConfirmed
watchLabelEvent = showWatchLabels and confirmedBar and hasActiveFailure and labelReady and ((stateText == "Recovery Watch" and recoveryScore >= watchScore + 8) or (stateText == "Reclaim Pending" and recoveryScore >= watchScore + 12))
shouldPrintLabel = showEventLabels and (((newFailure or recoveryReclaimEvent) and criticalLabelReady) or (rejectionEvent and labelReady) or watchLabelEvent)

if shouldPrintLabel
    printBelow = newLowerFailure ? true : newUpperFailure ? false : recoveryReclaimEvent ? activeFailureDir == 1 : rejectionEvent ? activeFailureDir == -1 : activeFailureDir == 1
    labelY = printBelow ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    stackBelow = printBelow and not na(lastBelowLabelBar) and bar_index - lastBelowLabelBar <= labelCooldownBars
    stackAbove = not printBelow and not na(lastAboveLabelBar) and bar_index - lastAboveLabelBar <= labelCooldownBars
    labelY := stackBelow ? labelY - atr * labelStackAtr : stackAbove ? labelY + atr * labelStackAtr : labelY
    compactText = "Watch\nScore " + str.tostring(math.round(recoveryScore))
    if newFailure
        compactText := (newUpperFailure ? "Upper Fail" : "Lower Fail") + "\nScore " + str.tostring(math.round(nz(failureInsideScore)))
    else if recoveryReclaimEvent
        compactText := "Reclaim\nScore " + str.tostring(math.round(recoveryScore))
    else if rejectionEvent
        compactText := "Reject"
    else if stateText == "Window Decaying"
        compactText := "Decay\nScore " + str.tostring(math.round(recoveryScore))
    detailedText = stateText + "\nScore " + str.tostring(math.round(recoveryScore)) + "\n" + failureSideText
    labelText = labelTextMode == "Compact" ? compactText : detailedText
    tooltipText = "Breakout Failure Recovery\nFailure State: " + failureSideText + "\nRecovery Score: " + scoreText + "\nReclaim Level: " + reclaimText + "\nRisk Zone: " + riskText + "\nVolume: " + volumeText + "\nAction: " + actionText
    labelColor = newFailure ? failureColor : recoveryReclaimEvent ? recoveryColor : rejectionEvent ? failureColor : stateColor
    newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = printBelow ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 0), textcolor = headerText, size = f_text_size(labelFontSize), tooltip = tooltipText, textalign = text.align_center)
    array.push(eventLabels, newLabel)
    lastLabelBar := bar_index
    if printBelow
        lastBelowLabelBar := bar_index
    else
        lastAboveLabelBar := bar_index
    while array.size(eventLabels) > maxVisibleLabels
        label.delete(array.shift(eventLabels))

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
panelBgActive = panelTheme == "Dark" ? panelBgDark : panelBgLight
rowBgActive = panelTheme == "Dark" ? color.rgb(17, 24, 39) : color.rgb(241, 245, 249)
panelLabelActive = panelTheme == "Dark" ? panelLabelD : panelLabelL
panelValueActive = panelTheme == "Dark" ? panelValueD : panelValueL
panelBorderActive = panelTheme == "Dark" ? panelBorderD : panelBorderL
panelSize = f_text_size(panelFontSize)

recoveryRateText = recTotal > 0 ? str.tostring(int(math.round(recoveryRate))) + "% (" + str.tostring(recTotal) + ")" : "Building"
recoveryRateColor = na(recoveryRate) ? panelValueActive : recoveryRate >= 55.0 ? bullColor : recoveryRate >= 45.0 ? neutralColor : bearColor

if showPanel
    if na(infoPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme
        if not na(infoPanel)
            table.delete(infoPanel)
        infoPanel := table.new(f_panel_pos(panelLocation), 2, 8, bgcolor = panelBgActive, frame_color = panelBorderActive, frame_width = 1, border_color = panelBorderActive, border_width = 1)
        table.cell(infoPanel, 0, 0, "AG Pro Breakout Failure Recovery", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        lastPanelLocation := panelLocation
        lastPanelTheme := panelTheme
    if barstate.islast
        table.clear(infoPanel, 0, 1, 1, 7)
        table.cell(infoPanel, 0, 0, "AG Pro Breakout Failure Recovery", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        scoreCellBg = hasActiveFailure ? color.new(f_score_color(recoveryScore), panelTheme == "Dark" ? 20 : 72) : rowBgActive
        stateCellBg = hasActiveFailure ? color.new(stateColor, panelTheme == "Dark" ? 20 : 72) : panelBgActive
        stateCellText = hasActiveFailure ? headerText : panelValueActive
        scoreCellText = hasActiveFailure and recoveryScore >= watchScore ? headerText : hasActiveFailure ? f_text_on(scoreCellBg) : panelValueActive
        f_panel_focus_row(infoPanel, 1, "Workflow", workflowText, headerText, stateCellBg, rowBgActive, panelLabelActive, panelSize)
        f_panel_focus_row(infoPanel, 2, "State", failureSideText + "\n" + stateText, stateCellText, stateCellBg, panelBgActive, panelLabelActive, panelSize)
        f_panel_focus_row(infoPanel, 3, "Recovery Score", scoreText, scoreCellText, scoreCellBg, rowBgActive, panelLabelActive, panelSize)
        f_panel_row(infoPanel, 4, "Recovery Rate", recoveryRateText, recoveryRateColor, panelBgActive, panelLabelActive, panelSize)
        f_panel_row(infoPanel, 5, "Reclaim", reclaimText, hasActiveFailure ? recoveryColor : panelValueActive, rowBgActive, panelLabelActive, panelSize)
        f_panel_row(infoPanel, 6, "Risk Shelf", riskText, hasActiveFailure ? neutralColor : panelValueActive, panelBgActive, panelLabelActive, panelSize)
        f_panel_row(infoPanel, 7, "Review", actionText + "\n" + volumeText, stateColor, rowBgActive, panelLabelActive, panelSize)
else
    if not na(infoPanel)
        table.delete(infoPanel)
        infoPanel := na
        lastPanelLocation := ""
        lastPanelTheme := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
recoveryActive = stateText == "Recovery Active"
recoveryWatch = stateText == "Recovery Watch"
failureConfirmedAlertState = stateText == "Failure Confirmed"
recoveryActiveAlert = recoveryActive and recoveryScore >= alertScore and recoveryActive[1] != true
recoveryWatchAlert = recoveryWatch and recoveryScore >= watchScore and recoveryWatch[1] != true
failureConfirmedAlert = failureConfirmedAlertState and failureConfirmedAlertState[1] != true
newFailureAlert = newFailure

alertcondition(newFailureAlert, "Failed Breakout Detected", "Breakout Failure Recovery: price probed outside the recent range and closed back inside. This is an attention marker, not a trade instruction.")
alertcondition(recoveryWatchAlert, "Recovery Watch", "Breakout Failure Recovery: a failed breakout is showing developing recovery context. Review reclaim level and risk shelf.")
alertcondition(recoveryActiveAlert, "Recovery Active", "Breakout Failure Recovery: reclaim behavior and recovery score reached active review context. This is not a trade instruction.")
alertcondition(failureConfirmedAlert, "Failure Confirmed", "Breakout Failure Recovery: retest response is confirming failed-break context. Review the risk shelf and broader structure.")

// Hidden reference plots
plot(hasActiveFailure ? recoveryScore : na, "Recovery Score", display = display.none)
plot(recoveryRate, "Recovery Rate", display = display.none)
````
