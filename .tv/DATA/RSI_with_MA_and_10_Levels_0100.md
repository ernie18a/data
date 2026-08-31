<!-- tradingview-pine-id: PUB;161c93a737074390a931be2cd3847c7a -->
<!-- tradingviewscripts-format: 1 -->
# RSI with MA and 10 Levels (0-100)

Source: https://www.tradingview.com/script/PV25E84B-RSI-with-MA-and-10-Levels-0-100/

## Description

buy and sell checking indicator where different levels of rsi 0 to 100 will be tested trade will be taken in accordance with other confirmation indicator based on your trading style

---

## Source Code

````pine
//@version=6
indicator('RSI with MA and 10 Levels (0-100)', shorttitle = 'RSI_10_Levels', overlay = false)

// --- Inputs ---
rsiLength = input.int(14, title = 'RSI Length')
rsiSource = input.source(close, title = 'RSI Source')

// MA on RSI Inputs
maType = input.string('SMA', title = 'MA Type', options = ['SMA', 'EMA'])
maLength = input.int(14, title = 'MA Length')

// Toggle visibility of the 10 levels (0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
showLevels = input.bool(true, title = 'Show 10 Grid Levels (0-100)')

// --- Calculations ---
// Base RSI
myRsi = ta.rsi(rsiSource, rsiLength)

// RSI-based Moving Average
myRsiMa = maType == 'EMA' ? ta.ema(myRsi, maLength) : ta.sma(myRsi, maLength)

// --- Plotting ---
// Plot main RSI and its MA
pRsi = plot(myRsi, title = 'RSI', color = color.blue, linewidth = 2)
pRsiMa = plot(myRsiMa, title = 'RSI-based MA', color = color.orange, linewidth = 2)

// --- 10 Reference Levels (0 to 100) ---
hline(0, 'Level 0', color = color.gray, linestyle = hline.style_dotted)
hline(10, 'Level 10', color = showLevels ? color.new(color.gray, 50) : color.new(color.white, 100))
hline(20, 'Level 20', color = showLevels ? color.new(color.gray, 50) : color.new(color.white, 100))
hline(30, 'Level 30', color = showLevels ? color.new(color.red, 40) : color.new(color.white, 100)) // Traditional Oversold-ish
hline(40, 'Level 40', color = showLevels ? color.new(color.gray, 50) : color.new(color.white, 100))
hline(50, 'Level 50', color = showLevels ? color.new(color.black, 30) : color.new(color.white, 100)) // Midpoint
hline(60, 'Level 60', color = showLevels ? color.new(color.gray, 50) : color.new(color.white, 100))
hline(70, 'Level 70', color = showLevels ? color.new(color.red, 40) : color.new(color.white, 100)) // Traditional Overbought-ish
hline(80, 'Level 80', color = showLevels ? color.new(color.gray, 50) : color.new(color.white, 100))
hline(90, 'Level 90', color = showLevels ? color.new(color.gray, 50) : color.new(color.white, 100))
hline(100, 'Level 100', color = color.gray, linestyle = hline.style_dotted)
````
