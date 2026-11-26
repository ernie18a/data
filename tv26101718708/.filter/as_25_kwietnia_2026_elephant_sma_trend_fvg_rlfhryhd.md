# AS 25 kwietnia 2026 - Elephant + SMA Trend + FVG

- url: https://www.tradingview.com/script/RLfHRyhD/
- type: indicator
- pine_id: PUB;5f91634030974e9db24dced73823b724
- version: 1.0

## Description

🇬🇧 ENGLISH DESCRIPTION

AS Indicator – Elephant Bars + SMA Trend + FVG + Sessions + MTF EMA

This is a multi-functional price action and trend indicator that combines volatility detection, trend filtering, liquidity gaps, session analysis, and multi-timeframe levels into one comprehensive tool.

🔹 1. Elephant Bars (Volatility & Momentum)

The indicator detects so-called Elephant Bars — strong impulsive candles defined by:

Range greater than ATR × multiplier
Body size exceeding a minimum percentage of the candle range

These bars signal institutional activity or strong momentum:

🟢 Bullish Elephant → strong buying pressure
🔴 Bearish Elephant → strong selling pressure

Optional labels (🐘) mark these candles directly on the chart.

🔹 2. SMA Trend System

Three Simple Moving Averages are used:

SMA 9 → short-term momentum (also colors candles)
SMA 20 → dynamic trend direction (colored green/red)
SMA 200 → macro trend filter

Trend logic:

Uptrend → SMA20 above SMA200
Downtrend → SMA20 below SMA200
No trend → price too close to SMA200 (range filter)

SMA200 changes color dynamically:

Green → bullish trend
Red → bearish trend
Gray → ranging market
🔹 3. Fair Value Gaps (FVG)

The script identifies inefficiencies in price delivery:

Bullish FVG → current low > high from 2 bars ago
Bearish FVG → current high < low from 2 bars ago

Zones are drawn as colored boxes and extended forward to highlight potential areas of:

liquidity
price rebalancing
institutional interest
🔹 4. Unified Alert System

A single alert triggers when ANY of the following occurs:

Elephant Bar detected
Bullish FVG appears
Bearish FVG appears

This allows efficient monitoring without multiple alert setups.

🔹 5. Market Sessions (Polish Time)

All sessions are calculated in Europe/Warsaw timezone:

Asia
Europe (London proxy)
US
New York
Daily Session (custom Poland session)

For each session:

The Opening Range (first X minutes) is calculated
High/Low is tracked
A dynamic box is drawn and extended in real time

This helps identify:

session liquidity zones
breakout levels
intraday structure
🔹 6. 15-Minute Range Levels (Live & Non-Repainting)

Two independent range systems:

Short lookback (live dynamic range)
Long lookback (strong key levels)

Levels are calculated from 15m data and plotted as horizontal lines:

Resistance (high range)
Support (low range)
🔹 7. Multi-Timeframe EMA (MTF)

Two EMAs from higher timeframes:

EMA 1 (faster HTF)
EMA 2 (slower HTF)

Signals:

EMA crossover up → bullish signal
EMA crossover down → bearish signal

Fully non-repainting (using lookahead_off logic).

🔹 8. Visual Features
Candle coloring based on SMA9
Elephant bars override color for clarity
Clean FVG zones (no borders)
Dynamic session boxes
Strong key levels from HTF data
✅ Summary

This indicator combines:

Momentum (Elephant Bars)
Trend (SMA + EMA)
Liquidity (FVG)
Structure (Opening Ranges & 15m levels)
Time (Sessions in local timezone)

➡️ Designed for intraday traders, price action traders, and smart money concepts users.

🇵🇱 OPIS PO POLSKU

AS Wskaźnik – Elephant Bars + SMA Trend + FVG + Sesje + MTF EMA

To rozbudowany wskaźnik price action, który łączy analizę zmienności, trendu, luk płynności, sesji oraz poziomów z wyższych interwałów w jednym narzędziu.

🔹 1. Elephant Bars (Zmienność i Impuls)

Wskaźnik wykrywa tzw. Elephant Bars:

zakres świecy większy niż ATR × mnożnik
korpus stanowi określony % całej świecy

Interpretacja:

🟢 byczy impuls (silny popyt)
🔴 niedźwiedzi impuls (silna podaż)

Opcjonalnie oznaczane symbolem 🐘 na wykresie.

🔹 2. System SMA (Trend)

Używane średnie:

SMA 9 → krótkoterminowy kierunek (koloruje świece)
SMA 20 → kierunek trendu
SMA 200 → filtr trendu globalnego

Logika:

trend wzrostowy → SMA20 > SMA200
trend spadkowy → SMA20 < SMA200
brak trendu → cena blisko SMA200

Kolory SMA200:

zielony → trend wzrostowy
czerwony → trend spadkowy
szary → konsolidacja
🔹 3. Fair Value Gap (FVG)

Wskaźnik wykrywa luki płynności:

byczy FVG → low > high sprzed 2 świec
niedźwiedzi FVG → high < low sprzed 2 świec

Zaznaczane jako prostokąty:

potencjalne strefy powrotu ceny
miejsca nierównowagi rynku
🔹 4. Jeden wspólny alert

Alert uruchamia się gdy wystąpi:

Elephant Bar
FVG byczy
FVG niedźwiedzi

➡️ Jeden alert zamiast wielu.

🔹 5. Sesje rynkowe (czas polski)

Wszystkie sesje w czasie Europe/Warsaw:

Azja
Europa
USA
New York
DS (sesja dzienna PL)

Dla każdej:

liczony Opening Range (pierwsze minuty)
rysowany box High/Low
aktualizacja w czasie rzeczywistym
🔹 6. Zakresy z 15m (bez repaintu)

Dwa zakresy:

krótkoterminowy (dynamiczny)
długoterminowy (silne poziomy)

Tworzą:

opór (high)
wsparcie (low)
🔹 7. EMA z wyższych TF (MTF)

Dwie EMA z innych interwałów:

szybka
wolna

Sygnały:

przecięcie w górę → kupno
przecięcie w dół → sprzedaż
🔹 8. Wizualizacja
kolorowanie świec
oznaczenia Elephant
czyste FVG (bez ramek)
boxy sesji
linie poziomów HTF
✅ Podsumowanie

Wskaźnik łączy:

impuls (Elephant)
trend (SMA + EMA)
płynność (FVG)
strukturę (range, sesje)
czas (sesje PL)

➡️ Idealny do:

daytradingu
price action
Smart Money Concepts

## Source Code

````pine
//@version=6
indicator("AS 25 kwietnia 2026 - Elephant + SMA Trend + FVG", overlay=true,
     max_boxes_count=200)

//────────────────────
// INPUTY
//────────────────────
atrLen      = input.int(14, "ATR Length")
mult        = input.float(1.5, "ATR Multiplier", step=0.1)
bodyPercent = input.float(0.5, "Min Body % of Range", step=0.05)
showMarks   = input.bool(true, "Show Elephant Marks")

// SMA
sma9Len = input.int(9, "SMA 9")
sma20Len = input.int(20, "SMA 20")
sma200Len = input.int(200, "SMA 200")
rangeFilter = input.float(0.005, "Range filter (distance from SMA200)", step=0.001)

// FVG
showFVG = input.bool(true, "Show FVG")
fvgExtend = input.int(3, "FVG Extend Bars")

//────────────────────
// ELEPHANT
//────────────────────
atr = ta.atr(atrLen)

barRange = high - low
body     = math.abs(close - open)

bodyRatio = barRange > 0 ? body / barRange : 0

isBigRange   = barRange > atr * mult
isStrongBody = bodyRatio > bodyPercent

elephantBar = isBigRange and isStrongBody

bullElephant = elephantBar and close > open
bearElephant = elephantBar and close < open

//────────────────────
// SMA
//────────────────────
sma9  = ta.sma(close, sma9Len)
sma20  = ta.sma(close, sma20Len)
sma200 = ta.sma(close, sma200Len)

sma20Up   = sma20 > sma20[1]

distance = math.abs(close - sma200) / sma200
noTrend = distance < rangeFilter

trendUp   = sma20 > sma200 and not noTrend
trendDown = sma20 < sma200 and not noTrend

colorSMA20 = sma20Up ? color.lime : color.red

colorSMA200 = noTrend ? color.gray :
     trendUp ? color.lime :
     trendDown ? color.red : color.gray

//────────────────────
// FVG LOGIKA
//────────────────────
bullFVG = low > high[2]
bearFVG = high < low[2]

//────────────────────
// WYKRES SMA
//────────────────────
plot(sma9,  color=color.gray, style = plot.style_stepline , linewidth=1, title="SMA 9")
plot(sma20,  color=colorSMA20,  linewidth=1, title="SMA 20")
plot(sma200, color=colorSMA200, linewidth=1, title="SMA 200")

//bar color
barcolor(close > sma9 ? color.rgb(0, 122, 4) : color.rgb(146, 0, 0))

//────────────────────
// ELEPHANT WIZUAL
//────────────────────
barcolor(bullElephant ? color.lime : bearElephant ? color.red : na)

if showMarks and bullElephant
    label.new(bar_index, low, "🐘", 
        style=label.style_label_up, 
        size=size.tiny,
        color=color.lime, 
        textcolor=color.black)

if showMarks and bearElephant
    label.new(bar_index, high, "🐘", 
        style=label.style_label_down, 
        size=size.tiny,
        color=color.red, 
        textcolor=color.white)

//────────────────────
// FVG RYSOWANIE
//────────────────────
if showFVG and bullFVG
    box.new(
        left = bar_index - 2,
        right = bar_index + fvgExtend,
        top = low,
        bottom = high[2],
        bgcolor = color.new(#00980d, 49),
        border_width = 0
    )

if showFVG and bearFVG
    box.new(
        left = bar_index - 2,
        right = bar_index + fvgExtend,
        top = low[2],
        bottom = high,
        bgcolor = color.new(#9b0000, 42),
        border_width = 0
    )

//────────────────────
// UNIFIED ALERT
//────────────────────
anySignal = elephantBar or bullFVG or bearFVG

alertcondition(
    anySignal,
    title="AS UNIFIED ALERT",
    message="Elephant Bar or FVG detected"
)

//────────────────────────────────────
// Opening Range
//────────────────────────────────────
orMinutes = input.int(5, "Opening Range Minutes")

showA = input.bool(true, "Azja")
showEU = input.bool(true, "Europe (London)")
showUS = input.bool(true, "US")
showNY = input.bool(true, "New York")
showDS = input.bool(true, "DS (Poland)")

//────────────────────────────────────
// TIMEZONE (ONLY POLAND)
//────────────────────────────────────
tz = "Europe/Warsaw"

//────────────────────────────────────
// SESSIONS (POLISH TIME)
//────────────────────────────────────
aSess  = "0000-0800"   // Azja
euSess = "0850-1700"   // Europa
usSess = "1350-2200"   // US
nySess = "1520-2250"   // NY
dSess  = "2250-2300"   // DS (Poland)

//────────────────────────────────────
// SESSION DETECTION (ALL IN PL TIME)
//────────────────────────────────────
inA  = not na(time(timeframe.period, aSess, tz))
inEU = not na(time(timeframe.period, euSess, tz))
inUS = not na(time(timeframe.period, usSess, tz))
inNY = not na(time(timeframe.period, nySess, tz))
inDS = not na(time(timeframe.period, dSess, tz))

newA  = inA  and not inA[1]
newEU = inEU and not inEU[1]
newUS = inUS and not inUS[1]
newNY = inNY and not inNY[1]
newDS = inDS and not inDS[1]

//────────────────────────────────────
// AZJA
//────────────────────────────────────
var float aHigh = na
var float aLow  = na
var int aCount  = 0
var int aStart  = na
var box aBox    = na

if newA
    aHigh := na
    aLow  := na
    aCount := 0
    aStart := bar_index
    aBox := na

if showA and inA
    if aCount < orMinutes
        aHigh := na(aHigh) ? high : math.max(aHigh, high)
        aLow  := na(aLow)  ? low  : math.min(aLow, low)
        aCount += 1

    if aCount == orMinutes and na(aBox)
        aBox := box.new(aStart, aHigh, bar_index, aLow,
            bgcolor=color.new(#700074, 70), border_color=na)

    if not na(aBox)
        box.set_right(aBox, bar_index)
        box.set_top(aBox, aHigh)
        box.set_bottom(aBox, aLow)

//────────────────────────────────────
// EUROPE
//────────────────────────────────────
var float euHigh = na
var float euLow  = na
var int euCount  = 0
var int euStart  = na
var box euBox    = na

if newEU
    euHigh := na
    euLow  := na
    euCount := 0
    euStart := bar_index
    euBox := na

if showEU and inEU
    if euCount < orMinutes
        euHigh := na(euHigh) ? high : math.max(euHigh, high)
        euLow  := na(euLow)  ? low  : math.min(euLow, low)
        euCount += 1

    if euCount == orMinutes and na(euBox)
        euBox := box.new(euStart, euHigh, bar_index, euLow,
            bgcolor=color.new(#818181, 78), border_color=na)

    if not na(euBox)
        box.set_right(euBox, bar_index)
        box.set_top(euBox, euHigh)
        box.set_bottom(euBox, euLow)

//────────────────────────────────────
// US
//────────────────────────────────────
var float usHigh = na
var float usLow  = na
var int usCount  = 0
var int usStart  = na
var box usBox    = na

if newUS
    usHigh := na
    usLow  := na
    usCount := 0
    usStart := bar_index
    usBox := na

if showUS and inUS
    if usCount < orMinutes
        usHigh := na(usHigh) ? high : math.max(usHigh, high)
        usLow  := na(usLow)  ? low  : math.min(usLow, low)
        usCount += 1

    if usCount == orMinutes and na(usBox)
        usBox := box.new(usStart, usHigh, bar_index, usLow,
            bgcolor=color.new(#1100ff, 65), border_color=na)

    if not na(usBox)
        box.set_right(usBox, bar_index)
        box.set_top(usBox, usHigh)
        box.set_bottom(usBox, usLow)

//────────────────────────────────────
// NEW YORK
//────────────────────────────────────
var float nyHigh = na
var float nyLow  = na
var int nyCount  = 0
var int nyStart  = na
var box nyBox    = na

if newNY
    nyHigh := na
    nyLow  := na
    nyCount := 0
    nyStart := bar_index
    nyBox := na

if showNY and inNY
    if nyCount < orMinutes
        nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
        nyLow  := na(nyLow)  ? low  : math.min(nyLow, low)
        nyCount += 1

    if nyCount == orMinutes and na(nyBox)
        nyBox := box.new(nyStart, nyHigh, bar_index, nyLow,
            bgcolor=color.new(#7b0000, 70), border_color=na)

    if not na(nyBox)
        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)

//────────────────────────────────────
// DAILY SESSION (POLAND)
//────────────────────────────────────
var float dHigh = na
var float dLow  = na
var int dCount  = 0
var int dStart  = na
var box dBox    = na

if newDS
    dHigh := na
    dLow  := na
    dCount := 0
    dStart := bar_index
    dBox := na

if showDS and inDS
    if dCount < orMinutes
        dHigh := na(dHigh) ? high : math.max(dHigh, high)
        dLow  := na(dLow)  ? low  : math.min(dLow, low)
        dCount += 1

    if dCount == orMinutes and na(dBox)
        dBox := box.new(dStart, dHigh, bar_index, dLow,
            bgcolor=color.new(#fff700, 45), border_color=na)

    if not na(dBox)
        box.set_right(dBox, bar_index)
        box.set_top(dBox, dHigh)
        box.set_bottom(dBox, dLow)

//────────────────────────────────────
// 15m DATA STREAM
//────────────────────────────────────
h15 = request.security(syminfo.tickerid, "15", high)
l15 = request.security(syminfo.tickerid, "15", low)

//────────────────────────────────────
// WINDOW RANGE (last 15m swings, LIVE)
//────────────────────────────────────
length = input.int(20, "15m Bars Lookback")

// zamiast HTF snapshot → budujemy rolling range
rangeHigh = ta.highest(h15, length)
rangeLow  = ta.lowest(l15, length)

//────────────────────────────────────
// LINES
//────────────────────────────────────
var line hiLine = na
var line loLine = na

// create once
if na(hiLine)
    hiLine := line.new(bar_index, rangeHigh, bar_index + 1, rangeHigh, extend=extend.right, color=color.rgb(126, 0, 0), width=2)

if na(loLine)
    loLine := line.new(bar_index, rangeLow, bar_index + 1, rangeLow, extend=extend.right, color=color.rgb(0, 107, 21), width=2)

// update continuously (THIS is key)
line.set_y1(hiLine, rangeHigh)
line.set_y2(hiLine, rangeHigh)

line.set_y1(loLine, rangeLow)
line.set_y2(loLine, rangeLow)

//────────────────────────────────────
// REAL 15m DATA STREAM (NO REPAINT)
//────────────────────────────────────
h15q = request.security(syminfo.tickerid, "15", high, lookahead=barmerge.lookahead_off)
l15q = request.security(syminfo.tickerid, "15", low,  lookahead=barmerge.lookahead_off)

//────────────────────────────────────
// RANGE
//────────────────────────────────────
lengthq = input.int(200, "15m Bars Lookback")

rangeHighq = ta.highest(h15, lengthq)
rangeLowq  = ta.lowest(l15, lengthq)

//────────────────────────────────────
// LINES
//────────────────────────────────────
var line hiLineq = na
var line loLineq = na

if na(hiLineq)
    hiLineq := line.new(bar_index, rangeHighq, bar_index, rangeHighq, extend=extend.right, color=color.rgb(157, 0, 0), width=5)

if na(loLineq)
    loLineq := line.new(bar_index, rangeLowq, bar_index, rangeLowq, extend=extend.right, color=color.rgb(0, 134, 4), width=5)

//────────────────────────────────────
// UPDATE (X + Y !!!)
//────────────────────────────────────
line.set_xy1(hiLineq, bar_index - 1, rangeHighq)
line.set_xy2(hiLineq, bar_index,     rangeHighq)

line.set_xy1(loLineq, bar_index - 1, rangeLowq)
line.set_xy2(loLineq, bar_index,     rangeLowq)

//────────────────────
// INPUTS EMA 1
//────────────────────
ma_len    = input.int(20, "EMA Length 1")
src       = input.source(close, "Source 1")
tf1       = input.timeframe("2", "HTF 1")
ma_offset = input.int(0, "Offset 1")

//────────────────────
// INPUTS EMA 2
//────────────────────
ma_len2   = input.int(20, "EMA Length 2")
src2      = input.source(close, "Source 2")
tf2       = input.timeframe("10", "HTF 2")
ma_offset2 = input.int(0, "Offset 2")

//────────────────────
// PROPER MTF EMA
//────────────────────
ema_mtf = request.security(syminfo.tickerid, tf1, ta.ema(src, ma_len))
ema_mtf2 = request.security(syminfo.tickerid, tf2, ta.ema(src2, ma_len2))

//────────────────────
// SIGNALS
//────────────────────
emaUp   = ta.crossover(close, ema_mtf)
emaDown = ta.crossunder(close, ema_mtf)

//────────────────────
// ALERTS
//────────────────────
alertcondition(emaUp, title="EMA UP", message="EMA_UP")
alertcondition(emaDown, title="EMA DOWN", message="EMA_DOWN")

//────────────────────
// PLOTS
//────────────────────
plot(ema_mtf, color=color.rgb(151, 136, 0, 45), offset=ma_offset, linewidth=1)
plot(ema_mtf2, color=color.rgb(0, 57, 103, 18), offset=ma_offset2, linewidth=2)
````
