# Liquidity gap identifier mtf

- url: https://www.tradingview.com/script/5yxFNLQH-Liquidity-gap-identifier-mtf/
- type: indicator
- pine_id: PUB;c4b5e19eb06c4b70afed8021f140614c
- version: 1.0

## Description

This Pine Script v6 indicator called "Liquidity gap identifier mtf" detects and visually highlights price gaps (also known as imbalances, inefficiencies, or Fair Value Gaps in SMC/ICT trading) using multi-timeframe (MTF) support.How it works:It compares the current candle (or higher timeframe candle) with the candle two bars prior.
Bullish Gap (upward imbalance): When the low of the current candle is higher than the high of the candle from two bars ago (low > high[2]). This leaves an unfilled area below price.
Bearish Gap (downward imbalance): When the high of the current candle is lower than the low of the candle from two bars ago (high < low[2]). This leaves an unfilled area above price.

The script draws boxes (rectangles) to mark these gaps:Boxes start between the relevant candles and automatically expand to the right (to the current bar) as new bars form.
Supports MTF: You can display gaps from a higher timeframe (e.g., daily gaps on a 15-minute chart) while keeping the main chart clean.
Customization: Colors, transparency, and the option to hide filled gaps (when price trades through the gap, the box is removed).
Uses arrays for efficient management of multiple active boxes with a FIFO (first-in, first-out) limit to avoid exceeding TradingView's max_boxes_count.

Key FeaturesExpanding boxes — The gaps stay visible and stretch rightward until filled or the max limit is reached.
Auto cleanup — Removes oldest gaps when the user-defined max is hit.
Hide filled gaps option (very useful for clean charts).
Clean MTF implementation using request.security() with proper gap handling.

Main Use CasesFair Value Gap / Imbalance Trading (ICT/SMC)Many traders use these gaps as magnet zones or areas that price is likely to return to and "fill" (mitigate).
Bullish gaps often act as support; bearish gaps as resistance.

Multi-Timeframe ConfluencePlot higher-timeframe gaps on your lower-timeframe chart to see where larger players might have left inefficiencies.
Example: Show 4H or Daily liquidity gaps while scalping on 5m/15m.

Gap Fill StrategiesEnter trades expecting price to retrace and fill the gap (mean reversion).
Or use unfilled gaps as bias: Trade in the direction of the gap (continuation) until it fills.

Liquidity Void IdentificationThese gaps represent areas with low liquidity / rapid price movement. Institutions often target or avoid them, making them useful for stop hunts, order blocks, or breaker setups.

Clean Chart ManagementThe "Hide Filled Gaps" feature + max boxes limit keeps the chart from becoming cluttered with old, irrelevant zones.

Typical Trading ContextTraders combine this with:Order blocks / breaker blocks
Market structure (BOS/CHOCH)
Volume profile or session liquidity
Higher-timeframe bias

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Modified for MTF with Expanding Boxes and Customization

//@version=6
// NOTE: max_boxes_count here should be set slightly higher than your user input to allow for the transition moment
indicator("Liquidity gap identifier mtf", overlay=true, max_boxes_count=400)

// --- USER CONTROLS ---
tf_input = input.timeframe("", "Timeframe", tooltip="Leave empty for current chart, or select e.g. 1H, 1D")
hide_filled = input.bool(true, "Hide Filled Gaps", tooltip="Remove boxes if price trades through the gap")
max_boxes_input = input.int(192, "Max Historical Boxes", minval=1, maxval=400, tooltip="Limits how many gaps are kept on screen. Older ones are removed automatically.")

// Colors & Transparency
bull_bg_color = input.color(color.rgb(17, 181, 11, 85), "Bullish Gap Color")
bull_border_color = input.color(color.new(#008000, 0), "Bullish Border")
bear_bg_color = input.color(color.rgb(129, 5, 5, 85), "Bearish Gap Color")
bear_border_color = input.color(color.rgb(128, 25, 34), "Bearish Border")


// --- DATA FETCHING ---
is_same_tf = tf_input == ""

// Fetch values: Native if same TF, Security if MTF
candle_1_L = is_same_tf ? low[2] : request.security(syminfo.tickerid, tf_input, low[2], gaps=barmerge.gaps_on)
candle_1_H = is_same_tf ? high[2] : request.security(syminfo.tickerid, tf_input, high[2], gaps=barmerge.gaps_on)
candle_3_L = is_same_tf ? low : request.security(syminfo.tickerid, tf_input, low, gaps=barmerge.gaps_on)
candle_3_H = is_same_tf ? high : request.security(syminfo.tickerid, tf_input, high, gaps=barmerge.gaps_on)

// --- STATE MANAGEMENT ---
var box[] active_boxes = array.new_box()
var string[] box_types = array.new_string() 
var float[] box_tops = array.new_float()
var float[] box_bots = array.new_float()

// Helper function to remove the oldest box (FIFO)
remove_oldest_box() =>
    if array.size(active_boxes) > 0
        old_b = array.shift(active_boxes) // Removes from index 0
        box.delete(old_b)
        array.shift(box_types)
        array.shift(box_tops)
        array.shift(box_bots)

// --- LOGIC: DETECT NEW GAPS ---
bull_gap = not na(candle_3_L) and not na(candle_1_H) and (candle_3_L > candle_1_H)
bear_gap = not na(candle_1_L) and not na(candle_3_H) and (candle_1_L > candle_3_H)

// 1. Create New Boxes (with FIFO limit check)
if bull_gap
    // If we are at the limit, remove the oldest one first
    if array.size(active_boxes) >= max_boxes_input
        remove_oldest_box()
        
    new_box = box.new(
         left=bar_index[2], 
         right=bar_index, 
         top=candle_3_L, 
         bottom=candle_1_H, 
         bgcolor=bull_bg_color, 
         border_color=bull_border_color,
         border_width=1
    )
    array.push(active_boxes, new_box)
    array.push(box_types, "bull")
    array.push(box_tops, candle_3_L)
    array.push(box_bots, candle_1_H)

if bear_gap
    // If we are at the limit, remove the oldest one first
    if array.size(active_boxes) >= max_boxes_input
        remove_oldest_box()

    new_box = box.new(
         left=bar_index[2], 
         right=bar_index, 
         top=candle_1_L, 
         bottom=candle_3_H, 
         bgcolor=bear_bg_color, 
         border_color=bear_border_color,
         border_width=1
    )
    array.push(active_boxes, new_box)
    array.push(box_types, "bear")
    array.push(box_tops, candle_1_L)
    array.push(box_bots, candle_3_H)

// 2. EXPAND EXISTING BOXES TO CURRENT BAR
if array.size(active_boxes) > 0
    for i = 0 to array.size(active_boxes) - 1
        b = array.get(active_boxes, i)
        box.set_right(b, bar_index)

// 3. DELETE FILLED GAPS
if hide_filled and array.size(active_boxes) > 0
    // Iterate backwards to safely remove items
    for i = array.size(active_boxes) - 1 to 0
        b = array.get(active_boxes, i)
        top_val = box.get_top(b)
        bot_val = box.get_bottom(b)
        
        // Check if current bar has traded INSIDE the gap
        if (low <= top_val and high >= bot_val)
            box.delete(b)
            array.remove(active_boxes, i)
            array.remove(box_types, i)
            array.remove(box_tops, i)
            array.remove(box_bots, i)
````
