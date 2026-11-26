# SPY/SPX key levels

- url: https://www.tradingview.com/script/KxZoRm6p-SPY-SPX-key-levels/
- type: indicator
- pine_id: PUB;5e911af5a4b542bbad1e2e4b76d626dc
- version: 1.0

## Description

This indicator is a comprehensive technical dashboard designed for TradingView that displays key institutional and historical price levels for SPY and SPX, helping traders identify significant market zones.

### Key Features:

* **Multi-Timeframe Data**: Automatically tracks and displays the High and Low prices for the previous day, week, month, and quarter for both SPY and SPX.
* **Visual Dashboard**: Features a compact, organized table positioned in the bottom-right corner of the chart, allowing for quick reference without obstructing price action.
* **Chart Overlay**: Draws precise horizontal lines directly on the chart for each monitored level, ensuring traders can visually track these key price points in real-time.
* **Customized Readability**: Includes intelligent label positioning that keeps text above lines and utilizes a dynamic offset system to prevent label overlap during volatile market conditions.
* **Color-Coded Analysis**: Synchronizes label colors between the table and the chart, making it intuitive to distinguish between different timeframes and levels at a glance.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Levels Table & Lines", overlay=true)

// Function to fetch HLC
get_hlc(ticker, tf) =>
    [request.security(ticker, tf, high[1]), request.security(ticker, tf, low[1])]

// Define tickers
ticker1 = "SPY"
ticker2 = "SPX"

// Fetch data
[dHigh, dLow] = get_hlc(ticker1, "D")
[wHigh, wLow] = get_hlc(ticker1, "W")
[mHigh, mLow] = get_hlc(ticker1, "M")
[qHigh, qLow] = get_hlc(ticker1, "3M")
[dHigh2, dLow2] = get_hlc(ticker2, "D")
[wHigh2, wLow2] = get_hlc(ticker2, "W")
[mHigh2, mLow2] = get_hlc(ticker2, "M")
[qHigh2, qLow2] = get_hlc(ticker2, "3M")

// Table setup
var table levelsTable = table.new(position.bottom_right, 3, 9, border_width = 1, border_color = color.gray, bgcolor = color.new(color.black, 20))

// Row function
add_row(row_idx, label_text, v1, v2, label_color) =>
    table.cell(levelsTable, 0, row_idx, label_text, text_color=label_color)
    table.cell(levelsTable, 1, row_idx, str.tostring(v1, format.mintick), text_color=color.white)
    table.cell(levelsTable, 2, row_idx, str.tostring(v2, format.mintick), text_color=color.white)

// Function to draw lines with offset to prevent overlap and text above the line
draw_level(price, label_text, color_val, offset_idx) =>
    if not na(price)
        offset = offset_idx * 15
        // Draw the line
        line.new(bar_index - 50, price, bar_index + 10 + offset, price, color=color_val, width=2)
        // Position label above the line using a small vertical offset relative to price
        label.new(bar_index + 10 + offset, price, label_text + " @ " + str.tostring(price, format.mintick), 
             color=color.new(color.black, 100), 
             textcolor=color_val, 
             style=label.style_label_down, // Points downwards toward the line
             yloc=yloc.price) // Ensures label stays attached to the price level

if barstate.islast
    // Header
    table.cell(levelsTable, 0, 0, "Level", bgcolor=color.gray, text_color=color.white)
    table.cell(levelsTable, 1, 0, "SPY", bgcolor=color.gray, text_color=color.white)
    table.cell(levelsTable, 2, 0, "SPX", bgcolor=color.gray, text_color=color.white)
    
    // Fill table
    add_row(1, "PDH", dHigh, dHigh2, color.red)
    add_row(2, "PDL", dLow, dLow2, color.blue)
    add_row(3, "PWH", wHigh, wHigh2, color.orange)
    add_row(4, "PWL", wLow, wLow2, color.purple)
    add_row(5, "PMH", mHigh, mHigh2, color.green)
    add_row(6, "PML", mLow, mLow2, color.yellow)
    add_row(7, "PQH", qHigh, qHigh2, color.red)
    add_row(8, "PQL", qLow, qLow2, color.blue)

    // Draw lines
    draw_level(dHigh, "PDH", color.red, 0)
    draw_level(dLow, "PDL", color.blue, 1)
    draw_level(wHigh, "PWH", color.orange, 2)
    draw_level(wLow, "PWL", color.purple, 3)
    draw_level(mHigh, "PMH", color.green, 4)
    draw_level(mLow, "PML", color.yellow, 5)
    draw_level(qHigh, "PQH", color.red, 6)
    draw_level(qLow, "PQL", color.blue, 7)
````
