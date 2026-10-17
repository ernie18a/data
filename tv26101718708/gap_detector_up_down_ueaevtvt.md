# Gap Detector (Up & Down)

- url: https://www.tradingview.com/script/uEAEvtvT-Gap-Detector-Up-Down/
- type: indicator
- pine_id: PUB;a180c98587284b6ab881521a24317ab9
- version: 1.0

## Description

Gap Detector marks bullish and bearish price gaps directly on the chart.

A Gap Up is detected when the current candle’s low is above the previous candle’s high.
A Gap Down is detected when the current candle’s high is below the previous candle’s low.

The indicator draws gap zones as boxes and extends them until price comes back to fill the gap. When the gap is fully closed, it can label the zone as closed.

Use this indicator to identify possible gap-fill trades, continuation setups, support/resistance zones, and areas where price may react.

## Source Code

````pine
//@version=6
indicator("Gap Detector (Up & Down)", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─── Inputs ───────────────────────────────────────────────────────────────────
gapMinPct     = input.float(0.1,  "Minimum Gap Size (%)",  minval=0.0, step=0.1,
                 tooltip="Only flag gaps where the gap is at least this % of the prior close.")
maxGaps       = input.int(8,      "Max Open Gaps to Show", minval=1,   maxval=50)
showGapZones  = input.bool(true,  "Show Gap Zones (boxes)")
showLabels    = input.bool(true,  "Show Labels")
fillGapZones  = input.bool(true,  "Fill Gap Zones")
colorUp       = input.color(color.new(color.green, 80), "Gap-Up Color")
colorDown     = input.color(color.new(color.red,   80), "Gap-Down Color")
borderUp      = input.color(color.new(color.green, 20), "Gap-Up Border")
borderDown    = input.color(color.new(color.red,   20), "Gap-Down Border")
showClosedTag = input.bool(true,  "Label Closed Gaps")

// ─── Gap Detection ────────────────────────────────────────────────────────────
prevHigh  = high[1]
prevLow   = low[1]
prevClose = close[1]

isGapUp   = low > prevHigh and (low - prevHigh) / prevClose * 100 >= gapMinPct
isGapDown = high < prevLow  and (prevLow - high) / prevClose * 100 >= gapMinPct

// ─── Gap Zone Boxes ───────────────────────────────────────────────────────────
var box[]   gapBoxes   = array.new_box()
var float[] gapTops    = array.new_float()
var float[] gapBottoms = array.new_float()
var bool[]  gapIsUp    = array.new_bool()
var bool[]  gapClosed  = array.new_bool()

// Helper: purge oldest open gap when we exceed maxGaps
pruneOldestOpenGap() =>
    // Count open gaps
    openCount = 0
    for i = 0 to array.size(gapClosed) - 1
        if not array.get(gapClosed, i)
            openCount += 1

    if openCount > maxGaps
        // Find and remove the oldest open gap (lowest index)
        for i = 0 to array.size(gapClosed) - 1
            if not array.get(gapClosed, i)
                box.delete(array.get(gapBoxes, i))
                array.remove(gapBoxes,   i)
                array.remove(gapTops,    i)
                array.remove(gapBottoms, i)
                array.remove(gapIsUp,    i)
                array.remove(gapClosed,  i)
                break

// Open new gap zones
if isGapUp and showGapZones
    b = box.new(bar_index - 1, low, bar_index, prevHigh,
         bgcolor      = fillGapZones ? colorUp : color.new(color.green, 100),
         border_color = borderUp,
         border_width = 1,
         extend       = extend.right)
    array.push(gapBoxes,   b)
    array.push(gapTops,    low)
    array.push(gapBottoms, prevHigh)
    array.push(gapIsUp,    true)
    array.push(gapClosed,  false)
    pruneOldestOpenGap()

if isGapDown and showGapZones
    b = box.new(bar_index - 1, prevLow, bar_index, high,
         bgcolor      = fillGapZones ? colorDown : color.new(color.red, 100),
         border_color = borderDown,
         border_width = 1,
         extend       = extend.right)
    array.push(gapBoxes,   b)
    array.push(gapTops,    prevLow)
    array.push(gapBottoms, high)
    array.push(gapIsUp,    false)
    array.push(gapClosed,  false)
    pruneOldestOpenGap()

// Close gap zones when price fills back through them
if array.size(gapBoxes) > 0
    for i = array.size(gapBoxes) - 1 to 0
        if not array.get(gapClosed, i)
            top    = array.get(gapTops,    i)
            bottom = array.get(gapBottoms, i)
            isUp   = array.get(gapIsUp,    i)
            b      = array.get(gapBoxes,   i)

            if isUp and low <= bottom
                box.delete(b)
                array.set(gapClosed, i, true)
                if showClosedTag and showLabels
                    label.new(bar_index, bottom,
                         "✓ Gap Up\nClosed",
                         style    = label.style_label_up,
                         color    = color.new(color.green, 60),
                         textcolor= color.white,
                         size     = size.small)

            if not isUp and high >= top
                box.delete(b)
                array.set(gapClosed, i, true)
                if showClosedTag and showLabels
                    label.new(bar_index, top,
                         "✓ Gap Down\nClosed",
                         style    = label.style_label_down,
                         color    = color.new(color.red, 60),
                         textcolor= color.white,
                         size     = size.small)

// ─── Signal Labels ────────────────────────────────────────────────────────────
if isGapUp and showLabels
    label.new(bar_index, low,
         "▲ Gap Up\n+" + str.tostring(math.round((low - prevHigh) / prevClose * 100, 2)) + "%",
         style    = label.style_label_down,
         color    = color.new(color.green, 20),
         textcolor= color.white,
         size     = size.normal)

if isGapDown and showLabels
    label.new(bar_index, high,
         "▼ Gap Down\n-" + str.tostring(math.round((prevLow - high) / prevClose * 100, 2)) + "%",
         style    = label.style_label_up,
         color    = color.new(color.red, 20),
         textcolor= color.white,
         size     = size.normal)

// ─── Bar Colors ───────────────────────────────────────────────────────────────
barcolor(isGapUp   ? color.new(color.green, 50) :
         isGapDown ? color.new(color.red,   50) : na)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(isGapUp,   "Gap Up Detected",   "Price gapped UP on {{ticker}} ({{interval}})")
alertcondition(isGapDown, "Gap Down Detected", "Price gapped DOWN on {{ticker}} ({{interval}})")
````
