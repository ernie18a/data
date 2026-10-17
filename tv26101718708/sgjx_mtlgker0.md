# SGJX

- url: https://www.tradingview.com/script/mTLgkeR0/
- type: indicator
- pine_id: PUB;62a0d2450a5a4fb5aed120eff6dea3c8
- version: 1.0

## Description

均线

## Source Code

````pine
//@version=6
indicator(title="Smoothed Moving Average", shorttitle="SMMA", overlay=true, timeframe="", timeframe_gaps=true)
len = input.int(7, minval=1, title="Length")
src = input(close, title="Source")
smma = 0.0
smma := na(smma[1]) ? ta.sma(src, len) : (smma[1] * (len - 1) + src) / len
plot(smma, "SMMA", color = #673AB7)
````
