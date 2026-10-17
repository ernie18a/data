# Probabilistic Projection

- url: https://www.tradingview.com/script/aMgiiI4s-Probabilistic-Projection/
- type: indicator
- pine_id: PUB;d370225dedbe4de2bc01399263dca164
- version: 4.0

## Description

Most projection tools extend the recent trend or calculate a single average return. Probabilistic Projection uses a more comprehensive approach: it examines the full range of returns that followed comparable historical conditions.

The method can be understood through one question:

When this market had a similar trend and level of volatility in the past, what happened over the following 6 months, 1 year or 2 years?

The indicator collects these historical forward returns, builds a complete probability distribution, and displays:

• The median historical outcome
• A configurable central range of outcomes
• The quality of the available sample

Similar historical conditions receive additional weight, but they are never allowed to dominate the model. At least 65% of the calculation always comes from the complete historical distribution.

This balance is important. Using only a few similar periods can produce unstable conclusions, while using only a long-term average ignores the current market environment. Probabilistic Projection combines both sources of information while automatically reducing the influence of unreliable samples.

WHY THIS APPROACH IS ROBUST

The model is designed to reduce several common sources of error:

• It evaluates a distribution of outcomes instead of producing one deterministic target.
• It uses confirmed daily data rather than incomplete higher-timeframe values.
• It remains independent of the chart timeframe.
• It limits the influence of trend and volatility conditioning.
• It gives less weight to conditional information when the sample is insufficient.
• It pulls unstable estimates back toward the global historical median.
• It widens the projection range when data quality is lower.
• It distinguishes sample quality from prediction accuracy.
• It uses standard market prices, including on non-standard charts.

A one-year projection therefore remains approximately one year whether the indicator is viewed on a 5-minute, daily or weekly chart.

HOW THE DISTRIBUTION IS BUILT

Three projection horizons are available:

• 6 months: 126 trading days
• 1 year: 252 trading days
• 2 years: 504 trading days

For each monthly projection step, the script measures what the market actually returned over the same forward horizon at different points in its history.

Historical sample endpoints are separated by approximately 21 trading days. The script can use up to 225 observations at each step, depending on the available history.

The final distribution combines three components:

1. Complete historical distribution

Every valid observation contributes to the baseline. This ensures that the model retains information from different market environments, including periods that do not resemble the current one.

2. Trend context

The latest confirmed daily close is compared with a 202-day simple moving average.

Historical observations that began in the same broad trend state can receive additional weight. Trend conditioning cannot contribute more than 12% of the total calculation.

3. Volatility context

The model calculates realized volatility from 21-day daily returns and ranks it over approximately three years.

Historical periods with a similar volatility rank can also receive additional weight. Volatility conditioning cannot contribute more than 28%.

The combined conditional contribution is capped at 35%. The complete historical distribution always retains at least 65% of the total weight.

If too few comparable observations are available, the corresponding trend or volatility weight is automatically reduced or disabled.

READING THE PROJECTION

Solid central line

The solid line represents the median of the reliability-adjusted distribution.

Because expected returns are less stable than return dispersion, the conditioned median is partially pulled back toward the global historical median. This limits the influence of temporary or poorly represented market conditions.

Dashed boundaries

The dashed lines represent a configurable central range:

• 60%: P20 to P80
• 70%: P15 to P85 (default)
• 80%: P10 to P90

The 60% setting focuses on more central outcomes. The 80% setting includes a broader range of historical scenarios.

When data quality is lower, the distance between the median and the boundaries is expanded. The projection becomes more cautious rather than displaying the same apparent precision with a weaker sample.

Shaded range

The optional shaded area makes the distribution easier to read. It represents a percentile-derived range of historical scenarios, not a confidence interval or guaranteed future coverage.

Each point is calculated from the return distribution corresponding to its own horizon. The connected lines help visualize how the median and dispersion evolve over time; they are not individual simulated market paths.

INFORMATION PANEL

Annualized median projection

The median return at the selected terminal horizon is converted into an annualized percentage. This makes the six-month, one-year and two-year projections easier to compare.

It describes the center of the modeled historical distribution. It is not an expected return or a performance promise.

Data quality

The data-quality score evaluates whether enough historical information is available. It considers:

• The number of valid observations
• The overlap between long-horizon observations
• An estimate of the effective independent sample size
• The minimum sample required to display the projection

This score measures the strength of the historical sample, not the probability that the projection will be correct.

CONFIRMED DATA AND LIVE PRICES

The statistical model uses completed daily observations. The optional regime channel also uses confirmed source-timeframe values.

The projected returns are rescaled to the live standard-market close. The displayed price levels can therefore move while the current chart bar is open, but the underlying historical distribution remains based on confirmed data.

On Heikin Ashi and other non-standard charts, the model uses the standard instrument rather than synthetic candle prices.

OPTIONAL REGIME CHANNEL

The optional regime channel provides separate higher-timeframe context and does not alter the probabilistic projection.

It evaluates:

• Price relative to fast and slow moving averages
• Momentum
• Direction of the slow moving average
• Percentage distance from the slow average
• ATR-based expansion

Its boundaries use the larger of a minimum percentage distance or an ATR-based distance. Optional smoothing changes only the visual transition between confirmed levels.

INTENDED USE

Probabilistic Projection is designed primarily for medium- and long-term analysis of broad equity indices.

It can help users:

• See the range of outcomes that historically followed comparable conditions
• Compare potential upside and downside asymmetry
• Understand how uncertainty expands with the projection horizon
• Identify when the historical evidence is limited
• Add a statistical framework to portfolio and risk decisions

No historical method can know the future. Market distributions change, long-horizon samples overlap, and unprecedented events cannot be represented.

Probabilistic Projection is a descriptive probability model, not a price target, trading signal or standalone trading system.

## Source Code

````pine
// @Julien_Exe
//@version=6

indicator(
    "Probabilistic Projection",
    overlay = true,
    max_bars_back = 5000,
    max_polylines_count = 3)

// Empirical probabilistic context tool for broad equity indices and index-like instruments.
// It models close-to-close PRICE returns. Use a total-return symbol when total returns are required.
// It is not a trading signal, an 80% pathwise corridor, or a performance promise.
//
// Main V4 changes:
// 1) Historical calibration forecasts use the conditioning guard that was available at their own origin.
// 2) Conditioning losses are profiled on current and historical-origin phases, then reused for nested gates.
// 3) The unconditional empirical benchmark receives direct ordered prequential calibration diagnostics.
// 4) Calibration corrections remain positive-skill-only and use historically reconstructed model states.
// 5) Minimum raw and temporal-block effective evidence thresholds are stricter for tail estimation.
// 6) Evidence is reported as a diagnostic score out of 100, never as a probability percentage.
// 7) Missing benchmark validation is capped below the "Good" classification.
// 8) Data adequacy, benchmark calibration and validated enhancement skill are reported separately.

// === Inputs
string horizonPreset = input.string(
    "1 year", "Projection horizon",
    options = ["6 months", "1 year", "2 years"],
    group = "Projection")

bool useConditioning = input.bool(
    true, "Mild trend/volatility conditioning",
    tooltip = "Keeps most probability mass on the global empirical distribution. Disable for the unconditional benchmark.",
    group = "Projection")

bool adaptiveConditioning = input.bool(
    true, "Horizon-specific conditioning guard",
    tooltip = "Activates conditioning only to the extent that completed horizon-specific forecasts show positive probabilistic skill versus the unconditional benchmark. Historical calibration origins reconstruct the guard available at that date.",
    group = "Projection")

bool useCalibration = input.bool(
    true, "Validated asymmetric calibration",
    tooltip = "Fits median and lower/upper corrections on completed forecasts reconstructed with historical conditioning guards, then applies them only when newer forecasts validated with older errors show positive probabilistic skill.",
    group = "Projection")

string anchorModeInput = input.string(
    "Live price", "Projection anchor",
    options = ["Confirmed close", "Live price"],
    tooltip = "Live price changes only the visual anchor intrabar. The return distribution and evidence scores remain frozen until the bar closes.",
    group = "Projection")

color projectionColor = input.color(
    color.rgb(48, 137, 255), "Projection color",
    group = "Display")

int deviationTransparency = input.int(
    35, "Deviation line transparency",
    minval = 0, maxval = 100,
    group = "Display")

string tableModeInput = input.string(
    "Simple", "Table mode",
    options = ["Simple", "Detailed", "Off"],
    tooltip = "Simple shows the median annualized price return and the overall evidence score. The score is a bounded diagnostic out of 100, not a probability of success.",
    group = "Table")

string tablePositionInput = input.string(
    "Bottom Right", "Table position",
    options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
    group = "Table")

string textSizeInput = input.string(
    "Normal", "Table text size",
    options = ["Tiny", "Small", "Normal"],
    group = "Table")

// === Frozen research constants
const int HARD_MAX_BARS_BACK = 4999
const int HARD_MAX_PROJECTION_BARS = 500
const int MAX_RAW_SAMPLES = 210
const int MIN_RAW_SAMPLES = 80
const float MIN_WEIGHTED_EFFECTIVE_SAMPLES = 6.0
const int ABSOLUTE_MAX_RESEARCH_ERRORS = 20
const int MIN_CALIBRATION_ERRORS = 8
const int MIN_CALIBRATION_VALIDATION_ERRORS = 3
const int MIN_CONDITIONING_SKILL_ERRORS = 4
const int MIN_BENCHMARK_VALIDATION_ERRORS = 4
const int BLOCK_PHASE_COUNT = 3

const float TARGET_INTERVAL_COVERAGE = 0.80
const float TARGET_ONE_SIDED_COVERAGE = 0.90
const float CALIBRATION_ORIGIN_FRACTION = 0.50
const float CALIBRATION_PRIOR_STRENGTH = 8.0
const float CALIBRATION_VALIDATION_SKILL_PRIOR = 3.0
const float CALIBRATION_COVERAGE_PRIOR = 4.0
const float BENCHMARK_COVERAGE_PRIOR = 4.0
const float BENCHMARK_ERROR_PRIOR = 2.0
const float CALIBRATION_FULL_POSITIVE_SKILL = 0.08
const float MIN_SCALE_CORRECTION = 0.65
const float MAX_SCALE_CORRECTION = 1.75
const float MAX_CENTER_SHIFT_AS_SPAN = 0.35

const float MAX_TREND_MASS = 0.08
const float MAX_VOLATILITY_MASS = 0.17
const float MAX_CONDITIONAL_MASS = 0.22
const float VOLATILITY_RANK_TOLERANCE = 0.25
const float CONDITIONING_SKILL_PRIOR_STRENGTH = 4.0
const float CONDITIONING_FULL_POSITIVE_SKILL = 0.06

const float RELIABILITY_EFFECTIVE_MIN = 4.0
const float RELIABILITY_EFFECTIVE_FULL = 14.0
const float CONDITIONING_VALIDATION_EFFECTIVE_MIN = 1.5
const float CONDITIONING_VALIDATION_EFFECTIVE_FULL = 7.0
const float CALIBRATION_VALIDATION_EFFECTIVE_MIN = 1.5
const float CALIBRATION_VALIDATION_EFFECTIVE_FULL = 6.0
const float BENCHMARK_VALIDATION_EFFECTIVE_MIN = 2.0
const float BENCHMARK_VALIDATION_EFFECTIVE_FULL = 8.0

const float DATA_EFFECTIVE_FULL = 18.0
const float EVIDENCE_WEAK_EFFECTIVE = 8.0
const float EVIDENCE_MODERATE_EFFECTIVE = 14.0
const float EVIDENCE_WEAK_CAP = 0.55
const float EVIDENCE_MODERATE_CAP = 0.75
const float OVERALL_NO_BENCHMARK_VALIDATION_CAP = 0.69
const float SCORE_FLOOR = 0.05
const float EPSILON = 0.0000000001

// === Supported calendar mapping
bool supportedTimeframe =
     timeframe.multiplier == 1 and
     (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
bool supportedChartType = chart.is_standard
bool supportedContext = supportedTimeframe and supportedChartType

int monthsInHorizon =
     horizonPreset == "6 months" ? 6 :
     horizonPreset == "2 years" ? 24 : 12

int projectionHorizon =
     timeframe.isdaily ? (monthsInHorizon == 6 ? 126 : monthsInHorizon == 24 ? 500 : 252) :
     timeframe.isweekly ? (monthsInHorizon == 6 ? 26 : monthsInHorizon == 24 ? 104 : 52) :
     monthsInHorizon

projectionHorizon := math.min(projectionHorizon, HARD_MAX_PROJECTION_BARS)

int monthlyStride = timeframe.isdaily ? 21 : timeframe.isweekly ? 4 : 1
float barsPerYear = timeframe.isdaily ? 252.0 : timeframe.isweekly ? 52.0 : 12.0
int trendLength = timeframe.isdaily ? 210 : timeframe.isweekly ? 40 : 10
int volatilityLength = timeframe.isdaily ? 21 : timeframe.isweekly ? 4 : 3
int volatilityRankLength = timeframe.isdaily ? 1260 : timeframe.isweekly ? 260 : 60

float oneBarLogReturn =
     not na(close[1]) and close > 0.0 and close[1] > 0.0 ? math.log(close / close[1]) : na
float trendAverage = ta.sma(close, trendLength)
float realizedVolatility = ta.stdev(oneBarLogReturn, volatilityLength)
float volatilityRank = ta.percentrank(realizedVolatility, volatilityRankLength) / 100.0

// === Generic helpers
f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_clamp01(float value) =>
    f_clamp(value, 0.0, 1.0)

f_linear_reliability(float effectiveCount, float minimum, float full) =>
    full <= minimum ? (effectiveCount >= full ? 1.0 : 0.0) :
     f_clamp01((effectiveCount - minimum) / (full - minimum))

f_log_return(float startPrice, float endPrice) =>
    not na(startPrice) and not na(endPrice) and startPrice > 0.0 and endPrice > 0.0 ?
         math.log(endPrice / startPrice) : na

f_price_from_log_return(float anchor, float logReturn) =>
    not na(anchor) and not na(logReturn) and anchor > 0.0 ?
         anchor * math.exp(f_clamp(logReturn, -20.0, 20.0)) : na

f_annualized_percent(float logReturn, int horizon) =>
    not na(logReturn) and horizon > 0 ?
         100.0 * (math.exp(f_clamp(logReturn * barsPerYear / float(horizon), -20.0, 20.0)) - 1.0) : na

f_total_percent(float logReturn) =>
    not na(logReturn) ? 100.0 * (math.exp(f_clamp(logReturn, -20.0, 20.0)) - 1.0) : na

f_signed_percent(float value) =>
    na(value) ? "N/A" : (value > 0.0 ? "+" : "") + str.tostring(value, "#.##") + "%"

f_number(float value, string formatString) =>
    na(value) ? "N/A" : str.tostring(value, formatString)

f_table_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_table_size(string value) =>
    value == "Tiny" ? size.tiny : value == "Normal" ? size.normal : size.small

f_quality_label(float value) =>
    na(value) ? "N/A" :
     value < 0.40 ? "Very low" :
     value < 0.55 ? "Low" :
     value < 0.70 ? "Moderate" :
     value < 0.85 ? "Good" : "Strong"

f_quality_text(float value) =>
    na(value) ? "N/A" : str.tostring(100.0 * value, "#") + "/100 · " + f_quality_label(value)

f_quality_color(float value) =>
    na(value) ? color.silver :
     value < 0.40 ? color.rgb(242, 100, 100) :
     value < 0.55 ? color.orange :
     value < 0.70 ? color.rgb(226, 190, 85) : color.rgb(71, 207, 137)

f_percentile_sorted(array<float> values, float probability) =>
    int count = array.size(values)
    float result = na
    if count == 1
        result := array.get(values, 0)
    else if count > 1
        float rank = f_clamp01(probability) * (count - 1)
        int lowerIndex = int(math.floor(rank))
        int upperIndex = int(math.ceil(rank))
        float fraction = rank - lowerIndex
        float lowerValue = array.get(values, lowerIndex)
        float upperValue = array.get(values, upperIndex)
        result := lowerValue + fraction * (upperValue - lowerValue)
    result

f_sum_positive(array<float> values) =>
    float total = 0.0
    int count = array.size(values)
    if count > 0
        for index = 0 to count - 1
            total += math.max(array.get(values, index), 0.0)
    total

f_kish_count(array<float> weights, float totalWeight) =>
    float squareTotal = 0.0
    int count = array.size(weights)
    if count > 0
        for index = 0 to count - 1
            float weight = math.max(array.get(weights, index), 0.0)
            squareTotal += weight * weight
    totalWeight > 0.0 and squareTotal > 0.0 ? totalWeight * totalWeight / squareTotal : 0.0

f_weighted_quantile_triplet(
    array<float> values,
    array<float> weights,
    array<int> sortedIndices,
    float totalWeight) =>
    int count = array.size(values)
    float q10 = na
    float q50 = na
    float q90 = na
    if count > 0 and array.size(weights) == count and array.size(sortedIndices) == count and totalWeight > 0.0
        float target10 = 0.10 * totalWeight
        float target50 = 0.50 * totalWeight
        float target90 = 0.90 * totalWeight
        float cumulative = 0.0
        for sortedPosition = 0 to count - 1
            int sourceIndex = array.get(sortedIndices, sortedPosition)
            cumulative += math.max(array.get(weights, sourceIndex), 0.0)
            if na(q10) and cumulative >= target10
                q10 := array.get(values, sourceIndex)
            if na(q50) and cumulative >= target50
                q50 := array.get(values, sourceIndex)
            if cumulative >= target90
                q90 := array.get(values, sourceIndex)
                break
        if na(q10)
            q10 := array.get(values, array.get(sortedIndices, count - 1))
        if na(q50)
            q50 := array.get(values, array.get(sortedIndices, count - 1))
        if na(q90)
            q90 := array.get(values, array.get(sortedIndices, count - 1))
    [q10, q50, q90]

f_effective_samples(float count, int stride, int horizon) =>
    horizon <= 0 ? 0.0 : count * math.min(1.0, float(stride) / float(horizon))

// Aggregates sample weights into horizon-sized temporal blocks. Multiple phase alignments
// reduce sensitivity to the arbitrary position of block boundaries. The minimum is retained.
f_block_effective_count(array<float> weights, int stride, int horizon) =>
    int count = array.size(weights)
    float totalWeight = f_sum_positive(weights)
    float sampleKish = f_kish_count(weights, totalWeight)
    float result = 0.0
    if count > 0 and totalWeight > 0.0 and horizon > 0 and stride > 0
        int blockSize = math.max(1, int(math.ceil(float(horizon) / float(stride))))
        if blockSize == 1
            result := sampleKish
        else
            int phaseCount = math.min(BLOCK_PHASE_COUNT, blockSize)
            float minimumBlockKish = na
            for phaseIndex = 0 to phaseCount - 1
                int phase = phaseCount == 1 ? 0 :
                     int(math.round(float(phaseIndex) * float(blockSize - 1) / float(phaseCount - 1)))
                int blockCount = int(math.floor(float(count - 1 + phase) / float(blockSize))) + 1
                array<float> blockWeights = array.new_float(blockCount, 0.0)
                for sampleIndex = 0 to count - 1
                    int blockIndex = int(math.floor(float(sampleIndex + phase) / float(blockSize)))
                    float updatedWeight = array.get(blockWeights, blockIndex) + math.max(array.get(weights, sampleIndex), 0.0)
                    array.set(blockWeights, blockIndex, updatedWeight)
                float blockTotal = f_sum_positive(blockWeights)
                float blockKish = f_kish_count(blockWeights, blockTotal)
                minimumBlockKish := na(minimumBlockKish) ? blockKish : math.min(minimumBlockKish, blockKish)
            float overlapCap = f_effective_samples(float(count), stride, horizon)
            result := math.min(sampleKish, math.min(overlapCap, nz(minimumBlockKish, 0.0)))
    result

f_positioned_effective_count(
    array<int> samplePositions,
    int startIndex,
    int sampleCount,
    int stride,
    int horizon) =>
    float result = 0.0
    int positionCount = array.size(samplePositions)
    if sampleCount > 0 and startIndex >= 0 and startIndex + sampleCount <= positionCount
        int maximumPosition = 0
        for subsetIndex = 0 to sampleCount - 1
            maximumPosition := math.max(
                maximumPosition,
                array.get(samplePositions, startIndex + subsetIndex))
        array<float> positionedWeights = array.new_float(maximumPosition + 1, 0.0)
        for subsetIndex = 0 to sampleCount - 1
            int samplePosition = array.get(samplePositions, startIndex + subsetIndex)
            array.set(positionedWeights, samplePosition, 1.0)
        result := f_block_effective_count(positionedWeights, stride, horizon)
    result

f_reliability(float effectiveCount) =>
    f_linear_reliability(effectiveCount, RELIABILITY_EFFECTIVE_MIN, RELIABILITY_EFFECTIVE_FULL)

f_pinball_loss(float actual, float quantile, float probability) =>
    if na(actual) or na(quantile)
        na
    else
        float error = actual - quantile
        error >= 0.0 ? probability * error : (probability - 1.0) * error

f_quantile_set_loss(float actual, float q10, float q50, float q90) =>
    float loss10 = f_pinball_loss(actual, q10, 0.10)
    float loss50 = f_pinball_loss(actual, q50, 0.50)
    float loss90 = f_pinball_loss(actual, q90, 0.90)
    not na(loss10) and not na(loss50) and not na(loss90) ?
         (loss10 + loss50 + loss90) / 3.0 : na

f_skill_performance_quality(float shrunkSkill) =>
    na(shrunkSkill) ? na : f_clamp01(0.50 + 5.0 * f_clamp(shrunkSkill, -0.10, 0.10))

f_research_error_limit(int horizon, int stride) =>
    float horizonInMonthlySteps = stride > 0 ? float(horizon) / float(stride) : 24.0
    int result =
         horizonInMonthlySteps <= 3.0 ? 20 :
         horizonInMonthlySteps <= 6.0 ? 18 :
         horizonInMonthlySteps <= 12.0 ? 16 :
         horizonInMonthlySteps <= 18.0 ? 14 : 12
    math.min(result, ABSOLUTE_MAX_RESEARCH_ERRORS)

// Direct ordered prequential calibration diagnostic for the unconditional benchmark.
// Zero weights preserve missing forecast positions when block-effective evidence is measured.
f_benchmark_validation_from_profile(
    array<float> weights,
    array<float> intervalHits,
    array<float> lowerHits,
    array<float> upperHits,
    array<float> normalizedErrors,
    int stride,
    int horizon) =>
    int profileCount = array.size(weights)
    array<float> effectiveWeights = array.new_float()
    array<float> usableNormalizedErrors = array.new_float()
    float totalWeight = 0.0
    float intervalHitTotal = 0.0
    float lowerHitTotal = 0.0
    float upperHitTotal = 0.0
    int validationCount = 0

    if profileCount > 0 and
       array.size(intervalHits) == profileCount and
       array.size(lowerHits) == profileCount and
       array.size(upperHits) == profileCount and
       array.size(normalizedErrors) == profileCount
        for profileIndex = 0 to profileCount - 1
            float sourceWeight = math.max(array.get(weights, profileIndex), 0.0)
            float intervalHit = array.get(intervalHits, profileIndex)
            float lowerHit = array.get(lowerHits, profileIndex)
            float upperHit = array.get(upperHits, profileIndex)
            float normalizedError = array.get(normalizedErrors, profileIndex)
            bool usable =
                 sourceWeight > EPSILON and
                 not na(intervalHit) and not na(lowerHit) and not na(upperHit) and
                 not na(normalizedError)
            float usableWeight = usable ? sourceWeight : 0.0
            array.push(effectiveWeights, usableWeight)
            if usable
                totalWeight += usableWeight
                intervalHitTotal += usableWeight * intervalHit
                lowerHitTotal += usableWeight * lowerHit
                upperHitTotal += usableWeight * upperHit
                array.push(usableNormalizedErrors, math.max(normalizedError, 0.0))
                validationCount += 1

    float validationEffectiveCount = f_block_effective_count(effectiveWeights, stride, horizon)
    float intervalCoverage = na
    float shrunkIntervalCoverage = na
    float lowerCoverage = na
    float upperCoverage = na
    float medianNormalizedError = na
    float benchmarkDiagnostic = na

    if validationCount >= MIN_BENCHMARK_VALIDATION_ERRORS and totalWeight > EPSILON
        intervalCoverage := intervalHitTotal / totalWeight
        lowerCoverage := lowerHitTotal / totalWeight
        upperCoverage := upperHitTotal / totalWeight

        shrunkIntervalCoverage := (
            intervalCoverage * validationEffectiveCount +
            BENCHMARK_COVERAGE_PRIOR * TARGET_INTERVAL_COVERAGE) / (
            validationEffectiveCount + BENCHMARK_COVERAGE_PRIOR)
        float shrunkLowerCoverage = (
            lowerCoverage * validationEffectiveCount +
            BENCHMARK_COVERAGE_PRIOR * TARGET_ONE_SIDED_COVERAGE) / (
            validationEffectiveCount + BENCHMARK_COVERAGE_PRIOR)
        float shrunkUpperCoverage = (
            upperCoverage * validationEffectiveCount +
            BENCHMARK_COVERAGE_PRIOR * TARGET_ONE_SIDED_COVERAGE) / (
            validationEffectiveCount + BENCHMARK_COVERAGE_PRIOR)

        array.sort(usableNormalizedErrors, order.ascending)
        float rawMedianNormalizedError = f_percentile_sorted(usableNormalizedErrors, 0.50)
        medianNormalizedError := (
            rawMedianNormalizedError * validationEffectiveCount +
            BENCHMARK_ERROR_PRIOR) / (
            validationEffectiveCount + BENCHMARK_ERROR_PRIOR)

        float validationReliability = f_linear_reliability(
            validationEffectiveCount,
            BENCHMARK_VALIDATION_EFFECTIVE_MIN,
            BENCHMARK_VALIDATION_EFFECTIVE_FULL)
        float intervalCoverageScore = f_clamp01(
            1.0 - math.abs(shrunkIntervalCoverage - TARGET_INTERVAL_COVERAGE) / 0.25)
        float lowerCoverageScore = f_clamp01(
            1.0 - math.abs(shrunkLowerCoverage - TARGET_ONE_SIDED_COVERAGE) / 0.20)
        float upperCoverageScore = f_clamp01(
            1.0 - math.abs(shrunkUpperCoverage - TARGET_ONE_SIDED_COVERAGE) / 0.20)
        float tailBalanceScore = f_clamp01(
            1.0 - math.abs(shrunkLowerCoverage - shrunkUpperCoverage) / 0.20)
        float medianAccuracyScore = 1.0 / (1.0 + medianNormalizedError)

        benchmarkDiagnostic := f_clamp01(
            validationReliability *
            (0.30 * intervalCoverageScore +
             0.15 * lowerCoverageScore +
             0.15 * upperCoverageScore +
             0.15 * tailBalanceScore +
             0.25 * medianAccuracyScore))

    [validationCount, validationEffectiveCount, intervalCoverage, shrunkIntervalCoverage, lowerCoverage, upperCoverage, medianNormalizedError, benchmarkDiagnostic]

f_history_evidence(int rawCount, float blockEffectiveCount) =>
    float rawCoverage = f_clamp01(float(rawCount) / float(MAX_RAW_SAMPLES))
    float independentCoverage = f_clamp01(blockEffectiveCount / DATA_EFFECTIVE_FULL)
    f_clamp01(0.20 * rawCoverage + 0.80 * independentCoverage)

f_data_adequacy(
    int rawCount,
    float rawOverlapEffectiveCount,
    float weightedBlockEffectiveCount,
    float stabilityScore) =>
    float result = na
    if rawCount >= MIN_RAW_SAMPLES and weightedBlockEffectiveCount >= MIN_WEIGHTED_EFFECTIVE_SAMPLES
        float historyComponent = f_history_evidence(rawCount, weightedBlockEffectiveCount)
        float concentrationComponent =
             rawOverlapEffectiveCount > EPSILON ?
             f_clamp01(weightedBlockEffectiveCount / rawOverlapEffectiveCount) : 0.0
        float stabilityComponent = na(stabilityScore) ? 0.45 : stabilityScore
        float logScore =
             0.60 * math.log(math.max(historyComponent, SCORE_FLOOR)) +
             0.15 * math.log(math.max(concentrationComponent, SCORE_FLOOR)) +
             0.25 * math.log(math.max(stabilityComponent, SCORE_FLOOR))
        result := f_clamp01(math.exp(logScore))
        if weightedBlockEffectiveCount < EVIDENCE_WEAK_EFFECTIVE
            result := math.min(result, EVIDENCE_WEAK_CAP)
        else if weightedBlockEffectiveCount < EVIDENCE_MODERATE_EFFECTIVE
            result := math.min(result, EVIDENCE_MODERATE_CAP)
    result

f_validation_component(float shrunkSkill, float effectiveCount, float effectiveMinimum, float effectiveFull) =>
    float result = na
    if not na(shrunkSkill) and effectiveCount > 0.0
        float reliability = f_linear_reliability(effectiveCount, effectiveMinimum, effectiveFull)
        float performance = f_skill_performance_quality(shrunkSkill)
        result := reliability * performance
    result

f_validated_enhancement(
    float conditioningShrunkSkill,
    float conditioningEffectiveCount,
    float calibrationShrunkSkill,
    float calibrationValidationEffectiveCount,
    bool conditioningActive,
    bool calibrationActive) =>
    float weightedScore = 0.0
    float totalWeight = 0.0
    if conditioningActive
        float conditioningComponent = f_validation_component(
            conditioningShrunkSkill,
            conditioningEffectiveCount,
            CONDITIONING_VALIDATION_EFFECTIVE_MIN,
            CONDITIONING_VALIDATION_EFFECTIVE_FULL)
        if not na(conditioningComponent)
            weightedScore += 0.45 * conditioningComponent
            totalWeight += 0.45
    if calibrationActive
        float calibrationComponent = f_validation_component(
            calibrationShrunkSkill,
            calibrationValidationEffectiveCount,
            CALIBRATION_VALIDATION_EFFECTIVE_MIN,
            CALIBRATION_VALIDATION_EFFECTIVE_FULL)
        if not na(calibrationComponent)
            weightedScore += 0.55 * calibrationComponent
            totalWeight += 0.55
    totalWeight > 0.0 ? f_clamp01(weightedScore / totalWeight) : na

f_overall_evidence(
    float dataAdequacy,
    float benchmarkCalibration,
    float validatedEnhancement,
    float weightedBlockEffectiveCount) =>
    float result = na
    if not na(dataAdequacy)
        if na(benchmarkCalibration)
            result := math.min(dataAdequacy, OVERALL_NO_BENCHMARK_VALIDATION_CAP)
        else
            float baseLogScore =
                 0.62 * math.log(math.max(dataAdequacy, SCORE_FLOOR)) +
                 0.38 * math.log(math.max(benchmarkCalibration, SCORE_FLOOR))
            float baseEvidence = f_clamp01(math.exp(baseLogScore))
            if na(validatedEnhancement)
                result := baseEvidence
            else
                float enhancedLogScore =
                     0.82 * math.log(math.max(baseEvidence, SCORE_FLOOR)) +
                     0.18 * math.log(math.max(validatedEnhancement, SCORE_FLOOR))
                result := f_clamp01(math.exp(enhancedLogScore))
        if weightedBlockEffectiveCount < EVIDENCE_WEAK_EFFECTIVE
            result := math.min(result, EVIDENCE_WEAK_CAP)
        else if weightedBlockEffectiveCount < EVIDENCE_MODERATE_EFFECTIVE
            result := math.min(result, EVIDENCE_MODERATE_CAP)
    result

// Four chronological blocks are compared on q10, q50, q90, width and asymmetry.
f_distribution_stability(array<float> outcomes) =>
    int count = array.size(outcomes)
    float result = na
    if count >= 80
        int chronologicalBlocks = 4
        int baseBlockSize = int(math.floor(float(count) / float(chronologicalBlocks)))
        array<float> q10Values = array.new_float()
        array<float> q50Values = array.new_float()
        array<float> q90Values = array.new_float()
        array<float> widthValues = array.new_float()
        array<float> asymmetryValues = array.new_float()
        for blockIndex = 0 to chronologicalBlocks - 1
            int startIndex = blockIndex * baseBlockSize
            int endIndex = blockIndex == chronologicalBlocks - 1 ? count - 1 : (blockIndex + 1) * baseBlockSize - 1
            array<float> blockOutcomes = array.new_float()
            for outcomeIndex = startIndex to endIndex
                array.push(blockOutcomes, array.get(outcomes, outcomeIndex))
            array.sort(blockOutcomes, order.ascending)
            float blockQ10 = f_percentile_sorted(blockOutcomes, 0.10)
            float blockQ50 = f_percentile_sorted(blockOutcomes, 0.50)
            float blockQ90 = f_percentile_sorted(blockOutcomes, 0.90)
            float lowerWidth = math.max(blockQ50 - blockQ10, 0.0001)
            float upperWidth = math.max(blockQ90 - blockQ50, 0.0001)
            float width = lowerWidth + upperWidth
            float asymmetry = (upperWidth - lowerWidth) / math.max(width, 0.0001)
            array.push(q10Values, blockQ10)
            array.push(q50Values, blockQ50)
            array.push(q90Values, blockQ90)
            array.push(widthValues, width)
            array.push(asymmetryValues, asymmetry)
        float minimumQ10 = array.get(q10Values, 0)
        float maximumQ10 = minimumQ10
        float minimumQ50 = array.get(q50Values, 0)
        float maximumQ50 = minimumQ50
        float minimumQ90 = array.get(q90Values, 0)
        float maximumQ90 = minimumQ90
        float minimumWidth = array.get(widthValues, 0)
        float maximumWidth = minimumWidth
        float totalWidth = 0.0
        float minimumAsymmetry = array.get(asymmetryValues, 0)
        float maximumAsymmetry = minimumAsymmetry
        for blockIndex = 0 to chronologicalBlocks - 1
            float blockQ10 = array.get(q10Values, blockIndex)
            float blockQ50 = array.get(q50Values, blockIndex)
            float blockQ90 = array.get(q90Values, blockIndex)
            float blockWidth = array.get(widthValues, blockIndex)
            float blockAsymmetry = array.get(asymmetryValues, blockIndex)
            minimumQ10 := math.min(minimumQ10, blockQ10)
            maximumQ10 := math.max(maximumQ10, blockQ10)
            minimumQ50 := math.min(minimumQ50, blockQ50)
            maximumQ50 := math.max(maximumQ50, blockQ50)
            minimumQ90 := math.min(minimumQ90, blockQ90)
            maximumQ90 := math.max(maximumQ90, blockQ90)
            minimumWidth := math.min(minimumWidth, blockWidth)
            maximumWidth := math.max(maximumWidth, blockWidth)
            minimumAsymmetry := math.min(minimumAsymmetry, blockAsymmetry)
            maximumAsymmetry := math.max(maximumAsymmetry, blockAsymmetry)
            totalWidth += blockWidth
        float pooledWidth = math.max(totalWidth / float(chronologicalBlocks), 0.01)
        float centerDrift = (maximumQ50 - minimumQ50) / pooledWidth
        float lowerTailDrift = (maximumQ10 - minimumQ10) / pooledWidth
        float upperTailDrift = (maximumQ90 - minimumQ90) / pooledWidth
        float widthDrift = math.abs(math.log(math.max(maximumWidth, 0.0001) / math.max(minimumWidth, 0.0001)))
        float asymmetryDrift = maximumAsymmetry - minimumAsymmetry
        float centerScore = 1.0 / (1.0 + centerDrift)
        float lowerTailScore = 1.0 / (1.0 + lowerTailDrift)
        float upperTailScore = 1.0 / (1.0 + upperTailDrift)
        float widthScore = 1.0 / (1.0 + widthDrift)
        float asymmetryScore = 1.0 / (1.0 + asymmetryDrift)
        result := f_clamp01(
            0.35 * centerScore +
            0.20 * lowerTailScore +
            0.20 * upperTailScore +
            0.15 * widthScore +
            0.10 * asymmetryScore)
    result

f_horizon_for_month(int monthNumber) =>
    int(math.max(
        1.0,
        math.min(
            float(projectionHorizon),
            math.round(float(monthNumber) * float(projectionHorizon) / float(monthsInHorizon)))))

// === Core empirical model
// Returns conditioned q10/q50/q90 and the unconditional benchmark from the same sample collection.
// conditioningMultiplier is in [0, 1] and can only reduce configured conditional mass.
f_model_quantiles(
    int horizon,
    int stride,
    int originOffset,
    bool conditioningEnabled,
    float conditioningMultiplier,
    bool collectDiagnostics) =>
    array<float> outcomes = array.new_float()
    array<bool> trendMatches = array.new_bool()
    array<float> volatilitySimilarities = array.new_float()

    float safeConditioningMultiplier = f_clamp01(conditioningMultiplier)
    bool evaluateConditioning = conditioningEnabled and safeConditioningMultiplier > EPSILON
    int availableBars = math.min(bar_index, HARD_MAX_BARS_BACK)
    bool originAvailable = originOffset <= availableBars
    bool originTrendReady = false
    bool originTrendBull = false
    float originVolatilityRank = na

    if originAvailable and evaluateConditioning
        originTrendReady := not na(close[originOffset]) and not na(trendAverage[originOffset])
        originTrendBull := originTrendReady and close[originOffset] > trendAverage[originOffset]
        originVolatilityRank := volatilityRank[originOffset]

    bool originVolatilityReady = evaluateConditioning and not na(originVolatilityRank)
    int trendMatchCount = 0
    float volatilityEquivalentCount = 0.0

    for sample = 0 to MAX_RAW_SAMPLES - 1
        int endOffset = originOffset + sample * stride
        int startOffset = endOffset + horizon
        if startOffset <= availableBars
            float outcome = f_log_return(close[startOffset], close[endOffset])
            if not na(outcome)
                array.push(outcomes, outcome)
                if evaluateConditioning
                    bool sampleTrendReady = not na(close[startOffset]) and not na(trendAverage[startOffset])
                    bool sampleTrendBull = sampleTrendReady and close[startOffset] > trendAverage[startOffset]
                    bool sameTrend = originTrendReady and sampleTrendReady and originTrendBull == sampleTrendBull
                    float sampleVolatilityRank = volatilityRank[startOffset]
                    float volatilitySimilarity =
                         originVolatilityReady and not na(sampleVolatilityRank) ?
                         f_clamp01(1.0 - math.abs(originVolatilityRank - sampleVolatilityRank) / VOLATILITY_RANK_TOLERANCE) : 0.0
                    array.push(trendMatches, sameTrend)
                    array.push(volatilitySimilarities, volatilitySimilarity)
                    if sameTrend
                        trendMatchCount += 1
                    volatilityEquivalentCount += volatilitySimilarity

    int rawCount = array.size(outcomes)
    float rawOverlapEffectiveCount = f_effective_samples(float(rawCount), stride, horizon)
    float trendEffectiveCount = 0.0
    float volatilityEffectiveCount = 0.0

    if evaluateConditioning and rawCount > 0
        if originTrendReady
            array<float> trendEvidenceWeights = array.new_float()
            for index = 0 to rawCount - 1
                array.push(trendEvidenceWeights, array.get(trendMatches, index) ? 1.0 : 0.0)
            trendEffectiveCount := f_block_effective_count(trendEvidenceWeights, stride, horizon)
        if originVolatilityReady
            array<float> volatilityEvidenceWeights = array.new_float()
            for index = 0 to rawCount - 1
                array.push(volatilityEvidenceWeights, array.get(volatilitySimilarities, index))
            volatilityEffectiveCount := f_block_effective_count(volatilityEvidenceWeights, stride, horizon)

    float trendMass =
         evaluateConditioning and originTrendReady ?
         MAX_TREND_MASS * f_reliability(trendEffectiveCount) * safeConditioningMultiplier : 0.0
    float volatilityMass =
         evaluateConditioning and originVolatilityReady ?
         MAX_VOLATILITY_MASS * f_reliability(volatilityEffectiveCount) * safeConditioningMultiplier : 0.0
    float conditionalMass = trendMass + volatilityMass

    if conditionalMass > MAX_CONDITIONAL_MASS and conditionalMass > 0.0
        float massScale = MAX_CONDITIONAL_MASS / conditionalMass
        trendMass *= massScale
        volatilityMass *= massScale
        conditionalMass := MAX_CONDITIONAL_MASS

    float q10 = na
    float q50 = na
    float q90 = na
    float globalQ10 = na
    float globalQ50 = na
    float globalQ90 = na
    float kishCount = 0.0
    float weightedBlockEffectiveCount = 0.0

    if rawCount >= MIN_RAW_SAMPLES
        array<float> weights = array.new_float()
        if conditionalMass > EPSILON
            float globalMassPerSample = (1.0 - conditionalMass) / float(rawCount)
            for index = 0 to rawCount - 1
                bool sameTrend = array.get(trendMatches, index)
                float volatilitySimilarity = array.get(volatilitySimilarities, index)
                float trendContribution =
                     trendMatchCount > 0 and sameTrend ? trendMass / float(trendMatchCount) : 0.0
                float volatilityContribution =
                     volatilityEquivalentCount > 0.0 ?
                     volatilityMass * volatilitySimilarity / volatilityEquivalentCount : 0.0
                array.push(weights, globalMassPerSample + trendContribution + volatilityContribution)
        else
            float uniformWeight = 1.0 / float(rawCount)
            for index = 0 to rawCount - 1
                array.push(weights, uniformWeight)

        array<int> sortedIndices = array.sort_indices(outcomes, order.ascending)
        float totalWeight = f_sum_positive(weights)
        kishCount := f_kish_count(weights, totalWeight)
        weightedBlockEffectiveCount := f_block_effective_count(weights, stride, horizon)

        [weightedQ10, weightedQ50, weightedQ90] =
             f_weighted_quantile_triplet(outcomes, weights, sortedIndices, totalWeight)
        q10 := weightedQ10
        q50 := weightedQ50
        q90 := weightedQ90

        if conditionalMass > EPSILON
            float benchmarkWeight = 1.0 / float(rawCount)
            array<float> benchmarkWeights = array.new_float(rawCount, benchmarkWeight)
            [benchmarkQ10, benchmarkQ50, benchmarkQ90] =
                 f_weighted_quantile_triplet(outcomes, benchmarkWeights, sortedIndices, 1.0)
            globalQ10 := benchmarkQ10
            globalQ50 := benchmarkQ50
            globalQ90 := benchmarkQ90
        else
            globalQ10 := q10
            globalQ50 := q50
            globalQ90 := q90

    float stabilityScore =
         collectDiagnostics and rawCount >= MIN_RAW_SAMPLES ?
         f_distribution_stability(outcomes) : na

    [q10, q50, q90, globalQ10, globalQ50, globalQ90, rawCount, rawOverlapEffectiveCount, weightedBlockEffectiveCount, conditionalMass, kishCount, stabilityScore]

// === Horizon-specific conditioning skill guard
// Current and historical-origin loss profiles use their exact forecast-maturity phases.
// Historical gate c starts with the forecast that matured on calibration origin c, then uses
// only still older completed forecasts. This is an exact nested walk-forward reconstruction.
f_conditioning_gate_from_profile(
    array<float> conditionedLosses,
    array<float> globalLosses,
    array<float> evidenceWeights,
    int startIndex,
    int maximumErrors,
    int stride,
    int horizon) =>
    int profileCount = array.size(evidenceWeights)
    int safeStartIndex = math.max(startIndex, 0)
    int windowCount =
         safeStartIndex < profileCount ?
         math.min(maximumErrors, profileCount - safeStartIndex) : 0
    array<float> windowWeights = array.new_float()
    float conditionedLossTotal = 0.0
    float globalLossTotal = 0.0
    int skillCount = 0

    if windowCount > 0 and
       array.size(conditionedLosses) == profileCount and
       array.size(globalLosses) == profileCount
        for windowIndex = 0 to windowCount - 1
            int sourceIndex = safeStartIndex + windowIndex
            float sourceWeight = math.max(array.get(evidenceWeights, sourceIndex), 0.0)
            float conditionedLoss = array.get(conditionedLosses, sourceIndex)
            float globalLoss = array.get(globalLosses, sourceIndex)
            bool usable =
                 sourceWeight > EPSILON and
                 not na(conditionedLoss) and not na(globalLoss)
            float usableWeight = usable ? sourceWeight : 0.0
            array.push(windowWeights, usableWeight)
            if usable
                conditionedLossTotal += usableWeight * conditionedLoss
                globalLossTotal += usableWeight * globalLoss
                skillCount += 1

    float skillEffectiveCount = f_block_effective_count(windowWeights, stride, horizon)
    float skill =
         skillCount >= MIN_CONDITIONING_SKILL_ERRORS and globalLossTotal > EPSILON ?
         f_clamp(1.0 - conditionedLossTotal / globalLossTotal, -1.0, 1.0) : na
    float skillShrinkage =
         skillEffectiveCount > 0.0 ?
         skillEffectiveCount / (skillEffectiveCount + CONDITIONING_SKILL_PRIOR_STRENGTH) : 0.0
    float shrunkSkill = na(skill) ? na : skill * skillShrinkage
    float skillReliability = f_linear_reliability(
        skillEffectiveCount,
        CONDITIONING_VALIDATION_EFFECTIVE_MIN,
        CONDITIONING_VALIDATION_EFFECTIVE_FULL)
    float positiveSkillGate =
         not na(shrunkSkill) and shrunkSkill > 0.0 ?
         f_clamp01(shrunkSkill / CONDITIONING_FULL_POSITIVE_SKILL) : 0.0
    float adaptiveGate = skillReliability * positiveSkillGate

    [skill, shrunkSkill, skillCount, skillEffectiveCount, f_clamp01(adaptiveGate)]

// One completed forecast diagnostic. The benchmark outputs remain available even when
// conditioning is disabled, so absolute benchmark calibration can always be evaluated.
f_conditioning_forecast_diagnostics(
    int horizon,
    int stride,
    int maturityOffset,
    bool conditioningEnabled) =>
    int availableBars = math.min(bar_index, HARD_MAX_BARS_BACK)
    int forecastOriginOffset = maturityOffset + horizon
    float conditionedLossValue = na
    float globalLossValue = na
    float skillWeight = 0.0
    float benchmarkWeight = 0.0
    float benchmarkIntervalHit = na
    float benchmarkLowerHit = na
    float benchmarkUpperHit = na
    float benchmarkNormalizedError = na

    if forecastOriginOffset <= availableBars
        [conditionedQ10, conditionedQ50, conditionedQ90, globalQ10, globalQ50, globalQ90, rawCount, rawOverlapEffective, weightedBlockEffective, conditionalMass, kishCount, stabilityScore] = f_model_quantiles(
            horizon,
            stride,
            forecastOriginOffset,
            conditioningEnabled,
            conditioningEnabled ? 1.0 : 0.0,
            false)

        float actualReturn = f_log_return(close[forecastOriginOffset], close[maturityOffset])
        float conditionedLoss = f_quantile_set_loss(actualReturn, conditionedQ10, conditionedQ50, conditionedQ90)
        float globalLoss = f_quantile_set_loss(actualReturn, globalQ10, globalQ50, globalQ90)
        float globalLowerWidth =
             not na(globalQ10) and not na(globalQ50) ? globalQ50 - globalQ10 : na
        float globalUpperWidth =
             not na(globalQ50) and not na(globalQ90) ? globalQ90 - globalQ50 : na
        bool globalUsable =
             rawCount >= MIN_RAW_SAMPLES and
             rawOverlapEffective >= MIN_WEIGHTED_EFFECTIVE_SAMPLES and
             not na(actualReturn) and
             not na(globalLoss) and
             not na(globalLowerWidth) and not na(globalUpperWidth) and
             globalLowerWidth > 0.0 and globalUpperWidth > 0.0

        if globalUsable
            benchmarkWeight := 1.0
            benchmarkIntervalHit := actualReturn >= globalQ10 and actualReturn <= globalQ90 ? 1.0 : 0.0
            benchmarkLowerHit := actualReturn >= globalQ10 ? 1.0 : 0.0
            benchmarkUpperHit := actualReturn <= globalQ90 ? 1.0 : 0.0
            float benchmarkError = actualReturn - globalQ50
            benchmarkNormalizedError :=
                 benchmarkError >= 0.0 ?
                 benchmarkError / math.max(globalUpperWidth, EPSILON) :
                 -benchmarkError / math.max(globalLowerWidth, EPSILON)

        bool conditionedUsable =
             conditioningEnabled and
             globalUsable and
             weightedBlockEffective >= MIN_WEIGHTED_EFFECTIVE_SAMPLES and
             conditionalMass > EPSILON and
             not na(conditionedLoss)
        if conditionedUsable
            conditionedLossValue := conditionedLoss
            globalLossValue := globalLoss
            skillWeight := f_clamp01(conditionalMass / MAX_CONDITIONAL_MASS)

    [conditionedLossValue, globalLossValue, skillWeight, benchmarkWeight, benchmarkIntervalHit, benchmarkLowerHit, benchmarkUpperHit, benchmarkNormalizedError]

f_conditioning_research(
    int horizon,
    int stride,
    bool conditioningEnabled,
    bool historicalGatesRequired) =>
    int skillStride = math.max(stride, int(math.round(float(horizon) * CALIBRATION_ORIGIN_FRACTION)))
    int maximumErrors = f_research_error_limit(horizon, stride)
    bool historicalPhaseAligned = historicalGatesRequired and horizon % skillStride == 0
    int historicalPhaseLead = historicalPhaseAligned ? int(horizon / skillStride) : 0
    int currentProfileCount =
         historicalPhaseAligned ?
         historicalPhaseLead + maximumErrors * 2 - 1 : maximumErrors

    array<float> currentConditionedLosses = array.new_float()
    array<float> currentGlobalLosses = array.new_float()
    array<float> currentSkillWeights = array.new_float()

    array<float> benchmarkWeights = array.new_float()
    array<float> benchmarkIntervalHits = array.new_float()
    array<float> benchmarkLowerHits = array.new_float()
    array<float> benchmarkUpperHits = array.new_float()
    array<float> benchmarkNormalizedErrors = array.new_float()

    // Current guard and benchmark validation. When the historical phase aligns with the
    // current grid, the profile is extended and reused for exact historical-origin gates.
    for skillSample = 0 to currentProfileCount - 1
        int maturityOffset = skillSample * skillStride
        [conditionedLoss, globalLoss, skillWeight, benchmarkWeight, benchmarkIntervalHit, benchmarkLowerHit, benchmarkUpperHit, benchmarkNormalizedError] =
             f_conditioning_forecast_diagnostics(
                horizon,
                stride,
                maturityOffset,
                conditioningEnabled)
        array.push(currentConditionedLosses, conditionedLoss)
        array.push(currentGlobalLosses, globalLoss)
        array.push(currentSkillWeights, skillWeight)
        if skillSample < maximumErrors
            array.push(benchmarkWeights, benchmarkWeight)
            array.push(benchmarkIntervalHits, benchmarkIntervalHit)
            array.push(benchmarkLowerHits, benchmarkLowerHit)
            array.push(benchmarkUpperHits, benchmarkUpperHit)
            array.push(benchmarkNormalizedErrors, benchmarkNormalizedError)

    [skill, shrunkSkill, skillCount, skillEffectiveCount, currentGate] =
         f_conditioning_gate_from_profile(
            currentConditionedLosses,
            currentGlobalLosses,
            currentSkillWeights,
            0,
            maximumErrors,
            skillStride,
            horizon)

    array<float> historicalOriginGates = array.new_float()
    if not historicalGatesRequired
        for calibrationSample = 0 to maximumErrors - 1
            array.push(historicalOriginGates, 0.0)
    else if historicalPhaseAligned
        for calibrationSample = 0 to maximumErrors - 1
            int historicalStart = historicalPhaseLead + calibrationSample
            [_, _, _, _, historicalGate] = f_conditioning_gate_from_profile(
                currentConditionedLosses,
                currentGlobalLosses,
                currentSkillWeights,
                historicalStart,
                maximumErrors,
                skillStride,
                horizon)
            array.push(historicalOriginGates, historicalGate)
    else
        // Non-aligned horizons require a second exact maturity phase. Index c is the
        // forecast that matured on calibration origin c; no post-origin loss can enter.
        int historicalProfileCount = maximumErrors * 2 - 1
        array<float> historicalConditionedLosses = array.new_float()
        array<float> historicalGlobalLosses = array.new_float()
        array<float> historicalSkillWeights = array.new_float()

        for historicalSample = 0 to historicalProfileCount - 1
            int historicalMaturityOffset = horizon + historicalSample * skillStride
            [historicalConditionedLoss, historicalGlobalLoss, historicalSkillWeight, _, _, _, _, _] =
                 f_conditioning_forecast_diagnostics(
                    horizon,
                    stride,
                    historicalMaturityOffset,
                    conditioningEnabled)
            array.push(historicalConditionedLosses, historicalConditionedLoss)
            array.push(historicalGlobalLosses, historicalGlobalLoss)
            array.push(historicalSkillWeights, historicalSkillWeight)

        for calibrationSample = 0 to maximumErrors - 1
            [_, _, _, _, historicalGate] = f_conditioning_gate_from_profile(
                historicalConditionedLosses,
                historicalGlobalLosses,
                historicalSkillWeights,
                calibrationSample,
                maximumErrors,
                skillStride,
                horizon)
            array.push(historicalOriginGates, historicalGate)

    [benchmarkValidationCount, benchmarkValidationEffective, benchmarkCoverage, benchmarkShrunkCoverage, benchmarkLowerCoverage, benchmarkUpperCoverage, benchmarkMedianNormalizedError, benchmarkDiagnostic] =
         f_benchmark_validation_from_profile(
            benchmarkWeights,
            benchmarkIntervalHits,
            benchmarkLowerHits,
            benchmarkUpperHits,
            benchmarkNormalizedErrors,
            skillStride,
            horizon)

    [skill, shrunkSkill, skillCount, skillEffectiveCount, currentGate, historicalOriginGates, benchmarkValidationCount, benchmarkValidationEffective, benchmarkCoverage, benchmarkShrunkCoverage, benchmarkLowerCoverage, benchmarkUpperCoverage, benchmarkMedianNormalizedError, benchmarkDiagnostic]

// === Asymmetric calibration helpers
f_calibration_fit(
    array<float> medianErrors,
    array<float> lowerWidths,
    array<float> upperWidths,
    int startIndex,
    int sampleCount,
    float effectiveCount) =>
    float adjustedBias = 0.0
    float adjustedLogLowerScale = 0.0
    float adjustedLogUpperScale = 0.0
    float shrinkage = 0.0

    if sampleCount >= MIN_CALIBRATION_ERRORS
        array<float> subsetErrors = array.new_float()
        for subsetIndex = 0 to sampleCount - 1
            array.push(subsetErrors, array.get(medianErrors, startIndex + subsetIndex))
        array.sort(subsetErrors, order.ascending)
        float rawBias = f_percentile_sorted(subsetErrors, 0.50)
        array<float> lowerScores = array.new_float()
        array<float> upperScores = array.new_float()

        for subsetIndex = 0 to sampleCount - 1
            int sourceIndex = startIndex + subsetIndex
            float error = array.get(medianErrors, sourceIndex)
            float lowerWidth = array.get(lowerWidths, sourceIndex)
            float upperWidth = array.get(upperWidths, sourceIndex)
            float lowerScore = error < rawBias ? (rawBias - error) / lowerWidth : 0.0
            float upperScore = error > rawBias ? (error - rawBias) / upperWidth : 0.0
            array.push(lowerScores, math.max(lowerScore, 0.0))
            array.push(upperScores, math.max(upperScore, 0.0))

        array.sort(lowerScores, order.ascending)
        array.sort(upperScores, order.ascending)
        int rankIndex = math.min(
            sampleCount - 1,
            int(math.ceil((sampleCount + 1) * TARGET_ONE_SIDED_COVERAGE)) - 1)
        int safeRankIndex = math.max(rankIndex, 0)
        float rawLowerScale = f_clamp(
            array.get(lowerScores, safeRankIndex),
            MIN_SCALE_CORRECTION,
            MAX_SCALE_CORRECTION)
        float rawUpperScale = f_clamp(
            array.get(upperScores, safeRankIndex),
            MIN_SCALE_CORRECTION,
            MAX_SCALE_CORRECTION)

        shrinkage := effectiveCount / (effectiveCount + CALIBRATION_PRIOR_STRENGTH)
        adjustedBias := shrinkage * rawBias
        adjustedLogLowerScale := shrinkage * math.log(rawLowerScale)
        adjustedLogUpperScale := shrinkage * math.log(rawUpperScale)

    [adjustedBias, adjustedLogLowerScale, adjustedLogUpperScale, shrinkage]

// Calibration fit uses all errors completed by the current origin. Every historical forecast is
// reconstructed with the conditioning guard available at its own origin. During validation, the
// correction is fitted only on errors that had already matured by that forecast origin; a full
// horizon embargo prevents overlapping future outcomes from leaking into the historical fit.
// The returned gate is zero unless ordered validation skill is positive.
f_calibration_parameters(
    int horizon,
    int stride,
    bool conditioningEnabled,
    bool adaptiveConditioningEnabled,
    array<float> historicalConditioningGates) =>
    array<float> medianErrors = array.new_float()
    array<float> lowerWidths = array.new_float()
    array<float> upperWidths = array.new_float()
    array<int> errorPositions = array.new_int()

    int availableBars = math.min(bar_index, HARD_MAX_BARS_BACK)
    int calibrationStride = math.max(stride, int(math.round(float(horizon) * CALIBRATION_ORIGIN_FRACTION)))
    int calibrationEmbargoSteps = int(math.ceil(float(horizon) / float(calibrationStride)))
    int maximumErrors = f_research_error_limit(horizon, stride)

    for calibrationSample = 0 to maximumErrors - 1
        int maturityOffset = calibrationSample * calibrationStride
        int forecastOriginOffset = maturityOffset + horizon
        if forecastOriginOffset <= availableBars
            float historicalConditioningMultiplier =
                 not conditioningEnabled ? 0.0 :
                 not adaptiveConditioningEnabled ? 1.0 :
                 calibrationSample < array.size(historicalConditioningGates) ?
                 array.get(historicalConditioningGates, calibrationSample) : 0.0
            [pastQ10, pastQ50, pastQ90, pastGlobalQ10, pastGlobalQ50, pastGlobalQ90, pastRawCount, pastRawOverlapEffective, pastWeightedBlockEffective, pastConditionalMass, pastKish, pastStability] = f_model_quantiles(
                horizon,
                stride,
                forecastOriginOffset,
                conditioningEnabled,
                historicalConditioningMultiplier,
                false)

            float actualReturn = f_log_return(close[forecastOriginOffset], close[maturityOffset])
            float lowerWidth = not na(pastQ10) and not na(pastQ50) ? pastQ50 - pastQ10 : na
            float upperWidth = not na(pastQ50) and not na(pastQ90) ? pastQ90 - pastQ50 : na
            bool usable =
                 pastRawCount >= MIN_RAW_SAMPLES and
                 pastWeightedBlockEffective >= MIN_WEIGHTED_EFFECTIVE_SAMPLES and
                 not na(actualReturn) and
                 not na(lowerWidth) and not na(upperWidth) and
                 lowerWidth > 0.0 and upperWidth > 0.0
            if usable
                array.push(medianErrors, actualReturn - pastQ50)
                array.push(lowerWidths, lowerWidth)
                array.push(upperWidths, upperWidth)
                array.push(errorPositions, calibrationSample)

    int calibrationCount = array.size(medianErrors)
    float calibrationEffectiveCount = f_positioned_effective_count(
        errorPositions,
        0,
        calibrationCount,
        calibrationStride,
        horizon)
    [adjustedBias, adjustedLogLowerScale, adjustedLogUpperScale, shrinkage] =
         f_calibration_fit(
            medianErrors,
            lowerWidths,
            upperWidths,
            0,
            calibrationCount,
            calibrationEffectiveCount)

    int validationCount = 0
    int validationCoveredCount = 0
    array<float> validationNormalizedErrors = array.new_float()
    array<int> validationPositions = array.new_int()
    float validationRawLossTotal = 0.0
    float validationCorrectedLossTotal = 0.0

    if calibrationCount > MIN_CALIBRATION_ERRORS
        for validationIndex = 0 to calibrationCount - 1
            int validationPosition = array.get(errorPositions, validationIndex)
            int minimumTrainingPosition = validationPosition + calibrationEmbargoSteps
            int trainingStartIndex = -1
            if validationIndex + 1 < calibrationCount
                for candidateIndex = validationIndex + 1 to calibrationCount - 1
                    if trainingStartIndex == -1 and array.get(errorPositions, candidateIndex) >= minimumTrainingPosition
                        trainingStartIndex := candidateIndex
            int trainingCount = trainingStartIndex >= 0 ? calibrationCount - trainingStartIndex : 0
            if trainingCount >= MIN_CALIBRATION_ERRORS
                float trainingEffectiveCount = f_positioned_effective_count(
                    errorPositions,
                    trainingStartIndex,
                    trainingCount,
                    calibrationStride,
                    horizon)
                [validationBias, validationLogLowerScale, validationLogUpperScale, validationShrinkage] =
                     f_calibration_fit(
                        medianErrors,
                        lowerWidths,
                        upperWidths,
                        trainingStartIndex,
                        trainingCount,
                        trainingEffectiveCount)

                float validationError = array.get(medianErrors, validationIndex)
                float validationLowerWidth = array.get(lowerWidths, validationIndex)
                float validationUpperWidth = array.get(upperWidths, validationIndex)
                float validationSpan = validationLowerWidth + validationUpperWidth
                float validationCenterShift = f_clamp(
                    validationBias,
                    -MAX_CENTER_SHIFT_AS_SPAN * validationSpan,
                    MAX_CENTER_SHIFT_AS_SPAN * validationSpan)
                float validationLowerScale = math.exp(validationLogLowerScale)
                float validationUpperScale = math.exp(validationLogUpperScale)
                float correctedError = validationError - validationCenterShift
                float correctedLowerWidth = validationLowerWidth * validationLowerScale
                float correctedUpperWidth = validationUpperWidth * validationUpperScale

                if correctedError >= -correctedLowerWidth and correctedError <= correctedUpperWidth
                    validationCoveredCount += 1

                float normalizedError =
                     correctedError >= 0.0 ?
                     correctedError / math.max(correctedUpperWidth, EPSILON) :
                     -correctedError / math.max(correctedLowerWidth, EPSILON)
                array.push(validationNormalizedErrors, math.max(normalizedError, 0.0))

                float rawLoss = f_quantile_set_loss(
                    validationError,
                    -validationLowerWidth,
                    0.0,
                    validationUpperWidth)
                float correctedLoss = f_quantile_set_loss(
                    validationError,
                    validationCenterShift - correctedLowerWidth,
                    validationCenterShift,
                    validationCenterShift + correctedUpperWidth)
                if not na(rawLoss) and not na(correctedLoss)
                    validationRawLossTotal += rawLoss
                    validationCorrectedLossTotal += correctedLoss
                array.push(validationPositions, array.get(errorPositions, validationIndex))
                validationCount += 1

    float validationEffectiveCount = f_positioned_effective_count(
        validationPositions,
        0,
        validationCount,
        calibrationStride,
        horizon)
    float validationCoverage = na
    float validationShrunkCoverage = na
    float validationMedianNormalizedError = na
    float validationSkill = na
    float validationShrunkSkill = na
    float calibrationDiagnostic = na
    float calibrationGate = 0.0

    if validationCount >= MIN_CALIBRATION_VALIDATION_ERRORS
        validationCoverage := float(validationCoveredCount) / float(validationCount)
        validationShrunkCoverage := (
            validationCoverage * validationEffectiveCount +
            CALIBRATION_COVERAGE_PRIOR * TARGET_INTERVAL_COVERAGE) / (
            validationEffectiveCount + CALIBRATION_COVERAGE_PRIOR)
        array.sort(validationNormalizedErrors, order.ascending)
        validationMedianNormalizedError := f_percentile_sorted(validationNormalizedErrors, 0.50)
        validationSkill := (
            validationRawLossTotal > EPSILON ?
             f_clamp(1.0 - validationCorrectedLossTotal / validationRawLossTotal, -1.0, 1.0) : na)
        float validationSkillShrinkage =
             validationEffectiveCount > 0.0 ?
             validationEffectiveCount /
             (validationEffectiveCount + CALIBRATION_VALIDATION_SKILL_PRIOR) : 0.0
        validationShrunkSkill := na(validationSkill) ? na : validationSkill * validationSkillShrinkage

        float validationReliability = f_linear_reliability(
            validationEffectiveCount,
            CALIBRATION_VALIDATION_EFFECTIVE_MIN,
            CALIBRATION_VALIDATION_EFFECTIVE_FULL)
        float coverageScore = f_clamp01(
            1.0 - math.abs(validationShrunkCoverage - TARGET_INTERVAL_COVERAGE) / 0.30)
        float medianAccuracyScore = 1.0 / (1.0 + validationMedianNormalizedError)
        float skillPerformanceScore = f_skill_performance_quality(validationShrunkSkill)
        calibrationDiagnostic := f_clamp01(
            validationReliability *
            (0.35 * coverageScore +
             0.20 * medianAccuracyScore +
             0.45 * skillPerformanceScore))

        float positiveSkillGate =
             not na(validationShrunkSkill) and validationShrunkSkill > 0.0 ?
             f_clamp01(validationShrunkSkill / CALIBRATION_FULL_POSITIVE_SKILL) : 0.0
        calibrationGate := f_clamp01(
            validationReliability *
            positiveSkillGate *
            (0.60 + 0.40 * coverageScore))

    [adjustedBias, adjustedLogLowerScale, adjustedLogUpperScale, calibrationCount, calibrationEffectiveCount, shrinkage, calibrationDiagnostic, calibrationGate, validationCount, validationEffectiveCount, validationCoverage, validationShrunkCoverage, validationMedianNormalizedError, validationSkill, validationShrunkSkill]

f_interpolate(array<int> xValues, array<float> yValues, int x, float fallback) =>
    int count = array.size(xValues)
    float result = fallback
    if count > 0 and array.size(yValues) == count
        int firstX = array.get(xValues, 0)
        int lastX = array.get(xValues, count - 1)
        if x <= firstX
            result := array.get(yValues, 0)
        else if x >= lastX
            result := array.get(yValues, count - 1)
        else if count > 1
            bool found = false
            for index = 1 to count - 1
                int rightX = array.get(xValues, index)
                if not found and x <= rightX
                    int leftX = array.get(xValues, index - 1)
                    float leftY = array.get(yValues, index - 1)
                    float rightY = array.get(yValues, index)
                    float fraction = float(x - leftX) / math.max(float(rightX - leftX), 1.0)
                    result := leftY + fraction * (rightY - leftY)
                    found := true
    result

// === Persistent model and drawing state
var array<polyline> projectionDrawings = array.new<polyline>()
var array<float> storedQ10ByMonth = array.new_float()
var array<float> storedQ50ByMonth = array.new_float()
var array<float> storedQ90ByMonth = array.new_float()
var table summaryTable = na
var string previousTablePosition = ""
var int previousTableRows = 0

var bool storedProjectionAvailable = false
var float storedAnchorPrice = na
var int storedAnchorIndex = na
var float storedTerminalQ10 = na
var float storedTerminalQ50 = na
var float storedTerminalQ90 = na
var int storedTerminalRawCount = 0
var float storedTerminalRawOverlapEffective = 0.0
var float storedTerminalWeightedBlockEffective = 0.0
var float storedTerminalKishCount = 0.0
var float storedTerminalConditionalMass = 0.0
var float storedTerminalCenterShift = na
var float storedTerminalLowerScale = na
var float storedTerminalUpperScale = na
var float storedTerminalStability = na

var float storedConditioningSkill = na
var float storedConditioningShrunkSkill = na
var int storedConditioningSkillCount = 0
var float storedConditioningSkillEffective = 0.0
var float storedConditioningGate = 0.0

var int storedTerminalBenchmarkValidationCount = 0
var float storedTerminalBenchmarkValidationEffective = 0.0
var float storedTerminalBenchmarkCoverage = na
var float storedTerminalBenchmarkShrunkCoverage = na
var float storedTerminalBenchmarkLowerCoverage = na
var float storedTerminalBenchmarkUpperCoverage = na
var float storedTerminalBenchmarkMedianNormalizedError = na
var float storedTerminalBenchmarkDiagnostic = na

var int storedTerminalCalibrationCount = 0
var float storedTerminalCalibrationEffective = 0.0
var float storedTerminalCalibrationFitShrinkage = 0.0
var float storedTerminalCalibrationDiagnostic = na
var float storedTerminalCalibrationGate = 0.0
var int storedTerminalCalibrationValidationCount = 0
var float storedTerminalCalibrationValidationEffective = 0.0
var float storedTerminalCalibrationValidationCoverage = na
var float storedTerminalCalibrationValidationShrunkCoverage = na
var float storedTerminalCalibrationValidationMedianNormalizedError = na
var float storedTerminalCalibrationValidationSkill = na
var float storedTerminalCalibrationValidationShrunkSkill = na

f_clear_drawings() =>
    int count = array.size(projectionDrawings)
    if count > 0
        for index = 0 to count - 1
            polyline.delete(array.get(projectionDrawings, index))
        array.clear(projectionDrawings)

plot(na, title = "Compiler anchor", display = display.none)

// === Statistical refresh: confirmed bars only
bool refreshStatisticalModel =
     supportedContext and
     (barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed))

if refreshStatisticalModel
    array.clear(storedQ10ByMonth)
    array.clear(storedQ50ByMonth)
    array.clear(storedQ90ByMonth)
    storedProjectionAvailable := false
    storedAnchorPrice := close
    storedAnchorIndex := bar_index
    storedTerminalQ10 := na
    storedTerminalQ50 := na
    storedTerminalQ90 := na
    storedTerminalRawCount := 0
    storedTerminalRawOverlapEffective := 0.0
    storedTerminalWeightedBlockEffective := 0.0
    storedTerminalKishCount := 0.0
    storedTerminalConditionalMass := 0.0
    storedTerminalCenterShift := na
    storedTerminalLowerScale := na
    storedTerminalUpperScale := na
    storedTerminalStability := na
    storedConditioningSkill := na
    storedConditioningShrunkSkill := na
    storedConditioningSkillCount := 0
    storedConditioningSkillEffective := 0.0
    storedConditioningGate := 0.0
    storedTerminalBenchmarkValidationCount := 0
    storedTerminalBenchmarkValidationEffective := 0.0
    storedTerminalBenchmarkCoverage := na
    storedTerminalBenchmarkShrunkCoverage := na
    storedTerminalBenchmarkLowerCoverage := na
    storedTerminalBenchmarkUpperCoverage := na
    storedTerminalBenchmarkMedianNormalizedError := na
    storedTerminalBenchmarkDiagnostic := na
    storedTerminalCalibrationCount := 0
    storedTerminalCalibrationEffective := 0.0
    storedTerminalCalibrationFitShrinkage := 0.0
    storedTerminalCalibrationDiagnostic := na
    storedTerminalCalibrationGate := 0.0
    storedTerminalCalibrationValidationCount := 0
    storedTerminalCalibrationValidationEffective := 0.0
    storedTerminalCalibrationValidationCoverage := na
    storedTerminalCalibrationValidationShrunkCoverage := na
    storedTerminalCalibrationValidationMedianNormalizedError := na
    storedTerminalCalibrationValidationSkill := na
    storedTerminalCalibrationValidationShrunkSkill := na

    // Shared anchor horizons keep conditioning, calibration and the projected path aligned.
    array<int> modelHorizons = array.new_int()
    array<int> candidateAnchorMonths = array.from(1, 3, 6, 12, 18, 24)
    int candidateAnchorCount = array.size(candidateAnchorMonths)
    for candidateIndex = 0 to candidateAnchorCount - 1
        int anchorMonth = array.get(candidateAnchorMonths, candidateIndex)
        if anchorMonth <= monthsInHorizon
            int anchorHorizon = f_horizon_for_month(anchorMonth)
            if array.size(modelHorizons) == 0
                array.push(modelHorizons, anchorHorizon)
            else if anchorHorizon > array.get(modelHorizons, array.size(modelHorizons) - 1)
                array.push(modelHorizons, anchorHorizon)
    if array.size(modelHorizons) == 0
        array.push(modelHorizons, projectionHorizon)
    else if array.get(modelHorizons, array.size(modelHorizons) - 1) != projectionHorizon
        array.push(modelHorizons, projectionHorizon)

    array<float> conditioningGates = array.new_float()
    array<float> conditioningSkills = array.new_float()
    array<float> conditioningShrunkSkills = array.new_float()
    array<int> conditioningSkillCounts = array.new_int()
    array<float> conditioningSkillEffectiveCounts = array.new_float()

    array<int> benchmarkValidationCounts = array.new_int()
    array<float> benchmarkValidationEffectiveCounts = array.new_float()
    array<float> benchmarkCoverages = array.new_float()
    array<float> benchmarkShrunkCoverages = array.new_float()
    array<float> benchmarkLowerCoverages = array.new_float()
    array<float> benchmarkUpperCoverages = array.new_float()
    array<float> benchmarkMedianNormalizedErrors = array.new_float()
    array<float> benchmarkDiagnostics = array.new_float()

    array<float> calibrationBiases = array.new_float()
    array<float> calibrationLogLowerScales = array.new_float()
    array<float> calibrationLogUpperScales = array.new_float()
    array<int> calibrationCounts = array.new_int()
    array<float> calibrationEffectiveCounts = array.new_float()
    array<float> calibrationFitShrinkages = array.new_float()
    array<float> calibrationDiagnostics = array.new_float()
    array<float> calibrationGates = array.new_float()
    array<int> calibrationValidationCounts = array.new_int()
    array<float> calibrationValidationEffectiveCounts = array.new_float()
    array<float> calibrationValidationCoverages = array.new_float()
    array<float> calibrationValidationShrunkCoverages = array.new_float()
    array<float> calibrationValidationMedianErrors = array.new_float()
    array<float> calibrationValidationSkills = array.new_float()
    array<float> calibrationValidationShrunkSkills = array.new_float()

    int modelAnchorCount = array.size(modelHorizons)
    for anchorIndex = 0 to modelAnchorCount - 1
        int anchorHorizon = array.get(modelHorizons, anchorIndex)

        [rawSkill, shrunkSkill, skillCount, skillEffectiveCount, estimatedGate, historicalOriginGates, benchmarkValidationCount, benchmarkValidationEffective, benchmarkCoverage, benchmarkShrunkCoverage, benchmarkLowerCoverage, benchmarkUpperCoverage, benchmarkMedianNormalizedError, benchmarkDiagnostic] =
             f_conditioning_research(
                anchorHorizon,
                monthlyStride,
                useConditioning,
                useCalibration and useConditioning and adaptiveConditioning)

        float conditioningSkill = useConditioning ? rawSkill : na
        float conditioningShrunkSkill = useConditioning ? shrunkSkill : na
        int conditioningSkillCount = useConditioning ? skillCount : 0
        float conditioningSkillEffectiveCount = useConditioning ? skillEffectiveCount : 0.0
        float conditioningGate =
             useConditioning ?
             (adaptiveConditioning ? estimatedGate : 1.0) : 0.0

        array.push(conditioningGates, conditioningGate)
        array.push(conditioningSkills, conditioningSkill)
        array.push(conditioningShrunkSkills, conditioningShrunkSkill)
        array.push(conditioningSkillCounts, conditioningSkillCount)
        array.push(conditioningSkillEffectiveCounts, conditioningSkillEffectiveCount)

        array.push(benchmarkValidationCounts, benchmarkValidationCount)
        array.push(benchmarkValidationEffectiveCounts, benchmarkValidationEffective)
        array.push(benchmarkCoverages, benchmarkCoverage)
        array.push(benchmarkShrunkCoverages, benchmarkShrunkCoverage)
        array.push(benchmarkLowerCoverages, benchmarkLowerCoverage)
        array.push(benchmarkUpperCoverages, benchmarkUpperCoverage)
        array.push(benchmarkMedianNormalizedErrors, benchmarkMedianNormalizedError)
        array.push(benchmarkDiagnostics, benchmarkDiagnostic)

        float adjustedBias = 0.0
        float adjustedLogLowerScale = 0.0
        float adjustedLogUpperScale = 0.0
        int calibrationCount = 0
        float calibrationEffectiveCount = 0.0
        float calibrationFitShrinkage = 0.0
        float calibrationDiagnostic = na
        float calibrationGate = 0.0
        int calibrationValidationCount = 0
        float calibrationValidationEffectiveCount = 0.0
        float calibrationValidationCoverage = na
        float calibrationValidationShrunkCoverage = na
        float calibrationValidationMedianError = na
        float calibrationValidationSkill = na
        float calibrationValidationShrunkSkill = na

        if useCalibration
            [calBias, calLogLowerScale, calLogUpperScale, calCount, calEffective, calFitShrinkage, calDiagnostic, calGate, calValidationCount, calValidationEffective, calValidationCoverage, calValidationShrunkCoverage, calValidationMedianError, calValidationSkill, calValidationShrunkSkill] = f_calibration_parameters(
                anchorHorizon,
                monthlyStride,
                useConditioning,
                adaptiveConditioning,
                historicalOriginGates)

            // The fit is already shrunk toward no correction. The validation gate adds a
            // second, independent shrinkage toward no correction and is zero for non-positive skill.
            adjustedBias := calBias * calGate
            adjustedLogLowerScale := calLogLowerScale * calGate
            adjustedLogUpperScale := calLogUpperScale * calGate
            calibrationCount := calCount
            calibrationEffectiveCount := calEffective
            calibrationFitShrinkage := calFitShrinkage
            calibrationDiagnostic := calDiagnostic
            calibrationGate := calGate
            calibrationValidationCount := calValidationCount
            calibrationValidationEffectiveCount := calValidationEffective
            calibrationValidationCoverage := calValidationCoverage
            calibrationValidationShrunkCoverage := calValidationShrunkCoverage
            calibrationValidationMedianError := calValidationMedianError
            calibrationValidationSkill := calValidationSkill
            calibrationValidationShrunkSkill := calValidationShrunkSkill

        array.push(calibrationBiases, adjustedBias)
        array.push(calibrationLogLowerScales, adjustedLogLowerScale)
        array.push(calibrationLogUpperScales, adjustedLogUpperScale)
        array.push(calibrationCounts, calibrationCount)
        array.push(calibrationEffectiveCounts, calibrationEffectiveCount)
        array.push(calibrationFitShrinkages, calibrationFitShrinkage)
        array.push(calibrationDiagnostics, calibrationDiagnostic)
        array.push(calibrationGates, calibrationGate)
        array.push(calibrationValidationCounts, calibrationValidationCount)
        array.push(calibrationValidationEffectiveCounts, calibrationValidationEffectiveCount)
        array.push(calibrationValidationCoverages, calibrationValidationCoverage)
        array.push(calibrationValidationShrunkCoverages, calibrationValidationShrunkCoverage)
        array.push(calibrationValidationMedianErrors, calibrationValidationMedianError)
        array.push(calibrationValidationSkills, calibrationValidationSkill)
        array.push(calibrationValidationShrunkSkills, calibrationValidationShrunkSkill)

    bool completePath = true
    for monthNumber = 1 to monthsInHorizon
        int horizon = f_horizon_for_month(monthNumber)
        bool collectTerminalDiagnostics = monthNumber == monthsInHorizon
        float interpolatedConditioningGate =
             useConditioning ? f_interpolate(modelHorizons, conditioningGates, horizon, 0.0) : 0.0

        [rawQ10, rawQ50, rawQ90, globalQ10, globalQ50, globalQ90, rawCount, rawOverlapEffective, weightedBlockEffective, conditionalMass, kishCount, stabilityScore] = f_model_quantiles(
            horizon,
            monthlyStride,
            0,
            useConditioning,
            interpolatedConditioningGate,
            collectTerminalDiagnostics)

        bool available =
             rawCount >= MIN_RAW_SAMPLES and
             weightedBlockEffective >= MIN_WEIGHTED_EFFECTIVE_SAMPLES and
             not na(rawQ10) and not na(rawQ50) and not na(rawQ90)

        if completePath and available
            float interpolatedBias =
                 useCalibration ? f_interpolate(modelHorizons, calibrationBiases, horizon, 0.0) : 0.0
            float interpolatedLogLowerScale =
                 useCalibration ? f_interpolate(modelHorizons, calibrationLogLowerScales, horizon, 0.0) : 0.0
            float interpolatedLogUpperScale =
                 useCalibration ? f_interpolate(modelHorizons, calibrationLogUpperScales, horizon, 0.0) : 0.0
            float centralSpan = math.max(rawQ90 - rawQ10, 0.0)
            float centerShift = f_clamp(
                interpolatedBias,
                -MAX_CENTER_SHIFT_AS_SPAN * centralSpan,
                MAX_CENTER_SHIFT_AS_SPAN * centralSpan)
            float lowerScale = math.exp(interpolatedLogLowerScale)
            float upperScale = math.exp(interpolatedLogUpperScale)
            float calibratedQ50 = rawQ50 + centerShift
            float calibratedQ10 =
                 calibratedQ50 - math.max(rawQ50 - rawQ10, 0.0) * lowerScale
            float calibratedQ90 =
                 calibratedQ50 + math.max(rawQ90 - rawQ50, 0.0) * upperScale

            array.push(storedQ10ByMonth, calibratedQ10)
            array.push(storedQ50ByMonth, calibratedQ50)
            array.push(storedQ90ByMonth, calibratedQ90)

            if collectTerminalDiagnostics
                storedTerminalQ10 := calibratedQ10
                storedTerminalQ50 := calibratedQ50
                storedTerminalQ90 := calibratedQ90
                storedTerminalRawCount := rawCount
                storedTerminalRawOverlapEffective := rawOverlapEffective
                storedTerminalWeightedBlockEffective := weightedBlockEffective
                storedTerminalKishCount := kishCount
                storedTerminalConditionalMass := conditionalMass
                storedTerminalCenterShift := centerShift
                storedTerminalLowerScale := lowerScale
                storedTerminalUpperScale := upperScale
                storedTerminalStability := stabilityScore
        else
            completePath := false

    storedProjectionAvailable := (
        completePath and
        array.size(storedQ10ByMonth) == monthsInHorizon and
        array.size(storedQ50ByMonth) == monthsInHorizon and
        array.size(storedQ90ByMonth) == monthsInHorizon and
        not na(storedTerminalQ50))

    if not storedProjectionAvailable
        array.clear(storedQ10ByMonth)
        array.clear(storedQ50ByMonth)
        array.clear(storedQ90ByMonth)

    int terminalAnchorIndex = array.size(modelHorizons) - 1
    storedConditioningSkill := array.get(conditioningSkills, terminalAnchorIndex)
    storedConditioningShrunkSkill := array.get(conditioningShrunkSkills, terminalAnchorIndex)
    storedConditioningSkillCount := array.get(conditioningSkillCounts, terminalAnchorIndex)
    storedConditioningSkillEffective := array.get(conditioningSkillEffectiveCounts, terminalAnchorIndex)
    storedConditioningGate := array.get(conditioningGates, terminalAnchorIndex)

    storedTerminalBenchmarkValidationCount := array.get(benchmarkValidationCounts, terminalAnchorIndex)
    storedTerminalBenchmarkValidationEffective := array.get(benchmarkValidationEffectiveCounts, terminalAnchorIndex)
    storedTerminalBenchmarkCoverage := array.get(benchmarkCoverages, terminalAnchorIndex)
    storedTerminalBenchmarkShrunkCoverage := array.get(benchmarkShrunkCoverages, terminalAnchorIndex)
    storedTerminalBenchmarkLowerCoverage := array.get(benchmarkLowerCoverages, terminalAnchorIndex)
    storedTerminalBenchmarkUpperCoverage := array.get(benchmarkUpperCoverages, terminalAnchorIndex)
    storedTerminalBenchmarkMedianNormalizedError := array.get(benchmarkMedianNormalizedErrors, terminalAnchorIndex)
    storedTerminalBenchmarkDiagnostic := array.get(benchmarkDiagnostics, terminalAnchorIndex)

    storedTerminalCalibrationCount := array.get(calibrationCounts, terminalAnchorIndex)
    storedTerminalCalibrationEffective := array.get(calibrationEffectiveCounts, terminalAnchorIndex)
    storedTerminalCalibrationFitShrinkage := array.get(calibrationFitShrinkages, terminalAnchorIndex)
    storedTerminalCalibrationDiagnostic := array.get(calibrationDiagnostics, terminalAnchorIndex)
    storedTerminalCalibrationGate := array.get(calibrationGates, terminalAnchorIndex)
    storedTerminalCalibrationValidationCount := array.get(calibrationValidationCounts, terminalAnchorIndex)
    storedTerminalCalibrationValidationEffective := array.get(calibrationValidationEffectiveCounts, terminalAnchorIndex)
    storedTerminalCalibrationValidationCoverage := array.get(calibrationValidationCoverages, terminalAnchorIndex)
    storedTerminalCalibrationValidationShrunkCoverage := array.get(calibrationValidationShrunkCoverages, terminalAnchorIndex)
    storedTerminalCalibrationValidationMedianNormalizedError := array.get(calibrationValidationMedianErrors, terminalAnchorIndex)
    storedTerminalCalibrationValidationSkill := array.get(calibrationValidationSkills, terminalAnchorIndex)
    storedTerminalCalibrationValidationShrunkSkill := array.get(calibrationValidationShrunkSkills, terminalAnchorIndex)

// === Drawing and table rendering
if barstate.islast and supportedContext
    f_clear_drawings()

    bool liveAnchor = anchorModeInput == "Live price"
    float activeAnchorPrice = liveAnchor ? close : storedAnchorPrice
    int activeAnchorIndex = liveAnchor ? bar_index : storedAnchorIndex
    bool renderedProjectionAvailable =
         storedProjectionAvailable and
         not na(activeAnchorPrice) and activeAnchorPrice > 0.0 and
         not na(activeAnchorIndex) and
         array.size(storedQ10ByMonth) == monthsInHorizon and
         array.size(storedQ50ByMonth) == monthsInHorizon and
         array.size(storedQ90ByMonth) == monthsInHorizon

    if renderedProjectionAvailable
        array<chart.point> lowerPoints = array.new<chart.point>()
        array<chart.point> medianPoints = array.new<chart.point>()
        array<chart.point> upperPoints = array.new<chart.point>()
        array.push(lowerPoints, chart.point.from_index(activeAnchorIndex, activeAnchorPrice))
        array.push(medianPoints, chart.point.from_index(activeAnchorIndex, activeAnchorPrice))
        array.push(upperPoints, chart.point.from_index(activeAnchorIndex, activeAnchorPrice))

        for monthNumber = 1 to monthsInHorizon
            int storedIndex = monthNumber - 1
            int horizon = f_horizon_for_month(monthNumber)
            float lowerPrice =
                 f_price_from_log_return(activeAnchorPrice, array.get(storedQ10ByMonth, storedIndex))
            float medianPrice =
                 f_price_from_log_return(activeAnchorPrice, array.get(storedQ50ByMonth, storedIndex))
            float upperPrice =
                 f_price_from_log_return(activeAnchorPrice, array.get(storedQ90ByMonth, storedIndex))
            int futureIndex = activeAnchorIndex + horizon
            array.push(lowerPoints, chart.point.from_index(futureIndex, lowerPrice))
            array.push(medianPoints, chart.point.from_index(futureIndex, medianPrice))
            array.push(upperPoints, chart.point.from_index(futureIndex, upperPrice))

        color boundaryColor = color.new(projectionColor, deviationTransparency)
        array.push(
            projectionDrawings,
            polyline.new(
                lowerPoints,
                curved = false,
                closed = false,
                xloc = xloc.bar_index,
                line_color = boundaryColor,
                line_style = line.style_dashed,
                line_width = 1))
        array.push(
            projectionDrawings,
            polyline.new(
                upperPoints,
                curved = false,
                closed = false,
                xloc = xloc.bar_index,
                line_color = boundaryColor,
                line_style = line.style_dashed,
                line_width = 1))
        array.push(
            projectionDrawings,
            polyline.new(
                medianPoints,
                curved = false,
                closed = false,
                xloc = xloc.bar_index,
                line_color = projectionColor,
                line_style = line.style_solid,
                line_width = 3))

    if tableModeInput != "Off"
        int requiredRows = tableModeInput == "Detailed" ? 19 : 2
        bool recreateTable =
             na(summaryTable) or
             previousTablePosition != tablePositionInput or
             previousTableRows != requiredRows

        if recreateTable
            if not na(summaryTable)
                table.delete(summaryTable)
                summaryTable := na
            summaryTable := table.new(
                f_table_position(tablePositionInput),
                2,
                requiredRows,
                frame_color = color.new(projectionColor, 45),
                frame_width = 1)
            previousTablePosition := tablePositionInput
            previousTableRows := requiredRows
        else
            table.clear(summaryTable, 0, 0, 1, requiredRows - 1)

        float annualizedQ10 =
             renderedProjectionAvailable ?
             f_annualized_percent(storedTerminalQ10, projectionHorizon) : na
        float annualizedQ50 =
             renderedProjectionAvailable ?
             f_annualized_percent(storedTerminalQ50, projectionHorizon) : na
        float annualizedQ90 =
             renderedProjectionAvailable ?
             f_annualized_percent(storedTerminalQ90, projectionHorizon) : na
        float historyEvidence =
             renderedProjectionAvailable ?
             f_history_evidence(storedTerminalRawCount, storedTerminalWeightedBlockEffective) : na
        float dataAdequacy =
             renderedProjectionAvailable ?
             f_data_adequacy(
                storedTerminalRawCount,
                storedTerminalRawOverlapEffective,
                storedTerminalWeightedBlockEffective,
                storedTerminalStability) : na
        float benchmarkCalibration =
             renderedProjectionAvailable ? storedTerminalBenchmarkDiagnostic : na
        float validatedEnhancement =
             renderedProjectionAvailable ?
             f_validated_enhancement(
                storedConditioningShrunkSkill,
                storedConditioningSkillEffective,
                storedTerminalCalibrationValidationShrunkSkill,
                storedTerminalCalibrationValidationEffective,
                useConditioning and storedConditioningGate > EPSILON,
                useCalibration and storedTerminalCalibrationGate > EPSILON) : na
        float overallEvidence =
             renderedProjectionAvailable ?
             f_overall_evidence(
                dataAdequacy,
                benchmarkCalibration,
                validatedEnhancement,
                storedTerminalWeightedBlockEffective) : na

        string intervalText =
             f_signed_percent(annualizedQ10) + " to " + f_signed_percent(annualizedQ90)
        string chartTextSize = f_table_size(textSizeInput)
        color headerBackground = color.new(projectionColor, 78)
        color cellBackground = color.new(color.black, 72)
        color valueColor =
             na(annualizedQ50) ? color.silver :
             annualizedQ50 >= 0.0 ? color.rgb(71, 207, 137) : color.rgb(242, 100, 100)
        color evidenceColor = f_quality_color(overallEvidence)

        // Default mode: exactly two rows and no header.
        if tableModeInput == "Simple"
            table.cell(
                summaryTable, 0, 0, "Median annualized price return",
                text_color = color.silver, text_size = chartTextSize,
                bgcolor = cellBackground, text_halign = text.align_left)
            table.cell(
                summaryTable, 1, 0, f_signed_percent(annualizedQ50),
                text_color = valueColor, text_size = chartTextSize,
                bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(
                summaryTable, 0, 1, "Overall evidence score",
                text_color = color.silver, text_size = chartTextSize,
                bgcolor = cellBackground, text_halign = text.align_left)
            table.cell(
                summaryTable, 1, 1, f_quality_text(overallEvidence),
                text_color = evidenceColor, text_size = chartTextSize,
                bgcolor = cellBackground, text_halign = text.align_right)
        else
            string confirmedStatus =
                 liveAnchor and barstate.isrealtime and not barstate.isconfirmed ?
                 "Live price anchor · model frozen at last closed bar" :
                 "Confirmed statistical model"
            string tailCaution =
                 renderedProjectionAvailable and storedTerminalWeightedBlockEffective < 10.0 ?
                 " · tail estimates remain exploratory" : ""
            string statusText =
                 renderedProjectionAvailable ?
                 confirmedStatus + tailCaution :
                 "Not available · requires raw n≥" + str.tostring(MIN_RAW_SAMPLES) +
                 " and block-effective n≥" + f_number(MIN_WEIGHTED_EFFECTIVE_SAMPLES, "#")

            string effectiveEvidenceText =
                 renderedProjectionAvailable ?
                 "weighted temporal-block n≈" + f_number(storedTerminalWeightedBlockEffective, "#.1") +
                 " · display minimum " + f_number(MIN_WEIGHTED_EFFECTIVE_SAMPLES, "#") +
                 " · robust-tail target 10" : "N/A"

            string sampleStructureText =
                 renderedProjectionAvailable ?
                 "raw n=" + str.tostring(storedTerminalRawCount) +
                 " · overlap-only n≈" + f_number(storedTerminalRawOverlapEffective, "#.1") +
                 " · sample Kish n≈" + f_number(storedTerminalKishCount, "#.1") : "N/A"

            string stabilityText =
                 na(storedTerminalStability) ?
                 "Not enough history for four chronological blocks" :
                 f_quality_text(storedTerminalStability) + " · q10/q50/q90, width and asymmetry"

            string benchmarkValidationText =
                 na(storedTerminalBenchmarkDiagnostic) ?
                 "Insufficient completed forecasts for ordered benchmark validation" :
                 "n=" + str.tostring(storedTerminalBenchmarkValidationCount) +
                 " · effective≈" + f_number(storedTerminalBenchmarkValidationEffective, "#.1") +
                 " · q10–q90 coverage " +
                 f_number(100.0 * storedTerminalBenchmarkCoverage, "#") + "% raw / " +
                 f_number(100.0 * storedTerminalBenchmarkShrunkCoverage, "#") + "% prior-shrunk" +
                 " · q10/q90 one-sided " +
                 f_number(100.0 * storedTerminalBenchmarkLowerCoverage, "#") + "%/" +
                 f_number(100.0 * storedTerminalBenchmarkUpperCoverage, "#") + "%" +
                 " · median miss " +
                 f_number(storedTerminalBenchmarkMedianNormalizedError, "#.2") + "× side width" +
                 " · " + f_quality_text(storedTerminalBenchmarkDiagnostic)

            string enhancementText =
                 na(validatedEnhancement) ?
                 "None active · empirical benchmark retained" :
                 f_quality_text(validatedEnhancement) +
                 " · active positive-skill enhancements only"

            string conditioningSkillText =
                 not useConditioning ? "Disabled · unconditional empirical benchmark" :
                 na(storedConditioningSkill) ?
                 "Not enough completed forecasts for horizon-specific validation" :
                 f_signed_percent(100.0 * storedConditioningSkill) + " raw skill · " +
                 f_signed_percent(100.0 * storedConditioningShrunkSkill) + " shrunk · n=" +
                 str.tostring(storedConditioningSkillCount) + " · effective≈" +
                 f_number(storedConditioningSkillEffective, "#.1")

            string conditioningActionText =
                 not useConditioning ? "0% conditional mass" :
                 f_number(100.0 * storedTerminalConditionalMass, "#") +
                 "% final conditional mass · current horizon gate ×" +
                 f_number(storedConditioningGate, "#.2") +
                 (adaptiveConditioning ? " · historical gates nested by origin" : " · fixed full gate")

            string calibrationEvidenceText =
                 not useCalibration ? "Disabled" :
                 str.tostring(storedTerminalCalibrationCount) +
                 " completed forecasts · effective≈" +
                 f_number(storedTerminalCalibrationEffective, "#.1") +
                 " · fit shrinkage " +
                 f_number(100.0 * storedTerminalCalibrationFitShrinkage, "#") + "%"

            string calibrationValidationText =
                 not useCalibration ? "Not evaluated" :
                 na(storedTerminalCalibrationValidationSkill) ?
                 "Insufficient embargoed nested validation forecasts · correction gate 0" :
                 f_number(100.0 * storedTerminalCalibrationValidationCoverage, "#") +
                 "% raw coverage · " +
                 f_number(100.0 * storedTerminalCalibrationValidationShrunkCoverage, "#") +
                 "% prior-shrunk · median miss " +
                 f_number(storedTerminalCalibrationValidationMedianNormalizedError, "#.2") +
                 "× side width · skill " +
                 f_signed_percent(100.0 * storedTerminalCalibrationValidationSkill) +
                 " raw / " +
                 f_signed_percent(100.0 * storedTerminalCalibrationValidationShrunkSkill) +
                 " shrunk · validation effective≈" +
                 f_number(storedTerminalCalibrationValidationEffective, "#.1") +
                 " · validation score " + f_quality_text(storedTerminalCalibrationDiagnostic)

            string calibrationActionText =
                 not useCalibration ? "None · calibration disabled" :
                 storedTerminalCalibrationCount < MIN_CALIBRATION_ERRORS ?
                 "None · insufficient fit forecasts" :
                 storedTerminalCalibrationGate <= EPSILON ?
                 "None · no positive validated probabilistic skill" :
                 "validation gate ×" + f_number(storedTerminalCalibrationGate, "#.2") +
                 " · final applied strength≈" +
                 f_number(100.0 * storedTerminalCalibrationFitShrinkage * storedTerminalCalibrationGate, "#") + "%"

            string correctionText =
                 not useCalibration or storedTerminalCalibrationGate <= EPSILON or na(storedTerminalCenterShift) ?
                 "None · raw horizon-specific empirical projection retained" :
                 "median " + f_signed_percent(f_total_percent(storedTerminalCenterShift)) +
                 " total price return · lower ×" + f_number(storedTerminalLowerScale, "#.2") +
                 " · upper ×" + f_number(storedTerminalUpperScale, "#.2")

            string anchorText =
                 liveAnchor ?
                 "Live price " + str.tostring(activeAnchorPrice, format.mintick) +
                 " · distribution frozen until close" :
                 "Confirmed close " + str.tostring(activeAnchorPrice, format.mintick) +
                 " · bar index " + str.tostring(activeAnchorIndex)

            string methodText =
                 "Marginal horizon q10/q50/q90 · temporal-block n · historical conditioning guards · horizon-embargoed positive-skill calibration"

            string scopeText =
                 "Close-based price returns · broad equity indices/index-like instruments · not an 80% pathwise corridor"

            table.cell(summaryTable, 0, 0, "Projection status", text_color = projectionColor, text_size = chartTextSize, bgcolor = headerBackground)
            table.cell(summaryTable, 1, 0, statusText, text_color = projectionColor, text_size = chartTextSize, bgcolor = headerBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 1, "Median annualized price return", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 1, f_signed_percent(annualizedQ50), text_color = valueColor, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 2, "Annualized q10–q90 price-return range", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 2, intervalText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 3, "Overall evidence score (not a probability)", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 3, f_quality_text(overallEvidence), text_color = evidenceColor, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 4, "Data adequacy score", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 4, f_quality_text(dataAdequacy), text_color = f_quality_color(dataAdequacy), text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 5, "Unconditional benchmark validation", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 5, benchmarkValidationText, text_color = f_quality_color(benchmarkCalibration), text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 6, "Validated enhancement evidence", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 6, enhancementText, text_color = f_quality_color(validatedEnhancement), text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 7, "Historical evidence component", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 7, f_quality_text(historyEvidence), text_color = f_quality_color(historyEvidence), text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 8, "Weighted block-effective evidence", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 8, effectiveEvidenceText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 9, "Raw, overlap and Kish sample structure", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 9, sampleStructureText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 10, "Four-block distribution stability", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 10, stabilityText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 11, "Conditioning skill versus global benchmark", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 11, conditioningSkillText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 12, "Conditioning action", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 12, conditioningActionText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 13, "Calibration fit evidence", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 13, calibrationEvidenceText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 14, "Embargoed nested calibration validation", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 14, calibrationValidationText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 15, "Calibration action", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 15, calibrationActionText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 16, "Final asymmetric correction", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 16, correctionText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 17, "Projection anchor and method", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 17, anchorText + " · " + methodText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 18, "Scope", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 18, scopeText, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
    else
        if not na(summaryTable)
            table.delete(summaryTable)
            summaryTable := na
        previousTablePosition := ""
        previousTableRows := 0

// Unsupported timeframe rendering. Simple mode preserves the two default rows.
if barstate.islast and not supportedContext
    f_clear_drawings()
    if tableModeInput != "Off"
        int requiredRows = tableModeInput == "Detailed" ? 3 : 2
        bool recreateTable =
             na(summaryTable) or
             previousTablePosition != tablePositionInput or
             previousTableRows != requiredRows

        if recreateTable
            if not na(summaryTable)
                table.delete(summaryTable)
                summaryTable := na
            summaryTable := table.new(
                f_table_position(tablePositionInput),
                2,
                requiredRows,
                frame_color = color.new(projectionColor, 45),
                frame_width = 1)
            previousTablePosition := tablePositionInput
            previousTableRows := requiredRows
        else
            table.clear(summaryTable, 0, 0, 1, requiredRows - 1)

        string chartTextSize = f_table_size(textSizeInput)
        color warningBackground = color.new(color.orange, 82)
        color cellBackground = color.new(color.black, 72)

        if tableModeInput == "Simple"
            table.cell(summaryTable, 0, 0, "Median annualized price return", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 0, "N/A", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 1, "Overall evidence score", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 1, "Use standard 1D · 1W · 1M", text_color = color.orange, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
        else
            string unsupportedTitle = not supportedChartType ? "Chart type not supported" : "Timeframe not supported"
            string unsupportedValue = not supportedChartType ? "Use a standard chart" : "Current chart: " + timeframe.period
            string unsupportedReason =
                 not supportedChartType ?
                 "Synthetic and price-based bars invalidate the calendar horizon and overlap model" :
                 "Calendar mapping and block-overlap logic are frozen for standard daily, weekly and monthly bars"
            table.cell(summaryTable, 0, 0, unsupportedTitle, text_color = color.orange, text_size = chartTextSize, bgcolor = warningBackground)
            table.cell(summaryTable, 1, 0, unsupportedValue, text_color = color.orange, text_size = chartTextSize, bgcolor = warningBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 1, "Supported context", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 1, "Standard 1D · 1W · 1M", text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
            table.cell(summaryTable, 0, 2, "Reason", text_color = color.silver, text_size = chartTextSize, bgcolor = cellBackground)
            table.cell(summaryTable, 1, 2, unsupportedReason, text_color = color.white, text_size = chartTextSize, bgcolor = cellBackground, text_halign = text.align_right)
    else
        if not na(summaryTable)
            table.delete(summaryTable)
            summaryTable := na
        previousTablePosition := ""
        previousTableRows := 0
````
