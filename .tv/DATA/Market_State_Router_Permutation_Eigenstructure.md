<!-- tradingview-pine-id: PUB;5a8e61a38dc345acb1b0fc02db8a98fd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market State Router [Permutation + Eigenstructure]

Source: https://www.tradingview.com/script/UF3lTBqJ-Market-State-Router-Permutation-Eigenstructure/

## Description

MSR-PX is an experimental quantitative market-regime and systemic-pressure framework designed to classify the environment surrounding price rather than operate as a conventional buy/sell oscillator.

Instead of asking only whether price is rising or falling, MSR-PX evaluates several dimensions of market behavior:

[*]Is local price action ordered or disordered?
[*]Is movement directionally efficient or rotational?
[*]Are major cross-asset markets becoming systemically coordinated?
[*]Is the charted asset participating in the dominant market factor?
[*]Are local and systemic forces aligned or in conflict?
[*]Which market-state interpretation is most consistent with the current environment?

The result is a rule-based Market State Router that classifies conditions as Trend, Breakout, Mean Reversion, Event/Systemic Risk, No Trade, or Loading Data.

🧠 CORE ENGINE 1 — LOCAL PERMUTATION STRUCTURE

MSR-PX measures local price-order dynamics using normalized permutation entropy.

Default configuration:

[*]Embedding dimension: 4
[*]Ordinal patterns: 24
[*]Permutation lookback: 250 bars

Permutation entropy examines the ordering of consecutive price observations rather than simply measuring return magnitude.

Lower entropy indicates that a smaller subset of ordinal patterns is dominating recent behavior, suggesting greater local structure.

Higher entropy indicates that ordinal patterns are being expressed more uniformly, suggesting increasing disorder.

MSR-PX ranks this structural measurement against its recent historical baseline so the router can evaluate structure relative to the market's own recent behavior.

⚡ CORE ENGINE 2 — DIRECTIONAL EFFICIENCY

Directional efficiency compares:

Absolute net displacement

against

Total bar-to-bar travel

over the selected lookback.

This helps separate two environments that may have similar volatility but very different internal behavior:

[*]Price traveling efficiently in one direction
[*]Price covering substantial distance while repeatedly reversing and rotating

Higher efficiency supports directional Trend and Breakout states.

Lower efficiency supports rotational and Mean Reversion interpretations.

🌐 CORE ENGINE 3 — CROSS-ASSET EIGENSTRUCTURE

MSR-PX builds a rolling 5 × 5 cross-asset correlation system from synchronized observations of:

[*]The charted asset
[*]SPY — U.S. equity risk
[*]TLT — long-duration Treasury exposure
[*]DXY — U.S. dollar
[*]VIX — implied equity volatility

The benchmark symbols are configurable.

The cross-asset network updates only from synchronized observations, helping avoid partially populated correlation samples when benchmark data is unavailable.

MSR-PX then analyzes the matrix's eigenvalue spectrum to estimate how concentrated market behavior has become around a common factor.

Diagnostics include:

[*]Dominant eigenvalue share
[*]Spectral entropy
[*]Common-factor concentration
[*]Target loading on the dominant eigenvector

When the dominant eigenvalue becomes increasingly concentrated while spectral entropy contracts, the network is behaving more like a coordinated system and less like a collection of independent markets.

🌀 CORE ENGINE 4 — SYSTEMIC ABSORPTION

Systemic Absorption is an MSR-PX composite measure of cross-asset common-factor concentration.

It incorporates:

[*]Dominant eigenvalue concentration
[*]Inverse spectral entropy
[*]Historical percentile normalization

The resulting measurement is designed to distinguish between:

[*]Decoupled environments, where local price behavior dominates
[*]Systemically coupled environments, where a shared cross-asset factor is exerting greater control

The term Absorption here does not refer to traditional order-flow or liquidity absorption.

It specifically represents MSR-PX's estimate of systemic cross-asset concentration relative to its own historical baseline.

🎯 CORE ENGINE 5 — TARGET-ATTRIBUTED FACTOR DIRECTION

A strong systemic factor does not imply that every asset is responding to that factor in the same direction.

MSR-PX therefore adjusts the dominant factor impulse using the charted asset's loading magnitude and loading sign on the dominant eigenvector.

Conceptually:

Factor Impulse × Target Loading Strength × Target Loading Direction

This allows the router to distinguish between:

[*]A systemic factor becoming active
[*]The charted asset participating in that factor
[*]The charted asset responding inversely to that factor
[*]Local price action conflicting with the target-attributed systemic direction

This target attribution is used when evaluating directional alignment and systemic conflict.

🚦 THE MARKET STATE ROUTER

The individual engines feed a priority-based classification system.

The router does not simply select whichever condition produces the largest number. Certain environments intentionally take precedence over normal directional states.

1. EVENT / SYSTEMIC RISK

The highest-priority state.

Event/Systemic Risk requires elevated systemic concentration together with either:

[*]A sufficiently strong systemic factor impulse
[*]Meaningful conflict between local price direction and the target-attributed dominant factor

This state is intended to identify environments where broader cross-asset forces may be dominating normal local relationships.

When active, the router readout emphasizes reduced aggression rather than attempting to predict a specific directional trade.

2. BREAKOUT LONG / BREAKOUT SHORT

Breakout requires a stronger combination of:

[*]Ordered local structure
[*]Sufficient directional efficiency
[*]Systemic participation
[*]Strong directional impulse
[*]Agreement between local and target-attributed factor direction

Breakout represents the router's strongest coordinated directional state.

3. TREND LONG / TREND SHORT

Trend states identify directional environments characterized by:

[*]Ordered structure
[*]Sufficient directional efficiency
[*]Active local directional impulse
[*]Directional consistency with systemic forces when systemic concentration is elevated

Trend does not require the same degree of systemic impulse as Breakout.

4. MEAN REVERSION

Mean Reversion is favored when the environment shows a combination of:

[*]Disordered local structure
[*]Weak or decoupled systemic absorption
[*]Low directional efficiency

This describes an environment where rotational interpretation may be more appropriate than directional continuation.

5. NO TRADE / LOADING DATA

No Trade means the router does not find sufficient evidence for one of the primary states.

Loading Data appears while the historical buffers required for permutation structure, synchronized correlation, eigenstructure, and percentile calculations are still populating.

These are intentional router outputs rather than errors.

📊 HOW TO READ MSR-PX

TREND LONG / SHORT

Local structure and directional efficiency support continuation in the routed direction.

BREAKOUT LONG / SHORT

Local direction and systemic participation are strongly coordinated.

This is the router's strongest directional participation regime.

MEAN REVERSION

Directional efficiency is weak, structure is disordered, and systemic coupling is limited.

The environment is behaving more rotationally than directionally.

EVENT / SYSTEMIC RISK

Cross-asset concentration is elevated and systemic impulse or local/systemic conflict has become unusually strong.

Normal local relationships may be less reliable during this state.

NO TRADE

Conditions are mixed, ambiguous, or insufficient for a stronger classification.

📈 STATE SCORE

MSR-PX includes an internal State Score summarizing the strength of evidence supporting the active regime.

This score is not a calibrated probability.

For example:

An 86% State Score does not mean there is an 86% probability that a trade will succeed.

It should be interpreted only as an internal regime-strength measurement derived from the router's component conditions.

🧪 FORWARD VALIDATION LOGGER

MSR-PX includes a built-in forward transition logger for research purposes.

The logger tracks whether detected systemic fragility conditions subsequently transition into an Event / Systemic Risk state within a configurable forward horizon.

It records information including:

[*]Total fragility transitions
[*]Warnings that reached Event/Systemic Risk
[*]Warnings that expired without transition
[*]Transition rate
[*]Average transition time
[*]Age of the currently pending observation

This logger is a forward transition diagnostic.

It is not presented as a complete trading backtest, statistical significance test, or proof of predictive profitability.

⏱️ TIMEFRAME GUIDANCE

MSR-PX is designed primarily for intraday market-state analysis.

5 minutes is the recommended starting timeframe for the default configuration because it provides a practical balance between responsiveness and cross-asset regime stability.

[*]1 minute: Faster regime transitions and earlier sensitivity to changing conditions, with greater exposure to short-term noise.
[*]5 minutes: Recommended default for active intraday regime analysis.
[*]15 minutes: Slower and smoother regime context for traders who prefer less frequent state changes.

No timeframe should be interpreted as universally or statistically optimal.

Regime behavior should be evaluated independently for the market, session, and trading horizon being studied.

🌍 SESSION AND BENCHMARK CONSIDERATIONS

The default network uses U.S.-centric equity, rates, dollar, and volatility benchmarks.

When MSR-PX is applied to:

[*]Futures
[*]Cryptocurrency
[*]Overnight sessions
[*]International markets
[*]Assets trading outside U.S. cash-equity hours

users should consider both the trading schedules and economic relevance of the selected benchmark symbols.

Because the eigenstructure engine depends on synchronized observations, benchmark selection and session availability matter.

🔬 WHAT MSR-PX IS — AND IS NOT

MSR-PX is a market-state research and contextual framework.

It is not:

[*]A standalone buy/sell system
[*]A guaranteed market predictor
[*]A calibrated probability model
[*]A replacement for risk management
[*]A claim of statistically optimal thresholds

The state thresholds are currently rule-based rather than statistically learned.

The purpose of the project is to explore whether combining local ordinal structure, directional efficiency, cross-asset eigenstructure, systemic concentration, and target-specific factor attribution can provide useful context about the current market environment.

🔓 OPEN-SOURCE PHILOSOPHY

MSR-PX is published open source so the methodology can be inspected, challenged, modified, and independently tested.

The research question is whether combining:

[*]Permutation Structure
[*]Directional Efficiency
[*]Cross-Asset Eigenstructure
[*]Systemic Concentration
[*]Target-Specific Factor Attribution

provides useful market-state information beyond what any one component provides independently.

Users are encouraged to inspect the implementation, test different markets and timeframes, experiment with alternative benchmark networks, and evaluate the router's behavior independently.

⚠️ LIMITATIONS

Important limitations include:

[*]State thresholds are rule-based and are not claimed to be universally optimal.
[*]Correlation and eigenstructure measurements are backward-looking.
[*]Cross-asset relationships can change through time.
[*]Different trading sessions can produce uneven benchmark availability.
[*]Shorter timeframes can produce noisier regime transitions.
[*]State Score is an internal strength score, not a statistical probability.
[*]Historical behavior does not guarantee future behavior.
[*]Regime classification does not itself constitute a trading signal.

DISCLAIMER

This indicator is provided for educational, analytical, and research purposes only.

Nothing presented by MSR-PX constitutes financial, investment, or trading advice.

Users are responsible for independently evaluating the methodology and determining whether information produced by the indicator is appropriate for their own research or decision-making.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cheeseboard1991

//@version=6
// File: market_state_router_px.pine
// Author: @Cheeseboard1991
// Market State Router [Permutation + Eigenstructure]
// MSR-PX — Open-Source Quantitative Market-State Research Framework
indicator(
    "Market State Router [Permutation + Eigenstructure]",
    shorttitle = "MSR-PX",
    overlay = false,
    max_bars_back = 2500
)
// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_LOCAL = "1. Local structure"
string GROUP_CROSS = "2. Cross-asset universe"
string GROUP_EIGEN = "3. Eigenstructure"
string GROUP_ROUTER = "4. Router thresholds"
string GROUP_DISPLAY = "5. Display"
string GROUP_VALIDATION = "6. Transition tracking"
string GROUP_DIAGNOSTICS = "7. Eigenstructure diagnostics"

int permutationLookback = input.int(
    250,
    "Permutation lookback",
    minval = 120,
    maxval = 1000,
    group = GROUP_LOCAL,
    tooltip = "Number of ordinal patterns used to estimate normalized permutation entropy at embedding dimension 4 (24 patterns). Needs at least ~240 samples."
)
int permutationDelay = input.int(
    1,
    "Embedding delay",
    minval = 1,
    maxval = 20,
    group = GROUP_LOCAL,
    tooltip = "Spacing between the four observations in each ordinal pattern."
)
int efficiencyLookback = input.int(
    20,
    "Efficiency-ratio lookback",
    minval = 2,
    maxval = 300,
    group = GROUP_LOCAL
)
int impulseSmoothing = input.int(
    8,
    "Directional smoothing",
    minval = 1,
    maxval = 100,
    group = GROUP_LOCAL
)
int impulseVolatilityLookback = input.int(
    30,
    "Impulse normalization lookback",
    minval = 10,
    maxval = 300,
    group = GROUP_LOCAL
)

string symbol1 = input.symbol("AMEX:SPY", "Benchmark 1", group = GROUP_CROSS)
string symbol2 = input.symbol("NASDAQ:TLT", "Benchmark 2", group = GROUP_CROSS)
string symbol3 = input.symbol("TVC:DXY", "Benchmark 3", group = GROUP_CROSS)
string symbol4 = input.symbol("CBOE:VIX", "Benchmark 4", group = GROUP_CROSS)

int eigenLookback = input.int(
    80,
    "Correlation lookback",
    minval = 20,
    maxval = 500,
    group = GROUP_EIGEN
)

int percentileBaseline = input.int(
    500,
    "Percentile baseline",
    minval = 100,
    maxval = 2000,
    group = GROUP_ROUTER,
    tooltip = "Ordinal structure uses this many chart observations. Absorption uses this many synchronized five-asset observations. Thresholds are empirical percentiles, not absolute levels."
)
float deterministicMax = input.float(
    0.25,
    "Ordered structure percentile maximum",
    minval = 0.0,
    maxval = 1.0,
    step = 0.05,
    group = GROUP_ROUTER
)
float chaoticMin = input.float(
    0.75,
    "Disordered structure percentile minimum",
    minval = 0.0,
    maxval = 1.0,
    step = 0.05,
    group = GROUP_ROUTER
)
float minimumEfficiency = input.float(
    0.25,
    "Minimum trend efficiency",
    minval = 0.0,
    maxval = 1.0,
    step = 0.05,
    group = GROUP_ROUTER
)
float systemicMin = input.float(
    0.80,
    "Systemic absorption percentile minimum",
    minval = 0.0,
    maxval = 1.0,
    step = 0.05,
    group = GROUP_ROUTER
)
float decoupledMax = input.float(
    0.20,
    "Decoupled absorption percentile maximum",
    minval = 0.0,
    maxval = 1.0,
    step = 0.05,
    group = GROUP_ROUTER
)
float breakoutImpulseMin = input.float(
    0.35,
    "Breakout factor impulse minimum",
    minval = 0.0,
    maxval = 1.0,
    step = 0.05,
    group = GROUP_ROUTER
)
float eventImpulseMin = input.float(
    0.70,
    "Event-risk factor impulse minimum",
    minval = 0.0,
    maxval = 1.0,
    step = 0.05,
    group = GROUP_ROUTER
)
float directionDeadZone = input.float(
    0.10,
    "Direction dead zone",
    minval = 0.0,
    maxval = 0.50,
    step = 0.05,
    group = GROUP_ROUTER
)

bool showBackground = input.bool(true, "Color regime background", group = GROUP_DISPLAY)
bool showDashboard = input.bool(true, "Show dashboard", group = GROUP_DISPLAY)
bool showConfidence = input.bool(true, "Plot router state score", group = GROUP_DISPLAY)

int validationHorizon = input.int(
    12,
    "Fragility transition horizon",
    minval = 1,
    maxval = 500,
    group = GROUP_VALIDATION,
    tooltip = "Maximum confirmed bars allowed between a new systemic-fragility warning and the raw event-risk condition. Warnings that do not reach event risk within this window are counted as expired."
)

float diagnosticDegeneracyThreshold = input.float(
    0.05,
    "Relative leading eigengap threshold",
    minval = 0.001,
    maxval = 0.20,
    step = 0.001,
    group = GROUP_DIAGNOSTICS,
    tooltip = "Research-only flag. Near-degenerate when (largest eigenvalue - second-largest eigenvalue) / largest eigenvalue is below this value. This does not alter any router state."
)

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────
const int ASSET_COUNT = 5
const int STATE_LOADING = -1
const int STATE_NO_TRADE = 0
const int STATE_TREND = 1
const int STATE_BREAKOUT = 2
const int STATE_MEAN_REVERSION = 3
const int STATE_EVENT_RISK = 4
const int ORIENTATION_ANCHOR_ROW = 1

const color SUITE_BULL = color.rgb(33, 205, 154)
const color SUITE_BEAR = color.rgb(244, 89, 103)
const color SUITE_NEUTRAL = color.rgb(55, 191, 244)
const color SUITE_CONFLICT = color.rgb(225, 70, 255)
const color SUITE_WATCH = color.rgb(250, 204, 21)
const color SUITE_DARK = color.rgb(13, 18, 31)
const color SUITE_TEXT = color.rgb(229, 235, 244)
const color SUITE_MUTED = color.rgb(138, 151, 170)

// ─────────────────────────────────────────────────────────────────────────────
// Functions
// ─────────────────────────────────────────────────────────────────────────────
f_clamp(float value, float lowerBound, float upperBound) =>
    math.max(lowerBound, math.min(upperBound, value))

f_log_return() =>
    close > 0.0 and close[1] > 0.0 ? math.log(close / close[1]) : na

f_less(float leftValue, int leftIndex, float rightValue, int rightIndex) =>
    leftValue < rightValue or (leftValue == rightValue and leftIndex < rightIndex)

f_pattern4(float oldest, float second, float third, float newest) =>
    int state = na
    if not na(oldest) and not na(second) and not na(third) and not na(newest)
        int inversions0 = (
            (f_less(second, 1, oldest, 0) ? 1 : 0) +
            (f_less(third, 2, oldest, 0) ? 1 : 0) +
            (f_less(newest, 3, oldest, 0) ? 1 : 0)
        )
        int inversions1 = (
            (f_less(third, 2, second, 1) ? 1 : 0) +
            (f_less(newest, 3, second, 1) ? 1 : 0)
        )
        int inversions2 = f_less(newest, 3, third, 2) ? 1 : 0
        state := inversions0 * 6 + inversions1 * 2 + inversions2
    state

f_pattern_frequency(int pattern, int target, bool valid, int length) =>
    ta.sma(valid ? (pattern == target ? 1.0 : 0.0) : na, length)

f_entropy_term(float probability) =>
    if na(probability)
        na
    else
        float bounded = f_clamp(probability, 0.0, 1.0)
        bounded > 0.0 ? -bounded * math.log(bounded) : 0.0

f_push_bounded(array<float> values, float value, int maximumSize) =>
    array.push(values, value)
    if array.size(values) > maximumSize
        array.shift(values)
    0

f_array_correlation(array<float> leftValues, array<float> rightValues) =>
    float result = na
    if array.size(leftValues) == array.size(rightValues) and array.size(leftValues) > 1
        float leftDeviation = array.stdev(leftValues)
        float rightDeviation = array.stdev(rightValues)
        if (
            not na(leftDeviation) and
            not na(rightDeviation) and
            leftDeviation > 0.0 and
            rightDeviation > 0.0
        )
            result := (
                array.covariance(leftValues, rightValues) /
                (leftDeviation * rightDeviation)
            )
    result

f_array_standardize(float value, array<float> values) =>
    float result = na
    if not na(value) and array.size(values) > 1
        float mean = array.avg(values)
        float deviation = array.stdev(values)
        if not na(deviation) and deviation > 0.0
            result := (value - mean) / deviation
    result

f_set_symmetric(matrix<float> matrixId, int row, int column, float value) =>
    matrix.set(matrixId, row, column, value)
    matrix.set(matrixId, column, row, value)

f_normalized_impulse(float values, int smoothingLength, int volatilityLength) =>
    float smoothed = ta.ema(values, smoothingLength)
    float volatility = ta.stdev(values, volatilityLength)
    float scaled = na
    if not na(volatility) and volatility > 0.0
        scaled := smoothed * math.sqrt(smoothingLength) / volatility
    na(scaled) ? na : f_clamp(scaled, -1.0, 1.0)

f_direction(float normalizedImpulse, float deadZone) =>
    int direction = 0
    if not na(normalizedImpulse)
        direction := normalizedImpulse > deadZone ? 1 : normalizedImpulse < -deadZone ? -1 : 0
    direction

f_percent(float value) =>
    na(value) ? "—" : str.tostring(value * 100.0, "#.0") + "%"

f_signed(float value) =>
    string formattedValue = "—"
    if not na(value)
        formattedValue := (value > 0.0 ? "+" : "") + str.tostring(value, "#.00")
    formattedValue

f_state_color(int state) =>
    switch state
        STATE_TREND => color.new(SUITE_BULL, 95)
        STATE_BREAKOUT => color.new(SUITE_BULL, 93)
        STATE_MEAN_REVERSION => color.new(SUITE_NEUTRAL, 95)
        STATE_EVENT_RISK => color.new(SUITE_BEAR, 93)
        STATE_NO_TRADE => color.new(SUITE_MUTED, 97)
        => color.new(SUITE_MUTED, 98)

// ─────────────────────────────────────────────────────────────────────────────
// Transition tracking
// ─────────────────────────────────────────────────────────────────────────────
if barstate.isfirst
    if not chart.is_standard
        runtime.error("Use this indicator on standard charts only.")

    if deterministicMax >= chaoticMin
        runtime.error("Deterministic complexity maximum must be below chaotic complexity minimum.")
    if decoupledMax >= systemicMin
        runtime.error("Decoupled concentration maximum must be below systemic concentration minimum.")
    if breakoutImpulseMin > eventImpulseMin
        runtime.error("Breakout impulse minimum cannot exceed event-risk impulse minimum.")

    string chartSymbol = ticker.standard(syminfo.tickerid)
    string benchmark1Symbol = ticker.standard(symbol1)
    string benchmark2Symbol = ticker.standard(symbol2)
    string benchmark3Symbol = ticker.standard(symbol3)
    string benchmark4Symbol = ticker.standard(symbol4)

    bool chartDuplicatesBenchmark = (
        chartSymbol == benchmark1Symbol or
        chartSymbol == benchmark2Symbol or
        chartSymbol == benchmark3Symbol or
        chartSymbol == benchmark4Symbol
    )

    bool benchmarksContainDuplicates = (
        benchmark1Symbol == benchmark2Symbol or
        benchmark1Symbol == benchmark3Symbol or
        benchmark1Symbol == benchmark4Symbol or
        benchmark2Symbol == benchmark3Symbol or
        benchmark2Symbol == benchmark4Symbol or
        benchmark3Symbol == benchmark4Symbol
    )

    if chartDuplicatesBenchmark
        runtime.error("The chart symbol must be different from all benchmark symbols.")
    if benchmarksContainDuplicates
        runtime.error("All benchmark symbols must be unique.")

// ─────────────────────────────────────────────────────────────────────────────
// Local permutation entropy, embedding dimension d = 4 (24 ordinal patterns)
// ─────────────────────────────────────────────────────────────────────────────
float oldestValue = close[permutationDelay * 3]
float secondValue = close[permutationDelay * 2]
float thirdValue = close[permutationDelay]
float newestValue = close

int ordinalPattern = f_pattern4(oldestValue, secondValue, thirdValue, newestValue)
bool validPattern = not na(ordinalPattern)

float rawEntropy = 0.0
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 0, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 1, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 2, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 3, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 4, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 5, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 6, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 7, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 8, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 9, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 10, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 11, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 12, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 13, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 14, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 15, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 16, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 17, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 18, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 19, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 20, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 21, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 22, validPattern, permutationLookback))
rawEntropy += f_entropy_term(f_pattern_frequency(ordinalPattern, 23, validPattern, permutationLookback))

float maximumEntropy = math.log(24.0)
bool complexityReady = (
    bar_index >= permutationLookback + permutationDelay * 3 - 1 and
    not na(rawEntropy)
)

float permutationComplexity = na
if complexityReady
    permutationComplexity := f_clamp(rawEntropy / maximumEntropy, 0.0, 1.0)

float absoluteChange = math.abs(ta.change(close))
float pathLength = ta.sma(absoluteChange, efficiencyLookback) * efficiencyLookback
float displacement = math.abs(close - close[efficiencyLookback])
float efficiencyRatio = na
if not na(pathLength) and pathLength > 0.0
    efficiencyRatio := f_clamp(displacement / pathLength, 0.0, 1.0)

float targetReturn = f_log_return()
float localImpulse = f_normalized_impulse(
    targetReturn,
    impulseSmoothing,
    impulseVolatilityLookback
)

// ─────────────────────────────────────────────────────────────────────────────
// Cross-asset return network
//
// Requested returns use gaps_on so missing bars remain missing. The network only
// accepts rows where all five instruments provide a fresh return on the same
// chart bar. The rolling arrays therefore contain synchronized observations
// rather than forward-filled returns.
// ─────────────────────────────────────────────────────────────────────────────
float return1 = request.security(
    symbol1,
    timeframe.period,
    f_log_return(),
    gaps = barmerge.gaps_on,
    lookahead = barmerge.lookahead_off,
    ignore_invalid_symbol = true
)
float return2 = request.security(
    symbol2,
    timeframe.period,
    f_log_return(),
    gaps = barmerge.gaps_on,
    lookahead = barmerge.lookahead_off,
    ignore_invalid_symbol = true
)
float return3 = request.security(
    symbol3,
    timeframe.period,
    f_log_return(),
    gaps = barmerge.gaps_on,
    lookahead = barmerge.lookahead_off,
    ignore_invalid_symbol = true
)
float return4 = request.security(
    symbol4,
    timeframe.period,
    f_log_return(),
    gaps = barmerge.gaps_on,
    lookahead = barmerge.lookahead_off,
    ignore_invalid_symbol = true
)

bool completeObservation = (
    not na(targetReturn) and
    not na(return1) and
    not na(return2) and
    not na(return3) and
    not na(return4)
)

var array<float> targetReturnWindow = array.new<float>()
var array<float> return1Window = array.new<float>()
var array<float> return2Window = array.new<float>()
var array<float> return3Window = array.new<float>()
var array<float> return4Window = array.new<float>()

var int lastSynchronizedObservationBar = na

if completeObservation
    f_push_bounded(targetReturnWindow, targetReturn, eigenLookback)
    f_push_bounded(return1Window, return1, eigenLookback)
    f_push_bounded(return2Window, return2, eigenLookback)
    f_push_bounded(return3Window, return3, eigenLookback)
    f_push_bounded(return4Window, return4, eigenLookback)
    lastSynchronizedObservationBar := bar_index

int synchronizedSampleCount = array.size(targetReturnWindow)
bool synchronizedWindowReady = synchronizedSampleCount >= eigenLookback

float correlation01 = na
float correlation02 = na
float correlation03 = na
float correlation04 = na
float correlation12 = na
float correlation13 = na
float correlation14 = na
float correlation23 = na
float correlation24 = na
float correlation34 = na

if completeObservation and synchronizedWindowReady
    correlation01 := f_array_correlation(targetReturnWindow, return1Window)
    correlation02 := f_array_correlation(targetReturnWindow, return2Window)
    correlation03 := f_array_correlation(targetReturnWindow, return3Window)
    correlation04 := f_array_correlation(targetReturnWindow, return4Window)
    correlation12 := f_array_correlation(return1Window, return2Window)
    correlation13 := f_array_correlation(return1Window, return3Window)
    correlation14 := f_array_correlation(return1Window, return4Window)
    correlation23 := f_array_correlation(return2Window, return3Window)
    correlation24 := f_array_correlation(return2Window, return4Window)
    correlation34 := f_array_correlation(return3Window, return4Window)

bool networkUpdateReady = (
    completeObservation and
    synchronizedWindowReady and
    not na(correlation01) and
    not na(correlation02) and
    not na(correlation03) and
    not na(correlation04) and
    not na(correlation12) and
    not na(correlation13) and
    not na(correlation14) and
    not na(correlation23) and
    not na(correlation24) and
    not na(correlation34)
)

var matrix<float> correlationMatrix = matrix.new<float>(
    ASSET_COUNT,
    ASSET_COUNT,
    0.0
)

if barstate.isfirst
    for index = 0 to ASSET_COUNT - 1
        matrix.set(correlationMatrix, index, index, 1.0)

var bool eigenstructureReady = false
var float normalizedSpectralEntropy = na
var float dominantEigenShare = na
var float systemicConcentration = na
var float targetLoading = na
var float loading1 = na
var float loading2 = na
var float loading3 = na
var float loading4 = na
var int lastEigenstructureUpdateBar = na

// Research-only diagnostics. None of these values participate in routing.
var float diagnosticLeadingEigenvalue = na
var float diagnosticSecondEigenvalue = na
var float diagnosticRelativeEigengap = na
var bool diagnosticNearDegenerate = false
var float diagnosticAbsoluteTemporalOverlap = na
var float diagnosticAnchorLoadingAbs = na
var array<float> diagnosticPreviousDominantVector = array.new<float>(
    ASSET_COUNT,
    0.0
)
var bool diagnosticPreviousVectorReady = false
var int diagnosticEigenUpdateCount = 0
var int diagnosticNearDegenerateCount = 0

if networkUpdateReady
    f_set_symmetric(correlationMatrix, 0, 1, correlation01)
    f_set_symmetric(correlationMatrix, 0, 2, correlation02)
    f_set_symmetric(correlationMatrix, 0, 3, correlation03)
    f_set_symmetric(correlationMatrix, 0, 4, correlation04)
    f_set_symmetric(correlationMatrix, 1, 2, correlation12)
    f_set_symmetric(correlationMatrix, 1, 3, correlation13)
    f_set_symmetric(correlationMatrix, 1, 4, correlation14)
    f_set_symmetric(correlationMatrix, 2, 3, correlation23)
    f_set_symmetric(correlationMatrix, 2, 4, correlation24)
    f_set_symmetric(correlationMatrix, 3, 4, correlation34)

    array<float> currentEigenvalues = matrix.eigenvalues(correlationMatrix)
    matrix<float> currentEigenvectors = matrix.eigenvectors(correlationMatrix)

    int dominantIndex = 0
    float dominantEigenvalue = array.get(currentEigenvalues, 0)
    float eigenvalueTrace = 0.0

    for index = 0 to ASSET_COUNT - 1
        eigenvalueTrace += matrix.get(correlationMatrix, index, index)
        float eigenvalue = array.get(currentEigenvalues, index)
        if eigenvalue > dominantEigenvalue
            dominantEigenvalue := eigenvalue
            dominantIndex := index

    int secondaryIndex = dominantIndex == 0 ? 1 : 0
    float secondEigenvalue = array.get(currentEigenvalues, secondaryIndex)

    for index = 0 to ASSET_COUNT - 1
        if index != dominantIndex
            float eigenvalue = array.get(currentEigenvalues, index)
            if eigenvalue > secondEigenvalue
                secondEigenvalue := eigenvalue
                secondaryIndex := index

    diagnosticLeadingEigenvalue := dominantEigenvalue
    diagnosticSecondEigenvalue := secondEigenvalue
    diagnosticRelativeEigengap := na
    if dominantEigenvalue > 0.0
        diagnosticRelativeEigengap := (
            (dominantEigenvalue - secondEigenvalue) /
            dominantEigenvalue
        )
    diagnosticNearDegenerate := (
        not na(diagnosticRelativeEigengap) and
        diagnosticRelativeEigengap < diagnosticDegeneracyThreshold
    )

    float diagnosticDotProduct = 0.0
    float diagnosticCurrentNormSquared = 0.0
    float diagnosticPreviousNormSquared = 0.0

    for row = 0 to ASSET_COUNT - 1
        float currentWeight = matrix.get(
            currentEigenvectors,
            row,
            dominantIndex
        )
        float previousWeight = array.get(
            diagnosticPreviousDominantVector,
            row
        )
        diagnosticDotProduct += currentWeight * previousWeight
        diagnosticCurrentNormSquared += currentWeight * currentWeight
        diagnosticPreviousNormSquared += previousWeight * previousWeight

    diagnosticAbsoluteTemporalOverlap := na
    if (
        diagnosticPreviousVectorReady and
        diagnosticCurrentNormSquared > 0.0 and
        diagnosticPreviousNormSquared > 0.0
    )
        diagnosticAbsoluteTemporalOverlap := f_clamp(
            math.abs(diagnosticDotProduct) /
            math.sqrt(
                diagnosticCurrentNormSquared *
                diagnosticPreviousNormSquared
            ),
            0.0,
            1.0
        )

    for row = 0 to ASSET_COUNT - 1
        array.set(
            diagnosticPreviousDominantVector,
            row,
            matrix.get(currentEigenvectors, row, dominantIndex)
        )

    diagnosticPreviousVectorReady := true
    diagnosticEigenUpdateCount += 1
    if diagnosticNearDegenerate
        diagnosticNearDegenerateCount += 1

    float rawSpectralEntropy = 0.0

    if eigenvalueTrace > 0.0
        for index = 0 to ASSET_COUNT - 1
            float probability = (
                math.max(array.get(currentEigenvalues, index), 0.0) /
                eigenvalueTrace
            )
            if probability > 0.0
                rawSpectralEntropy -= probability * math.log(probability)

        float currentSpectralEntropy = f_clamp(
            rawSpectralEntropy / math.log(ASSET_COUNT),
            0.0,
            1.0
        )
        float currentDominantShare = f_clamp(
            math.max(dominantEigenvalue, 0.0) / eigenvalueTrace,
            0.0,
            1.0
        )
        float currentNormalizedDominantShare = f_clamp(
            (currentDominantShare - 1.0 / ASSET_COUNT) /
            (1.0 - 1.0 / ASSET_COUNT),
            0.0,
            1.0
        )

        float anchorRawLoading = matrix.get(
            currentEigenvectors,
            ORIENTATION_ANCHOR_ROW,
            dominantIndex
        )
        float orientation = anchorRawLoading < 0.0 ? -1.0 : 1.0
        diagnosticAnchorLoadingAbs := math.abs(anchorRawLoading)

        normalizedSpectralEntropy := currentSpectralEntropy
        dominantEigenShare := currentDominantShare
        systemicConcentration := (
            0.5 * currentNormalizedDominantShare +
            0.5 * (1.0 - currentSpectralEntropy)
        )
        targetLoading := (
            matrix.get(currentEigenvectors, 0, dominantIndex) *
            orientation
        )
        loading1 := (
            matrix.get(currentEigenvectors, 1, dominantIndex) *
            orientation
        )
        loading2 := (
            matrix.get(currentEigenvectors, 2, dominantIndex) *
            orientation
        )
        loading3 := (
            matrix.get(currentEigenvectors, 3, dominantIndex) *
            orientation
        )
        loading4 := (
            matrix.get(currentEigenvectors, 4, dominantIndex) *
            orientation
        )
        eigenstructureReady := true
        lastEigenstructureUpdateBar := bar_index

float synchronizedTargetReturn = completeObservation ? targetReturn : na
float synchronizedReturn1 = completeObservation ? return1 : na
float synchronizedReturn2 = completeObservation ? return2 : na
float synchronizedReturn3 = completeObservation ? return3 : na
float synchronizedReturn4 = completeObservation ? return4 : na

float targetReturnStandard = f_array_standardize(
    synchronizedTargetReturn,
    targetReturnWindow
)
float return1Standard = f_array_standardize(
    synchronizedReturn1,
    return1Window
)
float return2Standard = f_array_standardize(
    synchronizedReturn2,
    return2Window
)
float return3Standard = f_array_standardize(
    synchronizedReturn3,
    return3Window
)
float return4Standard = f_array_standardize(
    synchronizedReturn4,
    return4Window
)

float factorReturn = na
if networkUpdateReady and eigenstructureReady
    factorReturn := (
        targetLoading * targetReturnStandard +
        loading1 * return1Standard +
        loading2 * return2Standard +
        loading3 * return3Standard +
        loading4 * return4Standard
    )

float factorImpulseCandidate = f_normalized_impulse(
    factorReturn,
    impulseSmoothing,
    impulseVolatilityLookback
)

var float factorImpulse = na
if networkUpdateReady and not na(factorImpulseCandidate)
    factorImpulse := factorImpulseCandidate

float targetLoadingStrength = na
if eigenstructureReady
    targetLoadingStrength := f_clamp(
        math.abs(targetLoading) * math.sqrt(ASSET_COUNT),
        0.0,
        1.0
    )

float targetFactorImpulse = na
if not na(factorImpulse) and not na(targetLoading) and not na(targetLoadingStrength)
    float loadingDirection = targetLoading < 0.0 ? -1.0 : 1.0
    targetFactorImpulse := (
        factorImpulse *
        targetLoadingStrength *
        loadingDirection
    )

int synchronizedObservationAge = na
if not na(lastSynchronizedObservationBar)
    synchronizedObservationAge := bar_index - lastSynchronizedObservationBar

int eigenstructureAge = na
if not na(lastEigenstructureUpdateBar)
    eigenstructureAge := bar_index - lastEigenstructureUpdateBar

// ─────────────────────────────────────────────────────────────────────────────
// Empirical normalization of both axes
//
// Neither permutation entropy nor absorption occupies the 0-1 range in practice;
// both live in narrow, symbol- and timeframe-specific bands. Every router
// threshold is therefore expressed as a percentile of the instrument's own
// realized distribution over the baseline window rather than as an absolute level.
// ─────────────────────────────────────────────────────────────────────────────
float structurePercentile = ta.percentrank(
    permutationComplexity,
    percentileBaseline
) / 100.0

var array<float> systemicConcentrationBaselineWindow = array.new<float>()
var float absorptionPercentile = na

if networkUpdateReady and eigenstructureReady and not na(systemicConcentration)
    f_push_bounded(
        systemicConcentrationBaselineWindow,
        systemicConcentration,
        percentileBaseline
    )
    if array.size(systemicConcentrationBaselineWindow) >= percentileBaseline
        absorptionPercentile := (
            array.percentrank(
                systemicConcentrationBaselineWindow,
                array.size(systemicConcentrationBaselineWindow) - 1
            ) /
            100.0
        )

// ─────────────────────────────────────────────────────────────────────────────
// Market-state router
// ─────────────────────────────────────────────────────────────────────────────
int localDirection = f_direction(localImpulse, directionDeadZone)
int factorDirection = f_direction(
    targetFactorImpulse,
    directionDeadZone
)

bool directionsActive = localDirection != 0 and factorDirection != 0
bool directionAgreement = directionsActive and localDirection == factorDirection
bool directionConflict = directionsActive and localDirection != factorDirection

bool routerReady = (
    complexityReady and
    eigenstructureReady and
    not na(structurePercentile) and
    not na(absorptionPercentile) and
    not na(efficiencyRatio) and
    not na(localImpulse) and
    not na(factorImpulse) and
    not na(targetLoadingStrength)
)

bool deterministic = routerReady and structurePercentile <= deterministicMax
bool chaotic = routerReady and structurePercentile >= chaoticMin
bool systemic = routerReady and absorptionPercentile >= systemicMin
bool decoupled = routerReady and absorptionPercentile <= decoupledMax
bool efficient = routerReady and efficiencyRatio >= minimumEfficiency

float determinismScore = routerReady ? 1.0 - structurePercentile : na
float trendScore = na
if routerReady
    trendScore := (
        100.0 *
        determinismScore *
        efficiencyRatio *
        (systemic ? (directionAgreement ? 1.0 : 0.35) : 1.0)
    )
float breakoutScore = na
if routerReady
    breakoutScore := (
        100.0 *
        determinismScore *
        absorptionPercentile *
        math.abs(factorImpulse) *
        targetLoadingStrength *
        (directionAgreement ? 1.0 : 0.0)
    )
float meanReversionScore = na
if routerReady
    meanReversionScore := (
        100.0 *
        structurePercentile *
        (1.0 - absorptionPercentile) *
        (1.0 - efficiencyRatio)
    )
float eventRiskScore = na
if routerReady
    eventRiskScore := (
        100.0 *
        absorptionPercentile *
        math.max(math.abs(factorImpulse), directionConflict ? 1.0 : 0.0)
    )

bool breakoutState = (
    deterministic and
    systemic and
    efficient and
    directionAgreement and
    math.abs(factorImpulse) >= breakoutImpulseMin
)

bool trendState = (
    deterministic and
    efficient and
    localDirection != 0 and
    (not systemic or directionAgreement)
)

bool meanReversionState = (
    chaotic and
    decoupled and
    efficiencyRatio < minimumEfficiency
)

bool eventRiskState = (
    systemic and
    (
        directionConflict or
        math.abs(factorImpulse) >= eventImpulseMin
    )
)

bool fragilityWarningState = (
    systemic and
    not eventRiskState
)

int marketState = STATE_NO_TRADE

if not routerReady
    marketState := STATE_LOADING
else if eventRiskState
    marketState := STATE_EVENT_RISK
else if breakoutState
    marketState := STATE_BREAKOUT
else if trendState
    marketState := STATE_TREND
else if meanReversionState
    marketState := STATE_MEAN_REVERSION

float strongestCandidate = na
if routerReady
    strongestCandidate := math.max(
        math.max(trendScore, breakoutScore),
        math.max(meanReversionScore, eventRiskScore)
    )

float stateConfidence = switch marketState
    STATE_BREAKOUT => breakoutScore
    STATE_TREND => trendScore
    STATE_MEAN_REVERSION => meanReversionScore
    STATE_EVENT_RISK => eventRiskScore
    STATE_NO_TRADE => 100.0 - strongestCandidate
    => na

if not na(stateConfidence)
    stateConfidence := f_clamp(stateConfidence, 0.0, 100.0)

float combinedDirectionalImpulse = na
if routerReady
    combinedDirectionalImpulse := (
        (1.0 - absorptionPercentile) * localImpulse +
        absorptionPercentile * targetFactorImpulse
    )

int routedDirection = f_direction(combinedDirectionalImpulse, directionDeadZone)

string stateText = switch marketState
    STATE_BREAKOUT => routedDirection > 0 ? "BREAKOUT LONG" : "BREAKOUT SHORT"
    STATE_TREND => localDirection > 0 ? "TREND LONG" : "TREND SHORT"
    STATE_MEAN_REVERSION => "MEAN REVERSION"
    STATE_EVENT_RISK => "EVENT / SYSTEMIC RISK"
    STATE_NO_TRADE => "NO TRADE"
    => "LOADING DATA"

string agreementText = "Unclear"
if directionsActive
    agreementText := directionAgreement ? "Aligned" : "Conflict"

// ─────────────────────────────────────────────────────────────────────────────
// Fragility transition logger
// ─────────────────────────────────────────────────────────────────────────────
bool fragilityWarningStarted = (
    barstate.isconfirmed and
    fragilityWarningState and
    (bar_index == 0 or not fragilityWarningState[1])
)

var bool validationPending = false
var int validationStartBar = na
var int validationWarningCount = 0
var int validationConfirmedCount = 0
var int validationFalseCount = 0
var int validationLeadBarSum = 0
var int validationLastLeadBars = na

if barstate.isconfirmed
    if not validationPending and fragilityWarningStarted
        validationPending := true
        validationStartBar := bar_index
        validationWarningCount += 1

    if validationPending
        int pendingAge = bar_index - validationStartBar
        if eventRiskState
            validationConfirmedCount += 1
            validationLeadBarSum += pendingAge
            validationLastLeadBars := pendingAge
            validationPending := false
            validationStartBar := na
        else if pendingAge >= validationHorizon
            validationFalseCount += 1
            validationPending := false
            validationStartBar := na

int validationResolvedCount = validationConfirmedCount + validationFalseCount

float validationFalseRate = na
if validationResolvedCount > 0
    validationFalseRate := float(validationFalseCount) / float(validationResolvedCount)

float validationAverageLeadBars = na
if validationConfirmedCount > 0
    validationAverageLeadBars := float(validationLeadBarSum) / float(validationConfirmedCount)

int validationPendingAge = na
if validationPending
    validationPendingAge := bar_index - validationStartBar

int marketDirectionCode = switch marketState
    STATE_BREAKOUT => routedDirection
    STATE_TREND => localDirection
    => 0

float diagnosticNearDegenerateRate = na
if diagnosticEigenUpdateCount > 0
    diagnosticNearDegenerateRate := (
        100.0 *
        float(diagnosticNearDegenerateCount) /
        float(diagnosticEigenUpdateCount)
    )

string validationAverageLeadText = "—"
if not na(validationAverageLeadBars)
    validationAverageLeadText := (
        str.tostring(validationAverageLeadBars, "#.0") +
        " bars"
    )

string validationPendingAgeText = "—"
if validationPending
    validationPendingAgeText := (
        str.tostring(validationPendingAge) +
        " / " +
        str.tostring(validationHorizon) +
        " bars"
    )

// ─────────────────────────────────────────────────────────────────────────────
// Visuals
// ─────────────────────────────────────────────────────────────────────────────
color currentStateColor = f_state_color(marketState)

bgcolor(showBackground ? currentStateColor : na, title = "Market state")

plot(
    structurePercentile * 100.0,
    "Ordinal structure percentile",
    color = SUITE_WATCH,
    linewidth = 2
)
plot(
    absorptionPercentile * 100.0,
    "Absorption percentile",
    color = SUITE_CONFLICT,
    linewidth = 2
)
plot(
    routerReady ? 50.0 + combinedDirectionalImpulse * 50.0 : na,
    "Directional conviction",
    color = SUITE_NEUTRAL,
    linewidth = 2
)
plot(
    showConfidence ? stateConfidence : na,
    "Router state score",
    color = color.new(SUITE_TEXT, 35),
    style = plot.style_histogram,
    linewidth = 2
)

hline(50.0, "Directional neutral", color = color.new(SUITE_MUTED, 65))
hline(deterministicMax * 100.0, "Deterministic threshold", color = color.new(SUITE_BULL, 50))
hline(chaoticMin * 100.0, "Chaotic threshold", color = color.new(SUITE_WATCH, 50))
hline(systemicMin * 100.0, "Systemic threshold", color = color.new(SUITE_BEAR, 55))

plot(marketState, "Market state code", display = display.data_window)
plot(marketDirectionCode, "Market direction code", display = display.data_window)
plot(completeObservation ? 1.0 : 0.0, "Fresh synchronized observation", display = display.data_window)
plot(synchronizedSampleCount, "Synchronized network samples", display = display.data_window)
plot(array.size(systemicConcentrationBaselineWindow), "Synchronized absorption baseline samples", display = display.data_window)
plot(synchronizedObservationAge, "Synchronized observation age", display = display.data_window)
plot(eigenstructureAge, "Eigenstructure age", display = display.data_window)
plot(diagnosticLeadingEigenvalue, "Research: leading eigenvalue", display = display.data_window)
plot(diagnosticSecondEigenvalue, "Research: second eigenvalue", display = display.data_window)
plot(diagnosticRelativeEigengap, "Research: relative leading eigengap", display = display.data_window)
plot(diagnosticNearDegenerate ? 1.0 : 0.0, "Research: near-degenerate eigenstructure", display = display.data_window)
plot(diagnosticAbsoluteTemporalOverlap, "Research: absolute temporal eigenvector overlap", display = display.data_window)
plot(diagnosticAnchorLoadingAbs, "Research: anchor loading absolute value", display = display.data_window)
plot(diagnosticEigenUpdateCount, "Research: valid eigenstructure updates", display = display.data_window)
plot(diagnosticNearDegenerateCount, "Research: near-degenerate updates", display = display.data_window)
plot(
    diagnosticNearDegenerateRate,
    "Research: near-degenerate update rate",
    display = display.data_window
)
plot(permutationComplexity, "Normalized permutation entropy", display = display.data_window)
plot(systemicConcentration, "Systemic concentration", display = display.data_window)
plot(dominantEigenShare, "Dominant eigenvalue share", display = display.data_window)
plot(normalizedSpectralEntropy, "Normalized spectral entropy", display = display.data_window)
plot(targetLoading, "Target dominant-factor loading", display = display.data_window)
plot(localImpulse, "Local normalized impulse", display = display.data_window)
plot(factorImpulse, "Factor normalized impulse", display = display.data_window)
plot(efficiencyRatio, "Efficiency ratio", display = display.data_window)
plot(fragilityWarningState ? 1.0 : 0.0, "Systemic fragility warning", display = display.data_window)
plot(validationWarningCount, "Fragility warnings", display = display.data_window)
plot(validationConfirmedCount, "Warnings reaching event risk", display = display.data_window)
plot(validationFalseCount, "Expired fragility warnings", display = display.data_window)
plot(validationFalseRate * 100.0, "Fragility expiration rate", display = display.data_window)
plot(validationAverageLeadBars, "Average event-risk transition bars", display = display.data_window)
plot(validationLastLeadBars, "Last event-risk transition bars", display = display.data_window)

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(
    position.top_right,
    2,
    18,
    bgcolor = SUITE_DARK,
    border_width = 1,
    frame_color = color.rgb(105, 115, 130),
    frame_width = 1,
    border_color = color.rgb(55, 64, 76)
)

if barstate.islast and showDashboard
    color dashboardHeaderBg = color.rgb(47, 53, 65)
    color dashboardLabelBg = color.rgb(24, 29, 38)
    color dashboardValueBg = color.rgb(14, 18, 25)
    color dashboardLabelText = color.rgb(195, 205, 217)
    color dashboardValueText = SUITE_TEXT
    color dashboardStateText = marketState == STATE_TREND or marketState == STATE_BREAKOUT ? color.black : SUITE_TEXT

    table.cell(
        dashboard,
        0,
        0,
        "MARKET STATE ROUTER",
        text_color = color.white,
        bgcolor = dashboardHeaderBg,
        text_size = size.small
    )
    table.cell(
        dashboard,
        1,
        0,
        timeframe.period,
        text_color = color.white,
        bgcolor = dashboardHeaderBg,
        text_size = size.small
    )
    table.cell(dashboard, 0, 1, "State", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 1, stateText, text_color = dashboardStateText, bgcolor = color.new(currentStateColor, 0), text_size = size.small)
    table.cell(dashboard, 0, 2, "State score", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 2, na(stateConfidence) ? "—" : str.tostring(stateConfidence, "#.0") + "%", text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 3, "Structure pct", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 3, f_percent(structurePercentile), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 4, "Efficiency", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 4, f_percent(efficiencyRatio), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 5, "Absorption pct", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 5, f_percent(absorptionPercentile), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 6, "Eigen share", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 6, f_percent(dominantEigenShare), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 7, "Spectral entropy", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 7, f_percent(normalizedSpectralEntropy), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 8, "Target loading", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 8, f_signed(targetLoading), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 9, "Local impulse", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 9, f_signed(localImpulse), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 10, "Factor impulse", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 10, f_signed(factorImpulse), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 11, "Direction", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 11, agreementText, text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 12, "Fragility", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(
        dashboard,
        1,
        12,
        fragilityWarningState ? "WARNING" : "CLEAR",
        text_color = fragilityWarningState ? SUITE_WATCH : dashboardValueText,
        bgcolor = dashboardValueBg,
        text_size = size.small
    )
    table.cell(dashboard, 0, 13, "Transitions", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(
        dashboard,
        1,
        13,
        str.tostring(validationWarningCount) + " total / " +
        str.tostring(validationConfirmedCount) + " reached risk / " +
        str.tostring(validationFalseCount) + " expired",
        text_color = dashboardValueText,
        bgcolor = dashboardValueBg,
        text_size = size.small
    )
    table.cell(dashboard, 0, 14, "Expiry rate", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(dashboard, 1, 14, f_percent(validationFalseRate), text_color = dashboardValueText, bgcolor = dashboardValueBg, text_size = size.small)
    table.cell(dashboard, 0, 15, "Avg transition", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(
        dashboard,
        1,
        15,
        validationAverageLeadText,
        text_color = dashboardValueText,
        bgcolor = dashboardValueBg,
        text_size = size.small
    )
    table.cell(dashboard, 0, 16, "Pending age", text_color = dashboardLabelText, bgcolor = dashboardLabelBg, text_size = size.small)
    table.cell(
        dashboard,
        1,
        16,
        validationPendingAgeText,
        text_color = dashboardValueText,
        bgcolor = dashboardValueBg,
        text_size = size.small
    )

    string dashboardReadText = switch marketState
        STATE_LOADING => "Building baseline · wait"
        STATE_EVENT_RISK => "Systemic stress · reduce aggression"
        STATE_BREAKOUT => "Expansion active · favor continuation"
        STATE_TREND => "Trend active · favor pullbacks"
        STATE_MEAN_REVERSION => "Rotation regime · fade extremes"
        STATE_NO_TRADE => fragilityWarningState
             ? "Fragility rising · risk watch"
             : directionConflict
             ? "Signals conflict · stand aside"
             : "No dominant regime · wait"
        => "No clear interpretation"

    color dashboardReadColor = switch marketState
        STATE_EVENT_RISK => SUITE_BEAR
        STATE_BREAKOUT => SUITE_BULL
        STATE_TREND => SUITE_BULL
        STATE_MEAN_REVERSION => SUITE_NEUTRAL
        STATE_LOADING => SUITE_WATCH
        STATE_NO_TRADE => fragilityWarningState ? SUITE_WATCH : dashboardValueText
        => dashboardValueText

    table.cell(
        dashboard,
        0,
        17,
        "Read",
        text_color = dashboardLabelText,
        bgcolor = dashboardLabelBg,
        text_size = size.small
    )
    table.cell(
        dashboard,
        1,
        17,
        dashboardReadText,
        text_color = dashboardReadColor,
        bgcolor = dashboardValueBg,
        text_size = size.small
    )


// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────
bool stateChanged = (
    barstate.isconfirmed and
    bar_index > 0 and
    marketState != marketState[1]
)

alertcondition(
    fragilityWarningStarted,
    "Systemic fragility warning",
    "Market State Router detected elevated systemic fragility before event-risk confirmation."
)
alertcondition(
    stateChanged and marketState == STATE_BREAKOUT,
    "Breakout regime",
    "Market State Router entered a breakout regime."
)
alertcondition(
    stateChanged and marketState == STATE_TREND,
    "Trend regime",
    "Market State Router entered a trend-following regime."
)
alertcondition(
    stateChanged and marketState == STATE_MEAN_REVERSION,
    "Mean-reversion regime",
    "Market State Router entered a mean-reversion regime."
)
alertcondition(
    stateChanged and marketState == STATE_EVENT_RISK,
    "Event/systemic-risk regime",
    "Market State Router entered an event or systemic-risk regime."
)
alertcondition(
    stateChanged and marketState == STATE_NO_TRADE,
    "No-trade regime",
    "Market State Router entered a no-trade regime."
)
````
