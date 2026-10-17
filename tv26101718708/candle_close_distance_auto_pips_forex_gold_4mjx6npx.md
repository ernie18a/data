# Candle Close Distance (Auto Pips - Forex + Gold)

- url: https://www.tradingview.com/script/4MjX6npx-Candle-Close-Distance-Auto-Pips-Forex-Gold/
- type: indicator
- pine_id: PUB;df437784f1e04912b4d79089c4c058e3
- version: 1.0

## Description

This script is designed to identify potential trading opportunities on XAUUSD using trend and price action.

It highlights key levels and possible entry signals based on market structure.

Features:
- Trend direction identification
- Buy and sell signals
- Clean and easy-to-read chart

This tool is intended for educational purposes and should be used alongside proper risk management.

## Source Code

````pine
//@version=5
indicator("Candle Close Distance (Auto Pips - Forex + Gold)", overlay=true)

// === AUTO PIP SIZE DETECTION ===
pip_size = syminfo.mintick == 0.00001 ? 0.0001 :
           syminfo.mintick == 0.001   ? 0.01   :
           syminfo.mintick == 0.01    ? 0.1    :
           0.0001

// === CONDITIONS ===
isBull = close > open
isBear = close < open

// === DISTANCE CALCULATION ===
distance = isBull ? (close - low) : isBear ? (high - close) : 0
distance_pips = distance / pip_size

// === LABEL (LAST 50 CANDLES ONLY) ===
if bar_index >= ta.highest(bar_index, 50) - 50
    label.new(bar_index, high, 
         text = str.tostring(distance_pips, "#.##") + " pips",
         style = label.style_label_down,
         color = isBull ? color.green : isBear ? color.red : color.gray,
         textcolor = color.white,
         size = size.small)

// === OPTIONAL LINE ===
plot(distance_pips, title="Distance (Pips)", color=color.blue)
````
