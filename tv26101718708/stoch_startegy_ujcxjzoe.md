# stoch startegy

- url: https://www.tradingview.com/script/UJcxJZoe-stoch-startegy/
- type: strategy
- pine_id: PUB;qSKOmAm11InBTt7amuLsckObqApRcD8J
- version: 1.0

## Description

Stoch strategy that try to buy in uptrend and to sell in low trend
the bearish and bullish zones are based on regular K stoch over MTF D (3X or timeX3) and vice versa .
The buy and sell rule based on conditions
2- when mtf stochastic cross above 50 and current  is rising, buy 
3- when mtf stochastic cross bellow 50 and current  isfalling, sell

the main script was written by  
03.freeman

I just change some settings to improve it

## Source Code

````pine
//@version=3
strategy("stoch startegy", overlay=false,default_qty_type=strategy.percent_of_equity,default_qty_value=100,currency=currency.USD)

len = input(54, minval=1, title="Length for Main Stochastic") 
smoothK = input(12, minval=1, title="SmoothK for Main Stochastic")
smoothD = input(3, minval=1, title="SmoothD for Main Stochastic")
upLine = input(80, minval=50, maxval=90, title="Upper Line Value?")
lowLine = input(30, minval=10, maxval=50, title="Lower Line Value?")
trailStep=input(100,minval=10,title="Trialing step value")

// current stochastic calculation
k = sma(stoch(close, high, low, len), smoothK)
d = sma(k, smoothD)

//mtf stochastic calculation smoothed with period

mtfK= sma(stoch(close, high, low, len), smoothK*3)
mtfD= sma(k, smoothD*3)

plot(k,"current TF k",blue,style=line, linewidth=2)
plot(d,"current TF d",red,style=line, linewidth=2)
plot(mtfK,"MTF TF k",black,style=line)
plot(mtfD,"Multi TF d",green,style=line, linewidth=2)
hline(upLine)
hline(50)
hline(lowLine)

longCondition = crossover(mtfK, 50) and k>50 and  k>d and mtfK>mtfD
if (longCondition)
    strategy.entry("Lungo", strategy.long)

shortCondition = crossunder(mtfD, 50) and k<50 and  k<d and mtfK<mtfD
if (shortCondition)
    strategy.entry("Corto", strategy.short)
    
exitlong=crossunder(mtfD, upLine)
exitshort=crossover(mtfK, lowLine)

if (exitlong)
    strategy.exit("Esci lungo","Lungo",trail_points=trailStep)
if (exitshort)
    strategy.exit("Esci corto","Corto",trail_points=trailStep)
    
showZones   = input(true, title="Show Bullish/Bearish Zones")
// bullish signal rule: 
bullishRule = k >= mtfD
// bearish signal rule: 
bearishRule = k <= mtfD
// current trading State
ruleState = 0
ruleState := bullishRule ? 1 : bearishRule ? -1 : nz(ruleState[1])
bgcolor(showZones ? ( ruleState==1 ? green : ruleState==-1 ? red : gray ) : na , title="supertrend Bullish/Bearish Zones", transp=90)
````
