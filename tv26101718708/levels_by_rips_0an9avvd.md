# Levels By RIPS

- url: https://www.tradingview.com/script/0an9avVD-Levels-By-RIPS/
- type: indicator
- pine_id: PUB;4f891c3257c949dfad2021560b2de88c
- version: 3.0

## Description

Levels By RIPS
A simple, clean tool for plotting custom price levels directly on your chart with price scale labels.
Paste a comma-separated list of levels for ES and NQ into the settings — the indicator automatically detects which instrument you're viewing and plots the correct levels. No manual line drawing, no clutter. Just paste and go.
Features:

Separate input boxes for ES and NQ levels
Auto-detects ES, MES, NQ, and MNQ charts
Color-coded price scale labels for instant visual reference
Adjustable line color and width
Updates instantly when you change settings

How to use:

Add to chart
Open Settings
Paste your comma-separated levels into the ES or NQ box
Done — levels plot automatically

Update your levels in Settings each time RIPS drops new ones. Takes 10 seconds — just replace the old numbers with the new ones.

## Source Code

````pine
//@version=6
indicator('Levels By RIPS', overlay = true)

es_input = input.text_area('7467.75, 7449.75, 7438.50, 7429.50, 7420.50, 7413.50, 7407.75, 7399.00, 7391.25, 7377.50, 7366.50, 7355.50, 7347.00, 7340.25, 7331.00', title = 'ES Levels (comma separated)')
nq_input = input.text_area('29685.50, 29586.25, 29525.25, 29473.25, 29426.00, 29390.00, 29354.25, 29301.75, 29262.75, 29210.75, 29116.75, 29059.75, 29011.50, 28964.75, 28929.25', title = 'NQ Levels (comma separated)')

col    = input.color(color.new(color.yellow, 0), 'Line Color')
lwidth = input.int(1, 'Line Width', minval = 1, maxval = 4)

ticker_upper = str.upper(syminfo.ticker)

is_MNQ       = str.contains(ticker_upper, 'MNQ')
is_MES       = str.contains(ticker_upper, 'MES')
is_NQ        = str.contains(ticker_upper, 'NQ') and not is_MNQ
is_ES        = str.contains(ticker_upper, 'ES') and not str.contains(ticker_upper, 'NQ')

use_ES_levels = is_ES or is_MES
use_NQ_levels = is_NQ or is_MNQ

var array<line>  drawn_lines  = array.new_line()
var array<label> drawn_labels = array.new_label()

if barstate.islast
    for l in drawn_lines
        line.delete(l)
    for lb in drawn_labels
        label.delete(lb)
    array.clear(drawn_lines)
    array.clear(drawn_labels)

    raw = use_ES_levels ? es_input : use_NQ_levels ? nq_input : ''

    if str.length(raw) > 0
        parts = str.split(raw, ',')
        for i = 0 to array.size(parts) - 1 by 1
            val_str = str.trim(array.get(parts, i))
            val     = str.tonumber(val_str)
            if not na(val) and val > 0
                ln = line.new(bar_index, val, bar_index + 1, val, extend = extend.both, color = col, width = lwidth)
                array.push(drawn_lines, ln)

                lb = label.new(bar_index + 1, val, str.tostring(val), style = label.style_label_left, color = col, textcolor = color.black, size = size.small, xloc = xloc.bar_index)
                array.push(drawn_labels, lb)
````
