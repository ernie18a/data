# ICT Engine: GunnyBadger

- url: https://www.tradingview.com/script/EaGYbGnU-ICT-Engine-GunnyBadger/
- type: indicator
- pine_id: PUB;8768bb69728c4ade84c3d1125c460b47
- version: 1.0

## Description

Liquidity
FVGs
IFVGs
This Indicator Provides Visuals of Market inefficiencies are left open.
it also marks out swing Highs and lows as Liquidity.
its meant to be a time saving tool for ICT traders

## Source Code

````pine
//@version=5
indicator("ICT Engine: Master Pro", overlay=true, max_lines_count=100, max_boxes_count=100, max_labels_count=100)

// --- INPUTS ---
bsl_color = input.color(color.red, "BSL Color")
ssl_color = input.color(color.green, "SSL Color")
mitigated_col = input.color(color.gray, "Mitigated Color")

// --- STORAGE ---
var line[] bsl_lines = array.new_line(0)
var line[] ssl_lines = array.new_line(0)
var bool[] bsl_mitigated = array.new_bool(0)
var bool[] ssl_mitigated = array.new_bool(0)

swing_len = 5
p_high = ta.pivothigh(high, swing_len, swing_len)
p_low  = ta.pivotlow(low, swing_len, swing_len)

// Add Lines
if not na(p_high)
    array.push(bsl_lines, line.new(bar_index-swing_len, p_high, bar_index, p_high, color=bsl_color, style=line.style_dashed))
    array.push(bsl_mitigated, false)

if not na(p_low)
    array.push(ssl_lines, line.new(bar_index-swing_len, p_low, bar_index, p_low, color=ssl_color, style=line.style_dashed))
    array.push(ssl_mitigated, false)

// Update & Freeze Lines
if array.size(bsl_lines) > 0
    for i = 0 to array.size(bsl_lines) - 1
        l = array.get(bsl_lines, i)
        if not array.get(bsl_mitigated, i)
            line.set_x2(l, bar_index)
            if high > line.get_y1(l)
                line.set_color(l, mitigated_col)
                array.set(bsl_mitigated, i, true)

if array.size(ssl_lines) > 0
    for i = 0 to array.size(ssl_lines) - 1
        l = array.get(ssl_lines, i)
        if not array.get(ssl_mitigated, i)
            line.set_x2(l, bar_index)
            if low < line.get_y1(l)
                line.set_color(l, mitigated_col)
                array.set(ssl_mitigated, i, true)

// --- FVG & IFVG ENGINE WITH LABELS ---
var box current_fvg = na
var label current_label = na
var int fvg_type = 0 

if low > high[2] and fvg_type != 1
    current_fvg := box.new(bar_index-2, low, bar_index, high[2], border_color=color.rgb(21, 252, 0), bgcolor=color.new(#02fc0a, 65))
    current_label := label.new(bar_index-1, (low + high[2])/2, "FVG", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none)
    fvg_type := 1
else if high < low[2] and fvg_type != -1
    current_fvg := box.new(bar_index-2, low[2], bar_index, high, border_color=color.rgb(250, 2, 2), bgcolor=color.new(#ff0202, 80))
    current_label := label.new(bar_index-1, (low[2] + high)/2, "FVG", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none)
    fvg_type := -1

if not na(current_fvg)
    box.set_right(current_fvg, bar_index)
    if fvg_type == 1 and close < box.get_bottom(current_fvg)
        box.set_border_color(current_fvg, color.rgb(133, 0, 71))
        box.set_bgcolor(current_fvg, color.new(#970051, 51))
        label.set_text(current_label, "IFVG")
        fvg_type := -2
    else if fvg_type == -1 and close > box.get_top(current_fvg)
        box.set_border_color(current_fvg, color.rgb(0, 248, 128))
        box.set_bgcolor(current_fvg, color.new(#00e677, 57))
        label.set_text(current_label, "IFVG")
        fvg_type := 2
````
