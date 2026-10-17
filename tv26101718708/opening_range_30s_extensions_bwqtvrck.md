# Opening Range 30s + Extensions

- url: https://www.tradingview.com/script/bWQtVrCK/
- type: indicator
- pine_id: PUB;486c01681b164f7cb252f2ce191ce330
- version: 1.0

## Description

PAX Group Opening Range Indicator (first 30s of RTH), plus configurable rotations.

## Source Code

````pine
//@version=6
indicator("Opening Range 30s + Extensions", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

stepPts    = input.float(15.0, "Extension Points", minval=0.25)
numLevels  = input.int(5, "Number of Extensions", minval=1, maxval=20)
showBox    = input.bool(true, "Show OR Box")
showLabels = input.bool(true, "Show Labels")

orColor    = input.color(color.gray, "ORH / ORL Color")
upColor    = input.color(color.teal, "Upper Extensions Color")
downColor  = input.color(color.red, "Lower Extensions Color")
boxColor   = input.color(color.new(color.red, 85), "OR Box Color")
invis      = color.rgb(0, 0, 0, 100)

tz = "America/New_York"

var float orh = na
var float orl = na
var bool buildingOR = false
var bool orDone = false

var line[] activeLines = array.new_line()
var label[] activeLabels = array.new_label()
var box activeBox = na

nyYear  = year(time, tz)
nyMonth = month(time, tz)
nyDay   = dayofmonth(time, tz)

todayStart = timestamp(tz, nyYear, nyMonth, nyDay, 9, 30, 0)
todayEnd   = todayStart + 30 * 1000

newDay = ta.change(nyDay) != 0

priceText(x) =>
    str.tostring(x, format.mintick)

if newDay
    orh := na
    orl := na
    buildingOR := false
    orDone := false
    array.clear(activeLines)
    array.clear(activeLabels)
    activeBox := na

barTouchesOR = time < todayEnd and time_close > todayStart
barAfterOR   = time >= todayEnd

if barTouchesOR and not orDone
    if not buildingOR
        orh := high
        orl := low
        buildingOR := true

        array.clear(activeLines)
        array.clear(activeLabels)

        if showBox
            activeBox := box.new(
                 left=bar_index,
                 top=orh,
                 right=bar_index,
                 bottom=orl,
                 bgcolor=boxColor,
                 border_width=0)

    orh := math.max(orh, high)
    orl := math.min(orl, low)

    if showBox and not na(activeBox)
        box.set_top(activeBox, orh)
        box.set_bottom(activeBox, orl)
        box.set_right(activeBox, bar_index)

if buildingOR and not orDone and barAfterOR
    buildingOR := false
    orDone := true

    // ORH / ORL
    array.push(activeLines, line.new(bar_index, orh, bar_index + 1, orh, color=orColor, width=2))
    array.push(activeLines, line.new(bar_index, orl, bar_index + 1, orl, color=orColor, width=2))

    if showLabels
        array.push(activeLabels, label.new(bar_index, orh, "ORH  (" + priceText(orh) + ")", style=label.style_label_left, color=invis, textcolor=orColor, size=size.small))
        array.push(activeLabels, label.new(bar_index, orl, "ORL  (" + priceText(orl) + ")", style=label.style_label_left, color=invis, textcolor=orColor, size=size.small))

    // Extensiones superiores
    for i = 1 to numLevels
        lvlUp = orh + stepPts * i
        array.push(activeLines, line.new(bar_index, lvlUp, bar_index + 1, lvlUp, color=upColor, width=1))

        if showLabels
            txtUp = str.tostring(i) + "   (" + priceText(lvlUp) + ")"
            array.push(activeLabels, label.new(bar_index, lvlUp, txtUp, style=label.style_label_left, color=invis, textcolor=upColor, size=size.small))

    // Extensiones inferiores
    for i = 1 to numLevels
        lvlDn = orl - stepPts * i
        array.push(activeLines, line.new(bar_index, lvlDn, bar_index + 1, lvlDn, color=downColor, width=1))

        if showLabels
            txtDn = str.tostring(i) + "   (" + priceText(lvlDn) + ")"
            array.push(activeLabels, label.new(bar_index, lvlDn, txtDn, style=label.style_label_left, color=invis, textcolor=downColor, size=size.small))

// Extender solo hasta el final del día actual
if orDone and not newDay
    if array.size(activeLines) > 0
        for i = 0 to array.size(activeLines) - 1
            line.set_x2(array.get(activeLines, i), bar_index)

    if showBox and not na(activeBox)
        box.set_right(activeBox, bar_index)

    if array.size(activeLabels) > 0
        for i = 0 to array.size(activeLabels) - 1
            label.set_x(array.get(activeLabels, i), bar_index)
````
