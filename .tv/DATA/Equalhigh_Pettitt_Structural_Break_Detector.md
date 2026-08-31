<!-- tradingview-pine-id: PUB;816a46ae69f4470d90610b16bfb829fa -->
<!-- tradingviewscripts-format: 1 -->
# Equalhigh - Pettitt Structural Break Detector

Source: https://www.tradingview.com/script/kNwpTPvl-Equalhigh-Pettitt-Structural-Break-Detector/

## Description

Equalhigh — Pettitt Structural Break Detector

User Manual

Overview

The Equalhigh Pettitt Structural Break Detector is a statistical regime-change indicator for TradingView. It is designed to identify a recent change in the distribution of price returns rather than a conventional overbought, oversold, or moving-average condition.

The indicator applies a rolling version of Pettitt's non-parametric change-point test to logarithmic price returns. It estimates the most likely break location inside the active window, evaluates its statistical significance, measures the direction and size of the median shift, and filters out changes that are too old or too small to be considered actionable.

This is a diagnostic indicator, not an automatic trading system. Its purpose is to answer:

Has the recent return regime changed materially, in which direction, and with what level of statistical evidence?

Core calculation

The observation tested on each bar is the multi-bar logarithmic return:

100 × ln(Source / Source[Return Horizon])

Inside the selected Pettitt window, the indicator:

Orders the observations chronologically.

Assigns non-parametric ranks, using average ranks for equal values.

Tests every admissible split while preserving the minimum segment size on both sides.

Selects the split with the largest absolute Pettitt statistic.

Calculates the approximate two-sided p-value:

p ≈ min(1, 2 × exp(-6K² / (n³ + n²)))

Compares the median return before and after the estimated break.

Standardizes the median shift by the rolling standard deviation.

Rejects breaks that are too old or have an insufficient effect size.

The test is non-parametric: it relies on ranks and does not require returns to follow a normal distribution.

Reading the indicator

The main line is a signed statistical-confidence display ranging from approximately -100 to +100.

Display

Meaning

Green

Recent, statistically confirmed upward shift in the return distribution

Red

Recent, statistically confirmed downward shift in the return distribution

Orange

Possible break; evidence is developing but does not yet meet the confirmed threshold

Gray

No currently actionable structural break

BULL label

A new confirmed upward structural-break event

BEAR label

A new confirmed downward structural-break event

Orange ?

A new possible upward or downward break

A positive reading means that the post-break median return is higher than the pre-break median. A negative reading means it is lower.

Important: a bullish break does not necessarily mean that returns are already positive. A change from strongly negative returns to mildly negative returns is an upward structural shift and can therefore be classified as bullish. Price structure should still be checked separately.

The displayed confidence is calculated as 100 × (1 − p-value). It is not the probability that a trade will be profitable, the probability that price will rise, or a forecast accuracy score.

Confirmation rules

A confirmed break requires all of the following:

The approximate p-value is less than or equal to the Confirmed p-value setting.

The estimated break age does not exceed the Maximum actionable break age.

The absolute median-shift effect reaches the Minimum median-shift effect.

The post-break median is different from the pre-break median.

A possible break requires:

A p-value above the confirmed threshold but no higher than the Possible-break p-value.

A recent estimated break.

At least half of the selected minimum effect size.

Dashboard

The statistical dashboard provides five fields:

Field

Interpretation

Pettitt State

Current classification: stable, possible break, confirmed break, or old break

P Value Approx

Approximate probability of observing a Pettitt statistic at least this extreme under the no-change hypothesis

Break Age

Estimated number of bars since the detected split

Median Shift

Post-break median return minus pre-break median return, in percentage points

Effect Size

Median shift divided by the rolling standard deviation of the tested returns

An OLD BREAK state means that statistically significant evidence remains inside the window, but the estimated change point is older than the selected actionable-age limit.

Inputs

1. Observations

Price sourceSelects the series used in the logarithmic-return calculation. Close is the standard choice.

Log-return horizonDefines the number of bars used for each return observation. A higher value focuses on slower moves but creates more overlap between consecutive observations.

Pettitt windowDefines the number of observations included in each rolling test. Short windows react faster but are noisier. Long windows are more stable but detect changes later.

Minimum segment sizePrevents the estimated split from being placed too close to either edge of the window. Larger values reduce unstable edge detections but also delay recognition of very recent changes.

2. Validation

Confirmed p-valueMaximum approximate p-value for a confirmed break. 0.05 is the default. Lower values are more selective.

Possible-break p-valueMaximum p-value for the orange early-warning state. 0.15 is the default.

Maximum actionable break ageMaximum number of bars allowed between the estimated break and the current bar. This prevents an old statistical event from being treated as a fresh signal.

Minimum median-shift effectMinimum absolute standardized median shift required for confirmation. 0.25 means that the shift must represent at least one quarter of the rolling return standard deviation.

Confirm signals at bar closeWhen enabled, new labels and alert events are confirmed only after the current bar closes. This is the recommended setting.

3. Display

These controls independently enable the regime background, confirmed labels, possible-break markers, and statistical dashboard.

Suggested starting profiles

Use case

Return horizon

Window

Minimum segment

Maximum age

Minimum effect

General swing trading

5

60

10

10

0.25

Faster market monitoring

3

50

8

7

0.30

Slower regime analysis

10

90

15

15

0.35

These are starting points, not optimized trading parameters. Settings should be tested across different symbols and market regimes without selecting them solely from the best historical result.

Practical workflow

Use a liquid instrument and ordinary candlestick data.

Keep bar-close confirmation enabled.

Treat orange as an observation state, not an entry instruction.

When a confirmed label appears, check whether price structure, volume, volatility, and the higher-timeframe context support the same interpretation.

Use the p-value, effect size, and break age together. A small p-value alone does not guarantee a useful trade.

Define entry, invalidation, position size, and exit rules independently.

For example, a green event with p = 0.02, a break age of 6 bars, and an effect size of +0.60 sigma represents a recent and statistically meaningful upward shift. It becomes more useful if price has also reclaimed an important level or broken a declining structure.

Alerts

Four alert conditions are available:

Pettitt — Possible bullish break

Pettitt — Possible bearish break

Pettitt — Bullish structural break

Pettitt — Bearish structural break

Alerts fire when a qualifying state first appears or when the estimated break resets to a more recent point while the same directional condition remains active. With bar-close confirmation enabled, alerts should be configured Once Per Bar Close.

Repainting and timing

The script does not use future data, lookahead, or a negative plot offset. A signal is displayed on the bar where the break is detected; it is not placed retrospectively on the estimated historical change point.

However, this is a rolling estimator. As new bars enter the window, the most likely split, p-value, break age, and state can change. On a live unclosed bar, values can also move with price. Enabling Confirm signals at bar close prevents provisional intrabar labels from being treated as confirmed events.

Limitations

Pettitt's test identifies the dominant single change point inside the active window. Multiple rapid regime changes can interfere with one another.

The p-value is an approximation, not an exact posterior probability.

Consecutive multi-bar returns overlap and are therefore not independent. This makes the p-value best treated as comparative statistical evidence rather than a perfectly calibrated probability.

A statistically significant distribution shift does not guarantee trend continuation or trading profitability.

Outliers are less influential than in many mean-based tests, but they can still affect the detected split and the rolling volatility denominator.

Very short windows are noisy; very long windows can react too slowly.

Logarithmic returns require positive source values. The test remains unavailable when the selected source contains invalid or non-positive observations inside the active window.

Results on Heikin Ashi, Renko, Range, Kagi, or other synthetic chart types describe the transformed data rather than standard traded prices.

Always evaluate the indicator on unseen data and combine it with independent risk controls.

Data Window outputs

The script exposes the following values for inspection and alert integration:

State code: +2 confirmed bullish, +1 possible bullish, 0 stable, −1 possible bearish, −2 confirmed bearish.

Approximate p-value.

Estimated break age.

Median shift in percentage points.

Median-shift effect size.

Pettitt K statistic.

Reference

A. N. Pettitt, “A Non-Parametric Approach to the Change-Point Problem,” Journal of the Royal Statistical Society: Series C (Applied Statistics), Vol. 28, No. 2, 1979, pp. 126–135. DOI: 10.2307/2346729.

Disclaimer

This indicator is provided for research and educational purposes. It does not constitute investment advice, a recommendation, or a guarantee of future performance. Trading involves risk, including the possible loss of capital.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stevesyl

//@version=6
indicator(
     "Equalhigh - Pettitt Structural Break Detector",
     shorttitle = "Pettitt Break",
     overlay = false,
     precision = 1
)

// Non-parametric rolling change-point detector based on Pettitt (1979).
// The script signals on the current detection bar. It never places a signal
// retrospectively on the estimated historical change-point.

// =============================================================================
// 1. INPUTS
// =============================================================================

groupData = "1. Observations"
source = input.source(close, "Price source", group = groupData)
returnHorizon = input.int(5, "Log-return horizon", minval = 1, maxval = 20, group = groupData)
windowLength = input.int(60, "Pettitt window", minval = 40, maxval = 120, group = groupData)
minimumSegment = input.int(10, "Minimum segment size", minval = 5, maxval = 20, group = groupData)

groupValidation = "2. Validation"
alpha = input.float(0.05, "Confirmed p-value", minval = 0.01, maxval = 0.10, step = 0.01, group = groupValidation)
warningAlpha = input.float(0.15, "Possible-break p-value", minval = 0.05, maxval = 0.30, step = 0.01, group = groupValidation)
maximumBreakAge = input.int(10, "Maximum actionable break age", minval = 1, maxval = 30, group = groupValidation)
minimumEffectSize = input.float(0.25, "Minimum median-shift effect", minval = 0.0, maxval = 2.0, step = 0.05, group = groupValidation)
confirmAtClose = input.bool(true, "Confirm signals at bar close", group = groupValidation)

groupDisplay = "3. Display"
showBackground = input.bool(true, "Color the detected regime", group = groupDisplay)
showSignals = input.bool(true, "Show structural-break labels", group = groupDisplay)
showPossibleBreaks = input.bool(true, "Show possible-break markers", group = groupDisplay)
showDashboard = input.bool(true, "Show statistical dashboard", group = groupDisplay)

// =============================================================================
// 2. STATISTICAL HELPERS
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

// Returns:
// [maximum statistic, chronological split index, approximate p-value,
//  median before the split, median after the split]
f_pettitt(float src, int length, int minSegment) =>
    float maximumStatistic = na
    int bestSplit = na
    float approximatePValue = na
    float medianBefore = na
    float medianAfter = na

    if not na(src[length - 1])
        array<float> values = array.new<float>(length, na)
        array<float> ranks = array.new<float>(length, na)
        bool allValuesAvailable = true

        // Store observations from oldest to newest.
        for i = 0 to length - 1
            float historicalValue = src[length - 1 - i]
            array.set(values, i, historicalValue)
            allValuesAvailable := allValuesAvailable and not na(historicalValue)

        if allValuesAvailable
            // Sorting indices reduces rank construction from O(n^2) pairwise
            // comparisons to one sort. Equal values receive their average rank.
            array<int> sortedIndices = array.sort_indices(values, order.ascending)
            int sortedPosition = 0

            while sortedPosition < length
                int tieEnd = sortedPosition
                int firstOriginalIndex = array.get(sortedIndices, sortedPosition)
                float tiedValue = array.get(values, firstOriginalIndex)

                while tieEnd + 1 < length and array.get(values, array.get(sortedIndices, tieEnd + 1)) == tiedValue
                    tieEnd += 1

                float averageRank = (float(sortedPosition + 1) + float(tieEnd + 1)) / 2.0

                for rankPosition = sortedPosition to tieEnd
                    int originalIndex = array.get(sortedIndices, rankPosition)
                    array.set(ranks, originalIndex, averageRank)

                sortedPosition := tieEnd + 1

            float cumulativeRank = 0.0
            float bestAbsoluteU = -1.0
            float sampleSize = float(length)

            // Pettitt's statistic can be calculated from cumulative rank sums:
            // U(t) = 2 * sum(R[1:t]) - t * (n + 1).
            for i = 0 to length - 1
                cumulativeRank += array.get(ranks, i)
                int splitCandidate = i + 1

                if splitCandidate >= minSegment and splitCandidate <= length - minSegment
                    float candidateU = 2.0 * cumulativeRank - float(splitCandidate) * (sampleSize + 1.0)
                    float candidateAbsoluteU = math.abs(candidateU)

                    if candidateAbsoluteU > bestAbsoluteU
                        bestAbsoluteU := candidateAbsoluteU
                        bestSplit := splitCandidate

            if not na(bestSplit)
                maximumStatistic := bestAbsoluteU

                float probabilityDenominator = math.pow(sampleSize, 3.0) + math.pow(sampleSize, 2.0)
                approximatePValue := math.min(1.0, 2.0 * math.exp(-6.0 * math.pow(maximumStatistic, 2.0) / probabilityDenominator))

                array<float> beforeValues = array.new<float>(bestSplit, na)
                array<float> afterValues = array.new<float>(length - bestSplit, na)

                for i = 0 to bestSplit - 1
                    array.set(beforeValues, i, array.get(values, i))

                for i = bestSplit to length - 1
                    array.set(afterValues, i - bestSplit, array.get(values, i))

                medianBefore := f_median(beforeValues)
                medianAfter := f_median(afterValues)

    [maximumStatistic, bestSplit, approximatePValue, medianBefore, medianAfter]

// =============================================================================
// 3. ROLLING PETTITT TEST
// =============================================================================

observation = source > 0.0 and source[returnHorizon] > 0.0 ? 100.0 * math.log(source / source[returnHorizon]) : na

[pettittStatistic, splitIndex, pValue, preBreakMedian, postBreakMedian] = f_pettitt(observation, windowLength, minimumSegment)

medianShift = postBreakMedian - preBreakMedian
observationDeviation = ta.stdev(observation, windowLength)
effectSize = observationDeviation > 0.0 ? medianShift / observationDeviation : 0.0
breakAge = not na(splitIndex) ? windowLength - splitIndex : na

barConfirmed = not confirmAtClose or barstate.isconfirmed
effectiveWarningAlpha = math.max(alpha, warningAlpha)

validTest = not na(pValue) and not na(breakAge)
recentBreak = validTest and breakAge <= maximumBreakAge
effectIsMeaningful = math.abs(effectSize) >= minimumEffectSize

confirmedBreak = recentBreak and pValue <= alpha and effectIsMeaningful
possibleBreak = recentBreak and pValue > alpha and pValue <= effectiveWarningAlpha and math.abs(effectSize) >= minimumEffectSize * 0.5

bullishBreakCondition = confirmedBreak and medianShift > 0.0
bearishBreakCondition = confirmedBreak and medianShift < 0.0
possibleBullishCondition = possibleBreak and medianShift > 0.0
possibleBearishCondition = possibleBreak and medianShift < 0.0

// A fresh event occurs when a condition first appears or when the estimated
// break age resets to a more recent point while the condition remains active.
newBullishBreak = barConfirmed and bullishBreakCondition and (not bullishBreakCondition[1] or breakAge < breakAge[1])
newBearishBreak = barConfirmed and bearishBreakCondition and (not bearishBreakCondition[1] or breakAge < breakAge[1])
newPossibleBullishBreak = barConfirmed and possibleBullishCondition and (not possibleBullishCondition[1] or breakAge < breakAge[1])
newPossibleBearishBreak = barConfirmed and possibleBearishCondition and (not possibleBearishCondition[1] or breakAge < breakAge[1])

// =============================================================================
// 4. EASY MODE DISPLAY
// =============================================================================

confidence = validTest ? 100.0 * (1.0 - pValue) : na
directionalConfidence = medianShift > 0.0 ? confidence : medianShift < 0.0 ? -confidence : 0.0

confirmedConfidenceLevel = 100.0 * (1.0 - alpha)
possibleConfidenceLevel = 100.0 * (1.0 - effectiveWarningAlpha)

upperConfirmedLine = hline(confirmedConfidenceLevel, "Confirmed bullish boundary", color = color.new(color.green, 20), linestyle = hline.style_dashed)
upperPossibleLine = hline(possibleConfidenceLevel, "Possible bullish boundary", color = color.new(color.orange, 35), linestyle = hline.style_dotted)
zeroLine = hline(0.0, "No directional shift", color = color.new(color.gray, 55))
lowerPossibleLine = hline(-possibleConfidenceLevel, "Possible bearish boundary", color = color.new(color.orange, 35), linestyle = hline.style_dotted)
lowerConfirmedLine = hline(-confirmedConfidenceLevel, "Confirmed bearish boundary", color = color.new(color.red, 20), linestyle = hline.style_dashed)
maximumLine = hline(100.0, "Maximum", color = color.new(color.white, 100), display = display.none)
minimumLine = hline(-100.0, "Minimum", color = color.new(color.white, 100), display = display.none)

fill(maximumLine, upperConfirmedLine, color = color.new(color.green, 91), title = "Confirmed bullish zone")
fill(upperConfirmedLine, upperPossibleLine, color = color.new(color.orange, 93), title = "Possible bullish zone")
fill(lowerPossibleLine, lowerConfirmedLine, color = color.new(color.orange, 93), title = "Possible bearish zone")
fill(lowerConfirmedLine, minimumLine, color = color.new(color.red, 91), title = "Confirmed bearish zone")

color detectorColor = bullishBreakCondition ? color.lime : bearishBreakCondition ? color.red : possibleBreak ? color.orange : color.gray
plot(directionalConfidence, "Directional confidence", color = detectorColor, linewidth = 3)

plotshape(
     showSignals and newBullishBreak,
     title = "Bullish structural break",
     style = shape.labelup,
     location = location.bottom,
     color = color.green,
     textcolor = color.white,
     size = size.tiny,
     text = "BULL"
)

plotshape(
     showSignals and newBearishBreak,
     title = "Bearish structural break",
     style = shape.labeldown,
     location = location.top,
     color = color.red,
     textcolor = color.white,
     size = size.tiny,
     text = "BEAR"
)

plotshape(
     showPossibleBreaks and newPossibleBullishBreak,
     title = "Possible bullish break",
     style = shape.triangleup,
     location = location.bottom,
     color = color.orange,
     size = size.tiny,
     text = "?"
)

plotshape(
     showPossibleBreaks and newPossibleBearishBreak,
     title = "Possible bearish break",
     style = shape.triangledown,
     location = location.top,
     color = color.orange,
     size = size.tiny,
     text = "?"
)

color stateBackground = bullishBreakCondition ? color.new(color.green, 92) : bearishBreakCondition ? color.new(color.red, 92) : possibleBreak ? color.new(color.orange, 93) : na
bgcolor(showBackground ? stateBackground : na, title = "Structural-break state")

// =============================================================================
// 5. DASHBOARD AND DATA WINDOW
// =============================================================================

string stateText = bullishBreakCondition ? "BULL STRUCTURAL BREAK" : bearishBreakCondition ? "BEAR STRUCTURAL BREAK" : possibleBullishCondition ? "POSSIBLE BULL BREAK" : possibleBearishCondition ? "POSSIBLE BEAR BREAK" : validTest and pValue <= alpha and not recentBreak ? "OLD BREAK" : "STABLE REGIME"

color stateColor = bullishBreakCondition ? color.green : bearishBreakCondition ? color.red : possibleBreak ? color.orange : color.gray
string pValueText = not validTest ? "N/A" : pValue < 0.001 ? "<0.001" : str.tostring(pValue, "#.###")
string breakAgeText = not validTest ? "N/A" : str.tostring(breakAge)
string medianShiftText = not validTest ? "N/A" : str.tostring(medianShift, "#.###") + " pp"
string effectSizeText = not validTest ? "N/A" : str.tostring(effectSize, "#.##") + " sigma"

var table dashboard = table.new(
     position.top_right,
     2,
     5,
     border_width = 1,
     border_color = color.new(color.gray, 50)
)

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "PETTITT STATE", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 1, 0, stateText, bgcolor = stateColor, text_color = color.white, text_size = size.small)
    table.cell(dashboard, 0, 1, "P VALUE APPROX", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 1, 1, pValueText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 0, 2, "BREAK AGE", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 1, 2, breakAgeText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 0, 3, "MEDIAN SHIFT", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 1, 3, medianShiftText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 0, 4, "EFFECT SIZE", bgcolor = color.new(color.black, 10), text_color = color.white, text_size = size.small)
    table.cell(dashboard, 1, 4, effectSizeText, bgcolor = color.new(stateColor, 65), text_color = color.white, text_size = size.small)

stateCode = bullishBreakCondition ? 2 : bearishBreakCondition ? -2 : possibleBullishCondition ? 1 : possibleBearishCondition ? -1 : 0

plot(stateCode, "State code", color = color.new(color.white, 100), display = display.data_window)
plot(pValue, "Approximate p-value", color = color.new(color.white, 100), display = display.data_window)
plot(breakAge, "Estimated break age", color = color.new(color.white, 100), display = display.data_window)
plot(medianShift, "Median shift in percentage points", color = color.new(color.white, 100), display = display.data_window)
plot(effectSize, "Median-shift effect size", color = color.new(color.white, 100), display = display.data_window)
plot(pettittStatistic, "Pettitt K statistic", color = color.new(color.white, 100), display = display.data_window)

// =============================================================================
// 6. ALERTS
// =============================================================================

alertcondition(newPossibleBullishBreak, "Pettitt - Possible bullish break", "Possible positive structural break detected on {{ticker}} ({{interval}}). Statistical confirmation is incomplete.")
alertcondition(newPossibleBearishBreak, "Pettitt - Possible bearish break", "Possible negative structural break detected on {{ticker}} ({{interval}}). Statistical confirmation is incomplete.")
alertcondition(newBullishBreak, "Pettitt - Bullish structural break", "Confirmed positive structural break detected on {{ticker}} ({{interval}}).")
alertcondition(newBearishBreak, "Pettitt - Bearish structural break", "Confirmed negative structural break detected on {{ticker}} ({{interval}}).")
````
