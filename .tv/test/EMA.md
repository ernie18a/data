<!-- tradingview-pine-id: PUB;24c9945dcb6a40238f40839b408c26ad -->
<!-- tradingviewscripts-format: 1 -->
# EMA

Source: https://www.tradingview.com/script/BN77NUdf-EMA-9-20-50-100-200/

## Description

A clean multi-timeframe EMA indicator that plots five exponential moving averages on your chart: 9, 20, 50, 100, and 200 periods.

These are among the most widely followed EMAs in technical analysis. The shorter EMAs (9, 20) track near-term momentum, the 50 marks the intermediate trend, and the 100 and 200 act as major long-term trend and support/resistance levels. When the fast EMAs cross above the slow ones, it signals bullish momentum; crosses below signal bearish momentum. Alignment of all five in order often confirms a strong trend.

Each EMA is color-coded and weighted for easy reading, so you can quickly gauge trend direction and spot potential crossovers, pullbacks, and dynamic support/resistance zones across any timeframe or asset.

Feel free to adjust the periods and colors to fit your own strategy.

---

## Source Code

````pine
//@version=6
indicator('EMA', overlay = true)

// EMAs
ema9 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

plot(ema9, color = color.new(color.orange, 0), title = '9')
plot(ema20, color = color.new(color.yellow, 0), title = '20')
plot(ema50, color = color.new(color.blue, 0), title = '50')
plot(ema100, color = color.new(color.green, 0), title = '100')
plot(ema200, color = color.new(color.red, 0), title = '200')

// Crossovers
bullishCross = ta.crossover(ema9, ema20)
bearishCross = ta.crossunder(ema9, ema20)

plotshape(bullishCross, title = 'Bullish Crossover', location = location.belowbar, color = color.new(color.green, 0), style = shape.triangleup, size = size.small)
plotshape(bearishCross, title = 'Bearish Crossover', location = location.abovebar, color = color.new(color.red, 0), style = shape.triangledown, size = size.small)
````
