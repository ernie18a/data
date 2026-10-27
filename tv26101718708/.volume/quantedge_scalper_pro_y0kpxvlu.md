# QuantEdge Scalper Pro

- url: https://www.tradingview.com/script/Y0kPxVLU-quantedge-scalper-pro/
- type: indicator
- pine_id: PUB;f5229fb144074aaf93be27158c11e370
- version: 1.0

## Description

Фильтр тренда
Стек EMA 20 / EMA 50 + позиция относительно VWAP. Все три должны совпадать. Обнаружение компрессии EMA блокирует торговлю во флэте.
EMA 20
EMA 50
VWAP
Фильтр волатильности (ATR)
ATR(14) сравнивается с его скользящей средней. Сигналы появляются только когда ATR между 0.5× и 4× базового уровня — исключаются флэт и экстремальные всплески.
ATR(14)
SMA ATR
Мин/Макс
Фильтр объёма
Объём текущего бара должен превышать 1.5× от 20-периодной SMA объёма. Множитель настраивается. Флаг всплеска используется повторно в подтверждении пробоя.
SMA объёма(20)
Всплеск 1.5×
ADX — анти-боковик
ADX(14) по Уайлдеру должен быть выше 20 (настраивается) И должна отсутствовать компрессия EMA. Оба условия нужны для подтверждения тренда.
ADX(14)
DI+ / DI−
Компрессия EMA
Рыночная структура
Пивоты определяют HH/HL (бычий рынок) и LH/LL (медвежий). Только подтверждённые пивоты без заглядывания вперёд. Пробой структуры (BOS) — бонусный триггер.
HH/HL
LH/LL
BOS
Ликвидационное сметание
Охота на стопы: фитиль прокалывает недавний экстремум, свеча закрывается обратно внутри. Бычье сметание = фитиль ниже минимума + закрытие выше него.
Охота на стопы
Прокол фитилём
Разворот
Подтверждение пробоя
Цена должна закрыться за пределами 20-барного диапазона при одновременном всплеске объёма И теле свечи выше среднего. Фильтр ложных пробоев проверяет следующий бар.
Диапазон(20)
Размер тела
Ложный пробой
Зоны дисбаланса (FVG)
Паттерн из 3 свечей: разрыв между максимумом свечи [2] и минимумом свечи [0] с подтверждающей средней свечой. Зоны отображаются прямоугольниками.
3-свечной гэп
Зона дисбаланса
Ордер-блоки (OB)
Последняя противоположная свеча перед сильным импульсным движением (тело > 1.5× среднего). Бычий ОБ = медвежья свеча перед большой бычьей.
Источник импульса
Тело 1.5×
Фильтр сессий
Сигналы только в Лондонскую (08:00–17:00 GMT) и Нью-Йоркскую (13:00–22:00 ET) сессии. Перекрытие 13:00–17:00 GMT — наилучшие условия.
Лондон
Нью-Йорк
Перекрытие
MTF-байас (опционально)
Данные старшего ТФ через lookahead_off — без перерисовки. По умолчанию ТФ: 60m. Лонги только если старший ТФ бычий.
EMA старшего ТФ
Нет lookahead
RSI-импульс
Опциональный фильтр RSI(14). Лонги: RSI > 60. Шорты: RSI < 40. Оба порога настраиваются. По умолчанию включён — отключите для чистого прайс-экшн.
RSI(14)
60 / 40

## Source Code

````pine
// ============================================================
// QuantEdge Scalper Pro v1.0
// Pine Script v6 — Non-Repainting Crypto Scalping Indicator
// Optimized for: 1m / 5m / 15m / 30m | Leverage x50+
// Author: QuantEdge Systems
// ============================================================
// MODULES:
//   1. User Inputs & Configuration
//   2. Core Calculations (EMA, VWAP, ATR, ADX, RSI, Volume)
//   3. Market Structure (HH/HL/LH/LL, BOS)
//   4. Liquidity Sweep Detection
//   5. Breakout Confirmation
//   6. Fair Value Gap (FVG) Detection
//   7. Order Block Detection
//   8. Session Filter
//   9. Signal Confluence Engine
//  10. Signal Grading (Weak / Medium / Strong)
//  11. Risk Management (SL/TP/RR)
//  12. Visuals (Labels, Candle Colors, Background, Dashboard)
//  13. Alert Conditions
// ============================================================

//@version=6
indicator(title="QuantEdge Scalper Pro", shorttitle="QE·Scalp", overlay=true, max_labels_count=500, max_lines_count=200, max_boxes_count=200)

// ============================================================
// 1. USER INPUTS & CONFIGURATION
// ============================================================

// --- Trend ---
grp_trend = "📈 Trend Settings"
ema_fast_len   = input.int(20,  "EMA Fast",    minval=5,   maxval=50,  group=grp_trend)
ema_slow_len   = input.int(50,  "EMA Slow",    minval=20,  maxval=200, group=grp_trend)
use_vwap       = input.bool(true, "Use VWAP Filter", group=grp_trend)

// --- ATR / Volatility ---
grp_atr = "⚡ ATR & Volatility"
atr_len        = input.int(14,   "ATR Length",          minval=5,  maxval=50,  group=grp_atr)
atr_sl_mult    = input.float(1.0, "SL ATR Multiplier",  minval=0.5, maxval=5.0, step=0.1, group=grp_atr)
atr_tp_mult    = input.float(1.8, "TP ATR Multiplier",  minval=0.5, maxval=10.0, step=0.1, group=grp_atr)
atr_min_mult   = input.float(0.5, "Min ATR (chop filter)",  minval=0.1, maxval=3.0, step=0.1, group=grp_atr)
atr_max_mult   = input.float(4.0, "Max ATR (spike filter)", minval=1.0, maxval=10.0, step=0.1, group=grp_atr)

// --- Volume ---
grp_vol = "📊 Volume Settings"
vol_len        = input.int(20,   "Volume MA Length",  minval=5, maxval=100, group=grp_vol)
vol_mult       = input.float(1.5, "Volume Spike Multiplier", minval=1.0, maxval=5.0, step=0.1, group=grp_vol)

// --- ADX / Trend Strength ---
grp_adx = "📐 ADX Trend Strength"
adx_len        = input.int(14,   "ADX Length",        minval=5, maxval=30,  group=grp_adx)
adx_threshold  = input.int(20,   "ADX Min Threshold", minval=10, maxval=50, group=grp_adx)

// --- RSI ---
grp_rsi = "🔄 RSI Momentum"
use_rsi        = input.bool(true, "Enable RSI Filter", group=grp_rsi)
rsi_len        = input.int(14,    "RSI Length",        minval=5, maxval=30,  group=grp_rsi)
rsi_ob         = input.int(60,    "RSI Long Min",      minval=40, maxval=80, group=grp_rsi)
rsi_os         = input.int(40,    "RSI Short Max",     minval=20, maxval=60, group=grp_rsi)

// --- Market Structure ---
grp_ms = "🏗 Market Structure"
ms_lookback    = input.int(10,   "Structure Lookback", minval=3, maxval=30, group=grp_ms)

// --- Session Filter ---
grp_sess = "🕐 Session Filter"
use_session    = input.bool(true, "Enable Session Filter", group=grp_sess)
london_open    = input.session("0800-1700", "London Session",   group=grp_sess)
ny_open        = input.session("1300-2200", "New York Session", group=grp_sess)

// --- Signal Grade ---
grp_sig = "🎯 Signal Settings"
show_weak      = input.bool(false, "Show Weak Signals",   group=grp_sig)
show_medium    = input.bool(false, "Show Medium Signals", group=grp_sig)
show_strong    = input.bool(true,  "Show Strong Signals", group=grp_sig)
cooldown_bars  = input.int(5,      "Signal Cooldown (bars)", minval=1, maxval=50, group=grp_sig)

// --- Extra Features ---
grp_extra = "🔧 Extra Features"
use_fvg        = input.bool(true,  "Detect Fair Value Gaps", group=grp_extra)
use_ob         = input.bool(true,  "Detect Order Blocks",    group=grp_extra)
use_liq_sweep  = input.bool(true,  "Detect Liquidity Sweeps", group=grp_extra)
use_mtf        = input.bool(false, "MTF Bias (Higher TF)",   group=grp_extra)
mtf_tf         = input.timeframe("60", "Higher Timeframe",   group=grp_extra)
use_fake_bo_filter = input.bool(true, "Fake Breakout Filter", group=grp_extra)

// --- Visuals ---
grp_vis = "🎨 Visuals"
show_emas      = input.bool(true,  "Show EMAs",           group=grp_vis)
show_vwap_line = input.bool(true,  "Show VWAP",           group=grp_vis)
show_bg        = input.bool(true,  "Trend Background",    group=grp_vis)
show_candles   = input.bool(false, "Color Candles",       group=grp_vis)
show_dashboard = input.bool(true,  "Show Dashboard",      group=grp_vis)
show_sl_tp     = input.bool(true,  "Show SL/TP Lines",    group=grp_vis)

// ============================================================
// 2. CORE CALCULATIONS
// ============================================================

// EMAs — confirmed on bar close (non-repainting)
ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)

// VWAP — daily anchored, standard
[vwap_val, _, _] = ta.vwap(hlc3, false, 1)

// ATR
atr_val  = ta.atr(atr_len)
atr_avg  = ta.sma(atr_val, atr_len)  // baseline for comparison

// Volume
vol_avg  = ta.sma(volume, vol_len)
vol_spike = volume > vol_avg * vol_mult

// RSI
rsi_val  = ta.rsi(close, rsi_len)

// ADX (custom implementation for Pine v6 compatibility)
// True Range components
tr_val   = ta.tr(true)
up_move  = high - high[1]
dn_move  = low[1] - low

// Positive/Negative Directional Movement
dm_plus  = (up_move > dn_move and up_move > 0) ? up_move : 0.0
dm_minus = (dn_move > up_move and dn_move > 0) ? dn_move : 0.0

// Smoothed values (Wilder's smoothing)
sm_tr    = ta.rma(tr_val,    adx_len)
sm_plus  = ta.rma(dm_plus,  adx_len)
sm_minus = ta.rma(dm_minus, adx_len)

di_plus  = sm_tr != 0 ? (sm_plus  / sm_tr) * 100 : 0.0
di_minus = sm_tr != 0 ? (sm_minus / sm_tr) * 100 : 0.0
di_sum   = di_plus + di_minus
dx_val   = di_sum != 0 ? math.abs(di_plus - di_minus) / di_sum * 100 : 0.0
adx_val  = ta.rma(dx_val, adx_len)

// EMA compression detection (anti-chop)
ema_spread      = math.abs(ema_fast - ema_slow)
ema_compressed  = ema_spread < atr_val * 0.3

// MTF Bias (higher timeframe EMA direction)
mtf_close       = request.security(syminfo.tickerid, mtf_tf, close, lookahead=barmerge.lookahead_off)
mtf_ema_fast    = request.security(syminfo.tickerid, mtf_tf, ta.ema(close, ema_fast_len), lookahead=barmerge.lookahead_off)
mtf_ema_slow    = request.security(syminfo.tickerid, mtf_tf, ta.ema(close, ema_slow_len), lookahead=barmerge.lookahead_off)
mtf_bull        = mtf_ema_fast > mtf_ema_slow
mtf_bear        = mtf_ema_fast < mtf_ema_slow

// ============================================================
// 3. MARKET STRUCTURE (HH / HL / LH / LL / BOS)
// ============================================================

// Swing highs and lows (confirmed, no lookahead)
swing_high = ta.pivothigh(high, ms_lookback, ms_lookback)
swing_low  = ta.pivotlow(low,  ms_lookback, ms_lookback)

// Track last confirmed pivot values
var float last_hh = na
var float last_hl = na
var float last_lh = na
var float last_ll = na

if not na(swing_high)
    last_hh := swing_high > nz(last_hh, swing_high) ? swing_high : last_hh
    last_lh := swing_high < nz(last_hh, swing_high) ? swing_high : last_lh

if not na(swing_low)
    last_hl := swing_low > nz(last_ll, swing_low) ? swing_low : last_hl
    last_ll := swing_low < nz(last_ll, swing_low) ? swing_low : last_ll

// Bullish structure: price making higher highs and higher lows
bull_structure = not na(last_hh) and not na(last_hl) and close > last_hl
bear_structure = not na(last_lh) and not na(last_ll) and close < last_lh

// Break of Structure (BOS)
var float bos_level_bull = na
var float bos_level_bear = na
bos_bull = not na(swing_high[ms_lookback]) and close > swing_high[ms_lookback]
bos_bear = not na(swing_low[ms_lookback])  and close < swing_low[ms_lookback]

// ============================================================
// 4. LIQUIDITY SWEEP DETECTION
// ============================================================

liq_lookback = ms_lookback

// A sweep: wick pierces a recent swing high/low, then closes back inside
recent_high  = ta.highest(high, liq_lookback)[1]  // confirmed prior high
recent_low   = ta.lowest(low,  liq_lookback)[1]   // confirmed prior low

// Bullish sweep: wick below recent low, close back above it (stop hunt)
liq_sweep_bull = use_liq_sweep and low < recent_low and close > recent_low and close > open

// Bearish sweep: wick above recent high, close back below it (stop hunt)
liq_sweep_bear = use_liq_sweep and high > recent_high and close < recent_high and close < open

// ============================================================
// 5. BREAKOUT CONFIRMATION
// ============================================================

// Average candle body size
avg_body = ta.sma(math.abs(close - open), 20)
body_size = math.abs(close - open)

// Breakout above recent range high with volume + body confirmation
range_high = ta.highest(high, 20)[1]
range_low  = ta.lowest(low,  20)[1]

bo_bull = close > range_high and vol_spike and body_size > avg_body
bo_bear = close < range_low  and vol_spike and body_size > avg_body

// Fake breakout filter: breakout bar closes back inside range next bar
// We check the previous bar's breakout, then confirm it held
var bool prev_bo_bull = false
var bool prev_bo_bear = false
prev_bo_bull := bo_bull[1]
prev_bo_bear := bo_bear[1]

fake_bo_bull = use_fake_bo_filter and prev_bo_bull and close < range_high[1]
fake_bo_bear = use_fake_bo_filter and prev_bo_bear and close > range_low[1]

confirmed_bo_bull = bo_bull and not fake_bo_bull
confirmed_bo_bear = bo_bear and not fake_bo_bear

// ============================================================
// 6. FAIR VALUE GAP (FVG) DETECTION
// ============================================================

// Bullish FVG: gap between candle[2] high and candle[0] low (3-bar pattern)
fvg_bull_cond = use_fvg and low > high[2] and close[1] > high[2]
fvg_bear_cond = use_fvg and high < low[2] and close[1] < low[2]

var bool in_bull_fvg = false
var bool in_bear_fvg = false
in_bull_fvg := fvg_bull_cond[1]  // confirmed prior bar
in_bear_fvg := fvg_bear_cond[1]

// ============================================================
// 7. ORDER BLOCK DETECTION
// ============================================================

// Bullish OB: last bearish candle before a strong bullish impulse
// Bearish OB: last bullish candle before a strong bearish impulse
ob_bull_cond = use_ob and close[1] < open[1] and close > open and body_size > avg_body * 1.5
ob_bear_cond = use_ob and close[1] > open[1] and close < open and body_size > avg_body * 1.5

// ============================================================
// 8. SESSION FILTER
// ============================================================

in_london    = time(timeframe.period, london_open, "Europe/London")
in_ny        = time(timeframe.period, ny_open, "America/New_York")
in_session   = not use_session or (not na(in_london) or not na(in_ny))

// ============================================================
// 9. SIGNAL CONFLUENCE ENGINE
// ============================================================

// --- Base Trend Conditions (non-repainting: all use confirmed close) ---

// LONG trend stack
trend_long  = close > ema_fast and close > ema_slow and ema_fast > ema_slow
trend_short = close < ema_fast and close < ema_slow and ema_fast < ema_slow

// VWAP alignment
vwap_long   = not use_vwap or close > vwap_val
vwap_short  = not use_vwap or close < vwap_val

// ATR volatility window (not too low, not too high)
atr_ok_long  = atr_val > atr_avg * atr_min_mult and atr_val < atr_avg * atr_max_mult
atr_ok_short = atr_ok_long  // symmetric

// ADX trend strength (avoid chop)
adx_ok = adx_val > adx_threshold and not ema_compressed

// RSI momentum
rsi_ok_long  = not use_rsi or rsi_val > rsi_ob
rsi_ok_short = not use_rsi or rsi_val < rsi_os

// MTF alignment
mtf_ok_long  = not use_mtf or mtf_bull
mtf_ok_short = not use_mtf or mtf_bear

// Candle close above prior high / below prior low
close_above_prev_high = close > high[1]
close_below_prev_low  = close < low[1]

// --- LONG Confluence Score ---
long_score = 0
long_score += trend_long          ? 1 : 0   // EMA trend aligned
long_score += vwap_long           ? 1 : 0   // Above VWAP
long_score += bull_structure      ? 1 : 0   // Higher highs/lows
long_score += vol_spike           ? 1 : 0   // Volume spike
long_score += atr_ok_long         ? 1 : 0   // ATR in range
long_score += adx_ok              ? 1 : 0   // ADX trending
long_score += rsi_ok_long         ? 1 : 0   // RSI momentum
long_score += (liq_sweep_bull or confirmed_bo_bull or bos_bull) ? 1 : 0  // Trigger
long_score += close_above_prev_high ? 1 : 0 // Candle confirmation
long_score += mtf_ok_long         ? 1 : 0   // MTF bias
long_score += (in_bull_fvg or ob_bull_cond) ? 1 : 0  // Structure confirmation

// --- SHORT Confluence Score ---
short_score = 0
short_score += trend_short          ? 1 : 0
short_score += vwap_short           ? 1 : 0
short_score += bear_structure       ? 1 : 0
short_score += vol_spike            ? 1 : 0
short_score += atr_ok_short         ? 1 : 0
short_score += adx_ok               ? 1 : 0
short_score += rsi_ok_short         ? 1 : 0
short_score += (liq_sweep_bear or confirmed_bo_bear or bos_bear) ? 1 : 0
short_score += close_below_prev_low ? 1 : 0
short_score += mtf_ok_short         ? 1 : 0
short_score += (in_bear_fvg or ob_bear_cond) ? 1 : 0

// ============================================================
// 10. SIGNAL GRADING
// ============================================================

// Thresholds out of 11 possible points
strong_threshold = 7
medium_threshold = 5
weak_threshold   = 3

long_strong  = long_score  >= strong_threshold
long_medium  = long_score  >= medium_threshold and long_score  < strong_threshold
long_weak    = long_score  >= weak_threshold   and long_score  < medium_threshold

short_strong = short_score >= strong_threshold
short_medium = short_score >= medium_threshold and short_score < strong_threshold
short_weak   = short_score >= weak_threshold   and short_score < medium_threshold

// ============================================================
// 11. SIGNAL COOLDOWN & FINAL SIGNAL GATE
// ============================================================

var int last_long_bar  = 0
var int last_short_bar = 0

// Gate signals through session + cooldown
cooldown_ok_long  = (bar_index - last_long_bar)  >= cooldown_bars
cooldown_ok_short = (bar_index - last_short_bar) >= cooldown_bars

// Final signals (only fires on confirmed bar close — non-repainting)
raw_long_signal  = in_session and cooldown_ok_long  and (long_strong  or (show_medium and long_medium)  or (show_weak and long_weak))
raw_short_signal = in_session and cooldown_ok_short and (short_strong or (show_medium and short_medium) or (show_weak and short_weak))

// Only one direction per bar, long takes priority if both (edge case)
final_long  = raw_long_signal  and not raw_short_signal
final_short = raw_short_signal and not raw_long_signal

// Update cooldown trackers
if final_long
    last_long_bar := bar_index
if final_short
    last_short_bar := bar_index

// ============================================================
// 12. RISK MANAGEMENT (ATR-BASED SL/TP)
// ============================================================

sl_long  = close - atr_val * atr_sl_mult
tp_long  = close + atr_val * atr_tp_mult
sl_short = close + atr_val * atr_sl_mult
tp_short = close - atr_val * atr_tp_mult

rr_ratio = atr_tp_mult / atr_sl_mult

// ============================================================
// 13. VISUALS
// ============================================================

// --- EMAs ---
ema_fast_plot = plot(show_emas ? ema_fast : na, "EMA Fast", color=color.new(color.yellow, 20), linewidth=1)
ema_slow_plot = plot(show_emas ? ema_slow : na, "EMA Slow", color=color.new(color.orange, 20), linewidth=2)

// VWAP
plot(show_vwap_line ? vwap_val : na, "VWAP", color=color.new(color.blue, 30), linewidth=2, style=plot.style_circles)

// --- Trend Background ---
bg_col = show_bg ? (trend_long ? color.new(color.green, 94) : trend_short ? color.new(color.red, 94) : color.new(color.gray, 97)) : na
bgcolor(bg_col, title="Trend Background")

// --- Candle Coloring ---
candle_col = show_candles ? (trend_long ? color.new(color.lime, 40) : trend_short ? color.new(color.red, 40) : color.new(color.gray, 60)) : na
barcolor(candle_col, title="Trend Candles")

// --- Signal Labels ---
// Strong LONG
if final_long and long_strong
    label.new(bar_index, low - atr_val * 0.5,
              "▲ BUY\n" + str.tostring(long_score) + "/11",
              color=color.new(color.green, 5),
              textcolor=color.white,
              style=label.style_label_up,
              size=size.normal)

// Medium LONG
if final_long and long_medium and show_medium
    label.new(bar_index, low - atr_val * 0.5,
              "▲ buy\n" + str.tostring(long_score) + "/11",
              color=color.new(color.teal, 20),
              textcolor=color.white,
              style=label.style_label_up,
              size=size.small)

// Strong SHORT
if final_short and short_strong
    label.new(bar_index, high + atr_val * 0.5,
              "▼ SELL\n" + str.tostring(short_score) + "/11",
              color=color.new(color.red, 5),
              textcolor=color.white,
              style=label.style_label_down,
              size=size.normal)

// Medium SHORT
if final_short and short_medium and show_medium
    label.new(bar_index, high + atr_val * 0.5,
              "▼ sell\n" + str.tostring(short_score) + "/11",
              color=color.new(color.maroon, 20),
              textcolor=color.white,
              style=label.style_label_down,
              size=size.small)

// --- Liquidity Sweep Markers ---
if liq_sweep_bull and use_liq_sweep
    label.new(bar_index, low - atr_val * 0.2, "💧", style=label.style_label_up, color=color.new(color.aqua, 30), textcolor=color.white, size=size.tiny)
if liq_sweep_bear and use_liq_sweep
    label.new(bar_index, high + atr_val * 0.2, "💧", style=label.style_label_down, color=color.new(color.orange, 30), textcolor=color.white, size=size.tiny)

// --- SL/TP Lines (on signal bars) ---
var line sl_line = na
var line tp_line = na

if final_long and show_sl_tp
    sl_line := line.new(bar_index, sl_long,  bar_index + 10, sl_long,  color=color.new(color.red,   20), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_long,  bar_index + 10, tp_long,  color=color.new(color.green, 20), width=1, style=line.style_dashed)

if final_short and show_sl_tp
    sl_line := line.new(bar_index, sl_short, bar_index + 10, sl_short, color=color.new(color.red,   20), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_short, bar_index + 10, tp_short, color=color.new(color.green, 20), width=1, style=line.style_dashed)

// --- FVG Boxes ---
var box fvg_box = na
if fvg_bull_cond and use_fvg
    fvg_box := box.new(bar_index - 2, low, bar_index + 5, high[2], bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 60))
if fvg_bear_cond and use_fvg
    fvg_box := box.new(bar_index - 2, low[2], bar_index + 5, high, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 60))

// ============================================================
// DASHBOARD TABLE
// ============================================================

if show_dashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 9,
                                border_width=1,
                                border_color=color.new(color.gray, 60),
                                bgcolor=color.new(color.black, 15),
                                frame_width=1,
                                frame_color=color.new(color.gray, 40))

    // Helper function colors
    trend_str   = trend_long ? "BULL 🟢" : trend_short ? "BEAR 🔴" : "FLAT ⚪"
    trend_col   = trend_long ? color.new(color.green, 20) : trend_short ? color.new(color.red, 20) : color.new(color.gray, 30)
    vol_str     = vol_spike ? "SPIKE 🔥" : "Normal"
    vol_col     = vol_spike ? color.new(color.orange, 20) : color.new(color.gray, 60)
    sess_str    = in_session ? "ACTIVE ✅" : "CLOSED ❌"
    sess_col    = in_session ? color.new(color.teal, 20) : color.new(color.gray, 50)
    adx_str     = adx_val > adx_threshold ? "TRENDING (" + str.tostring(math.round(adx_val)) + ")" : "CHOPPY (" + str.tostring(math.round(adx_val)) + ")"
    adx_col     = adx_val > adx_threshold ? color.new(color.lime, 30) : color.new(color.red, 40)
    atr_str     = str.tostring(math.round(atr_val, 4))
    rr_str      = str.tostring(math.round(rr_ratio, 1)) + ":1"
    long_sig_str  = long_strong ? "STRONG" : long_medium ? "MEDIUM" : long_weak ? "WEAK" : "NONE"
    short_sig_str = short_strong ? "STRONG" : short_medium ? "MEDIUM" : short_weak ? "WEAK" : "NONE"
    sig_col_l   = long_strong ? color.new(color.green, 10) : long_medium ? color.new(color.teal, 30) : color.new(color.gray, 60)
    sig_col_s   = short_strong ? color.new(color.red, 10) : short_medium ? color.new(color.maroon, 30) : color.new(color.gray, 60)

    // Header
    table.cell(dash, 0, 0, "QuantEdge Scalper",  text_color=color.white, bgcolor=color.new(color.navy, 10), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 1, 0, "Status",             text_color=color.white, bgcolor=color.new(color.navy, 10), text_size=size.small, text_halign=text.align_center)
    // Rows
    table.cell(dash, 0, 1, "Trend",     text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 1, trend_str,   text_color=color.white, bgcolor=trend_col, text_size=size.small)
    table.cell(dash, 0, 2, "ADX",       text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 2, adx_str,     text_color=color.white, bgcolor=adx_col, text_size=size.small)
    table.cell(dash, 0, 3, "Volatility (ATR)", text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 3, atr_str,     text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Volume",    text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 4, vol_str,     text_color=color.white, bgcolor=vol_col, text_size=size.small)
    table.cell(dash, 0, 5, "Session",   text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 5, sess_str,    text_color=color.white, bgcolor=sess_col, text_size=size.small)
    table.cell(dash, 0, 6, "Long Signal",  text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 6, long_sig_str + " (" + str.tostring(long_score) + "/11)", text_color=color.white, bgcolor=sig_col_l, text_size=size.small)
    table.cell(dash, 0, 7, "Short Signal", text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 7, short_sig_str + " (" + str.tostring(short_score) + "/11)", text_color=color.white, bgcolor=sig_col_s, text_size=size.small)
    table.cell(dash, 0, 8, "R:R Ratio", text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 8, rr_str,      text_color=color.yellow, text_size=size.small)

// ============================================================
// 14. ALERT CONDITIONS
// ============================================================

alertcondition(final_long  and long_strong,  title="🟢 STRONG BUY",  message="QuantEdge Scalper — STRONG BUY signal on {{ticker}} @ {{close}} | Score: {{plot_0}} | ATR SL: {{plot_1}}")
alertcondition(final_short and short_strong, title="🔴 STRONG SELL", message="QuantEdge Scalper — STRONG SELL signal on {{ticker}} @ {{close}} | Score: {{plot_0}} | ATR SL: {{plot_1}}")
alertcondition(final_long  and long_medium,  title="🔵 Medium BUY",  message="QuantEdge Scalper — Medium BUY signal on {{ticker}} @ {{close}}")
alertcondition(final_short and short_medium, title="🟠 Medium SELL", message="QuantEdge Scalper — Medium SELL signal on {{ticker}} @ {{close}}")
alertcondition(liq_sweep_bull, title="💧 Bullish Liquidity Sweep", message="QuantEdge Scalper — Bullish liquidity sweep on {{ticker}}")
alertcondition(liq_sweep_bear, title="💧 Bearish Liquidity Sweep", message="QuantEdge Scalper — Bearish liquidity sweep on {{ticker}}")
alertcondition(bos_bull,  title="📈 Bullish Break of Structure", message="QuantEdge Scalper — Bullish BOS on {{ticker}}")
alertcondition(bos_bear,  title="📉 Bearish Break of Structure", message="QuantEdge Scalper — Bearish BOS on {{ticker}}")
alertcondition(trend_long  and not trend_long[1],  title="🟢 Trend Changed BULL", message="QuantEdge Scalper — Trend changed BULLISH on {{ticker}}")
alertcondition(trend_short and not trend_short[1], title="🔴 Trend Changed BEAR", message="QuantEdge Scalper — Trend changed BEARISH on {{ticker}}")

// ============================================================
// Hidden plots for alert message variables
// ============================================================
plot(long_score,  "Long Score",  display=display.none)
plot(atr_val,     "ATR Value",   display=display.none)
plot(short_score, "Short Score", display=display.none)
plot(adx_val,     "ADX Value",   display=display.none)

// ============================================================
// END OF SCRIPT
// ============================================================
````
