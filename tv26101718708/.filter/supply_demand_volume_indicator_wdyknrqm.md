# Supply & Demand Volume Indicator

- url: https://www.tradingview.com/script/WdykNrqM/
- type: indicator
- pine_id: PUB;32226ee3ba2d4f74884cb72957afefe5
- version: 1.0

## Description

Supply & Demand Volume Indicator

The Supply & Demand Volume Indicator is designed to measure buying and selling pressure using trading volume.

The indicator classifies volume from bullish candles as buying volume and volume from bearish candles as selling volume. It then calculates moving averages for both values, allowing traders to compare the relative strength of buyers and sellers over time.

When the Buying Volume Moving Average rises above the Selling Volume Moving Average, it suggests that demand is increasing and buyers are becoming more active.

Conversely, when the Selling Volume Moving Average exceeds the Buying Volume Moving Average, it suggests that supply is increasing and sellers are gaining control of the market.

The background color provides a quick visual representation of the current supply and demand balance:

• Green Background – Buying pressure dominates
• Red Background – Selling pressure dominates

 Features

* Buying Volume Moving Average
* Selling Volume Moving Average
* Adjustable Moving Average Length
* Visual Supply & Demand Balance
* Non-Repainting Calculation
* Easy-to-Read Subwindow Display

 Suggested Uses

* Trend confirmation
* Market participation analysis
* Volume flow monitoring
* Identifying shifts in buying and selling pressure
* Confirmation tool for trend-following and momentum strategies

 Disclaimer

This indicator is intended as a market analysis tool and does not provide direct buy or sell signals. It is best used alongside other technical analysis methods and risk management techniques.

## Source Code

````pine
//@version=6
indicator("Supply & Demand Volume Indicator", overlay=false)

// Moving Average Length
maLength = input.int(14, minval=1, title="Moving Average Length")

// Candle Direction
isUp = close > open
isDown = close < open

// Buying and Selling Volume
buyVolume = isUp ? volume : 0
sellVolume = isDown ? volume : 0

// Moving Averages
buyVolMA = ta.sma(buyVolume, maLength)
sellVolMA = ta.sma(sellVolume, maLength)

// Plots
plot(buyVolMA, color=color.green, linewidth=2, title="Buying Volume MA")
plot(sellVolMA, color=color.red, linewidth=2, title="Selling Volume MA")

// Supply & Demand Balance Background
bgcolor(
     buyVolMA > sellVolMA
     ? color.new(color.green, 85)
     : color.new(color.red, 85),
     title="Supply & Demand Balance"
)
````
