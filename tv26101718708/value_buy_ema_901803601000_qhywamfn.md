# Value Buy- EMA 90/180/360/1000

- url: https://www.tradingview.com/script/QHYWAmFN-Value-Buy-EMA-90-180-360-1000/
- type: indicator
- pine_id: PUB;db0845825ffa4c0c9579270f5a73a46c
- version: 1.0

## Description

Higher timeframes for EMA. Usually opted to check bigger picture
EMA 90/180/360/1000

## Source Code

````pine
//@version=6
indicator(title="Value Buy Indicator- EMA 90/180/360/1000", overlay=true)

shortest = ta.ema(close, 90)
short = ta.ema(close, 180)
longer = ta.ema(close, 360)
longest = ta.ema(close, 1000)

plot(shortest, color = color.red)
plot(short, color = color.orange)
plot(longer, color = color.aqua)
plot(longest, color = color.blue)
````
