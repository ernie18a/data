# MATRIX FOLLOW LINE TERMINAL

- url: https://www.tradingview.com/script/3y6wOV0d/
- type: indicator
- pine_id: PUB;7d3e76f9536e420392beb08bffb4c0e4
- version: 1.0

## Description

MATRIX FOLLOW LINE TERMINAL is a streamlined trend-following system built around a dynamic adaptive line designed to simplify market direction analysis.

Instead of relying on multiple overlapping indicators, this script focuses on one core structure: a responsive trailing line that reacts to price pressure and trend continuation. When price reclaims the line, bullish momentum may be strengthening. When price closes below it, bearish pressure may be increasing.

The built-in dashboard provides quick visual context including current bias, last signal levels, line distance, and trend state — helping traders make faster chart decisions with less clutter.

Designed for traders who prefer clean charts, structured signals, and efficient market reading.

Kullanım Amaçları:
Trend yönünü sade şekilde görmek
Momentum geçişlerini takip etmek
Long / Short bias belirlemek
Breakout sonrası yön teyidi almak
Gürültülü grafikleri sadeleştirmek
Tek çizgi ile karar sürecini hızlandırmak

Uygun Piyasalar:
Crypto
Forex
Indices
Stocks
Commodities

Uygun Zaman Dilimleri:
15m
1H
4H
Daily

Hedef Kullanıcı Kitlesi
Clean chart seven traderlar
Trend follower kullanıcılar
Scalper + intraday traderlar
Swing traderlar
Sistematik işlem yapanlar
Fazla indikatör kalabalığından hoşlanmayan kullanıcılar

Markets often reward clarity over complexity.
This release focuses on simplicity, structure, and decision efficiency.

Future profile updates may include expanded terminal frameworks, advanced filters, and professional-grade market tools.

## Source Code

````pine
//@version=5
indicator("MATRIX FOLLOW LINE TERMINAL V3", shorttitle="MFL TERMINAL V3", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore   = "Core Engine"
groupVisual = "Visual Design"

atrPeriod      = input.int(5, "ATR Period", minval=1, group=groupCore)
bbPeriod       = input.int(21, "BB Period", minval=1, group=groupCore)
bbDeviation    = input.float(1.0, "BB Deviation", minval=0.1, step=0.1, group=groupCore)
useATRfilter   = input.bool(true, "Use ATR Filter", group=groupCore)
confirmOnClose = input.bool(true, "Confirm On Bar Close", group=groupCore)

showSignals    = input.bool(true, "Show Signals", group=groupVisual)
showDashboard  = input.bool(true, "Show Dashboard", group=groupVisual)
showBand       = input.bool(true, "Show Trend Band", group=groupVisual)
paintBars      = input.bool(false, "Paint Bars", group=groupVisual)
glowLine       = input.bool(true, "Glow Line", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float basis   = ta.sma(close, bbPeriod)
float dev     = ta.stdev(close, bbPeriod) * bbDeviation
float bbUpper = basis + dev
float bbLower = basis - dev
float atrValue = ta.atr(atrPeriod)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FOLLOW LINE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float followLine = na
var int bbSignal = 0

if close > bbUpper
    bbSignal := 1
else if close < bbLower
    bbSignal := -1
else
    bbSignal := nz(bbSignal[1], 0)

if bbSignal == 1
    float bullBase = useATRfilter ? low - atrValue : low
    if na(followLine[1])
        followLine := bullBase
    else
        followLine := math.max(bullBase, followLine[1])

if bbSignal == -1
    float bearBase = useATRfilter ? high + atrValue : high
    if na(followLine[1])
        followLine := bearBase
    else
        followLine := math.min(bearBase, followLine[1])

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND / COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int trend = 0
if not na(followLine)
    if close > followLine
        trend := 1
    else if close < followLine
        trend := -1
    else
        trend := nz(trend[1], 0)

color bullColor    = color.rgb(0, 122, 255)
color bearColor    = color.rgb(185, 32, 52)
color neutralColor = color.rgb(110, 110, 120)
color panelBg      = color.rgb(18, 18, 28)
color cellBg       = color.rgb(28, 28, 40)
color lineColor    = trend == 1 ? bullColor : trend == -1 ? bearColor : neutralColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RAW CROSS SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool barConfirmed = confirmOnClose ? barstate.isconfirmed : true

bool rawBuy  = not na(followLine) and not na(followLine[1]) and close > followLine and close[1] <= followLine[1] and barConfirmed
bool rawSell = not na(followLine) and not na(followLine[1]) and close < followLine and close[1] >= followLine[1] and barConfirmed

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NO DOUBLE BUY / SELL ENGINE
// 1 = last signal buy
// -1 = last signal sell
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int lastSignal = 0

bool buySignal = false
bool sellSignal = false

if rawBuy and lastSignal != 1
    buySignal := true
    lastSignal := 1

if rawSell and lastSignal != -1
    sellSignal := true
    lastSignal := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LAST SIGNAL PRICES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float lastBuyPrice = na
var float lastSellPrice = na

if buySignal
    lastBuyPrice := close

if sellSignal
    lastSellPrice := close

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS TEXT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string biasText = "NEUTRAL"
if trend == 1
    biasText := "BULLISH"
else if trend == -1
    biasText := "BEARISH"

string entryText = "WAIT"
if buySignal
    entryText := "BUY"
else if sellSignal
    entryText := "SELL"

float distancePercent = na
if not na(followLine) and followLine != 0
    distancePercent := ((close - followLine) / followLine) * 100.0

string distanceText = na(distancePercent) ? "-" : str.tostring(distancePercent, "#.##") + "%"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND BAND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float upperBandBull = trend == 1 ? followLine + atrValue * 0.35 : na
float lowerBandBull = trend == 1 ? followLine - atrValue * 0.35 : na
float upperBandBear = trend == -1 ? followLine + atrValue * 0.35 : na
float lowerBandBear = trend == -1 ? followLine - atrValue * 0.35 : na

p1 = plot(showBand ? upperBandBull : na, color=color.new(bullColor, 86), linewidth=1)
p2 = plot(showBand ? lowerBandBull : na, color=color.new(bullColor, 86), linewidth=1)
fill(p1, p2, color=color.new(bullColor, 91))

p3 = plot(showBand ? upperBandBear : na, color=color.new(bearColor, 86), linewidth=1)
p4 = plot(showBand ? lowerBandBear : na, color=color.new(bearColor, 86), linewidth=1)
fill(p3, p4, color=color.new(bearColor, 91))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(glowLine ? followLine : na, title="Glow", color=color.new(lineColor, 70), linewidth=6)
plot(followLine, title="Follow Line", color=lineColor, linewidth=2)

barcolor(paintBars ? (trend == 1 ? color.new(bullColor, 80) : trend == -1 ? color.new(bearColor, 80) : na) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float buyY  = low - atrValue * 0.35
float sellY = high + atrValue * 0.35

plotshape(showSignals and buySignal ? buyY : na, title="BUY", text="BUY", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=color.white, size=size.small)
plotshape(showSignals and sellSignal ? sellY : na, title="SELL", text="SELL", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, title="Buy", message="MATRIX FOLLOW LINE TERMINAL V3 BUY")
alertcondition(sellSignal, title="Sell", message="MATRIX FOLLOW LINE TERMINAL V3 SELL")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 2, 7, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "MFL TERMINAL V3", text_color=color.white, bgcolor=panelBg)
    table.cell(dash, 1, 0, biasText, text_color=color.white, bgcolor=trend == 1 ? bullColor : trend == -1 ? bearColor : neutralColor)

    table.cell(dash, 0, 1, "Entry", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 1, entryText, text_color=color.white, bgcolor=buySignal ? bullColor : sellSignal ? bearColor : color.rgb(70,70,70))

    table.cell(dash, 0, 2, "Close", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 2, str.tostring(close, format.mintick), text_color=color.white, bgcolor=cellBg)

    table.cell(dash, 0, 3, "Blue Line", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 3, na(followLine) ? "-" : str.tostring(followLine, format.mintick), text_color=color.white, bgcolor=cellBg)

    table.cell(dash, 0, 4, "Distance", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 4, distanceText, text_color=color.white, bgcolor=cellBg)

    table.cell(dash, 0, 5, "Last Buy", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 5, na(lastBuyPrice) ? "-" : str.tostring(lastBuyPrice, format.mintick), text_color=color.white, bgcolor=color.rgb(0,85,60))

    table.cell(dash, 0, 6, "Last Sell", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 6, na(lastSellPrice) ? "-" : str.tostring(lastSellPrice, format.mintick), text_color=color.white, bgcolor=color.rgb(100,35,45))
````
