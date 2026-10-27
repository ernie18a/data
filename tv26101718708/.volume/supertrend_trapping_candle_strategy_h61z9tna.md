# SuperTrend Trapping Candle Strategy

- url: https://www.tradingview.com/script/H61Z9TNa-SuperTrend-Trapping-Candle-Strategy/
- type: strategy
- pine_id: PUB;132032fe567a49649aa9f612b0f035f3
- version: 1.0

## Description

Hello traders!

[b]How this indicator works?[/b]
The main functionality of this indicator is to find entry based upon SuperTrend indicator. This indicator helps us to find trapping candle to enter into the market.

[b]What is a trapping candle?[/b]
A trapping candle is a candle that shows strength in opposite direction to SuperTrend. This helps us to enter in a trade before the move start in the current trend's direction. There are two types of trapping candles signals I have added currently:
1. Volume is high than previous candle in the opposite direction.
2. 3 candles of opposite direction with decreasing volume .

[b]How to enter in a trade in uptrend market?[/b]
SuperTrend shows a green signal
A green triangle formed below red candle
Enter into the trade when price is above red candle high
SL could be place below red candle or swing low if it is near

[b]How to enter in a trade in downtrend market?[/b]
SuperTrend shows a red signal
A red triangle formed above green candle
Enter into the trade when price is below green candle low
SL could be place above green candle high or swing high if it is near

[b]How to avoid to enter in a trade in sideways market?[/b]
You can follow price action strategies
Or you can follow some indicator to find sideways market

[b]Indicator settings and how to change?[/b]
ATR Length - For SuperTrend, this is default value.
Factor - For SuperTrend, changed to 2 to provide fast signals.
Candle Height - For trapping candle price, default set to 0.003% of the current price.

## Source Code

````pine
//@version=5
strategy("SuperTrend Trapping Candle Strategy", shorttitle="ST", margin_long=1, margin_short=1, overlay=true)


// Inputs
atrPeriod = input.int(10, "ATR Length")
factor = input.int(2, "Factor")
candleDivider = input.float(0.003, "Candle Height", step=0.0001)


// Supertrend
[supertrend, direction] = ta.supertrend(factor, atrPeriod)
plot(direction < 0 ? supertrend : na, "Up Trend", color = color.green, style=plot.style_linebr)
plot(direction < 0? na : supertrend, "Down Trend", color = color.red, style=plot.style_linebr)


//Trapping canlde
isUptrend = direction < 0
isDowntrend = direction > 0
isBullsStrengthDecreasing = volume < volume[1] and volume[1] < volume[2] and close > close[1] and close[1] > close[2] and open > open[1] and open[1] > open[2]
isBearsStrengthDecreasing = volume < volume[1] and volume[1] < volume[2] and close < close[1] and close[1] < close[2] and open < open[1] and open[1] < open[2]
isStrongVolume = (volume > volume[1]) or isBullsStrengthDecreasing or isBearsStrengthDecreasing
isSmallCandle = (high - low) < close * candleDivider
isUptrendTrapping = isUptrend and close < open and isStrongVolume and isSmallCandle
isDowntrendTrapping = isDowntrend and close > open and isStrongVolume and isSmallCandle

plotshape(isUptrendTrapping, style=shape.triangleup, location=location.belowbar, color=color.green)
plotshape(isDowntrendTrapping, style=shape.triangledown, location=location.abovebar, color=color.orange)


// Signals
longCondition = isUptrendTrapping
if (longCondition)
    strategy.entry("Long", strategy.long)


shortCondition = isDowntrendTrapping
if (shortCondition)
    strategy.entry("Short", strategy.short)

if open < close
    alert("Seller Trapped.", alert.freq_all)
if close > open
    alert("Buyer Trapped.", alert.freq_all)
````
