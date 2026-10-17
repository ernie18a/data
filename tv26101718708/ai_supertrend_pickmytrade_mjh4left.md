# AI SuperTrend [PickMyTrade]

- url: https://www.tradingview.com/script/MjH4LefT-AI-SuperTrend-PickMyTrade/
- type: indicator
- pine_id: PUB;f396b500d8624e769f611496e35b8f73
- version: 1.0

## Description

[b]THE PROBLEM WITH A FIXED MULTIPLIER[/b]

Every standard SuperTrend applies the same ATR multiplier across all market conditions — the same constant during a strong trending breakout, a narrow choppy range, and a volatility spike. A value calibrated for one regime is miscalibrated for the others. Most traders compensate by manually switching timeframes or parameters. This script automates that decision.

The question it asks: what if the ATR multiplier were selected from historical bars that most resembled the current market regime — matched by Hurst state and volatility rank — rather than set by the user as a fixed constant?

────────────────────────────────────────

[b]THREE AI LAYERS[/b]

[b]Layer 1 — Hurst Exponent (Regime Gate)[/b]

The Hurst Exponent is computed via Rescaled Range (R/S) Analysis. It measures the degree of long-range dependence (memory) in the price series:

[list]
[*]H ≥ 0.55 → Persistent (trending) — SuperTrend active, signals enabled
[*]H ≈ 0.50 → Random walk — candles turn gray, no signal generated
[*]H ≤ 0.45 → Anti-persistent (mean-reverting) — signals suppressed
[/list]

The Hurst gate is the first filter. Signals only fire when market structure is historically associated with persistence — not randomness or mean-reversion.

[b]Layer 2 — Garman-Klass Volatility Rank[/b]

Garman-Klass (1980) estimates realized volatility from OHLC prices rather than close-to-close returns, capturing intrabar price range and making it more sensitive to volatility changes. The current reading is percentile-ranked against recent history (0–100%) and used as the second feature dimension for the KNN search.

[b]Layer 3 — KNN Multiplier Optimizer[/b]

K-Nearest Neighbors searches a rolling memory bank of [Hurst, Vol Rank] feature pairs from previous bars. For each current bar it finds the K most similar historical bars by Euclidean distance in that 2D feature space. From those neighbors it retrieves the ATR multipliers that were in effect — weighted by the profitability of the bar that followed. The result is the AI Multiplier: a context-aware value drawn from the most similar past conditions, not a fixed constant.

────────────────────────────────────────

[b]WHAT YOU SEE ON THE CHART[/b]

https://www.tradingview.com/x/MhN73g5O/

[b]Candle color[/b] — the defining visual. Orange = bull trend regime, blue = bear trend regime, gray = random walk or mean-reverting. The regime state is readable on every bar without checking the table.

[b]Signals[/b] — ● (circle) marks trend flips with Hurst ≥ 0.65, the high-conviction threshold. ▲▼ (triangle) marks standard threshold crossings. No signal fires in gray (random or mean-reverting) regimes.

[b]SL / TP lines[/b] — dashed lines drawn automatically at each signal bar, sized from current ATR × the AI Multiplier active at that bar.

[b]Info table[/b] (top right) — live display of Hurst value, Regime label, Direction, AI Multiplier, Vol Rank, and KNN memory bar count. Shows WARMUP until KNN has stored enough bars to begin optimizing.

────────────────────────────────────────

[b]HOW TO USE[/b]

A signal requires all three conditions to be true simultaneously:
[list=1]
[*]KNN is warmed up (table shows ● LIVE)
[*]Hurst confirms a trending regime (H ≥ Trend Threshold input)
[*]Price is on the correct side of the EMA filter
[/list]

Circle signals (●) indicate Hurst has exceeded 0.65 — stronger persistence than the standard threshold. Triangle signals (▲▼) are at the user-defined threshold. Gray candles indicate the market is not in a trending regime; reducing exposure or standing aside is appropriate during those periods.

The regime background shading (faint orange or blue fill) shows when the SuperTrend is in an active directional state.

────────────────────────────────────────

[b]INPUTS[/b]

[i]AI Engine[/i] — Hurst Lookback, KNN Neighbors (K), KNN Memory (bars), Trend Threshold, Mean-Revert Threshold
[i]SuperTrend[/i] — ATR Length, Base Multiplier, Volatility Window, EMA Period
[i]Visual[/i] — Bull/Bear colors, SL/TP lines toggle, SL ATR Multiplier, Risk:Reward ratio, Regime Background
[i]Display[/i] — Zen Mode (hides labels and table), Show Info Table

[b]ALERTS[/b]

Three alert conditions: Long Signal, Short Signal, Any Signal.

────────────────────────────────────────

[b]NOTES[/b]

[list]
[*]KNN requires warmup equal to the KNN Memory setting before the AI Multiplier activates. During warmup the base multiplier scaled by Hurst and volatility rank is used instead.
[*]No repainting. All signals are confirmed on bar close. KNN stores lagged [1] values only.
[*]Garman-Klass citation: Garman, M. & Klass, M. (1980). On the Estimation of Security Price Volatilities from Historical Data. [i]Journal of Business[/i], 53(1), 67–78.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © PickMyTrade — AI SuperTrend [PickMyTrade] — Option B: Hurst-Colored Candles

//@version=6
import PickMyTrade_Official/PickMyTradeLib/1 as pmtq

indicator(
    title            = "AI SuperTrend [PickMyTrade]",
    shorttitle       = "AIST [PMT]",
    overlay          = true,
    max_labels_count = 50,
    max_lines_count  = 50
)

var string G_AI   = "AI Engine"
var string G_CORE = "SuperTrend"
var string G_VIS  = "Visual"
var string G_ZEN  = "Display"

i_hurst_len   = input.int  (60,   "Hurst Lookback",        minval=30,  maxval=200, step=5,  group=G_AI, tooltip="Bars used for R/S analysis. 60 recommended.")
i_knn_k       = input.int  (5,    "KNN Neighbors (K)",     minval=3,   maxval=15,           group=G_AI, tooltip="Historical analogs matched per bar.")
i_knn_depth   = input.int  (200,  "KNN Memory (bars)",     minval=50,  maxval=500, step=25, group=G_AI, tooltip="Bars stored in KNN memory bank.")
i_hurst_trend = input.float(0.55, "Trend Threshold",       minval=0.50, maxval=0.80, step=0.01, group=G_AI, tooltip="Hurst ≥ this = trending regime.")
i_hurst_pause = input.float(0.45, "Mean-Revert Threshold", minval=0.30, maxval=0.50, step=0.01, group=G_AI, tooltip="Hurst ≤ this = mean-reverting. Signals suppressed.")

i_atr_len   = input.int  (14,  "ATR Length",       minval=5,   maxval=50,            group=G_CORE, tooltip="ATR period for SuperTrend.")
i_base_mult = input.float(2.5, "Base Multiplier",  minval=0.5, maxval=6.0, step=0.1, group=G_CORE, tooltip="Base ATR multiplier. AI scales this each bar.")
i_vol_len   = input.int  (20,  "Vol Window",       minval=10,  maxval=100,           group=G_CORE, tooltip="Garman-Klass volatility window.")
i_ema_len   = input.int  (50,  "Trend EMA Period", minval=5,   maxval=500,           group=G_CORE, tooltip="Trend filter. Longs above, shorts below.")

bull_col    = input.color(color.new(#FF6D00, 0), "Bull Colour",   group=G_VIS)
bear_col    = input.color(color.new(#2962FF, 0), "Bear Colour",   group=G_VIS)
show_levels = input.bool (true,  "Show SL / TP Lines", group=G_VIS)
sl_mult     = input.float(1.5,  "SL ATR Multiplier",  minval=0.5, maxval=5.0,  step=0.1, group=G_VIS, active=show_levels)
rr_ratio    = input.float(2.0,  "Risk : Reward",      minval=0.5, maxval=10.0, step=0.1, group=G_VIS, active=show_levels)
show_bg     = input.bool (true,  "Regime Background",  group=G_VIS)
zen_mode    = input.bool (false, "Zen Mode",           group=G_ZEN, tooltip="Hides labels and table.")
show_table  = input.bool (true,  "Show Info Table",    group=G_ZEN)

float hurst    = pmtq.hurstRS(close, i_hurst_len)
float vol_rank = pmtq.garmanKlass(open, high, low, close, i_vol_len).rank

float _hurst_scale  = 1.0 + (0.5 - math.max(0.0, math.min(1.0, hurst))) * 1.6
float _vol_scale    = 1.0 + (vol_rank / 100.0) * 0.4
float base_adaptive = i_base_mult * _hurst_scale * _vol_scale

var array<float> _knn_h   = array.new<float>()
var array<float> _knn_v   = array.new<float>()
var array<float> _knn_m   = array.new<float>()
var array<float> _knn_ret = array.new<float>()

if barstate.isconfirmed and bar_index > i_hurst_len + 1
    float _ret_prev = (close - close[1]) / math.max(close[1], 1e-10)
    array.push(_knn_h,   hurst[1])
    array.push(_knn_v,   vol_rank[1])
    array.push(_knn_m,   base_adaptive[1])
    array.push(_knn_ret, _ret_prev)
    if array.size(_knn_h) > i_knn_depth
        array.shift(_knn_h)
        array.shift(_knn_v)
        array.shift(_knn_m)
        array.shift(_knn_ret)

float ai_mult = base_adaptive
int   _n      = array.size(_knn_h)
bool  warmed  = _n >= i_knn_k

if warmed
    array<float> _dists = array.new<float>(_n)
    for _i = 0 to _n - 1
        float _dh = (hurst    - array.get(_knn_h, _i)) / 0.5
        float _dv = (vol_rank - array.get(_knn_v, _i)) / 100.0
        array.set(_dists, _i, _dh * _dh + _dv * _dv)
    array<float> _sorted = array.copy(_dists)
    array.sort(_sorted, order.ascending)
    float _kth = array.get(_sorted, math.min(i_knn_k - 1, _n - 1))
    float _sw = 0.0
    float _sm = 0.0
    for _i = 0 to _n - 1
        float _d = array.get(_dists, _i)
        if _d <= _kth + 1e-10
            float _r = array.get(_knn_ret, _i)
            float _w = (_r > 0.0 ? 2.0 : 0.5) / (_d + 1e-6)
            _sw += _w
            _sm += _w * array.get(_knn_m, _i)
    if _sw > 1e-10
        ai_mult := math.max(0.5, math.min(6.0, _sm / _sw))

// ── B: SINGLE LINE + HURST-COLORED CANDLES ───────────────────────────────────
float _atr    = ta.atr(i_atr_len)
float _up_raw = hl2 + ai_mult * _atr
float _dn_raw = hl2 - ai_mult * _atr

var float _up  = na
var float _dn  = na
var int   _dir = 1

_up  := na(_up[1]) or _up_raw < _up[1] or close[1] > _up[1] ? _up_raw : _up[1]
_dn  := na(_dn[1]) or _dn_raw > _dn[1] or close[1] < _dn[1] ? _dn_raw : _dn[1]
_dir := nz(_dir[1], 1) == -1 and close > _up[1] ? 1 : nz(_dir[1], 1) == 1 and close < _dn[1] ? -1 : nz(_dir[1], 1)

float st_line  = _dir == 1 ? _dn : _up
float ema_line = ta.ema(close, i_ema_len)
bool  above_ema = close > ema_line
bool  below_ema = close < ema_line

bool regime_trend = hurst >= i_hurst_trend
bool regime_pause = hurst <= i_hurst_pause
bool bull_flip = _dir == 1  and nz(_dir[1], 1) == -1
bool bear_flip = _dir == -1 and nz(_dir[1], 1) ==  1
bool long_sig  = warmed and bull_flip and regime_trend and above_ema
bool short_sig = warmed and bear_flip and regime_trend and below_ema
bool long_hi   = long_sig  and hurst >= 0.65
bool short_hi  = short_sig and hurst >= 0.65

color _st_col = regime_pause ? color.new(color.gray, 30) : _dir == 1 ? color.new(bull_col, 0) : color.new(bear_col, 0)

plot(ema_line, "EMA",          color=color.new(color.gray, 60), linewidth=1)
plot(st_line,  "AI SuperTrend", color=_st_col, linewidth=2)

// Hurst-colored candles — the defining visual of Option B
barcolor(regime_trend and _dir == 1  ? color.new(bull_col, 15) : regime_trend and _dir == -1 ? color.new(bear_col, 15) : regime_pause ? color.new(color.gray, 35) : na, title="Regime Candles")

plotshape(long_hi  and not zen_mode, "Long ● High",   location=location.belowbar, style=shape.circle,      size=size.small, color=color.new(bull_col, 0))
plotshape(long_sig and not long_hi  and not zen_mode, "Long ▲",  location=location.belowbar, style=shape.triangleup,   size=size.small, color=color.new(bull_col, 0))
plotshape(short_hi and not zen_mode, "Short ● High",  location=location.abovebar, style=shape.circle,      size=size.small, color=color.new(bear_col, 0))
plotshape(short_sig and not short_hi and not zen_mode, "Short ▼", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.new(bear_col, 0))

bgcolor(show_bg and regime_trend and _dir == 1  ? color.new(bull_col, 93) : na, title="Bull Regime")
bgcolor(show_bg and regime_trend and _dir == -1 ? color.new(bear_col, 93) : na, title="Bear Regime")

var line sl_line = na
var line tp_line = na
if long_sig and show_levels and not zen_mode
    sl_line := line.new(bar_index, close - _atr * sl_mult, bar_index + 8, close - _atr * sl_mult, color=color.new(color.red, 30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, close + _atr * sl_mult * rr_ratio, bar_index + 8, close + _atr * sl_mult * rr_ratio, color=color.new(color.green, 30), width=1, style=line.style_dashed)
if short_sig and show_levels and not zen_mode
    sl_line := line.new(bar_index, close + _atr * sl_mult, bar_index + 8, close + _atr * sl_mult, color=color.new(color.red, 30), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, close - _atr * sl_mult * rr_ratio, bar_index + 8, close - _atr * sl_mult * rr_ratio, color=color.new(color.green, 30), width=1, style=line.style_dashed)

var table tbl = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 75), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)
if barstate.islast and show_table
    color txt_wht = color.new(color.white, 0)
    table.cell(tbl, 0, 0, "AI SuperTrend", text_color=color.new(color.gray, 0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 1, 0, warmed ? "● LIVE" : "● WARMUP", text_color=warmed ? color.new(color.lime, 0) : color.new(color.yellow, 0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 0, 1, "Hurst",     text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(hurst, "#.###"), text_color=regime_trend ? color.new(bull_col, 0) : regime_pause ? color.new(bear_col, 0) : color.new(color.gray, 0), text_size=size.small)
    table.cell(tbl, 0, 2, "Regime",    text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 2, regime_trend ? "Trending" : regime_pause ? "Mean-Rev" : "Random", text_color=regime_trend ? color.new(bull_col, 0) : regime_pause ? color.new(bear_col, 0) : color.new(color.gray, 0), text_size=size.small)
    table.cell(tbl, 0, 3, "Direction", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 3, _dir == 1 ? "▲ Bull" : "▼ Bear", text_color=_dir == 1 ? color.new(bull_col, 0) : color.new(bear_col, 0), text_size=size.small)
    table.cell(tbl, 0, 4, "AI Mult",   text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(ai_mult, "#.##"), text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 0, 5, "Vol Rank",  text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(vol_rank, "#") + "%", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 0, 6, "KNN Mem",   text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 6, str.tostring(_n) + " bars", text_color=warmed ? color.new(color.lime, 0) : color.new(color.yellow, 0), text_size=size.small)
    table.cell(tbl, 0, 7, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)
    table.cell(tbl, 1, 7, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)
    table.cell(tbl, 0, 8, "● ▲  Long", text_color=color.new(bull_col, 0), text_size=size.tiny)
    table.cell(tbl, 1, 8, "●=H>0.65",  text_color=color.new(color.gray, 20), text_size=size.tiny)

alertcondition(long_sig,  "AI ST - Long",  "AI SuperTrend [PickMyTrade]: Bull signal — Hurst trending, KNN-optimised multiplier active")
alertcondition(short_sig, "AI ST - Short", "AI SuperTrend [PickMyTrade]: Bear signal — Hurst trending, KNN-optimised multiplier active")
alertcondition(long_sig or short_sig, "AI ST - Any Signal", "AI SuperTrend [PickMyTrade]: Signal detected")
````
