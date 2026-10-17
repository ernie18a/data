# WaveTrend Signal V2

- url: https://www.tradingview.com/script/DBwRiDpK-WaveTrend-Signal-V2/
- type: indicator
- pine_id: PUB;2b2d7116d31b49418b8422cda67a4c2e
- version: 3.0

## Description

This is a very basic Wave Trend Oscillator. It is based on the excellent VuManChu Cipher B indicator. It uses two wave trend lines. 

WT crosses are significant events. Zero-line crosses are highlighted with either Green or Red triangles and signify trend direction changes. 

WT crosses either above 60 or below -60 signify the current trend may be losing momentum. 

I recommend changing the source to something smoother, such as a moving average or your favorite smoothing indicator happens to be. This will filter out a lot of false signals and make the WT crosses more meaningful! Happy trading!!

## Source Code

````pine
//@version=6
indicator("WaveTrend Signal V2.1", overlay = false)

wtChannelLen = input.int(9,  "WT Channel Length")
wtAverageLen = input.int(27, "WT Average Length")
wtMALen      = input.int(3,  "WT MA Length")
wtSource     = input.source(hlc3, "WT Source")
minSwing     = input.float(10.0, "Min Swing Before Cross", minval = 1.0)

esa = ta.ema(wtSource, wtChannelLen)
de  = ta.ema(math.abs(wtSource - esa), wtChannelLen)
ci  = (wtSource - esa) / (0.015 * de)

wt1 = ta.ema(ci, wtAverageLen)
wt2 = ta.sma(wt1, wtMALen)

// Track the lowest WT1 went before a long cross
// and highest WT1 went before a short cross
var float lowestSince  = 0.0
var float highestSince = 0.0

if wt1 < 0
    lowestSince := math.min(lowestSince, wt1)
else
    lowestSince := 0.0

if wt1 > 0
    highestSince := math.max(highestSince, wt1)
else
    highestSince := 0.0

// Raw cross
rawLong  = wt1[1] < 0 and wt1 >= 0
rawShort = wt1[1] > 0 and wt1 <= 0

// Filtered cross — only valid if WT1 swung far enough before crossing
filteredLong  = rawLong  and lowestSince[1]  <= -minSwing
filteredShort = rawShort and highestSince[1] >=  minSwing

// TP circles
wtCrossUp   = wt1[1] - wt2[1] < 0 and wt1 - wt2 >= 0
wtCrossDown = wt1[1] - wt2[1] > 0 and wt1 - wt2 <= 0
buyCircle   = wtCrossUp   and wt1 < -60 and wt2 < -60
sellCircle  = wtCrossDown and wt1 > 60  and wt2 > 60

plot(wt1, "WT1", color.blue)
plot(wt2, "WT2", color.red)
hline(0)
hline(60)
hline(-60)

// Raw signals (dim)
plotshape(rawLong,  "Raw Long",  shape.triangleup,   location.bottom, color.new(color.green, 70), size = size.tiny)
plotshape(rawShort, "Raw Short", shape.triangledown, location.top,    color.new(color.red, 70),   size = size.tiny)

// Filtered signals (bright)
plotshape(filteredLong,  "Filtered Long",  shape.triangleup,   location.bottom, color.green, size = size.small)
plotshape(filteredShort, "Filtered Short", shape.triangledown, location.top,    color.red,   size = size.small)

plotshape(buyCircle,  "Buy Circle",  shape.circle, location.bottom, color.aqua,   size = size.tiny)
plotshape(sellCircle, "Sell Circle", shape.circle, location.top,    color.yellow, size = size.tiny)
````
