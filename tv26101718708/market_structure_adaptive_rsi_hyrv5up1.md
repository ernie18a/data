# Market Structure Adaptive RSI

- url: https://www.tradingview.com/script/hyrV5uP1-Market-Structure-Adaptive-RSI/
- type: indicator
- pine_id: PUB;31367e4ff86144db81f3434d3e07e6c5
- version: 2.0

## Description

█ OVERVIEW
The Market Structure Adaptive RSI indicator is designed to adjust RSI smoothing based on market structure events (CHOCH and BOS).
RSI does not operate in a single mode — its behavior changes depending on whether the market is:
* changing direction (CHOCH)
* continuing structure (BOS)
Because of this, the indicator:
* switches between normal and smoothed modes
* dynamically adjusts the level of smoothing
* reacts faster to potential pullbacks in extended trends

█ CONCEPTS
Market Structure Adaptive RSI
Market Structure Adaptive RSI is a system that measures the direction and continuity of market structure events.
Based on that:
* it switches RSI behavior (regime switching)
* adapts its smoothing (adaptive smoothing)
RSI changes its characteristics depending on context:
* more stable during trends
* more responsive during structural shifts

Mode Switching Logic (core mechanism)
This is the key part of the indicator:
* After a CHOCH opposite to the last BOS →
RSI switches to normal mode (no smoothing / pullback mode)
* It stays in this mode until a BOS appears
* After a BOS →
RSI switches to **trend mode (smoothed)

BOS / CHOCH in Trend Direction
Once in trend mode:
* every additional BOS
* and CHOCH in the same direction
→ adjusts the RSI smoothing length (based on settings)

Adaptive Smoothing (detailed logic)
Default assumption:
* consecutive structural events in the same direction
→ increase the probability of a pullback
Therefore:
* each additional BOS / CHOCH in trend direction
→ reduces RSI smoothing length
Effect:
* RSI becomes faster in extended trends
* improves early detection of weakening momentum and pullbacks

Multi-Pivot Market Structure
Market structure is analyzed using multiple pivot lengths simultaneously.
This allows:
* detection of both short-term and long-term structures
* aggregation of events
* selection of the most significant breakout (largest pivot)
This reduces noise and improves BOS / CHOCH detection quality.

Event Priority on Multi-Break Candles
If a single candle breaks multiple pivots at once:
* all BOS / CHOCH events are detected normally
* the internal logic processes them independently
The impact applies only to labels (visualization):
* the label displays the event from the largest pivot (highest length)
* CHOCH always has priority over BOS

█ FEATURES
RSI
* Trend RSI Length (after BOS) – RSI length used in trend mode
* Pullback RSI Length – RSI length used after CHOCH (normal mode)
* Smooth RSI in Trend Mode (EMA) – enables/disables smoothing in trend mode

Adaptive Smoothing
* EMA after 1 BoS** – smoothing after first BOS
* EMA after 2 consecutive BoS – smoothing after 2 BOS
* EMA after 3 consecutive BoS – smoothing after 3 BOS
* EMA after 4 consecutive BoS – smoothing after 4 BOS
* EMA after 5+ consecutive BoS – smoothing in strong trends
(Note: by default, higher streaks reduce EMA length → RSI becomes faster)

Market Structure
* Pivot Length 1–5 – pivot lengths used for BOS / CHOCH detection
(Smaller values = more signals, larger values = stronger structure)

Labels
* Show CHOCH / BOS Labels with Length – enables event labels
* Label Offset from RSI Line – vertical offset of labels

Colors
* RSI Line - Above 50 – RSI color above 50
* RSI Line - Below 50 – RSI color below 50
* Overbought Line – OB level color
* Oversold Line – OS level color
* Neutral Line (50) – 50 level color
* Gradient Above OB / Below OS – fill colors outside zones

Candle Coloring
* Color Candles by Trend – colors candles based on RSI direction

OB/OS Levels
* Overbought / Oversold – OB and OS levels
* Dynamic OB/OS (MPO4 Style) – dynamic transparency
* OB/OS Line Width – line thickness
* Minimum / Maximum Transparency – transparency range

█ APPLICATIONS
1. Trend Following
After BOS:
* RSI switches to smoothed mode
* filters noise
* shows stable direction

2. Detecting Trend Weakness
In extended trends:
* consecutive BOS/CHOCH → shorter smoothing
* RSI accelerates
→ easier to spot early signs of pullbacks

3. Pullback Entries
* RSI returns to OB/OS zones
* reacts faster due to reduced smoothing
→ improved entry timing

4. Market Context Shift
* opposite CHOCH → mode reset
* RSI returns to normal mode
→ signal that structure may have changed

█ NOTES
* Smaller pivots → more signals
* Larger pivots → stronger structures
* Smoothing applies only in trend mode
* On multi-break candles, only one label is displayed (priority: CHOCH > BOS)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Market Structure Adaptive RSI", overlay = false, max_labels_count = 500)

// RSI Settings
len_trend    = input.int(14,  "Trend RSI Length (after BOS)",     minval = 10, group = "RSI")
len_pull     = input.int(12,  "Pullback RSI Length",              minval = 5,  group = "RSI")
smooth_trend = input.bool(true, "Smooth RSI in Trend Mode (EMA)", group = "RSI")

// Adaptive Smoothing Settings
weak_ema_len    = input.int(18,  "EMA after 1 BoS",                  minval = 2, group = "Adaptive Smoothing")
streak2_ema_len = input.int(15,  "EMA after 2 consecutive BoS",      minval = 2, group = "Adaptive Smoothing")
streak3_ema_len = input.int(10, "EMA after 3 consecutive BoS",       minval = 2, group = "Adaptive Smoothing")
streak4_ema_len = input.int(5,  "EMA after 4 consecutive BoS",       minval = 2, group = "Adaptive Smoothing")
streak5_ema_len = input.int(2,  "EMA after 5+ consecutive BoS",      minval = 2, group = "Adaptive Smoothing")

// Market Structure Settings
p1 = input.int(5,  "Pivot Length 1", group = "Market Structure")
p2 = input.int(10, "Pivot Length 2", group = "Market Structure")
p3 = input.int(20, "Pivot Length 3", group = "Market Structure")
p4 = input.int(30, "Pivot Length 4", group = "Market Structure")
p5 = input.int(50, "Pivot Length 5", group = "Market Structure")

// Label Settings
show_labels   = input.bool(true,  "Show CHOCH / BOS Labels with Length", group = "Labels")
label_offset  = input.int(5, "Label Offset from RSI Line", minval = 0, group = "Labels")

// Color Settings
rsi_up_color        = input.color(#26a69a,  "RSI Line - Above 50",           group = "Colors")
rsi_down_color      = input.color(#ef5350,    "RSI Line - Below 50",           group = "Colors")
colorCandles        = input.bool(true,          "Color Candles by Trend",         group = "Colors")   

ob_line_color       = input.color(#ef5350,    "Overbought Line",                group = "Colors")
os_line_color       = input.color(#26a69a,  "Oversold Line",                  group = "Colors")
neutral_line_color  = input.color(color.gray,   "Neutral Line (50)",              group = "Colors")

ob_gradient_color = input.color(color.gray, "Gradient Above OB (original style)", group = "Colors")
os_gradient_color = input.color(color.gray, "Gradient Below OS (original style)", group = "Colors")

// OB/OS Settings
obLevel         = input.float(70.0, 'Overbought', step = 0.1, group = "OB/OS Levels")
osLevel         = input.float(30.0, 'Oversold',   step = 0.1, group = "OB/OS Levels")
useDynamicOBOS  = input.bool(true, "Dynamic OB/OS", group = "OB/OS Levels")
obLineWidth     = input.int(4,     "OB/OS Line Width", minval=1, group = "OB/OS Levels")
minTransp       = input.int(90,    "Minimum Transparency (weak – almost invisible)", minval=0, maxval=100, group = "OB/OS Levels")
maxTransp       = input.int(10,    "Maximum Transparency (strong)", minval=0, maxval=100, group = "OB/OS Levels")

// State Variables
var bool in_trend = false
var int  bos_streak = 0

// Arrays for detection
var array<float> broken_highs_1 = array.new_float(0)
var array<float> broken_lows_1  = array.new_float(0)
var array<float> broken_highs_2 = array.new_float(0)
var array<float> broken_lows_2  = array.new_float(0)
var array<float> broken_highs_3 = array.new_float(0)
var array<float> broken_lows_3  = array.new_float(0)
var array<float> broken_highs_4 = array.new_float(0)
var array<float> broken_lows_4  = array.new_float(0)
var array<float> broken_highs_5 = array.new_float(0)
var array<float> broken_lows_5  = array.new_float(0)

// Arrays for events
var array<int>   bos_up_lengths   = array.new_int(0)
var array<float> bos_up_prices    = array.new_float(0)
var array<int>   bos_up_bars      = array.new_int(0)
var array<int>   bos_up_dirs      = array.new_int(0)

var array<int>   bos_down_lengths = array.new_int(0)
var array<float> bos_down_prices  = array.new_float(0)
var array<int>   bos_down_bars    = array.new_int(0)
var array<int>   bos_down_dirs    = array.new_int(0)

// Global variables
var int last_breakout_dir_1 = 0
var int last_breakout_dir_2 = 0
var int last_breakout_dir_3 = 0
var int last_breakout_dir_4 = 0
var int last_breakout_dir_5 = 0

var int last_bos_candle_color = 0

// Pivot Detection Function
f_processPivot(length, broken_highs, broken_lows) =>
    pivot_high = ta.pivothigh(high, length, length)
    pivot_low  = ta.pivotlow(low,  length, length)
    
    var float last_high = na
    var int   last_high_bar = na
    var float last_low  = na
    var int   last_low_bar  = na
    
    if not na(pivot_high)
        last_high := pivot_high
        last_high_bar := bar_index[length]
    
    if not na(pivot_low)
        last_low := pivot_low
        last_low_bar := bar_index[length]
    
    bool cross_up   = ta.crossover(close, last_high)
    bool cross_down = ta.crossunder(close, last_low)
    
    bos_up   = not na(last_high) and cross_up and not array.includes(broken_highs, last_high)
    bos_down = not na(last_low)  and cross_down and not array.includes(broken_lows,  last_low)
    
    float broken_high = na
    int   broken_high_bar = na
    float broken_low  = na
    int   broken_low_bar  = na
    int   new_dir = 0
    
    if bos_up
        array.push(broken_highs, last_high)
        broken_high := last_high
        broken_high_bar := last_high_bar
        new_dir := 1
    
    if bos_down
        array.push(broken_lows, last_low)
        broken_low := last_low
        broken_low_bar := last_low_bar
        new_dir := -1
    
    [bos_up, bos_down, new_dir, broken_high, broken_high_bar, broken_low, broken_low_bar]

// Process pivots
[bos_up_1, bos_down_1, dir1, bh1, bhb1, bl1, blb1] = f_processPivot(p1, broken_highs_1, broken_lows_1)
[bos_up_2, bos_down_2, dir2, bh2, bhb2, bl2, blb2] = f_processPivot(p2, broken_highs_2, broken_lows_2)
[bos_up_3, bos_down_3, dir3, bh3, bhb3, bl3, blb3] = f_processPivot(p3, broken_highs_3, broken_lows_3)
[bos_up_4, bos_down_4, dir4, bh4, bhb4, bl4, blb4] = f_processPivot(p4, broken_highs_4, broken_lows_4)
[bos_up_5, bos_down_5, dir5, bh5, bhb5, bl5, blb5] = f_processPivot(p5, broken_highs_5, broken_lows_5)

last_breakout_dir_1 := bos_up_1 or bos_down_1 ? dir1 : last_breakout_dir_1
last_breakout_dir_2 := bos_up_2 or bos_down_2 ? dir2 : last_breakout_dir_2
last_breakout_dir_3 := bos_up_3 or bos_down_3 ? dir3 : last_breakout_dir_3
last_breakout_dir_4 := bos_up_4 or bos_down_4 ? dir4 : last_breakout_dir_4
last_breakout_dir_5 := bos_up_5 or bos_down_5 ? dir5 : last_breakout_dir_5

// Clear event arrays
array.clear(bos_up_lengths)
array.clear(bos_up_prices)
array.clear(bos_up_bars)
array.clear(bos_up_dirs)
array.clear(bos_down_lengths)
array.clear(bos_down_prices)
array.clear(bos_down_bars)
array.clear(bos_down_dirs)

// Collect upward events
if bos_up_1
    array.push(bos_up_lengths, p1)
    array.push(bos_up_prices, bh1)
    array.push(bos_up_bars, bhb1)
    array.push(bos_up_dirs, last_breakout_dir_1[1])
if bos_up_2
    array.push(bos_up_lengths, p2)
    array.push(bos_up_prices, bh2)
    array.push(bos_up_bars, bhb2)
    array.push(bos_up_dirs, last_breakout_dir_2[1])
if bos_up_3
    array.push(bos_up_lengths, p3)
    array.push(bos_up_prices, bh3)
    array.push(bos_up_bars, bhb3)
    array.push(bos_up_dirs, last_breakout_dir_3[1])
if bos_up_4
    array.push(bos_up_lengths, p4)
    array.push(bos_up_prices, bh4)
    array.push(bos_up_bars, bhb4)
    array.push(bos_up_dirs, last_breakout_dir_4[1])
if bos_up_5
    array.push(bos_up_lengths, p5)
    array.push(bos_up_prices, bh5)
    array.push(bos_up_bars, bhb5)
    array.push(bos_up_dirs, last_breakout_dir_5[1])

// Collect downward events
if bos_down_1
    array.push(bos_down_lengths, p1)
    array.push(bos_down_prices, bl1)
    array.push(bos_down_bars, blb1)
    array.push(bos_down_dirs, last_breakout_dir_1[1])
if bos_down_2
    array.push(bos_down_lengths, p2)
    array.push(bos_down_prices, bl2)
    array.push(bos_down_bars, blb2)
    array.push(bos_down_dirs, last_breakout_dir_2[1])
if bos_down_3
    array.push(bos_down_lengths, p3)
    array.push(bos_down_prices, bl3)
    array.push(bos_down_bars, blb3)
    array.push(bos_down_dirs, last_breakout_dir_3[1])
if bos_down_4
    array.push(bos_down_lengths, p4)
    array.push(bos_down_prices, bl4)
    array.push(bos_down_bars, blb4)
    array.push(bos_down_dirs, last_breakout_dir_4[1])
if bos_down_5
    array.push(bos_down_lengths, p5)
    array.push(bos_down_prices, bl5)
    array.push(bos_down_bars, blb5)
    array.push(bos_down_dirs, last_breakout_dir_5[1])

// Event Collection (any_choch / any_bos flags)
bool any_choch = false
bool any_bos   = false

// Upward events processing
int up_size = array.size(bos_up_lengths)
if up_size > 0
    array<float> unique_up_prices = array.new_float(0)
    for i = 0 to up_size - 1
        float p = array.get(bos_up_prices, i)
        if not array.includes(unique_up_prices, p)
            array.push(unique_up_prices, p)
    for j = 0 to array.size(unique_up_prices) - 1
        float curr_p = array.get(unique_up_prices, j)
        int local_max_len = 0
        int max_idx = -1
        for k = 0 to up_size - 1
            if array.get(bos_up_prices, k) == curr_p and array.get(bos_up_lengths, k) > local_max_len
                local_max_len := array.get(bos_up_lengths, k)
                max_idx := k
        if max_idx >= 0
            int the_dir = array.get(bos_up_dirs, max_idx)
            if the_dir == -1
                any_choch := true
            else
                any_bos := true

// Downward events processing
int down_size = array.size(bos_down_lengths)
if down_size > 0
    array<float> unique_down_prices = array.new_float(0)
    for i = 0 to down_size - 1
        float p = array.get(bos_down_prices, i)
        if not array.includes(unique_down_prices, p)
            array.push(unique_down_prices, p)
    for j = 0 to array.size(unique_down_prices) - 1
        float curr_p = array.get(unique_down_prices, j)
        int local_max_len = 0
        int max_idx = -1
        for k = 0 to down_size - 1
            if array.get(bos_down_prices, k) == curr_p and array.get(bos_down_lengths, k) > local_max_len
                local_max_len := array.get(bos_down_lengths, k)
                max_idx := k
        if max_idx >= 0
            int the_dir = array.get(bos_down_dirs, max_idx)
            if the_dir == 1
                any_choch := true
            else
                any_bos := true

// Trend Mode and BOS Streak Logic
int curr_color = close > open ? 1 : (close < open ? -1 : 0)

bool valid_choch = any_choch and (curr_color != last_bos_candle_color and curr_color != 0)
bool same_color_choch = false

if any_choch
    same_color_choch := curr_color == last_bos_candle_color and curr_color != 0

if valid_choch
    in_trend := false
    bos_streak := 0
else if any_bos or same_color_choch
    in_trend := true
    bos_streak += 1

if any_bos or same_color_choch
    last_bos_candle_color := curr_color

// Adaptive RSI Calculation
rsi_trend_base = ta.rsi(close, len_trend)
rsi_pull       = ta.rsi(close, len_pull)

ema_weak   = ta.ema(rsi_trend_base, weak_ema_len)
ema2       = ta.ema(rsi_trend_base, streak2_ema_len)
ema3       = ta.ema(rsi_trend_base, streak3_ema_len)
ema4       = ta.ema(rsi_trend_base, streak4_ema_len)
ema5       = ta.ema(rsi_trend_base, streak5_ema_len)

float rsi_smoothed = rsi_pull
if in_trend
    if bos_streak >= 5
        rsi_smoothed := ema5
    else if bos_streak >= 4
        rsi_smoothed := ema4
    else if bos_streak >= 3
        rsi_smoothed := ema3
    else if bos_streak >= 2
        rsi_smoothed := ema2
    else
        rsi_smoothed := ema_weak

rsi_raw    = in_trend ? rsi_trend_base : rsi_pull
rsi_final  = in_trend and smooth_trend ? rsi_smoothed : rsi_raw

// Colors and Signals
color line_color = rsi_final > 50 ? rsi_up_color : rsi_down_color

longSignal  = rsi_final[1] <= osLevel and rsi_final > osLevel
shortSignal = rsi_final[1] >= obLevel and rsi_final < obLevel

// CHOCH/BOS Labels (color based only on direction)
if show_labels
    color bull_label_color = color.new(rsi_up_color, 10)
    color bear_label_color = color.new(rsi_down_color, 10)
    
    // Upward Events
    if up_size > 0
        array<float> unique_up_prices = array.new_float(0)
        for i = 0 to up_size - 1
            float p = array.get(bos_up_prices, i)
            if not array.includes(unique_up_prices, p)
                array.push(unique_up_prices, p)
        for j = 0 to array.size(unique_up_prices) - 1
            float curr_p = array.get(unique_up_prices, j)
            int local_max_len = 0
            int max_idx = -1
            for k = 0 to up_size - 1
                if array.get(bos_up_prices, k) == curr_p and array.get(bos_up_lengths, k) > local_max_len
                    local_max_len := array.get(bos_up_lengths, k)
                    max_idx := k
            if max_idx >= 0
                int the_dir = array.get(bos_up_dirs, max_idx)
                string label_text = the_dir == -1 ? "CHOCH " + str.tostring(local_max_len) : "BOS " + str.tostring(local_max_len)
                
                label.new(bar_index, rsi_final - label_offset, 
                          text = label_text,
                          color = bull_label_color, 
                          textcolor = color.black,
                          style = label.style_label_up, size = size.small)

    // Downward Events
    if down_size > 0
        array<float> unique_down_prices = array.new_float(0)
        for i = 0 to down_size - 1
            float p = array.get(bos_down_prices, i)
            if not array.includes(unique_down_prices, p)
                array.push(unique_down_prices, p)
        for j = 0 to array.size(unique_down_prices) - 1
            float curr_p = array.get(unique_down_prices, j)
            int local_max_len = 0
            int max_idx = -1
            for k = 0 to down_size - 1
                if array.get(bos_down_prices, k) == curr_p and array.get(bos_down_lengths, k) > local_max_len
                    local_max_len := array.get(bos_down_lengths, k)
                    max_idx := k
            if max_idx >= 0
                int the_dir = array.get(bos_down_dirs, max_idx)
                string label_text = the_dir == 1 ? "CHOCH " + str.tostring(local_max_len) : "BOS " + str.tostring(local_max_len)
                
                label.new(bar_index, rsi_final + label_offset, 
                          text = label_text,
                          color = bear_label_color, 
                          textcolor = color.white,
                          style = label.style_label_down, size = size.small)

// Chart Rendering
rsi_bull_peak = color.new(rsi_up_color, 65)
rsi_bull_mid  = color.new(rsi_up_color, 90)
rsi_bear_peak = color.new(rsi_down_color, 65)
rsi_bear_mid  = color.new(rsi_down_color, 90)

fadeDistance = obLevel - osLevel

remap(val, inMin, inMax, outMin, outMax) => outMin + (val - inMin) * (outMax - inMin) / (inMax - inMin)

getDynamicOBColor() =>
    if not useDynamicOBOS
        ob_line_color
    else
        rawDist = obLevel - rsi_final
        clamped = math.max(0, math.min(rawDist, fadeDistance))
        transp  = math.round(remap(clamped, 0, fadeDistance, maxTransp, minTransp))
        color.new(ob_line_color, transp)

getDynamicOSColor() =>
    if not useDynamicOBOS
        os_line_color
    else
        rawDist = rsi_final - osLevel
        clamped = math.max(0, math.min(rawDist, fadeDistance))
        transp  = math.round(remap(clamped, 0, fadeDistance, maxTransp, minTransp))
        color.new(os_line_color, transp)

// Gradient vs 50
p_rsi = plot(rsi_final, color = na, display = display.none)
p50   = plot(50,        color = na, display = display.none)

fill(p_rsi, p50, top_value = rsi_final >= 50 ? rsi_final : na, bottom_value = rsi_final >= 50 ? 50 : na, top_color = rsi_final >= 50 ? rsi_bull_peak : na, bottom_color = rsi_final >= 50 ? rsi_bull_mid  : na)
fill(p50, p_rsi, top_value = rsi_final < 50 ? 50 : na, bottom_value = rsi_final < 50 ? rsi_final : na, top_color = rsi_final < 50 ? rsi_bear_mid  : na, bottom_color = rsi_final < 50 ? rsi_bear_peak : na)

// OB/OS Lines
plot(obLevel, title = "Overbought", color = getDynamicOBColor(), linewidth = obLineWidth)
plot(osLevel, title = "Oversold",   color = getDynamicOSColor(), linewidth = obLineWidth)
hline(50, "Neutral", color = neutral_line_color, linestyle = hline.style_dotted)

// Gradient above/below OB/OS
p100 = plot(100, color = na)
pOB  = plot(obLevel, color = na)
p0   = plot(0,   color = na)
pOS  = plot(osLevel, color = na)

pOB_top = plot(obLevel + 10, color = na, display = display.none)
pOS_bot = plot(osLevel - 10, color = na, display = display.none)

fill(pOB_top, pOB,  color = (in_trend and smooth_trend) ? color.new(ob_gradient_color, 80) : na)
fill(pOS, pOS_bot, color = (in_trend and smooth_trend) ? color.new(os_gradient_color, 80) : na)

// Main RSI Line + Signals
plot(rsi_final, title = "Adaptive RSI", color = line_color, linewidth = 2)

plotshape(longSignal  ? osLevel - 5 : na, title="Long Signal",  location=location.absolute, color=rsi_up_color,   style=shape.triangleup,   size=size.small)
plotshape(shortSignal ? obLevel + 5 : na, title="Short Signal", location=location.absolute, color=rsi_down_color,  style=shape.triangledown, size=size.small)

// Color Candles by Trend
barcolor(colorCandles ? line_color : na)

// ALERTS 
alertcondition(longSignal,  title="Long Signal",  message="Adaptive RSI - Long Signal (crossing above Oversold)")
alertcondition(shortSignal, title="Short Signal", message="Adaptive RSI - Short Signal (crossing below Overbought)")
alertcondition(any_choch,   title="CHOCH Detected", message="CHOCH Detected - Potential trend reversal")
alertcondition(any_bos,     title="BOS Detected",   message="BOS Detected - Break of Structure")
````
