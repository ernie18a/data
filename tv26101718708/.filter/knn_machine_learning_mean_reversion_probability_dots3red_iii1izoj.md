# KNN Machine Learning Mean Reversion Probability [Dots3Red]

- url: https://www.tradingview.com/script/iiI1izOJ-KNN-Machine-Learning-Mean-Reversion-Probability-Dots3Red/
- type: indicator
- pine_id: PUB;cbb1c9b473f749f7a86ca6d8ff63131d
- version: 2.0

## Description

█ [b]OVERVIEW[/b]

This script applies a K-Nearest Neighbors (KNN) machine learning algorithm to estimate the probability that price will revert to its moving average within a defined number of bars. Rather than predicting momentum direction, it asks a more specific question: [i]how likely is it that this extension snaps back?[/i]

The model searches historical bars for situations that looked like the current one — same degree of stretch, same RSI exhaustion profile, same volume behavior — and measures how often those situations ended in a reversion to the basis MA. That proportion becomes the live probability shown on your chart.

█ [b]METHODOLOGY[/b]
The indicator follows a supervised machine-learning pipeline with five distinct stages.

[b]1 — Labeling (what we are predicting)[/b]
Each historical bar receives a label based on what actually happened next. If price was extended above the basis MA and touched it within the [i]Reversion Window[/i] — that bar is labeled a successful reversion. If it did not touch — labeled as no reversion. The same logic applies from below. This is the core distinction from momentum KNN indicators: the target is [i]reversion to fair value[/i], not directional price movement.

[b]2 — Feature engineering (what we measure)[/b]
Five features capture how stretched current price conditions are, each Z-score normalized to remove scale bias:
•  [b]MA Distance[/b] — signed % distance of close from the basis MA. The primary extension signal.
•  [b]Bollinger Band position[/b] — where price sits within the bands, normalizing extension relative to current volatility.
•  [b]RSI deviation[/b] — how far RSI has moved from neutral (50). Captures momentum exhaustion.
•  [b]Body compression[/b] — ratio of candle body to total range. Small bodies near extremes signal hesitation and loss of directional conviction.
•  [b]Volume fade[/b] — declining volume during an extension is a classic exhaustion signature.

[b]3 — Z-score normalization[/b]
All five features are standardized using a rolling mean and standard deviation computed on prior bars only (look-ahead free). This ensures the KNN distance calculation is not biased by features of different scales.

[b]4 — KNN engine[/b]
The algorithm scans the historical lookback window for the K most similar past bars, measured by [i]Minkowski Distance[/i] across all five features simultaneously. Closer neighbors receive exponentially higher voting weight via a [i]Gaussian Kernel[/i], so the prediction is driven by the most relevant historical analogs — not a simple majority vote.

[b]5 — Dual probability output[/b]
Two independent probabilities are maintained and tracked separately:
•  [b]P(reversion from above)[/b] — for overbought / extended-high setups.
•  [b]P(reversion from below)[/b] — for oversold / extended-low setups.

They are kept separate because bear-side extensions and bull-side extensions have statistically different behavior — bear moves are typically faster and sharper. A signal fires when the relevant probability crosses the user-defined threshold, [i]and[/i] only when price is actually extended (see Extension Gate below).


█ [b]WHAT MAKES THIS DIFFERENT[/b]
Most published KNN indicators predict momentum direction — will price go up or down next bar? This indicator predicts something more specific: [i]will price return to its average?[/i]

The distinction matters for several reasons:
1 — A high momentum reading can persist for many bars. A stretched reading has a natural gravity pulling it back, and measuring the historical probability of that snap is a more tractable problem than direction forecasting.
2 — The two probability channels are trained on separate populations, accounting for the asymmetry between bull and bear extensions.
3 — The [i]Extension Gate[/i] ensures signals only appear when there is actually something to revert from — no signals in flat, choppy, low-volatility conditions.


█ [b]EXTENSION GATE[/b]
Even if the KNN model outputs a high reversion probability, no signal appears unless price is beyond [i]Gate Multiplier × ATR[/i] from the basis MA. This prevents false signals in low-volatility or ranging conditions where mean reversion setups carry no statistical edge.


█ [b]HOW TO USE[/b]
[b]Signal shapes (▲ Rev / ▼ Rev)[/b]

Fire when P(reversion) crosses the threshold AND price passes the extension gate. The label at the signal bar shows the exact probability at the moment of firing.

[b]Snap zone fill[/b]
When a signal is active, the region between current price and the basis MA is shaded. This is the reversion target zone — where price is statistically expected to return. The fill deactivates automatically once price reverts back through the basis.

[b]Bar colors[/b]
•  Bright green/red — active probability above the threshold on the current price side.
•  Dimmed green/red — probability elevated but below threshold, approaching signal territory.
•  No color — neutral or low reversion probability.

[b]Background flash[/b]
A faint background confirms the exact bar on which a signal fired.

[b]Recommended workflow[/b]
1 — Set the [i]Basis MA[/i] to your preferred mean reversion average. EMA 20 is a common starting point for intraday and swing setups.
2 — Tune the [i]Reversion Window[/i] to match your typical trade hold time in bars.
3 — Adjust the [i]Extension Gate multiplier[/i] to the asset's volatility profile. Crypto typically requires higher values than forex or equities.
4 — Use the [i]Probability Threshold[/i] to control signal frequency. 0.65 gives moderate frequency; 0.75 and above is more selective.
5 — Combine with volume analysis or candlestick confirmation at signal bars for additional confluence before entering a position.

[image]https://www.tradingview.com/x/P7DF561a/[/image]

█ [b]SETTINGS REFERENCE[/b]
[b]KNN Engine[/b]
•  [i]K Neighbors[/i] — how many historical analogs vote. Higher = smoother, slower to react.
•  [i]Lookback Window[/i] — size of the historical search space in bars.
•  [i]Reversion Window[/i] — bars within which price must touch the MA to count as a reversion.
•  [i]Minkowski p[/i] — distance metric exponent. 1 = Manhattan, 2 = Euclidean.
•  [i]Gaussian Bandwidth[/i] — controls how steeply neighbor weight falls with distance.
•  [i]Probability Threshold[/i] — minimum confidence required to show a signal.

[b]Feature Settings[/b]
•  [i]Basis MA type / length[/i] — the fair value line all features are measured against.
•  [i]Bollinger Band mult[/i] — standard deviation multiplier for the BB position feature.
•  [i]RSI length[/i] — period for the RSI exhaustion feature.
•  [i]Volume MA length[/i] — baseline for the volume fade feature.

[b]Extension Gate[/b]
•  [i]Require extension gate[/i] — toggle the ATR-based signal filter on/off.
•  [i]Gate band multiplier[/i] — how many ATRs from basis price must be before signaling.
•  [i]Gate ATR length[/i] — period for the ATR used in the gate calculation.


█ [b]LIMITATIONS[/b]
•  KNN is a lazy learner — it does not generalize beyond historical patterns in the lookback window. Strong trending regimes or structural breaks can produce elevated false signals.
•  The reversion probability reflects historical frequency, not a guarantee of future behavior.
•  On low-bar-count charts (e.g. weekly on newer assets), the lookback window may not contain enough samples to produce stable probability estimates.
•  Computation scales with lookback window size. Very large windows may slow chart rendering.


█ [b]DISCLAIMER[/b]
This indicator is a decision-support tool, not a trading system. It does not constitute financial advice. Always apply proper risk management and combine with your own analysis.

Algorithm: K-Nearest Neighbors (KNN)
Distance metric: Minkowski Distance
Preprocessing: Z-Score Normalization
Target: Probabilistic Mean Reversion

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("KNN Mean Reversion Probability [Dots3Red]", overlay=true, max_bars_back=5000)

C_BULL      = color.new(#00c896, 0)
C_BEAR      = color.new(#ff4466, 0)
C_BULL_DIM  = color.new(#00c896, 60)
C_BEAR_DIM  = color.new(#ff4466, 60)
C_NEUTRAL   = color.new(#64748b, 0)
C_SNAP_BULL = color.new(#00c896, 88)
C_SNAP_BEAR = color.new(#ff4466, 88)

GRP_KNN  = "🧠 KNN Engine"
GRP_FEAT = "📐 Feature Settings"
GRP_GATE = "🚦 Extension Gate"
GRP_VIS  = "🎨 Visuals"

// --- KNN Engine ---
k_val        = input.int   (60,    "K Neighbors",        minval=5,  maxval=300, group=GRP_KNN,
                             tooltip="How many similar past bars to vote. Higher = smoother but slower to react.")
win_size     = input.int   (800,   "Lookback Window",    minval=50, maxval=2000, group=GRP_KNN,
                             tooltip="How many historical bars to search for neighbors.")
rev_window   = input.int   (6,     "Reversion Window",   minval=1,  maxval=20,  group=GRP_KNN,
                             tooltip="Number of bars within which price must touch the basis MA to count as a reversion.")
p_dist       = input.float (2.0,   "Minkowski p",        minval=1.0, maxval=6.0, step=0.5, group=GRP_KNN,
                             tooltip="Distance metric exponent. 1 = Manhattan, 2 = Euclidean, higher = emphasises largest feature difference.")
gauss_bw     = input.float (1.5,   "Gaussian bandwidth", minval=0.1, maxval=5.0, step=0.1, group=GRP_KNN,
                             tooltip="Controls how quickly neighbor weight falls with distance. Lower = only closest neighbors matter.")
prob_thresh  = input.float (0.65,  "Probability threshold", minval=0.3, maxval=0.99, step=0.01, group=GRP_KNN,
                             tooltip="Minimum reversion probability required to show a signal.")
// --- Feature Settings ---
basis_type   = input.string("EMA", "Basis MA type", options=["SMA","EMA","WMA","HMA","RMA"], group=GRP_FEAT,
                             tooltip="The moving average used as 'fair value'. All features measure extension FROM this line.")
basis_len    = input.int   (20,    "Basis MA length",    minval=5,  group=GRP_FEAT)
bb_mult      = input.float (2.0,   "Bollinger Band mult",minval=0.5, maxval=4.0, step=0.1, group=GRP_FEAT,
                             tooltip="Standard deviation multiplier for Bollinger Bands used in features.")
rsi_len      = input.int   (14,    "RSI length",         minval=2,  group=GRP_FEAT)
vol_ma_len   = input.int   (20,    "Volume MA length",   minval=5,  group=GRP_FEAT,
                             tooltip="Baseline for volume fade feature — volume dropping relative to this is a reversion sign.")

// --- Extension Gate ---
use_gate     = input.bool  (true,  "Require extension gate", group=GRP_GATE,
                             tooltip="If enabled, signals only appear when price is meaningfully extended from the MA.")
gate_mult    = input.float (1.0,   "Gate band multiplier",   minval=0.1, maxval=3.0, step=0.1, group=GRP_GATE,
                             tooltip="Price must be beyond (gate_mult × ATR) from the basis MA to pass the gate.")
gate_atr_len = input.int   (14,    "Gate ATR length",        minval=1, group=GRP_GATE)

// --- Visuals ---
show_basis   = input.bool  (true,  "Show basis MA",        group=GRP_VIS)
show_snap    = input.bool  (true,  "Show snap zone fill",  group=GRP_VIS,
                             tooltip="Shades the region between price and basis MA when a signal is active.")
show_barclr  = input.bool  (true,  "Color bars by P(rev)", group=GRP_VIS)

//constants
var float offSet = 0.004

// ============================================================
// HELPER: MA SELECTOR
// ============================================================
f_ma(src, len, t) =>
    switch t
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        "HMA" => ta.hma(src, len)
        "RMA" => ta.rma(src, len)
        =>       ta.ema(src, len)

// ============================================================
// HELPER: Z-SCORE NORMALIZATION
// Uses [1] offset so current bar is not in the normalization sample,
// preventing look-ahead on the mean/stdev calculation.
// ============================================================
f_zscore(src, len) =>
    _mu  = ta.sma(src[1], len)
    _sig = ta.stdev(src[1], len)
    (src - _mu) / math.max(_sig, 1e-6)

// ============================================================
// BASE CALCULATIONS
// ============================================================
basis     = f_ma(close, basis_len, basis_type)

// Bollinger Bands (for BB position feature)
bb_std    = ta.stdev(close, basis_len)
bb_upper  = basis + bb_mult * bb_std
bb_lower  = basis - bb_mult * bb_std

// RSI
rsi       = ta.rsi(close, rsi_len)
// ATR for extension gate
gate_atr  = ta.atr(gate_atr_len)
// Volume ratio (current vs baseline — uses [1] to avoid look-ahead)
vol_ratio = volume / math.max(ta.sma(volume[1], vol_ma_len), 1)


// F1: Normalised distance of close from basis MA (signed)
f_dist = (close - basis) / math.max(basis, 1e-6) * 100

// F2: Bollinger Band position — where is price within the bands?
f_bb_pos = (close - basis) / math.max(bb_upper - basis, 1e-6)

// F3: RSI deviation from neutral (50).
f_rsi_dev = rsi - 50.0

// F4: Body-to-range compression ratio (Z-scored).
_body      = math.abs(close - open)
_range     = math.max(high - low, 1e-6)
f_body_cmp = _body / _range

// F5: Volume fade. Declining volume during extension = exhaustion.
f_vol_fade = -vol_ratio

// ============================================================
// Z-SCORE NORMALIZE ALL FEATURES over the lookback window
// ============================================================
z1 = f_zscore(f_dist,     win_size)
z2 = f_zscore(f_bb_pos,   win_size)
z3 = f_zscore(f_rsi_dev,  win_size)
z4 = f_zscore(f_body_cmp, win_size)
z5 = f_zscore(f_vol_fade, win_size)


f_label() =>
    int lbl = 0
    bool above_basis = close[rev_window] > basis[rev_window]
    bool below_basis = close[rev_window] < basis[rev_window]
    if above_basis
        // Check if price touched basis within next rev_window bars
        bool touched = false
        for j = 0 to rev_window - 1
            if low[rev_window - 1 - j] <= basis[rev_window - 1 - j]
                touched := true
        lbl := touched ? 1 : 0
    else if below_basis
        bool touched = false
        for j = 0 to rev_window - 1
            if high[rev_window - 1 - j] >= basis[rev_window - 1 - j]
                touched := true
        lbl := touched ? -1 : 0
    lbl


var float p_rev_above = 0.0
var float p_rev_below = 0.0

var float[] dist_arr  = array.new_float(0)
var float[] label_arr = array.new_float(0)

if bar_index > win_size + rev_window
    array.clear(dist_arr)
    array.clear(label_arr)

    for i = rev_window to win_size + rev_window by rev_window
        // Minkowski distance across all 5 features
        float d = math.pow(
             math.pow(math.abs(z1 - z1[i]), p_dist)
           + math.pow(math.abs(z2 - z2[i]), p_dist)
           + math.pow(math.abs(z3 - z3[i]), p_dist)
           + math.pow(math.abs(z4 - z4[i]), p_dist)
           + math.pow(math.abs(z5 - z5[i]), p_dist),
           1.0 / p_dist)
        array.push(dist_arr,  d)
        array.push(label_arr, f_label()[i])

    int n_samples = array.size(dist_arr)

    if n_samples >= k_val
        // Sort by distance ascending, pick K nearest
        int[] sorted_idx = array.sort_indices(dist_arr, order.ascending)

        // Compute sigma = median distance among K neighbors (for Gaussian kernel)
        int half_k  = math.max(1, int(k_val / 2))
        int med_idx = array.get(sorted_idx, math.min(half_k, n_samples - 1))
        float sigma = math.max(array.get(dist_arr, med_idx), 1e-6)

        float w_rev_above   = 0.0
        float w_rev_below   = 0.0
        float w_total_above = 0.0
        float w_total_below = 0.0

        for j = 0 to k_val - 1
            int   idx = array.get(sorted_idx, j)
            float d   = array.get(dist_arr,  idx)
            float lbl = array.get(label_arr, idx)

            // Gaussian kernel weight
            float w = math.exp(-math.pow(d, gauss_bw) / (2.0 * sigma * sigma))

            // Route to the correct probability accumulator based on label direction
            if lbl == 1       
                w_rev_above   += w
                w_total_above += w
            else if lbl == -1 
                w_rev_below   += w
                w_total_below += w
            else              // neighbor did NOT revert (label = 0)
                float neighbor_side = z1[array.get(sorted_idx, j)]
                if neighbor_side > 0
                    w_total_above += w
                else
                    w_total_below += w

        p_rev_above := w_total_above > 0 ? w_rev_above / w_total_above : 0.0
        p_rev_below := w_total_below > 0 ? w_rev_below / w_total_below : 0.0


ext_band  = gate_mult * gate_atr
bool extended_above = close > basis + ext_band
bool extended_below = close < basis - ext_band
bool gate_ok_short  = use_gate ? extended_above : true
bool gate_ok_long   = use_gate ? extended_below : true

// ============================================================
// SIGNAL GENERATION
// Active reversion probability for the current bar's side
// ============================================================
float p_active = close >= basis ? p_rev_above : p_rev_below

// Crossover detection — fires on the first bar threshold is exceeded
bool raw_signal_short = ta.crossover (p_rev_above, prob_thresh) and close > basis
bool raw_signal_long  = ta.crossover (p_rev_below, prob_thresh) and close < basis

// Deduplication: don't re-signal in the same direction without a reset
var int last_dir = 0
bool sig_short = false
bool sig_long  = false

if raw_signal_short and gate_ok_short and last_dir >= 0
    sig_short := true
    last_dir  := -1

if raw_signal_long and gate_ok_long and last_dir <= 0
    sig_long := true
    last_dir := 1

// Reset direction when price crosses back through basis
if close > basis and last_dir == 1
    last_dir := 0
if close < basis and last_dir == -1
    last_dir := 0

// ============================================================
// VISUALIZATION
// ============================================================

// --- Basis MA ---
plot(show_basis ? basis : na, "Basis MA", color=color.new(#94a3b8, 20), linewidth=1)

barcolor_col = p_active > prob_thresh ? (close >= basis ? C_BEAR : C_BULL) :
               p_active > prob_thresh * 0.7 ? (close >= basis ? C_BEAR_DIM : C_BULL_DIM) :
               na
barcolor(show_barclr ? barcolor_col : na)

var bool snap_active_short = false
var bool snap_active_long  = false

if sig_short
    snap_active_short := true
if sig_long
    snap_active_long := true
// Deactivate snap once price reverts back through basis
if close <= basis
    snap_active_short := false
if close >= basis
    snap_active_long := false

snap_top    = snap_active_short ? close : snap_active_long  ? basis : na
snap_bottom = snap_active_short ? basis : snap_active_long  ? close : na

p_snap_top = plot(show_snap ? snap_top    : na, display=display.none)
p_snap_bot = plot(show_snap ? snap_bottom : na, display=display.none)
fill(p_snap_top, p_snap_bot,
     color = snap_active_short ? C_SNAP_BEAR : snap_active_long ? C_SNAP_BULL : na)

// --- Background flash on signal ---
bgcolor(sig_short ? color.new(C_BEAR, 92) : sig_long ? color.new(C_BULL, 92) : na)

// --- Signal shapes ---
plotshape(sig_short, "Revert Down",
          shape.triangledown, location.abovebar,
          C_BEAR, size=size.tiny,
          text="Rev", textcolor=C_BEAR,
          force_overlay=true)

plotshape(sig_long, "Revert Up",
          shape.triangleup, location.belowbar,
          C_BULL, size=size.tiny,
          text="Rev", textcolor=C_BULL,
          force_overlay=true)


if sig_short
    label.new(bar_index, high*(1+offSet),
              "P=" + str.tostring(math.round(p_rev_above * 100)) + "%",
              style=label.style_label_down,
              color=color.new(C_BEAR, 80),
              textcolor=C_BEAR,
              size=10,
              force_overlay=true
              )

if sig_long
    label.new(bar_index, low*(1-offSet),
              "P=" + str.tostring(math.round(p_rev_below * 100)) + "%",
              style=label.style_label_up,
              color=color.new(C_BULL, 80),
              textcolor=C_BULL,
              size=10,
              force_overlay=true)



alertcondition(sig_long,
               "KNN MR: Reversion Long",
               "KNN Mean Reversion — price likely snapping back UP to MA. P >{prob_thresh}")

alertcondition(sig_short,
               "KNN MR: Reversion Short",
               "KNN Mean Reversion — price likely snapping back DOWN to MA. P >{prob_thresh}")

alertcondition(sig_long or sig_short,
               "KNN MR: Any Reversion Signal",
               "KNN Mean Reversion signal fired (long or short)")
````
