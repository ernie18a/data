# EMA Pullback Engine - Ratnam

- url: https://www.tradingview.com/script/otJkqnyo-EMA-Pullback-Engine-Ratnam/
- type: indicator
- pine_id: PUB;01abcb6a9fac48a29235ec683585bd6f
- version: 1.0

## Description

Helps identify pivots near 20 and 50 EMA on 15 min and 1H timeframe while aligning the trends on Higher Time Frame as well

## Source Code

````pine
//@version=6
indicator("EMA Pullback Engine", overlay=true, max_labels_count=500)

// ================= INPUTS =================

// ===== EMA SETTINGS =====
len1 = input.int(50, minval=1, title="First", group="EMA")
src1 = input.source(close, title="Source", group="EMA")

len2 = input.int(100, minval=1, title="Second", group="EMA")
src2 = input.source(close, title="Source", group="EMA")

len3 = input.int(200, minval=1, title="Third", group="EMA")
src3 = input.source(close, title="Source", group="EMA")

len4 = input.int(400, minval=1, title="Fourth", group="EMA")
src4 = input.source(close, title="Source", group="EMA")

// ===== RISK SETTINGS =====
maxSL = input.float(2.0, "Max Stop Loss %", step=0.1, group="RISK")

// ===== BACKGROUND SETTINGS =====
showBG = input.bool(true, "Show Trend Background", group="BACKGROUND")
bullColor = input.color(color.new(color.green, 85), "Bull Background Color", group="BACKGROUND")
bearColor = input.color(color.new(color.red, 85), "Bear Background Color", group="BACKGROUND")

// ===== GENERAL SETTINGS =====
thresholdPct = input.float(1.0, "EMA Proximity %", step=0.1, group="GENERAL")
threshold = thresholdPct / 100
lookbackBars = input.int(400, "Label Lookback Bars", minval=50, group="GENERAL")
viewLabels = input.bool(true, "View Labels", group="GENERAL")

// ================= EMA DISPLAY =================

ema_1 = ta.ema(src1, len1)
plot(ema_1, title="EMA - 1", color=#fc4c2a, linewidth=4)

ema_2 = ta.ema(src2, len2)
plot(ema_2, title="EMA - 2", color=#35b4b8, linewidth=4)

ema_3 = ta.ema(src3, len3)
plot(ema_3, title="EMA - 3", color=#2e3440, linewidth=4)

ema_4 = ta.ema(src4, len4)
plot(ema_4, title="EMA - 4", color=#9b9e9e, linewidth=4)
showTargetLines = input.bool(true, "Show Target Lines", group="GENERAL")
// ================= CORE VARIABLES =================

var float entryPrice = na
var float stopLossPctLong  = na
var float stopLossPctShort = na
var int signalEMA = na

int touchEMA_Bull = 0
int touchEMA_Bear = 0

ema20  = ta.ema(close,20)
ema50  = ta.ema(close,50)
ema200 = ta.ema(close,200)

// ================= PIVOT ENGINE =================

bullPivot(L,R)=>
    p = R
    cond = true
    for i = 1 to L
        cond := cond and low[p] < low[p+i]
    for i = 1 to R
        cond := cond and low[p] < low[p-i]
    cond

bearPivot(L,R)=>
    p = R
    cond = true
    for i = 1 to L
        cond := cond and high[p] > high[p+i]
    for i = 1 to R
        cond := cond and high[p] > high[p-i]
    cond

// ================= PIVOT PRIORITY =================

leftArr  = array.from(3,5,1,4,2,3,2,2,3,1,2,1)
rightArr = array.from(3,1,5,2,4,2,3,2,1,3,1,2)

var int pivotBullIndex = na
var int pivotBearIndex = na

pivotBullIndex := na
pivotBearIndex := na

for i = 0 to array.size(leftArr)-1
    L = array.get(leftArr,i)
    R = array.get(rightArr,i)

    if na(pivotBullIndex)
        if bullPivot(L,R)
            pivotBullIndex := R

    if na(pivotBearIndex)
        if bearPivot(L,R)
            pivotBearIndex := R

isPivotLow  = not na(pivotBullIndex)
isPivotHigh = not na(pivotBearIndex)

// ================= HTF TREND =================

ema20_D  = request.security(syminfo.tickerid,"D",ta.ema(close,20))[1]
ema50_D  = request.security(syminfo.tickerid,"D",ta.ema(close,50))[1]
ema200_D = request.security(syminfo.tickerid,"D",ta.ema(close,200))[1]
rsi_D    = request.security(syminfo.tickerid,"D",ta.rsi(close,14))[1]

ema20SlopeUp   = ema20_D > ema20_D[5]
ema20SlopeDown = ema20_D < ema20_D[5]

emaDistance = math.abs(ema20_D - ema50_D) / close

bullTrendok =
     ema20_D > ema50_D and
     ema50_D > ema200_D and
     ema20SlopeUp and
     rsi_D > 55 and
     emaDistance > 0.003

bearTrendOk =
     ema20_D < ema50_D and
     ema50_D < ema200_D and
     ema20SlopeDown and
     rsi_D < 45 and
     emaDistance > 0.003

// ================= BACKGROUND =================

bullEMAStack = ema20_D > ema50_D and ema50_D > ema200_D
bearEMAStack = ema20_D < ema50_D and ema50_D < ema200_D

bgColor = bullEMAStack ? bullColor : bearEMAStack ? bearColor : na
bgcolor(showBG ? bgColor : na, editable=false)

// ================= EMA TOUCH =================

touchEMA_Bull := 0
touchEMA_Bear := 0

if isPivotLow
    if math.abs(low[pivotBullIndex]-ema200)/ema200 <= threshold
        touchEMA_Bull := 200
    else if math.abs(low[pivotBullIndex]-ema50)/ema50 <= threshold
        touchEMA_Bull := 50
    else if math.abs(low[pivotBullIndex]-ema20)/ema20 <= threshold
        touchEMA_Bull := 20

if isPivotHigh
    if math.abs(high[pivotBearIndex]-ema20)/ema20 <= threshold
        touchEMA_Bear := 20
    else if math.abs(high[pivotBearIndex]-ema50)/ema50 <= threshold
        touchEMA_Bear := 50
    else if math.abs(high[pivotBearIndex]-ema200)/ema200 <= threshold
        touchEMA_Bear := 200

validPullbackBull = touchEMA_Bull != 0
validPullbackBear = touchEMA_Bear != 0

// ================= BREAK CONFIRM =================

confirmBreakLong  = isPivotLow  and close > high[pivotBullIndex]
confirmBreakShort = isPivotHigh and close < low[pivotBearIndex]

// ================= SIGNALS =================

longSignal  = bullTrendok and validPullbackBull and confirmBreakLong and barstate.isconfirmed
shortSignal = bearTrendOk and validPullbackBear and confirmBreakShort and barstate.isconfirmed

longSignalEvent  = longSignal  and not longSignal[1]
shortSignalEvent = shortSignal and not shortSignal[1]

if longSignalEvent
    signalEMA := touchEMA_Bull
    stopLossPctLong := (close - low[pivotBullIndex]) / close

if shortSignalEvent
    signalEMA := touchEMA_Bear
    stopLossPctShort := (high[pivotBearIndex] - close) / close

// ================= SL FILTER =================

validLongSL  = longSignalEvent  and (stopLossPctLong * 100 <= maxSL)
validShortSL = shortSignalEvent and (stopLossPctShort * 100 <= maxSL)

// ================= ALERTS =================

if validLongSL
    alert(
        syminfo.ticker + " | BUY | EMA " + str.tostring(signalEMA) +
        " | SL " + str.tostring(stopLossPctLong * 100, "#.##") + "%",
        alert.freq_once_per_bar_close)

if validShortSL
    alert(
        syminfo.ticker + " | SELL | EMA " + str.tostring(signalEMA) +
        " | SL " + str.tostring(stopLossPctShort * 100, "#.##") + "%",
        alert.freq_once_per_bar_close)

// ================= LABELS =================

showLabels = viewLabels and (bar_index > (last_bar_index - lookbackBars))

if showLabels and longSignalEvent
    label.new(bar_index[pivotBullIndex], low[pivotBullIndex],
        "BUY | EMA " + str.tostring(signalEMA) + " | SL " + str.tostring(stopLossPctLong*100,"#.##") + "%",
        style=label.style_label_up, color=color.green, textcolor=color.white)

if showLabels and shortSignalEvent
    label.new(bar_index[pivotBearIndex], high[pivotBearIndex],
        "SELL | EMA " + str.tostring(signalEMA) + " | SL " + str.tostring(stopLossPctShort*100,"#.##") + "%",
        style=label.style_label_down, color=color.red, textcolor=color.white)

// ================= TARGET LINE (WORKING FINAL) =================

if showTargetLines and showLabels and validLongSL
    entry = close
    targetPrice = entry * (1 + stopLossPctLong * 2)

    pivotBar = bar_index - pivotBullIndex

    line.new(
        x1 = pivotBar - 5,
        y1 = targetPrice,
        x2 = math.min(bar_index, pivotBar + 5),
        y2 = targetPrice,
        xloc = xloc.bar_index,
        color = color.green,
        width = 2
    )

if showTargetLines and showLabels and validShortSL
    entry = close
    targetPrice = entry * (1 - stopLossPctShort * 2)

    pivotBar = bar_index - pivotBearIndex

    line.new(
        x1 = pivotBar - 5,
        y1 = targetPrice,
        x2 = math.min(bar_index, pivotBar + 5),
        y2 = targetPrice,
        xloc = xloc.bar_index,
        color = color.red,
        width = 2
    )
````
