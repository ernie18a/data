<!-- tradingview-pine-id: PUB;ed43bd62e3eb46fb95b1025b01d2e0e2 -->
<!-- tradingviewscripts-format: 1 -->
# AmberWaves Gap Fill Tracker

Source: https://www.tradingview.com/script/sUgJya2j-AmberWaves-Gap-Fill-Tracker/

## Description

This script identifies gaps with colored boxes and identifies the start date of each gap/box with text to the bottom right of the box. If a candle reduces the size of the gap, the box is reduced in like manner. Boxes representing gaps do not disappear until the gap is filled.

Box color, outline color, and label are modifiable features in the settings.

---

## Source Code

````pine
//@version=6
indicator("AmberWaves Gap Fill Tracker", overlay=true, max_boxes_count=500, max_labels_count=500)
//@AmberWaves

//=====================
// Inputs
//=====================
minGapPct   = input.float(0.1, "Minimum Gap Size (%)", minval=0.0, step=0.05, group="Detection")
lookbackBars = input.int(2000, "Max bars to track gaps", minval=100, group="Detection")

boxColorUp   = input.color(color.new(color.lime, 85), "Gap Up Box Color", group="Appearance")
boxColorDown = input.color(color.new(color.red, 85), "Gap Down Box Color", group="Appearance")
borderColorUp   = input.color(color.new(color.lime, 40), "Gap Up Border", group="Appearance")
borderColorDown = input.color(color.new(color.red, 40), "Gap Down Border", group="Appearance")
extendBoxes  = input.bool(true, "Extend boxes to current bar", group="Appearance")

showLabel    = input.bool(true, "Show date label", group="Label")
labelSize    = input.string(size.tiny, "Label Size", options=[size.tiny, size.small, size.normal], group="Label")
labelColor   = input.color(color.new(color.gray, 20), "Label Text Color", group="Label")
dateLabelSize  = input.string(size.tiny, "Date Label Size", options=[size.tiny, size.small, size.normal, size.large, size.huge], group="Label")

tz = input.string("America/Chicago", "Time Zone", options=[
     "America/Chicago",
     "America/New_York",
     "America/Los_Angeles",
     "Etc/UTC"
], group="Label")

//=====================
// Gap detection
//=====================
prevClose = close[1]
gapPct = prevClose != 0 ? math.abs(open - prevClose) / prevClose * 100.0 : 0.0

isGapUp   = open > prevClose and gapPct >= minGapPct
isGapDown = open < prevClose and gapPct >= minGapPct

gapTop    = isGapUp ? open : isGapDown ? prevClose : na
gapBottom = isGapUp ? prevClose : isGapDown ? open : na

dateStr = str.tostring(year(time, tz)) + "-" + str.tostring(month(time, tz), "00") + "-" + str.tostring(dayofmonth(time, tz), "00")

//=====================
// Tracking arrays for open gaps
//=====================
var array<box>   gapBoxes   = array.new<box>()
var     array<float> gapTops    = array.new<float>()
var array<float> gapBottoms = array.new<float>()
var array<bool>  gapIsUp    = array.new<bool>()
var array<int>   gapBarIdx  = array.new<int>()
var array<label>  gapLabels    = array.new<label>()

var array<label> dateLabels = array.new<label>()
//=====================
// Create new gap box when detected
//=====================
if (isGapUp or isGapDown) and not na(gapTop) and not na(gapBottom)
    bColor = isGapUp ? boxColorUp : boxColorDown
    bBorder = isGapUp ? borderColorUp : borderColorDown

    newBox = box.new(
                 left  = bar_index,
         top = gapTop,
         right = bar_index,
                  bottom = gapBottom,
         border_color = bBorder,
         bgcolor = bColor,
                 extend = extend.none)

    array.push(gapBoxes, newBox)
    array.push(gapTops, gapTop)
    array.push(gapBottoms, gapBottom)
    array.push(gapIsUp, isGapUp)
    array.push(gapBarIdx, bar_index)

    dateLabel = label.new(
            x = bar_index,
            y = gapBottom,
            text = dateStr,
            style = label.style_label_up,
            textcolor = color.white,
            color = color.new(color.black, 100),
                    size = dateLabelSize,
            textalign = text.align_right)
    array.push(dateLabels, dateLabel)

    if showLabel
        newLabel = label.new(
             x = bar_index,
             y = gapIsUp.last() ? gapTop : gapBottom,
             text = dateStr,
             style = isGapUp ? label.style_label_down : label.style_label_up,
             textcolor = labelColor,
             color = color.new(color.black, 100),
             size = labelSize)
        array.push(gapLabels, newLabel)
    else
        array.push(gapLabels, na)

//=====================
// Check existing gaps for fill, remove if filled
//=====================
if array.size(gapBoxes) > 0
    for i = array.size(gapBoxes) - 1 to 0
        top = array.get(gapTops, i)
        bottom = array.get(gapBottoms, i)
        upGap = array.get(gapIsUp, i)

        filled = upGap ? (low <= bottom) : (high >= top)

            // Shrink box if a candle has partially closed the gap
        if not filled
            if upGap and low < top
                top := low
                array.set(gapTops, i, top)
                box.set_top(array.get(gapBoxes, i), top)
            if not upGap and high > bottom
                bottom := high
                array.set(gapBottoms, i, bottom)
                box.set_bottom(array.get(gapBoxes, i), bottom)
                dl3 = array.get(dateLabels, i)
                if not na(dl3)
                    label.set_y(dl3, bottom)

        tooOld = bar_index - array.get(gapBarIdx, i) > lookbackBars

        if filled or tooOld
            b = array.get(gapBoxes, i)
            box.delete(b)

            l = array.get(gapLabels, i)
            if not na(l)
                label.delete(l)

            dl = array.get(dateLabels, i)
            if not na(dl)
                label.delete(dl)

            array.remove(gapBoxes, i)
            array.remove(gapTops, i)
            array.remove(gapBottoms, i)
            array.remove(gapIsUp, i)
            array.remove(dateLabels, i)
            array.remove(gapBarIdx, i)
            array.remove(gapLabels, i)
        else
            box.set_right(array.get(gapBoxes, i), bar_index)
            dl2 = array.get(dateLabels, i)
            if not na(dl2)
                label.set_x(dl2, bar_index)
````
