# Simple RSI and SMA Long and Short (by Coinrule)

- url: https://www.tradingview.com/script/Clpg5ju2-Simple-RSI-and-SMA-Long-and-Short-by-Coinrule/
- type: strategy
- pine_id: PUB;4b1a562c415c408b89c337643b2483b4
- version: 1.0

## Description

The relative strength index ( RSI ) is a momentum indicator used in technical analysis . RSI measures the speed and magnitude of a security's recent price changes to evaluate overvalued or undervalued conditions in the price of that security. The RSI is displayed as an oscillator (a line graph) on a scale of zero to 100. The RSI can do more than point to overbought and oversold securities. It can also indicate securities that may be primed for a trend reversal or corrective pullback in price. It can signal when to buy and sell. Traditionally, an RSI reading of 70 or above indicates an overbought situation. A reading of 30 or below indicates an oversold condition.

A simple moving average ( SMA ) calculates the average of a selected range of prices, usually closing prices, by the number of periods in that range.

The Strategy enters and closes the trade when the following conditions are met:

LONG
SMA100 is greater than SMA150
RSI is greater than 50

SHORT
SMA100 is less than SMA150
RSI is less than 50

When a long position is opened, it remains open until the conditions for a short are met at which point the long position is closed and the short position is opened. Then, when the conditions for the long position are met, the short will be closed and a long will be opened.

This strategy is back tested from 1 January 2022 to simulate how the strategy would work in a bear market. The strategy provides good returns.

The strategy assumes each order is using 30% of the available coins to make the results more realistic and to simulate you only ran this strategy on 30% of your holdings. A trading fee of 0.1% is also taken into account and is aligned to the base fee applied on Binance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coinrule

//@version=5
strategy('RSI and SMA',
         overlay=true,
         initial_capital=1000,
         process_orders_on_close=true,
         default_qty_type=strategy.percent_of_equity,
         default_qty_value=30,
         commission_type=strategy.commission.percent,
         commission_value=0.1)

showDate = input(defval=true, title='Show Date Range')
timePeriod = time >= timestamp(syminfo.timezone, 2022, 1, 1, 0, 0)
notInTrade = strategy.position_size <= 0

//==================================Buy Conditions============================================
//RSI
length = input(14)
rsi = ta.rsi(close, length)

//SMA
fastEMA = ta.sma(close, 100)
slowEMA = ta.sma(close, 150)
plot(fastEMA, color = color.green)
plot(slowEMA, color = color.blue)


bullish = ta.crossover(fastEMA, slowEMA) and rsi > 50
bearish = ta.crossover(slowEMA, fastEMA) and rsi < 50

strategy.entry("Long", strategy.long, when=bullish and timePeriod)
strategy.close("Exit", when=bearish)

strategy.entry("Short", strategy.short, when=bearish and timePeriod)
strategy.close("Exit", when=bullish)
````
