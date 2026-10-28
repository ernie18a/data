# Volume Dry-Up Reversal Planner [AGPro Series]

- url: https://www.tradingview.com/script/9SsDgpWs-Volume-Dry-Up-Reversal-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;e2045b78565340bb8cc05f89e8d43a7d
- version: 4.0

## Description

Volume Dry-Up Reversal Planner [AGPro Series]

🧠 Core Idea

Is the market losing participation before a reversal attempt?


📌 Overview / What it does

Volume Dry-Up Reversal Planner [AGPro Series] detects low-participation pockets where relative volume contracts and candle range compresses.

The script maps a dry-up pocket, tracks whether price attempts to reverse out of that pocket, and displays reversal rails, failure shelves, follow-through references, event labels, and a compact AG Pro dashboard.

It does not predict reversals. It helps organize participation, compression, reaction quality, failure risk, and current action state around a potential dry-up reversal context.


🎯 Purpose & Design Philosophy

Many reversal tools focus on dramatic exhaustion candles or high-volume climaxes.

This script was built for a quieter but important condition: participation drying up before the next reaction.

It helps traders evaluate whether the market is simply inactive, compressing before movement, or beginning a structured reversal attempt from a low-participation pocket.


⚡ Why This Script Is Different

Most volume indicators highlight high-volume events.

This script does NOT chase volume climax or generic reversal signals.

Instead, it focuses on volume dry-up, range compression, reversal rails, failure shelves, follow-through context, and a 0-100 readiness score.


⚙️ Methodology

1. Participation Detection

The script compares current volume against recent average volume to identify low-participation candles.

2. Compression Mapping

Current candle range is compared with recent average range. A dry-up pocket requires both lower participation and controlled range compression.

3. Reversal Evaluation

After a dry-up pocket appears, the script watches whether price breaks beyond the pocket with enough quality to form a reversal attempt.

4. Visual Output

The chart receives a dry-up pocket, reversal rail, failure shelf, follow-through rail, right-side tags, event labels, optional bar coloring, and a dashboard panel.


🗺️ How to Read the Chart

The dry-up pocket marks the area where participation and range compressed.

The reversal rail shows the level price must clear to begin a reversal attempt.

The failure shelf marks where the active reversal context fails.

The follow-through rail marks the first reaction reference after a reversal attempt.

Labels highlight dry-up pockets, bullish reversal attempts, bearish reversal attempts, follow-through, and invalidation.

Colors represent context:

• Teal → bullish reversal attempt

• Pink → bearish reversal attempt or invalidation

• Gold → follow-through or waiting context

• Indigo → dry-up pocket / monitoring context

The panel summarizes:

• Dry-Up state

• Reversal Score

• Participation

• Failure Risk

• Action


🚦 Signals & States

• Dry-Up Pocket → relative volume and range both contracted

• Bull Reversal → price broke above the dry-up pocket

• Bear Reversal → price broke below the dry-up pocket

• Follow-Through → price reached the first reaction rail

• Invalidated → price crossed the failure shelf after a reversal attempt

• READY → reversal context has enough score quality to monitor

• MONITOR → reversal attempt is active but not fully ready

• WAIT → no strong active context exists

• EXPIRED → the dry-up pocket is too old to remain active


🔔 Alerts Logic

Alerts can trigger when a dry-up pocket appears, when a bullish or bearish reversal attempt begins, when the context reaches READY state, when follow-through appears, or when invalidation occurs.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when relative volume contraction, range compression, close response, rejection quality, and volatility fit align.

For example, a low-volume compression pocket followed by a strong close outside the pocket can create a more structured reversal context than a random low-volume candle.


📊 When to Use

• Potential reversal areas after participation fades

• Pullback zones where volume dries up

• Ranging markets before directional reaction

• Trend pauses where continuation or reversal depends on participation

• Liquid crypto, indices, forex, and equities with readable volume behavior


⚠️ When NOT to Use

• Very low-liquidity symbols

• Markets with unreliable volume data

• News spikes and unstable spread conditions

• Extremely noisy candles without structure

• Situations where low volume simply means no meaningful market participation


🎛️ Key Inputs

• Relative Volume Length → controls the volume baseline

• Dry-Up Volume Threshold → controls how strict low-participation detection is

• Range Compression Length → controls the range baseline

• Maximum Range Ratio → controls how compressed the candle must be

• Dry-Up Pocket Window → controls how the pocket is mapped

• Reversal Buffer ATR → controls how far price must clear the pocket

• Failure Shelf ATR → controls where the reversal context fails

• Follow-Through ATR → controls the first reaction reference

• Visual settings → control pockets, rails, labels, tags, panel, and bar colors


🖥️ Interface & Visual Design

The interface is designed to make participation shifts visible without turning the chart into a noisy signal board.

The dry-up pocket defines context, the reversal rail defines the first reaction threshold, the failure shelf defines risk, and the panel summarizes the current state.

The goal is a premium, readable visual map for traders who care about participation and reaction quality.


🧪 Practical Usage Workflow

1. Check whether a dry-up pocket is active

2. Read the panel score and action state

3. Watch the reversal rail

4. Compare follow-through with failure risk

5. Confirm the context with broader market structure and timeframe alignment


🔍 Interpretation Guidelines

A dry-up pocket means participation and range compressed. It does not mean a reversal must happen.

A reversal attempt means price broke out of the pocket with enough reaction to monitor.

A READY state means the rule-based score has enough quality for attention.

Failure risk helps keep the reversal context grounded instead of treating every low-volume area as important.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a guaranteed reversal system.

It is not a high-volume climax detector.

It is not an automated trading tool.

It does not provide financial advice.

It does not guarantee reversal, continuation, profit, or a specific target.


⚠️ Limitations & Transparency

Volume behavior differs across markets, exchanges, sessions, and timeframes.

Some dry-up pockets may lead to no meaningful reaction.

Some reversals may begin without a clean dry-up pattern.

The score is a rule-based context score, not a certainty model.


🧠 Market Context Notes

Volume dry-up can represent hesitation, absorption, exhaustion, or simple inactivity.

The important question is not whether volume is low by itself, but whether price reacts cleanly after participation contracts.

Use the pocket as context, not confirmation by itself.


🧾 Use Case Examples

When price pulls back with shrinking volume and compressed candles, the script can map a dry-up pocket.

If price later breaks above that pocket, the script marks a bullish reversal attempt and tracks follow-through.

If price breaks below the failure shelf after a reversal attempt, the script marks invalidation.


🧱 System Philosophy

This script follows the AGPro Series approach: turn a specific market condition into a structured decision-support map.

The focus is not prediction. The focus is participation, compression, reaction quality, failure awareness, and visual clarity.


🔐 Non-Promise Statement

No script can remove uncertainty from markets.

This tool does not promise accuracy, profitability, or future price movement.

Its purpose is to organize volume dry-up context so the user can interpret the chart more clearly.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly, and any analytical output can fail.

Users are responsible for their own decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Low volume is not automatically bullish or bearish.

The best reads usually come when volume dry-up, range compression, reaction quality, and market structure all support the same context.

## Source Code

````pine
// --------------------------------------------------
// Volume Dry-Up Reversal Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Volume Dry-Up Reversal Planner maps low-participation pockets, evaluates
// whether price is compressing before a reversal attempt, and organizes the
// reaction into a 0-100 readiness score with clear action states and a
// confirmed pocket lifecycle and follow-through proof layer. It is designed for volume dry-up,
// reversal planning, price action, exhaustion, participation analysis, and
// risk-aware market structure review.
// --------------------------------------------------

//@version=6
indicator("Volume Dry-Up Reversal Planner [AGPro Series]",
     shorttitle = "AG Pro VDR",
     overlay = true,
     max_boxes_count = 40,
     max_lines_count = 120,
     max_labels_count = 200)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_DRY = "Dry-Up Detection"
G_REV = "Reversal Logic"
G_PROOF = "Confirm-Rate Proof"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

volumeLength = input.int(30, "Relative Volume Length", minval = 5, maxval = 300, group = G_DRY,
     tooltip = "Lookback used to compare current volume against recent average volume.")
dryVolumeThreshold = input.float(0.58, "Dry-Up Volume Threshold", minval = 0.05, maxval = 1.50, step = 0.01, group = G_DRY,
     tooltip = "Relative volume threshold used to identify low-participation candles. Lower values require stronger volume contraction.")
rangeLength = input.int(18, "Range Compression Length", minval = 5, maxval = 300, group = G_DRY,
     tooltip = "Lookback used to compare current candle range against recent average range.")
maxRangeRatio = input.float(0.78, "Maximum Range Ratio", minval = 0.10, maxval = 2.00, step = 0.01, group = G_DRY,
     tooltip = "Maximum current range divided by average range allowed for dry-up compression.")
dryWindowBars = input.int(7, "Dry-Up Pocket Window", minval = 2, maxval = 40, group = G_DRY,
     tooltip = "Number of recent bars used to map the low-participation pocket after a dry-up condition appears.")
atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_DRY,
     tooltip = "ATR length used to normalize reversal buffers, failure shelves, labels, and target spacing.")

minReadyScore = input.int(66, "Minimum Ready Score", minval = 1, maxval = 100, group = G_REV,
     tooltip = "Minimum 0-100 score required before the dry-up reversal context becomes READY.")
reversalBufferAtr = input.float(0.08, "Reversal Buffer ATR", minval = 0.00, step = 0.01, group = G_REV,
     tooltip = "ATR buffer beyond the dry-up pocket required to confirm a reversal attempt.")
failureShelfAtr = input.float(0.18, "Failure Shelf ATR", minval = 0.00, step = 0.01, group = G_REV,
     tooltip = "ATR shelf beyond the opposite side of the dry-up pocket where the reversal attempt fails.")
followThroughAtr = input.float(0.85, "Follow-Through ATR", minval = 0.10, step = 0.05, group = G_REV,
     tooltip = "ATR distance from the reversal rail used to mark early follow-through.")
maxDryUpAge = input.int(96, "Maximum Dry-Up Age", minval = 5, maxval = 600, group = G_REV,
     tooltip = "Maximum bars a dry-up pocket can remain active before it expires.")
pocketRefreshBars = input.int(18, "Pocket Refresh Bars", minval = 3, maxval = 120, group = G_REV,
     tooltip = "Minimum age required before a new confirmed dry-up condition can replace the active pocket. Active reversal attempts are never replaced by a new pocket.")

proofWindow = input.int(20, "Proof Window Bars", minval = 4, maxval = 200, group = G_PROOF,
     tooltip = "Bars used to resolve each follow-through proof sample after a reversal attempt. A win is recorded when the follow-through rail is reached before price closes an equal distance back through the broken reversal rail within this window.")

showDryPocket = input.bool(true, "Show Dry-Up Pocket", group = G_VISUAL,
     tooltip = "Shows the low-participation pocket used as the reversal reference.")
showPocketBadge = input.bool(true, "Show Centered Pocket Badge", group = G_VISUAL,
     tooltip = "Shows a separate centered badge inside the dry-up pocket for clearer zone identification.")
pocketBadgeAnchor = input.float(0.55, "Pocket Badge Anchor", minval = 0.20, maxval = 0.80, step = 0.05, group = G_VISUAL,
     tooltip = "Controls the horizontal placement of the centered pocket badge inside the projected zone.")
showReversalRail = input.bool(true, "Show Reversal Rail", group = G_VISUAL,
     tooltip = "Shows the active rail price must clear for a reversal attempt.")
showFailureShelf = input.bool(true, "Show Failure Shelf", group = G_VISUAL,
     tooltip = "Shows the shelf where the active reversal context fails.")
showFollowThroughRail = input.bool(true, "Show Follow-Through Rail", group = G_VISUAL,
     tooltip = "Shows the first follow-through reference after a reversal attempt.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows dry-up, reversal, follow-through, and invalidation labels on the chart.")
showDryLabels = input.bool(true, "Show Dry-Up Labels", group = G_VISUAL,
     tooltip = "Shows labels when a new low-participation pocket is detected.")
showReversalLabels = input.bool(true, "Show Reversal Labels", group = G_VISUAL,
     tooltip = "Shows labels when price attempts to reverse out of the dry-up pocket.")
showFollowLabels = input.bool(true, "Show Follow-Through Labels", group = G_VISUAL,
     tooltip = "Shows labels when price reaches the follow-through rail.")
showInvalidLabels = input.bool(true, "Show Invalidation Labels", group = G_VISUAL,
     tooltip = "Shows labels when the active reversal attempt fails through the shelf.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for the active rail, failure shelf, and follow-through rail.")
rightTagDetail = input.string("Full", "Right Tag Detail", options = ["Compact", "Full"], group = G_VISUAL,
     tooltip = "Compact keeps right-side tags short. Full includes price values for more detailed chart review.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly according to the active dry-up reversal state.")
projectionBars = input.int(72, "Projection Bars", minval = 5, maxval = 300, group = G_VISUAL,
     tooltip = "Number of bars used for projected boxes, rails, and right-side tags.")
labelCooldownBars = input.int(14, "Label Cooldown Bars", minval = 1, maxval = 80, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 4, maxval = 20, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart. Five is the default publication density; active pocket and rail tags are managed separately.")
labelOffsetAtr = input.float(0.65, "Label Offset ATR", minval = 0.05, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset so labels remain readable above or below candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

alertDryUp = input.bool(true, "Alert: Dry-Up Pocket", group = G_ALERTS,
     tooltip = "Enables alerts when a new low-participation pocket is detected.")
alertReversal = input.bool(true, "Alert: Reversal Attempt", group = G_ALERTS,
     tooltip = "Enables alerts when price attempts to reverse out of the dry-up pocket.")
alertReady = input.bool(true, "Alert: Ready State", group = G_ALERTS,
     tooltip = "Enables alerts when the dry-up reversal context reaches READY conditions.")
alertFollowThrough = input.bool(true, "Alert: Follow-Through", group = G_ALERTS,
     tooltip = "Enables alerts when price reaches the follow-through rail.")
alertInvalidated = input.bool(true, "Alert: Invalidated", group = G_ALERTS,
     tooltip = "Enables alerts when the active dry-up reversal context is invalidated.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
darkText = color.rgb(17, 24, 39)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

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
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Light" ? color.rgb(248, 250, 252) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_left(string theme) =>
    theme == "Light" ? color.rgb(226, 232, 240) : theme == "Slate" ? color.rgb(51, 65, 85) : color.rgb(51, 65, 85)

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_price(float value) =>
    str.tostring(value, format.mintick)

f_tag_text(string labelText, float value) =>
    rightTagDetail == "Full" ? labelText + "  " + f_price(value) : labelText

// --------------------------------------------------
// Core calculations
// --------------------------------------------------
atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0.0 ? volume / volAvg : 1.0
barRange = math.max(high - low, syminfo.mintick)
avgRange = ta.sma(barRange, rangeLength)
rangeRatio = avgRange > 0.0 ? barRange / avgRange : 1.0
atrAvg = ta.sma(safeAtr, rangeLength)
volatilityRatio = atrAvg > 0.0 ? safeAtr / atrAvg : 1.0
bodyRatio = math.abs(close - open) / barRange

dryCandidate = rvol <= dryVolumeThreshold and rangeRatio <= maxRangeRatio
rawDryPocket = dryCandidate and not dryCandidate[1]

dryHighCandidate = ta.highest(high, dryWindowBars)
dryLowCandidate = ta.lowest(low, dryWindowBars)

var bool hasDryPocket = false
var int dryBar = na
var float dryHigh = na
var float dryLow = na
var float dryMid = na
var float dryRvol = na
var float dryRangeRatio = na
var float pocketAtr = na
var float reversalAtr = na
var int activeDir = 0
var int reversalBar = na
var bool followDone = false
var int lastDryLabelBar = na

existingDryAge = hasDryPocket and not na(dryBar) ? bar_index - dryBar : na
existingExpired = hasDryPocket and not na(existingDryAge) and existingDryAge > maxDryUpAge
newDryPocketEvent = barstate.isconfirmed and rawDryPocket and activeDir == 0 and (not hasDryPocket or existingExpired or existingDryAge >= pocketRefreshBars)

if newDryPocketEvent
    hasDryPocket := true
    dryBar := bar_index
    dryHigh := dryHighCandidate
    dryLow := dryLowCandidate
    dryMid := (dryHighCandidate + dryLowCandidate) * 0.5
    dryRvol := rvol
    dryRangeRatio := rangeRatio
    pocketAtr := safeAtr
    reversalAtr := na
    activeDir := 0
    reversalBar := na
    followDone := false

dryAge = hasDryPocket and not na(dryBar) ? bar_index - dryBar : na
expired = hasDryPocket and dryAge > maxDryUpAge
expiredEvent = barstate.isconfirmed and expired and not expired[1]

if expiredEvent
    activeDir := 0
    reversalBar := na
    followDone := false

referenceAtr = math.max(nz(pocketAtr, safeAtr), syminfo.mintick)
reversalBuffer = referenceAtr * reversalBufferAtr
failureShelf = referenceAtr * failureShelfAtr
dryHeight = math.max(dryHigh - dryLow, syminfo.mintick)

bullReversal = hasDryPocket and not expired and bar_index > nz(dryBar, bar_index) and close > dryHigh + reversalBuffer and close > open
bearReversal = hasDryPocket and not expired and bar_index > nz(dryBar, bar_index) and close < dryLow - reversalBuffer and close < open
reversalEvent = barstate.isconfirmed and (bullReversal or bearReversal) and activeDir == 0
bullReversalEvent = reversalEvent and bullReversal
bearReversalEvent = reversalEvent and bearReversal

if reversalEvent
    activeDir := bullReversal ? 1 : -1
    reversalBar := bar_index
    reversalAtr := safeAtr
    followDone := false

reversalRail = activeDir == 1 ? dryHigh : activeDir == -1 ? dryLow : close >= dryMid ? dryHigh : dryLow
failureRail = activeDir == 1 ? dryLow - failureShelf : activeDir == -1 ? dryHigh + failureShelf : close >= dryMid ? dryLow - failureShelf : dryHigh + failureShelf
followReferenceAtr = math.max(nz(reversalAtr, referenceAtr), syminfo.mintick)
followRail = activeDir == 1 ? reversalRail + followReferenceAtr * followThroughAtr : activeDir == -1 ? reversalRail - followReferenceAtr * followThroughAtr : na

// --------------------------------------------------
// Follow-Through Proof
// On a reversal attempt, a win is recorded when the follow-through rail is
// reached before price closes an equal distance back through the broken
// reversal rail (a symmetric continuation-versus-fade test).
// --------------------------------------------------
var bool proofPending = false
var int proofDir = 0
var float proofFollowRail = na
var float proofFailRail = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

if reversalEvent
    if proofPending
        proofTotal += 1
    proofPending := true
    proofDir := bullReversalEvent ? 1 : -1
    proofFollowRail := followRail
    proofFailRail := failureRail
    proofStartBar := bar_index

invalidated = activeDir == 1 and close < failureRail or activeDir == -1 and close > failureRail
followThrough = activeDir == 1 and high >= followRail or activeDir == -1 and low <= followRail
followEvent = barstate.isconfirmed and followThrough and not invalidated and not followDone and activeDir != 0 and bar_index > nz(reversalBar, bar_index)
invalidatedEvent = barstate.isconfirmed and invalidated

if followEvent
    followDone := true

if invalidatedEvent
    activeDir := 0
    reversalBar := na
    followDone := false

if proofPending and barstate.isconfirmed and bar_index > proofStartBar
    bool proofFav = proofDir == 1 ? high >= proofFollowRail : low <= proofFollowRail
    bool proofInval = proofDir == 1 ? close < proofFailRail : close > proofFailRail
    bool proofExp = bar_index - proofStartBar >= proofWindow
    if proofFav and proofInval
        proofTotal += 1
        proofPending := false
    else if proofFav
        proofTotal += 1
        proofWin += 1
        proofPending := false
    else if proofInval
        proofTotal += 1
        proofPending := false
    else if proofExp
        proofTotal += 1
        proofPending := false

float followRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na

volumeDryScore = f_clamp((dryVolumeThreshold - math.min(rvol, dryVolumeThreshold)) / math.max(dryVolumeThreshold, 0.01) * 26.0, 0.0, 26.0)
rangeDryScore = f_clamp((maxRangeRatio - math.min(rangeRatio, maxRangeRatio)) / math.max(maxRangeRatio, 0.01) * 22.0, 0.0, 22.0)
closeResponseScore = activeDir == 1 ? f_clamp((close - reversalRail) / math.max(safeAtr, syminfo.mintick) * 24.0, 0.0, 20.0) : activeDir == -1 ? f_clamp((reversalRail - close) / math.max(safeAtr, syminfo.mintick) * 24.0, 0.0, 20.0) : bodyRatio * 10.0
rejectionScore = activeDir == 1 ? f_clamp((close - low) / barRange * 14.0, 0.0, 14.0) : activeDir == -1 ? f_clamp((high - close) / barRange * 14.0, 0.0, 14.0) : f_clamp(bodyRatio * 8.0, 0.0, 8.0)
volatilityFit = f_clamp(18.0 - math.abs(volatilityRatio - 1.0) * 18.0, 0.0, 18.0)
reversalScore = f_score(20.0 + volumeDryScore + rangeDryScore + closeResponseScore + rejectionScore + volatilityFit)

readyState = activeDir != 0 and reversalScore >= minReadyScore and not invalidated and not expired
dryState = not hasDryPocket ? "No Pocket" : expired ? "Expired" : activeDir == 1 ? "Bull Reversal" : activeDir == -1 ? "Bear Reversal" : "Dry-Up Pocket"
participationText = "RVOL " + str.tostring(rvol, "#.##") + "  Range " + str.tostring(rangeRatio, "#.##")
failureRisk = activeDir == 0 ? "n/a" : str.tostring(math.abs(close - failureRail) / math.max(safeAtr, syminfo.mintick), "#.##") + " ATR"
actionState = not hasDryPocket ? "WAIT" : expired ? "EXPIRED" : invalidated ? "INVALIDATED" : readyState ? "READY" : activeDir != 0 ? "MONITOR" : "WAIT"
scoreText = hasDryPocket ? str.tostring(reversalScore) + "/100  " + f_grade(reversalScore) : "n/a"
followRateText = na(followRate) ? "Building" : str.tostring(math.round(followRate)) + "% (" + str.tostring(proofTotal) + ")"
stateColor = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : actionState == "MONITOR" ? accentColor : actionState == "EXPIRED" ? panelBorder : neutralColor
actionColor = actionState == "READY" ? stateColor : actionState == "MONITOR" ? accentColor : actionState == "INVALIDATED" ? bearColor : actionState == "EXPIRED" ? panelBorder : neutralColor
var string previousActionState = "WAIT"
readyEvent = barstate.isconfirmed and actionState == "READY" and previousActionState != "READY"
labelSize = f_size(labelSizeInput)
rightEdge = bar_index + projectionBars

// --------------------------------------------------
// Visual objects
// --------------------------------------------------
var box dryBox = na
var label pocketBadge = na
var line revLine = na
var line failLine = na
var line followLine = na

if hasDryPocket and showDryPocket and not expired
    if na(dryBox)
        dryBox := box.new(dryBar, dryHigh, rightEdge, dryLow, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 91), border_color = color.new(accentColor, 42), border_width = 1)
    else
        box.set_lefttop(dryBox, dryBar, dryHigh)
        box.set_rightbottom(dryBox, rightEdge, dryLow)
        box.set_bgcolor(dryBox, color.new(accentColor, 91))
        box.set_border_color(dryBox, color.new(accentColor, 42))
    if showPocketBadge
        int badgeX = int(math.round(dryBar + (rightEdge - dryBar) * pocketBadgeAnchor))
        if na(pocketBadge)
            pocketBadge := label.new(badgeX, dryMid, "DRY-UP POCKET\nRVOL " + str.tostring(dryRvol, "#.##") + " | RNG " + str.tostring(dryRangeRatio, "#.##"), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = labelSize, textalign = text.align_center)
        else
            label.set_x(pocketBadge, badgeX)
            label.set_y(pocketBadge, dryMid)
            label.set_text(pocketBadge, "DRY-UP POCKET\nRVOL " + str.tostring(dryRvol, "#.##") + " | RNG " + str.tostring(dryRangeRatio, "#.##"))
            label.set_color(pocketBadge, color.new(accentColor, 0))
            label.set_textcolor(pocketBadge, f_text_on(accentColor))
            label.set_size(pocketBadge, labelSize)
    else
        if not na(pocketBadge)
            label.delete(pocketBadge)
            pocketBadge := na
else
    if not na(dryBox)
        box.delete(dryBox)
        dryBox := na
    if not na(pocketBadge)
        label.delete(pocketBadge)
        pocketBadge := na

if hasDryPocket and showReversalRail and not expired
    if na(revLine)
        revLine := line.new(dryBar, reversalRail, rightEdge, reversalRail, xloc = xloc.bar_index, extend = extend.none, color = stateColor, width = 2)
    else
        line.set_xy1(revLine, dryBar, reversalRail)
        line.set_xy2(revLine, rightEdge, reversalRail)
        line.set_color(revLine, stateColor)
        line.set_width(revLine, 2)
else
    if not na(revLine)
        line.delete(revLine)
        revLine := na

if hasDryPocket and showFailureShelf and not expired
    if na(failLine)
        failLine := line.new(dryBar, failureRail, rightEdge, failureRail, xloc = xloc.bar_index, extend = extend.none, color = bearColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(failLine, dryBar, failureRail)
        line.set_xy2(failLine, rightEdge, failureRail)
        line.set_color(failLine, bearColor)
        line.set_style(failLine, line.style_dashed)
else
    if not na(failLine)
        line.delete(failLine)
        failLine := na

if activeDir != 0 and showFollowThroughRail and not expired
    if na(followLine)
        followLine := line.new(reversalBar, followRail, rightEdge, followRail, xloc = xloc.bar_index, extend = extend.none, color = neutralColor, width = 1)
    else
        line.set_xy1(followLine, reversalBar, followRail)
        line.set_xy2(followLine, rightEdge, followRail)
        line.set_color(followLine, neutralColor)
else
    if not na(followLine)
        line.delete(followLine)
        followLine := na

// --------------------------------------------------
// Labels
// --------------------------------------------------
labelOffset = safeAtr * labelOffsetAtr
var array<label> eventLabels = array.new<label>()

f_push_label(label newLabel) =>
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if showEventLabels and showDryLabels and newDryPocketEvent and (na(lastDryLabelBar) or bar_index - lastDryLabelBar >= labelCooldownBars)
    label newLabel = label.new(bar_index, high + labelOffset, "DRY-UP\nRVOL " + str.tostring(dryRvol, "#.##") + " | RNG " + str.tostring(dryRangeRatio, "#.##"), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
    f_push_label(newLabel)
    lastDryLabelBar := bar_index

if showEventLabels and showReversalLabels and reversalEvent
    bool bullEvent = bullReversal
    color revLabelColor = bullEvent ? bullColor : bearColor
    label newLabel = label.new(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? "BULL REVERSAL\nScore " + str.tostring(reversalScore) : "BEAR REVERSAL\nScore " + str.tostring(reversalScore), xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = revLabelColor, textcolor = f_text_on(revLabelColor), size = labelSize)
    f_push_label(newLabel)

if showEventLabels and showFollowLabels and followEvent
    bool bullEvent = activeDir == 1
    label newLabel = label.new(bar_index, bullEvent ? high + labelOffset : low - labelOffset, "FOLLOW-THROUGH\nRail reached", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_label(newLabel)

if showEventLabels and showInvalidLabels and invalidatedEvent
    label newLabel = label.new(bar_index, close >= dryMid ? high + labelOffset : low - labelOffset, "INVALIDATED\nFailure shelf", xloc = xloc.bar_index, yloc = yloc.price, style = close >= dryMid ? label.style_label_down : label.style_label_up, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
    f_push_label(newLabel)

// --------------------------------------------------
// Right-side tags
// --------------------------------------------------
var label revTag = na
var label failTag = na
var label followTag = na

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

if showRightTags and hasDryPocket and not expired
    revTag := f_update_tag(revTag, reversalRail, f_tag_text("Reversal Rail", reversalRail), stateColor)
    failTag := f_update_tag(failTag, failureRail, f_tag_text("Failure", failureRail), bearColor)
    if activeDir != 0 and showFollowThroughRail
        followTag := f_update_tag(followTag, followRail, f_tag_text("Follow-Through", followRail), neutralColor)
    else
        if not na(followTag)
            label.delete(followTag)
            followTag := na
else
    if not na(revTag)
        label.delete(revTag)
        revTag := na
    if not na(failTag)
        label.delete(failTag)
        failTag := na
    if not na(followTag)
        label.delete(followTag)
        followTag := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelPos = f_panel_position(panelPositionInput)
panelSize = f_size(panelFontSizeInput)
panelLeftFinal = f_panel_left(panelTheme)
panelBgFinal = f_panel_bg(panelTheme)
panelLabelFinal = f_panel_label(panelTheme)
panelValueFinal = f_panel_value(panelTheme)
followRateColor = na(followRate) ? panelValueFinal : followRate >= 55.0 ? bullColor : followRate >= 40.0 ? neutralColor : bearColor

var table panel = table.new(panelPos, 2, 7, border_width = 1, border_color = panelBorder)

if barstate.islast
    table.set_position(panel, panelPos)
    if showPanel
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Volume Dry-Up Reversal Planner", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(panel, 0, 1, "Dry-Up", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 1, dryState, text_color = panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 2, "Reversal Score", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 2, scoreText, text_color = f_text_on(stateColor), bgcolor = stateColor, text_size = panelSize)
        table.cell(panel, 0, 3, "Participation", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 3, participationText, text_color = panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 4, "Failure Risk", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 4, failureRisk, text_color = panelValueFinal, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 5, "Follow Rate", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 5, followRateText, text_color = followRateColor, bgcolor = panelBgFinal, text_size = panelSize)
        table.cell(panel, 0, 6, "Action", text_color = panelLabelFinal, bgcolor = panelLeftFinal, text_size = panelSize)
        table.cell(panel, 1, 6, actionState, text_color = f_text_on(actionColor), bgcolor = actionColor, text_size = panelSize)
    else
        table.clear(panel, 0, 0, 1, 6)

barStateColor = actionState == "READY" ? color.new(stateColor, 72) : actionState == "MONITOR" ? color.new(accentColor, 78) : actionState == "INVALIDATED" ? color.new(bearColor, 70) : na
barcolor(showBarColors ? barStateColor : na)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertDryUp and newDryPocketEvent, "AG Pro VDR | DRY-UP POCKET", "AG Pro VDR: A confirmed low-participation dry-up pocket has been detected.")
alertcondition(alertReversal and bullReversalEvent, "AG Pro VDR | BULL REVERSAL ATTEMPT", "AG Pro VDR: Price is attempting a bullish reversal out of the dry-up pocket.")
alertcondition(alertReversal and bearReversalEvent, "AG Pro VDR | BEAR REVERSAL ATTEMPT", "AG Pro VDR: Price is attempting a bearish reversal out of the dry-up pocket.")
alertcondition(alertReady and readyEvent and activeDir == 1, "AG Pro VDR | BULL READY", "AG Pro VDR: Bullish dry-up reversal context entered READY on a confirmed close.")
alertcondition(alertReady and readyEvent and activeDir == -1, "AG Pro VDR | BEAR READY", "AG Pro VDR: Bearish dry-up reversal context entered READY on a confirmed close.")
alertcondition(alertFollowThrough and followEvent, "AG Pro VDR | FOLLOW-THROUGH", "AG Pro VDR: Price reached the dry-up reversal follow-through rail.")
alertcondition(alertInvalidated and invalidatedEvent, "AG Pro VDR | INVALIDATED", "AG Pro VDR: The active dry-up reversal context was invalidated on a confirmed close.")

if barstate.isconfirmed
    previousActionState := actionState
````
