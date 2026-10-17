# Linear Regression Curve CrossOver Strategy

- url: https://www.tradingview.com/script/cyFlSiNY-Linear-Regression-Curve-CrossOver-Strategy/
- type: strategy
- pine_id: PUB;DaNky2Mvlh3GxiDB8BNjzyen0bJrd3gf
- version: 2.0

## Description

The  worst way of the using Linear Regression

## Source Code

````pine
//@version=3
strategy(title="Linear Regression Curve CrossOver Strategy", shorttitle="LRC Crossover", overlay=true)
src = close
len1 = input(defval=100, minval=1, title="Length")
offset = 0
outfast = linreg(src, len1, offset)
p1 = plot(outfast,color=blue)

len2 = input(defval=150, minval=1, title="Length")

outslow = linreg(src, len2, offset)
p2 = plot(outslow,color=red)

colorband= outfast< outslow ?red:green

fill(p1,p2,color=colorband,transp=50)

yearfrom = input(2018)
yearuntil =input(2019)
monthfrom =input(1)
monthuntil =input(12)
dayfrom=input(1)
dayuntil=input(31)



if (  crossover(outfast,outslow) and   year >= yearfrom and year <= yearuntil and month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil) 
    strategy.entry("BUY", strategy.long, stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="BUY")
    
else
    strategy.cancel(id="BUY")


if ( crossover(outslow,outfast) and  year >= yearfrom and year <= yearuntil and month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil ) 

    strategy.entry("SELL", strategy.short,stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="SELL")
else
    strategy.cancel(id="SELL")
````
