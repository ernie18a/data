# XAUUSD Scalping Pro - Macd combine

- url: https://www.tradingview.com/script/AUlzihA6/
- type: indicator
- pine_id: PUB;f3d300b9761043cbb5d0379e7118c2be
- version: 1.0

## Description

XAUUSD Scalping pro and MACD indicator combine trade tool

## Source Code

````pine
//@version=6
indicator("XAUUSD Scalping - Final Filtered", overlay=true, max_bars_back=500)

// === 1. INPUTS (VCO) ===
len = input.int(30, "VCO Uzunluk")
scale = input.float(200.0, "VCO Ölçek")
oversold = input.float(-58, "Oversold Seviyesi")

// === 2. INPUTS (MACD) ===
fast = input.int(12, 'MACD Hızlı')
slow = input.int(25, 'MACD Yavaş')
sign = input.int(15, 'MACD Sinyal')
show_trend = input.bool(true, "Arka Planda Trendi Göster")

// === 3. MACD HEIKIN ASHI HESAPLAMA (KESİN FİLTRE) ===
haclose = (open + high + low + close) / 4
var float haopen = na
haopen := na(haopen[1]) ? (open + close) / 2 : (haopen[1] + haclose[1]) / 2

// Zero-Lag DEMA (MACD için)
f1 = ta.sma(haclose, fast)
f2 = ta.sma(f1, fast)
defast = (2 * f1) - f2

s1 = ta.sma(haclose, slow)
s2 = ta.sma(s1, slow)
deslow = (2 * s1) - s2

macdLine = defast - deslow
signalLine = ta.sma(macdLine, sign)

// FİLTRE: SADECE MAVİ > KIRMIZI İSE TRUE
is_bullish = macdLine > signalLine

// === 4. VCO SİNYAL ÜRETİCİ ===
mid = ta.sma((high + low) / 2, len)
rng = ta.sma(high - low, len)
body = ta.sma(math.abs(close - open), len)
offset = (rng * scale / 100) * (1 + body / math.max(rng, 1e-10))
dn = mid - offset
band = math.max((mid + offset) - dn, 1e-10)
osc = 100 * (close - dn) / band - 50

// === 5. SİNYAL ÇAKIŞTIRMA (AND MANTIĞI) ===
// Kesişme olduğu AN'da MACD pozitif değilse sinyal ÇIKMAZ.
vco_cross = ta.crossover(osc, oversold)
buy_signal = vco_cross and is_bullish

// === 6. GÖRSELLEŞTİRME (FİYAT ÜZERİNDE) ===
// Sinyal mumun tam altında
plotshape(buy_signal, title="BUY", location=location.belowbar, color=color.lime, style=shape.triangleup, size=size.large, text="BUY", textcolor=color.white)

// Arka plan rengi (Trendi takip etmen için)
// Mavi bölge = MACD Pozitif, Kırmızı bölge = MACD Negatif
bg_color = show_trend ? (is_bullish ? color.new(color.blue, 90) : color.new(color.red, 90)) : na
bgcolor(bg_color)

// MACD Çizgilerini Fiyatın Altında Hayalet Gibi Göster (Opsiyonel)
// Not: Overlay=true iken çizgiler fiyatın üstüne biner, bu yüzden sadece arka plan rengi daha temizdir.
````
