# Order Flow OBV MACD

- url: https://www.tradingview.com/script/d4vVC3i3-Order-Flow-OBV-MACD/
- type: indicator
- pine_id: PUB;918c7523e0264482ad727b814d545a32
- version: 1.0

## Description

[b]Overview[/b]

Order Flow OBV MACD is an open-source oscillator that extends the classic OBV-style MACD idea with Pine Script v6 order-flow tools. It can run from a traditional OBV-style cumulative volume source or from CVD built with TradingView footprint delta. The script then transforms that cumulative flow into a MACD-style oscillator, applies a T-channel style direction line, and adds an adaptive confidence score that weighs recent signal components by how well they have aligned with price direction.

This is not a strategy and it does not place trades. It is intended as a market structure and confirmation tool for studying momentum, volume flow, and order-flow agreement.

[b]What Makes It Different[/b]

The indicator combines four layers:

[list]
[*]A selectable cumulative volume engine: OBV-style signed volume or CVD from footprint delta.
[*]Optional footprint-adjusted CVD using Point of Control, Value Area, and POC row imbalance context.
[*]A MACD-style oscillator derived from the transformed cumulative flow.
[*]An adaptive confidence score that estimates bullish/bearish agreement from MACD direction, channel direction, delta direction, and footprint bias.
[/list]

The goal is not to predict the future or claim a fixed win rate. The goal is to show when several volume and order-flow components are aligned, conflicting, or neutral.

[b]How It Works[/b]

[b]1. Cumulative Volume Source[/b]

The script starts by building a cumulative flow series.

[list]
[*]OBV mode uses close direction multiplied by volume, then cumulates it.
[*]CVD mode uses footprint delta, which is buy volume minus sell volume for the bar, then cumulates it.
[/list]

OBV mode is broadly compatible. CVD mode uses TradingView's `request.footprint()` data, so footprint availability and account plan support matter.

[b]2. Footprint-Adjusted CVD[/b]

When CVD Mode is set to Footprint-adjusted, the raw delta can be boosted or softened by row-level footprint context:

[list]
[*]Price relative to the footprint Point of Control row.
[*]Price relative to Value Area High and Value Area Low.
[*]Buy or sell imbalance on the POC row.
[/list]

If delta and footprint context agree, delta can be strengthened. If they conflict, delta can be reduced. The Footprint Row Influence setting controls how strong this adjustment is.

[b]3. MACD Layer[/b]

The selected cumulative flow source is normalized through the original OBV-MACD style transformation and smoothed. The script then compares the transformed fast order-flow line against a slow EMA-based MACD leg.

The slow MACD leg can optionally adapt based on the previous bar's adaptive confidence. Strong confidence makes it more responsive. Weak confidence makes it smoother. This uses the prior bar's score to avoid circular logic.

[b]4. T-Channel Direction Line[/b]

The main plotted blue/red line is a channel-style directional line based on the slope of the MACD output. Blue indicates positive channel direction and red indicates negative channel direction. Optional cross markers can show direction changes.

[b]5. Adaptive Confidence[/b]

The Adaptive Confidence plot is a centered score:

[list]
[*]Above 0 favors bullish agreement.
[*]Below 0 favors bearish agreement.
[*]+25 and -25 are guide levels for stronger directional confidence.
[/list]

The score weighs four components:

[list]
[*]MACD direction.
[*]T-channel direction.
[*]Delta/CVD direction.
[*]Footprint bias.
[/list]

Each component receives an adaptive reliability weight based on how well its previous signal aligned with the current bar's price direction over the selected lookback.

[b]Key Inputs[/b]

[b]Cumulative Volume Source[/b]

Choose OBV for classic compatibility or CVD for footprint delta-based flow.

[b]CVD Mode[/b]

Raw delta uses footprint delta directly. Footprint-adjusted adds row-level POC, Value Area, and imbalance context.

[b]Footprint Ticks Per Row[/b]

Controls the price height of each footprint row. Lower values create finer detail. Higher values smooth noisy row behavior.

[b]Footprint Value Area %[/b]

Controls the amount of volume used to define the footprint Value Area. 70 is a common default.

[b]Footprint Imbalance %[/b]

Controls how strong a row imbalance must be before it is considered meaningful. Higher values are stricter.

[b]Footprint Row Influence %[/b]

Controls how much row-level footprint context can adjust bar delta in Footprint-adjusted mode.

[b]Adaptive Weight Lookback[/b]

Controls how quickly component weights adapt. Shorter values react faster but can be noisy. Longer values are smoother.

[b]Adapt MACD With Confidence[/b]

When enabled, the slow MACD leg adjusts using the previous bar's adaptive confidence. Disable it to keep the MACD closer to classic fixed-length behavior.

[b]Suggested Use[/b]

[list]
[*]Look for stronger bullish conditions when the channel is blue, the confidence score is above zero, and CVD/footprint settings support the move.
[*]Look for stronger bearish conditions when the channel is red, the confidence score is below zero, and delta/footprint context agrees.
[*]Treat low or mixed confidence as a warning that the components are not aligned.
[*]Use the indicator with price structure, support/resistance, market context, and risk management. Do not use it as a standalone trading system.
[/list]

[b]Limitations[/b]

[list]
[*]This is an indicator, not a strategy.
[*]It does not guarantee accuracy, profitability, or future performance.
[*]CVD and footprint-adjusted features depend on TradingView footprint data availability.
[*]TradingView states that scripts using `request.footprint()` require Premium or Ultimate access.
[*]The adaptive confidence score is a heuristic based on recent alignment, not machine learning training.
[*]Like any oscillator, it can lag, whipsaw, or conflict with price during chop, news events, thin liquidity, or unusual volume conditions.
[/list]

[b]Credits[/b]

This script builds on an OBV MACD concept and includes a T-channel style directional component inspired by Alex Grover's T-Channels work. The v6 version extends the idea with footprint delta, CVD, row-level footprint context, adaptive confidence scoring, and optional confidence-adjusted MACD smoothing.

[b]Disclaimer[/b]

This script is for educational and analytical use only. It is not financial advice, investment advice, or a recommendation to buy or sell any asset. Always test settings on your own symbol and timeframe, and use independent risk management.

## Source Code

````pine
//@version=6
// Author: jabez4jc
indicator("Order Flow OBV MACD", overlay = false)

// MACD
src1 = close
windowLen = 28
vLen = 14
cumVolumeSource = input.string("OBV", title = "Cumulative Volume Source", options = ["OBV", "CVD"], tooltip = "Select the cumulative flow engine. OBV uses close direction times volume and works on all symbols. CVD uses footprint delta and is more order-flow sensitive; use it when footprint data is available.")
cvdMode = input.string("Footprint-adjusted", title = "CVD Mode", options = ["Raw delta", "Footprint-adjusted"], tooltip = "Controls how CVD is built. Raw delta uses footprint buy minus sell volume only. Footprint-adjusted boosts or softens delta using POC, Value Area, and imbalance context.")
rowInfluencePercent = input.float(25.0, title = "Footprint Row Influence %", minval = 0.0, maxval = 100.0, tooltip = "How strongly row-level footprint context changes each CVD bar. Raise it for more aggressive footprint filtering; lower it if the confidence line becomes too jumpy.")
ticksPerRow = input.int(100, title = "Footprint Ticks Per Row", minval = 1, tooltip = "Price height of each footprint row, measured in ticks. Lower values create finer row detail for liquid/low-tick symbols. Higher values smooth noisy instruments or higher timeframes.")
valueAreaPercent = input.int(70, title = "Footprint Value Area %", minval = 1, maxval = 100, tooltip = "Percent of volume used to calculate footprint Value Area. 70 is standard. Raise it to include more volume in VA; lower it to focus only on the densest traded zone.")
imbalancePercent = input.int(300, title = "Footprint Imbalance %", minval = 1, tooltip = "Threshold for buy/sell row imbalance detection. Higher values require stronger imbalance and reduce signals. Lower values make imbalance influence more frequent but noisier.")
showConfidence = input.bool(true, title = "Show Adaptive Confidence", tooltip = "Shows the adaptive probabilistic score as columns. Above zero favors bullish conditions; below zero favors bearish conditions. Turn off for a cleaner MACD-only pane.")
adaptiveLookback = input.int(34, title = "Adaptive Weight Lookback", minval = 5, tooltip = "Bars used to estimate which components have recently predicted price direction best. Shorter adapts faster but can overreact. Longer is smoother and slower.")
useAdaptiveMacd = input.bool(true, title = "Adapt MACD With Confidence", tooltip = "When enabled, the slow MACD EMA adapts using the previous bar's confidence. Strong confidence makes MACD more responsive; weak confidence makes it smoother.")
macdAdaptStrength = input.float(0.35, title = "MACD Adapt Strength", minval = 0.0, maxval = 0.8, step = 0.05, tooltip = "Controls how much confidence can change the slow MACD EMA speed. Higher values adapt more aggressively. Lower values stay closer to the classic MACD.")

priceSpread = ta.stdev(high - low, windowLen)
src1Change = ta.change(src1)
obvCumVolume = ta.cum(math.sign(src1Change) * volume)
footprint reqFootprint = request.footprint(ticksPerRow, valueAreaPercent, imbalancePercent)
deltaVolume = not na(reqFootprint) ? reqFootprint.delta() : na
adjustedDeltaVolume = deltaVolume
footprintBias = 0
if cvdMode == "Footprint-adjusted" and not na(reqFootprint) and not na(deltaVolume)
    volume_row pocRow = reqFootprint.poc()
    volume_row vahRow = reqFootprint.vah()
    volume_row valRow = reqFootprint.val()

    pocMidPrice = math.avg(pocRow.up_price(), pocRow.down_price())
    vahUpperPrice = vahRow.up_price()
    valLowerPrice = valRow.down_price()

    pocBias = close > pocMidPrice ? 1 : close < pocMidPrice ? -1 : 0
    valueAreaBias = close > vahUpperPrice ? 1 : close < valLowerPrice ? -1 : 0
    imbalanceBias = pocRow.has_buy_imbalance() ? 1 : pocRow.has_sell_imbalance() ? -1 : 0
    footprintBias := pocBias + valueAreaBias + imbalanceBias

    deltaAligned = deltaVolume > 0 and footprintBias > 0 or deltaVolume < 0 and footprintBias < 0
    deltaConflicted = deltaVolume > 0 and footprintBias < 0 or deltaVolume < 0 and footprintBias > 0
    rowInfluence = rowInfluencePercent / 100.0
    deltaMultiplier = deltaAligned ? 1.0 + rowInfluence : deltaConflicted ? math.max(0.0, 1.0 - rowInfluence) : 1.0
    adjustedDeltaVolume := deltaVolume * deltaMultiplier
cvdCumVolume = ta.cum(nz(adjustedDeltaVolume))
v = cumVolumeSource == "CVD" ? cvdCumVolume : obvCumVolume
smooth = ta.sma(v, vLen)
vSpread = ta.stdev(v - smooth, windowLen)
shadow = (v - smooth) / vSpread * priceSpread
out = shadow > 0 ? high + shadow : low + shadow

obvLength = input.int(1, title = "OBV Length", minval = 1, tooltip = "EMA smoothing applied to the transformed OBV/CVD engine before MACD logic. Raise it to smooth noise; keep low for faster response.")
obvEma = ta.ema(out, obvLength)
src = obvEma

maType = input.string("DEMA", title = "MA Type", options = ["TDEMA", "TTEMA", "TEMA", "DEMA", "EMA", "AVG", "THMA", "ZLEMA", "ZLDEMA", "ZLTEMA", "DZLEMA", "TZLEMA", "LLEMA", "NMA"], tooltip = "Moving average type for the fast order-flow line. Faster types like TEMA/ZLEMA react sooner. Smoother types like EMA/DEMA reduce noise.")
showMa = true
maLength = input.int(9, title = "MA Length", minval = 1, tooltip = "Length of the fast MA applied to the order-flow source. Lower values are more sensitive; higher values reduce whipsaws.")
len1 = 26

nma(series float source, simple int length1, simple int length2) =>
    lambda = length1 / length2
    alpha = lambda * (length1 - 1) / (length1 - lambda)
    ma1 = ta.ema(source, length1)
    ma2 = ta.ema(ma1, length2)
    (1 + alpha) * ma1 - alpha * ma2

dema(series float source, simple int length) =>
    ma1 = ta.ema(source, length)
    ma2 = ta.ema(ma1, length)
    2 * ma1 - ma2

tema(series float source, simple int length) =>
    ma1 = ta.ema(source, length)
    ma2 = ta.ema(ma1, length)
    ma3 = ta.ema(ma2, length)
    3 * (ma1 - ma2) + ma3

tdema(series float source, simple int length) =>
    ma1 = dema(source, length)
    ma2 = dema(ma1, length)
    ma3 = dema(ma2, length)
    3 * (ma1 - ma2) + ma3

ttema(series float source, simple int length) =>
    ma1 = tema(source, length)
    ma2 = tema(ma1, length)
    ma3 = tema(ma2, length)
    3 * (ma1 - ma2) + ma3

hma(series float source, simple int length) =>
    halfLength = math.max(1, int(math.round(length / 2.0)))
    sqrtLength = math.max(1, int(math.round(math.sqrt(length))))
    ta.wma(2 * ta.wma(source, halfLength) - ta.wma(source, length), sqrtLength)

thma(series float source, simple int length) =>
    ma1 = hma(source, length)
    ma2 = hma(ma1, length)
    ma3 = hma(ma2, length)
    3 * (ma1 - ma2) + ma3

zlema(series float source, simple int length) =>
    lag = int(math.round((length - 1) / 2.0))
    zlsrc = source + (source - source[lag])
    ta.ema(zlsrc, length)

zldema(series float source, simple int length) =>
    lag = int(math.round((length - 1) / 2.0))
    zlsrc = source + (source - source[lag])
    dema(zlsrc, length)

zltema(series float source, simple int length) =>
    lag = int(math.round((length - 1) / 2.0))
    zlsrc = source + (source - source[lag])
    tema(zlsrc, length)

dzlema(series float source, simple int length) =>
    ma1 = zlema(source, length)
    ma2 = zlema(ma1, length)
    2 * ma1 - ma2

tzlema(series float source, simple int length) =>
    ma1 = zlema(source, length)
    ma2 = zlema(ma1, length)
    ma3 = zlema(ma2, length)
    3 * (ma1 - ma2) + ma3

llema(series float source, simple int length) =>
    srcNew = 0.25 * source + 0.5 * source[1] + 0.25 * source[2]
    ta.ema(srcNew, length)

myMa(series float source, simple int length) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "DEMA" => dema(source, length)
        "TEMA" => tema(source, length)
        "TDEMA" => tdema(source, length)
        "TTEMA" => ttema(source, length)
        "THMA" => thma(source, length)
        "ZLEMA" => zlema(source, length)
        "ZLDEMA" => zldema(source, length)
        "ZLTEMA" => zltema(source, length)
        "DZLEMA" => dzlema(source, length)
        "TZLEMA" => tzlema(source, length)
        "LLEMA" => llema(source, length)
        "NMA" => nma(source, length, len1)
        => math.avg(ttema(source, length), tdema(source, length))

adaptiveEma(series float source, simple int baseLength, series float confidence, simple float strength) =>
    confidenceRatio = math.min(1.0, math.abs(confidence) / 50.0)
    lengthMultiplier = 1.0 + strength * (1.0 - 2.0 * confidenceRatio)
    effectiveLength = math.max(1.0, baseLength * lengthMultiplier)
    alpha = 2.0 / (effectiveLength + 1.0)
    var float emaValue = na
    emaValue := na(emaValue[1]) ? source : alpha * source + (1.0 - alpha) * nz(emaValue[1], source)

ma = showMa ? myMa(src, maLength) : na
slowLength = input.int(title = "MACD Slow Length", defval = 26, minval = 1, tooltip = "Slow EMA length used in the MACD comparison against price. When adaptive MACD is enabled, this is the base length. Raise it for smoother trend context; lower it for earlier turns.")
src12 = close
plot(0, linewidth = 3, color = color.black)

// Calculating MACD
var float macdConfidenceMemory = 0.0
classicSlowMa = ta.ema(src12, slowLength)
adaptiveSlowMa = adaptiveEma(src12, slowLength, macdConfidenceMemory, macdAdaptStrength)
slowMa = useAdaptiveMacd ? adaptiveSlowMa : classicSlowMa
macd = ma - slowMa

src5 = macd
len5 = input.int(2, title = "Slope Length", minval = 1, tooltip = "Lookback used for the slope projection that feeds the channel line. Lower is faster and noisier; higher is smoother and later.")
offset = 0

calcSlope(series float source, simple int length) =>
    sumX = 0.0
    sumY = 0.0
    sumXSqr = 0.0
    sumXY = 0.0
    for i = 1 to length
        val = source[length - i]
        per = i + 1.0
        sumX += per
        sumY += val
        sumXSqr += per * per
        sumXY += val * per

    slope = (length * sumXY - sumX * sumY) / (length * sumXSqr - sumX * sumX)
    average = sumY / length
    intercept = average - slope * sumX / length + slope
    [slope, average, intercept]

[s, a5, i] = calcSlope(src5, len5)
tt1 = i + s * (len5 - offset)

// Script based on Alex Grover's T-Channels.
p = 1.0
src15 = tt1
var b5 = 0.0
var dev5 = 0.0
var oc = 0
n5 = ta.cum(1.0) - 1.0
a15 = ta.cum(math.abs(src15 - nz(b5[1], src15))) / n5 * p
b5 := src15 > nz(b5[1], src15) + a15 ? src15 : src15 < nz(b5[1], src15) - a15 ? src15 : nz(b5[1], src15)

b5Change = ta.change(b5)
dev5 := b5Change != 0 ? a15 : nz(dev5[1], a15)
oc := b5Change > 0 ? 1 : b5Change < 0 ? -1 : nz(oc[1])

cs = oc == 1 ? color.blue : color.red
plot(b5, color = color.new(cs, 50), linewidth = 4)

ocChange = ta.change(oc)
down = ocChange < 0
up = ocChange > 0
showSignal = input.bool(false, title = "Show signals", tooltip = "Plots cross markers when the T-channel direction flips. Enable for visible signal points; disable to reduce clutter.")
plotshape(showSignal and up ? tt1 : na, style = shape.triangleup, location = location.bottom, color = color.blue)
plotshape(showSignal and down ? tt1 : na, style = shape.triangledown, location = location.top, color = color.red)

predictionHit(series int signal, series int actualDirection) =>
    signal[1] == 0 or actualDirection == 0 ? 0.5 : signal[1] == actualDirection ? 1.0 : 0.0

adaptiveReliability(series int signal, series int actualDirection, simple int length) =>
    nz(ta.sma(predictionHit(signal, actualDirection), length), 0.5)

signalProbability(series int signal) =>
    signal > 0 ? 1.0 : signal < 0 ? 0.0 : 0.5

priceDirection = close > close[1] ? 1 : close < close[1] ? -1 : 0
macdSignal = macd > 0 ? 1 : macd < 0 ? -1 : 0
channelSignal = oc
deltaSignal = adjustedDeltaVolume > 0 ? 1 : adjustedDeltaVolume < 0 ? -1 : 0
footprintSignal = footprintBias > 0 ? 1 : footprintBias < 0 ? -1 : 0

macdWeight = adaptiveReliability(macdSignal, priceDirection, adaptiveLookback)
channelWeight = adaptiveReliability(channelSignal, priceDirection, adaptiveLookback)
deltaWeight = adaptiveReliability(deltaSignal, priceDirection, adaptiveLookback)
footprintWeight = adaptiveReliability(footprintSignal, priceDirection, adaptiveLookback)
totalWeight = macdWeight + channelWeight + deltaWeight + footprintWeight

bullProbability = totalWeight > 0 ? 100.0 * (signalProbability(macdSignal) * macdWeight + signalProbability(channelSignal) * channelWeight + signalProbability(deltaSignal) * deltaWeight + signalProbability(footprintSignal) * footprintWeight) / totalWeight : 50.0
centeredConfidence = bullProbability - 50.0
macdConfidenceMemory := centeredConfidence
confidenceColor = centeredConfidence >= 0 ? color.new(color.teal, 0) : color.new(color.orange, 0)
plot(showConfidence ? centeredConfidence : na, title = "Adaptive Confidence (+Bull / -Bear)", color = confidenceColor, linewidth = 2, style = plot.style_columns)
plot(showConfidence ? 25 : na, title = "High Bull Confidence", color = color.new(color.teal, 75), linewidth = 1)
plot(showConfidence ? -25 : na, title = "High Bear Confidence", color = color.new(color.orange, 75), linewidth = 1)

upper = tt1
lower = tt1

// DIVS code
hidePivots = input.bool(true, "Hide pivots?", tooltip = "Controls pivot labels. True hides pivot markers. Set to false if you want to inspect local highs/lows on the oscillator.")
shrt = false
xbars = input.int(50, "Period", minval = 1, tooltip = "Pivot detection lookback period. Higher values find broader pivots; lower values mark more frequent short-term pivots.")
hb = math.abs(ta.highestbars(upper, xbars))
lb = math.abs(ta.lowestbars(lower, xbars))

var float maxClose = na
var float maxUpper = na
var float minClose = na
var float minLower = na

maxClose := hb == 0 ? close : na(maxClose[1]) ? close : maxClose[1]
maxUpper := hb == 0 ? upper : na(maxUpper[1]) ? upper : maxUpper[1]
minClose := lb == 0 ? close : na(minClose[1]) ? close : minClose[1]
minLower := lb == 0 ? lower : na(minLower[1]) ? lower : minLower[1]

if close > maxClose
    maxClose := close
if upper > maxUpper
    maxUpper := upper
if close < minLower
    minLower := lower
if lower < minLower
    minLower := lower

pivotHigh = maxUpper == maxUpper[2] and maxUpper[2] != maxUpper[3]
pivotLow = minLower == minLower[2] and minLower[2] != minLower[3]

pivotHighY = not hidePivots and not shrt and pivotHigh ? maxUpper + 2 : na
pivotLowY = not hidePivots and not shrt and pivotLow ? minLower - 2 : na

plotshape(pivotHighY, title = "Pivot High", location = location.absolute, style = shape.labeldown, color = color.red, size = size.tiny, text = "Pivot", textcolor = color.white)
plotshape(pivotLowY, title = "Pivot Low", location = location.absolute, style = shape.labelup, color = color.blue, size = size.tiny, text = "Pivot", textcolor = color.white)
````
