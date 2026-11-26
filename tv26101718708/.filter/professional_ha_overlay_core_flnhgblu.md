# Professional HA Overlay Core

- url: https://www.tradingview.com/script/FLNHGblU-Professional-HA-Overlay-Core/
- type: indicator
- pine_id: PUB;a676124c754d40beb91ddf50d68fb87a
- version: 1.0

## Description

Hi, this script is a heiken ashi overlay.  That can be used on higher time frames.  It is for educational purposes only.  I will make changes as needed.  I like to use it in conjunction with EMA'S.

## Source Code

````pine
//@version=6
indicator("Professional HA Overlay Core", overlay=true, max_labels_count=500)

//==================================================
// INPUTS
//==================================================
autoLift = input.bool(true, "Auto Lift")
fastTF = input.timeframe("15", "Fast HA Timeframe")
majorTF = input.timeframe("60", "Major Ribbon Timeframe")

fastSmooth = input.int(5, "Fast HA Smoothing", minval=1)
majorSmooth = input.int(8, "Major Ribbon Smoothing", minval=1)

haLiftATR = input.float(3.5, "HA Lift ATR", step=0.25)
ribbonLiftATR = input.float(5.0, "Ribbon Lift ATR", step=0.25)

showHACandles = input.bool(true, "Show HA Candles")
showRibbon = input.bool(true, "Show Ribbon")
showSignals = input.bool(true, "Show Signals")

//==================================================
// HEIKIN ASHI SOURCE
//==================================================

haTicker = ticker.heikinashi(syminfo.tickerid)

//==================================================
// FAST HA
//==================================================

fastOpenRaw  = request.security(haTicker, fastTF, open)
fastHighRaw  = request.security(haTicker, fastTF, high)
fastLowRaw   = request.security(haTicker, fastTF, low)
fastCloseRaw = request.security(haTicker, fastTF, close)

fastOpen  = ta.ema(fastOpenRaw, fastSmooth)
fastHigh  = ta.ema(fastHighRaw, fastSmooth)
fastLow   = ta.ema(fastLowRaw, fastSmooth)
fastClose = ta.ema(fastCloseRaw, fastSmooth)

//==================================================
// MAJOR TREND
//==================================================

majorOpenRaw  = request.security(haTicker, majorTF, open)
majorCloseRaw = request.security(haTicker, majorTF, close)

majorOpen  = ta.ema(majorOpenRaw, majorSmooth)
majorClose = ta.ema(majorCloseRaw, majorSmooth)

//==================================================
// TREND
//==================================================

fastBull = fastClose > fastOpen
majorBull = majorClose > majorOpen

bullAligned = fastBull and majorBull
bearAligned = not fastBull and not majorBull



//==================================================
// OFFSETS
//==================================================

atrValue = ta.atr(14)

haOffset = math.max(atrValue * haLiftATR, close * 0.01)
ribbonOffset = math.max(atrValue * ribbonLiftATR, close * 0.015)

if autoLift
    haOffset := timeframe.isminutes ?
         math.max(atrValue * haLiftATR, close * 0.01) :
         timeframe.isdaily ?
         atrValue * 2.0 :
         atrValue * 0.75

    ribbonOffset := timeframe.isminutes ?
         math.max(atrValue * ribbonLiftATR, close * 0.015) :
         timeframe.isdaily ?
         atrValue * 3.0 :
         atrValue * 1.5
//==================================================
// LIFTED HA CANDLES
//==================================================

haO = fastOpen + haOffset
haH = fastHigh + haOffset
haL = fastLow + haOffset
haC = fastClose + haOffset

fastBullColor = color.new(color.lime, 55)
fastBearColor = color.new(color.red, 55)

plotcandle(
     showHACandles ? haO : na,
     showHACandles ? haH : na,
     showHACandles ? haL : na,
     showHACandles ? haC : na,
     color = fastBull ? fastBullColor : fastBearColor,
     wickcolor = color.gray,
     bordercolor = color.gray)

//==================================================
// RIBBON
//==================================================

ribbonCenter = majorClose + ribbonOffset 

upperRibbon = ribbonCenter + atrValue * 0.20
lowerRibbon = ribbonCenter - atrValue * 0.20

ribbonColor = majorBull ? color.green : color.red

p1 = plot(
     showRibbon ? upperRibbon : na,
     color=color.new(ribbonColor, 60),
     linewidth=2)

p2 = plot(
     showRibbon ? lowerRibbon : na,
     color=color.new(ribbonColor, 60),
     linewidth=2)

fill(
     p1,
     p2,
     color=color.new(ribbonColor, 85))

//==================================================
// EMA
//==================================================

ema9 = ta.ema(close, 9)

plot(
     ema9,
     title="9 EMA",
     color=color.yellow,
     linewidth=2)

ema18 = ta.ema(close, 18)

//==================================================
// STOCHASTIC
//==================================================

rawK = ta.stoch(close, high, low, 10)

k = ta.sma(rawK, 3)
d = ta.sma(k, 3)

//==================================================
// EARLY SIGNALS
//==================================================

earlyBull =
     ta.crossover(k, d) and
     k < 30 and
     bullAligned

earlyBear =
     ta.crossunder(k, d) and
     k > 70 and
     bearAligned

emaBullCross = ta.crossover(ema9, ema18)
emaBearCross = ta.crossunder(ema9, ema18)
//==================================================
// STRONG SIGNALS
//==================================================

strongBull =
     earlyBull and
     close > ema9

strongBear =
     earlyBear and
     close < ema9

//==================================================
// EMA CROSSOVER ARROWS
//==================================================

plotshape(
    emaBullCross,
    style=shape.labelup,
    location=location.bottom,
    color=color.lime,
    text="EMA",
    size=size.large)

plotshape(
    emaBearCross,
    style=shape.labeldown,
    location=location.top,
    color=color.red,
    text="EMA",
    size=size.large)

//==================================================
// SMALL ARROWS
//==================================================

plotshape(
     showSignals and earlyBull,
     style=shape.triangleup,
     location=location.belowbar,
     color=color.aqua,
     size=size.normal)

plotshape(
     showSignals and earlyBear,
     style=shape.triangledown,
     location=location.abovebar,
     color=color.orange,
     size=size.normal)

// ▲ ▼ = Early Warning

// LONG = Trade Candidate

// SHORT = Trade Candidate

//==================================================
// LARGE LABELS
//==================================================

plotshape(
     showSignals and strongBull,
     title="LONG",
     text="LONG",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.small)

plotshape(
     showSignals and strongBear,
     title="SHORT",
     text="SHORT",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.small)

//==================================================
// ALERT CONDITIONS
//==================================================

alertcondition(
     earlyBear,
     title = "Early SHORT Signal",
     message = "Early SHORT Signal: Stochastic + HA Alignment")

combinedSignal = strongBull or strongBear

alertcondition(
     combinedSignal,
     title = "Trade Signal",
     message = "New LONG or SHORT setup detected")
````
