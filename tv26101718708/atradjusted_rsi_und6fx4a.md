# ATR-Adjusted RSI

- url: https://www.tradingview.com/script/Und6fX4A-ATR-Adjusted-RSI/
- type: indicator
- pine_id: PUB;11dbde2b8d884d70bc52d93471736ba9
- version: 1.0

## Description

This indicator adjusts the RSI values using the Average True Range. It is used the same way as a normal RSI.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sofien-Kaabar

//@version=5
indicator("ATR-Adjusted RSI")

rsi = ta.rsi(close, 14)
atr = ta.atr(14)

rsi_atr = rsi / atr

rsi_atr_indicator = ta.rsi(rsi_atr, 14)

plot(rsi_atr_indicator, color = (rsi_atr_indicator > rsi_atr_indicator[1]) ? color.green : color.red)
hline(70)
hline(30)
````
