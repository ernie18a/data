# EMA-SMA-WMA-DEMA-VWMA 20-50-100-150-200 

- url: https://www.tradingview.com/script/gVuEkG6Y/
- type: indicator
- pine_id: PUB;5ee608a044c5465383ffb44677c2b751
- version: 1.0

## Description

This indicator brings together the 5 most commonly used moving average types (EMA, SMA, WMA, DEMA, VWMA) and their critical periods (20, 50, 100, 150, 200) in technical analysis under one roof.

The presence of 25 different lines on the chart may seem complex at first glance, so I have summarized the strategic usage guide below:

1. Differences Between Moving Average Types
Knowing which average to use when allows you to understand the "speed" of the price:

SMA (Simple): The slowest moving average, most closely watched by institutional investors (especially the 200 SMA). Provides reliable support/resistance.

EMA (Exponential): Gives more weight to recent price movements. Signals trend reversals faster than SMA.

WMA (Weighted): Similar to EMA but more sensitive to price changes.

DEMA (Double Exponential): Reduces lag to almost zero. Suitable for very fast scalping trades.

VWMA (Volume Weighted): Blends price with volume. If the VWMA also steepens as the price rises, it means that this rise is supported by "real volume".

Bu indikatör, teknik analizde en çok kullanılan 5 farklı hareketli ortalama türünü (EMA, SMA, WMA, DEMA, VWMA) ve bunların kritik periyotlarını (20, 50, 100, 150, 200) tek bir çatıda topluyor.

Grafiğinde 25 farklı çizgi olması ilk bakışta karmaşık gelebilir, bu yüzden stratejik kullanım rehberini aşağıda özetledim:

1. Hareketli Ortalama Türleri Arasındaki Farklar
Hangi ortalamayı ne zaman kullanacağını bilmek, fiyatın "hızını" anlamanı sağlar:

SMA (Basit): En ağır hareket eden, kurumsal yatırımcıların (özellikle 200 SMA) en çok dikkat ettiği ortalamadır. Güvenilir destek/direnç sağlar.

EMA (Üssel): Son fiyat hareketlerine daha fazla ağırlık verir. Trend dönüşlerini SMA'dan daha hızlı sinyalleşir.

WMA (Ağırlıklı): EMA'ya benzer ama fiyat değişimlerine karşı daha hassastır.

DEMA (Çift Üssel): Gecikmeyi (lag) neredeyse sıfıra indirir. Çok hızlı scalping işlemleri için uygundur.

VWMA (Hacim Ağırlıklı): Fiyatı hacimle harmanlar. Eğer fiyat yükselirken VWMA da dikleşiyorsa, bu yükselişin "gerçek hacimle" desteklendiğini anlarız.

## Source Code

````pine
//@version=6
indicator(title="EMA, SMA, WMA, DEMA, VWMA 20-50-100-150-200 (Fix)", shorttitle="Multi MAs All", overlay=true)

// --- Visibility Controls ---
groupVis = "Global Visibility"
showEMAs  = input.bool(true, title="Show All EMAs",  group=groupVis)
showSMAs  = input.bool(true, title="Show All SMAs",  group=groupVis)
showWMAs  = input.bool(true, title="Show All WMAs",  group=groupVis)
showDEMAs = input.bool(true, title="Show All DEMAs", group=groupVis)
showVWMAs = input.bool(true, title="Show All VWMAs", group=groupVis)

// --- EMA Inputs ---
groupEMA = "EMA Settings"
e_len1 = input.int(20,  minval=1, title="EMA 20 Length",  group=groupEMA)
e_len2 = input.int(50,  minval=1, title="EMA 50 Length",  group=groupEMA)
e_len3 = input.int(100, minval=1, title="EMA 100 Length", group=groupEMA)
e_len4 = input.int(150, minval=1, title="EMA 150 Length", group=groupEMA)
e_len5 = input.int(200, minval=1, title="EMA 200 Length", group=groupEMA)

// --- SMA Inputs ---
groupSMA = "SMA Settings"
s_len1 = input.int(20,  minval=1, title="SMA 20 Length",  group=groupSMA)
s_len2 = input.int(50,  minval=1, title="SMA 50 Length",  group=groupSMA)
s_len3 = input.int(100, minval=1, title="SMA 100 Length", group=groupSMA)
s_len4 = input.int(150, minval=1, title="SMA 150 Length", group=groupSMA)
s_len5 = input.int(200, minval=1, title="SMA 200 Length", group=groupSMA)

// --- WMA Inputs ---
groupWMA = "WMA Settings"
w_len1 = input.int(20,  minval=1, title="WMA 20 Length",  group=groupWMA)
w_len2 = input.int(50,  minval=1, title="WMA 50 Length",  group=groupWMA)
w_len3 = input.int(100, minval=1, title="WMA 100 Length", group=groupWMA)
w_len4 = input.int(150, minval=1, title="WMA 150 Length", group=groupWMA)
w_len5 = input.int(200, minval=1, title="WMA 200 Length", group=groupWMA)

// --- DEMA Inputs ---
groupDEMA = "DEMA Settings"
d_len1 = input.int(20,  minval=1, title="DEMA 20 Length",  group=groupDEMA)
d_len2 = input.int(50,  minval=1, title="DEMA 50 Length",  group=groupDEMA)
d_len3 = input.int(100, minval=1, title="DEMA 100 Length", group=groupDEMA)
d_len4 = input.int(150, minval=1, title="DEMA 150 Length", group=groupDEMA)
d_len5 = input.int(200, minval=1, title="DEMA 200 Length", group=groupDEMA)

// --- VWMA Inputs ---
groupVWMA = "VWMA Settings"
vw_len1 = input.int(20,  minval=1, title="VWMA 20 Length",  group=groupVWMA)
vw_len2 = input.int(50,  minval=1, title="VWMA 50 Length",  group=groupVWMA)
vw_len3 = input.int(100, minval=1, title="VWMA 100 Length", group=groupVWMA)
vw_len4 = input.int(150, minval=1, title="VWMA 150 Length", group=groupVWMA)
vw_len5 = input.int(200, minval=1, title="VWMA 200 Length", group=groupVWMA)

// --- Calculations ---

// EMA
ema1 = showEMAs ? ta.ema(close, e_len1) : na
ema2 = showEMAs ? ta.ema(close, e_len2) : na
ema3 = showEMAs ? ta.ema(close, e_len3) : na
ema4 = showEMAs ? ta.ema(close, e_len4) : na
ema5 = showEMAs ? ta.ema(close, e_len5) : na

// SMA
sma1 = showSMAs ? ta.sma(close, s_len1) : na
sma2 = showSMAs ? ta.sma(close, s_len2) : na
sma3 = showSMAs ? ta.sma(close, s_len3) : na
sma4 = showSMAs ? ta.sma(close, s_len4) : na
sma5 = showSMAs ? ta.sma(close, s_len5) : na

// WMA
wma1 = showWMAs ? ta.wma(close, w_len1) : na
wma2 = showWMAs ? ta.wma(close, w_len2) : na
wma3 = showWMAs ? ta.wma(close, w_len3) : na
wma4 = showWMAs ? ta.wma(close, w_len4) : na
wma5 = showWMAs ? ta.wma(close, w_len5) : na

// DEMA Custom Calculation (2 * EMA - EMA(EMA))
dema_calc(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    2 * e1 - e2

dema1 = showDEMAs ? dema_calc(close, d_len1) : na
dema2 = showDEMAs ? dema_calc(close, d_len2) : na
dema3 = showDEMAs ? dema_calc(close, d_len3) : na
dema4 = showDEMAs ? dema_calc(close, d_len4) : na
dema5 = showDEMAs ? dema_calc(close, d_len5) : na

// VWMA
vwma1 = showVWMAs ? ta.vwma(close, vw_len1) : na
vwma2 = showVWMAs ? ta.vwma(close, vw_len2) : na
vwma3 = showVWMAs ? ta.vwma(close, vw_len3) : na
vwma4 = showVWMAs ? ta.vwma(close, vw_len4) : na
vwma5 = showVWMAs ? ta.vwma(close, vw_len5) : na

// --- Plots ---

// EMA
plot(ema1, color=color.orange, linewidth=2, title="EMA 20")
plot(ema2, color=color.green,  linewidth=2, title="EMA 50")
plot(ema3, color=color.purple, linewidth=2, title="EMA 100")
plot(ema4, color=color.blue,   linewidth=2, title="EMA 150")
plot(ema5, color=color.maroon, linewidth=2, title="EMA 200")

// SMA
plot(sma1, color=color.orange, linewidth=2, title="SMA 20")
plot(sma2, color=color.green,  linewidth=2, title="SMA 50")
plot(sma3, color=color.purple, linewidth=2, title="SMA 100")
plot(sma4, color=color.blue,   linewidth=2, title="SMA 150")
plot(sma5, color=color.maroon, linewidth=2, title="SMA 200")

// WMA
plot(wma1, color=color.orange, linewidth=2, title="WMA 20")
plot(wma2, color=color.green,  linewidth=2, title="WMA 50")
plot(wma3, color=color.purple, linewidth=2, title="WMA 100")
plot(wma4, color=color.blue,   linewidth=2, title="WMA 150")
plot(wma5, color=color.maroon, linewidth=2, title="WMA 200")

// DEMA
plot(dema1, color=color.orange, linewidth=2, title="DEMA 20")
plot(dema2, color=color.green,  linewidth=2, title="DEMA 50")
plot(dema3, color=color.purple, linewidth=2, title="DEMA 100")
plot(dema4, color=color.blue,   linewidth=2, title="DEMA 150")
plot(dema5, color=color.maroon, linewidth=2, title="DEMA 200")

// VWMA
plot(vwma1, color=color.orange, linewidth=2, title="VWMA 20")
plot(vwma2, color=color.green,  linewidth=2, title="VWMA 50")
plot(vwma3, color=color.purple, linewidth=2, title="VWMA 100")
plot(vwma4, color=color.blue,   linewidth=2, title="VWMA 150")
plot(vwma5, color=color.maroon, linewidth=2, title="VWMA 200")
````
