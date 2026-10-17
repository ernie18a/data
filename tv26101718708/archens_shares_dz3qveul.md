# ARCHENS SHARES

- url: https://www.tradingview.com/script/dZ3qveUl-ARCHENS-SHARES/
- type: strategy
- pine_id: PUB;d4c7216bb32a44558f69d1d4d189fbaa
- version: 1.0

## Description

This script marks the high and low of 9.45 to 10.15 price. When the price breaks high, then gives Buy signal. When the price breaks low, then it gives Sell Signal. These buy and sell signals are given with labels "ARCHENS BUY" or "ARCHENS SELL". With my observation in stock market, I have made this strategy.

This strategy works in normal candle pattern but i observed that it works well in heikenashi candle. For this strategy to work well, we have to select 5 mins heikenashi candles. 

If this strategy gives "ARCHENS buy", then buy it. Target should be as per individuals mind. But Stop loss should be hitted when there are two continue opposite {red} heikenashi candle.

If this strategy gives "ARCHENS sell", then sell it. Target should be as per individuals mind. But Stop loss should be hitted when there are two continue opposite {green} heikenashi candle.

## Source Code

````pine
// Copyright (c) 2019-present
//@version=5
strategy("ARCHENS SHARES", overlay=true)

timeframe = input.timeframe(defval = "30", title = "timeframe")
session = input.session(defval="0945-1015", title = "session")
tradein = time(timeframe, session)

half_high = request.security(syminfo.tickerid, "30", high)
half_low = request.security(syminfo.tickerid, "30", low)

HH = ta.valuewhen(tradein, half_high, 0 )
HL = ta.valuewhen(tradein, half_low, 0 )

buy = ta.crossover(close,HH)
sell = ta.crossunder(close,HL)

// Reset strategy at the start of each day
if dayofweek != dayofweek[1]
    buy := false
    sell := false

plot(HH, style=plot.style_circles, color = color.orange, linewidth = 2)
plot(HL, style=plot.style_circles, color = color.orange, linewidth = 2)

strategy.entry("long", direction = strategy.long, when = buy, comment = "ARCHENS BUY")
strategy.entry("short", direction = strategy.short, when = sell, comment = "ARCHENS SELL")
````
