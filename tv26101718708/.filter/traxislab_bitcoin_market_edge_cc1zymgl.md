# TraxisLab - Bitcoin Market Edge

- url: https://www.tradingview.com/script/cC1zyMGl/
- type: indicator
- pine_id: PUB;cd93a5b753264ce9ab9e49022bc9c3c9
- version: 1.0

## Description

TraxisLab Bitcoin Market Edge is a Bitcoin-focused confluence indicator designed to combine trend, momentum, volume flow, VWAP, orderblocks, liquidity grabs, multi-timeframe bias, and structured risk levels into one clean trading overlay.

The script is built specifically as a decision-support framework for BTC traders who want a compact market edge model directly on the chart.

Core Concept

Bitcoin Market Edge uses a weighted scoring matrix to compare bullish and bearish conditions.

Instead of triggering entries from one isolated signal, the indicator evaluates several market components at the same time:

Volatility-adjusted EMA trend
Trend-adaptive RSI
OBV-based volume flow
Daily VWAP position and reclaim logic
Orderblock interaction
Liquidity grab detection
Break of structure
Multi-timeframe bias
Strong-volume confirmation

A long or short signal is only displayed when the score reaches the selected threshold, the opposite side is weaker by the required score gap, and cooldown rules are satisfied.

Signal Modes

The script includes three operating modes:

Aggressive
More responsive signals with a lower score threshold.

Standard
Balanced signal generation for general use.

Conservative
Stricter filtering with fewer but more selective signals.

A manual score override is available for users who want to define their own required score threshold.

Volatility-Adjusted EMAs

The indicator uses three EMAs:

Fast EMA
Mid EMA
Slow EMA

When volatility adjustment is enabled, EMA speed adapts to current ATR conditions.
In higher volatility, the EMAs can respond faster, while calmer conditions keep the trend model smoother.

The trend engine evaluates EMA alignment and EMA slope to classify the market as bullish, bearish, or neutral.

Trend-Adaptive RSI

The RSI logic adapts to the current trend environment.

In bullish conditions, RSI is interpreted differently than in bearish or neutral conditions.
This helps separate trend continuation momentum from potential exhaustion or reversal behavior.

The script can detect:

Bullish RSI continuation
Bearish RSI continuation
Extreme long conditions
Extreme short conditions
RSI slope shifts
Volume Flow, OBV & VWAP

Bitcoin Market Edge includes a volume-flow layer based on smoothed OBV and Daily VWAP.

This section helps identify whether volume is supporting the current price direction.

It evaluates:

OBV direction
OBV trend vs slower OBV average
Strong volume compared to volume moving average
Price position above or below Daily VWAP
VWAP reclaim events
VWAP proximity

This makes VWAP and volume flow an important part of the score model.

Orderblocks & Liquidity Grabs

The script detects basic bullish and bearish orderblocks after break-of-structure events.

It can display active orderblock zones directly on the chart and track when price trades back into them.

It also detects liquidity grabs:

Bullish liquidity grab below a previous pivot low
Bearish liquidity grab above a previous pivot high

These events are included in the confluence score and can also be displayed as compact “LG” markers.

Multi-Timeframe Bias Dashboard

The indicator checks up to four user-defined higher or lower timeframes.

Each timeframe is scored using:

EMA structure
Price position relative to the slow EMA
RSI bias

The dashboard displays the bias for each selected timeframe as bullish, bearish, or neutral.

This helps traders quickly see whether the current chart aligns with broader market direction.

Confluence Scoring Matrix

The scoring model compares long and short conditions across five categories:

Trend
RSI / momentum
Volume flow and VWAP
Orderblocks, BOS, and liquidity grabs
Multi-timeframe bias

Strong volume can add an additional score boost to the dominant side.

Signals require:

Score above the selected threshold
Minimum long/short score gap
Cooldown confirmation
Confirmed bar if enabled
No active same-direction signal conflict

This helps reduce weak or conflicting signals.

Risk Targets

When a signal appears, the script calculates visual trade levels:

Entry
Stop Loss
TP1
TP2
TP3

The stop is based on ATR, while take-profit levels are based on configurable risk-reward multiples.

These levels are drawn directly on the chart for the active setup.

Visual Features

The indicator includes a clean visual layout with:

Long and short signal labels
Tooltip details with score, entry, SL, TP levels, and MTF count
Volatility-adjusted EMAs
Daily VWAP
EMA and VWAP right-side labels
Bullish and bearish orderblock boxes
Liquidity grab markers
Active entry, stop, and target lines
Multi-timeframe dashboard

Most visuals can be enabled, disabled, or customized in the settings.

Alerts

The script includes alert conditions for:

Long entry
Short entry
Bullish BOS
Bearish BOS
Bullish liquidity grab
Bearish liquidity grab
Price entering bullish orderblock
Price entering bearish orderblock

These alerts can be used to monitor BTC setups without constantly watching the chart.

How to Use

Use Bitcoin Market Edge as a BTC-focused confluence and risk-mapping tool.

Typical use cases include:

Finding long or short opportunities when multiple BTC-specific conditions align
Confirming trend direction with volatility-adjusted EMAs
Checking volume support through OBV and VWAP
Watching for liquidity grabs around pivots
Tracking orderblock reactions after BOS events
Comparing current chart direction with multi-timeframe bias
Mapping risk and reward levels after a signal

For stronger setups, look for signals that align with higher-timeframe bias, strong volume, VWAP direction, and nearby orderblock or liquidity-grab context.

Notes

This script is optimized for Bitcoin market analysis but can also be applied to other liquid crypto markets.
The quality of signals may vary depending on the selected exchange, timeframe, volume data, and market conditions.

Orderblocks and liquidity grabs are simplified structural models and should be used as context rather than guaranteed reversal zones.

The indicator does not execute trades automatically.

Disclaimer

This indicator is for educational and analytical purposes only.
It does not provide financial advice, trading recommendations, or guaranteed results. Always use proper risk management and perform your own analysis before entering any trade.

## Source Code

````pine
//@version=5
indicator("TraxisLab — Bitcoin Market Edge", "TraxisLab BTC", overlay=true, max_labels_count=500, max_lines_count=300, max_boxes_count=100, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════════
// 1 INPUTS
// ═══════════════════════════════════════════════════════════════════════════

grp_eng = "Engine"
i_mode = input.string("Standard", "Mode", options=["Aggressive", "Standard", "Conservative"], group=grp_eng)
i_score_min = input.int(0, "Score Override 0=Auto", group=grp_eng, minval=0, maxval=100, step=5)
i_cooldown = input.int(8, "Cooldown Bars", group=grp_eng, minval=1, maxval=50)
i_min_gap = input.int(8, "Min Long/Short Score Gap", group=grp_eng, minval=0, maxval=30)
i_confirmed = input.bool(true, "Confirmed Bars Only", group=grp_eng)

grp_ema = "Volatility Adjusted EMAs"
i_ema_f_len = input.int(21, "EMA Fast", group=grp_ema, minval=5, maxval=50)
i_ema_m_len = input.int(50, "EMA Mid", group=grp_ema, minval=20, maxval=120)
i_ema_s_len = input.int(200, "EMA Slow", group=grp_ema, minval=100, maxval=400)
i_vol_adj = input.bool(true, "Volatility Adjust EMA Speed", group=grp_ema)
i_atr_len = input.int(14, "ATR Length", group=grp_ema, minval=5, maxval=50)

grp_rsi = "Trend Adaptive RSI"
i_rsi_len = input.int(14, "RSI Length", group=grp_rsi, minval=5, maxval=30)
i_rsi_ob = input.int(70, "RSI Overbought", group=grp_rsi, minval=55, maxval=90)
i_rsi_os = input.int(30, "RSI Oversold", group=grp_rsi, minval=10, maxval=45)
i_rsi_mid_b = input.int(55, "Bull Mid Trend", group=grp_rsi, minval=45, maxval=65)
i_rsi_mid_s = input.int(45, "Bear Mid Trend", group=grp_rsi, minval=35, maxval=55)

grp_vol = "Volume OBV VWAP"
i_obv_len = input.int(20, "OBV Smoothing", group=grp_vol, minval=5, maxval=50)
i_vol_mult = input.float(1.2, "Volume MA Multiplier", group=grp_vol, minval=0.8, maxval=3.0, step=0.1)
i_vwap_dist = input.float(0.5, "VWAP Proximity ATR", group=grp_vol, minval=0.1, maxval=2.0, step=0.1)

grp_ob = "Orderblocks Liquidity"
i_ob_pivot = input.int(5, "Pivot Lookback", group=grp_ob, minval=2, maxval=20)
i_ob_max = input.int(5, "Max Active Orderblocks", group=grp_ob, minval=1, maxval=15)
i_ob_extend = input.int(50, "Orderblock Extend Bars", group=grp_ob, minval=10, maxval=200)
i_liq_grab = input.float(0.10, "Min Liquidity Grab Depth ATR", group=grp_ob, minval=0.02, maxval=1.0, step=0.01)
i_show_obs = input.bool(true, "Show Orderblocks", group=grp_ob)
i_show_grab = input.bool(true, "Show Liquidity Grabs", group=grp_ob)

grp_mtf = "Multi Timeframe Dashboard"
i_mtf_on = input.bool(true, "MTF Active", group=grp_mtf)
i_tf1 = input.timeframe("15", "TF 1", group=grp_mtf)
i_tf2 = input.timeframe("60", "TF 2", group=grp_mtf)
i_tf3 = input.timeframe("240", "TF 3", group=grp_mtf)
i_tf4 = input.timeframe("D", "TF 4", group=grp_mtf)

grp_risk = "Risk Targets"
i_atr_sl_mult = input.float(1.2, "SL ATR Multiplier", group=grp_risk, minval=0.3, maxval=4.0, step=0.1)
i_tp1_rr = input.float(1.0, "TP1 RR", group=grp_risk, minval=0.5, maxval=5.0, step=0.25)
i_tp2_rr = input.float(2.0, "TP2 RR", group=grp_risk, minval=1.0, maxval=8.0, step=0.25)
i_tp3_rr = input.float(3.0, "TP3 RR", group=grp_risk, minval=1.5, maxval=12.0, step=0.25)
i_show_levels = input.bool(true, "Show Entry SL TP Lines", group=grp_risk)

grp_vis = "Visuals"
i_show_dash = input.bool(true, "Show Dashboard", group=grp_vis)
i_dash_pos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_vis)
i_show_emas = input.bool(true, "Plot EMAs", group=grp_vis)
i_show_vwap = input.bool(true, "Plot VWAP", group=grp_vis)
i_label_size = input.string("Small", "Signal Label Size", options=["Tiny", "Small", "Normal"], group=grp_vis)

grp_col = "Colors"
c_bull = input.color(#00e5ff, "Bull", group=grp_col)
c_bear = input.color(#ff1744, "Bear", group=grp_col)
c_warn = input.color(#ffc107, "Warn", group=grp_col)
c_neu = input.color(#787b86, "Neutral", group=grp_col)
c_ob_b = input.color(color.new(#00e5ff, 80), "Bull OB Fill", group=grp_col)
c_ob_s = input.color(color.new(#ff1744, 80), "Bear OB Fill", group=grp_col)
c_vwap_c = input.color(#ffc107, "VWAP", group=grp_col)

// ═══════════════════════════════════════════════════════════════════════════
// 2 HELPERS
// ═══════════════════════════════════════════════════════════════════════════

f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        => size.small

f_pos(string s) =>
    switch s
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_arrow(int d) =>
    d > 0 ? "▲" : d < 0 ? "▼" : "-"

f_dir_color(int d) =>
    d > 0 ? c_bull : d < 0 ? c_bear : c_neu

f_dir_text(int d) =>
    d > 0 ? "BULL" : d < 0 ? "BEAR" : "NEU"

bar_ok = i_confirmed ? barstate.isconfirmed : true
sig_sz = f_size(i_label_size)
dash_pos = f_pos(i_dash_pos)

// ═══════════════════════════════════════════════════════════════════════════
// 3 VOLATILITY ADJUSTED EMAS
// ═══════════════════════════════════════════════════════════════════════════

atr_val = ta.atr(i_atr_len)
atr_avg = ta.sma(atr_val, 50)
vol_ratio = atr_avg > 0 ? atr_val / atr_avg : 1.0
vol_factor = math.max(0.5, math.min(2.0, vol_ratio))

f_va_ema(float src, int len, bool adj) =>
    float eff_len = adj ? math.max(3.0, len / vol_factor) : len
    float alpha = 2.0 / (eff_len + 1.0)
    float out = na
    out := na(out[1]) ? src : out[1] + alpha * (src - out[1])
    out

ema_f = f_va_ema(close, i_ema_f_len, i_vol_adj)
ema_m = f_va_ema(close, i_ema_m_len, i_vol_adj)
ema_s = f_va_ema(close, i_ema_s_len, i_vol_adj)

sa = nz(atr_val, close * 0.01)
ema_f_slope = sa > 0 ? (ema_f - ema_f[3]) / sa * 100 : 0.0
ema_m_slope = sa > 0 ? (ema_m - ema_m[5]) / sa * 100 : 0.0

trend_bull = ema_f > ema_m and ema_m > ema_s and ema_f_slope > 0.2
trend_bear = ema_f < ema_m and ema_m < ema_s and ema_f_slope < -0.2
trend_neutral = not trend_bull and not trend_bear

// ═══════════════════════════════════════════════════════════════════════════
// 4 TREND ADAPTIVE RSI
// ═══════════════════════════════════════════════════════════════════════════

rsi_val = ta.rsi(close, i_rsi_len)
rsi_slope = rsi_val - rsi_val[3]

rsi_bull_signal = trend_bull ? rsi_val > i_rsi_mid_b and rsi_slope > 0 : rsi_val < i_rsi_os and rsi_slope > 0
rsi_bear_signal = trend_bear ? rsi_val < i_rsi_mid_s and rsi_slope < 0 : rsi_val > i_rsi_ob and rsi_slope < 0
rsi_extreme_long = rsi_val < (trend_bear ? 25 : i_rsi_os)
rsi_extreme_short = rsi_val > (trend_bull ? 75 : i_rsi_ob)

// ═══════════════════════════════════════════════════════════════════════════
// 5 VOLUME OBV VWAP
// ═══════════════════════════════════════════════════════════════════════════

vol_src = nz(volume)
obv_raw = ta.cum(close > close[1] ? vol_src : close < close[1] ? -vol_src : 0.0)
obv_smooth = ta.ema(obv_raw, i_obv_len)
obv_slow = ta.ema(obv_smooth, i_obv_len * 2)
obv_slope = obv_smooth - obv_smooth[3]

obv_bull = obv_slope > 0 and obv_smooth > obv_slow
obv_bear = obv_slope < 0 and obv_smooth < obv_slow

vol_ma = ta.sma(vol_src, 20)
vol_strong = vol_src > vol_ma * i_vol_mult

var float vwap_pv = 0.0
var float vwap_v = 0.0
var int vwap_start = 0

new_day = ta.change(time("D")) != 0

if new_day
    vwap_pv := hlc3 * vol_src
    vwap_v := vol_src
    vwap_start := bar_index
else
    vwap_pv += hlc3 * vol_src
    vwap_v += vol_src

vwap_d = vwap_v > 0 ? vwap_pv / vwap_v : hlc3

near_vwap = math.abs(close - vwap_d) <= sa * i_vwap_dist
vwap_reclaim_bull = close > vwap_d and close[1] <= vwap_d
vwap_reclaim_bear = close < vwap_d and close[1] >= vwap_d

volflow_bull = obv_bull and (close > vwap_d or vwap_reclaim_bull)
volflow_bear = obv_bear and (close < vwap_d or vwap_reclaim_bear)

// ═══════════════════════════════════════════════════════════════════════════
// 6 ORDERBLOCKS LIQUIDITY GRABS
// ═══════════════════════════════════════════════════════════════════════════

pvh = ta.pivothigh(high, i_ob_pivot, i_ob_pivot)
pvl = ta.pivotlow(low, i_ob_pivot, i_ob_pivot)

var float last_pvh = na
var float last_pvl = na

if not na(pvh)
    last_pvh := pvh

if not na(pvl)
    last_pvl := pvl

bos_bull = not na(last_pvh) and close > last_pvh and close[1] <= last_pvh
bos_bear = not na(last_pvl) and close < last_pvl and close[1] >= last_pvl

var array<box> ob_boxes = array.new_box()
var array<float> ob_tops = array.new_float()
var array<float> ob_bots = array.new_float()
var array<bool> ob_is_bull = array.new_bool()

if bos_bull and bar_ok
    int ob_idx_bull = -1
    for j = 1 to 15
        if ob_idx_bull == -1 and close[j] < open[j]
            ob_idx_bull := j
    if ob_idx_bull > 0
        top_bull = math.max(open[ob_idx_bull], high[ob_idx_bull])
        bot_bull = math.min(close[ob_idx_bull], low[ob_idx_bull])
        bull_border = i_show_obs ? color.new(c_bull, 60) : color.new(c_bull, 100)
        bull_bg = i_show_obs ? c_ob_b : color.new(c_bull, 100)
        box_bull = box.new(left=bar_index - ob_idx_bull, top=top_bull, right=bar_index + i_ob_extend, bottom=bot_bull, xloc=xloc.bar_index, border_color=bull_border, bgcolor=bull_bg, border_width=1)
        array.push(ob_boxes, box_bull)
        array.push(ob_tops, top_bull)
        array.push(ob_bots, bot_bull)
        array.push(ob_is_bull, true)

if bos_bear and bar_ok
    int ob_idx_bear = -1
    for j = 1 to 15
        if ob_idx_bear == -1 and close[j] > open[j]
            ob_idx_bear := j
    if ob_idx_bear > 0
        top_bear = math.max(close[ob_idx_bear], high[ob_idx_bear])
        bot_bear = math.min(open[ob_idx_bear], low[ob_idx_bear])
        bear_border = i_show_obs ? color.new(c_bear, 60) : color.new(c_bear, 100)
        bear_bg = i_show_obs ? c_ob_s : color.new(c_bear, 100)
        box_bear = box.new(left=bar_index - ob_idx_bear, top=top_bear, right=bar_index + i_ob_extend, bottom=bot_bear, xloc=xloc.bar_index, border_color=bear_border, bgcolor=bear_bg, border_width=1)
        array.push(ob_boxes, box_bear)
        array.push(ob_tops, top_bear)
        array.push(ob_bots, bot_bear)
        array.push(ob_is_bull, false)

while array.size(ob_boxes) > i_ob_max
    old_box = array.shift(ob_boxes)
    box.delete(old_box)
    array.shift(ob_tops)
    array.shift(ob_bots)
    array.shift(ob_is_bull)

in_bull_ob = false
in_bear_ob = false

if array.size(ob_tops) > 0
    for k = 0 to array.size(ob_tops) - 1
        ob_top = array.get(ob_tops, k)
        ob_bot = array.get(ob_bots, k)
        is_bull = array.get(ob_is_bull, k)
        if low <= ob_top and high >= ob_bot
            if is_bull
                in_bull_ob := true
            else
                in_bear_ob := true

liq_grab_bull = not na(last_pvl) and low < last_pvl - sa * i_liq_grab and close > last_pvl and bar_ok
liq_grab_bear = not na(last_pvh) and high > last_pvh + sa * i_liq_grab and close < last_pvh and bar_ok

if i_show_grab and liq_grab_bull
    label.new(x=bar_index, y=low - sa * 0.3, text="LG", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bull, 30), style=label.style_label_up, textcolor=color.white, size=size.tiny, tooltip="Bullish Liquidity Grab")

if i_show_grab and liq_grab_bear
    label.new(x=bar_index, y=high + sa * 0.3, text="LG", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bear, 30), style=label.style_label_down, textcolor=color.white, size=size.tiny, tooltip="Bearish Liquidity Grab")

// ═══════════════════════════════════════════════════════════════════════════
// 7 MTF BIAS
// ═══════════════════════════════════════════════════════════════════════════

f_mtf_dir() =>
    ef = ta.ema(close, 21)
    em = ta.ema(close, 50)
    es = ta.ema(close, 200)
    r = ta.rsi(close, 14)
    sc = 0
    sc += ef > em ? 1 : ef < em ? -1 : 0
    sc += close > es ? 1 : close < es ? -1 : 0
    sc += r > 55 ? 1 : r < 45 ? -1 : 0
    sc

mtf1_sc = i_mtf_on ? request.security(syminfo.tickerid, i_tf1, f_mtf_dir(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : 0
mtf2_sc = i_mtf_on ? request.security(syminfo.tickerid, i_tf2, f_mtf_dir(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : 0
mtf3_sc = i_mtf_on ? request.security(syminfo.tickerid, i_tf3, f_mtf_dir(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : 0
mtf4_sc = i_mtf_on ? request.security(syminfo.tickerid, i_tf4, f_mtf_dir(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : 0

mtf1_dir = mtf1_sc >= 2 ? 1 : mtf1_sc <= -2 ? -1 : 0
mtf2_dir = mtf2_sc >= 2 ? 1 : mtf2_sc <= -2 ? -1 : 0
mtf3_dir = mtf3_sc >= 2 ? 1 : mtf3_sc <= -2 ? -1 : 0
mtf4_dir = mtf4_sc >= 2 ? 1 : mtf4_sc <= -2 ? -1 : 0

mtf_bull_count = (mtf1_dir > 0 ? 1 : 0) + (mtf2_dir > 0 ? 1 : 0) + (mtf3_dir > 0 ? 1 : 0) + (mtf4_dir > 0 ? 1 : 0)
mtf_bear_count = (mtf1_dir < 0 ? 1 : 0) + (mtf2_dir < 0 ? 1 : 0) + (mtf3_dir < 0 ? 1 : 0) + (mtf4_dir < 0 ? 1 : 0)

// ═══════════════════════════════════════════════════════════════════════════
// 8 CONFLUENCE SCORING WITH MATRIX
// ═══════════════════════════════════════════════════════════════════════════

var matrix<int> weights = matrix.new<int>(5, 2, 0)

matrix.set(weights, 0, 0, trend_bull ? 18 : ema_f > ema_m ? 8 : 0)
matrix.set(weights, 0, 1, trend_bear ? 18 : ema_f < ema_m ? 8 : 0)
matrix.set(weights, 1, 0, rsi_extreme_long ? 12 : rsi_bull_signal ? 8 : 0)
matrix.set(weights, 1, 1, rsi_extreme_short ? 12 : rsi_bear_signal ? 8 : 0)
matrix.set(weights, 2, 0, volflow_bull ? 14 : close > vwap_d ? 6 : 0)
matrix.set(weights, 2, 1, volflow_bear ? 14 : close < vwap_d ? 6 : 0)
matrix.set(weights, 3, 0, (in_bull_ob ? 10 : 0) + (bos_bull ? 8 : 0) + (liq_grab_bull ? 12 : 0))
matrix.set(weights, 3, 1, (in_bear_ob ? 10 : 0) + (bos_bear ? 8 : 0) + (liq_grab_bear ? 12 : 0))
matrix.set(weights, 4, 0, mtf_bull_count * 4)
matrix.set(weights, 4, 1, mtf_bear_count * 4)

int long_score_base = 0
int short_score_base = 0

for r = 0 to 4
    long_score_base += matrix.get(weights, r, 0)
    short_score_base += matrix.get(weights, r, 1)

int long_score = long_score_base
int short_score = short_score_base

if vol_strong
    if long_score_base > short_score_base
        long_score += 6
    else if short_score_base > long_score_base
        short_score += 6
    else
        long_score += 3
        short_score += 3

long_score := math.max(0, math.min(100, long_score))
short_score := math.max(0, math.min(100, short_score))

auto_thresh = switch i_mode
    "Aggressive" => 35
    "Standard" => 50
    "Conservative" => 65
    => 50

thresh = i_score_min > 0 ? i_score_min : auto_thresh
score_gap = math.abs(long_score - short_score)

// ═══════════════════════════════════════════════════════════════════════════
// 9 SIGNAL GENERATION AND RISK
// ═══════════════════════════════════════════════════════════════════════════

var int last_long_bar = -9999
var int last_short_bar = -9999
var int active_dir = 0
var int active_bar = -9999
var float active_en = na
var float active_sl = na
var float active_tp1 = na
var float active_tp2 = na
var float active_tp3 = na

cd_long = bar_index - last_long_bar > i_cooldown
cd_short = bar_index - last_short_bar > i_cooldown

if active_dir == 1 and (low <= active_sl or high >= active_tp1 or bar_index - active_bar > 100)
    active_dir := 0

if active_dir == -1 and (high >= active_sl or low <= active_tp1 or bar_index - active_bar > 100)
    active_dir := 0

qual_long = long_score >= thresh and cd_long and bar_ok and score_gap >= i_min_gap and long_score > short_score
qual_short = short_score >= thresh and cd_short and bar_ok and score_gap >= i_min_gap and short_score > long_score

sig_long = qual_long and active_dir != 1
sig_short = qual_short and active_dir != -1

if sig_long
    last_long_bar := bar_index
    active_dir := 1
    active_bar := bar_index
    active_en := close
    risk_long = sa * i_atr_sl_mult
    active_sl := close - risk_long
    active_tp1 := close + risk_long * i_tp1_rr
    active_tp2 := close + risk_long * i_tp2_rr
    active_tp3 := close + risk_long * i_tp3_rr

if sig_short
    last_short_bar := bar_index
    active_dir := -1
    active_bar := bar_index
    active_en := close
    risk_short = sa * i_atr_sl_mult
    active_sl := close + risk_short
    active_tp1 := close - risk_short * i_tp1_rr
    active_tp2 := close - risk_short * i_tp2_rr
    active_tp3 := close - risk_short * i_tp3_rr

// ═══════════════════════════════════════════════════════════════════════════
// 10 PLOTS AND LABELS
// ═══════════════════════════════════════════════════════════════════════════

plot(i_show_emas ? ema_f : na, "EMA Fast", color.new(c_bull, 60), 1)
plot(i_show_emas ? ema_m : na, "EMA Mid", color.new(c_warn, 60), 1)
plot(i_show_emas ? ema_s : na, "EMA Slow", color.new(c_neu, 60), 1)
plot(i_show_vwap and bar_index >= vwap_start ? vwap_d : na, "VWAP-D", c_vwap_c, 2)

var label lbl_ef = na
var label lbl_em = na
var label lbl_es = na
var label lbl_vw = na

if barstate.islast
    if not na(lbl_ef)
        label.delete(lbl_ef)
    if not na(lbl_em)
        label.delete(lbl_em)
    if not na(lbl_es)
        label.delete(lbl_es)
    if not na(lbl_vw)
        label.delete(lbl_vw)
    if i_show_emas
        lbl_ef := label.new(x=bar_index + 5, y=ema_f, text=str.tostring(i_ema_f_len) + " EMA", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bull, 85), style=label.style_label_left, textcolor=c_bull, size=size.tiny)
        lbl_em := label.new(x=bar_index + 5, y=ema_m, text=str.tostring(i_ema_m_len) + " EMA", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_warn, 85), style=label.style_label_left, textcolor=c_warn, size=size.tiny)
        lbl_es := label.new(x=bar_index + 5, y=ema_s, text=str.tostring(i_ema_s_len) + " EMA", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_neu, 85), style=label.style_label_left, textcolor=c_neu, size=size.tiny)
    if i_show_vwap
        lbl_vw := label.new(x=bar_index + 5, y=vwap_d, text="VWAP", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_vwap_c, 70), style=label.style_label_left, textcolor=c_vwap_c, size=size.tiny)

if sig_long
    tt_long = "BTC LONG\nScore: " + str.tostring(long_score) + "/" + str.tostring(thresh) + "\nEntry: " + str.tostring(active_en, format.mintick) + "\nSL: " + str.tostring(active_sl, format.mintick) + "\nTP1: " + str.tostring(active_tp1, format.mintick) + "\nTP2: " + str.tostring(active_tp2, format.mintick) + "\nTP3: " + str.tostring(active_tp3, format.mintick) + "\nMTF: " + str.tostring(mtf_bull_count) + " Bull / " + str.tostring(mtf_bear_count) + " Bear"
    label.new(x=bar_index, y=low - sa * 0.5, text="L", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bull, 0), style=label.style_label_up, textcolor=color.white, size=sig_sz, textalign=text.align_center, tooltip=tt_long)

if sig_short
    tt_short = "BTC SHORT\nScore: " + str.tostring(short_score) + "/" + str.tostring(thresh) + "\nEntry: " + str.tostring(active_en, format.mintick) + "\nSL: " + str.tostring(active_sl, format.mintick) + "\nTP1: " + str.tostring(active_tp1, format.mintick) + "\nTP2: " + str.tostring(active_tp2, format.mintick) + "\nTP3: " + str.tostring(active_tp3, format.mintick) + "\nMTF: " + str.tostring(mtf_bull_count) + " Bull / " + str.tostring(mtf_bear_count) + " Bear"
    label.new(x=bar_index, y=high + sa * 0.5, text="S", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bear, 0), style=label.style_label_down, textcolor=color.white, size=sig_sz, textalign=text.align_center, tooltip=tt_short)

// ═══════════════════════════════════════════════════════════════════════════
// 11 ENTRY SL TP LEVELS
// ═══════════════════════════════════════════════════════════════════════════

var array<line> lvl_lines = array.new_line()
var array<label> lvl_labels = array.new_label()

if barstate.islast
    if array.size(lvl_lines) > 0
        for i = 0 to array.size(lvl_lines) - 1
            line.delete(array.get(lvl_lines, i))
    array.clear(lvl_lines)
    if array.size(lvl_labels) > 0
        for i = 0 to array.size(lvl_labels) - 1
            label.delete(array.get(lvl_labels, i))
    array.clear(lvl_labels)
    if i_show_levels and active_dir != 0 and not na(active_en)
        x1 = active_bar
        x2 = bar_index + 10
        array.push(lvl_lines, line.new(x1=x1, y1=active_en, x2=x2, y2=active_en, xloc=xloc.bar_index, color=color.new(color.white, 30), width=1, style=line.style_dashed))
        array.push(lvl_lines, line.new(x1=x1, y1=active_sl, x2=x2, y2=active_sl, xloc=xloc.bar_index, color=color.new(c_bear, 15), width=1, style=line.style_dotted))
        array.push(lvl_lines, line.new(x1=x1, y1=active_tp1, x2=x2, y2=active_tp1, xloc=xloc.bar_index, color=color.new(c_bull, 15), width=1, style=line.style_dotted))
        array.push(lvl_lines, line.new(x1=x1, y1=active_tp2, x2=x2, y2=active_tp2, xloc=xloc.bar_index, color=color.new(c_bull, 35), width=1, style=line.style_dotted))
        array.push(lvl_lines, line.new(x1=x1, y1=active_tp3, x2=x2, y2=active_tp3, xloc=xloc.bar_index, color=color.new(c_bull, 55), width=1, style=line.style_dotted))
        array.push(lvl_labels, label.new(x=x2 + 1, y=active_en, text="EN", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.white, 75), style=label.style_label_left, textcolor=color.white, size=size.tiny))
        array.push(lvl_labels, label.new(x=x2 + 1, y=active_sl, text="SL", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bear, 75), style=label.style_label_left, textcolor=c_bear, size=size.tiny))
        array.push(lvl_labels, label.new(x=x2 + 1, y=active_tp1, text="TP1", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bull, 75), style=label.style_label_left, textcolor=c_bull, size=size.tiny))
        array.push(lvl_labels, label.new(x=x2 + 1, y=active_tp2, text="TP2", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bull, 80), style=label.style_label_left, textcolor=c_bull, size=size.tiny))
        array.push(lvl_labels, label.new(x=x2 + 1, y=active_tp3, text="TP3", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_bull, 85), style=label.style_label_left, textcolor=c_bull, size=size.tiny))

// ═══════════════════════════════════════════════════════════════════════════
// 12 DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════

var table dash = table.new(dash_pos, 3, 8, bgcolor=color.new(#0f1119, 10), border_color=color.new(#2a2d3a, 60), border_width=1)

if i_show_dash and barstate.islast
    hdr_bg = color.new(#1a1d28, 30)
    cur_dir = trend_bull ? 1 : trend_bear ? -1 : 0
    act_txt = active_dir == 1 ? "LONG" : active_dir == -1 ? "SHORT" : "-"
    act_col = active_dir == 1 ? c_bull : active_dir == -1 ? c_bear : c_neu
    table.cell(dash, 0, 0, "BTC EDGE", text_color=color.white, text_size=size.small, bgcolor=hdr_bg)
    table.cell(dash, 1, 0, i_mode, text_color=c_warn, text_size=size.tiny, bgcolor=hdr_bg)
    table.cell(dash, 2, 0, ">=" + str.tostring(thresh), text_color=c_warn, text_size=size.tiny, bgcolor=hdr_bg)
    table.cell(dash, 0, 1, "TF", text_color=#5a5e70, text_size=size.tiny)
    table.cell(dash, 1, 1, timeframe.period, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 2, 1, f_dir_text(cur_dir) + " " + f_arrow(cur_dir), text_color=f_dir_color(cur_dir), text_size=size.tiny)
    table.cell(dash, 0, 2, "MTF1", text_color=#5a5e70, text_size=size.tiny)
    table.cell(dash, 1, 2, i_tf1, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 2, 2, f_dir_text(mtf1_dir) + " " + f_arrow(mtf1_dir), text_color=f_dir_color(mtf1_dir), text_size=size.tiny)
    table.cell(dash, 0, 3, "MTF2", text_color=#5a5e70, text_size=size.tiny)
    table.cell(dash, 1, 3, i_tf2, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 2, 3, f_dir_text(mtf2_dir) + " " + f_arrow(mtf2_dir), text_color=f_dir_color(mtf2_dir), text_size=size.tiny)
    table.cell(dash, 0, 4, "MTF3", text_color=#5a5e70, text_size=size.tiny)
    table.cell(dash, 1, 4, i_tf3, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 2, 4, f_dir_text(mtf3_dir) + " " + f_arrow(mtf3_dir), text_color=f_dir_color(mtf3_dir), text_size=size.tiny)
    table.cell(dash, 0, 5, "MTF4", text_color=#5a5e70, text_size=size.tiny)
    table.cell(dash, 1, 5, i_tf4, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 2, 5, f_dir_text(mtf4_dir) + " " + f_arrow(mtf4_dir), text_color=f_dir_color(mtf4_dir), text_size=size.tiny)
    table.cell(dash, 0, 6, "Score", text_color=#5a5e70, text_size=size.tiny)
    table.cell(dash, 1, 6, "L" + str.tostring(long_score), text_color=c_bull, text_size=size.tiny)
    table.cell(dash, 2, 6, "S" + str.tostring(short_score), text_color=c_bear, text_size=size.tiny)
    table.cell(dash, 0, 7, "Active", text_color=#5a5e70, text_size=size.tiny)
    table.cell(dash, 1, 7, act_txt, text_color=act_col, text_size=size.tiny)
    table.cell(dash, 2, 7, "Volx" + str.tostring(vol_factor, "#.0"), text_color=vol_strong ? c_warn : c_neu, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// 13 ALERTS
// ═══════════════════════════════════════════════════════════════════════════

alertcondition(sig_long, "Long", "BTC Edge: LONG entry")
alertcondition(sig_short, "Short", "BTC Edge: SHORT entry")
alertcondition(bos_bull, "BOS Bull", "BTC Edge: Bullish BOS")
alertcondition(bos_bear, "BOS Bear", "BTC Edge: Bearish BOS")
alertcondition(liq_grab_bull, "Liquidity Grab Bull", "BTC Edge: Bullish Liquidity Grab")
alertcondition(liq_grab_bear, "Liquidity Grab Bear", "BTC Edge: Bearish Liquidity Grab")
alertcondition(in_bull_ob, "In Bull OB", "BTC Edge: Price entered Bullish Orderblock")
alertcondition(in_bear_ob, "In Bear OB", "BTC Edge: Price entered Bearish Orderblock")
````
