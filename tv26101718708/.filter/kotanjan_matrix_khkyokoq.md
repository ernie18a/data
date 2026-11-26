# KOTANJAN MATRIX

- url: https://www.tradingview.com/script/khkyoKoQ/
- type: indicator
- pine_id: PUB;01697a68e67b43f69acd2dc79962d376
- version: 1.0

## Description

🇬🇧 English

KOTANJAN MATRIX is a market structure visualization framework designed to interpret price action through a 3-candle micro-structure model combined with volume and volatility dynamics.

Instead of displaying traditional signals, the script converts market behavior into a structured “energy grid” representation.

Core Methodology:

The system evaluates market movement using:

3-candle directional flow (micro trend detection)
Volume expansion (participation strength)
Price compression (energy accumulation phases)
Volatility-based normalization

These components are aggregated into a scoring mechanism that maps market conditions into a Tetris-style structural grid.

Visualization Logic:
Expanding conditions increase structural height (trend strength)
Compression phases reduce energy representation (accumulation zones)
Directional bias defines color state transitions
Market regimes are visually separated as structure rather than signals
Risk & Trend Layer:

The framework includes:

ATR-based V-Stop for dynamic risk reference
ATR volatility cloud to visualize market expansion/contraction
State-based trend tracking to avoid repetitive signal noise
Intended Use:

This tool is designed for:

Market structure analysis
Trend phase identification
Volatility interpretation
Visual decision support rather than automated trading signals

It does not repaint and does not generate repeated signals within the same market state.

🇹🇷 Türkçe Açıklama

KOTANJAN MATRIX, fiyat hareketini klasik indikatör sinyalleri yerine 3 mumluk mikro yapı modeli ile analiz eden bir piyasa yapı görselleştirme sistemidir.

Sistem, piyasayı “sinyal üretici” olarak değil, enerji tabanlı bir yapı (grid) olarak yorumlar.

Temel Mantık:

Model şu bileşenleri kullanır:

3 mumluk yönsel akış (mikro trend tespiti)
Hacim genişlemesi (piyasa katılım gücü)
Fiyat sıkışması (enerji birikim alanları)
Volatilite normalize edilmiş yapı

Bu veriler birleşerek piyasayı Tetris benzeri bir yapı içinde görselleştirir.

Görselleştirme Mantığı:
Güçlü trendler yapıyı yükseltir
Sıkışma dönemleri enerji düşüşü olarak görünür
Yön değişimleri renk geçişleriyle temsil edilir
Piyasa, sinyal yerine “yapı rejimleri” olarak okunur
Risk ve Trend Katmanı:
ATR bazlı V-Stop dinamik risk seviyesi sunar
ATR bulutu volatilite genişleme/daralma alanlarını gösterir
Tekrarlayan sinyalleri engelleyen state-based yapı kullanır
Kullanım Amacı:
Piyasa yapısını analiz etmek
Trend fazlarını okumak
Volatilite davranışını anlamak
Otomatik işlemden ziyade karar destek sistemi olarak kullanmak

Sistem repaint yapmaz ve aynı piyasa durumunda tekrar sinyal üretmez.

## Source Code

````pine
//@version=5
indicator("KOTANJAN TETRIS GRID", overlay=true)

//━━━━━━━━━━━━━━━━━━ INPUTS (PUBLISH PANEL)
len        = input.int(14, "Base Length", tooltip="Main calculation length")
rows       = input.int(12, "Grid Height")

// VISUAL CONTROLS
showGrid   = input.bool(true, "Show Grid")
showCloud  = input.bool(true, "Show ATR Cloud")
showVStop  = input.bool(true, "Show V-Stop")
showSignal = input.bool(true, "Show Signals")

// NOISE FILTER SETTINGS
volFactor  = input.float(1.2, "Volume Spike Multiplier", step=0.1)
compFactor = input.float(0.6, "Compression Sensitivity", step=0.1)

// RISK SETTINGS
atrLen     = input.int(14, "ATR Length")
vMult      = input.float(2.0, "V-Stop Multiplier")
cloudMult  = input.float(1.2, "ATR Cloud Width")

//━━━━━━━━━━━━━━━━━━ 3 CANDLE ENGINE
c1 = close[2]
c2 = close[1]
c3 = close

r1 = c2 - c1
r2 = c3 - c2

volAvg   = ta.sma(volume, len)
volSpike = volume > volAvg * volFactor

upFlow   = r1 > 0 and r2 > 0
downFlow = r1 < 0 and r2 < 0

avgRange = ta.sma(math.abs(close - close[1]), len)

compression =
     math.abs(r1) < avgRange * compFactor and
     math.abs(r2) < avgRange * compFactor

//━━━━━━━━━━━━━━━━━━ SCORE ENGINE
score =
     (upFlow ? 1 : downFlow ? -1 : 0) +
     (volSpike ? 1 : 0) +
     (compression ? -1 : 1)

//━━━━━━━━━━━━━━━━━━ BLOCK ENGINE
getBlocks(x) =>
    ax = math.abs(x)
    b =
         ax >= 3 ? 6 :
         ax >= 2 ? 5 :
         ax >= 1 ? 4 :
         ax >= 0.5 ? 3 :
         ax > 0 ? 2 : 1
    math.min(b, rows)

blocks = getBlocks(score)

//━━━━━━━━━━━━━━━━━━ COLOR ENGINE
getColor(x) =>
    color out = color.gray
    if x >= 3
        out := color.lime
    else if x == 2
        out := color.green
    else if x == 1
        out := color.yellow
    else if x == 0
        out := color.gray
    else
        out := color.red
    out

col = getColor(score)

//━━━━━━━━━━━━━━━━━━ STATE MACHINE (NO SPAM)
longCond  = upFlow and volSpike and not compression
shortCond = downFlow and volSpike and not compression

var int state = 0

newLong  = longCond and state != 1
newShort = shortCond and state != -1

if newLong
    state := 1
else if newShort
    state := -1

//━━━━━━━━━━━━━━━━━━ TETRIS GRID
var table t = table.new(position.middle_right, 1, rows, border_width=1)

if showGrid and barstate.islast
    for r = 0 to rows - 1
        table.cell(t, 0, r, "", bgcolor=color.rgb(10,10,10))

    for r = 0 to blocks - 1
        table.cell(t, 0, rows - 1 - r, "🧩", bgcolor=col)

//━━━━━━━━━━━━━━━━━━ V-STOP
atr = ta.atr(atrLen)

var float vStop = na

vStop :=
     state == 1 ? close - atr * vMult :
     state == -1 ? close + atr * vMult :
     nz(vStop[1])

plot(showVStop ? vStop : na, "V-Stop", color=color.white, linewidth=2)

//━━━━━━━━━━━━━━━━━━ ATR CLOUD
basis = ta.ema(close, len)

upper = basis + atr * cloudMult
lower = basis - atr * cloudMult

cloudColor =
     state == 1 ? color.new(color.green, 85) :
     state == -1 ? color.new(color.red, 85) :
     color.new(color.blue, 90)

p1 = plot(showCloud ? upper : na, display=display.none)
p2 = plot(showCloud ? lower : na, display=display.none)

fill(p1, p2, color=cloudColor)

//━━━━━━━━━━━━━━━━━━ SIGNALS (ONLY ON STATE CHANGE)
longSignal  = newLong
shortSignal = newShort

plotshape(showSignal and longSignal, title="Long",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="LONG",
     textcolor=color.white,
     size=size.small)

plotshape(showSignal and shortSignal, title="Short",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SHORT",
     textcolor=color.white,
     size=size.small)
````
