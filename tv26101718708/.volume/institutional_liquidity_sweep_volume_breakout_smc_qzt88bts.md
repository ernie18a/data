# Institutional Liquidity Sweep & Volume Breakout [SMC]

- url: https://www.tradingview.com/script/QzT88bTs-Institutional-Liquidity-Sweep-Volume-Breakout-SMC/
- type: indicator
- pine_id: PUB;b9372355c2e6483f952ca49a21d2ebbb
- version: 1.0

## Description

Hello Traders,
This open-source Pine Script (v5) indicator is designed to identify institutional "Liquidity Sweeps" or "Stop Hunts" based on Smart Money Concepts (SMC). 

In financial markets, institutional algorithms frequently push prices past recent short-term swing highs or lows to trigger retail stop-losses and engineering liquidity before driving the market in the actual intended direction. This tool helps traders detect those exact institutional reversal points in real-time.

1. *Dynamic Swing Analysis:* The script tracks the highest high and lowest low of a user-defined lookback period (default is 20 bars) to establish key liquidity zones.
2. *Liquidity Sweep Detection:* A potential signal occurs when the price pierces through these key swing levels but fails to sustain the breakout, closing back inside the range. This indicates a clear fakeout or liquidity grab.
3. *Volume Filter Confirmation:* To filter out weak and false signals, a sweep is only validated if the breaking candle carries significantly higher volume than the 20-period moving average volume. High volume confirms institutional participation.

 How to Trade with This Indicator:

-Bullish Sweep (Green Triangle & Label)NOccurs when the price sweeps a major swing low on high volume and closes back above it. This is a high-probability signal to look for long setups or exit short positions, especially on lower timeframes like the 5-minute or 15-minute charts for Gold (XAUUSD) and major USD currency pairs.
Bearish Sweep (Red Triangle & Label) Occurs when the price sweeps a major swing high on high volume and closes back below it. This indicates institutional selling pressure and serves as a signal to look for short entries.


 Customizable Settings
Swing Lookback Period  Adjust the number of historical bars to find stronger or tighter swing structures.
 Volume Multiplier: Customize how many times higher the volume must be compared to its average to trigger a valid sweep.
Show Labels:* Toggle chart labels on or off for a cleaner interface.

*Disclaimer:* No indicator works 100% of the time. Always practice strict risk management. For best results, use these signals in confluence with higher timeframe market structure, order blocks, or major macroeconomic trends.

## Source Code

````pine
//@version=6
indicator("Institutional Liquidity Sweep & Volume Breakout [SMC]", overlay=true, max_labels_count=500)

// ---- INPUTS ----
lookbackPeriod   = input.int(20, title="Swing Lookback Period", minval=5)
volumeMultiplier = input.float(1.5, title="Volume Multiplier", minval=1.0)
showLabels       = input.bool(true, title="Show Buy/Sell Labels")

// ---- SWING HIGH / LOW CALCULATIONS ----
highestHigh = ta.highest(high[1], lookbackPeriod)
lowestLow   = ta.lowest(low[1], lookbackPeriod)

// ---- VOLUME CONFIRMATION ----
avgVolume    = ta.sma(volume, 20)
isHighVolume = volume > (avgVolume * volumeMultiplier)

// ---- LIQUIDITY SWEEP LOGIC ----
bearishSweep = (high > highestHigh) and (close < highestHigh) and isHighVolume
bullishSweep = (low < lowestLow) and (close > lowestLow) and isHighVolume

// ---- PLOT SWING LINES ON CHART ----
var line hiLine = na
var line loLine = na

// v6 Fix: Checking change explicitly using ta.change() != 0 or math.abs
hasHiChanged = not na(ta.change(highestHigh)) and ta.change(highestHigh) != 0
hasLoChanged = not na(ta.change(lowestLow)) and ta.change(lowestLow) != 0

if hasHiChanged or barstate.isfirst
    hiLine := line.new(bar_index - lookbackPeriod, highestHigh, bar_index, highestHigh, color=color.red, style=line.style_dashed, width=1)
else
    line.set_x2(hiLine, bar_index)

if hasLoChanged or barstate.isfirst
    loLine := line.new(bar_index - lookbackPeriod, lowestLow, bar_index, lowestLow, color=color.green, style=line.style_dashed, width=1)
else
    line.set_x2(loLine, bar_index)

// ---- PLOT SHAPES AND LABELS ----
plotshape(bullishSweep, title="Bullish Sweep Shape", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(bearishSweep, title="Bearish Sweep Shape", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

if bullishSweep and showLabels
    label.new(bar_index, low, text="BULLISH SWEEP", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)

if bearishSweep and showLabels
    label.new(bar_index, high, text="BEARISH SWEEP", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)
````
