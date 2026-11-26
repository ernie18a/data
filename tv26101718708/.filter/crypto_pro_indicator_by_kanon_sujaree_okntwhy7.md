# Crypto Pro Indicator by Kanon Sujaree

- url: https://www.tradingview.com/script/OKNTWHy7/
- type: indicator
- pine_id: PUB;58f87690a12c47268930994b84d0d588
- version: 1.0

## Description

Built for serious crypto traders who don't have time to read noise. This script runs a weighted confidence engine across seven indicators simultaneously — VWAP, Multi-Timeframe RSI, MACD, Smart Money Structure, Volume, RSI Divergence, and EMA50 Trend — and only fires a signal when confidence clears 70%.
        No cluttered labels. No guesswork. Just a single arrow pointing at the exact candle to buy or sell, with a confidence percentage so you know exactly how strong the setup is.
Designed and tuned specifically for BTC, ETH, XRP, SOL, and BNB.
Best on 15m · 1H · 4H timeframes.

## Source Code

````pine
// ============================================================
// CRYPTO PRO INDICATOR — BTC ETH XRP SOL BNB
// Weighted Confidence System — แสดงสัญญาณเมื่อ >= 70%
//
// MAJOR (20% each):  VWAP · RSI Multi-TF · MACD
// TREND  (10%):      ADX  ← กรอง Sideways อัตโนมัติ
// MINOR  (10% each): BOS/CHoCH · EMA50 · Volume · Divergence
// Total possible = 100% | Default Threshold = 70%
// ============================================================
//@version=6
indicator("Crypto Pro Indicator [BTC ETH XRP SOL BNB]", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================
grp1 = "═══ VWAP ═══"
show_vwap       = input.bool(true,    "แสดง VWAP",            group=grp1)
show_vwap_bands = input.bool(true,    "แสดง VWAP Bands",      group=grp1)
vwap_mult       = input.float(2.0,    "Band Multiplier",       group=grp1, step=0.1)

grp2 = "═══ RSI ═══"
rsi_len         = input.int(14,       "RSI Length",            group=grp2)
rsi_ob          = input.int(70,       "Overbought",            group=grp2)
rsi_os          = input.int(30,       "Oversold",              group=grp2)
rsi_tf          = input.timeframe("240", "Higher TF",          group=grp2)

grp3 = "═══ MACD (Crypto-tuned) ═══"
macd_fast       = input.int(5,        "Fast",                  group=grp3)
macd_slow       = input.int(13,       "Slow",                  group=grp3)
macd_sig        = input.int(4,        "Signal",                group=grp3)

grp4 = "═══ ADX (Trend Strength) ═══"
adx_len         = input.int(14,       "ADX Length",            group=grp4)
adx_smooth      = input.int(14,       "ADX Smooth",            group=grp4)
adx_strong      = input.int(40,       "ADX Strong Trend",      group=grp4)
adx_trend       = input.int(25,       "ADX Trend",             group=grp4)
adx_weak        = input.int(20,       "ADX Weak (Sideways <)", group=grp4)

grp5 = "═══ Structure ═══"
struct_len      = input.int(10,       "Swing Length",          group=grp5)

grp6 = "═══ EMA Trend ═══"
ema_len         = input.int(50,       "EMA Length",            group=grp6)
show_ema        = input.bool(true,    "แสดง EMA",             group=grp6)

grp7 = "═══ Signals ═══"
show_buy        = input.bool(true,    "แสดงป้าย BUY",         group=grp7)
show_sell       = input.bool(true,    "แสดงป้าย SELL",        group=grp7)
conf_threshold  = input.int(70,       "Confidence ขั้นต่ำ %",  group=grp7, minval=50, maxval=100)

// ============================================================
// MAJOR #1 — VWAP + BANDS (20%)
// ============================================================
[vwap_val, _ub, _lb] = ta.vwap(hlc3, true, 1)
vwap_upper = vwap_val + vwap_mult * ta.stdev(hlc3 - vwap_val, 20)
vwap_lower = vwap_val - vwap_mult * ta.stdev(hlc3 - vwap_val, 20)

plot(show_vwap ? vwap_val   : na, "VWAP",       color=color.new(#00BCD4, 0), linewidth=2)
pu = plot(show_vwap_bands ? vwap_upper : na, "VWAP Upper", color=color.new(#FF5722, 50), linewidth=1)
pl = plot(show_vwap_bands ? vwap_lower : na, "VWAP Lower", color=color.new(#4CAF50, 50), linewidth=1)
fill(pu, pl, color=color.new(#00BCD4, 92))

price_above_vwap = close > vwap_val
price_below_vwap = close < vwap_val
near_lower_band  = low  <= vwap_lower * 1.003
near_upper_band  = high >= vwap_upper * 0.997

vwap_buy_score  = near_lower_band and price_above_vwap ? 20 : price_above_vwap ? 10 : 0
vwap_sell_score = near_upper_band and price_below_vwap ? 20 : price_below_vwap ? 10 : 0

// ============================================================
// MAJOR #2 — MULTI-TF RSI (20%)
// ============================================================
rsi_cur  = ta.rsi(close, rsi_len)
rsi_htf  = request.security(syminfo.tickerid, rsi_tf, ta.rsi(close, rsi_len), lookahead=barmerge.lookahead_off)

htf_bull     = rsi_htf > 50
htf_bear     = rsi_htf < 50
rsi_os_sig   = rsi_cur < rsi_os
rsi_ob_sig   = rsi_cur > rsi_ob
rsi_mid_bull = rsi_cur > 50 and rsi_cur < rsi_ob
rsi_mid_bear = rsi_cur < 50 and rsi_cur > rsi_os

rsi_buy_score  = rsi_os_sig  and htf_bull ? 20 : rsi_mid_bull and htf_bull ? 10 : 0
rsi_sell_score = rsi_ob_sig  and htf_bear ? 20 : rsi_mid_bear and htf_bear ? 10 : 0

// ============================================================
// MAJOR #3 — MACD Crypto-tuned 5/13/4 (20%)
// ============================================================
[macd_line, sig_line, hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)

macd_cross_up   = ta.crossover(macd_line,  sig_line)
macd_cross_down = ta.crossunder(macd_line, sig_line)
macd_bull       = macd_line > sig_line
macd_bear       = macd_line < sig_line
hist_up         = hist > hist[1] and hist > 0
hist_down       = hist < hist[1] and hist < 0

macd_buy_score  = macd_cross_up   ? 20 : macd_bull and hist_up   ? 10 : 0
macd_sell_score = macd_cross_down ? 20 : macd_bear and hist_down ? 10 : 0

// ============================================================
// TREND FILTER - ADX
// >= 35 = Strong Trend  30%
// >= 30 = Trend         20%
// >= 25 = Weak Trend    10%
// <  25 = Sideways       0%
// ============================================================
[diplus, diminus, adx_val] = ta.dmi(adx_len, adx_smooth)

adx_score = adx_val >= 35 ? 30 : adx_val >= 30 ? 20 : adx_val >= 25 ? 10 : 0

di_bull = diplus  > diminus
di_bear = diminus > diplus

adx_buy_score  = di_bull ? adx_score : math.round(adx_score / 2)
adx_sell_score = di_bear ? adx_score : math.round(adx_score / 2)

// แสดง ADX บน chart แบบ background อ่อนๆ
bgcolor(adx_val < adx_weak ? color.new(#607D8B, 97) : na, title="Sideways Zone")

// ============================================================
// MINOR #1 — BOS / CHoCH (10%)
// ============================================================
swing_high = ta.pivothigh(high, struct_len, struct_len)
swing_low  = ta.pivotlow(low,  struct_len, struct_len)

var float last_sh  = na
var float last_sl  = na
var bool  prev_bull = true

if not na(swing_high)
    last_sh := swing_high
if not na(swing_low)
    last_sl := swing_low

cross_up   = ta.crossover(close,  last_sh)
cross_down = ta.crossunder(close, last_sl)
bos_bull   = not na(last_sh) and cross_up
bos_bear   = not na(last_sl) and cross_down
choch_bull = not prev_bull and bos_bull
choch_bear = prev_bull     and bos_bear

if bos_bull
    prev_bull := true
if bos_bear
    prev_bull := false

struct_buy_score  = (bos_bull or choch_bull) ? 10 : prev_bull      ? 5 : 0
struct_sell_score = (bos_bear or choch_bear) ? 10 : not prev_bull  ? 5 : 0

// ============================================================
// MINOR #2 — EMA50 TREND (10%)
// ============================================================
ema50 = ta.ema(close, ema_len)
plot(show_ema ? ema50 : na, "EMA50", color=color.new(#FFD700, 30), linewidth=1)

above_ema      = close > ema50
below_ema      = close < ema50
ema_slope_up   = ema50 > ema50[3]
ema_slope_down = ema50 < ema50[3]

ema_buy_score  = above_ema and ema_slope_up   ? 10 : above_ema ? 5 : 0
ema_sell_score = below_ema and ema_slope_down ? 10 : below_ema ? 5 : 0

// ============================================================
// MINOR #3 — VOLUME (10%)
// ============================================================
vol_sma    = ta.sma(volume, 20)
high_vol   = volume > vol_sma * 1.5
normal_vol = volume >= vol_sma * 0.8 and volume <= vol_sma * 1.5
bull_candle = close > open
bear_candle = close < open

vol_buy_score  = high_vol and bull_candle   ? 10 : normal_vol and bull_candle ? 5 : 0
vol_sell_score = high_vol and bear_candle   ? 10 : normal_vol and bear_candle ? 5 : 0

// ============================================================
// MINOR #4 — RSI DIVERGENCE (10%)
// ============================================================
price_ll = low  < ta.lowest(low,  5)[1]
price_hh = high > ta.highest(high, 5)[1]
rsi_hl   = rsi_cur > ta.lowest(rsi_cur,  5)[1]
rsi_lh   = rsi_cur < ta.highest(rsi_cur, 5)[1]

bull_div = price_ll and rsi_hl and rsi_cur < 45
bear_div = price_hh and rsi_lh and rsi_cur > 55

div_buy_score  = bull_div ? 10 : 0
div_sell_score = bear_div ? 10 : 0

// ============================================================
// TOTAL CONFIDENCE (0-100%)
// ============================================================
buy_conf  = math.round(vwap_buy_score  + rsi_buy_score  + macd_buy_score  + adx_buy_score  + struct_buy_score  + ema_buy_score  + vol_buy_score  + div_buy_score)
sell_conf = math.round(vwap_sell_score + rsi_sell_score + macd_sell_score + adx_sell_score + struct_sell_score + ema_sell_score + vol_sell_score + div_sell_score)

// ============================================================
// BUY / SELL - BUY then SELL then BUY only
// ============================================================
var string last_sig = "none"

buy_trigger  = buy_conf  >= conf_threshold and not (buy_conf[1]  >= conf_threshold)
sell_trigger = sell_conf >= conf_threshold and not (sell_conf[1] >= conf_threshold)

buy_signal  = buy_trigger  and last_sig != "buy"
sell_signal = sell_trigger and last_sig == "buy"

if buy_signal
    last_sig := "buy"
if sell_signal
    last_sig := "sell"

buy_color(c) =>
    c >= 90 ? color.new(#00E676, 0) : c >= 80 ? color.new(#00C853, 0) : color.new(#69F0AE, 0)

if show_buy and buy_signal
    label.new(bar_index, low * 0.9975, "▲ BUY\n" + str.tostring(buy_conf) + "%",
      style=label.style_label_up, color=buy_color(buy_conf), textcolor=color.black, size=size.normal)
    line.new(bar_index, low * 0.9975, bar_index, low,
      color=buy_color(buy_conf), width=2, style=line.style_dotted)

if show_sell and sell_signal
    label.new(bar_index, high * 1.0025, "▼ SELL\n" + str.tostring(sell_conf) + "%",
      style=label.style_label_down, color=color.new(#D50000, 0), textcolor=color.white, size=size.normal)
    line.new(bar_index, high * 1.0025, bar_index, high,
      color=color.new(#D50000, 0), width=2, style=line.style_dotted)

bgcolor(buy_conf  >= conf_threshold ? color.new(#00C853, 96) : na, title="BUY Zone")
bgcolor(sell_conf >= conf_threshold ? color.new(#D50000, 96) : na, title="SELL Zone")

// ============================================================
// ALERTS
// ============================================================
alertcondition(buy_signal,  "BUY Signal",  "Crypto Pro: BUY Signal triggered")
alertcondition(sell_signal, "SELL Signal", "Crypto Pro: SELL Signal triggered")

// ============================================================
// INFO TABLE
// ============================================================
adx_status = adx_val >= 35 ? "Strong 🔥 30%" : adx_val >= 30 ? "Trend ✅ 20%" : adx_val >= 25 ? "Weak ⚠️ 10%" : "Sideways ❌ 0%"
adx_clr    = adx_val >= 35 ? color.lime : adx_val >= 30 ? color.yellow : adx_val >= 25 ? color.orange : color.red

var table t = table.new(position.top_right, 2, 10,
  bgcolor=color.new(#1a1a2e, 10), border_color=color.new(#00BCD4, 50),
  border_width=1, frame_color=color.new(#00BCD4, 30), frame_width=1)

sc(v, w) => str.tostring(v) + "/" + str.tostring(w)

table.cell(t,0,0,"INDICATOR",        text_color=color.new(#00BCD4,0), text_size=size.small, bgcolor=color.new(#0d0d1a,0))
table.cell(t,1,0,"SCORE",            text_color=color.new(#00BCD4,0), text_size=size.small, bgcolor=color.new(#0d0d1a,0))

table.cell(t,0,1,"VWAP  (20%)",      text_color=color.white,  text_size=size.small)
table.cell(t,1,1, sc(math.max(vwap_buy_score,   vwap_sell_score),   20), text_color=color.yellow, text_size=size.small)

table.cell(t,0,2,"RSI   (20%)",      text_color=color.white,  text_size=size.small)
table.cell(t,1,2, sc(math.max(rsi_buy_score,    rsi_sell_score),    20), text_color=color.yellow, text_size=size.small)

table.cell(t,0,3,"MACD  (20%)",      text_color=color.white,  text_size=size.small)
table.cell(t,1,3, sc(math.max(macd_buy_score,   macd_sell_score),   20), text_color=color.yellow, text_size=size.small)

table.cell(t,0,4,"ADX   (10%)",      text_color=color.white,  text_size=size.small)
table.cell(t,1,4, adx_status + " " + str.tostring(math.round(adx_val, 1)), text_color=adx_clr, text_size=size.small)

table.cell(t,0,5,"BOS/CHoCH (10%)", text_color=color.white,  text_size=size.small)
table.cell(t,1,5, sc(math.max(struct_buy_score, struct_sell_score), 10), text_color=color.yellow, text_size=size.small)

table.cell(t,0,6,"EMA50 (10%)",      text_color=color.white,  text_size=size.small)
table.cell(t,1,6, sc(math.max(ema_buy_score,    ema_sell_score),    10), text_color=color.yellow, text_size=size.small)

table.cell(t,0,7,"Volume (10%)",     text_color=color.white,  text_size=size.small)
table.cell(t,1,7, sc(math.max(vol_buy_score,    vol_sell_score),    10), text_color=color.yellow, text_size=size.small)

table.cell(t,0,8,"Divergence (10%)", text_color=color.white,  text_size=size.small)
table.cell(t,1,8, sc(math.max(div_buy_score,    div_sell_score),    10), text_color=color.yellow, text_size=size.small)

conf_val  = math.max(buy_conf, sell_conf)
conf_side = buy_conf >= sell_conf ? "BUY " : "SELL "
conf_disp = conf_val >= conf_threshold ? conf_side + str.tostring(conf_val) + "%" : "WAIT " + str.tostring(conf_val) + "%"
conf_clr  = conf_val >= conf_threshold ? (buy_conf >= sell_conf ? color.lime : color.red) : color.gray

table.cell(t,0,9,"CONFIDENCE",       text_color=color.white,  text_size=size.small, bgcolor=color.new(#0d0d1a,0))
table.cell(t,1,9, conf_disp,         text_color=conf_clr,     text_size=size.small, bgcolor=color.new(#0d0d1a,0))

//@version=6
plot(close)
````
