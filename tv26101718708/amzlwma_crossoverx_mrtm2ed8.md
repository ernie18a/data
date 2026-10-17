# AM_ZLWMA Crossover_x

- url: https://www.tradingview.com/script/mRTM2Ed8-AM-ZLWMA-Crossover-x/
- type: strategy
- pine_id: PUB;3Xuh6up4J5fPGendSjieCtedNmo79oF2
- version: 1.0

## Description

Dear All,

Please find updated version of Zero lag WMA crossover. In addition to this added 20/50 EMA to get better results.

Settings: 
ZLWMA = 8 identified by Blue line
Fast WMA = 21 identified by Red line	
EMA Period 20/50

How to Trade: 

Buy: Wait for positive crossover (Blue cross above Red) to happen trade can be taken there but to get better results post crossover once price move above EMA 20 then buy can be initiated.
Sell: Wait for negative crossover (Blue cross below Red) to happen trade can be taken there but to get better results post crossover once price move below EMA 20 then sell can be initiated.

Reason to wait for confirmation of price action above / Below moving average is most of the time it happens that even after crossover happens sometimes it was just a pull back and from there it could be a possibility for reversal. Once price action confirms moving above / below EMA20 then trade will be initiated.

Please comment and ask for any doubt

## Source Code

````pine
//The formula for a given N-Day period and for a given Data series is
//Lag=(Period-2)/3}
//EmaData=Data+(Data-Data(Lagdaysago)
//ZLEMA={EMA(EmaData,Period)
//The idea is do a regular exponential moving average (EMA) calculation
//but on a de-lagged data instead of doing it on the regular data.
//Data is de-lagged by removing the data from "lag" days ago thus removing (or attempting to) the cumulative effect of the moving average.
////////////////////////////////////////////////////////////////////////////////////////
//@version=2
strategy("AM_ZLWMA Crossover_x", overlay = true)
nPeriod = input(title="ZLWMA Period", type=integer, defval=8, minval=1)
xPrice = close
xLag = sqrt (nPeriod)
xWMAData = (xPrice + (xPrice - xPrice[xLag]))
xZLWMA = wma(xWMAData, nPeriod)
wmalength=input(21)
emalength1=input(20)
emalength2=input(50)
src=close
ema1 = ema(src, emalength1)
ema2 = ema(src, emalength2)
short = wma(src, wmalength)
long = xZLWMA
co = crossover(long, short)
cu = crossunder(long, short)

if (not na(xLag))
    if (co)
        strategy.entry("Long", strategy.long, comment="buy")
    if (cu)
        strategy.entry("Short", strategy.short, comment="sell")

plot(cross(short, long) ? short : na, style = cross, linewidth = 3)
col = long > short ? green : long < short ? red : blue
p1 = plot(short, title="short", style=linebr, linewidth=2, color=red)
p2 = plot(long, title="Long", style=linebr, linewidth=2, color=blue)
p3 = plot(ema1, title="EMA20", style=linebr, linewidth=3, color=green)
p4 = plot(ema2, title="EMA50", style=linebr, linewidth=3, color=yellow)
````
