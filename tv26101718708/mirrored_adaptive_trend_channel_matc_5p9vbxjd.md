# Mirrored Adaptive Trend Channel (MATC)

- url: https://www.tradingview.com/script/5p9vBxJd/
- type: indicator
- pine_id: PUB;bbe4f83ed643466dbc30f750211c4959
- version: 1.0

## Description

Mirrored Adaptive Trend Channel (MATC)

Mirrored Adaptive Trend Channel (MATC) is a volatility-adjusted trend-following indicator designed to reduce false breakouts and improve directional clarity through a mirrored price channel structure and dual confirmation logic.

🔹 Core Logic

The indicator is based on a percentage deviation channel constructed around the median price:

Source price:
HL2 (High + Low) / 2
Upper Band:
Upper = HL2 × (1 + Percent / 100)
Lower Band:
Lower = HL2 × (1 - Percent / 100)

These bands define a symmetrical price channel around a dynamic mid-region.

🔹 Mirror Structure

MATC introduces a mirror-adjusted channel model, where:

The midline is calculated as the average of upper and lower bands
Distance from midline is symmetrically redistributed
A mirror strength coefficient is applied to adjust channel expansion and contraction dynamically

This mechanism improves structural stability during volatility expansion phases.

🔹 Trend Determination

Trend direction is defined using a dual confirmation breakout logic:

Bullish Trend:
Price closes above the upper mirror band for consecutive confirmations
Bearish Trend:
Price closes below the lower mirror band for consecutive confirmations

Trend state is maintained until an opposite breakout is confirmed.

🔹 Smoothing Mechanism

To reduce noise, both bands are smoothed using an EMA:

EMA(lower mirror band, length)
EMA(upper mirror band, length)

This ensures cleaner transitions and reduces market micro-fluctuation sensitivity.

🔹 Signal Generation
BUY signal: Transition from bearish to bullish trend state
SELL signal: Transition from bullish to bearish trend state

Signals are plotted only at confirmed trend reversals to avoid premature entries.

🔹 Key Features
Mirrored channel structure for improved symmetry
Percentage-based adaptive volatility scaling
EMA smoothing for noise reduction
Dual-bar confirmation logic for fake breakout filtering
Clean trend-state visualization
🇹🇷 TÜRKÇE AÇIKLAMA
Mirrored Adaptive Trend Channel (MATC)

Mirrored Adaptive Trend Channel (MATC), sahte kırılımları azaltmak ve trend yönünü daha net göstermek için geliştirilmiş, yüzde bazlı adaptif kanal yapısına ve mirror (yansıtma) mantığına sahip trend takip indikatörüdür.

🔹 Temel Mantık

İndikatör, fiyatın ortalaması olan HL2 üzerine kuruludur:

Kaynak fiyat:
HL2 (High + Low) / 2
Üst bant:
HL2 × (1 + Yüzde / 100)
Alt bant:
HL2 × (1 - Yüzde / 100)

Bu yapı fiyat etrafında simetrik bir kanal oluşturur.

🔹 Mirror Yapısı

MATC, klasik bant sistemlerinden farklı olarak mirror (yansıtma) mantığı kullanır:

Orta eksen üst ve alt bandın ortalaması olarak hesaplanır
Kanal simetrik şekilde yeniden dağıtılır
“Mirror strength” katsayısı ile kanal genişleme/daralma dinamik hale getirilir

Bu yapı volatilite dönemlerinde daha stabil kanal davranışı sağlar.

🔹 Trend Tespiti

Trend yönü çift onaylı kırılım sistemi ile belirlenir:

Boğa trendi:
Fiyat üst mirror bandın üzerinde ardışık kapanışlar yapar
Ayı trendi:
Fiyat alt mirror bandın altında ardışık kapanışlar yapar

Trend, karşı yönlü onay gelene kadar korunur.

🔹 Yumuşatma Mekanizması

Gürültüyü azaltmak için bantlar EMA ile yumuşatılır:

EMA(alt mirror bant, length)
EMA(üst mirror bant, length)

Bu sayede daha temiz ve stabil bir yapı elde edilir.

🔹 Sinyal Üretimi
BUY sinyali: Ayı trendden boğa trende geçiş
SELL sinyali: Boğa trendden ayı trende geçiş

Sinyaller sadece trend değişiminde üretilir.

🔹 Öne Çıkan Özellikler
Mirror tabanlı simetrik kanal yapısı
Yüzde bazlı adaptif volatilite sistemi
EMA ile gürültü filtreleme
Sahte kırılım azaltan çift onay mekanizması
Temiz trend görselleştirme

## Source Code

````pine
//@version=5
indicator("Percent SuperTrend Mirror Filtered", overlay=true)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
percent   = input.float(2.0, title="Band Percent", step=0.1)
smoothLen = input.int(5, title="EMA Smooth")
mirrorStr = input.float(1.3, title="Mirror Strength (fake filter)", step=0.1)

//━━━━━━━━━━━━━━━━━━━
// SOURCE
//━━━━━━━━━━━━━━━━━━━
src = hl2

//━━━━━━━━━━━━━━━━━━━
// BASE BANDS
//━━━━━━━━━━━━━━━━━━━
upperBand = src * (1 + percent / 100)
lowerBand = src * (1 - percent / 100)

//━━━━━━━━━━━━━━━━━━━
// MIRROR CORE (midline symmetry)
//━━━━━━━━━━━━━━━━━━━
mid = (upperBand + lowerBand) / 2

dist = (upperBand - lowerBand) / 2

// mirror expansion / contraction
upperM = mid + dist * mirrorStr
lowerM = mid - dist * mirrorStr

//━━━━━━━━━━━━━━━━━━━
// TREND (FILTERED 2 STEP CONFIRM)
//━━━━━━━━━━━━━━━━━━━
var int trend = 1

breakUp   = close > upperM[1] and close > upperM[2]
breakDown = close < lowerM[1] and close < lowerM[2]

trend := breakUp ? 1 :
         breakDown ? -1 :
         trend[1]

//━━━━━━━━━━━━━━━━━━━
// SMOOTHED
//━━━━━━━━━━━━━━━━━━━
bullLine = ta.ema(lowerM, smoothLen)
bearLine = ta.ema(upperM, smoothLen)

trendLine = trend == 1 ? bullLine : bearLine

//━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━
fillColor  = trend == 1 ? color.new(color.lime, 88) : color.new(color.red, 88)
trendColor = trend == 1 ? color.lime : color.red

//━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━
p1 = plot(bullLine, color=color.lime, linewidth=1)
p2 = plot(bearLine, color=color.red, linewidth=1)

plot(trendLine, color=trendColor, linewidth=2)

fill(p1, p2, color=fillColor)

//━━━━━━━━━━━━━━━━━━━
// SIGNALS (clean + filtered)
//━━━━━━━━━━━━━━━━━━━
buySignal  = trend == 1 and trend[1] == -1
sellSignal = trend == -1 and trend[1] == 1

plotshape(buySignal, style=shape.labelup, text="BUY", location=location.belowbar, color=color.lime, textcolor=color.black, size=size.small)
plotshape(sellSignal, style=shape.labeldown, text="SELL", location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)
````
