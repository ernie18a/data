<!-- tradingview-pine-id: PUB;554e8e2eb693446ca549e031a826a635 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Log

Source: https://www.tradingview.com/script/eBf2ArYG-ATR-Log/

## Description

This ATR represent price movement in percentage term in logarithimic scale. 

Example - A stock was 100 USD 5 years back. it moved 3 USD on a certain day during that period. ATR of that stock on that day was 3%. Today that stock moved 3 USD but the value of that stock is 300 USD. ATR of that stock today is 1%.

If we plot this ATR, we can see how stock price movement expanded or compressed over a period of time. It gives a edge over normal ATR to judge historical dryness or fluidity in price movement

---

## Source Code

````pine
//@version=6
indicator(title="ATR Log", shorttitle="ATRLOG", overlay=false, timeframe="", timeframe_gaps=true)
length = input.int(title="Length", defval=11, minval=1)
smoothing = input.string(title="Smoothing", defval="RMA", options=["RMA", "SMA", "EMA", "WMA"])
ma_function(source, length) =>
	switch smoothing
		"RMA" => ta.rma(source, length)
		"SMA" => ta.sma(source, length)
		"EMA" => ta.ema(source, length)
		=> ta.wma(source, length)
plot(ma_function(((ta.tr(true)/close)*100), length), title = "ATRLOG", color=color.new(#B71C1C, 0))
````
