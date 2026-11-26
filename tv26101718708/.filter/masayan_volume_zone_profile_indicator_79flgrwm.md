# Masayan Volume Zone Profile Indicator

- url: https://www.tradingview.com/script/79fLgRwm/
- type: indicator
- pine_id: PUB;b1c1ad95bf55407bb27723baac348ca3
- version: 1.0

## Description

Masayan Volume Zone Profile Indicator is a dynamic volume-zone analysis tool that automatically calculates an estimated volume profile from all bars currently visible on the chart.

The indicator detects the chart’s visible range and recalculates whenever the user scrolls or zooms. No fixed lookback period is required.

Each visible candle’s TradingView volume is distributed across the price rows overlapped by its high-low range. The resulting profile highlights the price zones where the greatest estimated volume was concentrated.

Main features:

Automatic visible-chart range detection
Dynamic recalculation when scrolling or zooming
Estimated price-by-volume profile
Visible-range total volume summary
Estimated Point of Control
Value Area High and Value Area Low
Highlighted high-volume zones
Left or right profile positioning
POC-cross and value-area-entry alerts
Optional display controls
The profile is always drawn inside the currently visible chart range. Value-area volume bars are displayed in orange, volume outside the value area is displayed in blue, and the Point of Control is highlighted in red.

This indicator does not use broker order-book data, actual bid/ask volume, or market participant positions. The displayed profile is estimated from TradingView volume data and candle price ranges.

For forex symbols, TradingView volume may represent tick volume rather than centralized traded volume.

This script is intended for chart analysis, research, and educational purposes only.
It does not guarantee future performance and should not be considered financial advice.
Please test carefully before using it in any trading decision.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright MasayanFX

//@version=6
indicator("Masayan Volume Zone Profile Indicator", overlay=true, max_boxes_count=300, max_lines_count=10, max_labels_count=10)

// Inputs
profileRows = input.int(48, "Profile Rows", minval=16, maxval=100)
profileWidthPercent = input.float(28.0, "Profile Width Percent", minval=10.0, maxval=50.0)
profilePosition = input.string("Left", "Profile Position", options=["Left", "Right"])
valueAreaPercent = input.float(70.0, "Value Area Percent", minval=50.0, maxval=95.0)
hvnThreshold = input.float(65.0, "High Volume Zone Threshold", minval=20.0, maxval=95.0)

showValueAreaZone = input.bool(true, "Show Value Area Zone")
showHighVolumeZones = input.bool(true, "Show High Volume Zones")
showLevelLines = input.bool(true, "Show POC / Value Area Levels")
showLabels = input.bool(true, "Show Level Labels")
showSummary = input.bool(true, "Show Visible Volume Summary")

// Colors
outsideColor = input.color(color.rgb(70, 160, 220), "Outside Value Area Color")
valueAreaColor = input.color(color.rgb(240, 170, 70), "Value Area Color")
pocColor = input.color(color.rgb(255, 80, 90), "POC Color")
hvnColor = input.color(color.rgb(255, 190, 60), "High Volume Zone Color")

// Visible Chart Range
var int visibleLeftIndex = na
var int visibleRightIndex = na
var float visibleHigh = na
var float visibleLow = na
var float visibleVolume = 0.0
var float[] visibleHighs = array.new_float()
var float[] visibleLows = array.new_float()
var float[] visibleVolumes = array.new_float()

if barstate.isfirst
    array.clear(visibleHighs)
    array.clear(visibleLows)
    array.clear(visibleVolumes)
    visibleHigh := na
    visibleLow := na
    visibleVolume := 0.0

if time == chart.left_visible_bar_time
    visibleLeftIndex := bar_index

if time == chart.right_visible_bar_time
    visibleRightIndex := bar_index

isVisibleBar = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time

if isVisibleBar
    array.push(visibleHighs, high)
    array.push(visibleLows, low)
    array.push(visibleVolumes, nz(volume, 0.0))
    visibleHigh := na(visibleHigh) ? high : math.max(visibleHigh, high)
    visibleLow := na(visibleLow) ? low : math.min(visibleLow, low)
    visibleVolume += nz(volume, 0.0)

// Drawing Objects
var box[] profileBoxes = array.new_box()
var box[] zoneBoxes = array.new_box()
var line[] levelLines = array.new_line()
var label[] levelLabels = array.new_label()
var table summaryTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 82), border_width=0)

clearObjects() =>
    while array.size(profileBoxes) > 0
        box.delete(array.pop(profileBoxes))
    while array.size(zoneBoxes) > 0
        box.delete(array.pop(zoneBoxes))
    while array.size(levelLines) > 0
        line.delete(array.pop(levelLines))
    while array.size(levelLabels) > 0
        label.delete(array.pop(levelLabels))

// Latest Profile Values
var float currentPOC = na
var float currentVAH = na
var float currentVAL = na
var float currentVisibleVolume = na
var int currentVisibleBars = na

// Build the profile from every currently visible chart bar.
if barstate.islast and not na(visibleLeftIndex) and not na(visibleRightIndex)
    clearObjects()

    int calculationBars = array.size(visibleHighs)
    int calculationLeftIndex = visibleLeftIndex

    float priceRange = visibleHigh - visibleLow
    float rowHeight = priceRange / profileRows

    currentVisibleVolume := visibleVolume
    currentVisibleBars := calculationBars

    if rowHeight > 0
        float[] rowVolumes = array.new_float(profileRows, 0.0)

        // Second pass: distribute every visible candle's volume across price rows.
        for visibleIndex = 0 to calculationBars - 1
            float candleHigh = array.get(visibleHighs, visibleIndex)
            float candleLow = array.get(visibleLows, visibleIndex)
            float candleRange = math.max(candleHigh - candleLow, syminfo.mintick)
            float candleVolume = array.get(visibleVolumes, visibleIndex)
            bool volumeAllocated = false

            for row = 0 to profileRows - 1
                float rowLow = visibleLow + rowHeight * row
                float rowHigh = rowLow + rowHeight
                float overlap = math.max(0.0, math.min(candleHigh, rowHigh) - math.max(candleLow, rowLow))

                if overlap > 0
                    array.set(rowVolumes, row, array.get(rowVolumes, row) + candleVolume * overlap / candleRange)
                    volumeAllocated := true

            // Allocate zero-range candle volume to its matching price row.
            if not volumeAllocated
                int flatRow = math.min(profileRows - 1, math.max(0, int(math.floor((candleLow - visibleLow) / rowHeight))))
                array.set(rowVolumes, flatRow, array.get(rowVolumes, flatRow) + candleVolume)

        // Find POC and value area.
        float maximumVolume = 0.0
        int pocRow = 0

        for row = 0 to profileRows - 1
            float rowVolume = array.get(rowVolumes, row)
            if rowVolume > maximumVolume
                maximumVolume := rowVolume
                pocRow := row

        int valueLowRow = pocRow
        int valueHighRow = pocRow
        float includedVolume = array.get(rowVolumes, pocRow)
        float targetVolume = visibleVolume * valueAreaPercent / 100.0

        while includedVolume < targetVolume and (valueLowRow > 0 or valueHighRow < profileRows - 1)
            float upperVolume = valueHighRow < profileRows - 1 ? array.get(rowVolumes, valueHighRow + 1) : -1.0
            float lowerVolume = valueLowRow > 0 ? array.get(rowVolumes, valueLowRow - 1) : -1.0

            if upperVolume >= lowerVolume and valueHighRow < profileRows - 1
                valueHighRow += 1
                includedVolume += upperVolume
            else if valueLowRow > 0
                valueLowRow -= 1
                includedVolume += lowerVolume
            else
                break

        currentPOC := visibleLow + rowHeight * (pocRow + 0.5)
        currentVAH := visibleLow + rowHeight * (valueHighRow + 1.0)
        currentVAL := visibleLow + rowHeight * valueLowRow

        // Keep the entire profile inside the currently visible chart.
        int horizontalPadding = math.max(1, int(math.round(calculationBars * 0.015)))
        int maximumProfileWidth = math.max(5, int(math.round(calculationBars * profileWidthPercent / 100.0)))
        int profileOuterEdge = profilePosition == "Left" ? calculationLeftIndex + horizontalPadding : visibleRightIndex - horizontalPadding

        if showValueAreaZone
            box valueZone = box.new(calculationLeftIndex, currentVAH, visibleRightIndex, currentVAL, xloc=xloc.bar_index, bgcolor=color.new(valueAreaColor, 95), border_color=color.new(valueAreaColor, 100))
            array.push(zoneBoxes, valueZone)

        for row = 0 to profileRows - 1
            float rowVolume = array.get(rowVolumes, row)
            float rowLow = visibleLow + rowHeight * row
            float rowHigh = rowLow + rowHeight
            float relativeVolume = maximumVolume > 0 ? rowVolume / maximumVolume : 0.0
            int width = math.max(1, int(math.round(relativeVolume * maximumProfileWidth)))
            bool insideValueArea = row >= valueLowRow and row <= valueHighRow
            bool isPOC = row == pocRow
            bool isHighVolume = relativeVolume * 100.0 >= hvnThreshold

            if showHighVolumeZones and isHighVolume and not isPOC
                box highVolumeZone = box.new(calculationLeftIndex, rowHigh, visibleRightIndex, rowLow, xloc=xloc.bar_index, bgcolor=color.new(hvnColor, 96), border_color=color.new(hvnColor, 100))
                array.push(zoneBoxes, highVolumeZone)

            int boxLeft = profilePosition == "Left" ? profileOuterEdge : profileOuterEdge - width
            int boxRight = profilePosition == "Left" ? profileOuterEdge + width : profileOuterEdge
            color rowColor = isPOC ? color.new(pocColor, 8) : insideValueArea ? color.new(valueAreaColor, 18) : color.new(outsideColor, 35)
            box volumeBar = box.new(boxLeft, rowHigh, boxRight, rowLow, xloc=xloc.bar_index, bgcolor=rowColor, border_color=color.new(rowColor, 100))
            array.push(profileBoxes, volumeBar)

        if showLevelLines
            line pocLine = line.new(calculationLeftIndex, currentPOC, visibleRightIndex, currentPOC, xloc=xloc.bar_index, color=color.new(pocColor, 35), width=2)
            line vahLine = line.new(calculationLeftIndex, currentVAH, visibleRightIndex, currentVAH, xloc=xloc.bar_index, color=color.new(outsideColor, 65), style=line.style_dashed)
            line valLine = line.new(calculationLeftIndex, currentVAL, visibleRightIndex, currentVAL, xloc=xloc.bar_index, color=color.new(outsideColor, 65), style=line.style_dashed)
            array.push(levelLines, pocLine)
            array.push(levelLines, vahLine)
            array.push(levelLines, valLine)

        if showLabels
            label pocLabel = label.new(visibleRightIndex, currentPOC, "POC", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(pocColor, 20), textcolor=color.white, size=size.tiny)
            label vahLabel = label.new(visibleRightIndex, currentVAH, "VAH", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(outsideColor, 40), textcolor=color.white, size=size.tiny)
            label valLabel = label.new(visibleRightIndex, currentVAL, "VAL", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(outsideColor, 40), textcolor=color.white, size=size.tiny)
            array.push(levelLabels, pocLabel)
            array.push(levelLabels, vahLabel)
            array.push(levelLabels, valLabel)

    if showSummary
        table.cell(summaryTable, 0, 0, "VISIBLE PROFILE", text_color=color.white, bgcolor=color.new(color.rgb(35, 40, 48), 15))
        table.cell(summaryTable, 1, 0, str.tostring(currentVisibleBars) + " bars", text_color=color.new(color.white, 15), bgcolor=color.new(color.rgb(35, 40, 48), 15))
        table.cell(summaryTable, 0, 1, "Total volume", text_color=color.new(color.white, 30))
        table.cell(summaryTable, 1, 1, str.tostring(currentVisibleVolume, format.volume), text_color=valueAreaColor)
        table.cell(summaryTable, 0, 2, "POC", text_color=color.new(color.white, 30))
        table.cell(summaryTable, 1, 2, str.tostring(currentPOC, format.mintick), text_color=pocColor)
        table.cell(summaryTable, 0, 3, "Value area", text_color=color.new(color.white, 30))
        table.cell(summaryTable, 1, 3, str.tostring(currentVAL, format.mintick) + " - " + str.tostring(currentVAH, format.mintick), text_color=outsideColor)
    else
        table.clear(summaryTable, 0, 0, 1, 3)

// Data Window
plot(currentPOC, "Visible POC", display=display.data_window)
plot(currentVAH, "Visible Value Area High", display=display.data_window)
plot(currentVAL, "Visible Value Area Low", display=display.data_window)
plot(currentVisibleVolume, "Visible Total Volume", display=display.data_window)
````
