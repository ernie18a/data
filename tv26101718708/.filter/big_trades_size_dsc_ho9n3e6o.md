# Big Trades Size - DSC

- url: https://www.tradingview.com/script/HO9n3E6o-Big-Trades-Size-DSC/
- type: indicator
- pine_id: PUB;38d702349ee04733b9f3603b1eb6378a
- version: 5.0

## Description

Big Trades Size [Dark Stone]

Highlights statistically significant volume events (“big trades”) directly on the chart using clean colored bubbles.

• Green bubbles = buying pressure
• Red bubbles = selling pressure
• Bubble size scales with volume intensity
• Displays exact volume size inside each bubble
• Works on all timeframes (1m → Weekly)

How it works:
The indicator compares current bar volume against a moving average. When volume exceeds a user-defined multiple of the average, a bubble is plotted. Extreme volume events are automatically given larger bubbles for easy identification.

Key Features:
- Adjustable volume threshold
- Extreme volume detection
- Fully customizable colors and transparency
- Label size control
- Max labels limit to keep charts clean
- Works across all timeframes without lower-timeframe data requirements

Settings tips:
- Lower timeframes (1m–5m): Threshold 2.0 – 2.5
- Higher timeframes (1H–Daily): Threshold 1.6 – 2.0
- Raise the threshold if too many bubbles appear

Created by Aaron A at Dark Stone Capital

This indicator is for educational and analytical purposes only. It does not constitute financial advice.

## Source Code

````pine
//@version=6
// Created by Aaron A at Dark Stone Capital | x @stockswithaaron
indicator("Big Trades - DSC", overlay = true, max_labels_count = 500)

// ═══════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════
volLength     = input.int(20, "Volume MA Length", minval = 5)
threshold     = input.float(2.0, "Big Trade Threshold (× Average)", minval = 1.0, step = 0.1)
extremeMult   = input.float(3.5, "Extreme Threshold (× Average)", minval = 1.5, step = 0.1)
showLabels    = input.bool(true, "Show Size Labels")
labelSize     = input.string("small", "Text Size", options = ["tiny", "small", "normal"])
maxLabels     = input.int(150, "Max Labels", minval = 20, maxval = 500)
buyColor      = input.color(#00E676, "Buy Color")
sellColor     = input.color(#FF1744, "Sell Color")
textColor     = input.color(color.white, "Text Color")
transparency  = input.int(25, "Bubble Transparency", minval = 0, maxval = 80)

// ═══════════════════════════════════════
// CALCULATIONS
// ═══════════════════════════════════════
avgVol   = ta.sma(volume, volLength)
volRatio = avgVol > 0 ? volume / avgVol : 0.0
isBig    = volRatio >= threshold
isExtreme = volRatio >= extremeMult
isBuy    = close >= open

// ═══════════════════════════════════════
// VISUALS – bubble + volume number in one label
// ═══════════════════════════════════════
var label[] labs = array.new_label()

// Clean up excess labels
if array.size(labs) > maxLabels
    int excess = array.size(labs) - maxLabels
    for i = 0 to excess - 1
        label.delete(array.shift(labs))

if isBig and showLabels
    string txt = str.tostring(volume, format.volume)
    label lab = label.new(
         bar_index,
         isBuy ? low : high,
         txt,
         xloc = xloc.bar_index,
         yloc = isBuy ? yloc.belowbar : yloc.abovebar,
         style = label.style_circle,
         color = color.new(isBuy ? buyColor : sellColor, transparency),
         textcolor = textColor,
         size = isExtreme ? size.large : size.normal,
         tooltip = "Volume: " + str.tostring(volume) + "\nRatio: " + str.tostring(volRatio, "#.##") + "x avg"
     )
    array.push(labs, lab)
````
