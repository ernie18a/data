# ZigZag UZZ / LZZ Body Levels

- url: https://www.tradingview.com/script/nlArotTH-ZigZag-UZZ-LZZ-Body-Levels/
- type: indicator
- pine_id: PUB;599450eea00c4e1db36c5dbc6d5354c9
- version: 1.0

## Description

This strategy identifies short-term exhaustion patterns (3-candle ZigZag structure) and trades the breakout of key body levels.

It focuses on:

* Market hesitation / reversal attempts
* Body-based structure (not wick noise)
* Immediate continuation or rejection after pattern

## Source Code

````pine
//@version=5
indicator("ZigZag UZZ / LZZ Body Levels", overlay=true, max_labels_count=500, max_lines_count=500)

// ===== SETTINGS =====
offsetPoints = input.float(0.5, "Offset", step=0.1)

uzzLineColor = input.color(color.blue, "UZZ Line Color")
lzzLineColor = input.color(color.purple, "LZZ Line Color")

ddPlusColor = input.color(color.aqua, "+DD Color")
ddMinusColor = input.color(color.red, "-DD Color")

mainLineStyleInput = input.string("Solid", "UZZ/LZZ Line Style", options=["Solid", "Dotted", "Dashed"])
mainLineStyle =
     mainLineStyleInput == "Dotted" ? line.style_dotted :
     mainLineStyleInput == "Dashed" ? line.style_dashed :
     line.style_solid

lineWidth = input.int(2, "Main Line Width", minval=1, maxval=5)

bodyLineColor = input.color(color.white, "Body Line Color")
bodyLineStyleInput = input.string("Solid", "Body Line Style", options=["Solid", "Dotted", "Dashed"])
bodyLineWidth = input.int(1, "Body Line Width", minval=1, maxval=3)

bodyLineStyle =
     bodyLineStyleInput == "Dotted" ? line.style_dotted :
     bodyLineStyleInput == "Dashed" ? line.style_dashed :
     line.style_solid

labelBgColor = input.color(color.yellow, "Price Label Background")
labelTextColor = input.color(color.black, "Price Label Text")
priceLabelShapeInput = input.string("Label Left", "Price Label Shape", options=["Label Left", "Circle", "Diamond", "Square"])

priceLabelStyle =
     priceLabelShapeInput == "Circle" ? label.style_circle :
     priceLabelShapeInput == "Diamond" ? label.style_diamond :
     priceLabelShapeInput == "Square" ? label.style_square :
     label.style_label_left

labelOffsetBars = input.int(8, "Price Label Right Offset Bars", minval=1)
lineLeftBars = input.int(300, "Line Left Length (bars)", minval=10)
lineRightBars = input.int(300, "Line Right Length (bars)", minval=10)

// ===== SESSION SETTINGS =====
useTimeFilter = input.bool(true, "Use Time Filter")

useS1 = input.bool(true, "Session 1 ON")
s1StartH = input.int(7, "S1 Start Hour")
s1StartM = input.int(0, "S1 Start Minute")
s1EndH   = input.int(10, "S1 End Hour")
s1EndM   = input.int(0, "S1 End Minute")

useS2 = input.bool(true, "Session 2 ON")
s2StartH = input.int(15, "S2 Start Hour")
s2StartM = input.int(0, "S2 Start Minute")
s2EndH   = input.int(19, "S2 End Hour")
s2EndM   = input.int(0, "S2 End Minute")

useS3 = input.bool(true, "Session 3 ON")
s3StartH = input.int(23, "S3 Start Hour")
s3StartM = input.int(0, "S3 Start Minute")
s3EndH   = input.int(0, "S3 End Hour")
s3EndM   = input.int(0, "S3 End Minute")

// ===== TIME LOGIC =====
curH = hour(time, "GMT+8")
curM = minute(time, "GMT+8")
curTotal = curH * 60 + curM

f_inSession(startH, startM, endH, endM) =>
    startT = startH * 60 + startM
    endT   = endH * 60 + endM
    startT <= endT ? (curTotal >= startT and curTotal <= endT) : (curTotal >= startT or curTotal <= endT)

sessionAllowed =
     (useS1 and f_inSession(s1StartH, s1StartM, s1EndH, s1EndM)) or
     (useS2 and f_inSession(s2StartH, s2StartM, s2EndH, s2EndM)) or
     (useS3 and f_inSession(s3StartH, s3StartM, s3EndH, s3EndM))

timeAllowed = useTimeFilter ? sessionAllowed : true

// ===== BODY LOGIC =====
isGreen(offset) => close[offset] > open[offset]
isRed(offset)   => close[offset] < open[offset]

bodyHigh(offset) => math.max(open[offset], close[offset])
bodyLow(offset)  => math.min(open[offset], close[offset])

// ===== PATTERNS =====
uzzRaw = timeAllowed and isGreen(2) and isRed(1) and isRed(0)
lzzRaw = timeAllowed and isRed(2) and isGreen(1) and isGreen(0)

uzzPattern = barstate.isconfirmed and uzzRaw
lzzPattern = barstate.isconfirmed and lzzRaw

// ===== VARIABLES =====
var line activeLine = na
var line bodyLine = na
var label priceLabel = na
var float activePrice = na
var string activeType = ""
var int activeCreatedBar = na
var bool activeTriggered = false

// ===== CREATE +DD =====
if uzzPattern
    bodyPrice = math.max(bodyHigh(2), math.max(bodyHigh(1), bodyHigh(0)))
    activePrice := bodyPrice + offsetPoints
    activeType := "UZZ"
    activeCreatedBar := bar_index
    activeTriggered := false

    if not na(activeLine)
        line.delete(activeLine)
    if not na(bodyLine)
        line.delete(bodyLine)
    if not na(priceLabel)
        label.delete(priceLabel)

    bodyLine := line.new(bar_index - lineLeftBars, bodyPrice, bar_index + lineRightBars, bodyPrice,
         xloc=xloc.bar_index, color=bodyLineColor, width=bodyLineWidth, style=bodyLineStyle, force_overlay=true)

    activeLine := line.new(bar_index - lineLeftBars, activePrice, bar_index + lineRightBars, activePrice,
         xloc=xloc.bar_index, color=uzzLineColor, width=lineWidth, style=mainLineStyle, force_overlay=true)

    priceLabel := label.new(bar_index + labelOffsetBars, activePrice, str.tostring(activePrice, format.mintick),
         xloc=xloc.bar_index, yloc=yloc.price, style=priceLabelStyle,
         color=labelBgColor, textcolor=labelTextColor, force_overlay=true)

    label.new(bar_index, high + (syminfo.mintick * 80), "+DD",
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_none, textcolor=ddPlusColor, force_overlay=true)

// ===== CREATE -DD =====
if lzzPattern
    bodyPrice = math.min(bodyLow(2), math.min(bodyLow(1), bodyLow(0)))
    activePrice := bodyPrice - offsetPoints
    activeType := "LZZ"
    activeCreatedBar := bar_index
    activeTriggered := false

    if not na(activeLine)
        line.delete(activeLine)
    if not na(bodyLine)
        line.delete(bodyLine)
    if not na(priceLabel)
        label.delete(priceLabel)

    bodyLine := line.new(bar_index - lineLeftBars, bodyPrice, bar_index + lineRightBars, bodyPrice,
         xloc=xloc.bar_index, color=bodyLineColor, width=bodyLineWidth, style=bodyLineStyle, force_overlay=true)

    activeLine := line.new(bar_index - lineLeftBars, activePrice, bar_index + lineRightBars, activePrice,
         xloc=xloc.bar_index, color=lzzLineColor, width=lineWidth, style=mainLineStyle, force_overlay=true)

    priceLabel := label.new(bar_index + labelOffsetBars, activePrice, str.tostring(activePrice, format.mintick),
         xloc=xloc.bar_index, yloc=yloc.price, style=priceLabelStyle,
         color=labelBgColor, textcolor=labelTextColor, force_overlay=true)

    label.new(bar_index, low - (syminfo.mintick * 80), "-DD",
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_none, textcolor=ddMinusColor, force_overlay=true)

// ===== Z+ / Z- =====
canTrigger = timeAllowed and not activeTriggered and not na(activePrice) and not na(activeCreatedBar) and bar_index > activeCreatedBar

zPlus  = canTrigger and activeType == "UZZ" and high >= activePrice
zMinus = canTrigger and activeType == "LZZ" and low <= activePrice

if zPlus
    label.new(bar_index, high, "Z+",
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_down,
         color=color.green, textcolor=color.white,
         force_overlay=true)
    activeTriggered := true

if zMinus
    label.new(bar_index, low, "Z-",
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_up,
         color=color.red, textcolor=color.white,
         force_overlay=true)
    activeTriggered := true

// ===== MOVE PRICE LABEL =====
if timeAllowed and not na(priceLabel)
    label.set_x(priceLabel, bar_index + labelOffsetBars)
    label.set_y(priceLabel, activePrice)

// ===== CLEAN =====
if not timeAllowed
    if not na(activeLine)
        line.delete(activeLine)
        activeLine := na
    if not na(bodyLine)
        line.delete(bodyLine)
        bodyLine := na
    if not na(priceLabel)
        label.delete(priceLabel)
        priceLabel := na

    activePrice := na
    activeType := ""
    activeCreatedBar := na
    activeTriggered := false

// ===== ALERTS =====
alertcondition(uzzRaw, title="+DD", message="+DD formed")
alertcondition(lzzRaw, title="-DD", message="-DD formed")
alertcondition(zPlus, title="Z+", message="Z+ triggered")
alertcondition(zMinus, title="Z-", message="Z- triggered")
````
