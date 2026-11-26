# Flag Continuation Zones [AGPro Series]

- url: https://www.tradingview.com/script/WFuveuQS-Flag-Continuation-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;2559752d351442219e721b665aab8fef
- version: 5.0

## Description

🔷 Flag Continuation Zones [AGPro Series]

Flag Continuation Zones is a premium bull flag and bear flag continuation engine designed to identify clean continuation structures without turning the chart into a generic breakout scanner.

The script focuses on a classic, highly recognizable price-action sequence:

impulse pole → controlled flag compression → qualified breakout → forward continuation zone

Instead of marking every small consolidation as a flag, the engine validates the structure through pole strength, travel efficiency, flag depth, channel compression, trend alignment, breakout distance, and optional volume participation.

🔷 What Makes This Different

Most flag indicators are visually simple but structurally loose. They often label shallow pauses, random pullbacks, or broad ranges as flags.

Flag Continuation Zones takes a stricter route.

It first requires a validated impulse pole. The move must be large enough relative to ATR and efficient enough to show directional commitment. After that, the script waits for a controlled counter-trend flag window. The flag must remain compact, avoid excessive retracement, and preserve continuation structure before any breakout is accepted.

This creates a chart experience that is more selective, cleaner, and easier to trust visually.

🔷 How The Engine Works

The script evaluates four core stages:

1. Pole Validation
The prior impulse is measured by ATR multiple and path efficiency. This helps separate real directional movement from noisy grinding price action.

2. Flag Compression
After the pole, the script studies the consolidation window. A valid flag must remain inside an acceptable depth and range relative to the pole.

3. Breakout Confirmation
A continuation event is accepted only when price clears the flag boundary with an ATR buffer and, when available, enough volume participation.

4. Continuation Mapping
Accepted structures create a forward rectangular zone, an impulse pole line, a breakout label, and an optional measured-move projection line.

🔷 Visual Design

The visual language is intentionally restrained:

- clean bull and bear flag labels
- rectangular continuation zones
- impulse pole reference lines
- optional measured-move target line
- trend EMA context
- compact AG Pro status panel
- adjustable panel location
- dark and light panel themes
- adjustable label and panel font sizes

The goal is to make the pattern visible and premium without crowding the chart.

🔷 How This Is Different From Other AGPro Tools

This script is not a generic Trend Continuation Quality tool. It is not an abstract continuation scorecard.

It is specifically built around the flag pattern family:

- impulse pole quality
- flag channel compression
- breakout through the flag boundary
- measured-move continuation context

It also avoids overlapping with triangle, consolidation breakout, Donchian breakout, inside-bar breakout, and trendline tools by staying focused on the pole-and-flag structure itself.

🔷 Best Fit

This script is useful for traders who want to scan for cleaner bull flag and bear flag continuation patterns across crypto, forex, stocks, indices, and futures.

It is especially suitable for:

- continuation traders
- breakout traders who want stricter structure
- price-action traders who follow classic chart patterns
- users who prefer rectangular zones and measured-move context
- traders who want fewer but higher-quality labels

🔷 Key Inputs

Important controls include:

- Pole Lookback
- Flag Window
- Minimum Flag Bars
- Minimum Pole ATR Multiple
- Minimum Pole Efficiency
- Maximum Flag Depth
- Maximum Flag Range
- Breakout Buffer
- Volume Confirmation
- Signal Cooldown
- Zone Forward Bars
- Label Font Size
- Panel Location
- Panel Theme
- Panel Font Size

🔷 In One Sentence

Flag Continuation Zones turns the classic bull flag and bear flag pattern into a cleaner, scored, zone-based continuation map built for premium public chart presentation.

## Source Code

````pine
// -------------------------------------------------
// Flag Continuation Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 3.3
//
// Flag Continuation Zones is a chart-first bull flag and bear flag planner
// for continuation structure, impulse pole context, compression zones,
// breakout confirmation, measured-move targets, and a compact decision panel.
// Version 3.2 adds a confirmation-anchored proof layer (Follow, Hold, React,
// Flip rates) showing how often confirmed flag breakouts continued toward the
// measured move before the flag boundary was lost.
// -------------------------------------------------

//@version=6
indicator("Flag Continuation Zones [AGPro Series]",
     shorttitle       = "AG Pro FCZ",
     overlay          = true,
     max_boxes_count  = 140,
     max_lines_count  = 140,
     max_labels_count = 180)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgD      = color.rgb(15, 23, 42)
panelBorderD  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelValueD   = color.rgb(226, 232, 240)
panelBgL      = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpDetection = "Detection"
grpQuality = "Quality Filters"
grpVisuals = "Visuals"
grpPanel = "Panel"
grpProof = "Proof"
grpAlerts = "Alerts"

enginePreset = input.string("Modern Balanced", "Engine Preset", options = ["Modern Balanced", "Cleaner Swing", "Rich Context", "Custom"], group = grpDetection,
     tooltip = "Selects the behavior profile. Modern Balanced is the publication default, Cleaner Swing is stricter, Rich Context keeps more visible structure, and Custom uses the raw settings.")
poleLookback = input.int(12, "Pole Lookback", minval = 6, maxval = 80, group = grpDetection,
     tooltip = "Bars used to evaluate the impulse pole before a continuation flag can be planned.")
flagWindow = input.int(18, "Flag Window", minval = 6, maxval = 60, group = grpDetection,
     tooltip = "Bars used to evaluate controlled compression after an impulse pole.")
minFlagBars = input.int(4, "Minimum Flag Bars", minval = 2, maxval = 30, group = grpDetection,
     tooltip = "Minimum bars after a pole before a setup or breakout can qualify.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 80, group = grpDetection,
     tooltip = "ATR normalizes pole strength, compression size, breakout buffers, target projections, and label spacing.")
trendLen = input.int(50, "Trend EMA Length", minval = 10, maxval = 240, group = grpDetection,
     tooltip = "EMA used as trend context for bull and bear continuation structures.")

minPoleAtr = input.float(1.35, "Minimum Pole ATR Multiple", minval = 0.50, maxval = 8.00, step = 0.05, group = grpQuality,
     tooltip = "Minimum impulse size measured in ATR. Lower values reveal more early continuation context.")
minPoleEfficiency = input.float(0.30, "Minimum Pole Efficiency", minval = 0.10, maxval = 0.95, step = 0.05, group = grpQuality,
     tooltip = "Requires the impulse to travel efficiently instead of grinding through excessive two-way movement.")
maxFlagDepthPct = input.float(68.0, "Maximum Flag Depth %", minval = 15.0, maxval = 95.0, step = 1.0, group = grpQuality,
     tooltip = "Maximum retracement depth of the flag relative to the pole.")
maxFlagRangePct = input.float(110.0, "Maximum Flag Range %", minval = 20.0, maxval = 160.0, step = 1.0, group = grpQuality,
     tooltip = "Maximum compression height relative to the pole. Higher values keep more visible flag candidates.")
breakoutBufferAtr = input.float(0.04, "Breakout Buffer ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = grpQuality,
     tooltip = "ATR buffer beyond the flag boundary required before breakout continuation is accepted.")
useVolumeConfirm = input.bool(false, "Use Volume Confirmation", group = grpQuality,
     tooltip = "When enabled and volume data is available, breakouts must show relative participation.")
volumeLen = input.int(20, "Volume Average Length", minval = 5, maxval = 120, group = grpQuality,
     tooltip = "Volume average length used for optional breakout participation checks.")
minVolumeMultiple = input.float(1.00, "Minimum Volume Multiple", minval = 0.50, maxval = 4.00, step = 0.05, group = grpQuality,
     tooltip = "Required breakout volume relative to its average when volume confirmation is enabled.")
minSetupQuality = input.int(66, "Minimum Setup Quality", minval = 40, maxval = 100, group = grpQuality,
     tooltip = "Minimum 0-100 setup quality required before a continuation zone is promoted from watch to setup.")
setupCooldownBars = input.int(18, "Setup Cooldown Bars", minval = 1, maxval = 160, group = grpQuality,
     tooltip = "Minimum bars between setup labels. The script also limits each active flag candidate to one setup label.")
breakoutCooldownBars = input.int(18, "Breakout Cooldown Bars", minval = 1, maxval = 160, group = grpQuality,
     tooltip = "Minimum bars between breakout labels.")
poleCooldownBars = input.int(28, "Pole Label Cooldown Bars", minval = 1, maxval = 200, group = grpQuality,
     tooltip = "Minimum bars between major impulse pole labels.")

showTrendEma = input.bool(true, "Show Trend EMA", group = grpVisuals,
     tooltip = "Displays the trend EMA used by the continuation filter.")
showFlagZones = input.bool(true, "Show Continuation Zones", group = grpVisuals,
     tooltip = "Draws qualified continuation zones around accepted flag structures.")
showLiveWatchZone = input.bool(true, "Show Live Watch Zone", group = grpVisuals,
     tooltip = "Shows the current pole-locked compression area before a full setup qualifies.")
showZoneLabels = input.bool(true, "Show Centered Zone Labels", group = grpVisuals,
     tooltip = "Places a separate centered label inside flag zones and live watch zones.")
showPoleLines = input.bool(true, "Show Pole Lines", group = grpVisuals,
     tooltip = "Draws the impulse pole that anchors each accepted setup.")
showPoleLabels = input.bool(true, "Show Pole Labels", group = grpVisuals,
     tooltip = "Shows compact Pole labels only for major impulse anchors so lower-timeframe charts stay readable.")
showSetupLabels = input.bool(true, "Show Setup Labels", group = grpVisuals,
     tooltip = "Shows Bull Setup and Bear Setup labels when compression quality qualifies.")
showBreakoutLabels = input.bool(true, "Show Breakout Labels", group = grpVisuals,
     tooltip = "Shows Bull Break and Bear Break labels when continuation confirms.")
showTargets = input.bool(true, "Show Measured Move Target", group = grpVisuals,
     tooltip = "Draws measured-move projection lines after accepted breakouts.")
showTargetTags = input.bool(true, "Show Target Tags", group = grpVisuals,
     tooltip = "Adds right-side target tags to measured-move projection lines.")
zoneForwardBars = input.int(24, "Zone Forward Bars", minval = 5, maxval = 240, group = grpVisuals,
     tooltip = "How far zones and target lines project to the right.")
zoneMaxAgeBars = input.int(160, "Zone Max Age Bars", minval = 20, maxval = 700, group = grpVisuals,
     tooltip = "Maximum age of historical zones before they are removed.")
maxActiveZones = input.int(5, "Max Active Zones", minval = 1, maxval = 20, group = grpVisuals,
     tooltip = "Maximum continuation zones kept on chart.")
maxEventLabels = input.int(12, "Max Event Labels", minval = 4, maxval = 80, group = grpVisuals,
     tooltip = "Maximum pole, setup, breakout, and target labels retained on chart.")
zoneOpacity = input.int(90, "Zone Opacity", minval = 70, maxval = 96, group = grpVisuals,
     tooltip = "Controls how subtle continuation-zone fill appears.")
labelOffsetAtr = input.float(0.70, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = grpVisuals,
     tooltip = "ATR-based spacing used to keep labels readable around candles and zones.")
targetMultiple = input.float(1.00, "Measured Move Multiple", minval = 0.25, maxval = 2.00, step = 0.05, group = grpVisuals,
     tooltip = "Projection multiplier applied to pole size after continuation breakout.")
targetTagOffsetBars = input.int(4, "Target Tag Offset Bars", minval = 1, maxval = 40, group = grpVisuals,
     tooltip = "Bars between target line endpoint and right-side target tag.")
labelSizeOpt = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisuals,
     tooltip = "Controls every chart label size. Normal is the publication default.")
bullZoneColor = input.color(color.rgb(34, 197, 166), "Bull Flag Color", group = grpVisuals,
     tooltip = "Color used for bullish continuation zones and labels.")
bearZoneColor = input.color(color.rgb(244, 114, 182), "Bear Flag Color", group = grpVisuals,
     tooltip = "Color used for bearish continuation zones and labels.")

showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Shows the AG Pro flag continuation status panel.")
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpPanel,
     tooltip = "Selects where the AG Pro status panel appears.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel,
     tooltip = "Switches the panel between dark and light themes.")
panelSizeOpt = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Controls panel text size. Normal is the default.")
panelMemoryBars = input.int(160, "Panel Memory Bars", minval = 20, maxval = 700, group = grpPanel,
     tooltip = "How long the panel keeps the latest accepted flag context visible.")

showProof = input.bool(true, "Show Proof Layer", group = grpProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across confirmed flag breakouts on the current symbol and timeframe. Follow means a confirmed breakout continued one risk unit (1R) toward the measured move, or reached a nearer target, before the flag boundary was lost. These are historical outcome rates, not predictions.")
proofHorizonBars = input.int(40, "Proof Horizon Bars", minval = 5, maxval = 300, group = grpProof,
     tooltip = "Maximum number of bars each confirmed breakout is tracked for the proof measurement before it resolves at its current outcome.")
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = grpProof,
     tooltip = "Number of bars after a breakout confirms used to detect an immediate favorable continuation reaction.")
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = grpProof,
     tooltip = "Minimum favorable continuation progress toward the 1R target, within the reaction window, required to count as an early React.")

alertBullSetup = input.bool(true, "Alert on Bull Flag Setup", group = grpAlerts,
     tooltip = "Creates an alert condition when a bullish flag setup qualifies.")
alertBearSetup = input.bool(true, "Alert on Bear Flag Setup", group = grpAlerts,
     tooltip = "Creates an alert condition when a bearish flag setup qualifies.")
alertBreakouts = input.bool(true, "Alert on Flag Breakout", group = grpAlerts,
     tooltip = "Creates alert conditions when accepted flag breakouts confirm.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_sum_over(series float source, int length) =>
    float total = 0.0
    for i = 0 to length - 1
        total += nz(source[i])
    total

f_size(string opt) =>
    switch opt
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string opt) =>
    switch opt
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : panelBgL) : (alt ? color.rgb(24, 35, 55) : panelBgD)

f_fmt(float value) =>
    na(value) ? "--" : str.tostring(value, "#.##")

f_grade(float score) =>
    score >= 88 ? "A+" : score >= 78 ? "A" : score >= 66 ? "B" : score >= 54 ? "C" : "D"

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_push_label(array<label> store, label item, int limit) =>
    array.push(store, item)
    while array.size(store) > limit
        label oldItem = array.shift(store)
        if not na(oldItem)
            label.delete(oldItem)

f_push_line(array<line> store, line item, int limit) =>
    array.push(store, item)
    while array.size(store) > limit
        line oldItem = array.shift(store)
        if not na(oldItem)
            line.delete(oldItem)

// -------------------------------------------------
// Presets
// -------------------------------------------------
cleanerPreset = enginePreset == "Cleaner Swing"
richPreset = enginePreset == "Rich Context"
usedMinPoleAtr = cleanerPreset ? math.max(minPoleAtr, 1.70) : richPreset ? math.min(minPoleAtr, 1.10) : minPoleAtr
usedMinPoleEfficiency = cleanerPreset ? math.max(minPoleEfficiency, 0.38) : richPreset ? math.min(minPoleEfficiency, 0.24) : minPoleEfficiency
usedMinSetupQuality = cleanerPreset ? math.max(minSetupQuality, 74) : richPreset ? math.min(minSetupQuality, 58) : minSetupQuality
usedSetupCooldown = cleanerPreset ? math.max(setupCooldownBars, 22) : richPreset ? math.max(setupCooldownBars, 10) : setupCooldownBars
usedBreakoutCooldown = cleanerPreset ? math.max(breakoutCooldownBars, 22) : richPreset ? math.max(breakoutCooldownBars, 10) : breakoutCooldownBars
usedPoleCooldown = cleanerPreset ? math.max(poleCooldownBars, 36) : richPreset ? math.max(poleCooldownBars, 16) : poleCooldownBars
usedMaxZones = cleanerPreset ? math.min(maxActiveZones, 4) : richPreset ? math.min(maxActiveZones + 1, 8) : maxActiveZones
usedMaxLabels = cleanerPreset ? math.min(maxEventLabels, 8) : richPreset ? math.min(maxEventLabels + 4, 20) : maxEventLabels

chartSeconds = timeframe.in_seconds(timeframe.period)
belowBestView = timeframe.isintraday and not na(chartSeconds) and chartSeconds < 14400
bestViewText = belowBestView ? "Use 4H / 1D" : timeframe.isweekly ? "1W / 1D / 4H" : "4H / 1D"

// -------------------------------------------------
// Core Engine
// -------------------------------------------------
labelSize = f_size(labelSizeOpt)
panelTextSize = f_size(panelSizeOpt)
atrRaw = ta.atr(atrLen)
atrSafe = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
trendEma = ta.ema(close, trendLen)
trValue = ta.tr(true)
pathTravel = f_sum_over(trValue, poleLookback)
hasHistory = bar_index > poleLookback + flagWindow + 5 and not na(trendEma)

poleMoveNow = close - close[poleLookback]
absPoleNow = math.abs(poleMoveNow)
poleAtrNow = absPoleNow / atrSafe
poleEfficiencyNow = pathTravel > 0.0 ? absPoleNow / pathTravel : 0.0
bullTrendContext = close > trendEma or ta.ema(close, math.max(5, int(math.round(trendLen * 0.50)))) > trendEma
bearTrendContext = close < trendEma or ta.ema(close, math.max(5, int(math.round(trendLen * 0.50)))) < trendEma
bullPoleNow = hasHistory and poleMoveNow > atrSafe * usedMinPoleAtr and poleEfficiencyNow >= usedMinPoleEfficiency and bullTrendContext
bearPoleNow = hasHistory and poleMoveNow < -atrSafe * usedMinPoleAtr and poleEfficiencyNow >= usedMinPoleEfficiency and bearTrendContext

var int candidateSide = 0
var int candidatePoleBar = na
var int candidatePoleStartBar = na
var float candidatePoleStart = na
var float candidatePoleEnd = na
var float candidatePoleMove = na
var float candidatePoleAtr = na
var float candidatePoleEfficiency = na
var bool setupPrinted = false
var int lastPoleLabelBar = na
var int lastSetupBar = na
var int lastBreakoutBar = na
var string panelSide = "Neutral"
var string panelPhase = "Scanning"
var float panelQuality = na
var float panelDepth = na
var float panelPoleAtr = na
var string panelAction = "Wait"
var int lastPanelEventBar = na

barsAfterPole = not na(candidatePoleBar) ? bar_index - candidatePoleBar : 100000
candidateExpired = candidateSide != 0 and barsAfterPole > flagWindow + math.max(8, int(math.round(flagWindow * 0.50)))
if candidateExpired
    candidateSide := 0
    setupPrinted := false

newPoleSide = bullPoleNow ? 1 : bearPoleNow ? -1 : 0
candidateUpgrade = candidateSide != 0 and newPoleSide == candidateSide and poleAtrNow > nz(candidatePoleAtr, 0.0) * 1.14
newPoleAllowed = newPoleSide != 0 and (candidateSide == 0 or newPoleSide != candidateSide or candidateUpgrade or candidateExpired)
newCandidateStart = newPoleAllowed and (candidateSide == 0 or newPoleSide != candidateSide or candidateExpired)
if newPoleAllowed
    candidateSide := newPoleSide
    candidatePoleBar := bar_index
    candidatePoleStartBar := bar_index - poleLookback
    candidatePoleStart := close[poleLookback]
    candidatePoleEnd := close
    candidatePoleMove := poleMoveNow
    candidatePoleAtr := poleAtrNow
    candidatePoleEfficiency := poleEfficiencyNow
    if newCandidateStart
        setupPrinted := false
    panelSide := newPoleSide == 1 ? "Bull Flag Watch" : "Bear Flag Watch"
    panelPhase := "Pole locked"
    panelPoleAtr := poleAtrNow
    panelQuality := na
    panelDepth := na
    panelAction := "Monitor compression"
    lastPanelEventBar := bar_index

barsAfterPole := not na(candidatePoleBar) ? bar_index - candidatePoleBar : 100000
candidateActive = candidateSide != 0 and barsAfterPole >= 1 and barsAfterPole <= flagWindow + math.max(8, int(math.round(flagWindow * 0.50)))
inFlagWindow = candidateActive and barsAfterPole >= minFlagBars
flagHighPrev = ta.highest(high[1], flagWindow)
flagLowPrev = ta.lowest(low[1], flagWindow)
flagHeight = math.max(flagHighPrev - flagLowPrev, syminfo.mintick)
flagSlope = ta.linreg(close, flagWindow, 0) - ta.linreg(close, flagWindow, 1)
poleSize = math.max(math.abs(nz(candidatePoleMove)), syminfo.mintick)
maxDepth = maxFlagDepthPct * 0.01
maxRange = maxFlagRangePct * 0.01
bullDepth = poleSize > 0 ? (candidatePoleEnd - flagLowPrev) / poleSize : na
bearDepth = poleSize > 0 ? (flagHighPrev - candidatePoleEnd) / poleSize : na
flagRangePct = poleSize > 0 ? flagHeight / poleSize : na

volAvg = ta.sma(volume, volumeLen)
hasVolume = not na(volume) and not na(volAvg) and volAvg > 0
volumeOk = not useVolumeConfirm or not hasVolume or volume >= volAvg * minVolumeMultiple
activeDepth = candidateSide == 1 ? bullDepth : candidateSide == -1 ? bearDepth : na
depthOk = not na(activeDepth) and activeDepth >= -0.05 and activeDepth <= maxDepth
rangeOk = not na(flagRangePct) and flagRangePct <= maxRange
compressionOk = candidateSide == 1 ? flagSlope <= atrSafe * 0.24 : candidateSide == -1 ? flagSlope >= -atrSafe * 0.24 : false
positionOk = candidateSide == 1 ? close > candidatePoleStart + poleSize * 0.10 : candidateSide == -1 ? close < candidatePoleStart - poleSize * 0.10 : false

breakDistance = candidateSide == 1 ? (close - flagHighPrev) / atrSafe : candidateSide == -1 ? (flagLowPrev - close) / atrSafe : 0.0
poleScore = f_clamp((nz(candidatePoleAtr) / usedMinPoleAtr) * 28.0, 0.0, 30.0)
effScore = f_clamp(nz(candidatePoleEfficiency) / math.max(usedMinPoleEfficiency, 0.01) * 15.0, 0.0, 18.0)
depthScore = f_clamp((1.0 - nz(activeDepth, maxDepth)) / math.max(maxDepth, 0.01) * 18.0, 0.0, 20.0)
rangeScore = f_clamp((1.0 - nz(flagRangePct, maxRange)) / math.max(maxRange, 0.01) * 14.0, 0.0, 15.0)
compressionScore = compressionOk ? 10.0 : 3.0
trendScore = candidateSide == 1 ? (bullTrendContext ? 10.0 : 4.0) : candidateSide == -1 ? (bearTrendContext ? 10.0 : 4.0) : 0.0
volumeScore = volumeOk ? 7.0 : 0.0
breakoutScore = f_clamp(breakDistance * 8.0, 0.0, 8.0)
qualityScore = math.round(f_clamp(poleScore + effScore + depthScore + rangeScore + compressionScore + trendScore + volumeScore + breakoutScore, 0.0, 100.0))

bullSetup = inFlagWindow and candidateSide == 1 and depthOk and rangeOk and compressionOk and positionOk and qualityScore >= usedMinSetupQuality
bearSetup = inFlagWindow and candidateSide == -1 and depthOk and rangeOk and compressionOk and positionOk and qualityScore >= usedMinSetupQuality
canSetupLabel = na(lastSetupBar) or bar_index - lastSetupBar > usedSetupCooldown
canBreakoutLabel = na(lastBreakoutBar) or bar_index - lastBreakoutBar > usedBreakoutCooldown
bullBreak = bullSetup and close > flagHighPrev + atrSafe * breakoutBufferAtr and close > open and volumeOk and canBreakoutLabel
bearBreak = bearSetup and close < flagLowPrev - atrSafe * breakoutBufferAtr and close < open and volumeOk and canBreakoutLabel
setupSignal = (bullSetup or bearSetup) and not setupPrinted and canSetupLabel and not (bullBreak or bearBreak)
breakSignal = bullBreak or bearBreak

if candidateActive
    panelSide := candidateSide == 1 ? "Bull Watch" : "Bear Watch"
    panelPhase := inFlagWindow ? depthOk and rangeOk ? "Compression" : "Review" : "Pole locked"
    panelDepth := not na(activeDepth) ? activeDepth * 100.0 : na
    panelPoleAtr := candidatePoleAtr
    panelQuality := qualityScore
    panelAction := qualityScore >= usedMinSetupQuality ? "Review setup" : "Wait shape"
    lastPanelEventBar := bar_index

// -------------------------------------------------
// Confirmation-anchored proof (confirmed breakouts, Follow = continued 1R toward measured move before flag lost)
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

int breakDir = bullBreak ? 1 : bearBreak ? -1 : 0
int proofWarmup = trendLen + poleLookback + flagWindow + 5
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
        if naturalResolve or breakSignal
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
    if breakSignal and not pEvalActive and breakDir != 0
        pEvalActive := true
        pEvalDir := breakDir
        pEvalEntry := close
        pEvalStop := breakDir == 1 ? flagLowPrev : flagHighPrev
        float pStopDist = math.max(math.abs(close - pEvalStop), syminfo.mintick)
        float pTargetFull = close + breakDir * poleSize * targetMultiple
        float pRoomDist = math.max(math.abs(pTargetFull - close), syminfo.mintick)
        float pFollowDist = math.max(math.min(pStopDist, pRoomDist), syminfo.mintick)
        pEvalTarget := close + breakDir * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Drawing Objects
// -------------------------------------------------
var array<box> zoneBoxes = array.new<box>()
var array<label> zoneLabels = array.new<label>()
var array<int> zoneSides = array.new<int>()
var array<int> zoneBirthBars = array.new<int>()
var array<line> poleLines = array.new<line>()
var array<line> targetLines = array.new<line>()
var array<label> eventLabels = array.new<label>()
var box watchBox = na
var label watchLabel = na
var line watchLine = na

if array.size(zoneBoxes) > 0
    zoneCount = array.size(zoneBoxes)
    for idx = 0 to zoneCount - 1
        revIdx = zoneCount - 1 - idx
        activeBox = array.get(zoneBoxes, revIdx)
        activeSide = array.get(zoneSides, revIdx)
        activeBirthBar = array.get(zoneBirthBars, revIdx)
        boxTop = box.get_top(activeBox)
        boxBottom = box.get_bottom(activeBox)
        invalidZone = activeSide == 1 ? close < boxBottom : close > boxTop
        expiredZone = bar_index - activeBirthBar > zoneMaxAgeBars
        if invalidZone or expiredZone
            box.delete(activeBox)
            array.remove(zoneBoxes, revIdx)
            if array.size(zoneLabels) > revIdx
                oldZoneLabel = array.remove(zoneLabels, revIdx)
                label.delete(oldZoneLabel)
            array.remove(zoneSides, revIdx)
            array.remove(zoneBirthBars, revIdx)
        else
            box.set_right(activeBox, bar_index + zoneForwardBars)

plot(showTrendEma ? trendEma : na, "Trend EMA", color = color.new(accentColor, 15), linewidth = 2)

majorPole = newPoleAllowed and poleAtrNow >= usedMinPoleAtr * (richPreset ? 2.00 : cleanerPreset ? 3.00 : 2.55) and poleEfficiencyNow >= usedMinPoleEfficiency * (richPreset ? 1.00 : 1.15)
canPoleLabel = showPoleLabels and majorPole and (na(lastPoleLabelBar) or bar_index - lastPoleLabelBar > usedPoleCooldown)
if canPoleLabel
    poleColor = newPoleSide == 1 ? bullZoneColor : bearZoneColor
    poleX = int(math.round((candidatePoleStartBar + candidatePoleBar) * 0.5))
    poleY = (candidatePoleStart + candidatePoleEnd) * 0.5
    poleLabel = label.new(poleX, poleY, "Pole\n" + f_fmt(candidatePoleAtr) + " ATR",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_center,
         color = color.new(poleColor, 0),
         textcolor = headerText,
         size = labelSize,
         textalign = text.align_center)
    f_push_label(eventLabels, poleLabel, usedMaxLabels)
    lastPoleLabelBar := bar_index

watchVisible = showLiveWatchZone and showFlagZones and candidateActive and not (bullSetup or bearSetup or bullBreak or bearBreak)
if watchVisible
    watchColor = candidateSide == 1 ? bullZoneColor : bearZoneColor
    watchLeft = math.max(candidatePoleBar, bar_index - flagWindow)
    watchRight = bar_index + math.max(8, int(math.round(zoneForwardBars * 0.62)))
    watchTop = ta.highest(high, flagWindow)
    watchBottom = ta.lowest(low, flagWindow)
    watchX = int(math.round((watchLeft + watchRight) * 0.5))
    watchY = (watchTop + watchBottom) * 0.5
    watchText = candidateSide == 1 ? "Bull Watch\nQ " + str.tostring(qualityScore, "#") : "Bear Watch\nQ " + str.tostring(qualityScore, "#")
    if na(watchBox)
        watchBox := box.new(watchLeft, watchTop, watchRight, watchBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(watchColor, 94),
             border_color = color.new(watchColor, 42),
             border_width = 1)
    else
        box.set_left(watchBox, watchLeft)
        box.set_right(watchBox, watchRight)
        box.set_top(watchBox, watchTop)
        box.set_bottom(watchBox, watchBottom)
        box.set_bgcolor(watchBox, color.new(watchColor, 94))
        box.set_border_color(watchBox, color.new(watchColor, 42))
    if na(watchLine)
        watchLine := line.new(candidatePoleStartBar, candidatePoleStart, candidatePoleBar, candidatePoleEnd,
             xloc = xloc.bar_index,
             color = color.new(watchColor, 0),
             width = 2)
    else
        line.set_xy1(watchLine, candidatePoleStartBar, candidatePoleStart)
        line.set_xy2(watchLine, candidatePoleBar, candidatePoleEnd)
        line.set_color(watchLine, color.new(watchColor, 0))
    if showZoneLabels
        if na(watchLabel)
            watchLabel := label.new(watchX, watchY, watchText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_center,
                 color = color.new(watchColor, 0),
                 textcolor = headerText,
                 size = labelSize,
                 textalign = text.align_center)
        else
            label.set_x(watchLabel, watchX)
            label.set_y(watchLabel, watchY)
            label.set_text(watchLabel, watchText)
            label.set_color(watchLabel, color.new(watchColor, 0))
            label.set_textcolor(watchLabel, headerText)
            label.set_size(watchLabel, labelSize)
    else if not na(watchLabel)
        label.delete(watchLabel)
        watchLabel := na
else
    if not na(watchBox)
        box.delete(watchBox)
        watchBox := na
    if not na(watchLine)
        line.delete(watchLine)
        watchLine := na
    if not na(watchLabel)
        label.delete(watchLabel)
        watchLabel := na

if setupSignal
    signalSide = bullSetup ? 1 : -1
    sideColor = signalSide == 1 ? bullZoneColor : bearZoneColor
    zoneText = signalSide == 1 ? "Bull Flag\nQ " + str.tostring(qualityScore, "#") : "Bear Flag\nQ " + str.tostring(qualityScore, "#")
    setupText = signalSide == 1 ? "Bull Setup\nQ " + str.tostring(qualityScore, "#") : "Bear Setup\nQ " + str.tostring(qualityScore, "#")
    if showFlagZones
        setupBox = box.new(bar_index - flagWindow, flagHighPrev, bar_index + zoneForwardBars, flagLowPrev,
             xloc = xloc.bar_index,
             bgcolor = color.new(sideColor, zoneOpacity),
             border_color = color.new(sideColor, 18),
             border_width = qualityScore >= 84 ? 2 : 1)
        array.push(zoneBoxes, setupBox)
        array.push(zoneSides, signalSide)
        array.push(zoneBirthBars, bar_index)
        if showZoneLabels
            zoneLabelX = bar_index - flagWindow + int(math.round((flagWindow + zoneForwardBars) * 0.5))
            zoneLabelY = (flagHighPrev + flagLowPrev) * 0.5
            zoneLabel = label.new(zoneLabelX, zoneLabelY, zoneText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_center,
                 color = color.new(sideColor, 0),
                 textcolor = headerText,
                 size = labelSize,
                 textalign = text.align_center)
            array.push(zoneLabels, zoneLabel)
    if showPoleLines and not na(candidatePoleStartBar) and not na(candidatePoleBar)
        setupPole = line.new(candidatePoleStartBar, candidatePoleStart, candidatePoleBar, candidatePoleEnd,
             xloc = xloc.bar_index,
             color = color.new(sideColor, 0),
             width = 2)
        f_push_line(poleLines, setupPole, usedMaxZones)
    if showSetupLabels
        setupGap = atrSafe * math.max(labelOffsetAtr, 0.75)
        setupY = signalSide == 1 ? flagLowPrev - setupGap : flagHighPrev + setupGap
        setupLabel = label.new(bar_index, setupY, setupText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = signalSide == 1 ? label.style_label_up : label.style_label_down,
             color = color.new(sideColor, 0),
             textcolor = headerText,
             size = labelSize)
        f_push_label(eventLabels, setupLabel, usedMaxLabels)
    lastSetupBar := bar_index
    setupPrinted := true
    panelSide := signalSide == 1 ? "Bull Flag" : "Bear Flag"
    panelPhase := "Setup"
    panelQuality := qualityScore
    panelDepth := activeDepth * 100.0
    panelPoleAtr := candidatePoleAtr
    panelAction := "Review breakout"
    lastPanelEventBar := bar_index

while array.size(zoneBoxes) > usedMaxZones
    oldBox = array.shift(zoneBoxes)
    box.delete(oldBox)
    if array.size(zoneLabels) > 0
        oldZoneLabel = array.shift(zoneLabels)
        label.delete(oldZoneLabel)
    array.shift(zoneSides)
    array.shift(zoneBirthBars)

if breakSignal
    signalSide = bullBreak ? 1 : -1
    sideColor = signalSide == 1 ? bullZoneColor : bearZoneColor
    targetPrice = close + signalSide * poleSize * targetMultiple
    targetRightX = bar_index + zoneForwardBars + (showTargetTags ? targetTagOffsetBars : 0)
    breakText = signalSide == 1 ? "Bull Break\nQ " + str.tostring(qualityScore, "#") : "Bear Break\nQ " + str.tostring(qualityScore, "#")
    if showTargets
        targetLine = line.new(bar_index, targetPrice, targetRightX, targetPrice,
             xloc = xloc.bar_index,
             color = color.new(accentColor, 0),
             style = line.style_dotted,
             width = 2)
        f_push_line(targetLines, targetLine, usedMaxZones)
        if showTargetTags
            targetTag = label.new(targetRightX, targetPrice, "Target " + str.tostring(targetPrice, format.mintick),
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_left,
                 color = color.new(accentColor, 0),
                 textcolor = headerText,
                 size = labelSize)
            f_push_label(eventLabels, targetTag, usedMaxLabels)
    if showBreakoutLabels
        breakY = signalSide == 1 ? low - atrSafe * math.max(labelOffsetAtr, 0.75) : high + atrSafe * math.max(labelOffsetAtr, 0.75)
        breakLabel = label.new(bar_index, breakY, breakText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = signalSide == 1 ? label.style_label_up : label.style_label_down,
             color = color.new(sideColor, 0),
             textcolor = headerText,
             size = labelSize)
        f_push_label(eventLabels, breakLabel, usedMaxLabels)
    lastBreakoutBar := bar_index
    panelSide := signalSide == 1 ? "Bull Flag" : "Bear Flag"
    panelPhase := "Breakout"
    panelQuality := qualityScore
    panelDepth := activeDepth * 100.0
    panelPoleAtr := candidatePoleAtr
    panelAction := "Review target"
    lastPanelEventBar := bar_index
    candidateSide := 0
    setupPrinted := false

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertBullSetup and setupSignal and bullSetup, "Bull Flag Setup", "Flag Continuation Zones: bullish flag setup reached qualified continuation context.")
alertcondition(alertBearSetup and setupSignal and bearSetup, "Bear Flag Setup", "Flag Continuation Zones: bearish flag setup reached qualified continuation context.")
alertcondition(alertBreakouts and bullBreak, "Bull Flag Breakout", "Flag Continuation Zones: bullish flag continuation breakout confirmed.")
alertcondition(alertBreakouts and bearBreak, "Bear Flag Breakout", "Flag Continuation Zones: bearish flag continuation breakout confirmed.")

// -------------------------------------------------
// Panel
// -------------------------------------------------
activeZoneCount = array.size(zoneBoxes)
activeBullZones = 0
activeBearZones = 0
if activeZoneCount > 0
    for zoneIdx = 0 to activeZoneCount - 1
        sideAtIdx = array.get(zoneSides, zoneIdx)
        activeBullZones += sideAtIdx == 1 ? 1 : 0
        activeBearZones += sideAtIdx == -1 ? 1 : 0

panelMemoryFresh = not na(lastPanelEventBar) and bar_index - lastPanelEventBar <= panelMemoryBars
if not candidateActive and activeZoneCount > 0
    panelSide := activeBullZones > 0 and activeBearZones > 0 ? "Mixed Zones" : activeBullZones > 0 ? "Bull Zones" : "Bear Zones"
    panelPhase := "Monitoring"
else if not candidateActive and activeZoneCount == 0 and not panelMemoryFresh
    panelSide := "Neutral"
    panelPhase := "Scanning"
    panelQuality := na
    panelDepth := na
    panelPoleAtr := na
    panelAction := "Wait"

scoreText = na(panelQuality) ? "Pending" : str.tostring(panelQuality, "#") + "/100 " + f_grade(panelQuality)
depthText = na(panelDepth) ? "--" : str.tostring(panelDepth, "#") + "%"
poleText = na(panelPoleAtr) ? "--" : f_fmt(panelPoleAtr) + " ATR"
phaseColor = panelPhase == "Breakout" ? bullColor : panelPhase == "Setup" ? accentColor : panelPhase == "Compression" ? neutralColor : panelValueD
scoreColor = na(panelQuality) ? neutralColor : panelQuality >= usedMinSetupQuality ? bullColor : neutralColor

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "--"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "--"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "--"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "--"

isLightPanel = panelTheme == "Light"
panelBodyBg = f_panel_bg(isLightPanel, false)
panelAltBg = f_panel_bg(isLightPanel, true)
panelBodyBorder = isLightPanel ? panelBorderL : panelBorderD
panelLabelText = isLightPanel ? panelLabelL : panelLabelD
panelValueText = isLightPanel ? panelValueL : panelValueD

color followColPanel = proofTotal > 0 ? f_rate_color(followRate) : panelValueText
color holdColPanel = proofTotal > 0 ? f_rate_color(holdRate) : panelValueText
color reactColPanel = proofTotal > 0 ? f_rate_color(reactRate) : panelValueText
color flipColPanel = proofTotal > 0 ? f_flip_color(flipRate) : panelValueText

int panelRowCount = showProof ? 12 : 7
var table infoPanel = na
var string prevPanelLocation = ""
var string prevPanelTheme = ""
var bool prevProofMode = false

panelNeedsRebuild = showPanel and (na(infoPanel) or prevPanelLocation != panelLocation or prevPanelTheme != panelTheme or prevProofMode != showProof)
if panelNeedsRebuild
    if not na(infoPanel)
        table.delete(infoPanel)
    infoPanel := table.new(f_pos(panelLocation), 2, panelRowCount,
         bgcolor = panelBodyBg,
         frame_color = panelBodyBorder,
         frame_width = 1,
         border_color = panelBodyBorder,
         border_width = 1)
    table.cell(infoPanel, 0, 0, "AG Pro Flag Continuation Zones", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(infoPanel, 1, 0, "", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize)
    table.merge_cells(infoPanel, 0, 0, 1, 0)
    prevPanelLocation := panelLocation
    prevPanelTheme := panelTheme
    prevProofMode := showProof

if not showPanel and not na(infoPanel)
    table.delete(infoPanel)
    infoPanel := na
    prevPanelLocation := ""
    prevPanelTheme := ""

if showPanel and not na(infoPanel) and barstate.islast
    table.set_position(infoPanel, f_pos(panelLocation))
    table.clear(infoPanel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(infoPanel, 0, 0, 1, 0)
    table.cell(infoPanel, 0, 0, "AG Pro Flag Continuation Zones", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(infoPanel, 0, 1, "Side", bgcolor = panelBodyBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(infoPanel, 1, 1, panelSide, bgcolor = panelBodyBg, text_color = panelValueText, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(infoPanel, 0, 2, "Phase", bgcolor = panelAltBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(infoPanel, 1, 2, panelPhase, bgcolor = panelAltBg, text_color = phaseColor, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(infoPanel, 0, 3, "Pole", bgcolor = panelBodyBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(infoPanel, 1, 3, poleText, bgcolor = panelBodyBg, text_color = panelValueText, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(infoPanel, 0, 4, "Flag Depth", bgcolor = panelAltBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(infoPanel, 1, 4, depthText, bgcolor = panelAltBg, text_color = panelValueText, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(infoPanel, 0, 5, "Quality", bgcolor = panelBodyBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(infoPanel, 1, 5, scoreText, bgcolor = panelBodyBg, text_color = scoreColor, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(infoPanel, 0, 6, "Action", bgcolor = panelAltBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(infoPanel, 1, 6, panelAction, bgcolor = panelAltBg, text_color = phaseColor, text_size = panelTextSize, text_halign = text.align_right)
    if showProof
        table.cell(infoPanel, 0, 7, "Proof @ Confirm", bgcolor = panelBodyBg, text_color = accentColor, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 7, proofSampleText, bgcolor = panelBodyBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 8, "Follow Rate", bgcolor = panelAltBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 8, followTextPanel, bgcolor = panelAltBg, text_color = followColPanel, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 9, "Hold Rate", bgcolor = panelBodyBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 9, holdTextPanel, bgcolor = panelBodyBg, text_color = holdColPanel, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 10, "React Rate", bgcolor = panelAltBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 10, reactTextPanel, bgcolor = panelAltBg, text_color = reactColPanel, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(infoPanel, 0, 11, "Flip Rate", bgcolor = panelBodyBg, text_color = panelLabelText, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(infoPanel, 1, 11, flipTextPanel, bgcolor = panelBodyBg, text_color = flipColPanel, text_size = panelTextSize, text_halign = text.align_right)

plot(qualityScore, "FCZ Quality Score", display = display.none)
plot(candidateSide, "FCZ Candidate Side", display = display.none)
plot(followRate, "FCZ Follow Rate", display = display.none)
plot(holdRate, "FCZ Hold Rate", display = display.none)
plot(reactRate, "FCZ React Rate", display = display.none)
plot(flipRate, "FCZ Flip Rate", display = display.none)
````
