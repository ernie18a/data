# Engulfing After Climax Low Volume + Wick Filter Zohaib

- url: https://www.tradingview.com/script/aJThGZ2r-Engulfing-After-Climax-Low-Volume-Wick-Filter-Zohaib/
- type: indicator
- pine_id: PUB;b191019a85f94cc1bd1a6e94ffbe91f2
- version: 1.0

## Description

Low Volume Englfinc candle. The single of buy and sell will appear afte my setup

## Source Code

````pine
//@version=5
indicator("Engulfing After Climax Low Volume + Wick Filter", overlay=true)

bodyMultiplier = input.float(1.0, "Engulf Body Strength", step=0.1)
minBodyPercent = input.float(0.35, "Minimum Body % of Range", step=0.05)

avgVolLength = input.int(20, "Average Volume Length")
lowVolPercent = input.float(1.0, "Engulf Low Volume Below Avg", step=0.05)

climaxLookback = input.int(10, "Climax Lookback Candles")
climaxVolMultiplier = input.float(1.5, "Climax Volume Multiplier", step=0.1)
wideSpreadMultiplier = input.float(1.2, "Wide Spread Multiplier", step=0.1)

bodySize = math.abs(close - open)
prevBodySize = math.abs(close[1] - open[1])
candleRange = high - low

bodyPercent = candleRange != 0 ? bodySize / candleRange : 0
validBody = bodyPercent >= minBodyPercent

avgVol = ta.sma(volume, avgVolLength)
avgRange = ta.sma(high - low, avgVolLength)

lowVol = volume < avgVol * lowVolPercent
strongBody = bodySize >= prevBodySize * bodyMultiplier

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

buyWickOk = upperWick <= lowerWick
sellWickOk = lowerWick <= upperWick

sellingClimaxBar =
     close < open and
     volume > avgVol * climaxVolMultiplier and
     candleRange > avgRange * wideSpreadMultiplier

buyingClimaxBar =
     close > open and
     volume > avgVol * climaxVolMultiplier and
     candleRange > avgRange * wideSpreadMultiplier

sellingClimaxRecent = ta.barssince(sellingClimaxBar) <= climaxLookback
buyingClimaxRecent  = ta.barssince(buyingClimaxBar) <= climaxLookback

bullishEngulf =
     sellingClimaxRecent and
     close > open and
     close[1] < open[1] and
     close > open[1] and
     open <= close[1] and
     strongBody and
     lowVol and
     validBody and
     buyWickOk

bearishEngulf =
     buyingClimaxRecent and
     close < open and
     close[1] > open[1] and
     open >= close[1] and
     close < open[1] and
     strongBody and
     lowVol and
     validBody and
     sellWickOk

plotshape(bullishEngulf, title="Buy After Selling Climax", location=location.belowbar,
     color=color.green, style=shape.labelup, text="B")

plotshape(bearishEngulf, title="Sell After Buying Climax", location=location.abovebar,
     color=color.red, style=shape.labeldown, text="S")

plotshape(sellingClimaxBar, title="Selling Climax", location=location.belowbar,
     color=color.orange, style=shape.circle, size=size.tiny)

plotshape(buyingClimaxBar, title="Buying Climax", location=location.abovebar,
     color=color.purple, style=shape.circle, size=size.tiny)

alertcondition(bullishEngulf, title="Buy Alert", message="Bullish Engulfing Low Volume After Selling Climax")
alertcondition(bearishEngulf, title="Sell Alert", message="Bearish Engulfing Low Volume After Buying Climax")
````
