# niyati's with trend

- url: https://www.tradingview.com/script/aef7QVTd-niyati-s-with-trend/
- type: strategy
- pine_id: PUB;4JwbSJ0Lj0VBIMzMovid8v4eBLsjbK2Z
- version: 1.0

## Description

hhhhh

## Source Code

````pine
//@version=3
strategy("niyati's with trend", overlay=true)

width = input(2, minval=1)
xHigh  = security(tickerid,"D", high)
xLow   = security(tickerid,"D", low)
xClose = security(tickerid,"D", close)
xOpen  = security(tickerid,"D", open)
vR2 = xHigh+(xHigh - xLow)* 0.236
vS2 = xLow-(xHigh - xLow)* 0.236
vR3 = xHigh+(xHigh - xLow)* 0.382
vS3 = xLow-(xHigh - xLow)* 0.382
vR1 = xHigh+(xHigh - xLow)* 0.118
vS1 = xLow-(xHigh - xLow)* 0.118
vR4 = xHigh+(xHigh - xLow)* 0.618
vS4 = xLow-(xHigh - xLow)* 0.618
pR2 = xLow+(xHigh - xLow)* 0.236

plot(vS4, color=#ff014a, title="S4", style = circles, linewidth = width)
plot(vS3, color=#ff014a, title="S3", style = circles, linewidth = width)
plot(vS2, color=#ff002a, title="S2", style = circles, linewidth = width)
plot(vS1, color=#ff0000, title="S1", style = circles, linewidth = width)
plot(vR1, color=#009600, title="R1", style = circles, linewidth = width)
plot(vR2, color=#006F00, title="R2", style = circles, linewidth = width)
plot(vR3, color=#004900, title="R3", style = circles, linewidth = width)
plot(vR4, color=#004900, title="R4", style = circles, linewidth = width)
plot(pR2, color=#d96F00, title="P2", style = circles, linewidth = width)




len = input(5, title="Length")

ema1 = ema(xClose, len)

res = input(title="Resolution", type=resolution, defval="D")


out1 = security(tickerid, res, ema1)


plot(out1, title="ema5", style=line, linewidth=1, color = blue)

entry() => xLow > out1 and xOpen > xClose and (xHigh-xLow) < xClose*0.025 and low[1] > vS3*0.999 and low[1] < vS3*1.001 and open < close and close > vS3 and close < vS3*1.002
exit() => high > pR2 or low < vS3*0.998

strategy.entry(id = "long", long = true, when = entry())
strategy.close(id = "long", when = exit())
````
