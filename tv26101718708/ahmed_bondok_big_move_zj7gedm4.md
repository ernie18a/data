# AHMED BONDOK BIG MOVE

- url: https://www.tradingview.com/script/ZJ7GeDm4/
- type: indicator
- pine_id: PUB;620c252c482e433984ab1435bfab4617
- version: 1.0

## Description

This technical indicator, titled "MA PROBABILITY PIVOT PRO", is a professional-grade analysis tool designed for TradingView. It is specifically engineered to identify high-probability institutional entry points using a 3-candle sequence: Pivot, Fair Value Gap (FVG), and the Run.

Unlike standard indicators, this tool utilizes a Behavioral Probability Engine that calculates the strength of a move in real-time based on market mechanics rather than lagging averages.

## Core Methodology: The 1-2-3 Sequence
The indicator tracks a specific structural shift in the market:

Candle 1 (PIVOT): Identifies the structural turning point where liquidity is trapped or neutralized.

Candle 2 (FVG): Detects a "Fair Value Gap," signaling an imbalance where institutional orders are overwhelming the market.

Candle 3 (RUN): The confirmation candle that breaks the structural high/low with momentum, triggering the signal.

## Key Features & Logic
Dynamic Probability Scoring: Every signal is assigned a confidence percentage (e.g., 55% to 95%). This is calculated based on:

The "No Overlap" Rule: If the price leaves a clean gap and refuses to return to the FVG, the probability increases (+15%).

Momentum Weighting: If the "Run" candle is larger than the "Pivot" candle, it indicates aggressive buying/selling (+10%).

Fast Absorption: Rapid breaks of the pivot level add further confidence (+5%).

Institutional "Safe Zones": The indicator draws extended boxes across the FVG and Run levels. As long as the price holds above these zones (for longs) or below (for shorts), the trend remains valid.

Entry Price Visualization: A clean, dashed horizontal line marks the exact institutional entry price for easy tracking.

Visual Efficiency: Uses a compact labeling system with "★ TOP" designations for exceptional setups, ensuring your chart remains professional and uncluttered.

## How to Trade with it
High Confidence Signals (>75%): These represent "Exceptional" setups where momentum and structural gaps align perfectly. They often lead to rapid expansions.

The Numbering System: Clearly labeled 1 (PIVOT), 2, and 3 candles help you visualize the "story" behind the move as it unfolds.

Risk Management: The extended boxes act as dynamic support/resistance. A close back inside or through the box usually signals a shift in market sentiment.

Note: This indicator is optimized for high-volatility assets like the Nasdaq (US100), Bitcoin, and Gold, where institutional "Run" behaviors are most prominent.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AHMED BONDOK BIG MOVE

//@version=6
indicator('AHMED BONDOK BIG MOVE', 'AHMED BONDOK BIG MOVE', overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ———————————————————— SETTINGS & INPUTS ———————————————————— {
// Probability Weighting Settings
grp_prob = "Probability Weights (Logic Control)"
base_prob = input.float(55.0, "Base Probability %", minval=0, maxval=100, group=grp_prob)
gap_weight = input.float(15.0, "No Overlap (Gap) Weight", group=grp_prob)
mom_weight = input.float(10.0, "Momentum Weight", group=grp_prob)
abs_weight = input.float(5.0, "Fast Absorption Weight", group=grp_prob)

// Visual Settings
grp_vis = "Visual Customization"
bull_col = input.color(#17dfad, "Bullish Color", group=grp_vis, inline="c1")
bear_col = input.color(#dd326b, "Bearish Color", group=grp_vis, inline="c1")
lbl_size  = input.string(size.small, "Box/Font Size", options=[size.tiny, size.small, size.normal, size.large], group=grp_vis, tooltip="Small size makes the label box more compact.")
box_transp = input.int(85, "Box Transparency", minval=0, maxval=100, group=grp_vis)
show_num = input.bool(true, "Show Candle Numbering & Labels", group=grp_vis)

// Management
signals_to_show = input.int(1, "Latest Signals Count", minval=1, maxval=5, group="Management")
// }

// ———————————————————— CORE CALCULATIONS ———————————————————— {
float p_high = ta.pivothigh(1, 1)
float p_low  = ta.pivotlow(1, 1)

bool bull_fvg = low[0] > high[2]
bool bear_fvg = high[0] < low[2]

bool bull_run = close[0] > high[1] and bull_fvg[1]
bool bear_run = close[0] < low[1] and bear_fvg[1]

calculate_prob(is_bull) =>
    float p = base_prob
    if is_bull
        if low[0] > high[2] 
            p += gap_weight
        if math.abs(close[0]-open[0]) > math.abs(high[1]-low[1])
            p += mom_weight
        if close[0] > high[2] * 1.001
            p += abs_weight
    else
        if high[0] < low[2]
            p += gap_weight
        if math.abs(close[0]-open[0]) > math.abs(high[1]-low[1])
            p += mom_weight
        if close[0] < low[2] * 0.999
            p += abs_weight
    math.min(p, 95.0)

// ———————————————————— VISUAL EXECUTION ———————————————————— {
var array<label> labels_arr = array.new<label>(0)
var array<box> boxes_arr = array.new<box>(0)
var array<line> lines_arr = array.new<line>(0)

if bull_run or bear_run
    color main_col = bull_run ? bull_col : bear_col
    float current_prob = calculate_prob(bull_run)
    string direction = bull_run ? "BULL" : "BEAR"
    
    // 1. Numbering & Pivot Labels
    if show_num
        // Candle 1 - PIVOT
        label.new(bar_index-2, bull_run ? low[2] : high[2], "1\nPIVOT", 
             style=label.style_none, 
             textcolor=chart.fg_color, 
             size=size.tiny, 
             textalign=text.align_center)
        // Candle 2
        label.new(bar_index-1, bull_run ? low[1] : high[1], "2", 
             style=label.style_none, 
             textcolor=chart.fg_color, 
             size=size.tiny)
    
    // 2. Compact Signal Label
    lbl_text = direction + " " + str.tostring(current_prob) + "%" + (current_prob > 75 ? "\n★ TOP" : "")
    
    main_lbl = label.new(bar_index, bull_run ? low : high, 
         text = lbl_text,
         color = color.new(main_col, 10),
         style = bull_run ? label.style_label_up : label.style_label_down,
         textcolor = color.white,
         size = lbl_size)
    array.push(labels_arr, main_lbl)
    
    // 3. Dynamic Boxes (Safe Zones)
    bx = box.new(bar_index-1, bull_run ? high[2] : low[2], bar_index + 10, bull_run ? low[0] : high[0],
         bgcolor = color.new(main_col, box_transp),
         border_color = color.new(main_col, 40),
         extend = extend.right)
    array.push(boxes_arr, bx)

    // 4. Entry Price Line
    ln = line.new(bar_index, close[0], bar_index + 15, close[0], 
         color = color.new(main_col, 30), 
         width = 1, 
         style = line.style_dashed, 
         extend = extend.right)
    array.push(lines_arr, ln)
    
    if array.size(labels_arr) > signals_to_show
        label.delete(array.shift(labels_arr))
        box.delete(array.shift(boxes_arr))
        line.delete(array.shift(lines_arr))

bgcolor((bull_run or bear_run) ? color.new(bull_run ? bull_col : bear_col, 92) : na)
// }
````
