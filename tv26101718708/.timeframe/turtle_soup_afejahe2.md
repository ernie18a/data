# Turtle Soup

- url: https://www.tradingview.com/script/afeJahe2-Turtle-Soup/
- type: indicator
- pine_id: PUB;dfd9013cfd4d446eb801f4f102be58ca
- version: 1.0

## Description

This turtle soup indicator marks out swing points, you can choose whatever timeframe you want but I would not recomend using anything under the 15M timeframe as they are insignificant. There is also an option to remove swing points that are not within a HTF (15M+) FVG as well as an option to display the date and time of the swing points in order to easier spot SMT.

Any support for this indicator on my way to profitability is greatly appreciated: Paypal @Windowmaep

## Source Code

````pine
//@version=6
indicator("Turtle Soup", overlay = true, max_lines_count=500, max_labels_count=500)

// === Filters (swing history, FVG, spacing, swept) ===
lastNSwings = input.int(10, "Max number of swings", minval = 1, maxval = 500, group = "Filters")
min15mBarsBetweenSameSide = input.int(5, "Spacing", minval = 0, maxval = 200, group = "Filters")
useFvgFilter = input.bool(false, "Only show swings inside a HTF FVG", group = "Filters")
fvgLookback  = input.int(100, "FVG lookback", minval = 20, maxval = 500, group = "Filters")
removeSweptSwings = input.bool(false, "Remove swept swings", group = "Filters")
sweptTagBarShift  = input.int(-15, "Tag offset", minval = -500, maxval = 500, group = "Filters")
sweptDateBarShift = input.int(-15, "Text offset", minval = -500, maxval = 500, group = "Filters")

// === Date & time on chart ===
showSwingDate     = input.bool(true, "Show", group = "Date & time")
swingDateFormat   = input.string("MM-dd HH:mm", "Format", group = "Date & time")
swingDateBarShift = input.int(0, "Text offset", minval = 0, maxval = 50, group = "Date & time")
swingDateSizeIn   = input.string("Tiny", "Text size", options = ["Normal", "Large", "Small", "Tiny", "Auto"], group = "Date & time")
swingDateColorIn  = input.color(color.new(color.black, 0), "Text color", group = "Date & time")

// === Timeframe ===
swingsToShow  = input.string("Both", "Show", options = ["Both", "Highs only", "Lows only"], group = "Timeframe")
showSwingHighs = swingsToShow == "Both" or swingsToShow == "Highs only"
showSwingLows  = swingsToShow == "Both" or swingsToShow == "Lows only"
swingTf      = input.timeframe("15", group = "Timeframe", inline = "swtf", title = "Timeframe - Tag")
swingTfTag    = input.string("🐢", group = "Timeframe", inline = "swtf", title = "")
swingTfColor  = input.color(color.orange, group = "Timeframe", inline = "swtfst", title = "Color - Style - Width")
swingTfStyle  = input.string("Solid", group = "Timeframe", inline = "swtfst", title = "", options = ["Solid", "Dashed", "Dotted"])
swingTfWidth  = input.int(2, group = "Timeframe", inline = "swtfst", title = "")

tagSizeInput = input.string("Small", title="Tag size", options = ['Normal','Large','Small','Tiny','Auto'])

tagColor     = color.white
tagOffset    = 0
tagLineColor = false
tagLevel     = false

textSize(x) =>
    switch x
        'Normal'  => size.normal
        'Small'   => size.small
        'Tiny'    => size.tiny
        'Auto'    => size.auto
        'Large'   => size.large

tagSize = textSize(tagSizeInput)
swingDateSize = textSize(swingDateSizeIn)

// Offset tag anchors from the level so text sits clearly above swing highs and below swing lows.
tagVertPad = math.max(nz(ta.atr(14), syminfo.mintick * 500) * 0.06, syminfo.mintick * 25)

type Level
    float   level
    string  timeframe
    string  tag
    color   linecolor
    string  style
    int     width
    line    line = na
    label   label = na

timeframeSeconds = timeframe.in_seconds()
swingTfSeconds = timeframe.in_seconds(swingTf)

lineStyle(x) =>
    switch x
        'Solid'  => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted

var swings = array.new_line()
var tags = array.new_label()
var dateTags = array.new_label()

var swingHistoryLines = array.new_line()
var swingHistoryLabels = array.new_label()
var swingHistoryDateLabels = array.new_label()

var int lastSwingHigh15mBar = na
var int lastSwingLow15mBar = na

// Last accepted same-side swing for 15m spacing replacement (weak swing removed if a stronger one forms inside the min bar window).
var line   spacingHighLine = na
var label  spacingHighTag = na
var label  spacingHighDt = na
var float  spacingHighLevel = na

var line   spacingLowLine = na
var label  spacingLowTag = na
var label  spacingLowDt = na
var float  spacingLowLevel = na

purgeActiveSwingIfPresent(line oldLn) =>
    int sz = array.size(swings)
    if sz > 0
        for hidx = sz - 1 to 0
            if array.get(swings, hidx) == oldLn
                array.remove(swings, hidx)
                array.remove(tags, hidx)
                array.remove(dateTags, hidx)
                break

purgeAndDeleteSwingGraphics(line oldLn, label oldLb, label oldDt) =>
    purgeActiveSwingIfPresent(oldLn)
    line.delete(oldLn)
    label.delete(oldLb)
    if not na(oldDt)
        label.delete(oldDt)

removeSwingFromHistory(line ln) =>
    int n = array.size(swingHistoryLines)
    if n > 0
        for idx = 0 to n - 1
            if array.get(swingHistoryLines, idx) == ln
                array.remove(swingHistoryLines, idx)
                array.remove(swingHistoryLabels, idx)
                array.remove(swingHistoryDateLabels, idx)
                break

registerSwingByTime(line ln, label lb, label dtLb) =>
    array.push(swingHistoryLines, ln)
    array.push(swingHistoryLabels, lb)
    array.push(swingHistoryDateLabels, dtLb)
    fifoRemoved = array.new_line()
    while array.size(swingHistoryLines) > lastNSwings
        oldLn = array.shift(swingHistoryLines)
        oldLb = array.shift(swingHistoryLabels)
        oldDt = array.shift(swingHistoryDateLabels)
        array.push(fifoRemoved, oldLn)
        purgeAndDeleteSwingGraphics(oldLn, oldLb, oldDt)
    fifoRemoved

fmtSwingDate(int t) =>
    str.format_time(t, swingDateFormat, syminfo.timezone)

// Bearish FVG: high[i] < low[i+2] → zone [high[i], low[i+2]]. Swing-high filter: pivot *wick high* must lie in this zone only.
// Bullish FVG: low[i] > high[i+2] → zone [high[i+2], low[i]]. Swing-low filter: pivot *wick low* must lie in this zone only.
// "Active" on a TF: no newer bar (0 .. i-1) has closed at or outside that zone (close ≤ zLo or close ≥ zHi).
wickHighInsideActiveBearishFvg(float wickHigh, int lb) =>
    bool found = false
    int maxI = math.min(lb, bar_index)
    if maxI >= 2 and not na(wickHigh)
        for i = 2 to maxI
            if high[i] < low[i + 2]
                float zLo = high[i]
                float zHi = low[i + 2]
                if wickHigh >= zLo and wickHigh <= zHi
                    bool closedOver = false
                    for k = 0 to i - 1
                        if close[k] <= zLo or close[k] >= zHi
                            closedOver := true
                            break
                    if not closedOver
                        found := true
                        break
            if found
                break
    found

wickLowInsideActiveBullishFvg(float wickLow, int lb) =>
    bool found = false
    int maxI = math.min(lb, bar_index)
    if maxI >= 2 and not na(wickLow)
        for i = 2 to maxI
            if low[i] > high[i + 2]
                float zLo = high[i + 2]
                float zHi = low[i]
                if wickLow >= zLo and wickLow <= zHi
                    bool closedOver = false
                    for k = 0 to i - 1
                        if close[k] <= zLo or close[k] >= zHi
                            closedOver := true
                            break
                    if not closedOver
                        found := true
                        break
            if found
                break
    found

bearishFvgOnTf(float wickHigh, string tf) =>
    request.security(syminfo.tickerid, tf, wickHighInsideActiveBearishFvg(wickHigh, fvgLookback), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

bullishFvgOnTf(float wickLow, string tf) =>
    request.security(syminfo.tickerid, tf, wickLowInsideActiveBullishFvg(wickLow, fvgLookback), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

swingHighWickInActive15mPlusBearishFvg(float pivotWickHigh) =>
    bearishFvgOnTf(pivotWickHigh, "15") or bearishFvgOnTf(pivotWickHigh, "30") or bearishFvgOnTf(pivotWickHigh, "60") or bearishFvgOnTf(pivotWickHigh, "240") or bearishFvgOnTf(pivotWickHigh, "D") or bearishFvgOnTf(pivotWickHigh, "W")

swingLowWickInActive15mPlusBullishFvg(float pivotWickLow) =>
    bullishFvgOnTf(pivotWickLow, "15") or bullishFvgOnTf(pivotWickLow, "30") or bullishFvgOnTf(pivotWickLow, "60") or bullishFvgOnTf(pivotWickLow, "240") or bullishFvgOnTf(pivotWickLow, "D") or bullishFvgOnTf(pivotWickLow, "W")

// Anchor x at line tip (x2): box below price for swing highs; text right-aligned to the anchor.
newSwingDateLabelHigh(float y, int xAtLineEnd, int pivotTime) =>
    label.new(xAtLineEnd, y, text = fmtSwingDate(pivotTime), style = label.style_label_up, color = color.new(color.black, 100), textcolor = swingDateColorIn, size = swingDateSize, textalign = text.align_right)

// Anchor x at line tip: box above price for swing lows.
newSwingDateLabelLow(float y, int xAtLineEnd, int pivotTime) =>
    label.new(xAtLineEnd, y, text = fmtSwingDate(pivotTime), style = label.style_label_down, color = color.new(color.black, 100), textcolor = swingDateColorIn, size = swingDateSize, textalign = text.align_right)

checkExisting(inLevel, inTag, inColor, inStyle, inWidth) =>
    bool new = true
    size = array.size(swings)

    if size > 0
        for i = 0 to size - 1
            j = size - 1 - i
            swing = array.get(swings, j)
            level = line.get_y2(swing)
            tag = array.get(tags, j)

            if (inLevel == level)
                new := false
                line.set_style(swing, lineStyle(inStyle))
                line.set_color(swing, inColor)
                line.set_width(swing, inWidth)
                label.set_text(tag, tagLevel ? inTag + " " + str.tostring(inLevel) : inTag)
                if tagLineColor
                    label.set_textcolor(tag, color.new(inColor, 0))
                break
    new

if barstate.isconfirmed
    int cur15mBar = int(request.security(syminfo.tickerid, "15", bar_index, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))
    if timeframeSeconds <= swingTfSeconds
        bool drewNewHigh = false
        if showSwingHighs
            begLtf = time
            endLtf = time_close
            [begHtf, endHtf, prevTime, high0, high1, high2, high3, high4] = request.security(syminfo.tickerid, swingTf, [time, time_close, time[3], high[0], high[1], high[2], high[3], high[4]])

            if endLtf == endHtf or begLtf < begHtf or (begLtf < endHtf and barstate.ishistory)
                int n = endLtf == endHtf or barstate.ishistory ? 0 : 1

                if (n == 0 and high0 < high1 and high1 > high2) or (n == 0 and high0 < high1 and high1 == high2 and high2 > high3) or (n == 1 and high1 < high2 and high2 > high3) or (n == 1 and high1 < high2 and high2 == high3 and high3 > high4)
                    swingHigh = n == 0 ? high1 : high2
                    new = checkExisting(swingHigh, swingTfTag, swingTfColor, swingTfStyle, swingTfWidth)

                    bool tooSoonHigh = min15mBarsBetweenSameSide > 0 and not na(cur15mBar) and not na(lastSwingHigh15mBar) and (cur15mBar - lastSwingHigh15mBar) < min15mBarsBetweenSameSide
                    bool replaceWeakHigh = tooSoonHigh and not na(spacingHighLine) and not na(spacingHighLevel) and swingHigh > spacingHighLevel
                    bool allowHighBySpacing = min15mBarsBetweenSameSide <= 0 or not tooSoonHigh or replaceWeakHigh or na(spacingHighLine)

                    if new and allowHighBySpacing and (not useFvgFilter or swingHighWickInActive15mPlusBearishFvg(swingHigh))
                        if replaceWeakHigh
                            line lnRep = spacingHighLine
                            label lbRep = spacingHighTag
                            label dtRep = spacingHighDt
                            spacingHighLine := na
                            spacingHighTag := na
                            spacingHighDt := na
                            spacingHighLevel := na
                            purgeAndDeleteSwingGraphics(lnRep, lbRep, dtRep)
                            removeSwingFromHistory(lnRep)

                        int i = 0
                        int bar = na

                        while na(bar) and time[i] > prevTime
                            if high[i] == swingHigh
                                bar := i
                            i := i + 1

                        int pivotBar = bar_index - bar
                        int pivotTime = time[bar]

                        swing = line.new(pivotBar, swingHigh, bar_index + 1, swingHigh, color = swingTfColor, style = lineStyle(swingTfStyle), width = swingTfWidth)
                        tag = label.new(bar_index + tagOffset, swingHigh + tagVertPad, text = tagLevel ? swingTfTag + " " + str.tostring(swingHigh) : swingTfTag, style = label.style_label_up, color = color.new(color.black, 100), textcolor = tagLineColor ? color.new(swingTfColor, 0) : tagColor, size = tagSize, textalign = text.align_right)

                        int lineEndX = bar_index + 1 + swingDateBarShift
                        label dtLb = na
                        if showSwingDate
                            dtLb := newSwingDateLabelHigh(swingHigh, lineEndX, pivotTime)

                        fifoRm = registerSwingByTime(swing, tag, dtLb)
                        int fifoSz = array.size(fifoRm)
                        if fifoSz > 0
                            for ri = 0 to fifoSz - 1
                                lnRm = array.get(fifoRm, ri)
                                if not na(spacingHighLine) and spacingHighLine == lnRm
                                    spacingHighLine := na
                                    spacingHighTag := na
                                    spacingHighDt := na
                                    spacingHighLevel := na
                                if not na(spacingLowLine) and spacingLowLine == lnRm
                                    spacingLowLine := na
                                    spacingLowTag := na
                                    spacingLowDt := na
                                    spacingLowLevel := na
                        array.push(swings, swing)
                        array.push(tags, tag)
                        array.push(dateTags, dtLb)
                        spacingHighLine := swing
                        spacingHighTag := tag
                        spacingHighDt := dtLb
                        spacingHighLevel := swingHigh
                        drewNewHigh := true

        if showSwingHighs and drewNewHigh and not na(cur15mBar)
            lastSwingHigh15mBar := cur15mBar

        bool drewNewLow = false
        if showSwingLows
            begLtfLo = time
            endLtfLo = time_close
            [begHtfLo, endHtfLo, prevTimeLo, low0, low1, low2, low3, low4] = request.security(syminfo.tickerid, swingTf, [time, time_close, time[3], low[0], low[1], low[2], low[3], low[4]])

            if endLtfLo == endHtfLo or begLtfLo < begHtfLo or (begLtfLo < endHtfLo and barstate.ishistory)
                int nLo = endLtfLo == endHtfLo or barstate.ishistory ? 0 : 1

                if (nLo == 0 and low0 > low1 and low1 < low2) or (nLo == 0 and low0 > low1 and low1 == low2 and low2 < low3) or (nLo == 1 and low1 > low2 and low2 < low3) or (nLo == 1 and low1 > low2 and low2 == low3 and low3 < low4)
                    swingLow = nLo == 0 ? low1 : low2
                    newLo = checkExisting(swingLow, swingTfTag, swingTfColor, swingTfStyle, swingTfWidth)

                    bool tooSoonLow = min15mBarsBetweenSameSide > 0 and not na(cur15mBar) and not na(lastSwingLow15mBar) and (cur15mBar - lastSwingLow15mBar) < min15mBarsBetweenSameSide
                    bool replaceWeakLow = tooSoonLow and not na(spacingLowLine) and not na(spacingLowLevel) and swingLow < spacingLowLevel
                    bool allowLowBySpacing = min15mBarsBetweenSameSide <= 0 or not tooSoonLow or replaceWeakLow or na(spacingLowLine)

                    if newLo and allowLowBySpacing and (not useFvgFilter or swingLowWickInActive15mPlusBullishFvg(swingLow))
                        if replaceWeakLow
                            line lnRepLo = spacingLowLine
                            label lbRepLo = spacingLowTag
                            label dtRepLo = spacingLowDt
                            spacingLowLine := na
                            spacingLowTag := na
                            spacingLowDt := na
                            spacingLowLevel := na
                            purgeAndDeleteSwingGraphics(lnRepLo, lbRepLo, dtRepLo)
                            removeSwingFromHistory(lnRepLo)

                        int iLo = 0
                        int barLo = na

                        while na(barLo) and time[iLo] > prevTimeLo
                            if low[iLo] == swingLow
                                barLo := iLo
                            iLo := iLo + 1

                        int pivotBarLo = bar_index - barLo
                        int pivotTimeLo = time[barLo]

                        swingLo = line.new(pivotBarLo, swingLow, bar_index + 1, swingLow, color = swingTfColor, style = lineStyle(swingTfStyle), width = swingTfWidth)
                        tagLo = label.new(bar_index + tagOffset, swingLow - tagVertPad, text = tagLevel ? swingTfTag + " " + str.tostring(swingLow) : swingTfTag, style = label.style_label_down, color = color.new(color.black, 100), textcolor = tagLineColor ? color.new(swingTfColor, 0) : tagColor, size = tagSize, textalign = text.align_right)

                        int lineEndXLo = bar_index + 1 + swingDateBarShift
                        label dtLbLo = na
                        if showSwingDate
                            dtLbLo := newSwingDateLabelLow(swingLow, lineEndXLo, pivotTimeLo)

                        fifoRmLo = registerSwingByTime(swingLo, tagLo, dtLbLo)
                        int fifoSzLo = array.size(fifoRmLo)
                        if fifoSzLo > 0
                            for riLo = 0 to fifoSzLo - 1
                                lnRmLo = array.get(fifoRmLo, riLo)
                                if not na(spacingHighLine) and spacingHighLine == lnRmLo
                                    spacingHighLine := na
                                    spacingHighTag := na
                                    spacingHighDt := na
                                    spacingHighLevel := na
                                if not na(spacingLowLine) and spacingLowLine == lnRmLo
                                    spacingLowLine := na
                                    spacingLowTag := na
                                    spacingLowDt := na
                                    spacingLowLevel := na
                        array.push(swings, swingLo)
                        array.push(tags, tagLo)
                        array.push(dateTags, dtLbLo)
                        spacingLowLine := swingLo
                        spacingLowTag := tagLo
                        spacingLowDt := dtLbLo
                        spacingLowLevel := swingLow
                        drewNewLow := true

        if showSwingLows and drewNewLow and not na(cur15mBar)
            lastSwingLow15mBar := cur15mBar

    size = array.size(swings)

    if size > 0
        for i = 0 to size - 1
            j = size - 1 - i
            swing = array.get(swings, j)
            level = line.get_y2(swing)
            tag = array.get(tags, j)
            dtLb = array.get(dateTags, j)
            filled = (high >= level and low <= level)

            if filled
                array.remove(swings, j)
                array.remove(tags, j)
                array.remove(dateTags, j)
                if removeSweptSwings
                    removeSwingFromHistory(swing)
                    if not na(spacingHighLine) and spacingHighLine == swing
                        spacingHighLine := na
                        spacingHighTag := na
                        spacingHighDt := na
                        spacingHighLevel := na
                    if not na(spacingLowLine) and spacingLowLine == swing
                        spacingLowLine := na
                        spacingLowTag := na
                        spacingLowDt := na
                        spacingLowLevel := na
                    line.delete(swing)
                    label.delete(tag)
                    if not na(dtLb)
                        label.delete(dtLb)
                else
                    line.set_x2(swing, bar_index)
                    label.set_x(tag, bar_index + tagOffset + sweptTagBarShift)
                    if not na(dtLb)
                        label.set_x(dtLb, int(line.get_x2(swing)) + swingDateBarShift + sweptDateBarShift)
                continue
            else
                line.set_x2(swing, bar_index + 1)
                label.set_x(tag, bar_index + tagOffset)
                if not na(dtLb)
                    label.set_x(dtLb, int(line.get_x2(swing)) + swingDateBarShift)
````
