# PresentTrend - Strategy [presentTrading]

- url: https://www.tradingview.com/script/TIpnJpU8-PresentTrend-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;81773962c32d4264aa00e32dd2e4a25d
- version: 1.0

## Description

- Introduction and how it is different
The PresentTrend strategy is a unique custom trend-following strategy. This combination allows the strategy to take advantage of both short-term and long-term market trends, making it suitable for various market conditions.

BTCUSDT 4hr chart
https://www.tradingview.com/x/2oHnSX7m/

[700.HK](http://700.hk/) 3D chart
https://www.tradingview.com/x/ysDN32Rb/

- Strategy, How it Works
RSI or MFI: The first part uses a custom indicator based on either the Relative Strength Index (RSI) or the Money Flow Index (MFI). The indicator calculates a PresentTrend value, which generates buy and sell signals based on its crossover and crossunder, indicating potential trend reversals.

ATR: The second part is a popular trend-following indicator that uses the Average True Range (ATR). 

The strategy enters a long position when all buy signals from both strategies are true, and a short position when all sell signals are true. This ensures trades are entered when both short-term and long-term trends align, potentially increasing the strategy's reliability.

- Trade direction
The strategy also includes a trade direction parameter, allowing the user to choose whether to enter long trades, short trades, or both. This makes the strategy adaptable to different market conditions and trading styles.

- Usage
1. Set the input parameters for the custom trend-following strategy.
2. Choose whether to use the RSI or MFI for the custom strategy.
3. Choose the trade direction: long, short, or both.
4. The strategy will generate buy and sell signals based on the conditions of both strategies.
5. Enter a trade when a buy or sell signal is generated, depending on the chosen trade direction.

Please note that this strategy is meant to be a tool to aid in your trading decisions and not a standalone trading system. Always use proper risk management and make sure to test the strategy thoroughly before using it in live trading.

- Default settings
1. Source: 'hlc3', a balanced price level for calculations.
2. Length: 14, a common setting for many technical indicators.
3. Multiplier: 1.618 (the golden ratio), used in calculating the upper and lower thresholds.
4. RSI or MFI: Set to use MFI by default, both are momentum indicators.
5. Trade Direction: 'Both', allowing for both long and short trades.

The default settings are designed to provide a balanced approach to trend detection. However, these can be adjusted based on the user's preferences and the specific characteristics of the market being traded.

- Strategy's default Properties
1. Default Quantity Type: 'strategy.percent_of_equity' 
2. commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1: These parameters set the commission and slippage for the strategy. The commission is set to 0.1% of the trade value, and the slippage (the difference between the expected price of a trade and the price at which the trade is executed) is set to 1.
3. default_qty_type = strategy.percent_of_equity, default_qty_value = 10: These parameters set the default quantity for trades. The default_qty_type is set to strategy.percent_of_equity, which means that the size of each trade will be a percentage of the account equity. The default_qty_value is set to 10, which means that each trade will be 10% of the account equity.
4. initial_capital= 10000: This parameter sets the initial capital for the strategy to $10,000.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PresentTrading

//@version=5

// Define the strategy settings
strategy('PresentTrend - Strategy [presentTrading]' , overlay=true, precision=3, default_qty_type=strategy.cash, 
 commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1, 
  currency=currency.USD, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, initial_capital= 10000)

// Define the input parameters
priceSource  = input.source(title='Source', defval=hlc3, group='PresentTrend') // The price source to use
lengthParam  = input.int(title='Length', defval=14, group='PresentTrend') // The length of the moving average
multiplier = input.float(title='Multiplier', defval=1.618, step=0.1, group='PresentTrend') // The multiplier for the ATR
indicatorChoice  = input.bool(title='Whether to use RSI or MFI', defval=false, group='PresentTrend') // Whether to use RSI or MFI

// Add a parameter for choosing Long or Short
tradeDirection = input.string(title="Trade Direction", defval="Both", options=["Long", "Short", "Both"])

// Calculate the ATR and the upT and downT values
ATR = ta.sma(ta.tr, lengthParam)
upperThreshold = low - ATR * multiplier 
lowerThreshold  = high + ATR * multiplier 

// Initialize the PresentTrend indicator
PresentTrend = 0.0

// Calculate the PresentTrend indicator
PresentTrend := (indicatorChoice ? ta.rsi(priceSource, lengthParam) >= 50 : ta.mfi(hlc3, lengthParam) >= 50) ? upperThreshold < nz(PresentTrend[1]) ? nz(PresentTrend[1]) : upperThreshold : lowerThreshold > nz(PresentTrend[1]) ? nz(PresentTrend[1]) : lowerThreshold

// Calculate the buy and sell signals
longSignal  = ta.crossover(PresentTrend, PresentTrend[2])
shortSignal  = ta.crossunder(PresentTrend, PresentTrend[2])

// Calculate the number of bars since the last buy and sell signals
barsSinceBuy = ta.barssince(longSignal)
barsSinceSell = ta.barssince(shortSignal)
previousBuy = ta.barssince(longSignal[1])
previousSell = ta.barssince(shortSignal[1])

// Initialize the direction variable
trendDirection = 0

// Calculate the direction of the trend
trendDirection := longSignal and previousBuy > barsSinceSell ? 1 : shortSignal and previousSell > barsSinceBuy ? -1 : trendDirection[1]

// Check the trade direction parameter before entering a trade
if (trendDirection == 1 and (tradeDirection == "Long" or tradeDirection == "Both"))
    strategy.entry("Buy", strategy.long) 
if (trendDirection == -1 and (tradeDirection == "Short" or tradeDirection == "Both"))
    strategy.entry("Sell", strategy.short) 

// Add a stop mechanism when the tradeDirection is one-sided
if (tradeDirection == "Long" and trendDirection == -1)
    strategy.close("Buy")
if (tradeDirection == "Short" and trendDirection == 1)
    strategy.close("Sell")

// Visualization
plot(PresentTrend, color=color.blue, title="PresentTrend")
plotshape(series=longSignal, location=location.belowbar, color=color.green, style=shape.labelup, title="Buy Signal")
plotshape(series=shortSignal, location=location.abovebar, color=color.red, style=shape.labeldown, title="Sell Signal")
````
