# Candle Box System

- url: https://www.tradingview.com/script/AlzY0nXw/
- type: indicator
- pine_id: PUB;325adc7c01514fb3abcdf87ead7ef3f0
- version: 1.0

## Description

This indicator is a hybrid market structure tool based on a 3-candle triangle formation combined with EMA trend filtering and mirror-based noise reduction.

It detects short-term momentum shifts using structured price movement and validates signals with ATR-based volatility, strength comparison between candles, and EMA trend direction.

The system generates BUY and SELL signals only when multiple conditions align, ensuring higher-quality setups and reducing market noise.

🔺 Triangle Logic

Each signal is formed from a 3-candle structure that represents micro market flow. The triangle reflects short-term direction, momentum strength, and confirmation behavior.

📊 Reference Lines (Important Feature)

On every valid signal, the indicator draws reference lines on the box zone.

These lines act as dynamic support and resistance levels.

If price reacts to these levels and cannot break or hold them properly, the signal weakens or becomes invalid.

When price respects these lines as support or resistance and holds direction → the signal is considered strong BUY or SELL.

🪞 Mirror Filter Concept

The indicator uses a mirror-based EMA distance filter to eliminate fake signals caused by price noise around the trend line.

⚠️ Usage Note

This tool is designed for decision support only and should be used with proper risk management.

🇹🇷 TÜRKÇE AÇIKLAMA

Mirror EMA Triangle System V2

Bu gösterge, 3 mumluk üçgen formasyonu, EMA trend filtresi ve mirror (ayna) tabanlı gürültü azaltma mantığını birleştiren hibrit bir piyasa yapısı aracıdır.

Kısa vadeli momentum değişimlerini fiyat yapısı üzerinden tespit eder ve sinyalleri ATR volatilite filtresi, mumlar arası güç karşılaştırması ve EMA trend yönü ile doğrular.

Sistem, yalnızca birden fazla koşul aynı anda oluştuğunda BUY ve SELL sinyali üretir, böylece daha kaliteli işlem fırsatları sunar.

🔺 Üçgen Mantığı

Her sinyal 3 mumdan oluşan bir yapıdan gelir. Bu yapı piyasanın mikro hareket akışını temsil eder.

📊 Referans Çizgileri (ÖNEMLİ)

Sinyal oluştuğunda kutu bölgesi üzerinde referans çizgileri çizilir.

Bu çizgiler dinamik destek ve direnç seviyeleri gibi çalışır.

Eğer fiyat bu çizgileri destek veya direnç olarak test edip kıramazsa ve yönünü korursa → sinyal güçlü kabul edilir (güçlü AL / SAT).

🪞 Mirror Filtresi

EMA etrafındaki fiyat gürültüsünü filtrelemek için mirror mesafe mantığı kullanılır.

⚠️ Kullanım Notu

Bu gösterge sadece karar destek aracıdır ve risk yönetimi ile birlikte kullanılmalıdır.

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
````
