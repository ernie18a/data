# DEMA Double Exponential Moving Average Strategy

- url: https://www.tradingview.com/script/uk1XyAub/
- type: strategy
- pine_id: PUB;gqQc5XjVhSiyytKe07ogJsiRqkswbSub
- version: 3.0

## Description

@Moneros 2017

Based on The DEMA is a fast-acting moving average that is more responsive to market changes than a traditional moving average

[url=https://en.wikipedia.org/wiki/Double_exponential_moving_average]https://en.wikipedia.org/wiki/Double_exponential_moving_average[/url]

[b]
 !!!!  IN ORDER TO AVOID REPAITING ISSUES !!!!
 !!!!  DO NOT VIEW IN LOWER RESOLUTIONS THAN res/2 PARAMETER  !!!![/b]

 for example res = 120 view >= 60m  res = 60 view >= 30m
 the length of the DEMA sampling shouldn't be longer than a candle 


Best profits tested on BTCUSD
res = 105 slowPeriod = 2 fastPeriod = 32
res = 125 slowPeriod = 3 fastPeriod = 21
res = 120 slowPeriod = 2 fastPeriod = 32 
res = 130 slowPeriod = 1 fastPeriod = 24 
res = 40 slowPeriod = 4 fastPeriod = 93 
res = 60 slowPeriod = 1 fastPeriod = 67 



[symbol="BTCUSD"]BTCUSD[/symbol]

## Source Code

````pine
strategy(title = "Best SuperTrend BTCUSD", shorttitle = "SuperTrend BTCUSD",initial_capital=1000, commission_value=0.2, commission_type =strategy.commission.percent, default_qty_value=100 , overlay = true, pyramiding=1, default_qty_type=strategy.percent_of_equity)
//@Moneros 2017

// !!!!  IN ORDER TO AVOID REPAITING ISSUES !!!!
// !!!!  DO NOT VIEW IN LOWER RESOLUTIONS THAN res/2 PARAMETER  !!!!
// for example res = 120 char =60m  res = 60 char = 30m
// the length of the DEMA sampling shouldn't be longer than a candle 

//Best profits for $BTCUSD examples:
//res=165 view=30m fastPeriod=17  slowPeriod=9   profit %67.14 since 2017-08-14 
//res=100 view=30m fastPeriod=16  slowPeriod=30  profit %57 since 2017-08-14 

// If you want get access for super Trend with the best and optimazed values for:
//LTCUSD profit +%120
//ETHUSD profit +%80
//OMGUSD profit +%115
//BCHUSD profit +%80
//LTCUSD profit +%125 
//XRP,DASH comming soon, these profits include trading fee %0.2 
//
// Fee for access 0.015BTC per week 
// Contact me by chat 


fastPeriod    = input(defval =17, title = "DEMA FAST Period", minval = 2)
slowPeriod = input(defval = 9, title = "DEMA SLOW Period", minval = 1)
res = input(title="Resolution  - not lower than chart", type=resolution, defval="165")

demaFast =  security(tickerid, res, 2 * ema(close, fastPeriod) - ema(ema(close, fastPeriod), fastPeriod)  )
demaSlow  = security(tickerid,res, 2 * ema(close, slowPeriod) - ema(ema(close, slowPeriod), slowPeriod)  )


buy = crossover(demaSlow, demaFast)
sell = crossunder(demaSlow, demaFast)
bgcolor( buy[1] ? lime : na, transp=0)
bgcolor( sell[1] ? red : na, transp=0)

bgcolor( demaSlow > demaFast  ? lime : na, transp=95)
bgcolor( demaSlow < demaFast  ? red : na, transp=95)

strategy.entry("BUY", strategy.long, 1, when = buy)
strategy.entry("SELL", strategy.short, 1, when = sell )
````
