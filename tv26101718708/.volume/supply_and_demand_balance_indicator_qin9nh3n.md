# Supply and Demand Balance Indicator

- url: https://www.tradingview.com/script/qIN9Nh3n/
- type: indicator
- pine_id: PUB;9e5555d12e7f4ba483809a788f87b770
- version: 1.0

## Description

Supply and Demand Balance Indicator

The Supply and Demand Balance Indicator measures market pressure by comparing the moving averages of buying volume and selling volume.

The indicator classifies each candle as either bullish or bearish:

・Bullish candle (Close > Open): Volume is counted as buying volume.
・Bearish candle (Close < Open): Volume is counted as selling volume.

A moving average is then calculated separately for buying and selling volume. The difference between these two averages is plotted as a column chart around the zero line.

Interpretation
・Green bars above zero: Buying pressure is dominant.
・Red bars below zero: Selling pressure is dominant.
・Increasing positive values: Demand is strengthening.
・Increasing negative values: Supply is strengthening.

This indicator can be used to:

・Identify shifts in market sentiment.
・Confirm trend direction.
・Detect potential trend reversals.
・Filter entries for trend-following strategies.

The indicator is intentionally simple and can be combined with moving averages, momentum indicators, or price action analysis.

How to Use

This indicator is designed to be used together with the Supply & Demand Volume Indicator.

Supply & Demand Volume Indicator
・Green line above the red line: Buying pressure is dominant.
・Red line above the green line: Selling pressure is dominant.

Supply/Demand Balance
Green bars above zero: Buying pressure is increasing.
Red bars below zero: Selling pressure is increasing.

Example Usage
Bullish Conditions
1.The Buying Volume MA (green line) is above the Selling Volume MA (red line).
2.The Supply/Demand Balance turns positive and prints green bars.

This combination may indicate strengthening demand and a potential upward trend.

Bearish Conditions
1.The Selling Volume MA (red line) is above the Buying Volume MA (green line).
2.The Supply/Demand Balance turns negative and prints red bars.

This combination may indicate increasing supply and a potential downward trend.

Notes

These indicators are intended to measure market participation and volume pressure. They work best when combined with trend-following tools, moving averages, or price action analysis.

## Source Code

````pine
//@version=6
indicator("Supply and Demand Balance Indicator", shorttitle="Supply/Demand Balance", overlay=false)

// Determine candle direction
isBullish = close > open
isBearish = close < open

// Calculate buying and selling volume
buyVolume = isBullish ? volume : 0.0
sellVolume = isBearish ? volume : 0.0

// Input
length = input.int(14, "Volume MA Length", minval=1)

// Moving averages
buyVolMA = ta.sma(buyVolume, length)
sellVolMA = ta.sma(sellVolume, length)

// Supply/Demand Balance
volumeDiff = buyVolMA - sellVolMA

// Colors
barColor = volumeDiff >= 0 ? color.green : color.red

// Zero line
hline(0, "Zero Line", color=color.gray)

// Column chart
plot(
     volumeDiff,
     title="Supply/Demand Balance",
     style=plot.style_columns,
     color=barColor
)

// Background
bgcolor(
     volumeDiff > 0
     ? color.new(color.green, 85)
     : color.new(color.red, 85),
     title="Balance Background"
)
````
