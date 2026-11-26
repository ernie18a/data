# Premium/Discount ML Zones [PickMyTrade]

- url: https://www.tradingview.com/script/WWhSIUzy-Premium-Discount-ML-Zones-PickMyTrade/
- type: indicator
- pine_id: PUB;2362fbd6fdd6428fb227d304564abf99
- version: 1.0

## Description

[b]What does it do?[/b]

Builds a Premium / Equilibrium / Discount map from a [i]higher-timeframe[/i] dealing range, then runs an online logistic regression over every price level inside that map to detect the exact band where the model currently reads a directional edge. Because the range is read from one anchor timeframe, the zones sit at the same prices whether you view the 5m, 1h or Daily chart.

────────────────────────────────────

[b]The intellectual problem[/b]

Premium/Discount is a location framework: above the 50% equilibrium of a dealing range price is expensive, below it price is cheap. Two problems show up the moment you try to automate it.

[b]First — the range is usually drawn on whatever chart you are looking at.[/b] A 5-minute chart finds 5-minute swings, so it anchors to a micro-range that may be a few points wide. The Daily chart finds a range a hundred times larger. The same price is then simultaneously "premium" on one timeframe and "discount" on another, and the label stops meaning anything. The conventional discipline is to define the range on a higher timeframe and drop down only to execute — never to redraw the range on the execution chart.

[b]Second — location alone is not an edge.[/b] Knowing price is in the lower half of a range tells you it is cheap relative to that range. It does not tell you whether cheapness is currently being rewarded. In a strong downtrend every discount print keeps getting cheaper. Location is a filter; something else has to decide whether the location is worth acting on.

This indicator separates those two jobs. The dealing range and its three zones are the [i]map[/i], anchored once on a higher timeframe. A logistic regression trained on the chart's own history is the [i]decision[/i], and it is what marks the actionable band inside the map.

────────────────────────────────────

[b]How the dealing range is anchored[/b]

The range is built from confirmed swing highs and lows read from the Dealing Range Timeframe (default Daily) via [pine]request.security(..., lookahead=barmerge.lookahead_off)[/pine]. Each side re-anchors to its most recent confirmed swing, with guards that keep the pair coherent:

[pine]if not na(ph) and (na(swingLow) or ph > swingLow) swingHigh := ph if not na(pl) and (na(swingHigh) or pl < swingHigh) swingLow := pl[/pine]

Those guards are what make the range track the current leg rather than a fixed lookback window. In an uptrend each new higher low pulls the low side up with price, instead of leaving equilibrium pinned to an ancient low that price has long since left behind.

From that range:

[list] [] [b]Equilibrium[/b] — the exact 50% midpoint, [pine](rangeHigh + rangeLow) / 2[/pine] [] [b]Equilibrium band[/b] — a neutral fair-value zone of ±[i]Equilibrium Band[/i] × range around the midpoint (default ±10%, i.e. the middle 20%). No signals fire inside it. [*] [b]Premium[/b] — everything above the band. [b]Discount[/b] — everything below it. [/list]

[b]Break of structure[/b] — when price closes beyond the anchored range, the old range is stale until a new swing confirms. A bearish BOS blocks longs and a bullish BOS blocks shorts, so the model does not fade a breakout while waiting for the range to re-anchor.

────────────────────────────────────

[b]How the logistic regression works[/b]

[b]Step 1 — Three z-score normalised features[/b]

All three are standardised over the Z-Score Window (default 50) so the model is scale-invariant across instruments and timeframes.

[list] [] [b]F1 — Position in range[/b]: where the close sits between the range low and high, clamped to 0–1. This is the premium/discount coordinate itself. [] [b]F2 — Dwell time[/b]: a rolling time-at-price measure — the fraction of the last N bars that closed within one price band of the current close. High dwell means price has spent real time here; a level touched once in a spike scores low. [*] [b]F3 — Momentum[/b]: rate of change over the momentum length, normalised. Distinguishes a discount that is stabilising from one that is still falling. [/list]

[b]Step 2 — Online gradient descent with L2 regularization[/b]

There is no fixed training window and no retraining pass. Each confirmed bar is labelled from its forward return over the Label Horizon, and the weights take one gradient step per bar, always evaluated on the [i]previous[/i] bar's features so no current-bar information leaks into the update:

[pine]_pred = f_sigmoid(w0 + w1f1[1] + w2f2[1] + w3*f3[1]) _label = label_bull[1] ? 1.0 : 0.0 _err = _label - _pred w1 := w1 + i_learn_rate * (_err * f1[1] - i_l2_lambda * w1)[/pine]

The [pine]- i_l2_lambda * w1[/pine] term is weight decay: it pulls weights back toward zero each step, which stops any single feature from running away to an extreme value on a stretch of trending data. The bias term [pine]w0[/pine] is deliberately left unregularized — it carries the base rate, not a feature relationship.

[b]Step 3 — Posterior[/b]

[pine]post_bull = f_sigmoid(w0 + w1f1 + w2f2 + w3*f3) post_bear = 1.0 - post_bull[/pine]

[b]Step 4 — The ML entry zone (what the model detects)[/b]

This is the part that does the work. Rather than only scoring the bar in front of it, the model scores [i]every price level[/i] inside the discount half and the premium half — sweeping the position feature across the zone while holding dwell and momentum at their current values — and marks the contiguous band where its probability clears the Entry Threshold:

[pine]for j = 0 to i_nbins float p = rangeLow + (eq_bot - rangeLow) * j / i_nbins float f1p = ((p - rangeLow) / range_size - pos_mean) / pos_std float pbup = f_sigmoid(base + w1 * f1p) if pbup >= i_posterior_thresh ml_long_lo := na(ml_long_lo) ? p : math.min(ml_long_lo, p) ml_long_hi := na(ml_long_hi) ? p : math.max(ml_long_hi, p)[/pine]

That band is the [b]ML Buy / Sell Zone[/b] drawn on the chart. It is the exact price range in which a signal would fire right now — visible [i]before[/i] price arrives there. Its thickness is meaningful: a thin band means only a sliver of the zone clears the threshold, a thick band means the model reads an edge across most of the zone. When nothing clears the threshold, the band disappears entirely rather than showing a level the model does not support.

────────────────────────────────────

[b]Reading the indicator[/b]

[list] [] [b]PREMIUM box (orange)[/b] — upper region of the HTF range. Shorts are considered here only. [] [b]EQUILIBRIUM box (grey)[/b] — the fair-value band around the 50% midpoint. Nothing fires here by design. [] [b]DISCOUNT box (blue)[/b] — lower region. Longs are considered here only. [] [b]ML BUY / SELL ZONE (bright band)[/b] — the model-detected band inside the discount/premium region, labelled with the peak probability found in that band. [] [b]● circle (blue)[/b] — high-conviction long: P(Bull) ≥ 0.85. [b]▲ triangle (blue)[/b] — standard long: P(Bull) ≥ threshold. [] [b]● circle (orange)[/b] — high-conviction short: P(Bear) ≥ 0.85. [b]▼ triangle (orange)[/b] — standard short: P(Bear) ≥ threshold. [] [b]Dashed equilibrium line[/b] — the exact 50% midpoint. [] [b]Dashed SL / TP lines[/b] — reference levels from the range extreme at ATR × multiplier and the Risk:Reward ratio. [/list]

[b]Only the first bar of each signal cluster fires[/b] — if conditions stay true for several bars, only the transition bar is marked.

[b]Info table (top-right)[/b]

[list] [] [b]● LIVE[/b] (green) — the model has taken ≥ Training Samples Needed gradient steps. [b]● WARMUP[/b] (yellow) — still accumulating; signals suppressed. [] [b]Zone[/b] — Premium / Equilibrium / Discount, or [b]BOS ↑ / BOS ↓[/b] (yellow) when price has broken the range. [] [b]P(Bull) / P(Bear)[/b] — live posterior at the current bar. [] [b]N Trained[/b] — total gradient updates taken. [/list]

────────────────────────────────────

[b]Inputs[/b]

[b]Dealing Range[/b] [list] [] [b]Dealing Range Timeframe[/b] — whose swings define the map (default D). Set it equal to or higher than your execution chart. This is the input that makes the zones identical across timeframes. [] [b]Swing Left / Right Bars[/b] — swing definition on the anchor timeframe (default 3/3). Right Bars is the confirmation delay: the range re-anchors that many anchor-timeframe bars after a swing forms. [*] [b]Equilibrium Band[/b] — half-width of the neutral zone as a fraction of range (default 0.10). Set 0 to collapse it to a single line. [/list]

[b]Dwell-Time Feature[/b] [list] [*] Scan / Dwell Bands (default 20) — price resolution for the entry-zone scan and the dwell band width. Dwell Lookback (default 50). [/list]

[b]Logistic Regression[/b] [list] [] [b]Training Samples Needed[/b] — gradient updates before signals activate (default 80). [] [b]Entry Threshold[/b] — minimum probability to fire a signal and to light the ML zone (default 0.65). [] [b]Learning Rate[/b] — gradient step size (default 0.05). Higher adapts faster but noisier. [] [b]L2 Regularization[/b] — weight decay (default 0.001). 0 disables it. [*] Label Horizon (default 5), Momentum Length (default 14), Z-Score Window (default 50). [/list]

[b]Signal Levels[/b] [list] [*] Show SL/TP Lines, ATR Period, SL ATR Buffer (default 1.2), Risk:Reward (default 1.8). [/list]

[b]Visual / Display[/b] [list] [] Show Premium/Discount Map, Show ML Entry Zone, Zone Left Extent / Forward Extend, Show Equilibrium Line, Regime Background, zone colours. [] [b]Zen Mode[/b] — hides SL/TP lines and the table; map and ML zone remain. [/list]

────────────────────────────────────

[b]Three alerts included[/b]

[list] [] PD ML - Long — discount long fired [] PD ML - Short — premium short fired [*] PD ML - Any Signal — either direction [/list]

────────────────────────────────────

[b]Technical notes[/b]

[list] [] Swing detection on the anchor timeframe needs Swing Right Bars of that timeframe to confirm. With the Daily default that is a three-day confirmation delay before the range re-anchors. This is inherent to non-repainting swing detection, not a tunable away. [] [pine]request.security[/pine] uses [pine]lookahead_off[/pine], so historical bars use only confirmed anchor-timeframe values. The developing anchor bar updates in real time, which is expected behaviour for a live higher-timeframe reference. [] The dwell feature counts closes within one band of the current close over the lookback — a bar-based proxy for time-at-price. It does not use tick or volume-profile data. [] The entry-zone scan holds dwell and momentum fixed while sweeping position. It answers "if price were at level X, with today's momentum and dwell, what would the model read?" — a counterfactual across location, not a forecast of the path. [*] Logistic regression assumes a monotonic relationship between each feature and the log-odds. Real price behaviour is not always monotonic in position-within-range; the model captures the dominant direction of that relationship, not its curvature. [/list]

────────────────────────────────────

[b]Requirements and limitations[/b]

The model needs Training Samples Needed gradient steps before signals activate; on short-history charts the table shows WARMUP and nothing fires. Weights are learned per chart and per timeframe — switching symbol or timeframe restarts the learning from zero.

Probabilities are the model's read of patterns in its own training history. They are not a probability of profit, and patterns that historically preceded a directional move may not repeat.

The equilibrium band is deliberately dead space. If you want signals nearer the midpoint, reduce the band toward 0 — but the closer to fair value you trade, the less the premium/discount premise is contributing.

If the Dealing Range Timeframe is left blank or set below your chart's timeframe, the range is computed on the chart timeframe and the cross-timeframe consistency is lost. That is the failure mode this indicator exists to avoid.

The three zones describe location within one dealing range. They carry no information about ranges above them — a Daily discount can sit inside a Weekly premium.

────────────────────────────────────

[b]Risk disclosure[/b]

Nothing here forecasts price. The zones describe where price sits inside a measured range; the classifier reports what its training history associates with that location. Use with your own position sizing and risk management. Not financial advice.

[i]Built natively in Pine Script® v6. Online logistic regression trained by per-bar gradient descent with L2 weight decay, a rolling dwell-time feature, and a higher-timeframe swing-anchored dealing range. No external libraries, no data feeds.[/i]

[i]Open source — Mozilla Public License 2.0.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © PickMyTrade — Premium/Discount ML Zones [PickMyTrade]: HTF Dealing Range + Online Logistic Regression

//@version=6
indicator(
    title            = "Premium/Discount ML Zones [PickMyTrade]",
    shorttitle       = "PD ML",
    overlay          = true,
    max_boxes_count  = 30,
    max_lines_count  = 30,
    max_labels_count = 30,
    max_bars_back    = 500
)

var string G_RANGE = "Dealing Range"
var string G_DWELL = "Dwell-Time Feature"
var string G_ML    = "Logistic Regression"
var string G_RISK  = "Signal Levels"
var string G_VIS   = "Visual"
var string G_ZEN   = "Display"

i_range_tf  = input.timeframe("D", "Dealing Range Timeframe", group=G_RANGE, tooltip="Whose swings define the Premium & Discount halves. Because the range is read from THIS timeframe, the map stays at the same prices no matter which chart timeframe you view. Set it EQUAL TO OR HIGHER than your execution chart (e.g. Daily range while executing on 5m). Blank = use the chart timeframe (not recommended — micro ranges on low timeframes are what make Premium/Discount meaningless).")
i_piv_left  = input.int(3, "Swing Left Bars", minval=1, maxval=20, group=G_RANGE, tooltip="Bars to the LEFT of a swing point, counted on the Dealing Range Timeframe. Larger = only bigger, rarer swings anchor the range.")
i_piv_right = input.int(3, "Swing Right Bars", minval=1, maxval=20, group=G_RANGE, tooltip="Bars to the RIGHT needed to CONFIRM a swing. This is the confirmation delay — the range re-anchors this many Dealing-Range-Timeframe bars after a swing forms. Keeps it non-repainting; larger = slower but more reliable anchors.")
i_eq_band   = input.float(0.10, "Equilibrium Band (± % of range)", minval=0.0, maxval=0.25, step=0.01, group=G_RANGE, tooltip="Half-width of the neutral Equilibrium zone around the 50% midpoint, as a fraction of the range. 0.10 = the middle 20% (40%–60%) is fair value — price there is neither cheap nor expensive, so NO signals fire in it. Set 0 to collapse it back to a single line.")

i_nbins    = input.int(20, "Scan / Dwell Bands", minval=5, maxval=50, group=G_DWELL, tooltip="Price-level resolution used both for the ML entry-zone scan and the dwell feature. Higher = finer bands.")
i_dwell_lb = input.int(50, "Dwell Lookback (bars)", minval=10, maxval=300, group=G_DWELL, tooltip="How many recent bars are scanned to measure time-at-price (ML feature F2).")

i_train_lookback   = input.int(80, "Training Samples Needed", minval=20, maxval=400, group=G_ML, tooltip="Gradient updates needed before signals and the ML zone are considered warmed up.")
i_posterior_thresh = input.float(0.65, "Entry Threshold", minval=0.51, maxval=0.95, step=0.01, group=G_ML, tooltip="Minimum model probability required to fire a signal and to light up the ML entry zone.")
i_learn_rate       = input.float(0.05, "Learning Rate", minval=0.001, maxval=0.5, step=0.001, group=G_ML, tooltip="Gradient-descent step size. Higher = faster but noisier.")
i_l2_lambda        = input.float(0.001, "L2 Regularization", minval=0.0, maxval=0.1, step=0.001, group=G_ML, tooltip="Weight decay. Prevents weights drifting to overfit extremes. 0 = off.")
i_label_period     = input.int(5, "Label Horizon (bars)", minval=2, maxval=30, group=G_ML, tooltip="Bars ahead used to build the training label.")
i_mom_len          = input.int(14, "Momentum Length", minval=3, maxval=60, group=G_ML, tooltip="Rate-of-change window for the momentum feature (F3).")
i_zscore_len       = input.int(50, "Z-Score Window", minval=10, maxval=200, group=G_ML, tooltip="Normalisation window applied to all three features.")

i_show_levels = input.bool(true, "Show SL / TP Lines", group=G_RISK)
i_atr_period  = input.int(14, "ATR Period", minval=5, maxval=50, group=G_RISK, tooltip="ATR period for the reference stop-loss buffer.")
i_sl_atr_mult = input.float(1.2, "SL ATR Buffer", minval=0.2, maxval=5.0, step=0.1, group=G_RISK, active=i_show_levels, tooltip="ATR buffer beyond the range extreme for the reference stop-loss.")
i_rr_ratio    = input.float(1.8, "Risk : Reward", minval=0.5, maxval=6.0, step=0.1, group=G_RISK, active=i_show_levels, tooltip="Reference take-profit distance as a multiple of the stop distance.")

i_show_zones  = input.bool(true, "Show Premium/Discount Map", group=G_VIS, tooltip="The faint upper (Premium) / lower (Discount) halves and the equilibrium line — the structural map.")
i_show_ote    = input.bool(true, "Show ML Entry Zone", group=G_VIS, tooltip="The bright band the model detects inside each half — the exact price range where a signal would currently fire.")
i_zone_back   = input.int(80, "Zone Left Extent (bars)", minval=10, maxval=500, group=G_VIS, tooltip="How many bars back the zones are drawn from the current bar.")
i_zone_extend = input.int(30, "Zone Forward Extend (bars)", minval=0, maxval=200, group=G_VIS, tooltip="How many bars past the current bar the zones project forward.")
i_show_eq     = input.bool(true, "Show Equilibrium Line", group=G_VIS)
i_show_bg     = input.bool(true, "Regime Background", group=G_VIS)
i_disc_col    = input.color(color.new(#2962FF, 82), "Discount Colour", group=G_VIS)
i_prem_col    = input.color(color.new(#FF6D00, 82), "Premium Colour", group=G_VIS)
i_eq_col      = input.color(#787B86, "Equilibrium Colour", group=G_VIS, tooltip="Neutral fill for the fair-value band between Premium and Discount.")

i_zen_mode   = input.bool(false, "Zen Mode", group=G_ZEN, tooltip="Hides the SL/TP lines and the info table. The map and ML zone remain.")
i_show_table = input.bool(true, "Show Info Table", group=G_ZEN)

// ── DEALING RANGE — anchored to CONFIRMED SWINGS on the anchor timeframe ───
// Each side re-anchors to its latest confirmed swing; the guards keep the pair
// coherent (high always above low), so in an uptrend each higher low pulls the
// range up with the leg instead of leaving it pinned to an ancient low. This is
// the structural range price actually reacted to — not an arbitrary lookback.
htf = i_range_tf == "" ? timeframe.period : i_range_tf
[ph, pl] = request.security(syminfo.tickerid, htf, [ta.pivothigh(i_piv_left, i_piv_right), ta.pivotlow(i_piv_left, i_piv_right)], lookahead=barmerge.lookahead_off)

var float swingHigh = na
var float swingLow  = na

if not na(ph) and (na(swingLow) or ph > swingLow)
    swingHigh := ph
if not na(pl) and (na(swingHigh) or pl < swingHigh)
    swingLow := pl

rangeHigh = swingHigh
rangeLow  = swingLow

range_valid = not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow
range_size  = range_valid ? rangeHigh - rangeLow : na
equilibrium = range_valid ? (rangeHigh + rangeLow) / 2 : na   // exact 50% midpoint

// Three zones, tiling the range with no gaps: Discount (cheap) / Equilibrium
// (fair value — no edge, no signals) / Premium (expensive).
eq_top = range_valid ? equilibrium + i_eq_band * range_size : na
eq_bot = range_valid ? equilibrium - i_eq_band * range_size : na

// Break of structure — price has left the anchored range; the old range is stale
// until a new swing confirms. Never fade a BOS: signals are blocked on that side.
bos_up = range_valid and close > rangeHigh
bos_dn = range_valid and close < rangeLow

in_discount = range_valid and close <= eq_bot        // cheap    = look for longs
in_premium  = range_valid and close >= eq_top        // expensive = look for shorts
in_equilib  = range_valid and not in_discount and not in_premium   // fair value = stand aside

// ── FEATURE 1 — position within the range ──────────────────────────────────
pos         = range_valid ? (close - rangeLow) / math.max(range_size, syminfo.mintick) : na
pos_clamped = na(pos) ? 0.0 : math.max(0.0, math.min(1.0, pos))
pos_mean    = ta.sma(pos_clamped, i_zscore_len)
pos_std     = ta.stdev(pos_clamped, i_zscore_len)
f1          = (range_valid and pos_std > 0) ? (pos_clamped - pos_mean) / pos_std : 0.0

// ── FEATURE 2 — dwell-time: rolling time-at-price around the current close ──
var float dwell_density = 0.0
if range_valid and range_size > 0
    float band = range_size / i_nbins
    int   cnt  = 0
    for i = 0 to i_dwell_lb - 1
        if not na(close[i]) and math.abs(close[i] - close) <= band
            cnt += 1
    dwell_density := (cnt * 1.0) / i_dwell_lb
else
    dwell_density := 0.0
dwell_mean = ta.sma(dwell_density, i_zscore_len)
dwell_std  = ta.stdev(dwell_density, i_zscore_len)
f2         = (range_valid and dwell_std > 0) ? (dwell_density - dwell_mean) / dwell_std : 0.0

// ── FEATURE 3 — momentum ───────────────────────────────────────────────────
mom_raw  = (close - close[i_mom_len]) / (close[i_mom_len] + syminfo.mintick)
mom_mean = ta.sma(mom_raw, i_zscore_len)
mom_std  = ta.stdev(mom_raw, i_zscore_len)
f3       = mom_std > 0 ? (mom_raw - mom_mean) / mom_std : 0.0

// ── ONLINE LOGISTIC REGRESSION — gradient descent, trains on 1-bar lag ─────
fwd_roc    = (close - close[i_label_period]) / (close[i_label_period] + syminfo.mintick)
label_bull = fwd_roc > 0

f_sigmoid(float z) => 1.0 / (1.0 + math.exp(-z))

var float w0        = 0.0
var float w1        = 0.0
var float w2        = 0.0
var float w3        = 0.0
var float trained_n = 0.0

if bar_index >= i_zscore_len + i_label_period + 2
    _pred  = f_sigmoid(w0 + w1 * f1[1] + w2 * f2[1] + w3 * f3[1])
    _label = label_bull[1] ? 1.0 : 0.0
    _err   = _label - _pred
    w0 := w0 + i_learn_rate * _err
    w1 := w1 + i_learn_rate * (_err * f1[1] - i_l2_lambda * w1)
    w2 := w2 + i_learn_rate * (_err * f2[1] - i_l2_lambda * w2)
    w3 := w3 + i_learn_rate * (_err * f3[1] - i_l2_lambda * w3)
    trained_n := trained_n + 1

post_bull = f_sigmoid(w0 + w1 * f1 + w2 * f2 + w3 * f3)
post_bear = 1.0 - post_bull
warmed_up = trained_n >= i_train_lookback

// ── ML ENTRY-ZONE DETECTION ────────────────────────────────────────────────
// The model scores every price level in each half (varying only the position
// feature; dwell & momentum held at their current values) and lights up the
// contiguous band where its probability clears the threshold — the exact price
// range in which a signal would currently fire. This band IS the ML detection.
float ml_long_lo  = na
float ml_long_hi  = na
float ml_long_p   = na   // peak P(Bull) inside the detected long band
float ml_short_lo = na
float ml_short_hi = na
float ml_short_p  = na   // peak P(Bear) inside the detected short band

if range_valid and warmed_up and pos_std > 0
    base = w0 + w2 * f2 + w3 * f3
    for j = 0 to i_nbins
        float p    = rangeLow + (eq_bot - rangeLow) * j / i_nbins       // discount region only
        float f1p  = ((p - rangeLow) / range_size - pos_mean) / pos_std
        float pbup = f_sigmoid(base + w1 * f1p)
        if pbup >= i_posterior_thresh
            ml_long_lo := na(ml_long_lo) ? p : math.min(ml_long_lo, p)
            ml_long_hi := na(ml_long_hi) ? p : math.max(ml_long_hi, p)
            ml_long_p  := na(ml_long_p)  ? pbup : math.max(ml_long_p, pbup)
    for k = 0 to i_nbins
        float p2    = eq_top + (rangeHigh - eq_top) * k / i_nbins       // premium region only
        float f1p2  = ((p2 - rangeLow) / range_size - pos_mean) / pos_std
        float pbep  = 1.0 - f_sigmoid(base + w1 * f1p2)
        if pbep >= i_posterior_thresh
            ml_short_lo := na(ml_short_lo) ? p2 : math.min(ml_short_lo, p2)
            ml_short_hi := na(ml_short_hi) ? p2 : math.max(ml_short_hi, p2)
            ml_short_p  := na(ml_short_p)  ? pbep : math.max(ml_short_p, pbep)

// ── SIGNALS — the model is the trigger; it fires where the ML zone lives ────
atr = ta.atr(i_atr_period)

// bos_dn blocks longs (don't catch a falling knife); bos_up blocks shorts
// (don't short a bullish breakout) — the range is stale until a swing re-anchors.
long_sig  = warmed_up and in_discount and not bos_dn and post_bull >= i_posterior_thresh
short_sig = warmed_up and in_premium  and not bos_up and post_bear >= i_posterior_thresh

long_entry  = long_sig  and not long_sig[1]
short_entry = short_sig and not short_sig[1]

long_hi  = long_entry  and post_bull >= 0.85
short_hi = short_entry and post_bear >= 0.85

// ── DRAW: structural map (Discount / Equilibrium / Premium + midpoint line) ─
var box  discBox = na
var box  premBox = na
var box  eqBox   = na
var line eqLine  = na

int z_left  = bar_index > i_zone_back ? bar_index - i_zone_back : 0
int z_right = bar_index + i_zone_extend

if i_show_zones and range_valid
    if na(discBox)
        discBox := box.new(z_left, eq_bot, z_right, rangeLow, border_color=color.new(i_disc_col, 55), bgcolor=color.new(i_disc_col, 94), text="DISCOUNT", text_size=size.tiny, text_color=color.new(i_disc_col, 15), text_halign=text.align_left, text_valign=text.align_bottom)
        premBox := box.new(z_left, rangeHigh, z_right, eq_top, border_color=color.new(i_prem_col, 55), bgcolor=color.new(i_prem_col, 94), text="PREMIUM", text_size=size.tiny, text_color=color.new(i_prem_col, 15), text_halign=text.align_left, text_valign=text.align_top)
        eqBox   := box.new(z_left, eq_top, z_right, eq_bot, border_color=color.new(i_eq_col, 55), bgcolor=color.new(i_eq_col, 88), text="EQUILIBRIUM", text_size=size.tiny, text_color=color.new(i_eq_col, 10), text_halign=text.align_left, text_valign=text.align_center)
    box.set_lefttop     (discBox, z_left, eq_bot)
    box.set_rightbottom (discBox, z_right, rangeLow)
    box.set_lefttop     (premBox, z_left, rangeHigh)
    box.set_rightbottom (premBox, z_right, eq_top)
    box.set_lefttop     (eqBox, z_left, eq_top)
    box.set_rightbottom (eqBox, z_right, eq_bot)

if i_show_eq and range_valid
    if na(eqLine)
        eqLine := line.new(z_left, equilibrium, z_right, equilibrium, color=color.new(color.gray, 20), width=1, style=line.style_dashed)
    line.set_xy1(eqLine, z_left, equilibrium)
    line.set_xy2(eqLine, z_right, equilibrium)

// ── DRAW: ML entry zone (bright, model-detected) ───────────────────────────
var box mlLongBox  = na
var box mlShortBox = na

if i_show_ote and range_valid
    if na(mlLongBox)
        mlLongBox  := box.new(z_left, na, z_right, na, border_color=color.new(i_disc_col, 0), bgcolor=color.new(i_disc_col, 68), text_size=size.tiny, text_color=color.new(color.white, 0), text_halign=text.align_center, text_valign=text.align_center)
        mlShortBox := box.new(z_left, na, z_right, na, border_color=color.new(i_prem_col, 0), bgcolor=color.new(i_prem_col, 68), text_size=size.tiny, text_color=color.new(color.white, 0), text_halign=text.align_center, text_valign=text.align_center)
    if not na(ml_long_lo)
        box.set_lefttop     (mlLongBox, z_left, ml_long_hi)
        box.set_rightbottom (mlLongBox, z_right, ml_long_lo)
        box.set_text        (mlLongBox, "ML BUY ZONE · up to " + str.tostring(math.round(ml_long_p * 100)) + "% P(Bull)")
    else
        box.set_top    (mlLongBox, na)
        box.set_bottom (mlLongBox, na)
    if not na(ml_short_lo)
        box.set_lefttop     (mlShortBox, z_left, ml_short_hi)
        box.set_rightbottom (mlShortBox, z_right, ml_short_lo)
        box.set_text        (mlShortBox, "ML SELL ZONE · up to " + str.tostring(math.round(ml_short_p * 100)) + "% P(Bear)")
    else
        box.set_top    (mlShortBox, na)
        box.set_bottom (mlShortBox, na)

// ── SIGNAL SHAPES — circle = high conviction (P≥85%), triangle = normal ────
plotshape(long_hi,                      "PD Long ● High",  location=location.belowbar, style=shape.circle,       size=size.small, color=color.new(#2962FF, 0))
plotshape(long_entry  and not long_hi,  "PD Long ▲",       location=location.belowbar, style=shape.triangleup,   size=size.small, color=color.new(#2962FF, 0))
plotshape(short_hi,                     "PD Short ● High", location=location.abovebar, style=shape.circle,       size=size.small, color=color.new(#FF6D00, 0))
plotshape(short_entry and not short_hi, "PD Short ▼",      location=location.abovebar, style=shape.triangledown, size=size.small, color=color.new(#FF6D00, 0))

// ── REGIME BACKGROUND ──────────────────────────────────────────────────────
bgcolor(i_show_bg and long_sig  and not i_zen_mode ? color.new(i_disc_col, 93) : na, title="Discount Regime")
bgcolor(i_show_bg and short_sig and not i_zen_mode ? color.new(i_prem_col, 93) : na, title="Premium Regime")

// ── SL / TP REFERENCE LINES (visual only — this is an indicator) ───────────
var line sl_line = na
var line tp_line = na

if long_entry and i_show_levels and not i_zen_mode
    sl_price = math.min(rangeLow - atr * i_sl_atr_mult, close - atr * 0.5)
    tp_price = close + (close - sl_price) * i_rr_ratio
    sl_line := line.new(bar_index, sl_price, bar_index + 8, sl_price, color=color.new(color.red, 30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_price, bar_index + 8, tp_price, color=color.new(color.green, 30), width=1, style=line.style_dashed)

if short_entry and i_show_levels and not i_zen_mode
    sl_price = math.max(rangeHigh + atr * i_sl_atr_mult, close + atr * 0.5)
    tp_price = close - (sl_price - close) * i_rr_ratio
    sl_line := line.new(bar_index, sl_price, bar_index + 8, sl_price, color=color.new(color.red, 30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_price, bar_index + 8, tp_price, color=color.new(color.green, 30), width=1, style=line.style_dashed)

// ── INFO TABLE ─────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 75), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

if barstate.islast and i_show_table
    color  txt_wht  = color.new(color.white, 0)
    bool   in_bos   = bos_up or bos_dn
    string zone_lbl = not range_valid ? "No Range" : bos_up ? "BOS ↑" : bos_dn ? "BOS ↓" : in_premium ? "Premium" : in_discount ? "Discount" : "Equilibrium"
    color  zone_col = not range_valid ? txt_wht : in_bos ? color.new(color.yellow, 0) : in_premium ? color.new(i_prem_col, 0) : in_discount ? color.new(i_disc_col, 0) : color.new(i_eq_col, 0)

    table.cell(tbl, 0, 0, "PD-ML",   text_color=color.new(color.gray, 0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 1, 0, warmed_up ? "● LIVE" : "● WARMUP", text_color=warmed_up ? color.new(color.lime, 0) : color.new(color.yellow, 0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 0, 1, "Zone",      text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 1, zone_lbl,    text_color=zone_col, text_size=size.small)
    table.cell(tbl, 0, 2, "P(Bull)",   text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 2, str.format("{0,number,#.#%}", post_bull), text_color=color.new(#2962FF, 0), text_size=size.small)
    table.cell(tbl, 0, 3, "P(Bear)",   text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 3, str.format("{0,number,#.#%}", post_bear), text_color=color.new(#FF6D00, 0), text_size=size.small)
    table.cell(tbl, 0, 4, "N Trained", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(int(trained_n)) + (warmed_up ? " ✓" : " …"), text_color=warmed_up ? color.new(color.lime, 0) : color.new(color.yellow, 0), text_size=size.small)
    table.cell(tbl, 0, 5, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)
    table.cell(tbl, 1, 5, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)
    table.cell(tbl, 0, 6, "● ▲  Long",  text_color=color.new(#2962FF, 0), text_size=size.tiny)
    table.cell(tbl, 1, 6, "●=P≥85%",    text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(tbl, 0, 7, "● ▼  Short", text_color=color.new(#FF6D00, 0), text_size=size.tiny)
    table.cell(tbl, 1, 7, "▲▼=normal",  text_color=color.new(color.gray, 20), text_size=size.tiny)

// ── ALERTS ─────────────────────────────────────────────────────────────────
alertcondition(long_entry,  "PD ML - Long",  "Premium/Discount ML Zones [PickMyTrade]: Discount long — P(Bull) ≥ threshold")
alertcondition(short_entry, "PD ML - Short", "Premium/Discount ML Zones [PickMyTrade]: Premium short — P(Bear) ≥ threshold")
alertcondition(long_entry or short_entry, "PD ML - Any Signal", "Premium/Discount ML Zones [PickMyTrade]: Signal detected")
````
