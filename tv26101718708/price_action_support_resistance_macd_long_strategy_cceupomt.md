# Price Action - Support & Resistance + MACD LONG Strategy

- url: https://www.tradingview.com/script/cCEupOMt-Price-Action-Support-Resistance-MACD-LONG-Strategy/
- type: strategy
- pine_id: PUB;41de6f534f454f17ade7d4cddfd7eefd
- version: 1.0

## Description

Using "Price Action - Support & Resistance by DGT" and the MACD (Moving Average Convergence Divergence) indicator in TradingView can help develop a trade strategy. Here's a step-by-step approach you can follow:

1. Identifying Support and Resistance Levels: Apply the "Price Action - Support & Resistance by DGT" indicator to your chart. This indicator helps you identify key support and resistance levels based on price action. These levels act as potential areas where the price may reverse or consolidate.

2. Confirming Support and Resistance Levels: Once the indicator has plotted support and resistance levels on your chart, analyze the historical price action around these levels. Look for multiple touches or bounces from the same level, which adds strength to the support or resistance zone.

3. Analyzing the MACD Indicator: Add the MACD indicator to your chart. The MACD consists of two lines: the MACD line and the signal line, along with a histogram representing the difference between the two lines. The MACD helps identify momentum and potential trend reversals.

    When the MACD line crosses above the signal line and the histogram turns positive, it suggests bullish momentum.

4. Identifying Trade Opportunities:
   
   Bullish Trade: Look for a bullish setup when the price approaches a strong support level identified by the "Price Action - Support & Resistance by DGT" indicator. Wait for the MACD lines to cross above the signal line and the histogram to turn positive, indicating bullish momentum. Enter a long position with a stop loss below the 
   support level.

Managing the Trade: Once you enter a trade, consider setting a target based on the distance between your entry point and the nearest significant support or resistance level. You can also use trailing stop losses or other risk management techniques to protect your profits and limit potential losses.
Remember that no trading strategy is guaranteed to be successful, and it's important to practice proper risk management and conduct thorough analysis before making any trading decisions. Additionally, it's recommended to backtest and demo trade this strategy before using it with real money.

## Source Code

````pine
//@version=4
strategy("Price Action - Support & Resistance + MACD Strategy", overlay=true)

// Price Action - Support & Resistance
supportLevel = input(100, title="Support Level Strength", minval=1)
resistanceLevel = input(100, title="Resistance Level Strength", minval=1)

var supportPrice = 0.0
var resistancePrice = 0.0

if low <= supportPrice or barstate.islast
    supportPrice := low
if high >= resistancePrice or barstate.islast
    resistancePrice := high

plot(supportPrice, color=color.green, linewidth=1, title="Support")
plot(resistancePrice, color=color.red, linewidth=1, title="Resistance")

// MACD Indicator
[macdLine, signalLine, _] = macd(close, 26, 100, 9)
macdHistogram = macdLine - signalLine

// Bullish Trade Setup
bullishSetup = crossover(macdLine, signalLine) and macdHistogram > 0 and close > supportPrice
plotshape(bullishSetup, color=color.green, title="Bullish Setup", style=shape.triangleup, location=location.belowbar)

// Stop Loss and Take Profit Levels
stopLossLevel = input(5, title="Stop Loss Level (%)", minval=0.1, step=0.1)
takeProfitLevel = input(7.5, title="Take Profit Level (%)", minval=0.1, step=0.1)

// Execute Long Trades
if bullishSetup
    stopLossPrice = close * (1 - stopLossLevel / 100)
    takeProfitPrice = close * (1 + takeProfitLevel / 100)
    strategy.entry("Long", strategy.long)
    strategy.exit("Exit", "Long", stop=stopLossPrice, limit=takeProfitPrice)
````
