# Low Volume Zones

- url: https://www.tradingview.com/script/TNrXYDVi-Low-Volume-Zones/
- type: indicator
- pine_id: PUB;43718f9a739a421891391c9fd51f9745
- version: 2.0

## Description

Takes a fixed-range volume profile (approximated based on price grouping) between swings/pivots and displays low volume node zones of interest. Beta.

## Source Code

````pine
//@version=5
indicator('Low Volume Zones', overlay = true, max_boxes_count = 500, max_bars_back = 500)
// v1.1
// Displays low volume node (LVNs) zones between swings.
// Reccomended to use in conjunction with Fixed Volume Profile indicator and then wait to see how price action is reacting near or within each displayed zone.
// **Please note that low volume zones are not perfect as they are approximated from price zones and limited to the volume data provided by Trading View.
// Changes from v1.0:
//   • Toggle checkboxes for Support and Resistance zones
//   • Multi-timeframe (MTF) zones via request.security — default is chart's TF. Note that zones should often be the same regardless of timeframe, but, it also depends on where pivots were established, which can vary.
//   • Added notes to script input settings.
// ══════════════════════════════════════════════════════════════════════════════
// ║ Inputs
// ══════════════════════════════════════════════════════════════════════════════
pivot_left  = input.int(50,    'Pivot Left Bars',                minval = 2,    maxval = 100,  group = 'Pivots') // No. of bars lookback. Reccommend 20 - 50 depending on timeframe.
pivot_right = input.int(2,     'Pivot Right Bars',               minval = 2,    maxval = 50,   group = 'Pivots') // No. of bars to confirm high/low pivot. Reccommend 2 or 3 bars, pending timeframe. Lower setting will create false pivots.
n_bins      = input.int(30,    'Volume Profile Bins',            minval = 2,    maxval = 50,   group = 'Profile') // No. of LVN 'bins'. Divides the price range up from the swing low to high. A lower value covers a higher overall price range.
lvn_thresh  = input.float(0.25, 'LVN Threshold (% of peak)',      minval = 0.05, maxval = 0.95, step = 0.05, group = 'Profile') // Max. allowable volume threshold based on peak volume in the bin.
n_groups    = input.int(3,     'LVN Groups (zones per profile)', minval = 1,    maxval = 10,   group = 'Profile') // Total number of low volume groups/zones to display per bin. Reccomend 2-3, depending on other settings.
max_ext     = input.int(500,   'Max Extension Bars',             minval = 10,   maxval = 1000, group = 'Display') // Max number of bars to extend the zone to the right (until price breaks)
show_pivots = input.bool(true, 'Show Pivot Markers',             group = 'Display') // Toggle display of confirmed pivots.
 
// NEW: on/off toggles for the two zone types -- All zones are low volume, support zones are just created when price is increasing & vice versa.
show_support    = input.bool(true, 'Show Support Zones',    group = 'Display')
show_resistance = input.bool(true, 'Show Resistance Zones', group = 'Display')
 
// NEW: multi-timeframe selector. Current chart timeframe by default.
mtf_tf = input.timeframe('', 'Zone Timeframe', group = 'Timeframe',
     tooltip = 'Blank uses the chart timeframe. Select a higher TF to plot zones from that TF regardless of the chart.')
 
s_box_col = input.color(color.new(#03f4fd, 75), 'Support Fill',      group = 'Support')
s_bdr_col = input.color(color.new(#03f4fd, 0),  'Support Border',    group = 'Support')
r_box_col = input.color(color.new(#03f4fd, 75), 'Resistance Fill',   group = 'Resistance')
r_bdr_col = input.color(color.new(#03f4fd, 0),  'Resistance Border', group = 'Resistance')
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ MTF helpers
// ══════════════════════════════════════════════════════════════════════════════
// Is the selected TF the same as the chart? (blank = chart TF)
use_chart_tf = mtf_tf == '' or mtf_tf == timeframe.period
 
// Scale factor: how many chart bars fit inside one HTF bar (approx, min 1)
tf_mult = use_chart_tf ? 1 : math.max(1, int(timeframe.in_seconds(mtf_tf) / timeframe.in_seconds(timeframe.period)))
 
// OHLCV — use chart series directly when the zone TF matches, otherwise pull
// from HTF with lookahead_off. This avoids request.security's same-TF 1-bar
// delay that would otherwise shift the whole volume profile.
htf_high   = use_chart_tf ? high   : request.security(syminfo.tickerid, mtf_tf, high,   lookahead = barmerge.lookahead_off)
htf_low    = use_chart_tf ? low    : request.security(syminfo.tickerid, mtf_tf, low,    lookahead = barmerge.lookahead_off)
htf_volume = use_chart_tf ? volume : request.security(syminfo.tickerid, mtf_tf, volume, lookahead = barmerge.lookahead_off)
 
// HTF bar-boundary marker so the profile doesn't double-count repeated values
// when the chart TF is finer than the zone TF. True every bar on chart TF.
is_new_htf_bar = use_chart_tf ? true : ta.change(time(mtf_tf)) != 0
 
// Pivots — same short-circuit: direct on chart TF, security() otherwise.
ph = use_chart_tf ? ta.pivothigh(high, pivot_left, pivot_right) : request.security(syminfo.tickerid, mtf_tf, ta.pivothigh(high, pivot_left, pivot_right), lookahead = barmerge.lookahead_off)
pl = use_chart_tf ? ta.pivotlow(low,   pivot_left, pivot_right) : request.security(syminfo.tickerid, mtf_tf, ta.pivotlow(low,   pivot_left, pivot_right), lookahead = barmerge.lookahead_off)
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Support box tracking  (pivot low → highest pivot high)
// ══════════════════════════════════════════════════════════════════════════════
var box[]   s_boxes  = array.new<box>()
var float[] s_tops   = array.new<float>()
var float[] s_bots   = array.new<float>()
var int[]   s_starts = array.new<int>()
var int[]   s_pids   = array.new<int>()
 
var float s_anchor_pl      = na
var int   s_anchor_pl_idx  = na
var float s_highest_ph     = na
var int   s_highest_ph_idx = na
var int   s_cur_pid        = 0
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Resistance box tracking  (pivot high → lowest pivot low)
// ══════════════════════════════════════════════════════════════════════════════
var box[]   r_boxes  = array.new<box>()
var float[] r_tops   = array.new<float>()
var float[] r_bots   = array.new<float>()
var int[]   r_starts = array.new<int>()
var int[]   r_pids   = array.new<int>()
 
var float r_anchor_ph      = na
var int   r_anchor_ph_idx  = na
var float r_lowest_pl      = na
var int   r_lowest_pl_idx  = na
var int   r_cur_pid        = 0
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Toggle-off cleanup: purge any leftover boxes when a zone type is hidden
// ══════════════════════════════════════════════════════════════════════════════
if not show_support
    s_clr = array.size(s_boxes)
    if s_clr > 0
        for i = 0 to s_clr - 1
            box.delete(array.get(s_boxes, s_clr - 1 - i))
        array.clear(s_boxes)
        array.clear(s_tops)
        array.clear(s_bots)
        array.clear(s_starts)
        array.clear(s_pids)
 
if not show_resistance
    r_clr = array.size(r_boxes)
    if r_clr > 0
        for i = 0 to r_clr - 1
            box.delete(array.get(r_boxes, r_clr - 1 - i))
        array.clear(r_boxes)
        array.clear(r_tops)
        array.clear(r_bots)
        array.clear(r_starts)
        array.clear(r_pids)
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Volume profile + LVN draw logic
//   Uses HTF OHLCV via htf_high / htf_low / htf_volume.
//   Only accumulates on HTF-bar-close boundaries to avoid double counting
//   when the chart TF is finer than the zone TF.
// ══════════════════════════════════════════════════════════════════════════════
draw_support(int sb, int eb, float rhi, float rlo, int pid) =>
    rng = rhi - rlo
    nb  = eb - sb
    lb  = bar_index - sb
    if rng > 0 and nb > 0 and lb > 0 and lb <= 490
        bin_sz       = rng / n_bins
        float[] vols = array.new_float(n_bins, 0.0)
        for i = 0 to nb
            off = bar_index - (sb + i)
            if off >= 0 and off <= 490
                if nz(is_new_htf_bar[off], true)
                    mid = (htf_high[off] + htf_low[off]) / 2.0
                    b   = math.max(0, math.min(n_bins - 1, int((mid - rlo) / bin_sz)))
                    array.set(vols, b, array.get(vols, b) + nz(htf_volume[off]))
        peak = array.max(vols)
        if peak > 0
            bins_per_grp = math.max(1, int(n_bins / n_groups))
            for g = 0 to n_groups - 1
                g_start = g * bins_per_grp
                g_end   = g == n_groups - 1 ? n_bins - 1 : math.min(g_start + bins_per_grp - 1, n_bins - 1)
                if g_start > n_bins - 1
                    break
                min_vol = array.get(vols, g_start)
                min_b   = g_start
                if g_end > g_start
                    for b = g_start + 1 to g_end
                        v = array.get(vols, b)
                        if v < min_vol
                            min_vol := v
                            min_b   := b
                if min_vol <= lvn_thresh * peak
                    bot = rlo +  min_b      * bin_sz
                    top = rlo + (min_b + 1) * bin_sz
                    bx  = box.new(eb, top, bar_index, bot,
                         bgcolor = s_box_col, border_color = s_bdr_col, border_width = 1)
                    array.push(s_boxes,  bx)
                    array.push(s_tops,   top)
                    array.push(s_bots,   bot)
                    array.push(s_starts, bar_index)
                    array.push(s_pids,   pid)
 
draw_resistance(int sb, int eb, float rhi, float rlo, int pid) =>
    rng = rhi - rlo
    nb  = eb - sb
    lb  = bar_index - sb
    if rng > 0 and nb > 0 and lb > 0 and lb <= 490
        bin_sz       = rng / n_bins
        float[] vols = array.new_float(n_bins, 0.0)
        for i = 0 to nb
            off = bar_index - (sb + i)
            if off >= 0 and off <= 490
                if nz(is_new_htf_bar[off], true)
                    mid = (htf_high[off] + htf_low[off]) / 2.0
                    b   = math.max(0, math.min(n_bins - 1, int((mid - rlo) / bin_sz)))
                    array.set(vols, b, array.get(vols, b) + nz(htf_volume[off]))
        peak = array.max(vols)
        if peak > 0
            bins_per_grp = math.max(1, int(n_bins / n_groups))
            for g = 0 to n_groups - 1
                g_start = g * bins_per_grp
                g_end   = g == n_groups - 1 ? n_bins - 1 : math.min(g_start + bins_per_grp - 1, n_bins - 1)
                if g_start > n_bins - 1
                    break
                min_vol = array.get(vols, g_start)
                min_b   = g_start
                if g_end > g_start
                    for b = g_start + 1 to g_end
                        v = array.get(vols, b)
                        if v < min_vol
                            min_vol := v
                            min_b   := b
                if min_vol <= lvn_thresh * peak
                    bot = rlo +  min_b      * bin_sz
                    top = rlo + (min_b + 1) * bin_sz
                    bx  = box.new(eb, top, bar_index, bot,
                         bgcolor = r_box_col, border_color = r_bdr_col, border_width = 1)
                    array.push(r_boxes,  bx)
                    array.push(r_tops,   top)
                    array.push(r_bots,   bot)
                    array.push(r_starts, bar_index)
                    array.push(r_pids,   pid)
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Extend support boxes — retire on price touch or expiry
//   max_ext scaled by tf_mult so HTF zones get proportionally longer life.
// ══════════════════════════════════════════════════════════════════════════════
s_sz = array.size(s_boxes)
if s_sz > 0
    for i = 0 to s_sz - 1
        j   = s_sz - 1 - i
        bx  = array.get(s_boxes,  j)
        t   = array.get(s_tops,   j)
        bt  = array.get(s_bots,   j)
        st  = array.get(s_starts, j)
        hit = low <= t and high >= bt
        exp = bar_index - st >= max_ext * tf_mult
        if hit or exp
            // Box is left drawn in place — broken/expired zones remain visible
            array.remove(s_boxes,  j)
            array.remove(s_tops,   j)
            array.remove(s_bots,   j)
            array.remove(s_starts, j)
            array.remove(s_pids,   j)
        else
            box.set_right(bx, bar_index)
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Extend resistance boxes — retire on price touch or expiry
// ══════════════════════════════════════════════════════════════════════════════
r_sz = array.size(r_boxes)
if r_sz > 0
    for i = 0 to r_sz - 1
        j   = r_sz - 1 - i
        bx  = array.get(r_boxes,  j)
        t   = array.get(r_tops,   j)
        bt  = array.get(r_bots,   j)
        st  = array.get(r_starts, j)
        hit = low <= t and high >= bt
        exp = bar_index - st >= max_ext * tf_mult
        if hit or exp
            // Box is left drawn in place — broken/expired zones remain visible
            array.remove(r_boxes,  j)
            array.remove(r_tops,   j)
            array.remove(r_bots,   j)
            array.remove(r_starts, j)
            array.remove(r_pids,   j)
        else
            box.set_right(bx, bar_index)
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Support profile logic  (anchors at pivot LOW, extends to highest pivot HIGH)
//   Pivot-right offset is in HTF bars, so scale by tf_mult for chart-bar anchor.
// ══════════════════════════════════════════════════════════════════════════════
 
// New pivot LOW → freeze old support profile, start fresh
if not na(pl)
    s_cur_pid        := s_cur_pid + 1
    s_anchor_pl      := pl
    s_anchor_pl_idx  := bar_index - pivot_right * tf_mult
    s_highest_ph     := na
    s_highest_ph_idx := na
 
// New pivot HIGH → if highest since support anchor, redraw current support profile
if show_support and not na(ph)
    s_cur_ph_idx = bar_index - pivot_right * tf_mult
    if not na(s_anchor_pl) and (na(s_highest_ph) or ph >= s_highest_ph)
        s_sz_a = array.size(s_boxes)
        if s_sz_a > 0
            for i = 0 to s_sz_a - 1
                j = s_sz_a - 1 - i
                if array.get(s_pids, j) == s_cur_pid
                    box.delete(array.get(s_boxes, j))
                    array.remove(s_boxes,  j)
                    array.remove(s_tops,   j)
                    array.remove(s_bots,   j)
                    array.remove(s_starts, j)
                    array.remove(s_pids,   j)
        s_highest_ph     := ph
        s_highest_ph_idx := s_cur_ph_idx
        draw_support(s_anchor_pl_idx, s_cur_ph_idx, math.max(s_anchor_pl, ph), math.min(s_anchor_pl, ph), s_cur_pid)
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Resistance profile logic  (anchors at pivot HIGH, extends to lowest pivot LOW)
// ══════════════════════════════════════════════════════════════════════════════
 
// New pivot HIGH → freeze old resistance profile, start fresh
if not na(ph)
    r_cur_pid        := r_cur_pid + 1
    r_anchor_ph      := ph
    r_anchor_ph_idx  := bar_index - pivot_right * tf_mult
    r_lowest_pl      := na
    r_lowest_pl_idx  := na
 
// New pivot LOW → if lowest since resistance anchor, redraw current resistance profile
if show_resistance and not na(pl)
    r_cur_pl_idx = bar_index - pivot_right * tf_mult
    if not na(r_anchor_ph) and (na(r_lowest_pl) or pl <= r_lowest_pl)
        r_sz_a = array.size(r_boxes)
        if r_sz_a > 0
            for i = 0 to r_sz_a - 1
                j = r_sz_a - 1 - i
                if array.get(r_pids, j) == r_cur_pid
                    box.delete(array.get(r_boxes, j))
                    array.remove(r_boxes,  j)
                    array.remove(r_tops,   j)
                    array.remove(r_bots,   j)
                    array.remove(r_starts, j)
                    array.remove(r_pids,   j)
        r_lowest_pl     := pl
        r_lowest_pl_idx := r_cur_pl_idx
        draw_resistance(r_anchor_ph_idx, r_cur_pl_idx, math.max(r_anchor_ph, pl), math.min(r_anchor_ph, pl), r_cur_pid)
 
// ══════════════════════════════════════════════════════════════════════════════
// ║ Plot Pivot markers
// ══════════════════════════════════════════════════════════════════════════════
plotshape(show_pivots and not na(ph), 'Pivot High', shape.triangledown, location.abovebar,
     color.new(color.red,   0), size = size.small, offset = -pivot_right * tf_mult)
plotshape(show_pivots and not na(pl), 'Pivot Low',  shape.triangleup,   location.belowbar,
     color.new(color.green, 0), size = size.small, offset = -pivot_right * tf_mult)
````
