# Breakeven Review Planner [AGPro Series]

- url: https://www.tradingview.com/script/EuzqidNa-Breakeven-Review-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;164ad200ae7e48dfb64dba48315b23b8
- version: 4.0

## Description

Breakeven Review Planner [AGPro Series]

🧠 Core Idea

Has the move progressed enough to review breakeven protection, or is the context still too early, weak, or exposed?


📌 Overview / What it does

Breakeven Review Planner is a trade-management overlay designed to evaluate post-activation move progress. Instead of asking users to manually draw a full entry, stop, and take-profit plan, the script detects a qualified directional move, anchors an activation reference, builds a structural invalidation shelf, and measures live R progress from that context.

The output is a clean breakeven review workflow: a BE review zone, activation reference, invalidation shelf, current R reading, trend-support state, pullback-risk state, event labels, alerts, and a premium AGPro panel.

It does not predict price direction, place trades, calculate position size, build a take-profit ladder, or tell users to move a stop. Alerts and labels are attention markers for review context only.


🎯 Purpose & Design Philosophy

This script was built for traders who already manage active moves and need a cleaner way to evaluate whether the move has earned a breakeven review.

The gap it fills is not pre-trade risk/reward planning. AGPro already has tools for that. This script focuses on the management phase after a move is active: progress, structure, trend support, and pullback risk.

The design supports a disciplined review mindset. It helps users read whether the chart has built enough progress to deserve attention without turning that review into an automated instruction.


⚡ Why This Script Is Different

Most risk/reward tools focus on manual entry, stop-loss, targets, position sizing, and breakeven probability.

This script does NOT build a full trade plan, does NOT create TP ladders, and does NOT tell users to move a stop.

Instead, it watches the live chart for a qualified management context, scores the move's progress toward a breakeven review threshold, and keeps the user focused on whether the current structure is strong, weak, stale, or invalidated.


⚙️ Methodology

1. Context Detection
The script detects directional activation when price escapes recent structure with enough ATR-normalized impulse, candle commitment, close-location quality, and trend support.

2. Reference Mapping
After activation, the script anchors an activation reference and builds an invalidation shelf from the latest confirmed swing plus an ATR buffer.

3. Reaction Evaluation
The engine measures current R, best favorable R, trend support, candle quality, volatility fit, and pullback depth after progress.

4. Visual Output
The chart displays the BE review zone, progress fill, context lines, event labels, candle tint, alerts, and the AGPro panel.


🗺️ How to Read the Chart

Zones = the BE review area around the configured R trigger. It is a review zone, not a command.

Labels = context markers such as armed context, progress milestones, BE review, pullback watch, stale context, and invalidation.

Colors = teal for bullish-supported context, pink for bearish or invalid context, amber for caution, and indigo for breakeven review focus.

Panel = the current decision cockpit. It shows Review Score, Current R, BE Trigger, Progress State, Trend Support, and Action.


🚦 Signals & States

• Bull Context Armed → a bullish management context was activated after structure escape.

• Bear Context Armed → a bearish management context was activated after structure escape.

• BE Review Active → current progress reached the configured R threshold for breakeven review.

• Review + Pullback → price reached review progress but has pulled back enough to require closer attention.

• Stale → the context spent too many bars without enough progress.

• Invalidated → price reached the structural invalidation shelf.


🔔 Alerts Logic

Alerts trigger when a new management context activates, the BE review zone is reached, the review quality is high, pullback risk increases after review progress, the invalidation shelf is reached, or the context becomes stale.

Alerts are attention markers. They are not trading instructions, broker actions, or automated stop-management commands.


🧩 Confluence Logic

The strongest review context appears when R progress, trend support, candle close quality, controlled pullback depth, and normal volatility fit align.

When these conditions align, the Review Score rises and the panel state becomes easier to interpret.


📊 When to Use

• Active directional moves after structure expansion
• Trend continuation environments
• Breakout follow-through review
• Trade-management review after favorable progress
• Charts where users want R-style context without a full manual RR planner


⚠️ When NOT to Use

• Very low-liquidity symbols
• Extremely noisy ranges
• News shock candles with distorted ATR behavior
• Non-standard chart types that alter candle structure
• Situations where the user needs exact broker-level stop management


🎛️ Key Inputs

• Sensitivity → changes how quickly or strictly the script activates a management context.

• Structure Lookback → controls the recent structure boundary used for activation.

• BE Review Trigger (R) → sets the R threshold for review-zone activation.

• Invalidation Shelf Buffer ATR → controls how much ATR padding is added beyond the latest swing.

• Pullback Warning Depth (R) → controls when post-review pullback risk is marked.

• Visual settings → control labels, zones, progress fill, line extension, candle tint, and object limits.

• Panel settings → control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The panel follows the AGPro public-release standard with one merged blue header row containing only the script name.

The chart is designed to stay active but not crowded. It uses a single review zone, clean context lines, a subtle progress fill, and capped event labels.

Label and panel font sizes are adjustable, with Normal as the default.


🧪 Practical Usage Workflow

1. Read the panel Review Score and Progress State.

2. Check whether price is below, inside, or beyond the BE review zone.

3. Compare Current R with best favorable R to understand whether progress is expanding or pulling back.

4. Confirm whether trend support is still aligned.

5. Treat alerts as review prompts, not as automated trade actions.


🔍 Interpretation Guidelines

A high score means the move has progressed toward the review zone with stronger internal structure according to the script's rules.

A low score means the move is early, weak, stale, pulling back, or structurally invalidated.

The most useful interpretation comes from reading score, state, trend support, and invalidation together instead of relying on a single label.


🚫 What This Script Is NOT

• Not a prediction engine
• Not financial advice
• Not auto trading
• Not guaranteed signals
• Not a position sizing calculator
• Not a manual risk/reward visualizer
• Not a take-profit planner


⚠️ Limitations & Transparency

The activation model is rule-based and depends on recent structure, ATR, candle behavior, and trend filters.

Different timeframes can produce different activation references and invalidation shelves.

Fast volatility expansion can make R progress move quickly, while low volatility can keep contexts stale.

No rule-based tool can know a user's actual broker order, risk tolerance, or execution plan.


🧠 Market Context Notes

Breakeven review is most useful when progress, structure, and volatility are read together.

A move can reach a review zone while still having weak trend support or heavy pullback risk.

The script is designed to keep those differences visible.


🧾 Use Case Examples

When price breaks recent structure, trend support is aligned, and current R approaches the BE review threshold, the panel may shift from Building to Approaching Review.

When current R reaches the configured BE trigger and the score is strong, the script marks the review zone and can trigger a high-quality review alert.

When best favorable R was strong but current R pulls back by the configured amount, the script marks Pullback Watch instead of treating the move as automatically healthy.


🧱 System Philosophy

The AGPro approach is to turn chart information into structured decision context.

This script follows that philosophy by converting move progress into a clean review framework: activation, invalidation, R progress, trend support, pullback risk, and next review state.


🔐 Non-Promise Statement

This script does not provide certainty.

It does not guarantee that a breakeven review will improve trade outcome.

It only organizes the conditions that may make breakeven review context more visible.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, execution, risk management, and decisions.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the tool to study how active moves progress, stall, pull back, or invalidate around a structured management threshold.

## Source Code

````pine
// -------------------------------------------------
// Breakeven Review Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Breakeven Review Planner is a trade-management context engine that evaluates
// whether an already moving chart has progressed far enough to deserve
// breakeven protection review. It maps an automatic activation reference,
// structural invalidation shelf, current R progress, trend support, pullback
// risk, and next review state without becoming a manual risk/reward visualizer,
// position sizing tool, or automated trade instruction system.
// -------------------------------------------------

//@version=6
indicator("Breakeven Review Planner [AGPro Series]",
     shorttitle = "AG Pro BEP",
     overlay = true,
     max_lines_count = 80,
     max_labels_count = 80,
     max_boxes_count = 40)

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
// Inputs
// -------------------------------------------------
groupMove = "Move Detection"
sensitivityInput = input.string("Balanced", "Sensitivity", options = ["Early", "Balanced", "Strict"], group = groupMove,
     tooltip = "Controls how demanding the activation model is. Early reacts faster, Balanced is the default publication preset, and Strict requires cleaner impulse and trend support.")
structureLookback = input.int(28, "Structure Lookback", minval = 10, maxval = 160, group = groupMove,
     tooltip = "Lookback used to detect the recent range that a new management context must escape before it can become active.")
swingLen = input.int(5, "Swing Confirmation Length", minval = 2, maxval = 20, group = groupMove,
     tooltip = "Confirmed swing length used to build the structural invalidation shelf. Higher values create fewer but more meaningful shelves.")
emaFastLen = input.int(21, "Fast Trend EMA", minval = 5, maxval = 100, group = groupMove,
     tooltip = "Fast trend filter used to decide whether the active move has directional support.")
emaSlowLen = input.int(55, "Slow Trend EMA", minval = 10, maxval = 200, group = groupMove,
     tooltip = "Slow trend filter used with the fast EMA to grade directional support behind the move.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupMove,
     tooltip = "ATR length used for activation buffers, invalidation padding, zone width, label offsets, and volatility-fit scoring.")

groupPlanner = "Breakeven Review Model"
beTriggerR = input.float(1.0, "BE Review Trigger (R)", minval = 0.50, maxval = 2.50, step = 0.05, group = groupPlanner,
     tooltip = "R-progress threshold where the script marks the move as ready for breakeven protection review. This is a review marker, not an instruction.")
reviewBandR = input.float(0.15, "Review Zone Width (R)", minval = 0.05, maxval = 0.50, step = 0.01, group = groupPlanner,
     tooltip = "Vertical thickness of the BE review zone around the trigger level, measured as a fraction of the initial risk proxy.")
invalidationAtrBuffer = input.float(0.35, "Invalidation Shelf Buffer ATR", minval = 0.0, maxval = 2.0, step = 0.05, group = groupPlanner,
     tooltip = "ATR padding added beyond the latest confirmed swing when building the invalidation shelf.")
minImpulseAtr = input.float(0.35, "Minimum Activation Impulse ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = groupPlanner,
     tooltip = "Minimum close distance beyond the recent structure boundary, measured in ATR. Higher values reduce weak activations.")
minRiskAtr = input.float(0.45, "Minimum Risk Unit ATR", minval = 0.10, maxval = 3.0, step = 0.05, group = groupPlanner,
     tooltip = "Minimum distance between activation reference and invalidation shelf. Prevents tiny risk units from producing distorted R readings.")
pullbackWarnR = input.float(0.45, "Pullback Warning Depth (R)", minval = 0.10, maxval = 1.50, step = 0.05, group = groupPlanner,
     tooltip = "When current R falls this far from best favorable R after review progress, the script marks pullback risk.")
maxActiveBars = input.int(90, "Maximum Active Context Bars", minval = 20, maxval = 300, group = groupPlanner,
     tooltip = "Maximum age of an active management context before slow progress can be marked as stale.")
minReviewScore = input.int(62, "Minimum High-Quality Review Score", minval = 35, maxval = 90, group = groupPlanner,
     tooltip = "Score threshold used for high-quality BE review labels and alerts.")

groupVisual = "Visual Controls"
showContextLines = input.bool(true, "Show Context Lines", group = groupVisual,
     tooltip = "Displays the activation reference, BE review trigger, and invalidation shelf for the latest active context.")
showReviewZone = input.bool(true, "Show BE Review Zone", group = groupVisual,
     tooltip = "Draws the concept-native BE review zone centered on the breakeven review trigger.")
showProgressFill = input.bool(true, "Show Progress Fill", group = groupVisual,
     tooltip = "Highlights the live distance between activation reference and current price so R progress can be read quickly.")
showEventLabels = input.bool(true, "Show Event Labels", group = groupVisual,
     tooltip = "Shows activation, R-progress, BE review, pullback-risk, and invalidation labels with automatic object limits.")
showCandleTint = input.bool(true, "Tint Review Candles", group = groupVisual,
     tooltip = "Applies a subtle candle tint on activation and BE review bars to improve first-glance readability.")
zoneForwardBars = input.int(18, "Zone Forward Bars", minval = 4, maxval = 80, group = groupVisual,
     tooltip = "Number of bars the BE review zone projects forward from the current bar.")
lineForwardBars = input.int(10, "Line Forward Bars", minval = 2, maxval = 60, group = groupVisual,
     tooltip = "Number of bars active reference lines extend to the right of the latest candle.")
cooldownBars = input.int(12, "Visual Cooldown Bars", minval = 0, maxval = 80, group = groupVisual,
     tooltip = "Minimum spacing between non-critical event labels. This protects chart readability while keeping enough context visible.")
maxVisibleLabels = input.int(5, "Maximum Visible Labels", minval = 4, maxval = 40, group = groupVisual,
     tooltip = "Maximum number of historical event labels kept on chart. The default keeps the chart active without becoming crowded.")
labelOffsetAtr = input.float(1.00, "Label Offset ATR", minval = 0.10, maxval = 4.0, step = 0.05, group = groupVisual,
     tooltip = "Vertical distance between labels and candles, measured in ATR. Increase this when labels feel too close to price.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls chart label size. Normal is the default AGPro public-release setting.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows the AGPro status panel with review score, current R, BE trigger, progress state, trend support, and next review action.")
panelPositionInput = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = groupPanel,
     tooltip = "Selects where the AGPro panel is displayed on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Controls the panel color theme. Dark follows the default AGPro premium palette; Light is provided for bright chart layouts.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls panel text size. Normal is the default AGPro public-release setting.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float lowValue, float highValue) =>
    math.max(lowValue, math.min(value, highValue))

// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_label_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posName) =>
    switch posName
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_fmt_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_fmt_r(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "R"

f_grade(float score) =>
    score >= 85 ? "A+" : score >= 74 ? "A" : score >= 62 ? "B" : score >= 48 ? "C" : "D"

f_trim_events(array<label> itemArray, array<line> connectorArray, int maxItems) =>
    while array.size(itemArray) > maxItems
        label.delete(array.shift(itemArray))
        line.delete(array.shift(connectorArray))

f_clear_panel(table panelId, color transparentBg) =>
    for row = 0 to 8
        table.cell(panelId, 0, row, "", bgcolor = transparentBg, text_color = transparentBg, text_size = size.tiny)
        if row > 0
            table.cell(panelId, 1, row, "", bgcolor = transparentBg, text_color = transparentBg, text_size = size.tiny)

labelSize = f_label_size(labelSizeInput)
panelSize = f_label_size(panelSizeInput)
panelPos = f_panel_pos(panelPositionInput)

isLightPanel = panelThemeInput == "Light"
panelBgFinal = isLightPanel ? color.rgb(248, 250, 252) : panelBg
panelBorderFinal = isLightPanel ? color.rgb(203, 213, 225) : panelBorder
panelLabelFinal = isLightPanel ? color.rgb(71, 85, 105) : panelLabelCol
panelValueFinal = isLightPanel ? color.rgb(15, 23, 42) : panelValueCol

sensitivityFactor = sensitivityInput == "Early" ? 0.72 : sensitivityInput == "Strict" ? 1.28 : 1.0
minBodyRatio = sensitivityInput == "Early" ? 0.32 : sensitivityInput == "Strict" ? 0.52 : 0.42
minCloseLocation = sensitivityInput == "Early" ? 0.58 : sensitivityInput == "Strict" ? 0.70 : 0.64

// -------------------------------------------------
// Core Market State
// -------------------------------------------------
atr = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
atrBase = ta.sma(atr, 50)
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
volAvg = ta.sma(volume, 20)
volRatio = volAvg > 0 ? volume / volAvg : 1.0

barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyRatio = bodySize / barRange
bullCloseLocation = (close - low) / barRange
bearCloseLocation = (high - close) / barRange

pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var int lastSwingHighBar = na
var float lastSwingLow = na
var int lastSwingLowBar = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - swingLen

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - swingLen

priorHigh = ta.highest(high, structureLookback)[1]
priorLow = ta.lowest(low, structureLookback)[1]

trendBullEarly = close > emaSlow
trendBearEarly = close < emaSlow
trendBullBalanced = emaFast > emaSlow and close > emaFast
trendBearBalanced = emaFast < emaSlow and close < emaFast
trendBullStrict = emaFast > emaSlow and emaFast > emaFast[3] and close > emaFast
trendBearStrict = emaFast < emaSlow and emaFast < emaFast[3] and close < emaFast

trendBullOk = sensitivityInput == "Early" ? trendBullEarly : sensitivityInput == "Strict" ? trendBullStrict : trendBullBalanced
trendBearOk = sensitivityInput == "Early" ? trendBearEarly : sensitivityInput == "Strict" ? trendBearStrict : trendBearBalanced

breakBuffer = atr * minImpulseAtr * sensitivityFactor
bullActivationRaw = not na(priorHigh) and close > priorHigh + breakBuffer and close > open and bodyRatio >= minBodyRatio and bullCloseLocation >= minCloseLocation and trendBullOk
bearActivationRaw = not na(priorLow) and close < priorLow - breakBuffer and close < open and bodyRatio >= minBodyRatio and bearCloseLocation >= minCloseLocation and trendBearOk

fallbackBullInvalid = ta.lowest(low, structureLookback) - atr * invalidationAtrBuffer
fallbackBearInvalid = ta.highest(high, structureLookback) + atr * invalidationAtrBuffer
bullInvalidCandidate = not na(lastSwingLow) ? lastSwingLow - atr * invalidationAtrBuffer : fallbackBullInvalid
bearInvalidCandidate = not na(lastSwingHigh) ? lastSwingHigh + atr * invalidationAtrBuffer : fallbackBearInvalid
bullRiskCandidate = close - bullInvalidCandidate
bearRiskCandidate = bearInvalidCandidate - close
validBullRisk = bullRiskCandidate > math.max(atr * minRiskAtr, syminfo.mintick * 10)
validBearRisk = bearRiskCandidate > math.max(atr * minRiskAtr, syminfo.mintick * 10)

// -------------------------------------------------
// Active Context State
// -------------------------------------------------
var int activeSide = 0
var float activeEntry = na
var float activeInvalidation = na
var float activeRisk = na
var int activeBar = na
var float bestFavorableR = 0.0
var float nextMilestoneR = 0.5
var bool reviewSeen = false
var bool pullbackSeen = false
var bool invalidSeen = false
var bool staleSeen = false
var int lastLabelBar = na

// Activation follow-through proof: after a context arms, does price follow
// through in the armed direction (1.5 ATR) before reversing (1.0 ATR)?
var float bepProofTarget = na
var float bepProofStop   = na
var int   bepProofDir    = 0
var bool  bepProofOpen   = false
var int   bepProofAge    = na
var int   bepProofWins   = 0
var int   bepProofLosses = 0

var line entryLine = na
var line reviewLine = na
var line invalidLine = na
var box reviewBox = na
var box progressBox = na
var label reviewZoneLabel = na
var label entryBadge = na
var label invalidationBadge = na
var array<label> eventLabels = array.new_label()
var array<line> eventConnectors = array.new_line()

// Vertical anti-collision: lift a new label clear of every recent label within
// "win" bars on the same side. One-off events use a wide window; repeating
// milestones use a narrow one so a trend never stacks them upward.
f_bump_y(float baseY, bool above, int win) =>
    float result = baseY
    int sz = array.size(eventLabels)
    float gap = atr * labelOffsetAtr * 1.40
    int checks = math.min(sz, 6)
    if checks > 0
        for k = 1 to checks
            label prev = array.get(eventLabels, sz - k)
            if bar_index - label.get_x(prev) <= win
                float prevY = label.get_y(prev)
                if above and result < prevY + gap and result > prevY - gap
                    result := prevY + gap
                else if not above and result > prevY - gap and result < prevY + gap
                    result := prevY - gap
    result

wasActive = activeSide != 0 and not na(activeEntry) and not na(activeRisk) and activeRisk > 0
currentRRaw = wasActive ? activeSide == 1 ? (close - activeEntry) / activeRisk : (activeEntry - close) / activeRisk : na
ageBarsRaw = wasActive ? bar_index - activeBar : na
currentlyInvalid = wasActive and (activeSide == 1 ? low <= activeInvalidation : high >= activeInvalidation)
currentlyStale = wasActive and not invalidSeen and ageBarsRaw > maxActiveBars and nz(currentRRaw, 0.0) < beTriggerR * 0.55
canStartNew = not wasActive or invalidSeen or staleSeen or currentlyInvalid or currentlyStale or (bullActivationRaw and activeSide == -1) or (bearActivationRaw and activeSide == 1)

bullStartEvent = false
bearStartEvent = false
reviewEvent = false
pullbackEvent = false
invalidEvent = false
staleEvent = false

startBull = canStartNew and bullActivationRaw and validBullRisk
startBear = canStartNew and bearActivationRaw and validBearRisk

if startBull or startBear
    activeSide := startBull ? 1 : -1
    activeEntry := close
    activeInvalidation := startBull ? bullInvalidCandidate : bearInvalidCandidate
    activeRisk := startBull ? bullRiskCandidate : bearRiskCandidate
    activeBar := bar_index
    bestFavorableR := 0.0
    nextMilestoneR := 0.5
    reviewSeen := false
    pullbackSeen := false
    invalidSeen := false
    staleSeen := false
    bullStartEvent := startBull
    bearStartEvent := startBear
    if showEventLabels
        anchorY = startBull ? high : low
        y = f_bump_y(startBull ? anchorY + atr * labelOffsetAtr : anchorY - atr * labelOffsetAtr, startBull, 7)
        txt = startBull ? "BULL CONTEXT | ARMED" : "BEAR CONTEXT | ARMED"
        bg = startBull ? bullColor : bearColor
        st = startBull ? label.style_label_down : label.style_label_up
        newConnector = line.new(bar_index, anchorY, bar_index, y, xloc = xloc.bar_index, extend = extend.none, color = color.new(bg, 28), width = 1)
        newLabel = label.new(bar_index, y, txt, xloc = xloc.bar_index, style = st, color = bg, textcolor = f_text_on(bg), size = labelSize)
        array.push(eventLabels, newLabel)
        array.push(eventConnectors, newConnector)
        f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
        lastLabelBar := bar_index

isActive = activeSide != 0 and not na(activeEntry) and not na(activeRisk) and activeRisk > 0
ageBars = isActive ? bar_index - activeBar : na
currentR = isActive ? activeSide == 1 ? (close - activeEntry) / activeRisk : (activeEntry - close) / activeRisk : na
favorableR = isActive ? activeSide == 1 ? (high - activeEntry) / activeRisk : (activeEntry - low) / activeRisk : na

if isActive and not invalidSeen and not staleSeen
    bestFavorableR := math.max(bestFavorableR, nz(favorableR, 0.0))
    reviewLinePrice = activeEntry + activeSide * activeRisk * beTriggerR

    labelAllowed = na(lastLabelBar) or bar_index - lastLabelBar >= cooldownBars
    if showEventLabels and labelAllowed and currentR >= nextMilestoneR and nextMilestoneR < beTriggerR
        anchorY = activeSide == 1 ? high : low
        y = f_bump_y(activeSide == 1 ? anchorY + atr * labelOffsetAtr : anchorY - atr * labelOffsetAtr, activeSide == 1, 7)
        txt = f_fmt_r(nextMilestoneR) + " | BUILD"
        st = activeSide == 1 ? label.style_label_down : label.style_label_up
        bg = activeSide == 1 ? color.new(bullColor, 10) : color.new(bearColor, 10)
        newConnector = line.new(bar_index, anchorY, bar_index, y, xloc = xloc.bar_index, extend = extend.none, color = color.new(activeSide == 1 ? bullColor : bearColor, 28), width = 1)
        newLabel = label.new(bar_index, y, txt, xloc = xloc.bar_index, style = st, color = bg, textcolor = f_text_on(bg), size = labelSize)
        array.push(eventLabels, newLabel)
        array.push(eventConnectors, newConnector)
        f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
        lastLabelBar := bar_index
        nextMilestoneR += 0.5

    if not reviewSeen and currentR >= beTriggerR
        reviewSeen := true
        reviewEvent := true
        if showEventLabels
            anchorY = activeSide == 1 ? high : low
            y = f_bump_y(activeSide == 1 ? anchorY + atr * labelOffsetAtr : anchorY - atr * labelOffsetAtr, activeSide == 1, 14)
            txt = "BE REVIEW | " + f_fmt_r(currentR)
            st = activeSide == 1 ? label.style_label_down : label.style_label_up
            bg = color.new(accentColor, 0)
            newConnector = line.new(bar_index, anchorY, bar_index, y, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 28), width = 1)
            newLabel = label.new(bar_index, y, txt, xloc = xloc.bar_index, style = st, color = bg, textcolor = f_text_on(bg), size = labelSize)
            array.push(eventLabels, newLabel)
            array.push(eventConnectors, newConnector)
            f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
            lastLabelBar := bar_index
        nextMilestoneR := math.max(nextMilestoneR, beTriggerR + 0.5)

    labelAllowedAfterReview = na(lastLabelBar) or bar_index - lastLabelBar >= cooldownBars
    if showEventLabels and labelAllowedAfterReview and reviewSeen and currentR >= nextMilestoneR and nextMilestoneR <= 3.0
        anchorY = activeSide == 1 ? high : low
        y = f_bump_y(activeSide == 1 ? anchorY + atr * labelOffsetAtr : anchorY - atr * labelOffsetAtr, activeSide == 1, 7)
        txt = f_fmt_r(nextMilestoneR) + " | PROGRESS"
        st = activeSide == 1 ? label.style_label_down : label.style_label_up
        bg = activeSide == 1 ? color.new(bullColor, 0) : color.new(bearColor, 0)
        newConnector = line.new(bar_index, anchorY, bar_index, y, xloc = xloc.bar_index, extend = extend.none, color = color.new(activeSide == 1 ? bullColor : bearColor, 28), width = 1)
        newLabel = label.new(bar_index, y, txt, xloc = xloc.bar_index, style = st, color = bg, textcolor = f_text_on(bg), size = labelSize)
        array.push(eventLabels, newLabel)
        array.push(eventConnectors, newConnector)
        f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
        lastLabelBar := bar_index
        nextMilestoneR += 0.5

    if reviewSeen and not pullbackSeen and bestFavorableR - currentR >= pullbackWarnR
        pullbackSeen := true
        pullbackEvent := true
        if showEventLabels
            anchorY = activeSide == 1 ? high : low
            y = f_bump_y(activeSide == 1 ? anchorY + atr * labelOffsetAtr : anchorY - atr * labelOffsetAtr, activeSide == 1, 14)
            txt = "PULLBACK | WATCH"
            st = activeSide == 1 ? label.style_label_down : label.style_label_up
            newConnector = line.new(bar_index, anchorY, bar_index, y, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 28), width = 1)
            newLabel = label.new(bar_index, y, txt, xloc = xloc.bar_index, style = st, color = neutralColor, textcolor = color.rgb(20, 24, 31), size = labelSize)
            array.push(eventLabels, newLabel)
            array.push(eventConnectors, newConnector)
            f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
            lastLabelBar := bar_index

    activeInvalidHit = activeSide == 1 ? low <= activeInvalidation : high >= activeInvalidation
    if activeInvalidHit
        invalidSeen := true
        invalidEvent := true
        if showEventLabels
            anchorY = activeSide == 1 ? low : high
            y = f_bump_y(activeSide == 1 ? anchorY - atr * labelOffsetAtr : anchorY + atr * labelOffsetAtr, activeSide == -1, 14)
            txt = "CONTEXT | INVALID"
            st = activeSide == 1 ? label.style_label_up : label.style_label_down
            newConnector = line.new(bar_index, anchorY, bar_index, y, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 28), width = 1)
            newLabel = label.new(bar_index, y, txt, xloc = xloc.bar_index, style = st, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
            array.push(eventLabels, newLabel)
            array.push(eventConnectors, newConnector)
            f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
            lastLabelBar := bar_index

    if not invalidSeen and ageBars > maxActiveBars and currentR < beTriggerR * 0.55
        staleSeen := true
        staleEvent := true
        if showEventLabels
            anchorY = activeSide == 1 ? high : low
            y = f_bump_y(activeSide == 1 ? anchorY + atr * labelOffsetAtr : anchorY - atr * labelOffsetAtr, activeSide == 1, 14)
            txt = "NO PROGRESS | STALE"
            st = activeSide == 1 ? label.style_label_down : label.style_label_up
            newConnector = line.new(bar_index, anchorY, bar_index, y, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 28), width = 1)
            newLabel = label.new(bar_index, y, txt, xloc = xloc.bar_index, style = st, color = neutralColor, textcolor = color.rgb(20, 24, 31), size = labelSize)
            array.push(eventLabels, newLabel)
            array.push(eventConnectors, newConnector)
            f_trim_events(eventLabels, eventConnectors, maxVisibleLabels)
            lastLabelBar := bar_index

// -------------------------------------------------
// Activation proof (stop-aware, confirmed-bar gated)
// -------------------------------------------------
if barstate.isconfirmed
    if (startBull or startBear) and not bepProofOpen
        bepProofDir    := startBull ? 1 : -1
        bepProofTarget := startBull ? close + atr * 1.5 : close - atr * 1.5
        bepProofStop   := startBull ? close - atr * 1.0 : close + atr * 1.0
        bepProofAge    := 0
        bepProofOpen   := true
    if bepProofOpen and not na(bepProofTarget) and not na(bepProofStop)
        bool bepHitStop   = bepProofDir == 1 ? close <= bepProofStop : close >= bepProofStop
        bool bepHitTarget = bepProofDir == 1 ? close >= bepProofTarget : close <= bepProofTarget
        if bepHitStop
            bepProofLosses += 1
            bepProofOpen := false
        else if bepHitTarget
            bepProofWins += 1
            bepProofOpen := false
        else
            bepProofAge := nz(bepProofAge) + 1
            if bepProofAge > 25
                bepProofOpen := false

int   bepProofTotal = bepProofWins + bepProofLosses
float bepProofRate  = bepProofTotal == 0 ? 0.0 : 100.0 * bepProofWins / bepProofTotal
string proofText = bepProofTotal < 6 ? "Building (" + str.tostring(bepProofTotal) + ")" : str.tostring(math.round(bepProofRate)) + "% (" + str.tostring(bepProofTotal) + ")"
color proofCol = bepProofTotal < 6 ? panelLabelFinal : bepProofRate >= 55 ? bullColor : bepProofRate >= 45 ? neutralColor : bearColor

// -------------------------------------------------
// Score And State
// -------------------------------------------------
trendSupported = isActive and (activeSide == 1 ? emaFast > emaSlow and close > emaFast : emaFast < emaSlow and close < emaFast)
trendNeutral = isActive and not trendSupported and (activeSide == 1 ? close > emaSlow : close < emaSlow)
sideCloseLocation = isActive ? activeSide == 1 ? bullCloseLocation : bearCloseLocation : na
sideBodyDirection = isActive ? activeSide == 1 ? close >= open : close <= open : false
pullbackDepthR = isActive ? math.max(bestFavorableR - nz(currentR, 0.0), 0.0) : na
atrRatio = atrBase > 0 ? atr / atrBase : 1.0

progressScore = isActive ? f_clamp(nz(currentR, 0.0) / math.max(beTriggerR, 0.1), 0.0, 1.0) * 35.0 : 0.0
trendScore = trendSupported ? 20.0 : trendNeutral ? 10.0 : 0.0
candleScore = isActive ? (f_clamp(sideCloseLocation, 0.0, 1.0) * 0.65 + (sideBodyDirection ? f_clamp(bodyRatio, 0.0, 1.0) : 0.0) * 0.35) * 18.0 : 0.0
pullbackScore = isActive ? (1.0 - f_clamp(nz(pullbackDepthR, 0.0) / math.max(pullbackWarnR, 0.1), 0.0, 1.0)) * 15.0 : 0.0
volatilityScore = isActive ? (atrRatio >= 0.55 and atrRatio <= 1.65 ? 12.0 : atrRatio <= 2.25 ? 7.0 : 3.0) : 0.0
reviewScoreRaw = progressScore + trendScore + candleScore + pullbackScore + volatilityScore
reviewScore = invalidSeen or staleSeen ? math.min(reviewScoreRaw, invalidSeen ? 24.0 : 38.0) : reviewScoreRaw
reviewScoreRounded = math.round(reviewScore)

progressState =
     not isActive ? "Waiting" :
     invalidSeen ? "Invalidated" :
     staleSeen ? "Stale" :
     reviewSeen and pullbackSeen ? "Review + Pullback" :
     reviewSeen ? "BE Review Active" :
     currentR >= beTriggerR * 0.70 ? "Approaching Review" :
     currentR > 0 ? "Building" :
     "At Risk"

trendText =
     not isActive ? "Waiting" :
     trendSupported ? "Supported" :
     trendNeutral ? "Neutral" :
     "Weak"

actionText =
     not isActive ? "Wait For Context" :
     invalidSeen ? "Context Invalid" :
     staleSeen ? "Reset Review" :
     reviewSeen and pullbackSeen ? "Monitor Pullback" :
     reviewSeen ? "Review Protection" :
     currentR >= beTriggerR * 0.70 ? "Prepare Review" :
     "Let Move Build"

stateColor =
     invalidSeen ? bearColor :
     staleSeen ? neutralColor :
     reviewSeen and reviewScoreRounded >= minReviewScore ? bullColor :
     reviewSeen ? accentColor :
     progressState == "Building" or progressState == "Approaching Review" ? neutralColor :
     panelValueFinal

// -------------------------------------------------
// Active Visuals
// -------------------------------------------------
activeLineColor = invalidSeen or staleSeen ? color.new(panelLabelCol, 35) : activeSide == 1 ? bullColor : activeSide == -1 ? bearColor : panelLabelCol
activeFillColor = activeSide == 1 ? color.new(bullColor, 88) : activeSide == -1 ? color.new(bearColor, 88) : color.new(accentColor, 92)
transparent = color.new(panelBg, 100)

if isActive
    beLinePrice = activeEntry + activeSide * activeRisk * beTriggerR
    lineRight = bar_index + lineForwardBars
    zoneRight = bar_index + zoneForwardBars
    zoneHalf = activeRisk * reviewBandR
    zoneTop = beLinePrice + zoneHalf
    zoneBottom = beLinePrice - zoneHalf
    fillTop = math.max(activeEntry, close)
    fillBottom = math.min(activeEntry, close)

    if na(entryLine)
        entryLine := line.new(activeBar, activeEntry, lineRight, activeEntry, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 1)
        reviewLine := line.new(activeBar, beLinePrice, lineRight, beLinePrice, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 2)
        invalidLine := line.new(activeBar, activeInvalidation, lineRight, activeInvalidation, xloc = xloc.bar_index, color = color.new(bearColor, 0), width = 1, style = line.style_dashed)
    else
        line.set_xy1(entryLine, activeBar, activeEntry)
        line.set_xy2(entryLine, lineRight, activeEntry)
        line.set_xy1(reviewLine, activeBar, beLinePrice)
        line.set_xy2(reviewLine, lineRight, beLinePrice)
        line.set_xy1(invalidLine, activeBar, activeInvalidation)
        line.set_xy2(invalidLine, lineRight, activeInvalidation)

    line.set_color(entryLine, showContextLines ? color.new(accentColor, invalidSeen or staleSeen ? 45 : 0) : transparent)
    line.set_color(reviewLine, showContextLines ? color.new(accentColor, invalidSeen or staleSeen ? 45 : 0) : transparent)
    line.set_color(invalidLine, showContextLines ? color.new(bearColor, invalidSeen or staleSeen ? 50 : 0) : transparent)

    if showContextLines
        color entryBadgeColor = invalidSeen or staleSeen ? color.new(accentColor, 35) : accentColor
        color invalidBadgeColor = invalidSeen ? bearColor : color.new(bearColor, staleSeen ? 35 : 0)
        if na(entryBadge)
            entryBadge := label.new(lineRight, activeEntry, "ENTRY | " + f_fmt_price(activeEntry), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = entryBadgeColor, textcolor = f_text_on(entryBadgeColor), size = labelSize)
        else
            label.set_xy(entryBadge, lineRight, activeEntry)
            label.set_text(entryBadge, "ENTRY | " + f_fmt_price(activeEntry))
            label.set_color(entryBadge, entryBadgeColor)
            label.set_textcolor(entryBadge, f_text_on(entryBadgeColor))
            label.set_size(entryBadge, labelSize)
        if na(invalidationBadge)
            invalidationBadge := label.new(lineRight, activeInvalidation, "INVALIDATION | " + f_fmt_price(activeInvalidation), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = invalidBadgeColor, textcolor = f_text_on(invalidBadgeColor), size = labelSize)
        else
            label.set_xy(invalidationBadge, lineRight, activeInvalidation)
            label.set_text(invalidationBadge, "INVALIDATION | " + f_fmt_price(activeInvalidation))
            label.set_color(invalidationBadge, invalidBadgeColor)
            label.set_textcolor(invalidationBadge, f_text_on(invalidBadgeColor))
            label.set_size(invalidationBadge, labelSize)
    else
        if not na(entryBadge)
            label.delete(entryBadge)
            entryBadge := na
        if not na(invalidationBadge)
            label.delete(invalidationBadge)
            invalidationBadge := na

    if na(reviewBox)
        reviewBox := box.new(activeBar, zoneTop, zoneRight, zoneBottom, xloc = xloc.bar_index, border_color = color.new(accentColor, 35), bgcolor = color.new(accentColor, 88))
    else
        box.set_lefttop(reviewBox, activeBar, zoneTop)
        box.set_rightbottom(reviewBox, zoneRight, zoneBottom)
    box.set_border_color(reviewBox, showReviewZone ? color.new(accentColor, invalidSeen or staleSeen ? 75 : 35) : transparent)
    box.set_bgcolor(reviewBox, showReviewZone ? color.new(accentColor, invalidSeen or staleSeen ? 94 : 88) : transparent)

    if na(progressBox)
        progressBox := box.new(activeBar, fillTop, bar_index, fillBottom, xloc = xloc.bar_index, border_color = color.new(activeLineColor, 85), bgcolor = activeFillColor)
    else
        box.set_lefttop(progressBox, activeBar, fillTop)
        box.set_rightbottom(progressBox, bar_index, fillBottom)
    box.set_border_color(progressBox, showProgressFill ? color.new(activeLineColor, 78) : transparent)
    box.set_bgcolor(progressBox, showProgressFill ? activeFillColor : transparent)

    zoneMidX = int(math.round((activeBar + zoneRight) / 2.0))
    zoneMidY = (zoneTop + zoneBottom) / 2.0
    zoneText = invalidSeen ? "BE REVIEW INVALID | " + f_fmt_r(beTriggerR) : staleSeen ? "BE REVIEW STALE | " + f_fmt_r(beTriggerR) : reviewSeen ? "BE REVIEW ACTIVE | " + f_fmt_r(beTriggerR) : "BE REVIEW ZONE | " + f_fmt_r(beTriggerR)
    zoneBadgeColor = invalidSeen ? bearColor : staleSeen ? neutralColor : reviewSeen ? accentColor : accentColor
    zoneTextColor = f_text_on(zoneBadgeColor)
    if na(reviewZoneLabel)
        reviewZoneLabel := label.new(zoneMidX, zoneMidY, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = zoneBadgeColor, textcolor = zoneTextColor, size = labelSize)
    else
        label.set_xy(reviewZoneLabel, zoneMidX, zoneMidY)
        label.set_text(reviewZoneLabel, zoneText)
        label.set_size(reviewZoneLabel, labelSize)
        label.set_color(reviewZoneLabel, showReviewZone ? zoneBadgeColor : transparent)
        label.set_textcolor(reviewZoneLabel, showReviewZone ? zoneTextColor : transparent)

barTint =
     reviewEvent ? color.new(accentColor, 72) :
     bullStartEvent ? color.new(bullColor, 78) :
     bearStartEvent ? color.new(bearColor, 78) :
     na
barcolor(showCandleTint ? barTint : na)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table statusPanel = table.new(position.top_right, 2, 9, bgcolor = panelBgFinal, frame_color = panelBorderFinal, frame_width = 1, border_color = panelBorderFinal, border_width = 1)
var bool headerMerged = false

if not headerMerged
    table.merge_cells(statusPanel, 0, 0, 1, 0)
    headerMerged := true

if barstate.islast
    table.set_position(statusPanel, panelPos)
    if showPanel
        table.cell(statusPanel, 0, 0, "AG Pro Breakeven Review Planner", bgcolor = headerBg, text_color = headerText, text_size = panelSize, text_halign = text.align_center)
        table.cell(statusPanel, 0, 1, "Review Score", bgcolor = panelBgFinal, text_color = panelLabelFinal, text_size = panelSize)
        table.cell(statusPanel, 1, 1, isActive ? str.tostring(reviewScoreRounded, "#") + " / 100  " + f_grade(reviewScore) : "Waiting", bgcolor = panelBgFinal, text_color = stateColor, text_size = panelSize)
        table.cell(statusPanel, 0, 2, "Current R", bgcolor = panelBgFinal, text_color = panelLabelFinal, text_size = panelSize)
        table.cell(statusPanel, 1, 2, isActive ? f_fmt_r(currentR) + "  best " + f_fmt_r(bestFavorableR) : "n/a", bgcolor = panelBgFinal, text_color = panelValueFinal, text_size = panelSize)
        table.cell(statusPanel, 0, 3, "BE Trigger", bgcolor = panelBgFinal, text_color = panelLabelFinal, text_size = panelSize)
        table.cell(statusPanel, 1, 3, isActive ? f_fmt_r(beTriggerR) + " @ " + f_fmt_price(activeEntry + activeSide * activeRisk * beTriggerR) : f_fmt_r(beTriggerR), bgcolor = panelBgFinal, text_color = accentColor, text_size = panelSize)
        table.cell(statusPanel, 0, 4, "Progress State", bgcolor = panelBgFinal, text_color = panelLabelFinal, text_size = panelSize)
        table.cell(statusPanel, 1, 4, progressState, bgcolor = panelBgFinal, text_color = stateColor, text_size = panelSize)
        table.cell(statusPanel, 0, 5, "Trend Support", bgcolor = panelBgFinal, text_color = panelLabelFinal, text_size = panelSize)
        table.cell(statusPanel, 1, 5, trendText, bgcolor = panelBgFinal, text_color = trendSupported ? bullColor : trendText == "Weak" ? bearColor : neutralColor, text_size = panelSize)
        table.cell(statusPanel, 0, 6, "Action", bgcolor = panelBgFinal, text_color = panelLabelFinal, text_size = panelSize)
        table.cell(statusPanel, 1, 6, actionText, bgcolor = panelBgFinal, text_color = stateColor, text_size = panelSize)
        table.cell(statusPanel, 0, 7, "Invalidation", bgcolor = panelBgFinal, text_color = panelLabelFinal, text_size = panelSize)
        table.cell(statusPanel, 1, 7, isActive ? f_fmt_price(activeInvalidation) : "n/a", bgcolor = panelBgFinal, text_color = invalidSeen ? bearColor : panelValueFinal, text_size = panelSize)
        table.cell(statusPanel, 0, 8, "Proof", bgcolor = panelBgFinal, text_color = panelLabelFinal, text_size = panelSize)
        table.cell(statusPanel, 1, 8, proofText, bgcolor = panelBgFinal, text_color = proofCol, text_size = panelSize)
    else
        f_clear_panel(statusPanel, color.new(panelBgFinal, 100))

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
highQualityReview = reviewEvent and reviewScoreRounded >= minReviewScore

alertcondition(bullStartEvent, title = "Bullish BE Review Context Activated", message = "Breakeven Review Planner: bullish management context activated.")
alertcondition(bearStartEvent, title = "Bearish BE Review Context Activated", message = "Breakeven Review Planner: bearish management context activated.")
alertcondition(reviewEvent, title = "BE Review Zone Reached", message = "Breakeven Review Planner: price reached the configured breakeven review zone.")
alertcondition(highQualityReview, title = "High Quality BE Review", message = "Breakeven Review Planner: breakeven review zone reached with high review quality.")
alertcondition(pullbackEvent, title = "Pullback Risk After BE Review", message = "Breakeven Review Planner: pullback risk increased after breakeven review progress.")
alertcondition(invalidEvent, title = "BE Review Context Invalidated", message = "Breakeven Review Planner: active management context reached its invalidation shelf.")
alertcondition(staleEvent, title = "BE Review Context Stale", message = "Breakeven Review Planner: active management context became stale before enough progress.")

plot(isActive ? currentR : na, "Current R", display = display.none)
plot(isActive ? reviewScoreRounded : na, "Review Score", display = display.none)
plot(isActive ? activeEntry + activeSide * activeRisk * beTriggerR : na, "BE Review Trigger", display = display.none)
plot(isActive ? activeInvalidation : na, "Invalidation Shelf", display = display.none)
````
