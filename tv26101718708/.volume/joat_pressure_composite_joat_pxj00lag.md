# JOAT Pressure Composite [JOAT]

- url: https://www.tradingview.com/script/PxJ00lAg-JOAT-Pressure-Composite-JOAT/
- type: indicator
- pine_id: PUB;e36601ad0e3c45d4a9b33c1b85a8aa9b
- version: 1.0

## Description

[b]JOAT Pressure Composite [JOAT][/b]

[b]Introduction[/b]

JOAT Pressure Composite is an open-source accumulation-distribution and participation oscillator built to measure whether buying or selling pressure is strengthening, weakening, rotating, or diverging from price.

It is designed to expose internal sponsorship behind price movement rather than price movement alone.

The script combines weighted close-location flow, relative-volume sponsorship, volume sigma, effort, efficiency, momentum bias, VWAP bias, and confirmed higher-timeframe context into one composite pressure model.

The problem it solves is hidden participation.

Price can rise on weak effort.

Price can fall on poor sponsorship.

Price can continue moving while internal pressure deteriorates.

Pressure Composite tries to expose those changes earlier by measuring how much of the move is actually being sponsored by participation.

The oscillator pane carries the composite, signal line, envelope, flow ribbon, and extreme states.

At the same time, the indicator projects tailored information onto the main chart.

Price divergence is labeled clearly.

Expansion and absorption states are labeled directly on candles.

Anchored VWAP and trend context are overlaid on price so the oscillator and chart remain connected.

[image]https://www.tradingview.com/x/pGoTlq2o/[/image]

[b]Core Concepts[/b]

[b]1. Weighted Pressure Engine[/b]

The base flow uses close-location value and weighted volume.

[pine]
closeLocationValue = (2.0 * close - low - high) / barRange
weightedVolume     = volume * sponsorshipFactor
[/pine]

[b]2. Pressure Z-Score[/b]

The raw pressure series is normalized with a Z-score.

[b]3. Sigma and Effort Layers[/b]

Volume sigma and effort help distinguish aggressive participation from ordinary rotation.

[b]4. Efficiency Bias[/b]

The script measures whether price is moving efficiently over the selected lookback.

[b]5. VWAP Bias[/b]

Distance from anchored VWAP is normalized in ATR terms.

[b]6. Confirmed Divergence Logic[/b]

Pivot-based divergence compares oscillator highs and lows to price highs and lows.

[b]7. Expansion and Absorption Labels[/b]

The chart prints Bid Expansion, Offer Expansion, Bull Absorption, and Bear Absorption labels directly on price.

[b]8. Confirmed Higher-Timeframe Context[/b]

The script pulls confirmed HTF composite states only.

[image]https://www.tradingview.com/x/vmmya5lp/[/image]

[b]Features[/b]

[list]
[*][b]Composite pressure model:[/b] blends pressure, effort, sigma, efficiency, and VWAP bias
[*][b]Flow ribbon:[/b] shows whether pressure is widening or fading
[*][b]Envelope and extreme states:[/b] separates normal expansion from aggressive pressure
[*][b]Confirmed divergence detection:[/b] compares oscillator pivots to price pivots
[*][b]Clear divergence labeling:[/b] bullish and bearish pressure divergence is labeled directly on price
[*][b]Expansion / absorption labels:[/b] market states are marked on actual candles
[*][b]Anchored VWAP context:[/b] projected onto the chart for alignment
[*][b]Fast / slow trend context:[/b] price-side guides remain visible while using the oscillator
[*][b]Confirmed HTF states:[/b] non-repainting higher-timeframe pressure context
[*][b]No dashboard:[/b] information is pushed into the chart and oscillator instead of a table
[/list]

[b]Input Parameters[/b]

[b]Composite Engine:[/b]

[list]
[*]Smoothing Type
[*]Flow Smoothing
[*]Normalization Length
[*]Relative Volume Baseline
[*]Relative Volume Boost
[*]Volume Sigma Length
[*]Effort Smoothing
[*]Efficiency Length
[*]Signal Length
[*]Envelope Length
[*]Envelope Multiplier
[*]Extreme Multiplier
[*]Pivot Length
[*]Divergence Scan
[*]ATR Length
[/list]

[b]Qualification / Display:[/b]

[list]
[*]Use Trend Gate
[*]Trend Fast EMA
[*]Trend Slow EMA
[*]Use VWAP Gate
[*]Minimum Spread
[*]Show Histogram
[*]Show Signal Line
[*]Show Envelope
[*]Show Flow Ribbon
[*]Show Divergence
[*]Tint Price Bars
[*]Shade Momentum States
[*]Show Price Context
[*]Show Price Event Labels
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read the composite vs signal relationship to judge widening or fading pressure.

[b]Step 2:[/b] Check whether the state is expansion or absorption.

[b]Step 3:[/b] Watch labeled divergences closely, especially after extension.

[b]Step 4:[/b] Use anchored VWAP and trend overlays to connect the oscillator back to price structure.

[b]Step 5:[/b] Use confirmed HTF context as a quality filter rather than a prediction tool.

[b]Indicator Limitations[/b]

[list]
[*]Divergences can persist before price responds
[*]Confirmed higher-timeframe context intentionally lags unfinished HTF candles
[*]Low-volume environments can flatten the composite even while price drifts
[*]Pressure quality does not guarantee immediate reversal or continuation
[/list]

[b]Originality Statement[/b]

This script is original in how it integrates weighted close-location flow, RVOL sponsorship, sigma, effort, efficiency, VWAP distance, confirmed HTF context, and direct price-chart state labeling into one coherent participation framework.

The components are combined because they all address one question:

how much real sponsorship exists behind current price movement.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not financial advice.

Pressure readings and divergences do not guarantee reversal or continuation.

Use the script as context and confirmation, not as a promise of outcome.

[b]Best Use Cases[/b]

[list]
[*]Measuring whether price movement is being sponsored by real participation
[*]Spotting divergence between price and internal pressure
[*]Reading expansion versus absorption conditions
[*]Combining participation context with VWAP and trend structure
[/list]

[b]Interpretation Notes[/b]

The strongest bullish pressure states usually include positive pressure, supportive spread, constructive effort, and favorable price context above value.

The strongest bearish pressure states are the mirror image.

Divergences are most useful when they appear after extension or at major contextual levels.

Absorption labels should be treated as warnings that apparent directional continuation may be losing quality.

[b]Publication Notes[/b]

This script is intended to be published with a clean chart where the oscillator, labeled divergence, and at least one price-context label are clearly visible.

Because there is no dashboard, the publication image should make the chart-side annotations easy to read.

Keep the chart clean so the viewer can immediately understand that the script links oscillator behavior back to price.

-Made with passion by jackofalltrades\

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("JOAT Pressure Composite [JOAT]", shorttitle = "JPC [JOAT]", overlay = false, max_lines_count = 220, max_labels_count = 220, max_bars_back = 4000)

string groupEngine = "Composite Engine"
string groupFilters = "Qualification"
string groupMTF = "Higher Timeframe"
string groupDisplay = "Display"
string groupPalette = "Palette"

string smoothType = input.string("EMA", "Smoothing Type", options = ["ALMA", "EMA", "SMA", "RMA", "WMA"], group = groupEngine)
int smoothLength = input.int(21, "Flow Smoothing", minval = 2, group = groupEngine)
float almaOffset = input.float(0.85, "ALMA Offset", minval = 0.0, maxval = 1.0, step = 0.05, group = groupEngine)
float almaSigma = input.float(6.0, "ALMA Sigma", minval = 0.1, step = 0.1, group = groupEngine)
int normalizationLength = input.int(120, "Normalization Length", minval = 30, group = groupEngine)
int relativeVolumeLength = input.int(30, "Relative Volume Baseline", minval = 5, group = groupEngine)
float relativeVolumeBoost = input.float(1.45, "Relative Volume Boost", minval = 1.0, step = 0.05, group = groupEngine)
int sigmaLength = input.int(34, "Volume Sigma Length", minval = 5, group = groupEngine)
int effortLength = input.int(13, "Effort Smoothing", minval = 2, group = groupEngine)
int efficiencyLength = input.int(21, "Efficiency Length", minval = 5, group = groupEngine)
int signalLength = input.int(9, "Signal Length", minval = 2, group = groupEngine)
int bandLength = input.int(34, "Envelope Length", minval = 10, group = groupEngine)
float bandMultiplier = input.float(1.35, "Envelope Multiplier", minval = 0.5, step = 0.05, group = groupEngine)
float extremeMultiplier = input.float(2.1, "Extreme Multiplier", minval = 1.0, step = 0.1, group = groupEngine)
int divergenceLength = input.int(5, "Pivot Length", minval = 2, group = groupEngine)
int divergenceScan = input.int(55, "Divergence Scan", minval = 10, maxval = 150, group = groupEngine)
int atrLength = input.int(14, "ATR Length", minval = 2, group = groupEngine)

bool useTrendGate = input.bool(true, "Use Trend Gate", group = groupFilters)
int trendFastLength = input.int(55, "Trend Fast EMA", minval = 5, group = groupFilters)
int trendSlowLength = input.int(144, "Trend Slow EMA", minval = 10, group = groupFilters)
bool useVwapGate = input.bool(false, "Use VWAP Gate", group = groupFilters)
float minimumExpansion = input.float(0.25, "Minimum Spread", minval = 0.0, step = 0.05, group = groupFilters)

bool showConfirmedMtf = input.bool(true, "Show Higher Timeframe States", group = groupMTF)
string timeframeOne = input.timeframe("60", "Timeframe 1", group = groupMTF)
string timeframeTwo = input.timeframe("240", "Timeframe 2", group = groupMTF)
string timeframeThree = input.timeframe("D", "Timeframe 3", group = groupMTF)

bool showHistogram = input.bool(true, "Show Histogram", group = groupDisplay)
bool showSignalLine = input.bool(true, "Show Signal Line", group = groupDisplay)
bool showEnvelope = input.bool(true, "Show Envelope", group = groupDisplay)
bool showFlowRibbon = input.bool(true, "Show Flow Ribbon", group = groupDisplay)
bool showDivergence = input.bool(true, "Show Divergence", group = groupDisplay)
bool showBarTint = input.bool(true, "Tint Price Bars", group = groupDisplay)
bool showPaneBackdrop = input.bool(true, "Shade Momentum States", group = groupDisplay)
bool showPriceContext = input.bool(true, "Show Price Context", group = groupDisplay)
bool showEventLabels = input.bool(true, "Show Price Event Labels", group = groupDisplay)

color bidStrong = input.color(color.rgb(38, 191, 150), "Bid Strong", group = groupPalette)
color bidSoft = input.color(color.rgb(98, 217, 184), "Bid Soft", group = groupPalette)
color offerStrong = input.color(color.rgb(214, 88, 118), "Offer Strong", group = groupPalette)
color offerSoft = input.color(color.rgb(182, 118, 136), "Offer Soft", group = groupPalette)
color accentColor = input.color(color.rgb(226, 196, 101), "Accent", group = groupPalette)
color neutralColor = input.color(color.rgb(122, 136, 163), "Neutral", group = groupPalette)
color panelBackground = input.color(color.rgb(12, 17, 28), "Label Background", group = groupPalette)
color panelBorder = input.color(color.rgb(42, 54, 76), "Context Border", group = groupPalette)

clampFloat(float value, float lowValue, float highValue) =>
    math.max(lowValue, math.min(highValue, value))

lerpColor(color colorA, color colorB, float weight) =>
    float t = clampFloat(weight, 0.0, 1.0)
    color.rgb(
         int(color.r(colorA) + (color.r(colorB) - color.r(colorA)) * t),
         int(color.g(colorA) + (color.g(colorB) - color.g(colorA)) * t),
         int(color.b(colorA) + (color.b(colorB) - color.b(colorA)) * t))

oscillatorColor(float value, float boundary) =>
    float scaled = boundary > 0 ? clampFloat(math.abs(value) / boundary, 0.0, 1.0) : 0.0
    value > 0 ? lerpColor(bidSoft, bidStrong, scaled) : value < 0 ? lerpColor(offerSoft, offerStrong, scaled) : neutralColor

movingAverage(float source, int length, string mode, float offsetValue, float sigmaValue) =>
    switch mode
        "ALMA" => ta.alma(source, length, offsetValue, sigmaValue)
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)
        "RMA" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        => ta.ema(source, length)

zScore(float source, int length) =>
    float basis = ta.sma(source, length)
    float deviation = ta.stdev(source, length)
    deviation > 0 ? (source - basis) / deviation : 0.0

stateText(float value) =>
    value > 1.25 ? "Bid" : value < -1.25 ? "Offer" : "Balanced"

stateColor(float value) =>
    value > 1.25 ? bidStrong : value < -1.25 ? offerStrong : neutralColor

float barRange = math.max(high - low, syminfo.mintick)
float closeLocationValue = (2.0 * close - low - high) / barRange
float averageVolume = ta.sma(volume, relativeVolumeLength)
float relativeVolume = averageVolume > 0 ? volume / averageVolume : 1.0
float weightedVolume = volume * (volume > averageVolume ? relativeVolumeBoost : 1.0) * (1.0 + math.abs(closeLocationValue))
float accumulationLine = ta.cum(closeLocationValue * weightedVolume)
float accumulationBase = movingAverage(accumulationLine, smoothLength, smoothType, almaOffset, almaSigma)
float pressureRaw = accumulationLine - accumulationBase
float pressureZ = zScore(pressureRaw, normalizationLength)

float volumeReturn = volume > 0 and volume[1] > 0 ? math.log(volume / volume[1]) : 0.0
float volumeVariance = ta.ema(volumeReturn * volumeReturn, sigmaLength)
float volumeSigma = math.sqrt(math.max(volumeVariance, 0.0))
float sigmaZ = zScore(volumeSigma, normalizationLength)

float effortRaw = closeLocationValue * relativeVolume
float effortLine = ta.ema(effortRaw, effortLength)
float effortZ = zScore(effortLine, normalizationLength)

float momentumBias = (ta.rsi(close, 14) - 50.0) / 10.0
float efficiencyStep = math.abs(ta.change(close))
float efficiencyCum = ta.cum(efficiencyStep)
float efficiencyPath = efficiencyCum - nz(efficiencyCum[efficiencyLength], 0.0)
float efficiencyBias = not na(close[efficiencyLength]) and efficiencyPath > 0 ? (close - close[efficiencyLength]) / efficiencyPath : 0.0
float anchoredVwap = ta.vwap(hlc3)
float atrValue = ta.atr(atrLength)
float vwapBias = atrValue > 0 ? (close - anchoredVwap) / atrValue : 0.0

float fastTrend = ta.ema(close, trendFastLength)
float slowTrend = ta.ema(close, trendSlowLength)
float trendSpread = atrValue > 0 ? (fastTrend - slowTrend) / atrValue : 0.0
bool bullTrend = fastTrend >= slowTrend and close >= slowTrend
bool bearTrend = fastTrend < slowTrend and close < slowTrend
bool bullVwap = close >= anchoredVwap
bool bearVwap = close < anchoredVwap

float composite = pressureZ * 0.34 + effortZ * 0.18 + sigmaZ * 0.16 + momentumBias * 0.14 + efficiencyBias * 0.10 + vwapBias * 0.08
float signalLine = ta.ema(composite, signalLength)
float spreadLine = composite - signalLine
float regimeBasis = ta.ema(composite, bandLength)
float regimeDeviation = ta.stdev(composite, bandLength)
float upperBand = regimeBasis + regimeDeviation * bandMultiplier
float lowerBand = regimeBasis - regimeDeviation * bandMultiplier
float upperExtreme = regimeBasis + regimeDeviation * extremeMultiplier
float lowerExtreme = regimeBasis - regimeDeviation * extremeMultiplier
float compressionRatio = regimeDeviation > 0 ? math.abs(spreadLine) / regimeDeviation : 0.0
float auctionSkew = (pressureZ + effortZ + vwapBias) / 3.0

bool flowBid = pressureZ > 0 and effortZ > 0
bool flowOffer = pressureZ < 0 and effortZ < 0
bool bullQualified = composite > 0 and spreadLine > minimumExpansion and flowBid and (not useTrendGate or bullTrend) and (not useVwapGate or bullVwap)
bool bearQualified = composite < 0 and spreadLine < -minimumExpansion and flowOffer and (not useTrendGate or bearTrend) and (not useVwapGate or bearVwap)
bool bullExpansion = barstate.isconfirmed and bullQualified and composite > upperBand
bool bearExpansion = barstate.isconfirmed and bearQualified and composite < lowerBand
bool bullExtreme = barstate.isconfirmed and bullQualified and composite > upperExtreme
bool bearExtreme = barstate.isconfirmed and bearQualified and composite < lowerExtreme
bool bullAbsorption = barstate.isconfirmed and pressureZ > 0 and effortZ < 0 and composite > 0 and spreadLine < 0
bool bearAbsorption = barstate.isconfirmed and pressureZ < 0 and effortZ > 0 and composite < 0 and spreadLine > 0
bool rotationUp = barstate.isconfirmed and composite > regimeBasis and spreadLine > 0 and auctionSkew > 0
bool rotationDown = barstate.isconfirmed and composite < regimeBasis and spreadLine < 0 and auctionSkew < 0

float regimeScore = clampFloat(50.0 + composite * 14.0 + spreadLine * 18.0 + trendSpread * 6.0, 0.0, 100.0)
float stabilityScore = clampFloat(55.0 + efficiencyBias * 28.0 - math.abs(sigmaZ) * 10.0, 0.0, 100.0)
string activeRegime = bullExtreme ? "Aggressive Bid" : bearExtreme ? "Aggressive Offer" : bullExpansion ? "Bid Expansion" : bearExpansion ? "Offer Expansion" : bullAbsorption ? "Bull Absorption" : bearAbsorption ? "Bear Absorption" : composite > 0 ? "Constructive Balance" : composite < 0 ? "Defensive Balance" : "Neutral"

float pivotHigh = ta.pivothigh(composite, divergenceLength, divergenceLength)
float pivotLow = ta.pivotlow(composite, divergenceLength, divergenceLength)

bool bullDivergence = false
bool bearDivergence = false

if showDivergence and not na(pivotLow) and barstate.isconfirmed
    int previousLowOffset = na
    float previousOscillatorLow = na
    for i = divergenceLength + 1 to divergenceScan
        if not na(pivotLow[i])
            previousLowOffset := i
            previousOscillatorLow := pivotLow[i]
            break
    if not na(previousLowOffset)
        float currentPriceLow = low[divergenceLength]
        float previousPriceLow = low[divergenceLength + previousLowOffset]
        bullDivergence := currentPriceLow < previousPriceLow and pivotLow > previousOscillatorLow
        if bullDivergence
            line.new(bar_index - divergenceLength - previousLowOffset, previousOscillatorLow, bar_index - divergenceLength, pivotLow, color = color.new(bidStrong, 0), width = 2)
            line.new(bar_index - divergenceLength - previousLowOffset, previousPriceLow, bar_index - divergenceLength, currentPriceLow, color = color.new(bidStrong, 10), width = 2, force_overlay = true)
            label.new(bar_index - divergenceLength, pivotLow, "Bull Div", style = label.style_label_up, textcolor = color.white, color = color.new(bidStrong, 72))
            if showEventLabels
                label.new(bar_index - divergenceLength, currentPriceLow - atrValue * 0.25, "Bullish Pressure Divergence", yloc = yloc.price, style = label.style_label_up, textcolor = color.white, color = color.new(bidStrong, 20), force_overlay = true)

if showDivergence and not na(pivotHigh) and barstate.isconfirmed
    int previousHighOffset = na
    float previousOscillatorHigh = na
    for i = divergenceLength + 1 to divergenceScan
        if not na(pivotHigh[i])
            previousHighOffset := i
            previousOscillatorHigh := pivotHigh[i]
            break
    if not na(previousHighOffset)
        float currentPriceHigh = high[divergenceLength]
        float previousPriceHigh = high[divergenceLength + previousHighOffset]
        bearDivergence := currentPriceHigh > previousPriceHigh and pivotHigh < previousOscillatorHigh
        if bearDivergence
            line.new(bar_index - divergenceLength - previousHighOffset, previousOscillatorHigh, bar_index - divergenceLength, pivotHigh, color = color.new(offerStrong, 0), width = 2)
            line.new(bar_index - divergenceLength - previousHighOffset, previousPriceHigh, bar_index - divergenceLength, currentPriceHigh, color = color.new(offerStrong, 10), width = 2, force_overlay = true)
            label.new(bar_index - divergenceLength, pivotHigh, "Bear Div", style = label.style_label_down, textcolor = color.white, color = color.new(offerStrong, 72))
            if showEventLabels
                label.new(bar_index - divergenceLength, currentPriceHigh + atrValue * 0.25, "Bearish Pressure Divergence", yloc = yloc.price, style = label.style_label_down, textcolor = color.white, color = color.new(offerStrong, 20), force_overlay = true)

[timeframeOneComposite, timeframeOneSpread] = request.security(syminfo.tickerid, timeframeOne, [composite[1], spreadLine[1]], lookahead = barmerge.lookahead_on)
[timeframeTwoComposite, timeframeTwoSpread] = request.security(syminfo.tickerid, timeframeTwo, [composite[1], spreadLine[1]], lookahead = barmerge.lookahead_on)
[timeframeThreeComposite, timeframeThreeSpread] = request.security(syminfo.tickerid, timeframeThree, [composite[1], spreadLine[1]], lookahead = barmerge.lookahead_on)

color histogramColor = oscillatorColor(composite, 2.8)
color lineColor = oscillatorColor(spreadLine, 1.4)
color signalColor = spreadLine >= 0 ? color.new(accentColor, 0) : color.new(neutralColor, 0)
color paneBackdrop = bullExtreme ? color.new(bidStrong, 88) : bearExtreme ? color.new(offerStrong, 88) : bullExpansion ? color.new(bidSoft, 92) : bearExpansion ? color.new(offerSoft, 92) : na
color priceBarTint = bullExtreme ? color.new(bidStrong, 0) : bearExtreme ? color.new(offerStrong, 0) : bullExpansion ? color.new(bidSoft, 25) : bearExpansion ? color.new(offerSoft, 25) : na

bgcolor(showPaneBackdrop ? paneBackdrop : na)
barcolor(showBarTint ? priceBarTint : na)

plot(showHistogram ? composite : na, "Composite Histogram", color = color.new(histogramColor, 8), style = plot.style_columns, linewidth = 3)
plotHandleComposite = plot(composite, "Composite Line", color = lineColor, linewidth = 2)
plotHandleSignal = plot(showSignalLine ? signalLine : na, "Signal", color = signalColor, linewidth = 2)
plot(showPriceContext ? anchoredVwap : na, "Anchored VWAP Context", color = color.new(accentColor, 0), linewidth = 2, force_overlay = true)
plot(showPriceContext ? fastTrend : na, "Fast Trend Context", color = color.new(bidSoft, 20), linewidth = 2, force_overlay = true)
plot(showPriceContext ? slowTrend : na, "Slow Trend Context", color = color.new(offerSoft, 25), linewidth = 2, force_overlay = true)
plot(pressureZ, "Pressure Z", color = color.new(histogramColor, 55), linewidth = 1, display = display.none)
plot(effortZ, "Effort Z", color = color.new(accentColor, 65), linewidth = 1, display = display.none)
plot(auctionSkew, "Auction Skew", color = color.new(accentColor, 50), linewidth = 1, display = display.none)
plot(compressionRatio, "Compression Ratio", color = color.new(neutralColor, 60), linewidth = 1, display = display.none)

plotHandleUpper = plot(showEnvelope ? upperBand : na, "Upper Band", color = color.new(bidStrong, 45), linewidth = 1)
plotHandleLower = plot(showEnvelope ? lowerBand : na, "Lower Band", color = color.new(offerStrong, 45), linewidth = 1)
plotHandleExtremeUpper = plot(showEnvelope ? upperExtreme : na, "Upper Extreme", color = color.new(bidStrong, 75), linewidth = 1)
plotHandleExtremeLower = plot(showEnvelope ? lowerExtreme : na, "Lower Extreme", color = color.new(offerStrong, 75), linewidth = 1)
fill(plotHandleComposite, plotHandleSignal, color = showFlowRibbon ? color.new(spreadLine >= 0 ? bidStrong : offerStrong, 90) : na, title = "Flow Ribbon")
fill(plotHandleUpper, plotHandleLower, color = color.new(neutralColor, 92), title = "Envelope Fill")
fill(plotHandleExtremeUpper, plotHandleUpper, color = color.new(bidStrong, 92), title = "Upper Tail")
fill(plotHandleExtremeLower, plotHandleLower, color = color.new(offerStrong, 92), title = "Lower Tail")

hline(0.0, "Zero", color = color.new(neutralColor, 45))
hline(1.0, "Positive Threshold", color = color.new(bidSoft, 75))
hline(-1.0, "Negative Threshold", color = color.new(offerSoft, 75))
hline(2.0, "Bid Extreme", color = color.new(bidStrong, 82))
hline(-2.0, "Offer Extreme", color = color.new(offerStrong, 82))
hline(0.5, "Rotation Threshold", color = color.new(accentColor, 85))
hline(-0.5, "Negative Rotation Threshold", color = color.new(accentColor, 85))

var line vwapGuide = na
var line fastGuide = na
var line slowGuide = na
var label regimeLabel = na
var label mtfLabel = na

if barstate.islast
    int rightEdge = bar_index + 14
    if showPriceContext
        if na(vwapGuide)
            vwapGuide := line.new(bar_index - 8, anchoredVwap, rightEdge, anchoredVwap, color = color.new(accentColor, 0), width = 2, style = line.style_dashed, force_overlay = true)
            fastGuide := line.new(bar_index - 8, fastTrend, rightEdge, fastTrend, color = color.new(bidSoft, 5), width = 2, style = line.style_solid, force_overlay = true)
            slowGuide := line.new(bar_index - 8, slowTrend, rightEdge, slowTrend, color = color.new(offerSoft, 5), width = 2, style = line.style_solid, force_overlay = true)
        line.set_xy1(vwapGuide, bar_index - 8, anchoredVwap)
        line.set_xy2(vwapGuide, rightEdge, anchoredVwap)
        line.set_color(vwapGuide, color.new(accentColor, 0))
        line.set_xy1(fastGuide, bar_index - 8, fastTrend)
        line.set_xy2(fastGuide, rightEdge, fastTrend)
        line.set_color(fastGuide, color.new(bidSoft, 5))
        line.set_xy1(slowGuide, bar_index - 8, slowTrend)
        line.set_xy2(slowGuide, rightEdge, slowTrend)
        line.set_color(slowGuide, color.new(offerSoft, 5))
    else
        if not na(vwapGuide)
            line.delete(vwapGuide)
            line.delete(fastGuide)
            line.delete(slowGuide)
            vwapGuide := na
            fastGuide := na
            slowGuide := na

    if showEventLabels
        string regimeText = activeRegime + " | " + (bullTrend ? "Trend Bull" : bearTrend ? "Trend Bear" : "Trend Neutral")
        string htfText = showConfirmedMtf ? timeframeOne + " " + stateText(timeframeOneComposite) + " | " + timeframeTwo + " " + stateText(timeframeTwoComposite) + " | " + timeframeThree + " " + stateText(timeframeThreeComposite) : "HTF Off"
        if na(regimeLabel)
            regimeLabel := label.new(bar_index, high + atrValue * 1.1, regimeText, yloc = yloc.price, style = label.style_label_left, color = color.new(panelBackground, 5), textcolor = bullExpansion or bullExtreme ? bidStrong : bearExpansion or bearExtreme ? offerStrong : accentColor, force_overlay = true)
            mtfLabel := label.new(bar_index, high + atrValue * 1.7, htfText, yloc = yloc.price, style = label.style_label_left, color = color.new(panelBackground, 5), textcolor = neutralColor, force_overlay = true)
        label.set_xy(regimeLabel, bar_index, high + atrValue * 1.1)
        label.set_text(regimeLabel, regimeText)
        label.set_color(regimeLabel, color.new(panelBackground, 5))
        label.set_textcolor(regimeLabel, bullExpansion or bullExtreme ? bidStrong : bearExpansion or bearExtreme ? offerStrong : accentColor)
        label.set_xy(mtfLabel, bar_index, high + atrValue * 1.7)
        label.set_text(mtfLabel, htfText)
        label.set_color(mtfLabel, color.new(panelBackground, 5))
        label.set_textcolor(mtfLabel, neutralColor)

if showEventLabels and bullExpansion
    label.new(bar_index, low - atrValue * 0.35, "Bid Expansion", yloc = yloc.price, style = label.style_label_up, color = color.new(bidStrong, 12), textcolor = color.white, force_overlay = true)
if showEventLabels and bearExpansion
    label.new(bar_index, high + atrValue * 0.35, "Offer Expansion", yloc = yloc.price, style = label.style_label_down, color = color.new(offerStrong, 12), textcolor = color.white, force_overlay = true)
if showEventLabels and bullAbsorption
    label.new(bar_index, low - atrValue * 0.60, "Bull Absorption", yloc = yloc.price, style = label.style_label_up, color = color.new(bidSoft, 8), textcolor = color.white, force_overlay = true)
if showEventLabels and bearAbsorption
    label.new(bar_index, high + atrValue * 0.60, "Bear Absorption", yloc = yloc.price, style = label.style_label_down, color = color.new(offerSoft, 8), textcolor = color.white, force_overlay = true)

alertcondition(bullExpansion, "Bid Expansion", "Pressure Composite bid expansion on {{ticker}}")
alertcondition(bearExpansion, "Offer Expansion", "Pressure Composite offer expansion on {{ticker}}")
alertcondition(bullExtreme, "Aggressive Bid", "Pressure Composite aggressive bid on {{ticker}}")
alertcondition(bearExtreme, "Aggressive Offer", "Pressure Composite aggressive offer on {{ticker}}")
alertcondition(barstate.isconfirmed and bullDivergence, "Bullish Divergence", "Pressure Composite bullish divergence on {{ticker}}")
alertcondition(barstate.isconfirmed and bearDivergence, "Bearish Divergence", "Pressure Composite bearish divergence on {{ticker}}")
alertcondition(rotationUp, "Rotation Up", "Pressure Composite rotation up on {{ticker}}")
alertcondition(rotationDown, "Rotation Down", "Pressure Composite rotation down on {{ticker}}")
````
