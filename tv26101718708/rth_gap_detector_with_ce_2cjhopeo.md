# RTH Gap Detector with CE

- url: https://www.tradingview.com/script/2CjHopEo-RTH-Gap-Detector-with-CE/
- type: indicator
- pine_id: PUB;63e5c3920923417bba3ea508666cb2d4
- version: 1.0

## Description

### RTH Gap Detector with C.E.

This indicator detects the gap between the **9:30 AM ET RTH open** and the prior session’s **4:14 PM ET close**. It draws a box over the gap and marks its midpoint as **Consequent Encroachment (C.E.)**. The box extends until price fully fills the gap.

Gap grades are size-based, calculated as a percentage of the prior RTH close: **A** is at or above the Grade A threshold (**0.75% by default**), **B** is at or above the Grade B threshold (**0.25% by default**) but below A, and **C** is below B. These are customizable thresholds, not a separate ICT grading convention.

Settings let you filter small gaps, show or hide labels and the C.E. line, choose bullish/bearish or grade-based colors, and set the label size. By default, it keeps the **five most recent gaps**, including filled gaps. The default session uses New York time; on a 24-hour market such as BTC, it applies that time window to the chart’s prices.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("RTH Gap Detector with CE", shorttitle = "RTH Gap CE", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Session ---
rthSessionInput = input.session("0930-1615:23456", "RTH session", tooltip = "Default spans 9:30 AM to the 4:15 PM ET boundary, including the final 4:14 PM minute bar.", group = "Session")
timezoneInput = input.string("America/New_York", "Session time zone", tooltip = "Time zone used to interpret the RTH session.", group = "Session")

// --- Gap management ---
gapsToKeepInput = input.int(5, "Gaps to keep", minval = 1, maxval = 500, tooltip = "Maximum number of most recent gap drawings to retain, whether filled or still active.", group = "Gap Management")

// --- Gap grading ---
showGradeInput = input.bool(true, "Show gap grade", tooltip = "Show a size-based grade in labels. Gap size (%) = absolute open-to-prior-RTH-close distance divided by the absolute prior RTH close, multiplied by 100. A = at/above the A threshold; B = at/above the B threshold but below A; C = below B.", group = "Grading")
minGapPctInput = input.float(0.0, "Minimum gap (%)", minval = 0.0, step = 0.05, tooltip = "Ignore gaps smaller than this percentage of the prior RTH close.", group = "Grading")
gradeBThresholdInput = input.float(0.25, "Grade B threshold (%)", minval = 0.0, step = 0.05, tooltip = "Default 0.25%. Gaps at/above this threshold are at least B, unless they meet the A threshold. If thresholds are reversed, the lower value is treated as B.", group = "Grading")
gradeAThresholdInput = input.float(0.75, "Grade A threshold (%)", minval = 0.0, step = 0.05, tooltip = "Default 0.75%. Gaps at/above this threshold receive A. If thresholds are reversed, the higher value is treated as A.", group = "Grading")
colorByGradeInput = input.bool(false, "Color boxes by grade", tooltip = "Off: use Bullish gap color for an upward gap and Bearish gap color for a downward gap. On: use Grade A, B, or C color based on gap size. The selected color applies to the box, border, C.E. line, and label text.", group = "Grading")

// --- Display ---
showLabelInput = input.bool(true, "Show labels", tooltip = "Show a label on each qualifying RTH gap.", group = "Display")
labelSizeInput = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], tooltip = "Text size used by gap labels.", group = "Display")
showCeInput = input.bool(true, "Show C.E. level", tooltip = "Draw the Consequent Encroachment midpoint of each gap.", group = "Display")
boxTransparencyInput = input.int(84, "Box transparency", minval = 0, maxval = 100, tooltip = "Transparency of the gap box fill; 100 is fully transparent.", group = "Display")
borderTransparencyInput = input.int(10, "Border transparency", minval = 0, maxval = 100, tooltip = "Transparency of the gap box border.", group = "Display")

// --- Colors ---
bullColorInput = input.color(#089981, "Bullish gap", tooltip = "Used when grade coloring is off and the session open is above the prior RTH close.", group = "Colors")
bearColorInput = input.color(#f23645, "Bearish gap", tooltip = "Used when grade coloring is off and the session open is below the prior RTH close.", group = "Colors")
gradeAColorInput = input.color(#089981, "Grade A", tooltip = "Color used for A-grade gaps when Color boxes by grade is on.", group = "Colors")
gradeBColorInput = input.color(#5b9cf6, "Grade B", tooltip = "Color used for B-grade gaps when Color boxes by grade is on.", group = "Colors")
gradeCColorInput = input.color(#e6a23c, "Grade C", tooltip = "Color used for C-grade gaps when Color boxes by grade is on.", group = "Colors")

// --- Drawing state ---
var box[] gapBoxes = array.new_box()
var line[] ceLines = array.new_line()
var label[] gapLabels = array.new_label()
var float[] fillLevels = array.new_float()
var bool[] bullishGaps = array.new_bool()
var bool[] gapIsActive = array.new_bool()
var float lastRthClose = na

isRth = not na(time(timeframe.period, rthSessionInput, timezoneInput))
firstRthBar = isRth and not isRth[1]

// --- Detect opening gaps ---
if firstRthBar and not na(lastRthClose) and lastRthClose != 0
    gapSize = math.abs(open - lastRthClose)
    gapPct = gapSize / math.abs(lastRthClose) * 100.0
    if gapSize > 0 and gapPct >= minGapPctInput
        isBullishGap = open > lastRthClose
        gapTop = math.max(open, lastRthClose)
        gapBottom = math.min(open, lastRthClose)
        cePrice = (gapTop + gapBottom) / 2.0
        gapGrade = gapPct >= gradeAThresholdInput ? "A" : gapPct >= gradeBThresholdInput ? "B" : "C"
        gapColor = colorByGradeInput ? (gapGrade == "A" ? gradeAColorInput : gapGrade == "B" ? gradeBColorInput : gradeCColorInput) : (isBullishGap ? bullColorInput : bearColorInput)
        labelSize = switch labelSizeInput
            "Tiny" => size.tiny
            "Normal" => size.normal
            "Large" => size.large
            "Huge" => size.huge
            => size.small
        gapBox = box.new(left = bar_index, top = gapTop, right = bar_index, bottom = gapBottom, bgcolor = color.new(gapColor, boxTransparencyInput), border_color = color.new(gapColor, borderTransparencyInput))
        ceLine = showCeInput ? line.new(x1 = bar_index, y1 = cePrice, x2 = bar_index, y2 = cePrice, color = gapColor, style = line.style_dashed, width = 1) : na
        gapText = showGradeInput ? "RTH GAP " + gapGrade : "RTH GAP"
        if showCeInput
            gapText += "\nCE " + str.tostring(cePrice, format.mintick)
        gapLabel = showLabelInput ? label.new(x = bar_index + 1, y = cePrice, text = gapText, xloc = xloc.bar_index, style = label.style_label_left, color = #00000000, textcolor = gapColor, size = labelSize) : na
        array.push(gapBoxes, gapBox)
        array.push(ceLines, ceLine)
        array.push(gapLabels, gapLabel)
        array.push(fillLevels, isBullishGap ? gapBottom : gapTop)
        array.push(bullishGaps, isBullishGap)
        array.push(gapIsActive, true)

        while array.size(gapBoxes) > gapsToKeepInput
            oldBox = array.shift(gapBoxes)
            oldLine = array.shift(ceLines)
            oldLabel = array.shift(gapLabels)
            array.shift(fillLevels)
            array.shift(bullishGaps)
            array.shift(gapIsActive)
            box.delete(oldBox)
            if not na(oldLine)
                line.delete(oldLine)
            if not na(oldLabel)
                label.delete(oldLabel)

// Extend active drawings until the gap is fully filled.
activeIndex = 0
while activeIndex < array.size(gapBoxes)
    if array.get(gapIsActive, activeIndex)
        activeBox = array.get(gapBoxes, activeIndex)
        activeLine = array.get(ceLines, activeIndex)
        activeLabel = array.get(gapLabels, activeIndex)
        fillLevel = array.get(fillLevels, activeIndex)
        isBullish = array.get(bullishGaps, activeIndex)
        box.set_right(activeBox, bar_index)
        if not na(activeLine)
            line.set_x2(activeLine, bar_index)
        if not na(activeLabel)
            label.set_x(activeLabel, bar_index + 1)
        isFilled = isBullish ? low <= fillLevel : high >= fillLevel
        if isFilled
            array.set(gapIsActive, activeIndex, false)
            if not na(activeLabel)
                label.set_x(activeLabel, bar_index)
        else
            activeIndex += 1
    else
        activeIndex += 1

// Store the latest close observed inside RTH for the next session's gap comparison.
if isRth
    lastRthClose := close
````
