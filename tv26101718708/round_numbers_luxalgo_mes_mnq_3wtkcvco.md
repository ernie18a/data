# Round Numbers [LuxAlgo] MES MNQ

- url: https://www.tradingview.com/script/3wtkcvCO-Round-Numbers-LuxAlgo-MES-MNQ/
- type: indicator
- pine_id: PUB;5b69bd9e90354a0a8b05209f48eb51ef
- version: 1.0

## Description

highlights major, medium, and minor round numbers
lets you turn each group on or off
lets you change spacing
lets you customize color, style, and width
works differently for MNQ and MES if you want

The clean way is to make:

MES: 100, 50, 25
MNQ: 1000, 500, 100
or let you enter your own values manually.

What this does
Detects MES and MNQ automatically if you enable presets
Draws round-number lines above and below current price
Lets you customize:
spacing
colors
width
line style
labels
how many levels to show
Best default settings

For your style, I’d use:

MES
Major: 100
Medium: 50
Minor: 25
MNQ
Major: 1000
Medium: 500
Minor: 100

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Round Numbers [LuxAlgo]", shorttitle="Round Numbers", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Groups ---
string G_GEN = "General Settings"
string G_MAJ = "Major Levels"
string G_MED = "Medium Levels"
string G_MIN = "Minor Levels"
string G_LAB = "Labels"

// --- General Inputs ---
string modeInput    = input.string("Auto", "Mode", options=["Auto", "Manual"], group=G_GEN, tooltip="Auto mode detects MNQ/MES and sets spacing accordingly. Manual uses the inputs below.")
int lineRangeInput  = input.int(100, "Line Extension (Bars)", minval=1, group=G_GEN, tooltip="How many bars the lines extend into the past.")
int levelsCountIn   = input.int(5, "Levels Count (Above/Below)", minval=1, maxval=50, group=G_GEN, tooltip="Number of Major levels to show above and below the current price.")

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

// --- Label Inputs ---
bool showLabels     = input.bool(true, "Show Labels", group=G_LAB)
color labelColor    = input.color(color.gray, "Label Text Color", group=G_LAB)
string labelSize    = input.string(size.small, "Label Size", options=[size.tiny, size.small, size.normal], group=G_LAB)

// --- Logic ---
bool isMNQ = str.contains(syminfo.ticker, "MNQ")
bool isMES = str.contains(syminfo.ticker, "MES")

float majorSpacing  = modeInput == "Auto" ? (isMNQ ? 1000.0 : isMES ? 100.0 : majorSpacingIn) : majorSpacingIn
float mediumSpacing = modeInput == "Auto" ? (isMNQ ? 500.0  : isMES ? 50.0  : mediumSpacingIn) : mediumSpacingIn
float minorSpacing  = modeInput == "Auto" ? (isMNQ ? 100.0  : isMES ? 25.0  : minorSpacingIn) : minorSpacingIn

// --- Drawing Arrays ---
var line[] linesArray   = array.new_line()
var label[] labelsArray = array.new_label()

// Cleanup Function
clearObjects() =>
    if array.size(linesArray) > 0
        for l in linesArray
            line.delete(l)
        array.clear(linesArray)
    if array.size(labelsArray) > 0
        for lb in labelsArray
            label.delete(lb)
        array.clear(labelsArray)

// Draw Level Function
addLevel(float price, color col, string style, int width, string sz) =>
    array.push(linesArray, line.new(bar_index - lineRangeInput, price, bar_index + 10, price, color=col, style=style, width=width))
    if showLabels
        array.push(labelsArray, label.new(bar_index + 10, price, str.tostring(price, format.mintick), color=color.new(color.black, 100), textcolor=labelColor, style=label.style_label_left, size=sz))

// Core Logic on Last Bar
if barstate.islast
    clearObjects()
    
    float pivot = math.round(close / majorSpacing) * majorSpacing
    
    // Major Levels
    if showMajor
        for i = -levelsCountIn to levelsCountIn
            addLevel(pivot + (i * majorSpacing), majorColor, majorStyle, majorWidth, labelSize)

    // Medium Levels
    if showMedium
        int medRange = math.ceil(levelsCountIn * (majorSpacing / mediumSpacing))
        for i = -medRange to medRange
            float level = pivot + (i * mediumSpacing)
            bool isOverlappingMajor = math.abs(level / majorSpacing - math.round(level / majorSpacing)) < 0.0001
            bool inBounds = level <= pivot + (levelsCountIn * majorSpacing) and level >= pivot - (levelsCountIn * majorSpacing)
            if not (showMajor and isOverlappingMajor) and inBounds
                addLevel(level, mediumColor, mediumStyle, mediumWidth, labelSize)

    // Minor Levels
    if showMinor
        int minRange = math.ceil(levelsCountIn * (majorSpacing / minorSpacing))
        for i = -minRange to minRange
            float level = pivot + (i * minorSpacing)
            bool isOverlappingMajor = math.abs(level / majorSpacing - math.round(level / majorSpacing)) < 0.0001
            bool isOverlappingMedium = math.abs(level / mediumSpacing - math.round(level / mediumSpacing)) < 0.0001
            bool inBounds = level <= pivot + (levelsCountIn * majorSpacing) and level >= pivot - (levelsCountIn * majorSpacing)
            if not ((showMajor and isOverlappingMajor) or (showMedium and isOverlappingMedium)) and inBounds
                addLevel(level, minorColor, minorStyle, minorWidth, labelSize)

// --- Alerts ---
float nearestMajor  = math.round(close / majorSpacing) * majorSpacing
float nearestMedium = math.round(close / mediumSpacing) * mediumSpacing
float nearestMinor  = math.round(close / minorSpacing) * minorSpacing

if ta.cross(close, nearestMajor) and showMajor
    alert("Price crossed Major Round Number: " + str.tostring(nearestMajor), alert.freq_once_per_bar)
if ta.cross(close, nearestMedium) and showMedium and math.abs(nearestMedium / majorSpacing - math.round(nearestMedium / majorSpacing)) > 0.0001
    alert("Price crossed Medium Round Number: " + str.tostring(nearestMedium), alert.freq_once_per_bar)
if ta.cross(close, nearestMinor) and showMinor and math.abs(nearestMinor / mediumSpacing - math.round(nearestMinor / mediumSpacing)) > 0.0001
    alert("Price crossed Minor Round Number: " + str.tostring(nearestMinor), alert.freq_once_per_bar)
````
