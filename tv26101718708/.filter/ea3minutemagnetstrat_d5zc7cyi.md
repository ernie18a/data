# EA_3Minute_MagnetStrat

- url: https://www.tradingview.com/script/D5zC7CYi-EA-3Minute-MagnetStrat/
- type: strategy
- pine_id: PUB;3170
- version: -1.0

## Description

Magnet Script

## Source Code

````pine
//Based on Larry Connors RSI-2 Strategy - Lower RSI
strategy(title="EA_3Minute_MagnetStrat", shorttitle="EA_3Minute_MagnetStrat", overlay=false,overlay=false, pyramiding=1999, initial_capital=60000, currency=currency.USD)
src = close, 
//RSI CODE
up = rma(max(change(src), 0), 30)
down = rma(-min(change(src), 0), 30)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
//Criteria for Moving Avg rules
ma20= vwma(close,20)
ma50 = vwma(close,50)
ma100= vwma(close,100)

//Rule for RSI Color
//col = ma30 > ma50 > ma200 and rsi <=53?lime: ma50 < ma200  and rsi >= 60?red : silver
long1 = ma20 > ma50 and ma50 > ma100 and rsi < 50 
short1 = ma20 < ma50 and ma50 < ma100 and rsi > 48.5 
//plot(rsi, title="RSI", style=line, linewidth=1,color=col)
//plot(100, title="Upper Line 100",style=line, linewidth=3, color=aqua)
//plot(0, title="Lower Line 0",style=line, linewidth=3, color=aqua)

//band1 = plot(60, title="Upper Line 60",style=line, linewidth=1, color=aqua)
//band0 = plot(44, title="Lower Line 40",style=line, linewidth=1, color=aqua)
//fill(band1, band0, color=silver, transp=90)
//strategy.entry ("buy", strategy.long, when=long)
//strategy.entry ("sell", strategy.short, when=short)
//plot(long,"long",color=green,linewidth=1)
//plot(short,"short",color=red,linewidth=1)
//
long = long1[1] == 0 and long1 == 1
short = short1[1] == 0 and short1 == 1
longclose = long[3] == 1
shortclose = short[3] == 1

//Alert

strategy.entry("short", strategy.short,qty = 1000000,oca_type = strategy.oca.cancel, when=short)
strategy.entry("long", strategy.long,qty=1000000,oca_type = strategy.oca.cancel, when=long)
plot(long,"long",color=green,linewidth=1)
plot(short,"short",color=red,linewidth=1)
strategy.close("long",when=longclose)
strategy.close("short",when=shortclose)

//strategy.exit(id="long",qty = 100000,when=longclose)
//strategy.exit(id="short",qty = 100000,when=shortclose)
plot(longclose,"close",color=blue,linewidth=1)
plot(shortclose,"close",color=orange,linewidth=1)
//strategy.exit(id="Stop", profit = 20, loss = 100)
````
