# Engulfing Pattern Detector [SSFX]

- url: https://www.tradingview.com/script/4gOsbSI2-Engulfing-Pattern-Detector-SSFX/
- type: indicator
- pine_id: PUB;b5c7038e222244718f97615ab0985c14
- version: 1.0

## Description

Engulfing Pattern Detector [SSFX] is candlestick analysis indicator designed to detect and highlight bullish and bearish engulfing patterns directly on the price chart.

The indicator focuses on two-candle engulfing formations. A bullish engulfing pattern is identified when the current bullish candle engulfs the previous bearish candle based on the selected engulfing method. A bearish engulfing pattern is identified when the current bearish candle engulfs the previous bullish candle based on the selected engulfing method.

The script provides two engulfing detection modes:
[list=1]
[*]Body Engulfing: This mode checks whether the body of the current candle covers the body of the previous candle.
[*]Full Candle Engulfing: This stricter mode checks whether the current candle also covers the full high-low range of the previous candle, in addition to meeting the body engulfing condition.
[/list]
To reduce weak or unclear signals, the indicator includes a minimum body percentage filter. This allows users to require the current engulfing candle to have a minimum body size relative to its total candle range. This can help avoid candles with very small bodies or excessive wicks.

Key Features:
[list]
[*]Detects bullish engulfing patterns
[*]Detects bearish engulfing patterns
[*]Option to display all patterns or only bullish/bearish patterns
[*]Option to require opposite candle colors
[*]Body engulfing and full candle engulfing modes
[*]Minimum body percentage filter
[*]Box highlight around the two-candle engulfing formation
[*]Optional labels
[*]Optional candle coloring
[*]Optional background highlight
[*]Custom bullish and bearish colors
[*]Alert conditions for bullish, bearish, and any engulfing signal
[/list]
How to Use:
Bullish engulfing patterns may be used as a visual clue that buying pressure is increasing after a prior bearish candle. Bearish engulfing patterns may be used as a visual clue that selling pressure is increasing after a prior bullish candle.

The box highlight is drawn around the full two-candle pattern, making it easier to visually identify where the engulfing structure occurred. Green boxes represent bullish engulfing formations, while red boxes represent bearish engulfing formations.

This indicator is intended to be used as a visual candlestick pattern tool. It does not predict future price movement and should not be used as a standalone trading system. Users may combine the signals with their own market structure, support and resistance, trend, volume, or risk management analysis.

Alerts:
[list]
[*]The script includes alert conditions for:
[*]Bullish Engulfing Detected
[*]Bearish Engulfing Detected
[*]Any Engulfing Pattern Detected
[/list]
These alerts can be used to notify users when a new engulfing pattern appears on the chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SimplySafeFx

//@version=6
indicator("Engulfing Pattern Detector [SSFX]", overlay = true, max_labels_count = 500, max_boxes_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
patternMode = input.string(
     "All Patterns",
     "Pattern Display",
     options = ["All Patterns", "Bullish Engulfing", "Bearish Engulfing"]
)

engulfType = input.string(
     "Full Candle Engulfing",
     "Engulfing Type",
     options = ["Body Engulfing", "Full Candle Engulfing"]
)

requireOppositeColor = input.bool(true, "Require Opposite Candle Color")

minBodyPercent = input.float(
     40.0,
     "Minimum Body % of Current Candle",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0
)

showLabels = input.bool(true, "Show Labels")
showBarColor = input.bool(true, "Color Engulfing Candles")
showBackground = input.bool(false, "Highlight Background")

showBox = input.bool(true, "Highlight Pattern With Box")
boxFillTransparency = input.int(85, "Box Fill Transparency", minval = 0, maxval = 100)
boxBorderWidth = input.int(1, "Box Border Width", minval = 1, maxval = 5)
boxBorderStyleInput = input.string(
     "Solid",
     "Box Border Style",
     options = ["Solid", "Dashed", "Dotted"]
)

bullColor = input.color(color.lime, "Bullish Color")
bearColor = input.color(color.red, "Bearish Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STYLE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
boxBorderStyle =
     boxBorderStyleInput == "Solid"  ? line.style_solid  :
     boxBorderStyleInput == "Dashed" ? line.style_dashed :
     line.style_dotted

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
prevBull = close[1] > open[1]
prevBear = close[1] < open[1]

currBull = close > open
currBear = close < open

currBody = math.abs(close - open)
currRange = high - low
bodyPercent = currRange > 0 ? currBody / currRange * 100 : 0

validBodySize = bodyPercent >= minBodyPercent

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENGULFING LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bodyBullEngulf =
     open <= close[1] and
     close >= open[1]

bodyBearEngulf =
     open >= close[1] and
     close <= open[1]

fullBullEngulf =
     low <= low[1] and
     high >= high[1] and
     bodyBullEngulf

fullBearEngulf =
     high >= high[1] and
     low <= low[1] and
     bodyBearEngulf

bullEngulfBase = engulfType == "Body Engulfing" ? bodyBullEngulf : fullBullEngulf
bearEngulfBase = engulfType == "Body Engulfing" ? bodyBearEngulf : fullBearEngulf

bullColorCondition = requireOppositeColor ? prevBear and currBull : currBull
bearColorCondition = requireOppositeColor ? prevBull and currBear : currBear

bullishEngulfing =
     bullEngulfBase and
     bullColorCondition and
     validBodySize

bearishEngulfing =
     bearEngulfBase and
     bearColorCondition and
     validBodySize

showBull =
     patternMode == "All Patterns" or
     patternMode == "Bullish Engulfing"

showBear =
     patternMode == "All Patterns" or
     patternMode == "Bearish Engulfing"

bullSignal = bullishEngulfing and showBull
bearSignal = bearishEngulfing and showBear

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PATTERN BOX LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
patternTop = math.max(high, high[1])
patternBottom = math.min(low, low[1])

if showBox and bullSignal
    box.new(
         left = bar_index - 1,
         top = patternTop,
         right = bar_index,
         bottom = patternBottom,
         xloc = xloc.bar_index,
         border_color = bullColor,
         border_width = boxBorderWidth,
         border_style = boxBorderStyle,
         bgcolor = color.new(bullColor, boxFillTransparency)
    )

if showBox and bearSignal
    box.new(
         left = bar_index - 1,
         top = patternTop,
         right = bar_index,
         bottom = patternBottom,
         xloc = xloc.bar_index,
         border_color = bearColor,
         border_width = boxBorderWidth,
         border_style = boxBorderStyle,
         bgcolor = color.new(bearColor, boxFillTransparency)
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOT SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     bullSignal,
     title = "Bullish Engulfing",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullColor,
     size = size.small
)

plotshape(
     bearSignal,
     title = "Bearish Engulfing",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearColor,
     size = size.small
)

if showLabels and bullSignal
    label.new(
         bar_index,
         low,
         "Bullish\nEngulfing",
         style = label.style_label_up,
         color = bullColor,
         textcolor = color.white,
         size = size.small
    )

if showLabels and bearSignal
    label.new(
         bar_index,
         high,
         "Bearish\nEngulfing",
         style = label.style_label_down,
         color = bearColor,
         textcolor = color.white,
         size = size.small
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BAR COLOR / BACKGROUND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
barcolor(showBarColor and bullSignal ? bullColor : showBarColor and bearSignal ? bearColor : na)

bgcolor(showBackground and bullSignal ? color.new(bullColor, 85) : na)
bgcolor(showBackground and bearSignal ? color.new(bearColor, 85) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(
     bullSignal,
     title = "Bullish Engulfing Detected",
     message = "Bullish Engulfing detected on {{ticker}} at {{interval}}"
)

alertcondition(
     bearSignal,
     title = "Bearish Engulfing Detected",
     message = "Bearish Engulfing detected on {{ticker}} at {{interval}}"
)

alertcondition(
     bullSignal or bearSignal,
     title = "Any Engulfing Pattern Detected",
     message = "Engulfing candlestick pattern detected on {{ticker}} at {{interval}}"
)
````
