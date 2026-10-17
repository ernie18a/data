# Price to Gross Profit (Diluted shares oustanding) - Main Chart

- url: https://www.tradingview.com/script/SeppeHMa-Price-to-Gross-Profit-Diluted-shares-oustanding-Main-Chart/
- type: indicator
- pine_id: PUB;4c7515e68ae24a5c8c90bdf29a0217a1
- version: 1.0

## Description

plots on chart a signal of price to gp of 7 or less. 
feel free to change in the code urself. 

compares price (marketcap) to gross profit.

## Source Code

````pine
//@version=6
indicator("Price to Gross Profit (Diluted) - Main Chart", shorttitle="P/GP Signals", overlay=true)

// ────────────────────────────────────────
// Evaluation Function (Computed in Daily Context)
// ────────────────────────────────────────
f_pgp_signal(float target_ratio) =>
    // Fetch statements inside the function context
    float shares = request.financial(syminfo.tickerid, "DILUTED_SHARES_OUTSTANDING", "FQ", gaps=barmerge.gaps_off)
    float gp_ttm = request.financial(syminfo.tickerid, "GROSS_PROFIT", "TTM", gaps=barmerge.gaps_off)
    
    // Calculate Market Cap and P/GP Ratio
    float mc_diluted = na(shares) ? na : (close * shares)
    float pgp_ratio = na(mc_diluted) or na(gp_ttm) or gp_ttm <= 0 ? na : (mc_diluted / gp_ttm)
    
    // Return both the ratio value and the boolean trigger condition
    [pgp_ratio, not na(pgp_ratio) and pgp_ratio < target_ratio]

// ────────────────────────────────────────
// Secure the MTF Data Transmission
// ────────────────────────────────────────
// Request both the float value and the trigger boolean from the Daily timeframe simultaneously
[p_to_gp_diluted, is_below_target] = request.security(syminfo.tickerid, "D", f_pgp_signal(7.0))

// ────────────────────────────────────────
// Condition & Signal Plotting
// ────────────────────────────────────────
// Plot green triangles underneath the candles when the daily metric stays below 7
plotshape(is_below_target, 
          title="P/GP Below 7", 
          style=shape.triangleup, 
          location=location.belowbar, 
          color=color.green, 
          size=size.small)

// ────────────────────────────────────────
// Dynamic Floating Value Label
// ────────────────────────────────────────
var label lbl = na
if barstate.islast
    string label_text = na(p_to_gp_diluted) ? "P/GP: No Data Found" : "P/GP: " + str.tostring(p_to_gp_diluted, "#.##") + "×"
    color label_color = na(p_to_gp_diluted) ? color.maroon : color.blue

    label.delete(lbl)
    lbl := label.new(bar_index, high, label_text,
         color     = label_color,
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.normal,
         yloc      = yloc.price)
````
