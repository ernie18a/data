# K-Means Regime Detector

- url: https://www.tradingview.com/script/PCUBiICi-K-Means-Regime-Detector/
- type: indicator
- pine_id: PUB;c07b687c66744c4bba35e60bbb098df7
- version: 1.0

## Description

[b]K-Means Regime Detector[/b] classifies the current market state into three interpretable regimes — [b]Trending[/b], [b]Ranging[/b], and [b]Volatile[/b] — using unsupervised K-Means clustering (Lloyd's algorithm) computed entirely inside Pine Script v6.

[b]What Makes This Different[/b]

Most regime filters on TradingView use hand-picked thresholds: "ADX above 25 means trending." Those thresholds were calibrated for one instrument on one timeframe and silently break on others, because volatility and trend distributions vary widely across symbols and sessions.

This detector learns the three regime centers directly from the last N bars of the chart it is placed on. No fixed ADX cutoff, no hard-coded ATR multiplier, no external dataset. The boundaries between regimes are re-derived every time the model retrains, so the same script adapts whether you apply it to EURUSD 15m, BTCUSDT 4h, or SPX daily.

[b]What It Does[/b]

On every confirmed bar, the indicator:
[list]
[*] Computes four complementary market-state features
[*] Standardizes them with the mean and standard deviation stored at the last training step
[*] Finds the nearest centroid out of K clusters
[*] Assigns that cluster one of three regime labels and updates the on-chart dashboard
[/list]

The chart background (optional) is tinted by regime color, and three alert conditions fire on regime transitions.

[b]How It Works[/b]

[b]Four features (why these four)[/b]

[list]
[*] [b]ATR Ratio[/b] — current ATR(14) divided by its 20-bar SMA. Captures whether volatility is expanding or contracting relative to its own recent history.
[*] [b]ADX[/b] — directional movement strength from ta.dmi(). Measures trend conviction regardless of direction.
[*] [b]Bollinger Band Width Percentile[/b] — rank of the current BB width over the last 100 bars (0 to 1). Captures compression versus expansion on a bounded scale.
[*] [b]Momentum Acceleration[/b] — short-ROC minus long-ROC. Distinguishes accelerating moves from steady drift.
[/list]

ATR Ratio and BB Width Percentile both describe volatility but from different angles (absolute range vs. relative compression). ADX adds a directional axis. Momentum Acceleration adds a second-derivative axis that the first three cannot see. Together they span a 4-dimensional feature space in which the three regime types separate cleanly.

[b]Training (K-Means / Lloyd's algorithm)[/b]

[list]
[*] Accumulate the four features from the last [b]Training Window[/b] confirmed bars (default 500).
[*] Standardize (z-score) using the rolling mean and standard deviation.
[*] Initialize K centroids from evenly spaced samples in the window.
[*] Iterate: (1) assign each bar to its nearest centroid, (2) recompute each centroid as the mean of its members. Repeat until no assignment changes or Max Iterations is reached.
[*] Retrain every [b]Retrain Interval[/b] bars (default 100), on a rolling window, so the model adapts as the market evolves.
[/list]

[b]Regime labeling[/b]

After clustering, the centroid with the highest unscaled ADX becomes [b]Trending[/b]. Among the remaining centroids, the one with the highest unscaled ATR Ratio becomes [b]Volatile[/b]. Anything left over is labeled [b]Ranging[/b]. This rule-based post-labeling is what makes the output interpretable — pure K-Means would only give you anonymous cluster IDs.

[b]Prediction[/b]

For each new confirmed bar, the current feature vector is standardized with the stored training-time scaler, then assigned to the nearest centroid. A confidence score is computed from the ratio of the minimum distance to the average distance across all K centroids.

[b]Non-repainting[/b]

Every training and prediction step is gated on [icode]barstate.isconfirmed[/icode]. The regime printed on a closed bar will not change on future bars. Historical classifications match what the script would have produced in real time.

[b]Dashboard[/b]

[list]
[*] Large regime banner (green Trending / gold Ranging / red Volatile, or "WARMING UP" during the first training window)
[*] Confidence (0 to 100 percent) and bars-in-current-regime count
[*] Raw feature values: ATR Ratio, ADX, BB Width percent, Momentum Acceleration
[*] Training diagnostics: bar index of last training, bars until next retrain
[/list]

[b]Inputs[/b]

[list]
[*] [b]K Clusters[/b] — 2 to 5, default 3
[*] [b]Training Window[/b] — 100 to 1000, default 500
[*] [b]Retrain Interval[/b] — 20 to 500, default 100
[*] [b]Max Iterations[/b] — 5 to 50, default 30
[*] [b]ATR / ADX / BB Periods, Momentum Short / Long[/b] — feature periods, all tunable
[*] [b]Display[/b] — table position (9 choices), size, background on/off, transparency
[/list]

[b]Alerts[/b]

Three alertcondition entries fire when the regime changes:
[list]
[*] Regime: Trending
[*] Regime: Ranging
[*] Regime: Volatile
[/list]

[b]How To Use[/b]

This is a [i]context filter[/i], not a signal generator. Typical workflows:

[list]
[*] [b]Gate your existing setups.[/b] Enable trend-following entries (MA crossovers, Donchian breakouts) only when the regime reads Trending. Enable mean-reversion entries (RSI extremes, BB touches) only when it reads Ranging.
[*] [b]Size by regime.[/b] Consider reducing position size or widening stops during Volatile regimes, where whipsaws are most frequent.
[*] [b]Skip breakouts in ranges.[/b] Most breakout signals fail in a Ranging regime — use the detector to filter them out.
[*] [b]Watch transitions.[/b] A shift from Ranging to Trending can mark the beginning of a fresh directional move. Set the corresponding alert to monitor it across symbols.
[/list]

[b]Warm-up and Data Requirements[/b]

The indicator needs at least [b]Training Window[/b] confirmed bars of history before it produces its first classification. During warm-up, the dashboard shows "WARMING UP" and no regime color is painted. On lower timeframes (1m, 5m) make sure the chart loads at least 500 historical bars before trusting the output.

[b]About the Clustering Model[/b]

[list]
[*] [b]On-chart learning, no pre-trained model.[/b] Every centroid is learned in real time from the chart the script is placed on. There is no external training dataset, no imported weights, and no file upload — the model exists only within the current chart's bar history.
[*] [b]Training data source and window.[/b] The model fits on the most recent [b]Training Window[/b] confirmed bars on the chart (default 500; configurable 100–1000). It retrains every [b]Retrain Interval[/b] bars (default 100) on a rolling window, so older data is naturally discarded as the market evolves.
[*] [b]Algorithm and convergence.[/b] Lloyd's algorithm iterates at most [b]Max Iterations[/b] times (default 30) and early-exits on the first iteration where no sample changes its cluster assignment. Convergence is therefore data-dependent but bounded.
[*] [b]Features are z-score standardized[/b] using the rolling mean and standard deviation over the training window, stored at training time and reused at prediction time to keep inference consistent with training.
[*] [b]K is configurable but defaults to 3[/b] (Trending / Ranging / Volatile). This is deliberately low: three regimes are easy to reason about, and with [b]K > 3[/b] the post-labeling rule collapses extra clusters into Ranging. If you need finer granularity, consider a larger [b]Training Window[/b] first before raising K.
[*] [b]K-Means is a distance model, not a probability model.[/b] The "Confidence" field in the dashboard is a distance-ratio heuristic ([icode]1 / (1 + min_dist / avg_dist)[/icode]), not a posterior probability. Do not interpret it as a calibrated probability that the current regime is correct.
[/list]

[b]Notes and Limitations[/b]

[list]
[*] K-Means assumes roughly spherical clusters in standardized feature space. Extreme outliers (news spikes) can distort centroids until the next retrain.
[*] Regime labels are heuristic post-hoc assignments based on ADX and ATR Ratio centroid values. With [b]K Clusters > 3[/b], extra clusters are collapsed into Ranging — a deliberate simplification that can under-represent edge regimes.
[*] The three-regime assumption (Trending / Ranging / Volatile) is a modelling choice. Markets that cycle through finer or more exotic states (compression-then-expansion, trending-with-high-volatility, etc.) will be forced into the nearest of these three labels.
[*] Classifications reflect the most recently completed bar only and cannot anticipate regime changes before they appear in the features. Expect a lag proportional to the feature periods (ATR 14, ADX 14, BB 20, Momentum 10).
[*] On low-liquidity or gap-prone instruments, a single large candle can dominate the feature vector and flip the regime label until the next retrain smooths it out.
[*] Training window + retraining is capped by Pine Script's runtime budget. Very large [b]Training Window[/b] combined with low [b]Retrain Interval[/b] may trigger compile warnings.
[*] Past regime classifications do not predict future market behavior. This is an observational tool, not a forecasting model.
[/list]

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice. All trading decisions are the sole responsibility of the user. Past behavior does not guarantee future results.

## Source Code

````pine
// ============================================================================
// K-Means Regime Detector — ML-Based Market Regime Classification
// ============================================================================
//
// Classifies markets into Trending / Ranging / Volatile regimes using
// K-Means clustering (Lloyd's algorithm) on 4 price-derived features:
// ATR Ratio, ADX, BB Width Percentile, and Momentum Acceleration.
// StandardScaler normalization. Retrains every N bars on confirmed data.
//
// NON-REPAINTING: uses barstate.isconfirmed — no lookahead bias.
// Works on any asset: Forex, Crypto, Stocks, Indices.
//
// ============================================================================

//@version=6
indicator("K-Means Regime Detector", overlay=true, max_bars_back=5000)

// ============================================================================
// COLOR CONSTANTS
// ============================================================================

var color C_TRENDING   = #66BB6A
var color C_RANGING    = #FFD700
var color C_VOLATILE   = #EF5350
var color C_NEUTRAL_UI = #787b86
var color C_WHITE      = #d1d4dc
var color C_PANEL_BG   = color.new(#131722, 0)
var color C_HEADER_BG  = color.new(#1e222d, 0)
var color C_ROW_BG     = color.new(#16191e, 0)
var color C_ROW_BG2    = color.new(#1a1e27, 0)

// ============================================================================
// USER INPUTS
// ============================================================================

// --- K-Means ---
i_K              = input.int(3,   "K Clusters",        minval=2, maxval=5,    group="K-Means", tooltip="Number of clusters. 3 = Trending/Ranging/Volatile")
i_trainWindow    = input.int(500, "Training Window",    minval=100, maxval=1000, group="K-Means", tooltip="Number of bars used for K-Means training. Higher = more stable but slower.")
i_retrainInterval= input.int(100, "Retrain Interval",   minval=20, maxval=500,  group="K-Means", tooltip="Bars between retraining cycles")
i_maxIter        = input.int(30,  "Max Iterations",     minval=5, maxval=50,    group="K-Means", tooltip="Maximum Lloyd's algorithm iterations. Convergence usually occurs well before this limit.")

// --- Features ---
i_atrPeriod  = input.int(14, "ATR Period",       minval=2, maxval=100, group="Features", tooltip="Period for ATR calculation")
i_adxPeriod  = input.int(14, "ADX Period",       minval=2, maxval=100, group="Features", tooltip="Period for ADX/DMI calculation")
i_bbPeriod   = input.int(20, "BB Period",        minval=5, maxval=100, group="Features", tooltip="Period for Bollinger Band width")
i_momShort   = input.int(5,  "Momentum Short",   minval=1, maxval=50,  group="Features", tooltip="Short ROC period for momentum acceleration. Must be less than Momentum Long.")
i_momLong    = input.int(10, "Momentum Long",    minval=2, maxval=100, group="Features", tooltip="Long ROC period for momentum acceleration. Must be greater than Momentum Short.")

// --- Display ---
i_tblPos = input.string("Top Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group="Display", tooltip="Dashboard position on chart")
i_tblSize    = input.string("Small", "Table Size", options=["Small","Normal","Large"], group="Display", tooltip="Font size for the dashboard")
i_showBg     = input.bool(true, "Show Background",    group="Display", tooltip="Color chart background by detected regime")
i_bgTransp   = input.int(85,   "BG Transparency",     minval=50, maxval=98, group="Display", tooltip="Background color transparency (higher = more subtle)")

// ============================================================================
// HELPERS
// ============================================================================

f_tblPos(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_tblSize(string s) =>
    switch s
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_regimeColor(int r) =>
    switch r
        0 => C_TRENDING
        2 => C_VOLATILE
        => C_RANGING

f_regimeLabel(int r) =>
    switch r
        0 => "TRENDING"
        2 => "VOLATILE"
        => "RANGING"

// ============================================================================
// FEATURE COMPUTATION
// ============================================================================

float rawATR      = ta.atr(i_atrPeriod)
float atr_ratio   = rawATR / nz(ta.sma(rawATR, 20), 1.0)

[diPlus, diMinus, adx_value] = ta.dmi(i_adxPeriod, i_adxPeriod)

float bbBasis     = ta.sma(close, i_bbPeriod)
float bbDev       = ta.stdev(close, i_bbPeriod)
float bbWidth     = 2.0 * bbDev / nz(bbBasis, 1.0)
float bb_width_pctl = ta.percentrank(bbWidth, 100) / 100.0

float momentum_accel = ta.roc(close, i_momShort) - ta.roc(close, i_momLong)

// ============================================================================
// PERSISTENT STATE
// ============================================================================

var matrix<float> centroids   = matrix.new<float>(0, 0, 0.0)
var array<int>    regimeMap   = array.new<int>(5, 1)    // cluster → regime (0=Trend,1=Range,2=Volatile)
var int           lastTrainBar = -99999
var int           currentRegime = 1                      // default Ranging
var float         currentConf   = 0.0
var int           regimeBarCount = 0
var int           prevRegime    = 1
var bool          isTrained     = false
var int           trainedAtBar  = 0

// Scaler params (persisted from training)
var float sc_m0 = 0.0, var float sc_m1 = 0.0, var float sc_m2 = 0.0, var float sc_m3 = 0.0
var float sc_s0 = 1.0, var float sc_s1 = 1.0, var float sc_s2 = 1.0, var float sc_s3 = 1.0

// Feature history arrays
var array<float> hist_atr  = array.new<float>(0)
var array<float> hist_adx  = array.new<float>(0)
var array<float> hist_bb   = array.new<float>(0)
var array<float> hist_mom  = array.new<float>(0)

// Store confirmed bar features
if barstate.isconfirmed
    array.push(hist_atr, nz(atr_ratio, 1.0))
    array.push(hist_adx, nz(adx_value, 0.0))
    array.push(hist_bb,  nz(bb_width_pctl, 0.5))
    array.push(hist_mom, nz(momentum_accel, 0.0))
    // Keep only what we need
    if array.size(hist_atr) > i_trainWindow + 50
        array.shift(hist_atr)
        array.shift(hist_adx)
        array.shift(hist_bb)
        array.shift(hist_mom)

// ============================================================================
// K-MEANS TRAINING (Lloyd's Algorithm)
// ============================================================================

int histSize = array.size(hist_atr)
bool hasEnoughData = histSize >= i_trainWindow
bool shouldRetrain = hasEnoughData and bar_index - lastTrainBar >= i_retrainInterval and barstate.isconfirmed

if shouldRetrain
    lastTrainBar := bar_index
    int N = i_trainWindow
    int offset = histSize - N

    // --- Compute rolling mean & std for StandardScaler ---
    float sum_atr = 0.0, float sum_adx = 0.0, float sum_bb = 0.0, float sum_mom = 0.0
    float sq_atr = 0.0,  float sq_adx = 0.0,  float sq_bb = 0.0,  float sq_mom = 0.0

    for i = 0 to N - 1
        float a = array.get(hist_atr, offset + i)
        float b = array.get(hist_adx, offset + i)
        float c = array.get(hist_bb,  offset + i)
        float d = array.get(hist_mom, offset + i)
        sum_atr += a, sum_adx += b, sum_bb += c, sum_mom += d
        sq_atr += a * a, sq_adx += b * b, sq_bb += c * c, sq_mom += d * d

    float nF     = float(N)
    float m_atr  = sum_atr / nF, float m_adx = sum_adx / nF
    float m_bb   = sum_bb / nF,  float m_mom = sum_mom / nF
    float s_atr  = math.sqrt(math.max(sq_atr / nF - m_atr * m_atr, 0.0))
    float s_adx  = math.sqrt(math.max(sq_adx / nF - m_adx * m_adx, 0.0))
    float s_bb   = math.sqrt(math.max(sq_bb / nF - m_bb * m_bb, 0.0))
    float s_mom  = math.sqrt(math.max(sq_mom / nF - m_mom * m_mom, 0.0))
    s_atr := nz(s_atr, 1.0) == 0.0 ? 1.0 : s_atr
    s_adx := nz(s_adx, 1.0) == 0.0 ? 1.0 : s_adx
    s_bb  := nz(s_bb, 1.0)  == 0.0 ? 1.0 : s_bb
    s_mom := nz(s_mom, 1.0) == 0.0 ? 1.0 : s_mom

    // Store scaler params for prediction
    sc_m0 := m_atr, sc_m1 := m_adx, sc_m2 := m_bb, sc_m3 := m_mom
    sc_s0 := s_atr, sc_s1 := s_adx, sc_s2 := s_bb, sc_s3 := s_mom

    // --- Build scaled data matrix ---
    matrix<float> data = matrix.new<float>(N, 4, 0.0)
    for i = 0 to N - 1
        matrix.set(data, i, 0, (array.get(hist_atr, offset + i) - m_atr) / s_atr)
        matrix.set(data, i, 1, (array.get(hist_adx, offset + i) - m_adx) / s_adx)
        matrix.set(data, i, 2, (array.get(hist_bb,  offset + i) - m_bb)  / s_bb)
        matrix.set(data, i, 3, (array.get(hist_mom, offset + i) - m_mom) / s_mom)

    // --- Initialize centroids (evenly spaced samples) ---
    int K = math.min(i_K, N)
    matrix<float> C = matrix.new<float>(K, 4, 0.0)
    for k = 0 to K - 1
        int idx = math.floor(k * (N - 1) / math.max(K - 1, 1))
        matrix.set(C, k, 0, matrix.get(data, idx, 0))
        matrix.set(C, k, 1, matrix.get(data, idx, 1))
        matrix.set(C, k, 2, matrix.get(data, idx, 2))
        matrix.set(C, k, 3, matrix.get(data, idx, 3))

    // --- Lloyd's iterations ---
    array<int> assign = array.new<int>(N, 0)
    for iter = 0 to i_maxIter - 1
        // Assignment step
        bool changed = false
        for i = 0 to N - 1
            float minD = 1e18
            int bestK = 0
            float di0 = matrix.get(data, i, 0), float di1 = matrix.get(data, i, 1)
            float di2 = matrix.get(data, i, 2), float di3 = matrix.get(data, i, 3)
            for k = 0 to K - 1
                float d0 = di0 - matrix.get(C, k, 0), float d1 = di1 - matrix.get(C, k, 1)
                float d2 = di2 - matrix.get(C, k, 2), float d3 = di3 - matrix.get(C, k, 3)
                float d = d0 * d0 + d1 * d1 + d2 * d2 + d3 * d3
                if d < minD
                    minD := d
                    bestK := k
            if array.get(assign, i) != bestK
                changed := true
            array.set(assign, i, bestK)

        // Update step
        matrix<float> sumC = matrix.new<float>(K, 4, 0.0)
        array<int> countC = array.new<int>(K, 0)
        for i = 0 to N - 1
            int cl = array.get(assign, i)
            array.set(countC, cl, array.get(countC, cl) + 1)
            matrix.set(sumC, cl, 0, matrix.get(sumC, cl, 0) + matrix.get(data, i, 0))
            matrix.set(sumC, cl, 1, matrix.get(sumC, cl, 1) + matrix.get(data, i, 1))
            matrix.set(sumC, cl, 2, matrix.get(sumC, cl, 2) + matrix.get(data, i, 2))
            matrix.set(sumC, cl, 3, matrix.get(sumC, cl, 3) + matrix.get(data, i, 3))
        for k = 0 to K - 1
            int cnt = array.get(countC, k)
            if cnt > 0
                float cntF = float(cnt)
                matrix.set(C, k, 0, matrix.get(sumC, k, 0) / cntF)
                matrix.set(C, k, 1, matrix.get(sumC, k, 1) / cntF)
                matrix.set(C, k, 2, matrix.get(sumC, k, 2) / cntF)
                matrix.set(C, k, 3, matrix.get(sumC, k, 3) / cntF)

        if not changed
            break

    // --- Store centroids ---
    centroids := C

    // --- Regime label assignment using UNSCALED centroid values ---
    // Convert centroids back to original scale for interpretation
    array<float> c_atr_orig = array.new<float>(K, 0.0)
    array<float> c_adx_orig = array.new<float>(K, 0.0)
    for k = 0 to K - 1
        array.set(c_atr_orig, k, matrix.get(C, k, 0) * s_atr + m_atr)
        array.set(c_adx_orig, k, matrix.get(C, k, 1) * s_adx + m_adx)

    // Trending = highest ADX centroid
    int trendCluster = 0
    float maxADX = -1e18
    for k = 0 to K - 1
        if array.get(c_adx_orig, k) > maxADX
            maxADX := array.get(c_adx_orig, k)
            trendCluster := k

    // Volatile = highest ATR ratio (excluding trending cluster)
    int volCluster = -1
    float maxATR = -1e18
    for k = 0 to K - 1
        if k != trendCluster and array.get(c_atr_orig, k) > maxATR
            maxATR := array.get(c_atr_orig, k)
            volCluster := k

    // Remaining = Ranging
    for k = 0 to K - 1
        if k == trendCluster
            array.set(regimeMap, k, 0)
        else if k == volCluster
            array.set(regimeMap, k, 2)
        else
            array.set(regimeMap, k, 1)

    isTrained   := true
    trainedAtBar := bar_index

// ============================================================================
// PREDICTION (every confirmed bar)
// ============================================================================

if barstate.isconfirmed and isTrained and matrix.rows(centroids) > 0
    int K = matrix.rows(centroids)

    // Scale current features using stored scaler params
    float x0 = (nz(atr_ratio, 1.0) - sc_m0) / sc_s0
    float x1 = (nz(adx_value, 0.0) - sc_m1) / sc_s1
    float x2 = (nz(bb_width_pctl, 0.5) - sc_m2) / sc_s2
    float x3 = (nz(momentum_accel, 0.0) - sc_m3) / sc_s3

    // Find nearest centroid
    float minDist = 1e18
    float sumDist = 0.0
    int bestC = 0
    for k = 0 to K - 1
        float d = 0.0
        float diff0 = x0 - matrix.get(centroids, k, 0)
        float diff1 = x1 - matrix.get(centroids, k, 1)
        float diff2 = x2 - matrix.get(centroids, k, 2)
        float diff3 = x3 - matrix.get(centroids, k, 3)
        d := math.sqrt(diff0 * diff0 + diff1 * diff1 + diff2 * diff2 + diff3 * diff3)
        sumDist += d
        if d < minDist
            minDist := d
            bestC := k

    float avgDist = nz(sumDist / float(K), 1.0)
    avgDist := avgDist == 0.0 ? 1.0 : avgDist

    prevRegime    := currentRegime
    currentRegime := array.get(regimeMap, bestC)
    currentConf   := 100.0 / (1.0 + minDist / avgDist)

    if currentRegime == prevRegime
        regimeBarCount += 1
    else
        regimeBarCount := 1

// ============================================================================
// BACKGROUND COLOR
// ============================================================================

color bgCol = isTrained and i_showBg ? color.new(f_regimeColor(currentRegime), i_bgTransp) : na
bgcolor(bgCol)

// ============================================================================
// DASHBOARD TABLE
// ============================================================================

var table dash = table.new(f_tblPos(i_tblPos), 4, 6, bgcolor=C_PANEL_BG, border_width=1, border_color=color.new(#2a2e39, 0), frame_width=1, frame_color=color.new(#2a2e39, 0))
string sz      = f_tblSize(i_tblSize)

if barstate.islast
    color regCol = f_regimeColor(currentRegime)
    string regTxt = isTrained ? f_regimeLabel(currentRegime) : "WARMING UP"
    color regBg   = isTrained ? regCol : C_NEUTRAL_UI

    int barsToRetrain = isTrained ? math.max(0, i_retrainInterval - (bar_index - lastTrainBar)) : i_trainWindow - histSize

    // Row 0 — Header
    table.cell(dash, 0, 0, "𝗞-𝗠𝗘𝗔𝗡𝗦  𝗥𝗘𝗚𝗜𝗠𝗘", text_color=C_WHITE, text_size=sz, bgcolor=C_HEADER_BG)
    table.merge_cells(dash, 0, 0, 3, 0)

    // Row 1 — Regime Banner
    table.cell(dash, 0, 1, regTxt, text_color=isTrained ? color.new(#131722, 0) : C_WHITE, text_size=size.huge, bgcolor=regBg)
    table.merge_cells(dash, 0, 1, 3, 1)

    // Row 2 — Confidence & Bars
    table.cell(dash, 0, 2, "Confidence", text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=C_ROW_BG)
    table.cell(dash, 1, 2, isTrained ? str.tostring(currentConf, "#") + "%" : "—", text_color=C_WHITE, text_size=sz, bgcolor=C_ROW_BG)
    table.cell(dash, 2, 2, "Bars", text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=C_ROW_BG)
    table.cell(dash, 3, 2, isTrained ? str.tostring(regimeBarCount) : "—", text_color=C_WHITE, text_size=sz, bgcolor=C_ROW_BG)

    // Row 3 — ATR Ratio & ADX
    table.cell(dash, 0, 3, "ATR Ratio", text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=C_ROW_BG2)
    table.cell(dash, 1, 3, str.tostring(nz(atr_ratio, 0.0), "#.##"), text_color=C_WHITE, text_size=sz, bgcolor=C_ROW_BG2)
    table.cell(dash, 2, 3, "ADX", text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=C_ROW_BG2)
    table.cell(dash, 3, 3, str.tostring(nz(adx_value, 0.0), "#.#"), text_color=C_WHITE, text_size=sz, bgcolor=C_ROW_BG2)

    // Row 4 — BB Width% & Momentum Accel
    table.cell(dash, 0, 4, "BB Width%", text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=C_ROW_BG)
    table.cell(dash, 1, 4, str.tostring(nz(bb_width_pctl * 100.0, 0.0), "#.#"), text_color=C_WHITE, text_size=sz, bgcolor=C_ROW_BG)
    table.cell(dash, 2, 4, "Mom Accel", text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=C_ROW_BG)
    table.cell(dash, 3, 4, str.tostring(nz(momentum_accel, 0.0), "#.##"), text_color=C_WHITE, text_size=sz, bgcolor=C_ROW_BG)

    // Row 5 — Training Info
    table.cell(dash, 0, 5, "Trained", text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=C_ROW_BG2)
    table.cell(dash, 1, 5, isTrained ? str.tostring(trainedAtBar) : "—", text_color=C_WHITE, text_size=sz, bgcolor=C_ROW_BG2)
    table.cell(dash, 2, 5, "Next", text_color=C_NEUTRAL_UI, text_size=sz, bgcolor=C_ROW_BG2)
    table.cell(dash, 3, 5, str.tostring(barsToRetrain), text_color=C_WHITE, text_size=sz, bgcolor=C_ROW_BG2)

// ============================================================================
// ALERT CONDITIONS
// ============================================================================

bool regimeChanged = currentRegime != prevRegime and barstate.isconfirmed

alertcondition(regimeChanged and currentRegime == 0, "Regime: Trending",  "Market entered TRENDING regime — {{ticker}} {{interval}}")
alertcondition(regimeChanged and currentRegime == 1, "Regime: Ranging",   "Market entered RANGING regime — {{ticker}} {{interval}}")
alertcondition(regimeChanged and currentRegime == 2, "Regime: Volatile",  "Market entered VOLATILE regime — {{ticker}} {{interval}}")

// ============================================================================
````
