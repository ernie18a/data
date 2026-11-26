# MACD Positive & Price Above VWAP Indicator & Volume Above MA

- url: https://www.tradingview.com/script/64B0vrSt-MACD-Positive-Price-Above-VWAP-Indicator-Volume-Above-MA/
- type: indicator
- pine_id: PUB;bd851b5dcd1b41acb65a183a6bdb882f
- version: 1.0

## Description

This strategy provides a buy signal with a green arrow pointing up when four conditions are met. The MACD has to be above the signal line. The settings for MACD can be adjusted, but the default is the standard settings for MACD. The second condition is the price has to be above the VWAP line. The third condition is that the price of the current candle needs to be higher than the HIGH price of the previous candle. The last condition is that the volume has to be higher than the MA of volume.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © R39813

//@version=5
indicator("MACD Positive & Price Above VWAP Indicator", overlay=true)

// === 1. Calculate Indicators ===
// VWAP (main price chart)
vwapValue = ta.vwap(close)

// MACD (12, 26, 9) — separate pane
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)

// Volume Moving Average (50 periods)
volumeMA = ta.sma(volume, 50)

// === 2. Define Entry Conditions ===
// MACD line above Signal line
macd_is_positive = macdLine > signalLine

// Price above VWAP
price_above_vwap = close > vwapValue

// High above previous high
higher_than_prev_high = close > high[1]

// Volume above 50-period volume MA
volume_above_avg = volume > volumeMA

// Combined entry condition
entryCondition = macd_is_positive and price_above_vwap and higher_than_prev_high and higher_than_prev_high and volume_above_avg

// === 3. Plot VWAP and Entry Signals on Price Chart ===
plot(vwapValue, "VWAP", color=color.blue, linewidth=2)

plotshape(
     entryCondition,
     title="Entry Signal",
     location=location.belowbar,
     color=color.green,
     style=shape.triangleup,
     size=size.small)

// === 4. Plot MACD + Signal + Histogram in a Separate Pane ===
//plot(macdLine, "MACD Line", color=#2962FF)
//plot(signalLine, "Signal Line", color=#FF6D00)
//hline(0, "Zero Line", color=color.gray)

// Optional: MACD histogram
//plot(hist, "MACD Histogram", style=plot.style_columns,
//     color = hist >= 0 ? color.new(color.green, 0) : color.new(color.red, 0))
````
