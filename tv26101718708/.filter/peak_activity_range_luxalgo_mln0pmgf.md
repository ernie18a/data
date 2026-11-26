# Peak Activity Range [LuxAlgo]

- url: https://www.tradingview.com/script/mLN0PmgF-Peak-Activity-Range-LuxAlgo/
- type: indicator
- pine_id: PUB;87808dc371154c74b8c282cd6752467a
- version: 1.0

## Description

The Peak Activity Range indicator is a tool that automatically identifies high-volume price zones to establish support and resistance boundaries while providing a detailed analysis of volume distribution and breakout activity. By detecting significant volume peaks, the script highlights the price action of those specific candles to create dynamic ranges that act as key market interest zones.

🔶 [b]USAGE[/b]

The indicator identifies "Peak Activity Ranges" based on volume spikes. These ranges serve as key horizontal zones where significant market interest has occurred, often representing institutional participation.

🔹 [b]Signal Modes[/b]
The script plots small triangles (▲/▼) to indicate potential entries based on the selected mode in the settings. To prevent false signals, the indicator uses a state-based logic that requires price to return to the solid average line to reset the signal state.

[list]
[*] [b]Breakout[/b]: A bullish signal is triggered when the price closes above the range high, and a bearish signal is triggered when the price closes below the range low.
[*] [b]Retest[/b]: A bullish signal is triggered when a candle opens below the range high but closes above it. A bearish signal is triggered when a candle opens above the range low but closes below it.
[/list]

🔹 [b]Volume Distribution[/b]
Within each identified range, a dynamic Volume Profile is generated. This profile anchors to the right side of the zone and expands leftward, representing the volume transacted at specific price levels within that specific range.

🔶 [b]DETAILS[/b]

🔹 [b]Volume Peak Detection[/b]
The script uses a pivot-based approach to find volume highs. When a volume peak is confirmed (after the "Pivot Length" duration), the indicator retroactively creates a range based on the high and low of the candle that generated that volume. Any signals generated during the confirmation period are recalculated to ensure accuracy.

🔹 [b]Internal Levels[/b]
Each range contains two primary internal lines to guide the trader:
[list]
[*] [b]Solid Line[/b]: Represents the exact midpoint (average) of the high-volume candle's range. It acts as a "fair value" level; crossing this level resets the signal state.
[*] [b]Dashed Line[/b]: Represents the Point of Control (POC). This is the specific price level within the range where the highest amount of volume was transacted, calculated from the internal volume profile.
[/list]

🔶 [b]SETTINGS[/b]

🔹 [b]General[/b]
[list]
[*] [b]Pivot Length[/b]: The number of bars used to confirm a volume pivot high. Larger values identify more significant, longer-term ranges.
[*] [b]Signal Mode[/b]: Switch between "Breakout" and "Retest" logic for triangle signals.
[/list]

🔹 [b]Volume Profile[/b]
[list]
[*] [b]Show Volume Profile[/b]: Toggles the visibility of the internal volume distribution bars.
[*] [b]Profile Rows[/b]: Determines the vertical granularity (number of price bins) of the Volume Profile.
[*] [b]Max Width %[/b]: Controls the maximum horizontal extension of the profile as a percentage of the range duration.
[/list]

🔹 [b]Style[/b]
[list]
[*] [b]Bullish/Bearish Fill[/b]: Colors for the range background and volume profile bars.
[*] [b]Bullish/Bearish Lines[/b]: Colors for the solid (average) and dashed (POC) lines.
[*] [b]Signal Colors[/b]: Custom colors for the upward and downward breakout/retest triangles.
[/list]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("Peak Activity Range [LuxAlgo]", "LuxAlgo - Peak Activity Range", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// Settings
//---------------------------------------------------------------------------------------------------------------------{
length          = input.int(10, "Pivot Length", minval = 1, tooltip = "Number of bars to the left and right to determine the volume pivot high.")
signalMode      = input.string("Retest", "Signal Mode", options = ["Breakout", "Retest"], tooltip = "Choose the logic for generating signals.")

grpVp           = "Volume Profile"
showVp          = input.bool(true, "Show Volume Profile", group = grpVp, tooltip = "Enable or disable the volume profile inside ranges.")
vpRows          = input.int(10, "Profile Rows", minval = 1, maxval = 50, group = grpVp, tooltip = "Number of rows in the volume profile.")
vpWidthPct      = input.int(20, "Max Width %", minval = 1, maxval = 100, group = grpVp, tooltip = "Maximum width of the volume profile as a percentage of the range duration.")

grpStyle        = "Style"
bullColor       = input.color(color.new(#089981, 80), "Bullish Fill", group = grpStyle, tooltip = "Color for ranges starting from a bullish candle.")
bearColor       = input.color(color.new(#f23645, 80), "Bearish Fill", group = grpStyle, tooltip = "Color for ranges starting from a bearish candle.")
bullLineColor   = input.color(#089981, "Bullish Lines", group = grpStyle, tooltip = "Color for the inner lines of a bullish range.")
bearLineColor   = input.color(#f23645, "Bearish Lines", group = grpStyle, tooltip = "Color for the inner lines of a bearish range.")
signalUpColor   = input.color(#089981, "Breakout Up Signal", group = grpStyle, tooltip = "Color for the bullish breakout triangle.")
signalDownColor = input.color(#f23645, "Breakout Down Signal", group = grpStyle, tooltip = "Color for the bearish breakout triangle.")

//---------------------------------------------------------------------------------------------------------------------}
// Methods
//---------------------------------------------------------------------------------------------------------------------{
method addVolume(float[] vols, float h, float l, float v, float rangeTop, float rangeBot, int rows) =>
    if v > 0 and rangeTop > rangeBot
        float rowHeight = (rangeTop - rangeBot) / rows
        if h == l
            int rowIndex = math.floor((h - rangeBot) / rowHeight)
            rowIndex := math.max(0, math.min(rows - 1, rowIndex))
            vols.set(rowIndex, vols.get(rowIndex) + v)
        else
            for i = 0 to rows - 1
                float rowBot = rangeBot + i * rowHeight
                float rowTop = rangeBot + (i + 1) * rowHeight
                float overlap = math.max(0, math.min(h, rowTop) - math.max(l, rowBot))
                if overlap > 0
                    vols.set(i, vols.get(i) + v * (overlap / (h - l)))

method updateVpBoxes(box[] boxes, float[] vols, int leftIdx, int rightIdx, float rangeTop, float rangeBot, int rows, int widthPct, color c) =>
    float maxVol = vols.max()
    float rowHeight = (rangeTop - rangeBot) / rows
    int duration = rightIdx - leftIdx
    float maxBars = math.max(1, duration * widthPct / 100)
    
    if boxes.size() == 0
        for i = 0 to rows - 1
            boxes.push(box.new(na, na, na, na, bgcolor = c, border_color = na))
            
    for i = 0 to rows - 1
        float vol = vols.get(i)
        float width = maxVol > 0 ? (vol / maxVol) * maxBars : 0
        int boxLeft = rightIdx - math.round(width)
        box b = boxes.get(i)
        b.set_lefttop(boxLeft, rangeBot + (i + 1) * rowHeight)
        b.set_rightbottom(rightIdx, rangeBot + i * rowHeight)

method updatePoc(line pocLine, float[] vols, float rangeTop, float rangeBot, int rows) =>
    if vols.size() > 0
        float maxVol = vols.max()
        if maxVol > 0
            int pocIdx = vols.indexof(maxVol)
            if pocIdx != -1
                float rowHeight = (rangeTop - rangeBot) / rows
                float pocPrice = rangeBot + (pocIdx + 0.5) * rowHeight
                pocLine.set_y1(pocPrice)
                pocLine.set_y2(pocPrice)

//---------------------------------------------------------------------------------------------------------------------}
// Variables
//---------------------------------------------------------------------------------------------------------------------{
var box currentBox        = na
var color currentBoxColor = na
var line avgLine          = na
var line pocLine          = na

var float currentHigh     = na
var float currentLow      = na
var float currentAvg      = na
var int   state           = 0

var label[] signalLabels    = array.new_label()
var box[]   currentVpBoxes  = array.new_box()
var float[] activeVpVolumes = array.new_float(vpRows, 0)
var int     activeLeftIndex = na

//---------------------------------------------------------------------------------------------------------------------}
// Core Logic
//---------------------------------------------------------------------------------------------------------------------{
volPh = ta.pivothigh(volume, length, length)

if not na(volPh)
    pivotIndex = bar_index - length
    
    // Finalize previous VP boxes
    if not na(activeLeftIndex) and currentHigh > currentLow and showVp
        currentVpBoxes.updateVpBoxes(activeVpVolumes, activeLeftIndex, pivotIndex, currentHigh, currentLow, vpRows, vpWidthPct, currentBoxColor)
        
    // Trim previous objects to avoid overlap
    if not na(currentBox)
        box.set_right(currentBox, pivotIndex)
        line.set_x2(avgLine, pivotIndex)
        line.set_x2(pocLine, pivotIndex)
        
    // Clean up retroactively invalidated labels
    if array.size(signalLabels) > 0
        for i = array.size(signalLabels) - 1 to 0
            lbl = array.get(signalLabels, i)
            if label.get_x(lbl) >= pivotIndex
                label.delete(lbl)
                array.remove(signalLabels, i)
        
    pivotHigh  = high[length]
    pivotLow   = low[length]
    isBull     = close[length] >= open[length]
    
    boxColor   = isBull ? bullColor : bearColor
    currentBoxColor := boxColor
    lineColor  = isBull ? bullLineColor : bearLineColor
    
    currentBox := box.new(pivotIndex, pivotHigh, bar_index, pivotLow, border_color = na, bgcolor = boxColor)
    
    avgVal     = math.avg(pivotHigh, pivotLow)
    avgLine    := line.new(pivotIndex, avgVal, bar_index, avgVal, color = lineColor, style = line.style_solid)
    pocLine    := line.new(pivotIndex, avgVal, bar_index, avgVal, color = lineColor, style = line.style_dashed)
    
    currentHigh := pivotHigh
    currentLow  := pivotLow
    currentAvg  := avgVal
    state       := 0
    
    // Reset VP
    currentVpBoxes  := array.new_box()
    activeVpVolumes := array.new_float(vpRows, 0)
    activeLeftIndex := pivotIndex
    
    // Retroactively evaluate breakouts and VP for the new range
    for i = length to 0
        c      = close[i]
        c_prev = close[i+1]
        o      = open[i]
        
        bool crossAvg = (c > avgVal and c_prev <= avgVal) or (c < avgVal and c_prev >= avgVal)
        if crossAvg
            state := 0
            
        bool crossUp   = false
        bool crossDown = false
        
        if signalMode == "Breakout"
            crossUp   := c > pivotHigh and c_prev <= pivotHigh
            crossDown := c < pivotLow and c_prev >= pivotLow
        else // Retest
            crossUp   := o > pivotHigh and c < pivotHigh
            crossDown := o < pivotLow and c > pivotLow
            
        if crossUp and state != 1
            state := 1
            lbl = label.new(bar_index - i, na, text = "▲", style = label.style_none, textcolor = signalUpColor, yloc = yloc.belowbar, size = size.small)
            array.push(signalLabels, lbl)
            
        if crossDown and state != -1
            state := -1
            lbl = label.new(bar_index - i, na, text = "▼", style = label.style_none, textcolor = signalDownColor, yloc = yloc.abovebar, size = size.small)
            array.push(signalLabels, lbl)
            
        if pivotHigh > pivotLow
            activeVpVolumes.addVolume(high[i], low[i], volume[i], pivotHigh, pivotLow, vpRows)
            
    if pivotHigh > pivotLow
        pocLine.updatePoc(activeVpVolumes, pivotHigh, pivotLow, vpRows)
        if showVp
            currentVpBoxes.updateVpBoxes(activeVpVolumes, activeLeftIndex, bar_index, pivotHigh, pivotLow, vpRows, vpWidthPct, currentBoxColor)
        
else
    if not na(currentBox)
        box.set_right(currentBox, bar_index)
        line.set_x2(avgLine, bar_index)
        line.set_x2(pocLine, bar_index)
        
    // Real-time evaluation
    if not na(currentHigh)
        c      = close
        c_prev = close[1]
        o      = open
        
        bool crossAvg = (c > currentAvg and c_prev <= currentAvg) or (c < currentAvg and c_prev >= currentAvg)
        if crossAvg
            state := 0
            
        bool crossUp   = false
        bool crossDown = false
        
        if signalMode == "Breakout"
            crossUp   := c > currentHigh and c_prev <= currentHigh
            crossDown := c < currentLow and c_prev >= currentLow
        else // Retest
            crossUp   := o > currentHigh and c < currentHigh
            crossDown := o < currentLow and c > currentLow
            
        if crossUp and state != 1
            state := 1
            lbl = label.new(bar_index, na, text = "▲", style = label.style_none, textcolor = signalUpColor, yloc = yloc.belowbar, size = size.small)
            array.push(signalLabels, lbl)
            
        if crossDown and state != -1
            state := -1
            lbl = label.new(bar_index, na, text = "▼", style = label.style_none, textcolor = signalDownColor, yloc = yloc.abovebar, size = size.small)
            array.push(signalLabels, lbl)
            
        if currentHigh > currentLow
            activeVpVolumes.addVolume(high, low, volume, currentHigh, currentLow, vpRows)
            pocLine.updatePoc(activeVpVolumes, currentHigh, currentLow, vpRows)
            if showVp
                currentVpBoxes.updateVpBoxes(activeVpVolumes, activeLeftIndex, bar_index, currentHigh, currentLow, vpRows, vpWidthPct, currentBoxColor)

//---------------------------------------------------------------------------------------------------------------------}
````
