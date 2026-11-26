# Market Strategies - Strat Volume Bars

- url: https://www.tradingview.com/script/h2NJnHCQ-Market-Strategies-Strat-Volume-Bars/
- type: indicator
- pine_id: PUB;6522d7fd7d914593892c85de3811a05c
- version: 2.0

## Description

# Market Strategies – Strat Volume Bars

## Overview

Market Strategies – Strat Volume Bars brings The Strat directly into your volume analysis by color-coding every volume bar based on the candle's Strat classification.

Instead of viewing volume as a standalone metric, this indicator allows traders to instantly identify whether volume is occurring on an Inside Bar (1), Directional Up Bar (2U), Directional Down Bar (2D), or Outside Bar (3).

This provides a deeper layer of context by combining price action structure with volume participation.

---

## Strat Volume Classifications

### 🟨 Yellow Volume Bar – Inside Bar (1)

An Inside Bar occurs when the current candle remains completely inside the range of the previous candle.

**Interpretation:**

* Market compression
* Indecision
* Energy building
* Potential setup candle before expansion

High volume on an Inside Bar can indicate absorption or accumulation before a larger move develops.

---

### 🟩 Green Volume Bar – 2 Up

A 2 Up candle takes out the previous candle's high without taking out the previous candle's low.

**Interpretation:**

* Bullish directional movement
* Buyers in control
* Expansion to the upside

When accompanied by volume above the average volume line, it may signal strong participation behind the move.

---

### 🟥 Red Volume Bar – 2 Down

A 2 Down candle takes out the previous candle's low without taking out the previous candle's high.

**Interpretation:**

* Bearish directional movement
* Sellers in control
* Expansion to the downside

Higher-than-average volume on a 2 Down often suggests increased selling pressure.

---

### 🟪 Fuchsia Volume Bar – Outside Bar (3)

An Outside Bar takes out both the previous candle's high and low.

**Interpretation:**

* Volatility expansion
* Aggressive participation from both buyers and sellers
* Potential reversal or continuation

Large-volume Outside Bars often represent important decision points in the market.

---

## Average Volume Line

The indicator includes an optional moving average volume line to help identify abnormal participation.

### Volume Above Average

* Increased market interest
* Greater conviction
* Potential trend continuation

### Volume Below Average

* Reduced participation
* Lower conviction
* Higher probability of chop or failed moves

---

## How to Use

### Bullish Conditions

Look for:

* Green (2 Up) volume bars
* Volume above average
* Breaks of important market structure
* Alignment with higher timeframe direction

### Bearish Conditions

Look for:

* Red (2 Down) volume bars
* Volume above average
* Breaks below support or key levels
* Alignment with higher timeframe direction

### Compression Setups

Look for:

* Yellow (Inside Bar) volume bars
* Tight consolidation
* Followed by a directional 2 Up or 2 Down break

### Volatility Events

Look for:

* Fuchsia (Outside Bar) volume bars
* Significant volume spikes
* Confirmation from the next candle

---

## Key Benefits

✔ Instantly identify Strat candle types through volume

✔ Quickly spot volume-supported directional moves

✔ Easily distinguish compression from expansion

✔ Helps validate breakouts and breakdowns

✔ Works across all markets and timeframes

✔ Complements The Strat methodology without cluttering the chart

---

## Disclaimer

This indicator is designed as a market structure and volume visualization tool. It should be used alongside proper risk management, market context, and confirmation techniques. No indicator should be used as a standalone trading system.

## Source Code

````pine
//@version=6
indicator("Market Strategies - Strat Volume Bars + Aggression", overlay=false)

// Inputs
showAvgVol = input.bool(true, "Show Average Volume")
avgLength = input.int(20, "Average Volume Length", minval=1)
showAggression = input.bool(true, "Show Aggression")
showLabels = input.bool(true, "Show Aggression Labels")
volumeMultiplier = input.float(1.20, "Aggression Volume vs Average", minval=0.10, step=0.05)
closeThreshold = input.float(70.0, "Close Position Threshold (%)", minval=50.0, maxval=100.0, step=1.0)
bodyThreshold = input.float(50.0, "Minimum Body Strength (%)", minval=0.0, maxval=100.0, step=1.0)

// Colors
insideColor = color.new(#F6BE00, 0)
twoUpColor = color.green
twoDownColor = color.red
outsideColor = color.fuchsia
neutralColor = color.gray
buyAggressionColor = color.lime
sellAggressionColor = color.rgb(255, 30, 30)

// Strat candle logic
oneBar = high <= high[1] and low >= low[1]
twoUp = high > high[1] and not (low < low[1])
twoDown = low < low[1] and not (high > high[1])
threeBar = high > high[1] and low < low[1]

// Standard Strat color
stratColor = oneBar ? insideColor : threeBar ? outsideColor : twoUp ? twoUpColor : twoDown ? twoDownColor : neutralColor

// Average volume
avgVolume = ta.sma(volume, avgLength)
elevatedVolume = not na(avgVolume) and volume >= avgVolume * volumeMultiplier

// Candle measurements
barRange = high - low
barBody = math.abs(close - open)
bodyPercent = barRange > 0 ? barBody / barRange * 100.0 : 0.0
closePosition = barRange > 0 ? (close - low) / barRange * 100.0 : 50.0

// Estimated aggression
aggressiveBuying = showAggression and elevatedVolume and close > open and closePosition >= closeThreshold and bodyPercent >= bodyThreshold
aggressiveSelling = showAggression and elevatedVolume and close < open and closePosition <= 100.0 - closeThreshold and bodyPercent >= bodyThreshold

// Final volume color
finalVolumeColor = aggressiveBuying ? buyAggressionColor : aggressiveSelling ? sellAggressionColor : stratColor

// Volume plots
plot(volume, title="Strat Volume", style=plot.style_columns, color=finalVolumeColor)
plot(showAvgVol ? avgVolume : na, title="Average Volume", color=color.white, linewidth=2)

// Aggression markers
plotshape(showLabels and aggressiveBuying ? volume : na, title="Buy Aggression", style=shape.triangleup, location=location.absolute, color=buyAggressionColor, text="BUY", textcolor=buyAggressionColor, size=size.tiny)
plotshape(showLabels and aggressiveSelling ? volume : na, title="Sell Aggression", style=shape.triangledown, location=location.absolute, color=sellAggressionColor, text="SELL", textcolor=sellAggressionColor, size=size.tiny)

// Alert conditions
alertcondition(aggressiveBuying, title="Buy Aggression", message="Estimated buy aggression detected on {{ticker}} {{interval}}")
alertcondition(aggressiveSelling, title="Sell Aggression", message="Estimated sell aggression detected on {{ticker}} {{interval}}")

// Data Window values
plot(bodyPercent, title="Body Strength %", color=color.new(color.white, 100), display=display.data_window)
plot(closePosition, title="Close Position %", color=color.new(color.white, 100), display=display.data_window)
plot(volume / avgVolume, title="Relative Volume", color=color.new(color.white, 100), display=display.data_window)
````
