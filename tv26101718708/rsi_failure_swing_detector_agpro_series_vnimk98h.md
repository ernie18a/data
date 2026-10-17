# RSI Failure Swing Detector [AGPro Series]

- url: https://www.tradingview.com/script/vNiMk98H-RSI-Failure-Swing-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;d642dddd94e54c7c9640a7714e161a2e
- version: 5.0

## Description

RSI Failure Swing Detector [AGPro Series]

🔹 **Overview**

RSI Failure Swing Detector [AGPro Series] is a focused RSI reversal-structure tool built around one classic momentum concept: the confirmed RSI failure swing.

Instead of treating every oversold or overbought RSI reading as a reversal condition, this script waits for the full internal RSI sequence:

1. RSI reaches an extreme zone.
2. RSI recovers or reacts away from that extreme.
3. RSI pulls back while respecting the original RSI extreme.
4. RSI breaks the internal swing level that confirms the failure swing.

Only after that sequence is complete does the script mark a confirmed trigger on the chart.

The purpose is to make RSI failure swings easier to read in real time without turning the tool into a generic divergence scanner, RSI pressure map, or broad reversal dashboard.

🔹 **What Makes It Different**

Most RSI tools focus on one of three common ideas:

- RSI overbought and oversold levels.
- RSI divergence against price.
- RSI momentum or pressure state.

This script is intentionally different.

RSI Failure Swing Detector does not look for RSI divergence. It does not compare RSI swings against price swings to create hidden or regular divergence logic. It also does not measure RSI pressure, trend pressure, or directional dominance.

Its job is narrower and cleaner:

**It detects when RSI builds a classic failure swing sequence and then confirms that sequence through an internal RSI swing break.**

That keeps the tool separated from existing AGPro momentum scripts such as RSI Pressure Map, Stochastic Exhaustion Map, Multi-Oscillator Consensus Engine, Divergence Stack Scanner, and broader reversal-quality tools. The analytical lane here is not "is pressure building?" or "is price diverging?" The lane is:

**Has RSI completed a confirmed failure swing sequence?**

🔹 **Core Logic**

The bullish model starts when RSI moves into the oversold zone. The script then tracks the first recovery leg, waits for a pullback that stays meaningfully above the original RSI low, and confirms the pattern only when RSI breaks the recovery high.

The bearish model works in the opposite direction. It starts when RSI moves into the overbought zone, tracks the first reaction leg, waits for a bounce that stays meaningfully below the original RSI high, and confirms the pattern only when RSI breaks the reaction low.

This creates a clean four-part sequence:

- Extreme
- Recovery or reaction
- Controlled pullback
- Confirmed internal break

The confirmation step is important. The script is designed to avoid printing premature reversal labels while RSI is still only sitting at an extreme.

🔹 **Trigger Pockets**

When a failure swing is confirmed, the script can project a short chart-level trigger pocket from the confirmation bar.

These pockets are not generic support or resistance zones. They are failure-swing context zones designed to help the user visually track whether price respects or loses the area around a confirmed momentum trigger.

The pocket is time-limited, ATR-scaled, and capped by a maximum visible pocket setting so the chart remains clean.

🔹 **Panel**

The AGPro panel summarizes the active environment:

- RSI State
- Swing Stage
- Confirmation
- Sequence Score
- Trigger Pocket status

The first panel row follows the AGPro standard: one merged blue header row containing only the script title. Panel location, panel theme, label size, and panel font size are all configurable from settings.

🔹 **Visual Design**

The chart layer is intentionally restrained.

Stage labels explain where the RSI sequence is developing, while confirmed trigger labels appear only after the failure swing is complete. The default stage-label mode highlights only the final setup stage before confirmation, keeping lower-timeframe charts cleaner while still preserving the sequence logic.

Label cooldowns, maximum visible label limits, ATR-based offsets, compact trigger labels, and capped trigger pockets are included to keep the chart readable.

The default visual style is designed for a premium public chart: informative, but not crowded.

🔹 **Inputs**

Key settings include:

- RSI Length
- RSI Source
- Oversold Level
- Overbought Level
- Minimum RSI Separation
- Minimum RSI Pullback
- Maximum Sequence Bars
- Confirm On Bar Close
- Stage Label Detail
- Trigger Pocket Depth
- Trigger Pocket Projection Bars
- Panel Signal Memory Bars
- Label and panel size controls
- Panel location and theme controls

These settings allow the user to tune the detector for different symbols and timeframes while preserving the core failure swing structure.

🔹 **Best Use Case**

RSI Failure Swing Detector is best used when the trader wants a clean visual framework for RSI reversal structure without adding divergence complexity or broad pressure-state interpretation.

It can be useful for reviewing moments when RSI fails to retest its prior extreme and then confirms a momentum turn through its own internal swing level.

It is designed to organize one specific RSI pattern with cleaner confirmation, better visual hierarchy, and a focused chart workflow.

## Source Code

````pine
// -------------------------------------------------
// RSI Failure Swing Detector [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4.0
//
// RSI Failure Swing Detector maps the classic RSI failure swing sequence into
// a confirmed chart-facing reversal framework. It tracks oversold and
// overbought RSI swing stages, waits for the internal RSI break that confirms
// the pattern, then projects a clean trigger pocket on price with centered
// pocket labels, controlled stage markers, trigger scoring, sub-4H visual
// cleanup and a compact AG Pro panel for RSI failure swing analysis. Version
// 1.4.0 gives every trigger pocket one centered identity badge, removes repeated
// trigger/pocket narration, pairs pocket and badge cleanup, and restores the
// final setup stage as meaningful pre-confirmation context.
// -------------------------------------------------

//@version=6
indicator("RSI Failure Swing Detector [AGPro Series]",
     shorttitle       = "AG Pro RFS",
     overlay          = true,
     max_labels_count = 100,
     max_boxes_count  = 30)

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
rsiGroup = "RSI Failure Swing Engine"
visualGroup = "Chart Visuals"
panelGroup = "Panel"
proofGroup = "Proof"
alertGroup = "Alerts"

enginePreset = input.string("Swing / 4H", "Engine Preset", options = ["Swing / 4H", "Daily Selective", "Custom"], group = rsiGroup,
     tooltip = "Selects the default behavior profile. Swing / 4H balances clarity and event frequency. Daily Selective is cleaner and more selective. Custom uses the raw inputs below.")

rsiLength = input.int(14, "RSI Length", minval = 2, group = rsiGroup,
     tooltip = "Controls the RSI period used to build the failure swing sequence. A standard 14-period RSI keeps the model close to the classic interpretation.")

rsiSource = input.source(close, "RSI Source", group = rsiGroup,
     tooltip = "Selects the price source used by the RSI calculation. Close is the classic default and keeps the sequence stable across symbols.")

oversoldLevel = input.float(30.0, "Oversold Level", minval = 1.0, maxval = 49.0, step = 0.5, group = rsiGroup,
     tooltip = "Defines the lower RSI threshold used to start a bullish failure swing sequence.")

overboughtLevel = input.float(70.0, "Overbought Level", minval = 51.0, maxval = 99.0, step = 0.5, group = rsiGroup,
     tooltip = "Defines the upper RSI threshold used to start a bearish failure swing sequence.")

minRsiSeparation = input.float(4.0, "Minimum RSI Separation", minval = 0.5, maxval = 25.0, step = 0.5, group = rsiGroup,
     tooltip = "Requires the pullback leg to stay meaningfully separated from the original RSI extreme. Higher values make failure swing confirmation more selective.")

minPullback = input.float(3.0, "Minimum RSI Pullback", minval = 0.5, maxval = 25.0, step = 0.5, group = rsiGroup,
     tooltip = "Defines how much RSI must retrace after the first recovery or reaction leg before a valid third stage can form.")

maxSequenceBars = input.int(80, "Maximum Sequence Bars", minval = 10, maxval = 300, group = rsiGroup,
     tooltip = "Limits how long an unfinished failure swing sequence can remain active before it expires.")

confirmOnClose = input.bool(true, "Confirm On Bar Close", group = rsiGroup,
     tooltip = "When enabled, failure swing triggers are confirmed only after the current bar closes. This is the preferred public-release setting for stable historical behavior.")

stageLabelMode = input.string("Stage 3 Only", "Stage Label Detail", options = ["Off", "Stage 3 Only", "All Stages"], group = visualGroup,
     tooltip = "Controls sequence-stage badges. Stage 3 Only is the balanced default and identifies the final higher-low or lower-high setup before confirmation without printing every internal step.")

showTriggerLabels = input.bool(true, "Show Confirmed Trigger Labels", group = visualGroup,
     tooltip = "Shows a standalone confirmed-trigger badge when a labeled trigger pocket is not available. When the pocket identity badge is visible, duplicate trigger narration is automatically suppressed.")

showTriggerPockets = input.bool(true, "Show Trigger Pockets", group = visualGroup,
     tooltip = "Projects a time-limited price pocket from confirmed failure swing triggers. The pocket is context for retest behavior, not a generic support or resistance zone.")

showPocketLabels = input.bool(true, "Show Pocket Labels", group = visualGroup,
     tooltip = "Places one filled identity badge at the exact horizontal and vertical center of each confirmed trigger pocket.")

showSignalBarColor = input.bool(true, "Highlight Confirmed Trigger Bars", group = visualGroup,
     tooltip = "Applies a subtle candle tint only on confirmed trigger bars so the primary event remains easy to locate.")

lowTfCleanMode = input.bool(true, "Auto Clean Sub-4H View", group = visualGroup,
     tooltip = "Automatically reduces stage labels and retained pocket history below 4H so lower-timeframe charts stay readable. Core failure swing confirmation remains active.")

atrLength = input.int(14, "ATR Length", minval = 1, group = visualGroup,
     tooltip = "Controls the ATR baseline used for label offsets and trigger pocket depth.")

labelOffsetAtr = input.float(0.75, "Label Offset ATR", minval = 0.05, maxval = 3.0, step = 0.05, group = visualGroup,
     tooltip = "Offsets labels away from candle bodies so stage and trigger labels do not get buried inside price bars.")

pocketDepthAtr = input.float(0.85, "Pocket Depth ATR", minval = 0.10, maxval = 4.0, step = 0.05, group = visualGroup,
     tooltip = "Defines the vertical depth of each trigger pocket as a multiple of ATR.")

pocketBars = input.int(34, "Pocket Projection Bars", minval = 5, maxval = 150, group = visualGroup,
     tooltip = "Controls how far confirmed trigger pockets extend to the right of the confirmation bar.")

signalCooldownBars = input.int(28, "Confirmed Trigger Cooldown", minval = 0, maxval = 200, group = visualGroup,
     tooltip = "Prevents repeated confirmed trigger labels from clustering too tightly during choppy RSI conditions. Higher values keep the chart cleaner and more premium.")

stageLabelCooldown = input.int(18, "Stage Label Cooldown", minval = 0, maxval = 100, group = visualGroup,
     tooltip = "Controls the minimum spacing between stage labels so the chart keeps a premium, readable appearance.")

maxEventLabels = input.int(14, "Maximum Visible Labels", minval = 5, maxval = 60, group = visualGroup,
     tooltip = "Caps retained labels to keep the chart light, premium, and responsive.")

maxPockets = input.int(8, "Maximum Visible Pockets", minval = 1, maxval = 24, group = visualGroup,
     tooltip = "Caps retained trigger pockets to avoid unnecessary drawing load.")

labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = visualGroup,
     tooltip = "Controls every visible chart badge, including setup, standalone confirmation, and centered pocket identity badges. Normal is the publication default.")

bullPocketColor = input.color(color.rgb(34, 197, 166), "Bull Pocket Color", group = visualGroup,
     tooltip = "Color used for bullish RSI failure swing trigger pockets.")

bearPocketColor = input.color(color.rgb(244, 114, 182), "Bear Pocket Color", group = visualGroup,
     tooltip = "Color used for bearish RSI failure swing trigger pockets.")

showPanel = input.bool(true, "Show Panel", group = panelGroup,
     tooltip = "Shows the compact AG Pro status panel with RSI state, swing stage, confirmation, score and best-view guidance.")

panelLocation = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = panelGroup,
     tooltip = "Controls where the AG Pro status panel is displayed on the chart.")

panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = panelGroup,
     tooltip = "Selects the panel color theme while preserving the AGPro blue header row.")

panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = panelGroup,
     tooltip = "Controls panel text size. Normal is the recommended default for clean publication layouts.")

panelSignalMemoryBars = input.int(60, "Panel Signal Memory Bars", minval = 5, maxval = 300, group = panelGroup,
     tooltip = "Controls how long a confirmed trigger remains shown as recent in the panel.")

showProof = input.bool(true, "Show Proof Layer", group = proofGroup,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across confirmed RSI failure swing triggers on the current symbol and timeframe. Follow means price reversed one risk unit (1R, the trigger pocket depth) in the trigger direction before the trigger pocket was broken against it. These are historical outcome rates, not predictions.")

proofHorizonBars = input.int(30, "Proof Horizon Bars", minval = 5, maxval = 240, group = proofGroup,
     tooltip = "Maximum number of bars each confirmed trigger is tracked for the proof measurement before it resolves at its current outcome.")

reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = proofGroup,
     tooltip = "Number of bars after a trigger confirms used to detect an immediate favorable reversal reaction.")

reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = proofGroup,
     tooltip = "Minimum favorable reversal progress toward the 1R target, within the reaction window, required to count as an early React.")

alertBullConfirm = input.bool(true, "Alert on Bullish Confirmation", group = alertGroup,
     tooltip = "Enables alerts when a bullish RSI failure swing confirms.")

alertBearConfirm = input.bool(true, "Alert on Bearish Confirmation", group = alertGroup,
     tooltip = "Enables alerts when a bearish RSI failure swing confirms.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_pos(locationText) =>
    switch locationText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.top_right

f_text_on(_bg) =>
    brightness = color.r(_bg) + color.g(_bg) + color.b(_bg)
    brightness >= 360 ? color.rgb(15, 23, 42) : color.white

f_state_on_panel(_isLight, _state) =>
    if _isLight
        _state == bullColor ? color.rgb(13, 118, 99) : _state == bearColor ? color.rgb(178, 44, 112) : _state == neutralColor ? color.rgb(133, 77, 14) : _state == accentColor ? color.rgb(67, 56, 202) : _state
    else
        _state

f_panel_bg(isLight, alt) =>
    isLight ? (alt ? color.rgb(226, 232, 240) : panelBgL) : (alt ? color.rgb(30, 41, 59) : panelBgD)

f_pct(value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_score(separation, thrust, durationBars, closeQuality) =>
    separationScore = f_clamp(separation / math.max(minRsiSeparation * 2.5, 1.0) * 34.0, 0.0, 34.0)
    thrustScore = f_clamp(thrust / math.max(minPullback * 2.0, 1.0) * 28.0, 0.0, 28.0)
    timingScore = durationBars >= 4 and durationBars <= maxSequenceBars ? 18.0 : 8.0
    closeScore = f_clamp(closeQuality * 20.0, 0.0, 20.0)
    int(math.round(separationScore + thrustScore + timingScore + closeScore))

f_bull_stage_text(stage) =>
    switch stage
        1 => "Bull S1 - RSI washout"
        2 => "Bull S2 - recovery high"
        3 => "Bull S3 - higher RSI low"
        => "No bullish sequence"

f_bear_stage_text(stage) =>
    switch stage
        1 => "Bear S1 - RSI thrust"
        2 => "Bear S2 - reaction low"
        3 => "Bear S3 - lower RSI high"
        => "No bearish sequence"

f_add_label(array<label> store, int xValue, float yValue, string labelText, string labelStyle, color labelColor, color textColor, int limit, label_size) =>
    newLabel = label.new(x = xValue, y = yValue, text = labelText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = labelStyle,
         color = labelColor,
         textcolor = textColor,
         size = label_size,
         textalign = text.align_center)
    array.push(store, newLabel)
    while array.size(store) > limit
        oldLabel = array.shift(store)
        if not na(oldLabel)
            label.delete(oldLabel)

f_add_pocket(array<box> boxStore, array<label> labelStore, int leftValue, int rightValue, float topValue, float bottomValue, color pocketColor, color borderColor, color textColor, string pocketText, bool showLabel, int limit, label_size) =>
    newPocket = box.new(left = leftValue, top = topValue, right = rightValue, bottom = bottomValue,
         xloc = xloc.bar_index,
         bgcolor = pocketColor,
         border_color = borderColor,
         border_width = 1)
    array.push(boxStore, newPocket)
    label zoneLabel = na
    if showLabel
        badgeX = int(math.round((leftValue + rightValue) * 0.5))
        centerY = (topValue + bottomValue) * 0.5
        zoneLabel := label.new(badgeX, centerY, pocketText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_center,
             color = color.new(borderColor, 0),
             textcolor = textColor,
             size = label_size,
             textalign = text.align_center)
    array.push(labelStore, zoneLabel)
    while array.size(boxStore) > limit
        oldPocket = array.shift(boxStore)
        oldZoneLabel = array.shift(labelStore)
        if not na(oldPocket)
            box.delete(oldPocket)
        if not na(oldZoneLabel)
            label.delete(oldZoneLabel)

// -------------------------------------------------
// Preset Resolution
// -------------------------------------------------
dailyPreset = enginePreset == "Daily Selective"
usedMinRsiSeparation = dailyPreset ? math.max(minRsiSeparation, 5.0) : minRsiSeparation
usedMinPullback = dailyPreset ? math.max(minPullback, 4.0) : minPullback
usedStageLabelMode = dailyPreset ? "Stage 3 Only" : stageLabelMode
chartSeconds = timeframe.in_seconds(timeframe.period)
belowBestView = timeframe.isintraday and not na(chartSeconds) and chartSeconds < 14400
cleanLowTf = lowTfCleanMode and belowBestView
showStageLabelsEff = not cleanLowTf
usedMaxLabels = cleanLowTf ? math.min(maxEventLabels, 14) : dailyPreset ? math.min(maxEventLabels, 20) : maxEventLabels
usedMaxPockets = cleanLowTf ? math.min(maxPockets, 5) : dailyPreset ? math.min(maxPockets, 8) : maxPockets
bestViewText = cleanLowTf ? "Use 4H / 1D" : dailyPreset ? "1D chart" : "4H / 1D"

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
labelTextSize = f_size(labelFontInput)
panelTextSize = f_size(panelFontInput)
rsiValue = ta.rsi(rsiSource, rsiLength)
atrValue = ta.atr(atrLength)
atrSafe = math.max(nz(atrValue, 0.0), syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
closeLocation = (close - low) / barRange
confirmedBar = not confirmOnClose or barstate.isconfirmed

var array<label> eventLabels = array.new<label>()
var array<label> pocketLabels = array.new<label>()
var array<box> triggerPockets = array.new<box>()

var int bullStage = 0
var float bullBaseLow = na
var float bullBasePrice = na
var int bullBaseBar = na
var float bullBreakLevel = na
var int bullBreakBar = na
var float bullPullbackLow = na
var float bullPullbackPrice = na

var int bearStage = 0
var float bearBaseHigh = na
var float bearBasePrice = na
var int bearBaseBar = na
var float bearBreakLevel = na
var int bearBreakBar = na
var float bearPullbackHigh = na
var float bearPullbackPrice = na

var int lastSignalBar = na
var int lastStageLabelBar = na
var string lastSignalSide = "None"
var int lastSignalScore = na

crossOverOversold = ta.crossover(rsiValue, oversoldLevel)
crossUnderOverbought = ta.crossunder(rsiValue, overboughtLevel)
crossOverBullBreakRaw = ta.crossover(rsiValue, bullBreakLevel)
crossUnderBearBreakRaw = ta.crossunder(rsiValue, bearBreakLevel)
crossOverBullBreak = not na(bullBreakLevel) and crossOverBullBreakRaw
crossUnderBearBreak = not na(bearBreakLevel) and crossUnderBearBreakRaw

bool bullConfirmed = false
bool bearConfirmed = false
bool bullStageEvent = false
bool bearStageEvent = false
bool bullStageKeyEvent = false
bool bearStageKeyEvent = false
string bullStageEventText = ""
string bearStageEventText = ""
float bullStageLabelY = na
float bearStageLabelY = na

// -------------------------------------------------
// Sequence Expiration
// -------------------------------------------------
if bullStage > 0 and not na(bullBaseBar) and bar_index - bullBaseBar > maxSequenceBars
    bullStage := 0
    bullBaseLow := na
    bullBasePrice := na
    bullBaseBar := na
    bullBreakLevel := na
    bullBreakBar := na
    bullPullbackLow := na
    bullPullbackPrice := na

if bearStage > 0 and not na(bearBaseBar) and bar_index - bearBaseBar > maxSequenceBars
    bearStage := 0
    bearBaseHigh := na
    bearBasePrice := na
    bearBaseBar := na
    bearBreakLevel := na
    bearBreakBar := na
    bearPullbackHigh := na
    bearPullbackPrice := na

// -------------------------------------------------
// Bullish Failure Swing Sequence
// -------------------------------------------------
if rsiValue < oversoldLevel
    if bullStage == 0 or rsiValue < nz(bullBaseLow, rsiValue)
        bullStage := 1
        bullBaseLow := rsiValue
        bullBasePrice := low
        bullBaseBar := bar_index
        bullBreakLevel := na
        bullBreakBar := na
        bullPullbackLow := na
        bullPullbackPrice := na
        bullStageEvent := true
        bullStageEventText := "BULL EXTREME\nRSI washout"
        bullStageLabelY := low - atrSafe * labelOffsetAtr

if bullStage == 1
    if rsiValue < nz(bullBaseLow, rsiValue)
        bullBaseLow := rsiValue
        bullBasePrice := low
        bullBaseBar := bar_index
    if crossOverOversold
        bullStage := 2
        bullBreakLevel := rsiValue
        bullBreakBar := bar_index
        bullStageEvent := true
        bullStageEventText := "BULL RECOVERY\nInternal high"
        bullStageLabelY := low - atrSafe * labelOffsetAtr

if bullStage == 2
    bullBreakLevel := math.max(nz(bullBreakLevel, rsiValue), rsiValue)
    if rsiValue <= nz(bullBaseLow, rsiValue) + usedMinRsiSeparation
        if rsiValue < oversoldLevel
            bullStage := 1
            bullBaseLow := rsiValue
            bullBasePrice := low
            bullBaseBar := bar_index
            bullBreakLevel := na
            bullBreakBar := na
            bullPullbackLow := na
            bullPullbackPrice := na
    else if bullBreakLevel - rsiValue >= usedMinPullback
        bullStage := 3
        bullPullbackLow := rsiValue
        bullPullbackPrice := low
        bullStageEvent := true
        bullStageEventText := "BULL SETUP\nHigher RSI low"
        bullStageKeyEvent := true
        bullStageLabelY := low - atrSafe * labelOffsetAtr

if bullStage == 3
    if rsiValue < nz(bullPullbackLow, rsiValue)
        bullPullbackLow := rsiValue
        bullPullbackPrice := low
    if rsiValue <= nz(bullBaseLow, rsiValue) + usedMinRsiSeparation
        if rsiValue < oversoldLevel
            bullStage := 1
            bullBaseLow := rsiValue
            bullBasePrice := low
            bullBaseBar := bar_index
            bullBreakLevel := na
            bullBreakBar := na
            bullPullbackLow := na
            bullPullbackPrice := na
    else
        canBullSignal = na(lastSignalBar) or bar_index - lastSignalBar >= signalCooldownBars
        if confirmedBar and canBullSignal and crossOverBullBreak
            bullSeparation = bullPullbackLow - bullBaseLow
            bullThrust = rsiValue - bullBreakLevel
            bullDuration = bar_index - nz(bullBaseBar, bar_index)
            bullScore = f_score(bullSeparation, bullThrust, bullDuration, closeLocation)
            bullConfirmed := true
            lastSignalBar := bar_index
            lastSignalSide := "Bullish"
            lastSignalScore := bullScore
            if showTriggerLabels and not (showTriggerPockets and showPocketLabels)
                f_add_label(eventLabels, bar_index, low - atrSafe * labelOffsetAtr, "BULL RFS CONFIRMED\nQ " + str.tostring(bullScore), label.style_label_up, color.new(bullColor, 0), f_text_on(bullColor), usedMaxLabels, labelTextSize)
            if showTriggerPockets
                bullPocketTop = close
                bullPocketBottom = close - atrSafe * pocketDepthAtr
                pocketText = "BULL RFS POCKET\nQ " + str.tostring(bullScore)
                f_add_pocket(triggerPockets, pocketLabels, bar_index, bar_index + pocketBars, bullPocketTop, bullPocketBottom, color.new(bullPocketColor, 82), color.new(bullPocketColor, 20), f_text_on(bullPocketColor), pocketText, showPocketLabels, usedMaxPockets, labelTextSize)
            bullStage := 0
            bullBaseLow := na
            bullBasePrice := na
            bullBaseBar := na
            bullBreakLevel := na
            bullBreakBar := na
            bullPullbackLow := na
            bullPullbackPrice := na

// -------------------------------------------------
// Bearish Failure Swing Sequence
// -------------------------------------------------
if rsiValue > overboughtLevel
    if bearStage == 0 or rsiValue > nz(bearBaseHigh, rsiValue)
        bearStage := 1
        bearBaseHigh := rsiValue
        bearBasePrice := high
        bearBaseBar := bar_index
        bearBreakLevel := na
        bearBreakBar := na
        bearPullbackHigh := na
        bearPullbackPrice := na
        bearStageEvent := true
        bearStageEventText := "BEAR EXTREME\nRSI thrust"
        bearStageLabelY := high + atrSafe * labelOffsetAtr

if bearStage == 1
    if rsiValue > nz(bearBaseHigh, rsiValue)
        bearBaseHigh := rsiValue
        bearBasePrice := high
        bearBaseBar := bar_index
    if crossUnderOverbought
        bearStage := 2
        bearBreakLevel := rsiValue
        bearBreakBar := bar_index
        bearStageEvent := true
        bearStageEventText := "BEAR REACTION\nInternal low"
        bearStageLabelY := high + atrSafe * labelOffsetAtr

if bearStage == 2
    bearBreakLevel := math.min(nz(bearBreakLevel, rsiValue), rsiValue)
    if rsiValue >= nz(bearBaseHigh, rsiValue) - usedMinRsiSeparation
        if rsiValue > overboughtLevel
            bearStage := 1
            bearBaseHigh := rsiValue
            bearBasePrice := high
            bearBaseBar := bar_index
            bearBreakLevel := na
            bearBreakBar := na
            bearPullbackHigh := na
            bearPullbackPrice := na
    else if rsiValue - bearBreakLevel >= usedMinPullback
        bearStage := 3
        bearPullbackHigh := rsiValue
        bearPullbackPrice := high
        bearStageEvent := true
        bearStageEventText := "BEAR SETUP\nLower RSI high"
        bearStageKeyEvent := true
        bearStageLabelY := high + atrSafe * labelOffsetAtr

if bearStage == 3
    if rsiValue > nz(bearPullbackHigh, rsiValue)
        bearPullbackHigh := rsiValue
        bearPullbackPrice := high
    if rsiValue >= nz(bearBaseHigh, rsiValue) - usedMinRsiSeparation
        if rsiValue > overboughtLevel
            bearStage := 1
            bearBaseHigh := rsiValue
            bearBasePrice := high
            bearBaseBar := bar_index
            bearBreakLevel := na
            bearBreakBar := na
            bearPullbackHigh := na
            bearPullbackPrice := na
    else
        canBearSignal = na(lastSignalBar) or bar_index - lastSignalBar >= signalCooldownBars
        if confirmedBar and canBearSignal and crossUnderBearBreak
            bearSeparation = bearBaseHigh - bearPullbackHigh
            bearThrust = bearBreakLevel - rsiValue
            bearDuration = bar_index - nz(bearBaseBar, bar_index)
            bearScore = f_score(bearSeparation, bearThrust, bearDuration, 1.0 - closeLocation)
            bearConfirmed := true
            lastSignalBar := bar_index
            lastSignalSide := "Bearish"
            lastSignalScore := bearScore
            if showTriggerLabels and not (showTriggerPockets and showPocketLabels)
                f_add_label(eventLabels, bar_index, high + atrSafe * labelOffsetAtr, "BEAR RFS CONFIRMED\nQ " + str.tostring(bearScore), label.style_label_down, color.new(bearColor, 0), f_text_on(bearColor), usedMaxLabels, labelTextSize)
            if showTriggerPockets
                bearPocketTop = close + atrSafe * pocketDepthAtr
                bearPocketBottom = close
                pocketText = "BEAR RFS POCKET\nQ " + str.tostring(bearScore)
                f_add_pocket(triggerPockets, pocketLabels, bar_index, bar_index + pocketBars, bearPocketTop, bearPocketBottom, color.new(bearPocketColor, 82), color.new(bearPocketColor, 20), f_text_on(bearPocketColor), pocketText, showPocketLabels, usedMaxPockets, labelTextSize)
            bearStage := 0
            bearBaseHigh := na
            bearBasePrice := na
            bearBaseBar := na
            bearBreakLevel := na
            bearBreakBar := na
            bearPullbackHigh := na
            bearPullbackPrice := na

// -------------------------------------------------
// Confirmation-anchored proof (confirmed triggers, Follow = reversed 1R before pocket broke)
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

bool anchorTrigger = bullConfirmed or bearConfirmed
int proofWarmup = rsiLength + atrLength + 5
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
        if naturalResolve or anchorTrigger
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
    if anchorTrigger and not pEvalActive
        pEvalActive := true
        pEvalDir := bullConfirmed ? 1 : -1
        pEvalEntry := close
        float pRiskDist = math.max(atrSafe * pocketDepthAtr, syminfo.mintick)
        pEvalStop := close - pEvalDir * pRiskDist
        pEvalTarget := close + pEvalDir * pRiskDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false
        pFlipped := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Stage Labels and Bar Color
// -------------------------------------------------
canStageLabel = na(lastStageLabelBar) or bar_index - lastStageLabelBar >= stageLabelCooldown
allowBullStageLabel = usedStageLabelMode == "All Stages" or (usedStageLabelMode == "Stage 3 Only" and bullStageKeyEvent)
if showStageLabelsEff and usedStageLabelMode != "Off" and canStageLabel and allowBullStageLabel and bullStageEvent and not na(bullStageLabelY)
    f_add_label(eventLabels, bar_index, bullStageLabelY, bullStageEventText, label.style_label_up, color.new(bullColor, 36), f_text_on(color.new(bullColor, 36)), usedMaxLabels, labelTextSize)
    lastStageLabelBar := bar_index

canStageLabel := na(lastStageLabelBar) or bar_index - lastStageLabelBar >= stageLabelCooldown
allowBearStageLabel = usedStageLabelMode == "All Stages" or (usedStageLabelMode == "Stage 3 Only" and bearStageKeyEvent)
if showStageLabelsEff and usedStageLabelMode != "Off" and canStageLabel and allowBearStageLabel and bearStageEvent and not na(bearStageLabelY)
    f_add_label(eventLabels, bar_index, bearStageLabelY, bearStageEventText, label.style_label_down, color.new(bearColor, 36), f_text_on(color.new(bearColor, 36)), usedMaxLabels, labelTextSize)
    lastStageLabelBar := bar_index

signalBarColor = bullConfirmed ? color.new(bullColor, 0) : bearConfirmed ? color.new(bearColor, 0) : na
barcolor(showSignalBarColor ? signalBarColor : na)

// -------------------------------------------------
// Panel
// -------------------------------------------------
isLightPanel = panelTheme == "Light"
activePanelBg = f_panel_bg(isLightPanel, false)
activePanelAltBg = f_panel_bg(isLightPanel, true)
activePanelBorder = isLightPanel ? panelBorderL : panelBorderD
activePanelLabel = isLightPanel ? panelLabelL : panelLabelD
activePanelValue = isLightPanel ? panelValueL : panelValueD

rsiState = "Neutral"
rsiStateColor = neutralColor
if rsiValue <= oversoldLevel
    rsiState := "Oversold"
    rsiStateColor := bullColor
else if rsiValue >= overboughtLevel
    rsiState := "Overbought"
    rsiStateColor := bearColor
else if rsiValue > 50.0
    rsiState := "Upper Half"
    rsiStateColor := accentColor
else
    rsiState := "Lower Half"
    rsiStateColor := neutralColor

activeStageText = "Waiting"
if bullStage > 0 and (bearStage == 0 or nz(bullBaseBar, 0) >= nz(bearBaseBar, 0))
    activeStageText := f_bull_stage_text(bullStage)
else if bearStage > 0
    activeStageText := f_bear_stage_text(bearStage)

int barsFromSignal = na(lastSignalBar) ? na : bar_index - lastSignalBar
bool hasRecentSignal = not na(barsFromSignal) and barsFromSignal <= panelSignalMemoryBars
string confirmationText = hasRecentSignal ? lastSignalSide + " / " + str.tostring(barsFromSignal) + " bars ago" : "No confirmed trigger"
color confirmationColor = hasRecentSignal ? (lastSignalSide == "Bullish" ? bullColor : bearColor) : activePanelValue
string scoreText = hasRecentSignal and not na(lastSignalScore) ? str.tostring(lastSignalScore) + " / 100" : "Waiting"
string pocketTextPanel = "Hidden"
if showTriggerPockets
    pocketTextPanel := hasRecentSignal and not na(lastSignalScore) ? (lastSignalSide == "Bullish" ? "Bull Pocket / Q " : "Bear Pocket / Q ") + str.tostring(lastSignalScore) : "Awaiting trigger"

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "-"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "-"
color followColPanel = proofTotal > 0 ? f_rate_color(followRate) : activePanelValue
color holdColPanel = proofTotal > 0 ? f_rate_color(holdRate) : activePanelValue
color reactColPanel = proofTotal > 0 ? f_rate_color(reactRate) : activePanelValue
color flipColPanel = proofTotal > 0 ? f_flip_color(flipRate) : activePanelValue

int panelRowCount = showProof ? 12 : 7
var table statusPanel = na
var string prevPanelLocation = ""
var string prevPanelTheme = ""
var bool prevProofMode = false

panelNeedsRebuild = showPanel and (na(statusPanel) or prevPanelLocation != panelLocation or prevPanelTheme != panelTheme or prevProofMode != showProof)
if panelNeedsRebuild
    if not na(statusPanel)
        table.delete(statusPanel)
    statusPanel := table.new(f_pos(panelLocation), 2, panelRowCount,
         bgcolor = activePanelBg,
         frame_color = activePanelBorder,
         frame_width = 1,
         border_color = activePanelBorder,
         border_width = 1)
    table.cell(statusPanel, 0, 0, "AG Pro RSI Failure Swing Detector", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(statusPanel, 1, 0, "", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize)
    table.merge_cells(statusPanel, 0, 0, 1, 0)
    prevPanelLocation := panelLocation
    prevPanelTheme := panelTheme
    prevProofMode := showProof

if not showPanel and not na(statusPanel)
    table.delete(statusPanel)
    statusPanel := na
    prevPanelLocation := ""
    prevPanelTheme := ""

if showPanel and not na(statusPanel) and barstate.islast
    table.set_position(statusPanel, f_pos(panelLocation))
    table.clear(statusPanel, 0, 1, 1, panelRowCount - 1)
    table.cell(statusPanel, 0, 0, "AG Pro RSI Failure Swing Detector", bgcolor = headerBg, text_color = headerText, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(statusPanel, 0, 1, "RSI State", bgcolor = activePanelBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(statusPanel, 1, 1, rsiState + " " + str.tostring(rsiValue, "#.0"), bgcolor = activePanelBg, text_color = f_state_on_panel(isLightPanel, rsiStateColor), text_size = panelTextSize, text_halign = text.align_right)
    table.cell(statusPanel, 0, 2, "Swing Stage", bgcolor = activePanelAltBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(statusPanel, 1, 2, activeStageText, bgcolor = activePanelAltBg, text_color = activePanelValue, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(statusPanel, 0, 3, "Confirmation", bgcolor = activePanelBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(statusPanel, 1, 3, confirmationText, bgcolor = activePanelBg, text_color = f_state_on_panel(isLightPanel, confirmationColor), text_size = panelTextSize, text_halign = text.align_right)
    table.cell(statusPanel, 0, 4, "Score", bgcolor = activePanelAltBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(statusPanel, 1, 4, scoreText, bgcolor = activePanelAltBg, text_color = activePanelValue, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(statusPanel, 0, 5, "Pocket", bgcolor = activePanelBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(statusPanel, 1, 5, pocketTextPanel, bgcolor = activePanelBg, text_color = showTriggerPockets ? f_state_on_panel(isLightPanel, accentColor) : activePanelValue, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(statusPanel, 0, 6, "Best View", bgcolor = activePanelAltBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(statusPanel, 1, 6, bestViewText, bgcolor = activePanelAltBg, text_color = f_state_on_panel(isLightPanel, accentColor), text_size = panelTextSize, text_halign = text.align_right)
    if showProof
        table.cell(statusPanel, 0, 7, "Proof @ Confirm", bgcolor = activePanelBg, text_color = f_state_on_panel(isLightPanel, accentColor), text_size = panelTextSize, text_halign = text.align_left)
        table.cell(statusPanel, 1, 7, proofSampleText, bgcolor = activePanelBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_right)
        table.cell(statusPanel, 0, 8, "Follow Rate", bgcolor = activePanelAltBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(statusPanel, 1, 8, followTextPanel, bgcolor = activePanelAltBg, text_color = f_state_on_panel(isLightPanel, followColPanel), text_size = panelTextSize, text_halign = text.align_right)
        table.cell(statusPanel, 0, 9, "Hold Rate", bgcolor = activePanelBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(statusPanel, 1, 9, holdTextPanel, bgcolor = activePanelBg, text_color = f_state_on_panel(isLightPanel, holdColPanel), text_size = panelTextSize, text_halign = text.align_right)
        table.cell(statusPanel, 0, 10, "React Rate", bgcolor = activePanelAltBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(statusPanel, 1, 10, reactTextPanel, bgcolor = activePanelAltBg, text_color = f_state_on_panel(isLightPanel, reactColPanel), text_size = panelTextSize, text_halign = text.align_right)
        table.cell(statusPanel, 0, 11, "Flip Rate", bgcolor = activePanelBg, text_color = activePanelLabel, text_size = panelTextSize, text_halign = text.align_left)
        table.cell(statusPanel, 1, 11, flipTextPanel, bgcolor = activePanelBg, text_color = f_state_on_panel(isLightPanel, flipColPanel), text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts and Hidden Exports
// -------------------------------------------------
alertcondition(alertBullConfirm and bullConfirmed, title = "Bullish RSI Failure Swing Confirmed", message = "RSI Failure Swing Detector: Bullish failure swing confirmed.")
alertcondition(alertBearConfirm and bearConfirmed, title = "Bearish RSI Failure Swing Confirmed", message = "RSI Failure Swing Detector: Bearish failure swing confirmed.")
alertcondition((alertBullConfirm and bullConfirmed) or (alertBearConfirm and bearConfirmed), title = "Any RSI Failure Swing Confirmed", message = "RSI Failure Swing Detector: A confirmed RSI failure swing trigger is active.")

plot(rsiValue, "RSI Value", display = display.none)
plot(lastSignalScore, "Last Failure Swing Score", display = display.none)
plot(followRate, "RFS Follow Rate", display = display.none)
plot(holdRate, "RFS Hold Rate", display = display.none)
plot(reactRate, "RFS React Rate", display = display.none)
plot(flipRate, "RFS Flip Rate", display = display.none)
````
