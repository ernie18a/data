# AS 28.04.2026 - 1m Elephant + SMA + FVG + Adaptive Centric MA

- url: https://www.tradingview.com/script/sjD2fhfP/
- type: indicator
- pine_id: PUB;055f7e76a3754e84982895e30953420a
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
indicator("AS 28.04.2026 - 1m Elephant + SMA + FVG + Adaptive Centric MA", overlay=true,
     max_boxes_count=200)

//────────────────────
// INPUTY
//────────────────────
atrLen      = input.int(14, "ATR Length")
mult        = input.float(1.5, "ATR Multiplier", step=0.1)
bodyPercent = input.float(0.5, "Min Body % of Range", step=0.05)
showMarks   = input.bool(true, "Show Elephant Marks")

// SMA

sma8Len = input.int(8, "SMA 8")
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

sma8  = ta.sma(close, sma8Len)
sma9 = ta.sma(close, sma9Len)
sma20  = ta.sma(close, sma20Len)
sma200 = ta.sma(close, sma200Len)

sma20Up   = sma20 > sma20[1]

distance = math.abs(close - sma200) / sma200
noTrend = distance < rangeFilter

trendUp   = sma20 > sma200 and not noTrend
trendDown = sma20 < sma200 and not noTrend

colorSMA20 = sma20Up ? color.rgb(0, 137, 11, 60) : color.rgb(134, 1, 1, 68)

colorSMA200 = noTrend ? color.gray :
     trendUp ? color.rgb(22, 167, 0, 51) :
     trendDown ? color.rgb(188, 0, 0, 57) : color.gray

//────────────────────
// FVG LOGIKA
//────────────────────
bullFVG = low > high[2]
bearFVG = high < low[2]

//────────────────────
// WYKRES SMA
//────────────────────
plot(sma8,  color=color.rgb(120, 123, 134, 100), style = plot.style_stepline , linewidth=1, title="SMA 8")
plot(sma9,  color=color.rgb(120, 123, 134, 63), style = plot.style_stepline , linewidth=1, title="SMA 9")
plot(sma20,  color=colorSMA20,  linewidth=1, title="SMA 20")
plot(sma200, color=colorSMA200, linewidth=1, title="SMA 200")

//bar color
barcolor(close > sma8 ? color.rgb(0, 122, 4) : color.rgb(146, 0, 0))

//────────────────────
// ELEPHANT WIZUAL
//────────────────────
barcolor(bullElephant ? color.lime : bearElephant ? color.red : na)

if showMarks and bullElephant
    label.new(bar_index, low, "", 
        style=label.style_label_up, 
        size=size.tiny,
        color=color.rgb(0, 0, 0, 100), 
        textcolor=color.black)

if showMarks and bearElephant
    label.new(bar_index, high, "", 
        style=label.style_label_down, 
        size=size.tiny,
        color=color.rgb(0, 0, 0, 100), 
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
        bgcolor = color.new(#00980d, 80),
        border_width = 0
    )

if showFVG and bearFVG
    box.new(
        left = bar_index - 2,
        right = bar_index + fvgExtend,
        top = low[2],
        bottom = high,
        bgcolor = color.new(#9b0000, 80),
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
            bgcolor=color.new(#5b005e, 79), border_color=na)

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
            bgcolor=color.new(#535353, 78), border_color=na)

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
            bgcolor=color.new(#6d0000, 70), border_color=na)

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
anySignals = emaUp or emaDown 

alertcondition(
    anySignal,
    title="AS UNIFIED ALERT",
    message="Elephant Bar or FVG detected"
)


//────────────────────
// PLOTS
//────────────────────
plot(ema_mtf, color=color.rgb(151, 136, 0, 71), offset=ma_offset, linewidth=1)
plot(ema_mtf2, color=color.rgb(0, 57, 103, 56), offset=ma_offset2, linewidth=2)

OBRefine = input.string('On', 'Order Block Refine', ['On', 'Off'], tooltip = 'If Order Block Refine is Turned on,' + 'an Attempt is made to Detect the Optimal Range' + 'for the Order Block Using an Error Ccorrection Algorithm.', group = 'Order Block Setting')

RefineType = input.string('Defensive', 'Refine Type', ['Defensive', 'Aggressive'], tooltip = 'By Using Aggressive Error Correction Algorithm,' + 'a Large Range is Identified as Block Order.' + 'The Defensive Algorithm Detect a Small Range.', group = 'Order Block Setting')

//Show High and Low
Show_High = input.string('No', 'Show High Level', ['No', 'Yes'], tooltip = 'High Major Levels', group = 'Major Levels')
Show_Low = input.string('No', 'Show Low Level', ['No', 'Yes'], tooltip = 'Low Major Levels', group = 'Major Levels')

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Candle Range
Candle_Range = high - low
//Candle Trend and Candle Body
Candle_Body = close - open
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Candle Trend Detector
Candle_Trend = if Candle_Body > 0
    'Candle Positive'
else if Candle_Body < 0
    'Candle Negative'
else
    'Candle no Trend'
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Candle Break Detector
Candle_Break = if close > high[1]
    'Candle Bull Break'
else if close < low[1]
    'Candle Bear Break'
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //High and Low Detector

bar_index_bull = ta.valuewhen(close > high[1], bar_index, 0)
bar_index_bear = ta.valuewhen(close < low[1], bar_index, 0)

var int start_bar_index_high = 0
var int start_bar_index_low = 0

lenHighest = bar_index - bar_index_bear + 5
lenLowest = bar_index - bar_index_bull + 5

lenHighest1 = bar_index - bar_index_bear + 3
lenLowest1 = bar_index - bar_index_bull + 3
///////////////
HighestLen = if not na(lenHighest)
    lenHighest
else
    1
LowestLen = if not na(lenLowest)
    lenLowest
else
    1

///////////////
HighestLen1 = if not na(lenHighest1)
    lenHighest1
else
    1
LowestLen1 = if not na(lenLowest1)
    lenLowest1
else
    1

//All High and Low Detector
High_first = ta.highest(high, HighestLen)
Low_first = ta.lowest(low, LowestLen)

High_first1 = ta.highest(high, HighestLen1)
Low_first1 = ta.lowest(low, LowestLen1)

//All Correct High and Low Detector
var float High_Correct = 0.0
var float Low_Correct = 0.0
High_sec = if Candle_Break == 'Candle Bear Break' and Candle_Break[1] == 'Candle Bull Break'
    start_bar_index_high := bar_index
    if High_Correct[1] == High_first
        High_first1
    else
        High_first

Low_sec = if Candle_Break == 'Candle Bull Break' and Candle_Break[1] == 'Candle Bear Break'
    start_bar_index_low := bar_index
    if Low_Correct[1] == Low_first
        Low_first1
    else
        Low_first

High_Correct := if not na(High_sec)
    High_sec
else
    High_sec[1]

Low_Correct := if not na(Low_sec)
    Low_sec
else
    Low_sec[1]

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var int bar_index_bull_BoS = 0
var int bar_index_bear_BoS = 0
var string BoS = 'Hi'

var float High_Correct_f = 0.0
var float Low_Correct_f = 0.0

//Major Correct High and Low Detector
High_Correct_f := if High_Correct_f == 0
    High_Correct
else if High_Correct > High_Correct_f[1] and High_Correct_f != 0
    High_Correct
else if High_Correct < High_Correct_f[1]
    if BoS == 'Bear BoS' and bar_index_bear_BoS >= start_bar_index_high
        High_Correct
    else
        High_Correct_f
else if High_Correct_f == High_Correct_f[1] and High_Correct_f != 0
    High_Correct_f
else
    High_Correct

Low_Correct_f := if Low_Correct_f == 0
    Low_Correct
else if Low_Correct < Low_Correct_f[1] and Low_Correct_f != 0
    Low_Correct
else if Low_Correct > Low_Correct_f[1]
    if BoS == 'Bull BoS' and bar_index_bull_BoS >= start_bar_index_low
        Low_Correct
    else
        Low_Correct_f
else if Low_Correct_f == Low_Correct_f[1] and Low_Correct_f != 0
    Low_Correct_f
else
    Low_Correct

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//High and Low Drawing
color_High = High_Correct_f == High_Correct_f[1] ? color.rgb(5, 148, 10) : na
color_Low = Low_Correct_f == Low_Correct_f[1] ? color.rgb(184, 0, 0) : na

plot(High_Correct_f, 'Major High Levels', color = Show_High == 'Yes' ? color_High : na)
plot(Low_Correct_f, 'Major Low Levels', color = Show_Low == 'Yes' ? color_Low : na)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//BoS Detector

if close > High_Correct_f and close[1] <= High_Correct_f
    BoS := 'Bull BoS'
    bar_index_bull_BoS := bar_index
    bar_index_bull_BoS
    //label.set_text(id=Bull_BoS_Label, text="Bull BoS")
else if close < Low_Correct_f and close[1] >= Low_Correct_f
    BoS := 'Bear BoS'
    bar_index_bear_BoS := bar_index
    bar_index_bear_BoS
    //label.set_text(id=Bear_BoS_Label, text="Bear BoS")
else
    BoS := '0'
    BoS

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Trend Detector
var string Trend = 'Hi'

if BoS == 'Bull BoS' and bar_index_bull_BoS[1] > bar_index_bear_BoS
    Trend := 'Up Trend'
    Trend
else if BoS == 'Bear BoS' and bar_index_bear_BoS[1] > bar_index_bull_BoS
    Trend := 'Down Trend'
    Trend
else if Trend == 'Up Trend' and close < Low_Correct_f or Trend == 'Down Trend' and close > High_Correct_f
    Trend := 'No Trend'
    Trend
else
    Trend := Trend
    Trend
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Order Block Detector
bar_index_Supply_OB = ta.valuewhen(High_Correct != High_Correct[1], bar_index[1], 0)
bar_index_Demand_OB = ta.valuewhen(Low_Correct != Low_Correct[1], bar_index[1], 0)
/////////////////////////////////
var DOB_index = 0
var SOB_index = 0

var PerDOB_index = 0
var PerSOB_index = 0

var int DemandCheck = 0
var int SupplyCheck = 0

DOB_index := ta.valuewhen(BoS == 'Bull BoS' and bar_index_bull_BoS[1] > bar_index_bear_BoS or BoS == 'Bull BoS' and bar_index_bull_BoS > bar_index_bear_BoS, bar_index, 0)

SOB_index := ta.valuewhen(BoS == 'Bear BoS' and bar_index_bear_BoS[1] > bar_index_bull_BoS or BoS == 'Bear BoS' and bar_index_bear_BoS > bar_index_bull_BoS, bar_index, 0)

PerDOB_index := ta.valuewhen(BoS == 'Bull BoS' and bar_index_bull_BoS[1] > bar_index_bear_BoS or BoS == 'Bull BoS' and bar_index_bull_BoS > bar_index_bear_BoS, bar_index, 1)

PerSOB_index := ta.valuewhen(BoS == 'Bear BoS' and bar_index_bear_BoS[1] > bar_index_bull_BoS or BoS == 'Bear BoS' and bar_index_bear_BoS > bar_index_bull_BoS, bar_index, 1)

Demand_OB_Condition = (BoS == 'Bull BoS' and bar_index_bull_BoS[1] > bar_index_bear_BoS or BoS == 'Bull BoS' and bar_index_bull_BoS > bar_index_bear_BoS) and DemandCheck != bar_index_Demand_OB

Supply_OB_Condition = (BoS == 'Bear BoS' and bar_index_bear_BoS[1] > bar_index_bull_BoS or BoS == 'Bear BoS' and bar_index_bear_BoS > bar_index_bull_BoS) and SupplyCheck != bar_index_Supply_OB
//BOX Drawing///////////////////////////////////////////////////////////////

//Zones Data
//Demand Zone
//Proximal Line 
var float YDp12 = 0.0
var int XDp1 = 0
var int XDp2 = 0

//Distal Line
var float YDd12 = 0.0
var int XDd1 = 0
var int XDd2 = 0

//Supply Zone 
//Proximal Line 
var float YSp12 = 0.0
var int XSp1 = 0
var int XSp2 = 0

//Distal Line
var float YSd12 = 0.0
var int XSd1 = 0
var int XSd2 = 0

//Oreder Block Refine//////////////////////////////////////////////////////////////////////
ATR = ta.atr(55)
//Demand Candle Range /a : after , b : before , O : Order Block
var float DCRa1 = 0.0
var float DCRO = 0.0
var float DCRb1 = 0.0

if bar_index >= bar_index_Demand_OB + 1
    DCRa1 := Candle_Range[bar_index - bar_index_Demand_OB + 1]
    DCRO := Candle_Range[bar_index - bar_index_Demand_OB]
    DCRb1 := Candle_Range[bar_index - bar_index_Demand_OB - 1]
    DCRb1

//Demand Min ohlc{Var}
var float DminOpen = 0.0
var float DminHigh = 0.0
var float DminLow = 0.0
var float DminClose = 0.0

//Demand Max ohl{Var}
var float DmaxOpen = 0.0
var float DmaxHigh = 0.0
var float DmaxLow = 0.0
var float DmaxClose = 0.0
// Demand Min ohlc{Find}
if bar_index > bar_index_Demand_OB + 1
    DminOpen := math.min(open[bar_index - bar_index_Demand_OB - 2], open[bar_index - bar_index_Demand_OB + 1], open[bar_index - bar_index_Demand_OB], open[bar_index - bar_index_Demand_OB - 1])
    DminHigh := math.min(high[bar_index - bar_index_Demand_OB - 2], high[bar_index - bar_index_Demand_OB + 1], high[bar_index - bar_index_Demand_OB], high[bar_index - bar_index_Demand_OB - 1])
    DminLow := math.min(low[bar_index - bar_index_Demand_OB - 2], low[bar_index - bar_index_Demand_OB + 1], low[bar_index - bar_index_Demand_OB], low[bar_index - bar_index_Demand_OB - 1])
    DminClose := math.min(close[bar_index - bar_index_Demand_OB - 2], close[bar_index - bar_index_Demand_OB + 1], close[bar_index - bar_index_Demand_OB], close[bar_index - bar_index_Demand_OB - 1])
    DminClose
else if bar_index >= bar_index_Demand_OB
    DminOpen := math.min(open[bar_index - bar_index_Demand_OB + 1], open[bar_index - bar_index_Demand_OB], open[bar_index - bar_index_Demand_OB - 1])
    DminHigh := math.min(high[bar_index - bar_index_Demand_OB + 1], high[bar_index - bar_index_Demand_OB], high[bar_index - bar_index_Demand_OB - 1])
    DminLow := math.min(low[bar_index - bar_index_Demand_OB + 1], low[bar_index - bar_index_Demand_OB], low[bar_index - bar_index_Demand_OB - 1])
    DminClose := math.min(close[bar_index - bar_index_Demand_OB + 1], close[bar_index - bar_index_Demand_OB], close[bar_index - bar_index_Demand_OB - 1])
    DminClose

//Demand Max ohlc{Find}
if bar_index > bar_index_Demand_OB + 1
    DmaxOpen := math.max(open[bar_index - bar_index_Demand_OB - 2], open[bar_index - bar_index_Demand_OB + 1], open[bar_index - bar_index_Demand_OB], open[bar_index - bar_index_Demand_OB - 1])
    DmaxHigh := math.max(high[bar_index - bar_index_Demand_OB - 2], high[bar_index - bar_index_Demand_OB + 1], high[bar_index - bar_index_Demand_OB], high[bar_index - bar_index_Demand_OB - 1])
    DmaxLow := math.max(low[bar_index - bar_index_Demand_OB - 2], low[bar_index - bar_index_Demand_OB + 1], low[bar_index - bar_index_Demand_OB], low[bar_index - bar_index_Demand_OB - 1])
    DmaxClose := math.max(close[bar_index - bar_index_Demand_OB - 2], close[bar_index - bar_index_Demand_OB + 1], close[bar_index - bar_index_Demand_OB], close[bar_index - bar_index_Demand_OB - 1])
    DmaxClose
else if bar_index >= bar_index_Demand_OB
    DmaxOpen := math.max(open[bar_index - bar_index_Demand_OB + 1], open[bar_index - bar_index_Demand_OB], open[bar_index - bar_index_Demand_OB - 1])
    DmaxHigh := math.max(high[bar_index - bar_index_Demand_OB + 1], high[bar_index - bar_index_Demand_OB], high[bar_index - bar_index_Demand_OB - 1])
    DmaxLow := math.max(low[bar_index - bar_index_Demand_OB + 1], low[bar_index - bar_index_Demand_OB], low[bar_index - bar_index_Demand_OB - 1])
    DmaxClose := math.max(close[bar_index - bar_index_Demand_OB + 1], close[bar_index - bar_index_Demand_OB], close[bar_index - bar_index_Demand_OB - 1])
    DmaxClose

//Demand Order Block Refiner
var float DDA = 0.0 //Demand Distal Aggressive
var float DPA = 0.0 //Demand Proximal Aggressive

if DCRO <= ATR * 0.5
    DPA := high[bar_index - bar_index_Demand_OB]
    DDA := DminLow
    DDA
else if DCRO > ATR * 0.5 and DCRO <= ATR
    if Candle_Body > 0 or Candle_Body == 0
        DPA := close[bar_index - bar_index_Demand_OB]
        DDA := DminLow
        DDA
    else if Candle_Body < 0
        DPA := open[bar_index - bar_index_Demand_OB]
        DDA := DminLow
        DDA
else if DCRO > ATR
    if low[bar_index - bar_index_Demand_OB + 1] < high[bar_index - bar_index_Demand_OB]
        if low[bar_index - bar_index_Demand_OB + 1] > low[bar_index - bar_index_Demand_OB]
            DPA := low[bar_index - bar_index_Demand_OB + 1]
            DDA := low[bar_index - bar_index_Demand_OB]
            DDA
        else if low[bar_index - bar_index_Demand_OB + 1] <= low[bar_index - bar_index_Demand_OB]
            if Candle_Body[bar_index - bar_index_Demand_OB + 1] > 0 or Candle_Body[bar_index - bar_index_Demand_OB + 1] == 0
                if DCRa1 > ATR
                    DPA := DmaxOpen
                    DDA := DminLow
                    DDA
                else if DCRa1 < ATR
                    DPA := DmaxClose
                    DDA := DminLow
                    DDA
            else if Candle_Body[bar_index - bar_index_Demand_OB + 1] < 0
                if DCRa1 > ATR
                    DPA := DmaxOpen
                    DDA := DminLow
                    DDA
                else if DCRa1 < ATR
                    DPA := DmaxOpen
                    DDA := DminLow
                    DDA
    else if not(low[bar_index - bar_index_Demand_OB + 1] < high[bar_index - bar_index_Demand_OB])
        if DminLow - DminOpen > DminLow - DminClose and DminLow - DminOpen <= ATR and DminLow - DminOpen >= ATR * 0.5
            DPA := DminOpen
            DDA := DminLow
            DDA
        else if DminLow - DminOpen < DminLow - DminClose and DminLow - DminClose <= ATR and DminLow - DminClose >= ATR * 0.5
            DPA := DminClose
            DDA := DminLow
            DDA
else
    if Candle_Body > 0
        DPA := DmaxHigh
        DDA := DminLow
        DDA
    else if Candle_Body < 0
        DPA := DmaxHigh
        DDA := DmaxLow
        DDA

//Supply Candle Range /a : after , b : before , O : Order Block
var float SCRa1 = 0.0
var float SCRO = 0.0
var float SCRb1 = 0.0

SCRa1 := high[bar_index - bar_index_Supply_OB + 1] - low[bar_index - bar_index_Supply_OB + 1]
SCRO := high[bar_index - bar_index_Supply_OB] - low[bar_index - bar_index_Supply_OB]
SCRb1 := high[bar_index - bar_index_Supply_OB - 1] - low[bar_index - bar_index_Supply_OB - 1]

//Supply Min ohlc
var float SminOpen = 0.0
var float SminHigh = 0.0
var float SminLow = 0.0
var float SminClose = 0.0

//Supply Max ohlc
var float SmaxOpen = 0.0
var float SmaxHigh = 0.0
var float SmaxLow = 0.0
var float SmaxClose = 0.0

if bar_index > bar_index_Supply_OB + 1
    SminOpen := math.min(open[bar_index - bar_index_Supply_OB - 2], open[bar_index - bar_index_Supply_OB + 1], open[bar_index - bar_index_Supply_OB], open[bar_index - bar_index_Supply_OB - 1])
    SminHigh := math.min(high[bar_index - bar_index_Supply_OB - 2], high[bar_index - bar_index_Supply_OB + 1], high[bar_index - bar_index_Supply_OB], high[bar_index - bar_index_Supply_OB - 1])
    SminLow := math.min(low[bar_index - bar_index_Supply_OB - 2], low[bar_index - bar_index_Supply_OB + 1], low[bar_index - bar_index_Supply_OB], low[bar_index - bar_index_Supply_OB - 1])
    SminClose := math.min(close[bar_index - bar_index_Supply_OB - 2], close[bar_index - bar_index_Supply_OB + 1], close[bar_index - bar_index_Supply_OB], close[bar_index - bar_index_Supply_OB - 1])
    SminClose
else if bar_index >= bar_index_Supply_OB
    SminOpen := math.min(open[bar_index - bar_index_Supply_OB + 1], open[bar_index - bar_index_Supply_OB], open[bar_index - bar_index_Supply_OB - 1])
    SminHigh := math.min(high[bar_index - bar_index_Supply_OB + 1], high[bar_index - bar_index_Supply_OB], high[bar_index - bar_index_Supply_OB - 1])
    SminLow := math.min(low[bar_index - bar_index_Supply_OB + 1], low[bar_index - bar_index_Supply_OB], low[bar_index - bar_index_Supply_OB - 1])
    SminClose := math.min(close[bar_index - bar_index_Supply_OB + 1], close[bar_index - bar_index_Supply_OB], close[bar_index - bar_index_Supply_OB - 1])
    SminClose

//Dmand Max ohlc
if bar_index > bar_index_Supply_OB + 1
    SmaxOpen := math.max(open[bar_index - bar_index_Supply_OB - 2], open[bar_index - bar_index_Supply_OB + 1], open[bar_index - bar_index_Supply_OB], open[bar_index - bar_index_Supply_OB - 1])
    SmaxHigh := math.max(high[bar_index - bar_index_Supply_OB - 2], high[bar_index - bar_index_Supply_OB + 1], high[bar_index - bar_index_Supply_OB], high[bar_index - bar_index_Supply_OB - 1])
    SmaxLow := math.max(low[bar_index - bar_index_Supply_OB - 2], low[bar_index - bar_index_Supply_OB + 1], low[bar_index - bar_index_Supply_OB], low[bar_index - bar_index_Supply_OB - 1])
    SmaxClose := math.max(close[bar_index - bar_index_Supply_OB - 2], close[bar_index - bar_index_Supply_OB + 1], close[bar_index - bar_index_Supply_OB], close[bar_index - bar_index_Supply_OB - 1])
    SmaxClose
else if bar_index >= bar_index_Supply_OB
    SmaxOpen := math.max(open[bar_index - bar_index_Supply_OB + 1], open[bar_index - bar_index_Supply_OB], open[bar_index - bar_index_Supply_OB - 1])
    SmaxHigh := math.max(high[bar_index - bar_index_Supply_OB + 1], high[bar_index - bar_index_Supply_OB], high[bar_index - bar_index_Supply_OB - 1])
    SmaxLow := math.max(low[bar_index - bar_index_Supply_OB + 1], low[bar_index - bar_index_Supply_OB], low[bar_index - bar_index_Supply_OB - 1])
    SmaxClose := math.max(close[bar_index - bar_index_Supply_OB + 1], close[bar_index - bar_index_Supply_OB], close[bar_index - bar_index_Supply_OB - 1])
    SmaxClose

//Supply Order Block Refiner
var float SDA = 0.0 //Supply Distal Aggressive
var float SPA = 0.0 //Supply Proximal Aggressive

if SCRO <= ATR * 0.5
    SPA := low[bar_index - bar_index_Supply_OB]
    SDA := SmaxHigh
    SDA
else if SCRO > ATR * 0.5 and SCRO <= ATR
    if Candle_Body > 0 or Candle_Body == 0
        SPA := close[bar_index - bar_index_Supply_OB]
        SDA := SmaxHigh
        SDA
    else if Candle_Body < 0
        SPA := open[bar_index - bar_index_Supply_OB]
        SDA := SmaxHigh
        SDA
else if SCRO > ATR
    if high[bar_index - bar_index_Supply_OB - 1] > low[bar_index - bar_index_Supply_OB]
        if high[bar_index - bar_index_Supply_OB - 1] > high[bar_index - bar_index_Supply_OB]
            SPA := high[bar_index - bar_index_Supply_OB - 1]
            SDA := high[bar_index - bar_index_Supply_OB]
            SDA
        else if high[bar_index - bar_index_Supply_OB - 1] <= high[bar_index - bar_index_Supply_OB]
            if Candle_Body[bar_index - bar_index_Supply_OB - 1] > 0 or Candle_Body[bar_index - bar_index_Supply_OB - 1] == 0
                if SCRa1 > ATR
                    SPA := SminClose
                    SDA := SmaxHigh
                    SDA
                else if SCRa1 < ATR
                    SPA := SminOpen
                    SDA := SmaxHigh
                    SDA
            else if Candle_Body[bar_index - bar_index_Supply_OB - 1] < 0
                if SCRa1 > ATR
                    SPA := SminOpen
                    SDA := SmaxHigh
                    SDA
                else if SCRa1 < ATR
                    SPA := SmaxHigh
                    SDA := high[bar_index - bar_index_Supply_OB - 1]
                    SDA
    else if not(high[bar_index - bar_index_Supply_OB + 1] > low[bar_index - bar_index_Supply_OB])
        if SmaxHigh - SminOpen > SmaxHigh - SminClose and SmaxHigh - SminOpen <= ATR and SmaxHigh - SminOpen >= ATR * 0.5
            SPA := SminOpen
            SDA := SmaxHigh
            SDA
        else if SmaxHigh - DminOpen < SmaxHigh - DminClose and SmaxHigh - DminClose <= ATR and SmaxHigh - DminClose >= ATR * 0.5
            SPA := SminClose
            SDA := SmaxHigh
            SDA
else
    if Candle_Body > 0
        SPA := SminLow
        SDA := SmaxHigh
        SDA
    else if Candle_Body < 0
        SPA := SminLow
        SDA := SmaxHigh
        SDA

// choose Type Refine {Aggressive Vs Defensive}
var float DProximal = 0.0
var float DDistal = 0.0
var float SProximal = 0.0
var float SDistal = 0.0
//Demand Order Block choose Type Refine 
if RefineType == 'Defensive'
    if DPA - DDA >= ATR * 3
        DDistal := DDA
        DProximal := DPA - (DPA - DDA) * 0.7
        DProximal
    else if DPA - DDA < ATR * 3 and DPA - DDA >= ATR * 2
        DDistal := DDA
        DProximal := DPA - (DPA - DDA) * 0.6
        DProximal
    else if DPA - DDA < ATR * 2 and DPA - DDA >= ATR * 1.6
        DDistal := DDA
        DProximal := DPA - (DPA - DDA) * 0.5
        DProximal
    else if DPA - DDA < ATR * 1.6 and DPA - DDA > ATR
        DDistal := DDA
        DProximal := DPA - (DPA - DDA) * 0.25
        DProximal
    else if DPA - DDA <= ATR
        DDistal := DDA
        DProximal := DPA
        DProximal
else if RefineType == 'Aggressive'
    DDistal := DDA
    DProximal := DPA
    DProximal

//Supply Order Block choose Type Refine 
if RefineType == 'Defensive'
    if SDA - SPA >= ATR * 3
        SDistal := SDA
        SProximal := SPA + (SDA - SPA) * 0.7
        SProximal
    else if SDA - SPA < ATR * 3 and SDA - SPA >= ATR * 2
        SDistal := SDA
        SProximal := SPA + (SDA - SPA) * 0.6
        SProximal
    else if SDA - SPA < ATR * 2 and SDA - SPA >= ATR * 1.6
        SDistal := SDA
        SProximal := SPA + (SDA - SPA) * 0.5
        SProximal
    else if SDA - SPA < ATR * 1.6 and SDA - SPA > ATR
        SDistal := SDA
        SProximal := SPA + (SDA - SPA) * 0.25
        SProximal
    else if SDA - SPA <= ATR
        SDistal := SDA
        SProximal := SPA
        SProximal
else if RefineType == 'Aggressive'
    SDistal := SDA
    SProximal := SPA
    SProximal
    ////////////////////////
if Demand_OB_Condition
    DemandCheck := bar_index_Demand_OB
    YDp12 := OBRefine == 'On' ? DProximal : high[bar_index - bar_index_Demand_OB]
    XDp1 := bar_index_Demand_OB
    XDp2 := bar_index_Demand_OB + 1
    YDd12 := OBRefine == 'On' ? DDistal : low[bar_index - bar_index_Demand_OB]
    XDd1 := bar_index_Demand_OB
    XDd2 := bar_index_Demand_OB + 1
    XDd2

if Supply_OB_Condition
    SupplyCheck := bar_index_Supply_OB
    YSp12 := OBRefine == 'On' ? SProximal : low[bar_index - bar_index_Supply_OB]
    XSp1 := bar_index_Supply_OB
    XSp2 := bar_index_Supply_OB + 1
    YSd12 := OBRefine == 'On' ? SDistal : high[bar_index - bar_index_Supply_OB]
    XSd1 := bar_index_Supply_OB
    XSd2 := bar_index_Supply_OB + 1
    XSd2

//Dynamic Drawing Zone
LinerFunctionDem(Xd1, Yd1, Xd2, Yd2, Xp1, Yp1, Xp2, Yp2, Xn) =>
    //y = mx + b
    //m = (y2 - y1) / (x2 - x1)
    //b = y - mx
    xd1 = Xd1
    xd2 = Xd2
    yd1 = Yd1
    yd2 = Yd2
    xdn = Xn
    xdnz = Xn
    md = (yd2 - yd1) / (xd2 - xd1)
    bd = yd1 - md * xd1 //or b = y2 - m*x2
    Ydnz = md * xdnz + bd
    Ydn = md * xdn + bd
    xp1 = Xp1
    xp2 = Xp2
    yp1 = Yp1
    yp2 = Yp2
    xpn = Xn
    xpnz = Xn
    mp = (yp2 - yp1) / (xp2 - xp1)
    bp = yp1 - mp * xp1 //or b = y2 - m*x2
    Ypnz = mp * xpnz + bp
    Ypn = mp * xpn + bp
    var bool DemCheck = true
    var int DemCounter = 1
    var line Distal = na
    var line Proximal = na
    var line DLine50per = na
    var linefill fillline = na
    if Demand_OB_Condition
        Distal := line.new(xd1, yd1, xd2, yd1, color = color.rgb(105, 191, 111), style = line.style_dashed, width = 1)
        Proximal := line.new(xp1, yp1, xd2, yp1, color = color.rgb(105, 191, 111), style = line.style_dashed, width = 1)
        DLine50per := line.new(xp1, (yp1 + yd1) / 2, xd2, (yp1 + yd1) / 2, color = color.rgb(0, 0, 0), style = line.style_dotted, width = 1)
        DLine50per
    // fillline := linefill.new(Distal ,Proximal ,color = color.rgb(105, 191, 111, 100) )
    if (low > YDp12 or xd1 == YDp12[1]) and DemCheck == true
        DemCounter := DemCounter + 1
        line.set_x2(Distal, bar_index + 1)
        line.set_x2(Proximal, bar_index + 1)
        line.set_x2(DLine50per, bar_index + 1)

    if low < YDd12 and low[1] > YDd12
        DemCounter := DemCounter
        DemCheck := false
        DemCheck

    if Demand_OB_Condition
        DemCounter := 1
        DemCheck := true
        DemCheck
    [xd1, xd2, yd1, yd2, xdnz, md, bd, Ydnz, xdn, Ydn, xp1, xp2, yp1, yp2, xpnz, mp, bp, Ypnz, xpn, Ypn]


LinerFunctionSup(Xd1, Yd1, Xd2, Yd2, Xp1, Yp1, Xp2, Yp2, Xn) =>
    //y = mx + b
    //m = (y2 - y1) / (x2 - x1)
    //b = y - mx
    xd1 = Xd1
    xd2 = Xd2
    yd1 = Yd1
    yd2 = Yd2
    xdn = Xn
    xdnz = Xn
    md = (yd2 - yd1) / (xd2 - xd1)
    bd = yd1 - md * xd1 //or b = y2 - m*x2
    Ydnz = md * xdnz + bd
    Ydn = md * xdn + bd
    xp1 = Xp1
    xp2 = Xp2
    yp1 = Yp1
    yp2 = Yp2
    xpn = Xn
    xpnz = Xn
    mp = (yp2 - yp1) / (xp2 - xp1)
    bp = yp1 - mp * xp1 //or b = y2 - m*x2
    Ypnz = mp * xpnz + bp
    Ypn = mp * xpn + bp
    var bool SupCheck = true
    var int SupCounter = 1
    var line Distal = na
    var line Proximal = na
    var line SLine50per = na
    var linefill fillline = na
    if Supply_OB_Condition
        Distal := line.new(xd1, yd1, xdnz, yd1, color = color.rgb(242, 34, 51, 45), style = line.style_dashed, width = 1)
        Proximal := line.new(xp1, yp1, xpnz, yp1, color = color.rgb(242, 34, 51, 45), style = line.style_dashed, width = 1)
        SLine50per := line.new(xp1, (yp1 + yd1) / 2, xpnz, (yp1 + yd1) / 2, color = color.rgb(0, 0, 0), style = line.style_dotted, width = 1)
        SLine50per
    // fillline := linefill.new(Distal ,Proximal ,color = color.rgb(242, 34, 51, 100) )
    if (high < YSp12 or xd1 == YSp12[1]) and SupCheck == true
        SupCounter := SupCounter + 1
        line.set_x2(Distal, bar_index + 1)
        line.set_x2(Proximal, bar_index + 1)
        line.set_x2(SLine50per, bar_index + 1)

    if high > YSd12 and high[1] < YSd12
        SupCounter := SupCounter
        SupCheck := false
        SupCheck

    if Supply_OB_Condition
        SupCounter := 1
        SupCheck := true
        SupCheck
    [xd1, xd2, yd1, yd2, xdnz, md, bd, Ydnz, xdn, Ydn, xp1, xp2, yp1, yp2, xpnz, mp, bp, Ypnz, xpn, Ypn]


[DDx1, DDx2, DDy1, DDy2, DDxz, DDm, DDb, DDyz, DDxn, DDyn, DPx1, DPx2, DPy1, DPy2, DPxz, DPm, DPb, DPyz, DPxn, DPyn] = LinerFunctionDem(XDd1, YDd12, XDd2, YDd12, XDp1, YDp12, XDp2, YDp12, bar_index)
[SDx1, SDx2, SDy1, SDy2, SDxz, SDm, SDb, SDyz, SDxn, SDyn, SPx1, SPx2, SPy1, SPy2, SPxz, SPm, SPb, SPyz, SPxn, SPyn] = LinerFunctionSup(XSd1, YSd12, XSd2, YSd12, XSp1, YSp12, XSp2, YSp12, bar_index)

//---------------------------------------------------------------------------------------------------------------------}
// Constants & Inputs
//---------------------------------------------------------------------------------------------------------------------{
color BULL_COLOR = #089981
color BEAR_COLOR = #f23645

// --- Calculation Inputs ---
pivotLenInput       = input.int(10, "Pivot Lookback", minval = 2, group = "Calculation", tooltip = "Number of bars on each side of the pivot.")
zoneMultInput        = input.float(0.4, "Zone Width (dist Multiplier)", minval = 0.1, step = 0.1, group = "Calculation", tooltip = "Determines the vertical thickness of the S&R zones based on dist.")
minTestsInput        = input.int(2, "Minimum Tests to Highlight", minval = 1, group = "Calculation", tooltip = "Only show zones that have been tested at least this many times.")
maxZonesInput        = input.int(10, "Max Active Zones Per Type", minval = 1, maxval = 50, group = "Calculation", tooltip = "Limits the number of support and resistance zones displayed on the chart.")
maxHeightMultInput   = input.float(10.0, "Max Zone Height (dist Multiplier)", minval = 1.0, step = 0.5, group = "Calculation", tooltip = "If a zone becomes wider than this (due to merging), it will be deleted.")

// --- Visual Inputs ---
supportColorInput    = input.color(BULL_COLOR, "Support Color", group = "Visuals")
resistanceColorInput = input.color(BEAR_COLOR, "Resistance Color", group = "Visuals")
showLabelsInput      = input.bool(true, "Show Test Count Labels", group = "Visuals", tooltip = "Display labels showing many times a zone has been tested.")
extendZonesInput     = input.bool(true, "Extend Zones to Right", group = "Visuals", tooltip = "Extend the zone boxes to the current bar.")

//---------------------------------------------------------------------------------------------------------------------}
// Types & Collections
//---------------------------------------------------------------------------------------------------------------------{
type Zone
    float top
    float bottom
    int   testCount
    bool  isSupport
    int   startTime
    box   boxId
    label labelId
    line  lineId
    bool  isBroken
    int   mergeCount

var Zone[] supportZones    = array.new<Zone>()
var Zone[] resistanceZones = array.new<Zone>()

//---------------------------------------------------------------------------------------------------------------------}
// Methods & Functions
//---------------------------------------------------------------------------------------------------------------------{
// Method to check if a zone is broken by price close
// Method to check if a zone is broken by price close
method checkBreak(Zone self, float priceClose) =>
    if not self.isBroken
        if self.isSupport and priceClose < self.bottom
            self.isBroken := true
        else if not self.isSupport and priceClose > self.top
            self.isBroken := true
    self.isBroken

// Method to update visual objects of a zone
method updateVisuals(Zone self, int currentTime, int barDuration, color zoneColor) =>
    if not na(self.boxId)
        box.set_right(self.boxId, currentTime)
        box.set_bgcolor(self.boxId, color.new(zoneColor, self.testCount >= minTestsInput ? 80 : 95))
        box.set_border_color(self.boxId, na)
        
        if showLabelsInput and not na(self.labelId)
            label.set_x(self.labelId, currentTime + barDuration * 2)
            label.set_text(self.labelId, str.tostring(self.testCount))
            label.set_y(self.labelId, (self.top + self.bottom) / 2)
            label.set_textcolor(self.labelId, self.testCount >= minTestsInput ? zoneColor : na)
            label.set_style(self.labelId, label.style_label_left)
            label.set_tooltip(self.labelId, "Merges: " + str.tostring(self.mergeCount))
        
        if not na(self.lineId)
            line.set_x2(self.lineId, currentTime)
            line.set_color(self.lineId, color.new(zoneColor, self.testCount >= minTestsInput ? 50 : 80))

// Function to manage and add zones
manageZones(Zone[] zones, float price, bool isSupport, float width, color zoneColor) =>
    bool found = false
    int currentBarTime = time
    int barDuration = time - time[1]
    
    // Check for existing zones within proximity
    for z in zones
        if price <= z.top and price >= z.bottom
            z.testCount += 1
            found := true
            break
            
    // If no existing zone found, create new one
    if not found
        float top    = isSupport ? price + width / 2 : price + width
        float bottom = isSupport ? price - width : price - width / 2
        int startTime = time[pivotLenInput]
        
        box   b = box.new(startTime, top, time, bottom, 
                         xloc = xloc.bar_time,
                         bgcolor = color.new(zoneColor, 95), 
                         border_color = na)
                         
        label l = showLabelsInput ? label.new(time + barDuration * 2, (top + bottom) / 2, "1", 
                                             xloc = xloc.bar_time,
                                             color = #00000000, 
                                             style = label.style_label_left,
                                             textcolor = 1 >= minTestsInput ? zoneColor : na,
                                             size = size.small) : na
        
        line  li = line.new(startTime, (top + bottom) / 2, time, (top + bottom) / 2, 
                            xloc = xloc.bar_time, 
                            style = line.style_dashed, 
                            color = color.new(zoneColor, 80))
                                             
        array.unshift(zones, Zone.new(top, bottom, 1, isSupport, startTime, b, l, li, false, 0))
        
        // Trim array to keep only maxZonesInput
        if array.size(zones) > maxZonesInput
            Zone old = array.pop(zones)
            box.delete(old.boxId)
            label.delete(old.labelId)
            line.delete(old.lineId)

// Function to merge overlapping zones
mergeZones(Zone[] zones, float maxHeight) =>
    int i = 0
    while i < array.size(zones)
        Zone z1 = array.get(zones, i)
        int j = i + 1
        bool merged = false
        while j < array.size(zones)
            Zone z2 = array.get(zones, j)
            // Check for overlap
            if not (z1.bottom > z2.top or z1.top < z2.bottom)
                // Merge z2 into z1
                z1.top := math.max(z1.top, z2.top)
                z1.bottom := math.min(z1.bottom, z2.bottom)
                z1.testCount += z2.testCount
                z1.mergeCount += z2.mergeCount + 1
                // Anchor to the oldest pivot in the merge
                z1.startTime := math.min(z1.startTime, z2.startTime)
                
                // Update visuals of z1 to reflect new boundaries
                if not na(z1.boxId)
                    box.set_top(z1.boxId, z1.top)
                    box.set_bottom(z1.boxId, z1.bottom)
                    box.set_left(z1.boxId, z1.startTime)
                
                if not na(z1.lineId)
                    line.set_y1(z1.lineId, (z1.top + z1.bottom) / 2)
                    line.set_y2(z1.lineId, (z1.top + z1.bottom) / 2)
                    line.set_x1(z1.lineId, z1.startTime)


                // Delete z2 visuals and remove from collection
                box.delete(z2.boxId)
                label.delete(z2.labelId)
                line.delete(z2.lineId)

                array.remove(zones, j)
                merged := true
            else
                j += 1
        
        // After merging, check if the combined zone is too wide
        if (z1.top - z1.bottom) > maxHeight
            box.delete(z1.boxId)
            label.delete(z1.labelId)
            line.delete(z1.lineId)

            array.remove(zones, i)
            continue // Index shifted, don't increment i
            
        if merged
            continue
        i += 1

//---------------------------------------------------------------------------------------------------------------------}
// Main Logic
//---------------------------------------------------------------------------------------------------------------------{
float dist = ta.cum(math.abs(high-low)) / (bar_index+1)
float zoneWidth = (na(dist) ? close * 0.01 : dist) * zoneMultInput

float ph = ta.pivothigh(pivotLenInput, pivotLenInput)
float pl = ta.pivotlow(pivotLenInput, pivotLenInput)

// Handle Resistance (Pivot Highs)
if not na(ph)
    manageZones(resistanceZones, ph, false, zoneWidth, resistanceColorInput)
    mergeZones(resistanceZones, dist * maxHeightMultInput)

// Handle Support (Pivot Lows)
if not na(pl)
    manageZones(supportZones, pl, true, zoneWidth, supportColorInput)
    mergeZones(supportZones, dist * maxHeightMultInput)

// Check for breaks and update all zones
if array.size(supportZones) > 0
    for i = array.size(supportZones) - 1 to 0
        Zone z = array.get(supportZones, i)
        if z.checkBreak(close)
            box.delete(z.boxId)
            label.delete(z.labelId)
            line.delete(z.lineId)

            array.remove(supportZones, i)
        else if barstate.islast
            z.updateVisuals(time, time - time[1], supportColorInput)

if array.size(resistanceZones) > 0
    for i = array.size(resistanceZones) - 1 to 0
        Zone z = array.get(resistanceZones, i)
        if z.checkBreak(close)
            box.delete(z.boxId)
            label.delete(z.labelId)
            line.delete(z.lineId)

            array.remove(resistanceZones, i)
        else if barstate.islast
            z.updateVisuals(time, time - time[1], resistanceColorInput)

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
//---------------------------------------------------------------------------------------------------------------------{
priceGroup          = 'Price Settings'
srcInput            = input.source(close, 'Source', group = priceGroup)
lengthInput         = input.int(10, 'Length', minval = 1, group = priceGroup)

amaGroup            = 'Adaptive Settings'
attenuationInput    = input.float(1, 'Attenuation Factor', minval = 0.1, step = 0.1, group = amaGroup, tooltip = 'Controls the intensity of the price input and the base smoothing speed.')
powerInput          = input.float(2, 'Power Factor', minval = 0.1, step = 0.1, group = amaGroup, tooltip = 'Exponents the smoothing factor. Higher values make the MA flatter when price is near the range midpoint.')

colorGroup          = 'Colors'
amaColorInput       = input.color(#5b9cf6, 'AMA Color', group = colorGroup)
bullColorInput      = input.color(#089981, 'Bullish Fill', group = colorGroup)
bearColorInput      = input.color(#f23645, 'Bearish Fill', group = colorGroup)

//---------------------------------------------------------------------------------------------------------------------}
// Calculations
//---------------------------------------------------------------------------------------------------------------------{
// Pre-Smoothing sources using Length
srcq   = ta.sma(srcInput, lengthInput)
sHigh = ta.sma(high, lengthInput)
sLow  = ta.sma(low, lengthInput)

// Range boundaries
h = ta.highest(sHigh, lengthInput)
l = ta.lowest(sLow, lengthInput)

// Normalization logic (Relative position 0-100)
stoch = ta.stoch(srcq, h, l, lengthInput)

// Adaptive Logic
// alphaBase = (abs(stoch - 50) / 100) / attenuation
// alpha     = pow(alphaBase, power)
float alphaBase = (math.abs(stoch - 50) / 100) / attenuationInput
float alpha     = math.pow(alphaBase, powerInput)

float mid    = (h + l) / 2
float srcAma = mid + (srcq - mid) / attenuationInput

var float amaValue = src
amaValue := nz(amaValue[1]) + alpha * (srcAma - nz(amaValue[1]))

//---------------------------------------------------------------------------------------------------------------------}
// Visuals
//---------------------------------------------------------------------------------------------------------------------{
// AMA Plot
amaPlotId = plot(amaValue, 'Adaptive Centric Moving Average', amaColorInput, 1)

// Price Plot (for fills)
pricePlotId = plot(src, 'Source Price', display = display.none)

// Fill - Gradient from AMA to Price
fill(amaPlotId, pricePlotId, 
     top_value    = math.max(srcq, amaValue), 
     bottom_value = math.min(srcq, amaValue),
     top_color    = srcq > amaValue ? color.new(bullColorInput, 70) : color.new(chart.bg_color, 80),
     bottom_color = srcq > amaValue ? color.new(chart.bg_color, 80) : color.new(bearColorInput, 70),
     title        = 'Price-AMA Gradient')

//---------------------------------------------------------------------------------------------------------------------}
````
