# AS 25 kwietnia 2026 - Elephant + SMA Trend + FVG

- url: https://www.tradingview.com/script/q4FYdMYH/
- type: indicator
- pine_id: PUB;4a2d5fbc54f54c72908434ee35b8314a
- version: 1.0

## Description

Zanim pojawili się w moim mieszkaniu mafiosi w towarzystwie śniadolicej poetki Alberty Lulaj,
zanim wyrwali mnie z pijackiego snu i zanim jęli się domagać – wpierw obłudnymi prośbami, potem
bezpardonowymi pogróżkami – bym ułatwił druk wierszy Alberty Lulaj na łamach „Tygodnika
Powszechnego”, zanim nastąpiły burzliwe wydarzenia, o których pragnę opowiedzieć, była wigilia
wydarzeń, był zaranek i był wieczór dnia poprzedzającego, i ja od zaranka do wieczora dnia
poprzedzającego popijałem brzoskwiniówkę. Tak jest, piłem brzoskwiniówkę, zwierzęco tęskniłem
za ostatnią, przedśmiertną miłością i po uszy tkwiłem w życiu rozpustnym.

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
