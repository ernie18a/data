# DMI Wilder 10

- url: https://www.tradingview.com/script/pqHqTzLq-DMI-Wilder-10/
- type: indicator
- pine_id: PUB;4dc09c4eeb284ef3873445d949305a4a
- version: 1.0

## Description

DMI average type is wider , exponential to tell the moving direction 
DMI average type is wider , exponential to tell the moving direction

## Source Code

````pine
//@version=6
indicator("DMI Wilder 10", overlay=false)

len = 10

upMove = high - high[1]
downMove = low[1] - low

plusDM = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

tr = ta.rma(ta.tr(true), len)

plusDI = 100 * ta.rma(plusDM, len) / tr
minusDI = 100 * ta.rma(minusDM, len) / tr

dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, len)

plot(plusDI, color=color.green)
plot(minusDI, color=color.red)
plot(adx, color=color.white)
````
