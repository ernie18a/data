# Effort vs Result Reaction Map [AGPro Series]

- url: https://www.tradingview.com/script/HeDQBrkV-Effort-vs-Result-Reaction-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;6e65e83dfa77436a84434b756c3f54ef
- version: 4.0

## Description

Effort vs Result Reaction Map [AGPro Series]

⚖️ OVERVIEW
Effort vs Result Reaction Map is a premium volume-price reaction indicator built around one of the most practical ideas from Wyckoff and Volume Spread Analysis: effort only matters when it is compared with result.

Many volume tools stop at identifying high volume, relative volume spikes, wide candles or bullish/bearish pressure. This script goes further by asking a more selective question:

Is the market actually getting progress for the effort being spent?

The indicator compares normalized participation effort, ATR-adjusted price progress, close-location quality, directional efficiency and wick behavior. The output is a clean reaction map that highlights two specific event families:

• High effort + poor result
• Low effort + strong result

That makes the script different from a simple volume spike detector, a generic pressure map, a support/resistance drawer or a full Wyckoff phase tool. It is focused on the moment where participation and progress become meaningfully disconnected.

🔬 CORE IDEA
Effort is built from two dimensions:

• Relative volume versus a rolling participation baseline
• Candle spread normalized by ATR

Result is built from:

• Price progress over a configurable number of bars
• Close-location quality in the direction of progress
• ATR-normalized movement quality

Efficiency measures the relationship between those two sides. A bar can show strong volume, but if price does not achieve directional progress, the script treats that as a potential failed-progress reaction. A bar can also move cleanly with surprisingly low effort, which can reveal ease of movement and directional acceptance.

🧭 WHAT MAKES IT DIFFERENT
Most public volume indicators answer one of these questions:

• Is volume high?
• Is relative volume expanding?
• Is price near a volume shelf?
• Is pressure bullish or bearish?
• Is a Wyckoff phase forming?

Effort vs Result Reaction Map answers a narrower and more actionable chart-reading question:

Did the market receive enough result for the effort it spent?

This keeps the tool focused and prevents it from overlapping with broader volume profile, relative volume, delta, session reaction or support/resistance scripts. It does not try to label accumulation, distribution, spring, upthrust or phase structure. Instead, it turns effort/result imbalance into a compact reaction framework that can sit cleanly on any chart.

🎯 SIGNAL TYPES
High Effort + Poor Result
This event appears when participation and spread are unusually active but price progress remains weak. The script studies wick behavior and candle direction to estimate which side attempted progress and failed. The label then expresses the opposite reaction bias:

• Failed Bull Progress
• Failed Bear Progress

Low Effort + Strong Result
This event appears when price makes strong directional progress while effort remains unusually light. This can suggest ease of movement, cleaner directional travel or a lack of opposing participation in that moment:

• Low Effort Rise
• Low Effort Drop

Each event must pass a confidence threshold and a visual cooldown before it appears on the chart. This keeps the output selective and suitable for publication-quality screenshots.

🟦 REACTION BOXES
The script can draw rectangular reaction boxes around qualified events. These boxes are not generic support and resistance zones. They are event-native reaction ranges created only when the effort/result engine finds a meaningful imbalance.

Reaction boxes help the user track whether the market later respects, revisits or ignores the area where effort and result became disconnected. The box length, padding, transparency and minimum confidence are configurable.

This gives the chart more structure without turning the indicator into another broad zone tool.

📊 PANEL
The compact panel reports:

• Effort
• Result
• Efficiency
• Reaction Bias
• Confidence

The first panel row follows the AGPro standard format: one merged blue header row containing only the script name. Panel location, panel theme and panel font size are all configurable from the settings.

⚙️ KEY SETTINGS
Engine
• Effort Baseline Length controls the volume normalization baseline.
• ATR Normalization Length controls spread, progress and object spacing.
• Result Progress Bars defines how far back the result comparison looks.
• Volume Weight In Effort balances relative volume versus candle spread.

Reaction Thresholds
• High Effort Threshold defines unusual participation.
• Low Effort Threshold defines unusually light participation.
• Poor Result Threshold filters failed-progress events.
• Strong Result Threshold filters low-effort strong-result events.
• Minimum Event Confidence controls final event selectivity.
• Visual Cooldown Bars keeps labels and boxes from clustering.

Reaction Boxes
• Box Minimum Confidence keeps boxes more selective than labels if desired.
• Box Extend Right Bars controls how long reaction ranges remain visible.
• Box ATR Padding gives boxes a clean margin around the event candle.
• Box Transparency controls chart softness.

Labels And Markers
• Event labels can be enabled or disabled.
• Label confidence can be shown or hidden; it is hidden by default for cleaner screenshots.
• Label font size defaults to Normal.
• Label offset uses ATR so labels stay away from candle bodies.
• Directional markers provide a minimal visual cue for qualified reactions.

🧠 HOW TO USE
Apply the script to a liquid market and start with the default settings.

Watch for high-effort poor-result labels when volume and spread expand but the market fails to make clean progress. These areas can be useful for studying absorption, failed pushes and short-term reaction shifts.

Watch for low-effort strong-result labels when price moves cleanly without requiring heavy participation. These events can help identify easier directional travel and cleaner movement conditions.

Use the reaction boxes as context zones created by the event itself. They are best read together with structure, trend context, liquidity areas, session behavior or your own discretionary framework.

✅ BEST USE CASES
• Spotting failed directional progress after heavy participation
• Comparing volume effort with actual price result
• Identifying clean movement when result expands on lighter effort
• Studying short-term absorption and efficiency shifts
• Adding Wyckoff/VSA-inspired logic without using a full phase detector
• Keeping a premium chart layout with selective labels and contextual boxes

🧩 LIMITATIONS AND TRANSPARENCY
Effort vs Result Reaction Map is an analytical indicator, not a strategy.

It does not classify full Wyckoff phases, does not draw generic support/resistance, and does not attempt to forecast future price. Its purpose is to organize observed effort/result behavior into a clean visual framework.

Event quality depends on symbol behavior, timeframe, volume reliability and selected thresholds. Markets with unreliable volume data may need more conservative settings.

The script is designed to be selective by default, but users can tune thresholds, confidence, cooldown, label size, panel theme and reaction box visibility to match their preferred chart style.

## Source Code

````pine
// -------------------------------------------------
// Effort vs Result Reaction Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Effort vs Result Reaction Map converts Wyckoff and VSA-inspired volume price analysis
// into a compact reaction framework. It compares participation effort, price result,
// directional efficiency, failed progress and low-effort movement to highlight where
// volume is not translating into clean progress or where price advances with unusual ease.
// Version 1.3 adds confirmed event handling, event-locked proof distance and one
// current reaction range with a centered context badge for cleaner chart review.
// -------------------------------------------------

//@version=6
indicator("Effort vs Result Reaction Map [AGPro Series]",
     shorttitle = "AG Pro EVR",
     overlay = true,
     max_labels_count = 40,
     max_boxes_count = 2,
     max_lines_count = 4)

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
ttEffortLen       = "Length used to normalize volume participation. Higher values create a slower effort baseline; lower values react faster to recent volume changes."
ttConfirm         = "When enabled, effort/result events, chart objects and alerts are accepted only after the bar closes. This is the publication-safe default."
ttAtrLen          = "ATR length used to normalize candle spread, price progress, label offsets and reaction box padding."
ttProgressBars    = "Number of bars used to measure directional result. The script compares the current close with the close this many bars ago."
ttVolumeWeight    = "Weight assigned to relative volume inside the effort score. The remaining weight is assigned to ATR-normalized candle spread."
ttHighEffort      = "Minimum normalized effort value required to classify a bar as high effort. Values above this threshold mean participation and spread are unusually active."
ttLowEffort       = "Maximum normalized effort value allowed for low-effort strong-result events. Values below this threshold suggest price moved with unusually light effort."
ttPoorResult      = "Maximum result score allowed for high-effort poor-result events. Lower values demand weaker follow-through before a failed-progress event is accepted."
ttStrongResult    = "Minimum result score required for low-effort strong-result events. Higher values demand cleaner directional progress and stronger close location."
ttStrongProgress  = "ATR-normalized progress level that maps to a full progress score. Increase it to require larger movement before result quality becomes strong."
ttMinConfidence   = "Minimum confidence required before labels, markers and reaction boxes are drawn. Higher values keep only the cleanest effort/result imbalances."
ttCooldownBars    = "Minimum bars between accepted visual events. This controls label density and keeps the chart from becoming crowded."
ttReactionWindow  = "Number of bars a qualified event has to follow through in its reaction-bias direction within, for the Reaction Rate proof. It only measures historical follow-through and is not a forecast."
ttReactionTarget  = "ATR distance price must close in the reaction-bias direction before the locked adverse distance is reached. ATR is captured on the qualified event bar."
ttShowBoxes       = "Shows one current reaction range for the latest qualified effort/result event. A newer event replaces the prior range, preventing historical box overlap."
ttBoxMinConf      = "Minimum event confidence required to draw a reaction box. This can be higher than the label threshold to keep boxes more selective."
ttBoxExtend       = "Number of bars the current reaction range remains projected to the right. The range and its centered badge are removed after this review window."
ttBoxPad          = "Additional ATR padding applied above and below each reaction box so the box surrounds the full reaction range cleanly."
ttBoxTransp       = "Transparency for reaction boxes. Higher values make boxes softer and keep candles easier to read."
ttShowLabels      = "Show event labels for qualified failed-progress and low-effort strong-result reactions."
ttMaxLabels       = "Maximum number of event labels retained on the chart. Older labels are deleted first to preserve performance and visual clarity."
ttLabelOffset     = "ATR-based vertical distance used to place labels away from candle bodies and wicks."
ttLabelTransp     = "Transparency for label backgrounds. Higher values create a softer label while preserving the directional text."
ttShowLabelScore  = "Show confidence values directly inside event labels. Disabled by default to keep publication screenshots cleaner and more compact."
ttLabelSize       = "Font size for event labels. Normal is the default publication setting for balanced readability."
ttShowMarkers     = "Show small directional markers for qualified reaction events. Markers provide a clean visual cue even when labels are filtered."
ttShowPanel       = "Show or hide the compact status panel."
ttPanelPosition   = "Panel anchor location on the chart. Use this to keep the dashboard away from the most active price area."
ttPanelTheme      = "Panel color theme. Elite Dark follows the AGPro dark dashboard style; Clean Light is designed for light chart backgrounds."
ttPanelFont       = "Font size for panel text. Normal is the default publication setting for balanced readability."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Engine"
confirmOnClose = input.bool(true, "Confirm Events On Bar Close", group = groupEngine, tooltip = ttConfirm)
effortLen = input.int(34, "Effort Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = ttEffortLen)
atrLen = input.int(14, "ATR Normalization Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
progressBars = input.int(3, "Result Progress Bars", minval = 1, maxval = 20, group = groupEngine, tooltip = ttProgressBars)
volumeWeight = input.float(0.65, "Volume Weight In Effort", minval = 0.10, maxval = 0.90, step = 0.05, group = groupEngine, tooltip = ttVolumeWeight)

groupThresholds = "Reaction Thresholds"
highEffortThreshold = input.float(1.55, "High Effort Threshold", minval = 0.80, maxval = 4.00, step = 0.05, group = groupThresholds, tooltip = ttHighEffort)
lowEffortThreshold = input.float(0.78, "Low Effort Threshold", minval = 0.20, maxval = 1.50, step = 0.05, group = groupThresholds, tooltip = ttLowEffort)
poorResultThreshold = input.float(38.0, "Poor Result Threshold", minval = 10.0, maxval = 70.0, step = 1.0, group = groupThresholds, tooltip = ttPoorResult)
strongResultThreshold = input.float(72.0, "Strong Result Threshold", minval = 40.0, maxval = 95.0, step = 1.0, group = groupThresholds, tooltip = ttStrongResult)
strongProgressAtr = input.float(1.15, "Strong Progress ATR Multiple", minval = 0.25, maxval = 4.00, step = 0.05, group = groupThresholds, tooltip = ttStrongProgress)
minConfidence = input.float(76.0, "Minimum Event Confidence", minval = 35.0, maxval = 95.0, step = 1.0, group = groupThresholds, tooltip = ttMinConfidence)
cooldownBars = input.int(40, "Visual Cooldown Bars", minval = 0, maxval = 120, group = groupThresholds, tooltip = ttCooldownBars)
reactionWindow = input.int(14, "Reaction Proof Window (bars)", minval = 4, maxval = 200, group = groupThresholds, tooltip = ttReactionWindow)
reactionTargetAtr = input.float(0.75, "Reaction Proof Distance ATR", minval = 0.20, maxval = 3.00, step = 0.05, group = groupThresholds, tooltip = ttReactionTarget)

groupBoxes = "Reaction Boxes"
showBoxes = input.bool(true, "Show Reaction Boxes", group = groupBoxes, tooltip = ttShowBoxes)
boxMinConfidence = input.float(80.0, "Box Minimum Confidence", minval = 40.0, maxval = 98.0, step = 1.0, group = groupBoxes, tooltip = ttBoxMinConf)
boxExtendBars = input.int(32, "Box Extend Right Bars", minval = 8, maxval = 120, group = groupBoxes, tooltip = ttBoxExtend)
boxAtrPad = input.float(0.10, "Box ATR Padding", minval = 0.00, maxval = 0.80, step = 0.05, group = groupBoxes, tooltip = ttBoxPad)
boxTransparency = input.int(88, "Box Transparency", minval = 50, maxval = 96, group = groupBoxes, tooltip = ttBoxTransp)

groupLabels = "Labels And Markers"
showLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttShowLabels)
showLabelConfidence = input.bool(true, "Show Label Confidence", group = groupLabels, tooltip = ttShowLabelScore)
maxEventLabels = input.int(12, "Max Visible Labels", minval = 5, maxval = 40, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.15, "Label Offset ATR", minval = 0.10, maxval = 2.50, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
labelBackgroundTransparency = input.int(10, "Label Background Transparency", minval = 0, maxval = 75, group = groupLabels, tooltip = ttLabelTransp)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)
showMarkers = input.bool(false, "Show Directional Markers", group = groupLabels, tooltip = ttShowMarkers)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelPosition)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_label_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_size(string sizeText) =>
    switch sizeText
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_text_on(_bg) =>
    r = color.r(_bg) / 255.0
    g = color.g(_bg) / 255.0
    b = color.b(_bg) / 255.0
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    luminance > 0.45 ? color.rgb(15, 23, 42) : color.white

f_state_on_panel(bool isLight, color _state) =>
    if isLight
        _state == bullColor ? color.rgb(13, 118, 99) : _state == bearColor ? color.rgb(178, 44, 112) : _state == neutralColor ? color.rgb(133, 77, 14) : _state == accentColor ? color.rgb(67, 56, 202) : _state
    else
        _state

f_trim_labels(array<label> labels, int maxCount) =>
    int labelCount = array.size(labels)
    if labelCount > maxCount
        int removeCount = labelCount - maxCount
        for idx = 0 to removeCount - 1
            label oldLabel = array.shift(labels)
            label.delete(oldLabel)

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
float atr = ta.atr(atrLen)
float barRange = math.max(high - low, syminfo.mintick)
float trueRange = ta.tr(true)
float safeAtr = math.max(nz(atr, trueRange), syminfo.mintick)
float safeVolume = nz(volume, 0.0)
float avgVolume = ta.sma(safeVolume, effortLen)
float relVolume = avgVolume > 0.0 ? safeVolume / avgVolume : 1.0
float spreadAtr = safeAtr > 0.0 ? trueRange / safeAtr : 0.0
float effortRaw = relVolume * volumeWeight + spreadAtr * (1.0 - volumeWeight)
float effortScore = f_clamp(effortRaw / highEffortThreshold * 100.0, 0.0, 150.0)

bool hasProgressHistory = not na(close[progressBars])
float rawProgress = hasProgressHistory ? math.abs(close - close[progressBars]) / safeAtr : 0.0
int progressDir = close >= open ? 1 : -1
if hasProgressHistory
    if close > close[progressBars]
        progressDir := 1
    else if close < close[progressBars]
        progressDir := -1
float closeLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
float directionalCloseScore = progressDir == 1 ? closeLocation * 100.0 : (1.0 - closeLocation) * 100.0
float progressScore = f_clamp(rawProgress / strongProgressAtr * 100.0, 0.0, 130.0)
float resultScore = f_clamp(progressScore * 0.62 + directionalCloseScore * 0.38, 0.0, 100.0)
float efficiencyScore = effortScore > 0.0 ? f_clamp(resultScore / effortScore * 100.0, 0.0, 220.0) : 0.0

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float wickBalance = barRange > 0.0 ? (upperWick - lowerWick) / barRange : 0.0
int candleDir = close > open ? 1 : close < open ? -1 : progressDir
int attemptDir = candleDir
if math.abs(wickBalance) >= 0.18
    attemptDir := wickBalance > 0.0 ? 1 : -1
int failedBiasDir = -attemptDir

bool enoughHistory = bar_index > math.max(effortLen, atrLen) + progressBars
bool highEffort = effortRaw >= highEffortThreshold
bool lowEffort = effortRaw <= lowEffortThreshold
bool poorResult = resultScore <= poorResultThreshold
bool strongResult = resultScore >= strongResultThreshold
bool failedProgress = enoughHistory and highEffort and poorResult
bool lowEffortProgress = enoughHistory and lowEffort and strongResult

float failedConfidence = f_clamp(effortScore * 0.50 + (100.0 - resultScore) * 0.35 + math.abs(wickBalance) * 100.0 * 0.15, 0.0, 100.0)
float easeConfidence = f_clamp((100.0 - effortScore) * 0.35 + resultScore * 0.50 + directionalCloseScore * 0.15, 0.0, 100.0)
int eventBiasDir = failedProgress ? failedBiasDir : lowEffortProgress ? progressDir : 0
float eventConfidence = failedProgress ? failedConfidence : lowEffortProgress ? easeConfidence : 0.0
float liveConfidence = eventConfidence > 0.0 ? eventConfidence : f_clamp(math.abs(resultScore - effortScore) * 0.45 + math.abs(efficiencyScore - 100.0) * 0.20, 0.0, 100.0)
float biasScore = eventBiasDir * eventConfidence
string eventName = failedProgress ? (eventBiasDir > 0 ? "BEAR FAIL" : "BULL FAIL") : lowEffortProgress ? (eventBiasDir > 0 ? "EASE UP" : "EASE DOWN") : "BALANCED"

var int lastEventBar = na
var int lastAcceptedDir = 0
var float lastAcceptedConfidence = na
var string lastAcceptedName = ""
bool cooldownReady = na(lastEventBar) or bar_index - lastEventBar >= cooldownBars
bool confirmedGate = not confirmOnClose or barstate.isconfirmed
bool qualifiedEvent = (failedProgress or lowEffortProgress) and eventConfidence >= minConfidence and cooldownReady and confirmedGate

if qualifiedEvent
    lastEventBar := bar_index
    lastAcceptedDir := eventBiasDir
    lastAcceptedConfidence := eventConfidence
    lastAcceptedName := eventName

// -------------------------------------------------
// Reaction follow-through proof (Confirm Rate)
// -------------------------------------------------
// When a qualified event fires, does price follow through 0.75 ATR in its
// reaction-bias direction before moving 0.75 ATR against it? Counted once per
// event. An adverse move first, or a window expiry with no follow-through, is
// treated as not-followed (conservative).
bool eventThisBar = qualifiedEvent

var int   rrTotal = 0
var int   rrWon    = 0
var bool  rrPend    = false
var int   rrDir      = 0
var float rrAnchor    = na
var float rrMargin    = na
var int   rrLeft       = 0

if barstate.isconfirmed
    if rrPend and not na(rrAnchor)
        bool fav = rrDir > 0 ? close >= rrAnchor + rrMargin : close <= rrAnchor - rrMargin
        bool adv = rrDir > 0 ? close <= rrAnchor - rrMargin : close >= rrAnchor + rrMargin
        if adv
            rrTotal += 1
            rrPend := false
        else if fav
            rrTotal += 1
            rrWon += 1
            rrPend := false
        else
            rrLeft -= 1
            if rrLeft <= 0
                rrTotal += 1
                rrPend := false
    if eventThisBar and eventBiasDir != 0 and not rrPend
        rrDir := eventBiasDir
        rrAnchor := close
        rrMargin := safeAtr * reactionTargetAtr
        rrLeft := reactionWindow
        rrPend := true

float rrRate = rrTotal > 0 ? rrWon / rrTotal * 100.0 : na
string reactionRead = rrTotal > 0 ? str.tostring(math.round(rrRate)) + "% (" + str.tostring(rrTotal) + ")" : "Building"

// -------------------------------------------------
// Visual objects
// -------------------------------------------------
labelSize = f_label_size(labelSizeInput)
eventColor = eventBiasDir > 0 ? bullColor : eventBiasDir < 0 ? bearColor : neutralColor

var array<label> eventLabels = array.new_label()
var box activeReactionBox = na
var label activeReactionBadge = na
var int activeReactionStart = na

if not na(activeReactionStart) and bar_index - activeReactionStart > boxExtendBars
    if not na(activeReactionBox)
        box.delete(activeReactionBox)
    if not na(activeReactionBadge)
        label.delete(activeReactionBadge)
    activeReactionBox := na
    activeReactionBadge := na
    activeReactionStart := na

if qualifiedEvent
    if not na(activeReactionBox)
        box.delete(activeReactionBox)
    if not na(activeReactionBadge)
        label.delete(activeReactionBadge)
    activeReactionBox := na
    activeReactionBadge := na
    activeReactionStart := na

if qualifiedEvent and showBoxes and eventConfidence >= boxMinConfidence
    float pad = safeAtr * boxAtrPad
    int rightEdge = bar_index + boxExtendBars
    color boxColor = color.new(eventColor, boxTransparency)
    color borderColor = color.new(eventColor, math.max(boxTransparency - 18, 0))
    activeReactionBox := box.new(left = bar_index, top = high + pad, right = rightEdge, bottom = low - pad, xloc = xloc.bar_index, bgcolor = boxColor, border_color = borderColor, border_width = 1)
    activeReactionStart := bar_index
    int badgeX = bar_index + int(math.round(boxExtendBars * 0.68))
    float badgeY = (high + pad + low - pad) * 0.5
    string badgeText = eventName + " | C" + str.tostring(eventConfidence, "#") + " | E" + str.tostring(effortScore, "#") + "/R" + str.tostring(resultScore, "#")
    activeReactionBadge := label.new(x = badgeX, y = badgeY, text = badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(eventColor, 0), textcolor = f_text_on(eventColor), size = labelSize)

if qualifiedEvent and showLabels
    float labelY = eventBiasDir > 0 ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    string labelText = showLabelConfidence ? eventName + " | C" + str.tostring(eventConfidence, "#") : eventName
    label eventLabel = label.new(x = bar_index, y = labelY, text = labelText, xloc = xloc.bar_index, style = eventBiasDir > 0 ? label.style_label_up : label.style_label_down, color = color.new(eventColor, labelBackgroundTransparency), textcolor = f_text_on(eventColor), size = labelSize)
    array.push(eventLabels, eventLabel)
    f_trim_labels(eventLabels, maxEventLabels)

plotshape(showMarkers and qualifiedEvent and eventBiasDir > 0, title = "Bullish Reaction Marker", style = shape.triangleup, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(showMarkers and qualifiedEvent and eventBiasDir < 0, title = "Bearish Reaction Marker", style = shape.triangledown, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)

plot(effortScore, title = "Effort Score", color = accentColor, display = display.data_window)
plot(resultScore, title = "Result Score", color = neutralColor, display = display.data_window)
plot(efficiencyScore, title = "Efficiency Score", color = bullColor, display = display.data_window)
plot(biasScore, title = "Reaction Bias Score", color = eventColor, display = display.data_window)
plot(liveConfidence, title = "Reaction Confidence", color = eventColor, display = display.data_window)
plot(rrRate, title = "Reaction Follow Rate", color = bullColor, display = display.data_window)

alertcondition(qualifiedEvent and eventBiasDir > 0, title = "Bullish Effort Result Reaction", message = "Effort vs Result Reaction Map: bullish reaction bias detected.")
alertcondition(qualifiedEvent and eventBiasDir < 0, title = "Bearish Effort Result Reaction", message = "Effort vs Result Reaction Map: bearish reaction bias detected.")

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelTextSize = f_panel_size(panelFontSizeInput)
bool lightPanel = panelThemeInput == "Clean Light"
color activePanelBg = lightPanel ? color.rgb(248, 250, 252) : panelBg
color activePanelBorder = lightPanel ? color.rgb(203, 213, 225) : panelBorder
color activeLabelCol = lightPanel ? color.rgb(71, 85, 105) : panelLabelCol
color activeValueCol = lightPanel ? color.rgb(15, 23, 42) : panelValueCol
color mutedRowBg = lightPanel ? color.rgb(226, 232, 240) : color.rgb(30, 41, 59)

string effortState = highEffort ? "High" : lowEffort ? "Low" : "Normal"
string resultState = poorResult ? "Poor" : strongResult ? "Strong" : "Balanced"
string efficiencyState = efficiencyScore >= 125.0 ? "Efficient" : efficiencyScore <= 70.0 ? "Inefficient" : "Matched"
bool recentAccepted = not na(lastEventBar) and bar_index - lastEventBar <= boxExtendBars
int panelBiasDir = recentAccepted ? lastAcceptedDir : 0
float panelConfidence = recentAccepted ? lastAcceptedConfidence : liveConfidence
string biasText = panelBiasDir > 0 ? "Bullish / " + lastAcceptedName : panelBiasDir < 0 ? "Bearish / " + lastAcceptedName : "Neutral"
string actionText = recentAccepted ? "Review " + lastAcceptedName : "Wait for imbalance"
color effortCol = f_state_on_panel(lightPanel, highEffort ? accentColor : lowEffort ? neutralColor : activeValueCol)
color resultCol = f_state_on_panel(lightPanel, strongResult ? bullColor : poorResult ? bearColor : activeValueCol)
color efficiencyCol = f_state_on_panel(lightPanel, efficiencyScore >= 125.0 ? bullColor : efficiencyScore <= 70.0 ? bearColor : neutralColor)
color biasCol = f_state_on_panel(lightPanel, panelBiasDir > 0 ? bullColor : panelBiasDir < 0 ? bearColor : neutralColor)
color actionCol = f_state_on_panel(lightPanel, panelBiasDir > 0 ? bullColor : panelBiasDir < 0 ? bearColor : neutralColor)
color rateBaseCol = na(rrRate) ? activeValueCol : rrRate >= 60.0 ? bullColor : rrRate >= 45.0 ? neutralColor : bearColor
color rateCol = f_state_on_panel(lightPanel, rateBaseCol)

var table panel = table.new(f_position(panelPositionInput), 2, 8, bgcolor = activePanelBg, frame_color = activePanelBorder, frame_width = 1, border_color = activePanelBorder, border_width = 1)

if barstate.isfirst
    table.cell(panel, 0, 0, "", bgcolor = headerBg)
    table.cell(panel, 1, 0, "", bgcolor = headerBg)
    table.merge_cells(panel, 0, 0, 1, 0)

if barstate.islast
    if showPanel
        table.cell(panel, 0, 0, "AG Pro Effort vs Result Reaction Map", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
        table.cell(panel, 0, 1, "Effort", text_color = activeLabelCol, bgcolor = activePanelBg, text_size = panelTextSize)
        table.cell(panel, 1, 1, str.tostring(effortScore, "#.0") + " / " + effortState, text_color = effortCol, bgcolor = activePanelBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 2, "Result", text_color = activeLabelCol, bgcolor = mutedRowBg, text_size = panelTextSize)
        table.cell(panel, 1, 2, str.tostring(resultScore, "#.0") + " / " + resultState, text_color = resultCol, bgcolor = mutedRowBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 3, "Efficiency", text_color = activeLabelCol, bgcolor = activePanelBg, text_size = panelTextSize)
        table.cell(panel, 1, 3, str.tostring(efficiencyScore, "#.0") + " / " + efficiencyState, text_color = efficiencyCol, bgcolor = activePanelBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 4, "Reaction Bias", text_color = activeLabelCol, bgcolor = mutedRowBg, text_size = panelTextSize)
        table.cell(panel, 1, 4, biasText, text_color = biasCol, bgcolor = mutedRowBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 5, "Action", text_color = activeLabelCol, bgcolor = activePanelBg, text_size = panelTextSize)
        table.cell(panel, 1, 5, actionText, text_color = actionCol, bgcolor = activePanelBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 6, "Reaction Rate", text_color = activeLabelCol, bgcolor = mutedRowBg, text_size = panelTextSize)
        table.cell(panel, 1, 6, reactionRead, text_color = rateCol, bgcolor = mutedRowBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 7, "Confidence", text_color = activeLabelCol, bgcolor = activePanelBg, text_size = panelTextSize)
        table.cell(panel, 1, 7, str.tostring(panelConfidence, "#.0"), text_color = panelConfidence >= minConfidence ? biasCol : activeValueCol, bgcolor = activePanelBg, text_size = panelTextSize, text_halign = text.align_right)
    else
        table.clear(panel, 0, 0, 1, 7)
````
