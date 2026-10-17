# KNN Market Regime Engine [Dots3Red]

- url: https://www.tradingview.com/script/3GDtJSMC-KNN-Market-Regime-Engine-Dots3Red/
- type: indicator
- pine_id: PUB;a69ca061df094b9dbc03320be7055438
- version: 2.0

## Description

█ [b]OVERVIEW[/b]
Most market regime tools work in a pretty simple way: we set a threshold and call it a day. ADX above 25? Trending. Below 20? Ranging.

But that threshold is basically just our assumption baked into code. It doesn’t adapt, it doesn’t learn, and it’s treated the same whether we’re looking at Bitcoin, EUR/USD, or any other market — even though they behave completely differently.

[b]This script takes a different approach[/b]. It uses a [b]K-Nearest Neighbors (KNN)[/b] [i]machine learning algorithm[/i] to estimate the probability that the current market is in one of three regimes: [b]Trending[/b], [b]Ranging[/b], or [b]Volatile Trend[/b]. Rather than comparing today's readings against a fixed number, it searches the past 700 bars for the moments that [i]looked most like right now[/i] - and asks what the market did after each of those moments. The result is a live probability for each regime, not a hard categorical label.

The output is three things simultaneously: 
[list]
[*]a background color telling you the dominant regime
[*]a dashboard showing live probability bars for all three states
[*]change markers appearing only when the classifier is genuinely confident a shift has occurred.
[/list]

█ [b]THE FOUR REGIMES[/b]
[b]🔵 TRENDING[/b]  —  price is moving directionally with efficiency. Momentum strategies belong here. Mean reversion strategies get punished here.
[b]🟣 RANGING[/b]  —  price is oscillating between levels with no net directional movement. Mean reversion strategies and fade-the-extreme setups have edge here. Trend-following generates whipsaws.
[b]🟡 VOLATILE TREND[/b]  —  price is trending [i]and[/i] ATR has expanded sharply beyond its baseline. This captures earnings gaps, macro shocks, and post-breakout expansion. It is a distinct fourth state — not simply "a strong trend." Reduce size or trail very tightly.
[b]⬛ UNCERTAIN[/b]  —  the dominant probability did not clear the minimum confidence threshold. The market's character is genuinely ambiguous. The best action is observation, not engagement.


█ [b]HOW IT WORKS — THE FULL PIPELINE[/b]
[b]Step 1 — Six features, measured every bar[/b]
Each bar is described by six measurements, each capturing a different dimension of market character:
•  [b]ADX[/b] — trend strength. Not direction — only how strongly price is committed to any direction.
•  [b]ATR ratio[/b] — current ATR divided by its own long-term average. Measures whether volatility is elevated or compressed relative to its own history.
•  [b]Choppiness Index[/b] — measures how much of the price movement was wasted going sideways. Near 100 = pure chop. Near 38 = perfectly directional.
•  [b]Bollinger Band width[/b] — how expanded or compressed the bands are relative to price. A compression often precedes volatile expansion.
•  [b]Normalized slope[/b] — linear regression slope over N bars, divided by ATR. A scale-free measure of directional momentum.
•  [b]Kaufman Efficiency Ratio[/b] — how directly did price move from A to B? If price traveled 100 points total but only net-moved 20, ER is 0.20. High ER = trending cleanly. Low ER = zigzagging.

[b]Step 2 — Z-score normalization[/b]
ADX runs 0–100. ATR ratio runs 0.5–3.0. BB width might be 0.01–0.08 on forex. Using raw values in a distance calculation means the largest-scale feature dominates by sheer magnitude. All six features are standardized: [i]z = (value − rolling mean) / rolling stdev[/i]. This puts every feature on equal footing — a reading of +2.0 means "[i]two standard deviations above normal[/i]" on any feature. Critically, the mean and stdev are computed on prior bars only ([b]src[1][/b] offset), which eliminates look-ahead bias from the normalization step.

[b]Step 3 — Labeling historical bars[/b]
For every historical bar, the script evaluates what happened over the following [i]Forward Bars[/i] window:
•  If the net price move exceeded [i]Trend Threshold × average ATR[/i] over the window → labeled TRENDING (1)
•  If the ATR ratio exceeded [i]Volatility Threshold[/i] → labeled VOLATILE TREND (3)
•  If trending AND volatile simultaneously → labeled VOLATILE TREND (3), because risk context takes priority
•  Otherwise → labeled RANGING (2)

This label is only ever read at an offset of at least [i]Forward Bars[/i] bars into the past, so the current bar carries no label — there is no look-ahead in the training data.

[b]Step 4 — KNN search and Gaussian-weighted voting[/b]
On each bar, the algorithm scans the historical window (default 700 bars) and computes the Minkowski distance between today's six Z-scored features and every historical bar's six features. The K nearest matches are selected. Closer neighbors receive exponentially higher voting weight via a [b]Gaussian kernel[/b]: [i]w = exp(−d² / 2σ²)[/i]. This means a bar at distance 0.1 vastly outweighs one at distance 0.5. The votes produce three probabilities — P(trending), P(ranging), P(volatile trend) — that always sum to 1.

[b]Step 5 — Three-stage noise filtering[/b]
A single KNN output can flicker bar to bar. Three filters eliminate this:
•  [b]Mode filter[/b] — selects the most common regime over the last [i]smooth_len[/i] bars. Removes 1-3 bar flickers entirely.
•  [b]Confirmation filter[/b] — the smoothed regime must hold steady for [i]confirm_bars[/i] consecutive bars before being accepted. Kills false starts.
•  [b]Signal gap[/b] — regime change markers only appear once per [i]signal_gap[/i] bars minimum, and only when the dominant probability exceeds 65%. This eliminates cluttered charts entirely.


█ [b]DESIGN DECISIONS — WHAT WAS INITIALLY, WHAT CHANGED AND WHY[/b]
[b]From 3 regimes to 4[/b]
The first idea used three regimes with a simple override: if volatility was high, VOLATILE replaced TRENDING regardless of whether price was actually moving directionally. Testing on stocks showed this caused problems — an earnings-day spike during a clear uptrend was collapsing the trend signal entirely. We realized volatile trending markets are [i]qualitatively different[/i] from volatile ranging markets. A fast trend during an OPEC announcement is not the same as a gap-down in a sideways consolidation. VOLATILE TREND became its own regime, and the distinction turned out to be the most practically useful change in the entire script.

[b]From stride = fwd_bars to stride = 3[/b]
The early idea for the script we had sampled the training window with a stride equal to [i]Forward Bars[/i] (30 by default). This gave roughly 23 training samples — barely enough for KNN to make a meaningful comparison. Reducing the stride to 3 gives approximately 230 samples. The regime classification became dramatically more stable and consistent, especially in quieter markets where the 23-sample version frequently returned UNCERTAIN. The trade-off is slightly more computation, which Pine handles comfortably within its limits.

[b]From a single volatile threshold to a combined trend + volatile check[/b]
Originally we labeled VOLATILE based purely on ATR ratio exceeding a threshold. This correctly flagged high-volatility periods but was labeling slow low-ATR trends as RANGING instead of TRENDING during prolonged low-volatility bull markets. The label logic was reworked to check directionality and volatility [i]independently[/i] and then combine them: a trending move is TRENDING unless ATR is also elevated, in which case it becomes VOLATILE TREND. This made the label logic honest about what the market was actually doing.

[b]The Efficiency Ratio addition[/b]
The original five features (ADX, ATR ratio, Choppiness, BB width, Slope) left a gap: two markets can have identical ADX and slope but very different directional efficiency — one moves in a clean staircase, the other zigzags the same distance. Kaufman's Efficiency Ratio fills this gap. ER = 0.85 on a bar means 85% of all price movement went in the net direction. ER = 0.20 means price was thrashing around and barely net-moved. It proved particularly valuable for distinguishing true trending from noisy ranging in crypto and high-beta stocks.

[b]The regime change marker clutter problem[/b]
Early testing produced charts covered in triangles, circles, and diamonds — a new marker on almost every regime flicker. Three parameters were added to solve this: the mode filter, the confirmation bars requirement, and the signal gap. Together they ensure a marker only appears when (a) the majority of recent bars agree on the new regime, (b) it has held for at least N bars, and (c) the KNN confidence is above 65%. The result is 2–6 meaningful markers per year on a daily chart rather than dozens of noisy ones.


█ [b]WHAT YOU SEE ON THE CHART[/b]
[list]
[*][b]Background color[/b]  —  the dominant confirmed regime, colored continuously. Cyan = Trending. Magenta = Ranging. Amber = Volatile Trend. No color = Uncertain.
[*][b]Bar coloring[/b]  —  individual bars colored by the same regime. Toggle off if you prefer your own candle coloring scheme.
[*][b]Regime change markers[/b]  —  small shapes at confirmed, high-confidence regime transitions only. ▲ below bar = shift to Trending. ● below bar = shift to Ranging. ◆ above bar = shift to Volatile Trend.
[*][b]Dashboard (top right)[/b]  —  shows the confirmed regime label, confidence percentage, three probability meters (▰▰▰▱▱▱ format), and six live feature readings. The bottom row shows [i]Raw → Smooth[/i] (e.g. "T → R") so you can see what the raw KNN output is before the filters process it — useful for understanding when the classifier is about to change state.
[/list]

█ [b]SETTINGS REFERENCE[/b]

[b]🧠 KNN Engine[/b]
•  [i]K Neighbors[/i] — how many historical bars vote. Lower = faster reaction, higher = more stable. Default 25.
•  [i]Lookback Window[/i] — how many bars to search for neighbors. Larger = more training data. Default 700.
•  [i]Minkowski p[/i] — distance exponent. 1 = Manhattan (robust to outliers), 2 = Euclidean (standard). Default 2.
•  [i]Gaussian bandwidth[/i] — how steeply neighbor weight falls with distance. Lower = only the closest neighbors matter. Default 1.5.
•  [i]Minimum confidence[/i] — probability threshold below which the regime shows as UNCERTAIN. Default 0.45.

[b]🏷️ Labeling[/b]
•  [i]Forward bars[/i] — how many bars ahead define a historical bar's regime label. Match your typical hold time. Default 30.
•  [i]Trend threshold[/i] — net move must exceed this × avg ATR to label TRENDING. Lower = more bars labeled trending. Default 1.2.
•  [i]Volatility threshold[/i] — ATR ratio must exceed this to label VOLATILE TREND. Higher = only extreme events qualify. Default 1.5.

[b]📐 Features[/b]
•  [i]ADX Length[/i] — period for the directional movement index. Longer = smoother. Default 20.
•  [i]ATR Length[/i] — period for average true range. Default 14.
•  [i]ATR Baseline[/i] — SMA period for the ATR ratio denominator. Longer = more stable baseline. Default 100.
•  [i]Choppiness / BB / Slope lengths[/i] — feature calculation periods. All default to 20–30.
•  [i]Efficiency Ratio Length[/i] — Kaufman ER lookback. Default 30.

[b]🧹 Filtering[/b]
•  [i]Regime Smoothing Lookback[/i] — mode filter window. Higher = fewer false regime changes. Default 11.
•  [i]Bars to confirm regime[/i] — consecutive bars required before a new regime is accepted. Default 4.
•  [i]Min bars between signals[/i] — minimum spacing between regime change markers. Default 20.

█ [b]SETTINGS BY ASSET CLASS[/b]
[b]📈 Large-cap stocks — daily (AMZN, AAPL, NVDA)[/b]
Stocks trend slowly over weeks to months, with sharp one-day volatility spikes on earnings. All feature lengths should be longer to resolve the slower regime pace.
•  Forward bars: 20–30  |  Trend threshold: 0.8–1.2  |  Volatility threshold: 2.0–2.5
•  ATR Baseline: 100  |  ADX / Chop / Slope lengths: 20  |  BB length: 30  |  EffR: 30
•  Smoothing: 11  |  Confirm bars: 4–5  |  Signal gap: 20
•  Note: use 0.8 trend threshold for slow defensive stocks (JNJ, KO), 1.2 for high-beta tech (NVDA, TSLA)

[b]₿ Crypto — daily (BTC, ETH, large caps)[/b]
Crypto regimes flip in days, not months. ATR is 3–7× higher than stocks. Shorter windows, lower thresholds, less smoothing.
•  Forward bars: 10–14  |  Trend threshold: 1.5–2.5  |  Volatility threshold: 1.5–2.0
•  ATR Baseline: 50–70  |  All feature lengths: 14  |  EffR: 14–20
•  Smoothing: 5–7  |  Confirm bars: 2–3  |  Signal gap: 7–10
•  Note: for altcoins use trend threshold 2.0–2.5; for BTC use 1.5–2.0

[b]💱 Forex — daily (EUR/USD, GBP/USD, USD/JPY)[/b]
Forex trends are driven by central bank divergence and last months. Daily ATR is tiny (0.4–0.7% of price). Everything needs to be longer and slower.
•  Forward bars: 30–45  |  Trend threshold: 0.6–0.8  |  Volatility threshold: 2.5–3.0
•  ATR Baseline: 120–150  |  ADX length: 20–25  |  Slope / EffR: 40–50
•  Smoothing: 15–21  |  Confirm bars: 5–7  |  Signal gap: 30–45
•  Note: exotic pairs (USD/TRY, USD/ZAR) behave like crypto — use crypto settings instead

[b]🛢️ Commodities — daily (Gold XAU, Oil WTI)[/b]
Gold is slow and stable like equities. Oil is fast and event-driven like crypto. Use different profiles.
•  Gold: Forward bars 20, Trend 0.8, Vol 2.5, ATR Base 100, Smooth 11, Confirm 4, Gap 20
•  Oil: Forward bars 15, Trend 1.2, Vol 2.0, ATR Base 70, Smooth 7, Confirm 2–3, Gap 10
•  Note: OPEC events and geopolitical shocks will correctly fire VOLATILE TREND on oil — this is intended behavior

[b]🌐 Indices — daily (SPX, NDX, DAX)[/b]
Indices are the most regime-stable asset class. They trend 65–75% of the time and have the cleanest feature signals of any asset.
•  Forward bars: 20–30  |  Trend threshold: 0.8–1.0  |  Volatility threshold: 2.0–2.5
•  ATR Baseline: 120  |  ADX length: 20  |  Smoothing: 11–15  |  Confirm bars: 4–5  |  Signal gap: 20–30
•  Note: NDX is ~30% more volatile than SPX — use trend threshold 1.0 for NDX, 0.8 for SPX

[b]EXAMPLE[/b]
[image]https://www.tradingview.com/x/moEBpxaS/[/image]

█ [b]HOW TO USE WITH OTHER INDICATORS[/b]
This script does not generate buy or sell signals. It tells you [i]which type of strategy has edge right now[/i]. The intended workflow:
1 — Add your momentum or mean reversion indicator alongside this one.
2 — Only take momentum / trend-following entries when the background is [b]cyan (TRENDING)[/b].
3 — Only take mean reversion / fade entries when the background is [b]magenta (RANGING)[/b].
4 — Reduce position size or step aside entirely when the background is [b]amber (VOLATILE TREND)[/b].
5 — Do nothing when there is no background color — the regime is UNCERTAIN.

Used this way, the classifier acts as a strategy [i]mode selector[/i] rather than a signal generator. It is the foundation of a multi-strategy system where the same chart hosts different logic depending on detected conditions.


█ [b]LIMITATIONS[/b]
•  KNN is a lazy learner — it reflects patterns in its training window. If the current market regime has no historical analog in the lookback window (e.g. a once-in-a-decade crash), the classifier will misclassify or return UNCERTAIN.
•  The script requires a warm-up period equal to [i]Lookback Window + Forward Bars[/i] bars before producing output. On instruments with limited history this may delay the first valid reading.
•  Computation scales with window size and stride. Very large windows (2000+) may slow chart rendering on lower-end machines.
•  The reversion probability reflects historical frequency, not a guarantee of future behavior. All market regimes can and do fail.

[b]Human vs Machine[/b]🧠vs 🤖
And most importantly, checking the chart with the [b]HUMAN EYE[/b] is different from using the raw ML KNN method - something we agreed on checking the charts, as we, traders-developers, had different opinions of the market regime for an asset price. But the Script might yield results we can all agree upon. 


█ [b]DISCLAIMER[/b]
This indicator is a decision-support tool, not a trading system. It does not constitute financial advice. Past regime patterns do not guarantee future behavior. Always apply proper risk management.

Algorithm: K-Nearest Neighbors (KNN)
Distance metric: Minkowski Distance (p=2, Euclidean default)
Kernel: Gaussian (distance-weighted voting)
Normalization: Z-Score (look-ahead free)
Regimes: Trending | Ranging | Volatile Trend | Uncertain

## Source Code

````pine
//──────────────────────────────────────────────────────────────────────
//  KNN Market Regime Engine [Dots3Red]
//  Probabilistic market regime classification using KNN similarity analysis
//
//  © Dots3Red
//  TradingView: https://www.tradingview.com/u/Dots3Red/
//
//  This source code is subject to the terms of the Mozilla Public License 2.0
//  https://mozilla.org/MPL/2.0/
//──────────────────────────────────────────────────────────────────────

//@version=6
indicator("KNN Machine Learning Market Regime Engine [Dots3Red]", overlay=true, max_bars_back=5000, max_labels_count=50, max_lines_count=50, max_boxes_count=10)


C_TREND    = color.new(#00f0ff, 0)
C_RANGE    = color.new(#ff00aa, 0)
C_VOLTREND = color.new(#ffb700, 0)
C_NEUTRAL  = color.new(#475569, 0)

C_TREND_BG    = color.new(#00f0ff, 82)
C_RANGE_BG    = color.new(#ff00aa, 82)
C_VOLTREND_BG = color.new(#ffb700, 82)

C_TXT  = color.new(#f8fafc, 0)
C_DIM  = color.new(#94a3b8, 0)
C_BORD = color.new(#334155, 0)

// ─────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────
GRP_KNN  = "🧠 KNN Engine"
GRP_LAB  = "🏷️ Labeling"
GRP_FEAT = "📐 Features"
GRP_FILT = "🧹 Filtering"
GRP_VIS  = "🎨 Visuals"

k_val        = input.int   (25,   "K Neighbors",              minval=5,   maxval=200,  group=GRP_KNN,
               tooltip="Number of nearest historical bars that vote on the current regime.")
win_size     = input.int   (700,  "Lookback Window",          minval=200, maxval=3000, group=GRP_KNN,
               tooltip="How many historical bars to search for nearest neighbors.")
p_dist       = input.float (2.0,  "Minkowski p",              minval=1.0, maxval=4.0,  step=0.5, group=GRP_KNN,
               tooltip="Distance exponent. 1=Manhattan, 2=Euclidean.")
gauss_bw     = input.float (1.5,  "Gaussian bandwidth",       minval=0.5, maxval=5.0,  step=0.1, group=GRP_KNN,
               tooltip="Controls how fast neighbor weight decays with distance.")
prob_min     = input.float (0.45, "Minimum confidence",       minval=0.2, maxval=0.9,  step=0.05, group=GRP_KNN,
               tooltip="Dominant regime shown only when its probability clears this level.")

fwd_bars     = input.int   (30,   "Forward bars (Macro Cycle)",minval=5,  maxval=60,   group=GRP_LAB,
               tooltip="How many bars ahead define the regime label for each historical bar. Match your typical trade hold time.")
trend_mult   = input.float (1.2,  "Trend threshold",          minval=0.2, maxval=3.0,  step=0.1, group=GRP_LAB,
               tooltip="Net move must exceed this × avg ATR over the forward window to label TRENDING.")
vol_mult     = input.float (1.1,  "Volatility threshold",     minval=1.0, maxval=5.0,  step=0.1, group=GRP_LAB,
               tooltip="ATR ratio must exceed this for the VOLATILE TREND label.")

adx_len      = input.int   (20,   "ADX Length",               minval=5,   group=GRP_FEAT)
atr_len      = input.int   (14,   "ATR Length",               minval=5,   group=GRP_FEAT)
atr_base_len = input.int   (100,  "ATR Baseline Period",      minval=10,  group=GRP_FEAT,
               tooltip="ATR is compared to its own SMA over this period.")
chop_len     = input.int   (20,   "Choppiness Length",        minval=5,   group=GRP_FEAT)
bb_len       = input.int   (30,   "BB Width Length",          minval=5,   group=GRP_FEAT)
slope_len    = input.int   (20,   "Slope Length",             minval=3,   group=GRP_FEAT)
eff_len      = input.int   (30,   "Efficiency Ratio Length",  minval=5,   group=GRP_FEAT,
               tooltip="Kaufman Efficiency Ratio: how directionally efficient price movement was.")

smooth_len   = input.int   (11,   "Regime Smoothing Lookback",minval=1,   maxval=31,   group=GRP_FILT,
               tooltip="Mode filter window — picks the most common regime over this many bars.")
confirm_bars = input.int   (4,    "Bars to confirm regime",   minval=1,   maxval=10,   group=GRP_FILT,
               tooltip="Regime must hold steady for this many bars before being confirmed.")
signal_gap   = input.int   (20,   "Min bars between signals", minval=1,   maxval=100,  group=GRP_FILT,
               tooltip="Prevents signal markers from firing too frequently.")

show_bg      = input.bool  (false, "Background shading",       group=GRP_VIS)
show_barclr  = input.bool  (true, "Bar coloring",             group=GRP_VIS)
show_shapes  = input.bool  (true, "Regime change markers",    group=GRP_VIS)
show_dash    = input.bool  (true, "Dashboard",                group=GRP_VIS)
dash_pos     = input.string("Top Right", "Dashboard position",
               options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_VIS)

// ─────────────────────────────────────────────────────────────────────
// BASE SERIES
// ─────────────────────────────────────────────────────────────────────
atr_raw    = ta.atr(atr_len)
atr_base   = ta.sma(atr_raw, atr_base_len)
atr_ratio  = atr_raw / math.max(atr_base, 1e-9)

[_dmp, _dmn, adx_val] = ta.dmi(adx_len, adx_len)

tr_sum   = math.sum(ta.tr(true), chop_len)
hi_max   = ta.highest(high, chop_len)
lo_min   = ta.lowest(low,  chop_len)
chop_raw = 100.0 * math.log10(tr_sum / math.max(hi_max - lo_min, 1e-9)) / math.log10(chop_len)

bb_basis = ta.sma(close, bb_len)
bb_std   = ta.stdev(close, bb_len)
bb_width = (4.0 * bb_std) / math.max(bb_basis, 1e-9)

lr_now   = ta.linreg(close, slope_len, 0)
lr_prev  = ta.linreg(close, slope_len, 1)
lr_slope = math.abs(lr_now - lr_prev) / math.max(atr_raw, 1e-9)

// Kaufman Efficiency Ratio — directional efficiency of price movement
er_direction  = math.abs(close - close[eff_len])
er_volatility = math.sum(math.abs(close - close[1]), eff_len)
eff_ratio     = er_direction / math.max(er_volatility, 1e-9)

// ─────────────────────────────────────────────────────────────────────
// Z-SCORE NORMALIZATION (look-ahead free — [1] offset on mean/stdev)
// ─────────────────────────────────────────────────────────────────────
f_z(src, len) =>
    mu = ta.sma(src[1], len)
    sd = ta.stdev(src[1], len)
    (src - mu) / math.max(sd, 1e-9)

z1 = f_z(adx_val,  win_size)
z2 = f_z(atr_ratio,win_size)
z3 = f_z(chop_raw, win_size)
z4 = f_z(bb_width, win_size)
z5 = f_z(lr_slope, win_size)
z6 = f_z(eff_ratio,win_size)

// Net move normalized by average ATR over the forward window
net_move = math.abs(close - close[fwd_bars]) / math.max(ta.sma(atr_raw, fwd_bars), 1e-9)

is_trend = net_move   > trend_mult
is_vol   = atr_ratio  > vol_mult

// Volatile trend = trending move accompanied by ATR spike (e.g. earnings, macro event)
// Risk-first priority: ties broken toward volatile trend (see mode filter below)
label_series = is_trend and is_vol ? 3 : is_trend ? 1 : 2

// ─────────────────────────────────────────────────────────────────────
// KNN ENGINE
// ─────────────────────────────────────────────────────────────────────
var float p_trend    = 0.0
var float p_range    = 0.0
var float p_voltrend = 0.0

var float[] dist_arr  = array.new_float()
var float[] label_arr = array.new_float()

if bar_index > win_size + fwd_bars
    array.clear(dist_arr)
    array.clear(label_arr)

    // Stride = 3 → dense sample set (~233 samples vs ~23 with stride=fwd_bars)
    for i = fwd_bars to win_size + fwd_bars by 3
        float d = math.pow(
              math.pow(math.abs(z1 - z1[i]), p_dist)
            + math.pow(math.abs(z2 - z2[i]), p_dist)
            + math.pow(math.abs(z3 - z3[i]), p_dist)
            + math.pow(math.abs(z4 - z4[i]), p_dist)
            + math.pow(math.abs(z5 - z5[i]), p_dist)
            + math.pow(math.abs(z6 - z6[i]), p_dist),
            1.0 / p_dist)
        array.push(dist_arr,  d)
        array.push(label_arr, label_series[i])

    int n = array.size(dist_arr)

    if n >= k_val
        int[] sorted_idx = array.sort_indices(dist_arr, order.ascending)

        // Sigma = distance of median-K neighbor (Gaussian kernel scale)
        int   med_pos = math.min(math.max(1, int(k_val / 2)), n - 1)
        int   med_idx = array.get(sorted_idx, med_pos)
        float sigma   = math.max(array.get(dist_arr, med_idx), 1e-9)

        float wt = 0.0, float wr = 0.0, float wv = 0.0, float total = 0.0

        for j = 0 to k_val - 1
            int   idx = array.get(sorted_idx, j)
            float d   = array.get(dist_arr,  idx)
            float lbl = array.get(label_arr, idx)
            float w   = math.exp(-math.pow(d, gauss_bw) / (2.0 * sigma * sigma))

            if   lbl == 3
                wv += w
            else if lbl == 1
                wt += w
            else
                wr += w
            total += w

        if total > 0
            p_trend    := wt / total
            p_range    := wr / total
            p_voltrend := wv / total

// ─────────────────────────────────────────────────────────────────────
// RAW REGIME (pre-smoothing)
// ─────────────────────────────────────────────────────────────────────
raw_regime = p_voltrend > p_trend and p_voltrend > p_range and p_voltrend > prob_min ? 3 :
             p_trend    > p_range and p_trend    > prob_min                          ? 1 :
             p_range    > prob_min                                                   ? 2 : 0

// ─────────────────────────────────────────────────────────────────────
// MODE FILTER (majority vote over smooth_len bars)
// Ties broken in priority order: volatile trend > trending > ranging > uncertain
// This is intentional risk-first behavior, not a side-effect.
// ─────────────────────────────────────────────────────────────────────
f_mode(src, len) =>
    int c0 = 0, int c1 = 0, int c2 = 0, int c3 = 0
    for k = 0 to len - 1
        v = src[k]
        if   v == 0
            c0 += 1
        else if v == 1
            c1 += 1
        else if v == 2
            c2 += 1
        else
            c3 += 1
    // Risk-first tie-breaking: 3 > 1 > 2 > 0
    mx = math.max(c0, c1, c2, c3)
    mx == c3 ? 3 : mx == c1 ? 1 : mx == c2 ? 2 : 0

smooth_regime = f_mode(raw_regime, smooth_len)


bars_same       = ta.barssince(smooth_regime != smooth_regime[1])
confirmed_regime = bars_same >= confirm_bars ? smooth_regime : nz(smooth_regime[1])


var int prev_regime  = -1   // -1 = uninitialized sentinel (not a valid regime)
var int last_signal  = na

bool reg_changed = false
bool major_change = false

if confirmed_regime != -1   
    if prev_regime == -1
        prev_regime := confirmed_regime   
    else
        reg_changed  := confirmed_regime != prev_regime
        bool can_signal = na(last_signal) or (bar_index - last_signal > signal_gap)
        major_change := reg_changed and can_signal and math.max(p_trend, p_range, p_voltrend) > 0.65
        if major_change
            prev_regime := confirmed_regime
            last_signal := bar_index


reg_col = confirmed_regime == 1 ? C_TREND    :
          confirmed_regime == 2 ? C_RANGE    :
          confirmed_regime == 3 ? C_VOLTREND : C_NEUTRAL

reg_label = confirmed_regime == 1 ? "TRENDING"       :
             confirmed_regime == 2 ? "RANGING"        :
             confirmed_regime == 3 ? "VOLATILE TREND" : "UNCERTAIN"


bgcolor(show_bg and confirmed_regime == 1 ? C_TREND_BG    : na)
bgcolor(show_bg and confirmed_regime == 2 ? C_RANGE_BG    : na)
bgcolor(show_bg and confirmed_regime == 3 ? C_VOLTREND_BG : na)

barcolor(show_barclr and confirmed_regime != 0 ? reg_col : na)

plotshape(show_shapes and major_change and confirmed_regime == 1,
          "→ Trending",      shape.triangleup,   location.belowbar, C_TREND,    size=size.tiny)
plotshape(show_shapes and major_change and confirmed_regime == 2,
          "→ Ranging",       shape.circle,       location.belowbar, C_RANGE,    size=size.tiny)
plotshape(show_shapes and major_change and confirmed_regime == 3,
          "→ Volatile Trend",shape.diamond,      location.abovebar, C_VOLTREND, size=size.tiny)


prob_bar(p) =>
    n = math.round(p * 10)
    str.repeat("▰", math.max(0, n)) + str.repeat("▱", math.max(0, 10 - n))

if show_dash and barstate.islast
    tp = switch dash_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

    var table t = table.new(tp, 2, 11,
                  bgcolor      = color.new(#0f172a, 10),
                  border_color = C_BORD, border_width = 2,
                  frame_color  = C_BORD, frame_width  = 2)

    table.cell(t, 0, 0, "KNN REGIME CLASSIFIER",
               text_color=C_TXT, bgcolor=color.new(#1e293b, 0),
               text_size=10, text_halign=text.align_center)
    table.merge_cells(t, 0, 0, 1, 0)

    table.cell(t, 0, 1, "Regime",
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 1, reg_label,
               text_color=reg_col, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_center)

    table.cell(t, 0, 2, "Confidence",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 2, str.tostring(math.round(math.max(p_trend, p_range, p_voltrend) * 100)) + "%",
               text_color=reg_col, bgcolor=color.new(#0f172a, 20),
               text_size=10, text_halign=text.align_center)

    table.cell(t, 0, 3, "Trending",
               text_color=C_TREND, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 3, prob_bar(p_trend) + " " + str.tostring(math.round(p_trend * 100)) + "%",
               text_color=C_TREND, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)

    table.cell(t, 0, 4, "Ranging",
               text_color=C_RANGE, bgcolor=color.new(#0f172a, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 4, prob_bar(p_range) + " " + str.tostring(math.round(p_range * 100)) + "%",
               text_color=C_RANGE, bgcolor=color.new(#0f172a, 20),
               text_size=10, text_halign=text.align_left)

    table.cell(t, 0, 5, "Vol Trend",
               text_color=C_VOLTREND, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 5, prob_bar(p_voltrend) + " " + str.tostring(math.round(p_voltrend * 100)) + "%",
               text_color=C_VOLTREND, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)

    table.cell(t, 0, 6, "─── Live Features ───",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 0),
               text_size=10, text_halign=text.align_center)
    table.merge_cells(t, 0, 6, 1, 6)

    table.cell(t, 0, 7, "ADX  " + str.tostring(math.round(adx_val, 1)),
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 7, "ATR×  " + str.tostring(math.round(atr_ratio, 2)),
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)

    table.cell(t, 0, 8, "Chop  " + str.tostring(math.round(chop_raw, 1)),
               text_color=C_DIM, bgcolor=color.new(#0f172a, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 8, "BB%  " + str.tostring(math.round(bb_width * 100, 1)),
               text_color=C_DIM, bgcolor=color.new(#0f172a, 20),
               text_size=10, text_halign=text.align_left)

    table.cell(t, 0, 9, "Slope  " + str.tostring(math.round(lr_slope, 3)),
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 9, "EffR  " + str.tostring(math.round(eff_ratio, 2)),
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=10, text_halign=text.align_left)

    table.cell(t, 0, 10, "Raw → Smooth",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 20),
               text_size=10, text_halign=text.align_left)
    table.cell(t, 1, 10,
               (raw_regime == 1 ? "T" : raw_regime == 2 ? "R" : raw_regime == 3 ? "VT" : "?") +
               " → " +
               (confirmed_regime == 1 ? "T" : confirmed_regime == 2 ? "R" : confirmed_regime == 3 ? "VT" : "?"),
               text_color=reg_col, bgcolor=color.new(#0f172a, 20),
               text_size=10, text_halign=text.align_left)


alertcondition(major_change and confirmed_regime == 1, "KNN → Trending",      "KNN Regime: market shifted to TRENDING")
alertcondition(major_change and confirmed_regime == 2, "KNN → Ranging",       "KNN Regime: market shifted to RANGING")
alertcondition(major_change and confirmed_regime == 3, "KNN → Volatile Trend","KNN Regime: market shifted to VOLATILE TREND")
alertcondition(major_change,                           "KNN → Any change",    "KNN Regime: regime change detected")
````
