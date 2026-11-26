# TraxisLab - Reversal Engine

- url: https://www.tradingview.com/script/0kBpLwn1/
- type: indicator
- pine_id: PUB;4bc00d6453294368bee24c2f4b200387
- version: 1.0

## Description

TraxisLab Reversal Engine is a precision-focused reversal and continuation framework designed to identify high-confluence long and short opportunities using trend, momentum, volume, multi-timeframe confirmation, VWAP context, vector candles, and smart trade management logic.

This version includes a stronger anti-repaint structure, confirmed-bar signal handling, EMA slope filtering, volume confirmation, score gap validation, pending entry previews, and multi-timeframe alignment.

The goal of the Reversal Engine is to provide a complete visual decision layer for traders who want cleaner signals, stronger filtering, and structured trade levels directly on the chart.

Core Concept

The script uses a scoring-based signal engine to evaluate both bullish and bearish conditions.

Instead of triggering signals from one single condition, it combines multiple layers of confirmation:

Trend direction
EMA alignment
EMA slope strength
RSI and stochastic momentum
ADX trend strength
Volume confirmation
VWAP context
Vector candle activity
Market structure signals
Multi-timeframe direction
Score gap between long and short conditions

A signal is only shown when the selected conditions reach the required threshold and pass the active filters.

Signal Modes

The indicator includes three signal modes:

Aggressive
More responsive signals with lower confirmation requirements.

Standard
Balanced signal logic for general use.

Conservative
Stricter filtering for higher-quality but fewer signals.

A manual score override is also available for users who want full control over the required signal threshold.

Anti-Repaint Logic

This version includes a confirmed-bar option to reduce repainting behavior.

When enabled, signals are only generated after the candle closes.
This helps avoid signals appearing and disappearing during live candle formation.

Multi-timeframe data is also requested with lookahead disabled to support cleaner, non-repainting confirmation behavior.

Multi-Timeframe Confirmation

The script can analyze multiple timeframes at once:

5-minute
15-minute
1-hour
4-hour
Daily

Each timeframe is evaluated using EMA structure and RSI bias.
The user can choose how many timeframes must agree before a long or short signal is allowed.

Optional MTF score bonuses can be used to strengthen signals when higher-timeframe alignment is present.

Trend & Momentum Filters

The Reversal Engine includes several filters designed to improve signal quality:

EMA Filter
Uses fast, mid, and slow EMAs to evaluate trend structure.

EMA Slope Filter
Measures the slope of the fast EMA relative to ATR, helping confirm that price has enough directional strength.

ADX Filter
Filters out weak or low-trend environments.

RSI & Stochastic Context
Adds momentum and exhaustion information to the signal engine.

Volume Filter
Requires volume to be above a moving average threshold before signals are allowed.

Vector Candles

The script includes integrated Vector Candle logic.

Vector candles highlight candles with unusually strong volume-spread force compared to recent average activity.

The indicator separates:

Regular bullish vector candles
Regular bearish vector candles
Extreme bullish vector candles
Extreme bearish vector candles
Normal bullish and bearish candles

This helps traders identify high-effort candles, potential exhaustion, strong participation, or aggressive directional moves.

VWAP Context

The indicator includes multiple VWAP references:

Daily VWAP
Weekly VWAP
Monthly VWAP
4H VWAP

These levels provide clean institutional-style reference points for price reaction, trend context, mean reversion, and continuation setups.

VWAP labels can be enabled to keep the chart easy to read.

Market Structure

The script includes optional structure visualization such as:

BOS signals
CHoCH signals
Liquidity pivot markers

These tools help traders understand where price may be breaking structure, shifting direction, or reacting around important swing areas.

Pending Warnings

Pending warnings act as entry previews.

They appear when the setup is close to reaching the required score threshold and the important entry gates are already aligned.

This can help traders prepare for a possible signal before the full confirmation appears.

Pending warnings include their own cooldown to avoid excessive chart noise.

Mutual Exclusion & Trade Lock

To avoid conflicting signals, the script includes mutual exclusion logic and trade locking.

This helps prevent rapid back-and-forth long and short signals during choppy conditions.

The trade lock setting controls how long the engine waits before allowing a new trade direction.

Targets, Stops & Smart Trail

The script includes visual trade management tools:

Stop-loss levels
Up to three take-profit levels
RR-based target calculation
ATR-based stop buffer
Optional smart trailing logic

This gives traders a structured way to visualize risk and potential reward directly after a signal.

Visual Features

The script includes a complete visual overlay with:

Buy and sell labels
Pending warning labels
Vector candle coloring
Vector dots and extreme vector labels
Multi-timeframe trend information
VWAP levels
BOS / CHoCH structure markers
Liquidity pivots
Smart trailing line
Entry, stop, and take-profit levels
Compact statistics panel

Most visual elements can be enabled, disabled, or customized in the settings.

Alerts

The indicator is designed for alert-based workflows and can be used to monitor potential reversal or continuation setups.

Typical alert use cases include:

Long signal
Short signal
Pending long warning
Pending short warning
Structure shift
VWAP reaction
Vector candle event
Trail or level-based management events
How to Use

Use the Reversal Engine as a confluence-based decision support tool.

It is best used to identify moments where several independent conditions align in the same direction.

Typical use cases include:

Finding possible reversal entries after exhaustion
Confirming continuation trades with trend and MTF alignment
Filtering trades with EMA slope and volume confirmation
Using VWAP levels as reaction or mean-reversion zones
Identifying high-effort vector candles near key levels
Managing trades visually with RR-based targets and ATR-based stops

For stronger setups, look for signals that appear near important structure, VWAP levels, liquidity pivots, or after clear momentum exhaustion.

Notes

This script is an analytical overlay and does not execute trades automatically.
Signals are based on configurable scoring and filter logic.
No signal should be treated as guaranteed.

The confirmed-bar option is designed to reduce intrabar repaint behavior, but all indicators using live market data can still change while a candle is open if confirmation is disabled.

Multi-timeframe values depend on the selected chart, symbol, and timeframe settings.

Disclaimer

This indicator is for educational and analytical purposes only.
It does not provide financial advice, trading recommendations, or guaranteed results. Always use proper risk management and perform your own analysis before entering any trade.

## Source Code

````pine
//@version=5
// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  TRAXISLAB — REVERSAL ENGINE PRO v4.1 (PRECISION UPDATE)                ║
// ║  + barstate.isconfirmed (Anti-Repaint)                                   ║
// ║  + EMA Slope Filter · Volume Confirmation · Score Gap                    ║
// ║  + Tunable Thresholds · Pending = Entry-Preview (same gates)             ║
// ║  Vector Candles · VWAP · Mutual Exclusion · Smart Trail · MTF            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
indicator("TraxisLab — Reversal Engine", "TraxisLab REV", true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=500,
     max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════════
// │ 1  INPUTS                                                                │
// ═══════════════════════════════════════════════════════════════════════════

grp_sig = "⟐  Signal Engine"
i_mode      = input.string("Standard", "Signal Mode", options=["Aggressive", "Standard", "Conservative"], group=grp_sig)
i_score_min = input.int(0, "Score Override (0=Auto)", group=grp_sig, minval=0, maxval=90, step=5)
i_cooldown  = input.int(8, "Cooldown (Bars)", group=grp_sig, minval=1, maxval=50)
i_pending   = input.bool(true, "Pending Warnings", group=grp_sig)
i_pend_pct  = input.int(80, "Pending at (%)", group=grp_sig, minval=50, maxval=95, step=5, tooltip="80% of threshold = warning zone. Warning only appears when ALL entry gates (MTF, slope, gap) are already met — only score is missing")
i_pend_cd   = input.int(8, "Pending Cooldown", group=grp_sig, minval=3, maxval=30, tooltip="Min bars between warnings")
i_lock_bars = input.int(20, "Trade Lock (Bars)", group=grp_sig, minval=5, maxval=100)
i_min_gap   = input.int(5, "Min Score Gap (L vs S)", group=grp_sig, minval=0, maxval=20, step=5)
i_confirmed = input.bool(true, "Confirmed Bars Only", group=grp_sig, tooltip="Anti-Repaint: signals only after bar close")

grp_trend = "⟐  Trend Filter"
i_ema_fast  = input.int(21, "EMA Fast", group=grp_trend, minval=5, maxval=50)
i_ema_mid   = input.int(50, "EMA Mid", group=grp_trend, minval=20, maxval=100)
i_ema_slow  = input.int(200, "EMA Slow", group=grp_trend, minval=100, maxval=300)
i_trend_on  = input.bool(true, "EMA Filter Active", group=grp_trend)
i_slope_on  = input.bool(true, "EMA Slope Filter", group=grp_trend)
i_slope_min = input.float(0.2, "Min Slope (%ATR)", group=grp_trend, minval=0.0, maxval=2.0, step=0.1)

grp_volat = "⟐  Volatility"
i_atr_len  = input.int(14, "ATR Length", group=grp_volat, minval=5, maxval=50)
i_atr_mult = input.float(1.5, "ATR Multiplier (Trail)", group=grp_volat, minval=0.5, maxval=4.0, step=0.1)

grp_struct = "⟐  Structure"
i_pvt_len   = input.int(5, "Pivot Lookback", group=grp_struct, minval=2, maxval=20)
i_struct_on = input.bool(true, "BOS/CHoCH Signals", group=grp_struct)

grp_mom = "⟐  Momentum"
i_rsi_len  = input.int(14, "RSI Length", group=grp_mom, minval=5, maxval=30)
i_rsi_ob   = input.int(70, "RSI Overbought", group=grp_mom, minval=60, maxval=90)
i_rsi_os   = input.int(30, "RSI Oversold", group=grp_mom, minval=10, maxval=40)
i_adx_len  = input.int(14, "ADX Length", group=grp_mom, minval=5, maxval=30)
i_adx_min  = input.int(20, "ADX Minimum", group=grp_mom, minval=10, maxval=40)
i_adx_on   = input.bool(true, "ADX Filter Active", group=grp_mom)
i_vol_on   = input.bool(true, "Volume Filter Active", group=grp_mom)
i_vol_mult = input.float(1.1, "Volume Threshold (×MA)", group=grp_mom, minval=0.8, maxval=2.0, step=0.1)

grp_tp = "⟐  Targets & Stops"
i_tp_count = input.int(3, "Take-Profit Count", group=grp_tp, minval=1, maxval=3)
i_tp1_mult = input.float(1.0, "TP1 (RR-x)", group=grp_tp, minval=0.5, maxval=5.0, step=0.25)
i_tp2_mult = input.float(2.0, "TP2 (RR-x)", group=grp_tp, minval=1.0, maxval=8.0, step=0.25)
i_tp3_mult = input.float(3.0, "TP3 (RR-x)", group=grp_tp, minval=1.5, maxval=12.0, step=0.25)
i_sl_atr   = input.float(1.2, "SL Buffer (ATR-x)", group=grp_tp, minval=0.3, maxval=3.0, step=0.1)

grp_mtf = "⟐  Multi-Timeframe"
i_mtf_on    = input.bool(true, "MTF Active", group=grp_mtf)
i_mtf_min   = input.int(2, "Min TFs", group=grp_mtf, minval=1, maxval=5)
i_mtf_score = input.bool(true, "MTF Score Bonus", group=grp_mtf)
i_mtf_5m    = input.bool(true, "5m",  group=grp_mtf, inline="mtf1")
i_mtf_15m   = input.bool(true, "15m", group=grp_mtf, inline="mtf1")
i_mtf_1h    = input.bool(true, "1H",  group=grp_mtf, inline="mtf1")
i_mtf_4h    = input.bool(true, "4H",  group=grp_mtf, inline="mtf2")
i_mtf_1d    = input.bool(true, "1D",  group=grp_mtf, inline="mtf2")

grp_vc = "⟐  Vector Candles"
i_vc_on       = input.bool(true, "Active", group=grp_vc)
i_vc_lookback = input.int(20, "Lookback", group=grp_vc, minval=5, maxval=100)
i_vc_thresh   = input.float(1.5, "Threshold (×)", group=grp_vc, minval=1.0, maxval=5.0, step=0.1)
i_vc_extreme  = input.float(2.5, "Extreme (×)", group=grp_vc, minval=1.5, maxval=8.0, step=0.1)
i_vc_minbody  = input.float(0.3, "Min Body", group=grp_vc, minval=0.1, maxval=0.8, step=0.05)
c_vc_bull     = input.color(#00e5ff, "Bull Vec", group=grp_vc, inline="v1")
c_vc_bull_x   = input.color(#00bfa5, "Bull Ext", group=grp_vc, inline="v1")
c_vc_bear     = input.color(#ff1744, "Bear Vec", group=grp_vc, inline="v2")
c_vc_bear_x   = input.color(#d500f9, "Bear Ext", group=grp_vc, inline="v2")
c_vc_neu_up   = input.color(#26a69a, "Norm ▲", group=grp_vc, inline="v3")
c_vc_neu_dn   = input.color(#ef5350, "Norm ▼", group=grp_vc, inline="v3")
i_vc_dim      = input.int(40, "Dim (%)", group=grp_vc, minval=0, maxval=80, step=5)
i_vc_dots     = input.bool(true, "Dots", group=grp_vc)
i_vc_labels   = input.bool(true, "Ext Labels", group=grp_vc)

grp_vwap = "⟐  VWAP"
i_vwap_d   = input.bool(true,  "D",  group=grp_vwap, inline="vd")
c_vwap_d   = input.color(#ffc107, "", group=grp_vwap, inline="vd")
i_vwap_w   = input.bool(true,  "W",  group=grp_vwap, inline="vw")
c_vwap_w   = input.color(#00e676, "", group=grp_vwap, inline="vw")
i_vwap_m   = input.bool(true,  "M",  group=grp_vwap, inline="vm")
c_vwap_m   = input.color(#ff1744, "", group=grp_vwap, inline="vm")
i_vwap_h   = input.bool(true,  "4H", group=grp_vwap, inline="vh")
c_vwap_h   = input.color(#e040fb, "", group=grp_vwap, inline="vh")
i_vwap_lbl = input.bool(true,  "Lbl",group=grp_vwap)
i_vwap_wpx = input.int(2,      "W",  group=grp_vwap, minval=1, maxval=4)

grp_vis = "⟐  Visuals"
i_show_trail  = input.bool(true, "Trail", group=grp_vis)
i_show_levels = input.bool(true, "Levels", group=grp_vis)
i_show_struct = input.bool(true, "Structure", group=grp_vis)
i_show_liq    = input.bool(true, "Liq Pivots", group=grp_vis)
i_show_stats  = input.bool(true, "Stats", group=grp_vis)
i_max_levels  = input.int(1, "Max Sets", group=grp_vis, minval=1, maxval=3)
i_sig_size    = input.string("Small", "Sig Size", options=["Tiny", "Small", "Normal"], group=grp_vis)
i_lvl_style   = input.string("Dotted", "Lvl Style", options=["Solid", "Dashed", "Dotted"], group=grp_vis)

grp_col = "⟐  Colors"
c_bull      = input.color(#00e5ff, "Bull", group=grp_col)
c_bear      = input.color(#ff1744, "Bear", group=grp_col)
c_neutral   = input.color(#787b86, "Neutral", group=grp_col)
c_warn      = input.color(#ffc107, "Warn", group=grp_col)
c_bos_col   = input.color(#2962ff, "BOS", group=grp_col)
c_choch_col = input.color(#e040fb, "CHoCH", group=grp_col)

// ═══════════════════════════════════════════════════════════════════════════
// │ HELPERS                                                                  │
// ═══════════════════════════════════════════════════════════════════════════

f_size(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal
f_lstyle(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
sig_sz = f_size(i_sig_size)
lvl_ls = f_lstyle(i_lvl_style)
bool bar_ok = i_confirmed ? barstate.isconfirmed : true

// ═══════════════════════════════════════════════════════════════════════════
// │ 2  CORE                                                                  │
// ═══════════════════════════════════════════════════════════════════════════

atr_val = ta.atr(i_atr_len)
sa = nz(atr_val, close * 0.01)
ema_f = ta.ema(close, i_ema_fast)
ema_m = ta.ema(close, i_ema_mid)
ema_s = ta.ema(close, i_ema_slow)
rsi_val = ta.rsi(close, i_rsi_len)

ema_f_slope = sa > 0 ? (ema_f - ema_f[3]) / sa * 100 : 0.0
bool slope_bull = not i_slope_on or ema_f_slope > i_slope_min
bool slope_bear = not i_slope_on or ema_f_slope < -i_slope_min

f_adx(int len) =>
    up = high - high[1]
    dn = low[1] - low
    pDM = up > dn and up > 0 ? up : 0.0
    nDM = dn > up and dn > 0 ? dn : 0.0
    tr_val = ta.tr(true)
    pDI = 100 * ta.rma(pDM, len) / ta.rma(tr_val, len)
    nDI = 100 * ta.rma(nDM, len) / ta.rma(tr_val, len)
    dx = math.abs(pDI - nDI) / (pDI + nDI) * 100
    ta.rma(dx, len)

adx_val = f_adx(i_adx_len)
vol_ma = ta.sma(volume, 20)
vol_above = volume > vol_ma * i_vol_mult
stoch_k = ta.stoch(close, high, low, 14)

// ═══════════════════════════════════════════════════════════════════════════
// │ 2B  MTF — non-repainting                                                │
// ═══════════════════════════════════════════════════════════════════════════

f_mtf_dir() =>
    mtf_ef = ta.ema(close, 21)
    mtf_em = ta.ema(close, 50)
    mtf_es = ta.ema(close, 200)
    mtf_r  = ta.rsi(close, 14)
    float sc = 0.0
    sc += mtf_ef > mtf_em ? 1.0 : mtf_ef < mtf_em ? -1.0 : 0.0
    sc += close > mtf_es ? 1.0 : close < mtf_es ? -1.0 : 0.0
    sc += mtf_r > 55 ? 1.0 : mtf_r < 45 ? -1.0 : 0.0
    sc

mtf_5m_sc  = i_mtf_on and i_mtf_5m  ? request.security(syminfo.tickerid, "5",   f_mtf_dir(), lookahead=barmerge.lookahead_off) : 0.0
mtf_15m_sc = i_mtf_on and i_mtf_15m ? request.security(syminfo.tickerid, "15",  f_mtf_dir(), lookahead=barmerge.lookahead_off) : 0.0
mtf_1h_sc  = i_mtf_on and i_mtf_1h  ? request.security(syminfo.tickerid, "60",  f_mtf_dir(), lookahead=barmerge.lookahead_off) : 0.0
mtf_4h_sc  = i_mtf_on and i_mtf_4h  ? request.security(syminfo.tickerid, "240", f_mtf_dir(), lookahead=barmerge.lookahead_off) : 0.0
mtf_1d_sc  = i_mtf_on and i_mtf_1d  ? request.security(syminfo.tickerid, "D",   f_mtf_dir(), lookahead=barmerge.lookahead_off) : 0.0

int mtf_5m_dir  = mtf_5m_sc >= 2 ? 1 : mtf_5m_sc <= -2 ? -1 : 0
int mtf_15m_dir = mtf_15m_sc >= 2 ? 1 : mtf_15m_sc <= -2 ? -1 : 0
int mtf_1h_dir  = mtf_1h_sc >= 2 ? 1 : mtf_1h_sc <= -2 ? -1 : 0
int mtf_4h_dir  = mtf_4h_sc >= 2 ? 1 : mtf_4h_sc <= -2 ? -1 : 0
int mtf_1d_dir  = mtf_1d_sc >= 2 ? 1 : mtf_1d_sc <= -2 ? -1 : 0

int mtf_bull_cnt = 0, int mtf_bear_cnt = 0
if i_mtf_5m
    mtf_bull_cnt += mtf_5m_dir > 0 ? 1 : 0
    mtf_bear_cnt += mtf_5m_dir < 0 ? 1 : 0
if i_mtf_15m
    mtf_bull_cnt += mtf_15m_dir > 0 ? 1 : 0
    mtf_bear_cnt += mtf_15m_dir < 0 ? 1 : 0
if i_mtf_1h
    mtf_bull_cnt += mtf_1h_dir > 0 ? 1 : 0
    mtf_bear_cnt += mtf_1h_dir < 0 ? 1 : 0
if i_mtf_4h
    mtf_bull_cnt += mtf_4h_dir > 0 ? 1 : 0
    mtf_bear_cnt += mtf_4h_dir < 0 ? 1 : 0
if i_mtf_1d
    mtf_bull_cnt += mtf_1d_dir > 0 ? 1 : 0
    mtf_bear_cnt += mtf_1d_dir < 0 ? 1 : 0

int mtf_active = (i_mtf_5m ? 1 : 0) + (i_mtf_15m ? 1 : 0) + (i_mtf_1h ? 1 : 0) + (i_mtf_4h ? 1 : 0) + (i_mtf_1d ? 1 : 0)
bool mtf_confirms_long  = i_mtf_on ? mtf_bull_cnt >= i_mtf_min : true
bool mtf_confirms_short = i_mtf_on ? mtf_bear_cnt >= i_mtf_min : true

f_arrow(int dir) => dir > 0 ? "▲" : dir < 0 ? "▼" : "–"
string mtf_txt = ""
if i_mtf_5m
    mtf_txt := "5" + f_arrow(mtf_5m_dir) + " "
if i_mtf_15m
    mtf_txt := mtf_txt + "15" + f_arrow(mtf_15m_dir) + " "
if i_mtf_1h
    mtf_txt := mtf_txt + "1H" + f_arrow(mtf_1h_dir) + " "
if i_mtf_4h
    mtf_txt := mtf_txt + "4H" + f_arrow(mtf_4h_dir) + " "
if i_mtf_1d
    mtf_txt := mtf_txt + "D" + f_arrow(mtf_1d_dir)

// ═══════════════════════════════════════════════════════════════════════════
// │ 2C  VECTOR CANDLES (unchanged)                                           │
// ═══════════════════════════════════════════════════════════════════════════

spread_vc = high - low
body_vc = math.abs(close - open)
body_ratio_vc = spread_vc > 0 ? body_vc / spread_vc : 0
vector_force = volume * spread_vc
avg_force = ta.sma(vector_force, i_vc_lookback)
rel_force = avg_force > 0 ? vector_force / avg_force : 0
is_up_vc = close > open
has_body_vc = body_ratio_vc >= i_vc_minbody
is_vec = rel_force >= i_vc_thresh and has_body_vc
is_ext = rel_force >= i_vc_extreme and has_body_vc
is_vec_bull = is_vec and is_up_vc
is_vec_bear = is_vec and not is_up_vc
is_ext_bull = is_ext and is_up_vc
is_ext_bear = is_ext and not is_up_vc

color vc_color = na
if i_vc_on
    if is_ext_bull
        vc_color := c_vc_bull_x
    else if is_ext_bear
        vc_color := c_vc_bear_x
    else if is_vec_bull
        vc_color := c_vc_bull
    else if is_vec_bear
        vc_color := c_vc_bear
    else if is_up_vc
        vc_color := color.new(c_vc_neu_up, i_vc_dim)
    else
        vc_color := color.new(c_vc_neu_dn, i_vc_dim)
barcolor(vc_color)

plotshape(i_vc_on and i_vc_dots and is_vec_bull and not is_ext_bull, "VD▲", shape.circle, location.belowbar, c_vc_bull, size=size.tiny)
plotshape(i_vc_on and i_vc_dots and is_vec_bear and not is_ext_bear, "VD▼", shape.circle, location.abovebar, c_vc_bear, size=size.tiny)
if i_vc_on and i_vc_labels and is_ext_bull
    label.new(bar_index, low - spread_vc * 0.3, "V", xloc.bar_index, yloc.price, color.new(c_vc_bull_x, 10), label.style_label_up, color.white, size.tiny, text.align_center, tooltip="EXT BULL " + str.tostring(rel_force, "#.0") + "×")
if i_vc_on and i_vc_labels and is_ext_bear
    label.new(bar_index, high + spread_vc * 0.3, "V", xloc.bar_index, yloc.price, color.new(c_vc_bear_x, 10), label.style_label_down, color.white, size.tiny, text.align_center, tooltip="EXT BEAR " + str.tostring(rel_force, "#.0") + "×")

// ═══════════════════════════════════════════════════════════════════════════
// │ 2D  VWAP (unchanged)                                                    │
// ═══════════════════════════════════════════════════════════════════════════

hlc3_v = hlc3, vol_v = math.max(volume, 1)
var float vd_pv = 0.0, var float vd_vol = 0.0
if ta.change(time("D")) != 0
    vd_pv := hlc3_v * vol_v, vd_vol := vol_v
else
    vd_pv += hlc3_v * vol_v, vd_vol += vol_v
float vwap_d = vd_vol > 0 ? vd_pv / vd_vol : hlc3_v

var float vw_pv = 0.0, var float vw_vol = 0.0
if ta.change(time("W")) != 0
    vw_pv := hlc3_v * vol_v, vw_vol := vol_v
else
    vw_pv += hlc3_v * vol_v, vw_vol += vol_v
float vwap_w = vw_vol > 0 ? vw_pv / vw_vol : hlc3_v

var float vm_pv = 0.0, var float vm_vol = 0.0
if ta.change(time("M")) != 0
    vm_pv := hlc3_v * vol_v, vm_vol := vol_v
else
    vm_pv += hlc3_v * vol_v, vm_vol += vol_v
float vwap_m = vm_vol > 0 ? vm_pv / vm_vol : hlc3_v

var float vh_pv = 0.0, var float vh_vol = 0.0
if ta.change(time("240")) != 0
    vh_pv := hlc3_v * vol_v, vh_vol := vol_v
else
    vh_pv += hlc3_v * vol_v, vh_vol += vol_v
float vwap_h = vh_vol > 0 ? vh_pv / vh_vol : hlc3_v

near_vwap_d = math.abs(close - vwap_d) < sa * 0.5

plot(i_vwap_d ? vwap_d : na, "VWAP-D", c_vwap_d, i_vwap_wpx)
plot(i_vwap_w ? vwap_w : na, "VWAP-W", c_vwap_w, i_vwap_wpx)
plot(i_vwap_m ? vwap_m : na, "VWAP-M", c_vwap_m, i_vwap_wpx)
plot(i_vwap_h ? vwap_h : na, "VWAP-H", c_vwap_h, i_vwap_wpx)

var label lbl_vd = na, var label lbl_vw = na, var label lbl_vm = na, var label lbl_vh = na
if barstate.islast and i_vwap_lbl
    if not na(lbl_vd)
        label.delete(lbl_vd)
    if not na(lbl_vw)
        label.delete(lbl_vw)
    if not na(lbl_vm)
        label.delete(lbl_vm)
    if not na(lbl_vh)
        label.delete(lbl_vh)
    if i_vwap_d
        lbl_vd := label.new(bar_index + 15, vwap_d, "VWAP-D", xloc.bar_index, yloc.price, color.new(c_vwap_d, 60), label.style_label_left, c_vwap_d, size.tiny, text.align_center, tooltip="D: " + str.tostring(vwap_d, format.mintick))
    if i_vwap_w
        lbl_vw := label.new(bar_index + 15, vwap_w, "VWAP-W", xloc.bar_index, yloc.price, color.new(c_vwap_w, 60), label.style_label_left, c_vwap_w, size.tiny, text.align_center, tooltip="W: " + str.tostring(vwap_w, format.mintick))
    if i_vwap_m
        lbl_vm := label.new(bar_index + 15, vwap_m, "VWAP-M", xloc.bar_index, yloc.price, color.new(c_vwap_m, 60), label.style_label_left, c_vwap_m, size.tiny, text.align_center, tooltip="M: " + str.tostring(vwap_m, format.mintick))
    if i_vwap_h
        lbl_vh := label.new(bar_index + 15, vwap_h, "VWAP-H", xloc.bar_index, yloc.price, color.new(c_vwap_h, 60), label.style_label_left, c_vwap_h, size.tiny, text.align_center, tooltip="4H: " + str.tostring(vwap_h, format.mintick))

// ═══════════════════════════════════════════════════════════════════════════
// │ 3  STRUCTURE (unchanged)                                                 │
// ═══════════════════════════════════════════════════════════════════════════

var float str_hi = na, var float str_lo = na, var int str_trend = 0
pvh = ta.pivothigh(high, i_pvt_len, 1)
pvl = ta.pivotlow(low, i_pvt_len, 1)
if not na(pvh)
    str_hi := pvh
if not na(pvl)
    str_lo := pvl
bos_bull = not na(str_hi) and close > str_hi and close[1] <= nz(str_hi)
bos_bear = not na(str_lo) and close < str_lo and close[1] >= nz(str_lo)
choch_bull = str_trend == -1 and bos_bull
choch_bear = str_trend == 1  and bos_bear
if bos_bull
    str_trend := 1, str_hi := na
if bos_bear
    str_trend := -1, str_lo := na

if i_show_struct and i_struct_on and choch_bull
    label.new(bar_index, low - sa * 0.4, "CHoCH", xloc.bar_index, yloc.price, color.new(c_choch_col, 20), label.style_label_up, color.white, size.tiny, text.align_center, tooltip="CHoCH Bull")
else if i_show_struct and i_struct_on and bos_bull
    label.new(bar_index, low - sa * 0.3, "BOS", xloc.bar_index, yloc.price, color.new(c_bos_col, 50), label.style_label_up, c_bos_col, size.tiny, text.align_center, tooltip="BOS Bull")
if i_show_struct and i_struct_on and choch_bear
    label.new(bar_index, high + sa * 0.4, "CHoCH", xloc.bar_index, yloc.price, color.new(c_choch_col, 20), label.style_label_down, color.white, size.tiny, text.align_center, tooltip="CHoCH Bear")
else if i_show_struct and i_struct_on and bos_bear
    label.new(bar_index, high + sa * 0.3, "BOS", xloc.bar_index, yloc.price, color.new(c_bos_col, 50), label.style_label_down, c_bos_col, size.tiny, text.align_center, tooltip="BOS Bear")

// ═══════════════════════════════════════════════════════════════════════════
// │ 4  CANDLE QUALITY (unchanged)                                            │
// ═══════════════════════════════════════════════════════════════════════════

body = math.abs(close - open)
full_range = high - low
body_ratio = full_range > 0 ? body / full_range : 0
is_bull_candle = close > open
is_bear_candle = close < open
upper_wick = is_bull_candle ? high - close : high - open
lower_wick = is_bull_candle ? open - low : close - low
is_hammer = lower_wick > body * 2 and upper_wick < body * 0.5 and is_bull_candle
is_shooting_star = upper_wick > body * 2 and lower_wick < body * 0.5 and is_bear_candle
is_bull_engulf = is_bull_candle and is_bear_candle[1] and close > open[1] and open < close[1]
is_bear_engulf = is_bear_candle and is_bull_candle[1] and close < open[1] and open > close[1]

// ═══════════════════════════════════════════════════════════════════════════
// │ 5  SCORING (unchanged)                                                   │
// ═══════════════════════════════════════════════════════════════════════════

recent_swing_lo = ta.lowest(low, i_pvt_len * 2)
recent_swing_hi = ta.highest(high, i_pvt_len * 2)
swing_rng = recent_swing_hi - recent_swing_lo
near_support = swing_rng > 0 ? (close - recent_swing_lo) / swing_rng < 0.2 : false
near_resist  = swing_rng > 0 ? (close - recent_swing_lo) / swing_rng > 0.8 : false

f_score_long() =>
    int sc = 0
    if i_trend_on
        sc += ema_f > ema_m ? 7 : 0
        sc += close > ema_s ? 5 : 0
        sc += (i_slope_on and ema_f_slope > i_slope_min) ? 3 : 0
    else
        sc += 8
    sc += rsi_val < i_rsi_os ? 12 : rsi_val < 40 ? 5 : 0
    sc += stoch_k < 20 ? 8 : stoch_k < 35 ? 3 : 0
    sc += choch_bull ? 18 : bos_bull ? 10 : 0
    sc += is_bull_engulf ? 12 : is_hammer ? 10 : (body_ratio > 0.5 and is_bull_candle ? 5 : 0)
    if i_vol_on
        sc += vol_above ? 8 : 0
    else
        sc += 5
    sc += near_support ? 8 : 0
    sc += i_adx_on ? (adx_val > i_adx_min ? 5 : 0) : 3
    sc += near_vwap_d and close > vwap_d ? 5 : 0
    sc += is_vec_bull ? 4 : 0
    if i_mtf_on and i_mtf_score
        sc += mtf_bull_cnt * 2
    math.min(100, sc)

f_score_short() =>
    int sc = 0
    if i_trend_on
        sc += ema_f < ema_m ? 7 : 0
        sc += close < ema_s ? 5 : 0
        sc += (i_slope_on and ema_f_slope < -i_slope_min) ? 3 : 0
    else
        sc += 8
    sc += rsi_val > i_rsi_ob ? 12 : rsi_val > 60 ? 5 : 0
    sc += stoch_k > 80 ? 8 : stoch_k > 65 ? 3 : 0
    sc += choch_bear ? 18 : bos_bear ? 10 : 0
    sc += is_bear_engulf ? 12 : is_shooting_star ? 10 : (body_ratio > 0.5 and is_bear_candle ? 5 : 0)
    if i_vol_on
        sc += vol_above ? 8 : 0
    else
        sc += 5
    sc += near_resist ? 8 : 0
    sc += i_adx_on ? (adx_val > i_adx_min ? 5 : 0) : 3
    sc += near_vwap_d and close < vwap_d ? 5 : 0
    sc += is_vec_bear ? 4 : 0
    if i_mtf_on and i_mtf_score
        sc += mtf_bear_cnt * 2
    math.min(100, sc)

score_long  = f_score_long()
score_short = f_score_short()
auto_thresh = i_mode == "Aggressive" ? 25 : i_mode == "Standard" ? 38 : 55
thresh = i_score_min > 0 ? i_score_min : auto_thresh
sideways = i_adx_on and adx_val < i_adx_min

// ═══════════════════════════════════════════════════════════════════════════
// │ 6  MUTUAL EXCLUSION + PENDING                                           │
// │                                                                          │
// │  FIX: Pending bekommt EXAKT dieselben Gates wie Entry.                  │
// │  Vorher: Pending prüfte NUR score + cooldown + sideways                 │
// │  → Warning erschien, aber MTF/Slope/Gap blockierte den Entry            │
// │  → User sah "!" aber nie "L"/"S" = falsches Versprechen                │
// │                                                                          │
// │  Jetzt: Pending = Entry-Preview. Wenn "!" erscheint, fehlt             │
// │  NUR noch etwas Score. Alle anderen Gates sind bereits offen.           │
// │  → "!" bedeutet: "Noch 1-2 Faktoren, dann kommt der Entry"             │
// ═══════════════════════════════════════════════════════════════════════════

var int last_long_bar = -9999, var int last_short_bar = -9999
var int active_dir = 0, var int active_bar = 0
var float active_sl = 0.0, var float active_tp1 = 0.0

cd_long  = bar_index - last_long_bar > i_cooldown
cd_short = bar_index - last_short_bar > i_cooldown

// ─── Entry qualification (all gates) ────────────────────────────────────
qual_long  = score_long >= thresh and cd_long and not sideways and mtf_confirms_long and slope_bull and bar_ok
qual_short = score_short >= thresh and cd_short and not sideways and mtf_confirms_short and slope_bear and bar_ok

int score_gap = math.abs(score_long - score_short)
bool gap_ok = score_gap >= i_min_gap

dom_long  = qual_long  and (not qual_short or score_long > score_short) and gap_ok
dom_short = qual_short and (not qual_long  or score_short > score_long) and gap_ok
lock_no_long  = active_dir == -1 and (bar_index - active_bar) < i_lock_bars
lock_no_short = active_dir == 1  and (bar_index - active_bar) < i_lock_bars

if active_dir == 1 and (low <= active_sl or high >= active_tp1)
    active_dir := 0
if active_dir == -1 and (high >= active_sl or low <= active_tp1)
    active_dir := 0
if active_dir != 0 and (bar_index - active_bar) > 100
    active_dir := 0

sig_long  = dom_long  and not lock_no_long  and active_dir != 1
sig_short = dom_short and not lock_no_short and active_dir != -1
is_strong_long  = sig_long  and score_long >= 60
is_strong_short = sig_short and score_short >= 60

if sig_long
    last_long_bar := bar_index, active_dir := 1, active_bar := bar_index
    active_sl := close - sa * i_sl_atr, active_tp1 := close + sa * i_sl_atr * i_tp1_mult
if sig_short
    last_short_bar := bar_index, active_dir := -1, active_bar := bar_index
    active_sl := close + sa * i_sl_atr, active_tp1 := close - sa * i_sl_atr * i_tp1_mult

// ─── FIX: Pending = Entry mit niedrigerem Score-Threshold ───────────────
// Pending prüft DIESELBEN Gates: MTF, Slope, Gap, Cooldown, Sideways, Lock
// Einziger Unterschied: score_long >= pend_thresh statt >= thresh
// → Wenn "!" erscheint, ist GARANTIERT nur der Score zu niedrig

pend_thresh = math.round(float(thresh) * float(i_pend_pct) / 100.0)
var int last_pend_bar = -9999
bool pend_cd_ok = bar_index - last_pend_bar > i_pend_cd

// SAME gates as entry: mtf + slope + gap + bar_ok + cooldown + sideways + lock
pend_long  = i_pending and not sig_long and bar_ok and pend_cd_ok and cd_long and not sideways and not lock_no_long and active_dir != 1 and mtf_confirms_long and slope_bull and score_long >= pend_thresh and score_long < thresh and score_long > score_short and score_gap >= i_min_gap

pend_short = i_pending and not sig_short and bar_ok and pend_cd_ok and cd_short and not sideways and not lock_no_short and active_dir != -1 and mtf_confirms_short and slope_bear and score_short >= pend_thresh and score_short < thresh and score_short > score_long and score_gap >= i_min_gap

if pend_long or pend_short
    last_pend_bar := bar_index

// ═══════════════════════════════════════════════════════════════════════════
// │ 7  SMART TRAIL (unchanged)                                               │
// ═══════════════════════════════════════════════════════════════════════════

var float trail_val = na, var int trail_dir = 0
atr_trail = sa * i_atr_mult
if sig_long or (trail_dir == 1 and close > trail_val)
    float nt1 = close - atr_trail
    trail_val := trail_dir == 1 and not na(trail_val) ? math.max(nz(trail_val), nt1) : nt1
    trail_dir := 1
if sig_short or (trail_dir == -1 and close < trail_val)
    float nt2 = close + atr_trail
    trail_val := trail_dir == -1 and not na(trail_val) ? math.min(nz(trail_val), nt2) : nt2
    trail_dir := -1
if trail_dir == 1 and close < nz(trail_val, close)
    trail_val := close + atr_trail, trail_dir := -1
if trail_dir == -1 and close > nz(trail_val, close)
    trail_val := close - atr_trail, trail_dir := 1
plot(i_show_trail and not na(trail_val) ? trail_val : na, "Trail", trail_dir == 1 ? color.new(c_bull, 30) : color.new(c_bear, 30), 2, plot.style_steplinebr)

// ═══════════════════════════════════════════════════════════════════════════
// │ 8  LEVELS + STATS (unchanged)                                            │
// ═══════════════════════════════════════════════════════════════════════════

var array<float> s_en = array.new_float(0), var array<float> s_sl = array.new_float(0)
var array<float> s_t1 = array.new_float(0), var array<float> s_t2 = array.new_float(0)
var array<float> s_t3 = array.new_float(0), var array<bool> s_il = array.new_bool(0)
var array<int> s_ba = array.new_int(0)
var int st_tot = 0, var int st_w1 = 0, var int st_loss = 0, var float st_rr = 0.0

if array.size(s_en) > 0
    for i = array.size(s_en) - 1 to 0
        if i >= array.size(s_en)
            break
        float en = array.get(s_en, i), float sl = array.get(s_sl, i)
        float t1 = array.get(s_t1, i), bool il = array.get(s_il, i), int sb = array.get(s_ba, i)
        if bar_index - sb > 1
            bool slh = il ? low <= sl : high >= sl
            bool t1h = il ? high >= t1 : low <= t1
            if slh or t1h or bar_index - sb > 100
                st_tot += 1
                if t1h and not slh
                    st_w1 += 1
                    rk = math.abs(en - sl), rw = math.abs(t1 - en)
                    st_rr += rk > 0 ? rw / rk : 0
                else
                    st_loss += 1
                array.remove(s_en, i), array.remove(s_sl, i), array.remove(s_t1, i)
                array.remove(s_t2, i), array.remove(s_t3, i), array.remove(s_il, i), array.remove(s_ba, i)

// ═══════════════════════════════════════════════════════════════════════════
// │ 9  SIGNAL LABELS (unchanged)                                             │
// ═══════════════════════════════════════════════════════════════════════════

if sig_long
    float en = close, float rk = sa * i_sl_atr
    float sl = en - rk, float tp1 = en + rk * i_tp1_mult, float tp2 = en + rk * i_tp2_mult, float tp3 = en + rk * i_tp3_mult
    if i_show_levels
        while array.size(s_en) >= i_max_levels
            array.shift(s_en), array.shift(s_sl), array.shift(s_t1), array.shift(s_t2), array.shift(s_t3), array.shift(s_il), array.shift(s_ba)
        array.push(s_en, en), array.push(s_sl, sl), array.push(s_t1, tp1), array.push(s_t2, tp2), array.push(s_t3, tp3), array.push(s_il, true), array.push(s_ba, bar_index)
    string tt = "────────────────────\n   LONG · " + (is_strong_long ? "STRONG" : "Std") + "\n────────────────────\n   Score " + str.tostring(score_long) + " (≥" + str.tostring(thresh) + ")\n   Entry " + str.tostring(en, format.mintick) + "\n   SL " + str.tostring(sl, format.mintick) + "\n   TP1 " + str.tostring(tp1, format.mintick) + "\n   TP2 " + str.tostring(tp2, format.mintick) + "\n   TP3 " + str.tostring(tp3, format.mintick) + "\n   RR: 1:" + str.tostring(i_tp1_mult, "#.0") + "\n────────────────────\n   MTF " + str.tostring(mtf_bull_cnt) + "/" + str.tostring(mtf_active) + "▲\n   " + mtf_txt
    label.new(bar_index, low - sa * 0.5, "L", xloc.bar_index, yloc.price, is_strong_long ? color.new(c_bull, 0) : color.new(c_bull, 35), label.style_label_up, color.white, sig_sz, text.align_center, tt)

if sig_short
    float en = close, float rk = sa * i_sl_atr
    float sl = en + rk, float tp1 = en - rk * i_tp1_mult, float tp2 = en - rk * i_tp2_mult, float tp3 = en - rk * i_tp3_mult
    if i_show_levels
        while array.size(s_en) >= i_max_levels
            array.shift(s_en), array.shift(s_sl), array.shift(s_t1), array.shift(s_t2), array.shift(s_t3), array.shift(s_il), array.shift(s_ba)
        array.push(s_en, en), array.push(s_sl, sl), array.push(s_t1, tp1), array.push(s_t2, tp2), array.push(s_t3, tp3), array.push(s_il, false), array.push(s_ba, bar_index)
    string tt2 = "────────────────────\n   SHORT · " + (is_strong_short ? "STRONG" : "Std") + "\n────────────────────\n   Score " + str.tostring(score_short) + " (≥" + str.tostring(thresh) + ")\n   Entry " + str.tostring(en, format.mintick) + "\n   SL " + str.tostring(sl, format.mintick) + "\n   TP1 " + str.tostring(tp1, format.mintick) + "\n   TP2 " + str.tostring(tp2, format.mintick) + "\n   TP3 " + str.tostring(tp3, format.mintick) + "\n   RR: 1:" + str.tostring(i_tp1_mult, "#.0") + "\n────────────────────\n   MTF " + str.tostring(mtf_bear_cnt) + "/" + str.tostring(mtf_active) + "▼\n   " + mtf_txt
    label.new(bar_index, high + sa * 0.5, "S", xloc.bar_index, yloc.price, is_strong_short ? color.new(c_bear, 0) : color.new(c_bear, 35), label.style_label_down, color.white, sig_sz, text.align_center, tt2)

if pend_long
    label.new(bar_index, low - sa * 0.3, "!", xloc.bar_index, yloc.price, color.new(c_warn, 30), label.style_label_up, c_warn, size.tiny, text.align_center, tooltip="PEND L " + str.tostring(score_long) + "/" + str.tostring(thresh))
if pend_short
    label.new(bar_index, high + sa * 0.3, "!", xloc.bar_index, yloc.price, color.new(c_warn, 30), label.style_label_down, c_warn, size.tiny, text.align_center, tooltip="PEND S " + str.tostring(score_short) + "/" + str.tostring(thresh))

// ═══════════════════════════════════════════════════════════════════════════
// │ 10  LEVEL LINES (unchanged)                                              │
// ═══════════════════════════════════════════════════════════════════════════

var array<line> a_ln = array.new_line(0), var array<label> a_lb = array.new_label(0)
if barstate.islast
    if array.size(a_ln) > 0
        for i = 0 to array.size(a_ln) - 1
            line.delete(array.get(a_ln, i))
    array.clear(a_ln)
    if array.size(a_lb) > 0
        for i = 0 to array.size(a_lb) - 1
            label.delete(array.get(a_lb, i))
    array.clear(a_lb)
    if i_show_levels and array.size(s_en) > 0
        for i = 0 to array.size(s_en) - 1
            if i >= array.size(s_en)
                break
            float en = array.get(s_en, i), float sl = array.get(s_sl, i)
            float t1 = array.get(s_t1, i), float t2 = array.get(s_t2, i), float t3 = array.get(s_t3, i)
            bool il = array.get(s_il, i), int sb = array.get(s_ba, i)
            string dt = il ? "L" : "S"
            array.push(a_ln, line.new(sb, en, bar_index + 5, en, color=color.new(color.white, 30), width=1, style=line.style_dashed))
            array.push(a_lb, label.new(bar_index + 6, en, dt + " EN", xloc.bar_index, yloc.price, color.new(color.white, 70), label.style_label_left, color.white, size.tiny))
            array.push(a_ln, line.new(sb, sl, bar_index + 5, sl, color=color.new(c_bear, 20), width=1, style=lvl_ls))
            array.push(a_lb, label.new(bar_index + 6, sl, "SL", xloc.bar_index, yloc.price, color.new(c_bear, 60), label.style_label_left, c_bear, size.tiny))
            array.push(a_ln, line.new(sb, t1, bar_index + 5, t1, color=color.new(c_bull, 20), width=1, style=lvl_ls))
            array.push(a_lb, label.new(bar_index + 6, t1, "TP1", xloc.bar_index, yloc.price, color.new(c_bull, 60), label.style_label_left, c_bull, size.tiny))
            if i_tp_count >= 2
                array.push(a_ln, line.new(sb, t2, bar_index + 5, t2, color=color.new(c_bull, 40), width=1, style=lvl_ls))
                array.push(a_lb, label.new(bar_index + 6, t2, "TP2", xloc.bar_index, yloc.price, color.new(c_bull, 70), label.style_label_left, c_bull, size.tiny))
            if i_tp_count >= 3
                array.push(a_ln, line.new(sb, t3, bar_index + 5, t3, color=color.new(c_bull, 60), width=1, style=lvl_ls))
                array.push(a_lb, label.new(bar_index + 6, t3, "TP3", xloc.bar_index, yloc.price, color.new(c_bull, 80), label.style_label_left, c_bull, size.tiny))

// ═══════════════════════════════════════════════════════════════════════════
// │ 11  PIVOTS + EMAs (unchanged)                                            │
// ═══════════════════════════════════════════════════════════════════════════

plotshape(i_show_liq and not na(pvh), "LH", shape.xcross, location.abovebar, color.new(c_bear, 60), size=size.auto)
plotshape(i_show_liq and not na(pvl), "LL", shape.xcross, location.belowbar, color.new(c_bull, 60), size=size.auto)
plot(i_trend_on ? ema_f : na, "EF", color.new(c_bull, 70), 1)
plot(i_trend_on ? ema_m : na, "EM", color.new(c_warn, 70), 1)
plot(i_trend_on ? ema_s : na, "ES", color.new(c_neutral, 70), 1)

// ═══════════════════════════════════════════════════════════════════════════
// │ 12  STATS (unchanged)                                                    │
// ═══════════════════════════════════════════════════════════════════════════

var table stats = table.new(position.bottom_right, 2, 10, bgcolor=color.new(#0f1119, 10), border_color=color.new(#2a2d3a, 60), border_width=1)
if i_show_stats and barstate.islast
    wr = st_tot > 0 ? math.round(float(st_w1) / float(st_tot) * 100) : 0
    ar = st_w1 > 0 ? st_rr / float(st_w1) : 0
    table.cell(stats, 0, 0, "TL 4.1", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#1a1d28, 30))
    table.cell(stats, 1, 0, i_mode + " ≥" + str.tostring(thresh), text_color=c_warn, text_size=size.tiny, bgcolor=color.new(#1a1d28, 30))
    table.cell(stats, 0, 1, "W/L", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 1, str.tostring(st_w1) + "/" + str.tostring(st_loss), text_color=color.white, text_size=size.tiny)
    table.cell(stats, 0, 2, "Rate", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 2, str.tostring(wr) + "%", text_color=wr >= 55 ? c_bull : wr >= 40 ? c_warn : c_bear, text_size=size.tiny)
    table.cell(stats, 0, 3, "RR", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 3, str.tostring(ar, "#.0") + "R", text_color=ar >= 1.5 ? c_bull : c_warn, text_size=size.tiny)
    table.cell(stats, 0, 4, "Score", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 4, "L" + str.tostring(score_long) + " S" + str.tostring(score_short), text_color=score_long > score_short ? c_bull : c_bear, text_size=size.tiny)
    table.cell(stats, 0, 5, "Gap", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 5, str.tostring(score_gap) + (gap_ok ? " ✓" : " ✗"), text_color=gap_ok ? c_bull : c_warn, text_size=size.tiny)
    table.cell(stats, 0, 6, "Active", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 6, active_dir == 1 ? "LONG ●" : active_dir == -1 ? "SHORT ●" : "—", text_color=active_dir == 1 ? c_bull : active_dir == -1 ? c_bear : c_neutral, text_size=size.tiny)
    table.cell(stats, 0, 7, "Vec", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 7, is_ext ? str.tostring(rel_force, "#.0") + "×E" : is_vec ? str.tostring(rel_force, "#.0") + "×" : "—", text_color=is_ext ? c_vc_bear_x : is_vec ? c_vc_bull : c_neutral, text_size=size.tiny)
    color mtf_c = mtf_bull_cnt > mtf_bear_cnt ? c_bull : mtf_bear_cnt > mtf_bull_cnt ? c_bear : c_neutral
    table.cell(stats, 0, 8, "MTF", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 8, str.tostring(mtf_bull_cnt) + "▲" + str.tostring(mtf_bear_cnt) + "▼", text_color=mtf_c, text_size=size.tiny)
    table.cell(stats, 0, 9, "TFs", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 9, mtf_txt, text_color=mtf_c, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// │ 13  ALERTS (unchanged)                                                   │
// ═══════════════════════════════════════════════════════════════════════════

alertcondition(sig_long,        "Long",         "TraxisLab: Long")
alertcondition(sig_short,       "Short",        "TraxisLab: Short")
alertcondition(is_strong_long,  "Strong L",     "⭐ STRONG LONG")
alertcondition(is_strong_short, "Strong S",     "⭐ STRONG SHORT")
alertcondition(pend_long,       "Pend L",       "⚠ Long building")
alertcondition(pend_short,      "Pend S",       "⚠ Short building")
alertcondition(is_ext_bull,     "ExtV▲",        "⚡ Ext Bull Vec")
alertcondition(is_ext_bear,     "ExtV▼",        "⚡ Ext Bear Vec")
alertcondition(choch_bull,      "CH▲",          "CHoCH Bull")
alertcondition(choch_bear,      "CH▼",          "CHoCH Bear")
alertcondition(mtf_bull_cnt >= 4, "M4▲",        "4+ TFs Long")
alertcondition(mtf_bear_cnt >= 4, "M4▼",        "4+ TFs Short")
````
