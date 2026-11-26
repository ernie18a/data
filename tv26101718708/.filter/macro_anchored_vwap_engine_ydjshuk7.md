# Macro Anchored VWAP Engine

- url: https://www.tradingview.com/script/YDjsHuk7-Macro-Anchored-VWAP-Engine/
- type: indicator
- pine_id: PUB;6bf2d74b64a647f2842f3277bd986780
- version: 1.0

## Description

The Anchored VWAP Engine is a mathematical model that tracks the true institutional average price paid for an asset, starting from a specific, user-defined historical event. Unlike standard indicators that rely purely on time, this engine merges price, volume, and volatility into a single structural anchor.1. How the Engine Works Under the HoodThe engine operates on a cumulative looping mechanism that activates the exact moment a chosen historical date occurs on the chart.The Accumulation Trigger: The code ignores all data before your chosen date (e.g., March 23, 2020). When that bar arrives, it starts an open-ended running calculation.The Volume-Weighting Core: For every subsequent candle, it multiplies the typical price \((\frac{\text{High} + \text{Low} + \text{Close}}{3})\) by that candle's trading volume.The Running Totals: It adds this result to a rolling sum of cumulative price-volume and divides it by the total rolling sum of volume.2. The Statistical Dislocation MathThe unique power of the engine lies in its ability to compute true volume-weighted variance. It runs a parallel calculation tracking the square of the price multiplied by volume to extract a clean Standard Deviation (SD) channel.text               [Active Market Price]  <─── High-Sigma Exhaustion Zone (+3 SD)
                      ▲
                      │  (Parabolic Distance)
                      ▼
               [+2 SD Extreme Band]   <─── Institutional Liquidity Wall
                      ▲
                      │  (Typical Market Range: 95% of all distributions)
                      ▼
[ANCHOR DATE] ──> [BASE AVWAP LINE]   <─── True Institutional Equilibrium (The Mean)
Use code with caution.The Baseline Line: This is the absolute center of gravity. It represents the collective average break-even price of all institutional market participants who entered since the anchor point.The 2-Sigma Channel (\(\pm \)2 SD): This defines the outer boundary of normal market distribution. Statistically, price will trade inside this channel 95% of the time.The 3-Sigma Boundary (\(\pm \)3 SD): This represents a severe mathematical anomaly. When price stretches up to touch this band during a parabolic run, it means the asset is unsustainably overextended relative to its volume foundation.3. Core Advantages Over Traditional IndicatorsCompletely Non-Repainting: The levels lock into historical certainty as the chart moves forward.Immune to Time Dilution: Moving averages fade in relevance as time passes. Anchored VWAP grows structurally stronger as more volume accumulates over years.Identifies True Value: It shows you exactly where institutions will defend their positions during a major correction, rather than guessing based on visual line-drawing.

## Source Code

````pine
//@version=6
indicator("Institutional Macro Anchored VWAP Engine", overlay=true, max_lines_count=500)

// Group 1: User-Defined Structural Anchor Dates
g_anchors = "Macro Structural Anchors"
useGFC    = input.bool(true, "Plot 2009 GFC Anchor", group=g_anchors)
gfcYear   = input.int(2009, "GFC Year", group=g_anchors)
gfcMonth  = input.int(3, "GFC Month", group=g_anchors)
gfcDay    = input.int(6, "GFC Day", group=g_anchors)

useCovid  = input.bool(true, "Plot 2020 COVID Anchor", group=g_anchors)
covYear   = input.int(2020, "COVID Year", group=g_anchors)
covMonth  = input.int(3, "COVID Month", group=g_anchors)
covDay    = input.int(23, "COVID Day", group=g_anchors)

// Function to calculate volume-weighted cumulative metrics
f_calc_anchored_vwap(bool condition) =>
    var float cumPV  = 0.0
    var float cumVol = 0.0
    var float cumV_P2 = 0.0 // Cumulative Volume * Price^2 for variance math
    
    // Reset and begin accumulation when the specific calendar date is crossed
    if condition and not condition[1]
        cumPV   := 0.0
        cumVol  := 0.0
        cumV_P2 := 0.0
        
    if condition or cumVol > 0.0
        cumPV   += hlc3 * volume
        cumVol  += volume
        cumV_P2 += volume * math.pow(hlc3, 2)
        
    v_vwap = cumVol > 0.0 ? cumPV / cumVol : na
    v_var  = cumVol > 0.0 ? (cumV_P2 / cumVol) - math.pow(v_vwap, 2) : 0.0
    v_sd   = v_var > 0.0 ? math.sqrt(v_var) : 0.0
    [v_vwap, v_sd]

// Logical conditions checking for timestamp crossing
gfcTrigger   = time >= timestamp(gfcYear, gfcMonth, gfcDay, 00, 00)
covidTrigger = time >= timestamp(covYear, covMonth, covDay, 00, 00)

// Execute Calculations
[gfcVwap, gfcSd]     = f_calc_anchored_vwap(gfcTrigger)
[covidVwap, covidSd] = f_calc_anchored_vwap(covidTrigger)

// Plotting Engine - 2009 GFC Structure
plot(useGFC ? gfcVwap : na, "GFC Base VWAP", color=color.orange, linewidth=2)
plot(useGFC ? gfcVwap + (2.0 * gfcSd) : na, "GFC +2 SD Extreme", color=color.new(color.red, 30), linewidth=1, style=plot.style_line)
plot(useGFC ? gfcVwap + (3.0 * gfcSd) : na, "GFC +3 SD Exhaustion", color=color.new(color.maroon, 10), linewidth=2)

// Plotting Engine - 2020 COVID Structure
plot(useCovid ? covidVwap : na, "COVID Base VWAP", color=color.blue, linewidth=2)
plot(useCovid ? covidVwap + (2.0 * covidSd) : na, "COVID +2 SD Extreme", color=color.new(color.purple, 30), linewidth=1, style=plot.style_line)
plot(useCovid ? covidVwap + (3.0 * covidSd) : na, "COVID +3 SD Exhaustion", color=color.new(color.fuchsia, 10), linewidth=2)
````
