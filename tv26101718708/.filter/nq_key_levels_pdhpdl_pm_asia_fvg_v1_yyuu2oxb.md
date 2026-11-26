# NQ Key Levels [PDH/PDL | PM | Asia | FVG] V1

- url: https://www.tradingview.com/script/YyUU2oXB-NQ-Key-Levels-PDH-PDL-PM-Asia-FVG-V1/
- type: indicator
- pine_id: PUB;b0f6ace3db994ffba9c0cfb40cfc2580
- version: 3.0

## Description

NQ Key Levels plots four essential intraday reference levels directly on your chart: Previous Day High/Low, Premarket High/Low (8–9:30 AM ET), Asia Session High/Low (8 PM–Midnight ET), and HTF Fair Value Gaps. Built specifically for NQ futures with CME/New York session timing baked in — just add it to your chart and all levels update automatically.

## Source Code

````pine
//@version=6
indicator("NQ Key Levels V3 [Sweep + Displacement Engine]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=200)

// ─────────────────────────────────────────────
// GROUP: Previous Day High / Low
// ─────────────────────────────────────────────
grp_pd = "📅 Previous Day H/L"
show_pd        = input.bool(true,  "Show Previous Day H/L",   group=grp_pd)
pd_high_color  = input.color(color.new(#00BFFF, 0), "High Color", group=grp_pd)
pd_low_color   = input.color(color.new(#FF4444, 0), "Low Color",  group=grp_pd)
pd_line_width  = input.int(1, "Line Width", minval=1, maxval=4,   group=grp_pd)
pd_line_style  = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=grp_pd)
pd_show_labels = input.bool(true, "Show Labels",                  group=grp_pd)

// ─────────────────────────────────────────────
// GROUP: Premarket High / Low
// ─────────────────────────────────────────────
grp_pm = "🌅 Premarket H/L (8:00–9:30 AM ET)"
show_pm        = input.bool(true,  "Show Premarket H/L",      group=grp_pm)
pm_high_color  = input.color(color.new(#FFD700, 0), "High Color", group=grp_pm)
pm_low_color   = input.color(color.new(#FFA500, 0), "Low Color",  group=grp_pm)
pm_line_width  = input.int(1, "Line Width", minval=1, maxval=4,   group=grp_pm)
pm_line_style  = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=grp_pm)
pm_show_labels = input.bool(true, "Show Labels",                  group=grp_pm)

// ─────────────────────────────────────────────
// GROUP: Asia Session High / Low
// ─────────────────────────────────────────────
grp_as = "🌏 Asia Session H/L (8 PM–Midnight ET)"
show_asia        = input.bool(true,  "Show Asia H/L",           group=grp_as)
asia_high_color  = input.color(color.new(#9B59B6, 0), "High Color", group=grp_as)
asia_low_color   = input.color(color.new(#C39BD3, 0), "Low Color",  group=grp_as)
asia_line_width  = input.int(1, "Line Width", minval=1, maxval=4,   group=grp_as)
asia_line_style  = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=grp_as)
asia_show_labels = input.bool(true, "Show Labels",                  group=grp_as)

// ─────────────────────────────────────────────
// GROUP: HTF Fair Value Gaps
// ─────────────────────────────────────────────
grp_fvg = "📦 HTF Fair Value Gaps"
show_fvg        = input.bool(true,  "Show FVGs",                 group=grp_fvg)
fvg_tf          = input.timeframe("15", "HTF Timeframe",         group=grp_fvg)
fvg_bull_color  = input.color(color.new(#00FF88, 80), "Bullish FVG Fill",   group=grp_fvg)
fvg_bear_color  = input.color(color.new(#FF4444, 80), "Bearish FVG Fill",   group=grp_fvg)
fvg_bull_border = input.color(color.new(#00FF88, 20), "Bullish FVG Border", group=grp_fvg)
fvg_bear_border = input.color(color.new(#FF4444, 20), "Bearish FVG Border", group=grp_fvg)
fvg_labels      = input.bool(true,  "Show FVG Labels",           group=grp_fvg)
fvg_mitigate    = input.bool(true,  "Hide When Mitigated",       group=grp_fvg)
fvg_max         = input.int(40, "Max FVGs Shown", minval=1, maxval=100, group=grp_fvg)

// ─────────────────────────────────────────────
// GROUP: Liquidity Sweeps
// ─────────────────────────────────────────────
grp_sw = "💧 Liquidity Sweeps"
show_sweeps      = input.bool(true,  "Show Sweep Signals",          group=grp_sw)
sweep_pdh_on     = input.bool(true,  "PDH Sweeps",                  group=grp_sw)
sweep_pdl_on     = input.bool(true,  "PDL Sweeps",                  group=grp_sw)
sweep_pmh_on     = input.bool(true,  "PMH Sweeps",                  group=grp_sw)
sweep_pml_on     = input.bool(true,  "PML Sweeps",                  group=grp_sw)
sweep_asiah_on   = input.bool(true,  "Asia High Sweeps",            group=grp_sw)
sweep_asial_on   = input.bool(true,  "Asia Low Sweeps",             group=grp_sw)
bear_sweep_color = input.color(color.new(#FF4444, 0), "Bear Sweep Color", group=grp_sw)
bull_sweep_color = input.color(color.new(#00FF88, 0), "Bull Sweep Color", group=grp_sw)
min_sweep_ticks  = input.int(8, "Minimum Wick Through Level (ticks)", minval=1, maxval=50, group=grp_sw, tooltip="Price must pierce the level by this many ticks before closing back through")

// ─────────────────────────────────────────────
// GROUP: V3 Displacement Engine
// ─────────────────────────────────────────────
grp_v3 = "⚡ V3 Displacement Engine"
show_confirmed    = input.bool(true,  "Show Confirmed Setups Only",        group=grp_v3, tooltip="Only show sweeps confirmed by a displacement candle within the window")
disp_mult         = input.float(1.75, "Displacement Multiplier",           group=grp_v3, minval=1.0, maxval=4.0, step=0.1, tooltip="Candle range must exceed X × avg range to count as displacement")
disp_lookback     = input.int(20,     "Displacement Avg Lookback",          group=grp_v3, minval=5, maxval=50)
confirm_window    = input.int(5,      "Confirmation Window (bars)",         group=grp_v3, minval=1, maxval=10, tooltip="Bars after sweep to look for displacement. Sweep candle itself excluded.")
show_disp_candles = input.bool(true,  "Highlight Displacement Candles",     group=grp_v3)
disp_bull_color   = input.color(color.new(#00FF88, 60), "Bull Displacement Bg", group=grp_v3)
disp_bear_color   = input.color(color.new(#FF4444, 60), "Bear Displacement Bg", group=grp_v3)
show_entry_fvg    = input.bool(true,  "Mark Post-Sweep FVGs as Entry Zones", group=grp_v3)
entry_fvg_color   = input.color(color.new(#FFD700, 70), "Entry Zone FVG Color",  group=grp_v3)
entry_fvg_border  = input.color(color.new(#FFD700, 10), "Entry Zone FVG Border", group=grp_v3)

// ─────────────────────────────────────────────
// GLOBAL BAR CALCULATIONS
// ─────────────────────────────────────────────
new_day  = ta.change(time("D")) != 0
bar_hour = hour(time, "America/New_York")
bar_min  = minute(time, "America/New_York")

in_premarket = bar_hour == 8 or (bar_hour == 9 and bar_min < 30)
rth_open     = bar_hour == 9 and bar_min == 30
in_asia      = bar_hour >= 20
tick         = syminfo.mintick

// ─────────────────────────────────────────────
// DISPLACEMENT ENGINE
// ─────────────────────────────────────────────
candle_range = high - low
avg_range    = ta.sma(candle_range, disp_lookback)
is_disp      = candle_range > avg_range * disp_mult
is_disp_bear = is_disp and close < open
is_disp_bull = is_disp and close > open

bgcolor(show_disp_candles and is_disp_bear ? disp_bear_color : na, title="Bear Displacement Bar")
bgcolor(show_disp_candles and is_disp_bull ? disp_bull_color : na, title="Bull Displacement Bar")

// ─────────────────────────────────────────────
// HELPER
// ─────────────────────────────────────────────
getStyle(s) =>
    s == "Dotted" ? line.style_dotted : s == "Solid" ? line.style_solid : line.style_dashed

// ─────────────────────────────────────────────
// PREVIOUS DAY HIGH / LOW
// ─────────────────────────────────────────────
[pd_h, pd_l] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

var line  pdh_line = na
var line  pdl_line = na
var label pdh_lbl  = na
var label pdl_lbl  = na

if show_pd and new_day
    line.delete(pdh_line)
    line.delete(pdl_line)
    label.delete(pdh_lbl)
    label.delete(pdl_lbl)
    pdh_line := line.new(bar_index, pd_h, bar_index, pd_h, color=pd_high_color, width=pd_line_width, style=getStyle(pd_line_style), extend=extend.right)
    pdl_line := line.new(bar_index, pd_l, bar_index, pd_l, color=pd_low_color,  width=pd_line_width, style=getStyle(pd_line_style), extend=extend.right)
    if pd_show_labels
        pdh_lbl := label.new(bar_index, pd_h, "PDH " + str.tostring(pd_h, format.mintick), color=color.new(pd_high_color, 85), textcolor=pd_high_color, style=label.style_label_right, size=size.small)
        pdl_lbl := label.new(bar_index, pd_l, "PDL " + str.tostring(pd_l, format.mintick), color=color.new(pd_low_color,  85), textcolor=pd_low_color,  style=label.style_label_right, size=size.small)

// ─────────────────────────────────────────────
// PREMARKET HIGH / LOW
// ─────────────────────────────────────────────
var float pmh      = na
var float pml      = na
var bool  pm_ready = false
var line  pmh_line = na
var line  pml_line = na
var label pmh_lbl  = na
var label pml_lbl  = na

if new_day
    pmh      := na
    pml      := na
    pm_ready := false

if show_pm and in_premarket
    pmh      := na(pmh) ? high : math.max(pmh, high)
    pml      := na(pml) ? low  : math.min(pml, low)
    pm_ready := true

if show_pm and rth_open and pm_ready and not na(pmh)
    line.delete(pmh_line)
    line.delete(pml_line)
    label.delete(pmh_lbl)
    label.delete(pml_lbl)
    pmh_line := line.new(bar_index, pmh, bar_index, pmh, color=pm_high_color, width=pm_line_width, style=getStyle(pm_line_style), extend=extend.right)
    pml_line := line.new(bar_index, pml, bar_index, pml, color=pm_low_color,  width=pm_line_width, style=getStyle(pm_line_style), extend=extend.right)
    if pm_show_labels
        pmh_lbl := label.new(bar_index, pmh, "PMH " + str.tostring(pmh, format.mintick), color=color.new(pm_high_color, 85), textcolor=pm_high_color, style=label.style_label_right, size=size.small)
        pml_lbl := label.new(bar_index, pml, "PML " + str.tostring(pml, format.mintick), color=color.new(pm_low_color,  85), textcolor=pm_low_color,  style=label.style_label_right, size=size.small)

// ─────────────────────────────────────────────
// ASIA SESSION HIGH / LOW
// ─────────────────────────────────────────────
var float asiah        = na
var float asial        = na
var bool  asia_ready   = false
var bool  prev_in_asia = false
var line  asiah_line   = na
var line  asial_line   = na
var label asiah_lbl    = na
var label asial_lbl    = na

asia_start = in_asia and not prev_in_asia
asia_end   = not in_asia and prev_in_asia and bar_hour == 0

if asia_start
    asiah      := na
    asial      := na
    asia_ready := false

if show_asia and in_asia
    asiah      := na(asiah) ? high : math.max(asiah, high)
    asial      := na(asial) ? low  : math.min(asial, low)
    asia_ready := true

if show_asia and asia_end and asia_ready and not na(asiah)
    line.delete(asiah_line)
    line.delete(asial_line)
    label.delete(asiah_lbl)
    label.delete(asial_lbl)
    asiah_line := line.new(bar_index, asiah, bar_index, asiah, color=asia_high_color, width=asia_line_width, style=getStyle(asia_line_style), extend=extend.right)
    asial_line := line.new(bar_index, asial, bar_index, asial, color=asia_low_color,  width=asia_line_width, style=getStyle(asia_line_style), extend=extend.right)
    if asia_show_labels
        asiah_lbl := label.new(bar_index, asiah, "Asia H " + str.tostring(asiah, format.mintick), color=color.new(asia_high_color, 85), textcolor=asia_high_color, style=label.style_label_right, size=size.small)
        asial_lbl := label.new(bar_index, asial, "Asia L " + str.tostring(asial, format.mintick), color=color.new(asia_low_color,  85), textcolor=asia_low_color,  style=label.style_label_right, size=size.small)

prev_in_asia := in_asia

// ─────────────────────────────────────────────
// LIQUIDITY SWEEP DETECTION
// First sweep only per level per session
// ─────────────────────────────────────────────
sweep_size = min_sweep_ticks * tick

var bool pdh_swept   = false
var bool pdl_swept   = false
var bool pmh_swept   = false
var bool pml_swept   = false
var bool asiah_swept = false
var bool asial_swept = false

if new_day
    pdh_swept   := false
    pdl_swept   := false
    pmh_swept   := false
    pml_swept   := false
    asiah_swept := false
    asial_swept := false

if asia_start
    asiah_swept := false
    asial_swept := false

raw_pdh_bear   = sweep_pdh_on   and not pdh_swept   and not na(pd_h)  and high > pd_h   + sweep_size and close < pd_h
raw_pdl_bull   = sweep_pdl_on   and not pdl_swept   and not na(pd_l)  and low  < pd_l   - sweep_size and close > pd_l
raw_pmh_bear   = sweep_pmh_on   and not pmh_swept   and not na(pmh)   and high > pmh    + sweep_size and close < pmh
raw_pml_bull   = sweep_pml_on   and not pml_swept   and not na(pml)   and low  < pml    - sweep_size and close > pml
raw_asiah_bear = sweep_asiah_on and not asiah_swept and not na(asiah) and high > asiah  + sweep_size and close < asiah
raw_asial_bull = sweep_asial_on and not asial_swept and not na(asial) and low  < asial  - sweep_size and close > asial

if raw_pdh_bear
    pdh_swept := true
if raw_pdl_bull
    pdl_swept := true
if raw_pmh_bear
    pmh_swept := true
if raw_pml_bull
    pml_swept := true
if raw_asiah_bear
    asiah_swept := true
if raw_asial_bull
    asial_swept := true

any_raw_bear = raw_pdh_bear or raw_pmh_bear or raw_asiah_bear
any_raw_bull = raw_pdl_bull or raw_pml_bull or raw_asial_bull

// ─────────────────────────────────────────────
// STATE MACHINE: Confirmation Window
// ─────────────────────────────────────────────
var int    bear_sweep_bar  = na
var int    bull_sweep_bar  = na
var string bear_sweep_name = ""
var string bull_sweep_name = ""

if any_raw_bear and na(bear_sweep_bar)
    bear_sweep_bar  := bar_index
    bear_sweep_name := raw_pdh_bear ? "PDH" : raw_pmh_bear ? "PMH" : "AH"

if any_raw_bull and na(bull_sweep_bar)
    bull_sweep_bar  := bar_index
    bull_sweep_name := raw_pdl_bull ? "PDL" : raw_pml_bull ? "PML" : "AL"

in_bear_window = not na(bear_sweep_bar) and (bar_index - bear_sweep_bar) >= 1 and (bar_index - bear_sweep_bar) <= confirm_window
in_bull_window = not na(bull_sweep_bar) and (bar_index - bull_sweep_bar) >= 1 and (bar_index - bull_sweep_bar) <= confirm_window

bear_confirmed = in_bear_window and is_disp_bear
bull_confirmed = in_bull_window and is_disp_bull

if bear_confirmed or (not na(bear_sweep_bar) and (bar_index - bear_sweep_bar) > confirm_window)
    bear_sweep_bar := na

if bull_confirmed or (not na(bull_sweep_bar) and (bar_index - bull_sweep_bar) > confirm_window)
    bull_sweep_bar := na

// ─────────────────────────────────────────────
// CONFIRMED SWEEP MARKERS
// Plotted on the displacement candle
// ─────────────────────────────────────────────
if show_sweeps and bear_confirmed
    label.new(bar_index, high, bear_sweep_name + "✓",
         color=color.new(bear_sweep_color, 20),
         textcolor=color.white,
         style=label.style_label_down,
         size=size.small)

if show_sweeps and bull_confirmed
    label.new(bar_index, low, bull_sweep_name + "✓",
         color=color.new(bull_sweep_color, 20),
         textcolor=color.white,
         style=label.style_label_up,
         size=size.small)

// Unconfirmed raw sweeps (shown when show_confirmed is OFF)
plotshape(show_sweeps and not show_confirmed and raw_pdh_bear,   title="PDH Bear Sweep",    style=shape.triangledown, location=location.abovebar, color=bear_sweep_color, size=size.small, text="PDH")
plotshape(show_sweeps and not show_confirmed and raw_pmh_bear,   title="PMH Bear Sweep",    style=shape.triangledown, location=location.abovebar, color=bear_sweep_color, size=size.small, text="PMH")
plotshape(show_sweeps and not show_confirmed and raw_asiah_bear, title="Asia H Bear Sweep", style=shape.triangledown, location=location.abovebar, color=bear_sweep_color, size=size.small, text="AH")
plotshape(show_sweeps and not show_confirmed and raw_pdl_bull,   title="PDL Bull Sweep",    style=shape.triangleup,   location=location.belowbar, color=bull_sweep_color, size=size.small, text="PDL")
plotshape(show_sweeps and not show_confirmed and raw_pml_bull,   title="PML Bull Sweep",    style=shape.triangleup,   location=location.belowbar, color=bull_sweep_color, size=size.small, text="PML")
plotshape(show_sweeps and not show_confirmed and raw_asial_bull, title="Asia L Bull Sweep", style=shape.triangleup,   location=location.belowbar, color=bull_sweep_color, size=size.small, text="AL")

// ─────────────────────────────────────────────
// POST-SWEEP FVG WATCH FLAGS
// ─────────────────────────────────────────────
var bool watch_for_bear_fvg = false
var bool watch_for_bull_fvg = false

if bear_confirmed
    watch_for_bear_fvg := true
if bull_confirmed
    watch_for_bull_fvg := true

if new_day
    watch_for_bear_fvg := false
    watch_for_bull_fvg := false

// ─────────────────────────────────────────────
// HTF FAIR VALUE GAPS
// ─────────────────────────────────────────────
htf_h0  = request.security(syminfo.tickerid, fvg_tf, high,      lookahead=barmerge.lookahead_off)
htf_h2  = request.security(syminfo.tickerid, fvg_tf, high[2],   lookahead=barmerge.lookahead_off)
htf_l0  = request.security(syminfo.tickerid, fvg_tf, low,       lookahead=barmerge.lookahead_off)
htf_l2  = request.security(syminfo.tickerid, fvg_tf, low[2],    lookahead=barmerge.lookahead_off)
htf_bar = request.security(syminfo.tickerid, fvg_tf, bar_index, lookahead=barmerge.lookahead_off)

var box[]   fvg_box_arr = array.new_box()
var bool[]  fvg_is_bull = array.new_bool()
var float[] fvg_tops    = array.new_float()
var float[] fvg_bots    = array.new_float()
var label[] fvg_lbl_arr = array.new_label()

var bool entry_fvg_created = false
entry_fvg_created := false

htf_new  = ta.change(htf_bar) != 0
bull_fvg = htf_h2 < htf_l0
bear_fvg = htf_l2 > htf_h0

if show_fvg and htf_new
    if bull_fvg
        top_v    = htf_l0
        bot_v    = htf_h2
        mid_v    = math.avg(top_v, bot_v)
        is_entry = show_entry_fvg and watch_for_bull_fvg
        box_col  = is_entry ? entry_fvg_color  : fvg_bull_color
        bord_col = is_entry ? entry_fvg_border : fvg_bull_border
        lbl_txt  = is_entry ? "⚡ ENTRY"       : "BFVG"
        lbl_col  = is_entry ? entry_fvg_border : fvg_bull_border
        b = box.new(bar_index - 1, top_v, bar_index, bot_v, border_color=bord_col, bgcolor=box_col, border_width=is_entry ? 2 : 1, extend=extend.right)
        array.push(fvg_box_arr, b)
        array.push(fvg_is_bull, true)
        array.push(fvg_tops, top_v)
        array.push(fvg_bots, bot_v)
        if fvg_labels
            array.push(fvg_lbl_arr, label.new(bar_index, mid_v, lbl_txt, color=color.new(lbl_col, 80), textcolor=lbl_col, style=label.style_label_left, size=is_entry ? size.small : size.tiny))
        else
            array.push(fvg_lbl_arr, label(na))
        if is_entry
            watch_for_bull_fvg := false
            entry_fvg_created  := true

    if bear_fvg
        top_v    = htf_l2
        bot_v    = htf_h0
        mid_v    = math.avg(top_v, bot_v)
        is_entry = show_entry_fvg and watch_for_bear_fvg
        box_col  = is_entry ? entry_fvg_color  : fvg_bear_color
        bord_col = is_entry ? entry_fvg_border : fvg_bear_border
        lbl_txt  = is_entry ? "⚡ ENTRY"       : "BRVG"
        lbl_col  = is_entry ? entry_fvg_border : fvg_bear_border
        b = box.new(bar_index - 1, top_v, bar_index, bot_v, border_color=bord_col, bgcolor=box_col, border_width=is_entry ? 2 : 1, extend=extend.right)
        array.push(fvg_box_arr, b)
        array.push(fvg_is_bull, false)
        array.push(fvg_tops, top_v)
        array.push(fvg_bots, bot_v)
        if fvg_labels
            array.push(fvg_lbl_arr, label.new(bar_index, mid_v, lbl_txt, color=color.new(lbl_col, 80), textcolor=lbl_col, style=label.style_label_left, size=is_entry ? size.small : size.tiny))
        else
            array.push(fvg_lbl_arr, label(na))
        if is_entry
            watch_for_bear_fvg := false
            entry_fvg_created  := true

if show_fvg and fvg_mitigate and array.size(fvg_box_arr) > 0
    i = 0
    while i < array.size(fvg_box_arr)
        is_bull   = array.get(fvg_is_bull, i)
        top_v     = array.get(fvg_tops,    i)
        bot_v     = array.get(fvg_bots,    i)
        mitigated = is_bull ? close <= bot_v : close >= top_v
        if mitigated
            box.delete(array.get(fvg_box_arr, i))
            lbl = array.get(fvg_lbl_arr, i)
            if not na(lbl)
                label.delete(lbl)
            array.remove(fvg_box_arr, i)
            array.remove(fvg_is_bull, i)
            array.remove(fvg_tops,    i)
            array.remove(fvg_bots,    i)
            array.remove(fvg_lbl_arr, i)
        else
            i += 1

if array.size(fvg_box_arr) > fvg_max
    box.delete(array.shift(fvg_box_arr))
    array.shift(fvg_is_bull)
    array.shift(fvg_tops)
    array.shift(fvg_bots)
    old_lbl = array.shift(fvg_lbl_arr)
    if not na(old_lbl)
        label.delete(old_lbl)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(bear_confirmed, title="🔴 Confirmed Bearish Sweep + Displacement", message="NQ: Bearish sweep confirmed with displacement. Watch for entry FVG.")
alertcondition(bull_confirmed, title="🟢 Confirmed Bullish Sweep + Displacement", message="NQ: Bullish sweep confirmed with displacement. Watch for entry FVG.")
alertcondition(bear_confirmed or bull_confirmed, title="⚡ Confirmed Sweep (Any)", message="NQ: Confirmed sweep + displacement on key level.")
alertcondition(entry_fvg_created, title="🎯 Entry FVG Created", message="NQ: Post-sweep entry FVG just formed. Trade zone is active.")
````
