# Value Migration Bands [AGPro Series]

- url: https://www.tradingview.com/script/nc8zpwkj-Value-Migration-Bands-AGPro-Series/
- type: indicator
- pine_id: PUB;35f91c0970aa4314acb9dd66785016ab
- version: 6.0

## Description

Value Migration Bands [AGPro Series]

Value Migration Bands is a chart-first value migration engine that visualizes where the market's accepted-value region has been drifting over time. Instead of a single moving average, it builds a three-layer band (upper / middle / lower) from a rolling percentile window of typical price, then classifies the current environment as Rising, Flat, or Falling Value using an ATR-normalized slope of the migration midline. The result is a scale-invariant, regime-aware view of how "fair value" migrates across trending and ranging conditions — on crypto, equities, indices, forex and futures alike.

🔷 OVERVIEW

Most band-style indicators build their envelope from volatility (Bollinger, Keltner, Donchian). Value Migration Bands is built from acceptance — the region where price has actually spent its time during the lookback, captured as a percentile window of typical price (hlc3). The outer bands mark the edges of that accepted-value region. The midline marks its core. When the whole region drifts upward, the market is accepting higher prices (Rising Value). When it drifts downward, lower prices are being accepted (Falling Value). When it stays level, participants are agreeing on a stable range (Flat Value).

This reframes the classic "trend vs range" question in terms of value migration, which is a cleaner structural signal than price slope alone. You see not just where price is going, but where the market's center of gravity is going.

🔶 UNIQUE EDGE

Value Migration Bands is distinct from moving-average envelopes, volatility bands and standard channels in several structural ways:

• Percentile-based construction — the band is a percentile window of typical price, not a standard deviation or ATR multiple. This directly captures acceptance, not dispersion.

• Three-state migration classification — Rising / Flat / Falling Value, driven by an ATR-normalized slope of the midline. The classification is scale-invariant, so the same sensitivity works across BTC, SPX, EURUSD, gold and small-cap equities without retuning.

• Regime-aware event markers — Reclaim and Lost markers are filtered by the current regime. Reclaim events are suppressed when the market is in Falling Value; Lost events are suppressed in Rising Value. You only see the events that matter for the active regime.

• Strict Value Filter — during extreme compression, the indicator refuses to classify a regime until the band is meaningfully wide relative to ATR. This prevents false regime flags in low-volatility micro-bands.

• Distance + cooldown gating — new event markers require a minimum ATR distance from the previous event and a minimum bar spacing, producing a clean chart even on long histories.

🔷 METHODOLOGY

Band construction:
1. Typical price (hlc3) is sampled across a configurable lookback window (Band Length).
2. Two percentiles are computed — a lower percentile and an upper percentile, selected by the Band Width Mode (Tight, Balanced, Wide).
3. The midline is the mean of those two percentiles.
4. Light EMA smoothing (adaptive to Band Length) stabilizes the visual without adding structural lag.

Regime classification:
1. The midline slope is measured over a rolling window (adaptive to Band Length).
2. The slope is normalized by ATR(14) to make the threshold scale-invariant.
3. A user-controlled Migration Slope Sensitivity divides the normalized slope into Rising / Flat / Falling bands.
4. A 2-bar confirmation layer prevents rapid regime flipping during transitions.

Event detection:
• Reclaim — price re-enters the band from below after previously being lost.
• Lost — price falls out of the band after previously being inside.
Both pass a regime gate, an ATR-distance gate and a bar-cooldown gate before being plotted or alerted.

🔶 SIGNALS & ALERTS

Four built-in alert conditions:

• Value Band Shifted Up — fires when the confirmed regime transitions into Rising Value.
• Value Band Shifted Down — fires when the confirmed regime transitions into Falling Value.
• Band Reclaimed — fires when price re-enters the accepted-value region (regime-gated).
• Band Lost — fires when price falls out of the accepted-value region (regime-gated).

Alerts and on-chart markers share identical gating, so the alert log and the chart stay in sync.

🔷 KEY INPUTS

Band Engine:
• Band Length (default 100) — lookback for the percentile window.
• Band Width Mode — Tight, Balanced, Wide. Selects the percentile pair.
• Strict Value Filter — requires a minimum band width vs ATR before classifying a regime.
• Migration Slope Sensitivity (default 0.5) — threshold between Rising / Flat / Falling.

Visuals:
• Show Midline, Show Band Fill, Active State Label, Show Reclaim / Lost Markers, Show Info Panel.
• Panel Location — six options (Top / Middle / Bottom × Right / Left).
• Panel Font Size and Label Font Size — default Normal.

Colors:
• Rising Value Color, Falling Value Color, Flat Value Color.
• Band Fill Opacity.

Alerts:
• Individual toggles for the four alert conditions above.

🔶 HOW TO USE

Structural reading:
• Rising Value — treat Reclaim events as continuation confirmations, not counter-trend signals. Expect pullbacks to the midline to be bought.
• Falling Value — treat Lost events as continuation confirmations. Expect rallies back to the midline to be sold.
• Flat Value — neither regime is active. The band can be used as a range reference; directional events are suppressed because they do not carry regime confirmation.

Location reading:
• Inside Band — price is trading within the accepted-value region. This is the default state.
• Above Band — price is trading above accepted value. In Rising Value, this is constructive; in Falling Value, it is a rally to be evaluated.
• Below Band — price is trading below accepted value. In Falling Value, this is the dominant state; in Rising Value, it is a dip.

Timeframe guidance:
• 1H–4H — best balance for swing use with the default Band Length of 100.
• 15m–1H — reduce Band Length to 40–60 for intraday use.
• Daily — Band Length 100 gives a structural multi-month migration view.

Pairing suggestions:
• Higher-timeframe VMB for bias, lower-timeframe execution tools for entry.
• Combining with volume-based or anchored-VWAP tools can confirm whether value migration is participation-backed.

🔷 LIMITATIONS & TRANSPARENCY

• This is an analytical visualization tool, not a strategy. It does not backtest, does not place orders and does not generate buy / sell recommendations.
• Regime classification is based on historical midline slope. Like all rolling measures, it is a lagging read of structure — it describes what has been happening, not what will happen.
• During abrupt regime changes, the 2-bar confirmation layer introduces a small delay by design, trading reactivity for stability.
• Percentile bands are descriptive of past acceptance. Future acceptance may differ, especially around news events, regime breaks and illiquid sessions.
• The Strict Value Filter can force a Flat reading during extreme compression even when a visual direction appears present; this is intentional and protects against false regime flags.

🔶 RISK DISCLOSURE

This indicator is published for educational and analytical purposes. It is not financial advice, not a trading recommendation and not a guarantee of performance. Trading and investing involve substantial risk, including the risk of total loss. Past behaviour of any instrument does not guarantee future results. Users are solely responsible for their own decisions and should perform their own due diligence, including independent risk management and position sizing.

Published as open-source under the Mozilla Public License 2.0. Feedback, questions and discussion are welcome in the comments.

## Source Code

````pine
// -------------------------------------------------
// Value Migration Bands [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Value Migration Bands visualizes where accepted value is migrating across a
// rolling market profile proxy. The engine builds a three-layer value band
// from rolling percentiles of typical price, classifies rising, flat, and
// falling value with ATR-normalized slope, and summarizes reclaim, lost,
// location, width, slope, and migration quality in a chart-first workflow.
// V2.1 adds a price-referenced band workflow and hardens the follow-rate proof
// historically kept migrating in the shift direction.
// -------------------------------------------------

//@version=6
indicator("Value Migration Bands [AGPro Series]",
     shorttitle       = "AG Pro VMB",
     overlay          = true,
     max_lines_count  = 120,
     max_labels_count = 64,
     max_boxes_count  = 45,
     max_bars_back    = 800)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpEngine = "Band Engine"
bandLength = input.int(100, "Band Length", minval = 20, maxval = 500, group = grpEngine,
     tooltip = "Lookback window used to build the rolling accepted-value region. Longer values create slower structural bands; shorter values react faster but can be noisier.")
bandWidthMode = input.string("Balanced", "Band Width Mode", options = ["Tight", "Balanced", "Wide"], group = grpEngine,
     tooltip = "Controls the percentile range used to form the value band. Tight focuses on the accepted core, Balanced is the standard mode, and Wide captures broader participation.")
strictValueFilter = input.bool(true, "Strict Value Filter", group = grpEngine,
     tooltip = "When enabled, the band must be meaningfully wide relative to ATR before it is treated as a valid accepted-value region.")
migrationSlopeSens = input.float(0.5, "Migration Slope Sensitivity", minval = 0.1, maxval = 2.0, step = 0.1, group = grpEngine,
     tooltip = "ATR-normalized slope threshold separating Rising, Flat, and Falling Value. Lower values react faster; higher values require clearer migration.")
confirmBars = input.int(2, "Regime Confirmation Bars", minval = 1, maxval = 8, group = grpEngine,
     tooltip = "Number of consecutive bars a new migration regime must persist before becoming confirmed.")
followWindow = input.int(30, "Follow Proof Window (bars)", minval = 5, maxval = 200, group = grpEngine,
     tooltip = "Number of bars a confirmed value shift has to keep migrating in its direction within, for the Follow Rate proof. It only measures historical migration follow-through and is not a forecast.")

grpVisual = "Visuals"
showMidline = input.bool(true, "Show Midline", group = grpVisual,
     tooltip = "Shows the center of accepted value. The midline is the main reference inside the migration band.")
showFill = input.bool(true, "Show Band Fill", group = grpVisual,
     tooltip = "Displays the accepted-value band fill. This is the primary visual signature of the script.")
showBandBadge = input.bool(true, "Show Center Band Badge", group = grpVisual,
     tooltip = "Shows a centered premium badge inside the current value band with regime, score, and location context.")
showLiveTags = input.bool(true, "Show Live State Tags", group = grpVisual,
     tooltip = "Shows a compact right-edge band-width tag. The centered band badge carries the main state and score story.")
showEventLabels = input.bool(true, "Show Event Labels", group = grpVisual,
     tooltip = "Shows spaced reclaim, lost, rising, falling, and flat review labels when value context changes.")
showBackground = input.bool(false, "Show Background Tint", group = grpVisual,
     tooltip = "Adds a very subtle background tint for the active migration regime. Disabled by default for a cleaner institutional look.")
labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = grpVisual,
     tooltip = "Controls how many event labels are kept on the chart. Balanced is designed for public screenshots with context but without clutter.")
fillOpacity = input.int(88, "Band Fill Opacity", minval = 70, maxval = 98, group = grpVisual,
     tooltip = "Transparency level for the value band fill. Higher values are more transparent.")
rightTagOffset = input.int(7, "Right Tag Offset", minval = 2, maxval = 24, group = grpVisual,
     tooltip = "Horizontal offset for live right-edge labels.")
projectionBars = input.int(20, "Badge Projection Bars", minval = 8, maxval = 80, group = grpVisual,
     tooltip = "How far the current value-band badge zone projects to the right.")
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.20, maxval = 4.00, step = 0.05, group = grpVisual,
     tooltip = "ATR-based vertical offset that keeps event labels away from candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual,
     tooltip = "Controls on-chart label size.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Shows the compact panel with workflow, value state, location, migration score, band width, slope, and review context.")
panelPosition = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpPanel,
     tooltip = "Controls where the panel is anchored on the chart.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = grpPanel,
     tooltip = "Switches panel colors for dark or light chart backgrounds while keeping the AGPro blue header.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Controls panel text size.")

grpAlerts = "Alerts"
alertShiftUp = input.bool(true, "Alert: Value Shifted Up", group = grpAlerts,
     tooltip = "Creates an alert condition when the confirmed regime transitions into Rising Value.")
alertShiftDown = input.bool(true, "Alert: Value Shifted Down", group = grpAlerts,
     tooltip = "Creates an alert condition when the confirmed regime transitions into Falling Value.")
alertReclaim = input.bool(true, "Alert: Band Reclaimed", group = grpAlerts,
     tooltip = "Creates an alert condition when price returns into the accepted-value band from below.")
alertLost = input.bool(true, "Alert: Band Lost", group = grpAlerts,
     tooltip = "Creates an alert condition when price leaves the accepted-value band from inside to below.")

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
dangerColor   = color.rgb(239, 68, 68)
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
REG_FALLING = -1
REG_FLAT = 0
REG_RISING = 1

f_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_regime_text(int regimeValue) =>
    regimeValue == REG_RISING ? "Rising Value" : regimeValue == REG_FALLING ? "Falling Value" : "Flat Value"

f_regime_code(int regimeValue) =>
    regimeValue == REG_RISING ? "RISE" : regimeValue == REG_FALLING ? "FALL" : "FLAT"

f_regime_color(int regimeValue) =>
    regimeValue == REG_RISING ? bullColor : regimeValue == REG_FALLING ? bearColor : neutralColor

f_text_color(int regimeValue) =>
    regimeValue == REG_FLAT ? darkText : headerText

f_location_text(int locationValue) =>
    locationValue == 1 ? "Inside Band" : locationValue == 2 ? "Above Band" : "Below Band"

f_location_code(int locationValue) =>
    locationValue == 1 ? "INSIDE" : locationValue == 2 ? "ABOVE" : "BELOW"

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_panel_bg(string theme, bool alt) =>
    theme == "Clean Light" ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(20, 31, 52) : panelBg)

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_action_text(int regimeValue, int score, bool valid) =>
    not valid ? "Wait value" :
     regimeValue == REG_RISING and score >= 70 ? "Review rise" :
     regimeValue == REG_FALLING and score >= 70 ? "Review fall" :
     regimeValue == REG_FLAT ? "Map rotation" :
     "Track value"

f_action_color(string action, int regimeValue) =>
    action == "Review rise" or action == "Review fall" ? f_regime_color(regimeValue) :
     action == "Track value" ? accentColor :
     neutralColor

f_width_text(float widthAtr) =>
    widthAtr < 1.2 ? "Tight" : widthAtr > 2.5 ? "Wide" : "Normal"

f_score_grade(int scoreValue) =>
    scoreValue >= 88 ? "A+" : scoreValue >= 76 ? "A" : scoreValue >= 64 ? "B" : scoreValue >= 52 ? "C" : "D"

f_score_text(int scoreValue) =>
    str.tostring(scoreValue) + " " + f_score_grade(scoreValue)

f_badge_regime_title(int regimeValue) =>
    regimeValue == REG_RISING ? "Rise Value" : regimeValue == REG_FALLING ? "Fall Value" : "Flat Value"

f_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    bool alt = row % 2 == 0
    color bg = f_panel_bg(theme, alt)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = bg, text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = bg, text_size = f_size(fontSize), text_halign = text.align_right)

f_keep_event_label(array<label> labels, label item, int maxCount) =>
    array.push(labels, item)
    while array.size(labels) > maxCount
        label old = array.shift(labels)
        if not na(old)
            label.delete(old)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

panelSize = f_size(panelSizeInput)
labelSize = f_size(labelSizeInput)
maxEventLabels = labelDensity == "Detailed" ? 18 : labelDensity == "Balanced" ? 11 : 6
eventCooldownMult = labelDensity == "Detailed" ? 0.12 : labelDensity == "Balanced" ? 0.20 : 0.32

// -------------------------------------------------
// Band Engine
// -------------------------------------------------
src = hlc3
atr14 = math.max(nz(ta.atr(14), syminfo.mintick), syminfo.mintick)

pLow = bandWidthMode == "Tight" ? 30 : bandWidthMode == "Balanced" ? 25 : 15
pHigh = bandWidthMode == "Tight" ? 70 : bandWidthMode == "Balanced" ? 75 : 85

rawLower = ta.percentile_linear_interpolation(src, bandLength, pLow)
rawUpper = ta.percentile_linear_interpolation(src, bandLength, pHigh)
rawMid = (rawLower + rawUpper) / 2.0

smoothLen = int(math.max(3, math.round(bandLength / 20.0)))
lowerBand = ta.ema(rawLower, smoothLen)
upperBand = ta.ema(rawUpper, smoothLen)
midBand = ta.ema(rawMid, smoothLen)

bandWidthVal = upperBand - lowerBand
bandWidthAtr = bandWidthVal / atr14
validBand = not strictValueFilter or bandWidthAtr >= 0.80

// -------------------------------------------------
// Migration Classification
// -------------------------------------------------
slopeWindow = int(math.max(5, math.round(bandLength / 10.0)))
midSlope = (midBand - midBand[slopeWindow]) / slopeWindow
slopeAtr = midSlope / atr14
slopeThreshold = migrationSlopeSens / 10.0

regimeRaw = REG_FLAT
if validBand
    if slopeAtr > slopeThreshold
        regimeRaw := REG_RISING
    else if slopeAtr < -slopeThreshold
        regimeRaw := REG_FALLING

var int regime = REG_FLAT
var int regimeCandidate = REG_FLAT
var int regimeCandidateCount = 0

if regimeRaw == regimeCandidate
    regimeCandidateCount += 1
else
    regimeCandidate := regimeRaw
    regimeCandidateCount := 1

if regimeCandidateCount >= confirmBars
    regime := regimeCandidate

shiftedUp = regime == REG_RISING and regime[1] != REG_RISING
shiftedDown = regime == REG_FALLING and regime[1] != REG_FALLING
shiftedFlat = regime == REG_FLAT and regime[1] != REG_FLAT

// -------------------------------------------------
// Location And Events
// -------------------------------------------------
insideBand = close <= upperBand and close >= lowerBand
aboveBand = close > upperBand
belowBand = close < lowerBand

var int locState = 0
var int prevLoc = 0
locState := insideBand ? 1 : aboveBand ? 2 : belowBand ? -2 : prevLoc

reclaimEvent = prevLoc == -2 and locState == 1
lostEvent = prevLoc == 1 and locState == -2
prevLoc := locState

eventCooldown = int(math.max(10, math.round(bandLength * eventCooldownMult)))
eventAtrDist = labelDensity == "Detailed" ? 1.0 : labelDensity == "Balanced" ? 1.25 : 1.70
var int lastEventBar = -9999
var float lastEventPrice = na

barsOk = bar_index - lastEventBar >= eventCooldown
distOk = na(lastEventPrice) or math.abs(close - lastEventPrice) >= eventAtrDist * atr14
canPlotEvent = barsOk and distOk

reclaimOk = barstate.isconfirmed and reclaimEvent and regime != REG_FALLING and canPlotEvent
lostOk = barstate.isconfirmed and lostEvent and regime != REG_RISING and canPlotEvent
shiftOk = barstate.isconfirmed and (shiftedUp or shiftedDown or shiftedFlat) and canPlotEvent

// -------------------------------------------------
// Score
// -------------------------------------------------
slopeScore = f_clamp(math.abs(slopeAtr) / math.max(slopeThreshold * 2.5, 0.001), 0.0, 1.0)
widthScore = f_clamp(bandWidthAtr / 2.5, 0.0, 1.0)
locationScore = locState == 1 ? 1.0 : 0.45
validScore = validBand ? 1.0 : 0.25
migrationScore = int(math.round((slopeScore * 0.38 + widthScore * 0.24 + locationScore * 0.20 + validScore * 0.18) * 100.0))
scoreReady = not na(migrationScore)
actionText = f_action_text(regime, migrationScore, validBand)
actionColor = f_action_color(actionText, regime)
workflowText = not validBand ? "Wait value" : locState == 1 and regime == REG_FLAT ? "Map rotation" : locState == 1 ? "Review band" : locState == 2 ? "Review premium" : "Review discount"
reviewText = f_location_code(locState) + " / " + f_regime_code(regime) + " / " + f_score_text(migrationScore)

// -------------------------------------------------
// Migration follow-rate proof (Confirm Rate)
// -------------------------------------------------
var int   migTotal  = 0
var int   migWon     = 0
var bool  migPend    = false
var int   migDir     = 0
var float migAnchor  = na
var int   migLeft    = 0
var float migMargin  = na

if barstate.isconfirmed
    if migPend and not na(migAnchor)
        bool favHit = migDir == 1 ? midBand >= migAnchor + migMargin : midBand <= migAnchor - migMargin
        bool advHit = migDir == 1 ? midBand <= migAnchor - migMargin : midBand >= migAnchor + migMargin
        if favHit
            migTotal += 1
            migWon += 1
            migPend := false
        else if advHit
            migTotal += 1
            migPend := false
        else
            migLeft -= 1
            if migLeft <= 0
                migTotal += 1
                migPend := false
    int newShiftDir = shiftedUp ? 1 : shiftedDown ? -1 : 0
    if newShiftDir != 0
        if migPend and newShiftDir != migDir
            migTotal += 1
            migPend := false
        if not migPend
            migPend := true
            migDir := newShiftDir
            migAnchor := midBand
            migMargin := atr14 * 0.75
            migLeft := followWindow

float migRate = migTotal > 0 ? migWon / migTotal * 100.0 : na

// -------------------------------------------------
// Plotting
// -------------------------------------------------
regimeColor = f_regime_color(regime)
pUpper = plot(upperBand, "Upper Band", color = color.new(regimeColor, 44), linewidth = 1)
pLower = plot(lowerBand, "Lower Band", color = color.new(regimeColor, 44), linewidth = 1)
plot(showMidline ? midBand : na, "Middle Line", color = color.new(regimeColor, 12), linewidth = 2)

fillAlpha = regime == REG_FLAT ? math.min(fillOpacity + 5, 96) : fillOpacity
fill(pUpper, pLower, color = showFill ? color.new(regimeColor, fillAlpha) : na, title = "Value Migration Fill")
bgcolor(showBackground and validBand ? color.new(regimeColor, 94) : na, title = "Migration Background")

// -------------------------------------------------
// Center Band Badge
// -------------------------------------------------
var box bandBadgeBox = na
var label bandBadge = na

badgeLeft = math.max(bar_index - math.min(projectionBars, 28), 0)
badgeRight = bar_index + math.min(projectionBars, 22)
badgeCenterX = int(math.round((badgeLeft + badgeRight) * 0.5))
badgeY = midBand
badgeText = f_regime_code(regime) + " | " + f_location_code(locState) + " | " + f_score_text(migrationScore) + " | W " + str.tostring(bandWidthAtr, "0.00") + "x"
badgeBg = validBand ? color.new(regimeColor, 0) : color.new(panelLabelCol, 0)
badgeBoxBg = validBand ? color.new(regimeColor, fillAlpha) : color.new(panelLabelCol, 92)
badgeTextColor = validBand ? f_text_color(regime) : headerText
badgeBorderWidth = migrationScore >= 70 ? 2 : 1

if barstate.islast and showBandBadge and showFill and scoreReady
    if na(bandBadgeBox)
        bandBadgeBox := box.new(badgeLeft, upperBand, badgeRight, lowerBand, xloc = xloc.bar_index, border_color = color.new(regimeColor, 34), border_width = badgeBorderWidth, bgcolor = badgeBoxBg, text = "")
    else
        box.set_lefttop(bandBadgeBox, badgeLeft, upperBand)
        box.set_rightbottom(bandBadgeBox, badgeRight, lowerBand)
        box.set_border_color(bandBadgeBox, color.new(regimeColor, 34))
        box.set_border_width(bandBadgeBox, badgeBorderWidth)
        box.set_bgcolor(bandBadgeBox, badgeBoxBg)
        box.set_text(bandBadgeBox, "")
    if na(bandBadge)
        bandBadge := label.new(badgeCenterX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = badgeBg, textcolor = badgeTextColor, size = labelSize, textalign = text.align_center)
    else
        label.set_x(bandBadge, badgeCenterX)
        label.set_y(bandBadge, badgeY)
        label.set_text(bandBadge, badgeText)
        label.set_color(bandBadge, badgeBg)
        label.set_textcolor(bandBadge, badgeTextColor)
        label.set_size(bandBadge, labelSize)
else if barstate.islast
    if not na(bandBadgeBox)
        box.delete(bandBadgeBox)
        bandBadgeBox := na
    f_delete_label(bandBadge)
    bandBadge := na

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
var array<label> eventLabels = array.new_label()

if showEventLabels and shiftOk and scoreReady
    string txt = f_badge_regime_title(regime) + " | " + f_score_text(migrationScore)
    float y = regime == REG_FALLING ? high + atr14 * labelOffsetAtr : low - atr14 * labelOffsetAtr
    label lb = label.new(bar_index, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = regime == REG_FALLING ? label.style_label_down : label.style_label_up, color = color.new(regimeColor, 4), textcolor = f_text_color(regime), size = labelSize)
    f_keep_event_label(eventLabels, lb, maxEventLabels)
    lastEventBar := bar_index
    lastEventPrice := close

if showEventLabels and reclaimOk and scoreReady
    label lb = label.new(bar_index, low - atr14 * labelOffsetAtr, "RECLAIM | " + f_score_text(migrationScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(bullColor, 4), textcolor = headerText, size = labelSize, textalign = text.align_center)
    f_keep_event_label(eventLabels, lb, maxEventLabels)
    lastEventBar := bar_index
    lastEventPrice := close

if showEventLabels and lostOk and scoreReady
    label lb = label.new(bar_index, high + atr14 * labelOffsetAtr, "LOST | " + f_score_text(migrationScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(bearColor, 4), textcolor = headerText, size = labelSize, textalign = text.align_center)
    f_keep_event_label(eventLabels, lb, maxEventLabels)
    lastEventBar := bar_index
    lastEventPrice := close

// -------------------------------------------------
// Live Right-Edge Tags
// -------------------------------------------------
var label upperTag = na
var label valueTag = na
var label lowerTag = na

if showLiveTags and barstate.islast
    tagX = bar_index + rightTagOffset
    if na(upperTag)
        upperTag := label.new(tagX + 2, upperBand, "UPPER " + f_price(upperBand), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(regimeColor, 4), textcolor = f_text_color(regime), size = labelSize)
        valueTag := label.new(tagX + 10, midBand, "VALUE " + f_price(midBand), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 4), textcolor = headerText, size = labelSize)
        lowerTag := label.new(tagX + 18, lowerBand, "LOWER " + f_price(lowerBand), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(regimeColor, 4), textcolor = f_text_color(regime), size = labelSize)
    else
        label.set_xy(upperTag, tagX + 2, upperBand)
        label.set_text(upperTag, "UPPER " + f_price(upperBand))
        label.set_color(upperTag, color.new(regimeColor, 4))
        label.set_textcolor(upperTag, f_text_color(regime))
        label.set_size(upperTag, labelSize)
        label.set_xy(valueTag, tagX + 10, midBand)
        label.set_text(valueTag, "VALUE " + f_price(midBand))
        label.set_size(valueTag, labelSize)
        label.set_xy(lowerTag, tagX + 18, lowerBand)
        label.set_text(lowerTag, "LOWER " + f_price(lowerBand))
        label.set_color(lowerTag, color.new(regimeColor, 4))
        label.set_textcolor(lowerTag, f_text_color(regime))
        label.set_size(lowerTag, labelSize)
else if not showLiveTags
    f_delete_label(upperTag)
    f_delete_label(valueTag)
    f_delete_label(lowerTag)
    upperTag := na
    valueTag := na
    lowerTag := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
stateText = f_regime_text(regime)
locText = f_location_text(locState)
widthText = f_width_text(bandWidthAtr)
slopeText = (slopeAtr >= 0.0 ? "+" : "") + str.tostring(slopeAtr, "0.000")
theme = panelTheme
panelFrame = f_panel_border(theme)
migRateText = migTotal > 0 ? str.tostring(math.round(migRate)) + "% (" + str.tostring(migTotal) + ")" : "Building"
migRateCol = na(migRate) ? f_panel_value(theme) : migRate >= 55.0 ? bullColor : migRate >= 45.0 ? neutralColor : bearColor

var table panel = na
var string panelKey = ""
activePanelKey = panelPosition + "|" + panelTheme

if barstate.islast
    if showPanel
        if na(panel) or panelKey != activePanelKey
            if not na(panel)
                table.delete(panel)
            panel := table.new(f_pos(panelPosition), 2, 8, bgcolor = f_panel_bg(theme, false), border_color = panelFrame, border_width = 1, frame_color = panelFrame, frame_width = 1)
            panelKey := activePanelKey
        table.clear(panel, 0, 0, 1, 7)
        table.cell(panel, 0, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Value Migration Bands", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        f_row(panel, 1, "Workflow", workflowText, actionColor, theme, panelSizeInput)
        f_row(panel, 2, "Value State", stateText, regimeColor, theme, panelSizeInput)
        f_row(panel, 3, "Band Location", locText, locState == 1 ? f_panel_value(theme) : locState == 2 ? bullColor : bearColor, theme, panelSizeInput)
        f_row(panel, 4, "Migration Score", str.tostring(migrationScore) + " / 100 " + f_score_grade(migrationScore), migrationScore >= 70 ? accentColor : neutralColor, theme, panelSizeInput)
        f_row(panel, 5, "Follow Rate", migRateText, migRateCol, theme, panelSizeInput)
        f_row(panel, 6, "Width / Slope", widthText + " " + str.tostring(bandWidthAtr, "0.00") + "x / " + slopeText, regimeColor, theme, panelSizeInput)
        f_row(panel, 7, "Review", reviewText, actionColor, theme, panelSizeInput)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelKey := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertShiftUp and shiftedUp, "Value Shifted Up", "Value Migration Bands: confirmed value regime shifted up. This is an attention marker, not a trade instruction.")
alertcondition(alertShiftDown and shiftedDown, "Value Shifted Down", "Value Migration Bands: confirmed value regime shifted down. This is an attention marker, not a trade instruction.")
alertcondition(alertReclaim and reclaimOk, "Band Reclaimed", "Value Migration Bands: price returned into the accepted-value band from below.")
alertcondition(alertLost and lostOk, "Band Lost", "Value Migration Bands: price left the accepted-value band from inside to below.")

// Hidden reference plot
plot(migRate, "Migration Follow Rate", display = display.none)
````
