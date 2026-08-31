<!-- tradingview-pine-id: PUB;f4e3dd9700ba4c0e966cc1765c534edc -->
<!-- tradingviewscripts-format: 1 -->
# Nigel Time-Flow Horizons

Source: https://www.tradingview.com/script/XJvRmf6Y-Nigel-Time-Flow-Horizons/

## Description

Time Flow Horizons used for Order flow. Solid - Solid Lines is structural flow, Dashed-Dotted lines is Short-term flow, Dotted - right Solid line is immediate flow.

---

## Source Code

````pine
//@version=6
indicator("Nigel Time-Flow Horizons", overlay=true)

// === User‑selectable colors ===
structColor     = input.color(color.red,   "Structural Flow Color")
shortColor      = input.color(color.blue,  "Short-Term Flow Color")
immediateColor  = input.color(color.green, "Immediate Flow Color")
currentColor    = input.color(color.red,   "Current Time Color")

// === User‑selectable thickness ===
structWidth     = input.int(2, "Structural Line Width", minval=1, maxval=10)
shortWidth      = input.int(2, "Short-Term Line Width", minval=1, maxval=10)
immediateWidth  = input.int(2, "Immediate Line Width", minval=1, maxval=10)
currentWidth    = input.int(2, "Current Time Line Width", minval=1, maxval=10)

// === Timeframe info ===
tf_minutes = timeframe.multiplier
bars_per_day = 24 * 60 / tf_minutes

// === Horizon offsets ===
struct_bars    = int(10 * bars_per_day)   // 10 days
short_bars     = int(4 * bars_per_day)    // 4 days
immediate_bars = int(1 * bars_per_day)    // 24 hours

// === Bar positions ===
struct_left_bar  = bar_index - struct_bars
short_bar        = bar_index - short_bars
immediate_bar    = bar_index - immediate_bars
struct_right_bar = bar_index

// === Line handles ===
var line struct_left      = na
var line short_dash       = na
var line immediate_dotted = na
var line struct_right     = na

if barstate.islast
    // delete old lines
    if not na(struct_left)
        line.delete(struct_left)
    if not na(short_dash)
        line.delete(short_dash)
    if not na(immediate_dotted)
        line.delete(immediate_dotted)
    if not na(struct_right)
        line.delete(struct_right)

    // draw new lines with custom widths
    struct_left      := line.new(struct_left_bar,  close, struct_left_bar,  close,  color=structColor,   style=line.style_solid,  width=structWidth)
    short_dash       := line.new(short_bar,        close, short_bar,        close,  color=shortColor,    style=line.style_dashed, width=shortWidth)
    immediate_dotted := line.new(immediate_bar,    close, immediate_bar,    close,  color=immediateColor,style=line.style_dotted, width=immediateWidth)
    struct_right     := line.new(struct_right_bar, close, struct_right_bar, close,  color=currentColor,  style=line.style_solid,  width=currentWidth)

    // extend vertically across chart
    line.set_extend(struct_left,      extend.both)
    line.set_extend(short_dash,       extend.both)
    line.set_extend(immediate_dotted, extend.both)
    line.set_extend(struct_right,     extend.both)
````
