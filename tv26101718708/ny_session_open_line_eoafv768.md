# NY Session Open Line

- url: https://www.tradingview.com/script/eoafV768-NY-Session-Open-Line/
- type: indicator
- pine_id: PUB;a993aab2ffa84ad7b5248285b4fc0811
- version: 1.0

## Description

Vertical line print that is customizable, Default setting is NY open 09:30 EST.

## Source Code

````pine
//@version=6
indicator('NY Session Open Line', overlay = true)

// ─── SETTINGS ───────────────────────────────────────────────────────────────
var g = 'Session Open Line Settings'

open_hour = input.int(9, 'Hour (0–23, New York time)', minval = 0, maxval = 23, group = g)
open_minute = input.int(30, 'Minute (0–59)', minval = 0, maxval = 59, group = g)

show_line = input.bool(true, 'Show Line', group = g)
line_color = input.color(color.new(color.yellow, 0), 'Line Color', group = g)
line_width = input.int(1, 'Line Width', minval = 1, maxval = 4, group = g)
line_style_str = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g)

show_label = input.bool(true, 'Show Label', group = g)
label_text = input.string('NY Open 9:30', 'Label Text', group = g)
label_size_str = input.string('Small', 'Label Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = g)
label_pos_str = input.string('Top', 'Label Position', options = ['Top', 'Bottom'], group = g)

// ─── HELPERS ────────────────────────────────────────────────────────────────
_style() =>
    switch line_style_str
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_solid

_lsize() =>
    switch label_size_str
        'Tiny' => size.tiny
        'Normal' => size.normal
        'Large' => size.large
        => size.small

_lpos() =>
    label_pos_str == 'Bottom' ? label.style_label_up : label.style_label_down

// Zero-pad a number to 2 digits
_pad(n) =>
    n < 10 ? '0' + str.tostring(n) : str.tostring(n)

// ─── TIME DETECTION ─────────────────────────────────────────────────────────
// Build a 1-minute session window from the user-defined hour & minute.
// "America/New_York" handles DST automatically (EST/EDT).
close_minute = open_minute + 1 >= 60 ? 0 : open_minute + 1
close_hour = open_minute + 1 >= 60 ? open_hour + 1 : open_hour
session_str = _pad(open_hour) + _pad(open_minute) + '-' + _pad(close_hour) + _pad(close_minute)

is_trigger = not na(time('1', session_str, 'America/New_York')) and timeframe.isintraday and timeframe.multiplier < 60

// ─── DRAW ───────────────────────────────────────────────────────────────────
if show_line and is_trigger
    line.new(x1 = bar_index, y1 = high, x2 = bar_index, y2 = low, xloc = xloc.bar_index, extend = extend.both, color = line_color, style = _style(), width = line_width)

    if show_label
        lp = label_pos_str == 'Bottom' ? low : high
        label.new(x = bar_index, y = lp, text = label_text, xloc = xloc.bar_index, color = color.new(line_color, 80), textcolor = line_color, style = _lpos(), size = _lsize())
````
