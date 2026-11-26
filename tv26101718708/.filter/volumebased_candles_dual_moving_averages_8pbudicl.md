# Volume-Based Candles & Dual Moving Averages

- url: https://www.tradingview.com/script/8pbuDicL/
- type: indicator
- pine_id: PUB;e3a1095a820246b2bcd0fd2239c36f93
- version: 1.0

## Description

Dual Moving Averages (MA): The script plots two moving averages. You can customize the length and type (SMA, EMA, VWMA, etc.) for each via the settings menu. These serve as your primary trend filters.

Volume-Based Candle Coloring: Unlike standard charts where candles are simply Green (up) or Red (down), this script changes the intensity of the color based on whether the current volume is higher or lower than the previous candle.

Trend Direction: If the price is trading above the MAs, the bias is bullish. If below, it is bearish.

Crossovers: A "Golden Cross" (faster MA crossing above slower MA) often signals a trend reversal to the upside, while a "Death Cross" (faster crossing below) signals a potential shift to the downside.

## Source Code

````pine
//@version=6
indicator("Volume-Based Candles & Dual Moving Averages", overlay=true)

// --- MA 1 Inputs ---
len1 = input.int(20, title="Length 1", group="Moving Average 1")
src1 = input.source(close, title="Source 1", group="Moving Average 1")
type1 = input.string("SMA", title="Type 1", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA"], group="Moving Average 1")

// --- MA 2 Inputs ---
len2 = input.int(50, title="Length 2", group="Moving Average 2")
src2 = input.source(close, title="Source 2", group="Moving Average 2")
type2 = input.string("EMA", title="Type 2", options=["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA"], group="Moving Average 2")

// --- Calculation Function ---
calcMA(type, src, len) =>
    switch type
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        "RMA"  => ta.rma(src, len)
        "HMA"  => ta.hma(src, len)
        => ta.sma(src, len)

ma1 = calcMA(type1, src1, len1)
ma2 = calcMA(type2, src2, len2)

// --- Candle Color Logic ---
volIncreasing = volume > volume[1]

candleColor = close >= open ? 
     (volIncreasing ? color.new(color.lime, 0) : color.new(color.green, 50)) : 
     (volIncreasing ? color.new(color.red, 0) : color.new(color.maroon, 50))

// --- Plotting ---
plot(ma1, title="MA 1", color=color.blue, linewidth=2)
plot(ma2, title="MA 2", color=color.orange, linewidth=2)
barcolor(candleColor)
````
