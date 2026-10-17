# Trading Strategy - Follow The Plan

- url: https://www.tradingview.com/script/1IsrhaI8-Trading-Strategy-Follow-The-Plan/
- type: indicator
- pine_id: PUB;348389173a6c44dfb9d080c4ee5d4f95
- version: 3.0

## Description

"Trading Strategy - Follow The Plan" is a TradingView indicator specifically crafted for traders dedicated to adhering to a structured approach. It emphasizes the elimination of emotional decision-making by providing clear, actionable steps. This tool allows you to articulate and visually embed your trading strategy directly onto your charts, encompassing your entry plan, exit plan, and any additional notes crucial for maintaining focus and discipline. It's designed to aid in sustaining consistency in your trading executions, ensuring that you remain steadfastly aligned with your predetermined trading methodology.

[b]Features[/b]

1. Entry Plan: Allows traders to outline specific criteria for market entry. This could include conditions like divergences on multiple timeframes, specific pattern recognitions, or other entry triggers. The flexibility of this section caters to various trading styles and strategies.

2. Exit Plan: Dedicated to defining exit strategies, this section can include details on profit targets, stop-loss levels, or conditions for position reversal. It serves as a constant reminder of exit strategies during active trades.

3. Notes: A customizable space for traders to jot down essential rules, observations, or reminders. This section is particularly useful for reinforcing risk management practices and maintaining focus on broader trading goals.

4. Visibility Controls: Each section of the trading plan (Entry Plan, Exit Plan, Notes) can be toggled on or off, allowing traders to manage on-screen information and reduce chart clutter.

5. Layout Customization: Users can choose the placement of the trading plan on their chart, with options including Top Right, Top Left, Bottom Right, and Bottom Left. This caters to individual preferences and screen setups.

6. Appearance Customization: The indicator allows for adjustments in text and background colors, and text sizes for titles and content, enhancing readability and personal preference alignment.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JohannCoffee
// © Credit to david zak for original script "Simple Trading plan (by david zak)"
//@version=5
indicator("Trading Strategy - Follow The Plan", "Trading Plan", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=1000)

// Visibility Controls
show_entry_plan = input.bool(true, "Show Entry Plan")
show_exit_plan = input.bool(true, "Show Exit Plan")
show_notes = input.bool(true, "Show Notes")

// Layout Customization
layout_option = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

// Determine Table Position
var position_table = position.top_right // Default position
if layout_option == "Top Left"
    position_table := position.top_left
else if layout_option == "Bottom Right"
    position_table := position.bottom_right
else if layout_option == "Bottom Left"
    position_table := position.bottom_left
// No need for "Top Right" as it's the default

// Colors Section
colors_group = "Colors"
text_color_global = input.color((#797B86), "Text Color", group = colors_group)
bg_table_color  = input.color(#000000, "Table Background Color", group = colors_group)
bg_border_color  = input.color(color.new(#6b6b6b, 0), "Table Border Color", group = colors_group)

// Text Size Settings
title_text_size = input.string("Small", "Title Text Size", options = ["Small", "Normal", "Large"], group = "Title Text Size")
text_box_text_size = input.string("Normal", "Text Box Text Size", options = ["Small", "Normal", "Large"], group = "Text Box Text Size")

// Define Text Sizes
var h1_size = size.huge // Big title
var h2_size = size.large // Titles
var h3_size = size.normal // Text
var h4_size = size.small // Footer

// Adjust Title Text Size
h2_size := switch title_text_size
    "Large" => size.huge
    "Normal" => size.large
    "Small" => size.normal

// Adjust Text Box Text Size
h3_size := switch text_box_text_size
    "Large" => size.large
    "Normal" => size.normal
    "Small" => size.small

// Entry Plan Section
entry_sequence_group = "Entry Sequence"
entry_sequence_title = input.string("---- Entry Plan ----", "Title", group = entry_sequence_group)
entry_sequence_info = input.text_area("1. Forming divs: 4h, 1h, 45m\n2. Execution divs: 36m, 24m, 12m", "Entry Plan", group = entry_sequence_group)

// Exit Plan Section
exit_plan_group = "Exit Plan"
exit_plan_title = input.string("----- Exit Plan -----", "Title", group = exit_plan_group)
exit_plan_info = input.text_area("1. Key Levels\n2. Reversal div on 12/24/36m", "Exit Plan", group = exit_plan_group)

// Notes Section
notes_group = "Notes"
notes_title = input.string("---- Notes ----", "Title", group = notes_group)
notes_info = input.text_area("1. Wait for key levels\n2. Follow the trend\n3. No kamikaze trading\n4. Risk Management.", "Notes", group = notes_group)

// Table Initialization
var maTable = table.new(
     position=position_table, columns=2, rows=21, bgcolor=bg_table_color, 
     frame_color=bg_border_color, frame_width=1, border_width=3)

// Displaying Sections
if barstate.islast
    Cell = 0
    // Entry Plan
    if show_entry_plan
        table.cell(maTable, 0, Cell, text = entry_sequence_title, text_color = text_color_global, text_size = h2_size)
        table.merge_cells(maTable, 0, Cell, 1, Cell)
        Cell += 1
        table.cell(maTable, 0, Cell, text = entry_sequence_info, text_size = h3_size, text_color = text_color_global)
        table.merge_cells(maTable, 0, Cell, 1, Cell)
        Cell += 1

    // Exit Plan
    if show_exit_plan
        table.cell(maTable, 0, Cell, text = exit_plan_title, text_color = text_color_global, text_size = h2_size)
        table.merge_cells(maTable, 0, Cell, 1, Cell)
        Cell += 1
        table.cell(maTable, 0, Cell, text = exit_plan_info, text_size = h3_size, text_color = text_color_global)
        table.merge_cells(maTable, 0, Cell, 1, Cell)
        Cell += 1

    // Notes
    if show_notes
        table.cell(maTable, 0, Cell, text = notes_title, text_color = text_color_global, text_size = h2_size)
        table.merge_cells(maTable, 0, Cell, 1, Cell)
        Cell += 1
        table.cell(maTable, 0, Cell, text = notes_info, text_size = h3_size, text_color = text_color_global)
        table.merge_cells(maTable, 0, Cell, 1, Cell)
````
