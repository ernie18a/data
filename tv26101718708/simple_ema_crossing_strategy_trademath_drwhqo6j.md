# Simple EMA Crossing Strategy TradeMath

- url: https://www.tradingview.com/script/DRWHQo6J-simple-ema-crossing-strategy-trademath/
- type: strategy
- pine_id: PUB;abaaba30385c4e15978f4b6047495556
- version: 1.0

## Description

Simple EMA Crossing strategy, based on crossover Fast exponential moving average = EMA21 and Slow exponential moving average = EMA55.
Default stop loss is 3%, but you can change it.
Default take profit is 9%, it based on stop loss.
Risk to Reward ratio is 1 to 3.

[b]Strategy was tested on BTCUSDT 1H timeframe and works fine with these parameters.[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheHulkTrading

// Simple EMA strategy for BTCUSDT, timeframe - 1H. Based on crossing EMA21 and EMA55


//@version=4
strategy("Simple EMA Crossing Strategy ", overlay=true)

//Percent for stop loss, recommended = 3%
percent_loss = input(3, minval=1, title="Stop Loss") 

//Ema's
emaFast=ema(close,21)
emaSlow=ema(close,55)

//Long Contition is crossover ema21 and ema55
longCond = crossover(emaFast,emaSlow) 

//Stop level based on input percent_loss, default = 3%
stop_level_long = strategy.position_avg_price*((100-percent_loss)/100)
//Take profit - x3 of percent loss, default = 9%
take_level_long = strategy.position_avg_price*((100+percent_loss*3)/100)

//Entries and exits 
strategy.entry("Long", strategy.long, when=longCond)
strategy.exit("Stop Loss/TP","Long", stop=stop_level_long, limit = take_level_long)
````
