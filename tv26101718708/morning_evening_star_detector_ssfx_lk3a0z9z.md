# Morning & Evening Star Detector [SSFX]

- url: https://www.tradingview.com/script/lk3a0Z9z-Morning-Evening-Star-Detector-SSFX/
- type: indicator
- pine_id: PUB;819939f2f3314b46a033338f29ce2b61
- version: 1.0

## Description

Morning & Evening Star Detector [SSFX] is an open-source candlestick pattern indicator designed to identify two classic 3-candle reversal formations: the Morning Star and the Evening Star.

The Morning Star is a bullish reversal pattern that typically appears after bearish pressure. The indicator identifies it using a 3-candle structure:
[list=1]
[*]A strong bearish first candle
[*]A small-bodied middle candle, representing hesitation or loss of momentum
[*]A strong bullish third candle that closes back into the body of the first candle
[/list]
The Evening Star is the opposite bearish reversal pattern. It is detected when the market forms:
[list=1]
[*]A strong bullish first candle
[*]A small-bodied middle candle
[*]A strong bearish third candle that closes back into the body of the first candle
[/list]
To make the patterns easier to read on the chart, the script automatically draws a box around the full 3-candle formation:
[list]
[*]Green box = Morning Star
[*]Red box = Evening Star
[/list]
The box covers the full high-to-low range of the entire pattern, helping traders visually study where the reversal structure formed.

Main features:
[list]
[*]Detects Morning Star bullish reversal patterns
[*]Detects Evening Star bearish reversal patterns
[*]Draws visual boxes around valid 3-candle patterns
[*]Green highlight for Morning Star formations
[*]Red highlight for Evening Star formations
[*]Optional labels for detected patterns
[*]Optional background highlighting
[*]Adjustable candle body percentage filters
[*]Adjustable middle candle size filter
[*]Adjustable third candle close requirement
[*]Optional gap requirement for more traditional pattern detection
[*]Built-in alert conditions for both pattern types
[/list]
The pattern logic is fully customizable. Users can adjust the required body size of the first candle, the maximum body size of the star candle, the minimum body size of the confirmation candle, and how deeply the third candle must close into the first candle’s body.

The optional gap setting is included for traders who prefer a more classical definition of Morning Star and Evening Star patterns. Since many markets such as forex, gold, crypto, and index CFDs often do not produce clean session gaps, the gap requirement can be turned off for more flexible detection.

This indicator is intended for educational and analytical use. It does not predict future price movement and should not be used as a standalone trading system. Morning Star and Evening Star patterns are best interpreted together with market structure, support and resistance, trend context, volume, and proper risk management.

## Source Code

````pine
//@version=6
indicator("Morning & Evening Star Detector [SSFX]", overlay = true, max_labels_count = 500, max_boxes_count = 500)

//====================================================
// INPUTS
//====================================================
groupLogic = "Pattern Logic"

patternFilter = input.string(
     "All Patterns",
     "Show Pattern",
     options = ["All Patterns", "Morning Stars", "Evening Stars"],
     group = groupLogic,
     tooltip = "Choose which candlestick pattern type to display on the chart."
)

minFirstBodyPct = input.float(
     50.0,
     "Minimum First Candle Body %",
     minval = 1,
     maxval = 100,
     step = 1,
     group = groupLogic,
     tooltip = "The first candle must have a body at least this percentage of its full candle range."
)

maxStarBodyPct = input.float(
     35.0,
     "Maximum Star Candle Body %",
     minval = 1,
     maxval = 100,
     step = 1,
     group = groupLogic,
     tooltip = "The middle candle must have a small body. Lower value = stricter star candle."
)

minThirdBodyPct = input.float(
     40.0,
     "Minimum Third Candle Body %",
     minval = 1,
     maxval = 100,
     step = 1,
     group = groupLogic,
     tooltip = "The third candle must have a body at least this percentage of its full candle range."
)

closeIntoFirstPct = input.float(
     50.0,
     "Third Candle Close Into First Candle Body %",
     minval = 1,
     maxval = 100,
     step = 1,
     group = groupLogic,
     tooltip = "For Morning Star, the third candle must close above this percentage of the first candle body. For Evening Star, it must close below this percentage."
)

requireGap = input.bool(
     false,
     "Require Gap Between Candles",
     group = groupLogic,
     tooltip = "Classical star patterns often include gaps. For Forex, Gold, Crypto, and indices, gaps are less common, so this is disabled by default."
)

//====================================================
// VISUAL SETTINGS
//====================================================
groupVisual = "Visual Settings"

showLabels = input.bool(true, "Show Pattern Labels", group = groupVisual)
showBoxes = input.bool(true, "Show Pattern Boxes", group = groupVisual)
showBg = input.bool(false, "Highlight Background", group = groupVisual)

bullColor = input.color(color.lime, "Morning Star Color", group = groupVisual)
bearColor = input.color(color.red, "Evening Star Color", group = groupVisual)

boxTransparency = input.int(
     85,
     "Box Transparency",
     minval = 0,
     maxval = 100,
     group = groupVisual
)

boxBorderWidth = input.int(
     1,
     "Box Border Width",
     minval = 1,
     maxval = 5,
     group = groupVisual
)

keepLastBoxes = input.int(
     100,
     "Keep Last Boxes",
     minval = 1,
     maxval = 500,
     group = groupVisual
)

labelSizeInput = input.string(
     "Small",
     "Label Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = groupVisual
)

//====================================================
// FUNCTIONS
//====================================================
f_range(_h, _l) =>
    math.max(_h - _l, syminfo.mintick)

f_body(_o, _c) =>
    math.abs(_c - _o)

f_bodyPct(_o, _h, _l, _c) =>
    f_body(_o, _c) / f_range(_h, _l) * 100.0

f_labelSize(_size) =>
    switch _size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

//====================================================
// BOX STORAGE
//====================================================
var box[] patternBoxes = array.new_box()

f_addBox(_color) =>
    patternHigh = math.max(high, math.max(high[1], high[2]))
    patternLow  = math.min(low, math.min(low[1], low[2]))

    newBox = box.new(
         left = bar_index - 2,
         top = patternHigh,
         right = bar_index,
         bottom = patternLow,
         xloc = xloc.bar_index,
         border_color = _color,
         border_width = boxBorderWidth,
         bgcolor = color.new(_color, boxTransparency)
    )

    array.push(patternBoxes, newBox)

    if array.size(patternBoxes) > keepLastBoxes
        oldBox = array.shift(patternBoxes)
        box.delete(oldBox)

//====================================================
// BASIC CANDLE DATA
// Candle 1 = [2]
// Candle 2 = [1]
// Candle 3 = current candle
//====================================================
bodyPct1 = f_bodyPct(open[2], high[2], low[2], close[2])
bodyPct2 = f_bodyPct(open[1], high[1], low[1], close[1])
bodyPct3 = f_bodyPct(open, high, low, close)

candle1Bearish = close[2] < open[2]
candle1Bullish = close[2] > open[2]

candle2Small = bodyPct2 <= maxStarBodyPct

candle3Bullish = close > open
candle3Bearish = close < open

strongFirstCandle = bodyPct1 >= minFirstBodyPct
strongThirdCandle = bodyPct3 >= minThirdBodyPct

//====================================================
// MORNING STAR LOGIC
//====================================================
morningCloseLevel = close[2] + ((open[2] - close[2]) * closeIntoFirstPct / 100.0)

morningCloseOk = close >= morningCloseLevel

morningGapOk = not requireGap or (
     math.max(open[1], close[1]) < close[2] and
     open > math.max(open[1], close[1])
)

morningStar =
     candle1Bearish and
     strongFirstCandle and
     candle2Small and
     candle3Bullish and
     strongThirdCandle and
     morningCloseOk and
     morningGapOk

//====================================================
// EVENING STAR LOGIC
//====================================================
eveningCloseLevel = close[2] - ((close[2] - open[2]) * closeIntoFirstPct / 100.0)

eveningCloseOk = close <= eveningCloseLevel

eveningGapOk = not requireGap or (
     math.min(open[1], close[1]) > close[2] and
     open < math.min(open[1], close[1])
)

eveningStar =
     candle1Bullish and
     strongFirstCandle and
     candle2Small and
     candle3Bearish and
     strongThirdCandle and
     eveningCloseOk and
     eveningGapOk

//====================================================
// PATTERN DISPLAY FILTER
//====================================================
showMorningPattern = patternFilter == "All Patterns" or patternFilter == "Morning Stars"
showEveningPattern = patternFilter == "All Patterns" or patternFilter == "Evening Stars"

morningStarShown = morningStar and showMorningPattern
eveningStarShown = eveningStar and showEveningPattern

//====================================================
// VISUALS
//====================================================
if showBoxes and morningStarShown
    f_addBox(bullColor)

if showBoxes and eveningStarShown
    f_addBox(bearColor)

if showLabels and morningStarShown
    label.new(
         bar_index,
         low,
         "Morning Star",
         style = label.style_label_up,
         color = bullColor,
         textcolor = color.white,
         size = f_labelSize(labelSizeInput)
    )

if showLabels and eveningStarShown
    label.new(
         bar_index,
         high,
         "Evening Star",
         style = label.style_label_down,
         color = bearColor,
         textcolor = color.white,
         size = f_labelSize(labelSizeInput)
    )

bgcolor(showBg and morningStarShown ? color.new(bullColor, 85) : na)
bgcolor(showBg and eveningStarShown ? color.new(bearColor, 85) : na)

//====================================================
// ALERTS
//====================================================
alertcondition(
     morningStarShown,
     title = "Morning Star Detected",
     message = "Morning Star pattern detected on {{ticker}} at {{interval}}."
)

alertcondition(
     eveningStarShown,
     title = "Evening Star Detected",
     message = "Evening Star pattern detected on {{ticker}} at {{interval}}."
)
````
