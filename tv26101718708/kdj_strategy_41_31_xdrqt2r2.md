# kdj Strategy 41 - 31

- url: https://www.tradingview.com/script/XdRQT2R2-kdj-Strategy-41-31/
- type: strategy
- pine_id: PUB;NMbdF89hTh00tw27Vi6WNJZ2ri2ISLKZ
- version: 1.0

## Description

very profitable on 1D timeframe on btcusd or btceur

## Source Code

````pine
strategy("kdj Strategy pJ<1",shorttitle="kdj Strategy pJ<1",overlay=true,max_bars_back=200,default_qty_value=1,initial_capital=1000,currency=currency.USD)
// with alert pJ<20 
ilong = input(41)
isig = input(31, title="signal")

bcwsma(s,l,m) => 
    _s = s
    _l = l
    _m = m
    _bcwsma = (_m*_s+(_l-_m)*nz(_bcwsma[1]))/_l
    _bcwsma
    
c = close
h = highest(high, ilong)
l = lowest(low,ilong)
RSV = 100*((c-l)/(h-l))
pK = bcwsma(RSV, isig, 1)
pD = bcwsma(pK, isig, 1)
pJ = 3 * pK-2 * pD

plot(pK, color= #1E88E5,transp=0)
plot(pD, color=#FF6F00,transp=0)
plot(pJ, color=black,transp=0)


go_long= crossover(pJ,pD) 
go_short=crossover(pD,pJ) 

strategy.entry("Buy",strategy.long,1,when =go_long)


// strategy.entry("close short position",strategy.long,1,when =pJ<1)


strategy.entry("Sell",strategy.short,1,when = go_short)
// strategy.entry("close Long position",strategy.short,1,when = pJ>110)


alertcondition(pJ>110, title='Alert pJ>110 sell ')

alertcondition(pJ<20, title='Alert -pJ<20 buy Opportunity')


alertcondition(go_long, title='Alert - go long')
alertcondition(go_short, title='Alert - go short')
````
