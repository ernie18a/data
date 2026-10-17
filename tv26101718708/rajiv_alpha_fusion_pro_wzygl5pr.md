# Rajiv Alpha Fusion Pro

- url: https://www.tradingview.com/script/wZygl5Pr-Rajiv-Alpha-Fusion-Pro/
- type: indicator
- pine_id: PUB;03d366f5aa4c4ef1aaf2773336f30581
- version: 1.0

## Description

Rajiv Alpha Fusion Pro is a multi-confirmation intraday and swing trading indicator built for TradingView.
It combines multiple trend-following systems to generate high-probability BUY and SELL signals with automatic entry, stoploss, and multi-target levels.

Indicators Used
SuperTrend → Main trend direction
UT Bot → Momentum-based entry trigger
HalfTrend → Trend reversal confirmation
AlphaTrend → Additional trend strength filter
ATR → Dynamic stoploss calculation
Signal Logic

BUY signals are generated only when all enabled indicators confirm bullish momentum.

SELL signals are generated only when all enabled indicators confirm bearish momentum.

Confirmation structure:
Signal=SuperTrend∧UTBot∧HalfTrend∧AlphaTrend

Features
Multi-indicator confirmation system
ATR-based dynamic stoploss
Automatic Target 1, Target 2, and Target 3
Risk Reward structure:
TP1 = 1:2
TP2 = 1:3
TP3 = 1:4
Entry, Stoploss, and Target lines with labels
BUY and SELL arrows on chart
Webhook/function-call alerts
Enable/Disable any indicator individually
Works automatically on chart timeframe
Suitable for:
Scalping
Intraday trading
Swing trading
Risk Management Formula

Target=Entry±(Risk×RR)

Best Timeframes
1 Minute
3 Minute
5 Minute
15 Minute
1 Hour
Recommended Usage
Best used in trending markets
Combine with proper risk management
Avoid low-volume sideways markets
Use higher timeframe trend confirmation for better accuracy

## Source Code

````pine
//@version=5
indicator("Rajiv Alpha Fusion Pro", overlay = true)

//====================================================
// ENABLE / DISABLE INDICATORS
//====================================================

useSuperTrend = input.bool(true,  title = "Enable SuperTrend")
useUTBot      = input.bool(true,  title = "Enable UT Bot")
useHalfTrend  = input.bool(true,  title = "Enable HalfTrend")
useAlphaTrend = input.bool(true,  title = "Enable AlphaTrend")

//====================================================
// INPUTS
//====================================================

// SuperTrend
stAtrPeriod = input.int(10, title="SuperTrend ATR Period")
stFactor    = input.float(3.0, title="SuperTrend Factor")

// UT Bot
utKeyValue  = input.int(1, title="UT Bot Key Value")
utAtrPeriod = input.int(10, title="UT Bot ATR Period")

// HalfTrend
htAmplitude = input.int(2, title="HalfTrend Amplitude")

// AlphaTrend
alphaATRPeriod = input.int(14, title="AlphaTrend ATR Period")
alphaMultiplier = input.float(1.0, title="AlphaTrend Multiplier")

// ATR Stoploss
slAtrPeriod     = input.int(14, title="SL ATR Period")
slAtrMultiplier = input.float(1.5, title="SL ATR Multiplier")

// Targets
rr1 = 2.0
rr2 = input.float(3.0, title="Target 2 RR")
rr3 = input.float(4.0, title="Target 3 RR")

// Line Length
lineLength = input.int(25, title="Line Length")

//====================================================
// SUPER TREND
//====================================================

[supertrend, direction] = ta.supertrend(stFactor, stAtrPeriod)

stBull = direction < 0
stBear = direction > 0

plot(
     useSuperTrend ? supertrend : na,
     title="SuperTrend",
     color=stBull ? color.lime : color.red,
     linewidth=2)

//====================================================
// UT BOT
//====================================================

utATR = ta.atr(utAtrPeriod)
nLoss = utKeyValue * utATR

src = close

var float xATRTrailingStop = na

xATRTrailingStop :=
     src > nz(xATRTrailingStop[1]) and src[1] > nz(xATRTrailingStop[1]) ?
     math.max(nz(xATRTrailingStop[1]), src - nLoss) :

     src < nz(xATRTrailingStop[1]) and src[1] < nz(xATRTrailingStop[1]) ?
     math.min(nz(xATRTrailingStop[1]), src + nLoss) :

     src > nz(xATRTrailingStop[1]) ?
     src - nLoss :
     src + nLoss

utBuy  = ta.crossover(src, xATRTrailingStop)
utSell = ta.crossunder(src, xATRTrailingStop)

plot(
     useUTBot ? xATRTrailingStop : na,
     title="UT Bot",
     color=color.yellow,
     linewidth=2)

//====================================================
// HALF TREND
//====================================================

highestHigh = ta.highest(high, htAmplitude)
lowestLow   = ta.lowest(low, htAmplitude)

var int trend = 0

if close > highestHigh[1]
    trend := 1
else if close < lowestLow[1]
    trend := -1
else
    trend := nz(trend[1])

htBull = trend == 1
htBear = trend == -1

//====================================================
// ALPHA TREND
//====================================================

alphaATR = ta.atr(alphaATRPeriod)

upT   = low - (alphaATR * alphaMultiplier)
downT = high + (alphaATR * alphaMultiplier)

var float AlphaTrend = na

AlphaTrend :=
     close > nz(AlphaTrend[1]) ?
     math.max(upT, nz(AlphaTrend[1])) :
     math.min(downT, nz(AlphaTrend[1]))

alphaBull = close > AlphaTrend
alphaBear = close < AlphaTrend

plot(
     useAlphaTrend ? AlphaTrend : na,
     title="AlphaTrend",
     color=alphaBull ? color.aqua : color.orange,
     linewidth=2)

//====================================================
// CONDITIONAL CONFIRMATIONS
//====================================================

stBuyConfirm =
     useSuperTrend ? stBull : true

stSellConfirm =
     useSuperTrend ? stBear : true

utBuyConfirm =
     useUTBot ? utBuy : true

utSellConfirm =
     useUTBot ? utSell : true

htBuyConfirm =
     useHalfTrend ? htBull : true

htSellConfirm =
     useHalfTrend ? htBear : true

alphaBuyConfirm =
     useAlphaTrend ? alphaBull : true

alphaSellConfirm =
     useAlphaTrend ? alphaBear : true

//====================================================
// FINAL SIGNALS
//====================================================

buySignal =
     stBuyConfirm and
     utBuyConfirm and
     htBuyConfirm and
     alphaBuyConfirm

sellSignal =
     stSellConfirm and
     utSellConfirm and
     htSellConfirm and
     alphaSellConfirm

//====================================================
// ATR STOPLOSS
//====================================================

slATR = ta.atr(slAtrPeriod)

//====================================================
// VARIABLES
//====================================================

var float entryPrice = na
var float stopLoss   = na

var float target1 = na
var float target2 = na
var float target3 = na

//====================================================
// LINE VARIABLES
//====================================================

var line entryLine = na
var line slLine    = na

var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

//====================================================
// LABEL VARIABLES
//====================================================

var label entryLbl = na
var label slLbl    = na

var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na

//====================================================
// BUY SIGNAL
//====================================================

if buySignal

    entryPrice := close
    stopLoss   := entryPrice - (slATR * slAtrMultiplier)

    risk = entryPrice - stopLoss

    target1 := entryPrice + (risk * rr1)
    target2 := entryPrice + (risk * rr2)
    target3 := entryPrice + (risk * rr3)

    // Delete Old Objects
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)

    label.delete(entryLbl)
    label.delete(slLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)

    // Entry
    entryLine := line.new(
         bar_index,
         entryPrice,
         bar_index + lineLength,
         entryPrice,
         color=color.green,
         width=3)

    entryLbl := label.new(
         bar_index + lineLength,
         entryPrice,
         "ENTRY",
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white)

    // Stoploss
    slLine := line.new(
         bar_index,
         stopLoss,
         bar_index + lineLength,
         stopLoss,
         color=color.red,
         width=3)

    slLbl := label.new(
         bar_index + lineLength,
         stopLoss,
         "STOPLOSS",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    // TP1
    tp1Line := line.new(
         bar_index,
         target1,
         bar_index + lineLength,
         target1,
         color=color.blue,
         width=3)

    tp1Lbl := label.new(
         bar_index + lineLength,
         target1,
         "TARGET 1",
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    // TP2
    tp2Line := line.new(
         bar_index,
         target2,
         bar_index + lineLength,
         target2,
         color=color.aqua,
         width=3)

    tp2Lbl := label.new(
         bar_index + lineLength,
         target2,
         "TARGET 2",
         style=label.style_label_left,
         color=color.aqua,
         textcolor=color.black)

    // TP3
    tp3Line := line.new(
         bar_index,
         target3,
         bar_index + lineLength,
         target3,
         color=color.purple,
         width=3)

    tp3Lbl := label.new(
         bar_index + lineLength,
         target3,
         "TARGET 3",
         style=label.style_label_left,
         color=color.purple,
         textcolor=color.white)

//====================================================
// SELL SIGNAL
//====================================================

if sellSignal

    entryPrice := close
    stopLoss   := entryPrice + (slATR * slAtrMultiplier)

    risk = stopLoss - entryPrice

    target1 := entryPrice - (risk * rr1)
    target2 := entryPrice - (risk * rr2)
    target3 := entryPrice - (risk * rr3)

    // Delete Old Objects
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)

    label.delete(entryLbl)
    label.delete(slLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)

    // Entry
    entryLine := line.new(
         bar_index,
         entryPrice,
         bar_index + lineLength,
         entryPrice,
         color=color.orange,
         width=3)

    entryLbl := label.new(
         bar_index + lineLength,
         entryPrice,
         "ENTRY",
         style=label.style_label_left,
         color=color.orange,
         textcolor=color.white)

    // Stoploss
    slLine := line.new(
         bar_index,
         stopLoss,
         bar_index + lineLength,
         stopLoss,
         color=color.red,
         width=3)

    slLbl := label.new(
         bar_index + lineLength,
         stopLoss,
         "STOPLOSS",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    // TP1
    tp1Line := line.new(
         bar_index,
         target1,
         bar_index + lineLength,
         target1,
         color=color.blue,
         width=3)

    tp1Lbl := label.new(
         bar_index + lineLength,
         target1,
         "TARGET 1",
         style=label.style_label_left,
         color=color.blue,
         textcolor=color.white)

    // TP2
    tp2Line := line.new(
         bar_index,
         target2,
         bar_index + lineLength,
         target2,
         color=color.aqua,
         width=3)

    tp2Lbl := label.new(
         bar_index + lineLength,
         target2,
         "TARGET 2",
         style=label.style_label_left,
         color=color.aqua,
         textcolor=color.black)

    // TP3
    tp3Line := line.new(
         bar_index,
         target3,
         bar_index + lineLength,
         target3,
         color=color.purple,
         width=3)

    tp3Lbl := label.new(
         bar_index + lineLength,
         target3,
         "TARGET 3",
         style=label.style_label_left,
         color=color.purple,
         textcolor=color.white)

//====================================================
// BUY & SELL ARROWS
//====================================================

plotshape(
     buySignal,
     title="BUY",
     style=shape.arrowup,
     location=location.belowbar,
     color=color.lime,
     size=size.large)

plotshape(
     sellSignal,
     title="SELL",
     style=shape.arrowdown,
     location=location.abovebar,
     color=color.red,
     size=size.large)

//====================================================
// FUNCTION CALL ALERTS
//====================================================

buyMessage =
     '{"function":"rajiv",' +
     '"signal":"BUY",' +
     '"symbol":"' + syminfo.ticker + '",' +
     '"entry":"' + str.tostring(entryPrice) + '",' +
     '"stoploss":"' + str.tostring(stopLoss) + '",' +
     '"target1":"' + str.tostring(target1) + '",' +
     '"target2":"' + str.tostring(target2) + '",' +
     '"target3":"' + str.tostring(target3) + '"}'

sellMessage =
     '{"function":"rajiv",' +
     '"signal":"SELL",' +
     '"symbol":"' + syminfo.ticker + '",' +
     '"entry":"' + str.tostring(entryPrice) + '",' +
     '"stoploss":"' + str.tostring(stopLoss) + '",' +
     '"target1":"' + str.tostring(target1) + '",' +
     '"target2":"' + str.tostring(target2) + '",' +
     '"target3":"' + str.tostring(target3) + '"}'

if buySignal
    alert(buyMessage, alert.freq_once_per_bar_close)

if sellSignal
    alert(sellMessage, alert.freq_once_per_bar_close)

//====================================================
// ALERT CONDITIONS
//====================================================

alertcondition(buySignal, title="BUY SIGNAL", message="BUY SIGNAL")
alertcondition(sellSignal, title="SELL SIGNAL", message="SELL SIGNAL")
````
