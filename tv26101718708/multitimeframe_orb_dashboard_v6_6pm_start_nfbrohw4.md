# Multi-Timeframe ORB Dashboard (v6) - 6PM Start

- url: https://www.tradingview.com/script/nFBROhW4-Multi-Timeframe-ORB-Dashboard-v6-6PM-Start/
- type: indicator
- pine_id: PUB;d7bcd847ec7c4b09b16a65f21dc54d6a
- version: 1.0

## Description

Globex ORB great support and resistance levels add this to my nyse orb great combo.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe NYSE ORB Dashboard (v6) - 6PM Start", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// Timeframe Visibility Checkboxes
// ==========================================
show15m = input.bool(true,  title="Show 15 Min ORB", group="Timeframe Toggles")
show30m = input.bool(true,  title="Show 30 Min ORB", group="Timeframe Toggles")
show1h  = input.bool(true,  title="Show 1 Hour ORB", group="Timeframe Toggles")
show4h  = input.bool(true,  title="Show 4 Hour ORB", group="Timeframe Toggles")
show8h  = input.bool(true,  title="Show 8 Hour ORB", group="Timeframe Toggles")
show12h = input.bool(true,  title="Show 12 Hour ORB", group="Timeframe Toggles")
show16h = input.bool(true,  title="Show 16 Hour ORB", group="Timeframe Toggles")
show20h = input.bool(true,  title="Show 20 Hour ORB", group="Timeframe Toggles")

// Visual Customization Defaults
textColor  = input.color(color.white, title="Text Color", group="Visual Style")
textOffset = input.int(10, title="Right Margin Label Offset (Bars)", minval=2, group="Visual Style")

// Helper function to map drop-down strings to system variables
getLineStyle(string styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// ==========================================
// Per-Timeframe Style Configurations
// ==========================================
// 15 Min Configuration
c15m_H   = input.color(color.green,  title="15m High Color", group="15 Min Configuration")
c15m_L   = input.color(color.red,    title="15m Low Color",  group="15 Min Configuration")
w15m     = input.int(2,              title="15m Line Width", minval=1, maxval=10, group="15 Min Configuration")
s15m_str = input.string("Solid",     title="15m Line Style", options=["Solid", "Dashed", "Dotted"], group="15 Min Configuration")

// 30 Min Configuration
c30m_H   = input.color(color.lime,   title="30m High Color", group="30 Min Configuration")
c30m_L   = input.color(color.maroon, title="30m Low Color",  group="30 Min Configuration")
w30m     = input.int(2,              title="30m Line Width", minval=1, maxval=10, group="30 Min Configuration")
s30m_str = input.string("Solid",     title="30m Line Style", options=["Solid", "Dashed", "Dotted"], group="30 Min Configuration")

// 1 Hour Configuration
c1h_H    = input.color(color.teal,   title="1h High Color",  group="1 Hour Configuration")
c1h_L    = input.color(color.orange, title="1h Low Color",   group="1 Hour Configuration")
w1h      = input.int(2,              title="1h Line Width",  minval=1, maxval=10, group="1 Hour Configuration")
s1h_str  = input.string("Solid",     title="1h Line Style",  options=["Solid", "Dashed", "Dotted"], group="1 Hour Configuration")

// 4 Hour Configuration
c4h_H    = input.color(color.blue,   title="4h High Color",  group="4 Hour Configuration")
c4h_L    = input.color(color.navy,   title="4h Low Color",   group="4 Hour Configuration")
w4h      = input.int(2,              title="4h Line Width",  minval=1, maxval=10, group="4 Hour Configuration")
s4h_str  = input.string("Solid",     title="4h Line Style",  options=["Solid", "Dashed", "Dotted"], group="4 Hour Configuration")

// 8 Hour Configuration
c8h_H    = input.color(color.purple, title="8h High Color",  group="8 Hour Configuration")
c8h_L    = input.color(color.fuchsia,title="8h Low Color",   group="8 Hour Configuration")
w8h      = input.int(2,              title="8h Line Width",  minval=1, maxval=10, group="8 Hour Configuration")
s8h_str  = input.string("Solid",     title="8h Line Style",  options=["Solid", "Dashed", "Dotted"], group="8 Hour Configuration")

// 12 Hour Configuration
c12h_H   = input.color(color.yellow, title="12h High Color", group="12 Hour Configuration")
c12h_L   = input.color(color.aqua,   title="12h Low Color",  group="12 Hour Configuration")
w12h     = input.int(2,              title="12h Line Width", minval=1, maxval=10, group="12 Hour Configuration")
s12h_str = input.string("Solid",     title="12h Line Style", options=["Solid", "Dashed", "Dotted"], group="12 Hour Configuration")

// 16 Hour Configuration
c16h_H   = input.color(color.olive,  title="16h High Color", group="16 Hour Configuration")
c16h_L   = input.color(color.silver, title="16h Low Color",  group="16 Hour Configuration")
w16h     = input.int(2,              title="16h Line Width", minval=1, maxval=10, group="16 Hour Configuration")
s16h_str = input.string("Solid",     title="16h Line Style", options=["Solid", "Dashed", "Dotted"], group="16 Hour Configuration")

// 20 Hour Configuration
c20h_H   = input.color(color.gray,   title="20h High Color", group="20 Hour Configuration")
c20h_L   = input.color(color.white,  title="20h Low Color",  group="20 Hour Configuration")
w20h     = input.int(2,              title="20h Line Width", minval=1, maxval=10, group="20 Hour Configuration")
s20h_str = input.string("Solid",     title="20h Line Style", options=["Solid", "Dashed", "Dotted"], group="20 Hour Configuration")


// Force time evaluations natively inside New York Time zone
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

// 6:00 PM (Hour 18, Minute 00) Start
isNyseOpen = (nyHour == 18 and nyMinute == 0)

// ==========================================
// Multi-Timeframe Core Execution Function
// ==========================================
process_orb(bool isVisible, int duration, color hCol, color lCol, int lWidth, string lStyleStr, string labelPrefix) =>
    var float orbHigh = na
    var float orbLow = na
    var int orbStartTime = na
    var int orbEndTime = na
    
    // Persistent script references per timeframe tracking session
    var line highLine = na
    var line lowLine = na
    var label highLabel = na
    var label lowLabel = na

    chosenStyle = getLineStyle(lStyleStr)

    if isNyseOpen
        orbHigh      := high
        orbLow       := low
        orbStartTime := time
        orbEndTime   := na
        highLine     := na
        lowLine      := na
        highLabel    := na
        lowLabel     := na
    else if not na(orbStartTime)
        elapsedMinutes = (time - orbStartTime) / 60000
        
        // 1. Amass values inside tracking session window
        if elapsedMinutes <= duration
            orbHigh    := math.max(high, orbHigh)
            orbLow     := math.min(low, orbLow)
            orbEndTime := time
        else
            // 2. Window has closed. Calculate target 5:59:00 PM EST next-day limit.
            if isVisible
                // Adding exactly 24 hours (in milliseconds) and subtracting 1 minute (60,000ms) 
                // from the 6:00 PM start time lands exactly on 5:59 PM the following day.
                int stopTimestamp = orbStartTime + (24 * 60 * 60 * 1000) - (60 * 1000)
                
                if na(highLine) and not na(orbEndTime)
                    // Draw lines originating from the end of the ORB window up to our targeted 5:59 PM next-day cutoff
                    highLine  := line.new(x1=orbEndTime, y1=orbHigh, x2=stopTimestamp, y2=orbHigh, xloc=xloc.bar_time, color=hCol, width=lWidth, style=chosenStyle)
                    lowLine   := line.new(x1=orbEndTime, y1=orbLow,  x2=stopTimestamp, y2=orbLow,  xloc=xloc.bar_time, color=lCol, width=lWidth, style=chosenStyle)
                    
                    // Generate floating labels solely on active real-time data lookups
                    if barstate.islast
                        highLabel := label.new(x=bar_index + textOffset, y=orbHigh, text=labelPrefix + " H: " + str.tostring(orbHigh, "#.##"), xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_left, size=size.normal)
                        lowLabel  := label.new(x=bar_index + textOffset, y=orbLow,  text=labelPrefix + " L: " + str.tostring(orbLow, "#.##"),  xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=textColor, style=label.style_label_left, size=size.normal)
                else
                    // On the live candle, keep moving labels cleanly forward to follow market updates
                    if barstate.islast and not na(highLabel)
                        label.set_xy(highLabel, bar_index + textOffset, orbHigh)
                        label.set_xy(lowLabel, bar_index + textOffset, orbLow)
    
    int cleanExit = na

// ==========================================
// Process All Tracks Simultaneously
// ==========================================
process_orb(show15m, 15,   c15m_H,  c15m_L,  w15m,  s15m_str,  "15m")
process_orb(show30m, 30,   c30m_H,  c30m_L,  w30m,  s30m_str,  "30m")
process_orb(show1h,  60,   c1h_H,   c1h_L,   w1h,   s1h_str,   "1h")
process_orb(show4h,  240,  c4h_H,   c4h_L,   w4h,   s4h_str,   "4h")
process_orb(show8h,  480,  c8h_H,   c8h_L,   w8h,   s8h_str,   "8h")
process_orb(show12h, 720,  c12h_H,  c12h_L,  w12h,  s12h_str,  "12h")
process_orb(show16h, 960,  c16h_H,  c16h_L,  w16h,  s16h_str,  "16h")
process_orb(show20h, 1200, c20h_H,  c20h_L,  w20h,  s20h_str,  "20h")
````
