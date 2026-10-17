# Rule Number 1 Signals

- url: https://www.tradingview.com/script/Z7dzuStH-Rule-Number-1-Signals/
- type: strategy
- pine_id: PUB;Kunn6Z6vd7CgsbuCHDUZzy6fVeKR5Omm
- version: 12.0

## Description

This script takes the Rule #1 3 tools and plots them on the graph, to provide an additional level of indication for when to sell and when to buy.

## Source Code

````pine
//@version=4
strategy("Rule Number 1 Signals", overlay=true)

//This strategy is based off of the Book Rule #1 by Phil Town which teaches Long Term GARP/Value investing. There are three signals, MACD, Stochastics, and Moving Averages,
//that are all used in conjunction to signal a LONG entry. It is better used on Daily and above time periods as the book as about long term investing. Remember, the book, 
//is about fundamental business analysis, to see if its a wonderful company, as the focus, and technical analysis is just a trigger. I built this as an experiment to see what
//would happen if the signals were applied as per the book

//MACD
fastLength = input(8)
slowlength = input(17)
MACDLength = input(9)

MACD = ema(close, fastLength) - ema(close, slowlength)
aMACD = ema(MACD, MACDLength)
macdDelta = MACD - aMACD

//SMA signal
smaSignal = input(10)
sma = sma(close, smaSignal)

//Stochastics 14-5 (Slow)
stochasticLength = input(14, minval=1)
stochasticOverBought = input(80)
stochasticOverSold = input(20)

smoothK = 5
smoothD = 5

k = sma(stoch(close, high, low, stochasticLength), smoothK)
d = sma(k, smoothD)

//Buy and close conditions
smaCrossOver = crossover(close, sma)
stochasticCrossOver = crossover(k, d)
macdCrossOver = crossover(macdDelta, 0)

smaBullish = crossover(close, sma) or 
   close >= sma and abs(close - sma) > abs(close[1]) - sma[1]
macdBullish = crossover(macdDelta, 0) or 
   macdDelta >= 0 and abs(MACD - aMACD) > abs(MACD[1] - aMACD[1])
stochasticBullish = crossover(k, d) or k >= d and abs(k - d) > abs(k[1] - d[1])

macdCrossUnder = crossunder(macdDelta, 0)
stochasticCrossUnder = crossunder(k, d)
smaCrossUnder = crossunder(close, sma(close, smaSignal))

smaBearish = crossunder(close, sma) or 
   close <= sma and abs(close - sma) > abs(close[1]) - sma[1]
macdBearish = crossunder(macdDelta, 0) or 
   macdDelta >= 0 and abs(MACD - aMACD) > abs(MACD[1] - aMACD[1])
stochasticBearish = crossunder(k, d) or k <= d and abs(k - d) > abs(k[1] - d[1])


//Set up the premises for the strategy
long = macdCrossOver and smaBullish and stochasticBullish or 
   macdBullish and smaCrossOver and stochasticBullish or 
   macdBullish and smaBullish and stochasticCrossOver
closeLong = macdCrossUnder and smaBearish and stochasticBearish or 
   macdBearish and smaCrossUnder and stochasticBearish or 
   macdBearish and smaBearish and stochasticCrossUnder


//Strategy to go long or to close out long term positions.
if long
    strategy.entry("buy", strategy.long, 10, comment="BUY")

if closeLong
    strategy.close("buy")
````
