# False Break Trap Planner [AGPro Series]

- url: https://www.tradingview.com/script/pZ00o3kJ-False-Break-Trap-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;2af8a156995f4d98bec93497dfa19b6d
- version: 4.0

## Description

False Break Trap Planner [AGPro Series]

🧠 Core Idea

Is a breakout still holding, or is it turning into a false-break trap that deserves caution?


📌 Overview / What it does

False Break Trap Planner is a chart-first breakout failure planner built to evaluate range-edge break attempts after price moves beyond a recent high or low boundary.

Instead of only marking that a breakout happened, the script studies whether the move is holding beyond the edge, being reclaimed back into the range, or becoming a confirmed trap-risk context. It produces a 0-100 Trap Risk score, a reclaim state, a break-quality reading, a failure-room estimate, false-break zones, reclaim rails, and target-back guides.

This script does not predict price direction, automate execution, or claim that a failed break must reverse. It organizes the anatomy of a potential false break so traders can review the setup with cleaner context.


🎯 Purpose & Design Philosophy

This script was built for traders who need a practical decision layer around breakout failure, not another generic signal marker.

The gap it fills is the space between a clean breakout tool and a liquidity sweep tool. Many chart tools mark a level break, a wick, or a reclaim. This planner asks what the trader should review next: is the break holding, is reclaim pressure developing, is the failure fast enough to matter, and is there room back inside the range?

The design mindset is structured caution. The script helps users slow down around breakout traps, separate active risk from confirmed failure, and keep risk / target / invalidation context visible.


⚡ Why This Script Is Different

Most tools focus on breakout confirmation, sweep labels, or generic failed-break signals.

This script does NOT try to become a stop-hunt map, liquidity sweep engine, support/resistance zone scanner, or broad breakout system.

Instead, it focuses on one specific workflow: a prior range edge is broken, the break either holds or gets reclaimed, and the planner scores whether that behavior deserves trap-risk review.


⚙️ Methodology

1. Context Detection
The script maps a recent range high and range low from previous bars, then watches for an ATR-normalized break beyond either edge.

2. Reference Mapping
When a break attempt appears, the planner freezes the range edge, opposite edge, midpoint, and false-break extreme so the event can be evaluated consistently.

3. Reaction Evaluation
The model scores breakout failure speed, reclaim strength, wick size, volume spike, and whether price closes back inside the range.

4. Visual Output
The script displays a false-break box, reclaim or fail rail, target-back line, trap confirmation labels, reclaim-watch labels, and a premium AG Pro panel.


🗺️ How to Read the Chart

Zones = the active false-break box between the broken range edge and the failed extension.

Labels = compact state markers such as Upper Break Watch, Lower Break Watch, Reclaim Watch, Upper Trap, Lower Trap, or Break Accepted.

Colors = teal for lower-break trap recovery context, pink for upper-break trap risk, yellow for watch states, indigo for accepted/holding context, and red for confirmed trap-risk pressure.

Panel = a compact decision panel showing Trap Risk, Reclaim State, Break Quality, Failure Room, and Action.


🚦 Signals & States

• Upper Break Watch → price has moved beyond the upper range edge and the break is under review.

• Lower Break Watch → price has moved beyond the lower range edge and the break is under review.

• Reclaim Watch → price is testing back toward or inside the broken edge, but confirmation is not complete.

• Trap Confirmed → the break has closed back inside the range with enough trap-risk score.

• Break Holding → the break is still outside the range and has not reclaimed.

• Break Accepted → the break has held beyond the acceptance window and should not be treated as an active trap by default.


🔔 Alerts Logic

Alerts trigger when the planner detects confirmed upper or lower trap context, upper or lower reclaim-watch context, or break acceptance.

Each alert is an attention marker. It highlights a state transition that may deserve review. It is not a trade instruction and should not be treated as an automated entry or exit signal.


🧩 Confluence Logic

The strongest trap-risk context appears when several factors align:

• Fast failure after the break
• Close back inside the prior range
• Strong wick rejection
• Volume spike during the failed extension
• Clean room back toward the range midpoint

When these align, the panel score rises and the state becomes easier to interpret.


📊 When to Use

• Breakout and breakdown attempts around a recent range
• Markets where false breaks and failed continuations are common
• Intraday or swing charts where range edges are visually relevant
• Review workflows that need caution before chasing a break
• Breakout traders who want a structured invalidation and failure-room layer


⚠️ When NOT to Use

• Extremely low-liquidity instruments
• Very noisy micro timeframes with unreliable candles
• Markets with poor or synthetic volume data
• News-driven volatility where single-bar extremes distort ATR and volume
• Charts where the selected lookback does not represent a meaningful range


🎛️ Key Inputs

• Range Edge Lookback → controls the prior range used for break attempts.

• Minimum Break ATR → defines how far price must move beyond the edge before the planner starts tracking.

• Fast Reclaim Window → controls how many bars can pass before a reclaim becomes less meaningful.

• Trap Confirmed Score → minimum 0-100 score required for a confirmed trap label.

• Break Acceptance Bars → defines when a break should be treated as holding rather than still failing.

• Visual settings → control boxes, rails, target-back lines, label density, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The panel is designed as a clean AG Pro planning cockpit. The first row uses the standard merged blue AGPro header row, followed by five decision rows.

The chart visuals are intentionally focused: one active false-break box, a reclaim rail, a soft fail rail, a target-back line, and controlled labels. The goal is premium readability without turning the chart into a generic level map.


🧪 Practical Usage Workflow

1. Read the panel and check the current Reclaim State.
2. Review the false-break box and identify which edge was broken.
3. Check whether price is holding beyond the edge or closing back inside.
4. Compare Trap Risk with Break Quality.
5. Use the target-back line and failure-room reading as context, not as a forecast.


🔍 Interpretation Guidelines

Think in states, not predictions.

A high Trap Risk score means the attempted break has characteristics often associated with failed continuation. It does not mean the next move is guaranteed.

A strong Break Quality score means the break is still showing participation and close-through behavior. In that context, early fading can be premature.

The cleanest reading appears when Trap Risk is high, Break Quality is weak, and price has closed back inside the range.


🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not auto trading
• Not guaranteed signals
• Not a stop-hunt map
• Not a liquidity sweep scanner
• Not a support/resistance zone system
• Not a replacement for risk planning


⚠️ Limitations & Transparency

The active range depends on the selected lookback. A different lookback can produce different edges.

ATR and volume conditions can change quickly during high-volatility periods, which may affect scoring.

Breakout behavior differs across symbols, sessions, and timeframes. A trap-like structure on one market may not behave the same way on another.

The script is rule-based and does not know external news, order flow, or hidden liquidity.


🧠 Market Context Notes

False breaks often become more relevant near visible range edges, crowded breakout levels, and late-stage expansion attempts.

The planner is most useful when combined with broader market context, liquidity conditions, volatility regime, and the trader's own risk rules.


🧾 Use Case Examples

When price breaks above a recent range but closes back inside with a long upper wick and strong volume, the planner may mark Upper Trap context.

When price breaks below a range but quickly reclaims the lower edge, the planner may shift into Lower Trap context.

When price breaks and keeps closing beyond the edge after the acceptance window, the planner may mark Break Accepted instead of forcing a trap interpretation.


🧱 System Philosophy

False Break Trap Planner follows the AGPro Series decision-engine direction: score the setup, identify the state, show the risk reference, show the target-back context, and make the next review step clear.

The script is built to help traders make a structured chart-reading decision, not to add another isolated signal.


🔐 Non-Promise Statement

No script can confirm certainty.

No trap score guarantees reversal, continuation, or profitability.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk controls, and market interpretation.

This script is for educational and analytical use only and does not provide financial advice or guaranteed trading outcomes.


📚 Educational Note

Use the planner as a structured review layer around breakout failure behavior. The best value comes from comparing state, score, failure room, and broader market context together.

## Source Code

````pine
// -------------------------------------------------
// False Break Trap Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// False Break Trap Planner is a chart-first breakout failure decision engine.
// It tracks range-edge break attempts, measures whether the move is holding or
// being reclaimed, scores trap risk from 0-100, maps practical failure room,
// reclaim rails, target-back guides and next-action states, and adds a
// persistent midpoint-reversion proof layer for traders who need structured caution
// around false breaks, fakeouts and stop hunts instead of another generic
// signal marker. This is an analytical visualization tool, not a prediction
// engine, not automation, and not financial advice.
// -------------------------------------------------

//@version=6
indicator("False Break Trap Planner [AGPro Series]",
     shorttitle = "AG FBT",
     overlay = true,
     max_labels_count = 80,
     max_boxes_count = 4,
     max_lines_count = 12)

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
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttRange = "Lookback used to define the active range edge before a breakout attempt. The current bar is tested against the previous range so the planner can separate a real break from a fast reclaim."
ttAtr = "ATR length used for break depth, reclaim strength, label spacing, rails, target-back distance, and trap-zone thickness."
ttVol = "Volume baseline used to evaluate whether the break attempt had participation. On markets with unreliable volume, this component becomes neutral."
ttSensitivity = "Controls how quickly the planner reacts to edge breaks. Conservative requires a cleaner extension; Aggressive reacts to smaller edge violations."
ttConfirm = "Close Confirmed updates the planner on bar close. Live Updating previews active geometry, scores, and watch context intrabar; terminal outcomes, historical labels, alerts, and proof samples still commit only on confirmed closes."
ttMinBreak = "Minimum ATR-normalized move beyond the range edge required to register a break attempt."
ttConfirmBars = "Bars over which the failure-speed contribution decays. Trap confirmation can remain eligible until the active break decision resolves."
ttReclaim = "ATR-normalized close back inside the range that counts as strong reclaim pressure."
ttTrapScore = "Minimum 0-100 trap-risk score required for the planner to mark a confirmed trap context."
ttWatchScore = "Minimum 0-100 trap-risk score required for a reclaim-watch context before confirmation is complete."
ttVolumeSpike = "Relative volume level treated as meaningful participation during the failed break attempt."
ttBreakAccept = "If price keeps closing beyond the broken edge after this many bars, the planner treats the break as accepted instead of a trap."
ttProofWindow = "Bars used to resolve each midpoint-reversion proof sample after a Trap Confirmed event."
ttProofReversion = "How far price must revert from the broken edge toward the range midpoint to count in the proof, measured as a percentage of the edge-to-mid distance. A win is recorded when price reaches that target before crossing the stored extreme buffer."
ttBox = "Shows the active false-break box with a separate centered status badge. The badge is kept on a filled background for contrast."
ttRails = "Shows the frozen Broken Edge rail plus an Extreme Buffer rail beyond the tracked false-break extension."
ttTarget = "Shows the target-back line at the range midpoint. This is a planning reference, not a forecast or trade instruction."
ttProjection = "Controls how far boxes, rails, and target-back guides extend to the right."
ttResolvedPlan = "Bars a terminal Trap Confirmed or Break Accepted plan remains visible before it is archived. Accepted plans also archive immediately after a confirmed close back through the broken edge."
ttGuideLabels = "Shows compact price tags for the Broken Edge, Extreme Buffer, and Range Mid guides. Every visible planning line remains identifiable without relying on color alone."
ttZoneOpacity = "Transparency for the active false-break box. Higher values make the box lighter."
ttLabels = "Shows compact Break Watch, Reclaim Watch, Trap Confirmed, and Break Accepted labels with controlled spacing."
ttContextLabels = "Adds sparse holding-context labels during an unresolved break plan so the chart remains informative without becoming crowded."
ttCooldown = "Minimum spacing between lower-priority new-break labels. Trap, reclaim-watch, and acceptance transitions are never suppressed by this setting."
ttContextSpacing = "Minimum bars between sparse holding-context labels during an unresolved break attempt."
ttMaxLabels = "Maximum number of historical event and context labels retained. Older labels are deleted first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels away from candles."
ttLabelMode = "Compact labels keep the publication chart clean. Detailed labels add score and state text directly to chart labels."
ttLabelSize = "Controls all chart labels and the centered false-break badge. Normal is the recommended publication default."
ttPanel = "Shows or hides the AG Pro planning panel. The default is visible for public-release readability."
ttPanelLocation = "Moves the AG Pro planning panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
ttPanelFont = "Controls panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Trap Planner Engine"
rangeLookback = input.int(34, "Range Edge Lookback", minval = 10, maxval = 220, group = groupEngine, tooltip = ttRange)
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVol)
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

groupScoring = "Trap Risk Model"
minBreakAtrInput = input.float(0.16, "Minimum Break ATR", minval = 0.03, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttMinBreak)
reclaimWindowBars = input.int(4, "Fast Reclaim Window", minval = 1, maxval = 20, group = groupScoring, tooltip = ttConfirmBars)
strongReclaimAtr = input.float(0.35, "Strong Reclaim ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttReclaim)
minTrapScore = input.int(70, "Trap Confirmed Score", minval = 40, maxval = 95, group = groupScoring, tooltip = ttTrapScore)
watchScore = input.int(55, "Reclaim Watch Score", minval = 25, maxval = 90, group = groupScoring, tooltip = ttWatchScore)
volumeSpikeLevel = input.float(1.35, "Volume Spike Level", minval = 0.60, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttVolumeSpike)
acceptanceBars = input.int(8, "Break Acceptance Bars", minval = 2, maxval = 40, group = groupScoring, tooltip = ttBreakAccept)

groupProof = "Midpoint Reversion Proof"
proofWindow = input.int(20, "Proof Window Bars", minval = 4, maxval = 120, group = groupProof, tooltip = ttProofWindow)
proofReversionPct = input.float(50.0, "Proof Reversion To Mid %", minval = 20.0, maxval = 90.0, step = 5.0, group = groupProof, tooltip = ttProofReversion)

groupVisual = "Chart Visuals"
showFalseBreakBox = input.bool(true, "Show False-Break Box", group = groupVisual, tooltip = ttBox)
showReclaimRails = input.bool(true, "Show Edge / Extreme Rails", group = groupVisual, tooltip = ttRails)
showTargetBackLine = input.bool(true, "Show Target-Back Line", group = groupVisual, tooltip = ttTarget)
forwardBars = input.int(34, "Forward Render Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttProjection)
resolvedPlanBars = input.int(34, "Resolved Plan Display Bars", minval = 5, maxval = 160, group = groupVisual, tooltip = ttResolvedPlan)
showGuideLabels = input.bool(true, "Show Guide Price Labels", group = groupVisual, tooltip = ttGuideLabels)
zoneTransparency = input.int(88, "False-Break Box Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(48, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 4, maxval = 40, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.20, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupLabels, tooltip = ttLabelMode)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high(float value, float weak, float strong) =>
    span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low(float value, float good, float bad) =>
    span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

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

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_score_grade(float score) =>
    string result = "E"
    if score >= 85.0
        result := "A+"
    else if score >= 76.0
        result := "A"
    else if score >= 66.0
        result := "B"
    else if score >= 55.0
        result := "C"
    else if score >= 42.0
        result := "D"
    result

f_score_color(float score) =>
    color result = bullColor
    if score >= minTrapScore
        result := dangerColor
    else if score >= watchScore
        result := neutralColor
    result

f_risk_band(float score) =>
    string result = "Low"
    if score >= minTrapScore
        result := "High"
    else if score >= watchScore
        result := "Watch"
    result

f_state_color(string stateText, int side) =>
    switch stateText
        "Trap Confirmed" => side == 1 ? bearColor : bullColor
        "Reclaim Watch" => neutralColor
        "Break Holding" => accentColor
        "Break Accepted" => side == 1 ? bullColor : bearColor
        "Range Monitor" => panelLabelCol
        => panelValueCol

f_workflow(string stateText, int side) =>
    sideWord = side == 1 ? "Upper" : side == -1 ? "Lower" : "Range"
    switch stateText
        "Trap Confirmed" => "Review " + sideWord + " Trap"
        "Reclaim Watch" => "Track " + sideWord + " Reclaim"
        "Break Holding" => "Wait for Acceptance"
        "Break Accepted" => "Respect " + sideWord + " Break"
        => "Monitor Edges"

f_panel_bg(string themeText) =>
    themeText == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string themeText) =>
    themeText == "Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string themeText) =>
    themeText == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeText) =>
    themeText == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeText, int row) =>
    evenRow = row % 2 == 0
    themeText == "Light" ? (evenRow ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_row(table target, int row, string labelText, string valueText, color valueColor, string themeText, string sizeText, color valueBg) =>
    rowBg = f_row_bg(themeText, row)
    table.cell(target, 0, row, labelText, text_color = f_panel_label(themeText), bgcolor = rowBg, text_size = f_text_size(sizeText), text_halign = text.align_left)
    table.cell(target, 1, row, valueText, text_color = valueColor, bgcolor = valueBg, text_size = f_text_size(sizeText), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
visualUpdateReady = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
atrRaw = ta.atr(atrLength)
atr = math.max(nz(atrRaw, high - low), syminfo.mintick)
minBreakAtr = minBreakAtrInput
if sensitivity == "Conservative"
    minBreakAtr := minBreakAtrInput * 1.35
else if sensitivity == "Aggressive"
    minBreakAtr := minBreakAtrInput * 0.75

rangeHighRaw = ta.highest(high[1], rangeLookback)
rangeLowRaw = ta.lowest(low[1], rangeLookback)
validRange = not na(rangeHighRaw) and not na(rangeLowRaw) and rangeHighRaw > rangeLowRaw
rangeHigh = validRange ? rangeHighRaw : high
rangeLow = validRange ? rangeLowRaw : low
rangeMid = (rangeHigh + rangeLow) * 0.5
breakBuffer = atr * minBreakAtr

volumeBase = nz(ta.sma(volume, volumeLength), volume)
rvol = volumeBase > 0.0 ? volume / volumeBase : 1.0
barRange = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
bodyEfficiency = math.abs(close - open) / barRange

upperBreakAttempt = validRange and high > rangeHigh + breakBuffer
lowerBreakAttempt = validRange and low < rangeLow - breakBuffer
int candidateSide = 0
if upperBreakAttempt and lowerBreakAttempt
    candidateSide := (high - rangeHigh) >= (rangeLow - low) ? 1 : -1
else if upperBreakAttempt
    candidateSide := 1
else if lowerBreakAttempt
    candidateSide := -1

// -------------------------------------------------
// Break event memory and terminal lifecycle
// -------------------------------------------------
var int activeSide = 0
var int breakBar = na
var float eventHigh = na
var float eventLow = na
var float eventMid = na
var float breakExtreme = na
var float eventAtr = na
var int eventId = 0
var int eventOutcome = 0  // 0 = watching, 1 = trap confirmed, 2 = break accepted
var int eventResolvedBar = na
var int beyondCloseStreak = 0
var float eventBreakQuality = na
var float resolvedTrapRisk = na
var float resolvedBreakQuality = na

priorEventExists = activeSide != 0 and not na(breakBar) and not na(eventHigh) and not na(eventLow)
priorEventAge = priorEventExists ? bar_index - breakBar : 0
priorCloseInside = priorEventExists and (activeSide == 1 ? close < eventHigh : close > eventLow)
acceptedReentered = priorEventExists and eventOutcome == 2 and priorCloseInside
terminalExpired = priorEventExists and eventOutcome != 0 and not na(eventResolvedBar) and bar_index - eventResolvedBar > resolvedPlanBars
pendingExpiredInside = priorEventExists and eventOutcome == 0 and priorEventAge > acceptanceBars and priorCloseInside
pendingHardExpired = priorEventExists and eventOutcome == 0 and priorEventAge > acceptanceBars + resolvedPlanBars

if visualUpdateReady and (acceptedReentered or terminalExpired or pendingExpiredInside or pendingHardExpired)
    activeSide := 0
    breakBar := na
    eventHigh := na
    eventLow := na
    eventMid := na
    breakExtreme := na
    eventAtr := na
    eventOutcome := 0
    eventResolvedBar := na
    beyondCloseStreak := 0
    eventBreakQuality := na
    resolvedTrapRisk := na
    resolvedBreakQuality := na

newBreakAttempt = visualUpdateReady and candidateSide != 0
bool newBreakEvent = false
if newBreakAttempt
    trapRebreak = eventOutcome == 1 and candidateSide == activeSide and not na(eventResolvedBar) and bar_index > eventResolvedBar
    acceptedNewEdge = eventOutcome == 2 and candidateSide == activeSide and not na(eventResolvedBar) and bar_index > eventResolvedBar and (activeSide == 1 ? high > breakExtreme + breakBuffer : low < breakExtreme - breakBuffer)
    replaceEvent = activeSide == 0 or candidateSide != activeSide or na(breakBar) or trapRebreak or acceptedNewEdge or (eventOutcome == 0 and bar_index - breakBar > acceptanceBars)
    if replaceEvent
        eventId += 1
        activeSide := candidateSide
        breakBar := bar_index
        eventHigh := rangeHigh
        eventLow := rangeLow
        eventMid := rangeMid
        breakExtreme := candidateSide == 1 ? high : low
        eventAtr := atr
        eventOutcome := 0
        eventResolvedBar := na
        beyondCloseStreak := 0
        eventBreakQuality := na
        resolvedTrapRisk := na
        resolvedBreakQuality := na
        newBreakEvent := true
    else if eventOutcome == 0
        breakExtreme := activeSide == 1 ? math.max(nz(breakExtreme, high), high) : math.min(nz(breakExtreme, low), low)

if eventOutcome == 0 and activeSide == 1 and not na(breakExtreme)
    breakExtreme := math.max(breakExtreme, high)
else if eventOutcome == 0 and activeSide == -1 and not na(breakExtreme)
    breakExtreme := math.min(breakExtreme, low)

hasEvent = activeSide != 0 and not na(breakBar) and not na(eventHigh) and not na(eventLow) and not na(breakExtreme)
eventAge = hasEvent ? bar_index - breakBar : 0
eventFresh = hasEvent and eventOutcome == 0 and eventAge <= acceptanceBars

activeEdge = activeSide == 1 ? eventHigh : eventLow
targetBackLine = eventMid
penetrationAtr = hasEvent ? (activeSide == 1 ? math.max(breakExtreme - eventHigh, 0.0) / atr : math.max(eventLow - breakExtreme, 0.0) / atr) : 0.0
closeBeyondAtr = hasEvent ? (activeSide == 1 ? math.max(close - eventHigh, 0.0) / atr : math.max(eventLow - close, 0.0) / atr) : 0.0
reclaimDistanceAtr = hasEvent ? (activeSide == 1 ? math.max(eventHigh - close, 0.0) / atr : math.max(close - eventLow, 0.0) / atr) : 0.0
failureRoomAtr = hasEvent ? (activeSide == 1 ? math.max(close - targetBackLine, 0.0) / atr : math.max(targetBackLine - close, 0.0) / atr) : na
closeBackInside = hasEvent and (activeSide == 1 ? close < eventHigh : close > eventLow)
wickBackInside = hasEvent and (activeSide == 1 ? low <= eventHigh : high >= eventLow)
breakStillHolding = hasEvent and not closeBackInside and closeBeyondAtr > 0.0

if visualUpdateReady and hasEvent and eventOutcome == 0
    beyondCloseStreak := breakStillHolding ? beyondCloseStreak + 1 : 0

breakCloseScore = f_norm_high(closeBeyondAtr, 0.03, minBreakAtr * 2.2)
breakDepthScore = f_norm_high(penetrationAtr, minBreakAtr * 0.70, minBreakAtr * 3.0)
breakBodyScore = bodyEfficiency * 100.0
breakVolumeScore = f_norm_high(rvol, 0.85, volumeSpikeLevel * 1.25)
breakQuality = hasEvent ? f_clamp(breakCloseScore * 0.42 + breakDepthScore * 0.18 + breakBodyScore * 0.20 + breakVolumeScore * 0.20, 0.0, 100.0) : 0.0
if newBreakEvent
    eventBreakQuality := breakQuality
initialBreakQuality = nz(eventBreakQuality, breakQuality)

failureSpeedScore = hasEvent ? f_norm_low(eventAge, 0.0, reclaimWindowBars) : 0.0
reclaimScore = f_norm_high(reclaimDistanceAtr, 0.0, strongReclaimAtr)
activeWickRatio = activeSide == 1 ? upperWick / barRange : lowerWick / barRange
wickScore = f_clamp(activeWickRatio * 140.0, 0.0, 100.0)
volumeSpikeScore = f_norm_high(rvol, 0.90, volumeSpikeLevel)
closeInsideScore = closeBackInside ? 100.0 : wickBackInside ? 55.0 : 0.0
trapRiskRaw = hasEvent ? failureSpeedScore * 0.22 + reclaimScore * 0.25 + wickScore * 0.18 + volumeSpikeScore * 0.15 + closeInsideScore * 0.20 : 0.0
trapRisk = breakStillHolding and breakQuality > 72.0 ? trapRiskRaw * 0.65 : trapRiskRaw
trapRisk := f_clamp(trapRisk, 0.0, 100.0)

trapCandidate = hasEvent and eventOutcome == 0 and closeBackInside and trapRisk >= minTrapScore and eventAge <= acceptanceBars
reclaimWatchCandidate = hasEvent and eventOutcome == 0 and eventFresh and not trapCandidate and (wickBackInside or reclaimDistanceAtr > 0.0 or trapRisk >= watchScore)
acceptedCandidate = hasEvent and eventOutcome == 0 and beyondCloseStreak >= acceptanceBars and breakStillHolding and initialBreakQuality >= 48.0

trapConfirmEvent = barstate.isconfirmed and trapCandidate
breakAcceptedEvent = barstate.isconfirmed and acceptedCandidate
if trapConfirmEvent
    eventOutcome := 1
    eventResolvedBar := bar_index
    resolvedTrapRisk := trapRisk
    resolvedBreakQuality := initialBreakQuality
else if breakAcceptedEvent
    eventOutcome := 2
    eventResolvedBar := bar_index
    resolvedTrapRisk := trapRisk
    resolvedBreakQuality := initialBreakQuality

trapConfirmed = hasEvent and eventOutcome == 1
breakAccepted = hasEvent and eventOutcome == 2
reclaimWatch = hasEvent and eventOutcome == 0 and reclaimWatchCandidate
breakHolding = hasEvent and eventOutcome == 0 and breakStillHolding and not reclaimWatch
watchTransition = barstate.isconfirmed and reclaimWatch and (reclaimWatch[1] != true or eventId != eventId[1])
upperTrapAlert = trapConfirmEvent and activeSide == 1
lowerTrapAlert = trapConfirmEvent and activeSide == -1
upperWatchAlert = watchTransition and activeSide == 1
lowerWatchAlert = watchTransition and activeSide == -1
breakAcceptedAlert = breakAcceptedEvent

// -------------------------------------------------
// Midpoint-reversion proof
// Each confirmed terminal trap becomes one unique sample. Samples may overlap.
// A sample wins when price reaches its range-scaled midpoint target before the
// stored extreme buffer. Same-bar target/invalidation ambiguity counts as a
// non-win, and unresolved samples time out after the selected proof window.
// -------------------------------------------------
var array<int> proofDirs = array.new<int>()
var array<float> proofTargets = array.new<float>()
var array<float> proofInvalids = array.new<float>()
var array<int> proofStartBars = array.new<int>()
var int proofTotal = 0
var int proofWin = 0

if trapConfirmEvent and barstate.isconfirmed and hasEvent
    proofTarget = activeSide == 1 ? eventHigh - (proofReversionPct / 100.0) * (eventHigh - targetBackLine) : eventLow + (proofReversionPct / 100.0) * (targetBackLine - eventLow)
    proofInvalid = activeSide == 1 ? breakExtreme + nz(eventAtr, atr) * 0.18 : breakExtreme - nz(eventAtr, atr) * 0.18
    array.push(proofDirs, activeSide)
    array.push(proofTargets, proofTarget)
    array.push(proofInvalids, proofInvalid)
    array.push(proofStartBars, bar_index)

if barstate.isconfirmed
    pendingAtOpen = array.size(proofDirs)
    if pendingAtOpen > 0
        for offset = 0 to pendingAtOpen - 1
            i = pendingAtOpen - 1 - offset
            proofDir = array.get(proofDirs, i)
            proofTarget = array.get(proofTargets, i)
            proofInvalid = array.get(proofInvalids, i)
            proofStartBar = array.get(proofStartBars, i)
            if bar_index > proofStartBar
                proofFav = proofDir == 1 ? low <= proofTarget : high >= proofTarget
                proofInvHit = proofDir == 1 ? high >= proofInvalid : low <= proofInvalid
                proofExp = bar_index - proofStartBar >= proofWindow
                proofResolved = proofFav or proofInvHit or proofExp
                if proofResolved
                    proofTotal += 1
                    if proofFav and not proofInvHit
                        proofWin += 1
                    array.remove(proofDirs, i)
                    array.remove(proofTargets, i)
                    array.remove(proofInvalids, i)
                    array.remove(proofStartBars, i)

reversionRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na

reclaimState = "Range Monitor"
if trapConfirmed
    reclaimState := "Trap Confirmed"
else if breakAccepted
    reclaimState := "Break Accepted"
else if reclaimWatch
    reclaimState := "Reclaim Watch"
else if breakHolding
    reclaimState := "Break Holding"

planActive = hasEvent
displayTrapRisk = eventOutcome == 0 ? trapRisk : nz(resolvedTrapRisk, trapRisk)
displayBreakQuality = eventOutcome == 0 ? initialBreakQuality : nz(resolvedBreakQuality, initialBreakQuality)
sideWord = activeSide == 1 ? "Upper" : activeSide == -1 ? "Lower" : "Range"
stateDisplay = planActive ? sideWord + " " + reclaimState : "No Active Break"
breakQualityText = planActive ? str.tostring(math.round(displayBreakQuality)) + "/100 " + f_score_grade(displayBreakQuality) : "-"
trapRiskText = planActive ? str.tostring(math.round(displayTrapRisk)) + "/100 " + f_risk_band(displayTrapRisk) : "-"
midpointGapText = planActive ? f_fmt(failureRoomAtr) + " ATR" : "-"
barsActiveText = planActive ? str.tostring(eventAge) + (eventAge == 1 ? " bar" : " bars") : "-"
keyLevelText = planActive ? "Edge " + f_fmt_price(activeEdge) : "-"
pendingProofs = array.size(proofDirs)
reversionRateText = na(reversionRate) ? (pendingProofs > 0 ? "Building (" + str.tostring(pendingProofs) + ")" : "Building") : str.tostring(math.round(reversionRate)) + "% (" + str.tostring(proofTotal) + ")"
reversionRateColor = na(reversionRate) ? f_panel_value(panelTheme) : reversionRate >= 55.0 ? bullColor : reversionRate >= 40.0 ? neutralColor : bearColor

// -------------------------------------------------
// Visual objects
// -------------------------------------------------
stateColor = f_state_color(reclaimState, activeSide)
eventColor = planActive ? stateColor : panelLabelCol
boxColor = color.new(eventColor, zoneTransparency)
railColor = eventColor

var box trapBox = na
var label trapBadge = na
var line reclaimRail = na
var line failRail = na
var line targetLine = na
var label reclaimTag = na
var label failTag = na
var label targetTag = na

if planActive and showFalseBreakBox
    rightX = bar_index + forwardBars
    leftX = breakBar
    boxTop = activeSide == 1 ? math.max(breakExtreme, eventHigh) : eventLow
    boxBottom = activeSide == 1 ? eventHigh : math.min(breakExtreme, eventLow)
    centerX = int(math.round((leftX + rightX) * 0.5))
    centerY = (boxTop + boxBottom) * 0.5
    boxMetric = reclaimState == "Trap Confirmed" or reclaimState == "Reclaim Watch" ? "R " + str.tostring(math.round(displayTrapRisk)) + "/100" : "Q " + str.tostring(math.round(displayBreakQuality)) + "/100"
    boxText = sideWord + " False-Break Plan\n" + reclaimState + " | " + boxMetric
    if na(trapBox)
        trapBox := box.new(left = leftX, top = boxTop, right = rightX, bottom = boxBottom, xloc = xloc.bar_index, bgcolor = boxColor, border_color = color.new(eventColor, 12), border_width = 1)
    else
        box.set_lefttop(trapBox, leftX, boxTop)
        box.set_rightbottom(trapBox, rightX, boxBottom)
        box.set_bgcolor(trapBox, boxColor)
        box.set_border_color(trapBox, color.new(eventColor, 12))
    if na(trapBadge)
        trapBadge := label.new(centerX, centerY, boxText, xloc = xloc.bar_index, style = label.style_label_center, textcolor = f_text_on(eventColor), color = eventColor, size = f_text_size(labelFontSize), textalign = text.align_center, tooltip = "Centered false-break decision badge. It shows the terminal or active state and its relevant score without implying a trade instruction.")
    else
        label.set_x(trapBadge, centerX)
        label.set_y(trapBadge, centerY)
        label.set_text(trapBadge, boxText)
        label.set_textcolor(trapBadge, f_text_on(eventColor))
        label.set_color(trapBadge, eventColor)
        label.set_size(trapBadge, f_text_size(labelFontSize))
else
    if not na(trapBox)
        box.delete(trapBox)
        trapBox := na
    if not na(trapBadge)
        label.delete(trapBadge)
        trapBadge := na

if planActive and showReclaimRails
    rightX = bar_index + forwardBars
    extremeBuffer = activeSide == 1 ? breakExtreme + nz(eventAtr, atr) * 0.18 : breakExtreme - nz(eventAtr, atr) * 0.18
    if na(reclaimRail)
        reclaimRail := line.new(breakBar, activeEdge, rightX, activeEdge, xloc = xloc.bar_index, color = railColor, style = line.style_solid, width = 2)
    else
        line.set_xy1(reclaimRail, breakBar, activeEdge)
        line.set_xy2(reclaimRail, rightX, activeEdge)
        line.set_color(reclaimRail, railColor)
    if na(failRail)
        failRail := line.new(breakBar, extremeBuffer, rightX, extremeBuffer, xloc = xloc.bar_index, color = color.new(eventColor, 30), style = line.style_dashed, width = 1)
    else
        line.set_xy1(failRail, breakBar, extremeBuffer)
        line.set_xy2(failRail, rightX, extremeBuffer)
        line.set_color(failRail, color.new(eventColor, 30))
    if showGuideLabels
        reclaimTagText = "Broken Edge " + f_fmt_price(activeEdge)
        failTagText = "Extreme Buffer " + f_fmt_price(extremeBuffer)
        if na(reclaimTag)
            reclaimTag := label.new(rightX + 1, activeEdge, reclaimTagText, xloc = xloc.bar_index, style = label.style_label_left, textcolor = f_text_on(eventColor), color = eventColor, size = f_text_size(labelFontSize), tooltip = "Frozen broken range edge for the active decision plan.")
        else
            label.set_x(reclaimTag, rightX + 1)
            label.set_y(reclaimTag, activeEdge)
            label.set_text(reclaimTag, reclaimTagText)
            label.set_textcolor(reclaimTag, f_text_on(eventColor))
            label.set_color(reclaimTag, eventColor)
            label.set_size(reclaimTag, f_text_size(labelFontSize))
        if na(failTag)
            failTag := label.new(rightX + 1, extremeBuffer, failTagText, xloc = xloc.bar_index, style = label.style_label_left, textcolor = f_text_on(eventColor), color = eventColor, size = f_text_size(labelFontSize), tooltip = "Soft buffer beyond the tracked break extreme. It is a planning reference, not a trade instruction.")
        else
            label.set_x(failTag, rightX + 1)
            label.set_y(failTag, extremeBuffer)
            label.set_text(failTag, failTagText)
            label.set_textcolor(failTag, f_text_on(eventColor))
            label.set_color(failTag, eventColor)
            label.set_size(failTag, f_text_size(labelFontSize))
    else
        if not na(reclaimTag)
            label.delete(reclaimTag)
            reclaimTag := na
        if not na(failTag)
            label.delete(failTag)
            failTag := na
else
    if not na(reclaimRail)
        line.delete(reclaimRail)
        reclaimRail := na
    if not na(failRail)
        line.delete(failRail)
        failRail := na
    if not na(reclaimTag)
        label.delete(reclaimTag)
        reclaimTag := na
    if not na(failTag)
        label.delete(failTag)
        failTag := na

if planActive and showTargetBackLine
    rightX = bar_index + forwardBars
    if na(targetLine)
        targetLine := line.new(breakBar, targetBackLine, rightX, targetBackLine, xloc = xloc.bar_index, color = color.new(accentColor, 10), style = line.style_dotted, width = 2)
    else
        line.set_xy1(targetLine, breakBar, targetBackLine)
        line.set_xy2(targetLine, rightX, targetBackLine)
        line.set_color(targetLine, color.new(accentColor, 10))
    if showGuideLabels
        targetTagText = "Range Mid " + f_fmt_price(targetBackLine)
        if na(targetTag)
            targetTag := label.new(rightX + 1, targetBackLine, targetTagText, xloc = xloc.bar_index, style = label.style_label_left, textcolor = f_text_on(accentColor), color = accentColor, size = f_text_size(labelFontSize), tooltip = "Frozen range midpoint used by the target-back and midpoint-reversion proof logic.")
        else
            label.set_x(targetTag, rightX + 1)
            label.set_y(targetTag, targetBackLine)
            label.set_text(targetTag, targetTagText)
            label.set_textcolor(targetTag, f_text_on(accentColor))
            label.set_color(targetTag, accentColor)
            label.set_size(targetTag, f_text_size(labelFontSize))
    else
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na
else
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> chartLabels = array.new<label>()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

canPrintNewBreak = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
canPrintContext = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
majorStateTransition = trapConfirmEvent or watchTransition or breakAcceptedEvent
bool eventPrintedThisBar = false

if showEventLabels and barstate.isconfirmed and planActive and (majorStateTransition or (newBreakEvent and canPrintNewBreak))
    eventText = ""
    eventLabelColor = accentColor
    if trapConfirmEvent
        eventText := sideWord + " Trap Confirmed | R " + str.tostring(math.round(displayTrapRisk))
        eventLabelColor := f_state_color("Trap Confirmed", activeSide)
    else if breakAcceptedEvent
        eventText := sideWord + " Break Accepted | Q " + str.tostring(math.round(displayBreakQuality))
        eventLabelColor := f_state_color("Break Accepted", activeSide)
    else if watchTransition
        eventText := sideWord + " Reclaim Watch | R " + str.tostring(math.round(displayTrapRisk))
        eventLabelColor := neutralColor
    else if newBreakEvent
        eventText := sideWord + " Break Watch | Q " + str.tostring(math.round(displayBreakQuality))
        eventLabelColor := accentColor
    if labelTextMode == "Detailed"
        eventText += "\nRisk " + str.tostring(math.round(displayTrapRisk)) + " | Break " + str.tostring(math.round(displayBreakQuality))
    aboveBar = activeSide == 1
    labelY = aboveBar ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
    labelId = label.new(bar_index, labelY, eventText, xloc = xloc.bar_index, style = aboveBar ? label.style_label_down : label.style_label_up, textcolor = f_text_on(eventLabelColor), color = eventLabelColor, size = f_text_size(labelFontSize), textalign = text.align_center)
    array.push(chartLabels, labelId)
    f_trim_labels(chartLabels, maxVisibleLabels)
    lastEventLabelBar := bar_index
    eventPrintedThisBar := true

if showContextLabels and barstate.isconfirmed and planActive and eventOutcome == 0 and not eventPrintedThisBar and canPrintContext
    aboveBar = activeSide == 1
    labelY = aboveBar ? high + atr * (labelOffsetAtr + 0.60) : low - atr * (labelOffsetAtr + 0.60)
    contextMetric = reclaimWatch ? "R " + str.tostring(math.round(displayTrapRisk)) : "Q " + str.tostring(math.round(displayBreakQuality))
    contextText = sideWord + " " + reclaimState + " | " + contextMetric
    contextLabel = label.new(bar_index, labelY, contextText, xloc = xloc.bar_index, style = aboveBar ? label.style_label_down : label.style_label_up, textcolor = f_text_on(stateColor), color = stateColor, size = f_text_size(labelFontSize), textalign = text.align_center)
    array.push(chartLabels, contextLabel)
    f_trim_labels(chartLabels, maxVisibleLabels)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
theme = panelTheme
panelSize = panelFontSize
panelBgActive = f_panel_bg(theme)
panelBorderActive = f_panel_border(theme)
workflowRead = f_workflow(reclaimState, activeSide)
stateBg = color.new(stateColor, theme == "Light" ? 76 : 20)
riskBg = color.new(f_score_color(displayTrapRisk), theme == "Light" ? 78 : 24)
stateValueColor = planActive ? f_text_on(stateBg) : f_panel_value(theme)
stateCellBg = planActive ? stateBg : f_row_bg(theme, 2)
riskValueColor = planActive ? f_text_on(riskBg) : f_panel_value(theme)
riskCellBg = planActive ? riskBg : f_row_bg(theme, 3)

var table infoPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false

panelNeedsReset = showPanel and (na(infoPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme or showPanel != lastPanelVisible)
if panelNeedsReset
    if not na(infoPanel)
        table.delete(infoPanel)
    infoPanel := table.new(f_panel_pos(panelLocation), 2, 9, bgcolor = panelBgActive, frame_color = panelBorderActive, frame_width = 1, border_color = panelBorderActive, border_width = 1)
    table.cell(infoPanel, 0, 0, "AG Pro False Break Trap Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelSize), text_halign = text.align_center)
    table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelSize))
    table.merge_cells(infoPanel, 0, 0, 1, 0)
    lastPanelLocation := panelLocation
    lastPanelTheme := panelTheme
    lastPanelVisible := showPanel

if not showPanel and not na(infoPanel)
    table.delete(infoPanel)
    infoPanel := na
    lastPanelVisible := false

if showPanel and not na(infoPanel) and barstate.islast
    table.clear(infoPanel, 0, 1, 1, 8)
    table.cell(infoPanel, 0, 0, "AG Pro False Break Trap Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelSize), text_halign = text.align_center)
    f_panel_row(infoPanel, 1, "Workflow", workflowRead, planActive ? stateColor : f_panel_value(theme), theme, panelSize, f_row_bg(theme, 1))
    f_panel_row(infoPanel, 2, "State", stateDisplay, stateValueColor, theme, panelSize, stateCellBg)
    f_panel_row(infoPanel, 3, "Trap Risk", trapRiskText, riskValueColor, theme, panelSize, riskCellBg)
    f_panel_row(infoPanel, 4, "Break Quality", breakQualityText, planActive ? (displayBreakQuality >= 68.0 ? bullColor : displayBreakQuality >= 48.0 ? neutralColor : dangerColor) : f_panel_value(theme), theme, panelSize, f_row_bg(theme, 4))
    f_panel_row(infoPanel, 5, "Failure Room", midpointGapText, planActive ? accentColor : f_panel_value(theme), theme, panelSize, f_row_bg(theme, 5))
    f_panel_row(infoPanel, 6, "Bars Active", barsActiveText, planActive ? stateColor : f_panel_value(theme), theme, panelSize, f_row_bg(theme, 6))
    f_panel_row(infoPanel, 7, "Key Level", keyLevelText, planActive ? eventColor : f_panel_value(theme), theme, panelSize, f_row_bg(theme, 7))
    f_panel_row(infoPanel, 8, "Mid Reversion", reversionRateText, reversionRateColor, theme, panelSize, f_row_bg(theme, 8))

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(upperTrapAlert, "Upper Break Trap Confirmed", "False Break Trap Planner: upper break trap confirmed. This is an attention marker, not a trade instruction.")
alertcondition(lowerTrapAlert, "Lower Break Trap Confirmed", "False Break Trap Planner: lower break trap confirmed. This is an attention marker, not a trade instruction.")
alertcondition(upperWatchAlert, "Upper Reclaim Watch", "False Break Trap Planner: upper break is under reclaim watch. This is an attention marker, not a trade instruction.")
alertcondition(lowerWatchAlert, "Lower Reclaim Watch", "False Break Trap Planner: lower break is under reclaim watch. This is an attention marker, not a trade instruction.")
alertcondition(breakAcceptedAlert, "Break Accepted", "False Break Trap Planner: the break is holding beyond the acceptance window. This is an attention marker, not a trade instruction.")

// Hidden reference plots
plot(planActive ? displayTrapRisk : na, "Trap Risk Score", display = display.none)
plot(planActive ? displayBreakQuality : na, "Break Quality Score", display = display.none)
plot(planActive ? targetBackLine : na, "Target Back Line", display = display.none)
plot(planActive ? activeEdge : na, "Broken Range Edge", display = display.none)
````
