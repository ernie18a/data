# emasma

- url: https://www.tradingview.com/script/K9xqOSQ2-emasma/
- type: strategy
- pine_id: PUB;1GVCqbCUqOoAL55azpe3HWwHBTqGoJkq
- version: 6.0

## Description

EMA13 and SMA30 crossovers. Good when the market is very volatile.

## Source Code

````pine
//@version=2
strategy(title="EMA13SMA30", overlay=true, calc_on_order_fills=true, calc_on_every_tick=false, initial_capital=10000, 
          default_qty_type=strategy.percent_of_equity, default_qty_value=100, pyramiding=0, commission_value=0.2)

// If you want to limit the backtesting window, uncomment the lines below
testStartYear = input(2018, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)
testPeriod() =>
    time >= testPeriodStart ? true : false

nema = ema(close,13)
nsma = sma(close,30)

strategy.entry(id="Long", long=true, when=((testPeriod() and crossover(nema, nsma)) or time==testPeriodStart))
//strategy.close(id="Long", when=((testPeriod() and crossunder(nema, nsma)) or (timenow-time)<10000000))
strategy.close(id="Long", when=((testPeriod() and crossunder(nema, nsma))))
//strategy.close(id="Long", when=((testPeriod() and crossunder(nema, nsma)) or (timenow-time)<35500000))
//strategy.close(id="Long", when=((testPeriod() and crossunder(nema, nsma)) or (timenow-time)<195500000))

plot(nema, title="EMA13", color=orange, linewidth=4)
plot(nsma, title="SMA30", color=blue, linewidth=4)
plot(ema(close,50), title="EMA50", color=olive, linewidth=2)
plot(ema(close,200), title="EMA200", color=purple, linewidth=2)


//plot(timenow-time,linewidth=2,trackprice=true)
````
