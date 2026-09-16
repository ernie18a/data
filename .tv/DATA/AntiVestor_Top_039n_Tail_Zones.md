<!-- tradingview-pine-id: PUB;027ebd18088f4b7f86379071f01d6980 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# AntiVestor - Top &#039;n Tail Zones

Source: https://www.tradingview.com/script/8VsCUqIW-AntiVestor-Top-n-Tail-Zones/

## Description

AntiVestor - Top 'n Tail Zones

Top 'n Tail Zones is a utility for marking fixed levels and shaded zones on any chart or pane that moves on a stable numeric scale — market breadth readings, percentage-above-moving-average lines, or any bounded oscillator. It tops and tails the range: an upper extreme zone, a lower extreme zone, and a neutral middle, all set by you.

You pick a scale preset or enter the levels yourself; it paints the zones, three reference lines and four labels, and holds them across the chart.

It calculates nothing. There is no signal, no reading of price, no alert. Every level on screen is a number you chose.
[image]https://www.tradingview.com/x/gNTQRkO9/[/image]

[image]https://www.tradingview.com/x/k6nf1yc7/[/image]

WHAT IT DRAWS

[*]An upper zone, bounded by two levels. Labelled "Bullish Extreme" by default.
[*]A lower zone, labelled "Bearish Extreme".
[*]A middle zone between an upper and lower boundary, labelled as the neutral or chop area. If you set its upper and lower bounds to the same number, it collapses to a single midpoint line rather than a zero-height box.
[*]Dashed reference lines at the middle-zone boundaries, and an optional solid line at zero.
[*]Four labels floating to the right of the last bar, so the zones stay identified when you are scrolled in.

All levels and all six colours are adjustable. The zones extend back to the first loaded bar and forward by a configurable number of bars.

WHAT IT IS FOR

Anything that oscillates inside a range you already know the shape of:

[*]Market breadth symbols such as advance-decline differences, where the useful information is how far into an extreme the reading has gone rather than the number itself.
[*]Percentage-of-stocks-above-moving-average readings, which live on a 0-100 scale where the top and bottom bands are the interesting parts.
[*]Any bounded oscillator, where you want a shaded band rather than a pair of thin lines.

The intended pattern is a top zone, a bottom zone and a neutral middle, so that a glance tells you which part of the range you are in.

HOW TO APPLY IT

Two routes, depending on what you are zoning.

1. Chart the instrument directly and add the script. It draws on that instrument's own scale.
2. Add the script, then drag it into the pane of the oscillator you want to zone. It picks up that pane's scale.

Then pick a preset.

ADD / Breadth sets levels suited to an advance-decline reading in the low thousands.
Percentage (0-100) sets the top and bottom tenth as the extreme zones and marks 50 as the midpoint — for percentage-above-moving-average readings and bounded oscillators.
Custom hands control to the six level inputs, which is where you go for any scale the two presets do not fit.

A NOTE ON THE DEFAULT COLOURS

The upper zone defaults to red and the lower to green, which is the opposite of what you might expect. That is deliberate: on a mean-reversion scale the top of the range is where you become cautious, not enthusiastic. If you read the scale the other way, both are colour inputs.

LIMITATIONS

Nothing here adapts. The presets are fixed sets of numbers and the custom levels are static. Nothing recalculates, rescales or follows the instrument — change scale and you change the preset or re-enter the levels yourself.
Zones begin at the first bar loaded in your chart's history, not at the true start of the instrument.
The zone labels are fixed text. "Bullish Extreme" and "Bearish Extreme" will not match every scale you might apply this to.
No alerts, no signals, no directional output of any kind. Because nothing is computed from price, nothing repaints, but equally nothing is confirmed either.
On a standard price chart the preset levels are far from price and the zones will be invisible. That is expected — switch to Custom and enter levels that suit the instrument.

This is a drawing utility, not an analysis tool. It does not tell you anything you did not already decide. Nothing here is financial advice.

---

## Source Code

````pine
//@version=6
indicator("AntiVestor - Top 'n Tail Zones", overlay=true)

// ============================================================
// SCALE PRESET
// ============================================================
gP = "Scale"
preset = input.string("ADD / Breadth", title="Scale Preset", options=["ADD / Breadth", "Percentage (0-100)", "Custom"], group=gP)

// ============================================================
// CUSTOM LEVELS (used only when Preset = Custom)
// ============================================================
gC = "Custom Levels"
c_bull_high = input.float( 2000.0, title="Bullish Extreme Upper", step=10, group=gC)
c_bull_low  = input.float( 1500.0, title="Bullish Extreme Lower", step=10, group=gC)
c_bear_high = input.float(-1500.0, title="Bearish Extreme Upper", step=10, group=gC)
c_bear_low  = input.float(-2000.0, title="Bearish Extreme Lower", step=10, group=gC)
c_chop_top  = input.float( 1000.0, title="Chop Zone Upper",       step=10, group=gC)
c_chop_bot  = input.float(-1000.0, title="Chop Zone Lower",       step=10, group=gC)

isCustom = preset == "Custom"
isPct    = preset == "Percentage (0-100)"

bull_high = isCustom ? c_bull_high : isPct ? 100.0 :  2000.0
bull_low  = isCustom ? c_bull_low  : isPct ?  90.0 :  1500.0
bear_high = isCustom ? c_bear_high : isPct ?  10.0 : -1500.0
bear_low  = isCustom ? c_bear_low  : isPct ?   0.0 : -2000.0
chop_top  = isCustom ? c_chop_top  : isPct ?  50.0 :  1000.0
chop_bot  = isCustom ? c_chop_bot  : isPct ?  50.0 : -1000.0

// Collapsed chop zone (upper == lower) is treated as a single midpoint level
midOnly = chop_top == chop_bot

// ============================================================
// DISPLAY
// ============================================================
gV = "Display"
right_offset = input.int(20, title="Forward Extension (bars)", minval=0, maxval=500, group=gV)
show_zero    = input.bool(true, title="Show Zero Line", group=gV)

// ============================================================
// COLOURS
// ============================================================
gK = "Colours"
bull_colour       = input.color(color.red,    title="Bullish Zone Colour",   group=gK)
bear_colour       = input.color(color.green,  title="Bearish Zone Colour",   group=gK)
chop_colour       = input.color(color.purple, title="Chop Zone Colour",      group=gK)
line_colour       = input.color(color.orange, title="Reference Line Colour", group=gK)
zero_line_colour  = input.color(color.black,  title="Zero Line Colour",      group=gK)
label_text_colour = input.color(color.white,  title="Label Text Colour",     group=gK)

// ============================================================
// EXTENSION
// ============================================================
right = bar_index + right_offset
var int left = bar_index

// Dummy plot to satisfy PineScript rendering requirement
plot(na, title="Invisible Plot")

// ============================================================
// ZONE BOXES
// ============================================================
var box bull_zone = na
var box bear_zone = na
var box chop_zone = na

chop_border = midOnly ? color(na) : chop_colour
chop_fill   = midOnly ? color(na) : color.new(chop_colour, 85)

if na(bull_zone)
    bull_zone := box.new(left=left, top=bull_high, right=right, bottom=bull_low, border_color=bull_colour, bgcolor=color.new(bull_colour, 85))
    bear_zone := box.new(left=left, top=bear_high, right=right, bottom=bear_low, border_color=bear_colour, bgcolor=color.new(bear_colour, 85))
    chop_zone := box.new(left=left, top=chop_top,  right=right, bottom=chop_bot, border_color=chop_border, bgcolor=chop_fill)
else
    box.set_right(bull_zone, right)
    box.set_top(bull_zone, bull_high)
    box.set_bottom(bull_zone, bull_low)
    box.set_border_color(bull_zone, bull_colour)
    box.set_bgcolor(bull_zone, color.new(bull_colour, 85))

    box.set_right(bear_zone, right)
    box.set_top(bear_zone, bear_high)
    box.set_bottom(bear_zone, bear_low)
    box.set_border_color(bear_zone, bear_colour)
    box.set_bgcolor(bear_zone, color.new(bear_colour, 85))

    box.set_right(chop_zone, right)
    box.set_top(chop_zone, chop_top)
    box.set_bottom(chop_zone, chop_bot)
    box.set_border_color(chop_zone, chop_border)
    box.set_bgcolor(chop_zone, chop_fill)

// ============================================================
// REFERENCE LINES
// Line objects rather than hline(), because preset-derived levels
// are not const/input qualified and hline() will not accept them.
// Anchored to the current bar, not the first bar: Pine rejects x
// coordinates more than ~10000 bars from bar_index (RE10026).
// extend.both means the anchor position is irrelevant visually.
// ============================================================
var line ln_chop_top = na
var line ln_chop_bot = na
var line ln_zero     = na

if na(ln_chop_top)
    ln_chop_top := line.new(x1=bar_index, y1=chop_top, x2=bar_index + 1, y2=chop_top, extend=extend.both, color=line_colour, style=line.style_dashed, width=1)
    ln_chop_bot := line.new(x1=bar_index, y1=chop_bot, x2=bar_index + 1, y2=chop_bot, extend=extend.both, color=line_colour, style=line.style_dashed, width=1)
    ln_zero     := line.new(x1=bar_index, y1=0.0,      x2=bar_index + 1, y2=0.0,      extend=extend.both, color=zero_line_colour, style=line.style_solid, width=1)
else
    line.set_xy1(ln_chop_top, bar_index, chop_top)
    line.set_xy2(ln_chop_top, bar_index + 1, chop_top)
    line.set_color(ln_chop_top, line_colour)

    line.set_xy1(ln_chop_bot, bar_index, chop_bot)
    line.set_xy2(ln_chop_bot, bar_index + 1, chop_bot)
    line.set_color(ln_chop_bot, midOnly ? color(na) : line_colour)

    line.set_xy1(ln_zero, bar_index, 0.0)
    line.set_xy2(ln_zero, bar_index + 1, 0.0)
    line.set_color(ln_zero, show_zero ? zero_line_colour : color(na))

// ============================================================
// LABELS (floating on the right)
// ============================================================
var label lbl_bull = label.new(x=na, y=na, text="", style=label.style_label_right)
var label lbl_bear = label.new(x=na, y=na, text="", style=label.style_label_right)
var label lbl_high = label.new(x=na, y=na, text="", style=label.style_label_right)
var label lbl_low  = label.new(x=na, y=na, text="", style=label.style_label_right)

label.set_xy(lbl_bull, right - 1, (bull_high + bull_low) / 2)
label.set_text(lbl_bull, "Bullish Extreme")
label.set_color(lbl_bull, bull_colour)
label.set_textcolor(lbl_bull, label_text_colour)

label.set_xy(lbl_bear, right - 1, (bear_high + bear_low) / 2)
label.set_text(lbl_bear, "Bearish Extreme")
label.set_color(lbl_bear, bear_colour)
label.set_textcolor(lbl_bear, label_text_colour)

label.set_xy(lbl_high, right - 1, chop_top)
label.set_text(lbl_high, midOnly ? "Midpoint" : "Relative High")
label.set_color(lbl_high, line_colour)
label.set_textcolor(lbl_high, label_text_colour)

// Lower reference label is parked off-chart when the chop zone collapses
if midOnly
    label.set_xy(lbl_low, na, na)
    label.set_text(lbl_low, "")
else
    label.set_xy(lbl_low, right - 1, chop_bot)
    label.set_text(lbl_low, "Relative Low")
    label.set_color(lbl_low, line_colour)
    label.set_textcolor(lbl_low, label_text_colour)
````
