# Moving Average Exponential, easy setup

- url: https://www.tradingview.com/script/Ha9XmxLD-Moving-Average-Exponential-easy-setup/
- type: indicator
- pine_id: PUB;c0e6bb1bc91f42519dfb071fe9e37bf5
- version: 1.0

## Description

A simple moving average script with coloured background inbetween the moving averages.

## Source Code

````pine
//@version=5
indicator(title="Moving Average Exponential", shorttitle="EMA", overlay=true, timeframe="", timeframe_gaps=true)

// EMA 20
len20 = input.int(21, minval=1, title="Length EMA A")
src20 = input(close, title="Source EMA A")
out20 = ta.ema(src20, len20)
plot20 = plot(out20, title="EMA A", color=#bf616a)

// EMA 10
len10 = input.int(13, minval=1, title="Length EMA B")
src10 = input(close, title="Source EMA B")
out10 = ta.ema(src10, len10)
plot10 = plot(out10, title="EMA B", color=#a3be8c)

// Determine conditional fill color
fillColor = out10 > out20 ? color.rgb(163, 190, 140, 55) : out10 < out20 ? color.rgb(191, 97, 106, 55) : na

// Apply the fill once
fill(plot10, plot20, color=fillColor)

ma(source, length, type) =>
    switch type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

typeMA = input.string(title = "Method", defval = "SMA", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="Smoothing")
````
