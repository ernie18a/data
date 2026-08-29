<!-- tradingview-pine-id: PUB;fc069ed5af954c10bb90cce717273d05 -->
<!-- tradingviewscripts-format: 1 -->
# Global Sessions IST - High/Low & Range Dashboard [v6]

Source: https://www.tradingview.com/script/F8CCfpIN-Global-Sessions-IST-High-Low-Range-Dashboard/

## Description

Overview
Global Sessions IST is a lightweight, clean, and highly customizable session tracking tool designed specifically for traders operating in Indian Standard Time (IST). It dynamically highlights the active market hours for Asia (Tokyo/Hong Kong), London, and New York, helping you identify liquidity sweeps, session ranges, and key intraday turning points without cluttering your price action.

Key Features
IST Native Alignment: Built from the ground up for Indian Standard Time (UTC+5:30), mapping out global session open and close times accurately.

Minimalist Session Boxes: Visualizes session High, Low, and price movement using soft, customizable box fills and subtle border styles.

On-Chart Mini Dashboard: A real-time summary table positioned in the top-right corner that updates each session's:

Session High

Session Low

Total Point Range

DST (Daylight Saving Time) Toggle: Easily adjust London and New York session times by +1 hour with a single setting toggle during summer/winter shifts.

Fully Customizable Visuals: Toggle session boxes, adjust fill opacity, change session colors, or hide the dashboard entirely for a pure price-action view.

How to Use
Identify Session Ranges: Observe how price builds high and low points during the Asian consolidation phase.

Monitor Session Overlaps: Keep an eye on the high-liquidity London–New York overlap (6:30 PM – 9:00 PM IST) for major breakout or reversal trades.

Analyze Range Expansion: Use the mini dashboard to gauge session volatility in points/pip range before entering trades.

Reflective Thought
"What is night for all beings is the time of awakening for the self-controlled."
True market discipline requires awareness when others are asleep. Keep your charts clean, execution sharp, and risk management paramount.

---

## Source Code

````pine
//@version=6
indicator("Global Sessions IST - High/Low & Range Dashboard [v6]", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ==========================================
// 1. INPUT CONFIGURATIONS
// ==========================================

// Display Options
string g_disp        = "Display Style"
bool   i_showBox     = input.bool(true, "Draw Session Boxes", group = g_disp)
bool   i_showDash    = input.bool(true, "Show Info Dashboard (Top Right)", group = g_disp)
int    i_boxFillOpacity = input.int(85, "Box Fill Transparency (0-100)", minval=0, maxval=100, group = g_disp)

// Timezone Setting
string g_time        = "Timezone Configuration"
string i_tz          = input.string("UTC+5:30", "Timezone Offset", options=["UTC+5:30", "Asia/Kolkata"], group = g_time)
bool   i_dst         = input.bool(false, "Enable Summer Time / DST Offset (+1 Hr for US/UK)", group = g_time)

// Asian Session Settings
string g_asia        = "1. Asian Session (Tokyo/HK)"
string i_asiaTime    = input.session("0530-1330:23456", "Asian Time Range (IST)", group = g_asia)
color  i_asiaColor   = input.color(color.new(color.purple, 0), "Color", group = g_asia)

// London Session Settings
string g_lon         = "2. London Session"
string i_lonTimeBase = input.session("1230-2100:23456", "London Time Range (Standard IST)", group = g_lon)
color  i_lonColor    = input.color(color.new(color.blue, 0), "Color", group = g_lon)

// New York Session Settings
string g_ny          = "3. New York Session"
string i_nyTimeBase  = input.session("1830-0230:23456", "New York Time Range (Standard IST)", group = g_ny)
color  i_nyColor     = input.color(color.new(color.orange, 0), "Color", group = g_ny)

// Adjust session times dynamically if DST switch is toggled
string lonTime = i_dst ? "1330-2200:23456" : i_lonTimeBase
string nyTime  = i_dst ? "1930-0330:23456" : i_nyTimeBase

// ==========================================
// 2. HELPER FUNCTIONS
// ==========================================

inSession(sess) =>
    not na(time(timeframe.period, sess, i_tz))

// Function to track High, Low, and Range for each active session
f_processSession(isSession, sessColor) =>
    var float sHigh     = na
    var float sLow      = na
    var box   sBox      = na
    var float lastHigh  = na
    var float lastLow   = na
    var float lastRange = na
    
    if isSession and not isSession[1]
        // Session Start
        sHigh := high
        sLow  := low
        if i_showBox
            sBox := box.new(left = bar_index, top = sHigh, right = bar_index, bottom = sLow, 
                            border_color = sessColor, 
                            bgcolor = color.new(sessColor, i_boxFillOpacity), 
                            border_style = line.style_dotted)
            
    else if isSession
        // During Session
        sHigh := math.max(sHigh, high)
        sLow  := math.min(sLow, low)
        if not na(sBox)
            box.set_top(sBox, sHigh)
            box.set_bottom(sBox, sLow)
            box.set_right(sBox, bar_index)
            
    else if not isSession and isSession[1]
        // Session Close
        lastHigh  := sHigh
        lastLow   := sLow
        lastRange := (sHigh - sLow)
        
    [sHigh, sLow, lastHigh, lastLow, lastRange]

// Table Row Helper Function (Must be in global scope)
f_fillRow(tbl, row, name, hVal, lVal, rVal, rowColor) =>
    table.cell(tbl, 0, row, name, text_color = rowColor, text_size = size.small)
    table.cell(tbl, 1, row, na(hVal) ? "-" : str.tostring(hVal, "#.##"), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, row, na(lVal) ? "-" : str.tostring(lVal, "#.##"), text_color = color.white, text_size = size.small)
    table.cell(tbl, 3, row, na(rVal) ? "-" : str.tostring(rVal, "#.##"), text_color = color.white, text_size = size.small)

// ==========================================
// 3. SESSION EXECUTION
// ==========================================

bool inAsia   = inSession(i_asiaTime)
bool inLondon = inSession(lonTime)
bool inNY     = inSession(nyTime)

[asiaCurH, asiaCurL, asiaH, asiaL, asiaRange] = f_processSession(inAsia, i_asiaColor)
[lonCurH, lonCurL, lonH, lonL, lonRange]       = f_processSession(inLondon, i_lonColor)
[nyCurH, nyCurL, nyH, nyL, nyRange]             = f_processSession(inNY, i_nyColor)

// ==========================================
// 4. MINI DASHBOARD (TOP RIGHT)
// ==========================================

var table dash = table.new(position = position.top_right, columns = 4, rows = 4, 
                           bgcolor = color.new(color.black, 20), 
                           border_color = color.gray, border_width = 1)

if barstate.islast and i_showDash
    // Table Headers
    table.cell(dash, 0, 0, "Session", bgcolor = color.gray, text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 0, "High", bgcolor = color.gray, text_color = color.white, text_size = size.small)
    table.cell(dash, 2, 0, "Low", bgcolor = color.gray, text_color = color.white, text_size = size.small)
    table.cell(dash, 3, 0, "Range (Pts)", bgcolor = color.gray, text_color = color.white, text_size = size.small)

    // Populate rows using the outer helper function
    f_fillRow(dash, 1, "Asia", inAsia ? asiaCurH : asiaH, inAsia ? asiaCurL : asiaL, inAsia ? (asiaCurH - asiaCurL) : asiaRange, i_asiaColor)
    f_fillRow(dash, 2, "London", inLondon ? lonCurH : lonH, inLondon ? lonCurL : lonL, inLondon ? (lonCurH - lonCurL) : lonRange, i_lonColor)
    f_fillRow(dash, 3, "New York", inNY ? nyCurH : nyL, inNY ? nyCurL : nyL, inNY ? (nyCurH - nyCurL) : nyRange, i_nyColor)
````
