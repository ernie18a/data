# HTF Candle

- url: https://www.tradingview.com/script/uo3OknYI/
- type: indicator
- pine_id: PUB;30383fd381bd4231988d29ed6a2f86a9
- version: 2.0

## Description

"A simple and accurate Higher Time Frame (HTF) candlestick overlay."
This indicator renders HTF candlesticks on your chart. It dynamically counts the bars within each period to ensure perfect alignment across any market session or timeframe.

## Source Code

````pine
//@version=6
// ========================================================================= //
//                                HTF Candle                                 //
// ========================================================================= //
indicator(title='HTF Candle', overlay=true, max_bars_back=5000, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ------------------------------------------------------------------------- //
// HTF Candle Input
// ------------------------------------------------------------------------- //
htf_timeframe = input.timeframe("1D", title="Higher Time Frame (HTF)")
htf_color_bullish = input.color(color.new(#26a69a, 80), title="Bullish Candle Color")
htf_color_bearish = input.color(color.new(#ef5350, 80), title="Bearish Candle Color")
htf_wick_width = input.int(2, title="Wick Width (in bars)", minval=1)

// ------------------------------------------------------------------------- //
// HTF Candle Process
// ------------------------------------------------------------------------- //
var int htf_period_count = 0
bool htf_period_new = timeframe.change(htf_timeframe)

if htf_period_new
    htf_period_count := 1
else
    htf_period_count += 1

// --- Security Call ---
// Fetching the confirmed OHLC data of the previous HTF bar.
[htc_open, htf_high, htf_low, htf_close] = request.security(syminfo.tickerid, htf_timeframe, [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
htf_body_max = math.max(htc_open, htf_close), htf_body_min = math.min(htc_open, htf_close)

// --- Rendering Logic ---
if htf_period_new
    // Get the exact number of bars that were contained in the confirmed HTF period.
    int actual_bars = htf_period_count[1]
    
    // Determine the color based on price action
    color color = htf_close >= htc_open ? htf_color_bullish : htf_color_bearish
    
    // Calculate horizontal positioning
    int left_index   = bar_index - actual_bars
    int right_index  = bar_index - 1
    
    // Calculate vertical and horizontal positioning for wicks (centered)
    float center_offset = (actual_bars - 1) / 2.0
    int center_x        = math.round(bar_index - actual_bars + center_offset)
    int wick_left       = center_x - math.floor((htf_wick_width - 1) / 2.0)
    int wick_right      = wick_left + (htf_wick_width - 1)

    // --- Box Rendering (Wicks and Body) ---
    // Upper Wick
    if htf_high > htf_body_max
        box.new(left=wick_left, top=htf_high, right=wick_right, bottom=htf_body_max, border_color=color, bgcolor=color)
    // Lower Wick
    if htf_low < htf_body_min
        box.new(left=wick_left, top=htf_body_min, right=wick_right, bottom=htf_low, border_color=color, bgcolor=color)
    // Candle Body
    box.new(left=left_index, top=htf_body_max, right=right_index, bottom=htf_body_min, border_color=color, bgcolor=color)
````
