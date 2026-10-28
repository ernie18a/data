# Rolling Trend Pointer. Identify the True Market Trend

- url: https://www.tradingview.com/script/U3wMQFMG-Rolling-Trend-Pointer-Identify-the-True-Market-Trend/
- type: indicator
- pine_id: PUB;c469b33b5ac34b03adf6d09345fa9d73
- version: 1.0

## Description

[b]Rolling Trend Pointer[/b] is designed to provide an objective assessment of market direction, confirm trending conditions, and filter trading signals that occur in weak or conflicting market environments. Instead of relying on a conventional moving average, the indicator analyzes price position relative to VWAP, trading volume, the statistical magnitude of price deviations, the slope of Anchored VWAP, and directional agreement across multiple calculation periods.
Its main advantage is that it does not simply show whether price is above or below an average line. It evaluates the current trend direction, the strength of the active price impulse, and the degree of agreement between short-term price behavior and the broader volume-weighted market direction.

[b]Two Indicators Combined into One[/b]

Rolling Trend Pointer combines two interconnected indicator components:
1. "Rolling VWAP Trend Pointer", displayed in a separate indicator panel below the chart.
2. "Monthly Anchored VWAP with Multi-Period Confirmation", displayed directly on the main price chart.

The first component measures the current deviation of price from a rolling VWAP and determines whether the movement is statistically significant.
The second component determines the broader market direction based on the slope of the Monthly Anchored VWAP. It can also confirm that direction using Quarterly, Semiannual, and Annual Anchored VWAP calculations.
The "Synchronized Mode" checkbox connects both components into a single trend-confirmation system. When synchronization is enabled, the background fill on the main chart appears only when the Anchored VWAP direction agrees with the direction of the Rolling VWAP histogram.

[b]Part 1: Rolling VWAP Trend Pointer[/b]

The first component is displayed in a separate indicator panel and consists of:
* a green and red histogram;
* an upper positive boundary;
* a lower negative boundary;
* a zero line;
* a colored background indicating a strong breakout beyond the corresponding boundary.

The calculation is based on a Rolling VWAP, which is a volume-weighted average price calculated over the selected number of bars.

After calculating the VWAP, the indicator measures the distance between price and the VWAP:
* positive values are generated when price is positioned above the VWAP;
* negative values are generated when price is positioned below the VWAP.

The green histogram represents positive price deviation from the Rolling VWAP. The red histogram represents negative deviation.
The larger the absolute histogram value, the further price has moved away from its current volume-weighted center.

[b]Separate Positive and Negative Boundary Calculations[/b]

The upper and lower blue boundary lines are calculated independently.
The upper boundary uses only historical values above zero. It is designed to evaluate positive deviations and bullish price impulses.
The lower boundary uses only historical values below zero. The indicator analyzes the absolute magnitude of these negative deviations and then returns the calculated boundary to the negative area.
As a result, the lower boundary is not simply a mirrored version of the upper boundary. Each side adapts independently to the historical characteristics of bullish and bearish price movements.
This distinction is important because upward and downward volatility are often structurally different. Declines may occur quickly and aggressively, while bullish movements may develop more gradually and persist for longer periods.
Using separate calculations allows the indicator to adapt to this asymmetry instead of assuming that positive and negative price behavior is identical.

[b]Detecting Strong Price Impulses[/b]

When the histogram remains between the two blue boundaries, the price deviation is considered normal for the current market environment.
When the positive histogram rises above the upper boundary, the indicator identifies a strong bullish impulse. The background of the separate indicator panel becomes green.
When the negative histogram falls below the lower boundary, the indicator identifies a strong bearish impulse. The background becomes red.
A boundary breakout should not automatically be treated as an independent entry signal. It indicates that the current movement has become significantly stronger than the price deviations recently observed in the instrument.

[b]Part 2: Monthly Anchored VWAP[/b]

The second component is displayed directly on the main price chart.
It includes:
* the Monthly Anchored VWAP;
* upper and lower statistical bands;
* a VWAP line color based on its slope;
* a colored fill between the VWAP bands;
* optional confirmation from Quarterly, Semiannual, and Annual Anchored VWAP calculations.

The Monthly VWAP calculation resets at the beginning of every calendar month.
Unlike the Rolling VWAP, which uses a continuously moving lookback window, the Monthly Anchored VWAP accumulates price and volume data from the beginning of the current month.
When the Monthly VWAP slope is positive, the central line becomes green.
When the Monthly VWAP slope is negative, the central line becomes red.
The upper and lower bands are calculated using the volume-weighted standard deviation of price around the Monthly VWAP. These bands create a dynamic range that reflects the current price structure and volatility within the month.

[b]Multi-Period Trend Confirmation[/b]

By default, the trend direction is determined by the Monthly Anchored VWAP.
The following additional confirmation periods can be enabled in the settings:
* "Use Quarterly VWAP Confirmation"
* "Use Semiannual VWAP Confirmation"
* "Use Annual VWAP Confirmation"

The additional confirmation periods use AND logic.
For example, when Quarterly and Annual confirmation are enabled, a bullish trend will be confirmed only when the Monthly, Quarterly, and Annual VWAP slopes are all positive at the same time.
A bearish trend will be confirmed only when all enabled VWAP periods have negative slopes.
The more confirmation periods that are enabled, the stricter the trend filter becomes.
This reduces the number of confirmed trend conditions but increases the degree of agreement across different market horizons.

[b]Synchronized Mode[/b]

The "Synchronized Mode" setting is one of the main features of the indicator.
When synchronization is disabled, the fill between the VWAP bands on the main chart is determined only by the Monthly Anchored VWAP direction and the selected additional confirmation periods.
When synchronization is enabled, two conditions must be satisfied simultaneously:
* the Anchored VWAP direction must be confirmed;
* the Rolling VWAP histogram must be positioned on the corresponding side of the zero line.

A green fill requires:
* bullish Anchored VWAP confirmation;
* a positive Rolling VWAP histogram.

A red fill requires:
* bearish Anchored VWAP confirmation;
* a negative Rolling VWAP histogram.

When the two indicator components point in opposite directions, the background fill disappears.
This indicates that there is no complete agreement between the current price impulse and the broader Anchored VWAP trend.

[b]How to Interpret the Background Color on the Main Chart[/b]

The background fill between the Monthly Anchored VWAP bands is one of the most important visual elements of the indicator.
Particular attention should be paid to both the color and intensity of this background.
A light green fill indicates a confirmed bullish trend.
A stronger green fill indicates a confirmed bullish trend combined with a strong positive histogram breakout above the upper statistical boundary.
A light red fill indicates a confirmed bearish trend.
A stronger red fill indicates a confirmed bearish trend combined with a strong negative histogram breakout below the lower statistical boundary.
No background fill means that the indicator has not detected a synchronized directional condition.

This may occur during:
* sideways market conditions;
* transitional periods;
* weakening trends;
* disagreement between the Rolling VWAP component and the Anchored VWAP component;
* disagreement between the enabled Anchored VWAP confirmation periods.

The background color therefore represents the confirmed trend direction, while its intensity indicates whether the trend is also accompanied by an unusually strong statistical price impulse.

[b]Rolling Trend Pointer Settings[/b]

[i]VWAP Length[/i]
This setting determines the amount of positive and negative historical observations used to calculate the Rolling VWAP environment and the adaptive channel boundaries.
A lower value makes the indicator more responsive to recent market changes but may produce more frequent directional changes.
A higher value creates more stable statistical boundaries but causes the indicator to adapt more slowly when volatility conditions change.
The default value is "200".

[i]Band Multiplier[/i]
This setting controls the distance between the zero line and the independent positive and negative boundaries.
A lower value moves the boundaries closer to zero and increases the number of detected breakouts.
A higher value moves the boundaries further away from zero and filters out weaker movements, leaving only stronger price impulses.
The default value is "0.5".

[i]Channel Mode[/i]
Two channel calculation modes are available.

[i]Current VWAP Variance[/i]
This mode uses the current volume-weighted variance of the positive and negative samples.
It adapts more quickly to the current distribution and volatility structure of the market.

[i]Channel Width[/i]
This mode uses the historical variance of deviations from the corresponding positive and negative mean values.
It evaluates the established width of the distribution based on accumulated historical residuals.
For most trend-detection applications, testing should begin with "Current VWAP Variance".

[i]Histogram Smoothing[/i]
The following histogram smoothing methods are available:
* None;
* SMA;
* EMA;
* WMA;
* RMA.

Smoothing reduces small histogram fluctuations and limits unnecessary directional changes around the zero line.
It is important to understand that smoothing is applied to the displayed histogram and to the histogram breakout conditions.
The statistical upper and lower boundaries continue to be calculated from the original positive and negative observations.

[i]Histogram Smoothing Length[/i]
This setting controls the length of the selected histogram smoothing method.
A lower value preserves responsiveness.
A higher value produces a more stable histogram but increases calculation lag.
The default value is "10".

[i]Synchronized Mode[/i]
This checkbox synchronizes the Rolling VWAP Trend Pointer with the Monthly Anchored VWAP component.
When enabled, the background fill on the main price chart appears only when both components agree on the market direction.
For normal visual analysis, this setting should generally remain enabled.

[i]Show Breakout Background[/i]
This setting enables or disables the green and red background in the separate indicator panel when the histogram moves beyond its corresponding statistical boundary.

[b]Monthly Anchored VWAP Settings[/b]

[i]VWAP Source[/i]
This setting determines the price source used for the Anchored VWAP calculation.
The default source is "HLC3", which represents the average of the high, low, and close prices.

[i]Band Multiplier[/i]
This setting determines the width of the upper and lower bands around the Monthly Anchored VWAP.
A lower value produces a narrower range.
A higher value produces a wider range and includes more substantial price deviations.

[i]VWAP Slope Length[/i]
This setting determines the number of bars used to evaluate the direction of the VWAP slope.
A lower value reacts more quickly to changes in direction but may create more frequent trend switches.
A higher value produces a more stable trend direction but introduces additional delay.
The default value is "2".

[i]Line Width[/i]
This setting changes the thickness of the Monthly Anchored VWAP line and its upper and lower bands.

[i]Show VWAP Bands[/i]
This setting enables or disables the display of the upper and lower Monthly Anchored VWAP bands.

[i]Use Quarterly VWAP Confirmation[/i]
When enabled, the Monthly VWAP direction must agree with the Quarterly Anchored VWAP direction.

[i]Use Semiannual VWAP Confirmation[/i]
When enabled, the Monthly VWAP direction must agree with the Semiannual Anchored VWAP direction.

[i]Use Annual VWAP Confirmation[/i]
When enabled, the Monthly VWAP direction must agree with the Annual Anchored VWAP direction.

[b]Trend Direction Output for Strategy Integration[/b]
The indicator outputs the detected trend direction through a separate numerical variable called `trend_dir`.
This variable can be selected as an external data source and connected to other TradingView indicators or strategies.
The output ranges from "−2 to +2".

Possible values are:
* "+2" — confirmed strong bullish trend with a bullish histogram breakout;
* "+1" — confirmed bullish trend without a strong histogram breakout;
* "0" — neutral, conflicting, or unsynchronized market condition;
* "−1" — confirmed bearish trend without a strong histogram breakout;
* "−2" — confirmed strong bearish trend with a bearish histogram breakout.

This structure allows the indicator to be used not only for visual market analysis but also as a systematic trend filter inside automated trading strategies.

For example, a strategy can:
* allow long positions only when `trend_dir` equals +1 or +2;
* allow short positions only when `trend_dir` equals −1 or −2;
* disable entries during neutral conditions;
* test the neutral value separately;
* apply different trend requirements to long and short trades;
* distinguish between regular trends and statistically strong trend impulses.

[b]My Strategy Test Results[/b]

In my case, the strategy produced the highest long-trade win rate when the value "+1" was used as the trend filter for long entries.
For short trades, the best result was obtained when the value "0" was used.
This means that long entries performed best during a confirmed bullish trend that was not accompanied by an extreme positive histogram breakout.
Short entries performed best during neutral or unsynchronized market conditions rather than during an already confirmed bearish impulse.
The value "0" is not inherently bearish.
It indicates that the indicator has not detected complete directional agreement between its components.
These results apply to the specific strategy, instrument, timeframe, settings, and historical period that were tested.
Each of the five `trend_dir` states should be tested independently before being applied to another strategy or market.

[b]Practical Applications[/b]

Rolling Trend Pointer can be used for:
* identifying the main market direction;
* filtering entries against the prevailing trend;
* confirming breakout conditions;
* avoiding trades during conflicting market states;
* separating regular trends from strong trend impulses;
* providing an external trend variable to automated strategies;
* optimizing different filters for long and short positions;
* identifying periods of agreement between short-term momentum and broader volume-weighted direction.

For visual trading, it is recommended to keep "Synchronized Mode" enabled and focus primarily on the fill between the Monthly Anchored VWAP bands on the main chart.
A green or red fill indicates a synchronized directional condition.
A stronger fill indicates that the synchronized trend is also supported by a statistically significant histogram breakout.
The absence of a fill indicates that the current impulse and the broader Anchored VWAP direction are not fully synchronized.

[b]Use Rolling Trend Pointer to identify market direction, filter weak signals, and connect an objective trend state to your trading strategies.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Smollet

//@version=6
indicator("TREND: Rolling Trend Pointer", overlay = false)

//Rolling Trend Pointer --------------------------------------
//────────────────────────────────────────────────────────────────────
// Settings
//────────────────────────────────────────────────────────────────────

length = input.int(200, "VWAP Length", minval = 2, group = "Rolling Trend Pointer")
mult = input.float(0.5, "Band Multiplier", minval = 0.0, group = "Rolling Trend Pointer")
channelMode = input.string("Current VWAP Variance", "Channel Mode", options = ["Current VWAP Variance", "Channel Width"], group = "Rolling Trend Pointer")
histogramSmoothing = input.string("RMA", "Histogram Smoothing", options = ["None", "SMA", "EMA", "WMA", "RMA"], group = "Rolling Trend Pointer")
histogramSmoothingLength = input.int(10, "Histogram Smoothing Length", minval = 1, group = "Rolling Trend Pointer")
synchronizedMode = input.bool(true, "Synchronized Mode", group = "Rolling Trend Pointer")
showBreakoutBackground = input.bool(true, "Show Breakout Background", group = "Rolling Trend Pointer")



//────────────────────────────────────────────────────────────────────
// Weighted statistics functions
//────────────────────────────────────────────────────────────────────

f_weightedMean(array<float> values, array<float> weights) =>
    float totalWeight = 0.0
    float weightedSum = 0.0
    int sampleCount = array.size(values)
    if sampleCount > 0
        for i = 0 to sampleCount - 1
            float sampleValue = array.get(values, i)
            float sampleWeight = array.get(weights, i)
            totalWeight += sampleWeight
            weightedSum += sampleValue * sampleWeight
    totalWeight > 0.0 ? weightedSum / totalWeight : na

f_currentWeightedVariance(array<float> values, array<float> weights) =>
    float totalWeight = 0.0
    float weightedSum = 0.0
    float weightedSquareSum = 0.0
    int sampleCount = array.size(values)
    if sampleCount > 0
        for i = 0 to sampleCount - 1
            float sampleValue = array.get(values, i)
            float sampleWeight = array.get(weights, i)
            totalWeight += sampleWeight
            weightedSum += sampleValue * sampleWeight
            weightedSquareSum += sampleValue * sampleValue * sampleWeight
    float sampleMean = totalWeight > 0.0 ? weightedSum / totalWeight : na
    totalWeight > 0.0 ? math.max(weightedSquareSum / totalWeight - sampleMean * sampleMean, 0.0) : na

f_historicalWeightedVariance(array<float> residualSquares, array<float> weights) =>
    float totalWeight = 0.0
    float weightedResidualSum = 0.0
    int sampleCount = array.size(residualSquares)
    if sampleCount > 0
        for i = 0 to sampleCount - 1
            float residualSquare = array.get(residualSquares, i)
            float sampleWeight = array.get(weights, i)
            totalWeight += sampleWeight
            weightedResidualSum += residualSquare * sampleWeight
    totalWeight > 0.0 ? weightedResidualSum / totalWeight : na

//────────────────────────────────────────────────────────────────────
// Rolling VWAP
//────────────────────────────────────────────────────────────────────

src = open
sumV = math.sum(volume, length)
sumPV = math.sum(src * volume, length)
vwap = sumV > 0.0 ? sumPV / sumV : na

//────────────────────────────────────────────────────────────────────
// Raw histogram
//────────────────────────────────────────────────────────────────────

rawPriceDistance = close >= vwap ? high - vwap : low - vwap
sampleWeight = not na(volume) and volume > 0.0 ? volume : 1.0

//────────────────────────────────────────────────────────────────────
// Independent positive and negative samples
//────────────────────────────────────────────────────────────────────

var positiveValues = array.new_float()
var positiveWeights = array.new_float()
var positiveResidualSquares = array.new_float()

var negativeValues = array.new_float()
var negativeWeights = array.new_float()
var negativeResidualSquares = array.new_float()

// Only confirmed values are added to prevent repeated samples on a live bar.

if barstate.isconfirmed and not na(rawPriceDistance)
    if rawPriceDistance > 0.0
        array.push(positiveValues, rawPriceDistance)
        array.push(positiveWeights, sampleWeight)

        if array.size(positiveValues) > length
            array.shift(positiveValues)
            array.shift(positiveWeights)

        float currentPositiveMean = f_weightedMean(positiveValues, positiveWeights)
        float positiveResidual = rawPriceDistance - currentPositiveMean

        array.push(positiveResidualSquares, positiveResidual * positiveResidual)

        if array.size(positiveResidualSquares) > length
            array.shift(positiveResidualSquares)

    else if rawPriceDistance < 0.0
        float negativeMagnitude = math.abs(rawPriceDistance)

        array.push(negativeValues, negativeMagnitude)
        array.push(negativeWeights, sampleWeight)

        if array.size(negativeValues) > length
            array.shift(negativeValues)
            array.shift(negativeWeights)

        float currentNegativeMean = f_weightedMean(negativeValues, negativeWeights)
        float negativeResidual = negativeMagnitude - currentNegativeMean

        array.push(negativeResidualSquares, negativeResidual * negativeResidual)

        if array.size(negativeResidualSquares) > length
            array.shift(negativeResidualSquares)

//────────────────────────────────────────────────────────────────────
// Independent channel variances
//────────────────────────────────────────────────────────────────────

positiveCurrentVariance = f_currentWeightedVariance(positiveValues, positiveWeights)
negativeCurrentVariance = f_currentWeightedVariance(negativeValues, negativeWeights)

positiveHistoricalVariance = f_historicalWeightedVariance(positiveResidualSquares, positiveWeights)
negativeHistoricalVariance = f_historicalWeightedVariance(negativeResidualSquares, negativeWeights)

isCurrentVarianceMode = channelMode == "Current VWAP Variance"

selectedPositiveVariance = isCurrentVarianceMode ? positiveCurrentVariance : positiveHistoricalVariance
selectedNegativeVariance = isCurrentVarianceMode ? negativeCurrentVariance : negativeHistoricalVariance

positiveChannelReady = array.size(positiveValues) >= length
negativeChannelReady = array.size(negativeValues) >= length

upperChannelBoundary = positiveChannelReady ? math.sqrt(selectedPositiveVariance) * mult * 2.0 : na
lowerChannelBoundary = negativeChannelReady ? -math.sqrt(selectedNegativeVariance) * mult * 2.0 : na

//────────────────────────────────────────────────────────────────────
// Displayed histogram smoothing
//────────────────────────────────────────────────────────────────────

smoothedHistogram = histogramSmoothing == "SMA" ? ta.sma(rawPriceDistance, histogramSmoothingLength) : histogramSmoothing == "EMA" ? ta.ema(rawPriceDistance, histogramSmoothingLength) : histogramSmoothing == "WMA" ? ta.wma(rawPriceDistance, histogramSmoothingLength) : histogramSmoothing == "RMA" ? ta.rma(rawPriceDistance, histogramSmoothingLength) : rawPriceDistance

histogramColor = smoothedHistogram >= 0.0 ? color.green : color.red

//────────────────────────────────────────────────────────────────────
// Breakout background
//────────────────────────────────────────────────────────────────────

bullishBreakout = not na(upperChannelBoundary) and smoothedHistogram > upperChannelBoundary
bearishBreakout = not na(lowerChannelBoundary) and smoothedHistogram < lowerChannelBoundary

backgroundColor = bullishBreakout ? color.new(color.green, 80) : bearishBreakout ? color.new(color.red, 80) : na

bgcolor(showBreakoutBackground ? backgroundColor : na, title = "Breakout Background")

//────────────────────────────────────────────────────────────────────
// Smoothed histogram
//────────────────────────────────────────────────────────────────────

plot(smoothedHistogram, "Price Distance from VWAP", color = histogramColor, style = plot.style_area, linewidth = 2, histbase = 0)

//────────────────────────────────────────────────────────────────────
// Independently calculated channel boundaries
//────────────────────────────────────────────────────────────────────

plot(upperChannelBoundary, "Upper Channel Boundary", color = color.blue, linewidth = 2, histbase = 0)
plot(lowerChannelBoundary, "Lower Channel Boundary", color = color.blue, linewidth = 2, histbase = 0)

//────────────────────────────────────────────────────────────────────
// Zero line
//────────────────────────────────────────────────────────────────────

hline(0, "Zero", color = color.new(color.gray, 60), linestyle = hline.style_dotted)
















//"Monthly Anchored VWAP with Multi-Period Confirmation" --------------------------------------

//────────────────────────────────────────────────────────────────────
// Settings
//────────────────────────────────────────────────────────────────────

source = input.source(hlc3, "VWAP Source", group = "Monthly Anchored VWAP with Multi-Period Confirmation")
bandMultiplier = input.float(3.0, "Band Multiplier", minval = 0.0, step = 0.1, group = "Monthly Anchored VWAP with Multi-Period Confirmation")
slopeLength = input.int(2, "VWAP Slope Length", minval = 1, group = "Monthly Anchored VWAP with Multi-Period Confirmation")
lineWidth = input.int(2, "Line Width", minval = 1, maxval = 5, group = "Monthly Anchored VWAP with Multi-Period Confirmation")

showBands = input.bool(true, "Show VWAP Bands", group = "Monthly Anchored VWAP with Multi-Period Confirmation")
useQuarterlyVWAP = input.bool(false, "Use Quarterly VWAP Confirmation", group = "Monthly Anchored VWAP with Multi-Period Confirmation")
useSemiannualVWAP = input.bool(false, "Use Semiannual VWAP Confirmation", group = "Monthly Anchored VWAP with Multi-Period Confirmation")
useAnnualVWAP = input.bool(false, "Use Annual VWAP Confirmation", group = "Monthly Anchored VWAP with Multi-Period Confirmation")


//────────────────────────────────────────────────────────────────────
// Period resets
//────────────────────────────────────────────────────────────────────

newMonth = timeframe.change("1M")
newQuarter = timeframe.change("3M")
newSemiannual = timeframe.change("6M")
newYear = timeframe.change("12M")

//────────────────────────────────────────────────────────────────────
// Monthly anchored VWAP
//────────────────────────────────────────────────────────────────────

var float monthlyVolume = 0.0
var float monthlyPriceVolume = 0.0
var float monthlySquaredPriceVolume = 0.0

if newMonth or barstate.isfirst
    monthlyVolume := volume
    monthlyPriceVolume := source * volume
    monthlySquaredPriceVolume := source * source * volume
else
    monthlyVolume += volume
    monthlyPriceVolume += source * volume
    monthlySquaredPriceVolume += source * source * volume

monthlyVWAP = monthlyVolume > 0.0 ? monthlyPriceVolume / monthlyVolume : na
monthlyVariance = monthlyVolume > 0.0 ? math.max(monthlySquaredPriceVolume / monthlyVolume - monthlyVWAP * monthlyVWAP, 0.0) : na
monthlyDeviation = math.sqrt(monthlyVariance)

upperBand = monthlyVWAP + monthlyDeviation * bandMultiplier
lowerBand = monthlyVWAP - monthlyDeviation * bandMultiplier

//────────────────────────────────────────────────────────────────────
// Quarterly anchored VWAP
//────────────────────────────────────────────────────────────────────

var float quarterlyVolume = 0.0
var float quarterlyPriceVolume = 0.0

if newQuarter or barstate.isfirst
    quarterlyVolume := volume
    quarterlyPriceVolume := source * volume
else
    quarterlyVolume += volume
    quarterlyPriceVolume += source * volume

quarterlyVWAP = quarterlyVolume > 0.0 ? quarterlyPriceVolume / quarterlyVolume : na

//────────────────────────────────────────────────────────────────────
// Semiannual anchored VWAP
//────────────────────────────────────────────────────────────────────

var float semiannualVolume = 0.0
var float semiannualPriceVolume = 0.0

if newSemiannual or barstate.isfirst
    semiannualVolume := volume
    semiannualPriceVolume := source * volume
else
    semiannualVolume += volume
    semiannualPriceVolume += source * volume

semiannualVWAP = semiannualVolume > 0.0 ? semiannualPriceVolume / semiannualVolume : na

//────────────────────────────────────────────────────────────────────
// Annual anchored VWAP
//────────────────────────────────────────────────────────────────────

var float annualVolume = 0.0
var float annualPriceVolume = 0.0

if newYear or barstate.isfirst
    annualVolume := volume
    annualPriceVolume := source * volume
else
    annualVolume += volume
    annualPriceVolume += source * volume

annualVWAP = annualVolume > 0.0 ? annualPriceVolume / annualVolume : na

//────────────────────────────────────────────────────────────────────
// VWAP slopes
//────────────────────────────────────────────────────────────────────

monthlySlope = monthlyVWAP - monthlyVWAP[slopeLength]
quarterlySlope = quarterlyVWAP - quarterlyVWAP[slopeLength]
semiannualSlope = semiannualVWAP - semiannualVWAP[slopeLength]
annualSlope = annualVWAP - annualVWAP[slopeLength]

monthlyBullish = monthlySlope >= 0.0
monthlyBearish = monthlySlope < 0.0

quarterlyBullish = quarterlySlope >= 0.0
quarterlyBearish = quarterlySlope < 0.0

semiannualBullish = semiannualSlope >= 0.0
semiannualBearish = semiannualSlope < 0.0

annualBullish = annualSlope >= 0.0
annualBearish = annualSlope < 0.0

//────────────────────────────────────────────────────────────────────
// AND confirmation logic
//────────────────────────────────────────────────────────────────────

bullishConfirmation = monthlyBullish and (not useQuarterlyVWAP or quarterlyBullish) and (not useSemiannualVWAP or semiannualBullish) and (not useAnnualVWAP or annualBullish)
bearishConfirmation = monthlyBearish and (not useQuarterlyVWAP or quarterlyBearish) and (not useSemiannualVWAP or semiannualBearish) and (not useAnnualVWAP or annualBearish)

//────────────────────────────────────────────────────────────────────
// Monthly VWAP line color
//────────────────────────────────────────────────────────────────────

monthlyLineColor = monthlyBullish ? color.green : color.red

//────────────────────────────────────────────────────────────────────
// Consensus fill color
//────────────────────────────────────────────────────────────────────

consensusFillColor = bullishConfirmation ? color.new(color.green, 85) : bearishConfirmation ? color.new(color.red, 85) : na

//────────────────────────────────────────────────────────────────────
// Synchronized fill mode
//────────────────────────────────────────────────────────────────────

histogramBullish = smoothedHistogram >= 0.0
histogramBearish = smoothedHistogram < 0.0

synchronizedBullish = bullishConfirmation and histogramBullish
synchronizedBearish = bearishConfirmation and histogramBearish

synchronizedFillColor = synchronizedBullish ? bullishBreakout ? color.new(color.green, 65) : color.new(color.green, 85) : synchronizedBearish ? bearishBreakout ? color.new(color.red, 65) : color.new(color.red, 85) : na

monthlyBandFillColor = synchronizedMode ? synchronizedFillColor : consensusFillColor

//────────────────────────────────────────────────────────────────────
// Monthly VWAP plots
//────────────────────────────────────────────────────────────────────

plot(monthlyVWAP, "Monthly Anchored VWAP", color = monthlyLineColor, linewidth = lineWidth, force_overlay = true)
upperPlot = plot(showBands ? upperBand : na, "Upper Monthly VWAP Band", color = monthlyLineColor, linewidth = lineWidth, force_overlay = true)
lowerPlot = plot(showBands ? lowerBand : na, "Lower Monthly VWAP Band", color = monthlyLineColor, linewidth = lineWidth, force_overlay = true)
fill(upperPlot, lowerPlot, color = showBands ? monthlyBandFillColor : na, title = "Monthly VWAP Band Fill")

//────────────────────────────────────────────────────────────────────
// Output to use in Strategies
//────────────────────────────────────────────────────────────────────

trend_dir = monthlyBandFillColor == color.new(color.green, 65) ? 2 : monthlyBandFillColor == color.new(color.green, 85) ? 1 : monthlyBandFillColor == color.new(color.red, 65) ? -2 : monthlyBandFillColor == color.new(color.red, 85) ? -1 : 0
plot(trend_dir, "trend_dir", color.black, display = display.status_line)
````
