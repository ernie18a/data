# Market Structure Break & Sinyaller

- url: https://www.tradingview.com/script/TawHTbcz/
- type: indicator
- pine_id: PUB;35d70c5b5b1e44d583edc36c1a37d34a
- version: 1.0

## Description

Market yapısının bozulduğu noktaları gösteriyor. Hem pozitif hem negatif olarak

## Source Code

````pine
//@version=5
indicator("Market Structure Break & Sinyaller", overlay=true, max_labels_count=500)

// --- 1. MSB (Market Structure Break) Hesaplaması ---
lookback = 3 
higherHigh = ta.highest(high, lookback * 2 + 1)
lowerLow = ta.lowest(low, lookback * 2 + 1)

var float lastHigh = na
var float lastLow = na

// Son Tepe ve Dip Noktalarını Güncelle
if high[lookback] == higherHigh
    lastHigh := high[lookback]
if low[lookback] == lowerLow
    lastLow := low[lookback]

// Pozitif MSB: Fiyat son tepeyi yukarı kırarsa
msbPos = ta.crossover(close, lastHigh)
// Negatif MSB: Fiyat son dibi aşağı kırarsa
msbNeg = ta.crossunder(close, lastLow)

// --- 2. Diğer Göstergeler ---
ema200 = ta.ema(close, 200)
rsiValue = ta.rsi(close, 14)
obv = ta.obv
obv_ema = ta.ema(obv, 20)

// --- 3. Sinyal Çizimleri ---
// Pozitif MSB (Mavi Etiket)
if msbPos
    label.new(bar_index, high, "MSB (+)", color=color.blue, textcolor=color.white, style=label.style_label_down, size=size.small)

// Negatif MSB (Turuncu Etiket)
if msbNeg
    label.new(bar_index, low, "MSB (-)", color=color.orange, textcolor=color.white, style=label.style_label_up, size=size.small)

// Genel Al/Sat Sinyalleri (Onaylı)
buySignal = close > ema200 and rsiValue > 50 and obv > obv_ema and ta.crossover(close, ta.ema(close, 20))
sellSignal = close < ema200 and rsiValue < 50 and obv < obv_ema and ta.crossunder(close, ta.ema(close, 20))

plotshape(buySignal, title="Güçlü AL", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small, text="AL")
plotshape(sellSignal, title="Güçlü SAT", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small, text="SAT")

// EMA 200 Çizgisi
plot(ema200, color=color.new(color.gray, 50), title="EMA 200")
````
