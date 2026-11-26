# [ad] Opens & Previous Day H/L

- url: https://www.tradingview.com/script/bj1IB49A-ad-Opens-Previous-Day-H-L/
- type: indicator
- pine_id: PUB;ff027baa5bab4e6dbddabaa46fa8d8a0
- version: 5.0

## Description

Opens & Previous Day H/L draws the reference levels many traders watch, directly on the chart:
• yOpen, mOpen, wOpen, dOpen: Yearly, Monthly, Weekly and Daily Open
• PDH, PDL: Previous Day High and Low
• Optional: PWH, PWL (Previous Week High/Low) and PMH, PML (Previous Month High/Low)

How it looks
Every level is a thin 1 px line that starts on the candle where its period opened (previous highs and lows start where the previous period began). A short label sits inside the line, so it reads like a gap in the line instead of a banner on top of the chart. Levels at the same price share one label, for example "wOpen / dOpen" on a Monday, and labels of nearby levels are moved apart horizontally so they do not cover each other.

How it works
The levels come from the higher timeframe via request.security() with lookahead_on and a [1] offset for previous highs and lows, so only values that are already final are used: an open is known as soon as its period starts, and a previous high or low comes from the last completed period. Nothing repaints. A level is hidden when its period is shorter than the chart timeframe, for example there are no daily levels on a weekly chart.

Settings
• Levels: switch each of the ten levels on or off.
• Lines: fixed distance (default 90 bars) or full width, line style, line width.
• Labels: text size (8 / 10 / 12), short or full names, optional price in brackets, label position, line cut behind the label, overlap avoidance.
• Colors: yOpen, mOpen, wOpen, dOpen, previous highs, previous lows.

Notes
• Day, week, month and year boundaries follow the symbol's own session and time zone (00:00 UTC on most crypto exchanges), so values differ between instruments, for example spot vs perpetual.
• The levels are reference prices, not trade signals or financial advice. The script has no alerts.
• Free and open source (Mozilla Public License 2.0).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("[ad] Opens & Previous Day H/L", shorttitle = "[ad] Opens", overlay = true, max_lines_count = 50, max_labels_count = 50, max_bars_back = 5000)

// Yearly / Monthly / Weekly / Daily Open and the previous Day / Week / Month High and Low.
// Every level starts on the candle where its period opened (or where the previous period began)
// and is drawn as a thin line with a short text label sitting in the middle of the line.
// Levels that share a price (for example dOpen and wOpen on Monday) are merged into one label.
//
// Prices come from request.security() with the lookahead_on + [1] pattern, so only values that are
// already known are used: period opens are known at the start of the period, previous highs and
// lows come from the last completed period. Nothing repaints.
// Line starts are bar indexes of the chart: the bar where each period began (bar 0 when the period
// began before the first loaded candle). TradingView refuses drawings placed too far from the current
// bar, so a line never starts more than MAX_LINE_BARS_BACK bars before the last candle. Lines also never
// start on the very first bars of the loaded history: the chart preview of a publication does not draw a line
// that begins exactly on the first loaded bar.

string GROUP_LEVELS = "Levels"
string GROUP_LINES = "Lines"
string GROUP_LABELS = "Labels"
string GROUP_COLORS = "Colors"

string END_FULL = "Full width"
string END_FIXED = "Fixed distance"
string POS_NEAR = "Next to last candle"
string POS_FIXED = "Fixed offset"

bool showYoInput = input.bool(true, "Yearly Open (yOpen)", group = GROUP_LEVELS)
bool showMoInput = input.bool(true, "Monthly Open (mOpen)", group = GROUP_LEVELS)
bool showWoInput = input.bool(true, "Weekly Open (wOpen)", group = GROUP_LEVELS)
bool showDoInput = input.bool(true, "Daily Open (dOpen)", group = GROUP_LEVELS)
bool showPdhInput = input.bool(true, "Previous Day High (PDH)", group = GROUP_LEVELS)
bool showPdlInput = input.bool(true, "Previous Day Low (PDL)", group = GROUP_LEVELS)
bool showPwhInput = input.bool(false, "Previous Week High (PWH)", group = GROUP_LEVELS)
bool showPwlInput = input.bool(false, "Previous Week Low (PWL)", group = GROUP_LEVELS)
bool showPmhInput = input.bool(false, "Previous Month High (PMH)", group = GROUP_LEVELS)
bool showPmlInput = input.bool(false, "Previous Month Low (PML)", group = GROUP_LEVELS)

string lineEndInput = input.string(END_FIXED, "Line end", options = [END_FULL, END_FIXED], tooltip = "Full width: the line runs from its start to the right edge of the chart. Fixed distance: the line stops a set number of bars after the last candle.", group = GROUP_LINES)
int distanceInput = input.int(90, "Fixed distance (bars)", minval = 1, maxval = 450, tooltip = "Used only with Fixed distance. The label is placed in the middle of the part of the line that sticks out past the last candle.", group = GROUP_LINES)
string lineStyleInput = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = GROUP_LINES)
int lineWidthInput = input.int(1, "Line width", minval = 1, maxval = 4, group = GROUP_LINES)

bool showLabelsInput = input.bool(true, "Show labels", group = GROUP_LABELS)
string labelSizeInput = input.string("Medium", "Text size", options = ["Small", "Medium", "Large"], tooltip = "Small = 8, Medium = 10, Large = 12.", group = GROUP_LABELS)
bool shortNamesInput = input.bool(true, "Short names", tooltip = "yOpen, mOpen, wOpen, dOpen, PDH, PDL ... instead of Yearly Open, Monthly Open, Weekly Open, Daily Open, Prev Day High, Prev Day Low ...", group = GROUP_LABELS)
bool showPriceInput = input.bool(false, "Show price in label", tooltip = "Adds the price in brackets, for example yOpen (87643.3).", group = GROUP_LABELS)
bool cutLineInput = input.bool(true, "Cut the line behind the label", tooltip = "Fills the label with the chart background so the text looks like it sits inside the line.", group = GROUP_LABELS)
bool avoidOverlapInput = input.bool(true, "Avoid overlapping labels", tooltip = "Moves the labels of nearby levels apart horizontally so they do not cover each other. The spacing follows your zoom level.", group = GROUP_LABELS)
string labelPositionInput = input.string(POS_NEAR, "Label position", options = [POS_NEAR, POS_FIXED], tooltip = "Next to last candle: labels sit just right of the last candle, so they are always on screen. Fixed offset: labels sit a set number of bars right of the last candle; it needs a right margin of at least that many bars.", group = GROUP_LABELS)
int labelOffsetInput = input.int(60, "Label offset (bars right of last candle)", minval = 1, maxval = 450, tooltip = "Used with Full width and the Fixed offset position. Increase it to move the labels towards the right edge, decrease it if they fall outside your screen.", group = GROUP_LABELS)

color yoColorInput = input.color(color.rgb(231, 31, 101), "Yearly Open", group = GROUP_COLORS)
color moColorInput = input.color(color.rgb(231, 31, 101), "Monthly Open", group = GROUP_COLORS)
color woColorInput = input.color(color.rgb(231, 31, 101), "Weekly Open", group = GROUP_COLORS)
color doColorInput = input.color(color.rgb(120, 123, 134), "Daily Open", group = GROUP_COLORS)
color highColorInput = input.color(color.rgb(239, 83, 80), "Previous highs (PDH / PWH / PMH)", group = GROUP_COLORS)
color lowColorInput = input.color(color.rgb(66, 165, 245), "Previous lows (PDL / PWL / PML)", group = GROUP_COLORS)

int LEVEL_COUNT = 10
int NEAR_OFFSET_BARS = 5
float LABEL_GAP_RATIO = 0.04
float STAGGER_RATIO = 0.06
int MIN_STAGGER_BARS = 8
int MAX_LINE_BARS_BACK = 4900
int MIN_LINE_START_BAR = 3

// Open of the current period and high / low of the last completed period. Only values that are
// already final are requested.
[dOpen, dHigh1, dLow1] = request.security(syminfo.tickerid, "D", [open, high[1], low[1]], lookahead = barmerge.lookahead_on)
[wOpen, wHigh1, wLow1] = request.security(syminfo.tickerid, "W", [open, high[1], low[1]], lookahead = barmerge.lookahead_on)
[mOpen, mHigh1, mLow1] = request.security(syminfo.tickerid, "M", [open, high[1], low[1]], lookahead = barmerge.lookahead_on)
[yOpen, yHigh1, yLow1] = request.security(syminfo.tickerid, "12M", [open, high[1], low[1]], lookahead = barmerge.lookahead_on)

// A level is hidden when its period is shorter than the chart timeframe (no daily open on a weekly chart).
int chartSeconds = timeframe.in_seconds()
bool dailyOk = timeframe.in_seconds("D") >= chartSeconds
bool weeklyOk = timeframe.in_seconds("W") >= chartSeconds
bool monthlyOk = timeframe.in_seconds("M") >= chartSeconds
bool yearlyOk = timeframe.in_seconds("12M") >= chartSeconds

// Order matters: when two levels share a price, the earlier one owns the merged label.
float yoLevel = showYoInput and yearlyOk ? yOpen : na
float moLevel = showMoInput and monthlyOk ? mOpen : na
float woLevel = showWoInput and weeklyOk ? wOpen : na
float doLevel = showDoInput and dailyOk ? dOpen : na
float pdhLevel = showPdhInput and dailyOk ? dHigh1 : na
float pdlLevel = showPdlInput and dailyOk ? dLow1 : na
float pwhLevel = showPwhInput and weeklyOk ? wHigh1 : na
float pwlLevel = showPwlInput and weeklyOk ? wLow1 : na
float pmhLevel = showPmhInput and monthlyOk ? mHigh1 : na
float pmlLevel = showPmlInput and monthlyOk ? mLow1 : na

// Bar index where the current and the previous period of each timeframe began.
var int yIdx = 0
var int yPrevIdx = 0
var int mIdx = 0
var int mPrevIdx = 0
var int wIdx = 0
var int wPrevIdx = 0
var int dIdx = 0
var int dPrevIdx = 0
if timeframe.change("12M")
    yPrevIdx := yIdx
    yIdx := bar_index
if timeframe.change("M")
    mPrevIdx := mIdx
    mIdx := bar_index
if timeframe.change("W")
    wPrevIdx := wIdx
    wIdx := bar_index
if timeframe.change("D")
    dPrevIdx := dIdx
    dIdx := bar_index

var array<line> levelLines = array.new<line>(LEVEL_COUNT)
var array<label> levelLabels = array.new<label>(LEVEL_COUNT)

lineStyleOf(string name) =>
    name == "Dashed" ? line.style_dashed : name == "Dotted" ? line.style_dotted : line.style_solid

if barstate.islast
    array<float> prices = array.from(yoLevel, moLevel, woLevel, doLevel, pdhLevel, pdlLevel, pwhLevel, pwlLevel, pmhLevel, pmlLevel)
    array<int> origins = array.from(yIdx, mIdx, wIdx, dIdx, dPrevIdx, dPrevIdx, wPrevIdx, wPrevIdx, mPrevIdx, mPrevIdx)
    array<color> colors = array.from(yoColorInput, moColorInput, woColorInput, doColorInput, highColorInput, lowColorInput, highColorInput, lowColorInput, highColorInput, lowColorInput)
    array<string> names = shortNamesInput ? array.from("yOpen", "mOpen", "wOpen", "dOpen", "PDH", "PDL", "PWH", "PWL", "PMH", "PML") : array.from("Yearly Open", "Monthly Open", "Weekly Open", "Daily Open", "Prev Day High", "Prev Day Low", "Prev Week High", "Prev Week Low", "Prev Month High", "Prev Month Low")

    bool fullWidth = lineEndInput == END_FULL
    int endIndex = bar_index + (fullWidth ? 1 : distanceInput)
    int baseOffset = not fullWidth ? math.max(1, int(math.round(distanceInput / 2.0))) : labelPositionInput == POS_NEAR ? NEAR_OFFSET_BARS : labelOffsetInput
    int labelPx = labelSizeInput == "Small" ? 8 : labelSizeInput == "Large" ? 12 : 10
    color labelBg = cutLineInput ? chart.bg_color : color.new(chart.bg_color, 100)
    string lineStyle = lineStyleOf(lineStyleInput)

    // Merge labels of levels that share a price.
    array<int> owners = array.new<int>(LEVEL_COUNT, -1)
    array<string> texts = array.new<string>(LEVEL_COUNT, "")
    for index = 0 to LEVEL_COUNT - 1
        float price = array.get(prices, index)
        if not na(price)
            int owner = index
            if index > 0
                for earlier = 0 to index - 1
                    float earlierPrice = array.get(prices, earlier)
                    if not na(earlierPrice) and math.abs(price - earlierPrice) < syminfo.mintick
                        owner := array.get(owners, earlier)
                        break
            array.set(owners, index, owner)
            string current = array.get(texts, owner)
            string name = array.get(names, index)
            array.set(texts, owner, current == "" ? name : current + " / " + name)

    // Keep the labels of nearby levels apart. A label is about 4% of the visible price range tall, so
    // levels closer than that get their labels shifted by 6% of the visible bars per step: to the right
    // with Full width, alternately right and left of the middle with Fixed distance.
    array<int> slots = array.new<int>(LEVEL_COUNT, 0)
    int stepBars = MIN_STAGGER_BARS
    if avoidOverlapInput
        float visibleHigh = high
        float visibleLow = low
        int visibleBars = 1
        for back = 0 to math.min(bar_index, 4999)
            if time[back] < chart.left_visible_bar_time
                break
            visibleHigh := math.max(visibleHigh, high[back])
            visibleLow := math.min(visibleLow, low[back])
            visibleBars := back + 1
        float labelGap = (visibleHigh - visibleLow) * LABEL_GAP_RATIO
        stepBars := math.max(MIN_STAGGER_BARS, int(math.round(visibleBars * STAGGER_RATIO)))

        array<int> order = array.new<int>()
        for index = 0 to LEVEL_COUNT - 1
            if array.get(owners, index) == index
                array.push(order, index)
        if array.size(order) > 1
            for outer = 1 to array.size(order) - 1
                int key = array.get(order, outer)
                float keyPrice = array.get(prices, key)
                int inner = outer - 1
                while inner >= 0 and array.get(prices, array.get(order, inner)) > keyPrice
                    array.set(order, inner + 1, array.get(order, inner))
                    inner -= 1
                array.set(order, inner + 1, key)
            float previousPrice = na
            int previousSlot = 0
            for position = 0 to array.size(order) - 1
                int owner = array.get(order, position)
                float ownerPrice = array.get(prices, owner)
                int slot = not na(previousPrice) and ownerPrice - previousPrice < labelGap ? previousSlot + 1 : 0
                array.set(slots, owner, slot)
                previousSlot := slot
                previousPrice := ownerPrice

    for index = 0 to LEVEL_COUNT - 1
        float price = array.get(prices, index)
        line currentLine = array.get(levelLines, index)
        label currentLabel = array.get(levelLabels, index)
        if na(price)
            if not na(currentLine)
                line.delete(currentLine)
                array.set(levelLines, index, na)
            if not na(currentLabel)
                label.delete(currentLabel)
                array.set(levelLabels, index, na)
        else
            color levelColor = array.get(colors, index)
            int startIndex = math.max(array.get(origins, index), bar_index - MAX_LINE_BARS_BACK, MIN_LINE_START_BAR)
            int lastIndex = math.max(endIndex, startIndex + 1)
            if na(currentLine)
                currentLine := line.new(startIndex, price, lastIndex, price, xloc = xloc.bar_index, extend = fullWidth ? extend.right : extend.none, color = levelColor, style = lineStyle, width = lineWidthInput)
                array.set(levelLines, index, currentLine)
            else
                line.set_xy1(currentLine, startIndex, price)
                line.set_xy2(currentLine, lastIndex, price)
                line.set_extend(currentLine, fullWidth ? extend.right : extend.none)
                line.set_color(currentLine, levelColor)
                line.set_style(currentLine, lineStyle)
                line.set_width(currentLine, lineWidthInput)

            bool ownsLabel = showLabelsInput and array.get(owners, index) == index
            if ownsLabel
                int slot = array.get(slots, index)
                int shift = fullWidth ? slot : (slot % 2 == 1 ? (slot + 1) / 2 : -(slot / 2))
                int labelOffset = baseOffset + int(shift) * stepBars
                if not fullWidth
                    labelOffset := math.max(2, math.min(distanceInput - 2, labelOffset))
                int labelX = bar_index + labelOffset
                string labelText = array.get(texts, index) + (showPriceInput ? " (" + str.tostring(price, format.mintick) + ")" : "")
                if na(currentLabel)
                    currentLabel := label.new(labelX, price, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = labelBg, textcolor = levelColor, size = labelPx, textalign = text.align_center)
                    array.set(levelLabels, index, currentLabel)
                else
                    label.set_xy(currentLabel, labelX, price)
                    label.set_text(currentLabel, labelText)
                    label.set_color(currentLabel, labelBg)
                    label.set_textcolor(currentLabel, levelColor)
                    label.set_size(currentLabel, labelPx)
            else if not na(currentLabel)
                label.delete(currentLabel)
                array.set(levelLabels, index, na)

// Values for the Data Window only; they never touch the price scale.
plot(yoLevel, "Yearly Open", color = yoColorInput, display = display.data_window)
plot(moLevel, "Monthly Open", color = moColorInput, display = display.data_window)
plot(woLevel, "Weekly Open", color = woColorInput, display = display.data_window)
plot(doLevel, "Daily Open", color = doColorInput, display = display.data_window)
plot(pdhLevel, "Previous Day High", color = highColorInput, display = display.data_window)
plot(pdlLevel, "Previous Day Low", color = lowColorInput, display = display.data_window)
plot(pwhLevel, "Previous Week High", color = highColorInput, display = display.data_window)
plot(pwlLevel, "Previous Week Low", color = lowColorInput, display = display.data_window)
plot(pmhLevel, "Previous Month High", color = highColorInput, display = display.data_window)
plot(pmlLevel, "Previous Month Low", color = lowColorInput, display = display.data_window)
````
