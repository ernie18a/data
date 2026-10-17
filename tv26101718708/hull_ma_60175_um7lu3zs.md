# Hull MA 60/175

- url: https://www.tradingview.com/script/um7lu3ZS-Hull-MA-60-175/
- type: strategy
- pine_id: PUB;dwracBdP7JVoZ9UhV7T3BJNKPqjmrxzO
- version: 1.0

## Description

60; 175 hma cross over signal indicator

## Source Code

````pine
//@version=4
strategy(title = "Hull MA", shorttitle="Junior2", overlay = true)

//HULL MA 1

length = input(60, minval=1,title="HULL MA 1 LENGTH")
src = input(close, title="Source")
hullma = wma(2*wma(src, length/2)-wma(src, length), round(sqrt(length)))

plot(hullma, color=color.green)

//HULLMA 2

alength = input(175, minval=1,title="HULL MA 2 LENGTH")
asrc = input(close, title="Source")
ahullma = wma(2*wma(asrc, alength/2)-wma(asrc, alength), round(sqrt(alength)))

plot(ahullma, color=color.green)

c1up= crossover(hullma,ahullma)
c1down= crossunder(hullma,ahullma)

longCondition = c1up
if longCondition

    strategy.entry("L", strategy.long)


shortCondition = c1down 
if shortCondition

    strategy.entry("S", strategy.short)

plot(close)
````
