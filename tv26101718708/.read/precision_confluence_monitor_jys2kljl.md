# Precision Confluence Monitor

- url: https://www.tradingview.com/script/JyS2KljL-Precision-Confluence-Monitor/
- type: indicator
- pine_id: PUB;a54981a41f9745c3a73adeed43ed4c5e
- version: 2.0

## Description

Precision Confluence Monitor (PCM)
PCM tracks your Precision SPX levels and confirms each one against live NDX confluence before flagging an entry. You paste two comma-separated strings — your SPX levels and the matching NDX levels — and the script pairs them by position, then watches price action against both indices in real time.
How it works
The core logic is a two-candle confirmation rule. Candle 1 (C1) fires when price closes on the same side of a level on both SPX and NDX simultaneously — calls if both close above, puts if both close below. Candle 2 then confirms the move and triggers the actual ENTRY signal. This dual-index requirement filters out single-market fakeouts where SPX breaks a level but NDX doesn't follow.
Level categories (by index position in your string):

0–5: Daily levels
6–7: Range levels
8–9: Weekly levels
10–11: Monthly levels

Each type is color-coded on the chart with lines, zones, and labels showing the level price, its NDX pair, and live distance in points.
Built-in protections

Fail counter: every time a level is tested and rejected, it's tracked. After 2+ failures the level is flagged AVOID — the script will not give an entry there, keeping you out of chop.
SMA confirmation filter (optional): requires both SPX price and NDX to be on the correct side of the Fast/Slow SMAs before allowing a signal.
Volume filter (optional): requires ≥1.5× average volume to confirm a genuine break.

Display
A live status table summarizes every active level: SPX price, NDX pair, type, distance, whether NDX confirms, current signal state (Watch / C1 / Entry / Avoid), and fail count. On-chart labels and alerts (C1, Entry, and Avoid) keep you updated without watching the table.
Inputs reset daily so each session starts clean.
This script is a decision-support tool, not financial advice. Always manage your own risk.

## Source Code

````pine
//@version=6
// Precision Confluence Monitor
// Combines SPX Precision Levels with NDX confluence engine.
// Paste Mr. Precision's SPX string and NDX string — levels pair by index position.
// Two-candle rule: both SPX and NDX must close on same side for C1, then C2 = entry signal.
indicator("Precision Confluence Monitor", shorttitle="PCM", overlay=true,
          max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════

spx_str = input.string("", "SPX Levels (comma-separated)",  group="▶ Level Inputs",
     tooltip="e.g. 7551,7536,7529,7511,7498,7484,7565,7470,7576,7357,7367,6763\nIndex 0-5=Daily, 6-7=Range, 8-9=Weekly, 10-11=Monthly")
ndx_str = input.string("", "NDX Confluence (comma-separated)", group="▶ Level Inputs",
     tooltip="e.g. 30162,30082,30033,29943,29869,29736,...\nMust match SPX string length — pairs by position")

show_lines   = input.bool(true,  "Show Level Lines & Zones", group="▶ Display")
show_labels  = input.bool(true,  "Show Level Labels",        group="▶ Display")
show_signals = input.bool(true,  "Show Entry Signals on Chart", group="▶ Display")
show_table   = input.bool(true,  "Show Status Table",        group="▶ Display")
tbl_pos_str  = input.string("top_right", "Table Position",
     options=["top_right","top_left","bottom_right","bottom_left"], group="▶ Display")

use_sma  = input.bool(true,  "SMA Confirmation Filter",    group="▶ Filters",
     tooltip="Requires price & NDX to be on correct side of Fast/Slow SMAs")
sma_fast = input.int(10, "Fast SMA Period", minval=1,      group="▶ Filters")
sma_slow = input.int(20, "Slow SMA Period", minval=1,      group="▶ Filters")
use_vol  = input.bool(false, "Volume Filter (>=1.5x avg)", group="▶ Filters",
     tooltip="Genuine breaks typically spike volume 1.5x average")
vol_len  = input.int(20, "Volume Avg Length", minval=1,    group="▶ Filters")

alert_on = input.bool(true, "Enable Alerts (C1, Entry, Avoid)", group="▶ Alerts")

// ══════════════════════════════════════════════════════════════
// NDX LIVE DATA
// ══════════════════════════════════════════════════════════════
ndx_close = request.security("SPREADEX:NDX", timeframe.period, close)
ndx_sma_f = request.security("SPREADEX:NDX", timeframe.period, ta.sma(close, sma_fast))
ndx_sma_s = request.security("SPREADEX:NDX", timeframe.period, ta.sma(close, sma_slow))

// ══════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════
spx_arr = str.split(spx_str, ",")
ndx_arr = str.split(ndx_str, ",")
MAX     = 12

get_lvl(arr, i) =>
    float v = 0.0
    if array.size(arr) > i
        s = str.trim(array.get(arr, i))
        if str.length(s) > 0
            parsed = str.tonumber(s)
            if not na(parsed) and parsed > 0.0
                v := parsed
    v

// Red=Daily(0,1,4,5) Pink=Daily(2,3) Cyan=Range(6,7) Blue=Weekly(8,9) Purple=Monthly(10,11)
lvl_color(i) =>
    switch
        i == 0 or i == 1 or i == 4 or i == 5 => color.rgb(255, 40,  40)
        i == 2 or i == 3                      => color.rgb(255, 105, 180)
        i == 6 or i == 7                      => color.rgb(0,  188, 212)
        i == 8 or i == 9                      => color.rgb(60, 120, 255)
        =>                                       color.rgb(160, 60, 200)

lvl_type(i) =>
    i <= 5 ? "Daily" : i <= 7 ? "Range" : i <= 9 ? "Weekly" : "Monthly"

// ══════════════════════════════════════════════════════════════
// SMA & VOLUME FILTERS
// ══════════════════════════════════════════════════════════════
spx_sma_f = ta.sma(close, sma_fast)
spx_sma_s = ta.sma(close, sma_slow)
avg_vol   = ta.sma(volume, vol_len)

spx_bull_sma = close > spx_sma_f and spx_sma_f >= spx_sma_s
spx_bear_sma = close < spx_sma_f and spx_sma_f <= spx_sma_s
ndx_bull_sma = ndx_close > ndx_sma_f and ndx_sma_f >= ndx_sma_s
ndx_bear_sma = ndx_close < ndx_sma_f and ndx_sma_f <= ndx_sma_s
vol_ok       = not use_vol or volume >= avg_vol * 1.5

// ══════════════════════════════════════════════════════════════
// STATE ARRAYS
// 0=Watch 1=C1-calls -1=C1-puts 2=Entry-calls -2=Entry-puts
// ══════════════════════════════════════════════════════════════
var int[]   st_arr   = array.new_int(MAX, 0)
var int[]   fail_arr = array.new_int(MAX, 0)
var label[] sig_pool = array.new_label()

if dayofmonth != dayofmonth[1]
    for i = 0 to MAX - 1
        array.set(st_arr,   i, 0)
        array.set(fail_arr, i, 0)

if array.size(sig_pool) >= 480
    label.delete(array.get(sig_pool, 0))
    array.remove(sig_pool, 0)

// ══════════════════════════════════════════════════════════════
// CORE PROCESSING — wrapped in function to avoid RE10045
// (per-level variables now live in function scope, not global)
// ══════════════════════════════════════════════════════════════
process_level(i) =>
    spx_p = get_lvl(spx_arr, i)
    ndx_p = get_lvl(ndx_arr, i)
    if spx_p != 0.0
        int st  = array.get(st_arr,   i)
        int fc  = array.get(fail_arr, i)
        bool spx_above   = close > spx_p
        bool spx_below   = close < spx_p
        bool ndx_above   = ndx_p == 0.0 or ndx_close > ndx_p
        bool ndx_below   = ndx_p == 0.0 or ndx_close < ndx_p
        bool both_above  = spx_above and ndx_above
        bool both_below  = spx_below and ndx_below
        bool calls_ok    = not use_sma or (spx_bull_sma and ndx_bull_sma)
        bool puts_ok     = not use_sma or (spx_bear_sma and ndx_bear_sma)
        bool ndx_lost_up = ndx_p > 0.0 and ndx_close < ndx_p
        bool ndx_lost_dn = ndx_p > 0.0 and ndx_close > ndx_p
        int  new_st      = st

        if st == 0
            if both_above and vol_ok and calls_ok
                new_st := 1
                if show_signals
                    array.push(sig_pool, label.new(bar_index, spx_p,
                         "C1 up " + str.tostring(spx_p, "#") + (fc > 0 ? "  [" + str.tostring(fc) + " fail]" : ""),
                         color=color.new(color.green, 35), style=label.style_label_up, textcolor=color.white, size=size.small))
                if alert_on
                    alert("PCM C1 CALLS - SPX " + str.tostring(spx_p, "#") + " | NDX " + str.tostring(ndx_p, "#") + " | Prior fails: " + str.tostring(fc), alert.freq_once_per_bar)
            else if both_below and vol_ok and puts_ok
                new_st := -1
                if show_signals
                    array.push(sig_pool, label.new(bar_index, spx_p,
                         "C1 dn " + str.tostring(spx_p, "#") + (fc > 0 ? "  [" + str.tostring(fc) + " fail]" : ""),
                         color=color.new(color.red, 35), style=label.style_label_down, textcolor=color.white, size=size.small))
                if alert_on
                    alert("PCM C1 PUTS - SPX " + str.tostring(spx_p, "#") + " | NDX " + str.tostring(ndx_p, "#") + " | Prior fails: " + str.tostring(fc), alert.freq_once_per_bar)

        else if st == 1
            if both_above and vol_ok
                if fc >= 2
                    new_st := 0
                    if show_signals
                        array.push(sig_pool, label.new(bar_index, spx_p,
                             "AVOID " + str.tostring(spx_p, "#") + " (" + str.tostring(fc) + " fails)",
                             color=color.orange, style=label.style_label_down, textcolor=color.white, size=size.small))
                    if alert_on
                        alert("PCM AVOID - SPX " + str.tostring(spx_p, "#") + " has failed " + str.tostring(fc) + " times. DO NOT ENTER.", alert.freq_once_per_bar)
                else
                    new_st := 2
                    if show_signals
                        array.push(sig_pool, label.new(bar_index, spx_p,
                             "ENTRY CALLS " + str.tostring(spx_p, "#") + " | NDX " + str.tostring(ndx_p, "#"),
                             color=color.rgb(0, 180, 0), style=label.style_label_up, textcolor=color.white, size=size.small))
                    if alert_on
                        alert("PCM ENTRY CALLS - SPX " + str.tostring(spx_p, "#") + " | NDX " + str.tostring(ndx_p, "#") + " | Target: next Precision level above", alert.freq_once_per_bar)
            else if spx_below or ndx_lost_up
                new_st := 0
                array.set(fail_arr, i, fc + 1)
                if show_signals
                    array.push(sig_pool, label.new(bar_index, spx_p, "FAIL " + str.tostring(spx_p, "#"),
                         color=color.rgb(100, 100, 100), style=label.style_label_down, textcolor=color.white, size=size.tiny))

        else if st == -1
            if both_below and vol_ok
                if fc >= 2
                    new_st := 0
                    if show_signals
                        array.push(sig_pool, label.new(bar_index, spx_p,
                             "AVOID " + str.tostring(spx_p, "#") + " (" + str.tostring(fc) + " fails)",
                             color=color.orange, style=label.style_label_up, textcolor=color.white, size=size.small))
                    if alert_on
                        alert("PCM AVOID - SPX " + str.tostring(spx_p, "#") + " has failed " + str.tostring(fc) + " times. DO NOT ENTER.", alert.freq_once_per_bar)
                else
                    new_st := -2
                    if show_signals
                        array.push(sig_pool, label.new(bar_index, spx_p,
                             "ENTRY PUTS " + str.tostring(spx_p, "#") + " | NDX " + str.tostring(ndx_p, "#"),
                             color=color.rgb(220, 0, 0), style=label.style_label_down, textcolor=color.white, size=size.small))
                    if alert_on
                        alert("PCM ENTRY PUTS - SPX " + str.tostring(spx_p, "#") + " | NDX " + str.tostring(ndx_p, "#") + " | Target: next Precision level below", alert.freq_once_per_bar)
            else if spx_above or ndx_lost_dn
                new_st := 0
                array.set(fail_arr, i, fc + 1)
                if show_signals
                    array.push(sig_pool, label.new(bar_index, spx_p, "FAIL " + str.tostring(spx_p, "#"),
                         color=color.rgb(100, 100, 100), style=label.style_label_up, textcolor=color.white, size=size.tiny))

        else if st == 2
            if spx_below
                new_st := 0
        else if st == -2
            if spx_above
                new_st := 0

        array.set(st_arr, i, new_st)

for i = 0 to MAX - 1
    process_level(i)

// ══════════════════════════════════════════════════════════════
// LEVEL LINES, ZONES, AND LABELS
// ══════════════════════════════════════════════════════════════
var line[]  lvl_lines = array.new_line()
var box[]   lvl_boxes = array.new_box()
var label[] lvl_lbls  = array.new_label()

if barstate.islast
    if array.size(lvl_lines) > 0
        for j = 0 to array.size(lvl_lines) - 1
            line.delete(array.get(lvl_lines, j))
    array.clear(lvl_lines)
    if array.size(lvl_boxes) > 0
        for j = 0 to array.size(lvl_boxes) - 1
            box.delete(array.get(lvl_boxes, j))
    array.clear(lvl_boxes)
    if array.size(lvl_lbls) > 0
        for j = 0 to array.size(lvl_lbls) - 1
            label.delete(array.get(lvl_lbls, j))
    array.clear(lvl_lbls)

    for i = 0 to MAX - 1
        spx_p = get_lvl(spx_arr, i)
        ndx_p = get_lvl(ndx_arr, i)
        if spx_p == 0.0
            continue

        col  = lvl_color(i)
        typ  = lvl_type(i)
        st   = array.get(st_arr,   i)
        fc   = array.get(fail_arr, i)

        float thick = 1.0

        string badge = ""
        color  badge_col = col
        if fc >= 2 and math.abs(st) < 2
            badge     := " AVOID"
            badge_col := color.orange
        else if st == 2
            badge     := " CALLS ENTRY"
            badge_col := color.green
        else if st == -2
            badge     := " PUTS ENTRY"
            badge_col := color.green
        else if st == 1
            badge     := " C1 up"
            badge_col := color.lime
        else if st == -1
            badge     := " C1 dn"
            badge_col := color.orange

        if show_lines
            ln = line.new(bar_index - 500, spx_p, bar_index + 60, spx_p,
                 color=col, width=1, extend=extend.none)
            array.push(lvl_lines, ln)

            bx = box.new(bar_index - 500, spx_p + thick,
                         bar_index + 60,  spx_p - thick,
                         bgcolor=color.new(col, 88),
                         border_color=color.new(col, 65))
            array.push(lvl_boxes, bx)

        if show_labels
            ndx_tag  = ndx_p > 0.0 ? " | NDX " + str.tostring(ndx_p, "#") : ""
            dist_pts = close - spx_p
            dist_tag = "  (" + (dist_pts >= 0 ? "+" : "") + str.tostring(dist_pts, "#.##") + ")"

            lbl = label.new(bar_index + 18, spx_p,
                 typ + "  " + str.tostring(spx_p, "#.##") + ndx_tag + dist_tag + badge,
                 color=badge_col, style=label.style_label_left,
                 textcolor=color.white, size=size.small)
            array.push(lvl_lbls, lbl)

// ══════════════════════════════════════════════════════════════
// STATUS TABLE
// ══════════════════════════════════════════════════════════════
var table tbl = na

if barstate.islast and show_table
    if not na(tbl)
        table.delete(tbl)

    tbl_pos = switch tbl_pos_str
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        => position.bottom_left

    active_n = 0
    for i = 0 to MAX - 1
        if get_lvl(spx_arr, i) != 0.0
            active_n += 1

    if active_n > 0
        tbl := table.new(tbl_pos, 7, active_n + 1,
             border_width=1, border_color=color.rgb(55, 55, 55),
             bgcolor=color.rgb(8, 8, 15, 5))

        string[] hdrs = array.from("SPX Level", "NDX Pair", "Type", "Dist pts", "NDX OK", "Signal", "Fails")
        for c = 0 to 6
            table.cell(tbl, c, 0, array.get(hdrs, c),
                 text_color=color.white, bgcolor=color.rgb(25, 25, 55), text_size=size.small)

        row = 1
        for i = 0 to MAX - 1
            spx_p = get_lvl(spx_arr, i)
            ndx_p = get_lvl(ndx_arr, i)
            if spx_p == 0.0
                continue

            col = lvl_color(i)
            typ = lvl_type(i)
            st  = array.get(st_arr,   i)
            fc  = array.get(fail_arr, i)

            float dist      = close - spx_p
            string dist_str = (dist >= 0 ? "+" : "") + str.tostring(dist, "#.##")
            color  dist_col = dist >= 0 ? color.rgb(100, 220, 100) : color.rgb(220, 100, 100)

            string ndx_cell     = ndx_p > 0.0 ? (ndx_close > ndx_p ? "YES " + str.tostring(ndx_p, "#") : "NO "  + str.tostring(ndx_p, "#")) : "-"
            color  ndx_cell_col = ndx_p > 0.0 ? (ndx_close > ndx_p ? color.green : color.red) : color.gray

            string sig_str = ""
            color  sig_col = color.gray
            if fc >= 2 and math.abs(st) < 2
                sig_str := "AVOID"
                sig_col := color.orange
            else if st == 2
                sig_str := "CALLS"
                sig_col := color.lime
            else if st == -2
                sig_str := "PUTS"
                sig_col := color.lime
            else if st == 1
                sig_str := "C1 Calls"
                sig_col := color.yellow
            else if st == -1
                sig_str := "C1 Puts"
                sig_col := color.yellow
            else
                sig_str := "Watch"
                sig_col := color.rgb(150, 150, 150)

            bool   in_range = math.abs(dist) <= 10
            row_bg = in_range ? color.rgb(120, 90, 0, 25) : (row % 2 == 0 ? color.rgb(15, 15, 28) : color.rgb(8, 8, 18))
            string txt_sz   = in_range ? size.normal : size.small
            string lvl_lbl  = in_range ? "► " + str.tostring(spx_p, "#.##") : str.tostring(spx_p, "#.##")
            color  lvl_col  = in_range ? color.rgb(255, 220, 60) : col

            table.cell(tbl, 0, row, lvl_lbl,                                              text_color=lvl_col,      bgcolor=row_bg, text_size=txt_sz)
            table.cell(tbl, 1, row, str.tostring(ndx_p > 0.0 ? ndx_p : 0.0, "#"),        text_color=color.rgb(120, 160, 255), bgcolor=row_bg, text_size=txt_sz)
            table.cell(tbl, 2, row, typ,                          text_color=col,          bgcolor=row_bg, text_size=txt_sz)
            table.cell(tbl, 3, row, dist_str,                     text_color=in_range ? color.white : dist_col, bgcolor=row_bg, text_size=txt_sz)
            table.cell(tbl, 4, row, ndx_cell,                     text_color=ndx_cell_col, bgcolor=row_bg, text_size=txt_sz)
            table.cell(tbl, 5, row, sig_str,                      text_color=sig_col,      bgcolor=row_bg, text_size=txt_sz)
            table.cell(tbl, 6, row, str.tostring(fc),
                 text_color=fc >= 2 ? color.orange : color.white,
                 bgcolor=row_bg, text_size=txt_sz)

            row += 1

// ══════════════════════════════════════════════════════════════
// SMA PLOTS
// ══════════════════════════════════════════════════════════════
plot(use_sma ? spx_sma_f : na, "SPX Fast SMA", color=color.new(color.yellow, 55), linewidth=1)
plot(use_sma ? spx_sma_s : na, "SPX Slow SMA", color=color.new(color.orange, 55), linewidth=1)
````
