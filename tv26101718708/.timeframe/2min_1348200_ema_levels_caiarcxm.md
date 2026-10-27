# 2min 13-48-200 EMA + Levels

- url: https://www.tradingview.com/script/CAiARcXM-2min-13-48-200-EMA-Levels/
- type: indicator
- pine_id: PUB;f4a51f4dbb9f4bcdbd3c25f82055fa43
- version: 1.0

## Description

Features:

- 13 + 48 + 200 ema lines, calculated from a specified time frame (2min as default) that doesn't change with timeframe (useful if you want to see 2min ema lines in a 5min time frame
- Colored zones to indicate relationship between ema's:
[quote]
  > Light Green + Dark Green = 13 ema above 48 ema above 200 ema = bullish
  > Light Red + Dark Red = 200 ema above 48 ema above 13 ema = bearish
  > Combination of red and green = possible reversal
[/quote]
- Level lines calculated from previous day + pre market highs and lows

Customizable settings:

- EMA lines colors and thickness
- EMA zone colors
- Level line color and thickness
- Ema label text and background colors

## Source Code

````pine
//@version=5
indicator("Multi-Timeframe EMAs with Levels", shorttitle="MTF EMAs", overlay=true, max_lines_count=500)

// Input for the fixed timeframe (default 2 minutes)
timeframe_input = input.timeframe("2", title="Fixed Timeframe")

// Input for EMA periods
ema13_period = input.int(13, title="EMA 13 Period", minval=1)
ema48_period = input.int(48, title="EMA 48 Period", minval=1)
ema200_period = input.int(200, title="EMA 200 Period", minval=1)

// Input for colors (all blue by default)
ema13_color = input.color(color.new(color.blue, 0), title="EMA 13 Color")
ema48_color = input.color(color.new(color.blue, 0), title="EMA 48 Color")
ema200_color = input.color(color.new(color.blue, 0), title="EMA 200 Color")

// Input for line widths (per-EMA: 13=1, 48=2, 200=3)
ema13_width  = input.int(1, title="EMA 13 Width",  minval=1, maxval=5)
ema48_width  = input.int(2, title="EMA 48 Width",  minval=1, maxval=5)
ema200_width = input.int(3, title="EMA 200 Width", minval=1, maxval=5)

// ============ EMA Colored Zones Inputs ============
show_ema_zones   = input.bool(true, title="Show EMA Colored Zones", group="EMA Zones")
zone_light_green = input.color(color.new(color.green, 80), title="Light Green (mild bullish)",   group="EMA Zones")
zone_dark_green  = input.color(color.new(color.green, 60), title="Dark Green (strong bullish)",  group="EMA Zones")
zone_light_red   = input.color(color.new(color.red,   80), title="Light Red (mild bearish)",     group="EMA Zones")
zone_dark_red    = input.color(color.new(color.red,   60), title="Dark Red (strong bearish)",    group="EMA Zones")

// Inputs for level drawing (all blue by default)
show_premarket = input.bool(true, title="Show Premarket High/Low")
show_prev_day = input.bool(true, title="Show Previous Day High/Low")
pm_high_color = input.color(color.new(color.blue, 0), title="Premarket High Color")
pm_low_color  = input.color(color.new(color.blue, 0), title="Premarket Low Color")
pd_high_color = input.color(color.new(color.blue, 0), title="Previous Day High Color")
pd_low_color  = input.color(color.new(color.blue, 0), title="Previous Day Low Color")
level_line_width = input.int(2, title="Level Line Width", minval=1, maxval=5)
level_style = input.string("Solid", title="Level Line Style", options=["Solid", "Dashed", "Dotted"])
use_abbreviated = input.bool(false, title="Use Abbreviated Labels")
show_label_background = input.bool(false, title="Show Label Background")
label_text_color_choice = input.string("Line Color", title="Label Text Color", options=["White", "Black", "Line Color"])

// Calculate EMAs from the fixed timeframe
ema13 = request.security(syminfo.tickerid, timeframe_input, ta.ema(close, ema13_period), gaps=barmerge.gaps_off)
ema48 = request.security(syminfo.tickerid, timeframe_input, ta.ema(close, ema48_period), gaps=barmerge.gaps_off)
ema200 = request.security(syminfo.tickerid, timeframe_input, ta.ema(close, ema200_period), gaps=barmerge.gaps_off)

// Plot the EMAs (assigned to plot IDs so fill() can reference them for zones)
p_ema13  = plot(ema13,  title="EMA 13",  color=ema13_color,  linewidth=ema13_width)
p_ema48  = plot(ema48,  title="EMA 48",  color=ema48_color,  linewidth=ema48_width)
p_ema200 = plot(ema200, title="EMA 200", color=ema200_color, linewidth=ema200_width)

// ============ EMA Colored Zones Logic ============
// Which EMA is positionally in the middle — that EMA's "outer" fill is hidden
ema13_is_middle  = (ema48  >= ema13  and ema13  >= ema200) or (ema200 >= ema13  and ema13  >= ema48)
ema48_is_middle  = (ema13  >= ema48  and ema48  >= ema200) or (ema200 >= ema48  and ema48  >= ema13)
ema200_is_middle = (ema13  >= ema200 and ema200 >= ema48)  or (ema48  >= ema200 and ema200 >= ema13)

transparent_zone = color.new(color.black, 100)

// fill(13,48): hidden when 200 sits between them
fill_13_48_color = (not show_ema_zones or ema200_is_middle) ? transparent_zone :
     ema13 >= ema48 ? zone_light_green : zone_light_red

// fill(48,200): hidden when 13 sits between them. Color depends on 48 vs 200 and where 13 is.
fill_48_200_color = (not show_ema_zones or ema13_is_middle) ? transparent_zone :
     ema48 >= ema200 ?
         (ema13 >= ema48  ? zone_dark_green : zone_light_red) :
         (ema13 >= ema200 ? zone_light_green : zone_dark_red)

// fill(13,200): hidden when 48 sits between them.
// When 13 is the middle EMA, the span is across two "gaps" of separation -> dark shade.
fill_13_200_color = (not show_ema_zones or ema48_is_middle) ? transparent_zone :
     ema13 >= ema200 ?
         (ema13_is_middle ? zone_dark_green : zone_light_green) :
         (ema13_is_middle ? zone_dark_red   : zone_light_red)

fill(p_ema13, p_ema48,  color=fill_13_48_color,  title="EMA 13-48 Zone")
fill(p_ema48, p_ema200, color=fill_48_200_color, title="EMA 48-200 Zone")
fill(p_ema13, p_ema200, color=fill_13_200_color, title="EMA 13-200 Zone")

// Session definitions
is_premarket = not na(time(timeframe_input, "0400-0930", "America/New_York"))
is_regular_session = not na(time(timeframe_input, "0930-1600", "America/New_York"))
is_new_day = ta.change(time("D"))

// Track premarket high/low
var float pm_high = na
var float pm_low = na
var int pm_high_bar = na
var int pm_low_bar = na
var bool pm_captured = false

// Track regular session high/low for previous day calculation
var float reg_session_high = na
var float reg_session_low = na
var int reg_session_high_bar = na
var int reg_session_low_bar = na
var bool reg_session_started = false

// Track previous day high/low (from regular hours only)
var float prev_day_high = na
var float prev_day_low = na
var int prev_day_high_bar = na
var int prev_day_low_bar = na

// Line and label objects
var line pm_high_line = na
var line pm_low_line = na
var line pd_high_line = na
var line pd_low_line = na

var label pm_high_label = na
var label pm_low_label = na
var label pd_high_label = na
var label pd_low_label = na

// Convert style input to line style
current_line_style = level_style == "Dashed" ? line.style_dashed : level_style == "Dotted" ? line.style_dotted : line.style_solid

// Function to get label text color based on user choice
get_label_text_color(line_color) =>
    label_text_color_choice == "Black" ? color.black : label_text_color_choice == "White" ? color.white : line_color

// Reset at start of new day
if is_new_day
    // Save previous day's regular session high/low
    if reg_session_started
        prev_day_high := reg_session_high
        prev_day_low := reg_session_low
        prev_day_high_bar := reg_session_high_bar
        prev_day_low_bar := reg_session_low_bar
    
    // Reset regular session tracking
    reg_session_high := na
    reg_session_low := na
    reg_session_high_bar := na
    reg_session_low_bar := na
    reg_session_started := false
    
    // Reset premarket tracking
    pm_high := na
    pm_low := na
    pm_high_bar := na
    pm_low_bar := na
    pm_captured := false

// Capture regular session high/low
if is_regular_session
    reg_session_started := true
    
    if na(reg_session_high) or high > reg_session_high
        reg_session_high := high
        reg_session_high_bar := bar_index
    
    if na(reg_session_low) or low < reg_session_low
        reg_session_low := low
        reg_session_low_bar := bar_index

// Capture premarket high/low
if is_premarket
    if na(pm_high) or high > pm_high
        pm_high := high
        pm_high_bar := bar_index
    if na(pm_low) or low < pm_low
        pm_low := low
        pm_low_bar := bar_index
    pm_captured := true

// Draw/update premarket high line
pm_high_valid = show_premarket and pm_captured and not na(pm_high) and not na(pm_high_bar)
if pm_high_valid
    line.delete(pm_high_line)
    label.delete(pm_high_label)
    
    pm_high_line := line.new(pm_high_bar, pm_high, bar_index, pm_high, color=pm_high_color, width=level_line_width, style=current_line_style)
    
    pm_high_text = use_abbreviated ? "PMH: " + str.tostring(pm_high) : "High - Pre Market: " + str.tostring(pm_high)
    label_bg_color = show_label_background ? pm_high_color : color.new(pm_high_color, 100)
    label_txt_color = get_label_text_color(pm_high_color)
    pm_high_label := label.new(bar_index, pm_high, text=pm_high_text, style=label.style_label_left, color=label_bg_color, textcolor=label_txt_color, size=size.small)

// Draw/update premarket low line
pm_low_valid = show_premarket and pm_captured and not na(pm_low) and not na(pm_low_bar)
if pm_low_valid
    line.delete(pm_low_line)
    label.delete(pm_low_label)
    
    pm_low_line := line.new(pm_low_bar, pm_low, bar_index, pm_low, color=pm_low_color, width=level_line_width, style=current_line_style)
    
    pm_low_text = use_abbreviated ? "PML: " + str.tostring(pm_low) : "Low - Pre Market: " + str.tostring(pm_low)
    label_bg_color = show_label_background ? pm_low_color : color.new(pm_low_color, 100)
    label_txt_color = get_label_text_color(pm_low_color)
    pm_low_label := label.new(bar_index, pm_low, text=pm_low_text, style=label.style_label_left, color=label_bg_color, textcolor=label_txt_color, size=size.small)

// Draw/update previous day high line
pd_high_valid = show_prev_day and not na(prev_day_high) and not na(prev_day_high_bar)
if pd_high_valid
    line.delete(pd_high_line)
    label.delete(pd_high_label)
    
    pd_high_line := line.new(prev_day_high_bar, prev_day_high, bar_index, prev_day_high, color=pd_high_color, width=level_line_width, style=current_line_style)
    
    pd_high_text = use_abbreviated ? "PDH: " + str.tostring(prev_day_high) : "High - Previous Day: " + str.tostring(prev_day_high)
    label_bg_color = show_label_background ? pd_high_color : color.new(pd_high_color, 100)
    label_txt_color = get_label_text_color(pd_high_color)
    pd_high_label := label.new(bar_index, prev_day_high, text=pd_high_text, style=label.style_label_left, color=label_bg_color, textcolor=label_txt_color, size=size.small)

// Draw/update previous day low line
pd_low_valid = show_prev_day and not na(prev_day_low) and not na(prev_day_low_bar)
if pd_low_valid
    line.delete(pd_low_line)
    label.delete(pd_low_label)
    
    pd_low_line := line.new(prev_day_low_bar, prev_day_low, bar_index, prev_day_low, color=pd_low_color, width=level_line_width, style=current_line_style)
    
    pd_low_text = use_abbreviated ? "PDL: " + str.tostring(prev_day_low) : "Low - Previous Day: " + str.tostring(prev_day_low)
    label_bg_color = show_label_background ? pd_low_color : color.new(pd_low_color, 100)
    label_txt_color = get_label_text_color(pd_low_color)
    pd_low_label := label.new(bar_index, prev_day_low, text=pd_low_text, style=label.style_label_left, color=label_bg_color, textcolor=label_txt_color, size=size.small)

// Optional: Add a label to show which timeframe is being used
var label timeframe_label = na
if barstate.islast
    label.delete(timeframe_label)
    timeframe_label := label.new(bar_index, high, text="MTF EMAs (" + timeframe_input + ")", style=label.style_label_down, color=color.new(color.gray, 70), textcolor=color.white, size=size.small)
````
