# Mesut SMI  VWMA  Bollinger Alim Sinyali

- url: https://www.tradingview.com/script/2Cntmqt5/
- type: indicator
- pine_id: PUB;63179be83c6d4783805e1f2cd111c352
- version: 1.0

## Description

Tradingview sitesinde pine editöründe bir hissenin alım zamanını belirleyebilmek için bir kod yazmanı istiyorum. Kullanmak istediğim göstergeler ise şunlar: stokastik momentum endeksi, hacim ağırlıklı hareketli ortalama ve bollinger bantları. Hacim ağırlıklı hareketli ortalamayı stokastik momentum endeksi üzerine özel gösterge olarak atamak istiyorum ve bu göstergenin girdileri ise şöyle olmalı: uzunluk:7 kaynak: SMI: SMI ve uzantı: 0

Bir hissenin alım sinyali verebilmesi için koşullar ise şöyle:

1.      Koşul :  stokastik momentum endeksindeki SMI çizgisi SMI-based EMA çizgisinin üstünde olmalı ve bu durum 0 çizgisinin altında gerçekleşmeli.
2.      Koşul: hisse al sinyali verdikten sonra SMI çizgisi hacim ağırlıklı hareketli ortalamanın üstünde olmalı
3.      Koşul: hisse al sinayli verdikten sonra hissenin fiyatı bollinger bandının orta orta kanalının üstünde olması lazım.

Bu üç kuralında gerçekleştiği yerler bir hisse için alım fırsatıdır.

## Source Code

````pine
//@version=5
indicator("SMI + VWMA + Bollinger Alım Sinyali", overlay=true)

smiLength = input.int(5, "SMI Length")
smiSmoothK = input.int(3, "SMI Smooth K")
smiSmoothD = input.int(3, "SMI Smooth D")
smiEmaLength = input.int(3, "SMI EMA Length")

hh = ta.highest(high, smiLength)
ll = ta.lowest(low, smiLength)

mid = (hh + ll) / 2
diff = close - mid
rangeHL = hh - ll

diffEma = ta.ema(ta.ema(diff, smiSmoothK), smiSmoothD)
rangeEma = ta.ema(ta.ema(rangeHL, smiSmoothK), smiSmoothD)

smi = rangeEma != 0 ? 100 * diffEma / (rangeEma / 2) : 0
smiEma = ta.ema(smi, smiEmaLength)

// SMI üzerine VWMA
smiVwmaLength = input.int(7, "SMI VWMA Length")
smiVwma = ta.vwma(smi, smiVwmaLength)

// Bollinger Bands
bbLength = input.int(20, "BB Length")
bbMult = input.float(2.0, "BB StdDev")

bbMiddle = ta.sma(close, bbLength)
bbDev = ta.stdev(close, bbLength)

bbUpper = bbMiddle + bbMult * bbDev
bbLower = bbMiddle - bbMult * bbDev

// Alım Koşulları
condition1 = smi > smiEma and smi < 0 and smiEma < 0
condition2 = smi > smiVwma
condition3 = close > bbMiddle

buySignal = condition1 and condition2 and condition3

plot(bbMiddle, title="BB Middle", color=color.orange)
plot(bbUpper, title="BB Upper", color=color.gray)
plot(bbLower, title="BB Lower", color=color.gray)

plotshape(buySignal, title="AL", text="AL", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)

alertcondition(buySignal, title="AL Sinyali", message="SMI + VWMA + Bollinger alım sinyali oluştur")
````
