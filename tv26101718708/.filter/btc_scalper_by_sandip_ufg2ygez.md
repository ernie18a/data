# BTC Scalper by Sandip

- url: https://www.tradingview.com/script/Ufg2YGEz-BTC-Scalper-by-Sandip/
- type: indicator
- pine_id: PUB;d7296fc906a344848561ca495aca5053
- version: 1.0

## Description

LONG Entry — BOTH must happen together:

✅ Price touches / bounces off Demand Zone (green band)
✅ EMA Fast crosses above EMA Slow within last 3 bars

SHORT Entry — BOTH must happen together:

✅ Price touches / rejects from Supply Zone (red band)
✅ EMA Fast crosses below EMA Slow within last 3 bars

HOLD Logic (Fixed ATR TP/SL):

🟢 TP = 3× ATR above entry
🔴 SL = 1.5× ATR below entry (RR = 2:1)

## Source Code

````pine
//@version=6
indicator("BTC Scalper — Zone + EMA Cross [CPR + TP/SL]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grp1 = "═══ EMA Settings ═══"
fast_len = input.int(20, "Fast EMA", group=grp1)
slow_len = input.int(50, "Slow EMA", group=grp1)

grp2 = "═══ CPR Settings ═══"
show_cpr = input.bool(true, "Show CPR Levels", group=grp2)
cpr_tf   = input.timeframe("D", "CPR Timeframe", group=grp2)

grp3 = "═══ Zone Settings ═══"
zone_lookback   = input.int(10,   "Pivot Lookback Bars",     group=grp3, minval=5, maxval=50)
zone_atr_width  = input.float(0.5, "Zone Width (ATR x)",     group=grp3, minval=0.1, maxval=2.0)
bounce_atr_dist = input.float(1.5, "Bounce Distance (ATR x)", group=grp3, minval=0.5, maxval=3.0)

grp4 = "═══ TP / SL ═══"
tp_atr = input.float(3.0, "Take Profit (ATR x)", group=grp4, minval=0.5, maxval=10.0)
sl_atr = input.float(1.5, "Stop Loss  (ATR x)",  group=grp4, minval=0.5, maxval=5.0)
show_tpsl = input.bool(true, "Show TP/SL Lines", group=grp4)

grp5 = "═══ Filters ═══"
use_rsi_filter  = input.bool(true,  "RSI Filter",            group=grp5)
rsi_len         = input.int(14,     "RSI Length",            group=grp5)
use_vol_filter  = input.bool(true,  "Volume Filter",         group=grp5)
vol_mult        = input.float(1.2,  "Volume Spike (x avg)",  group=grp5)
use_cpr_filter  = input.bool(true,  "CPR Side Filter",       group=grp5)

// ═══════════════════════════════════════════════════════════════
//  CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════
atr      = ta.atr(14)
rsi      = ta.rsi(close, rsi_len)
vol_avg  = ta.sma(volume, 20)

// EMA
ema_fast = ta.ema(close, fast_len)
ema_slow = ta.ema(close, slow_len)

// EMA Cross
ema_cross_up   = ta.crossover(ema_fast, ema_slow)
ema_cross_down = ta.crossunder(ema_fast, ema_slow)

plot(ema_fast, "EMA Fast", color=color.new(#29b6f6, 0), linewidth=2)
plot(ema_slow, "EMA Slow", color=color.new(#ff9800, 0), linewidth=2)

// ═══════════════════════════════════════════════════════════════
//  CPR LEVELS
// ═══════════════════════════════════════════════════════════════
prev_high  = request.security(syminfo.tickerid, cpr_tf, high[1],  lookahead=barmerge.lookahead_on)
prev_low   = request.security(syminfo.tickerid, cpr_tf, low[1],   lookahead=barmerge.lookahead_on)
prev_close = request.security(syminfo.tickerid, cpr_tf, close[1], lookahead=barmerge.lookahead_on)

pivot = (prev_high + prev_low + prev_close) / 3
bc    = (prev_high + prev_low) / 2
tc    = (pivot - bc) + pivot
r1    = (2 * pivot) - prev_low
r2    = pivot + (prev_high - prev_low)
s1    = (2 * pivot) - prev_high
s2    = pivot - (prev_high - prev_low)

plot(show_cpr ? pivot : na, "Pivot", color=color.new(#ffeb3b, 0),  linewidth=2)
plot(show_cpr ? tc    : na, "TC",    color=color.new(#ffeb3b, 50), linewidth=1)
plot(show_cpr ? bc    : na, "BC",    color=color.new(#ffeb3b, 50), linewidth=1)
plot(show_cpr ? r1    : na, "R1",    color=color.new(#ef5350, 50), linewidth=1, style=plot.style_circles)
plot(show_cpr ? r2    : na, "R2",    color=color.new(#ef5350, 70), linewidth=1, style=plot.style_circles)
plot(show_cpr ? s1    : na, "S1",    color=color.new(#26a69a, 50), linewidth=1, style=plot.style_circles)
plot(show_cpr ? s2    : na, "S2",    color=color.new(#26a69a, 70), linewidth=1, style=plot.style_circles)

above_pivot = close > pivot
below_pivot = close < pivot

// ═══════════════════════════════════════════════════════════════
//  SUPPLY & DEMAND ZONES — DYNAMIC
// ═══════════════════════════════════════════════════════════════
swing_high = ta.pivothigh(high, zone_lookback, zone_lookback)
swing_low  = ta.pivotlow(low,   zone_lookback, zone_lookback)

var float last_sh      = na
var float last_sh_bot  = na
var float last_sl      = na
var float last_sl_top  = na

if not na(swing_high)
    last_sh     := swing_high
    last_sh_bot := swing_high - atr * zone_atr_width

if not na(swing_low)
    last_sl     := swing_low
    last_sl_top := swing_low  + atr * zone_atr_width

// Supply zone (red band)
p_supply_top = plot(not na(last_sh)     ? last_sh     : na, "Supply Top", color=color.new(#ff1744, 10), linewidth=2)
p_supply_bot = plot(not na(last_sh_bot) ? last_sh_bot : na, "Supply Bot", color=color.new(#ff1744, 50), linewidth=1)
fill(p_supply_top, p_supply_bot, color=color.new(#ff1744, 85), title="Supply Zone")

// Demand zone (green band)
p_demand_bot = plot(not na(last_sl)     ? last_sl     : na, "Demand Bot", color=color.new(#00e676, 10), linewidth=2)
p_demand_top = plot(not na(last_sl_top) ? last_sl_top : na, "Demand Top", color=color.new(#00e676, 50), linewidth=1)
fill(p_demand_bot, p_demand_top, color=color.new(#00e676, 85), title="Demand Zone")

// ═══════════════════════════════════════════════════════════════
//  BOUNCE DETECTION
// ═══════════════════════════════════════════════════════════════
// LONG: price touched demand zone and is now bouncing up
in_demand_zone    = not na(last_sl) and low <= last_sl_top and low >= last_sl - atr * bounce_atr_dist
bouncing_from_demand = in_demand_zone and close > open and close > low[1]

// SHORT: price touched supply zone and is now rejecting down
in_supply_zone    = not na(last_sh) and high >= last_sh_bot and high <= last_sh + atr * bounce_atr_dist
rejecting_supply  = in_supply_zone and close < open and close < high[1]

// ═══════════════════════════════════════════════════════════════
//  OPTIONAL FILTERS
// ═══════════════════════════════════════════════════════════════
rsi_long_ok  = use_rsi_filter ? rsi > 35 and rsi < 65 : true
rsi_short_ok = use_rsi_filter ? rsi < 65 and rsi > 35 : true
vol_ok       = use_vol_filter ? volume > vol_avg * vol_mult : true
cpr_long_ok  = use_cpr_filter ? above_pivot : true
cpr_short_ok = use_cpr_filter ? below_pivot : true

// ═══════════════════════════════════════════════════════════════
//  FINAL SIGNAL LOGIC
//  LONG  = Demand Zone Bounce  AND  EMA Cross Up
//  SHORT = Supply Zone Reject  AND  EMA Cross Down
// ═══════════════════════════════════════════════════════════════

// EMA cross within last 3 bars (so bounce and cross align)
recent_cross_up   = ema_cross_up   or ema_cross_up[1]   or ema_cross_up[2]   or ema_cross_up[3]
recent_cross_down = ema_cross_down or ema_cross_down[1] or ema_cross_down[2] or ema_cross_down[3]

long_signal  = bouncing_from_demand and recent_cross_up   and rsi_long_ok  and vol_ok and cpr_long_ok
short_signal = rejecting_supply     and recent_cross_down and rsi_short_ok and vol_ok and cpr_short_ok

// ═══════════════════════════════════════════════════════════════
//  TP / SL LINES — FIXED ATR BASED
// ═══════════════════════════════════════════════════════════════
var line tp_line = na
var line sl_line = na
var float entry_px = na
var bool  in_long  = false
var bool  in_short = false

if long_signal and not in_long and not in_short
    entry_px := close
    in_long  := true
    in_short := false
    if not na(tp_line)
        line.delete(tp_line)
    if not na(sl_line)
        line.delete(sl_line)
    tp_line := line.new(bar_index, entry_px + atr * tp_atr, bar_index + 50, entry_px + atr * tp_atr, color=color.new(#00e676, 0), width=2, extend=extend.right, style=line.style_dashed)
    sl_line := line.new(bar_index, entry_px - atr * sl_atr, bar_index + 50, entry_px - atr * sl_atr, color=color.new(#ff1744, 0), width=2, extend=extend.right, style=line.style_dashed)

if short_signal and not in_short and not in_long
    entry_px := close
    in_short := true
    in_long  := false
    if not na(tp_line)
        line.delete(tp_line)
    if not na(sl_line)
        line.delete(sl_line)
    tp_line := line.new(bar_index, entry_px - atr * tp_atr, bar_index + 50, entry_px - atr * tp_atr, color=color.new(#00e676, 0), width=2, extend=extend.right, style=line.style_dashed)
    sl_line := line.new(bar_index, entry_px + atr * sl_atr, bar_index + 50, entry_px + atr * sl_atr, color=color.new(#ff1744, 0), width=2, extend=extend.right, style=line.style_dashed)

// Exit tracking
long_tp_hit  = in_long  and high >= entry_px + atr * tp_atr
long_sl_hit  = in_long  and low  <= entry_px - atr * sl_atr
short_tp_hit = in_short and low  <= entry_px - atr * tp_atr
short_sl_hit = in_short and high >= entry_px + atr * sl_atr

if long_tp_hit or long_sl_hit
    in_long := false
if short_tp_hit or short_sl_hit
    in_short := false

// ═══════════════════════════════════════════════════════════════
//  ENTRY / EXIT LABELS
// ═══════════════════════════════════════════════════════════════
if long_signal
    label.new(bar_index, low - atr * 0.6,
              "LONG\nZone+EMA",
              color=color.new(#00e676, 0),
              textcolor=color.white,
              style=label.style_label_up,
              size=size.normal)

if short_signal
    label.new(bar_index, high + atr * 0.6,
              "SHORT\nZone+EMA",
              color=color.new(#ff1744, 0),
              textcolor=color.white,
              style=label.style_label_down,
              size=size.normal)

if long_tp_hit
    label.new(bar_index, high + atr * 0.3, "TP HIT", color=color.new(#00e676, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
if long_sl_hit
    label.new(bar_index, low - atr * 0.3, "SL HIT", color=color.new(#ff1744, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
if short_tp_hit
    label.new(bar_index, low - atr * 0.3, "TP HIT", color=color.new(#00e676, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
if short_sl_hit
    label.new(bar_index, high + atr * 0.3, "SL HIT", color=color.new(#ff1744, 20), textcolor=color.white, style=label.style_label_down, size=size.small)

// EMA cross markers
plotshape(ema_cross_up,   "EMA Bull Cross", style=shape.triangleup,   location=location.belowbar, color=color.new(#29b6f6, 0), size=size.tiny)
plotshape(ema_cross_down, "EMA Bear Cross", style=shape.triangledown, location=location.abovebar, color=color.new(#ff9800, 0), size=size.tiny)

// Background while in trade
bgcolor(in_long  ? color.new(#00e676, 96) : na, title="Long Hold Zone")
bgcolor(in_short ? color.new(#ff1744, 96) : na, title="Short Hold Zone")

// ═══════════════════════════════════════════════════════════════
//  HUD TABLE
// ═══════════════════════════════════════════════════════════════
var table hud = table.new(position.top_right, 2, 9, bgcolor=color.new(#131722, 5), border_color=color.new(#363a45, 60), border_width=1)

trend_txt    = ema_fast > ema_slow ? "BULL" : "BEAR"
trend_col    = ema_fast > ema_slow ? color.new(#00e676, 0) : color.new(#ff1744, 0)
rsi_txt      = str.tostring(math.round(rsi, 1))
zone_txt     = in_demand_zone ? "IN DEMAND" : in_supply_zone ? "IN SUPPLY" : "BETWEEN"
zone_col     = in_demand_zone ? color.new(#00e676, 0) : in_supply_zone ? color.new(#ff1744, 0) : color.gray
pos_txt      = in_long ? "LONG" : in_short ? "SHORT" : "FLAT"
pos_col      = in_long ? color.new(#00e676, 0) : in_short ? color.new(#ff1744, 0) : color.gray
cpr_side_txt = above_pivot ? "ABOVE PIVOT" : "BELOW PIVOT"
cpr_side_col = above_pivot ? color.new(#00e676, 0) : color.new(#ff1744, 0)
tp_txt       = not na(entry_px) and (in_long or in_short) ? str.tostring(math.round(in_long ? entry_px + atr * tp_atr : entry_px - atr * tp_atr, 1)) : "—"
sl_txt       = not na(entry_px) and (in_long or in_short) ? str.tostring(math.round(in_long ? entry_px - atr * sl_atr : entry_px + atr * sl_atr, 1)) : "—"
cross_txt    = recent_cross_up ? "BULL CROSS" : recent_cross_down ? "BEAR CROSS" : "NO CROSS"
cross_col    = recent_cross_up ? color.new(#29b6f6, 0) : recent_cross_down ? color.new(#ff9800, 0) : color.gray

table.cell(hud, 0, 0, "ZONE + EMA SCALPER", text_color=color.white,  bgcolor=color.new(#1e222d, 0), text_size=size.small)
table.cell(hud, 1, 0, "15m",                text_color=color.gray,   bgcolor=color.new(#1e222d, 0), text_size=size.small)
table.cell(hud, 0, 1, "EMA Trend",          text_color=color.gray,   text_size=size.small)
table.cell(hud, 1, 1, trend_txt,            text_color=trend_col,    text_size=size.small)
table.cell(hud, 0, 2, "EMA Cross",          text_color=color.gray,   text_size=size.small)
table.cell(hud, 1, 2, cross_txt,            text_color=cross_col,    text_size=size.small)
table.cell(hud, 0, 3, "Price Zone",         text_color=color.gray,   text_size=size.small)
table.cell(hud, 1, 3, zone_txt,             text_color=zone_col,     text_size=size.small)
table.cell(hud, 0, 4, "CPR Side",           text_color=color.gray,   text_size=size.small)
table.cell(hud, 1, 4, cpr_side_txt,         text_color=cpr_side_col, text_size=size.small)
table.cell(hud, 0, 5, "RSI",                text_color=color.gray,   text_size=size.small)
table.cell(hud, 1, 5, rsi_txt,              text_color=color.white,  text_size=size.small)
table.cell(hud, 0, 6, "Position",           text_color=color.gray,   text_size=size.small)
table.cell(hud, 1, 6, pos_txt,              text_color=pos_col,      text_size=size.small)
table.cell(hud, 0, 7, "TP Price",           text_color=color.gray,   text_size=size.small)
table.cell(hud, 1, 7, tp_txt,               text_color=color.new(#00e676, 0), text_size=size.small)
table.cell(hud, 0, 8, "SL Price",           text_color=color.gray,   text_size=size.small)
table.cell(hud, 1, 8, sl_txt,               text_color=color.new(#ff1744, 0), text_size=size.small)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(long_signal,  "LONG  — Zone Bounce + EMA Cross Up",   "BTC LONG: Demand Zone bounce + EMA Cross Up")
alertcondition(short_signal, "SHORT — Zone Reject + EMA Cross Down", "BTC SHORT: Supply Zone reject + EMA Cross Down")
alertcondition(long_tp_hit,  "LONG TP Hit",  "BTC LONG Take Profit Hit")
alertcondition(long_sl_hit,  "LONG SL Hit",  "BTC LONG Stop Loss Hit")
alertcondition(short_tp_hit, "SHORT TP Hit", "BTC SHORT Take Profit Hit")
alertcondition(short_sl_hit, "SHORT SL Hit", "BTC SHORT Stop Loss Hit")
````
