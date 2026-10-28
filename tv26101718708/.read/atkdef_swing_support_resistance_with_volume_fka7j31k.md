# ATK/DEF Swing Support & Resistance with Volume

- url: https://www.tradingview.com/script/FkA7j31K/
- type: indicator
- pine_id: PUB;7bbf3bf7bfdc4818b03ee201877fb346
- version: 1.0

## Description

## ATK/DEF Swing Support & Resistance with Volume Analysis

### Overview

This indicator is designed to visualize market structure through automatic Swing High and Swing Low detection combined with volume analysis.

It identifies historical support and resistance levels based on confirmed swing points and provides additional volume information to help users understand the strength of previous market reactions.

This tool focuses on price structure, level visualization, and market observation. It does not generate buy or sell signals.

---

## Main Features

### 1. Automatic Swing Detection

The indicator automatically detects Swing Highs and Swing Lows based on market volatility.

The swing detection period dynamically adjusts using ATR volatility conditions, allowing the indicator to adapt to different market environments.

---

### 2. Support & Resistance Mapping

Detected swing points are displayed as:

🔴 Resistance Levels
🟢 Support Levels

Each level represents a previous area where price showed a meaningful reaction.

The indicator stores recent swing levels and updates them as new market structure develops.

---

### 3. Volume Analysis

Each support and resistance level includes historical volume information from the corresponding swing candle.

Volume comparison is used to highlight stronger activity areas:

🔥 High Volume Marker

A higher-than-average volume condition may indicate increased market participation around that price area.

---

### 4. Market Structure Visualization

The indicator helps users observe:

• Previous reaction zones
• Historical support areas
• Historical resistance areas
• Volume participation around important levels
• Changing market structure

---

### 5. Dynamic Adaptation

Instead of using a fixed swing period, the indicator adjusts detection sensitivity according to market volatility.

This allows the tool to respond differently during:

• Low volatility consolidation
• Normal market movement
• Higher volatility conditions

---

## How To Use

This indicator can be used as a visual reference tool together with your own market analysis.

Possible applications include:

• Studying historical price reaction areas
• Identifying important structural levels
• Observing volume behavior near support/resistance zones
• Combining with price action or other analysis methods

---

## Important Notes

This indicator does not provide trading signals, guaranteed results, or investment advice.

Support and resistance levels represent historical market behavior and should be interpreted together with broader market context, risk management, and personal trading methodology.

---

## Original Concept

The indicator combines three analytical components:

1. Swing Structure
2. Support & Resistance Mapping
3. Volume Participation Analysis

The purpose is to create a clear visual framework for studying how price interacts with important historical levels.

## Source Code

````pine
//@version=6
indicator("Swing Support & Resistance with Volume", overlay=true, 
          max_lines_count=200, max_labels_count=200,
          shorttitle="S/R Vol")

// ============================================================
// MODULE 1: User Input Parameters
// ============================================================
volumeThreshold = input.float(1.5, "Volume Threshold", minval=1.0, maxval=3.0, step=0.1, tooltip="Volume above average multiplier for strong S/R")
maxSwingPoints = input.int(15, "Max Swing Points", minval=5, maxval=50, tooltip="Number of Swing High/Low points to keep")
showLabels = input.bool(true, "Show S/R Labels")
showLines = input.bool(true, "Show Horizontal Lines")
showTable = input.bool(true, "Show Info Table")

// Auto-calculate Swing detection period and volume MA
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

// ============================================================
// MODULE 4: Swing Detection + Array Management
// ============================================================

swingHigh = ta.pivothigh(autoBars, autoBars)
swingLow = ta.pivotlow(autoBars, autoBars)

// ----- Resistance (Swing High) Arrays -----
var float[] resPrices = array.new_float()
var int[] resIndices = array.new_int()
var float[] resVolumes = array.new_float()

// ----- Support (Swing Low) Arrays -----
var float[] supPrices = array.new_float()
var int[] supIndices = array.new_int()
var float[] supVolumes = array.new_float()

// ----- Label Arrays for Management -----
var label[] resLabels = array.new_label()
var label[] supLabels = array.new_label()

// ----- Line Arrays for Management -----
var line[] resLines = array.new_line()
var line[] supLines = array.new_line()

// ----- Info Table -----
var table infoTable = table.new(
    position=position.top_right,
    columns=2,
    rows=6,
    bgcolor=color.rgb(0,0,0, 85),
    border_color=color.gray,
    border_width=1
)

// ----- Process Resistance (Swing High) -----
if not na(swingHigh)
    array.push(resPrices, swingHigh)
    array.push(resIndices, bar_index[autoBars])
    array.push(resVolumes, volume[autoBars])
    
    if array.size(resPrices) > maxSwingPoints
        array.remove(resPrices, 0)
        array.remove(resIndices, 0)
        array.remove(resVolumes, 0)

// ----- Process Support (Swing Low) -----
if not na(swingLow)
    array.push(supPrices, swingLow)
    array.push(supIndices, bar_index[autoBars])
    array.push(supVolumes, volume[autoBars])
    
    if array.size(supPrices) > maxSwingPoints
        array.remove(supPrices, 0)
        array.remove(supIndices, 0)
        array.remove(supVolumes, 0)

// ============================================================
// MODULE 5: Clean Up Old Labels and Lines
// ============================================================

// ----- Clean Resistance Labels -----
if array.size(resLabels) > 0
    for i = 0 to array.size(resLabels) - 1
        lbl = array.get(resLabels, i)
        if not na(lbl)
            label.delete(lbl)
array.clear(resLabels)

// ----- Clean Support Labels -----
if array.size(supLabels) > 0
    for i = 0 to array.size(supLabels) - 1
        lbl = array.get(supLabels, i)
        if not na(lbl)
            label.delete(lbl)
array.clear(supLabels)

// ----- Clean Resistance Lines -----
if array.size(resLines) > 0
    for i = 0 to array.size(resLines) - 1
        ln = array.get(resLines, i)
        if not na(ln)
            line.delete(ln)
array.clear(resLines)

// ----- Clean Support Lines -----
if array.size(supLines) > 0
    for i = 0 to array.size(supLines) - 1
        ln = array.get(supLines, i)
        if not na(ln)
            line.delete(ln)
array.clear(supLines)

// ============================================================
// MODULE 6: Draw Resistance Labels (with Price)
// ============================================================

if showLabels and array.size(resPrices) > 0
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
                x=idx,
                y=val,
                text="🔴 R: " + priceDisplay + "\n" + volDisplay + volMark,
                color=color.new(color.red, 65),
                textcolor=color.white,
                style=label.style_label_down,
                size=size.small,
                textalign=text.align_center
            )
            array.push(resLabels, lbl)

// ============================================================
// MODULE 7: Draw Support Labels (with Price)
// ============================================================

if showLabels and array.size(supPrices) > 0
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
                x=idx,
                y=val,
                text="🟢 S: " + priceDisplay + "\n" + volDisplay + volMark,
                color=color.new(color.green, 65),
                textcolor=color.white,
                style=label.style_label_up,
                size=size.small,
                textalign=text.align_center
            )
            array.push(supLabels, lbl)

// ============================================================
// MODULE 8: Horizontal Lines
// ============================================================

if showLines and array.size(resPrices) > 0
    for i = 0 to array.size(resPrices) - 1
        idx = array.get(resIndices, i)
        val = array.get(resPrices, i)
        
        if not na(idx) and not na(val)
            ln = line.new(
                x1=idx,
                y1=val,
                x2=idx + 10,
                y2=val,
                color=color.new(color.red, 20),
                style=line.style_dotted,
                width=1,
                extend=extend.none
            )
            array.push(resLines, ln)

if showLines and array.size(supPrices) > 0
    for i = 0 to array.size(supPrices) - 1
        idx = array.get(supIndices, i)
        val = array.get(supPrices, i)
        
        if not na(idx) and not na(val)
            ln = line.new(
                x1=idx,
                y1=val,
                x2=idx + 10,
                y2=val,
                color=color.new(color.green, 20),
                style=line.style_dotted,
                width=1,
                extend=extend.none
            )
            array.push(supLines, ln)

// ============================================================
// MODULE 9: Latest S/R Price Labels
// ============================================================

if barstate.islast
    // ----- Latest Resistance -----
    if array.size(resPrices) > 0
        lastIdx = array.size(resPrices) - 1
        idx = array.get(resIndices, lastIdx)
        val = array.get(resPrices, lastIdx)
        if not na(idx) and not na(val)
            label.new(
                x=bar_index + 2,
                y=val,
                text="R: " + str.tostring(val, "#.##"),
                color=color.rgb(255,0,0, 20),
                textcolor=color.new(color.white, 0),
                style=label.style_label_left,
                size=size.tiny
            )
    
    // ----- Latest Support -----
    if array.size(supPrices) > 0
        lastIdx = array.size(supPrices) - 1
        idx = array.get(supIndices, lastIdx)
        val = array.get(supPrices, lastIdx)
        if not na(idx) and not na(val)
            label.new(
                x=bar_index + 2,
                y=val,
                text="S: " + str.tostring(val, "#.##"),
                color=color.rgb(0,255,0, 20),
                textcolor=color.new(color.white, 0),
                style=label.style_label_left,
                size=size.tiny
            )

// ============================================================
// MODULE 10: Info Table (Top Right)
// ============================================================

if showTable
    resCount = array.size(resPrices)
    supCount = array.size(supPrices)
    totalLevels = resCount + supCount
    
    // Get Latest Resistance Price
    var string latestResPrice = "N/A"
    if resCount > 0
        lastIdx = resCount - 1
        val = array.get(resPrices, lastIdx)
        if not na(val)
            latestResPrice := str.tostring(val, "#.##")
        else
            latestResPrice := "N/A"
    
    // Get Latest Support Price
    var string latestSupPrice = "N/A"
    if supCount > 0
        lastIdx = supCount - 1
        val = array.get(supPrices, lastIdx)
        if not na(val)
            latestSupPrice := str.tostring(val, "#.##")
        else
            latestSupPrice := "N/A"
    
    // Count High Volume S/R Levels
    highVolRes = 0
    for i = 0 to resCount - 1
        vol = array.get(resVolumes, i)
        if not na(vol) and isHighVolume(vol, avgVolume, volumeThreshold)
            highVolRes := highVolRes + 1
    
    highVolSup = 0
    for i = 0 to supCount - 1
        vol = array.get(supVolumes, i)
        if not na(vol) and isHighVolume(vol, avgVolume, volumeThreshold)
            highVolSup := highVolSup + 1
    
    // ----- Fill Table -----
    // Title Row
    table.cell(infoTable, 0, 0, "📊 S/R Stats", text_color=color.white, bgcolor=color.rgb(20,40,80), text_size=size.small)
    table.cell(infoTable, 1, 0, "", text_color=color.white, bgcolor=color.rgb(20,40,80), text_size=size.small)
    
    // Total Levels
    table.cell(infoTable, 0, 1, "Total Levels", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(totalLevels), text_color=color.orange, text_size=size.small)
    
    // Resistance Count
    table.cell(infoTable, 0, 2, "🔴 Resistance", text_color=color.red, bgcolor=color.rgb(30,30,30), text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(resCount) + " (🔥" + str.tostring(highVolRes) + ")", text_color=color.white, text_size=size.small)
    
    // Support Count
    table.cell(infoTable, 0, 3, "🟢 Support", text_color=color.green, bgcolor=color.rgb(30,30,30), text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(supCount) + " (🔥" + str.tostring(highVolSup) + ")", text_color=color.white, text_size=size.small)
    
    // Latest Resistance
    table.cell(infoTable, 0, 4, "Latest R", text_color=color.red, bgcolor=color.rgb(30,30,30), text_size=size.small)
    table.cell(infoTable, 1, 4, latestResPrice, text_color=color.white, text_size=size.small)
    
    // Latest Support
    table.cell(infoTable, 0, 5, "Latest S", text_color=color.green, bgcolor=color.rgb(30,30,30), text_size=size.small)
    table.cell(infoTable, 1, 5, latestSupPrice, text_color=color.white, text_size=size.small)
````
