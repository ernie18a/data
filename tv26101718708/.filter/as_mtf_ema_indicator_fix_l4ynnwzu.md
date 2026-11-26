# AS MTF EMA Indicator FIX

- url: https://www.tradingview.com/script/l4YNNWzu/
- type: indicator
- pine_id: PUB;4f7c01b99e8e4fac8c48664b2a1d2363
- version: 1.0

## Description

n,mn. nlnlnmlmblejtojbjhthj6oibkoivcniuhoiuwngklnbe blkwmlsh6jyo;jlmcainie6

## Source Code

````pine
//@version=6
indicator("AS MTF EMA Indicator FIX", overlay=true)

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
plot(ema_mtf, color=color.rgb(151, 136, 0, 62), offset=ma_offset, linewidth=1)
plot(ema_mtf2, color=color.rgb(0, 57, 103, 18), offset=ma_offset2, linewidth=2)

//────────────────────
// SHAPES
//────────────────────
plotshape(emaUp, location=location.belowbar, style=shape.labelup,
    color=color.rgb(76, 172, 175, 73), size=size.tiny)

plotshape(emaDown, location=location.abovebar, style=shape.labeldown,
    color=color.rgb(241, 255, 82, 79), size=size.tiny)

//────────────────────
// FVG
//────────────────────
extendBars = input.int(3, "Extend")

bullFVG = bar_index > 2 and low > high[2]
bearFVG = bar_index > 2 and high < low[2]

if bullFVG
    box.new(bar_index - 2, low, bar_index + extendBars, high[2],
        bgcolor=color.new(color.green, 80), border_color=na)

if bearFVG
    box.new(bar_index - 2, low[2], bar_index + extendBars, high,
        bgcolor=color.new(color.red, 80), border_color=na)

//────────────────────
// EMA 9 COLOR CANDLES
//────────────────────
len9 = input.int(9, "EMA 9")
ema9 = ta.ema(close, len9)

barcolor(close > ema9 ? color.rgb(0, 122, 4) : color.rgb(146, 0, 0))
plot(ema9, style = plot.style_stepline, color=color.rgb(120, 123, 134, 41))

//────────────────────
// UNIFIED ALERT (FIXED)
//────────────────────
anyEvent = emaUp or emaDown or bullFVG or bearFVG
emaEvent = emaUp or emaDown

alertcondition(emaEvent, title="AS EMA ALERT", message="AS_EMA_EVENT")

alertcondition(anyEvent, title="AS UNIFIED ALERT", message="AS_EVENT")

// OR INPUT
//────────────────────────────────────
orMinutes = input.int(5, "Opening Range Minutes")

showA = input.bool(true, "Azja")
showEurope = input.bool(true, "Europe (London)")
showNY     = input.bool(true, "New York")
showUS     = input.bool(true, "US")
showDS     = input.bool(true, "D")

//────────────────────────────────────
// SESSIONS (exchange time safe)
//───────────────────────────────────
aSess = "1650-1200"   // Azja
euSess = "0250-1800"   // London / Europe session proxy
usSess = "0750-1800"   // US session
nySess = "0920-1600"   // NY session
dSess = "1555-2150"   // NY session

inA = not na(time(timeframe.period, aSess))
inEU = not na(time(timeframe.period, euSess))
inNY = not na(time(timeframe.period, nySess))
inUS = not na(time(timeframe.period, usSess))
inDS = not na(time(timeframe.period, dSess))

newA = inA and not inA[1]
newEU = inEU and not inEU[1]
newNY = inNY and not inNY[1]
newUS = inUS and not inUS[1]
newDS = inDS and not inDS[1]

//────────────────────────────────────
// STATE AZJA
//────────────────────────────────────
var float aHigh = na
var float aLow  = na
var int   aCount = 0
var int   aStart = na
var box   aBox   = na

//────────────────────────────────────
// STATE EUROPE
//────────────────────────────────────
var float euHigh = na
var float euLow  = na
var int   euCount = 0
var int   euStart = na
var box   euBox   = na

//────────────────────────────────────
// STATE US
//────────────────────────────────────
var float usHigh = na
var float usLow  = na
var int   usCount = 0
var int   usStart = na
var box   usBox   = na

//────────────────────────────────────
// STATE NY
//────────────────────────────────────
var float nyHigh = na
var float nyLow  = na
var int   nyCount = 0
var int   nyStart = na
var box   nyBox   = na

//────────────────────────────────────
// STATE DS
//────────────────────────────────────
var float dHigh = na
var float dLow  = na
var int   dCount = 0
var int   dStart = na
var box   dBox   = na

//────────────────────────────────────
// RESET AZJA
//────────────────────────────────────
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
        aBox := box.new(
            left=aStart,
            top=aHigh,
            right=bar_index,
            bottom=aLow,
            bgcolor=color.new(#700074, 69),
            border_color=na
        )

    if not na(aBox)
        box.set_right(aBox, bar_index)
        box.set_top(aBox, aHigh)
        box.set_bottom(aBox, aLow)

//────────────────────────────────────
// RESET EUROPE
//────────────────────────────────────
if newEU
    euHigh := na
    euLow  := na
    euCount := 0
    euStart := bar_index
    euBox := na

if showEurope and inEU
    if euCount < orMinutes
        euHigh := na(euHigh) ? high : math.max(euHigh, high)
        euLow  := na(euLow)  ? low  : math.min(euLow, low)
        euCount += 1

    if euCount == orMinutes and na(euBox)
        euBox := box.new(
            left=euStart,
            top=euHigh,
            right=bar_index,
            bottom=euLow,
            bgcolor=color.new(#818181, 78),
            border_color=na
        )

    if not na(euBox)
        box.set_right(euBox, bar_index)
        box.set_top(euBox, euHigh)
        box.set_bottom(euBox, euLow)

//────────────────────────────────────
// RESET US
//────────────────────────────────────
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
        usBox := box.new(
            left=usStart,
            top=usHigh,
            right=bar_index,
            bottom=usLow,
            bgcolor=color.new(#1100ff, 64),
            border_color=na
        )

    if not na(usBox)
        box.set_right(usBox, bar_index)
        box.set_top(usBox, usHigh)
        box.set_bottom(usBox, usLow)

//────────────────────────────────────
// RESET NY
//────────────────────────────────────
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
        nyBox := box.new(
            left=nyStart,
            top=nyHigh,
            right=bar_index,
            bottom=nyLow,
            bgcolor=color.new(#7b0000, 70),
            border_color=na
        )

    if not na(nyBox)
        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)

//────────────────────────────────────
// RESET DAY
//────────────────────────────────────
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
        dBox := box.new(
            left=dStart,
            top=dHigh,
            right=bar_index,
            bottom=dLow,
            bgcolor=color.new(#fff700, 42),
            border_color=na
        )

    if not na(nyBox)
        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)

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
````
