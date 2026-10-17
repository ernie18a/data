# Heikin Ashi Trend Zones [AGPro Series]

- url: https://www.tradingview.com/script/iXNTJGyR-Heikin-Ashi-Trend-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;faf16b0214834bd4951d378ca1443b88
- version: 2.0

## Description

Heikin Ashi Trend Zones [AGPro Series]

Heikin Ashi Trend Zones [AGPro Series] is a clean overlay built for traders who like the smoothing behavior of Heikin Ashi but still want to keep the original market candles visible. Instead of repainting the chart with synthetic candles, the script reads the internal Heikin Ashi state in the background and converts it into a focused trend-state layer.

The engine follows four core ideas:

1. Internal HA Side
The script calculates the active Heikin Ashi side from synthetic HA open and close values, then filters weak neutral bodies so the state does not flip on every small candle.

2. HA Streak Quality
The panel tracks how long the current HA side has been active. This helps separate early state changes from mature continuation phases.

3. Optional Transition Zones
When the HA side changes with enough body strength, wick cleanliness, close location, ATR pressure, and prior-state maturity, the script can project a compact rectangular transition zone. This layer is disabled by default so the public chart view stays clean, but it remains available for traders who want to inspect HA changeover corridors.

4. Continuation Quality
Once a HA streak matures, the script scores continuation quality using body strength, wick cleanliness, close location, smoothed HA slope, streak depth, and ATR context. Labels appear only when the continuation score is strong enough and the cooldown rules allow a clean chart presentation.

What makes this script different

- It does not replace real candles with Heikin Ashi candles.
- It does not behave like a generic trend-following dashboard.
- It focuses on HA state transitions, HA streak maturity, and continuation quality.
- Optional transition boxes are concept-native HA corridors, not broad horizontal support/resistance zones.
- Label density is capped with cooldown and maximum visible label controls.
- The panel exposes HA side, streak, transition quality, continuation quality, and ATR context in a compact AGPro layout.

Visual design

The overlay stays restrained:
- A slim trend-state ribbon follows the smoothed HA path.
- Optional transition zones can extend forward as compact rectangles when enabled.
- Continuation labels are offset from candles with ATR spacing.
- Panel location, panel theme, panel font size, and label font size are adjustable.

Suggested usage

Use the script to study whether Heikin Ashi structure is shifting, stabilizing, or continuing while the original candles remain visible. The strongest reads usually come from alignment between a clean HA side, a growing streak, strong continuation quality, and an ATR context that supports the current state.

Default settings are tuned for a balanced public chart view with a clean ribbon and selective continuation labels. Faster traders can reduce smoothing and cooldown values. Swing traders can enable transition zones, increase transition projection, and require higher continuation quality for fewer labels.

## Source Code

````pine
// -------------------------------------------------
// Heikin Ashi Trend Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.1
//
// Heikin Ashi Trend Zones converts internal HA structure into a clean trend-state
// map without replacing the chart candles. It tracks HA side, streak quality,
// transition pressure, ATR context, and continuation quality, then highlights
// projected HA transition zones and restrained continuation labels. Two
// follow-rate layers report how often qualified transitions and continuation
// signals on this chart actually extended in their direction before the HA
// side flipped back.
// -------------------------------------------------

//@version=6
indicator("Heikin Ashi Trend Zones [AGPro Series]",
     shorttitle = "AG Pro HA",
     overlay = true,
     max_boxes_count = 100,
     max_labels_count = 300,
     max_lines_count = 50)

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
// Inputs
// -------------------------------------------------
groupCore = "Core Engine"
bodyTarget = input.float(0.55, "HA Body Strength Target", minval = 0.20, maxval = 0.90, step = 0.05, group = groupCore, tooltip = "Defines the HA body-to-range ratio that receives a full body strength score. Higher values demand cleaner, larger HA bodies.")
dojiFilter = input.float(0.12, "HA Neutral Body Filter", minval = 0.02, maxval = 0.35, step = 0.01, group = groupCore, tooltip = "Treats very small HA bodies as neutral noise and carries forward the prior directional state.")
haSmoothLen = input.int(8, "HA State Smoothing Length", minval = 2, maxval = 50, group = groupCore, tooltip = "Smooths the internal HA close used by the ribbon and continuation quality engine.")
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupCore, tooltip = "ATR period used for volatility normalization, label offsets, and transition-zone padding.")
atrContextLen = input.int(50, "ATR Context Length", minval = 10, maxval = 250, group = groupCore, tooltip = "Baseline ATR period used to classify the current volatility environment as quiet, normal, or expanding.")

groupQuality = "Quality Logic"
transitionMinQuality = input.float(62.0, "Transition Zone Minimum Quality", minval = 1.0, maxval = 100.0, step = 1.0, group = groupQuality, tooltip = "Minimum HA transition score required before a projected transition zone is drawn.")
transitionDecay = input.float(7.0, "Transition Quality Decay", minval = 1.0, maxval = 25.0, step = 1.0, group = groupQuality, tooltip = "Controls how quickly transition quality fades after the HA side change has occurred.")
continuationMinQuality = input.float(68.0, "Continuation Minimum Quality", minval = 1.0, maxval = 100.0, step = 1.0, group = groupQuality, tooltip = "Minimum continuation quality required before the HA state is considered clean enough for continuation labeling.")
minContinuationStreak = input.int(3, "Minimum Continuation Streak", minval = 2, maxval = 20, group = groupQuality, tooltip = "Number of consecutive HA candles required before the script can classify the move as a continuation state.")
confirmedOnly = input.bool(true, "Confirmed Bars Only", group = groupQuality, tooltip = "When enabled, zones, labels, and alerts are created only after the bar is confirmed.")

groupVisual = "Visual Layer"
showRibbon = input.bool(true, "Show Trend State Ribbon", group = groupVisual, tooltip = "Displays a slim HA state ribbon around the smoothed internal HA path without replacing chart candles.")
ribbonWidthAtr = input.float(0.08, "Ribbon Width ATR", minval = 0.02, maxval = 0.50, step = 0.01, group = groupVisual, tooltip = "Controls the visual thickness of the trend-state ribbon as a fraction of ATR.")
showTransitionZones = input.bool(false, "Show Transition Zones", group = groupVisual, tooltip = "Projects compact HA transition zones when the internal HA side flips with sufficient quality. Disabled by default to keep the public overlay clean.")
zoneProjectionBars = input.int(18, "Zone Projection Bars", minval = 5, maxval = 200, group = groupVisual, tooltip = "Number of bars each HA transition zone extends forward from its origin.")
zonePaddingAtr = input.float(0.06, "Zone Padding ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = groupVisual, tooltip = "Adds ATR-based padding around the HA transition body so optional zones remain compact and concept-specific.")
maxTransitionZones = input.int(3, "Maximum Visible Zones", minval = 1, maxval = 40, group = groupVisual, tooltip = "Caps the number of historical HA transition zones kept on the chart.")
showContinuationLabels = input.bool(true, "Show Continuation Labels", group = groupVisual, tooltip = "Places restrained labels when the HA trend state shows clean continuation quality after a confirmed streak.")
continuationLabelQuality = input.float(80.0, "Continuation Label Quality", minval = 1.0, maxval = 100.0, step = 1.0, group = groupVisual, tooltip = "Minimum continuation score required for on-chart continuation labels.")
labelCooldownBars = input.int(16, "Label Cooldown Bars", minval = 1, maxval = 100, group = groupVisual, tooltip = "Minimum bar distance between continuation labels. This keeps label density readable on fast charts.")
maxContinuationLabels = input.int(16, "Maximum Visible Labels", minval = 1, maxval = 100, group = groupVisual, tooltip = "Caps historical continuation labels so the overlay stays premium and responsive.")
labelOffsetAtr = input.float(1.45, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "Places labels outside the recent candle cluster using an ATR-based offset so they do not disappear inside price bars.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls continuation label font size. Normal is the default balanced publication setting.")

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Displays the AGPro state panel with HA side, streak, transition quality, continuation quality, and ATR context.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = groupPanel, tooltip = "Controls where the AGPro panel appears on the chart.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = "Switches the panel between the AGPro dark theme and a clean light layout.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default balanced publication setting.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float floorValue, float ceilingValue) =>
    math.max(floorValue, math.min(ceilingValue, value))

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        => position.top_right

f_panel_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_quality_text(float score) =>
    string result = "LOW"
    if score >= 82.0
        result := "PRIME"
    else if score >= 68.0
        result := "CLEAN"
    else if score >= 50.0
        result := "MIXED"
    result

f_side_text(int side) =>
    switch side
        1 => "Bullish HA"
        -1 => "Bearish HA"
        => "Neutral HA"

f_atr_text(float ratio) =>
    string result = "NORMAL"
    if ratio >= 1.18
        result := "EXPANDING"
    else if ratio <= 0.82
        result := "QUIET"
    result

f_state_color(int side, bool transitionActive, bool continuationActive) =>
    color result = color.new(neutralColor, 10)
    if transitionActive
        result := color.new(neutralColor, 0)
    else if continuationActive and side == 1
        result := color.new(bullColor, 0)
    else if continuationActive and side == -1
        result := color.new(bearColor, 0)
    else if side == 1
        result := color.new(bullColor, 35)
    else if side == -1
        result := color.new(bearColor, 35)
    result

f_score_color(float score, string theme) =>
    color result = theme == "Clean Light" ? color.rgb(100, 116, 139) : panelLabelCol
    if score >= 82.0
        result := accentColor
    else if score >= 68.0
        result := bullColor
    else if score >= 50.0
        result := neutralColor
    result

// -------------------------------------------------
// Heikin Ashi State Engine
// -------------------------------------------------
haClose = (open + high + low + close) / 4.0
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
haHigh = math.max(high, math.max(haOpen, haClose))
haLow = math.min(low, math.min(haOpen, haClose))

haBody = haClose - haOpen
haAbsBody = math.abs(haBody)
haSpan = math.max(haHigh - haLow, syminfo.mintick)
bodyRatio = haAbsBody / haSpan
rawSide = bodyRatio < dojiFilter ? 0 : haBody > 0.0 ? 1 : haBody < 0.0 ? -1 : 0

var int haSide = 0
haSide := rawSide == 0 ? nz(haSide[1], 0) : rawSide
priorSide = nz(haSide[1], haSide)
hasPriorSide = nz(haSide[1], 0) != 0
sideChanged = haSide != priorSide and haSide != 0 and hasPriorSide

var int haStreak = 0
haStreak := haSide == priorSide ? nz(haStreak[1], 0) + 1 : 1
priorStreak = nz(haStreak[1], 1)

atr = ta.atr(atrLen)
atrValue = nz(atr, math.max(high - low, syminfo.mintick))
atrBase = ta.sma(atrValue, atrContextLen)
atrRatio = atrBase > 0.0 ? atrValue / atrBase : 1.0
atrScore = f_clamp((atrRatio - 0.65) / 0.90 * 100.0, 0.0, 100.0)
atrContext = f_atr_text(atrRatio)

bodyScore = f_clamp(bodyRatio / bodyTarget * 100.0, 0.0, 100.0)
upperWick = haHigh - math.max(haOpen, haClose)
lowerWick = math.min(haOpen, haClose) - haLow
againstWick = haSide == 1 ? lowerWick : haSide == -1 ? upperWick : math.max(upperWick, lowerWick)
wickCleanScore = f_clamp(100.0 - againstWick / haSpan * 180.0, 0.0, 100.0)
closeLocationScore = haSide == 1 ? (haClose - haLow) / haSpan * 100.0 : haSide == -1 ? (haHigh - haClose) / haSpan * 100.0 : 50.0
closeLocationScore := f_clamp(closeLocationScore, 0.0, 100.0)

haSmooth = ta.ema(haClose, haSmoothLen)
haSlopeAtr = atrValue > 0.0 ? nz((haSmooth - haSmooth[1]) / atrValue, 0.0) : 0.0
slopeAligned = haSide == 1 ? haSlopeAtr > 0.0 : haSide == -1 ? haSlopeAtr < 0.0 : false
slopeScore = slopeAligned ? f_clamp(math.abs(haSlopeAtr) / 0.28 * 100.0, 0.0, 100.0) : 0.0
streakScore = f_clamp(haStreak / math.max(minContinuationStreak * 2.0, 1.0) * 100.0, 0.0, 100.0)
priorMaturityScore = f_clamp(priorStreak / 6.0 * 100.0, 0.0, 100.0)

transitionRawScore = bodyScore * 0.30 + wickCleanScore * 0.25 + closeLocationScore * 0.20 + atrScore * 0.15 + priorMaturityScore * 0.10
var float transitionQuality = 0.0
transitionQuality := sideChanged ? transitionRawScore : math.max(0.0, nz(transitionQuality[1], 0.0) - transitionDecay)

sameSide = haSide == priorSide and haSide != 0
continuationRawScore = bodyScore * 0.24 + wickCleanScore * 0.22 + closeLocationScore * 0.18 + slopeScore * 0.22 + streakScore * 0.14
continuationQuality = sameSide and haStreak >= minContinuationStreak ? continuationRawScore : 0.0
continuationActive = continuationQuality >= continuationMinQuality

barsSinceTransition = ta.barssince(sideChanged)
transitionActive = not na(barsSinceTransition) and barsSinceTransition <= math.max(3, minContinuationStreak) and transitionQuality > 0.0
stateColor = f_state_color(haSide, transitionActive, continuationActive)
confirmedGate = not confirmedOnly or barstate.isconfirmed

// -------------------------------------------------
// Follow-Rate Layers
// Two independent trackers measure the script's own claims on this chart.
// Registration always requires a confirmed bar, regardless of the
// Confirmed Bars Only visual setting, so the statistics never repaint.
// Resolution runs before registration; a timeout counts as failed.
// -------------------------------------------------
transConfirmedNew = barstate.isconfirmed and sideChanged and transitionRawScore >= transitionMinQuality

// Transition follow: after a qualified HA transition, did price extend
// 1.5 ATR in the new direction before the HA side flipped back?
var bool trTrkOn = false
var int trTrkDir = 0
var float trTrkTgt = na
var int trTrkStart = na
var int transFollowW = 0
var int transFollowN = 0
trWindow = math.max(20, zoneProjectionBars * 2)
if trTrkOn
    trFollowed = trTrkDir == 1 ? high >= trTrkTgt : low <= trTrkTgt
    trFailed = haSide != 0 and haSide != trTrkDir
    trTimeout = not na(trTrkStart) and bar_index - trTrkStart >= trWindow
    if trFailed or trTimeout
        transFollowN += 1
        trTrkOn := false
    else if trFollowed
        transFollowN += 1
        transFollowW += 1
        trTrkOn := false
if transConfirmedNew and not trTrkOn
    trTrkOn := true
    trTrkDir := haSide
    trTrkTgt := close + (haSide == 1 ? 1.0 : -1.0) * atrValue * 1.5
    trTrkStart := bar_index
transFollowRate = transFollowN > 0 ? 100.0 * transFollowW / transFollowN : na
transFollowReady = transFollowN >= 8

// -------------------------------------------------
// Trend State Ribbon
// -------------------------------------------------
ribbonUpper = haSmooth + atrValue * ribbonWidthAtr
ribbonLower = haSmooth - atrValue * ribbonWidthAtr
ribbonUpperPlot = plot(showRibbon ? ribbonUpper : na, "HA Ribbon Upper", color = color.new(stateColor, 35), linewidth = 1)
ribbonLowerPlot = plot(showRibbon ? ribbonLower : na, "HA Ribbon Lower", color = color.new(stateColor, 35), linewidth = 1)
fill(ribbonUpperPlot, ribbonLowerPlot, color = showRibbon ? color.new(stateColor, 84) : na, title = "HA Trend State Ribbon")
plot(showRibbon ? haSmooth : na, "HA State Path", color = color.new(stateColor, 0), linewidth = 2)

// -------------------------------------------------
// Transition Zones
// -------------------------------------------------
var box[] transitionBoxes = array.new_box()

if not showTransitionZones and array.size(transitionBoxes) > 0
    boxCount = array.size(transitionBoxes)
    for idx = 0 to boxCount - 1
        oldBox = array.shift(transitionBoxes)
        box.delete(oldBox)

newTransitionZone = showTransitionZones and confirmedGate and sideChanged and transitionRawScore >= transitionMinQuality
if newTransitionZone
    bodyTop = math.max(haOpen, haClose)
    bodyBottom = math.min(haOpen, haClose)
    zonePad = math.max(atrValue * zonePaddingAtr, syminfo.mintick * 8.0)
    zoneTop = bodyTop + zonePad
    zoneBottom = bodyBottom - zonePad
    zoneColor = haSide == 1 ? bullColor : bearColor
    newBox = box.new(left = bar_index,
         top = zoneTop,
         right = bar_index + zoneProjectionBars,
         bottom = zoneBottom,
         xloc = xloc.bar_index,
         bgcolor = color.new(zoneColor, 88),
         border_color = color.new(zoneColor, 35),
         border_width = 1)
    array.push(transitionBoxes, newBox)
    if array.size(transitionBoxes) > maxTransitionZones
        oldBox = array.shift(transitionBoxes)
        box.delete(oldBox)

// -------------------------------------------------
// Continuation Labels
// -------------------------------------------------
var label[] continuationLabels = array.new_label()
var int lastContinuationLabelBar = na

labelBaseLow = ta.lowest(low, 3)
labelBaseHigh = ta.highest(high, 3)
canDrawContinuationLabel = na(lastContinuationLabelBar) ? true : bar_index - lastContinuationLabelBar >= labelCooldownBars
qualityCrossUp = continuationQuality >= continuationLabelQuality and nz(continuationQuality[1], 0.0) < continuationLabelQuality
freshContinuation = continuationQuality >= continuationLabelQuality and haStreak == minContinuationStreak
strongContinuationRefresh = continuationQuality >= continuationLabelQuality + 10.0 and haStreak > minContinuationStreak and haStreak % labelCooldownBars == 0
newContinuationLabel = showContinuationLabels and confirmedGate and continuationActive and canDrawContinuationLabel and (qualityCrossUp or freshContinuation or strongContinuationRefresh)
if newContinuationLabel
    labelColor = haSide == 1 ? bullColor : bearColor
    labelText = haSide == 1 ? "CONT " + str.tostring(math.round(continuationQuality)) : "HOLD " + str.tostring(math.round(continuationQuality))
    labelY = haSide == 1 ? labelBaseLow - atrValue * labelOffsetAtr : labelBaseHigh + atrValue * labelOffsetAtr
    labelStyle = haSide == 1 ? label.style_label_up : label.style_label_down
    newLabel = label.new(x = bar_index,
         y = labelY,
         text = labelText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = labelStyle,
         color = color.new(labelColor, 8),
         textcolor = headerText,
         size = f_size(labelSizeInput))
    array.push(continuationLabels, newLabel)
    lastContinuationLabelBar := bar_index
    if array.size(continuationLabels) > maxContinuationLabels
        oldLabel = array.shift(continuationLabels)
        label.delete(oldLabel)

// Continuation follow: after a continuation signal, did price extend
// 1.5 ATR in the trend direction before the HA side flipped? The event
// mirrors the label trigger but is independent of label visibility, so
// the statistic works even when labels are hidden.
contConfirmedNew = barstate.isconfirmed and continuationActive and canDrawContinuationLabel and (qualityCrossUp or freshContinuation or strongContinuationRefresh)
var bool ctTrkOn = false
var int ctTrkDir = 0
var float ctTrkTgt = na
var int ctTrkStart = na
var int contFollowW = 0
var int contFollowN = 0
ctWindow = math.max(20, labelCooldownBars * 2)
if ctTrkOn
    ctFollowed = ctTrkDir == 1 ? high >= ctTrkTgt : low <= ctTrkTgt
    ctFailed = haSide != 0 and haSide != ctTrkDir
    ctTimeout = not na(ctTrkStart) and bar_index - ctTrkStart >= ctWindow
    if ctFailed or ctTimeout
        contFollowN += 1
        ctTrkOn := false
    else if ctFollowed
        contFollowN += 1
        contFollowW += 1
        ctTrkOn := false
if contConfirmedNew and not ctTrkOn
    ctTrkOn := true
    ctTrkDir := haSide
    ctTrkTgt := close + (haSide == 1 ? 1.0 : -1.0) * atrValue * 1.5
    ctTrkStart := bar_index
contFollowRate = contFollowN > 0 ? 100.0 * contFollowW / contFollowN : na
contFollowReady = contFollowN >= 8

f_follow_text(int n, float rate) =>
    n == 0 ? "-" : str.tostring(int(math.round(rate))) + "%  n=" + str.tostring(n)

f_follow_color(bool ready, float rate, string theme) =>
    color result = f_panel_label(theme)
    if ready
        result := rate >= 55.0 ? bullColor : rate >= 40.0 ? neutralColor : bearColor
    result

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_panel_position(panelLocation), 4, 6, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), border_color = f_panel_border(panelTheme), border_width = 1)

if barstate.islast
    table.clear(panel, 0, 0, 3, 5)
    if showPanel
        panelTextSize = f_size(panelSizeInput)
        panelBackground = f_panel_bg(panelTheme)
        panelLabel = f_panel_label(panelTheme)
        panelValue = f_panel_value(panelTheme)
        table.merge_cells(panel, 0, 0, 3, 0)
        table.cell(panel, 0, 0, "AG Pro Heikin Ashi Trend Zones", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize)
        table.cell(panel, 0, 1, "HA SIDE", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 1, 1, f_side_text(haSide), bgcolor = panelBackground, text_color = stateColor, text_size = panelTextSize)
        table.cell(panel, 2, 1, "STREAK", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 3, 1, str.tostring(haStreak), bgcolor = panelBackground, text_color = panelValue, text_size = panelTextSize)
        table.cell(panel, 0, 2, "TRANSITION", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 1, 2, f_quality_text(transitionQuality) + " " + str.tostring(math.round(transitionQuality)), bgcolor = panelBackground, text_color = f_score_color(transitionQuality, panelTheme), text_size = panelTextSize)
        table.cell(panel, 2, 2, "CONTINUATION", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 3, 2, f_quality_text(continuationQuality) + " " + str.tostring(math.round(continuationQuality)), bgcolor = panelBackground, text_color = f_score_color(continuationQuality, panelTheme), text_size = panelTextSize)
        table.cell(panel, 0, 3, "ATR CONTEXT", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 1, 3, atrContext, bgcolor = panelBackground, text_color = atrRatio >= 1.18 ? accentColor : atrRatio <= 0.82 ? neutralColor : panelValue, text_size = panelTextSize)
        table.cell(panel, 2, 3, "RATIO", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 3, 3, str.tostring(atrRatio, "#.##"), bgcolor = panelBackground, text_color = panelValue, text_size = panelTextSize)
        table.cell(panel, 0, 4, "ACTIVE ZONES", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 1, 4, str.tostring(array.size(transitionBoxes)), bgcolor = panelBackground, text_color = panelValue, text_size = panelTextSize)
        table.cell(panel, 2, 4, "STATE", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        panelState = transitionActive ? "TRANSITION" : continuationActive ? "CONTINUATION" : "BASELINE"
        table.cell(panel, 3, 4, panelState, bgcolor = panelBackground, text_color = stateColor, text_size = panelTextSize)
        table.cell(panel, 0, 5, "TRANS FOLLOW", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 1, 5, f_follow_text(transFollowN, transFollowRate), bgcolor = panelBackground, text_color = f_follow_color(transFollowReady, transFollowRate, panelTheme), text_size = panelTextSize)
        table.cell(panel, 2, 5, "CONT FOLLOW", bgcolor = panelBackground, text_color = panelLabel, text_size = panelTextSize)
        table.cell(panel, 3, 5, f_follow_text(contFollowN, contFollowRate), bgcolor = panelBackground, text_color = f_follow_color(contFollowReady, contFollowRate, panelTheme), text_size = panelTextSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bullTransition = confirmedGate and sideChanged and haSide == 1 and transitionRawScore >= transitionMinQuality
bearTransition = confirmedGate and sideChanged and haSide == -1 and transitionRawScore >= transitionMinQuality
cleanContinuation = confirmedGate and continuationActive and continuationQuality >= continuationLabelQuality

alertcondition(bullTransition, title = "Bullish HA transition", message = "Heikin Ashi Trend Zones detected a bullish HA transition zone with qualified internal state.")
alertcondition(bearTransition, title = "Bearish HA transition", message = "Heikin Ashi Trend Zones detected a bearish HA transition zone with qualified internal state.")
alertcondition(cleanContinuation, title = "Clean HA continuation", message = "Heikin Ashi Trend Zones detected a clean HA continuation state.")
````
