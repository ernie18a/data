# TRIX Chart Divergence

- url: https://www.tradingview.com/script/ZEq6W0sH-TRIX-Chart-Divergence/
- type: indicator
- pine_id: PUB;23b57f726e914d389f1db46903273083
- version: 2.0

## Description

TRIX Chart Divergence is based on one of my favorite oscillators.

The main feature of this indicator is that TRIX divergences are drawn not only in the oscillator pane, but also directly on the price chart.

This makes divergence much easier to read, especially for intraday trading and scalping. Instead of looking back and forth between price and the oscillator, you can immediately see where price made a new high or low and where TRIX failed to confirm that move.

For me, this is the most useful way to work with TRIX.

A bullish divergence appears when price makes a lower low, but TRIX does not confirm that move and forms a higher low. A bearish divergence appears when price makes a higher high, but TRIX does not confirm it and forms a lower high.

This type of divergence can warn about a possible correction or trend reversal. I especially like watching TRIX divergences on higher timeframes, because they can mark important exhaustion points. The indicator includes alerts for bullish and bearish divergences, so you can monitor multiple instruments and timeframes without watching every chart all the time.

I also use TRIX on the 1-minute gold chart for intraday trading. On lower timeframes, I use it  together with my own setups, price action, levels and other confirmation tools.

TRIX is simple and clean. When the TRIX line crosses the signal line in the lower area, it can show a possible bullish momentum shift. When the cross appears in the upper area, it can show a possible bearish momentum shift. In this indicator, bullish and bearish TRIX crosses are marked with small green and red dots.

TRIX does not have fixed overbought and oversold levels like RSI or Stochastic. That is why I added adaptive range levels. These levels show where TRIX is trading compared to its recent range. When TRIX moves outside this adaptive range, it can highlight stronger momentum extremes.

The adaptive range levels are optional. You can use the indicator in the classic way without them, or keep them on as an additional visual guide.

Main features:
- TRIX and signal line
- Histogram
- Small green and red dots on TRIX crossovers
- Bullish and bearish TRIX divergences
- Divergence lines in the oscillator pane
- Optional divergence lines directly on the price chart
- Optional adaptive TRIX range levels
- Alerts for TRIX crosses and divergences

Settings:

TRIX Length / Signal Length
Controls the basic TRIX calculation and signal line. Lower values make the oscillator more sensitive. Higher values make it smoother.

Adaptive Range Levels
Optional dynamic levels that show where TRIX is trading compared to its recent range. They can help identify stronger momentum extremes. You can turn them off if you prefer the classic TRIX view.

Range Lookback Bars
Defines how many previous bars are used to calculate the adaptive range. A larger value makes the range smoother and more stable. A smaller value makes it react faster.

Range Smoothing
Smooths the adaptive range levels.

TRIX Pivot Sensitivity
Controls how sensitive divergence detection is. Lower values find more divergences. Higher values show fewer but cleaner divergences.

Price Search Radius
Allows the script to search around the TRIX pivot and find the closest price high or low for drawing the divergence line.

Max Bars Between Points
Defines the maximum distance between two TRIX pivot points used for divergence detection.

Draw divergence line on TRIX
Shows the divergence line in the oscillator pane.

Draw divergence line on price chart
Shows the same divergence directly on the price chart.

Important:

This indicator is not a standalone trading system.

TRIX crosses and divergences are designed to help identify momentum shifts, exhaustion points and possible correction zones.

For best results, use it together with price action, support and resistance, trend structure, higher timeframe context and your own confirmation setup.

A divergence can warn about a possible correction or reversal, but it does not mean that price must reverse immediately.

## Source Code

````pine
//@version=6
indicator("TRIX Chart Divergence [josseliani]", shorttitle="TRIX Chart Div [josseliani]", overlay=false, max_lines_count=300, max_labels_count=300, max_bars_back=1000)

//====================================================
// Inputs
//====================================================
groupTrix = "TRIX Settings"
trixLen = input.int(9, "TRIX Length", minval=1, group=groupTrix)
signalLen = input.int(5, "Signal Length", minval=1, group=groupTrix)
src = input.source(close, "Source", group=groupTrix)

groupRange = "Adaptive Range Levels"
showAdaptiveRange = input.bool(true, "Show adaptive range levels", group=groupRange)
rangeLookback = input.int(100, "Range Lookback Bars", minval=20, maxval=1000, group=groupRange)
rangeSmoothLen = input.int(5, "Range Smoothing", minval=1, maxval=50, group=groupRange)

groupDiv = "Divergence Settings"
showDivergence = input.bool(true, "Show divergences", group=groupDiv)

pivotStrength = input.int(
     3,
     "TRIX Pivot Sensitivity",
     minval=1,
     maxval=20,
     group=groupDiv,
     tooltip="Controls pivot sensitivity. Lower values find more pivots; higher values show fewer, larger pivots."
     )

priceSearchRadius = input.int(
     5,
     "Price Search Radius",
     minval=0,
     maxval=50,
     group=groupDiv,
     tooltip="Searches around the TRIX pivot for the nearest price high or low used to draw the divergence line."
     )

maxBarsBetweenPoints = input.int(
     80,
     "Max Bars Between Points",
     minval=5,
     maxval=500,
     group=groupDiv,
     tooltip="Maximum number of bars allowed between the two TRIX pivot points used for divergence detection."
     )

showOscDivLines = input.bool(true, "Draw divergence line on TRIX", group=groupDiv)
showPriceDivLines = input.bool(true, "Draw divergence line on price chart", group=groupDiv)

groupView = "Display"
showHistogram = input.bool(true, "Show histogram", group=groupView)
showCrossDots = input.bool(true, "Show crossover dots", group=groupView)
showDivTriangles = input.bool(true, "Show white divergence triangles", group=groupView)
showZeroLine = input.bool(true, "Show zero line", group=groupView)

//====================================================
// Internal Settings
//====================================================
upperPercentile = 85.0
lowerPercentile = 15.0
maxDivLines = 50

//====================================================
// TRIX Calculation
//====================================================
ema1 = ta.ema(src, trixLen)
ema2 = ta.ema(ema1, trixLen)
ema3 = ta.ema(ema2, trixLen)

trix = ema3[1] != 0 ? 100 * (ema3 - ema3[1]) / ema3[1] : 0.0
signal = ta.ema(trix, signalLen)
hist = trix - signal

//====================================================
// Adaptive Range Levels
//====================================================
rawUpperRange = ta.percentile_nearest_rank(trix, rangeLookback, upperPercentile)
rawLowerRange = ta.percentile_nearest_rank(trix, rangeLookback, lowerPercentile)
rawMidRange = ta.percentile_nearest_rank(trix, rangeLookback, 50.0)

upperRange = ta.ema(rawUpperRange, rangeSmoothLen)
lowerRange = ta.ema(rawLowerRange, rangeSmoothLen)
midRange = ta.ema(rawMidRange, rangeSmoothLen)

//====================================================
// Cross Conditions
//====================================================
crossUp = ta.crossover(trix, signal)
crossDown = ta.crossunder(trix, signal)

//====================================================
// Functions
//====================================================
f_priceLowNearPivot(int centerOffset, int radius) =>
    int startOffset = math.max(centerOffset - radius, 0)
    int endOffset = math.min(centerOffset + radius, bar_index)
    float bestLow = low[startOffset]
    int bestBar = bar_index - startOffset
    for i = startOffset to endOffset
        if not na(low[i]) and low[i] < bestLow
            bestLow := low[i]
            bestBar := bar_index - i
    [bestLow, bestBar]

f_priceHighNearPivot(int centerOffset, int radius) =>
    int startOffset = math.max(centerOffset - radius, 0)
    int endOffset = math.min(centerOffset + radius, bar_index)
    float bestHigh = high[startOffset]
    int bestBar = bar_index - startOffset
    for i = startOffset to endOffset
        if not na(high[i]) and high[i] > bestHigh
            bestHigh := high[i]
            bestBar := bar_index - i
    [bestHigh, bestBar]

f_addLine(line[] arr, line ln, int maxCount) =>
    array.push(arr, ln)
    if array.size(arr) > maxCount
        oldLine = array.shift(arr)
        line.delete(oldLine)

//====================================================
// Original Divergence Logic
//====================================================
var float prevBullTrix = na
var int prevBullTrixBar = na
var float prevBullPriceLow = na
var int prevBullPriceLowBar = na

var float prevBearTrix = na
var int prevBearTrixBar = na
var float prevBearPriceHigh = na
var int prevBearPriceHighBar = na

var line[] oscLines = array.new_line()
var line[] priceLines = array.new_line()

bool bullDiv = false
bool bearDiv = false

float bullSignalY = na
float bearSignalY = na

trixPivotLow = ta.pivotlow(trix, pivotStrength, pivotStrength)
trixPivotHigh = ta.pivothigh(trix, pivotStrength, pivotStrength)

//====================================================
// Bullish Divergence
//====================================================
if showDivergence and not na(trixPivotLow)
    currBullTrix = trix[pivotStrength]
    currBullBar = bar_index - pivotStrength
    [currPriceLow, currPriceLowBar] = f_priceLowNearPivot(pivotStrength, priceSearchRadius)

    validBullZone = currBullTrix < 0
    validPrevBull = not na(prevBullTrix) and not na(prevBullTrixBar) and not na(prevBullPriceLow) and not na(prevBullPriceLowBar)

    barsBetweenBull = validPrevBull ? currBullBar - prevBullTrixBar : na
    trixHigherLow = validPrevBull and currBullTrix > prevBullTrix
    priceLowerLow = validPrevBull and currPriceLow < prevBullPriceLow
    inBullWindow = validPrevBull and barsBetweenBull > 0 and barsBetweenBull <= maxBarsBetweenPoints

    bullDiv := validBullZone and trixHigherLow and priceLowerLow and inBullWindow
    bullSignalY := bullDiv ? currBullTrix : na

    if bullDiv and showOscDivLines
        oscLine = line.new(
             prevBullTrixBar,
             prevBullTrix,
             currBullBar,
             currBullTrix,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.lime,
             style=line.style_dashed,
             width=1
             )
        f_addLine(oscLines, oscLine, maxDivLines)

    if bullDiv and showPriceDivLines
        priceLine = line.new(
             prevBullPriceLowBar,
             prevBullPriceLow,
             currPriceLowBar,
             currPriceLow,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.lime,
             style=line.style_dashed,
             width=1,
             force_overlay=true
             )
        f_addLine(priceLines, priceLine, maxDivLines)

    if validBullZone
        prevBullTrix := currBullTrix
        prevBullTrixBar := currBullBar
        prevBullPriceLow := currPriceLow
        prevBullPriceLowBar := currPriceLowBar

//====================================================
// Bearish Divergence
//====================================================
if showDivergence and not na(trixPivotHigh)
    currBearTrix = trix[pivotStrength]
    currBearBar = bar_index - pivotStrength
    [currPriceHigh, currPriceHighBar] = f_priceHighNearPivot(pivotStrength, priceSearchRadius)

    validBearZone = currBearTrix > 0
    validPrevBear = not na(prevBearTrix) and not na(prevBearTrixBar) and not na(prevBearPriceHigh) and not na(prevBearPriceHighBar)

    barsBetweenBear = validPrevBear ? currBearBar - prevBearTrixBar : na
    trixLowerHigh = validPrevBear and currBearTrix < prevBearTrix
    priceHigherHigh = validPrevBear and currPriceHigh > prevBearPriceHigh
    inBearWindow = validPrevBear and barsBetweenBear > 0 and barsBetweenBear <= maxBarsBetweenPoints

    bearDiv := validBearZone and trixLowerHigh and priceHigherHigh and inBearWindow
    bearSignalY := bearDiv ? currBearTrix : na

    if bearDiv and showOscDivLines
        oscLine = line.new(
             prevBearTrixBar,
             prevBearTrix,
             currBearBar,
             currBearTrix,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.red,
             style=line.style_dashed,
             width=1
             )
        f_addLine(oscLines, oscLine, maxDivLines)

    if bearDiv and showPriceDivLines
        priceLine = line.new(
             prevBearPriceHighBar,
             prevBearPriceHigh,
             currPriceHighBar,
             currPriceHigh,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.red,
             style=line.style_dashed,
             width=1,
             force_overlay=true
             )
        f_addLine(priceLines, priceLine, maxDivLines)

    if validBearZone
        prevBearTrix := currBearTrix
        prevBearTrixBar := currBearBar
        prevBearPriceHigh := currPriceHigh
        prevBearPriceHighBar := currPriceHighBar

//====================================================
// Plots
//====================================================
plot(showZeroLine ? 0 : na, "Zero Line", color=color.new(color.gray, 70), linewidth=1)

plot(showAdaptiveRange ? upperRange : na, "Upper Adaptive Range", color=color.new(color.red, 25), linewidth=1)
plot(showAdaptiveRange ? lowerRange : na, "Lower Adaptive Range", color=color.new(color.lime, 25), linewidth=1)
plot(showAdaptiveRange ? midRange : na, "Adaptive Range Midline", color=color.new(color.gray, 85), linewidth=1)

plot(trix, "TRIX", color=color.lime, linewidth=2)
plot(signal, "Signal", color=color.red, linewidth=2)

histColor = hist >= 0 ? (hist > hist[1] ? color.new(color.lime, 0) : color.new(color.green, 45)) : (hist < hist[1] ? color.new(color.red, 0) : color.new(color.maroon, 45))
plot(showHistogram ? hist : na, "Histogram", style=plot.style_columns, color=histColor)

plotshape(showCrossDots and crossUp ? trix : na, title="TRIX Bullish Cross", style=shape.circle, location=location.absolute, color=color.lime, size=size.tiny)
plotshape(showCrossDots and crossDown ? trix : na, title="TRIX Bearish Cross", style=shape.circle, location=location.absolute, color=color.red, size=size.tiny)

plotshape(showDivTriangles and bullDiv ? bullSignalY : na, title="Bullish TRIX Divergence", style=shape.triangleup, location=location.absolute, color=color.white, size=size.tiny)
plotshape(showDivTriangles and bearDiv ? bearSignalY : na, title="Bearish TRIX Divergence", style=shape.triangledown, location=location.absolute, color=color.white, size=size.tiny)

//====================================================
// Alerts
//====================================================
alertcondition(crossUp, title="TRIX Bullish Cross", message="TRIX bullish cross on {{ticker}} {{interval}}")
alertcondition(crossDown, title="TRIX Bearish Cross", message="TRIX bearish cross on {{ticker}} {{interval}}")
alertcondition(bullDiv, title="Bullish TRIX Divergence", message="Bullish TRIX divergence on {{ticker}} {{interval}}")
alertcondition(bearDiv, title="Bearish TRIX Divergence", message="Bearish TRIX divergence on {{ticker}} {{interval}}")
````
