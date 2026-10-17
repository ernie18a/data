# Multiple Moving Averages

- url: https://www.tradingview.com/script/p3FMw0zs/
- type: indicator
- pine_id: PUB;34a35dac7335456c8c7e88a62142525b
- version: 1.0

## Description

This indicator overlays four popular moving averages on your chart:  

EMA 62 (short-term trend)  
EMA 144 (medium-term trend)  
SMA 200 (long-term trend, widely watched)  
SMA 800 (very long-term trend)Use them to identify trend direction, dynamic support/resistance, and potential reversal zones.

## Source Code

````pine
//@version=6
indicator("Multiple Moving Averages", shorttitle="Multiple MAs", overlay=true)

// Calculate moving averages
ema62  = ta.ema(close, 62)
ema144 = ta.ema(close, 144)
sma200 = ta.sma(close, 200)
sma800 = ta.sma(close, 800)

// Plot moving averages
plot(ema62,  color=color.red,    title="EMA 62")
plot(ema144, color=color.orange, title="EMA 144")
plot(sma200, color=color.blue,   title="SMA 200")
plot(sma800, color=color.black,  title="SMA 800")
````
