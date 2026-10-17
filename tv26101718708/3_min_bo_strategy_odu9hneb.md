# 3 Min BO Strategy

- url: https://www.tradingview.com/script/odu9HNEb-3-Min-BO-Strategy/
- type: strategy
- pine_id: PUB;2283
- version: -1.0

## Description

Use BB50 0.2, RSI(30) , TTM Squeeze

## Source Code

````pine
//Based on Larry Connors RSI-2 Strategy - Lower RSI
strategy (title="Spyfrat Alert", shorttitle="SpyfratAlert", overlay=true, pyramiding=1999, initial_capital=60000, currency=currency.USD)

// TTM Squeeze code
lengthttm = input(title="Length", type=integer, defval=20, minval=0) 
bband(lengthttm, mult) =>
	sma(close, lengthttm) + mult * stdev(close, lengthttm)
keltner(length, mult) =>
	ema(close, lengthttm) + mult * ema(tr, lengthttm)

e1 = (highest(high, lengthttm) + lowest(low, lengthttm)) / 2 + sma(close, lengthttm)
osc = linreg(close - e1 / 2, lengthttm, 0)
diff = bband(lengthttm, 2) - keltner(lengthttm, 1)
osc_color = osc[1] < osc[0] ? osc[0] >= 0 ? #00ffff : #cc00cc : osc[0] >= 0 ? #009b9b : #ff9bff
mid_color = diff >= 0 ? green : red
conso = diff >= 0?1:0

//plot(osc, color=osc_color, style=histogram, linewidth=2)
//plot(0, color=mid_color, style=circles, linewidth=3)

// BB Init
source = close
length = input(50, minval=1)
mult = input(0.2, title="Mult Factor", minval=0.001, maxval=50)
alertLevel=input(0.1)
impulseLevel=input(0.75)
showRange = input(false, type=bool)

//RSI CODE
src = close, 
up = rma(max(change(src), 0), 30)
down = rma(-min(change(src), 0), 30)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

//BB CODE
basis = sma(source, length)
dev = mult * stdev(source, length)
upper = basis + dev
lower = basis - dev
bbr = source>upper?(((source-upper)/(upper-lower))/10): source<lower?(((source-lower)/(upper-lower))/10) : 0.05
bbi = bbr - nz(bbr[1]) 
//Rule
long = rsi>50.5 and rsi<57 and  bbi>0.10  and osc>0.00012 and conso>0
short = rsi<49.5 and rsi>40 and  bbi<-0.10 and osc<-0.00012 and conso>0

//Alert
//plot(long,"long",color=green,linewidth=1)
//plot(short,"short",color=red,linewidth=1)
strategy.entry("DOWN", strategy.short, comment="DOWN",qty=5000, when=short)
strategy.entry("UP", strategy.long, comment="UP",qty=5000, when=long)
strategy.exit(id="Stop", profit = 20, loss = 100)
````
