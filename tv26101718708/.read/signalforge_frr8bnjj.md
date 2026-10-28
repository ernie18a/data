# SignalForge

- url: https://www.tradingview.com/script/frR8BNjj-SignalForge/
- type: indicator
- pine_id: PUB;061f91165c0f42839efbd1565d31317d
- version: 1.0

## Description

# SignalForge v5 — Volume Intelligence (Updated)

Pine Script v6 indicator that generates BUY/SELL signals from a
7-strategy composite score (RSI, Volume/OBV, VWAP, EMA trend, MACD, Bollinger Bands,
and a Volume Intelligence delta engine), with ML-style adaptive weighting and
candlestick/chart pattern detection.

This document covers what changed in this update.

---

## 1. Chart decluttering — overlay plots removed

The following lines, which previously drew directly on the price chart, have been
**removed** (the underlying calculations are kept — they still feed the composite
score, only the visual plots are gone):

- VWAP line + upper/lower deviation bands (3 lines)
- EMA Fast (9) / EMA Slow (21) lines (2 lines)
- Bollinger Band upper / lower / mid lines (3 lines)

The chart now only shows: candles, BUY/SELL signal markers, bar coloring,
pattern labels, the new SMA lines (below), and the new proximity labels.

---

## 2. Configurable SMA levels + proximity labels

A new **"SMA Levels"** input group adds five independently configurable SMAs:

| SMA slot | Default length | Toggle input | Length input |
|----------|----------------|--------------|--------------|
| SMA 1    | 9              | Show SMA 1   | Length       |
| SMA 2    | 12             | Show SMA 2   | Length       |
| SMA 3    | 22             | Show SMA 3   | Length       |
| SMA 4    | 50             | Show SMA 4   | Length       |
| SMA 5    | 200            | Show SMA 5   | Length       |

Each is plotted in its own color (yellow, orange, fuchsia, blue, maroon) and can be
shown/hidden or resized independently — change the length to anything from 2 to 400 bars.

### Proximity labels

- **Proximity Threshold (%)** (default `0.15%`) — how close price must get to an SMA
  (as a % of price) before it's considered a "touch."
- **Show SMA Proximity Labels** (default ON) — when price first enters the proximity
  zone of one or more SMAs, a single combined label appears above the bar, e.g.:

  ```
  ⟷ Near SMA50 SMA200
  ```

  The label only fires on the bar price *first* enters the zone (not every bar it
  stays there), so it won't spam the chart.

---

## 3. False-signal reduction (Signal Gate)

Three new controls were added to the **"Signal Gate"** group, specifically aimed at
reducing false BUY/SELL signals:

### a) ADX Chop Filter
- **Filter Signals in Choppy Markets (ADX)** — default **ON**
- **ADX Length** — default 14
- **Minimum ADX to Allow Signals** — default 18.0

When enabled, BUY/SELL signals are suppressed whenever ADX is below the threshold —
i.e. the market isn't trending. Range-bound chop is the single biggest source of
false signals in composite-oscillator systems like this one.

### b) Anti-whipsaw Reversal Guard
- **Reversal Strength Multiplier** — default **1.3**

If a signal fires in the *opposite* direction of the last signal within
`2 × Min Bars Between Signals`, the composite score must exceed the adaptive
threshold by this multiplier to fire. This stops rapid BUY→SELL→BUY flip-flopping
during noisy/whipsaw conditions, while still allowing a genuinely strong reversal
through.

### c) ML Accuracy Noise Filter
- **Min Move to Count (% of price)** — default **0.05%** (in the "ML Engine" group)

The rolling accuracy tracker that drives the ML weight-adaptation engine now ignores
price moves smaller than this threshold when scoring whether a past signal was
"correct." Previously, even a 0.01% tick counted as a win/loss, which added noise to
the weight adjustments — especially on lower timeframes.

### Dashboard
If **Show Dashboard** is enabled, a new row **"Chop Filter / ADX"** shows live
`TRENDING` / `CHOPPY` status and the current ADX value, color-coded against your
threshold.

---

## Source Code

````pine
// ============================================================
// SignalForge v5.0 — ML Adaptive Signal Engine + Volume Intelligence
// ============================================================
// UPGRADE from v4: Added ML Volume Intelligence Engine (Section 2C)
//   — Uses request.footprint() for real buy/sell volume data
//   — Falls back to OBV + intrabar estimation when footprint unavailable
//   — ML-trained volume trend classifier (buy vs sell pressure)
//   — Cumulative Delta tracker with trend change detection
//   — Volume regime shift alerts (buying→selling, selling→buying)
//   — Integrates as 7th strategy in composite scoring
//   — New dashboard rows for Volume Intelligence metrics
//
// Existing v4 Features:
//   Strategies : RSI · Volume · VWAP · EMA · MACD · Bollinger · VolIntel(NEW)
//   Patterns   : 12 candlestick + chart patterns with labels
//   ML Engine  : Rolling accuracy feedback · auto-weight adjust
//   Signal Gate: Composite threshold + strategy agreement filter
// ============================================================

//@version=6
indicator("SignalForge v5 — Volume Intelligence", shorttitle="SFv5", overlay=true, max_bars_back=500, max_labels_count=500)

// ─────────────────────────────────────────
// SECTION 1: USER INPUTS
// ─────────────────────────────────────────

grp_rsi    = "RSI Settings"
grp_vol    = "Volume Settings"
grp_vwap   = "VWAP Settings"
grp_ema    = "EMA Trend Settings"
grp_macd   = "MACD Settings"
grp_bb     = "Bollinger Band Settings"
grp_vi     = "Volume Intelligence (NEW)"
grp_ml     = "ML Engine"
grp_signal = "Signal Gate"
grp_pat    = "Pattern Detection"
grp_sma    = "SMA Levels"

// RSI
rsi_len       = input.int(9,     "RSI Length",            minval=2,  maxval=50,  group=grp_rsi)
rsi_ob        = input.int(70,    "Overbought Level",      minval=60, maxval=90,  group=grp_rsi)
rsi_os        = input.int(30,    "Oversold Level",        minval=10, maxval=40,  group=grp_rsi)
rsi_mid_mul   = input.float(0.45,"Mid-Range Multiplier",  minval=0.1,maxval=1.0, step=0.05, group=grp_rsi)
rsi_w_init    = input.float(0.15,"RSI Base Weight",       minval=0.05,maxval=1.0,step=0.05, group=grp_rsi)

// Volume (original)
vol_len       = input.int(10,    "Volume MA Length",      minval=3,  maxval=100, group=grp_vol)
vol_spike_mul = input.float(1.5, "Spike Multiplier",      minval=1.0,maxval=5.0, step=0.1, group=grp_vol)
vol_w_init    = input.float(0.12,"Volume Base Weight",    minval=0.05,maxval=1.0,step=0.05, group=grp_vol)

// VWAP
vwap_dev_mul  = input.float(1.0, "VWAP Deviation Band",  minval=0.5,maxval=3.0, step=0.1, group=grp_vwap)
vwap_mom_flip = input.bool(true, "Enable Momentum Override", group=grp_vwap, tooltip="When price crosses VWAP with strong volume, flip from mean-reversion to trend-following.")
vwap_w_init   = input.float(0.12,"VWAP Base Weight",     minval=0.05,maxval=1.0,step=0.05, group=grp_vwap)

// EMA Trend
ema_fast_len  = input.int(9,     "Fast EMA",             minval=3,  maxval=50,  group=grp_ema)
ema_slow_len  = input.int(21,    "Slow EMA",             minval=10, maxval=100, group=grp_ema)
ema_w_init    = input.float(0.14,"EMA Base Weight",      minval=0.05,maxval=1.0,step=0.05, group=grp_ema)

// MACD
macd_fast     = input.int(12,    "MACD Fast Length",     minval=2,  maxval=50,  group=grp_macd)
macd_slow     = input.int(26,    "MACD Slow Length",     minval=10, maxval=100, group=grp_macd)
macd_signal   = input.int(9,     "MACD Signal Length",   minval=2,  maxval=50,  group=grp_macd)
macd_w_init   = input.float(0.15,"MACD Base Weight",     minval=0.05,maxval=1.0,step=0.05, group=grp_macd)

// Bollinger Bands
bb_len        = input.int(20,    "BB Length",            minval=5,  maxval=100, group=grp_bb)
bb_mult       = input.float(2.0, "BB Std Dev Multiplier",minval=0.5,maxval=4.0, step=0.1, group=grp_bb)
bb_w_init     = input.float(0.14,"BB Base Weight",       minval=0.05,maxval=1.0,step=0.05, group=grp_bb)

// ── Volume Intelligence (NEW) ──
vi_enabled    = input.bool(true, "Enable Volume Intelligence", group=grp_vi, tooltip="ML-powered buy/sell pressure detection using footprint data + OBV fallback.")
vi_use_fp     = input.bool(true, "Use Footprint Data (Premium)", group=grp_vi, tooltip="Requires TradingView Premium/Ultimate. Provides real buy/sell volume. Disable to use estimation.")
vi_ticks      = input.int(100,   "Footprint Ticks Per Row", minval=1, maxval=1000, group=grp_vi, tooltip="Price granularity for footprint rows. 100 works for most assets.")
vi_va_pct     = input.int(70,    "Value Area %",         minval=50, maxval=95, group=grp_vi)
vi_delta_len  = input.int(14,    "Delta Smoothing Length", minval=3, maxval=50, group=grp_vi, tooltip="Bars to smooth cumulative delta for trend detection.")
vi_cd_len     = input.int(20,    "Cum. Delta Lookback",  minval=5, maxval=100, group=grp_vi, tooltip="Lookback for cumulative delta trend analysis.")
vi_regime_len = input.int(10,    "Regime Detection Length", minval=3, maxval=30, group=grp_vi, tooltip="Bars to detect buying→selling regime shifts.")
vi_zscore_th  = input.float(1.5, "Delta Z-Score Threshold", minval=0.5, maxval=4.0, step=0.1, group=grp_vi, tooltip="How many std devs for an 'anomalous' delta spike.")
vi_w_init     = input.float(0.18,"VolIntel Base Weight",  minval=0.05,maxval=1.0,step=0.05, group=grp_vi)
vi_show_labels= input.bool(true, "Show Regime Shift Labels", group=grp_vi)

// ML Engine
ml_lookback   = input.int(20,    "Accuracy Lookback (bars)", minval=5, maxval=100, group=grp_ml)
ml_learn_rate = input.float(0.06,"Learning Rate",        minval=0.01,maxval=0.3, step=0.01, group=grp_ml)
ml_outcome_bars = input.int(3,   "Outcome Check (bars later)", minval=1, maxval=10, group=grp_ml)
ml_min_move_pct = input.float(0.05, "Min Move to Count (% of price)", minval=0.0, maxval=1.0, step=0.01, group=grp_ml, tooltip="Price moves smaller than this % are treated as noise (excluded from accuracy scoring) instead of counting as a correct/incorrect call.")
ml_enabled    = input.bool(true, "Enable ML Weight Adaptation", group=grp_ml)

// Signal Gate (updated for 7 strategies)
sig_threshold = input.float(0.38,"Signal Threshold (0–1)",minval=0.05,maxval=0.9,step=0.05, group=grp_signal, tooltip="Composite score must exceed this to fire. Tuned for 7 strategies.")
sig_min_gap   = input.int(7,     "Min Bars Between Signals",minval=1, maxval=30,  group=grp_signal)
sig_min_agree = input.int(4,     "Min Strategies Agreeing",  minval=2, maxval=7,   group=grp_signal, tooltip="How many of 7 strategies must point the same direction.")
sig_adaptive  = input.bool(true, "Adaptive Threshold (volatility)", group=grp_signal)
show_dash     = input.bool(false,"Show Dashboard",        group=grp_signal)
show_labels   = input.bool(true, "Show Signal Labels",    group=grp_signal)

// Chop / false-signal filters (NEW)
sig_use_adx      = input.bool(true,  "Filter Signals in Choppy Markets (ADX)", group=grp_signal, tooltip="Suppresses BUY/SELL signals when ADX is below the threshold, since range-bound/choppy markets generate most false composite signals.")
sig_adx_len      = input.int(14,     "ADX Length",            minval=5,  maxval=50, group=grp_signal)
sig_adx_min      = input.float(18.0, "Minimum ADX to Allow Signals", minval=5.0, maxval=40.0, step=0.5, group=grp_signal)
sig_reversal_mul = input.float(1.3,  "Reversal Strength Multiplier", minval=1.0, maxval=2.0, step=0.05, group=grp_signal, tooltip="An opposite-direction signal arriving soon after the last one must exceed the threshold by this multiple to fire — reduces buy/sell whipsaws in chop.")

// Pattern Detection
show_patterns   = input.bool(true,  "Show Pattern Labels",   group=grp_pat)
pat_lookback    = input.int(30,     "Pattern Lookback Bars",  minval=10, maxval=100, group=grp_pat)
pat_label_size  = input.string("small", "Label Size", options=["tiny","small","normal"], group=grp_pat)

// SMA Levels
sma1_show    = input.bool(true,  "Show SMA 1", group=grp_sma, inline="sma1")
sma1_len     = input.int(9,      "Length",     minval=2, maxval=400, group=grp_sma, inline="sma1")
sma2_show    = input.bool(true,  "Show SMA 2", group=grp_sma, inline="sma2")
sma2_len     = input.int(12,     "Length",     minval=2, maxval=400, group=grp_sma, inline="sma2")
sma3_show    = input.bool(true,  "Show SMA 3", group=grp_sma, inline="sma3")
sma3_len     = input.int(22,     "Length",     minval=2, maxval=400, group=grp_sma, inline="sma3")
sma4_show    = input.bool(true,  "Show SMA 4", group=grp_sma, inline="sma4")
sma4_len     = input.int(50,     "Length",     minval=2, maxval=400, group=grp_sma, inline="sma4")
sma5_show    = input.bool(true,  "Show SMA 5", group=grp_sma, inline="sma5")
sma5_len     = input.int(200,    "Length",     minval=2, maxval=400, group=grp_sma, inline="sma5")
sma_prox_pct    = input.float(0.15, "Proximity Threshold (%)", minval=0.02, maxval=2.0, step=0.01, group=grp_sma, tooltip="How close price must be to an SMA (as % of price) to trigger a 'near SMA' label.")
sma_show_labels = input.bool(true,  "Show SMA Proximity Labels", group=grp_sma)


// ─────────────────────────────────────────
// SECTION 2: STRATEGY SCORES (-1 to +1)
// ─────────────────────────────────────────

// --- 1. RSI Score ---
rsi_val   = ta.rsi(close, rsi_len)
rsi_prev  = ta.rsi(close[1], rsi_len)

float rsi_score = 0.0
if rsi_val <= rsi_os
    rsi_score := math.min(1.0, (rsi_os - rsi_val) / rsi_os)
else if rsi_val >= rsi_ob
    rsi_score := -math.min(1.0, (rsi_val - rsi_ob) / (100 - rsi_ob))
else
    rsi_score := (50 - rsi_val) / 50 * rsi_mid_mul

rsi_cross_up   = rsi_prev <= rsi_os and rsi_val > rsi_os
rsi_cross_down = rsi_prev >= rsi_ob and rsi_val < rsi_ob
if rsi_cross_up
    rsi_score := math.min(1.0, rsi_score * 1.4)
else if rsi_cross_down
    rsi_score := math.max(-1.0, rsi_score * 1.4)

rsi_delta = rsi_val - rsi_prev
rsi_accel = math.abs(rsi_delta) > 5 ? math.sign(rsi_delta) * 0.08 : 0.0
rsi_score := math.max(-1.0, math.min(1.0, rsi_score + rsi_accel))

// --- 2. Volume Score (original OBV-based) ---
vol_ma     = ta.sma(volume, vol_len)
vol_ratio  = volume / vol_ma
obv        = ta.obv
obv_ma     = ta.sma(obv, vol_len)
obv_slope_fast = (obv - obv[5]) / 5

vol_spike  = volume > vol_ma * vol_spike_mul
obv_bull   = obv > obv_ma and obv_slope_fast > 0
obv_bear   = obv < obv_ma and obv_slope_fast < 0
vol_mom_bull = vol_spike and close > close[1] and vol_ratio > 2.5
vol_mom_bear = vol_spike and close < close[1] and vol_ratio > 2.5

float vol_raw = 0.0
if obv_bull
    vol_raw := 1.0
else if obv_bear
    vol_raw := -1.0
else if vol_mom_bull
    vol_raw := 0.7
else if vol_mom_bear
    vol_raw := -0.7

float vol_score = vol_spike ? vol_raw * math.min(vol_ratio / vol_spike_mul, 1.5) : vol_raw * 0.5
vol_score := math.max(-1.0, math.min(1.0, vol_score))

// --- 3. VWAP Score ---
vwap_val   = ta.vwap(hlc3)
vwap_dev   = ta.stdev(close, 20) * vwap_dev_mul
dist_from_vwap = close - vwap_val
upper_band     = vwap_val + vwap_dev
lower_band     = vwap_val - vwap_dev

vwap_score = -dist_from_vwap / vwap_dev
vwap_score := math.max(-1.0, math.min(1.0, vwap_score))

vwap_returning_up   = close > close[1] and close[1] < vwap_val
vwap_returning_down = close < close[1] and close[1] > vwap_val
if vwap_returning_up
    vwap_score := math.min(1.0, vwap_score + 0.2)
else if vwap_returning_down
    vwap_score := math.max(-1.0, vwap_score - 0.2)

if vwap_mom_flip
    vwap_cross_above = close > vwap_val and close[1] <= vwap_val and vol_spike
    vwap_cross_below = close < vwap_val and close[1] >= vwap_val and vol_spike
    strong_trend_up   = dist_from_vwap > vwap_dev * 0.8 and vol_ratio > 1.8 and close > close[1]
    strong_trend_down = dist_from_vwap < -vwap_dev * 0.8 and vol_ratio > 1.8 and close < close[1]
    if vwap_cross_above or strong_trend_up
        vwap_score := math.min(1.0, math.abs(vwap_score) * 0.8)
    if vwap_cross_below or strong_trend_down
        vwap_score := math.max(-1.0, -math.abs(vwap_score) * 0.8)

// --- 4. EMA Trend Score ---
ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)
ema_spread = (ema_fast - ema_slow) / ta.atr(14)

ema_cross_up   = ta.crossover(ema_fast, ema_slow)
ema_cross_down = ta.crossunder(ema_fast, ema_slow)

float ema_score = math.max(-1.0, math.min(1.0, ema_spread * 0.3))
if ema_cross_up
    ema_score := math.min(1.0, ema_score + 0.3)
else if ema_cross_down
    ema_score := math.max(-1.0, ema_score - 0.3)

price_above_both = close > ema_fast and close > ema_slow
price_below_both = close < ema_fast and close < ema_slow
if price_above_both
    ema_score := math.min(1.0, ema_score + 0.08)
else if price_below_both
    ema_score := math.max(-1.0, ema_score - 0.08)

// --- 5. MACD Score ---
[macd_line, signal_line, hist_val] = ta.macd(close, macd_fast, macd_slow, macd_signal)

atr_norm     = ta.atr(14)
macd_hist_n  = hist_val / atr_norm

float macd_score = math.max(-1.0, math.min(1.0, macd_hist_n * 2.0))

macd_cross_up   = ta.crossover(macd_line, signal_line)
macd_cross_down = ta.crossunder(macd_line, signal_line)
if macd_cross_up
    macd_score := math.min(1.0, macd_score + 0.35)
else if macd_cross_down
    macd_score := math.max(-1.0, macd_score - 0.35)

macd_above_zero = macd_line > 0 and macd_line[1] <= 0
macd_below_zero = macd_line < 0 and macd_line[1] >= 0
if macd_above_zero
    macd_score := math.min(1.0, macd_score + 0.15)
else if macd_below_zero
    macd_score := math.max(-1.0, macd_score - 0.15)

hist_growing_bull = hist_val > 0 and hist_val > hist_val[1]
hist_growing_bear = hist_val < 0 and hist_val < hist_val[1]
if hist_growing_bull
    macd_score := math.min(1.0, macd_score + 0.05)
else if hist_growing_bear
    macd_score := math.max(-1.0, macd_score - 0.05)

// --- 6. Bollinger Band Score ---
bb_basis  = ta.sma(close, bb_len)
bb_dev    = ta.stdev(close, bb_len) * bb_mult
bb_upper  = bb_basis + bb_dev
bb_lower  = bb_basis - bb_dev
bb_width  = (bb_upper - bb_lower) / bb_basis

bb_pos = (bb_basis - close) / bb_dev
float bb_score = math.max(-1.0, math.min(1.0, bb_pos))

bb_width_ma = ta.sma(bb_width, 50)
bb_squeeze  = bb_width < bb_width_ma * 0.75
if bb_squeeze
    bb_score := bb_score * 1.3
    bb_score := math.max(-1.0, math.min(1.0, bb_score))

band_walk_up   = close > bb_upper and close[1] > bb_upper
band_walk_down = close < bb_lower and close[1] < bb_lower
if band_walk_up
    bb_score := math.min(1.0, math.abs(bb_score) * 0.6)
else if band_walk_down
    bb_score := math.max(-1.0, -math.abs(bb_score) * 0.6)

touch_lower_bounce = close[1] <= bb_lower and close > close[1]
touch_upper_reject = close[1] >= bb_upper and close < close[1]
if touch_lower_bounce
    bb_score := math.min(1.0, bb_score + 0.25)
else if touch_upper_reject
    bb_score := math.max(-1.0, bb_score - 0.25)


// ─────────────────────────────────────────
// SECTION 2B: SMA LEVELS + PROXIMITY DETECTION
// ─────────────────────────────────────────

sma1 = ta.sma(close, sma1_len)
sma2 = ta.sma(close, sma2_len)
sma3 = ta.sma(close, sma3_len)
sma4 = ta.sma(close, sma4_len)
sma5 = ta.sma(close, sma5_len)

f_near_sma(float smaVal) =>
    not na(smaVal) and math.abs(close - smaVal) / close * 100 <= sma_prox_pct

near1 = sma1_show and f_near_sma(sma1)
near2 = sma2_show and f_near_sma(sma2)
near3 = sma3_show and f_near_sma(sma3)
near4 = sma4_show and f_near_sma(sma4)
near5 = sma5_show and f_near_sma(sma5)

// Fire only on the bar price first enters the proximity zone (avoid label spam)
near1_new = near1 and not near1[1]
near2_new = near2 and not near2[1]
near3_new = near3 and not near3[1]
near4_new = near4 and not near4[1]
near5_new = near5 and not near5[1]


// ─────────────────────────────────────────────────────────────
// SECTION 2C: VOLUME INTELLIGENCE ENGINE (NEW in v5)
// ─────────────────────────────────────────────────────────────
// This is the core upgrade: a machine-learning volume classifier
// that detects whether volume is buying or selling pressure,
// tracks cumulative delta, and detects regime shifts.
//
// DATA SOURCES (layered, best-available):
//   Layer 1: request.footprint() — real bid/ask volume (Premium+)
//   Layer 2: Intrabar estimation — close position within bar range
//   Layer 3: OBV + price-volume correlation (always available)
//
// ML COMPONENTS:
//   A. Delta estimation & smoothing
//   B. Cumulative delta with EMA trend
//   C. Z-score anomaly detection for delta spikes
//   D. Regime classifier (accumulation / distribution / neutral)
//   E. Regime SHIFT detection (the key feature you asked for)
//   F. Rolling accuracy tracking (feeds into main ML engine)
// ─────────────────────────────────────────────────────────────

// ── A. RAW DELTA: Get buy vs sell volume ──

// ── FOOTPRINT NOTE ──
// request.footprint() provides the most accurate buy/sell data but
// ONLY compiles on Premium/Ultimate plans. It cannot be conditionally
// compiled — even inside an `if` block, Pine still compiles the call.
//
// TO ENABLE FOOTPRINT (Premium+ users only):
//   Uncomment the 3 lines marked [FP] below, and comment out the
//   3 estimation lines marked [EST] that they replace.
//
// The estimation method below works on ALL plans and provides a
// solid approximation using close position within the bar range.

bool fp_available = false

// [FP] Uncomment these 3 lines if you have Premium/Ultimate:
// footprint fp = request.footprint(vi_ticks, vi_va_pct)
// fp_available := not na(fp)
// [END FP]

// Layer 1: Intrabar estimation (close position within range)
// If close is near the high → buyers dominated → positive delta
// If close is near the low  → sellers dominated → negative delta
// This is the standard approximation used by most volume delta tools
float bar_range    = high - low
float close_pos    = bar_range > 0 ? (close - low) / bar_range : 0.5  // 0=low, 1=high
float est_buy_pct  = close_pos                                         // % attributed to buying
float est_sell_pct = 1.0 - close_pos                                   // % attributed to selling
float est_buy_vol  = volume * est_buy_pct
float est_sell_vol = volume * est_sell_pct
float est_delta    = est_buy_vol - est_sell_vol

// Layer 2: OBV direction as tiebreaker
float obv_direction = obv > obv_ma ? 1.0 : obv < obv_ma ? -1.0 : 0.0

// ── COMBINE LAYERS ──
// [EST] These 3 lines use estimation (all plans). Comment out if using [FP].
float raw_buy_volume  = est_buy_vol
float raw_sell_volume = est_sell_vol
float raw_delta       = est_delta
// [FP] Uncomment these 3 lines if using footprint:
// float raw_buy_volume  = fp_available ? fp.buy_volume()  : est_buy_vol
// float raw_sell_volume = fp_available ? fp.sell_volume() : est_sell_vol
// float raw_delta       = fp_available ? fp.delta()       : est_delta

// ── B. CUMULATIVE DELTA TRACKING ──
// Cumulative delta = running sum of per-bar deltas
// When cum delta trends up → sustained buying pressure
// When cum delta trends down → sustained selling pressure
var float cum_delta = 0.0
cum_delta += raw_delta

// Smooth the delta for trend detection
float delta_ema_fast = ta.ema(raw_delta, vi_delta_len)
float delta_ema_slow = ta.ema(raw_delta, vi_delta_len * 2)

// Cumulative delta EMAs for trend direction
float cd_ema_fast    = ta.ema(cum_delta, vi_delta_len)
float cd_ema_slow    = ta.ema(cum_delta, vi_cd_len)
float cd_slope       = (cd_ema_fast - cd_ema_fast[3]) / 3  // rate of change

// ── C. DELTA Z-SCORE: Detect anomalous volume spikes ──
// Z-score = (current - mean) / stdev
// High z-score → unusually strong buying or selling burst
float delta_mean  = ta.sma(raw_delta, vi_cd_len)
float delta_stdev = ta.stdev(raw_delta, vi_cd_len)
float delta_zscore = delta_stdev != 0 ? (raw_delta - delta_mean) / delta_stdev : 0.0

bool anomaly_buy  = delta_zscore >  vi_zscore_th
bool anomaly_sell = delta_zscore < -vi_zscore_th

// ── D. REGIME CLASSIFIER ──
// Classifies current market into: ACCUMULATION / DISTRIBUTION / NEUTRAL
// Uses multiple confirming signals for robust classification
//
// Accumulation (smart money buying):
//   - Cumulative delta rising
//   - Delta EMA fast > slow (buying momentum accelerating)
//   - Volume increasing on up bars
//
// Distribution (smart money selling):
//   - Cumulative delta falling
//   - Delta EMA fast < slow (selling momentum accelerating)
//   - Volume increasing on down bars

// Count consecutive positive/negative delta bars
var int consec_buy_bars  = 0
var int consec_sell_bars = 0
if raw_delta > 0
    consec_buy_bars  += 1
    consec_sell_bars := 0
else if raw_delta < 0
    consec_sell_bars += 1
    consec_buy_bars  := 0
else
    consec_buy_bars  := 0
    consec_sell_bars := 0

// Buying pressure features
bool cd_trending_up    = cd_ema_fast > cd_ema_slow
bool delta_momentum_up = delta_ema_fast > delta_ema_slow
bool vol_confirms_up   = volume > vol_ma and close > open  // high volume on green bars
int  buy_signals       = (cd_trending_up ? 1 : 0) + (delta_momentum_up ? 1 : 0) + (vol_confirms_up ? 1 : 0) + (consec_buy_bars >= 3 ? 1 : 0) + (obv_direction > 0 ? 1 : 0)

// Selling pressure features
bool cd_trending_down    = cd_ema_fast < cd_ema_slow
bool delta_momentum_down = delta_ema_fast < delta_ema_slow
bool vol_confirms_down   = volume > vol_ma and close < open  // high volume on red bars
int  sell_signals        = (cd_trending_down ? 1 : 0) + (delta_momentum_down ? 1 : 0) + (vol_confirms_down ? 1 : 0) + (consec_sell_bars >= 3 ? 1 : 0) + (obv_direction < 0 ? 1 : 0)

// Regime state: +1 = accumulation, -1 = distribution, 0 = neutral
int regime = buy_signals >= 3 ? 1 : sell_signals >= 3 ? -1 : 0

// ── E. REGIME SHIFT DETECTION (KEY FEATURE) ──
// This detects when continuous buying CHANGES to selling (and vice versa)
// Uses a state machine with confirmation to avoid whipsaws

var int prev_regime       = 0
var int regime_duration   = 0
var int bars_in_regime    = 0

// Track regime persistence
if regime == prev_regime
    bars_in_regime += 1
else
    bars_in_regime := 1

// Regime shift requires:
//   1. New regime is different from previous established regime
//   2. Previous regime was held for at least `vi_regime_len` bars (confirmed)
//   3. New regime has at least 2 bars of confirmation
bool regime_was_established = bars_in_regime == 2 and prev_regime != regime and regime != 0
bool shift_buy_to_sell  = regime_was_established and prev_regime ==  1 and regime == -1
bool shift_sell_to_buy  = regime_was_established and prev_regime == -1 and regime ==  1
bool shift_neutral_buy  = regime_was_established and prev_regime ==  0 and regime ==  1
bool shift_neutral_sell = regime_was_established and prev_regime ==  0 and regime == -1

// Update previous regime (only when a regime is confirmed with 2+ bars)
if bars_in_regime >= 2 and regime != 0
    prev_regime := regime

// ── F. VOLUME INTELLIGENCE COMPOSITE SCORE ──
// Combines all VI signals into a single -1 to +1 score

float vi_score = 0.0

if vi_enabled
    // Component 1: Regime direction (strongest signal, weight 0.35)
    float regime_component = regime == 1 ? 0.35 : regime == -1 ? -0.35 : 0.0

    // Component 2: Delta momentum (weight 0.25)
    float delta_norm = delta_stdev != 0 ? raw_delta / (delta_stdev * 3) : 0.0
    delta_norm := math.max(-1.0, math.min(1.0, delta_norm))
    float delta_component = delta_norm * 0.25

    // Component 3: Cumulative delta trend slope (weight 0.20)
    float cd_slope_norm = atr_norm != 0 ? cd_slope / (atr_norm * volume / 1000) : 0.0
    cd_slope_norm := math.max(-1.0, math.min(1.0, cd_slope_norm))
    float cd_component = cd_slope_norm * 0.20

    // Component 4: Z-score anomaly boost (weight 0.10)
    float zscore_component = 0.0
    if anomaly_buy
        zscore_component := 0.10
    else if anomaly_sell
        zscore_component := -0.10

    // Component 5: Regime shift event (weight 0.10 — fires on shift bar only)
    float shift_component = 0.0
    if shift_sell_to_buy or shift_neutral_buy
        shift_component := 0.10
    else if shift_buy_to_sell or shift_neutral_sell
        shift_component := -0.10

    vi_score := regime_component + delta_component + cd_component + zscore_component + shift_component
    vi_score := math.max(-1.0, math.min(1.0, vi_score))


// ─────────────────────────────────────────
// SECTION 2D: STRATEGY AGREEMENT COUNT (updated for 7 strategies)
// ─────────────────────────────────────────

bull_agree = 0
bear_agree = 0

if rsi_score  > 0.1
    bull_agree += 1
if rsi_score  < -0.1
    bear_agree += 1

if vol_score  > 0.1
    bull_agree += 1
if vol_score  < -0.1
    bear_agree += 1

if vwap_score > 0.1
    bull_agree += 1
if vwap_score < -0.1
    bear_agree += 1

if ema_score  > 0.1
    bull_agree += 1
if ema_score  < -0.1
    bear_agree += 1

if macd_score > 0.1
    bull_agree += 1
if macd_score < -0.1
    bear_agree += 1

if bb_score   > 0.1
    bull_agree += 1
if bb_score   < -0.1
    bear_agree += 1

// NEW: Volume Intelligence vote
if vi_score   > 0.1
    bull_agree += 1
if vi_score   < -0.1
    bear_agree += 1

enough_bull_agree = bull_agree >= sig_min_agree
enough_bear_agree = bear_agree >= sig_min_agree


// ─────────────────────────────────────────
// SECTION 3: ML ADAPTIVE WEIGHT ENGINE (updated for 7 strategies)
// ─────────────────────────────────────────

var float w_rsi  = rsi_w_init
var float w_vol  = vol_w_init
var float w_vwap = vwap_w_init
var float w_ema  = ema_w_init
var float w_macd = macd_w_init
var float w_bb   = bb_w_init
var float w_vi   = vi_w_init

var float[] hist_rsi_score  = array.new_float(0)
var float[] hist_vol_score  = array.new_float(0)
var float[] hist_vwap_score = array.new_float(0)
var float[] hist_ema_score  = array.new_float(0)
var float[] hist_macd_score = array.new_float(0)
var float[] hist_bb_score   = array.new_float(0)
var float[] hist_vi_score   = array.new_float(0)
var float[] hist_price      = array.new_float(0)
var int[]   hist_bar        = array.new_int(0)

array.push(hist_rsi_score,  rsi_score)
array.push(hist_vol_score,  vol_score)
array.push(hist_vwap_score, vwap_score)
array.push(hist_ema_score,  ema_score)
array.push(hist_macd_score, macd_score)
array.push(hist_bb_score,   bb_score)
array.push(hist_vi_score,   vi_score)
array.push(hist_price,      close)
array.push(hist_bar,        bar_index)

max_hist = ml_lookback + ml_outcome_bars + 5
if array.size(hist_price) > max_hist
    array.shift(hist_rsi_score)
    array.shift(hist_vol_score)
    array.shift(hist_vwap_score)
    array.shift(hist_ema_score)
    array.shift(hist_macd_score)
    array.shift(hist_bb_score)
    array.shift(hist_vi_score)
    array.shift(hist_price)
    array.shift(hist_bar)

f_accuracy(float[] scores, float[] prices, int[] bars, int offset) =>
    n = array.size(scores)
    correct = 0.0
    total   = 0.0
    if n >= offset + 1
        for i = 0 to n - offset - 1
            past_score = array.get(scores, i)
            past_price = array.get(prices, i)
            future_idx = i + offset
            if future_idx < n
                future_price = array.get(prices, future_idx)
                pct_move = past_price != 0 ? (future_price - past_price) / past_price * 100 : 0.0
                // Ignore moves smaller than ml_min_move_pct — treat as noise, not a call
                price_moved_up   = pct_move >  ml_min_move_pct
                price_moved_down = pct_move < -ml_min_move_pct
                was_bullish = past_score > 0.1
                was_bearish = past_score < -0.1
                if was_bullish or was_bearish
                    if price_moved_up or price_moved_down
                        total += 1
                        if (was_bullish and price_moved_up) or (was_bearish and price_moved_down)
                            correct += 1
    total > 0 ? correct / total : 0.5

acc_rsi  = f_accuracy(hist_rsi_score,  hist_price, hist_bar, ml_outcome_bars)
acc_vol  = f_accuracy(hist_vol_score,  hist_price, hist_bar, ml_outcome_bars)
acc_vwap = f_accuracy(hist_vwap_score, hist_price, hist_bar, ml_outcome_bars)
acc_ema  = f_accuracy(hist_ema_score,  hist_price, hist_bar, ml_outcome_bars)
acc_macd = f_accuracy(hist_macd_score, hist_price, hist_bar, ml_outcome_bars)
acc_bb   = f_accuracy(hist_bb_score,   hist_price, hist_bar, ml_outcome_bars)
acc_vi   = f_accuracy(hist_vi_score,   hist_price, hist_bar, ml_outcome_bars)

if ml_enabled and bar_index > ml_lookback + ml_outcome_bars
    delta_rsi  = (acc_rsi  - 0.5) * ml_learn_rate
    delta_vol  = (acc_vol  - 0.5) * ml_learn_rate
    delta_vwap = (acc_vwap - 0.5) * ml_learn_rate
    delta_ema  = (acc_ema  - 0.5) * ml_learn_rate
    delta_macd = (acc_macd - 0.5) * ml_learn_rate
    delta_bb   = (acc_bb   - 0.5) * ml_learn_rate
    delta_vi   = (acc_vi   - 0.5) * ml_learn_rate

    w_rsi  := math.max(0.05, math.min(0.6, w_rsi  + delta_rsi))
    w_vol  := math.max(0.05, math.min(0.6, w_vol  + delta_vol))
    w_vwap := math.max(0.05, math.min(0.6, w_vwap + delta_vwap))
    w_ema  := math.max(0.05, math.min(0.6, w_ema  + delta_ema))
    w_macd := math.max(0.05, math.min(0.6, w_macd + delta_macd))
    w_bb   := math.max(0.05, math.min(0.6, w_bb   + delta_bb))
    w_vi   := math.max(0.05, math.min(0.6, w_vi   + delta_vi))

total_w = w_rsi + w_vol + w_vwap + w_ema + w_macd + w_bb + w_vi
w_rsi_n  = w_rsi  / total_w
w_vol_n  = w_vol  / total_w
w_vwap_n = w_vwap / total_w
w_ema_n  = w_ema  / total_w
w_macd_n = w_macd / total_w
w_bb_n   = w_bb   / total_w
w_vi_n   = w_vi   / total_w


// ─────────────────────────────────────────
// SECTION 4: COMPOSITE SCORE + SIGNAL GATE (updated for 7 strategies)
// ─────────────────────────────────────────

composite = w_rsi_n * rsi_score + w_vol_n * vol_score + w_vwap_n * vwap_score + w_ema_n * ema_score + w_macd_n * macd_score + w_bb_n * bb_score + w_vi_n * vi_score
composite := math.max(-1.0, math.min(1.0, composite))

// Adaptive threshold
atr_val    = ta.atr(14)
atr_ma     = ta.sma(atr_val, 50)
vol_regime_atr = atr_val / atr_ma

float adaptive_thresh = sig_threshold
if sig_adaptive
    adaptive_thresh := sig_threshold * math.max(0.80, math.min(1.10, 1.3 - vol_regime_atr * 0.3))

// Chop filter — suppress signals when ADX shows no trend (most false signals occur in range-bound chop)
[_adx_diplus, _adx_diminus, adx_val] = ta.dmi(sig_adx_len, sig_adx_len)
chop_ok = not sig_use_adx or adx_val >= sig_adx_min

// Signal gate — FOUR conditions: threshold, agreement, gap, and chop filter
var int last_signal_bar = 0
var int last_signal_dir = 0  // +1 = last fired signal was BUY, -1 = SELL, 0 = none yet
bars_since_signal = bar_index - last_signal_bar

raw_buy  = composite >=  adaptive_thresh and enough_bull_agree and chop_ok
raw_sell = composite <= -adaptive_thresh and enough_bear_agree and chop_ok

// Anti-whipsaw: an opposite-direction signal arriving soon after the last one
// needs extra strength (composite * sig_reversal_mul) to fire
buy_is_reversal  = raw_buy  and last_signal_dir == -1 and bars_since_signal < sig_min_gap * 2
sell_is_reversal = raw_sell and last_signal_dir ==  1 and bars_since_signal < sig_min_gap * 2
reversal_ok_buy  = not buy_is_reversal  or composite >=  adaptive_thresh * sig_reversal_mul
reversal_ok_sell = not sell_is_reversal or composite <= -adaptive_thresh * sig_reversal_mul

gated_buy  = raw_buy  and bars_since_signal >= sig_min_gap and reversal_ok_buy
gated_sell = raw_sell and bars_since_signal >= sig_min_gap and reversal_ok_sell

if gated_buy or gated_sell
    last_signal_bar := bar_index
    last_signal_dir := gated_buy ? 1 : -1


// ─────────────────────────────────────────
// SECTION 5: CHART PATTERN DETECTION (unchanged from v4)
// ─────────────────────────────────────────

pat_size = pat_label_size == "tiny" ? size.tiny : pat_label_size == "small" ? size.small : size.normal

body      = math.abs(close - open)
upper_shd = high - math.max(close, open)
lower_shd = math.min(close, open) - low
full_range = high - low
is_bull   = close > open
is_bear   = close < open
avg_body  = ta.sma(body, 14)

// 1. HAMMER
hammer_body   = body < full_range * 0.35
hammer_lshd   = lower_shd > body * 2.0
hammer_ushd   = upper_shd < body * 0.5
hammer_down   = close[1] < close[2] and close[2] < close[3]
pat_hammer    = hammer_body and hammer_lshd and hammer_ushd and hammer_down and full_range > 0

// 2. SHOOTING STAR
star_body     = body < full_range * 0.35
star_ushd     = upper_shd > body * 2.0
star_lshd     = lower_shd < body * 0.5
star_up       = close[1] > close[2] and close[2] > close[3]
pat_star      = star_body and star_ushd and star_lshd and star_up and full_range > 0

// 3. BULLISH ENGULFING
eng_bull_prev = is_bear[1] and body[1] > avg_body * 0.3
eng_bull_curr = is_bull and body > body[1] * 1.1
eng_bull_wrap = open <= close[1] and close >= open[1]
eng_bull_down = close[2] < close[3]
pat_engulf_bull = eng_bull_prev and eng_bull_curr and eng_bull_wrap and eng_bull_down

// 4. BEARISH ENGULFING
eng_bear_prev = is_bull[1] and body[1] > avg_body * 0.3
eng_bear_curr = is_bear and body > body[1] * 1.1
eng_bear_wrap = open >= close[1] and close <= open[1]
eng_bear_up   = close[2] > close[3]
pat_engulf_bear = eng_bear_prev and eng_bear_curr and eng_bear_wrap and eng_bear_up

// 5. MORNING STAR
ms_first  = is_bear[2] and body[2] > avg_body
ms_middle = body[1] < avg_body * 0.5
ms_last   = is_bull and body > avg_body * 0.7
ms_close  = close > (open[2] + close[2]) / 2
pat_morning_star = ms_first and ms_middle and ms_last and ms_close

// 6. EVENING STAR
es_first  = is_bull[2] and body[2] > avg_body
es_middle = body[1] < avg_body * 0.5
es_last   = is_bear and body > avg_body * 0.7
es_close  = close < (open[2] + close[2]) / 2
pat_evening_star = es_first and es_middle and es_last and es_close

// 7. THREE WHITE SOLDIERS
tws_1 = is_bull[2] and body[2] > avg_body * 0.5
tws_2 = is_bull[1] and body[1] > avg_body * 0.5 and open[1] > open[2] and close[1] > close[2]
tws_3 = is_bull    and body    > avg_body * 0.5 and open    > open[1] and close    > close[1]
tws_open_in = open[1] <= close[2] and open <= close[1]
pat_three_soldiers = tws_1 and tws_2 and tws_3 and tws_open_in

// 8. THREE BLACK CROWS
tbc_1 = is_bear[2] and body[2] > avg_body * 0.5
tbc_2 = is_bear[1] and body[1] > avg_body * 0.5 and open[1] < open[2] and close[1] < close[2]
tbc_3 = is_bear    and body    > avg_body * 0.5 and open    < open[1] and close    < close[1]
tbc_open_in = open[1] >= close[2] and open >= close[1]
pat_three_crows = tbc_1 and tbc_2 and tbc_3 and tbc_open_in

// 9. DOUBLE BOTTOM
db_low1      = ta.lowest(low, pat_lookback)
db_low1_bar  = ta.barssince(low == db_low1)
db_tolerance = ta.atr(14) * 0.5
int db_safe_len = na(db_low1_bar) ? 1 : math.max(1, math.min(db_low1_bar, pat_lookback))
db_near_low  = math.abs(low - db_low1) < db_tolerance
db_bounce    = ta.highest(high, db_safe_len) > db_low1 + ta.atr(14) * 1.5
db_separated = not na(db_low1_bar) and db_low1_bar > 5 and db_low1_bar < pat_lookback
db_reversal  = close > close[1] and close > open
pat_double_bottom = db_near_low and db_bounce and db_separated and db_reversal

// 10. DOUBLE TOP
dt_high1     = ta.highest(high, pat_lookback)
dt_high1_bar = ta.barssince(high == dt_high1)
dt_near_high = math.abs(high - dt_high1) < db_tolerance
int dt_safe_len = na(dt_high1_bar) ? 1 : math.max(1, math.min(dt_high1_bar, pat_lookback))
dt_dip       = ta.lowest(low, dt_safe_len) < dt_high1 - ta.atr(14) * 1.5
dt_separated = not na(dt_high1_bar) and dt_high1_bar > 5 and dt_high1_bar < pat_lookback
dt_reversal  = close < close[1] and close < open
pat_double_top = dt_near_high and dt_dip and dt_separated and dt_reversal

// 11. BULL FLAG
pole_up      = close[5] > close[10] and (close[5] - close[10]) > ta.atr(14) * 2.0
flag_drift   = high < high[1] and high[1] < high[2]
flag_tight   = ta.stdev(close, 5) < ta.stdev(close[5], 5) * 0.6
flag_break   = close > high[1]
pat_bull_flag = pole_up and flag_drift[1] and flag_tight and flag_break

// 12. BEAR FLAG
pole_down    = close[5] < close[10] and (close[10] - close[5]) > ta.atr(14) * 2.0
flag_drift_d = low > low[1] and low[1] > low[2]
flag_tight_d = ta.stdev(close, 5) < ta.stdev(close[5], 5) * 0.6
flag_break_d = close < low[1]
pat_bear_flag = pole_down and flag_drift_d[1] and flag_tight_d and flag_break_d

// ── PATTERN LABELS ──
if show_patterns
    if pat_hammer
        label.new(bar_index, low, "Hammer", style=label.style_label_up, color=color.new(color.teal, 30), textcolor=color.white, size=pat_size, yloc=yloc.belowbar)
    if pat_star
        label.new(bar_index, high, "Shooting Star", style=label.style_label_down, color=color.new(color.maroon, 30), textcolor=color.white, size=pat_size, yloc=yloc.abovebar)
    if pat_engulf_bull
        label.new(bar_index, low, "Bull Engulf", style=label.style_label_up, color=color.new(color.teal, 30), textcolor=color.white, size=pat_size, yloc=yloc.belowbar)
    if pat_engulf_bear
        label.new(bar_index, high, "Bear Engulf", style=label.style_label_down, color=color.new(color.maroon, 30), textcolor=color.white, size=pat_size, yloc=yloc.abovebar)
    if pat_morning_star
        label.new(bar_index, low, "Morning Star", style=label.style_label_up, color=color.new(color.green, 20), textcolor=color.white, size=pat_size, yloc=yloc.belowbar)
    if pat_evening_star
        label.new(bar_index, high, "Evening Star", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=pat_size, yloc=yloc.abovebar)
    if pat_three_soldiers
        label.new(bar_index, low, "3 Soldiers", style=label.style_label_up, color=color.new(color.green, 20), textcolor=color.white, size=pat_size, yloc=yloc.belowbar)
    if pat_three_crows
        label.new(bar_index, high, "3 Crows", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=pat_size, yloc=yloc.abovebar)
    if pat_double_bottom
        label.new(bar_index, low, "Double Bottom", style=label.style_label_up, color=color.new(color.lime, 20), textcolor=color.black, size=pat_size, yloc=yloc.belowbar)
    if pat_double_top
        label.new(bar_index, high, "Double Top", style=label.style_label_down, color=color.new(color.fuchsia, 20), textcolor=color.white, size=pat_size, yloc=yloc.abovebar)
    if pat_bull_flag
        label.new(bar_index, low, "Bull Flag", style=label.style_label_up, color=color.new(color.lime, 20), textcolor=color.black, size=pat_size, yloc=yloc.belowbar)
    if pat_bear_flag
        label.new(bar_index, high, "Bear Flag", style=label.style_label_down, color=color.new(color.fuchsia, 20), textcolor=color.white, size=pat_size, yloc=yloc.abovebar)


// ─────────────────────────────────────────
// SECTION 6: VISUALS
// ─────────────────────────────────────────

// SMA Levels
plot(sma1_show ? sma1 : na, "SMA 1", color=color.new(color.yellow, 10),  linewidth=1)
plot(sma2_show ? sma2 : na, "SMA 2", color=color.new(color.orange, 10),  linewidth=1)
plot(sma3_show ? sma3 : na, "SMA 3", color=color.new(color.fuchsia, 10), linewidth=1)
plot(sma4_show ? sma4 : na, "SMA 4", color=color.new(color.blue, 10),    linewidth=2)
plot(sma5_show ? sma5 : na, "SMA 5", color=color.new(color.maroon, 10),  linewidth=2)

// SMA proximity label — single combined label listing every SMA the price just touched
if sma_show_labels
    string sma_near_txt = ""
    if near1_new
        sma_near_txt += "SMA" + str.tostring(sma1_len) + " "
    if near2_new
        sma_near_txt += "SMA" + str.tostring(sma2_len) + " "
    if near3_new
        sma_near_txt += "SMA" + str.tostring(sma3_len) + " "
    if near4_new
        sma_near_txt += "SMA" + str.tostring(sma4_len) + " "
    if near5_new
        sma_near_txt += "SMA" + str.tostring(sma5_len) + " "

    if sma_near_txt != ""
        label.new(bar_index, high, "⟷ Near " + str.trim(sma_near_txt),
             style=label.style_label_down,
             color=color.new(color.gray, 20),
             textcolor=color.white,
             size=size.tiny,
             yloc=yloc.abovebar)

// Buy signal
plotshape(gated_buy,
     title="Buy Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.lime, 0),
     size=size.normal,
     text="BUY")

// Sell signal
plotshape(gated_sell,
     title="Sell Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     size=size.normal,
     text="SELL")

// Bar coloring
bar_bull_strong = composite >  adaptive_thresh * 0.7
bar_bear_strong = composite < -adaptive_thresh * 0.7
bar_color = bar_bull_strong ? color.new(color.lime, 70) : bar_bear_strong ? color.new(color.red, 70) : na
barcolor(bar_color)

// Signal labels
if show_labels and gated_buy
    label.new(bar_index, low,
         "▲ " + str.tostring(math.round(composite * 100)) + "% [" + str.tostring(bull_agree) + "/7]",
         style=label.style_label_up,
         color=color.new(color.lime, 20),
         textcolor=color.white,
         size=size.small)

if show_labels and gated_sell
    label.new(bar_index, high,
         "▼ " + str.tostring(math.round(math.abs(composite) * 100)) + "% [" + str.tostring(bear_agree) + "/7]",
         style=label.style_label_down,
         color=color.new(color.red, 20),
         textcolor=color.white,
         size=size.small)

// ── Volume Intelligence: Regime Shift Labels (NEW) ──
if vi_enabled and vi_show_labels
    if shift_sell_to_buy
        label.new(bar_index, low,
             "🔄 SELL→BUY\nDelta Shift",
             style=label.style_label_up,
             color=color.new(#00E676, 10),
             textcolor=color.black,
             size=size.normal,
             yloc=yloc.belowbar)
        alert("🟢 REGIME SHIFT: Selling → Buying pressure detected on " + syminfo.tickerid, alert.freq_once_per_bar)

    if shift_buy_to_sell
        label.new(bar_index, high,
             "🔄 BUY→SELL\nDelta Shift",
             style=label.style_label_down,
             color=color.new(#FF1744, 10),
             textcolor=color.white,
             size=size.normal,
             yloc=yloc.abovebar)
        alert("🔴 REGIME SHIFT: Buying → Selling pressure detected on " + syminfo.tickerid, alert.freq_once_per_bar)

    // Anomaly labels (large unexpected volume bursts)
    if anomaly_buy and not shift_sell_to_buy
        label.new(bar_index, low,
             "⚡ Buy Spike\nZ:" + str.tostring(math.round(delta_zscore * 10) / 10),
             style=label.style_label_up,
             color=color.new(#00BFA5, 30),
             textcolor=color.white,
             size=size.tiny,
             yloc=yloc.belowbar)

    if anomaly_sell and not shift_buy_to_sell
        label.new(bar_index, high,
             "⚡ Sell Spike\nZ:" + str.tostring(math.round(delta_zscore * 10) / 10),
             style=label.style_label_down,
             color=color.new(#D50000, 30),
             textcolor=color.white,
             size=size.tiny,
             yloc=yloc.abovebar)


// ─────────────────────────────────────────
// SECTION 7: DASHBOARD TABLE (updated for 7 strategies + VI metrics)
// ─────────────────────────────────────────

f_score_color(float s) =>
    s > 0.2 ? color.green : s < -0.2 ? color.red : color.new(#888888, 0)

if show_dash and barstate.islast
    var table dash = table.new(
         position.top_right, 4, 13,
         bgcolor=color.new(color.white, 0),
         border_color=color.new(#D0D0D0, 0),
         border_width=1,
         frame_color=color.new(#B0B0B0, 0),
         frame_width=1)

    // ── Colors for white background ──
    color hdr_bg  = color.new(#F0F0F0, 0)
    color hdr_txt = color.new(#555555, 0)
    color lbl_txt = color.new(#333333, 0)
    color val_txt = color.new(#222222, 0)
    color dim_txt = color.new(#888888, 0)
    color sep_txt = color.new(#CCCCCC, 0)

    // Header
    table.cell(dash, 0, 0, "Strategy",  text_color=hdr_txt, text_size=size.small, bgcolor=hdr_bg)
    table.cell(dash, 1, 0, "Score",     text_color=hdr_txt, text_size=size.small, bgcolor=hdr_bg)
    table.cell(dash, 2, 0, "Accuracy",  text_color=hdr_txt, text_size=size.small, bgcolor=hdr_bg)
    table.cell(dash, 3, 0, "Weight",    text_color=hdr_txt, text_size=size.small, bgcolor=hdr_bg)

    // VWAP
    table.cell(dash, 0, 1, "VWAP",         text_color=lbl_txt, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(math.round(vwap_score * 100) / 100, "#.##"),
         text_color=f_score_color(vwap_score), text_size=size.small)
    table.cell(dash, 2, 1, str.tostring(math.round(acc_vwap * 100)) + "%",
         text_color=acc_vwap > 0.55 ? color.green : color.new(#CC7700, 0), text_size=size.small)
    table.cell(dash, 3, 1, str.tostring(math.round(w_vwap_n * 100)) + "%",
         text_color=val_txt, text_size=size.small)

    // Volume Intelligence
    vi_status_txt = not vi_enabled ? "OFF" : fp_available ? "FP" : "EST"
    vi_status_clr = not vi_enabled ? dim_txt : fp_available ? color.green : color.new(#CC7700, 0)
    table.cell(dash, 0, 2, "VolIntel " + vi_status_txt, text_color=vi_status_clr, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(math.round(vi_score * 100) / 100, "#.##"),
         text_color=f_score_color(vi_score), text_size=size.small)
    table.cell(dash, 2, 2, str.tostring(math.round(acc_vi * 100)) + "%",
         text_color=acc_vi > 0.55 ? color.green : color.new(#CC7700, 0), text_size=size.small)
    table.cell(dash, 3, 2, str.tostring(math.round(w_vi_n * 100)) + "%",
         text_color=val_txt, text_size=size.small)

    // Separator
    table.cell(dash, 0, 3, "─────", text_color=sep_txt, text_size=size.tiny)
    table.cell(dash, 1, 3, "─────", text_color=sep_txt, text_size=size.tiny)
    table.cell(dash, 2, 3, "─────", text_color=sep_txt, text_size=size.tiny)
    table.cell(dash, 3, 3, "─────", text_color=sep_txt, text_size=size.tiny)

    // Composite
    composite_color = composite > adaptive_thresh ? color.green : composite < -adaptive_thresh ? color.red : dim_txt
    table.cell(dash, 0, 4, "Composite",   text_color=lbl_txt, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(math.round(composite * 100) / 100, "#.##"),
         text_color=composite_color, text_size=size.small)
    table.cell(dash, 2, 4, "Threshold",   text_color=dim_txt, text_size=size.small)
    table.cell(dash, 3, 4, str.tostring(math.round(adaptive_thresh * 100) / 100, "#.##"),
         text_color=val_txt, text_size=size.small)

    // Agreement
    agree_count = composite >= 0 ? bull_agree : bear_agree
    agree_color = agree_count >= sig_min_agree ? color.green : agree_count >= sig_min_agree - 1 ? color.new(#CC7700, 0) : color.red
    table.cell(dash, 0, 5, "Agreement",   text_color=lbl_txt, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(agree_count) + "/7",
         text_color=agree_color, text_size=size.small)
    table.cell(dash, 2, 5, "Need:",       text_color=dim_txt,  text_size=size.small)
    table.cell(dash, 3, 5, str.tostring(sig_min_agree) + "/7",
         text_color=val_txt, text_size=size.small)

    // Signal
    sig_txt   = gated_buy ? "BUY" : gated_sell ? "SELL" : "HOLD"
    sig_color = gated_buy ? color.green : gated_sell ? color.red : dim_txt
    table.cell(dash, 0, 6, "Signal",      text_color=lbl_txt, text_size=size.small)
    table.cell(dash, 1, 6, sig_txt,       text_color=sig_color,   text_size=size.small)
    table.cell(dash, 2, 6, "Bars since:", text_color=dim_txt,  text_size=size.small)
    table.cell(dash, 3, 6, str.tostring(bars_since_signal),
         text_color=val_txt, text_size=size.small)

    // ML
    ml_status = ml_enabled ? "ON" : "OFF"
    table.cell(dash, 0, 7, "ML Engine",   text_color=lbl_txt,     text_size=size.small)
    table.cell(dash, 1, 7, ml_status,     text_color=ml_enabled ? color.green : dim_txt, text_size=size.small)
    table.cell(dash, 2, 7, "Learn rate:", text_color=dim_txt,       text_size=size.small)
    table.cell(dash, 3, 7, str.tostring(ml_learn_rate),
         text_color=val_txt, text_size=size.small)

    // ── Volume Intelligence Detail ──
    table.cell(dash, 0, 8, "─── Vol Intel ───", text_color=color.new(#0088AA, 0), text_size=size.tiny)
    table.cell(dash, 1, 8, "─────", text_color=sep_txt, text_size=size.tiny)
    table.cell(dash, 2, 8, "─────", text_color=sep_txt, text_size=size.tiny)
    table.cell(dash, 3, 8, "─────", text_color=sep_txt, text_size=size.tiny)

    // Regime
    regime_txt = regime == 1 ? "ACCUM" : regime == -1 ? "DISTRIB" : "NEUTRAL"
    regime_clr = regime == 1 ? color.green : regime == -1 ? color.red : dim_txt
    table.cell(dash, 0, 9, "Regime",      text_color=lbl_txt, text_size=size.small)
    table.cell(dash, 1, 9, regime_txt,    text_color=regime_clr,  text_size=size.small)
    table.cell(dash, 2, 9, "Delta Z:",    text_color=dim_txt,  text_size=size.small)
    table.cell(dash, 3, 9, str.tostring(math.round(delta_zscore * 100) / 100, "#.##"),
         text_color=math.abs(delta_zscore) > vi_zscore_th ? color.new(#CC7700, 0) : val_txt, text_size=size.small)

    // Buy/Sell volume
    buy_pct = (raw_buy_volume + raw_sell_volume) > 0 ? raw_buy_volume / (raw_buy_volume + raw_sell_volume) * 100 : 50
    table.cell(dash, 0, 10, "Buy Pressure", text_color=lbl_txt, text_size=size.small)
    table.cell(dash, 1, 10, str.tostring(math.round(buy_pct)) + "%",
         text_color=buy_pct > 55 ? color.green : buy_pct < 45 ? color.red : dim_txt, text_size=size.small)
    table.cell(dash, 2, 10, "Consec:",     text_color=dim_txt,  text_size=size.small)
    consec_txt = consec_buy_bars > 0 ? str.tostring(consec_buy_bars) + "B" : str.tostring(consec_sell_bars) + "S"
    table.cell(dash, 3, 10, consec_txt,
         text_color=consec_buy_bars > 0 ? color.green : color.red, text_size=size.small)

    // Volatility
    vol_txt = vol_regime_atr > 1.5 ? "HIGH" : vol_regime_atr > 0.8 ? "NORMAL" : "LOW"
    vol_color2 = vol_regime_atr > 1.5 ? color.new(#CC7700, 0) : vol_regime_atr > 0.8 ? color.green : dim_txt
    table.cell(dash, 0, 11, "Volatility",  text_color=lbl_txt, text_size=size.small)
    table.cell(dash, 1, 11, vol_txt,       text_color=vol_color2,   text_size=size.small)
    table.cell(dash, 2, 11, "ATR ratio:",  text_color=dim_txt,  text_size=size.small)
    table.cell(dash, 3, 11, str.tostring(math.round(vol_regime_atr * 100) / 100, "#.##"),
         text_color=val_txt, text_size=size.small)

    // Trend strength / chop filter
    chop_txt = chop_ok ? "TRENDING" : "CHOPPY"
    chop_clr = chop_ok ? color.green : color.new(#CC7700, 0)
    table.cell(dash, 0, 12, "Chop Filter",  text_color=lbl_txt, text_size=size.small)
    table.cell(dash, 1, 12, sig_use_adx ? chop_txt : "OFF",
         text_color=sig_use_adx ? chop_clr : dim_txt, text_size=size.small)
    table.cell(dash, 2, 12, "ADX:",        text_color=dim_txt,  text_size=size.small)
    table.cell(dash, 3, 12, str.tostring(math.round(adx_val * 10) / 10, "#.#"),
         text_color=adx_val >= sig_adx_min ? color.green : color.new(#CC7700, 0), text_size=size.small)


// ─────────────────────────────────────────
// SECTION 8: ALERTS
// ─────────────────────────────────────────

// Existing signal alerts
alertcondition(gated_buy,  "SignalForge BUY",  "SFv5 BUY signal on {{ticker}}")
alertcondition(gated_sell, "SignalForge SELL", "SFv5 SELL signal on {{ticker}}")

// NEW: Volume Intelligence alerts
// alertcondition requires const string — use static messages here
alertcondition(shift_buy_to_sell, "Vol: Buy→Sell Shift",  "🔴 Volume regime shifted from BUYING to SELLING on {{ticker}}")
alertcondition(shift_sell_to_buy, "Vol: Sell→Buy Shift",  "🟢 Volume regime shifted from SELLING to BUYING on {{ticker}}")
alertcondition(anomaly_buy,      "Vol: Anomaly Buy Spike",  "⚡ Anomalous buying volume spike detected on {{ticker}}")
alertcondition(anomaly_sell,     "Vol: Anomaly Sell Spike", "⚡ Anomalous selling volume spike detected on {{ticker}}")

// Dynamic alerts with Z-score detail (these fire via alert() which accepts series string)
if anomaly_buy
    alert("⚡ Anomalous buying volume spike on " + syminfo.tickerid + " (Z-score: " + str.tostring(math.round(delta_zscore * 10) / 10) + ")", alert.freq_once_per_bar)
if anomaly_sell
    alert("⚡ Anomalous selling volume spike on " + syminfo.tickerid + " (Z-score: " + str.tostring(math.round(delta_zscore * 10) / 10) + ")", alert.freq_once_per_bar)
````
