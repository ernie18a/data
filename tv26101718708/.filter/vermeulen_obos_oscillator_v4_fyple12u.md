# Vermeulen OB/OS Oscillator v4

- url: https://www.tradingview.com/script/FypLe12U-Vermeulen-OB-OS-Oscillator-v4/
- type: indicator
- pine_id: PUB;692089d89c8b44648d4692b890ed9a8e
- version: 1.0

## Description

The Vermeulen-Style Indicator v4 is a three-layer market analysis system built into two TradingView scripts: a price-chart overlay and a sub-pane oscillator. Together they answer three questions on every bar:

    What is the macro trend cycle? (Weinstein Stage Analysis — 150 SMA)

    What is the short-term regime? (5/20/50 EMA stack)

    Is sentiment at an extreme? (Panic/FOMO ratio + Momentum oscillator)

No single layer fires a trade signal in isolation. The system's edge comes from confluence — when all three layers agree, the probability of a sustained move is highest. When they disagree, the bias is to stand aside.

## Source Code

````pine
//@version=6
// ============================================================
// Vermeulen OB/OS Oscillator v4 — TheTechnicalTraders Approach
//
// What's in this pane:
//   · RSI (smoothed) — color-coded by ADX trend state
//   · Panic ratio area fill (red)  — Vermeulen >3 threshold
//   · FOMO ratio area fill (yellow) — Vermeulen >3 threshold
//   · Momentum reading line (data window) — 101/99 OB/OS
//   · ADX line (data window only)
//   · Panic→Bull triangle at pane bottom
//   · Stage macro background (teal Stage 2, red Stage 4)
//   · All signals on confirmed bars only — no repainting
// ============================================================
indicator("Vermeulen OB/OS Oscillator v4", overlay=false)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

rsi_len       = input.int(14,    "RSI Length",           minval=2)
adx_len       = input.int(14,    "ADX Length",           minval=2)
adx_threshold = input.int(25,    "ADX Threshold",        minval=1,
                tooltip="ADX above this colors RSI line purple = trending mode, mean-reversion less reliable")
ob_level      = input.int(70,    "RSI Overbought",       minval=51, maxval=99)
os_level      = input.int(30,    "RSI Oversold",         minval=1,  maxval=49)
mid_level     = input.int(50,    "RSI Midline")
vol_period    = input.int(20,    "Volume Lookback",      minval=5)
vol_mult      = input.float(1.5, "Volume Surge Mult",    minval=0.5, step=0.1)
panic_thresh  = input.float(3.0, "Panic/FOMO Threshold", minval=0.5, step=0.5,
                tooltip="Vermeulen: ratio >3 = extreme fear/FOMO. Red/yellow fills grow above this level.")
atr_len       = input.int(14,    "ATR Length",           minval=2)
macro_len     = input.int(150,   "Macro SMA",            minval=50,
                tooltip="150-day SMA for Stage 2/4 background coloring")
mom_ob        = input.int(101,   "Momentum OB",          tooltip="Vermeulen >101 = exhaustion")
mom_os        = input.int(99,    "Momentum OS",          tooltip="Vermeulen <99 = bounce candidate")
use_rth       = input.bool(false, "RTH Only (intraday)", tooltip="09:30–16:00 NY — enable on 5m/30m")

// ═══════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════

in_rth = use_rth ? not na(time(timeframe.period, "0930-1600", "America/New_York")) : true

rsi_raw   = ta.rsi(close, rsi_len)
rsi_s     = ta.ema(rsi_raw, 3)          // 3-bar smooth — cleaner visual without lag

[_dip, _dim, adx_val] = ta.dmi(adx_len, adx_len)
trend_active = adx_val > adx_threshold

macro_sma    = ta.sma(close, macro_len)
macro_slope_up   = macro_sma > macro_sma[5]
macro_slope_down = macro_sma < macro_sma[5]
stage2_bg    = macro_slope_up   and close > macro_sma
stage4_bg    = macro_slope_down and close < macro_sma

vol_available = not na(volume) and volume > 0
vol_avg       = ta.sma(volume, vol_period)
vol_ratio     = vol_available ? volume / vol_avg : 1.0

// Panic/FOMO continuous ratio
panic_ratio = vol_available ? math.max(0.0, 50.0 - rsi_s) / 10.0 * vol_ratio : 0.0
fomo_ratio  = vol_available ? math.max(0.0, rsi_s - 50.0) / 10.0 * vol_ratio : 0.0

// ATR extension: FOMO requires price >1 ATR from EMA fast (5 by default)
atr_val   = ta.atr(atr_len)
ema_fast  = ta.ema(close, 5)
price_ext = math.abs(close - ema_fast) > atr_val

// Momentum oscillator (same formula as overlay, data window only)
lo5         = ta.lowest(low,   5)
hi5         = ta.highest(high, 5)
range5      = hi5 - lo5
mom_reading = range5 > 0 ? 100.0 + ((close - lo5) / range5 - 0.5) * 4.0 : 100.0

// ═══════════════════════════════════════════════════════════════
// CONFIRMED SIGNALS (anti-repaint)
// ═══════════════════════════════════════════════════════════════

is_panic      = barstate.isconfirmed and in_rth and panic_ratio > panic_thresh and close < open
is_fomo       = barstate.isconfirmed and in_rth and fomo_ratio  > panic_thresh and close > open and price_ext
panic_to_bull = barstate.isconfirmed and ta.crossover(rsi_s, os_level) and not is_panic
mom_ob_cond   = barstate.isconfirmed and in_rth and mom_reading > mom_ob
mom_os_cond   = barstate.isconfirmed and in_rth and mom_reading < mom_os
rsi_os_recov  = barstate.isconfirmed and ta.crossover(rsi_s, os_level) and not is_panic
rsi_ob_rej    = barstate.isconfirmed and ta.crossunder(rsi_s, ob_level) and not is_fomo

// ═══════════════════════════════════════════════════════════════
// REFERENCE LINES
// ═══════════════════════════════════════════════════════════════

hline(ob_level,     "OB",            color=color.new(color.red,    55), linestyle=hline.style_dashed)
hline(os_level,     "OS",            color=color.new(color.teal,   55), linestyle=hline.style_dashed)
hline(mid_level,    "Mid",           color=color.new(color.gray,   70), linestyle=hline.style_dotted)
hline(panic_thresh, "Panic/FOMO ×3", color=color.new(color.orange, 50), linestyle=hline.style_dashed)

// ═══════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════

// RSI smooth — color-coded by trend state
osc_col = trend_active      ? color.new(color.purple, 0) :
          rsi_s > mid_level ? color.new(color.teal,   0) :
                              color.new(color.red,    0)

plot(rsi_s, "RSI Smooth", color=osc_col, linewidth=2)

// Panic/FOMO ratio fills — visible above threshold, fade below
panic_plot = plot(panic_ratio, "Panic Ratio",
     color=color.new(color.red,    40), linewidth=1, style=plot.style_area)
fomo_plot  = plot(fomo_ratio,  "FOMO Ratio",
     color=color.new(color.yellow, 40), linewidth=1, style=plot.style_area)

// Threshold reference line for ratio fills
thresh_plot = plot(panic_thresh, "Threshold",
     color=color.new(color.orange, 80), linewidth=1, style=plot.style_line)

// ADX and Momentum: data window only (avoids RSI scale confusion)
plot(adx_val,     "ADX",        color=color.new(color.silver, 60),
     linewidth=1, display=display.data_window)
plot(mom_reading, "Momentum",   color=color.new(color.blue,   60),
     linewidth=1, display=display.data_window)

// Panic→Bull entry marker at pane bottom
plotshape(panic_to_bull, "Panic→Bull", shape.triangleup,
          location.bottom, color=color.lime, size=size.small)

// Momentum OB/OS markers at top/bottom of RSI pane
plotshape(mom_ob_cond, "Mom OB", shape.triangledown,
          location.top, color=color.new(color.orange, 20), size=size.tiny)
plotshape(mom_os_cond, "Mom OS", shape.triangleup,
          location.bottom, color=color.new(color.aqua, 20), size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// BACKGROUND
// Priority: Panic/FOMO event > Stage macro
// ═══════════════════════════════════════════════════════════════

bgcolor(is_panic ? color.new(color.red,    80) :
        is_fomo  ? color.new(color.yellow, 80) :
        stage2_bg ? color.new(color.teal,  96) :
        stage4_bg ? color.new(color.red,   96) : na)

// ═══════════════════════════════════════════════════════════════
// ALERT CONDITIONS — all confirmed-bar gated
// ═══════════════════════════════════════════════════════════════

alertcondition(is_panic,
     "PANIC SELLING",
     "Panic ratio exceeded threshold — extreme fear, watch for reversal")
alertcondition(is_fomo,
     "FOMO BUY",
     "FOMO ratio exceeded threshold — price extended overbought, watch for exhaustion")
alertcondition(panic_to_bull,
     "Panic→Bull Entry",
     "RSI crossed back above OS — highest conviction long if EMA structure intact")
alertcondition(rsi_os_recov,
     "RSI Oversold Recovery",
     "RSI crossed back above OS level — potential recovery in progress")
alertcondition(rsi_ob_rej,
     "RSI Overbought Rejection",
     "RSI crossed back below OB level — potential pullback / reversal")
alertcondition(mom_ob_cond,
     "Momentum Overbought (>101)",
     "Short-term momentum above 101 — exhaustion / pause ahead")
alertcondition(mom_os_cond,
     "Momentum Oversold (<99)",
     "Short-term momentum below 99 — bounce candidate")
alertcondition(stage2_bg and not stage2_bg[1],
     "Stage 2 Bull Cycle",
     "150 SMA slope turned up, price above — Vermeulen bull cycle confirmed")
alertcondition(stage4_bg and not stage4_bg[1],
     "Stage 4 Bear Cycle",
     "150 SMA slope turned down, price below — Vermeulen bear cycle confirmed")
````
