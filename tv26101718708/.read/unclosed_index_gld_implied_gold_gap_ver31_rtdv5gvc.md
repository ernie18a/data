# Unclosed Index - GLD Implied Gold Gap Ver.3.1

- url: https://www.tradingview.com/script/rTdv5GVC/
- type: indicator
- pine_id: PUB;408aff50113b426888a8d35a47faccbc
- version: 1.0

## Description

[b]Unclosed Index – GLD Implied Gold Gaps[/b]

[b]Visualize GLD price gaps as projected zones on XAUUSD.[/b]

This indicator identifies daily price gaps in SPDR Gold Shares (GLD) and projects them onto the XAUUSD chart using a dynamic price ratio between GLD and gold.

Instead of displaying GLD’s original price levels—which are not directly comparable to XAUUSD—the indicator converts each gap into an implied gold price zone. This makes it easier to monitor how GLD’s unfilled gaps correspond to price action in the gold market.

[b]Key Features[/b]

[b]GLD Gap Detection: [/b]Detects daily gaps between the previous session’s close and the current session’s open.
[b]XAUUSD Price Projection: [/b]Converts GLD gap levels into approximate XAUUSD price zones using a dynamic ratio.
[b]Gap Status Tracking: [/b]Displays whether a gap is unfilled, being filled, or fully filled.
[b]Recent Gap History: [/b]Shows a configurable number of recent GLD gaps.
C[b]ustomizable Display: [/b]Adjust gap colors, transparency, labels, boundaries, and midlines to suit your chart.

[b]How to Use[/b]

Apply the indicator to an intraday XAUUSD chart. When a new GLD session begins, the indicator detects the daily gap and projects its corresponding zone onto the gold chart.

The projected zones can be used as an additional reference for market context, potential areas of interest, and gap-fill behavior.

[b]Important Notes[/b]

This indicator is designed as a [b]market context and visualization tool[/b], not as a standalone trading signal.

GLD and XAUUSD are different instruments with different trading sessions, market structures, and pricing characteristics. The projected levels are approximate and should not be interpreted as exact price equivalence or guaranteed support and resistance.

Always use your own analysis and risk management when making trading decisions.

## Source Code

````pine

 //@version=6
indicator("Unclosed Index - GLD Implied Gold Gap Ver.3.1", overlay=true, max_boxes_count=100, max_labels_count=100, max_lines_count=100)

//====================================================
// 1. INPUTS
//====================================================

gldSymbol = input.symbol("AMEX:GLD", "GLD Symbol")

lookbackDays = input.int(5, "Display Last N GLD Sessions", minval=1, maxval=20)
minGapPct = input.float(0.05, "Minimum GLD Gap (%)", minval=0.0, step=0.01)

showOpen = input.bool(true, "Show Unentered Gaps")
showPartial = input.bool(true, "Show Partially Filled Gaps")
showClosed = input.bool(true, "Show Fully Filled Gaps")

showLabels = input.bool(true, "Show Gap Information")
showMidline = input.bool(true, "Show 50% Midline")
showBoundaries = input.bool(true, "Show Gap Boundary Lines")

openColor = input.color(color.orange, "Unentered Gap")
partialColor = input.color(color.blue, "Partially Filled Gap")
closedColor = input.color(color.teal, "Fully Filled Gap")

openTransparency = input.int(78, "Unentered Transparency", minval=0, maxval=100)
partialTransparency = input.int(78, "Partial Transparency", minval=0, maxval=100)
closedTransparency = input.int(88, "Closed Transparency", minval=0, maxval=100)

//====================================================
// 2. GLD DAILY DATA
//====================================================

[gldDailyOpen, gldPreviousClose] = request.security(
    gldSymbol,
    "D",
    [open, close[1]],
    gaps=barmerge.gaps_off,
    lookahead=barmerge.lookahead_on
)

//====================================================
// 3. GLD INTRADAY DATA
//====================================================

[gldIntradayOpen, gldIntradayTime] = request.security(
    gldSymbol,
    timeframe.period,
    [open, time],
    gaps=barmerge.gaps_on,
    lookahead=barmerge.lookahead_off
)

// Detect first available GLD bar after a session gap.
bool newGldSession = not na(gldIntradayTime) and na(gldIntradayTime[1])

//====================================================
// 4. STORAGE
//====================================================

// State:
// 0 = Unentered
// 1 = Partially Filled
// 2 = Fully Filled

var box[] gapBoxes = array.new_box()
var line[] gapMidLines = array.new_line()
var line[] gapTopLines = array.new_line()
var line[] gapBottomLines = array.new_line()
var label[] gapLabels = array.new_label()

var float[] gapTops = array.new_float()
var float[] gapBottoms = array.new_float()
var float[] gapPercents = array.new_float()
var float[] gapRatios = array.new_float()

var bool[] gapIsUp = array.new_bool()
var int[] gapStates = array.new_int()
var int[] gapStartBars = array.new_int()
var int[] gapBornSessions = array.new_int()

var int sessionIndex = 0

//====================================================
// 5. SESSION COUNTER
//====================================================

if newGldSession
    sessionIndex += 1

//====================================================
// 6. REMOVE EXPIRED GAPS
//====================================================

int pruneIndex = array.size(gapBoxes) - 1

while pruneIndex >= 0
    int bornSession = array.get(gapBornSessions, pruneIndex)
    bool expired = sessionIndex - bornSession >= lookbackDays

    if expired
        box.delete(array.get(gapBoxes, pruneIndex))
        line.delete(array.get(gapMidLines, pruneIndex))
        line.delete(array.get(gapTopLines, pruneIndex))
        line.delete(array.get(gapBottomLines, pruneIndex))
        label.delete(array.get(gapLabels, pruneIndex))

        array.remove(gapBoxes, pruneIndex)
        array.remove(gapMidLines, pruneIndex)
        array.remove(gapTopLines, pruneIndex)
        array.remove(gapBottomLines, pruneIndex)
        array.remove(gapLabels, pruneIndex)

        array.remove(gapTops, pruneIndex)
        array.remove(gapBottoms, pruneIndex)
        array.remove(gapPercents, pruneIndex)
        array.remove(gapRatios, pruneIndex)

        array.remove(gapIsUp, pruneIndex)
        array.remove(gapStates, pruneIndex)
        array.remove(gapStartBars, pruneIndex)
        array.remove(gapBornSessions, pruneIndex)

    pruneIndex -= 1

//====================================================
// 7. DETECT GLD GAP AND CONVERT TO XAUUSD
//====================================================

if newGldSession and not na(gldDailyOpen) and not na(gldPreviousClose) and not na(gldIntradayOpen) and gldIntradayOpen > 0

    // Dynamic conversion ratio using the first common session bar.
    float conversionRatio = open / gldIntradayOpen

    // Convert GLD prices into implied XAUUSD prices.
    float impliedGldOpen = gldDailyOpen * conversionRatio
    float impliedPreviousClose = gldPreviousClose * conversionRatio

    // GLD gap percentage.
    float gldGapPct = (gldDailyOpen - gldPreviousClose) / gldPreviousClose * 100.0

    // Implied XAUUSD gap boundaries.
    float gapTop = math.max(impliedGldOpen, impliedPreviousClose)
    float gapBottom = math.min(impliedGldOpen, impliedPreviousClose)

    float gapMid = (gapTop + gapBottom) / 2.0
    float gapWidth = gapTop - gapBottom

    bool gapUp = gldGapPct > 0

    if math.abs(gldGapPct) >= minGapPct and gapWidth > 0

        // Initial state.
        int initialState = 0

        color initialColor = openColor

        box newBox = box.new(
            left=bar_index,
            top=gapTop,
            right=bar_index,
            bottom=gapBottom,
            xloc=xloc.bar_index,
            extend=extend.none,
            bgcolor=color.new(initialColor, openTransparency),
            border_color=initialColor,
            border_width=1
        )

        line newMidLine = line.new(
            x1=bar_index,
            y1=gapMid,
            x2=bar_index,
            y2=gapMid,
            xloc=xloc.bar_index,
            color=showMidline ? initialColor : color.new(initialColor, 100),
            style=line.style_dashed,
            width=1
        )

        line newTopLine = line.new(
            x1=bar_index,
            y1=gapTop,
            x2=bar_index,
            y2=gapTop,
            xloc=xloc.bar_index,
            color=showBoundaries ? initialColor : color.new(initialColor, 100),
            width=1
        )

        line newBottomLine = line.new(
            x1=bar_index,
            y1=gapBottom,
            x2=bar_index,
            y2=gapBottom,
            xloc=xloc.bar_index,
            color=showBoundaries ? initialColor : color.new(initialColor, 100),
            width=1
        )

        string directionText = "DOWN GAP"

        if gapUp
            directionText := "UP GAP"

        string labelText = "GLD " + directionText + "\nGap: " + str.tostring(gldGapPct, "#.###") + "%" + "\nXAU Width: " + str.tostring(gapWidth, format.mintick) + "\nXAU Zone: " + str.tostring(gapBottom, format.mintick) + " - " + str.tostring(gapTop, format.mintick) + "\nRatio: " + str.tostring(conversionRatio, "#.#####") + "\nUNENTERED"

        label newLabel = label.new(
            x=bar_index,
            y=gapMid,
            text=labelText,
            xloc=xloc.bar_index,
            style=label.style_label_left,
            color=color.new(initialColor, 10),
            textcolor=color.white,
            size=size.small
        )

        array.push(gapBoxes, newBox)
        array.push(gapMidLines, newMidLine)
        array.push(gapTopLines, newTopLine)
        array.push(gapBottomLines, newBottomLine)
        array.push(gapLabels, newLabel)

        array.push(gapTops, gapTop)
        array.push(gapBottoms, gapBottom)
        array.push(gapPercents, gldGapPct)
        array.push(gapRatios, conversionRatio)

        array.push(gapIsUp, gapUp)
        array.push(gapStates, initialState)
        array.push(gapStartBars, bar_index)
        array.push(gapBornSessions, sessionIndex)

//====================================================
// 8. UPDATE GAP STATES AND VISUALS
//====================================================

int gapCount = array.size(gapBoxes)

if gapCount > 0
    for i = 0 to gapCount - 1

        box currentBox = array.get(gapBoxes, i)
        line currentMid = array.get(gapMidLines, i)
        line currentTop = array.get(gapTopLines, i)
        line currentBottom = array.get(gapBottomLines, i)
        label currentLabel = array.get(gapLabels, i)

        float top = array.get(gapTops, i)
        float bottom = array.get(gapBottoms, i)
        float gapPct = array.get(gapPercents, i)
        float ratio = array.get(gapRatios, i)

        float mid = (top + bottom) / 2.0

        bool isUp = array.get(gapIsUp, i)

        int state = array.get(gapStates, i)
        int startBar = array.get(gapStartBars, i)

        if state < 2 and bar_index > startBar

            bool fullyFilled = false

            if isUp
                fullyFilled := low <= bottom
            else
                fullyFilled := high >= top

            bool enteredGap = high >= bottom and low <= top

            if fullyFilled
                state := 2
            else if enteredGap and state == 0
                state := 1

            array.set(gapStates, i, state)

        // Determine state color.
        color stateColor = openColor

        if state == 1
            stateColor := partialColor
        else if state == 2
            stateColor := closedColor

        // Determine transparency.
        int stateTransparency = openTransparency

        if state == 1
            stateTransparency := partialTransparency
        else if state == 2
            stateTransparency := closedTransparency

        // Determine visibility.
        bool visible = showOpen

        if state == 1
            visible := showPartial
        else if state == 2
            visible := showClosed

        // Extend active zones.
        if state < 2
            box.set_right(currentBox, bar_index)
            line.set_x2(currentMid, bar_index)
            line.set_x2(currentTop, bar_index)
            line.set_x2(currentBottom, bar_index)

        // Update box.
        box.set_bgcolor(
            currentBox,
            color.new(stateColor, visible ? stateTransparency : 100)
        )

        box.set_border_color(
            currentBox,
            color.new(stateColor, visible ? 0 : 100)
        )

        // Update midpoint.
        line.set_color(
            currentMid,
            color.new(stateColor, visible and showMidline ? 0 : 100)
        )

        // Update upper boundary.
        line.set_color(
            currentTop,
            color.new(stateColor, visible and showBoundaries ? 0 : 100)
        )

        // Update lower boundary.
        line.set_color(
            currentBottom,
            color.new(stateColor, visible and showBoundaries ? 0 : 100)
        )

        // Direction label.
        string directionText = "DOWN GAP"

        if isUp
            directionText := "UP GAP"

        // Status label.
        string statusText = "UNENTERED"

        if state == 1
            statusText := "IN PROGRESS"
        else if state == 2
            statusText := "FULLY FILLED"

        // Build label text.
        string labelText = "GLD " + directionText + "\nGap: " + str.tostring(gapPct, "#.###") + "%" + "\nXAU Width: " + str.tostring(top - bottom, format.mintick) + "\nXAU Zone: " + str.tostring(bottom, format.mintick) + " - " + str.tostring(top, format.mintick) + "\nRatio: " + str.tostring(ratio, "#.#####") + "\n" + statusText

        label.set_text(
            currentLabel,
            showLabels and visible ? labelText : ""
        )

        label.set_color(currentLabel, color.new(stateColor, 10))
        label.set_textcolor(currentLabel, color.white)
        label.set_y(currentLabel, mid)

        if state < 2
            label.set_x(currentLabel, bar_index)
        else
            label.set_x(currentLabel, box.get_right(currentBox))

//====================================================
// 9. GLD SESSION MARKER
//====================================================

plotshape(
    newGldSession,
    title="GLD Session Start",
    style=shape.circle,
    location=location.bottom,
    color=color.new(color.orange, 35),
    size=size.tiny
)

//====================================================
// 10. TIMEFRAME VALIDATION
//====================================================

if not timeframe.isintraday
    runtime.error("Please use an intraday chart, preferably 15-minute or 30-minute.")
````
