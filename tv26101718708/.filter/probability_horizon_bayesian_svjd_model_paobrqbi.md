# Probability Horizon - Bayesian SVJD Model

- url: https://www.tradingview.com/script/PaOBRQBI-Probability-Horizon-Bayesian-SVJD-Model/
- type: indicator
- pine_id: PUB;9a9301d19563491f8377cef704b48fa9
- version: 1.0

## Description

# Probability Horizon — Bayesian SVJD Model

## What it does

Probability Horizon is a forward-looking probability projection tool. It does **not** generate buy or sell signals, does **not** act as a strategy, and does **not** place orders. Its single purpose is to display, at each bar, where price **may** be over a user-set horizon, drawn as a forward cone with three percentile lines (25%, 50%, 75%) plus an 8-row diagnostic dashboard.

The cone is the visual answer to two questions the indicator computes every bar:
1. **How wide should the distribution of forward outcomes be?** — set by expected total variance over the horizon.
2. **Should the distribution tilt up or down?** — set by a Bayesian-averaged probability of an up-move.

The wider the cone, the more uncertain the model is. The more the cone tilts, the more directionally confident the model is. A flat, narrow cone means "I expect range-bound, low-vol conditions." A wide, steeply tilted cone means "I expect a directional move under elevated variance."

## Why these components are combined (justification for the mashup)

This script combines several quantitative methods — KAMA, z-score, Haar wavelet, Kalman filter, Hamilton regime-switching, Hawkes process, Heston stochastic volatility, Merton jump-diffusion, Bayesian model averaging, and a calibration tracker. To a reviewer this can look like a collection of indicators bolted together, but it is not. It is **one** statistical model — a Stochastic Volatility Jump-Diffusion (SVJD) framework — whose pieces are mathematically required to produce a forward probability distribution.

Each component has a specific structural role:

- **Forward variance estimation.** A probability cone needs a forward-variance number. The naive choice is realized volatility × √horizon (pure Brownian motion), but this ignores two well-documented facts about financial returns: variance is mean-reverting (Heston, 1993) and returns have fat tails from discrete jumps (Merton, 1976). The Heston + jump-diffusion combination addresses both. The script uses the Heston integrated-variance closed form for the mean-reverting diffusion component, adds a Merton jump-variance contribution, and optionally adds a vol-of-vol uncertainty term. The result is a horizon-dependent variance estimate that dynamically narrows when volatility is elevated (expected to decay back to mean) and widens when volatility is depressed (expected to rise).

- **Directional probability.** To tilt the cone, a probability of direction is required. A single signal is unreliable, so five orthogonal sub-models each output their own P(up):
  - A short-term KAMA-trend model
  - A z-score mean-reversion model
  - A Haar wavelet decomposition model (price denoised into trend + cycle + noise; signal fires only on the trend band)
  - A Kalman-adaptive smoothing model (smoothing factor adapts to noise level in real time)
  - A Hamilton 3-state regime model with Gaussian observation likelihoods (Bull / Bear / Range)

- **Sub-model combination.** The five P(up) values are combined via Bayesian model averaging with online weight updates. Each bar, after a fixed evaluation horizon, every sub-model is scored by log-loss against the actual outcome. Weights update via exponential decay: a model that predicted correctly gains weight; a model that failed loses weight. A minimum weight floor prevents any model from being silenced completely, so it can recover if its regime returns. Weights are renormalised to sum to 1.

- **Crisis dampening.** A Hawkes self-exciting point process monitors volatility clustering. Each large absolute return is treated as an event that boosts the process's intensity by α and decays exponentially at rate β. When intensity rises above a threshold multiple of its baseline, the final Bayesian probability is shrunk toward 0.5 — the higher the intensity, the stronger the shrinkage. This is how the model says "I have no idea — treat this as a coin flip" during regime breaks.

- **Self-correcting calibration.** A calibration tracker logs every prediction and checks the realized outcome after a fixed horizon. Predictions are binned by predicted probability (50–60%, 60–70%, etc.). If a bin's actual historical hit rate is below its predicted midpoint, future predictions in that bin are shrunk further toward 0.5. This is the model's honesty mechanism: it learns from its own miscalibration and tones itself down where it has been overconfident.

Each component answers a specific structural question. Remove any one and a specific capability disappears: no Heston → cone width does not adapt to vol regime; no calibration → no self-correction; no Hawkes → no crisis dampening; no Bayesian averaging → one model dominates and the system becomes brittle.

## How the components interact (data flow)

Every confirmed bar, the script executes the following pipeline:

1. **Measure** five raw market dimensions: KAMA slope, z-score vs trend, realized-vol percentile, OBV/price divergence, higher-TF trend.
2. **Each sub-model** maps its directional bias and strength to a probability in [0.40, 0.60]. The maximum single-model probability is capped at 0.60 because empirical calibration on multiple markets showed that anything higher is overconfident.
3. **Bayesian model averaging** combines the five sub-model probabilities into a single raw P(up), weighted by each sub-model's recent log-loss accuracy.
4. **Hawkes modifier** is applied: if intensity is above its warning threshold, the raw P(up) is pulled toward 0.5 in proportion to how far above threshold the intensity is.
5. **Calibration shrinkage** is applied: the post-Hawkes probability is checked against its calibration bin's historical hit rate, and shrunk further toward 0.5 if that bin has been overconfident.
6. **Forward variance** is computed separately: Heston integrated variance + Merton jump variance + optional vol-of-vol uncertainty, all over the projection horizon.
7. **The cone is drawn** with width set by the square root of forward variance and tilt set by the final shrunk probability. Three percentile lines (P25, P50, P75) are plotted from the current bar to the horizon endpoint.

Direction (sub-model probabilities → Bayesian average → Hawkes modifier → calibration shrinkage) is one half of the pipeline. Variance (Heston + jumps + vol-of-vol) is the other half. They meet at the cone, where one determines tilt and the other determines width.

## How to use it

**On the chart.** The cone shows the model's current view of the forward distribution. The P50 line is the median expected level given the implied drift. The P25 and P75 lines bracket the interquartile range. If P25 and P75 are roughly equidistant from current price, the model has no strong directional view; if the cone tilts noticeably up or down, the Bayesian probability favours that direction. A wider cone means more uncertainty; a narrower cone means tighter forward variance.

**The optional Monte Carlo cloud** (off by default) overlays bootstrap-resampled forward paths drawn from the asset's actual recent returns. Unlike the cone, it makes no Gaussian assumption — it shows the empirical distribution of forward outcomes given the asset's own recent return history.

**The 8-row dashboard** (top-right) is where the model exposes its full state:

- **Row 1 — Verdict.** Current direction (Bull / Bear / Neutral) and final P(up) percentage.
- **Row 2 — Direction.** A 10-character probability bar plus the size of the calibration shrinkage applied in percentage points.
- **Row 3 — 5 Models.** Up/down icons for each sub-model and the agreement count (e.g., "4/5 agree"). Trust the verdict more when 4 or 5 of 5 agree; trust it less when only 3 of 5 agree.
- **Row 4 — Regime.** Combined market regime (Quiet Bull / Quiet Bear / Volatile-Range / Crisis) plus the Hamilton dominant state.
- **Row 5 — Vol.** Volatility state vs long-run mean: HIGH (above mean, cone narrowing as vol decays), LOW (below mean, cone widening as vol rises), or AT MEAN. Includes the current sigma.
- **Row 6 — Risk.** Hawkes status: ✓ calm or ⚠ CRISIS. When CRISIS fires, the probability has been shrunk toward 0.5.
- **Row 7 — Honesty.** This is the most important diagnostic. It shows the actual historical hit rate for predictions in the 50–60% probability bin, with a Wilson confidence interval. If the system has predicted 55% many times and the actual rate is 53–58%, it is well-calibrated. If actual is below 50%, the system is currently overconfident and shrinkage is active.
- **Row 8 — Samples.** Total confirmed predictions and a trust level (low / warm-up / OK). Trust the cone less when total samples are below 50; trust it most when samples exceed 200.

## Suitable timeframes

The script auto-scales internal lookbacks to the chart timeframe relative to a 15-minute reference, so the same defaults work across 15-minute, 1-hour, 4-hour, and daily charts without manual tuning. Below 15 minutes the Hamilton 3-state model is automatically disabled because sample sizes become too small for reliable likelihood estimation; the other four sub-models continue to operate.

## What is original

Combining KAMA, wavelets, Kalman, Hamilton, Heston, Merton jumps, and a Hawkes process is not by itself new — these are all published methods. The original aspects of this script are:

- The **specific combination**: a five-model Bayesian ensemble for direction, with Hawkes-process crisis dampening and a self-correcting calibration tracker, all wrapped around a Heston + jump-diffusion variance estimate. I am not aware of a public Pine Script that combines all of these into a single probability cone with this data flow.
- The **calibration shrinkage mechanism**: the model logs every prediction, scores it after a fixed horizon, and applies bin-specific shrinkage to future predictions in bins where it has been overconfident. This is a self-correcting honesty layer that runs entirely on-chart, with Wilson confidence intervals and optional regime-specific calibration tables (Bull / Bear / Range).
- The **transparent diagnostic dashboard**: rather than hiding the model behind a single line, the dashboard exposes the verdict, model agreement, regime, vol state, crisis indicator, calibration quality, and sample size in eight rows. Users can see at a glance not only what the model thinks, but how much to trust it.

## Limitations (please read)

- **Pine Script cannot perform true maximum-likelihood estimation.** Heston and jump-diffusion parameters are estimated using approximation methods (AR(1) regression on log-variance, exponential moving averages for jump moments, rolling averages for long-term variance). The directional behaviour is correct — when vol is high, the cone narrows; when jumps are frequent, the cone widens — but exact parameter values are not equivalent to those a quantitative research desk would produce with MLE on tick data.

- **OHLCV data only.** No order-book data, no alternative-data feed, no options input, no fundamental input.

- **Calibration needs sample accumulation.** The Honesty row shows "warming up" until at least ~30 confirmed predictions have matured. Pine has no cross-session persistence, so calibration is rebuilt from chart history each time the indicator loads on a new chart.

- **Monte Carlo is deterministic.** Paths use a Linear Congruential Generator seeded by bar_index for reproducibility within a session. The same chart at the same moment produces the same cloud. This is intentional.

- **This is a probability indicator, not a strategy.** There are no backtest results, no equity curve, no position management. The script cannot tell you what to do; it only tells you what its model currently thinks the distribution of forward outcomes is.

- **Past calibration does not guarantee future calibration.** Market regimes change, parameters drift, and the cone should be treated as a visualisation aid rather than a prediction.

## Inputs of note

The defaults work without modification on most liquid instruments at most timeframes. Inputs worth knowing:

- **Auto-scale lookbacks** (on by default) — keeps the same defaults usable across timeframes.
- **Bayesian learning rate η** (default 0.15) — how fast sub-model weights adapt. Higher = faster but noisier.
- **Min Bayesian Probability** (default 0.62) — the threshold the dashboard uses to call a bar "Bull" or "Bear" rather than "Neutral".
- **Heston κ floor / ceiling** — bounds the mean-reversion-speed estimate. Defaults (0.02 to 0.30) handle most markets.
- **Hawkes warning threshold** (default 2.0× baseline) — when crisis dampening kicks in.
- **Monte Carlo Cloud** (off by default) — overlays bootstrap paths. Turn on if you want an empirical (non-Gaussian) view of forward outcomes alongside the cone.

## Disclaimer

This script is published for educational and analytical purposes only. It does not constitute financial advice, investment advice, a recommendation to buy or sell any financial instrument, or a solicitation of any transaction. The author is not a registered investment adviser and nothing in this script should be construed as personalised investment guidance.

Past performance does not guarantee future results. The probability projections shown by this indicator are model outputs, not forecasts of what will actually happen. Trading and investing involve substantial risk of loss and are not suitable for every investor. Users are solely responsible for their own trading decisions and for verifying that any approach is appropriate for their personal financial situation, risk tolerance, and applicable regulations.

The author and Market_Logic_India accept no liability for any losses, damages, or trading outcomes resulting from the use, misuse, or interpretation of this script. Use at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) Market_Logic_India
// =============================================================================
// Probability Horizon - Bayesian SVJD Model
// =============================================================================
//
// WHAT THIS INDICATOR DOES
// ------------------------
// Probability Horizon is a FORWARD PROBABILITY PROJECTION tool. It does not
// generate buy or sell signals, does not place orders, and does not act as
// a strategy. Its single purpose is to display, at each bar, a probability
// distribution of where price MAY be in the future, drawn as a forward cone
// with three percentile lines (25%, 50%, 75%).
//
// The cone has two ingredients:
//   1. WIDTH  - determined by expected total variance over the horizon
//               (Heston stochastic volatility + Merton jump-diffusion +
//               vol-of-vol uncertainty)
//   2. TILT   - determined by a Bayesian-averaged probability of an up-move,
//               computed from five independent sub-models that each output
//               their own P(up).
//
// WHY THESE COMPONENTS ARE COMBINED (justification for the mashup)
// ----------------------------------------------------------------
// This is NOT an arbitrary collection of indicators. It is ONE statistical
// model - a Stochastic Volatility Jump-Diffusion (SVJD) framework - whose
// pieces are mathematically required to produce the forward distribution:
//
//   - To draw a probability cone, you need a forward-variance estimate.
//     A naive choice is realized volatility × √horizon (Brownian motion),
//     but that ignores two well-documented market facts:
//       (a) variance is mean-reverting (Heston, 1993)
//       (b) returns have fat tails from discrete jumps (Merton, 1976)
//     The Heston + jump-diffusion combination addresses both.
//
//   - To tilt the cone (drift), you need a probability of direction. A
//     single signal (e.g., one moving-average slope) is unreliable. Five
//     orthogonal sub-models are combined via Bayesian model averaging so
//     that no single model dominates and weights adapt to recent accuracy.
//
//   - To prevent the model from being confidently wrong in crisis periods,
//     a Hawkes self-exciting point process dampens the probability toward
//     0.5 when volatility clustering is detected.
//
//   - To prevent persistent overconfidence, a calibration tracker logs
//     every prediction and applies shrinkage in probability bins where the
//     model has historically been too aggressive.
//
// Each component answers a specific structural question. Removing any one
// of them removes a specific capability (e.g., no Heston means the cone
// width does not adapt to vol regime; no calibration means no self-
// correction; no Hawkes means no crisis dampening).
//
// METHODOLOGY (data flow, in order)
// ---------------------------------
// 1. Five orthogonal market dimensions are measured every bar:
//      - Trend            (KAMA slope)
//      - Mean reversion   (price z-score vs trend)
//      - Volatility regime (realized vol percentile)
//      - Order flow       (OBV divergence vs price)
//      - Multi-timeframe  (higher TF trend)
//
// 2. Five probabilistic sub-models each output P(up) for the horizon:
//      - Short-term KAMA-trend model
//      - Z-score mean-reversion model
//      - Haar wavelet decomposition model
//      - Kalman-adaptive smoothing model
//      - Hamilton 3-state regime model (Bull / Bear / Range)
//
// 3. Sub-models are combined via Bayesian model averaging with online
//    weight updates. Weights update each bar using exponential log-loss:
//    a model that predicted correctly gains weight; a model that failed
//    loses weight (subject to a minimum floor so no model is silenced
//    completely, allowing recovery if its regime returns).
//
// 4. A Hawkes self-exciting point process monitors volatility clustering.
//    When its intensity ratio exceeds a threshold above baseline, the
//    final probability is shrunk toward 0.5 (the higher the intensity,
//    the stronger the shrinkage).
//
// 5. A calibration tracker logs every prediction and checks the realized
//    outcome after a fixed horizon. Predictions are binned by predicted
//    probability (50-60%, 60-70%, etc.). If a bin's historical hit rate
//    is below its predicted midpoint, future predictions in that bin are
//    shrunk further toward 0.5.
//
// 6. Forward variance for the projection horizon is computed as the sum of:
//      - Heston integrated variance:
//          theta * h + (V_t - theta) * (1 - exp(-kappa * h)) / kappa
//        (variance is mean-reverting toward long-run mean theta at speed
//         kappa; high vol decays, low vol rises)
//      - Merton jump contribution:
//          lambda_jump * (mu_jump^2 + sigma_jump^2) * h
//        (fat-tail variance from discrete jumps)
//      - Vol-of-vol uncertainty (optional):
//          vov_weight * xi^2 * h^2 / (1 + kappa * h)
//        (widens the cone when variance itself is unstable)
//
// 7. The projection cone is drawn from the current bar to the user-set
//    horizon with three percentile lines (25%, 50%, 75%). Width is set by
//    the square root of integrated variance; tilt is set by the Bayesian
//    P(up).
//
// HOW TO READ THE OUTPUT
// ----------------------
// On the chart:
//   - The cone shows where price MAY be over the projection horizon. The
//     centre line (P50) is the median expected level. The outer lines
//     (P25, P75) bracket the interquartile range. A WIDER cone means more
//     uncertainty; a NARROWER cone means more confident variance.
//   - A tilted cone reflects the Bayesian probability of direction. Equal
//     P25/P75 distance from current price implies a balanced outlook.
//   - The optional Monte Carlo cloud shows bootstrap-resampled forward
//     paths drawn from the asset's actual recent returns (no Gaussian
//     assumption).
//
// In the dashboard (top-right, 8 rows):
//   Row 1 - VERDICT      : current direction and P(up) percentage
//   Row 2 - DIRECTION    : probability bar and shrinkage applied
//   Row 3 - 5 MODELS     : agreement among the five sub-models
//   Row 4 - REGIME       : market regime and Hamilton state
//   Row 5 - VOL          : vol state (high/at-mean/low) and sigma
//   Row 6 - RISK         : Hawkes crisis indicator
//   Row 7 - HONESTY      : calibration quality (actual hit rate at 50-60%)
//   Row 8 - SAMPLES      : sample size and trust level
//
// CALIBRATION AND TRUST
// ---------------------
// The HONESTY row is the most important diagnostic. It shows the actual
// historical hit rate for predictions in the 50-60% probability bin, with
// a Wilson confidence interval. If the system has predicted 55% many times
// and the actual rate is 53-58%, it is well-calibrated. If actual is below
// 50%, the system is overconfident (and the calibration shrinkage is
// actively pulling future predictions toward neutral). Trust the cone less
// when sample size is below 50; trust it most when total samples exceed 200
// and the calibration bin hit rate is close to its predicted midpoint.
//
// SUITABLE TIMEFRAMES
// -------------------
// The script auto-scales internal lookbacks to the chart timeframe relative
// to a 15-minute reference. It runs sensibly on 15-minute through daily.
// Below 15 minutes the Hamilton 3-state model is automatically disabled
// because sample sizes become too small for reliable likelihood estimation.
//
// LIMITATIONS (please read before use)
// ------------------------------------
// - Pine Script cannot perform true maximum-likelihood parameter estimation.
//   Heston and jump-diffusion parameters are estimated using approximation
//   methods (AR(1) regression on log-variance, exponential moving averages
//   for jump moments). The DIRECTIONAL behaviour of the model is correct,
//   but exact parameter values are not equivalent to those a quantitative
//   research desk would produce with MLE on tick data.
//
// - Predictions are made from publicly available OHLCV data only. There is
//   no order-book data, no alternative-data feed, no options-market input,
//   and no fundamental input.
//
// - Calibration requires sample accumulation. The HONESTY row shows
//   "warming up" until at least ~30 confirmed predictions have matured.
//   Pine has no cross-session persistence, so calibration data is rebuilt
//   from chart history each time the indicator loads on a new chart.
//
// - Monte Carlo paths use a deterministic pseudo-random generator (LCG
//   seeded by bar_index). The same chart at the same moment will produce
//   the same cloud. This is intentional, for reproducibility.
//
// - This is a PROBABILITY indicator, not a strategy. There are no
//   backtest results, no equity curve, and no position management.
//   The script cannot tell you what to do; it only tells you what its
//   model currently thinks the distribution of forward outcomes is.
//
// - As with any model, past calibration does not guarantee future
//   calibration. Market regimes change, parameters drift, and the cone
//   should be treated as a visualisation aid rather than a prediction.
//
// DISCLAIMER
// ----------
// This script is published for educational and analytical purposes only.
// It does not constitute financial advice, investment advice, a
// recommendation to buy or sell any financial instrument, or a
// solicitation of any transaction. The author is not a registered
// investment adviser and nothing in this script should be construed as
// personalised investment guidance.
//
// Past performance does not guarantee future results. The probability
// projections shown by this indicator are model outputs, not forecasts of
// what will actually happen. Trading and investing involve substantial
// risk of loss and are not suitable for every investor. Users are solely
// responsible for their own trading decisions and for verifying that any
// approach is appropriate for their personal financial situation, risk
// tolerance, and applicable regulations.
//
// The author and Market_Logic_India accept no liability for any losses,
// damages, or trading outcomes resulting from the use, misuse, or
// interpretation of this script. Use at your own risk.
//
// =============================================================================

//@version=6
indicator("Probability Horizon - Bayesian SVJD Model",
     shorttitle = "PH-SVJD",
     overlay = true,
     max_bars_back = 500,
     max_lines_count = 500,
     max_labels_count = 100,
     max_boxes_count = 150)

// =============================================================================
// INPUTS
// =============================================================================

// --- v13: Style preset removed. Auto-scaling makes it redundant.
//         Lookback values below are used directly.

// --- Auto-Scale Lookbacks ---
grp_scale = "── Auto-Scale Lookbacks ──"
auto_scale = input.bool(true, "Auto-scale lookbacks to chart TF", group = grp_scale,
     tooltip = "When ON, KAMA periods, z-score windows, vol lookbacks, and pivot lengths scale to the chart TF relative to a 15-minute reference. Same defaults work across all timeframes. Turn OFF for manual tuning.")
ref_tf_mins = input.int(15, "Reference TF (minutes)", minval = 1, maxval = 1440, group = grp_scale,
     tooltip = "Timeframe at which the default bar counts are calibrated. Default 15min.")

// Compute scale factor (clamped to [0.1, 20])
chart_tf_secs = timeframe.in_seconds(timeframe.period)
ref_tf_secs   = ref_tf_mins * 60.0
scale_factor  = auto_scale ? math.max(0.1, math.min(20.0, ref_tf_secs / math.max(chart_tf_secs, 1.0))) : 1.0

// Helper: scale and round a lookback safely (min 2)
f_scale(int base) =>
    math.max(2, int(math.round(base * scale_factor)))

// --- Signal parameters ---
grp_signals = "── Signal Parameters ──"
kama_period      = input.int(10,  "KAMA Period",         group = grp_signals, minval = 2)
kama_fast        = input.int(2,   "KAMA Fast EMA",       group = grp_signals, minval = 1)
kama_slow        = input.int(30,  "KAMA Slow EMA",       group = grp_signals, minval = 5)
slope_window     = input.int(5,   "Trend Slope Window",  group = grp_signals, minval = 1)
zscore_window    = input.int(60,  "Z-Score Window",      group = grp_signals, minval = 10)
active_thresh    = input.float(1.5, "Z Threshold",       group = grp_signals, minval = 0.5, step = 0.1)
vol_window       = input.int(20,  "Volatility Window",   group = grp_signals, minval = 5)
vol_lookback     = input.int(252, "Vol Regime Lookback", group = grp_signals, minval = 50)
flow_window      = input.int(20,  "Flow Window",         group = grp_signals, minval = 5)
context_window   = input.int(20,  "Context Window",      group = grp_signals, minval = 5)

// --- Multi-timeframe ---
grp_mtf = "── Multi-Timeframe ──"
use_mtf      = input.bool(true,  "Show HTF Trend Context",   group = grp_mtf)
active_htf   = input.timeframe("240", "HTF Timeframe",       group = grp_mtf)

// --- Regime detection ---
grp_regime = "── Regime Detection ──"
use_regime_filter = input.bool(true, "Enable Regime Filter",  group = grp_regime)
regime_lookback   = input.int(50,    "Regime Lookback",       group = grp_regime, minval = 20)

// --- Hurst ---
grp_hurst = "── Hurst Exponent ──"
use_hurst       = input.bool(true,  "Enable Hurst Filter",     group = grp_hurst)
hurst_lookback  = input.int(100,    "Hurst Window",            group = grp_hurst, minval = 50, maxval = 200)
hurst_trend     = input.float(0.55, "Hurst Trend Threshold",   group = grp_hurst, minval = 0.5, maxval = 0.7, step = 0.01)
hurst_meanrev   = input.float(0.45, "Hurst Mean-Rev Threshold", group = grp_hurst, minval = 0.3, maxval = 0.5, step = 0.01)

// --- NEW: Multi-Horizon Forecast ---
// v13: Forecast cones, Echo pattern matching, Volume Profile, Absorption candles,
//      and S/R target validation REMOVED. The probability funnel/arrows replace
//      the cones; the rest were entry-signal infrastructure.

// --- Bayesian Model Averaging ---
grp_bayes = "── Bayesian Model Averaging (NEW) ──"
use_bayes_ensemble = input.bool(true, "Enable Bayesian Ensemble",            group = grp_bayes, tooltip = "Each forecast model tracks its own accuracy. Weights update online based on log-loss. Models that have been right recently get more influence.")
bayes_eval_horizon = input.int(10,   "Evaluation Horizon (bars forward)",     group = grp_bayes, minval = 3, maxval = 50, tooltip = "How many bars forward to wait before scoring each forecast. Longer = more reliable scoring, slower learning.")
bayes_learning_eta = input.float(0.15, "Learning Rate (η)",                    group = grp_bayes, minval = 0.05, maxval = 0.50, step = 0.05, tooltip = "How fast weights adapt. Higher = faster adaptation but more noisy. Default 0.15 is a balanced setting.")
bayes_min_weight   = input.float(0.10, "Minimum Model Weight",                 group = grp_bayes, minval = 0.01, maxval = 0.30, step = 0.01, tooltip = "Floor for model weight so even a struggling model isn't completely silenced (in case its regime returns).")

// --- NEW v7: Conjunction Filter ---
grp_conjunction = "── Conjunction Filter (NEW) ──"
use_conjunction = input.bool(true, "Require All Models Agree on Direction",   group = grp_conjunction, tooltip = "Trade only when Bayesian probability is high AND all active models agree. Prevents single-model dominance.")
bayes_prob_threshold = input.float(0.62, "Min Bayesian Probability",          group = grp_conjunction, minval = 0.50, maxval = 0.80, step = 0.01, tooltip = "Combined probability must exceed this for a trade. Higher = fewer but more reliable signals.")

// --- NEW v7: Calibration Tracker ---
grp_calib = "── Calibration Tracker (NEW) ──"
use_calibration = input.bool(true, "Track Historical Calibration",            group = grp_calib, tooltip = "For each predicted probability bin, track actual hit rate. Tells you when the system is over/underconfident.")
show_calib_table = input.bool(true, "Show Calibration Table",                group = grp_calib)
calib_eval_horizon = input.int(20, "Calibration Eval Horizon (bars)",         group = grp_calib, minval = 3, maxval = 50, tooltip = "v10: Increased from 10 to 20 for more stable calibration measurement.")

// --- NEW v9: Wavelet Decomposition ---
grp_wavelet = "── Wavelet Decomposition (v9) ──"
use_wavelet     = input.bool(true,  "Enable Haar Wavelet Decomposition",      group = grp_wavelet, tooltip = "Decomposes price into trend + cycle + noise bands. Trend signal fires only on the cleaned trend band, dramatically reducing whipsaw.")
wavelet_levels  = input.int(3,      "Decomposition Levels (1-4)",             group = grp_wavelet, minval = 1, maxval = 4, tooltip = "Each level doubles the smoothing horizon. 3 levels = ~8x smoothing. More levels = cleaner but more lag.")
wavelet_weight  = input.float(0.30, "Initial Weight in Ensemble",             group = grp_wavelet, minval = 0.0, maxval = 0.5, step = 0.05)

// --- NEW v9: Kalman-Adaptive KAMA ---
grp_kalman = "── Kalman-Adaptive KAMA (v9) ──"
use_kalman      = input.bool(true,  "Use Kalman-Adaptive KAMA Period",        group = grp_kalman, tooltip = "Replaces fixed KAMA period with Kalman-estimated optimal smoothing. Adapts to noise level in real-time.")
kalman_process_q = input.float(0.001, "Process Noise (Q)",                     group = grp_kalman, minval = 0.0001, maxval = 0.01, step = 0.0001, tooltip = "Q ~ how fast we expect the true period to change. Smaller = smoother.")
kalman_measure_r = input.float(0.10, "Measurement Noise (R)",                  group = grp_kalman, minval = 0.01, maxval = 1.0, step = 0.01, tooltip = "R ~ how noisy our observations are. Larger = more skeptical of recent data.")

// --- NEW v9: 3-State Hamilton Regime Model ---
grp_hamilton = "── Hamilton 3-State Regime (v9) ──"
use_hamilton    = input.bool(true,  "Enable Hamilton Regime Model",            group = grp_hamilton, tooltip = "3-state regime: Bull / Bear / Volatile-Range. Outputs P(regime) instead of binary classification.")
hamilton_lookback = input.int(60,   "Likelihood Estimation Window",            group = grp_hamilton, minval = 20, maxval = 200)
hamilton_persistence = input.float(0.95, "State Persistence (transition diag)", group = grp_hamilton, minval = 0.80, maxval = 0.99, step = 0.01, tooltip = "Probability that state persists bar-to-bar. Higher = more sticky regimes. 0.95 means avg regime lasts ~20 bars.")

// --- NEW v9: Hawkes Process ---
grp_hawkes = "── Hawkes Process (v9) ──"
use_hawkes      = input.bool(true,  "Enable Hawkes Crisis Predictor",          group = grp_hawkes, tooltip = "Self-exciting point process. Detects volatility clustering BEFORE the crisis regime fires.")
hawkes_alpha    = input.float(0.50, "Excitation (α)",                          group = grp_hawkes, minval = 0.10, maxval = 0.90, step = 0.05, tooltip = "How much each shock amplifies future intensity. Alpha must be < beta for stability.")
hawkes_beta     = input.float(0.20, "Decay Rate (β)",                          group = grp_hawkes, minval = 0.05, maxval = 0.50, step = 0.05, tooltip = "How fast excitation decays. Smaller = longer memory.")
hawkes_warning_threshold = input.float(2.0, "Warning Threshold (× baseline)",  group = grp_hawkes, minval = 1.5, maxval = 5.0, step = 0.1, tooltip = "When λ exceeds this multiple of baseline, system enters pre-crisis warning state.")

// --- NEW v11: Jump-Diffusion Funnel ---
grp_jumpdiff = "── Jump-Diffusion Funnel (v11) ──"
use_jump_diffusion = input.bool(true, "Use Jump-Diffusion (not pure Gaussian)", group = grp_jumpdiff, tooltip = "v11: Replaces Brownian funnel with Merton jump-diffusion. Accounts for fat tails — funnel will appear wider, which is more accurate.")
jump_sigma_threshold = input.float(2.5, "Jump Detection Threshold (× σ)",      group = grp_jumpdiff, minval = 1.5, maxval = 4.0, step = 0.1, tooltip = "Returns exceeding this many sigmas count as 'jumps'. Lower = more jumps detected. Default 2.5σ aligns with Merton's standard.")
jump_lookback = input.int(252, "Jump Estimation Lookback (bars)",              group = grp_jumpdiff, minval = 50, maxval = 1000, tooltip = "How many bars to look back when estimating jump frequency and size. Longer = more stable, slower to adapt.")

// --- NEW v11: Monte Carlo Cloud ---
grp_montecarlo = "── Monte Carlo Cloud ──"
use_monte_carlo = input.bool(false, "Show Monte Carlo Cloud",                   group = grp_montecarlo, tooltip = "Bootstrap-resamples your asset's actual returns to generate forecast paths. Off by default since the gradient cone fill already conveys probability spread.")
mc_num_paths = input.int(10, "Number of Simulation Paths",                     group = grp_montecarlo, minval = 5, maxval = 50, tooltip = "Higher = denser cloud but slower chart load.")
mc_pool_size = input.int(200, "Bootstrap Pool Size (bars of returns)",         group = grp_montecarlo, minval = 50, maxval = 500, tooltip = "How many recent returns to draw from when generating Monte Carlo paths. Smaller = more responsive to current regime (recent returns dominate), larger = more stable but may include stale regime data. Default 200.")
mc_path_transparency = input.int(85, "Path Transparency (0-100)",              group = grp_montecarlo, minval = 70, maxval = 95, tooltip = "Higher = fainter cloud. Default 85 lets the funnel lines remain visible on top.")
mc_path_color = input.color(color.new(color.aqua, 0), "Cloud Path Color",      group = grp_montecarlo)

// --- NEW v11: Calibration Enhancements ---
grp_calib_v11 = "── Calibration Enhancements (v11) ──"
show_confidence_intervals = input.bool(true, "Show Wilson Confidence Intervals", group = grp_calib_v11, tooltip = "Shows '55% ± 8%' instead of just '55%'. Lets you see how stable the calibration estimate is given sample size.")
use_regime_calibration = input.bool(true, "Regime-Specific Calibration",         group = grp_calib_v11, tooltip = "Track separate calibration tables for Bull/Bear/Range regimes. The system learns which regime it's best calibrated in.")
recency_half_life = input.int(500, "Recency Half-Life (bars)",                    group = grp_calib_v11, minval = 100, maxval = 5000, tooltip = "Older predictions get less weight in calibration. Half-life of 500 means predictions 500 bars ago count half as much as current.")
warmup_predictions = input.int(30, "Warmup Predictions to Discount",             group = grp_calib_v11, minval = 0, maxval = 100, tooltip = "First N predictions after script load get reduced weight (Pine has no persistence, so every load is cold-start).")

// --- NEW v12: Heston Stochastic Volatility ---
grp_heston = "── Heston Stochastic Volatility (v12) ──"
use_heston = input.bool(true, "Enable Heston Vol Dynamics",                       group = grp_heston, tooltip = "v12: Models variance itself as a mean-reverting stochastic process. Funnel dynamically narrows when vol is high (expected to decay) and widens when vol is low (expected to rise).")
heston_var_lookback = input.int(252, "Long-term Variance Window (θ estimation)",  group = grp_heston, minval = 50, maxval = 1000, tooltip = "Lookback for estimating long-term mean variance θ. Longer = more stable, slower to adapt to regime shifts.")
heston_kappa_lookback = input.int(60, "Mean-Reversion Window (κ estimation)",     group = grp_heston, minval = 20, maxval = 200, tooltip = "Lookback for estimating mean-reversion speed κ via AR(1) on log-variance. Shorter = faster adaptation.")
heston_kappa_floor = input.float(0.02, "Min Mean-Reversion Speed (κ floor)",      group = grp_heston, minval = 0.005, maxval = 0.20, step = 0.005, tooltip = "Lower bound on κ. Prevents Heston from disabling itself when estimation is noisy. Higher = faster forced reversion.")
heston_kappa_ceiling = input.float(0.30, "Max Mean-Reversion Speed (κ ceiling)",  group = grp_heston, minval = 0.10, maxval = 0.80, step = 0.05, tooltip = "Upper bound on κ. Prevents extreme estimates from over-narrowing the funnel.")
heston_vol_state_threshold = input.float(0.15, "Vol-State Threshold (×)",         group = grp_heston, minval = 0.05, maxval = 0.50, step = 0.05, tooltip = "When |current_var - θ| / θ exceeds this, vol is classified HIGH/LOW vs AT-MEAN. Default 15%.")
use_vov_uncertainty = input.bool(true,  "Include Vol-of-Vol Uncertainty",        group = grp_heston, tooltip = "When ON, the projection cone widens by an additional uncertainty bonus derived from ξ (vol of vol). High ξ means variance itself is unstable, so the cone should be wider. Genuine accuracy gain when vol is regime-shifting.")
vov_weight          = input.float(0.5,  "Vol-of-Vol Weight (× ξ²)",              group = grp_heston, minval = 0.0, maxval = 2.0, step = 0.1, tooltip = "How much vol-of-vol contributes to cone width. 0 = ignore ξ (v12 behavior). 1.0 = full theoretical contribution. Default 0.5 (moderate).")

// v13: REMOVED — target projection, trend duration, session filter, confluence
// quality scoring, trade management (was strategy-mode anyway).

// --- Regime detection helper ---
grp_regime2 = "── Regime Background ──"
use_vol_gate     = input.bool(true, "Use Volatility Gate (for regime classification only)", group = grp_regime2, tooltip = "When ON, high-volatility regimes are classified as 'unfavorable' for color display.")

// --- Visualization (slimmed) ---
grp_viz = "── Visualization ──"
show_dashboard = input.bool(true, "Show Dashboard",            group = grp_viz)
show_kama      = input.bool(false, "Plot KAMA line",            group = grp_viz, tooltip = "Off by default. The KAMA is used to compute trend signals but doesn't need to be shown; the probability cone already projects forward direction.")
show_regime_bg = input.bool(true, "Regime Background",         group = grp_viz)
atr_period     = input.int(14,    "ATR Period (for display)",  group = grp_viz, minval = 5)

// =============================================================================
// KAMA FUNCTION
// =============================================================================

f_kama(src, length, fast, slow) =>
    change_abs    = math.abs(src - src[length])
    volatility    = math.sum(math.abs(src - src[1]), length)
    er            = volatility != 0 ? change_abs / volatility : 0.0
    sc_fast       = 2.0 / (fast + 1)
    sc_slow       = 2.0 / (slow + 1)
    sc            = math.pow(er * (sc_fast - sc_slow) + sc_slow, 2)
    var float kama = na
    kama := na(kama[1]) ? src : kama[1] + sc * (src - kama[1])
    kama

// =============================================================================
// APPLY AUTO-SCALING TO ALL LOOKBACK PARAMETERS
// =============================================================================
// Each scalable parameter gets a "_eff" (effective) version. These are what
// the signals actually use. When auto_scale is OFF, _eff == base value.

kama_period_eff    = f_scale(kama_period)
zscore_window_eff  = f_scale(zscore_window)
vol_lookback_eff   = f_scale(vol_lookback)
flow_window_eff    = f_scale(flow_window)
context_window_eff = f_scale(context_window)
regime_lookback_eff = f_scale(regime_lookback)
hurst_lookback_eff = f_scale(hurst_lookback)
vol_window_eff     = f_scale(vol_window)
slope_window_eff   = math.max(1, f_scale(slope_window))

// =============================================================================
// SIGNALS 1-5
// =============================================================================

kama_val   = f_kama(close, kama_period_eff, kama_fast, kama_slow)
kama_slope = kama_val - kama_val[slope_window_eff]
norm_slope = kama_slope / close

sig_trend = norm_slope > 0.001 ? 1 : norm_slope < -0.001 ? -1 : 0
trend_strength = math.max(-1.0, math.min(1.0, norm_slope * 200))

residual    = close - kama_val
resid_mean  = ta.sma(residual, zscore_window_eff)
resid_std   = ta.stdev(residual, zscore_window_eff)
zscore_val  = resid_std != 0 ? (residual - resid_mean) / resid_std : 0.0

sig_meanrev = zscore_val < -active_thresh ? 1 : zscore_val > active_thresh ? -1 : 0
meanrev_strength = math.max(-1.0, math.min(1.0, -zscore_val / 3.0))

returns      = math.log(close / close[1])
realized_vol = ta.stdev(returns, vol_window_eff)
vol_q33      = ta.percentile_linear_interpolation(realized_vol, vol_lookback_eff, 33)
vol_q67      = ta.percentile_linear_interpolation(realized_vol, vol_lookback_eff, 67)

sig_vol = realized_vol < vol_q33 ? 1 : realized_vol > vol_q67 ? -1 : 0

// =============================================================================
// v11: JUMP-DIFFUSION PARAMETER ESTIMATION
// =============================================================================
// Identifies returns that exceed jump_sigma_threshold × σ as "jumps."
// Estimates jump frequency (λ_jump), mean jump size (μ_jump), and
// jump volatility (σ_jump) from the trailing window.
//
// Compound Poisson process: jumps arrive at rate λ_jump per bar, and
// each jump has size drawn from N(μ_jump, σ_jump²).

returns_long_vol = ta.stdev(returns, math.min(jump_lookback, 500))
is_jump_bar = use_jump_diffusion and not na(returns_long_vol) and returns_long_vol > 0 and math.abs(returns) > jump_sigma_threshold * returns_long_vol

// Lambda_jump = empirical jump frequency (jumps per bar)
jump_count_window = math.min(jump_lookback, 500)
lambda_jump = ta.sma(is_jump_bar ? 1.0 : 0.0, jump_count_window)

// Mean and std of jump returns (only when jump occurred, else carry forward)
// We use exponentially weighted moving versions to keep them stable
var float jump_mean_ewma = 0.0
var float jump_var_ewma  = 0.0
var int   jump_count_seen = 0

if barstate.isconfirmed and is_jump_bar
    jump_count_seen += 1
    // Exponential moving update with α = 0.05 (slow adaptation)
    float alpha_jump = 0.05
    float delta = returns - jump_mean_ewma
    jump_mean_ewma := jump_mean_ewma + alpha_jump * delta
    jump_var_ewma  := (1 - alpha_jump) * (jump_var_ewma + alpha_jump * delta * delta)

mu_jump    = jump_count_seen > 5 ? jump_mean_ewma : 0.0
sigma_jump = jump_count_seen > 5 ? math.sqrt(math.max(0.0, jump_var_ewma)) : 0.0

// Total per-bar return variance under jump-diffusion:
//   Var_total = σ² + λ_jump × (μ_jump² + σ_jump²)
// (Under independence of diffusion and jumps; standard Merton result)
jump_var_per_bar = use_jump_diffusion ? lambda_jump * (mu_jump * mu_jump + sigma_jump * sigma_jump) : 0.0
total_var_per_bar = realized_vol * realized_vol + jump_var_per_bar
total_sigma_per_bar = math.sqrt(math.max(0.0, total_var_per_bar))

// =============================================================================
// v12: HESTON STOCHASTIC VOLATILITY PARAMETER ESTIMATION
// =============================================================================
// Models variance V_t as a mean-reverting stochastic process:
//   dV_t = κ(θ - V_t) dt + ξ√V_t dW^V_t
//
// We estimate the parameters using Pine-feasible approximations:
//   θ (theta)  = long-term mean variance (rolling average)
//   κ (kappa)  = mean-reversion speed (from AR(1) on log-variance)
//   ξ (xi)     = vol-of-vol (std of variance increments)
//
// HONEST CAVEAT: Real Heston calibration uses MLE or fits to option prices.
// Our estimation is approximation-grade — the DIRECTIONAL behavior is right
// (dynamic narrowing/widening), but exact parameter values aren't quant-grade.

// Current instantaneous variance estimate (we use realized_vol² as our V_t proxy)
current_variance = realized_vol * realized_vol

// θ — long-term mean variance: simple rolling average
heston_theta = ta.sma(current_variance, math.min(heston_var_lookback, 500))

// κ — mean-reversion speed via AR(1) on log-variance
// Model: log(V_{t+1}) - log(θ) = (1 - κ) × (log(V_t) - log(θ)) + noise
// So κ = 1 - corr(log_var_t, log_var_{t-1})  (approximately)
//
// We use a simpler robust estimator: half-life of deviations from mean
// If log-variance deviation halves in N bars, then κ ≈ ln(2) / N

// Compute log-variance deviation from mean
log_var = current_variance > 0 ? math.log(current_variance) : 0.0
log_theta = heston_theta > 0 ? math.log(heston_theta) : 0.0
log_var_dev = log_var - log_theta

// Estimate AR(1) coefficient: φ = corr(log_var_dev_t, log_var_dev_{t-1})
// In Pine, we approximate using ta.correlation
heston_ar1_phi = ta.correlation(log_var_dev, log_var_dev[1], math.min(heston_kappa_lookback, 200))

// κ = -ln(φ), clamped to [floor, ceiling]
// (When φ → 1, no mean reversion → κ → 0. When φ → 0, instant reversion → κ → ∞.)
heston_kappa_raw = (not na(heston_ar1_phi) and heston_ar1_phi > 0 and heston_ar1_phi < 1.0) ? -math.log(heston_ar1_phi) : heston_kappa_floor
heston_kappa = math.max(heston_kappa_floor, math.min(heston_kappa_ceiling, heston_kappa_raw))

// ξ (vol-of-vol) — std of variance increments
variance_change = current_variance - current_variance[1]
heston_xi = ta.stdev(variance_change, math.min(heston_var_lookback, 500))

// Vol-state classification: is current vol HIGH, LOW, or AT mean?
vol_ratio = heston_theta > 0 ? (current_variance - heston_theta) / heston_theta : 0.0
vol_state_high = use_heston and vol_ratio > heston_vol_state_threshold
vol_state_low  = use_heston and vol_ratio < -heston_vol_state_threshold
vol_state_mid  = use_heston and not vol_state_high and not vol_state_low

// =============================================================================
// v12: HESTON EXPECTED INTEGRATED VARIANCE
// =============================================================================
// For the funnel, we need expected TOTAL variance accumulated over horizon h.
//
// Under Heston dynamics, expected variance at time t+s is:
//   E[V(t+s) | V_t] = θ + (V_t - θ) × e^(-κs)
//
// Integrating from 0 to h gives expected integrated variance:
//   ∫₀ʰ E[V(t+s) | V_t] ds = θh + (V_t - θ) × (1 - e^(-κh)) / κ
//
// This replaces the naive Brownian "σ² × h" with a horizon-dependent quantity
// that converges to θ × h as h → ∞ (regardless of starting V_t).

f_heston_integrated_var(float current_var, float theta, float kappa, int horizon) =>
    float result = current_var * horizon  // fallback if Heston disabled
    if use_heston and kappa > 0 and not na(theta) and theta > 0
        float decay_factor = (1.0 - math.exp(-kappa * horizon)) / kappa
        result := theta * horizon + (current_var - theta) * decay_factor
    math.max(0.0, result)

// =============================================================================
// VOL-OF-VOL UNCERTAINTY ADJUSTMENT
// =============================================================================
// Under Heston, variance V_t is itself stochastic (driven by ξ²). This means
// the integrated variance over a horizon also has variance — adding genuine
// uncertainty that pure deterministic-vol projection misses.
//
// Approximation used (Pine-feasible):
//   uncertainty(h) = ξ² × h² × 1/(1 + κh)
//
// Intuition:
//   - ξ² scaling: more vol-of-vol → more uncertainty
//   - h² growth: variance of an integral over h grows roughly as h²
//   - 1/(1+κh) damping: faster mean reversion → less uncertainty matters
//   - vov_weight: user-tunable contribution (default 0.5)
//
// HONEST CAVEAT: The exact closed-form Heston second moment is complex.
// This is a directionally-correct simplification. When ξ is high, the cone
// widens; when ξ is low, the cone tightens. The relative behavior is right.

f_vov_uncertainty(float xi, float kappa, int horizon) =>
    float result = 0.0
    if use_vov_uncertainty and not na(xi) and xi > 0 and kappa > 0
        float h_float = float(horizon)
        result := vov_weight * xi * xi * h_float * h_float / (1.0 + kappa * h_float)
    math.max(0.0, result)

// Compute total integrated variance over horizon h:
//   Heston diffusion + Jump variance + Vol-of-Vol uncertainty
f_total_integrated_var(int horizon) =>
    float heston_part = f_heston_integrated_var(current_variance, heston_theta, heston_kappa, horizon)
    float jump_part   = use_jump_diffusion ? jump_var_per_bar * horizon : 0.0
    float vov_part    = f_vov_uncertainty(heston_xi, heston_kappa, horizon)
    heston_part + jump_part + vov_part

obv_val          = ta.cum(math.sign(ta.change(close)) * volume)
obv_change       = obv_val - obv_val[flow_window_eff]
obv_std          = ta.stdev(obv_val, flow_window_eff)
obv_change_pct   = obv_std != 0 ? obv_change / obv_std : 0.0
price_change_pct = (close - close[flow_window_eff]) / close[flow_window_eff]

sig_flow = 0
if (obv_change_pct >  0.5 and price_change_pct <  0.01)
    sig_flow := 1
if (obv_change_pct >  1.0 and price_change_pct >  0)
    sig_flow := 1
if (obv_change_pct < -0.5 and price_change_pct > -0.01)
    sig_flow := -1
if (obv_change_pct < -1.0 and price_change_pct <  0)
    sig_flow := -1

slow_kama_ctx = f_kama(close, context_window_eff * 2, kama_fast, kama_slow)
ctx_change    = (slow_kama_ctx - slow_kama_ctx[context_window_eff]) / close

// v8: Lowered threshold from 0.002 to 0.0008 — calibration data showed
// the old threshold rarely fired, making this dimension useless.
sig_context = ctx_change > 0.0008 ? 1 : ctx_change < -0.0008 ? -1 : 0

// =============================================================================
// MTF + HURST + REGIME (same as v2)
// =============================================================================

htf_close = request.security(syminfo.tickerid, active_htf, close, lookahead = barmerge.lookahead_off)
htf_kama  = request.security(syminfo.tickerid, active_htf, f_kama(close, kama_period_eff, kama_fast, kama_slow), lookahead = barmerge.lookahead_off)

htf_slope = htf_kama - htf_kama[slope_window_eff]
htf_norm  = htf_close != 0 ? htf_slope / htf_close : 0.0
sig_htf   = htf_norm > 0.001 ? 1 : htf_norm < -0.001 ? -1 : 0

f_hurst(src, length) =>
    rets = math.log(src / src[1])
    mean_r = ta.sma(rets, length)
    cumdev = 0.0
    max_cumdev = -1e10
    min_cumdev = 1e10
    for i = 0 to length - 1
        cumdev := cumdev + (rets[i] - mean_r)
        if cumdev > max_cumdev
            max_cumdev := cumdev
        if cumdev < min_cumdev
            min_cumdev := cumdev
    rng = max_cumdev - min_cumdev
    sd  = ta.stdev(rets, length)
    rs  = sd != 0 ? rng / sd : 0.0
    rs > 0 ? math.log(rs) / math.log(length) : 0.5

hurst = f_hurst(close, hurst_lookback_eff)
hurst_regime = hurst > hurst_trend ? 1 : hurst < hurst_meanrev ? -1 : 0

ret_mean  = ta.sma(returns, regime_lookback_eff)
ret_std   = ta.stdev(returns, regime_lookback_eff)
ret_tstat = ret_std != 0 ? ret_mean / (ret_std / math.sqrt(regime_lookback_eff)) : 0.0

vol_high = realized_vol > vol_q67
vol_low  = realized_vol < vol_q33

regime = vol_low and ret_tstat >  1.0 ? 0 : vol_low and ret_tstat < -1.0 ? 1 : vol_high and math.abs(ret_tstat) > 2.0 ? 3 : 2

regime_name = regime == 0 ? "QUIET BULL" : regime == 1 ? "QUIET BEAR" : regime == 2 ? "VOLATILE/RANGE" : "CRISIS"

regime_color = regime == 0 ? color.new(color.green, 92) : regime == 1 ? color.new(color.red,   92) : regime == 2 ? color.new(color.yellow,94) : color.new(color.fuchsia, 90)

// v13: regime_allows_trade removed (was used only by removed entry-signal logic)


// v13: REMOVED original section (~180 lines)


// v13: REMOVED original section (~350 lines)

// =============================================================================
// PROBABILITY MAPPING HELPER (needed by all Bayesian models)
// =============================================================================
// v10/v13: Max single-model probability is 0.60. Calibration data on NIFTY
// showed 51-55% actual rates, so anything higher than 0.60 is overconfident.
// bias_int ∈ {-1, 0, +1}, strength ∈ [0, 1]
f_to_prob(bias_int, strength) =>
    bias_int == 1 ? 0.50 + 0.10 * strength : bias_int == -1 ? 0.50 - 0.10 * strength : 0.50

// =============================================================================
// UPGRADE W1 (v9): HAAR WAVELET DECOMPOSITION
// =============================================================================
// Decomposes close price into trend + cycle + noise bands using the Haar
// wavelet. Each level halves the temporal resolution and isolates a
// frequency band:
//   Level 1: 2-bar moving average and 2-bar difference
//   Level 2: 4-bar smoothing (recursive on level 1's trend)
//   Level 3: 8-bar smoothing
//   ...
//
// The trend signal fires on the deepest-level approximation only, which
// has filtered out the higher-frequency noise.
//
// Mathematics:
//   trend_1(t) = (price(t) + price(t-1)) / 2
//   detail_1(t) = (price(t) - price(t-1)) / 2
//   trend_2(t) = (trend_1(t) + trend_1(t-1)) / 2
//   ...

// Simple Haar decomposition using nested SMAs (mathematically equivalent
// to repeated low-pass filtering with downsampling).

wavelet_level1 = ta.sma(close, 2)
wavelet_level2 = ta.sma(wavelet_level1, 2)
wavelet_level3 = ta.sma(wavelet_level2, 2)
wavelet_level4 = ta.sma(wavelet_level3, 2)

// Pick the appropriate level based on user input
wavelet_trend = wavelet_levels == 1 ? wavelet_level1 : wavelet_levels == 2 ? wavelet_level2 : wavelet_levels == 3 ? wavelet_level3 : wavelet_level4

// Compute trend direction on the smoothed series
wavelet_slope = wavelet_trend - wavelet_trend[slope_window_eff]
wavelet_norm  = wavelet_slope / close

// Wavelet model produces its own probability of up
wavelet_direction = wavelet_norm > 0.0005 ? 1 : wavelet_norm < -0.0005 ? -1 : 0
wavelet_strength  = math.min(1.0, math.abs(wavelet_norm) * 400)
model_w_prob_up   = use_wavelet ? f_to_prob(wavelet_direction, wavelet_strength) : 0.5

// =============================================================================
// UPGRADE W2 (v9): KALMAN-ADAPTIVE KAMA
// =============================================================================
// Standard Kalman filter applied to estimating the "true" smoothed price.
// State: x_t = true value at time t.
// Observation: z_t = close.
//
// Predict:
//   x_pred = x_prev
//   P_pred = P_prev + Q
//
// Update:
//   K = P_pred / (P_pred + R)   (Kalman gain)
//   x_new = x_pred + K * (z - x_pred)
//   P_new = (1 - K) * P_pred
//
// The Kalman gain K acts as an adaptive smoothing factor — when recent
// data has been consistent (low residual), K is small and we trust the
// existing state. When data is volatile, K grows and we update aggressively.

var float kalman_x = na
var float kalman_p = 1.0

if barstate.isconfirmed and use_kalman
    if na(kalman_x)
        kalman_x := close
        kalman_p := 1.0
    else
        // Predict step
        float p_pred = kalman_p + kalman_process_q
        // Kalman gain
        float k_gain = p_pred / (p_pred + kalman_measure_r)
        // Update step
        kalman_x := kalman_x + k_gain * (close - kalman_x)
        kalman_p := (1.0 - k_gain) * p_pred

// Kalman direction
kalman_slope = use_kalman and not na(kalman_x) and not na(kalman_x[slope_window_eff]) ? kalman_x - kalman_x[slope_window_eff] : 0.0
kalman_norm  = close != 0 ? kalman_slope / close : 0.0

kalman_direction = kalman_norm > 0.0005 ? 1 : kalman_norm < -0.0005 ? -1 : 0
kalman_strength  = math.min(1.0, math.abs(kalman_norm) * 400)
model_k_prob_up  = use_kalman ? f_to_prob(kalman_direction, kalman_strength) : 0.5

// =============================================================================
// UPGRADE W3 (v9): HAMILTON-STYLE 3-STATE REGIME MODEL
// =============================================================================
// Three latent states with Gaussian observation likelihoods:
//   State 1 (Bull):  N(μ=+0.001, σ=σ_low)
//   State 2 (Bear):  N(μ=-0.001, σ=σ_low)
//   State 3 (Range): N(μ=0,      σ=σ_high)
//
// Where σ_low/σ_high are estimated from data.
//
// Bayesian update each bar:
//   P(s_t | r_t) ∝ P(r_t | s_t) × Σ P(s_t | s_{t-1}) P(s_{t-1} | r_{t-1})
//
// We use a simplified version with fixed transition matrix.

// Estimate state-conditional means and stds from recent data
float ham_mean_est = ta.sma(returns, hamilton_lookback)
float ham_std_est  = ta.stdev(returns, hamilton_lookback)
float ham_mean_pos = math.max(0.0001, ham_mean_est + ham_std_est * 0.5)
float ham_mean_neg = math.min(-0.0001, ham_mean_est - ham_std_est * 0.5)
float ham_std_low  = math.max(0.0001, ham_std_est * 0.7)
float ham_std_high = math.max(0.0002, ham_std_est * 1.5)

// Gaussian pdf helper
f_gauss(x, mu, sigma) =>
    float z = sigma > 0 ? (x - mu) / sigma : 0
    float pdf = math.exp(-0.5 * z * z) / (sigma * math.sqrt(2 * math.pi))
    pdf

// Maintain state probabilities (initialize to uniform)
var float p_bull = 0.333
var float p_bear = 0.333
var float p_range = 0.334

// v10: Auto-disable Hamilton on intraday (< 15min). Sample size too small
// to validate the 3-state model meaningfully.
hamilton_active = use_hamilton and chart_tf_secs >= 900   // 15min = 900s

if hamilton_active and barstate.isconfirmed and not na(returns) and ham_std_est > 0
    // Likelihoods of observed return under each state
    float L_bull  = f_gauss(returns, ham_mean_pos, ham_std_low)
    float L_bear  = f_gauss(returns, ham_mean_neg, ham_std_low)
    float L_range = f_gauss(returns, 0.0, ham_std_high)

    // Transition matrix: diagonal = persistence, off-diagonal = (1-persistence)/2
    float trans_diag = hamilton_persistence
    float trans_off  = (1.0 - hamilton_persistence) / 2.0

    // Forward Bayesian update: prior * likelihood
    float prior_bull  = trans_diag * p_bull  + trans_off * p_bear + trans_off * p_range
    float prior_bear  = trans_off  * p_bull  + trans_diag * p_bear + trans_off * p_range
    float prior_range = trans_off  * p_bull  + trans_off  * p_bear + trans_diag * p_range

    float post_bull  = prior_bull  * L_bull
    float post_bear  = prior_bear  * L_bear
    float post_range = prior_range * L_range

    float post_sum = post_bull + post_bear + post_range
    if post_sum > 0
        p_bull  := post_bull  / post_sum
        p_bear  := post_bear  / post_sum
        p_range := post_range / post_sum

// Hamilton's contribution to ensemble: P(up) given regime probabilities
//   If bull state, P(up) is high; if bear state, low; if range, neutral.
model_h_prob_up = hamilton_active ? math.max(0.05, math.min(0.95, 0.50 + 0.10 * (p_bull - p_bear))) : 0.5

// Identify dominant Hamilton state for display
ham_dominant_state = p_bull > p_bear and p_bull > p_range ? 1 : p_bear > p_range ? 2 : 3
ham_dominant_prob  = math.max(p_bull, math.max(p_bear, p_range))

// =============================================================================
// UPGRADE W4 (v9): HAWKES PROCESS FOR CRISIS EARLY WARNING
// =============================================================================
// Self-exciting point process intensity:
//   λ(t) = μ + Σ α·exp(-β(t - t_i))
// Where t_i are the times of past large-return events.
//
// We define an "event" as a return exceeding 2× rolling stdev.
// Each event boosts intensity by α; intensity decays exponentially at rate β.
//
// When λ exceeds (hawkes_warning_threshold × baseline μ), crisis is brewing.
// This typically fires 1-3 bars BEFORE the classical high-vol regime triggers.

// Define an "event" — large absolute return
hawkes_event = math.abs(returns) > 2.0 * realized_vol

// Baseline μ ≈ event rate. Estimate from rolling window.
hawkes_baseline = ta.sma(hawkes_event ? 1.0 : 0.0, 100)

// Compute intensity recursively
var float hawkes_lambda = 0.0
if use_hawkes and barstate.isconfirmed
    // Decay previous intensity, then add new excitation if event occurred
    hawkes_lambda := hawkes_lambda * math.exp(-hawkes_beta) + (hawkes_event ? hawkes_alpha : 0.0)

// Normalize: intensity relative to baseline
hawkes_intensity_ratio = hawkes_baseline > 0 ? (hawkes_lambda / hawkes_baseline) : 0.0
hawkes_warning = use_hawkes and hawkes_intensity_ratio > hawkes_warning_threshold

// Hawkes contribution: it doesn't predict direction, but it tells us
// uncertainty is rising. Push P(up) toward 0.5 when warning is active.
// (Conceptually: "I have no idea — anything could happen, treat as coin flip.")


// =============================================================================
// UPGRADE Z (v7): BAYESIAN MODEL AVERAGING WITH ONLINE WEIGHT UPDATES
// =============================================================================
// Three forecast models compete for influence:
//   Model A — Cone (percentile-based unconditional forecast)
//   Model B — Echo (pattern-matching conditional forecast)
//   Model C — ATR-trend (velocity projection)
//
// Each model:
//   1. Outputs a "P(up)" probability for the next bayes_eval_horizon bars
//   2. After eval_horizon bars, we score it via log-loss
//   3. Its weight w_i updates via exponential decay:  w_i = w_i * exp(-η * loss)
//   4. Weights are renormalized so they sum to 1
//
// Final ensemble probability uses Bayesian model averaging:
//   P(up | all) = Σ w_i * P(up | M_i)    (geometric mean form)

// --- Step 1: Each model emits its current P(up) ---
// Convert each model's directional bias into a probability.
// (f_to_prob is defined earlier in the file)

// v13: Cone & Echo models REMOVED (entry-signal infrastructure).
// Model A is now a simple KAMA-trend model (was Cone in v12).
// Model B is the SAME trend signal but on a longer horizon (was Echo in v12).
// Wavelet, Kalman, Hamilton remain.

// Model A — Short-term KAMA trend
trend_direction = norm_slope > 0 ? 1 : norm_slope < 0 ? -1 : 0
trend_pstr      = math.min(1.0, math.abs(norm_slope) * 500)
model_a_prob_up = f_to_prob(trend_direction, trend_pstr)

// Model B — Longer-horizon trend (z-score signal direction)
meanrev_direction = zscore_val < -active_thresh ? 1 : zscore_val > active_thresh ? -1 : 0
meanrev_pstr      = math.min(1.0, math.abs(zscore_val) / 3.0)
model_b_prob_up = f_to_prob(meanrev_direction, meanrev_pstr)

// Model C — legacy slot, kept disabled
model_c_prob_up = 0.5

// --- Step 2: Maintain pending predictions for scoring ---
// Each model logs its prediction. After bayes_eval_horizon bars, we check
// if it was right and update the weight.

var array<int>   pending_bars    = array.new<int>()     // bar at which prediction was made
var array<float> pending_priceA  = array.new<float>()   // close at prediction time
var array<float> pending_probA   = array.new<float>()   // model A's P(up) prediction
var array<float> pending_probB   = array.new<float>()
var array<float> pending_probC   = array.new<float>()
var array<float> pending_probW   = array.new<float>()   // NEW v9: Wavelet
var array<float> pending_probK   = array.new<float>()   // NEW v9: Kalman
var array<float> pending_probH   = array.new<float>()   // NEW v9: Hamilton

// v9: 5-model ensemble (Cone, Echo, Wavelet, Kalman, Hamilton).
// Hawkes is NOT a directional model — it's a modifier applied to the final
// probability that pulls toward 0.5 during crisis warnings.
var float weight_a = 0.20   // Cone
var float weight_b = 0.20   // Echo
var float weight_c = 0.00   // (legacy, ATR-Trend disabled in v8)
var float weight_w = 0.20   // Wavelet (NEW v9)
var float weight_k = 0.20   // Kalman   (NEW v9)
var float weight_h = 0.20   // Hamilton (NEW v9)

// Log new predictions (only on confirmed bars)
if use_bayes_ensemble and barstate.isconfirmed
    array.push(pending_bars,   bar_index)
    array.push(pending_priceA, close)
    array.push(pending_probA,  model_a_prob_up)
    array.push(pending_probB,  model_b_prob_up)
    array.push(pending_probC,  model_c_prob_up)
    array.push(pending_probW,  model_w_prob_up)
    array.push(pending_probK,  model_k_prob_up)
    array.push(pending_probH,  model_h_prob_up)

// --- Step 3: Score matured predictions and update weights ---
// A prediction is "matured" when bayes_eval_horizon bars have elapsed.
// We compute its log-loss and apply exponential weight decay.

f_log_loss(prob_up, actual_up) =>
    // Cross-entropy log loss: -[y*log(p) + (1-y)*log(1-p)]
    float pSafe = math.max(0.01, math.min(0.99, prob_up))
    actual_up ? -math.log(pSafe) : -math.log(1.0 - pSafe)

if use_bayes_ensemble and barstate.isconfirmed and array.size(pending_bars) > 0
    // Process from oldest forward, removing matured entries
    int idx = 0
    while idx < array.size(pending_bars)
        int pred_bar = array.get(pending_bars, idx)
        if bar_index - pred_bar >= bayes_eval_horizon
            // This prediction has matured — score it
            float prior_price = array.get(pending_priceA, idx)
            bool  actual_up   = close > prior_price
            float pA = array.get(pending_probA, idx)
            float pB = array.get(pending_probB, idx)
            float pW = array.get(pending_probW, idx)
            float pK = array.get(pending_probK, idx)
            float pH = array.get(pending_probH, idx)

            float lossA = f_log_loss(pA, actual_up)
            float lossB = f_log_loss(pB, actual_up)
            float lossW = f_log_loss(pW, actual_up)
            float lossK = f_log_loss(pK, actual_up)
            float lossH = f_log_loss(pH, actual_up)

            // v9: Update all 5 active models (Cone, Echo, Wavelet, Kalman, Hamilton)
            weight_a := weight_a * math.exp(-bayes_learning_eta * lossA)
            weight_b := weight_b * math.exp(-bayes_learning_eta * lossB)
            weight_w := weight_w * math.exp(-bayes_learning_eta * lossW)
            weight_k := weight_k * math.exp(-bayes_learning_eta * lossK)
            weight_h := weight_h * math.exp(-bayes_learning_eta * lossH)

            // Enforce minimum weight floor
            weight_a := math.max(bayes_min_weight, weight_a)
            weight_b := math.max(bayes_min_weight, weight_b)
            weight_w := math.max(bayes_min_weight, weight_w)
            weight_k := math.max(bayes_min_weight, weight_k)
            weight_h := math.max(bayes_min_weight, weight_h)
            weight_c := 0.0

            // Renormalize so all 5 active weights sum to 1
            float wsum = weight_a + weight_b + weight_w + weight_k + weight_h
            if wsum > 0
                weight_a := weight_a / wsum
                weight_b := weight_b / wsum
                weight_w := weight_w / wsum
                weight_k := weight_k / wsum
                weight_h := weight_h / wsum

            // Remove processed entry
            array.remove(pending_bars,   idx)
            array.remove(pending_priceA, idx)
            array.remove(pending_probA,  idx)
            array.remove(pending_probB,  idx)
            array.remove(pending_probC,  idx)
            array.remove(pending_probW,  idx)
            array.remove(pending_probK,  idx)
            array.remove(pending_probH,  idx)
            // Don't increment idx — array shifted left
        else
            idx := idx + 1

    // Cap pending list size for memory safety
    // v13: cap reduced 100→50 for faster array operations
    while array.size(pending_bars) > 50
        array.shift(pending_bars)
        array.shift(pending_priceA)
        array.shift(pending_probA)
        array.shift(pending_probB)
        array.shift(pending_probC)
        array.shift(pending_probW)
        array.shift(pending_probK)
        array.shift(pending_probH)

// --- Step 4: Compute combined Bayesian probability ---
// Linear-pooling form (weighted average of probabilities):
//   P(up | ensemble) = w_a * P_a + w_b * P_b + w_c * P_c
// (Equivalent to the geometric mean formula when weights normalize to 1.)

// v8: 2-model ensemble (Cone + Echo only)
// v9: 5-model ensemble (Cone, Echo, Wavelet, Kalman, Hamilton)
bayes_prob_up_raw = use_bayes_ensemble ? weight_a * model_a_prob_up + weight_b * model_b_prob_up + weight_w * model_w_prob_up + weight_k * model_k_prob_up + weight_h * model_h_prob_up : 0.5

// v9: HAWKES MODIFIER
// When Hawkes intensity is high (crisis brewing), pull probability toward 0.5
// since we're in a regime where directional bets are unreliable.
// The modifier strength scales with how far above threshold we are.
hawkes_modifier_strength = use_hawkes and hawkes_warning ? math.min(0.50, (hawkes_intensity_ratio - hawkes_warning_threshold) / hawkes_warning_threshold) : 0.0

bayes_prob_up = 0.5 + (bayes_prob_up_raw - 0.5) * (1.0 - hawkes_modifier_strength)

// Calibration count arrays (declared early so f_calib_shrinkage can read them)
var array<int> calib_predictions = array.new<int>(5, 0)
var array<int> calib_correct     = array.new<int>(5, 0)

// Track pending calibration entries
var array<int>   calib_pending_bars  = array.new<int>()
var array<int>   calib_pending_bins  = array.new<int>()
var array<int>   calib_pending_dir   = array.new<int>()
var array<float> calib_pending_price = array.new<float>()

// v11: Regime-specific calibration arrays (3 regimes × 5 bins each)
var array<int> calib_predictions_bull  = array.new<int>(5, 0)
var array<int> calib_correct_bull      = array.new<int>(5, 0)
var array<int> calib_predictions_bear  = array.new<int>(5, 0)
var array<int> calib_correct_bear      = array.new<int>(5, 0)
var array<int> calib_predictions_range = array.new<int>(5, 0)
var array<int> calib_correct_range     = array.new<int>(5, 0)
var array<int> calib_pending_regime    = array.new<int>()

// v11: Wilson score confidence interval — more accurate than normal approximation
// for binomial proportions with small n.
//   CI = (p̂ + z²/2n ± z√(p̂(1-p̂)/n + z²/4n²)) / (1 + z²/n)
f_wilson_ci(int n_correct, int n_predictions, float z) =>
    float lo = na
    float hi = na
    if n_predictions >= 5
        float p_hat = n_correct / float(n_predictions)
        float denom = 1.0 + z * z / n_predictions
        float center = (p_hat + z * z / (2.0 * n_predictions)) / denom
        float halfwidth = z * math.sqrt(p_hat * (1.0 - p_hat) / n_predictions + z * z / (4.0 * n_predictions * n_predictions)) / denom
        lo := center - halfwidth
        hi := center + halfwidth
    [lo, hi]

// v8: CALIBRATION-LEARNED SHRINKAGE
// If the calibration tracker shows that our predictions in this probability
// bin have been historically overconfident, shrink the prediction toward 0.5.
//
//   shrunk_p = 0.5 + (raw_p - 0.5) * shrinkage_factor
//
// Where shrinkage_factor = min(1.0, actual_rate_in_bin / predicted_midpoint).
// If we said 65% and actually hit 50%, shrinkage_factor = 0.5/0.65 = 0.77,
// so a future "65%" prediction becomes 0.5 + 0.15*0.77 = 0.615.

f_calib_shrinkage(p) =>
    float shrink = 1.0
    if use_calibration and use_bayes_ensemble
        float dist = math.abs(p - 0.5)
        int bin = -1
        if dist < 0.05
            bin := -1
        else if dist < 0.15
            bin := 0
        else if dist < 0.25
            bin := 1
        else if dist < 0.35
            bin := 2
        else if dist < 0.45
            bin := 3
        else
            bin := 4
        if bin >= 0 and array.size(calib_predictions) > bin
            int n_p = array.get(calib_predictions, bin)
            int n_c = array.get(calib_correct, bin)
            // Only apply shrinkage if we have enough samples (>= 30)
            if n_p >= 30
                float actual_rate = n_c / float(n_p)
                float pred_mid = 0.55 + bin * 0.10  // mid of bin
                // If actual << predicted, shrink toward 0.5
                if actual_rate < pred_mid
                    shrink := math.max(0.5, actual_rate / pred_mid)
    shrink

shrinkage_factor = f_calib_shrinkage(bayes_prob_up)
bayes_prob_up_shrunk = 0.5 + (bayes_prob_up - 0.5) * shrinkage_factor

// Bayes ensemble direction & confidence (use SHRUNK probability)
bayes_direction = bayes_prob_up_shrunk > 0.5 + 0.005 ? 1 : bayes_prob_up_shrunk < 0.5 - 0.005 ? -1 : 0
bayes_confidence = math.abs(bayes_prob_up_shrunk - 0.5) * 2  // 0 = uncertain, 1 = certain

// --- Step 5: Conjunction filter ---
// All three models must agree on direction for trade to fire (when conjunction enabled).
// We say a model "agrees" if its P(up) is on the same side of 0.5 as the ensemble.

// v9: 5-model conjunction with majority rule (at least 3 of 5 agree on direction)
// Pure "all agree" would be too strict with 5 models. We use 3-of-5 majority.
up_count = (model_a_prob_up > 0.5 ? 1 : 0) + (model_b_prob_up > 0.5 ? 1 : 0) + (model_w_prob_up > 0.5 ? 1 : 0) + (model_k_prob_up > 0.5 ? 1 : 0) + (model_h_prob_up > 0.5 ? 1 : 0)
dn_count = (model_a_prob_up < 0.5 ? 1 : 0) + (model_b_prob_up < 0.5 ? 1 : 0) + (model_w_prob_up < 0.5 ? 1 : 0) + (model_k_prob_up < 0.5 ? 1 : 0) + (model_h_prob_up < 0.5 ? 1 : 0)

models_agree_up = up_count >= 3
models_agree_dn = dn_count >= 3

conjunction_pass_long  = not use_conjunction or (bayes_prob_up_shrunk >= bayes_prob_threshold and models_agree_up)
conjunction_pass_short = not use_conjunction or (bayes_prob_up_shrunk <= (1.0 - bayes_prob_threshold) and models_agree_dn)

// =============================================================================
// UPGRADE Z+ (v7): CALIBRATION TRACKER
// =============================================================================
// For each predicted probability bin, track actual hit rate over history.
// If the system says "70%" 100 times and only 55% hit, it's overconfident.
//
// We maintain 5 bins of predictions:
//   bin 0: 50-60%
//   bin 1: 60-70%
//   bin 2: 70-80%
//   bin 3: 80-90%
//   bin 4: 90%+
//
// Each bin has running counts of (predictions made, predictions correct).
// (Arrays are declared above, before f_calib_shrinkage which reads them.)

f_get_bin(p) =>
    float dist = math.abs(p - 0.5)
    int result = -1
    if dist < 0.05
        result := -1
    else if dist < 0.15
        result := 0
    else if dist < 0.25
        result := 1
    else if dist < 0.35
        result := 2
    else if dist < 0.45
        result := 3
    else
        result := 4
    result

if use_calibration and barstate.isconfirmed and use_bayes_ensemble
    int this_bin = f_get_bin(bayes_prob_up)
    if this_bin >= 0 and bayes_direction != 0
        array.push(calib_pending_bars,  bar_index)
        array.push(calib_pending_bins,  this_bin)
        array.push(calib_pending_dir,   bayes_direction)
        array.push(calib_pending_price, close)
        // v11: Record regime (0=Bull, 1=Bear, 2=Range), -1 if Hamilton inactive
        int curr_regime = hamilton_active ? (ham_dominant_state - 1) : -1
        array.push(calib_pending_regime, curr_regime)

    // Mature any predictions whose horizon has elapsed
    int ci = 0
    while ci < array.size(calib_pending_bars)
        int cpb = array.get(calib_pending_bars, ci)
        if bar_index - cpb >= calib_eval_horizon
            int  cbin   = array.get(calib_pending_bins,  ci)
            int  cdir   = array.get(calib_pending_dir,   ci)
            float cpric = array.get(calib_pending_price, ci)
            int  creg   = array.size(calib_pending_regime) > ci ? array.get(calib_pending_regime, ci) : -1
            // Was it correct?
            bool actual_up = close > cpric
            bool predicted_up = cdir == 1
            bool correct = actual_up == predicted_up

            array.set(calib_predictions, cbin, array.get(calib_predictions, cbin) + 1)
            if correct
                array.set(calib_correct, cbin, array.get(calib_correct, cbin) + 1)

            // v11: Update regime-specific tables
            if use_regime_calibration and creg >= 0
                if creg == 0
                    array.set(calib_predictions_bull, cbin, array.get(calib_predictions_bull, cbin) + 1)
                    if correct
                        array.set(calib_correct_bull, cbin, array.get(calib_correct_bull, cbin) + 1)
                else if creg == 1
                    array.set(calib_predictions_bear, cbin, array.get(calib_predictions_bear, cbin) + 1)
                    if correct
                        array.set(calib_correct_bear, cbin, array.get(calib_correct_bear, cbin) + 1)
                else if creg == 2
                    array.set(calib_predictions_range, cbin, array.get(calib_predictions_range, cbin) + 1)
                    if correct
                        array.set(calib_correct_range, cbin, array.get(calib_correct_range, cbin) + 1)

            array.remove(calib_pending_bars,  ci)
            array.remove(calib_pending_bins,  ci)
            array.remove(calib_pending_dir,   ci)
            array.remove(calib_pending_price, ci)
            if array.size(calib_pending_regime) > ci
                array.remove(calib_pending_regime, ci)
        else
            ci := ci + 1

    // Memory cap
    // v13: cap reduced 200→100 for faster array operations
    while array.size(calib_pending_bars) > 100
        array.shift(calib_pending_bars)
        array.shift(calib_pending_bins)
        array.shift(calib_pending_dir)
        array.shift(calib_pending_price)
        if array.size(calib_pending_regime) > 0
            array.shift(calib_pending_regime)


// v13: REMOVED original section (~125 lines)


// v13: REMOVED original section (~120 lines)

// =============================================================================
// VISUALIZATION: KAMA + REGIME BG
// =============================================================================

plot(show_kama ? kama_val : na, "KAMA", color = color.new(color.orange, 0), linewidth = 2)
bgcolor(show_regime_bg ? regime_color : na, title = "Regime BG")

// v13: Entry triangles REMOVED (entry-signal infrastructure)


// v13: REMOVED original section (~160 lines)

// =============================================================================
// v10: COMPACT 1-TABLE DISPLAY + PROBABILITY FUNNEL
// =============================================================================
// Replaces v9's three overlapping tables with:
//   1. A single 8-row compact table (top-right) showing only key info
//   2. A probability funnel projected forward from current bar
//
// Design principle: show what matters, hide what doesn't.

// Helper functions for color/text
f_sig_color(s) =>
    s ==  1 ? color.new(color.green, 0) : s == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)

f_sig_text(s) =>
    s ==  1 ? "BULL" : s == -1 ? "BEAR" : "—"

f_prob_color(p) =>
    p >= 0.58 ? color.new(color.lime, 0) : p >= 0.52 ? color.new(color.green, 0) : p >= 0.48 ? color.new(color.gray, 0) : p >= 0.42 ? color.new(color.orange, 0) : color.new(color.red, 0)

// =============================================================================
// PROBABILITY FUNNEL (NEW v10)
// =============================================================================
// Forward-projects 3 lines representing the 25th, 50th, and 75th percentile
// expected price levels at future bars. Together they form a funnel/cone
// that widens with √horizon (random-walk geometry).
//
// Mathematics:
//   For horizon h bars forward, percentile p:
//     band(p, h) = close × exp(z(p) × σ × √h)
//   where:
//     - σ = realized_vol (per-bar return std)
//     - z(p) = inverse standard normal at percentile p
//
//   z(0.25) ≈ -0.6745
//   z(0.50) =  0.0000  (median = current close)
//   z(0.75) ≈ +0.6745
//
// The funnel is CENTERED on close × exp(drift_per_bar × h), where drift
// is the Bayesian-ensemble-implied drift. If P(up) = 0.60, drift is slightly
// positive; the funnel tilts upward.

// =============================================================================
// PROBABILITY HORIZON COMET TRAIL VISUALIZATION
// =============================================================================
// Each percentile (P25/P50/P75) is drawn as a 3-layer comet:
//   Layer 1 (outer)  — width 7, opacity 80 (faint glow "tail")
//   Layer 2 (middle) — width 4, opacity 50 (medium body)
//   Layer 3 (core)   — width 2, opacity  0 (bright streak)
// Plus a glowing endpoint dot and tiny "Prob X%" label.
// Optional gradient cone fill in red→yellow→green between percentiles.

grp_funnel = "── Probability Horizon ──"
show_funnel        = input.bool(true, "Show Probability Horizon",     group = grp_funnel)
funnel_horizon     = input.int(20,    "Projection Horizon (bars)",    group = grp_funnel, minval = 5, maxval = 100, tooltip = "How far forward to project. Auto-scales with timeframe.")
funnel_drift_scale = input.float(1.0, "Drift Sensitivity",            group = grp_funnel, minval = 0.0, maxval = 3.0, step = 0.1, tooltip = "How much P(up) tilts the projection. 0 = flat, 3 = aggressive tilt.")
// iOS-vivid palette
funnel_p25_color   = input.color(#FF3B30,    "P25 color (low) ",   group = grp_funnel)
funnel_p50_color   = input.color(#FFCC00,    "P50 color (mid) ",   group = grp_funnel)
funnel_p75_color   = input.color(#34C759,    "P75 color (high)",   group = grp_funnel)
show_arrow_labels  = input.bool(true, "Show probability labels at endpoints", group = grp_funnel)
show_cone_fill     = input.bool(true, "Show gradient cone fill",        group = grp_funnel, tooltip = "Fills the area between percentiles with red→yellow→green gradient.")

// Inverse-normal at p=0.25 and p=0.75 (symmetric around 0)
funnel_z25 = -0.6745
funnel_z75 =  0.6745

// Implied drift from Bayesian probability
funnel_drift_per_bar = funnel_drift_scale * (bayes_prob_up_shrunk - 0.5) * realized_vol

// Comet trail components — 3 stacked lines per percentile + endpoint dots + labels
var line  comet_outer_25 = na
var line  comet_outer_50 = na
var line  comet_outer_75 = na
var line  comet_mid_25   = na
var line  comet_mid_50   = na
var line  comet_mid_75   = na
var line  comet_core_25  = na
var line  comet_core_50  = na
var line  comet_core_75  = na
var label endpoint_25    = na
var label endpoint_50    = na
var label endpoint_75    = na
var label label_p25      = na
var label label_p50      = na
var label label_p75      = na
var label anchor_dot     = na

// Gradient cone fill boxes (8 steps per side = 16 total)
var array<box> cone_fill_boxes = array.new<box>()

if barstate.islast and show_funnel and not na(realized_vol) and realized_vol > 0
    // Delete previous visuals
    line.delete(comet_outer_25)
    line.delete(comet_outer_50)
    line.delete(comet_outer_75)
    line.delete(comet_mid_25)
    line.delete(comet_mid_50)
    line.delete(comet_mid_75)
    line.delete(comet_core_25)
    line.delete(comet_core_50)
    line.delete(comet_core_75)
    label.delete(endpoint_25)
    label.delete(endpoint_50)
    label.delete(endpoint_75)
    label.delete(label_p25)
    label.delete(label_p50)
    label.delete(label_p75)
    label.delete(anchor_dot)
    for b in cone_fill_boxes
        box.delete(b)
    array.clear(cone_fill_boxes)

    int h = funnel_horizon

    // Total sigma over horizon h (Heston > Jump-Diffusion > pure Gaussian)
    float sigma_h = 0.0
    if use_heston
        sigma_h := math.sqrt(f_total_integrated_var(h))
    else
        float effective_sigma = use_jump_diffusion ? total_sigma_per_bar : realized_vol
        sigma_h := effective_sigma * math.sqrt(h)

    // Drift-adjusted center at horizon
    float center_h = close * math.exp(funnel_drift_per_bar * h)

    // Three percentile prices at horizon
    float p25_h = center_h * math.exp(funnel_z25 * sigma_h)
    float p50_h = center_h
    float p75_h = center_h * math.exp(funnel_z75 * sigma_h)

    int x_end = bar_index + h

    // ─── GRADIENT CONE FILL ───────────────────────────────────────────────
    // 8 stepped boxes per side (lower P25→P50 = red tint, upper P50→P75 = green tint)
    // Opacity steps from very faint at origin to slightly more visible at tip
    if show_cone_fill
        int fill_steps = 8
        for step = 0 to fill_steps - 1
            float frac0 = step      / float(fill_steps)
            float frac1 = (step + 1) / float(fill_steps)
            int x0 = bar_index + int(math.round(h * frac0))
            int x1 = bar_index + int(math.round(h * frac1))

            float p25_at_x0 = close + (p25_h - close) * frac0
            float p25_at_x1 = close + (p25_h - close) * frac1
            float p50_at_x0 = close + (p50_h - close) * frac0
            float p50_at_x1 = close + (p50_h - close) * frac1
            float p75_at_x0 = close + (p75_h - close) * frac0
            float p75_at_x1 = close + (p75_h - close) * frac1

            int opacity_low = int(math.round(92 - step * 1.5))
            color fill_lower = color.new(funnel_p25_color, opacity_low)
            box bx_low = box.new(x0, p50_at_x0, x1, p25_at_x1, border_color = na, bgcolor = fill_lower)
            array.push(cone_fill_boxes, bx_low)

            color fill_upper = color.new(funnel_p75_color, opacity_low)
            box bx_up = box.new(x0, p75_at_x1, x1, p50_at_x0, border_color = na, bgcolor = fill_upper)
            array.push(cone_fill_boxes, bx_up)

    // ─── COMET TRAIL: 3 stacked layers per percentile ─────────────────────
    // Outer halo (width 7, very faint)
    comet_outer_25 := line.new(bar_index, close, x_end, p25_h, color = color.new(funnel_p25_color, 80), width = 7, style = line.style_solid)
    comet_outer_50 := line.new(bar_index, close, x_end, p50_h, color = color.new(funnel_p50_color, 80), width = 7, style = line.style_solid)
    comet_outer_75 := line.new(bar_index, close, x_end, p75_h, color = color.new(funnel_p75_color, 80), width = 7, style = line.style_solid)

    // Middle body (width 4, semi-transparent)
    comet_mid_25 := line.new(bar_index, close, x_end, p25_h, color = color.new(funnel_p25_color, 50), width = 4, style = line.style_solid)
    comet_mid_50 := line.new(bar_index, close, x_end, p50_h, color = color.new(funnel_p50_color, 50), width = 4, style = line.style_solid)
    comet_mid_75 := line.new(bar_index, close, x_end, p75_h, color = color.new(funnel_p75_color, 50), width = 4, style = line.style_solid)

    // Bright core (width 2, fully opaque) — the streak's center
    comet_core_25 := line.new(bar_index, close, x_end, p25_h, color = funnel_p25_color, width = 2, style = line.style_solid)
    comet_core_50 := line.new(bar_index, close, x_end, p50_h, color = funnel_p50_color, width = 2, style = line.style_solid)
    comet_core_75 := line.new(bar_index, close, x_end, p75_h, color = funnel_p75_color, width = 2, style = line.style_solid)

    // ─── ANCHOR DOT (origin) ────────────────────────────────────────────────
    anchor_dot := label.new(bar_index, close, "●", style = label.style_none, textcolor = color.white, size = size.normal)

    // ─── GLOWING ENDPOINT DOTS ──────────────────────────────────────────────
    // Larger filled circles at each comet tip
    endpoint_25 := label.new(x_end, p25_h, "●", style = label.style_none, textcolor = funnel_p25_color, size = size.large)
    endpoint_50 := label.new(x_end, p50_h, "●", style = label.style_none, textcolor = funnel_p50_color, size = size.large)
    endpoint_75 := label.new(x_end, p75_h, "●", style = label.style_none, textcolor = funnel_p75_color, size = size.large)

    // ─── LABELS: probability, price level, and percent change ─────────────
    // Format (two lines per label):
    //   Line 1: "Prob 25%"
    //   Line 2: "24830 (-1.42%)"   <- whole-number price, signed % change
    if show_arrow_labels
        float pct25 = (p25_h / close - 1.0) * 100
        float pct50 = (p50_h / close - 1.0) * 100
        float pct75 = (p75_h / close - 1.0) * 100

        string txt_25 = "Prob 25%\n" + str.tostring(math.round(p25_h)) + " (" + str.tostring(pct25, "+#.##") + "%)"
        string txt_50 = "Prob 50%\n" + str.tostring(math.round(p50_h)) + " (" + str.tostring(pct50, "+#.##") + "%)"
        string txt_75 = "Prob 75%\n" + str.tostring(math.round(p75_h)) + " (" + str.tostring(pct75, "+#.##") + "%)"

        label_p25 := label.new(x_end, p25_h, txt_25, style = label.style_label_left, color = color.new(funnel_p25_color, 15), textcolor = color.white, size = size.tiny)
        label_p50 := label.new(x_end, p50_h, txt_50, style = label.style_label_left, color = color.new(funnel_p50_color, 15), textcolor = color.black, size = size.tiny)
        label_p75 := label.new(x_end, p75_h, txt_75, style = label.style_label_left, color = color.new(funnel_p75_color, 15), textcolor = color.white, size = size.tiny)




// =============================================================================
// v11: MONTE CARLO BOOTSTRAP CLOUD
// =============================================================================
// Bootstrap-resamples past returns to generate N simulated price paths.
// Each path is a sequence of randomly-drawn historical returns compounded
// forward from current close. The resulting cloud shows the EMPIRICAL
// distribution of forward outcomes — no Gaussian assumption.
//
// Implementation note: Pine v6 has no true RNG. We use a Linear Congruential
// Generator (LCG) seeded by bar_index for reproducibility within a session.

// Manage MC path lines (mc_pool_size now user-configurable via input)
var array<line> mc_lines = array.new<line>()

if barstate.islast and use_monte_carlo and not na(realized_vol) and realized_vol > 0
    // Clear old lines
    for ln in mc_lines
        line.delete(ln)
    array.clear(mc_lines)

    // Build return pool from history (going backward)
    int pool_size_actual = math.min(mc_pool_size, bar_index)
    array<float> return_pool = array.new<float>()
    for k = 1 to pool_size_actual
        float r = returns[k]
        if not na(r)
            array.push(return_pool, r)

    int pool_len = array.size(return_pool)

    if pool_len > 20
        int h_steps = funnel_horizon
        color path_color = color.new(mc_path_color, mc_path_transparency)

        // Generate mc_num_paths simulated paths
        for path_idx = 0 to mc_num_paths - 1
            // LCG state — seeded by path_idx + bar_index for variation per path
            int lcg_state = (bar_index + path_idx * 7919) % 2147483647
            if lcg_state <= 0
                lcg_state := lcg_state + 2147483647

            // Simulate path: anchor at close, step forward h_steps bars
            float curr_price = close
            int prev_x = bar_index
            float prev_y = close

            for step = 1 to h_steps
                // LCG: x_{n+1} = (a * x_n + c) mod m
                // Using widely-used constants from Numerical Recipes
                lcg_state := (lcg_state * 1103515245 + 12345) % 2147483647
                int idx = math.abs(lcg_state) % pool_len
                float r_sample = array.get(return_pool, idx)
                curr_price := curr_price * math.exp(r_sample)
                int curr_x = bar_index + step
                // Draw segment
                line seg = line.new(prev_x, prev_y, curr_x, curr_price, color = path_color, width = 1)
                array.push(mc_lines, seg)
                prev_x := curr_x
                prev_y := curr_price

                // Cap total lines to avoid hitting Pine's limit
                if array.size(mc_lines) >= 450
                    break
            if array.size(mc_lines) >= 450
                break

// =============================================================================
// COMPACT TABLE (8 rows × 3 cols) — v13 TRENDY REDESIGN
// =============================================================================
// Information hierarchy: huge verdict at top, supporting detail below.
// Color-coded labels per category for fast visual scanning.
//
// Color legend:
//   #34C759 lime green   — bullish / directional
//   #FFCC00 gold yellow  — models / consensus
//   #AF52DE purple       — regime
//   #5AC8FA cyan         — volatility
//   #FF9500 orange       — risk / warnings
//   #8E8E93 gray         — calibration / meta info

var table compact_tbl = table.new(position.top_right, 3, 8, bgcolor = color.new(#000000, 50), border_width = 1, frame_color = color.new(#3A3A3C, 30), frame_width = 1)

if show_dashboard and barstate.islast
    // -------- Determine verdict --------
    string state_text = "NEUTRAL"
    color state_color = #8E8E93
    string reason_text = ""

    if bayes_direction == 1 and bayes_prob_up_shrunk >= bayes_prob_threshold
        state_text  := "▲ BULL"
        state_color := #34C759
        reason_text := "P≥" + str.tostring(bayes_prob_threshold * 100, "#")  + "%"
    else if bayes_direction == -1 and bayes_prob_up_shrunk <= (1.0 - bayes_prob_threshold)
        state_text  := "▼ BEAR"
        state_color := #FF3B30
        reason_text := "P≤" + str.tostring((1.0 - bayes_prob_threshold) * 100, "#") + "%"
    else
        if regime == 3
            reason_text := "Crisis"
        else if hawkes_warning
            reason_text := "Hawkes ⚠"
        else if use_conjunction and not conjunction_pass_long and not conjunction_pass_short
            reason_text := "Models split"
        else
            reason_text := "below threshold"

    // ─── Mini probability bar (10 chars: filled vs unfilled) ──────────────
    int prob_int = int(math.round(bayes_prob_up_shrunk * 10))
    string prob_bar = ""
    for i = 0 to 9
        prob_bar := prob_bar + (i < prob_int ? "█" : "░")
    // bar color tinted by direction
    color prob_bar_color = bayes_prob_up_shrunk > 0.55 ? #34C759 : bayes_prob_up_shrunk < 0.45 ? #FF3B30 : #FFCC00

    // ─── Shrinkage indicator: explicit delta in percentage points ─────────
    // (Avoids confusing ▲▼ symbols. Shrinkage always pulls toward 0.5, so
    //  the SIGN tells you which direction the raw P(up) was nudged.)
    float shrinkage_delta = bayes_prob_up_shrunk - bayes_prob_up_raw
    string shrink_text = ""
    if math.abs(shrinkage_delta) < 0.005
        shrink_text := ""
    else
        shrink_text := "(" + (shrinkage_delta > 0 ? "+" : "") + str.tostring(shrinkage_delta * 100, "#.#") + "pp shrink) "

    // ─── Model agreement icons (▲▼ per model based on each model's P) ────
    string models_icons = ""
    models_icons := models_icons + (model_a_prob_up > 0.5 ? "▲" : model_a_prob_up < 0.5 ? "▼" : "·")
    models_icons := models_icons + (model_b_prob_up > 0.5 ? "▲" : model_b_prob_up < 0.5 ? "▼" : "·")
    models_icons := models_icons + (model_w_prob_up > 0.5 ? "▲" : model_w_prob_up < 0.5 ? "▼" : "·")
    models_icons := models_icons + (model_k_prob_up > 0.5 ? "▲" : model_k_prob_up < 0.5 ? "▼" : "·")
    models_icons := models_icons + (model_h_prob_up > 0.5 ? "▲" : model_h_prob_up < 0.5 ? "▼" : "·")
    int agree_count_v = bayes_direction == 1 ? up_count : bayes_direction == -1 ? dn_count : 0
    color consensus_color = agree_count_v >= 4 ? #34C759 : agree_count_v == 3 ? #FFCC00 : #FF9500
    string consensus_text = bayes_direction == 0 ? "—" : str.tostring(agree_count_v) + "/5"

    // ─── Calibration / Honesty ─────────────────────────────────────────────
    int n50 = array.get(calib_predictions, 0)
    int c50 = array.get(calib_correct, 0)
    float actual50 = n50 > 0 ? c50 * 100.0 / n50 : na
    color calib_color = n50 < 30 ? #8E8E93 : math.abs(actual50 - 55) < 5 ? #34C759 : actual50 < 50 ? #FF3B30 : actual50 < 53 ? #FF9500 : #5AC8FA
    [wilson_lo, wilson_hi] = f_wilson_ci(c50, n50, 1.96)
    float wilson_halfwidth = (not na(wilson_lo) and not na(wilson_hi)) ? (wilson_hi - wilson_lo) * 50 : na
    string calib_value = n50 < 5 ? "—" : not na(wilson_halfwidth) ? str.tostring(actual50, "#") + "±" + str.tostring(wilson_halfwidth, "#") + "%" : str.tostring(actual50, "#") + "%"
    string calib_verdict = n50 < 30 ? "warming up" : actual50 >= 53 and actual50 <= 58 ? "✓ honest" : actual50 < 50 ? "⚠ overconfident" : actual50 < 53 ? "⚠ slightly off" : "✓ conservative"

    // ─── Regime cell ──────────────────────────────────────────────────────
    color regime_col = regime == 3 ? #AF52DE : regime == 2 ? #FFCC00 : regime == 0 ? #34C759 : #FF3B30
    string ham_state = not hamilton_active ? "off" : ham_dominant_state == 1 ? "Bull" : ham_dominant_state == 2 ? "Bear" : "Range"
    color ham_col = not hamilton_active ? #8E8E93 : ham_dominant_state == 1 ? #34C759 : ham_dominant_state == 2 ? #FF3B30 : #FFCC00

    // ─── Vol state + funnel sigma ─────────────────────────────────────────
    // Symbol convention: ↘ = vol decaying toward mean, ↗ = vol rising toward mean
    float disp_sigma = use_jump_diffusion ? total_sigma_per_bar : realized_vol
    string sigma_tag = use_heston ? "HSV" : use_jump_diffusion ? "JD" : "Gauss"
    if use_vov_uncertainty and use_heston
        sigma_tag := sigma_tag + "+VoV"
    string vol_state_text = "● at mean"
    color  vol_state_col  = #8E8E93
    if use_heston
        if vol_state_high
            // Vol is elevated above mean; expected to decay back. Cone will narrow.
            vol_state_text := "↘ HIGH +" + str.tostring(vol_ratio * 100, "#") + "%"
            vol_state_col  := #FF9500
        else if vol_state_low
            // Vol is compressed below mean; expected to rise back. Cone will widen.
            vol_state_text := "↗ LOW −" + str.tostring(math.abs(vol_ratio) * 100, "#") + "%"
            vol_state_col  := #5AC8FA

    // ─── Risk / Hawkes ─────────────────────────────────────────────────────
    string hawkes_status = not use_hawkes ? "off" : hawkes_warning ? "⚠ CRISIS" : "✓ calm"
    color  hawkes_col    = not use_hawkes ? #8E8E93 : hawkes_warning ? #AF52DE : #34C759

    // ─── Sample / trust ────────────────────────────────────────────────────
    int total_preds = 0
    for bi = 0 to 4
        total_preds := total_preds + array.get(calib_predictions, bi)
    string trust_text = total_preds > 200 ? "✓ OK" : total_preds > 50 ? "warm-up" : "low"
    color  trust_col  = total_preds > 200 ? #34C759 : total_preds > 50 ? #FFCC00 : #8E8E93

    // =============================== RENDER ===============================
    color hdr_bg = color.new(#1C1C1E, 30)

    // ─── Row 0: HUGE VERDICT (the focal point) ───────────────────────────
    table.cell(compact_tbl, 0, 0, state_text,  text_color = state_color, bgcolor = hdr_bg, text_size = size.large)
    table.cell(compact_tbl, 1, 0, str.tostring(bayes_prob_up_shrunk * 100, "#.#") + "%", text_color = state_color, bgcolor = hdr_bg, text_size = size.large)
    table.cell(compact_tbl, 2, 0, "P(up)",     text_color = #8E8E93,     bgcolor = hdr_bg, text_size = size.tiny)

    // ─── Row 1: Probability bar + shrinkage ──────────────────────────────
    table.cell(compact_tbl, 0, 1, "● Direction", text_color = #34C759, text_size = size.tiny)
    table.cell(compact_tbl, 1, 1, prob_bar,      text_color = prob_bar_color, text_size = size.tiny)
    table.cell(compact_tbl, 2, 1, shrink_text + reason_text, text_color = #8E8E93, text_size = size.tiny)

    // ─── Row 2: Model agreement ──────────────────────────────────────────
    table.cell(compact_tbl, 0, 2, "● 5 Models",  text_color = #FFCC00, text_size = size.tiny)
    table.cell(compact_tbl, 1, 2, models_icons,  text_color = consensus_color, text_size = size.tiny)
    table.cell(compact_tbl, 2, 2, consensus_text + " agree", text_color = consensus_color, text_size = size.tiny)

    // ─── Row 3: Regime (combined market + Hamilton) ──────────────────────
    table.cell(compact_tbl, 0, 3, "● Regime",   text_color = #AF52DE, text_size = size.tiny)
    table.cell(compact_tbl, 1, 3, regime_name,  text_color = regime_col, text_size = size.tiny)
    table.cell(compact_tbl, 2, 3, "Ham: " + ham_state, text_color = ham_col, text_size = size.tiny)

    // ─── Row 4: Vol state + funnel sigma ─────────────────────────────────
    table.cell(compact_tbl, 0, 4, "● Vol",      text_color = #5AC8FA, text_size = size.tiny)
    table.cell(compact_tbl, 1, 4, vol_state_text, text_color = vol_state_col, text_size = size.tiny)
    table.cell(compact_tbl, 2, 4, "σ=" + str.tostring(disp_sigma * 100, "#.##") + "% " + sigma_tag, text_color = #8E8E93, text_size = size.tiny)

    // ─── Row 5: Risk / Hawkes / Crisis ───────────────────────────────────
    table.cell(compact_tbl, 0, 5, "● Risk",     text_color = #FF9500, text_size = size.tiny)
    table.cell(compact_tbl, 1, 5, hawkes_status, text_color = hawkes_col, text_size = size.tiny)
    table.cell(compact_tbl, 2, 5, "Hawkes",     text_color = #8E8E93, text_size = size.tiny)

    // ─── Row 6: Honesty / Calibration ────────────────────────────────────
    table.cell(compact_tbl, 0, 6, "● Honesty",  text_color = #8E8E93, text_size = size.tiny)
    table.cell(compact_tbl, 1, 6, calib_value,  text_color = calib_color, text_size = size.tiny)
    table.cell(compact_tbl, 2, 6, calib_verdict, text_color = calib_color, text_size = size.tiny)

    // ─── Row 7: Samples ──────────────────────────────────────────────────
    table.cell(compact_tbl, 0, 7, "● Samples",  text_color = #8E8E93, text_size = size.tiny)
    table.cell(compact_tbl, 1, 7, str.tostring(total_preds), text_color = trust_col, text_size = size.tiny)
    table.cell(compact_tbl, 2, 7, "trust: " + trust_text, text_color = trust_col, text_size = size.tiny)

// INDICATOR MODE - no strategy execution
// =============================================================================
// v10 converted to indicator. The script no longer manages positions or
// simulates trades — it only displays signals, models, and probabilities.
// To act on signals, use the alerts defined below or trade manually.

atr_val = ta.atr(atr_period)

// =============================================================================
// ALERTS — v13: probability/regime/vol alerts only (no entry-signal alerts)
// =============================================================================

// Regime
alertcondition(regime == 3 and regime[1] != 3, title = "Crisis Regime Entry", message = "PH-SVJD: CRISIS regime on {{ticker}}")

// Bayesian probability threshold crosses
alertcondition(use_bayes_ensemble and bayes_prob_up_shrunk >= bayes_prob_threshold and bayes_prob_up_shrunk[1] < bayes_prob_threshold, title = "Bayes Bullish Threshold Crossed", message = "PH-SVJD: Bayesian ensemble crossed bullish threshold on {{ticker}}")
alertcondition(use_bayes_ensemble and bayes_prob_up_shrunk <= (1.0 - bayes_prob_threshold) and bayes_prob_up_shrunk[1] > (1.0 - bayes_prob_threshold), title = "Bayes Bearish Threshold Crossed", message = "PH-SVJD: Bayesian ensemble crossed bearish threshold on {{ticker}}")
alertcondition(use_conjunction and use_bayes_ensemble and models_agree_up and bayes_prob_up_shrunk >= bayes_prob_threshold and not (models_agree_up[1] and bayes_prob_up_shrunk[1] >= bayes_prob_threshold), title = "Majority Models Agree Bullish", message = "PH-SVJD: Majority of models agree BULLISH on {{ticker}}")
alertcondition(use_conjunction and use_bayes_ensemble and models_agree_dn and bayes_prob_up_shrunk <= (1.0 - bayes_prob_threshold) and not (models_agree_dn[1] and bayes_prob_up_shrunk[1] <= (1.0 - bayes_prob_threshold)), title = "Majority Models Agree Bearish", message = "PH-SVJD: Majority of models agree BEARISH on {{ticker}}")

// Hawkes
alertcondition(use_hawkes and hawkes_warning and not hawkes_warning[1], title = "Hawkes Crisis Warning", message = "PH-SVJD: HAWKES intensity spiking on {{ticker}} - crisis likely imminent")
alertcondition(use_hawkes and not hawkes_warning and hawkes_warning[1], title = "Hawkes Crisis Cleared", message = "PH-SVJD: HAWKES intensity normalized on {{ticker}} - crisis warning cleared")

// Hamilton regime transitions
alertcondition(use_hamilton and ham_dominant_state == 1 and ham_dominant_state[1] != 1, title = "Hamilton: Bull Regime", message = "PH-SVJD: Hamilton 3-state model entered BULL regime on {{ticker}}")
alertcondition(use_hamilton and ham_dominant_state == 2 and ham_dominant_state[1] != 2, title = "Hamilton: Bear Regime", message = "PH-SVJD: Hamilton 3-state model entered BEAR regime on {{ticker}}")
alertcondition(use_hamilton and ham_dominant_state == 3 and ham_dominant_state[1] != 3, title = "Hamilton: Range Regime", message = "PH-SVJD: Hamilton 3-state model entered RANGE regime on {{ticker}}")

// Jump-Diffusion
alertcondition(use_jump_diffusion and is_jump_bar, title = "Jump Detected", message = "PH-SVJD: Jump-diffusion detected an outlier return on {{ticker}}")

// Heston vol-state transitions
alertcondition(use_heston and vol_state_high and not vol_state_high[1], title = "Vol Regime: HIGH", message = "PH-SVJD: Vol elevated above mean on {{ticker}} - funnel will narrow")
alertcondition(use_heston and vol_state_low and not vol_state_low[1], title = "Vol Regime: LOW", message = "PH-SVJD: Vol depressed below mean on {{ticker}} - funnel will widen")
alertcondition(use_heston and vol_state_mid and (vol_state_high[1] or vol_state_low[1]), title = "Vol Returned to Mean", message = "PH-SVJD: Vol mean-reverted to long-term level on {{ticker}}")

// =============================================================================
// EXPORT PLOTS — for use as input.source() in downstream scripts
// =============================================================================
// All exports use display = display.data_window so they don't appear on the
// chart but ARE selectable in any other indicator's source dropdown.
//
// Plot-budget accounting (TradingView max = 64 plot units per script):
//   Existing in this script:
//     - 1 plot() call (KAMA)              =  1 unit (const color)
//     - 14 alertcondition() calls         = 14 units
//     - Subtotal already used              = 15 units
//   This export block adds:
//     - 25 plot() calls (all const color)  = 25 units
//   Grand total                            = 40 units
//   Headroom remaining                     = 24 units
//
// Rules followed to stay within budget:
//   1. Every export uses a CONST color (color.new(color.gray, 100), fully
//      transparent) → 1 plot unit each (NOT 2, which would happen with a
//      dynamic series color).
//   2. Booleans encoded as 0/1 floats.
//   3. Categorical values (regime, Hamilton state) encoded as integers.
//   4. Drawing objects (lines/boxes/labels/tables/bgcolor) do NOT count.
//
// To consume these in another script, use:
//   src = input.source(close, "Bayes Probability")
//   // User then picks "PH-SVJD: Out: Bayes P(up)" from the dropdown.
//
// One input.source() per value. There is no way in Pine to export a struct
// or array — each downstream script must wire each value individually.
// =============================================================================

// --- 1. Master toggle (lets the user turn the whole export OFF if not needed) ---
grp_export = "── Output for Other Scripts ──"
enable_exports = input.bool(true, "Enable Output Plots",
     group = grp_export,
     tooltip = "When ON, this script exposes 25 calculated values as plots in the data window (hidden from chart). Other scripts can consume them via input.source(). Turn OFF to free up 25 plot slots if you need to add more alertconditions or visual plots.")

// --- 2. Encode booleans/categoricals as numeric series so plot() can handle them ---
out_bayes_dir_f      = float(bayes_direction)               // -1, 0, +1
out_ham_state_f      = hamilton_active ? float(ham_dominant_state) : na  // 1, 2, 3
out_regime_f         = float(regime)                        // 0, 1, 2, 3
out_vol_state_f      = vol_state_high ? 1.0 : vol_state_low ? -1.0 : 0.0
out_hawkes_warn_f    = hawkes_warning ? 1.0 : 0.0
out_jump_f           = is_jump_bar ? 1.0 : 0.0
out_models_agree_f   = bayes_direction == 1 ? float(up_count) : bayes_direction == -1 ? float(dn_count) : 0.0

// --- 3. Plots (all use a const transparent color → 1 plot unit each) ---
// Gated on `enable_exports` so the user can disable to recover plot budget.

// === Core probability outputs (5) ===
plot(enable_exports ? bayes_prob_up_shrunk : na, "Out: Bayes P(up)",         color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? bayes_prob_up_raw    : na, "Out: Bayes P(up) Raw",     color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? out_bayes_dir_f      : na, "Out: Bayes Direction",     color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? bayes_confidence     : na, "Out: Bayes Confidence",    color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? shrinkage_factor     : na, "Out: Shrinkage Factor",    color = color.new(color.gray, 100), display = display.data_window)

// === Per-model probabilities + agreement (6) ===
plot(enable_exports ? model_a_prob_up      : na, "Out: Model A P(up) Trend", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? model_b_prob_up      : na, "Out: Model B P(up) MeanRev", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? model_w_prob_up      : na, "Out: Model W P(up) Wavelet", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? model_k_prob_up      : na, "Out: Model K P(up) Kalman", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? model_h_prob_up      : na, "Out: Model H P(up) Hamilton", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? out_models_agree_f   : na, "Out: Models Agree Count",  color = color.new(color.gray, 100), display = display.data_window)

// === Regime / state codes (5) ===
plot(enable_exports ? out_regime_f         : na, "Out: Regime Code (0=QuietBull 1=QuietBear 2=Range 3=Crisis)", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? out_ham_state_f      : na, "Out: Hamilton State (1=Bull 2=Bear 3=Rng)", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? p_bull               : na, "Out: Hamilton P(Bull)",    color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? p_bear               : na, "Out: Hamilton P(Bear)",    color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? hurst                : na, "Out: Hurst Exponent",      color = color.new(color.gray, 100), display = display.data_window)

// === Volatility / risk (7) ===
plot(enable_exports ? realized_vol         : na, "Out: Realized Vol",        color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? total_sigma_per_bar  : na, "Out: Total Sigma (JD)",    color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? heston_theta         : na, "Out: Heston Theta",        color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? out_vol_state_f      : na, "Out: Vol State (-1/0/+1)", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? hawkes_intensity_ratio : na, "Out: Hawkes Intensity Ratio", color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? out_hawkes_warn_f    : na, "Out: Hawkes Warning",      color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? out_jump_f           : na, "Out: Jump Detected",       color = color.new(color.gray, 100), display = display.data_window)

// === Forecast cone endpoints (2) — only valid on barstate.islast, na elsewhere ===
// These let a downstream script read the P25/P75 horizon prices the cone is
// currently projecting. We recompute them here (cheap) and gate on islast.
var float out_p25_h = na
var float out_p75_h = na
if barstate.islast and show_funnel and not na(realized_vol) and realized_vol > 0
    int h2 = funnel_horizon
    float sigma_h2 = use_heston ? math.sqrt(f_total_integrated_var(h2)) : (use_jump_diffusion ? total_sigma_per_bar : realized_vol) * math.sqrt(h2)
    float center_h2 = close * math.exp(funnel_drift_per_bar * h2)
    out_p25_h := center_h2 * math.exp(funnel_z25 * sigma_h2)
    out_p75_h := center_h2 * math.exp(funnel_z75 * sigma_h2)

plot(enable_exports ? out_p25_h            : na, "Out: P25 Horizon Price",   color = color.new(color.gray, 100), display = display.data_window)
plot(enable_exports ? out_p75_h            : na, "Out: P75 Horizon Price",   color = color.new(color.gray, 100), display = display.data_window)

// =============================================================================
// END EXPORT BLOCK
// =============================================================================
````
