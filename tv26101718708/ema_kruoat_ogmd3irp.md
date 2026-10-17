# EMA kruOat

- url: https://www.tradingview.com/script/oGmd3irP-EMA-kruOat/
- type: indicator
- pine_id: PUB;990870b51b154402b452c1c207e257a2
- version: 1.0

## Description

EMA 14/100/200 + LWMA 720 HLCC/4

This indicator displays key moving averages on the price chart to help identify market trends and important price zones.

It includes:
- EMA 14 for short-term trend analysis
- LWMA 720 calculated from HLCC/4 for the main weighted trend
- EMA 100 for medium-term trend analysis
- EMA 200 for long-term trend analysis

The LWMA 720 uses Weighted Close, also known as HLCC/4, calculated as:

(High + Low + Close + Close) / 4

This helps give more weight to the closing price while smoothing the overall trend with a Linear Weighted Moving Average.

Suitable for analyzing trend direction, support and resistance zones, potential reversal areas, and trade planning across multiple timeframes.

## Source Code

````pine
//@version=6
indicator("EMA 14/100/200 + LWMA 720 HLCC4", overlay=true)

weightedClose = (high + low + close + close) / 4

ema14   = ta.ema(close, 14)
lwma720 = ta.wma(weightedClose, 720)
ema100  = ta.ema(close, 100)
ema200  = ta.ema(close, 200)

plot(ema14,   color=color.yellow, title="EMA 14")
plot(lwma720, color=color.white,  title="LWMA 720 HLCC/4")
plot(ema100,  color=color.blue,   title="EMA 100")
plot(ema200,  color=color.green,  title="EMA 200")
````
