# Tertiary Pivot Structural Zones 

- url: https://www.tradingview.com/script/GnkERUKj-Tertiary-Pivot-Structural-Zones/
- type: indicator
- pine_id: PUB;e05ab71c270a4a33872af22d07680075
- version: 7.0

## Description

Support and Resistance zones using Adam Grimes Tertiary Pivot concept.

## Source Code

````pine
//@version=6
indicator("Tertiary Pivot Zones", shorttitle="Tertiary Pivot Zones", overlay=true, max_boxes_count=100, max_lines_count=150, max_labels_count=500)

// --- Inputs ---
leftBars        = input.int(1, "Pivot Left Hand Strength", minval=1)
rightBars       = input.int(1, "Pivot Right Hand Strength", minval=1)
showFirstOrder  = input.bool(true, "Show Minor (1st Order) Points?")
showSecondOrder = input.bool(true, "Show Intermediate (2nd Order) Points?")

boxThicknessMult = input.float(0.4, "Zone Box Thickness (ATR Mult)", minval=0.1, step=0.1)
mergeSensitivity = input.float(1.2, "Zone Merge Sensitivity (ATR Mult)", minval=0.1, step=0.1)

// --- Step 1: Calculate Base (1st Order) Pivots (CUSTOM INCLUSIVE ENGINE) ---
float pHi1 = na
bool isPH = true
for i = 1 to leftBars
    if high[rightBars] < high[rightBars + i]
        isPH := false
        break
for i = 0 to rightBars - 1
    if high[rightBars] < high[i]
        isPH := false
        break
if isPH
    pHi1 := high[rightBars]

float pLo1 = na
bool isPL = true
for i = 1 to leftBars
    if low[rightBars] > low[rightBars + i]
        isPL := false
        break
for i = 0 to rightBars - 1
    if low[rightBars] > low[i]
        isPL := false
        break
if isPL
    pLo1 := low[rightBars]

var float[] hi1_vals = array.new_float(0)
var int[]   hi1_idxs = array.new_int(0)
var float[] lo1_vals = array.new_float(0)
var int[]   lo1_idxs = array.new_int(0)

if not na(pHi1)
    array.push(hi1_vals, pHi1)
    array.push(hi1_idxs, bar_index - rightBars)
if not na(pLo1)
    array.push(lo1_vals, pLo1)
    array.push(lo1_idxs, bar_index - rightBars)

// --- Step 2: Calculate Second-Order Pivots (Tie-Breaker Math) ---
var float[] hi2_vals = array.new_float(0)
var int[]   hi2_idxs = array.new_int(0)
var float[] lo2_vals = array.new_float(0)
var int[]   lo2_idxs = array.new_int(0)

bool isSecondOrderHi = false
bool isSecondOrderLo = false

int secondHiIdx = na
float secondHiVal = na
int secondLoIdx = na
float secondLoVal = na

if not na(pHi1) and array.size(hi1_vals) >= 3
    int sz = array.size(hi1_vals)
    if array.get(hi1_vals, sz - 2) >= array.get(hi1_vals, sz - 3) and array.get(hi1_vals, sz - 2) > array.get(hi1_vals, sz - 1)
        isSecondOrderHi := true
        secondHiVal := array.get(hi1_vals, sz - 2)
        secondHiIdx := array.get(hi1_idxs, sz - 2)
        array.push(hi2_vals, secondHiVal)
        array.push(hi2_idxs, secondHiIdx)

if not na(pLo1) and array.size(lo1_vals) >= 3
    int sz = array.size(lo1_vals)
    if array.get(lo1_vals, sz - 2) <= array.get(lo1_vals, sz - 3) and array.get(lo1_vals, sz - 2) < array.get(lo1_vals, sz - 1)
        isSecondOrderLo := true
        secondLoVal := array.get(lo1_vals, sz - 2)
        secondLoIdx := array.get(lo1_idxs, sz - 2)
        array.push(lo2_vals, secondLoVal)
        array.push(lo2_idxs, secondLoIdx)

// --- Step 3: Calculate Tertiary (3rd Order) Pivots (Tie-Breaker Math) ---
bool isTertiaryHi = false
bool isTertiaryLo = false

int tertiaryHiIdx = na
float tertiaryHiVal = na
int tertiaryLoIdx = na
float tertiaryLoVal = na

if isSecondOrderHi and array.size(hi2_vals) >= 3
    int sz2 = array.size(hi2_vals)
    if array.get(hi2_vals, sz2 - 2) >= array.get(hi2_vals, sz2 - 3) and array.get(hi2_vals, sz2 - 2) > array.get(hi2_vals, sz2 - 1)
        isTertiaryHi := true
        tertiaryHiVal := array.get(hi2_vals, sz2 - 2)
        tertiaryHiIdx := array.get(hi2_idxs, sz2 - 2)

if isSecondOrderLo and array.size(lo2_vals) >= 3
    int sz2 = array.size(lo2_vals)
    if array.get(lo2_vals, sz2 - 2) <= array.get(lo2_vals, sz2 - 3) and array.get(lo2_vals, sz2 - 2) < array.get(lo2_vals, sz2 - 1)
        isTertiaryLo := true
        tertiaryLoVal := array.get(lo2_vals, sz2 - 2)
        tertiaryLoIdx := array.get(lo2_idxs, sz2 - 2)

// --- Step 4: Visual Plotting Engine ---
plotshape(showFirstOrder and not na(pHi1), title="1st Order High", style=shape.circle, location=location.abovebar, color=color.gray, size=size.tiny, offset=-rightBars)
plotshape(showFirstOrder and not na(pLo1), title="1st Order Low", style=shape.circle, location=location.belowbar, color=color.gray, size=size.tiny, offset=-rightBars)

if isSecondOrderHi and showSecondOrder
    label.new(x=secondHiIdx, y=secondHiVal, text="", xloc=xloc.bar_index, yloc=yloc.price, color=color.orange, style=label.style_triangledown, size=size.small)

if isSecondOrderLo and showSecondOrder
    label.new(x=secondLoIdx, y=secondLoVal, text="", xloc=xloc.bar_index, yloc=yloc.price, color=color.orange, style=label.style_triangleup, size=size.small)

if isTertiaryHi
    label.new(x=tertiaryHiIdx, y=tertiaryHiVal, text="", xloc=xloc.bar_index, yloc=yloc.price, color=color.red, style=label.style_circle, size=size.small)

if isTertiaryLo
    label.new(x=tertiaryLoIdx, y=tertiaryLoVal, text="", xloc=xloc.bar_index, yloc=yloc.price, color=color.green, style=label.style_circle, size=size.small)

// --- Step 5: Dynamic Box & Ledger Infrastructure (Active Zone Merging) ---
var box[] activeResistanceBoxes = array.new_box(0)
var box[] activeSupportBoxes    = array.new_box(0)

float zoneBuffer       = ta.atr(14) * boxThicknessMult
float proximityBuffer  = ta.atr(14) * mergeSensitivity

if isTertiaryHi
    bool absorbed = false
    if array.size(activeResistanceBoxes) > 0
        for i = array.size(activeResistanceBoxes) - 1 to 0 by 1
            box b = array.get(activeResistanceBoxes, i)
            float topLevel = box.get_top(b)
            float bottomLevel = box.get_bottom(b)
            
            float newTop = tertiaryHiVal
            float newBottom = tertiaryHiVal - zoneBuffer
            
            if newTop >= (bottomLevel - proximityBuffer) and newBottom <= (topLevel + proximityBuffer)
                box.set_top(b, math.max(topLevel, newTop))
                box.set_bottom(b, math.min(bottomLevel, newBottom))
                absorbed := true
                break
                
    if not absorbed
        box resBox = box.new(left=tertiaryHiIdx, top=tertiaryHiVal, right=bar_index, bottom=tertiaryHiVal - zoneBuffer,
          bgcolor=color.new(color.red, 92), border_color=color.new(color.red, 50), border_style=line.style_solid)
        array.push(activeResistanceBoxes, resBox)

if isTertiaryLo
    bool absorbed = false
    if array.size(activeSupportBoxes) > 0
        for i = array.size(activeSupportBoxes) - 1 to 0 by 1
            box b = array.get(activeSupportBoxes, i)
            float topLevel = box.get_top(b)
            float bottomLevel = box.get_bottom(b)
            
            float newTop = tertiaryLoVal + zoneBuffer
            float newBottom = tertiaryLoVal
            
            if newTop >= (bottomLevel - proximityBuffer) and newBottom <= (topLevel + proximityBuffer)
                box.set_top(b, math.max(topLevel, newTop))
                box.set_bottom(b, math.min(bottomLevel, newBottom))
                absorbed := true
                break
                
    if not absorbed
        box supBox = box.new(left=tertiaryLoIdx, top=tertiaryLoVal + zoneBuffer, right=bar_index, bottom=tertiaryLoVal,
          bgcolor=color.new(color.green, 92), border_color=color.new(color.green, 50), border_style=line.style_solid)
        array.push(activeSupportBoxes, supBox)

// --- Step 6: Real-Time Maintenance & Alert Processor ---
bool alertResistanceMitigated = false
bool alertSupportMitigated    = false

var int lastAlertBarRes = na
var int lastAlertBarSup = na

if array.size(activeResistanceBoxes) > 0
    for i = array.size(activeResistanceBoxes) - 1 to 0 by 1
        box b = array.get(activeResistanceBoxes, i)
        float topLevel = box.get_top(b)
        float bottomLevel = box.get_bottom(b)
        int startX     = box.get_left(b)
        
        if high >= bottomLevel and high <= topLevel and bar_index > startX and bar_index != lastAlertBarRes
            alertResistanceMitigated := true
            lastAlertBarRes := bar_index
        
        if close > topLevel
            int safeStartX = math.max(startX, bar_index - 9500)
            line.new(x1=safeStartX, y1=topLevel, x2=bar_index, y2=topLevel, xloc=xloc.bar_index, color=color.new(color.red, 40), width=1, style=line.style_dashed)
            box.delete(b)
            array.remove(activeResistanceBoxes, i)
        else
            box.set_right(b, bar_index)

if array.size(activeSupportBoxes) > 0
    for i = array.size(activeSupportBoxes) - 1 to 0 by 1
        box b = array.get(activeSupportBoxes, i)
        float topLevel = box.get_top(b)
        float bottomLevel = box.get_bottom(b)
        int startX        = box.get_left(b)
        
        if low <= topLevel and low >= bottomLevel and bar_index > startX and bar_index != lastAlertBarSup
            alertSupportMitigated := true
            lastAlertBarSup := bar_index
        
        if close < bottomLevel
            int safeStartX = math.max(startX, bar_index - 9500)
            line.new(x1=safeStartX, y1=bottomLevel, x2=bar_index, y2=bottomLevel, xloc=xloc.bar_index, color=color.new(color.green, 40), width=1, style=line.style_dashed)
            box.delete(b)
            array.remove(activeSupportBoxes, i)
        else
            box.set_right(b, bar_index)

// --- Step 7: Unified Audio Sound Mapping Layer ---
bool zoneHit = alertResistanceMitigated or alertSupportMitigated
alertcondition(zoneHit, title="Zone Hit (Supply or Demand)", message="Price has entered a Tertiary Structural Zone!")
````
