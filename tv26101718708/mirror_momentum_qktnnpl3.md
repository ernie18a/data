#  Mirror Momentum

- url: https://www.tradingview.com/script/QKTNNPL3/
- type: indicator
- pine_id: PUB;6406653de21d49f5af5f9c5fabdccde2
- version: 1.0

## Description

This indicator uses a mirror-based momentum structure built on an adaptive center axis.

Unlike traditional inverted indicators that simply negate price or apply static transformations, this model introduces a dynamic reflection mechanism:

Price is mirrored around a moving EMA-based center
This creates an adaptive reflection axis that evolves with market structure
The mirrored signal is then combined with smoothed momentum
mirrorMomentum = (2 * (center - price)) + momentum
Core Components
Symmetry mapping (reflection around a dynamic center)
Momentum injection (trend force embedded into the mirrored structure)
Adaptive distortion (volatility reshaping the mirror behavior)

This results in a dual-sided momentum oscillator that captures both directional movement and its reflected pressure.

It is not a simple inverse price oscillator, but a center-based adaptive mirrored momentum system.

Structural Interpretation (Important)

The indicator evaluates the distance (spread) between momentum and its mirrored structure as a measure of internal trend strength.

Wide separation between lines → strong trend expansion (trend continuation phase)
Narrowing of the lines → compression phase (trend exhaustion or potential reversal zone)

In addition, extreme wide expansion zones often correspond to major tops and bottoms, meaning that signals tend to behave more reliably within trending conditions.

Therefore, signals are generally more suitable for trend-following confirmation rather than standalone prediction, and the structure is better interpreted visually for identifying potential reversal zones.

🇹🇷 Türkçe Açıklama

Bu indikatör, dinamik merkez ekseni üzerine kurulu mirror (ayna) tabanlı bir momentum yapısı kullanır.

Klasik tersleme indikatörlerinden farklı olarak (sadece fiyatı negatiflemek veya sabit çevirme yapmak gibi), bu model adaptif bir yansıma mekanizması içerir:

Fiyat, EMA tabanlı hareketli bir merkez etrafında yansıtılır
Bu sayede piyasa yapısına göre değişen bir “dinamik ayna ekseni” oluşur
Daha sonra bu yansıma, momentum ile birleştirilir
mirrorMomentum = (2 * (center - price)) + momentum
Temel Bileşenler
Simetri haritalaması (dinamik merkez etrafında yansıma)
Momentum enjeksiyonu (trend gücünün yapıya eklenmesi)
Adaptif bozulma (volatiliteye göre şekil değiştiren ayna davranışı)

Bu yapı, hem yönü hem de karşıt hareketi yakalayan çift taraflı bir momentum osilatörü üretir.

Bu sistem klasik “inverse price” indikatörü değildir; merkez bazlı adaptif mirror momentum yapısıdır.

Yapısal Yorum (Önemli)

İndikatör, momentum ile mirror yapı arasındaki mesafeyi (spread’i) trend gücü olarak yorumlar.

Çizgilerin geniş açılması → güçlü trend genişlemesi (trend devam fazı)
Çizgilerin daralması → sıkışma (zayıflama / olası dönüş bölgesi)

Ayrıca en geniş açılma bölgeleri genellikle majör tepe ve dip bölgelerine denk gelir, bu yüzden sinyaller trend koşullarında daha sağlıklı çalışır.

Bu yapı, tek başına tahmin aracı olmaktan çok trend takibi ve görsel analiz için daha uygundur, özellikle dönüş bölgelerini gözle okumak için güçlü bir yapı sunar.

## Source Code

````pine
//@version=5
indicator("MATC Mirror Momentum", overlay=false, max_lines_count=500)

//--------------------------------------------------
// INPUTS
//--------------------------------------------------
length      = input.int(34,  "Momentum Length", minval=1)
smoothLen   = input.int(8,   "Smoothing", minval=1)
centerLen   = input.int(55,  "Center Axis Length", minval=1)

showFill    = input.bool(true, "Show Resonance Fill")
showSignals = input.bool(true, "Show Cross Signals")

//--------------------------------------------------
// BASE MOMENTUM
//--------------------------------------------------
basePrice = close
center    = ta.ema(basePrice, centerLen)

momentumRaw = basePrice - ta.ema(basePrice, length)
momentum    = ta.ema(momentumRaw, smoothLen)

//--------------------------------------------------
// MIRROR MOMENTUM
//--------------------------------------------------
mirrorMomentum = (2 * (center - basePrice)) + momentum
mirrorSmooth   = ta.ema(mirrorMomentum, smoothLen)

//--------------------------------------------------
// SIGNALS
//--------------------------------------------------
bullCross = ta.crossover(momentum, mirrorSmooth)
bearCross = ta.crossunder(momentum, mirrorSmooth)

//--------------------------------------------------
// COLORS
//--------------------------------------------------
momColor    = momentum >= mirrorSmooth ? color.lime : color.red
mirrorColor = mirrorSmooth <= momentum ? color.aqua : color.orange

//--------------------------------------------------
// PLOTS (IMPORTANT: MUST BE GLOBAL)
//--------------------------------------------------
p1 = plot(momentum, title="Momentum", color=momColor, linewidth=2)
p2 = plot(mirrorSmooth, title="Mirror Momentum", color=mirrorColor, linewidth=2)

//--------------------------------------------------
// FILL (SAFE VERSION)
//--------------------------------------------------
fillColor = showFill ? (momentum > mirrorSmooth ? color.new(color.lime, 88)
                                                 : color.new(color.red, 88))
                     : na

fill(p1, p2, color=fillColor)

//--------------------------------------------------
// SIGNALS
//--------------------------------------------------
plotshape(showSignals and bullCross,
     title="Bullish Cross",
     style=shape.circle,
     location=location.bottom,
     color=color.lime,
     size=size.tiny)

plotshape(showSignals and bearCross,
     title="Bearish Cross",
     style=shape.circle,
     location=location.top,
     color=color.red,
     size=size.tiny)

//--------------------------------------------------
// BACKGROUND
//--------------------------------------------------
````
