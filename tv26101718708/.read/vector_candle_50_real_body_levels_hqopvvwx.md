# Vector Candle 50% Real Body Levels

- url: https://www.tradingview.com/script/HqOpvvwx-Vector-Candle-50-Real-Body-Levels/
- type: indicator
- pine_id: PUB;c6dd14cc0ee647a096ed60fa58be798b
- version: 1.0

## Description

Vector Candle 50% Real Body Levels [v6]
Overview

This indicator identifies institutional volume anomalies (known as Vector Candles) and automatically plots a dynamic horizontal level at the exact 50% of their Real Body (the midpoint between open and close, completely ignoring the wicks).

In modern trading frameworks like Smart Money Concepts (SMC) or Order Blocks, the 50% threshold of a high-volume candle represents a premium point of control where heavy institutional orders were matched. This script visualizes these areas as high-probability support or resistance zones.

To keep your charts clean and noise-free, the script features a dynamic mitigation system: the moment any future candle touch or cross the line (even just with a wick), the level is considered "claimed" and immediately vanishes from your screen.
Key Features

    Real Body Midpoint Calculation: Unlike standard tools that calculate the 50% level using the absolute High and Low, this indicator targets the core of the market commitment by averaging only the open and close prices.

    Volume Threshold Filters: Dynamically benchmarks current volume against a Simple Moving Average (SMA) lookback period, filtering out normal market noise and highlighting only genuine capital injections.

    Auto-Clean Mitigation Logic: Levels instantly self-destruct once price mitigates or tests the exact coordinate, ensuring every single line visible on your chart is 100% active and pending.

    Engineered for v6 Performance: Built using Pine Script v6 User-Defined Types (UDTs) and efficient array memory management to prevent any charting lag, even during high-volatility sessions or lower timeframes.

Inputs & Customization

    Average Volume Lookback: The period used to establish the baseline volume average (Default: 10).

    Volume Multiplier 1 (VF) / Multiplier 2 (VA): Sensitivity thresholds to define what qualifies as an extraordinary volume vector (e.g., 2.0x or 1.5x above average).

    Level Style Options: Easily adjust the horizontal line color and thickness to blend seamlessly with your personal chart layout.

How to Trade with It

    Bullish Vector Mitigation (Support): When a high-volume bullish candle forms, look for the price to retrace downward to test the green horizontal line. This 50% body zone often acts as a strong bullish pivot.

    Bearish Vector Mitigation (Resistance): When a high-volume bearish candle drops, look for short-term relief rallies to cap out exactly at the 50% body line, offering high R:R (Risk-to-Reward) short entries.

    Breakout Tracking: If a level is pierced through aggressively rather than holding as pivot support/resistance, it indicates a structural shift in market direction.

## Source Code

````pine
//@version=6
indicator("Vector Candle 50% Real Body Levels", overlay=true, max_lines_count=500)

// --- Inputs ---
volLookback = input.int(10, "Average Volume Lookback")
mult1 = input.float(2.0, "Volume Multiplier 1 (VF)", step=0.1)
mult2 = input.float(1.5, "Volume Multiplier 2 (VA)", step=0.1)
lineColor = input.color(#00FF00, "Level Color")
lineWidth = input.int(2, "Line Width", minval=1)

// --- Logic ---
avgVol = ta.sma(volume, volLookback)
isVector = volume > avgVol * mult1 or volume > avgVol * mult2

// UDT to store level data
type VectorLevel
    line l
    float price
    int startBar
    bool active

var levels = array.new<VectorLevel>(0)

if isVector
    // MODIFICACIÓN: Determinamos la parte más alta y más baja del cuerpo real
    bodyMax = math.max(open, close)
    bodyMin = math.min(open, close)
    
    // NUEVO CRITERIO: Calculamos el 50% del cuerpo real (sin incluir mechas)
    midBodyPrice = (bodyMax + bodyMin) / 2
    
    // Trazamos la línea horizontal plana fijando el precio de inicio y fin en 'midBodyPrice'
    newL = line.new(x1=bar_index, y1=midBodyPrice, x2=bar_index + 1, y2=midBodyPrice, 
         color=lineColor, 
         width=lineWidth, 
         extend=extend.right)
    
    array.push(levels, VectorLevel.new(newL, midBodyPrice, bar_index, true))

// --- Deletion Logic ---
if array.size(levels) > 0
    for i = array.size(levels) - 1 to 0
        lvl = array.get(levels, i)
        if lvl.active
            // Se borra si el precio toca el nivel en barras posteriores
            if bar_index > lvl.startBar and low <= lvl.price and high >= lvl.price
                line.delete(lvl.l)
                lvl.active := false
                array.remove(levels, i)

// Limitar tamaño del array para rendimiento
if array.size(levels) > 100
    oldest = array.remove(levels, 0)
    line.delete(oldest.l)
````
