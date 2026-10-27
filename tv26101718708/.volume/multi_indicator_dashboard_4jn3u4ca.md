# Multi Indicator Dashboard

- url: https://www.tradingview.com/script/4JN3u4ca/
- type: indicator
- pine_id: PUB;cc6e752e42f5425685bb45a94421c65b
- version: 1.0

## Description

Teknik Analiz Yardımcısı

Grafikte onlarca indikatörü tek tek takip etmek yerine, stratejiniz için kritik olan 9 temel veriyi tek tabloda topladım.

Bu Dashboard ne işe yarar?

Hız: EMA (20/50/100/200), RSI, Bollinger, VWAP, Supertrend ve OBV-MACD verilerini tek panelde görürsünüz.

Teyit: "Güçlü AL/SAT" özet tablosu sayesinde, hissenin teknik olarak hangi bölgede olduğunu anlık analiz eder, karar verme sürenizi kısaltırsınız.

Disiplin: İşleme girmeden önce indikatörlerin teknik teyidini (hacim ve trend uyumunu) saniyeler içinde görür, hatalı giriş riskini azaltırsınız.

Kullanım: İndikatörü grafiğinize eklediğinizde sağ üst köşedeki tabloda sinyaller otomatik güncellenir.

## Source Code

````pine
//@version=6
indicator(title="Multi Indicator Dashboard", shorttitle="MID", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════
//  EMA 20 / 50 / 100 / 200
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
rsiLen = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
_chg   = ta.change(close)
up_r   = ta.rma(math.max(_chg, 0), rsiLen)
dn_r   = ta.rma(-math.min(_chg, 0), rsiLen)
rsi    = dn_r == 0 ? 100 : up_r == 0 ? 0 : 100 - (100 / (1 + up_r / dn_r))
rsi_sig = rsi >= 70 ? "SAT" : rsi <= 30 ? "AL" : "NÖTR"

// ═══════════════════════════════════════════════
//  BOLLINGER BANDS
// ═══════════════════════════════════════════════
bb_len   = input.int(20,  "BB Length",  minval=1,     group="Bollinger Bands")
bb_mult  = input.float(2.0,"BB StdDev", minval=0.001, group="Bollinger Bands")
bb_basis = ta.sma(close, bb_len)
bb_dev   = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev
bb_sig   = close <= bb_lower ? "AL" : close >= bb_upper ? "SAT" : "NÖTR"

// ═══════════════════════════════════════════════
//  VWAP
// ═══════════════════════════════════════════════
vwap_val  = ta.vwap(close)
vwap_sig  = close > vwap_val ? "AL" : "SAT"

// ═══════════════════════════════════════════════
//  SUPERTREND
// ═══════════════════════════════════════════════
st_period = input.int(10,   "ATR Period",     group="Supertrend")
st_mult   = input.float(3.0,"ATR Multiplier", step=0.1, group="Supertrend")
st_atr = ta.atr(st_period)
st_up  = hl2 - st_mult * st_atr
st_dn  = hl2 + st_mult * st_atr
var float st_up1 = na
var float st_dn1 = na
var int   trend  = 1
st_up1 := close[1] > nz(st_up1[1], st_up) ? math.max(st_up, nz(st_up1[1], st_up)) : st_up
st_dn1 := close[1] < nz(st_dn1[1], st_dn) ? math.min(st_dn, nz(st_dn1[1], st_dn)) : st_dn
trend  := nz(trend[1], 1) == -1 and close > st_dn1 ? 1 : nz(trend[1], 1) == 1 and close < st_up1 ? -1 : nz(trend[1], 1)
st_sig  = trend == 1  ? "AL" : "SAT"

plot(trend == 1  ? st_up1 : na, "ST Yükseliş", color=color.new(color.green, 10), linewidth=2, style=plot.style_linebr)
plot(trend == -1 ? st_dn1 : na, "ST Düşüş",   color=color.new(color.red,   10), linewidth=2, style=plot.style_linebr)

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
//  TABLO
// ═══════════════════════════════════════════════
var table dash = table.new(position.top_right, 3, 10, bgcolor=color.rgb(8, 10, 18, 0), border_width=1, border_color=color.rgb(45, 50, 75))

f_bg(sig) => sig == "AL" ? color.new(color.green, 5) : sig == "SAT" ? color.new(color.red, 5) : color.rgb(60, 60, 70)
f_tc(sig) => sig == "NÖTR" ? color.rgb(200, 200, 200) : color.white

if barstate.islast
    table.cell(dash, 0, 0, "İNDİKATÖR", bgcolor=color.rgb(15,18,42), text_color=color.rgb(170,185,255), text_size=size.small)
    table.cell(dash, 1, 0, "DEĞER", bgcolor=color.rgb(15,18,42), text_color=color.rgb(170,185,255), text_size=size.small)
    table.cell(dash, 2, 0, "SİNYAL", bgcolor=color.rgb(15,18,42), text_color=color.rgb(170,185,255), text_size=size.small)

    table.cell(dash, 0, 1, "EMA 20", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(shortest, "#.##"), bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 1, ema20_sig, bgcolor=f_bg(ema20_sig), text_color=f_tc(ema20_sig), text_size=size.small)

    table.cell(dash, 0, 2, "EMA 50", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(short_e, "#.##"), bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 2, ema50_sig, bgcolor=f_bg(ema50_sig), text_color=f_tc(ema50_sig), text_size=size.small)

    table.cell(dash, 0, 3, "EMA 100", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(longer, "#.##"), bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 3, ema100_sig, bgcolor=f_bg(ema100_sig), text_color=f_tc(ema100_sig), text_size=size.small)

    table.cell(dash, 0, 4, "EMA 200", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(longest, "#.##"), bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 4, ema200_sig, bgcolor=f_bg(ema200_sig), text_color=f_tc(ema200_sig), text_size=size.small)

    table.cell(dash, 0, 5, "RSI (14)", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(rsi, "#.##"), bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 5, rsi_sig, bgcolor=f_bg(rsi_sig), text_color=f_tc(rsi_sig), text_size=size.small)

    table.cell(dash, 0, 6, "BB", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, "20/2.0", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 6, bb_sig, bgcolor=f_bg(bb_sig), text_color=f_tc(bb_sig), text_size=size.small)

    table.cell(dash, 0, 7, "VWAP", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(vwap_val, "#.##"), bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 7, vwap_sig, bgcolor=f_bg(vwap_sig), text_color=f_tc(vwap_sig), text_size=size.small)

    table.cell(dash, 0, 8, "Supertrend", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 8, trend == 1 ? "Yükseliş" : "Düşüş", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 8, st_sig, bgcolor=f_bg(st_sig), text_color=f_tc(st_sig), text_size=size.small)

    table.cell(dash, 0, 9, "OBV MACD", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 9, oc == 1 ? "Yükseliş" : "Düşüş", bgcolor=color.rgb(12,14,28), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 9, obv_sig, bgcolor=f_bg(obv_sig), text_color=f_tc(obv_sig), text_size=size.small)
````
