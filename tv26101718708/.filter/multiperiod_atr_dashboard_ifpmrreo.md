# Multi-Period ATR Dashboard

- url: https://www.tradingview.com/script/IFPMrreo-Multi-Period-ATR-Dashboard/
- type: indicator
- pine_id: PUB;0dd0acb2cb7b448db2a75da1e4f3f4d4
- version: 6.0

## Description

Instantly track market expansion, compression, and structural chop with a clean, customizable multi-timeframe dashboard.

The Multi-Period ATR Dashboard compares rolling volatility across multiple lookbacks (ranging from 50-day down to 3-day, previous day, and a live intraday true range) directly against a customizable long-term baseline (default 365-day ATR).

🚀 Key Highlights:
Dynamic Color-Coding: Instantly visualizes whether timeframes are in a compressed dead zone (red), transition zone (yellow), or healthy expansion breakout (green).

Live Session Tracking: Includes an optional Today (Live) row to monitor developing intraday range versus your baseline in real time.

Smart Verdict Banner: Features a built-in status banner at the bottom of the table to summarize market conditions at a glance.

Fully Customizable: Easily toggle timeframes on or off, adjust lookback lengths, modify threshold percentages, and place the dashboard anywhere on your chart (Top/Bottom, Left/Right).

Built for day traders and swing traders looking to stay aligned with structural volatility shifts and avoid high-chop traps.

## Source Code

````pine
//@version=6
indicator("Multi-Period RTH Session Range Dashboard", overlay=true)

// User inputs for table customization
t_pos       = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
t_size      = input.string("Normal", "Text Size", options=["Small", "Normal", "Large", "Huge"])
show_bounds = input.bool(true, "Show Min / Max Price Bounds")
compact_mode = input.bool(false, "Compact Mode (Banner & Summary Only)")

// Threshold & Zone Settings
chop_thresh   = input.float(75.0, "🔴 Red / Choppy Market Max Threshold (%)")
yellow_lower  = input.float(75.0, "🟡 Yellow Zone Start (%)")
yellow_upper  = input.float(89.9, "🟡 Yellow Zone End (%)")
green_thresh  = input.float(90.0, "🟢 Green / Expansion Min Threshold (%)")

// Baseline (Always active)
p1 = input.int(365, "Baseline Period (Days)")

// Period toggles and day inputs
use_p2 = input.bool(true, "Enable Period 2")
p2     = input.int(50,   "Period 2 Days")

use_p3 = input.bool(true, "Enable Period 3")
p3     = input.int(21,   "Period 21 Days")

use_p4 = input.bool(true, "Enable Period 4")
p4     = input.int(14,   "Period 14 Days")

use_p5 = input.bool(true, "Enable Period 5")
p5     = input.int(7,    "Period 7 Days")

use_p6 = input.bool(true, "Enable Period 3 (3d)")
p6     = input.int(3,    "Period 3 Days")

use_p7 = input.bool(true, "Enable Previous Day (1d)")
p7     = input.int(1,    "Period 1 Day")

use_today = input.bool(true, "Enable Today's Live Range (TR)")

// Map position string to TradingView constants
pos = t_pos == "Top Right" ? position.top_right : 
      t_pos == "Top Left" ? position.top_left : 
      t_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

// Map text size string to TradingView constants
sz = t_size == "Small" ? size.small : 
     t_size == "Normal" ? size.normal : 
     t_size == "Large" ? size.large : size.huge

// --- UNIFIED DAILY SECURITY FEEDS FOR ALL HISTORICAL PERIODS ---
// Pulling completed daily bars ([1]) guarantees 100% identical values across 1-min, 15-min, and hourly charts.
[atr1, high1, low1] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, p1)[1], ta.highest(high, p1)[1], ta.lowest(low, p1)[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[atr2, high2, low2] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, p2)[1], ta.highest(high, p2)[1], ta.lowest(low, p2)[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[atr3, high3, low3] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, p3)[1], ta.highest(high, p3)[1], ta.lowest(low, p3)[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[atr4, high4, low4] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, p4)[1], ta.highest(high, p4)[1], ta.lowest(low, p4)[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[atr5, high5, low5] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, p5)[1], ta.highest(high, p5)[1], ta.lowest(low, p5)[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[atr6, high6, low6] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, p6)[1], ta.highest(high, p6)[1], ta.lowest(low, p6)[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[atr7, prevRthHigh, prevRthLow] = request.security(syminfo.tickerid, "D", [high[1] - low[1], high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// --- LIVE INTRADAY SESSION TRACKING FOR TODAY ONLY ---
bool isRTH = not na(time(timeframe.period, "0930-1600:23456", "America/New_York"))
var float curRthHigh = na
var float curRthLow  = na

int nyYear  = year(time, "America/New_York")
int nyMonth = month(time, "America/New_York")
int nyDay   = dayofmonth(time, "America/New_York")
var int lastNyDay = na

bool newNyDay = na(lastNyDay) or (nyDay != lastNyDay)

if newNyDay
    curRthHigh := na
    curRthLow  := na
    lastNyDay  := nyDay

if isRTH
    curRthHigh := na(curRthHigh) ? high : math.max(curRthHigh, high)
    curRthLow  := na(curRthLow) ? low : math.min(curRthLow, low)

bool is_weekday = dayofweek(time, "America/New_York") >= dayofweek.monday and dayofweek(time, "America/New_York") <= dayofweek.friday
int open_timestamp = timestamp("America/New_York", nyYear, nyMonth, nyDay, 9, 30)
bool rth_has_opened = not is_weekday or (time >= open_timestamp)

float raw_today_tr = nz(curRthHigh - curRthLow, 0.0)
float today_tr = rth_has_opened ? raw_today_tr : 0.0

if today_tr == 0.0 and isRTH
    today_tr := nz(curRthHigh - curRthLow, high - low)

// Calculate Ratios (% of baseline p1)
ratio2 = nz((atr2 / atr1) * 100, 0)
ratio3 = nz((atr3 / atr1) * 100, 0)
ratio4 = nz((atr4 / atr1) * 100, 0)
ratio5 = nz((atr5 / atr1) * 100, 0)
ratio6 = nz((atr6 / atr1) * 100, 0)
ratio7 = nz((atr7 / atr1) * 100, 0)
ratio_today = nz((today_tr / atr1) * 100, 0)

// Dynamic coloring based on custom user zones
f_getColor(float r) =>
    r < chop_thresh ? color.red : r >= green_thresh ? color.green : color.yellow

col2 = f_getColor(ratio2)
col3 = f_getColor(ratio3)
col4 = f_getColor(ratio4)
col5 = f_getColor(ratio5)
col6 = f_getColor(ratio6)
col7 = f_getColor(ratio7)
col_today = color.white 

// --- VERDICT LOGIC ---
string verdict_text = ""
color  verdict_col  = color.yellow

bool check_p6_chop = use_p6 and ratio6 < chop_thresh
bool check_p7_chop = use_p7 and ratio7 < chop_thresh
bool check_p6_bull = use_p6 and ratio6 >= green_thresh
bool check_p7_bull = use_p7 and ratio7 >= green_thresh

if check_p6_chop and check_p7_chop
    verdict_text := "🔴 CHOPPY MARKET (Consolidation)"
    verdict_col  := color.red
else if check_p6_bull or check_p7_bull or ratio6 >= green_thresh
    verdict_text := "🟢 HEALTHY EXPANSION"
    verdict_col  := color.green
else
    verdict_text := "🟡 SLOW / CHOPPY (Transition Zone)"
    verdict_col  := color.yellow

// Dynamically count total rows needed based on mode and active inputs
int total_rows = 0
int num_cols = 1

if compact_mode
    total_rows := 2 
    num_cols   := 1
else
    total_rows := 2 
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
    total_rows += 1 
    num_cols := show_bounds ? 4 : 3

var table dashboard = table.new(position = pos, columns = num_cols, rows = total_rows, bgcolor = color.new(#1E222D, 10), border_width = 1, border_color = color.gray)

if barstate.islast
    int current_row = 0
    
    if compact_mode
        table.cell(dashboard, 0, current_row, "RTH Market State Summary", text_color = color.white, text_size = sz, bgcolor = color.gray)
        current_row += 1
        table.cell(dashboard, 0, current_row, verdict_text, text_color = color.black, text_size = sz, bgcolor = verdict_col)
    else
        table.cell(dashboard, 0, current_row, "Timeframe", text_color = color.white, text_size = sz, bgcolor = color.gray)
        if show_bounds
            table.cell(dashboard, 1, current_row, "RTH Min - Max", text_color = color.white, text_size = sz, bgcolor = color.gray)
        table.cell(dashboard, show_bounds ? 2 : 1, current_row, "RTH Range", text_color = color.white, text_size = sz, bgcolor = color.gray)
        table.cell(dashboard, show_bounds ? 3 : 2, current_row, "% of " + str.tostring(p1) + "d", text_color = color.white, text_size = sz, bgcolor = color.gray)
        current_row += 1
        
        // Baseline (365d)
        table.cell(dashboard, 0, current_row, str.tostring(p1) + "-Day", text_color = color.white, text_size = sz)
        if show_bounds
            table.cell(dashboard, 1, current_row, str.tostring(low1, "#.##") + " - " + str.tostring(high1, "#.##"), text_color = color.gray, text_size = sz)
        table.cell(dashboard, show_bounds ? 2 : 1, current_row, str.tostring(atr1, "#.##"), text_color = color.white, text_size = sz)
        table.cell(dashboard, show_bounds ? 3 : 2, current_row, "100%", text_color = color.gray, text_size = sz)
        current_row += 1
        
        // Period 2 (50d)
        if use_p2
            table.cell(dashboard, 0, current_row, str.tostring(p2) + "-Day", text_color = color.white, text_size = sz)
            if show_bounds
                table.cell(dashboard, 1, current_row, str.tostring(low2, "#.##") + " - " + str.tostring(high2, "#.##"), text_color = color.gray, text_size = sz)
            table.cell(dashboard, show_bounds ? 2 : 1, current_row, str.tostring(atr2, "#.##"), text_color = col2, text_size = sz)
            table.cell(dashboard, show_bounds ? 3 : 2, current_row, str.tostring(ratio2, "#.0") + "%", text_color = col2, text_size = sz)
            current_row += 1
            
        // Period 3 (21d)
        if use_p3
            table.cell(dashboard, 0, current_row, str.tostring(p3) + "-Day", text_color = color.white, text_size = sz)
            if show_bounds
                table.cell(dashboard, 1, current_row, str.tostring(low3, "#.##") + " - " + str.tostring(high3, "#.##"), text_color = color.gray, text_size = sz)
            table.cell(dashboard, show_bounds ? 2 : 1, current_row, str.tostring(atr3, "#.##"), text_color = col3, text_size = sz)
            table.cell(dashboard, show_bounds ? 3 : 2, current_row, str.tostring(ratio3, "#.0") + "%", text_color = col3, text_size = sz)
            current_row += 1

        // Period 4 (14d)
        if use_p4
            table.cell(dashboard, 0, current_row, str.tostring(p4) + "-Day", text_color = color.white, text_size = sz)
            if show_bounds
                table.cell(dashboard, 1, current_row, str.tostring(low4, "#.##") + " - " + str.tostring(high4, "#.##"), text_color = color.gray, text_size = sz)
            table.cell(dashboard, show_bounds ? 2 : 1, current_row, str.tostring(atr4, "#.##"), text_color = col4, text_size = sz)
            table.cell(dashboard, show_bounds ? 3 : 2, current_row, str.tostring(ratio4, "#.0") + "%", text_color = col4, text_size = sz)
            current_row += 1
            
        // Period 5 (7d)
        if use_p5
            table.cell(dashboard, 0, current_row, str.tostring(p5) + "-Day", text_color = color.white, text_size = sz)
            if show_bounds
                table.cell(dashboard, 1, current_row, str.tostring(low5, "#.##") + " - " + str.tostring(high5, "#.##"), text_color = color.gray, text_size = sz)
            table.cell(dashboard, show_bounds ? 2 : 1, current_row, str.tostring(atr5, "#.##"), text_color = col5, text_size = sz)
            table.cell(dashboard, show_bounds ? 3 : 2, current_row, str.tostring(ratio5, "#.0") + "%", text_color = col5, text_size = sz)
            current_row += 1

        // Period 6 (3d)
        if use_p6
            table.cell(dashboard, 0, current_row, str.tostring(p6) + "-Day", text_color = color.white, text_size = sz)
            if show_bounds
                table.cell(dashboard, 1, current_row, str.tostring(low6, "#.##") + " - " + str.tostring(high6, "#.##"), text_color = color.gray, text_size = sz)
            table.cell(dashboard, show_bounds ? 2 : 1, current_row, str.tostring(atr6, "#.##"), text_color = col6, text_size = sz)
            table.cell(dashboard, show_bounds ? 3 : 2, current_row, str.tostring(ratio6, "#.0") + "%", text_color = col6, text_size = sz)
            current_row += 1

        // Period 7 (Previous Day)
        if use_p7
            table.cell(dashboard, 0, current_row, "Prev Day (1d)", text_color = color.white, text_size = sz)
            if show_bounds
                table.cell(dashboard, 1, current_row, str.tostring(prevRthLow, "#.##") + " - " + str.tostring(prevRthHigh, "#.##"), text_color = color.gray, text_size = sz)
            table.cell(dashboard, show_bounds ? 2 : 1, current_row, str.tostring(atr7, "#.##"), text_color = col7, text_size = sz)
            table.cell(dashboard, show_bounds ? 3 : 2, current_row, str.tostring(ratio7, "#.0") + "%", text_color = col7, text_size = sz)
            current_row += 1

        // Today's Live Range
        if use_today
            table.cell(dashboard, 0, current_row, "Today (Live)", text_color = color.white, text_size = sz)
            if show_bounds
                table.cell(dashboard, 1, current_row, str.tostring(curRthLow, "#.##") + " - " + str.tostring(curRthHigh, "#.##"), text_color = color.gray, text_size = sz)
            table.cell(dashboard, show_bounds ? 2 : 1, current_row, str.tostring(today_tr, "#.##"), text_color = col_today, text_size = sz)
            table.cell(dashboard, show_bounds ? 3 : 2, current_row, str.tostring(ratio_today, "#.0") + "%", text_color = col_today, text_size = sz)
            current_row += 1

        // Verdict Banner
        table.merge_cells(dashboard, 0, current_row, num_cols - 1, current_row)
        table.cell(dashboard, 0, current_row, verdict_text, text_color = color.black, text_size = sz, bgcolor = verdict_col)
````
