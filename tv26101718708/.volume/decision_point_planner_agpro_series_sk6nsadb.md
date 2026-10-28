# Decision Point Planner [AGPro Series]

- url: https://www.tradingview.com/script/Sk6NSAdb-Decision-Point-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;71220453cfdc42eaae0bb107b9e4db73
- version: 5.0

## Description

Decision Point Planner [AGPro Series]

🧠 Core Idea

Is price sitting at a decision point that deserves review, patience, or rejection?


📌 Overview / What it does

Decision Point Planner is a chart-first risk planning tool built to evaluate whether the current price area is meaningful enough to deserve attention.

The script maps one active decision point from structure shelf, balance edge, or trend backbone context, then scores the area using location quality, reaction candle behavior, volume support, trend context, available room, and invalidation distance. The output is a 0-100 Decision Score, a clear next-action state, a decision zone, an invalidation shelf, a target-room corridor, compact labels, alerts, and a premium AGPro panel.

It does not predict price direction, automate execution, or print direct buy/sell signals.


🎯 Purpose & Design Philosophy

This script was built for traders who want to know whether the chart is actually at a meaningful decision area or simply moving through noise.

Many tools show levels, zones, or signals in isolation. Decision Point Planner focuses on a narrower planning question: if price is near a decision reference, is the reaction strong enough, is risk still balanced, and is there enough room before the next obstacle?

The design supports a patient planning mindset: identify the point, read the reaction, check room and invalidation, then decide what deserves attention.


⚡ Why This Script Is Different

Most tools focus on plotting many support/resistance levels or marking every reaction.

This script does NOT create a generic S/R map, order-block scanner, FVG map, or prediction engine.

Instead, it selects one active decision reference and turns it into a planning workflow: Decision Score, Zone Type, Reaction State, Room/Risk, and Next Action.


⚙️ Methodology

1. Context Detection
The script detects the active planning side automatically using trend context and range location, or the user can force Long Context or Short Context.

2. Reference Mapping
It compares three decision references: the latest structure shelf, the active balance edge, and the trend backbone. The closest relevant reference becomes the active decision point.

3. Reaction Evaluation
It evaluates whether price is touching or approaching the zone, whether the candle shows a valid reaction, whether volume supports the reaction, whether trend context agrees, and whether room and invalidation remain balanced.

4. Visual Output
It displays a decision zone, invalidation shelf, target-room corridor, compact chart labels, alerts, and a clean AGPro panel.


🗺️ How to Read the Chart

Decision Zone = the current area where price is being evaluated as a decision point.

Invalidation Shelf = the reference beyond the zone that marks rejection in this rule set.

Target-Room Corridor = the available forward room toward the nearest obstacle or a minimum room guide.

Labels = compact attention markers showing ACTION, WAIT, PATIENCE, REJECTED, ROOM, or D POINT context.

Colors = teal and pink show active directional context, amber shows caution, indigo shows wait/reaction context, and blue is reserved for the AGPro panel header.

Panel = summarizes Decision Score, Zone Type, Reaction State, Room Risk, and Action.


🚦 Signals & States

• ACTION REVIEW → the decision point has enough score, reaction, room, and risk quality to deserve closer review.

• WAIT REACTION → price is near the decision point, but the reaction is still incomplete.

• PATIENCE → the area is active but quality, room, or risk is not clean enough yet.

• REJECTED → price crossed the invalidation shelf for the active decision point.

• STAND BY → price is not close enough to the active decision reference.


🔔 Alerts Logic

• Decision Point Action Review → triggers when the state enters ACTION REVIEW.

• Decision Point Wait Reaction → triggers when price is near the point but reaction is incomplete.

• Decision Point Patience → triggers when the active point requires patience or broader confirmation.

• Decision Point Room Limited → triggers when the point is active but forward room is limited.

• Decision Point Rejected → triggers when price crosses the active invalidation shelf.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

Decision quality improves when location, reaction candle behavior, volume support, trend context, target room, and invalidation distance align.

The strongest read appears when price is near the decision zone, the reaction candle is efficient, volume is supportive, trend context agrees, room is open, and risk distance is balanced.


📊 When to Use

• Around pullbacks where price is near a meaningful planning reference.

• During breakout or continuation preparation when the next reaction matters.

• Near range edges or balance transitions where patience is required.

• When comparing whether a setup deserves review or should remain on watch.

• On liquid markets where ATR, volume, and recent structure are meaningful.


⚠️ When NOT to Use

• Extremely low-liquidity markets with unreliable volume and candles.

• Highly noisy micro-timeframes where decision references change too frequently.

• News-driven volatility spikes where ATR and candle ranges expand abnormally.

• Charts where the user expects automatic buy/sell signals.

• As a standalone reason to enter or exit a trade.


🎛️ Key Inputs

• Planning Side → selects Auto, Long Context, or Short Context.

• Decision Range Lookback → defines the planning range and target-room obstacle.

• Structure Shelf Pivot Length → controls how strict the structure shelf reference is.

• Decision Reach ATR → controls how close price must be to the active point before review.

• Decision Zone Half-Width ATR → controls the vertical size of the decision zone.

• Target Room and Invalidation Inputs → define room quality and balanced risk distance.

• Visual Settings → control zones, shelves, corridor, labels, panel location, panel theme, and font sizes.


🖥️ Interface & Visual Design

The interface is intentionally chart-first.

The script uses one active decision zone, one invalidation shelf, and one target-room corridor instead of filling the chart with many competing zones. Labels are compact, offset away from candles, and controlled with cooldown and maximum-visible settings.

The panel follows the AGPro publication layout with a single merged blue title row, adjustable location, adjustable theme, and adjustable font size.


🧪 Practical Usage Workflow

1. Read the panel state and Decision Score.

2. Check the active decision zone and zone type.

3. Evaluate the reaction label and candle behavior.

4. Compare target-room corridor and invalidation shelf.

5. Treat alerts as review markers and confirm the broader market context.


🔍 Interpretation Guidelines

A higher Decision Score means the active decision point has stronger alignment inside the script's rule set. It does not mean price must move in the planned direction.

ACTION REVIEW means the area deserves attention, not automatic execution.

WAIT REACTION means the location may be important but the reaction is not complete.

REJECTED means the active invalidation shelf was crossed in this rule set.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a buy/sell signal service.

• Not a generic support/resistance zone map.

• Not an order-block or FVG scanner.


⚠️ Limitations & Transparency

Decision quality depends on the selected lookback, pivot length, ATR behavior, volume reliability, and timeframe.

Different markets can produce different reference behavior. High volatility can widen invalidation distance. Low volatility can compress target room. Small timeframes may produce more frequent state changes.

The script is rule-based and should be interpreted as an analytical planning layer inside broader market context.


🧠 Market Context Notes

A decision point is useful only when it connects location, reaction, risk, and room.

The same visual area can be weak if reaction is poor, volume is absent, target room is blocked, or invalidation is too tight or too wide.

This script organizes those checks into one readable decision layer.


🧾 Use Case Examples

When price pulls back toward the decision zone and the panel moves from WAIT REACTION to ACTION REVIEW, the area may deserve closer review.

When price touches the zone but the panel shows Room Limited, the user can recognize that the nearby path is obstructed.

When price crosses the invalidation shelf, the script marks the active decision point as rejected inside its rule set.


🧱 System Philosophy

Decision Point Planner follows the AGPro decision-engine approach:

Context first.
Risk before reaction.
Room before confidence.
Attention markers instead of promises.


🔐 Non-Promise Statement

No script can guarantee direction, continuation, reversal, or outcome.

This tool provides structured chart context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk controls, position sizing, and trading decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use the script to study how decision quality changes as price moves closer to or away from active planning references.

The most useful reading comes from comparing the panel state with visible price reaction, room, and invalidation context.

## Source Code

````pine
// -------------------------------------------------
// Decision Point Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Decision Point Planner is a chart-first risk planning overlay that evaluates
// whether price is sitting at a meaningful decision point that deserves review,
// patience, rejection, or no action. It combines location quality, reaction
// candle behavior, volume support, trend context, target room, invalidation
// distance, and next-action guidance without becoming a generic support/
// resistance map or a buy/sell signal printer. Version 1.4 adds a confirmation-
// anchored proof layer (Follow, Hold, React, Flip rates) showing how often the
// planned side held its invalidation and advanced toward room.
// -------------------------------------------------

//@version=6
indicator("Decision Point Planner [AGPro Series]",
     shorttitle       = "AG Pro DPP",
     overlay          = true,
     max_labels_count = 190,
     max_boxes_count  = 40,
     max_lines_count  = 80)

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
ttSide = "Selects the planning side. Auto follows trend context and range location. Manual modes force long-side or short-side decision-point evaluation."
ttConfirm = "When enabled, labels, alerts, and state transitions are confirmed only after the bar closes. This keeps public chart behavior stable."
ttLookback = "Lookback used to define the active planning range, range edge, and target-room obstacle."
ttPivot = "Pivot length used to locate the most recent structure shelf. The script evaluates one active decision point, not a full support/resistance map."
ttAtr = "ATR length used to normalize decision-zone distance, invalidation distance, target room, and label offsets."
ttAtrBase = "Longer ATR baseline used to classify volatility context and penalize overheated decision points."
ttFast = "Fast EMA used only for automatic side selection and trend context. It does not generate entries."
ttSlow = "Slow EMA used as the trend backbone and as one possible decision reference."
ttVolume = "Volume average used to determine whether a reaction candle has participation support. If volume is unavailable, the script remains conservative."
ttZoneReach = "Maximum ATR-normalized distance from the active decision point where the chart is considered close enough for review."
ttZoneWidth = "Vertical half-width of the decision zone in ATR terms. Wider zones tolerate more price noise around the reference."
ttMinRoom = "Minimum ATR-normalized room required before the target-room corridor is considered open."
ttStrongRoom = "Target-room value that maps to a strong room score. Higher values require more open space before the next obstacle."
ttMinRisk = "Minimum acceptable ATR-normalized distance to invalidation. If risk is too tight, the point is vulnerable to normal noise."
ttIdealRisk = "Preferred ATR-normalized distance to invalidation. Decision quality is strongest around this balanced area."
ttMaxRisk = "Maximum acceptable ATR-normalized distance to invalidation. If risk is too wide, the point becomes less efficient."
ttBody = "Minimum candle body efficiency required for a stronger reaction read at the decision point."
ttVolRatio = "Minimum volume ratio required for a reaction to be marked as volume-supported."
ttAction = "Minimum 0-100 score required for REVIEW POINT state. This is an attention state, not a trade instruction."
ttWatch = "Minimum 0-100 score required for WAIT REACTION state while price is near the decision point."
ttDecisionZone = "Shows the active decision zone only around the selected decision reference. The centered badge summarizes state and score."
ttInvalidation = "Shows the invalidation shelf beyond the decision zone. It is a planning reference, not a stop recommendation."
ttCorridor = "Shows the forward target-room corridor toward the nearest obstacle or projected room guide. The centered badge summarizes room quality."
ttProjection = "Number of bars projected to the right for the decision zone, invalidation shelf, and target-room corridor."
ttZoneOpacity = "Transparency for decision and corridor boxes. Higher values make the zones lighter."
ttGuideTags = "Shows right-edge tags for invalidation and target-room references. Disable it when the decision zone and panel already provide enough context."
ttGuideOffset = "Moves guide tags to the right while extending their reference lines and corridor to the same x-position, keeping tags attached to real levels."
ttLabels = "Shows compact REVIEW, WAIT, PATIENCE, REJECT, and ROOM labels. Labels are offset away from candles."
ttContext = "Adds sparse context labels even when the state does not change. Disabled by default for a cleaner public-release chart."
ttCooldown = "Minimum bars between event labels. Higher values reduce label density."
ttContextSpacing = "Minimum bars between sparse context labels during ongoing decision-point tracking."
ttMaxLabels = "Maximum number of recent labels retained on the chart. Older labels are removed first to preserve performance."
ttLabelOffset = "ATR-based vertical offset that keeps labels above or below candles."
ttLabelScore = "Adds the 0-100 decision score to chart labels."
ttLabelSize = "Font size for all chart labels, centered zone badges, and corridor badges. Normal is the recommended publication default."
ttMarkers = "Shows small diamond markers in addition to labels. Disabled by default because zones and labels already carry the visual story."
ttShowPanel = "Shows or hides the AG Pro planning panel. The panel is visible by default for publication-ready context."
ttPanelLocation = "Moves the panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended publication default."
ttAlerts = "Enables alert conditions for review, wait, patience, room-limited, and rejected decision states."
ttShowProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across rolling decision-side windows on the current symbol and timeframe. Follow means the planned side advanced one risk unit (1R) toward room, or reached a nearer target, before the invalidation shelf was breached. These are historical outcome rates, not predictions."
ttProofHorizon = "Maximum number of bars each rolling decision-side window is tracked for the proof measurement before it resolves at its current outcome."
ttReactBars = "Number of bars after a window opens used to detect an immediate favorable reaction."
ttReactProgress = "Minimum favorable progress toward the 1R target, within the reaction window, required to count as an early React."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Decision Point Engine"
sideMode = input.string("Auto", "Planning Side", options = ["Auto", "Long Context", "Short Context"], group = groupEngine, tooltip = ttSide)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group = groupEngine, tooltip = ttConfirm)
decisionLookback = input.int(72, "Decision Range Lookback", minval = 20, maxval = 300, group = groupEngine, tooltip = ttLookback)
pivotLen = input.int(5, "Structure Shelf Pivot Length", minval = 2, maxval = 25, group = groupEngine, tooltip = ttPivot)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = ttAtr)
atrBaseLen = input.int(55, "ATR Context Baseline", minval = 10, maxval = 300, group = groupEngine, tooltip = ttAtrBase)
fastEmaLen = input.int(21, "Fast Context EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLen = input.int(55, "Trend Backbone EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlow)
volumeLen = input.int(20, "Volume Support Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolume)

groupScoring = "Decision Scoring"
decisionReachAtr = input.float(0.85, "Decision Reach ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttZoneReach)
zoneHalfWidthAtr = input.float(0.32, "Decision Zone Half-Width ATR", minval = 0.05, maxval = 2.00, step = 0.01, group = groupScoring, tooltip = ttZoneWidth)
minimumRoomAtr = input.float(1.35, "Minimum Target Room ATR", minval = 0.20, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttMinRoom)
strongRoomAtr = input.float(3.25, "Strong Target Room ATR", minval = 0.50, maxval = 15.00, step = 0.10, group = groupScoring, tooltip = ttStrongRoom)
minimumRiskAtr = input.float(0.45, "Minimum Invalidation Distance ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttMinRisk)
idealRiskAtr = input.float(1.15, "Ideal Invalidation Distance ATR", minval = 0.10, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttIdealRisk)
maximumRiskAtr = input.float(2.85, "Maximum Invalidation Distance ATR", minval = 0.30, maxval = 12.00, step = 0.05, group = groupScoring, tooltip = ttMaxRisk)
minimumBodyEff = input.float(0.42, "Reaction Body Efficiency", minval = 0.05, maxval = 0.95, step = 0.01, group = groupScoring, tooltip = ttBody)
minimumVolumeRatio = input.float(0.95, "Volume Support Ratio", minval = 0.10, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttVolRatio)
actionThreshold = input.float(74.0, "REVIEW POINT Threshold", minval = 40.0, maxval = 95.0, step = 1.0, group = groupScoring, tooltip = ttAction)
watchThreshold = input.float(56.0, "WAIT REACTION Threshold", minval = 25.0, maxval = 90.0, step = 1.0, group = groupScoring, tooltip = ttWatch)

groupVisual = "Chart Visuals"
showDecisionZone = input.bool(true, "Show Decision Zone", group = groupVisual, tooltip = ttDecisionZone)
showInvalidationShelf = input.bool(true, "Show Invalidation Shelf", group = groupVisual, tooltip = ttInvalidation)
showTargetCorridor = input.bool(true, "Show Target-Room Corridor", group = groupVisual, tooltip = ttCorridor)
showGuideTags = input.bool(true, "Show Guide Tags", group = groupVisual, tooltip = ttGuideTags)
guideTagOffsetBars = input.int(8, "Guide Tag Offset Bars", minval = 0, maxval = 80, group = groupVisual, tooltip = ttGuideOffset)
projectionBars = input.int(40, "Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = ttProjection)
zoneTransparency = input.int(90, "Zone Transparency", minval = 70, maxval = 96, group = groupVisual, tooltip = ttZoneOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContext)
showEventMarkers = input.bool(false, "Show Event Markers", group = groupLabels, tooltip = ttMarkers)
labelCooldownBars = input.int(30, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(96, "Context Label Spacing", minval = 8, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(8, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttShowProof)
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = ttProofHorizon)
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof, tooltip = ttReactProgress)

groupAlerts = "Alerts"
alertDecisionStates = input.bool(true, "Alert on Decision States", group = groupAlerts, tooltip = ttAlerts)

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

f_score_color(int score) =>
    score >= 78 ? bullColor : score >= 62 ? accentColor : score >= 46 ? neutralColor : bearColor

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_state_color(string stateText) =>
    switch stateText
        "REVIEW POINT" => bullColor
        "WAIT REACTION" => accentColor
        "STAY PATIENT" => neutralColor
        "POINT REJECTED" => bearColor
        "STAND BY" => panelLabelCol
        => panelValueCol

f_badge_text(string stateText, int score) =>
    stateText == "REVIEW POINT" ? "REVIEW " + str.tostring(score) : stateText == "WAIT REACTION" ? "WAIT " + str.tostring(score) : stateText == "STAY PATIENT" ? "PATIENCE " + str.tostring(score) : stateText == "POINT REJECTED" ? "REJECT " + str.tostring(score) : "STAND " + str.tostring(score)

f_room_badge(bool roomOk, float roomAtr) =>
    (roomOk ? "ROOM " : "LIMIT ") + str.tostring(roomAtr, "#.0")

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

f_best_view_text(string stateText, bool roomOk, string riskState, string reactionText) =>
    string view = "Stand by"
    if stateText == "REVIEW POINT"
        view := roomOk and riskState == "Balanced" ? "Review context" : "Check risk"
    else if stateText == "WAIT REACTION"
        view := "Wait candle"
    else if stateText == "STAY PATIENT"
        view := "Let point develop"
    else if stateText == "POINT REJECTED"
        view := "Point failed"
    reactionText == "Accepted" and not roomOk ? "Room caution" : view

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float atrBase = ta.sma(atr, atrBaseLen)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? atr / atrBase : 1.0

float fastEma = ta.ema(close, fastEmaLen)
float slowEma = ta.ema(close, slowEmaLen)
float rangeHigh = nz(ta.highest(high, decisionLookback), high)
float rangeLow = nz(ta.lowest(low, decisionLookback), low)
float rangeSpan = math.max(rangeHigh - rangeLow, safeAtr)
float rangeMid = rangeLow + rangeSpan * 0.50
float rangePosition = f_clamp((close - rangeLow) / rangeSpan, 0.0, 1.0)

float pivotHighRaw = ta.pivothigh(high, pivotLen, pivotLen)
float pivotLowRaw = ta.pivotlow(low, pivotLen, pivotLen)
float lastPivotHigh = nz(ta.valuewhen(not na(pivotHighRaw), pivotHighRaw, 0), rangeHigh)
float lastPivotLow = nz(ta.valuewhen(not na(pivotLowRaw), pivotLowRaw, 0), rangeLow)

bool trendBull = fastEma >= slowEma and close >= slowEma
bool trendBear = fastEma <= slowEma and close <= slowEma
var int planningDir = 1
int autoDir = trendBull ? 1 : trendBear ? -1 : nz(planningDir[1], close >= rangeMid ? 1 : -1)
planningDir := sideMode == "Long Context" ? 1 : sideMode == "Short Context" ? -1 : autoDir

string sideText = planningDir == 1 ? "Long" : "Short"
color sideColor = planningDir == 1 ? bullColor : bearColor

float structureShelf = planningDir == 1 ? lastPivotLow : lastPivotHigh
float balanceEdge = planningDir == 1 ? rangeLow + rangeSpan * 0.382 : rangeHigh - rangeSpan * 0.382
float trendBackbone = slowEma
float shelfDistanceAtr = math.abs(close - structureShelf) / safeAtr
float edgeDistanceAtr = math.abs(close - balanceEdge) / safeAtr
float trendDistanceAtr = math.abs(close - trendBackbone) / safeAtr

float decisionLevel = structureShelf
float bestDistanceAtr = shelfDistanceAtr
string zoneType = "Structure Shelf"

if edgeDistanceAtr < bestDistanceAtr
    decisionLevel := balanceEdge
    bestDistanceAtr := edgeDistanceAtr
    zoneType := "Balance Edge"

if trendDistanceAtr < bestDistanceAtr
    decisionLevel := trendBackbone
    bestDistanceAtr := trendDistanceAtr
    zoneType := "Trend Backbone"

float zoneHalf = safeAtr * zoneHalfWidthAtr
float zoneTop = decisionLevel + zoneHalf
float zoneBottom = decisionLevel - zoneHalf
bool touchedZone = low <= zoneTop and high >= zoneBottom
bool nearDecision = touchedZone or bestDistanceAtr <= decisionReachAtr

float candleRange = math.max(high - low, syminfo.mintick)
float candleBody = math.abs(close - open)
float bodyEfficiency = candleBody / candleRange
float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)
float lowerWickAtr = math.max(lowerWick, 0.0) / safeAtr
float upperWickAtr = math.max(upperWick, 0.0) / safeAtr

float rawVolume = nz(volume, 0.0)
float averageVolume = nz(ta.sma(volume, volumeLen), rawVolume)
float volumeRatio = averageVolume > 0.0 ? rawVolume / averageVolume : 1.0
bool volumeSupported = volumeRatio >= minimumVolumeRatio

float invalidationLevel = planningDir == 1 ? zoneBottom - safeAtr * 0.18 : zoneTop + safeAtr * 0.18
bool invalidated = planningDir == 1 ? close < invalidationLevel : close > invalidationLevel
float riskDistanceRaw = planningDir == 1 ? close - invalidationLevel : invalidationLevel - close
float riskDistanceAtr = math.max(riskDistanceRaw / safeAtr, 0.0)

float structuralObstacle = planningDir == 1 ? math.max(rangeHigh, lastPivotHigh) : math.min(rangeLow, lastPivotLow)
float roomRaw = planningDir == 1 ? structuralObstacle - close : close - structuralObstacle
float targetRoomAtr = math.max(roomRaw / safeAtr, 0.0)
bool roomOpen = targetRoomAtr >= minimumRoomAtr
float targetGuide = roomRaw > safeAtr * 0.20 ? structuralObstacle : close + planningDir * safeAtr * minimumRoomAtr

bool longReaction = planningDir == 1 and touchedZone and close > decisionLevel and close > open and bodyEfficiency >= minimumBodyEff and lowerWickAtr >= zoneHalfWidthAtr * 0.35
bool shortReaction = planningDir == -1 and touchedZone and close < decisionLevel and close < open and bodyEfficiency >= minimumBodyEff and upperWickAtr >= zoneHalfWidthAtr * 0.35
bool reactionAccepted = not invalidated and (longReaction or shortReaction)
bool softReaction = not invalidated and touchedZone and ((planningDir == 1 and close > decisionLevel) or (planningDir == -1 and close < decisionLevel))

float locationScore = touchedZone ? 100.0 : f_norm_low_good(bestDistanceAtr, 0.0, decisionReachAtr * 1.60)
float reactionScore = reactionAccepted and volumeSupported ? 100.0 : reactionAccepted ? 84.0 : softReaction ? 68.0 : nearDecision ? 48.0 : 18.0
float volumeScore = f_norm_high_good(volumeRatio, 0.60, math.max(minimumVolumeRatio * 1.45, 1.10))
float trendScore = planningDir == 1 ? (trendBull ? 100.0 : close >= slowEma ? 70.0 : 38.0) : (trendBear ? 100.0 : close <= slowEma ? 70.0 : 38.0)
float roomScore = f_norm_high_good(targetRoomAtr, minimumRoomAtr * 0.35, strongRoomAtr)
float riskScore = f_peak_score(riskDistanceAtr, minimumRiskAtr, idealRiskAtr, maximumRiskAtr)
float volatilityScore = atrRatio <= 0.70 ? 72.0 : atrRatio <= 1.35 ? 100.0 : atrRatio <= 1.85 ? 62.0 : 34.0

float decisionScoreRaw = locationScore * 0.25 + reactionScore * 0.23 + volumeScore * 0.13 + trendScore * 0.14 + roomScore * 0.14 + riskScore * 0.07 + volatilityScore * 0.04
decisionScoreRaw := not nearDecision ? math.min(decisionScoreRaw, 55.0) : decisionScoreRaw
decisionScoreRaw := not roomOpen ? math.min(decisionScoreRaw, 70.0) : decisionScoreRaw
decisionScoreRaw := riskDistanceAtr < minimumRiskAtr ? math.min(decisionScoreRaw, 64.0) : decisionScoreRaw
decisionScoreRaw := riskDistanceAtr > maximumRiskAtr ? math.min(decisionScoreRaw, 62.0) : decisionScoreRaw
decisionScoreRaw := invalidated ? math.min(decisionScoreRaw, 28.0) : decisionScoreRaw
int decisionScore = int(math.round(f_clamp(decisionScoreRaw, 0.0, 100.0)))

string reactionState = invalidated ? "Rejected" : reactionAccepted and volumeSupported ? "Accepted" : reactionAccepted ? "Soft Reaction" : touchedZone ? "Testing" : nearDecision ? "Approaching" : "Away"
string riskText = riskDistanceAtr < minimumRiskAtr ? "Tight" : riskDistanceAtr > maximumRiskAtr ? "Wide" : "Balanced"
string roomText = roomOpen ? "Room Open" : "Room Limited"

bool actionReady = decisionScore >= actionThreshold and reactionAccepted and roomOpen and not invalidated
bool waitReaction = decisionScore >= watchThreshold and nearDecision and not reactionAccepted and not invalidated
bool patienceState = nearDecision and not actionReady and not waitReaction and not invalidated
string decisionState = invalidated ? "POINT REJECTED" : actionReady ? "REVIEW POINT" : waitReaction ? "WAIT REACTION" : patienceState ? "STAY PATIENT" : "STAND BY"
string actionText = decisionState == "REVIEW POINT" ? "Review " + sideText : decisionState == "WAIT REACTION" ? "Wait Reaction" : decisionState == "STAY PATIENT" ? "Stay Patient" : decisionState == "POINT REJECTED" ? "Reject Point" : "Stand By"
string bestViewText = f_best_view_text(decisionState, roomOpen, riskText, reactionState)
color stateColor = f_state_color(decisionState)

bool confirmedBar = confirmOnClose ? barstate.isconfirmed : true

// -------------------------------------------------
// Confirmation-anchored proof (rolling decision-side windows, Follow = advanced 1R toward room before invalidation)
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

int proofWarmup = decisionLookback + atrLen + 5
if confirmedBar and bar_index > proofWarmup
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
        if naturalResolve
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
    if not pEvalActive
        pEvalActive := true
        pEvalDir := planningDir
        pEvalEntry := close
        pEvalStop := invalidationLevel
        float pStopDist = math.max(math.abs(close - invalidationLevel), syminfo.mintick)
        float pRoomDist = math.max(math.abs(targetGuide - close), syminfo.mintick)
        float pFollowDist = math.max(math.min(pStopDist, pRoomDist), syminfo.mintick)
        pEvalTarget := close + planningDir * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Chart visuals
// -------------------------------------------------
int rightEdge = bar_index + projectionBars
int guideRightEdge = rightEdge + (showGuideTags ? guideTagOffsetBars : 0)
int zoneLeft = math.max(0, bar_index - math.max(8, pivotLen * 3))
int zoneCenterX = int(math.round((zoneLeft + rightEdge) * 0.5))
float zoneCenterY = (zoneTop + zoneBottom) * 0.5
string zoneText = f_badge_text(decisionState, decisionScore)
color zoneColor = decisionState == "POINT REJECTED" ? bearColor : decisionState == "REVIEW POINT" ? sideColor : decisionState == "WAIT REACTION" ? accentColor : neutralColor
color zoneBadgeText = zoneColor == neutralColor ? darkText : headerText

var box decisionBox = na
var label decisionBadge = na
if showDecisionZone
    if na(decisionBox)
        decisionBox := box.new(left = zoneLeft, top = zoneTop, right = rightEdge, bottom = zoneBottom, xloc = xloc.bar_index, bgcolor = color.new(zoneColor, zoneTransparency), border_color = color.new(zoneColor, 34), border_width = 1)
    else
        box.set_left(decisionBox, zoneLeft)
        box.set_right(decisionBox, rightEdge)
        box.set_top(decisionBox, zoneTop)
        box.set_bottom(decisionBox, zoneBottom)
        box.set_bgcolor(decisionBox, color.new(zoneColor, zoneTransparency))
        box.set_border_color(decisionBox, color.new(zoneColor, 34))
    if na(decisionBadge)
        decisionBadge := label.new(zoneCenterX, zoneCenterY, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(zoneColor, 0), textcolor = zoneBadgeText, size = f_label_size(labelSizeInput))
    else
        label.set_xy(decisionBadge, zoneCenterX, zoneCenterY)
        label.set_text(decisionBadge, zoneText)
        label.set_color(decisionBadge, color.new(zoneColor, 0))
        label.set_textcolor(decisionBadge, zoneBadgeText)
        label.set_size(decisionBadge, f_label_size(labelSizeInput))
        label.set_style(decisionBadge, label.style_label_center)
else
    if not na(decisionBox)
        box.delete(decisionBox)
        decisionBox := na
    if not na(decisionBadge)
        label.delete(decisionBadge)
        decisionBadge := na

var line invalidationLine = na
var label invalidationLabel = na
var label targetGuideLabel = na
if showInvalidationShelf
    color shelfColor = invalidated ? bearColor : color.new(neutralColor, 0)
    string shelfText = "RISK " + str.tostring(riskDistanceAtr, "#.00")
    float shelfTagY = invalidationLevel + (planningDir == 1 ? -safeAtr * 0.26 : safeAtr * 0.26)
    if na(invalidationLine)
        invalidationLine := line.new(bar_index, invalidationLevel, guideRightEdge, invalidationLevel, xloc = xloc.bar_index, color = color.new(shelfColor, 12), width = 1, style = line.style_dashed)
    else
        line.set_xy1(invalidationLine, bar_index, invalidationLevel)
        line.set_xy2(invalidationLine, guideRightEdge, invalidationLevel)
        line.set_color(invalidationLine, color.new(shelfColor, 12))
    if showGuideTags
        if na(invalidationLabel)
            invalidationLabel := label.new(guideRightEdge, shelfTagY, shelfText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(shelfColor, 0), textcolor = shelfColor == neutralColor ? darkText : headerText, size = f_label_size(labelSizeInput))
        else
            label.set_xy(invalidationLabel, guideRightEdge, shelfTagY)
            label.set_text(invalidationLabel, shelfText)
            label.set_color(invalidationLabel, color.new(shelfColor, 0))
            label.set_textcolor(invalidationLabel, shelfColor == neutralColor ? darkText : headerText)
            label.set_size(invalidationLabel, f_label_size(labelSizeInput))
    else
        if not na(invalidationLabel)
            label.delete(invalidationLabel)
            invalidationLabel := na
else
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(invalidationLabel)
        label.delete(invalidationLabel)
        invalidationLabel := na

float corridorTop = math.max(close, targetGuide)
float corridorBottom = math.min(close, targetGuide)
float minCorridorHeight = safeAtr * 0.12
if corridorTop - corridorBottom < minCorridorHeight
    corridorTop += minCorridorHeight * 0.50
    corridorBottom -= minCorridorHeight * 0.50

string corridorText = f_room_badge(roomOpen, targetRoomAtr)
float corridorMid = (corridorTop + corridorBottom) * 0.5
int corridorCenterX = int(math.round((bar_index + rightEdge) * 0.5))
color corridorColor = roomOpen ? color.new(bullColor, 0) : color.new(neutralColor, 0)
color corridorTextColor = roomOpen ? headerText : darkText
var box targetCorridor = na
var label corridorBadge = na
if showTargetCorridor
    if na(targetCorridor)
        targetCorridor := box.new(left = bar_index, top = corridorTop, right = guideRightEdge, bottom = corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(corridorColor, 92), border_color = color.new(corridorColor, 45), border_width = 1)
    else
        box.set_left(targetCorridor, bar_index)
        box.set_right(targetCorridor, guideRightEdge)
        box.set_top(targetCorridor, corridorTop)
        box.set_bottom(targetCorridor, corridorBottom)
        box.set_bgcolor(targetCorridor, color.new(corridorColor, 92))
        box.set_border_color(targetCorridor, color.new(corridorColor, 45))
    if na(corridorBadge)
        corridorBadge := label.new(corridorCenterX, corridorMid, corridorText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(corridorColor, 0), textcolor = corridorTextColor, size = f_label_size(labelSizeInput))
    else
        label.set_xy(corridorBadge, corridorCenterX, corridorMid)
        label.set_text(corridorBadge, corridorText)
        label.set_color(corridorBadge, color.new(corridorColor, 0))
        label.set_textcolor(corridorBadge, corridorTextColor)
        label.set_size(corridorBadge, f_label_size(labelSizeInput))
        label.set_style(corridorBadge, label.style_label_center)
    if showGuideTags
        if na(targetGuideLabel)
            targetGuideLabel := label.new(guideRightEdge, targetGuide, "TARGET\n" + str.tostring(targetRoomAtr, "#.00") + " ATR", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(corridorColor, 0), textcolor = corridorTextColor, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(targetGuideLabel, guideRightEdge, targetGuide)
            label.set_text(targetGuideLabel, "TARGET\n" + str.tostring(targetRoomAtr, "#.00") + " ATR")
            label.set_style(targetGuideLabel, label.style_label_left)
            label.set_color(targetGuideLabel, color.new(corridorColor, 0))
            label.set_textcolor(targetGuideLabel, corridorTextColor)
            label.set_size(targetGuideLabel, f_label_size(labelSizeInput))
    else if not na(targetGuideLabel)
        label.delete(targetGuideLabel)
        targetGuideLabel := na
else
    if not na(targetCorridor)
        box.delete(targetCorridor)
        targetCorridor := na
    if not na(corridorBadge)
        label.delete(corridorBadge)
        corridorBadge := na
    if not na(targetGuideLabel)
        label.delete(targetGuideLabel)
        targetGuideLabel := na

// -------------------------------------------------
// Labels and markers
// -------------------------------------------------
var int lastLabelBar = na
var string lastDecisionState = ""
var array<label> eventLabels = array.new_label()

bool actionEvent = confirmedBar and decisionState == "REVIEW POINT" and lastDecisionState != "REVIEW POINT"
bool waitEvent = confirmedBar and decisionState == "WAIT REACTION" and lastDecisionState != "WAIT REACTION"
bool patienceEvent = confirmedBar and decisionState == "STAY PATIENT" and lastDecisionState != "STAY PATIENT"
bool rejectEvent = confirmedBar and decisionState == "POINT REJECTED" and lastDecisionState != "POINT REJECTED"
bool roomBlockedEvent = confirmedBar and not roomOpen and nearDecision and not invalidated
bool labelCooldownReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars
bool contextReady = na(lastLabelBar) or bar_index - lastLabelBar >= contextSpacingBars
bool drawContext = showContextLabels and contextReady and nearDecision and not actionEvent and not waitEvent and not patienceEvent and not rejectEvent
bool drawEventLabel = showEventLabels and labelCooldownReady and (actionEvent or waitEvent or patienceEvent or rejectEvent or roomBlockedEvent or drawContext)

if drawEventLabel
    string labelHead = rejectEvent ? "REJECT" : actionEvent ? "REVIEW" : waitEvent ? "WAIT" : roomBlockedEvent ? "ROOM" : patienceEvent ? "PATIENCE" : "D POINT"
    string labelText = labelHead
    if showLabelScore and not rejectEvent
        labelText += " " + str.tostring(decisionScore)
    labelText += "\n" + reactionState
    bool drawBelow = planningDir == 1
    float labelY = drawBelow ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    color eventColor = rejectEvent ? bearColor : roomBlockedEvent ? neutralColor : stateColor
    color eventTextColor = eventColor == neutralColor ? darkText : headerText
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, yloc = yloc.price, style = drawBelow ? label.style_label_up : label.style_label_down, color = color.new(eventColor, 0), textcolor = eventTextColor, size = f_label_size(labelSizeInput))
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxVisibleLabels)
    lastLabelBar := bar_index

plotshape(showEventMarkers and actionEvent and planningDir == 1, title = "Long Decision Review Marker", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showEventMarkers and actionEvent and planningDir == -1, title = "Short Decision Review Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showEventMarkers and (waitEvent or patienceEvent or roomBlockedEvent), title = "Decision Patience Marker", style = shape.diamond, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)
plotshape(showEventMarkers and rejectEvent, title = "Decision Rejected Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(decisionScore, title = "Decision Score", color = f_score_color(decisionScore), display = display.data_window)
plot(locationScore, title = "Location Quality", color = accentColor, display = display.data_window)
plot(reactionScore, title = "Reaction Quality", color = sideColor, display = display.data_window)
plot(roomScore, title = "Room Quality", color = roomOpen ? bullColor : neutralColor, display = display.data_window)
plot(riskScore, title = "Invalidation Quality", color = riskText == "Balanced" ? bullColor : neutralColor, display = display.data_window)
plot(targetRoomAtr, title = "Target Room ATR", color = roomOpen ? bullColor : neutralColor, display = display.data_window)
plot(riskDistanceAtr, title = "Invalidation Distance ATR", color = riskText == "Balanced" ? bullColor : neutralColor, display = display.data_window)
plot(followRate, title = "Follow Rate", color = f_rate_color(followRate), display = display.data_window)
plot(holdRate, title = "Hold Rate", color = f_rate_color(holdRate), display = display.data_window)
plot(reactRate, title = "React Rate", color = f_rate_color(reactRate), display = display.data_window)
plot(flipRate, title = "Flip Rate", color = f_flip_color(flipRate), display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
string theme = panelThemeInput
string panelSize = panelFontSizeInput
color dashBg = f_panel_bg(theme)
color frameColor = f_panel_border(theme)
string scoreRead = str.tostring(decisionScore) + " / " + decisionState
string roomRead = roomText + " | " + str.tostring(targetRoomAtr, "#.00") + " ATR"
string riskRead = riskText + " | " + str.tostring(riskDistanceAtr, "#.00") + " ATR"
string actionRead = actionText + " | " + bestViewText

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "-"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "-"
color followColPanel = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(theme)
color holdColPanel = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(theme)
color reactColPanel = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(theme)
color flipColPanel = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(theme)

int panelRowCount = showProof ? 13 : 8
var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelFont = ""
var bool lastPanelVisible = false
var bool lastProofMode = false

bool panelNeedsReset = na(panel) or panelLocationInput != lastPanelLocation or panelThemeInput != lastPanelTheme or panelFontSizeInput != lastPanelFont or showPanel != lastPanelVisible or showProof != lastProofMode
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    if showPanel
        panel := table.new(f_panel_position(panelLocationInput), 2, panelRowCount, bgcolor = dashBg, frame_color = frameColor, frame_width = 1, border_color = frameColor, border_width = 1)
        table.cell(panel, 0, 0, "AG Pro Decision Point Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize))
        table.merge_cells(panel, 0, 0, 1, 0)
    else
        panel := na
    lastPanelLocation := panelLocationInput
    lastPanelTheme := panelThemeInput
    lastPanelFont := panelFontSizeInput
    lastPanelVisible := showPanel
    lastProofMode := showProof

if barstate.islast and showPanel and not na(panel)
    table.clear(panel, 0, 1, 1, panelRowCount - 1)
    table.cell(panel, 0, 0, "AG Pro Decision Point Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelSize), text_halign = text.align_center)
    f_set_row(panel, 1, "Workflow", actionRead, stateColor, theme, panelSize)
    f_set_row(panel, 2, "Decision Score", scoreRead, f_score_color(decisionScore), theme, panelSize)
    f_set_row(panel, 3, "Zone Type", zoneType, zoneColor, theme, panelSize)
    f_set_row(panel, 4, "Reaction", reactionState, reactionAccepted ? bullColor : touchedZone ? accentColor : f_panel_value(theme), theme, panelSize)
    f_set_row(panel, 5, "Target Room", roomRead, roomOpen ? bullColor : neutralColor, theme, panelSize)
    f_set_row(panel, 6, "Invalidation", riskRead, riskText == "Balanced" ? bullColor : neutralColor, theme, panelSize)
    f_set_row(panel, 7, "Review", bestViewText, stateColor, theme, panelSize)
    if showProof
        color proofHeadBg = f_row_bg(theme, 8)
        table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_label_size(panelSize), text_halign = text.align_left)
        table.cell(panel, 1, 8, proofSampleText, text_color = f_panel_label(theme), bgcolor = proofHeadBg, text_size = f_label_size(panelSize), text_halign = text.align_right)
        f_set_row(panel, 9, "Follow Rate", followTextPanel, followColPanel, theme, panelSize)
        f_set_row(panel, 10, "Hold Rate", holdTextPanel, holdColPanel, theme, panelSize)
        f_set_row(panel, 11, "React Rate", reactTextPanel, reactColPanel, theme, panelSize)
        f_set_row(panel, 12, "Flip Rate", flipTextPanel, flipColPanel, theme, panelSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertDecisionStates and actionEvent, title = "Decision Point Review", message = "Decision Point Planner: the active decision point moved into review state. This is an attention marker, not a trade instruction.")
alertcondition(alertDecisionStates and waitEvent, title = "Decision Point Wait Reaction", message = "Decision Point Planner: price is near a decision point, but the reaction is still incomplete.")
alertcondition(alertDecisionStates and patienceEvent, title = "Decision Point Patience", message = "Decision Point Planner: the active decision point requires patience or broader confirmation.")
alertcondition(alertDecisionStates and roomBlockedEvent, title = "Decision Point Room Limited", message = "Decision Point Planner: price is near a decision point, but target-room context is limited.")
alertcondition(alertDecisionStates and rejectEvent, title = "Decision Point Rejected", message = "Decision Point Planner: price crossed the active invalidation shelf for the current decision point.")

if confirmedBar
    lastDecisionState := decisionState
````
