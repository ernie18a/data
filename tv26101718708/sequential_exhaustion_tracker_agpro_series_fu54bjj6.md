# Sequential Exhaustion Tracker [AGPro Series]

- url: https://www.tradingview.com/script/Fu54bJj6-Sequential-Exhaustion-Tracker-AGPro-Series/
- type: indicator
- pine_id: PUB;27454bfe00f94fceb7731a0ff24545da
- version: 4.0

## Description

Sequential Exhaustion Tracker [AGPro Series]

🔷 Overview

Sequential Exhaustion Tracker [AGPro Series] is a price-action based trend maturity tool built for traders who want to read how far a directional candle sequence has developed, when that sequence is becoming late-stage, and whether the market is more likely to recycle the move or fail back through its terminal zone.

The script is not an oscillator, not a crossover tool, and not a protected-brand sequential clone. It does not depend on classic overbought or oversold thresholds. Instead, it tracks qualified directional progress bar by bar, measures the quality of the active count, opens a visual exhaustion window when the run becomes mature, and then follows the next phase as either recycle, testing, or failure.

That makes the script useful for a very specific question:

Is the current directional run still building cleanly, or has it entered the kind of late-sequence area where follow-through, failure, and reset behavior need closer attention?

🔷 What The Script Measures

The engine combines four practical components:

1. Directional candle count
The script counts qualified progress candles in the active direction. A candle must show meaningful close-to-close progress, sufficient body commitment, and optional trend-filter alignment before it can advance the count.

2. Exhaustion threshold
The count becomes mature only after it reaches the selected threshold. This avoids treating every small move as exhaustion and keeps the tool focused on developed directional sequences.

3. Exhaustion quality
The quality model blends count maturity, ATR-normalized stretch from the baseline, opposing wick absorption, and body-efficiency fade. A high reading means the sequence is not only long enough, but also showing late-run characteristics.

4. Recycle/failure lifecycle
Once a qualified exhaustion window appears, the script continues tracking price behavior. Strong continuation through the terminal zone can classify the sequence as recycled. A break back through the zone can classify it as failed. This turns the indicator into a lifecycle tracker instead of a one-bar label generator.

🔷 Visual Design

The chart output is designed to stay premium and readable:

- Compact count labels use milestone-based defaults so the chart shows sequence progress without turning into a label wall.
- ATR-based label offsets keep labels away from candle bodies.
- Exhaustion zones are drawn as rectangular terminal windows, not generic support/resistance blocks.
- Recycle and failure markers are intentionally short and selective.
- Older labels and zones are automatically removed to protect chart performance.
- The summary panel uses the AGPro standard merged blue title row and a clean four-line state readout.

🔷 Panel Readout

The panel summarizes the active condition in a compact format:

Direction
Shows whether the current qualified run is bullish, bearish, or neutral.

Count
Shows the active sequential count against the selected exhaustion threshold.

Exhaustion Quality
Shows the maturity score and the current quality band.

Recycle Status
Shows whether the sequence is building, mature, testing an exhaustion window, recycling, recycled, failed, or waiting.

🔷 How This Differs From Other AGPro Scripts

This script is intentionally separated from AGPro oscillator exhaustion tools.

Stochastic Exhaustion Map focuses on stochastic behavior, momentum fatigue, and reset context inside an oscillator framework.

Williams %R Exhaustion Map focuses on Williams %R extension behavior and release-corridor logic.

Sequential Exhaustion Tracker focuses on the visible candle sequence itself: directional progress, count maturity, terminal exhaustion zone, and post-exhaustion lifecycle behavior.

It is also different from support/resistance reaction tools because the rectangles are not structural S/R zones. They are temporary terminal sequence windows created only when a mature count and exhaustion quality condition are present.

🔷 How This Differs From Common Sequential Count Scripts

Many sequential scripts focus mainly on printing a fixed count and stopping there. Sequential Exhaustion Tracker takes a different path.

It does not simply count bars for visual decoration. It asks whether the count is supported by meaningful directional progress, whether the run has become stretched relative to its own volatility, whether the candle structure is showing absorption, and what happens after the mature sequence appears.

The key difference is the lifecycle layer:

- Building sequence
- Mature count
- Exhaustion window
- Testing window
- Recycle build
- Recycled continuation
- Failed exhaustion window

This gives the script a cleaner analytical role than a basic numbered label tool.

🔷 Suggested Use

The script is best used as a chart-context layer for:

- identifying late-stage directional runs
- separating fresh continuation from mature extension
- watching terminal sequence zones
- studying continuation recycle behavior
- spotting failed late-run pressure
- keeping sequential count context visible without overcrowding the chart

It is designed to complement market structure, trend context, volatility conditions, and the trader's broader workflow.

🔷 Default Settings

The default settings are built for a balanced public-chart presentation:

- Count threshold: 8
- Quality threshold: 62
- Trend alignment: enabled
- Count label mode: Mature Milestones
- Count label start: 6
- Minimum label spacing: 8 bars
- Exhaustion zones: enabled
- Panel: enabled
- Label and panel font sizes: Normal

These defaults aim to keep the chart informative without turning it into a noisy label wall.

🔷 Why It Was Built

Directional markets often move in phases. Early movement can be clean and efficient. Middle movement can be supported and persistent. Late movement can still continue, but the character of the candles often starts to change.

Sequential Exhaustion Tracker was built to make that progression easier to read directly on the chart. The goal is not to call every top or bottom. The goal is to show where the current sequence sits in its own lifecycle and whether the post-exhaustion behavior is confirming continuation, stalling, or failing.

That narrow focus is what makes the tool distinct: it is not a general momentum dashboard, not an oscillator map, not a support/resistance engine, and not a signal checklist. It is a dedicated sequential maturity and lifecycle tracker.

## Source Code

````pine
// -------------------------------------------------
// Sequential Exhaustion Tracker [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Sequential Exhaustion Tracker maps directional candle progression, trend
// maturity, exhaustion-window behavior, recycle/failure status and late-run
// quality without relying on protected sequential branding. It combines
// price-action progression, ATR-normalized stretch, opposing wick absorption,
// body fade, centered exhaustion-zone labels, lifecycle markers, sub-4H visual
// cleanup and a compact AGPro panel for sequence exhaustion analysis.
// V1.2 adds a confirmation-anchored proof layer (Follow, Hold, React, Flip
// rates) measuring how often exhaustion windows produced a reversal against the
// over-extended run before the run continued, and removes the static best-view row.
// V1.3 refreshes the publication presentation only. Core calculations, alerts,
// inputs and runtime behavior remain unchanged.
// -------------------------------------------------

//@version=6
indicator("Sequential Exhaustion Tracker [AGPro Series]",
     shorttitle       = "AG Pro SET",
     overlay          = true,
     max_labels_count = 240,
     max_boxes_count  = 140)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
// Brand
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
// Panel
panelBgD      = color.rgb(15, 23, 42)
panelBorderD  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelValueD   = color.rgb(226, 232, 240)
panelBgL      = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
// States
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
engineGroup = "Sequential Engine"
qualityGroup = "Quality Model"
visualGroup = "Visuals"
panelGroup = "Panel"
alertGroup = "Alerts"

enginePreset = input.string("Swing / 4H", "Engine Preset", options = ["Swing / 4H", "Daily Selective", "Custom"], group = engineGroup,
     tooltip = "Selects the default behavior profile. Swing / 4H balances signal frequency and clarity. Daily Selective is cleaner and more selective. Custom uses the raw inputs below.")

src = input.source(close, "Count Source", group = engineGroup,
     tooltip = "Source used to evaluate directional progress in the sequential count engine.")

trendLen = input.int(34, "Trend Filter Length", minval = 5, maxval = 200, group = engineGroup,
     tooltip = "EMA length used to separate directional progression from weak counter-trend noise.")

useTrendFilter = input.bool(true, "Require Trend Alignment", group = engineGroup,
     tooltip = "When enabled, qualified count bars must align with the selected trend filter.")

minProgressAtr = input.float(0.05, "Minimum Progress ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = engineGroup,
     tooltip = "Minimum close-to-close progress, measured as a fraction of ATR, required for a candle to advance the sequence.")

minBodyShare = input.float(0.18, "Minimum Body Share", minval = 0.00, maxval = 1.00, step = 0.01, group = engineGroup,
     tooltip = "Minimum candle body share required for a bar to count as meaningful directional progress.")

pauseTolerance = input.int(1, "Pause Tolerance", minval = 0, maxval = 5, group = engineGroup,
     tooltip = "Number of neutral bars allowed before the active sequence starts to decay.")

exhaustionThreshold = input.int(8, "Exhaustion Count Threshold", minval = 4, maxval = 20, group = engineGroup,
     tooltip = "Directional count level where a sequence becomes mature enough to be evaluated for exhaustion.")

qualityThreshold = input.int(62, "Quality Threshold", minval = 1, maxval = 100, group = engineGroup,
     tooltip = "Minimum exhaustion quality required before the script opens an exhaustion window.")

recycleThreshold = input.int(3, "Recycle Extension Count", minval = 1, maxval = 10, group = engineGroup,
     tooltip = "Number of continuation closes beyond the exhaustion zone required to classify the run as recycled instead of failed.")

signalCooldown = input.int(14, "Signal Cooldown Bars", minval = 0, maxval = 100, group = engineGroup,
     tooltip = "Minimum spacing between new exhaustion windows, used to keep the chart clean and publication-ready.")

qualitySmoothLen = input.int(4, "Quality Smoothing", minval = 1, maxval = 20, group = qualityGroup,
     tooltip = "EMA smoothing length applied to the final exhaustion quality score.")

stretchAtrCap = input.float(3.00, "Stretch ATR Cap", minval = 0.50, maxval = 10.00, step = 0.25, group = qualityGroup,
     tooltip = "ATR-normalized distance from the trend filter that represents full stretch contribution.")

wickPressureCap = input.float(0.55, "Opposing Wick Cap", minval = 0.10, maxval = 1.00, step = 0.05, group = qualityGroup,
     tooltip = "Opposing wick ratio that represents full absorption contribution in the exhaustion quality model.")

showBaseline = input.bool(true, "Show Sequence Baseline", group = visualGroup,
     tooltip = "Displays the EMA baseline used by the count engine.")

showQualifiedBars = input.bool(true, "Highlight Qualified Bars", group = visualGroup,
     tooltip = "Subtly colors bars that advance the active directional sequence.")

showCountLabels = input.bool(true, "Show Count Labels", group = visualGroup,
     tooltip = "Displays restrained count labels after the sequence reaches the selected label start.")

countLabelMode = input.string("Threshold Only", "Count Label Mode", options = ["Mature Milestones", "Milestones", "Step", "Threshold Only"], group = visualGroup,
     tooltip = "Controls count label density. Threshold Only is the cleanest publication default because exhaustion zones already carry the main visual signal.")

countLabelStart = input.int(6, "Count Label Start", minval = 1, maxval = 20, group = visualGroup,
     tooltip = "First count value that is allowed to print a visible count label.")

countLabelStep = input.int(2, "Count Label Step", minval = 1, maxval = 5, group = visualGroup,
     tooltip = "Controls how frequently count labels appear when Step mode is selected.")

minLabelSpacingBars = input.int(8, "Minimum Label Spacing", minval = 0, maxval = 50, group = visualGroup,
     tooltip = "Minimum bar distance between count labels, used to prevent label clusters on lower timeframes.")

maxCountLabels = input.int(24, "Maximum Count Labels", minval = 8, maxval = 120, group = visualGroup,
     tooltip = "Maximum retained count labels. Older labels are removed automatically to keep the script efficient.")

labelOffsetAtr = input.float(0.85, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = visualGroup,
     tooltip = "Vertical label distance from candles, measured in ATR, so labels remain readable and do not sit inside bars.")

showLifecycleMarkers = input.bool(true, "Show Recycle/Fail Markers", group = visualGroup,
     tooltip = "Displays compact markers when an exhaustion window recycles or fails.")

showExhaustionEventLabels = input.bool(false, "Show Extra EXH Event Labels", group = visualGroup,
     tooltip = "Adds a separate EXH label outside the zone. Disabled by default because centered zone labels already identify the exhaustion window.")

lowTfCleanMode = input.bool(true, "Auto Clean Sub-4H View", group = visualGroup,
     tooltip = "Automatically reduces count-label density and retained historical structures below 4H while keeping the core exhaustion engine active.")

showZones = input.bool(true, "Show Exhaustion Zones", group = visualGroup,
     tooltip = "Draws concept-native rectangular maturity zones around late sequential runs.")

showZoneLabels = input.bool(true, "Show Centered Zone Labels", group = visualGroup,
     tooltip = "Places compact labels in the vertical and horizontal center of each exhaustion zone.")

zoneLookback = input.int(7, "Zone Lookback Bars", minval = 2, maxval = 30, group = visualGroup,
     tooltip = "Number of recent bars used to anchor the terminal exhaustion zone.")

zoneForwardBars = input.int(18, "Zone Forward Bars", minval = 3, maxval = 80, group = visualGroup,
     tooltip = "Number of bars the exhaustion zone projects forward for lifecycle tracking.")

zoneDepthAtr = input.float(1.35, "Zone Depth ATR", minval = 0.25, maxval = 5.00, step = 0.05, group = visualGroup,
     tooltip = "ATR-based depth of the terminal exhaustion zone.")

zonePaddingAtr = input.float(0.12, "Zone Padding ATR", minval = 0.00, maxval = 1.00, step = 0.01, group = visualGroup,
     tooltip = "Small ATR padding applied beyond the terminal high or low of the sequence.")

maxZones = input.int(10, "Maximum Zones", minval = 1, maxval = 50, group = visualGroup,
     tooltip = "Maximum retained exhaustion zones. Older zones are deleted to protect chart performance.")

labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = visualGroup,
     tooltip = "Controls the size of on-chart labels. Normal is the recommended publication default.")

bullZoneColor = input.color(color.rgb(34, 197, 166), "Bull Exhaustion Zone Color", group = visualGroup,
     tooltip = "Color used for downside-run exhaustion zones where bullish reaction risk may increase.")

bearZoneColor = input.color(color.rgb(244, 114, 182), "Bear Exhaustion Zone Color", group = visualGroup,
     tooltip = "Color used for upside-run exhaustion zones where bearish reaction risk may increase.")

showPanel = input.bool(true, "Show Panel", group = panelGroup,
     tooltip = "Shows the compact AG Pro summary panel.")

panelLocation = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"],
     group = panelGroup,
     tooltip = "Selects where the summary panel appears on the chart.")

panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = panelGroup,
     tooltip = "Switches the panel between dark and light presentation themes while preserving the AGPro blue header.")

panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = panelGroup,
     tooltip = "Controls the panel text size. Normal is the recommended publication default.")

panelMemoryBars = input.int(120, "Panel Memory Bars", minval = 10, maxval = 500, group = panelGroup,
     tooltip = "Controls how long the panel keeps the last exhaustion lifecycle state visible after the active window resolves.")

alertExhaustion = input.bool(true, "Alert on Exhaustion Window", group = alertGroup,
     tooltip = "Enables alerts when a new exhaustion window opens.")

alertRecycle = input.bool(true, "Alert on Recycle", group = alertGroup,
     tooltip = "Enables alerts when an active exhaustion window recycles.")

alertFailure = input.bool(true, "Alert on Failure", group = alertGroup,
     tooltip = "Enables alerts when an active exhaustion window fails.")

proofGroup = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = proofGroup,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across exhaustion windows on the current symbol and timeframe. Follow means the over-extended run reversed by a full risk unit before the run continued through the zone. These are historical outcome rates, not predictions.")
proofHorizonBars = input.int(40, "Proof Horizon Bars", minval = 4, maxval = 300, group = proofGroup,
     tooltip = "Maximum number of bars each exhaustion window is tracked for the proof measurement before it resolves at its current outcome.")
reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = proofGroup,
     tooltip = "Number of bars after a window opens used to detect an immediate reversal reaction against the run.")
reactProgressPct = input.float(40.0, "Reaction Progress %", minval = 5.0, maxval = 90.0, step = 1.0, group = proofGroup,
     tooltip = "Minimum favorable reversal progress toward the risk-unit target, within the reaction window, required to count as an early React.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(isLight, alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : panelBgL) : (alt ? color.rgb(24, 35, 55) : panelBgD)

f_quality_band(qualityValue) =>
    qualityValue >= 80 ? "High Exhaustion" :
     qualityValue >= 62 ? "Mature Risk" :
     qualityValue >= 40 ? "Developing" :
     "Fresh"

f_rate_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55.0 ? bullColor : value >= 40.0 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30.0 ? bullColor : value <= 55.0 ? neutralColor : bearColor

f_push_label(array<label> store, label item, int limit) =>
    array.push(store, item)
    while array.size(store) > limit
        oldItem = array.shift(store)
        if not na(oldItem)
            label.delete(oldItem)

f_push_box(array<box> store, box item, int limit) =>
    array.push(store, item)
    while array.size(store) > limit
        oldItem = array.shift(store)
        if not na(oldItem)
            box.delete(oldItem)

// -------------------------------------------------
// Preset Resolution
// -------------------------------------------------
dailyPreset = enginePreset == "Daily Selective"
usedQualityThreshold = dailyPreset ? math.max(qualityThreshold, 68) : qualityThreshold
usedSignalCooldown = dailyPreset ? math.max(signalCooldown, 18) : signalCooldown
usedMaxCountLabels = dailyPreset ? math.min(maxCountLabels, 18) : maxCountLabels
usedMaxZones = dailyPreset ? math.min(maxZones, 8) : maxZones
usedCountLabelMode = dailyPreset ? "Mature Milestones" : countLabelMode
chartSeconds = timeframe.in_seconds(timeframe.period)
belowBestView = timeframe.isintraday and not na(chartSeconds) and chartSeconds < 14400
cleanLowTf = lowTfCleanMode and belowBestView
showCountLabelsEff = showCountLabels and not cleanLowTf
usedMaxCountLabelsEff = cleanLowTf ? math.min(usedMaxCountLabels, 12) : usedMaxCountLabels
usedMaxZonesEff = cleanLowTf ? math.min(usedMaxZones, 5) : usedMaxZones

// -------------------------------------------------
// Sequential Count Engine
// -------------------------------------------------
labelSize = f_size(labelFontInput)
panelSize = f_size(panelFontInput)
atr = ta.atr(14)
atrSafe = math.max(nz(atr, 0.0), syminfo.mintick)
baseline = ta.ema(src, trendLen)
hasPrevBar = not na(close[1]) and not na(baseline) and not na(baseline[1])

barSpan = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyShare = bodySize / barSpan
minMove = atrSafe * minProgressAtr

emaUp = src >= baseline and baseline >= baseline[1]
emaDown = src <= baseline and baseline <= baseline[1]
bodyUp = close > open and bodyShare >= minBodyShare
bodyDown = close < open and bodyShare >= minBodyShare
progressUp = hasPrevBar and close > close[1] + minMove
progressDown = hasPrevBar and close < close[1] - minMove

qualifiedUp = progressUp and bodyUp and (not useTrendFilter or emaUp)
qualifiedDown = progressDown and bodyDown and (not useTrendFilter or emaDown)
qualifiedDirection = qualifiedUp and not qualifiedDown ? 1 : qualifiedDown and not qualifiedUp ? -1 : 0

var int seqDirection = 0
var int seqCount = 0
var int pauseCount = 0

if barstate.isconfirmed
    if qualifiedDirection == 1
        seqCount := seqDirection == 1 ? seqCount + 1 : 1
        seqDirection := 1
        pauseCount := 0
    else if qualifiedDirection == -1
        seqCount := seqDirection == -1 ? seqCount + 1 : 1
        seqDirection := -1
        pauseCount := 0
    else
        pauseCount += 1
        if pauseCount > pauseTolerance
            seqCount := math.max(seqCount - 1, 0)
            if seqCount == 0
                seqDirection := 0

// -------------------------------------------------
// Exhaustion Quality
// -------------------------------------------------
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
opposingWickRatio = seqDirection == 1 ? upperWick / barSpan : seqDirection == -1 ? lowerWick / barSpan : 0.0
bodyShareAvg = ta.sma(bodyShare, qualitySmoothLen)
bodyFade = bodyShareAvg > 0 ? math.max(bodyShareAvg - bodyShare, 0.0) / bodyShareAvg : 0.0

countScore = seqDirection != 0 ? math.min(seqCount / exhaustionThreshold, 1.0) * 45.0 : 0.0
stretchScore = seqDirection != 0 ? math.min(math.abs(src - baseline) / (atrSafe * stretchAtrCap), 1.0) * 25.0 : 0.0
wickScore = math.min(opposingWickRatio / wickPressureCap, 1.0) * 15.0
fadeScore = math.min(bodyFade, 1.0) * 15.0
qualityRaw = countScore + stretchScore + wickScore + fadeScore
exhaustionQuality = seqDirection != 0 ? math.min(100.0, ta.ema(qualityRaw, qualitySmoothLen)) : 0.0

// -------------------------------------------------
// Lifecycle Tracking
// -------------------------------------------------
var int lastExhaustionBar = na
var int lastLifecycleBar = na
var int activeZoneDirection = 0
var float activeZoneTop = na
var float activeZoneBottom = na
var int postExhaustionCloses = 0
var string lifecycleStatus = "Waiting"
var string lastResolvedStatus = "Waiting"
var int lastCountLabelBar = na
var array<label> countLabels = array.new<label>()
var array<label> lifecycleLabels = array.new<label>()
var array<label> zoneLabels = array.new<label>()
var array<box> exhaustionZones = array.new<box>()

exhaustionArmed = seqDirection != 0 and seqCount >= exhaustionThreshold and exhaustionQuality >= usedQualityThreshold
previousArmed = exhaustionArmed[1] == true
cooldownReady = na(lastExhaustionBar) or bar_index - lastExhaustionBar > usedSignalCooldown
newExhaustionWindow = barstate.isconfirmed and exhaustionArmed and cooldownReady and (not previousArmed or seqDirection != seqDirection[1])
recyclePrint = false
failurePrint = false
lifecycleMarkerDirection = 0

terminalHigh = ta.highest(high, zoneLookback)
terminalLow = ta.lowest(low, zoneLookback)
zoneTopRaw = seqDirection == 1 ? terminalHigh + atrSafe * zonePaddingAtr : terminalLow + atrSafe * zoneDepthAtr
zoneBottomRaw = seqDirection == 1 ? terminalHigh - atrSafe * zoneDepthAtr : terminalLow - atrSafe * zonePaddingAtr
zoneTop = math.max(zoneTopRaw, zoneBottomRaw + syminfo.mintick)
zoneBottom = math.min(zoneBottomRaw, zoneTopRaw - syminfo.mintick)

if newExhaustionWindow
    lastExhaustionBar := bar_index
    lastLifecycleBar := bar_index
    activeZoneDirection := seqDirection
    activeZoneTop := zoneTop
    activeZoneBottom := zoneBottom
    postExhaustionCloses := 0
    lifecycleStatus := "Exhaustion Window"
    lastResolvedStatus := lifecycleStatus
    if showZones
        zoneColor = seqDirection == 1 ? bearZoneColor : bullZoneColor
        zoneBox = box.new(bar_index - zoneLookback + 1, zoneTop, bar_index + zoneForwardBars, zoneBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(zoneColor, 86),
             border_color = color.new(zoneColor, exhaustionQuality >= 80 ? 18 : 34),
             border_width = exhaustionQuality >= 80 ? 2 : 1)
        f_push_box(exhaustionZones, zoneBox, usedMaxZonesEff)
        if showZoneLabels
            zoneText = (seqDirection == 1 ? "SELL EXH" : "BUY EXH") + "\nQ " + str.tostring(math.round(exhaustionQuality))
            centerX = bar_index - zoneLookback + 1 + int(math.round((zoneLookback - 1 + zoneForwardBars) / 2.0))
            centerY = (zoneTop + zoneBottom) * 0.5
            zoneLabel = label.new(centerX, centerY, zoneText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_center,
                 textcolor = headerText,
                 color = color.new(zoneColor, 8),
                 size = labelSize,
                 textalign = text.align_center)
            f_push_label(zoneLabels, zoneLabel, usedMaxZonesEff)
else if barstate.isconfirmed and activeZoneDirection != 0 and not na(activeZoneTop) and not na(activeZoneBottom)
    continuationClose = activeZoneDirection == 1 ? close > activeZoneTop and close > open : close < activeZoneBottom and close < open
    failureClose = activeZoneDirection == 1 ? close < activeZoneBottom : close > activeZoneTop
    if failureClose
        lifecycleStatus := "Failed"
        lastResolvedStatus := lifecycleStatus
        lastLifecycleBar := bar_index
        failurePrint := true
        lifecycleMarkerDirection := activeZoneDirection
        activeZoneDirection := 0
        postExhaustionCloses := 0
    else if continuationClose
        postExhaustionCloses += 1
        if postExhaustionCloses >= recycleThreshold
            lifecycleStatus := "Recycled"
            lastResolvedStatus := lifecycleStatus
            lastLifecycleBar := bar_index
            recyclePrint := true
            lifecycleMarkerDirection := activeZoneDirection
            activeZoneDirection := 0
            postExhaustionCloses := 0
        else
            lifecycleStatus := "Recycle Build " + str.tostring(postExhaustionCloses)
    else
        lifecycleStatus := "Testing Window"
else if seqDirection != 0 and seqCount >= exhaustionThreshold
    lifecycleStatus := "Mature Count"
else if seqDirection != 0 and seqCount > 0
    lifecycleStatus := "Building"
else
    lifecycleStatus := "Waiting"

// -------------------------------------------------
// Confirmation-anchored proof (exhaustion fade: Follow = run reversed by 1R before continuing through the zone)
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

int proofWarmup = math.max(trendLen, 14) + 10
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
        if naturalResolve or newExhaustionWindow
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
    if newExhaustionWindow and not pEvalActive and seqDirection != 0
        int fadeDir = -seqDirection
        float runStop = seqDirection == 1 ? zoneTop : zoneBottom
        float pRisk = math.max(math.abs(close - runStop), atrSafe * 0.25)
        pEvalActive := true
        pEvalDir := fadeDir
        pEvalEntry := close
        pEvalStop := runStop
        pEvalTarget := close + fadeDir * pRisk
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Chart Visuals
// -------------------------------------------------
plot(showBaseline ? baseline : na, "Sequence Baseline", color = color.new(accentColor, 0), linewidth = 2)
barcolor(showQualifiedBars and qualifiedDirection != 0 ? color.new(qualifiedDirection == 1 ? bullColor : bearColor, 68) : na)

matureMilestoneCount = seqCount == math.max(1, exhaustionThreshold - 2) or seqCount == exhaustionThreshold
milestoneCount = seqCount == countLabelStart or seqCount == math.max(countLabelStart + 2, exhaustionThreshold - 2) or seqCount == exhaustionThreshold
stepCount = seqCount % countLabelStep == 0 or seqCount == exhaustionThreshold
thresholdCount = seqCount == exhaustionThreshold
modeAllowsCount = matureMilestoneCount
if usedCountLabelMode == "Milestones"
    modeAllowsCount := milestoneCount
else if usedCountLabelMode == "Step"
    modeAllowsCount := stepCount
else if usedCountLabelMode == "Threshold Only"
    modeAllowsCount := thresholdCount

spacingAllowsCount = na(lastCountLabelBar) or bar_index - lastCountLabelBar >= minLabelSpacingBars or seqCount == exhaustionThreshold
printCountLabel = barstate.isconfirmed and showCountLabelsEff and qualifiedDirection != 0 and seqCount >= countLabelStart and modeAllowsCount and spacingAllowsCount and not newExhaustionWindow
if printCountLabel
    labelY = seqDirection == 1 ? high + atrSafe * labelOffsetAtr : low - atrSafe * labelOffsetAtr
    labelStyle = seqDirection == 1 ? label.style_label_down : label.style_label_up
    labelColor = exhaustionQuality >= usedQualityThreshold ? neutralColor : seqDirection == 1 ? bullColor : bearColor
    countLabel = label.new(bar_index, labelY, str.tostring(seqCount),
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = labelStyle,
         textcolor = color.rgb(15, 23, 42),
         color = color.new(labelColor, 0),
         size = labelSize)
    f_push_label(countLabels, countLabel, usedMaxCountLabelsEff)
    lastCountLabelBar := bar_index

if barstate.isconfirmed and newExhaustionWindow and showExhaustionEventLabels
    eventY = seqDirection == 1 ? high + atrSafe * (labelOffsetAtr + 0.55) : low - atrSafe * (labelOffsetAtr + 0.55)
    eventStyle = seqDirection == 1 ? label.style_label_down : label.style_label_up
    eventText = "EXH\n" + str.tostring(math.round(exhaustionQuality))
    eventLabel = label.new(bar_index, eventY, eventText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = eventStyle,
         textcolor = headerText,
         color = color.new(headerBg, 0),
         size = labelSize,
         textalign = text.align_center)
    f_push_label(lifecycleLabels, eventLabel, usedMaxCountLabelsEff)

if barstate.isconfirmed and showLifecycleMarkers and (recyclePrint or failurePrint)
    markerDirection = lifecycleMarkerDirection != 0 ? lifecycleMarkerDirection : seqDirection
    markerY = markerDirection == 1 ? high + atrSafe * (labelOffsetAtr + 0.35) : low - atrSafe * (labelOffsetAtr + 0.35)
    markerStyle = markerDirection == 1 ? label.style_label_down : label.style_label_up
    markerText = recyclePrint ? "REC" : "FAIL"
    markerColor = recyclePrint ? accentColor : neutralColor
    markerLabel = label.new(bar_index, markerY, markerText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = markerStyle,
         textcolor = headerText,
         color = color.new(markerColor, 0),
         size = labelSize)
    f_push_label(lifecycleLabels, markerLabel, usedMaxCountLabelsEff)

// -------------------------------------------------
// Panel
// -------------------------------------------------
isLightPanel = panelTheme == "Light"
panelBgActive = f_panel_bg(isLightPanel, false)
panelAltBgActive = f_panel_bg(isLightPanel, true)
panelBorderActive = isLightPanel ? panelBorderL : panelBorderD
panelLabelActive = isLightPanel ? panelLabelL : panelLabelD
panelValueActive = isLightPanel ? panelValueL : panelValueD

directionText = seqDirection == 1 ? "Bullish Run" : seqDirection == -1 ? "Bearish Run" : "Neutral"
countText = seqDirection == 0 ? "0 / " + str.tostring(exhaustionThreshold) : str.tostring(seqCount) + " / " + str.tostring(exhaustionThreshold)
qualityText = str.tostring(math.round(exhaustionQuality)) + " / 100 " + f_quality_band(exhaustionQuality)
recentLifecycle = not na(lastLifecycleBar) and bar_index - lastLifecycleBar <= panelMemoryBars
statusText = activeZoneDirection != 0 ? lifecycleStatus : recentLifecycle ? lastResolvedStatus : lifecycleStatus
directionValueColor = seqDirection == 1 ? bullColor : seqDirection == -1 ? bearColor : neutralColor
statusValueColor = statusText == "Recycled" ? accentColor : statusText == "Failed" ? neutralColor : panelValueActive
proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
int panelRowCount = showProof ? 10 : 5

var table summaryPanel = na
var string prevPanelLocation = ""
var string prevPanelTheme = ""
var bool prevProofMode = false

panelNeedsRebuild = showPanel and (na(summaryPanel) or prevPanelLocation != panelLocation or prevPanelTheme != panelTheme or prevProofMode != showProof)
if panelNeedsRebuild
    if not na(summaryPanel)
        table.delete(summaryPanel)
    summaryPanel := table.new(f_pos(panelLocation), 2, panelRowCount,
         bgcolor = panelBgActive,
         frame_color = panelBorderActive,
         frame_width = 1,
         border_color = panelBorderActive,
         border_width = 1)
    table.cell(summaryPanel, 0, 0, "AG Pro Sequential Exhaustion Tracker", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(summaryPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(summaryPanel, 0, 0, 1, 0)
    prevPanelLocation := panelLocation
    prevPanelTheme := panelTheme
    prevProofMode := showProof

if not showPanel and not na(summaryPanel)
    table.delete(summaryPanel)
    summaryPanel := na
    prevPanelLocation := ""
    prevPanelTheme := ""

if showPanel and not na(summaryPanel) and barstate.islast
    table.set_position(summaryPanel, f_pos(panelLocation))
    table.clear(summaryPanel, 0, 1, 1, panelRowCount - 1)
    table.cell(summaryPanel, 0, 0, "AG Pro Sequential Exhaustion Tracker", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(summaryPanel, 0, 1, "Direction", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_left)
    table.cell(summaryPanel, 1, 1, directionText, text_color = directionValueColor, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_right)
    table.cell(summaryPanel, 0, 2, "Count", text_color = panelLabelActive, bgcolor = panelAltBgActive, text_size = panelSize, text_halign = text.align_left)
    table.cell(summaryPanel, 1, 2, countText, text_color = panelValueActive, bgcolor = panelAltBgActive, text_size = panelSize, text_halign = text.align_right)
    table.cell(summaryPanel, 0, 3, "Quality", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_left)
    table.cell(summaryPanel, 1, 3, qualityText, text_color = exhaustionQuality >= usedQualityThreshold ? neutralColor : panelValueActive, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_right)
    table.cell(summaryPanel, 0, 4, "Lifecycle", text_color = panelLabelActive, bgcolor = panelAltBgActive, text_size = panelSize, text_halign = text.align_left)
    table.cell(summaryPanel, 1, 4, statusText, text_color = statusValueColor, bgcolor = panelAltBgActive, text_size = panelSize, text_halign = text.align_right)
    if showProof
        table.cell(summaryPanel, 0, 5, "Proof @ Confirm", text_color = accentColor, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_left)
        table.cell(summaryPanel, 1, 5, proofSampleText, text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_right)
        table.cell(summaryPanel, 0, 6, "Follow Rate", text_color = panelLabelActive, bgcolor = panelAltBgActive, text_size = panelSize, text_halign = text.align_left)
        table.cell(summaryPanel, 1, 6, proofTotal > 0 ? f_rate_pct(followRate) : "-", text_color = proofTotal > 0 ? f_rate_color(followRate) : panelValueActive, bgcolor = panelAltBgActive, text_size = panelSize, text_halign = text.align_right)
        table.cell(summaryPanel, 0, 7, "Hold Rate", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_left)
        table.cell(summaryPanel, 1, 7, proofTotal > 0 ? f_rate_pct(holdRate) : "-", text_color = proofTotal > 0 ? f_rate_color(holdRate) : panelValueActive, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_right)
        table.cell(summaryPanel, 0, 8, "React Rate", text_color = panelLabelActive, bgcolor = panelAltBgActive, text_size = panelSize, text_halign = text.align_left)
        table.cell(summaryPanel, 1, 8, proofTotal > 0 ? f_rate_pct(reactRate) : "-", text_color = proofTotal > 0 ? f_rate_color(reactRate) : panelValueActive, bgcolor = panelAltBgActive, text_size = panelSize, text_halign = text.align_right)
        table.cell(summaryPanel, 0, 9, "Flip Rate", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_left)
        table.cell(summaryPanel, 1, 9, proofTotal > 0 ? f_rate_pct(flipRate) : "-", text_color = proofTotal > 0 ? f_flip_color(flipRate) : panelValueActive, bgcolor = panelBgActive, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertExhaustion and newExhaustionWindow, "Sequential Exhaustion Window", "Sequential Exhaustion Tracker opened a new exhaustion window.")
alertcondition(alertRecycle and recyclePrint, "Sequential Recycle", "Sequential Exhaustion Tracker classified the active exhaustion window as recycled.")
alertcondition(alertFailure and failurePrint, "Sequential Failure", "Sequential Exhaustion Tracker classified the active exhaustion window as failed.")

plot(seqCount, "SET Count", display = display.none)
plot(exhaustionQuality, "SET Exhaustion Quality", display = display.none)
plot(activeZoneDirection, "SET Active Zone Direction", display = display.none)
plot(followRate, "SET Follow Rate", display = display.none)
plot(holdRate, "SET Hold Rate", display = display.none)
plot(reactRate, "SET React Rate", display = display.none)
plot(flipRate, "SET Flip Rate", display = display.none)
````
