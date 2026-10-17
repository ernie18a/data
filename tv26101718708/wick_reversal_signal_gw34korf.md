# Wick Reversal Signal

- url: https://www.tradingview.com/script/Gw34kOrf-Wick-Reversal-Signal/
- type: strategy
- pine_id: PUB;RQzvdsaMBLHwbJAZQTYrqD3RLEDYYd9r
- version: 1.0

## Description

The PivotBoss wick reversal strategy

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © adiwajshing

//@version=4
strategy("Wick Reversal Signal", overlay=true)

wickMultiplier = input(3.25)
bodyPercentage = input(0.35)
barsBack = input(50)
bodyMultiplier = input(1.1)

myCandleSize = high-low
averageCandleSize = rma(myCandleSize, barsBack)

longSignal = close > open and open-low >= (close-open)*wickMultiplier and high-close <= (high-low)*bodyPercentage and high-low >= averageCandleSize*bodyMultiplier
longSignal := longSignal or (close < open and close-low >= (open-close)*wickMultiplier and high-close <= (high-low)*bodyPercentage and high-low >= averageCandleSize*bodyMultiplier)
longSignal := longSignal or (abs(close-open) < 0.01 and close != high and high-low >= (high-close)*wickMultiplier and high-close <= (high-low)*bodyPercentage and high-low >= averageCandleSize*bodyMultiplier)

shortSignal = close < open and high-open >= (open-close)*wickMultiplier and close-low <= (high-low)*bodyPercentage and high-low >= averageCandleSize*bodyMultiplier
shortSignal := shortSignal or (close > open and high-close >= (close-open)*wickMultiplier and close-low <= (high-low)*bodyPercentage and high-low >= averageCandleSize*bodyMultiplier)
shortSignal := shortSignal or (abs(close-open) < 0.01 and close != low and high-low >= (close-low)*wickMultiplier and close-low <= (high-low)*bodyPercentage and high-low >= averageCandleSize*bodyMultiplier)

plotshape(longSignal, style=shape.triangleup, size=size.normal)
plotshape(shortSignal, style=shape.triangledown, size=size.normal)

strategy.entry("LONG", strategy.long, when=longSignal)
strategy.entry("SHORT", strategy.short, when=shortSignal)
````
