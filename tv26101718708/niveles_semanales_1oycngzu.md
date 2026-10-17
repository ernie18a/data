# Niveles Semanales

- url: https://www.tradingview.com/script/1oYCNGZU/
- type: indicator
- pine_id: PUB;6ce087f07dd2435c9dc2e53fd3a6ee35
- version: 1.0

## Description

Recoge apertura semanal de la cotización y suma un 1% a cada línea.

## Source Code

````pine
//@version=6
indicator("Niveles Semanales ±1%", overlay=true, max_lines_count=500, max_labels_count=500)

//#region Inputs
showAnchorDebug = input.bool(false, "Show anchor debug label")
lineWidth = input.int(1, "Line width", minval=1, maxval=5)
anchorColor = input.color(color.yellow, "0% color")
levelColor = input.color(color.new(color.gray, 30), "Other levels color")
//#endregion

//#region Functions
//@function Formats a percentage level label.
//@param pct Percentage level.
//@returns Formatted percentage text.
formatPercent(pct) =>
    pct > 0 ? "+" + str.tostring(pct) + "%" : str.tostring(pct) + "%"

//@function Formats a price for the level label.
//@param price Price value.
//@returns Formatted price text.
formatPrice(price) =>
    "$" + str.tostring(price, format.mintick)

//@function Deletes all line and label objects in the provided arrays.
//@param lines Array of line objects.
//@param labels Array of label objects.
//@returns None.
clearObjects(array<line> lines, array<label> labels) =>
    for ln in lines
        line.delete(ln)
    for lb in labels
        label.delete(lb)
    lines.clear()
    labels.clear()
//#endregion

//#region State
var float anchorPrice = na
var int anchorBarIndex = na
var array<line> levelLines = array.new<line>()
var array<label> levelLabels = array.new<label>()
var label debugLabel = na
//#endregion

//#region Anchor detection
newMonday = dayofweek == dayofweek.monday and (na(dayofweek[1]) or dayofweek[1] != dayofweek.monday)
if newMonday
    anchorPrice := open
    anchorBarIndex := bar_index

if na(anchorPrice)
    mondayOpenValue = ta.valuewhen(dayofweek == dayofweek.monday and (na(dayofweek[1]) or dayofweek[1] != dayofweek.monday), open, 0)
    mondayOpenIndex = ta.valuewhen(dayofweek == dayofweek.monday and (na(dayofweek[1]) or dayofweek[1] != dayofweek.monday), bar_index, 0)
    anchorPrice := mondayOpenValue
    anchorBarIndex := int(mondayOpenIndex)
//#endregion

//#region Draw levels
if not na(anchorPrice) and not na(anchorBarIndex)
    clearObjects(levelLines, levelLabels)

    for pct = -15 to 15
        levelPrice = anchorPrice * (1 + pct / 100.0)
        isAnchorLevel = pct == 0
        levelCol = isAnchorLevel ? anchorColor : levelColor
        levelText = formatPercent(pct) + " — " + formatPrice(levelPrice)

        ln = line.new(
             anchorBarIndex,
             levelPrice,
             bar_index,
             levelPrice,
             extend=extend.right,
             color=levelCol,
             width=lineWidth,
             style=line.style_solid)
        lb = label.new(
             bar_index,
             levelPrice,
             levelText,
             xloc=xloc.bar_index,
             style=label.style_label_right,
             textcolor=levelCol,
             color=color.new(color.black, 100),
             size=size.small)

        levelLines.push(ln)
        levelLabels.push(lb)

    if showAnchorDebug
        if not na(debugLabel)
            label.delete(debugLabel)
        debugLabel := label.new(
             bar_index,
             anchorPrice,
             "Monday open: " + formatPrice(anchorPrice),
             xloc=xloc.bar_index,
             style=label.style_label_right,
             textcolor=color.white,
             color=color.new(color.blue, 0),
             size=size.small)
    else
        if not na(debugLabel)
            label.delete(debugLabel)
            debugLabel := na
//#endregion
````
