# Prev Day H/L Box

- url: https://www.tradingview.com/script/z3LltZCF-Prev-Day-H-L-Box/
- type: indicator
- pine_id: PUB;afd77853f35146438bbdfe8baf74c394
- version: 1.0

## Description

This plots previous day high low on any index just create the label for the ticker

## Source Code

````pine
////Previous Day H/L Box with Midpoint
//Pine Script v5
//@version=5
indicator("Prev Day H/L Box", overlay=true, max_boxes_count=500, max_lines_count=500)

// ── Inputs ──────────────────────────────────────────────
boxColor    = input.color(color.new(color.blue, 85), "Box Fill")
borderColor = input.color(color.new(color.blue, 20), "Border Color")
midColor    = input.color(color.new(color.orange, 0), "Midpoint Color")
showLabels  = input.bool(true, "Show Labels")

// ── Detect new daily bar ─────────────────────────────────
// Using ta.change to detect the start of a new day
isNewDay = ta.change(time("D"))

// ── Previous day OHLC ───────────────────────────────────
// Use lookahead_on with [1] to get the truly completed previous session
pdHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
pdMid  = (pdHigh + pdLow) / 2

// ── State variables ─────────────────────────────────────
var box   pdBox   = na
var line  midLine = na
var label lblHigh = na
var label lblLow  = na
var label lblMid  = na

// ── Draw on new day ──────────────────────────────────────
if isNewDay
    // Create new drawings for the new day
    pdBox := box.new(
         left         = bar_index,
         top          = pdHigh,
         right        = bar_index + 1,
         bottom       = pdLow,
         bgcolor      = boxColor,
         border_color = borderColor,
         border_width = 1)

    midLine := line.new(
         x1     = bar_index,
         y1     = pdMid,
         x2     = bar_index + 1,
         y2     = pdMid,
         color  = midColor,
         style  = line.style_dashed,
         width  = 1)

    if showLabels
        lblHigh := label.new(bar_index, pdHigh, "PDH: " + str.tostring(pdHigh, format.mintick),
             color=color.new(borderColor, 100), textcolor=borderColor,
             style=label.style_label_down, size=size.small)

        lblLow := label.new(bar_index, pdLow, "PDL: " + str.tostring(pdLow, format.mintick),
             color=color.new(borderColor, 100), textcolor=borderColor,
             style=label.style_label_up, size=size.small)

        lblMid := label.new(bar_index, pdMid, "MID: " + str.tostring(pdMid, format.mintick),
             color=color.new(midColor, 100), textcolor=midColor,
             style=label.style_label_left, size=size.small)

// ── Update Right Edge ────────────────────────────────────
// This ensures the box grows as the day progresses
if not na(pdBox)
    box.set_right(pdBox, bar_index)
    line.set_x2(midLine, bar_index)
    // Keep labels at the start or move them to the end:
    label.set_x(lblMid, bar_index)
````
