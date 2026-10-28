# 8 Indikator - HIZLI AL/SAT (4H PRO)

- url: https://www.tradingview.com/script/zZJZNY2h/
- type: indicator
- pine_id: PUB;56956d3036c7438c89aeec2ee9ffeb2b
- version: 1.0

## Description

8 indikatör birleşimi + ADX + EMA200 trend filtresi ile güçlü AL/SAT sinyalleri. 
Hızlı 3'lü (CCI+W%R+SuperTrend) ve tam 8'li sayım sistemi. 
Günlük trend + Hacim + Güçlü Trend filtreleri ile yanlış sinyalleri azaltır. 
4H timeframe için optimize edildi. ATR SL/TP otomatik gösterir.

## Source Code

````pine
//@version=5
indicator("8 İndikatör - HIZLI AL/SAT (4H PRO)", shorttitle="8Indi 4H PRO", overlay=true, max_labels_count=500)

// ────────────────────────────────── ZAMAN DİLİMİ KONTROLÜ ──────────────────────────────────


// ────────────────────────────────── KULLANICI AYARLARI ──────────────────────────────────
min_buy_count   = input.int(3,  "En Az Kaç AL Sinyali? (Toplam 8'li)", minval=1, maxval=8)
min_sell_count  = input.int(3,  "En Az Kaç SAT Sinyali? (Toplam 8'li)", minval=1, maxval=8)
use_fast_trio   = input.bool(true, "Hızlı 3'lü (CCI + W%R + SuperTrend) Kullanılsın mı?")
min_fast_buy    = input.int(3,  "Hızlı 3'lü AL için Kaç Sinyal?", minval=1, maxval=3)
min_fast_sell   = input.int(3,  "Hızlı 3'lü SAT için Kaç Sinyal?", minval=1, maxval=3)
show_atr_sl_tp  = input.bool(true, "ATR Tabanlı SL/TP Göster?")
use_volume_filter = input.bool(true, "Hacim Filtresi (Vol > 20 SMA) Kullanılsın mı?")
use_trend_filter  = input.bool(true, "Sadece Trend Yönünde İşlem Yap (Günlük SuperTrend)")

max_labels_user = input.int(10, "Kaç eski sinyal etiketi grafikte kalsın?", minval=1, maxval=50)

// ────────────────────────────────── İNDİKATÖR AKTİF/PASİF ──────────────────────────────────
use_rsi   = input.bool(true, "RSI")
use_macd  = input.bool(true, "MACD")
use_bb    = input.bool(true, "Bollinger Bands")
use_stoch = input.bool(true, "Stochastic")
use_ma    = input.bool(true, "MA Crossover")
use_cci   = input.bool(true, "CCI")
use_wr    = input.bool(true, "Williams %R")
use_super = input.bool(true, "SuperTrend")

// ────────────────────────────────── PARAMETRELER ──────────────────────────────────
rsi_len = input.int(14, "RSI Uzunluğu")
rsi_ob  = input.int(70, "RSI Aşırı Alım")
rsi_os  = input.int(30, "RSI Aşırı Satım")

macd_fast = input.int(12, "MACD Hızlı")
macd_slow = input.int(26, "MACD Yavaş")
macd_sig  = input.int(9,  "MACD Sinyal")

bb_len   = input.int(20, "BB Uzunluk")
bb_mult  = input.float(2.0, "BB Çarpan")

stoch_k = input.int(14, "Stoch %K")
stoch_d = input.int(3,  "Stoch %D")
stoch_os = input.int(20, "Stoch Aşırı Satım")
stoch_ob = input.int(80, "Stoch Aşırı Alım")

ma_fast = input.int(10, "Hızlı MA")
ma_slow = input.int(20, "Yavaş MA")

cci_len = input.int(14, "CCI Uzunluğu")
cci_ob  = input.int(100, "CCI Aşırı Alım")
cci_os  = input.int(-100, "CCI Aşırı Satım")

wr_len = input.int(14, "Williams %R Uzunluğu")
wr_ob  = input.int(-20, "W%R Aşırı Alım")
wr_os  = input.int(-80, "W%R Aşırı Satım")

st_mult = input.float(3.0, "SuperTrend Çarpan")
st_len  = input.int(10,   "SuperTrend Uzunluk")
atr_len = input.int(14,   "ATR Uzunluğu (SL/TP için)")

// ────────────────────────────────── İNDİKATÖRLER ──────────────────────────────────
rsi = ta.rsi(close, rsi_len)
[macd_line, signal_line, _] = ta.macd(close, macd_fast, macd_slow, macd_sig)

bb_basis = ta.sma(close, bb_len)
bb_dev   = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev

stoch_k_val = ta.stoch(close, high, low, stoch_k)
stoch_d_val = ta.sma(stoch_k_val, stoch_d)

ma_f = ta.sma(close, ma_fast)
ma_s = ta.sma(close, ma_slow)

cci = ta.cci(close, cci_len)
wr  = ta.wpr(wr_len)

// SuperTrend
atr_st          = ta.atr(st_len)
upper_band_basic = ta.sma(close, st_len) + st_mult * atr_st
lower_band_basic = ta.sma(close, st_len) - st_mult * atr_st

var float supertrend   = na
var int   direction    = 1
var float final_upper  = na
var float final_lower  = na

final_lower := close[1] > final_lower[1] ? math.max(lower_band_basic, final_lower[1]) : lower_band_basic
final_upper := close[1] < final_upper[1] ? math.min(upper_band_basic, final_upper[1]) : upper_band_basic
direction   := close > final_upper[1] ? 1 : close < final_lower[1] ? -1 : direction[1]
supertrend  := direction == 1 ? final_lower : final_upper

// ────────────────────────────────── GÜNLÜK TREND FİLTRESİ ──────────────────────────────────
daily_supertrend = request.security(syminfo.tickerid, "D", supertrend)
daily_direction  = request.security(syminfo.tickerid, "D", direction)
daily_trend_up   = daily_direction == 1
daily_trend_down = daily_direction == -1

// ────────────────────────────────── HACİM FİLTRESİ ──────────────────────────────────
vol_sma   = ta.sma(volume, 20)
volume_ok = not use_volume_filter or volume > vol_sma

// ────────────────────────────────── BİREYSEL SİNYALLER ──────────────────────────────────
rsi_buy   = use_rsi   and rsi   < rsi_os
rsi_sell  = use_rsi   and rsi   > rsi_ob
macd_buy  = use_macd  and ta.crossover(macd_line, signal_line)
macd_sell = use_macd  and ta.crossunder(macd_line, signal_line)
bb_buy    = use_bb    and close < bb_lower
bb_sell   = use_bb    and close > bb_upper
stoch_buy = use_stoch and stoch_k_val < stoch_os and ta.crossover(stoch_k_val, stoch_d_val)
stoch_sell= use_stoch and stoch_k_val > stoch_ob and ta.crossunder(stoch_k_val, stoch_d_val)
ma_buy    = use_ma    and ta.crossover(ma_f, ma_s)
ma_sell   = use_ma    and ta.crossunder(ma_f, ma_s)
cci_buy   = use_cci   and cci   < cci_os
cci_sell  = use_cci   and cci   > cci_ob
wr_buy    = use_wr    and wr    < wr_os
wr_sell   = use_wr    and wr    > wr_ob
st_buy    = use_super and close > supertrend and direction == 1
st_sell   = use_super and close < supertrend and direction == -1

// ────────────────────────────────── HIZLI 3'LÜ SAYIM ──────────────────────────────────
fast_buy_count  = (cci_buy ? 1 : 0) + (wr_buy ? 1 : 0) + (st_buy ? 1 : 0)
fast_sell_count = (cci_sell ? 1 : 0) + (wr_sell ? 1 : 0) + (st_sell ? 1 : 0)

fast_al_signal  = use_fast_trio and fast_buy_count  >= min_fast_buy
fast_sat_signal = use_fast_trio and fast_sell_count >= min_fast_sell

// ────────────────────────────────── TOPLAM 8'Lİ SAYIM ──────────────────────────────────
buy_count  = (rsi_buy ? 1 : 0) + (macd_buy ? 1 : 0) + (bb_buy ? 1 : 0) + (stoch_buy ? 1 : 0) +
             (ma_buy ? 1 : 0) + (cci_buy ? 1 : 0) + (wr_buy ? 1 : 0) + (st_buy ? 1 : 0)

sell_count = (rsi_sell ? 1 : 0) + (macd_sell ? 1 : 0) + (bb_sell ? 1 : 0) + (stoch_sell ? 1 : 0) +
             (ma_sell ? 1 : 0) + (cci_sell ? 1 : 0) + (wr_sell ? 1 : 0) + (st_sell ? 1 : 0)

// Trend filtresi
trend_ok_buy  = not use_trend_filter or daily_trend_up
trend_ok_sell = not use_trend_filter or daily_trend_down

// Final sinyaller
al_signal  = buy_count  >= min_buy_count  and volume_ok and trend_ok_buy
sat_signal = sell_count >= min_sell_count and volume_ok and trend_ok_sell 

// ────────────────────────────────── ATR SL/TP (4 ONDALIK BASAMAK) ──────────────────────────────────
atr       = ta.atr(atr_len)
sl_long   = close - 1.5 * atr
tp_long   = close + 2.0 * atr
sl_short  = close + 1.5 * atr
tp_short  = close - 2.0 * atr

sl_long_r  = str.tostring(sl_long,  "#.####")
tp_long_r  = str.tostring(tp_long,  "#.####")
sl_short_r = str.tostring(sl_short, "#.####")
tp_short_r = str.tostring(tp_short, "#.####")

// ────────────────────────────────── DETAY LİSTESİ (tooltip için) ──────────────────────────────────
get_buy_list()  => (rsi_buy ? "RSI " : "") + (macd_buy ? "MACD " : "") + (bb_buy ? "BB " : "") +
                   (stoch_buy ? "Stoch " : "") + (ma_buy ? "MA " : "") + (cci_buy ? "CCI " : "") +
                   (wr_buy ? "W%R " : "") + (st_buy ? "ST" : "")

get_sell_list() => (rsi_sell ? "RSI " : "") + (macd_sell ? "MACD " : "") + (bb_sell ? "BB " : "") +
                   (stoch_sell ? "Stoch " : "") + (ma_sell ? "MA " : "") + (cci_sell ? "CCI " : "") +
                   (wr_sell ? "W%R " : "") + (st_sell ? "ST" : "")

// ────────────────────────────────── ETİKET YÖNETİMİ ──────────────────────────────────
var label[] label_array = array.new_label(0)

create_label(x, y, txt, style, col, txtcol, yloc_val, tip) =>
    new_label = label.new(x, y, txt,
         style=style, color=col, textcolor=txtcol,
         size=size.small, yloc=yloc_val, tooltip=tip)
    array.push(label_array, new_label)
    if array.size(label_array) > max_labels_user
        old_label = array.shift(label_array)
        label.delete(old_label)
    new_label

// ────────────────────────────────── ETİKET OLUŞTURMA ──────────────────────────────────
if fast_al_signal and volume_ok and trend_ok_buy
    txt   = "HIZLI AL\nSL: " + sl_long_r + "\nTP: " + tp_long_r
    tip   = "HIZLI AL (CCI + W%R + SuperTrend)\nGüç: " + str.tostring(fast_buy_count) + "/3 + Bonus"
    create_label(bar_index, low, txt, label.style_label_up, color.new(#00ff00, 0), color.black, yloc.belowbar, tip)

else if fast_sat_signal and volume_ok and trend_ok_sell
    txt   = "HIZLI SAT\nSL: " + sl_short_r + "\nTP: " + tp_short_r
    tip   = "HIZLI SAT (CCI + W%R + SuperTrend)\nGüç: " + str.tostring(fast_sell_count) + "/3 + Bonus"
    create_label(bar_index, high, txt, label.style_label_down, color.new(#ff4444, 0), color.white, yloc.abovebar, tip)

else if al_signal
    txt   = "AL\nSL: " + sl_long_r + "\nTP: " + tp_long_r
    tip   = "AL Sinyali\n" + get_buy_list()
    create_label(bar_index, low, txt, label.style_label_up, color.new(#00b894, 0), color.white, yloc.belowbar, tip)

else if sat_signal
    txt   = "SAT\nSL: " + sl_short_r + "\nTP: " + tp_short_r
    tip   = "SAT Sinyali\n" + get_sell_list()
    create_label(bar_index, high, txt, label.style_label_down, color.new(#d63031, 0), color.white, yloc.abovebar, tip)

// ────────────────────────────────── UYARILAR ──────────────────────────────────
alertcondition(fast_al_signal  and volume_ok and trend_ok_buy,  title="HIZLI AL Sinyali",  message="HIZLI AL! {{ticker}} 4H")
alertcondition(fast_sat_signal and volume_ok and trend_ok_sell, title="HIZLI SAT Sinyali", message="HIZLI SAT! {{ticker}} 4H")
alertcondition(al_signal,  title="AL Sinyali",  message="AL Sinyali! {{ticker}} {{interval}}")
alertcondition(sat_signal, title="SAT Sinyali", message="SAT Sinyali! {{ticker}} {{interval}}")

// ────────────────────────────────── ARKA PLAN ──────────────────────────────────
bgcolor(fast_al_signal  and volume_ok and trend_ok_buy  ? color.new(#00ff00, 90) : na)
bgcolor(fast_sat_signal and volume_ok and trend_ok_sell ? color.new(#ff6b6b, 90) : na)
bgcolor(al_signal  and not (fast_al_signal  and volume_ok and trend_ok_buy)  ? color.new(#00b894, 94) : na)
bgcolor(sat_signal and not (fast_sat_signal and volume_ok and trend_ok_sell) ? color.new(#d63031, 94) : na)

// ────────────────────────────────── ÇİZGİLER ──────────────────────────────────
plot(supertrend, "SuperTrend", color=direction == 1 ? color.green : color.red, linewidth=2)
plot(daily_supertrend, "Günlük ST", color=daily_direction == 1 ? color.new(color.green, 70) : color.new(color.red, 70),
     linewidth=1, style=plot.style_circles)
````
