# Internal and External Liquidity

- url: https://www.tradingview.com/script/6VnkqYj4-Internal-and-External-Liquidity/
- type: indicator
- pine_id: PUB;b905533e54774533b7d7392fc11e16dc
- version: 1.0

## Description

This script is designed to visualize one of the most fundamental concepts in the ICT algorithmic framework: The cycle between Internal and External Liquidity.

According to ICT, the Interbank Price Delivery Algorithm continuously moves price in a loop—from drawing on resting orders at the absolute highs/lows of a dealing range (External Liquidity), back down into inefficiencies within that range (Internal Liquidity), and then back out again.

Here is exactly how the script brings this concept to life on your chart:

1. External Liquidity (The Dealing Range)
To identify the macro boundaries of the current dealing range, the script tracks "Major Swings" (which default to 15-bar pivots).

Ext BSL & Ext SSL: When a major high or low forms, it draws a thick, solid line extending forward in time. This acts as the outer boundary where the heaviest cluster of retail stop losses rests.

2. Internal Liquidity (Minor Swings & FVGs)
Once the dealing range is established, price will often consolidate or retrace within it. The script maps two types of internal liquidity that the algorithm uses to re-price before attacking the external bounds:

Minor Swings: These are short-term highs and lows (default 3-bar pivots) trapped inside the dealing range. They are marked with thinner, dashed lines.

Fair Value Gaps (FVGs): The script automatically highlights active bullish and bearish FVGs with slightly transparent boxes. FVGs act as massive internal magnets for price.

3. Dynamic Mitigation & Sweeps
The true power of this script is that it dynamically updates to reflect real-time liquidity consumption:

If price wicks past an External or Minor Swing line, the line stops extending (because the liquidity has been swept).

If price dips into an FVG box and completely fills the gap, the box immediately stops drawing (because the inefficiency has been rebalanced).
How to use it:

By watching the interplay between these drawings, you can track the algorithmic narrative. For example, if you see price completely fill an internal FVG (Internal Liquidity), you can immediately look up to the thick "Ext BSL" line (External Liquidity) to identify the algorithm's likely next target.

## Source Code

````pine
//@version=6
indicator("Internal and External Liquidity", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =====================================================================
// ICT Internal vs External Liquidity
// External Liquidity: Rests at bounds of dealing ranges (Major Swing Highs/Lows).
// Internal Liquidity: Exists within the range (FVGs, Minor Swings).
// Price moves from Internal -> External, and External -> Internal.
// =====================================================================

// --- Inputs ---
grp_ext = "External Liquidity (Dealing Range Bounds)"
ext_len = input.int(15, title="Major Pivot Length", group=grp_ext, tooltip="Defines the dealing range boundaries.")
ext_bsl_col = input.color(color.new(color.blue, 0), title="External BSL Color", group=grp_ext)
ext_ssl_col = input.color(color.new(color.red, 0), title="External SSL Color", group=grp_ext)

grp_int = "Internal Liquidity (Minor Swings & FVGs)"
int_len = input.int(3, title="Minor Pivot Length", group=grp_int, tooltip="Defines short-term internal highs/lows.")
int_bsl_col = input.color(color.new(color.blue, 50), title="Internal BSL Color", group=grp_int)
int_ssl_col = input.color(color.new(color.red, 50), title="Internal SSL Color", group=grp_int)

show_fvgs = input.bool(true, title="Show Internal FVGs", group=grp_int)
bull_fvg_col = input.color(color.new(color.green, 80), title="Bullish FVG Color", group=grp_int)
bear_fvg_col = input.color(color.new(color.red, 80), title="Bearish FVG Color", group=grp_int)

max_tracked = input.int(10, title="Max Active Objects to Track", group="Memory Management")

// --- External Liquidity Detection (Major Swings) ---
ext_ph = ta.pivothigh(high, ext_len, ext_len)
ext_pl = ta.pivotlow(low, ext_len, ext_len)

var line[] ext_bsl_lines = array.new_line()
var line[] ext_ssl_lines = array.new_line()
var label[] ext_labels = array.new_label()

if not na(ext_ph)
    pivot_bar = bar_index[ext_len]
    l = line.new(pivot_bar, ext_ph, bar_index, ext_ph, color=ext_bsl_col, width=2)
    lbl = label.new(pivot_bar, ext_ph, text="Ext BSL", color=color.new(color.white,100), textcolor=ext_bsl_col, style=label.style_label_down, size=size.small)
    array.push(ext_bsl_lines, l)
    array.push(ext_labels, lbl)
    if array.size(ext_bsl_lines) > max_tracked
        line.delete(array.shift(ext_bsl_lines))
        label.delete(array.shift(ext_labels))

if not na(ext_pl)
    pivot_bar = bar_index[ext_len]
    l = line.new(pivot_bar, ext_pl, bar_index, ext_pl, color=ext_ssl_col, width=2)
    lbl = label.new(pivot_bar, ext_pl, text="Ext SSL", color=color.new(color.white,100), textcolor=ext_ssl_col, style=label.style_label_up, size=size.small)
    array.push(ext_ssl_lines, l)
    array.push(ext_labels, lbl)
    if array.size(ext_ssl_lines) > max_tracked
        line.delete(array.shift(ext_ssl_lines))
        label.delete(array.shift(ext_labels))

// Manage External Lines
if array.size(ext_bsl_lines) > 0
    for i = array.size(ext_bsl_lines) - 1 to 0
        l = array.get(ext_bsl_lines, i)
        ly = line.get_y1(l)
        line.set_x2(l, bar_index)
        if high > ly
            array.remove(ext_bsl_lines, i)

if array.size(ext_ssl_lines) > 0
    for i = array.size(ext_ssl_lines) - 1 to 0
        l = array.get(ext_ssl_lines, i)
        ly = line.get_y1(l)
        line.set_x2(l, bar_index)
        if low < ly
            array.remove(ext_ssl_lines, i)

// --- Internal Liquidity Detection (Minor Swings) ---
int_ph = ta.pivothigh(high, int_len, int_len)
int_pl = ta.pivotlow(low, int_len, int_len)

var line[] int_bsl_lines = array.new_line()
var line[] int_ssl_lines = array.new_line()
var label[] int_labels = array.new_label()

if not na(int_ph)
    pivot_bar = bar_index[int_len]
    l = line.new(pivot_bar, int_ph, bar_index, int_ph, color=int_bsl_col, style=line.style_dashed, width=1)
    lbl = label.new(pivot_bar, int_ph, text="Int BSL", color=color.new(color.white,100), textcolor=int_bsl_col, style=label.style_label_down, size=size.tiny)
    array.push(int_bsl_lines, l)
    array.push(int_labels, lbl)
    if array.size(int_bsl_lines) > max_tracked
        line.delete(array.shift(int_bsl_lines))
        label.delete(array.shift(int_labels))

if not na(int_pl)
    pivot_bar = bar_index[int_len]
    l = line.new(pivot_bar, int_pl, bar_index, int_pl, color=int_ssl_col, style=line.style_dashed, width=1)
    lbl = label.new(pivot_bar, int_pl, text="Int SSL", color=color.new(color.white,100), textcolor=int_ssl_col, style=label.style_label_up, size=size.tiny)
    array.push(int_ssl_lines, l)
    array.push(int_labels, lbl)
    if array.size(int_ssl_lines) > max_tracked
        line.delete(array.shift(int_ssl_lines))
        label.delete(array.shift(int_labels))

// Manage Internal Lines
if array.size(int_bsl_lines) > 0
    for i = array.size(int_bsl_lines) - 1 to 0
        l = array.get(int_bsl_lines, i)
        ly = line.get_y1(l)
        line.set_x2(l, bar_index)
        if high > ly
            array.remove(int_bsl_lines, i)

if array.size(int_ssl_lines) > 0
    for i = array.size(int_ssl_lines) - 1 to 0
        l = array.get(int_ssl_lines, i)
        ly = line.get_y1(l)
        line.set_x2(l, bar_index)
        if low < ly
            array.remove(int_ssl_lines, i)

// --- Internal Liquidity Detection (FVGs) ---
var box[] bull_fvgs = array.new_box()
var box[] bear_fvgs = array.new_box()

if show_fvgs
    is_bull_fvg = low > high[2]
    is_bear_fvg = high < low[2]
    
    if is_bull_fvg
        b = box.new(left=bar_index[2], top=low, right=bar_index, bottom=high[2], bgcolor=bull_fvg_col, border_color=color.new(color.white,100), text="Int FVG", text_color=color.new(bull_fvg_col,0), text_size=size.tiny, text_halign=text.align_center, text_valign=text.align_center)
        array.push(bull_fvgs, b)
        if array.size(bull_fvgs) > max_tracked
            box.delete(array.shift(bull_fvgs))
            
    if is_bear_fvg
        b = box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high, bgcolor=bear_fvg_col, border_color=color.new(color.white,100), text="Int FVG", text_color=color.new(bear_fvg_col,0), text_size=size.tiny, text_halign=text.align_center, text_valign=text.align_center)
        array.push(bear_fvgs, b)
        if array.size(bear_fvgs) > max_tracked
            box.delete(array.shift(bear_fvgs))
            
    // Manage FVGs (Full Mitigation)
    if array.size(bull_fvgs) > 0
        for i = array.size(bull_fvgs) - 1 to 0
            b = array.get(bull_fvgs, i)
            box.set_right(b, bar_index)
            // If price fills the gap completely (sweeps internal liquidity)
            bottom = box.get_bottom(b)
            if low <= bottom
                array.remove(bull_fvgs, i)

    if array.size(bear_fvgs) > 0
        for i = array.size(bear_fvgs) - 1 to 0
            b = array.get(bear_fvgs, i)
            box.set_right(b, bar_index)
            // If price fills the gap completely (sweeps internal liquidity)
            top = box.get_top(b)
            if high >= top
                array.remove(bear_fvgs, i)
````
