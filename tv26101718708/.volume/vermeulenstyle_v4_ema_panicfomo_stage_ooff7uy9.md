# Vermeulen-Style v4: EMA + Panic/FOMO + Stage

- url: https://www.tradingview.com/script/OoFF7uy9-Vermeulen-Style-v4-EMA-Panic-FOMO-Stage/
- type: indicator
- pine_id: PUB;e4a5a65421754c13b633197e1a69506c
- version: 1.0

## Description

The Vermeulen-Style Indicator v4 is a **three-layer market analysis system** built into two TradingView scripts: a price-chart overlay and a sub-pane oscillator. Together they answer three questions on every bar:

1. **What is the macro trend cycle?** (Weinstein Stage Analysis — 150 SMA)
2. **What is the short-term regime?** (5/20/50 EMA stack)
3. **Is sentiment at an extreme?** (Panic/FOMO ratio + Momentum oscillator)

No single layer fires a trade signal in isolation. The system's edge comes from **confluence** — when all three layers agree, the probability of a sustained move is highest. When they disagree, the bias is to stand aside.

## Source Code

````pine
//@version=6
// ============================================================
// Vermeulen-Style Overlay v4 — TheTechnicalTraders Approach
// Three-layer system: EMA Regime · Panic/FOMO Sentiment · Stage
//
// Improvements over v1 spec:
//   [1] 5/20/50 EMA defaults (Vermeulen's published settings)
//   [2] 150 SMA macro gate — Weinstein Stage 1-4 analysis
//   [3] Panic/FOMO as continuous ratio (>3 threshold)
//   [4] Transitional "weak" regime — reduces background flicker
//   [5] Regime flip detection — confirmed bar, anti-repaint
//   [6] barstate.isconfirmed on all signals — no repainting
//   [7] Volume guard — na-safe for no-volume instruments
//   [8] vol_period as input (was hardcoded 20)
//   [9] ATR extension filter on FOMO (>1 ATR from EMA fast)
//  [10] Panic→Bull shape — spec's highest-conviction setup
//  [11] Momentum OB/OS bars (>101 / <99 — Vermeulen published)
//  [12] RTH session filter (optional — for 5m/30m intraday)
//  [13] Label queue — deletes oldest, never hits max_labels_count
//  [14] max_labels_count raised to 500
//  [15] ADX inputs in overlay (trend-gate context)
//  [16] Stage 2/4 alerts
// ============================================================
indicator("Vermeulen-Style v4: EMA + Panic/FOMO + Stage",
     overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

// EMA Settings — 5/20/50 matches Vermeulen's published 5-day / 20-day / 50-day system
ema_fast_len  = input.int(5,     "EMA Fast",             group="EMA Settings", minval=1)
ema_mid_len   = input.int(20,    "EMA Mid",              group="EMA Settings", minval=2)
ema_slow_len  = input.int(50,    "EMA Slow",             group="EMA Settings", minval=2)
macro_len     = input.int(150,   "Macro SMA",            group="EMA Settings", minval=50,
                tooltip="150-day SMA: Weinstein/Vermeulen macro cycle filter. Slope up + price above = Stage 2 bull.")

// Panic / FOMO Settings
rsi_len       = input.int(14,    "RSI Length",           group="Panic/FOMO", minval=2)
adx_len       = input.int(14,    "ADX Length",           group="Panic/FOMO", minval=2)
adx_threshold = input.int(25,    "ADX Threshold",        group="Panic/FOMO", minval=1,
                tooltip="ADX above this value = trending environment (RSI line turns purple in oscillator)")
vol_period    = input.int(20,    "Volume Lookback",      group="Panic/FOMO", minval=5,
                tooltip="Bars for average volume baseline. Use 10 on 5m, 20 on 30m/daily.")
vol_mult      = input.float(1.5, "Volume Multiplier",    group="Panic/FOMO", minval=0.5, step=0.1,
                tooltip="Volume must exceed avg × this multiplier. Use 2.0 on 5m to reduce noise.")
panic_thresh  = input.float(3.0, "Panic/FOMO Threshold", group="Panic/FOMO", minval=0.5, step=0.5,
                tooltip="Vermeulen: ratio > 3 = fear/FOMO taking over. Extreme readings: 10–31.")
rsi_ob        = input.int(70,    "RSI OB Level",         group="Panic/FOMO", minval=51, maxval=99)
rsi_os        = input.int(30,    "RSI OS Level",         group="Panic/FOMO", minval=1,  maxval=49)
atr_len       = input.int(14,    "ATR Length",           group="Panic/FOMO", minval=2,
                tooltip="FOMO only fires when price is >1 ATR extended beyond EMA fast")

// Momentum Oscillator
mom_ob        = input.int(101,   "Momentum OB",          group="Momentum",
                tooltip="Vermeulen: above 101 = short-term overbought / exhaustion")
mom_os        = input.int(99,    "Momentum OS",          group="Momentum",
                tooltip="Vermeulen: below 99 = short-term oversold / bounce candidate")

// Session & Display
use_rth       = input.bool(false, "RTH Only (intraday)",  group="Display",
                tooltip="Restricts Panic/FOMO signals to 09:30–16:00 NY. Enable on 5m/30m charts.")
show_labels   = input.bool(true,  "Show Panic/FOMO Labels", group="Display")
show_stage    = input.bool(true,  "Show Stage Background",  group="Display",
                tooltip="Stage 2=teal, Stage 4=red, Stage 1=blue, Stage 3=orange")
show_macro    = input.bool(true,  "Show 150 SMA",           group="Display")

// ═══════════════════════════════════════════════════════════════
// LAYER 1 — EMA REGIME
// ═══════════════════════════════════════════════════════════════

ema_fast  = ta.ema(close, ema_fast_len)
ema_mid   = ta.ema(close, ema_mid_len)
ema_slow  = ta.ema(close, ema_slow_len)
macro_sma = ta.sma(close, macro_len)

// Strict regime: all four conditions aligned
bull_regime = close > ema_fast and ema_fast > ema_mid and ema_mid > ema_slow
bear_regime = close < ema_fast and ema_fast < ema_mid and ema_mid < ema_slow

// Soft regime: EMA stack intact but price pulling back (reduces flicker)
weak_bull   = ema_mid > ema_slow and close > ema_slow and not bull_regime
weak_bear   = ema_mid < ema_slow and close < ema_slow and not bear_regime

// Regime flip — compare current bar EMA to prior confirmed bar EMA
ema_fast_p  = ta.ema(close[1], ema_fast_len)
ema_mid_p   = ta.ema(close[1], ema_mid_len)
ema_slow_p  = ta.ema(close[1], ema_slow_len)
bull_flip   = barstate.isconfirmed and
              ema_fast > ema_mid and ema_mid > ema_slow and
              not (ema_fast_p > ema_mid_p and ema_mid_p > ema_slow_p)
bear_flip   = barstate.isconfirmed and
              ema_fast < ema_mid and ema_mid < ema_slow and
              not (ema_fast_p < ema_mid_p and ema_mid_p < ema_slow_p)

// ═══════════════════════════════════════════════════════════════
// WEINSTEIN STAGE ANALYSIS (150 SMA macro)
// Stage 2 = accumulation → markup (bull cycle)
// Stage 4 = distribution → markdown (bear cycle)
// Stage 1 = base building     Stage 3 = topping / distribution
// ═══════════════════════════════════════════════════════════════

macro_slope_up   = macro_sma > macro_sma[5]
macro_slope_down = macro_sma < macro_sma[5]
stage2 = macro_slope_up   and close > macro_sma
stage4 = macro_slope_down and close < macro_sma
stage1 = not stage2 and not stage4 and close >= macro_sma
stage3 = not stage2 and not stage4 and close <  macro_sma

stage2_new = barstate.isconfirmed and stage2 and not stage2[1]
stage4_new = barstate.isconfirmed and stage4 and not stage4[1]

// ═══════════════════════════════════════════════════════════════
// LAYER 2 — PANIC / FOMO SENTIMENT
// ═══════════════════════════════════════════════════════════════

// Session filter
in_rth = use_rth ? not na(time(timeframe.period, "0930-1600", "America/New_York")) : true

rsi_val = ta.rsi(close, rsi_len)

[_dip, _dim, adx_val] = ta.dmi(adx_len, adx_len)
trend_active = adx_val > adx_threshold

// Volume guard: prevents na / zero-volume crash on indices/forex
vol_available = not na(volume) and volume > 0
vol_avg       = ta.sma(volume, vol_period)
vol_ratio     = vol_available ? volume / vol_avg : 1.0

// Panic/FOMO ratio — continuous reading; Vermeulen threshold = 3
// RSI distance from neutral (50) × volume ratio, normalised to 0–10+ scale
panic_ratio = vol_available ? math.max(0.0, 50.0 - rsi_val) / 10.0 * vol_ratio : 0.0
fomo_ratio  = vol_available ? math.max(0.0, rsi_val  - 50.0) / 10.0 * vol_ratio : 0.0

// ATR extension: FOMO requires price stretched >1 ATR above EMA fast
atr_val   = ta.atr(atr_len)
price_ext = math.abs(close - ema_fast) > atr_val

// All primary signals: confirmed bar only (anti-repaint)
is_panic      = barstate.isconfirmed and in_rth and panic_ratio > panic_thresh and close < open
is_fomo       = barstate.isconfirmed and in_rth and fomo_ratio  > panic_thresh and close > open and price_ext

// Panic→Bull: RSI crosses back above OS while EMA structure holds — spec's highest-conviction long
panic_to_bull = barstate.isconfirmed and ta.crossover(rsi_val, rsi_os) and ema_mid > ema_slow and not is_panic

// ═══════════════════════════════════════════════════════════════
// LAYER 3 — MOMENTUM BAR OSCILLATOR
// Vermeulen: >101 = short-term overbought, <99 = oversold
// ═══════════════════════════════════════════════════════════════

lo5         = ta.lowest(low,  5)
hi5         = ta.highest(high, 5)
range5      = hi5 - lo5
mom_reading = range5 > 0 ? 100.0 + ((close - lo5) / range5 - 0.5) * 4.0 : 100.0
mom_ob_cond = barstate.isconfirmed and in_rth and mom_reading > mom_ob
mom_os_cond = barstate.isconfirmed and in_rth and mom_reading < mom_os

// ═══════════════════════════════════════════════════════════════
// BAR COLOR
// Priority: Panic > FOMO > Mom OB > Mom OS > Bull > Weak Bull
//         > Bear > Weak Bear > Neutral
// ═══════════════════════════════════════════════════════════════

var color barCol = color.new(color.gray, 60)
if is_panic
    barCol := color.new(color.red,    0)
else if is_fomo
    barCol := color.new(color.yellow, 0)
else if mom_ob_cond
    barCol := color.new(color.orange, 20)
else if mom_os_cond
    barCol := color.new(color.aqua,   30)
else if bull_regime
    barCol := color.new(color.teal,   30)
else if weak_bull
    barCol := color.new(color.teal,   65)
else if bear_regime
    barCol := color.new(color.red,    55)
else if weak_bear
    barCol := color.new(color.red,    78)
else
    barCol := color.new(color.gray,   60)

barcolor(barCol)

// ═══════════════════════════════════════════════════════════════
// STAGE BACKGROUND + EMA PLOTS
// ═══════════════════════════════════════════════════════════════

bgcolor(show_stage and stage2 ? color.new(color.teal,   94) :
        show_stage and stage4 ? color.new(color.red,    94) :
        show_stage and stage1 ? color.new(color.blue,   97) :
        show_stage and stage3 ? color.new(color.orange, 96) : na)

plot(ema_fast,  "EMA Fast",  color=color.new(color.blue,   0), linewidth=1)
plot(ema_mid,   "EMA Mid",   color=color.new(color.orange, 0), linewidth=1)
plot(ema_slow,  "EMA Slow",  color=color.new(color.purple, 0), linewidth=2)
plot(show_macro ? macro_sma : na,
     "SMA Macro", color=color.new(color.gray, 30), linewidth=2)

// ═══════════════════════════════════════════════════════════════
// LABELS — managed queue, never exceeds max_labels_count
// ═══════════════════════════════════════════════════════════════

var label[] lQueue = array.new<label>()
MAX_LABELS = 200

f_pushLabel(lbl) =>
    array.push(lQueue, lbl)
    if array.size(lQueue) > MAX_LABELS
        label.delete(array.shift(lQueue))

if show_labels and is_panic
    f_pushLabel(label.new(bar_index, low * 0.999, "PANIC",
         style=label.style_label_up,   color=color.red,
         textcolor=color.white,        size=size.small))

if show_labels and is_fomo
    f_pushLabel(label.new(bar_index, high * 1.001, "FOMO",
         style=label.style_label_down, color=color.yellow,
         textcolor=color.black,        size=size.small))

// Panic→Bull triangle marker
plotshape(panic_to_bull, "Panic→Bull", shape.triangleup,
          location.belowbar, color=color.lime, size=size.normal)

// ═══════════════════════════════════════════════════════════════
// ALERT CONDITIONS
// ═══════════════════════════════════════════════════════════════

alertcondition(is_panic,
     "PANIC SELLING",
     "Panic ratio > threshold — fear taking over, watch for reversal")
alertcondition(is_fomo,
     "FOMO BUY",
     "FOMO ratio > threshold — price extended, overbought, watch for exhaustion")
alertcondition(panic_to_bull,
     "Panic→Bull Entry",
     "RSI crossed back above OS with EMA structure intact — highest conviction long")
alertcondition(bull_flip,
     "Bull Regime Flip",
     "EMA stack turned fully bullish — short-term trend change up")
alertcondition(bear_flip,
     "Bear Regime Flip",
     "EMA stack turned fully bearish — short-term trend change down")
alertcondition(stage2_new,
     "Stage 2 Bull Cycle Confirmed",
     "150 SMA slope turned up, price above — Weinstein/Vermeulen Stage 2 bull cycle")
alertcondition(stage4_new,
     "Stage 4 Bear Cycle Confirmed",
     "150 SMA slope turned down, price below — Weinstein/Vermeulen Stage 4 bear cycle")
alertcondition(mom_ob_cond,
     "Momentum Overbought (>101)",
     "Short-term momentum above 101 — exhaustion / pause likely")
alertcondition(mom_os_cond,
     "Momentum Oversold (<99)",
     "Short-term momentum below 99 — oversold bounce candidate")
````
