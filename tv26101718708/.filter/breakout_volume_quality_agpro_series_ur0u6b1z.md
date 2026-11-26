# Breakout Volume Quality [AGPro Series]

- url: https://www.tradingview.com/script/ur0U6b1Z-Breakout-Volume-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;233690aaaee74d0e98450c2714c887d9
- version: 5.0

## Description

Breakout Volume Quality [AGPro Series]

🔷 OVERVIEW

Breakout Volume Quality is a chart-overlay indicator built to answer one specific question:

When price breaks a defended level, did that break carry real participation quality, or was it only a low-conviction move beyond the line?

Many breakout tools detect the level break itself. This script goes one layer deeper. It evaluates the breakout candle through relative volume, body efficiency, close location, distance beyond the broken level, expansion versus ATR, and the quality of the underlying support-resistance range. The output is a clean 0-100 breakout volume quality score, a visual confirmation band, a compact event label, and a retest state panel.

The goal is not to mark every possible breakout. The goal is to separate a cleaner participation-backed break from a weak level poke that deserves less visual attention.

🔹 CORE IDEA

A breakout is more useful when price does more than cross a line.

Breakout Volume Quality looks for a sequence:

1. A support or resistance reference is built from repeated pivot interaction.
2. Price closes beyond that defended level by an ATR-adjusted buffer.
3. The breakout candle is graded for relative volume participation.
4. Candle structure is checked for efficient body control and directional close quality.
5. The move is measured against ATR to understand displacement and expansion.
6. Confirmed events project a forward confirmation band.
7. The script then tracks whether the broken level produces a clean retest hold, expires, or fades back inside.

This creates a more complete event map than a simple arrow above or below a candle.

💠 UNIQUE EDGE

The edge of this script is the "volume verdict" layer.

It does not simply ask whether price broke resistance or support. It asks whether the break showed enough participation quality to deserve confirmation.

That distinction matters because visually similar breakouts can behave very differently:

- A break with elevated relative volume, strong body efficiency, and a close near the directional extreme usually communicates cleaner participation.
- A break with low relative volume, wick-heavy structure, and a weak close beyond the level may be more fragile.
- A move that breaks, confirms, and later holds the band is visually different from a move that immediately fades back inside.

Breakout Volume Quality turns those differences into a readable score and a structured chart layer.

🔶 WHAT MAKES IT DIFFERENT FROM OTHER AGPRO BREAKOUT TOOLS

This script was intentionally designed to avoid overlapping with the existing AGPro breakout family.

It is not a Donchian breakout tool.
It does not revolve around a rolling channel high or low as the main concept. The level reference comes from defended pivot interaction, and the main evaluation is the volume quality of the break.

It is not an Inside Bar breakout tool.
It does not require a parent candle compression pattern. The script can evaluate broader defended levels rather than only inside-bar structures.

It is not an Opening Range breakout tool.
There is no session opening window, no locked opening range, and no session-specific model.

It is not an ATR Envelope breakout tool.
It does not treat a dynamic volatility envelope as the breakout boundary. ATR is used for normalization, buffers, bands, and score scaling.

It is not a Break-Retest quality tool.
The retest state is included for workflow context, but the core score is assigned to the breakout candle and its participation quality. The first retest is not the central scoring event.

It is not a Failed Break or trap-reclaim tool.
Weak breaks are faded as failed confirmations, but the script does not rebuild the event into a reversal or reclaim model.

It is not a general RVOL pressure map.
Relative volume is used specifically to validate level breaks, not to classify all candles into broad pressure states.

This gives Breakout Volume Quality its own clear lane: breakout participation quality around defended levels.

📌 VISUAL COMPONENTS

Breakout Line
The broken level is extended forward so the user can see the exact structural reference being tested.

Decision Rails
Eligible defended support and resistance references are displayed as subtle forward rails. These rails keep the chart active while price is building around a level, without turning the script into a generic support-resistance map.

Volume Build-Up Windows
Compact boxes labeled BULL SETUP or BEAR SETUP can frame areas where price is building volume pressure near an eligible breakout level before confirmation. These windows are concept-native: they show pre-breakout participation pressure, not generic support-resistance zones.

Optional Advanced Layers
RVOL approach marks, quality candle glow, and pressure trail points are available for users who want more activity on the chart, but they are disabled by default so the main public view remains easy to read.

Confirmation Band
A rectangular band is projected around the broken level. Confirmed events use stronger visual emphasis, while weak confirmations are faded so the chart keeps important context without becoming noisy.

Failed-Confirmation Fade
When price breaks a level but fails the volume, score, candle structure, or close-quality model, the event can still be shown as a softer failed confirmation band. Cleaner weak confirmations can also print WEAK UP or WEAK DOWN labels through a minimum-score filter, so the chart gains more context without labeling every low-quality break.

Retest Hold Label
After a confirmed breakout, the script watches the band for a clean hold. A retest hold is labeled only once so the chart remains controlled.

Summary Panel
The panel displays the current breakout side, volume confirmation, expansion, retest state, and score. It is designed for quick chart reading without covering the price action.

⚙️ SCORING MODEL

The score is built from six components:

Relative Volume
Measures whether current participation is meaningfully above its volume baseline.

Body Efficiency
Measures how much of the candle range is represented by the real body.

Directional Close Location
Checks whether the candle closes toward the breakout side of its own range.

Break Distance
Measures how far the close finishes beyond the broken level in ATR terms.

Expansion
Measures the breakout candle range relative to ATR.

Range Quality
Rewards levels that come from a more defined structure rather than a loose oversized range.

Together, these components produce a transparent 0-100 score and a grade-style readout.

🧭 HOW TO USE

Use the script to study whether a breakout has participation quality.

A stronger event usually has:

- A clean close beyond the level.
- Relative volume above the confirmation threshold.
- A body-dominant candle.
- A close near the breakout-side extreme.
- Meaningful ATR-normalized displacement.
- A confirmation band that later holds during a retest.

A weaker event may show:

- Low relative volume.
- A wick-heavy breakout candle.
- A close barely beyond the level.
- Fast return back inside the broken structure.
- A faded failed-confirmation label instead of a confirmed event.

The script is best used as a structured chart-reading layer. It helps organize breakout quality, but it is not a complete trading system by itself.

🔷 KEY INPUTS

Pivot Strength
Controls how support and resistance references are confirmed.

Minimum Level Touches
Requires repeated interaction before a level becomes eligible.

Level Match Tolerance ATR
Groups nearby pivots into one defended level.

Close Beyond Level ATR
Controls how decisive the break must be beyond the level.

RVOL Confirmation Threshold
Defines the participation level required for volume confirmation.

Minimum Body Efficiency
Filters weak, wick-heavy breakout bars.

Directional Close Location
Requires the candle to close toward the breakout side.

Minimum Score To Confirm
Controls how selective confirmed breakout labels should be.

Confirmation Band ATR
Sets the height of the projected band around the broken level.

Retest Watch Window
Defines how long the script watches for a clean retest hold.

Panel Location / Theme / Font Size
Allows the panel to be adapted to different chart layouts.

Label Font Size / Label Offset
Keeps labels readable and away from candle bodies.

🔶 BEST USE CASE

Breakout Volume Quality works best when the chart has visible defended levels and the user wants a cleaner way to judge whether the break had enough participation behind it.

It is especially useful for:

- Breakouts through repeated swing highs or swing lows.
- Range exits where volume quality matters.
- Comparing strong break candles against weak level pokes.
- Reviewing whether a breakout level later behaves as a confirmation band.
- Keeping weak break attempts visible without giving them the same visual weight as confirmed events.

The script is intentionally restrained: no oversized dashboard, no heavy channel system, no session dependency, and no unnecessary signal spam. The chart stays focused on the level, the break, the volume verdict, and the retest state.

🔹 ALERTS

The script includes alert conditions for:

- Bullish breakout volume confirmation.
- Bearish breakout volume confirmation.
- Breakout failed volume confirmation.
- Breakout retest hold.
- Breakout failed back inside.

These alerts are event prompts for chart review and workflow organization.

💎 DESIGN PHILOSOPHY

Breakout Volume Quality is built to feel clean, premium, and practical on a public TradingView chart.

The visual hierarchy is deliberate:

- Confirmed breaks are visible but not loud.
- Cleaner weak confirmations are faded and labeled through a score filter, while low-quality weak breaks stay visually softer.
- Decision rails keep active levels visible between major events.
- Labeled setup windows explain where pre-breakout volume pressure is forming.
- Optional activity layers are available, but the default chart does not rely on unlabeled dots.
- Bands are long enough to make the level meaningful.
- Retest labels appear only when the state actually changes.
- The panel stays compact and focused on the fields that matter.

The result is a breakout tool that is easy to understand at first glance, but still has enough structure underneath to support serious review.

## Source Code

````pine
// -------------------------------------------------
// Breakout Volume Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Breakout Volume Quality evaluates structural level breaks through relative
// volume, candle efficiency, close displacement, range expansion and retest
// behavior. It turns breakout attempts into a compact quality map with
// defended levels, confirmed volume-verdict bands, setup windows, event
// scoring, a clear next action and a hold-rate proof, all in a premium status
// panel. Built for RVOL breakout confirmation, failed breakout detection,
// clean retest mapping and volume-backed breakout quality analysis without
// turning the chart into a generic signal dashboard.
// -------------------------------------------------

//@version=6
indicator("Breakout Volume Quality [AGPro Series]",
     shorttitle       = "AG Pro BVQ",
     overlay          = true,
     max_labels_count = 240,
     max_lines_count  = 240,
     max_boxes_count  = 180)

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
groupCore = "Core Logic"
groupVolume = "Volume Quality"
groupScore = "Breakout Score"
groupRetest = "Retest State"
groupVisual = "Visuals"
groupPanel = "Panel"
groupAlert = "Alerts"

pivotLen = input.int(4, "Pivot Strength", minval = 2, maxval = 20, group = groupCore,
     tooltip = "Bars on each side required to confirm a structural pivot used as a breakout reference.")

minTouches = input.int(2, "Minimum Level Touches", minval = 1, maxval = 5, group = groupCore,
     tooltip = "Requires repeated pivot interaction before a support or resistance level becomes eligible.")

levelToleranceAtr = input.float(0.35, "Level Match Tolerance (ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = groupCore,
     tooltip = "Groups nearby pivots into one defended level when they are within this ATR-scaled distance.")

maxLevelAge = input.int(180, "Maximum Level Age", minval = 25, maxval = 600, group = groupCore,
     tooltip = "Retires stale support or resistance references so old levels do not dominate the current map.")

breakBufferAtr = input.float(0.08, "Close Beyond Level (ATR)", minval = 0.0, maxval = 1.0, step = 0.01, group = groupCore,
     tooltip = "Requires the close to finish beyond the breakout level by this ATR-scaled buffer.")

eventCooldown = input.int(10, "Event Cooldown Bars", minval = 0, maxval = 100, group = groupCore,
     tooltip = "Prevents repeated breakout markings from stacking too closely around the same structure.")

rvolLen = input.int(30, "Relative Volume Length", minval = 5, maxval = 200, group = groupVolume,
     tooltip = "Moving volume baseline used to calculate relative volume for breakout participation.")

rvolThreshold = input.float(1.35, "RVOL Confirmation Threshold", minval = 0.5, maxval = 5.0, step = 0.05, group = groupVolume,
     tooltip = "Minimum relative volume expected from a confirmed breakout event.")

rvolExtreme = input.float(2.50, "RVOL Full Score Level", minval = 1.0, maxval = 8.0, step = 0.05, group = groupVolume,
     tooltip = "Relative volume level where the volume component reaches its maximum contribution.")

requireVolume = input.bool(true, "Require RVOL Confirmation", group = groupVolume,
     tooltip = "When enabled, weak-volume breaks are treated as failed confirmations even if price breaks the level.")

atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupScore,
     tooltip = "Volatility baseline used for level tolerance, displacement, bands and label placement.")

minBodyEfficiency = input.float(0.48, "Minimum Body Efficiency", minval = 0.10, maxval = 0.95, step = 0.01, group = groupScore,
     tooltip = "Minimum share of the candle range controlled by the real body instead of wick noise.")

minCloseLocation = input.float(0.68, "Directional Close Location", minval = 0.50, maxval = 0.95, step = 0.01, group = groupScore,
     tooltip = "Requires the candle to close toward the breakout side of its own range.")

breakTargetAtr = input.float(0.65, "Full Break Distance (ATR)", minval = 0.10, maxval = 3.0, step = 0.05, group = groupScore,
     tooltip = "Breakout distance beyond the level that earns full displacement score.")

expansionTargetAtr = input.float(1.20, "Full Expansion (ATR)", minval = 0.30, maxval = 4.0, step = 0.05, group = groupScore,
     tooltip = "Candle range in ATR units that earns full range expansion score.")

maxRangeWidthAtr = input.float(5.00, "Preferred Range Width (ATR)", minval = 1.0, maxval = 20.0, step = 0.25, group = groupScore,
     tooltip = "Rewards breaks that emerge from a defined support-resistance range instead of a loose oversized structure.")

minScoreToConfirm = input.int(68, "Minimum Score To Confirm", minval = 1, maxval = 100, group = groupScore,
     tooltip = "Score threshold required for a breakout to be marked as confirmed.")

bandAtr = input.float(0.28, "Confirmation Band (ATR)", minval = 0.05, maxval = 1.50, step = 0.01, group = groupRetest,
     tooltip = "Half-height of the projected confirmation band around the broken level.")

bandForwardBars = input.int(38, "Band Forward Bars", minval = 5, maxval = 200, group = groupRetest,
     tooltip = "How far confirmed and weak confirmation bands extend forward.")

retestWindow = input.int(24, "Retest Watch Window", minval = 3, maxval = 150, group = groupRetest,
     tooltip = "How long the script watches for a clean retest after a confirmed breakout. Also defines the hold-rate proof window.")

failureAtr = input.float(0.35, "Failure Back Inside (ATR)", minval = 0.05, maxval = 2.0, step = 0.01, group = groupRetest,
     tooltip = "Marks a confirmed breakout as failed if price closes back through the level by this ATR-scaled amount.")

showStructure = input.bool(true, "Show Active Structure Levels", group = groupVisual,
     tooltip = "Displays the currently confirmed support and resistance references used by the breakout engine.")

showDecisionRails = input.bool(true, "Show Decision Rails", group = groupVisual,
     tooltip = "Displays subtle forward rails around eligible defended levels.")

decisionRailAtr = input.float(0.16, "Decision Rail Half-Width (ATR)", minval = 0.03, maxval = 0.80, step = 0.01, group = groupVisual,
     tooltip = "Thickness of the active decision rails around support and resistance references.")

decisionRailBackBars = input.int(32, "Decision Rail Back Bars", minval = 5, maxval = 200, group = groupVisual,
     tooltip = "How far active decision rails extend back from the current bar.")

decisionRailForwardBars = input.int(24, "Decision Rail Forward Bars", minval = 5, maxval = 200, group = groupVisual,
     tooltip = "How far active decision rails project forward from the current bar.")

showBands = input.bool(true, "Show Confirmation Bands", group = groupVisual,
     tooltip = "Draws projected rectangular bands around confirmed and selected weak breakout levels.")

showBandLabels = input.bool(true, "Show Band Labels", group = groupVisual,
     tooltip = "Places a compact label at the right edge of each confirmation band.")

showLabels = input.bool(true, "Show Event Labels", group = groupVisual,
     tooltip = "Displays compact confirmed breakout, retest and failure labels.")

labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = groupVisual,
     tooltip = "Controls event label verbosity. Minimal keeps only confirmed result labels; Balanced is publication-friendly; Detailed adds weak confirmation labels when allowed.")

showWeakEvents = input.bool(false, "Show Weak Confirmation Bands", group = groupVisual,
     tooltip = "Keeps higher-quality weak breakout attempts visible as faded bands without making them primary signals. Disabled by default for a cleaner publication view.")

showWeakLabels = input.bool(false, "Show Weak Confirmation Labels", group = groupVisual,
     tooltip = "When enabled, selected weak confirmation events can print compact labels. Disabled by default to reduce clutter.")

minWeakVisualScore = input.int(62, "Minimum Weak Visual Score", minval = 1, maxval = 100, group = groupVisual,
     tooltip = "Minimum score required for weak breakout attempts to receive visual treatment.")

showApproachMarkers = input.bool(false, "Show RVOL Approach Marks", group = groupVisual,
     tooltip = "Adds small participation marks when price approaches an eligible breakout level with elevated relative volume.")

approachRvolThreshold = input.float(1.35, "Approach RVOL Threshold", minval = 0.50, maxval = 5.00, step = 0.05, group = groupVisual,
     tooltip = "Minimum relative volume required for a pre-breakout approach mark.")

approachProximityAtr = input.float(0.80, "Approach Proximity (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual,
     tooltip = "How close price must be to an eligible level before an approach mark can appear.")

approachCooldown = input.int(14, "Approach Marker Cooldown", minval = 0, maxval = 80, group = groupVisual,
     tooltip = "Prevents RVOL approach marks from printing too densely.")

showCandleGlow = input.bool(true, "Show Quality Candle Glow", group = groupVisual,
     tooltip = "Colors efficient participation candles so the chart remains visually active between confirmed breakout events.")

lowTfShowcaseGuard = input.bool(true, "Auto Clean Low-TF View", group = groupVisual,
     tooltip = "When enabled, lower timeframes automatically reduce secondary visual layers for a cleaner breakout view.")

showBuildUpWindows = input.bool(true, "Show Volume Build-Up Windows", group = groupVisual,
     tooltip = "Draws compact windows when volume pressure builds near an eligible breakout level before confirmation.")

showBuildUpLabels = input.bool(true, "Show Setup Labels", group = groupVisual,
     tooltip = "Adds a Setup label to volume build-up windows.")

buildUpLookback = input.int(10, "Build-Up Window Lookback", minval = 5, maxval = 80, group = groupVisual,
     tooltip = "Bars used to frame a pre-breakout volume build-up window.")

buildUpRvolThreshold = input.float(1.55, "Build-Up RVOL Threshold", minval = 0.50, maxval = 5.00, step = 0.05, group = groupVisual,
     tooltip = "Minimum relative volume required for a volume build-up window.")

buildUpMaxWidthAtr = input.float(2.50, "Build-Up Max Width (ATR)", minval = 0.50, maxval = 20.00, step = 0.25, group = groupVisual,
     tooltip = "Limits setup windows to contained areas so broad trends are not boxed unnecessarily.")

buildUpForwardBars = input.int(10, "Build-Up Forward Bars", minval = 3, maxval = 100, group = groupVisual,
     tooltip = "How far volume build-up windows extend forward.")

buildUpCooldown = input.int(40, "Build-Up Window Cooldown", minval = 1, maxval = 120, group = groupVisual,
     tooltip = "Prevents repeated build-up windows from stacking around the same level.")

maxBuildUpWindows = input.int(3, "Maximum Build-Up Windows", minval = 1, maxval = 20, group = groupVisual,
     tooltip = "Maximum number of historical build-up windows kept on chart.")

maxVisualEvents = input.int(8, "Maximum Visible Events", minval = 3, maxval = 60, group = groupVisual,
     tooltip = "Limits historical event objects so the chart remains clean and fast.")

labelOffsetAtr = input.float(0.80, "Label Offset (ATR)", minval = 0.10, maxval = 3.0, step = 0.05, group = groupVisual,
     tooltip = "Moves labels away from candle bodies so they remain readable.")

labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls event, setup and band label text size. Normal is the default publication setting.")

showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows or hides the compact breakout volume quality panel.")

panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = groupPanel,
     tooltip = "Anchor position for the summary panel.")

panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light", "Slate"], group = groupPanel,
     tooltip = "Panel color theme while preserving the AGPro blue header row.")

panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Panel text size. Normal is the default premium layout.")

panelMemoryBars = input.int(120, "Panel Result Memory Bars", minval = 10, maxval = 1000, group = groupPanel,
     tooltip = "How long the panel keeps the last completed breakout result before returning to neutral scanning.")

enableAlerts = input.bool(true, "Enable Alert Conditions", group = groupAlert,
     tooltip = "Enables alert conditions for confirmed breaks, weak breaks, retest holds and failures.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(p) =>
    switch p
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_text_on(_bg) =>
    r = color.r(_bg) / 255.0
    g = color.g(_bg) / 255.0
    b = color.b(_bg) / 255.0
    luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    luminance > 0.45 ? color.rgb(15, 23, 42) : color.white

f_state_on_panel(isLight, _state) =>
    if isLight
        _state == bullColor ? color.rgb(13, 118, 99) : _state == bearColor ? color.rgb(178, 44, 112) : _state == neutralColor ? color.rgb(133, 77, 14) : _state == accentColor ? color.rgb(67, 56, 202) : _state == color.rgb(156, 163, 175) ? color.rgb(71, 85, 105) : _state
    else
        _state

f_grade(scoreValue) =>
    scoreValue >= 88 ? "A+" :
     scoreValue >= 78 ? "A" :
     scoreValue >= 68 ? "B" :
     scoreValue >= 55 ? "C" :
     "D"

f_score_color(scoreValue) =>
    scoreValue >= 78 ? bullColor :
     scoreValue >= 68 ? accentColor :
     scoreValue >= 55 ? neutralColor :
     color.rgb(156, 163, 175)

f_side_text(sideValue, weakValue) =>
    sideValue == 1 ? (weakValue ? "Weak Bull Break" : "Bull Break") :
     sideValue == -1 ? (weakValue ? "Weak Bear Break" : "Bear Break") :
     "Scanning"

f_side_color(sideValue, weakValue) =>
    weakValue ? color.rgb(156, 163, 175) :
     sideValue == 1 ? bullColor :
     sideValue == -1 ? bearColor :
     neutralColor

f_score_text(scoreValue) =>
    na(scoreValue) ? "--" : str.tostring(math.round(scoreValue)) + " / " + f_grade(scoreValue)

f_ratio_text(v) =>
    str.tostring(v, "#.##") + "x"

f_atr_text(v) =>
    str.tostring(v, "#.##") + " ATR"

// -------------------------------------------------
// Timeframe Guidance
// -------------------------------------------------
chartSeconds = timeframe.in_seconds(timeframe.period)
belowBestView = timeframe.isintraday and not na(chartSeconds) and chartSeconds < 14400
lowTfGuardActive = lowTfShowcaseGuard and belowBestView

showStructureEff = showStructure and not lowTfGuardActive
showDecisionRailsEff = showDecisionRails and not lowTfGuardActive
showWeakEventsEff = showWeakEvents and not lowTfGuardActive
showApproachMarkersEff = showApproachMarkers and not lowTfGuardActive
showCandleGlowEff = showCandleGlow and not lowTfGuardActive
showBuildUpWindowsEff = showBuildUpWindows and not lowTfGuardActive
showBuildUpLabelsEff = showBuildUpLabels and not lowTfGuardActive
showBandsEff = showBands
showBandLabelsEff = showBandLabels

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
atr = ta.atr(atrLen)
atrSafe = math.max(nz(atr, 0.0), syminfo.mintick)
volBaseRaw = ta.sma(volume, rvolLen)
volBase = na(volBaseRaw) or volBaseRaw <= 0.0 ? 1.0 : volBaseRaw
rvol = na(volume) ? 1.0 : volume / volBase

barSpan = high - low
barSpanSafe = math.max(barSpan, syminfo.mintick)
bodySize = math.abs(close - open)
bodyEfficiency = bodySize / barSpanSafe
closeLocation = (close - low) / barSpanSafe
barSpanAtr = barSpanSafe / atrSafe

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float resistance = na
var float support = na
var int resistanceTouches = 0
var int supportTouches = 0
var int resistanceBar = na
var int supportBar = na

if not na(pivotHigh)
    pivotAtr = math.max(nz(atr[pivotLen], atrSafe), syminfo.mintick)
    if na(resistance) or math.abs(pivotHigh - resistance) > levelToleranceAtr * pivotAtr
        resistance := pivotHigh
        resistanceTouches := 1
    else
        resistance := (resistance * resistanceTouches + pivotHigh) / (resistanceTouches + 1)
        resistanceTouches += 1
    resistanceBar := bar_index - pivotLen

if not na(pivotLow)
    pivotAtr = math.max(nz(atr[pivotLen], atrSafe), syminfo.mintick)
    if na(support) or math.abs(pivotLow - support) > levelToleranceAtr * pivotAtr
        support := pivotLow
        supportTouches := 1
    else
        support := (support * supportTouches + pivotLow) / (supportTouches + 1)
        supportTouches += 1
    supportBar := bar_index - pivotLen

resistanceLive = not na(resistance) and resistanceTouches >= minTouches and not na(resistanceBar) and bar_index - resistanceBar <= maxLevelAge
supportLive = not na(support) and supportTouches >= minTouches and not na(supportBar) and bar_index - supportBar <= maxLevelAge
haveRange = resistanceLive and supportLive and resistance > support
rangeWidthAtr = haveRange ? (resistance - support) / atrSafe : na

// -------------------------------------------------
// Breakout Scoring
// -------------------------------------------------
var int lastEventBar = na
var float lastScore = na
var int lastSide = 0
var bool lastWeak = false
var string retestState = "Idle"
var string volumeState = "Neutral"
var string expansionState = "Neutral"
var int lastApproachBar = na
var int lastBuildUpBar = na

canPrintEvent = na(lastEventBar) or bar_index - lastEventBar > eventCooldown
bullTriggerLevel = resistance + breakBufferAtr * atrSafe
bearTriggerLevel = support - breakBufferAtr * atrSafe
bullBreak = barstate.isconfirmed and resistanceLive and canPrintEvent and close > bullTriggerLevel and close[1] <= bullTriggerLevel
bearBreak = barstate.isconfirmed and supportLive and canPrintEvent and close < bearTriggerLevel and close[1] >= bearTriggerLevel
breakSide = bullBreak ? 1 : bearBreak ? -1 : 0
breakLevel = breakSide == 1 ? resistance : breakSide == -1 ? support : na
directionalClose = breakSide == 1 ? closeLocation : breakSide == -1 ? 1.0 - closeLocation : 0.5
breakDistanceAtr = breakSide == 1 ? (close - breakLevel) / atrSafe : breakSide == -1 ? (breakLevel - close) / atrSafe : 0.0

volumeScore = f_clamp((rvol - 1.0) / math.max(rvolExtreme - 1.0, 0.01), 0.0, 1.0) * 30.0
bodyScore = f_clamp(bodyEfficiency / math.max(minBodyEfficiency, 0.01), 0.0, 1.0) * 20.0
closeScore = f_clamp((directionalClose - 0.50) / math.max(minCloseLocation - 0.50, 0.01), 0.0, 1.0) * 15.0
distanceScore = f_clamp(breakDistanceAtr / math.max(breakTargetAtr, 0.01), 0.0, 1.0) * 20.0
expansionScore = f_clamp(barSpanAtr / math.max(expansionTargetAtr, 0.01), 0.0, 1.0) * 10.0
structureScore = haveRange ? f_clamp((maxRangeWidthAtr - rangeWidthAtr) / math.max(maxRangeWidthAtr, 0.01), 0.0, 1.0) * 5.0 : 2.5
breakScore = volumeScore + bodyScore + closeScore + distanceScore + expansionScore + structureScore

volumeOk = not requireVolume or rvol >= rvolThreshold
bodyOk = bodyEfficiency >= minBodyEfficiency
closeOk = directionalClose >= minCloseLocation
scoreOk = breakScore >= minScoreToConfirm
confirmedBreak = breakSide != 0 and volumeOk and bodyOk and closeOk and scoreOk
weakBreak = breakSide != 0 and not confirmedBreak
weakVisualOk = weakBreak and breakScore >= minWeakVisualScore

nearResistance = resistanceLive and high >= resistance - approachProximityAtr * atrSafe and close <= resistance + breakBufferAtr * atrSafe
nearSupport = supportLive and low <= support + approachProximityAtr * atrSafe and close >= support - breakBufferAtr * atrSafe
approachCanPrint = na(lastApproachBar) or bar_index - lastApproachBar > approachCooldown
rawBullApproach = showApproachMarkersEff and nearResistance and rvol >= approachRvolThreshold and bodyEfficiency >= minBodyEfficiency * 0.65 and closeLocation >= 0.58 and not bullBreak
rawBearApproach = showApproachMarkersEff and nearSupport and rvol >= approachRvolThreshold and bodyEfficiency >= minBodyEfficiency * 0.65 and closeLocation <= 0.42 and not bearBreak
bullApproach = barstate.isconfirmed and rawBullApproach and approachCanPrint
bearApproach = barstate.isconfirmed and rawBearApproach and approachCanPrint

if bullApproach or bearApproach
    lastApproachBar := bar_index

strongBullPressure = rvol >= rvolThreshold and bodyEfficiency >= minBodyEfficiency and closeLocation >= minCloseLocation
strongBearPressure = rvol >= rvolThreshold and bodyEfficiency >= minBodyEfficiency and closeLocation <= 1.0 - minCloseLocation
softBullPressure = rvol >= rvolThreshold and bodyEfficiency >= minBodyEfficiency * 0.65 and closeLocation >= 0.58
softBearPressure = rvol >= rvolThreshold and bodyEfficiency >= minBodyEfficiency * 0.65 and closeLocation <= 0.42

buildHigh = ta.highest(high, buildUpLookback)
buildLow = ta.lowest(low, buildUpLookback)
buildWidthAtr = (buildHigh - buildLow) / atrSafe
buildCanPrint = na(lastBuildUpBar) or bar_index - lastBuildUpBar > buildUpCooldown
bullBuildUp = barstate.isconfirmed and showBuildUpWindowsEff and buildCanPrint and resistanceLive and buildWidthAtr <= buildUpMaxWidthAtr and rvol >= buildUpRvolThreshold and close <= resistance + breakBufferAtr * atrSafe and high >= resistance - approachProximityAtr * atrSafe
bearBuildUp = barstate.isconfirmed and showBuildUpWindowsEff and buildCanPrint and supportLive and buildWidthAtr <= buildUpMaxWidthAtr and rvol >= buildUpRvolThreshold and close >= support - breakBufferAtr * atrSafe and low <= support + approachProximityAtr * atrSafe

if bullBuildUp or bearBuildUp
    lastBuildUpBar := bar_index

// -------------------------------------------------
// Breakout hold-rate proof (Confirm Rate)
// -------------------------------------------------
var int   confTotal = 0
var int   confHold  = 0
var int   pSide     = 0
var float pLevel    = na
var int   pLeft     = 0

if barstate.isconfirmed
    if pLeft > 0
        failBack = (pSide == 1 and close < pLevel - failureAtr * atrSafe) or (pSide == -1 and close > pLevel + failureAtr * atrSafe)
        if failBack
            confTotal += 1
            pSide := 0
            pLeft := 0
        else if pLeft == 1
            confTotal += 1
            confHold += 1
            pSide := 0
            pLeft := 0
        else
            pLeft -= 1
    if confirmedBreak and pLeft == 0
        pSide := breakSide
        pLevel := breakLevel
        pLeft := retestWindow

breakoutHoldRate = confTotal > 0 ? confHold / confTotal * 100.0 : na

// -------------------------------------------------
// Visual Object Storage
// -------------------------------------------------
var array<line> eventLines = array.new<line>()
var array<box> eventBoxes = array.new<box>()
var array<label> eventLabels = array.new<label>()
var array<label> bandLabels = array.new<label>()
var array<box> buildUpBoxes = array.new<box>()
var array<label> buildUpLabels = array.new<label>()

labelSize = f_size(labelSizeInput)
panelTextSize = f_size(panelSizeInput)
bandHalfHeight = bandAtr * atrSafe

f_trim_line(array<line> arr, maxCount) =>
    while array.size(arr) > maxCount
        old = array.shift(arr)
        if not na(old)
            line.delete(old)

f_trim_box(array<box> arr, maxCount) =>
    while array.size(arr) > maxCount
        old = array.shift(arr)
        if not na(old)
            box.delete(old)

f_trim_label(array<label> arr, maxCount) =>
    while array.size(arr) > maxCount
        old = array.shift(arr)
        if not na(old)
            label.delete(old)

// -------------------------------------------------
// Event Visuals And Active Retest State
// -------------------------------------------------
var int activeSide = 0
var float activeLevel = na
var int activeBreakBar = na
var int activeExpireBar = na
var bool activeRetestPrinted = false
bool retestHoldSignal = false
bool failedBackInsideSignal = false

showLabelsEff = showLabels and (not lowTfGuardActive or breakScore >= 88)
eventVisualAllowed = breakSide != 0 and ((confirmedBreak and (not lowTfGuardActive or breakScore >= 88)) or (showWeakEventsEff and weakVisualOk))
if eventVisualAllowed
    activeColor = confirmedBreak ? (breakSide == 1 ? bullColor : bearColor) : color.rgb(156, 163, 175)
    eventLine = line.new(bar_index - 1, breakLevel, bar_index + bandForwardBars, breakLevel,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(activeColor, confirmedBreak ? 0 : 45),
         style = confirmedBreak ? line.style_solid : line.style_dashed,
         width = confirmedBreak ? 2 : 1)
    array.push(eventLines, eventLine)
    f_trim_line(eventLines, maxVisualEvents)

    if showBandsEff
        eventBox = box.new(bar_index, breakLevel + bandHalfHeight, bar_index + bandForwardBars, breakLevel - bandHalfHeight,
             xloc = xloc.bar_index,
             extend = extend.none,
             bgcolor = color.new(activeColor, confirmedBreak ? 88 : 94),
             border_color = color.new(activeColor, confirmedBreak ? 18 : 70),
             border_width = confirmedBreak ? 2 : 1)
        array.push(eventBoxes, eventBox)
        f_trim_box(eventBoxes, maxVisualEvents)

        if showBandLabelsEff
            bandText = confirmedBreak ? (breakSide == 1 ? "Bull Confirm" : "Bear Confirm") : "Weak Break"
            bandBadgeColor = confirmedBreak ? activeColor : color.rgb(156, 163, 175)
            int bandBadgeX = bar_index + int(math.round(bandForwardBars * 0.5))
            bandLabel = label.new(bandBadgeX, breakLevel, bandText + "\n" + f_score_text(breakScore),
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_center,
                 color = color.new(bandBadgeColor, confirmedBreak ? 8 : 28),
                 textcolor = f_text_on(bandBadgeColor),
                 size = labelSize)
            array.push(bandLabels, bandLabel)
            f_trim_label(bandLabels, maxVisualEvents)

    weakLabelAllowed = weakBreak and showWeakLabels and labelDensity == "Detailed" and weakVisualOk
    confirmedLabelAllowed = showLabelsEff and confirmedBreak
    if confirmedLabelAllowed or weakLabelAllowed
        labelTitle = confirmedBreak ? (breakSide == 1 ? "BVQ Up" : "BVQ Down") : (breakSide == 1 ? "Weak Up" : "Weak Down")
        detail = labelDensity == "Minimal" ? f_score_text(breakScore) :
             labelDensity == "Detailed" ? f_score_text(breakScore) + "\nRVOL " + f_ratio_text(rvol) + " | EXP " + f_atr_text(barSpanAtr) :
             f_score_text(breakScore) + "\nRVOL " + f_ratio_text(rvol)
        labelY = breakSide == 1 ? high + atrSafe * labelOffsetAtr : low - atrSafe * labelOffsetAtr
        labelStyle = breakSide == 1 ? label.style_label_down : label.style_label_up
        eventBadgeColor = confirmedBreak ? activeColor : color.rgb(156, 163, 175)
        eventLabel = label.new(bar_index + 1, labelY, labelTitle + "\n" + detail,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = labelStyle,
             color = color.new(eventBadgeColor, confirmedBreak ? 0 : 35),
             textcolor = f_text_on(eventBadgeColor),
             size = labelSize,
             tooltip = "Breakout quality event. It marks a rule-based quality state, not a trade instruction.")
        array.push(eventLabels, eventLabel)
        f_trim_label(eventLabels, maxVisualEvents)

    lastEventBar := bar_index
    lastScore := breakScore
    lastSide := breakSide
    lastWeak := weakBreak
    volumeState := rvol >= rvolThreshold ? "Confirmed " + f_ratio_text(rvol) : "Weak " + f_ratio_text(rvol)
    expansionState := f_atr_text(barSpanAtr)

    if confirmedBreak
        activeSide := breakSide
        activeLevel := breakLevel
        activeBreakBar := bar_index
        activeExpireBar := bar_index + retestWindow
        activeRetestPrinted := false
        retestState := "Watching"
        if breakSide == 1
            resistance := na
            resistanceTouches := 0
            resistanceBar := na
        else
            support := na
            supportTouches := 0
            supportBar := na
    else
        retestState := "No Confirmation"

// -------------------------------------------------
// Retest State Tracking
// -------------------------------------------------
activeBreakout = activeSide != 0 and not na(activeLevel) and not na(activeBreakBar)
if barstate.isconfirmed and activeBreakout and bar_index > activeBreakBar
    inBand = low <= activeLevel + bandHalfHeight and high >= activeLevel - bandHalfHeight
    bullHold = activeSide == 1 and inBand and close >= activeLevel and close >= open
    bearHold = activeSide == -1 and inBand and close <= activeLevel and close <= open
    bullFail = activeSide == 1 and close < activeLevel - failureAtr * atrSafe
    bearFail = activeSide == -1 and close > activeLevel + failureAtr * atrSafe
    expired = bar_index > activeExpireBar

    if not activeRetestPrinted and not expired and (bullHold or bearHold)
        retestState := "Retest Hold"
        retestHoldSignal := true
        if showLabelsEff
            retestColor = activeSide == 1 ? bullColor : bearColor
            retestY = activeSide == 1 ? low - atrSafe * labelOffsetAtr : high + atrSafe * labelOffsetAtr
            retestStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
            retestLabel = label.new(bar_index, retestY, "Hold",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = retestStyle,
                 color = color.new(retestColor, 0),
                 textcolor = f_text_on(retestColor),
                 size = labelSize)
            array.push(eventLabels, retestLabel)
            f_trim_label(eventLabels, maxVisualEvents)
        activeRetestPrinted := true
        activeSide := 0
        activeLevel := na
        activeBreakBar := na
        activeExpireBar := na

    if bullFail or bearFail
        retestState := "Failed Back Inside"
        failedBackInsideSignal := true
        if showLabelsEff
            failColor = color.rgb(156, 163, 175)
            failY = activeSide == 1 ? low - atrSafe * labelOffsetAtr : high + atrSafe * labelOffsetAtr
            failStyle = activeSide == 1 ? label.style_label_up : label.style_label_down
            failLabel = label.new(bar_index, failY, "Fade",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = failStyle,
                 color = color.new(failColor, 10),
                 textcolor = f_text_on(failColor),
                 size = labelSize)
            array.push(eventLabels, failLabel)
            f_trim_label(eventLabels, maxVisualEvents)
        activeSide := 0
        activeLevel := na
        activeBreakBar := na
        activeExpireBar := na
        activeRetestPrinted := false
    else if expired and not activeRetestPrinted
        retestState := "Retest Expired"
        activeSide := 0
        activeLevel := na
        activeBreakBar := na
        activeExpireBar := na
        activeRetestPrinted := false

// -------------------------------------------------
// Structure, Rails And Setup Windows
// -------------------------------------------------
color candleGlowColor = na
if showCandleGlowEff
    candleGlowColor := strongBullPressure ? color.new(bullColor, 54) :
         strongBearPressure ? color.new(bearColor, 54) :
         softBullPressure ? color.new(bullColor, 78) :
         softBearPressure ? color.new(bearColor, 78) :
         na
barcolor(candleGlowColor)

plot(showStructureEff and resistanceLive ? resistance : na, "Active Resistance", color = color.new(bearColor, 18), linewidth = 2, style = plot.style_linebr)
plot(showStructureEff and supportLive ? support : na, "Active Support", color = color.new(bullColor, 18), linewidth = 2, style = plot.style_linebr)
plotshape(bullApproach, title = "Bullish RVOL Approach", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 10), size = size.tiny)
plotshape(bearApproach, title = "Bearish RVOL Approach", style = shape.circle, location = location.abovebar, color = color.new(bearColor, 10), size = size.tiny)

if bullBuildUp or bearBuildUp
    buildColor = bullBuildUp ? bullColor : bearColor
    buildText = bullBuildUp ? "Bull Setup" : "Bear Setup"
    int buildLeft = math.max(0, bar_index - buildUpLookback + 1)
    int buildRight = bar_index + buildUpForwardBars
    buildMid = (buildHigh + buildLow) * 0.5
    buildBox = box.new(buildLeft, buildHigh, buildRight, buildLow,
         xloc = xloc.bar_index,
         bgcolor = color.new(buildColor, 94),
         border_color = color.new(buildColor, 32),
         border_width = 1)
    array.push(buildUpBoxes, buildBox)
    f_trim_box(buildUpBoxes, maxBuildUpWindows)
    if showBuildUpLabelsEff
        int buildBadgeX = int(math.round((buildLeft + buildRight) * 0.5))
        buildLabel = label.new(buildBadgeX, buildMid, buildText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_center,
             color = color.new(buildColor, 16),
             textcolor = f_text_on(buildColor),
             size = labelSize)
        array.push(buildUpLabels, buildLabel)
        f_trim_label(buildUpLabels, maxBuildUpWindows)

var box resistanceRail = na
var box supportRail = na
var label resistanceRailBadge = na
var label supportRailBadge = na
railHalfHeight = decisionRailAtr * atrSafe
int railLeft = math.max(0, bar_index - decisionRailBackBars)
int railRight = bar_index + decisionRailForwardBars
int railBadgeX = bar_index + int(math.round(decisionRailForwardBars * 0.55))

if showDecisionRailsEff and resistanceLive
    if na(resistanceRail)
        resistanceRail := box.new(railLeft, resistance + railHalfHeight, railRight, resistance - railHalfHeight,
             xloc = xloc.bar_index,
             bgcolor = color.new(bearColor, 95),
             border_color = color.new(bearColor, 42),
             border_width = 1)
    else
        box.set_left(resistanceRail, railLeft)
        box.set_right(resistanceRail, railRight)
        box.set_top(resistanceRail, resistance + railHalfHeight)
        box.set_bottom(resistanceRail, resistance - railHalfHeight)
    if na(resistanceRailBadge)
        resistanceRailBadge := label.new(railBadgeX, resistance, "RESISTANCE WATCH", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bearColor, 4), textcolor = f_text_on(bearColor), size = labelSize)
    else
        label.set_xy(resistanceRailBadge, railBadgeX, resistance)
        label.set_size(resistanceRailBadge, labelSize)
else
    if not na(resistanceRail)
        box.delete(resistanceRail)
        resistanceRail := na
    if not na(resistanceRailBadge)
        label.delete(resistanceRailBadge)
        resistanceRailBadge := na

if showDecisionRailsEff and supportLive
    if na(supportRail)
        supportRail := box.new(railLeft, support + railHalfHeight, railRight, support - railHalfHeight,
             xloc = xloc.bar_index,
             bgcolor = color.new(bullColor, 95),
             border_color = color.new(bullColor, 42),
             border_width = 1)
    else
        box.set_left(supportRail, railLeft)
        box.set_right(supportRail, railRight)
        box.set_top(supportRail, support + railHalfHeight)
        box.set_bottom(supportRail, support - railHalfHeight)
    if na(supportRailBadge)
        supportRailBadge := label.new(railBadgeX, support, "SUPPORT WATCH", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bullColor, 4), textcolor = f_text_on(bullColor), size = labelSize)
    else
        label.set_xy(supportRailBadge, railBadgeX, support)
        label.set_size(supportRailBadge, labelSize)
else
    if not na(supportRail)
        box.delete(supportRail)
        supportRail := na
    if not na(supportRailBadge)
        label.delete(supportRailBadge)
        supportRailBadge := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
isLightPanel = panelTheme == "Light"
isSlatePanel = panelTheme == "Slate"
panelBg = isLightPanel ? panelBgL : isSlatePanel ? color.rgb(30, 41, 59) : panelBgD
panelAltBg = isLightPanel ? color.rgb(226, 232, 240) : isSlatePanel ? color.rgb(51, 65, 85) : color.rgb(30, 41, 59)
panelBorder = isLightPanel ? panelBorderL : isSlatePanel ? color.rgb(71, 85, 105) : panelBorderD
panelLabel = isLightPanel ? panelLabelL : isSlatePanel ? color.rgb(203, 213, 225) : panelLabelD
panelValue = isLightPanel ? panelValueL : panelValueD

var table panel = na

if showPanel and na(panel)
    panel := table.new(f_pos(panelPosition), 2, 8, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Breakout Volume Quality", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize)
    table.merge_cells(panel, 0, 0, 1, 0)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 1, 1, 7)

    panelFresh = not na(lastEventBar) and bar_index - lastEventBar <= panelMemoryBars
    panelSideText = activeSide != 0 ? f_side_text(activeSide, false) : panelFresh ? f_side_text(lastSide, lastWeak) : "Scanning"
    panelSideColorRaw = activeSide != 0 ? f_side_color(activeSide, false) : panelFresh ? f_side_color(lastSide, lastWeak) : neutralColor
    panelSideColor = f_state_on_panel(isLightPanel, panelSideColorRaw)
    panelVolumeText = panelFresh ? volumeState : "RVOL " + f_ratio_text(rvol)
    panelExpansionText = panelFresh ? expansionState : f_atr_text(barSpanAtr)
    panelRetestText = panelFresh ? retestState : "Idle"
    panelScoreText = panelFresh ? f_score_text(lastScore) : "--"
    panelScoreColorRaw = panelFresh and not na(lastScore) ? f_score_color(lastScore) : neutralColor
    panelScoreColor = f_state_on_panel(isLightPanel, panelScoreColorRaw)

    nextActionText = activeSide == 1 ? "Long break - watch retest" :
         activeSide == -1 ? "Short break - watch retest" :
         panelRetestText == "Retest Hold" ? "Hold confirmed - manage" :
         panelRetestText == "Failed Back Inside" ? "Break failed - stand down" :
         (resistanceLive or supportLive) ? "Scanning - watch levels" :
         "No levels - wait"
    nextActionColorRaw = activeSide == 1 ? bullColor :
         activeSide == -1 ? bearColor :
         panelRetestText == "Retest Hold" ? bullColor :
         panelRetestText == "Failed Back Inside" ? bearColor :
         (resistanceLive or supportLive) ? accentColor : neutralColor
    nextActionColor = f_state_on_panel(isLightPanel, nextActionColorRaw)

    holdRateText = confTotal > 0 ? str.tostring(int(math.round(breakoutHoldRate))) + "% (" + str.tostring(confTotal) + ")" : "Building"
    holdRateColor = na(breakoutHoldRate) ? panelValue : f_state_on_panel(isLightPanel, breakoutHoldRate >= 55.0 ? bullColor : breakoutHoldRate >= 45.0 ? neutralColor : bearColor)

    volumeCellColor = f_state_on_panel(isLightPanel, rvol >= rvolThreshold ? bullColor : neutralColor)
    retestCellColor = panelRetestText == "Retest Hold" ? f_state_on_panel(isLightPanel, bullColor) : panelRetestText == "Failed Back Inside" ? f_state_on_panel(isLightPanel, bearColor) : panelValue

    table.cell(panel, 0, 1, "Breakout", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, panelSideText, text_color = panelSideColor, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)

    table.cell(panel, 0, 2, "Next Action", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, nextActionText, text_color = nextActionColor, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)

    table.cell(panel, 0, 3, "Score", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, panelScoreText, text_color = panelScoreColor, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)

    table.cell(panel, 0, 4, "Volume", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, panelVolumeText, text_color = volumeCellColor, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)

    table.cell(panel, 0, 5, "Retest", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, panelRetestText, text_color = retestCellColor, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)

    table.cell(panel, 0, 6, "Hold Rate", text_color = panelLabel, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, holdRateText, text_color = holdRateColor, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)

    table.cell(panel, 0, 7, "Expansion", text_color = panelLabel, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, panelExpansionText, text_color = panelValue, bgcolor = panelBg, text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(enableAlerts and confirmedBreak and breakSide == 1, "Bullish Breakout Volume Confirmed", "Breakout Volume Quality: bullish breakout passed the volume quality model.")
alertcondition(enableAlerts and confirmedBreak and breakSide == -1, "Bearish Breakout Volume Confirmed", "Breakout Volume Quality: bearish breakout passed the volume quality model.")
alertcondition(enableAlerts and weakBreak, "Breakout Failed Volume Confirmation", "Breakout Volume Quality: price broke a level but failed the confirmation model.")
alertcondition(enableAlerts and retestHoldSignal, "Breakout Retest Hold", "Breakout Volume Quality: confirmed breakout produced a valid retest hold.")
alertcondition(enableAlerts and failedBackInsideSignal, "Breakout Failed Back Inside", "Breakout Volume Quality: confirmed breakout closed back through the broken level.")

plot(lastScore, "Last Breakout Quality Score", display = display.none)
plot(breakoutHoldRate, "Breakout Hold Rate", display = display.none)
plot(rvol, "Relative Volume", display = display.none)
plot(float(activeSide), "Active Retest Side", display = display.none)
````
