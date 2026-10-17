# Trader DrFXAi

- url: https://www.tradingview.com/script/xFYJn9N3-Trader-DrFXAi/
- type: indicator
- pine_id: PUB;02d428232b2749ae9b7cb5c0f7feb53c
- version: 1.0

## Description

Trader DrFXAi is a smart price action and market structure indicator designed to help traders identify potential trading opportunities and market direction.

Features

* Market structure analysis
* Buy and Sell signal detection
* Trend identification
* Session filtering
* Dynamic support and resistance zones
* Visual chart annotations

How to Use

1. Add the indicator to your chart.
2. Follow the market structure and trend direction.
3. Use Buy and Sell signals as trade confirmation.
4. Combine with proper risk management.
5. Higher timeframes can be used for trend confirmation.

Recommended Markets

* XAUUSD (Gold)
* Forex pairs
* Indices
* Cryptocurrencies

Disclaimer

This indicator is intended for educational and analytical purposes only. It does not guarantee profits and should not be considered financial advice. Always perform your own analysis and use proper risk management.

## Source Code

````pine
//@version=6
indicator("Trader DrFXAi", "DrFXAi Pro"
  , overlay = true
  , max_labels_count = 500
  , max_lines_count = 500
  , max_boxes_count = 500
  , max_bars_back = 500)

// ═══════════════════════════════════════════════════════
// SESSION FILTER
// ═══════════════════════════════════════════════════════
use_session_filter = input.bool(true, "Only Trade in Active Sessions", group="SESSION FILTER")
show_session_bg    = input.bool(true, "Show Session Background",       group="SESSION FILTER")
london_open        = input.int(8,  "London Open  (GMT)", minval=0, maxval=23, group="SESSION FILTER")
london_close       = input.int(12, "London Close (GMT)", minval=0, maxval=23, group="SESSION FILTER")
ny_open            = input.int(13, "New York Open  (GMT)", minval=0, maxval=23, group="SESSION FILTER")
ny_close           = input.int(20, "New York Close (GMT)", minval=0, maxval=23, group="SESSION FILTER")

bar_hour_gmt = math.floor((time / 3600000) % 24)
is_london    = bar_hour_gmt >= london_open  and bar_hour_gmt < london_close
is_ny        = bar_hour_gmt >= ny_open      and bar_hour_gmt < ny_close
is_overlap   = is_london and is_ny
is_active    = is_london or is_ny

bgcolor(show_session_bg and is_overlap ? color.new(#ff9800, 88) : na, title="Overlap")
bgcolor(show_session_bg and is_london  and not is_overlap ? color.new(#2196F3, 92) : na, title="London")
bgcolor(show_session_bg and is_ny      and not is_overlap ? color.new(#4CAF50, 92) : na, title="New York")

// ═══════════════════════════════════════════════════════
// SUPERTREND
// ═══════════════════════════════════════════════════════
var float nsensitivity = 1
nbuysell = input.bool(true, "Buy/Sell Signal", inline="BSNM", group="BUY/SELL SIGNAL")

supertrend(_src, factor, atrLen) =>
    atr        = ta.atr(atrLen)
    upperBand  = _src + factor * atr
    lowerBand  = _src - factor * atr
    prevLower  = nz(lowerBand[1])
    prevUpper  = nz(upperBand[1])
    lowerBand := lowerBand > prevLower or close[1] < prevLower ? lowerBand : prevLower
    upperBand := upperBand < prevUpper or close[1] > prevUpper ? upperBand : prevUpper
    var int   direction  = na
    var float superTrend = na
    prevST = nz(superTrend[1])
    if na(atr[1])
        direction := 1
    else if prevST == prevUpper
        direction := close > upperBand ? -1 : 1
    else
        direction := close < lowerBand ? 1 : -1
    superTrend := direction == -1 ? lowerBand : upperBand
    [superTrend, direction]

[supertrend, direction] = supertrend(close, nsensitivity * 7, 10)
bull = ta.crossover(close, supertrend)
bear = ta.crossunder(close, supertrend)

// ═══════════════════════════════════════════════════════
// H4 BIAS
// ═══════════════════════════════════════════════════════
h4_close = request.security(syminfo.tickerid, "240", close)
h4_ema   = request.security(syminfo.tickerid, "240", ta.ema(close, 50))
h4_bull  = h4_close > h4_ema
h4_bear  = h4_close < h4_ema

// ═══════════════════════════════════════════════════════
// DAILY & WEEKLY BIAS
// ═══════════════════════════════════════════════════════
d1_close = request.security(syminfo.tickerid, "D", close)
d1_ema   = request.security(syminfo.tickerid, "D", ta.ema(close, 20))
d1_bull  = d1_close > d1_ema
d1_bear  = d1_close < d1_ema

w1_close = request.security(syminfo.tickerid, "W", close)
w1_ema   = request.security(syminfo.tickerid, "W", ta.ema(close, 10))
w1_bull  = w1_close > w1_ema
w1_bear  = w1_close < w1_ema

// ═══════════════════════════════════════════════════════
// ADX FILTER
// ═══════════════════════════════════════════════════════
adx_threshold     = input.int(22, "ADX Threshold",          minval=10, maxval=50, group="ADX FILTER")
sidewaysThreshold = input.int(15, "ADX Sideways Threshold", minval=2,             group="ADX FILTER")
adxlen = 15
dilen  = 15

dirmov(len) =>
    up      = ta.change(high)
    down    = -ta.change(low)
    plusDM  = na(up)   ? na : up   > down and up   > 0 ? up   : 0
    minusDM = na(down) ? na : down > up   and down > 0 ? down : 0
    tr      = ta.rma(ta.tr, len)
    plus    = fixnan(100 * ta.rma(plusDM,  len) / tr)
    minus   = fixnan(100 * ta.rma(minusDM, len) / tr)
    [plus, minus]

adx(dilen, adxlen) =>
    [plus, minus] = dirmov(dilen)
    sum = plus + minus
    100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)

sig        = adx(dilen, adxlen)
adx_ok     = sig > adx_threshold
isSideways = sig < sidewaysThreshold

// ═══════════════════════════════════════════════════════
// RSI DIVERGENCE FILTER
// ═══════════════════════════════════════════════════════
rsi_len        = input.int(14,   "RSI Length",             minval=2,  maxval=50,  group="RSI DIVERGENCE")
rsi_ob         = input.int(70,   "RSI Overbought",         minval=60, maxval=90,  group="RSI DIVERGENCE")
rsi_os         = input.int(30,   "RSI Oversold",           minval=10, maxval=40,  group="RSI DIVERGENCE")
div_lookback   = input.int(5,    "Divergence Lookback",    minval=2,  maxval=20,  group="RSI DIVERGENCE")
show_div       = input.bool(true, "Show Divergence Labels",                       group="RSI DIVERGENCE")

rsi_val = ta.rsi(close, rsi_len)

// Pivot price & RSI
ph_price = ta.pivothigh(high,    div_lookback, div_lookback)
pl_price = ta.pivotlow(low,      div_lookback, div_lookback)
ph_rsi   = ta.pivothigh(rsi_val, div_lookback, div_lookback)
pl_rsi   = ta.pivotlow(rsi_val,  div_lookback, div_lookback)

// Bearish divergence: price HH, RSI LH → xu hướng yếu dần
var float prev_ph_price = na
var float prev_ph_rsi   = na
bear_div = false
if not na(ph_price) and not na(ph_rsi)
    if not na(prev_ph_price) and not na(prev_ph_rsi)
        bear_div := ph_price > prev_ph_price and ph_rsi < prev_ph_rsi
    prev_ph_price := ph_price
    prev_ph_rsi   := ph_rsi

// Bullish divergence: price LL, RSI HL → xu hướng yếu dần phía dưới
var float prev_pl_price = na
var float prev_pl_rsi   = na
bull_div = false
if not na(pl_price) and not na(pl_rsi)
    if not na(prev_pl_price) and not na(prev_pl_rsi)
        bull_div := pl_price < prev_pl_price and pl_rsi > prev_pl_rsi
    prev_pl_price := pl_price
    prev_pl_rsi   := pl_rsi

// RSI zone filter
rsi_is_ob = rsi_val >= rsi_ob
rsi_is_os = rsi_val <= rsi_os

// Chặn tín hiệu BUY khi RSI overbought + bearish divergence
// Chặn tín hiệu SELL khi RSI oversold + bullish divergence
var bool recent_bear_div = false
var bool recent_bull_div = false
var int  bear_div_bar    = 0
var int  bull_div_bar    = 0

if bear_div
    recent_bear_div := true
    bear_div_bar    := bar_index
if bull_div
    recent_bull_div := true
    bull_div_bar    := bar_index

// Reset divergence sau 10 bar
if bar_index - bear_div_bar > 10
    recent_bear_div := false
if bar_index - bull_div_bar > 10
    recent_bull_div := false

// Filter: block tín hiệu khi có divergence ngược chiều
bull_div_blocked = (recent_bear_div and rsi_is_ob)
bear_div_blocked = (recent_bull_div and rsi_is_os)

if show_div and bear_div
    label.new(bar_index - div_lookback, high[div_lookback] + ta.atr(14) * 0.5,
      "RSI Div↓", xloc.bar_index, yloc.price,
      color.rgb(244, 67, 54, 20), label.style_label_down,
      color.white, size.tiny)

if show_div and bull_div
    label.new(bar_index - div_lookback, low[div_lookback] - ta.atr(14) * 0.5,
      "RSI Div↑", xloc.bar_index, yloc.price,
      color.rgb(76, 175, 80, 20), label.style_label_up,
      color.white, size.tiny)

// ═══════════════════════════════════════════════════════
// CONFLUENCE
// ═══════════════════════════════════════════════════════
bull_session_ok = is_active and h4_bull and adx_ok and not bull_div_blocked
bear_session_ok = is_active and h4_bear and adx_ok and not bear_div_blocked

valid_bull = bull and bull_session_ok
valid_bear = bear and bear_session_ok
weak_bull  = bull and not bull_session_ok
weak_bear  = bear and not bear_session_ok

// ═══════════════════════════════════════════════════════
// RISK MANAGEMENT
// ═══════════════════════════════════════════════════════
levels2     = input.bool(true,      "Show TP/SL Levels",  group="Risk Management", inline="MMDB2")
lvlLines    = input.bool(true,      "Show Lines",          group="Risk Management", inline="levels2")
linesStyle  = input.string("SOLID", "", ["SOLID","DASHED","DOTTED"], group="Risk Management", inline="levels2")
lvlDecimals = input.int(4,          "Decimals", 1, 8,      group="Risk Management", inline="levels2")
atrRisk     = input.int(3,          "Risk ATR Mult", 1,    group="Risk Management", inline="levels3")
atrLen      = input.int(14,         "ATR Length",    1,    group="Risk Management", inline="levels3")
percentStop = input.float(1,        "Stop Loss % (0 to Disable)", 0, group="Risk Management")

decimals = lvlDecimals == 1 ? "#.#"       : lvlDecimals == 2 ? "#.##"     :
           lvlDecimals == 3 ? "#.###"     : lvlDecimals == 4 ? "#.####"   :
           lvlDecimals == 5 ? "#.#####"   : lvlDecimals == 6 ? "#.######" :
           lvlDecimals == 7 ? "#.#######" : "#.########"

atrBand   = ta.atr(atrLen) * atrRisk
countBull = ta.barssince(bull)
countBear = ta.barssince(bear)
trigger   = nz(countBull, bar_index) < nz(countBear, bar_index) ? 1 : 0
atrStop   = trigger == 1 ? low - atrBand : high + atrBand

lastTrade(src) => ta.valuewhen(bull or bear, src, 0)
entry_y = lastTrade(close)
stop_y  = lastTrade(atrStop)
tp1_y   = (entry_y - stop_y) * 1 + entry_y
tp2_y   = (entry_y - stop_y) * 2 + entry_y
tp3_y   = (entry_y - stop_y) * 3 + entry_y

// ═══════════════════════════════════════════════════════
// STRUCTURE SL + OB RETEST — MULTI-TIMEFRAME ADAPTIVE
// ═══════════════════════════════════════════════════════
show_retest_box  = input.bool(true,  "Show OB Retest Zone",       group="Structure SL & OB Retest")
use_auto_params  = input.bool(true,  "Auto Params by Timeframe",  group="Structure SL & OB Retest")
man_sl_lookback  = input.int(10,     "SL Lookback (Manual)",      minval=3, maxval=100,            group="Structure SL & OB Retest")
man_ob_mult      = input.float(1.2,  "OB Zone Mult (Manual)",     minval=0.3, maxval=5.0, step=0.1, group="Structure SL & OB Retest")
man_sl_buffer    = input.float(0.3,  "SL Buffer ATR (Manual)",    minval=0.0, maxval=2.0, step=0.1, group="Structure SL & OB Retest")
man_wait_bars    = input.int(20,     "Max Wait Bars (Manual)",    minval=5, maxval=200,             group="Structure SL & OB Retest")

tf_minutes = timeframe.in_seconds() / 60

auto_sl_lookback =
  tf_minutes <= 3   ? 20  :
  tf_minutes <= 5   ? 18  :
  tf_minutes <= 15  ? 14  :
  tf_minutes <= 30  ? 12  :
  tf_minutes <= 60  ? 10  :
  tf_minutes <= 240 ? 8   : 6

auto_ob_mult =
  tf_minutes <= 3   ? 2.5 :
  tf_minutes <= 5   ? 2.0 :
  tf_minutes <= 15  ? 1.6 :
  tf_minutes <= 30  ? 1.4 :
  tf_minutes <= 60  ? 1.2 :
  tf_minutes <= 240 ? 1.0 : 0.8

auto_sl_buffer =
  tf_minutes <= 3   ? 0.8 :
  tf_minutes <= 5   ? 0.6 :
  tf_minutes <= 15  ? 0.5 :
  tf_minutes <= 30  ? 0.4 :
  tf_minutes <= 60  ? 0.3 :
  tf_minutes <= 240 ? 0.25 : 0.2

auto_wait_bars =
  tf_minutes <= 3   ? 40  :
  tf_minutes <= 5   ? 35  :
  tf_minutes <= 15  ? 25  :
  tf_minutes <= 30  ? 20  :
  tf_minutes <= 60  ? 15  :
  tf_minutes <= 240 ? 12  : 8

sl_lookback    = use_auto_params ? auto_sl_lookback : man_sl_lookback
ob_zone_mult   = use_auto_params ? auto_ob_mult     : man_ob_mult
sl_buffer_mult = use_auto_params ? auto_sl_buffer   : man_sl_buffer
max_wait_bars  = use_auto_params ? auto_wait_bars   : man_wait_bars

atr14 = ta.atr(14)

// ADX threshold tăng theo khung nhỏ
adx_min_tf =
  tf_minutes <= 3   ? 28 :
  tf_minutes <= 5   ? 26 :
  tf_minutes <= 15  ? 24 :
  tf_minutes <= 30  ? 23 : adx_threshold

adx_ok_retest = sig > adx_min_tf

// Noise filter body candle
min_body_ratio =
  tf_minutes <= 3  ? 0.45 :
  tf_minutes <= 5  ? 0.40 :
  tf_minutes <= 15 ? 0.35 : 0.25

candle_body  = math.abs(close - open)
candle_range = high - low
body_ok      = candle_range > 0 ? candle_body / candle_range >= min_body_ratio : false

// Structure SL
struct_low  = ta.lowest(low,   sl_lookback)
struct_high = ta.highest(high, sl_lookback)

bull_struct_sl = struct_low  - atr14 * sl_buffer_mult
bear_struct_sl = struct_high + atr14 * sl_buffer_mult

// OB Retest state
var float  rtop          = na
var float  rbtm          = na
var int    rdir          = 0
var bool   r_pending     = false
var int    r_fired_bar   = 0
var box    r_box         = na
var float  r_entry_price = na
var float  r_sl_price    = na

ob_zone = atr14 * ob_zone_mult

if valid_bull and adx_ok_retest
    rtop          := close
    rbtm          := close - ob_zone
    rdir          := 1
    r_pending     := true
    r_fired_bar   := bar_index
    r_entry_price := close
    r_sl_price    := bull_struct_sl
    box.delete(r_box)
    if show_retest_box
        r_box := box.new(
          bar_index, rtop, bar_index + max_wait_bars, rbtm,
          border_color = color.rgb(76, 175, 80, 20),
          bgcolor      = color.rgb(76, 175, 80, 82))

if valid_bear and adx_ok_retest
    rbtm          := close
    rtop          := close + ob_zone
    rdir          := -1
    r_pending     := true
    r_fired_bar   := bar_index
    r_entry_price := close
    r_sl_price    := bear_struct_sl
    box.delete(r_box)
    if show_retest_box
        r_box := box.new(
          bar_index, rtop, bar_index + max_wait_bars, rbtm,
          border_color = color.rgb(244, 67, 54, 20),
          bgcolor      = color.rgb(244, 67, 54, 82))

retest_bull = r_pending and rdir ==  1 and body_ok and
              low  <= rtop and close >= rbtm and
              close > open and bar_index > r_fired_bar + 1

retest_bear = r_pending and rdir == -1 and body_ok and
              high >= rbtm and close <= rtop and
              close < open and bar_index > r_fired_bar + 1

retest_expired     = r_pending and (bar_index - r_fired_bar) >= max_wait_bars
retest_invalidated = (r_pending and rdir ==  1 and close < bull_struct_sl) or
                     (r_pending and rdir == -1 and close > bear_struct_sl)

if retest_expired or retest_invalidated
    r_pending := false
    rdir      := 0
    box.delete(r_box)

if retest_bull or retest_bear
    r_pending := false
    rdir      := 0
    box.delete(r_box)

retest_risk_bull = r_entry_price - bull_struct_sl
retest_risk_bear = bear_struct_sl - r_entry_price

retest_tp1_bull = r_entry_price + retest_risk_bull * 1.5
retest_tp2_bull = r_entry_price + retest_risk_bull * 3.0
retest_tp1_bear = r_entry_price - retest_risk_bear * 1.5
retest_tp2_bear = r_entry_price - retest_risk_bear * 3.0

// ═══════════════════════════════════════════════════════
// ENTRY LABELS
// ═══════════════════════════════════════════════════════
entry_atr = ta.atr(14)
sl_pts    = math.round(entry_atr * 1.5 / syminfo.mintick)
tp1_pts   = math.round(entry_atr * 1.5 / syminfo.mintick)
tp2_pts   = math.round(entry_atr * 3.0 / syminfo.mintick)

session_tag = is_overlap ? "OVERLAP" : is_london ? "LONDON" : is_ny ? "NEW YORK" : "--"
h4_tag      = h4_bull ? "H4: BULL" : "H4: BEAR"
adx_tag     = "ADX: " + str.tostring(math.round(sig, 1))

y1 = low  - ta.atr(30) * 2
y2 = high + ta.atr(30) * 2

buy_txt = "BUY\n" + session_tag + "\n" + h4_tag + "\n" + adx_tag +
          "\nSL "  + str.tostring(sl_pts)  + " pts" +
          "\nTP1 " + str.tostring(tp1_pts) + " pts" +
          "\nTP2 " + str.tostring(tp2_pts) + " pts"

sell_txt = "SELL\n" + session_tag + "\n" + h4_tag + "\n" + adx_tag +
           "\nSL "  + str.tostring(sl_pts)  + " pts" +
           "\nTP1 " + str.tostring(tp1_pts) + " pts" +
           "\nTP2 " + str.tostring(tp2_pts) + " pts"

buy_color  = is_overlap ? color.rgb(255,152,0,20) : is_london ? color.rgb(33,150,243,20) : color.rgb(76,175,80,20)
sell_color = is_overlap ? color.rgb(255,87,34,20) : is_london ? color.rgb(244,67,54,20)  : color.rgb(233,30,99,20)

if valid_bull and nbuysell
    label.new(bar_index, y1, buy_txt,
      xloc.bar_index, yloc.price, buy_color,
      label.style_label_up, color.white, size.small)

if valid_bear and nbuysell
    label.new(bar_index, y2, sell_txt,
      xloc.bar_index, yloc.price, sell_color,
      label.style_label_down, color.white, size.small)

if weak_bull and nbuysell
    label.new(bar_index, y1, "BUY\nweak",
      xloc.bar_index, yloc.price,
      color.rgb(76,175,80,75), label.style_label_up,
      color.rgb(255,255,255,60), size.tiny)

if weak_bear and nbuysell
    label.new(bar_index, y2, "SELL\nweak",
      xloc.bar_index, yloc.price,
      color.rgb(244,67,54,75), label.style_label_down,
      color.rgb(255,255,255,60), size.tiny)

// ─── Retest Entry Labels ─────────────────────────────
retest_atr30 = ta.atr(30)

rt_buy_txt = "🎯 BUY RETEST\n" + session_tag + "\n" + h4_tag + "\n" + adx_tag +
             "\nEntry : " + str.tostring(math.round(close, 2)) +
             "\nSL    : " + str.tostring(math.round(bull_struct_sl, 2)) +
             "\nTP1   : " + str.tostring(math.round(retest_tp1_bull, 2)) +
             "\nTP2   : " + str.tostring(math.round(retest_tp2_bull, 2))

rt_sell_txt = "🎯 SELL RETEST\n" + session_tag + "\n" + h4_tag + "\n" + adx_tag +
              "\nEntry : " + str.tostring(math.round(close, 2)) +
              "\nSL    : " + str.tostring(math.round(bear_struct_sl, 2)) +
              "\nTP1   : " + str.tostring(math.round(retest_tp1_bear, 2)) +
              "\nTP2   : " + str.tostring(math.round(retest_tp2_bear, 2))

if retest_bull and nbuysell
    label.new(bar_index, low - retest_atr30 * 1.5, rt_buy_txt,
      xloc.bar_index, yloc.price,
      color.rgb(0, 230, 64, 10), label.style_label_up,
      color.white, size.small)
    line.new(bar_index - 2, bull_struct_sl,   bar_index + 15, bull_struct_sl,
      color=color.rgb(255,50,50),  style=line.style_dashed, width=2)
    line.new(bar_index - 2, retest_tp1_bull,  bar_index + 15, retest_tp1_bull,
      color=color.rgb(0,230,64),   style=line.style_dotted, width=1)
    line.new(bar_index - 2, retest_tp2_bull,  bar_index + 15, retest_tp2_bull,
      color=color.rgb(0,200,50),   style=line.style_dotted, width=2)

if retest_bear and nbuysell
    label.new(bar_index, high + retest_atr30 * 1.5, rt_sell_txt,
      xloc.bar_index, yloc.price,
      color.rgb(255,50,50,10), label.style_label_down,
      color.white, size.small)
    line.new(bar_index - 2, bear_struct_sl,   bar_index + 15, bear_struct_sl,
      color=color.rgb(255,50,50),  style=line.style_dashed, width=2)
    line.new(bar_index - 2, retest_tp1_bear,  bar_index + 15, retest_tp1_bear,
      color=color.rgb(0,230,64),   style=line.style_dotted, width=1)
    line.new(bar_index - 2, retest_tp2_bear,  bar_index + 15, retest_tp2_bear,
      color=color.rgb(0,200,50),   style=line.style_dotted, width=2)

// ═══════════════════════════════════════════════════════
// TP/SL LINES & LABELS
// ═══════════════════════════════════════════════════════
labelTpSl(y, txt, clr) =>
    lbl = lvlLines ? label.new(bar_index + 1, y, txt,
      xloc.bar_index, yloc.price, clr,
      label.style_label_left, #000000, size.normal) : na
    label.delete(lbl[1])

if levels2
    labelTpSl(entry_y, "Entry -- "     + str.tostring(entry_y, decimals), color.rgb(242,244,252))
    labelTpSl(stop_y,  "Stop Loss -- " + str.tostring(stop_y,  decimals), #f90808)
    labelTpSl(tp1_y,   "TP 1 -- "     + str.tostring(tp1_y,   decimals), #00ff08)
    labelTpSl(tp2_y,   "TP 2 -- "     + str.tostring(tp2_y,   decimals), #00ff08)
    labelTpSl(tp3_y,   "TP 3 -- "     + str.tostring(tp3_y,   decimals), #00ff08)

style2 = linesStyle == "SOLID" ? line.style_solid :
         linesStyle == "DASHED" ? line.style_dashed : line.style_dotted

lineTpSl(y, clr) =>
    ln = lvlLines ? line.new(
      bar_index - (trigger == 1 ? countBull : countBear) + 4,
      y, bar_index + 1, y,
      xloc.bar_index, extend.none, clr, style2) : na
    line.delete(ln[1])

if lvlLines
    lineTpSl(entry_y, color.green)
    lineTpSl(stop_y,  color.red)
    lineTpSl(tp1_y,   color.green)
    lineTpSl(tp2_y,   color.green)
    lineTpSl(tp3_y,   color.green)

// ═══════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════
show_dashboard = input.bool(true, "Show Dashboard", group="DASHBOARD")

if show_dashboard and barstate.islast
    session_str = is_overlap ? "OVERLAP" : is_london ? "LONDON" : is_ny ? "NEW YORK" : "ASIAN"
    h4_str      = h4_bull ? "▲ BULLISH" : "▼ BEARISH"
    d1_str      = d1_bull ? "▲ BULLISH" : "▼ BEARISH"
    w1_str      = w1_bull ? "▲ BULLISH" : "▼ BEARISH"
    adx_str     = str.tostring(math.round(sig, 1)) + (adx_ok ? " ✓" : " ✗")
    rsi_str     = str.tostring(math.round(rsi_val, 1)) +
                  (rsi_is_ob ? " OB" : rsi_is_os ? " OS" : "")
    div_str     = recent_bear_div ? "Bear Div ⚠" : recent_bull_div ? "Bull Div ⚠" : "None"
    sig_str     = valid_bull  ? "▲ BUY"      :
                  valid_bear  ? "▼ SELL"     :
                  retest_bull ? "🎯 BUY RT"  :
                  retest_bear ? "🎯 SELL RT" :
                  weak_bull   ? "~ BUY weak" :
                  weak_bear   ? "~ SELL weak": "— WAIT"
    tf_tag      = use_auto_params ? "AUTO" : "MANUAL"
    tf_str      = "TF " + str.tostring(tf_minutes) + "m [" + tf_tag + "]"

    dash_txt = "══ DRFXAI PRO ══\n"  +
               "TF      : " + tf_str     + "\n" +
               "Session : " + session_str + "\n" +
               "─────────────────\n" +
               "W1 Bias : " + w1_str     + "\n" +
               "D1 Bias : " + d1_str     + "\n" +
               "H4 Bias : " + h4_str     + "\n" +
               "─────────────────\n" +
               "ADX     : " + adx_str    + "\n" +
               "RSI     : " + rsi_str    + "\n" +
               "Div     : " + div_str    + "\n" +
               "─────────────────\n" +
               "Signal  : " + sig_str

    var table dash = table.new(position.top_right, 1, 1,
      bgcolor      = color.rgb(13,17,28,10),
      border_color = color.rgb(100,100,100,50),
      border_width = 1)

    table.cell(dash, 0, 0, dash_txt,
      text_color = color.white,
      text_size  = size.small,
      bgcolor    = color.rgb(13,17,28,80))

// ═══════════════════════════════════════════════════════
// CIRRUS CLOUD
// ═══════════════════════════════════════════════════════
CirrusCloud = input(true, "Cirrus Cloud", group="TREND FEATURES")

smoothrng(x, t, m) =>
    wper  = t * 2 - 1
    avrng = ta.ema(math.abs(x - x[1]), t)
    ta.ema(avrng, wper) * m

rngfilt(x, r) =>
    var float f = x
    f := x > nz(f[1]) ? x - r < nz(f[1]) ? nz(f[1]) : x - r :
         x + r > nz(f[1]) ? nz(f[1]) : x + r
    f

smrngx1 = smoothrng(close, 22, 9)
smrngx2 = smoothrng(close, 15, 5)
filtx1  = rngfilt(close, smrngx1)
filtx12 = rngfilt(close, smrngx2)

cloud_css = color.rgb(0,187,212,100)
p1 = plot(CirrusCloud ? filtx1  : na, color=cloud_css, linewidth=1, title="Trend Tracer 1", editable=false)
p2 = plot(CirrusCloud ? filtx12 : na, color=cloud_css, linewidth=1, title="Trend Tracer 2", editable=false)
fill(p1, p2, color = filtx1 > filtx12 ? color.rgb(254,0,0,86) : color.rgb(21,255,0,86))

// ═══════════════════════════════════════════════════════
// BAR COLOR
// ═══════════════════════════════════════════════════════
barcolor(isSideways ? #b102fc : na)
barcolor(close > supertrend ? #3cff00 : #fe0100)

// ═══════════════════════════════════════════════════════
// SMC MODULE
// ═══════════════════════════════════════════════════════
color TRANSP_CSS = #ffffff00

mode       = input.string('Historical', options=['Historical','Present'], group='Smart Money Concepts')
style      = input.string('Colored',    options=['Colored','Monochrome'], group='Smart Money Concepts')
show_trend = input(false, 'Color Candles', group='Smart Money Concepts')

show_internals          = input(false, 'Show Internal Structure',  group='Real Time Internal Structure')
show_ibull              = input.string('All', 'Bullish Structure', options=['All','BOS','CHoCH'], inline='ibull', group='Real Time Internal Structure')
swing_ibull_css         = input(#089981, '', inline='ibull', group='Real Time Internal Structure')
show_ibear              = input.string('All', 'Bearish Structure', options=['All','BOS','CHoCH'], inline='ibear', group='Real Time Internal Structure')
swing_ibear_css         = input(#f23645, '', inline='ibear', group='Real Time Internal Structure')
ifilter_confluence      = input(false, 'Confluence Filter',        group='Real Time Internal Structure')
internal_structure_size = input.string('Tiny', 'Internal Label Size', options=['Tiny','Small','Normal'], group='Real Time Internal Structure')

show_Structure       = input(true,  'Show Swing Structure',  group='Real Time Swing Structure')
show_bull            = input.string('All', 'Bullish Structure', options=['All','BOS','CHoCH'], inline='bull', group='Real Time Swing Structure')
swing_bull_css       = input(color.rgb(0,0,0), '', inline='bull', group='Real Time Swing Structure')
show_bear            = input.string('All', 'Bearish Structure', options=['All','BOS','CHoCH'], inline='bear', group='Real Time Swing Structure')
swing_bear_css       = input(#000000, '', inline='bear', group='Real Time Swing Structure')
swing_structure_size = input.string('Small', 'Swing Label Size', options=['Tiny','Small','Normal'], group='Real Time Swing Structure')
show_swings          = input(false, 'Show Swings Points', inline='swings', group='Real Time Swing Structure')
length               = input.int(50, '', minval=10, inline='swings', group='Real Time Swing Structure')
show_hl_swings       = input(true, 'Show Strong/Weak High/Low',   group='Real Time Swing Structure')

show_iob     = input(false, 'Internal Order Blocks', inline='iob', group='Order Blocks')
iob_showlast = input.int(5, '', minval=1, inline='iob', group='Order Blocks')
show_ob      = input(true,  'Swing Order Blocks',    inline='ob',  group='Order Blocks')
ob_showlast  = input.int(5, '', minval=1, inline='ob', group='Order Blocks')
ob_filter    = input.string('Atr', 'Order Block Filter', options=['Atr','Cumulative Mean Range'], group='Order Blocks')
ibull_ob_css = input.color(#ffdd0033, 'Internal Bullish OB', group='Order Blocks')
ibear_ob_css = input.color(#ffdd0033, 'Internal Bearish OB', group='Order Blocks')
bull_ob_css  = input.color(color.rgb(255,255,255,80), 'Bullish OB', group='Order Blocks')
bear_ob_css  = input.color(color.rgb(255,255,255,80), 'Bearish OB', group='Order Blocks')

show_eq      = input(false, 'Equal High/Low', group='EQH/EQL')
eq_len       = input.int(3, 'Bars Confirmation', minval=1, group='EQH/EQL')
eq_threshold = input.float(0.1, 'Threshold', minval=0, maxval=0.5, step=0.1, group='EQH/EQL')
eq_size      = input.string('Tiny', 'Label Size', options=['Tiny','Small','Normal'], group='EQH/EQL')

show_fvg     = input(true,  'Fair Value Gaps', group='Fair Value Gaps')
fvg_auto     = input(true,  'Auto Threshold',  group='Fair Value Gaps')
fvg_tf       = input.timeframe('', 'Timeframe', group='Fair Value Gaps')
bull_fvg_css = input.color(#ddff006f, 'Bullish FVG', group='Fair Value Gaps')
bear_fvg_css = input.color(#f2ff0060, 'Bearish FVG', group='Fair Value Gaps')
fvg_extend   = input.int(10, 'Extend FVG', minval=0, group='Fair Value Gaps')

show_pdhl  = input(false, 'Daily',   inline='daily',   group='Highs & Lows MTF')
pdhl_style = input.string('⎯⎯⎯', '', options=['⎯⎯⎯','----','····'], inline='daily',   group='Highs & Lows MTF')
pdhl_css   = input(#2157f3, '', inline='daily',   group='Highs & Lows MTF')
show_pwhl  = input(false, 'Weekly',  inline='weekly',  group='Highs & Lows MTF')
pwhl_style = input.string('⎯⎯⎯', '', options=['⎯⎯⎯','----','····'], inline='weekly',  group='Highs & Lows MTF')
pwhl_css   = input(#2157f3, '', inline='weekly',  group='Highs & Lows MTF')
show_pmhl  = input(false, 'Monthly', inline='monthly', group='Highs & Lows MTF')
pmhl_style = input.string('⎯⎯⎯', '', options=['⎯⎯⎯','----','····'], inline='monthly', group='Highs & Lows MTF')
pmhl_css   = input(#2157f3, '', inline='monthly', group='Highs & Lows MTF')

show_sd      = input(false, 'Premium/Discount Zones', group='Premium & Discount Zones')
premium_css  = input.color(#f23645, 'Premium Zone',     group='Premium & Discount Zones')
eq_css       = input.color(#b2b5be, 'Equilibrium Zone', group='Premium & Discount Zones')
discount_css = input.color(#089981, 'Discount Zone',    group='Premium & Discount Zones')

n           = bar_index
atr         = ta.atr(200)
cmean_range = ta.cum(high - low) / n

hl()       => [high, low]
get_ohlc() => [close[1], open[1], high, low, high[2], low[2]]

display_Structure(x, y, txt, css, dashed, down, lbl_size) =>
    structure_line = line.new(x, y, n, y, color=css, style=dashed ? line.style_dashed : line.style_solid)
    structure_lbl  = label.new(int(math.avg(x, n)), y, txt,
      color=TRANSP_CSS, textcolor=css,
      style=down ? label.style_label_down : label.style_label_up, size=lbl_size)
    if mode == 'Present'
        line.delete(structure_line[1])
        label.delete(structure_lbl[1])

swings(len) =>
    var int os = 0
    upper = ta.highest(len)
    lower = ta.lowest(len)
    os   := high[len] > upper ? 0 : low[len] < lower ? 1 : os[1]
    top   = os == 0 and os[1] != 0 ? high[len] : 0
    btm   = os == 1 and os[1] != 1 ? low[len]  : 0
    [top, btm]

ob_coord(use_max, loc, target_top, target_btm, target_left, target_type) =>
    float min_val    = 99999999.
    float max_val    = 0.
    int   idx        = 1
    ob_threshold     = ob_filter == 'Atr' ? atr : cmean_range
    if use_max
        for i = 1 to (n - loc) - 1
            if (high[i] - low[i]) < ob_threshold[i] * 2
                max_val := math.max(high[i], max_val)
                min_val := max_val == high[i] ? low[i]  : min_val
                idx     := max_val == high[i] ? i        : idx
    else
        for i = 1 to (n - loc) - 1
            if (high[i] - low[i]) < ob_threshold[i] * 2
                min_val := math.min(low[i], min_val)
                max_val := min_val == low[i]  ? high[i] : max_val
                idx     := min_val == low[i]  ? i        : idx
    array.unshift(target_top,  max_val)
    array.unshift(target_btm,  min_val)
    array.unshift(target_left, time[idx])
    array.unshift(target_type, use_max ? -1 : 1)

display_ob(boxes, target_top, target_btm, target_left, target_type, show_last, swing, sz) =>
    for i = 0 to math.min(show_last - 1, sz - 1)
        get_box = array.get(boxes, i)
        box.set_lefttop(get_box,     array.get(target_left, i), array.get(target_top, i))
        box.set_rightbottom(get_box, array.get(target_left, i), array.get(target_btm, i))
        box.set_extend(get_box, extend.right)
        color css = na
        if swing
            if style == 'Monochrome'
                css := array.get(target_type, i) == 1 ? color.new(#b2b5be,80) : color.new(#5d606b,80)
                box.set_border_color(get_box, array.get(target_type, i) == 1 ? #b2b5be : #5d606b)
            else
                css := array.get(target_type, i) == 1 ? bull_ob_css : bear_ob_css
                box.set_border_color(get_box, css)
            box.set_bgcolor(get_box, css)
        else
            if style == 'Monochrome'
                css := array.get(target_type, i) == 1 ? color.new(#b2b5be,80) : color.new(#5d606b,80)
            else
                css := array.get(target_type, i) == 1 ? ibull_ob_css : ibear_ob_css
            box.set_border_color(get_box, css)
            box.set_bgcolor(get_box, css)

get_line_style(s) =>
    switch s
        '⎯⎯⎯' => line.style_solid
        '----' => line.style_dashed
        => line.style_dotted

phl(h, l, tf, css) =>
    var line high_line = line.new(na,na,na,na, xloc=xloc.bar_time, color=css, style=get_line_style(pdhl_style))
    var label high_lbl = label.new(na,na, xloc=xloc.bar_time, text=str.format('P{0}H',tf), color=TRANSP_CSS, textcolor=css, size=size.small, style=label.style_label_left)
    var line low_line  = line.new(na,na,na,na, xloc=xloc.bar_time, color=css, style=get_line_style(pdhl_style))
    var label low_lbl  = label.new(na,na, xloc=xloc.bar_time, text=str.format('P{0}L',tf), color=TRANSP_CSS, textcolor=css, size=size.small, style=label.style_label_left)
    hy = ta.valuewhen(h != h[1], h, 1)
    hx = ta.valuewhen(h == high, time, 1)
    ly = ta.valuewhen(l != l[1], l, 1)
    lx = ta.valuewhen(l == low,  time, 1)
    if barstate.islast
        ext = time + (time - time[1]) * 20
        line.set_xy1(high_line, hx, hy)
        line.set_xy2(high_line, ext, hy)
        label.set_xy(high_lbl, ext, hy)
        line.set_xy1(low_line, lx, ly)
        line.set_xy2(low_line, ext, ly)
        label.set_xy(low_lbl, ext, ly)

var int   trend  = 0
var int   itrend = 0
var float top_y  = 0.
var int   top_x  = 0
var float btm_y  = 0.
var int   btm_x  = 0
var float itop_y = 0.
var int   itop_x = 0
var float ibtm_y = 0.
var int   ibtm_x = 0
var float trail_up   = high
var float trail_dn   = low
var int   trail_up_x = 0
var int   trail_dn_x = 0
var bool  top_cross  = true
var bool  btm_cross  = true
var bool  itop_cross = true
var bool  ibtm_cross = true
var string txt_top   = ''
var string txt_btm   = ''

bool bull_choch_alert  = false
bool bull_bos_alert    = false
bool bear_choch_alert  = false
bool bear_bos_alert    = false
bool bull_ichoch_alert = false
bool bull_ibos_alert   = false
bool bear_ichoch_alert = false
bool bear_ibos_alert   = false
bool bull_iob_break    = false
bool bear_iob_break    = false
bool bull_ob_break     = false
bool bear_ob_break     = false
bool eqh_alert         = false
bool eql_alert         = false

var color bull_css  = style == 'Monochrome' ? #b2b5be : swing_bull_css
var color bear_css  = style == 'Monochrome' ? #b2b5be : swing_bear_css
var color ibull_css = style == 'Monochrome' ? #b2b5be : swing_ibull_css
var color ibear_css = style == 'Monochrome' ? #b2b5be : swing_ibear_css

var string internal_structure_lbl_size = internal_structure_size == 'Tiny' ? size.tiny : internal_structure_size == 'Small' ? size.small : size.normal
var string swing_structure_lbl_size    = swing_structure_size    == 'Tiny' ? size.tiny : swing_structure_size    == 'Small' ? size.small : size.normal
var string eqhl_lbl_size               = eq_size                == 'Tiny' ? size.tiny : eq_size                == 'Small' ? size.small : size.normal

[top, btm]   = swings(length)
[itop, ibtm] = swings(5)

var line  extend_top     = na
var label extend_top_lbl = label.new(na,na, color=TRANSP_CSS, textcolor=bear_css, style=label.style_label_down, size=size.tiny)

if top != 0
    top_cross := true
    txt_top   := top > top_y ? 'HH' : 'LH'
    if show_swings
        top_lbl = label.new(n-length, top, txt_top, color=TRANSP_CSS, textcolor=bear_css, style=label.style_label_down, size=swing_structure_lbl_size)
        if mode == 'Present'
            label.delete(top_lbl[1])
    line.delete(extend_top[1])
    extend_top := line.new(n-length, top, n, top, color=bear_css)
    top_y      := top
    top_x      := n - length
    trail_up   := top
    trail_up_x := n - length

if itop != 0
    itop_cross := true
    itop_y     := itop
    itop_x     := n - 5

trail_up   := math.max(high, trail_up)
trail_up_x := trail_up == high ? n : trail_up_x

if barstate.islast and show_hl_swings
    line.set_xy1(extend_top, trail_up_x, trail_up)
    line.set_xy2(extend_top, n + 20,     trail_up)
    label.set_x(extend_top_lbl, n + 20)
    label.set_y(extend_top_lbl, trail_up)
    label.set_text(extend_top_lbl, trend < 0 ? 'Strong High' : 'Weak High')

var line  extend_btm     = na
var label extend_btm_lbl = label.new(na,na, color=TRANSP_CSS, textcolor=bull_css, style=label.style_label_up, size=size.tiny)

if btm != 0
    btm_cross := true
    txt_btm   := btm < btm_y ? 'LL' : 'HL'
    if show_swings
        btm_lbl = label.new(n-length, btm, txt_btm, color=TRANSP_CSS, textcolor=bull_css, style=label.style_label_up, size=swing_structure_lbl_size)
        if mode == 'Present'
            label.delete(btm_lbl[1])
    line.delete(extend_btm[1])
    extend_btm := line.new(n-length, btm, n, btm, color=bull_css)
    btm_y      := btm
    btm_x      := n - length
    trail_dn   := btm
    trail_dn_x := n - length

if ibtm != 0
    ibtm_cross := true
    ibtm_y     := ibtm
    ibtm_x     := n - 5

trail_dn   := math.min(low, trail_dn)
trail_dn_x := trail_dn == low ? n : trail_dn_x

if barstate.islast and show_hl_swings
    line.set_xy1(extend_btm, trail_dn_x, trail_dn)
    line.set_xy2(extend_btm, n + 20,     trail_dn)
    label.set_x(extend_btm_lbl, n + 20)
    label.set_y(extend_btm_lbl, trail_dn)
    label.set_text(extend_btm_lbl, trend > 0 ? 'Strong Low' : 'Weak Low')

var iob_top  = array.new_float(0)
var iob_btm  = array.new_float(0)
var iob_left = array.new_int(0)
var iob_type = array.new_int(0)
var ob_top   = array.new_float(0)
var ob_btm   = array.new_float(0)
var ob_left  = array.new_int(0)
var ob_type  = array.new_int(0)

var bool bull_concordant = true
var bool bear_concordant = true

if ifilter_confluence
    bull_concordant := high - math.max(close, open) > math.min(close, open - low)
    bear_concordant := high - math.max(close, open) < math.min(close, open - low)

if ta.crossover(close, itop_y) and itop_cross and top_y != itop_y and bull_concordant
    bool choch = bool(na)
    if itrend < 0
        choch := true
        bull_ichoch_alert := true
    else
        bull_ibos_alert := true
    txt = choch ? 'CHoCH' : 'BOS'
    if show_internals
        if show_ibull == 'All' or (show_ibull == 'BOS' and not choch) or (show_ibull == 'CHoCH' and choch)
            display_Structure(itop_x, itop_y, txt, ibull_css, true, true, internal_structure_lbl_size)
    itop_cross := false
    itrend     := 1
    if show_iob
        ob_coord(false, itop_x, iob_top, iob_btm, iob_left, iob_type)

if ta.crossover(close, top_y) and top_cross
    bool choch = bool(na)
    if trend < 0
        choch := true
        bull_choch_alert := true
    else
        bull_bos_alert := true
    txt = choch ? 'CHoCH' : 'BOS'
    if show_Structure
        if show_bull == 'All' or (show_bull == 'BOS' and not choch) or (show_bull == 'CHoCH' and choch)
            display_Structure(top_x, top_y, txt, bull_css, false, true, swing_structure_lbl_size)
    if show_ob
        ob_coord(false, top_x, ob_top, ob_btm, ob_left, ob_type)
    top_cross := false
    trend     := 1

if ta.crossunder(close, ibtm_y) and ibtm_cross and btm_y != ibtm_y and bear_concordant
    bool choch = false
    if itrend > 0
        choch := true
        bear_ichoch_alert := true
    else
        bear_ibos_alert := true
    txt = choch ? 'CHoCH' : 'BOS'
    if show_internals
        if show_ibear == 'All' or (show_ibear == 'BOS' and not choch) or (show_ibear == 'CHoCH' and choch)
            display_Structure(ibtm_x, ibtm_y, txt, ibear_css, true, false, internal_structure_lbl_size)
    ibtm_cross := false
    itrend     := -1
    if show_iob
        ob_coord(true, ibtm_x, iob_top, iob_btm, iob_left, iob_type)

if ta.crossunder(close, btm_y) and btm_cross
    bool choch = bool(na)
    if trend > 0
        choch := true
        bear_choch_alert := true
    else
        bear_bos_alert := true
    txt = choch ? 'CHoCH' : 'BOS'
    if show_Structure
        if show_bear == 'All' or (show_bear == 'BOS' and not choch) or (show_bear == 'CHoCH' and choch)
            display_Structure(btm_x, btm_y, txt, bear_css, false, false, swing_structure_lbl_size)
    if show_ob
        ob_coord(true, btm_x, ob_top, ob_btm, ob_left, ob_type)
    btm_cross := false
    trend     := -1

var iob_boxes = array.new_box(0)
var ob_boxes  = array.new_box(0)

for element in iob_type
    index = array.indexof(iob_type, element)
    if close < array.get(iob_btm, index) and element == 1
        array.remove(iob_top, index)
        array.remove(iob_btm, index)
        array.remove(iob_left, index)
        array.remove(iob_type, index)
        bull_iob_break := true
    else if close > array.get(iob_top, index) and element == -1
        array.remove(iob_top, index)
        array.remove(iob_btm, index)
        array.remove(iob_left, index)
        array.remove(iob_type, index)
        bear_iob_break := true

for element in ob_type
    index = array.indexof(ob_type, element)
    if close < array.get(ob_btm, index) and element == 1
        array.remove(ob_top, index)
        array.remove(ob_btm, index)
        array.remove(ob_left, index)
        array.remove(ob_type, index)
        bull_ob_break := true
    else if close > array.get(ob_top, index) and element == -1
        array.remove(ob_top, index)
        array.remove(ob_btm, index)
        array.remove(ob_left, index)
        array.remove(ob_type, index)
        bear_ob_break := true

iob_size = array.size(iob_type)
ob_size  = array.size(ob_type)

if barstate.isfirst
    if show_iob
        for i = 0 to iob_showlast - 1
            array.push(iob_boxes, box.new(na,na,na,na, xloc=xloc.bar_time))
    if show_ob
        for i = 0 to ob_showlast - 1
            array.push(ob_boxes, box.new(na,na,na,na, xloc=xloc.bar_time))

if iob_size > 0 and barstate.islast
    display_ob(iob_boxes, iob_top, iob_btm, iob_left, iob_type, iob_showlast, false, iob_size)
if ob_size  > 0 and barstate.islast
    display_ob(ob_boxes,  ob_top,  ob_btm,  ob_left,  ob_type,  ob_showlast,  true,  ob_size)

var float eq_prev_top = 0.
var int   eq_top_x    = 0
var float eq_prev_btm = 0.
var int   eq_btm_x    = 0

if show_eq
    eq_top = ta.pivothigh(eq_len, eq_len)
    eq_btm = ta.pivotlow(eq_len, eq_len)
    if not na(eq_top)
        mx = math.max(eq_top, eq_prev_top)
        mn = math.min(eq_top, eq_prev_top)
        if mx < mn + atr * eq_threshold
            eqh_line = line.new(eq_top_x, eq_prev_top, n-eq_len, eq_top, color=bear_css, style=line.style_dotted)
            eqh_lbl  = label.new(int(math.avg(n-eq_len, eq_top_x)), eq_top, 'EQH', color=#00000000, textcolor=bear_css, style=label.style_label_down, size=eqhl_lbl_size)
            if mode == 'Present'
                line.delete(eqh_line[1])
                label.delete(eqh_lbl[1])
            eqh_alert := true
        eq_prev_top := eq_top
        eq_top_x    := n - eq_len
    if not na(eq_btm)
        mx = math.max(eq_btm, eq_prev_btm)
        mn = math.min(eq_btm, eq_prev_btm)
        if mn > mx - atr * eq_threshold
            eql_line = line.new(eq_btm_x, eq_prev_btm, n-eq_len, eq_btm, color=bull_css, style=line.style_dotted)
            eql_lbl  = label.new(int(math.avg(n-eq_len, eq_btm_x)), eq_btm, 'EQL', color=#00000000, textcolor=bull_css, style=label.style_label_up, size=eqhl_lbl_size)
            eql_alert := true
            if mode == 'Present'
                line.delete(eql_line[1])
                label.delete(eql_lbl[1])
        eq_prev_btm := eq_btm
        eq_btm_x    := n - eq_len

var bullish_fvg_max = array.new_box(0)
var bullish_fvg_min = array.new_box(0)
var bearish_fvg_max = array.new_box(0)
var bearish_fvg_min = array.new_box(0)

bool bullish_fvg_cnd = false
bool bearish_fvg_cnd = false

[src_c1, src_o1, src_h, src_l, src_h2, src_l2] = request.security(syminfo.tickerid, fvg_tf, get_ohlc())

if show_fvg
    delta_per = (src_c1 - src_o1) / src_o1 * 100
    change_tf = timeframe.change(fvg_tf)
    threshold = fvg_auto ? ta.cum(math.abs(change_tf ? delta_per : 0)) / n * 2 : 0
    bullish_fvg_cnd := src_l > src_h2 and src_c1 > src_h2 and delta_per  >  threshold and change_tf
    bearish_fvg_cnd := src_h < src_l2 and src_c1 < src_l2 and -delta_per >  threshold and change_tf
    if bullish_fvg_cnd
        array.unshift(bullish_fvg_max, box.new(n-1, src_l,              n+fvg_extend, math.avg(src_l,src_h2), border_color=bull_fvg_css, bgcolor=bull_fvg_css))
        array.unshift(bullish_fvg_min, box.new(n-1, math.avg(src_l,src_h2), n+fvg_extend, src_h2,            border_color=bull_fvg_css, bgcolor=bull_fvg_css))
    if bearish_fvg_cnd
        array.unshift(bearish_fvg_max, box.new(n-1, src_h,              n+fvg_extend, math.avg(src_h,src_l2), border_color=bear_fvg_css, bgcolor=bear_fvg_css))
        array.unshift(bearish_fvg_min, box.new(n-1, math.avg(src_h,src_l2), n+fvg_extend, src_l2,            border_color=bear_fvg_css, bgcolor=bear_fvg_css))
    for bx in bullish_fvg_min
        if low < box.get_bottom(bx)
            box.delete(bx)
            box.delete(array.get(bullish_fvg_max, array.indexof(bullish_fvg_min, bx)))
    for bx in bearish_fvg_max
        if high > box.get_top(bx)
            box.delete(bx)
            box.delete(array.get(bearish_fvg_min, array.indexof(bearish_fvg_max, bx)))

[pdh, pdl] = request.security(syminfo.tickerid, 'D', hl(), lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, 'W', hl(), lookahead=barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, 'M', hl(), lookahead=barmerge.lookahead_on)

if show_pdhl
    phl(pdh, pdl, 'D', pdhl_css)
if show_pwhl
    phl(pwh, pwl, 'W', pwhl_css)
if show_pmhl
    phl(pmh, pml, 'M', pmhl_css)

var box   premium      = box.new(na,na,na,na, bgcolor=color.new(premium_css,80),  border_color=na)
var label premium_lbl  = label.new(na,na, text='Premium',     color=TRANSP_CSS, textcolor=premium_css,  style=label.style_label_down, size=size.small)
var box   eq_box       = box.new(na,na,na,na, bgcolor=color.rgb(120,123,134,80), border_color=na)
var label eq_lbl       = label.new(na,na, text='Equilibrium', color=TRANSP_CSS, textcolor=eq_css,       style=label.style_label_left, size=size.small)
var box   discount     = box.new(na,na,na,na, bgcolor=color.new(discount_css,80), border_color=na)
var label discount_lbl = label.new(na,na, text='Discount',   color=TRANSP_CSS, textcolor=discount_css, style=label.style_label_up,   size=size.small)

if barstate.islast and show_sd
    avg = math.avg(trail_up, trail_dn)
    box.set_lefttop(premium,  math.max(top_x,btm_x), trail_up)
    box.set_rightbottom(premium, n, .95*trail_up+.05*trail_dn)
    label.set_xy(premium_lbl, int(math.avg(math.max(top_x,btm_x),n)), trail_up)
    box.set_lefttop(eq_box,   math.max(top_x,btm_x), .525*trail_up+.475*trail_dn)
    box.set_rightbottom(eq_box, n, .525*trail_dn+.475*trail_up)
    label.set_xy(eq_lbl, n, avg)
    box.set_lefttop(discount, math.max(top_x,btm_x), .95*trail_dn+.05*trail_up)
    box.set_rightbottom(discount, n, trail_dn)
    label.set_xy(discount_lbl, int(math.avg(math.max(top_x,btm_x),n)), trail_dn)

var color trend_css = na
if show_trend
    trend_css := style == 'Colored' ? (itrend==1 ? bull_css : bear_css) : itrend==1 ? #b2b5be : #5d606b
plotcandle(open,high,low,close, color=trend_css, wickcolor=trend_css, bordercolor=trend_css, editable=false)

// ═══════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════
alertcondition(valid_bull,            'BUY Signal',          'BUY — Session + H4 Bull + ADX OK')
alertcondition(valid_bear,            'SELL Signal',         'SELL — Session + H4 Bear + ADX OK')
alertcondition(weak_bull,             'BUY Weak',            'BUY — Weak setup')
alertcondition(weak_bear,             'SELL Weak',           'SELL — Weak setup')
alertcondition(retest_bull,           'BUY Retest Entry',    '🎯 BUY — OB Retest confirmed, Structure SL set')
alertcondition(retest_bear,           'SELL Retest Entry',   '🎯 SELL — OB Retest confirmed, Structure SL set')
alertcondition(retest_expired or retest_invalidated, 'Retest Cancelled', '⚠️ Retest zone expired or invalidated')
alertcondition(bear_div,              'Bearish RSI Divergence', '⚠️ Bearish RSI Divergence detected')
alertcondition(bull_div,              'Bullish RSI Divergence', '⚠️ Bullish RSI Divergence detected')
alertcondition(bull_ichoch_alert,     'Internal Bull CHoCH', 'Internal Bullish CHoCH formed')
alertcondition(bear_ichoch_alert,     'Internal Bear CHoCH', 'Internal Bearish CHoCH formed')
alertcondition(bull_bos_alert,        'Bullish BOS',         'Bullish BOS formed')
alertcondition(bear_bos_alert,        'Bearish BOS',         'Bearish BOS formed')
alertcondition(bull_choch_alert,      'Bullish CHoCH',       'Bullish CHoCH formed')
alertcondition(bear_choch_alert,      'Bearish CHoCH',       'Bearish CHoCH formed')
alertcondition(bullish_fvg_cnd,       'Bullish FVG',         'Bullish FVG formed')
alertcondition(bearish_fvg_cnd,       'Bearish FVG',         'Bearish FVG formed')
alertcondition(eqh_alert,             'Equal Highs',         'Equal highs detected')
alertcondition(eql_alert,             'Equal Lows',          'Equal lows detected')
````
