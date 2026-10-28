# ATK/DEF S/R Pivot Levels 

- url: https://www.tradingview.com/script/U2U6UdiI/
- type: indicator
- pine_id: PUB;7039343b839c4eca9e8026ad55b520b3
- version: 1.0

## Description

# Pivot Levels S/R 

## Overview

Pivot Levels Table is a market structure visualization tool designed to display important Pivot-based support and resistance reference levels with additional volume context.

The indicator automatically detects recent Pivot Highs and Pivot Lows, displays multiple historical levels, and provides volume information around each level to help users analyze market structure and price reaction areas.

## Features

### 📌 Multi-Timeframe Pivot Levels

* Select different timeframes from 1 minute to Monthly.
* Autor calculates Pivot High and Pivot Low levels.
* Displays recent Resistance (R1/R2/R3) and Support (S1/S2/S3) areas.
* Helps visualize important historical price reference zones.

### 📊 Volume Radar

Each Pivot level includes volume information:

* Volume comparison against average volume.
* Relative volume ratio display.
* Volume intensity classification:

  * Very Low
  * Low
  * Medium
  * Above Average
  * High
  * Extreme

This provides additional context about market participation near historical levels.

### 📈 Pivot Volume Analysis

The indicator records volume information when Pivot points are formed.

Users can compare:

* Pivot location
* Price level
* Volume activity
* Relative volume strength

to better understand historical market behavior.

### 📋 Information Table

The dashboard displays:

* Current timeframe
* Current price reference
* Current volume condition
* Volume radar status
* Resistance levels
* Support levels
* Volume information for each Pivot level

### ⚙️ Customization

Available settings:

* Pivot sensitivity (Left / Right)
* Timeframe selection
* Label visibility
* Table scaling
* Background opacity
* Display preferences

## How It Works

Pivot points are identified using the built-in Pivot High and Pivot Low methodology.

Volume information is calculated by comparing current volume with the average volume over recent periods.

The indicator does not generate trading signals or provide trading recommendations. It is designed as a visual analysis tool to help users study price structure and volume behavior.

## Suggested Usage

This tool can be combined with:

* Price Action analysis
* Market structure analysis
* Support and resistance studies
* Volume analysis
* Multi-timeframe chart review

## Important Note

Pivot levels are historical reference points and do not guarantee future price reactions.

Market conditions, volatility, liquidity, and other factors should always be considered when interpreting chart information.

This script is intended for educational and analytical purposes only.

## Source Code

````pine
//@version=6
indicator("Pivot Levels Table", overlay=true, precision=2)

// ========== Parameters ==========
left = input.int(5, "Left")
right = input.int(5, "Right")
showLabels = input.bool(true, "Show Pivot Price Labels")

// ========== Timeframe Selection ==========
timeframeType = input.string("Daily", "Timeframe", options=["1min", "5min", "15min", "30min", "1h", "4h", "Daily", "Weekly", "Monthly"], tooltip="Select timeframe to display")

// ========== Table Size Control ==========
tableScale = input.float(1.0, "Table Scale", minval=0.5, maxval=2.0, step=0.1, tooltip="Table overall scale")
tableWidth = input.int(2, "Table Border Width", minval=1, maxval=5, step=1, tooltip="Table border width")
tableBgOpacity = input.int(92, "Background Opacity", minval=50, maxval=100, step=1, tooltip="Background opacity (50-100)")

// ========== Get Current Chart Timeframe ==========
currentTF = timeframe.period

// ========== Convert Timeframe to Display Name ==========
tfDisplay = currentTF
if currentTF == "1"
    tfDisplay := "1min"
else if currentTF == "5"
    tfDisplay := "5min"
else if currentTF == "15"
    tfDisplay := "15min"
else if currentTF == "30"
    tfDisplay := "30min"
else if currentTF == "60"
    tfDisplay := "1h"
else if currentTF == "240"
    tfDisplay := "4h"
else if currentTF == "D"
    tfDisplay := "Daily"
else if currentTF == "W"
    tfDisplay := "Weekly"
else if currentTF == "M"
    tfDisplay := "Monthly"
else
    tfDisplay := currentTF

// ========== Convert Timeframe String ==========
selectedTimeframe = timeframe.period
if timeframeType == "1min"
    selectedTimeframe := "1"
else if timeframeType == "5min"
    selectedTimeframe := "5"
else if timeframeType == "15min"
    selectedTimeframe := "15"
else if timeframeType == "30min"
    selectedTimeframe := "30"
else if timeframeType == "1h"
    selectedTimeframe := "60"
else if timeframeType == "4h"
    selectedTimeframe := "240"
else if timeframeType == "Daily"
    selectedTimeframe := "D"
else if timeframeType == "Weekly"
    selectedTimeframe := "W"
else if timeframeType == "Monthly"
    selectedTimeframe := "M"

// ========== Get Data from Selected Timeframe ==========
[htfHigh, htfLow, htfClose, htfVolume] = request.security(syminfo.tickerid, selectedTimeframe, [high, low, close, volume], lookahead=barmerge.lookahead_off)

// ========== Calculate Volume Metrics ==========
htfAvgVolume = ta.sma(htfVolume, 20)
htfVolRatio = htfAvgVolume > 0 ? htfVolume / htfAvgVolume : 0

// Current Volume Status
volStatus = ""
volColor = color.white
if htfVolRatio > 2.0
    volStatus := "🔥 EXTREME"
    volColor := color.rgb(255,100,100)
else if htfVolRatio > 1.5
    volStatus := "📈 HIGH"
    volColor := color.rgb(255,180,100)
else if htfVolRatio > 1.0
    volStatus := "📊 ABOVE AVG"
    volColor := color.rgb(200,200,100)
else if htfVolRatio > 0.7
    volStatus := "📉 BELOW AVG"
    volColor := color.rgb(150,150,200)
else
    volStatus := "❄️ LOW"
    volColor := color.rgb(100,150,200)

// ========== Volume Radar ==========
radarDisplay = ""
radarColor = color.white
if htfVolRatio > 2.5
    radarDisplay := "🔴 EXTREME"
    radarColor := color.rgb(255,0,0)
else if htfVolRatio > 1.8
    radarDisplay := "🟠 HIGH"
    radarColor := color.rgb(255,150,0)
else if htfVolRatio > 1.2
    radarDisplay := "🟡 ABOVE"
    radarColor := color.rgb(255,200,0)
else if htfVolRatio > 0.8
    radarDisplay := "🟢 MEDIUM"
    radarColor := color.rgb(100,255,100)
else if htfVolRatio > 0.5
    radarDisplay := "🔵 LOW"
    radarColor := color.rgb(100,150,255)
else
    radarDisplay := "⚪ VERY LOW"
    radarColor := color.rgb(150,150,200)

// ========== Get Radar Display for Each Pivot ==========
getRadarDisplay(vol) =>
    if na(vol) or htfAvgVolume <= 0
        "N/A"
    else
        ratio = vol / htfAvgVolume
        if ratio > 2.5
            "🔴 EXTREME"
        else if ratio > 1.8
            "🟠 HIGH"
        else if ratio > 1.2
            "🟡 ABOVE"
        else if ratio > 0.8
            "🟢 MEDIUM"
        else if ratio > 0.5
            "🔵 LOW"
        else
            "⚪ VERY LOW"

getRadarColor(vol) =>
    if na(vol) or htfAvgVolume <= 0
        color.white
    else
        ratio = vol / htfAvgVolume
        if ratio > 2.5
            color.rgb(255,0,0)
        else if ratio > 1.8
            color.rgb(255,150,0)
        else if ratio > 1.2
            color.rgb(255,200,0)
        else if ratio > 0.8
            color.rgb(100,255,100)
        else if ratio > 0.5
            color.rgb(100,150,255)
        else
            color.rgb(150,150,200)

// ========== Store Last 3 Pivots ==========
var float r1 = na
var float r2 = na
var float r3 = na
var float s1 = na
var float s2 = na
var float s3 = na

// Pivot Volume & Average Volume
var float r1Vol = na
var float r2Vol = na
var float r3Vol = na
var float s1Vol = na
var float s2Vol = na
var float s3Vol = na

var float r1AvgVol = na
var float r2AvgVol = na
var float r3AvgVol = na
var float s1AvgVol = na
var float s2AvgVol = na
var float s3AvgVol = na

// ========== Calculate Pivots ==========
ph = ta.pivothigh(htfHigh, left, right)
pl = ta.pivotlow(htfLow, left, right)

// ========== Get Volume at Pivot ==========
phVol = ta.valuewhen(not na(ph), htfVolume, 0)
phAvgVol = ta.valuewhen(not na(ph), htfAvgVolume, 0)
plVol = ta.valuewhen(not na(pl), htfVolume, 0)
plAvgVol = ta.valuewhen(not na(pl), htfAvgVolume, 0)

// ========== Update Pivot High ==========
if not na(ph)
    r3 := r2
    r2 := r1
    r1 := ph
    
    r3Vol := r2Vol
    r2Vol := r1Vol
    r1Vol := phVol
    
    r3AvgVol := r2AvgVol
    r2AvgVol := r1AvgVol
    r1AvgVol := phAvgVol

// ========== Update Pivot Low ==========
if not na(pl)
    s3 := s2
    s2 := s1
    s1 := pl
    
    s3Vol := s2Vol
    s2Vol := s1Vol
    s1Vol := plVol
    
    s3AvgVol := s2AvgVol
    s2AvgVol := s1AvgVol
    s1AvgVol := plAvgVol

// ========== Format Volume ==========
formatVol(vol) =>
    if na(vol) or vol <= 0
        "N/A"
    else if vol >= 1000000
        str.tostring(vol / 1000000, "#.##") + "M"
    else if vol >= 1000
        str.tostring(vol / 1000, "#.#") + "K"
    else
        str.tostring(vol, "0")

// ========== Get Volume Status ==========
getVolStatus(vol, avgVol) =>
    if na(vol) or na(avgVol) or avgVol <= 0
        "N/A"
    else
        ratio = vol / avgVol
        if ratio > 2.0
            "🔥"
        else if ratio > 1.5
            "📈"
        else if ratio > 1.0
            "📊"
        else if ratio > 0.7
            "📉"
        else
            "❄️"

// ========== Line/Label Reuse ==========
var line r1Line = na, var line r2Line = na, var line r3Line = na
var line s1Line = na, var line s2Line = na, var line s3Line = na
var label r1Label = na, var label r2Label = na, var label r3Label = na
var label s1Label = na, var label s2Label = na, var label s3Label = na
var label pivotLabel = na

// ========== Show Pivot Price Labels ==========
if showLabels
    if not na(ph)
        labelText = "R1: " + str.tostring(ph, "#.##")
        if ph == r1 and not na(r1)
            labelText := "R1: " + str.tostring(r1, "#.##")
        else if ph == r2 and not na(r2)
            labelText := "R2: " + str.tostring(r2, "#.##")
        else if ph == r3 and not na(r3)
            labelText := "R3: " + str.tostring(r3, "#.##")
        else
            labelText := "R: " + str.tostring(ph, "#.##")
        
        if not na(pivotLabel)
            label.delete(pivotLabel)
        pivotLabel := label.new(bar_index[right], ph, 
                  text=labelText, 
                  style=label.style_label_down, 
                  color=color.new(color.red, 85), 
                  textcolor=color.white, 
                  size=size.small)
    
    if not na(pl)
        labelText = "S1: " + str.tostring(pl, "#.##")
        if pl == s1 and not na(s1)
            labelText := "S1: " + str.tostring(s1, "#.##")
        else if pl == s2 and not na(s2)
            labelText := "S2: " + str.tostring(s2, "#.##")
        else if pl == s3 and not na(s3)
            labelText := "S3: " + str.tostring(s3, "#.##")
        else
            labelText := "S: " + str.tostring(pl, "#.##")
        
        if not na(pivotLabel)
            label.delete(pivotLabel)
        pivotLabel := label.new(bar_index[right], pl, 
                  text=labelText, 
                  style=label.style_label_up, 
                  color=color.new(color.green, 85), 
                  textcolor=color.white, 
                  size=size.small)

// ========== Draw on Last Bar ==========
if barstate.islast
    int len = 5
    int x2 = bar_index + len
    
    // ----- R1 -----
    if not na(r1)
        if na(r1Line)
            r1Line := line.new(bar_index, r1, x2, r1, color=color.red, width=2, style=line.style_dashed)
        else
            line.set_xy1(r1Line, bar_index, r1)
            line.set_xy2(r1Line, x2, r1)
            line.set_color(r1Line, color.red)
            line.set_width(r1Line, 2)
            line.set_style(r1Line, line.style_dashed)
        if na(r1Label)
            r1Label := label.new(x2, r1, text="R1", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        else
            label.set_xy(r1Label, x2, r1)
            label.set_text(r1Label, "R1")
            label.set_color(r1Label, color.red)
    
    // ----- R2 -----
    if not na(r2)
        if na(r2Line)
            r2Line := line.new(bar_index, r2, x2, r2, color=color.red, width=1, style=line.style_dashed)
        else
            line.set_xy1(r2Line, bar_index, r2)
            line.set_xy2(r2Line, x2, r2)
            line.set_color(r2Line, color.red)
            line.set_width(r2Line, 1)
            line.set_style(r2Line, line.style_dashed)
        if na(r2Label)
            r2Label := label.new(x2, r2, text="R2", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        else
            label.set_xy(r2Label, x2, r2)
            label.set_text(r2Label, "R2")
            label.set_color(r2Label, color.red)
    
    // ----- R3 -----
    if not na(r3)
        if na(r3Line)
            r3Line := line.new(bar_index, r3, x2, r3, color=color.red, width=1, style=line.style_dashed)
        else
            line.set_xy1(r3Line, bar_index, r3)
            line.set_xy2(r3Line, x2, r3)
            line.set_color(r3Line, color.red)
            line.set_width(r3Line, 1)
            line.set_style(r3Line, line.style_dashed)
        if na(r3Label)
            r3Label := label.new(x2, r3, text="R3", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        else
            label.set_xy(r3Label, x2, r3)
            label.set_text(r3Label, "R3")
            label.set_color(r3Label, color.red)
    
    // ----- S1 -----
    if not na(s1)
        if na(s1Line)
            s1Line := line.new(bar_index, s1, x2, s1, color=color.green, width=2, style=line.style_dashed)
        else
            line.set_xy1(s1Line, bar_index, s1)
            line.set_xy2(s1Line, x2, s1)
            line.set_color(s1Line, color.green)
            line.set_width(s1Line, 2)
            line.set_style(s1Line, line.style_dashed)
        if na(s1Label)
            s1Label := label.new(x2, s1, text="S1", color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        else
            label.set_xy(s1Label, x2, s1)
            label.set_text(s1Label, "S1")
            label.set_color(s1Label, color.green)
    
    // ----- S2 -----
    if not na(s2)
        if na(s2Line)
            s2Line := line.new(bar_index, s2, x2, s2, color=color.green, width=1, style=line.style_dashed)
        else
            line.set_xy1(s2Line, bar_index, s2)
            line.set_xy2(s2Line, x2, s2)
            line.set_color(s2Line, color.green)
            line.set_width(s2Line, 1)
            line.set_style(s2Line, line.style_dashed)
        if na(s2Label)
            s2Label := label.new(x2, s2, text="S2", color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        else
            label.set_xy(s2Label, x2, s2)
            label.set_text(s2Label, "S2")
            label.set_color(s2Label, color.green)
    
    // ----- S3 -----
    if not na(s3)
        if na(s3Line)
            s3Line := line.new(bar_index, s3, x2, s3, color=color.green, width=1, style=line.style_dashed)
        else
            line.set_xy1(s3Line, bar_index, s3)
            line.set_xy2(s3Line, x2, s3)
            line.set_color(s3Line, color.green)
            line.set_width(s3Line, 1)
            line.set_style(s3Line, line.style_dashed)
        if na(s3Label)
            s3Label := label.new(x2, s3, text="S3", color=color.green, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        else
            label.set_xy(s3Label, x2, s3)
            label.set_text(s3Label, "S3")
            label.set_color(s3Label, color.green)
    
    // ============================================================
    // Table
    // ============================================================
    var table myTable = na
    if not na(myTable)
        table.delete(myTable)
    
    bgMain = color.rgb(10,10,30, tableBgOpacity)
    bgHeader = color.rgb(30,50,120, math.min(100, tableBgOpacity + 8))
    bgSubHeader = color.rgb(40,40,70, math.min(100, tableBgOpacity + 5))
    bgRow = color.rgb(18,20,40, math.min(100, tableBgOpacity - 2))
    bgRowAlt = color.rgb(25,28,50, math.min(100, tableBgOpacity - 2))
    
    textSizeMain = size.normal
    if tableScale >= 1.5
        textSizeMain := size.large
    else if tableScale >= 1.0
        textSizeMain := size.normal
    else
        textSizeMain := size.small
    
    borderW = math.round(tableWidth * tableScale)
    borderW := math.max(1, math.min(5, borderW))
    
    myTable := table.new(position.top_right, 4, 12, 
                         bgcolor=bgMain, 
                         border_color=color.rgb(80,80,150, 60), 
                         border_width=borderW,
                         frame_color=color.rgb(50,50,120, 70),
                         frame_width=borderW)
    
    // ----- Header -----
    table.cell(myTable, 0, 0, "⚡ PIVOT TABLE", 
               text_color=color.rgb(255,215,100), 
               bgcolor=bgHeader, 
               text_size=textSizeMain, 
               text_halign=text.align_center)
    table.cell(myTable, 1, 0, "", 
               text_color=color.white, 
               bgcolor=bgHeader, 
               text_size=textSizeMain)
    table.cell(myTable, 2, 0, "", 
               text_color=color.white, 
               bgcolor=bgHeader, 
               text_size=textSizeMain)
    table.cell(myTable, 3, 0, "", 
               text_color=color.white, 
               bgcolor=bgHeader, 
               text_size=textSizeMain)
    
    // ----- Info Row -----
    table.cell(myTable, 0, 1, "📊 Timeframe", 
               text_color=color.rgb(180,200,255), 
               bgcolor=bgSubHeader, 
               text_size=textSizeMain)
    table.cell(myTable, 1, 1, tfDisplay, 
               text_color=color.rgb(200,220,255), 
               bgcolor=bgSubHeader, 
               text_size=textSizeMain)
    table.cell(myTable, 2, 1, "📡 Radar", 
               text_color=color.rgb(100,255,218), 
               bgcolor=bgSubHeader, 
               text_size=textSizeMain)
    table.cell(myTable, 3, 1, radarDisplay + " " + str.tostring(htfVolRatio, "#.##") + "x", 
               text_color=radarColor, 
               bgcolor=bgSubHeader, 
               text_size=textSizeMain)
    
    // ----- Column Headers -----
    table.cell(myTable, 0, 2, "Level", 
               text_color=color.rgb(255,200,100), 
               bgcolor=color.rgb(50,50,90), 
               text_size=textSizeMain, 
               text_halign=text.align_center)
    table.cell(myTable, 1, 2, "Price", 
               text_color=color.rgb(255,200,100), 
               bgcolor=color.rgb(50,50,90), 
               text_size=textSizeMain, 
               text_halign=text.align_center)
    table.cell(myTable, 2, 2, "Volume", 
               text_color=color.rgb(255,200,100), 
               bgcolor=color.rgb(50,50,90), 
               text_size=textSizeMain, 
               text_halign=text.align_center)
    table.cell(myTable, 3, 2, "Radar", 
               text_color=color.rgb(255,200,100), 
               bgcolor=color.rgb(50,50,90), 
               text_size=textSizeMain, 
               text_halign=text.align_center)
    
    // ----- Data Rows -----
    // R1
    table.cell(myTable, 0, 3, "R1", text_color=color.rgb(255,120,120), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 1, 3, not na(r1) ? str.tostring(r1, "#.##") : "N/A", text_color=color.white, bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 2, 3, not na(r1Vol) ? formatVol(r1Vol) + " " + getVolStatus(r1Vol, r1AvgVol) : "N/A", text_color=color.rgb(150,220,255), bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 3, 3, not na(r1Vol) ? getRadarDisplay(r1Vol) : "N/A", text_color=getRadarColor(r1Vol), bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    
    // R2
    table.cell(myTable, 0, 4, "R2", text_color=color.rgb(255,120,120), bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 1, 4, not na(r2) ? str.tostring(r2, "#.##") : "N/A", text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 2, 4, not na(r2Vol) ? formatVol(r2Vol) + " " + getVolStatus(r2Vol, r2AvgVol) : "N/A", text_color=color.rgb(150,220,255), bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 3, 4, not na(r2Vol) ? getRadarDisplay(r2Vol) : "N/A", text_color=getRadarColor(r2Vol), bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    
    // R3
    table.cell(myTable, 0, 5, "R3", text_color=color.rgb(255,120,120), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 1, 5, not na(r3) ? str.tostring(r3, "#.##") : "N/A", text_color=color.white, bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 2, 5, not na(r3Vol) ? formatVol(r3Vol) + " " + getVolStatus(r3Vol, r3AvgVol) : "N/A", text_color=color.rgb(150,220,255), bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 3, 5, not na(r3Vol) ? getRadarDisplay(r3Vol) : "N/A", text_color=getRadarColor(r3Vol), bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    
    // Separator
    table.cell(myTable, 0, 6, "──────", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain, text_halign=text.align_center)
    table.cell(myTable, 1, 6, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    table.cell(myTable, 2, 6, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    table.cell(myTable, 3, 6, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    
    // S1
    table.cell(myTable, 0, 7, "S1", text_color=color.rgb(120,255,120), bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 1, 7, not na(s1) ? str.tostring(s1, "#.##") : "N/A", text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 2, 7, not na(s1Vol) ? formatVol(s1Vol) + " " + getVolStatus(s1Vol, s1AvgVol) : "N/A", text_color=color.rgb(150,220,255), bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 3, 7, not na(s1Vol) ? getRadarDisplay(s1Vol) : "N/A", text_color=getRadarColor(s1Vol), bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    
    // S2
    table.cell(myTable, 0, 8, "S2", text_color=color.rgb(120,255,120), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 1, 8, not na(s2) ? str.tostring(s2, "#.##") : "N/A", text_color=color.white, bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 2, 8, not na(s2Vol) ? formatVol(s2Vol) + " " + getVolStatus(s2Vol, s2AvgVol) : "N/A", text_color=color.rgb(150,220,255), bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 3, 8, not na(s2Vol) ? getRadarDisplay(s2Vol) : "N/A", text_color=getRadarColor(s2Vol), bgcolor=bgRow, text_size=textSizeMain, text_halign=text.align_right)
    
    // S3
    table.cell(myTable, 0, 9, "S3", text_color=color.rgb(120,255,120), bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 1, 9, not na(s3) ? str.tostring(s3, "#.##") : "N/A", text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 2, 9, not na(s3Vol) ? formatVol(s3Vol) + " " + getVolStatus(s3Vol, s3AvgVol) : "N/A", text_color=color.rgb(150,220,255), bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 3, 9, not na(s3Vol) ? getRadarDisplay(s3Vol) : "N/A", text_color=getRadarColor(s3Vol), bgcolor=bgRowAlt, text_size=textSizeMain, text_halign=text.align_right)
    
    // Separator
    table.cell(myTable, 0, 10, "──────", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain, text_halign=text.align_center)
    table.cell(myTable, 1, 10, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    table.cell(myTable, 2, 10, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    table.cell(myTable, 3, 10, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    
    // Current Price
    table.cell(myTable, 0, 11, "💰 Current", text_color=color.rgb(255,215,0), bgcolor=color.rgb(40,40,20), text_size=textSizeMain)
    table.cell(myTable, 1, 11, str.tostring(htfClose, "#.##"), text_color=color.rgb(255,215,0), bgcolor=color.rgb(40,40,20), text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 2, 11, volStatus, text_color=volColor, bgcolor=color.rgb(40,40,20), text_size=textSizeMain, text_halign=text.align_right)
    table.cell(myTable, 3, 11, radarDisplay, text_color=radarColor, bgcolor=color.rgb(40,40,20), text_size=textSizeMain, text_halign=text.align_right)
````
