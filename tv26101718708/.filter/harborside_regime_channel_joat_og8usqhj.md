# Harborside Regime Channel [JOAT]

- url: https://www.tradingview.com/script/Og8uSqhJ-Harborside-Regime-Channel-JOAT/
- type: indicator
- pine_id: PUB;d78f75e45d514da891446dfca7955997
- version: 1.0

## Description

[b]Harborside Regime Channel [JOAT][/b]

[b]Introduction[/b]

Harborside Regime Channel is an open-source regime-mapping indicator built to classify whether the market is expanding, compressing, reclaiming balance, or losing structural support inside a live adaptive channel.

The script is designed for traders who need context before they interpret any other signal.

Instead of asking only whether price is above or below a moving average, Harborside studies a pivot-fed centerline, adaptive outer rails, higher-timeframe directional agreement, and volatility compression state at the same time.

The result is a channel that behaves more like an institutional market map than a simple trend overlay.

The problem Harborside solves is regime clarity.

Many trend tools keep printing directional color even while the market is actually compressing inside a narrowing structure.

Many channel tools show a band but do not explain whether that band is healthy, fragile, extended, or aligned with higher-timeframe pressure.

Harborside addresses that by combining channel structure, expansion behavior, and higher-timeframe bias in one chart-first framework.

[image]https://www.tradingview.com/x/ecvPg2nh/[/image]

[b]Core Concepts[/b]

[b]1. Pivot-Fed Structural Center[/b]

Harborside does not anchor its regime center to a fixed moving average alone.

Instead, confirmed swing highs and swing lows are used to build a rolling center reference.

That center is then smoothed to create a structural balance line.

This matters because the center is linked to confirmed market geometry rather than only to lagging price averages.

The channel therefore breathes with the underlying structure of the market.

[b]2. Adaptive Outer Rails[/b]

The upper and lower rails are derived from ATR-scaled expansion around the structural center.

This means the channel naturally widens when volatility expands and contracts when price compresses.

Because the rails are smoothed, they remain readable instead of flickering excessively during intrabar noise.

This creates a cleaner map for determining whether price is stretching, reverting, or breaking into a new directional phase.

[b]3. Regime Flips on Confirmed Structural Breaks[/b]

A bullish regime is not assigned merely because price is green for a few bars.

A regime flip occurs when price confirms through the adaptive outer band in the relevant direction.

That regime is then maintained until the opposing side is confirmed.

This makes the indicator more stable than reactive color-on-close style tools.

[b]4. Compression Detection[/b]

Harborside measures band width relative to its own historical baseline.

When the band compresses below the configured threshold, the script identifies a meaningful reduction in expansion state.

This compression state is important because trend-following logic behaves very differently when the market is coiled than when it is already moving freely.

Compression is shown directly on the chart and carried into the dashboard state.

[b]5. Projection Rails[/b]

The script extends projected center, upper, and lower rails forward using current center slope and ATR-scaled projection logic.

These projected rails are not predictions in the magical sense.

They are forward references showing where the current regime geometry would continue if the active slope persists.

That gives the trader a usable visual frame for stretch, continuation, and mean-reversion decisions.

[b]6. Higher-Timeframe Bias Alignment[/b]

Higher-timeframe bias is requested using offset logic intended to avoid repaint-style behavior from incomplete higher-timeframe bars.

Fast and slow higher-timeframe EMA structure is used to determine whether broad directional pressure is supportive, opposing, or neutral.

Harborside does not force the higher-timeframe filter on the user.

It can be enabled or disabled depending on workflow.

[b]7. Regime Health and Confidence[/b]

Harborside includes a confidence-style scoring model built from displacement, slope, compression state, and directional bias alignment.

This score is not intended to be a trade system on its own.

It is a context gauge.

A high score means the active regime has cleaner structural support.

A low score means the visible state is weaker or more fragile.

[image]https://www.tradingview.com/x/DG3DD31M/[/image]

[b]Features[/b]

[list]
[*][b]Pivot-fed centerline:[/b] The regime center is anchored to confirmed swing structure rather than a static average alone
[*][b]Adaptive outer rails:[/b] ATR-scaled bands expand and contract with changing volatility conditions
[*][b]Confirmed regime flips:[/b] Bull and bear states change only after confirmed structural breaks through the active channel rails
[*][b]Compression box:[/b] Important volatility contraction zones are shown directly on the chart instead of being hidden in a separate pane
[*][b]Projection rails:[/b] Forward rails extend the current channel geometry into future bars for context and stretch awareness
[*][b]Higher-timeframe bias filter:[/b] Optional HTF directional alignment helps separate local moves from larger directional pressure
[*][b]Regime-colored candles:[/b] Candle coloring reflects the active state without relying on cluttered symbols or arrows
[*][b]Band cloud rendering:[/b] The active channel body is filled to make directional structure readable at a glance
[*][b]Health and confidence diagnostics:[/b] The dashboard summarizes regime quality in compact form
[*][b]Six-row dashboard:[/b] The display was intentionally reduced so the chart remains the primary source of information
[*][b]Confirmed-bar alerts:[/b] Alerts are available for regime flips, compression holds, center reclaims, HTF alignment, and high-health states
[/list]

[b]Input Parameters[/b]

[b]Channel Structure:[/b]
[list]
[*]Swing Length: Number of bars required on both sides to confirm pivots used by the structural center
[*]Band Multiplier: ATR multiplier used to define the channel width
[*]Center Smoothing: Smoothing applied to the structural midpoint
[*]Band Smoothing: Smoothing applied to the upper and lower rails
[/list]

[b]Bias and Context:[/b]
[list]
[*]Bias Timeframe: Higher timeframe used for optional directional confirmation
[*]Compression Lookback: Baseline window used to measure channel contraction
[*]Compression Threshold: Band-width threshold below which the market is treated as compressed
[*]Volume Bias Filter: Volume impulse threshold used to label directional support
[/list]

[b]Projection:[/b]
[list]
[*]Projection Bars: Number of bars projected forward
[*]Projection ATR Multiplier: Width factor used for forward rails
[*]Projection Slope Multiplier: How strongly current center slope influences the forward center projection
[/list]

[b]Display:[/b]
[list]
[*]Show Band Cloud toggle
[*]Show Compression Box toggle
[*]Show Projection Rails toggle
[*]Recolor Candles toggle
[*]Show Dashboard toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the State from the Chart First[/b]

Start with the channel itself.

Is price controlling the upper side of the structure, the lower side, or compressing near the center?

The rails and cloud are meant to answer that visually before the dashboard is consulted.

[b]Step 2: Check Compression Before Chasing Direction[/b]

If the compression box is active, treat the market as coiled rather than trending cleanly.

That does not mean price cannot move.

It means breakout quality matters more than ordinary directional drift.

[b]Step 3: Use Projection Rails as Forward Reference[/b]

Projection rails are best used for context.

If price is already far outside projected geometry, the market may be stretched.

If price is traveling inside projected structure, continuation is behaving more normally.

[b]Step 4: Compare Local Regime to HTF Bias[/b]

If the local regime and higher timeframe agree, directional conditions are cleaner.

If they disagree, treat the move with more caution.

That disagreement often marks either a pullback or a weak local thrust against broader pressure.

[b]Step 5: Use Health and Confidence as Filters, Not Commands[/b]

High confidence does not guarantee follow-through.

Low confidence does not guarantee failure.

The score is there to grade structural quality, not to replace decision-making.

[b]Indicator Limitations[/b]

[list]
[*]Pivot-based structure is intentionally confirmed after the swing forms, so the centerline will never anticipate future pivots
[*]Projection rails are structural references, not forecasts of what price must do next
[*]HTF alignment is delayed by design because the script uses completed higher-timeframe values for safer non-repainting behavior
[*]Compression can persist longer than expected, so directional patience is still required
[*]Harborside is a context framework and should not be treated as a guaranteed entry system on its own
[/list]

[b]Originality Statement[/b]

Harborside Regime Channel is original in the way it combines a pivot-fed structural center, ATR-adaptive regime rails, explicit compression logic, forward projection rails, and optional higher-timeframe agreement into one coherent chart-first overlay.

The value of the script is not any one component in isolation.

It is the way those components interact to show whether the market is healthy, stretched, compressing, or structurally aligned.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It does not provide financial advice, investment advice, or trading recommendations.

Any regime reading can fail, reverse, or degrade suddenly due to news, liquidity changes, or ordinary market uncertainty.

Always use independent confirmation and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Harborside Regime Channel [JOAT]", overlay = true, max_lines_count = 400, max_labels_count = 200)

//------------------------------------------------------------------------------
// Harborside Regime Channel
// Adaptive pivot-fed regime channel with higher-timeframe bias, compression
// detection, projection, and a diagnostic dashboard.
//------------------------------------------------------------------------------

string groupChannel = "Channel"
string groupBias = "Bias"
string groupContext = "Context"
string groupProjection = "Projection"
string groupStyle = "Style"
string groupDashboard = "Dashboard"
string groupAlerts = "Alerts"

int swingLength = input.int(10, "Swing Length", minval = 2, group = groupChannel)
float bandMult = input.float(2.0, "Band Multiplier", minval = 0.5, step = 0.1, group = groupChannel)
int centerSmooth = input.int(10, "Center Smoothing", minval = 2, group = groupChannel)
int bandSmooth = input.int(20, "Band Smoothing", minval = 2, group = groupChannel)
int projectionBars = input.int(14, "Projection Bars", minval = 1, maxval = 50, group = groupChannel)
bool showPivotMarks = input.bool(false, "Show Pivot Marks", group = groupChannel)
bool showBandCloud = input.bool(true, "Show Band Cloud", group = groupChannel)

bool useHtfBias = input.bool(true, "Use HTF Bias Filter", group = groupBias)
string htfInput = input.timeframe("240", "Bias Timeframe", group = groupBias)
int htfFastLen = input.int(34, "HTF Fast EMA", minval = 2, group = groupBias)
int htfSlowLen = input.int(89, "HTF Slow EMA", minval = 2, group = groupBias)
int compressionLookback = input.int(30, "Compression Lookback", minval = 5, group = groupBias)
float compressionPct = input.float(0.88, "Compression Threshold", minval = 0.5, maxval = 1.5, step = 0.01, group = groupBias)
int contextLookback = input.int(40, "Context Lookback", minval = 10, maxval = 200, group = groupContext)
int volumeLookback = input.int(34, "Volume Lookback", minval = 5, maxval = 200, group = groupContext)
float volumeBiasFilter = input.float(1.10, "Volume Bias Filter", minval = 0.5, step = 0.05, group = groupContext)
int trendConfirmBars = input.int(3, "Trend Confirm Bars", minval = 0, maxval = 10, group = groupContext)
bool showCompressionBox = input.bool(true, "Show Compression Box", group = groupContext)
bool showRangeRibbon = input.bool(true, "Show Range Ribbon", group = groupContext)
bool showProjectionRails = input.bool(true, "Show Projection Rails", group = groupProjection)
float projectionAtrMult = input.float(1.15, "Projection ATR Multiplier", minval = 0.2, step = 0.05, group = groupProjection)
float projectionSlopeMult = input.float(1.0, "Projection Slope Multiplier", minval = 0.2, step = 0.05, group = groupProjection)
float projectionBandMult = input.float(0.9, "Projection Band Multiplier", minval = 0.2, step = 0.05, group = groupProjection)

color bullCol = input.color(color.rgb(41, 214, 165), "Bull Regime", group = groupStyle, inline = "c1")
color bearCol = input.color(color.rgb(231, 99, 133), "", group = groupStyle, inline = "c1")
color midCol = input.color(color.rgb(126, 138, 165), "Center", group = groupStyle)
color neutralCol = input.color(color.rgb(104, 113, 136), "Neutral", group = groupStyle)
color compressionCol = input.color(color.rgb(255, 185, 58), "Compression", group = groupStyle)
color projectionCol = input.color(color.rgb(110, 199, 255), "Projection", group = groupStyle)
color railCol = input.color(color.rgb(74, 90, 129), "Rails", group = groupStyle)
int cloudOpacity = input.int(84, "Cloud Transparency", minval = 10, maxval = 95, group = groupStyle)
bool showProjection = input.bool(true, "Show Projection", group = groupStyle)
bool recolorCandles = input.bool(true, "Recolor Candles", group = groupStyle)

bool showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)
bool showDebugPlots = input.bool(false, "Show Debug Plots", group = groupDashboard)
string dashSize = input.string("Normal", "Dashboard Size", options = ["Small", "Normal", "Large"], group = groupDashboard)

bool enableAlerts = input.bool(true, "Enable Alerts", group = groupAlerts)

f_size(string sizeName) =>
    switch sizeName
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_txt(string title, string value, color c) =>
    title + ": " + value

f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_line(line id, int x1, float y1, int x2, float y2, color c, string s, int width) =>
    line result = id
    if na(result)
        result := line.new(x1, y1, x2, y2, color = c, style = s == "dashed" ? line.style_dashed : s == "dotted" ? line.style_dotted : line.style_solid, width = width)
    else
        line.set_xy1(result, x1, y1)
        line.set_xy2(result, x2, y2)
        line.set_color(result, c)
        line.set_style(result, s == "dashed" ? line.style_dashed : s == "dotted" ? line.style_dotted : line.style_solid)
        line.set_width(result, width)
    result

f_confidence(float displacement, float slope, bool bullBias, bool bearBias, bool squeeze) =>
    float score = 50.0
    score += math.min(math.abs(displacement) * 7.0, 22.0)
    score += math.min(math.abs(slope) * 240.0, 18.0)
    score += bullBias or bearBias ? 12.0 : -2.0
    score += squeeze ? -6.0 : 8.0
    math.min(math.max(score, 0.0), 100.0)

f_phase(bool bull, bool bear, bool squeeze, float slope, int age) =>
    squeeze ? "Compression" : bull and slope >= 0 ? age < 5 ? "Launch" : "Advance" : bear and slope <= 0 ? age < 5 ? "Breakdown" : "Decline" : "Rotation"

f_event_count(bool eventFlag, int length) =>
    float total = 0.0
    for i = 0 to length - 1
        total += eventFlag[i] ? 1.0 : 0.0
    total

float ph = ta.pivothigh(high, swingLength, swingLength)
float pl = ta.pivotlow(low, swingLength, swingLength)
var float lastPivotHigh = na
var float lastPivotLow = na

if not na(ph)
    lastPivotHigh := high[swingLength]
    if showPivotMarks
        label.new(bar_index[swingLength], high[swingLength], "PH", style = label.style_label_down, color = color.new(chart.bg_color, 100), textcolor = bullCol, size = size.tiny)
if not na(pl)
    lastPivotLow := low[swingLength]
    if showPivotMarks
        label.new(bar_index[swingLength], low[swingLength], "PL", style = label.style_label_up, color = color.new(chart.bg_color, 100), textcolor = bearCol, size = size.tiny)

float atrBase = ta.atr(55)
float centerRaw = math.avg(nz(lastPivotHigh, high), nz(lastPivotLow, low))
float centerLine = ta.ema(centerRaw, centerSmooth)
float upperBand = ta.ema(centerLine + atrBase * bandMult, bandSmooth)
float lowerBand = ta.ema(centerLine - atrBase * bandMult, bandSmooth)
float bandWidth = math.max(upperBand - lowerBand, syminfo.mintick)
float bandWidthAtr = bandWidth / math.max(atrBase, syminfo.mintick)
float centerSlope = ta.ema(centerLine - centerLine[1], centerSmooth)
float slopePct = centerSlope / math.max(centerLine, syminfo.mintick) * 100.0
bool compression = bandWidthAtr <= ta.sma(bandWidthAtr, compressionLookback) * compressionPct

float htfFast = na
float htfSlow = na
float htfClose = na
bool htfValid = timeframe.in_seconds(htfInput) >= timeframe.in_seconds(timeframe.period)
if useHtfBias and htfValid
    htfFast := request.security(syminfo.tickerid, htfInput, ta.ema(close, htfFastLen)[1], lookahead = barmerge.lookahead_on)
    htfSlow := request.security(syminfo.tickerid, htfInput, ta.ema(close, htfSlowLen)[1], lookahead = barmerge.lookahead_on)
    htfClose := request.security(syminfo.tickerid, htfInput, close[1], lookahead = barmerge.lookahead_on)

bool htfBullBias = useHtfBias and htfValid and not na(htfFast) and not na(htfSlow) and not na(htfClose) and htfFast > htfSlow and htfClose > htfFast
bool htfBearBias = useHtfBias and htfValid and not na(htfFast) and not na(htfSlow) and not na(htfClose) and htfFast < htfSlow and htfClose < htfFast

var int regimeState = 0
var int lastFlipBar = na
bool breakUp = barstate.isconfirmed and ta.crossover(close, upperBand)
bool breakDown = barstate.isconfirmed and ta.crossunder(close, lowerBand)

if breakUp and (not useHtfBias or htfBullBias)
    regimeState := 1
    lastFlipBar := bar_index
if breakDown and (not useHtfBias or htfBearBias)
    regimeState := -1
    lastFlipBar := bar_index
if regimeState == 0 and barstate.isconfirmed
    regimeState := close >= centerLine ? 1 : -1
    if na(lastFlipBar)
        lastFlipBar := bar_index

bool bullRegime = regimeState == 1
bool bearRegime = regimeState == -1
bool bullFlip = bullRegime and nz(regimeState[1], 0) != 1
bool bearFlip = bearRegime and nz(regimeState[1], 0) != -1
bool centerReclaim = barstate.isconfirmed and ta.crossover(close, centerLine)
bool centerLoss = barstate.isconfirmed and ta.crossunder(close, centerLine)
int regimeAge = bar_index - nz(lastFlipBar, bar_index)
float displacementAtr = (close - centerLine) / math.max(atrBase, syminfo.mintick)
float scoreBias = math.min(math.max(displacementAtr, -4.0), 4.0)
color regimeColor = color.from_gradient(scoreBias, -4.0, 4.0, bearCol, bullCol)
float contextHigh = ta.highest(high, contextLookback)
float contextLow = ta.lowest(low, contextLookback)
float contextSpan = math.max(contextHigh - contextLow, syminfo.mintick)
float contextSpanAtr = contextSpan / math.max(atrBase, syminfo.mintick)
float volumeBase = ta.ema(volume, volumeLookback)
float volumeImpulse = volumeBase > 0 ? volume / volumeBase : 1.0
bool volumeSupportedBull = bullRegime and volumeImpulse >= volumeBiasFilter
bool volumeSupportedBear = bearRegime and volumeImpulse >= volumeBiasFilter
float compressionDepth = math.max(0.0, 1.0 - bandWidthAtr / math.max(ta.sma(bandWidthAtr, compressionLookback), syminfo.mintick))
float confidence = f_confidence(displacementAtr, centerSlope, htfBullBias, htfBearBias, compression)
string phaseText = f_phase(bullRegime, bearRegime, compression, centerSlope, regimeAge)
int trendHold = nz(ta.barssince(bullFlip or bearFlip), 0)
float bullBreakCount = f_event_count(breakUp, contextLookback)
float bearBreakCount = f_event_count(breakDown, contextLookback)
float breakoutBias = (bullBreakCount - bearBreakCount) / math.max(bullBreakCount + bearBreakCount, 1)
float expansionScore = math.min(math.max((contextSpanAtr - bandWidthAtr) * 12.0, 0.0), 100.0)
float regimeTorque = math.min(math.max((math.abs(centerSlope) / math.max(atrBase, syminfo.mintick)) * 1200.0, 0.0), 100.0)
float htfSpread = htfFast - htfSlow
float distanceToUpper = (upperBand - close) / math.max(atrBase, syminfo.mintick)
float distanceToLower = (close - lowerBand) / math.max(atrBase, syminfo.mintick)
float midBias = (close - centerLine) / math.max(contextSpan, syminfo.mintick)
int bullRunBars = bullRegime ? nz(ta.barssince(not bullRegime), 0) : 0
int bearRunBars = bearRegime ? nz(ta.barssince(not bearRegime), 0) : 0
string directionText = bullRegime ? "Bid Dominant" : bearRegime ? "Offer Dominant" : "Balanced"
string htfContextText = not useHtfBias ? "HTF Off" : htfBullBias ? "HTF Bid" : htfBearBias ? "HTF Offer" : "HTF Flat"
float trendStrength = math.min(math.abs(displacementAtr) * 25.0, 100.0)
float structuralRoom = distanceToUpper + distanceToLower
float biasHeat = math.min(math.max((breakoutBias + 1.0) * 50.0, 0.0), 100.0)
float regimeHealth = math.min(math.max(confidence * 0.40 + trendStrength * 0.30 + expansionScore * 0.30, 0.0), 100.0)
float regimeSpread = htfSpread + structuralRoom
string regimeSnapshot = phaseText + " | " + directionText

var box compressionBox = na
var line projCenterLine = na
var line projUpperLine = na
var line projLowerLine = na
var linefill projUpperFill = na
var linefill projLowerFill = na

plotUpper = plot(bearRegime ? upperBand : na, "Upper Band", color = color.new(bearCol, 0), style = plot.style_linebr, linewidth = 2)
plotLower = plot(bullRegime ? lowerBand : na, "Lower Band", color = color.new(bullCol, 0), style = plot.style_linebr, linewidth = 2)
plotCenter = plot(centerLine, "Center Line", color = color.new(midCol, 0), linewidth = 2)
fill(plotLower, plotCenter, showBandCloud ? color.new(bullCol, cloudOpacity) : color.new(chart.bg_color, 100))
fill(plotUpper, plotCenter, showBandCloud ? color.new(bearCol, cloudOpacity) : color.new(chart.bg_color, 100))

bgcolor(compression ? color.new(neutralCol, 92) : na, title = "Compression Background")

if showCompressionBox
    if compression
        int compressionLeft = math.max(bar_index - compressionLookback, 0)
        if na(compressionBox)
            compressionBox := box.new(left = compressionLeft, top = upperBand, right = bar_index, bottom = lowerBand, bgcolor = color.new(compressionCol, 92), border_color = color.new(compressionCol, 50), border_width = 1, text = "Compression", text_color = compressionCol)
        else
            box.set_left(compressionBox, compressionLeft)
            box.set_right(compressionBox, bar_index)
            box.set_top(compressionBox, upperBand)
            box.set_bottom(compressionBox, lowerBand)
            box.set_bgcolor(compressionBox, color.new(compressionCol, 92))
            box.set_border_color(compressionBox, color.new(compressionCol, 50))
            box.set_text(compressionBox, "Compression | " + str.tostring(compressionDepth * 100.0, "#.0") + "%")
    else if not na(compressionBox)
        box.set_bgcolor(compressionBox, color.new(compressionCol, 100))
        box.set_border_color(compressionBox, color.new(compressionCol, 100))

if showProjection and showProjectionRails
    float projectedCenter = centerLine + centerSlope * projectionBars * projectionSlopeMult
    float projectedUpper = projectedCenter + atrBase * bandMult * projectionAtrMult
    float projectedLower = projectedCenter - atrBase * bandMult * projectionAtrMult
    projCenterLine := f_line(projCenterLine, bar_index, centerLine, bar_index + projectionBars, projectedCenter, color.new(regimeColor, 30), "dashed", 2)
    projUpperLine := f_line(projUpperLine, bar_index, upperBand, bar_index + projectionBars, projectedUpper, color.new(bullCol, 36), "solid", 2)
    projLowerLine := f_line(projLowerLine, bar_index, lowerBand, bar_index + projectionBars, projectedLower, color.new(bearCol, 36), "solid", 2)
    if na(projUpperFill)
        projUpperFill := linefill.new(projCenterLine, projUpperLine, color.new(bullCol, 90))
    else
        linefill.set_color(projUpperFill, color.new(bullCol, 90))
    if na(projLowerFill)
        projLowerFill := linefill.new(projCenterLine, projLowerLine, color.new(bearCol, 90))
    else
        linefill.set_color(projLowerFill, color.new(bearCol, 90))

if bullFlip
    label.new(bar_index, lowerBand, "Regime Shift Up", style = label.style_label_up, color = color.new(chart.bg_color, 100), textcolor = bullCol, size = size.small)
if bearFlip
    label.new(bar_index, upperBand, "Regime Shift Down", style = label.style_label_down, color = color.new(chart.bg_color, 100), textcolor = bearCol, size = size.small)

var label projectionLabel = na
if showProjection and barstate.islast
    if not na(projectionLabel)
        label.delete(projectionLabel)
    string projectionText = bullRegime ? "Bid Bias" : bearRegime ? "Offer Bias" : "Balanced"
    projectionText := projectionText + " | " + str.tostring(displacementAtr, "#.##") + " ATR"
    projectionText := projectionText + " | C" + str.tostring(confidence, "#.0")
    projectionLabel := label.new(bar_index + projectionBars, centerLine, projectionText, style = label.style_label_left, color = color.new(regimeColor, 82), textcolor = chart.fg_color, size = size.small)

color candleColor = recolorCandles ? regimeColor : na
barcolor(candleColor)
plotcandle(recolorCandles ? open : na, recolorCandles ? high : na, recolorCandles ? low : na, recolorCandles ? close : na, color = candleColor, wickcolor = candleColor, bordercolor = candleColor)

stateText = bullRegime ? close > centerLine ? "Advance" : "Pullback" : close < centerLine ? "Decline" : "Rebound"
htfText = not useHtfBias ? "Disabled" : not htfValid ? "Invalid TF" : htfBullBias ? "Bull" : htfBearBias ? "Bear" : "Neutral"
compressionText = compression ? "Compressed" : "Expanded"

string contextText = volumeSupportedBull ? "Bull Supported" : volumeSupportedBear ? "Bear Supported" : "Unconfirmed"
string phaseBiasText = phaseText + " | " + contextText

var table ribbon = table.new(position.bottom_center, 12, 2, frame_color = color.new(chart.fg_color, 85), frame_width = 1)
var table dash = table.new(position.top_right, 2, 6, bgcolor = color.new(color.rgb(8, 10, 17), 0), frame_color = color.new(chart.fg_color, 75), frame_width = 1, border_color = color.new(chart.fg_color, 90), border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Harborside", text_color = chart.fg_color, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 1, 0, stateText + " | " + directionText, text_color = regimeColor, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 0, 1, "Phase", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 1, phaseBiasText, text_color = phaseText == "Compression" ? compressionCol : regimeColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 2, "Width", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 2, str.tostring(bandWidthAtr, "#.##") + " ATR | " + compressionText, text_color = compression ? compressionCol : regimeColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 3, "Confidence", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 3, str.tostring(confidence, "#.0") + " | H " + str.tostring(regimeHealth, "#.0"), text_color = regimeColor, text_size = f_size(dashSize))
    table.cell(dash, 0, 4, "HTF / Vol", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 4, htfText + " | " + str.tostring(volumeImpulse, "#.00") + "x", text_color = htfBullBias ? bullCol : htfBearBias ? bearCol : chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 0, 5, "Room", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 5, str.tostring(distanceToUpper, "#.##") + " / " + str.tostring(distanceToLower, "#.##"), text_color = chart.fg_color, text_size = f_size(dashSize))

if showRangeRibbon and barstate.islast
    int center = 6
    int active = int(math.round(center + scoreBias / 4.0 * center))
    active := int(f_clamp(active, 0, 11))
    for col = 0 to 11
        float dist = math.abs(col - center) / float(center)
        color cellCol = col <= center ? color.new(bullCol, int(28 + dist * 48)) : color.new(bearCol, int(28 + dist * 48))
        table.cell(ribbon, col, 0, col == center ? "Axis" : "", bgcolor = col == center ? color.new(midCol, 72) : color.new(chart.bg_color, 100), text_color = chart.fg_color)
        table.cell(ribbon, col, 1, col == active ? " " : "", bgcolor = cellCol)

plot(showDebugPlots ? centerSlope : na, "Center Slope", color = color.new(regimeColor, 0), display = display.none)
plot(showDebugPlots ? bandWidthAtr : na, "Band Width ATR", color = color.new(neutralCol, 0), display = display.none)
plot(showDebugPlots ? confidence : na, "Confidence", color = color.new(compressionCol, 0), display = display.none)
plot(showDebugPlots ? volumeImpulse : na, "Volume Impulse", color = color.new(projectionCol, 0), display = display.none)
plot(showDebugPlots ? midBias : na, "Mid Bias", color = color.new(railCol, 0), display = display.none)
plot(showDebugPlots ? regimeHealth : na, "Regime Health", color = color.new(compressionCol, 0), display = display.none)
plot(showDebugPlots ? biasHeat : na, "Bias Heat", color = color.new(projectionCol, 0), display = display.none)
plot(showDebugPlots ? regimeSpread : na, "Regime Spread", color = color.new(railCol, 0), display = display.none)

alertcondition(enableAlerts and bullFlip, "Harborside Bull Flip", "The regime has flipped into a bullish state.")
alertcondition(enableAlerts and bearFlip, "Harborside Bear Flip", "The regime has flipped into a bearish state.")
alertcondition(enableAlerts and centerReclaim, "Harborside Center Reclaim", "Price has reclaimed the structural center upward.")
alertcondition(enableAlerts and centerLoss, "Harborside Center Loss", "Price has lost the structural center downward.")
alertcondition(enableAlerts and compression and (breakUp or breakDown), "Harborside Compression Break", "Compression has broken with directional follow-through.")
alertcondition(enableAlerts and htfBullBias, "Harborside HTF Bull", "Higher-timeframe bias is aligned bullish.")
alertcondition(enableAlerts and htfBearBias, "Harborside HTF Bear", "Higher-timeframe bias is aligned bearish.")
alertcondition(enableAlerts and showProjection and barstate.isconfirmed and bullRegime and close > centerLine + atrBase * projectionAtrMult, "Harborside Projection Stretch Up", "Price has stretched beyond the projected bullish rail.")
alertcondition(enableAlerts and showProjection and barstate.isconfirmed and bearRegime and close < centerLine - atrBase * projectionAtrMult, "Harborside Projection Stretch Down", "Price has stretched beyond the projected bearish rail.")
alertcondition(enableAlerts and barstate.isconfirmed and trendHold >= trendConfirmBars and compression, "Harborside Compression Hold", "Compression has persisted long enough to matter.")
alertcondition(enableAlerts and volumeSupportedBull, "Harborside Volume Supported Bull", "Bullish regime is backed by volume expansion.")
alertcondition(enableAlerts and volumeSupportedBear, "Harborside Volume Supported Bear", "Bearish regime is backed by volume expansion.")
alertcondition(enableAlerts and barstate.isconfirmed and regimeHealth >= 75.0, "Harborside High Health", "The regime health score has become elevated.")
alertcondition(enableAlerts and bullRegime and bullRunBars >= trendConfirmBars, "Harborside Bull Hold", "Bull regime has held long enough to matter.")
alertcondition(enableAlerts and bearRegime and bearRunBars >= trendConfirmBars, "Harborside Bear Hold", "Bear regime has held long enough to matter.")
````
