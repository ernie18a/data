# Market Structure Shifts & Buy/Sell Strategy

- url: https://www.tradingview.com/script/ekySPL7X/
- type: indicator
- pine_id: PUB;5ca536591abe44bd95372c58ad756605
- version: 1.0

## Description

English: "This indicator detects Market Structure Shifts and triggers Buy/Sell signals only when price action, volume, and momentum are fully aligned with the long-term trend."

Türkçe Anlamı: Bu indikatör, Market Yapısı Değişimlerini tespit eder ve yalnızca fiyat hareketi, hacim ve momentum uzun vadeli trendle tam uyumlu olduğunda Al/Sat sinyalleri üretir.

## Source Code

````pine
//@version=5
indicator("Kapsamlı Market Yapısı & Trend Stratejisi", overlay=true, max_labels_count=500)

// --- PARAMETRELER ---
lookback = 3
emaBoyut = 200
rsiBoyut = 14

// --- GÖSTERGE HESAPLAMALARI ---
ema200 = ta.ema(close, emaBoyut)
rsiValue = ta.rsi(close, rsiBoyut)
obv = ta.obv
obv_ema = ta.ema(obv, 20)

// --- MARKET STRUCTURE (MSB) TESPİTİ ---
higherHigh = ta.highest(high, lookback * 2 + 1)
lowerLow = ta.lowest(low, lookback * 2 + 1)

var float lastHigh = na
var float lastLow = na

if high[lookback] == higherHigh
    lastHigh := high[lookback]
if low[lookback] == lowerLow
    lastLow := low[lookback]

msbPos = ta.crossover(close, lastHigh) // Pozitif Kırılım
msbNeg = ta.crossunder(close, lastLow) // Negatif Kırılım

// --- STRATEJİ KOŞULLARI ---

// GÜÇLÜ AL: Market yapısı yukarı kırılmalı + Fiyat EMA 200 üstünde + RSI 50 üstünde + Hacim onaylı
gucluAl = msbPos and close > ema200 and rsiValue > 50 and obv > obv_ema

// GÜÇLÜ SAT: Market yapısı aşağı kırılmalı + Fiyat EMA 200 altında + RSI 50 altında + Hacim zayıf
gucluSat = msbNeg and close < ema200 and rsiValue < 50 and obv < obv_ema

// --- GÖRSELLEŞTİRME ---

// EMA 200 Çizgisi
plot(ema200, color=color.new(color.gray, 50), linewidth=2, title="Ana Trend (EMA 200)")

// Sinyal Etiketleri
if gucluAl
    label.new(bar_index, low, "🚀 GÜÇLÜ AL\n(Trend & MSB Onaylı)", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.normal)

if gucluSat
    label.new(bar_index, high, "⚠️ GÜÇLÜ SAT\n(Trend & MSB Onaylı)", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.normal)

// Arka Plan Renklendirme
bgcolor(gucluAl ? color.new(color.green, 85) : na)
bgcolor(gucluSat ? color.new(color.red, 85) : na)
````
