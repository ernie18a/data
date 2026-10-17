# RSI Crossover 8rookz

- url: https://www.tradingview.com/script/qGMLR2aY-RSI-Crossover-8rookz/
- type: strategy
- pine_id: PUB;H0ubgrCGkzD6bS196OSCQYOFW5Ms7AcH
- version: 1.0

## Description

RSI using 2 different time frames

## Source Code

````pine
//@version=3


//use overlay=false to create plot below chart, overlay=true will intergrate it
strategy("RSI Crossover 8rookz", overlay=false)
length = input( 13 )
lengthfast = input( 5 )

price = close

vrsi = rsi(price, length)
vrsiFast = rsi(price, lengthfast)

plot(vrsi, color=purple)
plot(vrsiFast, color=green)
````
