# HTF Power of Three @SafarTrades

- url: https://www.tradingview.com/script/fVI9OJf7-HTF-Power-of-Three-SafarTrades/
- type: indicator
- pine_id: PUB;6757417edb4448c68245b69c8ccd86e4
- version: 1.0

## Description

[b]HTF Power of Three[/b]

HTF Power of Three is a higher timeframe visualization framework designed to project a developing Daily, Weekly, or Monthly candle directly onto a lower timeframe chart.

The indicator is built around ICT's Power of Three (PO3) concept, allowing traders to monitor the current higher timeframe range and observe how price develops within that structure throughout the session.

Rather than repeatedly switching between execution and higher timeframes, traders can maintain awareness of the active higher timeframe candle while remaining focused on lower timeframe execution.

[image]https://www.tradingview.com/x/m1hPwN3z/[/image]

Many traders use the Daily, Weekly, or Monthly candle as a reference for directional bias, range analysis, and Power of Three development. However, viewing these structures traditionally requires frequent timeframe changes.

HTF Power of Three solves this by projecting the active higher timeframe candle directly onto the chart, allowing traders to continuously monitor:

• Current higher timeframe range

• Relative position of current price within that range

• Expansion of the active candle as new price data forms

• Potential accumulation, manipulation, and distribution development

• Higher timeframe context during lower timeframe execution

[b]Power of Three Framework[/b]

The indicator is designed to help traders visualize how price is developing inside the active higher timeframe range.

As the higher timeframe candle evolves, the projected structure updates in real time, allowing traders to monitor changes in range expansion, directional movement, and overall delivery without leaving the execution chart.

[image]https://www.tradingview.com/x/iVtJMGmW/[/image]

By maintaining visibility of the active higher timeframe candle, traders can better understand where current price is trading relative to the projected range and how the developing structure aligns with their market narrative.

[b]Higher Timeframe Reference Levels[/b]

The projected candle includes key higher timeframe reference points that help traders maintain context throughout the session.

Optional display elements include:

• Open

• High

• Low

• Current Close

• Range Information

• Price-Based Range Measurements

• Tick-Based Range Measurements

[image]https://www.tradingview.com/x/uP4jEs6d/[/image]

These references allow traders to quickly evaluate the state of the developing higher timeframe candle without requiring separate charts.

[b]Customization[/b]

The indicator includes extensive display controls allowing users to customize:

• Daily, Weekly, or Monthly projections

• Projection positioning and offset

• Bullish and bearish candle appearance

• Wick, border, and body styling

• OHLC label visibility

• Range table visibility

• Table positioning

• Range display format

• Daily calculation method options

[image]https://www.tradingview.com/x/1YrKFbMf/[/image]

[b]Intended Use
[/b]
HTF Power of Three is designed for traders who combine lower timeframe execution with higher timeframe narrative and range analysis.

By projecting the active Daily, Weekly, or Monthly candle directly onto the chart, the indicator provides continuous visibility of higher timeframe structure while reducing the need for constant timeframe switching.

## Source Code

````pine
//@version=6

// © 2026 SafarTrades
// All Rights Reserved
//
// This indicator is proprietary software.
// Unauthorized copying, redistribution,
// resale, modification, or republication
// is prohibited without written permission.

indicator("HTF Power of Three", shorttitle="HTF PO3", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =========================================================================
// 1. User Inputs & Configuration Groups
// =========================================================================

// PO3 Settings
grp_po3_settings = "PO3 SETTINGS"
tf_input = input.string("1 day", "Timeframe", options=["30 minutes", "45 minutes", "1 hour", "2 hours", "3 hours", "4 hours", "12 hours", "1 day", "1 week", "1 month", "3 months", "6 months", "12 months"], group=grp_po3_settings, tooltip="The Higher Timeframe (HTF) to calculate the Power of Three candle.")
use_ny = input.bool(true, "Use NY Midnight", group=grp_po3_settings, tooltip="If checked, calculations start at Midnight (00:00) New York Time. If unchecked, they use standard exchange session open times.")

// HTF PO3 Appearance
grp_appearance = "HTF PO3 APPEARANCE"
offset = input.int(10, "Offset", group=grp_appearance, tooltip="Offsets the HTF candle visualization to the right of the latest price action (in bars).")
bull_body_color = input.color(color.new(#089981, 0), "Bullish Body", inline="body_colors", group=grp_appearance)
bear_body_color = input.color(color.new(#000000, 0), "Bearish Body", inline="body_colors", group=grp_appearance)
bull_border_color = input.color(#000000, "Bullish Border", inline="border_colors", group=grp_appearance)
bear_border_color = input.color(#000000, "Bearish Border", inline="border_colors", group=grp_appearance)
bull_wick_color = input.color(#000000, "Bullish Wick", inline="wick_colors", group=grp_appearance)
bear_wick_color = input.color(#000000, "Bearish Wick", inline="wick_colors", group=grp_appearance)
wick_width      = input.int(1, "Wick Width", minval=1, group=grp_appearance, tooltip="Width of the HTF candle wick line.")

// LTF Projections (Live PO3)
grp_projections = "LTF PROJECTIONS (LIVE PO3)"
show_ohlc_labels = input.bool(true, "OHLC Price", inline="ohlc", group=grp_projections, tooltip="Shows price labels on the right side of the HTF candle drawing.")
ohlc_label_size  = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], inline="ohlc", group=grp_projections)

show_open_line   = input.bool(true, "Open Line", inline="open_proj", group=grp_projections, tooltip="Projects a horizontal line from the start of the HTF period at the Open price.")
open_line_color  = input.color(color.new(color.gray, 30), "Color", inline="open_proj", group=grp_projections)
open_line_width  = input.int(1, "Width", minval=1, inline="open_proj", group=grp_projections)
open_line_style  = input.string("Dashed", "Style", options=["Solid", "Dashed", "Dotted"], inline="open_proj", group=grp_projections)

show_lh_lines    = input.bool(true, "L/H Lines", inline="lh_proj", group=grp_projections, tooltip="Projects horizontal lines from the start of the HTF period at the High and Low prices.")
lh_line_color    = input.color(color.new(color.gray, 30), "Color", inline="lh_proj", group=grp_projections)
lh_line_width    = input.int(1, "Width", minval=1, inline="lh_proj", group=grp_projections)
lh_line_style    = input.string("Dashed", "Style", options=["Solid", "Dashed", "Dotted"], inline="lh_proj", group=grp_projections)

// PO3 Info Table
grp_table = "PO3 INFO TABLE"
show_info_table = input.bool(true, "Show Info Table", group=grp_table, tooltip="Show or hide the PO3 range dashboard table.")
range_unit = input.string("Price", "Range", options=["Price", "Ticks", "Percentage", "All"], group=grp_table, tooltip="Display format for the candle range dashboard.")
table_y = input.string("Middle", "Vertical Position", options=["Top", "Middle", "Bottom"], inline="tbl_pos", group=grp_table)
table_x = input.string("Right", "Horizontal Position", options=["Left", "Center", "Right"], inline="tbl_pos", group=grp_table)
table_bg_col = input.color(color.new(#e0e3eb, 0), "Label Color", inline="tbl_style", group=grp_table)
table_txt_col = input.color(#131722, "Text Color", inline="tbl_style", group=grp_table)
table_border_col = input.color(color.new(#959aab, 0), "Border Color", inline="tbl_style", group=grp_table)


// =========================================================================
// 2. Helper Functions
// =========================================================================

// Resolve label size options
f_get_lbl_size(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// Resolve line styles
f_get_line_style(string style_str) =>
    switch style_str
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Resolve table position
f_get_table_pos(string y_pos, string x_pos) =>
    y_pos == "Top" ? (x_pos == "Left" ? position.top_left : x_pos == "Center" ? position.top_center : position.top_right) : 
     y_pos == "Middle" ? (x_pos == "Left" ? position.middle_left : x_pos == "Center" ? position.middle_center : position.middle_right) : 
     (x_pos == "Left" ? position.bottom_left : x_pos == "Center" ? position.bottom_center : position.bottom_right)

// Parse chart timeframe to minutes
f_tf_to_minutes() =>
    int mult = timeframe.multiplier
    timeframe.isseconds ? 0 : 
     timeframe.isminutes ? mult : 
     timeframe.isdaily ? mult * 1440 : 
     timeframe.isweekly ? mult * 10080 : 
     timeframe.ismonthly ? mult * 43200 : 999999

// Format price using tick precision
f_format_price(float val) =>
    str.tostring(val)

// Format range metrics based on the selected display format
f_format_range(float price_val, float pct_val, float ticks_val, float pips_val, string unit_type) =>
    switch unit_type
        "Price"      => str.tostring(price_val, "#.##") + (na(syminfo.currency) ? "" : " " + syminfo.currency)
        "Ticks"      => str.tostring(ticks_val, "#") + " Ticks"
        "Percentage" => str.tostring(pct_val, "#.##") + "%"
        "Pips"       => str.tostring(pips_val, "#.#") + " Pips"
        "All"        => str.tostring(price_val, "#.##") + (na(syminfo.currency) ? "" : " " + syminfo.currency) + " (" + str.tostring(pct_val, "#.##") + "%)"
        => str.tostring(price_val, "#.##") + (na(syminfo.currency) ? "" : " " + syminfo.currency)

// Adjust color transparency safely
f_adjust_transparency(color col, float offset_val) =>
    color.new(col, math.min(100, math.max(0, math.round(color.t(col) + offset_val))))


// =========================================================================
// 3. Engine & Calculations
// =========================================================================

// Determine HTF timeframe details
tf_str = switch tf_input
    "30 minutes" => "30"
    "45 minutes" => "45"
    "1 hour"     => "60"
    "2 hours"    => "120"
    "3 hours"    => "180"
    "4 hours"    => "240"
    "12 hours"   => "720"
    "1 day"      => "D"
    "1 week"     => "W"
    "1 month"    => "M"
    "3 months"   => "3M"
    "6 months"   => "6M"
    "12 months"  => "12M"
    => "D"

htf_tf_in_minutes = switch tf_input
    "30 minutes" => 30
    "45 minutes" => 45
    "1 hour"     => 60
    "2 hours"    => 120
    "3 hours"    => 180
    "4 hours"    => 240
    "12 hours"   => 720
    "1 day"      => 1440
    "1 week"     => 10080
    "1 month"    => 43200
    "3 months"   => 129600
    "6 months"   => 259200
    "12 months"  => 518400
    => 1440

chart_tf_in_minutes = f_tf_to_minutes()

// Validate timeframe structure
is_valid_tf = chart_tf_in_minutes < htf_tf_in_minutes or chart_tf_in_minutes == 0

// Track period changes
var bool is_new_period = false
if is_valid_tf
    if use_ny
        is_new_period := switch tf_input
            "30 minutes" => ta.change(time("30", "America/New_York")) != 0
            "45 minutes" => ta.change(time("45", "America/New_York")) != 0
            "1 hour"     => ta.change(time("60", "America/New_York")) != 0
            "2 hours"    => ta.change(time("120", "America/New_York")) != 0
            "3 hours"    => ta.change(time("180", "America/New_York")) != 0
            "4 hours"    => ta.change(time("240", "America/New_York")) != 0
            "12 hours"   => ta.change(time("720", "America/New_York")) != 0
            "1 day"      => ta.change(dayofmonth(time, "America/New_York")) != 0
            "1 week"     => ta.change(weekofyear(time, "America/New_York")) != 0
            "1 month"    => ta.change(month(time, "America/New_York")) != 0
            "3 months"   => ta.change(month(time, "America/New_York")) != 0 and (month(time, "America/New_York") - 1) % 3 == 0
            "6 months"   => ta.change(month(time, "America/New_York")) != 0 and (month(time, "America/New_York") - 1) % 6 == 0
            "12 months"  => ta.change(month(time, "America/New_York")) != 0 and month(time, "America/New_York") == 1
            => ta.change(dayofmonth(time, "America/New_York")) != 0
    else
        is_new_period := ta.change(time(tf_str)) != 0

// Accumulate HTF candle metrics
var float htf_open = na
var float htf_high = na
var float htf_low = na
var float htf_close = na
var int htf_start_bar_index = na
var int htf_high_bar_index = na
var int htf_low_bar_index = na

if is_new_period or na(htf_open)
    htf_open := open
    htf_high := high
    htf_low := low
    htf_close := close
    htf_start_bar_index := bar_index
    htf_high_bar_index := bar_index
    htf_low_bar_index := bar_index
else
    if high > htf_high
        htf_high := high
        htf_high_bar_index := bar_index
    
    if low < htf_low
        htf_low := low
        htf_low_bar_index := bar_index
        
    htf_close := close

// =========================================================================
// 4. Drawings Engine (Live Candle & Projections)
// =========================================================================

// Visual configurations for the live candle
var box htf_body_box = na
var line htf_wick_line = na

var line open_proj_line = na
var line high_proj_line = na
var line low_proj_line = na

var label high_price_label = na
var label close_price_label = na
var label open_price_label = na
var label low_price_label = na

// Floating dashboard table
var table info_table = table.new(position=f_get_table_pos(table_y, table_x), columns=1, rows=2, bgcolor=color.new(color.black, 100), border_color=table_border_col, border_width=1)

if barstate.islast and is_valid_tf
    // Layout indices for future drawing coordinates
    candle_width = 6
    left_x = bar_index + offset
    right_x = left_x + candle_width
    middle_x = left_x + math.round(candle_width / 2)
    
    // Choose styling colors based on candle trend
    is_bullish = htf_close >= htf_open
    body_color   = is_bullish ? bull_body_color : bear_body_color
    border_color = is_bullish ? bull_border_color : bear_border_color
    wick_color   = is_bullish ? bull_wick_color : bear_wick_color
    
    // ---------------------------------------------------------------------
    // A. Draw Live Candle Body Box
    // ---------------------------------------------------------------------
    if na(htf_body_box)
        htf_body_box := box.new(
             left=left_x, top=math.max(htf_open, htf_close),
             right=right_x, bottom=math.min(htf_open, htf_close),
             xloc=xloc.bar_index,
             border_color=border_color, border_width=1, border_style=line.style_solid,
             bgcolor=body_color
             )
    else
        box.set_left(htf_body_box, left_x)
        box.set_right(htf_body_box, right_x)
        box.set_top(htf_body_box, math.max(htf_open, htf_close))
        box.set_bottom(htf_body_box, math.min(htf_open, htf_close))
        box.set_bgcolor(htf_body_box, body_color)
        box.set_border_color(htf_body_box, border_color)

    // ---------------------------------------------------------------------
    // B. Draw Live Candle Wick Line
    // ---------------------------------------------------------------------
    if na(htf_wick_line)
        htf_wick_line := line.new(
             x1=middle_x, y1=htf_high,
             x2=middle_x, y2=htf_low,
             xloc=xloc.bar_index,
             color=wick_color, width=wick_width, style=line.style_solid
             )
    else
        line.set_x1(htf_wick_line, middle_x)
        line.set_x2(htf_wick_line, middle_x)
        line.set_y1(htf_wick_line, htf_high)
        line.set_y2(htf_wick_line, htf_low)
        line.set_color(htf_wick_line, wick_color)
        line.set_width(htf_wick_line, wick_width)

    // ---------------------------------------------------------------------
    // C. Draw Open Price Horizontal Projection
    // ---------------------------------------------------------------------
    if show_open_line
        if na(open_proj_line)
            open_proj_line := line.new(
                 x1=htf_start_bar_index, y1=htf_open,
                 x2=right_x, y2=htf_open,
                 xloc=xloc.bar_index,
                 color=open_line_color, width=open_line_width, style=f_get_line_style(open_line_style)
                 )
        else
            line.set_x1(open_proj_line, htf_start_bar_index)
            line.set_x2(open_proj_line, right_x)
            line.set_y1(open_proj_line, htf_open)
            line.set_y2(open_proj_line, htf_open)
            line.set_color(open_proj_line, open_line_color)
            line.set_width(open_proj_line, open_line_width)
            line.set_style(open_proj_line, f_get_line_style(open_line_style))
    else
        if not na(open_proj_line)
            line.delete(open_proj_line)
            open_proj_line := na

    // ---------------------------------------------------------------------
    // D. Draw High/Low Horizontal Projections
    // ---------------------------------------------------------------------
    if show_lh_lines
        if na(high_proj_line)
            high_proj_line := line.new(
                 x1=htf_high_bar_index, y1=htf_high,
                 x2=right_x, y2=htf_high,
                 xloc=xloc.bar_index,
                 color=lh_line_color, width=lh_line_width, style=f_get_line_style(lh_line_style)
                 )
        else
            line.set_x1(high_proj_line, htf_high_bar_index)
            line.set_x2(high_proj_line, right_x)
            line.set_y1(high_proj_line, htf_high)
            line.set_y2(high_proj_line, htf_high)
            line.set_color(high_proj_line, lh_line_color)
            line.set_width(high_proj_line, lh_line_width)
            line.set_style(high_proj_line, f_get_line_style(lh_line_style))
            
        if na(low_proj_line)
            low_proj_line := line.new(
                 x1=htf_low_bar_index, y1=htf_low,
                 x2=right_x, y2=htf_low,
                 xloc=xloc.bar_index,
                 color=lh_line_color, width=lh_line_width, style=f_get_line_style(lh_line_style)
                 )
        else
            line.set_x1(low_proj_line, htf_low_bar_index)
            line.set_x2(low_proj_line, right_x)
            line.set_y1(low_proj_line, htf_low)
            line.set_y2(low_proj_line, htf_low)
            line.set_color(low_proj_line, lh_line_color)
            line.set_width(low_proj_line, lh_line_width)
            line.set_style(low_proj_line, f_get_line_style(lh_line_style))
    else
        if not na(high_proj_line)
            line.delete(high_proj_line)
            high_proj_line := na
        if not na(low_proj_line)
            line.delete(low_proj_line)
            low_proj_line := na

    // ---------------------------------------------------------------------
    // E. Draw OHLC Text Price Labels
    // ---------------------------------------------------------------------
    lbl_size = f_get_lbl_size(ohlc_label_size)
    label_txt_color = chart.fg_color
    
    if show_ohlc_labels
        // High Label
        if na(high_price_label)
            high_price_label := label.new(
                 x=right_x + 1, y=htf_high,
                 text=f_format_price(htf_high),
                 xloc=xloc.bar_index,
                 color=color.new(color.black, 100), textcolor=label_txt_color,
                 style=label.style_label_left, size=lbl_size
                 )
        else
            label.set_x(high_price_label, right_x + 1)
            label.set_y(high_price_label, htf_high)
            label.set_text(high_price_label, f_format_price(htf_high))
            label.set_textcolor(high_price_label, label_txt_color)
            label.set_size(high_price_label, lbl_size)
            
        // Close Label
        if na(close_price_label)
            close_price_label := label.new(
                 x=right_x + 1, y=htf_close,
                 text=f_format_price(htf_close),
                 xloc=xloc.bar_index,
                 color=color.new(color.black, 100), textcolor=label_txt_color,
                 style=label.style_label_left, size=lbl_size
                 )
        else
            label.set_x(close_price_label, right_x + 1)
            label.set_y(close_price_label, htf_close)
            label.set_text(close_price_label, f_format_price(htf_close))
            label.set_textcolor(close_price_label, label_txt_color)
            label.set_size(close_price_label, lbl_size)
            
        // Open Label
        if na(open_price_label)
            open_price_label := label.new(
                 x=right_x + 1, y=htf_open,
                 text=f_format_price(htf_open),
                 xloc=xloc.bar_index,
                 color=color.new(color.black, 100), textcolor=label_txt_color,
                 style=label.style_label_left, size=lbl_size
                 )
        else
            label.set_x(open_price_label, right_x + 1)
            label.set_y(open_price_label, htf_open)
            label.set_text(open_price_label, f_format_price(htf_open))
            label.set_textcolor(open_price_label, label_txt_color)
            label.set_size(open_price_label, lbl_size)
            
        // Low Label
        if na(low_price_label)
            low_price_label := label.new(
                 x=right_x + 1, y=htf_low,
                 text=f_format_price(htf_low),
                 xloc=xloc.bar_index,
                 color=color.new(color.black, 100), textcolor=label_txt_color,
                 style=label.style_label_left, size=lbl_size
                 )
        else
            label.set_x(low_price_label, right_x + 1)
            label.set_y(low_price_label, htf_low)
            label.set_text(low_price_label, f_format_price(htf_low))
            label.set_textcolor(low_price_label, label_txt_color)
            label.set_size(low_price_label, lbl_size)
    else
        if not na(high_price_label)
            label.delete(high_price_label)
            high_price_label := na
        if not na(close_price_label)
            label.delete(close_price_label)
            close_price_label := na
        if not na(open_price_label)
            label.delete(open_price_label)
            open_price_label := na
        if not na(low_price_label)
            label.delete(low_price_label)
            low_price_label := na

    // ---------------------------------------------------------------------
    // F. Display PO3 Range Dashboard Table
    // ---------------------------------------------------------------------
    // Title matching selected HTF
    tf_shortcode = switch tf_input
        "30 minutes" => "30m"
        "45 minutes" => "45m"
        "1 hour"     => "1H"
        "2 hours"    => "2H"
        "3 hours"    => "3H"
        "4 hours"    => "4H"
        "12 hours"   => "12H"
        "1 day"      => "1D"
        "1 week"     => "1W"
        "1 month"    => "1M"
        "3 months"   => "3M"
        "6 months"   => "6M"
        "12 months"  => "12M"
        => "D"
    header_title = tf_shortcode + " CANDLE PO3°"
    
    // Calculate range metric formats
    range_price = htf_high - htf_low
    range_pct = (range_price / htf_open) * 100
    range_ticks = range_price / syminfo.mintick
    
    // Custom FX Pips vs Ticks detection
    is_fx = syminfo.type == "forex"
    pip_size = is_fx ? (syminfo.mintick * 10) : syminfo.mintick
    range_pips = range_price / pip_size
    
    total_range_text = f_format_range(range_price, range_pct, range_ticks, range_pips, range_unit)

    // Row 0: Header and Row 1: Range
    if show_info_table
        table.set_border_color(info_table, table_border_col)
        table.cell(info_table, 0, 0, header_title, bgcolor=table_bg_col, text_color=table_txt_col, text_size=size.small, text_halign=text.align_center)
        table.cell(info_table, 0, 1, "Range: " + total_range_text, bgcolor=table_bg_col, text_color=table_txt_col, text_size=size.small, text_halign=text.align_center)
    else
        table.clear(info_table, 0, 0, 0, 1)
        table.set_border_color(info_table, color.new(color.black, 100))

// ---------------------------------------------------------------------
// G. Warning Check for Timeframe Mismatch
// ---------------------------------------------------------------------
var table warning_table = table.new(position=position.top_center, columns=1, rows=1)
if barstate.islast
    if not is_valid_tf
        table.cell(warning_table, 0, 0, "HTF PO3 Error: Chart timeframe must be lower than selected HTF timeframe (" + tf_input + ")", bgcolor=color.new(#ff1744, 20), text_color=#ff1744, text_size=size.normal, text_formatting=text.format_bold)
    else
        table.clear(warning_table, 0, 0)
````
