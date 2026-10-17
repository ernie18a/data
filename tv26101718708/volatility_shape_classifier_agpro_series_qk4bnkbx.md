# Volatility Shape Classifier [AGPro Series]

- url: https://www.tradingview.com/script/qK4BNkBx-Volatility-Shape-Classifier-AGPro-Series/
- type: indicator
- pine_id: PUB;3c1a03b1b53843a18a93aa7258dcd662
- version: 8.0

## Description

Volatility Shape Classifier [AGPro Series]

🔹 Overview

Volatility Shape Classifier is a context and diagnostics tool that does not stop at telling you whether volatility is high or low. Instead it classifies the SHAPE of that volatility on every bar — Smooth, Chaotic, Choppy, Drift, or Dead — using three independent dimensions combined into a single regime read. The result is a continuous visual narrative made of a subtle background tint, throttled transition badges, and a compact metrics panel.

It is designed to sit on your chart as a pure awareness layer. It does not generate buy or sell signals and it is not a trading strategy.


🔷 Unique Edge

Most volatility tools compress the market into one axis — high vs low (ATR, Bollinger Band Width), or trend vs range (Choppiness Index, ADX). They answer half of the question.

This script asks three questions at once and fuses the answers:

  1. Magnitude — is ATR above or below its own long baseline?
  2. Smoothness — are bar-to-bar moves consistent in size, or erratic?
  3. Directional Consistency — do bars point the same way, or cancel each other?

Only the combination of these three can distinguish a controlled trend run (Smooth) from a violent whipsaw (Chaotic) from a wide directionless thrash (Choppy) — all three of which can show identical ATR readings. That shape distinction is the core value this script adds, and it is the gap left by standard volatility and chop indicators.


🔶 Methodology

Engine layer (per bar):
  • Volatility Level = ATR(volLen) / SMA(ATR, volLen * 3)
  • Smoothness = StDev(|close − close[1]|) / SMA(|close − close[1]|) over volLen
  • Direction = |sum(close − close[1])| / sum(|close − close[1]|) over volLen

Classification layer maps the three readings into six mutually exclusive codes:
  0 — Forming (warm-up / in-between space, no tint)
  1 — Expansion · Smooth   (high vol, low CV, directional)
  2 — Expansion · Chaotic  (high vol, high CV)
  3 — Expansion · Choppy   (high vol, low direction)
  4 — Low-Vol · Drift      (low vol, low CV, mild direction)
  5 — Low-Vol · Dead       (low vol, low CV, no direction)

Stability layer applies a configurable Confirmation Bars window so a new shape must persist for N consecutive bars before the chart commits to it. This prevents single-bar flicker. Between-state readings do not reset the current shape, they hold it — avoiding the classic "blink to neutral" problem of switch-based classifiers.


🔸 Signals & Alerts

Four alert conditions are published:
  • Shape Shifted to Smooth Expansion
  • Shape Shifted to Chaotic Expansion
  • Shape Shifted to Choppy Expansion
  • Shape Collapsed (any expansion state falling into low-vol Drift or Dead)

Alerts fire only on confirmed shape transitions and only on bar close, so repaint on the signal bar is not a concern.


🔹 Key Inputs

  • Volatility Length — window for ATR, smoothness, and direction (default 20)
  • Confirmation Bars — persistence requirement before committing to a new shape (default 3)
  • Badge Cooldown — minimum bars between visible badges (default 15; tint updates continuously regardless)
  • Panel Position / Size — six anchor points, four size presets
  • Badge Font Size — four size presets


🔷 How to Use

  • Use the SHAPE read as a setup filter, not as the signal itself. Smooth Expansion is where trend-following tools tend to perform well. Chaotic and Choppy Expansion are where they tend to fail even when the raw volatility reading looks attractive.
  • The Drift state often precedes an expansion in the direction of the drift.
  • The Dead state is a compression warning — a shape collapse alert from Expansion into Dead is a common precursor to a fresh expansion move in either direction.
  • Pair with your own entry logic (structure, moving averages, volume). This tool answers "what kind of market am I in right now?" — it does not answer "where do I enter?"


🔶 Limitations & Transparency

  • Thresholds (1.15x / 0.70x / 0.80 / 1.10 / 0.18) were tuned on crypto and FX data across 15m to 1D timeframes. Very illiquid instruments and very low timeframes (< 5m) may require a longer Volatility Length.
  • Shape classification is inherently backward-looking (it reads the last volLen bars). It describes the character of recent volatility, not future volatility.
  • The script is a context layer. It is not a strategy and should not be used in isolation for trade decisions.
  • Past behavior of a shape does not guarantee future behavior.


🔸 Risk Disclosure

This indicator is an educational and analytical tool. It does not constitute financial advice, trade recommendations, or a signal service. All trading involves risk. You are solely responsible for your own trading decisions.

## Source Code

````pine
// -------------------------------------------------
// Volatility Shape Classifier [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.9
//
// Classifies the shape of volatility, not only its size. The engine combines
// ATR regime, bar-to-bar smoothness, and directional consistency to separate
// smooth expansion, chaotic expansion, choppy expansion, low-volatility drift,
// low-volatility dead zones, and forming conditions. This release adds a
// confirmation-anchored proof layer (React, Follow, Hold, Flip rates) that shows
// how stable and reliable past shape calls were on this symbol, while preserving
// the original classifier logic, ribbon, badges, and right-edge status card.
// -------------------------------------------------

//@version=6
indicator("Volatility Shape Classifier [AGPro Series]",
     shorttitle       = "AG Pro VSC",
     overlay          = true,
     max_labels_count = 140,
     max_lines_count  = 30,
     max_bars_back    = 1000)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
gEngine = "Engine"
volLen = input.int(20, "Volatility Length", minval = 5, maxval = 200, group = gEngine,
     tooltip = "Primary window for ATR regime, smoothness, and directional consistency. Shorter values react faster; longer values produce more active shape changes.")
classifierMode = input.string("Normal", "Classifier Mode", options = ["Responsive", "Normal", "Strict"], group = gEngine,
     tooltip = "Controls how easily volatility shapes are confirmed. Responsive reacts faster, Strict requires cleaner evidence, and Normal balances both.")
confirmBars = input.int(3, "Confirmation Bars", minval = 0, maxval = 10, group = gEngine,
     tooltip = "Number of consecutive bars a new raw volatility shape must persist before becoming the confirmed chart state.")
badgeCooldown = input.int(16, "Badge Cooldown (bars)", minval = 0, maxval = 100, group = gEngine,
     tooltip = "Minimum bars between transition badges. The live ribbon, panel, and right-side context tag still update continuously.")

gVisual = "Visuals"
showRibbon = input.bool(true, "Show Shape Ribbon", group = gVisual,
     tooltip = "Displays an ATR-scaled ribbon around an EMA backbone. The ribbon color reflects the confirmed volatility shape.")
ribbonLen = input.int(34, "Ribbon Backbone Length", minval = 5, maxval = 200, group = gVisual,
     tooltip = "EMA length used as the visual backbone for the volatility-shape ribbon.")
ribbonAtr = input.float(0.20, "Ribbon Height (ATR)", minval = 0.04, maxval = 0.80, step = 0.02, group = gVisual,
     tooltip = "Controls ribbon thickness relative to ATR. Slightly higher values make the volatility map easier to read in screenshots.")
showBackground = input.bool(true, "Show Background Tint", group = gVisual,
     tooltip = "Adds a subtle background tint to help recognize the active volatility shape at a glance.")
showBadges = input.bool(true, "Show Transition Badges", group = gVisual,
     tooltip = "Shows compact badges when confirmed volatility-shape transitions occur.")
showContextPulses = input.bool(true, "Show Context Pulses", group = gVisual,
     tooltip = "Adds small premium context markers on important expansion, noisy, and cooldown shifts without changing the analytical logic.")
showLiveTags = input.bool(true, "Show Right-Side Status Card", group = gVisual,
     tooltip = "Shows a single right-edge status card with workflow state, confirmed shape, quality score, ATR context, and duration.")
rightTagOffset = input.int(6, "Right Tag Offset", minval = 2, maxval = 20, group = gVisual,
     tooltip = "Controls how far the right-edge status card is placed from the latest candle.")
maxVisibleBadges = input.int(8, "Max Visible Badges", minval = 3, maxval = 30, group = gVisual,
     tooltip = "Maximum number of historical transition badges kept on the chart.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gVisual,
     tooltip = "Controls on-chart label font size for badges, context pulses, and the right-edge status card.")

gPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = gPanel,
     tooltip = "Shows the AGPro panel with volatility shape, workflow state, quality, ATR context, smoothness, direction, and duration.")
panelPosition = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel,
     tooltip = "Controls where the panel is anchored on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = gPanel,
     tooltip = "Switches panel colors for dark or light chart backgrounds.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel,
     tooltip = "Controls panel text size.")

gProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = gProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: React, Follow, Hold, and Flip rates measured across past confirmed shape calls on the current symbol and timeframe. These are classification-stability rates, not trade outcomes or predictions.")
reactBars = input.int(3, "Reaction Window (bars)", minval = 1, maxval = 30, group = gProof,
     tooltip = "Number of bars a new shape call must survive without flipping to count as an early React.")
proofHorizonBars = input.int(12, "Proof Horizon (bars)", minval = 4, maxval = 120, group = gProof,
     tooltip = "Number of bars each confirmed shape call is tracked forward to measure whether the exact shape held (Hold) and whether the volatility category followed through (Follow).")

gAlerts = "Alerts"
alertSmooth = input.bool(true, "Alert: Smooth Expansion", group = gAlerts,
     tooltip = "Creates an alert condition when the confirmed state changes into Smooth Expansion.")
alertChaotic = input.bool(true, "Alert: Chaotic Expansion", group = gAlerts,
     tooltip = "Creates an alert condition when the confirmed state changes into Chaotic Expansion.")
alertChoppy = input.bool(true, "Alert: Choppy Expansion", group = gAlerts,
     tooltip = "Creates an alert condition when the confirmed state changes into Choppy Expansion.")
alertLowVol = input.bool(true, "Alert: Low-Volatility Shape", group = gAlerts,
     tooltip = "Creates an alert condition when the confirmed state changes into Low-Vol Drift or Low-Vol Dead.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgLight  = color.rgb(248, 250, 252)
panelBorderD  = color.rgb(51, 65, 85)
panelBorderL  = color.rgb(203, 213, 225)
panelLabelD   = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueD   = color.rgb(226, 232, 240)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkText      = color.rgb(17, 24, 39)

isLightTheme = panelTheme == "Light"
panelBg = isLightTheme ? panelBgLight : panelBgDark
panelBorder = isLightTheme ? panelBorderL : panelBorderD
panelLabelCol = isLightTheme ? panelLabelL : panelLabelD
panelValueCol = isLightTheme ? panelValueL : panelValueD
panelAltBg = isLightTheme ? color.rgb(241, 245, 249) : color.rgb(24, 35, 55)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
SHAPE_FORMING = 0
SHAPE_SMOOTH = 1
SHAPE_CHAOTIC = 2
SHAPE_CHOPPY = 3
SHAPE_DRIFT = 4
SHAPE_DEAD = 5

f_size(string s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string p) =>
    switch p
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_pct(float v) =>
    str.tostring(int(math.round(v))) + "%"

f_rate_color(float v) =>
    v >= 55 ? bullColor : v >= 40 ? neutralColor : bearColor

f_flip_color(float v) =>
    v <= 30 ? bullColor : v <= 55 ? neutralColor : bearColor

f_shape_color(int s) =>
    switch s
        SHAPE_SMOOTH  => bullColor
        SHAPE_CHAOTIC => bearColor
        SHAPE_CHOPPY  => neutralColor
        SHAPE_DRIFT   => accentColor
        SHAPE_DEAD    => accentColor
        => panelBorder

f_shape_uses_direction(int s) =>
    s == SHAPE_SMOOTH or s == SHAPE_DRIFT

f_same_shape_call(int shapeA, bool upA, int shapeB, bool upB) =>
    shapeA == shapeB and (not f_shape_uses_direction(shapeA) or upA == upB)

f_shape_text_color(int s) =>
    s == SHAPE_CHOPPY ? darkText : headerText

f_shape_short(int s, bool up) =>
    dir = up ? " Up" : " Down"
    switch s
        SHAPE_SMOOTH  => "Smooth Exp" + dir
        SHAPE_CHAOTIC => "Chaotic Exp"
        SHAPE_CHOPPY  => "Choppy Exp"
        SHAPE_DRIFT   => "Low-Vol Drift" + dir
        SHAPE_DEAD    => "Low-Vol Dead"
        => "Forming"

f_shape_full(int s, bool up) =>
    dir = up ? " Up" : " Down"
    switch s
        SHAPE_SMOOTH  => "Smooth Expansion" + dir
        SHAPE_CHAOTIC => "Chaotic Expansion"
        SHAPE_CHOPPY  => "Choppy Expansion"
        SHAPE_DRIFT   => "Low-Vol Drift" + dir
        SHAPE_DEAD    => "Low-Vol Dead"
        => "Forming"

f_workflow_state(int s) =>
    switch s
        SHAPE_SMOOTH  => "Active"
        SHAPE_CHAOTIC => "Noisy"
        SHAPE_CHOPPY  => "Noisy"
        SHAPE_DRIFT   => "Cooldown"
        SHAPE_DEAD    => "Cooldown"
        => "Forming"

f_workflow_hint(int s) =>
    switch s
        SHAPE_SMOOTH  => "Clean Release"
        SHAPE_CHAOTIC => "Risky Speed"
        SHAPE_CHOPPY  => "Noisy Burst"
        SHAPE_DRIFT   => "Quiet Drift"
        SHAPE_DEAD    => "Dead Zone"
        => "Waiting"

f_workflow_color(int s) =>
    switch s
        SHAPE_SMOOTH  => bullColor
        SHAPE_CHAOTIC => bearColor
        SHAPE_CHOPPY  => neutralColor
        SHAPE_DRIFT   => accentColor
        SHAPE_DEAD    => accentColor
        => panelBorder

f_workflow_text_color(int s) =>
    s == SHAPE_CHOPPY ? darkText : headerText

panelSize = f_size(panelSizeInput)
labelSize = f_size(labelSizeInput)

// -------------------------------------------------
// Engine
// -------------------------------------------------
atrNow = math.max(nz(ta.atr(volLen), syminfo.mintick), syminfo.mintick)
atrBase = ta.sma(atrNow, volLen * 3)
volLevel = not na(atrBase) and atrBase > 0.0 ? atrNow / atrBase : 1.0

barMove = math.abs(close - nz(close[1], close))
moveMean = ta.sma(barMove, volLen)
moveStd = ta.stdev(barMove, volLen)
smoothness = not na(moveMean) and moveMean > 0.0 and not na(moveStd) ? moveStd / moveMean : 0.0

netMove = close - nz(close[volLen], close)
absMove = nz(math.sum(barMove, volLen), 0.0)
direction = absMove > 0.0 ? f_clamp(math.abs(netMove) / absMove, 0.0, 1.0) : 0.0
dirUp = netMove >= 0.0

volHigh = classifierMode == "Strict" ? 1.22 : classifierMode == "Responsive" ? 1.08 : 1.15
volLow = classifierMode == "Strict" ? 0.64 : classifierMode == "Responsive" ? 0.78 : 0.70
smoothMax = classifierMode == "Strict" ? 0.72 : classifierMode == "Responsive" ? 0.90 : 0.80
chaoticMin = classifierMode == "Strict" ? 1.18 : classifierMode == "Responsive" ? 1.02 : 1.10
driftMin = classifierMode == "Strict" ? 0.24 : classifierMode == "Responsive" ? 0.14 : 0.18
smoothDirMin = classifierMode == "Strict" ? 0.18 : classifierMode == "Responsive" ? 0.10 : 0.126

historyReady = bar_index >= volLen * 4

rawShape = SHAPE_FORMING
if historyReady
    if volLevel >= volHigh and smoothness <= smoothMax and direction >= smoothDirMin
        rawShape := SHAPE_SMOOTH
    else if volLevel >= volHigh and smoothness >= chaoticMin
        rawShape := SHAPE_CHAOTIC
    else if volLevel >= volHigh and direction < driftMin
        rawShape := SHAPE_CHOPPY
    else if volLevel <= volLow and direction >= driftMin and smoothness <= smoothMax
        rawShape := SHAPE_DRIFT
    else if volLevel <= volLow and direction < driftMin and smoothness <= smoothMax
        rawShape := SHAPE_DEAD

var int confirmedShape = SHAPE_FORMING
var bool confirmedUp = true
var int candidateShape = SHAPE_FORMING
var bool candidateUp = true
var int candidateCount = 0
var int barsInShape = 0

if barstate.isconfirmed
    if rawShape == SHAPE_FORMING
        candidateShape := confirmedShape
        candidateUp := confirmedUp
        candidateCount := 0
    else if f_same_shape_call(rawShape, dirUp, confirmedShape, confirmedUp)
        candidateShape := confirmedShape
        candidateUp := confirmedUp
        candidateCount := 0
    else
        if f_same_shape_call(rawShape, dirUp, candidateShape, candidateUp)
            candidateCount += 1
        else
            candidateShape := rawShape
            candidateUp := dirUp
            candidateCount := 1

        if confirmBars == 0 or candidateCount >= confirmBars
            confirmedShape := candidateShape
            confirmedUp := candidateUp
            candidateCount := 0

prevConfirmedShape = bar_index == 0 ? confirmedShape : confirmedShape[1]
prevConfirmedUp = bar_index == 0 ? confirmedUp : confirmedUp[1]
sameCallAsPrevious = f_same_shape_call(confirmedShape, confirmedUp, prevConfirmedShape, prevConfirmedUp)
shapeChanged = barstate.isconfirmed and not sameCallAsPrevious
barsInShape := confirmedShape == SHAPE_FORMING ? 0 : sameCallAsPrevious ? barsInShape + 1 : 1

shapeUp = f_shape_uses_direction(confirmedShape) ? confirmedUp : dirUp
shapeColor = f_shape_color(confirmedShape)
shapeTextColor = f_shape_text_color(confirmedShape)

volScore = f_clamp((volLevel - volLow) / math.max(volHigh - volLow, 0.01), 0.0, 1.0)
smoothScore = f_clamp(1.0 - smoothness / math.max(chaoticMin, 0.01), 0.0, 1.0)
dirScore = f_clamp(direction, 0.0, 1.0)
qualityScore =
     confirmedShape == SHAPE_SMOOTH ? int(math.round((volScore * 0.34 + smoothScore * 0.33 + dirScore * 0.33) * 100.0)) :
     confirmedShape == SHAPE_CHAOTIC ? int(math.round((volScore * 0.45 + f_clamp(smoothness / math.max(chaoticMin, 0.01), 0.0, 1.0) * 0.55) * 100.0)) :
     confirmedShape == SHAPE_CHOPPY ? int(math.round((volScore * 0.45 + (1.0 - dirScore) * 0.55) * 100.0)) :
     confirmedShape == SHAPE_DRIFT ? int(math.round(((1.0 - volScore) * 0.50 + dirScore * 0.50) * 100.0)) :
     confirmedShape == SHAPE_DEAD ? int(math.round(((1.0 - volScore) * 0.55 + (1.0 - dirScore) * 0.45) * 100.0)) :
     0

volText = volLevel >= volHigh ? "High" : volLevel <= volLow ? "Low" : "Normal"
atrContextText = volText + " ATR " + str.tostring(volLevel, "#.00") + "x"
smoothText = smoothness <= smoothMax ? "Smooth" : smoothness >= chaoticMin ? "Chaotic" : "Mixed"
directionText = direction >= 0.50 ? "Directional" : direction >= driftMin ? "Drifting" : "Choppy"
workflowText = f_workflow_state(confirmedShape)
workflowHint = f_workflow_hint(confirmedShape)
workflowColor = f_workflow_color(confirmedShape)
workflowTextColor = f_workflow_text_color(confirmedShape)

// -------------------------------------------------
// Confirmation-anchored proof (classification stability)
// -------------------------------------------------
var int proofTotal = 0
var int proofReact = 0
var int proofFollow = 0
var int proofHold = 0
var int proofFlip = 0
var bool evalActive = false
var int evalShape = SHAPE_FORMING
var bool evalUp = true
var bool evalExpansion = false
var int evalStartBar = na
var bool evalReacted = false
var bool evalFollowed = false

effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

if barstate.isconfirmed
    if evalActive
        int heldBars = bar_index - evalStartBar
        bool exactCallChanged = not f_same_shape_call(confirmedShape, confirmedUp, evalShape, evalUp)

        if not exactCallChanged and heldBars >= effectiveReactBars
            evalReacted := true

        bool horizonDone = heldBars >= proofHorizonBars
        if exactCallChanged or horizonDone
            bool categoryMatch = evalExpansion ? volLevel >= volHigh : volLevel <= volLow
            evalFollowed := categoryMatch

            proofTotal := proofTotal + 1
            if evalReacted
                proofReact := proofReact + 1
            if evalFollowed
                proofFollow := proofFollow + 1
            if horizonDone and not exactCallChanged
                proofHold := proofHold + 1
            if exactCallChanged
                proofFlip := proofFlip + 1

            evalActive := false

    if shapeChanged and confirmedShape != SHAPE_FORMING and not evalActive
        evalActive := true
        evalShape := confirmedShape
        evalUp := confirmedUp
        evalExpansion := confirmedShape == SHAPE_SMOOTH or confirmedShape == SHAPE_CHAOTIC or confirmedShape == SHAPE_CHOPPY
        evalStartBar := bar_index
        evalReacted := false
        evalFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Visuals
// -------------------------------------------------
basis = ta.ema(close, ribbonLen)
ribbonHalf = math.max(atrNow * ribbonAtr, syminfo.mintick * 10.0)
ribbonTop = basis + ribbonHalf
ribbonBottom = basis - ribbonHalf

pTop = plot(showRibbon ? ribbonTop : na, "Shape Ribbon Top", color = color.new(shapeColor, 70), linewidth = 1)
pBottom = plot(showRibbon ? ribbonBottom : na, "Shape Ribbon Bottom", color = color.new(shapeColor, 70), linewidth = 1)
fill(pTop, pBottom, color = showRibbon ? color.new(shapeColor, 82) : na, title = "Shape Ribbon Fill")

plotshape(showContextPulses and shapeChanged and confirmedShape == SHAPE_SMOOTH, title = "Smooth Expansion Pulse", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny, text = "")
plotshape(showContextPulses and shapeChanged and (confirmedShape == SHAPE_CHAOTIC or confirmedShape == SHAPE_CHOPPY), title = "Noisy Expansion Pulse", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny, text = "")
plotshape(showContextPulses and shapeChanged and (confirmedShape == SHAPE_DRIFT or confirmedShape == SHAPE_DEAD), title = "Cooldown Pulse", style = shape.square, location = location.bottom, color = color.new(accentColor, 0), size = size.tiny, text = "")

bgcolor(showBackground and confirmedShape != SHAPE_FORMING ? color.new(shapeColor, 94) : na, title = "Shape Background")

var array<label> badges = array.new<label>()
var int lastBadgeBar = -10000

f_keep_badge(label id) =>
    array.push(badges, id)
    while array.size(badges) > maxVisibleBadges
        old = array.shift(badges)
        if not na(old)
            label.delete(old)

badgeAllowed = showBadges and shapeChanged and confirmedShape != SHAPE_FORMING and (bar_index - lastBadgeBar >= badgeCooldown)
badgeY = shapeUp ? high + atrNow * 1.55 : low - atrNow * 1.55
badgeStyle = shapeUp ? label.style_label_down : label.style_label_up

if badgeAllowed
    lb = label.new(bar_index, badgeY, workflowHint + " | " + f_shape_short(confirmedShape, shapeUp), xloc = xloc.bar_index, yloc = yloc.price, style = badgeStyle, color = shapeColor, textcolor = shapeTextColor, size = labelSize)
    f_keep_badge(lb)
    lastBadgeBar := bar_index

var label liveStatusTag = na
var line liveConnector = na

if showLiveTags and barstate.islast
    tagX = bar_index + rightTagOffset
    anchorY = shapeUp ? ribbonTop : ribbonBottom
    statusText = workflowText + " | " + f_shape_short(confirmedShape, shapeUp) + "\nQuality " + str.tostring(qualityScore) + "\n" + atrContextText + "\nDuration " + str.tostring(barsInShape) + " bars"

    if na(liveStatusTag)
        liveStatusTag := label.new(tagX, anchorY, statusText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(workflowColor, 0), textcolor = workflowTextColor, size = labelSize, textalign = text.align_left)
    else
        label.set_xy(liveStatusTag, tagX, anchorY)
        label.set_text(liveStatusTag, statusText)
        label.set_color(liveStatusTag, color.new(workflowColor, 0))
        label.set_textcolor(liveStatusTag, workflowTextColor)
        label.set_size(liveStatusTag, labelSize)
        label.set_textalign(liveStatusTag, text.align_left)

    if na(liveConnector)
        liveConnector := line.new(bar_index, anchorY, tagX, anchorY, xloc = xloc.bar_index, extend = extend.none, color = color.new(shapeColor, 30), style = line.style_solid, width = 1)
    else
        line.set_xy1(liveConnector, bar_index, anchorY)
        line.set_xy2(liveConnector, tagX, anchorY)
        line.set_color(liveConnector, color.new(shapeColor, 30))
else if not showLiveTags
    if not na(liveStatusTag)
        label.delete(liveStatusTag)
        liveStatusTag := na
    if not na(liveConnector)
        line.delete(liveConnector)
        liveConnector := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
int panelRowCount = showProof ? 13 : 8
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : panelLabelCol
color followCol = proofTotal > 0 ? f_rate_color(followRate) : panelLabelCol
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : panelLabelCol
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : panelLabelCol

var table panel = na

if showPanel and na(panel)
    panel := table.new(f_pos(panelPosition), 2, panelRowCount, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 0, "AG Pro Volatility Shape Classifier", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)

    table.cell(panel, 0, 1, "Shape", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, f_shape_full(confirmedShape, shapeUp), text_color = shapeTextColor, bgcolor = shapeColor, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 2, "Workflow", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, workflowText + " - " + workflowHint, text_color = workflowTextColor, bgcolor = workflowColor, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 3, "Quality", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, str.tostring(qualityScore) + " / 100", text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 4, "ATR Context", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, atrContextText, text_color = panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 5, "Smoothness", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, smoothText, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 6, "Direction", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, directionText, text_color = panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 7, "Duration", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, str.tostring(barsInShape) + " bars", text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    if showProof
        table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 8, proofSampleText, text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 9, "React Rate", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 9, reactText, text_color = reactCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 10, "Follow Rate", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 10, followText, text_color = followCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 11, "Hold Rate", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 11, holdText, text_color = holdCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

        table.cell(panel, 0, 12, "Flip Rate", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 12, flipText, text_color = flipCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
smoothShift = alertSmooth and shapeChanged and confirmedShape == SHAPE_SMOOTH
chaoticShift = alertChaotic and shapeChanged and confirmedShape == SHAPE_CHAOTIC
choppyShift = alertChoppy and shapeChanged and confirmedShape == SHAPE_CHOPPY
lowVolShift = alertLowVol and shapeChanged and (confirmedShape == SHAPE_DRIFT or confirmedShape == SHAPE_DEAD)

alertcondition(smoothShift, "Smooth Expansion Attention Marker", "Volatility Shape Classifier: SMOOTH EXPANSION attention marker. Review volatility shape, quality, and broader context.")
alertcondition(chaoticShift, "Chaotic Expansion Attention Marker", "Volatility Shape Classifier: CHAOTIC EXPANSION attention marker. Review noisy volatility conditions before interpreting context.")
alertcondition(choppyShift, "Choppy Expansion Attention Marker", "Volatility Shape Classifier: CHOPPY EXPANSION attention marker. Review expansion quality and directional consistency.")
alertcondition(lowVolShift, "Low-Volatility Attention Marker", "Volatility Shape Classifier: LOW-VOLATILITY attention marker. Review cooldown context and broader market structure.")

// -------------------------------------------------
// Hidden Exports
// -------------------------------------------------
plot(qualityScore, "VSC Quality Score", display = display.none)
plot(volLevel, "VSC Vol Level", display = display.none)
plot(followRate, "VSC Follow Rate", display = display.none)
plot(holdRate, "VSC Hold Rate", display = display.none)
plot(reactRate, "VSC React Rate", display = display.none)
plot(flipRate, "VSC Flip Rate", display = display.none)
plot(confirmedShape, "VSC Confirmed Shape ID", display = display.none)
plot(shapeUp ? 1 : -1, "VSC Confirmed Direction", display = display.none)
plot(barsInShape, "VSC Bars In Shape", display = display.none)
plot(smoothness, "VSC Smoothness Ratio", display = display.none)
plot(direction, "VSC Directional Consistency", display = display.none)
````
