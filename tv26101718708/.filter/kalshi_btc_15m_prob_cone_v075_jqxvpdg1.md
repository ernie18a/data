# Kalshi BTC 15m Prob Cone v0.7.5

- url: https://www.tradingview.com/script/jqxVpdG1-Kalshi-BTC-15m-Prob-Cone-v0-7-5/
- type: indicator
- pine_id: PUB;4b6932b041114fc8b40787376dfb5bf3
- version: 1.0

## Description

Kalshi BTC 15m Probability Cone - Historical SMA
Overview
Kalshi BTC 15m Probability Cone - Historical SMA is a TradingView indicator designed for the Kalshi BTC 15-minute Up/Down market workflow.
It compares the current 60-period SMA to a fixed interval target, then scans historical SMA behavior over matching time windows. The result is a probability table and a forward probability cone showing how similar historical windows behaved into settlement.
The indicator is built for short-interval decision support. It does not predict the future, connect directly to Kalshi, or guarantee profitable trades. It uses the TradingView chart feed as its analysis source.
What It Does
At each 15-minute interval, the script:
1.	Captures the previous 60-period SMA as the interval target.
2.	Tracks the current 60-period SMA against that fixed target.
3.	Calculates the time remaining in the active interval.
4.	Scans historical SMA windows with the same remaining-time length.
5.	Weights historical samples by recency, volume similarity, and optional settlement-phase similarity.
6.	Estimates the probability of finishing above or below the target.
7.	Draws a probability cone from the current SMA into the rest of the interval.
8.	Displays feed, sample, and confidence diagnostics in a table.
The main question it answers is:
Based on similar historical SMA movement, how often did the SMA finish above or below the active 15-minute target?
Main Features
Historical Probability Table
The table gives a compact readout of the current interval.
It includes:
·	Status – Whether enough historical data is available.
·	Confidence – Quality level based on effective sample size.
·	Feed – Whether recent chart bars appear regular or gapped.
·	Time Window – Time remaining in the current 15-minute interval.
·	Current Dist – Current SMA distance from the interval target.
·	Prob Above – Weighted historical probability of finishing above the target.
·	Prob Below – Weighted historical probability of finishing below the target.
·	Max Up – Largest historical upward move in the analyzed windows.
·	Max Down – Largest historical downward move in the analyzed windows.
·	Recency λ – Current recency weighting setting.
·	Volume σ – Current volume similarity setting.
·	Raw Windows – Number of historical windows scanned.
·	Eff. Samples – Effective sample size after weighting.
·	Data Hours – Approximate stored historical data.
Probability Cone
The probability cone projects historical percentile ranges forward from the current SMA.
It includes:
·	p10
·	p25
·	p50 median
·	p75
·	p90
·	Max Up rail
·	Max Down rail
The percentile bands use weighted linear interpolation. This makes the cone smoother, especially when the effective sample size is low.
The Max Up and Max Down rails are not percentiles. They are exact historical extremes from the analyzed sample set.
15-Minute Interval Target
At the start of each 15-minute interval, the script captures the previous 60-period SMA.
That value becomes the interval target. The target is drawn as a purple horizontal line and remains fixed until the next interval begins.
Interval Boundary Lines
Purple vertical lines mark each 15-minute boundary.
These make it easier to see where each Kalshi-style interval begins and ends.
Feed Integrity Check
The Feed row checks whether the chart feed spacing matches the active chart timeframe.
Examples:
·	A 1-second chart expects about 1,000 ms between bars.
·	A 5-second chart expects about 5,000 ms between bars.
The tolerance is 25% of the expected bar gap.
This allows the indicator to degrade cleanly on other timeframes instead of assuming every chart is always 1 second.
Inputs
Display Options
Show Historical Probability Table

Turns the probability table on or off.
Show Probability Cone

Turns the forward cone on or off.
Table Position

Moves the table to one of the chart corners.
Calculation Settings
Minimum Sample Size

Sets the minimum effective sample size required before the model is considered ready.
Update Frequency

Controls how often the main probability scan updates.
Store Data Every N Seconds

Controls how often SMA and volume samples are stored.
Max History Samples

Limits stored history.
Max Analysis Iterations

Limits how many historical windows are scanned during the main probability calculation.
Weighting Parameters
Recency Decay (Lambda)

Controls how much recent data matters.
·	0.0 means no recency bias.
·	Small values apply mild recency bias.
·	Larger values make recent data dominate faster.
Volume Similarity (Sigma %)

Controls how strongly the model prefers historical windows with volume similar to the current bar.
·	Higher values are more neutral.
·	Lower values are stricter.
·	Very low values can sharply reduce effective sample size.
Settlement Phase Weighting
Settlement Phase Weighting Mode

Controls whether historical samples from a similar point inside the 15-minute interval get extra weight.
Available modes:
·	Off
·	Weighted
Settlement Phase Sigma

Controls how strict the settlement-phase matching is.
Lower values are stricter. Higher values are more forgiving.
Cone Settings
Cone Max Iterations

Controls how many historical windows are used for cone calculations.
Lower values improve performance. Higher values may improve stability, but they can increase chart load.
How to Read the Chart
Gray SMA Line
The gray line is the 60-period SMA.
This is the main value being compared against the interval target.
Purple Horizontal Line
The purple horizontal line is the active 15-minute target.
If the SMA is above this line, the interval is currently above target. If it is below this line, the interval is currently below target.
Purple Vertical Lines
The vertical lines mark 15-minute interval boundaries.
Probability Cone
The cone starts at the current SMA and extends toward the end of the interval.
A cone drifting upward means the weighted historical median is moving higher over the remaining window.
A cone drifting downward means the weighted historical median is moving lower over the remaining window.
A wide cone means historical outcomes were more spread out. A narrow cone means historical outcomes were more clustered.
Max Up and Max Down Rails
The dashed rails show the largest upside and downside moves found in the analyzed historical windows.
They are useful for context, but they are not hard limits. Market movement can exceed prior extremes.
How to Read the Table
Status
·	Ready means the model has enough effective samples.
·	Collecting data... means the model has not reached the minimum effective sample size.
Confidence
Confidence is based on effective sample size:
·	Low – fewer than 100 effective samples
·	Medium – 100 to 499 effective samples
·	Good – 500 to 999 effective samples
·	High – 1,000 or more effective samples
Feed
Feed status helps identify chart data problems:
·	OK – Bar spacing looks normal.
·	Recent Gaps – Recent irregular bars were detected.
·	Gap – The current bar spacing is irregular.
·	Initializing – Not enough bar history yet.
Prob Above / Prob Below
These are the main probability outputs.
They show the weighted historical percentage of comparable windows that finished above or below the active target.
Example:
Prob Above = 62%
This means 62% of the weighted historical windows finished above the target condition.
Current Dist
This shows the current percentage distance between the SMA and the active target.
Positive values mean the SMA is above target. Negative values mean the SMA is below target.
Raw Windows vs. Effective Samples
Raw Windows is the number of historical windows scanned.
Effective Samples is the usable sample size after weighting.
A high Raw Windows count with a low Effective Samples count means the weighting settings are aggressive.
Suggested Workflow for Kalshi BTC 15m Markets
1. Start with a Clean Baseline
Use neutral settings first:
·	Recency λ: 0.0
·	Volume σ: 100% or higher
·	Settlement Phase Weighting: Off
This gives the clearest view of the raw historical distribution.
2. Check the Feed Row
Do not trust the table if the feed is showing active gaps.
Short-interval markets are sensitive to missing bars. Bad input data produces bad probability output. Shocking, yes, but machines still cannot turn garbage into edge. 🧯
3. Check Effective Sample Size
Prefer readings with a reasonable effective sample size.
A strong probability with weak sample quality is fragile. It may still be useful, but it should be treated cautiously.
4. Compare Table Bias to Cone Shape
The best readings are cleaner when the table and cone agree.
For example:
·	Prob Above is clearly higher than Prob Below.
·	The cone median slopes upward.
·	The current SMA is not already stretched near the Max Up rail.
·	Feed status is OK.
·	Effective sample size is acceptable.
5. Avoid Treating Small Edges as Certainty
A 52% to 55% reading is not a magic button.
For a binary-style market, fees, spread, fill quality, and timing can easily erase a small statistical lean.
6. Use the Rails for Context
Max Up and Max Down show what happened in the most extreme historical windows.
They can help you avoid chasing when the current move is already stretched.
They should not be used as guaranteed ceilings or floors.
Practical Interpretation
The indicator is strongest as a context tool.
Useful situations include:
·	Estimating whether the current interval is statistically tilted.
·	Comparing the table probability against the cone median.
·	Checking whether current movement is stretched versus historical windows.
·	Identifying when weighting settings are too aggressive.
·	Spotting feed problems before trusting a short-interval readout.
Weak situations include:
·	Low effective sample size.
·	Recent feed gaps.
·	Sudden volatility regime changes.
·	Major news or exchange disruptions.
·	Thin or abnormal volume.
·	Overly strict recency, volume, or phase weighting.
Recommended Chart Setup
For the intended workflow, use:
·	BTC chart source that closely matches the market you are analyzing.
·	1-second chart when available.
·	Enough loaded history to build a useful sample.
·	Stable chart feed conditions.
·	Conservative weighting settings at first.
·	A separate check against Kalshi’s actual market and settlement rules.
The indicator uses TradingView chart data. It does not pull official Kalshi settlement values.
Limitations
This script is based entirely on historical SMA behavior.
It does not know:
·	Future news
·	Order-book changes
·	Kalshi liquidity shifts
·	Bid/ask spread behavior
·	Fill quality
·	Sudden volatility changes
·	Exchange outages
·	Macro events
·	Official settlement-feed discrepancies
Important limits:
·	Historical probability is not a forecast.
·	The cone is not a predicted path.
·	Max Up and Max Down are not hard boundaries.
·	Low effective sample size can make results unstable.
·	Aggressive weighting can create false confidence.
·	Poor chart data can distort the output.
·	A binary market can still be mispriced, illiquid, or difficult to enter and exit cleanly.
Use the indicator as decision support, not as an automated trading system.
Version Notes
v0.7.5
·	Renamed the indicator for the Kalshi BTC 15-minute market workflow.
·	Recommended title: Kalshi BTC 15m Probability Cone - Historical SMA.
·	Recommended short title: Kalshi BTC 15m Prob Cone.
·	Clarified that the indicator uses TradingView chart data and is not an official Kalshi settlement feed.
v0.7.4
·	Feed integrity now derives expected bar spacing from the chart timeframe.
·	Gap tolerance is now proportional at 25% of expected bar spacing.
·	Non-time-based charts fall back to a 1-second expectation.
·	Cone percentile bands now use linear interpolation between weighted ranks.
·	Probability table calculations are unchanged by the cone interpolation update.
·	Max Up and Max Down rails remain exact historical extremes.
v0.7.3
·	Settlement countdown was aligned to the same epoch-based interval clock used by interval boundaries.
·	Removed the older minute/second countdown dependency.
·	Improved consistency between interval boundary detection and remaining-time calculations.
v0.7.2
·	Replaced loose cache variables with typed cache structures.
·	Reduced cache-management complexity.
·	Preserved existing output behavior.
v0.7.1
·	Unified the scan and weighting path.
·	Shared one precomputed weight array between scan and cone calculations.
·	Reduced duplicated weighting work.
v0.7.0
·	Merged max-positive and max-negative extreme tracking into the main historical scan.
·	Added cone rails for maximum historical upside and downside.
·	Improved cone performance with a separate cone iteration cap.
Disclaimer
This script is for research, visualization, and educational use.
It does not provide financial advice. It does not guarantee profitable trades. It does not connect directly to Kalshi or certify settlement outcomes.
Historical probability can describe what happened before. It cannot guarantee what happens next.
Use proper risk controls.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © lazerorca360

//@version=6
indicator("Kalshi BTC 15m Prob Cone v0.7.5", overlay=true, max_lines_count=500, max_polylines_count=30)

// ============================================================================
// CORE MODEL — USER INPUTS
// ============================================================================
showHistoricalTable = input.bool(true, "Show Historical Probability Table", group="Display Options")
showProbabilityCone = input.bool(true, "Show Probability Cone", group="Display Options")
historicalTablePositionInput = input.string(
     "Bottom Left",
     "Table Position",
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"],
     group="Display Options"
)

minSampleSize = input.int(20, "Minimum Sample Size", minval=5, maxval=100, group="Calculation Settings")
updateFrequency = input.int(15, "Update Frequency (seconds)", minval=10, maxval=60, group="Calculation Settings")
historicalSampleRate = input.int(5, "Store Data Every N Seconds", minval=1, maxval=30, group="Calculation Settings")
maxHistoryBars = input.int(20000, "Max History Samples", minval=1000, maxval=50000, step=1000, group="Calculation Settings")
maxIterations = input.int(20000, "Max Analysis Iterations", minval=1000, maxval=30000, step=1000, group="Calculation Settings")

recencyLambda = input.float(
     0.0,
     "Recency Decay (Lambda)",
     minval=0.0,
     maxval=0.5,
     step=0.0001,
     tooltip="Controls how much recent data is weighted vs old data. 0.0 = neutral (equal weighting), 0.0001-0.0005 = typical range, higher values = stronger recency bias",
     group="Weighting Parameters"
)

volumeSigma = input.float(
     100.0,
     "Volume Similarity (Sigma %)",
     minval=10.0,
     maxval=200.0,
     step=5.0,
     tooltip="Controls volume regime matching. 100+ = neutral (all volumes), 50 = moderate matching, 30 = strict matching to similar volume periods",
     group="Weighting Parameters"
)

// ============================================================================
// SETTLEMENT PHASE WEIGHTING OVERLAY — USER INPUTS
// ============================================================================
settlementPhaseWeightingMode = input.string(
     "Off",
     "Settlement Phase Weighting Mode",
     options=["Off", "Weighted"],
     group="Settlement Phase Weighting"
)

settlementPhaseSigmaSeconds = input.int(
     10,
     "Settlement Phase Sigma (seconds)",
     minval=1,
     maxval=120,
     tooltip="When Weighted, used as Gaussian sigma for Settlement Phase Weighting.",
     group="Settlement Phase Weighting"
)

settlementPhaseWeightingEnabled = settlementPhaseWeightingMode == "Weighted"

// ============================================================================
// CORE MODEL — CONE SETTINGS
// ============================================================================
coneStepSeconds = 15
coneUpdateSeconds = 15
coneMaxIterations = input.int(
     1000,
     "Cone Max Iterations",
     minval=250,
     maxval=10000,
     step=250,
     group="Cone Settings",
     tooltip="Separate iteration cap for cone percentiles and cone extreme rails to reduce runtime. Lower = faster."
)

// ============================================================================
// USER-DEFINED TYPES — CACHE STATE (folds #10)
// ----------------------------------------------------------------------------
// Each heavy-update / cone refresh previously tracked ~14 loose `var` cache
// fields plus a hand-written multi-line comparison.  Bundling them into typed
// objects makes "what invalidates this cache" a single visible structure and
// turns the commit step into one constructor assignment.
//
// Numeric/string fields default to na / "" exactly as the old `var` fields did.
// The bool field defaults to false (never na), preserving the no-bool-na rule.
// ============================================================================
type ScanCache
    int updateBucket = na
    int historySize = na
    int timeRemainingRounded = na
    int windowSizeInSamples = na
    float targetPrice = na
    float sma = na
    float vol = na
    float settlementPhaseSeconds = na
    float lambda = na
    float sigma = na
    string settlementPhaseMode = ""
    int settlementPhaseSigmaSeconds = na
    int maxIterations = na
    int minSampleSize = na

type ConeCache
    int updateBucket = na
    int intervalId = na
    int historySize = na
    int timeRemainingRounded = na
    float targetPrice = na
    float sma = na
    float vol = na
    float settlementPhaseSeconds = na
    float lambda = na
    float sigma = na
    string settlementPhaseMode = ""
    int settlementPhaseSigmaSeconds = na
    int maxIterations = na
    int stepSeconds = na
    bool show = false

// ============================================================================
// CORE MODEL — HELPER FUNCTIONS
// ============================================================================
f_calculateConfidence(float samples) =>
    if samples < 100
        "Low"
    else if samples < 500
        "Medium"
    else if samples < 1000
        "Good"
    else
        "High"

f_getConfidenceColor(float samples) =>
    if samples < 100
        color.new(color.red, 50)
    else if samples < 500
        color.new(color.orange, 50)
    else if samples < 1000
        color.new(color.yellow, 50)
    else
        color.new(color.green, 50)

f_formatTimeWindow(int secondsRemaining) =>
    timeMinutes = int(math.floor(secondsRemaining / 60))
    timeSeconds = int(secondsRemaining % 60)
    str.tostring(timeMinutes) + "m " + str.tostring(timeSeconds) + "s"

f_getFeedStatusText(float barGapMs, bool isIrregularBar, float recentIrregularBars) =>
    na(barGapMs) ? "Initializing" : isIrregularBar ? "Gap " + str.tostring(barGapMs / 1000.0, "#.###") + "s" : recentIrregularBars > 0 ? "Recent Gaps" : "OK"

f_getFeedStatusColor(float barGapMs, bool isIrregularBar, float recentIrregularBars) =>
    na(barGapMs) ? color.new(color.gray, 50) : isIrregularBar ? color.new(color.red, 40) : recentIrregularBars > 0 ? color.new(color.orange, 40) : color.new(color.green, 60)

f_getTablePosition(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_weightedInterpolatedPercentile(
    array<float> projectedValues,
    array<float> projectedWeights,
    array<int> sortedIdx,
    float targetWeight
) =>
    float percentileValue = na
    int n = array.size(sortedIdx)

    if n > 0
        int firstIdx = array.get(sortedIdx, 0)
        float firstValue = array.get(projectedValues, firstIdx)
        float prevValue = firstValue
        float prevCumulative = 0.0
        float cumulativeWeight = 0.0

        for rank = 0 to n - 1
            int idx = array.get(sortedIdx, rank)
            float value = array.get(projectedValues, idx)
            float weight = array.get(projectedWeights, idx)
            cumulativeWeight += weight

            if na(percentileValue) and cumulativeWeight >= targetWeight
                float denom = cumulativeWeight - prevCumulative
                float frac = denom > 0 ? (targetWeight - prevCumulative) / denom : 0.0
                frac := math.max(0.0, math.min(1.0, frac))
                percentileValue := prevValue + frac * (value - prevValue)

            prevValue := value
            prevCumulative := cumulativeWeight

        if na(percentileValue)
            int lastIdx = array.get(sortedIdx, n - 1)
            percentileValue := array.get(projectedValues, lastIdx)

    percentileValue

// ============================================================================
// SETTLEMENT PHASE WEIGHTING OVERLAY — HELPER FUNCTION
// ============================================================================
f_getSettlementPhaseWeight(float currentPhaseSeconds, float historicalPhaseSeconds, float sigmaSeconds) =>
    float phaseDiff = math.abs(historicalPhaseSeconds - currentPhaseSeconds)
    sigmaSeconds > 0 ? math.exp(-(phaseDiff * phaseDiff) / (2.0 * sigmaSeconds * sigmaSeconds)) : 1.0

// ============================================================================
// UNIFIED WEIGHTING — SINGLE PRECOMPUTE PASS (folds #6 + #7 + #8)
// ----------------------------------------------------------------------------
// One pass over the active historical array produces a per-sample weight that
// is shared by BOTH the probability scan and the cone.  Recency, volume, and
// (optionally) settlement-phase weights are all horizon-independent.
//
//   weight[i] = recencyWeight(i) * volumeWeight(i) [* phaseWeight(i)]
//
// Recency uses distance-from-end-of-array: exp(-lambda * (arrSize - 1 - i)),
// which differs from the old per-window basis only by a uniform constant that
// cancels in probability ratios, effective-sample-size ratios, and cumulative
// percentile fractions.  #6 is satisfied: volumeSigmaAbsolute is computed once.
// ============================================================================
f_computeWeights(
    array<float> volumeArray,
    array<float> phaseArray,
    float currentVol,
    float currentPhaseSeconds,
    float recencyLambdaValue,
    float volumeSigmaValue,
    float phaseSigmaSeconds,
    bool phaseEnabled
) =>
    int arrSize = array.size(volumeArray)
    array<float> weights = array.new<float>(arrSize, 0.0)

    // #6: loop-invariant volume sigma hoisted out of the loop.
    float volumeSigmaAbsolute = (volumeSigmaValue / 100.0) * currentVol
    bool volumeSigmaUsable = volumeSigmaAbsolute > 0
    float volumeDenom = volumeSigmaUsable ? (2.0 * volumeSigmaAbsolute * volumeSigmaAbsolute) : 1.0

    bool phaseUsable = phaseEnabled and array.size(phaseArray) == arrSize

    for i = 0 to arrSize - 1
        int distFromEnd = arrSize - 1 - i
        float recencyWeight = math.exp(-recencyLambdaValue * distFromEnd)

        float volStart = array.get(volumeArray, i)
        float volumeDifference = volStart - currentVol
        float volumeWeight = volumeSigmaUsable ? math.exp(-(volumeDifference * volumeDifference) / volumeDenom) : 1.0

        float w = recencyWeight * volumeWeight

        if phaseUsable
            float historicalPhase = array.get(phaseArray, i)
            float phaseWeight = f_getSettlementPhaseWeight(currentPhaseSeconds, historicalPhase, phaseSigmaSeconds)
            w := w * phaseWeight

        array.set(weights, i, w)

    weights

// ============================================================================
// UNIFIED HISTORICAL SCAN (folds #8) — CONSUMES PRECOMPUTED WEIGHTS (folds #7)
// ----------------------------------------------------------------------------
// Replaces f_scanHistoricalWindowsCore and f_scanHistoricalWindowsWeighted.
// All weighting differences between Off and Weighted modes live in the shared
// weights array, so a single scan serves both modes.  Extremes (Max Up / Down)
// are tracked in the same loop and scoped to the same weight>0 window set as
// the probability totals.
// ============================================================================
f_scanHistoricalWindows(
    int windowSizeInSamples,
    float targetPrice,
    float currentSma,
    int maxIterationsValue,
    array<float> smaArray,
    array<float> weightsArray
) =>
    float weightedSamplesAboveLocal = 0.0
    float weightedSamplesBelowLocal = 0.0
    float totalWeightedSamplesLocal = 0.0
    float sumSquaredWeightsLocal = 0.0
    float effectiveSampleSizeLocal = 0.0
    int rawWindowsAnalyzedLocal = 0
    float maxPositiveChangeLocal = na
    float maxNegativeChangeLocal = na

    int historicalArraySizeLocal = array.size(smaArray)
    float thresholdChangeLocal = ((targetPrice / currentSma) - 1.0) * 100.0

    if historicalArraySizeLocal > windowSizeInSamples + 10 and array.size(weightsArray) == historicalArraySizeLocal
        int totalAvailableWindows = historicalArraySizeLocal - windowSizeInSamples
        int numWindowsToAnalyze = math.min(totalAvailableWindows, maxIterationsValue)
        int startIndex = totalAvailableWindows - numWindowsToAnalyze

        for i = startIndex to totalAvailableWindows - 1
            float smaStart = array.get(smaArray, i)
            float combinedWeight = array.get(weightsArray, i)

            if smaStart != 0 and combinedWeight > 0
                float smaEnd = array.get(smaArray, i + windowSizeInSamples)
                rawWindowsAnalyzedLocal += 1

                float percentChange = ((smaEnd - smaStart) / smaStart) * 100.0

                if na(maxPositiveChangeLocal) or percentChange > maxPositiveChangeLocal
                    maxPositiveChangeLocal := percentChange
                if na(maxNegativeChangeLocal) or percentChange < maxNegativeChangeLocal
                    maxNegativeChangeLocal := percentChange

                totalWeightedSamplesLocal += combinedWeight
                sumSquaredWeightsLocal += combinedWeight * combinedWeight

                if percentChange > thresholdChangeLocal
                    weightedSamplesAboveLocal += combinedWeight
                else
                    weightedSamplesBelowLocal += combinedWeight

    effectiveSampleSizeLocal := sumSquaredWeightsLocal > 0 ? (totalWeightedSamplesLocal * totalWeightedSamplesLocal) / sumSquaredWeightsLocal : 0.0
    [weightedSamplesAboveLocal, weightedSamplesBelowLocal, totalWeightedSamplesLocal, effectiveSampleSizeLocal, rawWindowsAnalyzedLocal, maxPositiveChangeLocal, maxNegativeChangeLocal]

// ============================================================================
// CORE MODEL — CONE PERCENTILES WITH PRECOMPUTED WEIGHTS
// ============================================================================
f_calcConePercentilesPrecomputed(
    int horizonSeconds,
    float currentSma,
    int coneMaxIterationsValue,
    int sampleRateSeconds,
    array<float> smaArray,
    array<float> precomputedWeights
) =>
    float p10 = na
    float p25 = na
    float p50 = na
    float p75 = na
    float p90 = na
    float railDown = na
    float railUp = na

    int historicalArraySizeLocal = array.size(smaArray)
    int windowSizeInSamples = int(math.round(horizonSeconds / sampleRateSeconds))

    array<float> projectedValues = array.new<float>()
    array<float> projectedWeights = array.new<float>()

    if windowSizeInSamples > 0 and historicalArraySizeLocal > windowSizeInSamples + 10 and array.size(precomputedWeights) == historicalArraySizeLocal
        int totalAvailableWindows = historicalArraySizeLocal - windowSizeInSamples
        int numWindowsToAnalyze = math.min(totalAvailableWindows, coneMaxIterationsValue)
        int startIndex = totalAvailableWindows - numWindowsToAnalyze

        for i = startIndex to totalAvailableWindows - 1
            float smaStart = array.get(smaArray, i)
            float combinedWeight = array.get(precomputedWeights, i)

            if smaStart != 0 and combinedWeight > 0
                float smaEnd = array.get(smaArray, i + windowSizeInSamples)
                float percentChange = ((smaEnd - smaStart) / smaStart) * 100.0
                float projectedPrice = currentSma * (1.0 + percentChange / 100.0)

                // Rails scoped to weight>0 windows, matching the percentile set.
                if na(railUp) or projectedPrice > railUp
                    railUp := projectedPrice
                if na(railDown) or projectedPrice < railDown
                    railDown := projectedPrice

                array.push(projectedValues, projectedPrice)
                array.push(projectedWeights, combinedWeight)

        int n = array.size(projectedValues)
        if n > 0
            float totalWeightLocal = 0.0
            for i = 0 to n - 1
                totalWeightLocal += array.get(projectedWeights, i)

            if totalWeightLocal > 0
                array<int> sortedIdx = array.sort_indices(projectedValues, order.ascending)

                float target10 = 0.10 * totalWeightLocal
                float target25 = 0.25 * totalWeightLocal
                float target50 = 0.50 * totalWeightLocal
                float target75 = 0.75 * totalWeightLocal
                float target90 = 0.90 * totalWeightLocal

                // Interpolated weighted percentiles: instead of snapping to the
                // first sorted value whose cumulative weight crosses the target,
                // interpolate between the previous rank and the crossing rank.
                // This only affects cone bands/median, not probability scan totals
                // or exact max/min rails.
                p10 := f_weightedInterpolatedPercentile(projectedValues, projectedWeights, sortedIdx, target10)
                p25 := f_weightedInterpolatedPercentile(projectedValues, projectedWeights, sortedIdx, target25)
                p50 := f_weightedInterpolatedPercentile(projectedValues, projectedWeights, sortedIdx, target50)
                p75 := f_weightedInterpolatedPercentile(projectedValues, projectedWeights, sortedIdx, target75)
                p90 := f_weightedInterpolatedPercentile(projectedValues, projectedWeights, sortedIdx, target90)

    [p10, p25, p50, p75, p90, railDown, railUp]

// ============================================================================
// CORE MODEL — BASE SMA, FEED INTEGRITY CHECK, AND INTERVAL TRACKING
// ============================================================================
sma60 = ta.sma(close, 60)

timeframeSeconds = timeframe.in_seconds()
expectedBarGapMs = na(timeframeSeconds) or timeframeSeconds <= 0 ? 1000.0 : timeframeSeconds * 1000.0
gapToleranceMs = expectedBarGapMs * 0.25
irregularLookbackBars = 300

barGapMs = na(time[1]) ? na : time - time[1]
isIrregularBar = not na(barGapMs) and math.abs(barGapMs - expectedBarGapMs) > gapToleranceMs

irregularBarValue = isIrregularBar ? 1.0 : 0.0
irregularBarCum = ta.cum(irregularBarValue)
recentIrregularBars = bar_index >= irregularLookbackBars ? irregularBarCum - irregularBarCum[irregularLookbackBars] : irregularBarCum

feedStatusText = f_getFeedStatusText(barGapMs, isIrregularBar, recentIrregularBars)
feedStatusColor = f_getFeedStatusColor(barGapMs, isIrregularBar, recentIrregularBars)

intervalMs = 15 * 60 * 1000
currentIntervalId = int(math.floor(time / intervalMs))
prevIntervalId = na(time[1]) ? na : int(math.floor(time[1] / intervalMs))
crossedIntervalBoundary = na(prevIntervalId) or currentIntervalId != prevIntervalId

var array<line> horizontalLines = array.new<line>()
var array<line> verticalLines = array.new<line>()

maxHorizontalLines = 10
maxVerticalLines = 100

var float currentTargetPrice = na
var line currentHorizontalLine = na

if crossedIntervalBoundary
    line newVerticalLine = line.new(bar_index, low, bar_index, high, color=color.purple, width=3, style=line.style_solid, extend=extend.both)
    if array.size(verticalLines) >= maxVerticalLines
        line oldVerticalLine = array.shift(verticalLines)
        line.delete(oldVerticalLine)
    array.push(verticalLines, newVerticalLine)

    if not na(currentHorizontalLine)
        line.set_x2(currentHorizontalLine, bar_index)

    if not na(sma60[1])
        currentTargetPrice := sma60[1]

        currentHorizontalLine := line.new(bar_index, currentTargetPrice, bar_index + 1, currentTargetPrice, color=color.purple, width=3, style=line.style_solid)

        if array.size(horizontalLines) >= maxHorizontalLines
            line oldLine = array.shift(horizontalLines)
            line.delete(oldLine)

        array.push(horizontalLines, currentHorizontalLine)

if not na(currentHorizontalLine) and not crossedIntervalBoundary
    line.set_x2(currentHorizontalLine, bar_index)

// ============================================================================
// CORE MODEL — TIME-TO-INTERVAL CALCULATOR
// ----------------------------------------------------------------------------
// #1: Derived from the SAME UTC epoch basis as currentIntervalId / intervalMs
// (time % intervalMs) rather than minute(time)/second(time).  The boundary that
// fires crossedIntervalBoundary and the countdown that drives windowSizeInSamples
// now share one clock and cannot desync.
//
//   msIntoInterval = ms elapsed since the start of the current 15-min block
//   timeRemaining  = whole seconds until the next quarter-hour boundary
//
// On UTC-quoted feeds and any whole-hour-offset exchange timezone (including the
// quarter-hour ET/UTC settlement Kalshi uses) this is numerically identical to
// the previous minute(time)/second(time) calculation.  It only diverges — and
// self-corrects — on exotic half/quarter-hour-offset exchange timezones where
// minute(time) would have measured a clock misaligned from the actual interval.
// On a 1-second feed time is whole-second aligned, so the int() truncation is
// exact (msIntoInterval is always a whole number of seconds).
// ============================================================================
msIntoInterval = time % intervalMs
timeRemaining = int((intervalMs - msIntoInterval) / 1000)
timeRemainingRounded = int(math.round(timeRemaining / 5.0) * 5.0)
currentSettlementPhaseSeconds = float(timeRemaining)

// ============================================================================
// CORE MODEL — CURRENT DISTANCE CALCULATOR
// ============================================================================
currentDistance = not na(currentTargetPrice) ? sma60 - currentTargetPrice : 0.0
currentPercentDistance = not na(currentTargetPrice) and currentTargetPrice != 0 ? (currentDistance / currentTargetPrice) * 100.0 : 0.0

// ============================================================================
// CORE MODEL — HISTORICAL DATA COLLECTION
// ============================================================================
var array<float> historicalSMA = array.new<float>()
var array<float> historicalVolume = array.new<float>()

// ============================================================================
// SETTLEMENT PHASE WEIGHTING OVERLAY — HISTORICAL DATA COLLECTION
// NOTE:
// These arrays remain completely dormant when Settlement Phase Weighting is Off.
// No push, shift, or read occurs unless the overlay is enabled.
// ============================================================================
var array<float> overlayHistoricalSMA = array.new<float>()
var array<float> overlayHistoricalVolume = array.new<float>()
var array<float> overlayHistoricalSettlementPhaseSeconds = array.new<float>()

sampleIntervalMs = historicalSampleRate * 1000
currentSampleBucket = int(math.floor(time / sampleIntervalMs))
prevSampleBucket = na(time[1]) ? na : int(math.floor(time[1] / sampleIntervalMs))
shouldStoreSample = na(prevSampleBucket) or currentSampleBucket != prevSampleBucket

if bar_index >= 60 and shouldStoreSample
    // Core history always collects.
    array.push(historicalSMA, sma60)
    array.push(historicalVolume, volume)

    if array.size(historicalSMA) > maxHistoryBars
        array.shift(historicalSMA)
        array.shift(historicalVolume)

    // Overlay history collects only when enabled.
    if settlementPhaseWeightingEnabled
        array.push(overlayHistoricalSMA, sma60)
        array.push(overlayHistoricalVolume, volume)
        array.push(overlayHistoricalSettlementPhaseSeconds, currentSettlementPhaseSeconds)

        if array.size(overlayHistoricalSMA) > maxHistoryBars
            array.shift(overlayHistoricalSMA)
            array.shift(overlayHistoricalVolume)
            array.shift(overlayHistoricalSettlementPhaseSeconds)

// ============================================================================
// SHARED ACTIVE ARRAYS — selected once for both the scan and the cone.
// ============================================================================
bool phaseOn = settlementPhaseWeightingEnabled
array<float> activeSmaArray = phaseOn ? overlayHistoricalSMA : historicalSMA
array<float> activeVolArray = phaseOn ? overlayHistoricalVolume : historicalVolume

// ============================================================================
// UPDATE GATING — heavy scan and cone share the same confirmed-last-bar gate.
// ============================================================================
updateIntervalMs = updateFrequency * 1000
currentUpdateBucket = int(math.floor(time / updateIntervalMs))
prevUpdateBucket = na(time[1]) ? na : int(math.floor(time[1] / updateIntervalMs))
shouldUpdate = na(prevUpdateBucket) or currentUpdateBucket != prevUpdateBucket
runHeavyUpdate = barstate.islast and barstate.isconfirmed and shouldUpdate

coneUpdateIntervalMs = coneUpdateSeconds * 1000
currentConeUpdateBucket = int(math.floor(time / coneUpdateIntervalMs))
prevConeUpdateBucket = na(time[1]) ? na : int(math.floor(time[1] / coneUpdateIntervalMs))
shouldConeUpdate = na(prevConeUpdateBucket) or currentConeUpdateBucket != prevConeUpdateBucket
runConeUpdate = barstate.islast and barstate.isconfirmed and shouldConeUpdate

// ============================================================================
// SHARED WEIGHTS — built once per refresh bar, consumed by scan AND cone (#7).
// ============================================================================
var array<float> sharedWeights = array.new<float>()

if runHeavyUpdate or runConeUpdate
    sharedWeights := f_computeWeights(
         activeVolArray,
         overlayHistoricalSettlementPhaseSeconds,
         volume,
         currentSettlementPhaseSeconds,
         recencyLambda,
         volumeSigma,
         settlementPhaseSigmaSeconds,
         phaseOn
    )

// ============================================================================
// CORE MODEL / OVERLAY — HISTORICAL PROBABILITY (WITH TYPED CACHE)
// ============================================================================
var float weightedSamplesAbove = 0.0
var float weightedSamplesBelow = 0.0
var float maxPositiveChange = na
var float maxNegativeChange = na
var float totalWeightedSamples = 0.0
var float effectiveSampleSize = 0.0
var int rawWindowsAnalyzed = 0
var bool dataReady = false

var ScanCache scanCache = ScanCache.new()

if runHeavyUpdate
    if not na(currentTargetPrice) and timeRemainingRounded > 0 and sma60 != 0
        int activeHistorySize = array.size(activeSmaArray)
        int windowSizeInSamples = int(math.round(timeRemainingRounded / historicalSampleRate))

        bool phaseCacheChanged = settlementPhaseWeightingEnabled ?
             (currentSettlementPhaseSeconds != scanCache.settlementPhaseSeconds or settlementPhaseWeightingMode != scanCache.settlementPhaseMode or settlementPhaseSigmaSeconds != scanCache.settlementPhaseSigmaSeconds) :
             (settlementPhaseWeightingMode != scanCache.settlementPhaseMode)

        bool cacheRefreshNeeded =
             na(scanCache.updateBucket) or
             currentUpdateBucket != scanCache.updateBucket or
             activeHistorySize != scanCache.historySize or
             timeRemainingRounded != scanCache.timeRemainingRounded or
             windowSizeInSamples != scanCache.windowSizeInSamples or
             currentTargetPrice != scanCache.targetPrice or
             sma60 != scanCache.sma or
             volume != scanCache.vol or
             recencyLambda != scanCache.lambda or
             volumeSigma != scanCache.sigma or
             phaseCacheChanged or
             maxIterations != scanCache.maxIterations or
             minSampleSize != scanCache.minSampleSize

        if cacheRefreshNeeded
            // Single unified scan for both Off and Weighted modes (#8),
            // consuming the shared precomputed weights (#7).
            [scanWeightedAbove, scanWeightedBelow, scanTotalWeighted, scanEffectiveSampleSize, scanRawWindows, scanMaxUp, scanMaxDown] = f_scanHistoricalWindows(
                 windowSizeInSamples,
                 currentTargetPrice,
                 sma60,
                 maxIterations,
                 activeSmaArray,
                 sharedWeights
            )

            weightedSamplesAbove := scanWeightedAbove
            weightedSamplesBelow := scanWeightedBelow
            totalWeightedSamples := scanTotalWeighted
            effectiveSampleSize := scanEffectiveSampleSize
            rawWindowsAnalyzed := scanRawWindows
            maxPositiveChange := scanMaxUp
            maxNegativeChange := scanMaxDown

            dataReady := effectiveSampleSize >= minSampleSize

            // #10: single grouped commit of the entire cache snapshot.
            scanCache := ScanCache.new(
                 updateBucket = currentUpdateBucket,
                 historySize = activeHistorySize,
                 timeRemainingRounded = timeRemainingRounded,
                 windowSizeInSamples = windowSizeInSamples,
                 targetPrice = currentTargetPrice,
                 sma = sma60,
                 vol = volume,
                 settlementPhaseSeconds = currentSettlementPhaseSeconds,
                 lambda = recencyLambda,
                 sigma = volumeSigma,
                 settlementPhaseMode = settlementPhaseWeightingMode,
                 settlementPhaseSigmaSeconds = settlementPhaseSigmaSeconds,
                 maxIterations = maxIterations,
                 minSampleSize = minSampleSize
             )
    else
        weightedSamplesAbove := 0.0
        weightedSamplesBelow := 0.0
        totalWeightedSamples := 0.0
        effectiveSampleSize := 0.0
        rawWindowsAnalyzed := 0
        maxPositiveChange := na
        maxNegativeChange := na
        dataReady := false

probabilityAboveHistorical = totalWeightedSamples > 0 ? (weightedSamplesAbove / totalWeightedSamples) * 100.0 : 0.0
probabilityBelowHistorical = totalWeightedSamples > 0 ? (weightedSamplesBelow / totalWeightedSamples) * 100.0 : 0.0

// ============================================================================
// CORE MODEL — CONFIDENCE
// ============================================================================
confidenceLevel = f_calculateConfidence(effectiveSampleSize)
confidenceColor = f_getConfidenceColor(effectiveSampleSize)

// ============================================================================
// CORE MODEL / OVERLAY — PROBABILITY CONE (WITH TYPED CACHE + SHARED WEIGHTS)
// ============================================================================
var polyline coneOuterBand = na
var polyline coneInnerBand = na
var polyline coneMedianLine = na
var polyline coneP10Line = na
var polyline coneP25Line = na
var polyline coneP75Line = na
var polyline coneP90Line = na
var polyline coneMaxUpRail = na
var polyline coneMaxDownRail = na

var ConeCache coneCache = ConeCache.new()

if runConeUpdate
    int activeConeHistorySize = array.size(activeSmaArray)

    bool conePhaseCacheChanged = settlementPhaseWeightingEnabled ?
         (currentSettlementPhaseSeconds != coneCache.settlementPhaseSeconds or settlementPhaseWeightingMode != coneCache.settlementPhaseMode or settlementPhaseSigmaSeconds != coneCache.settlementPhaseSigmaSeconds) :
         (settlementPhaseWeightingMode != coneCache.settlementPhaseMode)

    bool coneRefreshNeeded =
         na(coneCache.updateBucket) or
         currentConeUpdateBucket != coneCache.updateBucket or
         currentIntervalId != coneCache.intervalId or
         activeConeHistorySize != coneCache.historySize or
         timeRemainingRounded != coneCache.timeRemainingRounded or
         currentTargetPrice != coneCache.targetPrice or
         sma60 != coneCache.sma or
         volume != coneCache.vol or
         recencyLambda != coneCache.lambda or
         volumeSigma != coneCache.sigma or
         conePhaseCacheChanged or
         coneMaxIterations != coneCache.maxIterations or
         coneStepSeconds != coneCache.stepSeconds or
         showProbabilityCone != coneCache.show

    if coneRefreshNeeded
        if not na(coneOuterBand)
            polyline.delete(coneOuterBand)
            coneOuterBand := na
        if not na(coneInnerBand)
            polyline.delete(coneInnerBand)
            coneInnerBand := na
        if not na(coneMedianLine)
            polyline.delete(coneMedianLine)
            coneMedianLine := na
        if not na(coneP10Line)
            polyline.delete(coneP10Line)
            coneP10Line := na
        if not na(coneP25Line)
            polyline.delete(coneP25Line)
            coneP25Line := na
        if not na(coneP75Line)
            polyline.delete(coneP75Line)
            coneP75Line := na
        if not na(coneP90Line)
            polyline.delete(coneP90Line)
            coneP90Line := na
        if not na(coneMaxUpRail)
            polyline.delete(coneMaxUpRail)
            coneMaxUpRail := na
        if not na(coneMaxDownRail)
            polyline.delete(coneMaxDownRail)
            coneMaxDownRail := na

        if showProbabilityCone and not na(currentTargetPrice) and sma60 != 0 and timeRemainingRounded >= coneStepSeconds and effectiveSampleSize >= minSampleSize
            // Cone consumes the same sharedWeights array built once above (#7).
            array<chart.point> p10Points = array.new<chart.point>()
            array<chart.point> p25Points = array.new<chart.point>()
            array<chart.point> p50Points = array.new<chart.point>()
            array<chart.point> p75Points = array.new<chart.point>()
            array<chart.point> p90Points = array.new<chart.point>()
            array<chart.point> maxUpPoints = array.new<chart.point>()
            array<chart.point> maxDownPoints = array.new<chart.point>()

            chart.point anchorPoint = chart.point.from_time(time, sma60)
            array.push(p10Points, anchorPoint)
            array.push(p25Points, anchorPoint)
            array.push(p50Points, anchorPoint)
            array.push(p75Points, anchorPoint)
            array.push(p90Points, anchorPoint)
            array.push(maxUpPoints, anchorPoint)
            array.push(maxDownPoints, anchorPoint)

            for horizon = coneStepSeconds to timeRemainingRounded by coneStepSeconds
                [q10, q25, q50, q75, q90, qRailDown, qRailUp] = f_calcConePercentilesPrecomputed(
                     horizon,
                     sma60,
                     coneMaxIterations,
                     historicalSampleRate,
                     activeSmaArray,
                     sharedWeights
                )

                if not na(q10) and not na(q25) and not na(q50) and not na(q75) and not na(q90) and not na(qRailDown) and not na(qRailUp)
                    int futureTime = time + horizon * 1000
                    array.push(p10Points, chart.point.from_time(futureTime, q10))
                    array.push(p25Points, chart.point.from_time(futureTime, q25))
                    array.push(p50Points, chart.point.from_time(futureTime, q50))
                    array.push(p75Points, chart.point.from_time(futureTime, q75))
                    array.push(p90Points, chart.point.from_time(futureTime, q90))
                    array.push(maxUpPoints, chart.point.from_time(futureTime, qRailUp))
                    array.push(maxDownPoints, chart.point.from_time(futureTime, qRailDown))

            int pointCount = array.size(p50Points)
            if pointCount >= 2
                chart.point terminalMedianPoint = array.get(p50Points, pointCount - 1)
                float terminalMedianPrice = terminalMedianPoint.price

                bool isBullCone = terminalMedianPrice > currentTargetPrice
                bool isBearCone = terminalMedianPrice < currentTargetPrice

                color outerFillColor = isBullCone ? color.new(color.lime, 88) : isBearCone ? color.new(color.red, 88) : color.new(color.blue, 88)
                color innerFillColor = isBullCone ? color.new(color.lime, 80) : isBearCone ? color.new(color.red, 80) : color.new(color.aqua, 80)

                color outerBorderColor = isBullCone ? color.new(color.lime, 55) : isBearCone ? color.new(color.red, 55) : color.new(color.blue, 55)
                color innerBorderColor = isBullCone ? color.new(color.lime, 35) : isBearCone ? color.new(color.red, 35) : color.new(color.aqua, 35)

                color medianColor = isBullCone ? color.lime : isBearCone ? color.red : color.white
                color railColor = isBullCone ? color.new(color.lime, 15) : isBearCone ? color.new(color.red, 15) : color.new(color.gray, 20)

                array<chart.point> outerBandPoints = array.new<chart.point>()
                array<chart.point> innerBandPoints = array.new<chart.point>()

                for i = 0 to array.size(p90Points) - 1
                    array.push(outerBandPoints, array.get(p90Points, i))
                for i = array.size(p10Points) - 1 to 1
                    array.push(outerBandPoints, array.get(p10Points, i))

                for i = 0 to array.size(p75Points) - 1
                    array.push(innerBandPoints, array.get(p75Points, i))
                for i = array.size(p25Points) - 1 to 1
                    array.push(innerBandPoints, array.get(p25Points, i))

                coneOuterBand := polyline.new(
                     outerBandPoints,
                     curved=false,
                     closed=true,
                     xloc=xloc.bar_time,
                     line_color=outerBorderColor,
                     fill_color=outerFillColor,
                     line_style=line.style_solid,
                     line_width=1
                )

                coneInnerBand := polyline.new(
                     innerBandPoints,
                     curved=false,
                     closed=true,
                     xloc=xloc.bar_time,
                     line_color=innerBorderColor,
                     fill_color=innerFillColor,
                     line_style=line.style_solid,
                     line_width=1
                )

                coneP10Line := polyline.new(
                     p10Points,
                     curved=false,
                     closed=false,
                     xloc=xloc.bar_time,
                     line_color=color.new(outerBorderColor, 10),
                     line_style=line.style_solid,
                     line_width=1
                )

                coneP25Line := polyline.new(
                     p25Points,
                     curved=false,
                     closed=false,
                     xloc=xloc.bar_time,
                     line_color=color.new(innerBorderColor, 10),
                     line_style=line.style_solid,
                     line_width=1
                )

                coneMedianLine := polyline.new(
                     p50Points,
                     curved=false,
                     closed=false,
                     xloc=xloc.bar_time,
                     line_color=medianColor,
                     line_style=line.style_solid,
                     line_width=2
                )

                coneP75Line := polyline.new(
                     p75Points,
                     curved=false,
                     closed=false,
                     xloc=xloc.bar_time,
                     line_color=color.new(innerBorderColor, 10),
                     line_style=line.style_solid,
                     line_width=1
                )

                coneP90Line := polyline.new(
                     p90Points,
                     curved=false,
                     closed=false,
                     xloc=xloc.bar_time,
                     line_color=color.new(outerBorderColor, 10),
                     line_style=line.style_solid,
                     line_width=1
                )

                coneMaxUpRail := polyline.new(
                     maxUpPoints,
                     curved=false,
                     closed=false,
                     xloc=xloc.bar_time,
                     line_color=railColor,
                     line_style=line.style_dashed,
                     line_width=1
                )

                coneMaxDownRail := polyline.new(
                     maxDownPoints,
                     curved=false,
                     closed=false,
                     xloc=xloc.bar_time,
                     line_color=railColor,
                     line_style=line.style_dashed,
                     line_width=1
                )

        // #10: single grouped commit of the entire cone cache snapshot.
        coneCache := ConeCache.new(
             updateBucket = currentConeUpdateBucket,
             intervalId = currentIntervalId,
             historySize = activeConeHistorySize,
             timeRemainingRounded = timeRemainingRounded,
             targetPrice = currentTargetPrice,
             sma = sma60,
             vol = volume,
             settlementPhaseSeconds = currentSettlementPhaseSeconds,
             lambda = recencyLambda,
             sigma = volumeSigma,
             settlementPhaseMode = settlementPhaseWeightingMode,
             settlementPhaseSigmaSeconds = settlementPhaseSigmaSeconds,
             maxIterations = coneMaxIterations,
             stepSeconds = coneStepSeconds,
             show = showProbabilityCone
         )

// ============================================================================
// CORE MODEL — DISPLAY HISTORICAL TABLE WITH CONFIDENCE AND DIAGNOSTICS
// ============================================================================
var table historicalTable = na
tablePosition = f_getTablePosition(historicalTablePositionInput)

if showHistoricalTable
    if na(historicalTable)
        historicalTable := table.new(tablePosition, 2, 15, border_width=1)

    if runHeavyUpdate
        color headerBg = color.new(color.gray, 30)
        table.cell(historicalTable, 0, 0, "Metric", bgcolor=headerBg, text_color=color.white)
        table.cell(historicalTable, 1, 0, "Value", bgcolor=headerBg, text_color=color.white)

        string statusText = dataReady and not na(currentTargetPrice) ? "Ready" : "Collecting data..."
        color statusBg = dataReady and not na(currentTargetPrice) ? color.new(color.green, 60) : color.new(color.yellow, 60)

        string timeText = f_formatTimeWindow(timeRemainingRounded)

        color distColor = currentPercentDistance > 0 ? color.green : color.red
        string distText = not na(currentTargetPrice) ? str.tostring(currentPercentDistance, "0.0000") + "%" : "n/a"

        string probAboveText = dataReady ? str.tostring(probabilityAboveHistorical, "#.#") + "%" : "n/a"
        color probAboveBg = dataReady ? (probabilityAboveHistorical > 50 ? color.new(color.green, 50) : color.new(color.red, 50)) : color.new(color.gray, 80)

        string probBelowText = dataReady ? str.tostring(probabilityBelowHistorical, "#.#") + "%" : "n/a"
        color probBelowBg = dataReady ? (probabilityBelowHistorical > 50 ? color.new(color.red, 50) : color.new(color.green, 50)) : color.new(color.gray, 80)

        string maxUpText = not na(maxPositiveChange) ? str.tostring(maxPositiveChange, "#.##") + "%" : "n/a"
        string maxDownText = not na(maxNegativeChange) ? str.tostring(maxNegativeChange, "#.##") + "%" : "n/a"

        string lambdaText = str.tostring(recencyLambda, "#.####")
        color lambdaColor = recencyLambda == 0 ? color.gray : color.new(color.blue, 50)

        string sigmaText = str.tostring(volumeSigma, "#.#") + "%"
        color sigmaColor = volumeSigma >= 100 ? color.gray : color.new(color.purple, 50)

        string rawWindowsText = str.tostring(rawWindowsAnalyzed)
        string effSamplesText = str.tostring(effectiveSampleSize, "#.#")

        int activeHistorySizeForDisplay = array.size(activeSmaArray)
        float approxHours = (activeHistorySizeForDisplay * historicalSampleRate) / 3600.0
        string hoursText = str.tostring(approxHours, "#.#")

        table.cell(historicalTable, 0, 1, "Status", text_color=color.white)
        table.cell(historicalTable, 1, 1, statusText, text_color=color.white, bgcolor=statusBg)

        table.cell(historicalTable, 0, 2, "Confidence", text_color=color.white)
        table.cell(historicalTable, 1, 2, confidenceLevel, text_color=color.white, bgcolor=confidenceColor)

        table.cell(historicalTable, 0, 3, "Feed", text_color=color.white)
        table.cell(historicalTable, 1, 3, feedStatusText, text_color=color.white, bgcolor=feedStatusColor)

        table.cell(historicalTable, 0, 4, "Time Window", text_color=color.white)
        table.cell(historicalTable, 1, 4, timeText, text_color=color.white)

        table.cell(historicalTable, 0, 5, "Current Dist", text_color=color.white)
        table.cell(historicalTable, 1, 5, distText, text_color=distColor)

        table.cell(historicalTable, 0, 6, "Prob Above", text_color=color.white)
        table.cell(historicalTable, 1, 6, probAboveText, text_color=color.white, bgcolor=probAboveBg)

        table.cell(historicalTable, 0, 7, "Prob Below", text_color=color.white)
        table.cell(historicalTable, 1, 7, probBelowText, text_color=color.white, bgcolor=probBelowBg)

        table.cell(historicalTable, 0, 8, "Max Up", text_color=color.white)
        table.cell(historicalTable, 1, 8, maxUpText, text_color=color.green)

        table.cell(historicalTable, 0, 9, "Max Down", text_color=color.white)
        table.cell(historicalTable, 1, 9, maxDownText, text_color=color.red)

        table.cell(historicalTable, 0, 10, "Recency λ", text_color=color.white)
        table.cell(historicalTable, 1, 10, lambdaText, text_color=color.white, bgcolor=lambdaColor)

        table.cell(historicalTable, 0, 11, "Volume σ", text_color=color.white)
        table.cell(historicalTable, 1, 11, sigmaText, text_color=color.white, bgcolor=sigmaColor)

        table.cell(historicalTable, 0, 12, "Raw Windows", text_color=color.white)
        table.cell(historicalTable, 1, 12, rawWindowsText, text_color=color.white)

        table.cell(historicalTable, 0, 13, "Eff. Samples", text_color=color.white)
        table.cell(historicalTable, 1, 13, effSamplesText, text_color=color.white)

        table.cell(historicalTable, 0, 14, "Data Hours", text_color=color.white)
        table.cell(historicalTable, 1, 14, hoursText, text_color=color.white)

// ============================================================================
// CORE MODEL — PLOTS
// ============================================================================
plot(sma60, color=color.new(color.gray, 70), linewidth=1, title="60-Period SMA")

// ============================================================================
// VERSION NOTES
// ============================================================================
// Version 0.7.4 - FEED GAP TIMEFRAME DERIVATION + INTERPOLATED CONE PERCENTILES
// Timestamp: 06-14-26 XX:XX:XX ET
//
// ---- CHANGE #1: FEED GAP EXPECTATION DERIVED FROM CHART TIMEFRAME ----
//
// PROBLEM:
//   The feed-integrity check hardcoded a 1-second expected bar gap:
//     expectedBarGapMs = 1000
//   That was correct on the intended 1-second chart, but it made the Feed row
//   show false gaps if the indicator was accidentally placed on a 5s, 15s, or
//   other time-based chart.
//
// SOLUTION:
//   expectedBarGapMs now derives from the active chart timeframe:
//     timeframeSeconds = timeframe.in_seconds()
//     expectedBarGapMs = timeframeSeconds * 1000
//   The gap tolerance is now proportional:
//     gapToleranceMs = expectedBarGapMs * 0.25
//
// EFFECT / SCOPE:
//   - On a 1-second chart, timeframe.in_seconds() is 1, so expectedBarGapMs is
//     1000 and gapToleranceMs is 250: identical to v0.7.3.
//   - On other time-based charts, the Feed row degrades gracefully instead of
//     flagging every normal bar as a gap.
//   - On non-time-based charts where timeframe.in_seconds() is unavailable, the
//     guard falls back to the original 1-second expectation.
//
// ---- CHANGE #2: CONE PERCENTILES USE LINEAR INTERPOLATION ----
//
// PROBLEM:
//   Cone percentiles were weighted step functions: each percentile snapped to
//   the first sorted projected price whose cumulative weight crossed the target.
//   At low effective sample size, that can make cone bands visibly jump between
//   refreshes.
//
// SOLUTION:
//   Added f_weightedInterpolatedPercentile(), which linearly interpolates
//   between the previous sorted rank and the crossing rank:
//     frac = (target - prevCumulative) / (cumulativeWeight - prevCumulative)
//     pX   = prevValue + frac * (value - prevValue)
//
// EFFECT / SCOPE:
//   - Cone p10 / p25 / p50 / p75 / p90 are smoother and less stair-stepped.
//   - Prob Above / Prob Below are unchanged because they come from the separate
//     weighted-fraction scan.
//   - Max Up / Max Down rails are unchanged and remain exact observed extremes.
//   - Percentiles remain monotonic and bounded inside the rails.
//
// FUNCTIONS ADDED:
//   f_weightedInterpolatedPercentile
//
// KEPT: All user inputs unchanged.
// KEPT: Table layout unchanged.
// KEPT: Unified interval clock from v0.7.3.
// KEPT: Typed cache state from v0.7.2.
// KEPT: Unified scan/weight path from v0.7.1.
//
// ============================================================================
// Version 0.7.3 - UNIFIED INTERVAL CLOCK (folds prior suggestion #1)
// Timestamp: 06-14-26 XX:XX:XX ET
//
// This release points the settlement countdown at the same UTC epoch basis the
// interval boundary already used, eliminating a latent two-clock dependency.
//
// ---- #1: SETTLEMENT COUNTDOWN DERIVED FROM THE EPOCH, NOT minute()/second() ----
//
// PROBLEM:
//   currentIntervalId / crossedIntervalBoundary bucket on the raw UTC epoch:
//     currentIntervalId = floor(time / intervalMs)
//   But the old calcTimeRemaining() read minute(time) / second(time), which
//   resolve in the chart's EXCHANGE timezone.  On any exchange timezone offset
//   from UTC by a non-whole-hour amount (e.g. UTC+5:30, UTC+5:45, UTC-3:30) the
//   two clocks disagree about where a quarter-hour boundary falls, so the
//   countdown that drives windowSizeInSamples could be offset from the boundary
//   that actually sets currentTargetPrice.
//
// SOLUTION:
//   The countdown now uses pure epoch arithmetic against intervalMs:
//     msIntoInterval = time % intervalMs
//     timeRemaining  = int((intervalMs - msIntoInterval) / 1000)
//   The calcTimeRemaining() function and its minute()/second() calls are gone.
//   Every time bucket in the script (interval id, sample bucket, update bucket,
//   cone update bucket, settlement countdown) now derives from one clock.
//
// EFFECT / SCOPE:
//   - UTC-quoted feeds and any whole-hour-offset exchange timezone (which
//     includes the quarter-hour ET/UTC settlement Kalshi uses, and essentially
//     all crypto venues on TradingView): numerically IDENTICAL output to v0.7.2.
//     This is a no-op on those charts that simply removes the footgun.
//   - Exotic half/quarter-hour-offset exchange timezones: the countdown now
//     correctly tracks the actual interval boundary instead of a misaligned
//     exchange-tz clock.  This is the only situation where any displayed value
//     changes, and the change is a correction.
//
// PRECISION NOTE:
//   On a 1-second feed `time` is whole-second aligned, so msIntoInterval is
//   always a whole number of seconds and the int() truncation is exact —
//   timeRemaining matches the old integer-seconds result bit for bit on
//   whole-hour-offset charts.
//
// ---- FUNCTIONS REMOVED ----
//   calcTimeRemaining   (replaced by inline epoch arithmetic)
//
// KEPT: All user inputs unchanged.
// KEPT: All display logic, table layout, and visual outputs unchanged.
// KEPT: timeRemainingRounded (5s snap) and currentSettlementPhaseSeconds
//       definitions unchanged — only their upstream source changed.
// KEPT: Typed cache state (ScanCache / ConeCache) from v0.7.2.
// KEPT: Unified scan/weight path from v0.7.1 (f_computeWeights,
//       f_scanHistoricalWindows, shared sharedWeights for scan + cone).
// KEPT: Settlement Phase Weighting overlay dormancy when Off.
// KEPT: Prior version notes preserved below per Build-stage rules.
//
// ============================================================================
// Version 0.7.2 - TYPED CACHE STATE (folds #10)
// Timestamp: 06-14-26 XX:XX:XX ET
//
// Bundled the heavy-update and cone cache fields into user-defined types
// (ScanCache, ConeCache).  Single `var` instances replace ~28 loose `var`
// cache fields; staleness checks read named fields and each commit is a single
// constructor assignment.  Numeric/string fields default to na / ""; the lone
// bool field defaults to false (no bool-na).  Behavior identical to v0.7.1.
//
// ============================================================================
// Version 0.7.1 - UNIFIED SCAN/WEIGHT PATH (folds #6, #7, #8)
// Timestamp: 06-14-26 XX:XX:XX ET
//
// #6: volumeSigmaAbsolute hoisted out of the scan loop into f_computeWeights.
// #7: One sharedWeights array built per refresh bar, consumed by BOTH the scan
//     and the cone (replacing the former double weight build).  Recency uses an
//     array-position basis that differs from the old per-window basis only by a
//     uniform constant, which cancels in all ratio/fraction outputs.
// #8: f_scanHistoricalWindowsCore + f_scanHistoricalWindowsWeighted replaced by
//     one f_scanHistoricalWindows consuming shared weights.
//
// CONSISTENCY: unified scan and cone process only windows where smaStart != 0
// AND combinedWeight > 0; cone rails scoped to that same set; cone percentile
// na-fallbacks made direction-correct (low -> min, high -> max).
// FUNCTIONS ADDED: f_computeWeights, f_scanHistoricalWindows.
// FUNCTIONS REMOVED: f_scanHistoricalWindowsCore, f_scanHistoricalWindowsWeighted.
//
// ============================================================================
// Version 0.7.0 - ALGORITHMIC EFFICIENCY: MERGED EXTREMES, PRECOMPUTED CONE WEIGHTS
// Timestamp: 03-18-26 XX:XX:XX PM ET
//
// CHANGE 1: Merged max-positive/max-negative extremes tracking into the main
//   historical scan, removing the standalone f_scanWindowExtremes pass.
// CHANGE 2: Extremes inherited the scan's startIndex / maxIterations window.
// CHANGE 3: Cone weights precomputed once per cone refresh instead of per
//   horizon (now shared with the scan in v0.7.1+).
// FUNCTIONS REMOVED IN 0.7.0: f_scanWindowExtremes,
//   f_calcConePercentilesAndRailsCore, f_calcConePercentilesAndRailsWeighted.
//
// ============================================================================
// Version 0.6.3 - STRICTER OFF-MODE DORMANCY
// Timestamp: 03-17-26 11:58:24 PM ET
//
// CHANGED: Settlement Phase Weighting overlay history fully dormant when Off.
// CHANGED: Core and overlay historical datasets physically separated.
// CHANGED: Active history size and displayed data hours follow the active mode.
// KEPT: Off + Weighted only; time-to-settlement remains the model backbone.
//
// ============================================================================
// Version 0.6.2 - CORRECTED BUILD REGENERATION
// Timestamp: 03-17-26 11:37:26 PM ET
//
// CHANGED: Core and overlay scan logic split into separate functions.
// CHANGED: Removed the bool/na cache trap from the build path.
// KEPT: Settlement Phase Weighting optional overlay (Off / Weighted).
//
// ============================================================================
// Version 0.6.1 - SETTLEMENT PHASE WEIGHTING REFACTOR
//
// CHANGED: Renamed "Phase Matching" to "Settlement Phase Weighting".
// CHANGED: Removed Strict mode (Off / Weighted only); split mode from enabled.
// CHANGED: Settlement Phase Weighting treated as an optional overlay.
// KEPT: Max Up / Max Down remain horizon extremes.
//
// ============================================================================
// Version 0.6.0 - OPTIONAL PHASE MATCHING
//
// NEW: Optional quarter-hour phase matching; Weighted Gaussian phase weighting.
// KEPT: Baseline behavior when phase matching is Off.
//
// From v0.5.x:
// - Added Max Up / Max Down rails to the cone
// - Cone horizons advance in 15-second increments on a 15-second cadence
// - Heavy updates and cone redraws wait for bar confirmation
// - Table position user-selectable with Bottom Left default
// - barstate.islast gating for heavy work; separate coneMaxIterations input
````
