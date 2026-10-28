# Auto Multi-TF Touchpoint Levels

- url: https://www.tradingview.com/script/lTq9JfHC-Auto-Multi-TF-Touchpoint-Levels/
- type: indicator
- pine_id: PUB;bc2d9a7e8703423dbfc60872c20d426c
- version: 1.0

## Description

Auto Multi-TF Touchpoint & S/R Levels is a robust, highly customizable indicator designed to automatically plot key support and resistance levels across multiple timeframes directly onto your active chart.

​Inspired by structural price action and touchpoint analysis, this script eliminates the manual labor of drawing horizontal lines by automatically calculating the previous period's highs and lows for various timeframes—capturing the exact zones where price frequently reacts and consolidates.

​Key Features

​Multi-Timeframe Support: Seamlessly toggle and track levels from intraday to macro timeframes, including 5m, 10m, 15m, 30m, 1h, 4h, Daily (1D), and Weekly (1W).
​Granular Customization: Full control over your visual workspace. Tailor each timeframe's aesthetic independently with user-defined options for:
​Color Pickers (with adjustable opacity/transparency)
​Line Styles (Solid, Dashed, or Dotted)
​Line Thickness / Width (1 to 5)
​Clean Chart Management: Dynamically updates and extends lines right to the edge of the chart (extend.right), keeping your workspace organized without cluttering past candles.
​How to Use

​Add the indicator to any chart (optimized for indices, forex, and crypto).
​Open the Settings menu to enable/disable the specific timeframes you trade.
​Use the Visuals & Colors and Line Styles & Thickness tabs to color-code your levels (e.g., distinct colors for intraday vs. macro weekly zones) to align with your personal trading strategy.
​Tip: Perfect for day traders and swing traders looking to automate structural reference points on indices like the Nasdaq/US100 or other popular instruments.

## Source Code

````pine
//@version=6
indicator("Auto Multi-TF Touchpoint Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
grp_settings = "Level Settings"
grp_visuals  = "Visuals & Colors"
grp_styles   = "Line Styles & Thickness"

// Timeframe Toggles
use_5m  = input.bool(true, "Show 5-Minute Levels",  group=grp_settings)
use_10m = input.bool(false, "Show 10-Minute Levels", group=grp_settings)
use_15m = input.bool(true, "Show 15-Minute Levels", group=grp_settings)
use_30m = input.bool(false, "Show 30-Minute Levels", group=grp_settings)
use_1h  = input.bool(true, "Show 1-Hour Levels",  group=grp_settings)
use_4h  = input.bool(false, "Show 4-Hour Levels",  group=grp_settings)
use_1d  = input.bool(true, "Show Daily Levels",   group=grp_settings)
use_1w  = input.bool(true, "Show Weekly Levels",  group=grp_settings)

// Colors
col_5m  = input.color(color.new(color.blue, 50),   "5-Minute Color",   group=grp_visuals)
col_10m = input.color(color.new(color.teal, 50),   "10-Minute Color",  group=grp_visuals)
col_15m = input.color(color.new(color.green, 50),  "15-Minute Color",  group=grp_visuals)
col_30m = input.color(color.new(color.lime, 50),   "30-Minute Color",  group=grp_visuals)
col_1h  = input.color(color.new(color.orange, 50), "1-Hour Color",     group=grp_visuals)
col_4h  = input.color(color.new(color.red, 50),    "4-Hour Color",     group=grp_visuals)
col_1d  = input.color(color.new(color.purple, 50), "Daily Color",      group=grp_visuals)
col_1w  = input.color(color.new(color.maroon, 50), "Weekly Color",     group=grp_visuals)

// Line Styles (Solid, Dashed, Dotted)
style_5m  = input.string("Dashed", "5-Minute Style",  options=["Solid", "Dashed", "Dotted"], group=grp_styles)
style_10m = input.string("Dashed", "10-Minute Style", options=["Solid", "Dashed", "Dotted"], group=grp_styles)
style_15m = input.string("Dashed", "15-Minute Style", options=["Solid", "Dashed", "Dotted"], group=grp_styles)
style_30m = input.string("Dashed", "30-Minute Style", options=["Solid", "Dashed", "Dotted"], group=grp_styles)
style_1h  = input.string("Solid",  "1-Hour Style",    options=["Solid", "Dashed", "Dotted"], group=grp_styles)
style_4h  = input.string("Solid",  "4-Hour Style",    options=["Solid", "Dashed", "Dotted"], group=grp_styles)
style_1d  = input.string("Solid",  "Daily Style",     options=["Solid", "Dashed", "Dotted"], group=grp_styles)
style_1w  = input.string("Solid",  "Weekly Style",    options=["Solid", "Dashed", "Dotted"], group=grp_styles)

// Line Thickness (Width 1 to 5)
thick_5m  = input.int(1, "5-Minute Thickness",  minval=1, maxval=5, group=grp_styles)
thick_10m = input.int(1, "10-Minute Thickness", minval=1, maxval=5, group=grp_styles)
thick_15m = input.int(2, "15-Minute Thickness", minval=1, maxval=5, group=grp_styles)
thick_30m = input.int(2, "30-Minute Thickness", minval=1, maxval=5, group=grp_styles)
thick_1h  = input.int(2, "1-Hour Thickness",    minval=1, maxval=5, group=grp_styles)
thick_4h  = input.int(3, "4-Hour Thickness",    minval=1, maxval=5, group=grp_styles)
thick_1d  = input.int(3, "Daily Thickness",     minval=1, maxval=5, group=grp_styles)
thick_1w  = input.int(4, "Weekly Thickness",    minval=1, maxval=5, group=grp_styles)

// --- Helper Function to Convert Style String to Pine Script Constant ---
f_get_style(style_str) =>
    val = style_str == "Solid" ? line.style_solid : style_str == "Dashed" ? line.style_dashed : line.style_dotted
    val

// --- Function to Calculate Levels ---
f_get_levels(tf) =>
    tf_high = request.security(syminfo.tickerid, tf, high)
    tf_low  = request.security(syminfo.tickerid, tf, low)
    
    t_change = ta.change(time(tf))
    is_new_period = not na(t_change) and t_change != 0

    var float level_h_1 = na
    var float level_h_2 = na
    var float level_l_1 = na
    var float level_l_2 = na

    if is_new_period
        level_h_2 := level_h_1
        level_l_2 := level_l_1
        level_h_1 := tf_high[1]
        level_l_1 := tf_low[1]

    [level_h_1, level_h_2, level_l_1, level_l_2]

// --- Main Calculation ---
[h5_1, h5_2, l5_1, l5_2]       = f_get_levels("5")
[h10_1, h10_2, l10_1, l10_2]   = f_get_levels("10")
[h15_1, h15_2, l15_1, l15_2]   = f_get_levels("15")
[h30_1, h30_2, l30_1, l30_2]   = f_get_levels("30")
[h60_1, h60_2, l60_1, l60_2]   = f_get_levels("60")
[h240_1, h240_2, l240_1, l240_2] = f_get_levels("240")
[hd_1, hd_2, ld_1, ld_2]       = f_get_levels("D")
[hw_1, hw_2, lw_1, lw_2]       = f_get_levels("W")

// --- Function to Draw Lines ---
f_draw_level(level, line_color, line_style_str, line_width) =>
    if not na(level)
        var line level_line = na
        line.delete(level_line)
        l_style = f_get_style(line_style_str)
        level_line := line.new(bar_index - 1, level, bar_index, level, color=line_color, style=l_style, width=line_width, extend=extend.right, force_overlay=true)

// --- Drawing Logic ---
if barstate.islast
    if use_5m
        f_draw_level(h5_1, col_5m, style_5m, thick_5m)
        f_draw_level(h5_2, col_5m, style_5m, thick_5m)
        f_draw_level(l5_1, col_5m, style_5m, thick_5m)
        f_draw_level(l5_2, col_5m, style_5m, thick_5m)

    if use_10m
        f_draw_level(h10_1, col_10m, style_10m, thick_10m)
        f_draw_level(h10_2, col_10m, style_10m, thick_10m)
        f_draw_level(l10_1, col_10m, style_10m, thick_10m)
        f_draw_level(l10_2, col_10m, style_10m, thick_10m)

    if use_15m
        f_draw_level(h15_1, col_15m, style_15m, thick_15m)
        f_draw_level(h15_2, col_15m, style_15m, thick_15m)
        f_draw_level(l15_1, col_15m, style_15m, thick_15m)
        f_draw_level(l15_2, col_15m, style_15m, thick_15m)
        
    if use_30m
        f_draw_level(h30_1, col_30m, style_30m, thick_30m)
        f_draw_level(h30_2, col_30m, style_30m, thick_30m)
        f_draw_level(l30_1, col_30m, style_30m, thick_30m)
        f_draw_level(l30_2, col_30m, style_30m, thick_30m)

    if use_1h
        f_draw_level(h60_1, col_1h, style_1h, thick_1h)
        f_draw_level(h60_2, col_1h, style_1h, thick_1h)
        f_draw_level(l60_1, col_1h, style_1h, thick_1h)
        f_draw_level(l60_2, col_1h, style_1h, thick_1h)

    if use_4h
        f_draw_level(h240_1, col_4h, style_4h, thick_4h)
        f_draw_level(h240_2, col_4h, style_4h, thick_4h)
        f_draw_level(l240_1, col_4h, style_4h, thick_4h)
        f_draw_level(l240_2, col_4h, style_4h, thick_4h)

    if use_1d
        f_draw_level(hd_1, col_1d, style_1d, thick_1d)
        f_draw_level(hd_2, col_1d, style_1d, thick_1d)
        f_draw_level(ld_1, col_1d, style_1d, thick_1d)
        f_draw_level(ld_2, col_1d, style_1d, thick_1d)

    if use_1w
        f_draw_level(hw_1, col_1w, style_1w, thick_1w)
        f_draw_level(hw_2, col_1w, style_1w, thick_1w)
        f_draw_level(lw_1, col_1w, style_1w, thick_1w)
        f_draw_level(lw_2, col_1w, style_1w, thick_1w)
````
