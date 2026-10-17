# Market Structure Swings

- url: https://www.tradingview.com/script/1yJbrZuu-Market-Structure-Swings/
- type: indicator
- pine_id: PUB;34f2f0e5457f434f85977345ed2f1a19
- version: 1.0

## Description

This indicator marks price swings in three levels: regular, intermediate, and major. It helps show which highs and lows are minor turns and which are more important structure points.

## Source Code

````pine
//@version=6
indicator("Swings + Intermediate + Major", shorttitle="Swings", overlay=true, max_bars_back=20, max_labels_count=500)

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
inputRepaint = input.bool(true, "Repaints on Real Time?")

inputShowSH  = input.bool(true, "Show Swing Highs")
inputShowSL  = input.bool(true, "Show Swing Lows")
inputShowISH = input.bool(true, "Show Intermediate Swing Highs")
inputShowISL = input.bool(true, "Show Intermediate Swing Lows")
inputShowMSH = input.bool(true, "Show Major Swing Highs")
inputShowMSL = input.bool(true, "Show Major Swing Lows")

// Swing High style
swingHighText      = input.string("▼", "Swing High Symbol")
swingHighColor     = input.color(color.white, "Swing High Color")
swingHighSizeInput = input.string("small", "Swing High Size", options=["tiny", "small", "normal", "large", "huge"])

// Swing Low style
swingLowText      = input.string("▲", "Swing Low Symbol")
swingLowColor     = input.color(color.white, "Swing Low Color")
swingLowSizeInput = input.string("small", "Swing Low Size", options=["tiny", "small", "normal", "large", "huge"])

// Intermediate High style
interHighText      = input.string("◆", "Intermediate High Symbol")
interHighColor     = input.color(color.blue, "Intermediate High Color")
interHighSizeInput = input.string("large", "Intermediate High Size", options=["tiny", "small", "normal", "large", "huge"])

// Intermediate Low style
interLowText      = input.string("◆", "Intermediate Low Symbol")
interLowColor     = input.color(color.red, "Intermediate Low Color")
interLowSizeInput = input.string("large", "Intermediate Low Size", options=["tiny", "small", "normal", "large", "huge"])

// Major High style
majorHighText      = input.string("◆", "Major High Symbol")
majorHighColor     = input.color(color.yellow, "Major High Color")
majorHighSizeInput = input.string("huge", "Major High Size", options=["tiny", "small", "normal", "large", "huge"])

// Major Low style
majorLowText      = input.string("◆", "Major Low Symbol")
majorLowColor     = input.color(color.orange, "Major Low Color")
majorLowSizeInput = input.string("huge", "Major Low Size", options=["tiny", "small", "normal", "large", "huge"])

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
getLabelSize(sizeName) =>
    switch sizeName
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.huge

isHigherHigh(value1, value2) =>
    value1 >= value2

isLowerLow(value1, value2) =>
    value1 <= value2

swing_highs(currentBar) =>
    currentHigh = high[currentBar]
    isHigherHigh(currentHigh, high[currentBar + 1]) and isHigherHigh(currentHigh, high[currentBar - 1])

swing_lows(currentBar) =>
    currentLow = low[currentBar]
    isLowerLow(currentLow, low[currentBar + 1]) and isLowerLow(currentLow, low[currentBar - 1])

makeHighLabel(_bar, _text, _color, _sizeName) =>
    label.new(
         x=_bar,
         y=na,
         text=_text,
         xloc=xloc.bar_index,
         yloc=yloc.abovebar,
         style=label.style_none,
         textcolor=_color,
         size=getLabelSize(_sizeName)
     )

makeLowLabel(_bar, _text, _color, _sizeName) =>
    label.new(
         x=_bar,
         y=na,
         text=_text,
         xloc=xloc.bar_index,
         yloc=yloc.belowbar,
         style=label.style_none,
         textcolor=_color,
         size=getLabelSize(_sizeName)
     )

// ─────────────────────────────────────────────────────────────
// Swing detection
// ─────────────────────────────────────────────────────────────
rightMargin = inputRepaint ? 2 : 3

isSwingHigh = swing_highs(rightMargin)
isSwingLow  = swing_lows(rightMargin)

// ─────────────────────────────────────────────────────────────
// State: regular swings
// ─────────────────────────────────────────────────────────────
var float prevSwingHigh1 = na
var float prevSwingHigh2 = na
var int   prevSwingHighBar1 = na
var label prevSwingHighLabel1 = na

var float prevSwingLow1 = na
var float prevSwingLow2 = na
var int   prevSwingLowBar1 = na
var label prevSwingLowLabel1 = na

// ─────────────────────────────────────────────────────────────
// State: intermediate swings
// ─────────────────────────────────────────────────────────────
var float prevIntHigh1 = na
var float prevIntHigh2 = na
var int   prevIntHighBar1 = na
var label prevIntHighLabel1 = na

var float prevIntLow1 = na
var float prevIntLow2 = na
var int   prevIntLowBar1 = na
var label prevIntLowLabel1 = na

// ─────────────────────────────────────────────────────────────
// Optional trigger flags for alerts
// ─────────────────────────────────────────────────────────────
newIntermediateHigh = false
newIntermediateLow  = false
newMajorHigh        = false
newMajorLow         = false

// ─────────────────────────────────────────────────────────────
// Process Swing Highs
// ─────────────────────────────────────────────────────────────
if isSwingHigh
    currentSwingHigh = high[rightMargin]
    currentSwingHighBar = bar_index - rightMargin

    isIntermediateHigh = not na(prevSwingHigh1) and not na(prevSwingHigh2) and prevSwingHigh1 > prevSwingHigh2 and prevSwingHigh1 > currentSwingHigh

    if isIntermediateHigh
        newIntermediateHigh := true

        if not na(prevSwingHighLabel1)
            label.delete(prevSwingHighLabel1)

        label createdIntHighLabel = na
        if inputShowISH
            createdIntHighLabel := makeHighLabel(prevSwingHighBar1, interHighText, interHighColor, interHighSizeInput)

        isMajorHigh = not na(prevIntHigh1) and not na(prevIntHigh2) and prevIntHigh1 > prevIntHigh2 and prevIntHigh1 > prevSwingHigh1

        if isMajorHigh
            newMajorHigh := true

            if not na(prevIntHighLabel1)
                label.delete(prevIntHighLabel1)

            if inputShowMSH
                makeHighLabel(prevIntHighBar1, majorHighText, majorHighColor, majorHighSizeInput)

        prevIntHigh2 := prevIntHigh1
        prevIntHigh1 := prevSwingHigh1
        prevIntHighBar1 := prevSwingHighBar1
        prevIntHighLabel1 := createdIntHighLabel

    label currentHighLabel = na
    if inputShowSH
        currentHighLabel := makeHighLabel(currentSwingHighBar, swingHighText, swingHighColor, swingHighSizeInput)

    prevSwingHigh2 := prevSwingHigh1
    prevSwingHigh1 := currentSwingHigh
    prevSwingHighBar1 := currentSwingHighBar
    prevSwingHighLabel1 := currentHighLabel

// ─────────────────────────────────────────────────────────────
// Process Swing Lows
// ─────────────────────────────────────────────────────────────
if isSwingLow
    currentSwingLow = low[rightMargin]
    currentSwingLowBar = bar_index - rightMargin

    isIntermediateLow = not na(prevSwingLow1) and not na(prevSwingLow2) and prevSwingLow1 < prevSwingLow2 and prevSwingLow1 < currentSwingLow

    if isIntermediateLow
        newIntermediateLow := true

        if not na(prevSwingLowLabel1)
            label.delete(prevSwingLowLabel1)

        label createdIntLowLabel = na
        if inputShowISL
            createdIntLowLabel := makeLowLabel(prevSwingLowBar1, interLowText, interLowColor, interLowSizeInput)

        isMajorLow = not na(prevIntLow1) and not na(prevIntLow2) and prevIntLow1 < prevIntLow2 and prevIntLow1 < prevSwingLow1

        if isMajorLow
            newMajorLow := true

            if not na(prevIntLowLabel1)
                label.delete(prevIntLowLabel1)

            if inputShowMSL
                makeLowLabel(prevIntLowBar1, majorLowText, majorLowColor, majorLowSizeInput)

        prevIntLow2 := prevIntLow1
        prevIntLow1 := prevSwingLow1
        prevIntLowBar1 := prevSwingLowBar1
        prevIntLowLabel1 := createdIntLowLabel

    label currentLowLabel = na
    if inputShowSL
        currentLowLabel := makeLowLabel(currentSwingLowBar, swingLowText, swingLowColor, swingLowSizeInput)

    prevSwingLow2 := prevSwingLow1
    prevSwingLow1 := currentSwingLow
    prevSwingLowBar1 := currentSwingLowBar
    prevSwingLowLabel1 := currentLowLabel

// ─────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────
alertcondition(isSwingHigh, "Swing High", "New Swing High")
alertcondition(isSwingLow, "Swing Low", "New Swing Low")
alertcondition(newIntermediateHigh, "Intermediate Swing High", "New Intermediate Swing High")
alertcondition(newIntermediateLow, "Intermediate Swing Low", "New Intermediate Swing Low")
alertcondition(newMajorHigh, "Major Swing High", "New Major Swing High")
alertcondition(newMajorLow, "Major Swing Low", "New Major Swing Low")
````
