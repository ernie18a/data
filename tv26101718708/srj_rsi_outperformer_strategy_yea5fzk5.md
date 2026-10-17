# SRJ RSI Outperformer Strategy

- url: https://www.tradingview.com/script/Yea5fzK5-SRJ-RSI-Outperformer-Strategy/
- type: strategy
- pine_id: PUB;df1b8d205cd645698e08fa521c184674
- version: 3.0

## Description

For Daily timeframe use 100, 40, 21, 200 in input settings.
For 15 Minute time frame use 14, 28, 21, 100 in input settings

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sapt_Jash

//@version=5
strategy("SRJ RSI Outperformer Strategy", overlay=true)

srcperiod1 = input.int(14, minval=1, title="Length Of Fast RSI")
srcperiod2 = input.int(28, minval=1, title="Length Of Slow RSI")
srcperiod3 = input.int(14, minval=1, title="Length Of Moving Average")
srcperiod4 = input.int(100, minval=1, title="Length Of Deciding Moving Average")
srcperiod5 = input.int(20, minval=1, title="Target Profit Percentage")
srcperiod6 = input.int(10, minval=1, title="Stoploss Percentage")
rsi1 = ta.rsi(close, srcperiod1)
rsi2 = ta.rsi(close, srcperiod2)
divergence1 = (rsi2/rsi1)
divergence2 = (rsi1/divergence1)
ma1 = ta.sma(rsi1, srcperiod3)
ma2 = ta.sma(divergence2, srcperiod3)



//Long Conditions//
longcondition = (ta.crossover(ma2, ma1) and (close > ta.sma(close, srcperiod4)))

    

//Exit onditions//
exitcondition = (ta.crossunder(ma2, ma1) or (ta.crossunder(close, ta.sma(close, srcperiod4))))


if (longcondition)
    strategy.entry("Long Entry", strategy.long)
    
if (exitcondition)
    
    strategy.exit("Long Exit", profit = close * (1+(srcperiod5/100)), loss = close * (1-(srcperiod6/100)))
````
