# AG Pro ATR Compression Map [AGPro Series]

- url: https://www.tradingview.com/script/nCbbDHVD-AG-Pro-ATR-Compression-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;3c700e6fcf374a5690ec42667cca9d3b
- version: 11.0

## Description

[b]AG Pro ATR Compression Map [AGPro Series][/b]

Overview / What it does

AG Pro ATR Compression Map is a chart-first compression analysis tool designed to evaluate how organized a low-volatility phase is and how structurally developed that contraction has become.

Instead of treating every quiet market phase as equally meaningful, the script separates loose and unstable contraction from cleaner, more contained compression conditions. The goal is not to label every narrow range as important, but to provide a structured visual framework for monitoring whether a tightening phase is becoming more coherent and potentially worth closer attention.

The script is built for users who want to read compression quality directly on the chart without relying on overly complex dashboard-style presentation. It highlights active compression zones, assigns a normalized compression score, classifies the current state of contraction, and summarizes the condition through a compact on-chart panel.

This is intended as a context and monitoring tool. It does not attempt to forecast direction, guarantee expansion, or replace execution planning and risk management.

Unique Edge

The main idea behind this script is that low volatility alone is not enough.

Many consolidations look similar at first glance, but their internal structure can be very different. Some are noisy, unstable, and disorderly. Others become progressively tighter, cleaner, and more contained. AG Pro ATR Compression Map is designed to make that distinction clearer.

Its edge is not based on directional prediction. Instead, it evaluates compression quality through a blended framework that combines volatility contraction, local range tightening, internal noise behavior, and containment structure. This allows the script to differentiate between random quiet price action and more organized compression phases.

This also keeps the script distinct from tools that focus on breakout confirmation, retest quality, trend classification, or level-based pressure analysis. Here, the focus is narrower and more specific: measuring the quality of compression itself.

Methodology

The script combines four internal components into a unified compression score:

1) ATR contraction
Measures whether current ATR is compressed relative to its own baseline.

2) Range tightness
Measures whether the recent price range has narrowed compared with a broader reference window.

3) Noise evaluation
Evaluates whether the contraction phase is relatively clean or increasingly disordered. This includes internal bar behavior such as wick activity, directional flipping, and local overlap behavior.

4) Structural containment
Measures whether price is remaining contained within a tighter local area instead of drifting loosely inside a broad consolidation.

These components are normalized and combined into a 0-100 compression score.

The script then classifies the result into four stages:

• Loose
• Building
• Tight
• Mature

This stage logic is designed to help distinguish early contraction from more developed compression conditions. Higher states reflect more structured tightening, but not certainty of resolution.

What the script highlights

• Compression zone
A shaded chart area is displayed when compression conditions are active.

• Compression score
A compact label shows the current normalized compression score.

• State label
The current compression stage is shown directly on the chart.

• Mini panel
A small panel summarizes ATR state, range state, noise condition, containment quality, overall compression score, active state, and current compression window length.

Signals & Alerts

This script includes deterministic alert conditions for:

• Compression Active
Triggered when compression conditions become active according to the script's scoring logic.

• Compression Mature
Triggered when the current state reaches Mature.

• Compression State Change
Triggered when the internal compression state changes.

These alerts are designed to reflect state transitions inside the script's existing framework. They should be interpreted as analytical status changes, not as trade instructions.

Key Inputs

Main controls include:

• ATR Length
• Baseline Length
• Range Window
• Noise Window
• Containment Window
• Compression Threshold
• Mature Threshold

The script also includes display controls for zone visibility, labels, panel position, theme mode, text sizing, and label offset. Advanced options allow stricter filtering and additional sensitivity controls for wick behavior and close-overlap behavior.

How to read it

In practice, the script is most useful when users want to answer questions such as:

• Is this contraction still loose, or is it becoming more organized?
• Is the range tightening in a meaningful way, or is price simply drifting?
• Is the structure relatively clean, or is internal noise increasing?
• Has the compression developed enough to justify closer monitoring?

A higher compression score means the script is detecting tighter and more structured contraction conditions. A lower score suggests that the current quiet phase is still broad, unstable, or underdeveloped.

Best use cases

This script can be useful when monitoring:

• developing consolidations
• low-volatility phases inside broader trends
• pre-expansion observation zones
• structured pauses after directional movement
• markets where users want to distinguish clean compression from random inactivity

It is especially suited for traders who prefer chart-first context tools rather than signal-heavy overlays.

Limitations & Transparency

Compression can remain inactive for long periods, fail to resolve cleanly, or resolve without meaningful follow-through.

A high compression reading does not imply directional certainty, timing certainty, or inevitable expansion. Likewise, a low reading does not mean price cannot move sharply. The script measures structure quality inside contraction conditions. It does not measure certainty.

The output should be used as contextual information alongside price action, market structure, execution rules, and risk management.

What it does not do

This script does not:

• predict breakout direction
• guarantee expansion
• project targets
• replace trade planning
• function as a standalone entry engine

Risk Disclosure

For educational and analytical use only.

## Source Code

````pine
// --------------------------------------------------
// ATR Compression Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.2
//
// ATR Compression Map is a chart-first volatility compression planner
// built to read ATR contraction, range compression, noise quality,
// containment pressure, and expansion readiness inside low-volatility
// market structure. It maps clean compression pockets, release-risk
// shelves, right-side context tags, and a compact decision panel without
// turning volatility contraction into a prediction engine.
// V2.1 adds a confirmation-anchored proof layer (Follow, Hold, React, Flip
// rates) measuring how often pocket releases expanded in the release direction,
// and removes the redundant review row.
// V2.2 separates active and archived pocket hierarchy, centers zone badges,
// and reduces default event and right-edge label density.
// --------------------------------------------------

//@version=6
indicator("ATR Compression Map [AGPro Series]",
     shorttitle = "AG Pro ATR",
     overlay = true,
     max_labels_count = 220,
     max_lines_count = 220,
     max_boxes_count = 120)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_CORE   = "Core Engine"
G_SCORE  = "Scoring"
G_ZONE   = "Compression Pocket"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

atrLen = input.int(14, "ATR Length", minval = 1, group = G_CORE,
     tooltip = "ATR lookback used to measure current volatility. Lower values react faster, while higher values smooth the compression read.")
baselineLen = input.int(50, "Baseline Length", minval = 10, maxval = 300, group = G_CORE,
     tooltip = "Reference window used to normalize current ATR and range behavior against broader conditions.")
rangeWindow = input.int(20, "Range Window", minval = 5, maxval = 200, group = G_CORE,
     tooltip = "Recent structure window used to measure whether price range is contracting or expanding.")
noiseWindow = input.int(10, "Noise Window", minval = 3, maxval = 80, group = G_CORE,
     tooltip = "Window used to evaluate wick behavior, direction flips, and close-to-close noise.")
containmentWindow = input.int(24, "Containment Window", minval = 5, maxval = 200, group = G_CORE,
     tooltip = "Window used to evaluate whether price is clustering inside a contained volatility pocket.")
compressionThreshold = input.float(62.0, "Compression Threshold", minval = 1.0, maxval = 100.0, step = 1.0, group = G_CORE,
     tooltip = "Minimum score required for a qualified compression state.")
matureThreshold = input.float(80.0, "Mature Threshold", minval = 1.0, maxval = 100.0, step = 1.0, group = G_CORE,
     tooltip = "Higher score level required for mature compression when noise and containment also confirm.")
strictMode = input.bool(false, "Strict Mode", group = G_CORE,
     tooltip = "Applies tighter score gates for more selective compression pockets.")

atrWeight = input.float(30.0, "ATR Weight", minval = 0.0, maxval = 100.0, step = 1.0, group = G_SCORE,
     tooltip = "Weight assigned to ATR contraction in the final compression score.")
rangeWeight = input.float(30.0, "Range Weight", minval = 0.0, maxval = 100.0, step = 1.0, group = G_SCORE,
     tooltip = "Weight assigned to recent range contraction in the final compression score.")
noiseWeight = input.float(20.0, "Noise Weight", minval = 0.0, maxval = 100.0, step = 1.0, group = G_SCORE,
     tooltip = "Weight assigned to low-noise behavior, including wick, flip, and close-drift quality.")
containmentWeight = input.float(20.0, "Containment Weight", minval = 0.0, maxval = 100.0, step = 1.0, group = G_SCORE,
     tooltip = "Weight assigned to price clustering and containment quality.")

showPocket = input.bool(true, "Show Compression Pocket", group = G_ZONE,
     tooltip = "Draws the active compression pocket when the structure qualifies as building, tight, or mature.")
showPocketText = input.bool(true, "Show Pocket Badge", group = G_ZONE,
     tooltip = "Places a solid badge at the right edge of the active compression pocket so the structure remains readable on light and dark charts.")
showPocketMidline = input.bool(true, "Show Pocket Midline", group = G_ZONE,
     tooltip = "Draws a midpoint guide inside the active compression pocket.")
showPocketQuarters = input.bool(false, "Show Quarter Guides", group = G_ZONE,
     tooltip = "Optionally adds subtle quarter-range guide lines inside the active compression pocket. Disabled by default for a cleaner zone hierarchy.")
projectPocketBars = input.int(18, "Pocket Projection Bars", minval = 3, maxval = 120, group = G_ZONE,
     tooltip = "Projects the active compression pocket to the right of the latest candle.")
archivePockets = input.bool(true, "Show Archived Pockets", group = G_ZONE,
     tooltip = "Keeps a small number of completed compression pockets as faded market memory.")
archiveCount = input.int(1, "Archived Pocket Count", minval = 0, maxval = 8, group = G_ZONE,
     tooltip = "Maximum number of completed compression pockets retained on the chart.")
archiveProjection = input.int(24, "Archived Pocket Projection", minval = 0, maxval = 240, group = G_ZONE,
     tooltip = "Forward projection length for completed compression pockets.")
minimumPocketBars = input.int(5, "Minimum Pocket Bars", minval = 2, maxval = 100, group = G_ZONE,
     tooltip = "Minimum pocket duration required before a completed pocket can be archived.")

showRibbon = input.bool(true, "Show Compression Ribbon", group = G_VISUAL,
     tooltip = "Shows a soft volatility ribbon around price for continuous compression context.")
showRightTags = input.bool(false, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Optionally displays right-side tags for score, rails, and action context. Disabled by default because the centered pocket badge and panel already carry the active workflow.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Displays selective chart labels for important compression state changes.")
eventDensity = input.string("Low", "Event Label Density", options = ["Low", "Normal", "High"], group = G_VISUAL,
     tooltip = "Controls spacing and memory for compression event labels. Low is the default publication mode and keeps only selective lifecycle context.")
labelSizeInput = input.string("Normal", "Label Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Text size for event labels, zone badges, and right-side tags.")
rightTagOffset = input.int(4, "Right Tag Offset", minval = 1, maxval = 30, group = G_VISUAL,
     tooltip = "Horizontal offset used to place right-side tags away from the latest candle.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Optionally colors candles by compression state. Disabled by default to keep price action visually dominant.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the compact AG Pro decision panel. Enabled by default for public-release readability.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Moves the AG Pro panel to the preferred chart location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between the premium AGPro dark theme and a clean light theme.")
panelSizeInput = input.string("Normal", "Panel Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default.")

alertCompressionReady = input.bool(true, "Alert: Compression Ready", group = G_ALERTS,
     tooltip = "Creates an alert condition when compression first qualifies. Alerts are attention markers, not trade instructions.")
alertMature = input.bool(true, "Alert: Mature Compression", group = G_ALERTS,
     tooltip = "Creates an alert condition when compression reaches the mature state. Alerts are attention markers, not trade instructions.")
alertRelease = input.bool(true, "Alert: Pocket Release", group = G_ALERTS,
     tooltip = "Creates an alert condition when price closes outside the active compression pocket. Alerts are attention markers, not trade instructions.")

G_PROOF = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = G_PROOF,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across pocket releases on the current symbol and timeframe. Follow means price expanded one risk unit in the release direction before giving back the same distance against it. These are historical outcome rates, not predictions.")
proofStopAtr = input.float(1.20, "Proof Risk Unit (ATR)", minval = 0.30, maxval = 5.00, step = 0.10, group = G_PROOF,
     tooltip = "ATR distance used as one risk unit for the proof measurement. The favorable expansion target and the adverse reference are both placed this far from the release close.")
proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 4, maxval = 300, group = G_PROOF,
     tooltip = "Maximum number of bars each release is tracked for the proof measurement before it resolves at its current outcome.")
reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = G_PROOF,
     tooltip = "Number of bars after a release used to detect an immediate favorable expansion reaction.")
reactProgressPct = input.float(40.0, "Reaction Progress %", minval = 5.0, maxval = 90.0, step = 1.0, group = G_PROOF,
     tooltip = "Minimum favorable progress toward the risk-unit target, within the reaction window, required to count as an early React.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_norm_low_good(float value, float good, float bad) =>
    span = bad - good
    span == 0.0 ? 0.0 : f_clamp(100.0 * (bad - value) / span, 0.0, 100.0)

f_weighted4(float a, float b, float c, float d, float wa, float wb, float wc, float wd) =>
    totalWeight = wa + wb + wc + wd
    totalWeight > 0.0 ? (a * wa + b * wb + c * wc + d * wd) / totalWeight : 0.0

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_text_on(_bg) =>
    r = color.r(_bg) / 255.0
    g = color.g(_bg) / 255.0
    b = color.b(_bg) / 255.0
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    luminance > 0.45 ? color.rgb(15, 23, 42) : color.white

f_panel_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_state_color(string value) =>
    switch value
        "Mature" => color.rgb(37, 99, 235)
        "Tight" => color.rgb(34, 197, 166)
        "Building" => color.rgb(129, 140, 248)
        "Release" => color.rgb(245, 189, 92)
        "Failed" => color.rgb(244, 114, 182)
        => color.rgb(245, 189, 92)

f_grade(float score) =>
    score >= 85.0 ? "A+" : score >= 75.0 ? "A" : score >= 65.0 ? "B" : score >= 50.0 ? "C" : "D"

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? color.rgb(34, 197, 166) : value >= 40.0 ? color.rgb(245, 189, 92) : color.rgb(244, 114, 182)

f_flip_color(value) =>
    value <= 30.0 ? color.rgb(34, 197, 166) : value <= 55.0 ? color.rgb(245, 189, 92) : color.rgb(244, 114, 182)

f_row_bg(bool isDarkRow, int row) =>
    row % 2 == 0 ? (isDarkRow ? color.rgb(30, 41, 59) : color.rgb(226, 232, 240)) : (isDarkRow ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252))

f_badge_text(string stateValue, float scoreValue) =>
    stateValue == "Mature" ? "Mature Compression | Q" + str.tostring(math.round(scoreValue)) : stateValue == "Tight" ? "Tight Compression | Q" + str.tostring(math.round(scoreValue)) : stateValue == "Building" ? "Building Compression | Q" + str.tostring(math.round(scoreValue)) : "ATR Compression | Q" + str.tostring(math.round(scoreValue))

f_clear_labels(array<label> items) =>
    while array.size(items) > 0
        label oldLabel = array.pop(items)
        if not na(oldLabel)
            label.delete(oldLabel)

f_prune_labels(array<label> items, int keep) =>
    while array.size(items) > keep
        label oldLabel = array.shift(items)
        if not na(oldLabel)
            label.delete(oldLabel)

f_prune_boxes(array<box> items, int keep) =>
    while array.size(items) > keep
        box oldBox = array.shift(items)
        if not na(oldBox)
            box.delete(oldBox)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBorderDark = color.rgb(51, 65, 85)
panelLabelColDark = color.rgb(148, 163, 184)
panelValueColDark = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

isDark = panelTheme == "Dark"
panelBg = isDark ? panelBgDark : color.rgb(248, 250, 252)
panelBorder = isDark ? panelBorderDark : color.rgb(203, 213, 225)
panelLabelCol = isDark ? panelLabelColDark : color.rgb(100, 116, 139)
panelValueCol = isDark ? panelValueColDark : color.rgb(30, 41, 59)
darkText = color.rgb(15, 23, 42)
lightText = color.rgb(248, 250, 252)
tagText = color.rgb(248, 250, 252)

f_state_on_panel(_state) =>
    if not isDark
        _state == bullColor ? color.rgb(13, 118, 99) : _state == bearColor ? color.rgb(178, 44, 112) : _state == neutralColor ? color.rgb(133, 77, 14) : _state == accentColor ? color.rgb(67, 56, 202) : _state
    else
        _state

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
atrNow = ta.atr(atrLen)
atrBase = nz(ta.sma(atrNow, baselineLen), atrNow)
atrRatio = atrBase > 0.0 ? atrNow / atrBase : 1.0

rangeNow = ta.highest(high, rangeWindow) - ta.lowest(low, rangeWindow)
rangeBase = nz(ta.sma(rangeNow, baselineLen), rangeNow)
rangeRatio = rangeBase > 0.0 ? rangeNow / rangeBase : 1.0

barSpan = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
wickFraction = (upperWick + lowerWick) / barSpan
wickAverage = nz(ta.sma(wickFraction, noiseWindow), wickFraction)

barDirection = close > close[1] ? 1 : close < close[1] ? -1 : 0
flipEvent = barDirection != 0 and barDirection[1] != 0 and barDirection != barDirection[1] ? 1.0 : 0.0
flipRate = nz(ta.sma(flipEvent, noiseWindow), 0.0)
closeDrift = nz(ta.sma(math.abs(close - close[1]) / barSpan, noiseWindow), 0.0)

containHigh = ta.highest(high, containmentWindow)
containLow = ta.lowest(low, containmentWindow)
containRange = math.max(containHigh - containLow, syminfo.mintick)
closeStd = nz(ta.stdev(close, containmentWindow), 0.0)
containRatio = closeStd / containRange

atrScore = f_norm_low_good(atrRatio, strictMode ? 0.70 : 0.78, strictMode ? 1.02 : 1.10)
rangeScore = f_norm_low_good(rangeRatio, strictMode ? 0.70 : 0.80, strictMode ? 1.04 : 1.12)
wickScore = f_norm_low_good(wickAverage, strictMode ? 0.30 : 0.38, strictMode ? 0.68 : 0.82)
flipScore = f_norm_low_good(flipRate, strictMode ? 0.06 : 0.10, strictMode ? 0.34 : 0.46)
closeDriftScore = f_norm_low_good(closeDrift, strictMode ? 0.12 : 0.16, strictMode ? 0.52 : 0.70)
noiseScore = (wickScore + flipScore + closeDriftScore) / 3.0
containmentScore = f_norm_low_good(containRatio, strictMode ? 0.12 : 0.16, strictMode ? 0.34 : 0.42)

compressionScoreRaw = f_weighted4(atrScore, rangeScore, noiseScore, containmentScore, atrWeight, rangeWeight, noiseWeight, containmentWeight)
compressionScore = f_clamp(compressionScoreRaw, 0.0, 100.0)

// --------------------------------------------------
// State Engine
// --------------------------------------------------
buildingThreshold = math.max(34.0, compressionThreshold * 0.72)
matureNoiseGate = strictMode ? 62.0 : 52.0
matureContainmentGate = strictMode ? 66.0 : 55.0

isBuilding = compressionScore >= buildingThreshold and atrScore >= 40.0 and rangeScore >= 40.0
isTight = compressionScore >= compressionThreshold and atrScore >= 50.0 and rangeScore >= 50.0
isMature = compressionScore >= matureThreshold and atrScore >= 58.0 and rangeScore >= 58.0 and noiseScore >= matureNoiseGate and containmentScore >= matureContainmentGate

state = isMature ? "Mature" : isTight ? "Tight" : isBuilding ? "Building" : "Loose"
stateColor = f_state_color(state)
scoreGrade = f_grade(compressionScore)

atrState = atrScore >= 72.0 ? "Contracted" : atrScore >= 50.0 ? "Cooling" : "Open"
rangeState = rangeScore >= 72.0 ? "Contained" : rangeScore >= 50.0 ? "Narrowing" : "Wide"
noiseState = noiseScore >= 70.0 ? "Clean" : noiseScore >= 45.0 ? "Mixed" : "Noisy"
containState = containmentScore >= 70.0 ? "Strong" : containmentScore >= 45.0 ? "Stable" : "Weak"

compressionActive = isTight or isMature
pocketActive = showPocket and isBuilding

// --------------------------------------------------
// Compression Pocket State
// --------------------------------------------------
var int pocketStartBar = na
var float pocketHigh = na
var float pocketLow = na
var bool pocketQualified = false
var box activePocketBox = na
var label activePocketBadge = na
var line activeMidLine = na
var line activeQ1Line = na
var line activeQ3Line = na
var array<box> archivedPocketBoxes = array.new<box>()
var array<label> archivedPocketBadges = array.new<label>()

prevPocketActive = bar_index > 0 ? pocketActive[1] : false
prevCompressionActive = bar_index > 0 ? compressionActive[1] : false
prevMature = bar_index > 0 ? isMature[1] : false

enteredPocket = pocketActive and not prevPocketActive
exitedPocket = not pocketActive and prevPocketActive
enteredCompression = compressionActive and not prevCompressionActive
reachedMature = isMature and not prevMature

if enteredPocket
    pocketStartBar := bar_index
    pocketHigh := high
    pocketLow := low
    pocketQualified := compressionActive

    if not na(activePocketBox)
        box.delete(activePocketBox)
        activePocketBox := na
    if not na(activePocketBadge)
        label.delete(activePocketBadge)
        activePocketBadge := na
    if not na(activeMidLine)
        line.delete(activeMidLine)
        activeMidLine := na
    if not na(activeQ1Line)
        line.delete(activeQ1Line)
        activeQ1Line := na
    if not na(activeQ3Line)
        line.delete(activeQ3Line)
        activeQ3Line := na

    activePocketBox := box.new(bar_index, high, bar_index + projectPocketBars, low, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 86), border_color = color.new(stateColor, 5), border_width = 2, text = "")

if pocketActive
    pocketHigh := math.max(nz(pocketHigh, high), high)
    pocketLow := math.min(nz(pocketLow, low), low)
    pocketQualified := pocketQualified or compressionActive

pocketRange = not na(pocketHigh) and not na(pocketLow) ? math.max(pocketHigh - pocketLow, syminfo.mintick) : na
pocketMid = not na(pocketRange) ? (pocketHigh + pocketLow) * 0.5 : na
pocketQ1 = not na(pocketRange) ? pocketLow + pocketRange * 0.25 : na
pocketQ3 = not na(pocketRange) ? pocketLow + pocketRange * 0.75 : na
pocketAge = not na(pocketStartBar) ? bar_index - pocketStartBar + 1 : 0

releaseUp = prevCompressionActive and not na(pocketHigh[1]) and close > pocketHigh[1] and close[1] <= pocketHigh[1]
releaseDown = prevCompressionActive and not na(pocketLow[1]) and close < pocketLow[1] and close[1] >= pocketLow[1]
releaseEvent = releaseUp or releaseDown

if exitedPocket and not na(pocketStartBar) and not na(pocketHigh) and not na(pocketLow)
    archiveColor = pocketQualified ? stateColor[1] : accentColor
    finalAge = bar_index - pocketStartBar
    if archivePockets and archiveCount > 0 and pocketQualified and finalAge >= minimumPocketBars
        archivedRight = bar_index + archiveProjection
        archivedBadgeX = int(math.round((pocketStartBar + archivedRight) * 0.5))
        archivedMidY = (pocketHigh + pocketLow) * 0.5
        archivedBox = box.new(pocketStartBar, pocketHigh, archivedRight, pocketLow, xloc = xloc.bar_index, bgcolor = color.new(archiveColor, 93), border_color = color.new(archiveColor, 62), border_width = 1, text = "")
        archivedBadgeText = "Memory " + str.tostring(math.round(compressionScore[1]))
        archivedBadge = label.new(archivedBadgeX, archivedMidY, archivedBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(archiveColor, 0), textcolor = f_text_on(archiveColor), size = f_size(labelSizeInput), textalign = text.align_center)
        array.push(archivedPocketBoxes, archivedBox)
        array.push(archivedPocketBadges, archivedBadge)
        f_prune_boxes(archivedPocketBoxes, archiveCount)
        f_prune_labels(archivedPocketBadges, archiveCount)

    if not na(activePocketBox)
        box.delete(activePocketBox)
        activePocketBox := na
    if not na(activePocketBadge)
        label.delete(activePocketBadge)
        activePocketBadge := na
    if not na(activeMidLine)
        line.delete(activeMidLine)
        activeMidLine := na
    if not na(activeQ1Line)
        line.delete(activeQ1Line)
        activeQ1Line := na
    if not na(activeQ3Line)
        line.delete(activeQ3Line)
        activeQ3Line := na

    pocketStartBar := na
    pocketHigh := na
    pocketLow := na
    pocketQualified := false

if not archivePockets or archiveCount == 0
    while array.size(archivedPocketBoxes) > 0
        oldArchivedBox = array.pop(archivedPocketBoxes)
        if not na(oldArchivedBox)
            box.delete(oldArchivedBox)
    f_clear_labels(archivedPocketBadges)

if showPocket and pocketActive and not na(activePocketBox) and not na(pocketStartBar) and not na(pocketHigh) and not na(pocketLow)
    pocketRight = bar_index + projectPocketBars
    badgeX = int(math.round((pocketStartBar + pocketRight) * 0.5))
    boxColor = isMature ? headerBg : isTight ? bullColor : accentColor
    boxAlpha = isMature ? 78 : isTight ? 82 : 88
    badgeText = f_badge_text(state, compressionScore)
    badgeTextColor = f_text_on(boxColor)
    box.set_left(activePocketBox, pocketStartBar)
    box.set_right(activePocketBox, pocketRight)
    box.set_top(activePocketBox, pocketHigh)
    box.set_bottom(activePocketBox, pocketLow)
    box.set_bgcolor(activePocketBox, color.new(boxColor, boxAlpha))
    box.set_border_color(activePocketBox, color.new(boxColor, isMature ? 0 : 8))
    box.set_border_width(activePocketBox, isMature ? 3 : 2)
    box.set_text(activePocketBox, "")

    if showPocketText
        if na(activePocketBadge)
            activePocketBadge := label.new(badgeX, pocketMid, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(boxColor, 0), textcolor = badgeTextColor, size = f_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(activePocketBadge, badgeX, pocketMid)
            label.set_text(activePocketBadge, badgeText)
            label.set_color(activePocketBadge, color.new(boxColor, 0))
            label.set_textcolor(activePocketBadge, badgeTextColor)
            label.set_size(activePocketBadge, f_size(labelSizeInput))
            label.set_style(activePocketBadge, label.style_label_center)
    else if not na(activePocketBadge)
        label.delete(activePocketBadge)
        activePocketBadge := na

    if showPocketMidline
        if na(activeMidLine)
            activeMidLine := line.new(pocketStartBar, pocketMid, pocketRight, pocketMid, xloc = xloc.bar_index, color = color.new(boxColor, 22), width = 1)
        line.set_xy1(activeMidLine, pocketStartBar, pocketMid)
        line.set_xy2(activeMidLine, pocketRight, pocketMid)
        line.set_color(activeMidLine, color.new(boxColor, 22))
    else if not na(activeMidLine)
        line.delete(activeMidLine)
        activeMidLine := na

    if showPocketQuarters
        if na(activeQ1Line)
            activeQ1Line := line.new(pocketStartBar, pocketQ1, pocketRight, pocketQ1, xloc = xloc.bar_index, color = color.new(boxColor, 65), width = 1, style = line.style_dotted)
        if na(activeQ3Line)
            activeQ3Line := line.new(pocketStartBar, pocketQ3, pocketRight, pocketQ3, xloc = xloc.bar_index, color = color.new(boxColor, 65), width = 1, style = line.style_dotted)
        line.set_xy1(activeQ1Line, pocketStartBar, pocketQ1)
        line.set_xy2(activeQ1Line, pocketRight, pocketQ1)
        line.set_xy1(activeQ3Line, pocketStartBar, pocketQ3)
        line.set_xy2(activeQ3Line, pocketRight, pocketQ3)
    else
        if not na(activeQ1Line)
            line.delete(activeQ1Line)
            activeQ1Line := na
        if not na(activeQ3Line)
            line.delete(activeQ3Line)
            activeQ3Line := na

if (not showPocket or not pocketActive) and not na(activePocketBadge)
    label.delete(activePocketBadge)
    activePocketBadge := na

if not showPocket and not na(activePocketBox)
    box.delete(activePocketBox)
    activePocketBox := na

// --------------------------------------------------
// Ribbon
// --------------------------------------------------
scoreFrac = compressionScore / 100.0
ribbonBasisLen = math.max(2, int(math.floor(rangeWindow * 0.5)))
ribbonBasis = ta.ema(hlc3, ribbonBasisLen)
ribbonWidth = ta.ema(atrNow * (1.35 - scoreFrac * 0.72), 5)
ribbonTop = ribbonBasis + ribbonWidth
ribbonBot = ribbonBasis - ribbonWidth
ribbonCoreTop = ribbonBasis + ribbonWidth * 0.42
ribbonCoreBot = ribbonBasis - ribbonWidth * 0.42

ribbonLineColor = state == "Loose" ? color.new(panelLabelCol, 70) : color.new(stateColor, isMature ? 8 : 24)
ribbonFillColor = state == "Loose" ? color.new(panelLabelCol, 96) : color.new(stateColor, isMature ? 88 : isTight ? 91 : 94)
coreFillColor = state == "Loose" ? color.new(panelLabelCol, 98) : color.new(stateColor, isMature ? 82 : isTight ? 88 : 93)

plotTop = plot(showRibbon ? ribbonTop : na, "Compression Ribbon High", color = ribbonLineColor, linewidth = 1)
plotBot = plot(showRibbon ? ribbonBot : na, "Compression Ribbon Low", color = ribbonLineColor, linewidth = 1)
plotCoreTop = plot(showRibbon ? ribbonCoreTop : na, "Compression Core High", color = color.new(stateColor, 55), linewidth = 1)
plotCoreBot = plot(showRibbon ? ribbonCoreBot : na, "Compression Core Low", color = color.new(stateColor, 55), linewidth = 1)
plotBasis = plot(showRibbon ? ribbonBasis : na, "Compression Spine", color = color.new(stateColor, state == "Loose" ? 72 : 25), linewidth = 1)

fill(plotTop, plotBot, color = ribbonFillColor, title = "Compression Ribbon Fill")
fill(plotCoreTop, plotCoreBot, color = coreFillColor, title = "Compression Core Fill")

barcolor(showBarColors ? color.new(stateColor, 58) : na)

// --------------------------------------------------
// Action Engine
// --------------------------------------------------
edgeDistanceTop = not na(pocketHigh) ? math.abs(pocketHigh - close) / math.max(atrNow, syminfo.mintick) : na
edgeDistanceBottom = not na(pocketLow) ? math.abs(close - pocketLow) / math.max(atrNow, syminfo.mintick) : na
nearEdge = not na(edgeDistanceTop) and not na(edgeDistanceBottom) ? math.min(edgeDistanceTop, edgeDistanceBottom) <= 0.35 : false
pressureText = noiseState == "Noisy" ? "Noisy" : nearEdge ? "Edge pressure" : compressionActive ? "Holding" : isBuilding ? "Building" : "Open"
roomText = not na(pocketRange) ? str.tostring(pocketRange / math.max(atrNow, syminfo.mintick), "#.##") + " ATR" : "n/a"
actionState = releaseUp ? "Review Upside" : releaseDown ? "Review Downside" : isMature and nearEdge ? "Watch Edge" : isMature ? "Monitor Mature" : isTight ? "Track Compression" : isBuilding ? "Build Context" : "Wait Setup"
actionColor = releaseEvent ? neutralColor : isMature ? headerBg : isTight ? bullColor : isBuilding ? accentColor : neutralColor

// --------------------------------------------------
// Confirmation-anchored proof (pocket releases: Follow = 1R expansion in the release direction before 1R against)
// --------------------------------------------------
int releaseDir = releaseUp ? 1 : releaseDown ? -1 : 0

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

int proofWarmup = baselineLen + atrLen + 10
bool releaseAnchor = barstate.isconfirmed and releaseEvent and releaseDir != 0
if barstate.isconfirmed and bar_index > proofWarmup
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
        if naturalResolve or releaseAnchor
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
    if releaseAnchor and not pEvalActive
        float pRisk = math.max(atrNow * proofStopAtr, syminfo.mintick)
        pEvalActive := true
        pEvalDir := releaseDir
        pEvalEntry := close
        pEvalStop := close - releaseDir * pRisk
        pEvalTarget := close + releaseDir * pRisk
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float proofFlipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastEventLabelBar = na
labelGap = eventDensity == "Low" ? 34 : eventDensity == "High" ? 10 : 20
labelKeep = eventDensity == "Low" ? 8 : eventDensity == "High" ? 24 : 14
canLabel = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelGap
eventOffset = math.max(atrNow * 1.25, syminfo.mintick * 10.0)

labelEvent = showEventLabels and canLabel and (enteredPocket or enteredCompression or reachedMature or releaseEvent)

if labelEvent
    eventText = releaseUp ? "Review Upside" : releaseDown ? "Review Downside" : reachedMature ? "Mature Q" + str.tostring(math.round(compressionScore)) : enteredCompression ? "Ready Q" + str.tostring(math.round(compressionScore)) : noiseState == "Noisy" ? "Noisy Q" + str.tostring(math.round(compressionScore)) : "Build Q" + str.tostring(math.round(compressionScore))
    eventColor = releaseEvent ? neutralColor : reachedMature ? headerBg : enteredCompression ? bullColor : noiseState == "Noisy" ? bearColor : accentColor
    eventIsUpper = releaseUp or reachedMature
    eventY = eventIsUpper ? high + eventOffset : low - eventOffset
    eventStyle = eventIsUpper ? label.style_label_down : label.style_label_up
    eventTextColor = f_text_on(eventColor)
    newLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventStyle, color = eventColor, textcolor = eventTextColor, size = f_size(labelSizeInput))
    array.push(eventLabels, newLabel)
    lastEventLabelBar := bar_index

f_prune_labels(eventLabels, labelKeep)

// --------------------------------------------------
// Right-Side Tags
// --------------------------------------------------
var label scoreTag = na
var label railTag = na
var label noiseTag = na
var label actionTag = na

if barstate.islast
    if not na(scoreTag)
        label.delete(scoreTag)
        scoreTag := na
    if not na(railTag)
        label.delete(railTag)
        railTag := na
    if not na(noiseTag)
        label.delete(noiseTag)
        noiseTag := na
    if not na(actionTag)
        label.delete(actionTag)
        actionTag := na

    if showRightTags
        tagX = bar_index + rightTagOffset
        scoreY = not na(pocketHigh) ? pocketHigh + atrNow * 0.20 : ribbonTop
        railY = not na(pocketHigh) ? pocketHigh : ribbonTop
        noiseY = not na(pocketLow) ? pocketLow : ribbonBot
        actionY = not na(pocketMid) ? pocketMid : close

        scoreTagBg = actionColor
        railTagBg = isMature ? headerBg : accentColor
        noiseTagBg = noiseState == "Noisy" ? bearColor : isTight ? bullColor : neutralColor

        scoreTag := label.new(tagX, scoreY, "ATR " + str.tostring(math.round(compressionScore)) + " " + scoreGrade, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = scoreTagBg, textcolor = f_text_on(scoreTagBg), size = f_size(labelSizeInput))
        railTag := label.new(tagX, railY, "Rail " + str.tostring(railY, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = railTagBg, textcolor = f_text_on(railTagBg), size = f_size(labelSizeInput))
        noiseTag := label.new(tagX, noiseY, noiseState + " / " + containState, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = noiseTagBg, textcolor = f_text_on(noiseTagBg), size = f_size(labelSizeInput))
        actionTag := label.new(tagX + 1, actionY, actionState, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = actionColor, textcolor = f_text_on(actionColor), size = f_size(labelSizeInput))

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelSize = f_size(panelSizeInput)
var table panel = na
var string lastPanelPosition = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastPanelVisible = false
var bool lastProofMode = false
int panelRowCount = showProof ? 12 : 7

panelNeedsReset = na(panel) or panelPositionInput != lastPanelPosition or panelTheme != lastPanelTheme or panelSizeInput != lastPanelSize or showPanel != lastPanelVisible or showProof != lastProofMode
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    if showPanel
        panel := table.new(f_panel_position(panelPositionInput), 2, panelRowCount, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
        table.cell(panel, 0, 0, "AG Pro ATR Compression Map", text_color = headerText, text_size = panelSize, bgcolor = headerBg, text_halign = text.align_center)
        table.cell(panel, 1, 0, "", text_color = headerText, text_size = panelSize, bgcolor = headerBg)
        table.merge_cells(panel, 0, 0, 1, 0)
    else
        panel := na
    lastPanelPosition := panelPositionInput
    lastPanelTheme := panelTheme
    lastPanelSize := panelSizeInput
    lastPanelVisible := showPanel
    lastProofMode := showProof

if barstate.islast and showPanel and not na(panel)
    table.clear(panel, 0, 1, 1, panelRowCount - 1)
    table.cell(panel, 0, 0, "AG Pro ATR Compression Map", text_color = headerText, text_size = panelSize, bgcolor = headerBg, text_halign = text.align_center)
    table.cell(panel, 0, 1, "Workflow", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 1), text_halign = text.align_left)
    table.cell(panel, 1, 1, actionState, text_color = f_text_on(actionColor), text_size = panelSize, bgcolor = actionColor, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Volatility", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 2), text_halign = text.align_left)
    table.cell(panel, 1, 2, state + " / " + str.tostring(math.round(compressionScore)) + " " + scoreGrade, text_color = f_text_on(stateColor), text_size = panelSize, bgcolor = stateColor, text_halign = text.align_right)
    table.cell(panel, 0, 3, "ATR / Range", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 3), text_halign = text.align_left)
    table.cell(panel, 1, 3, atrState + " / " + rangeState, text_color = panelValueCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 3), text_halign = text.align_right)
    table.cell(panel, 0, 4, "Noise", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 4), text_halign = text.align_left)
    table.cell(panel, 1, 4, noiseState + " / " + str.tostring(math.round(noiseScore)), text_color = f_state_on_panel(noiseState == "Noisy" ? bearColor : noiseState == "Clean" ? bullColor : neutralColor), text_size = panelSize, bgcolor = f_row_bg(isDark, 4), text_halign = text.align_right)
    table.cell(panel, 0, 5, "Containment", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 5), text_halign = text.align_left)
    table.cell(panel, 1, 5, containState + " / " + str.tostring(math.round(containmentScore)), text_color = f_state_on_panel(containState == "Weak" ? bearColor : containState == "Strong" ? bullColor : accentColor), text_size = panelSize, bgcolor = f_row_bg(isDark, 5), text_halign = text.align_right)
    table.cell(panel, 0, 6, "Pocket", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 6), text_halign = text.align_left)
    table.cell(panel, 1, 6, pressureText + " / " + roomText, text_color = panelValueCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 6), text_halign = text.align_right)
    if showProof
        table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, text_size = panelSize, bgcolor = f_row_bg(isDark, 7), text_halign = text.align_left)
        table.cell(panel, 1, 7, proofSampleText, text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 7), text_halign = text.align_right)
        table.cell(panel, 0, 8, "Follow Rate", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 8), text_halign = text.align_left)
        table.cell(panel, 1, 8, proofTotal > 0 ? f_rate_pct(followRate) : "-", text_color = proofTotal > 0 ? f_state_on_panel(f_rate_color(followRate)) : panelValueCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 8), text_halign = text.align_right)
        table.cell(panel, 0, 9, "Hold Rate", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 9), text_halign = text.align_left)
        table.cell(panel, 1, 9, proofTotal > 0 ? f_rate_pct(holdRate) : "-", text_color = proofTotal > 0 ? f_state_on_panel(f_rate_color(holdRate)) : panelValueCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 9), text_halign = text.align_right)
        table.cell(panel, 0, 10, "React Rate", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 10), text_halign = text.align_left)
        table.cell(panel, 1, 10, proofTotal > 0 ? f_rate_pct(reactRate) : "-", text_color = proofTotal > 0 ? f_state_on_panel(f_rate_color(reactRate)) : panelValueCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 10), text_halign = text.align_right)
        table.cell(panel, 0, 11, "Flip Rate", text_color = panelLabelCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 11), text_halign = text.align_left)
        table.cell(panel, 1, 11, proofTotal > 0 ? f_rate_pct(proofFlipRate) : "-", text_color = proofTotal > 0 ? f_state_on_panel(f_flip_color(proofFlipRate)) : panelValueCol, text_size = panelSize, bgcolor = f_row_bg(isDark, 11), text_halign = text.align_right)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertCompressionReady and enteredCompression, "AG Pro ATR | Compression Ready", "AG Pro ATR Compression Map: compression has reached the ready threshold.")
alertcondition(alertMature and reachedMature, "AG Pro ATR | Mature Compression", "AG Pro ATR Compression Map: compression has reached the mature state.")
alertcondition(alertRelease and releaseUp, "AG Pro ATR | Upside Release", "AG Pro ATR Compression Map: price closed above the active compression pocket.")
alertcondition(alertRelease and releaseDown, "AG Pro ATR | Downside Release", "AG Pro ATR Compression Map: price closed below the active compression pocket.")

// --------------------------------------------------
// Hidden Exports
// --------------------------------------------------
plot(compressionScore, "ATR Compression Score", display = display.none)
plot(followRate, "ATR Follow Rate", display = display.none)
plot(holdRate, "ATR Hold Rate", display = display.none)
plot(reactRate, "ATR React Rate", display = display.none)
plot(proofFlipRate, "ATR Flip Rate", display = display.none)
````
