# Traditional Renko Box Overlay

- url: https://www.tradingview.com/script/TZkdEphU/
- type: indicator
- pine_id: PUB;66409ce5983542b8abc08c44cbcbb775
- version: 1.0

## Description

[b]Traditional Renko Box Overlay[/b]

[b]Traditional Renko Box Overlay[/b] is a TradingView indicator that overlays traditional Renko-style boxes directly on a standard time-based chart.

The purpose of this indicator is to visually organize price movement through a fixed box-size structure while keeping the original candlestick chart visible. By combining regular candlesticks with Renko-style price segmentation, it helps make directional movement, price progression, and market structure easier to read.

## Key Features

* Displays Renko-style boxes on the main chart.
* Uses a traditional fixed box-size logic.
* Aligns box boundaries with round-number price levels.
* Uses important zero-based price levels as structural anchors.
* Supports user-defined box sizes.
* Draws a dotted midline inside each box.
* Allows the active box display to be turned on or off.
* Visualizes price structure as a supplementary layer without replacing the original chart.

## Intended Use

This indicator may be useful for traders who want to:

* Organize directional price movement more clearly.
* Reduce visual noise from regular candlesticks and better understand market structure.
* Observe how price behaves above or below important round-number levels.
* Combine time-based chart analysis with Renko-style price-range analysis.
* Use the boxes as a visual aid for support/resistance, trend reading, and price progression.

## Notes

This indicator is not intended to predict future price movement by itself.

It is recommended to use it together with other analytical methods such as price action, market structure, volume, VWAP, and support/resistance analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FX_tankyu

//@version=6
indicator("Traditional Renko Box Overlay", shorttitle="Renko Box Overlay", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=50)

//----------------------------------------------------
// Inputs
//----------------------------------------------------
group_logic = "Logic"
boxPipsInput   = input.float(5.0, "Traditional box size (pips)", minval=0.1, step=0.1, group=group_logic)
sourceMode     = input.string("Close", "Price source for brick update", options=["Close", "High-Low"], group=group_logic)
reversalBricks = input.int(1, "Reversal size (bricks)", minval=1, maxval=10, group=group_logic)
useAutoPip     = input.bool(true, "Auto-detect pip size", group=group_logic)
manualPipSize  = input.float(0.0001, "Manual pip size (used when auto-detect OFF)", minval=0.00000001, step=0.00000001, group=group_logic)

group_style = "Style"
showHistorical     = input.bool(true, "Show historical boxes", group=group_style)
showActiveOnly     = input.bool(false, "Show active box", group=group_style)
showMidline        = input.bool(false, "Show box midline", group=group_style)
fillTransparency   = input.int(82, "Box fill transparency", minval=0, maxval=100, group=group_style)
borderTransparency = input.int(0, "Border transparency", minval=0, maxval=100, group=group_style)
upColor            = input.color(color.teal, "Up box color", group=group_style)
downColor          = input.color(color.red, "Down box color", group=group_style)
activeBorderWidth  = input.int(2, "Active box border width", minval=1, maxval=5, group=group_style)
histBorderWidth    = input.int(1, "Historical box border width", minval=1, maxval=5, group=group_style)

group_perf = "Performance"
maxHistBoxes  = input.int(200, "Maximum historical boxes", minval=10, maxval=450, group=group_perf)
showInfoLabel = input.bool(false, "Show info label", group=group_perf)

//----------------------------------------------------
// Helpers
//----------------------------------------------------
f_detectPipSize() =>
    float pip = syminfo.mintick * 10.0
    if syminfo.type == "forex"
        pip := str.contains(syminfo.ticker, "JPY") ? 0.01 : 0.0001
    else if syminfo.mintick >= 0.01
        pip := syminfo.mintick
    pip

f_top(_a, _b) =>
    math.max(_a, _b)

f_bot(_a, _b) =>
    math.min(_a, _b)

f_mid(_a, _b) =>
    (_a + _b) * 0.5

f_boxColor(_dir) =>
    _dir >= 0 ? upColor : downColor

f_gridPrice(_index, _brickSize) =>
    _index * _brickSize

f_makeBox(_left, _right, _open, _close, _dir, _borderWidth, _fillTransparency, _borderTransparency) =>
    c = f_boxColor(_dir)
    box.new(
         left=_left,
         top=f_top(_open, _close),
         right=_right,
         bottom=f_bot(_open, _close),
         xloc=xloc.bar_index,
         border_color=color.new(c, _borderTransparency),
         border_width=_borderWidth,
         bgcolor=color.new(c, _fillTransparency))

f_makeMidline(_left, _right, _open, _close, _dir) =>
    c = f_boxColor(_dir)
    l = line.new(
         x1=_left,
         y1=f_mid(_open, _close),
         x2=_right,
         y2=f_mid(_open, _close),
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.new(c, 25),
         width=1)
    line.set_style(l, line.style_dotted)
    l

//----------------------------------------------------
// Brick size
//----------------------------------------------------
pipSize   = useAutoPip ? f_detectPipSize() : manualPipSize
brickSize = boxPipsInput * pipSize

//----------------------------------------------------
// State
//----------------------------------------------------
var int   renkoIndex = na
var float renkoClose = na
var int   renkoDir   = 0

// Active brick state (logic)
var bool  activeExists    = false
var int   activeStartBar  = na
var float activeOpenPrice = na
var float activeClosePrice = na
var int   activeDir       = 0

// Active drawings
var box   activeBox = na
var line  activeMid = na

// Historical drawings
var box[] histBoxes = array.new_box()
var line[] histMids = array.new_line()

var label infoLabel = na

//----------------------------------------------------
// Initialization
//----------------------------------------------------
if barstate.isfirst and brickSize > 0
    renkoIndex := int(math.floor(close / brickSize))
    renkoClose := f_gridPrice(renkoIndex, brickSize)
    renkoDir   := 0

//----------------------------------------------------
// Price references
//----------------------------------------------------
float refHigh = sourceMode == "Close" ? close : high
float refLow  = sourceMode == "Close" ? close : low

//----------------------------------------------------
// Trim old historical drawings
//----------------------------------------------------
while array.size(histBoxes) > maxHistBoxes
    oldBox = array.shift(histBoxes)
    if not na(oldBox)
        box.delete(oldBox)

while array.size(histMids) > maxHistBoxes
    oldLine = array.shift(histMids)
    if not na(oldLine)
        line.delete(oldLine)

//----------------------------------------------------
// Renko engine (zero-anchored fixed grid)
//----------------------------------------------------
if brickSize > 0 and not na(renkoIndex)
    int safety = 0
    bool keepProcessing = true

    while keepProcessing and safety < 100
        keepProcessing := false
        safety += 1

        int nextIndex = renkoIndex
        int nextDir   = 0
        bool hasStep  = false

        float upThreshold   = f_gridPrice(renkoIndex + 1, brickSize)
        float downThreshold = f_gridPrice(renkoIndex - 1, brickSize)

        if renkoDir == 0
            bool canUp   = refHigh >= upThreshold
            bool canDown = refLow  <= downThreshold

            if canUp and canDown
                float upExc = refHigh - renkoClose
                float dnExc = renkoClose - refLow
                bool chooseUp = close >= renkoClose ? true : close < renkoClose ? false : upExc >= dnExc
                nextIndex := chooseUp ? (renkoIndex + 1) : (renkoIndex - 1)
                nextDir   := chooseUp ? 1 : -1
                hasStep   := true
            else if canUp
                nextIndex := renkoIndex + 1
                nextDir   := 1
                hasStep   := true
            else if canDown
                nextIndex := renkoIndex - 1
                nextDir   := -1
                hasStep   := true

        else if renkoDir == 1
            bool canContinueUp = refHigh >= upThreshold
            bool canReverseDn  = refLow <= f_gridPrice(renkoIndex - reversalBricks, brickSize)

            if canContinueUp
                nextIndex := renkoIndex + 1
                nextDir   := 1
                hasStep   := true
            else if canReverseDn
                nextIndex := renkoIndex - 1
                nextDir   := -1
                hasStep   := true

        else if renkoDir == -1
            bool canContinueDn = refLow <= downThreshold
            bool canReverseUp  = refHigh >= f_gridPrice(renkoIndex + reversalBricks, brickSize)

            if canContinueDn
                nextIndex := renkoIndex - 1
                nextDir   := -1
                hasStep   := true
            else if canReverseUp
                nextIndex := renkoIndex + 1
                nextDir   := 1
                hasStep   := true

        if hasStep
            float prevClose = renkoClose
            float nextClose = f_gridPrice(nextIndex, brickSize)

            // finalize previous active logical brick into historical drawings
            if activeExists
                if showHistorical
                    histBox = f_makeBox(
                         activeStartBar,
                         bar_index,
                         activeOpenPrice,
                         activeClosePrice,
                         activeDir,
                         histBorderWidth,
                         fillTransparency,
                         borderTransparency)
                    array.push(histBoxes, histBox)

                    if showMidline
                        histMid = f_makeMidline(
                             activeStartBar,
                             bar_index,
                             activeOpenPrice,
                             activeClosePrice,
                             activeDir)
                        array.push(histMids, histMid)

            // remove previous active drawings
            if not na(activeBox)
                box.delete(activeBox)
                activeBox := na

            if not na(activeMid)
                line.delete(activeMid)
                activeMid := na

            // start new active logical brick
            activeExists      := true
            activeStartBar    := bar_index
            activeOpenPrice   := prevClose
            activeClosePrice  := nextClose
            activeDir         := nextDir

            // create new active drawings only when highlight is enabled
            if showActiveOnly
                activeBox := f_makeBox(
                     activeStartBar,
                     bar_index,
                     activeOpenPrice,
                     activeClosePrice,
                     activeDir,
                     activeBorderWidth,
                     fillTransparency,
                     borderTransparency)

                if showMidline
                    activeMid := f_makeMidline(
                         activeStartBar,
                         bar_index,
                         activeOpenPrice,
                         activeClosePrice,
                         activeDir)

            renkoIndex := nextIndex
            renkoClose := nextClose
            renkoDir   := nextDir
            keepProcessing := true

//----------------------------------------------------
// Extend active drawings horizontally
//----------------------------------------------------
if showActiveOnly and activeExists
    if not na(activeBox)
        box.set_right(activeBox, bar_index)
        box.set_top(activeBox, f_top(activeOpenPrice, activeClosePrice))
        box.set_bottom(activeBox, f_bot(activeOpenPrice, activeClosePrice))

    if showMidline and not na(activeMid)
        line.set_x2(activeMid, bar_index)
        line.set_y1(activeMid, f_mid(activeOpenPrice, activeClosePrice))
        line.set_y2(activeMid, f_mid(activeOpenPrice, activeClosePrice))

//----------------------------------------------------
// Active band plots
//----------------------------------------------------
float activeTop = na
float activeBot = na
float activeMidPrice = na

if showActiveOnly and activeExists
    activeTop := f_top(activeOpenPrice, activeClosePrice)
    activeBot := f_bot(activeOpenPrice, activeClosePrice)
    activeMidPrice := f_mid(activeTop, activeBot)

pTop = plot(activeTop, "Active Box Top", color=color.new(renkoDir >= 0 ? upColor : downColor, 0), linewidth=1, style=plot.style_linebr)
pBot = plot(activeBot, "Active Box Bottom", color=color.new(renkoDir >= 0 ? upColor : downColor, 0), linewidth=1, style=plot.style_linebr)
fill(pTop, pBot, color=showActiveOnly and activeExists ? color.new(renkoDir >= 0 ? upColor : downColor, 90) : na, title="Active Box Fill")
plot(showActiveOnly and showMidline ? activeMidPrice : na, "Active Box Midline", color=color.new(renkoDir >= 0 ? upColor : downColor, 35), linewidth=1, style=plot.style_linebr, linestyle = plot.linestyle_dotted)

//----------------------------------------------------
// Info label
//----------------------------------------------------
if showInfoLabel
    if not na(infoLabel)
        label.delete(infoLabel)

    string dirText = renkoDir == 1 ? "UP" : renkoDir == -1 ? "DOWN" : "NEUTRAL"
    string srcText = sourceMode == "Close" ? "Close" : "High-Low"

    string infoText =
         "Traditional Renko Box Overlay\n" +
         "Brick Size: " + str.tostring(boxPipsInput) + " pips\n" +
         "Pip Size: " + str.tostring(pipSize) + "\n" +
         "Brick Size (price): " + str.tostring(brickSize) + "\n" +
         "Grid Anchor: 0.0\n" +
         "Source: " + srcText + "\n" +
         "Reversal: " + str.tostring(reversalBricks) + " brick(s)\n" +
         "Direction: " + dirText + "\n" +
         "Renko Close: " + str.tostring(renkoClose)

    infoLabel := label.new(
         x=bar_index,
         y=high,
         text=infoText,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(color.silver, 75),
         size=size.small)
````
