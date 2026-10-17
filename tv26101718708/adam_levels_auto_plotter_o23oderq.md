# Adam Levels Auto Plotter

- url: https://www.tradingview.com/script/O23OdErq-Adam-Levels-Auto-Plotter/
- type: indicator
- pine_id: PUB;0d58c288cff44444a5a90e9980246a6d
- version: 1.0

## Description

Adam Levels Auto Plotter

A clean and customizable support/resistance framework designed for traders who use manually distributed market levels and want a faster workflow inside TradingView.

This script allows you to paste support and resistance levels directly into the settings panel, and the indicator automatically parses and plots them onto the chart.

Features:
• Paste full nightly support/resistance text directly into the indicator
• Automatically detects MAJOR levels using “(major)”
• Supports zone parsing such as 7455-50
• Independent support and resistance styling
• Custom colors for:
  - Supports
  - Resistances
  - MAJOR levels
  - Price labels
  - MAJOR text labels
• Adjustable:
  - Line width
  - Line style (solid / dashed / dotted)
  - Label size
  - Label positioning
• Right-side live price labels
• Optional centered “MAJOR” labels
• Automatic touch alerts for:
  - Any level
  - Support levels
  - Resistance levels
  - MAJOR levels
• TradingView-native scaling and overlay behavior

Example Input:
Supports are: 7520 (major), 7514, 7507 (major), 7455-50 (major)

Resistances are: 7531, 7535 (major), 7542

This indicator was built to streamline discretionary trading workflows and reduce the need to manually draw levels every session.

Best used for:
• ES / MES futures
• Intraday support & resistance trading
• Session reaction levels
• Market profile / structure traders
• Manual level-based trading systems

How To Use:
1. Add indicator to chart
2. Open settings
3. Paste support and resistance text
4. Customize colors/styles if desired
5. Create alerts using TradingView’s alert system

Alert Types:
• Adam Level Touch
• Adam Support Touch
• Adam Resistance Touch
• Adam MAJOR Level Touch

Notes:
• MAJOR levels are automatically identified by the keyword “major”
• Zones are automatically detected using dash notation (example: 7455-50)
• Labels and styles are fully customizable from settings

[b]Important TradingView Scale Setting[/b]

After adding the script to your chart:

1. Click the gear icon on the bottom right of the chart scale area
2. Select “Merge all scales into one”
3. Choose “On the right”

This ensures the Adam Levels align correctly with the main ES price scale and prevents TradingView from creating a separate indicator scale.

Without this setting enabled, the plotted support and resistance levels may appear compressed or visually misaligned from price.

## Source Code

````pine
//@version=6
indicator("Adam Levels Auto Plotter", overlay=true, scale=scale.right, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// INPUTS
supportText = input.text_area("Supports are: 7520 (major), 7514, 7507 (major), 7455-50 (major)", "Support Levels")
resistanceText = input.text_area("Resistances are: 7531, 7535 (major), 7542", "Resistance Levels")

showLabels = input.bool(true, "Show Price Labels")
showMajorLabels = input.bool(true, "Show MAJOR Labels")

labelOffset = input.int(5, "Price Label Offset Bars", minval=1)
majorLabelOffset = input.int(20, "MAJOR Label Offset Bars", minval=1)

priceLabelPosition = input.string("On Line", "Price Label Position", options=["Above", "On Line", "Below"])
priceLabelTickOffset = input.int(4, "Price Label Vertical Offset Ticks", minval=1)

priceLabelTextColor = input.color(color.white, "Price Label Text Color")
priceLabelBackgroundColor = input.color(color.black, "Price Label Background Color")
priceLabelSizeInput = input.string("Small", "Price Label Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

majorTextSizeInput = input.string("Normal", "MAJOR Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

majorLineStyleInput = input.string("Dashed", "Major Line Style", options=["Solid", "Dashed", "Dotted"])
normalLineStyleInput = input.string("Solid", "Normal Line Style", options=["Solid", "Dashed", "Dotted"])

lineLookback = input.int(500, "Line Lookback Bars", minval=50)

supportColor = input.color(color.green, "Support Color")
majorSupportColor = input.color(color.lime, "Major Support Color")
resistanceColor = input.color(color.orange, "Resistance Color")
majorResistanceColor = input.color(color.red, "Major Resistance Color")

majorTextColor = input.color(color.yellow, "MAJOR Text Color")

normalWidth = input.int(1, "Normal Line Width", minval=1, maxval=5)
majorWidth = input.int(3, "Major Line Width", minval=1, maxval=5)

// ALERT INPUTS
enableTouchAlerts = input.bool(true, "Enable Touch Alerts")
touchBufferTicks = input.int(2, "Touch Alert Buffer Ticks", minval=0)

// ARRAYS
var line[] lines = array.new_line()
var label[] labels = array.new_label()
var box[] boxes = array.new_box()

getMajorTextSize() =>
    majorTextSizeInput == "Tiny" ? size.tiny :
     majorTextSizeInput == "Small" ? size.small :
     majorTextSizeInput == "Large" ? size.large :
     majorTextSizeInput == "Huge" ? size.huge :
     size.normal

getPriceLabelSize() =>
    priceLabelSizeInput == "Tiny" ? size.tiny :
     priceLabelSizeInput == "Normal" ? size.normal :
     priceLabelSizeInput == "Large" ? size.large :
     priceLabelSizeInput == "Huge" ? size.huge :
     size.small

getLineStyle(styleInput) =>
    styleInput == "Dashed" ? line.style_dashed :
     styleInput == "Dotted" ? line.style_dotted :
     line.style_solid

getPriceLabelY(price) =>
    offset = syminfo.mintick * priceLabelTickOffset
    priceLabelPosition == "Above" ? price + offset :
     priceLabelPosition == "Below" ? price - offset :
     price

isTouched(price) =>
    buffer = syminfo.mintick * touchBufferTicks
    high >= price - buffer and low <= price + buffer

clearDrawings() =>
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
        array.clear(lines)

    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
        array.clear(labels)

    if array.size(boxes) > 0
        for i = 0 to array.size(boxes) - 1
            box.delete(array.get(boxes, i))
        array.clear(boxes)

cleanText(txt) =>
    result = txt
    result := str.replace_all(result, "Supports are:", "")
    result := str.replace_all(result, "Support are:", "")
    result := str.replace_all(result, "Supports:", "")
    result := str.replace_all(result, "Support:", "")
    result := str.replace_all(result, "Resistances are:", "")
    result := str.replace_all(result, "Resistance are:", "")
    result := str.replace_all(result, "Resistances:", "")
    result := str.replace_all(result, "Resistance:", "")
    result

drawLevel(price, isMajor, isSupport) =>
    col = isSupport ? (isMajor ? majorSupportColor : supportColor) : (isMajor ? majorResistanceColor : resistanceColor)
    width = isMajor ? majorWidth : normalWidth
    lineStyle = isMajor ? getLineStyle(majorLineStyleInput) : getLineStyle(normalLineStyleInput)

    l = line.new(bar_index - lineLookback, price, bar_index + labelOffset, price, xloc=xloc.bar_index, extend=extend.right, color=col, width=width, style=lineStyle)
    array.push(lines, l)

    if showLabels
        labelText = str.tostring(price, format.mintick)
        labelY = getPriceLabelY(price)
        lab = label.new(bar_index + labelOffset, labelY, labelText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=priceLabelBackgroundColor, textcolor=priceLabelTextColor, size=getPriceLabelSize())
        array.push(labels, lab)

    if showMajorLabels and isMajor
        majorLab = label.new(bar_index + majorLabelOffset, price, "MAJOR", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=majorTextColor, size=getMajorTextSize())
        array.push(labels, majorLab)

drawZone(highPrice, lowPrice, isMajor, isSupport) =>
    col = isSupport ? majorSupportColor : majorResistanceColor
    b = box.new(bar_index - lineLookback, highPrice, bar_index + labelOffset, lowPrice, xloc=xloc.bar_index, border_color=col, bgcolor=color.new(col, 85))
    array.push(boxes, b)
    drawLevel(highPrice, isMajor, isSupport)
    drawLevel(lowPrice, isMajor, isSupport)

processLevels(txt, isSupport, doDraw) =>
    clean = cleanText(txt)
    parts = str.split(clean, ",")

    touchedAny = false
    touchedMajor = false

    if array.size(parts) > 0
        for i = 0 to array.size(parts) - 1
            part = str.trim(array.get(parts, i))
            isMajor = str.contains(str.lower(part), "major")

            part := str.replace_all(part, "(major)", "")
            part := str.replace_all(part, "major", "")
            part := str.trim(part)

            if str.length(part) > 0
                if str.contains(part, "-")
                    rangeParts = str.split(part, "-")

                    if array.size(rangeParts) >= 2
                        highText = str.trim(array.get(rangeParts, 0))
                        lowText = str.trim(array.get(rangeParts, 1))

                        if str.length(lowText) < str.length(highText)
                            prefixLength = str.length(highText) - str.length(lowText)
                            prefix = str.substring(highText, 0, prefixLength)
                            lowText := prefix + lowText

                        highPrice = str.tonumber(highText)
                        lowPrice = str.tonumber(lowText)

                        if not na(highPrice) and not na(lowPrice)
                            zoneHigh = math.max(highPrice, lowPrice)
                            zoneLow = math.min(highPrice, lowPrice)

                            buffer = syminfo.mintick * touchBufferTicks
                            zoneTouched = high >= zoneLow - buffer and low <= zoneHigh + buffer

                            touchedAny := touchedAny or zoneTouched
                            touchedMajor := touchedMajor or (zoneTouched and isMajor)

                            if doDraw
                                drawZone(zoneHigh, zoneLow, isMajor, isSupport)
                else
                    price = str.tonumber(part)

                    if not na(price)
                        levelTouched = isTouched(price)

                        touchedAny := touchedAny or levelTouched
                        touchedMajor := touchedMajor or (levelTouched and isMajor)

                        if doDraw
                            drawLevel(price, isMajor, isSupport)

    [touchedAny, touchedMajor]

// MAIN DRAWING
if barstate.islast
    clearDrawings()

[supportTouch, supportMajorTouch] = processLevels(supportText, true, barstate.islast)
[resistanceTouch, resistanceMajorTouch] = processLevels(resistanceText, false, barstate.islast)

anyTouch = enableTouchAlerts and (supportTouch or resistanceTouch)
majorTouch = enableTouchAlerts and (supportMajorTouch or resistanceMajorTouch)

// ALERT CONDITIONS
alertcondition(anyTouch, "Adam Level Touch", "Price touched an Adam support or resistance level.")
alertcondition(supportTouch and enableTouchAlerts, "Adam Support Touch", "Price touched an Adam support level.")
alertcondition(resistanceTouch and enableTouchAlerts, "Adam Resistance Touch", "Price touched an Adam resistance level.")
alertcondition(majorTouch, "Adam MAJOR Level Touch", "Price touched an Adam MAJOR level.")
````
