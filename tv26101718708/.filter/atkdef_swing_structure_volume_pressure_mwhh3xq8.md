# ATK/DEF Swing Structure Volume Pressure

- url: https://www.tradingview.com/script/mwhh3xq8/
- type: indicator
- pine_id: PUB;4e92781b4eed4b2db49376451c12fe76
- version: 1.0

## Description

# ATK/DEF Swing Structure  Volume Pressure Analysis

## Overview

ATK/DEF Swing Structure + Volume Pressure Analysis is a market analysis indicator designed to visualize price structure, support and resistance areas, volume activity, and candle behavior.

The indicator combines dynamic swing detection, structural level mapping, volume analysis, volume expansion observation, and candle pressure measurement into a unified visual framework.

This script focuses on market observation and technical analysis by displaying historical price behavior and current market conditions.

---

# Main Features

## Dynamic Swing Structure

The indicator automatically detects Swing Highs and Swing Lows based on market volatility.

The adaptive swing calculation uses ATR-based conditions to adjust sensitivity according to different market environments.

---

## Support & Resistance Structure

The script identifies historical structural levels from confirmed swing points.

Displayed information includes:

• Resistance areas
• Support areas
• Historical price levels
• Associated volume information

These levels provide a visual reference for studying price interaction with previous market areas.

---

## Volume Activity Analysis

The indicator compares current volume conditions with recent average volume.

Included information:

• Volume ratio
• Volume activity level
• Volume score visualization
• High-volume structural areas

This helps users observe changes in market participation.

---

## Volume Expansion Observation

The indicator detects unusual volume expansion by comparing current volume behavior with recent volume distribution.

Volume conditions are categorized into different activity levels to help users identify periods of increased market activity.

---

## Candle Pressure Analysis

The indicator evaluates candle position within its trading range to display pressure balance.

The calculation provides visual information about:

• Positive candle pressure
• Negative candle pressure
• Balanced candle conditions

This feature is designed for studying candle behavior together with price structure.

---

## Market Information Dashboard

The integrated dashboard displays:

• Volume conditions
• Volume score
• Volume expansion status
• Candle pressure status
• Support and resistance statistics
• Latest structural levels

---

# Methodology

The indicator combines several analytical concepts:

1. Swing Structure Detection
2. Support and Resistance Visualization
3. Volume Behavior Analysis
4. Volume Expansion Measurement
5. Candle Range Pressure Calculation

Each component works together to provide a clearer visualization of market behavior.

---

# Usage

This indicator can be used as a visual reference tool for:

• Studying market structure
• Observing historical reaction areas
• Monitoring volume changes
• Analyzing candle behavior
• Comparing current conditions with previous price activity

---

# Disclaimer

This script is provided for educational and analytical purposes.

It is designed to visualize market information and does not provide financial advice or automated decision-making.

Users should interpret the displayed information together with their own analysis and risk management approach.

---

# Original Concept

ATK/DEF focuses on the relationship between:

• Price Structure
• Volume Participation
• Candle Behavior

The framework is designed to organize multiple market observations into one clear visual analysis tool.

## Source Code

````pine
//@version=6
indicator("ATK/DEF Swing Structure Volume Pressure", overlay=true, 
          max_lines_count=200, max_labels_count=200,
          shorttitle="Swing Structure Volume Pressure")

// ============================================================
// MODULE 1: User Input Parameters
// ============================================================
volumeThreshold = input.float(1.5, "Volume Threshold", minval=1.0, maxval=3.0, step=0.1, tooltip="Volume above average multiplier for strong S/R")
maxSwingPoints = input.int(15, "Max Swing Points", minval=5, maxval=50, tooltip="Number of Swing High/Low points to keep")
showLabels = input.bool(true, "Show S/R Labels")
showLines = input.bool(true, "Show Horizontal Lines")
showTable = input.bool(true, "Show Info Table")

// ----- Table Position and Size Control -----
tablePosition = input.string("top_right", "Table Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], tooltip="Table position on chart")
tableScale = input.float(1.0, "Table Scale", minval=0.5, maxval=2.0, step=0.1, tooltip="Table overall scale")
tableWidth = input.int(2, "Table Column Width", minval=1, maxval=5, step=1, tooltip="Table column width multiplier")
tableBgOpacity = input.int(92, "Table Background Opacity", minval=50, maxval=100, step=1, tooltip="Background opacity (50-100)")

// Auto-calculate Swing detection period
autoBars = math.round(ta.atr(14) / ta.sma(ta.tr, 50) * 5)
autoBars := math.max(3, math.min(10, autoBars))
volumeLookback = 20

// ============================================================
// MODULE 2: Helper Functions
// ============================================================

formatVolume(vol) =>
    if na(vol) or vol <= 0
        "N/A"
    else if vol >= 1000000
        str.tostring(vol / 1000000, "#.##") + "M"
    else if vol >= 1000
        str.tostring(vol / 1000, "#.#") + "K"
    else
        str.tostring(vol, "0")

formatPrice(price) =>
    if na(price)
        "N/A"
    else
        str.tostring(price, "#.##")

isHighVolume(vol, avgVol, threshold) =>
    not na(vol) and not na(avgVol) and avgVol > 0 and vol / avgVol > threshold

// ============================================================
// MODULE 3: Technical Indicators
// ============================================================

var float avgVolume = na
avgVolume := ta.sma(volume, volumeLookback)

volRatio = avgVolume > 0 ? volume / avgVolume : 0

// Volume Score
volumeScore = 50
if volRatio > 2.5
    volumeScore := 100
else if volRatio > 2.0
    volumeScore := 90
else if volRatio > 1.5
    volumeScore := 75
else if volRatio > 1.2
    volumeScore := 65
else if volRatio > 1.0
    volumeScore := 55
else if volRatio > 0.7
    volumeScore := 40
else if volRatio > 0.5
    volumeScore := 25
else
    volumeScore := 10

// ----- Volume Spike Detection -----
var float[] recentVolumes = array.new_float()
array.push(recentVolumes, volume)
if array.size(recentVolumes) > 20
    array.remove(recentVolumes, 0)

volMean = array.avg(recentVolumes)
volStd = array.stdev(recentVolumes)

isSpike = volMean > 0 and volStd > 0 and volume > volMean + 2 * volStd

spikeDanger = ""
spikeColor = color.white
spikeScore = 0

if isSpike
    spikeRatio = volume / volMean
    if spikeRatio > 4.0
        spikeDanger := "🔴 EXTREME SPIKE"
        spikeColor := color.rgb(255,0,0)
        spikeScore := 100
    else if spikeRatio > 3.0
        spikeDanger := "🟠 HIGH SPIKE"
        spikeColor := color.rgb(255,150,0)
        spikeScore := 75
    else if spikeRatio > 2.5
        spikeDanger := "🟡 MODERATE SPIKE"
        spikeColor := color.rgb(255,200,0)
        spikeScore := 50
    else
        spikeDanger := "🟢 WEAK SPIKE"
        spikeColor := color.rgb(100,255,100)
        spikeScore := 25
else
    spikeDanger := "✅ NORMAL"
    spikeColor := color.rgb(100,200,255)
    spikeScore := 0

// Candle Pressure Balance
totalRange = high - low + 0.0001
buyPressure = (close - low) / totalRange * 100
sellPressure = (high - close) / totalRange * 100
pressureBalance = buyPressure - sellPressure

pressureStatus = ""
pressureColor = color.white
if pressureBalance > 60
    pressureStatus := "🟢 Bull Pressure"
    pressureColor := color.rgb(0,255,0)
else if pressureBalance > 30
    pressureStatus := "📈 Buying Dominance"
    pressureColor := color.rgb(100,255,100)
else if pressureBalance > 10
    pressureStatus := "📈 Weak Buying"
    pressureColor := color.rgb(150,255,150)
else if pressureBalance > -10
    pressureStatus := "➡️ Balanced"
    pressureColor := color.rgb(200,200,200)
else if pressureBalance > -30
    pressureStatus := "📉 Weak Selling"
    pressureColor := color.rgb(255,200,150)
else if pressureBalance > -60
    pressureStatus := "📉 Selling Dominance"
    pressureColor := color.rgb(255,150,100)
else
    pressureStatus := "🔴 Bear Pressure"
    pressureColor := color.rgb(255,0,0)

// ============================================================
// MODULE 4: Swing Detection + Array Management
// ============================================================

swingHigh = ta.pivothigh(autoBars, autoBars)
swingLow = ta.pivotlow(autoBars, autoBars)

// ----- Resistance Data Arrays -----
var float[] resPrices = array.new_float()
var int[] resIndices = array.new_int()
var float[] resVolumes = array.new_float()

// ----- Support Data Arrays -----
var float[] supPrices = array.new_float()
var int[] supIndices = array.new_int()
var float[] supVolumes = array.new_float()

// ----- Resistance Graphics Arrays -----
var label[] resLabels = array.new_label()
var line[] resLines = array.new_line()

// ----- Support Graphics Arrays -----
var label[] supLabels = array.new_label()
var line[] supLines = array.new_line()

// ----- Table Data Arrays -----
var string[] tableLabels = array.new_string()
var string[] tableValues = array.new_string()
var color[] tableLabelColors = array.new_color()
var color[] tableValueColors = array.new_color()

// ----- Volume Spike Data Arrays -----
var float[] spikeHistory = array.new_float()
var int[] spikeIndices = array.new_int()
var string[] spikeLabels = array.new_string()
var label[] spikeMarkers = array.new_label()

// ============================================================
// MODULE 5: Table Position Mapping + Create Table
// ============================================================

var table infoTable = na
if barstate.isfirst
    tablePos = position.top_right
    if tablePosition == "top_left"
        tablePos := position.top_left
    else if tablePosition == "top_center"
        tablePos := position.top_center
    else if tablePosition == "top_right"
        tablePos := position.top_right
    else if tablePosition == "middle_left"
        tablePos := position.middle_left
    else if tablePosition == "middle_center"
        tablePos := position.middle_center
    else if tablePosition == "middle_right"
        tablePos := position.middle_right
    else if tablePosition == "bottom_left"
        tablePos := position.bottom_left
    else if tablePosition == "bottom_center"
        tablePos := position.bottom_center
    else
        tablePos := position.bottom_right
    
    infoTable := table.new(
        position=tablePos,
        columns=2,
        rows=11,
        bgcolor=color.rgb(10,10,30, tableBgOpacity),
        border_color=color.rgb(80,80,150, 50),
        border_width=math.round(tableWidth),
        frame_color=color.rgb(50,50,120, 70),
        frame_width=math.round(tableWidth)
    )

// ----- Process Resistance -----
if not na(swingHigh)
    array.push(resPrices, swingHigh)
    array.push(resIndices, bar_index[autoBars])
    array.push(resVolumes, volume[autoBars])
    
    if array.size(resPrices) > maxSwingPoints
        array.remove(resPrices, 0)
        array.remove(resIndices, 0)
        array.remove(resVolumes, 0)

// ----- Process Support -----
if not na(swingLow)
    array.push(supPrices, swingLow)
    array.push(supIndices, bar_index[autoBars])
    array.push(supVolumes, volume[autoBars])
    
    if array.size(supPrices) > maxSwingPoints
        array.remove(supPrices, 0)
        array.remove(supIndices, 0)
        array.remove(supVolumes, 0)

// ----- Process Volume Spike -----
if isSpike
    array.push(spikeHistory, volume)
    array.push(spikeIndices, bar_index)
    array.push(spikeLabels, spikeDanger)
    
    if array.size(spikeHistory) > 10
        array.remove(spikeHistory, 0)
        array.remove(spikeIndices, 0)
        array.remove(spikeLabels, 0)

// ============================================================
// MODULE 6: Clean Up Old Graphics
// ============================================================

if array.size(resLabels) > 0
    for i = 0 to array.size(resLabels) - 1
        lbl = array.get(resLabels, i)
        if not na(lbl)
            label.delete(lbl)
array.clear(resLabels)

if array.size(supLabels) > 0
    for i = 0 to array.size(supLabels) - 1
        lbl = array.get(supLabels, i)
        if not na(lbl)
            label.delete(lbl)
array.clear(supLabels)

if array.size(resLines) > 0
    for i = 0 to array.size(resLines) - 1
        ln = array.get(resLines, i)
        if not na(ln)
            line.delete(ln)
array.clear(resLines)

if array.size(supLines) > 0
    for i = 0 to array.size(supLines) - 1
        ln = array.get(supLines, i)
        if not na(ln)
            line.delete(ln)
array.clear(supLines)

if array.size(spikeMarkers) > 0
    for i = 0 to array.size(spikeMarkers) - 1
        marker = array.get(spikeMarkers, i)
        if not na(marker)
            label.delete(marker)
array.clear(spikeMarkers)

// ============================================================
// MODULE 7: Draw Labels
// ============================================================

if showLabels
    for i = 0 to array.size(resPrices) - 1
        idx = array.get(resIndices, i)
        val = array.get(resPrices, i)
        vol = array.get(resVolumes, i)
        
        if not na(idx) and not na(val) and not na(vol) and vol > 0
            volDisplay = formatVolume(vol)
            priceDisplay = formatPrice(val)
            isVolHigh = isHighVolume(vol, avgVolume, volumeThreshold)
            volMark = isVolHigh ? " 🔥" : ""
            
            lbl = label.new(
                x=idx, y=val,
                text="🔴 R: " + priceDisplay + "\n" + volDisplay + volMark,
                color=color.new(color.red, 65),
                textcolor=color.white,
                style=label.style_label_down,
                size=size.small,
                textalign=text.align_center
            )
            array.push(resLabels, lbl)
    
    for i = 0 to array.size(supPrices) - 1
        idx = array.get(supIndices, i)
        val = array.get(supPrices, i)
        vol = array.get(supVolumes, i)
        
        if not na(idx) and not na(val) and not na(vol) and vol > 0
            volDisplay = formatVolume(vol)
            priceDisplay = formatPrice(val)
            isVolHigh = isHighVolume(vol, avgVolume, volumeThreshold)
            volMark = isVolHigh ? " 🔥" : ""
            
            lbl = label.new(
                x=idx, y=val,
                text="🟢 S: " + priceDisplay + "\n" + volDisplay + volMark,
                color=color.new(color.green, 65),
                textcolor=color.white,
                style=label.style_label_up,
                size=size.small,
                textalign=text.align_center
            )
            array.push(supLabels, lbl)

// ============================================================
// MODULE 8: Draw Horizontal Lines
// ============================================================

if showLines
    for i = 0 to array.size(resPrices) - 1
        idx = array.get(resIndices, i)
        val = array.get(resPrices, i)
        if not na(idx) and not na(val)
            ln = line.new(
                x1=idx, y1=val,
                x2=idx + 10, y2=val,
                color=color.new(color.red, 20),
                style=line.style_dotted,
                width=1,
                extend=extend.none
            )
            array.push(resLines, ln)
    
    for i = 0 to array.size(supPrices) - 1
        idx = array.get(supIndices, i)
        val = array.get(supPrices, i)
        if not na(idx) and not na(val)
            ln = line.new(
                x1=idx, y1=val,
                x2=idx + 10, y2=val,
                color=color.new(color.green, 20),
                style=line.style_dotted,
                width=1,
                extend=extend.none
            )
            array.push(supLines, ln)

// ============================================================
// MODULE 9: Latest Price Labels
// ============================================================

if barstate.islast
    if array.size(resPrices) > 0
        lastIdx = array.size(resPrices) - 1
        idx = array.get(resIndices, lastIdx)
        val = array.get(resPrices, lastIdx)
        if not na(idx) and not na(val)
            label.new(
                x=bar_index + 2, y=val,
                text="R: " + str.tostring(val, "#.##"),
                color=color.rgb(255,0,0, 20),
                textcolor=color.white,
                style=label.style_label_left,
                size=size.tiny
            )
    
    if array.size(supPrices) > 0
        lastIdx = array.size(supPrices) - 1
        idx = array.get(supIndices, lastIdx)
        val = array.get(supPrices, lastIdx)
        if not na(idx) and not na(val)
            label.new(
                x=bar_index + 2, y=val,
                text="S: " + str.tostring(val, "#.##"),
                color=color.rgb(0,255,0, 20),
                textcolor=color.white,
                style=label.style_label_left,
                size=size.tiny
            )

// ============================================================
// MODULE 10: Draw Spike Markers
// ============================================================

if isSpike
    spikeLabel = label.new(
        x=bar_index,
        y=high + ta.atr(10) * 0.5,
        text=spikeDanger + "\n" + formatVolume(volume) + " (" + str.tostring(volume / volMean, "#.#") + "x)",
        color=color.new(spikeColor, 70),
        textcolor=color.white,
        style=label.style_label_down,
        size=size.small,
        textalign=text.align_center
    )
    array.push(spikeMarkers, spikeLabel)

// ============================================================
// MODULE 11: Table Data Management
// ============================================================

array.clear(tableLabels)
array.clear(tableValues)
array.clear(tableLabelColors)
array.clear(tableValueColors)

resCount = array.size(resPrices)
supCount = array.size(supPrices)

latestResPrice = resCount > 0 ? str.tostring(array.get(resPrices, resCount - 1), "#.##") : "N/A"
latestSupPrice = supCount > 0 ? str.tostring(array.get(supPrices, supCount - 1), "#.##") : "N/A"

highVolRes = 0
for i = 0 to resCount - 1
    if isHighVolume(array.get(resVolumes, i), avgVolume, volumeThreshold)
        highVolRes := highVolRes + 1

highVolSup = 0
for i = 0 to supCount - 1
    if isHighVolume(array.get(supVolumes, i), avgVolume, volumeThreshold)
        highVolSup := highVolSup + 1

volStatus = ""
volColor = color.white
if volRatio > 2.0
    volStatus := "🔥 EXTREME"
    volColor := color.rgb(255,100,100)
else if volRatio > 1.5
    volStatus := "📈 HIGH"
    volColor := color.rgb(255,180,100)
else if volRatio > 1.0
    volStatus := "📊 ABOVE AVG"
    volColor := color.rgb(200,200,100)
else if volRatio > 0.7
    volStatus := "📉 BELOW AVG"
    volColor := color.rgb(150,150,200)
else
    volStatus := "❄️ LOW"
    volColor := color.rgb(100,150,200)

volumeScoreDisplay = str.tostring(volumeScore) + "/100"
volumeScoreColor = volumeScore >= 80 ? color.rgb(0,255,0) :
                   volumeScore >= 60 ? color.rgb(100,255,100) :
                   volumeScore >= 40 ? color.rgb(200,200,100) :
                   volumeScore >= 20 ? color.rgb(255,150,100) :
                   color.rgb(255,50,50)

spikeCount = array.size(spikeHistory)
lastSpike = spikeCount > 0 ? array.get(spikeLabels, spikeCount - 1) : "None"
spikeDisplay = spikeCount > 0 ? str.tostring(spikeCount) + " (Latest: " + lastSpike + ")" : "✅ No Spikes"

// ----- Determine Text Size Based on Scale -----
textSize = size.small
if tableScale >= 1.5
    textSize := size.large
else if tableScale >= 1.0
    textSize := size.normal
else
    textSize := size.small

// ----- Fill Table Data -----
array.push(tableLabels, " Swing Structure Volume Pressure")
array.push(tableValues, "")
array.push(tableLabelColors, color.rgb(200,220,255))
array.push(tableValueColors, color.rgb(200,220,255))

array.push(tableLabels, "━━━━━━━━━━━━━━━━")
array.push(tableValues, "")
array.push(tableLabelColors, color.rgb(80,80,150))
array.push(tableValueColors, color.rgb(80,80,150))

array.push(tableLabels, "📊 Volume")
array.push(tableValues, volStatus + " " + str.tostring(volRatio, "#.##") + "x")
array.push(tableLabelColors, color.rgb(180,200,255))
array.push(tableValueColors, volColor)

array.push(tableLabels, "📈 Volume Score")
array.push(tableValues, volumeScoreDisplay)
array.push(tableLabelColors, color.rgb(180,200,255))
array.push(tableValueColors, volumeScoreColor)

array.push(tableLabels, "⚡ Spike Danger")
array.push(tableValues, spikeDanger + " (Score: " + str.tostring(spikeScore) + ")")
array.push(tableLabelColors, color.rgb(255,200,150))
array.push(tableValueColors, spikeColor)

array.push(tableLabels, "📋 Spike History")
array.push(tableValues, spikeDisplay)
array.push(tableLabelColors, color.rgb(180,200,255))
array.push(tableValueColors, color.rgb(200,200,200))

array.push(tableLabels, "⚖️ Candle Pressure")
array.push(tableValues, pressureStatus + " (" + str.tostring(pressureBalance, "#.#") + ")")
array.push(tableLabelColors, color.rgb(180,200,255))
array.push(tableValueColors, pressureColor)

array.push(tableLabels, "───────────────")
array.push(tableValues, "")
array.push(tableLabelColors, color.rgb(60,60,120))
array.push(tableValueColors, color.rgb(60,60,120))

array.push(tableLabels, "🔴 Resistance")
array.push(tableValues, str.tostring(resCount) + " (🔥" + str.tostring(highVolRes) + ")")
array.push(tableLabelColors, color.rgb(255,150,150))
array.push(tableValueColors, color.rgb(255,200,200))

array.push(tableLabels, "🟢 Support")
array.push(tableValues, str.tostring(supCount) + " (🔥" + str.tostring(highVolSup) + ")")
array.push(tableLabelColors, color.rgb(150,255,150))
array.push(tableValueColors, color.rgb(200,255,200))

array.push(tableLabels, "🎯 Latest R/S")
array.push(tableValues, "R:" + latestResPrice + " S:" + latestSupPrice)
array.push(tableLabelColors, color.rgb(180,200,255))
array.push(tableValueColors, color.rgb(200,220,255))

// ============================================================
// MODULE 12: Render Table (with Scaling)
// ============================================================

if showTable and barstate.islast and not na(infoTable)
    for row = 0 to array.size(tableLabels) - 1
        labelText = array.get(tableLabels, row)
        valueText = array.get(tableValues, row)
        labelColor = array.get(tableLabelColors, row)
        valueColor = array.get(tableValueColors, row)
        
        isHeader = row == 0
        isSeparator = row == 1 or row == 7
        
        if isHeader
            table.cell(infoTable, 0, row, labelText, 
                       text_color=labelColor, 
                       bgcolor=color.rgb(math.round(30 * tableScale), math.round(50 * tableScale), math.round(120 * tableScale)), 
                       text_size=textSize, 
                       text_halign=text.align_center)
            table.cell(infoTable, 1, row, "", 
                       text_color=labelColor, 
                       bgcolor=color.rgb(math.round(30 * tableScale), math.round(50 * tableScale), math.round(120 * tableScale)), 
                       text_size=textSize)
        else if isSeparator
            table.cell(infoTable, 0, row, labelText, 
                       text_color=labelColor, 
                       bgcolor=color.rgb(math.round(15 * tableScale), math.round(15 * tableScale), math.round(40 * tableScale)), 
                       text_size=textSize, 
                       text_halign=text.align_center)
            table.cell(infoTable, 1, row, "", 
                       text_color=labelColor, 
                       bgcolor=color.rgb(math.round(15 * tableScale), math.round(15 * tableScale), math.round(40 * tableScale)), 
                       text_size=textSize)
        else
            table.cell(infoTable, 0, row, labelText, 
                       text_color=labelColor, 
                       bgcolor=color.rgb(math.round(20 * tableScale), math.round(25 * tableScale), math.round(55 * tableScale)), 
                       text_size=textSize, 
                       text_halign=text.align_left)
            table.cell(infoTable, 1, row, valueText, 
                       text_color=valueColor, 
                       bgcolor=color.rgb(math.round(20 * tableScale), math.round(25 * tableScale), math.round(55 * tableScale)), 
                       text_size=textSize, 
                       text_halign=text.align_right)
````
