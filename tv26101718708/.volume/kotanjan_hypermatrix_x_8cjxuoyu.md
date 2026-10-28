# KOTANJAN HYPERMATRIX X

- url: https://www.tradingview.com/script/8CjxUoyu/
- type: indicator
- pine_id: PUB;19fca9b1c7374edc99adb2d2ae0b08a6
- version: 1.0

## Description

(English Description)

KOTANJAN HYPERMATRIX X is a multi-layered market structure engine designed to analyze price behavior through a composite of momentum, volume, volatility, trend strength, and compression-expansion cycles.

Unlike traditional indicators that rely on a single mathematical model (such as RSI, MACD, or moving averages), this system integrates multiple independent market dimensions into one unified state engine.

CORE COMPONENTS

The system is built on six primary normalized market vectors:

ATR (Average True Range): Measures market movement intensity and volatility expansion.
Delta (Price Change Flow): Captures immediate directional pressure between candles.
OBV (On-Balance Volume): Tracks volume-driven capital flow into or out of price movement.
Momentum (ROC): Measures acceleration or deceleration of price movement.
Volatility Ratio: Identifies market instability relative to its own baseline behavior.
Trend Differential: Measures short-term directional bias using EMA spread structure.

These six components form the Market Matrix Core, representing the raw energy structure of price behavior.

FLOW STRUCTURE ENGINE

In addition to the matrix core, a secondary flow engine evaluates:

Multi-candle directional alignment (3-candle flow system)
Volume spike detection relative to dynamic average
Compression detection based on range contraction

This allows the system to distinguish between:

accumulation phases
breakout preparation phases
directional continuation phases
ADVANCED CONFIRMATION LAYER (KOTANJAN SYSTEM)

The distinguishing element of this indicator is the KOTANJAN System Layer, which enhances probability accuracy by adding adaptive market filters:

ADX (Trend Strength Filter): Determines whether market movement is structurally valid or noise-driven.
MACD Histogram (Momentum Continuation): Confirms whether directional pressure is accelerating or weakening.
RSI (Exhaustion Filter): Identifies overbought/oversold zones and reduces probability distortion during extreme conditions.

These filters do not replace the core matrix. Instead, they act as a probability refinement layer that adjusts market bias based on structural confirmation.

MARKET STRUCTURE INTERPRETATION

KOTANJAN HYPERMATRIX X interprets market behavior as a dynamic system of:

Compression → low volatility, accumulation phase
Expansion → breakout or trend initiation
Extreme → potential exhaustion or reversal risk

This structure allows the system to detect hidden transitions that are not visible through single-indicator analysis.

PROBABILITY ENGINE

All components are merged into a unified scoring system that produces:

Bullish probability (%)
Bearish probability (%)

This is not a prediction model but a weighted state evaluation of current market conditions.

KEY DIFFERENCE

The main difference between KOTANJAN HYPERMATRIX X and traditional trading indicators is:

It does not analyze price as a single line.

Instead, it treats the market as a multi-dimensional energy system, combining:

price structure
volume flow
volatility compression
trend strength
momentum confirmation

into one unified behavioral engine.

🇹🇷 Türkçe Açıklama

KOTANJAN HYPERMATRIX X, piyasayı tek bir indikatör mantığıyla değil, çok katmanlı bir “piyasa durum motoru” olarak analiz eden gelişmiş bir yapı sistemidir.

Klasik indikatörler (RSI, MACD, MA vb.) sadece tek bir veri tipine odaklanırken, bu sistem fiyatı birçok farklı boyutta aynı anda değerlendirir.

TEMEL BİLEŞENLER

Sistem 6 ana normalize veri üzerinden çalışır:

ATR: Piyasanın hareket gücünü ve volatilite genişlemesini ölçer
Delta: Mumlar arası anlık yön baskısını gösterir
OBV: Hacim akışı ile para giriş/çıkışını takip eder
Momentum (ROC): Fiyat hızlanmasını veya yavaşlamasını ölçer
Volatilite Oranı: Piyasanın kendi ortalamasına göre dengesizliğini ölçer
Trend Farkı: EMA yapısı üzerinden kısa vadeli yön eğilimini belirler

Bu 6 veri birlikte Market Matrix Core yapısını oluşturur.

AKIŞ SİSTEMİ (FLOW ENGINE)

Bunun yanında ikinci bir yapı vardır:

3 mumluk yön akışı
hacim patlama tespiti
daralma (compression) analizi

Bu sayede sistem şunları ayırt edebilir:

birikim dönemleri
kırılım hazırlıkları
trend devam bölgeleri
KOTANJAN SİSTEM KATMANI (EN ÖNEMLİ FARK)

Bu indikatörü diğerlerinden ayıran en önemli bölüm KOTANJAN sistem katmanıdır.

Bu katmanda:

ADX: Trend gerçekten güçlü mü yoksa rastgele hareket mi?
MACD Histogram: Momentum devam ediyor mu yoksa zayıflıyor mu?
RSI: Aşırı alım / aşırı satım bölgelerinde risk filtresi

Bu üç yapı direkt olarak sinyal üretmez.
Sadece mevcut sistemi “doğrulayan veya zayıflatan” bir ağırlık mekanizması olarak çalışır.

MARKET YAPISI OKUMA MANTIĞI

Sistem piyasayı 3 temel fazda okur:

Compression (Daralma): düşük volatilite, birikim
Expansion (Genişleme): kırılım veya trend başlangıcı
Extreme (Aşırı durum): yorulma ve dönüş riski

Bu yapı sayesinde klasik indikatörlerde görülmeyen gizli geçişler yakalanır.

PROBABILITY MOTORU

Tüm sistem birleşerek:

Boğa yüzdesi
Ayı yüzdesi

üretir.

Bu değerler tahmin değil, mevcut piyasa durumunun ağırlıklı analiz sonucudur.

EN BÜYÜK FARK

KOTANJAN HYPERMATRIX X’in en önemli farkı şudur:

Fiyatı tek bir çizgi olarak analiz etmez.

Bunun yerine piyasayı:

fiyat yapısı
hacim akışı
volatilite daralma/genişleme
trend gücü
momentum doğrulaması

olarak çok boyutlu bir sistem şeklinde değerlendirir.

## Source Code

````pine
//@version=5
indicator("🧩 FLUX MATRIX • KOTANJAN PRO", overlay=true)

//━━━━━━━━━━━━━━━━━━ INPUTS
len         = input.int(14, "Base Length")
rows        = input.int(12, "Grid Height")

showGrid    = input.bool(true, "Show Grid")
showCloud   = input.bool(true, "Show ATR Cloud")
showVStop   = input.bool(true, "Show V-Stop")
showSignal  = input.bool(true, "Show Signals")
showProb    = input.bool(true, "Show Probability")

// FILTERS
volFactor   = input.float(1.2, "Volume Spike Multiplier", step=0.1)
compFactor  = input.float(0.6, "Compression Sensitivity", step=0.1)

// ATR
atrLen      = input.int(14, "ATR Length")
vMult       = input.float(2.0, "V-Stop Multiplier")
cloudMult   = input.float(1.2, "ATR Cloud Width")

// ADX
adxlen      = input.int(14, "ADX Smoothing")
dilen       = input.int(14, "DI Length")
supportLen  = input.int(14, "ADX Support Length")

//━━━━━━━━━━━━━━━━━━ PRICE ENGINE

c1 = close[2]
c2 = close[1]
c3 = close

r1 = c2 - c1
r2 = c3 - c2

//━━━━━━━━━━━━━━━━━━ FLOW ENGINE

volAvg =
     ta.sma(volume, len)

volSpike =
     volume > volAvg * volFactor

upFlow =
     r1 > 0 and r2 > 0

downFlow =
     r1 < 0 and r2 < 0

avgRange =
     ta.sma(math.abs(close - close[1]), len)

compression =
     math.abs(r1) < avgRange * compFactor and
     math.abs(r2) < avgRange * compFactor

//━━━━━━━━━━━━━━━━━━ CORE DATA

atr =
     ta.atr(len)

delta =
     close - close[1]

//━━━━━━━━━━━━━━━━━━ MANUAL OBV

var float obv = 0.0

obv :=
     nz(obv[1]) +
     (close > close[1] ? volume :
     close < close[1] ? -volume : 0)

//━━━━━━━━━━━━━━━━━━ EXTRA ENGINES

momentum =
     ta.roc(close, len)

volatility =
     atr / math.max(ta.sma(atr, len), 1)

trend =
     ta.ema(close, 9) -
     ta.ema(close, 21)

//━━━━━━━━━━━━━━━━━━ REAL ADX

dirmov(lenADX) =>

    up =
         ta.change(high)

    down =
         -ta.change(low)

    plusDM =
         na(up) ? na :
         (up > down and up > 0 ? up : 0)

    minusDM =
         na(down) ? na :
         (down > up and down > 0 ? down : 0)

    truerange =
         ta.rma(ta.tr, lenADX)

    plus =
         fixnan(
         100 *
         ta.rma(plusDM, lenADX) /
         truerange)

    minus =
         fixnan(
         100 *
         ta.rma(minusDM, lenADX) /
         truerange)

    [plus, minus]

adxFunc(dilen, adxlen) =>

    [plus, minus] =
         dirmov(dilen)

    sum =
         plus + minus

    100 *
     ta.rma(
     math.abs(plus - minus) /
     (sum == 0 ? 1 : sum),
     adxlen)

adx =
     adxFunc(dilen, adxlen)

adxSupport =
     ta.sma(adx, supportLen)

adxBull =
     adx > adxSupport

//━━━━━━━━━━━━━━━━━━ MACD + RSI

[macdLine, signalLine, histLine] =
     ta.macd(close, 12, 26, 9)

rsi =
     ta.rsi(close, len)

//━━━━━━━━━━━━━━━━━━ NORMALIZER

norm(x) =>

    base =
         ta.sma(math.abs(x), len)

    base == 0 ? 0 : x / base

//━━━━━━━━━━━━━━━━━━ NORMALIZED VALUES

atrV =
     norm(atr)

delV =
     norm(delta)

obvSmooth =
     ta.ema(obv, len)

obvV =
     norm(obv - obvSmooth)

momV =
     norm(momentum)

volV =
     norm(volatility)

trdV =
     norm(trend)

//━━━━━━━━━━━━━━━━━━ MATRIX SCORE

matrixScore =
     atrV +
     delV +
     obvV +
     momV +
     volV +
     trdV

//━━━━━━━━━━━━━━━━━━ FLOW SCORE

flowScore =
     (upFlow ? 1 : downFlow ? -1 : 0) +
     (volSpike ? 1 : 0) +
     (compression ? -1 : 1)

//━━━━━━━━━━━━━━━━━━ BACK-END AI

adxBoost =
     adxBull ? 2.0 : -1.5

macdBoost =
     histLine > 0 ?
     math.min(histLine * 5, 3) :
     math.max(histLine * 5, -3)

rsiPenalty =
     rsi > 75 ? -3 :
     rsi > 70 ? -2 :
     rsi < 25 ? 3 :
     rsi < 30 ? 2 : 0

//━━━━━━━━━━━━━━━━━━ FINAL SCORE

finalScore =
     matrixScore +
     flowScore +
     adxBoost +
     macdBoost +
     rsiPenalty

//━━━━━━━━━━━━━━━━━━ BLOCK ENGINE

getBlocks(x) =>

    ax = math.abs(x)

    b =
         ax >= 10 ? 12 :
         ax >= 8 ? 10 :
         ax >= 6 ? 8 :
         ax >= 4 ? 6 :
         ax >= 2 ? 4 :
         ax >= 1 ? 3 :
         ax > 0 ? 2 : 1

    math.min(b, rows)

blocks =
     getBlocks(finalScore)

//━━━━━━━━━━━━━━━━━━ COLOR ENGINE

getColor(x) =>

    color out = color.gray

    if x >= 8
        out := color.lime
    else if x >= 4
        out := color.green
    else if x >= 1
        out := color.yellow
    else if x <= -4
        out := color.red
    else
        out := color.orange

    out

col =
     getColor(finalScore)

//━━━━━━━━━━━━━━━━━━ STATE MACHINE

longCond =
     upFlow and
     volSpike and
     not compression and
     finalScore > 3

shortCond =
     downFlow and
     volSpike and
     not compression and
     finalScore < -3

var int state = 0

newLong =
     longCond and state != 1

newShort =
     shortCond and state != -1

if newLong
    state := 1
else if newShort
    state := -1

//━━━━━━━━━━━━━━━━━━ GRID

var table t =
     table.new(
     position.middle_right,
     1,
     rows,
     border_width = 1)

if showGrid and barstate.islast

    for r = 0 to rows - 1

        table.cell(
             t,
             0,
             r,
             "",
             bgcolor=color.rgb(10,10,10))

    for r = 0 to blocks - 1

        table.cell(
             t,
             0,
             rows - 1 - r,
             "🧩",
             bgcolor=col)

//━━━━━━━━━━━━━━━━━━ VSTOP

var float vStop = na

vStop :=
     state == 1 ?
     close - atr * vMult :

     state == -1 ?
     close + atr * vMult :

     nz(vStop[1])

plot(
     showVStop ? vStop : na,
     "V-Stop",
     color=color.white,
     linewidth=2)

//━━━━━━━━━━━━━━━━━━ ATR CLOUD

basis =
     ta.ema(close, len)

upper =
     basis + atr * cloudMult

lower =
     basis - atr * cloudMult

cloudColor =
     state == 1 ?
     color.new(color.green, 85) :

     state == -1 ?
     color.new(color.red, 85) :

     color.new(color.blue, 90)

p1 =
     plot(
     showCloud ? upper : na,
     display=display.none)

p2 =
     plot(
     showCloud ? lower : na,
     display=display.none)

fill(p1, p2, color=cloudColor)

//━━━━━━━━━━━━━━━━━━ SIGNALS

plotshape(
     showSignal and newLong,
     title="Long",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="LONG",
     textcolor=color.white,
     size=size.small)

plotshape(
     showSignal and newShort,
     title="Short",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SHORT",
     textcolor=color.white,
     size=size.small)

//━━━━━━━━━━━━━━━━━━ PROBABILITY ENGINE

bullProb =
     math.max(
     math.min(
     50 + finalScore * 4,
     100),
     0)

bearProb =
     100 - bullProb

//━━━━━━━━━━━━━━━━━━ CLEAN PANEL

var table legend =
     table.new(
     position.top_right,
     1,
     3)

if barstate.islast and showProb

    phaseText =
         compression ? "COMPRESSION" :
         finalScore > 4 ? "EXPANSION" :
         "BALANCED"

    phaseColor =
         compression ? color.gray :
         finalScore > 4 ? color.lime :
         color.orange

    table.cell(
         legend,
         0,
         0,
         "🧩 KOTANJAN MATRIX",
         text_color=color.white,
         bgcolor=color.black)

    table.cell(
         legend,
         0,
         1,
         "PHASE : " + phaseText,
         text_color=phaseColor,
         bgcolor=color.black)

    table.cell(
         legend,
         0,
         2,
         "🟢 Bull : " +
         str.tostring(bullProb, "#.0") +
         "% | 🔴 Bear : " +
         str.tostring(bearProb, "#.0") + "%",
         text_color=color.white,
         bgcolor=
         bullProb > 60 ?
         color.new(color.lime, 70) :

         bearProb > 60 ?
         color.new(color.red, 70) :

         color.new(color.orange, 70))
````
