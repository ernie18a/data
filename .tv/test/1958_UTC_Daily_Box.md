<!-- tradingview-pine-id: PUB;70b2a08a3f8849bb9d1ff8a94b9fdc14 -->
<!-- tradingviewscripts-format: 1 -->
# 19:58 UTC Daily Box

Source: https://www.tradingview.com/script/JmrQkUoW-NQ-Daily-Box/

## Description

Automatically draws a box from the high and low of the confirmed 2-minute candle opening at 19:58 UTC. Each box extends to the right and includes an optional dashed 50% midpoint line. When a new box overlaps an older one, the older box is removed while non-overlapping historical boxes remain visible. Designed for precise UTC-based session analysis

---

## Source Code

````pine
//@version=6
indicator("19:58 UTC Daily Box", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// ==============================================================================
// User Inputs
// ==============================================================================
showMidpoint = input.bool(true, "Show Midpoint Line")
boxBgColor   = input.color(color.new(color.blue, 85), "Box Background Color")
boxBorder    = input.color(color.new(color.blue, 40), "Box Border Color")
lineColor    = input.color(color.new(color.red, 0), "Midpoint Line Color")

// ==============================================================================
// Timeframe Validation
// ==============================================================================
if bar_index == 0 and (timeframe.multiplier != 2 or not timeframe.isminutes)
    runtime.error("This indicator must be used strictly on a 2-minute chart.")

// ==============================================================================
// Synchronized Arrays for Data Storage
// ==============================================================================
var array<box>   boxes = array.new<box>()
var array<line>  lines = array.new<line>()
var array<float> highs = array.new<float>()
var array<float> lows  = array.new<float>()
var array<int>   dates = array.new<int>()

// ==============================================================================
// Logic & Execution
// ==============================================================================
// Identify the 19:58 UTC candle. 
// Using barstate.isconfirmed ensures we only draw on the final closed values (no repainting).
is1958 = hour(time, "UTC") == 19 and minute(time, "UTC") == 58 and barstate.isconfirmed

// Generate a unique integer date key (YYYYMMDD) in UTC to prevent duplicates
currentDateKey = year(time, "UTC") * 10000 + month(time, "UTC") * 100 + dayofmonth(time, "UTC")

if is1958
    // 1. Prevent duplicate creation for the exact same date
    alreadyExists = false
    if array.size(dates) > 0
        if array.get(dates, array.size(dates) - 1) == currentDateKey
            alreadyExists := true
            
    if not alreadyExists
        float newHigh = high
        float newLow  = low
        float newMid  = (newHigh + newLow) / 2.0
        
        // 2. Iterate backward to check for price overlaps with older boxes
        if array.size(boxes) > 0
            for i = array.size(boxes) - 1 to 0
                float oldHigh = array.get(highs, i)
                float oldLow  = array.get(lows, i)
                
                // Overlap Condition: newHigh >= oldLow AND newLow <= oldHigh
                if newHigh >= oldLow and newLow <= oldHigh
                    
                    // Delete the overlapping box and its midpoint line
                    box.delete(array.get(boxes, i))
                    lineToDelete = array.get(lines, i)
                    if not na(lineToDelete)
                        line.delete(lineToDelete)
                    
                    // Remove the deleted objects' records from the synchronized arrays
                    array.remove(boxes, i)
                    array.remove(lines, i)
                    array.remove(highs, i)
                    array.remove(lows,  i)
                    array.remove(dates, i)
                    
        // 3. Create the new box
        newBox = box.new(
             left         = bar_index, 
             top          = newHigh, 
             right        = bar_index + 1, 
             bottom       = newLow, 
             border_color = boxBorder, 
             bgcolor      = boxBgColor, 
             extend       = extend.right
         )
        
        // 4. Create the new midpoint line (if enabled by user)
        line newLine = na
        if showMidpoint
            newLine := line.new(
                 x1     = bar_index, 
                 y1     = newMid, 
                 x2     = bar_index + 1, 
                 y2     = newMid, 
                 color  = lineColor, 
                 style  = line.style_dashed, 
                 extend = extend.right
             )
            
        // 5. Store the new items in our synchronized arrays
        array.push(boxes, newBox)
        array.push(lines, newLine)
        array.push(highs, newHigh)
        array.push(lows,  newLow)
        array.push(dates, currentDateKey)
````
