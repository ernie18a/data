# Volatility Capture RSI-Bollinger - Strategy [presentTrading]

- url: https://www.tradingview.com/script/Xr2xrNAY-Volatility-Capture-RSI-Bollinger-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;1c4f6af25f6e458a80205c09766241d2
- version: 1.0

## Description

- Introduction and how it is different
The 'Volatility Capture RSI-Bollinger - Strategy [presentTrading]' is a trading strategy that combines the concepts of Bollinger Bands (BB), Relative Strength Index (RSI), and Simple Moving Average (SMA) to generate trading signals. The uniqueness of this strategy is it calculates which is a dynamic level between the upper and lower Bollinger Bands based on the closing price. This unique feature allows the strategy to adapt to market volatility and price movements.

The market in Crypto and Stock are highly volatile, making them suitable for a strategy that uses Bollinger Bands. The RSI can help identify overbought or oversold conditions in this often speculative market.

BTCUSD 4hr chart
https://www.tradingview.com/x/M5dADidC/

[700.HK](http://700.hk/) 3hr chart
https://www.tradingview.com/x/Ozsr1W6C/

Remember, the effectiveness of a trading strategy also depends on other factors such as the timeframe used, the specific settings of the indicators, and the overall market conditions. It's always recommended to backtest and paper trade a strategy before using it in live trading.

- Strategy, How it Works
Dynamic Bollinger Band: The strategy works by first calculating the upper and lower Bollinger Bands based on the user-defined length and multiplier. It then uses the Bollinger Bands and the closing price to dynamically adjust the presentBollingBand value. In the end, it generates a long signal when the price crosses over the present Bolling Band and a short signal when the price crosses under the present Bolling Band.

RSI: If the user has chosen to use RSI for signals, the strategy also calculates the RSI and its SMA, and uses these to generate additional long and short signals. The RSI-based signals are only used if the 'Use RSI for signals' option is set to true.

The strategy then checks the chosen trading direction and enters a long or short position accordingly. If the trading direction is set to 'Both', the strategy can enter both long and short positions.

Finally, the strategy exits a position when the close price crosses under the present Bolling Band for a long position, or crosses over the present Bolling Band for a short position.

- Trade direction
The strategy also includes a trade direction parameter, allowing the user to choose whether to enter long trades, short trades, or both. This makes the strategy adaptable to different market conditions and trading styles.

- Usage
1. Set the input parameters as per your trading preferences. You can choose the price source, the length of the moving average, the multiplier for the ATR, whether to use RSI for signals, the RSI and SMA periods, the bought and sold range levels, and the trading direction.
2. The strategy will then generate buy and sell signals based on these parameters. You can use these signals to enter and exit trades.

- Default settings
1. Source: hlc3
2. Length: 50
3. Multiplier: 2.7183
4. Use RSI for signals: True
5. RSI Period: 10
6. SMA Period: 5
7. Bought Range Level: 55
8. Sold Range Level: 50
9. Trade Direction: Both

- Strategy's default Properties
1. Default Quantity Type: 'strategy.percent_of_equity'
2. commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1: These parameters set the commission and slippage for the strategy. The commission is set to 0.1% of the trade value, and the slippage (the difference between the expected price of a trade and the price at which the trade is executed) is set to 1.
3. default_qty_type = strategy.percent_of_equity, default_qty_value = 15: These parameters set the default quantity for trades. The default_qty_type is set to strategy.percent_of_equity, which means that the size of each trade will be a percentage of the account equity. The default_qty_value is set to 15, which means that each trade will be 15% of the account equity.
4. initial_capital= 10000: This parameter sets the initial capital for the strategy to $10,000.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PresentTrading

//@version=5
// Define the strategy settings
strategy('Volatility Capture RSI-Bollinger - Strategy [presentTrading]', overlay=true, precision=3, default_qty_type=strategy.cash, 
 commission_value= 0.1, commission_type=strategy.commission.percent, slippage=1, 
  currency=currency.USD, default_qty_type = strategy.percent_of_equity, default_qty_value = 15, initial_capital= 10000)

// Define the input parameters for the indicator
priceSource  = input.source(title='Source', defval=hlc3, group='presentBollingBand') // The price source to use
lengthParam   = input.int(50, 'lengthParam', minval=1, group='presentBollingBand') // The length of the moving average
multiplier = input.float(2.7183, 'Multiplier', minval=0.1, step=.1, group='presentBollingBand') // The multiplier for the ATR
useRSI = input.bool(true, 'Use RSI for signals', group='presentBollingBand') // Boolean input to decide whether to use RSI for signals
rsiPeriod = input.int(10, 'RSI Period', minval=1, group='presentBollingBand') // The period for the RSI calculation
smaPeriod = input.int(5, 'SMA Period', minval=1, group='presentBollingBand') // The period for the SMA calculation
boughtRange = input.float(55, 'Bought Range Level', minval=1, group='presentBollingBand') // The level for the bought range
soldRange = input.float(50, 'Sold Range Level', minval=1, group='presentBollingBand') // The level for the sold range

// Add a parameter for choosing Long or Short
tradeDirection = input.string("Both", "Trade Direction", options=["Long", "Short", "Both"], group='presentBollingBand') // Dropdown input for trade direction

// Calculate the bollingerBand
barIndex = bar_index // The current bar index
upperBollingerBand = ta.sma(high, lengthParam) + ta.stdev(high, lengthParam) * multiplier // Calculate the upper Bollinger Band
lowerBollingerBand = ta.sma(low, lengthParam) - ta.stdev(low, lengthParam) * multiplier // Calculate the lower Bollinger Band

var float presentBollingBand = na // Initialize the presentBollingBand variable
crossCount = 0 // Initialize the crossCount variable

// Calculate the buy and sell signals
longSignal1 = ta.crossover(priceSource, presentBollingBand) // Calculate the long signal
shortSignal1 = ta.crossunder(priceSource, presentBollingBand) // Calculate the short signal

// Calculate the RSI
rsiValue = ta.rsi(priceSource, rsiPeriod) // Calculate the RSI value
rsiSmaValue = ta.sma(rsiValue, smaPeriod) // Calculate the SMA of the RSI value

// Calculate the buy and sell signals
longSignal2 = rsiSmaValue > boughtRange // Calculate the long signal based on the RSI SMA
shortSignal2 = rsiSmaValue < soldRange // Calculate the short signal based on the RSI SMA

presentBollingBand := na(lowerBollingerBand) or na(upperBollingerBand)?0.0 : close>presentBollingBand?math.max(presentBollingBand,lowerBollingerBand) : close<presentBollingBand?math.min(presentBollingBand,upperBollingerBand) : 0.0


if (tradeDirection == "Long" or tradeDirection == "Both") and longSignal1 and (useRSI ? longSignal2 : true) // Use RSI for signals if useRSI is true
    presentBollingBand := lowerBollingerBand // If the trade direction is "Long" or "Both", and the long signal is true, and either useRSI is false or the long signal based on RSI is true, then assign the lowerBollingerBand to the presentBollingBand.
    strategy.entry("Long", strategy.long) // Enter a long position.

if (tradeDirection == "Short" or tradeDirection == "Both") and shortSignal1 and (useRSI ? shortSignal2 : true) // Use RSI for signals if useRSI is true
    presentBollingBand := upperBollingerBand // If the trade direction is "Short" or "Both", and the short signal is true, and either useRSI is false or the short signal based on RSI is true, then assign the upperBollingerBand to the presentBollingBand.
    strategy.entry("Short", strategy.short) // Enter a short position.

// Exit condition
if (strategy.position_size > 0 and ta.crossunder(close, presentBollingBand)) // If the strategy has a long position and the close price crosses under the presentBollingBand, then close the long position.
    strategy.close("Long")
if (strategy.position_size < 0 and ta.crossover(close, presentBollingBand)) // If the strategy has a short position and the close price crosses over the presentBollingBand, then close the short position.
    strategy.close("Short")

//~~ Plot
plot(presentBollingBand,"presentBollingBand", color=color.blue) // Plot the presentBollingBand on the chart.
````
