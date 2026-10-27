# Binary Options Strategy Template

- url: https://www.tradingview.com/script/pvnR5RYJ-Binary-Options-Strategy-Template/
- type: strategy
- pine_id: PUB;0902c207f2b14ce6a5a282049a02f12a
- version: 1.0

## Description

With the hype around Binary Options trading (more like gambling instead of trading) it is good to be able to backtest a strategy before using it in the live markets. 
In a Binary Options trade the trade get's closed after a specific amount of time and the only thing that matters is if the market has increased in price or decreased after that amount of time.

Because of this a strategy backtest should close all positions after a specific amount of time. In this super small script the number of bars since the trade was opened is used as a way to close the position. So for example if you use this strategy on the 1 minute charts with number of bars set to 5 it will close the position 5 minutes after opening it. Purpose of this script is using it as a strategy on already existing scripts to check viability for options trading.

With the limited pine knowledge that I have I do not know if it is possible to create a more realistic binary options strategy which also calculated the profit. If someone knows a more advanced version of this please let me know.

## Source Code

````pine
//@version=4
strategy("Binary Options Strategy Template", overlay=true)

// In this code we track the bar where a position was opened and close the position
// aftera specified number of bars. The objective of this script is testing long/short signals
// for knowing the amount of times it would turn a profit or not.

// User input for amount of bars till close
barsTillClose = input(5, minval=2, title="Amount of Bars Till Close Position")


// SIMPLE ENTRY LOGIC (insert long/short signal here)
sma = sma(close, 14)
strategy.entry("Long", strategy.long, when=close > sma)
strategy.entry("Short", strategy.long, when=close < sma)

// Track the Entry Bar
entryTime = float(na)
timeClose = bool(na)
entryTime := timeClose[1] ? na : strategy.position_size[0] > strategy.position_size[1] ? bar_index : entryTime[1]

// See if we need to close
timeClose := bar_index >= entryTime+(barsTillClose-2)
strategy.close("Long", when=timeClose)
strategy.close("Short", when=timeClose)


plot(sma)
````
