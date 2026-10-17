# Multi-Line Resistance/Support Creator Rev0

- url: https://www.tradingview.com/script/OXiv7Osa-Multi-Line-Resistance-Support-Creator-Rev0/
- type: indicator
- pine_id: PUB;dc64e822fbbc4e2eb5374b6d88112dee
- version: 1.0

## Description

[b]Overview:[/b]

Tired of manually drawing horizontal lines one by one every time you get a new list of key daily levels? The Multi-Line Support, Resistance & Control Creator is a utility script designed to instantly plot bulk price levels directly onto your chart.

Whether you copy your levels from a spreadsheet, a Discord chat, or an external volume profile tool, simply paste your raw text into the indicator settings, and the script will do the rest.

[b]Key Features:[/b]

Bulk Data Pasting: No need to format your text perfectly. The script features an intelligent parsing engine that accepts clean vertical columns (Excel/Notepad), comma-separated lists, or space-separated lists.

Three Distinct Zones: Organize your chart cleanly with three dedicated input boxes for Resistance (defaults to Red), Support (defaults to Green), and Control/Pivot levels (defaults to Blue). Colors are fully customizable.

Fractional Grain Pricing Support: Built specifically to handle cross-asset quoting. You can paste standard decimal formats (e.g., 450.25) alongside traditional CBOT grain fractional eighths (e.g., 460'2 or 460'6 for Corn, Wheat, or Soybeans), and the script will accurately calculate and plot them.

Infinite Extension & Clean Margins: Lines automatically extend infinitely across the screen. Price labels are cleanly pushed into the right margin so they never clutter or obscure your live candlestick data.

Global Styling: Instantly toggle all your lines between Dashed, Dotted, or Solid, adjust the line thickness (1-5), and toggle price labels on or off with a single click.

[b]How to Use:[/b]

Add the indicator to your chart and open the Settings menu.

Under the Resistance, Support, or Control sections, paste your raw price levels into the large text boxes.

Example inputs that work perfectly:
450.25, 455.00, 460.50 (Commas)
450.25 455.00 460.50 (Spaces)
Alternatively, just paste a straight vertical column of numbers directly from Excel.

Adjust your global line thickness and style at the bottom of the settings menu.

Who is this for?
This tool is perfect for day traders, supply/demand traders, and futures traders who rely on external levels (like daily pivots, standard deviations, or institutional order blocks) and want to load their charts in seconds before the market opens.

## Source Code

````pine
//@version=6
indicator("Multi-Line Resistance/Support Creator Rev0", overlay=true)
// Copyright: Mohd Asfa Asyari May 2026

// --- Inputs ---
var group_resist  = "Resistance Settings"
var group_support = "Support Settings"
var group_control = "Control Settings"
var group_style   = "Global Line Style"

// Resistance Inputs
resist_string = input.text_area("", "Paste Resistance Levels Here", tooltip="These will draw in Red", group=group_resist)
resist_color  = input.color(color.red, "Resistance Color", group=group_resist)

// Support Inputs
support_string = input.text_area("", "Paste Support Levels Here", tooltip="These will draw in Green", group=group_support)
support_color  = input.color(color.green, "Support Color", group=group_support)

// Control Inputs
control_string = input.text_area("", "Paste Control Levels Here", tooltip="These will draw in Blue", group=group_control)
control_color  = input.color(color.blue, "Control Color", group=group_control)

// Global Styling
line_style  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=group_style)
line_width  = input.int(1, "Line Thickness", minval=1, maxval=5, group=group_style)
show_labels = input.bool(true, "Show Price Labels?", group=group_style)

// --- Helper Functions ---
f_get_style(style_txt) =>
    style_txt == "Solid" ? line.style_solid : style_txt == "Dashed" ? line.style_dashed : line.style_dotted

f_clean_fractional(str_val) =>
    trimmed = str.trim(str_val)
    quote_idx = str.pos(trimmed, "'")
    if not na(quote_idx)
        int_str = str.substring(trimmed, 0, quote_idx)
        frac_str = str.substring(trimmed, quote_idx + 1)
        int_num = str.tonumber(int_str)
        frac_num = str.tonumber(frac_str)
        int_num + (frac_num / 8)
    else
        str.tonumber(trimmed)

// --- Arrays for Cleanup ---
var line[]  active_lines  = array.new<line>()
var label[] active_labels = array.new<label>()

// --- Core Drawing Function ---
// This processes any block of text and draws the corresponding color lines
f_process_levels(string levels_txt, color lvl_color) =>
    string[] raw_levels = array.new_string()
    string current_item = ""
    int str_len = str.length(levels_txt)
    
    // Manual text extraction for line breaks, spaces, and commas
    if str_len > 0
        for i = 0 to str_len - 1
            string char = str.substring(levels_txt, i, i + 1)
            if char == "," or char == " " or char == "\n" or char == "\r"
                if str.length(current_item) > 0
                    array.push(raw_levels, current_item)
                    current_item := ""
            else
                current_item := current_item + char
                
        if str.length(current_item) > 0
            array.push(raw_levels, current_item)

    // Execute the drawing
    int total_levels = array.size(raw_levels)
    if total_levels > 0
        for i = 0 to total_levels - 1
            string raw_val = array.get(raw_levels, i)
            float price_level = f_clean_fractional(raw_val)
            
            if not na(price_level)
                line new_line = line.new(
                  x1=bar_index - 1, y1=price_level, 
                  x2=bar_index, y2=price_level, 
                  color=lvl_color, 
                  style=f_get_style(line_style), 
                  width=line_width,
                  extend=extend.both
                 )
                array.push(active_lines, new_line)
                
                if show_labels
                    label new_lbl = label.new(
                      x=bar_index + 5, y=price_level, 
                      text=raw_val, 
                      style=label.style_label_left, 
                      textcolor=lvl_color, 
                      color=color.new(color.black, 100), 
                      size=size.small
                     )
                    array.push(active_labels, new_lbl)

// --- Main Execution ---
if barstate.islast
    // 1. Clean previous drawings on update
    if array.size(active_lines) > 0
        for i = 0 to array.size(active_lines) - 1
            line.delete(array.get(active_lines, i))
    if array.size(active_labels) > 0
        for i = 0 to array.size(active_labels) - 1
            label.delete(array.get(active_labels, i))
            
    array.clear(active_lines)
    array.clear(active_labels)

    // 2. Draw all three zones
    f_process_levels(resist_string, resist_color)
    f_process_levels(support_string, support_color)
    f_process_levels(control_string, control_color)
````
