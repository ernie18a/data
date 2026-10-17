# 15-Min NYSE ORB (Customizable Continuous Lines)

- url: https://www.tradingview.com/script/J2xZ69wc-15-Min-NYSE-ORB-Customizable-Continuous-Lines/
- type: indicator
- pine_id: PUB;1953b45433e7494aab3247a04193dc2c
- version: 1.0

## Description

Allows auto drawing of multiple time frame orbs on 15, 30 , 1hr etc..that extend to open of next day.

## Source Code

````pine
//@version=5
indicator("15-Min NYSE ORB (Customizable Continuous Lines)", overlay=true)

// Inputs
orbDuration  = input.int(15, title="ORB Duration (Minutes)")
highColor    = input.color(color.green, title="ORB High Line Color")
lowColor     = input.color(color.red, title="ORB Low Line Color")
lineWidth    = input.int(2, title="Line Width", minval=1, maxval=10)

// New Styling Inputs (Drop-down menus)
lineStyleInput = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"])

// Map string choices to official Pine Script line style variables
chosenStyle = switch lineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

// Variables
var float orbHigh = na
var float orbLow = na
var int orbStartTime = na
var line highLine = na
var line lowLine = na

// Force time evaluations natively inside New York Time zone 
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

// Identify the strict 9:30 AM EST Opening Candle
isNyseOpen = (nyHour == 9 and nyMinute == 30)

if isNyseOpen
    // Reset range tracking silently at the opening bell (No lines drawn)
    orbHigh := high
    orbLow := low
    orbStartTime := time
    highLine := na
    lowLine := na
    na 
else if not na(orbStartTime)
    // Calculate total minutes passed from the 09:30 AM EST anchor
    elapsedMinutes = (time - orbStartTime) / 60000
    
    if elapsedMinutes <= orbDuration
        // Keep computing high and low silently inside memory limits
        orbHigh := math.max(high, orbHigh)
        orbLow := math.min(low, orbLow)
        na 
    else
        // 15 Minutes closed. Build the lines for the first time
        if na(highLine)
            highLine := line.new(x1=orbStartTime, y1=orbHigh, x2=time, y2=orbHigh, 
                                 xloc=xloc.bar_time, color=highColor, width=lineWidth, style=chosenStyle)
            lowLine  := line.new(x1=orbStartTime, y1=orbLow,  x2=time, y2=orbLow,  
                                 xloc=xloc.bar_time, color=lowColor,  width=lineWidth, style=chosenStyle)
            na
        else
            // Lock values and extend both lines smoothly to the current candle time
            line.set_x2(highLine, time)
            line.set_x2(lowLine, time)
            na
    na
````
