# Low Volume Pullback Zones [AGPro Series]

- url: https://www.tradingview.com/script/rWPId9WQ-Low-Volume-Pullback-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;68a20612e25045209becad445862e50d
- version: 5.0

## Description

Low Volume Pullback Zones [AGPro Series]

🔷 Overview

Low Volume Pullback Zones [AGPro Series] is a trend-continuation overlay built for one very specific market behavior: a trend is already established, price retraces in a controlled way, volume dries up during that retracement, and the market later reclaims a continuation trigger.

The default profile is tuned for daily swing charts, where low-volume retracements usually form cleaner structural pockets and the chart has enough space for the boxes to read properly. A 4H Active preset is included for traders who want more frequent mapping, while Custom mode exposes the raw controls.

Many pullback tools focus only on price touching a moving average, a SuperTrend line, or a generic support/resistance area. This script is intentionally narrower. It looks for the quieter part of a trend: the moment where participation contracts during a retracement, the pullback stays shallow relative to the prior impulse, and a clean continuation pocket can be mapped with a visible invalidation boundary.

The goal is not to mark every trend candle. The goal is to isolate the cleaner pauses inside trend conditions where the pullback behaves like controlled absorption instead of aggressive reversal pressure.

🟩 What The Script Detects

The engine combines five layers:

1. Trend Side
The script first checks whether the market has a clean bullish or bearish trend profile using EMA alignment, EMA slope, DI direction, and ADX strength. If the trend is flat or mixed, the script avoids mapping low-quality pullbacks.

2. Low RVOL Retracement
During a pullback, the script measures relative volume against a rolling volume baseline. A stronger dry-up score means the retracement is happening with lighter participation, which often creates a cleaner continuation context than high-volume countertrend pressure.

3. Shallow Pullback Depth
The pullback is measured against the prior impulse reference range. Controlled retracements receive higher scores, while deep retracements move toward failure risk.

4. Continuation Trigger
The script waits for price to reclaim beyond the pullback pocket boundary with a small ATR buffer and relative-volume recovery. This prevents the chart from filling with premature pullback labels before the structure actually confirms.

5. Invalidation Boundary
Every active dry-up pocket has a structural boundary beyond the deepest pullback extreme. If price breaks that boundary, the pocket is treated as invalid rather than leaving an old setup on the chart.

🟦 Chart Visuals

The main visual layer is the Dry-Up Pullback Pocket.

When a valid pullback begins, the script draws a compact rectangular pocket around the retracement range. If the pocket confirms, the script projects a tighter functional retest/hold zone instead of extending the entire historical pullback range. This makes the zone easier to use: bullish zones focus on the reclaimed upper pocket area, bearish zones focus on the reclaimed lower pocket area, and the dotted invalidation boundary remains beyond the failed side of the structure.

Dry-Up Watch labels can appear before final confirmation when the pullback already has strong volume contraction and acceptable structure. Rejected context boxes are optional and disabled by default because they are diagnostic, not actionable hold zones. Trigger labels remain compact and controlled by cooldown logic. The default behavior keeps the chart active enough to be useful without making it feel crowded or noisy.

🟨 Info Panel

The panel summarizes the current state:

Trend Side - bullish trend, bearish trend, or no clean trend.
Dry-Up Score - how strongly volume contracted inside the active or most recent pocket.
Pullback Depth - retracement depth relative to the prior impulse.
Trigger State - mapping, triggered, expired, boundary lost, trend lost, or waiting.
Failure Risk - a compact risk read based on depth, volume behavior, and pullback duration.

The panel location, panel theme, panel font size, and label font size are configurable from settings. The first panel row follows the AGPro Series standard format with a single merged blue header row.

🟪 What Makes This Different

This script is not a generic trend meter.
It is not a SuperTrend reaction tool.
It is not a broad continuation score dashboard.
It is not a volume spike or climax detector.

Low Volume Pullback Zones is focused on the relationship between trend continuation and volume contraction during the retracement itself. That makes the script different from tools that only measure trend strength, moving-average reclaim, breakout quality, support/resistance reactions, or high-volume pressure events.

The core question is:

Did the pullback become quiet enough, shallow enough, and controlled enough to justify a mapped continuation pocket?

That narrow question is what gives the script its identity.

🧭 How To Read It

Bullish dry-up pocket:
The trend filter is bullish, price retraces into the EMA lane, average RVOL contracts, depth remains controlled, and price reclaims the upper pocket boundary.

Bearish dry-up pocket:
The trend filter is bearish, price retraces upward into the EMA lane, average RVOL contracts, depth remains controlled, and price reclaims the lower pocket boundary.

Failure risk:
Failure risk rises when the pullback becomes too deep, too long, or too active in volume terms. A higher failure risk means the retracement is no longer behaving like a quiet continuation pause.

Invalidation boundary:
The dotted boundary marks the structural area where the active pocket is no longer considered valid.

⚙ Key Settings

Engine Preset:
Daily Swing is the default and is designed for cleaner publication-grade structure. 4H Active keeps more frequent lower-timeframe pockets. Custom uses the direct input values.

Fast / Mid / Slow EMA Lengths:
Control the trend structure used by the pullback engine.

Minimum ADX and Minimum EMA Slope:
Help the script avoid mapping dry-up pockets in flat conditions.

Relative Volume Length:
Defines the baseline used to measure volume dry-up.

Preferred Pullback RVOL:
Controls how quiet the pullback should be to receive full dry-up credit.

Preferred Max Depth:
Defines the ideal shallow retracement threshold.

Trigger Buffer:
Adds a small ATR-based confirmation buffer beyond the pullback pocket.

Pocket Projection Bars:
Controls how far completed pockets extend to the right.

Functional Zone Width:
Controls how much of the original pullback range is projected after confirmation. Smaller values create a tighter retest/hold pocket; larger values keep more of the original pullback structure.

Label Cooldown and Max Structures:
Keep the overlay readable and publication-clean.

📌 Best Use

This indicator is best used on markets that already show directional structure. It is designed for traders who study trend continuation, relative volume behavior, pullback quality, and invalidation-based chart structure.

It can be used across crypto, forex, indices, equities, and commodities, but the most useful results generally appear when the market has enough trend strength for low-volume retracements to matter.

🟧 Design Philosophy

Low Volume Pullback Zones [AGPro Series] was built to keep the chart premium and readable:

Clean pocket boxes instead of noisy background clutter.
Restrained watch and trigger labels instead of constant marker spam.
Visible invalidation boundaries instead of ambiguous zones.
Professional RVOL and depth scoring instead of simple moving-average touches.
Configurable panel and label sizing for different chart layouts.

The script is intentionally selective. Its strongest value comes from filtering out ordinary pullbacks and highlighting the ones where trend, volume dry-up, shallow depth, and continuation confirmation align.

## Source Code

````pine
// -------------------------------------------------
// Low Volume Pullback Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Low Volume Pullback Zones maps trend-aligned retracements where relative
// volume contracts, pullback depth remains controlled, and price later
// reclaims a continuation trigger. The overlay highlights dry-up pockets,
// continuation zones, invalidation boundaries, watch states and quality
// labels with a cleaner publication-focused visual system. Built for low
// volume pullback analysis, dry-up pocket mapping, trend continuation setups,
// RVOL contraction, pullback depth control and swing/4H continuation context.
// Version 1.4 strengthens preset safety, qualified-pocket Proof integrity,
// synchronized structure retention, boundary-badge coverage, and visual
// density while preserving the original dry-up pullback methodology.
// -------------------------------------------------

//@version=6
indicator("Low Volume Pullback Zones [AGPro Series]",
     shorttitle       = "AG Pro LVP",
     overlay          = true,
     max_boxes_count  = 70,
     max_lines_count  = 70,
     max_labels_count = 120,
     max_bars_back    = 700)

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
groupTrend = "Trend Filter"
groupPullback = "Dry-Up Pullback Engine"
groupTrigger = "Continuation Trigger"
groupVisual = "Visuals"
groupPanel = "Panel"
groupProof = "Proof"
groupAlerts = "Alerts"

enginePreset = input.string("Daily Swing", "Engine Preset", options = ["Daily Swing", "4H Active", "Custom"], group = groupTrend,
     tooltip = "Daily Swing is selective and cleaner for publication screenshots. 4H Active creates more frequent dry-up pocket mapping. Custom uses the raw inputs.")

emaFastLen = input.int(21, "Fast EMA Length", minval = 3, maxval = 60, group = groupTrend,
     tooltip = "Fast trend anchor used to detect the first retracement into the active trend lane.")

emaMidLen = input.int(55, "Mid EMA Length", minval = 8, maxval = 120, group = groupTrend,
     tooltip = "Primary trend anchor used for trend-side filtering and pullback context.")

emaSlowLen = input.int(144, "Slow EMA Length", minval = 20, maxval = 250, group = groupTrend,
     tooltip = "Slow structure anchor used to reject pullbacks that damage the broader trend.")

slopeLookback = input.int(10, "EMA Slope Lookback", minval = 2, maxval = 50, group = groupTrend,
     tooltip = "Measures whether the mid EMA is moving with enough trend pressure to support continuation analysis.")

diLength = input.int(14, "DI Length", minval = 5, maxval = 50, group = groupTrend,
     tooltip = "Directional index length used by the ADX trend-strength filter.")

adxSmoothing = input.int(14, "ADX Smoothing", minval = 5, maxval = 50, group = groupTrend,
     tooltip = "Smoothing length for ADX. Higher values reduce trend-strength noise.")

minAdx = input.float(16.0, "Minimum ADX", minval = 5.0, maxval = 45.0, step = 0.5, group = groupTrend,
     tooltip = "Minimum ADX required before the script treats a trend as suitable for continuation analysis.")

minSlopeAtr = input.float(0.06, "Minimum EMA Slope (ATR)", minval = 0.0, maxval = 1.5, step = 0.01, group = groupTrend,
     tooltip = "Minimum mid-EMA slope normalized by ATR. Helps avoid low-volume pullbacks inside flat conditions.")

showTrendAnchors = input.bool(false, "Show Trend EMAs", group = groupTrend,
     tooltip = "Displays the EMA anchors used by the trend and pullback engines.")

atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupPullback,
     tooltip = "ATR length used for label spacing, invalidation buffers and normalized trigger distances.")

impulseLookback = input.int(42, "Impulse Reference Lookback", minval = 8, maxval = 120, group = groupPullback,
     tooltip = "Lookback used to define the prior impulse range before a pullback begins.")

rvolLength = input.int(45, "Relative Volume Length", minval = 5, maxval = 150, group = groupPullback,
     tooltip = "Baseline length for relative volume. Pullbacks are higher quality when average RVOL dries up against this baseline.")

startMaxRvol = input.float(1.15, "Max RVOL to Start Pullback", minval = 0.30, maxval = 3.00, step = 0.05, group = groupPullback,
     tooltip = "A fresh pullback map can begin only when relative volume is not aggressively elevated.")

preferredDryRvol = input.float(0.72, "Preferred Pullback RVOL", minval = 0.20, maxval = 1.50, step = 0.05, group = groupPullback,
     tooltip = "Average pullback RVOL at or below this level receives full dry-up credit.")

hardRvol = input.float(1.20, "Weak Dry-Up RVOL", minval = 0.50, maxval = 3.00, step = 0.05, group = groupPullback,
     tooltip = "Average pullback RVOL above this level receives little or no dry-up credit.")

minPullbackBars = input.int(3, "Minimum Pullback Bars", minval = 1, maxval = 20, group = groupPullback,
     tooltip = "Minimum number of bars required before a dry-up pocket can trigger.")

maxPullbackBars = input.int(18, "Maximum Pullback Bars", minval = 4, maxval = 80, group = groupPullback,
     tooltip = "Pullbacks that last beyond this window are treated as stale.")

preferredDepthPct = input.float(50.0, "Preferred Max Depth (%)", minval = 10.0, maxval = 70.0, step = 0.5, group = groupPullback,
     tooltip = "Preferred retracement depth relative to the prior impulse range.")

hardDepthPct = input.float(88.6, "Hard Depth Limit (%)", minval = 20.0, maxval = 95.0, step = 0.5, group = groupPullback,
     tooltip = "Pullbacks deeper than this level are treated as structural failures.")

minDryScore = input.float(58.0, "Minimum Dry-Up Score", minval = 0.0, maxval = 100.0, step = 1.0, group = groupPullback,
     tooltip = "Minimum dry-up score required before a pullback can graduate into a continuation trigger.")

emaLaneAtr = input.float(0.45, "EMA Lane Tolerance (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = groupPullback,
     tooltip = "Allows pullbacks to map when price retraces near the fast or mid EMA lane.")

minQualityScore = input.float(72.0, "Minimum Trigger Quality", minval = 0.0, maxval = 100.0, step = 1.0, group = groupTrigger,
     tooltip = "Minimum composite quality score required for a trigger label and completed pocket zone.")

triggerBufferAtr = input.float(0.05, "Trigger Buffer (ATR)", minval = 0.00, maxval = 1.00, step = 0.01, group = groupTrigger,
     tooltip = "Adds a small ATR buffer beyond the pullback pocket boundary before continuation confirmation.")

recoveryRvolRatio = input.float(1.05, "Recovery RVOL Ratio", minval = 0.20, maxval = 3.00, step = 0.05, group = groupTrigger,
     tooltip = "Requires trigger-bar RVOL to recover relative to average dry-up RVOL inside the pullback.")

invalidationAtr = input.float(0.28, "Invalidation Buffer (ATR)", minval = 0.00, maxval = 2.00, step = 0.01, group = groupTrigger,
     tooltip = "Places the invalidation boundary beyond the deepest pullback extreme.")

confirmOnClose = input.bool(true, "Confirm Triggers on Bar Close", group = groupTrigger,
     tooltip = "When enabled, trigger labels print only after the bar is confirmed.")

showActivePocket = input.bool(true, "Show Active Dry-Up Pocket", group = groupVisual,
     tooltip = "Displays the live pullback pocket while the dry-up map is still forming.")

showCompletedPockets = input.bool(true, "Show Completed Pocket Zones", group = groupVisual,
     tooltip = "Keeps qualified dry-up pocket zones visible after continuation triggers.")

showZoneLabels = input.bool(true, "Show Centered Zone Labels", group = groupVisual,
     tooltip = "Places compact labels inside completed pocket zones.")

showInvalidationBoundary = input.bool(true, "Show Invalidation Boundary", group = groupVisual,
     tooltip = "Draws the structural boundary that invalidates the active pullback pocket.")

showTriggerLabels = input.bool(true, "Show Continuation Trigger Labels", group = groupVisual,
     tooltip = "Displays compact labels when a dry-up pullback confirms into a continuation trigger.")

showWatchLabels = input.bool(true, "Show Dry-Up Watch Labels", group = groupVisual,
     tooltip = "Adds restrained watch labels when a pocket has strong dry-up and acceptable depth but has not confirmed yet.")

showFailureTags = input.bool(false, "Show Failure Tags", group = groupVisual,
     tooltip = "When enabled, invalidated pockets can print small failure tags. Disabled by default for cleaner publication visuals.")

lowTfCleanMode = input.bool(true, "Auto Clean Sub-4H View", group = groupVisual,
     tooltip = "Below 4H, tightens how many historical structures are retained so the publication view stays readable, while keeping dry-up watch and trigger labels visible. Core trigger logic remains active.")

functionalZonePct = input.float(38.2, "Functional Zone Width (%)", minval = 15.0, maxval = 80.0, step = 0.5, group = groupVisual,
     tooltip = "Controls how much of the original pullback range is projected after confirmation.")

projectionBars = input.int(45, "Pocket Projection Bars", minval = 5, maxval = 120, group = groupVisual,
     tooltip = "Projects completed pullback pockets and invalidation boundaries forward for context.")

sameSideCooldown = input.int(22, "Same-Side Label Cooldown", minval = 0, maxval = 120, group = groupVisual,
     tooltip = "Minimum spacing between same-side trigger labels to keep chart density controlled.")

maxStructures = input.int(12, "Max Structures to Keep", minval = 4, maxval = 60, group = groupVisual,
     tooltip = "Limits historical boxes, labels and invalidation lines retained on the chart.")

labelOffsetAtr = input.float(1.15, "Label Offset (ATR)", minval = 0.20, maxval = 4.00, step = 0.05, group = groupVisual,
     tooltip = "Offsets labels away from candles using ATR so they do not get buried inside price.")

labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls the font size of continuation, watch and optional failure labels.")

labelDetail = input.string("Balanced", "Label Detail", options = ["Compact", "Balanced", "Detailed"], group = groupVisual,
     tooltip = "Controls the amount of information printed inside trigger labels.")

minWatchQuality = input.float(78.0, "Minimum Watch Quality", minval = 0.0, maxval = 100.0, step = 1.0, group = groupVisual,
     tooltip = "Minimum quality required before a non-confirmed dry-up pocket can print a watch label.")

bullPocketColor = input.color(color.rgb(34, 197, 166), "Bull Pocket Color", group = groupVisual,
     tooltip = "Color used for bullish dry-up pocket boxes and bullish continuation trigger labels.")

bearPocketColor = input.color(color.rgb(244, 114, 182), "Bear Pocket Color", group = groupVisual,
     tooltip = "Color used for bearish dry-up pocket boxes and bearish continuation trigger labels.")

boundaryColor = input.color(color.rgb(245, 189, 92), "Invalidation Boundary Color", group = groupVisual,
     tooltip = "Color used for dotted invalidation boundaries around active and completed pullback pockets.")

showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Displays the AG Pro live diagnostics panel.")

panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = groupPanel,
     tooltip = "Moves the information panel to the selected chart area.")

panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Controls the panel color theme while preserving the blue AGPro header row.")

panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls the panel text size.")

panelMemoryBars = input.int(80, "Panel Memory Bars", minval = 10, maxval = 500, group = groupPanel,
     tooltip = "Controls how long the panel displays the most recent completed or invalidated pocket.")

showProof = input.bool(true, "Show Proof Layer", group = groupProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across qualified dry-up pullbacks on the current symbol and timeframe. A pullback qualifies when its dry-up, depth, and quality reach the watch grade. Follow means the pullback then continued one risk unit (1R) in the trend direction before the pocket invalidation was lost. These are historical outcome rates, not predictions.")
proofHorizonBars = input.int(40, "Proof Horizon Bars", minval = 5, maxval = 300, group = groupProof,
     tooltip = "Maximum number of bars each confirmed trigger is tracked for the proof measurement before it resolves at its current outcome.")
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof,
     tooltip = "Number of bars after a trigger confirms used to detect an immediate favorable continuation reaction.")
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof,
     tooltip = "Minimum favorable continuation progress toward the 1R target, within the reaction window, required to count as an early React.")

alertBullTrigger = input.bool(true, "Alert on Bullish Trigger", group = groupAlerts,
     tooltip = "Enables alerts when a bullish dry-up pullback confirms.")

alertBearTrigger = input.bool(true, "Alert on Bearish Trigger", group = groupAlerts,
     tooltip = "Enables alerts when a bearish dry-up pullback confirms.")

alertInvalidation = input.bool(false, "Alert on Pocket Invalidation", group = groupAlerts,
     tooltip = "Enables alerts when an active dry-up pocket loses its structural boundary before triggering.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
lvp_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

lvp_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

lvp_pos(p) =>
    switch p
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

lvp_text_on(_bg) =>
    brightness = color.r(_bg) + color.g(_bg) + color.b(_bg)
    brightness >= 360 ? color.rgb(15, 23, 42) : color.white

lvp_state_on_panel(_isLight, _state) =>
    if _isLight
        _state == bullColor ? color.rgb(13, 118, 99) : _state == bearColor ? color.rgb(178, 44, 112) : _state == neutralColor ? color.rgb(133, 77, 14) : _state == accentColor ? color.rgb(67, 56, 202) : _state
    else
        _state

lvp_panel_bg(isLight, alt) =>
    isLight ? (alt ? color.rgb(226, 232, 240) : panelBgL) : (alt ? color.rgb(30, 41, 59) : panelBgD)

lvp_grade(scoreValue) =>
    scoreValue >= 86 ? "Prime" :
     scoreValue >= 76 ? "Strong" :
     scoreValue >= 66 ? "Constructive" :
     "Fragile"

lvp_depth_text(depthValue, preferredLimit, hardLimit) =>
    na(depthValue) ? "Waiting" :
     depthValue <= preferredLimit ? "Shallow" :
     depthValue <= hardLimit ? "Extended" :
     "Broken"

lvp_risk_text(riskValue) =>
    na(riskValue) ? "Waiting" :
     riskValue >= 72 ? "High" :
     riskValue >= 45 ? "Moderate" :
     "Controlled"

lvp_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

lvp_rate_color(value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

lvp_flip_color(value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

lvp_trim_boxes(array<box> arr, maxCount) =>
    while array.size(arr) > maxCount
        old = array.shift(arr)
        if not na(old)
            box.delete(old)

lvp_trim_lines(array<line> arr, maxCount) =>
    while array.size(arr) > maxCount
        old = array.shift(arr)
        if not na(old)
            line.delete(old)

lvp_trim_labels(array<label> arr, maxCount) =>
    while array.size(arr) > maxCount
        old = array.shift(arr)
        if not na(old)
            label.delete(old)

lvp_trim_completed_structures(
     array<box> boxes,
     array<line> lines,
     array<label> zoneBadges,
     array<label> boundaryBadges,
     maxCount) =>
    while array.size(boxes) > maxCount
        box oldBox = array.shift(boxes)
        line oldLine = array.shift(lines)
        label oldZoneBadge = array.shift(zoneBadges)
        label oldBoundaryBadge = array.shift(boundaryBadges)
        if not na(oldBox)
            box.delete(oldBox)
        if not na(oldLine)
            line.delete(oldLine)
        if not na(oldZoneBadge)
            label.delete(oldZoneBadge)
        if not na(oldBoundaryBadge)
            label.delete(oldBoundaryBadge)

// -------------------------------------------------
// Preset Resolution
// -------------------------------------------------
dailyPreset = enginePreset == "Daily Swing"
activePreset = enginePreset == "4H Active"
customPreset = enginePreset == "Custom"

usedImpulseLookback = customPreset ? impulseLookback : dailyPreset ? math.max(impulseLookback, 42) : activePreset ? math.min(impulseLookback, 24) : impulseLookback
usedRvolLength = customPreset ? rvolLength : dailyPreset ? math.max(rvolLength, 45) : activePreset ? math.min(rvolLength, 30) : rvolLength

usedMaxPullbackBarsRaw = customPreset ? maxPullbackBars : dailyPreset ? math.max(maxPullbackBars, 18) : activePreset ? math.min(maxPullbackBars, 14) : maxPullbackBars
usedMaxPullbackBars = math.max(usedMaxPullbackBarsRaw, minPullbackBars + 1)

usedPreferredDepthRaw = customPreset ? preferredDepthPct : dailyPreset ? math.max(preferredDepthPct, 50.0) : activePreset ? math.min(preferredDepthPct, 38.2) : preferredDepthPct
usedHardDepthRaw = customPreset ? hardDepthPct : dailyPreset ? math.max(hardDepthPct, 88.6) : activePreset ? math.min(hardDepthPct, 78.6) : hardDepthPct
usedPreferredDepthPct = math.min(usedPreferredDepthRaw, usedHardDepthRaw - 0.5)
usedHardDepthPct = math.max(usedHardDepthRaw, usedPreferredDepthPct + 0.5)
usedTriggerDepthPct = lvp_clamp(dailyPreset ? 61.8 : usedPreferredDepthPct, usedPreferredDepthPct, usedHardDepthPct)

effectivePreferredDryRvol = math.min(preferredDryRvol, hardRvol - 0.05)
effectiveHardRvol = math.max(hardRvol, effectivePreferredDryRvol + 0.05)
effectiveStartMaxRvol = math.max(startMaxRvol, effectivePreferredDryRvol)

usedMinDryScore = customPreset ? minDryScore : dailyPreset ? math.max(minDryScore, 68.0) : minDryScore
usedMinWatchQuality = customPreset ? minWatchQuality : dailyPreset ? math.max(minWatchQuality, 78.0) : activePreset ? math.max(minWatchQuality, 72.0) : minWatchQuality
usedSameSideCooldown = customPreset ? sameSideCooldown : dailyPreset ? math.max(sameSideCooldown, 22) : activePreset ? math.min(sameSideCooldown, 14) : sameSideCooldown
usedProjectionBars = customPreset ? projectionBars : dailyPreset ? math.max(projectionBars, 45) : activePreset ? math.min(projectionBars, 28) : projectionBars
usedMaxStructures = customPreset ? maxStructures : dailyPreset ? math.min(maxStructures, 12) : activePreset ? math.min(maxStructures, 10) : maxStructures

effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

chartSeconds = timeframe.in_seconds(timeframe.period)
belowBestView = timeframe.isintraday and not na(chartSeconds) and chartSeconds < 14400
cleanLowTf = lowTfCleanMode and belowBestView
showWatchLabelsEff = showWatchLabels
showZoneLabelsEff = showZoneLabels
usedMaxStructuresEff = cleanLowTf ? math.min(usedMaxStructures, 6) : usedMaxStructures

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
engineWarmup = math.max(
     emaSlowLen,
     math.max(usedImpulseLookback, math.max(usedRvolLength, atrLength))
 ) + math.max(slopeLookback, adxSmoothing) + 5
engineReady = bar_index > engineWarmup
proofConfirmedBar = barstate.isconfirmed

fastEma = ta.ema(close, emaFastLen)
midEma = ta.ema(close, emaMidLen)
slowEma = ta.ema(close, emaSlowLen)
atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, 0.0), syminfo.mintick)
volumeAverage = ta.sma(volume, usedRvolLength)
rvol = not na(volumeAverage) and volumeAverage > 0 ? volume / volumeAverage : 1.0
priorClose = nz(close[1], close)
priorHigh = nz(ta.highest(high, usedImpulseLookback)[1], high)
priorLow = nz(ta.lowest(low, usedImpulseLookback)[1], low)
[plusDi, minusDi, adxValue] = ta.dmi(diLength, adxSmoothing)

hasSlopeHistory = not na(midEma[slopeLookback])
midSlopeAtr = hasSlopeHistory ? (midEma - midEma[slopeLookback]) / safeAtr : 0.0
bullTrend = engineReady and fastEma > midEma and midEma > slowEma and close > midEma and midSlopeAtr >= minSlopeAtr and adxValue >= minAdx and plusDi >= minusDi
bearTrend = engineReady and fastEma < midEma and midEma < slowEma and close < midEma and midSlopeAtr <= -minSlopeAtr and adxValue >= minAdx and minusDi >= plusDi
bullWatch = not bullTrend and fastEma > slowEma and close > slowEma and midSlopeAtr > -minSlopeAtr and plusDi >= minusDi * 0.85
bearWatch = not bearTrend and fastEma < slowEma and close < slowEma and midSlopeAtr < minSlopeAtr and minusDi >= plusDi * 0.85
trendDir = bullTrend ? 1 : bearTrend ? -1 : bullWatch ? 1 : bearWatch ? -1 : 0
confirmedTrend = bullTrend or bearTrend

trendSlopeScore = lvp_clamp(math.abs(midSlopeAtr) / math.max(minSlopeAtr * 3.0, 0.01) * 100.0, 0.0, 100.0)
adxScore = lvp_clamp((adxValue - minAdx) / math.max(minAdx, 1.0) * 100.0, 0.0, 100.0)
trendScore = trendDir == 0 ? 0.0 : trendSlopeScore * 0.42 + adxScore * 0.33 + (confirmedTrend ? 25.0 : 12.0)

plot(showTrendAnchors ? fastEma : na, "Fast EMA", color = color.new(bullColor, 15), linewidth = 1)
plot(showTrendAnchors ? midEma : na, "Mid EMA", color = color.new(accentColor, 10), linewidth = 1)
plot(showTrendAnchors ? slowEma : na, "Slow EMA", color = color.new(neutralColor, 10), linewidth = 2)

// -------------------------------------------------
// Pullback State
// -------------------------------------------------
var bool pocketActive = false
var int pocketDir = 0
var int pocketBars = 0
var float pocketTop = na
var float pocketBottom = na
var float pocketAnchorHigh = na
var float pocketAnchorLow = na
var float pocketRvolSum = 0.0
var box activePocketBox = na
var line activeBoundaryLine = na
var label activeBoundaryBadge = na
var box[] completedPocketBoxes = array.new_box()
var line[] completedBoundaryLines = array.new_line()
var label[] signalLabels = array.new_label()
var label[] zoneLabels = array.new_label()
var label[] completedBoundaryBadges = array.new_label()
var int lastBullSignalBar = na
var int lastBearSignalBar = na
var int lastBullWatchBar = na
var int lastBearWatchBar = na
var bool watchLabelPrinted = false
var bool proofArmedThisPocket = false
var string lastTriggerState = "Waiting"
var float lastDryScore = na
var float lastDepthPct = na
var float lastFailureRisk = na
var float lastAvgRvol = na
var int lastEventBar = na

bullLaneTouch = low <= fastEma + emaLaneAtr * safeAtr or low <= midEma + emaLaneAtr * safeAtr
bearLaneTouch = high >= fastEma - emaLaneAtr * safeAtr or high >= midEma - emaLaneAtr * safeAtr
bullPullbackStart = not pocketActive and trendDir == 1 and bullLaneTouch and close > slowEma and rvol <= effectiveStartMaxRvol and close <= math.max(open, priorClose)
bearPullbackStart = not pocketActive and trendDir == -1 and bearLaneTouch and close < slowEma and rvol <= effectiveStartMaxRvol and close >= math.min(open, priorClose)
startPocket = bullPullbackStart or bearPullbackStart

if startPocket
    if not na(activePocketBox)
        box.delete(activePocketBox)
    if not na(activeBoundaryLine)
        line.delete(activeBoundaryLine)
    if not na(activeBoundaryBadge)
        label.delete(activeBoundaryBadge)
        activeBoundaryBadge := na
    pocketActive := true
    pocketDir := bullPullbackStart ? 1 : -1
    pocketBars := 1
    pocketTop := high
    pocketBottom := low
    pocketAnchorHigh := math.max(priorHigh, high)
    pocketAnchorLow := math.min(priorLow, low)
    pocketRvolSum := rvol
    watchLabelPrinted := false
    proofArmedThisPocket := false
    lastTriggerState := "Mapping"
    if showActivePocket
        activePocketBox := box.new(bar_index, pocketTop, bar_index, pocketBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 89),
             border_color = color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 18),
             border_width = 1)
    startBoundary = pocketDir == 1 ? pocketBottom - invalidationAtr * safeAtr : pocketTop + invalidationAtr * safeAtr
    if showInvalidationBoundary
        activeBoundaryLine := line.new(bar_index, startBoundary, bar_index, startBoundary,
             xloc = xloc.bar_index,
             color = color.new(boundaryColor, 12),
             style = line.style_dotted,
             width = 1)
        activeBoundaryBadge := label.new(
             bar_index,
             startBoundary,
             "INVALID",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = color.new(boundaryColor, 4),
             textcolor = lvp_text_on(boundaryColor),
             size = lvp_size(labelSizeInput))
else if pocketActive
    pocketBars += 1
    pocketTop := math.max(pocketTop, high)
    pocketBottom := math.min(pocketBottom, low)
    pocketRvolSum += rvol

pocketPriceSpan = pocketActive ? math.max(pocketAnchorHigh - pocketAnchorLow, syminfo.mintick) : na
depthPct = pocketActive ? (pocketDir == 1 ? (pocketAnchorHigh - pocketBottom) / pocketPriceSpan * 100.0 : (pocketTop - pocketAnchorLow) / pocketPriceSpan * 100.0) : na
avgRvol = pocketActive and pocketBars > 0 ? pocketRvolSum / pocketBars : na
dryScore = pocketActive ? (avgRvol <= effectivePreferredDryRvol ? 100.0 : avgRvol >= effectiveHardRvol ? 0.0 : 100.0 * (1.0 - (avgRvol - effectivePreferredDryRvol) / math.max(effectiveHardRvol - effectivePreferredDryRvol, 0.01))) : na
depthScore = pocketActive ? (depthPct <= usedPreferredDepthPct ? 100.0 : depthPct >= usedHardDepthPct ? 0.0 : 100.0 * (1.0 - (depthPct - usedPreferredDepthPct) / math.max(usedHardDepthPct - usedPreferredDepthPct, 0.01))) : na
durationScore = pocketActive ? (pocketBars < minPullbackBars ? 55.0 * pocketBars / math.max(minPullbackBars, 1) : pocketBars <= usedMaxPullbackBars ? 100.0 : 0.0) : na
triggerLevel = pocketActive ? (pocketDir == 1 ? pocketTop + triggerBufferAtr * safeAtr : pocketBottom - triggerBufferAtr * safeAtr) : na
invalidationLevel = pocketActive ? (pocketDir == 1 ? pocketBottom - invalidationAtr * safeAtr : pocketTop + invalidationAtr * safeAtr) : na
distanceToTriggerAtr = pocketActive ? (pocketDir == 1 ? math.max(triggerLevel - close, 0.0) : math.max(close - triggerLevel, 0.0)) / safeAtr : na
triggerPressureScore = pocketActive ? lvp_clamp(100.0 - distanceToTriggerAtr * 45.0, 0.0, 100.0) : na
qualityScore = pocketActive ? trendScore * 0.20 + dryScore * 0.28 + depthScore * 0.24 + durationScore * 0.12 + triggerPressureScore * 0.16 : na
depthRisk = pocketActive ? lvp_clamp(depthPct / math.max(usedHardDepthPct, 1.0) * 48.0, 0.0, 48.0) : na
volumeRisk = pocketActive ? lvp_clamp((avgRvol - effectivePreferredDryRvol) / math.max(effectiveHardRvol - effectivePreferredDryRvol, 0.01) * 28.0, 0.0, 28.0) : na
timeRisk = pocketActive ? lvp_clamp(pocketBars / math.max(usedMaxPullbackBars, 1) * 24.0, 0.0, 24.0) : na
failureRisk = pocketActive ? lvp_clamp(depthRisk + volumeRisk + timeRisk, 0.0, 100.0) : na

if pocketActive and not na(activePocketBox)
    box.set_right(activePocketBox, bar_index)
    box.set_top(activePocketBox, pocketTop)
    box.set_bottom(activePocketBox, pocketBottom)
    activeAlpha = int(math.round(lvp_clamp(94.0 - nz(dryScore, 0.0) * 0.22, 68.0, 94.0)))
    box.set_bgcolor(activePocketBox, color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, activeAlpha))
    box.set_border_color(activePocketBox, color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 18))

if pocketActive and not na(activeBoundaryLine)
    line.set_x2(activeBoundaryLine, bar_index)
    line.set_y1(activeBoundaryLine, invalidationLevel)
    line.set_y2(activeBoundaryLine, invalidationLevel)

if pocketActive and not na(activeBoundaryBadge)
    int activeBoundaryBadgeX = bar_index + 2
    string activeBoundaryText = "INVALID " + str.tostring(invalidationLevel, format.mintick)
    label.set_xy(activeBoundaryBadge, activeBoundaryBadgeX, invalidationLevel)
    label.set_text(activeBoundaryBadge, activeBoundaryText)
    label.set_style(activeBoundaryBadge, label.style_label_left)
    label.set_color(activeBoundaryBadge, color.new(boundaryColor, 4))
    label.set_textcolor(activeBoundaryBadge, lvp_text_on(boundaryColor))
    label.set_size(activeBoundaryBadge, lvp_size(labelSizeInput))

depthBroken = pocketActive and depthPct > usedHardDepthPct
boundaryBroken = pocketActive and (pocketDir == 1 ? close < invalidationLevel : close > invalidationLevel)
trendLost = pocketActive and (pocketDir == 1 ? close < slowEma : close > slowEma)
stalePocket = pocketActive and pocketBars > usedMaxPullbackBars
invalidationEvent = depthBroken or boundaryBroken or trendLost or stalePocket

volumeRecovered = pocketActive and rvol >= nz(avgRvol, rvol) * recoveryRvolRatio
confirmedBar = not confirmOnClose or barstate.isconfirmed
bullTriggerEvent = pocketActive and pocketDir == 1 and confirmedBar and pocketBars >= minPullbackBars and dryScore >= usedMinDryScore and depthPct <= usedTriggerDepthPct and qualityScore >= minQualityScore and volumeRecovered and close > triggerLevel and close > open
bearTriggerEvent = pocketActive and pocketDir == -1 and confirmedBar and pocketBars >= minPullbackBars and dryScore >= usedMinDryScore and depthPct <= usedTriggerDepthPct and qualityScore >= minQualityScore and volumeRecovered and close < triggerLevel and close < open
triggerEvent = bullTriggerEvent or bearTriggerEvent
watchSideAllowed = pocketDir == 1 ? (na(lastBullWatchBar) or bar_index - lastBullWatchBar >= usedSameSideCooldown) : (na(lastBearWatchBar) or bar_index - lastBearWatchBar >= usedSameSideCooldown)
watchEvent = pocketActive and showWatchLabelsEff and watchSideAllowed and not watchLabelPrinted and pocketBars >= minPullbackBars and dryScore >= usedMinDryScore and depthPct <= usedHardDepthPct and qualityScore >= usedMinWatchQuality and not triggerEvent and not invalidationEvent
sameSideAllowed = triggerEvent and (pocketDir == 1 ? (na(lastBullSignalBar) or bar_index - lastBullSignalBar >= usedSameSideCooldown) : (na(lastBearSignalBar) or bar_index - lastBearSignalBar >= usedSameSideCooldown))

// -------------------------------------------------
// Confirmation-anchored proof (qualified pockets: Follow = continued 1R in trend before invalidation lost)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false

bool pocketQualified = pocketActive and pocketBars >= minPullbackBars and not na(dryScore) and dryScore >= usedMinDryScore and not na(depthPct) and depthPct <= usedHardDepthPct and not na(qualityScore) and qualityScore >= usedMinWatchQuality and not na(invalidationLevel)
bool newQualifyAnchor = proofConfirmedBar and pocketQualified and not proofArmedThisPocket

if proofConfirmedBar and engineReady
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool ambiguousNow = targetTouched and stopTouched

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched
                    proofFlip := proofFlip + 1
            pEvalActive := false

    // Each pocket can arm the Proof layer only once. If another sample is
    // already active, the overlapping pocket is intentionally not sampled.
    if newQualifyAnchor
        proofArmedThisPocket := true
        if not pEvalActive and pocketDir != 0
            float pStopDist = math.max(math.abs(close - invalidationLevel), syminfo.mintick)
            pEvalActive := true
            pEvalDir := pocketDir
            pEvalEntry := close
            pEvalStop := invalidationLevel
            pEvalTarget := close + pocketDir * pStopDist
            pEvalStart := bar_index
            pReacted := false
            pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

if watchEvent
    watchText = labelDetail == "Compact" ? "DRY-UP" : "DRY-UP WATCH\nQ " + str.tostring(math.round(qualityScore)) + " | RVOL " + str.tostring(avgRvol, "#.##")
    watchY = pocketDir == 1 ? low - labelOffsetAtr * safeAtr * 0.65 : high + labelOffsetAtr * safeAtr * 0.65
    watchLabel = label.new(bar_index, watchY, watchText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = pocketDir == 1 ? label.style_label_up : label.style_label_down,
         textcolor = lvp_text_on(accentColor),
         color = color.new(accentColor, 12),
         size = lvp_size(labelSizeInput))
    array.push(signalLabels, watchLabel)
    if pocketDir == 1
        lastBullWatchBar := bar_index
    else
        lastBearWatchBar := bar_index
    watchLabelPrinted := true

if triggerEvent
    lastTriggerState := pocketDir == 1 ? "Bull Trigger" : "Bear Trigger"
    lastDryScore := dryScore
    lastDepthPct := depthPct
    lastFailureRisk := failureRisk
    lastAvgRvol := avgRvol
    lastEventBar := bar_index
    originalPocketRange = math.max(pocketTop - pocketBottom, syminfo.mintick)
    functionalZoneSize = originalPocketRange * functionalZonePct / 100.0
    projectedZoneTop = pocketDir == 1 ? pocketTop : pocketBottom + functionalZoneSize
    projectedZoneBottom = pocketDir == 1 ? pocketTop - functionalZoneSize : pocketBottom
    zoneMid = (projectedZoneTop + projectedZoneBottom) * 0.5
    zoneRight = bar_index + usedProjectionBars
    if pocketDir == 1
        lastBullSignalBar := bar_index
    else
        lastBearSignalBar := bar_index
    box completedStructureBox = na
    line completedStructureLine = na
    label completedZoneBadge = na
    label completedBoundaryBadge = na

    if not na(activePocketBox)
        if showCompletedPockets
            box.set_right(activePocketBox, zoneRight)
            box.set_top(activePocketBox, projectedZoneTop)
            box.set_bottom(activePocketBox, projectedZoneBottom)
            box.set_bgcolor(activePocketBox, color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 78))
            box.set_border_color(activePocketBox, color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 5))
            completedStructureBox := activePocketBox
        else
            box.delete(activePocketBox)
        activePocketBox := na
    else if showCompletedPockets
        completedBox = box.new(bar_index, projectedZoneTop, zoneRight, projectedZoneBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 78),
             border_color = color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 5),
             border_width = 1)
        completedStructureBox := completedBox
    if showZoneLabelsEff and showCompletedPockets
        zoneText = (pocketDir == 1 ? "BULL LVP" : "BEAR LVP") + "\nQ " + str.tostring(math.round(qualityScore))
        zoneBadgeX = math.max(bar_index + 4, zoneRight - 4)
        zoneLabel = label.new(zoneBadgeX, zoneMid, zoneText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             textcolor = lvp_text_on(pocketDir == 1 ? bullPocketColor : bearPocketColor),
             color = color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 8),
             size = lvp_size(labelSizeInput))
        completedZoneBadge := zoneLabel
    if not na(activeBoundaryLine)
        if showCompletedPockets
            line.set_x2(activeBoundaryLine, zoneRight)
            line.set_y1(activeBoundaryLine, invalidationLevel)
            line.set_y2(activeBoundaryLine, invalidationLevel)
            line.set_color(activeBoundaryLine, color.new(boundaryColor, 0))
            completedStructureLine := activeBoundaryLine

            int completedBoundaryBadgeX = zoneRight + 2
            string completedBoundaryText = "INVALID " + str.tostring(invalidationLevel, format.mintick)
            if na(activeBoundaryBadge)
                completedBoundaryBadge := label.new(
                     completedBoundaryBadgeX,
                     invalidationLevel,
                     completedBoundaryText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_left,
                     color = color.new(boundaryColor, 0),
                     textcolor = lvp_text_on(boundaryColor),
                     size = lvp_size(labelSizeInput))
            else
                label.set_xy(activeBoundaryBadge, completedBoundaryBadgeX, invalidationLevel)
                label.set_text(activeBoundaryBadge, completedBoundaryText)
                label.set_style(activeBoundaryBadge, label.style_label_left)
                label.set_color(activeBoundaryBadge, color.new(boundaryColor, 0))
                label.set_textcolor(activeBoundaryBadge, lvp_text_on(boundaryColor))
                label.set_size(activeBoundaryBadge, lvp_size(labelSizeInput))
                completedBoundaryBadge := activeBoundaryBadge
        else
            line.delete(activeBoundaryLine)
            if not na(activeBoundaryBadge)
                label.delete(activeBoundaryBadge)

        activeBoundaryLine := na
        activeBoundaryBadge := na

    if showCompletedPockets and not na(completedStructureBox)
        array.push(completedPocketBoxes, completedStructureBox)
        array.push(completedBoundaryLines, completedStructureLine)
        array.push(zoneLabels, completedZoneBadge)
        array.push(completedBoundaryBadges, completedBoundaryBadge)
        lvp_trim_completed_structures(
             completedPocketBoxes,
             completedBoundaryLines,
             zoneLabels,
             completedBoundaryBadges,
             usedMaxStructuresEff)
    if showTriggerLabels and sameSideAllowed
        scoreText = str.tostring(math.round(qualityScore))
        labelText = labelDetail == "Compact" ? (pocketDir == 1 ? "BULL LVP " : "BEAR LVP ") + scoreText :
             labelDetail == "Detailed" ? (pocketDir == 1 ? "BULL DRY-UP\n" : "BEAR DRY-UP\n") + "Q " + scoreText + " | RVOL " + str.tostring(avgRvol, "#.##") + "\nDepth " + str.tostring(depthPct, "#.#") + "%" :
             (pocketDir == 1 ? "BULL DRY-UP\n" : "BEAR DRY-UP\n") + "Q " + scoreText + " | RVOL " + str.tostring(avgRvol, "#.##")
        labelY = pocketDir == 1 ? low - labelOffsetAtr * safeAtr : high + labelOffsetAtr * safeAtr
        newLabel = label.new(bar_index, labelY, labelText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = pocketDir == 1 ? label.style_label_up : label.style_label_down,
             textcolor = lvp_text_on(pocketDir == 1 ? bullPocketColor : bearPocketColor),
             color = color.new(pocketDir == 1 ? bullPocketColor : bearPocketColor, 0),
             size = lvp_size(labelSizeInput))
        array.push(signalLabels, newLabel)
    pocketActive := false
    pocketDir := 0
    pocketBars := 0
    pocketTop := na
    pocketBottom := na
    pocketAnchorHigh := na
    pocketAnchorLow := na
    pocketRvolSum := 0.0
    watchLabelPrinted := false

if invalidationEvent and not triggerEvent
    lastTriggerState := boundaryBroken ? "Boundary Lost" : depthBroken ? "Depth Broken" : trendLost ? "Trend Lost" : "Expired"
    lastDryScore := dryScore
    lastDepthPct := depthPct
    lastFailureRisk := failureRisk
    lastAvgRvol := avgRvol
    lastEventBar := bar_index
    if showFailureTags
        failY = pocketDir == 1 ? high + labelOffsetAtr * safeAtr : low - labelOffsetAtr * safeAtr
        failLabel = label.new(bar_index, failY, "POCKET FAILED",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = pocketDir == 1 ? label.style_label_down : label.style_label_up,
             textcolor = lvp_text_on(neutralColor),
             color = color.new(neutralColor, 5),
             size = lvp_size(labelSizeInput))
        array.push(signalLabels, failLabel)
    if not na(activePocketBox)
        box.delete(activePocketBox)
        activePocketBox := na
    if not na(activeBoundaryLine)
        line.delete(activeBoundaryLine)
        activeBoundaryLine := na
    if not na(activeBoundaryBadge)
        label.delete(activeBoundaryBadge)
        activeBoundaryBadge := na
    pocketActive := false
    pocketDir := 0
    pocketBars := 0
    pocketTop := na
    pocketBottom := na
    pocketAnchorHigh := na
    pocketAnchorLow := na
    pocketRvolSum := 0.0
    watchLabelPrinted := false

lvp_trim_completed_structures(
     completedPocketBoxes,
     completedBoundaryLines,
     zoneLabels,
     completedBoundaryBadges,
     usedMaxStructuresEff)
lvp_trim_labels(signalLabels, usedMaxStructuresEff)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelTextSize = lvp_size(panelSizeInput)
isLightPanel = panelTheme == "Light"
panelBg = lvp_panel_bg(isLightPanel, false)
panelAltBg = lvp_panel_bg(isLightPanel, true)
panelBorder = isLightPanel ? panelBorderL : panelBorderD
panelLabel = isLightPanel ? panelLabelL : panelLabelD
panelValue = isLightPanel ? panelValueL : panelValueD

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
string followTextPanel = proofTotal > 0 ? lvp_pct(followRate) : "--"
string holdTextPanel = proofTotal > 0 ? lvp_pct(holdRate) : "--"
string reactTextPanel = proofTotal > 0 ? lvp_pct(reactRate) : "--"
string flipTextPanel = proofTotal > 0 ? lvp_pct(flipRate) : "--"
color followCol = proofTotal > 0 ? lvp_rate_color(followRate) : panelValue
color holdCol = proofTotal > 0 ? lvp_rate_color(holdRate) : panelValue
color reactCol = proofTotal > 0 ? lvp_rate_color(reactRate) : panelValue
color flipCol = proofTotal > 0 ? lvp_flip_color(flipRate) : panelValue

int panelRowCount = showProof ? 11 : 6
var table panel = na
var int prevPanelRows = -1
if showPanel and (na(panel) or prevPanelRows != panelRowCount)
    if not na(panel)
        table.delete(panel)
    panel := table.new(lvp_pos(panelPosition), 2, panelRowCount, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    prevPanelRows := panelRowCount
if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    prevPanelRows := -1

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, lvp_pos(panelPosition))
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Low Volume Pullback Zones", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    hasPanelMemory = not pocketActive and not na(lastEventBar) and bar_index - lastEventBar <= panelMemoryBars
    trendText = bullTrend ? "Bull Trend" : bearTrend ? "Bear Trend" : bullWatch ? "Bull Watch" : bearWatch ? "Bear Watch" : "No Clean Trend"
    trendCol = trendDir == 1 ? bullColor : trendDir == -1 ? bearColor : neutralColor
    panelDry = pocketActive ? dryScore : hasPanelMemory ? lastDryScore : na
    panelDepth = pocketActive ? depthPct : hasPanelMemory ? lastDepthPct : na
    panelRisk = pocketActive ? failureRisk : hasPanelMemory ? lastFailureRisk : na
    panelRvol = pocketActive ? avgRvol : hasPanelMemory ? lastAvgRvol : na
    triggerText = pocketActive ? "Mapping " + (pocketDir == 1 ? "Bull" : "Bear") : hasPanelMemory ? lastTriggerState : "Waiting"
    dryText = na(panelDry) ? "Waiting" : str.tostring(math.round(panelDry)) + " | RVOL " + str.tostring(panelRvol, "#.##")
    depthText = na(panelDepth) ? "Waiting" : str.tostring(panelDepth, "#.#") + "% " + lvp_depth_text(panelDepth, usedPreferredDepthPct, usedHardDepthPct)
    riskText = na(panelRisk) ? "Waiting" : lvp_risk_text(panelRisk) + " " + str.tostring(math.round(panelRisk))
    dryCol = na(panelDry) ? panelValue : panelDry >= usedMinDryScore ? bullColor : neutralColor
    depthCol = na(panelDepth) ? panelValue : panelDepth <= usedPreferredDepthPct ? accentColor : neutralColor
    triggerCol = triggerText == "Bull Trigger" ? bullColor : triggerText == "Bear Trigger" ? bearColor : triggerText == "Waiting" ? panelValue : accentColor
    riskCol = na(panelRisk) ? panelValue : panelRisk >= 72 ? bearColor : panelRisk >= 45 ? neutralColor : bullColor

    table.cell(panel, 0, 1, "Trend", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, trendText, text_color = lvp_state_on_panel(isLightPanel, trendCol), bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Dry-Up", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, dryText, text_color = lvp_state_on_panel(isLightPanel, dryCol), bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Depth", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, depthText, text_color = lvp_state_on_panel(isLightPanel, depthCol), bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Trigger", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, triggerText, text_color = lvp_state_on_panel(isLightPanel, triggerCol), bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Risk", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, riskText, text_color = lvp_state_on_panel(isLightPanel, riskCol), bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)
    if showProof
        table.cell(panel, 0, 6, "Proof @ Confirm", text_color = accentColor, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(panel, 1, 6, proofSampleText, text_color = panelLabel, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 7, "Follow Rate", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(panel, 1, 7, followTextPanel, text_color = lvp_state_on_panel(isLightPanel, followCol), bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 8, "Hold Rate", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(panel, 1, 8, holdTextPanel, text_color = lvp_state_on_panel(isLightPanel, holdCol), bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 9, "React Rate", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(panel, 1, 9, reactTextPanel, text_color = lvp_state_on_panel(isLightPanel, reactCol), bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(panel, 0, 10, "Flip Rate", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(panel, 1, 10, flipTextPanel, text_color = lvp_state_on_panel(isLightPanel, flipCol), bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts And Hidden Exports
// -------------------------------------------------
alertcondition(alertBullTrigger and bullTriggerEvent, "Bullish Low Volume Pullback Trigger", "Low Volume Pullback Zones: bullish dry-up pullback confirmed into continuation.")
alertcondition(alertBearTrigger and bearTriggerEvent, "Bearish Low Volume Pullback Trigger", "Low Volume Pullback Zones: bearish dry-up pullback confirmed into continuation.")
alertcondition(alertInvalidation and invalidationEvent and not triggerEvent, "Low Volume Pullback Pocket Invalidated", "Low Volume Pullback Zones: active dry-up pocket lost its structural boundary before confirmation.")

plot(lastDryScore, "Last Dry-Up Score", display = display.none)
plot(lastDepthPct, "Last Pullback Depth", display = display.none)
plot(float(trendDir), "Trend Direction", display = display.none)
plot(followRate, "LVP Follow Rate", display = display.none)
plot(holdRate, "LVP Hold Rate", display = display.none)
plot(reactRate, "LVP React Rate", display = display.none)
plot(flipRate, "LVP Flip Rate", display = display.none)
plot(proofAmbiguous, "LVP Ambiguous Proof Count", display = display.none)
plot(pocketDir, "LVP Active Pocket Direction", display = display.none)
plot(pocketActive ? pocketBars : na, "LVP Active Pocket Age", display = display.none)
plot(pocketActive ? avgRvol : na, "LVP Active Pocket RVOL", display = display.none)
plot(array.size(completedPocketBoxes), "LVP Retained Structure Count", display = display.none)
````
