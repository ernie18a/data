# All in one - RK

- url: https://www.tradingview.com/script/NxkveoXC-All-in-one-RK/
- type: indicator
- pine_id: PUB;37bb3a2a25f443c1b2f9fd1feb972193
- version: 1.0

## Description

Merging more indicators into 1: 
"Long Entry Signal",      "🟢 LONG Entry - Check TP/SL levels"
"Short Entry Signal",     "🔴 SHORT Entry - Check TP/SL levels"
"Bullish BOS",            "Bullish Break of Structure"
"Bearish BOS",            "Bearish Break of Structure"
"Volume Surge",           "Volume Surge Detected"
"MACD Bull Cross",        "MACD Bullish Crossover"
"MACD Bear Cross",        "MACD Bearish Crossover"
"Bullish RSI Divergence", "Bullish RSI Divergence Detected"
"Bearish RSI Divergence", "Bearish RSI Divergence Detected"

## Source Code

````pine
// ============================================================
// ULTRA TRADING SYSTEM v2.0 — Pine Script v6
// Includes: Entry, TP1-4, Stop Loss, Demand/Supply Zones,
//           EMA Trend Cloud, RSI, MACD Signal, ATR Volatility,
//           Volume Surge, Fibonacci Levels, Market Structure,
//           Divergence Detection, Session Highlights
// ============================================================
//@version=6
indicator("Ultra Trading System v2.0", overlay = true, max_boxes_count = 200, max_lines_count = 500, max_labels_count = 200)

// ─────────────────────────────────────────
// GROUP 1: TREND SETTINGS
// ─────────────────────────────────────────
var string g1 = "📈 Trend & EMA Cloud"
ema_fast   = input.int(21,   "Fast EMA",      group = g1)
ema_mid    = input.int(50,   "Mid EMA",       group = g1)
ema_slow   = input.int(200,  "Slow EMA",      group = g1)
show_cloud = input.bool(true, "Show EMA Cloud", group = g1)

// ─────────────────────────────────────────
// GROUP 2: ENTRY / TP / SL
// ─────────────────────────────────────────
var string g2 = "🎯 Entry / TP / SL"
atr_length  = input.int(14,    "ATR Length",         group = g2)
sl_atr_mult = input.float(1.5, "SL ATR Multiplier",  group = g2, step = 0.1)
tp1_mult    = input.float(1.0, "TP1 Multiplier (R)", group = g2, step = 0.1)
tp2_mult    = input.float(2.0, "TP2 Multiplier (R)", group = g2, step = 0.1)
tp3_mult    = input.float(3.0, "TP3 Multiplier (R)", group = g2, step = 0.1)
tp4_mult    = input.float(4.0, "TP4 Multiplier (R)", group = g2, step = 0.1)
show_entry  = input.bool(true, "Show Entry/SL/TP Lines", group = g2)

// ─────────────────────────────────────────
// GROUP 3: SUPPLY & DEMAND ZONES
// ─────────────────────────────────────────
var string g3 = "🔴🟢 Supply & Demand Zones"
zone_pivot  = input.int(10,    "Pivot Lookback",   group = g3, minval = 3)
show_zones  = input.bool(true, "Show Zones",       group = g3)
zone_extend = input.int(40,    "Zone Extend Bars", group = g3)

// ─────────────────────────────────────────
// GROUP 4: FIBONACCI
// ─────────────────────────────────────────
var string g4 = "🌀 Fibonacci Levels"
show_fib     = input.bool(true, "Show Fibonacci",      group = g4)
fib_lookback = input.int(100,   "Fibonacci Lookback",  group = g4)

// ─────────────────────────────────────────
// GROUP 5: MARKET STRUCTURE
// ─────────────────────────────────────────
var string g5 = "🏗️ Market Structure"
show_struct = input.bool(true, "Show BOS / CHoCH",    group = g5)
struct_len  = input.int(10,    "Structure Lookback",  group = g5)

// ─────────────────────────────────────────
// GROUP 6: VOLUME SURGE
// ─────────────────────────────────────────
var string g6 = "📊 Volume Surge"
show_vol = input.bool(true,  "Show Volume Surge Labels", group = g6)
vol_mult = input.float(2.0,  "Volume Surge Multiplier",  group = g6, step = 0.1)
vol_len  = input.int(20,     "Volume MA Length",         group = g6)

// ─────────────────────────────────────────
// GROUP 7: SESSION HIGHLIGHTS
// ─────────────────────────────────────────
var string g7 = "🕐 Session Highlights"
show_session = input.bool(true,                            "Show Sessions", group = g7)
london_col   = input.color(color.new(color.blue,   90),   "London",        group = g7)
ny_col       = input.color(color.new(color.orange, 90),   "New York",      group = g7)
asia_col     = input.color(color.new(color.purple, 90),   "Asia",          group = g7)

// ─────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────

// EMAs
ema21  = ta.ema(close, ema_fast)
ema50  = ta.ema(close, ema_mid)
ema200 = ta.ema(close, ema_slow)

// ATR
atr = ta.atr(atr_length)

// Trend direction
bull_trend = ema21 > ema50 and ema50 > ema200
bear_trend = ema21 < ema50 and ema50 < ema200

// EMA Cloud plots
p21  = plot(ema21,  "EMA 21",  color = bull_trend ? color.new(color.lime,  0) : color.new(color.red,   0), linewidth = 1)
p50  = plot(ema50,  "EMA 50",  color = bull_trend ? color.new(color.teal,  0) : color.new(color.orange, 0), linewidth = 1)
p200 = plot(ema200, "EMA 200", color = color.new(color.white, 30), linewidth = 2)

// Cloud fill
fill(p21, p50,
     color = show_cloud ? (bull_trend ? color.new(color.lime, 88) : color.new(color.red, 88)) : na,
     title = "EMA Cloud")

// ─────────────────────────────────────────
// RSI
// ─────────────────────────────────────────
rsi = ta.rsi(close, 14)

// ─────────────────────────────────────────
// ENTRY SIGNALS
// ─────────────────────────────────────────
long_signal  = ta.crossover(ema21, ema50)  and close > ema200
short_signal = ta.crossunder(ema21, ema50) and close < ema200

long_entry  = long_signal  and rsi < 70
short_entry = short_signal and rsi > 30

// ─────────────────────────────────────────
// DYNAMIC SL / TP LEVELS
// ─────────────────────────────────────────
var float entry_price = na
var float sl_price    = na
var float tp1_val     = na
var float tp2_val     = na
var float tp3_val     = na
var float tp4_val     = na

if long_entry
    entry_price := close
    sl_price    := close - atr * sl_atr_mult
    tp1_val     := close + atr * sl_atr_mult * tp1_mult
    tp2_val     := close + atr * sl_atr_mult * tp2_mult
    tp3_val     := close + atr * sl_atr_mult * tp3_mult
    tp4_val     := close + atr * sl_atr_mult * tp4_mult

if short_entry
    entry_price := close
    sl_price    := close + atr * sl_atr_mult
    tp1_val     := close - atr * sl_atr_mult * tp1_mult
    tp2_val     := close - atr * sl_atr_mult * tp2_mult
    tp3_val     := close - atr * sl_atr_mult * tp3_mult
    tp4_val     := close - atr * sl_atr_mult * tp4_mult

// Plot lines
plot(show_entry ? entry_price : na, "Entry", color = color.white,               linewidth = 2, style = plot.style_linebr)
plot(show_entry ? sl_price    : na, "SL",    color = color.red,                 linewidth = 2, style = plot.style_linebr)
plot(show_entry ? tp1_val     : na, "TP1",   color = color.lime,                linewidth = 1, style = plot.style_linebr)
plot(show_entry ? tp2_val     : na, "TP2",   color = color.teal,                linewidth = 1, style = plot.style_linebr)
plot(show_entry ? tp3_val     : na, "TP3",   color = color.yellow,              linewidth = 1, style = plot.style_linebr)
plot(show_entry ? tp4_val     : na, "TP4",   color = color.orange,              linewidth = 2, style = plot.style_linebr)

// Entry labels
if long_entry and show_entry
    lbl_txt = "▲ LONG ENTRY\nSL:  " + str.tostring(math.round(sl_price, 2)) +
              "\nTP1: " + str.tostring(math.round(tp1_val, 2)) +
              "\nTP2: " + str.tostring(math.round(tp2_val, 2)) +
              "\nTP3: " + str.tostring(math.round(tp3_val, 2)) +
              "\nTP4: " + str.tostring(math.round(tp4_val, 2))
    label.new(bar_index, low - atr * 0.5, lbl_txt,
              color = color.lime, textcolor = color.black,
              style = label.style_label_up, size = size.small)

if short_entry and show_entry
    lbl_txt = "▼ SHORT ENTRY\nSL:  " + str.tostring(math.round(sl_price, 2)) +
              "\nTP1: " + str.tostring(math.round(tp1_val, 2)) +
              "\nTP2: " + str.tostring(math.round(tp2_val, 2)) +
              "\nTP3: " + str.tostring(math.round(tp3_val, 2)) +
              "\nTP4: " + str.tostring(math.round(tp4_val, 2))
    label.new(bar_index, high + atr * 0.5, lbl_txt,
              color = color.red, textcolor = color.white,
              style = label.style_label_down, size = size.small)

// ─────────────────────────────────────────
// SUPPLY & DEMAND ZONES
// ─────────────────────────────────────────
ph = ta.pivothigh(high, zone_pivot, zone_pivot)
pl = ta.pivotlow(low,   zone_pivot, zone_pivot)

if not na(ph) and show_zones
    box.new(bar_index - zone_pivot, ph, bar_index - zone_pivot + zone_extend, ph - atr * 0.5,
            border_color = color.new(color.red,   40),
            bgcolor      = color.new(color.red,   88),
            border_width = 1,
            extend       = extend.right)

if not na(pl) and show_zones
    box.new(bar_index - zone_pivot, pl + atr * 0.5, bar_index - zone_pivot + zone_extend, pl,
            border_color = color.new(color.lime,  40),
            bgcolor      = color.new(color.lime,  88),
            border_width = 1,
            extend       = extend.right)

// ─────────────────────────────────────────
// FIBONACCI RETRACEMENT
// ─────────────────────────────────────────
fib_high  = ta.highest(high, fib_lookback)
fib_low   = ta.lowest(low,   fib_lookback)
fib_range = fib_high - fib_low

fib_236 = fib_high - fib_range * 0.236
fib_382 = fib_high - fib_range * 0.382
fib_500 = fib_high - fib_range * 0.500
fib_618 = fib_high - fib_range * 0.618
fib_786 = fib_high - fib_range * 0.786

plot(show_fib ? fib_236 : na, "Fib 23.6%", color = color.new(color.purple, 40), linewidth = 1)
plot(show_fib ? fib_382 : na, "Fib 38.2%", color = color.new(color.purple, 30), linewidth = 1)
plot(show_fib ? fib_500 : na, "Fib 50.0%", color = color.new(color.fuchsia, 30), linewidth = 1)
plot(show_fib ? fib_618 : na, "Fib 61.8%", color = color.new(color.maroon, 20), linewidth = 1)
plot(show_fib ? fib_786 : na, "Fib 78.6%", color = color.new(color.orange, 40), linewidth = 1)

// ─────────────────────────────────────────
// MARKET STRUCTURE — BOS & CHoCH
// ─────────────────────────────────────────
ms_high = ta.pivothigh(high, struct_len, struct_len)
ms_low  = ta.pivotlow(low,   struct_len, struct_len)

var float last_hh = na
var float last_ll = na
var float prev_hh = na
var float prev_ll = na

if not na(ms_high)
    prev_hh := last_hh
    last_hh := ms_high

if not na(ms_low)
    prev_ll := last_ll
    last_ll := ms_low

bos_bull   = not na(last_hh) and not na(prev_hh) and close > last_hh and close[1] <= last_hh
bos_bear   = not na(last_ll) and not na(prev_ll) and close < last_ll and close[1] >= last_ll
choch_bull = bear_trend[1] and bull_trend
choch_bear = bull_trend[1] and bear_trend

if show_struct and bos_bull
    label.new(bar_index, high, "BOS ↑",
              color = color.new(color.lime, 20), textcolor = color.black,
              style = label.style_label_down, size = size.tiny)

if show_struct and bos_bear
    label.new(bar_index, low, "BOS ↓",
              color = color.new(color.red, 20), textcolor = color.white,
              style = label.style_label_up, size = size.tiny)

if show_struct and choch_bull
    label.new(bar_index, low - atr, "CHoCH ↑",
              color = color.new(color.teal, 20), textcolor = color.black,
              style = label.style_label_up, size = size.tiny)

if show_struct and choch_bear
    label.new(bar_index, high + atr, "CHoCH ↓",
              color = color.new(color.orange, 20), textcolor = color.white,
              style = label.style_label_down, size = size.tiny)

// ─────────────────────────────────────────
// VOLUME SURGE
// ─────────────────────────────────────────
vol_ma    = ta.sma(volume, vol_len)
vol_surge = volume > vol_ma * vol_mult

if show_vol and vol_surge
    vol_dir = close >= open
    label.new(bar_index, vol_dir ? low - atr * 0.3 : high + atr * 0.3,
              "⚡ VOL",
              color     = vol_dir ? color.new(color.lime, 40) : color.new(color.red, 40),
              textcolor = color.white,
              style     = vol_dir ? label.style_label_up : label.style_label_down,
              size      = size.tiny)

// ─────────────────────────────────────────
// RSI DIVERGENCE
// ─────────────────────────────────────────
rsi_ph = ta.pivothigh(rsi, 5, 5)
rsi_pl = ta.pivotlow(rsi,  5, 5)
prc_ph = ta.pivothigh(high, 5, 5)
prc_pl = ta.pivotlow(low,   5, 5)

bear_div = not na(rsi_ph) and not na(prc_ph) and prc_ph > prc_ph[1] and rsi_ph < rsi_ph[1]
bull_div = not na(rsi_pl) and not na(prc_pl) and prc_pl < prc_pl[1] and rsi_pl > rsi_pl[1]

bgcolor(bull_div ? color.new(color.lime, 92) : na, title = "Bullish Divergence BG")
bgcolor(bear_div ? color.new(color.red,  92) : na, title = "Bearish Divergence BG")

// ─────────────────────────────────────────
// MACD SIGNAL ARROWS
// ─────────────────────────────────────────
[macdLine, signalLine, _histLine] = ta.macd(close, 12, 26, 9)
macd_cross_up   = ta.crossover(macdLine,  signalLine)
macd_cross_down = ta.crossunder(macdLine, signalLine)

plotshape(macd_cross_up,   "MACD Bull Cross", shape.triangleup,   location.belowbar, color.new(color.teal,   20), size = size.tiny)
plotshape(macd_cross_down, "MACD Bear Cross", shape.triangledown, location.abovebar, color.new(color.orange, 20), size = size.tiny)

// ─────────────────────────────────────────
// ATR VOLATILITY BANDS
// ─────────────────────────────────────────
kelt_upper = ema50 + atr * 2
kelt_lower = ema50 - atr * 2

p_ku = plot(kelt_upper, "ATR Upper Band", color = color.new(color.gray, 70), linewidth = 1)
p_kl = plot(kelt_lower, "ATR Lower Band", color = color.new(color.gray, 70), linewidth = 1)
fill(p_ku, p_kl, color = color.new(color.gray, 96), title = "ATR Volatility Band")

// ─────────────────────────────────────────
// SESSION HIGHLIGHTS
// ─────────────────────────────────────────
hr = hour(time, "UTC")
is_london = hr >= 7  and hr < 10
is_ny     = hr >= 13 and hr < 16
is_asia   = hr >= 0  and hr < 4

bgcolor(show_session and is_london ? london_col : na, title = "London Session")
bgcolor(show_session and is_ny     ? ny_col     : na, title = "NY Session")
bgcolor(show_session and is_asia   ? asia_col   : na, title = "Asia Session")

// ─────────────────────────────────────────
// HH / HL / LH / LL LABELS
// ─────────────────────────────────────────
ph5 = ta.pivothigh(high, 5, 5)
pl5 = ta.pivotlow(low,   5, 5)

prev_ph5 = ta.valuewhen(not na(ph5), ph5, 1)
prev_pl5 = ta.valuewhen(not na(pl5), pl5, 1)

is_hh = not na(ph5) and ph5 > prev_ph5
is_lh = not na(ph5) and ph5 < prev_ph5
is_ll = not na(pl5) and pl5 < prev_pl5
is_hl = not na(pl5) and pl5 > prev_pl5

plotshape(is_hh, "HH", shape.labeldown, location.abovebar, color.new(color.lime,   0), text = "HH", textcolor = color.black, size = size.tiny)
plotshape(is_ll, "LL", shape.labelup,   location.belowbar, color.new(color.red,    0), text = "LL", textcolor = color.white, size = size.tiny)
plotshape(is_lh, "LH", shape.labeldown, location.abovebar, color.new(color.orange, 0), text = "LH", textcolor = color.white, size = size.tiny)
plotshape(is_hl, "HL", shape.labelup,   location.belowbar, color.new(color.teal,   0), text = "HL", textcolor = color.black, size = size.tiny)

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────
alertcondition(long_entry,      "Long Entry Signal",      "🟢 LONG Entry - Check TP/SL levels")
alertcondition(short_entry,     "Short Entry Signal",     "🔴 SHORT Entry - Check TP/SL levels")
alertcondition(bos_bull,        "Bullish BOS",            "Bullish Break of Structure")
alertcondition(bos_bear,        "Bearish BOS",            "Bearish Break of Structure")
alertcondition(vol_surge,       "Volume Surge",           "Volume Surge Detected")
alertcondition(macd_cross_up,   "MACD Bull Cross",        "MACD Bullish Crossover")
alertcondition(macd_cross_down, "MACD Bear Cross",        "MACD Bearish Crossover")
alertcondition(bull_div,        "Bullish RSI Divergence", "Bullish RSI Divergence Detected")
alertcondition(bear_div,        "Bearish RSI Divergence", "Bearish RSI Divergence Detected")
````
