# Exit Readiness Planner [AGPro Series]

- url: https://www.tradingview.com/script/kVUTgQFz-Exit-Readiness-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;81df43bc285c40ef91621cb099fe63b2
- version: 4.0

## Description

Exit Readiness Planner [AGPro Series]

🧠 Core Idea

Is the active move showing enough decay to prepare an exit review?


📌 Overview / What it does

Exit Readiness Planner is a chart-first trade management tool built to evaluate whether an active move is losing enough quality to deserve closer review. Its cleanest default use case is 4H swing-management review, where structure, target proximity, and decay are usually easier to read than on very small timeframes.

The script converts momentum decay, candle-efficiency loss, target proximity, volatility contraction, and reversal pressure into a 0-100 Exit Readiness Score. It produces an exit-pressure zone, target and risk-shift rails, exhaustion fade context, compact state labels, alerts, and a clean AGPro panel.

It does not predict price direction, automate exits, or print direct sell commands. Its purpose is to organize exit-review context while the user remains responsible for all decisions.


🎯 Purpose & Design Philosophy

Many traders plan entries carefully but review exits only after momentum has already faded. This script was built to make the exit-review question more structured.

It helps traders who manage active moves and want a cleaner way to monitor whether the move still has room, strength, and volatility support, or whether it is shifting into a review state.

The design supports a management mindset: read the current pressure, check remaining room, review exhaustion, then decide what deserves attention.


⚡ Why This Script Is Different

Most tools focus on take-profit ladders, trailing stops, or direct exit signals.

This script does NOT build a profit-target ladder, a Chandelier Exit clone, a stop-loss optimizer, or a buy/sell command system.

Instead, it asks a narrower decision question: is the active move showing enough decay, target proximity, or risk-shift pressure to prepare an exit review?


⚙️ Methodology

1. Context Detection
The script identifies the active move side using Auto Context, Long Move, or Short Move.

2. Reference Mapping
It maps target-side structure, remaining room, a fast trend reference, and an exit-pressure zone around the active target rail.

3. Reaction Evaluation
The model scores momentum decay, candle-efficiency loss, target proximity, volatility contraction, and reversal pressure.

4. Visual Output
The output appears as a forward exit-pressure zone, exhaustion fade band, compact labels, alert conditions, and a premium AGPro panel.


🗺️ How to Read the Chart

Zones = the forward exit-pressure area near the active target rail.

Labels = clear attention markers such as EXIT REVIEW, EXIT WATCH, TARGET NEAR, RISK SHIFT, or PRESSURE EASED.

Colors = teal suggests calmer monitor context, amber suggests watch or target proximity, pink/red suggests stronger exit-review pressure.

Panel = summarizes Exit Pressure, Remaining Room, Exhaustion State, Risk Shift, and Action.


🚦 Signals & States

• EXIT REVIEW → the score and supporting conditions show stronger decay or pressure.

• EXIT WATCH → review context is developing but is not yet in the stronger review state.

• TARGET NEAR → price is close to the active target-side reference.

• RISK SHIFT → pressure appeared against the active move near the trend reference.

• MONITOR → exit pressure is not strong enough for active review attention.


🔔 Alerts Logic

• Exit Readiness Review → triggers when the planner enters Exit Review state.

• Exit Readiness Watch → triggers when watch context appears.

• Target Near → triggers when price becomes close to the active target rail.

• Risk Shift → triggers when pressure appears against the active move.

• Pressure Eased → triggers when active pressure returns to monitor context.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The strongest review context appears when momentum decay, candle-efficiency loss, target proximity, volatility contraction, and reversal pressure align.

When only one factor appears, the state may remain Watch or Monitor. When several factors align, the score can move toward Exit Review.


📊 When to Use

• During active trade management.

• Especially on 4H swing-management charts.

• When price is approaching a target-side reference.

• During trend moves that may be losing momentum.

• After strong directional candles begin to compress.

• On liquid symbols where ATR and pivot references are meaningful.


⚠️ When NOT to Use

• Extremely low-liquidity markets with unreliable candles.

• News spikes where volatility changes too quickly.

• Very noisy micro-timeframes with unstable wick behavior.

• As a standalone reason to close a position.

• When the user has no broader trade plan or risk framework.


🎛️ Key Inputs

• Active Move Side → selects Auto Context, Long Move, or Short Move.

• Sensitivity → controls how quickly decay and pressure affect the score.

• Lookback → defines the structure window for target references and room.

• Exit Review Score → sets the threshold for the stronger review state.

• Exit Watch Score → sets the lower attention threshold.

• Visual Settings → control zones, rails, fade bands, labels, optional move-side prefixes, optional micro markers, panel visibility, theme, location, and font sizes.


🖥️ Interface & Visual Design

The interface is chart-first and built around one primary visual object: the exit-pressure zone.

The panel uses the AGPro publication layout with a single merged blue title row, adjustable location, adjustable theme, and adjustable font size.

Labels use clear full-text state names, offset from candles, and are controlled by cooldown and maximum-visible settings to keep the chart active without becoming crowded. Move-side prefixes and tiny micro markers are available but disabled by default for a cleaner 4H publication preset.


🧪 Practical Usage Workflow

1. Read the panel Action state.

2. Check the Exit Pressure score.

3. Review the remaining room to the active target rail.

4. Compare the exhaustion state with candle behavior.

5. Treat alerts and labels as review prompts, not trade commands.


🔍 Interpretation Guidelines

A high score means the script sees more exit-review pressure according to its rules. It does not mean price must reverse.

Target Near means remaining room is compressed relative to ATR. It does not mean the target must hold.

Risk Shift means pressure appeared against the active move. It should be interpreted with timeframe, volatility, and broader structure.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a sell-signal service.

• Not a take-profit ladder.

• Not a trailing-stop strategy.


⚠️ Limitations & Transparency

Exit-readiness behavior depends on the selected lookback, ATR length, target pivot length, sensitivity, timeframe, and market condition.

Low volatility can make target proximity more frequent. High volatility can widen references and delay review states. Small timeframes can produce more frequent state changes.

The script is rule-based and should be read as an analytical management layer inside a broader plan.


🧠 Market Context Notes

An active move can remain valid while still deserving review.

Exit readiness is not the same as bearish or bullish prediction. It is a structured way to notice when the move may be losing quality, nearing a reference, or showing pressure against the active side.


🧾 Use Case Examples

When price approaches the target rail and candle efficiency falls, the planner may move from Monitor to Exit Watch.

When target proximity, momentum decay, and reversal pressure align, the planner may mark Exit Review.

When pressure eases and the move regains quality, the script can return to Monitor.


🧱 System Philosophy

Exit Readiness Planner follows the AGPro decision-engine approach:

Context before reaction.
Review before emotion.
Attention markers instead of commands.


🔐 Non-Promise Statement

No indicator can guarantee continuation, reversal, target behavior, or exit timing.

This tool provides structured chart context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk controls, position sizing, and trading decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use the script to study how exit-review pressure changes as momentum fades, room compresses, volatility contracts, and pressure appears against the active move.

## Source Code

````pine
// -------------------------------------------------
// Exit Readiness Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Exit Readiness Planner is a chart-first trade management map for reviewing
// when an active move may be losing quality. It blends momentum decay,
// candle-efficiency loss, target proximity, volatility contraction and
// reversal pressure into a transparent 0-100 readiness score, a clear action
// state and a persistent outcome-proof layer that tracks how often an
// Exit Review was followed by real deterioration. The script is a visual
// trade-management decision-support planner for profit-taking and exit timing,
// not a prediction engine, direct exit command or automated trading system.
// -------------------------------------------------

//@version=6
indicator("Exit Readiness Planner [AGPro Series]",
     shorttitle = "AG ERP",
     overlay = true,
     max_labels_count = 100,
     max_boxes_count = 8,
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
ttSideMode = "Selects the active move side used for exit-readiness review. Auto Context follows trend structure; manual modes keep the planner fixed to long-side or short-side management context."
ttSensitivity = "Controls how quickly the planner reacts to decay. Reactive raises the effect of momentum loss, opposite pressure, and volatility contraction."
ttLookback = "Main structure window used to define target proximity, remaining room, exhaustion context, and recent move quality."
ttAtrLength = "ATR length used to normalize labels, zones, remaining room, volatility contraction, and projection spacing."
ttTrendLength = "EMA length used to identify active move context and risk-shift behavior. This is a management reference, not an entry signal."
ttMomentumLength = "Lookback used to compare current directional momentum with the prior directional move. Shorter values react faster."
ttTargetPivot = "Pivot length used to collect nearby target references. Higher values produce fewer but more deliberate target rails."
ttMinimumScore = "Minimum 0-100 score required before the script marks Exit Review context. This is an attention state only."
ttWatchScore = "Minimum 0-100 score required before the script marks Exit Watch context. Watch means review context is developing."
ttConfirmation = "Close Confirmed waits for closed bars before labels and alerts. Live Updating can react during the active bar."
ttZoneDepth = "ATR-based depth of the forward exit-pressure zone around the active target rail."
ttProjection = "Number of bars used to project the exit-pressure zone, target rail, and risk-shift rail to the right."
ttShowZone = "Shows the concept-native exit-pressure zone near the active target rail. A separate filled badge summarizes the state and score."
ttShowBands = "Shows the exhaustion fade band between fast and slow trend references when exit pressure is active."
ttShowRails = "Shows compact target and risk-shift rails used by the planner."
ttShowLabels = "Shows moderate event and context labels for review, watch, target proximity, and risk-shift conditions."
ttContextLabels = "Adds sparse context labels while exit pressure remains active so the chart remains informative without becoming crowded."
ttShowMarkers = "Shows tiny markers in addition to labels. Off by default because labels already provide the main public chart story."
ttShowSidePrefix = "Adds Long Move or Short Move to chart labels. Off by default because the panel already shows active side context."
ttCooldown = "Minimum bars between labels. Higher values reduce label density and improve readability."
ttMaxObjects = "Maximum number of visible labels retained on chart. Older labels are removed first for performance."
ttLabelOffset = "ATR-based offset that keeps labels above or below candles instead of buried inside price bars."
ttShowScore = "Adds the 0-100 readiness score to label text while keeping labels compact."
ttLabelSize = "Controls all chart label, zone badge, and right-side tag sizes. Normal is the recommended publication default."
ttShowPanel = "Shows or hides the AG Pro panel. The panel is visible by default for public-release readability."
ttPanelLocation = "Moves the panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark theme and a clean light theme."
ttPanelFont = "Controls panel text size. Normal is the recommended publication default."
ttProofWindow = "Number of bars used to resolve each Exit Review proof sample. After an Exit Review event, the planner checks whether the active move deteriorated within this window before extending favorably."
ttProofMove = "ATR-normalized distance used to resolve the proof. A win is recorded when price first travels this far against the active move (deterioration confirmed) rather than first extending the move favorably."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Exit Readiness Engine"
sideMode = input.string("Auto Context", "Active Move Side", options = ["Auto Context", "Long Move", "Short Move"], group = groupEngine, tooltip = ttSideMode)
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Reactive"], group = groupEngine, tooltip = ttSensitivity)
lookback = input.int(72, "Lookback", minval = 20, maxval = 300, group = groupEngine, tooltip = ttLookback)
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 80, group = groupEngine, tooltip = ttAtrLength)
trendLength = input.int(34, "Trend Reference Length", minval = 8, maxval = 200, group = groupEngine, tooltip = ttTrendLength)
momentumLength = input.int(8, "Momentum Decay Length", minval = 3, maxval = 50, group = groupEngine, tooltip = ttMomentumLength)
targetPivotLength = input.int(5, "Target Pivot Length", minval = 2, maxval = 20, group = groupEngine, tooltip = ttTargetPivot)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirmation)

groupScoring = "Readiness Score"
minimumScore = input.float(70.0, "Exit Review Score", minval = 45.0, maxval = 95.0, step = 1.0, group = groupScoring, tooltip = ttMinimumScore)
watchScore = input.float(56.0, "Exit Watch Score", minval = 30.0, maxval = 90.0, step = 1.0, group = groupScoring, tooltip = ttWatchScore)
targetNearAtr = input.float(1.10, "Target Near ATR", minval = 0.25, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = "ATR-normalized distance that defines when price is close enough to the target rail to increase exit-review pressure.")
targetFarAtr = input.float(3.40, "Target Far ATR", minval = 0.75, maxval = 10.00, step = 0.10, group = groupScoring, tooltip = "ATR-normalized distance considered enough remaining room. Larger values make target-proximity pressure less frequent.")
volContractionRef = input.int(5, "Volatility Contraction Bars", minval = 2, maxval = 30, group = groupScoring, tooltip = "Compares current ATR with recent ATR to detect whether the active move is losing volatility support.")

groupProof = "Outcome Proof"
proofWindow = input.int(20, "Proof Window Bars", minval = 4, maxval = 120, group = groupProof, tooltip = ttProofWindow)
proofMoveAtr = input.float(1.00, "Proof Move ATR", minval = 0.25, maxval = 4.00, step = 0.05, group = groupProof, tooltip = ttProofMove)

groupVisual = "Visuals"
showExitZone = input.bool(true, "Show Exit-Pressure Zone", group = groupVisual, tooltip = ttShowZone)
showFadeBand = input.bool(true, "Show Exhaustion Fade Band", group = groupVisual, tooltip = ttShowBands)
showGuideRails = input.bool(true, "Show Target / Risk Rails", group = groupVisual, tooltip = ttShowRails)
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = "Displays compact right-side tags for active target and risk-shift references.")
zoneDepthAtr = input.float(0.55, "Zone Depth ATR", minval = 0.15, maxval = 2.50, step = 0.05, group = groupVisual, tooltip = ttZoneDepth)
projectionBars = input.int(34, "Forward Projection Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttProjection)

groupLabels = "Labels"
showLabels = input.bool(true, "Show Labels", group = groupLabels, tooltip = ttShowLabels)
showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
showMicroMarkers = input.bool(false, "Show Micro Markers", group = groupLabels, tooltip = ttShowMarkers)
showSidePrefix = input.bool(false, "Show Move Side In Labels", group = groupLabels, tooltip = ttShowSidePrefix)
labelCooldownBars = input.int(26, "Label Cooldown Bars", minval = 2, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(52, "Context Label Spacing", minval = 12, maxval = 180, group = groupLabels, tooltip = "Minimum spacing for sparse context labels while the move remains in review or watch state.")
maxVisibleLabels = input.int(10, "Max Visible Labels", minval = 4, maxval = 60, group = groupLabels, tooltip = ttMaxObjects)
labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttShowScore)
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

f_panel_color(color sourceColor, string theme) =>
    if theme == "Light"
        sourceColor == bullColor ? color.rgb(5, 105, 88) : sourceColor == bearColor ? color.rgb(190, 24, 93) : sourceColor == neutralColor ? color.rgb(146, 92, 10) : sourceColor == accentColor ? color.rgb(67, 56, 202) : sourceColor == dangerColor ? color.rgb(185, 28, 28) : sourceColor
    else
        sourceColor

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = f_panel_color(rightColor, theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_grade(float score) =>
    score >= 84.0 ? "A" : score >= 72.0 ? "B" : score >= 60.0 ? "C" : score >= 45.0 ? "D" : "E"

f_state_color(string stateText) =>
    switch stateText
        "Exit Review" => dangerColor
        "Exit Watch" => neutralColor
        "Target Near" => accentColor
        "Risk Shift" => bearColor
        "Pressure Eased" => bullColor
        => bullColor

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
// Core Measurements
// -------------------------------------------------
confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
fastTrendLength = math.max(2, int(math.round(trendLength * 0.50)))
fastTrend = ta.ema(close, fastTrendLength)
slowTrend = ta.ema(close, trendLength)
trendSlope = slowTrend - nz(slowTrend[5], slowTrend)
rangeHigh = nz(ta.highest(high, lookback), high)
rangeLow = nz(ta.lowest(low, lookback), low)
rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangePosition = f_clamp((close - rangeLow) / rangeSpan, 0.0, 1.0)

autoSide = 0
if fastTrend >= slowTrend and trendSlope >= 0.0
    autoSide := 1
else if fastTrend <= slowTrend and trendSlope <= 0.0
    autoSide := -1
else
    autoSide := rangePosition >= 0.50 ? 1 : -1

activeSide = sideMode == "Long Move" ? 1 : sideMode == "Short Move" ? -1 : autoSide
sideText = activeSide == 1 ? "Long Move" : "Short Move"

directionalMove = activeSide == 1 ? close - nz(close[momentumLength], close) : nz(close[momentumLength], close) - close
priorDirectionalMove = activeSide == 1 ? nz(close[momentumLength], close) - nz(close[momentumLength * 2], nz(close[momentumLength], close)) : nz(close[momentumLength * 2], nz(close[momentumLength], close)) - nz(close[momentumLength], close)
moveAtr = directionalMove / safeAtr
priorMoveAtr = priorDirectionalMove / safeAtr
decayRaw = priorMoveAtr - moveAtr
sensitivityBoost = sensitivity == "Reactive" ? 1.18 : sensitivity == "Conservative" ? 0.88 : 1.0
momentumDecayScore = f_norm_high_good(decayRaw * sensitivityBoost, -0.15, 1.15)
momentumDecayScore := moveAtr < 0.0 ? math.max(momentumDecayScore, 72.0) : momentumDecayScore

candleRange = math.max(high - low, syminfo.mintick)
bodyRatio = math.abs(close - open) / candleRange
closeLocation = f_clamp((close - low) / candleRange, 0.0, 1.0)
directionalCloseQuality = activeSide == 1 ? closeLocation : 1.0 - closeLocation
efficiencyLossScore = f_clamp((1.0 - bodyRatio) * 42.0 + (1.0 - directionalCloseQuality) * 58.0, 0.0, 100.0)

pivotHigh = ta.pivothigh(high, targetPivotLength, targetPivotLength)
pivotLow = ta.pivotlow(low, targetPivotLength, targetPivotLength)
var array<float> highPivots = array.new<float>()
var array<float> lowPivots = array.new<float>()

if not na(pivotHigh)
    array.push(highPivots, pivotHigh)
    while array.size(highPivots) > 36
        array.shift(highPivots)

if not na(pivotLow)
    array.push(lowPivots, pivotLow)
    while array.size(lowPivots) > 36
        array.shift(lowPivots)

nearestTarget = activeSide == 1 ? rangeHigh : rangeLow
if activeSide == 1 and array.size(highPivots) > 0
    for idx = 0 to array.size(highPivots) - 1
        level = array.get(highPivots, idx)
        if level > close and (na(nearestTarget) or level < nearestTarget)
            nearestTarget := level

if activeSide == -1 and array.size(lowPivots) > 0
    for idx = 0 to array.size(lowPivots) - 1
        level = array.get(lowPivots, idx)
        if level < close and (na(nearestTarget) or level > nearestTarget)
            nearestTarget := level

fallbackTarget = close + activeSide * safeAtr * targetFarAtr
targetLevel = activeSide == 1 ? nearestTarget > close ? nearestTarget : fallbackTarget : nearestTarget < close ? nearestTarget : fallbackTarget
remainingRoomAtr = math.max(activeSide == 1 ? (targetLevel - close) / safeAtr : (close - targetLevel) / safeAtr, 0.0)
targetProximityScore = f_norm_low_good(remainingRoomAtr, targetNearAtr, targetFarAtr)

atrPast = nz(atr[volContractionRef], atr)
atrRatio = atrPast > 0.0 ? atr / atrPast : 1.0
atrBase = nz(ta.sma(atr, atrLength * 3), atr)
atrBaseRatio = atrBase > 0.0 ? atr / atrBase : 1.0
contractionScore = f_clamp(f_norm_low_good(atrRatio, 0.72, 1.08) * 0.62 + f_norm_low_good(atrBaseRatio, 0.78, 1.18) * 0.38, 0.0, 100.0)

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
oppositeWickRatio = activeSide == 1 ? upperWick / candleRange : lowerWick / candleRange
oppositeClose = activeSide == 1 ? close < open : close > open
riskShiftRaw = activeSide == 1 ? close < fastTrend and close[1] >= fastTrend[1] : close > fastTrend and close[1] <= fastTrend[1]
reversalPressureScore = f_clamp(oppositeWickRatio * 70.0 + (oppositeClose ? 18.0 : 0.0) + (riskShiftRaw ? 24.0 : 0.0), 0.0, 100.0)

scoreRaw = momentumDecayScore * 0.28 + efficiencyLossScore * 0.20 + targetProximityScore * 0.22 + contractionScore * 0.14 + reversalPressureScore * 0.16
exitReadinessScore = f_clamp(scoreRaw, 0.0, 100.0)
effectiveReviewScore = math.max(minimumScore, watchScore + 1.0)
effectiveWatchScore = math.min(watchScore, effectiveReviewScore - 1.0)

targetNear = remainingRoomAtr <= targetNearAtr
decayStrong = momentumDecayScore >= 65.0 and efficiencyLossScore >= 50.0
exhaustionActive = exitReadinessScore >= effectiveWatchScore and (decayStrong or targetNear or reversalPressureScore >= 62.0)
reviewActive = exitReadinessScore >= effectiveReviewScore and exhaustionActive
watchActive = exitReadinessScore >= effectiveWatchScore and exhaustionActive

exhaustionState = reviewActive ? "Heavy Decay" : watchActive ? "Developing" : targetNear ? "Target Near" : "Normal"
riskShiftState = riskShiftRaw ? "Shift Triggered" : reversalPressureScore >= 60.0 ? "Pressure Rising" : "Stable"
actionState = reviewActive ? "Exit Review" : riskShiftRaw and exitReadinessScore >= effectiveWatchScore ? "Risk Shift" : targetNear and exitReadinessScore >= effectiveWatchScore - 6.0 ? "Target Near" : watchActive ? "Exit Watch" : "Monitor"
actionColor = f_state_color(actionState)

// -------------------------------------------------
// Events
// -------------------------------------------------
var string lastActionState = ""
reviewEvent = confirmedBar and actionState == "Exit Review" and lastActionState != "Exit Review"
watchEvent = confirmedBar and actionState == "Exit Watch" and lastActionState != "Exit Watch"
targetEvent = confirmedBar and targetNear and not targetNear[1]
riskShiftEvent = confirmedBar and riskShiftRaw
pressureReleaseEvent = confirmedBar and (lastActionState == "Exit Review" or lastActionState == "Exit Watch") and actionState == "Monitor"

// -------------------------------------------------
// Outcome Proof
// Every confirmed Exit Review receives an independent frozen test. A win means
// deterioration reached its threshold before favorable extension. Same-bar
// threshold conflicts resolve conservatively as non-wins.
// -------------------------------------------------
var int proofTotal = 0
var int proofWin = 0
var array<int> proofSides = array.new<int>()
var array<float> proofFavLevels = array.new<float>()
var array<float> proofAdvLevels = array.new<float>()
var array<int> proofStartBars = array.new<int>()

if barstate.isconfirmed
    proofCountAtOpen = array.size(proofSides)
    if proofCountAtOpen > 0
        for step = 0 to proofCountAtOpen - 1
            i = proofCountAtOpen - 1 - step
            proofSide = array.get(proofSides, i)
            proofFavLevel = array.get(proofFavLevels, i)
            proofAdvLevel = array.get(proofAdvLevels, i)
            proofStartBar = array.get(proofStartBars, i)
            if bar_index > proofStartBar
                favHit = proofSide == 1 ? high >= proofFavLevel : low <= proofFavLevel
                advHit = proofSide == 1 ? low <= proofAdvLevel : high >= proofAdvLevel
                expired = bar_index - proofStartBar >= proofWindow
                if favHit or advHit or expired
                    proofTotal += 1
                    if advHit and not favHit
                        proofWin += 1
                    array.remove(proofSides, i)
                    array.remove(proofFavLevels, i)
                    array.remove(proofAdvLevels, i)
                    array.remove(proofStartBars, i)
    if reviewEvent
        proofMoveDist = safeAtr * proofMoveAtr
        array.push(proofSides, activeSide)
        array.push(proofFavLevels, close + activeSide * proofMoveDist)
        array.push(proofAdvLevels, close - activeSide * proofMoveDist)
        array.push(proofStartBars, bar_index)

// -------------------------------------------------
// Visual Objects
// -------------------------------------------------
labelSize = f_text_size(labelFontSize)
zoneRight = bar_index + projectionBars
zoneTopRaw = activeSide == 1 ? targetLevel : targetLevel + safeAtr * zoneDepthAtr
zoneBottomRaw = activeSide == 1 ? targetLevel - safeAtr * zoneDepthAtr : targetLevel
zoneTop = math.max(zoneTopRaw, zoneBottomRaw)
zoneBottom = math.min(zoneTopRaw, zoneBottomRaw)
riskShiftLevel = fastTrend
zoneVisible = showExitZone and (watchActive or reviewActive or targetNear)
zoneColor = reviewActive ? dangerColor : targetNear ? accentColor : neutralColor

var box exitZone = na
var box fadeBand = na
var line targetRail = na
var line riskShiftRail = na
var label zoneBadge = na
var label fadeBadge = na
var label targetTag = na
var label riskTag = na

if zoneVisible
    if na(exitZone)
        exitZone := box.new(bar_index, zoneTop, zoneRight, zoneBottom, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, reviewActive ? 86 : 90), border_color = color.new(zoneColor, 30), border_width = 1)
    else
        box.set_lefttop(exitZone, bar_index, zoneTop)
        box.set_rightbottom(exitZone, zoneRight, zoneBottom)
        box.set_bgcolor(exitZone, color.new(zoneColor, reviewActive ? 86 : 90))
        box.set_border_color(exitZone, color.new(zoneColor, 30))
    centerX = int(math.round((bar_index + zoneRight) / 2.0))
    centerY = (zoneTop + zoneBottom) * 0.5
    badgeText = "EXIT PRESSURE | Q " + str.tostring(math.round(exitReadinessScore)) + " | " + str.upper(actionState)
    if na(zoneBadge)
        zoneBadge := label.new(centerX, centerY, "", xloc = xloc.bar_index, style = label.style_label_center, color = zoneColor, textcolor = f_text_on(zoneColor), size = labelSize)
    f_set_label(zoneBadge, centerX, centerY, badgeText, zoneColor, label.style_label_center, labelSize)
else
    if not na(exitZone)
        box.delete(exitZone)
        exitZone := na
    if not na(zoneBadge)
        label.delete(zoneBadge)
        zoneBadge := na

if showFadeBand and exhaustionActive
    bandTop = math.max(fastTrend, slowTrend)
    bandBottom = math.min(fastTrend, slowTrend)
    bandColor = reviewActive ? dangerColor : neutralColor
    bandRight = bar_index + math.max(6, int(math.round(projectionBars * 0.55)))
    bandCenterX = int(math.round((bar_index + bandRight) / 2.0))
    bandCenterY = (bandTop + bandBottom) * 0.5
    if na(fadeBand)
        fadeBand := box.new(bar_index, bandTop, bandRight, bandBottom, xloc = xloc.bar_index, bgcolor = color.new(bandColor, 91), border_color = color.new(bandColor, 62), border_width = 1)
    else
        box.set_lefttop(fadeBand, bar_index, bandTop)
        box.set_rightbottom(fadeBand, bandRight, bandBottom)
        box.set_bgcolor(fadeBand, color.new(bandColor, 91))
        box.set_border_color(fadeBand, color.new(bandColor, 62))
    if na(fadeBadge)
        fadeBadge := label.new(bandCenterX, bandCenterY, "", xloc = xloc.bar_index, style = label.style_label_center, color = bandColor, textcolor = f_text_on(bandColor), size = labelSize)
    f_set_label(fadeBadge, bandCenterX, bandCenterY, "EXHAUSTION | " + str.upper(exhaustionState), bandColor, label.style_label_center, labelSize)
else
    if not na(fadeBand)
        box.delete(fadeBand)
        fadeBand := na
    if not na(fadeBadge)
        label.delete(fadeBadge)
        fadeBadge := na

if showGuideRails and (zoneVisible or exhaustionActive)
    if na(targetRail)
        targetRail := line.new(bar_index, targetLevel, zoneRight, targetLevel, xloc = xloc.bar_index, color = color.new(accentColor, 0), width = 2, style = line.style_dotted)
    else
        line.set_xy1(targetRail, bar_index, targetLevel)
        line.set_xy2(targetRail, zoneRight, targetLevel)
        line.set_color(targetRail, color.new(accentColor, 0))
    if na(riskShiftRail)
        riskShiftRail := line.new(bar_index, riskShiftLevel, zoneRight, riskShiftLevel, xloc = xloc.bar_index, color = color.new(actionColor, 16), width = 1, style = line.style_dashed)
    else
        line.set_xy1(riskShiftRail, bar_index, riskShiftLevel)
        line.set_xy2(riskShiftRail, zoneRight, riskShiftLevel)
        line.set_color(riskShiftRail, color.new(actionColor, 16))
    if showRightTags
        targetTagX = zoneRight + 3
        riskTagX = zoneRight + 12
        if na(targetTag)
            targetTag := label.new(targetTagX, targetLevel, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
        f_set_label(targetTag, targetTagX, targetLevel, "Target " + str.tostring(targetLevel, format.mintick), accentColor, label.style_label_left, labelSize)
        if na(riskTag)
            riskTag := label.new(riskTagX, riskShiftLevel, "", xloc = xloc.bar_index, style = label.style_label_left, color = actionColor, textcolor = f_text_on(actionColor), size = labelSize)
        f_set_label(riskTag, riskTagX, riskShiftLevel, "Risk Shift " + str.tostring(riskShiftLevel, format.mintick), actionColor, label.style_label_left, labelSize)
    else
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na
        if not na(riskTag)
            label.delete(riskTag)
            riskTag := na
else
    if not na(targetRail)
        line.delete(targetRail)
        targetRail := na
    if not na(riskShiftRail)
        line.delete(riskShiftRail)
        riskShiftRail := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na
    if not na(riskTag)
        label.delete(riskTag)
        riskTag := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var int lastLabelBar = na
var array<label> stateLabels = array.new_label()
labelReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
stateEvent = reviewEvent or watchEvent or targetEvent or riskShiftEvent or pressureReleaseEvent
contextEvent = showContextLabels and confirmedBar and labelReady and exhaustionActive and (na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars)
drawLabel = showLabels and labelReady and (stateEvent or contextEvent)

if drawLabel
    labelText = reviewEvent ? "Exit Review" : watchEvent ? "Exit Watch" : riskShiftEvent ? "Risk Shift" : targetEvent ? "Target Near" : pressureReleaseEvent ? "Pressure Eased" : actionState
    labelColor = f_state_color(labelText)
    if showLabelScore and not pressureReleaseEvent
        labelText += " | Q " + str.tostring(math.round(exitReadinessScore))
    if showSidePrefix
        labelText := sideText + " | " + labelText
    labelY = activeSide == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    labelStyle = activeSide == 1 ? label.style_label_down : label.style_label_up
    newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(labelColor, 4), textcolor = f_text_on(labelColor), size = labelSize, textalign = text.align_center)
    array.push(stateLabels, newLabel)
    f_trim_labels(stateLabels, maxVisibleLabels)
    lastLabelBar := bar_index

plotshape(showMicroMarkers and reviewEvent and activeSide == 1, title = "Long Exit Review Marker", style = shape.diamond, location = location.abovebar, color = color.new(dangerColor, 0), size = size.tiny)
plotshape(showMicroMarkers and reviewEvent and activeSide == -1, title = "Short Exit Review Marker", style = shape.diamond, location = location.belowbar, color = color.new(dangerColor, 0), size = size.tiny)
plotshape(showMicroMarkers and riskShiftEvent and activeSide == 1, title = "Long Risk Shift Marker", style = shape.circle, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)
plotshape(showMicroMarkers and riskShiftEvent and activeSide == -1, title = "Short Risk Shift Marker", style = shape.circle, location = location.belowbar, color = color.new(neutralColor, 0), size = size.tiny)

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(exitReadinessScore, title = "Exit Readiness Score", color = actionColor, display = display.data_window)
plot(momentumDecayScore, title = "Momentum Decay Score", color = neutralColor, display = display.data_window)
plot(efficiencyLossScore, title = "Candle Efficiency Loss", color = bearColor, display = display.data_window)
plot(targetProximityScore, title = "Target Proximity Score", color = accentColor, display = display.data_window)
plot(contractionScore, title = "Volatility Contraction Score", color = bullColor, display = display.data_window)
plot(reversalPressureScore, title = "Reversal Pressure Score", color = dangerColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelShell = f_panel_bg(panelTheme)
panelFrame = f_panel_border(panelTheme)
valueText = f_panel_value(panelTheme)
pressureRead = str.tostring(math.round(exitReadinessScore)) + " / " + f_grade(exitReadinessScore)
roomRead = str.tostring(remainingRoomAtr, "#.00") + " ATR"
exhaustionRead = str.tostring(math.round(momentumDecayScore)) + " / " + exhaustionState
riskShiftRead = str.tostring(math.round(reversalPressureScore)) + " / " + riskShiftState
actionRead = actionState + " / " + sideText
outcomeProofRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na
outcomeProofText = na(outcomeProofRate) ? "Building" : str.tostring(math.round(outcomeProofRate)) + "% (" + str.tostring(proofTotal) + ")"
outcomeProofColor = na(outcomeProofRate) ? valueText : outcomeProofRate >= 55.0 ? bullColor : outcomeProofRate >= 40.0 ? neutralColor : bearColor

var table infoPanel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

panelNeedsReset = showPanel and (na(infoPanel) or panelLocationCache != panelLocation or panelThemeCache != panelTheme)
if panelNeedsReset
    if not na(infoPanel)
        table.delete(infoPanel)
    infoPanel := table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = panelShell, frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
    table.merge_cells(infoPanel, 0, 0, 1, 0)
    panelLocationCache := panelLocation
    panelThemeCache := panelTheme

if not showPanel and not na(infoPanel)
    table.delete(infoPanel)
    infoPanel := na
    panelLocationCache := ""
    panelThemeCache := ""

if showPanel and not na(infoPanel) and barstate.islast
    table.clear(infoPanel, 0, 0, 1, 6)
    table.merge_cells(infoPanel, 0, 0, 1, 0)
    table.cell(infoPanel, 0, 0, "AG Pro Exit Readiness Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
    f_set_row(infoPanel, 1, "Exit Pressure", pressureRead, actionColor, panelTheme, panelFontSize)
    f_set_row(infoPanel, 2, "Remaining Room", roomRead, remainingRoomAtr <= targetNearAtr ? neutralColor : valueText, panelTheme, panelFontSize)
    f_set_row(infoPanel, 3, "Decay / Context", exhaustionRead, momentumDecayScore >= 65.0 ? neutralColor : valueText, panelTheme, panelFontSize)
    f_set_row(infoPanel, 4, "Risk Shift", riskShiftRead, reversalPressureScore >= 62.0 ? bearColor : valueText, panelTheme, panelFontSize)
    f_set_row(infoPanel, 5, "Workflow", actionRead, actionColor, panelTheme, panelFontSize)
    f_set_row(infoPanel, 6, "Outcome Proof", outcomeProofText, outcomeProofColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(reviewEvent, title = "Exit Readiness Review", message = "Exit Readiness Planner: Exit Review context is active. This is an attention marker, not a trade instruction.")
alertcondition(watchEvent, title = "Exit Readiness Watch", message = "Exit Readiness Planner: Exit Watch context is active. Review context is developing.")
alertcondition(targetEvent, title = "Exit Readiness Target Near", message = "Exit Readiness Planner: price is near the active target rail.")
alertcondition(riskShiftEvent, title = "Exit Readiness Risk Shift", message = "Exit Readiness Planner: risk-shift pressure appeared against the active move.")
alertcondition(pressureReleaseEvent, title = "Exit Readiness Pressure Eased", message = "Exit Readiness Planner: exit pressure eased back into monitor context.")

if confirmedBar
    lastActionState := actionState
````
