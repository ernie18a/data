# Adaptive Lorentzian Classification [Quantum Algo]

- url: https://www.tradingview.com/script/co5Tx0MQ-Adaptive-Lorentzian-Classification-Quantum-Algo/
- type: indicator
- pine_id: PUB;dc8bed1dd3934694bd2ca67de14d8ca6
- version: 3.0

## Description

Quantum ML Engine — Adaptive Lorentzian Classification [Quantum Algo]

█ OVERVIEW

Quantum ML Engine is a machine-learning classifier that predicts the direction of price over a configurable horizon using an Approximate Nearest Neighbors (ANN) search across historical feature vectors. Instead of relying on a single oscillator, it compares the current bar's "fingerprint" — a vector of up to six normalized features — against thousands of past bars, finds the most similar market conditions, and lets those historical outcomes vote on what is likely to happen next.

By default the engine measures similarity with Lorentzian distance, log(1 + |Δ|), rather than Euclidean distance. Market data is heavily distorted around major events (CPI prints, FOMC, black swans), and Lorentzian distance naturally compresses these outliers — analogous to how mass warps space-time — so a single extreme bar cannot dominate the neighbor selection.

This is an original, fully self-contained implementation written from scratch with zero library imports. The concept of applying Lorentzian distance to kNN classification on charts was pioneered in the open-source work of @jdehorty (Machine Learning: Lorentzian Classification), building on earlier kNN studies by @capissimo. Full credit to both for the foundational research. This script does not reuse their code; it re-derives the approach independently and extends it in the ways described below.

█ WHAT IS DIFFERENT IN THIS IMPLEMENTATION

1 — Time-aligned training set
Each training sample pairs the feature vector recorded AT a given bar with the realized outcome over the following H bars. Features and labels are stored on the same time axis, so the classifier learns from correctly matched cause-and-effect pairs. There is no lookahead: a sample only enters the training set once its outcome is fully realized.

2 — ATR neutral-zone labeling
Historical moves smaller than a configurable multiple of ATR are labeled NEUTRAL instead of long/short. Sideways noise therefore never teaches the model a false directional lesson. Set the multiplier to 0 to disable.

3 — Six engineered features with importance weights
RSI, WaveTrend, CCI, ADX, MFI (volume flow) and Fisher Transform, each normalized to a common 0–1 scale. Every feature slot has its own weight input, so you can tell the engine which dimensions matter more for your market without removing features entirely.

4 — Four selectable distance metrics
Lorentzian (default), Manhattan, Euclidean, and a 50/50 Lorentzian-Manhattan Hybrid. Switching metrics changes the geometry of the neighborhood and is a powerful tuning lever per asset class.

5 — Distance-weighted voting with a confidence score
Closer neighbors vote louder (weight = 1 / (1 + distance)). The agreement between neighbors is expressed as a 0–100% confidence value printed on every bar, and a minimum-confidence gate suppresses low-conviction signals entirely.

6 — Adaptive K
The neighbor count automatically shrinks (up to 40%) when volatility ranks high over the last 100 bars, making the model more reactive in fast markets, and expands back in quiet regimes for stability. Can be disabled for a fixed K.

7 — Sliding training window
The engine always trains on the most recent N bars rather than the oldest bars in chart history, so the model reflects current market structure.

8 — Configurable prediction horizon
The training/holding horizon is an input (1–20 bars) instead of a hardcoded constant.

9 — Three exit modes
Fixed-horizon exits, dynamic kernel-slope exits, and an optional ATR trailing stop with the stop level plotted on the chart.

10 — Higher-timeframe confluence filter
Optionally require price to be above (longs) or below (shorts) an EMA on a higher timeframe of your choice.

█ HOW IT WORKS

1. On every bar, six features are computed and normalized.
2. The bar's feature vector is compared against samples inside the sliding training window, sampled with a minimum chronological spacing (default 4 bars) so neighbors come from distinct market episodes rather than one cluster.
3. A monotonic distance threshold maintains a stable pool of approximate nearest neighbors; when the pool exceeds K, the threshold resets to the 75th-percentile distance, allowing genuinely closer samples to rotate in over time.
4. Neighbors vote long / short / neutral, weighted by proximity. The weighted sum becomes the prediction; the degree of agreement becomes the confidence.
5. The raw signal is then passed through optional filters: volatility regime (recent ATR vs long-run ATR), trend regime (EMA separation normalized by ATR), ADX, EMA/SMA trend, higher-timeframe trend, and a Nadaraya-Watson kernel regression filter (rational quadratic estimate with a Gaussian crossover mode for smoother color transitions).
6. Entries print only when the ML signal, the confidence gate, and all enabled filters agree.

█ SETTINGS GUIDE

General — source, training window size, prediction horizon, neutral-zone width.
ML Engine — K, adaptive K toggle, chronological spacing, distance metric, distance weighting, minimum confidence.
Feature Engineering — feature type, parameters and weight for each of the six slots.
Filters — volatility, regime, ADX, EMA/SMA, higher-timeframe confluence.
Kernel — lookback, relative weighting, regression level, lag, smoothing mode.
Exits — fixed vs dynamic exits, ATR trailing stop and multiplier.
Display — bar colors, prediction labels (value + confidence), dashboard, color compression.

█ DASHBOARD

The on-chart panel shows the live signal, prediction confidence, current adaptive K, volatility and trend regime states, kernel bias, and a calibration win-rate. The calibration statistic simply checks whether price moved in the predicted direction over the horizon after each signal. It exists ONLY to give feedback while tuning features — it is not a backtest, includes no costs or risk management, and must not be treated as a performance claim.

█ USAGE NOTES

— Works on any symbol and timeframe; intraday (15m–4H) and daily charts are typical starting points. Crypto, FX, indices and equities all behave differently — retune the features and metric per market.
— Higher minimum confidence = fewer but more selective signals. Raising chronological spacing diversifies neighbors on lower timeframes.
— Signals are evaluated on bar close. Like any bar-close logic, the in-progress bar can change until it closes.
— Best used as a confluence layer inside a complete trading plan with your own risk management, not as a standalone buy/sell system.

█ CREDITS

Concept inspiration: @jdehorty (Machine Learning: Lorentzian Classification) and @capissimo (kNN implementations). This script is an independent, original implementation with the extensions listed above.

█ DISCLAIMER

[i]This script is provided for educational and informational purposes only. It is not financial advice, and past behavior — including the on-chart calibration statistics — does not guarantee future results. Trading involves substantial risk of loss. Always do your own research and manage risk responsibly.[/i]

## Source Code

````pine
// Quantum ML Engine — Adaptive Lorentzian Classification
//
// Original, dependency-free implementation. Concept inspiration: the open-source
// Lorentzian Classification research by @jdehorty and kNN studies by @capissimo.
// No code is reused — all logic below is written from scratch with substantial.
// extensions (see header notes).
//
// ── What this engine does ─────────────────────────────────────────────────────
// An Approximate Nearest Neighbors (ANN) classifier predicts the direction of
// price over the next H bars by comparing the current bar's feature vector
// against thousands of historical bars, using a selectable distance metric
// (Lorentzian by default—it dampens outliers caused by news/FOMC "warps"
// in price-time).
//
// ── Upgrades over classic Lorentzian Classification ─────────────────────────
//  1. Zero library dependencies — fully self-contained, publishable as-is.
//  2. Six features (adds MFI volume flow + Fisher Transform) with per-feature
//     importance WEIGHTS.
//  3. Four selectable distance metrics: Lorentzian / Manhattan / Euclidean /
//     Hybrid.
//  4. Properly time-aligned training set: features are stored at the bar the
//     label describes (classic LDC stores them misaligned by the horizon).
//  5. ATR neutral-zone labeling — tiny moves are labeled NEUTRAL so chop never
//     pollutes the training set.
//  6. Distance-WEIGHTED voting (closer neighbors vote louder) instead of a raw
//     label sum.
//  7. Confidence score (0–100%) on every prediction + minimum-confidence gate.
//  8. Adaptive K — neighbor count auto-shrinks in high volatility for faster
//     reaction, expands in quiet regimes for stability.
//  9. Sliding training window over the most RECENT maxBarsBack bars (classic
//     LDC trains on the oldest ones).
// 10. Configurable prediction horizon (classic is hardcoded to 4 bars).
// 11. ATR trailing-stop exit mode with plotted stop line, alongside fixed-bar
//     and dynamic-kernel exits.
// 12. Optional higher-timeframe trend confluence filter.
// 13. Live dashboard: signal, confidence, regime state, adaptive K, calibration
//     win-rate. (Calibration only — NOT a backtest.)

//@version=6
indicator('Quantum ML Engine — Adaptive Lorentzian Classification [Quantum Algo]', 'Quantum ML Engine [Quantum Algo]', overlay = true, precision = 4, max_labels_count = 500)

// ════════════════════════════════════════
// CONSTANTS
// ════════════════════════════════════════
int LONG    =  1
int SHORT   = -1
int NEUTRAL =  0

color C_BULL  = color.new(#00E5FF, 0)   // Quantum cyan
color C_BEAR  = color.new(#FF3D71, 0)   // Quantum red
color C_GOLD  = color.new(#FFC247, 0)
color C_GRAY  = color.new(#787B86, 0)
color C_TRANS = color.new(#000000, 100)

// ════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════
// ── General
src             = input.source(close, 'Source',                         group = 'General')
maxBarsBack     = input.int(2000, 'Max Bars Back', minval = 200, maxval = 5000, group = 'General', tooltip = 'Size of the sliding training window (most recent bars).')
horizon         = input.int(4, 'Prediction Horizon (bars)', minval = 1, maxval = 20, group = 'General', tooltip = 'How many bars ahead the model is trained to predict. Classic LDC hardcodes 4.')
neutralZoneMult = input.float(0.3, 'Neutral Zone (× ATR)', minval = 0, step = 0.1, group = 'General', tooltip = 'Historical moves smaller than this many ATRs are labeled NEUTRAL and excluded from directional training. Cleans chop out of the training set. 0 = off (classic behavior).')

// ── Engine
baseK         = input.int(8, 'Neighbors (K)', minval = 1, maxval = 100, group = 'ML Engine')
useAdaptiveK  = input.bool(true, 'Adaptive K (volatility-scaled)', group = 'ML Engine', tooltip = 'Shrinks K up to 40% in high-volatility regimes (faster reaction), keeps full K in quiet regimes (more stability).')
chronoSpacing = input.int(4, 'Chronological Spacing', minval = 1, maxval = 20, group = 'ML Engine', tooltip = 'Minimum bar distance between sampled neighbors. Prevents oversampling a single market event.')
metric        = input.string('Lorentzian', 'Distance Metric', options = ['Lorentzian', 'Manhattan', 'Euclidean', 'Hybrid'], group = 'ML Engine', tooltip = 'Lorentzian: log(1+|Δ|) per feature — dampens outliers. Hybrid: 50/50 Lorentzian + Manhattan.')
useDistWeight = input.bool(true, 'Distance-Weighted Voting', group = 'ML Engine', tooltip = 'Closer neighbors vote louder (weight = 1/(1+d)). Off = classic equal-vote sum.')
minConfidence = input.float(20, 'Min Confidence %', minval = 0, maxval = 100, step = 5, group = 'ML Engine', tooltip = 'Predictions below this confidence are ignored. 0 = classic behavior.')

// ── Feature Engineering (type, param A, param B, importance weight)
fCount   = input.int(6, 'Feature Count', minval = 2, maxval = 6, group = 'Feature Engineering')
f1Type   = input.string('RSI',    'F1', options = ['RSI', 'WT', 'CCI', 'ADX', 'MFI', 'FISHER'], inline = 'f1', group = 'Feature Engineering')
f1A      = input.int(14, 'A',  inline = 'f1', group = 'Feature Engineering')
f1B      = input.int(1,  'B',  inline = 'f1', group = 'Feature Engineering')
f1W      = input.float(1.0, 'W', step = 0.1, minval = 0, inline = 'f1', group = 'Feature Engineering')
f2Type   = input.string('WT',     'F2', options = ['RSI', 'WT', 'CCI', 'ADX', 'MFI', 'FISHER'], inline = 'f2', group = 'Feature Engineering')
f2A      = input.int(10, 'A',  inline = 'f2', group = 'Feature Engineering')
f2B      = input.int(11, 'B',  inline = 'f2', group = 'Feature Engineering')
f2W      = input.float(1.0, 'W', step = 0.1, minval = 0, inline = 'f2', group = 'Feature Engineering')
f3Type   = input.string('CCI',    'F3', options = ['RSI', 'WT', 'CCI', 'ADX', 'MFI', 'FISHER'], inline = 'f3', group = 'Feature Engineering')
f3A      = input.int(20, 'A',  inline = 'f3', group = 'Feature Engineering')
f3B      = input.int(1,  'B',  inline = 'f3', group = 'Feature Engineering')
f3W      = input.float(1.0, 'W', step = 0.1, minval = 0, inline = 'f3', group = 'Feature Engineering')
f4Type   = input.string('ADX',    'F4', options = ['RSI', 'WT', 'CCI', 'ADX', 'MFI', 'FISHER'], inline = 'f4', group = 'Feature Engineering')
f4A      = input.int(20, 'A',  inline = 'f4', group = 'Feature Engineering')
f4B      = input.int(2,  'B',  inline = 'f4', group = 'Feature Engineering')
f4W      = input.float(1.0, 'W', step = 0.1, minval = 0, inline = 'f4', group = 'Feature Engineering')
f5Type   = input.string('MFI',    'F5', options = ['RSI', 'WT', 'CCI', 'ADX', 'MFI', 'FISHER'], inline = 'f5', group = 'Feature Engineering')
f5A      = input.int(14, 'A',  inline = 'f5', group = 'Feature Engineering')
f5B      = input.int(1,  'B',  inline = 'f5', group = 'Feature Engineering')
f5W      = input.float(0.8, 'W', step = 0.1, minval = 0, inline = 'f5', group = 'Feature Engineering')
f6Type   = input.string('FISHER', 'F6', options = ['RSI', 'WT', 'CCI', 'ADX', 'MFI', 'FISHER'], inline = 'f6', group = 'Feature Engineering')
f6A      = input.int(9,  'A',  inline = 'f6', group = 'Feature Engineering')
f6B      = input.int(1,  'B',  inline = 'f6', group = 'Feature Engineering')
f6W      = input.float(0.8, 'W', step = 0.1, minval = 0, inline = 'f6', group = 'Feature Engineering')

// ── Filters
useVolFilter  = input.bool(true,  'Volatility Filter', group = 'Filters', tooltip = 'Only trade when recent volatility exceeds the long-run baseline (expanding regime).')
useRegime     = input.bool(true,  'Regime Filter', inline = 'reg', group = 'Filters')
regimeThr     = input.float(0.1, 'Threshold', step = 0.05, minval = 0, inline = 'reg', group = 'Filters', tooltip = 'Trend strength = |EMA20 − EMA50| / ATR. Must exceed threshold (filters ranging markets).')
useAdxFilter  = input.bool(false, 'ADX Filter', inline = 'adx', group = 'Filters')
adxThr        = input.int(20, 'Threshold', minval = 0, maxval = 100, inline = 'adx', group = 'Filters')
useEmaFilter  = input.bool(false, 'EMA Filter', inline = 'ema', group = 'Filters')
emaPeriod     = input.int(200, 'Period', minval = 1, inline = 'ema', group = 'Filters')
useSmaFilter  = input.bool(false, 'SMA Filter', inline = 'sma', group = 'Filters')
smaPeriod     = input.int(200, 'Period', minval = 1, inline = 'sma', group = 'Filters')
useHtfFilter  = input.bool(false, 'HTF Confluence', inline = 'htf', group = 'Filters')
htfTimeframe  = input.timeframe('240', '', inline = 'htf', group = 'Filters')
htfEmaLen     = input.int(50, 'EMA', minval = 1, inline = 'htf', group = 'Filters', tooltip = 'Longs only above the higher-timeframe EMA, shorts only below.')

// ── Kernel Regression
useKernelFilter    = input.bool(true,  'Trade with Kernel', inline = 'k1', group = 'Kernel')
showKernelEstimate = input.bool(true,  'Show Estimate', inline = 'k1', group = 'Kernel')
useKernelSmoothing = input.bool(false, 'Enhanced Smoothing (crossover mode)', group = 'Kernel')
kLookback  = input.int(8, 'Lookback', minval = 3, inline = 'k2', group = 'Kernel')
kRelWeight = input.float(8.0, 'Rel. Weight', step = 0.25, inline = 'k2', group = 'Kernel')
kRegLevel  = input.int(25, 'Regression Level', minval = 2, inline = 'k2', group = 'Kernel')
kLag       = input.int(2, 'Lag', minval = 1, maxval = 5, inline = 'k2', group = 'Kernel')

// ── Exits
showExits       = input.bool(false, 'Show Exit Marks', group = 'Exits')
useDynamicExits = input.bool(false, 'Dynamic Kernel Exits', group = 'Exits', tooltip = 'Let winners run — exit on kernel slope reversal instead of fixed horizon.')
useAtrTrail     = input.bool(false, 'ATR Trailing Stop', inline = 'tr', group = 'Exits')
atrTrailMult    = input.float(2.0, '× ATR', step = 0.25, minval = 0.5, inline = 'tr', group = 'Exits')

// ── Display
showBarColors  = input.bool(true, 'Bar Colors', group = 'Display')
showPredLabels = input.bool(true, 'Prediction Labels', group = 'Display')
showDashboard  = input.bool(true, 'Dashboard', group = 'Display')
colorCompress  = input.int(1, 'Color Compression', minval = 1, maxval = 10, group = 'Display')

// ════════════════════════════════════════
// NORMALIZATION & FEATURE FUNCTIONS
// (self-contained — no library imports)
// ════════════════════════════════════════
minimax(float s) =>
    var float mn = na
    var float mx = na
    if not na(s)
        mn := na(mn) ? s : math.min(mn, s)
        mx := na(mx) ? s : math.max(mx, s)
    rng = mx - mn
    not na(rng) and rng > 0 ? (s - mn) / rng : 0.5

n_rsi(float s, int len, int smooth) =>
    nz(ta.ema(ta.rsi(s, len), math.max(smooth, 1)) / 100, 0.5)

n_wt(float s, int n1, int n2) =>
    ema1 = ta.ema(s, n1)
    dev  = ta.ema(math.abs(s - ema1), n1)
    ci   = (s - ema1) / math.max(0.015 * dev, 1e-10)
    wt1  = ta.ema(ci, n2)
    wt2  = ta.sma(wt1, 4)
    minimax(wt1 - wt2)

n_cci(float s, int len, int smooth) =>
    minimax(ta.ema(ta.cci(s, len), math.max(smooth, 1)))

n_adx(int len) =>
    [diP, diM, adxV] = ta.dmi(len, len)
    nz(adxV / 100, 0.5)

n_mfi(int len) =>
    nz(ta.mfi(hlc3, len) / 100, 0.5)

n_fisher(int len) =>
    hi = ta.highest(hl2, len)
    lo = ta.lowest(hl2, len)
    var float v = 0.0
    v := 0.66 * ((hl2 - lo) / math.max(hi - lo, 1e-10) - 0.5) + 0.67 * nz(v[1])
    v := math.min(math.max(v, -0.999), 0.999)
    var float fish = 0.0
    fish := 0.5 * math.log((1 + v) / (1 - v)) + 0.5 * nz(fish[1])
    math.atan(fish) / math.pi + 0.5   // map ℝ → (0, 1)

seriesFrom(string ftype, int pA, int pB) =>
    switch ftype
        'RSI'    => n_rsi(src, pA, pB)
        'WT'     => n_wt(hlc3, pA, pB)
        'CCI'    => n_cci(src, pA, pB)
        'ADX'    => n_adx(pA)
        'MFI'    => n_mfi(pA)
        'FISHER' => n_fisher(pA)
        => n_rsi(src, pA, pB)

// Live feature vector
float f1 = seriesFrom(f1Type, f1A, f1B)
float f2 = seriesFrom(f2Type, f2A, f2B)
float f3 = seriesFrom(f3Type, f3A, f3B)
float f4 = seriesFrom(f4Type, f4A, f4B)
float f5 = seriesFrom(f5Type, f5A, f5B)
float f6 = seriesFrom(f6Type, f6A, f6B)

// ════════════════════════════════════════
// TRAINING DATA (time-aligned)
// Each stored sample pairs the feature vector AT bar (now − horizon) with the
// realized outcome over the following `horizon` bars. No misalignment, no lookahead.
// ════════════════════════════════════════
atrLabel = ta.atr(20)
outcome  = src - src[horizon]
labelThr = nz(neutralZoneMult * atrLabel[horizon], 0)
yNow     = outcome > labelThr ? LONG : outcome < -labelThr ? SHORT : NEUTRAL

var yTrain = array.new_int()
var f1Arr  = array.new_float()
var f2Arr  = array.new_float()
var f3Arr  = array.new_float()
var f4Arr  = array.new_float()
var f5Arr  = array.new_float()
var f6Arr  = array.new_float()

array.push(yTrain, yNow)
array.push(f1Arr, nz(f1[horizon], f1))
array.push(f2Arr, nz(f2[horizon], f2))
array.push(f3Arr, nz(f3[horizon], f3))
array.push(f4Arr, nz(f4[horizon], f4))
array.push(f5Arr, nz(f5[horizon], f5))
array.push(f6Arr, nz(f6[horizon], f6))

// ════════════════════════════════════════
// DISTANCE METRICS
// ════════════════════════════════════════
pairDist(float a, float b) =>
    diff = math.abs(a - b)
    switch metric
        'Lorentzian' => math.log(1 + diff)
        'Manhattan'  => diff
        'Euclidean'  => diff * diff
        'Hybrid'     => 0.5 * math.log(1 + diff) + 0.5 * diff
        => math.log(1 + diff)

getDistance(int i) =>
    float d = f1W * pairDist(f1, array.get(f1Arr, i)) + f2W * pairDist(f2, array.get(f2Arr, i))
    if fCount >= 3
        d += f3W * pairDist(f3, array.get(f3Arr, i))
    if fCount >= 4
        d += f4W * pairDist(f4, array.get(f4Arr, i))
    if fCount >= 5
        d += f5W * pairDist(f5, array.get(f5Arr, i))
    if fCount >= 6
        d += f6W * pairDist(f6, array.get(f6Arr, i))
    metric == 'Euclidean' ? math.sqrt(d) : d

// ════════════════════════════════════════
// FILTERS (computed globally)
// ════════════════════════════════════════
recentVol = ta.atr(10)
histVol   = ta.atr(40)
filtVolatility = useVolFilter ? recentVol > histVol : true

trendStrength = math.abs(ta.ema(close, 20) - ta.ema(close, 50)) / math.max(ta.atr(20), 1e-10)
filtRegime = useRegime ? trendStrength > regimeThr : true

[dmiP, dmiM, adxVal] = ta.dmi(14, 14)
filtAdx = useAdxFilter ? adxVal > adxThr : true

filterAll = filtVolatility and filtRegime and filtAdx

emaValue      = ta.ema(close, emaPeriod)
smaValue      = ta.sma(close, smaPeriod)
isEmaUptrend   = useEmaFilter ? close > emaValue : true
isEmaDowntrend = useEmaFilter ? close < emaValue : true
isSmaUptrend   = useSmaFilter ? close > smaValue : true
isSmaDowntrend = useSmaFilter ? close < smaValue : true

htfEma = request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, htfEmaLen), barmerge.gaps_off, barmerge.lookahead_off)
isHtfUptrend   = useHtfFilter ? close > htfEma : true
isHtfDowntrend = useHtfFilter ? close < htfEma : true

// ════════════════════════════════════════
// ADAPTIVE K
// ════════════════════════════════════════
volRank    = nz(ta.percentrank(recentVol, 100) / 100, 0.5)
kNeighbors = useAdaptiveK ? math.max(3, math.round(baseK * (1.0 - 0.4 * volRank))) : baseK

// ════════════════════════════════════════
// CORE ML — ANN search over a SLIDING window of the most recent bars
// Neighbor pool persists across bars; the monotonic lastDistance gate keeps it
// stable while the 75th-percentile reset lets genuinely closer samples rotate in.
// ════════════════════════════════════════
var distances = array.new_float()
var votes     = array.new_int()
var float prediction = 0.0
var float confidence = 0.0
var int   signal     = NEUTRAL

maxBarsBackIndex = last_bar_index >= maxBarsBack ? last_bar_index - maxBarsBack : 0

if bar_index >= maxBarsBackIndex
    float lastDistance = -1.0
    int total    = array.size(yTrain)
    int startIdx = math.max(0, total - maxBarsBack)
    for i = startIdx to total - 1
        if (i - startIdx) % chronoSpacing == 0
            d = getDistance(i)
            if d >= lastDistance
                lastDistance := d
                array.push(distances, d)
                array.push(votes, array.get(yTrain, i))
                if array.size(votes) > kNeighbors
                    lastDistance := array.get(distances, math.min(array.size(distances) - 1, math.round(kNeighbors * 3.0 / 4.0)))
                    array.shift(distances)
                    array.shift(votes)
    // Trim pool if adaptive K shrank since last bar
    while array.size(votes) > kNeighbors
        array.shift(distances)
        array.shift(votes)
    // Distance-weighted vote + confidence
    float wSum = 0.0
    float vSum = 0.0
    if array.size(votes) > 0
        for j = 0 to array.size(votes) - 1
            w = useDistWeight ? 1.0 / (1.0 + array.get(distances, j)) : 1.0
            wSum += w
            vSum += w * array.get(votes, j)
    prediction := useDistWeight and wSum > 0 ? vSum / wSum * kNeighbors : vSum
    confidence := wSum > 0 ? math.abs(vSum) / wSum * 100 : 0.0

// ════════════════════════════════════════
// SIGNAL
// ════════════════════════════════════════
passConfidence = confidence >= minConfidence
signal := prediction > 0 and passConfidence and filterAll ? LONG : prediction < 0 and passConfidence and filterAll ? SHORT : nz(signal[1])

// Bar-count fractal filters
var int barsHeld = 0
barsHeld := ta.change(signal) != 0 ? 0 : barsHeld + 1
isHeldFull     = barsHeld == horizon
isHeldPartial  = barsHeld > 0 and barsHeld < horizon
isDifferentSignalType = ta.change(signal) != 0
isEarlySignalFlip = ta.change(signal) != 0 and (ta.change(signal[1]) != 0 or ta.change(signal[2]) != 0 or ta.change(signal[3]) != 0)

isBuySignal  = signal == LONG  and isEmaUptrend  and isSmaUptrend  and isHtfUptrend
isSellSignal = signal == SHORT and isEmaDowntrend and isSmaDowntrend and isHtfDowntrend
isLastSignalBuy  = signal[horizon] == LONG  and isEmaUptrend[horizon]  and isSmaUptrend[horizon]
isLastSignalSell = signal[horizon] == SHORT and isEmaDowntrend[horizon] and isSmaDowntrend[horizon]
isNewBuySignal  = isBuySignal and isDifferentSignalType
isNewSellSignal = isSellSignal and isDifferentSignalType

// ════════════════════════════════════════
// KERNEL REGRESSION (own implementation)
// ════════════════════════════════════════
kernelRQ(float s, int lb, float rw, int startAt) =>
    float cw = 0.0
    float sw = 0.0
    int span = math.min(startAt + 2 * lb + 10, bar_index)
    for i = 0 to span
        w = math.pow(1.0 + (i * i) / (2.0 * rw * lb * lb), -rw)
        cw += s[i] * w
        sw += w
    sw > 0 ? cw / sw : s

kernelGauss(float s, int lb, int startAt) =>
    float cw = 0.0
    float sw = 0.0
    int span = math.min(startAt + 2 * lb + 10, bar_index)
    for i = 0 to span
        w = math.exp(-(i * i) / (2.0 * lb * lb))
        cw += s[i] * w
        sw += w
    sw > 0 ? cw / sw : s

yhat1 = kernelRQ(src, kLookback, kRelWeight, kRegLevel)
yhat2 = kernelGauss(src, math.max(kLookback - kLag, 2), kRegLevel)

wasBearishRate = yhat1[2] > yhat1[1]
wasBullishRate = yhat1[2] < yhat1[1]
isBearishRate  = yhat1[1] > yhat1
isBullishRate  = yhat1[1] < yhat1
isBearishChange = isBearishRate and wasBullishRate
isBullishChange = isBullishRate and wasBearishRate
isBullishCross  = ta.crossover(yhat2, yhat1)
isBearishCross  = ta.crossunder(yhat2, yhat1)
isBullishSmooth = yhat2 >= yhat1
isBearishSmooth = yhat2 <= yhat1

alertBullish = useKernelSmoothing ? isBullishCross : isBullishChange
alertBearish = useKernelSmoothing ? isBearishCross : isBearishChange
isBullishKernel = useKernelFilter ? (useKernelSmoothing ? isBullishSmooth : isBullishRate) : true
isBearishKernel = useKernelFilter ? (useKernelSmoothing ? isBearishSmooth : isBearishRate) : true

plotColor = showKernelEstimate ? (useKernelSmoothing ? (isBullishSmooth ? C_BULL : C_BEAR) : (isBullishRate ? C_BULL : C_BEAR)) : C_TRANS
plot(yhat1, 'Kernel Regression Estimate', color = plotColor, linewidth = 2)

// ════════════════════════════════════════
// ENTRIES & EXITS
// ════════════════════════════════════════
startLongTrade  = isNewBuySignal  and isBullishKernel and isEmaUptrend  and isSmaUptrend  and isHtfUptrend
startShortTrade = isNewSellSignal and isBearishKernel and isEmaDowntrend and isSmaDowntrend and isHtfDowntrend

// Dynamic (kernel) exits
barsSinceShortEntry = nz(ta.barssince(startShortTrade), 1000000)
barsSinceBullFlip   = nz(ta.barssince(alertBullish), 1000000)
barsSinceLongEntry  = nz(ta.barssince(startLongTrade), 1000000)
barsSinceBearFlip   = nz(ta.barssince(alertBearish), 1000000)
isValidShortExit = barsSinceBullFlip > barsSinceShortEntry
isValidLongExit  = barsSinceBearFlip > barsSinceLongEntry
endLongDynamic  = isBearishChange and isValidLongExit[1]
endShortDynamic = isBullishChange and isValidShortExit[1]

// Strict (fixed-horizon) exits
endLongStrict  = ((isHeldFull and isLastSignalBuy)  or (isHeldPartial and isNewSellSignal and isLastSignalBuy))  and startLongTrade[horizon]
endShortStrict = ((isHeldFull and isLastSignalSell) or (isHeldPartial and isNewBuySignal  and isLastSignalSell)) and startShortTrade[horizon]

isDynamicValid = not useEmaFilter and not useSmaFilter and not useKernelSmoothing

// ATR trailing stop
var int   pos   = 0
var float trail = na
atrExit = ta.atr(14)
longStopHit  = pos == 1  and not na(trail) and close < trail
shortStopHit = pos == -1 and not na(trail) and close > trail

endLongTrade  = (useDynamicExits and isDynamicValid ? endLongDynamic  : endLongStrict)  or (useAtrTrail and longStopHit)
endShortTrade = (useDynamicExits and isDynamicValid ? endShortDynamic : endShortStrict) or (useAtrTrail and shortStopHit)

if startLongTrade
    pos := 1
    trail := close - atrExit * atrTrailMult
else if startShortTrade
    pos := -1
    trail := close + atrExit * atrTrailMult
else if pos == 1
    trail := math.max(trail, close - atrExit * atrTrailMult)
    if endLongTrade
        pos := 0
        trail := na
else if pos == -1
    trail := math.min(trail, close + atrExit * atrTrailMult)
    if endShortTrade
        pos := 0
        trail := na

plot(useAtrTrail and pos != 0 ? trail : na, 'ATR Trail', color = pos == 1 ? C_BULL : C_BEAR, style = plot.style_linebr, linewidth = 1)

// ════════════════════════════════════════
// PLOTTING
// ════════════════════════════════════════
compressionFactor = kNeighbors / float(colorCompress)
c_pred = prediction > 0 ? color.from_gradient(prediction, 0, compressionFactor, C_GRAY, C_BULL) : prediction < 0 ? color.from_gradient(prediction, -compressionFactor, 0, C_BEAR, C_GRAY) : C_GRAY

plotshape(startLongTrade  ? low  : na, 'Buy',  shape.labelup,   location.belowbar, color = c_pred, size = size.small, offset = 0)
plotshape(startShortTrade ? high : na, 'Sell', shape.labeldown, location.abovebar, color = c_pred, size = size.small, offset = 0)
plotshape(endLongTrade  and showExits ? high : na, 'StopBuy',  shape.xcross, location.absolute, color = C_BULL, size = size.tiny, offset = 0)
plotshape(endShortTrade and showExits ? low  : na, 'StopSell', shape.xcross, location.absolute, color = C_BEAR, size = size.tiny, offset = 0)

if showPredLabels
    txt = str.tostring(math.round(prediction, 1)) + '\n' + str.tostring(math.round(confidence)) + '%'
    yVal = prediction > 0 ? high + hl2 * 0.001 : low - hl2 * 0.001
    label.new(bar_index, yVal, txt, xloc.bar_index, yloc.price, C_TRANS, prediction > 0 ? label.style_label_up : label.style_label_down, c_pred, size.small, text.align_center)

barcolor(showBarColors ? color.new(c_pred, 55) : na)

// ════════════════════════════════════════
// CALIBRATION STATS (NOT a backtest — feature-engineering feedback only)
// ════════════════════════════════════════
var int calTrades = 0
var int calWins   = 0
var int calFlips  = 0
if startLongTrade[horizon]
    calTrades += 1
    if close > close[horizon]
        calWins += 1
if startShortTrade[horizon]
    calTrades += 1
    if close < close[horizon]
        calWins += 1
if isEarlySignalFlip
    calFlips += 1

// ════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════
if showDashboard and barstate.islast
    var tbl = table.new(position.top_right, 2, 9, bgcolor = color.new(#0B1020, 15), frame_color = color.new(#00E5FF, 70), frame_width = 1, border_color = color.new(#FFFFFF, 92), border_width = 1)
    cellTxt = color.new(#E6EDF7, 0)
    table.cell(tbl, 0, 0, 'QUANTUM ML ENGINE', text_color = C_GOLD, text_size = size.small)
    table.cell(tbl, 1, 0, 'ANN · ' + metric, text_color = C_GRAY, text_size = size.tiny)
    table.cell(tbl, 0, 1, 'Signal', text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 1, 1, signal == LONG ? 'LONG ▲' : signal == SHORT ? 'SHORT ▼' : 'NEUTRAL', text_color = signal == LONG ? C_BULL : signal == SHORT ? C_BEAR : C_GRAY, text_size = size.small)
    table.cell(tbl, 0, 2, 'Confidence', text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(math.round(confidence)) + '%', text_color = confidence >= minConfidence ? C_BULL : C_GRAY, text_size = size.small)
    table.cell(tbl, 0, 3, 'Adaptive K', text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 1, 3, str.tostring(kNeighbors) + ' / ' + str.tostring(baseK), text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 0, 4, 'Regime', text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 1, 4, filtRegime ? 'TRENDING' : 'RANGING', text_color = filtRegime ? C_BULL : C_GOLD, text_size = size.small)
    table.cell(tbl, 0, 5, 'Volatility', text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 1, 5, filtVolatility ? 'EXPANDING' : 'CONTRACTING', text_color = filtVolatility ? C_BULL : C_GOLD, text_size = size.small)
    table.cell(tbl, 0, 6, 'Kernel Bias', text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 1, 6, isBullishKernel and not isBearishKernel ? 'BULLISH' : isBearishKernel and not isBullishKernel ? 'BEARISH' : 'MIXED', text_color = isBullishKernel and not isBearishKernel ? C_BULL : isBearishKernel and not isBullishKernel ? C_BEAR : C_GRAY, text_size = size.small)
    table.cell(tbl, 0, 7, 'Calibration WR*', text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 1, 7, calTrades > 0 ? str.tostring(math.round(100.0 * calWins / calTrades)) + '%  (' + str.tostring(calTrades) + ')' : '—', text_color = cellTxt, text_size = size.small)
    table.cell(tbl, 0, 8, '*' + str.tostring(horizon) + '-bar calibration, not a backtest', text_color = C_GRAY, text_size = size.tiny)
    table.cell(tbl, 1, 8, 'Flips: ' + str.tostring(calFlips), text_color = C_GRAY, text_size = size.tiny)

// ════════════════════════════════════════
// BACKTEST STREAM + ALERTS
// ════════════════════════════════════════
backTestStream = startLongTrade ? 1 : endLongTrade ? 2 : startShortTrade ? -1 : endShortTrade ? -2 : 0
plot(backTestStream, 'Backtest Stream', display = display.none)
plot(prediction, 'Prediction', display = display.none)
plot(confidence, 'Confidence', display = display.none)

alertcondition(startLongTrade,  'QME Open Long ▲',   'QME Open Long ▲ | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(endLongTrade,    'QME Close Long ▲',  'QME Close Long ▲ | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(startShortTrade, 'QME Open Short ▼',  'QME Open Short ▼ | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(endShortTrade,   'QME Close Short ▼', 'QME Close Short ▼ | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(startLongTrade or startShortTrade, 'QME Open Position ▲▼',  'QME Open Position ▲▼ | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(endLongTrade or endShortTrade,     'QME Close Position ▲▼', 'QME Close Position ▲▼ | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(alertBullish, 'QME Kernel Bullish', 'QME Kernel Bullish ▲ | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(alertBearish, 'QME Kernel Bearish', 'QME Kernel Bearish ▼ | {{ticker}}@{{close}} | ({{interval}})')
````
