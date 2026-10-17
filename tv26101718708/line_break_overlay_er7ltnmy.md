# Line Break Overlay

- url: https://www.tradingview.com/script/Er7ltnMy-Line-Break-Overlay/
- type: indicator
- pine_id: PUB;46f0c7bc00a348719bbab78b08cf032f
- version: 1.0

## Description

[b]📌 Introduction[/b]

The Line Break Overlay indicator allows you to plot a traditional Line Break chart (such as the classic 3-Line Break) directly on top of your standard time-based charts (Candlesticks, Bars, etc.).

By rendering Line Break boxes over standard charts, you can filter out market noise and identify clear, trend-following price action without losing the context of time or the details of standard candlestick patterns.

[b]✨ Key Features[/b]

True Overlay Design: Uses Pine Script's advanced box objects to draw Line Break blocks directly over your current chart. The boxes extend dynamically as new bars form until a new box is confirmed.

Customizable Period: While the 3-Line Break is the standard, you can adjust the "Line Break Period" to any number (e.g., 2, 4, 5) to suit your trading style.

Dynamic Reversal Level: Visually plots the exact price level required for the current trend to reverse. This acts as a great dynamic support/resistance or trailing stop level.

Memory Management: Built-in array and object management limits the number of boxes drawn (default 200) to prevent performance issues and keep your chart running smoothly.

[b]⚙️ Settings & Customization[/b]

Line Break Period: Choose the number of previous lines/boxes the price must break to trigger a reversal.

Source: Choose the price source. The default is hl2 (High+Low/2), but you can change it to close or others based on your preference.

Max Box History: Set the maximum number of boxes to keep on the chart.

Box Style: Fully customize the colors, transparency, and border width for both Uptrend and Downtrend boxes.

Reversal Level: Toggle the visibility of the reversal line.

Tip: To make the reversal line dashed, please go to the 'Style' tab in the indicator settings window and change the line style from 'Line' to 'Dashed'.

[b]🔔 Alerts[/b]

The script includes built-in alert conditions for trend reversals. You can easily set up notifications when the market shifts momentum:

Trend Uptrend (Buy): Triggers when the price breaks the upper reversal level, confirming a new uptrend box.

Trend Downtrend (Sell): Triggers when the price breaks the lower reversal level, confirming a new downtrend box.

[b]💡 How to Use[/b]

Use this indicator to identify major market trends and filter out minor retracements. If the boxes are green, the trend is up; if they are red, the trend is down. The reversal level clearly shows you where the trend will invalidate, making it highly useful for placing stop losses or breakout entries.

## Source Code

````pine
//@version=5
indicator("Line Break Overlay", overlay=true, max_boxes_count=500)

// --- Input Settings ---
// Basic Settings
int lb_len = input.int(3, title="Line Break Period", minval=1, group="Basic Settings", tooltip="Standard is 3 (3-Line Break).")
float src = input.source(hl2, title="Source", group="Basic Settings")
int max_history = input.int(200, title="Max Box History", minval=10, maxval=500, group="Basic Settings", tooltip="Maximum number of boxes to display (prevents memory issues).")

// Box Style
color col_up = input.color(color.new(color.green, 60), title="Up Color", inline="box_up", group="Box Style")
color border_up = input.color(color.green, title="Border", inline="box_up", group="Box Style")
color col_dn = input.color(color.new(color.red, 60), title="Down Color", inline="box_dn", group="Box Style")
color border_dn = input.color(color.red, title="Border", inline="box_dn", group="Box Style")
int b_width = input.int(1, title="Border Width", minval=1, group="Box Style")

// Reversal Level Settings
bool show_rev = input.bool(true, title="Show Reversal Level", group="Reversal Level Settings", tooltip="To make it dashed, please change the line style to 'Dashed' from the 'Style' tab in settings.")
color col_rev_up = input.color(color.green, title="Up Trend Level Color", inline="rev_col", group="Reversal Level Settings")
color col_rev_dn = input.color(color.red, title="Down Trend Level Color", inline="rev_col", group="Reversal Level Settings")
int rev_width = input.int(1, title="Line Width", minval=1, group="Reversal Level Settings")

// --- Array Initialization ---
// Arrays to store high, low, and direction (1=Up, -1=Down) of Line Break boxes
var float[] box_highs = array.new_float(0)
var float[] box_lows = array.new_float(0)
var int[] box_dirs = array.new_int(0)

// Array to store the drawn box objects
var box[] drawn_boxes = array.new_box(0)

// Index in the array where the current trend started
var int trend_start_idx = 0

// Current Trend & Reversal Level
var int current_trend = 1
float reversal_level = na

// --- Logic Calculation ---
// Initialize on the first bar
if barstate.isfirst
    array.push(box_highs, high)
    array.push(box_lows, low)
    int initial_dir = close >= open ? 1 : -1
    array.push(box_dirs, initial_dir)
    trend_start_idx := 0
    current_trend := initial_dir
    
    // Draw the first box
    color bg_col = initial_dir == 1 ? col_up : col_dn
    color br_col = initial_dir == 1 ? border_up : border_dn
    box b = box.new(left=bar_index, top=high, right=bar_index, bottom=low, border_color=br_col, border_width=b_width, bgcolor=bg_col)
    array.push(drawn_boxes, b)

int size = array.size(box_highs)

if size > 0
    // Get the most recent box information
    int last_idx = size - 1
    float last_high = array.get(box_highs, last_idx)
    float last_low = array.get(box_lows, last_idx)
    int last_dir = array.get(box_dirs, last_idx)

    // Calculate current Reversal Level
    int check_idx_for_rev = math.max(trend_start_idx, size - lb_len)
    if last_dir == 1
        reversal_level := array.get(box_lows, check_idx_for_rev)
    else if last_dir == -1
        reversal_level := array.get(box_highs, check_idx_for_rev)

    bool is_new_box = false
    int new_dir = 0
    float new_high = na
    float new_low = na

    // During an uptrend
    if last_dir == 1
        if src > last_high // Continuation (new high)
            new_dir := 1
            new_high := src
            new_low := last_high
            is_new_box := true
        else // Check for reversal
            if src < reversal_level // Reversal to downtrend
                new_dir := -1
                new_high := last_low
                new_low := src
                is_new_box := true

    // During a downtrend
    else if last_dir == -1
        if src < last_low // Continuation (new low)
            new_dir := -1
            new_high := last_low
            new_low := src
            is_new_box := true
        else // Check for reversal
            if src > reversal_level // Reversal to uptrend
                new_dir := 1
                new_high := src
                new_low := last_high
                is_new_box := true

    // --- Box Drawing and Array Update ---
    if is_new_box
        // Extend the right edge of the existing last box to the current bar before drawing a new one
        if array.size(drawn_boxes) > 0
            box last_b = array.get(drawn_boxes, array.size(drawn_boxes) - 1)
            box.set_right(last_b, bar_index)

        // Add the new box data to the arrays
        array.push(box_highs, new_high)
        array.push(box_lows, new_low)
        array.push(box_dirs, new_dir)
        
        // Update the trend start index if the trend direction changed
        if new_dir != last_dir
            trend_start_idx := array.size(box_highs) - 1
            current_trend := new_dir // Update global trend state

        // Add the new box to the chart
        color bg_col = new_dir == 1 ? col_up : col_dn
        color br_col = new_dir == 1 ? border_up : border_dn
        box b = box.new(left=bar_index, top=new_high, right=bar_index, bottom=new_low, border_color=br_col, border_width=b_width, bgcolor=bg_col)
        array.push(drawn_boxes, b)

        // Memory management
        if array.size(box_highs) > max_history
            array.shift(box_highs)
            array.shift(box_lows)
            array.shift(box_dirs)
            // Shift trend start index by 1
            trend_start_idx := math.max(0, trend_start_idx - 1)
            
            // Delete the oldest box object
            box old_b = array.shift(drawn_boxes)
            box.delete(old_b)
            
    else
        // While a new box is not formed, keep extending the current box to the right
        if array.size(drawn_boxes) > 0
            box current_b = array.get(drawn_boxes, array.size(drawn_boxes) - 1)
            box.set_right(current_b, bar_index)

// --- Plotting ---
color current_rev_col = current_trend == 1 ? col_rev_up : col_rev_dn
// The line style is 'stepline' (solid by default). Change to dashed via the Style settings tab in TradingView.
plot(show_rev ? reversal_level : na, color=current_rev_col, title="Reversal Level", linewidth=rev_width, style=plot.style_stepline)

// --- Alerts ---
// Trigger when trend reverses
bool long_cond = ta.change(current_trend) and current_trend == 1
bool short_cond = ta.change(current_trend) and current_trend == -1

alertcondition(long_cond, title="Trend Uptrend (Buy)", message="Line Break trend reversed to UP.")
alertcondition(short_cond, title="Trend Downtrend (Sell)", message="Line Break trend reversed to DOWN.")
````
