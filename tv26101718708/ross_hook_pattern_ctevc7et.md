# Ross Hook Pattern 

- url: https://www.tradingview.com/script/CtEVc7eT-Ross-Hook-Pattern/
- type: indicator
- pine_id: PUB;06b69263c8284d3a89632b4879bc955c
- version: 1.0

## Description

Indicator Description:  
The Ross Hook Pattern (Expo) – FIXED indicator automatically detects and visualizes the classic Ross Hook pattern introduced by Joe Ross. It identifies pivot structures, trend continuation setups, and breakout conditions by analyzing a sequence of higher highs, higher lows, lower highs, and lower lows. The script highlights the key components of the pattern, including the First Hook, Second Hook, and the Ross Hook itself.

This tool is designed for traders who want to capture trend continuation opportunities and understand market structure through price action. It provides optional labels, pattern drawings, break markers, and pivot annotations for complete visual clarity.

Key Features:

Automatic detection of bullish and bearish Ross Hook patterns

Customizable period and hook distance settings

Optional visualization of pivots (HH/HL/LL/LH)

Breakout markers with adjustable shape, size, and colors

Pattern drawing: First Hook, Second Hook, and Ross Hook lines

Alerts for bullish and bearish Ross Hook pattern identification

Works on all markets and timeframes

How It Works:

The indicator tracks pivot highs and lows using a user‑defined period

It stores the last five pivots and evaluates their structural relationship

When price breaks above/below the key pivot (Point 2), the script checks whether the Ross Hook conditions are met

If confirmed, the indicator plots the pattern, labels the hooks, and optionally draws the full structure

Alerts notify the trader when a valid bullish or bearish Ross Hook pattern appears

How to Use:

Look for bullish patterns during uptrends and bearish patterns during downtrends

Use the Hook Distance setting to filter out weak or shallow structures

Enable pattern drawings for educational or analytical purposes

Combine with trend indicators, volume, or higher‑timeframe structure for stronger confluence

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rauser

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0
// © Zeiierman

//@version=5
indicator("Ross Hook Pattern (Expo) - FIXED", overlay=true, max_bars_back=5000, max_labels_count=500, max_lines_count=500)

// Tooltips
t1 = "Set the Ross Hook Period - A high value returns long-term patterns, and a low value returns short-term patterns"
t2 = "Set the minimum distance between point 2 and point 3."
t3 = "Show pattern break, set the size, and coloring"
t4 = "Show the Ross Hook"
t5 = "Show the Ross Hook pattern"
t6 = "Enable the HH/HL/LL/LH labels"

// Inputs
prd = input.int(20, minval=1, title="Set Period", tooltip=t1)
dst = input.int(20, minval=0, title="Set Hook Distance", tooltip=t2)
showBreak = input.bool(true, "Show Break", inline="break")
showHook = input.bool(true, "Show Hook", tooltip=t4)
showPattern = input.bool(false, "Show Pattern", tooltip=t5)
showPvts = input.bool(false, "Show Pivots", tooltip=t6)
visuell = input.string("Diamond", "", options=["Diamond", "XCross", "Cross", "Flag", "Square"], inline="break")
colBull = input.color(color.new(#31be0c, 0), "", inline="break")
colBear = input.color(color.new(#df3d3d, 0), "", inline="break")
size = input.string(size.tiny, "", options=[size.tiny, size.small, size.normal, size.large, size.huge], inline="break", tooltip=t3)

shape = switch visuell
    "Diamond" => label.style_diamond
    "XCross" => label.style_xcross
    "Cross" => label.style_cross
    "Flag" => label.style_flag
    "Square" => label.style_square

// Arrays for pivot values and their indexes
var pvts = array.new<float>(5, 0.0)
var idx = array.new<int>(5, 0)

// Detect pivots
pvtHi = ta.pivothigh(high, prd, prd)
pvtLo = ta.pivotlow(low, prd, prd)

var pos = 0
if not na(pvtHi) and pos <= 0
    if showPvts
        label.new(bar_index - prd, high[prd], text=pvtHi > array.get(pvts, 1) ? "HH" : "LH", style=label.style_label_down, color=color(na), textcolor=chart.fg_color)
    array.pop(pvts)
    array.pop(idx)
    array.unshift(pvts, high[prd])
    array.unshift(idx, bar_index - prd)
    pos := 1

if not na(pvtLo) and pos >= 0
    if showPvts
        label.new(bar_index - prd, low[prd], text=pvtLo > array.get(pvts, 1) ? "HL" : "LL", style=label.style_label_up, color=color(na), textcolor=chart.fg_color)
    array.pop(pvts)
    array.pop(idx)
    array.unshift(pvts, low[prd])
    array.unshift(idx, bar_index - prd)
    pos := -1

// --- Pattern detection ---
Hook = true  // Reset on every bar

// Only run logic if arrays have enough elements
if array.size(pvts) >= 5 and array.size(idx) >= 5
    p0 = array.get(pvts, 0)
    p1 = array.get(pvts, 1)
    p2 = array.get(pvts, 2)
    p3 = array.get(pvts, 3)
    p4 = array.get(pvts, 4)

    i0 = array.get(idx, 0)
    i1 = array.get(idx, 1)
    i2 = array.get(idx, 2)
    i3 = array.get(idx, 3)
    i4 = array.get(idx, 4)

    // Bullish pattern
    if ta.crossover(high, p1) and Hook
        if p0 < p1 and p1 > p3 and p0 > p2 and p2 > p4 and p3 > p2
            first = bar_index - i4
            sec = bar_index - i3
            if bar_index - i1 >= prd
                for i = first to sec
                    if not na(close[i]) and close[i] > p2 and i2 - bar_index[i] >= dst
                        if showPattern
                            line.new(bar_index - i, p2, i2, p2, color=chart.fg_color, style=line.style_dashed)
                            mid = math.round(math.avg(bar_index - i, i2))
                            label.new(mid, p2, text="First Hook", color=color(color.green), textcolor=chart.fg_color, style=label.style_label_up)
                        if showBreak
                            label.new(bar_index, high, style=shape, color=colBull, size=size)
                        if showHook
                            line.new(i3, p3, bar_index, p3, color=chart.fg_color, style=line.style_dashed)
                            label.new(math.round(math.avg(bar_index, i3)), p3, text="Ross Hook", color=color(na), textcolor=chart.fg_color, style=label.style_label_up)
                        if showPattern
                            line.new(i1, p1, bar_index, p1, color=chart.fg_color, style=line.style_dashed)
                            label.new(math.round(math.avg(bar_index, i1)), p1, text="Second Hook", color=color(na), textcolor=chart.fg_color, style=label.style_label_down)
                            label.new(i4, p4, text="1", color=color(na), textcolor=chart.fg_color, style=label.style_label_up)
                            label.new(i3, p3, text="2", color=color(na), textcolor=chart.fg_color, style=label.style_label_down)
                            label.new(i2, p2, text="3", color=color(na), textcolor=chart.fg_color, style=label.style_label_up)
                            for j = array.size(pvts) - 2 to 2
                                line.new(array.get(idx, j), array.get(pvts, j), array.get(idx, j + 1), array.get(pvts, j + 1), color=chart.fg_color)
                        alert("Bullish Ross Hook Pattern Identified on: " + syminfo.ticker, alert.freq_once_per_bar_close)
                        break

    // Bearish pattern
    if ta.crossunder(low, p1) and Hook
        if p0 > p1 and p1 < p3 and p0 < p2 and p2 < p4 and p3 < p2
            first = bar_index - i4
            sec = bar_index - i3
            if bar_index - i1 >= prd
                for i = first to sec
                    if not na(close[i]) and close[i] < p2 and i2 - bar_index[i] >= dst
                        if showPattern
                            line.new(bar_index - i, p2, i2, p2, color=chart.fg_color, style=line.style_dashed)
                            mid = math.round(math.avg(bar_index - i, i2))
                            label.new(mid, p2, text="First Hook", color=color(na), textcolor=chart.fg_color, style=label.style_label_down)
                        if showBreak
                            label.new(bar_index, low, style=shape, color=colBear, size=size)
                        if showHook
                            line.new(i3, p3, bar_index, p3, color=chart.fg_color, style=line.style_dashed)
                            label.new(math.round(math.avg(bar_index, i3)), p3, text="Ross Hook", color=color(na), textcolor=chart.fg_color, style=label.style_label_down)
                        if showPattern
                            line.new(i1, p1, bar_index, p1, color=chart.fg_color, style=line.style_dashed)
                            label.new(math.round(math.avg(bar_index, i1)), p1, text="Second Hook", color=color(na), textcolor=chart.fg_color, style=label.style_label_up)
                            label.new(i4, p4, text="1", color=color(na), textcolor=chart.fg_color, style=label.style_label_down)
                            label.new(i3, p3, text="2", color=color(na), textcolor=chart.fg_color, style=label.style_label_up)
                            label.new(i2, p2, text="3", color=color(na), textcolor=chart.fg_color, style=label.style_label_down)
                            for j = array.size(pvts) - 2 to 2
                                line.new(array.get(idx, j), array.get(pvts, j), array.get(idx, j + 1), array.get(pvts, j + 1), color=chart.fg_color)
                        alert("Bearish Ross Hook Pattern Identified on: " + syminfo.ticker, alert.freq_once_per_bar_close)
                        break
````
