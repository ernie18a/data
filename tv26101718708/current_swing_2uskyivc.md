# Current Swing

- url: https://www.tradingview.com/script/2uSkYIVC-Current-Swing/
- type: indicator
- pine_id: PUB;332f6bceb4d447f59f512a859f6ba1bc
- version: 5.0

## Description

The Current Swing indicator automatically identifies the most recent valid Swing High and Swing Low points on a higher timeframe (e.g., 3m) and projects key Fibonacci retracement levels directly onto your lower timeframe chart (e.g., 1m).

Pullback Depth Analysis: Maps out the 0%, 40%, 50%, 60%, and 100% levels of the active swing range to gauge market retracement depth.

Trend Continuation Insight: Helps you instantly assess whether price is holding premium/discount zones or pulling back too deeply, indicating whether a continuation is likely or if the structure is failing.

Sweep Protection: Filters out noise by only plotting confirmed swings that have remained unswept for a customizable period, keeping your chart clean and focused on valid structure.

## Source Code

````pine
//@version=6
indicator("Relevant Macro Swing Range", overlay=true, max_lines_count=100, max_labels_count=100)

// --- INPUTS ---
group_swing   = "Swing Structure & Relevance"
pivot_len     = input.int(10, "Pivot Lookback (Größer = Makro-Swings)", minval=2, maxval=100, group=group_swing)
use_atr_filter= input.bool(true, "Min. Range Filter (ATR-basiert)", group=group_swing)
atr_length    = input.int(14, "ATR Length", group=group_swing)
atr_mult      = input.float(2.0, "Min. ATR Multiplier (Höher = ignoriert kleine Swings)", minval=0.5, step=0.5, group=group_swing)

group_fib     = "Fibonacci Pullback Levels"
show_fib      = input.bool(true, "Show Fib Levels", group=group_fib)
color_50      = input.color(#0cc513, "50% Midline Color", group=group_fib)
color_outer   = input.color(#636363, "40% & 60% Color", group=group_fib)
line_width    = input.int(1, "Line Width", minval=1, maxval=4, group=group_fib)

// --- ATR CALCULATION FOR SWING FILTER ---
atr_val = ta.atr(atr_length)
min_range_size = use_atr_filter ? (atr_val * atr_mult) : 0.0

// --- PIVOT DETECTION ---
p_high = ta.pivothigh(high, pivot_len, pivot_len)
p_low  = ta.pivotlow(low, pivot_len, pivot_len)

var float macro_high = na
var float macro_low  = na
var int   high_bar   = na
var int   low_bar    = na
var bool  is_bullish = true

// Temp variables to track potential pivots
var float temp_high = na
var int   temp_high_bar = na
var float temp_low = na
var int   temp_low_bar = na

if not na(p_high)
    temp_high := p_high
    temp_high_bar := bar_index[pivot_len]

if not na(p_low)
    temp_low := p_low
    temp_low_bar := bar_index[pivot_len]

// --- MACRO STRUCTURE ENGINE ---
// Initializing first range
if na(macro_high) and not na(temp_high)
    macro_high := temp_high
    high_bar   := temp_high_bar

if na(macro_low) and not na(temp_low)
    macro_low := temp_low
    low_bar   := temp_low_bar

// Update Macro High/Low only if range size condition is met or Structure is broken
if not na(temp_high) and not na(macro_low)
    if (temp_high - macro_low) >= min_range_size
        if na(macro_high) or temp_high > macro_high or temp_high_bar > low_bar
            if temp_high > macro_high or na(high_bar) or temp_high_bar > high_bar
                macro_high := temp_high
                high_bar   := temp_high_bar
                if high_bar > low_bar
                    is_bullish := true

if not na(temp_low) and not na(macro_high)
    if (macro_high - temp_low) >= min_range_size
        if na(macro_low) or temp_low < macro_low or temp_low_bar > high_bar
            if temp_low < macro_low or na(low_bar) or temp_low_bar > low_bar
                macro_low := temp_low
                low_bar   := temp_low_bar
                if low_bar > high_bar
                    is_bullish := false

// --- REALTIME BREAKOUT EXPANSION ---
if not na(macro_high) and high > macro_high
    macro_high := high
    high_bar   := bar_index
    is_bullish := true

if not na(macro_low) and low < macro_low
    macro_low := low
    low_bar   := bar_index
    is_bullish := false

// --- DYNAMIC FIBONACCI CALCULATIONS ---
float range_val = macro_high - macro_low

float level_0   = na
float level_40  = na
float level_50  = macro_high - (range_val * 0.50)
float level_60  = na
float level_100 = na

if is_bullish
    level_0   := macro_low
    level_40  := macro_high - (range_val * 0.40)
    level_60  := macro_high - (range_val * 0.60)
    level_100 := macro_high
else
    level_0   := macro_high
    level_40  := macro_low + (range_val * 0.40)
    level_60  := macro_low + (range_val * 0.60)
    level_100 := macro_low

// --- GRAPHICAL RENDERING ---
var line line_100 = na
var line line_60  = na
var line line_50  = na
var line line_40  = na
var line line_0   = na

var label lbl_100 = na
var label lbl_60  = na
var label lbl_50  = na
var label lbl_40  = na
var label lbl_0   = na

if show_fib and not na(macro_high) and not na(macro_low) and range_val > 0
    line.delete(line_100)
    line.delete(line_60)
    line.delete(line_50)
    line.delete(line_40)
    line.delete(line_0)

    label.delete(lbl_100)
    label.delete(lbl_60)
    label.delete(lbl_50)
    label.delete(lbl_40)
    label.delete(lbl_0)

    int start_x = math.min(nz(low_bar, bar_index), nz(high_bar, bar_index))
    int end_x   = bar_index + 8

    int x_0   = is_bullish ? low_bar  : high_bar
    int x_100 = is_bullish ? high_bar : low_bar

    line_100 := line.new(x1=x_100,   y1=level_100, x2=end_x, y2=level_100, color=color_outer, style=line.style_solid, width=line_width)
    line_60  := line.new(x1=start_x, y1=level_60,  x2=end_x, y2=level_60,  color=color_outer, style=line.style_dotted, width=line_width)
    line_50  := line.new(x1=start_x, y1=level_50,  x2=end_x, y2=level_50,  color=color_50,    style=line.style_solid,  width=line_width + 1)
    line_40  := line.new(x1=start_x, y1=level_40,  x2=end_x, y2=level_40,  color=color_outer, style=line.style_dotted, width=line_width)
    line_0   := line.new(x1=x_0,     y1=level_0,   x2=end_x, y2=level_0,   color=color_outer, style=line.style_solid, width=line_width)

    lbl_100 := label.new(x=end_x, y=level_100, text="100%", color=color.new(color.black, 100), textcolor=color_outer, style=label.style_label_left, size=size.small)
    lbl_60  := label.new(x=end_x, y=level_60,  text="60%",  color=color.new(color.black, 100), textcolor=color_outer, style=label.style_label_left, size=size.small)
    lbl_50  := label.new(x=end_x, y=level_50,  text="50%",  color=color.new(color.black, 100), textcolor=color_50,    style=label.style_label_left, size=size.small)
    lbl_40  := label.new(x=end_x, y=level_40,  text="40%",  color=color.new(color.black, 100), textcolor=color_outer, style=label.style_label_left, size=size.small)
    lbl_0   := label.new(x=end_x, y=level_0,   text="0%",   color=color.new(color.black, 100), textcolor=color_outer, style=label.style_label_left, size=size.small)
````
