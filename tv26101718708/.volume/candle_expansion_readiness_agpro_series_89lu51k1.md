# Candle Expansion Readiness [AGPro Series]

- url: https://www.tradingview.com/script/89lU51k1-Candle-Expansion-Readiness-AGPro-Series/
- type: indicator
- pine_id: PUB;b5ae350ef468472984c88566d5141300
- version: 5.0

## Description

Candle Expansion Readiness [AGPro Series]

🧠 Core Idea

Is the current candle expansion meaningful enough to monitor, or is it only a noisy wide candle?


📌 Overview / What it does

Candle Expansion Readiness [AGPro Series] is a chart-first candle quality planner built to evaluate whether an active expansion candle has enough structure to deserve attention.

Instead of treating every wide candle as important, the script studies body efficiency, wick control, relative volume, ATR-normalized expansion, recent range behavior, and close location. These components are converted into a 0-100 Expansion Readiness Score with a clear state: READY, WATCH, FADE RISK, or WAIT.

The script produces expansion candle labels, a forward follow-through box, risk edge, target guide, failure/fade states, alerts, and a clean AGPro planning panel. It does not predict future price movement, automate decisions, or guarantee that an expansion candle will continue.


🎯 Purpose & Design Philosophy

This script was built for traders who want a cleaner way to judge expansion candles before reacting to them.

The gap it fills is practical: many candle tools mark a candle after it appears, but they do not explain whether that candle is efficient, supported, close-positioned, and monitorable. Candle Expansion Readiness turns that moment into a structured planning question.

The design supports a decision-first workflow: read the candle quality, check whether follow-through is developing, identify the risk edge, and decide whether the context deserves more attention.


⚡ Why This Script Is Different

Most tools focus on large candles, volume spikes, engulfing patterns, institutional candle labels, or general breakout signals.

This script does NOT clone Institutional Candle Detector, does not classify candles into institutional taxonomies, does not build an absorption system, and does not act as a generic breakout-volume tool.

Instead, it evaluates the current expansion candle as a readiness event. The output is not a trade command. It is a planning state that helps users separate monitorable expansion from weak, noisy, or fading candle behavior.


⚙️ Methodology

1. Context Detection
The script reads the active candle side from candle direction and close behavior, or lets the user force bullish or bearish readiness mode.

2. Reference Mapping
It maps the expansion candle, risk edge, follow-through window, and target guide.

3. Reaction Evaluation
The model scores body efficiency, wick control, relative volume, ATR expansion, recent range expansion, and directional close location.

4. Visual Output
The result appears through compact labels, candle glow, a forward follow-through box, risk edge, target guide, deterministic alerts, and the AGPro planning panel.


🗺️ How to Read the Chart

Zones = the follow-through box shows the monitored area from the expansion risk edge toward the target guide. Its label is centered inside the box.

Labels = compact markers show READY, WATCH, DOWNGRADE, CONFIRMED, INVALID, or FADED context.

Colors = green highlights stronger bullish readiness or confirmation, pink highlights bearish or invalidated context, amber highlights caution, and indigo highlights watch behavior.

Panel = the panel summarizes Candle Efficiency, Volume Support, Expansion Score, Follow-Through, and Action.


🚦 Signals & States

• READY → candle expansion quality is strong enough to monitor.

• WATCH → candle quality is improving but confirmation is incomplete.

• FADE RISK → the candle expanded, but wick or close behavior is weak.

• CONFIRMED → follow-through reached the active target guide.

• INVALIDATED → price crossed the active risk edge.

• FADED → the follow-through window expired without confirmation.

• WAIT → no strong enough expansion context is active.


🔔 Alerts Logic

Alerts trigger when the planner enters READY state, downgrades from READY or WATCH, crosses the active risk edge, confirms at the target guide, or fades after the follow-through window.

These alerts are attention markers only. They are not trade instructions, entry signals, or automated strategy commands.


🧩 Confluence Logic

The readiness state becomes stronger when body efficiency, close location, relative volume, ATR expansion, and wick control align on the same candle.

When those elements align and the follow-through box remains active without risk-edge violation, the candle context becomes cleaner. When the score is high but follow-through fails, the planner intentionally downgrades the context instead of ignoring the failure.


📊 When to Use

• Active intraday or swing charts where candle expansion matters.

• Breakout attempts where candle quality needs review.

• Continuation moves that require follow-through monitoring.

• Reversal attempts where the trader wants to know whether the impulse candle is efficient or noisy.

• Liquid symbols with reliable OHLC and volume data.


⚠️ When NOT to Use

• Very low-liquidity markets with unreliable candles.

• Extremely noisy sessions where wide candles fail repeatedly.

• Symbols with poor or missing volume data if volume support is central to your workflow.

• News-driven spikes where normal candle-quality rules may lose relevance.

• As a standalone entry system without broader market context.


🎛️ Key Inputs

• Sensitivity → controls how strict the readiness model is.

• Expansion Lookback → compares the current candle to recent range behavior.

• READY Threshold → minimum 0-100 score required for READY state.

• Confirmation Mode → controls whether close quality alone is enough or whether volume/edge confirmation is required.

• Follow-Through Bars → defines how long the script monitors the active expansion.

• Risk Edge Buffer ATR → moves the invalidation reference slightly beyond the candle edge.

• Visual settings → control boxes, risk edge, target guide, candle glow, labels, panel theme, and font sizes.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The panel gives the current decision state without becoming a crowded dashboard. The follow-through box creates a clean visual planning area, while compact labels keep the chart active without burying price candles.

The first panel row follows the AGPro merged blue header standard and shows only the script name.


🧪 Practical Usage Workflow

1. Read the Expansion Score and Action row.

2. Check whether the candle is READY, WATCH, or FADE RISK.

3. If READY appears, inspect the follow-through box and risk edge.

4. Watch whether price confirms, fades, or invalidates.

5. Interpret the result within your broader structure, liquidity, and risk plan.


🔍 Interpretation Guidelines

Think of the script as a candle expansion planner, not a signal caller.

A READY candle deserves attention because its structure is cleaner than average. A WATCH candle needs more evidence. A FADE RISK candle warns that expansion exists, but the candle quality is not clean. INVALIDATED and FADED states are part of the workflow because failed expansion is useful information.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not an institutional candle detector.

• Not an order block, fair value gap, or support/resistance map.


⚠️ Limitations & Transparency

• Timeframe differences can change how expansion candles appear.

• Volatility spikes can temporarily distort candle-quality readings.

• Volume data may differ by exchange, broker, symbol, and feed.

• Follow-through is evaluated through a fixed monitoring window.

• Market conditions can shift after a READY candle appears.


🧠 Market Context Notes

Candle expansion is most useful when interpreted with liquidity, structure, volatility, and location.

The script focuses on the candle itself and the immediate follow-through plan. Traders should still consider broader trend context, nearby levels, session behavior, and event risk.


🧾 Use Case Examples

When a bullish candle closes near its high with strong body efficiency and relative volume, the script may mark READY and project a follow-through box above the risk edge.

When a wide candle has heavy wick behavior and poor close location, the script may flag FADE RISK instead of treating the candle as clean expansion.

When a READY candle fails back through its risk edge, the active plan becomes INVALIDATED.


🧱 System Philosophy

AGPro tools are designed to support structured chart reading. The goal is to convert market behavior into clean, rule-based context that helps traders think more clearly.

Candle Expansion Readiness follows that philosophy by turning a single expansion candle into a monitored planning state.


🔐 Non-Promise Statement

No script can provide certainty.

This tool organizes candle expansion context, but it does not guarantee continuation, reversal, profit, or any specific market outcome.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, execution, position sizing, and risk management.

Nothing in this script or description is financial advice.


📚 Educational Note

Use the script to study how clean expansion candles behave across different symbols and timeframes. The value is in comparing candle quality, follow-through, and failure behavior over time.

## Source Code

````pine
// -------------------------------------------------
// Candle Expansion Readiness [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Candle Expansion Readiness is a chart-first candle quality planner that
// evaluates whether an expansion candle has enough body efficiency, wick
// control, relative volume, ATR expansion, and close-location quality to
// deserve active monitoring. It produces a 0-100 readiness score, compact
// follow-through map, risk edge, target guide, and next-action panel.
// Version 1.3 adds a confirmation-anchored proof layer (Follow, Hold, React,
// Flip rates) showing how often Ready expansion candles followed through
// toward the target guide before the risk edge was lost.
// Version 1.5 gives the live map enough visual width for its centered badge,
// removes duplicate in-map events, and spaces historical labels more evenly.
// -------------------------------------------------

//@version=6
indicator("Candle Expansion Readiness [AGPro Series]",
     shorttitle = "AG CER",
     overlay = true,
     max_labels_count = 240,
     max_boxes_count = 80,
     max_lines_count = 160)

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
ttSide = "Selects how the active candle side is read. Auto uses the candle body direction and close behavior. Manual modes force bullish or bearish expansion planning."
ttConfirm = "When enabled, readiness states, labels, boxes, and alerts wait for bar close. This keeps public chart behavior stable."
ttSensitivity = "Controls the internal strictness used by the readiness model. Strict requires cleaner candle structure; Active allows more monitoring events."
ttAtrLen = "ATR length used for expansion normalization, label offset, risk edge padding, and target guide calculations."
ttVolumeLen = "Volume average length used to calculate relative volume support. When volume is unavailable, the volume component becomes neutral."
ttScoreLookback = "Lookback used to compare current candle range against recent candle behavior. This is a candle expansion model, not a breakout range scanner."
ttFollowBars = "Number of bars used to monitor whether an expansion candle confirms, fades, or violates its risk edge."
ttRiskBuffer = "ATR buffer added beyond the expansion candle opposite edge. It keeps the risk edge from sitting exactly on the candle extreme."
ttTargetBody = "Body multiple projected from the expansion close to form the forward follow-through target guide. This is a planning reference only."
ttReady = "Minimum 0-100 score required for Ready state. Ready means the candle is strong enough to monitor, not that a trade should be taken."
ttWatch = "Minimum 0-100 score required for Watch state. Watch means candle quality is improving but not yet clean enough for Ready."
ttConfirmMode = "Adds an optional confirmation gate to Ready state. Volume mode requires stronger participation; edge mode requires a stronger directional close."
ttBoxes = "Shows the forward follow-through box from the expansion candle toward the target guide. The zone uses a separate centered contrast badge."
ttRisk = "Shows the active risk edge behind the expansion candle. It is an invalidation reference for the planner, not a stop recommendation."
ttTarget = "Shows the forward target guide used to evaluate major follow-through confirmation."
ttLevelTags = "Shows compact right-side Risk and Target tags. These tags use the same chart label font size as every other label."
ttGlow = "Colors Ready and Watch expansion candles lightly so candle quality can be read without adding a separate signal system."
ttFade = "When enabled, failed or faded expansion plans are visually softened with a faded follow-through box."
ttBoxOpacity = "Transparency for follow-through boxes. Higher values make the box lighter."
ttLabels = "Shows compact Ready, Watch, Confirmed, Invalid, Faded, and context labels. Labels are offset away from candle bodies."
ttContextLabels = "Adds sparse context labels during ongoing Ready or Watch behavior so the chart does not look empty while remaining controlled."
ttMarkers = "Shows tiny event markers in addition to labels. Disabled by default because labels and follow-through boxes already carry the public chart story."
ttCooldown = "Minimum bars between event labels. Higher values reduce chart density."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing readiness states."
ttMaxObjects = "Maximum retained event labels. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles instead of buried inside bars."
ttShowScore = "Adds the 0-100 readiness score to chart labels."
ttLabelSize = "Font size for all chart labels, level tags, and centered follow-through zone badges. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AGPro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
ttPanelFont = "Font size for the AGPro panel. Normal is the recommended publication default."
ttProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across Ready expansion candles on the current symbol and timeframe. Follow means a Ready candle continued one risk unit (1R) toward the target guide before the risk edge was lost. These are historical outcome rates, not predictions."
ttProofHorizon = "Maximum number of bars each Ready candle is tracked for the proof measurement before it resolves at its current outcome."
ttReactBars = "Number of bars after a Ready candle used to detect an immediate favorable follow-through reaction."
ttReactProgress = "Minimum favorable follow-through progress toward the 1R target, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Readiness Engine"
sideMode = input.string("Auto", "Expansion Side", options = ["Auto", "Bullish Readiness", "Bearish Readiness"], group = groupEngine, tooltip = ttSide)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirm)
sensitivity = input.string("Balanced", "Sensitivity", options = ["Strict", "Balanced", "Active"], group = groupEngine, tooltip = ttSensitivity)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
volumeLen = input.int(34, "Volume Support Length", minval = 5, maxval = 240, group = groupEngine, tooltip = ttVolumeLen)
scoreLookback = input.int(24, "Expansion Lookback", minval = 8, maxval = 180, group = groupEngine, tooltip = ttScoreLookback)
followThroughBars = input.int(5, "Follow-Through Bars", minval = 2, maxval = 30, group = groupEngine, tooltip = ttFollowBars)
riskBufferAtr = input.float(0.12, "Risk Edge Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupEngine, tooltip = ttRiskBuffer)
targetBodyMultiple = input.float(1.15, "Target Body Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupEngine, tooltip = ttTargetBody)

groupScoring = "Readiness Scoring"
readyThreshold = input.int(72, "Ready Threshold", minval = 45, maxval = 95, group = groupScoring, tooltip = ttReady)
watchThreshold = input.int(56, "Watch Threshold", minval = 25, maxval = 90, group = groupScoring, tooltip = ttWatch)
confirmationMode = input.string("Close Quality", "Confirmation Mode", options = ["Close Quality", "Close + Volume", "Close + Edge"], group = groupScoring, tooltip = ttConfirmMode)

groupVisual = "Chart Visuals"
showFollowThroughBox = input.bool(true, "Show Follow-Through Box", group = groupVisual, tooltip = ttBoxes)
showRiskEdge = input.bool(true, "Show Risk Edge", group = groupVisual, tooltip = ttRisk)
showTargetGuide = input.bool(true, "Show Target Guide", group = groupVisual, tooltip = ttTarget)
showLevelTags = input.bool(true, "Show Risk / Target Tags", group = groupVisual, tooltip = ttLevelTags)
showCandleGlow = input.bool(true, "Show Candle Glow", group = groupVisual, tooltip = ttGlow)
showFailureFade = input.bool(true, "Show Failed Expansion Fade", group = groupVisual, tooltip = ttFade)
boxTransparency = input.int(88, "Box Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttBoxOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
showEventMarkers = input.bool(false, "Show Tiny Event Markers", group = groupLabels, tooltip = ttMarkers)
labelCooldownBars = input.int(36, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(54, "Context Label Spacing", minval = 6, maxval = 220, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleObjects = input.int(8, "Max Visible Event Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxObjects)
labelOffsetAtr = input.float(1.15, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttShowScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttProof)
proofHorizonBars = input.int(12, "Proof Horizon Bars", minval = 3, maxval = 120, group = groupProof, tooltip = ttProofHorizon)
reactBars = input.int(2, "Reaction Window Bars", minval = 1, maxval = 30, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

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
    value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)

f_label_size(string sizeText) =>
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
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    evenRow = row % 2 == 0
    theme == "Light" ? (evenRow ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_state_color(string stateText, int side) =>
    switch stateText
        "Ready" => side == 1 ? bullColor : bearColor
        "Watch" => accentColor
        "Fade Risk" => neutralColor
        "Wait" => neutralColor
        "Confirmed" => bullColor
        "Invalidated" => bearColor
        "Faded" => neutralColor
        => panelLabelCol

f_score_color(int scoreValue, int side) =>
    scoreValue >= readyThreshold ? (side == 1 ? bullColor : bearColor) :
     scoreValue >= watchThreshold ? accentColor :
     scoreValue >= 40 ? neutralColor :
     bearColor

f_grade(int scoreValue) =>
    scoreValue >= 85 ? "A+" : scoreValue >= 72 ? "A" : scoreValue >= 56 ? "B" : scoreValue >= 40 ? "C" : "D"

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize, color rightBg) =>
    rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rightBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_workflow(string stateText, string outcomeText) =>
    outcomeText == "CONFIRMED" ? "Review Confirmation" :
     outcomeText == "INVALIDATED" ? "Review Risk Edge" :
     outcomeText == "FADED" ? "Review Fade" :
     stateText == "Ready" ? "Track Expansion" :
     stateText == "Watch" ? "Watch Candle" :
     stateText == "Fade Risk" ? "Review Quality" :
     "Standby"

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
labelSize = f_label_size(labelSizeInput)
panelTextSize = f_label_size(panelFontSizeInput)
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
candleRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
totalWick = upperWick + lowerWick
bodyPct = body / candleRange
wickPct = totalWick / candleRange
closeLocation = (close - low) / candleRange
candleRangeAtr = candleRange / safeAtr

avgRange = ta.sma(high - low, scoreLookback)
rangeExpansionRatio = not na(avgRange) and avgRange > 0.0 ? candleRange / avgRange : 1.0
volumeAvg = ta.sma(volume, volumeLen)
volumeSupported = not na(volume) and volume > 0.0 and not na(volumeAvg) and volumeAvg > 0.0
rvol = volumeSupported ? volume / volumeAvg : 1.0

candleDir = close > open ? 1 : close < open ? -1 : close >= nz(close[1], close) ? 1 : -1
planDir = sideMode == "Bullish Readiness" ? 1 : sideMode == "Bearish Readiness" ? -1 : candleDir
directionalCloseLocation = planDir == 1 ? closeLocation : 1.0 - closeLocation
directionalWickPct = planDir == 1 ? upperWick / candleRange : lowerWick / candleRange
oppositeEdge = planDir == 1 ? low : high
riskEdgeNow = planDir == 1 ? oppositeEdge - safeAtr * riskBufferAtr : oppositeEdge + safeAtr * riskBufferAtr
targetGuideNow = close + planDir * math.max(body * targetBodyMultiple, safeAtr * 0.35)

bodyWeak = sensitivity == "Strict" ? 0.50 : sensitivity == "Active" ? 0.34 : 0.42
bodyStrong = sensitivity == "Strict" ? 0.82 : sensitivity == "Active" ? 0.70 : 0.76
closeWeak = sensitivity == "Strict" ? 0.66 : sensitivity == "Active" ? 0.54 : 0.60
closeStrong = sensitivity == "Strict" ? 0.92 : sensitivity == "Active" ? 0.80 : 0.86
rangeWeak = sensitivity == "Strict" ? 0.95 : sensitivity == "Active" ? 0.65 : 0.78
rangeIdeal = sensitivity == "Strict" ? 1.65 : sensitivity == "Active" ? 1.35 : 1.50
rangeHot = sensitivity == "Strict" ? 2.80 : sensitivity == "Active" ? 3.40 : 3.10
rvolWeak = sensitivity == "Strict" ? 0.95 : sensitivity == "Active" ? 0.65 : 0.78
rvolStrong = sensitivity == "Strict" ? 1.80 : sensitivity == "Active" ? 1.35 : 1.55

bodyEfficiencyScore = f_norm_high_good(bodyPct, bodyWeak, bodyStrong)
wickControlScore = f_norm_low_good(math.max(wickPct, directionalWickPct * 1.35), 0.18, 0.62)
volumeSupportScore = volumeSupported ? f_norm_high_good(rvol, rvolWeak, rvolStrong) : 55.0
atrExpansionScore = f_peak_score(candleRangeAtr, rangeWeak, rangeIdeal, rangeHot)
closeLocationScore = f_norm_high_good(directionalCloseLocation, closeWeak, closeStrong)
rangeContextScore = f_peak_score(rangeExpansionRatio, 0.80, 1.45, 3.00)

readinessRaw = bodyEfficiencyScore * 0.24 + wickControlScore * 0.16 + volumeSupportScore * 0.20 + atrExpansionScore * 0.18 + closeLocationScore * 0.17 + rangeContextScore * 0.05
readinessScore = int(math.round(f_clamp(readinessRaw, 0.0, 100.0)))

closeQualityGate = closeLocationScore >= 45.0 and bodyEfficiencyScore >= 35.0
volumeGate = confirmationMode != "Close + Volume" or volumeSupportScore >= 54.0
edgeGate = confirmationMode != "Close + Edge" or (planDir == 1 ? close > high[1] : close < low[1])
readyCandidate = readinessScore >= readyThreshold and closeQualityGate and volumeGate and edgeGate
watchCandidate = readinessScore >= watchThreshold and closeQualityGate and not readyCandidate
fadeRiskCandidate = candleRangeAtr >= 1.10 and readinessScore < watchThreshold and (wickControlScore < 42.0 or closeLocationScore < 42.0)
confirmedBar = not confirmOnClose or barstate.isconfirmed

readinessState = "Wait"
if readyCandidate
    readinessState := "Ready"
else if watchCandidate
    readinessState := "Watch"
else if fadeRiskCandidate
    readinessState := "Fade Risk"

sideText = planDir == 1 ? "Bullish" : "Bearish"
actionText = readinessState == "Ready" ? "Monitor Follow-Through" : readinessState == "Watch" ? "Wait Cleaner Expansion" : readinessState == "Fade Risk" ? "Review Weak Candle" : "Wait"
readinessColor = f_state_color(readinessState, planDir)

// -------------------------------------------------
// Active plan tracking
// -------------------------------------------------
var int activeEventBar = na
var int activeDir = 0
var int activePlanScore = na
var float activeRiskEdge = na
var float activeTargetGuide = na
var string activeOutcome = "NONE"
var box activeBox = na
var label activeBoxLabel = na
var line activeRiskLine = na
var line activeTargetLine = na
var label riskTag = na
var label targetTag = na
var array<label> eventLabels = array.new<label>()
var string lastReadinessState = ""
var int lastLabelBar = na
var int lastContextLabelBar = na
var int lastPlanBar = na

hasActivePlan = not na(activeEventBar) and activeOutcome == "MONITOR"
activeAge = not na(activeEventBar) ? bar_index - activeEventBar : 0
activeInvalidated = hasActivePlan and (activeDir == 1 ? close < activeRiskEdge : close > activeRiskEdge)
activeConfirmed = hasActivePlan and (activeDir == 1 ? close >= activeTargetGuide or high >= activeTargetGuide : close <= activeTargetGuide or low <= activeTargetGuide)
activeFaded = hasActivePlan and activeAge > followThroughBars and not activeConfirmed and not activeInvalidated

invalidationEvent = false
confirmationEvent = false
fadeEvent = false

if confirmedBar and hasActivePlan
    if activeInvalidated
        activeOutcome := "INVALIDATED"
        invalidationEvent := true
    else if activeConfirmed
        activeOutcome := "CONFIRMED"
        confirmationEvent := true
    else if activeFaded
        activeOutcome := "FADED"
        fadeEvent := true

followText = "No Active Plan"
followColor = panelLabelCol
if activeOutcome == "MONITOR"
    followText := "M " + str.tostring(math.min(activeAge, followThroughBars)) + "/" + str.tostring(followThroughBars)
    followColor := accentColor
else if activeOutcome == "CONFIRMED"
    followText := "Confirmed"
    followColor := bullColor
else if activeOutcome == "INVALIDATED"
    followText := "Invalid"
    followColor := bearColor
else if activeOutcome == "FADED"
    followText := "Faded"
    followColor := neutralColor

readyEvent = confirmedBar and readinessState == "Ready" and lastReadinessState != "Ready"
watchEvent = confirmedBar and readinessState == "Watch" and lastReadinessState != "Watch"
downgradeEvent = confirmedBar and (lastReadinessState == "Ready" or lastReadinessState == "Watch") and (readinessState == "Fade Risk" or readinessState == "Wait")
planSpacingReady = na(lastPlanBar) or bar_index - lastPlanBar >= followThroughBars
outcomeEvent = invalidationEvent or confirmationEvent or fadeEvent
startPlan = confirmedBar and readinessState == "Ready" and planSpacingReady and not outcomeEvent and (not hasActivePlan or activeOutcome != "MONITOR")

// -------------------------------------------------
// Confirmation-anchored proof (Ready candles, Follow = continued 1R toward target before risk edge lost)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false
var bool pFlipped = false

int proofWarmup = math.max(scoreLookback, math.max(volumeLen, atrLen)) + 5
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favExc = pEvalDir * (close - pEvalEntry)
        if heldBars >= 1 and heldBars <= reactBars and favExc >= followDist * reactProgressPct / 100.0
            pReacted := true
        bool stopBreached = pEvalDir == 1 ? close < pEvalStop : close > pEvalStop
        bool hitTarget = heldBars >= 1 and favExc >= followDist
        if stopBreached
            pFlipped := true
        bool followNow = hitTarget and not pFlipped
        if followNow
            pFollowed := true
        bool naturalResolve = pFlipped or followNow or heldBars >= proofHorizonBars
        if naturalResolve or readyEvent
            proofTotal := proofTotal + 1
            if pFollowed
                proofFollow := proofFollow + 1
            if not pFlipped
                proofHold := proofHold + 1
            if pReacted
                proofReact := proofReact + 1
            if pFlipped
                proofFlip := proofFlip + 1
            pEvalActive := false
    if readyEvent and not pEvalActive and planDir != 0
        pEvalActive := true
        pEvalDir := planDir
        pEvalEntry := close
        pEvalStop := riskEdgeNow
        float pStopDist = math.max(math.abs(close - riskEdgeNow), syminfo.mintick)
        float pRoomDist = math.max(math.abs(targetGuideNow - close), syminfo.mintick)
        float pFollowDist = math.max(math.min(pStopDist, pRoomDist), syminfo.mintick)
        pEvalTarget := close + planDir * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

if startPlan
    if not na(activeBox)
        box.delete(activeBox)
    if not na(activeBoxLabel)
        label.delete(activeBoxLabel)
    if not na(activeRiskLine)
        line.delete(activeRiskLine)
    if not na(activeTargetLine)
        line.delete(activeTargetLine)
    if not na(riskTag)
        label.delete(riskTag)
    if not na(targetTag)
        label.delete(targetTag)
    activeEventBar := bar_index
    activeDir := planDir
    activePlanScore := readinessScore
    activeRiskEdge := riskEdgeNow
    activeTargetGuide := targetGuideNow
    activeOutcome := "MONITOR"
    lastPlanBar := bar_index
    topBox = math.max(activeRiskEdge, activeTargetGuide)
    bottomBox = math.min(activeRiskEdge, activeTargetGuide)
    rightBox = activeEventBar + math.max(followThroughBars, 9)
    planColor = planDir == 1 ? bullColor : bearColor
    followText := "M 0/" + str.tostring(followThroughBars)
    followColor := accentColor
    if showFollowThroughBox
        activeBox := box.new(left = activeEventBar, top = topBox, right = rightBox, bottom = bottomBox, xloc = xloc.bar_index, bgcolor = color.new(planColor, boxTransparency), border_color = color.new(planColor, 42), border_width = 1)
    if showRiskEdge
        activeRiskLine := line.new(activeEventBar, activeRiskEdge, rightBox, activeRiskEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 0), width = 2, style = line.style_dashed)
    if showTargetGuide
        activeTargetLine := line.new(activeEventBar, activeTargetGuide, rightBox, activeTargetGuide, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = 1, style = line.style_dotted)

if not na(activeBox)
    rightBoxLive = activeEventBar + math.max(followThroughBars, 9)
    boxColor = activeOutcome == "CONFIRMED" ? bullColor : activeOutcome == "INVALIDATED" ? bearColor : activeOutcome == "FADED" ? neutralColor : activeDir == 1 ? bullColor : bearColor
    activeTransparency = showFailureFade and (activeOutcome == "INVALIDATED" or activeOutcome == "FADED") ? math.min(boxTransparency + 4, 96) : boxTransparency
    box.set_left(activeBox, activeEventBar)
    box.set_right(activeBox, rightBoxLive)
    box.set_top(activeBox, math.max(activeRiskEdge, activeTargetGuide))
    box.set_bottom(activeBox, math.min(activeRiskEdge, activeTargetGuide))
    box.set_bgcolor(activeBox, color.new(boxColor, activeTransparency))
    box.set_border_color(activeBox, color.new(boxColor, 35))
    if showFollowThroughBox
        labelText = activeOutcome == "MONITOR" ? "Expansion S " + str.tostring(activePlanScore) + "\n" + followText : activeOutcome == "CONFIRMED" ? "Confirmed | S " + str.tostring(activePlanScore) : activeOutcome == "INVALIDATED" ? "Invalidated | S " + str.tostring(activePlanScore) : "Faded | S " + str.tostring(activePlanScore)
        labelX = int(math.round((activeEventBar + rightBoxLive) / 2.0))
        labelY = (activeRiskEdge + activeTargetGuide) * 0.5
        if na(activeBoxLabel)
            activeBoxLabel := label.new(labelX, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(boxColor, 0), textcolor = f_text_on(boxColor), size = labelSize, textalign = text.align_center, tooltip = "Centered expansion map badge. It summarizes readiness and follow-through context without acting as a trade instruction.")
        else
            label.set_xy(activeBoxLabel, labelX, labelY)
            label.set_text(activeBoxLabel, labelText)
            label.set_color(activeBoxLabel, color.new(boxColor, 0))
            label.set_textcolor(activeBoxLabel, f_text_on(boxColor))
            label.set_size(activeBoxLabel, labelSize)

if not showFollowThroughBox
    if not na(activeBox)
        box.delete(activeBox)
        activeBox := na
    if not na(activeBoxLabel)
        label.delete(activeBoxLabel)
        activeBoxLabel := na

tagX = not na(activeEventBar) ? math.max(bar_index + 3, activeEventBar + math.max(followThroughBars, 9) + 2) : bar_index + 3
if not na(activeRiskLine)
    riskColor = activeOutcome == "INVALIDATED" ? bearColor : activeOutcome == "CONFIRMED" ? bullColor : neutralColor
    line.set_xy1(activeRiskLine, activeEventBar, activeRiskEdge)
    line.set_xy2(activeRiskLine, showLevelTags ? tagX : activeEventBar + math.max(followThroughBars, 9), activeRiskEdge)
    line.set_color(activeRiskLine, color.new(riskColor, 0))

if not na(activeTargetLine)
    targetColor = activeOutcome == "CONFIRMED" ? bullColor : accentColor
    line.set_xy1(activeTargetLine, activeEventBar, activeTargetGuide)
    line.set_xy2(activeTargetLine, showLevelTags ? tagX : activeEventBar + math.max(followThroughBars, 9), activeTargetGuide)
    line.set_color(activeTargetLine, color.new(targetColor, 0))

if barstate.islast and showLevelTags and not na(activeEventBar) and activeOutcome != "NONE"
    levelColor = activeDir == 1 ? bullColor : bearColor
    if showRiskEdge and not na(activeRiskEdge)
        riskText = "Risk " + f_price(activeRiskEdge)
        if na(riskTag)
            riskTag := label.new(tagX, activeRiskEdge, riskText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 0), textcolor = darkText, size = labelSize, tooltip = "Risk edge reference for the active candle expansion plan.")
        else
            label.set_xy(riskTag, tagX, activeRiskEdge)
            label.set_text(riskTag, riskText)
            label.set_color(riskTag, color.new(neutralColor, 0))
            label.set_textcolor(riskTag, darkText)
            label.set_size(riskTag, labelSize)
    if showTargetGuide and not na(activeTargetGuide)
        targetText = "Target " + f_price(activeTargetGuide)
        if na(targetTag)
            targetTag := label.new(tagX, activeTargetGuide, targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = labelSize, tooltip = "Target guide reference for follow-through review.")
        else
            label.set_xy(targetTag, tagX, activeTargetGuide)
            label.set_text(targetTag, targetText)
            label.set_color(targetTag, color.new(accentColor, 0))
            label.set_textcolor(targetTag, headerText)
            label.set_size(targetTag, labelSize)
else if barstate.islast
    if not na(riskTag)
        label.delete(riskTag)
        riskTag := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na

// -------------------------------------------------
// Chart coloring and labels
// -------------------------------------------------
color candleColor = na
if showCandleGlow and readinessState == "Ready"
    candleColor := color.new(readinessColor, 58)
else if showCandleGlow and readinessState == "Watch"
    candleColor := color.new(accentColor, 76)
else if showFailureFade and readinessState == "Fade Risk"
    candleColor := color.new(neutralColor, 82)
barcolor(candleColor)

labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
contextReady = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars
drawContext = showContextLabels and contextReady and not labelCooldownReady and (readinessState == "Ready" or readinessState == "Watch")
insideActiveMap = not na(activeEventBar) and bar_index >= activeEventBar and bar_index <= activeEventBar + math.max(followThroughBars, 9)
activeMapOwnsEvent = insideActiveMap and not readyEvent
drawEventLabel = showEventLabels and not activeMapOwnsEvent and ((labelCooldownReady and (readyEvent or watchEvent or downgradeEvent or invalidationEvent or confirmationEvent or fadeEvent)) or drawContext)

if drawEventLabel
    labelState = confirmationEvent ? "Confirmed" : invalidationEvent ? "Invalidated" : fadeEvent ? "Faded" : downgradeEvent ? "Fade Risk" : readinessState
    labelText = labelState
    if showLabelScore and (labelState == "Ready" or labelState == "Watch")
        labelText := labelText + "\nS " + str.tostring(readinessScore)
    else if labelState == "Confirmed"
        labelText := "Confirmed\nTarget"
    else if labelState == "Invalidated"
        labelText := "Invalid\nRisk"
    else if labelState == "Faded"
        labelText := "Faded\nNo Follow"
    else if labelState == "Fade Risk"
        labelText := "Fade Risk\nS " + str.tostring(readinessScore)
    labelEventDir = (confirmationEvent or invalidationEvent or fadeEvent) and activeDir != 0 ? activeDir : planDir
    eventOffset = confirmationEvent or invalidationEvent or fadeEvent ? labelOffsetAtr * 1.24 : drawContext ? labelOffsetAtr * 0.72 : labelOffsetAtr
    labelY = labelEventDir == 1 ? low - safeAtr * eventOffset : high + safeAtr * eventOffset
    labelColor = confirmationEvent ? bullColor : invalidationEvent ? bearColor : fadeEvent or downgradeEvent ? neutralColor : readinessColor
    tipText = "Candle Expansion Readiness\nScore: " + str.tostring(readinessScore) + "\nSide: " + sideText + "\nBody Efficiency: " + str.tostring(math.round(bodyEfficiencyScore)) + "\nVolume Support: " + str.tostring(math.round(volumeSupportScore)) + "\nFollow-Through: " + followText + "\nAction: " + actionText
    eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelEventDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(labelColor, 4), textcolor = f_text_on(labelColor), size = labelSize, tooltip = tipText, textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleObjects)
    if drawContext
        lastContextLabelBar := bar_index
    else
        lastLabelBar := bar_index

plotshape(showEventMarkers and readyEvent and planDir == 1, title = "Bullish Ready Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showEventMarkers and readyEvent and planDir == -1, title = "Bearish Ready Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showEventMarkers and (watchEvent or downgradeEvent), title = "Candle Expansion Watch Marker", style = shape.circle, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)
plotshape(showEventMarkers and (invalidationEvent or fadeEvent), title = "Expansion Failure Marker", style = shape.xcross, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showEventMarkers and confirmationEvent, title = "Expansion Confirmation Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(readinessScore, title = "Expansion Readiness Score", color = readinessColor, display = display.data_window)
plot(bodyEfficiencyScore, title = "Body Efficiency Score", color = bullColor, display = display.data_window)
plot(wickControlScore, title = "Wick Control Score", color = neutralColor, display = display.data_window)
plot(volumeSupportScore, title = "Volume Support Score", color = accentColor, display = display.data_window)
plot(atrExpansionScore, title = "ATR Expansion Score", color = bearColor, display = display.data_window)
plot(closeLocationScore, title = "Close Location Score", color = panelLabelCol, display = display.data_window)
plot(followRate, title = "CER Follow Rate", display = display.none)
plot(holdRate, title = "CER Hold Rate", display = display.none)
plot(reactRate, title = "CER React Rate", display = display.none)
plot(flipRate, title = "CER Flip Rate", display = display.none)

// -------------------------------------------------
// Panel
// -------------------------------------------------
theme = panelThemeInput
panelSize = panelFontSizeInput
dashBg = f_panel_bg(theme)
frameColor = f_panel_border(theme)
panelValueActive = f_panel_value(theme)

workflowRead = f_workflow(readinessState, activeOutcome)
bodyRead = str.tostring(math.round(bodyEfficiencyScore)) + " / " + str.tostring(bodyPct * 100.0, "#") + "%"
wickRead = str.tostring(math.round(wickControlScore)) + " / Wick"
volumeRead = volumeSupported ? str.tostring(math.round(volumeSupportScore)) + " / " + str.tostring(rvol, "0.00") + "x" : "Neutral"
scoreRead = str.tostring(readinessScore) + "/100 " + f_grade(readinessScore)
riskTargetRead = not na(activeEventBar) and activeOutcome != "NONE" ? f_price(activeRiskEdge) + " / " + f_price(activeTargetGuide) : "-"
scoreColor = f_score_color(readinessScore, planDir)
statePanelColor = readinessState == "Wait" ? scoreColor : readinessColor
stateBg = color.new(statePanelColor, theme == "Light" ? 74 : 18)
scoreBg = color.new(scoreColor, theme == "Light" ? 78 : 24)

proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
followTextPanel = proofTotal > 0 ? f_pct(followRate) : "-"
holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "-"
reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "-"
flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "-"
proofDefaultCol = f_panel_value(theme)
followCol = proofTotal > 0 ? f_rate_color(followRate) : proofDefaultCol
holdCol = proofTotal > 0 ? f_rate_color(holdRate) : proofDefaultCol
reactCol = proofTotal > 0 ? f_rate_color(reactRate) : proofDefaultCol
flipCol = proofTotal > 0 ? f_flip_color(flipRate) : proofDefaultCol

panelRowCount = showProof ? 12 : 7
var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

panelNeedsReset = showPanel and (na(panel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or showPanel != lastPanelVisible or showProof != lastProofMode)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Candle Expansion Readiness", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelVisible := showPanel
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 1, 1, panelRowCount - 1)
    table.cell(panel, 0, 0, "AG Pro Candle Expansion Readiness", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    f_set_row(panel, 1, "Workflow", workflowRead, statePanelColor, theme, panelSize, f_row_bg(theme, 1))
    f_set_row(panel, 2, "State", readinessState + " / " + sideText, f_text_on(stateBg), theme, panelSize, stateBg)
    f_set_row(panel, 3, "Readiness", scoreRead, f_text_on(scoreBg), theme, panelSize, scoreBg)
    f_set_row(panel, 4, "Body / Wick", bodyRead + " | " + wickRead, bodyEfficiencyScore >= 65.0 ? bullColor : bodyEfficiencyScore >= 45.0 ? neutralColor : bearColor, theme, panelSize, f_row_bg(theme, 4))
    f_set_row(panel, 5, "Volume", volumeRead, volumeSupportScore >= 65.0 ? bullColor : volumeSupportScore >= 45.0 ? neutralColor : bearColor, theme, panelSize, f_row_bg(theme, 5))
    f_set_row(panel, 6, "Follow / Edge", followText + " | " + riskTargetRead, followColor, theme, panelSize, f_row_bg(theme, 6))
    if showProof
        proofHeadBg = f_row_bg(theme, 7)
        table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_label_size(panelSize), text_halign = text.align_left)
        table.cell(panel, 1, 7, proofSampleText, text_color = f_panel_label(theme), bgcolor = proofHeadBg, text_size = f_label_size(panelSize), text_halign = text.align_right)
        f_set_row(panel, 8, "Follow Rate", followTextPanel, followCol, theme, panelSize, f_row_bg(theme, 8))
        f_set_row(panel, 9, "Hold Rate", holdTextPanel, holdCol, theme, panelSize, f_row_bg(theme, 9))
        f_set_row(panel, 10, "React Rate", reactTextPanel, reactCol, theme, panelSize, f_row_bg(theme, 10))
        f_set_row(panel, 11, "Flip Rate", flipTextPanel, flipCol, theme, panelSize, f_row_bg(theme, 11))

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(readyEvent, title = "Candle Expansion Ready", message = "Candle Expansion Readiness: Ready state is active. Monitor follow-through and risk edge. This is an attention marker, not a trade instruction.")
alertcondition(downgradeEvent, title = "Candle Expansion Downgrade", message = "Candle Expansion Readiness: readiness downgraded from Ready or Watch. Review candle quality before acting.")
alertcondition(invalidationEvent, title = "Candle Expansion Invalidated", message = "Candle Expansion Readiness: price crossed the active risk edge. Review the expansion plan.")
alertcondition(confirmationEvent, title = "Candle Expansion Confirmed", message = "Candle Expansion Readiness: follow-through reached the target guide. This is an attention marker, not a trade instruction.")
alertcondition(fadeEvent, title = "Candle Expansion Faded", message = "Candle Expansion Readiness: the active expansion did not confirm within the follow-through window.")

if confirmedBar
    lastReadinessState := readinessState
````
