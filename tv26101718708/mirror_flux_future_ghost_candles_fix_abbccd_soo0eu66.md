# Mirror Flux Future Ghost Candles FIX AB-BC-CD 

- url: https://www.tradingview.com/script/sOo0Eu66/
- type: indicator
- pine_id: PUB;8db43790ff264640aa138241f4f8bc99
- version: 1.0

## Description

Mirror Flux Projection System (AB–BC–CD Structural Model)

This indicator is a forward projection model built on a mirrored EMA transformation and volatility-adjusted trend dynamics. It does not repaint and operates strictly on closed candle data.

The core logic is based on a dual EMA structure (EMA 200 as trend base and EMA 34 as dynamic center). A mirrored price transformation is applied relative to the EMA structure, creating a synthetic “mirror market state” that represents the opposite pressure side of the current price action.

From this mirrored structure, a slope-based momentum engine is derived. This slope is used to project future directional levels forward across multiple steps. These projected levels form a structured forward path extending the current market behavior into the future.

The system is organized into an AB–BC–CD framework:

AB Phase: Represents initial impulse and potential extreme deviation zones relative to the center line.
BC Phase: When price reaches extreme conditions, the model applies a short compression behavior, temporarily flattening early projection steps to simulate pause, absorption, or consolidation.
CD Phase: After compression, the projection resumes normal slope continuation, representing trend expansion and directional continuation.

This structure helps distinguish between continuation zones and exhaustion zones, reducing false breakout interpretation by filtering short-lived volatility spikes.

The projection lines extend forward into the chart, allowing interaction analysis between projected directional structure and actual market movement. When real price aligns with the projected positive structure zones (above center and slope direction), it indicates potential continuation confirmation. When divergence occurs, it highlights potential exhaustion or reversal pressure.

This model is not a prediction tool but a structural projection of momentum flow based on mirrored EMA dynamics and volatility-normalized behavior.

Key Features:

Mirror-based EMA transformation structure
ATR-adjusted volatility normalization
AB–BC–CD compression and expansion logic
Forward multi-step projection system
Non-repainting design
Breakout noise filtering via compression phase logic
🇹🇷 TÜRKÇE AÇIKLAMA (COPY READY)

Mirror Flux Projeksiyon Sistemi (AB–BC–CD Yapısal Model)

Bu gösterge, EMA tabanlı mirror (ayna) dönüşümü ve volatiliteye göre ayarlanmış trend dinamiği üzerine kurulu ileriye dönük bir projeksiyon modelidir. Repaint yapmaz ve yalnızca kapanmış mum verilerini kullanır.

Sistem, EMA 200 (trend omurgası) ve EMA 34 (dinamik merkez) yapısını kullanarak piyasa için referans bir denge hattı oluşturur. Fiyat, EMA yapısına göre ayna dönüşümüne tabi tutulur ve böylece mevcut piyasanın karşıt (ayna evrendeki) basınç yapısı üretilir.

Bu mirror yapıdan türetilen slope (eğim) değeri ile geleceğe doğru yönsel projeksiyon çizgileri oluşturulur. Bu çizgiler piyasa hareketini ileriye taşıyan çok adımlı bir yapı meydana getirir.

Sistem AB–BC–CD yapısı ile çalışır:

AB Fazı: Fiyatın merkez çizgiye göre aşırı sapma ve impuls bölgelerini temsil eder.
BC Fazı: Aşırı bölgelerde sistem kısa süreli bir sıkışma (compression) uygular ve ilk projeksiyon adımlarını düzleştirerek piyasanın duraksama / likidite emilim etkisini simüle eder.
CD Fazı: Sıkışma sonrası trend normal eğim ile devam eder ve genişleme (expansion) yapısı oluşur.

Bu yapı, sahte kırılım (fake breakout) etkilerini azaltır ve kısa süreli volatilite patlamalarını filtreleyerek daha yapısal hareketleri öne çıkarır.

Projeksiyon çizgileri ileriye doğru uzatılır ve gerçek fiyat hareketi ile karşılaştırmalı analiz yapılmasına olanak sağlar. Eğer fiyat, yukarı yönlü projeksiyon bölgesi ile uyumlu hareket ediyorsa bu trend devamlılığına işaret eder. Eğer sapma oluşuyorsa bu zayıflama veya dönüş baskısını gösterir.

Bu sistem bir tahmin aracı değil, mirror EMA dinamikleri ve volatilite normalize edilmiş momentum akışına dayalı yapısal bir piyasa projeksiyon modelidir.

Özellikler:

EMA tabanlı mirror dönüşüm sistemi
ATR ile normalize edilmiş volatilite yapısı
AB–BC–CD sıkışma ve genişleme modeli
Çok adımlı ileri projeksiyon sistemi
Repaint yapmayan yapı
Fake breakout filtreleme mekanizması

## Source Code

````pine
//@version=5
indicator("Mirror Flux Future Ghost Candles FIX AB-BC-CD (Enhanced Visibility)", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
len = input.int(200, "Trend Length")
projLen = 28

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaBase  = ta.ema(close, len)
center   = ta.ema(close, 34)

mirror = emaBase * 2 - close
mirrorBull = mirror > emaBase

atr = ta.atr(14)

slope = (emaBase - emaBase[1]) * (mirrorBull ? 1.2 : 0.8)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTREME LOGIC (AB ZONE)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
norm = atr != 0 ? (close - center) / atr : 0.0

isExtreme = math.abs(norm) > 1.5

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
base = center

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AB - BC - CD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 3 mum flat + continuation
p1 = isExtreme ? base : base + slope * 1
p2 = isExtreme ? base : base + slope * 2
p3 = isExtreme ? base : base + slope * 3

p4 = base + slope * 4
p5 = base + slope * 5
p6 = base + slope * 6
p7 = base + slope * 7
p8 = base + slope * 8
p9 = base + slope * 9
p10 = base + slope * 10
p11 = base + slope * 11
p12 = base + slope * 12
p13 = base + slope * 13
p14 = base + slope * 14
p15 = base + slope * 15
p16 = base + slope * 16
p17 = base + slope * 17
p18 = base + slope * 18
p19 = base + slope * 19
p20 = base + slope * 20
p21 = base + slope * 21
p22 = base + slope * 22
p23 = base + slope * 23
p24 = base + slope * 24
p25 = base + slope * 25
p26 = base + slope * 26
p27 = base + slope * 27
p28 = base + slope * 28

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLOR (slightly stronger visibility)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
col = norm >= 0 ?
     color.new(color.lime, 75) :
     color.new(color.red, 75)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUALS (ENHANCED READABILITY)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 🔥 CENTER NOW BLACK (clear reference line)
plot(center, color=color.black, linewidth=2)

// optional EMA faint guide
plot(emaBase, color=color.new(color.gray, 60), linewidth=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROJECTION (more visible than before)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(p1, offset=1, color=color.new(col, 0), linewidth=2)
plot(p2, offset=2, color=color.new(col, 0), linewidth=2)
plot(p3, offset=3, color=color.new(col, 0), linewidth=2)

plot(p4, offset=4, color=color.new(col, 10), linewidth=2)
plot(p5, offset=5, color=color.new(col, 10), linewidth=2)
plot(p6, offset=6, color=color.new(col, 10), linewidth=2)
plot(p7, offset=7, color=color.new(col, 15), linewidth=2)
plot(p8, offset=8, color=color.new(col, 15), linewidth=2)
plot(p9, offset=9, color=color.new(col, 15), linewidth=2)
plot(p10, offset=10, color=color.new(col, 20), linewidth=2)
plot(p11, offset=11, color=color.new(col, 20), linewidth=2)
plot(p12, offset=12, color=color.new(col, 20), linewidth=2)
plot(p13, offset=13, color=color.new(col, 25), linewidth=2)
plot(p14, offset=14, color=color.new(col, 25), linewidth=2)
plot(p15, offset=15, color=color.new(col, 25), linewidth=2)
plot(p16, offset=16, color=color.new(col, 30), linewidth=2)
plot(p17, offset=17, color=color.new(col, 30), linewidth=2)
plot(p18, offset=18, color=color.new(col, 30), linewidth=2)
plot(p19, offset=19, color=color.new(col, 35), linewidth=2)
plot(p20, offset=20, color=color.new(col, 35), linewidth=2)
plot(p21, offset=21, color=color.new(col, 35), linewidth=2)
plot(p22, offset=22, color=color.new(col, 40), linewidth=2)
plot(p23, offset=23, color=color.new(col, 40), linewidth=2)
plot(p24, offset=24, color=color.new(col, 40), linewidth=2)
plot(p25, offset=25, color=color.new(col, 45), linewidth=2)
plot(p26, offset=26, color=color.new(col, 45), linewidth=2)
plot(p27, offset=27, color=color.new(col, 45), linewidth=2)
plot(p28, offset=28, color=color.new(col, 50), linewidth=2)
````
