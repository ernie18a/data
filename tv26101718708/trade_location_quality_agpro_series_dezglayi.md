# Trade Location Quality [AGPro Series]

- url: https://www.tradingview.com/script/dEzglaYi-Trade-Location-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;45b9de354ebe4c52b73a01ae30298f07
- version: 6.0

## Description

Trade Location Quality [AGPro Series]

🧠 Core Idea

Is price in a clean trade location, or is it too close to obstruction, invalidation, or noisy range edges?


📌 Overview / What it does

Trade Location Quality [AGPro Series] is a chart-overlay risk-location planner designed to evaluate whether the current price area is practical for setup review.

The script measures range position, nearby obstruction rails, ATR-normalized risk distance, target room, trend support, and volatility fit. These inputs are combined into a 0-100 Location Quality Score with a clear state such as Clean Location, Watch Location, Obstructed, Danger Close, Risk Wide, or Poor Location.

It produces a forward location window, target/risk rails, compact event labels, alert conditions, and a premium AGPro panel. It does not predict price direction, automate execution, or print direct buy/sell commands.


🎯 Purpose & Design Philosophy

This script was built to solve a common planning problem: a setup may look interesting, but the trade location may still be weak because price is too stretched, too close to the next obstacle, or too close to invalidation.

The goal is to help traders think in terms of location quality before reacting to a setup. It supports a planning mindset: check context, evaluate room, review risk, then decide whether the area deserves attention.

It is designed for traders who want a clean decision layer rather than another generic signal marker.


⚡ Why This Script Is Different

Most tools focus on detecting a level, zone, breakout, or signal.

This script does NOT build a premium/discount map, OTE model, generic support/resistance scanner, order-block map, or prediction engine.

Instead, it asks a narrower planning question: is the current location clean enough to evaluate, or is the chart already blocked by risk, obstruction, or poor range position?


⚙️ Methodology

1. Context Detection
The script identifies the active evaluation side using either Auto Context, Long Context, or Short Context. Auto Context follows the trend-support basis.

2. Reference Mapping
It maps the recent range, nearest obstruction rails, opposite-side risk rail, estimated invalidation reference, and ATR-normalized room.

3. Reaction Evaluation
It scores location quality using range position, target room, risk distance, trend support, and volatility fit.

4. Visual Output
It displays a forward location window, target/risk rails, state labels, alerts, and a compact AGPro panel.


🗺️ How to Read the Chart

Location Window = the current area where price location is being evaluated.

Target Obstruction Rail = the nearest meaningful obstacle in the evaluation direction.

Risk Rail = the opposite-side reference used to estimate invalidation distance.

Labels = compact state markers showing the current planner condition and score.

Colors = teal and indigo suggest stronger quality, amber suggests caution, and pink/red suggests weak or risky location.

Panel = summarizes score, state, range position, obstruction distance, risk state, and next action.


🚦 Signals & States

• Clean Location → location score is strong, room is sufficient, and risk distance is balanced.

• Watch Location → context is acceptable but not strong enough for the clean-location state.

• Obstructed → price is too close to the next target-side obstruction rail.

• Danger Close → invalidation is too close for a balanced location read.

• Risk Wide → invalidation is too far away, making the location less efficient.

• Poor Location → score and context are not strong enough for planning attention.


🔔 Alerts Logic

• Clean Location → triggers when the script enters the Clean Location state.

• Obstructed Location → triggers when price becomes too close to the next obstruction rail.

• Risk Location Warning → triggers when risk distance becomes too tight or too wide.

• Watch Location → triggers when a watchable location context appears without reaching Clean Location.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

Location quality improves when range position, target room, balanced risk distance, trend support, and stable volatility align.

The strongest read appears when the score is high and the panel also shows enough obstruction distance with a balanced risk state.


📊 When to Use

• During setup planning before reacting to a signal.

• Around pullbacks where risk and target room matter.

• During trend continuation review when price may be clean or already stretched.

• Before breakout or reversal evaluation when nearby obstruction can change the quality of the idea.

• On liquid markets where ATR and pivot references are meaningful.


⚠️ When NOT to Use

• Extremely low-liquidity markets with unreliable candles.

• Highly noisy periods where rails change too frequently.

• Extreme volatility spikes where ATR-based distance can expand rapidly.

• Charts where the user has no broader context for directional evaluation.

• As a standalone reason to enter or exit a trade.


🎛️ Key Inputs

• Evaluation Context → selects Auto, Long, or Short planning context.

• Location Lookback → defines the recent structure window.

• Obstruction Pivot Length → controls how strict obstruction rails are.

• Minimum Clean Score → sets the quality threshold for Clean Location.

• Minimum Target Room ATR → controls how much room must exist before the next obstruction.

• Risk Buffer Inputs → define what counts as too close or too wide.

• Visual Settings → control compact or detailed labels, rails, location window, panel visibility, theme, location, and font sizes.


🖥️ Interface & Visual Design

The interface is intentionally chart-first.

The location window shows the active evaluation area without filling the chart with many competing zones. The obstruction rails provide practical reference points. The default labels use compact state tags, while hover tooltips retain the deeper score, room, risk, and action context. Cooldown and maximum-visible settings keep the chart active but not crowded.

The panel follows the AGPro publication layout with a single merged blue title row, adjustable location, adjustable theme, and adjustable font size.


🧪 Practical Usage Workflow

1. Read the panel score and state.

2. Check whether target-side room is open or obstructed.

3. Review whether risk distance is balanced, too close, or too wide.

4. Compare the location window with broader market context.

5. Treat alerts and labels as attention markers, not decisions.


🔍 Interpretation Guidelines

A high score means the location is cleaner relative to the script's rule set. It does not mean price must move in the evaluated direction.

An obstructed state means room is limited before the next nearby reference. It does not mean price cannot break through that area.

A risk warning means the current location is less balanced for planning. It should be interpreted with timeframe, volatility, and broader structure.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a buy/sell signal service.

• Not a premium/discount or OTE zone engine.

• Not a generic support/resistance zone scanner.


⚠️ Limitations & Transparency

Location quality depends on the selected lookback, pivot length, volatility profile, and timeframe.

Different markets can produce different rail behavior. High volatility may widen risk distance. Low volatility may compress target room. Small timeframes may produce more frequent state changes.

The script is rule-based and should be read as a planning tool inside broader analysis.


🧠 Market Context Notes

Trade location is not only about where price is. It is also about what sits nearby.

A location can look attractive but still be weak if there is not enough clean room before the next obstruction. A location can also be risky if invalidation is too close or too far for the current volatility environment.

This script organizes those conditions into a single readable decision layer.


🧾 Use Case Examples

When price pulls back inside a trend and the score improves while risk remains balanced, the chart may deserve closer review.

When price is near a target-side rail and the panel shows Obstructed, the user can recognize that nearby room is limited.

When volatility expands and risk distance becomes too wide, the script can mark the location as less efficient for planning.


🧱 System Philosophy

Trade Location Quality follows the AGPro decision-engine approach: the script should help the user evaluate context, quality, risk, room, and next action without promising an outcome.

The goal is not to add another signal. The goal is to improve the quality of the planning process.


🔐 Non-Promise Statement

No script can guarantee direction, continuation, reversal, or outcome.

This tool provides structured chart context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk controls, position sizing, and trading decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use the script to study how trade location changes as price moves closer to risk, target, obstruction, and range edges. The most useful reading comes from comparing the panel state with the visible chart context.

## Source Code

````pine
// -------------------------------------------------
// Trade Location Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6.2
//
// Trade Location Quality is a chart-first risk-location planner for reviewing
// whether price is sitting in a clean execution area or too close to nearby
// obstruction, invalidation, noisy range edges, wide-risk structure, or poor
// target room. It combines range position, obstruction rails, risk distance,
// trend support, ATR context, and target-room quality into a 0-100 location
// quality score, plus a confirmation-anchored proof layer (Follow, Hold, React,
// Flip rates) that measures distinct review phases without overlapping samples.
// Version 1.6.2 preserves the professional label hierarchy introduced in
// Version 1.6.1 and corrects multiline string construction for Pine v6
// compilation without changing analytical, scoring, Proof, or alert logic.
// -------------------------------------------------

//@version=6
indicator("Trade Location Quality [AGPro Series]",
     shorttitle       = "AG TLQ",
     overlay          = true,
     max_labels_count = 110,
     max_lines_count  = 24,
     max_boxes_count  = 12,
     max_bars_back    = 700)

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
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_PRESET = "Selects the default operating profile. Balanced Location is the publication default. Cleaner Swing reduces label and rail density. Active Intraday reacts faster. Custom uses the raw inputs below."
const string TT_CONTEXT = "Selects the side used for location evaluation. Auto Context follows trend and price location. Manual modes keep the planner fixed to one side."
const string TT_LOOKBACK = "Defines the recent structure window used to calculate range position, nearby rails, and local trade-location context."
const string TT_PIVOT = "Controls how strict the pivot logic is when collecting nearby obstruction references. Higher values create fewer but stronger rails."
const string TT_TREND = "EMA length used as the trend-support reference in the quality score. It is context only, not a standalone signal."
const string TT_ATR = "ATR length used to normalize risk distance, obstruction distance, volatility state, rails, and label offsets."
const string TT_CONFIRM = "Close Confirmed waits for closed bars before printing new labels and alerts. Live Updating can react intrabar."
const string TT_CLEAN = "Minimum 0-100 score required before the planner marks location quality as review-ready."
const string TT_WATCH = "Minimum 0-100 score required before the script treats the area as watchable rather than poor location."
const string TT_ROOM = "Minimum ATR-normalized room required between current price and the next obstruction rail."
const string TT_RISK_MIN = "If invalidation is closer than this ATR value, the planner marks the location as too close to risk."
const string TT_RISK_MAX = "If invalidation is farther than this ATR value, the planner marks the location as wide-risk."
const string TT_OPEN_ROOM = "Fallback room used when no confirmed obstruction rail exists beyond current price."
const string TT_INVALID = "Small ATR buffer placed beyond the opposite obstruction rail to estimate invalidation context."
const string TT_WINDOW = "Displays the current quality window as a forward box with a centered premium status badge."
const string TT_RAILS = "Displays nearby upper and lower obstruction rails used by the planner."
const string TT_RAIL_LABELS = "Shows compact right-side labels for target-room and risk rails. Disable this if the price scale becomes crowded."
const string TT_RAIL_OFFSET = "Moves rail labels to the right while extending their reference rails to the same x-position, so labels remain clearly attached to real levels."
const string TT_TREND_BASIS = "Shows the trend-support EMA used by the model. Hidden by default to keep public charts cleaner."
const string TT_LABELS = "Displays compact state labels when location state changes or remains important after the cooldown."
const string TT_LABEL_MODE = "Compact keeps publication charts cleaner. Detailed prints the full state and score on labels."
const string TT_COOLDOWN = "Minimum number of bars between planner labels. This keeps label density active but controlled."
const string TT_MAX_LABELS = "Limits how many recent planner labels remain on the chart."
const string TT_FORWARD = "Controls how far the active location window and rails extend to the right."
const string TT_OFFSET = "ATR-based vertical offset used to keep event labels away from candles."
const string TT_FONT = "Controls all chart label sizes produced by the script. Normal is the recommended publication default."
const string TT_PANEL = "Shows or hides the AG Pro information panel. The default is visible for publication-ready chart context."
const string TT_PANEL_LOC = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_FONT = "Controls the panel text size. Normal is the recommended publication default."
const string TT_SHOWPROOF = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across rolling evaluation windows in the active review context on the current symbol and timeframe. Follow means price advanced one risk unit (1R) in favor, or reached the room edge if it was closer, before invalidation. These are historical outcome rates, not predictions."
const string TT_PROOF_HORIZON = "Number of bars each rolling location window is tracked forward to measure whether price advanced favorably before the invalidation reference was breached."
const string TT_REACT_BARS = "Number of bars after a window opens used to detect an immediate favorable reaction."
const string TT_REACT_PROGRESS = "Minimum favorable progress, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Location Engine"
enginePreset = input.string("Balanced Location", "Engine Preset", options = ["Balanced Location", "Cleaner Swing", "Active Intraday", "Custom"], group = groupEngine, tooltip = TT_PRESET)
contextMode = input.string("Auto Context", "Evaluation Context", options = ["Auto Context", "Long Context", "Short Context"], group = groupEngine, tooltip = TT_CONTEXT)
locationLookback = input.int(96, "Location Lookback", minval = 40, maxval = 300, group = groupEngine, tooltip = TT_LOOKBACK)
pivotLength = input.int(5, "Obstruction Pivot Length", minval = 2, maxval = 20, group = groupEngine, tooltip = TT_PIVOT)
trendLength = input.int(55, "Trend Support Length", minval = 10, maxval = 200, group = groupEngine, tooltip = TT_TREND)
atrLength = input.int(14, "ATR Length", minval = 5, maxval = 50, group = groupEngine, tooltip = TT_ATR)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = TT_CONFIRM)

groupQuality = "Quality Model"
minCleanScore = input.int(68, "Minimum Review Score", minval = 40, maxval = 95, group = groupQuality, tooltip = TT_CLEAN)
minWatchScore = input.int(54, "Minimum Watch Score", minval = 30, maxval = 90, group = groupQuality, tooltip = TT_WATCH)
minimumRoomAtr = input.float(1.35, "Minimum Target Room ATR", minval = 0.4, maxval = 5.0, step = 0.05, group = groupQuality, tooltip = TT_ROOM)
minimumRiskAtr = input.float(0.35, "Minimum Risk Buffer ATR", minval = 0.1, maxval = 2.0, step = 0.05, group = groupQuality, tooltip = TT_RISK_MIN)
maximumRiskAtr = input.float(2.75, "Maximum Risk Distance ATR", minval = 0.8, maxval = 6.0, step = 0.05, group = groupQuality, tooltip = TT_RISK_MAX)
openRoomProjectionAtr = input.float(2.25, "Open Room Projection ATR", minval = 0.8, maxval = 6.0, step = 0.05, group = groupQuality, tooltip = TT_OPEN_ROOM)
invalidationBufferAtr = input.float(0.15, "Invalidation Buffer ATR", minval = 0.0, maxval = 1.0, step = 0.05, group = groupQuality, tooltip = TT_INVALID)

groupVisual = "Chart Visuals"
showLocationWindow = input.bool(true, "Show Location Window", group = groupVisual, tooltip = TT_WINDOW)
showObstructionRails = input.bool(true, "Show Obstruction Rails", group = groupVisual, tooltip = TT_RAILS)
showRailLabels = input.bool(true, "Show Rail Labels", group = groupVisual, tooltip = TT_RAIL_LABELS)
railLabelOffsetBars = input.int(8, "Rail Label Offset Bars", minval = 0, maxval = 60, group = groupVisual, tooltip = TT_RAIL_OFFSET)
showTrendBasis = input.bool(false, "Show Trend Basis", group = groupVisual, tooltip = TT_TREND_BASIS)
showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = TT_LABELS)
labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupVisual, tooltip = TT_LABEL_MODE)
labelCooldown = input.int(20, "Label Cooldown Bars", minval = 3, maxval = 80, group = groupVisual, tooltip = TT_COOLDOWN)
maxVisibleLabels = input.int(9, "Max Visible Labels", minval = 4, maxval = 24, group = groupVisual, tooltip = TT_MAX_LABELS)
renderForwardBars = input.int(34, "Forward Render Bars", minval = 8, maxval = 120, group = groupVisual, tooltip = TT_FORWARD)
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.20, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = TT_OFFSET)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = TT_FONT)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOC)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_FONT)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = TT_SHOWPROOF)
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = TT_PROOF_HORIZON)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = TT_REACT_BARS)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = TT_REACT_PROGRESS)

groupAlerts = "Alerts"
alertCleanWatch = input.bool(true, "Alert on Review and Watch", group = groupAlerts, tooltip = "Enables alerts when the planner enters review-ready or watchable location context.")
alertWarnings = input.bool(true, "Alert on Obstruction or Risk Warning", group = groupAlerts, tooltip = "Enables alerts when price is obstructed, too close to risk, or too wide from invalidation.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

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

f_score_color(int score, int cleanLevel, int watchLevel) =>
    score >= 78 ? bullColor : score >= cleanLevel ? accentColor : score >= watchLevel ? neutralColor : bearColor

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_grade(int score) =>
    score >= 86 ? "A+" : score >= 78 ? "A" : score >= 68 ? "B" : score >= 56 ? "C" : score >= 44 ? "D" : "E"

f_fmt_1(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_range_pos_text(float posValue) =>
    str.tostring(math.round(posValue * 100.0)) + "%"

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

f_delete_line(line item) =>
    if not na(item)
        line.delete(item)

f_delete_box(box item) =>
    if not na(item)
        box.delete(item)

// -------------------------------------------------
// Presets
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
activePreset = enginePreset == "Active Intraday"
customPreset = enginePreset == "Custom"

usedCleanScoreRaw = customPreset ? minCleanScore : cleanerPreset ? math.max(minCleanScore, 72) : activePreset ? math.max(minCleanScore - 4, 40) : minCleanScore
usedWatchScoreRaw = customPreset ? minWatchScore : cleanerPreset ? math.max(minWatchScore, 58) : activePreset ? math.max(minWatchScore - 4, 30) : minWatchScore
usedCleanScore = math.max(usedCleanScoreRaw, usedWatchScoreRaw + 1)
usedWatchScore = math.min(usedWatchScoreRaw, usedCleanScore - 1)

usedLabelCooldown = customPreset ? labelCooldown : cleanerPreset ? math.max(labelCooldown, 28) : activePreset ? math.min(labelCooldown, 14) : labelCooldown
usedMaxLabels = customPreset ? maxVisibleLabels : cleanerPreset ? math.min(maxVisibleLabels, 5) : activePreset ? math.min(maxVisibleLabels, 8) : math.min(maxVisibleLabels, 7)
usedForwardBars = customPreset ? renderForwardBars : cleanerPreset ? math.max(renderForwardBars, 38) : activePreset ? math.min(renderForwardBars, 24) : renderForwardBars

effectiveMinimumRoomAtr = math.max(minimumRoomAtr, 0.05)
effectiveMinimumRiskAtr = math.min(minimumRiskAtr, maximumRiskAtr)
effectiveMaximumRiskAtr = math.max(maximumRiskAtr, effectiveMinimumRiskAtr + 0.05)
effectiveRiskIdealAtr = f_clamp(1.25, effectiveMinimumRiskAtr, effectiveMaximumRiskAtr)
effectiveOpenRoomProjectionAtr = math.max(openRoomProjectionAtr, effectiveMinimumRoomAtr)
effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

// -------------------------------------------------
// Core Location Model
// -------------------------------------------------
confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
proofConfirmedBar = barstate.isconfirmed
engineWarmup = math.max(locationLookback, math.max(trendLength, atrLength * 4)) + pivotLength * 2 + 5
engineReady = bar_index > engineWarmup

atr = math.max(nz(ta.atr(atrLength), syminfo.mintick), syminfo.mintick)
trendBasis = ta.ema(close, trendLength)
trendSlope = trendBasis - nz(trendBasis[5], trendBasis)

rangeHighRaw = ta.highest(high, locationLookback)
rangeLowRaw = ta.lowest(low, locationLookback)
rangeHigh = nz(rangeHighRaw, high)
rangeLow = nz(rangeLowRaw, low)
rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangePos = f_clamp((close - rangeLow) / rangeSpan, 0.0, 1.0)

autoLongContext = close >= trendBasis
longContext = contextMode == "Long Context" ? true : contextMode == "Short Context" ? false : autoLongContext
contextText = longContext ? "Long review" : "Short review"
contextShort = longContext ? "LONG" : "SHORT"

ph = ta.pivothigh(high, pivotLength, pivotLength)
pl = ta.pivotlow(low, pivotLength, pivotLength)

var array<float> pivotHighs = array.new_float()
var array<int> pivotHighBars = array.new_int()
var array<float> pivotLows = array.new_float()
var array<int> pivotLowBars = array.new_int()

if not na(ph)
    array.push(pivotHighs, ph)
    array.push(pivotHighBars, bar_index - pivotLength)

if not na(pl)
    array.push(pivotLows, pl)
    array.push(pivotLowBars, bar_index - pivotLength)

// Keep confirmed pivot references inside the selected Location Lookback.
while array.size(pivotHighBars) > 0 and bar_index - array.get(pivotHighBars, 0) > locationLookback
    array.shift(pivotHighBars)
    array.shift(pivotHighs)

while array.size(pivotLowBars) > 0 and bar_index - array.get(pivotLowBars, 0) > locationLookback
    array.shift(pivotLowBars)
    array.shift(pivotLows)

while array.size(pivotHighs) > 48
    array.shift(pivotHighs)
    array.shift(pivotHighBars)

while array.size(pivotLows) > 48
    array.shift(pivotLows)
    array.shift(pivotLowBars)

pastHigh = nz(ta.highest(high[1], locationLookback), high)
pastLow = nz(ta.lowest(low[1], locationLookback), low)

float nearestAbove = pastHigh > close ? pastHigh : na
float nearestBelow = pastLow < close ? pastLow : na

if array.size(pivotHighs) > 0
    for i = 0 to array.size(pivotHighs) - 1
        float level = array.get(pivotHighs, i)
        if level > close and (na(nearestAbove) or level < nearestAbove)
            nearestAbove := level

if array.size(pivotLows) > 0
    for i = 0 to array.size(pivotLows) - 1
        float level = array.get(pivotLows, i)
        if level < close and (na(nearestBelow) or level > nearestBelow)
            nearestBelow := level

upperRail = na(nearestAbove) ? close + atr * effectiveOpenRoomProjectionAtr : nearestAbove
lowerRail = na(nearestBelow) ? close - atr * effectiveOpenRoomProjectionAtr : nearestBelow

targetRail = longContext ? upperRail : lowerRail
oppositeRail = longContext ? lowerRail : upperRail
invalidationLevel = longContext ? oppositeRail - atr * invalidationBufferAtr : oppositeRail + atr * invalidationBufferAtr
targetRoomAtrRaw = longContext ? (targetRail - close) / atr : (close - targetRail) / atr
riskDistanceAtrRaw = longContext ? (close - invalidationLevel) / atr : (invalidationLevel - close) / atr
targetRoomAtr = math.max(targetRoomAtrRaw, 0.0)
riskDistanceAtr = math.max(riskDistanceAtrRaw, 0.0)

idealPosition = longContext ? 0.38 : 0.62
locationComponent = f_clamp(100.0 - math.abs(rangePos - idealPosition) * 220.0, 0.0, 100.0)
locationComponent := longContext and rangePos > 0.82 ? math.min(locationComponent, 38.0) : locationComponent
locationComponent := not longContext and rangePos < 0.18 ? math.min(locationComponent, 38.0) : locationComponent
locationComponent := longContext and rangePos < 0.07 ? math.min(locationComponent, 58.0) : locationComponent
locationComponent := not longContext and rangePos > 0.93 ? math.min(locationComponent, 58.0) : locationComponent

obstructionComponent = f_clamp(targetRoomAtr / effectiveMinimumRoomAtr * 76.0, 0.0, 100.0)
obstructionComponent := targetRoomAtr >= effectiveMinimumRoomAtr * 1.55 ? math.min(100.0, obstructionComponent + 18.0) : obstructionComponent

riskComponent = f_clamp(100.0 - math.abs(riskDistanceAtr - effectiveRiskIdealAtr) * 42.0, 0.0, 100.0)
riskComponent := riskDistanceAtr < effectiveMinimumRiskAtr ? math.min(riskComponent, 30.0) : riskComponent
riskComponent := riskDistanceAtr > effectiveMaximumRiskAtr ? math.min(riskComponent, 42.0) : riskComponent

trendAligned = longContext ? close >= trendBasis : close <= trendBasis
slopeAligned = longContext ? trendSlope >= 0 : trendSlope <= 0
trendComponent = trendAligned and slopeAligned ? 100.0 : trendAligned ? 74.0 : slopeAligned ? 58.0 : 24.0

atrBase = nz(ta.sma(atr, atrLength * 3), atr)
volRatio = atrBase == 0.0 ? 1.0 : atr / atrBase
volComponent = f_clamp(100.0 - math.abs(volRatio - 1.0) * 90.0, 0.0, 100.0)
volComponent := volRatio < 0.55 or volRatio > 1.90 ? math.min(volComponent, 45.0) : volComponent

tooCloseRisk = engineReady and riskDistanceAtr < effectiveMinimumRiskAtr
riskTooWide = engineReady and riskDistanceAtr > effectiveMaximumRiskAtr
obstructed = engineReady and targetRoomAtr < effectiveMinimumRoomAtr

scoreRaw = locationComponent * 0.30 + obstructionComponent * 0.25 + riskComponent * 0.20 + trendComponent * 0.15 + volComponent * 0.10
scoreCapped = tooCloseRisk ? math.min(scoreRaw, usedWatchScore - 8.0) : riskTooWide ? math.min(scoreRaw, usedWatchScore - 4.0) : obstructed ? math.min(scoreRaw, usedCleanScore - 4.0) : scoreRaw
locationScore = int(math.round(f_clamp(scoreCapped, 0.0, 100.0)))
locationGrade = f_grade(locationScore)

reviewLocation = engineReady and locationScore >= usedCleanScore and not tooCloseRisk and not riskTooWide and not obstructed
watchLocation = engineReady and locationScore >= usedWatchScore and not tooCloseRisk and not riskTooWide

stateText = reviewLocation ? "Review Location" : tooCloseRisk ? "Build Buffer" : riskTooWide ? "Risk Too Wide" : obstructed ? "Check Room" : watchLocation ? "Track Reaction" : "Stand Aside"
contextState = reviewLocation ? "Clean location" : tooCloseRisk ? "Risk too close" : riskTooWide ? "Wide-risk area" : obstructed ? "Obstructed room" : watchLocation ? "Watchable area" : "Poor location"
reviewText = reviewLocation ? "Review reaction" : obstructed ? "Wait room" : tooCloseRisk ? "Build buffer" : riskTooWide ? "Reduce assumption" : watchLocation ? "Track reaction" : "Stand aside"
riskState = tooCloseRisk ? "Too close" : riskTooWide ? "Too wide" : "Balanced"
stateColor = reviewLocation ? f_score_color(locationScore, usedCleanScore, usedWatchScore) : obstructed ? neutralColor : tooCloseRisk or riskTooWide ? dangerColor : watchLocation ? accentColor : bearColor
badgeTextColor = stateText == "Check Room" ? darkText : headerText

eventCode = reviewLocation ? "REVIEW" : tooCloseRisk ? "BUFFER" : riskTooWide ? "WIDE" : obstructed ? "ROOM" : watchLocation ? "WATCH" : "STAND"
volText = volRatio > 1.90 ? "Noisy ATR" : volRatio < 0.55 ? "Quiet ATR" : "Balanced ATR"

// -------------------------------------------------
// Confirmation-anchored proof (qualified location phases)
// -------------------------------------------------
proofQualifiedState = reviewLocation or watchLocation
proofPreviousQualified = bar_index > 0 and (reviewLocation[1] or watchLocation[1])
proofContextDir = longContext ? 1 : -1
proofQualifiedEvent = proofConfirmedBar and engineReady and proofQualifiedState and (not proofPreviousQualified or proofContextDir != nz(proofContextDir[1], proofContextDir))

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

if proofConfirmedBar and engineReady
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool directionReplaced = proofContextDir != pEvalDir
        bool ambiguousNow = targetTouched and (stopTouched or directionReplaced)

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched and not directionReplaced
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or directionReplaced or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched and not directionReplaced
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched or directionReplaced
                    proofFlip := proofFlip + 1

            pEvalActive := false
            pLastResolveBar := bar_index

    // Start one non-overlapping evaluation when a new qualified review phase begins.
    bool proofRestartReady = na(pLastResolveBar) or bar_index > pLastResolveBar
    if proofQualifiedEvent and not pEvalActive and proofRestartReady
        pEvalActive := true
        pEvalDir := proofContextDir
        pEvalEntry := close
        pEvalStop := invalidationLevel

        float pStopDist = math.max(math.abs(close - invalidationLevel), syminfo.mintick)
        float pEdgeDist = math.max(math.abs(targetRail - close), syminfo.mintick)
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
// Current Chart Objects
// -------------------------------------------------
labelSz = f_text_size(labelFontSize)
renderLeft = math.max(bar_index - int(math.min(locationLookback, 140)), 0)
renderRight = bar_index + usedForwardBars
upperRailLabelX = renderRight + railLabelOffsetBars
lowerRailLabelX = upperRailLabelX + 3
upperRailRight = showRailLabels ? upperRailLabelX : renderRight
lowerRailRight = showRailLabels ? lowerRailLabelX : renderRight

bandLowPct = longContext ? 0.20 : 0.45
bandHighPct = longContext ? 0.55 : 0.80
locationBandLow = rangeLow + rangeSpan * bandLowPct
locationBandHigh = rangeLow + rangeSpan * bandHighPct
windowTop = math.max(locationBandLow, locationBandHigh)
windowBot = math.min(locationBandLow, locationBandHigh)
windowMid = (windowTop + windowBot) * 0.5
windowCenterX = int(math.round((renderLeft + renderRight) * 0.5))

var box locationWindow = na
var label locationWindowLabel = na
var line upperObstructionLine = na
var line lowerObstructionLine = na
var label upperRailLabel = na
var label lowerRailLabel = na

windowBg = color.new(stateColor, reviewLocation ? 85 : 91)
windowBorder = color.new(stateColor, reviewLocation ? 16 : 34)
windowText = eventCode + " " + str.tostring(locationScore) + "\n" + contextShort

if barstate.islast
    if showLocationWindow
        if na(locationWindow)
            locationWindow := box.new(renderLeft, windowTop, renderRight, windowBot, xloc = xloc.bar_index, bgcolor = windowBg, border_color = windowBorder, border_width = reviewLocation ? 2 : 1)
        else
            box.set_left(locationWindow, renderLeft)
            box.set_right(locationWindow, renderRight)
            box.set_top(locationWindow, windowTop)
            box.set_bottom(locationWindow, windowBot)
            box.set_bgcolor(locationWindow, windowBg)
            box.set_border_color(locationWindow, windowBorder)
            box.set_border_width(locationWindow, reviewLocation ? 2 : 1)

        if na(locationWindowLabel)
            locationWindowLabel := label.new(windowCenterX, windowMid, windowText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = badgeTextColor, color = color.new(stateColor, 0), size = labelSz, textalign = text.align_center)
        else
            label.set_x(locationWindowLabel, windowCenterX)
            label.set_y(locationWindowLabel, windowMid)
            label.set_text(locationWindowLabel, windowText)
            label.set_textcolor(locationWindowLabel, badgeTextColor)
            label.set_color(locationWindowLabel, color.new(stateColor, 0))
            label.set_size(locationWindowLabel, labelSz)
            label.set_textalign(locationWindowLabel, text.align_center)
    else
        f_delete_box(locationWindow)
        f_delete_label(locationWindowLabel)
        locationWindow := na
        locationWindowLabel := na

    if showObstructionRails
        if na(upperObstructionLine)
            upperObstructionLine := line.new(renderLeft, upperRail, upperRailRight, upperRail, xloc = xloc.bar_index, color = color.new(accentColor, 18), style = line.style_dotted, width = 1)
        else
            line.set_xy1(upperObstructionLine, renderLeft, upperRail)
            line.set_xy2(upperObstructionLine, upperRailRight, upperRail)
            line.set_color(upperObstructionLine, color.new(accentColor, 18))

        if na(lowerObstructionLine)
            lowerObstructionLine := line.new(renderLeft, lowerRail, lowerRailRight, lowerRail, xloc = xloc.bar_index, color = color.new(neutralColor, 20), style = line.style_dotted, width = 1)
        else
            line.set_xy1(lowerObstructionLine, renderLeft, lowerRail)
            line.set_xy2(lowerObstructionLine, lowerRailRight, lowerRail)
            line.set_color(lowerObstructionLine, color.new(neutralColor, 20))

        upperText = longContext ? "ROOM" : "RISK"
        lowerText = longContext ? "RISK" : "ROOM"
        if showRailLabels
            if na(upperRailLabel)
                upperRailLabel := label.new(upperRailLabelX, upperRail, upperText + " " + f_fmt_1(math.abs(upperRail - close) / atr), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = headerText, color = color.new(accentColor, 8), size = labelSz)
            else
                label.set_x(upperRailLabel, upperRailLabelX)
                label.set_y(upperRailLabel, upperRail)
                label.set_text(upperRailLabel, upperText + " " + f_fmt_1(math.abs(upperRail - close) / atr))
                label.set_style(upperRailLabel, label.style_label_left)
                label.set_color(upperRailLabel, color.new(accentColor, 8))
                label.set_textcolor(upperRailLabel, headerText)
                label.set_size(upperRailLabel, labelSz)

            if na(lowerRailLabel)
                lowerRailLabel := label.new(lowerRailLabelX, lowerRail, lowerText + " " + f_fmt_1(math.abs(close - lowerRail) / atr), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = darkText, color = color.new(neutralColor, 6), size = labelSz)
            else
                label.set_x(lowerRailLabel, lowerRailLabelX)
                label.set_y(lowerRailLabel, lowerRail)
                label.set_text(lowerRailLabel, lowerText + " " + f_fmt_1(math.abs(close - lowerRail) / atr))
                label.set_style(lowerRailLabel, label.style_label_left)
                label.set_color(lowerRailLabel, color.new(neutralColor, 6))
                label.set_textcolor(lowerRailLabel, darkText)
                label.set_size(lowerRailLabel, labelSz)
        else
            f_delete_label(upperRailLabel)
            f_delete_label(lowerRailLabel)
            upperRailLabel := na
            lowerRailLabel := na
    else
        f_delete_line(upperObstructionLine)
        f_delete_line(lowerObstructionLine)
        f_delete_label(upperRailLabel)
        f_delete_label(lowerRailLabel)
        upperObstructionLine := na
        lowerObstructionLine := na
        upperRailLabel := na
        lowerRailLabel := na

plot(showTrendBasis ? trendBasis : na, "Trend Basis", color = color.new(accentColor, 25), linewidth = 1)

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
var array<label> eventLabels = array.new_label()
var int lastLabelBar = na
var int lastLabelLane = 0

f_store_label(label item) =>
    array.push(eventLabels, item)
    while array.size(eventLabels) > usedMaxLabels
        label oldLabel = array.shift(eventLabels)
        label.delete(oldLabel)

barsFromLastLabel = na(lastLabelBar) ? 100000 : bar_index - lastLabelBar

// Group rapidly changing raw states into broader visual families. This avoids
// printing separate WIDE, BUFFER, ROOM, and STAND labels inside one noisy cluster.
warningFamily = tooCloseRisk or riskTooWide or obstructed
constructiveFamily = reviewLocation or watchLocation
previousWarningFamily = bar_index > 0 and (tooCloseRisk[1] or riskTooWide[1] or obstructed[1])
previousConstructiveFamily = bar_index > 0 and (reviewLocation[1] or watchLocation[1])

reviewEntryEvent = engineReady and reviewLocation and not reviewLocation[1]
watchEntryEvent = engineReady and watchLocation and not reviewLocation and not (watchLocation[1] and not reviewLocation[1])
warningEntryEvent = engineReady and warningFamily and not previousWarningFamily
constructiveExitEvent = engineReady and previousConstructiveFamily and not constructiveFamily

eventFamily = reviewEntryEvent ? "REVIEW" :
     watchEntryEvent ? "WATCH" :
     warningEntryEvent ? "WARNING" :
     constructiveExitEvent ? "EXIT" :
     ""

criticalLocationEvent = eventFamily != ""
periodicImportant = engineReady and (reviewLocation or watchLocation) and barsFromLastLabel >= usedLabelCooldown * 5
shouldPrintLabel = showLabels and confirmedBar and (criticalLocationEvent or periodicImportant)

if shouldPrintLabel
    displayCode = reviewEntryEvent ? "REVIEW" :
         watchEntryEvent ? "WATCH" :
         warningEntryEvent ? (tooCloseRisk ? "BUFFER" : riskTooWide ? "WIDE" : "ROOM") :
         constructiveExitEvent ? (tooCloseRisk ? "BUFFER" : riskTooWide ? "WIDE" : obstructed ? "ROOM" : "RESET") :
         eventCode

    warningLabel = eventFamily == "WARNING" or eventFamily == "EXIT"
    labelBelow = warningLabel ? not longContext : longContext

    // Separate historical clusters across three ATR lanes.
    laneOffsetAtr = float(lastLabelLane) * 0.42
    labelY = labelBelow ? low - atr * (labelOffsetAtr + laneOffsetAtr) : high + atr * (labelOffsetAtr + laneOffsetAtr)
    labelStyle = labelBelow ? label.style_label_up : label.style_label_down

    eventText = displayCode + " " + str.tostring(locationScore)
    if labelTextMode == "Detailed"
        eventText := stateText + "\nScore " + str.tostring(locationScore)

    eventTip = contextState +
         "\nScore: " + str.tostring(locationScore) +
         "\nRoom: " + f_fmt_1(targetRoomAtr) + " ATR" +
         "\nRisk: " + f_fmt_1(riskDistanceAtr) + " ATR" +
         "\nReview: " + reviewText

    labelColor = warningLabel ? (obstructed ? neutralColor : dangerColor) : stateColor
    textColor = warningLabel and obstructed ? darkText : headerText

    // Nearby events update the latest label instead of creating a new overlap.
    mergeBars = math.max(4, int(math.round(usedLabelCooldown * 0.40)))
    mergeWithLast = array.size(eventLabels) > 0 and barsFromLastLabel < mergeBars

    if mergeWithLast
        label clusterLabel = array.get(eventLabels, array.size(eventLabels) - 1)
        label.set_xy(clusterLabel, bar_index, labelY)
        label.set_text(clusterLabel, eventText)
        label.set_style(clusterLabel, labelStyle)
        label.set_textcolor(clusterLabel, textColor)
        label.set_color(clusterLabel, color.new(labelColor, 4))
        label.set_size(clusterLabel, labelSz)
        label.set_tooltip(clusterLabel, eventTip)
    else
        label eventLabel = label.new(
             bar_index,
             labelY,
             eventText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = labelStyle,
             textcolor = textColor,
             color = color.new(labelColor, 4),
             size = labelSz,
             tooltip = eventTip,
             textalign = text.align_center)
        f_store_label(eventLabel)
        lastLabelLane := (lastLabelLane + 1) % 3

    lastLabelBar := bar_index

if barstate.islast and array.size(eventLabels) > 0
    if showLabels
        for i = 0 to array.size(eventLabels) - 1
            label.set_size(array.get(eventLabels, i), labelSz)
    else
        for i = 0 to array.size(eventLabels) - 1
            label.delete(array.get(eventLabels, i))
        array.clear(eventLabels)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table pnl = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFontSize = ""
var bool lastProofMode = false

scoreText = str.tostring(locationScore) + " / " + locationGrade
roomText = f_fmt_1(targetRoomAtr) + " ATR"
riskText = riskState + " / " + f_fmt_1(riskDistanceAtr) + " ATR"
atrText = volText + " / " + f_fmt_1(volRatio) + "x"
contextPanelText = contextShort + " / " + contextState
rangePanelText = f_range_pos_text(rangePos) + " range"

proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
followText = proofTotal > 0 ? f_pct(followRate) : "-"
holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
followCol = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelTheme)
holdCol = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelTheme)
reactCol = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelTheme)
flipCol = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelTheme)

int panelRowCount = showProof ? 12 : 7

if barstate.islast
    if showPanel
        if na(pnl) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme or panelFontSize != lastPanelFontSize or showProof != lastProofMode
            if not na(pnl)
                table.delete(pnl)
            pnl := table.new(f_panel_pos(panelLocation), 2, panelRowCount, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
            table.cell(pnl, 0, 0, "AG Pro Trade Location Quality", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
            table.cell(pnl, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
            table.merge_cells(pnl, 0, 0, 1, 0)
            lastPanelLocation := panelLocation
            lastPanelTheme := panelTheme
            lastPanelFontSize := panelFontSize
            lastProofMode := showProof
        table.clear(pnl, 0, 1, 1, panelRowCount - 1)
        table.cell(pnl, 0, 0, "AG Pro Trade Location Quality", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(pnl, 1, "Workflow", reviewText, stateColor, panelTheme, panelFontSize)
        f_panel_row(pnl, 2, "Location Context", contextPanelText, stateColor, panelTheme, panelFontSize)
        f_panel_row(pnl, 3, "Quality Score", scoreText, f_score_color(locationScore, usedCleanScore, usedWatchScore), panelTheme, panelFontSize)
        f_panel_row(pnl, 4, "Room / Range", roomText + " / " + rangePanelText, targetRoomAtr >= effectiveMinimumRoomAtr ? bullColor : neutralColor, panelTheme, panelFontSize)
        f_panel_row(pnl, 5, "Risk Distance", riskText, riskState == "Balanced" ? bullColor : dangerColor, panelTheme, panelFontSize)
        f_panel_row(pnl, 6, "ATR Context", atrText, volRatio > 1.90 or volRatio < 0.55 ? neutralColor : accentColor, panelTheme, panelFontSize)
        if showProof
            color proofHeadBg = f_row_bg(panelTheme, 7)
            table.cell(pnl, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_text_size(panelFontSize), text_halign = text.align_left)
            table.cell(pnl, 1, 7, proofSampleText, text_color = f_panel_label(panelTheme), bgcolor = proofHeadBg, text_size = f_text_size(panelFontSize), text_halign = text.align_right)
            f_panel_row(pnl, 8, "Follow Rate", followText, followCol, panelTheme, panelFontSize)
            f_panel_row(pnl, 9, "Hold Rate", holdText, holdCol, panelTheme, panelFontSize)
            f_panel_row(pnl, 10, "React Rate", reactText, reactCol, panelTheme, panelFontSize)
            f_panel_row(pnl, 11, "Flip Rate", flipText, flipCol, panelTheme, panelFontSize)
    else if not na(pnl)
        table.delete(pnl)
        pnl := na
        lastPanelLocation := ""
        lastPanelTheme := ""
        lastPanelFontSize := ""

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
newReviewLocation = confirmedBar and engineReady and reviewLocation and not reviewLocation[1]
newObstructedLocation = confirmedBar and engineReady and obstructed and not obstructed[1]
newRiskWarning = confirmedBar and engineReady and (tooCloseRisk or riskTooWide) and not (tooCloseRisk[1] or riskTooWide[1])
newWatchLocation = confirmedBar and engineReady and watchLocation and not reviewLocation and not watchLocation[1]

alertcondition(alertCleanWatch and newReviewLocation, "Trade Location Review", "Trade Location Quality: review-ready location context is active. This is an analytical attention marker, not a trade instruction.")
alertcondition(alertWarnings and newObstructedLocation, "Trade Location Room Check", "Trade Location Quality: price is close to the next obstruction rail. Review target room and broader context.")
alertcondition(alertWarnings and newRiskWarning, "Trade Location Risk Warning", "Trade Location Quality: risk distance is too close or too wide for a balanced location review.")
alertcondition(alertCleanWatch and newWatchLocation, "Trade Location Watch", "Trade Location Quality: watchable location context is active. This is an attention marker, not a trade instruction.")

plot(locationScore, "TLQ Location Score", display = display.none)
plot(targetRoomAtr, "TLQ Target Room ATR", display = display.none)
plot(riskDistanceAtr, "TLQ Risk Distance ATR", display = display.none)
plot(followRate, "TLQ Follow Rate", display = display.none)
plot(holdRate, "TLQ Hold Rate", display = display.none)
plot(reactRate, "TLQ React Rate", display = display.none)
plot(flipRate, "TLQ Flip Rate", display = display.none)
plot(proofAmbiguous, "TLQ Ambiguous Proof Count", display = display.none)
plot(longContext ? 1 : -1, "TLQ Context Direction", display = display.none)
plot(rangePos, "TLQ Range Position", display = display.none)
plot(array.size(pivotHighs) + array.size(pivotLows), "TLQ Active Pivot Count", display = display.none)
````
