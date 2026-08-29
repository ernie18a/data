<!-- tradingview-pine-id: PUB;550763f7c1ea4b16b6e7bf15026d064b -->
<!-- tradingviewscripts-format: 1 -->
# Golden Zone [Bhavik51]

Source: https://www.tradingview.com/script/9kUf8e35-Golden-Zone-Bhavik51/

## Description

The Golden Zone:

When a structurally valid swing completes, the indicator automatically calculates and projects a "Golden Zone" box forward. This box represents the 0.5 to 0.618 Fibonacci retracement levels of the most recently completed swing leg. The zone extends dynamically with real-time price action, providing a visual area of interest for trend-following pullbacks.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bhavik51

//@version=6
indicator(title = "Golden Zone [Bhavik51]", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// --- 1. Settings ---
swingLength   = input.int(10, title = "Swing Length", group = "Swing Settings")
swingMult     = input.float(3.5, title = "Swing Multiplier", group = "Swing Settings", step = 0.5)
htf           = input.timeframe("", title = "Calculated Timeframe", group = "Swing Settings")

// Structure Filter Settings
useStructFilter = input.bool(true, title = "Enable HH / LL Structure Filter", group = "Structure Filter")

// New Line Settings
upLineColor   = input.color(color.green, title = "Up Trend Line Color", group = "Line Settings")
downLineColor = input.color(color.red, title = "Down Trend Line Color", group = "Line Settings")
lineWidth     = input.int(1, title = "Line Width", minval = 1, maxval = 5, group = "Line Settings")
lineStyleStr  = input.string("Solid", title = "Line Style", options = ["Solid", "Dashed", "Dotted"], group = "Line Settings")

showFibs      = input.bool(true, title = "Show 0.5 - 0.618 Zone", group = "UI Settings")
bullColor     = input.color(color.new(color.teal, 85), title = "Bullish Zone Color", group = "UI Settings")
bearColor     = input.color(color.new(color.orange, 85), title = "Bearish Zone Color", group = "UI Settings")

// Map the dropdown string to the actual Pine Script line style
lineStyle = lineStyleStr == "Dashed" ? line.style_dashed : lineStyleStr == "Dotted" ? line.style_dotted : line.style_solid

// --- 2. Fetch Data ---
[htfHigh, htfLow, htfClose, htfAtr] = request.security(syminfo.tickerid, htf, [high, low, close, ta.atr(swingLength)])
atrThreshold = htfAtr * swingMult

// --- 3. State Variables ---
var int dir = 1             
var float extremePrice = na 
var int extremeTime = na     
var line activeLine = na    

// Fib Zone Memory
var float prevExtremePrice = na
var int prevExtremeTime = na
var box goldenZone = na
var label fib50Label = na
var label fib618Label = na

// Structure Memory
var float lastHigh = na
var float lastLow = na

if barstate.isfirst
    extremePrice := close
    extremeTime := time
    prevExtremePrice := close
    prevExtremeTime := time
    activeLine := line.new(time, close, time, close, xloc = xloc.bar_time, color = color.gray, width = lineWidth, style = lineStyle)

// --- 4. Swing & Fib Detection Logic ---
if not na(htfClose)
    // Keep stretching only the most recent Fib Box AND Labels forward
    if showFibs and not na(goldenZone)
        box.set_right(goldenZone, time)
        label.set_x(fib50Label, time)
        label.set_x(fib618Label, time)

    if dir == 1 // Currently in an Uptrend
        if htfHigh > extremePrice
            extremePrice := htfHigh
            extremeTime := time
            line.set_xy2(activeLine, extremeTime, extremePrice)
        
        // Reversal Down -> Confirms a Major High
        if htfClose < extremePrice - atrThreshold
            dir := -1 
            // Draw the new DOWN line using the user's color, width, and style
            activeLine := line.new(extremeTime, extremePrice, time, htfLow, xloc = xloc.bar_time, color = downLineColor, width = lineWidth, style = lineStyle)
            
            // Market Structure Check (Is this a Higher High?)
            bool isHH = na(lastHigh) or (extremePrice > lastHigh)
            bool structBullOK = not useStructFilter or isHH

            // --- FIBONACCI CALCULATION (Bullish Leg Completed) ---
            if showFibs and structBullOK
                float swingRange = extremePrice - prevExtremePrice
                float fib50 = extremePrice - (swingRange * 0.5)
                float fib618 = extremePrice - (swingRange * 0.618)
                
                goldenZone := box.new(prevExtremeTime, fib50, time, fib618, xloc = xloc.bar_time, border_color = color.new(color.teal, 30), border_style = line.style_dashed, bgcolor = bullColor)
                fib50Label := label.new(time, fib50, text = " 0.5", xloc = xloc.bar_time, style = label.style_none, textcolor = color.teal, size = size.small)
                fib618Label := label.new(time, fib618, text = " 0.618", xloc = xloc.bar_time, style = label.style_none, textcolor = color.teal, size = size.small)
            else if showFibs
                goldenZone := na // Clear it so it doesn't drag an invalid zone forward

            // Update variables for the next leg
            lastHigh := extremePrice
            prevExtremePrice := extremePrice
            prevExtremeTime := extremeTime
            extremePrice := htfLow
            extremeTime := time

    else if dir == -1 // Currently in a Downtrend
        if htfLow < extremePrice
            extremePrice := htfLow
            extremeTime := time
            line.set_xy2(activeLine, extremeTime, extremePrice)
        
        // Reversal Up -> Confirms a Major Low
        if htfClose > extremePrice + atrThreshold
            dir := 1 
            // Draw the new UP line using the user's color, width, and style
            activeLine := line.new(extremeTime, extremePrice, time, htfHigh, xloc = xloc.bar_time, color = upLineColor, width = lineWidth, style = lineStyle)
            
            // Market Structure Check (Is this a Lower Low?)
            bool isLL = na(lastLow) or (extremePrice < lastLow)
            bool structBearOK = not useStructFilter or isLL

            // --- FIBONACCI CALCULATION (Bearish Leg Completed) ---
            if showFibs and structBearOK
                float swingRange = prevExtremePrice - extremePrice
                float fib50 = extremePrice + (swingRange * 0.5)
                float fib618 = extremePrice + (swingRange * 0.618)
                
                goldenZone := box.new(prevExtremeTime, fib50, time, fib618, xloc = xloc.bar_time, border_color = color.new(color.orange, 30), border_style = line.style_dashed, bgcolor = bearColor)
                fib50Label := label.new(time, fib50, text = " 0.5", xloc = xloc.bar_time, style = label.style_none, textcolor = color.orange, size = size.small)
                fib618Label := label.new(time, fib618, text = " 0.618", xloc = xloc.bar_time, style = label.style_none, textcolor = color.orange, size = size.small)
            else if showFibs
                goldenZone := na // Clear it so it doesn't drag an invalid zone forward

            // Update variables for the next leg
            lastLow := extremePrice
            prevExtremePrice := extremePrice
            prevExtremeTime := extremeTime
            extremePrice := htfHigh
            extremeTime := time
````
