# Previous Day & Week OHLC

- url: https://www.tradingview.com/script/ghriZ4XS-Previous-Day-Week-OHLC/
- type: indicator
- pine_id: PUB;a1f4fa0fef2a41f1bd3cf623d692dc07
- version: 1.0

## Description

This indicator automatically plots key daily and weekly reference levels on your chart, helping traders identify potential support, resistance, liquidity zones and breakout areas.

[b]Plotted Levels[/b]

[list]
[*] [b]PDH[/b] - Previous Day High
[*] [b]PDL[/b] – Previous Day Low
[*] [b]PDC[/b] – Previous Day Close
[*] [b]DO[/b] – Current Day Open
[*] [b]PWH[/b] – Previous Week High
[*] [b]PWL[/b] – Previous Week Low
[/list]

[b]Features[/b]

[list]
[*] [b]Automatic Daily & Weekly Level Plotting [/b]- Levels update automatically as new sessions begin.
[*] [b]Smart Label Overlap Protection[/b] - When multiple levels share the same price, labels are automatically offset to prevent overlapping while maintaining readability.
[*] [b]Preserved Color Identification[/b] - Each level retains its individual color, making it easy to distinguish between daily and weekly references.
[*] [b]Historical Levels Option [/b]- Display only the current session's levels or keep previous levels visible for historical analysis and backtesting.
[*] [b]Fully Customizable Appearance[/b] - Adjust colors, line styles, line widths, label sizes and label positions to match your preferred chart layout.
[/list]

## Source Code

````pine
//@version=6
indicator("Previous Day & Week OHLC", overlay = true, max_lines_count = 500)

// ==========================================
// INPUTS
// ==========================================
// Daily Levels Group
grp_daily   = "Daily Levels"
show_daily  = input.bool(true, "Show Daily (PDH/PDL/PDC)", group=grp_daily)
pdh_color   = input.color(#00897b, "PDH Color", group=grp_daily)
pdl_color   = input.color(#f23645, "PDL Color", group=grp_daily)
pdc_color   = input.color(#787b86, "PDC Color", group=grp_daily)
show_do     = input.bool(true, "Show Daily Open (DO)", group=grp_daily)
do_color    = input.color(#2196f3, "DO Color", group=grp_daily)

// Weekly Levels Group
grp_weekly  = "Weekly Levels"
show_weekly = input.bool(true, "Show Weekly (PWH/PWL)", group=grp_weekly)
pwh_color   = input.color(#9c27b0, "PWH Color", group=grp_weekly)
pwl_color   = input.color(#9c27b0, "PWL Color", group=grp_weekly)

// Visuals Group (Lines & Styles)
grp_style   = "Line Visuals"
line_width  = input.int(2, "Line Width", minval=1, group=grp_style)
line_style  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_style)

// Label Settings Group
grp_labels  = "Label Settings"
show_labels = input.bool(true, "Show Labels", group=grp_labels)
show_price  = input.bool(true, "Include Price Value", group=grp_labels)
price_today = input.bool(true, "Price Only on Today's Levels", group=grp_labels)
lbl_size    = input.string("Normal", "Label Size", options=["Small", "Normal", "Large"], group=grp_labels)
lbl_pos     = input.string("Left (Start)", "Label Position", options=["Left (Start)", "Right (Dynamic)"], group=grp_labels)

// Historical Logic Group
grp_logic   = "Historical Data Settings"
show_hist   = input.bool(false, "Show Historical Levels", group=grp_logic)

// ==========================================
// DATA FETCHING
// ==========================================
[pdh, pdl, pdc, do_val] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1], open], lookahead = barmerge.lookahead_on)
[pwh, pwl]              = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)

// ==========================================
// STORAGE & HELPERS
// ==========================================
var line[]  all_lines  = array.new_line()
var label[] all_labs   = array.new_label()
var float[] all_prices = array.new_float()
var string[] all_names = array.new_string()

// Helper: Get Line Style
get_line_style(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// Helper: Get Label Size
get_lbl_size(s) =>
    s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

// Helper: Multiplier for vertical offset
get_offset_multiplier(s) =>
    s == "Small" ? 18 : s == "Normal" ? 26 : 34

// Function: Core Level Creation
create_level(price, name, col) =>
    l = line.new(bar_index, price, bar_index, price, color=col, width=line_width, style=get_line_style(line_style))
    array.push(all_lines, l)
    
    if show_labels
        style = lbl_pos == "Left (Start)" ? label.style_label_right : label.style_label_left
        lb = label.new(bar_index, price, name, style=style, textcolor=col, color=color.new(color.white, 100), size=get_lbl_size(lbl_size))
        array.push(all_labs, lb)
        array.push(all_prices, price)
        array.push(all_names, name)

// ==========================================
// MAIN LOGIC
// ==========================================
bool is_new_day = ta.change(time("D")) != 0

if is_new_day
    // Clean history if disabled
    if not show_hist and array.size(all_lines) > 0
        for i = 0 to array.size(all_lines) - 1
            line.delete(array.get(all_lines, i))
            if show_labels
                label.delete(array.get(all_labs, i))
        array.clear(all_lines)
        array.clear(all_labs)
        array.clear(all_prices)
        array.clear(all_names)

    // Daily Levels
    if show_daily
        create_level(pdh, "PDH", pdh_color)
        create_level(pdl, "PDL", pdl_color)
        create_level(pdc, "PDC", pdc_color)
    
    // Daily Open
    if show_do
        create_level(do_val, "DO", do_color)
    
    // Weekly Levels
    if show_weekly
        create_level(pwh, "PWH", pwh_color)
        create_level(pwl, "PWL", pwl_color)

// ==========================================
// DYNAMIC UPDATE
// ==========================================
if array.size(all_lines) > 0
    levels_per_session = (show_daily ? 3 : 0) + (show_do ? 1 : 0) + (show_weekly ? 2 : 0)
    total_count        = array.size(all_lines)

    // Reset label Y positions and update base texts first
    for i = 0 to total_count - 1
        bool is_current = (i >= total_count - levels_per_session)
        val = array.get(all_prices, i)
        
        // Extend and Move Current Levels
        if is_current
            line.set_x2(array.get(all_lines, i), bar_index)
            if show_labels and lbl_pos == "Right (Dynamic)"
                label.set_x(array.get(all_labs, i), bar_index)

        if show_labels
            lbl = array.get(all_labs, i)
            txt = array.get(all_names, i)
            
            // Return label to its original price before collision handling
            label.set_y(lbl, val)
            
            string display_text = txt
            if show_price and (not price_today or is_current)
                display_text := txt + " (" + str.tostring(val, format.mintick) + ")"
            
            if label.get_text(lbl) != display_text
                label.set_text(lbl, display_text)

    // --- Overlap Detection & Spacing Logic ---
    if show_labels and total_count > 1
        float shift_amount = syminfo.mintick * get_offset_multiplier(lbl_size)

        for i = 0 to total_count - 1
            lbl_i = array.get(all_labs, i)
            x_i   = label.get_x(lbl_i)
            p_i   = array.get(all_prices, i)
            
            int collision_count = 0
            
            for j = 0 to i
                if j == i
                    break
                lbl_j = array.get(all_labs, j)
                x_j   = label.get_x(lbl_j)
                p_j   = array.get(all_prices, j)
                
                if x_i == x_j and p_i == p_j
                    collision_count += 1
            
            // If there is a collision, shift the current label upwards
            if collision_count > 0
                label.set_y(lbl_i, p_i + (shift_amount * collision_count))
````
