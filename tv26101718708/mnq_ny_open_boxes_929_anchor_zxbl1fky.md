# MNQ NY Open Boxes (9:29 Anchor)

- url: https://www.tradingview.com/script/ZxBl1FkY-MNQ-NY-Open-Boxes-9-29-Anchor/
- type: indicator
- pine_id: PUB;6e3da559de6b4b1bb331b1902ae93b7b
- version: 1.0

## Description

Stockmen. A opening trade indicator showing tp and SL for shorts or longs

## Source Code

````pine
//@version=6
indicator("MNQ NY Open Boxes (9:29 Anchor)", overlay=true, max_boxes_count=20, max_lines_count=20, max_labels_count=20)

// Inputs
showOpenLine = input.bool(true, "Show Open Line")
showLabels   = input.bool(true, "Show Labels")
extendBars   = input.int(500, "Box Extension (Bars)", minval=50)

// MNQ settings
tickSize   = 0.25
greenTicks = 400
redTicks   = 200

greenRange = greenTicks * tickSize   // 100 points
redRange   = redTicks * tickSize     // 50 points

// NY time detection
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

isAnchorBar = nyHour == 9 and nyMinute == 29

// Persistent objects
var float anchorPrice = na
var int anchorBar = na

var box greenUpBox = na
var box greenDownBox = na
var box redUpBox = na
var box redDownBox = na
var line openLine = na

var label lbl400Up = na
var label lbl400Down = na
var label lbl200Up = na
var label lbl200Down = na
var label lblOpen = na

// Create at 9:29
if isAnchorBar
    anchorPrice := open
    anchorBar := bar_index
    rightEdge = anchorBar + extendBars

    // Delete old
    if not na(greenUpBox)
        box.delete(greenUpBox)
    if not na(greenDownBox)
        box.delete(greenDownBox)
    if not na(redUpBox)
        box.delete(redUpBox)
    if not na(redDownBox)
        box.delete(redDownBox)
    if not na(openLine)
        line.delete(openLine)

    if not na(lbl400Up)
        label.delete(lbl400Up)
    if not na(lbl400Down)
        label.delete(lbl400Down)
    if not na(lbl200Up)
        label.delete(lbl200Up)
    if not na(lbl200Down)
        label.delete(lbl200Down)
    if not na(lblOpen)
        label.delete(lblOpen)

    // 400T up
    greenUpBox := box.new(
        left = anchorBar,
        right = rightEdge,
        top = anchorPrice + greenRange,
        bottom = anchorPrice,
        border_color = color.green,
        bgcolor = color.new(color.green, 88)
    )

    // 400T down
    greenDownBox := box.new(
        left = anchorBar,
        right = rightEdge,
        top = anchorPrice,
        bottom = anchorPrice - greenRange,
        border_color = color.green,
        bgcolor = color.new(color.green, 88)
    )

    // 200T up
    redUpBox := box.new(
        left = anchorBar,
        right = rightEdge,
        top = anchorPrice + redRange,
        bottom = anchorPrice,
        border_color = color.red,
        bgcolor = color.new(color.red, 85)
    )

    // 200T down
    redDownBox := box.new(
        left = anchorBar,
        right = rightEdge,
        top = anchorPrice,
        bottom = anchorPrice - redRange,
        border_color = color.red,
        bgcolor = color.new(color.red, 85)
    )

    // Line
    if showOpenLine
        openLine := line.new(
            x1 = anchorBar,
            y1 = anchorPrice,
            x2 = rightEdge,
            y2 = anchorPrice,
            color = color.white,
            width = 2,
            style = line.style_dashed
        )

    // Labels
    if showLabels
        lbl400Up := label.new(anchorBar + extendBars, anchorPrice + greenRange, "+400T", style=label.style_label_left, color=color.green, textcolor=color.white)
        lbl400Down := label.new(anchorBar + extendBars, anchorPrice - greenRange, "-400T", style=label.style_label_left, color=color.green, textcolor=color.white)
        lbl200Up := label.new(anchorBar + extendBars, anchorPrice + redRange, "+200T", style=label.style_label_left, color=color.red, textcolor=color.white)
        lbl200Down := label.new(anchorBar + extendBars, anchorPrice - redRange, "-200T", style=label.style_label_left, color=color.red, textcolor=color.white)
        lblOpen := label.new(anchorBar + extendBars, anchorPrice, "9:29 Anchor", style=label.style_label_left, color=color.white, textcolor=color.black)
````
