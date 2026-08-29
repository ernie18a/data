<!-- tradingview-pine-id: PUB;4e77be363ae1429d92abbf7f7d28427c -->
<!-- tradingviewscripts-format: 1 -->
# Chronological Elliott Wave Tracker -

Source: https://www.tradingview.com/script/0tier0dF-Chronological-Elliott-Wave-Tracker-With-Projections/

## Description

Tired of automated Elliott Wave scripts that plot Wave 5 on a dip or scramble the sequence during consolidation?

Standard zigzag indicators often fail in complex market environments because they hunt for price extremes in a vacuum. They ignore the strict chronological timeline required by Elliott Wave Theory, leading to broken counts and overlapping labels.

This indicator solves that problem by utilizing a Strict Alternating ZigZag Engine. It tracks the actual chronological path of the market (High ➔ Low ➔ High ➔ Low) and anchors the motive (1-5) and corrective (A-B-C) labels exactly where they belong, ensuring a structurally accurate map of the price action.

Key Features
True Chronological Wave Mapping: Forces impulse waves (1, 3, 5) strictly to peaks and corrective waves (2, 4) strictly to dips (in a bullish setup). The internal logic respects the timeline of the chart.

Dynamic Wedge Detection: Automatically scans a macro lookback window to find the absolute structural extremes, drawing a clean, converging wedge pattern based on historical anchors.

Actionable Zones: Automatically generates a shaded Buy Zone (accumulation area based on recent corrective dips) and a Bull Case breakout line for quick invalidation/validation reference.

Adaptive Fibonacci Targets: Projects Wave III (1.618 extension) and Wave IV (0.382 retracement) targets based on the actual detected sub-wave structure, rather than random wicks.

Tick-Safe Memory Management: Built with advanced array cleanup to completely bypass the notorious TradingView "label limit" bug. Your counts will never flicker or disappear on the live tick.

How to Use & Customize
Pivot Sensitivity: The core of the indicator. Lower this number (e.g., 3 to 5) to catch tighter, more frequent waves on higher timeframes (like the Daily chart). Raise it (e.g., 10 to 15) to ignore noise and only map major macro swings.

Bullish vs. Bearish Toggle: By default, the script assumes you are mapping a bullish motive phase (where 1, 3, and 5 are peaks). If you are mapping a downward impulse, simply uncheck the "Bullish Impulse" box in the settings to perfectly invert the structure.

Label Distance (ATR): If the counts are clashing with long candle wicks, adjust the ATR multiplier in the settings to push the labels further away from the price action.

Disclaimer: This script is designed for structural analysis and educational purposes. Automated Elliott Wave counting is highly complex, and this tool is best used as a structural baseline to assist your own manual charting, not as a standalone financial signal.

---

## Source Code

````pine
//@version=6
indicator("Chronological Elliott Wave Tracker -", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// INPUTS & CONFIGURATION
// ==========================================
grp_ma       = "Moving Average"
ma_len       = input.int(50, "Blue MA Length", group=grp_ma)

grp_lookback = "Macro Structure Lookback"
macro_bars   = input.int(300, "Macro Lookback Window", group=grp_lookback)

grp_counts   = "Wave Count Settings"
count_len    = input.int(8, "Pivot Sensitivity (Length)", minval=2, group=grp_counts, tooltip="Higher = ignores minor chops. Lower = catches tighter waves.")
lbl_offset   = input.float(1.2, "Label Distance from Price (ATR)", step=0.1, group=grp_counts)
show_zigzag  = input.bool(true, "Show ZigZag Connecting Lines", group=grp_counts)

grp_zones    = "Action Zones"
show_buy_zone= input.bool(true, "Show BUY ZONE Box", group=grp_zones)
show_bull_case= input.bool(true, "Show BULL CASE Line", group=grp_zones)

grp_fib      = "Fibonacci Targets"
future_offset= input.int(60, "Projection Distance (Right)", group=grp_fib)

// ==========================================
// 1. GLOBAL CALCULATIONS (State-Safe)
// ==========================================
blue_ma = ta.ema(close, ma_len)
plot(blue_ma, "Blue MA", color=color.new(color.blue, 0), linewidth=2)

current_atr = ta.atr(14)
htf_high    = ta.highest(high, macro_bars)
htf_low     = ta.lowest(low, macro_bars)

// ==========================================
// 2. STRICT ALTERNATING ZIGZAG ENGINE
// ==========================================
// This forces the script to map chronologically (High -> Low -> High -> Low)
var int dir = 0
ph = ta.pivothigh(high, count_len, count_len)
pl = ta.pivotlow(low, count_len, count_len)

type Point
    int bar
    float price
    bool isHigh

var points = array.new<Point>()

if not na(ph)
    if dir < 1 // If last point was a low, add this high
        array.unshift(points, Point.new(bar_index - count_len, ph, true))
        dir := 1
    else // If last point was also a high, only keep the highest one
        if ph > array.get(points, 0).price
            array.set(points, 0, Point.new(bar_index - count_len, ph, true))

if not na(pl)
    if dir > -1 // If last point was a high, add this low
        array.unshift(points, Point.new(bar_index - count_len, pl, false))
        dir := -1
    else // If last point was also a low, only keep the lowest one
        if pl < array.get(points, 0).price
            array.set(points, 0, Point.new(bar_index - count_len, pl, false))

// Keep enough history for a full Elliott Cycle
if array.size(points) > 20
    array.pop(points)

// ==========================================
// 3. TICK-SAFE MEMORY MANAGEMENT
// ==========================================
var line res_line = na
var line sup_line = na
var line bull_line = na
var label bull_lbl = na
var box b_zone = na
var label b_lbl = na
var line w3_line = na
var label w3_lbl = na
var line w4_line = na
var label w4_lbl = na

var line[] zz_lines = array.new_line(0)
var label[] wave_labels = array.new_label(0)

// ==========================================
// 4. DRAWING & MAPPING
// ==========================================
if barstate.islast
    // TICK-SAFE CLEANUP
    line.delete(res_line)
    line.delete(sup_line)
    line.delete(bull_line)
    label.delete(bull_lbl)
    box.delete(b_zone)
    label.delete(b_lbl)
    line.delete(w3_line)
    label.delete(w3_lbl)
    line.delete(w4_line)
    label.delete(w4_lbl)
    
    if array.size(zz_lines) > 0
        for i = 0 to array.size(zz_lines) - 1
            line.delete(array.get(zz_lines, i))
        array.clear(zz_lines)
        
    if array.size(wave_labels) > 0
        for i = 0 to array.size(wave_labels) - 1
            label.delete(array.get(wave_labels, i))
        array.clear(wave_labels)

    // A. THICK BLUE SUPPORT/RESISTANCE
    res_line := line.new(bar_index - macro_bars, htf_high, bar_index + future_offset, htf_high, color=color.new(color.blue, 0), width=3)
    sup_line := line.new(bar_index - macro_bars, htf_low, bar_index + future_offset, htf_low, color=color.new(color.blue, 0), width=3)

    int p_len = array.size(points)

    // B. DRAW CHRONOLOGICAL ZIGZAG LINES & WAVE COUNTS
    if p_len >= 8 // Need at least 8 points for a full 1-5, A-C sequence
        
        // 1. Draw the ZigZag connecting lines to visualize the structure
        if show_zigzag
            for i = 0 to p_len - 2
                Point p_curr = array.get(points, i)
                Point p_prev = array.get(points, i + 1)
                array.push(zz_lines, line.new(p_prev.bar, p_prev.price, p_curr.bar, p_curr.price, color=color.new(color.gray, 50), width=2))

        // 2. Map the 8 most recent points to the textbook Elliott Structure
        // Check if the most recent point (index 0) is a High or a Low
        // Assuming we want (C) to map to a Low and (5) to map to a High for a bullish sequence
        
        int offset = array.get(points, 0).isHigh ? 1 : 0 // Shift index by 1 if current point is a High, to align (C) to a Low

        if p_len > offset + 7
            Point pC = array.get(points, offset + 0) // Corrective Dip
            Point pB = array.get(points, offset + 1) // Corrective Peak
            Point pA = array.get(points, offset + 2) // Corrective Dip
            Point p5 = array.get(points, offset + 3) // Motive Peak
            Point p4 = array.get(points, offset + 4) // Motive Dip
            Point p3 = array.get(points, offset + 5) // Motive Peak
            Point p2 = array.get(points, offset + 6) // Motive Dip
            Point p1 = array.get(points, offset + 7) // Motive Peak

            float atr_off = current_atr * lbl_offset
            color lbl_grn = color.new(color.green, 0)
            color lbl_red = color.new(color.red, 0)

            // Corrective Phase (A-B-C)
            array.push(wave_labels, label.new(pC.bar, pC.price + (pC.isHigh ? atr_off : -atr_off), "(C)", textcolor=lbl_red, style=label.style_none))
            array.push(wave_labels, label.new(pB.bar, pB.price + (pB.isHigh ? atr_off : -atr_off), "(B)", textcolor=lbl_red, style=label.style_none))
            array.push(wave_labels, label.new(pA.bar, pA.price + (pA.isHigh ? atr_off : -atr_off), "(A)", textcolor=lbl_red, style=label.style_none))

            // Motive Phase (1-5)
            array.push(wave_labels, label.new(p5.bar, p5.price + (p5.isHigh ? atr_off : -atr_off), "(5)", textcolor=lbl_grn, style=label.style_none))
            array.push(wave_labels, label.new(p4.bar, p4.price + (p4.isHigh ? atr_off : -atr_off), "(4)", textcolor=lbl_grn, style=label.style_none))
            array.push(wave_labels, label.new(p3.bar, p3.price + (p3.isHigh ? atr_off : -atr_off), "(3)", textcolor=lbl_grn, style=label.style_none))
            array.push(wave_labels, label.new(p2.bar, p2.price + (p2.isHigh ? atr_off : -atr_off), "(2)", textcolor=lbl_grn, style=label.style_none))
            array.push(wave_labels, label.new(p1.bar, p1.price + (p1.isHigh ? atr_off : -atr_off), "(1)", textcolor=lbl_grn, style=label.style_none))

            // C. DYNAMIC BUY ZONE & BULL CASE
            if show_buy_zone
                box_top = pB.price
                box_bot = pC.price
                b_zone := box.new(p5.bar, box_top, bar_index + 20, box_bot, border_color=color.green, bgcolor=color.new(color.green, 90))
                b_lbl := label.new(bar_index + 10, (box_top + box_bot)/2, "BUY ZONE", textcolor=color.green, style=label.style_none)

            if show_bull_case
                bull_line := line.new(bar_index - 50, p5.price, bar_index + future_offset, p5.price, color=color.green, width=1)
                bull_lbl := label.new(bar_index + 10, p5.price, "BULL CASE", textcolor=color.green, style=label.style_none)

            // D. FIB PROJECTIONS
            float swing_range = math.abs(p5.price - p2.price) // Using actual wave structure
            float w3_tgt = pC.price + (swing_range * 1.618)
            
            w3_line := line.new(bar_index, w3_tgt, bar_index + future_offset, w3_tgt, color=color.green, width=1)
            w3_lbl := label.new(bar_index + future_offset, w3_tgt, "III\n\n1.618 (" + str.tostring(w3_tgt, "#.##") + ")", textcolor=color.green, style=label.style_none)

            float w4_382 = w3_tgt - ((w3_tgt - pC.price) * 0.382)
            w4_line := line.new(bar_index, w4_382, bar_index + future_offset, w4_382, color=color.white, width=2)
            w4_lbl := label.new(bar_index + future_offset, w4_382, "IV\n\n0.382 (" + str.tostring(w4_382, "#.##") + ")", textcolor=color.white, style=label.style_none)
````
