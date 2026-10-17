# Prev Day H/L Box

- url: https://www.tradingview.com/script/vtoMQxsK-Prev-Day-H-L-Box/
- type: indicator
- pine_id: PUB;9111a22205854495b5d91af97f5aa548
- version: 1.0

## Description

Previous day HL and mid point to plot on the chart that will help to guage the market direction.

## Source Code

````pine
//Previous Day H/L Box with Midpoint
//Pine Script v5
// © Your Strategy — Previous Day H/L Box + Midpoint
//@version=5
indicator("Prev Day H/L Box", overlay=true, max_boxes_count=500, max_lines_count=500)

// ── Inputs ──────────────────────────────────────────────
boxColor    = input.color(color.new(color.blue,  85), "Box Fill")
borderColor = input.color(color.new(color.blue,  20), "Border Color")
midColor    = input.color(color.new(color.orange, 0),  "Midpoint Color")
showLabels  = input.bool(true, "Show Labels")

// ── Detect new daily bar ─────────────────────────────────
isNewDay = timeframe.change("D")

// ── Previous day OHLC ───────────────────────────────────
pdHigh = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pdLow  = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pdMid  = (pdHigh + pdLow) / 2

// ── State variables ─────────────────────────────────────
var box   pdBox     = na
var line  midLine   = na
var label lblHigh   = na
var label lblLow    = na
var label lblMid    = na

// ── Draw on new day ──────────────────────────────────────
if isNewDay
    // Box from prev day's first bar to current bar + 1 session
    startBar = bar_index
    endBar   = bar_index + 1440   // extends rightward; auto-clipped by chart

    // Delete previous drawings
    box.delete(pdBox)
    line.delete(midLine)
    label.delete(lblHigh)
    label.delete(lblLow)
    label.delete(lblMid)

    // Draw the H/L box
    pdBox := box.new(
         left        = startBar,
         top         = pdHigh,
         right       = endBar,
         bottom      = pdLow,
         bgcolor      = boxColor,
         border_color = borderColor,
         border_width = 1,
         extend       = extend.right)

    // Draw the midpoint line
    midLine := line.new(
         x1     = startBar,
         y1     = pdMid,
         x2     = endBar,
         y2     = pdMid,
         color  = midColor,
         style  = line.style_dashed,
         width  = 1,
         extend = extend.right)

    // Labels
    if showLabels
        lblHigh := label.new(startBar, pdHigh, "PDH: " + str.tostring(pdHigh, "#.##"),
             color=color.new(borderColor,60), textcolor=borderColor,
             style=label.style_label_right, size=size.small)

        lblLow := label.new(startBar, pdLow, "PDL: " + str.tostring(pdLow, "#.##"),
             color=color.new(borderColor,60), textcolor=borderColor,
             style=label.style_label_right, size=size.small)

        lblMid := label.new(startBar, pdMid, "MID: " + str.tostring(pdMid, "#.##"),
             color=color.new(midColor,70), textcolor=midColor,
             style=label.style_label_right, size=size.small)
````
