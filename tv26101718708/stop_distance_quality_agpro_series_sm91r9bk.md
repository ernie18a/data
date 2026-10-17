# Stop Distance Quality [AGPro Series]

- url: https://www.tradingview.com/script/sm91R9Bk-Stop-Distance-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;ba7a87834ced4132b63dd70ed910fbab
- version: 10.0

## Description

Stop Distance Quality [AGPro Series]

🧠 Core Idea

Is the invalidation distance structurally reasonable, or is it too tight, too wide, or too exposed to noise?


📌 Overview / What it does

Stop Distance Quality [AGPro Series] is a chart-first risk planning tool built to evaluate stop-distance quality before a setup is treated as clean.

The script studies the active invalidation rail, ATR-normalized stop distance, swing structure fit, wick risk, volatility context, and available target room. It converts those components into a 0-100 risk-quality score and a clear next-action state.

It produces a stop-fit band, an invalidation rail, an ideal-fit guide, compact chart labels, alerts, and a clean AGPro planning panel. It does not select the best stop method, size positions, predict price direction, or automate trade decisions.


🎯 Purpose & Design Philosophy

This script was built to fill a specific planning gap: many tools show where a stop could be placed, but fewer tools ask whether that stop distance is structurally usable.

It helps traders who already have a setup idea and want to evaluate whether the invalidation distance is balanced enough to keep watching.

The design supports disciplined planning: measure the risk first, then decide whether the setup deserves attention.


⚡ Why This Script Is Different

Most tools focus on plotting stop-loss levels, comparing stop-loss methods, or attaching stops to entry signals.

This script does NOT act as a stop-loss optimizer, position-size calculator, target ladder, or directional signal tool.

Instead, it answers one practical planning question: is the current stop distance too tight, too wide, or reasonably aligned with structure and volatility?


⚙️ Methodology

1. Context Detection
The script selects long or short evaluation context using either manual side selection or automatic trend and range-location reading.

2. Reference Mapping
It maps one active swing-based invalidation rail and builds a stop-fit band using minimum, ideal, and maximum ATR-normalized distance boundaries.

3. Reaction Evaluation
It scores stop distance, swing structure fit, wick risk, volatility context, and target room.

4. Visual Output
It displays the stop-fit band, invalidation rail, ideal-fit guide, chart labels, alerts, and AGPro panel state.


🗺️ How to Read the Chart

Zones = the stop-fit band shows the acceptable ATR-normalized area where the active invalidation distance is considered more balanced.

Labels = labels mark FIT, WATCH, TOO TIGHT, TOO WIDE, NO ROOM, or invalidation-check contexts.

Colors = AGPro green highlights balanced fit, pink highlights wide-risk pressure, amber highlights caution, and indigo highlights active watch context.

Panel = the panel summarizes Stop Distance, ATR Context, Structure Fit, Risk Quality, and Action.


🚦 Signals & States

• FIT → stop distance is structurally reasonable enough for active review.

• WATCH → risk quality is improving but not strong enough for FIT.

• TOO TIGHT → invalidation distance is too close relative to ATR and may be vulnerable to normal noise.

• TOO WIDE → invalidation distance is too large relative to the current chart context.

• NO ROOM → target room is not clean enough for the current risk distance.

• WEAK FIT → the current context does not meet the minimum quality threshold.


🔔 Alerts Logic

Alerts trigger when the script enters FIT, WATCH, TOO TIGHT, TOO WIDE, or NO ROOM state.

An additional alert can trigger when price crosses the prior invalidation rail.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The strongest context appears when stop distance sits near the ideal ATR band, swing structure is clear, wick noise is controlled, volatility is readable, and target room remains open.

When several of these conditions align, the risk-quality score improves.


📊 When to Use

• Before evaluating a risk-defined setup

• During pullbacks where invalidation placement matters

• Around breakout retests where stops can be too tight or too wide

• In structured trending or range-extension environments


⚠️ When NOT to Use

• Very low-liquidity symbols with erratic wicks

• Extremely noisy markets where ATR changes too quickly

• News-driven candles or abnormal event spikes

• Charts where no clear swing invalidation exists


🎛️ Key Inputs

• Evaluation Side → controls Auto, Long Context, or Short Context scoring.

• ATR Length → normalizes stop distance, wick risk, target room, and visual offsets.

• Invalidation Lookback → controls the swing rail used as the active invalidation reference.

• Minimum / Ideal / Maximum Stop ATR → define the stop-fit band.

• FIT / WATCH Thresholds → control how selective the planner is.

• Visual settings → control band visibility, guide lines, labels, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is intentionally narrow and readable.

The chart focuses on one main visual object: the stop-fit band. The panel uses a single merged AGPro header row and keeps the essential risk-quality information visible without turning the script into a dashboard-heavy tool.

Labels are compact, offset from candles, and controlled with cooldown and maximum-visible settings.


🧪 Practical Usage Workflow

1. Read the panel risk-quality state.

2. Check whether the invalidation rail sits inside, below, or beyond the stop-fit band.

3. Review whether the label says FIT, WATCH, TOO TIGHT, TOO WIDE, or NO ROOM.

4. Confirm structure and volatility context before treating the setup as meaningful.


🔍 Interpretation Guidelines

Think of the output as a risk-quality filter, not a trade signal.

A FIT state means the distance is more balanced relative to ATR and structure. It does not mean price must move favorably.

A TOO TIGHT or TOO WIDE state means the risk reference may need more context, more buffer, or a cleaner setup.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a stop-loss optimizer

• Not a position-sizing calculator


⚠️ Limitations & Transparency

Stop-distance quality can change as volatility expands or contracts.

Different timeframes may produce different invalidation rails and ATR readings.

Fast markets, low liquidity, and abnormal wick behavior can reduce the usefulness of any rule-based distance model.


🧠 Market Context Notes

Risk quality is not only about where a stop sits. It also depends on whether volatility is readable, whether the swing reference is meaningful, and whether there is enough room before nearby obstruction.

This script keeps those factors visible without adding unrelated signal logic.


🧾 Use Case Examples

When price pulls back in a trend and the invalidation rail sits inside the stop-fit band, the setup can move into review mode.

When the stop distance is below the minimum ATR boundary, the script may mark TOO TIGHT and suggest waiting for more buffer.

When stop distance is large but target room is limited, the script may mark NO ROOM or TOO WIDE.


🧱 System Philosophy

Stop Distance Quality belongs to the AGPro planner-style family: tools that help traders evaluate context before decisions, rather than simply printing another signal.


🔐 Non-Promise Statement

No output from this script guarantees a result.

No score represents certainty.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, position sizing, and risk management.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

The goal is to make risk distance easier to inspect and compare across changing volatility conditions.

## Source Code

````pine
// -------------------------------------------------
// Stop Distance Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Stop Distance Quality is a chart-first risk planning tool that evaluates whether the
// active invalidation distance is too tight, too wide, or structurally reasonable. It
// scores ATR-normalized stop distance, swing structure fit, wick risk, volatility context,
// and target room into a single 0-100 risk-quality read, and adds a confirmation-anchored
// proof layer (Follow, Hold, React, Flip rates) that shows how past FIT setups on this
// symbol resolved - while staying focused on planning quality, not stop-loss optimization,
// position sizing, prediction, or signal printing.
// -------------------------------------------------

//@version=6
indicator("Stop Distance Quality [AGPro Series]",
     shorttitle       = "AG Pro SDQ",
     overlay          = true,
     max_labels_count = 100,
     max_boxes_count  = 5,
     max_lines_count  = 10)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttPreset = "Selects the operating profile. Balanced Quality is the publication default. Cleaner Swing reduces label density. Active Intraday reacts faster. Custom uses the raw input values."
string ttSide = "Selects the evaluation side. Auto reads trend and range location to choose the active long or short context. Manual modes force one side only."
string ttConfirm = "When enabled, state changes, alerts, and proof evaluation are confirmed only after the bar closes. This keeps public chart behavior stable."
string ttAtrLen = "ATR length used to normalize stop distance, wick risk, target room, visual offsets, and the stop-fit band."
string ttAtrBase = "Longer ATR baseline used to classify whether current volatility is compressed, normal, hot, or extreme."
string ttStructure = "Lookback used to locate the active swing-based invalidation rail. This script evaluates one active invalidation reference, not multiple stop methods."
string ttTarget = "Lookback used to estimate available target room before the nearest recent range edge in the planned direction."
string ttWick = "Lookback used to measure active-side wick noise. Larger wick pressure near invalidation reduces risk-quality confidence."
string ttFast = "Fast EMA used only for automatic side selection and trend context. It does not generate entry signals."
string ttSlow = "Slow EMA used only for automatic side selection and trend context."
string ttBuffer = "ATR buffer around the invalidation rail used to estimate whether nearby swing structure has repeated reactions."
string ttMinStop = "Minimum acceptable ATR-normalized stop distance. Below this value, the invalidation can be too tight and vulnerable to normal noise."
string ttIdealStop = "Preferred ATR-normalized stop distance. The stop-distance score is strongest near this value."
string ttMaxStop = "Maximum acceptable ATR-normalized stop distance. Above this value, the plan is treated as wide risk."
string ttMinRoom = "Minimum ATR-normalized target room required before risk quality can be considered clean."
string ttStrongRoom = "Target-room value that maps to a strong room score. Higher values require more open space."
string ttWickLimit = "Active-side wick pressure that begins to damage the quality score. Lower values make the script stricter in noisy candles."
string ttFit = "Minimum 0-100 quality score required for FIT state. FIT means the stop distance is structurally reasonable, not that a trade should be taken."
string ttWatch = "Minimum 0-100 quality score required for WATCH state. WATCH means the distance is improving but still not clean enough for FIT."
string ttBand = "Shows the acceptable stop-distance band between the minimum and maximum ATR-normalized boundaries. The centered solid badge is the primary chart-first quality readout."
string ttIdeal = "Shows a dotted ideal-fit guide inside the stop-distance band."
string ttRail = "Shows the active swing-based invalidation rail used by the scoring model."
string ttGuideTags = "Shows solid right-side tags for ideal distance, invalidation rail, and target room."
string ttProjection = "Number of bars projected to the right for the band and guide lines."
string ttBandOpacity = "Transparency for the stop-fit band. Higher values make the band lighter."
string ttSmartWidth = "Automatically keeps the stop-fit band tighter on higher timeframes so the visual stays screenshot-friendly."
string ttLabels = "Shows compact FIT, WATCH, TOO TIGHT, TOO WIDE, and NO ROOM labels. Labels are offset away from candles."
string ttContext = "Adds sparse context labels even when the state does not change. Disabled by default for cleaner public screenshots."
string ttInvalidationLabels = "Shows chart labels when price crosses the prior invalidation rail. Alerts remain available even when these labels are hidden."
string ttMarkers = "Shows tiny diamond markers on state changes. Keep this off for the cleanest publication screenshot."
string ttCooldown = "Minimum bars between chart labels. Higher values reduce label density."
string ttContextSpacing = "Minimum bars between sparse context labels during ongoing evaluation."
string ttMaxLabels = "Maximum number of chart labels retained. Older labels are removed first to preserve performance."
string ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
string ttLabelScore = "Adds the 0-100 risk-quality score to chart labels."
string ttLabelSize = "Font size for chart labels, rail tags, and the solid SDQ band badge. Normal is the recommended publication default."
string ttShowPanel = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
string ttProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured from each FIT confirmation on the current symbol and timeframe. Same-bar target-and-stop outcomes are excluded because OHLC data cannot establish event order. These are historical outcome rates, not predictions."
string ttProofHorizon = "Number of bars each FIT confirmation is tracked forward to measure whether the stop held and whether price followed through by one risk multiple (1R)."
string ttReactBars = "Number of bars after a FIT confirmation used to detect an immediate favorable reaction. The effective value is capped at the Proof Horizon. Lower values require a faster initial push to count as a React."
string ttReactProg = "Minimum favorable progress toward one risk multiple, within the reaction window, required to count a confirmation as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Risk Quality Engine"
string enginePreset = input.string("Balanced Quality", "Engine Preset", options = ["Balanced Quality", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = ttPreset)
string sideMode = input.string("Auto", "Evaluation Side", options = ["Auto", "Long Context", "Short Context"], group = groupEngine, tooltip = ttSide)
bool confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirm)
int atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
int atrBaseLen = input.int(55, "ATR Context Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttAtrBase)
int structureLookback = input.int(34, "Invalidation Lookback", minval = 6, maxval = 220, group = groupEngine, tooltip = ttStructure)
int targetLookback = input.int(72, "Target Room Lookback", minval = 10, maxval = 300, group = groupEngine, tooltip = ttTarget)
int wickLookback = input.int(18, "Wick Risk Lookback", minval = 3, maxval = 100, group = groupEngine, tooltip = ttWick)
int fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
int slowEmaLen = input.int(55, "Slow Context EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlow)
float structureBufferAtr = input.float(0.28, "Structure Buffer ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupEngine, tooltip = ttBuffer)

string groupScoring = "Stop Distance Scoring"
float minStopAtr = input.float(0.45, "Minimum Stop ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttMinStop)
float idealStopAtr = input.float(1.15, "Ideal Stop ATR", minval = 0.10, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttIdealStop)
float maxStopAtr = input.float(2.70, "Maximum Stop ATR", minval = 0.20, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = ttMaxStop)
float minRoomAtr = input.float(1.20, "Minimum Target Room ATR", minval = 0.10, maxval = 10.00, step = 0.05, group = groupScoring, tooltip = ttMinRoom)
float strongRoomAtr = input.float(3.20, "Strong Target Room ATR", minval = 0.30, maxval = 20.00, step = 0.10, group = groupScoring, tooltip = ttStrongRoom)
float wickRiskLimit = input.float(0.65, "Wick Risk Limit ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = ttWickLimit)
float fitThreshold = input.float(74.0, "FIT Threshold", minval = 40.0, maxval = 95.0, step = 1.0, group = groupScoring, tooltip = ttFit)
float watchThreshold = input.float(58.0, "WATCH Threshold", minval = 25.0, maxval = 90.0, step = 1.0, group = groupScoring, tooltip = ttWatch)

string groupVisual = "Chart Visuals"
bool showStopBand = input.bool(true, "Show Stop Fit Band", group = groupVisual, tooltip = ttBand)
bool showIdealLine = input.bool(true, "Show Ideal Fit Line", group = groupVisual, tooltip = ttIdeal)
bool showInvalidationRail = input.bool(true, "Show Invalidation Rail", group = groupVisual, tooltip = ttRail)
bool showGuideTags = input.bool(true, "Show Guide Tags", group = groupVisual, tooltip = ttGuideTags)
int projectionBars = input.int(34, "Projection Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttProjection)
int bandTransparency = input.int(91, "Band Transparency", minval = 78, maxval = 96, group = groupVisual, tooltip = ttBandOpacity)
bool smartBandWidth = input.bool(true, "Smart Higher-Timeframe Width", group = groupVisual, tooltip = ttSmartWidth)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
bool showInvalidationLabels = input.bool(false, "Show Invalidation Check Labels", group = groupLabels, tooltip = ttInvalidationLabels)
bool showStateMarkers = input.bool(false, "Show Small State Markers", group = groupLabels, tooltip = ttMarkers)
int labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(80, "Context Label Spacing", minval = 12, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(8, "Max Visible Labels", minval = 3, maxval = 60, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
string labelSizeInput = input.string("Large", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
string panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the panel to the preferred chart location.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Switches the panel between AG Pro dark and clean light themes.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Font size for the AG Pro panel. Normal is the recommended publication default.")

string groupProof = "Proof"
bool showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttProof)
int proofHorizonBars = input.int(16, "Proof Horizon Bars", minval = 4, maxval = 120, group = groupProof, tooltip = ttProofHorizon)
int reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 30, group = groupProof, tooltip = ttReactBars)
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProg)

string groupAlerts = "Alerts"
bool alertFitWatch = input.bool(true, "Alert on FIT and WATCH", group = groupAlerts, tooltip = "Enables alerts when stop distance enters FIT or WATCH context.")
bool alertRiskWarnings = input.bool(true, "Alert on Tight, Wide, No Room, or Rail Check", group = groupAlerts, tooltip = "Enables alerts for tight stops, wide stops, insufficient target room, and invalidation rail checks.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_titlecase(string s) =>
    switch s
        "FIT" => "Fit"
        "WATCH" => "Watch"
        "TOO TIGHT" => "Too Tight"
        "TOO WIDE" => "Too Wide"
        "NO ROOM" => "No Room"
        "WEAK FIT" => "Weak Fit"
        "BALANCED" => "Balanced"
        "EDGE FIT" => "Edge Fit"
        "COMPRESSED" => "Compressed"
        "EXTREME" => "Extreme"
        "HOT" => "Hot"
        "NORMAL" => "Normal"
        "STRONG" => "Strong"
        "ACCEPTABLE" => "Acceptable"
        "WEAK" => "Weak"
        => s

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)

f_stop_fit(float stopAtr, float minAtr, float idealAtr, float maxAtr) =>
    float result = 0.0
    if stopAtr < minAtr
        result := f_clamp(stopAtr / math.max(minAtr, 0.01) * 62.0, 0.0, 62.0)
    else if stopAtr <= idealAtr
        result := 62.0 + f_clamp((stopAtr - minAtr) / math.max(idealAtr - minAtr, 0.01) * 38.0, 0.0, 38.0)
    else if stopAtr <= maxAtr
        result := 100.0 - f_clamp((stopAtr - idealAtr) / math.max(maxAtr - idealAtr, 0.01) * 48.0, 0.0, 48.0)
    else
        result := f_clamp(52.0 - (stopAtr - maxAtr) / math.max(maxAtr, 0.01) * 52.0, 0.0, 52.0)
    result

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

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
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_state_color(string stateText) =>
    switch stateText
        "FIT" => bullColor
        "WATCH" => accentColor
        "TOO TIGHT" => neutralColor
        "TOO WIDE" => bearColor
        "NO ROOM" => neutralColor
        "WEAK FIT" => panelLabelCol
        => panelLabelCol

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(20, 31, 52) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_best_view_text() =>
    timeframe.isintraday ? "1H / 4H / 1D" : timeframe.isdaily ? "Daily chart" : "4H / 1D"

f_set_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, bool altRow, string fontSize) =>
    color rowBg = f_panel_bg(isLight, altRow)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(isLight), bgcolor = rowBg, text_size = f_label_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -------------------------------------------------
// Presets
// -------------------------------------------------
bool cleanerPreset = enginePreset == "Cleaner Swing"
bool activePreset = enginePreset == "Active Intraday"
int usedLabelCooldown = cleanerPreset ? math.max(labelCooldownBars, 32) : activePreset ? math.min(labelCooldownBars, 14) : labelCooldownBars
int usedContextSpacing = cleanerPreset ? math.max(contextSpacingBars, 100) : activePreset ? math.min(contextSpacingBars, 48) : contextSpacingBars
int usedMaxLabels = cleanerPreset ? math.min(maxVisibleLabels, 5) : activePreset ? math.min(maxVisibleLabels, 9) : math.min(maxVisibleLabels, 8)
float usedFitThresholdRaw = cleanerPreset ? math.max(fitThreshold, 78.0) : activePreset ? math.max(fitThreshold - 4.0, 40.0) : fitThreshold
float usedWatchThresholdRaw = cleanerPreset ? math.max(watchThreshold, 62.0) : activePreset ? math.max(watchThreshold - 4.0, 25.0) : watchThreshold
float usedFitThreshold = f_clamp(usedFitThresholdRaw, 40.0, 95.0)
float usedWatchThreshold = f_clamp(math.min(usedWatchThresholdRaw, usedFitThreshold - 1.0), 25.0, 90.0)
int usedProjectionBars = smartBandWidth and (timeframe.isweekly or timeframe.ismonthly) ? math.min(projectionBars, 22) : projectionBars

// Keep dependent scoring inputs internally coherent even when users enter them out of order.
float effectiveMinStopAtr = math.min(minStopAtr, maxStopAtr)
float effectiveMaxStopAtr = math.max(minStopAtr, maxStopAtr)
float effectiveIdealStopAtr = f_clamp(idealStopAtr, effectiveMinStopAtr, effectiveMaxStopAtr)
float effectiveStrongRoomAtr = math.max(strongRoomAtr, minRoomAtr + 0.10)
int effectiveReactBars = math.min(reactBars, proofHorizonBars)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atr, atrBaseLen)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? atr / atrBase : 1.0

float fastEma = ta.ema(close, fastEmaLen)
float slowEma = ta.ema(close, slowEmaLen)
float rangeHighRaw = ta.highest(high, targetLookback)
float rangeLowRaw = ta.lowest(low, targetLookback)
float rangeHigh = nz(rangeHighRaw, high)
float rangeLow = nz(rangeLowRaw, low)
float rangeWidth = math.max(rangeHigh - rangeLow, syminfo.mintick)
float rangePosition = f_clamp((close - rangeLow) / rangeWidth, 0.0, 1.0)

bool bullContext = close >= slowEma and fastEma >= slowEma
bool bearContext = close < slowEma and fastEma < slowEma
int planDir = sideMode == "Long Context" ? 1 : sideMode == "Short Context" ? -1 : bullContext ? 1 : bearContext ? -1 : rangePosition <= 0.50 ? 1 : -1
string dirText = planDir == 1 ? "Long" : "Short"
string sideCode = planDir == 1 ? "L" : "S"

float lowestStructure = ta.lowest(low, structureLookback)
float highestStructure = ta.highest(high, structureLookback)
int lowestOffsetRaw = ta.lowestbars(low, structureLookback)
int highestOffsetRaw = ta.highestbars(high, structureLookback)
float invalidationLevel = planDir == 1 ? nz(lowestStructure, low) : nz(highestStructure, high)
int rawOffset = planDir == 1 ? nz(lowestOffsetRaw, 0) : nz(highestOffsetRaw, 0)
int refOffset = math.max(0, -rawOffset)
int refBar = math.max(0, bar_index - refOffset)

float stopDistance = math.max(planDir == 1 ? close - invalidationLevel : invalidationLevel - close, syminfo.mintick)
float stopAtr = stopDistance / safeAtr
float targetEdge = planDir == 1 ? rangeHigh : rangeLow
float targetRoom = math.max(planDir == 1 ? targetEdge - close : close - targetEdge, 0.0)
float targetRoomAtr = targetRoom / safeAtr

float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)
float longWickRiskRaw = ta.sma(lowerWick / safeAtr, wickLookback)
float shortWickRiskRaw = ta.sma(upperWick / safeAtr, wickLookback)
float wickRiskAtr = planDir == 1 ? nz(longWickRiskRaw, lowerWick / safeAtr) : nz(shortWickRiskRaw, upperWick / safeAtr)

float touchCount = 0.0
for idx = 0 to structureLookback - 1
    float testLow = low[idx]
    float testHigh = high[idx]
    if planDir == 1 and not na(testLow)
        touchCount += testLow <= invalidationLevel + safeAtr * structureBufferAtr ? 1.0 : 0.0
    if planDir == -1 and not na(testHigh)
        touchCount += testHigh >= invalidationLevel - safeAtr * structureBufferAtr ? 1.0 : 0.0

float touchScore = f_clamp(touchCount / 3.0 * 100.0, 0.0, 100.0)
float ageScore = refOffset <= 1 ? 42.0 : refOffset <= structureLookback * 0.72 ? 100.0 : 72.0
float structureScore = touchScore * 0.46 + ageScore * 0.54
float stopScore = f_stop_fit(stopAtr, effectiveMinStopAtr, effectiveIdealStopAtr, effectiveMaxStopAtr)
float roomScore = f_norm_high_good(targetRoomAtr, minRoomAtr * 0.40, effectiveStrongRoomAtr)
float wickScore = f_norm_low_good(wickRiskAtr, 0.10, wickRiskLimit)
float volatilityScore = f_peak_score(atrRatio, 0.55, 1.00, 1.90)

float riskQuality = stopScore * 0.42 + structureScore * 0.22 + wickScore * 0.13 + roomScore * 0.15 + volatilityScore * 0.08
int qualityScore = int(math.round(f_clamp(riskQuality, 0.0, 100.0)))

bool tooTight = stopAtr < effectiveMinStopAtr
bool tooWide = stopAtr > effectiveMaxStopAtr
bool noRoom = targetRoomAtr < minRoomAtr

string distanceState = tooTight ? "TOO TIGHT" : tooWide ? "TOO WIDE" : stopScore >= 78.0 ? "BALANCED" : "EDGE FIT"
string atrState = atrRatio < 0.75 ? "COMPRESSED" : atrRatio > 1.95 ? "EXTREME" : atrRatio > 1.65 ? "HOT" : "NORMAL"
string structureState = structureScore >= 72.0 ? "STRONG" : structureScore >= 54.0 ? "ACCEPTABLE" : "WEAK"
string riskState = tooTight ? "TOO TIGHT" : tooWide ? "TOO WIDE" : noRoom ? "NO ROOM" : qualityScore >= usedFitThreshold ? "FIT" : qualityScore >= usedWatchThreshold ? "WATCH" : "WEAK FIT"
string actionState = riskState == "FIT" ? "Fit - Review" : riskState == "WATCH" ? "Watch - Monitor" : riskState == "TOO TIGHT" ? "Too Tight - Wait" : riskState == "TOO WIDE" ? "Too Wide - Wait" : riskState == "NO ROOM" ? "No Room - Wait" : "Hold Off"
color stateColor = f_state_color(riskState)
bool confirmedBar = not confirmOnClose or barstate.isconfirmed

// -------------------------------------------------
// Stop fit band and guide rails
// -------------------------------------------------
int rightEdge = bar_index + usedProjectionBars
int leftEdge = bar_index - 3
float nearBoundary = close - planDir * effectiveMinStopAtr * safeAtr
float farBoundary = close - planDir * effectiveMaxStopAtr * safeAtr
float idealBoundary = close - planDir * effectiveIdealStopAtr * safeAtr
float bandTop = math.max(nearBoundary, farBoundary)
float bandBottom = math.min(nearBoundary, farBoundary)
float bandMid = (bandTop + bandBottom) * 0.5
int labelX = bar_index + int(math.round(usedProjectionBars * 0.50))

var box stopBand = na
var label bandLabel = na
var line invalidationRail = na
var line idealLine = na
var line targetRoomLine = na
var label invalidationTag = na
var label idealTag = na
var label targetTag = na

// Current planning objects display only their latest state, so update them on the last chart bar only.
if barstate.islast
    if showStopBand
        string bandText = "SDQ " + str.tostring(qualityScore) + " | " + f_titlecase(riskState) + "\nStop " + str.tostring(stopAtr, "#.00") + " ATR | Room " + str.tostring(targetRoomAtr, "#.00") + " ATR"
        if na(stopBand)
            stopBand := box.new(left = leftEdge, top = bandTop, right = rightEdge, bottom = bandBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, bandTransparency), border_color = color.new(stateColor, 25), border_width = riskState == "FIT" ? 2 : 1)
        else
            box.set_left(stopBand, leftEdge)
            box.set_right(stopBand, rightEdge)
            box.set_top(stopBand, bandTop)
            box.set_bottom(stopBand, bandBottom)
            box.set_bgcolor(stopBand, color.new(stateColor, bandTransparency))
            box.set_border_color(stopBand, color.new(stateColor, 25))
            box.set_border_width(stopBand, riskState == "FIT" ? 2 : 1)
        if na(bandLabel)
            bandLabel := label.new(labelX, bandMid, bandText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(bandLabel, labelX, bandMid)
            label.set_text(bandLabel, bandText)
            label.set_color(bandLabel, color.new(stateColor, 0))
            label.set_textcolor(bandLabel, headerText)
            label.set_size(bandLabel, f_label_size(labelSizeInput))
            label.set_textalign(bandLabel, text.align_center)
    else
        if not na(stopBand)
            box.delete(stopBand)
            stopBand := na
        f_delete_label(bandLabel)
        bandLabel := na

    if showInvalidationRail
        color railColor = riskState == "FIT" ? bullColor : riskState == "TOO WIDE" ? bearColor : neutralColor
        if na(invalidationRail)
            invalidationRail := line.new(refBar, invalidationLevel, rightEdge, invalidationLevel, xloc = xloc.bar_index, extend = extend.none, color = railColor, width = 2)
        else
            line.set_xy1(invalidationRail, refBar, invalidationLevel)
            line.set_xy2(invalidationRail, rightEdge, invalidationLevel)
            line.set_color(invalidationRail, railColor)
    else
        if not na(invalidationRail)
            line.delete(invalidationRail)
            invalidationRail := na

    if showIdealLine
        if na(idealLine)
            idealLine := line.new(leftEdge, idealBoundary, rightEdge, idealBoundary, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 10), width = 1, style = line.style_dotted)
        else
            line.set_xy1(idealLine, leftEdge, idealBoundary)
            line.set_xy2(idealLine, rightEdge, idealBoundary)
            line.set_color(idealLine, color.new(accentColor, 10))
    else
        if not na(idealLine)
            line.delete(idealLine)
            idealLine := na

    if showGuideTags and showInvalidationRail
        string invalidationText = "Invalidation\n" + str.tostring(stopAtr, "#.00") + " ATR"
        color invalidationColor = riskState == "FIT" ? bullColor : riskState == "TOO WIDE" ? bearColor : neutralColor
        if na(invalidationTag)
            invalidationTag := label.new(rightEdge + 2, invalidationLevel, invalidationText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(invalidationColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(invalidationTag, rightEdge + 2, invalidationLevel)
            label.set_text(invalidationTag, invalidationText)
            label.set_color(invalidationTag, color.new(invalidationColor, 0))
            label.set_textcolor(invalidationTag, headerText)
            label.set_size(invalidationTag, f_label_size(labelSizeInput))
    else
        f_delete_label(invalidationTag)
        invalidationTag := na

    if showGuideTags and showIdealLine
        string idealText = "Ideal\n" + str.tostring(effectiveIdealStopAtr, "#.00") + " ATR"
        if na(idealTag)
            idealTag := label.new(rightEdge + 5, idealBoundary, idealText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(idealTag, rightEdge + 5, idealBoundary)
            label.set_text(idealTag, idealText)
            label.set_color(idealTag, color.new(accentColor, 0))
            label.set_textcolor(idealTag, headerText)
            label.set_size(idealTag, f_label_size(labelSizeInput))
    else
        f_delete_label(idealTag)
        idealTag := na

    if showGuideTags
        string targetText = "Target Room\n" + str.tostring(targetRoomAtr, "#.00") + " ATR"
        float targetY = targetEdge + planDir * safeAtr * 0.24
        color targetColor = noRoom ? neutralColor : bullColor
        if na(targetRoomLine)
            targetRoomLine := line.new(leftEdge, targetEdge, rightEdge, targetEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(targetColor, 24), width = 1, style = line.style_dashed)
        else
            line.set_xy1(targetRoomLine, leftEdge, targetEdge)
            line.set_xy2(targetRoomLine, rightEdge, targetEdge)
            line.set_color(targetRoomLine, color.new(targetColor, 24))
        if na(targetTag)
            targetTag := label.new(rightEdge + 8, targetY, targetText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(targetColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(targetTag, rightEdge + 8, targetY)
            label.set_text(targetTag, targetText)
            label.set_color(targetTag, color.new(targetColor, 0))
            label.set_textcolor(targetTag, headerText)
            label.set_size(targetTag, f_label_size(labelSizeInput))
    else
        if not na(targetRoomLine)
            line.delete(targetRoomLine)
            targetRoomLine := na
        f_delete_label(targetTag)
        targetTag := na

// -------------------------------------------------
// Confirmation-anchored proof state
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool evalActive = false
var int evalDir = 0
var int evalStartBar = na
var float evalEntry = na
var float evalStop = na
var float evalTarget = na
var bool evalReacted = false
var bool evalFollowed = false
var bool evalFlipped = false

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var int lastInvalidationLabelBar = na
var string lastRiskState = ""
var array<label> eventLabels = array.new_label()

bool fitEvent = confirmedBar and riskState == "FIT" and lastRiskState != "FIT"
bool watchEvent = confirmedBar and riskState == "WATCH" and lastRiskState != "WATCH"
bool tightEvent = confirmedBar and riskState == "TOO TIGHT" and lastRiskState != "TOO TIGHT"
bool wideEvent = confirmedBar and riskState == "TOO WIDE" and lastRiskState != "TOO WIDE"
bool roomEvent = confirmedBar and riskState == "NO ROOM" and lastRiskState != "NO ROOM"
bool longRailCross = confirmedBar and planDir[1] == 1 and not na(invalidationLevel[1]) and close[1] >= invalidationLevel[1] and close < invalidationLevel[1]
bool shortRailCross = confirmedBar and planDir[1] == -1 and not na(invalidationLevel[1]) and close[1] <= invalidationLevel[1] and close > invalidationLevel[1]
bool invalidationEvent = longRailCross or shortRailCross
bool eventCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= usedLabelCooldown
bool contextReady = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= usedContextSpacing
bool invalidationCooldownReady = na(lastInvalidationLabelBar) or bar_index - lastInvalidationLabelBar >= usedLabelCooldown
bool stateEvent = fitEvent or watchEvent or tightEvent or wideEvent or roomEvent
bool contextStateEligible = riskState == "FIT" or riskState == "WATCH" or riskState == "TOO TIGHT" or riskState == "TOO WIDE" or riskState == "NO ROOM"
bool drawStateLabel = showEventLabels and eventCooldownReady and stateEvent
bool drawContextLabel = showContextLabels and contextReady and not drawStateLabel and contextStateEligible
bool drawInvalidationLabel = showInvalidationLabels and invalidationCooldownReady and invalidationEvent

// Proof evaluation: track each FIT confirmation forward to see whether the stop held
// and whether price followed through by one risk multiple (1R). Same-bar stop/target
// outcomes are excluded because OHLC data cannot establish which level was reached first.
if confirmedBar
    if fitEvent and not evalActive
        evalActive := true
        evalDir := planDir
        evalEntry := close
        evalStop := invalidationLevel
        float oneR = math.max(math.abs(close - invalidationLevel), safeAtr * 0.10)
        evalTarget := close + evalDir * oneR
        evalStartBar := bar_index
        evalReacted := false
        evalFollowed := false
        evalFlipped := false
    if evalActive
        int heldBars = bar_index - evalStartBar
        if heldBars >= 1
            float favTargetDist = math.max(math.abs(evalTarget - evalEntry), syminfo.mintick)
            float favExcursion = evalDir == 1 ? high - evalEntry : evalEntry - low
            if heldBars <= effectiveReactBars and favExcursion >= favTargetDist * reactProgressPct / 100.0
                evalReacted := true
            bool hitStop = evalDir == 1 ? low <= evalStop : high >= evalStop
            bool hitTarget = evalDir == 1 ? high >= evalTarget : low <= evalTarget
            bool ambiguousNow = hitStop and hitTarget
            bool followNow = hitTarget and not hitStop
            bool flipNow = hitStop and not hitTarget
            if followNow
                evalFollowed := true
            if flipNow
                evalFlipped := true
            bool horizonDone = heldBars >= proofHorizonBars
            if ambiguousNow
                // OHLC data cannot reveal which level was reached first, so exclude the sample.
                proofAmbiguous := proofAmbiguous + 1
                evalActive := false
            else if evalFlipped or followNow or horizonDone
                proofTotal := proofTotal + 1
                if evalFollowed
                    proofFollow := proofFollow + 1
                if not evalFlipped
                    proofHold := proofHold + 1
                if evalReacted
                    proofReact := proofReact + 1
                if evalFlipped
                    proofFlip := proofFlip + 1
                evalActive := false

if drawStateLabel or drawContextLabel
    string labelText = sideCode + " " + f_titlecase(riskState)
    if showLabelScore
        labelText += " " + str.tostring(qualityScore)
    labelText += "\n" + str.tostring(stopAtr, "#.00") + " ATR"
    float labelY = planDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = planDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(stateColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, usedMaxLabels)
    if drawStateLabel
        lastEventLabelBar := bar_index
    else
        lastContextLabelBar := bar_index

if drawInvalidationLabel
    int railDir = nz(planDir[1], planDir)
    float railLabelY = railDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    label railLabel = label.new(x = bar_index, y = railLabelY, text = "Rail Check\n" + str.tostring(math.abs(close - invalidationLevel[1]) / safeAtr, "#.00") + " ATR", xloc = xloc.bar_index, yloc = yloc.price, style = railDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(neutralColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    array.push(eventLabels, railLabel)
    f_trim_labels(eventLabels, usedMaxLabels)
    lastInvalidationLabelBar := bar_index

plotshape(showStateMarkers and fitEvent and planDir == 1, title = "Long FIT Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showStateMarkers and fitEvent and planDir == -1, title = "Short FIT Marker", style = shape.diamond, location = location.abovebar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showStateMarkers and (tightEvent or wideEvent or roomEvent), title = "Risk Warning Marker", style = shape.diamond, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)

// -------------------------------------------------
// Panel
// -------------------------------------------------
bool panelIsLight = panelThemeInput == "Light"
color panelFrame = f_panel_border(panelIsLight)
string panelSize = panelFontSizeInput
string stopRead = str.tostring(stopAtr, "#.00") + " ATR | " + f_titlecase(distanceState)
string atrRead = str.tostring(atrRatio, "#.00") + "x | " + f_titlecase(atrState)
string structureRead = str.tostring(int(math.round(structureScore))) + " | " + f_titlecase(structureState)
string wickRead = str.tostring(wickRiskAtr, "#.00") + " ATR"
string roomRead = str.tostring(targetRoomAtr, "#.00") + " ATR | " + (noRoom ? "Limited" : "Open")
string qualityRead = str.tostring(qualityScore) + " / 100 | " + f_titlecase(riskState)
string actionRead = actionState + " | " + dirText
string bestViewText = f_best_view_text()

// Proof rates (confirmation-anchored, cumulative over completed FIT evaluations)
float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color followCol = proofTotal > 0 ? f_rate_color(followRate) : panelLabelCol
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : panelLabelCol
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : panelLabelCol
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : panelLabelCol
string sampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x " + str.tostring(proofAmbiguous) : "building"

int panelRowCount = showProof ? 14 : 9
var table panel = table.new(position.top_right, 2, panelRowCount, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.set_frame_color(panel, panelFrame)
    table.set_border_color(panel, panelFrame)
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Stop Distance Quality", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
        f_set_row(panel, 1, "Risk Quality", qualityRead, stateColor, panelIsLight, false, panelSize)
        f_set_row(panel, 2, "Stop Distance", stopRead, stopScore >= 62.0 ? bullColor : stopScore >= 42.0 ? neutralColor : bearColor, panelIsLight, true, panelSize)
        f_set_row(panel, 3, "ATR Context", atrRead, volatilityScore >= 55.0 ? accentColor : neutralColor, panelIsLight, false, panelSize)
        f_set_row(panel, 4, "Structure Fit", structureRead, structureScore >= 60.0 ? bullColor : neutralColor, panelIsLight, true, panelSize)
        f_set_row(panel, 5, "Wick Risk", wickRead, wickScore >= 55.0 ? bullColor : neutralColor, panelIsLight, false, panelSize)
        f_set_row(panel, 6, "Target Room", roomRead, noRoom ? neutralColor : bullColor, panelIsLight, true, panelSize)
        f_set_row(panel, 7, "Next Action", actionRead, stateColor, panelIsLight, false, panelSize)
        if showProof
            color subBg = f_panel_bg(panelIsLight, true)
            table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = subBg, text_size = f_label_size(panelSize))
            table.cell(panel, 1, 8, sampleText, text_color = f_panel_label(panelIsLight), bgcolor = subBg, text_size = f_label_size(panelSize), text_halign = text.align_right)
            f_set_row(panel, 9, "Follow Rate", followText, followCol, panelIsLight, false, panelSize)
            f_set_row(panel, 10, "Hold Rate", holdText, holdCol, panelIsLight, true, panelSize)
            f_set_row(panel, 11, "React Rate", reactText, reactCol, panelIsLight, false, panelSize)
            f_set_row(panel, 12, "Flip Rate", flipText, flipCol, panelIsLight, true, panelSize)
            f_set_row(panel, 13, "Best View", bestViewText, accentColor, panelIsLight, false, panelSize)
        else
            f_set_row(panel, 8, "Best View", bestViewText, accentColor, panelIsLight, true, panelSize)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertFitWatch and fitEvent, title = "Stop Distance FIT", message = "Stop Distance Quality: FIT state is active. This is an attention marker, not a trade instruction.")
alertcondition(alertFitWatch and watchEvent, title = "Stop Distance WATCH", message = "Stop Distance Quality: WATCH state is active. The stop distance is improving but not yet clean enough for FIT.")
alertcondition(alertRiskWarnings and tightEvent, title = "Stop Distance Too Tight", message = "Stop Distance Quality: stop distance is too tight relative to current ATR context.")
alertcondition(alertRiskWarnings and wideEvent, title = "Stop Distance Too Wide", message = "Stop Distance Quality: stop distance is too wide relative to current ATR context.")
alertcondition(alertRiskWarnings and roomEvent, title = "Stop Distance No Room", message = "Stop Distance Quality: target room is not clean enough for the current stop-distance context.")
alertcondition(alertRiskWarnings and invalidationEvent, title = "Invalidation Rail Check", message = "Stop Distance Quality: price crossed the prior invalidation rail. Review the current context.")

plot(qualityScore, title = "SDQ Quality Score", display = display.none)
plot(stopScore, title = "SDQ Stop Score", display = display.none)
plot(targetRoomAtr, title = "SDQ Target Room ATR", display = display.none)
plot(followRate, title = "SDQ Follow Rate", display = display.none)
plot(holdRate, title = "SDQ Hold Rate", display = display.none)
plot(reactRate, title = "SDQ React Rate", display = display.none)
plot(flipRate, title = "SDQ Flip Rate", display = display.none)
plot(proofAmbiguous, title = "SDQ Ambiguous Exclusions", display = display.none)

if confirmedBar
    lastRiskState := riskState
````
