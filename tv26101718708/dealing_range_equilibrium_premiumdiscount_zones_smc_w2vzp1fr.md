# Dealing Range Equilibrium & Premium/Discount Zones (SMC)

- url: https://www.tradingview.com/script/w2VZp1fR-Dealing-Range-Equilibrium-Premium-Discount-Zones-SMC/
- type: indicator
- pine_id: PUB;44613f17cdba42e78030e8091a48fac4
- version: 1.0

## Description

This indicator is a streamlined visualization tool designed specifically for traders utilizing Smart Money Concepts (SMC) and ICT methodologies. It automatically detects the current structural Dealing Range and divides it into logical quadrants: Premium, Discount, and Equilibrium.
Rather than manually drawing Fibonacci grids on every new structural swing, this script dynamically anchors to the most recent validated pivot points, keeping your charts clean and your focus on price action.
Underlying Logic & Calculations
The script relies on a standard pivot-detection algorithm to establish the boundaries of the dealing range:
Swing Detection: It uses standard ta.pivothigh and ta.pivotlow functions to scan for structural highs and lows based on a user-defined "Swing Lookback Period" (default is 20 bars). A pivot high is confirmed when the central candle is higher than the n candles to its left and right.
Range Anchoring: Once a new swing high or low is validated, the top or bottom variables update respectively. These horizontal levels persist forward in time until a new structural pivot breaks them.
Equilibrium Calculation: The script calculates the mathematical median of the current range by adding the active Swing High and Swing Low, then dividing by two (top + bottom) / 2.
Visuals & Practical Usage
In SMC theory, markets move from consolidation to expansion, seeking liquidity. The dealing range helps traders contextualize where price is relative to recent structure:
Premium Zone (Red Fill): The upper 50% of the dealing range. In a bearish structural environment, traders look for price to retrace into the Premium zone to identify high-probability short setups or institutional distribution.
Discount Zone (Green Fill): The lower 50% of the dealing range. In a bullish environment, traders wait for price to retrace into the Discount zone to look for long setups or institutional accumulation.
Equilibrium (Midline): The exact 50% level (fair value). Price action around this line often acts as a transition point or near-term support/resistance.
Settings
Swing Lookback Period: Controls the sensitivity of the pivot detection. A lower number (e.g., 5 or 10) will capture micro-structure and minor pullbacks, ideal for scalping. A higher number (e.g., 20 or 50) will anchor only to major macro-swings.
Show Labels: Toggles the text labels on the current price axis to keep the chart clean if desired.

## Source Code

````pine
//@version=6
indicator("Trader's Multiverse Dealing Range Equilibrium Original", overlay=true)

// --- Inputs ---
swingLookback = input.int(20, "Swing Lookback Period", minval=2)
showLabels    = input.bool(true, "Show Labels")
eqColor       = input.color(color.new(color.gray, 50), "Equilibrium Color")

// --- Logic to find Swings ---
float ph = ta.pivothigh(high, swingLookback, swingLookback)
float pl = ta.pivotlow(low, swingLookback, swingLookback)

// Variables to store the current Dealing Range
var float top = na
var float bottom = na

if not na(ph)
    top := ph
if not na(pl)
    bottom := pl

// Calculate Equilibrium
float equilibrium = (top + bottom) / 2

// --- Plotting ---
// Plot the High and Low of the range
plot(top, "Range High", color=color.red, style=plot.style_linebr)
plot(bottom, "Range Low", color=color.green, style=plot.style_linebr)

// Plot the Equilibrium (50% level)
plot(equilibrium, "Equilibrium (50%)", color=eqColor, linewidth=2, style=plot.style_linebr)

// Fill Premium and Discount zones
p1 = plot(top, display=display.none)
p2 = plot(equilibrium, display=display.none)
p3 = plot(bottom, display=display.none)

fill(p1, p2, color.new(color.red, 90), title="Premium Zone")
fill(p2, p3, color.new(color.green, 90), title="Discount Zone")

// --- Labels ---
if showLabels and barstate.islast
    label.new(bar_index, top, "Premium (High)", style=label.style_none, textcolor=color.red)
    label.new(bar_index, equilibrium, "Equilibrium", style=label.style_none, textcolor=color.gray)
    label.new(bar_index, bottom, "Discount (Low)", style=label.style_none, textcolor=color.green)
````
