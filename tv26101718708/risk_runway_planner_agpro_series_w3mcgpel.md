# Risk Runway Planner [AGPro Series]

- url: https://www.tradingview.com/script/W3McGPel-Risk-Runway-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;36948ea1cc214771bd2a29d0e9e42e7c
- version: 6.0

## Description

Risk Runway Planner [AGPro Series]

🧠 Core Idea

Is the current setup offering a clean risk runway, or is risk too wide, too blocked, or still too early?


📌 Overview / What it does

Risk Runway Planner [AGPro Series] is a chart-first risk planning and execution readiness tool designed to evaluate whether a setup has enough structure to deserve active attention.

Instead of printing generic buy or sell signals, the script studies stop-distance quality, invalidation clarity, expansion room, volatility state, trend support, and price location. It then converts those factors into a 0-100 quality score and a clear next-action state.

The script produces an active risk runway box, invalidation and target-edge guides, compact chart labels, alerts, and a clean AGPro planning panel. It does not predict future price movement, automate decisions, or guarantee that a setup will follow through.


🎯 Purpose & Design Philosophy

This script was built for traders who want to evaluate setup quality before execution, not after the chart has already moved.

Many tools show signals, volatility compression, or target levels in isolation. Risk Runway Planner is designed to connect the practical planning questions: Where is invalidation? Is stop distance reasonable? Is there enough room before obstruction? Is volatility supportive or unstable? What should the trader pay attention to now?

The design mindset is simple: a cleaner decision framework is more useful than another crowded signal layer.


⚡ Why This Script Is Different

Most tools focus on entries, squeeze conditions, support/resistance zones, or target projections as separate ideas.

This script does NOT try to become a generic compression map, a take-profit ladder, a position-sizing calculator, or a signal generator.

Instead, it evaluates the quality of the risk runway between invalidation and the next target edge. The core output is not a trade command. It is a planning state that helps the user decide whether a setup is READY, still on WATCH, BLOCKED by poor room, or exposed to WIDE RISK.


⚙️ Methodology

1. Context Detection
The script detects the active planning side using trend structure and price location, or allows the user to force long-context or short-context evaluation.

2. Reference Mapping
It maps the current planning range, recent invalidation shelf, nearby obstacle, ATR-normalized stop distance, and projected expansion room.

3. Reaction Evaluation
The model scores stop quality, expansion room, trend support, volatility state, and range location. These components are blended into a 0-100 quality score.

4. Visual Output
The output is shown through a risk runway box, invalidation guide, target-edge guide, compact labels, deterministic alerts, and a premium planning panel.


🗺️ How to Read the Chart

Zones = the active risk runway between invalidation and target edge.

Labels = compact state markers showing READY, WATCH, DOWNGRADE, INVALIDATED, or TARGET EDGE context.

Colors = bullish and bearish context use AGPro state colors, while neutral and warning conditions use controlled accent tones.

Panel = the panel summarizes Risk Compression, Expansion Room, Volatility State, Quality Score, Risk Edge, and Action.


🚦 Signals & States

• READY → the current risk runway has enough quality to justify active attention.

• WATCH → the setup is improving but does not yet meet the stricter readiness threshold.

• WIDE RISK → stop distance or invalidation quality is too weak for clean planning context.

• BLOCKED → expansion room is limited or the nearest obstacle is too close.

• WAIT → the planner does not detect a strong enough structure yet.

• INVALIDATED → a prior active invalidation shelf has been crossed.

• TARGET EDGE → a prior target edge has been reached.


🔔 Alerts Logic

Alerts trigger when the planner enters READY state, enters WATCH state, downgrades from READY, crosses a prior invalidation shelf, or reaches a prior target edge.

These alerts are attention markers. They are not trade instructions, entry signals, or automated strategy commands.


🧩 Confluence Logic

The strongest planning state appears when multiple components align:

Stop-distance quality + expansion room + trend support + controlled volatility + favorable price location.

When these factors align, the script can move from WATCH to READY. If risk widens or room becomes blocked, the state can downgrade.


📊 When to Use

• Before evaluating a discretionary setup

• During trend pauses where invalidation is becoming clearer

• Before breakout or continuation attempts when risk needs structure

• Around pullbacks where stop distance and target room need review

• When comparing whether one setup has cleaner risk than another


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro-timeframes with unstable wicks

• News-driven volatility spikes

• Markets where recent structure is too distorted to define a useful invalidation shelf

• Situations where the user expects a signal-only entry tool


🎛️ Key Inputs

• Planning Side → controls Auto, Long Context, or Short Context evaluation.

• ATR Length → normalizes stop distance, room, labels, and volatility state.

• Planning Range → defines the broader structure used for price location and range context.

• Invalidation Lookback → controls how the invalidation shelf is mapped.

• Obstacle Lookback → controls how nearby target-edge obstruction is estimated.

• READY / WATCH Thresholds → adjust how selective the planner is.

• Visual settings → control runway boxes, guide lines, memory boxes, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is built around a clean planning panel and one primary chart object: the risk runway box.

The panel uses a single merged AGPro header row and keeps the key planning information readable without turning the chart into a dashboard-heavy layout.

Labels are intentionally compact, offset away from candles, and controlled with cooldown and maximum-visible settings.


🧪 Practical Usage Workflow

1. Read the panel action state.

2. Check whether the risk runway box has enough room between invalidation and target edge.

3. Review whether the Risk Edge is reasonable in ATR terms.

4. Confirm whether the chart context supports the selected planning side.

5. Treat alerts as attention markers and review the broader market context before making any decision.


🔍 Interpretation Guidelines

A higher score means the planner sees better alignment between risk, room, volatility, trend support, and location.

READY does not mean a trade must be taken. It means the setup has enough planning quality to deserve attention.

WATCH means the structure may be developing, but at least one component still needs improvement.

WIDE RISK and BLOCKED are caution states. They help identify when the chart may be less efficient for planning.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.

It does not replace user judgment, risk management, or broader market analysis.


⚠️ Limitations & Transparency

Timeframe differences can change how invalidation shelves and obstacles are detected.

Volatility changes can alter ATR-normalized risk and room conditions.

Market structure can shift quickly after news, low-liquidity movement, or aggressive momentum expansion.

The script is rule-based and should be interpreted as an analytical planning layer, not as certainty.


🧠 Market Context Notes

Risk quality is not only about stop distance. It also depends on whether price has enough clean room to move, whether volatility is controlled, and whether structure supports the active side.

The planner is most useful when it helps the user avoid low-quality setups before they become emotional decisions.


🧾 Use Case Examples

When price is near a constructive invalidation shelf and still has clean room toward the next target edge, the planner may move toward WATCH or READY.

When price is too close to the nearest obstacle, the planner may show BLOCKED even if trend direction looks attractive.

When stop distance becomes too wide relative to ATR, the planner can show WIDE RISK even if the setup still looks visually interesting.


🧱 System Philosophy

Risk Runway Planner follows the AGPro Series decision-engine approach:

Context first.
Risk before reward.
Structure before signal.
Attention markers instead of promises.


🔐 Non-Promise Statement

No indicator can remove uncertainty.

No state, score, label, alert, or visual box should be interpreted as guaranteed market direction.


📉 Risk Disclosure

Trading involves risk.

All decisions remain the responsibility of the user.

This script is for educational and analytical chart review only and does not provide financial advice.


📚 Educational Note

The script is designed to help users think more clearly about setup quality, invalidation, volatility, and available room before reacting to price movement.

## Source Code

````pine
// -------------------------------------------------
// Risk Runway Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Risk Runway Planner is a chart-first risk planning and execution readiness
// tool built to evaluate stop-distance quality, invalidation clarity, expansion
// room, trend support, volatility load, and active runway state before a setup
// moves from watch state into active attention. It now adds a confirmation-
// anchored proof layer (Follow, Hold, React, Flip rates) that shows how often
// the active runway reached its target edge before invalidation on the symbol.
// -------------------------------------------------

//@version=6
indicator("Risk Runway Planner [AGPro Series]",
     shorttitle       = "AG Pro RRP",
     overlay          = true,
     max_labels_count = 130,
     max_boxes_count  = 30,
     max_lines_count  = 40)

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
ttPreset = "Selects the default operating profile. Balanced Planner is the publication default. Cleaner Swing reduces density. Active Intraday reacts faster. Custom uses the raw inputs below."
ttDirectionMode = "Selects the planning side. Auto reads trend and price location to choose the active context. Manual modes force the planner to evaluate only the selected side."
ttAtrLen = "ATR length used to normalize stop distance, expansion room, volatility load, labels and runway padding."
ttBaselineLen = "Reference length used to compare current volatility with a broader baseline. Higher values make the volatility state slower and more stable."
ttRangeLen = "Lookback used to define the current planning range. The planner reads where price is inside this range and whether there is enough room before obstruction."
ttInvalidLen = "Lookback used to locate the active invalidation shelf. For long context it reads recent lows; for short context it reads recent highs."
ttObstacleLen = "Lookback used to search for the nearest recent obstacle in the planned direction. This affects expansion room and target-edge estimation."
ttFastLen = "Fast EMA used for trend-support scoring. It does not generate entries; it only helps classify whether the active plan has directional support."
ttSlowLen = "Slow EMA used as the main trend baseline for planning context and optional runway support."
ttMinStopAtr = "Minimum acceptable ATR-normalized stop distance. Values below this can be fragile because the invalidation shelf may be too close."
ttIdealStopAtr = "Preferred ATR-normalized stop distance. The stop-distance score is strongest near this value."
ttMaxStopAtr = "Maximum acceptable ATR-normalized stop distance. Values above this are treated as wide-risk conditions."
ttMinRoomAtr = "Minimum ATR-normalized expansion room required before the setup can be considered clean enough for active attention."
ttStrongRoomAtr = "Expansion-room level that maps to a strong room score. Higher values require more open space before the next obstacle."
ttReadyThreshold = "Minimum total quality score required for READY state. READY means attention is justified, not that a trade should be executed."
ttWatchThreshold = "Minimum total quality score required for WATCH state. WATCH means the structure is improving but not ready enough yet."
ttShowBox = "Shows the active risk runway box from invalidation shelf to target edge. This is a planning object, not a support/resistance zone."
ttBoxProjection = "Number of bars the active runway box projects to the right. A moderate projection keeps risk, invalidation and target context readable."
ttShowLines = "Shows the invalidation shelf and target edge as compact projected guide lines."
ttShowMemory = "Keeps a small number of completed READY runway boxes as soft context. Disable this if the chart becomes too busy."
ttMemoryCount = "Maximum number of completed runway memory boxes retained on the chart."
ttLiveOffset = "Moves live review tags to the right while keeping level-based invalidation and target tags attached to their guide lines."
ttShowLabels = "Shows compact state labels for READY, WATCH, downgrade, invalidation and target-edge events."
ttShowContext = "Adds sparse context labels when the planner remains active for a while. This keeps the chart informative without creating a signal board."
ttLabelCooldown = "Minimum bars between event labels. Higher values reduce label density and keep the public chart cleaner."
ttContextSpacing = "Minimum spacing for sparse context labels during active planning phases."
ttMaxLabels = "Maximum number of labels retained on the chart. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset used to keep labels above or below candles instead of buried inside price bars."
ttShowScore = "Adds the 0-100 quality score to event labels. The text remains compact for publication screenshots."
ttLabelSize = "Font size for chart labels and runway box text. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the compact AG Pro planning panel. The panel is shown by default for public release readability."
ttPanelLocation = "Moves the planning panel to the preferred chart location."
ttPanelTheme = "Switches the panel between the AG Pro dark theme and a clean light theme."
ttPanelFont = "Font size for the planning panel. Normal is the recommended publication default."
ttShowProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across rolling evaluation windows in the active planning direction on the current symbol and timeframe. Follow means price advanced one risk unit (1R) in favor, or reached the target edge if it was closer, before invalidation. These are historical outcome rates, not predictions."
ttProofHorizon = "Number of bars each rolling runway window is tracked forward to measure whether the target edge was reached before the invalidation shelf was breached."
ttReactBars = "Number of bars after a window opens used to detect an immediate favorable reaction toward the target edge."
ttReactProgress = "Minimum favorable progress toward the target edge, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Planner Engine"
enginePreset = input.string("Balanced Planner", "Engine Preset", options = ["Balanced Planner", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = ttPreset)
directionMode = input.string("Auto", "Planning Side", options = ["Auto", "Long Context", "Short Context"], group = groupEngine, tooltip = ttDirectionMode)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
baselineLen = input.int(55, "Volatility Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttBaselineLen)
rangeLen = input.int(48, "Planning Range", minval = 10, maxval = 300, group = groupEngine, tooltip = ttRangeLen)
invalidLen = input.int(18, "Invalidation Lookback", minval = 3, maxval = 120, group = groupEngine, tooltip = ttInvalidLen)
obstacleLen = input.int(72, "Obstacle Lookback", minval = 10, maxval = 300, group = groupEngine, tooltip = ttObstacleLen)
fastLen = input.int(21, "Fast Trend EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFastLen)
slowLen = input.int(55, "Slow Trend EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlowLen)

groupScoring = "Risk Scoring"
minStopAtr = input.float(0.45, "Minimum Stop ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttMinStopAtr)
idealStopAtr = input.float(1.15, "Ideal Stop ATR", minval = 0.10, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttIdealStopAtr)
maxStopAtr = input.float(2.80, "Maximum Stop ATR", minval = 0.20, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = ttMaxStopAtr)
minRoomAtr = input.float(1.35, "Minimum Room ATR", minval = 0.10, maxval = 10.00, step = 0.05, group = groupScoring, tooltip = ttMinRoomAtr)
strongRoomAtr = input.float(3.40, "Strong Room ATR", minval = 0.30, maxval = 20.00, step = 0.10, group = groupScoring, tooltip = ttStrongRoomAtr)
readyThreshold = input.float(74.0, "READY Threshold", minval = 40.0, maxval = 95.0, step = 1.0, group = groupScoring, tooltip = ttReadyThreshold)
watchThreshold = input.float(58.0, "WATCH Threshold", minval = 25.0, maxval = 90.0, step = 1.0, group = groupScoring, tooltip = ttWatchThreshold)

groupVisual = "Runway Visuals"
showRunwayBox = input.bool(true, "Show Risk Runway Box", group = groupVisual, tooltip = ttShowBox)
boxProjectionBars = input.int(38, "Box Projection Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttBoxProjection)
showGuideLines = input.bool(true, "Show Risk / Target Guides", group = groupVisual, tooltip = ttShowLines)
showMemoryBoxes = input.bool(false, "Show READY Memory Boxes", group = groupVisual, tooltip = ttShowMemory)
memoryBoxCount = input.int(1, "Max Memory Boxes", minval = 0, maxval = 8, group = groupVisual, tooltip = ttMemoryCount)
showLiveReviewTags = input.bool(true, "Show Live Review Tags", group = groupVisual,
     tooltip = "Shows compact right-edge tags for workflow state, quality, invalidation distance, and target room.")
liveTagOffsetBars = input.int(8, "Live Tag Offset Bars", minval = 3, maxval = 60, group = groupVisual, tooltip = ttLiveOffset)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttShowLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttShowContext)
labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttLabelCooldown)
contextSpacingBars = input.int(80, "Context Label Spacing", minval = 20, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(8, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.18, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttShowScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttShowProof)
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = ttProofHorizon)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

groupAlerts = "Alerts"
alertReadyWatch = input.bool(true, "Alert on READY and WATCH", group = groupAlerts,
     tooltip = "Enables alerts when the runway enters READY or WATCH state.")
alertRiskEvents = input.bool(true, "Alert on Invalidation and Target Edge", group = groupAlerts,
     tooltip = "Enables alerts when a prior runway invalidation shelf is crossed or the target edge is reached.")

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

f_stop_quality(float stopAtr, float minAtr, float idealAtr, float maxAtr) =>
    result = 0.0
    if stopAtr < minAtr
        result := f_clamp(stopAtr / minAtr * 78.0, 0.0, 78.0)
    else if stopAtr <= idealAtr
        result := 78.0 + f_clamp((stopAtr - minAtr) / math.max(idealAtr - minAtr, 0.01) * 22.0, 0.0, 22.0)
    else
        result := f_norm_low_good(stopAtr, idealAtr, maxAtr)
    result

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
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        oldBox = array.shift(boxes)
        box.delete(oldBox)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_action_color(string action) =>
    switch action
        "READY" => bullColor
        "WATCH" => accentColor
        "WIDE RISK" => bearColor
        "BLOCKED" => neutralColor
        "INVALID" => bearColor
        => panelLabelCol

f_action_display(string action) =>
    switch action
        "READY" => "REVIEW READY"
        "WATCH" => "BUILD WATCH"
        "WIDE RISK" => "DISTANCE REVIEW"
        "BLOCKED" => "ROOM BLOCKED"
        "INVALID" => "INVALIDATION HIT"
        "WAIT" => "WAIT SETUP"
        => action

f_action_short(string action) =>
    switch action
        "READY" => "READY"
        "WATCH" => "WATCH"
        "WIDE RISK" => "DISTANCE"
        "BLOCKED" => "ROOM"
        "INVALID" => "INVALID"
        "WAIT" => "WAIT"
        => action

f_review_text(string action) =>
    switch action
        "READY" => "REVIEW PLAN"
        "WATCH" => "TRACK BUILD"
        "WIDE RISK" => "CHECK DISTANCE"
        "BLOCKED" => "CHECK TARGET"
        "INVALID" => "RESET PLAN"
        "WAIT" => "WAIT CLEANER"
        => "REVIEW CONTEXT"

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(19, 29, 48) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_best_view_text() =>
    timeframe.isintraday ? "1H / 4H / 1D" : timeframe.isdaily ? "DAILY CHART" : "4H / 1D"

// -------------------------------------------------
// Presets
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Intraday"

usedReadyThresholdRaw = cleanerPreset ? math.max(readyThreshold, 76.0) : activePreset ? math.max(readyThreshold - 4.0, 40.0) : readyThreshold
usedWatchThresholdRaw = cleanerPreset ? math.max(watchThreshold, 60.0) : activePreset ? math.max(watchThreshold - 5.0, 25.0) : watchThreshold
usedReadyThreshold = math.max(usedReadyThresholdRaw, usedWatchThresholdRaw + 1.0)
usedWatchThreshold = math.min(usedWatchThresholdRaw, usedReadyThreshold - 1.0)

usedLabelCooldown = cleanerPreset ? math.max(labelCooldownBars, 30) : activePreset ? math.min(labelCooldownBars, 14) : labelCooldownBars
usedMaxVisibleLabels = cleanerPreset ? math.min(maxVisibleLabels, 6) : activePreset ? math.min(maxVisibleLabels, 10) : maxVisibleLabels
usedBoxProjection = cleanerPreset ? math.max(boxProjectionBars, 42) : activePreset ? math.min(boxProjectionBars, 28) : boxProjectionBars

effectiveMinStopAtr = math.min(minStopAtr, maxStopAtr)
effectiveMaxStopAtr = math.max(minStopAtr, maxStopAtr)
effectiveIdealStopAtr = f_clamp(idealStopAtr, effectiveMinStopAtr, effectiveMaxStopAtr)
effectiveMinRoomAtr = math.min(minRoomAtr, strongRoomAtr)
effectiveStrongRoomAtr = math.max(strongRoomAtr, effectiveMinRoomAtr + 0.05)
effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
atrBase = ta.sma(atr, baselineLen)
atrRatio = atrBase > 0.0 ? atr / atrBase : 1.0
atrPulse = not na(atr[5]) and atr[5] > 0.0 ? atr / atr[5] : 1.0

rangeHigh = ta.highest(high, rangeLen)
rangeLow = ta.lowest(low, rangeLen)
rangeWidth = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangePosition = f_clamp((close - rangeLow) / rangeWidth, 0.0, 1.0)
rangeAtr = rangeWidth / safeAtr

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
emaSlope = emaSlow - nz(emaSlow[5], emaSlow)
int autoDir = 0
if emaFast > emaSlow and emaSlope >= 0.0
    autoDir := 1
else if emaFast < emaSlow and emaSlope <= 0.0
    autoDir := -1
else
    autoDir := rangePosition <= 0.50 ? 1 : -1

planDir = directionMode == "Long Context" ? 1 : directionMode == "Short Context" ? -1 : autoDir
dirText = planDir == 1 ? "Long Context" : "Short Context"
dirPrefix = planDir == 1 ? "L" : "S"

rawInvalid = planDir == 1 ? ta.lowest(low, invalidLen) : ta.highest(high, invalidLen)
invalidLevel = planDir == 1 ? math.min(rawInvalid, close - syminfo.mintick) : math.max(rawInvalid, close + syminfo.mintick)
stopDistance = math.abs(close - invalidLevel)
stopAtr = stopDistance / safeAtr
stopQuality = f_stop_quality(stopAtr, effectiveMinStopAtr, effectiveIdealStopAtr, effectiveMaxStopAtr)

priorObstacleRaw = planDir == 1 ? ta.highest(high[1], obstacleLen) : ta.lowest(low[1], obstacleLen)
priorObstacle = nz(priorObstacleRaw, close)
projectedRoom = math.max(rangeWidth * 0.50, safeAtr * effectiveStrongRoomAtr)
fallbackTarget = close + planDir * projectedRoom
targetLevel = planDir == 1 ? priorObstacle > close ? priorObstacle : fallbackTarget : priorObstacle < close ? priorObstacle : fallbackTarget
roomAtr = math.abs(targetLevel - close) / safeAtr
roomScore = f_norm_high_good(roomAtr, effectiveMinRoomAtr, effectiveStrongRoomAtr)

compressionScore = f_clamp(f_norm_low_good(atrRatio, 0.72, 1.38) * 0.58 + f_norm_low_good(rangeAtr, 2.20, 7.50) * 0.42, 0.0, 100.0)
expansionScore = f_clamp(f_norm_high_good(atrPulse, 0.92, 1.18) * 0.45 + roomScore * 0.55, 0.0, 100.0)
volatilityScore = f_clamp(compressionScore * 0.64 + expansionScore * 0.36, 0.0, 100.0)

trendSideScore = planDir == 1 ? (emaFast > emaSlow ? 70.0 : 35.0) : (emaFast < emaSlow ? 70.0 : 35.0)
trendSlopeScore = planDir == 1 ? f_norm_high_good(emaSlope / safeAtr, -0.12, 0.18) : f_norm_high_good(-emaSlope / safeAtr, -0.12, 0.18)
priceSideScore = planDir == 1 ? (close >= emaSlow ? 100.0 : 45.0) : (close <= emaSlow ? 100.0 : 45.0)
trendScore = f_clamp(trendSideScore * 0.40 + trendSlopeScore * 0.32 + priceSideScore * 0.28, 0.0, 100.0)

locationScore = planDir == 1 ? f_norm_low_good(rangePosition, 0.28, 0.86) : f_norm_high_good(rangePosition, 0.14, 0.72)
qualityScore = f_clamp(stopQuality * 0.28 + roomScore * 0.24 + trendScore * 0.18 + volatilityScore * 0.16 + locationScore * 0.14, 0.0, 100.0)
effectiveReadyThreshold = usedReadyThreshold
effectiveWatchThreshold = usedWatchThreshold

riskState = stopQuality >= 70.0 ? "CONTROLLED" : stopQuality >= 45.0 ? "REVIEW" : "WIDE"
roomState = roomScore >= 70.0 ? "OPEN" : roomScore >= 45.0 ? "LIMITED" : "BLOCKED"
volState = volatilityScore >= 70.0 ? "COMPRESSED" : volatilityScore >= 45.0 ? "BALANCED" : "LOOSE"
qualityState = qualityScore >= effectiveReadyThreshold ? "A" : qualityScore >= effectiveWatchThreshold ? "B" : qualityScore >= 45.0 ? "C" : "D"

actionState = "WAIT"
if stopQuality < 35.0
    actionState := "WIDE RISK"
else if roomScore < 32.0
    actionState := "BLOCKED"
else if qualityScore >= effectiveReadyThreshold and stopQuality >= 55.0 and roomScore >= 55.0 and trendScore >= 45.0
    actionState := "READY"
else if qualityScore >= effectiveWatchThreshold
    actionState := "WATCH"
else
    actionState := "WAIT"

activePlan = actionState != "WAIT"
actionColor = f_action_color(actionState)
actionDisplay = f_action_display(actionState)
rightEdge = bar_index + usedBoxProjection
liveTagX = rightEdge + liveTagOffsetBars
qualityTagX = liveTagX + 2
riskTagX = liveTagX + 5
targetTagX = liveTagX + 8
guideRightEdge = showLiveReviewTags and activePlan ? targetTagX : rightEdge
boxTop = math.max(targetLevel, invalidLevel)
boxBottom = math.min(targetLevel, invalidLevel)
boxText = "RUNWAY " + f_action_short(actionState) + "\nQ " + str.tostring(math.round(qualityScore))

// -------------------------------------------------
// Confirmation-anchored proof (qualified runway capture)
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
var bool pReacted = false
var bool pFollowed = false

int proofWarmup = math.max(slowLen, obstacleLen) + atrLen + 5
bool proofEligible = actionState == "READY" or actionState == "WATCH"
int proofSideCode = planDir

if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool sideReplaced = proofSideCode != pEvalDir
        bool ambiguousNow = targetTouched and (stopTouched or sideReplaced)

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched and not sideReplaced
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or sideReplaced or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched and not sideReplaced
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched or sideReplaced
                    proofFlip := proofFlip + 1

            pEvalActive := false
            pLastResolveBar := bar_index

    // Open sequential, non-overlapping samples only in qualified READY/WATCH contexts.
    bool proofRestartReady = na(pLastResolveBar) or bar_index > pLastResolveBar
    if proofEligible and not pEvalActive and proofRestartReady
        pEvalActive := true
        pEvalDir := proofSideCode
        pEvalEntry := close
        pEvalStop := invalidLevel

        float pStopDist = math.max(math.abs(close - invalidLevel), syminfo.mintick)
        float pEdgeDist = math.max(math.abs(targetLevel - close), syminfo.mintick)
        float pFollowDist = math.min(pStopDist, pEdgeDist)
        pEvalTarget := close + pEvalDir * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Events
// -------------------------------------------------
var string lastActionState = ""
readyEvent = barstate.isconfirmed and actionState == "READY" and lastActionState != "READY"
watchEvent = barstate.isconfirmed and actionState == "WATCH" and lastActionState != "WATCH"
downgradeEvent = barstate.isconfirmed and lastActionState == "READY" and actionState != "READY"
wasActive = bar_index > 0 ? activePlan[1] : false
prevDir = bar_index > 0 ? planDir[1] : planDir
invalidationEvent = barstate.isconfirmed and wasActive and not na(invalidLevel[1]) and ((prevDir == 1 and close < invalidLevel[1]) or (prevDir == -1 and close > invalidLevel[1]))
targetEvent = barstate.isconfirmed and wasActive and not na(targetLevel[1]) and ((prevDir == 1 and high >= targetLevel[1]) or (prevDir == -1 and low <= targetLevel[1]))

// -------------------------------------------------
// Active runway visuals
// -------------------------------------------------
var box activeRunwayBox = na
var label activeRunwayBadge = na
var line invalidationLine = na
var line targetLine = na
var label liveStateTag = na
var label liveQualityTag = na
var label liveRiskTag = na
var label liveTargetTag = na
var line liveReviewConnector = na
var array<box> memoryBoxes = array.new_box()
var array<label> memoryBadges = array.new_label()

if showRunwayBox and activePlan
    boxBg = color.new(actionColor, actionState == "READY" ? 88 : actionState == "WATCH" ? 92 : 95)
    boxBorder = color.new(actionColor, actionState == "READY" ? 26 : actionState == "WATCH" ? 45 : 64)
    runwayBadgeX = int(math.round((bar_index + rightEdge) * 0.5))
    runwayBadgeY = (boxTop + boxBottom) * 0.5
    if na(activeRunwayBox)
        activeRunwayBox := box.new(left = bar_index, top = boxTop, right = rightEdge, bottom = boxBottom, xloc = xloc.bar_index, bgcolor = boxBg, border_color = boxBorder, border_width = 1)
    else
        box.set_left(activeRunwayBox, bar_index)
        box.set_right(activeRunwayBox, rightEdge)
        box.set_top(activeRunwayBox, boxTop)
        box.set_bottom(activeRunwayBox, boxBottom)
        box.set_bgcolor(activeRunwayBox, boxBg)
        box.set_border_color(activeRunwayBox, boxBorder)
    if na(activeRunwayBadge)
        activeRunwayBadge := label.new(runwayBadgeX, runwayBadgeY, boxText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(actionColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    else
        label.set_xy(activeRunwayBadge, runwayBadgeX, runwayBadgeY)
        label.set_text(activeRunwayBadge, boxText)
        label.set_style(activeRunwayBadge, label.style_label_center)
        label.set_color(activeRunwayBadge, color.new(actionColor, 0))
        label.set_textcolor(activeRunwayBadge, headerText)
        label.set_size(activeRunwayBadge, f_label_size(labelSizeInput))
        label.set_textalign(activeRunwayBadge, text.align_center)
else
    if not na(activeRunwayBox)
        if showMemoryBoxes and memoryBoxCount > 0 and lastActionState == "READY"
            memoryBox = box.copy(activeRunwayBox)
            box.set_bgcolor(memoryBox, color.new(bullColor, 93))
            box.set_border_color(memoryBox, color.new(bullColor, 70))
            array.push(memoryBoxes, memoryBox)
            f_trim_boxes(memoryBoxes, memoryBoxCount)
            memoryBadge = label.new(int(math.round((box.get_left(memoryBox) + box.get_right(memoryBox)) * 0.5)), (box.get_top(memoryBox) + box.get_bottom(memoryBox)) * 0.5, "READY\nMEMORY", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bullColor, 18), textcolor = color.new(headerText, 18), size = f_label_size(labelSizeInput), textalign = text.align_center)
            array.push(memoryBadges, memoryBadge)
            f_trim_labels(memoryBadges, memoryBoxCount)
        box.delete(activeRunwayBox)
        activeRunwayBox := na
    if not na(activeRunwayBadge)
        label.delete(activeRunwayBadge)
        activeRunwayBadge := na

if showGuideLines and activePlan
    invalidColor = color.new(bearColor, 0)
    targetColor = color.new(planDir == 1 ? bullColor : accentColor, 0)
    if na(invalidationLine)
        invalidationLine := line.new(bar_index, invalidLevel, guideRightEdge, invalidLevel, xloc = xloc.bar_index, extend = extend.none, color = invalidColor, width = 2, style = line.style_solid)
    else
        line.set_xy1(invalidationLine, bar_index, invalidLevel)
        line.set_xy2(invalidationLine, guideRightEdge, invalidLevel)
        line.set_color(invalidationLine, invalidColor)
    if na(targetLine)
        targetLine := line.new(bar_index, targetLevel, guideRightEdge, targetLevel, xloc = xloc.bar_index, extend = extend.none, color = targetColor, width = 2, style = line.style_dotted)
    else
        line.set_xy1(targetLine, bar_index, targetLevel)
        line.set_xy2(targetLine, guideRightEdge, targetLevel)
        line.set_color(targetLine, targetColor)
else
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

// -------------------------------------------------
// Live review tags
// -------------------------------------------------
if barstate.islast
    if not na(liveStateTag)
        label.delete(liveStateTag)
        liveStateTag := na
    if not na(liveQualityTag)
        label.delete(liveQualityTag)
        liveQualityTag := na
    if not na(liveRiskTag)
        label.delete(liveRiskTag)
        liveRiskTag := na
    if not na(liveTargetTag)
        label.delete(liveTargetTag)
        liveTargetTag := na
    if not na(liveReviewConnector)
        line.delete(liveReviewConnector)
        liveReviewConnector := na

    if showLiveReviewTags and activePlan
        tagGap = math.max(safeAtr * 0.72, close * 0.007)
        midLevel = (boxTop + boxBottom) * 0.5
        stateY = planDir == 1 ? midLevel + tagGap * 0.55 : midLevel - tagGap * 0.55
        qualityY = planDir == 1 ? stateY + tagGap : stateY - tagGap
        riskY = invalidLevel
        targetY = targetLevel

        liveStateTag := label.new(liveTagX, stateY, "WORKFLOW\n" + f_review_text(actionState), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(actionColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        liveQualityTag := label.new(qualityTagX, qualityY, "QUALITY\n" + str.tostring(math.round(qualityScore)) + "/100", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 4), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        liveRiskTag := label.new(riskTagX, riskY, "INVALID\n" + str.tostring(stopAtr, "#.00") + " ATR", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 5), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        liveTargetTag := label.new(targetTagX, targetY, "TARGET\n" + str.tostring(roomAtr, "#.00") + " ATR", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(planDir == 1 ? bullColor : accentColor, 5), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        liveReviewConnector := line.new(rightEdge, midLevel, liveTagX, stateY, xloc = xloc.bar_index, color = color.new(actionColor, 42), width = 1, style = line.style_dotted)

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastLabelBar = na
var array<label> eventLabels = array.new_label()
labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= usedLabelCooldown
stateEvent = readyEvent or watchEvent or downgradeEvent or invalidationEvent or targetEvent
contextEvent = showContextLabels and barstate.isconfirmed and activePlan and labelCooldownReady and (na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars)
drawEventLabel = showEventLabels and labelCooldownReady and (stateEvent or contextEvent)

if drawEventLabel
    eventDir = invalidationEvent or targetEvent ? prevDir : planDir
    eventPrefix = eventDir == 1 ? "L" : "S"
    eventText = eventPrefix + " " + f_action_short(actionState)
    eventColor = actionColor
    if invalidationEvent
        eventText := "INVALIDATION"
        eventColor := bearColor
    else if targetEvent
        eventText := "TARGET EDGE"
        eventColor := neutralColor
    else if downgradeEvent
        eventText := "REVIEW DOWN"
        eventColor := neutralColor
    else if showLabelScore
        eventText += " " + str.tostring(math.round(qualityScore))
    labelY = eventDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    eventLabel = label.new(x = bar_index, y = labelY, text = eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(eventColor, 8), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, usedMaxVisibleLabels)
    lastLabelBar := bar_index

plotshape(readyEvent, title = "READY State Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 100), size = size.tiny, display = display.none)
plotshape(downgradeEvent or invalidationEvent, title = "Risk Downgrade Marker", style = shape.diamond, location = location.abovebar, color = color.new(neutralColor, 100), size = size.tiny, display = display.none)

// -------------------------------------------------
// Hidden exports
// -------------------------------------------------
plot(qualityScore, title = "Risk Runway Quality Score", color = actionColor, display = display.none)
plot(stopQuality, title = "Stop Distance Quality", color = bearColor, display = display.none)
plot(roomScore, title = "Expansion Room Score", color = bullColor, display = display.none)
plot(volatilityScore, title = "Volatility State Score", color = accentColor, display = display.none)
plot(trendScore, title = "Trend Support Score", color = neutralColor, display = display.none)
plot(followRate, title = "RRP Follow Rate", display = display.none)
plot(holdRate, title = "RRP Hold Rate", display = display.none)
plot(reactRate, title = "RRP React Rate", display = display.none)
plot(flipRate, title = "RRP Flip Rate", display = display.none)
plot(proofAmbiguous, title = "RRP Ambiguous Proof Count", display = display.none)
plot(stopAtr, title = "RRP Stop Distance ATR", display = display.none)
plot(roomAtr, title = "RRP Target Room ATR", display = display.none)
plot(planDir, title = "RRP Planning Direction", display = display.none)

// -------------------------------------------------
// Panel
// -------------------------------------------------
isLightPanel = panelThemeInput == "Light"
panelBgA = f_panel_bg(isLightPanel, false)
panelBgB = f_panel_bg(isLightPanel, true)
frameColor = f_panel_border(isLightPanel)
labelText = f_panel_label(isLightPanel)
valueText = f_panel_value(isLightPanel)
panelSize = panelFontSizeInput

riskRead = str.tostring(math.round(stopQuality)) + " / " + riskState
roomRead = str.tostring(math.round(roomScore)) + " / " + roomState
volRead = str.tostring(math.round(volatilityScore)) + " / " + volState
qualityRead = str.tostring(math.round(qualityScore)) + " / " + qualityState
edgeRead = str.tostring(stopAtr, "#.00") + " ATR"
targetRead = str.tostring(roomAtr, "#.00") + " ATR"
actionRead = actionDisplay + " | " + (planDir == 1 ? "LONG" : "SHORT")
bestViewText = f_best_view_text()

proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
followText = proofTotal > 0 ? f_pct(followRate) : "-"
holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
followCol = proofTotal > 0 ? f_rate_color(followRate) : valueText
holdCol = proofTotal > 0 ? f_rate_color(holdRate) : valueText
reactCol = proofTotal > 0 ? f_rate_color(reactRate) : valueText
flipCol = proofTotal > 0 ? f_flip_color(flipRate) : valueText

int panelRowCount = showProof ? 13 : 8

var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastProofMode = false

panelNeedsReset = showPanel and (na(panel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or panelFontSizeInput != lastPanelSize or showProof != lastProofMode)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = panelBgA, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Risk Runway Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize))
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelSize := panelFontSizeInput
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.set_frame_color(panel, frameColor)
    table.set_border_color(panel, frameColor)
    table.clear(panel, 0, 1, 1, panelRowCount - 1)
    table.cell(panel, 0, 1, "Workflow", text_color = labelText, bgcolor = panelBgA, text_size = f_label_size(panelSize))
    table.cell(panel, 1, 1, actionRead, text_color = actionColor, bgcolor = panelBgA, text_size = f_label_size(panelSize), text_halign = text.align_right)
    table.cell(panel, 0, 2, "Risk Distance", text_color = labelText, bgcolor = panelBgB, text_size = f_label_size(panelSize))
    table.cell(panel, 1, 2, edgeRead + " / " + riskState, text_color = stopQuality >= 55.0 ? bullColor : stopQuality >= 35.0 ? neutralColor : bearColor, bgcolor = panelBgB, text_size = f_label_size(panelSize), text_halign = text.align_right)
    table.cell(panel, 0, 3, "Invalidation", text_color = labelText, bgcolor = panelBgA, text_size = f_label_size(panelSize))
    table.cell(panel, 1, 3, str.tostring(invalidLevel, format.mintick), text_color = bearColor, bgcolor = panelBgA, text_size = f_label_size(panelSize), text_halign = text.align_right)
    table.cell(panel, 0, 4, "Target Room", text_color = labelText, bgcolor = panelBgB, text_size = f_label_size(panelSize))
    table.cell(panel, 1, 4, targetRead + " / " + roomState, text_color = roomScore >= 55.0 ? bullColor : roomScore >= 32.0 ? neutralColor : bearColor, bgcolor = panelBgB, text_size = f_label_size(panelSize), text_halign = text.align_right)
    table.cell(panel, 0, 5, "Quality", text_color = labelText, bgcolor = panelBgA, text_size = f_label_size(panelSize))
    table.cell(panel, 1, 5, qualityRead, text_color = actionColor, bgcolor = panelBgA, text_size = f_label_size(panelSize), text_halign = text.align_right)
    table.cell(panel, 0, 6, "Volatility", text_color = labelText, bgcolor = panelBgB, text_size = f_label_size(panelSize))
    table.cell(panel, 1, 6, volRead, text_color = volatilityScore >= 55.0 ? accentColor : valueText, bgcolor = panelBgB, text_size = f_label_size(panelSize), text_halign = text.align_right)
    table.cell(panel, 0, 7, "Review View", text_color = labelText, bgcolor = panelBgA, text_size = f_label_size(panelSize))
    table.cell(panel, 1, 7, bestViewText, text_color = accentColor, bgcolor = panelBgA, text_size = f_label_size(panelSize), text_halign = text.align_right)
    if showProof
        table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = panelBgB, text_size = f_label_size(panelSize), text_halign = text.align_left)
        table.cell(panel, 1, 8, proofSampleText, text_color = labelText, bgcolor = panelBgB, text_size = f_label_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 9, "Follow Rate", text_color = labelText, bgcolor = panelBgA, text_size = f_label_size(panelSize))
        table.cell(panel, 1, 9, followText, text_color = followCol, bgcolor = panelBgA, text_size = f_label_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 10, "Hold Rate", text_color = labelText, bgcolor = panelBgB, text_size = f_label_size(panelSize))
        table.cell(panel, 1, 10, holdText, text_color = holdCol, bgcolor = panelBgB, text_size = f_label_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 11, "React Rate", text_color = labelText, bgcolor = panelBgA, text_size = f_label_size(panelSize))
        table.cell(panel, 1, 11, reactText, text_color = reactCol, bgcolor = panelBgA, text_size = f_label_size(panelSize), text_halign = text.align_right)
        table.cell(panel, 0, 12, "Flip Rate", text_color = labelText, bgcolor = panelBgB, text_size = f_label_size(panelSize))
        table.cell(panel, 1, 12, flipText, text_color = flipCol, bgcolor = panelBgB, text_size = f_label_size(panelSize), text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertReadyWatch and readyEvent, title = "Risk Runway Review Ready", message = "Risk Runway Planner: REVIEW READY attention marker. Review risk distance, target room, and broader market context.")
alertcondition(alertReadyWatch and watchEvent, title = "Risk Runway Build Watch", message = "Risk Runway Planner: BUILD WATCH attention marker. Track whether risk distance and target room continue to improve.")
alertcondition(downgradeEvent, title = "Risk Runway Review Down", message = "Risk Runway Planner: review state moved down from a prior ready context.")
alertcondition(alertRiskEvents and invalidationEvent, title = "Risk Runway Invalidation Review", message = "Risk Runway Planner: prior invalidation shelf was crossed. Review the active plan context.")
alertcondition(alertRiskEvents and targetEvent, title = "Risk Runway Target Edge Review", message = "Risk Runway Planner: prior target edge was reached. Review remaining runway context.")

if barstate.isconfirmed
    lastActionState := actionState
````
