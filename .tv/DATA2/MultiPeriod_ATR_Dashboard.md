<!-- tradingview-pine-id: PUB;0dd0acb2cb7b448db2a75da1e4f3f4d4 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Period ATR Dashboard

Source: https://www.tradingview.com/script/IFPMrreo-Multi-Period-ATR-Dashboard/

## Description

Instantly track market expansion, compression, and structural chop with a clean, customizable multi-timeframe dashboard.

The Multi-Period ATR Dashboard compares rolling volatility across multiple lookbacks (ranging from 50-day down to 3-day, previous day, and a live intraday true range) directly against a customizable long-term baseline (default 365-day ATR).

🚀 Key Highlights:
Dynamic Color-Coding: Instantly visualizes whether timeframes are in a compressed dead zone (red), transition zone (yellow), or healthy expansion breakout (green).

Live Session Tracking: Includes an optional Today (Live) row to monitor developing intraday range versus your baseline in real time.

Smart Verdict Banner: Features a built-in status banner at the bottom of the table to summarize market conditions at a glance.

Fully Customizable: Easily toggle timeframes on or off, adjust lookback lengths, modify threshold percentages, and place the dashboard anywhere on your chart (Top/Bottom, Left/Right).

Built for day traders and swing traders looking to stay aligned with structural volatility shifts and avoid high-chop traps.

---

## Source Code

````pine
//@version=6
indicator("Multi-Period ATR Dashboard", overlay=true)

// User inputs for table customization
t_pos   = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
t_size  = input.string("Normal", "Text Size", options=["Small", "Normal", "Large", "Huge"])

// Threshold & Zone Settings
dead_thresh   = input.float(75.0, "🔴 Red / Chop Max Threshold (%)")
yellow_lower  = input.float(75.0, "🟡 Yellow Zone Start (%)")
yellow_upper  = input.float(99.9, "🟡 Yellow Zone End (%)")
green_thresh  = input.float(100.0, "🟢 Green / Expansion Min Threshold (%)")

// Verdict Explanations & Notes (Settings Tooltips)
var string G_NOTE_RED    = "🔴 RED BANNER (HIGH CHOP / CONSOLIDATION): Triggered when 3-day ATR is under 75%."
var string G_NOTE_GREEN  = "🟢 GREEN BANNER (HEALTHY PUSHTHROUGH): Triggered when 3-day ATR is 100% or higher."
var string G_NOTE_YELLOW = "🟡 YELLOW BANNER (TRANSITION): Triggered in all other cases (e.g., single green day while 3-day trend remains below expansion)."

// Settings Group: Dashboard Verdict Guide
dummy_note1 = input.string(G_NOTE_RED, "📌 Verdict Logic Guide (1/3)")
dummy_note2 = input.string(G_NOTE_GREEN, "📌 Verdict Logic Guide (2/3)")
dummy_note3 = input.string(G_NOTE_YELLOW, "📌 Verdict Logic Guide (3/3)")

// Baseline (Always active)
p1 = input.int(365, "Baseline Period (Days)")

// Period toggles and day inputs
use_p2 = input.bool(true, "Enable Period 2")
p2     = input.int(50,   "Period 2 Days")

use_p3 = input.bool(true, "Enable Period 3")
p3     = input.int(21,   "Period 3 Days")

use_p4 = input.bool(true, "Enable Period 4")
p4     = input.int(14,   "Period 4 Days")

use_p5 = input.bool(true, "Enable Period 5")
p5     = input.int(7,    "Period 5 Days")

use_p6 = input.bool(true, "Enable Period 6")
p6     = input.int(3,    "Period 6 Days")

use_p7 = input.bool(true, "Enable Previous Day (1d)")
p7     = input.int(1,    "Period 7 Days")

use_today = input.bool(true, "Enable Today's Live Range (TR)")

// Map position string to TradingView constants
pos = t_pos == "Top Right" ? position.top_right : 
      t_pos == "Top Left" ? position.top_left : 
      t_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

// Map text size string to TradingView constants
sz = t_size == "Small" ? size.small : 
     t_size == "Normal" ? size.normal : 
     t_size == "Large" ? size.large : size.huge

// Calculate ATR for periods on Daily timeframe 
atr1 = request.security(syminfo.tickerid, "D", ta.atr(p1))
atr2 = request.security(syminfo.tickerid, "D", ta.atr(p2))
atr3 = request.security(syminfo.tickerid, "D", ta.atr(p3))
atr4 = request.security(syminfo.tickerid, "D", ta.atr(p4))
atr5 = request.security(syminfo.tickerid, "D", ta.atr(p5))
atr6 = request.security(syminfo.tickerid, "D", ta.atr(p6))
atr7 = request.security(syminfo.tickerid, "D", ta.tr(true)[1]) 

// Calculate Today's True Range (Live developing range on current bar)
float today_tr = request.security(syminfo.tickerid, "D", ta.tr(true))

// Calculate Ratios (% of baseline p1)
ratio2 = (atr2 / atr1) * 100
ratio3 = (atr3 / atr1) * 100
ratio4 = (atr4 / atr1) * 100
ratio5 = (atr5 / atr1) * 100
ratio6 = (atr6 / atr1) * 100
ratio7 = (atr7 / atr1) * 100
ratio_today = (today_tr / atr1) * 100

// Dynamic coloring based on custom user zones
f_getColor(float r) =>
    r < dead_thresh ? color.red : r >= green_thresh ? color.green : color.yellow

col2 = f_getColor(ratio2)
col3 = f_getColor(ratio3)
col4 = f_getColor(ratio4)
col5 = f_getColor(ratio5)
col6 = f_getColor(ratio6)
col7 = f_getColor(ratio7)
col_today = f_getColor(ratio_today)

// Verdict Logic
string verdict_text = ""
color  verdict_col  = color.yellow

bool check_p6_dead = use_p6 and ratio6 < dead_thresh
bool check_p7_dead = use_p7 and ratio7 < dead_thresh
bool check_p6_bull = use_p6 and ratio6 >= green_thresh
bool check_p7_bull = use_p7 and ratio7 >= green_thresh

if check_p6_dead
    verdict_text := "🔴 HIGH CHOP (Consolidation)"
    verdict_col  := color.red
else if check_p6_bull
    verdict_text := "🟢 HEALTHY PUSHTHROUGH"
    verdict_col  := color.green
else
    verdict_text := "🟡 SLOW / CHOPPY (Transition Zone)"
    verdict_col  := color.yellow

// Dynamically count total rows needed based on what's enabled
int total_rows = 2 // Header + Baseline always shown
if use_p2
    total_rows += 1
if use_p3
    total_rows += 1
if use_p4
    total_rows += 1
if use_p5
    total_rows += 1
if use_p6
    total_rows += 1
if use_p7
    total_rows += 1
if use_today
    total_rows += 1
total_rows += 1 // Verdict row

var table dashboard = table.new(position = pos, columns = 3, rows = total_rows, bgcolor = color.new(#1E222D, 10), border_width = 1, border_color = color.gray)

if barstate.islast
    int current_row = 0
    
    // Header
    table.cell(dashboard, 0, current_row, "Timeframe", text_color = color.white, text_size = sz, bgcolor = color.gray)
    table.cell(dashboard, 1, current_row, "ATR / TR", text_color = color.white, text_size = sz, bgcolor = color.gray)
    table.cell(dashboard, 2, current_row, "% of " + str.tostring(p1) + "d", text_color = color.white, text_size = sz, bgcolor = color.gray)
    current_row += 1
    
    // Baseline (365d)
    table.cell(dashboard, 0, current_row, str.tostring(p1) + "-Day", text_color = color.white, text_size = sz)
    table.cell(dashboard, 1, current_row, str.tostring(atr1, "#.##"), text_color = color.white, text_size = sz)
    table.cell(dashboard, 2, current_row, "100%", text_color = color.gray, text_size = sz)
    current_row += 1
    
    // Period 2 (50d)
    if use_p2
        table.cell(dashboard, 0, current_row, str.tostring(p2) + "-Day", text_color = color.white, text_size = sz)
        table.cell(dashboard, 1, current_row, str.tostring(atr2, "#.##"), text_color = col2, text_size = sz)
        table.cell(dashboard, 2, current_row, str.tostring(ratio2, "#.0") + "%", text_color = col2, text_size = sz)
        current_row += 1
        
    // Period 3 (21d)
    if use_p3
        table.cell(dashboard, 0, current_row, str.tostring(p3) + "-Day", text_color = color.white, text_size = sz)
        table.cell(dashboard, 1, current_row, str.tostring(atr3, "#.##"), text_color = col3, text_size = sz)
        table.cell(dashboard, 2, current_row, str.tostring(ratio3, "#.0") + "%", text_color = col3, text_size = sz)
        current_row += 1

    // Period 4 (14d)
    if use_p4
        table.cell(dashboard, 0, current_row, str.tostring(p4) + "-Day", text_color = color.white, text_size = sz)
        table.cell(dashboard, 1, current_row, str.tostring(atr4, "#.##"), text_color = col4, text_size = sz)
        table.cell(dashboard, 2, current_row, str.tostring(ratio4, "#.0") + "%", text_color = col4, text_size = sz)
        current_row += 1
        
    // Period 5 (7d)
    if use_p5
        table.cell(dashboard, 0, current_row, str.tostring(p5) + "-Day", text_color = color.white, text_size = sz)
        table.cell(dashboard, 1, current_row, str.tostring(atr5, "#.##"), text_color = col5, text_size = sz)
        table.cell(dashboard, 2, current_row, str.tostring(ratio5, "#.0") + "%", text_color = col5, text_size = sz)
        current_row += 1

    // Period 6 (3d)
    if use_p6
        table.cell(dashboard, 0, current_row, str.tostring(p6) + "-Day", text_color = color.white, text_size = sz)
        table.cell(dashboard, 1, current_row, str.tostring(atr6, "#.##"), text_color = col6, text_size = sz)
        table.cell(dashboard, 2, current_row, str.tostring(ratio6, "#.0") + "%", text_color = col6, text_size = sz)
        current_row += 1

    // Period 7 (Previous Day)
    if use_p7
        table.cell(dashboard, 0, current_row, "Prev Day (1d)", text_color = color.white, text_size = sz)
        table.cell(dashboard, 1, current_row, str.tostring(atr7, "#.##"), text_color = col7, text_size = sz)
        table.cell(dashboard, 2, current_row, str.tostring(ratio7, "#.0") + "%", text_color = col7, text_size = sz)
        current_row += 1

    // Today's Live True Range
    if use_today
        table.cell(dashboard, 0, current_row, "Today (Live)", text_color = color.white, text_size = sz)
        table.cell(dashboard, 1, current_row, str.tostring(today_tr, "#.##"), text_color = col_today, text_size = sz)
        table.cell(dashboard, 2, current_row, str.tostring(ratio_today, "#.0") + "%", text_color = col_today, text_size = sz)
        current_row += 1

    // Verdict Banner
    table.merge_cells(dashboard, 0, current_row, 2, current_row)
    table.cell(dashboard, 0, current_row, verdict_text, text_color = color.black, text_size = sz, bgcolor = verdict_col)
````
