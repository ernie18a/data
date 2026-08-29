<!-- tradingview-pine-id: PUB;391532300a374452bad109a14de5c0f6 -->
<!-- tradingviewscripts-format: 1 -->
# Dynamic SMC & Market Structure PRO

Source: https://www.tradingview.com/script/j5Sp5u7i-Dynamic-SMC-Market-Structure-PRO/

## Description

Dynamic SMC and Market Structure PRO

Dynamic SMC and Market Structure PRO is a comprehensive technical analysis tool designed for price action traders and Smart Money Concepts practitioners. It focuses on mapping structural context, tracking key daily and session liquidity levels, and highlighting major market turning points without cluttering your chart.

Key Features Overview

1. Major Swing Extreme Highlights
Automatically identifies major market peaks and bottoms. Major highs are highlighted with clean red shapes and major lows with clean green shapes. This gives traders an instant visual reading of macro market extremes.

2. Smart Money Structure Engine
Tracks real time market context by automatically identifying Break of Structure (BOS) for trend continuation and Change of Character (CHoCH) for potential trend reversals on valid swing points.

3. Dynamic Supply and Demand Zones
Plots high probability supply and demand areas directly on your chart. These dynamic zones automatically adjust and disappear as soon as price breaks through them, ensuring your charting area stays clean.

4. Auto Disappearing Previous Day High and Low
Projects active Previous Day High (PDH) and Previous Day Low (PDL) levels. As soon as price breaks or sweeps these daily liquidity boundaries, the lines automatically delete to keep focus on active price action.

5. Auto Disappearing Session Liquidity
Tracks Asian session highs and lows. Includes a smart proximity filter that prevents visual clutter when session levels align closely with daily highs or lows. Lines automatically disappear when swept by price.

6. Fibonacci 0.5 Equilibrium Range
Calculates the 50 percent Fibonacci Equilibrium line across recent price swings. This helps traders easily distinguish between Premium zones above 50 percent and Discount zones below 50 percent.

7. Clean Dashboard Panel
Displays an on screen information panel summarizing current structure trend, pricing zone state, daily liquidity sweep status, and active supply or demand zone counts.

How to Use

Step 1: Determine Structural Context
Check the market structure labels (BOS/CHoCH) and the Dashboard Panel to determine whether the market is currently in a bullish or bearish structure trend.

Step 2: Identify Premium vs Discount Pricing
Use the 0.5 Equilibrium Line to contextualize price position:
- Premium Zone (Above 0.5 EQ): Ideal area to evaluate short setups near active Supply Zones or recent Major High shapes.
- Discount Zone (Below 0.5 EQ): Ideal area to evaluate long setups near active Demand Zones or recent Major Low shapes.

Step 3: Monitor Liquidity Sweeps
Watch how price interacts with Previous Day High/Low and Session High/Low levels. When price sweeps one of these levels and the line disappears, look for a CHoCH reaction for potential reversal setups.

Step 4: Execute on Zone Reactions
Evaluate price action inside active Supply and Demand zones. When price enters a zone in alignment with the broader structural trend, look for lower timeframe confirmation.

Settings Overview

Major Swing Extremes Settings
- Show Major Swing High/Low Shapes: Toggle visibility of major high and low shapes.
- Major Swing Lookback Sensitivity: Adjusts the pivot lookback length used to detect major market extremes.

Smart Money Structure Settings
- Show BOS and CHoCH Lines: Toggle visibility of structural break lines and text tags.
- Structure Sensitivity (Pivot Length): Controls how sensitive the script is to structural swing points.

Dynamic Supply and Demand Settings
- Show Dynamic Supply and Demand Zones: Toggle display of active supply and demand boxes.
- Max Active Zones Per Side: Controls the maximum number of active supply or demand zones displayed simultaneously.
- Zone Transparency: Adjusts the color opacity of the supply and demand boxes.

Auto Disappearing PDH and PDL Settings
- Show Active PDH / PDL: Toggle display of Previous Day High and Low lines.

Session Highs and Lows Settings
- Show Session High/Low Lines: Toggle display of session liquidity lines.
- Clutter Distance Threshold: Sets the distance threshold in pips or points to prevent overlapping lines when levels are close.

Fibonacci Equilibrium Settings
- Show 0.5 Equilibrium Line: Toggle display of the 50 percent mid point level.
- Equilibrium Lookback Range: Adjusts the lookback period used for calculating recent swing highs and lows.

Pro Tips for Effective Usage

Tip 1: Trade in Alignment with Macro Extremes
Higher probability trade setups occur when price retests a Demand Zone near a Green Major Low shape, or a Supply Zone near a Red Major High shape.

Tip 2: Multi Timeframe Alignment
Mark major structure and supply/demand zones on higher timeframes like 1 Hour or 4 Hour, then switch to lower timeframes like 5 Min or 15 Min for CHoCH entry confirmation.

Tip 3: Pay Attention to Swept Levels
When a PDH or Session High line disappears after price spikes through it, observe if price quickly reverses back inside the range. This often signals institutional liquidity hunting.

Things to Avoid

1. Avoid Entering Inside Invalidated Zones
Do not trade setups from supply or demand zones that have already been broken through by price closes.

2. Avoid Counter Trend Entries at Equilibrium
Do not take aggressive short entries right at the 0.5 Equilibrium line when the market is making strong consecutive bullish BOS breaks.

3. Avoid Over Sensitivity on Low Timeframes
Do not use extremely low pivot lookback settings on sub minute charts to avoid unnecessary noise in structure detection.

Disclaimer
This tool is built strictly for educational and analytical purposes. It does not offer financial advice, trade signals, or guaranteed outcomes. Always practice proper risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ACE_Chart_Logic

//@version=6
// ==============================================================================================
//           D Y N A M I C   S M C   &   M A R K E T   S T R U C T U R E   P R O
// ==============================================================================================

indicator("Dynamic SMC & Market Structure PRO", "Dynamic SMC PRO", overlay = true, max_lines_count = 500, max_boxes_count = 100, max_labels_count = 500)

// 1. INPUTS & FULL CUSTOMIZATION PANEL
g_major           = "===== MAJOR SWING EXTREMES (SHAPES ONLY) ====="
show_major_swings = input.bool(true, "Show Major Swing High/Low Shapes", group=g_major)
major_len         = input.int(20, "Major Swing Lookback Sensitivity", minval=5, maxval=100, group=g_major)
c_major_hh        = input.color(#ff1744, "Major High Color (Red Shape)", group=g_major)
c_major_hl        = input.color(#00e676, "Major Low Color (Green Shape)", group=g_major)

g_smc             = "===== SMART MONEY STRUCTURE (BOS & CHOCH) ====="
show_smc          = input.bool(true, "Show BOS & CHoCH Lines", group=g_smc)
smc_len           = input.int(8, "Structure Sensitivity (Pivot Length)", minval=3, group=g_smc)
c_bull_smc        = input.color(#00e676, "Bullish Structure Color", group=g_smc)
c_bear_smc        = input.color(#ff1744, "Bearish Structure Color", group=g_smc)

g_zones           = "===== DYNAMIC SUPPLY & DEMAND ZONES ====="
show_zones        = input.bool(true, "Show Dynamic Supply & Demand Zones", group=g_zones)
max_zones         = input.int(4, "Max Active Zones Per Side", minval=1, maxval=10, group=g_zones)
zone_opacity      = input.int(80, "Zone Transparency (0-100)", minval=0, maxval=100, group=g_zones)
c_supply_zone     = input.color(#ff1744, "Supply Zone Color", group=g_zones)
c_demand_zone     = input.color(#00e676, "Demand Zone Color", group=g_zones)

g_pdh             = "===== AUTO-DISAPPEARING PDH & PDL ====="
show_pdh_pdl      = input.bool(true, "Show Active PDH / PDL", group=g_pdh)
c_pdh             = input.color(#00e5ff, "PDH Color", group=g_pdh)
c_pdl             = input.color(#ffea00, "PDL Color", group=g_pdh)

g_sess            = "===== AUTO-DISAPPEARING SESSION HIGHS & LOWS ====="
show_sessions     = input.bool(true, "Show Session High/Low Lines", group=g_sess)
c_asia            = input.color(#29b6f6, "Asia High/Low Color", group=g_sess)
merge_dist_pips   = input.float(15.0, "Clutter Distance Threshold (Pips / Gold $)", minval=1.0, group=g_sess)

g_fib             = "===== FIBONACCI 0.5 EQUILIBRIUM LEVEL ====="
show_eq           = input.bool(true, "Show 0.5 Equilibrium Line", group=g_fib)
eq_len            = input.int(35, "Equilibrium Lookback Range", minval=10, group=g_fib)
c_eq              = input.color(#e040fb, "0.5 EQ Color", group=g_fib)

g_panel           = "===== DASHBOARD PANEL ====="
show_panel        = input.bool(true, "Show Information Panel", group=g_panel)

atrVal = ta.atr(14)
pip_threshold = merge_dist_pips * syminfo.mintick * (syminfo.type == "forex" ? 10 : 100)

// 2. MAJOR SWING EXTREMES ENGINE
major_ph = ta.pivothigh(high, major_len, major_len)
major_pl = ta.pivotlow(low, major_len, major_len)

if show_major_swings and not na(major_ph)
    label.new(bar_index - major_len, high[major_len] + (atrVal * 0.3), "", color=c_major_hh, style=label.style_label_down, size=size.tiny)

if show_major_swings and not na(major_pl)
    label.new(bar_index - major_len, low[major_len] - (atrVal * 0.3), "", color=c_major_hl, style=label.style_label_up, size=size.tiny)

// 3. SMART MONEY STRUCTURE (BOS / CHOCH)
smc_ph = ta.pivothigh(high, smc_len, smc_len)
smc_pl = ta.pivotlow(low, smc_len, smc_len)

var float last_smc_ph = na
var int last_smc_ph_idx = na
var float last_smc_pl = na
var int last_smc_pl_idx = na
var int trend_direction = 0

if not na(smc_ph)
    last_smc_ph := smc_ph
    last_smc_ph_idx := bar_index - smc_len

if not na(smc_pl)
    last_smc_pl := smc_pl
    last_smc_pl_idx := bar_index - smc_len

if show_smc and not na(last_smc_ph) and ta.crossover(close, last_smc_ph)
    string tag_text = trend_direction == -1 ? "CHoCH" : "BOS"
    line.new(last_smc_ph_idx, last_smc_ph, bar_index, last_smc_ph, color=c_bull_smc, style=line.style_dashed, width=1)
    label.new(math.floor((last_smc_ph_idx + bar_index) / 2), last_smc_ph, tag_text, color=color.new(#000000, 100), textcolor=c_bull_smc, style=label.style_label_down, size=size.small)
    trend_direction := 1
    last_smc_ph := na

if show_smc and not na(last_smc_pl) and ta.crossunder(close, last_smc_pl)
    string tag_text = trend_direction == 1 ? "CHoCH" : "BOS"
    line.new(last_smc_pl_idx, last_smc_pl, bar_index, last_smc_pl, color=c_bear_smc, style=line.style_dashed, width=1)
    label.new(math.floor((last_smc_pl_idx + bar_index) / 2), last_smc_pl, tag_text, color=color.new(#000000, 100), textcolor=c_bear_smc, style=label.style_label_up, size=size.small)
    trend_direction := -1
    last_smc_pl := na

// 4. DYNAMIC SUPPLY & DEMAND ZONES ENGINE
var box[] supply_boxes = array.new_box()
var box[] demand_boxes = array.new_box()

zone_ph = ta.pivothigh(high, 6, 6)
zone_pl = ta.pivotlow(low, 6, 6)

if show_zones and not na(zone_ph)
    box new_sup = box.new(left=bar_index - 6, top=high[6], right=bar_index + 12, bottom=math.max(open[6], close[6]), border_color=c_supply_zone, bgcolor=color.new(c_supply_zone, zone_opacity), text="SUPPLY", text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    array.push(supply_boxes, new_sup)
    if array.size(supply_boxes) > max_zones
        box.delete(array.shift(supply_boxes))

if show_zones and not na(zone_pl)
    box new_dem = box.new(left=bar_index - 6, top=math.min(open[6], close[6]), right=bar_index + 12, bottom=low[6], border_color=c_demand_zone, bgcolor=color.new(c_demand_zone, zone_opacity), text="DEMAND", text_color=color.black, text_size=size.tiny, text_halign=text.align_right)
    array.push(demand_boxes, new_dem)
    if array.size(demand_boxes) > max_zones
        box.delete(array.shift(demand_boxes))

if show_zones and array.size(supply_boxes) > 0
    for i = array.size(supply_boxes) - 1 to 0
        box b = array.get(supply_boxes, i)
        float top_p = box.get_top(b)
        if close > top_p
            box.delete(b)
            array.remove(supply_boxes, i)
        else
            box.set_right(b, bar_index + 12)

if show_zones and array.size(demand_boxes) > 0
    for i = array.size(demand_boxes) - 1 to 0
        box b = array.get(demand_boxes, i)
        float bot_p = box.get_bottom(b)
        if close < bot_p
            box.delete(b)
            array.remove(demand_boxes, i)
        else
            box.set_right(b, bar_index + 12)

// 5. AUTO-DISAPPEARING PDH & PDL
[pdh_val, pdl_val] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

var line line_pdh = na
var line line_pdl = na
var label lbl_pdh = na
var label lbl_pdl = na

var bool is_pdh_broken = false
var bool is_pdl_broken = false

if ta.change(time("D")) != 0
    is_pdh_broken := false
    is_pdl_broken := false
    line.delete(line_pdh)
    line.delete(line_pdl)
    label.delete(lbl_pdh)
    label.delete(lbl_pdl)

if show_pdh_pdl and not is_pdh_broken and not na(pdh_val)
    if high > pdh_val
        is_pdh_broken := true
        line.delete(line_pdh)
        label.delete(lbl_pdh)
    else
        line.delete(line_pdh)
        label.delete(lbl_pdh)
        line_pdh := line.new(bar_index - 10, pdh_val, bar_index + 15, pdh_val, color=c_pdh, style=line.style_dotted, width=2)
        lbl_pdh  := label.new(bar_index + 15, pdh_val, "PDH", color=color.new(#000000, 100), textcolor=c_pdh, style=label.style_label_left, size=size.small)

if show_pdh_pdl and not is_pdl_broken and not na(pdl_val)
    if low < pdl_val
        is_pdl_broken := true
        line.delete(line_pdl)
        label.delete(lbl_pdl)
    else
        line.delete(line_pdl)
        label.delete(lbl_pdl)
        line_pdl := line.new(bar_index - 10, pdl_val, bar_index + 15, pdl_val, color=c_pdl, style=line.style_dotted, width=2)
        lbl_pdl  := label.new(bar_index + 15, pdl_val, "PDL", color=color.new(#000000, 100), textcolor=c_pdl, style=label.style_label_left, size=size.small)

// 6. SESSION HIGHS & LOWS
bool in_asia = not na(time(timeframe.period, "0000-0600:23456"))

var float asia_h = na
var float asia_l = na
var line asia_h_line = na
var line asia_l_line = na

if in_asia
    if not in_asia[1]
        asia_h := high
        asia_l := low
    else
        asia_h := math.max(asia_h, high)
        asia_l := math.min(asia_l, low)

if ta.change(time("D")) != 0
    line.delete(asia_h_line)
    line.delete(asia_l_line)
    asia_h := na
    asia_l := na

if show_sessions and not na(asia_h)
    bool is_too_close_pdh = not na(pdh_val) and math.abs(asia_h - pdh_val) < pip_threshold
    if high > asia_h
        line.delete(asia_h_line)
        asia_h := na
    else if not is_too_close_pdh
        line.delete(asia_h_line)
        asia_h_line := line.new(bar_index - 10, asia_h, bar_index + 10, asia_h, color=c_asia, style=line.style_dashed, width=1)

if show_sessions and not na(asia_l)
    bool is_too_close_pdl = not na(pdl_val) and math.abs(asia_l - pdl_val) < pip_threshold
    if low < asia_l
        line.delete(asia_l_line)
        asia_l := na
    else if not is_too_close_pdl
        line.delete(asia_l_line)
        asia_l_line := line.new(bar_index - 10, asia_l, bar_index + 10, asia_l, color=c_asia, style=line.style_dashed, width=1)

// 7. FIBONACCI 0.5 EQUILIBRIUM LEVEL
fib_highest = ta.highest(high, eq_len)
fib_lowest  = ta.lowest(low, eq_len)
eq_50_level = fib_lowest + ((fib_highest - fib_lowest) * 0.5)

var line eq_line = na
var label eq_label = na

if barstate.islast and show_eq
    line.delete(eq_line)
    label.delete(eq_label)
    eq_line  := line.new(bar_index - 25, eq_50_level, bar_index + 20, eq_50_level, color=c_eq, style=line.style_dashed, width=2)
    eq_label := label.new(bar_index + 20, eq_50_level, "0.50 EQ", color=color.new(#000000, 100), textcolor=c_eq, style=label.style_label_left, size=size.small)

// 8. DASHBOARD PANEL
var table info_table = table.new(position.top_right, 2, 4, bgcolor=color.new(#111827, 15), border_width=1, border_color=#374151)

if show_panel and barstate.islast
    table.cell(info_table, 0, 0, "Structure Trend", text_color=color.white, text_size=size.small, bgcolor=#1f2937)
    table.cell(info_table, 1, 0, trend_direction == 1 ? "BULLISH" : trend_direction == -1 ? "BEARISH" : "NEUTRAL", text_color=trend_direction == 1 ? #00e676 : trend_direction == -1 ? #ff1744 : color.gray, text_size=size.small, bgcolor=#1f2937)
    
    table.cell(info_table, 0, 1, "Pricing Zone", text_color=color.white, text_size=size.small, bgcolor=#1f2937)
    table.cell(info_table, 1, 1, close > eq_50_level ? "PREMIUM" : "DISCOUNT", text_color=close > eq_50_level ? #ff5252 : #69f0ae, text_size=size.small, bgcolor=#1f2937)
    
    table.cell(info_table, 0, 2, "PDH / PDL State", text_color=color.white, text_size=size.small, bgcolor=#1f2937)
    table.cell(info_table, 1, 2, is_pdh_broken ? "PDH Swept" : is_pdl_broken ? "PDL Swept" : "Active", text_color=color.white, text_size=size.small, bgcolor=#1f2937)

    table.cell(info_table, 0, 3, "Supply/Demand", text_color=color.white, text_size=size.small, bgcolor=#1f2937)
    table.cell(info_table, 1, 3, str.tostring(array.size(supply_boxes)) + " Sup / " + str.tostring(array.size(demand_boxes)) + " Dem", text_color=color.white, text_size=size.small, bgcolor=#1f2937)
````
