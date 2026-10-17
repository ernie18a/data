# Average True Range PCT

- url: https://www.tradingview.com/script/jhrnD6KA-Average-True-Range-PCT/
- type: indicator
- pine_id: PUB;bc9a4ccf296843e48352e200fed9e49b
- version: 1.0

## Description

This script calculates the percentage value of closing price occupied by ATR value

## Source Code

````pine
//@version=6
indicator(title="Average True Range PCT", shorttitle="ATR%", overlay=false, timeframe="", timeframe_gaps=true)
length = input.int(title="Length", defval=14, minval=1)
src = input(close, title="Source")
smoothing = input.string(title="Smoothing", defval="RMA", options=["RMA", "SMA", "EMA", "WMA"])
ma_function(source, length) =>
	switch smoothing
		"RMA" => ta.rma(source, length)
		"SMA" => ta.sma(source, length)
		"EMA" => ta.ema(source, length)
		=> ta.wma(source, length)

atrs = ta.tr(true)
values = 100.0 * atrs / src
plot(ma_function(values, length), title = "ATR%", color=color.new(#B71C1C, 0))
````
