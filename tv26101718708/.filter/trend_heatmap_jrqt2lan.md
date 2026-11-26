# Trend Heatmap

- url: https://www.tradingview.com/script/jrQT2LaN-Trend-Heatmap/
- type: indicator
- pine_id: PUB;d9f9b1d629a24b4884c3a55fc7c70eab
- version: 1.0

## Description

"Trend Heatmap," is a custom technical indicator designed to measure and visualize the strength and direction of market trends by combining price action with volume data.

Instead of relying on a single moving average or momentum oscillator, it creates a custom "heatmap" value that attempts to quantify whether buying or selling pressure is currently dominant.

The script does not plot directly on your main price chart; it appears in a separate pane below the chart.

This indicator is designed to help traders identify trend exhaustion or shifts in momentum. Because it incorporates volume, it is intended to help filter out "fakeouts"—price moves that occur on low volume and are often less sustainable.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator(title = 'Trend Heatmap', overlay = false)

// Made Dy Vitaliy. Version 1.0.4

// Calculations
calculations = close == high and close == low or high == low ? 0 : (2 * close - low - high) / (high - low) * volume
trendstrength = math.sum(calculations, 1) / math.sum(volume, 1)
toptrend = math.sum(volume * (ta.change(ohlc4) <= 0 ? 0 : ohlc4), 8)
lowertrend = math.sum(volume * (ta.change(ohlc4) >= 0 ? 0 : ohlc4), 8)

paramaters(upper, lower) =>
    if lower == 0
        100
    if upper == 0
        0
    100.0 - 100.0 / (1.0 + toptrend / lowertrend)

trendline = paramaters(toptrend, lowertrend)

calculations2 = close == high and close == low or high == low ? 0 : (2 * close - low - high) / (high - low) * volume
trendstrength2 = math.sum(calculations2, 1) / math.sum(volume, 1)
toptrend2 = math.sum(volume * (ta.change(close) <= 0 ? 0 : close), 20)
lowertrend2 = math.sum(volume * (ta.change(close) >= 0 ? 0 : close), 20)

paramaters2(upper2, lower2) =>
    if lower2 == 0
        100
    if upper2 == 0
        0
    100.0 - 100.0 / (1.0 + toptrend2 / lowertrend2)

trendline2 = paramaters2(toptrend2, lowertrend2)

// Final Combined Indicator
combinedTrend = trendline + trendstrength / trendline2 + trendstrength2

// Heat Map Logic: Define colors based on level
// 0 (Green/Bullish) -> 50 (Neutral) -> 100 (Red/Bearish)
heatmapColor = color.from_gradient(combinedTrend, 30, 80, color.green, color.red)

// Plotting
plot(combinedTrend, 'Trend', color = color.new(heatmapColor, 0), linewidth = 3)

// Static Hlines for reference
hline(100, title = 'Max', color = color.gray, linestyle = hline.style_dotted)
hline(50, title = 'Mid', color = color.gray, linestyle = hline.style_dotted)
hline(0, title = 'Min', color = color.gray, linestyle = hline.style_dotted)
````
