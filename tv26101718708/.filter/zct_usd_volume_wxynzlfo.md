# ZCT USD Volume

- url: https://www.tradingview.com/script/WxynzLFO-ZCT-USD-Volume/
- type: indicator
- pine_id: PUB;46b01d9f48ec4b36a43bb8db15a54fe7
- version: 1.0

## Description

Volume indicator showing volume in USD.

unlike other volume indicators, this displays volume in USD so you can scan for the dollar amount needed. Whether this be a minimum volume threshold, fast spikes, or any other trends in volume you're looking for.

## Source Code

````pine

//@version=6
indicator("USD Volume", shorttitle="USD Vol", format=format.volume, overlay=false)

maLength = input.int(20, title="MA Length", minval=1)

usdVolume = volume * close

bullish = close >= open
barColor = bullish ? color.new(color.teal, 20) : color.new(color.red, 20)

plot(usdVolume, style=plot.style_columns, color=barColor, title="USD Volume")
plot(ta.sma(usdVolume, maLength), color=color.yellow, linewidth=2, title="Volume MA")
````
