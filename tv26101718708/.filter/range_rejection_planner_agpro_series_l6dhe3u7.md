# Range Rejection Planner [AGPro Series]

- url: https://www.tradingview.com/script/L6DHe3u7-Range-Rejection-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;d9085ded4e4e49a68aa9103f685ddbe9
- version: 4.0

## Description

Range Rejection Planner [AGPro Series]


🧠 Core Idea

Is price rejecting a range edge with enough quality to monitor back toward the midline?


📌 Overview / What it does

Range Rejection Planner is a chart-first range reaction decision engine built to evaluate whether price is rejecting the active range edge with enough structure to deserve attention.

The script maps one relevant range edge, a focused edge-reaction zone, wick rejection behavior, close-back-inside quality, midline room, invalidation shelf, failure risk, event labels, alerts, and a clean AGPro planning panel. These components are converted into a 0-100 Rejection Score and a clear next-action state.

It does not predict price movement, automate trades, draw a full support/resistance library, or guarantee that a range edge will hold. Its purpose is to organize the range-edge rejection review process with practical risk and midline context.


🎯 Purpose & Design Philosophy

This script was built for traders who want to evaluate range-edge reactions without turning the chart into a crowded level map.

Many range tools show boundaries, fills, or breakout markers, but they often stop before answering the practical planning question: did price actually reject the edge, is there room back to the midline, and where does the idea fail?

The design philosophy is simple: a range-edge rejection is only useful when the edge interaction, wick response, close-back-inside behavior, midline room, and failure shelf can be read together.


⚡ Why This Script Is Different

Most tools focus on drawing support/resistance zones, marking every range touch, or highlighting breakouts.

This script does NOT clone Support Resistance Reaction Map, does not build a multi-level S/R inventory, and does not act as a broad breakout or break-retest scanner.

Instead, it focuses on one active range and one active edge. The main output is not a buy/sell signal. It is a planning state that helps users decide whether the edge rejection deserves review, whether midline room exists, and whether failure risk is rising.


⚙️ Methodology

1. Context Detection
The script builds an active range from previous bars and identifies whether price is interacting with the upper or lower edge.

2. Reference Mapping
It maps the relevant edge zone, the range midline, and an invalidation shelf beyond the rejected edge.

3. Reaction Evaluation
The model scores edge proximity, wick rejection, close-back-inside quality, relative volume response, midline room, and active range quality.

4. Visual Output
The result appears as a centered range-edge zone, a midline review path, guide lines, compact state labels, alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Zones = the active range-edge zone shows the relevant upper or lower boundary being evaluated. The zone label is centered inside the shape.

Midline Path = the projected review area between the rejected edge and the range midline. It helps show whether there is enough room for interpretation.

Labels = compact markers show EDGE WATCH, REJECT READY, MIDLINE REVIEW, MIDLINE HIT, or FAILURE RISK context.

Colors = teal supports lower-edge rejection context, pink supports upper-edge rejection context, amber highlights review states, and indigo marks midline references.

Panel = the panel summarizes Range Edge, Rejection Score, Midline Room, Failure Risk, and Action.


🚦 Signals & States

• EDGE WATCH → price is probing a range edge and early rejection conditions are developing.

• REJECT READY → range-edge rejection quality reached the selected score threshold.

• MIDLINE REVIEW → an active rejection context is being monitored toward the range midline.

• MIDLINE HIT → price reached the active range midline after a rejection context.

• FAILURE RISK → price crossed the invalidation shelf beyond the rejected edge.

• RANGE WAIT → a range exists, but the edge interaction is not strong enough yet.


🔔 Alerts Logic

Alerts trigger when the planner enters EDGE WATCH, REJECT READY, MIDLINE REVIEW, MIDLINE HIT, or FAILURE RISK.

Each alert is an attention marker. Alerts are not trade instructions, entry commands, exit commands, or automated strategy rules.


🧩 Confluence Logic

The strongest context appears when several conditions align:

Range edge probe + strong rejection wick + close back inside the range + supportive relative volume + meaningful room back to the midline + a clear invalidation shelf.

When these components weaken, the planner can stay in EDGE WATCH, return to RANGE WAIT, or shift into FAILURE RISK.


📊 When to Use

• During range-bound markets where edge reactions matter

• When price probes the upper or lower boundary of a recent range

• When evaluating whether an edge rejection has enough midline room

• When a trader wants risk and invalidation context around a range reaction

• On liquid symbols where wicks, volume, and range boundaries are readable


⚠️ When NOT to Use

• Extremely low-liquidity symbols with unreliable wicks or volume

• Very noisy micro-timeframes where range edges shift too often

• News-driven volatility spikes that distort normal range behavior

• Strong trend expansion where range rejection is no longer the main context

• Situations where the user expects automatic buy/sell signals


🎛️ Key Inputs

• Range Edge Mode → chooses Auto, Upper Edge Rejection, or Lower Edge Rejection.

• Active Range Lookback → controls the previous-bar range used for edge evaluation.

• Range Edge Zone ATR → controls the width of the focused edge-reaction zone.

• Close-Back-Inside ATR → defines how much price should close back inside after probing an edge.

• Invalidation Shelf ATR → controls the failure-risk reference beyond the rejected edge.

• REJECT READY Threshold → sets the minimum 0-100 score for the strongest rejection state.

• Label and Panel Font Size → controls visual readability.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The active edge zone gives the main visual reference. The midline path shows the review area. The invalidation shelf defines where the rejection context becomes weaker. The panel provides a compact decision summary without replacing the chart.

The AGPro panel follows the standard first row format: one merged blue title row containing only the script name.


🧪 Practical Usage Workflow

1. Read the panel state and Rejection Score.

2. Check which range edge is active.

3. Review the wick rejection and close-back-inside context.

4. Compare the midline room with the invalidation shelf.

5. Treat alerts as attention markers, then evaluate broader market context.


🔍 Interpretation Guidelines

Think in terms of rejection quality, not prediction.

A stronger score means multiple range-reaction conditions are aligned. A weaker score means the edge interaction may be early, noisy, too close to the midline, or vulnerable to failure.

Failure Risk does not forecast a breakout. It means the active rejection context has crossed its rule-based failure shelf and should be reviewed.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed signal tool

• Not a generic support/resistance map

• Not a full range breakout scanner


⚠️ Limitations & Transparency

The script is rule-based and depends on recent price, range, wick, volatility, and volume behavior.

Timeframe changes can alter the active range, score, edge zone, midline room, and invalidation shelf. Volatility spikes can temporarily distort range boundaries. Symbols with unreliable volume may produce weaker participation readings.

Outputs should always be interpreted with broader market structure, liquidity conditions, and independent risk planning.


🧠 Market Context Notes

Range-edge rejection is most useful when the market is respecting a bounded structure and still has meaningful space toward the middle of the range.

If price starts expanding beyond the edge, this tool intentionally shifts attention from rejection quality toward failure risk instead of calling continuation or reversal with certainty.


🧾 Use Case Examples

When price probes above the active range high, prints a strong upper wick, closes back inside, and still has clear room toward the midline, the planner may classify the context as REJECT READY.

When price touches the lower edge but closes weakly, lacks wick response, or sits too close to the midline, the planner may remain in EDGE WATCH or RANGE WAIT.

When price crosses the invalidation shelf beyond the rejected edge, the planner marks FAILURE RISK for review.


🧱 System Philosophy

AGPro planning tools are designed to help traders make a decision, not simply see another signal.

This script follows that philosophy by turning range rejection into a practical decision question:

Is the edge interaction valid?
How strong is the rejection?
Where is the midline reference?
Where is the failure shelf?
What should I review now?


🔐 Non-Promise Statement

No script can remove uncertainty.

No state, score, label, zone, line, or alert guarantees a future market outcome.


📉 Risk Disclosure

Trading involves risk. Market conditions can change quickly, and no script can eliminate uncertainty.

Users are responsible for their own analysis, risk management, and decisions.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the planner to study how range edges behave across different markets and timeframes. The most useful reading comes from comparing the edge zone, wick response, midline room, failure shelf, panel state, and broader market context together.

## Source Code

````pine
// -------------------------------------------------
// Range Rejection Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Range Rejection Planner is a chart-first range reaction decision engine
// that evaluates whether price is rejecting the active range edge with enough
// quality to monitor. It maps the current range edge zone, wick rejection,
// close-back-inside behavior, midline room, failure risk, invalidation shelf,
// a 0-100 Rejection Score and a persistent reversion-rate proof layer without
// becoming a generic support/resistance map.
// -------------------------------------------------

//@version=6
indicator("Range Rejection Planner [AGPro Series]",
     shorttitle = "AG Pro RRP",
     overlay = true,
     max_boxes_count = 40,
     max_labels_count = 180,
     max_lines_count = 80,
     max_bars_back = 800)

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
color darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttSide = "Selects which range edge is evaluated. Auto uses the closest active range edge and the cleaner rejection score."
string ttConfirm = "Close Confirmed prints state changes, labels, and alerts only after the bar closes. Live Updating allows the planner to update during the active bar."
string ttRange = "Lookback used to build the active range from previous bars. The current bar is tested against this reference instead of being included inside it."
string ttAtr = "ATR length used for edge zones, rejection normalization, invalidation shelves, label spacing, and room-to-midline calculations."
string ttVol = "Volume average length used to evaluate whether rejection appears with supportive participation. When volume is unavailable, the volume component is neutral."
string ttZone = "ATR width around the active range edge. This creates a focused edge-reaction zone rather than multiple support/resistance zones."
string ttCloseBack = "Minimum ATR distance price should close back inside the range after probing an edge."
string ttInvalid = "ATR buffer beyond the probed range edge used to map the failure-risk shelf."
string ttMinWick = "Minimum wick share preferred for cleaner edge rejection. Higher values require stronger rejection wicks."
string ttMinRoom = "Minimum ATR room from the current close back to the range midline. More room gives the planner a cleaner review path."
string ttWidth = "Maximum ATR-normalized active range width that can still be treated as a useful rejection range."
string ttIdeal = "Ideal ATR-normalized range width used by the range-quality score. Extremely narrow or wide ranges receive weaker scores."
string ttReady = "Minimum 0-100 Rejection Score required for REJECT READY state. It is an attention state, not a trade instruction."
string ttWatch = "Minimum 0-100 Rejection Score required for EDGE WATCH state before a full rejection is confirmed."
string ttWindow = "Number of bars after a rejection where midline room and failure risk remain actively evaluated."
string ttProofWindow = "Bars used to resolve each reversion-rate proof sample after a REJECT READY plan starts."
string ttProofReversion = "How far price must revert from the rejected edge toward the range midline to count as a played-out reversion in the proof, measured as a percentage of the edge-to-midline distance. A win is recorded when price reverts this far before crossing the invalidation shelf."
string ttShowEdge = "Shows the active range-edge zone with centered text. Only the relevant edge is shown to avoid a generic support/resistance map."
string ttShowPath = "Shows the review path from the rejected edge toward the range midline. The label is centered inside the path box."
string ttGuides = "Shows the active edge line, midline target, and invalidation shelf used by the planner."
string ttLabels = "Shows compact REJECT READY, EDGE WATCH, MIDLINE HIT, and FAILURE RISK labels with controlled spacing."
string ttContext = "Adds sparse context labels while a range edge is being watched so the chart remains alive without becoming crowded."
string ttCooldown = "Minimum bars between event labels. Higher values reduce visual density."
string ttContextSpacing = "Minimum bars between sparse context labels during ongoing range-edge review."
string ttMaxLabels = "Maximum number of retained labels. Older labels are deleted first to preserve performance."
string ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles instead of buried inside bars."
string ttLabelScore = "Adds the 0-100 Rejection Score to chart labels. Keeping this off leaves the score in the panel and keeps the chart cleaner."
string ttReviewLabels = "Shows optional MIDLINE REVIEW labels during active plans. Disabled by default because the midline path and panel already show this state."
string ttLabelSize = "Controls all chart labels and centered zone text. Normal is the recommended publication default."
string ttShowPanel = "Shows or hides the AG Pro planning panel. It is visible by default for public-release readability."
string ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark theme and a clean light theme."
string ttPanelFont = "Controls AG Pro panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Range Rejection Engine"
string sideMode = input.string("Auto", "Range Edge Mode", options = ["Auto", "Upper Edge Rejection", "Lower Edge Rejection"], group = groupEngine, tooltip = ttSide)
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)
int rangeLookback = input.int(40, "Active Range Lookback", minval = 12, maxval = 260, group = groupEngine, tooltip = ttRange)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtr)
int volumeLength = input.int(34, "Volume Response Length", minval = 5, maxval = 240, group = groupEngine, tooltip = ttVol)
float edgeZoneAtr = input.float(0.30, "Range Edge Zone ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupEngine, tooltip = ttZone)
float closeBackAtr = input.float(0.12, "Close-Back-Inside ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupEngine, tooltip = ttCloseBack)
float invalidationAtr = input.float(0.34, "Invalidation Shelf ATR", minval = 0.05, maxval = 3.00, step = 0.01, group = groupEngine, tooltip = ttInvalid)

string groupScoring = "Rejection Score Model"
float minimumWickShare = input.float(0.34, "Minimum Rejection Wick Share", minval = 0.05, maxval = 0.90, step = 0.01, group = groupScoring, tooltip = ttMinWick)
float minimumMidlineRoomAtr = input.float(0.85, "Minimum Midline Room ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttMinRoom)
float maximumRangeWidthAtr = input.float(7.50, "Maximum Range Width ATR", minval = 1.50, maxval = 25.00, step = 0.10, group = groupScoring, tooltip = ttWidth)
float idealRangeWidthAtr = input.float(3.20, "Ideal Range Width ATR", minval = 0.80, maxval = 12.00, step = 0.10, group = groupScoring, tooltip = ttIdeal)
int rejectReadyThreshold = input.int(72, "REJECT READY Threshold", minval = 45, maxval = 95, group = groupScoring, tooltip = ttReady)
int edgeWatchThreshold = input.int(55, "EDGE WATCH Threshold", minval = 25, maxval = 90, group = groupScoring, tooltip = ttWatch)
int rejectionReviewBars = input.int(28, "Rejection Review Window", minval = 5, maxval = 160, group = groupScoring, tooltip = ttWindow)

string groupProof = "Confirm-Rate Proof"
int proofWindow = input.int(20, "Proof Window Bars", minval = 4, maxval = 160, group = groupProof, tooltip = ttProofWindow)
float proofReversionPct = input.float(50.0, "Proof Reversion To Mid %", minval = 20.0, maxval = 90.0, step = 5.0, group = groupProof, tooltip = ttProofReversion)

string groupVisual = "Chart Visuals"
bool showEdgeZone = input.bool(true, "Show Range Edge Zone", group = groupVisual, tooltip = ttShowEdge)
bool showMidlinePath = input.bool(true, "Show Midline Review Path", group = groupVisual, tooltip = ttShowPath)
bool showPlanningGuides = input.bool(true, "Show Midline / Invalidation Guides", group = groupVisual, tooltip = ttGuides)
int projectionBars = input.int(38, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = "Controls how far the active edge zone, midline path, and guide lines extend to the right.")
int zoneTransparency = input.int(87, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = "Transparency for edge zones and midline path. Higher values create lighter visuals.")

string groupLabels = "Labels"
bool showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
bool showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
bool showReviewLabels = input.bool(false, "Show Review Labels", group = groupLabels, tooltip = ttReviewLabels)
int labelCooldownBars = input.int(14, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
int contextSpacingBars = input.int(38, "Context Label Spacing", minval = 6, maxval = 220, group = groupLabels, tooltip = ttContextSpacing)
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 12, group = groupLabels, tooltip = ttMaxLabels)
float labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
bool showLabelScore = input.bool(false, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
    result

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_text_size(string sizeText) =>
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

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    if theme == "Clean Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_state_color(string stateText, int side) =>
    switch stateText
        "REJECT READY" => side == 1 ? bullColor : bearColor
        "EDGE WATCH" => accentColor
        "MIDLINE REVIEW" => neutralColor
        "MIDLINE HIT" => bullColor
        "FAILURE RISK" => bearColor
        "RANGE WAIT" => panelLabelCol
        => panelValueCol

f_score_grade(int scoreValue) =>
    scoreValue >= 85 ? "A+" : scoreValue >= 76 ? "A" : scoreValue >= 66 ? "B" : scoreValue >= 55 ? "C" : scoreValue >= 42 ? "D" : "E"

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_badge_set(label id, int xValue, float yValue, string textValue, color bgValue, string sizeValue) =>
    label result = id
    if na(result)
        result := label.new(x = xValue, y = yValue, text = textValue, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bgValue, 0), textcolor = f_text_on(bgValue), size = f_text_size(sizeValue), textalign = text.align_center)
    else
        label.set_x(result, xValue)
        label.set_y(result, yValue)
        label.set_text(result, textValue)
        label.set_color(result, color.new(bgValue, 0))
        label.set_textcolor(result, f_text_on(bgValue))
        label.set_size(result, f_text_size(sizeValue))
    result

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
bool confirmedBar = confirmationMode == "Live Updating" or barstate.isconfirmed
float atrRaw = ta.atr(atrLength)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float activeHigh = ta.highest(high[1], rangeLookback)
float activeLow = ta.lowest(low[1], rangeLookback)
bool hasRange = not na(activeHigh) and not na(activeLow) and activeHigh > activeLow and bar_index > rangeLookback
float activeWidth = hasRange ? activeHigh - activeLow : na
float activeMid = hasRange ? (activeHigh + activeLow) * 0.5 : na
float activeWidthAtr = hasRange ? activeWidth / safeAtr : na
float edgeZoneWidth = safeAtr * edgeZoneAtr
float invalidationWidth = safeAtr * invalidationAtr

float candleRange = math.max(high - low, syminfo.mintick)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickShare = upperWick / candleRange
float lowerWickShare = lowerWick / candleRange
float volumeAverage = ta.sma(volume, volumeLength)
bool volumeReady = not na(volumeAverage) and volumeAverage > 0.0 and not na(volume)
float relativeVolume = volumeReady ? volume / volumeAverage : na
float volumeScore = volumeReady ? f_norm_high_good(relativeVolume, 0.70, 1.45) : 55.0

float rangeQualityScore = hasRange ? f_peak_score(activeWidthAtr, 1.00, idealRangeWidthAtr, maximumRangeWidthAtr) : 0.0
bool matureRange = hasRange and activeWidthAtr <= maximumRangeWidthAtr and rangeQualityScore >= 20.0
float rangePosition = hasRange ? f_clamp((close - activeLow) / activeWidth, 0.0, 1.0) : na

bool upperAllowed = sideMode == "Auto" or sideMode == "Upper Edge Rejection"
bool lowerAllowed = sideMode == "Auto" or sideMode == "Lower Edge Rejection"
bool upperEdgeTouched = matureRange and upperAllowed and high >= activeHigh - edgeZoneWidth
bool lowerEdgeTouched = matureRange and lowerAllowed and low <= activeLow + edgeZoneWidth
float upperCloseBackAtr = matureRange ? (activeHigh - close) / safeAtr : 0.0
float lowerCloseBackAtr = matureRange ? (close - activeLow) / safeAtr : 0.0
float upperMidlineRoomAtr = matureRange ? math.max(close - activeMid, 0.0) / safeAtr : 0.0
float lowerMidlineRoomAtr = matureRange ? math.max(activeMid - close, 0.0) / safeAtr : 0.0
float upperEdgeDistanceAtr = matureRange ? math.abs(high - activeHigh) / safeAtr : 10.0
float lowerEdgeDistanceAtr = matureRange ? math.abs(low - activeLow) / safeAtr : 10.0

float upperEdgeScore = upperEdgeTouched ? f_norm_low_good(upperEdgeDistanceAtr, 0.0, edgeZoneAtr * 2.0) : 0.0
float lowerEdgeScore = lowerEdgeTouched ? f_norm_low_good(lowerEdgeDistanceAtr, 0.0, edgeZoneAtr * 2.0) : 0.0
float upperWickScore = f_norm_high_good(upperWickShare, minimumWickShare * 0.65, minimumWickShare * 1.55)
float lowerWickScore = f_norm_high_good(lowerWickShare, minimumWickShare * 0.65, minimumWickShare * 1.55)
float upperCloseBackScore = f_norm_high_good(upperCloseBackAtr, closeBackAtr * 0.50, math.max(closeBackAtr * 2.20, 0.25))
float lowerCloseBackScore = f_norm_high_good(lowerCloseBackAtr, closeBackAtr * 0.50, math.max(closeBackAtr * 2.20, 0.25))
float upperRoomScore = f_norm_high_good(upperMidlineRoomAtr, minimumMidlineRoomAtr * 0.35, minimumMidlineRoomAtr * 1.45)
float lowerRoomScore = f_norm_high_good(lowerMidlineRoomAtr, minimumMidlineRoomAtr * 0.35, minimumMidlineRoomAtr * 1.45)
float upperScoreRaw = upperEdgeScore * 0.15 + upperWickScore * 0.24 + upperCloseBackScore * 0.25 + volumeScore * 0.14 + upperRoomScore * 0.17 + rangeQualityScore * 0.05
float lowerScoreRaw = lowerEdgeScore * 0.15 + lowerWickScore * 0.24 + lowerCloseBackScore * 0.25 + volumeScore * 0.14 + lowerRoomScore * 0.17 + rangeQualityScore * 0.05
int upperScore = int(math.round(f_clamp(upperScoreRaw, 0.0, 100.0)))
int lowerScore = int(math.round(f_clamp(lowerScoreRaw, 0.0, 100.0)))

bool upperCloseBackValid = upperCloseBackAtr >= closeBackAtr and close < activeHigh
bool lowerCloseBackValid = lowerCloseBackAtr >= closeBackAtr and close > activeLow
bool upperWickValid = upperWickShare >= minimumWickShare * 0.80
bool lowerWickValid = lowerWickShare >= minimumWickShare * 0.80
bool upperCandidate = upperEdgeTouched and upperCloseBackValid and upperWickValid and upperMidlineRoomAtr >= minimumMidlineRoomAtr * 0.35
bool lowerCandidate = lowerEdgeTouched and lowerCloseBackValid and lowerWickValid and lowerMidlineRoomAtr >= minimumMidlineRoomAtr * 0.35

int candidateSide = 0
int candidateScore = 0
if sideMode == "Upper Edge Rejection" and upperCandidate
    candidateSide := -1
    candidateScore := upperScore
else if sideMode == "Lower Edge Rejection" and lowerCandidate
    candidateSide := 1
    candidateScore := lowerScore
else if upperCandidate or lowerCandidate
    if upperScore >= lowerScore and upperCandidate
        candidateSide := -1
        candidateScore := upperScore
    else if lowerCandidate
        candidateSide := 1
        candidateScore := lowerScore

bool hasCandidate = candidateSide != 0
float candidateEdge = candidateSide == -1 ? activeHigh : candidateSide == 1 ? activeLow : na
float candidateInvalidation = candidateSide == -1 ? activeHigh + invalidationWidth : candidateSide == 1 ? activeLow - invalidationWidth : na
float candidateMidlineRoomAtr = candidateSide == -1 ? upperMidlineRoomAtr : candidateSide == 1 ? lowerMidlineRoomAtr : 0.0
bool candidateFailure = candidateSide == -1 ? close > candidateInvalidation : candidateSide == 1 ? close < candidateInvalidation : false

// -------------------------------------------------
// Rejection plan state
// -------------------------------------------------
var int planSide = 0
var int planStartBar = na
var float planEdge = na
var float planMidline = na
var float planInvalidation = na
var int planScore = 0
var bool planMidlineDone = false
var bool planFailed = false
var int lastEventBar = na
var int lastContextBar = na
var array<label> eventLabels = array.new<label>()
var int lastUpperVisualBar = na
var int lastLowerVisualBar = na
var label lastUpperVisualLabel = na
var label lastLowerVisualLabel = na

bool canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
bool newRejectEvent = confirmedBar and hasCandidate and candidateScore >= rejectReadyThreshold and not candidateFailure and canPrintEvent
if newRejectEvent
    planSide := candidateSide
    planStartBar := bar_index
    planEdge := candidateEdge
    planMidline := activeMid
    planInvalidation := candidateInvalidation
    planScore := candidateScore
    planMidlineDone := false
    planFailed := false
    lastEventBar := bar_index

bool planExists = planSide != 0 and not na(planStartBar)
int planAge = planExists ? bar_index - planStartBar : 0
bool planExpired = planExists and planAge > rejectionReviewBars
bool activePlan = planExists and not planExpired and not planMidlineDone and not planFailed
bool currentFailure = activePlan and (planSide == -1 ? close > planInvalidation : close < planInvalidation)
bool currentMidlineHit = activePlan and (planSide == -1 ? low <= planMidline : high >= planMidline)

bool failureEvent = confirmedBar and currentFailure and not planFailed
if failureEvent
    planFailed := true
    lastEventBar := bar_index

bool midlineHitEvent = confirmedBar and currentMidlineHit and not planMidlineDone and not failureEvent
if midlineHitEvent
    planMidlineDone := true
    lastEventBar := bar_index

bool edgeWatchEvent = confirmedBar and hasCandidate and candidateScore >= edgeWatchThreshold and candidateScore < rejectReadyThreshold and not candidateFailure and canPrintEvent
if edgeWatchEvent
    lastEventBar := bar_index

bool midlineReviewEvent = showReviewLabels and confirmedBar and activePlan and planAge > 0 and planAge <= rejectionReviewBars and not midlineHitEvent and not failureEvent and canPrintEvent and planScore >= edgeWatchThreshold
if midlineReviewEvent
    lastEventBar := bar_index

bool contextEvent = showContextLabels and confirmedBar and matureRange and (hasCandidate or activePlan or rangePosition > 0.72 or rangePosition < 0.28) and (na(lastContextBar) or bar_index - lastContextBar >= contextSpacingBars)
if contextEvent
    lastContextBar := bar_index

int rangeBiasSide = hasRange and close >= activeMid ? -1 : 1
string stateText = "WAIT"
int stateSide = hasCandidate ? candidateSide : planExists ? planSide : rangeBiasSide
int displayScore = hasCandidate ? candidateScore : planExists ? planScore : 0
if failureEvent or planFailed
    stateText := "FAILURE RISK"
else if midlineHitEvent or planMidlineDone
    stateText := "MIDLINE HIT"
else if newRejectEvent
    stateText := "REJECT READY"
else if edgeWatchEvent or (hasCandidate and candidateScore >= edgeWatchThreshold)
    stateText := "EDGE WATCH"
else if activePlan
    stateText := "MIDLINE REVIEW"
else if matureRange
    stateText := "RANGE WAIT"

color stateColor = f_state_color(stateText, stateSide)
float displayMidline = planExists ? planMidline : activeMid
float displayEdge = planExists ? planEdge : hasCandidate ? candidateEdge : rangeBiasSide == -1 ? activeHigh : activeLow
float displayInvalidation = planExists ? planInvalidation : hasCandidate ? candidateInvalidation : rangeBiasSide == -1 ? activeHigh + invalidationWidth : activeLow - invalidationWidth
float displayRoomAtr = planExists ? (planSide == -1 ? math.max(close - planMidline, 0.0) / safeAtr : math.max(planMidline - close, 0.0) / safeAtr) : candidateMidlineRoomAtr

string failureRiskText = "Low"
color failureRiskColor = bullColor
if stateText == "FAILURE RISK"
    failureRiskText := "High"
    failureRiskColor := bearColor
else if hasCandidate and candidateFailure
    failureRiskText := "High"
    failureRiskColor := bearColor
else if displayRoomAtr < minimumMidlineRoomAtr * 0.55 or displayScore < edgeWatchThreshold
    failureRiskText := "Medium"
    failureRiskColor := neutralColor

string actionText = "Wait"
if stateText == "REJECT READY"
    actionText := "Review Rejection"
else if stateText == "EDGE WATCH"
    actionText := "Watch Edge"
else if stateText == "MIDLINE REVIEW"
    actionText := "Track Midline"
else if stateText == "MIDLINE HIT"
    actionText := "Review Target"
else if stateText == "FAILURE RISK"
    actionText := "Review Failure"
else if stateText == "RANGE WAIT"
    actionText := "Wait for Edge"

// -------------------------------------------------
// Reversion-rate proof
// On a REJECT READY plan, a win is recorded when price reverts the chosen
// percentage of the edge-to-midline distance before crossing the invalidation
// shelf.
// -------------------------------------------------
var bool proofPending = false
var int proofDir = 0
var float proofTarget = na
var float proofInvalid = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

if newRejectEvent and barstate.isconfirmed
    proofPending := true
    proofDir := planSide
    proofTarget := planSide == -1 ? planEdge - (proofReversionPct / 100.0) * (planEdge - planMidline) : planEdge + (proofReversionPct / 100.0) * (planMidline - planEdge)
    proofInvalid := planInvalidation
    proofStartBar := bar_index

if proofPending and barstate.isconfirmed and bar_index > proofStartBar
    bool proofFav = proofDir == -1 ? low <= proofTarget : high >= proofTarget
    bool proofInvHit = proofDir == -1 ? close > proofInvalid : close < proofInvalid
    bool proofExp = bar_index - proofStartBar >= proofWindow
    if proofFav and proofInvHit
        proofTotal += 1
        proofPending := false
    else if proofFav
        proofTotal += 1
        proofWin += 1
        proofPending := false
    else if proofInvHit
        proofTotal += 1
        proofPending := false
    else if proofExp
        proofTotal += 1
        proofPending := false

float reversionRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na
string reversionRateText = na(reversionRate) ? "Building" : str.tostring(math.round(reversionRate)) + "% (" + str.tostring(proofTotal) + ")"
color reversionRateColor = na(reversionRate) ? f_panel_value(panelTheme) : reversionRate >= 55.0 ? bullColor : reversionRate >= 40.0 ? neutralColor : bearColor

// -------------------------------------------------
// Visual objects
// -------------------------------------------------
var box edgeZoneBox = na
var box midlinePathBox = na
var line edgeLine = na
var line midlineLine = na
var line invalidationLine = na
var label edgeBadge = na
var label midlineBadge = na

int visualSide = stateSide == 0 ? 1 : stateSide
color visualColor = visualSide == 1 ? bullColor : bearColor
int leftEdge = math.max(bar_index - math.min(rangeLookback, 220), 0)
int rightEdge = bar_index + projectionBars
bool showActiveVisuals = matureRange and not na(displayEdge) and not na(displayMidline)

if showEdgeZone and showActiveVisuals
    float edgeTop = visualSide == -1 ? activeHigh + edgeZoneWidth : activeLow + edgeZoneWidth
    float edgeBottom = visualSide == -1 ? activeHigh - edgeZoneWidth : activeLow - edgeZoneWidth
    string edgeText = "RANGE EDGE | " + (displayScore > 0 ? str.tostring(displayScore) + " " + f_score_grade(displayScore) : "WATCH")
    float edgeMid = (edgeTop + edgeBottom) * 0.5
    if na(edgeZoneBox)
        edgeZoneBox := box.new(left = leftEdge, top = edgeTop, right = rightEdge, bottom = edgeBottom, xloc = xloc.bar_index, bgcolor = color.new(visualColor, zoneTransparency), border_color = color.new(visualColor, 28), border_width = 1, text = "", text_color = headerText, text_size = f_text_size(labelFontSize), text_halign = text.align_center, text_valign = text.align_center)
    else
        box.set_left(edgeZoneBox, leftEdge)
        box.set_right(edgeZoneBox, rightEdge)
        box.set_top(edgeZoneBox, edgeTop)
        box.set_bottom(edgeZoneBox, edgeBottom)
        box.set_bgcolor(edgeZoneBox, color.new(visualColor, zoneTransparency))
        box.set_border_color(edgeZoneBox, color.new(visualColor, 28))
        box.set_text(edgeZoneBox, "")
        box.set_text_size(edgeZoneBox, f_text_size(labelFontSize))
    int edgeBadgeX = int(math.round((leftEdge + rightEdge) * 0.5))
    edgeBadge := f_badge_set(edgeBadge, edgeBadgeX, edgeMid, edgeText, visualColor, labelFontSize)
else if not na(edgeZoneBox)
    box.delete(edgeZoneBox)
    edgeZoneBox := na
    if not na(edgeBadge)
        label.delete(edgeBadge)
        edgeBadge := na

if showMidlinePath and showActiveVisuals and (activePlan or hasCandidate or stateText == "REJECT READY" or stateText == "EDGE WATCH")
    float pathTop = math.max(displayEdge, displayMidline)
    float pathBottom = math.min(displayEdge, displayMidline)
    int pathLeft = planExists ? planStartBar : bar_index
    if na(midlinePathBox)
        midlinePathBox := box.new(left = pathLeft, top = pathTop, right = rightEdge, bottom = pathBottom, xloc = xloc.bar_index, bgcolor = color.new(visualColor, math.min(zoneTransparency + 5, 96)), border_color = color.new(visualColor, 45), border_width = 1, text = "", text_color = headerText, text_size = f_text_size(labelFontSize), text_halign = text.align_center, text_valign = text.align_center)
    else
        box.set_left(midlinePathBox, pathLeft)
        box.set_right(midlinePathBox, rightEdge)
        box.set_top(midlinePathBox, pathTop)
        box.set_bottom(midlinePathBox, pathBottom)
        box.set_bgcolor(midlinePathBox, color.new(visualColor, math.min(zoneTransparency + 5, 96)))
        box.set_border_color(midlinePathBox, color.new(visualColor, 45))
        box.set_text(midlinePathBox, "")
        box.set_text_size(midlinePathBox, f_text_size(labelFontSize))
    int midlineBadgeX = int(math.round((pathLeft + rightEdge) * 0.5))
    float midlineBadgeY = (pathTop + pathBottom) * 0.5
    string midlineBadgeText = "MIDLINE PATH | " + (not na(displayRoomAtr) ? str.tostring(displayRoomAtr, "#.##") + " ATR" : "REVIEW")
    midlineBadge := f_badge_set(midlineBadge, midlineBadgeX, midlineBadgeY, midlineBadgeText, accentColor, labelFontSize)
else if not na(midlinePathBox)
    box.delete(midlinePathBox)
    midlinePathBox := na
    if not na(midlineBadge)
        label.delete(midlineBadge)
        midlineBadge := na

if showPlanningGuides and showActiveVisuals
    if na(edgeLine)
        edgeLine := line.new(leftEdge, displayEdge, rightEdge, displayEdge, xloc = xloc.bar_index, extend = extend.none, color = color.new(visualColor, 5), width = 2)
    else
        line.set_xy1(edgeLine, leftEdge, displayEdge)
        line.set_xy2(edgeLine, rightEdge, displayEdge)
        line.set_color(edgeLine, color.new(visualColor, 5))
    if na(midlineLine)
        midlineLine := line.new(leftEdge, displayMidline, rightEdge, displayMidline, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 5), width = 1, style = line.style_dotted)
    else
        line.set_xy1(midlineLine, leftEdge, displayMidline)
        line.set_xy2(midlineLine, rightEdge, displayMidline)
        line.set_color(midlineLine, color.new(accentColor, 5))
    if na(invalidationLine)
        invalidationLine := line.new(leftEdge, displayInvalidation, rightEdge, displayInvalidation, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 0), width = 1, style = line.style_dashed)
    else
        line.set_xy1(invalidationLine, leftEdge, displayInvalidation)
        line.set_xy2(invalidationLine, rightEdge, displayInvalidation)
        line.set_color(invalidationLine, color.new(bearColor, 0))
else
    if not na(edgeLine)
        line.delete(edgeLine)
        edgeLine := na
    if not na(midlineLine)
        line.delete(midlineLine)
        midlineLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
if showEventLabels and not (barstate.islast and showActiveVisuals) and (newRejectEvent or edgeWatchEvent or midlineHitEvent or failureEvent or midlineReviewEvent)
    string labelState = newRejectEvent ? "REJECT READY" : edgeWatchEvent ? "EDGE WATCH" : midlineHitEvent ? "MIDLINE HIT" : failureEvent ? "FAILURE RISK" : "MIDLINE REVIEW"
    int labelSide = newRejectEvent or edgeWatchEvent ? candidateSide : planSide
    int labelScore = newRejectEvent or edgeWatchEvent ? candidateScore : planScore
    string labelTitle = newRejectEvent ? "REJECT READY" : edgeWatchEvent ? "EDGE WATCH" : midlineHitEvent ? "MIDLINE HIT" : failureEvent ? "FAILURE RISK" : "MIDLINE REVIEW"
    string labelText = labelTitle + (showLabelScore ? " | Q " + str.tostring(labelScore) + " " + f_score_grade(labelScore) : "")
    float eventOffset = labelOffsetAtr
    if failureEvent
        eventOffset += 0.35
    else if midlineHitEvent
        eventOffset += 0.20
    float labelY = labelSide == 1 ? low - safeAtr * eventOffset : high + safeAtr * eventOffset
    color labelBg = f_state_color(labelState, labelSide)
    bool upperVisualLane = labelSide == -1
    int priorVisualBar = upperVisualLane ? lastUpperVisualBar : lastLowerVisualBar
    label priorVisualLabel = upperVisualLane ? lastUpperVisualLabel : lastLowerVisualLabel
    bool visualCollision = not na(priorVisualBar) and bar_index - priorVisualBar < labelCooldownBars
    bool terminalEvent = failureEvent or midlineHitEvent
    bool printEventLabel = not visualCollision or terminalEvent
    if printEventLabel
        if visualCollision and terminalEvent and not na(priorVisualLabel)
            int priorLabelIndex = array.indexof(eventLabels, priorVisualLabel)
            if priorLabelIndex >= 0
                array.remove(eventLabels, priorLabelIndex)
            label.delete(priorVisualLabel)
        label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(labelBg, 6), textcolor = f_text_on(labelBg), size = f_text_size(labelFontSize))
        array.push(eventLabels, eventLabel)
        if upperVisualLane
            lastUpperVisualBar := bar_index
            lastUpperVisualLabel := eventLabel
        else
            lastLowerVisualBar := bar_index
            lastLowerVisualLabel := eventLabel
        f_trim_labels(eventLabels, maxVisibleLabels)

if contextEvent and not (barstate.islast and showActiveVisuals) and not (newRejectEvent or edgeWatchEvent or midlineHitEvent or failureEvent or midlineReviewEvent)
    int contextSide = rangePosition >= 0.50 ? -1 : 1
    string contextText = (rangePosition >= 0.72 or rangePosition <= 0.28) ? "EDGE WATCH" : "RANGE MIDLINE"
    float contextY = contextSide == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    color contextColor = contextSide == 1 ? bullColor : bearColor
    bool contextUpperLane = contextSide == -1
    int priorContextLaneBar = contextUpperLane ? lastUpperVisualBar : lastLowerVisualBar
    bool contextLaneClear = na(priorContextLaneBar) or bar_index - priorContextLaneBar >= labelCooldownBars
    if contextLaneClear
        label contextLabel = label.new(x = bar_index, y = contextY, text = contextText, xloc = xloc.bar_index, yloc = yloc.price, style = contextSide == 1 ? label.style_label_up : label.style_label_down, color = color.new(contextColor, 35), textcolor = f_text_on(contextColor), size = f_text_size(labelFontSize))
        array.push(eventLabels, contextLabel)
        if contextUpperLane
            lastUpperVisualBar := bar_index
            lastUpperVisualLabel := contextLabel
        else
            lastLowerVisualBar := bar_index
            lastLowerVisualLabel := contextLabel
        f_trim_labels(eventLabels, maxVisibleLabels)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string scoreText = displayScore > 0 ? str.tostring(displayScore) + " / " + f_score_grade(displayScore) : "-"
string edgeTextPanel = stateSide == -1 ? "Upper Edge" : stateSide == 1 ? "Lower Edge" : "-"
string roomText = not na(displayRoomAtr) ? str.tostring(displayRoomAtr, "#.##") + " ATR" : "-"

var table panel = table.new(f_panel_position(panelLocation), 2, 7, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)

if barstate.islast
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.cell(panel, 0, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Range Rejection Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        f_panel_row(panel, 1, "Range Edge", edgeTextPanel, stateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 2, "Rejection Score", scoreText, stateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 3, "Midline Room", roomText, f_panel_value(panelTheme), panelTheme, panelFontSize)
        f_panel_row(panel, 4, "Failure Risk", failureRiskText, failureRiskColor, panelTheme, panelFontSize)
        f_panel_row(panel, 5, "Action", actionText, stateColor, panelTheme, panelFontSize)
        f_panel_row(panel, 6, "Reversion Rate", reversionRateText, reversionRateColor, panelTheme, panelFontSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(barstate.isconfirmed and edgeWatchEvent, title = "Range Edge Watch", message = "Range Rejection Planner: price is probing an active range edge with developing rejection context. This is an attention marker, not a trade instruction.")
alertcondition(barstate.isconfirmed and newRejectEvent, title = "Rejection Ready", message = "Range Rejection Planner: range-edge rejection quality reached REJECT READY state. Review midline room and failure risk.")
alertcondition(barstate.isconfirmed and midlineReviewEvent, title = "Midline Review", message = "Range Rejection Planner: an active range rejection is being monitored toward the midline reference.")
alertcondition(barstate.isconfirmed and midlineHitEvent, title = "Midline Hit", message = "Range Rejection Planner: price reached the active range midline after a rejection context.")
alertcondition(barstate.isconfirmed and failureEvent, title = "Rejection Failure Risk", message = "Range Rejection Planner: price crossed the invalidation shelf for the active rejection context.")
````
