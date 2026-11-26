# SMC Engine (FVG, POI, Breakaway)

- url: https://www.tradingview.com/script/Atwdz6pq-SMC-Engine-FVG-POI-Breakaway/
- type: indicator
- pine_id: PUB;63f31baf95144e4ab5cbcf88e17087d2
- version: 1.0

## Description

Overview:
SMC Engine (OB, FVG, Breakaway) is a comprehensive, institutional-grade Smart Money Concepts (SMC) indicator designed to help price action traders identify market structure, liquidity zones, and institutional footprints with precision.

Whether you trade intraday setups or higher timeframes, this script automates the heavy lifting of mapping order blocks, imbalances, and inducement levels.

Key Features:

Order Blocks & Master POIs: Automatically plots Bullish and Bearish Order Blocks (OB) upon structural breaks, complete with high-confluence Master POI zones. Includes auto-mitigation logic that clears zones once tested or breached by price.

Fair Value Gaps (FVG) & Breakaway Gaps: Highlights standard imbalances and aggressive displacement breakaway gaps. Features an optional 50% Equilibrium (CE) midline to track institutional discount/premium reactions.

Multi-Timeframe Flexibility: Includes a toggle to restrict complex intraday elements (like CHoCH, BOS, and IDMT sweeps) exclusively to intraday charts, ensuring your Daily and higher timeframe charts remain clean and focused strictly on key Order Blocks and zones.

Real-Time SMC Dashboard: Features a clean, on-screen metrics table tracking current market bias, active FVG counts, breakaway gaps, active order blocks, and POI metrics at a glance.

Built-in Alert Conditions: Set custom alerts for Imbalance/FVG formations, Order Block tests, and price crosses to never miss an institutional setup.

Customization & Inputs:

Designed with flexibility in mind, the indicator allows you to tailor every visual and functional element to fit your exact trading methodology:

Swing Pivot Length: Fine-tune the sensitivity of market swing detection by adjusting the lookback pivot length to match scalping, day trading, or swing trading timeframes.

Display & Timeframe Controls: Easily toggle the “Show SMC Only on Intraday Charts” setting to automatically clean up higher timeframes (like Daily or Weekly charts) by hiding minor structure lines while keeping key institutional zones visible.

Order Block & IDMT Settings: Customize label sizes (Small, Normal, Large, Huge) for Order Blocks and Inducement (IDMT) sweeps, and select specific text and dashed line colors for IDMT sweeps.

Master POI Zones: Turn high-confluence Master Confluent POI zones on or off, and assign custom semi-transparent background colors for bullish and bearish institutional zones.

FVG & Breakaway Gap Styling: Configure standard imbalance boxes and displacement breakaway gaps separately. Enable or disable the 50% Equilibrium (CE) midline to monitor discount and premium price reactions precisely.

On-Screen Dashboard: Choose your preferred dashboard layout position (Top Right, Bottom Right, Top Left, Bottom Left) or hide the table entirely if you prefer an uncluttered chart canvas.

Trading Strategies & Combos:

To get the highest probability setups from this engine, consider combining it with other technical tools:

Volume Analysis: Pair this script with a Volume Profile or Volume Delta indicator. Look for institutional Order Blocks and Breakaway Gaps that form alongside massive volume spikes or high volume nodes to confirm institutional sponsorship.

Higher Timeframe Support & Resistance: Use the multi-timeframe capability to mark key daily/weekly S&R levels. When a Master POI or Order Block overlaps with major support or resistance, it creates a high-confluence reversal or continuation zone.

Strategy Note: Order Block Mitigation & Bias Reversal :

Smart Money Concepts rely heavily on mitigation and structural shifts. Here is how you can interpret breaks within this engine:

Order Block Validation & Mitigation: As price interacts with Bullish or Bearish Order Blocks, the script automatically tracks and auto-mitigates (deletes) zones once price closes past their invalidation levels.

Reversing Bias on OB Breaks: If a strong Bullish Order Block is decisively broken to the downside (or a Bearish OB is broken to the upside), it often signals a shift in market sentiment or a change of character (CHoCH). Traders frequently use these breaches to flip their directional bias, anticipating a continuation in the direction of the breakout or a retest of the newly formed opposing structure.

Disclaimer
This indicator is intended strictly for educational, informational, and analytical purposes and does not constitute financial, investment, or trading advice. Past performance of Smart Money Concepts or any technical setups identified by this script does not guarantee future results. Trading financial markets involves substantial risk of loss and is not suitable for every investor. You are solely responsible for your own trading decisions, risk management, and capital allocation. The author and publisher of this script assume no responsibility or liability for any direct, indirect, or consequential losses arising from the use of this indicator.

## Source Code

````pine
//@version=6
indicator ("SMC Engine (FVG, POI, Breakaway)", overlay=true, max_bars_back=1000, max_boxes_count=400, max_lines_count=500)

// --- Inputs & Customization ---
swing_length   = input.int(7, title="Swing Pivot Length", minval=2)
onlyIntraday   = input.bool(true, title="Show SMC Only on Intraday Charts (Applies to Structure/IDMT)", group="Display Settings")

// --- OB & IDMT Settings ---
show_bull_obs  = input.bool(true, title="Show Bullish Order Blocks", group="Order Block Settings")
show_bear_obs  = input.bool(true, title="Show Bearish Order Blocks", group="Order Block Settings")
ob_text_size   = input.string("Normal", title="Order Block Label Size", options=["Small", "Normal", "Large", "Huge"], group="Order Block Settings")
idmt_text_size = input.string("Normal", title="IDMT Label Size", options=["Small", "Normal", "Large", "Huge"], group="IDMT Settings")

// --- POI Settings ---
show_poi       = input.bool(true, title="Show Master Confluent POI Zones?", group="POI Settings")
color_poi_bull = input.color(color.new(color.blue, 82), title="Bullish Master POI Color", group="POI Settings")
color_poi_bear = input.color(color.new(color.purple, 82), title="Bearish Master POI Color", group="POI Settings")

// --- FVG & Breakaway Settings ---
show_fvg_ce         = input.bool(true, title="Show 50% FVG Midline (CE)?", group="FVG Settings")
color_fvg_bull      = input.color(color.new(color.green, 85), title="FVG Bullish Color", group="FVG Settings")
color_fvg_bear      = input.color(color.new(color.red, 85), title="FVG Bearish Color", group="FVG Settings")
fvg_text_size       = input.string("Small", title="FVG & Breakaway Label Size", options=["Tiny", "Small", "Normal", "Large"], group="FVG Settings")

// --- Breakaway Gap Settings ---
show_breakaway_fvg  = input.bool(true, title="Show Breakaway Gaps (Displacement)?", group="Breakaway Gap Settings")
color_ba_bull       = input.color(color.new(color.teal, 75), title="Bullish Breakaway Gap Color", group="Breakaway Gap Settings")
color_ba_bear       = input.color(color.new(color.fuchsia, 75), title="Bearish Breakaway Gap Color", group="Breakaway Gap Settings")

// --- IDMT Color Picker Inputs ---
color_idmt_text = input.color(color.rgb(255, 255, 255), title="IDMT Label Text Color", group="IDMT Settings")
color_idmt_line = input.color(color.rgb(255, 0, 128), title="IDMT Line Color", group="IDMT Settings")

// --- Dashboard Settings ---
show_dashboard = input.bool(true, title="Show SMC Dashboard?", group="Dashboard Settings")
dash_position  = input.string("Top Right", title="Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group="Dashboard Settings")

// --- Fixed Color Styling ---
color_bull_structure = color.rgb(0, 200, 5)
color_bear_structure = color.rgb(255, 15, 15)
color_bull_ob        = color.new(color.green, 90)
color_bear_ob        = color.new(color.red, 90)

// --- Convert String Sizes to Pine Size Constants ---
selected_ob_size = switch ob_text_size
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

selected_idmt_size = switch idmt_text_size
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

selected_fvg_size = switch fvg_text_size
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

// Flags for constraints
isIntradayTf = timeframe.isintraday
runStructure = not onlyIntraday or isIntradayTf

// --- Find Market Swings (Available everywhere for OBs, restricted for structure if toggled) ---
ph = ta.pivothigh(high, swing_length, swing_length)
pl = ta.pivotlow(low, swing_length, swing_length)

var float top_target = na
var float btm_target = na
var bool is_bullish  = true

var label last_idmt_label = na
var line  last_idmt_line  = na
var bool  idmt_already_printed = false

var float last_minor_low  = na
var float last_minor_high = na

var bool look_for_bull_fvg = false
var bool look_for_bear_fvg = false
var bool look_for_bull_ba  = false
var bool look_for_bear_ba  = false

// --- Storage Arrays ---
var box[]  active_bull_fvgs    = array.new_box()
var line[] active_bull_lines   = array.new_line()
var box[]  active_bear_fvgs    = array.new_box()
var line[] active_bear_lines   = array.new_line()

var box[]  active_ba_bull_fvgs = array.new_box()
var line[] active_ba_bull_lines= array.new_line()
var box[]  active_ba_bear_fvgs = array.new_box()
var line[] active_ba_bear_lines= array.new_line()

var box[]  active_bull_obs     = array.new_box()
var box[]  active_bear_obs     = array.new_box()
var box[]  active_bull_pois    = array.new_box()
var box[]  active_bear_pois    = array.new_box()

var box[]  all_today_fvgs      = array.new_box()
var line[] all_today_lines     = array.new_line()

// --- Daily Clean Engine ---
if timeframe.change("D")
    if array.size(all_today_fvgs) > 0
        for i = array.size(all_today_fvgs) - 1 to 0
            box.delete(array.get(all_today_fvgs, i))
        array.clear(all_today_fvgs)
        
    if array.size(all_today_lines) > 0
        for i = array.size(all_today_lines) - 1 to 0
            line.delete(array.get(all_today_lines, i))
        array.clear(all_today_lines)

    array.clear(active_bull_fvgs)
    array.clear(active_bull_lines)
    array.clear(active_bear_fvgs)
    array.clear(active_bear_lines)
    array.clear(active_ba_bull_fvgs)
    array.clear(active_ba_bull_lines)
    array.clear(active_ba_bear_fvgs)
    array.clear(active_ba_bear_lines)

if not na(ph)
    top_target := ph
    last_minor_high := ph
if not na(pl)
    btm_target := pl
    last_minor_low := pl

// --- Inducement (IDMT) & Structure Breaks (Run only if runStructure is true) ---
bool bull_ob_formed = false
bool bear_ob_formed = false

if runStructure
    if not idmt_already_printed and not na(last_minor_low)
        if ta.crossunder(low, last_minor_low) and close > last_minor_low
            if not na(last_idmt_label)
                label.delete(last_idmt_label)
                line.delete(last_idmt_line)
                
            last_idmt_label := label.new(bar_index, low, "IDMT Sweep", color=color.new(color.white, 100), textcolor=color_idmt_text, style=label.style_label_up, size=selected_idmt_size)
            last_idmt_line  := line.new(math.max(bar_index[swing_length], bar_index - 950), last_minor_low, bar_index, last_minor_low, color=color_idmt_line, style=line.style_dashed)
            last_minor_low  := na 
            idmt_already_printed := true 

    if not idmt_already_printed and not na(last_minor_high)
        if ta.crossover(high, last_minor_high) and close < last_minor_high
            if not na(last_idmt_label)
                label.delete(last_idmt_label)
                line.delete(last_idmt_line)
                
            last_idmt_label := label.new(bar_index, high, "IDMT Sweep", color=color.new(color.white, 100), textcolor=color_idmt_text, style=label.style_label_down, size=selected_idmt_size)
            last_idmt_line  := line.new(math.max(bar_index[swing_length], bar_index - 950), last_minor_high, bar_index, last_minor_high, color=color_idmt_line, style=line.style_dashed)
            last_minor_high := na 
            idmt_already_printed := true 

// --- Structure Breaks & Order Blocks (Runs across all timeframes so OBs show on Daily) ---
if not na(top_target) and ta.crossover(close, top_target)
    if runStructure
        label.new(bar_index, high, is_bullish ? "BOS" : "CHoCH", color=color.new(color.white, 100), textcolor=color_bull_structure, style=label.style_label_down, size=size.small)
        line.new(math.max(bar_index[swing_length], bar_index - 950), top_target, bar_index, top_target, color=color_bull_structure, style=line.style_dashed)
        
    ob_top = high[swing_length]
    ob_btm = math.min(open[swing_length], close[swing_length])
    
    if show_bull_obs
        box ob_box = box.new(left=bar_index[swing_length], top=ob_top, right=bar_index, bottom=ob_btm, 
            bgcolor=color_bull_ob, border_color=color.green, border_style=line.style_solid, 
            text="BULL OB", text_color=color.green, text_size=selected_ob_size, text_valign="top", text_halign="left")
        array.push(active_bull_obs, ob_box)

    if show_poi and show_bull_obs
        box poi_box = box.new(left=bar_index[swing_length], top=ob_top, right=bar_index, bottom=ob_btm, 
            bgcolor=color_poi_bull, border_color=color.blue, border_style=line.style_dashed, 
            text="MASTER BULL POI", text_color=color.blue, text_size=size.small, text_valign="bottom", text_halign="left")
        array.push(active_bull_pois, poi_box)

    bull_ob_formed := true
    is_bullish := true
    top_target := na
    idmt_already_printed := false 
    last_idmt_label := na 
    last_idmt_line  := na
    look_for_bull_fvg := true
    look_for_bear_fvg := false
    look_for_bull_ba  := true  
    look_for_bear_ba  := false

if not na(btm_target) and ta.crossunder(close, btm_target)
    if runStructure
        label.new(bar_index, low, is_bullish ? "CHoCH" : "BOS", color=color.new(color.white, 100), textcolor=color_bear_structure, style=label.style_label_up, size=size.small)
        line.new(math.max(bar_index[swing_length], bar_index - 950), btm_target, bar_index, btm_target, color=color_bear_structure, style=line.style_dashed)
        
    ob_top = math.max(open[swing_length], close[swing_length])
    ob_btm = low[swing_length]
    
    if show_bear_obs
        box ob_box = box.new(left=bar_index[swing_length], top=ob_top, right=bar_index, bottom=ob_btm, 
            bgcolor=color_bear_ob, border_color=color.red, border_style=line.style_solid, 
            text="BEAR OB", text_color=color.red, text_size=selected_ob_size, text_valign="top", text_halign="left")
        array.push(active_bear_obs, ob_box)

    if show_poi and show_bear_obs
        box poi_box = box.new(left=bar_index[swing_length], top=ob_top, right=bar_index, bottom=ob_btm, 
            bgcolor=color_poi_bear, border_color=color.purple, border_style=line.style_dashed, 
            text="MASTER BEAR POI", text_color=color.purple, text_size=size.small, text_valign="bottom", text_halign="left")
        array.push(active_bear_pois, poi_box)

    bear_ob_formed := true
    is_bullish := false
    btm_target := na
    idmt_already_printed := false 
    last_idmt_label := na 
    last_idmt_line  := na
    look_for_bear_fvg := true
    look_for_bull_fvg := false
    look_for_bear_ba  := true  
    look_for_bull_ba  := false

// --- Fair Value Gaps & Breakaway Gaps Engine ---
bool bull_fvg_formed = false
bool bear_fvg_formed = false
bool ba_bull_formed  = false
bool ba_bear_formed  = false

if bar_index > 2
    // --- Bullish Breakaway Gap Detection ---
    if look_for_bull_ba and show_breakaway_fvg and (low > high[2]) and (close[1] > high[2])
        float ce_level = (low + high[2]) / 2.0
        box_bx = box.new(left=bar_index[2], top=low, right=bar_index, bottom=high[2], 
            bgcolor=color_ba_bull, border_color=color.new(color.white, 60), 
            text="BREAKAWAY GAP", text_color=color.white, text_size=selected_fvg_size, text_valign="top", text_halign="right")
        line_ce = show_fvg_ce ? line.new(x1=bar_index[2], y1=ce_level, x2=bar_index, y2=ce_level, color=color.new(color.white, 30), style=line.style_dotted, width=1) : na
        array.push(active_ba_bull_fvgs, box_bx)
        array.push(active_ba_bull_lines, line_ce)
        array.push(all_today_fvgs, box_bx)
        if not na(line_ce)
            array.push(all_today_lines, line_ce)
        ba_bull_formed := true
        look_for_bull_ba := false

    // --- Standard Bullish FVG Detection ---
    else if look_for_bull_fvg and (low > high[2]) and (close[1] > high[2])
        float ce_level = (low + high[2]) / 2.0
        box_bx = box.new(left=bar_index[2], top=low, right=bar_index, bottom=high[2], 
            bgcolor=color_fvg_bull, border_color=color.new(color.white, 60), 
            text="FVG", text_color=color.white, text_size=selected_fvg_size, text_valign="top", text_halign="right")
        line_ce = show_fvg_ce ? line.new(x1=bar_index[2], y1=ce_level, x2=bar_index, y2=ce_level, color=color.new(color.white, 30), style=line.style_dotted, width=1) : na
        array.push(active_bull_fvgs, box_bx)
        array.push(active_bull_lines, line_ce)
        array.push(all_today_fvgs, box_bx)
        if not na(line_ce)
            array.push(all_today_lines, line_ce)
        bull_fvg_formed := true
        look_for_bull_fvg := false 

    // --- Bearish Breakaway Gap Detection ---
    if look_for_bear_ba and show_breakaway_fvg and (high < low[2]) and (close[1] < low[2])
        float ce_level = (low[2] + high) / 2.0
        box_bx = box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high, 
            bgcolor=color_ba_bear, border_color=color.new(color.white, 60), 
            text="BREAKAWAY GAP", text_color=color.white, text_size=selected_fvg_size, text_valign="top", text_halign="right")
        line_ce = show_fvg_ce ? line.new(x1=bar_index[2], y1=ce_level, x2=bar_index, y2=ce_level, color=color.new(color.white, 30), style=line.style_dotted, width=1) : na
        array.push(active_ba_bear_fvgs, box_bx)
        array.push(active_ba_bear_lines, line_ce)
        array.push(all_today_fvgs, box_bx)
        if not na(line_ce)
            array.push(all_today_lines, line_ce)
        ba_bear_formed := true
        look_for_bear_ba := false

    // --- Standard Bearish FVG Detection ---
    else if look_for_bear_fvg and (high < low[2]) and (close[1] < low[2])
        float ce_level = (low[2] + high) / 2.0
        box_bx = box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high, 
            bgcolor=color_fvg_bear, border_color=color.new(color.white, 60), 
            text="FVG", text_color=color.white, text_size=selected_fvg_size, text_valign="top", text_halign="right")
        line_ce = show_fvg_ce ? line.new(x1=bar_index[2], y1=ce_level, x2=bar_index, y2=ce_level, color=color.new(color.white, 30), style=line.style_dotted, width=1) : na
        array.push(active_bear_fvgs, box_bx)
        array.push(active_bear_lines, line_ce)
        array.push(all_today_fvgs, box_bx)
        if not na(line_ce)
            array.push(all_today_lines, line_ce)
        bear_fvg_formed := true
        look_for_bear_fvg := false 

// --- FVG & Breakaway Alerts Definition ---
alertcondition(bull_fvg_formed or ba_bull_formed, title="Bullish FVG/Breakaway Formed", message="A new Bullish Fair Value Gap or Breakaway Gap has formed!")
alertcondition(bear_fvg_formed or ba_bear_formed, title="Bearish FVG/Breakaway Formed", message="A new Bearish Fair Value Gap or Breakaway Gap has formed!")

if bull_fvg_formed or ba_bull_formed
    alert("Bullish Imbalance Formed", alert.freq_once_per_bar)

if bear_fvg_formed or ba_bear_formed
    alert("Bearish Imbalance Formed", alert.freq_once_per_bar)

// --- Extension & Auto-Mitigation Engine ---
// Bullish FVGs
if array.size(active_bull_fvgs) > 0
    for i = array.size(active_bull_fvgs) - 1 to 0
        box_bx  = array.get(active_bull_fvgs, i)
        line_ce = array.get(active_bull_lines, i)
        box.set_right(box_bx, bar_index)
        if not na(line_ce)
            line.set_x2(line_ce, bar_index)
        if close < box.get_bottom(box_bx)
            box.delete(box_bx)
            if not na(line_ce)
                line.delete(line_ce)
            array.remove(active_bull_fvgs, i)
            array.remove(active_bull_lines, i)

// Bullish Breakaway Gaps
if array.size(active_ba_bull_fvgs) > 0
    for i = array.size(active_ba_bull_fvgs) - 1 to 0
        box_bx  = array.get(active_ba_bull_fvgs, i)
        line_ce = array.get(active_ba_bull_lines, i)
        box.set_right(box_bx, bar_index)
        if not na(line_ce)
            line.set_x2(line_ce, bar_index)
        if close < box.get_bottom(box_bx)
            box.delete(box_bx)
            if not na(line_ce)
                line.delete(line_ce)
            array.remove(active_ba_bull_fvgs, i)
            array.remove(active_ba_bull_lines, i)

// Bearish FVGs
if array.size(active_bear_fvgs) > 0
    for i = array.size(active_bear_fvgs) - 1 to 0
        box_bx  = array.get(active_bear_fvgs, i)
        line_ce = array.get(active_bear_lines, i)
        box.set_right(box_bx, bar_index)
        if not na(line_ce)
            line.set_x2(line_ce, bar_index)
        if close > box.get_top(box_bx)
            box.delete(box_bx)
            if not na(line_ce)
                line.delete(line_ce)
            array.remove(active_bear_fvgs, i)
            array.remove(active_bear_lines, i)

// Bearish Breakaway Gaps
if array.size(active_ba_bear_fvgs) > 0
    for i = array.size(active_ba_bear_fvgs) - 1 to 0
        box_bx  = array.get(active_ba_bear_fvgs, i)
        line_ce = array.get(active_ba_bear_lines, i)
        box.set_right(box_bx, bar_index)
        if not na(line_ce)
            line.set_x2(line_ce, bar_index)
        if close > box.get_top(box_bx)
            box.delete(box_bx)
            if not na(line_ce)
                line.delete(line_ce)
            array.remove(active_ba_bear_fvgs, i)
            array.remove(active_ba_bear_lines, i)

// Bullish Order Blocks
if array.size(active_bull_obs) > 0
    for i = array.size(active_bull_obs) - 1 to 0
        box_ob = array.get(active_bull_obs, i)
        box.set_right(box_ob, bar_index)
        if close < box.get_bottom(box_ob)
            box.delete(box_ob)
            array.remove(active_bull_obs, i)

// Bullish POIs
if array.size(active_bull_pois) > 0
    for i = array.size(active_bull_pois) - 1 to 0
        box_poi = array.get(active_bull_pois, i)
        box.set_right(box_poi, bar_index)
        if close < box.get_bottom(box_poi)
            box.delete(box_poi)
            array.remove(active_bull_pois, i)

// Bearish Order Blocks
if array.size(active_bear_obs) > 0
    for i = array.size(active_bear_obs) - 1 to 0
        box_ob = array.get(active_bear_obs, i)
        box.set_right(box_ob, bar_index)
        if close > box.get_top(box_ob)
            box.delete(box_ob)
            array.remove(active_bear_obs, i)

// Bearish POIs
if array.size(active_bear_pois) > 0
    for i = array.size(active_bear_pois) - 1 to 0
        box_poi = array.get(active_bear_pois, i)
        box.set_right(box_poi, bar_index)
        if close > box.get_top(box_poi)
            box.delete(box_poi)
            array.remove(active_bear_pois, i)

// --- Specific Order Block Cross Alerts ---
bool price_crossed_bull_ob = false
bool price_crossed_bear_ob = false

if array.size(active_bull_obs) > 0
    for i = 0 to array.size(active_bull_obs) - 1
        box_ob = array.get(active_bull_obs, i)
        float ob_btm = box.get_bottom(box_ob)
        if ta.crossunder(close, ob_btm) or ta.crossunder(low, ob_btm)
            price_crossed_bull_ob := true

if array.size(active_bear_obs) > 0
    for i = 0 to array.size(active_bear_obs) - 1
        box_ob = array.get(active_bear_obs, i)
        float ob_top = box.get_top(box_ob)
        if ta.crossover(close, ob_top) or ta.crossover(high, ob_top)
            price_crossed_bear_ob := true

alertcondition(price_crossed_bull_ob, title="Price Crossed Bullish OB", message="Price crossed below/into a Bullish Order Block zone!")
alertcondition(price_crossed_bear_ob, title="Price Crossed Above Bearish OB", message="Price crossed above a Bearish Order Block zone!")

if price_crossed_bull_ob
    alert("Price Crossed Bullish OB", alert.freq_once_per_bar)

if price_crossed_bear_ob
    alert("Price Crossed Above Bearish OB", alert.freq_once_per_bar)

// --- SMC On-Screen Dashboard Table ---
var table_pos = switch dash_position
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table smc_dash = table.new(position=table_pos, columns=2, rows=6, bgcolor=color.new(color.black, 30), border_color=color.rgb(60, 60, 60), border_width=1)

if show_dashboard and barstate.islast
    table.cell(smc_dash, 0, 0, "SMC METRIC", text_color=color.white, text_size=size.small, bgcolor=color.rgb(40, 40, 40))
    table.cell(smc_dash, 1, 0, "VALUE", text_color=color.white, text_size=size.small, bgcolor=color.rgb(40, 40, 40))
    
    table.cell(smc_dash, 0, 1, "Market Bias", text_color=color.white, text_size=size.small)
    table.cell(smc_dash, 1, 1, is_bullish ? "BULLISH 🟢" : "BEARISH 🔴", text_color=is_bullish ? color.green : color.red, text_size=size.small)
    
    int total_active_fvgs = array.size(active_bull_fvgs) + array.size(active_bear_fvgs)
    table.cell(smc_dash, 0, 2, "Active FVGs", text_color=color.white, text_size=size.small)
    table.cell(smc_dash, 1, 2, str.tostring(total_active_fvgs) + " (" + str.tostring(array.size(active_bull_fvgs)) + "B / " + str.tostring(array.size(active_bear_fvgs)) + "S)", text_color=color.white, text_size=size.small)

    int total_active_ba = array.size(active_ba_bull_fvgs) + array.size(active_ba_bear_fvgs)
    table.cell(smc_dash, 0, 3, "Breakaway Gaps", text_color=color.white, text_size=size.small)
    table.cell(smc_dash, 1, 3, str.tostring(total_active_ba) + " (" + str.tostring(array.size(active_ba_bull_fvgs)) + "B / " + str.tostring(array.size(active_ba_bear_fvgs)) + "S)", text_color=color.teal, text_size=size.small)

    int total_active_obs = array.size(active_bull_obs) + array.size(active_bear_obs)
    table.cell(smc_dash, 0, 4, "Active OBs", text_color=color.white, text_size=size.small)
    table.cell(smc_dash, 1, 4, str.tostring(total_active_obs) + " (" + str.tostring(array.size(active_bull_obs)) + "B / " + str.tostring(array.size(active_bear_obs)) + "S)", text_color=color.white, text_size=size.small)

    int total_active_pois = array.size(active_bull_pois) + array.size(active_bear_pois)
    table.cell(smc_dash, 0, 5, "Active POIs", text_color=color.white, text_size=size.small)
    table.cell(smc_dash, 1, 5, str.tostring(total_active_pois) + " (" + str.tostring(array.size(active_bull_pois)) + "B / " + str.tostring(array.size(active_bear_pois)) + "S)", text_color=color.white, text_size=size.small)
````
