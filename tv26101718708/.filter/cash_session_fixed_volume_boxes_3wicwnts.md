# Cash Session Fixed Volume Boxes

- url: https://www.tradingview.com/script/3wIcWnts-Cash-Session-Fixed-Volume-Boxes/
- type: indicator
- pine_id: PUB;d0ab974a612e4d36ac79711726a5aeb5
- version: 1.0

## Description

Cash Session Fixed Volume Boxes
Cash Session Fixed Volume Boxes
Cash Session Fixed Volume Boxes
Cash Session Fixed Volume Boxes
Cash Session Fixed Volume Boxes
Cash Session Fixed Volume Boxes

## Source Code

````pine
//@version=6
indicator("Cash Session Fixed Volume Boxes", overlay=true, max_boxes_count=500, max_labels_count=500)

//────────────────────────────────────
// Inputs
//────────────────────────────────────
volTarget       = input.float(100000, "Contracts Per Box", minval=1)
cashSession     = input.session("0930-1600", "Cash Session")
showLabels      = input.bool(true, "Show Box Labels")
boxTransparency = input.int(85, "Box Transparency", minval=0, maxval=100)

bullColor    = input.color(color.green, "Bullish Box Color")
bearColor    = input.color(color.red, "Bearish Box Color")
neutralColor = input.color(color.gray, "Neutral Box Color")

//────────────────────────────────────
// Session Detection
//────────────────────────────────────
inSession  = not na(time(timeframe.period, cashSession))
newSession = inSession and not inSession[1]

//────────────────────────────────────
// Variables
//────────────────────────────────────
var float blockVol = 0.0
var float blockHigh = na
var float blockLow = na
var float blockOpen = na
var int blockStartIndex = na
var int boxCount = 0

//────────────────────────────────────
// Reset at cash session open
//────────────────────────────────────
if newSession
    blockVol := 0.0
    blockHigh := high
    blockLow := low
    blockOpen := open
    blockStartIndex := bar_index
    boxCount := 0

//────────────────────────────────────
// Build volume boxes during session
//────────────────────────────────────
if inSession
    if na(blockStartIndex)
        blockVol := 0.0
        blockHigh := high
        blockLow := low
        blockOpen := open
        blockStartIndex := bar_index

    blockVol += volume
    blockHigh := math.max(blockHigh, high)
    blockLow := math.min(blockLow, low)

    if blockVol >= volTarget
        boxCount += 1

        boxColor = close > blockOpen ? bullColor : close < blockOpen ? bearColor : neutralColor

        box.new(left=blockStartIndex, top=blockHigh, right=bar_index, bottom=blockLow, bgcolor=color.new(boxColor, boxTransparency), border_color=color.new(boxColor, 0))

        if showLabels
            label.new(x=bar_index, y=blockHigh, text="#" + str.tostring(boxCount) + "\n" + str.tostring(math.round(blockVol)) + " vol", style=label.style_label_down, textcolor=color.white, color=color.new(boxColor, 0), size=size.tiny)

        blockVol := 0.0
        blockHigh := high
        blockLow := low
        blockOpen := open
        blockStartIndex := bar_index

//────────────────────────────────────
// Reset outside session
//────────────────────────────────────
if not inSession
    blockStartIndex := na
    blockVol := 0.0
    blockHigh := na
    blockLow := na
    blockOpen := na
````
