# Options Spread Strike Guide

- url: https://www.tradingview.com/script/U5RfEOXl-Options-Spread-Strike-Guide/
- type: indicator
- pine_id: PUB;8fe84f4592c84981a787bb5dd0ef5820
- version: 1.0

## Description

A quick reference for building call debit, put debit, call credit, and put credit spreads.

Build option spreads with confidence.

One of the most common points of confusion for new options traders is remembering which strike price to buy and which strike price to sell for each debit and credit spread.

This lightweight reference guide provides a compact on-chart table showing the correct spread construction for the four basic vertical spreads:

Call Debit
Put Debit
Call Credit
Put Credit

Each row clearly identifies:

Buy – Larger or Smaller Strike $
Sell – Larger or Smaller Strike $
Move – The expected direction of the underlying price

The guide is intended as a quick reference while placing trades. It does not generate trading signals or recommend specific strike prices.

Features
Compact reference table
Uses Buy and Sell instead of Long and Short for clarity
Uses Larger $ and Smaller $ instead of "Higher" and "Lower" strikes to reduce confusion
Optional muted color theme
Configurable table position
Small footprint designed for multi-chart layouts
Tips

The guide can be displayed:

On the main chart
In a lower indicator panel
Alongside another indicator such as RSI if you prefer to keep your price chart uncluttered

Choose the location that best fits your workflow.

Designed for Learning

This indicator is intended as a learning and reference tool. It helps reinforce proper spread construction until it becomes second nature.

Once you know the market direction and the type of spread you want to trade, the table provides a quick reminder of which strike prices to buy and sell.

If this guide saves you from making even one spread construction mistake, then it has done its job.

## Source Code

````pine
//@version=6
indicator("Options Spread Strike Guide", overlay=true)

// --- Inputs for Customization ---
string grp_display = "Table Display Settings"
bool show_table    = input.bool(true, "Show Table", group=grp_display)
string table_pos   = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Center Right", "Center Left"], group=grp_display)
string text_style  = input.string("Normal", "Text Muting", options=["Normal", "Muted (Gray)"], group=grp_display)

// --- Color & Position Logic ---
var position = position.top_right
if table_pos == "Top Left"
    position := position.top_left
else if table_pos == "Bottom Right"
    position := position.bottom_right
else if table_pos == "Bottom Left"
    position := position.bottom_left
else if table_pos == "Center Right"
    position := position.middle_right
else if table_pos == "Center Left"
    position := position.middle_left

// Handle muted text style
color header_text_color = text_style == "Muted (Gray)" ? color.rgb(180, 180, 180) : color.white
color row_text_color    = text_style == "Muted (Gray)" ? color.rgb(140, 140, 140) : color.rgb(220, 220, 220)
color header_bg_color   = text_style == "Muted (Gray)" ? color.rgb(60, 60, 60, 40) : color.rgb(40, 40, 50, 10)
color row_bg_color      = text_style == "Muted (Gray)" ? color.rgb(45, 45, 45, 40) : color.rgb(30, 30, 35, 20)

// --- Draw Table ---
var table cheat_sheet = na

// Only create and render the table if enabled
if show_table
    // Initialize a 4-column, 5-row table
    cheat_sheet := table.new(position=position, columns=4, rows=5, border_color=color.rgb(100, 100, 100, 50), border_width=1)
    
    if barstate.islast
        // Row 0: Headers
        table.cell(cheat_sheet, 0, 0, "Strategy",            bgcolor=header_bg_color, text_color=header_text_color, text_size=size.small)
        table.cell(cheat_sheet, 1, 0, "Buy",                 bgcolor=header_bg_color, text_color=header_text_color, text_size=size.small)
        table.cell(cheat_sheet, 2, 0, "Sell",                bgcolor=header_bg_color, text_color=header_text_color, text_size=size.small)
        table.cell(cheat_sheet, 3, 0, "Move", bgcolor=header_bg_color, text_color=header_text_color, text_size=size.small)
        
        // Row 1: Call Debit
        table.cell(cheat_sheet, 0, 1, "Call Debit",          bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 1, 1, "Smaller $",  bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 2, 1, "Larger $",   bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 3, 1, "Up",                bgcolor=row_bg_color, text_color=text_style == "Muted (Gray)" ? row_text_color : color.green, text_size=size.small)
        
        // Row 2: Put Debit
        table.cell(cheat_sheet, 0, 2, "Put Debit",           bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 1, 2, "Larger $",   bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 2, 2, "Smaller $",  bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 3, 2, "Down",              bgcolor=row_bg_color, text_color=text_style == "Muted (Gray)" ? row_text_color : color.red, text_size=size.small)
        
        // Row 3: Call Credit
        table.cell(cheat_sheet, 0, 3, "Call Credit",         bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 1, 3, "Larger $",   bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 2, 3, "Smaller $",  bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 3, 3, "Down",              bgcolor=row_bg_color, text_color=text_style == "Muted (Gray)" ? row_text_color : color.red, text_size=size.small)
        
        // Row 4: Put Credit
        table.cell(cheat_sheet, 0, 4, "Put Credit",          bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 1, 4, "Smaller $",  bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 2, 4, "Larger $",   bgcolor=row_bg_color, text_color=row_text_color, text_size=size.small)
        table.cell(cheat_sheet, 3, 4, "Up",                bgcolor=row_bg_color, text_color=text_style == "Muted (Gray)" ? row_text_color : color.green, text_size=size.small)
````
