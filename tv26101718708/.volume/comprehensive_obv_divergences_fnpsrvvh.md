# Comprehensive OBV & Divergences

- url: https://www.tradingview.com/script/FNpSrVVh-Comprehensive-OBV-Divergences/
- type: indicator
- pine_id: PUB;e2f8f458610b4d4b8d29413d664575ad
- version: 1.0

## Description

A 20-period Simple Moving Average to the OBV line that can be used in tandem with VWMA. If price is above a rising VWMA, and OBV is crossing above its own MA, you have complete alignment between price action and volume flow.

## Source Code

````pine
//@version=6
indicator("Comprehensive OBV & Divergences", shorttitle="OBV + Div", overlay=false)

// =========================================================================
// INPUTS
// =========================================================================
src = input(close, title="Source")
maLength = input.int(20, title="OBV MA Length", tooltip="Used for trend confirmation alongside your VWMA")
pivotLookback = input.int(5, title="Pivot Lookback", minval=1, tooltip="Number of bars required to confirm a pivot high/low. Lower = more sensitive, Higher = major swings.")

// =========================================================================
// CALCULATIONS
// =========================================================================
// Standard OBV Calculation
obv = ta.cum(math.sign(ta.change(src)) * volume)
obv_ma = ta.sma(obv, maLength)

// =========================================================================
// DIVERGENCE LOGIC
// =========================================================================
// Identify Pivot Highs and Lows
plFound = not na(ta.pivotlow(src, pivotLookback, pivotLookback))
phFound = not na(ta.pivothigh(src, pivotLookback, pivotLookback))

// Variables to store the last two price and OBV pivot values
var float priceL1 = na, var float priceL2 = na
var float obvL1 = na,   var float obvL2 = na

var float priceH1 = na, var float priceH2 = na
var float obvH1 = na,   var float obvH2 = na

// Update Lows (For Bullish Divergence)
if plFound
    priceL2 := priceL1
    priceL1 := src[pivotLookback]
    obvL2 := obvL1
    obvL1 := obv[pivotLookback]

// Update Highs (For Bearish Divergence)
if phFound
    priceH2 := priceH1
    priceH1 := src[pivotLookback]
    obvH2 := obvH1
    obvH1 := obv[pivotLookback]

// Detect Regular Bullish Divergence (Price makes Lower Low, OBV makes Higher Low)
bullDiv = plFound and (priceL1 < priceL2) and (obvL1 > obvL2)

// Detect Regular Bearish Divergence (Price makes Higher High, OBV makes Lower High)
bearDiv = phFound and (priceH1 > priceH2) and (obvH1 < obvH2)

// =========================================================================
// PLOTTING
// =========================================================================
// Plot OBV and MA
plot(obv, title="OBV", color=color.new(color.blue, 0), linewidth=2)
plot(obv_ma, title="OBV MA", color=color.new(color.orange, 0), linewidth=1)

// Plot Divergence Signals directly on the OBV pane
plotshape(bullDiv ? obv[pivotLookback] : na, title="Bullish Divergence", text="BULL", style=shape.labelup, location=location.absolute, color=color.new(color.green, 0), textcolor=color.white, offset=-pivotLookback)
plotshape(bearDiv ? obv[pivotLookback] : na, title="Bearish Divergence", text="BEAR", style=shape.labeldown, location=location.absolute, color=color.new(color.red, 0), textcolor=color.white, offset=-pivotLookback)
````
