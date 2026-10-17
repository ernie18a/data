# AMD NYC Session Baney

- url: https://www.tradingview.com/script/ihN1SGEw-AMD-NYC-Session-Baney/
- type: indicator
- pine_id: PUB;22b51d2a76604366bde452b129acdf31
- version: 1.0

## Description

This indicator helps you mark out consolidation,manipulation,and distribution also known as the AMD strat

## Source Code

````pine
//@version=6
indicator("NY Session - Consol Sweep Distribution", overlay=true, max_boxes_count=100, max_labels_count=100, max_lines_count=100)

min_bars  = input.int(4, "Min Consolidation Bars", minval=4, maxval=12)
max_rng   = input.float(20.0, "Max Consolidation Range (pts)")
sweep_min = input.float(3.0, "Min Sweep Beyond Zone (pts)")
dist_min  = input.float(15.0, "Min Distribution Move (pts)")

is_ny    = not na(time(timeframe.period, "0930-1130", "America/New_York"))
in_dates = time >= timestamp(2026, 6, 22, 9, 30, 0) and time <= timestamp(2026, 6, 29, 11, 30, 0)
active   = is_ny and in_dates

var float  p_ext = na
var string p_dir = ""

// Precompute highs/lows for window sizes 4-12 at top level (Pine Script requirement)
zh4  = ta.highest(high, 4)[1]
zl4  = ta.lowest(low, 4)[1]
zh5  = ta.highest(high, 5)[1]
zl5  = ta.lowest(low, 5)[1]
zh6  = ta.highest(high, 6)[1]
zl6  = ta.lowest(low, 6)[1]
zh7  = ta.highest(high, 7)[1]
zl7  = ta.lowest(low, 7)[1]
zh8  = ta.highest(high, 8)[1]
zl8  = ta.lowest(low, 8)[1]
zh9  = ta.highest(high, 9)[1]
zl9  = ta.lowest(low, 9)[1]
zh10 = ta.highest(high, 10)[1]
zl10 = ta.lowest(low, 10)[1]
zh11 = ta.highest(high, 11)[1]
zl11 = ta.lowest(low, 11)[1]
zh12 = ta.highest(high, 12)[1]
zl12 = ta.lowest(low, 12)[1]

zh_arr = array.from(zh4, zh5, zh6, zh7, zh8, zh9, zh10, zh11, zh12)
zl_arr = array.from(zl4, zl5, zl6, zl7, zl8, zl9, zl10, zl11, zl12)

// Scan for consolidation -> sweep on each confirmed session bar
if barstate.isconfirmed and active
    for i = 0 to 8
        n = i + 4
        if n >= min_bars
            zh = array.get(zh_arr, i)
            zl = array.get(zl_arr, i)
            if zh - zl <= max_rng
                if high > zh + sweep_min and close <= zh
                    box.new(bar_index - n, zh, bar_index, zl, border_color=color.yellow, bgcolor=color.new(color.yellow, 78), border_width=2)
                    label.new(bar_index, high, "SWEEP H", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
                    p_ext := high
                    p_dir := "dn"
                    break
                if low < zl - sweep_min and close >= zl
                    box.new(bar_index - n, zh, bar_index, zl, border_color=color.yellow, bgcolor=color.new(color.yellow, 78), border_width=2)
                    label.new(bar_index, low, "SWEEP L", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.small)
                    p_ext := low
                    p_dir := "up"
                    break

// Confirm distribution on bars after the sweep
if not na(p_ext) and active
    if p_dir == "dn" and (p_ext - low) >= dist_min
        label.new(bar_index, low, "DIST DN " + str.tostring(math.round(p_ext - low)) + "pt", style=label.style_label_up, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)
        p_ext := na
        p_dir := ""
    else if p_dir == "up" and (high - p_ext) >= dist_min
        label.new(bar_index, high, "DIST UP " + str.tostring(math.round(high - p_ext)) + "pt", style=label.style_label_down, color=color.new(color.lime, 20), textcolor=color.black, size=size.tiny)
        p_ext := na
        p_dir := ""

// Reset state at session end
if not active and p_dir != ""
    p_ext := na
    p_dir := ""
````
