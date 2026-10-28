# Sprott Uranium Trust (U.UN) Synthetic NAV Engine

- url: https://www.tradingview.com/script/ZuuwYxIb-Sprott-Uranium-Trust-U-UN-Synthetic-NAV-Engine/
- type: indicator
- pine_id: PUB;ebe8b648e3f041f4b30efc2e55fd1e1f
- version: 1.0

## Description

A simple script to display Sprott Uranium U.U fund discount to NAV (in USD).
The fund often drops to 10% discount which tends to be a good spot to go long.

## Source Code

````pine
//@version=6
indicator("Sprott Uranium Trust (U.UN) Synthetic NAV Engine", shorttitle="U.UN True NAV", overlay=false)

// 1. Core Mathematical Multiplier (Pounds of Uranium per 1 share unit of U.UN)
// Derived directly from Sprott's official assets divided by outstanding shares
lbsPerUnit = 0.236666

// 2. Safely fetch live global Uranium Spot Price from COMEX futures 
// We use 'barmerge.lookahead_on' to prevent historical charts from distorting historical gaps
uraniumSpotPrice = request.security("COMEX:UX1!", "D", close, barmerge.gaps_off, barmerge.lookahead_on)

// 3. Compute Real-time Synthetic NAV Per Share
// Formula: Spot Price of 1 lb of Uranium * Pounds held per individual share unit
syntheticNAV = uraniumSpotPrice * lbsPerUnit

// 4. Calculate Percentage Premium or Discount Deviation
// Formula: ((Market Price - Synthetic NAV) / Synthetic NAV) * 100
navDeviationPct = ((close - syntheticNAV) / syntheticNAV) * 100

// 5. Visual Threshold Markers
hline(0, "Fair Value Parity", color=color.gray, linestyle=hline.style_dashed)
lowLine  = hline(-5.0, "Deep Discount Target", color=color.green, linestyle=hline.style_dotted)
highLine = hline(2.0, "High Premium Risk", color=color.red, linestyle=hline.style_dotted)

// Color transitions: Bright green for discounts, bright red for premiums
dynamicColor = navDeviationPct >= 0 ? color.red : color.green
plot(navDeviationPct, title="Premium/Discount %", color=color.new(dynamicColor, 30), style=plot.style_columns)

// 6. Dynamic Information Dashboard Table
var table infoBox = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 20), border_color=color.black, border_width=1)
if barstate.islast
    table.cell(infoBox, 0, 0, "Market Price (CAD):", text_color=color.white, text_size=size.small)
    table.cell(infoBox, 1, 0, "$" + str.tostring(close, "#.##"), text_color=color.white, text_size=size.small)
    
    table.cell(infoBox, 0, 1, "Derived NAV (CAD):", text_color=color.white, text_size=size.small)
    table.cell(infoBox, 1, 1, "$" + str.tostring(syntheticNAV, "#.##"), text_color=color.yellow, text_size=size.small)
    
    table.cell(infoBox, 0, 2, "Net Deviation:", text_color=color.white, text_size=size.small)
    table.cell(infoBox, 1, 2, str.tostring(navDeviationPct, "#.##") + "%", text_color=navDeviationPct >= 0 ? color.red : color.green, text_size=size.small)
````
