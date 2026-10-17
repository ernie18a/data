# Multi-Timeframe NYSE ORB Dashboard (High-Vis HUD)

- url: https://www.tradingview.com/script/yNU1el0M-Multi-Timeframe-NYSE-ORB-Dashboard-High-Vis-HUD/
- type: indicator
- pine_id: PUB;bde35e85761046f681ddeabfbe36327f
- version: 1.0

## Description

Ultimate Multi time frame ORB i use on 1 minute chart, and data box with time frames and prices and color coordinator.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe NYSE ORB Dashboard (High-Vis HUD)", overlay=true, max_lines_count=500)

// ==========================================
// Timeframe Visibility Checkboxes
// ==========================================
show15m = input.bool(true,  title="Show 15 Min ORB", group="Timeframe Toggles")
show30m = input.bool(true,  title="Show 30 Min ORB", group="Timeframe Toggles")
show1h  = input.bool(true,  title="Show 1 Hour ORB", group="Timeframe Toggles")
show4h  = input.bool(true,  title="Show 4 Hour ORB", group="Timeframe Toggles")
show8h  = input.bool(true,  title="Show 8 Hour ORB", group="Timeframe Toggles")
show24h = input.bool(true,  title="Show 24 Hour ORB", group="Timeframe Toggles")

// Visual Customization Defaults
lineWidth  = input.int(3, title="ORB Line Width", minval=1, maxval=10, group="Visual Style")
lineStyleInput = input.string("Solid", title="Global Line Style", options=["Solid", "Dashed", "Dotted"], group="Visual Style")

// Map string choices to official Pine Script line style variables
chosenStyle = switch lineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

// High Visibility Table UI Styling (No transparency, thick borders)
tableBgColor   = input.color(color.new(color.black, 0), title="HUD Solid Background Color", group="HUD High-Vis Style")
tableTextColor = input.color(color.white, title="HUD Headers Text Color", group="HUD High-Vis Style")
tableTextSize  = input.string("Large", title="HUD Font Size", options=["Normal", "Large", "Huge"], group="HUD High-Vis Style")

fontSize = switch tableTextSize
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.large

// Ultra-Bright Neon Colors per Timeframe (Eliminated all dark blues, dark reds, and purples)
c15m_H = input.color(#ff007f, title="15m High Color (Neon Pink)", group="15 Min Configuration")
c15m_L = input.color(#00ffff, title="15m Low Color (Electric Cyan)", group="15 Min Configuration")
c30m_H = input.color(#00ff00, title="30m High Color (Hot Lime)", group="30 Min Configuration")
c30m_L = input.color(#ff0055, title="30m Low Color (Bright Magenta)", group="30 Min Configuration")
c1h_H  = input.color(#ffff00, title="1h High Color (Vibrant Yellow)", group="1 Hour Configuration")
c1h_L  = input.color(#ffaa00, title="1h Low Color (Bright Gold)", group="1 Hour Configuration")
c4h_H  = input.color(#ff5500, title="4h High Color (Ultra Orange)", group="4 Hour Configuration")
c4h_L  = input.color(#00ffaa, title="4h Low Color (Neon Mint)", group="4 Hour Configuration")
c8h_H  = input.color(#ff00ff, title="8h High Color (Vivid Fuchsia)", group="8 Hour Configuration")
c8h_L  = input.color(#00aaff, title="8h Low Color (Sky Cyan)", group="8 Hour Configuration")
c24h_H = input.color(#ffffff, title="24h High Color (Pure White)", group="24 Hour Configuration")
c24h_L = input.color(#ffea00, title="24h Low Color (Neon Yellow)", group="24 Hour Configuration")

// Force time evaluations natively inside New York Time zone
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
isNyseOpen = (nyHour == 9 and nyMinute == 30)

// Global matrix/arrays to hold layout data for the HUD compiler
var float[] activeHighs  = array.new_float(6, na)
var float[] activeLows   = array.new_float(6, na)

// ==========================================
// Multi-Timeframe Core Execution Function
// ==========================================
process_orb(bool isVisible, int duration, color hCol, color lCol, int internalIdx) =>
    var float orbHigh = na
    var float orbLow = na
    var int orbStartTime = na
    var line highLine = na
    var line lowLine = na

    if isNyseOpen
        orbHigh := high
        orbLow := low
        orbStartTime := time
        highLine := na
        lowLine := na
    else if not na(orbStartTime)
        elapsedMinutes = (time - orbStartTime) / 60000
        if elapsedMinutes <= duration
            orbHigh := math.max(high, orbHigh)
            orbLow := math.min(low, orbLow)
        else
            if isVisible
                if na(highLine)
                    highLine := line.new(x1=orbStartTime, y1=orbHigh, x2=time, y2=orbHigh, xloc=xloc.bar_time, color=hCol, width=lineWidth, style=chosenStyle)
                    lowLine  := line.new(x1=orbStartTime, y1=orbLow,  x2=time, y2=orbLow,  xloc=xloc.bar_time, color=lCol, width=lineWidth, style=chosenStyle)
                else
                    line.set_x2(highLine, time)
                    line.set_x2(lowLine, time)
                    line.set_width(highLine, lineWidth)
                    line.set_width(lowLine, lineWidth)
            
            // Push active data metrics out to HUD memory slots regardless of line visibility state
            array.set(activeHighs, internalIdx, orbHigh)
            array.set(activeLows, internalIdx, orbLow)
    int cleanExit = na

// ==========================================
// Process All Tracks Simultaneously
// ==========================================
process_orb(show15m, 15, c15m_H, c15m_L, 0)
process_orb(show30m, 30, c30m_H, c30m_L, 1)
process_orb(show1h,  60, c1h_H,  c1h_L,  2)
process_orb(show4h,  240, c4h_H,  c4h_L,  3)
process_orb(show8h,  480, c8h_H,  c8h_L,  4)
process_orb(show24h, 1440, c24h_H, c24h_L, 5)

// ==========================================
// Top Right Corner HUD Table Engine
// ==========================================
// Thickened borders to width=3 and bright white/gray contrast for sharp gridlines
var table hudTable = table.new(position.top_right, columns=3, rows=7, bgcolor=tableBgColor, border_width=3, border_color=color.new(color.white, 30))

if barstate.islast
    // Render Header Row (Forced BOLD via large typography and monospace font alignment)
    table.cell(hudTable, 0, 0, "TIMEFRAME", text_color=tableTextColor, text_size=fontSize, text_font_family=font.family_monospace)
    table.cell(hudTable, 1, 0, "ORB HIGH",  text_color=tableTextColor, text_size=fontSize, text_font_family=font.family_monospace)
    table.cell(hudTable, 2, 0, "ORB LOW",   text_color=tableTextColor, text_size=fontSize, text_font_family=font.family_monospace)
    
    // Arrays containing meta properties for fast loop formatting
    tfNames      = array.new_string(6)
    tfToggles    = array.new_bool(6)
    tfHighColors = array.new_color(6)
    tfLowColors  = array.new_color(6)
    
    // Package parameters up smoothly
    array.set(tfNames, 0, "15 Min"),  array.set(tfToggles, 0, show15m), array.set(tfHighColors, 0, c15m_H), array.set(tfLowColors, 0, c15m_L)
    array.set(tfNames, 1, "30 Min"),  array.set(tfToggles, 1, show30m), array.set(tfHighColors, 1, c30m_H), array.set(tfLowColors, 1, c30m_L)
    array.set(tfNames, 2, "1 Hour"),  array.set(tfToggles, 2, show1h),  array.set(tfHighColors, 2, c1h_H),  array.set(tfLowColors, 2, c1h_L)
    array.set(tfNames, 3, "4 Hour"),  array.set(tfToggles, 3, show4h),  array.set(tfHighColors, 3, c4h_H),  array.set(tfLowColors, 3, c4h_L)
    array.set(tfNames, 4, "8 Hour"),  array.set(tfToggles, 4, show8h),  array.set(tfHighColors, 4, c8h_H),  array.set(tfLowColors, 4, c8h_L)
    array.set(tfNames, 5, "24 Hour"), array.set(tfToggles, 5, show24h), array.set(tfHighColors, 5, c24h_H), array.set(tfLowColors, 5, c24h_L)
    
    int activeRowIdx = 1
    
    for i = 0 to 5
        if array.get(tfToggles, i)
            float currentH = array.get(activeHighs, i)
            float currentL = array.get(activeLows, i)
            
            string hStr = na(currentH) ? "CALC..." : str.tostring(currentH, "#.##")
            string lStr = na(currentL) ? "CALC..." : str.tostring(currentL, "#.##")
            
            // Build the row elements dynamically (Enforces bold-style clarity using uppercase strings)
            table.cell(hudTable, 0, activeRowIdx, array.get(tfNames, i), text_color=tableTextColor, text_size=fontSize)
            table.cell(hudTable, 1, activeRowIdx, hStr, text_color=array.get(tfHighColors, i), text_size=fontSize)
            table.cell(hudTable, 2, activeRowIdx, lStr, text_color=array.get(tfLowColors, i), text_size=fontSize)
            
            activeRowIdx += 1
            
    // Wipe remaining unused rows cleanly
    if activeRowIdx < 7
        for r = activeRowIdx to 6
            table.cell(hudTable, 0, r, "", bgcolor=color.new(color.black, 100))
            table.cell(hudTable, 1, r, "", bgcolor=color.new(color.black, 100))
            table.cell(hudTable, 2, r, "", bgcolor=color.new(color.black, 100))
````
