# Multi-Asset ORB Indicator (OIL, Gold, Indices, ON)

- url: https://www.tradingview.com/script/fL9WxBcN-Multi-Asset-ORB-Indicator-OIL-Gold-Indices-ON/
- type: indicator
- pine_id: PUB;b7678d188d69471783574b860e6d6d81
- version: 3.0

## Description

Indicator Overview

This indicator is a professional-grade, multi-asset **Opening Range Breakout (ORB)** script written in **Pine Script v6**. It automates the process of tracking high-precision opening ranges across multiple asset classes (Crude Oil, Gold, Indices, and Overnight sessions), handling timezones seamlessly, and giving you clean, clutter-free visual feedback on your charts.

Key Features & Capabilities

1. Automated Asset Filtering

The indicator automatically detects the ticker symbol on your chart and filters which session boxes to display so you don't have to manually change settings when switching markets:

OIL Sessions:** Automatically maps to crude oil products (`CL`, `OIL`, `WTI`, `QM`, `MCL`).
Gold Sessions:** Automatically maps to gold futures (`GC`, `MGC`, `GOLD`).
Indices Sessions:** Automatically maps to major indices (`ES`, `NQ`, `MES`, `MNQ`).
Overnight Sessions:** Enabled universally across **all symbols** on your chart.

2. Precise Eastern Time (EST/EDT) Engine

* All market open, close, and expiration times are calculated using **Eastern Time** via TradingView's `"America/New_York"` time engine.
* If your chart or local computer time is set to **Central Time (CST/CDT)** or any other timezone, the script automatically and accurately shifts the session times so they trigger at the correct corresponding hour in your local view (e.g., a 9:30 AM EST session correctly plots at 8:30 AM CST).

3. Covered Trading Sessions

OIL Sessions:
07:00 AM – 07:05 AM EST (Stops extending at 02:30 PM EST)
 09:00 AM – 09:05 AM EST (Stops extending at 02:30 PM EST)

Gold Sessions:
 08:00 AM – 08:05 AM EST (Stops extending at 01:30 PM EST)
08:20 AM – 08:50 AM EST (Stops extending at 01:30 PM EST)

Indices Sessions:
08:00 AM – 08:15 AM EST (Stops extending at 04:00 PM EST)
09:30 AM – 09:45 AM EST (Stops extending at 04:00 PM EST)
09:30 AM – 10:00 AM EST (Stops extending at 04:00 PM EST)

Overnight Sessions (All Symbols):
06:00 PM – 06:05 PM EST (Stops extending at 03:00 AM EST next day)
06:00 PM – 06:15 PM EST (Stops extending at 03:00 AM EST next day)

4. Customization & Styling Control**

Global Visibility Toggles:** Instantly turn all ORB session boxes or midpoints on or off with master checkboxes.
Individual Session Toggles:** Enable or disable entire asset groups (OIL, Gold, Indices, Overnight) independently.
Color Customization:** Tailor individual background and border tints for every single ORB window to easily distinguish them on your chart.
Line & Border Styling:** Customize the box border and midpoint line styles (**Solid**, Dashed**, or **Dotted**) and adjust their thickness (1 to 5 width) to match your exact chart layout preferences.

How It Works on the Chart

When an ORB time window starts, the indicator records the high and low prices. As soon as the opening range period concludes, it draws a shaded session box and a dashed midpoint line from the start time, extending them forward dynamically until the session's designated stop time. Utilizing `xloc.bar_time`, the script avoids future-bar constraints, ensuring smooth rendering across any historical or live timeframe.

## Source Code

````pine
//@version=6
indicator("Multi-Session ORB Indicator", overlay=true, max_boxes_count=500, max_lines_count=500)

// --- Inputs ---
tz          = input.string("America/New_York", title="Timezone")
inst_mode   = input.string("Auto", title="Instrument Mode", options=["Auto", "Oil", "Gold", "Indices", "All"])

showBoxes   = input.bool(true, title="Show ORB Session Boxes", group="ORB Session Selection")
showMids    = input.bool(true, title="Show ORB Midpoints", group="ORB Session Selection")

// --- Line Style Settings ---
line_style_opt  = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="ORB Line Style")
line_width_opt  = input.int(1, title="Line Width", minval=1, maxval=4, group="ORB Line Style")
mid_style_opt   = input.string("Dashed", title="Midline Style", options=["Solid", "Dashed", "Dotted"], group="ORB Line Style")
mid_width_opt   = input.int(1, title="Midline Width", minval=1, maxval=4, group="ORB Line Style")

// Helper function to map string choices to line styles
f_get_style(style_str) =>
    switch style_str
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

line_style = f_get_style(line_style_opt)
mid_style  = f_get_style(mid_style_opt)

// --- Instrument Detection ---
is_oil_symbol     = str.contains(syminfo.ticker, "CL") or str.contains(syminfo.ticker, "USO") or str.contains(syminfo.ticker, "OIL") or str.contains(syminfo.ticker, "QM") or str.contains(syminfo.ticker, "MCL")
is_gold_symbol    = str.contains(syminfo.ticker, "GC") or str.contains(syminfo.ticker, "GLD") or str.contains(syminfo.ticker, "GOLD") or str.contains(syminfo.ticker, "MGC")
is_indices_symbol = str.contains(syminfo.ticker, "ES") or str.contains(syminfo.ticker, "NQ") or str.contains(syminfo.ticker, "YM") or str.contains(syminfo.ticker, "RTY") or str.contains(syminfo.ticker, "SPY") or str.contains(syminfo.ticker, "QQQ") or str.contains(syminfo.ticker, "MES") or str.contains(syminfo.ticker, "MNQ") or str.contains(syminfo.ticker, "MYM") or str.contains(syminfo.ticker, "M2K")

show_oil     = (inst_mode == "Auto" and is_oil_symbol) or inst_mode == "Oil" or inst_mode == "All"
show_gold    = (inst_mode == "Auto" and is_gold_symbol) or inst_mode == "Gold" or inst_mode == "All"
show_indices = (inst_mode == "Auto" and is_indices_symbol) or inst_mode == "Indices" or inst_mode == "All"
show_on      = inst_mode == "Auto" or inst_mode == "All"

// --- Session Toggles ---
oil1_en     = input.bool(true, title="7:00am EST (5 min) - ends 2:30pm", group="Oil Sessions") and show_oil
oil2_en     = input.bool(true, title="9:00am EST (5 min) - ends 2:30pm", group="Oil Sessions") and show_oil

gold1_en    = input.bool(true, title="8:00am EST (5 min) - ends 1:30pm", group="Gold Sessions") and show_gold
gold2_en    = input.bool(true, title="8:20am EST (30 min) - ends 1:30pm", group="Gold Sessions") and show_gold

ind1_en     = input.bool(true, title="8:00am EST (15 min) - ends 4:00pm", group="Indices Sessions") and show_indices
ind2_en     = input.bool(true, title="9:30am EST (30 min) - ends 4:00pm", group="Indices Sessions") and show_indices
ind3_en     = input.bool(true, title="9:30am EST (15 min level) - ends 4:00pm", group="Indices Sessions") and show_indices

on1_en      = input.bool(true, title="6:00pm EST (5 min) - ends 3:00am", group="Overnight Sessions") and show_on
on2_en      = input.bool(true, title="6:00pm EST (15 min) - ends 3:00am", group="Overnight Sessions") and show_on

// Colors
col_oil1    = input.color(color.new(color.blue, 85), title="Oil – 7:00am EST", group="ORB Colors")
col_oil2    = input.color(color.new(color.navy, 85), title="Oil – 9:00am EST", group="ORB Colors")
col_gold1   = input.color(color.new(color.yellow, 85), title="Gold – 8:00am EST", group="ORB Colors")
col_gold2   = input.color(color.new(color.purple, 85), title="Gold – 8:20am EST", group="ORB Colors")
col_ind1    = input.color(color.new(color.teal, 85), title="Indices – 8:00am EST", group="ORB Colors")
col_ind2    = input.color(color.new(color.maroon, 85), title="Indices – 9:30am EST", group="ORB Colors")
col_ind3    = input.color(color.new(color.fuchsia, 85), title="Indices – 9:30am EST 15min", group="ORB Colors")
col_on1     = input.color(color.new(color.blue, 85), title="6:00pm EST (5 min)", group="ORB Colors")
col_on2     = input.color(color.new(color.orange, 85), title="6:00pm EST (15 min)", group="ORB Colors")

// --- ORB Session Method ---
f_orb(en, startH, startM, durationM, endH, endM, col) =>
    var box b = na
    var line l_top = na
    var line l_bot = na
    var line l_mid = na
    var float orb_high = na
    var float orb_low = na
    var int start_time = na
    var int end_time = na
    
    cur_h = hour(time, tz)
    cur_m = minute(time, tz)
    is_start = (cur_h == startH and cur_m == startM)
    
    if en
        if is_start
            orb_high := high
            orb_low := low
            start_time := time
            
            end_time := timestamp(tz, year, month, dayofmonth, endH, endM)
            if end_time < start_time
                end_time += 86400000 
                
            if showBoxes
                b := box.new(start_time, orb_high, end_time, orb_low, xloc=xloc.bar_time, bgcolor=col, border_color=color.new(col, 20))
                
            l_top := line.new(start_time, orb_high, end_time, orb_high, xloc=xloc.bar_time, color=color.new(col, 0), style=line_style, width=line_width_opt)
            l_bot := line.new(start_time, orb_low, end_time, orb_low, xloc=xloc.bar_time, color=color.new(col, 0), style=line_style, width=line_width_opt)
            
            if showMids
                l_mid := line.new(start_time, (orb_high + orb_low) / 2, end_time, (orb_high + orb_low) / 2, xloc=xloc.bar_time, color=color.new(col, 0), style=mid_style, width=mid_width_opt)
        
        minutes_elapsed = (cur_h - startH) * 60 + (cur_m - startM)
        if minutes_elapsed >= 0 and minutes_elapsed < durationM
            if not na(orb_high)
                orb_high := math.max(orb_high, high)
                orb_low := math.min(orb_low, low)
                
                if showBoxes and not na(b)
                    box.set_top(b, orb_high)
                    box.set_bottom(b, orb_low)
                    
                if not na(l_top)
                    line.set_y1(l_top, orb_high)
                    line.set_y2(l_top, orb_high)
                    
                if not na(l_bot)
                    line.set_y1(l_bot, orb_low)
                    line.set_y2(l_bot, orb_low)
                    
                if showMids and not na(l_mid)
                    line.set_y1(l_mid, (orb_high + orb_low) / 2)
                    line.set_y2(l_mid, (orb_high + orb_low) / 2)

// --- Execute Sessions ---
f_orb(oil1_en, 7, 0, 5, 14, 30, col_oil1)
f_orb(oil2_en, 9, 0, 5, 14, 30, col_oil2)

f_orb(gold1_en, 8, 0, 5, 13, 30, col_gold1)
f_orb(gold2_en, 8, 20, 30, 13, 30, col_gold2)

f_orb(ind1_en, 8, 0, 15, 16, 0, col_ind1)
f_orb(ind2_en, 9, 30, 30, 16, 0, col_ind2)
f_orb(ind3_en, 9, 30, 15, 16, 0, col_ind3)

f_orb(on1_en, 18, 0, 5, 3, 0, col_on1)
f_orb(on2_en, 18, 0, 15, 3, 0, col_on2)

// Dummy plot to satisfy TradingView's drawing validation requirement for overlay scripts
plot(na, title="ORB Status", display=display.none)
````
