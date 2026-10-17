# Delivery Regime Map [AGPro Series]

- url: https://www.tradingview.com/script/7xR1GB9N-Delivery-Regime-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;4ef874818e0e469486b727e70f7dc3a9
- version: 8.0

## Description

Delivery Regime Map [AGPro Series]

🔹 Overview

Delivery Regime Map classifies the market's delivery character into four distinct regimes — Balanced, Directional, Fragmented, and Exhausted — giving traders instant context on whether the tape is trending with conviction, consolidating, breaking into volatile chop, or fading after an extended move. Rather than asking "is this bullish or bearish?", DRM answers a more useful question: "what kind of market am I in, and what kind of setup is appropriate here?"

The indicator overlays a soft state ribbon across the chart, prints confirmed regime shift labels at the moment of transition, and maintains a compact status panel with the active regime, a composite conviction score, regime duration, and time since the last shift. All outputs are confirmed on bar close with dwell-based hysteresis to suppress noise.


🎯 Unique Edge

Most regime or trend-strength tools collapse the market into a single linear axis (strong ↔ weak, bullish ↔ bearish). Delivery Regime Map is categorical, not linear — it identifies the qualitative character of price delivery by fusing four independent dimensions:

• Displacement quality (how much of each bar's range is body vs. wick)
• Directional persistence (close-to-close consistency + EMA slope alignment)
• Continuity (same-side runs penalized by gap noise)
• Range expansion (current range normalized by ATR baseline)

These dimensions combine into a composite score, but the regime classification uses banded thresholds with hysteresis — meaning a Directional tape must decisively lose its edge before flipping to Fragmented or Exhausted. This produces sparse, high-conviction transitions rather than the constant flipping typical of single-value strength meters.


⚙️ Methodology

The engine computes five rolling metrics across a user-defined window (default 20 bars):

1. Displacement Quality — |close − open| / range, smoothed. High values mean strong, decisive bars with minimal wick rejection.

2. Directional Persistence — average signed close direction plus an EMA slope-alignment check. Rewards tapes that move one way without reversing.

3. Continuity — the proportion of consecutive same-side candles, penalized by an average gap-size term (opens far from prior closes indicate fractured delivery).

4. Range Expansion — current range vs. ATR baseline, clipped to [0, 1]. High expansion combined with low continuity flags Fragmented tapes.

5. Exhaustion Proxy — the decay rate of displacement quality after a period of high persistence. Triggers near trend terminations where bars shrink while direction lingers.

A classifier selects the active regime by priority (Directional → Exhausted → Fragmented → Balanced), and a dwell-bar confirmation (default 5 bars, or 8 under Strict mode) plus a minimum-gap filter (default 10 bars) prevent whipsaw transitions.


🚦 Signals & Alerts

Four alert conditions are built in, each firing only on a confirmed regime shift:

• Regime shifted to Directional — conviction is rising; the tape is trending
• Regime shifted to Fragmented — wide, disconnected bars; chop risk elevated
• Regime shifted to Exhausted — prior trend is losing steam; mean-reversion risk
• Regime shifted to Balanced — low-conviction state; breakout potential building

All alerts include the ticker and interval in the message payload.


🎛️ Key Inputs

• Regime Window (8–60) — length of the measurement window
• Regime Sensitivity (Low / Normal / High) — hysteresis band width
• Strict Classifier — extends dwell requirement from 5 to 8 bars
• Minimum Bars Between Shifts — anti-chop spacing filter
• Show State Ribbon / Regime Shift Labels — visual toggles
• Panel Position + Font Size — 6 anchor positions, 5 size options
• Label Font Size — matches user's chart density preference

Every input carries an inline tooltip explaining its behavior and tradeoffs.


📚 How to Use

• Use Directional regimes to favor trend-following entries and trailing stops
• Use Balanced regimes to prepare for breakouts; volatility compression often precedes expansion
• Use Fragmented regimes as a caution flag — reduce size, widen stops, or stand aside
• Use Exhausted regimes to tighten trailing stops on open trend positions; the edge may be fading

DRM is designed to be asset-agnostic and timeframe-agnostic. On lower timeframes (1m–15m), consider Strict mode and a larger minimum-gap value. On daily charts, defaults typically work well. Combine with any entry framework — order blocks, breakout levels, VWAP reclaims — as a regime filter that answers "should I even be looking for a setup here?"


⚠️ Limitations & Transparency

• The classifier is reactive, not predictive — it confirms regime changes on close, so a Directional label appears a few bars after the trend has begun. This is by design: dwell confirmation is the primary noise filter.
• Regime definitions are categorical interpretations of price statistics. They are not forecasts.
• The composite score reflects regime conviction, not directional bias. A high score in Fragmented means "confidently choppy", not "confidently bullish".
• This indicator is not a strategy. It produces no entry signals, no take-profit targets, and no stop-loss levels. It is a market-context tool intended to be combined with a trader's existing framework.
• Past regime behavior does not guarantee future regime behavior. Market character can change abruptly on news or macro events.


📜 Risk Disclosure

This indicator is published for educational and analytical purposes only. It does not constitute financial advice, a trading recommendation, or an offer to buy or sell any instrument. Trading and investing carry risk of loss, and past performance does not guarantee future results. Users are solely responsible for their own decisions and should consult qualified professionals before committing capital.

## Source Code

````pine
// -------------------------------------------------
// Delivery Regime Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.9
//
// Delivery Regime Map classifies the market's delivery character into
// Balanced, Directional, Fragmented, and Exhausted regimes. It blends
// ATR-normalized displacement quality, directional persistence, continuity,
// range expansion, and fade pressure into a rule-based delivery score, then
// projects the active regime through a clean price ribbon, an active delivery
// zone, centered zone badge, shift labels, a right-edge status card, and a
// compact AG Pro panel, plus a confirmation-anchored proof layer (Follow, Hold,
// React, Flip rates) measuring how stable past regime calls were on the symbol.
// -------------------------------------------------

//@version=6
indicator("Delivery Regime Map [AGPro Series]",
     shorttitle = "AG Pro DRM",
     overlay = true,
     max_labels_count = 110,
     max_lines_count = 30,
     max_boxes_count = 20)

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
// Regime constants
// -------------------------------------------------
REGIME_BALANCED = 0
REGIME_DIRECTIONAL = 1
REGIME_FRAGMENTED = 2
REGIME_EXHAUSTED = 3

// -------------------------------------------------
// Input groups
// -------------------------------------------------
gEngine = "Engine"
gVisual = "Visual Layer"
gLabels = "Labels"
gPanel  = "Panel"
gProof  = "Proof"
gAlerts = "Alerts"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
regimeLen = input.int(20, "Regime Window", minval = 8, maxval = 80, group = gEngine, tooltip = "Number of bars used to measure displacement quality, persistence, continuity, and expansion.")
sensitivity = input.string("Normal", "Regime Sensitivity", options = ["Low", "Normal", "High"], group = gEngine, tooltip = "Controls how readily the classifier shifts between delivery regimes.")
strictClassifier = input.bool(false, "Strict Classifier", group = gEngine, tooltip = "Requires longer dwell confirmation before a new regime is promoted.")
minShiftGap = input.int(10, "Minimum Bars Between Shifts", minval = 0, maxval = 80, group = gEngine, tooltip = "Minimum spacing between confirmed regime shifts.")

showRibbon = input.bool(true, "Show Delivery Ribbon", group = gVisual, tooltip = "Displays a price-mapped ribbon colored by the active delivery regime.")
ribbonBasisLen = input.int(34, "Ribbon Basis Length", minval = 5, maxval = 200, group = gVisual, tooltip = "EMA basis used to map the delivery ribbon onto price.")
ribbonWidthATR = input.float(0.16, "Ribbon Width (ATR)", minval = 0.03, maxval = 1.20, step = 0.01, group = gVisual, tooltip = "ATR-scaled thickness of the delivery ribbon.")
showRibbonGlow = input.bool(true, "Show Ribbon Glow", group = gVisual, tooltip = "Adds a soft outer glow around the delivery ribbon.")
showDeliveryZone = input.bool(true, "Show Active Delivery Zone", group = gVisual, tooltip = "Draws a focused regime zone around the latest delivery window.")
showZoneBadge = input.bool(true, "Show Centered Zone Badge", group = gVisual, tooltip = "Places a vertically centered regime badge in the clear projection area of the active delivery zone, so it stays readable without overlapping candles.")
zoneLookback = input.int(28, "Active Zone Lookback", minval = 8, maxval = 160, group = gVisual, tooltip = "Rolling window used to map the active delivery zone around current price structure.")
zoneProjectionBars = input.int(12, "Active Zone Projection", minval = 2, maxval = 80, group = gVisual, tooltip = "Forward projection length for the active delivery zone.")
showBackground = input.bool(false, "Tint Background by Regime", group = gVisual, tooltip = "Applies a subtle background tint based on the active regime.")
backgroundTransparency = input.int(95, "Background Transparency", minval = 80, maxval = 99, group = gVisual, tooltip = "Transparency used by the optional background tint.")
showBarTint = input.bool(false, "Tint Bars by Regime", group = gVisual, tooltip = "Applies a subtle candle tint based on the active delivery regime.")

showShiftLabels = input.bool(true, "Show Regime Shift Labels", group = gLabels, tooltip = "Prints labels when a confirmed delivery regime shift occurs.")
showLiveTag = input.bool(true, "Show Live Status Card", group = gLabels, tooltip = "Displays a single live right-side status card with the current delivery regime, score, and metric readings.")
liveTagOffsetBars = input.int(6, "Live Tag Offset Bars", minval = 1, maxval = 40, group = gLabels, tooltip = "Horizontal offset for the live status card. The card is automatically kept to the right of the active delivery zone to avoid overlap.")
labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gLabels, tooltip = "Controls how many historical regime labels are retained.")
labelTextInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels, tooltip = "Text size used for chart labels.")
labelOffsetATR = input.float(1.05, "Label Offset (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = gLabels, tooltip = "ATR-based spacing used to keep regime labels away from candles.")
minLabelBars = input.int(14, "Minimum Bars Between Labels", minval = 1, maxval = 100, group = gLabels, tooltip = "Minimum bar spacing between printed regime labels.")

showPanel = input.bool(true, "Show Panel", group = gPanel, tooltip = "Displays the AG Pro delivery regime panel.")
panelPos = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel, tooltip = "Panel placement on the chart.")
panelTheme = input.string("Auto", "Panel Theme", options = ["Auto", "Dark", "Light"], group = gPanel, tooltip = "Panel theme. Auto adapts to the chart background.")
panelTextInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel, tooltip = "Text size used inside the panel.")
showMetricRow = input.bool(true, "Show Metric Detail Row", group = gPanel, tooltip = "Adds a compact row with displacement, persistence, and continuity readings.")

showProof = input.bool(true, "Show Proof Layer", group = gProof, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measuring how stable past regime calls were on the current symbol and timeframe. These are regime-stability rates, not trade outcomes or predictions.")
proofHorizonBars = input.int(24, "Proof Horizon Bars", minval = 5, maxval = 300, group = gProof, tooltip = "Number of bars each confirmed regime is tracked forward to test whether the regime persisted intact (Hold) or was replaced by a different regime (Flip).")
reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 60, group = gProof, tooltip = "Number of bars a new regime must survive without changing to count as an early React.")

alertDirectional = input.bool(true, "Alert: Directional Regime", group = gAlerts, tooltip = "Triggers when the confirmed regime shifts to Directional.")
alertFragmented = input.bool(true, "Alert: Fragmented Regime", group = gAlerts, tooltip = "Triggers when the confirmed regime shifts to Fragmented.")
alertExhausted = input.bool(true, "Alert: Exhausted Regime", group = gAlerts, tooltip = "Triggers when the confirmed regime shifts to Exhausted.")
alertBalanced = input.bool(true, "Alert: Balanced Regime", group = gAlerts, tooltip = "Triggers when the confirmed regime shifts to Balanced.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_dark_mode(string mode) =>
    lum = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
    mode == "Dark" ? true : mode == "Light" ? false : lum < 140

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)

f_trim_labels(array<label> items, int keep) =>
    while array.size(items) > keep
        oldItem = array.shift(items)
        if not na(oldItem)
            label.delete(oldItem)

f_threshold(float lowValue, float normalValue, float highValue) =>
    sensitivity == "Low" ? lowValue : sensitivity == "High" ? highValue : normalValue

f_regime_name(int regime) =>
    switch regime
        REGIME_DIRECTIONAL => "Directional"
        REGIME_FRAGMENTED  => "Fragmented"
        REGIME_EXHAUSTED   => "Exhausted"
        => "Balanced"

f_regime_state(int regime) =>
    switch regime
        REGIME_DIRECTIONAL => "Ready"
        REGIME_FRAGMENTED  => "Blocked"
        REGIME_EXHAUSTED   => "Monitor"
        => "Wait"

f_regime_workflow(int regime) =>
    switch regime
        REGIME_DIRECTIONAL => "Clean Delivery"
        REGIME_FRAGMENTED  => "Broken Flow"
        REGIME_EXHAUSTED   => "Fade Watch"
        => "Balanced Map"

f_regime_color(int regime) =>
    switch regime
        REGIME_DIRECTIONAL => bullColor
        REGIME_FRAGMENTED  => bearColor
        REGIME_EXHAUSTED   => neutralColor
        => accentColor

// -------------------------------------------------
// Engine metrics
// -------------------------------------------------
labelSize = f_size(labelTextInput)
panelSize = f_size(panelTextInput)
atr = math.max(nz(ta.atr(regimeLen), syminfo.mintick * 20.0), syminfo.mintick)

body = math.abs(close - open)
barRange = math.max(high - low, syminfo.mintick)
bodyPct = body / barRange
dispQual = ta.sma(bodyPct, regimeLen)

dir = close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0
dirAvg = ta.sma(dir, regimeLen)
persist = math.abs(dirAvg)
emaFastLen = int(math.max(2, math.round(regimeLen / 2.0)))
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, regimeLen)
slopeSign = emaFast > emaSlow ? 1.0 : emaFast < emaSlow ? -1.0 : 0.0
dirSign = dirAvg > 0 ? 1.0 : dirAvg < 0 ? -1.0 : 0.0
slopeAlign = slopeSign != 0 and slopeSign == dirSign ? 1.0 : 0.0
dirScore = 0.65 * persist + 0.35 * slopeAlign

sameSide = (close > open and close[1] > open[1]) or (close < open and close[1] < open[1]) ? 1.0 : 0.0
continuity = ta.sma(sameSide, regimeLen)
gap = math.abs(open - close[1]) / atr
gapPenalty = math.min(1.0, ta.sma(gap, regimeLen) * 0.5)
contScore = math.max(0.0, continuity - gapPenalty)

rangeNorm = barRange / atr
rangeAvg = ta.sma(rangeNorm, regimeLen)
expansion = math.min(2.0, rangeAvg) / 2.0

dispDelta = dispQual - nz(dispQual[regimeLen], dispQual)
fade = math.max(0.0, math.min(1.0, -dispDelta * 4.0))
priorPersist = nz(persist[regimeLen], persist)

composite = int(math.round(100.0 * (0.40 * dirScore + 0.30 * dispQual + 0.20 * contScore + 0.10 * (1.0 - expansion))))

// -------------------------------------------------
// Classifier
// -------------------------------------------------
thrDir = f_threshold(0.52, 0.45, 0.38)
thrFrag = f_threshold(0.58, 0.50, 0.43)
thrBal = f_threshold(0.32, 0.38, 0.44)
thrExhFade = f_threshold(0.40, 0.30, 0.22)

var int rawRegime = REGIME_BALANCED
isDirectional = dirScore >= thrDir and dispQual >= 0.38
isFragmented = expansion >= thrFrag and (contScore <= 0.38 or dirScore <= 0.42)
isExhausted = priorPersist >= 0.45 and fade >= thrExhFade and dirScore <= thrDir + 0.05
isBalanced = dirScore <= thrBal and expansion <= 0.55

rawRegime := isDirectional ? REGIME_DIRECTIONAL : isExhausted ? REGIME_EXHAUSTED : isFragmented ? REGIME_FRAGMENTED : isBalanced ? REGIME_BALANCED : nz(rawRegime[1], REGIME_BALANCED)

confirmBars = strictClassifier ? 8 : 5
var int confirmedRegime = REGIME_BALANCED
var int stableCount = 0
var int regimeDuration = 0
var int lastShiftBar = 0

stableCount := rawRegime == nz(rawRegime[1], rawRegime) ? stableCount + 1 : 1
regimeDuration := confirmedRegime == nz(confirmedRegime[1], confirmedRegime) ? regimeDuration + 1 : 1
gapSatisfied = bar_index - lastShiftBar >= minShiftGap

if barstate.isconfirmed and stableCount >= confirmBars and rawRegime != confirmedRegime and gapSatisfied
    confirmedRegime := rawRegime
    lastShiftBar := bar_index
    regimeDuration := 1

barsSinceShift = bar_index - lastShiftBar
regimeShift = barstate.isconfirmed and confirmedRegime != nz(confirmedRegime[1], confirmedRegime)
regimeName = f_regime_name(confirmedRegime)
regimeState = f_regime_state(confirmedRegime)
workflowText = f_regime_workflow(confirmedRegime)
regimeColor = f_regime_color(confirmedRegime)

// -------------------------------------------------
// Confirmation-anchored proof (regime stability)
// -------------------------------------------------
var int proofTotal = 0
var int proofReact = 0
var int proofFollow = 0
var int proofHold = 0
var int proofFlip = 0
var bool evalActive = false
var bool proofSeeded = false
var int evalRegime = na
var int evalStartBar = na
var bool evalReacted = false
var bool evalFollowed = false

int proofWarmup = regimeLen * 2 + ribbonBasisLen
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))
int midBars = math.max(effectiveReactBars + 1, int(math.round(proofHorizonBars * 0.5)))
midBars := math.min(midBars, proofHorizonBars)

if barstate.isconfirmed and bar_index > proofWarmup
    bool regimeChanged = evalActive and confirmedRegime != evalRegime

    if evalActive
        int heldBars = bar_index - evalStartBar
        if not regimeChanged and heldBars >= effectiveReactBars
            evalReacted := true
        if not regimeChanged and heldBars >= midBars
            evalFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        if regimeChanged or horizonDone
            proofTotal := proofTotal + 1
            if evalReacted
                proofReact := proofReact + 1
            if evalFollowed
                proofFollow := proofFollow + 1
            if horizonDone and not regimeChanged
                proofHold := proofHold + 1
            else
                proofFlip := proofFlip + 1
            evalActive := false

    // Start exactly one proof evaluation for each confirmed regime call.
    // The first post-warmup regime is seeded once; subsequent samples begin only on shifts.
    bool startEvaluation = (not proofSeeded) or regimeShift
    if startEvaluation
        evalActive := true
        proofSeeded := true
        evalRegime := confirmedRegime
        evalStartBar := bar_index
        evalReacted := false
        evalFollowed := false

float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Visual layer
// -------------------------------------------------
basis = ta.ema(close, ribbonBasisLen)
ribbonHalf = atr * ribbonWidthATR
ribbonTop = basis + ribbonHalf
ribbonBottom = basis - ribbonHalf
glowTop = basis + ribbonHalf * 2.0
glowBottom = basis - ribbonHalf * 2.0

pGlowTop = plot(showRibbon and showRibbonGlow ? glowTop : na, "Delivery Glow Top", color = color.new(regimeColor, 100), linewidth = 1)
pGlowBottom = plot(showRibbon and showRibbonGlow ? glowBottom : na, "Delivery Glow Bottom", color = color.new(regimeColor, 100), linewidth = 1)
pRibbonTop = plot(showRibbon ? ribbonTop : na, "Delivery Ribbon Top", color = color.new(regimeColor, 78), linewidth = 1)
pRibbonBottom = plot(showRibbon ? ribbonBottom : na, "Delivery Ribbon Bottom", color = color.new(regimeColor, 78), linewidth = 1)
pBasis = plot(showRibbon ? basis : na, "Delivery Basis", color = color.new(regimeColor, 16), linewidth = 2)

fill(pGlowTop, pGlowBottom, color = showRibbon and showRibbonGlow ? color.new(regimeColor, 95) : na, title = "Delivery Ribbon Glow")
fill(pRibbonTop, pRibbonBottom, color = showRibbon ? color.new(regimeColor, 84) : na, title = "Delivery Ribbon Fill")
bgcolor(showBackground ? color.new(regimeColor, backgroundTransparency) : na, title = "Regime Background")
barcolor(showBarTint ? color.new(regimeColor, 80) : na)

// -------------------------------------------------
// Active delivery zone
// -------------------------------------------------
zoneHigh = ta.highest(high + atr * 0.22, zoneLookback)
zoneLow = ta.lowest(low - atr * 0.22, zoneLookback)
zoneMid = (zoneHigh + zoneLow) * 0.5
zoneLeft = math.max(0, bar_index - zoneLookback + 1)
zoneRight = bar_index + zoneProjectionBars
zoneBadgeX = math.min(zoneRight - 1, bar_index + int(math.round(math.max(2, zoneProjectionBars) * 0.5)))
zoneBadgeText = regimeName + " Delivery\nScore " + str.tostring(composite)

var box activeZone = na
var label zoneBadge = na

if barstate.islast
    if showDeliveryZone
        if na(activeZone)
            activeZone := box.new(zoneLeft, zoneHigh, zoneRight, zoneLow, xloc = xloc.bar_index, bgcolor = color.new(regimeColor, 91), border_color = color.new(regimeColor, 44), border_width = 1)
        else
            box.set_left(activeZone, zoneLeft)
            box.set_right(activeZone, zoneRight)
            box.set_top(activeZone, zoneHigh)
            box.set_bottom(activeZone, zoneLow)
            box.set_bgcolor(activeZone, color.new(regimeColor, 91))
            box.set_border_color(activeZone, color.new(regimeColor, 44))
            box.set_border_width(activeZone, 1)

        if showZoneBadge
            if na(zoneBadge)
                zoneBadge := label.new(zoneBadgeX, zoneMid, zoneBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(regimeColor, 0), textcolor = f_text_on(regimeColor), size = labelSize, textalign = text.align_center)
            else
                label.set_xy(zoneBadge, zoneBadgeX, zoneMid)
                label.set_text(zoneBadge, zoneBadgeText)
                label.set_color(zoneBadge, color.new(regimeColor, 0))
                label.set_textcolor(zoneBadge, f_text_on(regimeColor))
                label.set_size(zoneBadge, labelSize)
                label.set_textalign(zoneBadge, text.align_center)
        else
            if not na(zoneBadge)
                label.delete(zoneBadge)
                zoneBadge := na
    else
        if not na(activeZone)
            box.delete(activeZone)
            activeZone := na
        if not na(zoneBadge)
            label.delete(zoneBadge)
            zoneBadge := na

// -------------------------------------------------
// Labels
// -------------------------------------------------
var label[] shiftLabels = array.new_label()
var label liveStatusTag = na
var line liveConnector = na
var int lastLabelBar = na
labelKeep = labelDensity == "Detailed" ? 8 : labelDensity == "Balanced" ? 5 : 3
canPrintLabel = na(lastLabelBar) or bar_index - lastLabelBar >= minLabelBars

if showShiftLabels and regimeShift and canPrintLabel
    placeAbove = confirmedRegime == REGIME_DIRECTIONAL or confirmedRegime == REGIME_EXHAUSTED
    yLabel = placeAbove ? high + atr * labelOffsetATR : low - atr * labelOffsetATR
    labelStyle = placeAbove ? label.style_label_down : label.style_label_up
    labelText = regimeState + " | " + regimeName
    lb = label.new(bar_index, yLabel, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(regimeColor, 0), textcolor = f_text_on(regimeColor), size = labelSize, textalign = text.align_center)
    array.push(shiftLabels, lb)
    f_trim_labels(shiftLabels, labelKeep)
    lastLabelBar := bar_index

if barstate.islast
    if showLiveTag
        tagX = math.max(bar_index + liveTagOffsetBars, zoneRight + 2)
        placeTop = confirmedRegime == REGIME_DIRECTIONAL or confirmedRegime == REGIME_EXHAUSTED
        anchorY = placeTop ? ribbonTop : ribbonBottom
        statusText = regimeState + " | " + regimeName + "\nScore " + str.tostring(composite) + "\nDisp/Dir/Cont " + str.tostring(dispQual, "#.##") + " / " + str.tostring(dirScore, "#.##") + " / " + str.tostring(contScore, "#.##")
        if na(liveStatusTag)
            liveStatusTag := label.new(tagX, anchorY, statusText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(regimeColor, 0), textcolor = f_text_on(regimeColor), size = labelSize, textalign = text.align_left)
        else
            label.set_xy(liveStatusTag, tagX, anchorY)
            label.set_text(liveStatusTag, statusText)
            label.set_color(liveStatusTag, color.new(regimeColor, 0))
            label.set_textcolor(liveStatusTag, f_text_on(regimeColor))
            label.set_size(liveStatusTag, labelSize)
            label.set_textalign(liveStatusTag, text.align_left)
        if na(liveConnector)
            liveConnector := line.new(bar_index, basis, tagX, anchorY, xloc = xloc.bar_index, color = color.new(regimeColor, 38), width = 1)
        else
            line.set_xy1(liveConnector, bar_index, basis)
            line.set_xy2(liveConnector, tagX, anchorY)
            line.set_color(liveConnector, color.new(regimeColor, 38))
    else
        if not na(liveStatusTag)
            label.delete(liveStatusTag)
            liveStatusTag := na
        if not na(liveConnector)
            line.delete(liveConnector)
            liveConnector := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
darkPanel = f_dark_mode(panelTheme)
panelFrame = darkPanel ? panelBorder : color.rgb(203, 213, 225)
leftBg = darkPanel ? color.rgb(13, 22, 38) : color.rgb(241, 245, 249)
rightBg = darkPanel ? color.rgb(8, 15, 28) : color.rgb(255, 255, 255)
leftTxt = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
rightTxt = darkPanel ? panelValueCol : color.rgb(15, 23, 42)
stateBg = color.new(regimeColor, darkPanel ? 28 : 84)
scoreBg = composite >= 70 ? color.new(regimeColor, darkPanel ? 30 : 84) : composite >= 40 ? color.new(neutralColor, darkPanel ? 32 : 86) : rightBg
shiftText = barsSinceShift == 0 ? "Just now" : str.tostring(barsSinceShift) + " bars ago"
modeText = sensitivity + (strictClassifier ? " / Strict" : "")
metricText = str.tostring(dispQual, "#.##") + " / " + str.tostring(dirScore, "#.##") + " / " + str.tostring(contScore, "#.##")

proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
followText = proofTotal > 0 ? f_pct(followRate) : "-"
holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
followCol = proofTotal > 0 ? f_rate_color(followRate) : rightTxt
holdCol = proofTotal > 0 ? f_rate_color(holdRate) : rightTxt
reactCol = proofTotal > 0 ? f_rate_color(reactRate) : rightTxt
flipCol = proofTotal > 0 ? f_flip_color(flipRate) : rightTxt

int panelRowCount = showProof ? 13 : 8

var table panel = na
var string lastPanelPos = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastPanelVisible = false
var bool lastMetricMode = false
var bool lastProofMode = false

panelNeedsReset = showPanel and (na(panel) or panelPos != lastPanelPos or panelTheme != lastPanelTheme or panelTextInput != lastPanelSize or showMetricRow != lastMetricMode or showProof != lastProofMode)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPos), 2, panelRowCount, frame_color = panelFrame, border_color = panelFrame, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Delivery Regime Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelPos := panelPos
    lastPanelTheme := panelTheme
    lastPanelSize := panelTextInput
    lastPanelVisible := showPanel
    lastMetricMode := showMetricRow
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_panel_pos(panelPos))
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Delivery Regime Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 0, 1, "State", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 1, regimeState, text_color = f_text_on(stateBg), bgcolor = stateBg, text_size = panelSize)
    table.cell(panel, 0, 2, "Regime", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 2, regimeName, text_color = regimeColor, bgcolor = rightBg, text_size = panelSize)
    table.cell(panel, 0, 3, "Workflow", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 3, workflowText, text_color = f_text_on(stateBg), bgcolor = stateBg, text_size = panelSize)
    table.cell(panel, 0, 4, "Delivery Score", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 4, str.tostring(composite) + "/100", text_color = composite >= 40 ? f_text_on(scoreBg) : rightTxt, bgcolor = scoreBg, text_size = panelSize)
    table.cell(panel, 0, 5, "Duration", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 5, str.tostring(regimeDuration) + " bars / " + shiftText, text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(panel, 0, 6, "Mode", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 6, modeText, text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    table.cell(panel, 0, 7, showMetricRow ? "Disp / Dir / Cont" : "Expansion", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
    table.cell(panel, 1, 7, showMetricRow ? metricText : str.tostring(expansion, "#.##"), text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
    if showProof
        table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(panel, 1, 8, proofSampleText, text_color = leftTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(panel, 0, 9, "Follow Rate", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 9, followText, text_color = followCol, bgcolor = rightBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(panel, 0, 10, "Hold Rate", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 10, holdText, text_color = holdCol, bgcolor = rightBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(panel, 0, 11, "React Rate", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 11, reactText, text_color = reactCol, bgcolor = rightBg, text_size = panelSize, text_halign = text.align_right)
        table.cell(panel, 0, 12, "Flip Rate", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 12, flipText, text_color = flipCol, bgcolor = rightBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertDirectional and regimeShift and confirmedRegime == REGIME_DIRECTIONAL, "DRM | Directional Attention Marker", "Delivery Regime Map: DIRECTIONAL attention marker. Review delivery quality, persistence, and broader market context.")
alertcondition(alertFragmented and regimeShift and confirmedRegime == REGIME_FRAGMENTED, "DRM | Fragmented Attention Marker", "Delivery Regime Map: FRAGMENTED attention marker. Review continuity, range expansion, and broader market context.")
alertcondition(alertExhausted and regimeShift and confirmedRegime == REGIME_EXHAUSTED, "DRM | Exhausted Attention Marker", "Delivery Regime Map: EXHAUSTED attention marker. Review fade pressure and broader market context.")
alertcondition(alertBalanced and regimeShift and confirmedRegime == REGIME_BALANCED, "DRM | Balanced Attention Marker", "Delivery Regime Map: BALANCED attention marker. Review whether delivery has returned to a neutral map.")

// -------------------------------------------------
// Hidden Exports
// -------------------------------------------------
plot(composite, "DRM Delivery Score", display = display.none)
plot(dispQual, "DRM Displacement", display = display.none)
plot(dirScore, "DRM Directional Score", display = display.none)
plot(contScore, "DRM Continuity", display = display.none)
plot(followRate, "DRM Follow Rate", display = display.none)
plot(holdRate, "DRM Hold Rate", display = display.none)
plot(reactRate, "DRM React Rate", display = display.none)
plot(flipRate, "DRM Flip Rate", display = display.none)
plot(confirmedRegime, "DRM Confirmed Regime ID", display = display.none)
plot(regimeDuration, "DRM Regime Duration", display = display.none)
````
