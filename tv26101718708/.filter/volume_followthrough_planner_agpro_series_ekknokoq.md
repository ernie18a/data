# Volume Follow-Through Planner [AGPro Series]

- url: https://www.tradingview.com/script/EKkNOkoQ-Volume-Follow-Through-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;f9154998dc9f4edaaeff8d4d936c6300
- version: 4.0

## Description

Volume Follow-Through Planner [AGPro Series]

🧠 Core Idea

Did high volume create real continuation, or was it only a one-bar event?


📌 Overview / What it does

Volume Follow-Through Planner is a decision-oriented volume analytics overlay built to evaluate what happens after a qualified high-volume candle appears.

Instead of only marking volume spikes, the script opens a follow-through review window, measures next-bar progress, spread quality, close location, trend-side alignment, risk-rail defense, target-room progress, and converts the result into a 0-100 follow-through score.

It produces volume event labels, a forward follow-through box, a centered box label, a risk rail, a target-room guide, continuation/failure state labels, optional target-review labels, alert conditions, and a compact AGPro planning panel. It does not predict future price, automate execution, or claim that a high-volume event must continue.


🎯 Purpose & Design Philosophy

This script was built for traders who want volume to answer a practical planning question: did the event actually create usable continuation context?

Many volume tools stop at detection. They show that volume was high, but they do not explain whether later candles accepted, extended, failed, or faded after the event.

Volume Follow-Through Planner fills that gap by treating volume as the start of a review process, not the final answer. The goal is a cleaner decision layer: event quality, follow-through quality, risk edge, bias context, and next action.


⚡ Why This Script Is Different

Most volume tools focus on identifying spikes, climaxes, absorption, or simple participation changes.

This script does NOT try to clone Volume Climax Detector, Volume Absorption Zones, Breakout Volume Quality, or a generic breakout scanner.

Instead, it focuses on post-event behavior. The volume event must be strong enough to matter, but the main question is what happens next: continuation, weak follow-through, risk building, target review, or failure.


⚙️ Methodology

1. Context Detection

The script measures local relative volume against a rolling volume baseline, normalizes candle spread by ATR, checks body quality, close location, and trend-side alignment.

2. Reference Mapping

When a qualified event appears, the script anchors a follow-through box from the event close toward a target-room guide and places a risk rail beyond the event candle.

3. Reaction Evaluation

During the review window, the planner measures next-bar progress, favorable movement, adverse movement, follow-through closes, rail defense, and time efficiency.

4. Visual Output

The result is converted into a 0-100 follow-through score, chart labels, centered box text, guide lines, panel rows, and alert conditions.


🗺️ How to Read the Chart

Zones = the follow-through box projected from the event close toward the target-room guide.

Labels = volume event, follow-through ready, one-bar event, target review, or failed event states.

Colors = teal for constructive bullish context, pink for constructive bearish context, yellow for caution, and indigo for target/strong review states.

Panel = compact decision summary showing Volume Event, Follow-Through, Spread Quality, Bias, and Action.

Risk rail = the invalidation reference behind the event candle. A confirmed close beyond it marks the active event as failed.


🚦 Signals & States

• Volume Event → a qualified high-volume candle opened a follow-through review.

• FT WATCH → the event is active but still needs more progress.

• FT READY → follow-through quality reached the planner threshold.

• RISK BUILDING → adverse movement is rising while the event is still active.

• ONE-BAR EVENT → volume appeared, but follow-through did not develop enough inside the review window.

• FAILED → price closed beyond the risk rail.

• TARGET REVIEW → the event reached the target-room guide and should be reviewed in context.


🔔 Alerts Logic

Alerts trigger when a qualified volume event appears, when follow-through reaches the ready threshold, when the risk rail is broken, when the target-room guide is reached, and when an event becomes a one-bar event.

Alerts are attention markers. They are not trade instructions, entry rules, or automated execution logic.


🧩 Confluence Logic

The strongest context appears when relative volume, spread quality, close location, next-bar progress, follow-through closes, and trend-side bias align.

When the event has strong participation but weak progress, the planner reduces the follow-through score instead of treating volume alone as enough.


📊 When to Use

• After noticeable participation expansion

• During directional continuation attempts

• Around strong candle events that need confirmation from later bars

• On liquid instruments with reliable volume data

• When the main question is whether volume created continuation or only temporary attention


⚠️ When NOT to Use

• Very low-liquidity symbols

• Charts with unreliable or missing volume data

• Extremely noisy micro timeframes

• Markets where one candle can distort volume baselines

• Conditions where the user needs a full volume profile, absorption zone, or climax detector instead


🎛️ Key Inputs

• Sensitivity → controls how demanding the volume event gate is.

• Volume Lookback → defines the baseline used for relative volume.

• Minimum Planner Score → sets the FT READY threshold.

• Follow-Through Window → controls how many bars are used for early review.

• Risk Rail Buffer → adjusts the invalidation reference behind the event candle.

• Target Guide ATR → controls the projected target-room guide.

• Cooldown Bars → limits repeated events around the same move.

• Visual settings → control labels, optional target-review labels, boxes, guide lines, panel location, panel theme, and font sizes.


🖥️ Interface & Visual Design

The panel is designed as a compact planning cockpit rather than a data dump.

The first row uses the AGPro blue merged header style, while the rows below focus only on the decision fields needed for fast interpretation.

The chart visuals are intentionally moderate: enough labels to make the chart feel active, but controlled by cooldown, maximum visible objects, and spacing settings.


🧪 Practical Usage Workflow

1. Read the panel and check whether a volume event is active.

2. Inspect the follow-through box and risk rail.

3. Watch whether price progresses beyond the event close or fades back toward the rail.

4. Use the Follow-Through score and Action row as context for further review.

5. Confirm the broader market structure, volatility, and liquidity environment separately.


🔍 Interpretation Guidelines

Think of the first volume event as a question, not an answer.

Strong follow-through means the event received continuation support. Weak follow-through means volume did not yet translate into useful directional progress. A failed event means the risk rail was broken and the original event context should be rejected.

The score is a planning aid. It should be interpreted with market structure, higher-timeframe context, and risk controls.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a volume climax detector

• Not an absorption zone map

• Not a generic support/resistance tool


⚠️ Limitations & Transparency

Volume quality depends on the chart symbol and exchange feed.

Timeframe changes can materially alter event frequency, volume baselines, and follow-through behavior.

Extreme volatility can make the risk rail or target-room guide less stable.

The script is rule-based and cannot understand news, liquidation cascades, macro events, or hidden order flow.


🧠 Market Context Notes

High volume is most useful when later candles confirm that participation had directional effect.

If price cannot progress after the event, the volume may represent temporary effort, late participation, absorption-like behavior, or simple noise.

This script focuses on that after-event evaluation.


🧾 Use Case Examples

When a strong bullish volume event appears and later candles close above the event close, the follow-through score can improve toward FT READY.

When a bearish volume event appears but price immediately reclaims the event area and breaks the rail, the state can shift to FAILED.

When volume expands but price stays trapped near the event close, the state can become ONE-BAR EVENT.


🧱 System Philosophy

The AGPro planner style is built around decision quality.

A chart tool should not only show what happened. It should help the user evaluate validity, strength, risk, target room, and the next state to monitor.


🔐 Non-Promise Statement

No script can provide certainty.

No signal, state, score, label, or alert guarantees a future outcome.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, execution, risk management, and decisions.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the planner to study how volume events behave after they appear. The most important information is often not the event itself, but whether later candles confirm, weaken, or invalidate it.

## Source Code

````pine
// -------------------------------------------------
// Volume Follow-Through Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Volume Follow-Through Planner is a decision-oriented volume analytics
// overlay that evaluates whether a qualified high-volume event receives real
// continuation after the first bar. It measures volume multiple, next-bar
// progress, candle spread, close location, trend-side alignment, risk rail
// defense, and target room to produce a 0-100 follow-through score, then
// self-measures how often events actually follow through with a panel hit rate.
// -------------------------------------------------

//@version=6
indicator("Volume Follow-Through Planner [AGPro Series]",
     shorttitle = "AG Pro VFP",
     overlay = true,
     max_boxes_count = 12,
     max_lines_count = 6,
     max_labels_count = 100)

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
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttSensitivity = "Controls how demanding the planner is when registering volume events. Strict requires stronger volume, spread, close location, and body quality."
ttSide = "Selects which side of volume events can open a follow-through review. Auto lets the candle structure decide."
ttConfirm = "Confirmed Close waits for bar close before registering events and alerts. Realtime allows earlier chart feedback while the bar is forming."
ttAtrLen = "ATR length used to normalize spread, follow-through progress, label offsets, target room, and the risk rail."
ttVolumeLen = "Lookback used to calculate the local volume baseline. The event volume multiple is measured against this baseline."
ttFast = "Fast EMA used only for bias context and visual orientation. It does not create trade instructions."
ttSlow = "Slow EMA used for trend-side alignment and panel bias context."
ttSlope = "Number of bars used to judge whether the slow EMA is supporting the event side."
ttMinVolume = "Minimum relative volume required before a bar can become a follow-through event. Sensitivity adjusts this internally."
ttIdealVolume = "Volume multiple where event quality is considered strongest. Very high values above the ceiling are treated as climax-like and excluded."
ttClimaxCeiling = "Maximum relative volume accepted by this planner. This keeps the script focused on follow-through planning instead of cloning a volume climax detector."
ttMinSpread = "Minimum candle range measured in ATR. This avoids treating quiet high-volume bars as directional follow-through events."
ttMinBody = "Minimum body share of the event candle. Higher values require cleaner directional commitment."
ttCloseEdge = "Minimum close location near the event side. Bull events prefer closes near the high; bear events prefer closes near the low."
ttMinEventScore = "Minimum 0-100 event quality required before the planner opens a follow-through window."
ttPlannerScore = "Minimum 0-100 follow-through score required before the panel can mark FT READY."
ttFollowWindow = "Number of bars used for the first follow-through review. Weak progress after this window can become a one-bar event state."
ttTrackBars = "Maximum number of bars an event remains actively tracked by the panel and visual guides."
ttRequiredProgress = "ATR-normalized progress expected during the follow-through review."
ttMinCloses = "Minimum number of closes beyond the event close preferred before the strongest follow-through state can appear."
ttRiskBuffer = "ATR buffer beyond the event candle used to place the risk rail. The rail is an analytical invalidation reference."
ttTargetAtr = "ATR distance used for the follow-through target guide. This is a planning reference, not a promised outcome."
ttAdverseLimit = "ATR-normalized adverse movement where follow-through quality begins to deteriorate."
ttCooldown = "Minimum bars between new volume event windows. Higher values reduce repeated events around the same move."
ttEventMarker = "Shows the compact label on each qualified volume event. Labels are offset away from candles for clearer screenshots."
ttFtBox = "Shows the active follow-through box from the event close toward the target guide. Its label is centered inside the box."
ttRiskRail = "Shows the risk rail beyond the event candle. A confirmed close beyond this rail marks the event as failed."
ttTargetGuide = "Shows a target-room guide beyond the event close. It is used for planning context only."
ttContextEma = "Shows light context EMAs for bias orientation. Disable for a cleaner chart."
ttSmallMarkers = "Shows small directional markers under event and follow-through states. Disabled by default because labels carry the main information."
ttBoxOpacity = "Transparency for the follow-through box. Higher values make the box lighter."
ttProjection = "Number of bars projected to the right for the follow-through box and guide lines."
ttAdaptiveProjection = "Shortens follow-through box and guide projections on daily, weekly, and monthly charts so higher-timeframe screenshots stay balanced."
ttLabels = "Shows event, follow-through, one-bar, and failed-event labels. Labels are intentionally compact and offset from candles."
ttTargetLabels = "Shows target-review labels when the active event reaches the target guide. Disabled by default because target labels can repeat often during strong moves."
ttContextLabels = "Adds sparse context labels while an event is still active. Disabled by default for a cleaner publication screenshot."
ttLabelCooldown = "Minimum bars between major event labels. This protects readability on noisy symbols."
ttContextSpacing = "Minimum bars between sparse context labels during active follow-through review."
ttMaxLabels = "Maximum number of visible chart labels retained. Older labels are removed first for performance."
ttMaxZones = "Maximum number of follow-through boxes and guide sets retained on the chart."
ttLabelOffset = "ATR-based vertical offset used to keep labels away from candle bodies and wicks."
ttLabelScore = "Adds the 0-100 follow-through score to chart labels."
ttLabelSize = "Font size for all on-chart labels and centered box labels. Normal is the default publication setting."
ttShowPanel = "Shows or hides the AGPro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the AGPro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark, slate, and clean light themes."
ttPanelFont = "Font size for the AGPro panel. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Volume Event Engine"
sensitivityInput = input.string("Balanced", "Sensitivity", options = ["Early", "Balanced", "Strict"], group = groupEngine, tooltip = ttSensitivity)
eventSideInput = input.string("Auto", "Event Side", options = ["Auto", "Bull Volume", "Bear Volume"], group = groupEngine, tooltip = ttSide)
confirmationMode = input.string("Confirmed Close", "Confirmation Mode", options = ["Confirmed Close", "Realtime"], group = groupEngine, tooltip = ttConfirm)
atrLen = input.int(14, "ATR Normalization Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
volumeLen = input.int(34, "Volume Lookback", minval = 5, maxval = 300, group = groupEngine, tooltip = ttVolumeLen)
fastEmaLen = input.int(21, "Fast Bias EMA", minval = 1, maxval = 200, group = groupEngine, tooltip = ttFast)
slowEmaLen = input.int(55, "Slow Bias EMA", minval = 2, maxval = 300, group = groupEngine, tooltip = ttSlow)
slopeBars = input.int(5, "Bias Slope Bars", minval = 1, maxval = 30, group = groupEngine, tooltip = ttSlope)

groupEvent = "Event Qualification"
minimumVolumeRatio = input.float(1.55, "Minimum Volume Multiple", minval = 1.00, maxval = 5.00, step = 0.05, group = groupEvent, tooltip = ttMinVolume)
idealVolumeRatio = input.float(2.25, "Ideal Volume Multiple", minval = 1.10, maxval = 6.00, step = 0.05, group = groupEvent, tooltip = ttIdealVolume)
climaxCeilingRatio = input.float(3.80, "Climax Ceiling Multiple", minval = 1.50, maxval = 10.00, step = 0.05, group = groupEvent, tooltip = ttClimaxCeiling)
minimumSpreadAtr = input.float(0.95, "Minimum Spread ATR", minval = 0.20, maxval = 4.00, step = 0.05, group = groupEvent, tooltip = ttMinSpread)
minimumBodyShare = input.float(0.42, "Minimum Body Share", minval = 0.10, maxval = 0.90, step = 0.01, group = groupEvent, tooltip = ttMinBody)
minimumCloseEdge = input.float(0.60, "Minimum Edge Close", minval = 0.50, maxval = 0.95, step = 0.01, group = groupEvent, tooltip = ttCloseEdge)
minimumEventScore = input.int(62, "Minimum Event Score", minval = 30, maxval = 95, group = groupEvent, tooltip = ttMinEventScore)
newEventCooldown = input.int(16, "Cooldown Bars", minval = 1, maxval = 120, group = groupEvent, tooltip = ttCooldown)

groupScoring = "Follow-Through Planning"
minPlannerScore = input.int(72, "Minimum Planner Score", minval = 35, maxval = 95, group = groupScoring, tooltip = ttPlannerScore)
followThroughWindow = input.int(6, "Follow-Through Window", minval = 2, maxval = 30, group = groupScoring, tooltip = ttFollowWindow)
trackingBars = input.int(24, "Active Tracking Bars", minval = 5, maxval = 100, group = groupScoring, tooltip = ttTrackBars)
requiredProgressAtr = input.float(0.65, "Required Progress ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = groupScoring, tooltip = ttRequiredProgress)
minimumFollowCloses = input.int(2, "Minimum Follow-Through Closes", minval = 1, maxval = 10, group = groupScoring, tooltip = ttMinCloses)
riskRailBufferAtr = input.float(0.22, "Risk Rail Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.05, group = groupScoring, tooltip = ttRiskBuffer)
targetGuideAtr = input.float(1.65, "Target Guide ATR", minval = 0.50, maxval = 6.00, step = 0.05, group = groupScoring, tooltip = ttTargetAtr)
adverseLimitAtr = input.float(0.82, "Adverse Limit ATR", minval = 0.20, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttAdverseLimit)

groupVisual = "Chart Visuals"
showEventMarker = input.bool(true, "Show Volume Event Marker", group = groupVisual, tooltip = ttEventMarker)
showFollowThroughBox = input.bool(true, "Show Follow-Through Box", group = groupVisual, tooltip = ttFtBox)
showRiskRail = input.bool(true, "Show Risk Rail", group = groupVisual, tooltip = ttRiskRail)
showTargetGuide = input.bool(true, "Show Target Guide", group = groupVisual, tooltip = ttTargetGuide)
showContextEma = input.bool(true, "Show Context EMAs", group = groupVisual, tooltip = ttContextEma)
showSmallMarkers = input.bool(false, "Show Small Markers", group = groupVisual, tooltip = ttSmallMarkers)
boxTransparency = input.int(91, "Box Transparency", minval = 72, maxval = 96, group = groupVisual, tooltip = ttBoxOpacity)
projectionBars = input.int(24, "Projection Bars", minval = 8, maxval = 160, group = groupVisual, tooltip = ttProjection)
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = ttAdaptiveProjection)
boxBadgeAnchor = input.float(0.50, "Box Badge Anchor", minval = 0.25, maxval = 0.75, step = 0.05, group = groupVisual, tooltip = "Controls the horizontal placement of the centered follow-through box badge.")

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showTargetReviewLabels = input.bool(false, "Show Target Review Labels", group = groupLabels, tooltip = ttTargetLabels)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttLabelCooldown)
contextSpacingBars = input.int(52, "Context Label Spacing", minval = 5, maxval = 240, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(10, "Max Visible Labels", minval = 5, maxval = 60, group = groupLabels, tooltip = ttMaxLabels)
maxVisibleZones = input.int(4, "Max Visible Boxes", minval = 1, maxval = 8, group = groupLabels, tooltip = ttMaxZones)
labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_norm_high_good(float value, float weak, float strong) =>
    float span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    float span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = value <= idealValue ? f_norm_high_good(value, lowValue, idealValue) : f_norm_low_good(value, idealValue, highValue)
    f_clamp(result, 0.0, 100.0)

f_label_size(string sizeText) =>
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
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    theme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : theme == "Slate" ? (evenRow ? color.rgb(30, 41, 59) : color.rgb(24, 34, 56)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_score_text(float score) =>
    na(score) ? "n/a" : str.tostring(int(math.round(score)))

f_ratio_text(float ratioValue) =>
    na(ratioValue) ? "n/a" : str.tostring(ratioValue, "#.##") + "x"

f_score_tier(float score) =>
    na(score) ? "n/a" : score >= 82 ? "A" : score >= 70 ? "B" : score >= 55 ? "C" : "D"

f_dir_text(int dir) =>
    dir == 1 ? "Bull" : dir == -1 ? "Bear" : "Neutral"

f_score_color(float score, int dir) =>
    color baseColor = dir == 1 ? bullColor : dir == -1 ? bearColor : neutralColor
    na(score) ? panelLabelCol : score >= 82 ? accentColor : score >= 65 ? baseColor : score >= 48 ? neutralColor : color.new(baseColor, 20)

f_state_color(string stateText, int dir, float score) =>
    stateText == "FAILED" ? bearColor : stateText == "ONE-BAR EVENT" or stateText == "EXPIRED" or stateText == "REPLACED" ? neutralColor : stateText == "FT READY" ? f_score_color(score, dir) : stateText == "TARGET REVIEW" ? accentColor : stateText == "RISK BUILDING" ? neutralColor : panelValueCol

f_bias_color(int dir) =>
    dir == 1 ? bullColor : dir == -1 ? bearColor : neutralColor

f_panel_row(table panelId, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    color safeRight = theme == "Clean Light" ? rightColor == bullColor ? color.rgb(15, 118, 110) : rightColor == bearColor ? color.rgb(190, 24, 93) : rightColor == neutralColor ? color.rgb(180, 83, 9) : rightColor == accentColor ? color.rgb(79, 70, 229) : rightColor : rightColor
    table.cell(panelId, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize))
    table.cell(panelId, 1, row, rightText, text_color = safeRight, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        label oldLabel = array.shift(labels)
        if not na(oldLabel)
            label.delete(oldLabel)

f_trim_zones(array<box> boxes, array<label> badges, int maxCount) =>
    while array.size(boxes) > maxCount
        box oldBox = array.shift(boxes)
        label oldBadge = array.shift(badges)
        if not na(oldBox)
            box.delete(oldBox)
        if not na(oldBadge)
            label.delete(oldBadge)

f_trend_score(int dir, float priceValue, float fastValue, float slowValue, float slopeValue, float atrValue) =>
    float baseScore = dir == 1 ? (priceValue >= slowValue ? 34.0 : 12.0) : (priceValue <= slowValue ? 34.0 : 12.0)
    float stackScore = dir == 1 ? (fastValue >= slowValue ? 36.0 : 0.0) : (fastValue <= slowValue ? 36.0 : 0.0)
    float slopeAtr = math.abs(slopeValue) / math.max(atrValue, syminfo.mintick)
    float slopeScore = dir == 1 ? (slopeValue >= 0.0 ? f_norm_high_good(slopeAtr, 0.01, 0.28) * 0.30 : 0.0) : (slopeValue <= 0.0 ? f_norm_high_good(slopeAtr, 0.01, 0.28) * 0.30 : 0.0)
    f_clamp(baseScore + stackScore + slopeScore, 0.0, 100.0)

// -------------------------------------------------
// Core measurements
// -------------------------------------------------
float atr = ta.atr(atrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float barRange = math.max(high - low, syminfo.mintick)
float bodySize = math.abs(close - open)
float bodyShare = bodySize / barRange
float closeLocation = (close - low) / barRange
float bullEdgeClose = closeLocation
float bearEdgeClose = 1.0 - closeLocation
float spreadAtr = barRange / safeAtr

float volumeBase = ta.sma(volume, volumeLen)
float relVolume = not na(volumeBase) and volumeBase > 0.0 and not na(volume) ? volume / volumeBase : 1.0

float fastEma = ta.ema(close, fastEmaLen)
float slowEma = ta.ema(close, slowEmaLen)
float trendSlope = slowEma - nz(slowEma[slopeBars], slowEma)
int panelBias = fastEma > slowEma and trendSlope >= 0.0 ? 1 : fastEma < slowEma and trendSlope <= 0.0 ? -1 : 0
int activeProjectionBars = adaptiveProjection ? timeframe.ismonthly ? math.min(projectionBars, 8) : timeframe.isweekly ? math.min(projectionBars, 14) : timeframe.isdaily ? math.min(projectionBars, 20) : projectionBars : projectionBars

float sensitivityMult = sensitivityInput == "Early" ? 0.88 : sensitivityInput == "Strict" ? 1.15 : 1.0
float closeEdgeShift = sensitivityInput == "Early" ? -0.04 : sensitivityInput == "Strict" ? 0.05 : 0.0
float bodyShift = sensitivityInput == "Early" ? -0.04 : sensitivityInput == "Strict" ? 0.07 : 0.0

float qualifiedVolume = minimumVolumeRatio * sensitivityMult
float qualifiedSpread = minimumSpreadAtr * sensitivityMult
float qualifiedClose = f_clamp(minimumCloseEdge + closeEdgeShift, 0.50, 0.95)
float qualifiedBody = f_clamp(minimumBodyShare + bodyShift, 0.10, 0.92)

float volumeScore = f_peak_score(relVolume, qualifiedVolume * 0.72, math.max(idealVolumeRatio, qualifiedVolume + 0.10), math.max(climaxCeilingRatio, idealVolumeRatio + 0.10))
float spreadScore = f_norm_high_good(spreadAtr, qualifiedSpread * 0.70, qualifiedSpread + 0.95)
float bodyScore = f_norm_high_good(bodyShare, qualifiedBody * 0.80, 0.82)
float bullCloseScore = f_norm_high_good(bullEdgeClose, qualifiedClose * 0.88, 0.95)
float bearCloseScore = f_norm_high_good(bearEdgeClose, qualifiedClose * 0.88, 0.95)
float bullTrendScore = f_trend_score(1, close, fastEma, slowEma, trendSlope, safeAtr)
float bearTrendScore = f_trend_score(-1, close, fastEma, slowEma, trendSlope, safeAtr)

float bullEventScore = f_clamp(volumeScore * 0.32 + spreadScore * 0.20 + bullCloseScore * 0.18 + bodyScore * 0.14 + bullTrendScore * 0.16, 0.0, 100.0)
float bearEventScore = f_clamp(volumeScore * 0.32 + spreadScore * 0.20 + bearCloseScore * 0.18 + bodyScore * 0.14 + bearTrendScore * 0.16, 0.0, 100.0)

bool confirmedBar = confirmationMode == "Realtime" or barstate.isconfirmed
bool allowBull = eventSideInput != "Bear Volume"
bool allowBear = eventSideInput != "Bull Volume"
bool commonEventGate = relVolume >= qualifiedVolume and relVolume <= climaxCeilingRatio and spreadAtr >= qualifiedSpread and bodyShare >= qualifiedBody
bool bullCandidate = allowBull and commonEventGate and close >= open and bullEdgeClose >= qualifiedClose and bullEventScore >= minimumEventScore
bool bearCandidate = allowBear and commonEventGate and close <= open and bearEdgeClose >= qualifiedClose and bearEventScore >= minimumEventScore
int candidateDir = bullCandidate and (not bearCandidate or bullEventScore >= bearEventScore) ? 1 : bearCandidate ? -1 : 0
float candidateScore = candidateDir == 1 ? bullEventScore : candidateDir == -1 ? bearEventScore : na
float candidateCloseScore = candidateDir == 1 ? bullCloseScore : candidateDir == -1 ? bearCloseScore : na
float candidateTrendScore = candidateDir == 1 ? bullTrendScore : candidateDir == -1 ? bearTrendScore : na

// -------------------------------------------------
// Active event state
// -------------------------------------------------
var int activeDir = 0
var int activeEventBar = na
var float activeHigh = na
var float activeLow = na
var float activeClose = na
var float activeAtr = na
var float activeTarget = na
var float activeRiskRail = na
var float activeEventScore = na
var float activeFollowScore = na
var float activeVolumeRatio = na
var float activeSpreadScore = na
var float activeCloseScore = na
var float activeBiasScore = na
var float activeBestPrice = na
var float activeWorstAdverseAtr = 0.0
var float activeBestProgressAtr = 0.0
var float activeNextBarScore = 0.0
var int activeFollowCloses = 0
var bool activeNextBarLocked = false
var bool activeContinued = false
var bool activeFailed = false
var bool activeOneBar = false
var bool activeTargetReached = false
var bool activeResolved = false
var int lastEventBar = na
var int lastContextLabelBar = na
var int lastMajorLabelBar = na
var string activeState = "WAITING"
var string activeAction = "Wait for volume event"

// Follow-through proof counters (events that genuinely continued vs all resolved events)
var int ftEventHits = 0
var int ftEventTotal = 0

var box activeFtBox = na
var label activeBoxLabel = na
var line activeRiskLine = na
var line activeTargetLine = na
var label activeRiskTag = na
var label activeTargetTag = na

var array<label> eventLabels = array.new<label>()
var array<box> ftBoxes = array.new<box>()
var array<label> ftBoxLabels = array.new<label>()

bool newVolumeEvent = confirmedBar and candidateDir != 0 and (na(lastEventBar) or bar_index - lastEventBar >= newEventCooldown)
bool readySignal = false
bool failedSignal = false
bool oneBarSignal = false
bool targetSignal = false

if newVolumeEvent
    // Resolve an unfinished prior event before the new independent event takes control.
    if activeDir != 0 and not activeResolved
        activeResolved := true
        ftEventTotal += 1
        activeState := "REPLACED"
        activeAction := "Review new event"

    // Preserve a centered, state-aware badge on every visible historical box.
    color prevBoxCol = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : neutralColor
    if not na(activeBoxLabel)
        color retiredBadgeBg = color.new(prevBoxCol, 38)
        label.set_text(activeBoxLabel, str.upper(f_dir_text(activeDir)) + " | " + activeState + " | Q " + f_score_text(activeFollowScore))
        label.set_color(activeBoxLabel, retiredBadgeBg)
        label.set_textcolor(activeBoxLabel, f_text_on(retiredBadgeBg))
        activeBoxLabel := na
    if not na(activeFtBox)
        box.set_bgcolor(activeFtBox, color.new(prevBoxCol, 94))
        box.set_border_color(activeFtBox, color.new(prevBoxCol, 72))
    if not na(activeRiskLine)
        line.delete(activeRiskLine)
        activeRiskLine := na
    if not na(activeTargetLine)
        line.delete(activeTargetLine)
        activeTargetLine := na
    if not na(activeRiskTag)
        label.delete(activeRiskTag)
        activeRiskTag := na
    if not na(activeTargetTag)
        label.delete(activeTargetTag)
        activeTargetTag := na

    activeDir := candidateDir
    activeEventBar := bar_index
    activeHigh := high
    activeLow := low
    activeClose := close
    activeAtr := safeAtr
    activeTarget := close + candidateDir * safeAtr * targetGuideAtr
    activeRiskRail := candidateDir == 1 ? low - safeAtr * riskRailBufferAtr : high + safeAtr * riskRailBufferAtr
    activeEventScore := candidateScore
    activeFollowScore := candidateScore * 0.42
    activeVolumeRatio := relVolume
    activeSpreadScore := spreadScore
    activeCloseScore := candidateCloseScore
    activeBiasScore := candidateTrendScore
    activeBestPrice := candidateDir == 1 ? high : low
    activeWorstAdverseAtr := 0.0
    activeBestProgressAtr := 0.0
    activeNextBarScore := 0.0
    activeFollowCloses := 0
    activeNextBarLocked := false
    activeContinued := false
    activeFailed := false
    activeOneBar := false
    activeTargetReached := false
    activeResolved := false
    activeState := "EVENT"
    activeAction := "Track follow-through"
    lastEventBar := bar_index
    color eventColor = candidateDir == 1 ? bullColor : bearColor
    int rightEdge = bar_index + activeProjectionBars
    float laneTop = candidateDir == 1 ? activeTarget : activeClose
    float laneBottom = candidateDir == 1 ? activeClose : activeTarget
    float boxTop = math.max(laneTop, laneBottom)
    float boxBottom = math.min(laneTop, laneBottom)
    if showFollowThroughBox
        activeFtBox := box.new(left = bar_index, top = boxTop, right = rightEdge, bottom = boxBottom, xloc = xloc.bar_index, border_color = color.new(eventColor, 45), bgcolor = color.new(eventColor, boxTransparency), border_width = 1)
        int midX = bar_index + int(math.round(activeProjectionBars * boxBadgeAnchor))
        color badgeBg = color.new(eventColor, 18)
        activeBoxLabel := label.new(midX, (boxTop + boxBottom) / 2.0, str.upper(f_dir_text(candidateDir)) + " | EVENT | Q " + f_score_text(candidateScore), xloc = xloc.bar_index, style = label.style_label_center, color = badgeBg, textcolor = f_text_on(badgeBg), size = f_label_size(labelSizeInput))
        array.push(ftBoxes, activeFtBox)
        array.push(ftBoxLabels, activeBoxLabel)
        f_trim_zones(ftBoxes, ftBoxLabels, maxVisibleZones)
    if showRiskRail
        activeRiskLine := line.new(bar_index, activeRiskRail, rightEdge, activeRiskRail, xloc = xloc.bar_index, color = color.new(bearColor, 8), style = line.style_dashed, width = 1)
        activeRiskTag := label.new(rightEdge + 3, activeRiskRail, "RISK " + str.tostring(activeRiskRail, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = f_label_size(labelSizeInput))
    if showTargetGuide
        activeTargetLine := line.new(bar_index, activeTarget, rightEdge, activeTarget, xloc = xloc.bar_index, color = color.new(accentColor, 8), style = line.style_dashed, width = 1)
        activeTargetTag := label.new(rightEdge + 12, activeTarget, "TARGET " + str.tostring(activeTarget, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_label_size(labelSizeInput))
    if showEventMarker and showEventLabels
        float markerY = candidateDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        string markerText = "VOL " + f_ratio_text(relVolume) + (showLabelScore ? " | Q " + f_score_text(candidateScore) : "")
        label eventLabel = label.new(bar_index, markerY, markerText, xloc = xloc.bar_index, style = candidateDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(eventColor, 0), textcolor = f_text_on(eventColor), size = f_label_size(labelSizeInput))
        array.push(eventLabels, eventLabel)
        f_trim_labels(eventLabels, maxVisibleLabels)
        lastMajorLabelBar := bar_index

bool hasActiveEvent = activeDir != 0 and not na(activeEventBar)
int barsActive = hasActiveEvent ? bar_index - activeEventBar : 0
bool activeWindow = hasActiveEvent and barsActive <= trackingBars

if hasActiveEvent and bar_index > activeEventBar and activeWindow
    activeBestPrice := activeDir == 1 ? math.max(activeBestPrice, high) : math.min(activeBestPrice, low)
    float favorableAtr = activeDir == 1 ? math.max(activeBestPrice - activeClose, 0.0) / activeAtr : math.max(activeClose - activeBestPrice, 0.0) / activeAtr
    float adverseAtr = activeDir == 1 ? math.max(activeClose - low, 0.0) / activeAtr : math.max(high - activeClose, 0.0) / activeAtr
    activeBestProgressAtr := math.max(activeBestProgressAtr, favorableAtr)
    activeWorstAdverseAtr := math.max(activeWorstAdverseAtr, adverseAtr)
    if barsActive == 1 and not activeNextBarLocked
        float nextBarProgressAtr = activeDir == 1 ? (close - activeClose) / activeAtr : (activeClose - close) / activeAtr
        activeNextBarScore := f_clamp(nextBarProgressAtr / math.max(requiredProgressAtr * 0.80, 0.05) * 100.0, 0.0, 100.0)
        activeNextBarLocked := true
    if barsActive <= followThroughWindow and confirmedBar
        bool followClose = activeDir == 1 ? close > activeClose : close < activeClose
        if followClose
            activeFollowCloses += 1
    bool railBroken = activeDir == 1 ? close <= activeRiskRail : close >= activeRiskRail
    bool targetTouched = activeDir == 1 ? high >= activeTarget : low <= activeTarget
    float progressScore = f_norm_high_good(activeBestProgressAtr, requiredProgressAtr * 0.25, requiredProgressAtr * 1.70)
    float closeCountScore = f_norm_high_good(activeFollowCloses, 0.0, minimumFollowCloses + 1.0)
    float defenseScore = railBroken ? 0.0 : f_norm_low_good(activeWorstAdverseAtr, 0.10, adverseLimitAtr)
    float timeScore = barsActive <= followThroughWindow ? f_norm_low_good(barsActive, followThroughWindow * 0.25, followThroughWindow + 4.0) : f_norm_low_good(barsActive, followThroughWindow, trackingBars)
    activeFollowScore := f_clamp(activeEventScore * 0.28 + progressScore * 0.28 + activeNextBarScore * 0.18 + closeCountScore * 0.12 + defenseScore * 0.10 + timeScore * 0.04, 0.0, 100.0)
    bool readyNow = not railBroken and activeFollowScore >= minPlannerScore and progressScore >= 45.0 and activeFollowCloses >= minimumFollowCloses
    bool oneBarNow = not railBroken and barsActive >= followThroughWindow and activeFollowScore < minPlannerScore and progressScore < 48.0
    if confirmedBar and not activeResolved
        if railBroken
            activeFailed := true
            failedSignal := true
            activeState := "FAILED"
            activeAction := "Reject event"
        else if targetTouched
            activeTargetReached := true
            targetSignal := true
            activeState := "TARGET REVIEW"
            activeAction := "Review extension"
        else if readyNow
            activeContinued := true
            readySignal := true
            activeState := "FT READY"
            activeAction := "Manage continuation"
        else if oneBarNow
            activeOneBar := true
            oneBarSignal := true
            activeState := "ONE-BAR EVENT"
            activeAction := "Stand aside"
    if not activeResolved and not activeFailed and not activeContinued and not activeOneBar and not activeTargetReached
        activeState := activeWorstAdverseAtr >= adverseLimitAtr * 0.72 ? "RISK BUILDING" : "FT WATCH"
        activeAction := activeState == "RISK BUILDING" ? "Wait for defense" : "Wait for progress"

    // Proof pass: record each event once at its first terminal resolution
    if not activeResolved and (readySignal or targetSignal or failedSignal or oneBarSignal)
        activeResolved := true
        ftEventTotal += 1
        if readySignal or targetSignal
            ftEventHits += 1

    color stateColor = f_score_color(activeFollowScore, activeDir)
    int dynamicRight = math.min(bar_index + activeProjectionBars, activeEventBar + trackingBars + activeProjectionBars)
    if not na(activeFtBox)
        float laneTopUpdate = activeDir == 1 ? activeTarget : activeClose
        float laneBottomUpdate = activeDir == 1 ? activeClose : activeTarget
        box.set_right(activeFtBox, dynamicRight)
        box.set_top(activeFtBox, math.max(laneTopUpdate, laneBottomUpdate))
        box.set_bottom(activeFtBox, math.min(laneTopUpdate, laneBottomUpdate))
        box.set_bgcolor(activeFtBox, color.new(stateColor, activeFailed ? 94 : boxTransparency))
        box.set_border_color(activeFtBox, color.new(stateColor, activeFailed ? 35 : 42))
    if not na(activeBoxLabel)
        int labelRight = not na(activeFtBox) ? box.get_right(activeFtBox) : dynamicRight
        int midX = activeEventBar + int(math.round((labelRight - activeEventBar) * boxBadgeAnchor))
        float boxMid = (math.max(activeTarget, activeClose) + math.min(activeTarget, activeClose)) / 2.0
        color badgeUpdate = color.new(stateColor, 16)
        label.set_x(activeBoxLabel, midX)
        label.set_y(activeBoxLabel, boxMid)
        label.set_text(activeBoxLabel, str.upper(f_dir_text(activeDir)) + " | " + activeState + " | Q " + f_score_text(activeFollowScore))
        label.set_color(activeBoxLabel, badgeUpdate)
        label.set_textcolor(activeBoxLabel, f_text_on(badgeUpdate))
        label.set_size(activeBoxLabel, f_label_size(labelSizeInput))
    if not na(activeRiskLine)
        line.set_xy2(activeRiskLine, dynamicRight, activeRiskRail)
        line.set_color(activeRiskLine, color.new(activeFailed ? bearColor : neutralColor, activeFailed ? 0 : 12))
    if not na(activeRiskTag)
        color riskTagBg = color.new(activeFailed ? bearColor : neutralColor, 0)
        label.set_x(activeRiskTag, dynamicRight + 3)
        label.set_y(activeRiskTag, activeRiskRail)
        label.set_text(activeRiskTag, "RISK " + str.tostring(activeRiskRail, format.mintick))
        label.set_color(activeRiskTag, riskTagBg)
        label.set_textcolor(activeRiskTag, f_text_on(riskTagBg))
        label.set_size(activeRiskTag, f_label_size(labelSizeInput))
    if not na(activeTargetLine)
        line.set_xy2(activeTargetLine, dynamicRight, activeTarget)
        line.set_color(activeTargetLine, color.new(activeTargetReached ? accentColor : f_score_color(activeFollowScore, activeDir), 10))
    if not na(activeTargetTag)
        color targetTagBg = color.new(activeTargetReached ? accentColor : f_score_color(activeFollowScore, activeDir), 0)
        label.set_x(activeTargetTag, dynamicRight + 12)
        label.set_y(activeTargetTag, activeTarget)
        label.set_text(activeTargetTag, "TARGET " + str.tostring(activeTarget, format.mintick))
        label.set_color(activeTargetTag, targetTagBg)
        label.set_textcolor(activeTargetTag, f_text_on(targetTagBg))
        label.set_size(activeTargetTag, f_label_size(labelSizeInput))
    bool majorLabelAllowed = na(lastMajorLabelBar) or bar_index - lastMajorLabelBar >= labelCooldownBars
    if showEventLabels and readySignal and majorLabelAllowed
        float labelY = activeDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        color readyBg = color.new(f_score_color(activeFollowScore, activeDir), 0)
        label readyLabel = label.new(bar_index, labelY, "FT READY" + (showLabelScore ? " | Q " + f_score_text(activeFollowScore) : ""), xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_up : label.style_label_down, color = readyBg, textcolor = f_text_on(readyBg), size = f_label_size(labelSizeInput))
        array.push(eventLabels, readyLabel)
        f_trim_labels(eventLabels, maxVisibleLabels)
        lastMajorLabelBar := bar_index
    if showEventLabels and failedSignal
        float failY = activeDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
        label failLabel = label.new(bar_index, failY, "FAILED | RAIL", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = f_label_size(labelSizeInput))
        array.push(eventLabels, failLabel)
        f_trim_labels(eventLabels, maxVisibleLabels)
        lastMajorLabelBar := bar_index
    if showEventLabels and oneBarSignal
        float weakY = activeDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
        label weakLabel = label.new(bar_index, weakY, "ONE-BAR | NO FT", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_label_size(labelSizeInput))
        array.push(eventLabels, weakLabel)
        f_trim_labels(eventLabels, maxVisibleLabels)
        lastMajorLabelBar := bar_index
    if showEventLabels and showTargetReviewLabels and targetSignal and majorLabelAllowed
        float targetY = activeDir == 1 ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
        label targetLabel = label.new(bar_index, targetY, "TARGET | REVIEW", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_label_size(labelSizeInput))
        array.push(eventLabels, targetLabel)
        f_trim_labels(eventLabels, maxVisibleLabels)
        lastMajorLabelBar := bar_index
    bool contextAllowed = showContextLabels and not activeFailed and activeWindow and barsActive > 1 and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)
    if showEventLabels and contextAllowed
        float contextY = activeDir == 1 ? low - safeAtr * labelOffsetAtr * 0.72 : high + safeAtr * labelOffsetAtr * 0.72
        string contextText = activeState == "FT WATCH" ? "FT Watch" : activeState == "RISK BUILDING" ? "Risk" : activeState
        color contextBg = color.new(f_state_color(activeState, activeDir, activeFollowScore), 8)
        label contextLabel = label.new(bar_index, contextY, str.upper(contextText) + (showLabelScore ? " | Q " + f_score_text(activeFollowScore) : ""), xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_up : label.style_label_down, color = contextBg, textcolor = f_text_on(contextBg), size = f_label_size(labelSizeInput))
        array.push(eventLabels, contextLabel)
        f_trim_labels(eventLabels, maxVisibleLabels)
        lastContextLabelBar := bar_index

if hasActiveEvent and not activeWindow and not activeResolved
    activeResolved := true
    ftEventTotal += 1
    activeState := "EXPIRED"
    activeAction := "Wait for new event"
    if not na(activeBoxLabel)
        color expiredBadgeBg = color.new(neutralColor, 20)
        label.set_text(activeBoxLabel, str.upper(f_dir_text(activeDir)) + " | EXPIRED | Q " + f_score_text(activeFollowScore))
        label.set_color(activeBoxLabel, expiredBadgeBg)
        label.set_textcolor(activeBoxLabel, f_text_on(expiredBadgeBg))

// Follow-through hit rate (proof readout)
float ftHitRate = ftEventTotal > 0 ? ftEventHits / ftEventTotal * 100.0 : na
string ftRateText = ftEventTotal > 0 ? str.tostring(int(math.round(ftHitRate))) + "% (" + str.tostring(ftEventHits) + "/" + str.tostring(ftEventTotal) + ")" : "Building"
color ftRateColor = ftEventTotal == 0 ? neutralColor : ftHitRate >= 60.0 ? bullColor : ftHitRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Visual plots
// -------------------------------------------------
plot(showContextEma ? fastEma : na, "Fast Bias EMA", color = color.new(accentColor, 50), linewidth = 1)
plot(showContextEma ? slowEma : na, "Slow Bias EMA", color = color.new(panelLabelCol, 45), linewidth = 1)

plotshape(showSmallMarkers and newVolumeEvent and candidateDir == 1, title = "Bull Volume Event", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showSmallMarkers and newVolumeEvent and candidateDir == -1, title = "Bear Volume Event", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(showSmallMarkers and readySignal and activeDir == 1, title = "Bull Follow-Through Ready", style = shape.circle, location = location.belowbar, color = color.new(accentColor, 0), size = size.tiny)
plotshape(showSmallMarkers and readySignal and activeDir == -1, title = "Bear Follow-Through Ready", style = shape.circle, location = location.abovebar, color = color.new(accentColor, 0), size = size.tiny)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = na

if barstate.islast
    if showPanel
        if na(panel)
            panel := table.new(f_panel_position(panelLocationInput), 2, 7, bgcolor = f_panel_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_width = 1)
        table.set_position(panel, f_panel_position(panelLocationInput))
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Volume Follow-Through Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)
        string eventText = hasActiveEvent ? f_dir_text(activeDir) + " " + f_ratio_text(activeVolumeRatio) : "No active event"
        color eventColor = hasActiveEvent ? f_score_color(activeEventScore, activeDir) : f_panel_value(panelThemeInput)
        string ftText = hasActiveEvent ? activeState + " " + f_score_text(activeFollowScore) : "Waiting"
        color ftColor = hasActiveEvent ? f_state_color(activeState, activeDir, activeFollowScore) : f_panel_value(panelThemeInput)
        string spreadText = hasActiveEvent ? f_score_tier(activeSpreadScore) + " / " + f_score_text(activeSpreadScore) : "n/a"
        color spreadColor = hasActiveEvent ? f_score_color(activeSpreadScore, activeDir) : f_panel_value(panelThemeInput)
        string biasText = f_dir_text(panelBias) + " Bias"
        color biasColor = f_bias_color(panelBias)
        string actionText = hasActiveEvent ? activeAction : "Wait for event"
        color actionColor = hasActiveEvent ? ftColor : f_panel_value(panelThemeInput)
        f_panel_row(panel, 1, "Volume Event", eventText, eventColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Follow-Through", ftText, ftColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Outcome Proof", ftRateText, ftRateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Spread Quality", spreadText, spreadColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Bias", biasText, biasColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Action", actionText, actionColor, panelThemeInput, panelFontSizeInput)
    else if not na(panel)
        table.delete(panel)
        panel := na

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newVolumeEvent, "Volume Event", "Volume Follow-Through Planner: qualified volume event registered.")
alertcondition(readySignal, "Follow-Through Ready", "Volume Follow-Through Planner: follow-through score reached the ready threshold.")
alertcondition(failedSignal, "Risk Rail Broken", "Volume Follow-Through Planner: active event closed beyond the risk rail.")
alertcondition(targetSignal, "Target Review", "Volume Follow-Through Planner: active event reached the target-room guide.")
alertcondition(oneBarSignal, "One-Bar Event", "Volume Follow-Through Planner: event did not create enough follow-through inside the review window.")
````
