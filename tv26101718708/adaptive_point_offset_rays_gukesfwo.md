# Adaptive Point Offset Rays

- url: https://www.tradingview.com/script/GukESfwO-Adaptive-Point-Offset-Rays/
- type: indicator
- pine_id: PUB;3ecc102466644bca90c85e698019e714
- version: 1.0

## Description

Adaptive Offset Rays

Futures Point

Plots up to five configurable horizontal rays above current price and five below, each set by a fixed point offset from a chosen price source (default: close). Rays reposition at a user-defined interval rather than every tick, keeping the chart legible instead of accumulating redundant lines.
Inputs

Price reference (source)
Ray length (bars projected forward)
Update frequency (minutes; set to 0 for tick-by-tick tracking)
Five above/below levels, each independently toggled with its own point value
Line colors and optional point-value labels

Use case: dynamic reference levels for gauging distance traveled or remaining toward a target — useful for scalping or intraday setups where fixed dollar/point thresholds matter more than static support/resistance.

Note: rays reflect live price offsets and are not predictive signals; they do not repaint historical values, only their forward projection updates.

## Source Code

````pine
//@version=6
indicator("Adaptive Point Offset Rays", overlay = true, max_lines_count = 20)

// ── Settings ─────────────────────────────────────────────
src        = input.source(close, "Price Reference")
rayLen     = input.int(20, "Ray Length (bars forward)", minval = 1)
updateMin  = input.int(1, "Update Frequency (minutes)", minval = 0, tooltip = "0 = update on every tick")

grpUp   = "Levels Above Price"
u1_on = input.bool(true,  "Enable", inline = "u1", group = grpUp)
u1_pt = input.float(25,   "Points", inline = "u1", group = grpUp)
u2_on = input.bool(true,  "Enable", inline = "u2", group = grpUp)
u2_pt = input.float(50,   "Points", inline = "u2", group = grpUp)
u3_on = input.bool(true,  "Enable", inline = "u3", group = grpUp)
u3_pt = input.float(200,  "Points", inline = "u3", group = grpUp)
u4_on = input.bool(false, "Enable", inline = "u4", group = grpUp)
u4_pt = input.float(0,    "Points", inline = "u4", group = grpUp)
u5_on = input.bool(false, "Enable", inline = "u5", group = grpUp)
u5_pt = input.float(0,    "Points", inline = "u5", group = grpUp)

grpDn   = "Levels Below Price"
d1_on = input.bool(true,  "Enable", inline = "d1", group = grpDn)
d1_pt = input.float(25,   "Points", inline = "d1", group = grpDn)
d2_on = input.bool(true,  "Enable", inline = "d2", group = grpDn)
d2_pt = input.float(50,   "Points", inline = "d2", group = grpDn)
d3_on = input.bool(true,  "Enable", inline = "d3", group = grpDn)
d3_pt = input.float(200,  "Points", inline = "d3", group = grpDn)
d4_on = input.bool(false, "Enable", inline = "d4", group = grpDn)
d4_pt = input.float(0,    "Points", inline = "d4", group = grpDn)
d5_on = input.bool(false, "Enable", inline = "d5", group = grpDn)
d5_pt = input.float(0,    "Points", inline = "d5", group = grpDn)

colUp = input.color(color.new(color.teal, 0),   "Above-Price Color")
colDn = input.color(color.new(color.maroon, 0), "Below-Price Color")
lblOn = input.bool(true, "Show Price Labels")

// ── State: objects created ONCE, reused forever ─────────
var line[]  upLines    = array.new<line>(5)
var line[]  dnLines    = array.new<line>(5)
var label[] upLabels   = array.new<label>(5)
var label[] dnLabels   = array.new<label>(5)
var int     lastUpdate = 0

if barstate.isfirst
    for i = 0 to 4
        array.set(upLines, i, line.new(na, na, na, na))
        array.set(dnLines, i, line.new(na, na, na, na))
        array.set(upLabels, i, label.new(na, na, ""))
        array.set(dnLabels, i, label.new(na, na, ""))

drawRay(lineArr, labelArr, idx, enabled, pts, refPrice, isUp) =>
    l  = array.get(lineArr, idx)
    lb = array.get(labelArr, idx)
    line.set_xy1(l, na, na)
    label.set_x(lb, na)
    if enabled
        level = isUp ? refPrice + pts : refPrice - pts
        line.set_xy1(l, bar_index, level)
        line.set_xy2(l, bar_index + rayLen, level)
        line.set_color(l, isUp ? colUp : colDn)
        line.set_width(l, 2)
        if lblOn
            label.set_xy(lb, bar_index + rayLen, level)
            label.set_text(lb, str.tostring(pts, "#") + " pts")
            label.set_color(lb, color.new(color.black, 100))
            label.set_textcolor(lb, isUp ? colUp : colDn)
            label.set_style(lb, label.style_label_left)

freqMs   = updateMin * 60 * 1000
dueForUpdate = updateMin == 0 or (timenow - lastUpdate >= freqMs)

if barstate.islast and dueForUpdate
    lastUpdate := timenow
    drawRay(upLines, upLabels, 0, u1_on, u1_pt, src, true)
    drawRay(upLines, upLabels, 1, u2_on, u2_pt, src, true)
    drawRay(upLines, upLabels, 2, u3_on, u3_pt, src, true)
    drawRay(upLines, upLabels, 3, u4_on, u4_pt, src, true)
    drawRay(upLines, upLabels, 4, u5_on, u5_pt, src, true)
    drawRay(dnLines, dnLabels, 0, d1_on, d1_pt, src, false)
    drawRay(dnLines, dnLabels, 1, d2_on, d2_pt, src, false)
    drawRay(dnLines, dnLabels, 2, d3_on, d3_pt, src, false)
    drawRay(dnLines, dnLabels, 3, d4_on, d4_pt, src, false)
    drawRay(dnLines, dnLabels, 4, d5_on, d5_pt, src, false)
````
