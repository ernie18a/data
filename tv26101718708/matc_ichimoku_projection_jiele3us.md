# MATC +  Ichimoku Projection 

- url: https://www.tradingview.com/script/JIelE3US/
- type: indicator
- pine_id: PUB;0d0fd6f25bf04684bc9a9a35bde0d3ef
- version: 1.0

## Description

📌 MATC ICHIMOKU PROJECTION — SYSTEM DESCRIPTION (ENGLISH)

MATC Ichimoku Projection is a hybrid market structure and momentum system that combines a custom mathematical trend engine (MATC) with a projected Ichimoku Cloud model to detect high-probability breakout zones.

The system does not rely on a single indicator. Instead, it builds a multi-layer confirmation model using trend structure, volatility expansion, and projected equilibrium zones.

🔷 1. MATC STRUCTURE (Market Adaptive Trend Calculation)

MATC is a dynamic band-based trend engine built on:

Percentage-based upper/lower deviation from price
Smoothed mirror expansion of volatility
EMA-based stabilization of structural levels

This creates:

Dynamic resistance
Dynamic support
Midline equilibrium

MATC interprets market compression and expansion cycles mathematically, rather than using static indicators.

🔷 2. ICHIMOKU PROJECTION CLOUD

Instead of traditional Ichimoku interpretation, this system uses a projected cloud state:

Span A = (Tenkan + Kijun) / 2
Span B = highest/lowest range equilibrium

The cloud is used not as lagging support/resistance, but as a:

🔹 Future regime filter (bull or bear probability zone)

🔷 3. STRONG BUY LOGIC (PROBABILITY EVENT)

A Strong Buy signal is generated only when two independent systems align:

✔ MATC Breakout Condition

Price must break above MATC resistance:

This confirms structural expansion
✔ Ichimoku Bull Regime
Span A > Span B (green cloud state)
Indicates bullish future market structure
✔ Combined Confirmation

A Strong Buy occurs only when:

MATC breakout AND Ichimoku green regime align

This creates a dual-projection confirmation system, reducing false signals significantly.

🔷 4. SINGLE EVENT PER CLOUD CYCLE

To avoid overtrading and duplicate signals:

Each Ichimoku green cloud phase generates only one Strong Buy
Signal reset occurs only when a new cloud regime begins

This ensures:

One institutional-style confirmation per market expansion phase

🔷 5. SYSTEM CHARACTERISTICS

This model is:

✔ Non-repainting in logic structure
✔ Regime-based (trend + future projection)
✔ Volatility adaptive
✔ Designed for breakout confirmation rather than prediction
✔ Built to reduce fake breakouts via dual confirmation
⚠️ LIMITATIONS / DISCLAIMER

Like all technical systems, MATC Ichimoku Projection:

Does not guarantee accuracy
Can generate false signals in low-volume or choppy markets
Works best in trending or expanding volatility environments
Should be used with risk management filters
📌 CONCLUSION

MATC Ichimoku Projection is a dual-layer market intelligence system combining:

Structural trend mathematics (MATC)
Future probability cloud modeling (Ichimoku Projection)

The goal is not to predict the market, but to identify:

“Where probability of expansion becomes statistically dominant”

📌 MATC ICHIMOKU PROJEKSİYON — SİSTEM AÇIKLAMASI (TÜRKÇE)

MATC Ichimoku Projection, özel bir matematiksel trend yapısı (MATC) ile projeksiyon Ichimoku Bulutu’nun birleştirildiği hibrit bir piyasa analiz sistemidir.

Sistem tek bir indikatöre dayanmaz. Bunun yerine çok katmanlı doğrulama modeli kullanır:

Trend yapısı
Volatilite genişlemesi
Gelecek rejim tahmini
🔷 1. MATC YAPISI (Piyasa Adaptif Trend Hesaplama)

MATC sistemi şu matematiksel yapıya dayanır:

Fiyatın yüzde bazlı üst/alt bandı
Volatiliteye göre genişleyen mirror yapı
EMA ile yumuşatılmış trend seviyeleri

Sonuç olarak:

Dinamik destek
Dinamik direnç
Orta denge (midline)

MATC, piyasayı sabit çizgilerle değil:

genişleme ve sıkışma döngüleriyle matematiksel olarak okur

🔷 2. ICHIMOKU PROJEKSİYON BULUTU

Klasik Ichimoku yerine burada:

Span A = Tenkan + Kijun ortalaması
Span B = yüksek/düşük denge bölgesi

Bulut artık gecikmeli değil:

🔹 “gelecek piyasa rejimi filtresi” olarak kullanılır

🔷 3. STRONG BUY MANTIĞI (PROBABILİTY EVENT)

Strong Buy sinyali sadece iki sistem aynı anda doğrulama verdiğinde oluşur:

✔ MATC kırılımı

Fiyat MATC direncini yukarı kırar

✔ Ichimoku yeşil rejim

Span A > Span B

✔ birleşik doğrulama

İki sistem aynı anda bullish rejim üretir

Bu yapı:

çift projeksiyonlu doğrulama sistemi oluşturur

🔷 4. HER BULUTTA TEK SİNYAL

Aynı bölgede tekrar sinyal üretmemek için:

Her yeşil bulutta sadece 1 STRONG BUY
Yeni bulut başladığında reset

Bu sayede:

“kurumsal tek onay sistemi” davranışı oluşur

🔷 5. SİSTEM ÖZELLİKLERİ
✔ Repaint mantığına karşı filtrelenmiş yapı
✔ Trend + gelecek rejim sistemi
✔ Volatilite adaptif
✔ Breakout odaklı
✔ Fake sinyalleri azaltmak için çift doğrulama
⚠️ SINIRLAR
Her sistem gibi %100 doğruluk garanti etmez
Yatay piyasalarda false signal üretebilir
Trend ve hacimle birlikte kullanılması önerilir

## Source Code

````pine
//@version=5
indicator("MATC + Hidden Ichimoku Projection PRO (Clean STRONG SELL)", overlay=true, max_bars_back=500)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
percent   = input.float(2.0, title="Band Percent", step=0.1)
smoothLen = input.int(5, title="Smoothing Length")
projBars  = input.int(10, title="Projection Bars")
mirrorStr = input.float(1.3, title="Mirror Strength")
buffer    = input.float(0.15, title="Break Buffer %")

tenkanLen = input.int(9, title="Tenkan Length")
kijunLen  = input.int(26, title="Kijun Length")
spanBLen  = input.int(52, title="Span B Length")

//━━━━━━━━━━━━━━━━━━━
// SOURCE
//━━━━━━━━━━━━━━━━━━━
src = hl2

//━━━━━━━━━━━━━━━━━━━
// MATC STRUCTURE
//━━━━━━━━━━━━━━━━━━━
upper = src * (1 + percent / 100)
lower = src * (1 - percent / 100)

mid  = (upper + lower) / 2
dist = (upper - lower) / 2

upperM = mid + dist * mirrorStr
lowerM = mid - dist * mirrorStr

resistance = ta.ema(upperM, smoothLen)
support    = ta.ema(lowerM, smoothLen)
midline    = (resistance + support) / 2

//━━━━━━━━━━━━━━━━━━━
// BREAK LOGIC
//━━━━━━━━━━━━━━━━━━━
buf = buffer / 100

bullBreak = close > resistance * (1 + buf)
bearBreak = close < support * (1 - buf)

//━━━━━━━━━━━━━━━━━━━
// TREND STATE
//━━━━━━━━━━━━━━━━━━━
var int trend = 1

trend := bullBreak ? 1 :
         bearBreak ? -1 :
         trend

//━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━
buySignal =
     trend == 1 and
     trend[1] == -1

sellSignal =
     trend == -1 and
     trend[1] == 1

//━━━━━━━━━━━━━━━━━━━
// ICHIMOKU CLOUD (HIDDEN)
//━━━━━━━━━━━━━━━━━━━
tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2
kijun  = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2

spanA = (tenkan + kijun) / 2
spanB = (ta.highest(high, spanBLen) + ta.lowest(low, spanBLen)) / 2

futureBull = spanA > spanB
futureBear = spanA < spanB

//━━━━━━━━━━━━━━━━━━━
// VISUALS
//━━━━━━━━━━━━━━━━━━━
pRes = plot(resistance, color=trend == 1 ? color.lime : color.new(color.lime, 40), linewidth=2)
pSup = plot(support, color=trend == -1 ? color.red : color.new(color.red, 40), linewidth=2)
pMid = plot(midline, color=color.new(color.gray, 70), linewidth=1)

//━━━━━━━━━━━━━━━━━━━
// PROJECTION
//━━━━━━━━━━━━━━━━━━━
pFres = plot(resistance, offset=projBars, color=trend == 1 ? color.new(color.lime, 35) : color.new(color.lime, 80), linewidth=2)
pFsup = plot(support, offset=projBars, color=trend == -1 ? color.new(color.red, 35) : color.new(color.red, 80), linewidth=2)

fill(pRes, pFres, color=trend == 1 ? color.new(color.lime, 82) : color.new(color.lime, 94))
fill(pSup, pFsup, color=trend == -1 ? color.new(color.red, 82) : color.new(color.red, 94))
fill(pRes, pMid, color=color.new(color.gray, 92))
fill(pMid, pSup, color=color.new(color.gray, 92))

//━━━━━━━━━━━━━━━━━━━
// STRONG BUY
//━━━━━━━━━━━━━━━━━━━
var bool strongBuyUsed = false

newBullCloud = futureBull and not futureBull[1]

if newBullCloud
    strongBuyUsed := false

strongBuy =
     not strongBuyUsed and
     futureBull and
     ta.crossover(close, resistance)

if strongBuy
    strongBuyUsed := true

//━━━━━━━━━━━━━━━━━━━
// STRONG SELL (FIXED PRO VERSION)
//━━━━━━━━━━━━━━━━━━━
var bool strongSellUsed = false

newBearCloud = futureBear and not futureBear[1]

if newBearCloud
    strongSellUsed := false

strongSell =
     not strongSellUsed and
     futureBear and
     trend == -1 and
     ta.crossunder(close, support) and
     close < support and
     close[1] < support[1]

if strongSell
    strongSellUsed := true

//━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━
plotshape(buySignal, title="BUY", style=shape.labelup, location=location.belowbar, text="BUY", color=color.lime, textcolor=color.black, size=size.small)

plotshape(sellSignal, title="SELL", style=shape.labeldown, location=location.abovebar, text="SELL", color=color.red, textcolor=color.white, size=size.small)

plotshape(strongBuy, title="STRONG BUY", style=shape.labelup, location=location.belowbar, text="STRONG BUY", color=color.aqua, textcolor=color.black, size=size.large)

plotshape(strongSell, title="STRONG SELL", style=shape.labeldown, location=location.abovebar, text="STRONG SELL", color=color.fuchsia, textcolor=color.white, size=size.large)
````
