# LowHigh Archit Gupta

- url: https://www.tradingview.com/script/GrNWoMYc-LowHigh-Archit-Gupta/
- type: indicator
- pine_id: PUB;1c6c67a04a49440eac72d7c402e9f9f6
- version: 1.0

## Description

It Fetch out the price by x% of high or low of specific candle

## Source Code

````pine
//@version=6
indicator("LowHigh", overlay=true)

highPlus1 = high * 1.01
lowMinus1 = low * 0.99

highPlus05 = high * 1.0045
lowMinus05 = low * 0.9955

plot(highPlus05, title="LowHigh", color=color.green)
plot(lowMinus05, title="LowHigh", color=color.red)
````
