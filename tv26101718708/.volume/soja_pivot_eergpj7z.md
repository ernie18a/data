# SOJA PIVOT

- url: https://www.tradingview.com/script/EeRgpJ7Z/
- type: strategy
- pine_id: PUB;tFwbR92jIWnkQ3CwnOcjgZZqGCbj46HA
- version: 1.0

## Description

Strategy using SOJA HUNTER indicator for buy and Pivot points for sell :
-1st TP at R1 with 25% shares
-2nd TP at R2 with 25% shares
SL using trailing stop.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ParaBellum68

//@version=4
strategy(title="SOJA PIVOT", shorttitle="SOJA PIVOT")
soja = ((cmo(close,5) > 25) and (cmo(close,5) < 70) and (close> close[1]) and (bbw(close,50,1) < 0.6) and (sum(volume,5)> 250000) and (obv[5]>15))
TP = 2.1 * hlc3[1]- high[1]
TP2 = TP + high[1] - low[1]
SL = avg(close,14) - 3*atr(14)
strategy.entry("buy", true, 1, when = soja == 1)
strategy.close("buy", when = close > TP, qty_percent = 25)
strategy.close("buy", when = close > TP2, qty_percent = 25)
strategy.exit("stop", "exit", when = close < SL)
````
