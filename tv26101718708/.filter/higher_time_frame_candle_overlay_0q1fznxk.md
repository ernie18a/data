# Higher Time Frame Candle Overlay

- url: https://www.tradingview.com/script/0q1fznxK-Higher-Time-Frame-Candle-Overlay/
- type: indicator
- pine_id: PUB;40c934c49b00465d8603169cb87b1a9f
- version: 1.0

## Description

Higher Time Frame Candle Overlay. You can change it so it displays 5min, 30min, etc.

## Source Code

````pine
//@version=5
indicator("Giant Custom HTF Candle Overlay", shorttitle="Giant HTF", overlay=true, max_boxes_count=500, max_lines_count=500)

// 1. Create a user input for the timeframe (defaults to "5")
htf_input = input.timeframe("5", title="Higher Timeframe")

// 2. Fetch the custom HTF data based on user input
[o, h, l, c] = request.security(syminfo.tickerid, htf_input, [open, high, low, close])

// 3. Detect when a new HTF block begins
new_htf = ta.change(time(htf_input))

// 4. Define colors (80 = highly transparent so you can see the small candles inside)
bull_bg = color.new(color.teal, 80)
bear_bg = color.new(color.red, 80)
bull_border = color.new(color.teal, 0) // Solid border
bear_border = color.new(color.red, 0)  // Solid border

// 5. Variables to track our drawing objects
var box candle_box = na
var line top_wick = na
var line bottom_wick = na
var int start_index = na

// 6. Security Check: Only draw if the chart timeframe is strictly LOWER than the chosen HTF
// timeframe.in_seconds() converts timeframes into seconds to make accurate mathematical comparisons
current_tf_seconds = timeframe.in_seconds(timeframe.period)
htf_seconds        = timeframe.in_seconds(htf_input)
is_lower_tf        = timeframe.isintraday and (current_tf_seconds < htf_seconds)

if is_lower_tf
    // Setup current colors based on Open/Close
    is_bull = c >= o
    current_bg = is_bull ? bull_bg : bear_bg
    current_border = is_bull ? bull_border : bear_border
    
    // Top and bottom of the candle body
    body_top = math.max(o, c)
    body_bottom = math.min(o, c)

    if new_htf
        // A new period started: Create a NEW box and wicks
        start_index := bar_index
        
        candle_box := box.new(left=start_index, top=body_top, right=bar_index, bottom=body_bottom, border_color=current_border, bgcolor=current_bg)
        
        // Draw wicks at the center of the candle
        center_index = math.round((start_index + bar_index) / 2)
        top_wick := line.new(x1=center_index, y1=body_top, x2=center_index, y2=h, color=current_border)
        bottom_wick := line.new(x1=center_index, y1=body_bottom, x2=center_index, y2=l, color=current_border)
        
    else
        // Update the existing box and wicks to stretch them as the timeframe progresses
        if not na(candle_box)
            box.set_top(candle_box, body_top)
            box.set_bottom(candle_box, body_bottom)
            box.set_right(candle_box, bar_index) 
            box.set_bgcolor(candle_box, current_bg)
            box.set_border_color(candle_box, current_border)
            
            // Recalculate the center so the wicks stay perfectly centered on the giant candle
            center_index = math.round((start_index + bar_index) / 2)
            
            line.set_x1(top_wick, center_index)
            line.set_x2(top_wick, center_index)
            line.set_y1(top_wick, body_top)
            line.set_y2(top_wick, h)
            line.set_color(top_wick, current_border)
            
            line.set_x1(bottom_wick, center_index)
            line.set_x2(bottom_wick, center_index)
            line.set_y1(bottom_wick, body_bottom)
            line.set_y2(bottom_wick, l)
            line.set_color(bottom_wick, current_border)
````
