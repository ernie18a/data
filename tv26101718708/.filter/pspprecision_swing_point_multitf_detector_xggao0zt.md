# PSP(precision swing point) Multi-TF Detector

- url: https://www.tradingview.com/script/XGGAO0ZT-PSP-precision-swing-point-Multi-TF-Detector/
- type: indicator
- pine_id: PUB;397e5ed4bdfb46619abc6c11e8b7853d
- version: 1.0

## Description

# Precision Swing Point (PSP) — Multi-Timeframe with Accumulation Filter

**Catch the divergences that actually matter — across every timeframe from 1-minute to 4-hour.**

A Precision Swing Point (PSP) is a candle-level divergence between three correlated futures indices (ES, NQ, YM) where one closes opposite to the other two on the same bar. In ICT and Quarterly Theory frameworks, PSPs are core entry triggers — but raw detection generates dozens of false signals per session, especially in low-conviction range conditions. This indicator solves that by filtering out PSPs that print inside high-volume accumulation zones, where divergences are noise rather than tradeable reversals.

## Features

**Multi-timeframe detection** — toggle 1m, 3m, 5m, 15m, 30m, 1h, and 4h independently. Higher-timeframe markers scale visually so you can spot the timeframe at a glance.

**Wyckoff-style accumulation filter** — suppresses PSPs in zones where price is compressed but volume is elevated, the textbook signature of accumulation/distribution. Fully tunable: volume multiplier, range compression, zone density, and lookback windows.

**Configurable assets** — defaults to ES/NQ/YM but accepts any three correlated symbols (e-minis, micros, equity index ETFs, sector rotations).

**Clean visual design** — small markers below/above bars for bullish/bearish, no background flooding, no oversized arrows. Built to overlay alongside your existing chart structure without competing for attention.

**Per-timeframe alerts** — separate bullish and bearish alert conditions for every enabled timeframe, so you can route signals by quality and not get pinged on every 1m flicker.

**Non-repainting** — uses confirmed candles only and lookahead-off security calls. What prints in real-time is what stays.

## Built For

Traders running ICT, Quarterly Theory, or any correlated-asset framework who want PSP confluence without filtering hundreds of false signals manually. Particularly useful for funded account traders where signal quality directly impacts drawdown and payout consistency.

## Settings

- Symbol inputs for each correlated asset
- 7 independent timeframe toggles
- Accumulation filter master toggle + 5 tuning parameters
- Debug mode: visualize accumulation zones to verify the filter
- Marker style and color customization

## Source Code

````pine
//@version=6
// ============================================================
// Precision Swing Point (PSP) Multi-Timeframe Detector
// + Wyckoff-style Accumulation Filter
// ============================================================
indicator("PSP Multi-TF Detector", "PSP MTF", overlay=true, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================

// --- Symbols ---
g_sym  = "Symbols (use the contract you trade)"
sym_es = input.symbol("CME_MINI:MES1!",  "MES (Micro E-mini S&P 500)", group=g_sym)
sym_nq = input.symbol("CME_MINI:MNQ1!",  "MNQ (Micro E-mini Nasdaq)",  group=g_sym)
sym_ym = input.symbol("CBOT_MINI:MYM1!", "MYM (Micro E-mini Dow)",     group=g_sym)

// --- Timeframes ---
g_tf    = "Timeframes"
use_1m  = input.bool(true, "1 minute",   group=g_tf)
use_3m  = input.bool(true, "3 minutes",  group=g_tf)
use_5m  = input.bool(true, "5 minutes",  group=g_tf)
use_15m = input.bool(true, "15 minutes", group=g_tf)
use_30m = input.bool(true, "30 minutes", group=g_tf)
use_1h  = input.bool(true, "1 hour",     group=g_tf)
use_4h  = input.bool(true, "4 hours",    group=g_tf)

// --- Display ---
g_disp        = "Display"
show_tf_label = input.bool(true,    "Show TF label next to marker", group=g_disp)
bull_color    = input.color(#9CCC65, "Bullish color",               group=g_disp)
bear_color    = input.color(#B71C1C, "Bearish color",               group=g_disp)
show_debug    = input.bool(false,   "Show symbol-match debug label", group=g_disp)

// === NEW: Accumulation Filter inputs ============================
// Wyckoff-style filter: high volume + compressed range = accumulation.
// A bar counts as "accumulation" when BOTH:
//   volume > sma(volume, volumeLookback) * volumeMultiplier
//   (high - low) < atr(atrLookback) * rangeMultiplier
// A "zone" is active when >= minAccumBars of the last zoneLookback
// bars qualify. Tune the multipliers to control sensitivity.
// ================================================================
g_accum           = "Accumulation Filter"
enableAccumFilter = input.bool(true,  "Enable accumulation filter",          group=g_accum)
volumeLookback    = input.int(20,     "Volume SMA lookback",     minval=2,   group=g_accum)
volumeMultiplier  = input.float(1.5,  "Volume × baseline",       minval=0.1, step=0.1, group=g_accum, tooltip="Bar is 'high volume' when volume exceeds SMA × this multiplier")
atrLookback       = input.int(20,     "ATR lookback",            minval=2,   group=g_accum)
rangeMultiplier   = input.float(0.7,  "Range × ATR",             minval=0.1, step=0.1, group=g_accum, tooltip="Bar is 'compressed' when (high-low) is less than ATR × this multiplier")
zoneLookback      = input.int(5,      "Zone window (bars)",      minval=2,   group=g_accum)
minAccumBars      = input.int(3,      "Min accum bars in window", minval=1,  group=g_accum, tooltip="At least this many bars in the window must be accumulation bars to call it a zone")
showAccumZones    = input.bool(false, "Shade accumulation zones (chart TF)", group=g_accum)

// ============================================================
// GATING
// ============================================================
chart_id      = ticker.standard(syminfo.tickerid)
es_id         = ticker.standard(sym_es)
nq_id         = ticker.standard(sym_nq)
ym_id         = ticker.standard(sym_ym)
is_psp_symbol = chart_id == es_id or chart_id == nq_id or chart_id == ym_id
chart_sec     = timeframe.in_seconds(timeframe.period)

if show_debug and barstate.islast
    txt = (is_psp_symbol ? "MATCH — " : "NO MATCH — ") + "chart: " + chart_id + "\nlooking for: " + es_id + " | " + nq_id + " | " + ym_id
    label.new(bar_index, high, txt, style=label.style_label_left, color=is_psp_symbol ? color.new(color.green, 70) : color.new(color.red, 70), textcolor=color.white, size=size.small)

// ============================================================
// HELPERS
// ============================================================
f_dir(o, c) => c > o ? 1 : c < o ? -1 : 0

f_detect(es_o, es_c, nq_o, nq_c, ym_o, ym_c) =>
    d_es = f_dir(es_o, es_c)
    d_nq = f_dir(nq_o, nq_c)
    d_ym = f_dir(ym_o, ym_c)
    no_doji = d_es != 0 and d_nq != 0 and d_ym != 0
    bulls = (d_es ==  1 ? 1 : 0) + (d_nq ==  1 ? 1 : 0) + (d_ym ==  1 ? 1 : 0)
    bears = (d_es == -1 ? 1 : 0) + (d_nq == -1 ? 1 : 0) + (d_ym == -1 ? 1 : 0)
    bull = no_doji and bulls == 1 and bears == 2
    bear = no_doji and bears == 1 and bulls == 2
    [bull, bear]

f_oc(sym, tf) =>
    request.security(sym, tf, [open[1], close[1]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

f_active(enabled, tf) =>
    enabled and timeframe.in_seconds(tf) >= chart_sec and is_psp_symbol

// === NEW: Accumulation helpers ==================================
// Evaluates accumulation-zone state on the CURRENT bar in the
// caller's context. When called inside request.security, every
// variable below (volume, high, low, ta.sma, ta.atr) automatically
// refers to the requested symbol+TF's data.
f_accum_zone_here() =>
    is_high_vol   = volume > ta.sma(volume, volumeLookback) * volumeMultiplier
    is_compressed = (high - low) < ta.atr(atrLookback) * rangeMultiplier
    accum_bar     = is_high_vol and is_compressed
    math.sum(accum_bar ? 1 : 0, zoneLookback) >= minAccumBars

// Non-repainting fetch of the accumulation state of the most
// recently CLOSED bar at the given TF, on the chart's symbol.
// Mirrors the [1]-shifted security pattern used for PSP detection.
f_accum(tf) =>
    request.security(syminfo.tickerid, tf, f_accum_zone_here()[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

// Returns TRUE when this PSP should PASS the filter (not be suppressed).
//   - filter disabled        → pass
//   - accum state na/false   → pass (na guarded via nz to handle early bars)
//   - accum state true       → suppress
f_pass(accum) =>
    not (enableAccumFilter and accum == true)

// ============================================================
// FETCH PER-TF OPEN/CLOSE (3 symbols × 7 timeframes)
// ============================================================
[es_o_1m,  es_c_1m]  = f_oc(sym_es, "1")
[nq_o_1m,  nq_c_1m]  = f_oc(sym_nq, "1")
[ym_o_1m,  ym_c_1m]  = f_oc(sym_ym, "1")

[es_o_3m,  es_c_3m]  = f_oc(sym_es, "3")
[nq_o_3m,  nq_c_3m]  = f_oc(sym_nq, "3")
[ym_o_3m,  ym_c_3m]  = f_oc(sym_ym, "3")

[es_o_5m,  es_c_5m]  = f_oc(sym_es, "5")
[nq_o_5m,  nq_c_5m]  = f_oc(sym_nq, "5")
[ym_o_5m,  ym_c_5m]  = f_oc(sym_ym, "5")

[es_o_15m, es_c_15m] = f_oc(sym_es, "15")
[nq_o_15m, nq_c_15m] = f_oc(sym_nq, "15")
[ym_o_15m, ym_c_15m] = f_oc(sym_ym, "15")

[es_o_30m, es_c_30m] = f_oc(sym_es, "30")
[nq_o_30m, nq_c_30m] = f_oc(sym_nq, "30")
[ym_o_30m, ym_c_30m] = f_oc(sym_ym, "30")

[es_o_1h,  es_c_1h]  = f_oc(sym_es, "60")
[nq_o_1h,  nq_c_1h]  = f_oc(sym_nq, "60")
[ym_o_1h,  ym_c_1h]  = f_oc(sym_ym, "60")

[es_o_4h,  es_c_4h]  = f_oc(sym_es, "240")
[nq_o_4h,  nq_c_4h]  = f_oc(sym_nq, "240")
[ym_o_4h,  ym_c_4h]  = f_oc(sym_ym, "240")

// ============================================================
// DETECT PSPS PER TIMEFRAME
// ============================================================
[bull_1m,  bear_1m]  = f_detect(es_o_1m,  es_c_1m,  nq_o_1m,  nq_c_1m,  ym_o_1m,  ym_c_1m)
[bull_3m,  bear_3m]  = f_detect(es_o_3m,  es_c_3m,  nq_o_3m,  nq_c_3m,  ym_o_3m,  ym_c_3m)
[bull_5m,  bear_5m]  = f_detect(es_o_5m,  es_c_5m,  nq_o_5m,  nq_c_5m,  ym_o_5m,  ym_c_5m)
[bull_15m, bear_15m] = f_detect(es_o_15m, es_c_15m, nq_o_15m, nq_c_15m, ym_o_15m, ym_c_15m)
[bull_30m, bear_30m] = f_detect(es_o_30m, es_c_30m, nq_o_30m, nq_c_30m, ym_o_30m, ym_c_30m)
[bull_1h,  bear_1h]  = f_detect(es_o_1h,  es_c_1h,  nq_o_1h,  nq_c_1h,  ym_o_1h,  ym_c_1h)
[bull_4h,  bear_4h]  = f_detect(es_o_4h,  es_c_4h,  nq_o_4h,  nq_c_4h,  ym_o_4h,  ym_c_4h)

// === NEW: PER-TF ACCUMULATION STATE ============================
// Each TF independently evaluates its own accumulation state on
// the chart symbol — the PSP at that TF is filtered against the
// same TF's zone (not the chart's TF).
// ================================================================
accum_1m  = f_accum("1")
accum_3m  = f_accum("3")
accum_5m  = f_accum("5")
accum_15m = f_accum("15")
accum_30m = f_accum("30")
accum_1h  = f_accum("60")
accum_4h  = f_accum("240")

// ============================================================
// NEW HTF CANDLE TRIGGER (fires once per closed HTF candle)
// ============================================================
new_1m  = ta.change(time("1"))   != 0
new_3m  = ta.change(time("3"))   != 0
new_5m  = ta.change(time("5"))   != 0
new_15m = ta.change(time("15"))  != 0
new_30m = ta.change(time("30"))  != 0
new_1h  = ta.change(time("60"))  != 0
new_4h  = ta.change(time("240")) != 0

// === UPDATED: FINAL SIGNALS now include accumulation filter ====
sig_bull_1m  = bull_1m  and f_active(use_1m,  "1")   and new_1m  and f_pass(accum_1m)
sig_bear_1m  = bear_1m  and f_active(use_1m,  "1")   and new_1m  and f_pass(accum_1m)
sig_bull_3m  = bull_3m  and f_active(use_3m,  "3")   and new_3m  and f_pass(accum_3m)
sig_bear_3m  = bear_3m  and f_active(use_3m,  "3")   and new_3m  and f_pass(accum_3m)
sig_bull_5m  = bull_5m  and f_active(use_5m,  "5")   and new_5m  and f_pass(accum_5m)
sig_bear_5m  = bear_5m  and f_active(use_5m,  "5")   and new_5m  and f_pass(accum_5m)
sig_bull_15m = bull_15m and f_active(use_15m, "15")  and new_15m and f_pass(accum_15m)
sig_bear_15m = bear_15m and f_active(use_15m, "15")  and new_15m and f_pass(accum_15m)
sig_bull_30m = bull_30m and f_active(use_30m, "30")  and new_30m and f_pass(accum_30m)
sig_bear_30m = bear_30m and f_active(use_30m, "30")  and new_30m and f_pass(accum_30m)
sig_bull_1h  = bull_1h  and f_active(use_1h,  "60")  and new_1h  and f_pass(accum_1h)
sig_bear_1h  = bear_1h  and f_active(use_1h,  "60")  and new_1h  and f_pass(accum_1h)
sig_bull_4h  = bull_4h  and f_active(use_4h,  "240") and new_4h  and f_pass(accum_4h)
sig_bear_4h  = bear_4h  and f_active(use_4h,  "240") and new_4h  and f_pass(accum_4h)

// ============================================================
// PLOT MARKERS  (unchanged)
// ============================================================
plotshape(sig_bull_1m,  "Bull PSP 1m",  shape.circle,       location.belowbar, bull_color, size=size.tiny,   offset=-1)
plotshape(sig_bear_1m,  "Bear PSP 1m",  shape.circle,       location.abovebar, bear_color, size=size.tiny,   offset=-1)
plotshape(sig_bull_3m,  "Bull PSP 3m",  shape.circle,       location.belowbar, bull_color, size=size.small,  offset=-1)
plotshape(sig_bear_3m,  "Bear PSP 3m",  shape.circle,       location.abovebar, bear_color, size=size.small,  offset=-1)
plotshape(sig_bull_5m,  "Bull PSP 5m",  shape.triangleup,   location.belowbar, bull_color, size=size.tiny,   offset=-1)
plotshape(sig_bear_5m,  "Bear PSP 5m",  shape.triangledown, location.abovebar, bear_color, size=size.tiny,   offset=-1)
plotshape(sig_bull_15m, "Bull PSP 15m", shape.triangleup,   location.belowbar, bull_color, size=size.small,  offset=-1)
plotshape(sig_bear_15m, "Bear PSP 15m", shape.triangledown, location.abovebar, bear_color, size=size.small,  offset=-1)
plotshape(sig_bull_30m, "Bull PSP 30m", shape.triangleup,   location.belowbar, bull_color, size=size.normal, offset=-1)
plotshape(sig_bear_30m, "Bear PSP 30m", shape.triangledown, location.abovebar, bear_color, size=size.normal, offset=-1)
plotshape(sig_bull_1h,  "Bull PSP 1h",  shape.diamond,      location.belowbar, bull_color, size=size.small,  offset=-1)
plotshape(sig_bear_1h,  "Bear PSP 1h",  shape.diamond,      location.abovebar, bear_color, size=size.small,  offset=-1)
plotshape(sig_bull_4h,  "Bull PSP 4h",  shape.diamond,      location.belowbar, bull_color, size=size.normal, offset=-1)
plotshape(sig_bear_4h,  "Bear PSP 4h",  shape.diamond,      location.abovebar, bear_color, size=size.normal, offset=-1)

// ============================================================
// OPTIONAL TF LABELS  (unchanged)
// ============================================================
// Spacing scales with chart volatility so the text always clears the marker.
// Computed at top level so the rolling ATR window stays continuous.
label_spacing = ta.atr(14) * 0.5

f_label(cond, txt, isBull, col) =>
    if cond and show_tf_label
        y_pos = isBull ? low[1] - label_spacing : high[1] + label_spacing
        label.new(bar_index - 1, y_pos, txt, style=label.style_none, textcolor=col, size=size.tiny)

f_label(sig_bull_1m,  "1m",  true,  bull_color)
f_label(sig_bear_1m,  "1m",  false, bear_color)
f_label(sig_bull_3m,  "3m",  true,  bull_color)
f_label(sig_bear_3m,  "3m",  false, bear_color)
f_label(sig_bull_5m,  "5m",  true,  bull_color)
f_label(sig_bear_5m,  "5m",  false, bear_color)
f_label(sig_bull_15m, "15m", true,  bull_color)
f_label(sig_bear_15m, "15m", false, bear_color)
f_label(sig_bull_30m, "30m", true,  bull_color)
f_label(sig_bear_30m, "30m", false, bear_color)
f_label(sig_bull_1h,  "1h",  true,  bull_color)
f_label(sig_bear_1h,  "1h",  false, bear_color)
f_label(sig_bull_4h,  "4h",  true,  bull_color)
f_label(sig_bear_4h,  "4h",  false, bear_color)

// ============================================================
// ALERTS  (unchanged — filter automatically applies because
// alerts fire on the same sig_* booleans the markers use)
// ============================================================
alertcondition(sig_bull_1m,  "Bullish PSP — 1m",  "Bullish PSP on the 1-minute timeframe")
alertcondition(sig_bear_1m,  "Bearish PSP — 1m",  "Bearish PSP on the 1-minute timeframe")
alertcondition(sig_bull_3m,  "Bullish PSP — 3m",  "Bullish PSP on the 3-minute timeframe")
alertcondition(sig_bear_3m,  "Bearish PSP — 3m",  "Bearish PSP on the 3-minute timeframe")
alertcondition(sig_bull_5m,  "Bullish PSP — 5m",  "Bullish PSP on the 5-minute timeframe")
alertcondition(sig_bear_5m,  "Bearish PSP — 5m",  "Bearish PSP on the 5-minute timeframe")
alertcondition(sig_bull_15m, "Bullish PSP — 15m", "Bullish PSP on the 15-minute timeframe")
alertcondition(sig_bear_15m, "Bearish PSP — 15m", "Bearish PSP on the 15-minute timeframe")
alertcondition(sig_bull_30m, "Bullish PSP — 30m", "Bullish PSP on the 30-minute timeframe")
alertcondition(sig_bear_30m, "Bearish PSP — 30m", "Bearish PSP on the 30-minute timeframe")
alertcondition(sig_bull_1h,  "Bullish PSP — 1h",  "Bullish PSP on the 1-hour timeframe")
alertcondition(sig_bear_1h,  "Bearish PSP — 1h",  "Bearish PSP on the 1-hour timeframe")
alertcondition(sig_bull_4h,  "Bullish PSP — 4h",  "Bullish PSP on the 4-hour timeframe")
alertcondition(sig_bear_4h,  "Bearish PSP — 4h",  "Bearish PSP on the 4-hour timeframe")

// === NEW: ACCUMULATION ZONE BACKGROUND SHADING =================
// Faint gray when the CHART's timeframe is in an accumulation zone.
// We map the chart's TF to the corresponding accum_* variable so we
// reuse the same non-repainting data the filter is using.
// offset=-1 aligns the shading with the bar that was actually evaluated.
// ================================================================
chart_accum = timeframe.period == "1"   ? accum_1m  :
              timeframe.period == "3"   ? accum_3m  :
              timeframe.period == "5"   ? accum_5m  :
              timeframe.period == "15"  ? accum_15m :
              timeframe.period == "30"  ? accum_30m :
              timeframe.period == "60"  ? accum_1h  :
              timeframe.period == "240" ? accum_4h  : false

bgcolor(showAccumZones and chart_accum ? color.new(color.gray, 92) : na, offset=-1, title="Accumulation zone")
````
