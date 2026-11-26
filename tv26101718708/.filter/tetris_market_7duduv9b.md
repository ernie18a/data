# Tetris MARKET 

- url: https://www.tradingview.com/script/7DudUv9b/
- type: indicator
- pine_id: PUB;63b6574bc591428c95eacab3018eb25e
- version: 1.0

## Description

🧩 Market Tetris Grid – Multi-Factor Market Structure Model

This indicator is a multi-layer market structure visualization system that combines volatility, momentum, volume flow, and trend direction into a unified “block-based” framework inspired by Tetris logic.

The purpose of this model is not to generate isolated signals, but to visualize the internal strength and alignment of market forces in real time.

🔬 CORE MATHEMATICAL STRUCTURE

The system is built on six independent market components:

1. ATR (Volatility Engine – Enhanced / Super ATR Concept)

The ATR component is not used in its standard form only.
Instead, it is normalized and interpreted as a relative volatility expansion engine.

It measures:

Market range expansion
Volatility pressure compared to historical average
Structural movement intensity

This is part of a broader “multi-source volatility interpretation” approach, where ATR is combined with range and true range behavior to represent real market energy rather than simple average true range.

2. Delta (Price Pressure)

Delta represents raw directional price movement:

Positive delta → buying pressure
Negative delta → selling pressure

It captures immediate micro-directional momentum of price.

3. OBV (Volume Flow Engine)

OBV is implemented in a stable cumulative form:

Volume is added on upward closes
Subtracted on downward closes

This reflects net capital flow direction rather than raw volume.

4. Momentum (Rate of Change)

Momentum is calculated using rate-of-change logic:

Measures speed of price movement
Identifies acceleration or deceleration phases
5. Volatility Ratio

Volatility is normalized using ATR relative to its moving average:

Detects expansion vs compression phases
Identifies structural volatility regime shifts
6. Trend Structure

Trend is defined as the difference between short and medium EMAs:

Represents directional bias
Filters noise from raw price movement
🧠 SCORING & PROBABILITY MODEL

All six components are normalized and aggregated into a unified score:

Positive score → bullish market bias
Negative score → bearish market bias

This score is then converted into:

Bullish Probability (%)
Bearish Probability (%)

The probability is not predictive in isolation, but represents multi-factor alignment strength across market dimensions.

🧱 VISUAL MODEL (TETRIS GRID LOGIC)

Each column represents one market force:

ATR / Delta / OBV / Momentum / Volatility / Trend

Block height reflects intensity, allowing visual detection of:

Market expansion zones
Compression phases
Directional imbalance
Structural alignment or divergence
⚠️ INTENDED USE

This indicator is designed for:

Market structure analysis
Trend strength visualization
Multi-factor confirmation
Institutional-style flow interpretation

It is not intended to be a standalone buy/sell system.

🇹🇷 TÜRKÇE AÇIKLAMA (RESMİ)
🧩 Market Tetris Grid – Çok Faktörlü Piyasa Yapı Modeli

Bu indikatör, volatilite, momentum, hacim akışı ve trend yönünü tek bir “blok tabanlı yapı” içinde birleştiren çok katmanlı bir piyasa görselleştirme sistemidir.

Amaç, tekil sinyal üretmek değil; piyasanın içsel güç dağılımını ve uyumunu gerçek zamanlı olarak görselleştirmektir.

🔬 TEMEL MATEMATİK YAPI

Sistem 6 ana piyasa bileşeni üzerine kuruludur:

1. ATR (Geliştirilmiş Volatilite Motoru – “Super ATR” Mantığı)

ATR sadece klasik haliyle kullanılmaz.

Bunun yerine:

normalize edilir
geçmiş ortalamalara göre göreceli gücü ölçülür
piyasa genişleme enerjisi olarak yorumlanır

Bu yapı, standart ATR’den farklı olarak:
👉 “çok kaynaklı volatilite yorumlama modeli” içerir.

Yani sadece ortalama gerçek aralık değil, piyasanın enerji artışı / daralması analiz edilir.

2. Delta (Fiyat Baskısı)

Delta, fiyatın anlık yönlü hareketini temsil eder:

Pozitif delta → alım baskısı
Negatif delta → satım baskısı
3. OBV (Hacim Akışı)

OBV şu mantıkla çalışır:

kapanış yukarıysa hacim eklenir
kapanış aşağıysa hacim çıkarılır

Bu yapı net para akış yönünü gösterir.

4. Momentum

Momentum, fiyat değişim hızını ölçer:

hızlanma / yavaşlama tespiti yapar
5. Volatilite Oranı

ATR’nin kendi ortalamasına oranı alınır:

piyasa sıkışma / genişleme tespiti
rejim değişimi analizi
6. Trend Yapısı

Kısa ve orta EMA farkı alınır:

yönlü bias üretir
gürültüyü filtreler
🧠 SKOR VE OLASILIK MODELİ

6 bileşen normalize edilerek tek bir skor oluşturur:

pozitif skor → bullish baskı
negatif skor → bearish baskı

Bu skor daha sonra:

Bullish %
Bearish %

olarak olasılığa çevrilir.

Bu değer tek başına tahmin değil, çoklu piyasa faktörlerinin hizalanma gücünü gösterir.

🧱 GÖRSEL MODEL (TETRIS MANTIĞI)

Her sütun bir piyasa gücünü temsil eder:

ATR / Delta / OBV / Momentum / Volatilite / Trend

Blok yüksekliği, ilgili faktörün gücünü gösterir.

Bu sayede:

genişleme bölgeleri
sıkışma alanları
yönsel dengesizlik
yapısal uyum / ayrışma

görsel olarak analiz edilebilir.

⚠️ KULLANIM AMACI

Bu indikatör:

piyasa yapısı analizi
trend gücü ölçümü
çok faktörlü doğrulama
kurumsal akış yorumlama

için tasarlanmıştır.

Tek başına al/sat sistemi değildir.

## Source Code

````pine
//@version=5
indicator("🧩 Market Tetris Grid (Clean Explained)", overlay=true)

//━━━━━━━━ INPUT
len = input.int(14, "Length")
rows = 10

//━━━━━━━━ DATA
atr        = ta.atr(len)
delta      = close - close[1]

// MANUAL OBV
obv = 0.0
obv := nz(obv[1]) + (close > close[1] ? volume : close < close[1] ? -volume : 0)

momentum   = ta.roc(close, len)
volatility = atr / math.max(ta.sma(atr, len), 1)
trend      = ta.ema(close, 9) - ta.ema(close, 21)

//━━━━━━━━ NORMALIZER
norm(x) =>
    x / math.max(ta.sma(math.abs(x), len), 1)

//━━━━━━━━ VALUES
atrV  = norm(atr)
delV  = norm(delta)
obvV  = norm(obv)
momV  = norm(momentum)
volV  = norm(volatility)
trdV  = norm(trend)

//━━━━━━━━ BLOCK SIZE
getBlocks(x) =>
    b = 1
    if math.abs(x) > 1.5
        b := 5
    else if math.abs(x) > 1.0
        b := 4
    else if math.abs(x) > 0.7
        b := 3
    else if math.abs(x) > 0.4
        b := 2
    else
        b := 1
    b

b1 = getBlocks(atrV)
b2 = getBlocks(delV)
b3 = getBlocks(obvV)
b4 = getBlocks(momV)
b5 = getBlocks(volV)
b6 = getBlocks(trdV)

//━━━━━━━━ COLOR SYSTEM
getColor(x) =>
    color out = color.black
    if x > 1.2
        out := color.lime
    else if x > 0.5
        out := color.aqua
    else if x > 0
        out := color.yellow
    else
        out := color.red
    out

//━━━━━━━━ COLUMN COLORS
c1 = color.orange
c2 = color.blue
c3 = color.purple
c4 = color.yellow
c5 = color.teal
c6 = color.fuchsia

//━━━━━━━━ TABLE
var table t = table.new(position.middle_right, 6, rows, border_width=1)

//━━━━━━━━ DRAW GRID
if barstate.islast

    for r = 0 to rows - 1
        for c = 0 to 5
            table.cell(t, c, r, "", bgcolor=color.black)

    for r = 0 to b1 - 1
        table.cell(t, 0, rows - 1 - r, "ATR", bgcolor=getColor(atrV), text_color=color.white)

    for r = 0 to b2 - 1
        table.cell(t, 1, rows - 1 - r, "DELTA", bgcolor=getColor(delV), text_color=color.white)

    for r = 0 to b3 - 1
        table.cell(t, 2, rows - 1 - r, "OBV", bgcolor=getColor(obvV), text_color=color.white)

    for r = 0 to b4 - 1
        table.cell(t, 3, rows - 1 - r, "MOM", bgcolor=getColor(momV), text_color=color.white)

    for r = 0 to b5 - 1
        table.cell(t, 4, rows - 1 - r, "VOL", bgcolor=getColor(volV), text_color=color.white)

    for r = 0 to b6 - 1
        table.cell(t, 5, rows - 1 - r, "TRD", bgcolor=getColor(trdV), text_color=color.white)

//━━━━━━━━ LEGEND
var table legend = table.new(position.top_right, 1, 7)

if barstate.islast
    table.cell(legend, 0, 0, "🟢 STRONG TREND", text_color=color.lime, bgcolor=color.black)
    table.cell(legend, 0, 1, "🔵 NORMAL FLOW", text_color=color.aqua, bgcolor=color.black)
    table.cell(legend, 0, 2, "🟡 WEAK / WARNING", text_color=color.yellow, bgcolor=color.black)
    table.cell(legend, 0, 3, "🔴 PRESSURE / BEAR", text_color=color.red, bgcolor=color.black)
    table.cell(legend, 0, 4, "ATR / DELTA / OBV / MOM / VOL / TREND", text_color=color.gray, bgcolor=color.black)

//━━━━━━━━ PROBABILITY ENGINE
score = atrV + delV + obvV + momV + volV + trdV

bullProb = score > 0 ? math.min(50 + score * 10, 100) : math.max(0, 50 + score * 10)
bearProb = 100 - bullProb

table.cell(legend, 0, 5,
     "🟢 Bullish: " + str.tostring(bullProb, "#.0") + "% | 🔴 Bearish: " + str.tostring(bearProb, "#.0") + "%",
     text_color=color.white,
     bgcolor=color.black)

//━━━━━━━━ STRESS ZONE
stress = (b1 + b2 + b3 + b4 + b5 + b6) >= 22
bgcolor(stress ? color.new(color.red, 85) : na)
````
