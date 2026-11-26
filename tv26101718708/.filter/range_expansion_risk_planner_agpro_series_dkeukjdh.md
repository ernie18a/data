# Range Expansion Risk Planner [AGPro Series]

- url: https://www.tradingview.com/script/dkEuKJdH-Range-Expansion-Risk-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;3f8680d0129445628011da90cf245715
- version: 4.0

## Description

Range Expansion Risk Planner [AGPro Series]

🧠 Core Idea

Does a range expansion offer clean room, or is price moving into immediate failure risk?


📌 Overview / What it does

Range Expansion Risk Planner [AGPro Series] is a chart-first breakout quality and risk-planning tool built for one specific moment: price has left a defined range, and the trader needs to understand whether the expansion has enough structure to deserve attention.

Instead of printing generic breakout signals, the script maps the source range, freezes the broken edge, builds an expansion runway, tracks a failure rail, estimates target room, evaluates retest behavior, and converts those conditions into a 0-100 planner score.

The script produces a source range box, expansion runway, failed-expansion review band, risk/target rails, full-state labels, deterministic alerts, and a clean AGPro panel. It does not predict future price movement, automate execution, or guarantee that a breakout will continue.


🎯 Purpose & Design Philosophy

This script was built for traders who want to evaluate range expansion quality after price leaves a structure, not simply react to the first candle outside the range.

Many tools mark breakouts, draw range boxes, or highlight volatility expansion. The gap is the planning layer after the break: Is the source range mature? Was the expansion candle strong enough? Did price close clearly beyond the edge? Is the retest accepted or weak? Is there enough room before the next target-side reference?

The design supports a decision-first workflow. It helps users separate a clean range expansion from a weak release, blocked room, failed expansion, or early unconfirmed movement.


⚡ Why This Script Is Different

Most tools focus on breakout arrows, range highs/lows, volatility spikes, or support/resistance zones.

This script does NOT become a generic range breakout signal, a generic S/R zone map, a squeeze indicator, or a target predictor.

Instead, it evaluates the quality of the expansion plan after the range edge is broken. The main output is not a trade command. It is a planning state that helps the user decide whether the current expansion is CLEAN, on REVIEW, waiting for retest, blocked by room risk, or failing back into the source range.


⚙️ Methodology

1. Context Detection
The script maps the active source range using a user-defined lookback and detects whether price has closed beyond the upper or lower edge with enough ATR-normalized distance.

2. Reference Mapping
When a qualified expansion appears, the script freezes the source range, the broken edge, the failure rail, and the target-room marker so the plan can be reviewed consistently.

3. Reaction Evaluation
The model scores range maturity, expansion candle quality, close beyond edge, retest quality, target-room distance, and failure-rail distance.

4. Visual Output
The result is displayed through a source range box, expansion runway, failed-expansion band, risk/target rails, full-state event labels, alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Zones = the source range shows where the expansion came from. The expansion runway shows the path between the broken edge and the target-room marker. The failed-expansion band shows the area where the release may be losing structure.

Labels = full-state markers show Range Expansion, Clean Expansion, Expansion Review, Retest Accepted, Failed Expansion, Target Room Reached, Failure Risk, or Range Watch context.

Colors = teal highlights cleaner bullish expansion, pink highlights bearish or failed contexts, amber highlights review/risk states, and indigo highlights watch or target-edge states.

Panel = the panel summarizes Range Maturity, Expansion Risk, Room Risk, Confirmation, and Action.


🚦 Signals & States

• CLEAN EXPANSION → range expansion quality is strong enough to deserve active review.

• REVIEW → expansion context is developing, but confirmation or target room is incomplete.

• WAIT RETEST → price has expanded, but the broken edge has not yet been accepted clearly.

• ROOM BLOCKED → target-side room is limited relative to the current risk structure.

• FAILURE RISK → price is back inside the range or close to the failed-expansion area.

• FAILED → price crossed the failure rail and the prior expansion plan should be reviewed.

• TARGET EDGE → price reached the active target-room marker.

• RANGE WATCH → the range is mature enough to monitor, but no qualified expansion is active yet.


🔔 Alerts Logic

Alerts trigger when the planner enters clean expansion, review state, retest accepted state, failed-expansion warning, or target-room reached state.

These alerts are attention markers only. They are not trade instructions, entry signals, automated strategy commands, or guaranteed outcomes.


🧩 Confluence Logic

The strongest context appears when a mature source range releases with a strong expansion candle, price closes clearly beyond the edge, target-side room remains open, the failure rail is not too far away, and the broken edge receives constructive retest behavior.

When those components align, the planner score improves and the action state becomes cleaner.


📊 When to Use

• After price leaves a clear range

• During breakout-review workflows

• When comparing whether a release has enough room to justify attention

• When price retests the broken range edge

• On liquid symbols where ATR, range, and volume behavior are readable

• Especially on 4H swing charts, where range release, retest behavior, failure risk, and target-room context remain visually readable


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro-timeframes

• News-driven candles that distort the range edge

• Markets with frequent gaps or unreliable volume

• Situations where the user expects a simple buy/sell signal


🎛️ Key Inputs

• Expansion Side → controls Auto, Long Expansion, or Short Expansion planning.

• Sensitivity → changes how selective the range maturity and edge-close requirements are.

• Source Range Lookback → defines the range used before expansion.

• ATR Length → normalizes failure rail, label spacing, expansion distance, and room risk.

• Retest Review Bars → controls how long an edge retest can improve confirmation quality.

• Target-Side Obstacle Lookback → searches for older target-side references before using the measured target.

• CLEAN / REVIEW Scores → adjust how strict the state model is.

• Visual settings → control boxes, runway, rails, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around one primary decision path: source range → expansion runway → failure rail → target room.

The panel uses the AGPro public-release standard with one merged blue header row containing only the script name. It keeps the decision fields readable without turning the chart into a crowded dashboard.

Labels keep full professional state names, are offset away from candles, and are limited by cooldown and max-visible controls.


🧪 Practical Usage Workflow

1. Read the panel action state.

2. Check whether the source range was mature enough before expansion.

3. Review the expansion runway and target-room marker.

4. Check whether price accepted the broken edge or moved back into failure risk.

5. Use alerts as attention markers, then evaluate the broader market context.


🔍 Interpretation Guidelines

A higher score means the model sees better alignment between source range quality, expansion candle quality, edge close, retest behavior, and target room.

CLEAN EXPANSION does not mean a trade must be taken. It means the expansion structure is clean enough to deserve active review.

REVIEW means the release may be developing, but the user should check confirmation and room quality before treating it as clean.

FAILED and FAILURE RISK are caution states. They help identify when an expansion is losing structure after leaving the range.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.

It does not replace user judgment, risk management, or broader market analysis.


⚠️ Limitations & Transparency

Timeframe differences can change how range maturity, retests, and target-room references appear.

Volatility changes can widen failure rails or reduce clean target room.

Fast market conditions can move from CLEAN to FAILED quickly if price returns into the source range.

The script is rule-based and should be interpreted as an analytical planning layer, not as certainty.


🧠 Market Context Notes

Range expansion quality is not only about breaking the edge. A cleaner expansion usually needs a readable source range, a decisive close beyond the edge, enough room before obstruction, and a failure reference that is not too wide.

The planner is most useful when it prevents users from treating every breakout as equal.


🧾 Use Case Examples

When price closes beyond a mature range and the target-room marker remains far enough away, the planner may move into REVIEW or CLEAN EXPANSION.

When price retests the broken edge and holds outside the range, confirmation can improve.

When price closes back through the failure rail, the planner marks FAILED so the old expansion idea is not treated as clean anymore.


🧱 System Philosophy

Range Expansion Risk Planner follows the AGPro Series decision-engine approach:

Context first.
Risk before reaction.
Structure before signal.
Attention markers instead of promises.


🔐 Non-Promise Statement

No indicator can remove uncertainty.

No score, state, label, alert, range box, runway, or rail should be interpreted as guaranteed market direction.


📉 Risk Disclosure

Trading involves risk.

All decisions remain the responsibility of the user.

This script is for educational and analytical chart review only and does not provide financial advice.


📚 Educational Note

Use this script to study how range expansions develop, how broken edges behave after release, and how failure risk can be organized visually before making discretionary decisions.

## Source Code

````pine
// -------------------------------------------------
// Range Expansion Risk Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Range Expansion Risk Planner is a chart-first breakout quality and risk
// planning engine that evaluates whether a release from a defined range has
// clean expansion room or immediate failure risk. It maps the source range,
// active expansion runway, failure rail, target-room marker, 0-100 planner
// score, and next-action state without becoming a generic breakout signal.
// Version 1.4 adds a stop-aware target-room hit rate that measures how often
// expansions reached the target room before the failure rail.
// Version 1.5 adds collision-safe owned rail lanes and compact zone identities.
// -------------------------------------------------

//@version=6
indicator("Range Expansion Risk Planner [AGPro Series]",
     shorttitle = "AG RER",
     overlay = true,
     max_labels_count = 180,
     max_boxes_count = 40,
     max_lines_count = 90)

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
ttSide = "Selects the expansion side. Auto only activates after price closes beyond the mapped range edge. Manual modes force long-side or short-side range expansion planning."
ttSensitivity = "Controls selectivity across the model. Conservative requires stronger range maturity and edge close; Aggressive allows earlier review states."
ttConfirm = "Close Confirmed prints states, labels, and alerts only after bar close. Live Updating allows the planner to update during the active bar."
ttRange = "Lookback used to map the source range before expansion. The script freezes this range when a qualified release starts."
ttRangeBase = "Baseline used to compare the current range width against normal range width. This helps separate mature ranges from loose structures."
ttAtr = "ATR length used to normalize expansion distance, failure rail width, label offsets, target room, and risk distance."
ttVolume = "Volume baseline used to evaluate whether the expansion candle has participation. On symbols without reliable volume, this component becomes neutral."
ttRetest = "Number of bars after expansion where a range-edge retest can improve confirmation quality."
ttObstacle = "Lookback used to locate older target-side obstacles. If no meaningful obstacle exists, the measured range target is used."
ttActive = "Maximum number of bars an expansion plan can remain active before a fresh qualified release is required."
ttMinScore = "Minimum 0-100 planner score required for Clean Expansion context. This is an attention state, not a trade instruction."
ttWatchScore = "Minimum 0-100 score required for Expansion Review context. Review means the expansion deserves study but is not clean enough yet."
ttBreakAtr = "Minimum ATR-normalized close beyond the range edge required to start a range expansion plan."
ttFailureBuffer = "ATR buffer inside the broken range edge used to define the failure rail. A close beyond this rail marks failed expansion risk."
ttRetestBand = "ATR band around the broken edge used to detect whether price retested and accepted the range edge after expansion."
ttMinRoom = "Minimum ATR-normalized room preferred between current price and the target-room marker."
ttIdealRoom = "Target-room distance treated as strong enough for clean planning. Higher values require more open space."
ttMaxRisk = "ATR-normalized distance from price to failure rail above which risk is treated as too wide for clean planning."
ttTarget = "Measured-range multiplier used to project the target-room marker from the broken edge. This is a planning reference only."
ttProjection = "Number of bars projected to the right for the range box, expansion runway, failure rail, and target-room marker."
ttRangeBox = "Shows the source range with a separate centered maturity badge. When a qualified expansion starts, the box freezes around the source range."
ttRunway = "Shows the expansion runway from the broken range edge toward the active target-room marker. The state badge is centered inside the runway."
ttRails = "Shows the broken range edge, failure rail, and target-room guide lines used by the planner."
ttFailureBand = "Shows a narrow failed-expansion review band around the broken edge and failure rail."
ttRightTags = "Displays compact price-aware right-side tags for active edge, target, and failure references, with owned connectors where close rails require separate visual lanes."
ttBoxOpacity = "Controls box transparency. Higher values make range and runway boxes lighter."
ttLabels = "Shows Range Expansion, Clean Expansion, Retest Accepted, Failed Expansion, Target Room, and Range Watch labels with controlled spacing."
ttContext = "Adds sparse context labels during active planning so the chart remains informative without becoming crowded."
ttCooldown = "Minimum bars between event labels. Higher values reduce label density."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing states."
ttMaxLabels = "Maximum number of chart labels retained. Older labels are deleted first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels away from candles."
ttLabelStack = "Extra ATR offset added when labels print near each other. This keeps labels readable without abbreviating them."
ttLabelScore = "Adds the 0-100 planner score to chart labels."
ttLabelSize = "Font size for chart labels, right-side tags, and centered badges. Normal is the recommended public-release default."
ttShowPanel = "Shows or hides the AG Pro planning panel. It is visible by default for public-release readability."
ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between dark and light chart-friendly themes."
ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended public-release default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Range Expansion Engine"
sideMode = input.string("Auto", "Expansion Side", options = ["Auto", "Long Expansion", "Short Expansion"], group = groupEngine, tooltip = ttSide)
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = ttSensitivity)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)
rangeLookback = input.int(34, "Source Range Lookback", minval = 12, maxval = 240, group = groupEngine, tooltip = ttRange)
rangeBaseLength = input.int(100, "Range Width Baseline", minval = 30, maxval = 400, group = groupEngine, tooltip = ttRangeBase)
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
volumeLength = input.int(20, "Volume Baseline Length", minval = 5, maxval = 150, group = groupEngine, tooltip = ttVolume)
retestLookback = input.int(12, "Retest Review Bars", minval = 2, maxval = 60, group = groupEngine, tooltip = ttRetest)
obstacleLookback = input.int(144, "Target-Side Obstacle Lookback", minval = 40, maxval = 500, group = groupEngine, tooltip = ttObstacle)
maxActiveBars = input.int(90, "Max Active Plan Bars", minval = 20, maxval = 300, group = groupEngine, tooltip = ttActive)

groupScoring = "Planner Scoring"
minimumPlannerScore = input.int(70, "Clean Expansion Score", minval = 45, maxval = 95, group = groupScoring, tooltip = ttMinScore)
reviewScore = input.int(54, "Review Score", minval = 25, maxval = 90, group = groupScoring, tooltip = ttWatchScore)
minimumEdgeCloseAtr = input.float(0.16, "Minimum Edge Close ATR", minval = 0.02, maxval = 1.50, step = 0.01, group = groupScoring, tooltip = ttBreakAtr)
failureBufferAtr = input.float(0.12, "Failure Rail Buffer ATR", minval = 0.00, maxval = 1.20, step = 0.01, group = groupScoring, tooltip = ttFailureBuffer)
retestBandAtr = input.float(0.38, "Retest Acceptance Band ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttRetestBand)
minimumRoomAtr = input.float(0.85, "Minimum Target Room ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttMinRoom)
idealRoomAtr = input.float(2.60, "Ideal Target Room ATR", minval = 0.40, maxval = 10.00, step = 0.05, group = groupScoring, tooltip = ttIdealRoom)
maximumRiskAtr = input.float(3.20, "Maximum Failure Distance ATR", minval = 0.50, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = ttMaxRisk)
targetRangeMultiple = input.float(1.15, "Target Room Range Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttTarget)

groupVisual = "Chart Visuals"
showRangeBox = input.bool(true, "Show Source Range Box", group = groupVisual, tooltip = ttRangeBox)
showExpansionRunway = input.bool(true, "Show Expansion Runway", group = groupVisual, tooltip = ttRunway)
showPlanningRails = input.bool(true, "Show Risk / Target Rails", group = groupVisual, tooltip = ttRails)
showFailureBand = input.bool(true, "Show Failed-Expansion Band", group = groupVisual, tooltip = ttFailureBand)
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttRightTags)
projectionBars = input.int(34, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
boxTransparency = input.int(90, "Box Transparency", minval = 72, maxval = 96, group = groupVisual, tooltip = ttBoxOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
showMicroMarkers = input.bool(false, "Show Micro Markers", group = groupLabels, tooltip = "Shows tiny event markers in addition to labels. Disabled by default because labels and badges carry the primary chart story.")
labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 2, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(58, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 60, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
labelStackAtr = input.float(0.80, "Label Stack Offset ATR", minval = 0.00, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelStack)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    result = 0.0
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

f_panel_pos(string posText) =>
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

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_panel_bg(string theme) =>
    theme == "Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    evenRow = row % 2 == 0
    theme == "Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_score_color(float score) =>
    result = bearColor
    if score >= minimumPlannerScore
        result := bullColor
    else if score >= reviewScore
        result := accentColor
    else if score >= 40.0
        result := neutralColor
    result

f_state_color(string stateText) =>
    switch stateText
        "Clean Expansion" => bullColor
        "Expansion Review" => accentColor
        "Waiting For Retest" => neutralColor
        "Target Room Blocked" => neutralColor
        "Failure Risk" => dangerColor
        "Failed Expansion" => bearColor
        "Target Room Reached" => accentColor
        "Range Watch" => accentColor
        "Range Building" => neutralColor
        => panelLabelCol

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_fmt_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_set_label(label tag, int x, float y, string txt, color bg, styleValue, textSize) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, txt)
    label.set_color(tag, color.new(bg, 0))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, textSize)
    label.set_textalign(tag, text.align_center)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

// -------------------------------------------------
// Sensitivity and Base Measurements
// -------------------------------------------------
confirmedBar = confirmationMode == "Live Updating" or barstate.isconfirmed
sensitivityBreakMult = sensitivity == "Conservative" ? 1.25 : sensitivity == "Aggressive" ? 0.82 : 1.00
sensitivityMaturityMult = sensitivity == "Conservative" ? 1.25 : sensitivity == "Aggressive" ? 0.78 : 1.00
sensitivityRoomMult = sensitivity == "Conservative" ? 1.15 : sensitivity == "Aggressive" ? 0.88 : 1.00
requiredBreakAtr = minimumEdgeCloseAtr * sensitivityBreakMult
requiredMaturityBars = math.max(4, int(math.round(rangeLookback * 0.32 * sensitivityMaturityMult)))

atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
priorRangeHigh = nz(ta.highest(high, rangeLookback)[1], high)
priorRangeLow = nz(ta.lowest(low, rangeLookback)[1], low)
priorRangeWidth = math.max(priorRangeHigh - priorRangeLow, syminfo.mintick)
priorMid = (priorRangeHigh + priorRangeLow) * 0.5
rangeBase = ta.sma(priorRangeWidth, rangeBaseLength)
rangeRatio = not na(rangeBase) and rangeBase > 0.0 ? priorRangeWidth / rangeBase : 1.0
rangeWidthAtr = priorRangeWidth / safeAtr

barRange = math.max(high - low, syminfo.mintick)
bodyShare = math.abs(close - open) / barRange
rawVolume = na(volume) ? 1.0 : volume
volumeBase = ta.sma(rawVolume, volumeLength)
volumeRatio = not na(volumeBase) and volumeBase > 0.0 ? rawVolume / volumeBase : 1.0
volumeScore = na(volume) ? 55.0 : f_norm_high_good(volumeRatio, 0.75, 1.55)

quietRangeBar = barRange / safeAtr <= 1.35 and bodyShare <= 0.66
var int quietAge = 0
quietAge := quietRangeBar ? nz(quietAge[1]) + 1 : 0
priorQuietAge = nz(quietAge[1])

rangeAgeScore = f_norm_high_good(priorQuietAge, requiredMaturityBars * 0.45, requiredMaturityBars * 2.00)
rangeWidthScore = f_peak_score(rangeWidthAtr, 0.85, 3.35, 8.20)
rangeCompressionScore = f_norm_low_good(rangeRatio, 0.72, 1.36)
currentRangeMaturityScore = f_clamp(rangeAgeScore * 0.36 + rangeWidthScore * 0.42 + rangeCompressionScore * 0.22, 0.0, 100.0)

breakAboveAtr = math.max(close - priorRangeHigh, 0.0) / safeAtr
breakBelowAtr = math.max(priorRangeLow - close, 0.0) / safeAtr
candidateBullBreak = breakAboveAtr >= requiredBreakAtr
candidateBearBreak = breakBelowAtr >= requiredBreakAtr

autoDetectedDir = candidateBullBreak and not candidateBearBreak ? 1 : candidateBearBreak and not candidateBullBreak ? -1 : close >= priorMid ? 1 : -1
detectedDir = 0
if sideMode == "Long Expansion"
    detectedDir := candidateBullBreak ? 1 : 0
else if sideMode == "Short Expansion"
    detectedDir := candidateBearBreak ? -1 : 0
else
    detectedDir := candidateBullBreak and not candidateBearBreak ? 1 : candidateBearBreak and not candidateBullBreak ? -1 : 0

calcDir = detectedDir == 0 ? autoDetectedDir : detectedDir
candidateCloseBeyondAtr = calcDir == 1 ? breakAboveAtr : breakBelowAtr
candidateCloseLocation = calcDir == 1 ? (close - low) / barRange : (high - close) / barRange
candidateRangePower = barRange / safeAtr
candidateCloseScore = f_norm_high_good(candidateCloseBeyondAtr, requiredBreakAtr * 0.35, requiredBreakAtr + 0.95)
candidateLocationScore = f_clamp(candidateCloseLocation * 100.0, 0.0, 100.0)
candidateBodyScore = f_norm_high_good(bodyShare, 0.22, 0.68)
candidatePowerScore = f_peak_score(candidateRangePower, 0.55, 1.45, 3.50)
candidateExpansionCandleScore = f_clamp(candidateCloseScore * 0.36 + candidateLocationScore * 0.24 + candidateBodyScore * 0.18 + candidatePowerScore * 0.12 + volumeScore * 0.10, 0.0, 100.0)
candidateExpansion = detectedDir != 0

// -------------------------------------------------
// Active Expansion Memory
// -------------------------------------------------
var int activeDir = 0
var int activeStartBar = na
var float activeRangeHigh = na
var float activeRangeLow = na
var float activeRangeWidth = na
var float activeMaturityScore = na
var float activeExpansionCandleScore = na
var int activeRangeAge = 0
var bool activeFailed = false
var bool activeTargetHit = false

activeExpired = activeDir != 0 and not na(activeStartBar) and bar_index - activeStartBar > maxActiveBars
canStartFresh = candidateExpansion and (activeDir == 0 or detectedDir != activeDir or activeExpired or activeFailed or activeTargetHit)
newExpansionEvent = false

if confirmedBar and canStartFresh
    activeDir := detectedDir
    activeStartBar := bar_index
    activeRangeHigh := priorRangeHigh
    activeRangeLow := priorRangeLow
    activeRangeWidth := priorRangeWidth
    activeMaturityScore := currentRangeMaturityScore
    activeExpansionCandleScore := candidateExpansionCandleScore
    activeRangeAge := priorQuietAge
    activeFailed := false
    activeTargetHit := false
    newExpansionEvent := true

activeNow = activeDir != 0 and not na(activeStartBar) and not na(activeRangeHigh) and not na(activeRangeLow)
activeAge = activeNow ? bar_index - activeStartBar : 0
activeEdge = activeNow ? activeDir == 1 ? activeRangeHigh : activeRangeLow : na
activeWidth = activeNow ? math.max(activeRangeWidth, syminfo.mintick) : priorRangeWidth
measuredTarget = activeNow ? activeEdge + activeDir * activeWidth * targetRangeMultiple : na
rawObstacle = activeDir == 1 ? nz(ta.highest(high, obstacleLookback)[1], measuredTarget) : nz(ta.lowest(low, obstacleLookback)[1], measuredTarget)
obstacleOnTargetSide = activeNow and (activeDir == 1 ? rawObstacle > activeEdge + safeAtr * 0.20 : rawObstacle < activeEdge - safeAtr * 0.20)
targetEdge = activeNow ? obstacleOnTargetSide ? activeDir == 1 ? math.min(rawObstacle, measuredTarget) : math.max(rawObstacle, measuredTarget) : measuredTarget : na
failureRail = activeNow ? activeDir == 1 ? activeEdge - safeAtr * failureBufferAtr : activeEdge + safeAtr * failureBufferAtr : na

closeBeyondActiveAtr = activeNow ? math.max(activeDir * (close - activeEdge), 0.0) / safeAtr : 0.0
backInsideRange = activeNow and (activeDir == 1 ? close < activeEdge : close > activeEdge)
failureNow = activeNow and (activeDir == 1 ? close < failureRail : close > failureRail)
targetReachedNow = activeNow and (activeDir == 1 ? high >= targetEdge : low <= targetEdge)
edgeTouch = activeNow and activeAge > 0 and (activeDir == 1 ? low <= activeEdge + safeAtr * retestBandAtr : high >= activeEdge - safeAtr * retestBandAtr)
acceptedRetest = activeNow and edgeTouch and not backInsideRange and not failureNow

if confirmedBar and activeNow
    activeFailed := activeFailed or failureNow
    activeTargetHit := activeTargetHit or targetReachedNow

barsSinceRetest = ta.barssince(acceptedRetest)
retestRecent = not na(barsSinceRetest) and barsSinceRetest <= retestLookback

// -------------------------------------------------
// Planner Scoring and States
// -------------------------------------------------
currentCloseScore = activeNow ? f_norm_high_good(closeBeyondActiveAtr, requiredBreakAtr * 0.30, requiredBreakAtr + 0.95) : 0.0
activeCloseLocation = activeNow ? activeDir == 1 ? (close - low) / barRange : (high - close) / barRange : candidateCloseLocation
retestQualityScore = 0.0
if not activeNow
    retestQualityScore := 0.0
else if activeFailed
    retestQualityScore := 0.0
else if acceptedRetest
    retestQualityScore := 92.0
else if retestRecent
    retestQualityScore := 84.0
else if backInsideRange
    retestQualityScore := 20.0
else if activeAge <= retestLookback
    retestQualityScore := 62.0
else
    retestQualityScore := 52.0

targetRoomAtr = activeNow ? math.max(activeDir * (targetEdge - close), 0.0) / safeAtr : 0.0
failureDistanceAtr = activeNow ? math.max(activeDir * (close - failureRail), 0.0) / safeAtr : 0.0
roomDistanceScore = f_norm_high_good(targetRoomAtr, minimumRoomAtr * sensitivityRoomMult, idealRoomAtr * sensitivityRoomMult)
failureDistanceScore = f_peak_score(failureDistanceAtr, 0.18, 1.40, maximumRiskAtr)
roomRiskScore = activeNow ? f_clamp(roomDistanceScore * 0.68 + failureDistanceScore * 0.32, 0.0, 100.0) : 0.0

rawPlannerScore = activeNow ? activeMaturityScore * 0.20 + activeExpansionCandleScore * 0.26 + currentCloseScore * 0.16 + retestQualityScore * 0.18 + roomRiskScore * 0.20 : currentRangeMaturityScore
cappedPlannerScore = rawPlannerScore
if activeFailed
    cappedPlannerScore := math.min(cappedPlannerScore, 28.0)
else if backInsideRange
    cappedPlannerScore := math.min(cappedPlannerScore, 44.0)
else if activeTargetHit
    cappedPlannerScore := math.min(cappedPlannerScore, 66.0)
else if roomRiskScore < 28.0 and activeNow
    cappedPlannerScore := math.min(cappedPlannerScore, 52.0)

plannerScore = int(math.round(f_clamp(cappedPlannerScore, 0.0, 100.0)))
directionText = activeNow ? activeDir == 1 ? "Long" : "Short" : calcDir == 1 ? "Long" : "Short"

rangeMaturityState = activeNow ? activeMaturityScore >= 72.0 ? "Mature" : activeMaturityScore >= 55.0 ? "Usable" : "Thin" : currentRangeMaturityScore >= 72.0 ? "Mature" : currentRangeMaturityScore >= 55.0 ? "Building" : "Loose"
roomRiskState = not activeNow ? "No runway" : activeTargetHit ? "Target edge" : targetRoomAtr < minimumRoomAtr * sensitivityRoomMult ? "Blocked" : roomRiskScore < 50.0 ? "Thin room" : "Open room"
confirmationState = not activeNow ? currentRangeMaturityScore >= 55.0 ? "Await edge" : "Range forming" : activeFailed or failureNow ? "Back inside" : acceptedRetest or retestRecent ? "Retest accepted" : closeBeyondActiveAtr >= requiredBreakAtr * 1.55 and activeCloseLocation >= 0.58 ? "Close confirmed" : activeAge <= retestLookback ? "Await retest" : "Unconfirmed"

plannerState = ""
if not activeNow
    plannerState := currentRangeMaturityScore >= 62.0 ? "Range Watch" : "Range Building"
else if activeFailed
    plannerState := "Failed Expansion"
else if activeTargetHit
    plannerState := "Target Room Reached"
else if backInsideRange
    plannerState := "Failure Risk"
else if roomRiskState == "Blocked"
    plannerState := "Target Room Blocked"
else if plannerScore >= minimumPlannerScore and (acceptedRetest or retestRecent or confirmationState == "Close confirmed")
    plannerState := "Clean Expansion"
else if plannerScore >= reviewScore
    plannerState := "Expansion Review"
else
    plannerState := "Waiting For Retest"

actionState = ""
if plannerState == "Clean Expansion"
    actionState := "Review expansion"
else if plannerState == "Expansion Review"
    actionState := "Review room"
else if plannerState == "Waiting For Retest"
    actionState := "Wait retest"
else if plannerState == "Target Room Blocked"
    actionState := "Check obstacle"
else if plannerState == "Failure Risk"
    actionState := "Check failure"
else if plannerState == "Failed Expansion"
    actionState := "Review failure"
else if plannerState == "Target Room Reached"
    actionState := "Review target"
else if plannerState == "Range Watch"
    actionState := "Wait edge"
else
    actionState := "Build range"

plannerColor = f_state_color(plannerState)
scoreColor = activeNow ? f_score_color(plannerScore) : f_score_color(currentRangeMaturityScore)

// -------------------------------------------------
// Target-room follow-through proof (stop-aware)
// -------------------------------------------------
// After each qualified expansion, did price reach the target-room marker before
// the failure rail was crossed? Win = target room first, Loss = failure rail
// first, neither inside the active window = uncounted.
var int   pfTotal  = 0
var int   pfWins   = 0
var bool  pfOpen   = false
var int   pfDir    = 0
var float pfTarget = na
var float pfFail   = na
var int   pfBar    = na

if confirmedBar
    if pfOpen
        bool pfHitFail   = pfDir == 1 ? close < pfFail : close > pfFail
        bool pfHitTarget = pfDir == 1 ? high >= pfTarget : low <= pfTarget
        if pfHitFail
            pfTotal += 1
            pfOpen  := false
        else if pfHitTarget
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > maxActiveBars
            pfOpen := false
    if newExpansionEvent and not na(targetEdge) and not na(failureRail)
        pfOpen   := true
        pfDir    := activeDir
        pfTarget := targetEdge
        pfFail   := failureRail
        pfBar    := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
targetRateText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"

// -------------------------------------------------
// Visual Range, Runway, and Rails
// -------------------------------------------------
labelSize = f_text_size(labelFontSize)
rightEdge = bar_index + projectionBars
currentRangeLeft = math.max(0, bar_index - rangeLookback)
activeRangeLeft = activeNow ? math.max(0, activeStartBar - rangeLookback) : currentRangeLeft
visualRangeLeft = activeNow ? activeRangeLeft : currentRangeLeft
visualRangeRight = activeNow ? rightEdge : bar_index + math.min(projectionBars, 22)
visualRangeHigh = activeNow ? activeRangeHigh : priorRangeHigh
visualRangeLow = activeNow ? activeRangeLow : priorRangeLow
rangeBadgeText = activeNow ? "SOURCE RANGE | M" + str.tostring(int(math.round(activeMaturityScore))) : str.upper(rangeMaturityState) + " | M" + str.tostring(int(math.round(currentRangeMaturityScore)))
rangeBadgeColor = activeNow ? color.rgb(71, 85, 105) : accentColor
rangeBoxColor = activeNow ? color.new(panelLabelCol, boxTransparency) : color.new(accentColor, math.min(boxTransparency + 2, 96))

var box sourceRangeBox = na
var box expansionRunwayBox = na
var box failedExpansionBand = na
var line edgeLine = na
var line failureLine = na
var line targetLine = na
var line edgeLead = na
var line failureLead = na
var label rangeBadge = na
var label runwayBadge = na
var label failureBadge = na
var label edgeTag = na
var label targetTag = na
var label failureTag = na

if showRangeBox
    if na(sourceRangeBox)
        sourceRangeBox := box.new(visualRangeLeft, visualRangeHigh, visualRangeRight, visualRangeLow, xloc = xloc.bar_index, bgcolor = rangeBoxColor, border_color = color.new(panelLabelCol, 38), border_width = 1)
    else
        box.set_lefttop(sourceRangeBox, visualRangeLeft, visualRangeHigh)
        box.set_rightbottom(sourceRangeBox, visualRangeRight, visualRangeLow)
        box.set_bgcolor(sourceRangeBox, rangeBoxColor)
        box.set_border_color(sourceRangeBox, color.new(panelLabelCol, 38))
    rangeCenterX = int(math.round((visualRangeLeft + visualRangeRight) * 0.5))
    rangeCenterY = (visualRangeHigh + visualRangeLow) * 0.5
    if na(rangeBadge)
        rangeBadge := label.new(rangeCenterX, rangeCenterY, "", xloc = xloc.bar_index, style = label.style_label_center, color = rangeBadgeColor, textcolor = f_text_on(rangeBadgeColor), size = labelSize)
    f_set_label(rangeBadge, rangeCenterX, rangeCenterY, rangeBadgeText, rangeBadgeColor, label.style_label_center, labelSize)
else
    if not na(sourceRangeBox)
        box.delete(sourceRangeBox)
        sourceRangeBox := na
    if not na(rangeBadge)
        label.delete(rangeBadge)
        rangeBadge := na

if showExpansionRunway and activeNow
    runwayTop = math.max(activeEdge, targetEdge)
    runwayBottom = math.min(activeEdge, targetEdge)
    runwayColor = plannerState == "Clean Expansion" ? (activeDir == 1 ? bullColor : bearColor) : plannerColor
    runwayText = activeFailed or backInsideRange ? "FAILURE REVIEW | Q" + str.tostring(plannerScore) : str.upper(plannerState) + " | Q" + str.tostring(plannerScore)
    if na(expansionRunwayBox)
        expansionRunwayBox := box.new(activeStartBar, runwayTop, rightEdge, runwayBottom, xloc = xloc.bar_index, bgcolor = color.new(runwayColor, boxTransparency), border_color = color.new(runwayColor, 28), border_width = 1)
    else
        box.set_lefttop(expansionRunwayBox, activeStartBar, runwayTop)
        box.set_rightbottom(expansionRunwayBox, rightEdge, runwayBottom)
        box.set_bgcolor(expansionRunwayBox, color.new(runwayColor, boxTransparency))
        box.set_border_color(expansionRunwayBox, color.new(runwayColor, 28))
    runwayCenterX = int(math.round((activeStartBar + rightEdge) * 0.5))
    runwayCenterY = (runwayTop + runwayBottom) * 0.5
    if na(runwayBadge)
        runwayBadge := label.new(runwayCenterX, runwayCenterY, "", xloc = xloc.bar_index, style = label.style_label_center, color = runwayColor, textcolor = f_text_on(runwayColor), size = labelSize)
    f_set_label(runwayBadge, runwayCenterX, runwayCenterY, runwayText, runwayColor, label.style_label_center, labelSize)
else
    if not na(expansionRunwayBox)
        box.delete(expansionRunwayBox)
        expansionRunwayBox := na
    if not na(runwayBadge)
        label.delete(runwayBadge)
        runwayBadge := na

if showFailureBand and activeNow
    failureTop = math.max(activeEdge, failureRail)
    failureBottom = math.min(activeEdge, failureRail)
    failureText = activeFailed or backInsideRange ? "FAILURE REVIEW" : "FAILURE BAND"
    failureColor = activeFailed or backInsideRange ? dangerColor : neutralColor
    if na(failedExpansionBand)
        failedExpansionBand := box.new(activeStartBar, failureTop, rightEdge, failureBottom, xloc = xloc.bar_index, bgcolor = color.new(failureColor, 88), border_color = color.new(failureColor, 34), border_width = 1)
    else
        box.set_lefttop(failedExpansionBand, activeStartBar, failureTop)
        box.set_rightbottom(failedExpansionBand, rightEdge, failureBottom)
        box.set_bgcolor(failedExpansionBand, color.new(failureColor, 88))
        box.set_border_color(failedExpansionBand, color.new(failureColor, 34))
    failureCenterX = int(math.round((activeStartBar + rightEdge) * 0.5))
    failureCenterY = (failureTop + failureBottom) * 0.5
    if na(failureBadge)
        failureBadge := label.new(failureCenterX, failureCenterY, "", xloc = xloc.bar_index, style = label.style_label_center, color = failureColor, textcolor = f_text_on(failureColor), size = labelSize)
    f_set_label(failureBadge, failureCenterX, failureCenterY, failureText, failureColor, label.style_label_center, labelSize)
else
    if not na(failedExpansionBand)
        box.delete(failedExpansionBand)
        failedExpansionBand := na
    if not na(failureBadge)
        label.delete(failureBadge)
        failureBadge := na

if showPlanningRails and activeNow
    edgeColor = plannerState == "Failed Expansion" or plannerState == "Failure Risk" ? dangerColor : activeDir == 1 ? bullColor : bearColor
    fontLaneMult = labelFontSize == "Large" ? 1.25 : labelFontSize == "Small" ? 0.88 : labelFontSize == "Tiny" ? 0.78 : 1.0
    railLaneStep = math.max(atr * 0.82, math.abs(activeEdge - failureRail) * 2.6) * fontLaneMult
    targetGap = math.abs(targetEdge - activeEdge)
    edgeLaneStep = math.min(railLaneStep, math.max(atr * 0.45, targetGap * 0.32))
    edgeLaneY = activeEdge + activeDir * edgeLaneStep
    failureLaneY = failureRail - activeDir * railLaneStep
    railEndX = math.max(activeStartBar + 2, rightEdge - 5)
    if na(edgeLine)
        edgeLine := line.new(activeStartBar, activeEdge, railEndX, activeEdge, xloc = xloc.bar_index, extend = extend.none, color = edgeColor, width = 2)
    else
        line.set_xy1(edgeLine, activeStartBar, activeEdge)
        line.set_xy2(edgeLine, railEndX, activeEdge)
        line.set_color(edgeLine, edgeColor)
    if na(failureLine)
        failureLine := line.new(activeStartBar, failureRail, railEndX, failureRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 0), width = 1, style = line.style_dashed)
    else
        line.set_xy1(failureLine, activeStartBar, failureRail)
        line.set_xy2(failureLine, railEndX, failureRail)
        line.set_color(failureLine, color.new(dangerColor, 0))
    if na(targetLine)
        targetLine := line.new(activeStartBar, targetEdge, rightEdge, targetEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = 1, style = line.style_dotted)
    else
        line.set_xy1(targetLine, activeStartBar, targetEdge)
        line.set_xy2(targetLine, rightEdge, targetEdge)
        line.set_color(targetLine, color.new(accentColor, 0))
    if showRightTags
        if na(edgeLead)
            edgeLead := line.new(railEndX, activeEdge, rightEdge - 1, edgeLaneY, xloc = xloc.bar_index, extend = extend.none, color = edgeColor, width = 2)
        else
            line.set_xy1(edgeLead, railEndX, activeEdge)
            line.set_xy2(edgeLead, rightEdge - 1, edgeLaneY)
            line.set_color(edgeLead, color.new(edgeColor, 18))
        if na(failureLead)
            failureLead := line.new(railEndX, failureRail, rightEdge - 1, failureLaneY, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 18), width = 2)
        else
            line.set_xy1(failureLead, railEndX, failureRail)
            line.set_xy2(failureLead, rightEdge - 1, failureLaneY)
            line.set_color(failureLead, color.new(dangerColor, 18))
        if na(edgeTag)
            edgeTag := label.new(rightEdge, edgeLaneY, "", xloc = xloc.bar_index, style = label.style_label_left, color = edgeColor, textcolor = f_text_on(edgeColor), size = labelSize)
        f_set_label(edgeTag, rightEdge, edgeLaneY, "EDGE " + str.tostring(activeEdge, format.mintick), edgeColor, label.style_label_left, labelSize)
        if na(targetTag)
            targetTag := label.new(rightEdge, targetEdge, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
        f_set_label(targetTag, rightEdge, targetEdge, "TARGET " + str.tostring(targetEdge, format.mintick), accentColor, label.style_label_left, labelSize)
        if na(failureTag)
            failureTag := label.new(rightEdge, failureLaneY, "", xloc = xloc.bar_index, style = label.style_label_left, color = dangerColor, textcolor = f_text_on(dangerColor), size = labelSize)
        f_set_label(failureTag, rightEdge, failureLaneY, "FAIL " + str.tostring(failureRail, format.mintick), dangerColor, label.style_label_left, labelSize)
else
    if not na(edgeLine)
        line.delete(edgeLine)
        edgeLine := na
    if not na(failureLine)
        line.delete(failureLine)
        failureLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na
    if not na(edgeLead)
        line.delete(edgeLead)
        edgeLead := na
    if not na(failureLead)
        line.delete(failureLead)
        failureLead := na
    if not na(edgeTag)
        label.delete(edgeTag)
        edgeTag := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na
    if not na(failureTag)
        label.delete(failureTag)
        failureTag := na

// -------------------------------------------------
// Labels and Markers
// -------------------------------------------------
var int lastLabelBar = na
var string lastPlannerState = ""
var array<label> eventLabels = array.new<label>()

cleanEvent = confirmedBar and plannerState == "Clean Expansion" and lastPlannerState != "Clean Expansion"
reviewEvent = confirmedBar and plannerState == "Expansion Review" and lastPlannerState != "Expansion Review"
failedEvent = confirmedBar and (failureNow or plannerState == "Failed Expansion") and lastPlannerState != "Failed Expansion"
failureRiskEvent = confirmedBar and plannerState == "Failure Risk" and lastPlannerState != "Failure Risk"
targetEvent = confirmedBar and targetReachedNow and lastPlannerState != "Target Room Reached"
retestEvent = confirmedBar and acceptedRetest and not acceptedRetest[1]
rangeWatchEvent = confirmedBar and not activeNow and plannerState == "Range Watch" and lastPlannerState != "Range Watch"
qualityRetestEvent = retestEvent and plannerScore >= reviewScore and retestQualityScore >= 84.0
failurePrintEvent = (failedEvent or failureRiskEvent) and activeAge <= math.max(3, int(math.round(retestLookback * 0.5)))
labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars
drawContext = showContextLabels and contextReady and ((activeNow and not activeFailed and not backInsideRange) or plannerState == "Range Watch")
drawEventLabel = showEventLabels and labelCooldownReady and (newExpansionEvent or qualityRetestEvent or failurePrintEvent or targetEvent or cleanEvent or reviewEvent or rangeWatchEvent or drawContext)

if drawEventLabel
    labelState = plannerState
    if newExpansionEvent
        labelState := "Range Expansion"
    else if qualityRetestEvent
        labelState := "Retest Accepted"
    else if targetEvent
        labelState := "Target Room Reached"
    else if failedEvent
        labelState := "Failure Review"
    else if failureRiskEvent
        labelState := "Failure Risk"
    else if cleanEvent
        labelState := "Clean Expansion"
    else if reviewEvent
        labelState := "Expansion Review"
    else if rangeWatchEvent
        labelState := "Range Watch"
    labelText = labelState
    if showLabelScore and activeNow
        labelText += "\nScore " + str.tostring(plannerScore)
    else if showLabelScore and not activeNow and labelState == "Range Watch"
        labelText += "\nMaturity " + str.tostring(int(math.round(currentRangeMaturityScore)))
    if activeNow and (labelState == "Clean Expansion" or labelState == "Target Room Reached")
        labelText += "\nRoom " + f_fmt(targetRoomAtr) + " ATR"
    riskLabel = labelState == "Failure Review" or labelState == "Failure Risk" or plannerState == "Target Room Blocked"
    labelPlacementDir = activeNow ? riskLabel ? -activeDir : activeDir : calcDir
    stackStep = na(lastLabelBar) ? 0 : bar_index - lastLabelBar <= labelCooldownBars ? 1 : 0
    baseLabelY = labelPlacementDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    labelY = labelPlacementDir == 1 ? baseLabelY - safeAtr * labelStackAtr * stackStep : baseLabelY + safeAtr * labelStackAtr * stackStep
    labelColor = labelState == "Failure Review" ? dangerColor : labelState == "Retest Accepted" ? accentColor : labelState == "Range Expansion" ? (activeDir == 1 ? bullColor : bearColor) : f_state_color(labelState)
    eventLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelPlacementDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 8), textcolor = f_text_on(labelColor), size = labelSize, textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastLabelBar := bar_index

plotshape(showMicroMarkers and cleanEvent and activeDir == 1, title = "Long Clean Expansion Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showMicroMarkers and cleanEvent and activeDir == -1, title = "Short Clean Expansion Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showMicroMarkers and (reviewEvent or qualityRetestEvent), title = "Expansion Review Marker", style = shape.circle, location = location.abovebar, color = color.new(accentColor, 0), size = size.tiny)
plotshape(showMicroMarkers and (failedEvent or failureRiskEvent), title = "Failed Expansion Marker", style = shape.xcross, location = location.abovebar, color = color.new(dangerColor, 0), size = size.tiny)
plotshape(showMicroMarkers and targetEvent, title = "Target Room Marker", style = shape.square, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(plannerScore, title = "Range Expansion Planner Score", color = scoreColor, display = display.data_window)
plot(activeNow ? activeMaturityScore : currentRangeMaturityScore, title = "Range Maturity Score", color = accentColor, display = display.data_window)
plot(activeNow ? activeExpansionCandleScore : candidateExpansionCandleScore, title = "Expansion Candle Score", color = bullColor, display = display.data_window)
plot(currentCloseScore, title = "Close Beyond Edge Score", color = neutralColor, display = display.data_window)
plot(retestQualityScore, title = "Retest Quality Score", color = panelLabelCol, display = display.data_window)
plot(roomRiskScore, title = "Room Risk Score", color = bearColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
theme = panelTheme
panelSize = panelFontSize
targetRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : f_panel_value(theme)
dashBg = f_panel_bg(theme)
frameColor = f_panel_border(theme)
rangeAgeRead = activeNow ? str.tostring(activeRangeAge) + " bars" : str.tostring(priorQuietAge) + " bars"
rangeRead = rangeMaturityState + " / " + str.tostring(int(math.round(activeNow ? activeMaturityScore : currentRangeMaturityScore))) + " / " + rangeAgeRead
riskRead = plannerState + " / " + str.tostring(plannerScore)
roomRead = roomRiskState + " / " + (activeNow ? f_fmt(targetRoomAtr) + " ATR" : "-")
confirmRead = confirmationState + (activeNow ? " / " + f_fmt(closeBeyondActiveAtr) + " ATR" : "")
actionRead = actionState + " / " + directionText

var table panel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

panelNeedsReset = showPanel and (na(panel) or panelLocationCache != panelLocation or panelThemeCache != panelTheme)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
    panelLocationCache := panelLocation
    panelThemeCache := panelTheme

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelLocationCache := ""
    panelThemeCache := ""

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 0, 1, 6)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Range Expansion Risk Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelSize), text_halign = text.align_center)
    f_set_row(panel, 1, "Range Maturity", rangeRead, rangeMaturityState == "Mature" ? bullColor : rangeMaturityState == "Usable" or rangeMaturityState == "Building" ? accentColor : neutralColor, theme, panelSize)
    f_set_row(panel, 2, "Expansion Risk", riskRead, plannerColor, theme, panelSize)
    f_set_row(panel, 3, "Room Risk", roomRead, roomRiskState == "Open room" ? bullColor : roomRiskState == "Blocked" ? dangerColor : neutralColor, theme, panelSize)
    f_set_row(panel, 4, "Confirmation", confirmRead, confirmationState == "Retest accepted" or confirmationState == "Close confirmed" ? bullColor : confirmationState == "Back inside" ? dangerColor : neutralColor, theme, panelSize)
    f_set_row(panel, 5, "Target Rate", targetRateText, targetRateCol, theme, panelSize)
    f_set_row(panel, 6, "Review", actionRead, plannerColor, theme, panelSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(cleanEvent, title = "Clean Range Expansion", message = "Range Expansion Risk Planner: clean range expansion context is active. This is an attention marker, not a trade instruction.")
alertcondition(reviewEvent, title = "Range Expansion Review", message = "Range Expansion Risk Planner: expansion context deserves review, but confirmation or room quality is incomplete.")
alertcondition(retestEvent, title = "Retest Accepted", message = "Range Expansion Risk Planner: price retested and accepted the broken range edge.")
alertcondition(failedEvent or failureRiskEvent, title = "Failed Expansion Warning", message = "Range Expansion Risk Planner: price is back inside the range or has crossed the failure rail. Review risk context.")
alertcondition(targetEvent, title = "Target Room Reached", message = "Range Expansion Risk Planner: price reached the active target-room marker. Review the expansion plan.")

if confirmedBar
    lastPlannerState := plannerState
````
