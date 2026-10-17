# RSI with Dynamic SD Bands (Mean Reversion)

- url: https://www.tradingview.com/script/6RdZeQ1r-RSI-with-Dynamic-SD-Bands-Mean-Reversion/
- type: indicator
- pine_id: PUB;cdc12a8301ed42ba9c51031041eb427b
- version: 1.0

## Description

RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)RSI with Dynamic SD Bands (Mean Reversion)

## Source Code

````pine
//@version=6
indicator("RSI with Dynamic SD Bands (Mean Reversion)", overlay=false, timeframe="")

// --- Inputs ---
rsiLength   = input.int(14, title="RSI Length", minval=1)
sdLength    = input.int(20, title="SD Lookback Length", minval=1)
multiplier  = input.float(2.0, title="SD Multiplier", step=0.1)
src         = input.source(close, title="Source")

// --- Calculations ---
rsiVal = ta.rsi(src, rsiLength)
rsiMean = ta.sma(rsiVal, sdLength)
rsiSD = ta.stdev(rsiVal, sdLength)

upperBand = rsiMean + (rsiSD * multiplier)
lowerBand = rsiMean - (rsiSD * multiplier)

// --- Plots & Visuals ---
plot(rsiVal, title="RSI", color=color.purple, linewidth=2)
plot(rsiMean, title="RSI Mean (Basis)", color=color.gray, linewidth=1)

pUpper = plot(upperBand, title="Dynamic Overbought (+SD)", color=color.red, linewidth=1)
pLower = plot(lowerBand, title="Dynamic Oversold (-SD)", color=color.green, linewidth=1)

fill(pUpper, pLower, color=color.new(color.purple, 95), title="Bands Background")

// --- Entry Signals ---
shortSignal = ta.crossunder(rsiVal, upperBand)
longSignal  = ta.crossover(rsiVal, lowerBand)

plotshape(shortSignal, title="Short/Sell Alert", style=shape.triangledown, location=location.top, color=color.red, size=size.small)
plotshape(longSignal, title="Long/Buy Alert", style=shape.triangleup, location=location.bottom, color=color.green, size=size.small)

bgcolor(shortSignal ? color.new(color.red, 85) : na)
bgcolor(longSignal ? color.new(color.green, 85) : na)
````
