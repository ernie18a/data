# EMA with 4% Bands

- url: https://www.tradingview.com/script/9jVNRddT-EMA-with-4-Bands/
- type: indicator
- pine_id: PUB;f411e75ed93344b4b9b0322254baf661
- version: 1.0

## Description

asdasd the bets 4% ema bnands above 300 ema etc. Make sure you use the 300 ema with the 21/12 emas to get the proper trend direction. Make sure you have prioper risk management.

## Source Code

````pine
//@version=6
indicator("EMA with 4% Bands", overlay=true)
length = input.int(20, "EMA Length")
percent = 4.0

emaValue = ta.ema(close, length)
upperBand = emaValue * (1 + percent / 100)
lowerBand = emaValue * (1 - percent / 100)

plot(emaValue, color=color.blue, title="EMA")
plot(upperBand, color=color.green, title="Upper Band")
plot(lowerBand, color=color.red, title="Lower Band")
fill(plot(upperBand), plot(lowerBand), color=color.new(color.blue, 90))
````
