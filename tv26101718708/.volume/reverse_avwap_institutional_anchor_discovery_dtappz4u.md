# Reverse AVWAP: Institutional Anchor Discovery

- url: https://www.tradingview.com/script/dtaPpz4u-Reverse-AVWAP-Institutional-Anchor-Discovery/
- type: indicator
- pine_id: PUB;0d37002d29fd4cdca9c27a92ec96f194
- version: 1.0

## Description

Stop guessing your anchors. Let the algorithm find them for you.

Most traders use the Anchored VWAP (AVWAP) the same way: they pick an obvious swing high, swing low, or earnings gap, anchor a line to it, and wait to see if price reacts. But what if we flipped the script? What if we took a significant current price level and mathematically scanned history to find exactly which hidden dates are defending it?

[b]Introducing the Reverse AVWAP.
[/b]

This indicator acts as an investigative tool for market structure and volume memory. By targeting a specific date or your current real-time chart bar, the script calculates backward, scanning thousands of bars to find the exact historical anchor points where an AVWAP drawn from them converges perfectly with your target price.

How It Works
Instead of projecting forward, this script reverse-engineers the volume profile:

Dynamic Target Selection: Choose to run the calculation from a fixed Target Date or toggle Use Last Chart Bar as Target to dynamically track live, real-time convergence on your current candle.

Historical Matrix Scan: The algorithm searches back in time, calculating the exact AVWAP from every single historical bar up to your target.

Threshold Matching: If a historical AVWAP lands within your custom proximity threshold (e.g., ±2.5% or ±3.5%) of the target price, it flags that date as a valid "Anchor."

Stitched Curve Generation: It draws the historical VWAP curves connecting those hidden anchors directly to your target.

Key Features
Macro First vs. Micro First Scanning: Choose your search direction. Macro First scans from the oldest historical data forward, prioritizing dominant multi-year structural pivots (like All-Time Highs or major cyclical bottoms). Micro First scans from recent data backward, focusing on short-term accumulation zones.

Smart Anti-Clustering: Includes a "Minimum Bars Between Anchors" filter. If the market forms a major rounded peak or flat consolidation, this prevents the script from grabbing 5 consecutive days on the same structure. It forces the algorithm to find distinct, uniquely significant pivot origins.

Up to 15 Historical Curves: Automatically color-codes and plots multiple unique historical AVWAP curves that converge on your target price.

Precision Divergence Labels: Drops clean visual tags on the discovered anchors, showing you exactly how close the historical AVWAP came to your target price down to the decimal percentage.

Under the Hood (Engine Optimizations)
Calculating thousands of historical AVWAPs iteratively would normally trigger a Pine Script timeout or cause massive lag. This indicator utilizes a heavily optimized architecture to bypass TradingView's native limitations:

O(1) Time Math: It uses rolling arrays to track the cumulative sums of Volume and Price × Volume. By subtracting cumulative historical values from current ones, it solves the AVWAP equations instantly in constant time per bar.

Bulletproof Line-Chain Renderer: TradingView’s standard polyline engine frequently suffers from canvas rendering drops when drawing long curves across thousands of bars. This script implements a custom, lightweight rendering engine that segments standard lines into roughly 80 dynamically downsampled links per anchor. The result is a buttery-smooth curve that never fails to render, no matter how far back the anchor sits.

Memory Management: Includes a dedicated garbage-collection routine that wipes and redraws canvas objects on live ticks, keeping your chart clean, responsive, and completely free of visual flickering.

Usage Tips
The History Loading Shortcut: Pine Script can only analyze data that is actively loaded into your browser session. If you are looking for a macro anchor from years ago, use the TradingView "Go to" shortcut (Alt + G on Windows, Option + G on Mac) and enter a past date. This forces the servers to load the historical bars instantly, allowing the script to find the anchor immediately.

Validation: If you see a breakout, run the Reverse AVWAP. If multiple historical volume anchors perfectly align with your current price, you have high-conviction proof of a major institutional volume node. You can then use those newly discovered anchor dates to project standard AVWAPs forward into the future.

## Source Code

````pine
//@version=5
indicator("Reverse AVWAP", overlay=true, max_lines_count=500, max_labels_count=20)

// =========================================================================
// INPUTS
// =========================================================================
useLastBar   = input.bool(false, title="Use Last Chart Bar as Target?", tooltip="Overrides the date below and dynamically targets the most recent bar on the chart.")
targetDate   = input.time(timestamp("2026-05-27 00:00"), title="Target Date (If toggle off)")
threshPct    = input.float(3.5, title="Proximity Threshold (%)", step=0.5)
searchMode   = input.string("Macro First (Oldest -> Newest)", title="Search Direction", options=["Macro First (Oldest -> Newest)", "Micro First (Newest -> Oldest)"])
maxAnchors   = input.int(5, title="Max Anchors to Plot", minval=1, maxval=15)
minLookback  = input.int(20, title="Minimum Bars Before Target", minval=1)
minDist      = input.int(60, title="Minimum Bars Between Anchors", minval=1)
maxLookback  = input.int(8000, title="Max Total Lookback (Bars)", maxval=10000)

// =========================================================================
// DATA TRACKING
// =========================================================================
var float[] pv_arr   = array.new_float()
var float[] v_arr    = array.new_float()
var int[]   time_arr = array.new_int()
var float[] hlc3_arr = array.new_float()

float vol = na(volume) ? 1.0 : volume
float pv = hlc3 * vol

array.push(pv_arr, ta.cum(pv))
array.push(v_arr, ta.cum(vol))
array.push(time_arr, time)
array.push(hlc3_arr, hlc3)

if array.size(pv_arr) > maxLookback
    array.shift(pv_arr)
    array.shift(v_arr)
    array.shift(time_arr)
    array.shift(hlc3_arr)

// =========================================================================
// GARBAGE COLLECTION
// =========================================================================
var line[]  drawn_lines  = array.new_line()
var label[] drawn_labels = array.new_label()

// =========================================================================
// CORE LOGIC & TRIGGER
// =========================================================================
var bool targetReached = false
bool triggerCondition = false

if useLastBar
    if barstate.islast
        triggerCondition := true
else
    if not targetReached and time >= targetDate
        triggerCondition := true
        targetReached := true

if triggerCondition
    int n = array.size(pv_arr)
    
    if n > 1
        float target_pv = array.get(pv_arr, n - 1)
        float target_v  = array.get(v_arr, n - 1)
        float target_c  = close
        float thresh    = threshPct / 100.0
        
        int[] anchor_indices = array.new_int()
        int last_anchor = -1
        
        int search_start = n - 1 - minLookback
        int search_end   = 1
        
        bool isMacro = searchMode == "Macro First (Oldest -> Newest)"
        int loop_start = isMacro ? search_end : search_start
        int loop_end   = isMacro ? search_start : search_end
        int loop_step  = isMacro ? 1 : -1
        
        if search_start >= 1
            for i = loop_start to loop_end by loop_step
                float past_pv = array.get(pv_arr, i - 1)
                float past_v  = array.get(v_arr, i - 1)
                
                float denom = target_v - past_v
                if denom > 0
                    float avwap_val = (target_pv - past_pv) / denom
                    float diff = math.abs(avwap_val - target_c) / target_c
                    
                    if diff <= thresh
                        if last_anchor == -1 or math.abs(last_anchor - i) >= minDist
                            array.push(anchor_indices, i)
                            last_anchor := i
                            if array.size(anchor_indices) >= maxAnchors
                                break
        
        // ---------------------------------------------------------
        // RENDERING ENGINE
        // ---------------------------------------------------------
        if array.size(anchor_indices) > 0
            
            // Clear old drawings
            if array.size(drawn_lines) > 0
                for l in drawn_lines
                    line.delete(l)
                array.clear(drawn_lines)
                
            if array.size(drawn_labels) > 0
                for lbl in drawn_labels
                    label.delete(lbl)
                array.clear(drawn_labels)
            
            color[] colors = array.from(color.red, color.blue, color.green, color.orange, color.purple, color.teal, color.maroon, color.navy)
            
            for k = 0 to array.size(anchor_indices) - 1
                int a_idx = array.get(anchor_indices, k)
                float past_pv = array.get(pv_arr, a_idx - 1)
                float past_v  = array.get(v_arr, a_idx - 1)
                
                int total_bars = (n - 1) - a_idx
                int sample_rate = math.max(1, int(total_bars / 80)) 
                
                float prev_avwap = na
                int prev_time = na
                int color_idx = k % array.size(colors)
                color current_color = array.get(colors, color_idx)
                
                // Build the Line Chain (Flattened to single line execution)
                for j = a_idx to n - 1
                    if j == a_idx or (j - a_idx) % sample_rate == 0 or j == n - 1
                        float c_pv = array.get(pv_arr, j)
                        float c_v  = array.get(v_arr, j)
                        float denom_j = c_v - past_v
                        
                        if denom_j > 0
                            float c_avwap = (c_pv - past_pv) / denom_j
                            int c_time = array.get(time_arr, j)
                            
                            if not na(prev_avwap)
                                line l = line.new(x1=prev_time, y1=prev_avwap, x2=c_time, y2=c_avwap, xloc=xloc.bar_time, color=current_color, width=2)
                                array.push(drawn_lines, l)
                            
                            prev_time := c_time
                            prev_avwap := c_avwap
                
                // Draw Anchor Label (Flattened)
                float final_avwap = (target_pv - past_pv) / (target_v - past_v)
                float actual_diff = (final_avwap - target_c) / target_c * 100
                int anchor_time = array.get(time_arr, a_idx)
                float anchor_price = array.get(hlc3_arr, a_idx)
                string lbl_text = "A" + str.tostring(k+1) + "\n" + str.tostring(actual_diff, "#.##") + "%"
                
                label anchor_lbl = label.new(x=anchor_time, y=anchor_price, text=lbl_text, xloc=xloc.bar_time, color=current_color, textcolor=color.white, style=label.style_label_down, size=size.small)
                array.push(drawn_labels, anchor_lbl)
            
            // Draw Target Label (Flattened to resolve error from Screenshot 2026-05-28 at 11.27.47.png)
            int target_x = array.get(time_arr, n - 1)
            string target_text = "Target\n" + str.tostring(target_c, format.mintick)
            label t_lbl = label.new(x=target_x, y=target_c, text=target_text, xloc=xloc.bar_time, color=color.gray, textcolor=color.white, style=label.style_label_up, size=size.small)
            array.push(drawn_labels, t_lbl)
````
