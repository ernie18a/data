# Noctis Parallel Geometry [JOAT]

- url: https://www.tradingview.com/script/5Bn5DWkP-Noctis-Parallel-Geometry-JOAT/
- type: indicator
- pine_id: PUB;be01157dbc664dd7b59868fbbdaa7ea9
- version: 1.0

## Description

[b]Noctis Parallel Geometry [JOAT][/b]

[b]Introduction[/b]

Noctis Parallel Geometry is an open-source channel-construction and ratio-lattice overlay designed to organize price into ascending or descending parallel structures built from confirmed pivots. It maps primary boundaries, internal levels, stretch lines, and dynamic tracking projections so the user can see where price is moving inside a broader geometric framework.

The problem this script solves is inconsistent channel drawing. Manually drawn channels vary from user to user, and many automatic channel tools do not show how the geometry was constructed or how price is behaving inside it after the channel is established. Noctis Parallel Geometry turns confirmed pivot relationships into a persistent structure with historical roll-forward behavior.

[b]Core Concepts[/b]

[b]1. Pivot-Driven Channel Construction[/b]
Ascending geometry is built from two confirmed pivot lows plus the opposing pivot high that defines channel height. Descending geometry is built from two confirmed pivot highs plus the opposing pivot low. This creates a parallel structure rather than a freehand trendline.

[b]2. Ratio Lattice[/b]
Once the main channel is built, the script can add internal reference levels and stretch levels. These help the user see whether price is rotating around the midline, respecting inner rails, or pushing into extended geometry.

[b]3. Historical Channel Preservation[/b]
When a new active geometry forms, the previous one can be rolled into history instead of being deleted. Historical channels are shifted and preserved so the user can study how prior geometry resolved.

[b]4. Dynamic Projection Tracking[/b]
The script can project a live tracking geometry from the most recent active pivot anchor and evolving extreme. This provides a developing path while the full next confirmed channel is still incomplete.

[b]Features[/b]

[list]
[*][b]Ascending and descending channel construction:[/b] Built from confirmed pivot relationships
[*][b]Primary channel rails:[/b] Base and top boundaries
[*][b]Inner ratio levels:[/b] Optional internal guidance lines
[*][b]Stretch levels:[/b] Optional extension rails beyond the main channel
[*][b]Historical geometry retention:[/b] Previous channels can remain on-chart
[*][b]Dynamic tracking projection:[/b] Live provisional geometry based on current extremes
[*][b]Pivot tags:[/b] Optional pivot markers for transparency
[*][b]Dashboard:[/b] Displays active geometry mode and structural information
[/list]

[b]Input Parameters[/b]

[b]Channel Engine:[/b]
[list]
[*]Pivot Length
[*]Extend Active Geometry
[*]Show Historical Geometry
[*]Historical Channel Count
[*]Show Dynamic Projection
[/list]

[b]Ratio Lattice And Display:[/b]
[list]
[*]Inner-level toggle
[*]Stretch-level toggle
[*]Historical projection offset
[*]Pivot-tag and dashboard toggles
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify whether the active geometry is ascending or descending.
[b]Step 2:[/b] Use the midline and inner rails to gauge whether price is rotating cleanly or losing internal balance.
[b]Step 3:[/b] Use stretch levels as warning areas where price is pushing beyond normal channel behavior.
[b]Step 4:[/b] Compare active geometry with preserved historical geometry to see whether the market is reusing or abandoning prior pathing.
[b]Step 5:[/b] Treat dynamic tracking as provisional context until a fully confirmed new channel is formed.

[b]Indicator Limitations[/b]

[list]
[*]Channels only update after pivot confirmation, so geometry changes are intentionally delayed to avoid repainting
[*]Fast regime changes can invalidate a channel before price spends much time respecting it
[*]Dynamic tracking lines are exploratory guidance, not confirmed structure
[*]This indicator describes geometry; it does not by itself determine direction or trade quality
[/list]

[b]Originality Statement[/b]

Noctis Parallel Geometry is original in how it turns confirmed pivot relationships into a parallel-channel engine with internal lattice levels, stretch rails, historical roll-forward geometry, and live tracking projection. These parts work together to create a coherent geometric framework rather than a simple trendline overlay.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Channel geometry can fail abruptly in volatile or event-driven conditions, so all analysis should be paired with appropriate risk controls.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Noctis Parallel Geometry [JOAT]", shorttitle="NPG [JOAT]", overlay=true, max_lines_count=500, max_labels_count=120)

//==============================================================================
// INPUTS
//==============================================================================
grp_channel = "Channel Engine"
pivot_length = input.int(18, "Pivot Length", minval=3, group=grp_channel)
extend_active = input.bool(true, "Extend Active Geometry", group=grp_channel)
show_history = input.bool(true, "Show Historical Geometry", group=grp_channel)
max_history_channels = input.int(4, "Historical Channel Count", minval=1, maxval=12, group=grp_channel)
show_tracking = input.bool(true, "Show Dynamic Projection", group=grp_channel)

grp_levels = "Ratio Lattice"
show_inner_levels = input.bool(true, "Show Inner Levels", group=grp_levels)
show_stretch_levels = input.bool(true, "Show Stretch Levels", group=grp_levels)
history_projection = input.int(-90, "Historical Projection Offset", minval=-250, maxval=250, group=grp_levels)

grp_visual = "Visuals"
show_pivot_tags = input.bool(false, "Show Pivot Tags", group=grp_visual)
show_dashboard = input.bool(true, "Show Dashboard", group=grp_visual)

//==============================================================================
// PALETTE
//==============================================================================
panel_bg = color.rgb(10, 16, 24)
panel_header = color.rgb(20, 29, 41)
panel_cell = color.rgb(16, 23, 34)
panel_grid = color.rgb(42, 57, 75)
text_main = color.rgb(228, 233, 241)
text_dim = color.rgb(144, 160, 178)

top_col = color.rgb(95, 147, 255)
mid_col = color.rgb(230, 182, 82)
base_col = color.rgb(0, 209, 147)
stretch_col = color.rgb(255, 101, 133)
track_col = color.rgb(166, 132, 255)

//==============================================================================
// STATE
//==============================================================================
var int high_a_bar = na
var float high_a_price = na
var int high_b_bar = na
var float high_b_price = na
var int low_a_bar = na
var float low_a_price = na
var int low_b_bar = na
var float low_b_price = na
var int opposite_bar = na
var float opposite_price = na

var array<line> active_lines = array.new<line>()
var array<line> tracking_lines = array.new<line>()
var array<line> history_lines = array.new<line>()

var float active_slope = na
var float active_height = na
var int active_direction = 0
var int active_start_bar = na
var string active_mode = "Idle"

var int track_extreme_bar = na
var float track_extreme_price = na

//==============================================================================
// PIVOTS
//==============================================================================
pivot_high = ta.pivothigh(high, pivot_length, pivot_length)
pivot_low = ta.pivotlow(low, pivot_length, pivot_length)

if not na(pivot_high)
    high_a_bar := high_b_bar
    high_a_price := high_b_price
    high_b_bar := bar_index[pivot_length]
    high_b_price := pivot_high
    opposite_bar := low_b_bar
    opposite_price := low_b_price
    track_extreme_bar := na
    track_extreme_price := na
    if show_pivot_tags
        label.new(bar_index[pivot_length], pivot_high, "PH", style=label.style_label_down, color=color.new(top_col, 8), textcolor=color.black, size=size.tiny)

if not na(pivot_low)
    low_a_bar := low_b_bar
    low_a_price := low_b_price
    low_b_bar := bar_index[pivot_length]
    low_b_price := pivot_low
    opposite_bar := high_b_bar
    opposite_price := high_b_price
    track_extreme_bar := na
    track_extreme_price := na
    if show_pivot_tags
        label.new(bar_index[pivot_length], pivot_low, "PL", style=label.style_label_up, color=color.new(base_col, 8), textcolor=color.black, size=size.tiny)

//==============================================================================
// CHANNEL BUILD HELPERS
//==============================================================================
f_clear_tracking() =>
    if array.size(tracking_lines) > 0
        for i = 0 to array.size(tracking_lines) - 1
            line.delete(array.get(tracking_lines, i))
        array.clear(tracking_lines)

f_roll_active_to_history() =>
    if array.size(active_lines) > 0
        int target_x = bar_index + history_projection
        for i = 0 to array.size(active_lines) - 1
            line current = array.get(active_lines, i)
            if show_history
                int x1 = line.get_x1(current)
                float y1 = line.get_y1(current)
                int x2 = line.get_x2(current)
                float y2 = line.get_y2(current)
                float slope = (y2 - y1) / math.max(x2 - x1, 1)
                float target_y = y1 + slope * (target_x - x1)
                line.set_x2(current, target_x)
                line.set_y2(current, target_y)
                line.set_extend(current, extend.none)
                array.push(history_lines, current)
            else
                line.delete(current)
        array.clear(active_lines)
        int allowed = max_history_channels * 7
        while array.size(history_lines) > allowed
            line old_line = array.shift(history_lines)
            line.delete(old_line)

f_draw_geometry(_left_bar_1, _left_price_1, _left_bar_2, _left_price_2, _anchor_bar, _anchor_price, _direction) =>
    f_roll_active_to_history()
    float slope = (_left_price_2 - _left_price_1) / math.max(_left_bar_2 - _left_bar_1, 1)
    float projected_on_anchor = _left_price_1 + slope * (_anchor_bar - _left_bar_1)
    float height = _direction == 1 ? _anchor_price - projected_on_anchor : projected_on_anchor - _anchor_price

    line upper_main = na
    line lower_main = na
    line inner_a = na
    line midline = na
    line inner_b = na
    line stretch_a = na
    line stretch_b = na

    if _direction == 1
        lower_main := line.new(_left_bar_1, _left_price_1, _left_bar_2, _left_price_2, color=base_col, width=2, extend=extend_active ? extend.right : extend.none)
        upper_main := line.new(_left_bar_1, _left_price_1 + height, _left_bar_2, _left_price_2 + height, color=top_col, width=2, extend=extend_active ? extend.right : extend.none)
        inner_a := line.new(_left_bar_1, _left_price_1 + height * 0.12, _left_bar_2, _left_price_2 + height * 0.12, color=color.new(base_col, 20), extend=extend_active ? extend.right : extend.none)
        midline := line.new(_left_bar_1, _left_price_1 + height * 0.50, _left_bar_2, _left_price_2 + height * 0.50, color=mid_col, extend=extend_active ? extend.right : extend.none)
        inner_b := line.new(_left_bar_1, _left_price_1 + height * 0.88, _left_bar_2, _left_price_2 + height * 0.88, color=color.new(top_col, 20), extend=extend_active ? extend.right : extend.none)
        stretch_a := line.new(_left_bar_1, _left_price_1 - height * 0.12, _left_bar_2, _left_price_2 - height * 0.12, color=color.new(stretch_col, 25), style=line.style_dashed, extend=extend_active ? extend.right : extend.none)
        stretch_b := line.new(_left_bar_1, _left_price_1 + height * 1.12, _left_bar_2, _left_price_2 + height * 1.12, color=color.new(stretch_col, 25), style=line.style_dashed, extend=extend_active ? extend.right : extend.none)
    else
        upper_main := line.new(_left_bar_1, _left_price_1, _left_bar_2, _left_price_2, color=top_col, width=2, extend=extend_active ? extend.right : extend.none)
        lower_main := line.new(_left_bar_1, _left_price_1 - height, _left_bar_2, _left_price_2 - height, color=base_col, width=2, extend=extend_active ? extend.right : extend.none)
        inner_a := line.new(_left_bar_1, _left_price_1 - height * 0.12, _left_bar_2, _left_price_2 - height * 0.12, color=color.new(top_col, 20), extend=extend_active ? extend.right : extend.none)
        midline := line.new(_left_bar_1, _left_price_1 - height * 0.50, _left_bar_2, _left_price_2 - height * 0.50, color=mid_col, extend=extend_active ? extend.right : extend.none)
        inner_b := line.new(_left_bar_1, _left_price_1 - height * 0.88, _left_bar_2, _left_price_2 - height * 0.88, color=color.new(base_col, 20), extend=extend_active ? extend.right : extend.none)
        stretch_a := line.new(_left_bar_1, _left_price_1 + height * 0.12, _left_bar_2, _left_price_2 + height * 0.12, color=color.new(stretch_col, 25), style=line.style_dashed, extend=extend_active ? extend.right : extend.none)
        stretch_b := line.new(_left_bar_1, _left_price_1 - height * 1.12, _left_bar_2, _left_price_2 - height * 1.12, color=color.new(stretch_col, 25), style=line.style_dashed, extend=extend_active ? extend.right : extend.none)

    array.push(active_lines, upper_main)
    array.push(active_lines, lower_main)
    if show_inner_levels
        array.push(active_lines, inner_a)
        array.push(active_lines, midline)
        array.push(active_lines, inner_b)
    else
        line.delete(inner_a)
        line.delete(midline)
        line.delete(inner_b)
    if show_stretch_levels
        array.push(active_lines, stretch_a)
        array.push(active_lines, stretch_b)
    else
        line.delete(stretch_a)
        line.delete(stretch_b)

    int geometry_start_bar = _direction == 1 ? low_a_bar : high_a_bar
    string geometry_mode = _direction == 1 ? "Ascending" : "Descending"
    [slope, height, _direction, geometry_start_bar, geometry_mode]

//==============================================================================
// CHANNEL CREATION
//==============================================================================
can_build_up = not na(low_a_bar) and not na(low_b_bar) and not na(high_b_bar) and high_b_bar > low_a_bar and high_b_bar < low_b_bar
can_build_down = not na(high_a_bar) and not na(high_b_bar) and not na(low_b_bar) and low_b_bar > high_a_bar and low_b_bar < high_b_bar

if not na(pivot_low) and can_build_up
    [new_slope, new_height, new_direction, new_start_bar, new_mode] = f_draw_geometry(low_a_bar, low_a_price, low_b_bar, low_b_price, high_b_bar, high_b_price, 1)
    active_slope := new_slope
    active_height := new_height
    active_direction := new_direction
    active_start_bar := new_start_bar
    active_mode := new_mode

if not na(pivot_high) and can_build_down
    [new_slope, new_height, new_direction, new_start_bar, new_mode] = f_draw_geometry(high_a_bar, high_a_price, high_b_bar, high_b_price, low_b_bar, low_b_price, -1)
    active_slope := new_slope
    active_height := new_height
    active_direction := new_direction
    active_start_bar := new_start_bar
    active_mode := new_mode

//==============================================================================
// DYNAMIC PROJECTION
//==============================================================================
f_clear_tracking()

if show_tracking and barstate.islast and array.size(active_lines) > 0 and active_direction != 0
    if active_direction == 1 and bar_index > low_b_bar
        if na(track_extreme_price) or low < track_extreme_price
            track_extreme_bar := bar_index
            track_extreme_price := low
        if not na(track_extreme_bar) and track_extreme_bar > low_b_bar
            float slope = (track_extreme_price - low_b_price) / math.max(track_extreme_bar - low_b_bar, 1)
            float projected = low_b_price + slope * (high_b_bar - low_b_bar)
            float height = high_b_price - projected
            line tl = line.new(low_b_bar, low_b_price, track_extreme_bar, track_extreme_price, color=color.new(track_col, 10), style=line.style_dashed, extend=extend.right)
            line tu = line.new(low_b_bar, low_b_price + height, track_extreme_bar, track_extreme_price + height, color=color.new(track_col, 10), style=line.style_dashed, extend=extend.right)
            array.push(tracking_lines, tl)
            array.push(tracking_lines, tu)
    if active_direction == -1 and bar_index > high_b_bar
        if na(track_extreme_price) or high > track_extreme_price
            track_extreme_bar := bar_index
            track_extreme_price := high
        if not na(track_extreme_bar) and track_extreme_bar > high_b_bar
            float slope = (track_extreme_price - high_b_price) / math.max(track_extreme_bar - high_b_bar, 1)
            float projected = high_b_price + slope * (low_b_bar - high_b_bar)
            float height = projected - low_b_price
            line tu = line.new(high_b_bar, high_b_price, track_extreme_bar, track_extreme_price, color=color.new(track_col, 10), style=line.style_dashed, extend=extend.right)
            line tl = line.new(high_b_bar, high_b_price - height, track_extreme_bar, track_extreme_price - height, color=color.new(track_col, 10), style=line.style_dashed, extend=extend.right)
            array.push(tracking_lines, tu)
            array.push(tracking_lines, tl)

//==============================================================================
// DASHBOARD
//==============================================================================
var table dash = table.new(position.top_right, 2, 6, bgcolor=panel_bg, border_width=1, border_color=panel_grid, frame_color=panel_grid, frame_width=1)

f_dash_row(_row, _label, _value, _color, _bg) =>
    table.cell(dash, 0, _row, _label, text_color=text_dim, bgcolor=_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, _row, _value, text_color=_color, bgcolor=_bg, text_size=size.small, text_halign=text.align_right)

if show_dashboard and barstate.islast
    color state_color = active_direction == 1 ? base_col : active_direction == -1 ? top_col : mid_col
    string slope_text = na(active_slope) ? "n/a" : str.tostring(active_slope, format.mintick)
    string height_text = na(active_height) ? "n/a" : str.tostring(active_height, format.mintick)
    string age_text = na(active_start_bar) ? "n/a" : str.tostring(bar_index - active_start_bar) + " bars"
    table.cell(dash, 0, 0, "NOCTIS GEOMETRY", text_color=text_main, bgcolor=panel_header, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, active_mode, text_color=state_color, bgcolor=panel_header, text_size=size.small, text_halign=text.align_right)
    f_dash_row(1, "Slope", slope_text, state_color, panel_cell)
    f_dash_row(2, "Channel Height", height_text, text_main, panel_bg)
    f_dash_row(3, "Age", age_text, text_main, panel_cell)
    f_dash_row(4, "History Lines", str.tostring(array.size(history_lines)), text_main, panel_bg)
    f_dash_row(5, "Projection", array.size(tracking_lines) > 0 ? "Live" : "Idle", array.size(tracking_lines) > 0 ? track_col : text_dim, panel_cell)

//==============================================================================
// ALERTS
//==============================================================================
alertcondition(not na(pivot_low) and can_build_up, "Ascending Geometry", "Noctis Parallel Geometry [JOAT] built a confirmed ascending channel on {{ticker}} {{interval}}.")
alertcondition(not na(pivot_high) and can_build_down, "Descending Geometry", "Noctis Parallel Geometry [JOAT] built a confirmed descending channel on {{ticker}} {{interval}}.")
````
