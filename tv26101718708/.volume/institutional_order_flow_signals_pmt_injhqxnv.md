# Institutional Order Flow Signals [PMT]

- url: https://www.tradingview.com/script/inJHQXNV-Institutional-Order-Flow-Signals-PMT/
- type: indicator
- pine_id: PUB;e7a3c0b4b8674b589f746c4b0848d015
- version: 1.0

## Description

[b]Institutional Order Flow Signals[/b] applies a Gaussian Naive Bayes classifier — trained entirely within Pine Script® v6 — to cumulative volume delta divergence in order to surface, in real time, three mutually exclusive market regime states: bullish re-alignment, bearish re-alignment, and order flow divergence.

The core question this indicator addresses is distinct from threshold-crossover approaches: given the current statistical pattern of delta momentum, price/CVD divergence, and delta slope, what is the posterior probability that the market is entering — or exiting — a directional institutional order flow regime?

――――――――――――――――――――――――――――――――――――――

🔷 [b]WHAT IT MEASURES[/b]

🔸 [b]Cumulative Volume Delta (CVD)[/b]

CVD is the running sum of intrabar net order flow — buy volume minus sell volume — estimated via the close-position formula: bull_vol = volume × (close − low) / (high − low). The cumulative series tracks persistent institutional buying or selling pressure independently of price direction, making it a first-order proxy for directional order flow without requiring exchange-level bid/ask data.

🔸 [b]Three Z-Score Normalised Features[/b]

Each bar, the classifier receives three inputs derived from CVD and z-score normalised for cross-instrument compatibility:

[b]F1 — CVD Momentum[/b]: rate of change of CVD over N bars, normalised by its rolling mean and standard deviation. Encodes how rapidly buying or selling pressure is accelerating relative to its own recent baseline.

[b]F2 — Price/CVD Divergence[/b]: price rate of change minus CVD rate of change. A large positive value signals price rising while order flow is falling — the classic institutional distribution pattern. Near-zero values indicate price and flow agreement.

[b]F3 — CVD Slope[/b]: linear regression slope of CVD over a short window, z-score normalised. Provides a direction-of-flow signal independent of F1's momentum measure, satisfying the Naive Bayes conditional independence assumption as closely as CVD-derived features can.

🔸 [b]Market Regime Labels[/b]

Three mutually exclusive regimes are recognised. A [b]bullish re-alignment[/b] bar is one where both price ROC and CVD ROC are positive — institutional flow and price confirm each other to the upside. A [b]bearish re-alignment[/b] bar is the symmetric case. A [b]divergence[/b] bar occurs when price and order flow point in opposite directions — historically associated with regime transitions and distribution/accumulation activity.

――――――――――――――――――――――――――――――――――――――

🔷 [b]THE CLASSIFIER[/b]

🔸 [b]Welford Online Learning[/b]

The classifier accumulates running sufficient statistics — count, mean, and variance — for each of the nine (feature × regime) combinations using Welford's numerically stable online update. No historical arrays are stored. The model's parameters shift gradually with each new bar, making it adaptive to changing market microstructure conditions without a fixed lookback window.

🔸 [b]Gaussian Likelihood + Bayesian Posterior[/b]

Each feature is modelled as a Gaussian distribution under each class. The joint likelihood of the current feature vector is computed by multiplying the three per-feature probability densities under the Naive Bayes independence assumption. A class prior — updated empirically from observed regime frequencies — is combined with the joint likelihood via Bayes' theorem to produce posterior probabilities P(Bull | F1,F2,F3) and P(Bear | F1,F2,F3) for the current bar. A warmup gate suppresses signals until the classifier has accumulated statistically meaningful training observations.

――――――――――――――――――――――――――――――――――――――

🔷 [b]SIGNALS AND DISPLAY[/b]

🔸 [b]High-Conviction Buy — P(Bull) > 85%[/b]

A long signal fires when the bull posterior clears the configurable threshold, CVD momentum confirms, and price is above the trend EMA. The threshold is surfaced on the label itself, making the confidence level explicit at every entry rather than hidden inside an opaque signal.

🔸 [b]Bear Signal — CVD Divergence[/b]

A short signal fires when the bear posterior clears threshold and F2 is in active divergence territory — price moving up while order flow is declining, or the symmetric distribution case. CVD divergence without posterior confirmation does not produce a signal; both conditions are required simultaneously.

🔸 [b]Bull Regime Band — CVD Aligned[/b]

A fill band anchored to the trend EMA expands when the classifier assigns high posterior probability to a sustained bullish re-alignment regime. The opacity of the band scales with the posterior — faint during low-confidence periods, saturated when the classifier considers the regime firmly established.

🔸 [b]Info Table[/b]

Live readout displays current bull and bear posteriors, CVD direction, and training bar count. The Trained N counter confirms the classifier has completed warmup before acting on any signal.

――――――――――――――――――――――――――――――――――――――

🔷 [b]INPUTS[/b]

[b]Classifier Lookback[/b] — minimum training bars before signals activate. Default 100.
[b]Entry Posterior Threshold[/b] — minimum posterior required. 0.60 permissive; 0.70 default; 0.80 high-conviction only.
[b]CVD Momentum Period[/b] — lookback for F1 and F2 rate of change.
[b]CVD Slope Period[/b] — regression window for F3.
[b]Z-Score Period[/b] — normalisation window applied across all three features.
[b]Trend EMA Period[/b] — macro filter; long signals only fire above EMA, short signals below.

――――――――――――――――――――――――――――――――――――――

🔷 [b]REQUIREMENTS AND LIMITATIONS[/b]

The classifier requires a warmup period before signals are valid. The CVD estimator is synthetic — derived from intrabar price position, not actual bid/ask data — and introduces noise on instruments with low liquidity or wide spreads. The Naive Bayes independence assumption is partially violated because all three features are CVD-derived; the posteriors function as relative confidence scores rather than calibrated frequentist probabilities.

――――――――――――――――――――――――――――――――――――――

[i]Built natively in Pine Script® v6. No external libraries, no data feeds, no fixed lookback arrays. The Gaussian Naive Bayes classifier trains continuously from the chart's own bar history using Welford's online algorithm. Open source — Mozilla Public License 2.0.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © PickMyTrade — Institutional Order Flow Signals [PMT]: Probabilistic Volume Delta Classifier

//@version=6
indicator(
    title            = "Institutional Order Flow Signals [PMT]",
    shorttitle       = "IOF Signals",
    overlay          = true,
    max_labels_count = 50,
    max_lines_count  = 50
)

var string G_BAYES = "Naive Bayes Classifier"
var string G_CVD   = "CVD Settings"
var string G_VIS   = "Visual"
var string G_ZEN   = "Zen / Display"
var string G_RISK  = "Signal Levels"

nb_lookback      = input.int  (100,  "Classifier Lookback",        minval=30,   maxval=500,  group=G_BAYES,
                   tooltip="Bars used to train the classifier. More bars = more stable estimates, slower to adapt to regime shifts.")
posterior_thresh = input.float(0.70, "Entry Threshold",            minval=0.51, maxval=0.95, step=0.01, group=G_BAYES,
                   tooltip="Minimum posterior probability to show a signal. 0.65 = more signals  |  0.80 = high conviction only.")
prior_bull       = input.float(0.50, "Prior Bull Probability",     minval=0.10, maxval=0.90, step=0.01, group=G_BAYES,
                   tooltip="Starting belief about market direction before any data. 0.50 = neutral.")

cvd_period     = input.int(14, "CVD Momentum Period",  minval=3,  maxval=100, group=G_CVD,
                 tooltip="Look-back period for CVD rate of change (Feature F1).")
cvd_slope_len  = input.int(10, "CVD Slope Period",     minval=3,  maxval=50,  group=G_CVD,
                 tooltip="Linear regression window for CVD slope (Feature F3).")
cvd_zscore_len = input.int(50, "Z-Score Window",       minval=10, maxval=200, group=G_CVD,
                 tooltip="Normalisation window for all three features.")

show_levels  = input.bool (true,  "Show SL / TP Lines",   group=G_RISK)
sl_atr_mult  = input.float(1.5,   "SL ATR Multiplier",    minval=0.5,  maxval=5.0,  step=0.1, group=G_RISK, active=show_levels)
rr_ratio     = input.float(2.0,   "Risk : Reward",        minval=0.5,  maxval=10.0, step=0.1, group=G_RISK, active=show_levels)
atr_period   = input.int  (14,    "ATR Period",           minval=5,    maxval=50,             group=G_RISK)
ema_period   = input.int  (50,    "Trend EMA Period",     minval=5,    maxval=500,            group=G_RISK,
                 tooltip="Longs only above this EMA, shorts only below.")

show_band    = input.bool (true,  "Posterior Band",       group=G_VIS)
show_bg      = input.bool (true,  "Regime Background",    group=G_VIS)
bull_col     = input.color(color.new(#2962FF, 0), "Bull Colour", group=G_VIS)
bear_col     = input.color(color.new(#FF6D00, 0), "Bear Colour", group=G_VIS)

zen_mode     = input.bool(false, "Zen Mode  (hide all text)",  group=G_ZEN,
                 tooltip="Hides all text labels. Only shapes and bands remain — ideal for screenshots and live use.")
show_table   = input.bool(true,  "Show Info Table",             group=G_ZEN)

// ── CVD ───────────────────────────────────────────────────────────────────────
hl_range   = high - low + syminfo.mintick
bull_vol   = volume * (close - low)  / hl_range
bear_vol   = volume * (high - close) / hl_range
delta_bar  = bull_vol - bear_vol
var float cvd = 0.0
cvd := cvd + delta_bar

// ── FEATURES ──────────────────────────────────────────────────────────────────
cvd_roc      = (cvd - cvd[cvd_period]) / (math.abs(cvd[cvd_period]) + syminfo.mintick)
cvd_roc_mean = ta.sma  (cvd_roc, cvd_zscore_len)
cvd_roc_std  = ta.stdev(cvd_roc, cvd_zscore_len)
f1           = cvd_roc_std > 0 ? (cvd_roc - cvd_roc_mean) / cvd_roc_std : 0.0

price_roc    = (close - close[cvd_period]) / (close[cvd_period] + syminfo.mintick)
f2_raw       = price_roc - cvd_roc
f2_mean      = ta.sma  (f2_raw, cvd_zscore_len)
f2_std       = ta.stdev(f2_raw, cvd_zscore_len)
f2           = f2_std > 0 ? (f2_raw - f2_mean) / f2_std : 0.0

cvd_slope_raw = ta.linreg(cvd, cvd_slope_len, 0) - ta.linreg(cvd, cvd_slope_len, 1)
f3_mean       = ta.sma  (cvd_slope_raw, cvd_zscore_len)
f3_std        = ta.stdev(cvd_slope_raw, cvd_zscore_len)
f3            = f3_std > 0 ? (cvd_slope_raw - f3_mean) / f3_std : 0.0

// ── NAIVE BAYES TRAINING ──────────────────────────────────────────────────────
label_bull = price_roc > 0 and cvd_roc > 0
label_bear = price_roc < 0 and cvd_roc < 0
label_div  = not label_bull and not label_bear

gauss_pdf(float x, float mu, float sigma) =>
    s = math.max(sigma, 0.0001)
    math.exp(-0.5 * math.pow((x - mu) / s, 2)) / (s * math.sqrt(2 * math.pi))

var array<float> nb_n  = array.new_float(3, 0.0)
var array<float> s1    = array.new_float(3, 0.0)
var array<float> s2    = array.new_float(3, 0.0)
var array<float> s3    = array.new_float(3, 0.0)
var array<float> s1sq  = array.new_float(3, 0.0)
var array<float> s2sq  = array.new_float(3, 0.0)
var array<float> s3sq  = array.new_float(3, 0.0)

upd(int c, float a, float b, float d) =>
    n = array.get(nb_n, c) + 1
    array.set(nb_n,  c, n)
    array.set(s1,    c, array.get(s1,   c) + a)
    array.set(s2,    c, array.get(s2,   c) + b)
    array.set(s3,    c, array.get(s3,   c) + d)
    array.set(s1sq,  c, array.get(s1sq, c) + a * a)
    array.set(s2sq,  c, array.get(s2sq, c) + b * b)
    array.set(s3sq,  c, array.get(s3sq, c) + d * d)

if bar_index >= cvd_zscore_len + cvd_period + 2
    if label_bull[1]
        upd(0, f1[1], f2[1], f3[1])
    else if label_bear[1]
        upd(1, f1[1], f2[1], f3[1])
    else
        upd(2, f1[1], f2[1], f3[1])

gmean(int c, array<float> arr) =>
    n = array.get(nb_n, c)
    n > 0 ? array.get(arr, c) / n : 0.0

gstd(int c, array<float> arr, array<float> arrsq) =>
    n = array.get(nb_n, c)
    if n < 2
        1.0
    else
        m = array.get(arr, c) / n
        math.sqrt(math.max(array.get(arrsq, c) / n - m * m, 0.0001))

// Class statistics — Bull
mu1b = gmean(0, s1)
sd1b = gstd(0, s1, s1sq)
mu2b = gmean(0, s2)
sd2b = gstd(0, s2, s2sq)
mu3b = gmean(0, s3)
sd3b = gstd(0, s3, s3sq)

// Class statistics — Bear
mu1s = gmean(1, s1)
sd1s = gstd(1, s1, s1sq)
mu2s = gmean(1, s2)
sd2s = gstd(1, s2, s2sq)
mu3s = gmean(1, s3)
sd3s = gstd(1, s3, s3sq)

// Class statistics — Diverged
mu1d = gmean(2, s1)
sd1d = gstd(2, s1, s1sq)
mu2d = gmean(2, s2)
sd2d = gstd(2, s2, s2sq)
mu3d = gmean(2, s3)
sd3d = gstd(2, s3, s3sq)

// ── POSTERIOR ─────────────────────────────────────────────────────────────────
total_n = array.get(nb_n, 0) + array.get(nb_n, 1) + array.get(nb_n, 2)
pb      = total_n > 0 ? array.get(nb_n, 0) / total_n : prior_bull
ps      = total_n > 0 ? array.get(nb_n, 1) / total_n : (1.0 - prior_bull) / 2.0
pd      = total_n > 0 ? array.get(nb_n, 2) / total_n : (1.0 - prior_bull) / 2.0

lik_b = gauss_pdf(f1, mu1b, sd1b) * gauss_pdf(f2, mu2b, sd2b) * gauss_pdf(f3, mu3b, sd3b)
lik_s = gauss_pdf(f1, mu1s, sd1s) * gauss_pdf(f2, mu2s, sd2s) * gauss_pdf(f3, mu3s, sd3s)
lik_d = gauss_pdf(f1, mu1d, sd1d) * gauss_pdf(f2, mu2d, sd2d) * gauss_pdf(f3, mu3d, sd3d)

ev        = pb * lik_b + ps * lik_s + pd * lik_d + 1e-12
post_bull = pb * lik_b / ev
post_bear = ps * lik_s / ev

warmed_up = total_n >= nb_lookback

// ── TREND + ATR ───────────────────────────────────────────────────────────────
ema_line  = ta.ema(close, ema_period)
above_ema = close > ema_line
below_ema = close < ema_line
atr       = ta.atr(atr_period)

// ── SIGNALS ───────────────────────────────────────────────────────────────────
long_sig  = warmed_up and post_bull >= posterior_thresh and above_ema and cvd > cvd[1]
short_sig = warmed_up and post_bear >= posterior_thresh and below_ema and cvd < cvd[1]

// First bar of a new cluster only — avoids consecutive signal spam
long_entry  = long_sig  and not long_sig[1]
short_entry = short_sig and not short_sig[1]

// Confidence tier
bull_hi   = post_bull >= 0.85
bull_mid  = post_bull >= 0.75 and not bull_hi
bear_hi   = post_bear >= 0.85
bear_mid  = post_bear >= 0.75 and not bear_hi

// ── COLOURS ───────────────────────────────────────────────────────────────────
bull_base  = bull_col
bear_base  = bear_col

long_col   = bull_hi  ? bull_base : bull_mid ? color.new(bull_base, 30) : color.new(bull_base, 55)
short_col  = bear_hi  ? bear_base : bear_mid ? color.new(bear_base, 30) : color.new(bear_base, 55)

band_a_b   = warmed_up ? int(math.max(8,  100 - int(post_bull * 92))) : 100
band_a_s   = warmed_up ? int(math.max(8,  100 - int(post_bear * 92))) : 100

// ── PLOTS ─────────────────────────────────────────────────────────────────────
plot(ema_line, "EMA", color=color.new(color.gray, 50), linewidth=1)

b_top = plot(show_band ? ema_line + atr : na, display=display.none)
b_bot = plot(show_band ? ema_line       : na, display=display.none)
fill(b_top, b_bot,
     color = show_band and above_ema and warmed_up ? color.new(bull_base, band_a_b) : na,
     title = "Bull Band")

s_top = plot(show_band ? ema_line       : na, display=display.none)
s_bot = plot(show_band ? ema_line - atr : na, display=display.none)
fill(s_top, s_bot,
     color = show_band and below_ema and warmed_up ? color.new(bear_base, band_a_s) : na,
     title = "Bear Band")

// Entry shapes — first bar of cluster only, no text
plotshape(long_entry and bull_hi      and not zen_mode, "Long ● High",
          location=location.belowbar, style=shape.circle,     size=size.small, color=long_col)
plotshape(long_entry and not bull_hi  and not zen_mode, "Long ▲ Normal",
          location=location.belowbar, style=shape.triangleup, size=size.small, color=long_col)
plotshape(long_entry and zen_mode,                      "Long Zen",
          location=location.belowbar, style=shape.triangleup, size=size.small, color=long_col)

plotshape(short_entry and bear_hi     and not zen_mode, "Short ● High",
          location=location.abovebar, style=shape.circle,      size=size.small, color=short_col)
plotshape(short_entry and not bear_hi and not zen_mode, "Short ▼ Normal",
          location=location.abovebar, style=shape.triangledown, size=size.small, color=short_col)
plotshape(short_entry and zen_mode,                     "Short Zen",
          location=location.abovebar, style=shape.triangledown, size=size.small, color=short_col)

// Regime background
bgcolor(show_bg and warmed_up and post_bull >= posterior_thresh and above_ema
        ? color.new(bull_base, 93) : na, title="Bull Regime")
bgcolor(show_bg and warmed_up and post_bear >= posterior_thresh and below_ema
        ? color.new(bear_base, 93) : na, title="Bear Regime")

// ── SL / TP LINES ─────────────────────────────────────────────────────────────
var line sl_line = na
var line tp_line = na

if long_entry and show_levels and not zen_mode
    sl_price = close - atr * sl_atr_mult
    tp_price = close + atr * sl_atr_mult * rr_ratio
    sl_line := line.new(bar_index, sl_price, bar_index + 8, sl_price,
                 color=color.new(color.red, 30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_price, bar_index + 8, tp_price,
                 color=color.new(color.green, 30), width=1, style=line.style_dashed)

if short_entry and show_levels and not zen_mode
    sl_price = close + atr * sl_atr_mult
    tp_price = close - atr * sl_atr_mult * rr_ratio
    sl_line := line.new(bar_index, sl_price, bar_index + 8, sl_price,
                 color=color.new(color.red, 30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_price, bar_index + 8, tp_price,
                 color=color.new(color.green, 30), width=1, style=line.style_dashed)

// ── INFO TABLE ────────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 8,
    bgcolor      = color.new(color.black, 75),
    border_color = color.new(color.gray, 60),
    border_width = 1,
    frame_color  = color.new(color.gray, 50),
    frame_width  = 1)

if barstate.islast and show_table
    txt_hdr = color.new(color.gray,  0)
    txt_wht = color.new(color.white, 0)

    table.cell(tbl, 0, 0, "IOF Signals",    text_color=txt_hdr, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 1, 0, warmed_up ? "● LIVE" : "● WARMUP",
               text_color = warmed_up ? color.new(color.lime, 0) : color.new(color.yellow, 0),
               text_size  = size.small, bgcolor=color.new(color.black, 60))

    table.cell(tbl, 0, 1, "Bull P",         text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 1, str.format("{0,number,#.#%}", post_bull),
               text_color = post_bull >= posterior_thresh ? color.new(bull_col, 0) : color.new(color.gray, 0),
               text_size  = size.small)

    table.cell(tbl, 0, 2, "Bear P",         text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 2, str.format("{0,number,#.#%}", post_bear),
               text_color = post_bear >= posterior_thresh ? color.new(bear_col, 0) : color.new(color.gray, 0),
               text_size  = size.small)

    table.cell(tbl, 0, 3, "CVD Flow",       text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 3, cvd > cvd[1] ? "▲ Buy" : "▼ Sell",
               text_color = cvd > cvd[1] ? color.new(color.lime, 0) : color.new(bear_col, 0),
               text_size  = size.small)

    table.cell(tbl, 0, 4, "N Trained",      text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(int(total_n)) + (warmed_up ? " ✓" : " …"),
               text_color = warmed_up ? color.new(color.lime, 0) : color.new(color.yellow, 0),
               text_size  = size.small)

    // ── Icon legend ──────────────────────────────────────────────
    table.cell(tbl, 0, 5, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)
    table.cell(tbl, 1, 5, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)

    table.cell(tbl, 0, 6, "● ▲  Buy",  text_color=color.new(bull_col, 0), text_size=size.tiny)
    table.cell(tbl, 1, 6, "●=strong",  text_color=color.new(color.gray, 20), text_size=size.tiny)

    table.cell(tbl, 0, 7, "● ▼  Sell", text_color=color.new(bear_col, 0), text_size=size.tiny)
    table.cell(tbl, 1, 7, "▲▼=normal", text_color=color.new(color.gray, 20), text_size=size.tiny)

// ── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(long_entry,  "IOF Long Signal",  "Institutional Order Flow [PMT]: Bull signal — P(Bull) ≥ threshold")
alertcondition(short_entry, "IOF Short Signal", "Institutional Order Flow [PMT]: Bear signal — P(Bear) ≥ threshold")
alertcondition(long_entry or short_entry, "IOF Any Signal", "Institutional Order Flow [PMT]: Signal fired")
````
