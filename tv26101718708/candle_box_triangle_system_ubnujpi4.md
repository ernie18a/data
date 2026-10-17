# Candle Box Triangle System

- url: https://www.tradingview.com/script/UbnUjpi4/
- type: indicator
- pine_id: PUB;7191e133b08c4373995fd300b4c0ed34
- version: 1.0

## Description

Mirror EMA Triangle System V2 CLEAN

This indicator is a structured market framework built on a 3-candle micro-structure model combined with EMA trend filtering, ATR volatility validation, and mirror deviation logic.

🔷 Core Logic

The system identifies directional momentum using a 3-candle sequence:

Higher highs and higher closes define bullish structure
Lower highs and lower closes define bearish structure

Each valid structure is filtered through:

EMA 50 trend direction (market bias)
ATR-based volatility threshold (movement strength validation)
Mirror distance filter (price deviation from equilibrium)
🔺 Triangle Formation Model

Every valid signal forms a 3-point geometric structure (triangle block):

c1 → c2 → c3 create a micro market cycle
This triangle represents short-term momentum compression and expansion

Inside each triangle:

Price acceleration is measured
Weak structures are filtered out
Only “valid momentum triangles” generate signals
🟦 Breakout Zone Logic (Box Structure)

Each triangle generates a zone (box) based on:

High/Low range of the last 3 candles

These zones act as market reference levels:

Bull zones = potential support areas
Bear zones = potential resistance areas
📈 Support / Resistance Behavior
When price respects the upper breakout level, it acts as support
When broken upward, it indicates continuation and structural shift
When broken downward, bearish continuation is expected

These levels are not static lines, but dynamic structural reference zones

🎯 Projection Logic

Forward projection lines estimate:

Expected continuation direction
Volatility-adjusted target movement using ATR expansion

These projections are not predictions, but probabilistic market path expectations based on recent momentum energy.

🧠 Market Interpretation
Triangles = momentum formation
Boxes = institutional reaction zones
EMA filter = trend bias confirmation
Projection = expected displacement path
🇹🇷 TÜRKÇE AÇIKLAMA

Mirror EMA Triangle System V2 CLEAN

Bu gösterge, 3 mumluk mikro yapı modeli üzerine kurulu; EMA trend filtresi, ATR volatilite kontrolü ve mirror (denge sapması) mantığı ile desteklenen yapısal bir piyasa analiz sistemidir.

🔷 Temel Mantık

Sistem fiyat hareketini 3 mum üzerinden analiz eder:

Yükselen yapılar = yükseliş momentumu
Düşen yapılar = düşüş momentumu

Bu yapı şu filtrelerden geçer:

EMA 50 trend yönü
ATR ile hareket gücü kontrolü
Fiyatın EMA’dan sapma mesafesi (mirror filtre)
🔺 Üçgen Yapı Modeli

Her sinyal 3 noktalı bir geometrik yapı oluşturur:

c1 → c2 → c3 = piyasa mikro döngüsü

Bu üçgen yapı:

Momentum sıkışması ve açılmasını temsil eder
Zayıf hareketleri eler
Sadece güçlü yapılar sinyal üretir
🟦 Kutu (Zone) Mantığı

Her üçgen sonrası oluşan kutu:

Son 3 mumun yüksek/düşük aralığıdır

Bu bölgeler:

Yükselişte destek alanı gibi çalışır
Düşüşte direnç alanı gibi çalışır
📈 Destek / Direnç Davranışı
Üst seviyenin korunması = destek görevi
Yukarı kırılım = trend devamı
Aşağı kırılım = yapısal zayıflama

Bu çizgiler statik değil, dinamik piyasa referans bölgeleridir

🎯 Projeksiyon Mantığı

İleriye çizilen projeksiyonlar:

Olası fiyat yönünü gösterir
ATR bazlı volatilite genişlemesi ile hesaplanır

Bu çizgiler kesin tahmin değil, olasılıksal hareket beklentisidir

🧠 Piyasa Yorumu
Üçgenler = momentum oluşumu
Kutular = piyasa reaksiyon bölgeleri
EMA = trend yön filtresi
Projeksiyon = olası fiyat yol haritası

## Source Code

````pine
//@version=5
indicator("Mirror EMA Triangle System V2 CLEAN", overlay=true)

// ─────────────────────
// EMA FILTER
// ─────────────────────
emaLen = input.int(50, "EMA Length")
ema = ta.ema(close, emaLen)
plot(ema, color=color.black)

bullTrend = close > ema
bearTrend = close < ema

// ─────────────────────
// 3 MUM STRUCTURE
// ─────────────────────
c1 = close[2]
c2 = close[1]
c3 = close

upMove   = (c2 > c1) and (c3 > c2)
downMove = (c2 < c1) and (c3 < c2)

// ─────────────────────
// ATR FILTER
// ─────────────────────
atr = ta.atr(14)
validMove = math.abs(c3 - c2) > atr * 0.6

// ─────────────────────
// STRENGTH FILTER
// ─────────────────────
range12 = math.abs(c2 - c1)
range23 = math.abs(c3 - c2)
strongMove = range23 > range12

// ─────────────────────
// MIRROR FILTER (FAKE CLEANER)
// ─────────────────────
mirrorDist = math.abs(close - ema)
mirrorFilter = mirrorDist > atr * 0.4

// ─────────────────────
// FINAL SIGNALS
// ─────────────────────
buySignal  = upMove and strongMove and validMove and bullTrend and mirrorFilter
sellSignal = downMove and strongMove and validMove and bearTrend and mirrorFilter

// ─────────────────────
// STATE MACHINE
// ─────────────────────
var int state = 0

buyTrigger  = buySignal and state != 1
sellTrigger = sellSignal and state != -1

if buyTrigger
    state := 1

if sellTrigger
    state := -1

// ─────────────────────
// SIGNALS
// ─────────────────────
plotshape(buyTrigger, style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, title="BUY")
plotshape(sellTrigger, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="SELL")

// ─────────────────────
// TRIANGLE ZONE
// ─────────────────────
topLevel = math.max(high[2], math.max(high[1], high))
botLevel = math.min(low[2], math.min(low[1], low))

if buyTrigger
    box.new(
         left=bar_index-2,
         right=bar_index,
         top=topLevel,
         bottom=botLevel,
         border_color=color.blue,
         bgcolor=color.new(color.blue, 85)
     )

if sellTrigger
    box.new(
         left=bar_index-2,
         right=bar_index,
         top=topLevel,
         bottom=botLevel,
         border_color=color.red,
         bgcolor=color.new(color.red, 85)
     )

// ─────────────────────
// TRIANGLE LINES
// ─────────────────────
var line l1 = na
var line l2 = na
var line l3 = na

if buyTrigger or sellTrigger
    line.delete(l1)
    line.delete(l2)
    line.delete(l3)

    col = buyTrigger ? color.blue : color.red

    l1 := line.new(bar_index-2, c1, bar_index-1, c2, color=col, width=2)
    l2 := line.new(bar_index-1, c2, bar_index, c3, color=col, width=2)
    l3 := line.new(bar_index-2, c1, bar_index, c3, color=color.new(col, 60), width=1)

// ─────────────────────
// PROJECTION
// ─────────────────────
projLen = 5

if buyTrigger
    line.new(bar_index, c3, bar_index + projLen, c3 + atr, color=color.new(color.blue, 40), style=line.style_dashed)

if sellTrigger
    line.new(bar_index, c3, bar_index + projLen, c3 - atr, color=color.new(color.red, 40), style=line.style_dashed)

// ─────────────────────
// BREAKOUT LEVELS (SAFE ADD-ON)
// ─────────────────────
var line buyLevel = na
var line sellLevel = na

if buyTrigger
    line.delete(buyLevel)
    buyLevel := line.new(bar_index-2, topLevel, bar_index + 30, topLevel, color=color.green, width=2)

if sellTrigger
    line.delete(sellLevel)
    sellLevel := line.new(bar_index-2, botLevel, bar_index + 30, botLevel, color=color.red, width=2)

// BREAK LOGIC
if not na(buyLevel)
    if close > topLevel
        line.delete(buyLevel)

if not na(sellLevel)
    if close < botLevel
        line.delete(sellLevel)// ─────────────────────
// ATR CLOUD (BREAKOUT ZONE VISUALIZATION)
// ─────────────────────
atrLen = 14
atrVal = ta.atr(atrLen)

// Bull zone cloud
bullUpper = topLevel + atrVal
bullLower = topLevel - atrVal

// Bear zone cloud
bearUpper = botLevel + atrVal
bearLower = botLevel - atrVal

bullCloudTop = buyTrigger ? bullUpper : na
bullCloudBot = buyTrigger ? bullLower : na

bearCloudTop = sellTrigger ? bearUpper : na
bearCloudBot = sellTrigger ? bearLower : na

p1 = plot(bullCloudTop, display=display.none)
p2 = plot(bullCloudBot, display=display.none)
fill(p1, p2, color=color.new(color.green, 85))

p3 = plot(bearCloudTop, display=display.none)
p4 = plot(bearCloudBot, display=display.none)
fill(p3, p4, color=color.new(color.red, 85))
````
