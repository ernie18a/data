# ATH Line

- url: https://www.tradingview.com/script/2HR3Z8qv-ATH-Line/
- type: indicator
- pine_id: PUB;69be663e8393455292d88c08373920cd
- version: 1.0

## Description

All time highs to mark on your charts. you can customize the colors as well.

## Source Code

````pine
//@version=6
indicator("ATH Line", overlay=true)

// === SETTINGS ===
useRay = input.bool(true, "Use Horizontal Ray (off = full extend line)")
lineColor = input.color(color.white, "Line Color")
textColor = input.color(color.white, "Text Color")

// === ATH ===
var float ath = na
if na(ath) or high > ath
    ath := high

// === LINE ===
var line athLine = na
if barstate.islast
    line.delete(athLine)
    athLine := line.new(
        x1 = bar_index - 500,
        y1 = ath,
        x2 = bar_index,
        y2 = ath,
        extend = useRay ? extend.right : extend.both,
        color = lineColor,
        style = line.style_dotted,
        width = 1
    )

// === LABEL (LOCKED TO RIGHT EDGE) ===
var label athLabel = na
if barstate.islast
    label.delete(athLabel)
    athLabel := label.new(
        x = bar_index,
        y = ath,
        text = "ATH",
        style = label.style_label_right,
        textcolor = textColor,
        color = color.new(color.black, 100),
        size = size.normal
    )
````
