<!-- tradingview-pine-id: PUB;c03fb6c0deda4d988473affe434f68f8 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Displacement Acceptance Meter v3

Source: https://www.tradingview.com/script/PGXm7Yiy-Volume-Displacement-Acceptance-Meter-v3/

## Description

volume displacement this indicator shows if theres real volume behind the candles sticks movement perfect for orb and breakout traders

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © notfrm63rd
//@version=6
indicator("Volume Displacement Acceptance Meter v3", shorttitle="VDAM v3", overlay=false)


//========================
// INPUTS
//========================

volLength = input.int(20, "Volume Average Length")
atrLength = input.int(14, "ATR Length")
smooth = input.int(3, "Smoothing")

threshold = input.float(0.15, "Acceptance Threshold", step=0.05)

extDispThresh = input.float(2.5, "Exhaustion Displacement")
extRvolThresh = input.float(2.0, "Exhaustion RVOL")
extReduction = input.float(0.5, "Exhaustion Reduction")

useTrendFilter = input.bool(true, "Use Trend Filter")
trendEMALen = input.int(50, "Trend EMA Length")
adxLen = input.int(14, "ADX Length")


//========================
// NORMALIZATION
//========================

normalize(x) =>
    x / (1 + math.abs(x))


//========================
// VOLUME
//========================

avgVol = ta.sma(volume, volLength)

relativeVolume = avgVol > 0 ? volume / avgVol : 0


//========================
// CANDLE STRUCTURE
//========================

candleRange = high - low
body = math.abs(close - open)

bodyStrength = candleRange > 0 ? body / candleRange : 0

bullCandle = close > open
bearCandle = close < open


direction = bullCandle ? 1 : bearCandle ? -1 : 0


//========================
// DISPLACEMENT
//========================

atr = ta.atr(atrLength)

displacement = atr > 0 ? candleRange / atr : 0


//========================
// MOMENTUM
//========================

rsi = ta.rsi(close,14)

momentum = rsi > 55 ? 1 : rsi < 45 ? -1 : 0


//========================
// ACCEPTANCE SCORE
//========================

rawScore = relativeVolume * displacement * bodyStrength

momentumWeight = momentum == direction ? 1.25 : 0.75

score = rawScore * direction * momentumWeight

meter = ta.ema(normalize(score), smooth)


//========================
// EXHAUSTION
//========================

extremeMove = displacement > extDispThresh and relativeVolume > extRvolThresh

meterFiltered = extremeMove ? meter * extReduction : meter


//========================
// TREND FILTER
//========================

emaTrend = ta.ema(close, trendEMALen)

emaSlope = emaTrend - emaTrend[1]

[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

trending = adx > 20

trendDirection = emaSlope > 0 ? 1 : emaSlope < 0 ? -1 : 0


finalMeter = useTrendFilter and trending ? meterFiltered * trendDirection : meterFiltered


//========================
// DISPLAY
//========================

barColor = finalMeter > threshold ? color.green : finalMeter < -threshold ? color.red : color.gray


plot(
     finalMeter,
     title="VDAM Acceptance",
     style=plot.style_columns,
     color=barColor,
     linewidth=3
)


hline(threshold, "Bull Threshold")
hline(-threshold, "Bear Threshold")


//========================
// ALERTS
//========================

bullSignal = ta.crossover(finalMeter, threshold)
bearSignal = ta.crossunder(finalMeter, -threshold)

alertcondition(
     bullSignal,
     title="Bull Acceptance",
     message="VDAM Bullish Acceptance"
)

alertcondition(
     bearSignal,
     title="Bear Acceptance",
     message="VDAM Bearish Acceptance"
)
````
