# Simple Moving Average 10/30/40

- url: https://www.tradingview.com/script/m61ut9aR/
- type: indicator
- pine_id: PUB;09ab4af256df45858317dae91fd6b9a8
- version: 1.0

## Description

Simple Moving Average 10/30/40
Simple Moving Average 10/30/40
Simple Moving Average 10/30/40
Simple Moving Average 10/30/40

## Source Code

````pine
//@version=6
indicator(title="Simple Moving Average 10/30/40", shorttitle="SMA 10/30/40", overlay=true, timeframe="", timeframe_gaps=true)

src = input(close, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none)

sma10 = ta.sma(src, 10)
sma30 = ta.sma(src, 30)
sma40 = ta.sma(src, 40)

plot(sma10, color=color.green, title="SMA 10", offset=offset)
plot(sma30, color=color.orange, title="SMA 30", offset=offset)
plot(sma40, color=color.red, title="SMA 40", offset=offset)
````
