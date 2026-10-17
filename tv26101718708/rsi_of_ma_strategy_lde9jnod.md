#  RSI of MA Strategy 

- url: https://www.tradingview.com/script/Lde9JnOd-RSI-of-MA-Strategy/
- type: strategy
- pine_id: PUB;NfMTdWjbuqBa0riT40mKnPRmlXEt3YQA
- version: 1.0

## Description

Strategy of my RSI of MA Indicator

https://www.tradingview.com/script/MfZK8cdn-RSI-of-MA/

## Source Code

````pine
//@version=2
strategy(title = " RSI of MA Strategy ",shorttitle="MARSI Strategy",default_qty_type = strategy.percent_of_equity, default_qty_value = 100,commission_type=strategy.commission.percent,commission_value=0.1,initial_capital=1)



lengthofma = input(15,minval=1,title="Length of MA")
len = input(14, minval=1, title="Length")
upperband = input(70,minval=1,title='Upper Band for RSI')
lowerband = input(30,minval=1,title="Lower Band for RSI")

src=sma(close,lengthofma)
up = rma(max(change(src), 0), len)
down = rma(-min(change(src), 0), len)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
plot(rsi, color=purple)

band1 = hline(upperband)
band0 = hline(lowerband)
fill(band1, band0, color=purple, transp=90)



longCond =  crossover(rsi,lowerband)

shortCond =  crossunder(rsi,upperband)




monthfrom =input(1)
monthuntil =input(12)
dayfrom=input(1)
dayuntil=input(31)

if (  longCond    and  month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil) 
    strategy.entry("LONG", strategy.long, stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="LONG")
    
else
    strategy.cancel(id="LONG")
    



if ( shortCond   and month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil ) 

    strategy.entry("SHORT", strategy.short,stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="SHORT")
else
    strategy.cancel(id="SHORT")
````
