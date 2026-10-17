# Pyramid Giza Vector & Moon Target

- url: https://www.tradingview.com/script/kebcwC2t-Pyramid-Giza-Vector-Moon-Target/
- type: indicator
- pine_id: PUB;4587423442a9463d8dfa8687f9b14232
- version: 1.0

## Description

Directional Clarity: It provides an immediate "bias." If price is riding the 51.8° line, the trend is sustainable. If the angle becomes too steep (e.g., 80°), the market is "overheated." If it breaks below, the "Divine Proportion" is lost, and a crash is likely.

Geometric Support/Resistance: Unlike a horizontal line, this diagonal moves with time. It predicts exactly where support should be three days or three weeks from now.

The "Squaring" Signal: When the price (Vertical) and Time (Horizontal) meet at this specific angle, it identifies a "Square" in the market—often the exact moment a major trend reverses.

## Source Code

````pine
//@version=5
indicator("Pyramid Giza Vector & Moon Target", overlay=true)

// --- Inputs ---
lookbackInput = input.int(50, "Lookback for Pivot", minval=10)
show_circles = input.bool(true, "Show Moon Target (1.272)")

// --- Math & Geometry ---
pyramid_slope_ratio = 1.272 

var float anchor_p = na
var int anchor_t = na

low_piv = ta.pivotlow(low, lookbackInput, 5)

if not na(low_piv)
    anchor_p := low[5]
    anchor_t := bar_index[5]

// --- Vector Calculation ---
atr_val = ta.atr(14)
slope_per_b = (atr_val / 10) * pyramid_slope_ratio

float giza_v = na
if not na(anchor_p)
    t_delta = bar_index - anchor_t
    giza_v := anchor_p + (t_delta * slope_per_b)

moon_t = anchor_p + (atr_val * 4.236) 

// --- Plotting using HEX codes to bypass 'color' identifier error ---
plot(giza_v, color=#FFD700, title="Pyramid Slope (51.8°)", linewidth=2)
plot(show_circles ? moon_t : na, color=#808080, style=plot.style_linebr, title="Moon Target")

// --- Directional Signals ---
bull_sig = ta.crossover(close, giza_v)
bear_sig = ta.crossunder(close, giza_v)

plotshape(bull_sig, style=shape.triangleup, location=location.belowbar, color=#00FF00, size=size.small, title="Bullish Alignment")
plotshape(bear_sig, style=shape.triangledown, location=location.abovebar, color=#FF0000, size=size.small, title="Broken Symmetry")

// Alert logic
alertcondition(bull_sig, title="Geometric Alignment", message="Price has entered the Pyramid Slope!")
alertcondition(bear_sig, title="Geometry Broken", message="Price has fallen below the Giza Vector.")
````
