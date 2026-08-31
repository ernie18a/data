<!-- tradingview-pine-id: PUB;67931be38aab47098fb6411be39e10ea -->
<!-- tradingviewscripts-format: 1 -->
# Equalhigh - Lepage Dual-Regime Detector

Source: https://www.tradingview.com/script/3VOr4jG5-Equalhigh-Lepage-Dual-Regime-Detector/

## Description

Equalhigh — Lepage Dual-Regime Detector

User Manual

Overview

The Equalhigh Lepage Dual-Regime Detector is a non-parametric change-point indicator for TradingView. It is designed to identify recent changes in either:

Location: the central level of the return distribution.

Scale: the dispersion of the return distribution.

Both simultaneously: a mixed structural break.

Unlike a conventional momentum oscillator, the indicator does not ask whether price is overbought or oversold. It asks whether recent return behavior is statistically different from earlier return behavior inside the active window.

This is a diagnostic regime detector, not an automatic buy-and-sell system.

Why use a location-scale test?

A market transition does not always begin with an obvious directional move. Sometimes the median return changes while volatility remains stable. In other cases, volatility expands or contracts before a clear directional shift becomes visible.

The Lepage framework combines two rank-based components:

The Wilcoxon rank-sum component measures a change in location.

The Ansari–Bradley component measures a change in scale.

The combined statistic can therefore detect more types of structural change than a location-only test.

Observation series

The test is applied to multi-bar logarithmic returns:

Observation = 100 × ln(Source / Source[Return Horizon])

Using returns instead of raw prices reduces the tendency to classify the normal upward drift of an asset as a permanent structural break.

Logarithmic returns require positive source values. The indicator remains unavailable when the active window contains invalid or non-positive source observations.

Core calculation

For every active window, the script:

Stores the return observations chronologically.

Assigns average Wilcoxon ranks to equal observations.

Assigns average Ansari–Bradley center-weighted scores to equal observations.

Tests every split that leaves at least the selected Minimum segment size on both sides.

Standardizes the location and scale score sums at each split.

Calculates the Lepage statistic:

L = Z_location² + Z_scale²

Selects the split with the highest Lepage statistic.

Calculates the fixed-split asymptotic p-value:

p_fixed ≈ exp(−L / 2)

Applies a conservative Bonferroni correction for all admissible splits:

p_scan = min(1, Number of tested splits × p_fixed)

Uses medians and median absolute deviations to classify the type and practical size of the detected change.

The scan correction is important because selecting the strongest result from many candidate splits would otherwise make the displayed p-value too optimistic.

Understanding the components

Location Z

The location component is displayed with an intuitive directional sign:

Location Z > 0: the later segment shifted upward.

Location Z < 0: the later segment shifted downward.

A larger absolute value represents stronger rank-based location evidence.

Scale Z

The scale component describes the change in return dispersion:

Scale Z > 0: the later segment became more dispersed.

Scale Z < 0: the later segment became less dispersed.

A larger absolute value represents stronger rank-based scale evidence.

The combined statistic squares both components, so the p-value measures the strength of the overall break. The signs are used to interpret its direction.

Color system

Color or marker

Interpretation

Green — LEVEL +

Confirmed positive location shift without a qualifying scale shift

Red — LEVEL −

Confirmed negative location shift without a qualifying scale shift

Purple — VOL +

Confirmed scale expansion without a qualifying location shift

Blue — VOL −

Confirmed scale compression without a qualifying location shift

Orange — MIXED

Confirmed location and scale shift occurring together

Yellow — ?

Possible break with incomplete statistical confirmation

Gray

No currently actionable break

A volatility expansion is not automatically bearish, and a volatility compression is not automatically bullish. These states describe dispersion, not market direction.

The orange mixed state does not encode direction by itself. Use Median Shift and MAD Scale Shift in the dashboard to determine whether the mixed change combines an upward or downward level shift with expansion or compression.

Confidence line

The main line is calculated as:

Scan-adjusted confidence = 100 × (1 − p_scan)

The default boundaries are:

95: confirmed statistical zone when the confirmed p-value is 0.05.

85: possible statistical zone when the possible-break p-value is 0.15.

The line color reflects the currently classified regime.

Important: this confidence value is not the probability that price will rise, the probability that a trade will be profitable, a win rate, or a forecast-accuracy score.

Confirmation logic

A confirmed regime requires all of the following:

The scan-adjusted p-value is less than or equal to Confirmed scan p-value.

The estimated break is no older than Maximum actionable break age.

At least one component passes its practical-effect threshold.

The contributing component also passes Minimum component Z.

Positive or negative location shift

The robust location effect reaches Minimum location shift.

The absolute Location Z reaches Minimum component Z.

The scale component does not independently pass all its confirmation filters.

The sign of the median shift determines positive or negative classification.

Scale expansion or compression

The symmetric MAD scale-ratio change reaches Minimum scale-ratio change.

The absolute Scale Z reaches Minimum component Z.

The location component does not independently pass all its confirmation filters.

The MAD ratio determines expansion or compression.

Mixed break

Both the location and scale components pass their effect-size and component-Z filters.

Possible break

The scan-adjusted p-value is above the confirmed threshold but no higher than the possible-break threshold. At least one component must also reach half of its normal effect-size and component-Z requirements.

Dashboard

Dashboard field

Meaning

Lepage State

Current regime classification

Scan-Adj P

Bonferroni-adjusted approximate p-value for the split scan

Break Age

Estimated number of bars since the selected split

Location Z

Directional standardized Wilcoxon component

Scale Z

Directional standardized Ansari–Bradley component

Median Shift

Post-break median return minus pre-break median return, in percentage points

Location Effect

Median shift divided by a robust sigma estimate

MAD Scale Shift

Conventional percentage change from pre-break MAD to post-break MAD

Additional dashboard states include:

FILTERED BREAK: the combined statistic is significant and recent, but neither component passes all practical-effect and Z filters.

OLD BREAK: the combined statistic remains significant inside the window, but the estimated split is older than Maximum actionable break age.

STABLE REGIME: no currently actionable or possible break.

Input guide

1. Observations

Price sourceSeries used to calculate logarithmic returns. Close is the standard setting.

Log-return horizonNumber of bars covered by each return observation. Lower values react to short moves. Higher values emphasize slower market behavior but create more overlap between consecutive observations.

Lepage windowNumber of return observations in each rolling test. Short windows react faster but are noisier. Long windows are more stable but respond later.

Minimum segment sizeMinimum number of observations required before and after every candidate split. Increasing it reduces unstable edge detections but prevents the test from selecting extremely recent breaks.

2. Validation

Confirmed scan p-valueMaximum adjusted p-value for confirmation. The default is 0.05. Lower values produce fewer and more selective events.

Possible-break scan p-valueMaximum adjusted p-value for the yellow early-warning state. The default is 0.15.

Maximum actionable break ageMaximum number of bars allowed between the estimated split and the current bar.

Minimum location shiftMinimum median shift measured in robust sigma units. The robust sigma is 1.4826 × window MAD, with standard deviation used as a fallback when necessary.

Minimum scale-ratio change (%)Minimum symmetric difference between pre-break and post-break MAD. Symmetric measurement treats a doubling and a halving of scale as equally large changes for filtering purposes.

Minimum component ZPrevents a regime label from being attributed to a component that contributed too little to the combined Lepage statistic. The default is 1.00.

Confirm signals at bar closeWhen enabled, new markers and alert events are confirmed only when the current bar closes. This is the recommended setting.

3. Display

These settings independently control regime backgrounds, confirmed labels, possible-break markers, and the dashboard.

Suggested starting profiles

Use case

Return horizon

Window

Minimum segment

Maximum age

Location effect

Scale change

Component Z

General swing trading

5

60

10

10

0.25

25%

1.00

Faster monitoring

3

50

8

7

0.30

30%

1.25

Slower regime analysis

10

90

15

15

0.35

30%

1.00

These profiles are starting points, not optimized trading parameters. Test settings across different assets and unseen market periods.

Interpretation examples

Green location event

Suppose the dashboard shows:

Scan-adjusted p-value: 0.03

Break age: 6

Median shift: +0.80 pp

Location effect: +0.55 sigma

MAD scale shift: +10%

The evidence supports a recent upward change in the central return level, while the scale change remains below its filter.

Purple volatility-expansion event

Suppose the location effect is small, but post-break MAD is 60% higher, Scale Z is strongly positive, and the adjusted p-value is below 0.05. The indicator classifies a volatility expansion. Market direction must be determined separately.

Orange mixed event

If both median returns and dispersion change materially, the indicator displays MIXED. A positive Median Shift with a positive MAD Scale Shift represents improving returns accompanied by expanding volatility. A negative Median Shift with expanding volatility can represent a more hostile risk regime.

Practical workflow

Use ordinary candlesticks on a liquid instrument.

Keep Confirm signals at bar close enabled.

Treat yellow as an observation state rather than an entry instruction.

When a confirmed event appears, inspect Location Z, Scale Z, Median Shift, and MAD Scale Shift.

Confirm the interpretation with price structure, volume, liquidity, and higher-timeframe context.

Define entry, invalidation, position sizing, and exit rules independently.

The indicator is particularly useful as a regime filter. For example, a trend strategy may be treated differently during purple volatility expansion than during blue volatility compression.

Alerts

Six alert conditions are available:

Lepage — Possible break

Lepage — Positive level shift

Lepage — Negative level shift

Lepage — Volatility expansion

Lepage — Volatility compression

Lepage — Mixed regime break

A confirmed alert fires when a qualifying state first appears, when the confirmed regime type changes, or when the estimated split resets to a more recent point. A possible alert follows equivalent first-appearance and break-reset logic.

When bar-close confirmation is enabled, configure TradingView alerts as Once Per Bar Close.

Repainting and event timing

The script does not use future data, lookahead, or a negative plot offset. It places a marker on the bar where the break is detected and never moves that marker backward to the estimated historical split.

However, the estimator is rolling. As a new bar enters the window and an old bar leaves it, the selected split, component scores, p-value, break age, and current state can change. Values can also fluctuate on an open real-time bar. Bar-close confirmation prevents provisional intrabar markers from being treated as confirmed events.

Historical events are calculated only from information available on their respective bars.

Statistical limitations

The fixed-split chi-square p-value is asymptotic rather than exact.

Bonferroni correction is conservative because the candidate splits are dependent.

The correction covers the splits inside one window, not repeated testing across every bar in the chart.

Consecutive multi-bar returns overlap and are not independent. The adjusted p-value should therefore be interpreted as comparative evidence rather than a perfectly calibrated probability.

The classical Lepage components are most naturally interpreted as location and scale tests under regular distributional conditions. Strong skew changes or complex distribution changes can affect both components.

The detector selects one dominant split per rolling window. Multiple rapid changes can interfere with one another.

A statistically significant regime change does not guarantee persistence, directional continuation, or trading profitability.

Median absolute deviation can be close to zero on discrete or insufficiently variable data. The script uses a small numerical floor, but scale percentages can still become unusually large.

Results on Heikin Ashi, Renko, Range, Kagi, Point & Figure, or other synthetic charts describe transformed data rather than ordinary traded prices.

Always evaluate the indicator on unseen data and combine it with independent risk controls.

Data Window outputs

The script exposes:

State code.

Scan-adjusted p-value.

Estimated break age.

Location Z component.

Scale Z component.

Median shift in percentage points.

Robust location effect.

MAD scale change percentage.

Lepage statistic.

State codes are:

Code

State

4

Mixed location-scale break

3

Scale expansion

2

Positive location shift

1

Possible break

0

Stable, filtered, or old break

−2

Negative location shift

−3

Scale compression

TradingView publication metadata

Primary category: Oscillators

Secondary category: Trend Analysis

Suggested tags: Lepage Test, Change Point, Regime Detection, Statistics, Non-Parametric, Volatility, Structural Break

References

Y. Lepage, “A Combination of Wilcoxon's and Ansari-Bradley's Statistics,” Biometrika, 1971.

F. Rublík, “The Multisample Version of the Lepage Test,” Kybernetika, Vol. 41, No. 6, 2005, pp. 713–733: paper.

G. J. Ross, D. K. Tasoulis and N. M. Adams, “Nonparametric Monitoring of Data Streams for Changes in Location and Scale,” Technometrics, Vol. 53, No. 4, 2011, pp. 379–389: DOI.

H. Murakami, “A Nonparametric Location–Scale Statistic for Detecting a Change Point,” The International Journal of Advanced Manufacturing Technology, Vol. 61, 2012, pp. 449–455: DOI.

Disclaimer

This indicator is provided for research and educational purposes. It does not constitute investment advice, a recommendation, or a guarantee of future performance. Trading involves risk, including the possible loss of capital.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stevesyl

//@version=6
indicator(
     "Equalhigh - Lepage Dual-Regime Detector",
     shorttitle = "Lepage Regime",
     overlay = false,
     precision = 1,
     max_bars_back = 500
)

// Rolling non-parametric location-scale change-point detector.
// The Lepage statistic combines standardized Wilcoxon rank-sum and
// Ansari-Bradley scale components. The scan p-value uses a conservative
// Bonferroni adjustment across all admissible split points.
//
// Signals are displayed on the current detection bar. The script never
// back-places a signal on the estimated historical change point.

// =============================================================================
// 1. INPUTS
// =============================================================================

groupData = "1. Observations"
source = input.source(close, "Price source", group = groupData)
returnHorizon = input.int(5, "Log-return horizon", minval = 1, maxval = 20, group = groupData)
windowLength = input.int(60, "Lepage window", minval = 40, maxval = 120, group = groupData)
minimumSegment = input.int(10, "Minimum segment size", minval = 5, maxval = 20, group = groupData)

groupValidation = "2. Validation"
alpha = input.float(0.05, "Confirmed scan p-value", minval = 0.01, maxval = 0.10, step = 0.01, group = groupValidation)
warningAlpha = input.float(0.15, "Possible-break scan p-value", minval = 0.05, maxval = 0.30, step = 0.01, group = groupValidation)
maximumBreakAge = input.int(10, "Maximum actionable break age", minval = 1, maxval = 30, group = groupValidation)
minimumLocationEffect = input.float(0.25, "Minimum location shift", minval = 0.05, maxval = 2.00, step = 0.05, group = groupValidation, tooltip = "Minimum median shift measured in robust sigma units.")
minimumScaleChange = input.float(25.0, "Minimum scale-ratio change (%)", minval = 5.0, maxval = 200.0, step = 5.0, group = groupValidation, tooltip = "Minimum symmetric change between the pre-break and post-break median absolute deviations.")
minimumComponentZ = input.float(1.00, "Minimum component Z", minval = 0.50, maxval = 3.00, step = 0.25, group = groupValidation, tooltip = "Prevents the regime label from being assigned to a component that contributed too little to the combined Lepage statistic.")
confirmAtClose = input.bool(true, "Confirm signals at bar close", group = groupValidation)

groupDisplay = "3. Display"
showBackground = input.bool(true, "Color the detected regime", group = groupDisplay)
showSignals = input.bool(true, "Show confirmed-break labels", group = groupDisplay)
showPossibleBreaks = input.bool(true, "Show possible-break markers", group = groupDisplay)
showDashboard = input.bool(true, "Show statistical dashboard", group = groupDisplay)

// =============================================================================
// 2. ARRAY HELPERS
// =============================================================================

f_median(array<float> data) =>
    array<float> sortedData = array.copy(data)
    array.sort(sortedData, order.ascending)

    int dataSize = array.size(sortedData)
    int middle = int(math.floor(dataSize / 2.0))
    float result = na

    if dataSize > 0
        result := dataSize % 2 == 1 ? array.get(sortedData, middle) : (array.get(sortedData, middle - 1) + array.get(sortedData, middle)) / 2.0

    result

f_mad(array<float> data, float center) =>
    int dataSize = array.size(data)
    array<float> deviations = array.new<float>(dataSize, na)

    if dataSize > 0
        for i = 0 to dataSize - 1
            array.set(deviations, i, math.abs(array.get(data, i) - center))

    f_median(deviations)

// Returns:
// [maximum Lepage statistic, chronological split index, scan-adjusted p-value,
//  location Z, scale Z, median before, median after, MAD before, MAD after,
//  MAD across the complete window]
f_lepage(float src, int length, int minSegment) =>
    float maximumStatistic = na
    int bestSplit = na
    float adjustedPValue = na
    float bestLocationZ = na
    float bestScaleZ = na
    float medianBefore = na
    float medianAfter = na
    float madBefore = na
    float madAfter = na
    float overallMad = na

    if not na(src[length - 1])
        array<float> values = array.new<float>(length, na)
        array<float> ranks = array.new<float>(length, na)
        array<float> scaleScores = array.new<float>(length, na)
        bool allValuesAvailable = true

        // Store observations chronologically, from oldest to newest.
        for i = 0 to length - 1
            float historicalValue = src[length - 1 - i]
            array.set(values, i, historicalValue)
            allValuesAvailable := allValuesAvailable and not na(historicalValue)

        if allValuesAvailable
            array<int> sortedIndices = array.sort_indices(values, order.ascending)
            int sortedPosition = 0

            // Assign average Wilcoxon ranks and average Ansari-Bradley scores
            // to tied values. The AB score at pooled position p is
            // min(p, N - p + 1), producing symmetric center-weighted scores.
            while sortedPosition < length
                int tieEnd = sortedPosition
                int firstOriginalIndex = array.get(sortedIndices, sortedPosition)
                float tiedValue = array.get(values, firstOriginalIndex)

                while tieEnd + 1 < length and array.get(values, array.get(sortedIndices, tieEnd + 1)) == tiedValue
                    tieEnd += 1

                float averageRank = (float(sortedPosition + 1) + float(tieEnd + 1)) / 2.0
                float scaleScoreSum = 0.0

                for scorePosition = sortedPosition to tieEnd
                    int oneBasedPosition = scorePosition + 1
                    scaleScoreSum += math.min(float(oneBasedPosition), float(length - oneBasedPosition + 1))

                float averageScaleScore = scaleScoreSum / float(tieEnd - sortedPosition + 1)

                for scorePosition = sortedPosition to tieEnd
                    int originalIndex = array.get(sortedIndices, scorePosition)
                    array.set(ranks, originalIndex, averageRank)
                    array.set(scaleScores, originalIndex, averageScaleScore)

                sortedPosition := tieEnd + 1

            float rankMean = array.avg(ranks)
            float scaleScoreMean = array.avg(scaleScores)
            float rankSquaredDeviationSum = 0.0
            float scaleSquaredDeviationSum = 0.0

            // Empirical score variances preserve the usual no-tie formulas
            // while remaining usable when equal observations occur.
            for i = 0 to length - 1
                float rankDeviation = array.get(ranks, i) - rankMean
                float scaleDeviation = array.get(scaleScores, i) - scaleScoreMean
                rankSquaredDeviationSum += math.pow(rankDeviation, 2.0)
                scaleSquaredDeviationSum += math.pow(scaleDeviation, 2.0)

            float cumulativeRank = 0.0
            float cumulativeScaleScore = 0.0
            float bestStatistic = -1.0
            float sampleSize = float(length)
            int admissibleSplitCount = length - 2 * minSegment + 1

            for i = 0 to length - 1
                cumulativeRank += array.get(ranks, i)
                cumulativeScaleScore += array.get(scaleScores, i)
                int splitCandidate = i + 1

                if splitCandidate >= minSegment and splitCandidate <= length - minSegment
                    float firstSize = float(splitCandidate)
                    float secondSize = sampleSize - firstSize
                    float finitePopulationFactor = firstSize * secondSize / (sampleSize * (sampleSize - 1.0))
                    float rankVariance = finitePopulationFactor * rankSquaredDeviationSum
                    float scaleVariance = finitePopulationFactor * scaleSquaredDeviationSum

                    if rankVariance > 0.0 and scaleVariance > 0.0
                        float rawLocationZ = (cumulativeRank - firstSize * rankMean) / math.sqrt(rankVariance)
                        // Invert the first-segment rank-sum sign so that a
                        // positive displayed Z means the later segment shifted up.
                        float directionalLocationZ = -rawLocationZ
                        float scaleZ = (cumulativeScaleScore - firstSize * scaleScoreMean) / math.sqrt(scaleVariance)
                        float candidateStatistic = math.pow(rawLocationZ, 2.0) + math.pow(scaleZ, 2.0)

                        if candidateStatistic > bestStatistic
                            bestStatistic := candidateStatistic
                            bestSplit := splitCandidate
                            bestLocationZ := directionalLocationZ
                            bestScaleZ := scaleZ

            if not na(bestSplit)
                maximumStatistic := bestStatistic

                // A fixed-split Lepage statistic is asymptotically chi-square
                // with two degrees of freedom, whose survival function is
                // exp(-L/2). Bonferroni adjusts for scanning many split points.
                float fixedSplitPValue = math.exp(-maximumStatistic / 2.0)
                adjustedPValue := math.min(1.0, float(admissibleSplitCount) * fixedSplitPValue)

                array<float> beforeValues = array.new<float>(bestSplit, na)
                array<float> afterValues = array.new<float>(length - bestSplit, na)

                for i = 0 to bestSplit - 1
                    array.set(beforeValues, i, array.get(values, i))

                for i = bestSplit to length - 1
                    array.set(afterValues, i - bestSplit, array.get(values, i))

                medianBefore := f_median(beforeValues)
                medianAfter := f_median(afterValues)
                madBefore := f_mad(beforeValues, medianBefore)
                madAfter := f_mad(afterValues, medianAfter)

                float overallMedian = f_median(values)
                overallMad := f_mad(values, overallMedian)

    [maximumStatistic, bestSplit, adjustedPValue, bestLocationZ, bestScaleZ, medianBefore, medianAfter, madBefore, madAfter, overallMad]

// =============================================================================
// 3. ROLLING LEPAGE TEST
// =============================================================================

observation = source > 0.0 and source[returnHorizon] > 0.0 ? 100.0 * math.log(source / source[returnHorizon]) : na

[lepageStatistic, splitIndex, pValue, locationZ, scaleZ, preBreakMedian, postBreakMedian, preBreakMad, postBreakMad, windowMad] = f_lepage(observation, windowLength, minimumSegment)

medianShift = postBreakMedian - preBreakMedian
standardDeviation = ta.stdev(observation, windowLength)
robustSigma = 1.4826 * windowMad
locationDenominator = robustSigma > 0.0 ? robustSigma : standardDeviation
locationEffect = locationDenominator > 0.0 ? medianShift / locationDenominator : 0.0

scaleFloor = math.max(nz(windowMad) * 0.001, 0.0000000001)
scaleRatio = (postBreakMad + scaleFloor) / (preBreakMad + scaleFloor)
scaleChangePercent = 100.0 * (scaleRatio - 1.0)
scaleMagnitudePercent = 100.0 * (math.max(scaleRatio, 1.0 / scaleRatio) - 1.0)
breakAge = not na(splitIndex) ? windowLength - splitIndex : na

barConfirmed = not confirmAtClose or barstate.isconfirmed
effectiveWarningAlpha = math.max(alpha, warningAlpha)

validTest = not na(pValue) and not na(breakAge) and not na(locationZ) and not na(scaleZ)
recentBreak = validTest and breakAge <= maximumBreakAge
confirmedStatistic = recentBreak and pValue <= alpha
possibleStatistic = recentBreak and pValue > alpha and pValue <= effectiveWarningAlpha

locationEffectIsMeaningful = math.abs(locationEffect) >= minimumLocationEffect and math.abs(locationZ) >= minimumComponentZ
scaleEffectIsMeaningful = scaleMagnitudePercent >= minimumScaleChange and math.abs(scaleZ) >= minimumComponentZ
possibleLocationEffect = math.abs(locationEffect) >= minimumLocationEffect * 0.5 and math.abs(locationZ) >= minimumComponentZ * 0.5
possibleScaleEffect = scaleMagnitudePercent >= minimumScaleChange * 0.5 and math.abs(scaleZ) >= minimumComponentZ * 0.5

mixedBreakCondition = confirmedStatistic and locationEffectIsMeaningful and scaleEffectIsMeaningful
bullishLocationCondition = confirmedStatistic and locationEffectIsMeaningful and not scaleEffectIsMeaningful and medianShift > 0.0
bearishLocationCondition = confirmedStatistic and locationEffectIsMeaningful and not scaleEffectIsMeaningful and medianShift < 0.0
scaleExpansionCondition = confirmedStatistic and scaleEffectIsMeaningful and not locationEffectIsMeaningful and scaleRatio > 1.0
scaleCompressionCondition = confirmedStatistic and scaleEffectIsMeaningful and not locationEffectIsMeaningful and scaleRatio < 1.0
possibleBreakCondition = possibleStatistic and (possibleLocationEffect or possibleScaleEffect)

confirmedBreak = mixedBreakCondition or bullishLocationCondition or bearishLocationCondition or scaleExpansionCondition or scaleCompressionCondition

stateCode = mixedBreakCondition ? 4 : scaleExpansionCondition ? 3 : bullishLocationCondition ? 2 : possibleBreakCondition ? 1 : bearishLocationCondition ? -2 : scaleCompressionCondition ? -3 : 0

newConfirmedBreak = barConfirmed and confirmedBreak and (not confirmedBreak[1] or stateCode != stateCode[1] or breakAge < breakAge[1])
newPossibleBreak = barConfirmed and possibleBreakCondition and (not possibleBreakCondition[1] or breakAge < breakAge[1])

newMixedBreak = newConfirmedBreak and mixedBreakCondition
newScaleExpansion = newConfirmedBreak and scaleExpansionCondition
newBullishLocation = newConfirmedBreak and bullishLocationCondition
newBearishLocation = newConfirmedBreak and bearishLocationCondition
newScaleCompression = newConfirmedBreak and scaleCompressionCondition

// =============================================================================
// 4. REGIME DISPLAY
// =============================================================================

confidence = validTest ? 100.0 * (1.0 - pValue) : na
confirmedConfidenceLevel = 100.0 * (1.0 - alpha)
possibleConfidenceLevel = 100.0 * (1.0 - effectiveWarningAlpha)

confirmedLine = hline(confirmedConfidenceLevel, "Confirmed boundary", color = color.new(color.green, 20), linestyle = hline.style_dashed)
possibleLine = hline(possibleConfidenceLevel, "Possible boundary", color = color.new(color.orange, 30), linestyle = hline.style_dotted)
zeroLine = hline(0.0, "Minimum confidence", color = color.new(color.gray, 75))
maximumLine = hline(100.0, "Maximum confidence", color = color.new(color.gray, 70))

fill(maximumLine, confirmedLine, color = color.new(color.green, 92), title = "Confirmed statistical zone")
fill(confirmedLine, possibleLine, color = color.new(color.orange, 93), title = "Possible statistical zone")

purple = color.rgb(156, 39, 176)
blue = color.rgb(33, 150, 243)
yellow = color.rgb(255, 193, 7)

color regimeColor = mixedBreakCondition ? color.orange : scaleExpansionCondition ? purple : bullishLocationCondition ? color.lime : bearishLocationCondition ? color.red : scaleCompressionCondition ? blue : possibleBreakCondition ? yellow : color.gray

plot(confidence, "Scan-adjusted confidence", color = regimeColor, linewidth = 3)

plotshape(
     showSignals and newBullishLocation,
     title = "Positive location shift",
     style = shape.labelup,
     location = location.bottom,
     color = color.green,
     textcolor = color.white,
     size = size.tiny,
     text = "LEVEL +"
)

plotshape(
     showSignals and newBearishLocation,
     title = "Negative location shift",
     style = shape.labeldown,
     location = location.top,
     color = color.red,
     textcolor = color.white,
     size = size.tiny,
     text = "LEVEL -"
)

plotshape(
     showSignals and newScaleExpansion,
     title = "Scale expansion",
     style = shape.labeldown,
     location = location.top,
     color = purple,
     textcolor = color.white,
     size = size.tiny,
     text = "VOL +"
)

plotshape(
     showSignals and newScaleCompression,
     title = "Scale compression",
     style = shape.labelup,
     location = location.bottom,
     color = blue,
     textcolor = color.white,
     size = size.tiny,
     text = "VOL -"
)

plotshape(
     showSignals and newMixedBreak,
     title = "Mixed location-scale shift",
     style = shape.labeldown,
     location = location.top,
     color = color.orange,
     textcolor = color.white,
     size = size.tiny,
     text = "MIXED"
)

plotshape(
     showPossibleBreaks and newPossibleBreak,
     title = "Possible location-scale break",
     style = shape.triangleup,
     location = location.bottom,
     color = yellow,
     size = size.tiny,
     text = "?"
)

color regimeBackground = confirmedBreak ? color.new(regimeColor, 91) : possibleBreakCondition ? color.new(yellow, 93) : na
bgcolor(showBackground ? regimeBackground : na, title = "Dual-regime state")

// =============================================================================
// 5. DASHBOARD AND DATA WINDOW
// =============================================================================

filteredBreak = confirmedStatistic and not confirmedBreak
oldBreak = validTest and pValue <= alpha and not recentBreak

string stateText = mixedBreakCondition ? "MIXED BREAK" : scaleExpansionCondition ? "VOLATILITY EXPANSION" : bullishLocationCondition ? "POSITIVE LEVEL SHIFT" : bearishLocationCondition ? "NEGATIVE LEVEL SHIFT" : scaleCompressionCondition ? "VOLATILITY COMPRESSION" : possibleBreakCondition ? "POSSIBLE BREAK" : filteredBreak ? "FILTERED BREAK" : oldBreak ? "OLD BREAK" : "STABLE REGIME"

color stateColor = mixedBreakCondition ? color.orange : scaleExpansionCondition ? purple : bullishLocationCondition ? color.green : bearishLocationCondition ? color.red : scaleCompressionCondition ? blue : possibleBreakCondition ? yellow : color.gray

string pValueText = not validTest ? "N/A" : pValue < 0.001 ? "<0.001" : str.tostring(pValue, "#.###")
string breakAgeText = not validTest ? "N/A" : str.tostring(breakAge)
string locationZText = not validTest ? "N/A" : str.tostring(locationZ, "#.##")
string scaleZText = not validTest ? "N/A" : str.tostring(scaleZ, "#.##")
string medianShiftText = not validTest ? "N/A" : str.tostring(medianShift, "#.###") + " pp"
string locationEffectText = not validTest ? "N/A" : str.tostring(locationEffect, "#.##") + " sigma"
string scaleChangeText = not validTest ? "N/A" : str.tostring(scaleChangePercent, "#.1") + "%"

var table dashboard = table.new(
     position.top_right,
     2,
     8,
     border_width = 1,
     border_color = color.new(color.gray, 50)
)

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "LEPAGE STATE", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 1, 0, stateText, bgcolor = stateColor, text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 0, 1, "SCAN-ADJ P", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 1, 1, pValueText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 0, 2, "BREAK AGE", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 1, 2, breakAgeText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 0, 3, "LOCATION Z", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 1, 3, locationZText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 0, 4, "SCALE Z", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 1, 4, scaleZText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 0, 5, "MEDIAN SHIFT", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 1, 5, medianShiftText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 0, 6, "LOCATION EFFECT", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 1, 6, locationEffectText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 0, 7, "MAD SCALE SHIFT", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.tiny)
    table.cell(dashboard, 1, 7, scaleChangeText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.tiny)

plot(stateCode, "State code", color = color.new(color.white, 100), display = display.data_window)
plot(pValue, "Scan-adjusted p-value", color = color.new(color.white, 100), display = display.data_window)
plot(breakAge, "Estimated break age", color = color.new(color.white, 100), display = display.data_window)
plot(locationZ, "Location Z component", color = color.new(color.white, 100), display = display.data_window)
plot(scaleZ, "Scale Z component", color = color.new(color.white, 100), display = display.data_window)
plot(medianShift, "Median shift in percentage points", color = color.new(color.white, 100), display = display.data_window)
plot(locationEffect, "Robust location effect", color = color.new(color.white, 100), display = display.data_window)
plot(scaleChangePercent, "MAD scale change percent", color = color.new(color.white, 100), display = display.data_window)
plot(lepageStatistic, "Lepage statistic", color = color.new(color.white, 100), display = display.data_window)

// =============================================================================
// 6. ALERTS
// =============================================================================

alertcondition(newPossibleBreak, "Lepage - Possible break", "Possible location-scale regime break detected on {{ticker}} ({{interval}}). Statistical confirmation is incomplete.")
alertcondition(newBullishLocation, "Lepage - Positive level shift", "Confirmed positive return-level shift detected on {{ticker}} ({{interval}}).")
alertcondition(newBearishLocation, "Lepage - Negative level shift", "Confirmed negative return-level shift detected on {{ticker}} ({{interval}}).")
alertcondition(newScaleExpansion, "Lepage - Volatility expansion", "Confirmed return-scale expansion detected on {{ticker}} ({{interval}}).")
alertcondition(newScaleCompression, "Lepage - Volatility compression", "Confirmed return-scale compression detected on {{ticker}} ({{interval}}).")
alertcondition(newMixedBreak, "Lepage - Mixed regime break", "Confirmed combined location-scale regime break detected on {{ticker}} ({{interval}}).")
````
