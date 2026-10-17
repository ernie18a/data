# Spyfrat RSI Strategy

- url: https://www.tradingview.com/script/LC8cz33c-Spyfrat-RSI-Strategy/
- type: strategy
- pine_id: PUB;2247
- version: -1.0

## Description

Spyfrat RSI 50 Strategy Pinescript

## Source Code

````pine
//Based on Larry Connors RSI-2 Strategy - Lower RSI
strategy(title="Spyfrat RSI Strategy", shorttitle="SpyfratRSI", overlay=false)
src = close, 

//RSI CODE
up = rma(max(change(src), 0), 30)
down = rma(-min(change(src), 0), 30)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

//Rule for RSI Color
col = rsi > 50?lime: rsi < 60?red : silver

plot(rsi, title="RSI", style=line, linewidth=2,color=col)
//plot(100, title="Upper Line 100",style=line, linewidth=3, color=aqua)
//plot(0, title="Lower Line 0",style=line, linewidth=3, color=aqua)

band1 = plot(70, title="Upper Line 70",style=line, linewidth=1, color=aqua)
band0 = plot(30, title="Lower Line 30",style=line, linewidth=1, color=aqua)
band2 = plot(50, title="Upper Line 50",style=line, linewidth=1, color=green)
fill(band1, band0, color=gray, transp=80)

//plot(long,"long",color=green,linewidth=1)
//plot(short,"short",color=red,linewidth=1)
````
