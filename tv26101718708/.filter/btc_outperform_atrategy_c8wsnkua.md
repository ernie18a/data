# BTC outperform atrategy

- url: https://www.tradingview.com/script/c8wSnkUA-BTC-outperform-atrategy/
- type: strategy
- pine_id: PUB;6c86a8dd887d42c0ac313a67d9931187
- version: 1.0

## Description

### Code Description

This Pine Script™ code implements a simple trading strategy based on the relative prices of Bitcoin (BTC) on a weekly and a three-month basis. The script plots the weekly and three-month closing prices of Bitcoin on the chart and generates trading signals based on the comparison of these prices. The code can also be applied to Ethereum (ETH) with similar effectiveness.

### Explanation

1. **Inputs and Variables**:
   - The user selects the trading symbol (default is "BINANCE:BTCUSDT").
   - `weeklyPrice` retrieves the closing price of the selected symbol on a weekly interval.
   - `monthlyPrice` retrieves the closing price of the selected symbol on a three-month interval.

2. **Plotting Data**:
   - The weekly price is plotted in blue.
   - The three-month price is plotted in red.

3. **Trading Conditions**:
   - A long position is suggested if the weekly price is greater than the three-month price.
   - A short position is suggested if the three-month price is greater than the weekly price.

4. **Strategy Execution**:
   - If the long condition is met, the strategy enters a long position.
   - If the short condition is met, the strategy enters a short position.

This script works equally well for Ethereum (ETH) by changing the symbol input to "BINANCE:ETHUSDT" or any other desired Ethereum trading pair.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © witus9719

// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © witus9719
//@version=5
strategy("BTC outperform atrategy", overlay=true)

// Symbol selection with 1W and 1M intervals
symbolInput = input("BINANCE:BTCUSDT", title="Symbol")
weeklyPrice = request.security(symbolInput, "W", close)
monthlyPrice = request.security(symbolInput, "3M", close)

// Displaying data on the chart
plot(weeklyPrice, color=color.blue, linewidth=2, title="Weekly Price")
plot(monthlyPrice, color=color.red, linewidth=2, title="Monthly Price")

// Entry and exit conditions
longCondition = weeklyPrice > monthlyPrice
shortCondition = monthlyPrice > weeklyPrice

// Opening a long position
if (longCondition)
    strategy.entry("Long", strategy.long)

// Closing the long position or opening a short position
if (shortCondition)
    strategy.entry("Short", strategy.short)
````
