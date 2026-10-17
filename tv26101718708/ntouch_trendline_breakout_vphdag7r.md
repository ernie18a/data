# N-Touch Trendline Breakout

- url: https://www.tradingview.com/script/VPHDaG7r-n-touch-trendline-breakout/
- type: indicator
- pine_id: PUB;d1381896b8b64efa94d16b75eeb93bed
- version: 1.0

## Description

I've created an indicator that identifies support and resistance levels based on pivots and tracks how many times price interacts with them before breaking out.

Here is how it works:

1. Pivot Identification: It looks for pivot highs (resistance) and pivot lows (support) to establish levels.
2. Touch Tracking: When the price comes within the Touch Tolerance % of an active level (but doesn't break and close past it), it registers a "touch" and displays the count as tiny text on the chart.
3. Breakout Detection: If the price breaks through the level (closing above resistance or below support), it checks the touch count. If the required number of touches (default is 3) has been met or exceeded, it triggers a "BO" (Breakout) label with an arrow.

You can customize the following settings in the indicator inputs:

1. Pivot Length: Adjusts how many bars are used to define a pivot. A higher value will find more significant long-term levels.
2. Required Touches: The minimum number of interactions required before a breakout signal is valid.
3. Touch Tolerance %: Defines how close the price must get to the level to be considered a touch.
-Initial Touches: The two pivot points used to create the trendline automatically count as the first 2 touches.
-Future Touches: As the trendline extends into the future, any time the price comes within the Touch Tolerance % of the line without breaking it, a new touch is registered and displayed as a small number on the chart.
-Breakout Detection: If the price breaks through the extended trendline (closing above resistance or below support), the script checks the touch count. If it meets or exceeds your Required Touches setting (default is 3, which means the 2 pivots + 1 additional touch), it signals a breakout.
Clean Touch Numbers: The number 3 (and any subsequent numbers) will only print once per actual swing touch, keeping your chart nice and clean.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("N-Touch Trendline Breakout", overlay = true, max_lines_count = 500)

// --- Inputs ---
int pivotLen = input.int(10, "Pivot Length")
int reqTouches = input.int(3, "Required Touches (Including Pivots)", minval=2)
float touchTolerance = input.float(0.15, "Touch Tolerance %", step=0.05) / 100
int touchCooldown = input.int(5, "Bars Between Touches", tooltip="Minimum bars required between consecutive touches")

// --- Types ---
type TrendLine
    int x1
    float y1
    int x2
    float y2
    float slope
    float intercept
    int dir // 1 for resistance (lower highs), -1 for support (higher lows)
    int touches
    bool active
    line lineObj
    int lastTouchBar

// --- State ---
var trendlines = array.new<TrendLine>()
var lastPhX = 0
var float lastPhY = na
var lastPlX = 0
var float lastPlY = na

// Find Pivots
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

int pivotX = bar_index - pivotLen

if not na(ph)
    if not na(lastPhY) and ph < lastPhY // Lower high -> valid downward trendline
        float slope = (ph - lastPhY) / (pivotX - lastPhX)
        float intercept = lastPhY - slope * lastPhX
        line l = reqTouches <= 2 ? line.new(lastPhX, lastPhY, pivotX, ph, color=color.red, style=line.style_solid) : na
        if not na(l)
            line.set_extend(l, extend.right)
            label.new(lastPhX, lastPhY, "1", color=color.new(color.red, 100), style=label.style_label_down, textcolor=color.red, size=size.small)
            label.new(pivotX, ph, "2", color=color.new(color.red, 100), style=label.style_label_down, textcolor=color.red, size=size.small)
        array.push(trendlines, TrendLine.new(lastPhX, lastPhY, pivotX, ph, slope, intercept, 1, 2, true, l, pivotX))
    lastPhX := pivotX
    lastPhY := ph

if not na(pl)
    if not na(lastPlY) and pl > lastPlY // Higher low -> valid upward trendline
        float slope = (pl - lastPlY) / (pivotX - lastPlX)
        float intercept = lastPlY - slope * lastPlX
        line l = reqTouches <= 2 ? line.new(lastPlX, lastPlY, pivotX, pl, color=color.green, style=line.style_solid) : na
        if not na(l)
            line.set_extend(l, extend.right)
            label.new(lastPlX, lastPlY, "1", color=color.new(color.green, 100), style=label.style_label_up, textcolor=color.green, size=size.small)
            label.new(pivotX, pl, "2", color=color.new(color.green, 100), style=label.style_label_up, textcolor=color.green, size=size.small)
        array.push(trendlines, TrendLine.new(lastPlX, lastPlY, pivotX, pl, slope, intercept, -1, 2, true, l, pivotX))
    lastPlX := pivotX
    lastPlY := pl

// Check touches and breakouts
if array.size(trendlines) > 0
    for i = array.size(trendlines) - 1 to 0
        TrendLine tl = array.get(trendlines, i)
        
        if tl.active and bar_index > tl.x2
            float lineY = tl.slope * bar_index + tl.intercept
            float toleranceAmt = math.abs(lineY * touchTolerance)
            
            if tl.dir == 1 // Resistance trendline (downward)
                if close > lineY // Breakout
                    if tl.touches >= reqTouches
                        label.new(bar_index, low, "BO↑\n(" + str.tostring(tl.touches) + "t)", color=color.green, style=label.style_label_up, textcolor=color.white, size=size.small)
                        if not na(tl.lineObj)
                            line.set_color(tl.lineObj, color.new(color.gray, 50))
                            line.set_extend(tl.lineObj, extend.none)
                            line.set_x2(tl.lineObj, bar_index)
                            line.set_y2(tl.lineObj, lineY)
                    tl.active := false
                    
                else if high >= lineY - toleranceAmt and close <= lineY and bar_index >= tl.lastTouchBar + touchCooldown
                    // Valid Touch
                    tl.touches += 1
                    tl.lastTouchBar := bar_index
                    
                    // Draw line if we just met the required touches
                    if tl.touches == reqTouches and na(tl.lineObj)
                        tl.lineObj := line.new(tl.x1, tl.y1, bar_index, lineY, color=color.red, style=line.style_solid)
                        line.set_extend(tl.lineObj, extend.right)
                        label.new(tl.x1, tl.y1, "1", color=color.new(color.red, 100), style=label.style_label_down, textcolor=color.red, size=size.small)
                        label.new(tl.x2, tl.y2, "2", color=color.new(color.red, 100), style=label.style_label_down, textcolor=color.red, size=size.small)
                        
                    if tl.touches >= reqTouches
                        label.new(bar_index, high, str.tostring(tl.touches), color=color.new(color.red, 100), style=label.style_label_down, textcolor=color.red, size=size.small)
                    
            else if tl.dir == -1 // Support trendline (upward)
                if close < lineY // Breakout
                    if tl.touches >= reqTouches
                        label.new(bar_index, high, "BO↓\n(" + str.tostring(tl.touches) + "t)", color=color.red, style=label.style_label_down, textcolor=color.white, size=size.small)
                        if not na(tl.lineObj)
                            line.set_color(tl.lineObj, color.new(color.gray, 50))
                            line.set_extend(tl.lineObj, extend.none)
                            line.set_x2(tl.lineObj, bar_index)
                            line.set_y2(tl.lineObj, lineY)
                    tl.active := false
                    
                else if low <= lineY + toleranceAmt and close >= lineY and bar_index >= tl.lastTouchBar + touchCooldown
                    // Valid Touch
                    tl.touches += 1
                    tl.lastTouchBar := bar_index
                    
                    // Draw line if we just met the required touches
                    if tl.touches == reqTouches and na(tl.lineObj)
                        tl.lineObj := line.new(tl.x1, tl.y1, bar_index, lineY, color=color.green, style=line.style_solid)
                        line.set_extend(tl.lineObj, extend.right)
                        label.new(tl.x1, tl.y1, "1", color=color.new(color.green, 100), style=label.style_label_up, textcolor=color.green, size=size.small)
                        label.new(tl.x2, tl.y2, "2", color=color.new(color.green, 100), style=label.style_label_up, textcolor=color.green, size=size.small)
                        
                    if tl.touches >= reqTouches
                        label.new(bar_index, low, str.tostring(tl.touches), color=color.new(color.green, 100), style=label.style_label_up, textcolor=color.green, size=size.small)

// Cleanup old inactive lines
if array.size(trendlines) > 50
    TrendLine oldTl = array.shift(trendlines)
````
