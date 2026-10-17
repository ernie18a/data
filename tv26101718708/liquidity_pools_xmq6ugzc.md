# Liquidity Pools

- url: https://www.tradingview.com/script/xMQ6ugZc-Liquidity-Pools/
- type: indicator
- pine_id: PUB;0b9fde726fda40aabf4d8430265e4ab4
- version: 1.0

## Description

This script is an automated liquidity mapping tool based on ICT concepts. It actively hunts your chart for zones where retail stop losses and pending breakout orders are clustered.

Here is a breakdown of how the script functions and visualizes liquidity on your chart:

1. Automatic Pivot Detection (Old Highs & Old Lows)
The script continuously monitors price action to find major structural turning points (swing highs and swing lows).

When a confirmed swing high forms, it registers it as Buy-Side Liquidity (BSL) and draws a blue line projecting to the right. This marks a zone where retail traders have placed their buy-stop loss orders above the high.

When a confirmed swing low forms, it registers it as Sell-Side Liquidity (SSL) and draws a red line projecting to the right. This marks a zone where sell-stop loss orders are resting.

2. Equal Highs (EQH) and Equal Lows (EQL) Detection
In ICT methodology, the most powerful magnets for price are "Relative Equal Highs" or "Relative Equal Lows".

The script actively measures the distance between a newly formed pivot and an old active pivot.

If a new pivot forms within a few ticks of an old one (customizable in settings), the script recognizes it as highly engineered liquidity!

It automatically thickens the line, changes its color to bright orange, and updates the text label to EQH or EQL, signaling an extremely high-probability draw on liquidity.

3. Smart Text Labeling
To ensure you never have to guess what a line means, the script pins a text label (BSL, SSL, EQH, or EQL) directly at the starting point of every liquidity pool.

4. Sweep Detection & "Stop-Hunting" Tracking
Liquidity pools are only valid until they are traded through.

The script tracks every live tick. The exact moment price sweeps through a liquidity line, it stops extending the line.

It drops a small "X" right where the line was broken. This gives you a permanent historical footprint on your chart of exactly where and when "Smart Money" swept stops.

5. Memory Management
Because liquidity lines could theoretically build up infinitely and crash your chart, the script has built-in garbage collection. It only keeps track of the 15 most recent unswept pools (you can change this number in the settings) so your chart always stays clean and fast.

## Source Code

````pine
//@version=6
indicator("ICT Liquidity Pools", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================================
// ICT Liquidity Pools Concept
// Objectives: Identify resting orders clustered above old highs (BSL) and below old lows (SSL).
// Identifies Equal Highs (EQH) and Equal Lows (EQL) for high-probability targets.
// Tracks liquidity pools until they are swept by price.
// =====================================================================

// --- Inputs ---
grp_pivots = "Pivot Settings"
pivot_left = input.int(5, title="Pivot Left Bars", group=grp_pivots)
pivot_right = input.int(5, title="Pivot Right Bars", group=grp_pivots)
max_pools = input.int(15, title="Max Active Pools to Track", group=grp_pivots)

grp_eq = "Equal Highs/Lows (EQH/EQL)"
eq_ticks = input.int(5, title="EQH/EQL Tolerance (Ticks)", group=grp_eq, tooltip="If a new pivot forms within this many ticks of an old pivot, it is flagged as an Equal High/Low.")
threshold = eq_ticks * syminfo.mintick

grp_visuals = "Visual Settings"
bsl_col = input.color(color.new(#177400, 30), title="BSL Color", group=grp_visuals)
ssl_col = input.color(color.new(color.red, 30), title="SSL Color", group=grp_visuals)
eqh_col = input.color(color.new(color.orange, 0), title="EQH/EQL Highlight Color", group=grp_visuals)
show_swept = input.bool(true, title="Show 'X' when Swept", group=grp_visuals)

// --- Detection ---
ph = ta.pivothigh(high, pivot_left, pivot_right)
pl = ta.pivotlow(low, pivot_left, pivot_right)

// Arrays to store active lines and labels
var line[] bsl_lines = array.new_line()
var line[] ssl_lines = array.new_line()
var label[] bsl_labels = array.new_label()
var label[] ssl_labels = array.new_label()

// New BSL (Buy-Side Liquidity)
if not na(ph)
    pivot_bar = bar_index[pivot_right]
    
    // Check for EQH (Equal Highs)
    is_eqh = false
    if array.size(bsl_lines) > 0
        for i = 0 to array.size(bsl_lines) - 1
            l = array.get(bsl_lines, i)
            if math.abs(line.get_y1(l) - ph) <= threshold
                is_eqh := true
                // Highlight the older line as an EQH
                line.set_color(l, eqh_col)
                line.set_width(l, 2)
                
                // Update the older label to say EQH
                lbl_old = array.get(bsl_labels, i)
                label.set_text(lbl_old, "EQH")
                label.set_textcolor(lbl_old, eqh_col)
                break
                
    line_col = is_eqh ? eqh_col : bsl_col
    line_width = is_eqh ? 2 : 1
    
    l = line.new(x1=pivot_bar, y1=ph, x2=bar_index, y2=ph, color=line_col, style=line.style_solid, width=line_width)
    array.push(bsl_lines, l)
    
    txt = is_eqh ? "EQH" : "BSL"
    lbl = label.new(x=pivot_bar, y=ph, text=txt, style=label.style_label_down, color=color.new(color.white, 100), textcolor=line_col, size=size.small)
    array.push(bsl_labels, lbl)
    
    // Manage array size to prevent memory bloat
    if array.size(bsl_lines) > max_pools
        oldest = array.shift(bsl_lines)
        line.delete(oldest)
        oldest_lbl = array.shift(bsl_labels)
        label.delete(oldest_lbl)

// New SSL (Sell-Side Liquidity)
if not na(pl)
    pivot_bar = bar_index[pivot_right]
    
    // Check for EQL (Equal Lows)
    is_eql = false
    if array.size(ssl_lines) > 0
        for i = 0 to array.size(ssl_lines) - 1
            l = array.get(ssl_lines, i)
            if math.abs(line.get_y1(l) - pl) <= threshold
                is_eql := true
                // Highlight the older line as an EQL
                line.set_color(l, eqh_col)
                line.set_width(l, 2)
                
                // Update the older label to say EQL
                lbl_old = array.get(ssl_labels, i)
                label.set_text(lbl_old, "EQL")
                label.set_textcolor(lbl_old, eqh_col)
                break
                
    line_col = is_eql ? eqh_col : ssl_col
    line_width = is_eql ? 2 : 1

    l = line.new(x1=pivot_bar, y1=pl, x2=bar_index, y2=pl, color=line_col, style=line.style_solid, width=line_width)
    array.push(ssl_lines, l)
    
    txt = is_eql ? "EQL" : "SSL"
    lbl = label.new(x=pivot_bar, y=pl, text=txt, style=label.style_label_up, color=color.new(color.white, 100), textcolor=line_col, size=size.small)
    array.push(ssl_labels, lbl)
    
    if array.size(ssl_lines) > max_pools
        oldest = array.shift(ssl_lines)
        line.delete(oldest)
        oldest_lbl = array.shift(ssl_labels)
        label.delete(oldest_lbl)

// --- Management (Sweeps & Extension) ---
if array.size(bsl_lines) > 0
    for i = array.size(bsl_lines) - 1 to 0
        l = array.get(bsl_lines, i)
        ly = line.get_y1(l)
        
        // Extend line to current bar
        line.set_x2(l, bar_index)
        
        // Check if swept
        if high > ly
            // Liquidity swept
            if show_swept
                label.new(x=bar_index, y=ly, text="X", color=color.new(color.white,100), textcolor=bsl_col, style=label.style_label_down, size=size.small)
            // Stop extending by removing from active tracking array
            array.remove(bsl_lines, i)
            array.remove(bsl_labels, i)

if array.size(ssl_lines) > 0
    for i = array.size(ssl_lines) - 1 to 0
        l = array.get(ssl_lines, i)
        ly = line.get_y1(l)
        
        // Extend line to current bar
        line.set_x2(l, bar_index)
        
        // Check if swept
        if low < ly
            // Liquidity swept
            if show_swept
                label.new(x=bar_index, y=ly, text="X", color=color.new(color.white,100), textcolor=ssl_col, style=label.style_label_up, size=size.small)
            // Stop extending by removing from active tracking array
            array.remove(ssl_lines, i)
            array.remove(ssl_labels, i)
````
