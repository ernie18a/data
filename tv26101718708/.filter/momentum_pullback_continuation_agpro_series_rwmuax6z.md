# Momentum Pullback Continuation [AGPro Series]

- url: https://www.tradingview.com/script/RWmUAX6z-Momentum-Pullback-Continuation-AGPro-Series/
- type: indicator
- pine_id: PUB;bd52dea384fd4626ba2bff96ad08835e
- version: 4.0

## Description

Momentum Pullback Continuation [AGPro Series]

🧠 Core Idea

Is a momentum pullback resetting cleanly for continuation, or is the move losing its execution quality?


📌 Overview / What it does

Momentum Pullback Continuation [AGPro Series] is a chart-first continuation planner built for traders who review momentum-driven trends after a controlled pullback.

The script maps a momentum reset pocket, continuation trigger line, invalidation rail, target-room corridor, state labels, alerts, and a clean AGPro planning panel. It converts trend support, momentum slope, pullback depth, close recovery, volume behavior, and target room into a 0-100 Continuation Score.

The default publication preset is 1H-focused. Higher timeframes can be tested from the inputs, but the strongest intended use case is hourly momentum pullback review.

It does not predict price, automate entries, or turn every trend pullback into a signal. It is a structured decision tool for evaluating whether the current momentum reset deserves closer review.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between basic momentum readings and practical continuation planning.

Many traders can see that momentum exists, but the harder question is whether the pullback is resetting in a controlled way or damaging the continuation structure. This planner focuses on that decision layer.

The design supports a disciplined workflow: identify the active momentum side, inspect the reset pocket, evaluate the score, locate the invalidation rail, compare target room, and read the next-action state.


⚡ Why This Script Is Different

Most tools focus on momentum oscillators, moving-average direction, divergence events, or generic continuation labels.

This script does NOT clone Hidden Divergence Continuation Zones, Trend Continuation Quality, Structural Momentum Oscillator, ROC Momentum Shift Map, or a generic pullback signal map.

Instead, it treats the pullback as a planning event. The main output is not a buy/sell marker. It is a momentum reset decision state with score, risk edge, target-room context, and action guidance.


⚙️ Methodology

1. Context Detection
The script identifies bullish or bearish momentum context using an EMA stack, normalized trend slope, and smoothed rate-of-change pressure.

2. Reference Mapping
It builds a concept-native Momentum Reset Pocket around the active trend support area, then maps a continuation trigger line, invalidation rail, and target-room guide.

3. Reaction Evaluation
The score model evaluates momentum slope, pullback depth, trend support, close recovery, volume behavior, and available target room.

4. Visual Output
The chart shows the reset pocket, target-room corridor, trigger and risk guides, compact event labels, sparse context labels, alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Reset Pocket = the area where a momentum pullback is expected to stabilize before continuation can be reviewed.

Trigger Line = the fast continuation reference that price needs to recover after the reset.

Invalidation Rail = the planning line where the active reset context is considered lost.

Target-Room Corridor = the forward planning area between current price and the target-room guide.

Labels = RESET, WATCH, READY, WEAK, and INVALID attention markers.

Colors = teal marks bullish continuation context, pink marks bearish continuation context, amber marks weak or caution states, indigo marks watch/target-room context, and red marks invalidation.

Panel = summarizes Momentum State, Pullback Quality, Continuation Score, Risk Edge, and Action.


🚦 Signals & States

• RESET → price has interacted with the momentum reset pocket.

• WATCH → the reset is developing, but recovery or score quality is not complete.

• READY → momentum, pullback depth, recovery, volume context, and target room align strongly enough for structured review.

• WEAK → the pullback is too deep, low quality, or not recovering well enough.

• INVALID → price has crossed the invalidation rail and the active reset context should be rebuilt.


🔔 Alerts Logic

Alerts trigger when READY, WATCH, WEAK RESET, or INVALID states appear.

Each alert is an attention marker tied to the rule-based state engine. Alerts are not trade instructions and do not guarantee that continuation will occur.


🧩 Confluence Logic

The continuation context becomes stronger when trend support, positive momentum slope, controlled pullback depth, clean close recovery, acceptable volume behavior, and target-room availability align.

The script intentionally requires multiple conditions instead of labeling every pullback inside a trend as meaningful.


📊 When to Use

• Directional markets with visible momentum pressure

• 1H charts and nearby intraday momentum review

• Trend continuation review workflows

• Pullbacks after a clear momentum impulse

• Situations where risk edge and target room matter before acting

• Markets where volume and close behavior are readable enough to support context


⚠️ When NOT to Use

• Low-liquidity symbols with unreliable candles or volume

• Extremely choppy markets with frequent trend-side flips

• News-driven volatility where reset structure changes too quickly

• Very flat markets where momentum pressure is absent

• Instruments where the active pullback is far beyond the mapped risk edge


🎛️ Key Inputs

• Continuation Side → selects Auto, Bullish Only, or Bearish Only evaluation.

• Timeframe Profile → keeps the default script behavior focused on 1H charts, with optional broader intraday or all-timeframe testing.

• Sensitivity → adjusts how strict the momentum reset model is.

• EMA settings → define trigger, reset, and support references.

• Momentum ROC settings → control the internal momentum pressure reading.

• Reset Pocket Width → changes how wide the reset area is around trend support.

• READY / WATCH Score → sets state thresholds.

• Visual settings → control zones, guide lines, labels, panel theme, panel location, and font sizes.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first and practical.

The reset pocket and target-room corridor provide the main visual planning structure. Labels are compact and spaced with cooldown controls. The AGPro panel uses a single merged blue header row and focuses only on the core decision fields.


🧪 Practical Usage Workflow

1. Read the panel Momentum State.

2. Check whether price is interacting with the Momentum Reset Pocket.

3. Compare Pullback Quality and Continuation Score.

4. Locate the Risk Edge and Target-Room Corridor.

5. Use the Action row to decide whether the context is READY, still WATCH, weak, invalid, or only worth scanning.


🔍 Interpretation Guidelines

Think of the script as a continuation readiness map, not a command system.

A higher score means the active momentum pullback matches the script's internal definition of cleaner continuation structure. A lower score means one or more components are missing, such as trend support, recovery quality, volume context, or target room.

The invalidation rail is a planning boundary for the active context. It is not a guaranteed stop level and should not replace the user's own risk process.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an auto-trading system.

This script does not provide guaranteed signals.

This script does not replace independent confirmation, position sizing, or risk management.


⚠️ Limitations & Transparency

Momentum continuation behavior changes across symbols, sessions, and timeframes.

The default 1H Focus profile intentionally suppresses active labels, zones, and alerts outside the intended hourly review window.

Low-liquidity markets can distort volume behavior and reset quality.

High volatility can widen risk edges and reduce target-room clarity.

Sideways conditions can create repeated resets without clean continuation.

No rule-based script can fully account for sudden news, spread changes, slippage, or discretionary execution constraints.


🧠 Market Context Notes

Momentum pullbacks are often more useful when the broader trend remains intact, the pullback is controlled rather than impulsive against trend, and the recovery candle shows clear close quality.

The best reads usually come from alignment between structure, momentum, volume, volatility, and clean forward room.


🧾 Use Case Examples

When price pulls into the reset pocket during bullish momentum and then recovers the trigger line with a stronger score, the script can mark READY for continuation review.

When price enters the pocket but momentum slope fades and pullback depth becomes excessive, the script can mark WEAK RESET.

When price crosses the invalidation rail, the active reset context is treated as lost and should be rebuilt.


🧱 System Philosophy

AGPro tools are built around structured interpretation.

The goal is not to create more chart noise. The goal is to turn visible market behavior into a cleaner decision framework: context, quality, risk, target room, and next action.


🔐 Non-Promise Statement

No script can provide certainty.

No score guarantees continuation.

The output should be interpreted as structured context, not as a promise of future price movement.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, confirmation, position sizing, and decisions.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the planner to study how momentum resets behave across different symbols and timeframes. Over time, compare READY, WATCH, WEAK RESET, and INVALID states to understand which environments produce cleaner continuation structure.

## Source Code

````pine
// -------------------------------------------------
// Momentum Pullback Continuation [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Momentum Pullback Continuation is a chart-first continuation planner that
// evaluates whether a momentum-driven trend is resetting cleanly enough for a
// new continuation review. It maps a momentum reset pocket, continuation
// trigger line, invalidation rail, target-room corridor, 0-100 continuation
// score, next-action state, and a continuation rate that proves how often
// confirmed continuation triggers reached target room before invalidation,
// without becoming a generic oscillator, divergence map, or basic signal
// indicator. Version 1.5 preserves the core continuation model while refining
// state naming, guide identification, label hierarchy, and chart readability.
// -------------------------------------------------

//@version=6
indicator("Momentum Pullback Continuation [AGPro Series]",
     shorttitle = "AG Pro MPC",
     overlay = true,
     max_boxes_count = 70,
     max_labels_count = 240,
     max_lines_count = 110)

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
string ttSide = "Selects which momentum continuation side the planner evaluates. Auto follows the active EMA and momentum context, while manual modes restrict the planner to one side only."
string ttSensitivity = "Controls how selective the momentum reset model is. Responsive shows more review states, Balanced is the publication default, and Strict requires cleaner momentum recovery."
string ttFast = "Fast EMA used as the continuation trigger reference. It is not a standalone moving-average signal."
string ttBase = "Base EMA used to build the momentum reset pocket. Clean pullbacks usually reset around this area before continuation can be reviewed."
string ttSlow = "Slow EMA used for broader trend support and invalidation context."
string ttRoc = "Rate-of-change length used to measure momentum pressure. The script uses it as one component of the planner, not as a separate oscillator panel."
string ttSmooth = "Smoothing applied to the momentum reading so short noise does not dominate the continuation score."
string ttSlope = "Lookback used to measure whether smoothed momentum is improving, stalling, or fading after a reset."
string ttAtr = "ATR normalizes reset pocket width, risk rail distance, target-room corridor, and label offset across symbols."
string ttVolume = "Volume baseline used to compare reset participation and continuation recovery. On symbols with unreliable volume, interpret this component as context."
string ttLookback = "Lookback used to locate the current momentum impulse extreme and estimate forward target-room context."
string ttResetWindow = "Number of bars after a reset-pocket touch where a continuation trigger can still qualify as part of the same reset event."
string ttBand = "ATR width around the base EMA used to draw the momentum reset pocket."
string ttIdeal = "Preferred ATR-normalized pullback depth after a momentum impulse. Too shallow and too deep pullbacks receive lower quality scores."
string ttMaxDepth = "Pullbacks deeper than this ATR distance are treated as weak or damaged resets."
string ttRisk = "ATR buffer beyond the reset pocket and slow EMA used to draw the invalidation rail. It is a planning reference, not a stop instruction."
string ttRoom = "Preferred ATR-normalized distance between current price and the target-room guide."
string ttReady = "Minimum 0-100 score required for READY state."
string ttWatch = "Minimum 0-100 score required for WATCH state."
string ttConfirm = "Close Confirmed waits for a closed bar before labels and alerts print. Live Updating lets the planner update during the active bar."
string ttTimeframe = "Defines the default timeframe suitability gate. 1H Focus keeps labels, zones, alerts, and active panel states focused on 45-90 minute intraday charts. Intraday Flexible allows broader intraday testing, and All Timeframes removes the gate."
string ttPocket = "Shows the momentum reset pocket. Text is rendered as a separate centered badge for better readability."
string ttCorridor = "Shows a forward target-room corridor after a valid reset context. The corridor is a planning area, not a price forecast."
string ttRails = "Shows the continuation trigger line, invalidation rail, and target guide used by the planner."
string ttEma = "Shows the EMA references used by the momentum planner."
string ttProjection = "Controls how far the pocket, corridor, and guide lines extend to the right."
string ttAdaptiveProjection = "Shortens projected zones on daily, weekly, and monthly charts so higher-timeframe screenshots stay balanced."
string ttBadgeAnchor = "Controls the horizontal placement of centered zone badges inside projected zones."
string ttOpacity = "Controls reset pocket transparency. Higher values make the chart cleaner."
string ttLabels = "Shows compact READY, WATCH, RESET, WEAK RESET, and INVALID labels with controlled spacing."
string ttContext = "Adds sparse context labels so the chart does not look empty while avoiding repeated signal clutter."
string ttScoreLabel = "Adds the 0-100 continuation score to chart labels."
string ttCooldown = "Minimum bars between event labels. Higher values reduce repeated labels during active resets."
string ttContextSpacing = "Minimum bars between sparse context labels during ongoing momentum-reset review."
string ttMaxLabels = "Maximum number of visible chart labels retained by the script. Older labels are deleted first for performance."
string ttOffset = "ATR-based vertical offset that keeps labels above or below candles."
string ttLabelSize = "Controls all chart labels and centered zone badges. Normal is the recommended public-release default."
string ttPanel = "Shows or hides the AG Pro planning panel. The default is visible for public-release readability."
string ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between the premium AGPro dark, slate, and clean light themes."
string ttPanelFont = "Controls panel text size. Normal is the recommended publication default."
string ttAlert = "Minimum 0-100 continuation score required before READY alerts can trigger."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Momentum Continuation Engine"
string sideMode = input.string("Auto", "Continuation Side", options = ["Auto", "Bullish Only", "Bearish Only"], group = groupEngine, tooltip = ttSide)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = ttSensitivity)
int fastEmaLength = input.int(21, "Fast Trigger EMA", minval = 3, maxval = 200, group = groupEngine, tooltip = ttFast)
int baseEmaLength = input.int(55, "Base Reset EMA", minval = 5, maxval = 300, group = groupEngine, tooltip = ttBase)
int slowEmaLength = input.int(144, "Slow Support EMA", minval = 10, maxval = 500, group = groupEngine, tooltip = ttSlow)
int momentumLength = input.int(12, "Momentum ROC Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttRoc)
int momentumSmooth = input.int(5, "Momentum Smoothing", minval = 1, maxval = 50, group = groupEngine, tooltip = ttSmooth)
int momentumSlopeLookback = input.int(5, "Momentum Slope Lookback", minval = 1, maxval = 50, group = groupEngine, tooltip = ttSlope)
int atrLength = input.int(14, "ATR Length", minval = 3, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(30, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)
int impulseLookback = input.int(64, "Momentum Impulse Lookback", minval = 20, maxval = 300, group = groupEngine, tooltip = ttLookback)

string groupModel = "Continuation Score Model"
int resetWindowBars = input.int(10, "Reset Review Window Bars", minval = 1, maxval = 80, group = groupModel, tooltip = ttResetWindow)
float resetBandAtr = input.float(0.62, "Reset Pocket Width ATR", minval = 0.10, maxval = 2.50, step = 0.01, group = groupModel, tooltip = ttBand)
float idealResetDepthAtr = input.float(0.90, "Ideal Pullback Depth ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupModel, tooltip = ttIdeal)
float maxResetDepthAtr = input.float(2.35, "Deep Reset Risk ATR", minval = 0.30, maxval = 7.00, step = 0.05, group = groupModel, tooltip = ttMaxDepth)
float riskBufferAtr = input.float(0.38, "Invalidation Rail Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = groupModel, tooltip = ttRisk)
float cleanTargetRoomAtr = input.float(2.00, "Clean Target Room ATR", minval = 0.30, maxval = 8.00, step = 0.05, group = groupModel, tooltip = ttRoom)
int readyScore = input.int(72, "READY Score", minval = 40, maxval = 95, group = groupModel, tooltip = ttReady)
int watchScore = input.int(55, "WATCH Score", minval = 25, maxval = 90, group = groupModel, tooltip = ttWatch)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupModel, tooltip = ttConfirm)
string timeframeProfile = input.string("1H Focus", "Timeframe Profile", options = ["1H Focus", "Intraday Flexible", "All Timeframes"], group = groupModel, tooltip = ttTimeframe)

string groupVisual = "Chart Visuals"
bool showResetPocket = input.bool(true, "Show Momentum Reset Pocket", group = groupVisual, tooltip = ttPocket)
bool showTargetCorridor = input.bool(true, "Show Target-Room Corridor", group = groupVisual, tooltip = ttCorridor)
bool showGuideLines = input.bool(true, "Show Trigger / Risk / Target Guides", group = groupVisual, tooltip = ttRails)
bool showEmaReferences = input.bool(false, "Show EMA References", group = groupVisual, tooltip = ttEma)
int projectionBars = input.int(42, "Forward Render Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
bool adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = ttAdaptiveProjection)
float zoneBadgeAnchor = input.float(0.55, "Zone Badge Anchor", minval = 0.20, maxval = 0.80, step = 0.05, group = groupVisual, tooltip = ttBadgeAnchor)
int zoneTransparency = input.int(87, "Reset Pocket Transparency", minval = 72, maxval = 96, group = groupVisual, tooltip = ttOpacity)

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttScoreLabel)
int labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(52, "Context Label Spacing", minval = 6, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(10, "Max Visible Labels", minval = 5, maxval = 100, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(1.25, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = ttPanelFont)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(72, "Minimum READY Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = ttAlert)

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
        "Huge" => size.huge
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

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(248, 250, 252) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else if theme == "Slate"
        evenRow ? color.rgb(30, 41, 59) : color.rgb(24, 34, 56)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_grade(float score) =>
    string result = "D"
    if score >= 88.0
        result := "A+"
    else if score >= 78.0
        result := "A"
    else if score >= 66.0
        result := "B"
    else if score >= 55.0
        result := "C"
    result

f_score_color(float score) =>
    color result = dangerColor
    if score >= 78.0
        result := bullColor
    else if score >= 66.0
        result := accentColor
    else if score >= 55.0
        result := neutralColor
    result

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_add_label(array<label> labels, int x, float y, string labelText, color bgColor, color textColor, bool upStyle, string sizeText, int maxCount) =>
    label newLabel = label.new(x = x, y = y, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = upStyle ? label.style_label_up : label.style_label_down, color = bgColor, textcolor = textColor, size = f_text_size(sizeText))
    array.push(labels, newLabel)
    f_trim_labels(labels, maxCount)

f_delete_box(box target) =>
    if not na(target)
        box.delete(target)

f_delete_line(line target) =>
    if not na(target)
        line.delete(target)

f_delete_label(label target) =>
    if not na(target)
        label.delete(target)

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
bool confirmReady = confirmationMode == "Live Updating" or barstate.isconfirmed
bool oneHourProfile = timeframe.isintraday and timeframe.multiplier >= 45 and timeframe.multiplier <= 90
bool flexibleIntradayProfile = timeframe.isintraday and timeframe.multiplier <= 240
bool timeframeAllowed = timeframeProfile == "All Timeframes" ? true : timeframeProfile == "Intraday Flexible" ? flexibleIntradayProfile : oneHourProfile
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
int renderBars = adaptiveProjection ? timeframe.ismonthly ? math.min(projectionBars, 8) : timeframe.isweekly ? math.min(projectionBars, 14) : timeframe.isdaily ? math.min(projectionBars, 24) : projectionBars : projectionBars

float emaFast = ta.ema(close, fastEmaLength)
float emaBase = ta.ema(close, baseEmaLength)
float emaSlow = ta.ema(close, slowEmaLength)

float momentumRaw = ta.roc(close, momentumLength)
float momentumSmoothValue = ta.ema(momentumRaw, momentumSmooth)
float momentumSlope = momentumSmoothValue - momentumSmoothValue[momentumSlopeLookback]
float baseSlopeAtr = (emaBase - emaBase[momentumSlopeLookback]) / safeAtr

float volumeAverage = ta.sma(volume, volumeLength)
float volumeRatio = not na(volumeAverage) and volumeAverage > 0.0 ? volume / volumeAverage : 1.0

float minSlope = sensitivity == "Strict" ? 0.035 : sensitivity == "Responsive" ? -0.005 : 0.012
float minMomentum = sensitivity == "Strict" ? 0.18 : sensitivity == "Responsive" ? -0.04 : 0.06
float closeLocationNeed = sensitivity == "Strict" ? 0.66 : sensitivity == "Responsive" ? 0.54 : 0.60

bool allowBull = sideMode != "Bearish Only"
bool allowBear = sideMode != "Bullish Only"
bool bullContext = allowBull and emaFast > emaBase and emaBase > emaSlow and baseSlopeAtr >= minSlope and momentumSmoothValue >= minMomentum
bool bearContext = allowBear and emaFast < emaBase and emaBase < emaSlow and baseSlopeAtr <= -minSlope and momentumSmoothValue <= -minMomentum
int trendSide = bullContext ? 1 : bearContext ? -1 : 0
bool activeMomentum = trendSide != 0 and timeframeAllowed

float pocketTop = na
float pocketBottom = na
if trendSide == 1
    pocketTop := emaFast + safeAtr * 0.10
    pocketBottom := emaBase - safeAtr * resetBandAtr
else if trendSide == -1
    pocketTop := emaBase + safeAtr * resetBandAtr
    pocketBottom := emaFast - safeAtr * 0.10

bool validPocket = activeMomentum and not na(pocketTop) and not na(pocketBottom) and pocketTop > pocketBottom
bool pocketTouch = validPocket and high >= pocketBottom and low <= pocketTop
int barsSinceTouch = ta.barssince(pocketTouch)
bool recentReset = validPocket and not na(barsSinceTouch) and barsSinceTouch <= resetWindowBars

float impulseHigh = ta.highest(high, impulseLookback)
float impulseLow = ta.lowest(low, impulseLookback)
float pullbackDepthAtr = na
if trendSide == 1
    pullbackDepthAtr := (impulseHigh - low) / safeAtr
else if trendSide == -1
    pullbackDepthAtr := (high - impulseLow) / safeAtr

float targetGuide = na
float invalidationRail = na
float triggerLine = na
if trendSide == 1
    targetGuide := impulseHigh + safeAtr * 0.35
    invalidationRail := math.min(pocketBottom, emaSlow) - safeAtr * riskBufferAtr
    triggerLine := emaFast
else if trendSide == -1
    targetGuide := impulseLow - safeAtr * 0.35
    invalidationRail := math.max(pocketTop, emaSlow) + safeAtr * riskBufferAtr
    triggerLine := emaFast

float barRange = math.max(high - low, syminfo.mintick)
float closeLocation = (close - low) / barRange
float bullCloseRecovery = (close - emaFast) / safeAtr
float bearCloseRecovery = (emaFast - close) / safeAtr
bool bullTrigger = recentReset and trendSide == 1 and close > triggerLine and close > open and closeLocation >= closeLocationNeed
bool bearTrigger = recentReset and trendSide == -1 and close < triggerLine and close < open and closeLocation <= 1.0 - closeLocationNeed
bool triggerQualified = (bullTrigger or bearTrigger) and confirmReady

bool invalidated = recentReset and ((trendSide == 1 and close < invalidationRail) or (trendSide == -1 and close > invalidationRail))

float trendSpreadAtr = trendSide == 1 ? (emaFast - emaSlow) / safeAtr : trendSide == -1 ? (emaSlow - emaFast) / safeAtr : 0.0
float slopeScore = trendSide == 1 ? f_norm_high(baseSlopeAtr, -0.02, 0.12) : trendSide == -1 ? f_norm_high(-baseSlopeAtr, -0.02, 0.12) : 0.0
float spreadScore = f_norm_high(trendSpreadAtr, 0.15, 2.50)
float trendScore = slopeScore * 0.55 + spreadScore * 0.45

float momentumDirectionScore = trendSide == 1 ? f_norm_high(momentumSmoothValue, -0.15, 1.25) : trendSide == -1 ? f_norm_high(-momentumSmoothValue, -0.15, 1.25) : 0.0
float momentumSlopeScore = trendSide == 1 ? f_norm_high(momentumSlope, -0.14, 0.22) : trendSide == -1 ? f_norm_high(-momentumSlope, -0.14, 0.22) : 0.0
float momentumScore = momentumDirectionScore * 0.55 + momentumSlopeScore * 0.45

float depthScore = validPocket and not na(pullbackDepthAtr) ? f_peak_score(pullbackDepthAtr, 0.15, idealResetDepthAtr, maxResetDepthAtr) : 0.0
float pocketScore = recentReset ? 100.0 : pocketTouch ? 80.0 : validPocket ? 45.0 : 0.0
float resetQualityScore = depthScore * 0.68 + pocketScore * 0.32

float recoveryDistance = trendSide == 1 ? bullCloseRecovery : trendSide == -1 ? bearCloseRecovery : 0.0
float locationScore = trendSide == 1 ? f_norm_high(closeLocation, 0.42, 0.82) : trendSide == -1 ? f_norm_high(1.0 - closeLocation, 0.42, 0.82) : 0.0
float recoveryScore = f_norm_high(recoveryDistance, -0.28, 0.55) * 0.58 + locationScore * 0.42

float resetVolumeScore = f_norm_low(volumeRatio, 0.60, 1.45)
float triggerVolumeScore = f_norm_high(volumeRatio, 0.75, 1.35)
float volumeScore = triggerQualified ? triggerVolumeScore : resetVolumeScore * 0.65 + 35.0

float targetRoomAtr = trendSide == 1 ? (targetGuide - close) / safeAtr : trendSide == -1 ? (close - targetGuide) / safeAtr : na
float roomScore = not na(targetRoomAtr) ? f_norm_high(targetRoomAtr, 0.25, cleanTargetRoomAtr) : 0.0

float continuationScoreRaw = trendScore * 0.20 + momentumScore * 0.22 + resetQualityScore * 0.24 + recoveryScore * 0.18 + volumeScore * 0.08 + roomScore * 0.08
float continuationScore = activeMomentum ? f_clamp(continuationScoreRaw, 0.0, 100.0) : 0.0

bool deepResetRisk = validPocket and not na(pullbackDepthAtr) and pullbackDepthAtr > maxResetDepthAtr
bool readyState = activeMomentum and not invalidated and triggerQualified and continuationScore >= readyScore and targetRoomAtr >= 0.30
bool watchState = activeMomentum and not invalidated and recentReset and continuationScore >= watchScore and not readyState
bool weakResetState = activeMomentum and recentReset and (continuationScore < watchScore or deepResetRisk) and not invalidated
bool waitResetState = activeMomentum and not recentReset and not invalidated

string trendText = not timeframeAllowed ? "1H Focus" : trendSide == 1 ? "Bull Momentum" : trendSide == -1 ? "Bear Momentum" : "No Momentum"
string pullbackText = not timeframeAllowed ? "Use 1H" : invalidated ? "Invalidated" : readyState ? "Clean Reset" : watchState ? "Review Reset" : weakResetState ? "Weak Reset" : waitResetState ? "Wait Reset" : "Scan"
string actionText = not timeframeAllowed ? "Switch to 1H" : "Scan"
if timeframeAllowed
    if readyState
        actionText := "READY: review continuation"
    else if watchState
        actionText := "WAIT: recovery developing"
    else if weakResetState
        actionText := "REBUILD: weak reset"
    else if invalidated
        actionText := "RESET LOST"
    else if waitResetState
        actionText := "Track reset pocket"

color trendColor = not timeframeAllowed ? neutralColor : trendSide == 1 ? bullColor : trendSide == -1 ? bearColor : neutralColor
color stateColor = not timeframeAllowed ? neutralColor : readyState ? trendColor : watchState ? accentColor : weakResetState ? neutralColor : invalidated ? dangerColor : f_panel_value(panelTheme)
string scoreText = timeframeAllowed ? str.tostring(math.round(continuationScore)) + " / " + f_grade(continuationScore) : "-"
string scoreSuffix = showLabelScore ? "\n" + str.tostring(math.round(continuationScore)) : ""
float riskDistanceAtr = trendSide == 1 ? (close - invalidationRail) / safeAtr : trendSide == -1 ? (invalidationRail - close) / safeAtr : na
string riskText = validPocket and not na(riskDistanceAtr) ? f_price(invalidationRail) + " / " + f_fmt(riskDistanceAtr) + " ATR" : "-"
string roomText = activeMomentum and not na(targetRoomAtr) ? f_fmt(targetRoomAtr) + " ATR" : "-"

// -------------------------------------------------
// Continuation-rate proof (Confirm Rate)
// -------------------------------------------------
int contWindowBars = math.max(resetWindowBars * 3, 20)
var int   contTotal   = 0
var int   contWon      = 0
var bool  cPendActive  = false
var int   cPendDir     = 0
var float cPendTarget  = na
var float cPendInval   = na
var int   cPendLeft    = 0

if barstate.isconfirmed
    if cPendActive and not na(cPendTarget) and not na(cPendInval)
        bool invalHit = cPendDir == 1 ? close <= cPendInval : close >= cPendInval
        bool targetHit = cPendDir == 1 ? high >= cPendTarget : low <= cPendTarget
        if invalHit
            contTotal += 1
            cPendActive := false
        else if targetHit
            contTotal += 1
            contWon += 1
            cPendActive := false
        else
            cPendLeft -= 1
            if cPendLeft <= 0
                contTotal += 1
                cPendActive := false
    bool contTrigger = (bullTrigger or bearTrigger) and trendSide != 0 and not na(targetGuide) and not na(invalidationRail)
    if contTrigger
        if cPendActive
            contTotal += 1
            cPendActive := false
        cPendActive := true
        cPendDir := trendSide
        cPendTarget := targetGuide
        cPendInval := invalidationRail
        cPendLeft := contWindowBars

float contRate = contTotal > 0 ? contWon / contTotal * 100.0 : na
string contRateText = contTotal > 0 ? str.tostring(int(math.round(contRate))) + "% (" + str.tostring(contTotal) + ")" : "Building"
color contRateColor = na(contRate) ? f_panel_value(panelTheme) : contRate >= 55.0 ? bullColor : contRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Visual Zones and Lines
// -------------------------------------------------
var box resetPocketBox = na
var box targetCorridorBox = na
var label resetPocketBadge = na
var label targetCorridorBadge = na
var label riskGuideBadge = na
var label triggerGuideBadge = na
var label targetGuideBadge = na
var line riskLine = na
var line triggerGuideLine = na
var line targetLine = na

int leftEdge = math.max(bar_index - math.max(resetWindowBars, 6), 0)
int rightEdge = bar_index + renderBars
int badgeX = int(math.round(leftEdge + (rightEdge - leftEdge) * zoneBadgeAnchor))
string resetPocketText = readyState ? "Continuation Ready" : watchState ? "Reset Under Review" : weakResetState ? "Weak Reset Pocket" : waitResetState ? "Reset Watch Pocket" : invalidated ? "Reset Invalidated" : "Momentum Reset Pocket"

if showResetPocket and validPocket
    if na(resetPocketBox)
        resetPocketBox := box.new(left = leftEdge, top = pocketTop, right = rightEdge, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(trendColor, zoneTransparency), border_color = color.new(trendColor, 35), border_width = 1)
    else
        box.set_left(resetPocketBox, leftEdge)
        box.set_right(resetPocketBox, rightEdge)
        box.set_top(resetPocketBox, pocketTop)
        box.set_bottom(resetPocketBox, pocketBottom)
        box.set_bgcolor(resetPocketBox, color.new(trendColor, zoneTransparency))
        box.set_border_color(resetPocketBox, color.new(trendColor, 35))
    if na(resetPocketBadge)
        resetPocketBadge := label.new(badgeX, math.avg(pocketTop, pocketBottom), resetPocketText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(trendColor, 5), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_x(resetPocketBadge, badgeX)
        label.set_y(resetPocketBadge, math.avg(pocketTop, pocketBottom))
        label.set_text(resetPocketBadge, resetPocketText)
        label.set_color(resetPocketBadge, color.new(trendColor, 5))
        label.set_textcolor(resetPocketBadge, headerText)
        label.set_size(resetPocketBadge, f_text_size(labelFontSize))
else
    f_delete_box(resetPocketBox)
    resetPocketBox := na
    f_delete_label(resetPocketBadge)
    resetPocketBadge := na

if showTargetCorridor and validPocket and recentReset and not invalidated and not na(targetGuide)
    float corridorTop = trendSide == 1 ? targetGuide : close
    float corridorBottom = trendSide == 1 ? close : targetGuide
    if corridorTop > corridorBottom
        int corridorRight = bar_index + renderBars
        int corridorBadgeX = int(math.round(bar_index + (corridorRight - bar_index) * zoneBadgeAnchor))
        if na(targetCorridorBox)
            targetCorridorBox := box.new(left = bar_index, top = corridorTop, right = corridorRight, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 92), border_color = color.new(accentColor, 55))
        else
            box.set_left(targetCorridorBox, bar_index)
            box.set_right(targetCorridorBox, corridorRight)
            box.set_top(targetCorridorBox, corridorTop)
            box.set_bottom(targetCorridorBox, corridorBottom)
        if na(targetCorridorBadge)
            targetCorridorBadge := label.new(corridorBadgeX, math.avg(corridorTop, corridorBottom), "Target Room", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 12), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
        else
            label.set_x(targetCorridorBadge, corridorBadgeX)
            label.set_y(targetCorridorBadge, math.avg(corridorTop, corridorBottom))
            label.set_text(targetCorridorBadge, "Target Room")
            label.set_color(targetCorridorBadge, color.new(accentColor, 12))
            label.set_textcolor(targetCorridorBadge, headerText)
            label.set_size(targetCorridorBadge, f_text_size(labelFontSize))
    else
        f_delete_box(targetCorridorBox)
        targetCorridorBox := na
        f_delete_label(targetCorridorBadge)
        targetCorridorBadge := na
else
    f_delete_box(targetCorridorBox)
    targetCorridorBox := na
    f_delete_label(targetCorridorBadge)
    targetCorridorBadge := na

if showGuideLines and validPocket
    if na(riskLine)
        riskLine := line.new(x1 = leftEdge, y1 = invalidationRail, x2 = rightEdge, y2 = invalidationRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(dangerColor, 0), style = line.style_dashed, width = 2)
    else
        line.set_xy1(riskLine, leftEdge, invalidationRail)
        line.set_xy2(riskLine, rightEdge, invalidationRail)
        line.set_color(riskLine, invalidated ? color.new(dangerColor, 0) : color.new(dangerColor, 15))
        line.set_style(riskLine, line.style_dashed)
        line.set_width(riskLine, invalidated ? 3 : 2)
    string riskGuideText = "Risk Rail\n" + f_price(invalidationRail)
    if na(riskGuideBadge)
        riskGuideBadge := label.new(rightEdge, invalidationRail, riskGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 5), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_x(riskGuideBadge, rightEdge)
        label.set_y(riskGuideBadge, invalidationRail)
        label.set_text(riskGuideBadge, riskGuideText)
        label.set_color(riskGuideBadge, color.new(dangerColor, 5))
        label.set_textcolor(riskGuideBadge, headerText)
        label.set_size(riskGuideBadge, f_text_size(labelFontSize))
else
    f_delete_line(riskLine)
    riskLine := na
    f_delete_label(riskGuideBadge)
    riskGuideBadge := na

if showGuideLines and validPocket
    if na(triggerGuideLine)
        triggerGuideLine := line.new(x1 = leftEdge, y1 = triggerLine, x2 = rightEdge, y2 = triggerLine, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 10), style = line.style_solid, width = 1)
    else
        line.set_xy1(triggerGuideLine, leftEdge, triggerLine)
        line.set_xy2(triggerGuideLine, rightEdge, triggerLine)
        line.set_color(triggerGuideLine, color.new(accentColor, 10))
    string triggerGuideText = "Reset Trigger\n" + f_price(triggerLine)
    if na(triggerGuideBadge)
        triggerGuideBadge := label.new(rightEdge, triggerLine, triggerGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 8), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_x(triggerGuideBadge, rightEdge)
        label.set_y(triggerGuideBadge, triggerLine)
        label.set_text(triggerGuideBadge, triggerGuideText)
        label.set_color(triggerGuideBadge, color.new(accentColor, 8))
        label.set_textcolor(triggerGuideBadge, headerText)
        label.set_size(triggerGuideBadge, f_text_size(labelFontSize))
else
    f_delete_line(triggerGuideLine)
    triggerGuideLine := na
    f_delete_label(triggerGuideBadge)
    triggerGuideBadge := na

if showGuideLines and validPocket and recentReset and not invalidated
    if na(targetLine)
        targetLine := line.new(x1 = bar_index, y1 = targetGuide, x2 = rightEdge, y2 = targetGuide, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), style = line.style_dotted, width = 1)
    else
        line.set_xy1(targetLine, bar_index, targetGuide)
        line.set_xy2(targetLine, rightEdge, targetGuide)
        line.set_color(targetLine, color.new(accentColor, 0))
    string targetGuideText = "Target Guide\n" + f_price(targetGuide)
    if na(targetGuideBadge)
        targetGuideBadge := label.new(rightEdge, targetGuide, targetGuideText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 5), textcolor = headerText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_x(targetGuideBadge, rightEdge)
        label.set_y(targetGuideBadge, targetGuide)
        label.set_text(targetGuideBadge, targetGuideText)
        label.set_color(targetGuideBadge, color.new(accentColor, 5))
        label.set_textcolor(targetGuideBadge, headerText)
        label.set_size(targetGuideBadge, f_text_size(labelFontSize))
else
    f_delete_line(targetLine)
    targetLine := na
    f_delete_label(targetGuideBadge)
    targetGuideBadge := na

plot(showEmaReferences and timeframeAllowed ? emaFast : na, title = "Fast Trigger EMA", color = color.new(trendColor, 5), linewidth = 1)
plot(showEmaReferences and timeframeAllowed ? emaBase : na, title = "Base Reset EMA", color = color.new(accentColor, 10), linewidth = 2)
plot(showEmaReferences and timeframeAllowed ? emaSlow : na, title = "Slow Support EMA", color = color.new(panelLabelCol, 15), linewidth = 2)

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> chartLabels = array.new_label()
var int lastEventLabelBar = na
var int lastContextLabelBar = na

bool resetEvent = recentReset and not recentReset[1] and confirmReady
bool readyEvent = readyState and not readyState[1] and confirmReady
bool invalidEvent = invalidated and not invalidated[1] and confirmReady
bool weakEvent = weakResetState and not weakResetState[1] and confirmReady
bool eventSpacingOk = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
bool eventNow = showEventLabels and eventSpacingOk and (readyEvent or invalidEvent or weakEvent or resetEvent)

if eventNow
    bool upStyle = invalidEvent ? trendSide == -1 : trendSide == 1
    float eventY = upStyle ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    string sidePrefix = trendSide == 1 ? "BULL " : trendSide == -1 ? "BEAR " : ""
    string eventText = readyEvent ? sidePrefix + "READY" + scoreSuffix : invalidEvent ? sidePrefix + "RESET LOST" : weakEvent ? sidePrefix + "WEAK RESET" + scoreSuffix : sidePrefix + "RESET" + scoreSuffix
    color eventColor = readyEvent ? trendColor : invalidEvent ? dangerColor : weakEvent ? neutralColor : accentColor
    f_add_label(chartLabels, bar_index, eventY, eventText, color.new(eventColor, 4), headerText, upStyle, labelFontSize, maxVisibleLabels)
    lastEventLabelBar := bar_index

bool contextEligible = showContextLabels and confirmReady and validPocket and not invalidated and (watchState or (waitResetState and continuationScore >= watchScore - 5)) and not eventNow
bool contextSpacingOk = na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars

if contextEligible and contextSpacingOk
    bool upStyleContext = trendSide == 1
    float contextY = upStyleContext ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    string contextSide = trendSide == 1 ? "BULL " : trendSide == -1 ? "BEAR " : ""
    string contextText = watchState ? contextSide + "WATCH" + scoreSuffix : contextSide + "MOMENTUM" + scoreSuffix
    color contextColor = watchState ? accentColor : trendColor
    f_add_label(chartLabels, bar_index, contextY, contextText, color.new(contextColor, 8), headerText, upStyleContext, labelFontSize, maxVisibleLabels)
    lastContextLabelBar := bar_index

// -------------------------------------------------
// Panel
// -------------------------------------------------
color panelFrame = f_panel_border(panelTheme)
var table panel = table.new(f_panel_position(panelLocation), 2, 7, bgcolor = f_panel_bg(panelTheme), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
string scoreRowLabel = waitResetState ? "Context Score" : "Continuation Score"
string riskRowLabel = waitResetState ? "Watch Risk" : "Risk Edge"

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocation))
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Momentum Pullback Continuation", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_set_row(panel, 1, "Momentum State", trendText, trendColor, panelTheme, panelFontSize)
        f_set_row(panel, 2, "Pullback Quality", pullbackText, stateColor, panelTheme, panelFontSize)
        f_set_row(panel, 3, scoreRowLabel, scoreText, timeframeAllowed ? f_score_color(continuationScore) : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_set_row(panel, 4, "Cont Rate", contRateText, contRateColor, panelTheme, panelFontSize)
        f_set_row(panel, 5, riskRowLabel, riskText, invalidated ? dangerColor : f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_set_row(panel, 6, "Action", actionText, stateColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool readyAlert = timeframeAllowed and readyEvent and continuationScore >= alertScoreThreshold
bool watchAlert = timeframeAllowed and watchState and not watchState[1] and confirmReady
bool invalidAlert = timeframeAllowed and invalidEvent
bool weakAlert = timeframeAllowed and weakEvent

alertcondition(readyAlert, "Momentum Pullback READY", "Momentum Pullback Continuation: READY state detected after a clean momentum reset.")
alertcondition(watchAlert, "Momentum Pullback WATCH", "Momentum Pullback Continuation: WATCH state detected while momentum reset is developing.")
alertcondition(invalidAlert, "Momentum Pullback INVALID", "Momentum Pullback Continuation: active reset context crossed the invalidation rail.")
alertcondition(weakAlert, "Momentum Pullback WEAK RESET", "Momentum Pullback Continuation: reset quality weakened and the plan may need to be rebuilt.")
````
