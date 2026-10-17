# Chirag Strategy SMA with StopLoss

- url: https://www.tradingview.com/script/nRZlZdgm-Chirag-Strategy-SMA-with-StopLoss/
- type: strategy
- pine_id: PUB;b1a849b3ede74465b9c560affe472632
- version: 2.0

## Description

The Moving Average Crossover trading strategy is possibly the most popular trading strategy in the world of trading. This strategy is a good example of so-called traditional strategies. Traditional strategies are always long or short. That means they are never out of the market. The concept of having a strategy that is always long or short may be scary, particularly in today’s market where you don’t know what is going to happen as far as risk on any one market. But a lot of traders believe that the concept is still valid, especially for those of traders who do their own research or their own discretionary trading.

This version uses crossover of simple moving averages of length 10 and 13. This strategy is best suitable for NIFTY and BANKNIFTY under 15min candlestick for intraday and 1hour candlestick for long-term.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chiragchopra91
//@version=4

strategy(title='Chirag Strategy SMA', shorttitle='CHIRAGSMA', overlay=true)

plot(sma(close,10), color=color.green, linewidth=2)
plot(sma(close,13), color=color.red, linewidth=2)

longCondition = crossover(sma(close, 10), sma(close, 13))
shortCondition = crossover(sma(close, 13), sma(close, 10))

// Set stop loss level with input options
longLossPerc = input(title="Long Stop Loss (%)", type=input.float, minval=0.0, step=0.1, defval=1) * 0.01
shortLossPerc = input(title="Short Stop Loss (%)", type=input.float, minval=0.0, step=0.1, defval=1) * 0.01

longStopPrice  = strategy.position_avg_price * (1 - longLossPerc)
shortStopPrice = strategy.position_avg_price * (1 + shortLossPerc)

if longCondition
    if strategy.position_size < 0
        strategy.close('Short', comment="SHORT EXIT")
    strategy.entry('Long', strategy.long, comment="BUY")

if shortCondition
    if strategy.position_size > 0
        strategy.close('Long', comment="BUY EXIT")
    strategy.entry('Short', strategy.short, comment="SHORT")

if strategy.position_size > 0
    strategy.exit('LONG SL', stop=longStopPrice, comment="LONG SL EXIT")

if strategy.position_size < 0
    strategy.exit('SHORT SL', stop=shortStopPrice, comment="SHORT SL EXIT")
    
    
plot(longStopPrice, title="Long StopLoss", color=color.red)
plot(shortStopPrice, title="Short StopLoss", color=color.red)
````
