# Uranium Spot Price Premium/Discount to Long-Term Ratio

- url: https://www.tradingview.com/script/WlXRgdj0-Uranium-Spot-Price-Premium-Discount-to-Long-Term-Ratio/
- type: indicator
- pine_id: PUB;4ccabee48a8b4f63bcd01dd52d86575d
- version: 2.0

## Description

A simple script to display Uranium pot price vs long term contract price.
It is based on Cameco published prices: 
https://research.investors.com/stock-quotes/nyse-cameco-ccj.htm
When the spot price surges above LT price, it signals speculative excitement, it's time to look for an exit.

## Source Code

````pine
//@version=6
indicator("Uranium Spot Price Premium/Discount to Long-Term", shorttitle="UX Spot vs LT", overlay=false)

// 1. Fetch Real-time Uranium Spot Price Contract Data (UX1!)
uraniumSpot = request.security("COMEX:UX1!", "D", close, barmerge.gaps_off, barmerge.lookahead_on)

// 2. Structural Monthly Long-Term Pricing Engine 
getUraniumLongTerm(int yr, int mo) =>
    float price = na
    
    // 2026 Term Nodes
    if yr == 2026

        if mo >= 6
            price := 95.50
        else if mo == 5
            price := 94.00
        else if mo == 4
            price := 91.50
        else if mo == 3
            price := 91.50
        else if mo == 2
            price := 90.00
        else
            price := 89.00
            
    // 2025 Term Nodes
    else if yr == 2025
        if mo == 12
            price := 86.50
        else if mo == 11
            price := 86.00
        else if mo == 10
            price := 85.00
        else if mo == 9
            price := 83.00
        else if mo == 8
            price := 81.00
        else if mo == 7
            price := 81.00
        else if mo == 6
            price := 80.00
        else if mo == 5
            price := 80.00
        else if mo == 4
            price := 80.00
        else if mo == 3
            price := 80.00
        else if mo == 2
            price := 80.00
        else
            price := 81.00
            
    // 2024 Term Nodes
    else if yr == 2024
        if mo == 12
            price := 80.50
        else if mo == 11
            price := 81.50
        else if mo == 10
            price := 81.50
        else if mo == 9
            price := 81.50
        else if mo == 8
            price := 81.00
        else if mo == 7
            price := 80.50
        else if mo == 6
            price := 79.50
        else if mo == 5
            price := 78.50
        else if mo == 4
            price := 77.50
        else if mo == 3
            price := 77.50
        else if mo == 2
            price := 75.00
        else
            price := 72.00
    // 2023 Term Nodes
    else if yr == 2023
        if mo == 12
            price := 68.00
        else if mo == 11
            price := 66.00
        else if mo == 10
            price := 64.00
        else if mo == 9
            price := 61.50
        else if mo == 8
            price := 59.00
        else if mo == 7
            price := 56.88
        else if mo == 6
            price := 56.00
        else if mo == 5
            price := 55.00
        else if mo == 4
            price := 53.50
        else if mo == 3
            price := 53.0
        else if mo == 2
            price := 53.00
        else
            price := 52.5
            // 2022 Term Nodes
    else if yr == 2022
        if mo == 12
            price := 52.00
        else if mo == 11
            price := 52.00
        else if mo == 10
            price := 51.00
        else if mo == 9
            price := 51.00
        else if mo == 8
            price := 51.50
        else if mo == 7
            price := 51.50
        else if mo == 6
            price := 51.50
        else if mo == 5
            price := 50.75
        else if mo == 4
            price := 50.00
        else if mo == 3
            price := 49.00
        else if mo == 2
            price := 43.88
        else
            price := 42.88
            
    // Fallback baseline for prior macro cycles
    else
        price := 36.00
        
    price

// Extract time coordinates from current processing bar
currentYear  = year(time)
currentMonth = month(time)

// Execute matrix retrieval to get historical Long Term contract value
uraniumLongTerm = getUraniumLongTerm(currentYear, currentMonth)

// 3. INVERTED Mathematical Calculation
// Formula: ((Spot Price - Long-Term Price) / Long-Term Price) * 100
spotDeviationPct = ((uraniumSpot - uraniumLongTerm) / uraniumLongTerm) * 100

// 4. Threshold Baselines
hline(0, "Market Value Parity", color=color.gray, linestyle=hline.style_dashed)

// 5. Visual Rendering Elements
// Green columns mean Spot is trading at a premium over Long-Term (tight market)
// Red columns mean Spot is trading at a discount below Long-Term (loose market)
dynamicColor = spotDeviationPct >= 0 ? color.green : color.red
plot(spotDeviationPct, title="Spot Deviation to LT %", color=color.new(dynamicColor, 30), style=plot.style_columns)

// 6. Dynamic Information Dashboard Table
var table infoBox = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 15), border_color=color.black, border_width=1)
if barstate.islast
    table.cell(infoBox, 0, 0, "U3O8 Spot Price:", text_color=color.white, text_size=size.small)
    table.cell(infoBox, 1, 0, "$" + str.tostring(uraniumSpot, "#.##"), text_color=color.aqua, text_size=size.small)
    
    table.cell(infoBox, 0, 1, "Macro Long-Term:", text_color=color.white, text_size=size.small)
    table.cell(infoBox, 1, 1, "$" + str.tostring(uraniumLongTerm, "#.##"), text_color=color.yellow, text_size=size.small)
    
    table.cell(infoBox, 0, 2, "Spot Prem/Disc:", text_color=color.white, text_size=size.small)
    table.cell(infoBox, 1, 2, str.tostring(spotDeviationPct, "#.##") + "%", text_color=dynamicColor, text_size=size.small)
````
