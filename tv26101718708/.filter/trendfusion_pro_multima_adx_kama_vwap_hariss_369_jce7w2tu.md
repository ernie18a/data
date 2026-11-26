# TrendFusion Pro | Multi-MA + ADX + KAMA + VWAP Hariss 369

- url: https://www.tradingview.com/script/JCE7w2tU-TrendFusion-Pro-Multi-MA-ADX-KAMA-VWAP-Hariss-369/
- type: indicator
- pine_id: PUB;664c73b3ee1b4ee181ed68f6d26b6385
- version: 1.0

## Description

A flexible multi-timeframe trend-following indicator designed to identify bullish and bearish market conditions using configurable Moving Average alignment.

The system allows traders to combine up to three Moving Averages, with independent settings for MA type, length and timeframe. Supported MA types include EMA, SMA, WMA, VWMA, RMA and HMA.

Core Features

• Three independently configurable Moving Averages
• EMA, SMA, WMA, VWMA, RMA and HMA support
• Individual timeframe selection for each MA
• Flexible MA alignment logic for BUY and SELL conditions
• Optional DMI/ADX trend-strength filter
• Optional Higher-Timeframe KAMA trend filter
• Optional Higher-Timeframe VWAP filter
• ATR-based dynamic trailing stop
• Separate long and short ATR trailing stops
• BUY and SELL signals with configurable colours
• Alert conditions for BUY and SELL signals
• Clean chart-based trend visualization

How the Trend Logic Works

When multiple MAs are enabled, the indicator looks for price and MA alignment.

For bullish conditions, price must be above the selected MAs and the enabled MAs must be properly aligned from faster to slower.

For bearish conditions, price must be below the selected MAs and the enabled MAs must be aligned in the opposite direction.

The indicator can also require confirmation from:

• DMI/ADX
• Higher-Timeframe KAMA
• Higher-Timeframe VWAP

These filters are optional and can be enabled or disabled according to the trader's methodology.

ATR Trailing Stop

The indicator calculates a dynamic ATR-based trailing stop.

For long conditions, the stop can only move upward as the trend progresses.

For short conditions, the stop can only move downward.

This provides a dynamic way to manage trend-following trades while allowing the trader to adjust ATR length and multiplier according to the market and timeframe.

Suggested Use

The indicator can be used for:

• Trend identification
• Trend-following entries
• Pullback confirmation
• Multi-timeframe market analysis
• Dynamic trailing-stop management
• Alert-based trading workflows

The default configuration uses 20 EMA, 50 EMA and 200 EMA, but these settings are fully customizable.

Different combinations can be tested depending on the instrument, timeframe and trading style.

Important

This indicator is designed as a technical-analysis and decision-support tool. It does not guarantee profitable trades and should not be treated as a standalone trading system.

Always test settings on historical data and in real-time market conditions before using them with real capital.

## Source Code

````pine
//@version=6
indicator("TrendFusion Pro | Multi-MA + ADX + KAMA + VWAP Hariss 369", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 1 INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma1Type = input.string("EMA", "MA 1 Type",
     options=["EMA","SMA","WMA","VWMA","RMA","HMA"])

ma1Len = input.int(20, "MA 1 Length", minval=1)

ma1TF = input.timeframe("", "MA 1 Timeframe (Blank = Chart)")

useMA1 = input.bool(true, "Use MA 1 for Signals")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 2 INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma2Type = input.string("EMA", "MA 2 Type",
     options=["EMA","SMA","WMA","VWMA","RMA","HMA"])

ma2Len = input.int(50, "MA 2 Length", minval=1)

ma2TF = input.timeframe("", "MA 2 Timeframe (Blank = Chart)")

useMA2 = input.bool(true, "Use MA 2 for Signals")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 3 INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma3Type = input.string("EMA", "MA 3 Type",
     options=["EMA","SMA","WMA","VWMA","RMA","HMA"])

ma3Len = input.int(200, "MA 3 Length", minval=1)

ma3TF = input.timeframe("", "MA 3 Timeframe (Blank = Chart)")

useMA3 = input.bool(true, "Use MA 3 for Signals")


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DMI / ADX FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
useDMI = input.bool(false, "Use DMI/ADX Filter")

diLen     = input.int(14, "DI Length", minval=2)
adxLen    = input.int(14, "ADX Smoothing", minval=2)
adxThresh = input.float(20.0, "ADX Threshold", step=0.5)

showDMI = input.bool(false, "Show DMI/ADX")


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF KAMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

useHTFKAMA  = input.bool(false, "Use HTF KAMA Filter")
showHTFKAMA = input.bool(true,  "Show HTF KAMA")

kamaTF   = input.timeframe("15", "HTF KAMA TF")
kamaLen  = input.int(21, "KAMA Length")
kamaFast = input.int(2, "KAMA Fast")
kamaSlow = input.int(30, "KAMA Slow")

kamaColor = input.color(color.aqua, "HTF KAMA Colour")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

useHTFVWAP  = input.bool(false, "Use HTF VWAP Filter")
showHTFVWAP = input.bool(true,  "Show HTF VWAP")

vwapTF = input.timeframe("15", "HTF VWAP TF")

vwapColor = input.color(color.yellow, "HTF VWAP Colour")

kamaFunc(src, len, fast, slow)=>

    change = math.abs(src - src[len])

    volatility = 0.0
    for i = 0 to len - 1
        volatility += math.abs(src[i] - src[i + 1])

    er = volatility != 0 ? change / volatility : 0.0

    fastSC = 2.0 / (fast + 1)
    slowSC = 2.0 / (slow + 1)

    sc = math.pow(er * (fastSC - slowSC) + slowSC, 2)

    kama = 0.0
    kama := nz(kama[1], src) + sc * (src - nz(kama[1], src))

    kama

showATRSL = input.bool(true, "Show ATR SL")

atrLength = input.int(14, "ATR Length")

atrMultiplier = input.float(2.0, "ATR Multiplier", step=0.1)

atrSLColorLong = input.color(color.red, "Long SL Color")

atrSLColorShort = input.color(color.lime, "Short SL Color")
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABEL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buyColor = input.color(color.lime, "Buy Label Color")
sellColor = input.color(color.red, "Sell Label Color")

buyTextColor = input.color(color.white, "Buy Text Color")
sellTextColor = input.color(color.white, "Sell Text Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MOVING AVERAGE FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
calcMA(src, len, type)=>
    switch type
        "EMA"  => ta.ema(src, len)
        "SMA"  => ta.sma(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        "RMA"  => ta.rma(src, len)
        => ta.hma(src, len)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MULTI TIMEFRAME MA FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
getMA(tf, len, type)=>
    tf == "" ?
         calcMA(close, len, type) :
         request.security(
              syminfo.tickerid,
              tf,
              calcMA(close, len, type))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CALCULATE MAs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma1 = getMA(ma1TF, ma1Len, ma1Type)
ma2 = getMA(ma2TF, ma2Len, ma2Type)
ma3 = getMA(ma3TF, ma3Len, ma3Type)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF KAMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

htfKAMA =
     request.security(
          syminfo.tickerid,
          kamaTF,
          kamaFunc(close, kamaLen, kamaFast, kamaSlow))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

htfVWAP =
     request.security(
          syminfo.tickerid,
          vwapTF,
          ta.vwap(hlc3))

        //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLength)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DMI / ADX CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
upMove   = ta.change(high)
downMove = -ta.change(low)

plusDM  = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

tr = ta.rma(ta.tr, diLen)

plusDI  = 100 * ta.rma(plusDM, diLen) / tr
minusDI = 100 * ta.rma(minusDM, diLen) / tr

sumDI = plusDI + minusDI
adx = 100 * ta.rma(math.abs(plusDI - minusDI) / (sumDI == 0 ? 1 : sumDI), adxLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DMI FILTER CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dmiBull = plusDI > minusDI and adx > adxThresh
dmiBear = minusDI > plusDI and adx > adxThresh

kamaBull =
     not useHTFKAMA or
     close > htfKAMA

kamaBear =
     not useHTFKAMA or
     close < htfKAMA

vwapBull =
     not useHTFVWAP or
     close > htfVWAP

vwapBear =
     not useHTFVWAP or
     close < htfVWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA FILTER CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bull = false
bear = false

// MA1 only
if useMA1 and not useMA2 and not useMA3
    bull := close > ma1
    bear := close < ma1

// MA2 only
else if useMA2 and not useMA1 and not useMA3
    bull := close > ma2
    bear := close < ma2

// MA3 only
else if useMA3 and not useMA1 and not useMA2
    bull := close > ma3
    bear := close < ma3

// MA1 + MA2
else if useMA1 and useMA2 and not useMA3
    bull := close > ma1 and close > ma2 and ma1 > ma2
    bear := close < ma1 and close < ma2 and ma1 < ma2

// MA1 + MA3
else if useMA1 and useMA3 and not useMA2
    bull := close > ma1 and close > ma3 and ma1 > ma3
    bear := close < ma1 and close < ma3 and ma1 < ma3

// MA2 + MA3
else if useMA2 and useMA3 and not useMA1
    bull := close > ma2 and close > ma3 and ma2 > ma3
    bear := close < ma2 and close < ma3 and ma2 < ma3

// MA1 + MA2 + MA3
else if useMA1 and useMA2 and useMA3
    bull := close > ma1 and close > ma2 and close > ma3 and ma1 > ma2 and ma2 > ma3
    bear := close < ma1 and close < ma2 and close < ma3 and ma1 < ma2 and ma2 < ma3

// Apply DMI filter
bull :=
     bull and
     (not useDMI or dmiBull) and
     kamaBull and
     vwapBull

bear :=
     bear and
     (not useDMI or dmiBear) and
     kamaBear and
     vwapBear
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool inBuy  = false
var bool inSell = false

buySignal  = bull and not inBuy
sellSignal = bear and not inSell

if buySignal
    inBuy  := true
    inSell := false

if sellSignal
    inSell := true
    inBuy  := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR TRAILING STOP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float longSL = na
var float shortSL = na

if buySignal
    longSL := close - atr * atrMultiplier
    shortSL := na
else if inBuy
    longSL := math.max(nz(longSL), close - atr * atrMultiplier)

if sellSignal
    shortSL := close + atr * atrMultiplier
    longSL := na
else if inSell
    shortSL := math.min(nz(shortSL), close + atr * atrMultiplier)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if buySignal
    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=buyColor,
         textcolor=buyTextColor)

if sellSignal
    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=sellColor,
         textcolor=sellTextColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(ma1, title="MA 1", color=color.lime, linewidth=2)
plot(ma2, title="MA 2", color=color.orange, linewidth=2)
plot(ma3, title="MA 3", color=color.red, linewidth=2)

plot(
     showHTFKAMA ? htfKAMA : na,
     title="HTF KAMA",
     color=kamaColor,
     linewidth=2)

plot(
     showHTFVWAP ? htfVWAP : na,
     title="HTF VWAP",
     color=vwapColor,
     linewidth=2)
     
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, title="BUY", message="BUY Signal")
alertcondition(sellSignal, title="SELL", message="SELL Signal")

plot(showATRSL ? longSL : na,
     "Long ATR Trail",
     color=atrSLColorLong,
     linewidth=2,
     style=plot.style_linebr)

plot(showATRSL ? shortSL : na,
     "Short ATR Trail",
     color=atrSLColorShort,
     linewidth=2,
     style=plot.style_linebr)
````
