# Hybrid Round Numbers [LuxAlgo]

- url: https://www.tradingview.com/script/IRmO7qr3-Hybrid-Round-Numbers-LuxAlgo/
- type: indicator
- pine_id: PUB;1dfbcb1a6d1241508f7ea7a6d3fe1273
- version: 1.0

## Description

Smart Round Number Indicator (MES & MNQ)

This indicator highlights key psychological price levels and helps traders focus on where price is most likely to react—without cluttering the chart.

🔑 Core Features
Automatic Detection
Detects MES and MNQ automatically
Applies optimized spacing:
MES → 100 / 50 / 25
MNQ → 1000 / 500 / 100
🎯 Two Display Modes
1. Full Mode
Displays all Major, Medium, and Minor levels
Ideal for big-picture analysis and mapping liquidity zones
2. Proximity Mode (Scalping Focus)
Shows only the nearest levels above and below price
Reduces clutter for precision trading
🟦 Reaction Zones
Each level includes a shaded zone (customizable in ticks)
Represents areas where price is likely to:
react
reverse
consolidate
🚨 Two-Tier Alerts
Zone Touch: Price enters the reaction zone
Level Sweep: Price crosses the exact round number
🎨 Full Customization
Adjust:
spacing (auto or manual)
colors
line styles (solid, dashed, dotted)
line thickness
number of levels shown
Customize Major, Medium, and Minor levels independently
🧠 Smart Logic
Prevents overlapping levels
Automatically prioritizes Major levels over Medium
Keeps charts clean and readable
📍 Improved Visibility
Right-aligned labels and extended lines
Clean layout optimized for real-time decision-making
⚡ Best Use Case
Ideal for scalpers and intraday traders
Helps identify:
liquidity sweeps
reaction zones
high-probability entry and exit levels

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Hybrid Round Numbers [LuxAlgo]", shorttitle="Round Numbers Hybrid", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// --- Groups ---
string G_GEN = "General Settings"
string G_MAJ = "Major Levels"
string G_MED = "Medium Levels"
string G_MIN = "Minor Levels"
string G_ZON = "Reaction Zones (Proximity Mode)"

// --- General Inputs ---
string viewMode     = input.string("Full", "View Mode", options=["Full", "Proximity"], group=G_GEN, tooltip="Full: Shows all levels based on Count. Proximity: Only shows levels nearest to price with reaction zones.")
string spacingMode  = input.string("Auto", "Spacing Mode", options=["Auto", "Manual"], group=G_GEN, tooltip="Auto mode detects MNQ/MES and sets spacing accordingly.")
int lineRangeInput  = input.int(100, "Line Extension (Bars)", minval=1, group=G_GEN)
int levelsCountIn   = input.int(5, "Full Mode: Levels Count", minval=1, maxval=50, group=G_GEN, tooltip="Number of Major levels to show above and below price in Full mode.")
int proximityIn     = input.int(1, "Proximity Mode: Level Count", minval=1, maxval=5, group=G_GEN, tooltip="How many levels above/below to show in Proximity mode.")

// --- Spacing Inputs ---
float majorSpacingIn  = input.float(100.0, "Major Spacing", minval=0.0000001, group=G_MAJ)
float mediumSpacingIn = input.float(50.0, "Medium Spacing", minval=0.0000001, group=G_MED)
float minorSpacingIn  = input.float(25.0, "Minor Spacing", minval=0.0000001, group=G_MIN)

// --- Style Inputs ---
bool showMajor      = input.bool(true, "Show Major Levels", group=G_MAJ)
color majorColor    = input.color(color.new(#5b9cf6, 30), "Color", inline="maj", group=G_MAJ)
string majorStyle   = input.string(line.style_solid, "Style", options=[line.style_solid, line.style_dotted, line.style_dashed], inline="maj", group=G_MAJ)
int majorWidth      = input.int(2, "Width", minval=1, inline="maj", group=G_MAJ)

bool showMedium     = input.bool(true, "Show Medium Levels", group=G_MED)
color mediumColor   = input.color(color.new(#5b9cf6, 60), "Color", inline="med", group=G_MED)
string mediumStyle  = input.string(line.style_dashed, "Style", options=[line.style_solid, line.style_dotted, line.style_dashed], inline="med", group=G_MED)
int mediumWidth     = input.int(1, "Width", minval=1, inline="med", group=G_MED)

bool showMinor      = input.bool(true, "Show Minor Levels", group=G_MIN)
color minorColor    = input.color(color.new(#5b9cf6, 80), "Color", inline="min", group=G_MIN)
string minorStyle   = input.string(line.style_dotted, "Style", options=[line.style_solid, line.style_dotted, line.style_dashed], inline="min", group=G_MIN)
int minorWidth      = input.int(1, "Width", minval=1, inline="min", group=G_MIN)

// --- Reaction Zone Inputs ---
bool showZones      = input.bool(true, "Show Zones (Proximity Mode Only)", group=G_ZON)
float zoneTicks     = input.float(4.0, "Zone Size (Ticks)", minval=0, group=G_ZON)
color zoneColor     = input.color(color.new(#5b9cf6, 90), "Zone Color", group=G_ZON)

// --- Logic ---
bool isMNQ = str.contains(syminfo.ticker, "MNQ")
bool isMES = str.contains(syminfo.ticker, "MES")

float majorSpacing  = spacingMode == "Auto" ? (isMNQ ? 1000.0 : isMES ? 100.0 : majorSpacingIn) : majorSpacingIn
float mediumSpacing = spacingMode == "Auto" ? (isMNQ ? 500.0  : isMES ? 50.0  : mediumSpacingIn) : mediumSpacingIn
float minorSpacing  = spacingMode == "Auto" ? (isMNQ ? 100.0  : isMES ? 25.0  : minorSpacingIn) : minorSpacingIn

float zoneOffset = zoneTicks * syminfo.mintick

// --- Drawing Arrays ---
var line[] linesArray   = array.new_line()
var label[] labelsArray = array.new_label()
var box[] boxesArray    = array.new_box()

clearObjects() =>
    if array.size(linesArray) > 0
        for l in linesArray
            line.delete(l)
        array.clear(linesArray)
    if array.size(labelsArray) > 0
        for lb in labelsArray
            label.delete(lb)
        array.clear(labelsArray)
    if array.size(boxesArray) > 0
        for b in boxesArray
            box.delete(b)
        array.clear(boxesArray)

addLevel(float price, color col, string style, int width) =>
    int rightOffset = 50 // Extended to the right
    array.push(linesArray, line.new(bar_index - lineRangeInput, price, bar_index + rightOffset, price, color=col, style=style, width=width))
    array.push(labelsArray, label.new(bar_index + rightOffset, price, str.tostring(price, format.mintick), color=color.new(color.black, 100), textcolor=color.gray, style=label.style_label_left, size=size.small))
    if viewMode == "Proximity" and showZones
        array.push(boxesArray, box.new(bar_index - lineRangeInput, price + zoneOffset, bar_index + rightOffset, price - zoneOffset, bgcolor=zoneColor, border_color=color.new(col, 80)))

if barstate.islast
    clearObjects()
    float pivot = math.round(close / majorSpacing) * majorSpacing
    int count = viewMode == "Full" ? levelsCountIn : proximityIn
    
    // Major
    if showMajor
        for i = -count to count
            addLevel(pivot + (i * majorSpacing), majorColor, majorStyle, majorWidth)

    // Medium
    if showMedium
        int medRange = math.ceil(count * (majorSpacing / mediumSpacing))
        for i = -medRange to medRange
            float level = pivot + (i * mediumSpacing)
            bool isOverlappingMajor = math.abs(level / majorSpacing - math.round(level / majorSpacing)) < 0.0001
            bool inBounds = level <= pivot + (count * majorSpacing) and level >= pivot - (count * majorSpacing)
            if not (showMajor and isOverlappingMajor) and inBounds
                addLevel(level, mediumColor, mediumStyle, mediumWidth)

    // Minor (Only in Full Mode, or if specifically desired in Proximity)
    if showMinor
        int minRange = math.ceil(count * (majorSpacing / minorSpacing))
        for i = -minRange to minRange
            float level = pivot + (i * minorSpacing)
            bool isOverlappingMajor = math.abs(level / majorSpacing - math.round(level / majorSpacing)) < 0.0001
            bool isOverlappingMedium = math.abs(level / mediumSpacing - math.round(level / mediumSpacing)) < 0.0001
            bool inBounds = level <= pivot + (count * majorSpacing) and level >= pivot - (count * majorSpacing)
            if not ((showMajor and isOverlappingMajor) or (showMedium and isOverlappingMedium)) and inBounds
                addLevel(level, minorColor, minorStyle, minorWidth)

// --- Alerts ---
float nearestMajor  = math.round(close / majorSpacing) * majorSpacing
float nearestMedium = math.round(close / mediumSpacing) * mediumSpacing

if ta.cross(close, nearestMajor) and showMajor
    alert("Price crossed Major level: " + str.tostring(nearestMajor), alert.freq_once_per_bar)
if ta.cross(close, nearestMedium) and showMedium and math.abs(nearestMedium / majorSpacing - math.round(nearestMedium / majorSpacing)) > 0.0001
    alert("Price crossed Medium level: " + str.tostring(nearestMedium), alert.freq_once_per_bar)
````
