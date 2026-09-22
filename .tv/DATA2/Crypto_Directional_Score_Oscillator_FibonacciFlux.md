<!-- tradingview-pine-id: PUB;449c029c1cc34bfdbf666313db2a75ee -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Crypto Directional Score Oscillator [FibonacciFlux]

Source: https://www.tradingview.com/script/docbGUUG-Crypto-Directional-Score-Oscillator-FibonacciFlux/

## Description

A causal OHLCV direction score for crypto with a fixed-coefficient mode and two Bayesian-regime modes - published with measurements showing that the default mode ranks outcomes only weakly, that its percentages are not probabilities, and that the two Bayesian modes do not rank outcomes at all.

This plots an Up score and a Down score from 0 to 100 against a threshold. Neither is a chance of anything. It was saved as "Crypto Directional Probability Oscillator" and renamed before publishing, because the measurements below show the number is not a probability.

🔶 USAGE

In Fixed mode the oscillator blends five features of the current bar - trend, momentum, mean reversion, volume-weighted close location and path efficiency - into a logistic score from 0 to 100; the Bayesian modes add a volatility-regime input. Markers print where the score crosses a threshold. Read it as a compact summary of which features dominate right now. Do not read it as a forecast: its best measured ranking ability is an AUC of 0.55, before any trading cost, and its markers do not beat chance.

🔹 Reading the pane

[*]Up score, teal, and Down score, red, are mirror images: the Down score is 100 minus the Up score. They are one number drawn twice.
[*]The grey guides sit at the threshold, at 50, and at 100 minus the threshold.
[*]A marker prints on a confirmed bar when either line crosses up through the threshold. Every marker sits on the upper guide, bearish ones included, because a bearish marker is the red Down score crossing up through it; nothing prints at the lower guide. C means efficiency is at or above the Trend Regime Threshold and trend agrees in sign; R is every other crossing.
[*]The table, bottom right: the active mode; what the number is and its measured AUC range; in the Bayesian modes the dominant regime and its posterior; in Bayesian + Adaptive the number of scored samples each expert holds (weights apply from 12); and a warning when volume is missing or the timeframe is outside 1h-4h.
[*]In the Bayesian modes the Data Window also lists the four regime posteriors (Bull, Bear, Range, Stress) in percent.

🔹 The modes have opposite signs
A HIGH Fixed reading means price below its fast EMA with negative momentum - a dip-buy read. A high reading in either Bayesian mode means an established uptrend above it - a continuation read. Across all four symbol-timeframe pairs, the Up score correlates +0.51 to +0.60 with mean reversion and -0.09 to +0.02 with trend in Fixed, against -0.46 to -0.41 and +0.78 to +0.81 in both Bayesian modes. Switching the dropdown reverses what a high number means.

🔹 Warm-up and repainting
Fixed needs 55 bars and the Bayesian modes 64 - about 2.3 and 2.7 days on 1h, 9 and 11 days on 4h. Adaptive weights go live after roughly 150-160 bars; the exact count depends on where the chart's history starts, because adaptation samples every eighth bar by timestamp. The lines move while a bar is open. The regime filter, the adaptation and every marker update on confirmed bars only, so historical markers do not repaint.

🔶 DETAILS

🔹 The mechanism
Fixed mode, every coefficient asserted rather than estimated:
[pine]logit = 1.6 * (eff * (0.55*trend + 0.30*momentum) + (1 - eff) * 0.65*meanRev + 0.25*flow)
pUp   = 1 / (1 + exp(-logit))[/pine]
The Bayesian modes run a four-state filter (Bull, Bear, Range, Stress) with Student-t likelihoods and gate four expert logits by the posterior. Two constants flip the sign, and only together: the gate gives mean reversion 0.05 of the weight under a Bull or Bear posterior (0.55 under Range), and a 0.90 * (pBull - pBear) term adds a directional-state signal driven mostly by trend. Changing either alone leaves the mean-reversion correlation at -0.21 to -0.29; changing both turns it to +0.44 to +0.49. None of the roughly 80 constants in the file was fitted to data.

🔹 Measured result
Binance BTCUSDT and ETHUSDT, 1h (21,567 bars per symbol) and 4h (5,392 per symbol), 2024-04-01 to 2026-09-16. The code attaches no forward horizon to the score, so outcomes were scored at 1, 8 and 24 bars: 12 cells per mode. Nulls are circular shifts of the outcome series, seeded, with the observed statistic pooled into the draws.

[*]Fixed ranks outcomes, weakly. AUC 0.509 to 0.550, above 0.5 in 12 of 12 cells, significant in 8 (400 draws), family-wise p 0.027 - but the 12 cells are not independent: they share three overlapping horizons and two nested timeframes, and BTCUSDT and ETHUSDT log returns correlate 0.82. Uneven: 6 of 6 ETHUSDT cells, 2 of 3 BTCUSDT 1h, 0 of 3 BTCUSDT 4h (p 0.24-0.63).
[*]Its percentages overstate that by roughly 4 to 24 times. At 8 bars the top Fixed decile (mean printed 63.0-63.7) rose 50.7-52.5% of the time; the bottom decile (36.9-37.5) rose 44.1-49.5%. A printed spread of about 26 points is a realized spread of 1.1 to 6.8, an overstatement of 3.9x, 4.5x, 9.7x and 23.8x in the four cells. Brier skill against always predicting the base rate is negative in 11 of 12 Fixed cells (-0.004 to -0.021; one cell +0.003).
[*]The Bayesian modes do not rank outcomes. AUC 0.467 to 0.505 across 24 cells, none significant (smallest p 0.095), family-wise p 0.91, Brier skill -0.156 to -0.205. Their extreme tails lean the wrong way - the top decile rose less often than the bottom in 24 of 24 cells, mean -0.062 - but the ranking as a whole is not detectably inverted.
[*]The markers do not separate from chance. 138 tests (144 marker-type x horizon x symbol x timeframe x mode combinations, less 6 with fewer than 5 events): 13 reach p <= 0.05 where 6.9 are expected, family-wise p 0.120. The two strongest are the same marker with opposite signs, both Bayesian + Adaptive one bar ahead: bearish continuation +54.89bp on BTCUSDT 4h, -72.52bp on ETHUSDT 4h.

🔹 Known limits

[*]Between 28% and 42% of the threshold slider does nothing in Fixed mode. Neither Fixed line can exceed 85.32 (logit bound 1.760), and the larger of the two peaked at 75.5 to 80.5, so 14, 15, 10 and 12 of the 36 positions printed no marker in 2.4 years on BTCUSDT 1h, BTCUSDT 4h, ETHUSDT 1h and ETHUSDT 4h. Both Bayesian modes reach about 93. At 0.70 on BTCUSDT 1h: 97 markers in Fixed, 574 in Bayesian Regime, 619 in Bayesian + Adaptive.
[*]The Stress state is almost unused: dominant on 0.1% to 0.3% of bars, median posterior 0.004. Moving Stress Sensitivity from 0.5 to 2.0 changes the Up score by 0.34 to 0.40 points on average.
[*]Adaptation moves the Up score by 1.1 to 1.3 points on average and at most 19, and leaves the Bayesian tail pattern in place in 12 of 12 cells.
[*]Two instruments, two timeframes, no transaction costs.

🔹 How the numbers were checked
The model was reimplemented outside Pine and compared with the chart's Data Window: 271 values over 14 bars - Fixed and Bayesian Regime on BTCUSDT 4h (2026-06-13 to 2026-08-19), Bayesian + Adaptive on BTCUSDT 1h (2026-09-10 to 2026-09-15). Fixed and Bayesian Regime agree to 4.9e-9. The largest adaptive difference, 0.004 points of the Up score on one bar, is volume: TradingView's BINANCE feed showed 349.12 where Binance's API reports 363.19, and flow is the only input that reads it.

Three reviews of the draft changed its conclusions, and the corrections are recorded because each wrong version looked finished. The draft said the score did not discriminate at all and that the Bayesian modes rank outcomes in reverse; a re-test found Fixed does rank weakly and the reversal is confined to the tails. The marker family-wise p was first 0.0010 (each null draw was compared against a set containing itself), then 0.0605 (observed and null p on different grids), and is 0.120 with the pooled estimator. The two estimator errors both made the markers look better than they are; the first-draft error ran the other way and understated Fixed.

🔶 SETTINGS

🔹 Model Mode

[*]Model Mode - Fixed, Bayesian Regime, or Bayesian + Adaptive; the modes have opposite signs (default: Fixed)

🔹 Features and Signals - used by every mode

[*]Fast EMA - trend and mean-reversion anchor (default: 21, range 5-80)
[*]Slow EMA - trend reference (default: 55, range 20-200)
[*]Momentum Horizon - bars in the normalized return (default: 8, range 2-30)
[*]Normalization Length - return deviation and volume average (default: 20, range 10-100)
[*]Efficiency Length - bars in the path-efficiency ratio (default: 20, range 5-100)
[*]Signal Threshold - marker level; prints nothing in Fixed from 0.76-0.81 upward (default: 0.70, range 0.55-0.90)
[*]Trend Regime Threshold - efficiency needed to label a crossing C rather than R (default: 0.35, range 0.10-0.80)

🔹 Bayesian Regime

[*]Trend-State Persistence - probability a trend state carries to the next bar (default: 0.90, range 0.70-0.98)
[*]Student-t Degrees of Freedom - tail weight of the likelihoods (default: 5, range 3-15)
[*]Stress Sensitivity - Bayesian modes only; lowers the volatility level at which Stress engages; nearly inert (default: 1.0, range 0.5-2.0)

🔹 Optional Adaptation

[*]Outcome Horizon - Bayesian + Adaptive only; bars before an expert's call is scored, and the sampling cadence (default: 8, range 2-24)
[*]Matured Observations - Bayesian + Adaptive only; scored samples kept per expert; at least 12 before weights apply (default: 48, range 12-120)
[*]Greediness - how sharply lower loss raises an expert's weight (default: 2.0, range 0.25-6.0)
[*]Minimum Expert Weight - floor on an expert's raw score before the four weights are normalized, so the realized minimum weight is higher than this: 0.10 to 0.17 in the measured data (default: 0.05, range 0.01-0.20)

🔹 Two-Color Style

[*]Up / Bullish - colour of the Up score line and the bullish markers (default: #14B8A6)
[*]Down / Bearish - colour of the Down score line and the bearish markers (default: #F43F5E)
[*]Line Width - width of both score lines (default: 2, range 1-4)

Open source under the Mozilla Public License 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux
// Causal OHLCV model with optional filtered Bayesian regimes and delayed expert adaptation.
// Outputs are directional scores, not calibrated forecasts or probabilities of profit.
//
// ===========================================================================
// WHAT THE UP SCORE IS WORTH, MEASURED
//
// Saved until now as "Crypto Directional Probability Oscillator". Renamed before
// publishing, because the measurements below show the plotted number is not a
// probability. In the code the Up score is still the variable pUp.
//
// Data: Binance BTCUSDT and ETHUSDT, 1h (21,567 bars per symbol) and 4h (5,392
// bars per symbol), 2024-04-01 to 2026-09-16 - the 1h-4h range this script says
// its defaults are for. Outcome: did close rise over the next 1, 8 or 24 bars.
// That gives 12 cells per mode (2 symbols x 2 timeframes x 3 horizons). Nulls are
// circular shifts of the outcome series against the score, seeded, with the
// observed statistic pooled into the draws so both are scored on one grid.
//
// 0. THERE IS NO HORIZON. pUp is an instantaneous logistic of a feature blend;
//    no forward period is attached to it anywhere in this file. The only horizon
//    here scores the adaptive experts and never enters pUp. So the Up score is not the
//    probability of any defined event, which is why three horizons are tested.
//
// 1. FIXED MODE RANKS OUTCOMES - WEAKLY. AUC is 0.509 to 0.550 across its 12
//    cells, above 0.5 in all 12, significant against the null (400 draws) in 8,
//    family-wise p 0.027. It is uneven: 6 of 6 ETHUSDT cells, 2 of 3 BTCUSDT 1h,
//    0 of 3 BTCUSDT 4h (p 0.24-0.63). BTCUSDT and ETHUSDT log returns correlate
//    0.82 on both timeframes, so the two symbols are not independent evidence.
//
// 2. ITS PERCENTAGES OVERSTATE THAT BY ROUGHLY 4 TO 24 TIMES. At 8 bars the top
//    decile of Fixed readings (mean printed 63.0-63.7) rose 50.7-52.5% of the
//    time and the bottom decile (mean printed 36.9-37.5) rose 44.1-49.5%. A
//    printed spread of about 26 points is a realized spread of 1.1 to 6.8, i.e. a
//    per-cell overstatement of 3.9x, 4.5x, 9.7x and 23.8x. Brier
//    skill against always predicting the base rate is negative in 11 of 12 Fixed
//    cells (-0.004 to -0.021; one cell +0.003). It ranks; it is not a probability.
//
// 3. THE BAYESIAN MODES DO NOT RANK OUTCOMES AT ALL. AUC is 0.467 to 0.505 across
//    their 24 cells, none significant (smallest p 0.095), family-wise p 0.91.
//    Brier skill is -0.156 to -0.205. Their most confident tails lean the wrong
//    way - the top decile rose less often than the bottom decile in 24 of 24
//    cells, mean -0.062 - but the ranking as a whole is not detectably inverted,
//    and given the 0.82 cross-symbol correlation that tail pattern is weak.
//
// 4. THE MODES HAVE OPPOSITE SIGNS. Correlation of pUp with each input, range over
//    all four symbol-timeframe pairs:
//
//                        trend           meanRev          momentum
//      Fixed          -0.09 to +0.02   +0.51 to +0.60   -0.53 to -0.46
//      Bayesian (both) +0.78 to +0.81   -0.46 to -0.41   +0.26 to +0.29
//
//    A HIGH Fixed reading means price below its fast EMA with negative momentum
//    (a dip-buy read); a high Bayesian reading means an established uptrend
//    extended above it (a continuation read). Two constants cause the flip, and
//    only jointly: the regime gate gives mean reversion 0.05 of the weight under a
//    Bull or Bear posterior (0.55 under Range), and 0.90 * (pBull - pBear) adds a
//    directional-state term driven mostly by trend. Setting either one to the
//    other value alone leaves the mean-reversion correlation at -0.21 to -0.29;
//    changing both makes it +0.44 to +0.49 in all four pairs.
//
// 5. THE MARKERS DO NOT SEPARATE FROM CHANCE. 138 tests (4 marker types x 3
//    horizons x 2 symbols x 2 timeframes x 3 modes = 144, less 6 with fewer than
//    5 events): 13 reach p <= 0.05 where 6.9 are expected, median p 0.388,
//    family-wise p 0.120. The two strongest are the same marker type with
//    opposite signs, both Bayesian + Adaptive at one bar: bearish continuation
//    +54.89bp on BTCUSDT 4h and -72.52bp on ETHUSDT 4h.
//
// 6. 28% TO 42% OF THE THRESHOLD SLIDER IS INERT IN FIXED MODE. The Fixed logit is
//    bounded by 1.6 * 1.10 = 1.760, so neither line can exceed 85.32. The larger of
//    Up and Down scores actually peaked at 75.5 to 80.5, leaving 14, 15, 10 and 12
//    of the 36 slider positions with no marker in 2.4 years (BTCUSDT 1h, BTCUSDT
//    4h, ETHUSDT 1h, ETHUSDT 4h); the first dead position is 0.76 to 0.81 in
//    slider units (0-1). Bayesian Regime has none and peaks near 93. At the shared 0.70 default,
//    BTCUSDT 1h gives 97 markers in Fixed, 574 in Bayesian Regime and 619 in
//    Bayesian + Adaptive.
//
// 7. THE STRESS STATE IS ALMOST UNUSED, AND ADAPTATION IS SMALL. Stress is the
//    dominant regime on 0.1% to 0.3% of bars (median Stress posterior 0.004).
//    Adaptation moves pUp by 0.011 to 0.013 on average, at most 0.19, and leaves
//    the tail pattern in point 3 in place in 12 of 12 cells.
//
// HOW IT WAS CHECKED. The model was reimplemented outside Pine and compared with
// the Data Window: 271 values over 14 bars - Fixed and Bayesian Regime on BTCUSDT
// 4h (2026-06-13 to 2026-08-19), Bayesian + Adaptive on BTCUSDT 1h (2026-09-10
// to 2026-09-15). Fixed and Bayesian Regime agree to 4.9e-9. The largest adaptive
// difference, 4e-5 in pUp on one bar, is volume: the BINANCE feed showed 349.12
// where Binance's API reports 363.19, and flow is the only input that reads it.
//
// CORRECTIONS MADE BEFORE PUBLISHING, RECORDED BECAUSE EACH LOOKED FINE. An early
// draft said the score did not discriminate at all and that the Bayesian modes
// rank outcomes in reverse; an independent re-test showed Fixed does rank
// weakly and the Bayesian reversal is confined to the tails. The marker
// family-wise p was first 0.0010 (each null draw compared against a set that
// contained itself), then 0.0605 (observed and nulls on different p grids), and
// is 0.120 with the pooled estimator. Both estimator errors made the markers
// look stronger; the early-draft error ran the other way and understated Fixed.
//
// Fixed is the default because its sign is not reversed, not because it is a
// usable edge: AUC 0.51-0.55 before any trading cost. Nothing here is a forecast,
// a signal service, or a claim of profitability.
// ===========================================================================

//@version=6
indicator("Crypto Directional Score Oscillator [FibonacciFlux]", "Crypto Score", overlay=false, precision=1)

// ============================================================================
// Inputs
// ============================================================================

string GRP_MODE = "Model Mode"
string modelMode = input.string("Fixed", "Model Mode", options=["Fixed", "Bayesian Regime", "Bayesian + Adaptive"], group=GRP_MODE, tooltip="The modes have OPPOSITE signs. Fixed: a high reading means price is below its fast EMA and falling (a dip-buy read). Both Bayesian modes: a high reading means an established uptrend above it (a continuation read). Measured on BTCUSDT and ETHUSDT, 1h and 4h: Fixed ranks direction weakly (AUC 0.51-0.55) and its percentages overstate that; the Bayesian modes do not rank it at all. Details in the description.")

string GRP_MODEL = "Features and Signals"
int fastLength = input.int(21, "Fast EMA", minval=5, maxval=80, group=GRP_MODEL)
int slowLength = input.int(55, "Slow EMA", minval=20, maxval=200, group=GRP_MODEL)
int momentumLength = input.int(8, "Momentum Horizon", minval=2, maxval=30, group=GRP_MODEL)
int normalizationLength = input.int(20, "Normalization Length", minval=10, maxval=100, group=GRP_MODEL)
int efficiencyLength = input.int(20, "Efficiency Length", minval=5, maxval=100, group=GRP_MODEL)
float signalThreshold = input.float(0.70, "Signal Threshold", minval=0.55, maxval=0.90, step=0.01, group=GRP_MODEL, tooltip="Level either line must cross to print a marker, as 0-1 (0.70 = 70 on the scale). Applies in every mode. In Fixed mode the lines cannot exceed 85 and in testing peaked at 75.5-80.5, so settings above about 0.76-0.81 (slider units, 0-1) print nothing; the Bayesian modes reach about 93. In testing the markers did not beat chance (family-wise p 0.12).")
float trendRegimeThreshold = input.float(0.35, "Trend Regime Threshold", minval=0.10, maxval=0.80, step=0.05, group=GRP_MODEL, tooltip="Path efficiency (0-1) at or above which a crossing is labelled C - continuation, with trend agreeing in sign - instead of R. Used in every mode.")

string GRP_BAYES = "Bayesian Regime"
float regimePersistence = input.float(0.90, "Trend-State Persistence", minval=0.70, maxval=0.98, step=0.01, group=GRP_BAYES)
int likelihoodDegrees = input.int(5, "Student-t Degrees of Freedom", minval=3, maxval=15, group=GRP_BAYES)
float stressSensitivity = input.float(1.0, "Stress Sensitivity", minval=0.5, maxval=2.0, step=0.1, group=GRP_BAYES, tooltip="Bayesian modes only; no effect in Fixed. Lowers the volatility level at which the Stress regime engages. Nearly inert: in testing Stress was the dominant regime on under 0.3% of bars, and moving this from 0.5 to 2.0 changed the Up score by 0.3-0.4 points on average.")

string GRP_ADAPT = "Optional Adaptation"
int adaptationHorizon = input.int(8, "Outcome Horizon", minval=2, maxval=24, group=GRP_ADAPT, tooltip="Bayesian + Adaptive only. Bars after which the call of each expert is scored against the realized move. Scoring also runs only on every Nth bar by timestamp, so N is the sampling cadence too.")
int adaptationSamples = input.int(48, "Matured Observations", minval=12, maxval=120, group=GRP_ADAPT, tooltip="Bayesian + Adaptive only. Scored samples kept per expert. Adaptive weights switch on once 12 exist; the count shown in the table rises to this number and then stops.")
float greediness = input.float(2.0, "Greediness", minval=0.25, maxval=6.0, step=0.25, group=GRP_ADAPT)
float minimumExpertWeight = input.float(0.05, "Minimum Expert Weight", minval=0.01, maxval=0.20, step=0.01, group=GRP_ADAPT)

string GRP_STYLE = "Two-Color Style"
color upColor = input.color(#14B8A6, "Up / Bullish", group=GRP_STYLE)
color downColor = input.color(#F43F5E, "Down / Bearish", group=GRP_STYLE)
int lineWidth = input.int(2, "Line Width", minval=1, maxval=4, group=GRP_STYLE)

// ============================================================================
// Fixed, clipped OHLCV features
// ============================================================================

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_safe_log(float value) =>
    math.log(math.max(value, 0.0000000001))

f_logistic(float value) =>
    1.0 / (1.0 + math.exp(-f_clamp(value, -8.0, 8.0)))

f_student_log_kernel(float value, float center, float scale, float nu) =>
    float safeScale = math.max(scale, 0.0001)
    float error = (value - center) / safeScale
    -math.log(safeScale) - 0.5 * (nu + 1.0) * math.log(1.0 + error * error / nu)

f_state_log_likelihood(float trendValue, float momentumValue, float efficiencyValue, float flowValue, float logVolValue, float trendCenter, float momentumCenter, float efficiencyCenter, float flowCenter, float logVolCenter, float trendScale, float momentumScale, float efficiencyScale, float flowScale, float logVolScale, float nu) =>
    f_student_log_kernel(trendValue, trendCenter, trendScale, nu) + f_student_log_kernel(momentumValue, momentumCenter, momentumScale, nu) + f_student_log_kernel(efficiencyValue, efficiencyCenter, efficiencyScale, nu) + f_student_log_kernel(flowValue, flowCenter, flowScale, nu) + f_student_log_kernel(logVolValue, logVolCenter, logVolScale, nu)

f_binary_log_loss(float probability, float outcome) =>
    float clipped = f_clamp(probability, 0.001, 0.999)
    -outcome * math.log(clipped) - (1.0 - outcome) * math.log(1.0 - clipped)

f_push_bounded(array<float> values, float value, int maximumSize) =>
    array.push(values, value)
    if array.size(values) > maximumSize
        array.shift(values)

f_mean_or_default(array<float> values, float fallback) =>
    array.size(values) > 0 ? array.avg(values) : fallback

float atr14 = ta.atr(14)
float ema21 = ta.ema(close, fastLength)
float ema55 = ta.ema(close, slowLength)
float safeAtr = math.max(atr14, syminfo.mintick)

float trend = f_clamp((ema21 - ema55) / (2.0 * safeAtr), -1.0, 1.0)

float logReturn = close > 0 and close[1] > 0 ? math.log(close / close[1]) : 0.0
float returnDeviation = ta.stdev(logReturn, normalizationLength)
float horizonReturn = close > 0 and close[momentumLength] > 0 ? math.log(close / close[momentumLength]) : 0.0
float momentumDenominator = math.max(returnDeviation * math.sqrt(momentumLength), 0.0000000001)
float momentum = f_clamp(horizonReturn / momentumDenominator, -2.0, 2.0) / 2.0

float volumeMean = ta.sma(volume, normalizationLength)
float relativeVolume = not na(volumeMean) and volumeMean > 0 ? volume / volumeMean : na
float candleRange = math.max(high - low, syminfo.mintick)
float closeLocationValue = f_clamp((2.0 * close - high - low) / candleRange, -1.0, 1.0)
float flow = not na(relativeVolume) ? f_clamp(closeLocationValue * math.min(relativeVolume, 2.0) / 2.0, -1.0, 1.0) : na

float absoluteChange = math.abs(ta.change(close))
float pathLength = ta.sma(absoluteChange, efficiencyLength) * efficiencyLength
float efficiency = not na(pathLength) and pathLength > 0 ? f_clamp(math.abs(close - close[efficiencyLength]) / pathLength, 0.0, 1.0) : 0.0
float meanReversion = f_clamp((ema21 - close) / (2.0 * safeAtr), -1.0, 1.0)

float atrMean = ta.sma(atr14, 50)
float volatilityRatio = not na(atrMean) and atrMean > 0 ? atr14 / atrMean : na
float logVolatility = not na(volatilityRatio) ? f_clamp(f_safe_log(volatilityRatio), -1.5, 1.5) : na

bool volumeReady = not na(relativeVolume) and volumeMean > 0
bool historyReady = not na(ema55) and not na(returnDeviation) and not na(close[efficiencyLength]) and not na(flow)
bool modelReady = volumeReady and historyReady
bool bayesianReady = modelReady and not na(logVolatility)
bool bayesianMode = modelMode != "Fixed"
bool adaptiveMode = modelMode == "Bayesian + Adaptive"

// Disclosed fixed coefficients, ASSERTED NOT FITTED - none of the roughly 80 constants
// in this file (these five, the four expert scales, the transition matrix, the state
// centres and scales, and the regime gate matrix) was estimated from data: 0.55 trend, 0.30 momentum,
// 0.65 mean reversion, 0.25 flow, and overall scale 1.6.
float fixedDirectionalLogit = modelReady ? 1.6 * (efficiency * (0.55 * trend + 0.30 * momentum) + (1.0 - efficiency) * 0.65 * meanReversion + 0.25 * flow) : na
float fixedPUp = modelReady ? f_logistic(fixedDirectionalLogit) : na

// ============================================================================
// Four-state causal Bayesian filter
// ============================================================================

var float posteriorBull = 0.25
var float posteriorBear = 0.25
var float posteriorRange = 0.25
var float posteriorStress = 0.25

float trendStateRemainder = 1.0 - regimePersistence
float trendToOpposite = trendStateRemainder * 0.08
float trendToRange = trendStateRemainder * 0.72
float trendToStress = trendStateRemainder * 0.20

float priorBull = posteriorBull * regimePersistence + posteriorBear * trendToOpposite + posteriorRange * 0.07 + posteriorStress * 0.06
float priorBear = posteriorBull * trendToOpposite + posteriorBear * regimePersistence + posteriorRange * 0.07 + posteriorStress * 0.06
float priorRange = posteriorBull * trendToRange + posteriorBear * trendToRange + posteriorRange * 0.82 + posteriorStress * 0.13
float priorStress = posteriorBull * trendToStress + posteriorBear * trendToStress + posteriorRange * 0.04 + posteriorStress * 0.75

float nu = likelihoodDegrees
float bullLogLikelihood = bayesianReady ? f_state_log_likelihood(trend, momentum, efficiency, flow, logVolatility, 0.55, 0.35, 0.62, 0.15, 0.00, 0.45, 0.55, 0.25, 0.65, 0.45, nu) : na
float bearLogLikelihood = bayesianReady ? f_state_log_likelihood(trend, momentum, efficiency, flow, logVolatility, -0.55, -0.35, 0.62, -0.15, 0.00, 0.45, 0.55, 0.25, 0.65, 0.45, nu) : na
float rangeLogLikelihood = bayesianReady ? f_state_log_likelihood(trend, momentum, efficiency, flow, logVolatility, 0.00, 0.00, 0.18, 0.00, -0.15, 0.35, 0.45, 0.22, 0.65, 0.40, nu) : na
float stressLogVolCenter = 0.65 / stressSensitivity
float stressLogLikelihood = bayesianReady ? f_state_log_likelihood(trend, momentum, efficiency, flow, logVolatility, 0.00, 0.00, 0.40, 0.00, stressLogVolCenter, 0.75, 0.80, 0.35, 0.85, 0.55, nu) : na

if barstate.isconfirmed and bayesianMode and bayesianReady
    float bullLogJoint = f_safe_log(priorBull) + bullLogLikelihood
    float bearLogJoint = f_safe_log(priorBear) + bearLogLikelihood
    float rangeLogJoint = f_safe_log(priorRange) + rangeLogLikelihood
    float stressLogJoint = f_safe_log(priorStress) + stressLogLikelihood
    float maxLogJoint = math.max(math.max(bullLogJoint, bearLogJoint), math.max(rangeLogJoint, stressLogJoint))
    float bullWeight = math.exp(bullLogJoint - maxLogJoint)
    float bearWeight = math.exp(bearLogJoint - maxLogJoint)
    float rangeWeight = math.exp(rangeLogJoint - maxLogJoint)
    float stressWeight = math.exp(stressLogJoint - maxLogJoint)
    float posteriorDenominator = bullWeight + bearWeight + rangeWeight + stressWeight
    if not na(posteriorDenominator) and posteriorDenominator > 0
        posteriorBull := bullWeight / posteriorDenominator
        posteriorBear := bearWeight / posteriorDenominator
        posteriorRange := rangeWeight / posteriorDenominator
        posteriorStress := stressWeight / posteriorDenominator
    else
        float priorDenominator = math.max(priorBull + priorBear + priorRange + priorStress, 0.0000000001)
        posteriorBull := priorBull / priorDenominator
        posteriorBear := priorBear / priorDenominator
        posteriorRange := priorRange / priorDenominator
        posteriorStress := priorStress / priorDenominator

// ============================================================================
// Regime-gated directional experts
// ============================================================================

float trendExpertLogit = modelReady ? 2.2 * trend : na
float momentumExpertLogit = modelReady ? 1.8 * momentum : na
float meanReversionExpertLogit = modelReady ? 2.0 * meanReversion : na
float flowExpertLogit = modelReady ? 1.4 * flow : na

float pTrendExpert = modelReady ? f_logistic(trendExpertLogit) : na
float pMomentumExpert = modelReady ? f_logistic(momentumExpertLogit) : na
float pMeanReversionExpert = modelReady ? f_logistic(meanReversionExpertLogit) : na
float pFlowExpert = modelReady ? f_logistic(flowExpertLogit) : na

// Each state row sums to one. Bull/Bear emphasize trend, Range emphasizes
// mean reversion, and Stress emphasizes momentum plus volume-flow location.
float regimeTrendGate = posteriorBull * 0.50 + posteriorBear * 0.50 + posteriorRange * 0.10 + posteriorStress * 0.10
float regimeMomentumGate = posteriorBull * 0.30 + posteriorBear * 0.30 + posteriorRange * 0.15 + posteriorStress * 0.35
float regimeMeanReversionGate = posteriorBull * 0.05 + posteriorBear * 0.05 + posteriorRange * 0.55 + posteriorStress * 0.05
float regimeFlowGate = posteriorBull * 0.15 + posteriorBear * 0.15 + posteriorRange * 0.20 + posteriorStress * 0.50

// ============================================================================
// Optional delayed expert adaptation
// ============================================================================

var array<float> trendLosses = array.new_float()
var array<float> momentumLosses = array.new_float()
var array<float> meanReversionLosses = array.new_float()
var array<float> flowLosses = array.new_float()

int chartSeconds = int(timeframe.in_seconds())
int epochBar = chartSeconds > 0 ? int(math.floor(time / (chartSeconds * 1000.0))) : bar_index
bool adaptationCadence = epochBar % adaptationHorizon == 0
bool maturedPredictionReady = not na(close[adaptationHorizon]) and not na(pTrendExpert[adaptationHorizon]) and not na(pMomentumExpert[adaptationHorizon]) and not na(pMeanReversionExpert[adaptationHorizon]) and not na(pFlowExpert[adaptationHorizon])

if barstate.isconfirmed and adaptiveMode and bayesianReady and maturedPredictionReady and adaptationCadence
    float maturedOutcome = close > close[adaptationHorizon] ? 1.0 : 0.0
    float trendLoss = f_binary_log_loss(pTrendExpert[adaptationHorizon], maturedOutcome)
    float momentumLoss = f_binary_log_loss(pMomentumExpert[adaptationHorizon], maturedOutcome)
    float meanReversionLoss = f_binary_log_loss(pMeanReversionExpert[adaptationHorizon], maturedOutcome)
    float flowLoss = f_binary_log_loss(pFlowExpert[adaptationHorizon], maturedOutcome)
    f_push_bounded(trendLosses, trendLoss, adaptationSamples)
    f_push_bounded(momentumLosses, momentumLoss, adaptationSamples)
    f_push_bounded(meanReversionLosses, meanReversionLoss, adaptationSamples)
    f_push_bounded(flowLosses, flowLoss, adaptationSamples)

int maturedSampleCount = array.size(trendLosses)
bool adaptationReady = maturedSampleCount >= 12 and array.size(momentumLosses) >= 12 and array.size(meanReversionLosses) >= 12 and array.size(flowLosses) >= 12
float neutralLogLoss = 0.69314718056
float trendMeanLoss = f_mean_or_default(trendLosses, neutralLogLoss)
float momentumMeanLoss = f_mean_or_default(momentumLosses, neutralLogLoss)
float meanReversionMeanLoss = f_mean_or_default(meanReversionLosses, neutralLogLoss)
float flowMeanLoss = f_mean_or_default(flowLosses, neutralLogLoss)
float minimumMeanLoss = math.min(math.min(trendMeanLoss, momentumMeanLoss), math.min(meanReversionMeanLoss, flowMeanLoss))

float adaptiveTrendRaw = adaptationReady ? math.max(minimumExpertWeight, math.exp(-greediness * (trendMeanLoss - minimumMeanLoss))) : 1.0
float adaptiveMomentumRaw = adaptationReady ? math.max(minimumExpertWeight, math.exp(-greediness * (momentumMeanLoss - minimumMeanLoss))) : 1.0
float adaptiveMeanReversionRaw = adaptationReady ? math.max(minimumExpertWeight, math.exp(-greediness * (meanReversionMeanLoss - minimumMeanLoss))) : 1.0
float adaptiveFlowRaw = adaptationReady ? math.max(minimumExpertWeight, math.exp(-greediness * (flowMeanLoss - minimumMeanLoss))) : 1.0
float adaptiveDenominator = adaptiveTrendRaw + adaptiveMomentumRaw + adaptiveMeanReversionRaw + adaptiveFlowRaw
float adaptiveTrendWeight = adaptiveTrendRaw / adaptiveDenominator
float adaptiveMomentumWeight = adaptiveMomentumRaw / adaptiveDenominator
float adaptiveMeanReversionWeight = adaptiveMeanReversionRaw / adaptiveDenominator
float adaptiveFlowWeight = adaptiveFlowRaw / adaptiveDenominator

float trendGateRaw = regimeTrendGate * (adaptiveMode and adaptationReady ? adaptiveTrendWeight : 1.0)
float momentumGateRaw = regimeMomentumGate * (adaptiveMode and adaptationReady ? adaptiveMomentumWeight : 1.0)
float meanReversionGateRaw = regimeMeanReversionGate * (adaptiveMode and adaptationReady ? adaptiveMeanReversionWeight : 1.0)
float flowGateRaw = regimeFlowGate * (adaptiveMode and adaptationReady ? adaptiveFlowWeight : 1.0)
float expertGateDenominator = math.max(trendGateRaw + momentumGateRaw + meanReversionGateRaw + flowGateRaw, 0.0000000001)
float trendGate = trendGateRaw / expertGateDenominator
float momentumGate = momentumGateRaw / expertGateDenominator
float meanReversionGate = meanReversionGateRaw / expertGateDenominator
float flowGate = flowGateRaw / expertGateDenominator

float stressConviction = 1.0 - 0.65 * posteriorStress
float regimeDirectionalBias = posteriorBull - posteriorBear
float bayesianDirectionalLogit = bayesianReady ? stressConviction * (0.90 * regimeDirectionalBias + trendGate * trendExpertLogit + momentumGate * momentumExpertLogit + meanReversionGate * meanReversionExpertLogit + flowGate * flowExpertLogit) : na
float bayesianPUp = bayesianReady ? f_logistic(bayesianDirectionalLogit) : na

float pUp = modelMode == "Fixed" ? fixedPUp : bayesianPUp
float pDown = modelReady ? 1.0 - pUp : na
bool activeReady = modelMode == "Fixed" ? modelReady : bayesianReady

// ============================================================================
// Confirmed-bar threshold signals
// ============================================================================

bool rawUpCross = ta.crossover(pUp, signalThreshold)
bool rawDownCross = ta.crossover(pDown, signalThreshold)

bool bullishContinuation = barstate.isconfirmed and activeReady and rawUpCross and efficiency >= trendRegimeThreshold and trend > 0
bool bullishReversal = barstate.isconfirmed and activeReady and rawUpCross and not bullishContinuation
bool bearishContinuation = barstate.isconfirmed and activeReady and rawDownCross and efficiency >= trendRegimeThreshold and trend < 0
bool bearishReversal = barstate.isconfirmed and activeReady and rawDownCross and not bearishContinuation

// ============================================================================
// Oscillator visuals: only the two directional colors carry signal meaning
// ============================================================================

float pUpPercent = pUp * 100.0
float pDownPercent = pDown * 100.0
float upperGuide = signalThreshold * 100.0
float lowerGuide = (1.0 - signalThreshold) * 100.0

plot(pUpPercent, "Up score", color=upColor, linewidth=lineWidth)
plot(pDownPercent, "Down score", color=downColor, linewidth=lineWidth)
plot(upperGuide, "Upper Threshold", color=color.new(chart.fg_color, 68), linewidth=1)
plot(50.0, "Balance", color=color.new(chart.fg_color, 82), linewidth=1)
plot(lowerGuide, "Lower Threshold", color=color.new(chart.fg_color, 68), linewidth=1)
plot(bayesianMode ? posteriorBull * 100.0 : na, "Posterior Bull", color=color.new(chart.fg_color, 0), display=display.data_window)
plot(bayesianMode ? posteriorBear * 100.0 : na, "Posterior Bear", color=color.new(chart.fg_color, 0), display=display.data_window)
plot(bayesianMode ? posteriorRange * 100.0 : na, "Posterior Range", color=color.new(chart.fg_color, 0), display=display.data_window)
plot(bayesianMode ? posteriorStress * 100.0 : na, "Posterior Stress", color=color.new(chart.fg_color, 0), display=display.data_window)

plotshape(bullishReversal ? upperGuide : na, title="Bullish Reversal", style=shape.circle, location=location.absolute, color=upColor, size=size.tiny, text="R", textcolor=upColor)
plotshape(bearishReversal ? upperGuide : na, title="Bearish Reversal", style=shape.circle, location=location.absolute, color=downColor, size=size.tiny, text="R", textcolor=downColor)
plotshape(bullishContinuation ? upperGuide : na, title="Bullish Continuation", style=shape.triangleup, location=location.absolute, color=upColor, size=size.small, text="C", textcolor=upColor)
plotshape(bearishContinuation ? upperGuide : na, title="Bearish Continuation", style=shape.triangledown, location=location.absolute, color=downColor, size=size.small, text="C", textcolor=downColor)

alertcondition(bullishReversal, "Bullish Reversal", "Up score crossed the threshold; R = the crossing did not meet the C condition. Not a forecast: no marker type separates from chance family-wise (p 0.120 across 138 tests; 13 individually reach p<=0.05 where 6.9 are expected).")
alertcondition(bearishReversal, "Bearish Reversal", "Down score crossed the threshold; R = the crossing did not meet the C condition. Not a forecast: no marker type separates from chance family-wise (p 0.120 across 138 tests; 13 individually reach p<=0.05 where 6.9 are expected).")
alertcondition(bullishContinuation, "Bullish Continuation", "Up score crossed the threshold with efficiency at or above the trend-regime threshold and trend above zero (C). Not a forecast: no marker type separates from chance family-wise (p 0.120 across 138 tests; 13 individually reach p<=0.05 where 6.9 are expected).")
alertcondition(bearishContinuation, "Bearish Continuation", "Down score crossed the threshold with efficiency at or above the trend-regime threshold and trend below zero (C). Not a forecast: no marker type separates from chance family-wise (p 0.120 across 138 tests; 13 individually reach p<=0.05 where 6.9 are expected).")

// ============================================================================
// Disclosure and data warnings
// ============================================================================

bool timeframeInDefaultRange = chartSeconds >= 3600 and chartSeconds <= 14400
var table disclosureTable = table.new(position.bottom_right, 1, 5, frame_color=color.new(chart.fg_color, 75), frame_width=1)

if barstate.islast
    float dominantPosterior = math.max(math.max(posteriorBull, posteriorBear), math.max(posteriorRange, posteriorStress))
    string dominantState = dominantPosterior == posteriorBull ? "Bull Trend" : dominantPosterior == posteriorBear ? "Bear Trend" : dominantPosterior == posteriorRange ? "Range" : "Stress"
    string disclosure = modelMode == "Fixed" ? "Fixed coefficients; ranks weakly (AUC 0.51-0.55), not a probability" : "Regime-gated score; no detectable ranking (AUC 0.47-0.51)"
    string stateText = bayesianMode ? dominantState + " " + str.tostring(dominantPosterior * 100.0, "#.0") + "%" : ""
    string adaptationText = adaptiveMode ? (adaptationReady ? "Adaptive ready: " + str.tostring(maturedSampleCount) + " scored samples" : "Adaptive warm-up: " + str.tostring(maturedSampleCount) + "/12 scored samples") : ""
    string warning = not volumeReady ? "No usable exchange volume; model disabled" : not timeframeInDefaultRange ? "Defaults chosen for 1h-4h crypto charts; not fitted to data" : ""
    table.cell(disclosureTable, 0, 0, modelMode, text_color=chart.fg_color, bgcolor=color.new(chart.bg_color, 15), text_size=size.small)
    table.cell(disclosureTable, 0, 1, disclosure, text_color=chart.fg_color, bgcolor=color.new(chart.bg_color, 15), text_size=size.small)
    table.cell(disclosureTable, 0, 2, stateText, text_color=stateText == "" ? color.new(chart.fg_color, 100) : chart.fg_color, bgcolor=color.new(chart.bg_color, stateText == "" ? 100 : 15), text_size=size.small)
    table.cell(disclosureTable, 0, 3, adaptationText, text_color=adaptationText == "" ? color.new(chart.fg_color, 100) : chart.fg_color, bgcolor=color.new(chart.bg_color, adaptationText == "" ? 100 : 15), text_size=size.small)
    table.cell(disclosureTable, 0, 4, warning, text_color=warning == "" ? color.new(chart.fg_color, 100) : chart.fg_color, bgcolor=color.new(chart.bg_color, warning == "" ? 100 : 15), text_size=size.small)
````
