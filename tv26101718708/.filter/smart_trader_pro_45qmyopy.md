# Smart Trader Pro

- url: https://www.tradingview.com/script/45qMYopY-Smart-Trader-Pro/
- type: indicator
- pine_id: PUB;713f469655f7471989a8ca6a5792e2ec
- version: 2.0

## Description

Fully combined script with engulfing candles added.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kirabrianne

//@version=6
indicator(
     title       = "Apex Trader Pro — Levels + Trade Box + Engulfing",
     shorttitle  = "ATP Pro",
     overlay     = true,
     max_boxes_count = 10,
     max_labels_count = 20)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp_levels  = "Key Levels"
grp_box     = "Trade Box"
grp_trend   = "Trend Strength"
grp_engulf  = "Engulfing Candles"
grp_display = "Display Options"

show_daily   = input.bool(true,  "Show Daily H/L",    group = grp_levels)
show_weekly  = input.bool(true,  "Show Weekly H/L",   group = grp_levels)
show_monthly = input.bool(true,  "Show Monthly H/L",  group = grp_levels)
show_yearly  = input.bool(true,  "Show Yearly H/L",   group = grp_levels)
show_vwap    = input.bool(true,  "Show VWAP",         group = grp_levels)

enable_box   = input.bool(false, "Enable Trade Box",  group = grp_box)
tp_ticks     = input.float(20.0, "Profit Target (pts)", minval = 0.25, step = 0.25, group = grp_box)
sl_ticks     = input.float(10.0, "Stop Loss (pts)",     minval = 0.25, step = 0.25, group = grp_box)
box_dir      = input.string("Long", "Trade Direction", options = ["Long", "Short"], group = grp_box)

ma_fast_len  = input.int(20, "Fast EMA Length", minval = 1, group = grp_trend)
ma_slow_len  = input.int(50, "Slow EMA Length", minval = 1, group = grp_trend)
rsi_len      = input.int(14, "RSI Length",      minval = 1, group = grp_trend)
adx_len      = input.int(14, "ADX Length",      minval = 1, group = grp_trend)
adx_thresh   = input.int(25, "ADX Strong Trend Threshold", minval = 1, group = grp_trend)

// Engulfing inputs
show_engulf     = input.bool(true,  "Show Engulfing Signals", group = grp_engulf)
engulf_filter   = input.bool(true,  "Require ADX > Threshold", group = grp_engulf)
engulf_rsi_filt = input.bool(true,  "Require RSI 30–70",       group = grp_engulf)
engulf_ema_filt = input.bool(true,  "Require EMA Trend Align", group = grp_engulf)

col_bull    = input.color(color.new(color.teal, 0),  "Bullish Color",   group = grp_display)
col_bear    = input.color(color.new(color.red,  0),  "Bearish Color",   group = grp_display)
col_neutral = input.color(color.new(color.gray, 0),  "Neutral Color",   group = grp_display)
col_tp      = input.color(color.new(color.lime, 70), "Target Box Fill", group = grp_display)
col_sl      = input.color(color.new(color.red,  70), "Stop Box Fill",   group = grp_display)

// ─────────────────────────────────────────────
// HIGHER TIMEFRAME LEVELS
// ─────────────────────────────────────────────
[d_high, d_low] = request.security(syminfo.tickerid, "D",
     [high[1], low[1]], lookahead = barmerge.lookahead_on)

[w_high, w_low] = request.security(syminfo.tickerid, "W",
     [high[1], low[1]], lookahead = barmerge.lookahead_on)

[m_high, m_low] = request.security(syminfo.tickerid, "M",
     [high[1], low[1]], lookahead = barmerge.lookahead_on)

[y_high, y_low] = request.security(syminfo.tickerid, "12M",
     [high[1], low[1]], lookahead = barmerge.lookahead_on)

// ─────────────────────────────────────────────
// INDICATORS
// ─────────────────────────────────────────────
vwap_val = ta.vwap(hlc3)
ema_fast = ta.ema(close, ma_fast_len)
ema_slow = ta.ema(close, ma_slow_len)
rsi_val  = ta.rsi(close, rsi_len)
[diplus, diminus, adx_val] = ta.dmi(adx_len, adx_len)

// ─────────────────────────────────────────────
// TREND STRENGTH LOGIC
// ─────────────────────────────────────────────
above_vwap  = close > vwap_val
ema_bull_x  = ema_fast > ema_slow
rsi_bull    = rsi_val > 50
adx_strong  = adx_val >= adx_thresh

bull_signals = (above_vwap ? 1 : 0) + (ema_bull_x ? 1 : 0) + (rsi_bull ? 1 : 0)
bear_signals = (not above_vwap ? 1 : 0) + (not ema_bull_x ? 1 : 0) + (not rsi_bull ? 1 : 0)

trend_dir   = bull_signals >= 2 ? "Bullish" : bear_signals >= 2 ? "Bearish" : "Neutral"
trend_color = trend_dir == "Bullish" ? col_bull : trend_dir == "Bearish" ? col_bear : col_neutral
adx_str     = adx_strong ? " STRONG" : " WEAK"

trend_txt = trend_dir + adx_str +
     "\nRSI: "  + str.tostring(math.round(rsi_val, 1)) +
     "  ADX: "  + str.tostring(math.round(adx_val, 1)) +
     "\nEMA"    + str.tostring(ma_fast_len) +
     (ema_bull_x ? " > " : " < ") +
     "EMA"      + str.tostring(ma_slow_len) +
     "\nVWAP: " + (above_vwap ? "Above" : "Below")

// ─────────────────────────────────────────────
// ENGULFING CANDLE LOGIC
// ─────────────────────────────────────────────
rsi_not_exhausted = rsi_val > 30 and rsi_val < 70

bullEngulf_raw = close > open and
     close[1] < open[1] and
     close > open[1] and
     open < close[1]

bearEngulf_raw = close < open and
     close[1] > open[1] and
     close < open[1] and
     open > close[1]

// Apply optional filters
bull_adx_ok  = engulf_filter   ? adx_strong          : true
bull_rsi_ok  = engulf_rsi_filt ? rsi_not_exhausted   : true
bull_ema_ok  = engulf_ema_filt ? ema_bull_x          : true

bear_adx_ok  = engulf_filter   ? adx_strong          : true
bear_rsi_ok  = engulf_rsi_filt ? rsi_not_exhausted   : true
bear_ema_ok  = engulf_ema_filt ? not ema_bull_x      : true

bullSignal = show_engulf and bullEngulf_raw and bull_adx_ok and bull_rsi_ok and bull_ema_ok
bearSignal = show_engulf and bearEngulf_raw and bear_adx_ok and bear_rsi_ok and bear_ema_ok

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
plot(show_daily   ? d_high : na, "Day High",   color=color.new(color.blue,   20), linewidth=1, style=plot.style_stepline)
plot(show_daily   ? d_low  : na, "Day Low",    color=color.new(color.blue,   20), linewidth=1, style=plot.style_stepline)
plot(show_weekly  ? w_high : na, "Week High",  color=color.new(color.purple, 20), linewidth=2, style=plot.style_stepline)
plot(show_weekly  ? w_low  : na, "Week Low",   color=color.new(color.purple, 20), linewidth=2, style=plot.style_stepline)
plot(show_monthly ? m_high : na, "Month High", color=color.new(color.orange, 20), linewidth=2, style=plot.style_stepline)
plot(show_monthly ? m_low  : na, "Month Low",  color=color.new(color.orange, 20), linewidth=2, style=plot.style_stepline)
plot(show_yearly  ? y_high : na, "Year High",  color=color.new(color.red,    10), linewidth=3, style=plot.style_stepline)
plot(show_yearly  ? y_low  : na, "Year Low",   color=color.new(color.red,    10), linewidth=3, style=plot.style_stepline)
plot(show_vwap    ? vwap_val : na, "VWAP",     color=color.new(color.yellow,  0), linewidth=2)
plot(ema_fast, "EMA Fast", color=color.new(col_bull, 30), linewidth=1)
plot(ema_slow, "EMA Slow", color=color.new(col_bear, 30), linewidth=1)

// Engulfing shapes
plotshape(bullSignal, "Bull Engulfing", shape.triangleup,
     location.belowbar, color.green, size=size.small)
plotshape(bearSignal, "Bear Engulfing", shape.triangledown,
     location.abovebar, color.red, size=size.small)

// ─────────────────────────────────────────────
// TRADE BOX
// ─────────────────────────────────────────────
var box   tp_box   = na
var box   sl_box   = na
var label tp_lbl   = na
var label sl_lbl   = na
var float entry_px = na

if enable_box and na(entry_px)
    entry_px := close

tp_price = box_dir == "Long" ? entry_px + tp_ticks : entry_px - tp_ticks
sl_price = box_dir == "Long" ? entry_px - sl_ticks : entry_px + sl_ticks

box_left  = bar_index - 3
box_right = bar_index + 30

if enable_box
    box.delete(tp_box)
    box.delete(sl_box)
    label.delete(tp_lbl)
    label.delete(sl_lbl)

    tp_top    = box_dir == "Long" ? tp_price : entry_px
    tp_bottom = box_dir == "Long" ? entry_px : tp_price
    tp_box   := box.new(box_left, tp_top, box_right, tp_bottom,
         bgcolor=col_tp, border_color=color.lime, border_width=1)

    sl_top    = box_dir == "Long" ? entry_px : sl_price
    sl_bottom = box_dir == "Long" ? sl_price : entry_px
    sl_box   := box.new(box_left, sl_top, box_right, sl_bottom,
         bgcolor=col_sl, border_color=color.red, border_width=1)

    rr = math.round(tp_ticks / sl_ticks, 2)

    tp_lbl := label.new(box_right, tp_price,
         text="TP " + str.tostring(tp_price) + "  (R:R " + str.tostring(rr) + ":1)",
         style=label.style_label_left, color=color.lime, textcolor=color.black, size=size.small)

    sl_lbl := label.new(box_right, sl_price,
         text="SL " + str.tostring(sl_price),
         style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small)

if not enable_box
    entry_px := na

// ─────────────────────────────────────────────
// TREND LABEL
// ─────────────────────────────────────────────
var label trend_lbl = na

if barstate.islast
    label.delete(trend_lbl)
    trend_lbl := label.new(bar_index + 2, high,
         text=trend_txt,
         style=label.style_label_left,
         color=color.new(trend_color, 20),
         textcolor=color.white,
         size=size.normal)

// ─────────────────────────────────────────────
// LEVEL LABELS
// ─────────────────────────────────────────────
var label lbl_dh = na, var label lbl_dl = na
var label lbl_wh = na, var label lbl_wl = na
var label lbl_mh = na, var label lbl_ml = na
var label lbl_yh = na, var label lbl_yl = na

if barstate.islast
    label.delete(lbl_dh), label.delete(lbl_dl)
    label.delete(lbl_wh), label.delete(lbl_wl)
    label.delete(lbl_mh), label.delete(lbl_ml)
    label.delete(lbl_yh), label.delete(lbl_yl)
    lx = bar_index + 1

    if show_daily
        lbl_dh := label.new(lx, d_high, "D High " + str.tostring(d_high), style=label.style_label_left, color=color.new(color.blue,60),   textcolor=color.white, size=size.tiny)
        lbl_dl := label.new(lx, d_low,  "D Low "  + str.tostring(d_low),  style=label.style_label_left, color=color.new(color.blue,60),   textcolor=color.white, size=size.tiny)
    if show_weekly
        lbl_wh := label.new(lx, w_high, "W High " + str.tostring(w_high), style=label.style_label_left, color=color.new(color.purple,60), textcolor=color.white, size=size.tiny)
        lbl_wl := label.new(lx, w_low,  "W Low "  + str.tostring(w_low),  style=label.style_label_left, color=color.new(color.purple,60), textcolor=color.white, size=size.tiny)
    if show_monthly
        lbl_mh := label.new(lx, m_high, "M High " + str.tostring(m_high), style=label.style_label_left, color=color.new(color.orange,60), textcolor=color.white, size=size.tiny)
        lbl_ml := label.new(lx, m_low,  "M Low "  + str.tostring(m_low),  style=label.style_label_left, color=color.new(color.orange,60), textcolor=color.white, size=size.tiny)
    if show_yearly
        lbl_yh := label.new(lx, y_high, "Y High " + str.tostring(y_high), style=label.style_label_left, color=color.new(color.red,50),    textcolor=color.white, size=size.tiny)
        lbl_yl := label.new(lx, y_low,  "Y Low "  + str.tostring(y_low),  style=label.style_label_left, color=color.new(color.red,50),    textcolor=color.white, size=size.tiny)

// ─────────────────────────────────────────────
// BACKGROUND
// ─────────────────────────────────────────────
bgcolor(trend_dir == "Bullish" ? color.new(col_bull, 95) :
        trend_dir == "Bearish" ? color.new(col_bear, 95) : na,
        title="Trend Zone")

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(ta.crossover(close,    vwap_val),  "VWAP Cross Up",   "Price crossed ABOVE VWAP")
alertcondition(ta.crossunder(close,   vwap_val),  "VWAP Cross Down", "Price crossed BELOW VWAP")
alertcondition(ta.crossover(ema_fast, ema_slow),  "EMA Bull Cross",  "Fast EMA crossed ABOVE Slow EMA")
alertcondition(ta.crossunder(ema_fast, ema_slow), "EMA Bear Cross",  "Fast EMA crossed BELOW Slow EMA")
alertcondition(adx_val >= adx_thresh and bull_signals >= 2, "Strong Bull Trend", "ADX strong + Bullish confluence")
alertcondition(adx_val >= adx_thresh and bear_signals >= 2, "Strong Bear Trend", "ADX strong + Bearish confluence")
alertcondition(bullSignal, "Bull Engulfing", "Bullish Engulfing: ADX + RSI + EMA confirmed")
alertcondition(bearSignal, "Bear Engulfing", "Bearish Engulfing: ADX + RSI + EMA confirmed")
// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
if (enable_box and na(entry_px)) or syminfo.tickerid != syminfo.tickerid[1]
    entry_px := close
````
