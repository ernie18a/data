# Reaction Follow-Through Planner [AGPro Series]

- url: https://www.tradingview.com/script/sI06GmrZ-Reaction-Follow-Through-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;273c47ef8c584916b21df20ba63e4806
- version: 4.0

## Description

Reaction Follow-Through Planner [AGPro Series]


🧠 Core Idea

Did the first reaction actually create follow-through, or did price only bounce and fade?


📌 Overview / What it does

Reaction Follow-Through Planner is a decision-oriented overlay that evaluates what happens after price produces an initial reaction around a confirmed swing reference.

Instead of only marking the reaction itself, the script opens a structured follow-through window, measures progress, tracks defense of the reaction zone, defines invalidation, estimates target room, and converts the context into a 0-100 planner score.

It produces reaction zones, follow-through tracks, continuation markers, failed-reaction labels, risk/target guide lines, and a compact AGPro panel. It does not predict future price, place trades, automate execution, or claim that any reaction must continue.


🎯 Purpose & Design Philosophy

This script was built for traders who already understand that a reaction candle is not enough.

Many charts show a wick, bounce, rejection, hold, or local response, but the real question comes after that first response: did the market follow through with clean progress, participation, and defended invalidation?

The design philosophy is simple: treat reaction analysis as a planning workflow. The script helps organize the reaction into strength, follow-through, invalidation, room, and next action.


⚡ Why This Script Is Different

Most reaction tools focus on finding the reaction candle, drawing the level, or scoring the first response.

This script does NOT clone a rejection-block detector, a support/resistance reaction map, or a generic pivot reaction score.

Instead, it starts after the first reaction appears. It tracks whether that reaction can defend its zone, produce directional progress, maintain follow-through, and offer enough room before the context becomes stale or failed.


⚙️ Methodology

1. Context Detection

The engine tracks confirmed swing reaction references and waits for price to interact with them.

2. Reference Mapping

When the first response is accepted, the script builds a reaction zone from the first response candle and defines an invalidation edge beyond the defended area.

3. Reaction Evaluation

The script grades the initial reaction candle using close defense, wick defense, body participation, and direction agreement.

4. Follow-Through Tracking

During the tracking window, the model measures best directional progress, next-bar response, volume support, adverse excursion, time decay, and whether the invalidation edge remains defended.

5. Visual Output

The chart displays reaction zones, follow-through tracks, target room, invalidation guides, continuation markers, failed-reaction labels, and a clean AGPro planner panel.


🗺️ How to Read the Chart

Zones = the defended first-reaction area that should remain intact for the follow-through case to stay valid.

Follow-through track = the movement path from the reaction close toward the current follow-through position.

Invalidation guide = the price edge where the reaction context is considered failed by the script logic.

Target room guide = the nearby structure or ATR-based room estimate used to judge whether the reaction still has space.

Labels = optional reaction start markers, follow-through continuation, or failed-reaction context. Start labels and failed-reaction X markers are disabled by default, while failed-reaction labels use a separate low cap for a cleaner publication view.

Colors = teal for bullish reaction continuation, pink for bearish reaction continuation, gold for weak or stalled contexts, and indigo for higher-quality follow-through.

Panel = the current reaction strength, follow-through state, invalidation level, room estimate, and next action.


🚦 Signals & States

• Bull Reaction Watch → a bullish reaction window is active, but follow-through still needs progress.

• Bear Reaction Watch → a bearish reaction window is active, but follow-through still needs progress.

• Bull Follow-Through → bullish follow-through reached the planner threshold.

• Bear Follow-Through → bearish follow-through reached the planner threshold.

• No Follow-Through → the reaction stayed defended but did not generate enough progress inside the tracking window.

• Failed Reaction → price closed beyond the reaction invalidation edge.


🔔 Alerts Logic

Alerts are attention markers, not trade instructions.

New Bull Reaction Window triggers when a bullish first-response window opens.

New Bear Reaction Window triggers when a bearish first-response window opens.

Bull Follow-Through Ready triggers when bullish follow-through reaches the score and progress thresholds.

Bear Follow-Through Ready triggers when bearish follow-through reaches the score and progress thresholds.

Reaction Failed triggers when price closes beyond the active invalidation edge.


🧩 Confluence Logic

The strongest context appears when reaction strength, next-bar progress, volume response, wick defense, and room all align.

When the reaction candle is strong but follow-through is weak, the panel will usually remain in watch or no-follow-through mode.

When follow-through progresses but invalidation is too close or room is limited, interpretation should stay cautious.


📊 When to Use

• After a visible reaction from a swing high or swing low reference.

• During retest, hold, rejection, or continuation planning.

• When you want to separate first-response reactions from reactions that actually continue.

• On symbols and timeframes with enough liquidity for clean candle structure.


⚠️ When NOT to Use

• Extremely low-liquidity markets where reaction candles are unreliable.

• Very noisy micro timeframes with erratic wicks.

• News-driven volatility where invalidation and room can shift quickly.

• Situations where the user expects automatic entries or guaranteed outcomes.


🎛️ Key Inputs

• Swing Reaction Lookback → controls how selective the reaction references are.

• First Response Mode → controls how strict the first reaction filter is.

• Follow-Through Track Bars → controls how long the script evaluates continuation after the reaction.

• Minimum Planner Score → sets the threshold for continuation-ready context.

• Invalidation Buffer → controls how far beyond the reaction zone the invalidation edge sits.

• Fallback Target Room → estimates room when no clean opposite structure is nearby.

• Visual settings → control zones, optional start labels, outcome labels, failed-reaction label cap, optional failed markers, guides, density, and panel layout.


🖥️ Interface & Visual Design

The interface is built around a clean AGPro panel and chart-first visuals.

The panel gives the decision summary. The chart shows the defended reaction zone, follow-through track, invalidation edge, target room, and state labels.

The visual hierarchy is intentionally restrained: enough labels to make the chart alive, but not so many that the reaction workflow becomes noisy.


🧪 Practical Usage Workflow

1. Read the panel to see whether a reaction window is active.

2. Check the reaction zone and invalidation edge.

3. Watch whether the follow-through track expands away from the zone.

4. Compare the score with available target room.

5. Treat alerts as review prompts, not execution commands.


🔍 Interpretation Guidelines

A strong reaction is not automatically a strong follow-through.

A clean follow-through usually needs directional progress, defended invalidation, supportive participation, and enough remaining room.

If the panel says No Follow-Through, the reaction may still be interesting visually, but the script did not detect enough post-reaction continuation quality.

If the panel says Failed Reaction, the original reaction context is no longer valid according to the script rules.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a replacement for risk management.

• Not a generic support/resistance map.

• Not a rejection-block scanner.


⚠️ Limitations & Transparency

The script is rule-based and depends on confirmed swing references, ATR normalization, volume baselines, and selected sensitivity settings.

Different timeframes can produce different reaction windows.

High volatility can expand invalidation distance and reduce room quality.

Low-liquidity markets can create misleading wick behavior.


🧠 Market Context Notes

Reaction follow-through is strongest when the first response is supported by participation and clean progress away from the defended zone.

It is weaker when price reacts but stalls near the zone, repeatedly revisits invalidation, or lacks target room.

The script is designed to help traders think in terms of reaction quality, not certainty.


🧾 Use Case Examples

When price reacts from a swing low and the next bars defend the reaction zone with rising progress, the planner may shift from Bull Reaction Watch to Bull Follow-Through.

When price rejects a swing high but immediately reclaims the invalidation edge, the planner may mark Failed Reaction.

When price bounces but fails to expand before the tracking window expires, the panel may show No Follow-Through.


🧱 System Philosophy

The AGPro approach favors decision engines over simple signal indicators.

This script follows that philosophy by turning a reaction into a structured review process: strength, follow-through, invalidation, room, and action.


🔐 Non-Promise Statement

No score guarantees continuation.

No alert confirms a profitable outcome.

No visual state should be treated as certainty.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, position sizing, and market interpretation.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use this script to study how reactions behave after the first response.

The goal is to improve interpretation discipline, not to replace a complete trading plan.

## Source Code

````pine
// -------------------------------------------------
// Reaction Follow-Through Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Reaction Follow-Through Planner evaluates whether an initial support or
// resistance reaction can produce real follow-through after the first response.
// It creates a reaction zone, tracks continuation progress, defines the
// invalidation edge and target room, and converts the context into a 0-100
// decision score with a clear next-action state. A live Follow-Through Rate
// logs how often a reaction reaches a balanced one-risk target before its own
// invalidation, as honest, non-repainting proof of the planner.
// -------------------------------------------------

//@version=6
indicator("Reaction Follow-Through Planner [AGPro Series]",
     shorttitle = "AG Pro RFT",
     overlay = true,
     max_boxes_count = 160,
     max_lines_count = 160,
     max_labels_count = 320)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttPivotLen = "Bars on each side used to confirm swing reaction references. Higher values create fewer but more meaningful reaction anchors."
ttAtrLen = "ATR length used to normalize zone width, label offsets, invalidation buffers, target room, and follow-through progress."
ttZoneWidth = "ATR-based padding around the first reaction area. This is a reaction context zone, not a generic support or resistance map."
ttResponseMode = "Controls how demanding the first reaction filter is. Strict requires stronger candle agreement before a follow-through window opens."
ttTrackBars = "Number of bars used to evaluate whether the first response produced real follow-through or faded after the reaction."
ttMinScore = "Minimum 0-100 follow-through score required before the planner marks the reaction as continuation-ready."
ttCooldown = "Minimum bars between new reaction windows. This keeps the chart readable and prevents repeated labels around the same area."
ttVolumeLen = "Volume baseline used to evaluate whether the reaction and follow-through have participation support."
ttInvBuffer = "ATR buffer beyond the reaction zone used to place the invalidation edge. A close beyond this edge marks the reaction as failed."
ttTargetAtr = "Fallback ATR distance used when no clean structural room is available beyond the reaction."
ttRoomLookback = "Lookback used to locate nearby opposite-side structure for target room estimation."
ttProofWindow = "Bars allowed for a reaction to reach its one-risk target or invalidation before the sample is left unresolved (uncounted) in the Follow-Through Rate."
ttShowZones = "Show reaction zones created from the first response candle. Each zone represents the area that must remain defended."
ttShowTrack = "Show a follow-through track from the reaction close to the current follow-through position."
ttShowGuides = "Show invalidation and target room guide lines for the active reaction window."
ttShowLabels = "Show one collision-safe terminal outcome label per reaction plan. Labels are offset from candles for cleaner publication screenshots."
ttShowStartLabels = "Show compact labels when a reaction window first opens. Disabled by default so the chart focuses on follow-through and failure outcomes."
ttShowMarkers = "Show compact directional markers when follow-through or failure states are confirmed."
ttShowFailMarkers = "Show small failed-reaction X markers. Disabled by default because failure labels already provide the required context."
ttMaxLabels = "Maximum number of visible event labels retained on the chart. Older labels are deleted first for performance and clarity."
ttMaxZones = "Maximum number of reaction zones retained on the chart. Older zones are deleted first to avoid clutter."
ttZoneRight = "Number of bars each reaction zone extends beyond the tracking window so the defended area remains visible after the first response."
ttAdaptiveProjection = "Shortens reaction-zone extension on daily, weekly, and monthly charts so higher-timeframe screenshots stay balanced."
ttZoneLabelAnchor = "Controls the horizontal placement of the centered reaction-zone badge inside the active zone."
ttLabelOffset = "ATR-based label offset used to keep text away from candle bodies and wicks."
ttLabelSize = "Font size for all on-chart labels. Normal is the default publication setting."
ttShowPanel = "Show or hide the AGPro planner panel. The panel is visible by default for public-release readability."
ttPanelPos = "Panel anchor location. Move it if it overlaps the most active price area on your chart."
ttPanelTheme = "Panel color theme. Elite Dark follows the AGPro dashboard style; Slate and Clean Light are available for different chart layouts."
ttPanelFont = "Font size for the panel text. Normal is the default publication setting."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Engine"
pivotLen = input.int(5, "Swing Reaction Lookback", minval = 2, maxval = 30, group = groupEngine, tooltip = ttPivotLen)
atrLen = input.int(14, "ATR Normalization Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
zoneWidthAtr = input.float(0.28, "Reaction Zone Width (ATR)", minval = 0.05, maxval = 1.50, step = 0.01, group = groupEngine, tooltip = ttZoneWidth)
responseMode = input.string("Balanced", "First Response Mode", options = ["Fast", "Balanced", "Strict"], group = groupEngine, tooltip = ttResponseMode)
trackBars = input.int(8, "Follow-Through Track Bars", minval = 3, maxval = 30, group = groupEngine, tooltip = ttTrackBars)
minimumScore = input.float(62.0, "Minimum Planner Score", minval = 30.0, maxval = 95.0, step = 1.0, group = groupEngine, tooltip = ttMinScore)
cooldownBars = input.int(16, "Reaction Cooldown Bars", minval = 0, maxval = 80, group = groupEngine, tooltip = ttCooldown)
volumeLen = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttVolumeLen)

groupRisk = "Risk And Room"
invalidationBufferAtr = input.float(0.18, "Invalidation Buffer (ATR)", minval = 0.00, maxval = 1.50, step = 0.01, group = groupRisk, tooltip = ttInvBuffer)
targetAtrMultiple = input.float(1.80, "Fallback Target Room (ATR)", minval = 0.50, maxval = 6.00, step = 0.10, group = groupRisk, tooltip = ttTargetAtr)
roomLookback = input.int(50, "Room Structure Lookback", minval = 10, maxval = 300, group = groupRisk, tooltip = ttRoomLookback)
proofWindowBars = input.int(20, "Follow-Through Proof Window Bars", minval = 10, maxval = 200, group = groupRisk, tooltip = ttProofWindow)

groupVisual = "Visuals"
showZones = input.bool(true, "Show Reaction Zones", group = groupVisual, tooltip = ttShowZones)
showTrack = input.bool(false, "Show Follow-Through Track", group = groupVisual, tooltip = ttShowTrack)
showGuides = input.bool(true, "Show Invalidation / Target Guides", group = groupVisual, tooltip = ttShowGuides)
showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = ttShowLabels)
showStartLabels = input.bool(false, "Show Start Labels", group = groupVisual, tooltip = ttShowStartLabels)
showMarkers = input.bool(true, "Show Directional Markers", group = groupVisual, tooltip = ttShowMarkers)
showFailedMarkers = input.bool(false, "Show Failed Reaction Markers", group = groupVisual, tooltip = ttShowFailMarkers)
maxVisibleLabels = input.int(16, "Max Visible Labels", minval = 5, maxval = 120, group = groupVisual, tooltip = ttMaxLabels)
maxVisibleZones = input.int(4, "Max Visible Zones", minval = 1, maxval = 30, group = groupVisual, tooltip = ttMaxZones)
zoneRightExtension = input.int(8, "Zone Right Extension Bars", minval = 4, maxval = 80, group = groupVisual, tooltip = ttZoneRight)
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = ttAdaptiveProjection)
zoneLabelAnchor = input.float(0.50, "Zone Label Anchor", minval = 0.25, maxval = 0.75, step = 0.05, group = groupVisual, tooltip = ttZoneLabelAnchor)
labelOffsetAtr = input.float(0.80, "Label Offset (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = ttLabelOffset)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelPos)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
darkText = color.rgb(17, 24, 39)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_text_on(color bg) =>
    bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_label_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_size(string sizeText) =>
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

f_score_text(float score) =>
    str.tostring(int(math.round(score)))

f_price_text(float priceValue) =>
    na(priceValue) ? "n/a" : str.tostring(priceValue, format.mintick)

f_score_tier(float score) =>
    score >= 82 ? "A" : score >= 70 ? "B" : score >= 55 ? "C" : "D"

f_score_color(float score, int dir) =>
    color base = dir == 1 ? bullColor : dir == -1 ? bearColor : neutralColor
    score >= 82 ? accentColor : score >= 62 ? base : score >= 45 ? neutralColor : color.new(base, 25)

f_state_color(string stateText, int dir) =>
    stateText == "Failed Reaction" ? bearColor : stateText == "No Follow-Through" ? neutralColor : dir == 1 ? bullColor : dir == -1 ? bearColor : neutralColor

f_prune_labels(array<label> ids, int maxKeep) =>
    while array.size(ids) > maxKeep
        label oldId = array.shift(ids)
        if not na(oldId)
            label.delete(oldId)

f_prune_boxes(array<box> ids, int maxKeep) =>
    while array.size(ids) > maxKeep
        box oldId = array.shift(ids)
        if not na(oldId)
            box.delete(oldId)

f_prune_lines(array<line> ids, int maxKeep) =>
    while array.size(ids) > maxKeep
        line oldId = array.shift(ids)
        if not na(oldId)
            line.delete(oldId)

f_panel_row(table panelId, int row, string labelText, string valueText, color valueColor, color bgColor, color labelColor, textSize) =>
    table.cell(panelId, 0, row, labelText, text_color = labelColor, bgcolor = bgColor, text_size = textSize)
    table.cell(panelId, 1, row, valueText, text_color = valueColor, bgcolor = bgColor, text_size = textSize)

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
visualZoneRightExtension = adaptiveProjection ? timeframe.ismonthly ? math.min(zoneRightExtension, 6) : timeframe.isweekly ? math.min(zoneRightExtension, 10) : timeframe.isdaily ? math.min(zoneRightExtension, 14) : zoneRightExtension : zoneRightExtension
volBase = ta.sma(volume, volumeLen)
relVol = volBase > 0 ? volume / volBase : 1.0
barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyShare = bodySize / barRange
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
closePos = (close - low) / barRange
recentHigh = ta.highest(high, roomLookback)
recentLow = ta.lowest(low, roomLookback)

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float lastResistance = na
var float lastSupport = na

if not na(pivotHigh)
    lastResistance := pivotHigh

if not na(pivotLow)
    lastSupport := pivotLow

reactionTolerance = safeAtr * zoneWidthAtr
requiredComponents = responseMode == "Strict" ? 3 : responseMode == "Balanced" ? 2 : 1

supportTouched = not na(lastSupport) and low <= lastSupport + reactionTolerance and high >= lastSupport - reactionTolerance
resistanceTouched = not na(lastResistance) and high >= lastResistance - reactionTolerance and low <= lastResistance + reactionTolerance

bullComponents = (not na(lastSupport) and close > lastSupport ? 1 : 0) + (close >= open ? 1 : 0) + (lowerWick >= upperWick ? 1 : 0) + (closePos >= 0.55 ? 1 : 0)
bearComponents = (not na(lastResistance) and close < lastResistance ? 1 : 0) + (close <= open ? 1 : 0) + (upperWick >= lowerWick ? 1 : 0) + (closePos <= 0.45 ? 1 : 0)

// -------------------------------------------------
// Active Reaction State
// -------------------------------------------------
var int activeDir = 0
var int activeEventBar = na
var float activeEventClose = na
var float activeZoneTop = na
var float activeZoneBottom = na
var float activeInvalidation = na
var float activeTarget = na
var float activeReactionScore = na
var float activeNextBarScore = 0.0
var float activeVolumeScore = na
var float activeBestProgress = 0.0
var float activeWorstAdverse = 0.0
var float activeFollowScore = 0.0
var bool activeNextBarLocked = false
var bool activeContinued = false
var bool activeFailed = false
var int activeOutcome = 0
var int lastEventBar = na
var string activeState = "No Active Reaction"
var string activeAction = "Wait for reaction"

var box activeBox = na
var label activeZoneLabel = na
var line activeTrackLine = na
var line activeInvalidationLine = na
var line activeTargetLine = na
var label activeInvalidationLabel = na
var label activeTargetLabel = na

var array<label> eventLabels = array.new<label>()
var array<label> zoneLabels = array.new<label>()
var array<box> reactionBoxes = array.new<box>()
var array<line> guideLines = array.new<line>()

confirmedBar = barstate.isconfirmed
reactionReady = na(lastEventBar) or bar_index - lastEventBar >= cooldownBars
supportDistance = supportTouched ? math.abs(close - lastSupport) : 100000000.0
resistanceDistance = resistanceTouched ? math.abs(close - lastResistance) : 100000000.0

bullCandidate = confirmedBar and reactionReady and supportTouched and bullComponents >= requiredComponents and supportDistance <= resistanceDistance
bearCandidate = confirmedBar and reactionReady and resistanceTouched and bearComponents >= requiredComponents and resistanceDistance < supportDistance
newReaction = bullCandidate or bearCandidate
newDir = bullCandidate ? 1 : bearCandidate ? -1 : 0

if newReaction
    while array.size(guideLines) > 0
        line oldGuide = array.shift(guideLines)
        if not na(oldGuide)
            line.delete(oldGuide)
    activeTrackLine := na
    activeInvalidationLine := na
    activeTargetLine := na
    if not na(activeInvalidationLabel)
        label.delete(activeInvalidationLabel)
    if not na(activeTargetLabel)
        label.delete(activeTargetLabel)
    activeInvalidationLabel := na
    activeTargetLabel := na
    float anchorLevel = newDir == 1 ? lastSupport : lastResistance
    float rawTop = newDir == 1 ? math.max(anchorLevel + reactionTolerance, math.min(open, close)) : math.max(high, anchorLevel + reactionTolerance)
    float rawBottom = newDir == 1 ? math.min(low, anchorLevel - reactionTolerance) : math.min(anchorLevel - reactionTolerance, math.max(open, close))
    float zTop = math.max(rawTop, rawBottom)
    float zBot = math.min(rawTop, rawBottom)
    float wickDefense = newDir == 1 ? lowerWick / barRange : upperWick / barRange
    float closeDefense = newDir == 1 ? closePos : 1.0 - closePos
    float bodyAlign = newDir == 1 ? (close >= open ? 1.0 : 0.0) : (close <= open ? 1.0 : 0.0)
    float reactionScore = f_clamp(closeDefense * 38.0 + wickDefense * 32.0 + bodyShare * 15.0 + bodyAlign * 15.0, 0.0, 100.0)
    float fallbackTarget = newDir == 1 ? close + safeAtr * targetAtrMultiple : close - safeAtr * targetAtrMultiple
    float roomTarget = newDir == 1 ? (recentHigh > close ? recentHigh : fallbackTarget) : (recentLow < close ? recentLow : fallbackTarget)
    activeDir := newDir
    activeEventBar := bar_index
    activeEventClose := close
    activeZoneTop := zTop
    activeZoneBottom := zBot
    activeInvalidation := newDir == 1 ? zBot - safeAtr * invalidationBufferAtr : zTop + safeAtr * invalidationBufferAtr
    activeTarget := roomTarget
    activeReactionScore := reactionScore
    activeVolumeScore := f_clamp(relVol / 1.70 * 100.0, 0.0, 100.0)
    activeNextBarScore := 0.0
    activeBestProgress := 0.0
    activeWorstAdverse := 0.0
    activeFollowScore := reactionScore * 0.40 + activeVolumeScore * 0.10
    activeNextBarLocked := false
    activeContinued := false
    activeFailed := false
    activeOutcome := 0
    activeState := newDir == 1 ? "Bull Reaction Watch" : "Bear Reaction Watch"
    activeAction := "Track follow-through"
    lastEventBar := bar_index
    color zoneColor = newDir == 1 ? bullColor : bearColor
    int zoneRight = bar_index + trackBars + visualZoneRightExtension
    if showZones
        activeBox := box.new(left = bar_index, top = zTop, right = zoneRight, bottom = zBot, xloc = xloc.bar_index, border_color = color.new(zoneColor, 42), bgcolor = color.new(zoneColor, 90), border_width = 1)
        array.push(reactionBoxes, activeBox)
        f_prune_boxes(reactionBoxes, maxVisibleZones)
        int midX = bar_index + int(math.floor((trackBars + visualZoneRightExtension) * zoneLabelAnchor))
        activeZoneLabel := label.new(midX, (zTop + zBot) / 2.0, (newDir == 1 ? "BULL" : "BEAR") + " WATCH\nQ" + f_score_text(activeFollowScore) + " | AGE 0/" + str.tostring(trackBars), xloc = xloc.bar_index, style = label.style_label_center, color = color.new(zoneColor, 30), textcolor = f_text_on(zoneColor), size = f_label_size(labelSizeInput))
        array.push(zoneLabels, activeZoneLabel)
        f_prune_labels(zoneLabels, maxVisibleZones)
    if showTrack
        activeTrackLine := line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = color.new(zoneColor, 0), width = 2)
        array.push(guideLines, activeTrackLine)
    if showGuides
        activeInvalidationLine := line.new(bar_index, activeInvalidation, zoneRight, activeInvalidation, xloc = xloc.bar_index, color = color.new(bearColor, 10), style = line.style_dashed, width = 1)
        activeTargetLine := line.new(bar_index, activeTarget, zoneRight, activeTarget, xloc = xloc.bar_index, color = color.new(accentColor, 12), style = line.style_dashed, width = 1)
        activeInvalidationLabel := label.new(zoneRight, activeInvalidation, "INVALID " + f_price_text(activeInvalidation), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = f_label_size(labelSizeInput))
        activeTargetLabel := label.new(zoneRight, activeTarget, "TARGET " + f_price_text(activeTarget), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_label_size(labelSizeInput))
        array.push(guideLines, activeInvalidationLine)
        array.push(guideLines, activeTargetLine)
    f_prune_lines(guideLines, maxVisibleZones * 3)
    if showLabels and showStartLabels
        float labelY = newDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        label startLabel = label.new(bar_index, labelY, "Start\n" + f_score_text(reactionScore), xloc = xloc.bar_index, style = newDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(zoneColor, 10), textcolor = f_text_on(zoneColor), size = f_label_size(labelSizeInput))
        array.push(eventLabels, startLabel)
        f_prune_labels(eventLabels, maxVisibleLabels)

// -------------------------------------------------
// Follow-Through Tracking
// -------------------------------------------------
continuationSignal = false
failureSignal = false

if confirmedBar and activeDir != 0 and not na(activeEventBar)
    int barsElapsed = bar_index - activeEventBar
    float favorable = activeDir == 1 ? high - activeEventClose : activeEventClose - low
    float adverse = activeDir == 1 ? activeEventClose - low : high - activeEventClose
    activeBestProgress := math.max(activeBestProgress, favorable / safeAtr)
    activeWorstAdverse := math.max(activeWorstAdverse, adverse / safeAtr)
    if barsElapsed == 1 and not activeNextBarLocked
        float nextProgress = activeDir == 1 ? close - activeEventClose : activeEventClose - close
        activeNextBarScore := f_clamp(nextProgress / (safeAtr * 0.55) * 100.0, 0.0, 100.0)
        activeNextBarLocked := true
    bool invalidated = activeDir == 1 ? close < activeInvalidation : close > activeInvalidation
    float progressScore = f_clamp(activeBestProgress / math.max(targetAtrMultiple, 0.25) * 100.0, 0.0, 100.0)
    float defenseScore = invalidated ? 0.0 : f_clamp(100.0 - activeWorstAdverse / math.max(invalidationBufferAtr + zoneWidthAtr, 0.10) * 38.0, 0.0, 100.0)
    float timeDecay = f_clamp(100.0 - (barsElapsed / math.max(trackBars, 1.0)) * 42.0, 25.0, 100.0)
    activeFollowScore := f_clamp(activeReactionScore * 0.24 + progressScore * 0.28 + activeNextBarScore * 0.18 + activeVolumeScore * 0.12 + defenseScore * 0.12 + timeDecay * 0.06, 0.0, 100.0)
    bool readyToContinue = not invalidated and activeFollowScore >= minimumScore and progressScore >= 48.0 and barsElapsed > 0
    bool expiredWeak = barsElapsed >= trackBars and activeFollowScore < minimumScore and not invalidated
    if invalidated and activeOutcome == 0
        failureSignal := true
        activeFailed := true
        activeOutcome := 2
        activeState := "Failed Reaction"
        activeAction := "Reject setup"
    else if readyToContinue and activeOutcome == 0
        continuationSignal := true
        activeContinued := true
        activeOutcome := 1
        activeState := activeDir == 1 ? "Bull Follow-Through" : "Bear Follow-Through"
        activeAction := "Manage follow-through"
    else if expiredWeak and activeOutcome == 0
        activeOutcome := 3
        activeState := "No Follow-Through"
        activeAction := "Stand aside"
    else if activeOutcome == 0
        activeState := activeDir == 1 ? "Bull Reaction Watch" : "Bear Reaction Watch"
        activeAction := "Wait for progress"
    if not na(activeBox)
        int dynamicRight = math.min(bar_index + visualZoneRightExtension, activeEventBar + trackBars + visualZoneRightExtension)
        box.set_right(activeBox, dynamicRight)
        box.set_bgcolor(activeBox, color.new(f_score_color(activeFollowScore, activeDir), activeFailed ? 93 : 90))
        box.set_border_color(activeBox, color.new(f_score_color(activeFollowScore, activeDir), activeFailed ? 35 : 45))
    if not na(activeZoneLabel)
        int labelRight = not na(activeBox) ? box.get_right(activeBox) : activeEventBar + trackBars + visualZoneRightExtension
        int midX = activeEventBar + int(math.floor((labelRight - activeEventBar) * zoneLabelAnchor))
        color zoneBadgeCol = f_score_color(activeFollowScore, activeDir)
        label.set_x(activeZoneLabel, midX)
        label.set_y(activeZoneLabel, (activeZoneTop + activeZoneBottom) / 2.0)
        string zoneState = activeOutcome == 1 ? "CONTINUE" : activeOutcome == 2 ? "FAILED" : activeOutcome == 3 ? "EXPIRED" : "WATCH"
        label.set_text(activeZoneLabel, (activeDir == 1 ? "BULL " : "BEAR ") + zoneState + "\nQ" + f_score_text(activeFollowScore) + " | AGE " + str.tostring(math.min(barsElapsed, trackBars)) + "/" + str.tostring(trackBars))
        label.set_color(activeZoneLabel, color.new(zoneBadgeCol, 18))
        label.set_textcolor(activeZoneLabel, f_text_on(zoneBadgeCol))
        label.set_size(activeZoneLabel, f_label_size(labelSizeInput))
    if not na(activeTrackLine)
        line.set_xy2(activeTrackLine, bar_index, close)
        line.set_color(activeTrackLine, color.new(f_score_color(activeFollowScore, activeDir), 0))
    int guideRight = activeEventBar + trackBars + visualZoneRightExtension
    if not na(activeInvalidationLabel)
        label.set_xy(activeInvalidationLabel, guideRight, activeInvalidation)
        label.set_text(activeInvalidationLabel, "INVALID " + f_price_text(activeInvalidation))
        label.set_size(activeInvalidationLabel, f_label_size(labelSizeInput))
    if not na(activeTargetLabel)
        label.set_xy(activeTargetLabel, guideRight, activeTarget)
        label.set_text(activeTargetLabel, "TARGET " + f_price_text(activeTarget))
        label.set_size(activeTargetLabel, f_label_size(labelSizeInput))
    if continuationSignal and showLabels
        color ftCol = f_score_color(activeFollowScore, activeDir)
        float labelY = activeDir == 1 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
        label ftLabel = label.new(bar_index, labelY, (activeDir == 1 ? "BULL" : "BEAR") + " FT | Q" + f_score_text(activeFollowScore) + " | CONTINUE", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(ftCol, 0), textcolor = f_text_on(ftCol), size = f_label_size(labelSizeInput))
        array.push(eventLabels, ftLabel)
        f_prune_labels(eventLabels, maxVisibleLabels)

// -------------------------------------------------
// Follow-Through-Rate Proof
// On a fresh reaction, a win is recorded when price reaches one risk-distance in
// the reaction direction (a balanced one-risk target) before closing beyond the
// invalidation edge. Samples that resolve neither inside the proof window are
// left unresolved and uncounted. Updated only on confirmed bars so the statistic
// does not repaint.
// -------------------------------------------------
var int   proofWins    = 0
var int   proofTotal   = 0
var bool  proofPending = false
var int   proofDir     = 0
var float proofTarget  = na
var float proofStop    = na
var int   proofStartBar = na
var int   proofArmedBar = na

if barstate.isconfirmed
    if proofPending
        favHit  = proofDir == 1 ? high >= proofTarget : low <= proofTarget
        stopHit = proofDir == 1 ? close < proofStop : close > proofStop
        expired = bar_index - proofStartBar >= proofWindowBars
        if favHit and stopHit
            proofTotal += 1
            proofPending := false
        else if favHit
            proofWins += 1
            proofTotal += 1
            proofPending := false
        else if stopHit
            proofTotal += 1
            proofPending := false
        else if expired
            proofPending := false
    if activeDir != 0 and activeEventBar == bar_index and proofArmedBar != bar_index and not na(activeInvalidation) and not proofPending
        riskDist = math.max(math.abs(activeEventClose - activeInvalidation), safeAtr * 0.10)
        proofDir := activeDir
        proofTarget := activeEventClose + activeDir * riskDist
        proofStop := activeInvalidation
        proofStartBar := bar_index
        proofPending := true
        proofArmedBar := bar_index

float proofRate = proofTotal > 0 ? proofWins / proofTotal * 100.0 : na

// -------------------------------------------------
// Markers And Alerts
// -------------------------------------------------
plotshape(showMarkers and continuationSignal and activeDir == 1, title = "Bull Follow-Through Marker", style = shape.triangleup, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny, text = "FT")
plotshape(showMarkers and continuationSignal and activeDir == -1, title = "Bear Follow-Through Marker", style = shape.triangledown, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny, text = "FT")
plotshape(showMarkers and showFailedMarkers and failureSignal, title = "Failed Reaction Marker", style = shape.xcross, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)

alertcondition(newReaction and newDir == 1, "New Bull Reaction Window", "Reaction Follow-Through Planner detected a new bullish reaction window.")
alertcondition(newReaction and newDir == -1, "New Bear Reaction Window", "Reaction Follow-Through Planner detected a new bearish reaction window.")
alertcondition(continuationSignal and activeDir == 1, "Bull Follow-Through Ready", "Bullish reaction follow-through reached the planner threshold.")
alertcondition(continuationSignal and activeDir == -1, "Bear Follow-Through Ready", "Bearish reaction follow-through reached the planner threshold.")
alertcondition(failureSignal, "Reaction Failed", "The active reaction closed beyond its invalidation edge.")

// -------------------------------------------------
// Panel
// -------------------------------------------------
isLightPanel = panelThemeInput == "Clean Light"
isSlatePanel = panelThemeInput == "Slate"
pBg = isLightPanel ? color.rgb(248, 250, 252) : isSlatePanel ? color.rgb(30, 41, 59) : panelBg
pBorder = isLightPanel ? color.rgb(203, 213, 225) : panelBorder
pLabel = isLightPanel ? color.rgb(71, 85, 105) : panelLabelCol
pValue = isLightPanel ? color.rgb(15, 23, 42) : panelValueCol
pMuted = isLightPanel ? color.rgb(100, 116, 139) : panelLabelCol
panelSize = f_panel_size(panelFontSizeInput)

var table plannerPanel = table.new(f_panel_position(panelPositionInput), 2, 7, bgcolor = pBg, border_color = pBorder, border_width = 1)

roomAtr = activeDir == 1 ? (activeTarget - close) / safeAtr : activeDir == -1 ? (close - activeTarget) / safeAtr : na
roomText = activeDir == 0 or na(roomAtr) ? "n/a" : str.tostring(math.max(roomAtr, 0.0), "#.##") + " ATR"
reactionText = activeDir == 0 ? "Waiting" : f_score_tier(activeReactionScore) + " / " + f_score_text(activeReactionScore)
followText = activeDir == 0 ? "No active window" : f_score_tier(activeFollowScore) + " / " + f_score_text(activeFollowScore) + " - " + activeState
invalidationText = activeDir == 0 ? "n/a" : f_price_text(activeInvalidation)
actionText = activeDir == 0 ? "Wait for reaction" : activeAction
stateColor = activeDir == 0 ? pValue : f_state_color(activeState, activeDir)
proofText = proofTotal > 0 ? str.tostring(math.round(nz(proofRate, 0.0))) + "% (" + str.tostring(proofTotal) + ")" : "Building"
proofCol = na(proofRate) ? pMuted : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

if barstate.islast
    table.set_position(plannerPanel, f_panel_position(panelPositionInput))
    table.clear(plannerPanel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(plannerPanel, 0, 0, 1, 0)
        table.cell(plannerPanel, 0, 0, "AG Pro Reaction Follow-Through Planner", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        f_panel_row(plannerPanel, 1, "Reaction Strength", reactionText, activeDir == 0 ? pValue : f_score_color(activeReactionScore, activeDir), pBg, pLabel, panelSize)
        f_panel_row(plannerPanel, 2, "Follow-Through", followText, stateColor, pBg, pLabel, panelSize)
        f_panel_row(plannerPanel, 3, "Invalidation", invalidationText, activeDir == 0 ? pMuted : bearColor, pBg, pLabel, panelSize)
        f_panel_row(plannerPanel, 4, "Room", roomText, activeDir == 0 ? pMuted : accentColor, pBg, pLabel, panelSize)
        f_panel_row(plannerPanel, 5, "Follow-Through Rate", proofText, proofCol, pBg, pLabel, panelSize)
        f_panel_row(plannerPanel, 6, "Action", actionText, stateColor, pBg, pLabel, panelSize)
````
