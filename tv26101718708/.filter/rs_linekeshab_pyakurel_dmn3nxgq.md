# RS Line_Keshab Pyakurel

- url: https://www.tradingview.com/script/dmN3nXgq-RS-Line-Keshab-Pyakurel/
- type: indicator
- pine_id: PUB;d6e89a67594f4bfd84298355b0f71b10
- version: 2.0

## Description

Unlike the Relative Strength Index (RSI), which is a momentum oscillator bound between 0 and 100, the RS Line measures real outperformance by dividing the price of the base asset by a benchmark index (defaulted to the S&P 500: SPX or SPY). It highlights whether a stock is truly leading the market or just floating along with the tide.

## Source Code

````pine
//@version=6
indicator('RS Line with High/Low Dots', shorttitle = 'RS Line Dots', overlay = false)

// --- Inputs ---
comparisonSymbol = input.symbol('AMEX:SPY', title = 'Comparison Symbol (Benchmark)')
maLength = input.int(21, title = 'RS Moving Average Length', minval = 1)
lookback = input.int(252, title = 'Lookback Period (252 Daily / 52 Weekly)', minval = 1)
colorUp = input.color(color.green, title = 'RS Line Up Color')
colorDown = input.color(color.red, title = 'RS Line Down Color')

// --- Data Fetching ---
benchmarkClose = request.security(comparisonSymbol, timeframe.period, close)

// --- Calculations ---
rsRatio = close / benchmarkClose
rsMA = ta.sma(rsRatio, maLength)

// 52-Week High / Low Calculations
// [1] looks at previous bars so the current bar can actually equal or beat it
rsHigh52 = ta.highest(rsRatio[1], lookback)
rsLow52 = ta.lowest(rsRatio[1], lookback)

is52High = rsRatio >= rsHigh52
is52Low = rsRatio <= rsLow52

// Define colors outside of the plot functions
lineColor = rsRatio > rsMA ? colorUp : colorDown
bgColor = rsRatio > rsMA ? color.new(colorUp, 95) : color.new(colorDown, 95)

// --- Plotting ---
plot(rsRatio, title = 'RS Line', color = lineColor, linewidth = 2)
plot(rsMA, title = 'RS MA', color = color.gray, linewidth = 1, style = plot.style_line)
bgcolor(bgColor)

// Plot Green Dot at Highs and Red Dot at Lows directly on the RS Line
plotshape(is52High ? rsRatio : na, title = '52-Week High Dot', style = shape.circle, location = location.absolute, color = color.green, size = size.small)
plotshape(is52Low ? rsRatio : na, title = '52-Week Low Dot', style = shape.circle, location = location.absolute, color = color.red, size = size.small)
````
