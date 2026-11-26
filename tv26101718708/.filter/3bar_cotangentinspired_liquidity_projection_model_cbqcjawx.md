# 3-Bar Cotangent-Inspired Liquidity Projection Model

- url: https://www.tradingview.com/script/CbQCjAWx/
- type: indicator
- pine_id: PUB;dd348f7433b847258e933c8b0fea381b
- version: 1.0

## Description

3-Bar Cotangent-Inspired Liquidity Projection Model

This indicator is a hybrid market structure and forward projection system built on a 3-candle analytical framework combined with volatility, momentum, and liquidity anchoring.

It does not use predictive assumptions, but rather constructs probabilistic forward zones based on real market microstructure.

📊 Core Logic (3-Candle Structure)

The system is built on three consecutive candles:

Base Candle (t-2)
Defines the structural liquidity reference (high/low anchor zone)
Expansion Candle (t-1)
Measures directional pressure by comparing range expansion relative to the base candle
Confirmation Candle (t)
Evaluates whether price remains within the base liquidity zone or rejects it
⚙️ Calculations

The projection engine combines:

ATR-based volatility scaling
Volume-weighted momentum pressure
Distance from liquidity anchor (Order Block-like structure)
Cotangent-inspired angular velocity approximation:

cot(θ)=
tan(θ)
1
	​


Pressure Ratio:
Pressure=
Base Range
Expansion Range
	​

Forward projection zone:
Projection=Price±(ATR⋅f(Pressure,Momentum))
📈 Visualization
Green line = bullish forward guide path
Red line = bearish forward guide path
Blue cloud = projected price equilibrium zone

The cloud is drawn ahead of price action, representing a probabilistic future range rather than a fixed prediction.

Guide lines act as directional structure guides, while the cloud defines potential volatility expansion areas.

🧠 Market Interpretation
Price above cloud = bullish expansion regime
Price below cloud = bearish expansion regime
Inside cloud = equilibrium / compression zone

The slope of the projection is dynamically influenced by the 3-bar structure, meaning momentum shifts directly affect the angle of forward projection.

⚠️ Important Note

This is not a signal generator in isolation.
It is a structural projection framework designed to visualize liquidity expansion, compression, and directional probability zones.

🇹🇷 TÜRKÇE AÇIKLAMA

3-Mum Kotanjan Esinli Likidite Projeksiyon Modeli

Bu gösterge, 3 mumluk yapı üzerine kurulmuş, volatilite, momentum ve likidite referanslarını birleştiren hibrit bir piyasa projeksiyon sistemidir.

Tahmin yapmaz; bunun yerine piyasanın mikro yapısına göre ileriye dönük olasılık bölgeleri oluşturur.

📊 Temel Mantık (3 Mum Yapısı)

Sistem üç mum üzerinden çalışır:

Baz Mum (t-2)
Likidite referans alanını (tepe/dip bölgesi) belirler
Genişleme Mumu (t-1)
Baz mumuna göre fiyatın genişleme gücünü ölçer
Onay Mumu (t)
Fiyatın baz likidite bölgesinde kalıp kalmadığını analiz eder
⚙️ Hesaplamalar

Sistem şu bileşenleri kullanır:

ATR bazlı volatilite ölçekleme
Hacim + momentum gücü
Likidite (OB benzeri) mesafe etkisi
Kotanjan tabanlı eğim yaklaşımı:

cot(θ)=
tan(θ)
1
	​


Basit güç oranı:
G
u
¨
c
\c
	​

=
Baz Aralık
Geni
s
\c
	​

leme Aralı
g
˘
	​

ı
	​

İleri projeksiyon:
Projeksiyon=Fiyat±(ATR⋅momentum fonksiyonu)
📈 Görselleştirme
Yeşil çizgi = yukarı yönlü proje yolu
Kırmızı çizgi = aşağı yönlü proje yolu
Mavi bulut = ileriye dönük fiyat olasılık bölgesi

Bulut, fiyatın gelecekte bulunabileceği olası denge alanını temsil eder.

🧠 Piyasa Yorumu
Fiyat bulut üstü = güçlü yükseliş rejimi
Fiyat bulut altı = güçlü düşüş rejimi
Bulut içi = sıkışma / denge bölgesi

Projeksiyon açısı 3 mum yapısına bağlı olarak değişir, yani momentum arttıkça ileri yön eğimi de artar.

⚠️ Önemli Not

Bu sistem tek başına al-sat sinyali değildir.
Likidite, momentum ve volatilite yapısını ileriye taşıyan görsel bir piyasa modelidir.

## Source Code

````pine
//@version=5
indicator("Forward Projection Only (Clean)", overlay=true)

//━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━
obLen   = input.int(10, "Order Block Lookback")
atrLen  = input.int(14, "ATR Length")
smooth  = input.int(5, "Smoothing")
k       = input.float(2.0, "Strength")
projLen = input.int(20, "Forward Length")

//━━━━━━━━━━━━━━━━━━
// CORE (STILL USED FOR PROJECTION)
//━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)

//━━━━━━━━━━━━━━━━━━
// ORDER BLOCK (ANCHOR ONLY)
//━━━━━━━━━━━━━━━━━━
bullOB = low == ta.lowest(low, obLen) and close > open
bearOB = high == ta.highest(high, obLen) and close < open

var float ob = na

if bullOB
    ob := low
else if bearOB
    ob := high
else
    ob := nz(ob, close)

//━━━━━━━━━━━━━━━━━━
// DISTANCE FIELD
//━━━━━━━━━━━━━━━━━━
dist = math.abs(close - ob)
dist := math.max(dist, syminfo.mintick)

//━━━━━━━━━━━━━━━━━━
// COT STYLE CORE
//━━━━━━━━━━━━━━━━━━
theta = math.atan(close - close[1])
cot = math.abs(math.tan(theta)) > 0.0001 ? 1 / math.tan(theta) : 0

momentum = math.abs(close - close[1])
power    = volume * (high - low)

G = (momentum * power) / (dist * dist)

wave = ta.ema(math.sin(G) + cot, smooth)

//━━━━━━━━━━━━━━━━━━
// FORWARD PROJECTION ONLY
//━━━━━━━━━━━━━━━━━━
force = wave * atr * k

projUp = close + force
projDn = close - force

//━━━━━━━━━━━━━━━━━━
// GUIDE LINES (FORWARD ONLY)
//━━━━━━━━━━━━━━━━━━
var line upGuide = na
var line dnGuide = na

if bar_index > 1
    if not na(upGuide)
        line.delete(upGuide)
    if not na(dnGuide)
        line.delete(dnGuide)

    upGuide := line.new(bar_index, close, bar_index + projLen, projUp, color=color.green, width=2)
    dnGuide := line.new(bar_index, close, bar_index + projLen, projDn, color=color.red, width=2)

//━━━━━━━━━━━━━━━━━━
// FORWARD CLOUD ONLY
//━━━━━━━━━━━━━━━━━━
pUp = plot(projUp, offset=projLen, color=color.new(color.green, 0))
pDn = plot(projDn, offset=projLen, color=color.new(color.red, 0))

fill(pUp, pDn, color=color.new(color.blue, 85))
````
