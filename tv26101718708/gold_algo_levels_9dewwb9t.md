# Gold Algo Levels

- url: https://www.tradingview.com/script/9DeWWb9T-Gold-Algo-Levels/
- type: indicator
- pine_id: PUB;006d1d091abb4f2b9c94c81c24710c0c
- version: 3.0

## Description

Levels are divided into two tiers:

Primary (00, 25, 50) — the most significant zones where institutional order flow is heaviest. These are the levels most likely to produce strong reactions, reversals, or breakout continuations.

Secondary (10, 90) — supporting levels that act as minor friction points, often used as interim targets or areas of brief consolidation.

Features:
• Auto-plots all algo levels across the visible price range
• Updates dynamically as price moves
• Color-coded by significance — primaries and secondaries clearly distinguished
• Clean, minimal design that works on any chart theme
• Fully customizable colours, line styles, and label display

Best used on XAUUSD. Works on all timeframes.

## Source Code

````pine
//@version=5
indicator("Algo Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// Inputs
primary_col     = input.color(color.new(color.white, 0), "Primary level color   (00, 25, 50, 75)")
secondary_col   = input.color(color.new(#8ab4d4, 0), "Secondary level color (10, 90)")
primary_width   = input.int(1, "Primary line width", minval=1, maxval=4)
secondary_width = input.int(1, "Secondary line width", minval=1, maxval=4)
primary_style   = input.string("Solid", "Primary line style", options=["Solid", "Dashed", "Dotted"])
secondary_style = input.string("Solid", "Secondary line style", options=["Solid", "Dashed", "Dotted"])
show_labels     = input.bool(true, "Show level labels")
label_size      = input.string("small", "Label size", options=["tiny", "small", "normal"])
levels_range    = input.int(5, "Levels above/below price (per 100)", minval=2, maxval=20)

// Alert inputs
enable_alerts      = input.bool(true, "Enable alerts")
alert_primary      = input.bool(true, "Alert on primary levels")
alert_secondary    = input.bool(true, "Alert on secondary levels")
alert_on_bar_close = input.bool(true, "Alert once per bar close")

// Helpers
f_line_style(s) =>
    s == "Dashed" ? line.style_dashed :
     s == "Dotted" ? line.style_dotted :
     line.style_solid

f_label_size(s) =>
    s == "tiny" ? size.tiny :
     s == "small" ? size.small :
     size.normal

f_tag(offset) =>
    offset == 0  ? "00" :
     offset == 10 ? "10" :
     offset == 25 ? "25" :
     offset == 50 ? "50" :
     offset == 75 ? "75" : "90"

// Levels
var int[] offsets = array.from(0, 10, 25, 50, 75, 90)
var line[] level_lines = array.new_line()
var label[] level_labels = array.new_label()

// Alert detection
float crossed_level = na
string crossed_tag = ""
string crossed_kind = ""
int crossed_direction = 0

if enable_alerts and not na(close[1])
    low_block = int(math.floor(math.min(close, close[1]) / 100)) - 1
    high_block = int(math.floor(math.max(close, close[1]) / 100)) + 1

    for block = low_block to high_block
        block_base = block * 100

        for i = 0 to array.size(offsets) - 1
            offset = array.get(offsets, i)
            lvl = block_base + offset

            is_primary = offset == 0 or offset == 25 or offset == 50 or offset == 75
            alert_allowed = is_primary ? alert_primary : alert_secondary

            crossed_up = close[1] < lvl and close >= lvl
            crossed_down = close[1] > lvl and close <= lvl

            if alert_allowed and na(crossed_level) and (crossed_up or crossed_down)
                crossed_level := lvl
                crossed_tag := f_tag(offset)
                crossed_kind := is_primary ? "primary" : "secondary"
                crossed_direction := crossed_up ? 1 : -1

algo_level_crossed = not na(crossed_level)

alertcondition(algo_level_crossed, "Algo Level Crossed", "Price crossed an Algo Level.")

if algo_level_crossed
    direction_txt = crossed_direction == 1 ? "up through" : "down through"
    msg = "Algo Levels: " + syminfo.ticker + " crossed " + direction_txt + " " + crossed_kind + " level " + str.tostring(crossed_level, format.mintick) + " [" + crossed_tag + "] on " + timeframe.period

    if alert_on_bar_close
        alert(msg, alert.freq_once_per_bar_close)
    else
        alert(msg, alert.freq_once_per_bar)

// Draw levels on last bar
if barstate.islast
    if array.size(level_lines) > 0
        for i = 0 to array.size(level_lines) - 1
            line.delete(array.get(level_lines, i))
        array.clear(level_lines)

    if array.size(level_labels) > 0
        for i = 0 to array.size(level_labels) - 1
            label.delete(array.get(level_labels, i))
        array.clear(level_labels)

    base = math.floor(close / 100) * 100
    p_style = f_line_style(primary_style)
    s_style = f_line_style(secondary_style)
    l_size = f_label_size(label_size)

    for block = -levels_range to levels_range
        block_base = base + block * 100

        for i = 0 to array.size(offsets) - 1
            offset = array.get(offsets, i)
            lvl = block_base + offset

            is_primary = offset == 0 or offset == 25 or offset == 50 or offset == 75
            col = is_primary ? primary_col : secondary_col
            lwidth = is_primary ? primary_width : secondary_width
            lstyle = is_primary ? p_style : s_style
            lvl_tag = f_tag(offset)

            new_line = line.new(
                 x1=bar_index - 50,
                 y1=lvl,
                 x2=bar_index + 50,
                 y2=lvl,
                 xloc=xloc.bar_index,
                 color=col,
                 width=lwidth,
                 style=lstyle
             )

            array.push(level_lines, new_line)

            if show_labels
                label_txt = str.tostring(lvl, "#.##") + "  [" + lvl_tag + "]"

                new_label = label.new(
                     x=bar_index + 52,
                     y=lvl,
                     text=label_txt,
                     xloc=xloc.bar_index,
                     color=color.new(color.black, 100),
                     textcolor=col,
                     style=label.style_label_left,
                     size=l_size
                 )

                array.push(level_labels, new_label)
````
