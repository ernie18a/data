# The Werkstatt [OMSF]

- url: https://www.tradingview.com/script/8Y3LEclz-The-Werkstatt-OMSF/
- type: indicator
- pine_id: PUB;14cd2c9498734d549a76d3b47b338739
- version: 2.0

## Description

[b]Innovation, Baseline Testing & Feedback Hub[/b]

Welcome to the WERKSTATT  – a flexible open-source framework and research hub designed to introduce, test, and refine new indicator concepts, quantitative mechanics, and trading ideas.


🎯 [b]CONCEPT & PURPOSE[/b]

To keep the main publisher profile clean and free from incomplete beta scripts, the WERKSTATT serves as a central, unified platform for experimental releases and baseline research projects.

Rather than releasing separate test scripts for every iteration, the WERKSTATT functions as an [b]interactive container:[/b]

    [b]Interactive Project Navigation:[/b] Switch between active research projects directly within the indicator settings.

    [b]Integrated Concept & Journal Overlays:[/b] View core logic definitions, rules, and baseline test logs directly on the chart without cluttering the workspace.

    💡 [b]Feedback & Ideas: [/b]Feel free to share thoughts, suggestions, edge-case observations, and feature requests in the comments to help refine these concepts into production-ready tools.


🗂️ [b]HOW TO USE THE WERKSTATT INTERFACE[/b]

    Project Intro: Upon loading, the indicator displays the [b][i]#Project Overview Overlay[/i][/b], explaining the current project's core logic, rules, and objectives.

    Settings Navigation: Open the settings panel [b](🗂️ PROJECT NAVIGATION)[/b]:

        [b][i]#Projectintro:[/i][/b] Uncheck this toggle once familiar with the concept to hide the overlay and activate the live chart/testing tools.

        [b][i]#Logentry:[/i] [/b]Toggle journal entries (#log 1, #log 2, etc.) to review specific historical test setups and baseline verifications on the chart.

       [b] [i]#Beta Visuals:[/i] [/b]Toggle compact chart dashboards and subpanel oscillators on/off.


🔬 [b]PROJECT 01: IAI ZONES [beta][/b]

The inaugural project introduces [b]Cumulative Activity Zones[/b], evolving the mechanics of the original IAI ([i]Intrabar Activity Index[/i]) Indicator by extracting its core logic into an independent cumulative activity model and integrating it with OMSF ([i]Objective Market Structure Framework[/i]) rules:
    
[list]
[*][b][i]Activity Impulse[/i][/b]: Evolved from the original IAI logic, the extracted tracker aggregates volume and volatility expansion into a cumulative activity metric (percentile-ranked over a dynamic lookback window). High-activity phases are highlighted via yellow chart dots.
---
[*][b][i]Latch-Trigger & Anchoring:[/i][/b] When an activity phase terminates, a memory latch is armed. The price zone (High/Low) is anchored to the chart upon the next structural OMSF breakout.
---
[*][b][i]Dynamic Zone Management:[/i] [/b]Evaluates zone overlap and range hierarchy (Stable, Replace, or Refining modes) to prevent clutter while keeping high-conviction structural price levels.
[/list]
[i]REFERENCES & DEPENDENCIES[list]
[*]Intrabar Activity Index (IAI)
[*]Objective Market Structure Framework (OMSF)[/list]
https://www.tradingview.com/script/OjktEsmn/
https://www.tradingview.com/script/g1122Yj2/

⚠️ [b]DISCLAIMER[/b]

This script is published under the THE WERKSTATT research initiative for educational, analytical, and testing purposes only ([beta]). It does not constitute financial advice. Always perform thorough replay testing and maintain strict risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © arnipoer

//@version=6
indicator("OMSF-Werkstatt")

render_werkstatt_sign() =>
    var table logoTab = table.new(
         position = position.top_center, 
         columns = 1, 
         rows = 1, 
         bgcolor = color.new(#0b121f, 15), 
         border_width = 1, 
         border_color = color.new(#FF6B00, 30),
         force_overlay = true )
    string logo_text = 
         "┌────────────────────────────────────────────────────────────────────────────────┐\n" +
         "│                            ████████╗██╗  ██╗███████╗                            │\n" +
         "│                               ██║   ███████║█████╗                              │\n" +
         "│                               ██║   ██╔══██║███████╗                            │\n" +
         "│                               ╚═╝   ╚═╝  ╚═╝╚══════╝                            │\n" +
         "│                                                                                │\n" +
         "│ ██╗  ██╗███████╗██████╗ ██╗  ██╗███████╗████████╗█████╗  ████████╗████████╗ │\n" +
         "│ ██║  ██║██╔════╝██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝╚══██╔══╝ │\n" +
         "│ ██║██║██║█████╗  ██████╔╝█████═╝ ███████╗   ██║   ███████║   ██║      ██║   │\n" +
         "│ ████████║██╔══╝  ██╔══██╗██  ██╗ ╚════██║   ██║   ██╔══██║   ██║      ██║   │\n" +
         "│ ╚██   ██║███████╗██║  ██║██║ ╚██╗███████║   ██║   ██║  ██║   ██║      ██║   │\n" +
         "│  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝      ╚═╝   │\n" +
         "│                                                                                │\n" +
         "│                            OMSF ENGINEER DRIVEN 🇩🇪                             │\n" +
         "└────────────────────────────────────────────────────────────────────────────────┘"
    table.cell(
         logoTab, 0, 0, logo_text, 
         text_color = #FF6B00, 
         text_size = size.normal, 
         text_font_family = font.family_monospace, 
         text_halign = text.align_center)


/// ==========================================
// 🎨 WERKSTATT STYLING & PALETTE
// ==========================================
color COLOR_BG_PANEL   = color.new(#0b121f, 10)
color COLOR_BG_DASH    = color.new(#0F172A, 15)
color COLOR_AMBER      = color.rgb(234, 152, 10)  // Aktivität & Akzent
color COLOR_CYAN       = #00E5FF  // OMSF-Struktur
color COLOR_TEXT       = color.new(#E2E8F0, 10)
color COLOR_MUTED      = color.new(#64748B, 30)


import arnipoer/PriceActionStructure/4 as omsf //@link https://www.tradingview.com/script/g1122Yj2/
import arnipoer/VisualStructureTools/4 as vst //@link https://tradingview.com/script/RYljd98y/


[bull_candle_color, bear_candle_color, deep_space_blue, midnight_charcoal, silk_pearl, omsf_color, omsf_bulls_color, omsf_bears_color, hyper_green_hex, laser_crimson_hex, cream, 
     mint_cyan, ice_blue, soft_coral, bears_dusk, bulls_fading, bulls_exhaustion, bulls_dawn] = vst.colorsuite()

// =====================
// 📑 WERKSTATT-JOURNAL 
// =====================

project_intro_overlay(string header, string project_text, color border_cl) =>
    var table textPanel = table.new(position = position.bottom_center, columns = 1, rows = 2, 
     bgcolor = color.new(#0b121f, 10), border_width = 1, border_color = color.new(border_cl, 60), force_overlay = true)
   
    table.cell(textPanel, 0, 0, header, height = 0, text_color = color.new(COLOR_AMBER, 20), text_size = size.normal, text_halign =  text.align_center, text_valign = text.align_bottom)
    table.cell(textPanel, 0, 1, project_text, text_color = color.new(COLOR_TEXT, 20), text_size = size.normal, text_halign = text.align_left, text_valign = text.align_top)

project_log(string log_text, color border_cl, color text_color) =>
    var table textPanel = table.new(position = position.middle_left, columns = 1, rows = 1, 
     bgcolor = color.new(#0b121f, 10), border_width = 2, border_color = border_cl, force_overlay = true)    
    table.cell(textPanel, 0, 0, log_text, text_color = text_color, text_size = size.normal, text_halign =  text.align_left, text_valign = text.align_top)


// ==========================================
// 🗂️ PROJEKT-NAVIGATION
// ==========================================
gp_nav = '🗂️ PROJECT NAVIGATION'

show_intro     = input.bool(true, "Projectintro", group = gp_nav, inline = '1')

active_project = input.string('Project 01 - CAI ZONES [beta]', "",
     options=[
         'Project 01 - CAI ZONES [beta]', 
         '...'], group = gp_nav, inline = '1', active = show_intro, 
         tooltip = "Enable to view project overview & concept overlay. Select the active OMSF research project. Disable to start using the project tool.")

show_log       = input.bool(true, "Logentry", group = gp_nav, active = not show_intro, inline = '2')

log_entry = input.string('#log 1', "",
     options=['#log 1', '...'], group = gp_nav, inline = '2', active = not show_intro, display = display.none, 
     tooltip = "Track project progress and toggle journal log entries on/off on the chart.")

show_beta_dash = input.bool(true, "Beta dashboard", group = gp_nav, inline = '3', active = not show_intro)
show_beta_oszi = input.bool(true, "Beta oscillator", group = gp_nav, inline = '3', active = not show_intro, 
     tooltip = "Toggle project-specific visuals: Enables/disables the compact main chart dashboard and lower panel IAI Live Tracker oscillator.")


// PROJECT MATRIX
proj_1     = (active_project == 'Project 01 - CAI ZONES [beta]')
proj_2     = (active_project == '...')

// LOG MATRIX
log_entry_1     = (log_entry == '#log 1')
log_entry_2     = (log_entry == '...')


// ===============================================================================
//|             Project 1 - IAI Zones                                            |
// ===============================================================================
string project_1_header = "=== PROJ 01: IAI / OMSF LIQUIDITY ZONES [BETA] ===\n"
string project_1_text = 
     "CONCEPT:\n" +
     "Integration of IAI (Intrabar Activity Index) with OMSF structural logic.\n" +
     "The IAI Live Tracker detects elevated market activity (percentile-based cumulative volatility x volume).\n" +
     "Once activity is registered, the OMSF framework locks and renders the corresponding origin price range as persistent chart zones.\n\n" +
     "GOAL:\n" +
     "Development of a standalone indicator and execution of rule-based day/swing trading strategies.\n\n" +
     "STATUS & LOGIC:\n" +
     "1. Latch-Trigger:\n" +
     "   • Arming: When a high-activity phase terminates (is_activity cooldown), the memory flag is set to true.\n" +
     "   • Triggering: On the first subsequent OMSF structural breakout, the zone (High/Low) is anchored to the chart.\n" +
     "     (OMSF compression filter disabled to yield tighter, highly precise zones).\n\n" +
     "2. Zone Management (Max 2 Zones):\n" +
     "   • Stable Zones: New zones are drawn only if they are entirely non-overlapping with existing ones.\n" +
     "   • Refining Zones: Overlapping, tighter zones replace previous zones for refined precision\n\n" +
     "QUICK START:\n" +
      "To begin testing, uncheck 'Projectintro' in the Project Navigation settings."
if barstate.islast and proj_1 and show_intro
    project_intro_overlay(project_1_header, project_1_text , COLOR_AMBER )

string proj1_log1 = 
     "=== LOG 01: BASELINE ===\n" +
     "Replay testing with\n" +
     "default parameters\n" +
     "(85% Vola, 66% Volume,\n" +
     "Lookback 50, cumLen 12):\n\n" +
     "• H1 (~2.5 days):\n" +
     "  \"Weekly Zones\"\n" +
     "• M10 (~0.33 days):\n" +
     "  \"Daily Zones\"\n\n" +
     "IAI dots and OMSF\n" +
     "visualized to verify\n" +
     "zone logic.\n\n" +
     "Lower Panel:\n" +
     "IAI Live Tracker\n" +
     "Oscillator."
if barstate.islast and proj_1 and log_entry_1 and not show_intro and show_log
    project_log(proj1_log1, COLOR_AMBER, mint_cyan)



// ==========================================
// ⚙️️ #Proj 01 - Parameter & Rendering
// ==========================================
gp_iai_zones = '🎯 IAI ZONES (BETA)'

show_iai_zones = input.bool(true, 'Activity Zones... ', group = gp_iai_zones, active = not show_intro, inline = '1')

zone_options = input.string('Refining Zones', 'Options',group = gp_iai_zones, active = proj_1 and log_entry_2  and not show_intro, inline = '1', options = ['stable zones', 'Replace previous zone', 'Refining Zones'], display = display.none)

show_activity_dots = input.bool(true, "Show IAI Dots", group = gp_iai_zones, inline = '2', active = not show_intro)

show_structure = input.bool(true, 'Show OMSF Structure', group = gp_iai_zones, inline = '2', active = not show_intro,
     tooltip = "Toggle visual overlays: Displays yellow activity dots (combined Vola + Volume) and renders the underlying OMSF structural framework.")

activity_length = input.int(12,title = 'activity length', group=gp_iai_zones, active = not show_intro, display = display.none,
     tooltip = "Cumulative activity length (cumLen): Defines the bar lookback window used to accumulate intrabar activity index (IAI) signals for sustained volatility/volume tracking.")

lookback_period = input.int(50, maxval = 4900, title = 'Lookback Period', group=gp_iai_zones, active = not show_intro, display = display.none, 
     tooltip = 'Number of bars used for the PercentRank calculation. Higher values create more stable, long-term statistical averages.')

VolaTresh = input.float(85.0, step=1.0, title = 'Volatility Threshold (%)', group=gp_iai_zones, active = not show_intro, display = display.none, 
     tooltip = 'Defines the minimum percentile for price activity (True Range). \n\nExample: 85.0 means the current volatility must be higher than 85% of all bars in your lookback period. High volatility combined with high volume triggers the Activity Index (IAI).')

VolumeTresh = input.float(66.0, step=1.0, title = 'Volume Threshold (%)', group=gp_iai_zones, active = not show_intro, display = display.none, 
      tooltip = 'Defines the minimum percentile for volume engagement. \n\nExample: 85.0 means the current volume must be higher than 85% of all bars in your lookback period to be considered significant.')

// ===============================================================================
//|          Project 01 Object: IAI Zones [BETA]                                 |
// ===============================================================================

// --- Import OMSF Structure ---
[omsf_strHigh, omsf_strHightime, omsf_strLow, omsf_strLowtime, _, _, _, _, _, _, _, _, _, _, _, expansLong, expansShort, longCorr, shortCorr] = omsf.get_omsf_structure(false, 1, close, 14, 1.2, 1.5, 4)

bool omsf_breakout = (expansLong or expansShort) and (longCorr or shortCorr)[1]


// --- Extracted IAI Live Tracker (Cumulative Activity) ---  @link https://www.tradingview.com/script/OjktEsmn/

calc_cum_activity(int activity_length, int lookback, float vola_thresh, float volume_thresh, float low_volume_thresh) =>
    
    // Aggregate live data (Totals)
    float live_transfer_vola_total   = math.sum(ta.tr(true), activity_length)
    float live_transfer_volume_total = nz(math.sum(volume, activity_length), 0)
   
    // Adjust lookback to maintain statistical consistency across different data densities
    int safe_lookback = math.min(lookback * activity_length, 4900)
    
    // Percentile rank transformation (Live Transfer)
    float pct_live_vola   = ta.percentrank(live_transfer_vola_total, safe_lookback)
    float pct_live_volume = ta.percentrank(live_transfer_volume_total, safe_lookback)
    
    float live_vola   = pct_live_vola
    float live_volume = pct_live_volume

    // Booleans
    bool is_high_volume = live_volume > volume_thresh
    bool is_low_volume  = live_volume < low_volume_thresh
    bool is_high_vola   = live_vola > vola_thresh
    
    // CAI Logic (High Activity & Engagement)
    bool is_activity = (live_vola > vola_thresh and live_volume > volume_thresh)

    // Estimate trading days
    var int c = 0
    var float[] a = array.new<float>()

    c += 1
    if ta.change(time("D")) != 0
        if c > 1
            array.push(a, c - 1)
            if array.size(a) > 7
                array.shift(a)
        c := 1

    float trading_days = math.round(lookback / array.median(a), 2)

    [live_vola, live_volume, safe_lookback, is_high_volume, is_low_volume, is_high_vola, is_activity, trading_days]

[live_vola, live_volume, safe_lookback, is_high_volume, is_low_volume, is_high_vola, is_activity, trading_days] = calc_cum_activity(activity_length, lookback_period, VolaTresh, VolumeTresh, 25.0)

/// ===============================================================================
//|                        Activity Zone Logic & Management                       |
// ===============================================================================

get_cai_zones(float str_high, float str_low, bool is_activity, bool omsf_breakout, string zone_options) => 
    
    // --- 1. Activity & Latch-Trigger Logic ---
    var bool registered_activity = false
    
    // Arm memory flag when high-activity phase terminates (cooldown)
    if is_activity[1] and not is_activity 
        registered_activity := true

    bool check_new_zone = registered_activity and omsf_breakout

    // --- 2. Zone Memory Storage ---
    var float abz_high = na,      var float abz_low = na,      var int time_zone = na
    var float prev_abz_high = na, var float prev_abz_low = na, var int prev_time_zone = na

    // --- 3. Overlap Inspection ---
    bool is_overlapping_last = not na(abz_high)      and (str_high >= abz_low)      and (str_low <= abz_high)
    bool is_overlapping_prev = not na(prev_abz_high) and (str_high >= prev_abz_low) and (str_low <= prev_abz_high)

    // --- 4. Range Comparison for Refinement ---
    float last_zone_range = abz_high - abz_low
    float prev_zone_range = prev_abz_high - prev_abz_low
    float new_zone_range  = str_high - str_low

    bool is_smaller_than_last = is_overlapping_last and (new_zone_range < last_zone_range)
    bool is_smaller_than_prev = is_overlapping_prev and (new_zone_range < prev_zone_range)

    // --- 5. Zone Update Execution on Trigger ---
    if check_new_zone
        registered_activity := false // Reset latch trigger

        if zone_options == 'stable zones'
            // STABLE: No overlap allowed with 'last' OR 'prev' zones
            if not is_overlapping_last and not is_overlapping_prev
                prev_abz_high := abz_high, prev_abz_low := abz_low, prev_time_zone := time_zone
                abz_high := str_high,     abz_low := str_low,     time_zone := time

        else if zone_options == 'Replace previous zone'
            // REPLACE: Simple overwrite if no overlap with current last zone
            if not is_overlapping_last
                prev_abz_high := abz_high, prev_abz_low := abz_low, prev_time_zone := time_zone
                abz_high := str_high,     abz_low := str_low,     time_zone := time

        else if zone_options == 'Refining Zones'
            // REFINING: 1:1 replacement on overlap if new range is tighter (Last remains Last, Prev remains Prev)
            if is_smaller_than_last and not is_overlapping_prev
                // 1:1 replacement of 'last'
                abz_high := str_high, abz_low := str_low, time_zone := time
            else if is_smaller_than_prev and not is_overlapping_last
                // 1:1 replacement of 'prev'
                prev_abz_high := str_high, prev_abz_low := str_low, prev_time_zone := time
            else if not is_overlapping_last and not is_overlapping_prev
                // Completely new zone without overlap: Standard queue shift
                prev_abz_high := abz_high, prev_abz_low := abz_low, prev_time_zone := time_zone
                abz_high := str_high,     abz_low := str_low,     time_zone := time

    [abz_high, abz_low, time_zone, prev_abz_high, prev_abz_low, prev_time_zone]

// --- Function Call ---
[abz_High, abz_Low, timeZone, prev_abz_High, prev_abz_Low, prev_timeZone] = get_cai_zones(omsf_strHigh, omsf_strLow, is_activity, omsf_breakout, zone_options)

// ===============================================================================
//|               Visuals: Oscillator, Overlays & Beta Dashboard                 |
// ===============================================================================

// # Render Matrix
render_iai_zones = proj_1 and show_iai_zones 
render_iai_dash = proj_1 and show_beta_dash and not show_intro
render_iai_oszi = proj_1 and show_beta_oszi 
render_iai_dots = proj_1 and show_activity_dots and not show_intro
render_omsf_struct = proj_1 and show_structure and not show_intro

// --- 1. VISUALIZATION: IAI OSCILLATOR ---
color vol_color = is_activity ? color.new(color.orange, 30) : 
      (not is_low_volume ? color.new(color.navy, is_high_volume ? 10 : 50) : color.new(color.gray, 70))

// Volume Histogram (Background)
plot(render_iai_oszi ? live_volume : na, title='Volume Percentile', style=plot.style_columns, histbase=0, 
     color=vol_color, linewidth=2)

// Volatility Area
plot(render_iai_oszi ? live_vola : na, title='Volatility Percentile', style=plot.style_area, histbase=0, 
     color=is_high_vola ? color.new(color.orange, 75) : color.new(color.silver, 80), linewidth=2)

// --- LEVEL REFERENCES (Percentile Scale) ---
hline(render_iai_oszi ? 50 : na,          title='Median (50%)',         color=color.new(color.white, 50), linestyle=hline.style_dashed)
hline(render_iai_oszi ? VolumeTresh : na, title='Volume Threshold',     color=color.purple,              linestyle=hline.style_dashed)
hline(render_iai_oszi ? VolaTresh : na,   title='Volatility Threshold', color=color.orange,              linestyle=hline.style_dashed)


// --- 2. CHART OVERLAYS: ACTIVITY DOTS & OMSF STRUCTURE ---

// Candle direction helper functions
is_long_candle()  => open < close
is_short_candle() => open >= close

plotshape(render_iai_dots and is_activity and is_short_candle(), title='IAI Short', display=display.pane, color=color.yellow, style=shape.circle, location=location.abovebar, size=size.tiny, force_overlay=true)
plotshape(render_iai_dots and is_activity and is_long_candle(),  title='IAI Long',  display=display.pane, color=color.yellow, style=shape.circle, location=location.belowbar, size=size.tiny, force_overlay=true)

// OMSF Structural Levels
if render_omsf_struct
    vst.setLine(omsf_strHigh, omsf_strHightime, "", "above", "no ext.", 2, omsf_color)
    vst.setLine(omsf_strLow,  omsf_strLowtime,  "", "below", "no ext.", 2, omsf_color)

// Anchored Activity Zones
if render_iai_zones 
    vst.setBox(abz_High,      abz_Low,      timeZone,      time, "last ABZ",     "center", mint_cyan,  0, "solid", 70)
    vst.setBox(prev_abz_High, prev_abz_Low, prev_timeZone, time, "previous ABZ", "center", soft_coral, 0, "solid", 70) 


// --- 3. BETA DASHBOARD TABLE ---
iai_beta_dash(string position, string textsize, int cell_width) =>
    var table t = table.new(position, 3, 5, border_color=color.silver)    
    
    // Header
    table.cell(t, 0, 0, text='Cumulative Activity Zones', bgcolor=color.new(color.silver, 70), text_color=cream, text_size=size.small, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.merge_cells(t, 0, 0, 1, 0), table.merge_cells(t, 0, 0, 2, 0)
    
    // Row 1-3: Column 0 (Parameters & Settings)
    table.cell(t, 0, 1, text='MODE:\n' + zone_options, width=cell_width, bgcolor=COLOR_BG_DASH, text_color=COLOR_TEXT, text_size=textsize, text_font_family=font.family_monospace)
    table.cell(t, 0, 2, text='CUM LEN: ' + str.tostring(activity_length), width=cell_width, bgcolor=COLOR_BG_DASH, text_color=COLOR_TEXT, text_size=textsize, text_font_family=font.family_monospace)
    table.cell(t, 0, 3, text='LOOKBACK ' + str.tostring(lookback_period) + ' bars\n = ' + str.tostring(trading_days) + ' days', bgcolor=COLOR_BG_DASH, text_color=COLOR_TEXT, text_size=textsize, text_font_family=font.family_monospace)
    
    // Row 1-3: Column 1 (Volatility Status)
    table.cell(t, 1, 1, text='VOLA', width=cell_width, bgcolor=COLOR_BG_DASH, text_color=COLOR_AMBER, text_size=textsize, text_font_family=font.family_monospace)
    table.cell(t, 1, 2, text=str.tostring(live_vola, "#.##") + '% (' + str.tostring(VolaTresh) + '%)', width=cell_width, bgcolor=COLOR_BG_DASH, text_color=mint_cyan, text_size=textsize, text_font_family=font.family_monospace)
    table.cell(t, 1, 3, text='Threshold ' + str.tostring(VolaTresh) + '%', bgcolor=COLOR_BG_DASH, text_color=COLOR_AMBER, text_size=textsize, text_font_family=font.family_monospace)
    
    // Row 1-3: Column 2 (Volume Status)
    table.cell(t, 2, 1, text='VOLUME', width=cell_width, bgcolor=COLOR_BG_DASH, text_color=COLOR_AMBER, text_size=textsize, text_font_family=font.family_monospace)
    table.cell(t, 2, 2, text=str.tostring(live_volume, "#.##") + '% (' + str.tostring(VolumeTresh) + '%)', width=cell_width, bgcolor=COLOR_BG_DASH, text_color=mint_cyan, text_size=textsize, text_font_family=font.family_monospace)
    table.cell(t, 2, 3, text='Threshold ' + str.tostring(VolumeTresh) + '%', bgcolor=COLOR_BG_DASH, text_color=COLOR_AMBER, text_size=textsize, text_font_family=font.family_monospace)
    
    // Footer / Watermark
    table.cell(t, 0, 4, text="© 2026 ap | Made in Germany 🇩🇪", bgcolor=color.new(color.silver, 70), text_color=color.new(color.white, 30), text_size=size.tiny, text_halign=text.align_right)
    table.merge_cells(t, 0, 4, 1, 4), table.merge_cells(t, 0, 4, 2, 4)

// Render Dashboard Trigger
if show_beta_dash and render_iai_dash
    iai_beta_dash(position.bottom_left, size.normal, 10)

// ==========================================
//        🎨 BRANDING & LOGO BADGE
// ==========================================
gp_branding = '🎨 BRANDING & VISUALS'
show_werkstatt_logo  = input.bool(true, "Werkstatt logo", group = gp_branding, active = not show_intro)

render_werkstatt_sign_compact() =>
    var table logoTab = table.new(
         position = position.top_left, 
         columns = 1, 
         rows = 1, 
         bgcolor = color.new(#0b121f, 15), 
         border_width = 1, 
         border_color = color.new(#FF6B00, 30),
         force_overlay = true)
    string logo_text = 
         "┌─────────────────────────────────────────┐\n" +
         "│  ██████╗  ███╗   ███╗███████╗███████╗  │\n" +
         "│ ██╔═══██╗ ████╗ ████║██╔════╝██╔════╝  │\n" +
         "│ ██║   ██║ ██╔████╔██║███████╗█████╗    │\n" +
         "│ ██║   ██║ ██║╚██╔╝██║╚════██║██╔══╝    │\n" +
         "│ ╚██████╔╝ ██║ ╚═╝ ██║███████║██║       │\n" +
         "│  ╚═════╝  ╚═╝     ╚═╝╚══════╝╚═╝       │\n" +
         "│     W E R K S T A T T   v1.0           │\n" +
         "│         Engineer-Driven 🇩🇪             │\n" +
         "└─────────────────────────────────────────┘"
    table.cell(
         logoTab, 0, 0, logo_text, 
         text_color = #FF6B00, 
         text_size = size.tiny, 
         text_font_family = font.family_monospace, 
         text_halign = text.align_center)

if barstate.islast and show_intro
    render_werkstatt_sign()
if barstate.islast and show_werkstatt_logo and not show_intro
    render_werkstatt_sign_compact() 


///////////////////                      * ⚠️DISCLAIMER *                         ////////////////////////////////////////                                                       
// This indicator is developed and released under the DIE WERKSTATT research initiative for educational, analytical,    //
// and testing purposes only ([beta]). It does not constitute financial or investment advice.                           //  
// Trading financial markets involves substantial risk of capital loss.                                                 //
// Always apply proper risk management, test strategies thoroughly in replay mode, and make your own trading decisions. //                                                                                                     
//////////////////                             ---                                 ///////////////////////////////////////
````
