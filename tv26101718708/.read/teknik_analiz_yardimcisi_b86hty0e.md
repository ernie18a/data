# Teknik Analiz Yardimcisi

- url: https://www.tradingview.com/script/b86htY0E/
- type: indicator
- pine_id: PUB;afaafee2485d461ba624a393d3520a6b
- version: 1.0

## Description

TAY (Teknik Analiz Yardimcisi)
Grafik üzerinde çok sayıda indikatörü takip etmek yerine, temel teknik göstergeleri tek bir tablo üzerinde birleştiren bir takip aracıdır.

Dashboard İçeriği:

EMA (20, 50, 100, 200): Fiyatın trend ortalamalarına göre konumunu gösterir.

RSI (14): Fiyatın aşırı alım veya satım bölgelerini takip eder.

Bollinger Bantlari: Fiyatın oynaklık bandını belirler.

VWAP: Kurumsal maliyete yakın ortalamayı analiz eder.

Supertrend: Trend yönünü (Yükseliş/Düşüş) belirler.

OBV MACD: Hacim destekli momentumu ölçer.

Sinyal Mantigi:
Tablo, yukarıdaki 9 indikatörün "AL" ve "SAT" sinyallerini anlık olarak tarar. Alt kısımda yer alan özet bölümü, indikatörler arasındaki "Net Fark" (AL - SAT dengesi) hesabına göre piyasa eğilimini sayısal olarak raporlar.

Not: Bu araç tamamen fiyat ve hacim verilerine dayalı teknik hesaplamalar yapar. Herhangi bir alım-satım tavsiyesi içermez; sadece teknik verilerin hızlı takibini sağlayan bir analiz yardımcıdır.

## Source Code

````pine
//@version=6
indicator(title="Teknik Analiz Yardimcisi", shorttitle="TAY", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════
//  EMA
// ═══════════════════════════════════════════════
shortest = ta.ema(close, 20)
short_e  = ta.ema(close, 50)
longer   = ta.ema(close, 100)
longest  = ta.ema(close, 200)

ema20_sig  = close > shortest ? "AL" : "SAT"
ema50_sig  = close > short_e  ? "AL" : "SAT"
ema100_sig = close > longer   ? "AL" : "SAT"
ema200_sig = close > longest  ? "AL" : "SAT"

// ═══════════════════════════════════════════════
//  RSI
// ═══════════════════════════════════════════════
rsiLen  = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
_chg    = ta.change(close)
up_r    = ta.rma(math.max(_chg, 0), rsiLen)
dn_r    = ta.rma(-math.min(_chg, 0), rsiLen)
rsi     = dn_r == 0 ? 100 : up_r == 0 ? 0 : 100 - (100 / (1 + up_r / dn_r))
rsi_sig = rsi >= 70 ? "SAT" : rsi <= 30 ? "AL" : "NOTR"

// ═══════════════════════════════════════════════
//  BOLLINGER BANDS
// ═══════════════════════════════════════════════
bb_len   = input.int(20,    "BB Length",  minval=1,     group="Bollinger Bands")
bb_mult  = input.float(2.0, "BB StdDev", minval=0.001, group="Bollinger Bands")
bb_basis = ta.sma(close, bb_len)
bb_dev   = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev
bb_sig   = close <= bb_lower ? "AL" : close >= bb_upper ? "SAT" : "NOTR"

// ═══════════════════════════════════════════════
//  VWAP - mor cizgi
// ═══════════════════════════════════════════════
vwap_val = ta.vwap(close)
vwap_sig = close > vwap_val ? "AL" : "SAT"

plot(vwap_val, title="VWAP", color=color.new(#9C27B0, 10), linewidth=2, style=plot.style_line)

var label vwap_lbl = na
label.delete(vwap_lbl)
vwap_lbl := label.new(
     x         = bar_index,
     y         = vwap_val,
     text      = "VWAP",
     style     = label.style_label_left,
     color     = color.new(#9C27B0, 20),
     textcolor = color.white,
     size      = size.tiny)

// ═══════════════════════════════════════════════
//  SUPERTREND
// ═══════════════════════════════════════════════
st_period = input.int(10,    "ATR Period",     group="Supertrend")
st_mult   = input.float(3.0, "ATR Multiplier", step=0.1, group="Supertrend")

st_atr = ta.atr(st_period)
st_up  = hl2 - st_mult * st_atr
st_dn  = hl2 + st_mult * st_atr

var float st_up1 = na
var float st_dn1 = na
var int   trend  = 1

st_up1 := close[1] > nz(st_up1[1], st_up) ? math.max(st_up, nz(st_up1[1], st_up)) : st_up
st_dn1 := close[1] < nz(st_dn1[1], st_dn) ? math.min(st_dn, nz(st_dn1[1], st_dn)) : st_dn
trend  := nz(trend[1], 1) == -1 and close > st_dn1 ? 1 : nz(trend[1], 1) == 1 and close < st_up1 ? -1 : nz(trend[1], 1)

st_buy  = trend ==  1 and trend[1] == -1
st_sell = trend == -1 and trend[1] ==  1
st_sig  = trend ==  1 ? "AL" : "SAT"

plot(trend ==  1 ? st_up1 : na, "ST Yukselis", color=color.new(color.green, 10), linewidth=2, style=plot.style_linebr)
plot(trend == -1 ? st_dn1 : na, "ST Dusus",   color=color.new(color.red,   10), linewidth=2, style=plot.style_linebr)

plotshape(st_buy  ? st_up1 : na, title="AL",  style=shape.labelup,   location=location.absolute, color=color.green, textcolor=color.white, text="AL",  size=size.small)
plotshape(st_sell ? st_dn1 : na, title="SAT", style=shape.labeldown, location=location.absolute, color=color.red,   textcolor=color.white, text="SAT", size=size.small)

// ═══════════════════════════════════════════════
//  OBV MACD
// ═══════════════════════════════════════════════
obv_v   = ta.cum(math.sign(ta.change(close)) * volume)
obv_sma = ta.sma(obv_v, 14)
vspread = ta.stdev(obv_v - obv_sma, 28)
pspread = ta.stdev(high - low, 28)
shadow  = vspread == 0 ? 0.0 : (obv_v - obv_sma) / vspread * pspread
obv_out = shadow > 0 ? high + shadow : low + shadow
obvema  = ta.ema(obv_out, 1)

dema_f(s, l) =>
    m1 = ta.ema(s, l)
    2 * m1 - ta.ema(m1, l)

obv_fast = dema_f(obvema, 9)
obv_slow = ta.ema(close, 26)
obv_macd = obv_fast - obv_slow

var float b5 = 0.0
var int   oc = 0
_n   = math.max(bar_index, 1)
_a15 = ta.cum(math.abs(obv_macd - nz(b5[1], obv_macd))) / _n
b5  := obv_macd > nz(b5[1], obv_macd) + _a15 ? obv_macd : obv_macd < nz(b5[1], obv_macd) - _a15 ? obv_macd : nz(b5[1], obv_macd)
oc  := ta.change(b5) > 0 ? 1 : ta.change(b5) < 0 ? -1 : nz(oc[1])
obv_sig = oc == 1 ? "AL" : "SAT"

// ═══════════════════════════════════════════════
//  GENEL OZET — net fark mantigi
// ═══════════════════════════════════════════════
sig_list = array.from(
     ema20_sig, ema50_sig, ema100_sig, ema200_sig,
     rsi_sig,   bb_sig,
     vwap_sig,  st_sig,    obv_sig)

buy_c  = 0
sell_c = 0
notr_c = 0

for s in sig_list
    if s == "AL"
        buy_c  += 1
    else if s == "SAT"
        sell_c += 1
    else
        notr_c += 1

net = buy_c - sell_c

overall =
     net >=  3 ? "GUCLU AL  +" :
     net ==  2 ? "ZAYIF AL  +" :
     net ==  1 ? "ZAYIF AL  +" :
     net ==  0 ? "KARISIK  ~"  :
     net == -1 ? "ZAYIF SAT -" :
     net == -2 ? "ZAYIF SAT -" :
     "GUCLU SAT -"

ov_bg =
     net >=  3 ? color.new(color.green, 0)  :
     net >=  1 ? color.new(color.green, 45) :
     net ==  0 ? color.rgb(60, 60, 80)      :
     net >= -2 ? color.new(color.red, 45)   :
     color.new(color.red, 0)

// ═══════════════════════════════════════════════
//  TABLO
// ═══════════════════════════════════════════════
var table dash = table.new(
     position.top_right, 3, 13,
     bgcolor      = color.rgb(8, 10, 18, 0),
     border_width = 1,
     border_color = color.rgb(45, 50, 75),
     frame_width  = 2,
     frame_color  = color.rgb(60, 70, 120))

f_bg(sig) =>
    sig == "AL"  ? color.new(color.green, 5) :
     sig == "SAT" ? color.new(color.red,   5) :
     color.rgb(55, 55, 68)

f_tc(sig) =>
    sig == "NOTR" ? color.rgb(200, 200, 200) : color.white

HDR = color.rgb(15, 18, 42)
HDT = color.rgb(170, 185, 255)
ROW = color.rgb(12, 14, 28)
SZ  = size.small

if barstate.islast

    table.cell(dash, 0, 0, "Teknik Analiz Yardimcisi", bgcolor=HDR, text_color=HDT, text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 0, "DEGER",                    bgcolor=HDR, text_color=HDT, text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 0, "SINYAL",                   bgcolor=HDR, text_color=HDT, text_size=SZ, text_halign=text.align_center)

    table.cell(dash, 0, 1, "EMA 20",  bgcolor=ROW, text_color=color.rgb(255,110,110), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(shortest, "#.##"), bgcolor=ROW, text_color=color.rgb(255,110,110), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 1, ema20_sig,  bgcolor=f_bg(ema20_sig),  text_color=f_tc(ema20_sig),  text_size=SZ, text_halign=text.align_center)

    table.cell(dash, 0, 2, "EMA 50",  bgcolor=ROW, text_color=color.rgb(255,110,110), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(short_e,  "#.##"), bgcolor=ROW, text_color=color.rgb(255,110,110), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 2, ema50_sig,  bgcolor=f_bg(ema50_sig),  text_color=f_tc(ema50_sig),  text_size=SZ, text_halign=text.align_center)

    table.cell(dash, 0, 3, "EMA 100", bgcolor=ROW, text_color=color.rgb(255,110,110), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(longer,   "#.##"), bgcolor=ROW, text_color=color.rgb(255,110,110), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 3, ema100_sig, bgcolor=f_bg(ema100_sig), text_color=f_tc(ema100_sig), text_size=SZ, text_halign=text.align_center)

    table.cell(dash, 0, 4, "EMA 200", bgcolor=ROW, text_color=color.rgb(255,110,110), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(longest,  "#.##"), bgcolor=ROW, text_color=color.rgb(255,110,110), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 4, ema200_sig, bgcolor=f_bg(ema200_sig), text_color=f_tc(ema200_sig), text_size=SZ, text_halign=text.align_center)

    rsi_lbl = str.tostring(math.round(rsi, 2)) + (rsi >= 70 ? " ^" : rsi <= 30 ? " v" : "")
    table.cell(dash, 0, 5, "RSI (14)", bgcolor=ROW, text_color=color.rgb(180,140,255), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 5, rsi_lbl,   bgcolor=ROW, text_color=color.rgb(180,140,255), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 5, rsi_sig,   bgcolor=f_bg(rsi_sig),   text_color=f_tc(rsi_sig),   text_size=SZ, text_halign=text.align_center)

    bb_lbl = str.tostring(bb_basis, "#.##") + " +-" + str.tostring(bb_dev, "#.##")
    table.cell(dash, 0, 6, "Bollinger Bands", bgcolor=ROW, text_color=color.rgb(100,160,255), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 6, bb_lbl,   bgcolor=ROW, text_color=color.rgb(100,160,255), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 6, bb_sig,   bgcolor=f_bg(bb_sig),   text_color=f_tc(bb_sig),   text_size=SZ, text_halign=text.align_center)

    table.cell(dash, 0, 7, "VWAP",   bgcolor=ROW, text_color=color.rgb(200,100,255), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(vwap_val, "#.##"), bgcolor=ROW, text_color=color.rgb(200,100,255), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 7, vwap_sig, bgcolor=f_bg(vwap_sig), text_color=f_tc(vwap_sig), text_size=SZ, text_halign=text.align_center)

    st_dir = trend == 1 ? "Yukselis ^  " : "Dusus v  "
    st_val = trend == 1 ? str.tostring(st_up1, "#.##") : str.tostring(st_dn1, "#.##")
    table.cell(dash, 0, 8, "Supertrend", bgcolor=ROW, text_color=trend==1?color.rgb(80,255,120):color.rgb(255,80,80), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 8, st_dir + st_val, bgcolor=ROW, text_color=trend==1?color.rgb(80,255,120):color.rgb(255,80,80), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 8, st_sig,  bgcolor=f_bg(st_sig),  text_color=f_tc(st_sig),  text_size=SZ, text_halign=text.align_center)

    obv_dir = oc == 1 ? "Yukselis ^" : "Dusus v"
    table.cell(dash, 0, 9, "OBV MACD Indicator", bgcolor=ROW, text_color=oc==1?color.rgb(80,160,255):color.rgb(255,100,100), text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 9, obv_dir,  bgcolor=ROW, text_color=oc==1?color.rgb(80,160,255):color.rgb(255,100,100), text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 9, obv_sig,  bgcolor=f_bg(obv_sig), text_color=f_tc(obv_sig), text_size=SZ, text_halign=text.align_center)

    table.cell(dash, 0, 10, "", bgcolor=color.rgb(35,40,70), text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 10, "", bgcolor=color.rgb(35,40,70), text_color=color.white, text_size=size.tiny)
    table.cell(dash, 2, 10, "", bgcolor=color.rgb(35,40,70), text_color=color.white, text_size=size.tiny)

    net_str = net > 0 ? "+" + str.tostring(net) : str.tostring(net)
    table.cell(dash, 0, 11, "AL: " + str.tostring(buy_c) + "  SAT: " + str.tostring(sell_c) + "  NOTR: " + str.tostring(notr_c),
         bgcolor=ov_bg, text_color=color.white, text_size=SZ, text_halign=text.align_left)
    table.cell(dash, 1, 11, "Net: " + net_str,
         bgcolor=ov_bg, text_color=color.white, text_size=SZ, text_halign=text.align_center)
    table.cell(dash, 2, 11, overall,
         bgcolor=ov_bg, text_color=color.white, text_size=SZ, text_halign=text.align_center)
````
