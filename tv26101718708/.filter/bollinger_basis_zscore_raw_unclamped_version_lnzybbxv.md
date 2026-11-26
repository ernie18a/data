# Bollinger Basis Z-Score - Raw / Unclamped Version

- url: https://www.tradingview.com/script/LnzyBbxV-Bollinger-Basis-Z-Score-Raw-Unclamped-Version/
- type: indicator
- pine_id: PUB;8b330884608e4975b0b0a13885536461
- version: 1.0

## Description

This script is an adaptation of the Bollinger Bands Z-Score concept.

Credit: Inspired by the open-source Bollinger Bands Z-Score script by TradingView user simonweisser_business:
https://www.tradingview.com/script/WdkD7KpA/

My modification for this version is that the displayed Z-score is left raw/unclamped instead of being hard-capped at ±2. For my long-term valuation use case, I need to see when Bitcoin moves beyond ±2 standard deviations, because capped values can stay glued to the upper or lower boundary and hide how extreme the condition really is.

This indicator is for educational and analytical purposes only and is not financial advice.

## Source Code

````pine
//@version=6
indicator(shorttitle="BB Z-Score", title="Bollinger Bands Z-Score - SDCA Version", overlay=false)

// Inputs
length = input.int(20, minval=1, title="BB Length")
maType = input.string("SMA", "Basis MA Type", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
src = input(close, title="Source")

zlen = input.int(50, "Z-Score Length")
sdScale = input.float(1.0, "Z-Score SD Scale", minval=0.1, step=0.1)

showClamped = input.bool(false, "Clamp Display")
clampValue = input.float(3.0, "Clamp Value", minval=1.0, step=0.5)

// MA Function
ma(source, length, _type) =>
    switch _type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

// Basis line
basis = ma(src, length, maType)

// Z-score of the basis line
mean = ta.sma(basis, zlen)
std = ta.stdev(basis, zlen)
zscore = std != 0 ? (basis - mean) / (std * sdScale) : 0

// Optional display clamp only
plotZ = showClamped ? math.min(math.max(zscore, -clampValue), clampValue) : zscore

// Lines
hline(3,  "Raw +3 / SDCA -3", color=color.new(color.red, 50))
hline(2,  "Raw +2 / SDCA -2", color=color.new(color.red, 20))
hline(1,  "Raw +1 / SDCA -1", color=color.new(color.orange, 30))
hline(0,  "Neutral", color=color.gray)
hline(-1, "Raw -1 / SDCA +1", color=color.new(color.teal, 30))
hline(-2, "Raw -2 / SDCA +2", color=color.new(color.green, 20))
hline(-3, "Raw -3 / SDCA +3", color=color.new(color.green, 50))

plot(plotZ, title="BB Basis Z-Score", color=color.blue, linewidth=2)

// Background
hUpper = hline(2, display=display.none)
hLower = hline(-2, display=display.none)
fill(hUpper, hLower, color=color.new(color.blue, 90), title="Background Fill")
````
