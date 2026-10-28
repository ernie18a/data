# NemaGA

- url: https://www.tradingview.com/script/K6zXUUud-NemaGA/
- type: indicator
- pine_id: PUB;0064a68562d949eca054b9e9f6f4dae4
- version: 1.0

## Description

it an experimental indicator based on gausian moving average

## Source Code

````pine
//@version=6
indicator("skn-alma filtered v2", shorttitle="NEMAGMA", overlay=true)

// Inputs
src = input.source(close, "Source", group="ALMA Smoothing")
smooth = input.int(1, "Smoothing", minval=1, group="ALMA Smoothing")
length1 = input.int(25, "ALMA Lookback", minval=1, group="ALMA Smoothing")

gLength = input.int(14, minval=1, title="Gaussian Length", group="Gaussian Adaptive Moving Average")
adaptive = input.bool(true, title="Adaptive Parameters", group="Gaussian Adaptive Moving Average")
volatilityPeriod = input.int(20, minval=1, title="Volatility Period", group="Gaussian Adaptive Moving Average")
fixedSigma = input.float(1.0, minval=0.1, title="Fixed Sigma", group="Gaussian Adaptive Moving Average")

emaLen = input.int(7, "EMA Length", minval=1, group="Filters")
useRsiChande = input.bool(true, "Use RSI + Chande Filter", group="Filters")
useEmaFilter = input.bool(true, "Use EMA Price/Slope Filter", group="Filters")
cooldownBars = input.int(1, "Cooldown Bars After Signal", minval=0, group="Filters")

useMtf = input.bool(false, "Use Higher Timeframe EMA Confirmation", group="Higher Timeframe")
htf = input.timeframe("15", "Higher Timeframe", group="Higher Timeframe")

// ALMA Smoothed Percentage Change
almaOffset = 0.85
almaSigma = 7

pchange = ta.change(src, smooth) / src * 100
avpchange = ta.alma(pchange, length1, almaOffset, almaSigma)

// RSI
rsi = ta.rsi(close, 14)
rsiL = rsi > rsi[1]
rsiS = rsi < rsi[1]

// Chande Momentum
length11 = 9
momm = ta.change(close)

f1(m) => m >= 0.0 ? m : 0.0
f2(m) => m >= 0.0 ? 0.0 : -m

m1 = f1(momm)
m2 = f2(momm)
sm1 = math.sum(m1, length11)
sm2 = math.sum(m2, length11)

percent(nom, div) =>
    div != 0 ? 100 * nom / div : 0

chandeMO = percent(sm1 - sm2, sm1 + sm2)
cL = chandeMO > chandeMO[1]
cS = chandeMO < chandeMO[1]

// Gaussian Adaptive Moving Average
float gmaRaw = 0.0
float sumOfWeights = 0.0

sigma = adaptive ? ta.stdev(close, volatilityPeriod) : fixedSigma
sigma := math.max(nz(sigma, fixedSigma), 0.000001)

for i = 0 to gLength - 1
    weight = math.exp(-math.pow(((i - (gLength - 1)) / (2 * sigma)), 2) / 2)

    float highestValue = avpchange
    float lowestValue = avpchange

    if i > 0
        for j = 1 to i
            historicalValue = avpchange[j]
            if not na(historicalValue)
                highestValue := math.max(highestValue, historicalValue)
                lowestValue := math.min(lowestValue, historicalValue)

    value = highestValue + lowestValue
    gmaRaw += value * weight
    sumOfWeights += weight

gmaRaw := sumOfWeights != 0 ? (gmaRaw / sumOfWeights) / 2 : na
gma = ta.ema(gmaRaw, 7)

// Base ASGMA direction
baseBull = avpchange >= gma
baseBear = avpchange < gma

// EMA filter
emaLine = ta.ema(close, emaLen)
emaRising = emaLine > emaLine[1]
emaFalling = emaLine < emaLine[1]

emaBuyOk = close > emaLine and emaRising
emaSellOk = close < emaLine and emaFalling

// Higher timeframe EMA confirmation
htfClose = request.security(syminfo.tickerid, htf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfEma = request.security(syminfo.tickerid, htf, ta.ema(close, emaLen), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfClose > htfEma and htfEma > htfEma[1]
htfBear = htfClose < htfEma and htfEma < htfEma[1]

// Filters
rsiChandeBuyOk = rsiL and cL
rsiChandeSellOk = rsiS and cS

buyOk = baseBull
buyOk := buyOk and (not useRsiChande or rsiChandeBuyOk)
buyOk := buyOk and (not useEmaFilter or emaBuyOk)
buyOk := buyOk and (not useMtf or htfBull)

sellOk = baseBear
sellOk := sellOk and (not useRsiChande or rsiChandeSellOk)
sellOk := sellOk and (not useEmaFilter or emaSellOk)
sellOk := sellOk and (not useMtf or htfBear)

// Cooldown + alternating signal state
var int lastSignalBar = na
var int signalState = 0   // 0 = no position, 1 = last signal was Buy, -1 = last signal was Sell

cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars

buySetup = buyOk and not buyOk[1]
sellSetup = sellOk and not sellOk[1]

buySignal = buySetup and signalState != 1 and cooldownOk and barstate.isconfirmed
sellSignal = sellSetup and signalState != -1 and cooldownOk and barstate.isconfirmed

if buySignal
    signalState := 1
    lastSignalBar := bar_index

if sellSignal
    signalState := -1
    lastSignalBar := bar_index

// Plot
gmaColor = baseBull ? color.rgb(0, 161, 5) : color.rgb(215, 0, 0)

// Candle colors are left unchanged to avoid visual confusion.
plot(emaLine, color=gmaColor, linewidth=3, title="EMA Colored By ASGMA")

plotshape(buySignal, title="Filtered Buy", text="B", textcolor=color.white, style=shape.labelup, location=location.belowbar, color=color.rgb(0, 161, 5))
plotshape(sellSignal, title="Filtered Sell", text="S", textcolor=color.white, style=shape.labeldown, location=location.abovebar, color=color.rgb(215, 0, 0))

bgcolor(buySignal ? color.rgb(0, 162, 5, 85) : na)
bgcolor(sellSignal ? color.rgb(207, 0, 0, 85) : na)

alertcondition(buySignal, title="Filtered Buy Signal", message="Filtered Long! {{exchange}}:{{ticker}}")
alertcondition(sellSignal, title="Filtered Sell Signal", message="Filtered Short! {{exchange}}:{{ticker}}")
````
