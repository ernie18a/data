# Random Forest Regressor - Return Estimator

- url: https://www.tradingview.com/script/4OspJFAd-Random-Forest-Regressor-Return-Estimator/
- type: indicator
- pine_id: PUB;1fb0a0a9f8b6465dbfcd28ad4a2f902e
- version: 1.0

## Description

[b]Random Forest Regressor — Return Estimator[/b] is an educational example of how to build, train, and deploy a multi-output Random Forest regressor entirely inside Pine Script v6. The script estimates the percent price change over the next 1 to 20 bars and renders the resulting trajectory as a polyline with OOB-calibrated prediction interval bands.

Powered by [b]RandomForestLibrary[/b].

[b]What Makes This Different[/b]

Most "prediction" indicators on TradingView either (a) project a single point one bar ahead, or (b) draw an extrapolation based on a closed-form curve (linear regression, polynomial fit). This script does neither. It trains a genuine Random Forest ensemble on the last N bars of the current chart, learns a separate regression target per horizon (H1 through H20), and plots the [i]mean predicted path[/i] together with [i]OOB-residual-calibrated uncertainty bands[/i] that widen with horizon distance.

It is labeled as a [b]Regressor[/b] and a [b]Return Estimator[/b] — not a "Forecast" — deliberately. The polyline is a conditional expectation estimate given the current feature values, not a guarantee of future prices. The 90% and 95% bands show how much residual uncertainty the model had on its own out-of-bag samples.

[b]What It Does[/b]

[list]
[*] Computes 8 engineered features on every bar (RSI, ATR %, CCI, Volume Ratio, Price vs SMA50, 10-bar Momentum, BB Width, ADX).
[*] On the last bar only, constructs a training matrix of the last N bars and a multi-target matrix of future percent returns at horizons 1 to [b]Forecast Horizon[/b].
[*] Trains a Random Forest regressor (bootstrap aggregation, CART trees with MSE splits, out-of-bag accumulation).
[*] Predicts the 1-to-20 bar return trajectory for the current bar and draws it as a polyline.
[*] Draws 90% and 95% prediction interval bands using per-horizon OOB residual standard deviation.
[*] Renders a diagnostics dashboard (OOB R^2, per-horizon predictions, feature importance bars).
[/list]

[b]How It Works[/b]

[b]Eight features (why this set)[/b]

[list]
[*] [b]RSI(14)[/b] — oscillatory position / overbought-oversold
[*] [b]ATR %[/b] — absolute volatility scaled by price
[*] [b]CCI(20)[/b] — deviation from moving average in standard deviations
[*] [b]Volume Ratio[/b] — current volume vs its 20-bar SMA
[*] [b]Price vs SMA50[/b] — medium-term trend position
[*] [b]Momentum(10)[/b] — 10-bar percentage change
[*] [b]BB Width %[/b] — Bollinger Band compression / expansion
[*] [b]ADX(14)[/b] — directional movement strength
[/list]

The feature set deliberately mixes oscillators (RSI, CCI), volatility indicators (ATR %, BB Width), trend indicators (Price vs SMA50, ADX), and momentum (10-bar return) so the forest can find complementary split dimensions rather than redundant ones. Volume Ratio adds a non-price axis that is independent of the others.

[b]Multi-target training[/b]

For every training bar [icode]i[/icode] the target row is the vector of percent returns [icode][r_{i,1}, r_{i,2}, ..., r_{i,H}][/icode] where [icode]r_{i,h} = (close[i+h] - close[i]) / close[i] * 100[/icode]. The Random Forest is fit in regressor mode, so each leaf stores one mean return per horizon. This is an honest multi-horizon model — not the same 1-bar prediction compounded forward.

[b]Prediction intervals (Out-of-Bag residual method)[/b]

During training, every sample that is not drawn into a given tree's bootstrap contributes an out-of-bag prediction error to its horizon. The standard deviation of these errors, computed per horizon, estimates residual uncertainty. The plotted bands are:

[list]
[*] [b]90% band[/b] = mean ± 1.645 × OOB residual std
[*] [b]95% band[/b] = mean ± 1.960 × OOB residual std
[/list]

Because residual variance naturally grows with horizon, the bands form a fan — narrow at H1, wide at H20. This is a self-calibration using only training data, no separate holdout required. Reference: Wager, Hastie, and Efron (2014).

[b]Non-repainting design[/b]

All training and inference run only on [icode]barstate.islast[/icode]. The model is rebuilt from scratch on the final bar using only past data; no future look-ahead is possible by construction. The forecast line you see on the last bar is what the model would have produced when that bar closed.

[b]Dashboard[/b]

[list]
[*] [b]Direction[/b] — sign of the final horizon prediction (Bullish / Bearish)
[*] [b]OOB R^2[/b] — out-of-bag coefficient of determination, averaged across horizons (honest generalization estimate)
[*] [b]Trees / Depth[/b], [b]Training / Horizon[/b] — current configuration
[*] [b]Pred H5 / H10 / H20[/b] — predicted percent change at three horizons
[*] [b]PI Width H20[/b] — width of the 95% band at the farthest horizon (uncertainty scale)
[*] [b]OOB Res. Std[/b] — residual standard deviation averaged across all horizons
[*] [b]Feature Importance[/b] — weighted MSE decrease per feature, displayed as Unicode bar graphs; the highest-importance feature is highlighted
[/list]

[b]Inputs[/b]

[list]
[*] [b]Number of Trees[/b] — 1 to 15, default 10
[*] [b]Max Depth[/b] — 1 to 6, default 4
[*] [b]Training Bars[/b] — 100 to 1000, default 500
[*] [b]Threshold Candidates[/b] — 3 to 10, default 5
[*] [b]Random Seed[/b] — default 42 (change for a different ensemble)
[*] [b]Min Samples per Leaf[/b] — 5 to 50, default 10
[*] [b]Forecast Horizon[/b] — 5 to 30 bars, default 20
[*] [b]Show 90% / 95% PI[/b] — on/off
[*] [b]Colors[/b] — forecast line, 90% band fill, 95% band fill
[*] [b]Show Dashboard[/b] — on/off
[/list]

[b]How To Use[/b]

This script is primarily a [b]demonstration of RandomForestLibrary[/b] and an [b]educational reference implementation[/b] of multi-horizon regression with calibrated uncertainty. Practical usage notes:

[list]
[*] Treat the forecast line as a [b]conditional mean estimate[/b], not a price target. Single ensemble runs on financial time series are noisy; expect the line to shift as new bars print.
[*] Use [b]OOB R^2[/b] as a trust indicator. Negative or near-zero values mean the features had little predictive signal on the training window; do not rely on the forecast in that case.
[*] Use the [b]width of the prediction interval[/b] as a volatility / uncertainty read. A narrow band at H20 indicates the model saw consistent residuals; a wide band means future moves could plausibly be anywhere within that range.
[*] The [b]feature importance bars[/b] tell you which inputs drove this particular forecast. If one feature dominates, the prediction is fragile — it depends almost entirely on that signal.
[*] [b]Timeframe and data[/b]: works on any OHLCV market but needs at least Training Bars + Forecast Horizon + 50 bars of history before producing output.
[/list]

[b]About the Model and Training[/b]

[list]
[*] [b]On-chart training, no pre-trained model.[/b] The Random Forest is rebuilt from scratch on the last bar of the visible chart every time the script recomputes. There is no imported dataset, no uploaded weights, and no external training pipeline — the ensemble exists only within the current chart session.
[*] [b]Training data source and window.[/b] Training uses the most recent [b]Training Bars[/b] confirmed bars on the chart (default 500; configurable 100–1000), leaving [b]Forecast Horizon[/b] additional bars at the end so every training sample has a complete future-return vector. The label for bar [icode]i[/icode] is the [icode]H[/icode]-horizon vector of percent returns [icode](close[i+h] - close[i]) / close[i] * 100[/icode] for [icode]h = 1..H[/icode].
[*] [b]Not a walk-forward / rolling-window evaluator.[/b] The model is fit once on the training window and then queried on the current bar. It is not a walk-forward backtest. The OOB R^2 shown on the dashboard is computed on the same training window, not on a separate time period.
[*] [b]Out-of-bag evaluation.[/b] Each tree trains on a bootstrap sample (~63% of rows). The remaining rows become that tree's OOB set and are used to compute the OOB R^2 and per-horizon residual standard deviation displayed in the dashboard and used to draw the prediction interval bands.
[*] [b]Overfitting controls.[/b] The defaults are intentionally conservative: [b]Max Depth = 4[/b] (≤31 nodes per tree), [b]Min Samples per Leaf = 10[/b] (leaves stop splitting below 20 samples), [b]Threshold Candidates = 5[/b] per feature at each split, and automatic feature subsampling (each split sees only [icode]ceil(n_features / 3) = 3[/icode] of the 8 features). These four controls together limit variance from individual trees. Raising depth, lowering [icode]min_samples_leaf[/icode], or using a very short training window will produce visibly overfitted in-sample forecasts with unreliable OOB R^2 — tune with care.
[*] [b]Deterministic given a seed.[/b] Identical [b]Random Seed[/b] + identical training window + identical hyperparameters → identical forest and identical forecast. Use the seed to reproduce or to generate ensemble variance across multiple runs.
[/list]

[b]Notes and Limitations[/b]

[list]
[*] This is an educational reference implementation. It does not guarantee profit, does not forecast actual future prices, and should not be used as a standalone trading signal. The polyline is a conditional mean estimate, not a price path.
[*] A Random Forest trained on recent data learns recent market behavior. Regime changes (volatility shocks, news-driven gaps) can invalidate the fit until enough new bars accumulate after the regime shift.
[*] [b]Overfitting risk.[/b] A Random Forest trained on ~500 bars of a single instrument can over-fit local patterns even with depth 4 and a leaf minimum of 10. A positive OOB R^2 on the training window is an internal cross-validation signal, not a guarantee of out-of-sample performance.
[*] Prediction intervals assume OOB residuals are representative of future residuals. If the market enters a regime the training window did not cover, intervals can understate true uncertainty.
[*] The polyline extrapolates as a discrete sequence of horizon means; it is not a continuous stochastic path and should not be read as one. Consecutive horizon predictions can be jagged when the ensemble disagrees.
[*] Pine Script's runtime limits constrain ensemble size. Defaults ([b]Trees=10, Depth=4[/b]) are conservative; larger values may hit loop iteration caps. Tune upward carefully and watch for compile warnings.
[*] The script needs at least [b]Training Bars + Forecast Horizon + 50[/b] bars of history (default 570) before producing a forecast; earlier bars display a "Not enough data" label.
[*] Bars with missing feature values (very early history, gaps, or instruments without volume) are skipped by the accumulator, which can effectively shrink the usable training window below the nominal setting.
[/list]

[b]References[/b]

[list]
[*] Breiman, L. (2001). Random Forests. Machine Learning, 45(1), 5–32.
[*] Wager, S., Hastie, T., and Efron, B. (2014). Confidence Intervals for Random Forests: The Jackknife and the Infinitesimal Jackknife. Journal of Machine Learning Research, 15, 1625–1651.
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and research purposes only. It does not constitute financial advice. A Random Forest regressor is a statistical estimator, not an oracle. Its outputs may be inaccurate, and past in-sample or OOB performance does not guarantee future results. Always conduct your own analysis and manage risk appropriately.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ShigemiQuant

//@version=6
indicator("Random Forest Regressor - Return Estimator",
     overlay = true, max_bars_back = 5000)

import ShigemiQuant/RandomForestLibrary/1 as RF


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUT PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════════

// Group "Random Forest"
int   P_TREES      = input.int(10,  "Number of Trees",          minval = 1,   maxval = 15,   group = "Random Forest",
     tooltip = "Number of decision trees in the ensemble. More trees improve stability but increase computation time.")
int   P_DEPTH      = input.int(4,   "Max Depth",                minval = 1,   maxval = 6,    group = "Random Forest",
     tooltip = "Maximum depth of each decision tree. Deeper trees capture more complex patterns but risk overfitting.")
int   P_TRAIN_SIZE = input.int(500, "Training Bars",            minval = 100, maxval = 1000, group = "Random Forest",
     tooltip = "Number of recent bars used to train the model. Larger values provide more data but may include outdated patterns.")
int   P_THRESH_N   = input.int(5,   "Threshold Candidates",     minval = 3,   maxval = 10,   group = "Random Forest",
     tooltip = "Number of random split thresholds evaluated per feature at each node. Higher values find better splits at the cost of speed.")
int   P_SEED       = input.int(42,  "Random Seed",                                           group = "Random Forest",
     tooltip = "Seed for the random number generator. Change this value to get a different random forest ensemble.")
int   P_MIN_LEAF   = input.int(10,  "Min Samples per Leaf",     minval = 5,   maxval = 50,   group = "Random Forest",
     tooltip = "Minimum number of samples required in each leaf node. Higher values prevent overfitting by avoiding overly specific splits.")

// Group "Forecast"
int  P_MAX_HORIZON = input.int(20,   "Forecast Horizon (bars)",  minval = 5,   maxval = 30,   group = "Forecast",
     tooltip = "Number of future bars to forecast. The model predicts percentage change for each horizon step.")
bool P_CI_90       = input.bool(true, "Show 90% Prediction Interval",                         group = "Forecast",
     tooltip = "Display the 90% prediction interval band around the forecast line, based on OOB residual analysis.")
bool P_CI_95       = input.bool(true, "Show 95% Prediction Interval",                         group = "Forecast",
     tooltip = "Display the 95% prediction interval band (wider). Based on out-of-bag residuals (Wager 2014 method).")

// Group "Display"
color P_LINE_COLOR = input.color(#2962FF,                   "Forecast Line Color", group = "Display",
     tooltip = "Color of the main forecast polyline.")
color P_CI90_COLOR = input.color(color.new(#2962FF, 75),    "90% PI Color",        group = "Display",
     tooltip = "Fill color for the 90% prediction interval band.")
color P_CI95_COLOR = input.color(color.new(#2962FF, 88),    "95% PI Color",        group = "Display",
     tooltip = "Fill color for the 95% prediction interval band.")
bool  P_SHOW_DASH  = input.bool(true,                       "Show Dashboard",      group = "Display",
     tooltip = "Toggle the information dashboard showing model metrics, predictions, and feature importances.")


// ═══════════════════════════════════════════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

int   N_FEATURES = 8
color C_BULL     = #089981
color C_BEAR     = #f23645
color C_DASH_BG  = #131722
color C_DASH_FG  = color.white
color C_DASH_LB  = color.gray


// ═══════════════════════════════════════════════════════════════════════════════
//  FEATURE COMPUTATION (8 features)
// ═══════════════════════════════════════════════════════════════════════════════

// 1. RSI(14)
float f_rsi = ta.rsi(close, 14)

// 2. ATR(14) / close * 100 — ATR%
float f_atr_pct = ta.atr(14) / close * 100.0

// 3. CCI(20)
float f_cci = ta.cci(close, 20)

// 4. Volume Ratio — volume / SMA(volume, 20)
float f_vol_ratio = nz(volume / ta.sma(volume, 20), 1.0)

// 5. Price vs SMA50 — close / SMA(close, 50) * 100
float f_price_sma = close / ta.sma(close, 50) * 100.0

// 6. Momentum 10-bar %
float f_mom = bar_index >= 10 ? (close - close[10]) / close[10] * 100.0 : 0.0

// 7. Bollinger Band Width %
float bb_basis   = ta.sma(close, 20)
float bb_dev     = 2.0 * ta.stdev(close, 20)
float f_bb_width = bb_basis > 0 ? ((bb_basis + bb_dev) - (bb_basis - bb_dev)) / bb_basis * 100.0 : 0.0

// 8. ADX(14) — via ta.dmi() tuple return
[diPlus, diMinus, adxValue] = ta.dmi(14, 14)
float f_adx = adxValue


// ═══════════════════════════════════════════════════════════════════════════════
//  DATA ACCUMULATION — push every bar with valid features
// ═══════════════════════════════════════════════════════════════════════════════

var array<float> hist_f1    = array.new<float>()   // RSI
var array<float> hist_f2    = array.new<float>()   // ATR%
var array<float> hist_f3    = array.new<float>()   // CCI
var array<float> hist_f4    = array.new<float>()   // Vol Ratio
var array<float> hist_f5    = array.new<float>()   // Price vs SMA50
var array<float> hist_f6    = array.new<float>()   // Momentum
var array<float> hist_f7    = array.new<float>()   // BB Width
var array<float> hist_f8    = array.new<float>()   // ADX
var array<float> hist_close = array.new<float>()

bool features_valid = not na(f_rsi) and not na(f_atr_pct) and not na(f_cci) and not na(f_price_sma) and not na(f_bb_width) and not na(f_adx)

if features_valid
    hist_f1.push(f_rsi)
    hist_f2.push(f_atr_pct)
    hist_f3.push(f_cci)
    hist_f4.push(f_vol_ratio)
    hist_f5.push(f_price_sma)
    hist_f6.push(f_mom)
    hist_f7.push(f_bb_width)
    hist_f8.push(f_adx)
    hist_close.push(close)


// ═══════════════════════════════════════════════════════════════════════════════
//  FEATURE NAMES (for dashboard)
// ═══════════════════════════════════════════════════════════════════════════════

var array<string> FEAT_NAMES = array.from("RSI(14)", "ATR %", "CCI(20)", "Vol Ratio", "Price/SMA50", "Mom(10)", "BB Width", "ADX(14)")


// ═══════════════════════════════════════════════════════════════════════════════
//  MAIN LOGIC — training & inference on last bar only (non-repainting)
// ═══════════════════════════════════════════════════════════════════════════════

if barstate.islast
    int total = hist_close.size()

    if total < P_TRAIN_SIZE + P_MAX_HORIZON + 50
        label.new(bar_index, close, "⚠ Not enough data\nNeed " + str.tostring(P_TRAIN_SIZE + P_MAX_HORIZON + 50) + " bars (have " + str.tostring(total) + ")",
             style = label.style_label_left, color = color.new(color.gray, 50), textcolor = color.white, size = size.normal)
    else

        // ─── Build training dataset ──────────────────────────────────────
        int train_start = total - P_TRAIN_SIZE - P_MAX_HORIZON
        int train_end   = total - P_MAX_HORIZON - 1
        int n_train     = train_end - train_start + 1

        if n_train < 50
            label.new(bar_index, close, "⚠ Not enough training samples (" + str.tostring(n_train) + " < 50)",
                 style = label.style_label_left, color = color.new(color.gray, 50), textcolor = color.white, size = size.normal)
        else

            // X matrix: n_train × 8
            matrix<float> X = matrix.new<float>(n_train, N_FEATURES, 0.0)

            // Y matrix: n_train × P_MAX_HORIZON (change % per horizon)
            matrix<float> Y = matrix.new<float>(n_train, P_MAX_HORIZON, 0.0)

            for i = 0 to n_train - 1
                int idx = train_start + i
                // Fill features
                X.set(i, 0, hist_f1.get(idx))
                X.set(i, 1, hist_f2.get(idx))
                X.set(i, 2, hist_f3.get(idx))
                X.set(i, 3, hist_f4.get(idx))
                X.set(i, 4, hist_f5.get(idx))
                X.set(i, 5, hist_f6.get(idx))
                X.set(i, 6, hist_f7.get(idx))
                X.set(i, 7, hist_f8.get(idx))
                // Fill targets: change % for each horizon
                float base_close = hist_close.get(idx)
                for h = 0 to P_MAX_HORIZON - 1
                    float future_close = hist_close.get(idx + h + 1)
                    Y.set(i, h, (future_close - base_close) / base_close * 100.0)

            // ─── Train Random Forest via library ─────────────────────────
            RF.Forest forest = RF.Forest.new().init(
                 n_estimators          = P_TREES,
                 max_depth             = P_DEPTH,
                 max_features          = 0,
                 min_samples_leaf      = P_MIN_LEAF,
                 n_threshold_candidates = P_THRESH_N,
                 seed                  = P_SEED
                 ).fit_regressor(X, Y)

            // ─── OOB R² ──────────────────────────────────────────────────
            float oob_r2 = forest.oob_r2()

            // ─── Feature importances ─────────────────────────────────────
            array<float> importances = forest.feature_importance()

            // ─── Current bar prediction + prediction intervals ─────────
            array<float> current_sample = array.new<float>(N_FEATURES, 0.0)
            current_sample.set(0, hist_f1.get(total - 1))
            current_sample.set(1, hist_f2.get(total - 1))
            current_sample.set(2, hist_f3.get(total - 1))
            current_sample.set(3, hist_f4.get(total - 1))
            current_sample.set(4, hist_f5.get(total - 1))
            current_sample.set(5, hist_f6.get(total - 1))
            current_sample.set(6, hist_f7.get(total - 1))
            current_sample.set(7, hist_f8.get(total - 1))

            // Ensemble mean prediction
            array<float> pred_mean = forest.predict_multi(current_sample)

            // OOB residual-based prediction intervals (Wager 2014)
            array<float> pred_std = forest.oob_residual_std()

            // ─── Polyline Drawing ────────────────────────────────────────
            float current_close = close

            // Forecast line (mean prediction)
            array<chart.point> pred_points = array.new<chart.point>()
            pred_points.push(chart.point.from_index(bar_index, current_close))
            for h = 0 to P_MAX_HORIZON - 1
                float price = current_close * (1.0 + pred_mean.get(h) / 100.0)
                pred_points.push(chart.point.from_index(bar_index + h + 1, price))
            polyline.new(pred_points, closed = false, line_color = P_LINE_COLOR, line_width = 2)

            // 95% prediction interval (outer, more transparent)
            if P_CI_95
                array<chart.point> ci95_points = array.new<chart.point>()
                // Upper edge: left → right
                for h = 0 to P_MAX_HORIZON - 1
                    float upper = current_close * (1.0 + (pred_mean.get(h) + 1.96 * pred_std.get(h)) / 100.0)
                    ci95_points.push(chart.point.from_index(bar_index + h + 1, upper))
                // Lower edge: right → left
                for h = P_MAX_HORIZON - 1 to 0
                    float lower = current_close * (1.0 + (pred_mean.get(h) - 1.96 * pred_std.get(h)) / 100.0)
                    ci95_points.push(chart.point.from_index(bar_index + h + 1, lower))
                polyline.new(ci95_points, closed = true, fill_color = P_CI95_COLOR, line_color = color.new(color.white, 100))

            // 90% prediction interval (inner, slightly more opaque)
            if P_CI_90
                array<chart.point> ci90_points = array.new<chart.point>()
                for h = 0 to P_MAX_HORIZON - 1
                    float upper = current_close * (1.0 + (pred_mean.get(h) + 1.645 * pred_std.get(h)) / 100.0)
                    ci90_points.push(chart.point.from_index(bar_index + h + 1, upper))
                for h = P_MAX_HORIZON - 1 to 0
                    float lower = current_close * (1.0 + (pred_mean.get(h) - 1.645 * pred_std.get(h)) / 100.0)
                    ci90_points.push(chart.point.from_index(bar_index + h + 1, lower))
                polyline.new(ci90_points, closed = true, fill_color = P_CI90_COLOR, line_color = color.new(color.white, 100))

            // ─── Dashboard ───────────────────────────────────────────────
            if P_SHOW_DASH
                int n_rows = 19  // rows 0-18 (title + 9 metrics + separator + 8 features)
                table dash = table.new(position.top_right, 2, n_rows, bgcolor = C_DASH_BG, border_width = 0)

                // Row 0: Title
                table.cell(dash, 0, 0, "𝗥𝗮𝗻𝗱𝗼𝗺 𝗙𝗼𝗿𝗲𝘀𝘁 𝗥𝗲𝗴𝗿𝗲𝘀𝘀𝗼𝗿",
                     text_color = C_DASH_FG, text_size = size.normal, text_halign = text.align_left)
                table.cell(dash, 1, 0, "lib v" + str.tostring(RF.lib_version()),
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_right)

                // Row 1: Direction (based on H20 / last horizon prediction)
                float last_horizon_pred = pred_mean.get(P_MAX_HORIZON - 1)
                string dir_text  = last_horizon_pred >= 0 ? "BULLISH" : "BEARISH"
                color  dir_color = last_horizon_pred >= 0 ? C_BULL : C_BEAR
                table.cell(dash, 0, 1, "Direction:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 1, dir_text,
                     text_color = dir_color, text_size = size.small, text_halign = text.align_right)

                // Row 2: OOB R²
                table.cell(dash, 0, 2, "OOB R²:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 2, str.tostring(oob_r2, "#.####"),
                     text_color = oob_r2 > 0 ? C_BULL : C_BEAR,
                     text_size = size.small, text_halign = text.align_right)

                // Row 3: Trees / Depth
                table.cell(dash, 0, 3, "Trees / Depth:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 3, str.tostring(P_TREES) + " / " + str.tostring(P_DEPTH),
                     text_color = C_DASH_FG, text_size = size.small, text_halign = text.align_right)

                // Row 4: Training / Horizon
                table.cell(dash, 0, 4, "Training / Horizon:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 4, str.tostring(P_TRAIN_SIZE) + " / " + str.tostring(P_MAX_HORIZON),
                     text_color = C_DASH_FG, text_size = size.small, text_halign = text.align_right)

                // Row 5: Pred H5
                float pred_h5 = P_MAX_HORIZON >= 5 ? pred_mean.get(4) : na
                string h5_text = not na(pred_h5) ? (pred_h5 >= 0 ? "+" : "") + str.tostring(pred_h5, "#.##") + "%" : "N/A"
                color  h5_color = not na(pred_h5) ? (pred_h5 >= 0 ? C_BULL : C_BEAR) : C_DASH_LB
                table.cell(dash, 0, 5, "Pred H5:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 5, h5_text,
                     text_color = h5_color, text_size = size.small, text_halign = text.align_right)

                // Row 6: Pred H10
                float pred_h10 = P_MAX_HORIZON >= 10 ? pred_mean.get(9) : na
                string h10_text = not na(pred_h10) ? (pred_h10 >= 0 ? "+" : "") + str.tostring(pred_h10, "#.##") + "%" : "N/A"
                color  h10_color = not na(pred_h10) ? (pred_h10 >= 0 ? C_BULL : C_BEAR) : C_DASH_LB
                table.cell(dash, 0, 6, "Pred H10:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 6, h10_text,
                     text_color = h10_color, text_size = size.small, text_halign = text.align_right)

                // Row 7: Pred H20
                float pred_h20 = P_MAX_HORIZON >= 20 ? pred_mean.get(19) : na
                string h20_text = not na(pred_h20) ? (pred_h20 >= 0 ? "+" : "") + str.tostring(pred_h20, "#.##") + "%" : "N/A"
                color  h20_color = not na(pred_h20) ? (pred_h20 >= 0 ? C_BULL : C_BEAR) : C_DASH_LB
                table.cell(dash, 0, 7, "Pred H20:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 7, h20_text,
                     text_color = h20_color, text_size = size.small, text_halign = text.align_right)

                // Row 8: PI Width H20 (95% prediction interval width)
                float pi_width_h20 = P_MAX_HORIZON >= 20 ? 2.0 * 1.96 * pred_std.get(19) : na
                string pi_text = not na(pi_width_h20) ? str.tostring(pi_width_h20, "#.##") + "%" : "N/A"
                table.cell(dash, 0, 8, "PI Width H20:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 8, pi_text,
                     text_color = C_DASH_FG, text_size = size.small, text_halign = text.align_right)

                // Row 9: OOB Residual Std (average across horizons)
                float avg_std = 0.0
                for h = 0 to pred_std.size() - 1
                    avg_std += pred_std.get(h)
                avg_std := pred_std.size() > 0 ? avg_std / float(pred_std.size()) : na
                string std_text = not na(avg_std) ? str.tostring(avg_std, "#.###") + "%" : "N/A"
                table.cell(dash, 0, 9, "OOB Res. Std:",
                     text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 9, std_text,
                     text_color = C_DASH_FG, text_size = size.small, text_halign = text.align_right)

                // Row 10: Feature Importance separator
                table.cell(dash, 0, 10, "── Feature Importance ──",
                     text_color = P_LINE_COLOR, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, 10, "",
                     text_color = C_DASH_FG)

                // Rows 11-18: Feature importances with Unicode bar graph
                float max_imp = 0.0
                for f = 0 to N_FEATURES - 1
                    float imp_val = importances.size() > f ? importances.get(f) : 0.0
                    max_imp := math.max(max_imp, imp_val)

                for f = 0 to N_FEATURES - 1
                    float imp = importances.size() > f ? importances.get(f) : 0.0
                    int bar_len = max_imp > 0 ? int(math.round(imp / max_imp * 10)) : 0
                    bar_len := math.max(0, math.min(10, bar_len))
                    string bar_str = ""
                    for b = 0 to 9
                        bar_str += b < bar_len ? "█" : "░"
                    string imp_text = "[" + bar_str + "] " + str.tostring(imp * 100.0, "#.1") + "%"
                    color imp_color = imp == max_imp and max_imp > 0 ? #42A5F5 : P_LINE_COLOR
                    table.cell(dash, 0, 11 + f, FEAT_NAMES.get(f),
                         text_color = C_DASH_LB, text_size = size.small, text_halign = text.align_left)
                    table.cell(dash, 1, 11 + f, imp_text,
                         text_color = imp_color, text_size = size.small, text_halign = text.align_right)
````
