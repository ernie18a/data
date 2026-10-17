# ATR with Percentage

- url: https://www.tradingview.com/script/l4QDZCby-ATR-with-Percentage/
- type: indicator
- pine_id: PUB;d898e2b5a3e142d9a575cd560e039503
- version: 1.0

## Description

Same ATR (Average True Rang) with additional % near the label useful to identify volatile tickers

## Source Code

````pine
//@version=5
indicator(title="ATR with Percentage", shorttitle="ATR %", overlay=false)

// --- Inputs ---
length    = input.int(title="Length", defval=14, minval=1)
smoothing = input.string(title="Smoothing", defval="RMA", options=["RMA", "SMA", "EMA", "WMA"])

// --- Calculations ---
ma_function(source, length) =>
    switch smoothing
        "RMA" => ta.rma(source, length)
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        => ta.wma(source, length)

// Standard ATR Value
atrValue = ma_function(ta.tr(true), length)

// ATR as a Percentage of Price
// Formula: (ATR / Current Price) * 100
atrPercent = (atrValue / close) * 100

// --- Plotting ---
// Plotting the standard ATR line
plot(atrValue, title="ATR Value", color=color.new(#B71C1C, 0), linewidth=2)

// Plotting the Percentage as a hidden value so it shows in the legend/data window
plot(atrPercent, title="ATR %", color=color.new(color.blue, 100), display=display.all)

// Optional: Add a label or use the 'format' parameter in the plot if you only want %
// But since you asked for both near the pips, the legend will now show:
// ATR Value: [X]  ATR %: [Y]
````
