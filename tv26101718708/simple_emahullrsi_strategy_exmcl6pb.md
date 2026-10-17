# Simple EMA_Hull_RSI Strategy

- url: https://www.tradingview.com/script/exMcL6PB-Simple-EMA-Hull-RSI-Strategy/
- type: strategy
- pine_id: PUB;bP09j6CnUVzdvmLhCxdgsoPXegxQNxqH
- version: 1.0

## Description

Another simple strategy. Crossing EMA & Hull MA  and the level of RSI (overbought/oversold) defines long or short. 
Can be improved by varying the parameters and adding take profit / stop loss.
Backtest: ETHUSD (Bitmex): 5m

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bitduke

//@version=4
strategy(shorttitle="EHR", title="Simple EMA_Hull_RSI", overlay=false, 
     calc_on_every_tick=false, pyramiding=0, default_qty_type=strategy.cash, 
     default_qty_value=1000, currency=currency.USD, initial_capital=1000,
     commission_type=strategy.commission.percent, commission_value=0.075)

// EMA
len = input(minval=1, title="EMA Length", defval=50)
src = input(close, title="EMA Source")
final_ema = ema(src, len)
plot(final_ema, color=color.red, title="EMA")

overbought = input(60, title="overbought value")
oversold = input(45, title="oversold value")

overbought_signal = rsi(close, 14) > overbought
oversold_signal = rsi(close, 14) < oversold
barcolor(overbought_signal ? color.black : na)
barcolor(oversold_signal ? color.blue : na)
// Hull MA
n = input(title="Hull Length", defval=7)
n2ma=2*wma(close,round(n/2))
nma=wma(close,n)
diff=n2ma-nma
sqn=round(sqrt(n))

n2ma1=2*wma(close[1],round(n/2))
nma1=wma(close[1],n)
diff1=n2ma1-nma1
sqn1=round(sqrt(n))

n1=wma(diff,sqn)
n2=wma(diff1,sqn)
c=n1>n2?color.green:color.red
ma=plot(n1,color=c)

// Strategy Logic
longCondition =  overbought_signal and crossover(n1,final_ema) 
shortCondition = oversold_signal and crossover(final_ema,n1) 

strategy.entry("EHR_Long", strategy.long, when=longCondition)
strategy.entry("EHR_Short", strategy.short, when=shortCondition)
````
