# 15 Min FVG CE Entry Model

- url: https://www.tradingview.com/script/fqUOH9Ae-15-Min-FVG-CE-Entry-Model/
- type: indicator
- pine_id: PUB;9bd8ca091aeb4eedab87db353e356dc4
- version: 4.0

## Description

Filters 15m FVGs down to only actionable CE setups.

- Must validate within 2 candles
- Invalidated on early weakness or adverse move past CE
- If CE is tapped, remains active until stop (>X) or target (≥Y)

Active = in play
Gray = invalid or complete

## Source Code

````pine
//@version=6
indicator("15 Min FVG CE Entry Model", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//====================================================
// Inputs
//====================================================
only15m             = input.bool(true, "Only run on 15m chart")
forwardBars         = input.int(7, "Show each FVG forward bars from middle candle", minval=1, maxval=100)
maxVisibleFvgs      = input.int(10, "How many most recent FVGs to keep", minval=1, maxval=50)
showCeLabel         = input.bool(true, "Show CE label")
labelOffsetTicks    = input.int(8, "CE label offset above line (ticks)", minval=1, maxval=100)

useEntryTimeFilter  = input.bool(false, "Use personal entry window for rule logic")
entrySessionInput   = input.session("1000-1600", "Personal entry window")
entryTz             = input.string("America/New_York", "Entry timezone")

sweepLookback       = input.int(5, "Rule 7: prior candles swept", minval=1)
minRejectWickPts    = input.float(20.0, "Rule 7: min rejection wick points", minval=0)
minRejectAwayPts    = input.float(15.0, "Rule 9: min close away from opposite FVG", minval=0)
ceInvalidationPts   = input.float(20.0, "Invalidate if price goes this many points past CE", minval=0)
targetPtsFromCe     = input.float(40.0, "Gray after this many points in trade direction once CE is tapped", minval=0)

// Visual customization
activeFvgColor      = input.color(color.teal, "Active FVG Color")
activeFvgOpacity    = input.int(75, "Active FVG Opacity", minval=0, maxval=100)
inactiveFvgColor    = input.color(color.gray, "Inactive FVG Color")
inactiveFvgOpacity  = input.int(75, "Inactive FVG Opacity", minval=0, maxval=100)
ceLineInputColor    = input.color(color.black, "CE Line Color")
boxBorderInputColor = input.color(color.black, "Box Border Color")
labelBgInputColor   = input.color(color.black, "CE Label Background")
labelTextInputColor = input.color(color.white, "CE Label Text")

//====================================================
// Guardrail
//====================================================
is15m = timeframe.in_seconds() == 15 * 60
if only15m and not is15m
    runtime.error("Use this indicator on a 15-minute chart.")

//====================================================
// Time filter for rule logic only
//====================================================
inEntryWindow = not na(time(timeframe.period, entrySessionInput, entryTz))
ruleLogicAllowed = not useEntryTimeFilter or inEntryWindow

//====================================================
// Visuals
//====================================================
validFill      = color.new(activeFvgColor, activeFvgOpacity)
grayFill       = color.new(inactiveFvgColor, inactiveFvgOpacity)
boxBorder      = color.new(boxBorderInputColor, 0)
ceLineColor    = ceLineInputColor
labelBgColor   = color.new(labelBgInputColor, 0)
labelTextColor = labelTextInputColor
labelOffset    = syminfo.mintick * labelOffsetTicks

//====================================================
// Helpers
//====================================================
roundToQuarter(price) =>
    math.round(price * 4.0) / 4.0

ceLabelText(price) =>
    "CE " + str.tostring(roundToQuarter(price))

//====================================================
// Alert flag
//====================================================
var bool newActiveSetupAlert = false
newActiveSetupAlert := false

//====================================================
// Raw FVG definitions
// Bullish FVG: low > high[2]  => zone [high[2], low]
// Bearish FVG: high < low[2] => zone [high, low[2]]
// IMPORTANT: only form after the candle is fully closed
//====================================================
newBullFvg = barstate.isconfirmed and bar_index >= 2 and low > high[2]
newBearFvg = barstate.isconfirmed and bar_index >= 2 and high < low[2]

//====================================================
// Rule 7 rejection wick
//====================================================
candleRange = high - low
bodyHigh    = math.max(open, close)
bodyLow     = math.min(open, close)
upperWick   = high - bodyHigh
lowerWick   = bodyLow - low

sweepsPriorHighs = high > ta.highest(high[1], sweepLookback)
sweepsPriorLows  = low < ta.lowest(low[1], sweepLookback)

upperDominant = candleRange > 0 and upperWick > candleRange * 0.5
lowerDominant = candleRange > 0 and lowerWick > candleRange * 0.5

bearishRejectWick = sweepsPriorHighs and upperDominant and upperWick >= minRejectWickPts
bullishRejectWick = sweepsPriorLows and lowerDominant and lowerWick >= minRejectWickPts

//====================================================
// Historical opposite-FVG memory for Rule 9
// Bullish FVG inversed if close < its bottom
// Bearish FVG inversed if close > its top
//====================================================
var bullHistLow      = array.new_float()
var bullHistHigh     = array.new_float()
var bullHistInversed = array.new_bool()

var bearHistLow      = array.new_float()
var bearHistHigh     = array.new_float()
var bearHistInversed = array.new_bool()

//====================================================
// FVG arrays
// dir:   1 = bull, -1 = bear
// state: 1 = active, 0 = inactive
//====================================================
var fvgDir         = array.new_int()
var fvgState       = array.new_int()
var fvgLow         = array.new_float()
var fvgHigh        = array.new_float()
var fvgCe          = array.new_float()
var fvgCreatedBar  = array.new_int()
var fvgStartBar    = array.new_int()
var fvgEndBar      = array.new_int()
var fvgTappedZone  = array.new_bool()
var fvgTappedCe    = array.new_bool()
var fvgBox         = array.new_box()
var fvgLine        = array.new_line()
var fvgLabel       = array.new_label()

//====================================================
// Add new bullish FVG
//====================================================
if newBullFvg
    bullLow  = high[2]
    bullHigh = low
    bullCe   = (bullLow + bullHigh) / 2.0
    startBar = bar_index - 1
    endBar   = startBar + forwardBars

    array.push(bullHistLow, bullLow)
    array.push(bullHistHigh, bullHigh)
    array.push(bullHistInversed, false)

    initialState = bearishRejectWick ? 0 : 1
    initialFill  = bearishRejectWick ? grayFill : validFill

    box newBox = box.new(left=startBar, top=bullHigh, right=endBar, bottom=bullLow, xloc=xloc.bar_index, border_color=boxBorder, bgcolor=initialFill)
    line newLine = line.new(x1=startBar, y1=bullCe, x2=endBar, y2=bullCe, xloc=xloc.bar_index, color=ceLineColor, style=line.style_dotted, width=2)
    label newLabel = na

    if showCeLabel
        newLabel := label.new(x=endBar, y=bullCe + labelOffset, text=ceLabelText(bullCe), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=labelTextColor, color=labelBgColor)

    array.push(fvgDir, 1)
    array.push(fvgState, initialState)
    array.push(fvgLow, bullLow)
    array.push(fvgHigh, bullHigh)
    array.push(fvgCe, bullCe)
    array.push(fvgCreatedBar, bar_index)
    array.push(fvgStartBar, startBar)
    array.push(fvgEndBar, endBar)
    array.push(fvgTappedZone, false)
    array.push(fvgTappedCe, false)
    array.push(fvgBox, newBox)
    array.push(fvgLine, newLine)
    array.push(fvgLabel, newLabel)

    if initialState == 1
        newActiveSetupAlert := true

//====================================================
// Add new bearish FVG
//====================================================
if newBearFvg
    bearLow  = high
    bearHigh = low[2]
    bearCe   = (bearLow + bearHigh) / 2.0
    startBar = bar_index - 1
    endBar   = startBar + forwardBars

    array.push(bearHistLow, bearLow)
    array.push(bearHistHigh, bearHigh)
    array.push(bearHistInversed, false)

    initialState = bullishRejectWick ? 0 : 1
    initialFill  = bullishRejectWick ? grayFill : validFill

    box newBox = box.new(left=startBar, top=bearHigh, right=endBar, bottom=bearLow, xloc=xloc.bar_index, border_color=boxBorder, bgcolor=initialFill)
    line newLine = line.new(x1=startBar, y1=bearCe, x2=endBar, y2=bearCe, xloc=xloc.bar_index, color=ceLineColor, style=line.style_dotted, width=2)
    label newLabel = na

    if showCeLabel
        newLabel := label.new(x=endBar, y=bearCe + labelOffset, text=ceLabelText(bearCe), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=labelTextColor, color=labelBgColor)

    array.push(fvgDir, -1)
    array.push(fvgState, initialState)
    array.push(fvgLow, bearLow)
    array.push(fvgHigh, bearHigh)
    array.push(fvgCe, bearCe)
    array.push(fvgCreatedBar, bar_index)
    array.push(fvgStartBar, startBar)
    array.push(fvgEndBar, endBar)
    array.push(fvgTappedZone, false)
    array.push(fvgTappedCe, false)
    array.push(fvgBox, newBox)
    array.push(fvgLine, newLine)
    array.push(fvgLabel, newLabel)

    if initialState == 1
        newActiveSetupAlert := true

//====================================================
// Update inversion status of historical FVGs
//====================================================
bullHistCount = array.size(bullHistLow)
if bullHistCount > 0
    for i = 0 to bullHistCount - 1
        if not array.get(bullHistInversed, i)
            histLow = array.get(bullHistLow, i)
            if close < histLow
                array.set(bullHistInversed, i, true)

bearHistCount = array.size(bearHistLow)
if bearHistCount > 0
    for i = 0 to bearHistCount - 1
        if not array.get(bearHistInversed, i)
            histHigh = array.get(bearHistHigh, i)
            if close > histHigh
                array.set(bearHistInversed, i, true)

//====================================================
// Process FVG states
//====================================================
fvgCount = array.size(fvgDir)
if fvgCount > 0
    for idx = 0 to fvgCount - 1
        state_i      = array.get(fvgState, idx)
        dir_i        = array.get(fvgDir, idx)
        low_i        = array.get(fvgLow, idx)
        high_i       = array.get(fvgHigh, idx)
        ce_i         = array.get(fvgCe, idx)
        created_i    = array.get(fvgCreatedBar, idx)
        box_i        = array.get(fvgBox, idx)

        if state_i == 1
            afterCreation = bar_index > created_i
            withinWindow  = afterCreation and bar_index <= created_i + 2
            postWindow    = bar_index > created_i + 2

            zoneTouchedNow = afterCreation and low <= high_i and high >= low_i
            ceTouchedNow   = afterCreation and low <= ce_i and high >= ce_i

            tappedZonePrev = array.get(fvgTappedZone, idx)
            tappedCePrev   = array.get(fvgTappedCe, idx)

            tappedZoneNow = tappedZonePrev or zoneTouchedNow
            tappedCeNow   = tappedCePrev or ceTouchedNow

            array.set(fvgTappedZone, idx, tappedZoneNow)
            array.set(fvgTappedCe, idx, tappedCeNow)

            rule8Invalidate = ruleLogicAllowed and bar_index == created_i + 2 and not tappedZoneNow

            closeInsideWithoutCeInvalidate = ruleLogicAllowed and withinWindow and not tappedCeNow and close > low_i and close < high_i

            ceBreachInvalidate = ruleLogicAllowed and afterCreation and (
                 (dir_i == 1 and low < ce_i - ceInvalidationPts) or
                 (dir_i == -1 and high > ce_i + ceInvalidationPts)
            )

            rule7Invalidate = ruleLogicAllowed and withinWindow and (
                 (dir_i == 1 and bearishRejectWick) or
                 (dir_i == -1 and bullishRejectWick)
            )

            rule9Invalidate = false
            if ruleLogicAllowed and withinWindow
                if dir_i == 1 and bearHistCount > 0
                    for j = 0 to bearHistCount - 1
                        if not array.get(bearHistInversed, j)
                            oppLow     = array.get(bearHistLow, j)
                            oppHigh    = array.get(bearHistHigh, j)
                            tappedOpp  = low <= oppHigh and high >= oppLow
                            closedAway = close <= oppLow - minRejectAwayPts
                            if tappedOpp and closedAway
                                rule9Invalidate := true
                if dir_i == -1 and bullHistCount > 0
                    for j = 0 to bullHistCount - 1
                        if not array.get(bullHistInversed, j)
                            oppLow     = array.get(bullHistLow, j)
                            oppHigh    = array.get(bullHistHigh, j)
                            tappedOpp  = low <= oppHigh and high >= oppLow
                            closedAway = close >= oppHigh + minRejectAwayPts
                            if tappedOpp and closedAway
                                rule9Invalidate := true

            targetReached = afterCreation and tappedCeNow and (
                 (dir_i == 1 and high >= ce_i + targetPtsFromCe) or
                 (dir_i == -1 and low <= ce_i - targetPtsFromCe)
            )

            untappedWindowExpired = postWindow and not tappedCeNow

            shouldGray = rule7Invalidate or rule8Invalidate or rule9Invalidate or closeInsideWithoutCeInvalidate or ceBreachInvalidate or targetReached or untappedWindowExpired

            if shouldGray
                array.set(fvgState, idx, 0)
                box.set_bgcolor(box_i, grayFill)

//====================================================
// Keep only the most recent N total FVGs
//====================================================
while array.size(fvgDir) > maxVisibleFvgs
    oldBox   = array.shift(fvgBox)
    oldLine  = array.shift(fvgLine)
    oldLabel = array.shift(fvgLabel)

    if not na(oldBox)
        box.delete(oldBox)
    if not na(oldLine)
        line.delete(oldLine)
    if not na(oldLabel)
        label.delete(oldLabel)

    array.shift(fvgDir)
    array.shift(fvgState)
    array.shift(fvgLow)
    array.shift(fvgHigh)
    array.shift(fvgCe)
    array.shift(fvgCreatedBar)
    array.shift(fvgStartBar)
    array.shift(fvgEndBar)
    array.shift(fvgTappedZone)
    array.shift(fvgTappedCe)

//====================================================
// Alert condition
//====================================================
alertcondition(
     newActiveSetupAlert,
     title = "New Active FVG Setup",
     message = "15 Min FVG CE Entry Model: New active setup formed. Check chart and place limit at CE."
)
````
