<!-- tradingview-pine-id: PUB;9PnpNIeEXvIG22MVPcyMQxoMO9NQkT7a -->
<!-- tradingviewscripts-format: 1 -->
# Reflex & Trendflex

Source: https://www.tradingview.com/script/6tSfPE3W-Reflex-Trendflex/

## Description

█ OVERVIEW

Reflex and Trendflex are zero-lag oscillators that decompose price into independent cycle and trend components using SuperSmoother filtering. These indicators isolate each component separately, providing clearer identification of cyclical reversals (Reflex) versus trending movements (Trendflex).

Based on Dr. John F. Ehlers' "Reflex: A New Zero-Lag Indicator" article (February 2020, TASC), both oscillators use normalized slope deviation analysis to minimize lag while maintaining signal clarity. The SuperSmoother filter removes high-frequency noise, then deviations from linear regression (Reflex) or current value (Trendflex) are measured and normalized by RMS for consistent amplitude across instruments and timeframes.

█ CONCEPTS

SuperSmoother Filter
Both oscillators begin with a two-pole Butterworth low-pass filter that smooths price data without the excessive lag of simple moving averages. The filter uses exponential decay coefficients and cosine modulation based on the cutoff period, providing aggressive smoothing while preserving signal timing.

Reflex: Cycle Component
Reflex isolates cyclical price behavior by measuring deviation from a linear regression line fitted through the SuperSmoother output. For each bar, the filter calculates a linear slope over the lookback period, then sums how much the smoothed price deviates from this trendline. These deviations represent pure cyclical movement - price oscillations around the dominant trend. The result is normalized by RMS (root mean square) to produce consistent amplitude regardless of volatility or timeframe.

Trendflex: Trend Component
Trendflex extracts trending behavior by measuring cumulative deviation from the current SuperSmoother value. Instead of comparing to a regression line, it simply sums the differences between the current smoothed value and all past values in the period. This captures sustained directional movement rather than oscillations. Like Reflex, normalization by RMS ensures comparable readings across different instruments.

RMS Normalization
Both oscillators normalize their raw deviation measurements using an exponentially weighted RMS calculation: `rms = 0.04 * deviation² + 0.96 * rms[1]`. This adaptive normalization ensures the oscillator amplitude remains stable as volatility changes, making threshold levels meaningful across different market conditions.

█ INTERPRETATION

Reflex (Cycle Component)
Oscillates around zero representing cyclical price behavior isolated from trend:
 • Above zero: Price is in upward phase of cycle
 • Below zero: Price is in downward phase of cycle
 • Zero crossings: Potential cycle reversal points
 • Extremes: Indicate stretched cyclical condition, often precede mean reversion

Best used for identifying cyclical turning points in ranging or oscillating markets. More sensitive to reversals than Trendflex.

Trendflex (Trend Component)
Oscillates around zero representing trending behavior isolated from cycles:
 • Above zero: Sustained upward trend
 • Below zero: Sustained downward trend
 • Zero crossings: Trend direction changes
 • Magnitude: Strength of trend (larger absolute values = stronger trend)

Best used for confirming trend direction and identifying trend exhaustion. Less noisy than Reflex due to focus on directional movement rather than oscillations.

Combined Analysis
Using both oscillators together provides powerful signal confirmation:
 • Both positive: Strong uptrend with positive cycle phase (high probability long setup)
 • Both negative: Strong downtrend with negative cycle phase (high probability short setup)
 • Divergent signals: Conflicting cycle and trend (choppy conditions, reduce position size)
 • Reflex reversal with Trendflex agreement: Cyclical turn within established trend (entry/exit timing)

Dynamic Thresholds
Threshold bands identify statistically significant oscillator readings that warrant attention:
 • Breach above +threshold: Strong bullish cycle (Reflex) or trend (Trendflex) behavior - potential overbought condition
 • Breach below -threshold: Strong bearish cycle or trend behavior - potential oversold condition
 • Return inside thresholds: Signal strength normalizing, potential reversal or consolidation ahead
 • Threshold compression: During low volatility, thresholds narrow (especially with StdDev mode), making breaches more frequent
 • Threshold expansion: During high volatility, thresholds widen, filtering out minor oscillations

Combine threshold breaches with zero-line position for stronger signals:
 • Threshold breach + zero-line cross = high-conviction signal
 • Threshold breach without zero-line support = monitor for confirmation

Alert Conditions
Six built-in alerts trigger on bar close (no repainting):
 • Above +Threshold: Oscillator crossed above positive threshold (strong bullish behavior)
 • Below -Threshold: Oscillator crossed below negative threshold (strong bearish behavior)
 • Reflex Above Zero: Reflex crossed above zero (bullish cycle phase)
 • Reflex Below Zero: Reflex crossed below zero (bearish cycle phase)
 • Trendflex Above Zero: Trendflex crossed above zero (bullish trend shift)
 • Trendflex Below Zero: Trendflex crossed below zero (bearish trend shift)

█ SETTINGS & PARAMETER TUNING

Oscillator Settings
 • Source: Price series to decompose
 • Reflex Period (5-50): SuperSmoother period for cycle component. Lower values increase responsiveness to cyclical turns but add noise. Default 20.
 • Trendflex Period (5-50): SuperSmoother period for trend component. Lower values respond faster to trend changes. Default 20.

Display Settings
 • Reflex/Trendflex Display: Toggle visibility and customize colors for each oscillator independently
 • Zero Line: Reference line showing neutral oscillator position

Dynamic Thresholds
Optional significance bands that identify when oscillator readings indicate strong cyclical or trending behavior:
 • Threshold Mode: Choose calculation method based on market characteristics
   - MAD (Median Absolute Deviation): Outlier-resistant, best for markets with occasional spikes (default)
   - Standard Deviation: Volatility-sensitive, adapts quickly to regime changes
   - Percentile Rank: Fixed probability bands (e.g., 90% = only 10% of values exceed threshold)
 • Apply To: Select which oscillator (Reflex or Trendflex) to calculate thresholds for
 • Period (2-200): Lookback window for threshold calculation. Default 50.
 • Multiplier (k): Scaling factor for MAD/StdDev modes. Higher values = fewer threshold breaches (default 1.5)
 • Percentile (%): For Percentile mode only. Higher percentile = more selective threshold (default 90%)

Parameter Interactions
 • Shorter periods make both oscillators more sensitive but noisier
 • Reflex typically more volatile than Trendflex at same period settings
 • For ranging markets: shorter Reflex period (10-15) captures swings better
 • For trending markets: shorter Trendflex period (10-15) follows trend shifts faster

█ LIMITATIONS

Inherent Characteristics
 • Near-zero lag, not zero-lag: Despite the name, some lag remains from SuperSmoother filtering
 • Normalization artifacts: RMS normalization can produce unusual readings during volatility regime changes
 • Period dependency: Oscillator characteristics change significantly with different period settings - no "correct" universal parameter

Market Conditions to Avoid
 • Very low volatility: Normalization amplifies noise in quiet markets, producing false signals
 • Sudden gaps: SuperSmoother assumes continuous data; large gaps disrupt filter continuity requiring bars to stabilize
 • Micro timeframes: Sub-minute charts contain microstructure noise that overwhelms signal quality

Parameter Selection Pitfalls
 • Matching periods to dominant cycle: If period doesn't align with actual market cycle period, signals degrade
 • Threshold over-tuning: Optimizing threshold parameters for past data often fails forward - use conservative defaults
 • Ignoring component differences: Reflex and Trendflex measure different aspects - don't expect identical behavior

█ NOTES

Credits
These indicators are based on Dr. John F. Ehlers' "Reflex: A New Zero-Lag Indicator" published in the February 2020 issue of Technical Analysis of Stocks & Commodities (TASC) magazine. The article introduces a novel approach to isolating cycle and trend components using SuperSmoother filtering combined with normalized deviation analysis.

For those interested in the underlying mathematics and DSP concepts:
 • Ehlers, J.F. (February 2020). "Reflex: A New Zero-Lag Indicator" - Technical Analysis of Stocks & Commodities magazine
 • Ehlers, J.F. (2001). Rocket Science for Traders: Digital Signal Processing Applications. John Wiley & Sons
 • Various TASC articles by John Ehlers on SuperSmoother filters and oscillator design

by ♚@e2e4

---

## Source Code

````pine
//#region ———————————————————— Reflex & Trendflex

// @version=6
// ♚
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @author=@e2e4, for TradingView.com

// Reflex & Trendflex: Zero-lag oscillators that decompose price into cycle and trend components
// using SuperSmoother filtering with normalized slope deviation analysis
indicator('Reflex & Trendflex', 'xFlex', overlay = false, precision = 3)

//#endregion

//#region ———————————————————— Constants

// —————————— Math Constants
const float     TWO_PI                  = 2.0 * math.pi
const float     SQRT2_PI                = math.sqrt(2.0) * math.pi
const float     MAD_SCALE               = 0.6745

// —————————— Colors
const color     ReflexBlue              = #4A90E2
const color     TrendflexRed            = #E24A4A
const color     BullishGreen            = #4AE27A
const color     BearishRed              = #E24A4A
const color     NeutralGray             = #808080
const color     NeutralBlue             = #4DB8FF
const color     GoldenAmber             = #FFB340
const color     LimeGreen               = #A6FF4D

// —————————— Tooltips
const string    TT_source               = "Price series to decompose into cycle and trend components"
const string    TT_reflexPeriod         = "SuperSmoother period for Reflex cycle component. Lower = more responsive (5-50)"
const string    TT_trendflexPeriod      = "SuperSmoother period for Trendflex trend component. Lower = more responsive (5-50)"
const string    TT_dispReflex           = "Show/hide Reflex cycle component oscillator"
const string    TT_dispTrendflex        = "Show/hide Trendflex trend component oscillator"
const string    TT_zeroLine             = "Show/hide zero reference line"
const string    TT_showThreshold        = "Show/hide dynamic threshold bands for identifying significant oscillator behavior"
const string    TT_thresholdMode        = "MAD (outlier-resistant), Standard deviation (volatility-sensitive), or Percentile rank (fixed probability)"
const string    TT_thresholdSource      = "Which oscillator to calculate threshold for"
const string    TT_thresholdPeriod      = "Lookback period for threshold calculations (2-200)"
const string    TT_thresholdMultiplier  = "Scaling factor (k) for MAD/Standard deviation modes"
const string    TT_thresholdPercentile  = "Percentile of |oscillator| for threshold. E.g., 90% means only 10% of values exceed (0-100%)"

// —————————— Helpers
const string    GROUP_DIV               = "     ───────────────────────────────────────────     "

// —————————— Enums
// @enum        Threshold Calculation Modes 
//              MAD: Outlier-resistant using Median Absolute Deviation
//              Standard deviation: Volatility-sensitive using stdev
//              Percentile rank: Fixed probability bands based on historical distribution
enum thresholdMode
    mad         = "MAD"
    stdev       = "Standard Deviation"
    pctl        = "Percentile Rank"

// @enum        Oscillator Selection
//              Cycle component (Reflex) or Trend component (Trendflex)
enum osc
    cycle       = "Reflex"
    trend       = "Trendflex"

//#endregion

//#region ———————————————————— Inputs

const string    GROUP_MAIN          = '》 OSCILLATOR SETTINGS' + GROUP_DIV              // minval, maxval, step
float           source              = input.source(close,       'Source',                             tooltip = TT_source,             inline = '', group = GROUP_MAIN)
int             reflexPeriod        = input.int(20,             'Reflex Period',               5,    50,    1,  TT_reflexPeriod,                '',         GROUP_MAIN)
int             trendflexPeriod     = input.int(20,             'Trendflex Period      ', 5,   50,    1,   TT_trendflexPeriod,             '',         GROUP_MAIN)

const string    GROUP_DISP          = '》' + ' DISPLAY SETTINGS' + GROUP_DIV
bool            showReflex          = input.bool(true,          'Reflex (Cycle Component)             ',                              inline = 'DISP1', group = GROUP_DISP)
color           colorReflex         = input.color(ReflexBlue,   '',                                             TT_dispReflex,             'DISP1',         GROUP_DISP, active = showReflex)
bool            showTrendflex       = input.bool(true,          'Trendflex (Trend Component)    ',                              inline = 'DISP2', group = GROUP_DISP)
color           colorTrendflex      = input.color(TrendflexRed, '',                                             TT_dispTrendflex,          'DISP2',         GROUP_DISP, active = showTrendflex)
bool            showZeroLine        = input.bool(true,          'Zero Line              ',                                inline = 'DISP3', group = GROUP_DISP)
color           colorZeroLine       = input.color(NeutralBlue,  '',                                             TT_zeroLine,               'DISP3',         GROUP_DISP, active = showZeroLine)

const string    GROUP_DIAG          = '》 DIAGNOSTICS' + GROUP_DIV
bool            showThreshold       = input.bool(true,          'Dynamic Threshold         ',                    TT_showThreshold,          'DIAG1',         GROUP_DIAG)
color           colorThresholdTop   = input.color(GoldenAmber,  '',                                                               inline = 'DIAG1', group = GROUP_DIAG, active = showThreshold)
color           colorThresholdBottom= input.color(LimeGreen,    '',                                                               inline = 'DIAG1', group = GROUP_DIAG, active = showThreshold)
thresholdMode   thresholdModeInput  = input.enum(thresholdMode.mad, 'Threshold mode',                 tooltip = TT_thresholdMode,      inline = '', group = GROUP_DIAG, active = showThreshold)
osc             thresholdSource     = input.enum(osc.cycle,     'Apply to',                           tooltip = TT_thresholdSource,    inline = '', group = GROUP_DIAG, active = showThreshold)
int             thresholdPeriod     = input.int(50,             'Period',                     2,   200,    1,   TT_thresholdPeriod,             '',         GROUP_DIAG, active = showThreshold)
float           thresholdMultiplier = input.float(1.5,          'Multiplier (k)',           0.0,   5.0,  0.1,   TT_thresholdMultiplier,         '',         GROUP_DIAG, active = showThreshold and thresholdModeInput != thresholdMode.pctl)
float           thresholdPercentile = input.float(90.0,         'Percentile (%)',           0.0, 100.0,  0.5,   TT_thresholdPercentile,         '',         GROUP_DIAG, active = showThreshold and thresholdModeInput == thresholdMode.pctl)

//#endregion

//#region ———————————————————— Functions

// @function        Median Absolute Deviation (MAD)
//                  Robust, outlier-resistant dispersion measure.
//                  Fast approximation: MAD ≈ 0.6745 × stdev for normal distributions
// @param source    Input series
// @param period    Lookback period
// @returns         Approximated MAD value
mad(series float source, int period) => MAD_SCALE * ta.stdev(source, period)


// @function    Dynamic Threshold Calculator
//              Identifies significant signal deviation using three methods:
//              • MAD: Outlier-resistant threshold based on Median Absolute Deviation (multiplier * MAD)
//              • Standard Deviation: Volatility-sensitive threshold based on Standard Deviation (multiplier * stdev)
//              • Percentile Rank: Fixed probability threshold based on Percentile Rank
// @param source        Oscillator series
// @param mode          thresholdMode enum: mad, stdev, or pctl
// @param period        Lookback period
// @param multiplier    Scaling factor for MAD/Standard Deviation (unused for Percentile)
// @param percentile    Percentile value 0-100 (Percentile Rank mode only)
// @returns Threshold value for identifying significant oscillator behavior
threshold(series float source, thresholdMode mode, int period, float multiplier, float percentile) =>
    switch mode
        thresholdMode.mad   => multiplier * mad(source, period)
        thresholdMode.stdev => multiplier * ta.stdev(source, period)
        thresholdMode.pctl  => ta.percentile_nearest_rank(math.abs(source), period, percentile)
        => runtime.error("Unknown threshold mode: " + str.tostring(mode)), float(na)


// @function    RMS Normalization
//              Exponentially weighted root mean square normalization for consistent oscillator amplitude.
//              Uses 0.04/0.96 weighting for adaptive response to volatility changes.
// @param value     Current deviation value to normalize
// @param prevRms   Previous RMS state
// @returns Normalized value with consistent amplitude
normalize(float value) =>
    var float   rmsEnergy   = 0.0, rmsEnergy := 0.04 * value * value + 0.96 * nz(rmsEnergy[1])
    float       normalized  = value / math.sqrt(rmsEnergy)
    normalized


// @function    SuperSmoother - Ehlers' two-pole Butterworth low-pass filter
//              Reference: "Cybernetic Analysis for Stocks and Futures" (Ehlers, 2004)
// @param source    Input price series
// @param period    Cutoff period (higher = more smoothing)
// @returns         Filtered series with reduced high-frequency noise
superSmoother(series float source, int period) =>
    // Two-pole Butterworth coefficients
    var float decayFactor   = math.exp(-SQRT2_PI / (0.5 * period))
    var float freqResponse  = math.cos( SQRT2_PI / (0.5 * period))
    // Feedback coefficients (recursive part) & Input coefficient (feedforward) — average current and previous input
    var float coefF1        = 2.0 * decayFactor * freqResponse
    var float coefF2        = -decayFactor * decayFactor
    var float coefI         = (1.0 - coefF1 - coefF2) / 2.0
    // Apply filter: coefI * (current + previous input) + coefF1 * previous output + coefF2 * output before that
    var float ssf           = 0.0, ssf := coefI * (nz(source) + nz(source[1])) + coefF1 * nz(ssf[1]) + coefF2 * nz(ssf[2])
    ssf


// @function    Reflex — cycle component oscillator (O(1) incremental calculation)
//              Measures deviation from linear regression slope of SuperSmoothed price
// @param source    Price series
// @param period    SuperSmoother period (lower = more responsive to cycles)
// @returns Normalized cycle component oscillator
reflex(series float source, int period) =>
    float       smoothed    = superSmoother(source, period)
    float       slope       = (smoothed[period] - smoothed) / period
    // O(1) incremental sum replaces loop: Σ(smoothed + i*slope - smoothed[i]) for i=1..period
    var float   sumSmoothed = 0.0, sumSmoothed := sumSmoothed + nz(smoothed[1]) - nz(smoothed[period + 1])
    float       sumIndices  = period * (period + 1) / 2.0
    float       sumDev      = period * smoothed + slope * sumIndices - sumSmoothed
    float       avgDev      = sumDev / period
    float       reflex      = normalize(avgDev)
    reflex


// @function    Trendflex — trend component oscillator (O(1) incremental calculation)
//              Measures cumulative deviation from current SuperSmoothed value
// @param source    Price series
// @param period    SuperSmoother period (lower = more responsive to trends)
// @returns Normalized trend component oscillator
trendflex(series float source, int period) =>
    float       smoothed    = superSmoother(source, period)
    // O(1) incremental sum replaces loop: Σ(smoothed - smoothed[i]) for i=1..period
    var float   sumSmoothed = 0.0, sumSmoothed := sumSmoothed + nz(smoothed[1]) - nz(smoothed[period + 1])
    float       sumDev      = period * smoothed - sumSmoothed
    float       avgDev      = sumDev / period
    float       trendflex   = normalize(avgDev)
    trendflex

//#endregion

//#region ———————————————————— Calculations

// Calculate oscillators
float reflexValue      = showReflex    ? reflex(source, reflexPeriod)    : na
float trendflexValue   = showTrendflex ? trendflex(source, trendflexPeriod) : na
// Calculate threshold
float thresholdOsc     = thresholdSource == osc.cycle ? reflexValue : trendflexValue
float thresholdValue   = showThreshold ? threshold(thresholdOsc, thresholdModeInput, thresholdPeriod, thresholdMultiplier, thresholdPercentile) : float(na)

//#endregion

//#region ———————————————————— Plots

// Main oscillator plots
plot(showReflex     ? reflexValue      : float(na), 'Reflex',       colorReflex,            2, display = showReflex    ? display.all : display.none)
plot(showTrendflex  ? trendflexValue   : float(na), 'Trendflex',    colorTrendflex,         2, display = showTrendflex ? display.all : display.none)
hline(showZeroLine  ? 0                : float(na), 'Zero',         colorZeroLine,             display = showZeroLine  ? display.all : display.none)

plot(showThreshold  ?  thresholdValue  : float(na), 'Threshold +',  colorThresholdTop,         display = showThreshold ? display.all : display.none)
plot(showThreshold  ? -thresholdValue  : float(na), 'Threshold -',  colorThresholdBottom,      display = showThreshold ? display.all : display.none)

//#endregion

//#region ———————————————————— Alerts

// Alert conditions: threshold breaches and zero-line crossings
var string ALERT_GROUP = "Reflex & Trendflex"
bool crossedAboveThreshold = showThreshold and ta.crossover(thresholdOsc, thresholdValue)
bool crossedBelowThreshold = showThreshold and ta.crossunder(thresholdOsc, -thresholdValue)
bool reflexAboveZero       = ta.crossover(reflexValue, 0)
bool reflexBelowZero       = ta.crossunder(reflexValue, 0)
bool trendflexAboveZero    = ta.crossover(trendflexValue, 0)
bool trendflexBelowZero    = ta.crossunder(trendflexValue, 0)

alertcondition(crossedAboveThreshold, ALERT_GROUP + ": Above +Threshold", "xFlex: oscillator crossed above +threshold")
alertcondition(crossedBelowThreshold, ALERT_GROUP + ": Below -Threshold", "xFlex: oscillator crossed below -threshold")
alertcondition(reflexAboveZero,       ALERT_GROUP + ": Reflex Above Zero", "xFlex: Reflex crossed above zero")
alertcondition(reflexBelowZero,       ALERT_GROUP + ": Reflex Below Zero", "xFlex: Reflex crossed below zero")
alertcondition(trendflexAboveZero,    ALERT_GROUP + ": Trendflex Above Zero", "xFlex: Trendflex crossed above zero")
alertcondition(trendflexBelowZero,    ALERT_GROUP + ": Trendflex Below Zero", "xFlex: Trendflex crossed below zero")

//#endregion
````
