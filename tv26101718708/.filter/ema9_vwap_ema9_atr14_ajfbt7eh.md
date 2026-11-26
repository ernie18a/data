# EMA9 + VWAP + EMA9 - ATR14

- url: https://www.tradingview.com/script/ajFbt7EH/
- type: indicator
- pine_id: PUB;1f2cf57ba5e64859b012f450bce4d6cc
- version: 1.0

## Description

A combination of 3 displayed indicators:
EMA(9)
VWAP
EMA(9) minus 1 x ATR(14)
To display all relevant data for the ‘VWAP Reclaim’ trading strategy

## Source Code

````pine
//@version=6
indicator("EMA9 + VWAP + EMA9 - ATR14", overlay=true)

// Einstellungen
emaLen = input.int(9, "EMA Länge")
atrLen = input.int(14, "ATR Länge")
atrMult = input.float(1.0, "ATR Multiplikator", step=0.1)

// Berechnungen
ema9 = ta.ema(close, emaLen)
vwapLine = ta.vwap(hlc3)
atr14 = ta.atr(atrLen)

emaMinusAtr = ema9 - atrMult * atr14

// Linien im Chart
plot(ema9, title="EMA 9", color=color.orange, linewidth=2)
plot(vwapLine, title="VWAP", color=color.blue, linewidth=2)
plot(emaMinusAtr, title="EMA 9 minus 1x ATR 14", color=color.red, linewidth=2)
````
