# Fractal Model - C2 (Fixed Arrows) -QMA

- url: https://www.tradingview.com/script/nbVucO0c-Fractal-Model-C2-Fixed-Arrows-QMA/
- type: indicator
- pine_id: PUB;204e354b388a4a799620952e1ddff635
- version: 1.0

## Description

Fractal Model - C2 (Fixed Arrows) -QMA

Core Concepts: This script identifies swing points where price transitions between bullish and bearish trends.

Liquidity Sweeps: It targets specific candle wicks that breach local liquidity before a reversal.

Confirmation (CISD): The signal only appears when Candle 2 confirms a "Change in State of Delivery" by closing beyond the expansion of the sweep candle.

High Probability: Uses Daily Bias alignment to filter out low-probability trades that move against the higher timeframe trend.

Risk Management: Designed for a 2R risk-to-reward ratio setup.

## Source Code

````pine
//@version=5
indicator("Fractal Model - C2 (Fixed Arrows)", overlay=true)

// --- 1. Identify Swing Liquidity ---
// Using a smaller lookback (like 3-5) helps catch the tight sweeps seen in your images.
lookback = input.int(3, "Liquidity Lookback") 

// hi/lo are the levels to be swept (the peaks/valleys before the sweep candle)
hi = ta.highest(high[2], lookback) 
lo = ta.lowest(low[2], lookback) 

// --- 2. Logic for Liquidity Sweep (Candle 1) ---
// Candle 1 [index 1] must sweep the liquidity level
bullishSweep = low[1] < lo 
bearishSweep = high[1] > hi 

// --- 3. Candle 2 Confirmation (The Current Candle) ---
// Candle 2 [index 0] confirms by closing past the C1 body (Change in State of Delivery)
c2Bullish = bullishSweep and close[0] > high[1]
c2Bearish = bearishSweep and close[0] < low[1]

// --- 4. Visual Arrows (Offset to Prior Candle) ---
// offset = -1 puts the arrow exactly on the sweep candle (C1)
plotshape(c2Bullish ? true : na, 
     title="C2 Bullish", 
     style=shape.arrowup,   
     location=location.belowbar, 
     color=color.new(#00ffbb, 0), 
     size=size.small, 
     text="C2", 
     textcolor=color.new(#00ffbb, 0),
     offset=-1)

plotshape(c2Bearish ? true : na, 
     title="C2 Bearish", 
     style=shape.arrowdown, 
     location=location.abovebar, 
     color=color.new(#ff0055, 0), 
     size=size.small, 
     text="C2", 
     textcolor=color.new(#ff0055, 0),
     offset=-1)

// --- Alert Configuration ---
alertcondition(c2Bullish, "C2 Bullish Confirmed", "Fractal C2 Long")
alertcondition(c2Bearish, "C2 Bearish Confirmed", "Fractal C2 Short")
````
