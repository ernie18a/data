# Gold Price Cambodian Units - LFT.Trader

- url: https://www.tradingview.com/script/dF3azmHE-Gold-Price-Cambodian-Units-LFT-Trader/
- type: indicator
- pine_id: PUB;307456cdb7304579abdec616e45060a1
- version: 1.0

## Description

This indicator is specifically designed for gold traders and investors in the Cambodian market. It bridges the gap between the global gold market (priced in Troy Ounces) and the local Cambodian measurement system.
It provides a live-updating table on your chart that converts the current XAU/USD price into Damlung (ដំឡឹង), Chi (ជី), and Hun (ហ៊ុន).

[b]Measurement Logic
[/b]To ensure accuracy, the script uses the standard international-to-local conversion:
1 Damlung (ដំឡឹង) = 37.5 Grams
1 Troy Ounce ≈ 31.1034768 Grams
1 Damlung ≈ 1.20565 Troy Ounces
1 Damlung = 10 Chi (ជី)
1 Chi = 10 Hun (ហ៊ុន)

[b]Key Features
[/b]✅ Live Updates: Calculations refresh instantly with every price movement on the XAUUSD chart.
✅ Dual Currency Display: View prices in both USD and Cambodian Riel (KHR).
✅ Customizable Exchange Rate: Since local market rates for USD/KHR can vary from official bank rates, you can manually set your preferred exchange rate in the settings.
✅ Flexible UI: Choose from 9 different positions on your chart to place the table (Top, Middle, Bottom — Left, Center, Right).
✅ Toggle KHR Column: Hide or show the Riel column depending on your preference.
✅ Clean Formatting: Prices include thousands separators (commas) and decimal points for high-precision viewing.

[b]How to Use
[/b]Add the indicator to a Gold (XAUUSD) chart.
Open the Settings to adjust the table position or text size.
Input the current local USD/KHR exchange rate to get an accurate Riel price.
Use the "Show Price (KHR)" checkbox to simplify the table if you only need USD values.

[b]Disclaimer
[/b]This tool is for informational purposes only. Local gold shop premiums and spreads may vary. Always verify prices with your local dealer before making financial decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LFT_Trader

//@version=6
indicator("Gold Price Cambodian Units - LFT.Trader", overlay=true)

// --- Inputs ---
group_pos = "Table Settings"
table_pos_input = input.string("Top Right", "Table Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=group_pos)
text_size = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=group_pos)

group_conv = "Currency Settings"
show_khr = input.bool(true, "Show Price (KHR) Column", tooltip="Toggle to show or hide the Cambodian Riel column.", group=group_conv)
usd_khr_rate = input.float(4100, "USD/KHR Manual Rate", tooltip="Since TradingView's USD/KHR might vary, you can set the local market rate here.", group=group_conv)

// --- Calculations ---
// 1 Damlung = 37.5g
// 1 Oz = 31.1034768g
// Ratio = 37.5 / 31.1034768 = 1.20565302
oz_to_damlung_ratio = 1.20565302
current_gold_price_usd = close

price_damlung_usd = current_gold_price_usd * oz_to_damlung_ratio
price_chi_usd     = price_damlung_usd / 10
price_hun_usd     = price_chi_usd / 10

price_damlung_khr = price_damlung_usd * usd_khr_rate
price_chi_khr     = price_chi_usd * usd_khr_rate
price_hun_khr     = price_hun_usd * usd_khr_rate

// --- Table Position Logic ---
var table_pos = position.top_right
if table_pos_input == "Top Right"
    table_pos := position.top_right
else if table_pos_input == "Top Center"
    table_pos := position.top_center
else if table_pos_input == "Top Left"
    table_pos := position.top_left
else if table_pos_input == "Middle Right"
    table_pos := position.middle_right
else if table_pos_input == "Middle Center"
    table_pos := position.middle_center
else if table_pos_input == "Middle Left"
    table_pos := position.middle_left
else if table_pos_input == "Bottom Right"
    table_pos := position.bottom_right
else if table_pos_input == "Bottom Center"
    table_pos := position.bottom_center
else if table_pos_input == "Bottom Left"
    table_pos := position.bottom_left

// --- Table Size Logic ---
var t_size = size.normal
if text_size == "Small"
    t_size := size.small
else if text_size == "Large"
    t_size := size.large

// --- Create and Update Table ---
var table goldTable = table.new(table_pos, 3, 4, border_width = 1, border_color = color.gray, frame_width = 1, frame_color = color.gray)

if barstate.islast
    // Clear the table to handle the column toggle smoothly
    table.clear(goldTable, 0, 0, 2, 3)

    // Header
    table.cell(goldTable, 0, 0, "Unit (ឯកតា)", bgcolor = color.new(color.orange, 0), text_color = color.black, text_size = t_size)
    table.cell(goldTable, 1, 0, "Price (USD)", bgcolor = color.new(color.orange, 0), text_color = color.black, text_size = t_size)
    if show_khr
        table.cell(goldTable, 2, 0, "Price (KHR)", bgcolor = color.new(color.orange, 0), text_color = color.black, text_size = t_size)

    // Row 1: Damlung
    table.cell(goldTable, 0, 1, "1 Damlung (ដំឡឹង)", bgcolor = color.new(color.gray, 90), text_color = color.gray, text_size = t_size)
    table.cell(goldTable, 1, 1, str.format("{0,number,#,###.##}", price_damlung_usd), bgcolor = color.new(color.gray, 90), text_color = color.red, text_size = t_size)
    if show_khr
        table.cell(goldTable, 2, 1, str.format("{0,number,#,###.##}", price_damlung_khr), bgcolor = color.new(color.gray, 90), text_color = color.gray, text_size = t_size)

    // Row 2: Chi
    table.cell(goldTable, 0, 2, "1 Chi (ជី)", bgcolor = color.new(color.gray, 80), text_color = color.gray, text_size = t_size)
    table.cell(goldTable, 1, 2, str.format("{0,number,#,###.##}", price_chi_usd), bgcolor = color.new(color.gray, 80), text_color = color.red, text_size = t_size)
    if show_khr
        table.cell(goldTable, 2, 2, str.format("{0,number,#,###.##}", price_chi_khr), bgcolor = color.new(color.gray, 80), text_color = color.gray, text_size = t_size)

    // Row 3: Hun
    table.cell(goldTable, 0, 3, "1 Hun (ហ៊ុន)", bgcolor = color.new(color.gray, 90), text_color = color.gray, text_size = t_size)
    table.cell(goldTable, 1, 3, str.format("{0,number,#,###.##}", price_hun_usd), bgcolor = color.new(color.gray, 90), text_color = color.red, text_size = t_size)
    if show_khr
        table.cell(goldTable, 2, 3, str.format("{0,number,#,###.##}", price_hun_khr), bgcolor = color.new(color.gray, 90), text_color = color.gray, text_size = t_size)
````
