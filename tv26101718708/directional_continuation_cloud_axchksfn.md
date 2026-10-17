# Directional Continuation Cloud

- url: https://www.tradingview.com/script/AxchksFN-Directional-Continuation-Cloud/
- type: indicator
- pine_id: PUB;3bc4c8af96c443afb6e0a60510942023
- version: 1.0

## Description

Directional Continuation Engine v1 is a trend-following pullback script designed to identify continuation entries after controlled retracements. It combines trend structure, trend quality, pullback health, and momentum triggers to help avoid chasing extended moves or trading low-quality chop. It is built for continuation setups, not top or bottom picking.

## Source Code

````pine
//@version=6
indicator("Directional Continuation Cloud", overlay=true)

fastTrendEmaLen = input.int(20, "Fast Trend EMA", minval=2)
midTrendEmaLen  = input.int(50, "Mid Trend EMA", minval=3)
slowTrendEmaLen = input.int(100, "Slow Trend EMA", minval=5)
slopeLookback   = input.int(5, "EMA Slope Lookback", minval=1)

fastTrendEma = ta.ema(close, fastTrendEmaLen)
midTrendEma  = ta.ema(close, midTrendEmaLen)
slowTrendEma = ta.ema(close, slowTrendEmaLen)

fastSlope = fastTrendEma - fastTrendEma[slopeLookback]
midSlope  = midTrendEma - midTrendEma[slopeLookback]

bullStructure = (
    fastTrendEma > midTrendEma and
    midTrendEma > slowTrendEma and
    fastSlope > 0 and
    midSlope > 0
)

bearStructure = (
    fastTrendEma < midTrendEma and
    midTrendEma < slowTrendEma and
    fastSlope < 0 and
    midSlope < 0
)

bullCloudColor = color.new(color.lime, 88)
bearCloudColor = color.new(color.red, 88)
neutralCloudColor = color.new(color.gray, 92)

pFast = plot(fastTrendEma, "Fast EMA", color=color.new(color.teal, 0), linewidth=1)
pMid  = plot(midTrendEma, "Mid EMA", color=color.new(color.orange, 0), linewidth=1)
plot(slowTrendEma, "Slow EMA", color=color.new(color.gray, 40), linewidth=1)

fillColor = neutralCloudColor
if bullStructure
    fillColor := bullCloudColor
else if bearStructure
    fillColor := bearCloudColor

fill(pFast, pMid, color=fillColor)
````
