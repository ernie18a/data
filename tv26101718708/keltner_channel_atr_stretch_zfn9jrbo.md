# Keltner Channel ATR Stretch

- url: https://www.tradingview.com/script/zFn9jrBO-Keltner-Channel-ATR-Stretch/
- type: indicator
- pine_id: PUB;e444cc9540f54f6fac3e91b4b94a592f
- version: 1.0

## Description

Keltner Channel ATR Stretch is a Keltner Channel variant designed to show trend bias, price stretch, and volatility width in one compact view.

The script uses an EMA basis with ATR-scaled upper and lower bands. In addition to the channel itself, it normalizes the selected Source's distance from the EMA basis as Stretch, normalizes the EMA basis slope in ATR units as Bias, and ranks the current channel width against its recent min-max range as Width Rank.

The goal is not to create trade signals. The goal is to make the current chart state easier to read: whether price is inside the channel, moving with a trend bias, pulling back toward the basis, stretching beyond the outer band, reaching an extreme band, or returning inside the channel after an outside move.

Dashboard reading:
Bias shows the EMA basis direction normalized by ATR:
Bullish, Bearish, or Neutral.

Position shows where the selected Source is relative to the channel:
Trend Zone, Pullback, Upper Stretch, Lower Stretch, Extreme, or Inside.

Volatility shows the current channel width regime:
Quiet, Normal, or Expanded.

Stretch shows the distance from the EMA basis in outer-channel units.
A value near +1 means price is near the upper outer band.
A value near -1 means price is near the lower outer band.

Slope shows the EMA basis slope in ATR units.

Width Rank shows the current channel width relative to its recent min-max range.
It is a simple 0-100 rank of the current width inside its own recent range, not a statistical percentile.

How it works:
The basis is an EMA of the selected Source.
The outer bands are calculated as:
Basis plus or minus ATR multiplied by the ATR Multiplier.

The inner bands are a fractional zone inside the outer channel.
The optional extreme bands are a wider reference zone outside the outer channel.

Stretch is calculated as:
Source minus Basis, divided by the outer channel half-width.

Slope is calculated as:
Current EMA basis minus the basis from the selected lookback, divided by ATR.

Width Rank compares the current channel width to the lowest and highest channel width over the selected Width Rank Lookback.

Markers and alerts:
Upper stretch and lower stretch mark movement beyond the outer bands.
Upper extreme and lower extreme mark movement beyond the optional extreme band level.
Upper return inside and lower return inside mark when the selected Source moves back inside the outer channel after being outside it.
Trend bias changed marks a change in the ATR-normalized EMA basis direction.
Width regime changed marks a change between Quiet, Normal, and Expanded width states.

The Confirmed bars only setting is enabled by default. When it is enabled, markers and alerts evaluate only on closed bars. The dashboard reflects the current chart state, including the still-forming bar.

This is not a trading system. It is a visual analysis tool for reading channel position, trend bias, and volatility context. It does not provide trade instructions, entries, exits, or performance claims.

Limitations:
Keltner Channels are volatility-based bands and can expand or contract as ATR changes.
A stretch beyond a band does not necessarily mean price must reverse.
A quiet width regime does not guarantee expansion.
A bullish or bearish bias does not predict future direction.
Use this tool together with your own market context and risk management.

No financial advice.

This open-source script was written from scratch using Pine Script built-ins. No third-party Pine code was reused.


日本語補足:

Keltner Channel ATR Stretch は、EMAを中心にATR幅のチャネルを表示しながら、価格の伸び、EMAの傾き、チャネル幅の状態を同時に確認するためのインジケーターです。

右上のDashboardでは、Bias、Position、Volatilityを中心に、現在のチャート状態をすばやく確認できます。

Bias はATRで正規化したEMAの傾きです。
Position は価格がチャネル内、トレンドゾーン、押し目、上方向または下方向の伸び、極端な伸びのどこにあるかを示します。
Volatility はチャネル幅がQuiet、Normal、Expandedのどの状態にあるかを示します。

このスクリプトは売買システムではありません。
BUY/SELL、エントリー、利確、損切りを指示するものではなく、トレンド・行き過ぎ・ボラティリティの状態を読みやすくするための視覚補助ツールです。

## Source Code

````pine
//@version=6
indicator("Keltner Channel ATR Stretch", shorttitle = "KC ATR Stretch", overlay = true)

// ============================================================================
// CONSTANTS
// ============================================================================
const string GRP_CORE   = "Core Keltner"
const string GRP_LENS   = "Stretch & Slope"
const string GRP_WIDTH  = "Channel Width Regime"
const string GRP_SIGNAL = "Markers & Alerts"
const string GRP_VIS    = "Visuals"
const string GRP_STYLE  = "Style & Colors"

const string POS_TR = "Top Right"
const string POS_BR = "Bottom Right"
const string POS_TL = "Top Left"
const string POS_BL = "Bottom Left"

const string TXT_SMALL  = "Small"
const string TXT_NORMAL = "Normal"

// ============================================================================
// INPUTS
// ============================================================================
// --- Core Keltner Channel ---
source        = input.source(close, "Source", group = GRP_CORE, tooltip = "Price series used for the basis, stretch, and state classification.")
basisLength   = input.int(20, "Basis EMA Length", minval = 1, group = GRP_CORE, tooltip = "Length of the EMA centerline (basis).")
atrLength     = input.int(20, "ATR Length", minval = 1, group = GRP_CORE, tooltip = "Length of the ATR that sets the channel width.")
multiplier    = input.float(1.5, "ATR Multiplier", minval = 0.1, step = 0.1, group = GRP_CORE, tooltip = "Distance of the outer bands from the basis, measured in ATR units.")

// --- Stretch & Slope ---
innerRatio     = input.float(0.5, "Inner Zone Ratio", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_LENS, tooltip = "Inner band distance as a fraction of the outer band (0 = at basis, 1 = at outer band).")
extremeRatio   = input.float(1.5, "Extreme Zone Ratio", minval = 1.0, step = 0.1, group = GRP_LENS, tooltip = "Extreme band distance as a multiple of the outer band (>= 1).")
slopeLookback  = input.int(5, "Slope Lookback", minval = 1, group = GRP_LENS, tooltip = "Number of bars used to measure the basis slope.")
slopeThreshold = input.float(0.25, "Slope Threshold (ATR)", minval = 0.0, step = 0.05, group = GRP_LENS, tooltip = "Minimum ATR-normalized basis slope required to call a trend bias.")

// --- Channel Width Regime ---
widthLookback     = input.int(100, "Width Rank Lookback", minval = 2, group = GRP_WIDTH, tooltip = "Bars used to rank current channel width against its own recent range.")
quietThreshold    = input.float(20, "Quiet Threshold", minval = 0, maxval = 100, step = 1, group = GRP_WIDTH, tooltip = "Width Rank below this value is labeled Quiet.")
expandedThreshold = input.float(80, "Expanded Threshold", minval = 0, maxval = 100, step = 1, group = GRP_WIDTH, tooltip = "Width Rank above this value is labeled Expanded.")

// --- Markers & Alerts ---
confirmedOnly = input.bool(true, "Confirmed bars only", group = GRP_SIGNAL, tooltip = "When on, markers and alerts evaluate only on closed bars to avoid intrabar repainting.")
showStretch   = input.bool(true, "Show stretch markers", group = GRP_SIGNAL)
showReturnInside = input.bool(true, "Show return-inside markers", group = GRP_SIGNAL)

// --- Visuals ---
showInner     = input.bool(true,  "Show Inner Channel", group = GRP_VIS)
showExtreme   = input.bool(false, "Show Extreme Channel", group = GRP_VIS)
showFill      = input.bool(true,  "Show Fill", group = GRP_VIS)
colorBars     = input.bool(false, "Color Bars", group = GRP_VIS)
showDashboard = input.bool(true,  "Show Dashboard", group = GRP_VIS)
dashPosInput  = input.string(POS_TR, "Dashboard Position", options = [POS_TR, POS_BR, POS_TL, POS_BL], group = GRP_VIS)

// --- Style & Colors ---
basisColor   = input.color(#f5a623, "Basis", group = GRP_STYLE)
bandColor    = input.color(#2962ff, "Outer Bands", group = GRP_STYLE)
innerColor   = input.color(#5b9cf6, "Inner Bands", group = GRP_STYLE)
extremeColor = input.color(#9598a1, "Extreme Bands", group = GRP_STYLE)
bullColor    = input.color(#26a69a, "Bullish Tint", group = GRP_STYLE)
bearColor    = input.color(#ef5350, "Bearish Tint", group = GRP_STYLE)
neutralColor = input.color(#787b86, "Neutral Tint", group = GRP_STYLE)

dashTextSizeInput = input.string(TXT_NORMAL, "Dashboard Text Size", options = [TXT_SMALL, TXT_NORMAL], group = GRP_STYLE)
dashBgColor       = input.color(#131722, "Dashboard Background", group = GRP_STYLE)
dashHeaderBg      = input.color(#2a2e39, "Dashboard Header Background", group = GRP_STYLE)
dashLabelColor    = input.color(#b2b5be, "Dashboard Label Text", group = GRP_STYLE)
dashValueColor    = input.color(color.white, "Dashboard Value Text", group = GRP_STYLE)
dashBorderColor   = input.color(#434651, "Dashboard Border", group = GRP_STYLE)
dashBgTransp      = input.int(15, "Dashboard Background Transparency", minval = 0, maxval = 90, group = GRP_STYLE)
dashStateTransp   = input.int(18, "Dashboard State Cell Transparency", minval = 0, maxval = 85, group = GRP_STYLE)

// ============================================================================
// FUNCTIONS
// ============================================================================
// Map the dashboard position string to a table position constant.
posFromInput(string p) =>
    switch p
        POS_TR => position.top_right
        POS_BR => position.bottom_right
        POS_TL => position.top_left
        => position.bottom_left

// Map the dashboard text size string to a built-in text size constant.
textSizeFromInput(string s) =>
    s == TXT_SMALL ? size.small : size.normal

// Format a number with an explicit sign: "+1.25", "0.00", "-0.74".
// The sign is decided after rounding, so values that round to zero stay unsigned.
signedStr(float v, string fmt) =>
    string s = str.tostring(math.abs(v), fmt)
    bool isUnsigned = na(v) or s == str.tostring(0.0, fmt)
    isUnsigned ? s : v > 0 ? "+" + s : "-" + s

// ============================================================================
// CALCULATIONS
// ============================================================================
// Validate width-regime thresholds.
if quietThreshold >= expandedThreshold
    runtime.error("Quiet Threshold must be lower than Expanded Threshold.")

// Keltner core: an EMA basis with an ATR-scaled channel around it.
basis     = ta.ema(source, basisLength)
atrValue  = ta.atr(atrLength)
safeAtr   = math.max(atrValue, syminfo.mintick)            // floor ATR so later divisions stay finite
halfWidth = safeAtr * multiplier                           // outer band distance, in price units

upper        = basis + halfWidth
lower        = basis - halfWidth
innerUpper   = basis + halfWidth * innerRatio
innerLower   = basis - halfWidth * innerRatio
extremeUpper = basis + halfWidth * extremeRatio
extremeLower = basis - halfWidth * extremeRatio

// Stretch metrics: put price position and trend on a normalized, comparable scale.
stretchUnit   = (source - basis) / math.max(halfWidth, syminfo.mintick) // +1 sits on the outer band
stretchAtr    = (source - basis) / safeAtr                              // deviation in raw ATR multiples
basisSlopeAtr = (basis - basis[slopeLookback]) / safeAtr                // ATR-normalized slope of the basis

// Trend bias as an integer so comparisons stay simple and na-safe: 1 bull, -1 bear, 0 neutral.
trendState = basisSlopeAtr > slopeThreshold ? 1 : basisSlopeAtr < -slopeThreshold ? -1 : 0

// Channel Width Rank: where current width sits inside its own recent min-max range (0-100).
channelWidth = upper - lower
lowestWidth  = ta.lowest(channelWidth, widthLookback)
highestWidth = ta.highest(channelWidth, widthLookback)
widthRange   = math.max(highestWidth - lowestWidth, syminfo.mintick)    // guard against a zero range
widthRank    = 100.0 * (channelWidth - lowestWidth) / widthRange

// Width regime as an integer: -1 quiet, 0 normal, 1 expanded.
widthRegime = widthRank < quietThreshold ? -1 : widthRank > expandedThreshold ? 1 : 0

// Price series used for all state classification, so channel position,
// stretch values, markers, and alerts all refer to the same selected Source.
statePrice = source

// Live (raw) state for the dashboard - reflects the currently developing bar.
rawUpperStretch = statePrice > upper
rawLowerStretch = statePrice < lower
rawUpperExtreme = statePrice > extremeUpper
rawLowerExtreme = statePrice < extremeLower

// Position classification for the dashboard, evaluated on the live bar.
isExtreme       = statePrice > extremeUpper or statePrice < extremeLower
isUpperStretch  = statePrice > upper and statePrice <= extremeUpper
isLowerStretch  = statePrice < lower and statePrice >= extremeLower
isBullTrendZone = trendState == 1 and statePrice >= basis and statePrice <= upper
isBearTrendZone = trendState == -1 and statePrice <= basis and statePrice >= lower
isBullPullback  = trendState == 1 and statePrice < basis and statePrice >= innerLower
isBearPullback  = trendState == -1 and statePrice > basis and statePrice <= innerUpper

// A return inside requires price to be back within the outer channel, not merely
// past the band it crossed (a full break to the opposite side does not count).
insideChannel = statePrice <= upper and statePrice >= lower

// Warm-up guards: suppress state-change alerts until the lookbacks have data.
trendReady = bar_index > slopeLookback
widthReady = bar_index > widthLookback

// Gated state for markers and alerts - optionally requires a closed bar (no repaint).
confirmedOk        = confirmedOnly ? barstate.isconfirmed : true
upperStretch       = confirmedOk and rawUpperStretch
lowerStretch       = confirmedOk and rawLowerStretch
upperExtreme       = confirmedOk and rawUpperExtreme
lowerExtreme       = confirmedOk and rawLowerExtreme
upperStretchOnly   = upperStretch and not upperExtreme
lowerStretchOnly   = lowerStretch and not lowerExtreme
upperReentry       = confirmedOk and insideChannel and statePrice[1] > upper[1]
lowerReentry       = confirmedOk and insideChannel and statePrice[1] < lower[1]
trendBiasChanged   = confirmedOk and trendReady and trendState != trendState[1]
widthRegimeChanged = confirmedOk and widthReady and widthRegime != widthRegime[1]

// ============================================================================
// VISUALS
// ============================================================================
// Core bands. Basis, Upper and Lower are always drawn; inner/extreme are optional.
pBasis = plot(basis, "Basis", color = color.new(basisColor, 0), linewidth = 2)
pUpper = plot(upper, "Upper", color = color.new(bandColor, 0), linewidth = 1)
pLower = plot(lower, "Lower", color = color.new(bandColor, 0), linewidth = 1)
plot(showInner ? innerUpper : na, "Inner Upper", color = color.new(innerColor, 35), linewidth = 1)
plot(showInner ? innerLower : na, "Inner Lower", color = color.new(innerColor, 35), linewidth = 1)
plot(showExtreme ? extremeUpper : na, "Extreme Upper", color = color.new(extremeColor, 25), linewidth = 1)
plot(showExtreme ? extremeLower : na, "Extreme Lower", color = color.new(extremeColor, 25), linewidth = 1)

// Data Window readouts so the underlying values can be checked bar by bar.
plot(stretchUnit, "Stretch Unit", display = display.data_window)
plot(basisSlopeAtr, "Basis Slope ATR", display = display.data_window)
plot(widthRank, "Width Rank", display = display.data_window)

// Subtle directional fill: upper half vs lower half of the channel, split at the basis.
fill(pUpper, pBasis, color = showFill ? color.new(bearColor, 90) : na, title = "Upper Half Fill")
fill(pBasis, pLower, color = showFill ? color.new(bullColor, 90) : na, title = "Lower Half Fill")

// Channel state markers.
plotshape(showStretch and upperStretchOnly, title = "Upper Stretch", style = shape.triangledown, location = location.abovebar, color = color.new(bandColor, 0), size = size.tiny)
plotshape(showStretch and lowerStretchOnly, title = "Lower Stretch", style = shape.triangleup,   location = location.belowbar, color = color.new(bandColor, 0), size = size.tiny)
plotshape(showStretch and upperExtreme, title = "Upper Extreme", style = shape.diamond, location = location.abovebar, color = color.new(extremeColor, 0), size = size.tiny)
plotshape(showStretch and lowerExtreme, title = "Lower Extreme", style = shape.diamond, location = location.belowbar, color = color.new(extremeColor, 0), size = size.tiny)
plotshape(showReturnInside and upperReentry, title = "Upper Return Inside", style = shape.xcross, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)
plotshape(showReturnInside and lowerReentry, title = "Lower Return Inside", style = shape.xcross, location = location.belowbar, color = color.new(neutralColor, 0), size = size.tiny)

// Optional bar coloring by trend bias (off by default to keep the chart calm).
barColorValue = colorBars ? (trendState == 1 ? bullColor : trendState == -1 ? bearColor : neutralColor) : na
barcolor(barColorValue, title = "Trend Bias Bars")

// --- Dashboard ---
var table dash = table.new(
     posFromInput(dashPosInput),
     2,
     7,
     bgcolor = color.new(dashBgColor, dashBgTransp),
     frame_color = color.new(dashBorderColor, 0),
     frame_width = 1,
     border_color = color.new(dashBorderColor, 35),
     border_width = 1)

// Draw on the last bar only to keep the table cheap. Values reflect the live bar;
// markers and alerts follow the "Confirmed bars only" setting instead.
if showDashboard and barstate.islast
    string dashTextSize = textSizeFromInput(dashTextSizeInput)
    color  labelText    = color.new(dashLabelColor, 0)
    color  valueText    = color.new(dashValueColor, 0)
    color  headerBg     = color.new(dashHeaderBg, 0)

    string labelBias       = trendState == 1 ? "Bullish" : trendState == -1 ? "Bearish" : "Neutral"
    string labelPosition   = isExtreme ? "Extreme" : isUpperStretch ? "Upper Stretch" : isLowerStretch ? "Lower Stretch" : (isBullTrendZone or isBearTrendZone) ? "Trend Zone" : (isBullPullback or isBearPullback) ? "Pullback" : "Inside"
    string labelVolatility = widthRegime == -1 ? "Quiet" : widthRegime == 1 ? "Expanded" : "Normal"

    color tintBias       = trendState == 1 ? bullColor : trendState == -1 ? bearColor : neutralColor
    color tintPosition   = isExtreme ? extremeColor : isUpperStretch ? bearColor : isLowerStretch ? bullColor : isBullTrendZone ? bullColor : isBearTrendZone ? bearColor : (isBullPullback or isBearPullback) ? basisColor : neutralColor
    color tintVolatility = widthRegime == 1 ? basisColor : neutralColor

    // Numeric readouts, guarded so limited history shows "n/a" instead of "NaN".
    string stretchText = na(stretchUnit) ? "n/a" : signedStr(stretchUnit, "0.00") + "x"
    string slopeText   = na(basisSlopeAtr) ? "n/a" : signedStr(basisSlopeAtr, "0.00") + " ATR"
    string widthText   = na(widthRank) ? "n/a" : str.tostring(widthRank, "0") + "%"
    string stretchTip  = "Distance from the basis in outer-channel units (+1 = upper band). Raw ATR distance: " + (na(stretchAtr) ? "n/a" : signedStr(stretchAtr, "0.00"))

    // Header row
    table.cell(dash, 0, 0, "Keltner Channel", text_color = valueText, text_size = dashTextSize, text_halign = text.align_left, bgcolor = headerBg)
    table.cell(dash, 1, 0, "ATR Stretch", text_color = valueText, text_size = dashTextSize, text_halign = text.align_right, bgcolor = headerBg)
    // State rows
    table.cell(dash, 0, 1, "Bias", text_color = labelText, text_size = dashTextSize, text_halign = text.align_left)
    table.cell(dash, 1, 1, labelBias, text_color = valueText, text_size = dashTextSize, text_halign = text.align_right, bgcolor = color.new(tintBias, dashStateTransp), tooltip = "EMA basis direction, slope normalized by ATR.")
    table.cell(dash, 0, 2, "Position", text_color = labelText, text_size = dashTextSize, text_halign = text.align_left)
    table.cell(dash, 1, 2, labelPosition, text_color = valueText, text_size = dashTextSize, text_halign = text.align_right, bgcolor = color.new(tintPosition, dashStateTransp), tooltip = "Price location relative to the channel: trend zone, pullback, stretched, extreme, or inside.")
    table.cell(dash, 0, 3, "Volatility", text_color = labelText, text_size = dashTextSize, text_halign = text.align_left)
    table.cell(dash, 1, 3, labelVolatility, text_color = valueText, text_size = dashTextSize, text_halign = text.align_right, bgcolor = color.new(tintVolatility, dashStateTransp), tooltip = "Channel width regime from Width Rank.")
    // Numeric rows
    table.cell(dash, 0, 4, "Stretch", text_color = labelText, text_size = dashTextSize, text_halign = text.align_left)
    table.cell(dash, 1, 4, stretchText, text_color = valueText, text_size = dashTextSize, text_halign = text.align_right, tooltip = stretchTip)
    table.cell(dash, 0, 5, "Slope", text_color = labelText, text_size = dashTextSize, text_halign = text.align_left)
    table.cell(dash, 1, 5, slopeText, text_color = valueText, text_size = dashTextSize, text_halign = text.align_right, tooltip = "EMA basis slope over the lookback, in ATR units.")
    table.cell(dash, 0, 6, "Width Rank", text_color = labelText, text_size = dashTextSize, text_halign = text.align_left)
    table.cell(dash, 1, 6, widthText, text_color = valueText, text_size = dashTextSize, text_halign = text.align_right, tooltip = "Current channel width relative to its recent min-max range.")

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(upperStretchOnly, "Upper stretch", "Upper stretch detected")
alertcondition(lowerStretchOnly, "Lower stretch", "Lower stretch detected")
alertcondition(upperExtreme, "Upper extreme stretch", "Upper extreme stretch detected")
alertcondition(lowerExtreme, "Lower extreme stretch", "Lower extreme stretch detected")
alertcondition(upperReentry, "Upper return inside", "Upper return inside detected")
alertcondition(lowerReentry, "Lower return inside", "Lower return inside detected")
alertcondition(trendBiasChanged, "Trend bias changed", "Trend bias changed")
alertcondition(widthRegimeChanged, "Width regime changed", "Volatility width regime changed")
````
