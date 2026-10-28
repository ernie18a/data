# Cuathro EMA Strategy

- url: https://www.tradingview.com/script/ZTWiav7B/
- type: strategy
- pine_id: PUB;r84gm3aJ41BUq0WTlphUaB7YM1OeAywA
- version: 5.0

## Description

It's a long term script based on multiples EMA, crossover and crossunder.
Based on two good scripts CM Sling and OCC.

Always adjust resolution at least twice than chart.

Enjoy it![symbol="BTCUSD"]BTCUSD[/symbol]

## Source Code

````pine
strategy(title = "Cuathro EMA Scalping", shorttitle = "Cuathro EMA Stoch ",initial_capital=1000, commission_value=0.2, commission_type =strategy.commission.percent, default_qty_value=100 , overlay = false, pyramiding=10, default_qty_type=strategy.percent_of_equity)
//@Moneros 2017
// based on double EMA or DEMA
// DO NOT USE FOR LIVE TRANSACTIONS, repainting issue with len parameter, 14 candles ahead could change last long/short

emaSlowPeriod    = input(defval = 44, title = "EMA Slow, always < EMA Fast - low short term, high long term ", minval = 1)
emaFastPeriod    = input(defval = 72, title = "EMA Fast - low short term, high long term ", minval = 1)
len    = input(defval = 14, title = "Period", minval = 1)
res = input(title="Resolution  - not lower than chart", type=resolution, defval="120")

length = input(14, minval=1, title="Period Stoch")
OverBought = input(80,  title="OverBought Stoch")
OverSold = input(20, title="OverSold Stoch")


closeSeries =  security(tickerid, res, 2 * ema(close[1], len) - ema(ema(close[1], len), len)  )
openSeries  = security(tickerid,res, 2 * ema(close[2], len) - ema(ema(close[2], len), len)  )


slowema = ema(closeSeries - openSeries,emaSlowPeriod)
fastema = ema(closeSeries - openSeries,emaFastPeriod)


bgcolor(slowema< fastema ? red : na, transp=95)
bgcolor(slowema> fastema ? lime : na, transp=95)

bgcolor(crossover(slowema, fastema) ? lime : na, transp=0)
bgcolor(crossunder(slowema, fastema) ? red : na, transp=0)
strategy.entry("BUY", strategy.long, 1, when = crossover(slowema, fastema))
strategy.entry("SELL", strategy.short, 1, when = crossunder(slowema, fastema)) 


smoothK = 3
smoothD = 3

k = sma(stoch(close, high, low, length), smoothK) 
d = sma(k, smoothD) 

plot(k,color=lime)
plot(d,color=red)

plot(OverBought,color=blue)
plot(OverSold,color=blue)

bgcolor( slowema< fastema and k >=OverBought and crossunder(k,d) ? red : na, transp=55)
bgcolor( slowema> fastema and k <=OverSold and  crossover(k,d) ? lime : na, transp=55)

bgcolor(crossunder(k,d) ? red : na, transp=85)
bgcolor(crossover(k,d) ? lime : na, transp=85)
````
