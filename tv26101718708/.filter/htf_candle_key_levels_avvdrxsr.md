# HTF Candle & Key Levels

- url: https://www.tradingview.com/script/aVvdRxSr-HTF-Candle-Key-Levels/
- type: indicator
- pine_id: PUB;f721a3f33b8642458889c41533fb4bbc
- version: 3.0

## Description

HTF Candle & Key Levels Overlay
A clean, clear TradingView indicator for analyzing Higher Timeframe (HTF) market structure and price action. It projects key percentage levels and Fibonacci ratios from the higher timeframe candle directly across your chart background, while displaying the active HTF candle neatly on the right margin—keeping your main chart completely unobstructed.

Key Features:
Flexible HTF Selection: Track Daily, 4-Hour, 1-Hour, or other timeframe candles on your lower-timeframe execution charts (e.g., 1m, 5m, 15m) to maintain full context of the broader price range.

Selectable Key & Fibonacci Levels: Easily toggle crucial range points and Fibonacci retracements—such as 0% (Low), 40%, 50% (Midpoint), 60%, 61.8%, 78.6%, and 100% (High)—complete with optional real-time price and percentage labels.

Right Candle: Renders the body and wicks of the current HTF candle off to the right side of active price action, ensuring your execution chart remains clean.

Full Customization: Adjust line styles (Solid, Dashed, Dotted), line thickness, colors, and candle parameters to fit your visual preference.

## Source Code

````pine
//@version=6
indicator("HTF Candle & Key Levels Overlay", overlay=true, max_lines_count=500, max_boxes_count=100, max_labels_count=100)

// --- INPUTS ---
group_htf    = "HTF Settings"
htf          = input.timeframe("D", "Higher Timeframe (HTF)", group=group_htf)
draw_right   = input.bool(true, "Display Right HTF Candle(s)", group=group_htf)
num_candles  = input.int(1, "Number of Past HTF Candles (1-5)", minval=1, maxval=5, group=group_htf)
right_offset = input.int(4, "Right Candle Offset (Bars)", minval=1, group=group_htf)
candle_width = input.int(3, "Right Candle Width (Bars)", minval=1, group=group_htf)

group_fib    = "Fibonacci / Level & Style"
show_fib     = input.bool(true, "Show Levels", group=group_fib)

// Separate Toggles for Percentage and Price (Defaults: % ON, Price OFF)
show_pct     = input.bool(true, "Show % Label", group=group_fib)
show_price   = input.bool(false, "Show Price Label", group=group_fib)

// Label Color Selection & Styling
label_color     = input.color(color.new(#636363, 40), "Label Text Color (Main Levels)", group=group_fib)
label_color_50  = input.color(color.new(#ff0000, 30), "Label Text Color (50.0% Level Only)", group=group_fib)
label_style_str = input.string("Transparent", "Label Style (Main Levels)", options=["Transparent", "With Background"], group=group_fib)
bg_50_only      = input.bool(false, "Add Background to 50.0% Label Only", group=group_fib)

// Fib Toggles
show_1    = input.bool(false, "100.0% (High)", inline="f1", group=group_fib)
show_0786 = input.bool(false, "78.6%", inline="f786", group=group_fib)
show_0618 = input.bool(false, "61.8%", inline="f618", group=group_fib)
show_06   = input.bool(true, "60.0%", inline="f06", group=group_fib)
show_05   = input.bool(true, "50.0%", inline="f05", group=group_fib)
show_04   = input.bool(true, "40.0%", inline="f04", group=group_fib)
show_0    = input.bool(false, "0.0% (Low)", inline="f0", group=group_fib)

// Line Customization & Specific Line Style for 40% & 60% (Default: Dotted)
line_style_str    = input.string("Solid", "Line Style (Main Lines)", options=["Solid", "Dashed", "Dotted"], group=group_fib)
line_style_40_60  = input.string("Dotted", "Line Style (40% & 60% Only)", options=["Solid", "Dashed", "Dotted"], group=group_fib)
fib_color         = input.color(#636363, "Main Line Color", group=group_fib)
color_50          = input.color(#ff0000, "Color for 50.0% Level", group=group_fib)
line_width        = input.int(1, "Line Width (Regular Lines)", minval=1, maxval=4, group=group_fib)
line_width_50     = input.int(2, "Line Width (50.0% Midline Only)", minval=1, maxval=5, group=group_fib)

// --- PREVIOUS DAY (PD) SETTINGS ---
group_pd          = "Previous Day (PD) Settings"
show_pd50         = input.bool(true, "Show PD50 Line", group=group_pd)
pd50_label_text   = input.string("PD50", "PD50 Label Text", group=group_pd)
show_pd50_price   = input.bool(false, "Show PD Price in Parentheses", group=group_pd)
pd50_size_str     = input.string("Small", "PD Font Size", options=["Small", "Normal", "Large"], group=group_pd)
pd50_color        = input.color(#f3db0b, "PD50 Color", group=group_pd)
pd50_bg_style     = input.string("With Background", "PD50 Label Style", options=["Transparent", "With Background"], group=group_pd)
pd50_width        = input.int(2, "PD50 Line Width", minval=1, maxval=5, group=group_pd)
pd50_style_str    = input.string("Dashed", "PD50 Line Style", options=["Solid", "Dashed", "Dotted"], group=group_pd)

show_pd_40_60     = input.bool(false, "Show PD 40 & 60 Lines", group=group_pd)
pd_40_60_color    = input.color(#f3db0b, "PD 40 & 60 Color", group=group_pd)
pd_40_60_width    = input.int(1, "PD 40 & 60 Line Width", minval=1, maxval=5, group=group_pd)
pd_40_60_style    = input.string("Dotted", "PD 40 & 60 Line Style", options=["Solid", "Dashed", "Dotted"], group=group_pd)

// Background Zones Customization (7% Opacity = 93% Transparency)
group_bg      = "Background Colors (Zones)"
show_bg_40_50 = input.bool(true, "Show Zone 40% - 50%", group=group_bg)
color_40_50   = input.color(color.new(color.gray, 93), "Color (40% - 50%)", group=group_bg)

show_bg_50_60 = input.bool(true, "Show Zone 50% - 60%", group=group_bg)
color_50_60   = input.color(color.new(color.gray, 93), "Color (50% - 60%)", group=group_bg)

// Candle Colors & Style for Right Candle
group_color = "Right Candle Colors & Width"
up_color    = input.color(#b2b5be, "Bullish Body", group=group_color)
down_color  = input.color(#363a45, "Bearish Body", group=group_color)
wick_color  = input.color(#636363, "Wick Color", group=group_color)
wick_width  = input.int(1, "Wick Width", minval=1, maxval=5, group=group_color)

// --- HELPER FUNCTIONS ---
get_line_style(string style) =>
    switch style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

get_label_size(string sz) =>
    switch sz
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

selected_style          = get_line_style(line_style_str)
selected_style_40_60    = get_line_style(line_style_40_60)
selected_style_pd50     = get_line_style(pd50_style_str)
selected_style_pd_40_60 = get_line_style(pd_40_60_style)
pd50_size               = get_label_size(pd50_size_str)

// --- HTF DATA FOR MULTIPLE CANDLES ---
htf_o0 = request.security(syminfo.tickerid, htf, open, lookahead=barmerge.lookahead_on)
htf_h0 = request.security(syminfo.tickerid, htf, high, lookahead=barmerge.lookahead_on)
htf_l0 = request.security(syminfo.tickerid, htf, low, lookahead=barmerge.lookahead_on)
htf_c0 = request.security(syminfo.tickerid, htf, close, lookahead=barmerge.lookahead_on)

htf_o1 = request.security(syminfo.tickerid, htf, open[1], lookahead=barmerge.lookahead_on)
htf_h1 = request.security(syminfo.tickerid, htf, high[1], lookahead=barmerge.lookahead_on)
htf_l1 = request.security(syminfo.tickerid, htf, low[1], lookahead=barmerge.lookahead_on)
htf_c1 = request.security(syminfo.tickerid, htf, close[1], lookahead=barmerge.lookahead_on)

htf_o2 = request.security(syminfo.tickerid, htf, open[2], lookahead=barmerge.lookahead_on)
htf_h2 = request.security(syminfo.tickerid, htf, high[2], lookahead=barmerge.lookahead_on)
htf_l2 = request.security(syminfo.tickerid, htf, low[2], lookahead=barmerge.lookahead_on)
htf_c2 = request.security(syminfo.tickerid, htf, close[2], lookahead=barmerge.lookahead_on)

htf_o3 = request.security(syminfo.tickerid, htf, open[3], lookahead=barmerge.lookahead_on)
htf_h3 = request.security(syminfo.tickerid, htf, high[3], lookahead=barmerge.lookahead_on)
htf_l3 = request.security(syminfo.tickerid, htf, low[3], lookahead=barmerge.lookahead_on)
htf_c3 = request.security(syminfo.tickerid, htf, close[3], lookahead=barmerge.lookahead_on)

htf_o4 = request.security(syminfo.tickerid, htf, open[4], lookahead=barmerge.lookahead_on)
htf_h4 = request.security(syminfo.tickerid, htf, high[4], lookahead=barmerge.lookahead_on)
htf_l4 = request.security(syminfo.tickerid, htf, low[4], lookahead=barmerge.lookahead_on)
htf_c4 = request.security(syminfo.tickerid, htf, close[4], lookahead=barmerge.lookahead_on)

// Previous Day Data
pd_h = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pd_l = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pd_range    = pd_h - pd_l
pd_50_price = pd_h - pd_range * 0.5
pd_40_price = pd_h - pd_range * 0.4
pd_60_price = pd_h - pd_range * 0.6

// --- VAR DECLARATIONS ---
var box[]  right_boxes = array.new<box>()
var line[] right_wicks = array.new<line>()

var box  box_40_50 = na
var box  box_50_60 = na

var line[]  fib_lines  = array.new<line>()
var label[] fib_labels = array.new<label>()

var int start_bar = bar_index

is_new_tf = timeframe.change(htf)

if is_new_tf
    start_bar := bar_index

// Helper function to create Fib lines
add_fib_level(float price, string level_text, color l_color, int l_width, color txt_color_input, bool is_50_level, string custom_line_style, int max_right_x) =>
    line_style_to_use = custom_line_style == "" ? selected_style : get_line_style(custom_line_style)
    
    // Main line up to current bar
    line l_chart = line.new(x1=start_bar, y1=price, x2=bar_index, y2=price, color=l_color, style=line_style_to_use, width=l_width)
    array.push(fib_lines, l_chart)
    
    int label_x = bar_index
    
    // Small connecting line across right HTF candles
    if draw_right
        int right_x1 = bar_index + right_offset
        line l_candle = line.new(x1=right_x1, y1=price, x2=max_right_x, y2=price, color=l_color, style=line_style_to_use, width=l_width)
        array.push(fib_lines, l_candle)
        label_x := max_right_x

    // Dynamic Label Text Creation
    if show_pct or show_price
        string display_text = ""
        
        if show_pct and show_price
            display_text := level_text + " (" + str.tostring(price, "#.##") + ")"
        else if show_pct
            display_text := level_text
        else if show_price
            display_text := str.tostring(price, "#.##")

        bool use_bg = is_50_level ? (bg_50_only or label_style_str == "With Background") : (label_style_str == "With Background")
        color bg_col = use_bg ? l_color : color.new(color.black, 100)
        color txt_col = use_bg ? color.white : txt_color_input
        
        label lbl = label.new(x=label_x, y=price, text=display_text, color=bg_col, textcolor=txt_col, style=label.style_label_left, size=size.small)
        array.push(fib_labels, lbl)

// --- LIVE UPDATES PER BAR ---
if array.size(fib_lines) > 0
    for i = 0 to array.size(fib_lines) - 1
        line.delete(array.get(fib_lines, i))
    array.clear(fib_lines)

if array.size(fib_labels) > 0
    for i = 0 to array.size(fib_labels) - 1
        label.delete(array.get(fib_labels, i))
    array.clear(fib_labels)

if array.size(right_boxes) > 0
    for i = 0 to array.size(right_boxes) - 1
        box.delete(array.get(right_boxes, i))
    array.clear(right_boxes)

if array.size(right_wicks) > 0
    for i = 0 to array.size(right_wicks) - 1
        line.delete(array.get(right_wicks, i))
    array.clear(right_wicks)

if not na(box_40_50)
    box.delete(box_40_50)
if not na(box_50_60)
    box.delete(box_50_60)

// Helper arrays to handle multi-candle rendering
float[] opens  = array.new_float()
float[] highs  = array.new_float()
float[] lows   = array.new_float()
float[] closes = array.new_float()

array.push(opens, htf_o0)
array.push(highs, htf_h0)
array.push(lows, htf_l0)
array.push(closes, htf_c0)

if num_candles >= 2
    array.push(opens, htf_o1)
    array.push(highs, htf_h1)
    array.push(lows, htf_l1)
    array.push(closes, htf_c1)
if num_candles >= 3
    array.push(opens, htf_o2)
    array.push(highs, htf_h2)
    array.push(lows, htf_l2)
    array.push(closes, htf_c2)
if num_candles >= 4
    array.push(opens, htf_o3)
    array.push(highs, htf_h3)
    array.push(lows, htf_l3)
    array.push(closes, htf_c3)
if num_candles == 5
    array.push(opens, htf_o4)
    array.push(highs, htf_h4)
    array.push(lows, htf_l4)
    array.push(closes, htf_c4)

int max_right_x = bar_index

// Draw Right HTF Candles (from oldest to newest)
if draw_right
    int spacing = candle_width + 1
    for i = num_candles - 1 to 0
        float c_o = array.get(opens, i)
        float c_h = array.get(highs, i)
        float c_l = array.get(lows, i)
        float c_c = array.get(closes, i)

        int candle_index = (num_candles - 1) - i
        int r_x1 = bar_index + right_offset + (candle_index * spacing)
        int r_x2 = r_x1 + (candle_width - 1)
        max_right_x := r_x2

        float r_mid = r_x1 + (r_x2 - r_x1) / 2.0
        int r_mid_int = int(math.round(r_mid))

        color body_col = c_c >= c_o ? up_color : down_color

        line w_line = line.new(x1=r_mid_int, y1=c_h, x2=r_mid_int, y2=c_l, color=wick_color, width=wick_width)
        array.push(right_wicks, w_line)

        float b_top = math.max(c_o, c_c)
        float b_bottom = math.min(c_o, c_c)
        if b_top == b_bottom
            b_top := b_top + (c_h - c_l) * 0.001

        box b_box = box.new(left=r_x1, top=b_top, right=r_x2, bottom=b_bottom, border_color=body_col, bgcolor=body_col)
        array.push(right_boxes, b_box)

// Calculate horizontal levels & zones for the current HTF candle
float range_htf = htf_h0 - htf_l0
float p_40 = htf_h0 - range_htf * 0.4
float p_50 = htf_h0 - range_htf * 0.5
float p_60 = htf_h0 - range_htf * 0.6

// Background boxes end at current bar
if show_bg_40_50
    box_40_50 := box.new(left=start_bar, top=p_40, right=bar_index, bottom=p_50, border_color=color.new(color.white, 100), bgcolor=color_40_50)

if show_bg_50_60
    box_50_60 := box.new(left=start_bar, top=p_50, right=bar_index, bottom=p_60, border_color=color.new(color.white, 100), bgcolor=color_50_60)

// Draw Fibonacci Lines
if show_fib
    if show_1
        add_fib_level(htf_h0, "100.0% High", fib_color, line_width, label_color, false, "", max_right_x)
    if show_04
        add_fib_level(p_40, "40.0%", fib_color, line_width, label_color, false, line_style_40_60, max_right_x)
    if show_05
        add_fib_level(p_50, "50.0%", color_50, line_width_50, label_color_50, true, "", max_right_x)
    if show_06
        add_fib_level(p_60, "60.0%", fib_color, line_width, label_color, false, line_style_40_60, max_right_x)
    if show_0618
        add_fib_level(htf_h0 - range_htf * 0.618, "61.8%", fib_color, line_width, label_color, false, "", max_right_x)
    if show_0786
        add_fib_level(htf_h0 - range_htf * 0.786, "78.6%", fib_color, line_width, label_color, false, "", max_right_x)
    if show_0
        add_fib_level(htf_l0, "0.0% Low", fib_color, line_width, label_color, false, "", max_right_x)

// Draw Previous Day 50% (PD50) Line
if show_pd50 and not na(pd_50_price)
    int pd_end_x = draw_right ? max_right_x : bar_index
    line l_pd50 = line.new(x1=start_bar, y1=pd_50_price, x2=pd_end_x, y2=pd_50_price, color=pd50_color, style=selected_style_pd50, width=pd50_width)
    array.push(fib_lines, l_pd50)
    
    bool use_pd_bg = pd50_bg_style == "With Background"
    color pd_bg_col  = use_pd_bg ? color.new(pd50_color, 40) : color.new(color.black, 100)
    color pd_txt_col = use_pd_bg ? #2a2e39 : color.new(pd50_color, 30)
    
    string pd_text = show_pd50_price ? pd50_label_text + " (" + str.tostring(pd_50_price, "#.##") + ")" : pd50_label_text
    label lbl_pd50 = label.new(x=pd_end_x, y=pd_50_price, text=pd_text, color=pd_bg_col, textcolor=pd_txt_col, style=label.style_label_left, size=pd50_size)
    array.push(fib_labels, lbl_pd50)

// Draw Previous Day 40 & 60 Lines
if show_pd_40_60 and not na(pd_40_price)
    int pd_end_x = draw_right ? max_right_x : bar_index
    
    // PD 40
    line l_pd40 = line.new(x1=start_bar, y1=pd_40_price, x2=pd_end_x, y2=pd_40_price, color=pd_40_60_color, style=selected_style_pd_40_60, width=pd_40_60_width)
    array.push(fib_lines, l_pd40)
    string pd40_text = show_pd50_price ? "PD40 (" + str.tostring(pd_40_price, "#.##") + ")" : "PD40"
    label lbl_pd40 = label.new(x=pd_end_x, y=pd_40_price, text=pd40_text, color=color.new(color.black, 100), textcolor=color.new(pd_40_60_color, 30), style=label.style_label_left, size=pd50_size)
    array.push(fib_labels, lbl_pd40)

    // PD 60
    line l_pd60 = line.new(x1=start_bar, y1=pd_60_price, x2=pd_end_x, y2=pd_60_price, color=pd_40_60_color, style=selected_style_pd_40_60, width=pd_40_60_width)
    array.push(fib_lines, l_pd60)
    string pd60_text = show_pd50_price ? "PD60 (" + str.tostring(pd_60_price, "#.##") + ")" : "PD60"
    label lbl_pd60 = label.new(x=pd_end_x, y=pd_60_price, text=pd60_text, color=color.new(color.black, 100), textcolor=color.new(pd_40_60_color, 30), style=label.style_label_left, size=pd50_size)
    array.push(fib_labels, lbl_pd60)
````
