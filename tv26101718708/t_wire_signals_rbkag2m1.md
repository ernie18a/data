# T Wire Signals

- url: https://www.tradingview.com/script/RBkag2m1-T-Wire-Signals/
- type: indicator
- pine_id: PUB;7f3b9190d197492da75f2b67ffaae652
- version: 1.0

## Description

35x buy and sell indicator to be used on multiple time frames

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════
// T WIRE SIGNALS  —  Pine Script v5
// ───────────────────────────────────────────────────────────────────────────────
// Three-layer engine:
//   LAYER 1 → Range Filter   (trend direction)
//   LAYER 2 → QQE Momentum   (RSI momentum state)
//   LAYER 3 → EMA Crossover  (entry trigger)
//
// Trade management baked into every signal:
//   • Entry  — 10% of portfolio margin at configured leverage
//   • TP1    — close 80% at 30% margin gain  (default 35x = 0.857% price move)
//   • Stop   — hard exit at 31% margin loss  (default 35x = 0.886% price move)
//   • Runner — 20% stays open, stop moves to +5% margin once TP1 hits
// ═══════════════════════════════════════════════════════════════════════════════

//@version=5
indicator("T Wire Signals", shorttitle="TWire", overlay=true, max_labels_count=500)


// ───────────────────────────────────────────────────────────────────────────────
// SETTINGS
// ───────────────────────────────────────────────────────────────────────────────

grp_eng = "Engine Settings"
rf_per        = input.int   (100,   "RF Sampling Period",   minval=1,         group=grp_eng)
rf_mult       = input.float (3.0,   "RF Range Multiplier",  minval=0.1, step=0.1, group=grp_eng)
qqe_rsi_len   = input.int   (14,    "QQE RSI Length",       minval=1,         group=grp_eng)
qqe_smooth    = input.int   (5,     "QQE RSI Smoothing",    minval=1,         group=grp_eng)
qqe_factor    = input.float (4.238, "QQE Factor",           minval=0.1, step=0.001, group=grp_eng)
qqe_thresh    = input.int   (0,     "QQE Neutral Zone (±)", minval=0,         group=grp_eng)
fast_len      = input.int   (8,     "Fast EMA",             minval=1,         group=grp_eng)
mid_len       = input.int   (21,    "Mid EMA",              minval=1,         group=grp_eng)
slow_len      = input.int   (50,    "Slow EMA",             minval=1,         group=grp_eng)

grp_risk = "Trade Management"
leverage      = input.int   (35,    "Leverage",                     minval=1, step=1,   group=grp_risk)
hard_stop_pct = input.float (31.0,  "Hard Stop  (% of margin)",     minval=0.1, step=0.5, group=grp_risk)
tp1_pct       = input.float (30.0,  "TP1         (% of margin)",    minval=0.1, step=0.5, group=grp_risk)
runner_sl_pct = input.float (5.0,   "Runner Stop (% of margin)",    minval=0.1, step=0.5, group=grp_risk)
tp1_close_pct = input.float (80.0,  "Close at TP1 (%)",             minval=1,   step=5.0, group=grp_risk)

grp_vis = "Display"
show_bg       = input.bool  (true,  "Trend background",         group=grp_vis)
show_levels   = input.bool  (false, "Show TP / Stop lines",     group=grp_vis)
show_emas     = input.bool  (false, "Show EMA lines",           group=grp_vis)
show_rf       = input.bool  (false, "Show Range Filter line",   group=grp_vis)


// ───────────────────────────────────────────────────────────────────────────────
// LAYER 1: RANGE FILTER
// ───────────────────────────────────────────────────────────────────────────────

rf_range = ta.rma(math.abs(close - close[1]), rf_per) * rf_mult

var float rf_filt = close
var int   rf_dir  = 1

rf_filt := close - rf_range > nz(rf_filt[1], close) ? close - rf_range :
           close + rf_range < nz(rf_filt[1], close) ? close + rf_range :
           nz(rf_filt[1], close)

rf_dir  := close - rf_range > nz(rf_filt[1], close) ?  1 :
           close + rf_range < nz(rf_filt[1], close) ? -1 :
           nz(rf_dir[1], 1)

rf_bull = rf_dir ==  1
rf_bear = rf_dir == -1
rf_hi   = rf_filt + rf_range
rf_lo   = rf_filt - rf_range


// ───────────────────────────────────────────────────────────────────────────────
// LAYER 2: QQE MOMENTUM
// ───────────────────────────────────────────────────────────────────────────────

rsi_raw   = ta.rsi(close, qqe_rsi_len)
rsi_s     = ta.ema(rsi_raw, qqe_smooth)
atr_rsi   = math.abs(rsi_s - rsi_s[1])
wilders_p = qqe_rsi_len * 2 - 1
dar       = ta.rma(atr_rsi, wilders_p) * qqe_factor

var float long_band  = 0.0
var float short_band = 0.0

long_band  := rsi_s > nz(long_band[1])  ? math.max(nz(long_band[1]),  rsi_s - dar) : rsi_s - dar
short_band := rsi_s < nz(short_band[1]) ? math.min(nz(short_band[1]), rsi_s + dar) : rsi_s + dar

var int qqe_dir = 1
qqe_dir := rsi_s > short_band[1] and qqe_dir[1] == -1 ?  1 :
           rsi_s < long_band[1]  and qqe_dir[1] ==  1 ? -1 :
           nz(qqe_dir[1], 1)

qqe_bull = qqe_dir ==  1 and rsi_s > (50 + qqe_thresh)
qqe_bear = qqe_dir == -1 and rsi_s < (50 - qqe_thresh)


// ───────────────────────────────────────────────────────────────────────────────
// LAYER 3: EMA SIGNALS
// ───────────────────────────────────────────────────────────────────────────────

fast_ema = ta.ema(close, fast_len)
mid_ema  = ta.ema(close, mid_len)
slow_ema = ta.ema(close, slow_len)

bull_cross   = ta.crossover (fast_ema, slow_ema)
bear_cross   = ta.crossunder(fast_ema, slow_ema)
bull_break   = ta.crossover (close, mid_ema) and fast_ema > slow_ema
bear_break   = ta.crossunder(close, mid_ema) and fast_ema < slow_ema
bull_ema_sig = bull_cross or bull_break
bear_ema_sig = bear_cross or bear_break


// ───────────────────────────────────────────────────────────────────────────────
// FINAL SIGNAL
// ───────────────────────────────────────────────────────────────────────────────

long_sig  = bull_ema_sig and rf_bull and close > rf_filt and qqe_bull
short_sig = bear_ema_sig and rf_bear and close < rf_filt and qqe_bear


// ───────────────────────────────────────────────────────────────────────────────
// TRADE LEVELS  —  calculated from entry price at configured leverage
// ───────────────────────────────────────────────────────────────────────────────
//   price_move = margin_% / leverage / 100
//   e.g. 31% stop at 35x = 31/35/100 = 0.00886 = 0.886% price move from entry

price_stop   = hard_stop_pct / leverage / 100
price_tp1    = tp1_pct       / leverage / 100
price_runner = runner_sl_pct / leverage / 100

// LONG levels
l_stop   = close * (1 - price_stop)
l_tp1    = close * (1 + price_tp1)
l_runner = close * (1 + price_runner)

// SHORT levels
s_stop   = close * (1 + price_stop)
s_tp1    = close * (1 - price_tp1)
s_runner = close * (1 - price_runner)

// Helper: format price for label
f(x) => str.tostring(x, format.mintick)

// Helper: format as %
fp(x) => str.tostring(math.round(x * 100, 3), "#.###") + "%"


// ───────────────────────────────────────────────────────────────────────────────
// LEVEL LINES  —  drawn forward from each signal bar
// ───────────────────────────────────────────────────────────────────────────────

var line line_tp1    = na
var line line_stop   = na
var line line_runner = na
line_extend = 60   // bars to extend lines forward

if show_levels and long_sig
    line.delete(line_tp1)
    line.delete(line_stop)
    line.delete(line_runner)
    line_tp1    := line.new(bar_index, l_tp1,    bar_index + line_extend, l_tp1,    color=color.new(color.green,  20), style=line.style_dashed, width=1)
    line_stop   := line.new(bar_index, l_stop,   bar_index + line_extend, l_stop,   color=color.new(color.red,    20), style=line.style_dashed, width=1)
    line_runner := line.new(bar_index, l_runner, bar_index + line_extend, l_runner, color=color.new(color.yellow, 30), style=line.style_dotted, width=1)

if show_levels and short_sig
    line.delete(line_tp1)
    line.delete(line_stop)
    line.delete(line_runner)
    line_tp1    := line.new(bar_index, s_tp1,    bar_index + line_extend, s_tp1,    color=color.new(color.green,  20), style=line.style_dashed, width=1)
    line_stop   := line.new(bar_index, s_stop,   bar_index + line_extend, s_stop,   color=color.new(color.red,    20), style=line.style_dashed, width=1)
    line_runner := line.new(bar_index, s_runner, bar_index + line_extend, s_runner, color=color.new(color.yellow, 30), style=line.style_dotted, width=1)


// ───────────────────────────────────────────────────────────────────────────────
// VISUALS
// ───────────────────────────────────────────────────────────────────────────────

bgcolor(show_bg and rf_bull ? color.new(color.teal, 93) : show_bg and rf_bear ? color.new(color.red, 93) : na, title="Trend Background")

plot(show_rf    ? rf_filt  : na, "Range Filter", color=rf_bull ? color.new(color.teal, 20) : color.new(color.red, 20), linewidth=2)
plot(show_emas  ? fast_ema : na, "Fast EMA",     color=color.new(color.lime, 40), linewidth=1)
plot(show_emas  ? mid_ema  : na, "Mid EMA",      color=color.new(color.teal, 30), linewidth=1)
plot(show_emas  ? slow_ema : na, "Slow EMA",     color=color.new(color.gray, 20), linewidth=2)

// ── BUY label ─────────────────────────────────────────────────────────────────
if long_sig
    label.new(bar_index, low,
     "▲ BUY\n" + f(close),
     yloc      = yloc.belowbar,
     style     = label.style_label_up,
     color     = color.new(color.teal, 0),
     textcolor = color.white,
     size      = size.normal)

// ── SELL label ────────────────────────────────────────────────────────────────
if short_sig
    label.new(bar_index, high,
     "▼ SELL\n" + f(close),
     yloc      = yloc.abovebar,
     style     = label.style_label_down,
     color     = color.new(color.red, 0),
     textcolor = color.white,
     size      = size.normal)


// ───────────────────────────────────────────────────────────────────────────────
// ALERTS
// ───────────────────────────────────────────────────────────────────────────────

alertcondition(long_sig,  "T Wire — BUY",  "BUY  | {{ticker}} {{interval}} | Entry: {{close}}")
alertcondition(short_sig, "T Wire — SELL", "SELL | {{ticker}} {{interval}} | Entry: {{close}}")
````
