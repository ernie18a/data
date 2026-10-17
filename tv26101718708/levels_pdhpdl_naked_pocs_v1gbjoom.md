# Levels - PDH/PDL, Naked POCs

- url: https://www.tradingview.com/script/V1gbjOom-Levels-PDH-PDL-Naked-POCs/
- type: indicator
- pine_id: PUB;c04dde7076254ac581f01631c45d79c0
- version: 2.0

## Description

Levels

One indicator for the levels traders actually watch: previous day/week/month highs and lows, Daily/Weekly/Monthly flip levels, and naked POCs. It loads clean and is built for confluence.

WHAT IT SHOWS
- Previous Period Levels: PDH / PDL, PWH / PWL, PMH / PML, with optional mids.
- Daily / Weekly / Monthly Levels: the open of the candle that follows a color flip (bearish to bullish or the reverse). They work on any chart timeframe.
- Naked POCs: unmitigated daily, weekly and monthly points of control, newest first.
- Monday Range (optional, off by default): high, low and mid from the Asia open. Turn it on with one click.
- Optional Pending levels and Developing POC for the period still forming.

A CLEAN CHART FROM THE FIRST LOAD
- The previous highs and lows are the map. They draw as full lines with price-scale tags.
- Daily / Weekly / Monthly levels and Naked POCs sit in a tidy column to the right, tucked behind the price scale. Each label shows its price (for example "Weekly (86486.7)"), and mitigated levels drop off automatically.
- Everything is quick to read, with no clutter.

PLACEMENT, PER GROUP
Every group has its own Placement setting:
- Standard: lines run from where they began, with labels at the right end.
- Right: lines are hidden and labels sit in a column at the current bar.
- Right Far: the same column, pushed out so the labels tuck behind the price scale. Adjust the offset to taste.
Mix and match. For example, keep the highs and lows as lines and put the rest in the column, or put everything in Right Far for a minimal look.

PRICE DISPLAY, PER GROUP
- Labels on Price Scale: switch each group's price-scale tags on or off.
- Show Price in Label: print the price inside each label.
Use either one, both, or neither.

FULLY CUSTOMIZABLE LABELS
Every label's text can be changed. Look for the text box next to each color swatch in the settings (for example, rename PDH to YDAY-H, or dPOC to Daily POC). Colors, line styles and which levels appear are all yours to set.

OVERLAP HANDLING
When levels sit at nearly the same price their labels combine into one (for example PDH/PWH), so the chart stays readable. The threshold is adjustable, and lines are never affected.

MITIGATION
Choose what happens when price trades through a level: keep extending, freeze the line where it was hit, or remove it. Daily / Weekly / Monthly levels and POCs are removed by default to keep the chart clean. You can keep them if you prefer. Right placements always show only live levels.

USING IT FOR CONFLUENCE
Daily, Weekly and Monthly levels, previous period highs/lows and naked POCs all act as reference points. When two or more cluster at one price, that area is worth attention. Combined labels make those clusters easy to spot.

NOTES ON ACCURACY (PLEASE READ)
- Naked POCs are most exact on 1D and higher charts, where the script uses real volume-at-price footprint data. On lower timeframes they are estimated from lower-timeframe volume and can differ slightly. For the exact read, switch to 1D.
- Footprint data may depend on your TradingView plan. If a plan does not support it on a given chart, the script falls back to the estimate.
- POC accuracy is a work in progress. It has been tuned against other volume profile tools and will keep improving with updates.
- Levels are drawn from available history and can differ slightly between data feeds.

This is a tool for chart reference, not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mikey369

//@version=6
indicator('Levels - PDH/PDL, Naked POCs', shorttitle = 'Levels', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────────── Settings ─────────────────────────────
lineWidth = 1

// ───────────────────────────── Quick Setup ─────────────────────────────
g_qs = 'Quick Setup'
layout_mode = input.string('Custom', 'Label Layout', options = ['Custom', 'All Standard', 'All Right', 'All Right Far'], group = g_qs, tooltip = 'Sets where every group\'s labels go in one step. Standard: lines run from where they began, with labels at the right end. Right: lines are hidden and labels sit in a column at the current bar. Right Far: the same column, shifted by Right Far Offset so the labels tuck under the price scale. Right modes show only unmitigated levels. Custom uses the Placement setting in each group below.')
scale_mode = input.string('Custom', 'Price Scale Tags', options = ['Custom', 'All On', 'All Off'], group = g_qs, tooltip = 'Shows or hides every level\'s price tag on the price scale in one step. Custom uses the setting in each group below.')
price_mode = input.string('Custom', 'Price in Labels', options = ['Custom', 'All On', 'All Off'], group = g_qs, tooltip = 'Adds or removes the price in every level\'s label in one step. Custom uses the setting in each group below.')
show_pct = input.bool(false, 'Show % From Price', group = g_qs, tooltip = 'Shows how far price currently is from each level, as a percentage: (level - price) / price. A level 1% below price reads -1%.')
show_labels = input.bool(true, 'Show Line Labels', group = g_qs)
label_size_str = input.string('Small', 'Label Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = g_qs)
far_offset = input.int(30, 'Right Far Offset (bars)', minval = 0, group = g_qs, tooltip = 'How far Right Far pushes the label column to the right of the current bar.')
gap_bars = input.int(0, 'Standard / Right Offset (bars)', minval = 0, group = g_qs, tooltip = 'Moves the label column to the right in Standard and Right placement. Standard measures from where each line ends, Right from the current bar. Right Far uses Right Far Offset instead.')
line_offset = input.int(10, 'Line Offset (bars)', minval = 0, group = g_qs, tooltip = 'Length of the line stub drawn between a level and its label, in the level\'s own line style. Frozen levels in Standard mode have no stub, so their label sits at the bar where they were mitigated.')

// ───────────────────────────── Style ─────────────────────────────
g_disp = 'Style'
mono = input.bool(false, 'Monochrome', inline = 'mono', group = g_disp, tooltip = 'Overrides every level color with the single color on the right.')
mono_col = input.color(#b8b8b8, '', inline = 'mono', group = g_disp)
lbl_transparency = input.int(100, 'Label Background Transparency', minval = 0, maxval = 100, group = g_disp, tooltip = 'Higher = more see-through. Set to 100% to hide the background completely (text only).')
mit_dim = input.int(0, 'Mitigated Level Transparency', minval = 0, maxval = 90, group = g_disp, tooltip = 'Dims mitigated (frozen) Daily, Weekly, Monthly and naked POC levels. 0 leaves them at full strength.')
combine_labels = input.bool(true, 'Combine Overlapping Labels', group = g_disp, tooltip = 'When levels land at/near the same price and their labels sit on the same bar, they share one label (e.g. PDH/PWH) instead of stacking. Lines are never affected. Only levels that are switched on are combined.')
overlap_pct = input.float(0.1, 'Overlap Threshold (%)', minval = 0.0, step = 0.05, group = g_disp, tooltip = 'Two levels are treated as overlapping when they sit within this percentage of each other.')

// ───────────────────────────── Monday Range ─────────────────────────────
g_mon = 'Monday Range'
show_mon = input.bool(false, 'Show Monday Range', group = g_mon, tooltip = 'Master switch. The range starts at the Asia open (Sunday 8:00 PM New York) and builds through the end of that session. Its lines run from the Asia open to Friday 5:00 PM New York, then reset at the next Sunday Asia open. Weekends are skipped.')
show_monh = input.bool(true, 'Monday High', inline = 'monh', group = g_mon)
col_monh = input.color(#5b9cf6, '', inline = 'monh', group = g_mon)
lbl_monh = input.string('MDAY-H', '', inline = 'monh', group = g_mon)
show_monl = input.bool(true, 'Monday Low', inline = 'monl', group = g_mon)
col_monl = input.color(#5b9cf6, '', inline = 'monl', group = g_mon)
lbl_monl = input.string('MDAY-L', '', inline = 'monl', group = g_mon)
show_monm = input.bool(false, 'Monday Mid', inline = 'monm', group = g_mon)
col_monm = input.color(#5b9cf6, '', inline = 'monm', group = g_mon)
lbl_monm = input.string('MDAY-M', '', inline = 'monm', group = g_mon)
place_mon_in = input.string('Standard', 'Placement', options = ['Standard', 'Right', 'Right Far'], group = g_mon, tooltip = 'Used when Label Layout in Quick Setup is Custom. Standard: lines run from where they began, with labels at the right end. Right: lines are hidden and labels sit in a column at the current bar. Right Far: the same column, shifted by Right Far Offset so the labels tuck under the price scale. Right modes show only unmitigated levels.')
ps_mon_in = input.bool(true, 'Labels on Price Scale', group = g_mon, tooltip = 'Used when Price Scale Tags in Quick Setup is Custom. Shows each level\'s price tag on the price scale. Matches the "Labels on price scale" checkbox on the Style tab.')
pr_mon_in = input.bool(false, 'Show Price in Label', group = g_mon, tooltip = 'Used when Price in Labels in Quick Setup is Custom.')
style_mon = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_mon)
show_mon_hist = input.bool(false, 'Show Historical Ranges', group = g_mon, tooltip = 'Keeps the high and low (and mid, if switched on above) of every past Monday range, drawn from that week\'s Asia open to Friday 5:00 PM New York. Past ranges have no labels or price-scale tags and are drawn in every placement mode. Needs Show Monday Range on.')
max_mon_hist = input.int(20, 'Max Historical Ranges (weeks)', minval = 1, maxval = 100, group = g_mon, tooltip = 'How many past weeks to keep. Each week uses up to three lines, and the chart allows 500 lines in total.')

// ───────────────────────────── Previous Period Levels ─────────────────────────────
g_hl = 'Previous Period Levels'
show_hl = input.bool(true, 'Show Previous Period Levels', group = g_hl, tooltip = 'Master switch for every previous day, week and month level below. Turning it off hides their lines, labels and price-scale tags. The individual settings are kept.')
show_pdh = input.bool(true, 'Previous Day High', inline = 'pdh', group = g_hl)
col_pdh = input.color(#808080, '', inline = 'pdh', group = g_hl)
lbl_pdh = input.string('PDH', '', inline = 'pdh', group = g_hl)
show_pdl = input.bool(true, 'Previous Day Low', inline = 'pdl', group = g_hl)
col_pdl = input.color(#808080, '', inline = 'pdl', group = g_hl)
lbl_pdl = input.string('PDL', '', inline = 'pdl', group = g_hl)
show_pdm = input.bool(false, 'Previous Day Mid', inline = 'pdm', group = g_hl)
col_pdm = input.color(#808080, '', inline = 'pdm', group = g_hl)
lbl_pdm = input.string('PDM', '', inline = 'pdm', group = g_hl)
style_pd = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_hl)

show_wh = input.bool(true, 'Previous Week High', inline = 'wh', group = g_hl)
col_wh = input.color(#808080, '', inline = 'wh', group = g_hl)
lbl_wh = input.string('PWH', '', inline = 'wh', group = g_hl)
show_wl = input.bool(true, 'Previous Week Low', inline = 'wl', group = g_hl)
col_wl = input.color(#808080, '', inline = 'wl', group = g_hl)
lbl_wl = input.string('PWL', '', inline = 'wl', group = g_hl)
show_wm = input.bool(false, 'Previous Week Mid', inline = 'wm', group = g_hl)
col_wm = input.color(#808080, '', inline = 'wm', group = g_hl)
lbl_wm = input.string('PWM', '', inline = 'wm', group = g_hl)
style_pw = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_hl)

show_mh = input.bool(true, 'Previous Month High', inline = 'mh', group = g_hl)
col_mh = input.color(#808080, '', inline = 'mh', group = g_hl)
lbl_mh = input.string('PMH', '', inline = 'mh', group = g_hl)
show_ml = input.bool(true, 'Previous Month Low', inline = 'ml', group = g_hl)
col_ml = input.color(#808080, '', inline = 'ml', group = g_hl)
lbl_ml = input.string('PML', '', inline = 'ml', group = g_hl)
show_mm = input.bool(false, 'Previous Month Mid', inline = 'mm', group = g_hl)
col_mm = input.color(#808080, '', inline = 'mm', group = g_hl)
lbl_mm = input.string('PMM', '', inline = 'mm', group = g_hl)
style_pm = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_hl)

place_hl_in = input.string('Standard', 'Placement', options = ['Standard', 'Right', 'Right Far'], group = g_hl, tooltip = 'Used when Label Layout in Quick Setup is Custom. Standard: lines run from where they began, with labels at the right end. Right: lines are hidden and labels sit in a column at the current bar. Right Far: the same column, shifted by Right Far Offset so the labels tuck under the price scale. Right modes show only unmitigated levels.')
ps_hl_in = input.bool(true, 'Labels on Price Scale', group = g_hl, tooltip = 'Used when Price Scale Tags in Quick Setup is Custom. Shows each level\'s price tag on the price scale. Matches the "Labels on price scale" checkbox on the Style tab.')
pr_hl_in = input.bool(false, 'Show Price in Label', group = g_hl, tooltip = 'Used when Price in Labels in Quick Setup is Custom.')
mitigationMode = input.string('Freeze Line', 'On Mitigation', options = ['Keep Extending', 'Freeze Line', 'Remove Level'], group = g_hl, tooltip = 'Keep Extending: lines extend to the current bar indefinitely. Freeze Line: once price trades through a level, its line and label stop extending and stay fixed where mitigation happened. Remove Level: the line, label, and price-scale tag disappear once mitigated. Mid levels are mitigated when price trades through the midpoint. Right and Right Far placement always hide mitigated levels.')
hide_mit_scale = input.bool(true, 'Remove Price Tag When Mitigated', group = g_hl, tooltip = 'Removes a mitigated level\'s price from the price scale. Applies to Keep Extending and Freeze Line. Remove Level always removes it.')

// ───────────────────────────── Daily / Weekly / Monthly Levels ─────────────────────────────
g_dw = 'Daily / Weekly / Monthly Levels'
show_dlv = input.bool(true, 'Daily Levels', inline = 'dlv', group = g_dw)
col_dlv = input.color(#b2b5be, '', inline = 'dlv', group = g_dw)
lbl_dlv = input.string('Daily', '', inline = 'dlv', group = g_dw)
show_wlv = input.bool(true, 'Weekly Levels', inline = 'wlv', group = g_dw)
col_wlv = input.color(#ffffff, '', inline = 'wlv', group = g_dw)
lbl_wlv = input.string('Weekly', '', inline = 'wlv', group = g_dw)
show_mlv = input.bool(true, 'Monthly Levels', inline = 'mlv', group = g_dw)
col_mlv = input.color(#ce93d8, '', inline = 'mlv', group = g_dw)
lbl_mlv = input.string('Monthly', '', inline = 'mlv', group = g_dw)
place_dw_in = input.string('Right Far', 'Placement', options = ['Standard', 'Right', 'Right Far'], group = g_dw, tooltip = 'Used when Label Layout in Quick Setup is Custom. Standard: lines run from where they began, with labels at the right end. Right: lines are hidden and labels sit in a column at the current bar. Right Far: the same column, shifted by Right Far Offset so the labels tuck under the price scale. Right modes show only unmitigated levels.')
ps_dw_in = input.bool(false, 'Labels on Price Scale', group = g_dw, tooltip = 'Used when Price Scale Tags in Quick Setup is Custom. Shows each level\'s price tag on the price scale. Matches the "Labels on price scale" checkbox on the Style tab.')
pr_dw_in = input.bool(true, 'Show Price in Label', group = g_dw, tooltip = 'Used when Price in Labels in Quick Setup is Custom.')
max_dlv = input.int(3, 'Max Daily Levels', minval = 1, maxval = 3, group = g_dw, tooltip = 'How many unmitigated daily levels to show, newest first.')
max_wlv = input.int(3, 'Max Weekly Levels', minval = 1, maxval = 3, group = g_dw, tooltip = 'How many unmitigated weekly levels to show, newest first.')
max_mlv = input.int(3, 'Max Monthly Levels', minval = 1, maxval = 3, group = g_dw, tooltip = 'How many unmitigated monthly levels to show, newest first.')
show_pending = input.bool(false, 'Show Pending Levels', group = g_dw, tooltip = 'Also labels the level of the candle that is still forming when it has already flipped color against the previous candle. It is marked "(Pending)" and either becomes a normal level when the candle closes or disappears if the candle flips back. Pending levels have a label and line but no price-scale tag.')
dw_freeze = input.string('Remove Level', 'On Mitigation', options = ['Freeze Line', 'Remove Level'], group = g_dw, tooltip = 'Freeze Line: a level price has traded through stays on the chart, ending at the bar where it was mitigated. Remove Level: it disappears. Right and Right Far placement always hide mitigated levels.')
dw_frozen_keep = input.int(1, 'Frozen Levels to Keep', minval = 1, maxval = 2, group = g_dw, tooltip = 'How many of the most recently mitigated levels to keep per type.')
style_dw = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_dw)

// ───────────────────────────── Naked POCs ─────────────────────────────
g_poc = 'Naked POCs'
show_dpoc = input.bool(true, 'Daily Naked POC', inline = 'dpoc', group = g_poc)
col_dpoc = input.color(#fbc02d, '', inline = 'dpoc', group = g_poc)
lbl_dpoc = input.string('dPOC', '', inline = 'dpoc', group = g_poc)
show_wpoc = input.bool(true, 'Weekly Naked POC', inline = 'wpoc', group = g_poc)
col_wpoc = input.color(#f57c00, '', inline = 'wpoc', group = g_poc)
lbl_wpoc = input.string('wPOC', '', inline = 'wpoc', group = g_poc)
show_mpoc = input.bool(true, 'Monthly Naked POC', inline = 'mpoc', group = g_poc)
col_mpoc = input.color(#e64a19, '', inline = 'mpoc', group = g_poc)
lbl_mpoc = input.string('mPOC', '', inline = 'mpoc', group = g_poc)
place_poc_in = input.string('Right Far', 'Placement', options = ['Standard', 'Right', 'Right Far'], group = g_poc, tooltip = 'Used when Label Layout in Quick Setup is Custom. Standard: lines run from where they began, with labels at the right end. Right: lines are hidden and labels sit in a column at the current bar. Right Far: the same column, shifted by Right Far Offset so the labels tuck under the price scale. Right modes show only unmitigated levels.')
ps_poc_in = input.bool(false, 'Labels on Price Scale', group = g_poc, tooltip = 'Used when Price Scale Tags in Quick Setup is Custom. Shows each level\'s price tag on the price scale. Matches the "Labels on price scale" checkbox on the Style tab.')
pr_poc_in = input.bool(true, 'Show Price in Label', group = g_poc, tooltip = 'Used when Price in Labels in Quick Setup is Custom.')
max_dpoc = input.int(3, 'Max Daily POCs', minval = 1, maxval = 3, group = g_poc, tooltip = 'How many unmitigated daily POCs to show, newest first.')
max_wpoc = input.int(3, 'Max Weekly POCs', minval = 1, maxval = 3, group = g_poc, tooltip = 'How many unmitigated weekly POCs to show, newest first.')
max_mpoc = input.int(3, 'Max Monthly POCs', minval = 1, maxval = 3, group = g_poc, tooltip = 'How many unmitigated monthly POCs to show, newest first.')
show_devpoc = input.bool(false, 'Show Developing POC', group = g_poc, tooltip = 'Also marks the POC of the day, week and month that are still in progress, labeled "(Dev)". It moves as volume builds. Uses the dPOC, wPOC and mPOC switches above. Labels and lines only, no price-scale tag.')
poc_freeze = input.string('Remove Level', 'On Mitigation', options = ['Freeze Line', 'Remove Level'], group = g_poc, tooltip = 'Freeze Line: a POC price has traded through stays on the chart, ending at the bar where it was mitigated. Remove Level: it disappears. Right and Right Far placement always hide mitigated levels.')
poc_frozen_keep = input.int(1, 'Frozen POCs to Keep', minval = 1, maxval = 2, group = g_poc, tooltip = 'How many of the most recently mitigated POCs to keep per type.')
poc_lookback = input.int(90, 'Lookback (days)', minval = 10, maxval = 365, group = g_poc, tooltip = 'How far back sessions are profiled. Older POCs are ignored. Lower values calculate faster.')
poc_use_fp = input.bool(true, 'Use Footprint Data (1D and Higher)', group = g_poc, tooltip = 'Uses real volume-at-price footprint data when the chart is on 1D or higher. Charts below 1D, or sessions the footprint cannot supply, use the lower-timeframe estimate below instead. POC accuracy is a work in progress and will keep improving. It is most exact on 1D and higher.')
poc_tpr = input.int(100, 'Footprint Ticks Per Row', minval = 1, group = g_poc, tooltip = 'Price resolution of the volume profile in ticks. Each POC is the center of the highest-volume row, so smaller values place it more precisely. Also sets the row size of the lower-timeframe estimate.')
poc_res_fine = input.string('1', 'Estimate Resolution: Fine (minutes)', options = ['1', '3', '5', '15'], group = g_poc, tooltip = 'Lower-timeframe bars used for the estimate while that much history is available.')
poc_res_coarse = input.string('5', 'Estimate Resolution: Coarse (minutes)', options = ['5', '15', '30', '60'], group = g_poc, tooltip = 'Used for older history when the fine resolution has no data.')
style_poc = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = g_poc)
poc_debug = input.bool(false, 'Show Debug Table', group = g_poc, tooltip = 'Shows whether footprint data is active and lists the newest unmitigated daily and weekly POCs with their session dates.')

// ───────────────────────────── Helpers ─────────────────────────────
f_c(c) =>
    mono ? mono_col : c

layout_p = layout_mode == 'All Standard' ? 'Standard' : layout_mode == 'All Right' ? 'Right' : layout_mode == 'All Right Far' ? 'Right Far' : ''
place_mon = layout_p == '' ? place_mon_in : layout_p
place_hl = layout_p == '' ? place_hl_in : layout_p
place_dw = layout_p == '' ? place_dw_in : layout_p
place_poc = layout_p == '' ? place_poc_in : layout_p
ps_mon = scale_mode == 'Custom' ? ps_mon_in : scale_mode == 'All On'
ps_hl = scale_mode == 'Custom' ? ps_hl_in : scale_mode == 'All On'
ps_dw = scale_mode == 'Custom' ? ps_dw_in : scale_mode == 'All On'
ps_poc = scale_mode == 'Custom' ? ps_poc_in : scale_mode == 'All On'
pr_mon = price_mode == 'Custom' ? pr_mon_in : price_mode == 'All On'
pr_hl = price_mode == 'Custom' ? pr_hl_in : price_mode == 'All On'
pr_dw = price_mode == 'Custom' ? pr_dw_in : price_mode == 'All On'
pr_poc = price_mode == 'Custom' ? pr_poc_in : price_mode == 'All On'

rMon = place_mon != 'Standard'
rHl = place_hl != 'Standard'
rDw = place_dw != 'Standard'
rPoc = place_poc != 'Standard'

sh_pdh = show_hl and show_pdh
sh_pdl = show_hl and show_pdl
sh_pdm = show_hl and show_pdm
sh_wh = show_hl and show_wh
sh_wl = show_hl and show_wl
sh_wm = show_hl and show_wm
sh_mh = show_hl and show_mh
sh_ml = show_hl and show_ml
sh_mm = show_hl and show_mm

f_anchor(own, p) =>
    p == 'Standard' ? own + gap_bars : p == 'Right' ? bar_index + gap_bars : bar_index + far_offset

f_labelSize(s) =>
    s == 'Tiny' ? size.tiny : s == 'Small' ? size.small : s == 'Normal' ? size.normal : size.large

f_lineStyle(s) =>
    s == 'Dashed' ? line.style_dashed : s == 'Dotted' ? line.style_dotted : line.style_solid

f_pct(val) =>
    (val - close) / close * 100

f_buildText(baseTxt, val, pr) =>
    txt = baseTxt
    if pr
        txt := txt + ' (' + str.tostring(val, format.mintick) + ')'
    if show_pct
        txt := txt + ' (' + str.tostring(f_pct(val), '#.##') + '%)'
    txt

f_near(a, b) =>
    not na(a) and not na(b) and b != 0 and math.abs(a - b) / math.abs(b) * 100 < overlap_pct

f_atF(a, i) =>
    float r = na
    if i < array.size(a)
        r := array.get(a, i)
    r

f_atI(a, i) =>
    int r = na
    if i < array.size(a)
        r := array.get(a, i)
    r

f_sz(a) =>
    na(a) ? 0 : array.size(a)

// Every chart bar's open time, indexed by bar_index, so a timestamp can be mapped back to its bar.
var int[] barTimes = array.new_int()
array.push(barTimes, time)

f_barAt(t) =>
    int r = bar_index
    if not na(t)
        r := math.max(0, array.binary_search_leftmost(barTimes, t))
    r

var label[] allLabels = array.new<label>(60, na)
var line[] allExtLines = array.new<line>(60, na)

// Draws one label at lblX. When off > 0 a line stub in the level's own line style runs from extStartX to the label.
f_setLabel(idx, show, val, txt, col, stl, off, extStartX, lblX, lblSz) =>
    ex = array.get(allLabels, idx)
    exLine = array.get(allExtLines, idx)
    if show and not na(val)
        bgCol = color.new(col, lbl_transparency)
        if na(ex)
            array.set(allLabels, idx, label.new(lblX, val, txt, xloc.bar_index, yloc.price, color = bgCol, style = label.style_label_left, textcolor = col, size = lblSz))
        else
            label.set_xy(ex, lblX, val)
            label.set_text(ex, txt)
            label.set_color(ex, bgCol)
            label.set_textcolor(ex, col)
            label.set_size(ex, lblSz)
        if off > 0
            if na(exLine)
                array.set(allExtLines, idx, line.new(extStartX, val, lblX, val, xloc.bar_index, color = col, style = f_lineStyle(stl), width = lineWidth))
            else
                line.set_xy1(exLine, extStartX, val)
                line.set_xy2(exLine, lblX, val)
                line.set_color(exLine, col)
                line.set_style(exLine, f_lineStyle(stl))
        else if not na(exLine)
            line.delete(exLine)
            array.set(allExtLines, idx, na)
    else
        if not na(ex)
            label.delete(ex)
            array.set(allLabels, idx, na)
        if not na(exLine)
            line.delete(exLine)
            array.set(allExtLines, idx, na)

// ───────────────────────────── Session Anchor (Asia open) ─────────────────────────────
// Sessions start at 8:00 PM New York time. The session beginning Sunday 8:00 PM is the Monday session.
msPerDay = 86400000
nyZone = 'America/New_York'

f_sessionStart(t) =>
    y = year(t, nyZone)
    m = month(t, nyZone)
    d = dayofmonth(t, nyZone)
    anchor = timestamp(nyZone, y, m, d, 20, 0, 0)
    t >= anchor ? anchor : anchor - msPerDay

// ───────────────────────────── Previous Period High/Low Tracking ─────────────────────────────
newDay = timeframe.change('D')
newWeek = timeframe.change('W')
newMonth = timeframe.change('M')

var float dayHigh = na
var float dayLow = na
var int dayHighBar = na
var int dayLowBar = na
var float pDayHigh = na
var float pDayLow = na
var int pDayHighBar = na
var int pDayLowBar = na

if newDay
    pDayHigh := dayHigh
    pDayLow := dayLow
    pDayHighBar := dayHighBar
    pDayLowBar := dayLowBar
    dayHigh := high
    dayLow := low
    dayHighBar := bar_index
    dayLowBar := bar_index
else
    if high > dayHigh
        dayHigh := high
        dayHighBar := bar_index
    if low < dayLow
        dayLow := low
        dayLowBar := bar_index

var float weekHigh = na
var float weekLow = na
var int weekHighBar = na
var int weekLowBar = na
var float pWeekHigh = na
var float pWeekLow = na
var int pWeekHighBar = na
var int pWeekLowBar = na

if newWeek
    pWeekHigh := weekHigh
    pWeekLow := weekLow
    pWeekHighBar := weekHighBar
    pWeekLowBar := weekLowBar
    weekHigh := high
    weekLow := low
    weekHighBar := bar_index
    weekLowBar := bar_index
else
    if high > weekHigh
        weekHigh := high
        weekHighBar := bar_index
    if low < weekLow
        weekLow := low
        weekLowBar := bar_index

var float monthHigh = na
var float monthLow = na
var int monthHighBar = na
var int monthLowBar = na
var float pMonthHigh = na
var float pMonthLow = na
var int pMonthHighBar = na
var int pMonthLowBar = na

if newMonth
    pMonthHigh := monthHigh
    pMonthLow := monthLow
    pMonthHighBar := monthHighBar
    pMonthLowBar := monthLowBar
    monthHigh := high
    monthLow := low
    monthHighBar := bar_index
    monthLowBar := bar_index
else
    if high > monthHigh
        monthHigh := high
        monthHighBar := bar_index
    if low < monthLow
        monthLow := low
        monthLowBar := bar_index

pDayMid = (pDayHigh + pDayLow) / 2
pWeekMid = (pWeekHigh + pWeekLow) / 2
pMonthMid = (pMonthHigh + pMonthLow) / 2
pDayMidBar = math.max(pDayHighBar, pDayLowBar)
pWeekMidBar = math.max(pWeekHighBar, pWeekLowBar)
pMonthMidBar = math.max(pMonthHighBar, pMonthLowBar)

// ───────────────────────────── Monday Range Tracking ─────────────────────────────
sess = f_sessionStart(time)
isMonSess = dayofweek(sess, nyZone) == dayofweek.sunday
newMonRange = isMonSess and (na(sess[1]) or sess != sess[1])

var float monHigh = na
var float monLow = na
var int monStartBar = na
var line[] monHist = array.new<line>()
var int monCut = na
var int monEndBar = na

if newMonRange
    if show_mon and show_mon_hist and not na(monStartBar) and not na(monHigh)
        histEnd = math.max(monStartBar, monEndBar)
        if show_monh
            array.push(monHist, line.new(monStartBar, monHigh, histEnd, monHigh, xloc.bar_index, color = f_c(col_monh), style = f_lineStyle(style_mon), width = lineWidth))
        if show_monl
            array.push(monHist, line.new(monStartBar, monLow, histEnd, monLow, xloc.bar_index, color = f_c(col_monl), style = f_lineStyle(style_mon), width = lineWidth))
        if show_monm
            array.push(monHist, line.new(monStartBar, (monHigh + monLow) / 2, histEnd, (monHigh + monLow) / 2, xloc.bar_index, color = f_c(col_monm), style = f_lineStyle(style_mon), width = lineWidth))
        perWk = (show_monh ? 1 : 0) + (show_monl ? 1 : 0) + (show_monm ? 1 : 0)
        while array.size(monHist) > max_mon_hist * perWk
            line.delete(array.shift(monHist))
    monHigh := high
    monLow := low
    monStartBar := bar_index
    monCut := timestamp(nyZone, year(sess, nyZone), month(sess, nyZone), dayofmonth(sess, nyZone) + 5, 17, 0, 0)
else if isMonSess
    monHigh := math.max(monHigh, high)
    monLow := math.min(monLow, low)

if not na(monCut) and time < monCut
    monEndBar := bar_index

monMid = (monHigh + monLow) / 2

// ───────────────────────────── Previous Period Lines + Mitigation ─────────────────────────────
// Slots: 0 PDH, 1 PDL, 2 PDM, 3 PWH, 4 PWL, 5 PWM, 6 PMH, 7 PML, 8 PMM
var line[] hlLines = array.new<line>(9, na)
var bool[] hlMit = array.new<bool>(9, false)
var int[] hlMitBar = array.new<int>(9, na)

// kind: 0 = high, 1 = low, 2 = mid
f_hlUpdate(idx, isNew, kind, lvl, lvlBar, showIt, hideLine, col, styleStr) =>
    ln = array.get(hlLines, idx)
    if isNew
        if not na(ln)
            line.delete(ln)
        array.set(hlMit, idx, false)
        array.set(hlMitBar, idx, na)
        newLn = showIt and not hideLine and not na(lvl) ? line.new(lvlBar, lvl, bar_index, lvl, xloc.bar_index, color = f_c(col), style = f_lineStyle(styleStr), width = lineWidth) : na
        array.set(hlLines, idx, newLn)
    else
        mit = array.get(hlMit, idx)
        justHit = false
        if not mit and not na(lvl)
            hit = kind == 0 ? high >= lvl : kind == 1 ? low <= lvl : (low <= lvl and high >= lvl)
            if hit
                array.set(hlMit, idx, true)
                array.set(hlMitBar, idx, bar_index)
                mit := true
                justHit := true
        if not na(ln)
            if mitigationMode == 'Remove Level' and mit
                line.delete(ln)
                array.set(hlLines, idx, na)
            else if mitigationMode == 'Keep Extending' or not mit or justHit
                line.set_xy2(ln, bar_index, lvl)

f_barEff(idx) =>
    mb = array.get(hlMitBar, idx)
    mitigationMode == 'Freeze Line' and array.get(hlMit, idx) and not na(mb) ? mb : bar_index

f_removed(idx) =>
    (mitigationMode == 'Remove Level' or rHl) and array.get(hlMit, idx)

f_frz(idx) =>
    mitigationMode == 'Freeze Line' and not rHl and array.get(hlMit, idx)

f_tagOff(idx) =>
    array.get(hlMit, idx) and (mitigationMode == 'Remove Level' or hide_mit_scale or rHl)

f_hlUpdate(0, newDay, 0, pDayHigh, pDayHighBar, sh_pdh, rHl, col_pdh, style_pd)
f_hlUpdate(1, newDay, 1, pDayLow, pDayLowBar, sh_pdl, rHl, col_pdl, style_pd)
f_hlUpdate(2, newDay, 2, pDayMid, pDayMidBar, sh_pdm, rHl, col_pdm, style_pd)
f_hlUpdate(3, newWeek, 0, pWeekHigh, pWeekHighBar, sh_wh, rHl, col_wh, style_pw)
f_hlUpdate(4, newWeek, 1, pWeekLow, pWeekLowBar, sh_wl, rHl, col_wl, style_pw)
f_hlUpdate(5, newWeek, 2, pWeekMid, pWeekMidBar, sh_wm, rHl, col_wm, style_pw)
f_hlUpdate(6, newMonth, 0, pMonthHigh, pMonthHighBar, sh_mh, rHl, col_mh, style_pm)
f_hlUpdate(7, newMonth, 1, pMonthLow, pMonthLowBar, sh_ml, rHl, col_ml, style_pm)
f_hlUpdate(8, newMonth, 2, pMonthMid, pMonthMidBar, sh_mm, rHl, col_mm, style_pm)

// ───────────────────────────── Monday Range Lines ─────────────────────────────
var line[] monLines = array.new<line>(3, na)

f_monUpdate(idx, isNew, val, showIt, col) =>
    ln = array.get(monLines, idx)
    if isNew
        if not na(ln)
            line.delete(ln)
        newLn = show_mon and showIt and not rMon and not na(val) ? line.new(monStartBar, val, bar_index, val, xloc.bar_index, color = f_c(col), style = f_lineStyle(style_mon), width = lineWidth) : na
        array.set(monLines, idx, newLn)
    else if not na(ln)
        line.set_xy1(ln, monStartBar, val)
        line.set_xy2(ln, monEndBar, val)

f_monUpdate(0, newMonRange, monHigh, show_monh, col_monh)
f_monUpdate(1, newMonRange, monLow, show_monl, col_monl)
f_monUpdate(2, newMonRange, monMid, show_monm, col_monm)

// ───────────────────────────── Daily / Weekly / Monthly Level Engine ─────────────────────────────
// Runs inside the Daily, Weekly and Monthly series, so it works on any chart timeframe. A level is the
// open of the first candle after the candle color flips (bearish to bullish or bullish to bearish). It is created
// once that candle has closed. When a later candle trades back through it, the level moves to a short
// list of mitigated levels together with the time it was hit.
f_flipEngine() =>
    var float[] lv = array.new_float()
    var int[] lt = array.new_int()
    var bool[] lb = array.new_bool()
    var float[] fzv = array.new_float()
    var int[] fzo = array.new_int()
    var int[] fzm = array.new_int()

    bullNow = close >= open
    bullPrev = close[1] >= open[1]
    bullPrev2 = close[2] >= open[2]
    isFlip = bullPrev != bullPrev2

    if not na(close[2]) and isFlip and not array.includes(lt, time[1])
        array.unshift(lv, open[1])
        array.unshift(lt, time[1])
        array.unshift(lb, bullPrev)
        if array.size(lv) > 12
            array.pop(lv)
            array.pop(lt)
            array.pop(lb)

    i = array.size(lv) - 1
    while i >= 0
        lvl = array.get(lv, i)
        hit = array.get(lb, i) ? low <= lvl : high >= lvl
        if hit
            array.unshift(fzv, lvl)
            array.unshift(fzo, array.get(lt, i))
            array.unshift(fzm, time)
            if array.size(fzv) > 6
                array.pop(fzv)
                array.pop(fzo)
                array.pop(fzm)
            array.remove(lv, i)
            array.remove(lt, i)
            array.remove(lb, i)
        i := i - 1

    forming = timenow < time_close
    pend = forming and bullNow != bullPrev
    pv = pend ? open : na
    pt = pend ? time : na

    v0 = f_atF(lv, 0)
    v1 = f_atF(lv, 1)
    v2 = f_atF(lv, 2)
    t0 = f_atI(lt, 0)
    t1 = f_atI(lt, 1)
    t2 = f_atI(lt, 2)
    zv0 = f_atF(fzv, 0)
    zo0 = f_atI(fzo, 0)
    zm0 = f_atI(fzm, 0)
    zv1 = f_atF(fzv, 1)
    zo1 = f_atI(fzo, 1)
    zm1 = f_atI(fzm, 1)

    [v0, t0, v1, t1, v2, t2, pv, pt, zv0, zo0, zm0, zv1, zo1, zm1]

[d0, dt0, d1, dt1, d2, dt2, dpv, dpt, dfv0, dfo0, dfm0, dfv1, dfo1, dfm1] = request.security(syminfo.tickerid, 'D', f_flipEngine())
[w0, wt0, w1, wt1, w2, wt2, wpv, wpt, wfv0, wfo0, wfm0, wfv1, wfo1, wfm1] = request.security(syminfo.tickerid, 'W', f_flipEngine())
[m0, mt0, m1, mt1, m2, mt2, mpv, mpt, mfv0, mfo0, mfm0, mfv1, mfo1, mfm1] = request.security(syminfo.tickerid, 'M', f_flipEngine())

// ───────────────────────────── Naked POC Engine ─────────────────────────────
// Each Daily, Weekly and Monthly session gets a volume profile. On 1D and higher charts the profile comes
// from footprint volume-at-price. Otherwise each lower-timeframe bar's volume is spread evenly across its
// high-low range. When a session ends, its highest-volume row becomes that session's POC. A POC is naked
// until a later bar trades through it, then it moves to a short list of mitigated POCs with the hit time.
// Sessions follow the exchange timezone (UTC for most crypto), weeks start Monday.
f_dayStart(t) =>
    tz = syminfo.timezone
    timestamp(tz, year(t, tz), month(t, tz), dayofmonth(t, tz), 0, 0, 0)

f_weekStart(t) =>
    tz = syminfo.timezone
    ds = timestamp(tz, year(t, tz), month(t, tz), dayofmonth(t, tz), 0, 0, 0)
    ds - ((dayofweek(t, tz) - 2 + 7) % 7) * msPerDay

f_monthStart(t) =>
    tz = syminfo.timezone
    timestamp(tz, year(t, tz), month(t, tz), 1, 0, 0, 0)

f_key(kd, t) =>
    kd == 0 ? f_dayStart(t) : kd == 1 ? f_weekStart(t) : f_monthStart(t)

binP = syminfo.mintick * poc_tpr
mitTol = binP / 20

type Sess
    int key
    map<int, float> prof
    float lo
    float hi
    array<float> pocs
    array<int> times
    array<float> fv
    array<int> fo
    array<int> fm

f_newSess() =>
    Sess.new(na, map.new<int, float>(), na, na, array.new_float(), array.new_int(), array.new_float(), array.new_int(), array.new_int())

f_copySess(Sess s) =>
    Sess.new(s.key, map.copy(s.prof), s.lo, s.hi, array.copy(s.pocs), array.copy(s.times), array.copy(s.fv), array.copy(s.fo), array.copy(s.fm))

f_add(Sess s, float lo, float hi, float vol) =>
    if not na(lo) and not na(hi) and vol > 0
        s.lo := na(s.lo) ? lo : math.min(s.lo, lo)
        s.hi := na(s.hi) ? hi : math.max(s.hi, hi)
        k0 = int(math.floor(lo / binP))
        k1 = int(math.floor(hi / binP))
        if k1 <= k0 or hi <= lo
            map.put(s.prof, k0, nz(map.get(s.prof, k0)) + vol)
        else
            span = hi - lo
            for k = k0 to k1
                bl = math.max(lo, k * binP)
                bh = math.min(hi, (k + 1) * binP)
                if bh > bl
                    map.put(s.prof, k, nz(map.get(s.prof, k)) + vol * (bh - bl) / span)

f_pocOf(Sess s) =>
    float poc = na
    if map.size(s.prof) > 0
        ks = map.keys(s.prof)
        float best = -1.0
        for i = 0 to array.size(ks) - 1
            k = array.get(ks, i)
            v = nz(map.get(s.prof, k))
            if v > best
                best := v
                poc := (k + 0.5) * binP
    poc

// A new session has started: the finished session's POC joins the naked list and its profile is cleared.
f_roll(Sess s, int newKey) =>
    if not na(s.key) and map.size(s.prof) > 0
        p = f_pocOf(s)
        if not na(p)
            array.unshift(s.pocs, p)
            array.unshift(s.times, s.key)
            if array.size(s.pocs) > 12
                array.pop(s.pocs)
                array.pop(s.times)
    map.clear(s.prof)
    s.lo := na
    s.hi := na
    s.key := newKey

// Any naked POC inside the bar's range [l, h] is mitigated and moves to the frozen list, newest first.
// The first touch mitigates a POC, including a touch by the bar that is still forming.
f_mitigate(Sess s, float h, float l, int tm) =>
    i = array.size(s.pocs) - 1
    while i >= 0
        p = array.get(s.pocs, i)
        if l - mitTol <= p and p <= h + mitTol
            array.unshift(s.fv, p)
            array.unshift(s.fo, array.get(s.times, i))
            array.unshift(s.fm, tm)
            if array.size(s.fv) > 6
                array.pop(s.fv)
                array.pop(s.fo)
                array.pop(s.fm)
            array.remove(s.pocs, i)
            array.remove(s.times, i)
        i := i - 1

// Index of the nth mitigated POC whose session start is inside the lookback window, or -1.
f_fzIdx(Sess s, int cutF, int nth) =>
    int found = -1
    int c = 0
    n = array.size(s.fv)
    if n > 0
        for i = 0 to n - 1
            if found < 0 and array.get(s.fo, i) >= cutF
                if c == nth
                    found := i
                c += 1
    found

f_ingestAll(Sess dS_, Sess wS_, Sess mS_, footprint fp_, array<int> ts, array<float> hs, array<float> ls, array<float> vs, int cnt) =>
    chartSec = timeframe.in_seconds()
    array<float> fLo = array.new_float()
    array<float> fHi = array.new_float()
    array<float> fVo = array.new_float()
    if not na(fp_)
        rws = footprint.rows(fp_)
        nr = array.size(rws)
        if nr > 0
            for i = 0 to nr - 1
                rw = array.get(rws, i)
                rv = volume_row.total_volume(rw)
                rdn = math.max(volume_row.down_price(rw), low)
                rup = math.min(volume_row.up_price(rw), high)
                if rv > 0 and not na(rdn) and not na(rup)
                    array.push(fLo, math.min(rdn, rup))
                    array.push(fHi, math.max(rdn, rup))
                    array.push(fVo, rv)
    array<Sess> sessArr = array.new<Sess>()
    array.push(sessArr, dS_)
    array.push(sessArr, wS_)
    array.push(sessArr, mS_)
    thr = array.from(86400, 604800, 2678400)
    for kd = 0 to 2
        Sess s = array.get(sessArr, kd)
        fits = chartSec <= array.get(thr, kd)
        if fits and array.size(fLo) > 0
            k = f_key(kd, time)
            if na(s.key) or k != s.key
                f_roll(s, k)
            for i = 0 to array.size(fLo) - 1
                f_add(s, array.get(fLo, i), array.get(fHi, i), array.get(fVo, i))
            f_mitigate(s, high, low, time)
        else if cnt > 0
            for j = 0 to cnt - 1
                t = array.get(ts, j)
                h = array.get(hs, j)
                l = array.get(ls, j)
                if not na(t) and not na(h) and not na(l)
                    k = f_key(kd, t)
                    if na(s.key) or k != s.key
                        f_roll(s, k)
                    f_add(s, l, h, nz(array.get(vs, j)))
                    f_mitigate(s, h, l, t)
        else if fits
            k = f_key(kd, time)
            if na(s.key) or k != s.key
                f_roll(s, k)
            f_add(s, low, high, nz(volume))
            f_mitigate(s, high, low, time)

var Sess dS = f_newSess()
var Sess wS = f_newSess()
var Sess mS = f_newSess()

effFine = timeframe.in_seconds(poc_res_fine) >= timeframe.in_seconds() ? timeframe.period : poc_res_fine
effCoarse = timeframe.in_seconds(poc_res_coarse) >= timeframe.in_seconds() ? timeframe.period : poc_res_coarse
[fT, fH, fL, fV] = request.security_lower_tf(syminfo.tickerid, effFine, [time, high, low, volume])
[cT, cH, cL, cV] = request.security_lower_tf(syminfo.tickerid, effCoarse, [time, high, low, volume])
useFine = f_sz(fT) > 0
ltT = useFine ? fT : cT
ltH = useFine ? fH : cH
ltL = useFine ? fL : cL
ltV = useFine ? fV : cV

footprint fp = poc_use_fp and (show_dpoc or show_wpoc or show_mpoc) and timeframe.in_seconds() >= 86400 ? request.footprint(poc_tpr) : na

ingestFrom = timenow - (poc_lookback + 35) * msPerDay

// Only closed bars are written into the permanent state; the forming bar is previewed on a copy later.
if barstate.isconfirmed and (show_dpoc or show_wpoc or show_mpoc) and time >= ingestFrom
    f_ingestAll(dS, wS, mS, fp, ltT, ltH, ltL, ltV, f_sz(ltT))
    // ───────────────────────────── Naked Level Model (live bar) ─────────────────────────────
// Slots: 0-2 Daily levels, 3-5 Weekly levels, 6-8 Monthly levels,
//        9-11 dPOC, 12-14 wPOC, 15-17 mPOC,
//        18 Daily pending, 19 Weekly pending, 20 Monthly pending,
//        21-22 Daily frozen, 23-24 Weekly frozen, 25-26 Monthly frozen,
//        27-28 dPOC frozen, 29-30 wPOC frozen, 31-32 mPOC frozen,
//        33-35 developing dPOC, wPOC, mPOC
var float[] nkVal = array.new_float(36, na)
var int[] nkTime = array.new_int(36, na)
var int[] nkEnd = array.new_int(36, na)
var line[] nkLines = array.new<line>(36, na)
var table dbg = poc_debug ? table.new(position.top_right, 3, 12, bgcolor = color.new(color.black, 20), border_width = 1) : na

if barstate.islast
    dVals = array.from(d0, d1, d2)
    dTms = array.from(dt0, dt1, dt2)
    wVals = array.from(w0, w1, w2)
    wTms = array.from(wt0, wt1, wt2)
    mVals = array.from(m0, m1, m2)
    mTms = array.from(mt0, mt1, mt2)
    mxD = math.min(max_dlv, 3)
    mxW = math.min(max_wlv, 3)
    mxM = math.min(max_mlv, 3)
    mxDP = math.min(max_dpoc, 3)
    mxWP = math.min(max_wpoc, 3)
    mxMP = math.min(max_mpoc, 3)

    for s = 0 to 35
        array.set(nkVal, s, na)
        array.set(nkTime, s, na)
        array.set(nkEnd, s, na)

    for k = 0 to 2
        array.set(nkVal, k, show_dlv and k < mxD ? array.get(dVals, k) : na)
        array.set(nkTime, k, array.get(dTms, k))
        array.set(nkVal, 3 + k, show_wlv and k < mxW ? array.get(wVals, k) : na)
        array.set(nkTime, 3 + k, array.get(wTms, k))
        array.set(nkVal, 6 + k, show_mlv and k < mxM ? array.get(mVals, k) : na)
        array.set(nkTime, 6 + k, array.get(mTms, k))

    array.set(nkVal, 18, show_dlv and show_pending ? dpv : na)
    array.set(nkTime, 18, dpt)
    array.set(nkVal, 19, show_wlv and show_pending ? wpv : na)
    array.set(nkTime, 19, wpt)
    array.set(nkVal, 20, show_mlv and show_pending ? mpv : na)
    array.set(nkTime, 20, mpt)

    dfvA = array.from(dfv0, dfv1)
    dfoA = array.from(dfo0, dfo1)
    dfmA = array.from(dfm0, dfm1)
    wfvA = array.from(wfv0, wfv1)
    wfoA = array.from(wfo0, wfo1)
    wfmA = array.from(wfm0, wfm1)
    mfvA = array.from(mfv0, mfv1)
    mfoA = array.from(mfo0, mfo1)
    mfmA = array.from(mfm0, mfm1)
    for q = 0 to 1
        keepQ = dw_freeze == 'Freeze Line' and q < dw_frozen_keep and not rDw
        array.set(nkVal, 21 + q, show_dlv and keepQ ? array.get(dfvA, q) : na)
        array.set(nkTime, 21 + q, array.get(dfoA, q))
        array.set(nkEnd, 21 + q, array.get(dfmA, q))
        array.set(nkVal, 23 + q, show_wlv and keepQ ? array.get(wfvA, q) : na)
        array.set(nkTime, 23 + q, array.get(wfoA, q))
        array.set(nkEnd, 23 + q, array.get(wfmA, q))
        array.set(nkVal, 25 + q, show_mlv and keepQ ? array.get(mfvA, q) : na)
        array.set(nkTime, 25 + q, array.get(mfoA, q))
        array.set(nkEnd, 25 + q, array.get(mfmA, q))

    dPrev = f_copySess(dS)
    wPrev = f_copySess(wS)
    mPrev = f_copySess(mS)
    if not barstate.isconfirmed and (show_dpoc or show_wpoc or show_mpoc)
        f_ingestAll(dPrev, wPrev, mPrev, fp, ltT, ltH, ltL, ltV, f_sz(ltT))

    for k = 0 to 2
        if k < array.size(dPrev.pocs)
            array.set(nkVal, 9 + k, show_dpoc and k < mxDP ? array.get(dPrev.pocs, k) : na)
            array.set(nkTime, 9 + k, array.get(dPrev.times, k))
        if k < array.size(wPrev.pocs)
            array.set(nkVal, 12 + k, show_wpoc and k < mxWP ? array.get(wPrev.pocs, k) : na)
            array.set(nkTime, 12 + k, array.get(wPrev.times, k))
        if k < array.size(mPrev.pocs)
            array.set(nkVal, 15 + k, show_mpoc and k < mxMP ? array.get(mPrev.pocs, k) : na)
            array.set(nkTime, 15 + k, array.get(mPrev.times, k))

    if show_devpoc
        array.set(nkVal, 33, show_dpoc ? f_pocOf(dPrev) : na)
        array.set(nkTime, 33, dPrev.key)
        array.set(nkVal, 34, show_wpoc ? f_pocOf(wPrev) : na)
        array.set(nkTime, 34, wPrev.key)
        array.set(nkVal, 35, show_mpoc ? f_pocOf(mPrev) : na)
        array.set(nkTime, 35, mPrev.key)

    cutF = time - poc_lookback * msPerDay
    for k = 0 to 1
        keepP = poc_freeze == 'Freeze Line' and k < poc_frozen_keep and not rPoc
        ixD = f_fzIdx(dPrev, cutF, k)
        ixW = f_fzIdx(wPrev, cutF, k)
        ixM = f_fzIdx(mPrev, cutF, k)
        if ixD >= 0
            array.set(nkVal, 27 + k, show_dpoc and keepP ? array.get(dPrev.fv, ixD) : na)
            array.set(nkTime, 27 + k, array.get(dPrev.fo, ixD))
            array.set(nkEnd, 27 + k, array.get(dPrev.fm, ixD))
        if ixW >= 0
            array.set(nkVal, 29 + k, show_wpoc and keepP ? array.get(wPrev.fv, ixW) : na)
            array.set(nkTime, 29 + k, array.get(wPrev.fo, ixW))
            array.set(nkEnd, 29 + k, array.get(wPrev.fm, ixW))
        if ixM >= 0
            array.set(nkVal, 31 + k, show_mpoc and keepP ? array.get(mPrev.fv, ixM) : na)
            array.set(nkTime, 31 + k, array.get(mPrev.fo, ixM))
            array.set(nkEnd, 31 + k, array.get(mPrev.fm, ixM))

    if poc_debug
        table.cell(dbg, 0, 0, 'Footprint', text_color = color.white, text_size = size.small)
        table.cell(dbg, 1, 0, na(fp) ? 'no' : 'yes', text_color = color.white, text_size = size.small)
        table.cell(dbg, 0, 1, 'Daily POCs', text_color = color.white, text_size = size.small)
        table.cell(dbg, 2, 1, 'Weekly POCs', text_color = color.white, text_size = size.small)
        for r = 0 to 4
            string dTxt = ''
            string wTxt = ''
            if r < array.size(dPrev.pocs)
                dTxt := str.tostring(array.get(dPrev.pocs, r), format.mintick) + '  ' + str.format_time(array.get(dPrev.times, r), 'yyyy-MM-dd', 'UTC')
            if r < array.size(wPrev.pocs)
                wTxt := str.tostring(array.get(wPrev.pocs, r), format.mintick) + '  ' + str.format_time(array.get(wPrev.times, r), 'yyyy-MM-dd', 'UTC')
            table.cell(dbg, 0, 2 + r, dTxt, text_color = color.white, text_size = size.small)
            table.cell(dbg, 2, 2 + r, wTxt, text_color = color.white, text_size = size.small)
        table.cell(dbg, 0, 7, 'Frozen Daily', text_color = color.white, text_size = size.small)
        table.cell(dbg, 2, 7, 'Frozen Weekly', text_color = color.white, text_size = size.small)
        for r = 0 to 3
            string fdTxt = ''
            string fwTxt = ''
            if r < array.size(dPrev.fv)
                fdTxt := str.tostring(array.get(dPrev.fv, r), format.mintick) + '  ' + str.format_time(array.get(dPrev.fo, r), 'yyyy-MM-dd', 'UTC')
            if r < array.size(wPrev.fv)
                fwTxt := str.tostring(array.get(wPrev.fv, r), format.mintick) + '  ' + str.format_time(array.get(wPrev.fo, r), 'yyyy-MM-dd', 'UTC')
            table.cell(dbg, 0, 8 + r, fdTxt, text_color = color.white, text_size = size.small)
            table.cell(dbg, 2, 8 + r, fwTxt, text_color = color.white, text_size = size.small)

// ───────────────────────────── Price Scale Tags ─────────────────────────────
// The price scale shows a plot's most recent non-empty value, so tags are fed only on the live bar.
// On realtime bars the closing tick is skipped so no stale value is left behind.
flagMon = (ps_mon ? display.price_scale + display.status_line : display.status_line) - display.pane
flagHl = (ps_hl ? display.price_scale + display.status_line : display.status_line) - display.pane
flagDw = (ps_dw ? display.price_scale + display.status_line : display.status_line) - display.pane
flagPoc = (ps_poc ? display.price_scale + display.status_line : display.status_line) - display.pane
tagBar = barstate.islast and (not barstate.isrealtime or not barstate.isconfirmed)

plot(tagBar and show_mon and show_monh ? monHigh : na, 'Monday High', mono ? mono_col : col_monh, 1, style = plot.style_line, display = flagMon)
plot(tagBar and show_mon and show_monl ? monLow : na, 'Monday Low', mono ? mono_col : col_monl, 1, style = plot.style_line, display = flagMon)
plot(tagBar and show_mon and show_monm ? monMid : na, 'Monday Mid', mono ? mono_col : col_monm, 1, style = plot.style_line, display = flagMon)
plot(tagBar and sh_pdh and not f_tagOff(0) ? pDayHigh : na, 'PDH', mono ? mono_col : col_pdh, 1, style = plot.style_line, display = flagHl)
plot(tagBar and sh_pdl and not f_tagOff(1) ? pDayLow : na, 'PDL', mono ? mono_col : col_pdl, 1, style = plot.style_line, display = flagHl)
plot(tagBar and sh_pdm and not f_tagOff(2) ? pDayMid : na, 'PDM', mono ? mono_col : col_pdm, 1, style = plot.style_line, display = flagHl)
plot(tagBar and sh_wh and not f_tagOff(3) ? pWeekHigh : na, 'PWH', mono ? mono_col : col_wh, 1, style = plot.style_line, display = flagHl)
plot(tagBar and sh_wl and not f_tagOff(4) ? pWeekLow : na, 'PWL', mono ? mono_col : col_wl, 1, style = plot.style_line, display = flagHl)
plot(tagBar and sh_wm and not f_tagOff(5) ? pWeekMid : na, 'PWM', mono ? mono_col : col_wm, 1, style = plot.style_line, display = flagHl)
plot(tagBar and sh_mh and not f_tagOff(6) ? pMonthHigh : na, 'PMH', mono ? mono_col : col_mh, 1, style = plot.style_line, display = flagHl)
plot(tagBar and sh_ml and not f_tagOff(7) ? pMonthLow : na, 'PML', mono ? mono_col : col_ml, 1, style = plot.style_line, display = flagHl)
plot(tagBar and sh_mm and not f_tagOff(8) ? pMonthMid : na, 'PMM', mono ? mono_col : col_mm, 1, style = plot.style_line, display = flagHl)

plot(tagBar ? array.get(nkVal, 0) : na, 'Daily Level 1', mono ? mono_col : col_dlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 1) : na, 'Daily Level 2', mono ? mono_col : col_dlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 2) : na, 'Daily Level 3', mono ? mono_col : col_dlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 3) : na, 'Weekly Level 1', mono ? mono_col : col_wlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 4) : na, 'Weekly Level 2', mono ? mono_col : col_wlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 5) : na, 'Weekly Level 3', mono ? mono_col : col_wlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 6) : na, 'Monthly Level 1', mono ? mono_col : col_mlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 7) : na, 'Monthly Level 2', mono ? mono_col : col_mlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 8) : na, 'Monthly Level 3', mono ? mono_col : col_mlv, 1, style = plot.style_line, display = flagDw)
plot(tagBar ? array.get(nkVal, 9) : na, 'dPOC 1', mono ? mono_col : col_dpoc, 1, style = plot.style_line, display = flagPoc)
plot(tagBar ? array.get(nkVal, 10) : na, 'dPOC 2', mono ? mono_col : col_dpoc, 1, style = plot.style_line, display = flagPoc)
plot(tagBar ? array.get(nkVal, 11) : na, 'dPOC 3', mono ? mono_col : col_dpoc, 1, style = plot.style_line, display = flagPoc)
plot(tagBar ? array.get(nkVal, 12) : na, 'wPOC 1', mono ? mono_col : col_wpoc, 1, style = plot.style_line, display = flagPoc)
plot(tagBar ? array.get(nkVal, 13) : na, 'wPOC 2', mono ? mono_col : col_wpoc, 1, style = plot.style_line, display = flagPoc)
plot(tagBar ? array.get(nkVal, 14) : na, 'wPOC 3', mono ? mono_col : col_wpoc, 1, style = plot.style_line, display = flagPoc)
plot(tagBar ? array.get(nkVal, 15) : na, 'mPOC 1', mono ? mono_col : col_mpoc, 1, style = plot.style_line, display = flagPoc)
plot(tagBar ? array.get(nkVal, 16) : na, 'mPOC 2', mono ? mono_col : col_mpoc, 1, style = plot.style_line, display = flagPoc)
plot(tagBar ? array.get(nkVal, 17) : na, 'mPOC 3', mono ? mono_col : col_mpoc, 1, style = plot.style_line, display = flagPoc)

// ───────────────────────────── Line Labels ─────────────────────────────
// Entries 0-11 are the Monday and previous-period levels (MDAY-H, MDAY-L, MDAY-M, PDH, PDL, PDM, PWH, PWL, PWM, PMH, PML, PMM),
// followed by the 36 model slots above. Overlapping labels are combined in this order.

if barstate.islast
    lblSz = f_labelSize(label_size_str)

    lvVal = array.from(monHigh, monLow, monMid, pDayHigh, pDayLow, pDayMid, pWeekHigh, pWeekLow, pWeekMid, pMonthHigh, pMonthLow, pMonthMid)
    lvTxt = array.from(lbl_monh, lbl_monl, lbl_monm, lbl_pdh, lbl_pdl, lbl_pdm, lbl_wh, lbl_wl, lbl_wm, lbl_mh, lbl_ml, lbl_mm)
    lvCol = array.from(f_c(col_monh), f_c(col_monl), f_c(col_monm), f_c(col_pdh), f_c(col_pdl), f_c(col_pdm), f_c(col_wh), f_c(col_wl), f_c(col_wm), f_c(col_mh), f_c(col_ml), f_c(col_mm))
    lvSty = array.from(style_mon, style_mon, style_mon, style_pd, style_pd, style_pd, style_pw, style_pw, style_pw, style_pm, style_pm, style_pm)
    lvAct = array.from(show_labels and show_mon and show_monh, show_labels and show_mon and show_monl, show_labels and show_mon and show_monm, show_labels and sh_pdh and not f_removed(0), show_labels and sh_pdl and not f_removed(1), show_labels and sh_pdm and not f_removed(2), show_labels and sh_wh and not f_removed(3), show_labels and sh_wl and not f_removed(4), show_labels and sh_wm and not f_removed(5), show_labels and sh_mh and not f_removed(6), show_labels and sh_ml and not f_removed(7), show_labels and sh_mm and not f_removed(8))
    lvAnc = array.from(f_anchor(nz(monEndBar, bar_index), place_mon), f_anchor(nz(monEndBar, bar_index), place_mon), f_anchor(nz(monEndBar, bar_index), place_mon), f_anchor(f_barEff(0), place_hl), f_anchor(f_barEff(1), place_hl), f_anchor(f_barEff(2), place_hl), f_anchor(f_barEff(3), place_hl), f_anchor(f_barEff(4), place_hl), f_anchor(f_barEff(5), place_hl), f_anchor(f_barEff(6), place_hl), f_anchor(f_barEff(7), place_hl), f_anchor(f_barEff(8), place_hl))
    lvPr = array.from(pr_mon, pr_mon, pr_mon, pr_hl, pr_hl, pr_hl, pr_hl, pr_hl, pr_hl, pr_hl, pr_hl, pr_hl)
    lvFz = array.from(false, false, false, f_frz(0), f_frz(1), f_frz(2), f_frz(3), f_frz(4), f_frz(5), f_frz(6), f_frz(7), f_frz(8))

    slotTxt = array.from(lbl_dlv, lbl_wlv, lbl_mlv, lbl_dpoc, lbl_wpoc, lbl_mpoc)
    slotCol = array.from(col_dlv, col_wlv, col_mlv, col_dpoc, col_wpoc, col_mpoc)

    for k = 0 to 35
        int ty = 0
        bool pend = false
        bool dev = false
        bool frz = false
        if k < 9
            ty := int(k / 3)
        else if k < 18
            ty := 3 + int((k - 9) / 3)
        else if k < 21
            ty := k - 18
            pend := true
        else if k < 27
            ty := int((k - 21) / 2)
            frz := true
        else if k < 33
            ty := 3 + int((k - 27) / 2)
            frz := true
        else
            ty := 3 + (k - 33)
            dev := true
        nv = array.get(nkVal, k)
        baseTxt = array.get(slotTxt, ty)
        string tx = pend ? baseTxt + ' (Pending)' : dev ? baseTxt + ' (Dev)' : baseTxt
        color cl = f_c(array.get(slotCol, ty))
        if frz
            cl := color.new(cl, mit_dim)
        stl = ty < 3 ? style_dw : style_poc
        endT = array.get(nkEnd, k)
        int anc = bar_index
        plc = ty < 3 ? place_dw : place_poc
        if frz and not na(endT)
            anc := f_anchor(f_barAt(endT), plc)
        else
            anc := f_anchor(bar_index, plc)
        array.push(lvVal, nv)
        array.push(lvTxt, tx)
        array.push(lvCol, cl)
        array.push(lvSty, stl)
        array.push(lvAct, show_labels and not na(nv))
        array.push(lvAnc, anc)
        array.push(lvPr, ty < 3 ? pr_dw : pr_poc)
        array.push(lvFz, frz)

        ln = array.get(nkLines, k)
        lt0 = array.get(nkTime, k)
        hideL = ty < 3 ? rDw : rPoc
        lineEnd = frz and not na(endT) ? array.get(barTimes, f_barAt(endT)) : time
        if not na(nv) and not na(lt0) and not hideL
            if na(ln)
                array.set(nkLines, k, line.new(lt0, nv, lineEnd, nv, xloc.bar_time, color = cl, style = f_lineStyle(stl), width = lineWidth))
            else
                line.set_xy1(ln, lt0, nv)
                line.set_xy2(ln, lineEnd, nv)
                line.set_color(ln, cl)
                line.set_style(ln, f_lineStyle(stl))
        else if not na(ln)
            line.delete(ln)
            array.set(nkLines, k, na)

    nTot = array.size(lvVal)
    used = array.new_bool(nTot, false)
    placed = array.new_bool(nTot, false)
    fTxt = array.new_string(nTot, '')

    for i = 0 to nTot - 1
        vi = array.get(lvVal, i)
        if array.get(lvAct, i) and not na(vi) and not array.get(used, i)
            txt = array.get(lvTxt, i)
            if combine_labels
                for j = 0 to nTot - 1
                    if j > i
                        vj = array.get(lvVal, j)
                        if array.get(lvAct, j) and not na(vj) and not array.get(used, j) and array.get(lvAnc, j) == array.get(lvAnc, i) and f_near(vi, vj)
                            txt := txt + '/' + array.get(lvTxt, j)
                            array.set(used, j, true)
            array.set(placed, i, true)
            array.set(fTxt, i, f_buildText(txt, vi, array.get(lvPr, i)))

    for i = 0 to nTot - 1
        if array.get(placed, i)
            fzI = array.get(lvFz, i)
            offI = fzI ? 0 : line_offset
            csI = array.get(lvAnc, i)
            f_setLabel(i, true, array.get(lvVal, i), array.get(fTxt, i), array.get(lvCol, i), array.get(lvSty, i), offI, csI, csI + offI, lblSz)
        else
            f_setLabel(i, false, float(na), '', color.gray, 'Solid', 0, bar_index, bar_index, lblSz)
````
