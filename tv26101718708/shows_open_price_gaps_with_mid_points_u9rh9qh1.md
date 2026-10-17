# Shows open price Gaps with mid points

- url: https://www.tradingview.com/script/U9rH9QH1-Shows-open-price-Gaps-with-mid-points/
- type: indicator
- pine_id: PUB;11b1f041f19843d18fe72c30a4f10a22
- version: 1.0

## Description

This script shows gaps on the current screen view that have not been closed yet by price revisiting them. Once fully closed, they are no longer highlighted

The implication is that often price goes back and closes these open gaps at some point in the future (Bull or Bearish)

If the gap confluences with another price action target like a H&S then its maybe interesting

## Source Code

````pine
//@version=6
indicator("Open Gaps", overlay=true, max_boxes_count=500, max_labels_count=500)

//=====================================================================
// INDICATOR DESCRIPTION
//=====================================================================
// This indicator finds classic price gaps that are visible on the
// current chart screen only.
//
// Gap rules:
// - Bullish gap: current LOW > previous HIGH
// - Bearish gap: current HIGH < previous LOW
//
// What the script does:
// - Scans only the bars visible on screen
// - Draws a box over each visible unfilled gap
// - Shows the midpoint price as a label
// - Does not redraw gaps that have already been filled
//
// Colour logic used in this script:
// - Bullish gaps are RED
// - Bearish gaps are GREEN
//
// Notes:
// - This version does NOT draw a horizontal line to the RHS.
// - Safe lookback is limited to avoid Pine history errors.

//=====================================================
// USER INPUTS
//=====================================================
showBullGaps    = input.bool(true, "Show Bullish Gaps")
showBearGaps    = input.bool(true, "Show Bearish Gaps")
minGapTicks     = input.int(1, "Minimum Gap Size (ticks)", minval=1)
showLabels      = input.bool(true, "Show Price Labels")
gapTransparency = input.int(82, "Gap Box Transparency", minval=0, maxval=100)

//=====================================================
// SETTINGS
//=====================================================
minGapSize = minGapTicks * syminfo.mintick
leftT      = chart.left_visible_bar_time
rightT     = chart.right_visible_bar_time

//=====================================================
// STORAGE
//=====================================================
var box[]   gapBoxes     = array.new_box()
var label[] targetLabels = array.new_label()

//=====================================================
// CLEAR ALL OLD OBJECTS
//=====================================================
clearAll() =>
    int n = array.size(gapBoxes)
    if n > 0
        for i = n - 1 to 0
            box.delete(array.get(gapBoxes, i))
            label lb = array.get(targetLabels, i)
            if not na(lb)
                label.delete(lb)
            array.remove(gapBoxes, i)
            array.remove(targetLabels, i)

//=====================================================
// MAIN DRAW LOGIC
//=====================================================
if barstate.islast
    clearAll()

    int maxLookback = math.min(bar_index, 9999)

    for j = 1 to maxLookback
        bool currInView = time[j - 1] >= leftT and time[j - 1] <= rightT
        bool prevInView = time[j] >= leftT and time[j] <= rightT

        if currInView and prevInView
            bool bullGap = showBullGaps and low[j - 1] > high[j] and (low[j - 1] - high[j]) >= minGapSize
            bool bearGap = showBearGaps and high[j - 1] < low[j] and (low[j] - high[j - 1]) >= minGapSize

            if bullGap
                float top    = low[j - 1]
                float bottom = high[j]
                float mid    = (top + bottom) / 2.0
                int gapBar   = bar_index - j + 1

                bool filled = false
                int fillCheckMax = j - 1
                if fillCheckMax >= 0
                    for k = 0 to fillCheckMax
                        if low[k] <= bottom
                            filled := true
                            break

                if not filled
                    box b = box.new(
                         left = gapBar - 1,
                         top = top,
                         right = bar_index,
                         bottom = bottom,
                         bgcolor = color.new(color.red, gapTransparency),
                         border_color = color.red)

                    label lb = na
                    if showLabels
                        lb := label.new(
                             x = bar_index + 1,
                             y = mid,
                             text = str.tostring(mid, format.mintick),
                             style = label.style_label_left,
                             color = color.red,
                             textcolor = color.white,
                             size = size.small)

                    array.push(gapBoxes, b)
                    array.push(targetLabels, lb)

            if bearGap
                float top    = low[j]
                float bottom = high[j - 1]
                float mid    = (top + bottom) / 2.0
                int gapBar   = bar_index - j + 1

                bool filled = false
                int fillCheckMax = j - 1
                if fillCheckMax >= 0
                    for k = 0 to fillCheckMax
                        if high[k] >= top
                            filled := true
                            break

                if not filled
                    box b = box.new(
                         left = gapBar - 1,
                         top = top,
                         right = bar_index,
                         bottom = bottom,
                         bgcolor = color.new(color.green, gapTransparency),
                         border_color = color.green)

                    label lb = na
                    if showLabels
                        lb := label.new(
                             x = bar_index + 1,
                             y = mid,
                             text = str.tostring(mid, format.mintick),
                             style = label.style_label_left,
                             color = color.green,
                             textcolor = color.white,
                             size = size.small)

                    array.push(gapBoxes, b)
                    array.push(targetLabels, lb)
````
