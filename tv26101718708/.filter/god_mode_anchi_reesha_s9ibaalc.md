# GOD MODE | Anchi Reesha

- url: https://www.tradingview.com/script/S9iBAAlc-GOD-MODE-Anchi-Reesha/
- type: indicator
- pine_id: PUB;1124d80c4295444d8319932e501143a0
- version: 1.0

## Description

all in one indicator, we can buy and sell based on indication

## Source Code

````pine
// ============================================================
//  ██████╗  ██████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗
// ██╔════╝ ██╔═══██╗██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
// ██║  ███╗██║   ██║██║  ██║    ██╔████╔██║██║   ██║██║  ██║█████╗
// ██║   ██║██║   ██║██║  ██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝
// ╚██████╔╝╚██████╔╝██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗
//  ╚═════╝  ╚═════╝ ╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
// ------------------------------------------------------------
//  by_kunal.exe  |  GOD MODE INDICATOR v1.0
//  Multi-Confluence Signal Engine
//  Trend + Momentum + Volume + Smart Money + Risk Management
// ============================================================

//@version=5
indicator(title="⚡ GOD MODE | by_kunal.exe", shorttitle="GOD MODE", overlay=true, max_labels_count=500, max_lines_count=500)

// ════════════════════════════════════════════════
// ░░░ SETTINGS ░░░
// ════════════════════════════════════════════════

grp1 = "── EMA TREND STACK ──"
ema_fast   = input.int(20,  "Fast EMA",   minval=1, group=grp1)
ema_mid    = input.int(50,  "Mid EMA",    minval=1, group=grp1)
ema_slow   = input.int(200, "Slow EMA",   minval=1, group=grp1)
show_emas  = input.bool(true, "Show EMAs", group=grp1)

grp2 = "── RSI SETTINGS ──"
rsi_len    = input.int(14, "RSI Length", minval=1, group=grp2)
rsi_ob     = input.int(70, "Overbought", group=grp2)
rsi_os     = input.int(30, "Oversold",   group=grp2)

grp3 = "── VWAP ──"
show_vwap  = input.bool(true, "Show VWAP", group=grp3)

grp4 = "── VOLUME ──"
vol_mult   = input.float(1.5, "Volume Spike Multiplier", minval=1.0, step=0.1, group=grp4)
vol_len    = input.int(20, "Volume MA Length", group=grp4)

grp5 = "── ATR RISK MANAGEMENT ──"
atr_len    = input.int(14, "ATR Length", group=grp5)
atr_sl_mult = input.float(1.5, "SL Multiplier (ATR × X)", step=0.1, group=grp5)
atr_tp_mult = input.float(3.0, "TP Multiplier (ATR × X)", step=0.1, group=grp5)
show_zones  = input.bool(true, "Show SL/TP on Signal", group=grp5)

grp6 = "── SIGNAL ENGINE ──"
min_score  = input.int(4, "Min Confluence Score to Signal (1–6)", minval=1, maxval=6, group=grp6)
show_hud   = input.bool(true, "Show Dashboard HUD", group=grp6)

// ════════════════════════════════════════════════
// ░░░ CORE CALCULATIONS ░░░
// ════════════════════════════════════════════════

// — EMA Stack —
e_fast = ta.ema(close, ema_fast)
e_mid  = ta.ema(close, ema_mid)
e_slow = ta.ema(close, ema_slow)

bull_trend = e_fast > e_mid and e_mid > e_slow
bear_trend = e_fast < e_mid and e_mid < e_slow

// — RSI —
rsi = ta.rsi(close, rsi_len)
rsi_bull = rsi > 50 and rsi < rsi_ob
rsi_bear = rsi < 50 and rsi > rsi_os

// — RSI Hidden Divergence (simplified momentum flip) —
// Bullish: price makes higher low, RSI makes lower low → hidden bull div (continuation)
price_hl = low > low[2]
rsi_ll   = rsi < rsi[2]
hidden_bull_div = price_hl and rsi_ll and rsi < 55

price_lh = high < high[2]
rsi_hh   = rsi > rsi[2]
hidden_bear_div = price_lh and rsi_hh and rsi > 45

// — VWAP —
vwap_val = ta.vwap(hlc3)
above_vwap = close > vwap_val
below_vwap = close < vwap_val

// — Volume Spike —
vol_ma    = ta.sma(volume, vol_len)
vol_spike = volume > vol_ma * vol_mult

// — ATR —
atr_val = ta.atr(atr_len)

// — Candle Body Strength (no indecision candles) —
body      = math.abs(close - open)
candle_range = high - low
strong_candle = candle_range > 0 and (body / candle_range) > 0.5

// ════════════════════════════════════════════════
// ░░░ CONFLUENCE SCORING ░░░
// ════════════════════════════════════════════════

// LONG score (0–6)
long_score = 0
long_score := long_score + (bull_trend      ? 1 : 0)   // 1. EMA trend up
long_score := long_score + (rsi_bull        ? 1 : 0)   // 2. RSI momentum
long_score := long_score + (above_vwap      ? 1 : 0)   // 3. Above VWAP
long_score := long_score + (vol_spike       ? 1 : 0)   // 4. Volume confirms
long_score := long_score + (hidden_bull_div ? 1 : 0)   // 5. Hidden divergence
long_score := long_score + (strong_candle   ? 1 : 0)   // 6. Strong candle

// SHORT score (0–6)
short_score = 0
short_score := short_score + (bear_trend      ? 1 : 0)
short_score := short_score + (rsi_bear        ? 1 : 0)
short_score := short_score + (below_vwap      ? 1 : 0)
short_score := short_score + (vol_spike       ? 1 : 0)
short_score := short_score + (hidden_bear_div ? 1 : 0)
short_score := short_score + (strong_candle   ? 1 : 0)

// ════════════════════════════════════════════════
// ░░░ SIGNAL TRIGGER ░░░
// ════════════════════════════════════════════════

long_signal  = long_score  >= min_score and long_score  > long_score[1]
short_signal = short_score >= min_score and short_score > short_score[1]

// Avoid same signal back-to-back within 3 bars
var int last_long_bar  = -10
var int last_short_bar = -10

long_fire  = long_signal  and (bar_index - last_long_bar  > 3)
short_fire = short_signal and (bar_index - last_short_bar > 3)

if long_fire
    last_long_bar := bar_index
if short_fire
    last_short_bar := bar_index

// ════════════════════════════════════════════════
// ░░░ SL / TP CALCULATION ░░░
// ════════════════════════════════════════════════

long_sl = close - atr_val * atr_sl_mult
long_tp = close + atr_val * atr_tp_mult
short_sl = close + atr_val * atr_sl_mult
short_tp = close - atr_val * atr_tp_mult

// ════════════════════════════════════════════════
// ░░░ PLOTS ░░░
// ════════════════════════════════════════════════

// EMAs
plot(show_emas ? e_fast : na, "EMA 20",  color=color.new(color.aqua,   20), linewidth=1)
plot(show_emas ? e_mid  : na, "EMA 50",  color=color.new(color.yellow, 20), linewidth=1)
plot(show_emas ? e_slow : na, "EMA 200", color=color.new(color.orange, 20), linewidth=2)

// VWAP
plot(show_vwap ? vwap_val : na, "VWAP", color=color.new(color.purple, 10), linewidth=2, style=plot.style_circles)

// BUY signal
plotshape(long_fire,  title="BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(color.lime,    0), textcolor=color.black, text="BUY",  size=size.normal)
plotshape(short_fire, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.new(color.red,     0), textcolor=color.white, text="SELL", size=size.normal)

// SL/TP lines on signal
if long_fire and show_zones
    line.new(bar_index, long_sl, bar_index + 8, long_sl, color=color.new(color.red,   0), width=2, style=line.style_dashed)
    line.new(bar_index, long_tp, bar_index + 8, long_tp, color=color.new(color.green, 0), width=2, style=line.style_dashed)
    label.new(bar_index + 9, long_sl, "SL", color=color.new(color.red,   80), textcolor=color.red,   style=label.style_none, size=size.small)
    label.new(bar_index + 9, long_tp, "TP", color=color.new(color.green, 80), textcolor=color.green, style=label.style_none, size=size.small)

if short_fire and show_zones
    line.new(bar_index, short_sl, bar_index + 8, short_sl, color=color.new(color.red,   0), width=2, style=line.style_dashed)
    line.new(bar_index, short_tp, bar_index + 8, short_tp, color=color.new(color.green, 0), width=2, style=line.style_dashed)
    label.new(bar_index + 9, short_sl, "SL", color=color.new(color.red,   80), textcolor=color.red,   style=label.style_none, size=size.small)
    label.new(bar_index + 9, short_tp, "TP", color=color.new(color.green, 80), textcolor=color.green, style=label.style_none, size=size.small)

// Background color (trend zone)
bgcolor(bull_trend ? color.new(color.lime, 95) : bear_trend ? color.new(color.red, 95) : na, title="Trend BG")

// ════════════════════════════════════════════════
// ░░░ DASHBOARD HUD ░░░
// ════════════════════════════════════════════════

if show_hud and barstate.islast
    var table hud = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 10), border_color=color.new(color.gray, 50), border_width=1, frame_color=color.new(color.gray, 30), frame_width=1)

    // Header
    table.cell(hud, 0, 0, "⚡ GOD MODE HUD",  text_color=color.yellow, text_size=size.normal, bgcolor=color.new(color.black, 0), text_halign=text.align_center)
    table.cell(hud, 1, 0, "by_kunal.exe",       text_color=color.gray,   text_size=size.small,  bgcolor=color.new(color.black, 0), text_halign=text.align_center)

    // Labels col
    table.cell(hud, 0, 1, "EMA Trend",    text_color=color.white, text_size=size.small)
    table.cell(hud, 0, 2, "RSI",          text_color=color.white, text_size=size.small)
    table.cell(hud, 0, 3, "VWAP",         text_color=color.white, text_size=size.small)
    table.cell(hud, 0, 4, "Volume",       text_color=color.white, text_size=size.small)
    table.cell(hud, 0, 5, "Hidden Div",   text_color=color.white, text_size=size.small)
    table.cell(hud, 0, 6, "Candle Body",  text_color=color.white, text_size=size.small)
    table.cell(hud, 0, 7, "──────────",   text_color=color.gray,  text_size=size.small)
    table.cell(hud, 0, 8, "LONG Score",   text_color=color.lime,  text_size=size.small)
    table.cell(hud, 0, 9, "SHORT Score",  text_color=color.red,   text_size=size.small)

    // Values col
    table.cell(hud, 1, 1, bull_trend ? "🟢 BULL" : bear_trend ? "🔴 BEAR" : "⚪ RANGE", text_color=bull_trend ? color.lime : bear_trend ? color.red : color.gray, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(math.round(rsi, 1)) + (rsi > rsi_ob ? " OB" : rsi < rsi_os ? " OS" : ""), text_color=rsi > 50 ? color.lime : color.red, text_size=size.small)
    table.cell(hud, 1, 3, above_vwap ? "🟢 Above" : "🔴 Below", text_color=above_vwap ? color.lime : color.red, text_size=size.small)
    table.cell(hud, 1, 4, vol_spike  ? "🚀 SPIKE" : "Normal",   text_color=vol_spike  ? color.yellow : color.gray, text_size=size.small)
    table.cell(hud, 1, 5, hidden_bull_div ? "🟢 Bull" : hidden_bear_div ? "🔴 Bear" : "None", text_color=hidden_bull_div ? color.lime : hidden_bear_div ? color.red : color.gray, text_size=size.small)
    table.cell(hud, 1, 6, strong_candle ? "✅ Strong" : "⚠ Weak", text_color=strong_candle ? color.lime : color.orange, text_size=size.small)
    table.cell(hud, 1, 7, "──────────", text_color=color.gray,  text_size=size.small)
    table.cell(hud, 1, 8, str.tostring(long_score)  + " / 6", text_color=long_score  >= min_score ? color.lime   : color.gray, text_size=size.normal)
    table.cell(hud, 1, 9, str.tostring(short_score) + " / 6", text_color=short_score >= min_score ? color.red    : color.gray, text_size=size.normal)

// ════════════════════════════════════════════════
// ░░░ ALERTS ░░░
// ════════════════════════════════════════════════

alertcondition(long_fire,  title="⚡ GOD MODE — BUY Signal",  message="GOD MODE BUY | Score: {{long_score}} | {{ticker}} @ {{close}}")
alertcondition(short_fire, title="⚡ GOD MODE — SELL Signal", message="GOD MODE SELL | Score: {{short_score}} | {{ticker}} @ {{close}}")

// ============================================================
// END OF SCRIPT — by_kunal.exe
// ============================================================
````
