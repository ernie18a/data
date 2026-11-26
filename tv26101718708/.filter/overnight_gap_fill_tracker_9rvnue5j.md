# Overnight Gap Fill Tracker 

- url: https://www.tradingview.com/script/9RvNUe5J-Overnight-Gap-Fill-Tracker/
- type: indicator
- pine_id: PUB;b6f8da90267843d8ba5a1a0fa24de99e
- version: 2.0

## Description

Overnight Gap Fill Tracker measures how often the opening gap on a stock or ETF is retraced during the same regular session. It breaks the results down by retracement depth, weekday, and gap size.

FIRST-TIME SETUP (PLEASE READ)
The default settings are scaled for SPX-level prices (min gap 10, size buckets 25 / 50, bounce distance 8, Dollar mode). On SPY, QQQ or a typical stock, those defaults filter out almost every gap, so the table will look empty until you adjust them. Open the indicator Settings and do ONE of these:
- Easiest: set "Gap measurement unit" (General) to Percent. The percent defaults (min gap 0.15%, small below 0.30%, large from 0.65%) work across symbols and price levels. SPY works out to roughly $1 min gap and $2 / $5 buckets.
- Or stay in Dollar mode and enter values for your symbol: "Min gap size ($)", "Small gap max ($)" and "Large gap min ($)". Example starting points: SPY 1 / 2 / 5, SPX 10 / 20 / 50.
Also set "Bounce min move (pts)". It is always in price units, even in Percent mode (example: SPY 1, SPX 10). The bounce rows are hidden by default and only matter if you turn them on.
Changing any setting recalculates all statistics from the bars on your chart.

WHAT IT DOES
1. At the first regular-session bar (09:30 New York time) it measures the gap: today's open minus the previous session's close, taken from the prior daily bar. Gaps below a user-set minimum are ignored.
2. It draws the gap zone, the prior close, and the 25%, 50% and 75% retracement levels, measured from the open back toward the prior close. The chart shows the most recent N gaps (adjustable).
3. During the session it compares each bar's high/low to those levels and records which were reached: 25%, 50%, 75%, and 100% (a full fill back to the prior close). The opening bar counts.
4. Each finished session is stored in a log. The statistics table is calculated from that log, using every gap on the chart or only the last N sessions if a lookback is set.

THE TABLE
- Fill rates at 25/50/75/100%: all gaps, gap-up only, gap-down only, shown with counts (hits/total).
- Fill rates by weekday, shown separately for gap-up and gap-down.
- Fill rates by gap size (small/medium/large, all gaps combined). Bucket edges are yours to set, either in price units or as a percent of price. Percent mode lets the same buckets work across symbols with different prices, and keeps them consistent as price drifts over the years.
- Optional bounce and continuation rows. Bounce: after the 50% level is touched, price moves back in the original gap direction by at least a set distance within a set number of bars. Continuation: the share of 50% touches that go on to a full fill.
- A TODAY row showing the current gap, its 50% target, fill status, and how often gaps on this weekday in the same direction have reached 50%.
- The gap-up and gap-down columns can be hidden, and most sections toggled, to shrink the table. Color themes include a colorblind-safe palette.

WHAT IT ADDS
Plotting the prior close and retracement levels is common. This script adds the statistics layer: a per-session log that feeds the fill-depth, weekday and size breakdowns, plus bounce/continuation tracking and a weekday-conditional TODAY row, all recalculated from the bars on your chart. The code is open so you can see exactly how each statistic is counted.

HOW TO USE
- Use an intraday chart (for example 5 or 15 minutes) with standard candles or bars, set to regular trading hours, on a symbol with one regular session per day (US stocks, ETFs, indices such as SPX).
- Complete the first-time setup above for your symbol.

LIMITATIONS
- The statistics describe past behavior of the bars loaded on your chart. They are not predictions or trade signals. Sample depth depends on how much intraday history your plan loads; the table header shows the date range and session count. Some cells (a single weekday, large gaps) can have small samples, so check the counts.
- Continuous futures are not supported: session boundaries and contract rolls distort what counts as an overnight gap.
- Non-standard chart types (Heikin Ashi, Renko, etc.) are not supported because their open/close values are not real prices.
- With extended hours enabled, the script may not detect the session open. Use the regular-hours setting.
- The current, unfinished session is included in the table, so today's numbers can change until the close.
- On a regular-hours chart, the table does not update for a new day until the market opens.

REPAINTING / LOOKAHEAD
The gap and retracement levels are fixed at the session's first bar using the previous daily close, requested with a one-bar offset so there is no lookahead. Fill flags use each bar's high/low, including the live bar. Once a level is touched it stays touched, so historical results do not change on reload.

This is a statistics tool for study, not financial advice.

## Source Code

````pine
//@version=6
indicator('Overnight Gap Fill Tracker v3', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ─── Helper functions ─────────────────────────────────────────────────────────
pct_n(n, d) =>
    d > 0 ? str.tostring(math.round(n / d * 100)) + '% (' + str.tostring(n) + '/' + str.tostring(d) + ')' : '—'

heat(n, d, cHigh, cMid, cLow, cNone) =>
    p = d > 0 ? math.round(n / d * 100) : -1
    p >= 80 ? cHigh : p >= 70 ? color.new(cHigh, 15) : p >= 60 ? cMid : p >= 0 ? cLow : cNone

// ─── Inputs: Chart ────────────────────────────────────────────────────────────
grp_chart = 'Chart'
show_gap_box      = input.bool(true,  'Show gap zone box',          group = grp_chart)
show_25_line      = input.bool(true,  'Show 25% line',              group = grp_chart)
show_50_line      = input.bool(true,  'Show 50% line',              group = grp_chart)
show_75_line      = input.bool(true,  'Show 75% line',              group = grp_chart)
show_pc_line      = input.bool(true,  'Show prev close line',       group = grp_chart)
show_labels       = input.bool(true,  'Show labels',                group = grp_chart)
show_bounce_label = input.bool(false, 'Show bounce label',          group = grp_chart)
show_100_label    = input.bool(false, 'Show 100% fill label',       group = grp_chart)
extend_lines      = input.bool(false, 'Extend lines right',         group = grp_chart)
box_width_bars    = input.int(8,      'Gap box width (bars)',        group = grp_chart, minval = 1, maxval = 200)
line_ext_bars     = input.int(20,     'Line extend (bars)',          group = grp_chart, minval = 1, maxval = 500)
max_days_show     = input.int(10,     'Show last N zones (0=all)',   group = grp_chart, minval = 0)

// ─── Inputs: Table ────────────────────────────────────────────────────────────
grp_table = 'Table'
show_table       = input.bool(true,  'Show stats table',            group = grp_table)
show_dir_up      = input.bool(true,  'Show GAP UP stats',           group = grp_table, tooltip = 'Turn off on gap-down days to hide UP column/rows and shrink the table')
show_dir_dn      = input.bool(true,  'Show GAP DN stats',           group = grp_table, tooltip = 'Turn off on gap-up days to hide DN column/rows and shrink the table')
show_25_stat     = input.bool(true,  'Show 25% fill row',           group = grp_table)
show_50_stat     = input.bool(true,  'Show 50% fill row',           group = grp_table)
show_75_stat     = input.bool(true,  'Show 75% fill row',           group = grp_table)
show_100_stat    = input.bool(true,  'Show 100% fill row',          group = grp_table)
show_bounce_stat = input.bool(false, 'Show bounce stat row',        group = grp_table)
show_cont_stat   = input.bool(false, 'Show cont to 100% row',       group = grp_table)
show_25_75_dow   = input.bool(true,  'Show DOW 25%/75% block',      group = grp_table)
show_size_bkt    = input.bool(true,  'Show gap size breakdown',     group = grp_table)
sz_small_max_pts = input.float(25.0, 'Small gap max ($)',           group = grp_table, minval = 0.1, tooltip = 'Used when unit = Dollar. Gaps up to this size = Small')
sz_large_min_pts = input.float(50.0, 'Large gap min ($)',           group = grp_table, minval = 0.1, tooltip = 'Used when unit = Dollar. Gaps at or above this size = Large')
sz_small_max_pct = input.float(0.30, 'Small gap max (%)',           group = grp_table, minval = 0.01, tooltip = 'Used when unit = Percent. Gaps up to this size = Small')
sz_large_min_pct = input.float(0.65, 'Large gap min (%)',           group = grp_table, minval = 0.01, tooltip = 'Used when unit = Percent. Gaps at or above this size = Large')
sz_bkt_25        = input.bool(true,  'Size breakdown: 25%',         group = grp_table)
sz_bkt_50        = input.bool(true,  'Size breakdown: 50%',         group = grp_table)
sz_bkt_75        = input.bool(true,  'Size breakdown: 75%',         group = grp_table)
sz_bkt_100       = input.bool(true,  'Size breakdown: 100%',        group = grp_table)
tbl_pos_str      = input.string('Top Right', 'Table position',      group = grp_table, options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'])
tbl_sz_str       = input.string('Normal', 'Table text size',        group = grp_table, options = ['Tiny', 'Small', 'Normal', 'Large'])

// ─── Inputs: Table Color Scheme ───────────────────────────────────────────────
grp_tablecolor = 'Table Color Scheme'
tbl_theme = input.string('Classic', 'Table Theme', group = grp_tablecolor,
     options = ['Classic', 'Blue/Orange', 'Monochrome', 'Custom'],
     tooltip = 'Classic = green/red. Blue/Orange = high-contrast blue/orange palette. Monochrome = greyscale. Custom = pick every color below.')

// Custom structural colors (only used when theme = Custom)
c_hdr_in    = input.color(#080808,  'Custom: Header bg',      group = grp_tablecolor, inline = 'cc1')
c_sub_in    = input.color(#131313,  'Custom: Subheader bg',   group = grp_tablecolor, inline = 'cc1')
c_row_in    = input.color(#0a0a0a,  'Custom: Row bg',         group = grp_tablecolor, inline = 'cc2')
c_alt_in    = input.color(#111111,  'Custom: Alt row bg',     group = grp_tablecolor, inline = 'cc2')
c_txt_in    = input.color(#ffffff,  'Custom: Text',           group = grp_tablecolor, inline = 'cc3')
c_mut_in    = input.color(#9e9e9e,  'Custom: Muted text',     group = grp_tablecolor, inline = 'cc3')
c_up_in     = input.color(#66bb6a,  'Custom: Gap up text',    group = grp_tablecolor, inline = 'cc4')
c_dn_in     = input.color(#ef5350,  'Custom: Gap down text',  group = grp_tablecolor, inline = 'cc4')
c_amb_in    = input.color(#7cb342,  'Custom: Amber/accent',   group = grp_tablecolor, inline = 'cc5')
// Custom heat-map tiers (fill % cells)
c_heat_hi_in   = input.color(#1b5e20, 'Custom heat: ≥80%',    group = grp_tablecolor, inline = 'ch1')
c_heat_mid_in  = input.color(#558b2f, 'Custom heat: ≥60%',    group = grp_tablecolor, inline = 'ch1')
c_heat_low_in  = input.color(#7f0000, 'Custom heat: <60%',    group = grp_tablecolor, inline = 'ch2')
c_heat_none_in = input.color(#0a0a0a,'Custom heat: no data',  group = grp_tablecolor, inline = 'ch2')

// ─── Inputs: General ──────────────────────────────────────────────────────────
grp_gen = 'General'
gap_unit       = input.string('Dollar', 'Gap measurement unit', group = grp_gen, options = ['Dollar', 'Percent'], tooltip = 'Dollar: fixed $/pt cutoffs (retune per ticker/price level). Percent: self-scaling as price drifts — no retuning needed across tickers or over time.')
min_gap_pts    = input.float(10.0, 'Min gap size ($)',            group = grp_gen, minval = 0.0, tooltip = 'Used when unit = Dollar. SPX: 10pts | SPY: 1pt | QQQ: 0.75pt')
min_gap_pct    = input.float(0.15, 'Min gap size (%)',            group = grp_gen, minval = 0.0, tooltip = 'Used when unit = Percent. ~0.15% is roughly 1pt on SPY at current levels.')
lookback_days  = input.int(0,     'Stat lookback days (0=all)',   group = grp_gen, minval = 0)
bounce_bars    = input.int(10,    'Bounce look-forward bars',     group = grp_gen, minval = 1, maxval = 100)
bounce_min_pts = input.float(8.0, 'Bounce min move (pts)',        group = grp_gen, minval = 0.0, tooltip = 'SPX: 10pts | SPY: 1pt | QQQ: 1pt')

// ─── Inputs: Colors (chart zones) ─────────────────────────────────────────────
grp_style = 'Colors'
col_gap_up = input.color(color.new(#2e7d32, 80), 'Gap up zone',         group = grp_style)
col_gap_dn = input.color(color.new(#8b0000, 80), 'Gap down zone',       group = grp_style)
col_50_up  = input.color(#2e7d32,                '50% target (gap up)', group = grp_style)
col_50_dn  = input.color(#8b0000,                '50% target (gap dn)', group = grp_style)
col_25_up  = input.color(color.new(#66bb6a, 40), '25% target (gap up)', group = grp_style)
col_25_dn  = input.color(color.new(#ef9a9a, 40), '25% target (gap dn)', group = grp_style)
col_75_up  = input.color(color.new(#a5d6a7, 20), '75% target (gap up)', group = grp_style)
col_75_dn  = input.color(color.new(#ef5350, 40), '75% target (gap dn)', group = grp_style)
col_pc     = input.color(color.new(#9e9e9e, 0),  'Prev RTH close',      group = grp_style)

t_pos  = tbl_pos_str == 'Top Right' ? position.top_right : tbl_pos_str == 'Top Left' ? position.top_left : tbl_pos_str == 'Bottom Right' ? position.bottom_right : position.bottom_left
tbl_sz = tbl_sz_str == 'Tiny' ? size.tiny : tbl_sz_str == 'Small' ? size.small : tbl_sz_str == 'Large' ? size.large : size.normal

is_pct = gap_unit == 'Percent'
unit_suffix = is_pct ? '%' : 'pt'

// ─── Resolve table palette from theme ─────────────────────────────────────────
get_chrome() =>
    switch tbl_theme
        'Classic'         => [#080808, #131313, #0a0a0a, #111111, #ffffff, #9e9e9e, #66bb6a, #ef5350, #7cb342]
        'Blue/Orange' => [#080808, #131313, #0a0a0a, #111111, #ffffff, #9e9e9e, #F0E442, #CC79A7, #009E73]
        'Monochrome'      => [#080808, #1a1a1a, #1e1e1e, #282828, #ffffff, #9e9e9e, #d0d0d0, #707070, #a0a0a0]
        => [c_hdr_in, c_sub_in, c_row_in, c_alt_in, c_txt_in, c_mut_in, c_up_in, c_dn_in, c_amb_in]

get_heat() =>
    switch tbl_theme
        'Classic'         => [#1b5e20, #558b2f, #7f0000, #0a0a0a]
        'Blue/Orange' => [#0072B2, #8a8a8a, #E69F00, #0a0a0a]
        'Monochrome'      => [#505050, #2e2e2e, #1a1a1a, #0a0a0a]
        => [c_heat_hi_in, c_heat_mid_in, c_heat_low_in, c_heat_none_in]

// ─── Dynamic column/row counts ────────────────────────────────────────────────
_dow_cols    = 1 + (show_25_stat ? 1 : 0) + (show_50_stat ? 1 : 0) + (show_75_stat ? 1 : 0) + (show_100_stat ? 1 : 0)
_sz_cols     = 1 + (sz_bkt_25 ? 1 : 0) + (sz_bkt_50 ? 1 : 0) + (sz_bkt_75 ? 1 : 0) + (sz_bkt_100 ? 1 : 0)
NCOLS        = math.max(4, math.max(_dow_cols, _sz_cols))
_fill_rows   = (show_25_stat ? 1 : 0) + (show_50_stat ? 1 : 0) + (show_75_stat ? 1 : 0) + (show_100_stat ? 1 : 0)
_after50_rows = show_50_stat ? 1 + (show_bounce_stat ? 1 : 0) + (show_cont_stat ? 1 : 0) : 0
_dow25_rows  = show_25_75_dow ? (show_dir_up ? 6 : 0) + (show_dir_dn ? 6 : 0) : 0
_sz_bkt_rows = show_size_bkt ? 4 : 0
TOTAL_ROWS   = 1 + 1 + _fill_rows + _after50_rows + _dow25_rows + _sz_bkt_rows + 4

// ─── Session detection ────────────────────────────────────────────────────────
session_tz    = 'America/New_York'
sess_string   = '0930-1600'
in_rth_window = not na(time('1', sess_string, session_tz))
new_day       = ta.change(time('D', session_tz)) != 0
is_first_bar  = new_day and in_rth_window

// ─── Prev RTH close ───────────────────────────────────────────────────────────
rth_daily_close = request.security(syminfo.tickerid, 'D', close[1], lookahead = barmerge.lookahead_on)

// ─── State variables ─────────────────────────────────────────────────────────
var float prev_close    = na
var float gap_size_raw  = na   // always dollar gap — used for chart price levels
var float gap_size      = na   // dollar OR percent, per gap_unit — used for classification/min-gap
var float target_25     = na
var float target_50     = na
var float target_75     = na
var bool  gap_up        = false
var bool  filled_25     = false
var bool  filled        = false
var bool  filled_75     = false
var int   fill_bar      = na
var bool  full_filled   = false
var bool  bounced       = false

// ─── Effective thresholds (branch once per bar) ───────────────────────────────
min_gap      = is_pct ? min_gap_pct    : min_gap_pts
sz_small_max = is_pct ? sz_small_max_pct : sz_small_max_pts
sz_large_min = is_pct ? sz_large_min_pct : sz_large_min_pts

// ─── Session log arrays ───────────────────────────────────────────────────────
// NOTE: these are populated ONLY from the is_first_bar block below, which fires
// exactly once per completed day (when the next day's first bar opens). There is
// deliberately no separate "log today" push on barstate.islast: the in-progress
// day's own state (gap_size, filled_25, filled, filled_75, full_filled) is read
// directly by the TODAY row elsewhere, so it never needs to be in this array.
// Logging it there as well, every tick, was the source of duplicate same-day
// entries in earlier versions. An in-progress session is correctly excluded from
// the aggregate stats until it finalizes.
var array<string> log_dir  = array.new<string>()
var array<bool>   log_f25  = array.new<bool>()
var array<bool>   log_f50  = array.new<bool>()
var array<bool>   log_f75  = array.new<bool>()
var array<bool>   log_f100 = array.new<bool>()
var array<bool>   log_bnc  = array.new<bool>()
var array<float>  log_gap  = array.new<float>()
var array<int>    log_dw   = array.new<int>()
var array<int>    log_time = array.new<int>()

// ─── Drawing arrays ───────────────────────────────────────────────────────────
var array<box>   gap_boxes    = array.new<box>()
var array<line>  pc_lines     = array.new<line>()
var array<line>  target_lines = array.new<line>()
var array<label> all_labels   = array.new<label>()

// ─── Purge old drawings ───────────────────────────────────────────────────────
if is_first_bar and max_days_show > 0
    while array.size(gap_boxes)    > max_days_show
        box.delete(array.shift(gap_boxes))
    while array.size(pc_lines)     > max_days_show
        line.delete(array.shift(pc_lines))
    while array.size(target_lines) > max_days_show * 3
        line.delete(array.shift(target_lines))
    while array.size(all_labels)   > max_days_show * 5
        label.delete(array.shift(all_labels))

// ─── On RTH open ─────────────────────────────────────────────────────────────
if is_first_bar
    if not na(gap_size)
        array.push(log_dir,  gap_size > 0 ? 'UP' : 'DN')
        array.push(log_f25,  filled_25)
        array.push(log_f50,  filled)
        array.push(log_f75,  filled_75)
        array.push(log_f100, full_filled)
        array.push(log_bnc,  bounced)
        array.push(log_gap,  math.abs(gap_size))
        array.push(log_dw,   dayofweek[1])
        array.push(log_time, math.round(time[1] / 86400000) * 86400000)

    prev_close   := rth_daily_close
    gap_size_raw := open - rth_daily_close
    gap_size     := is_pct and rth_daily_close != 0 ? gap_size_raw / rth_daily_close * 100 : gap_size_raw
    target_25    := open - gap_size_raw * 0.25
    target_50    := open - gap_size_raw * 0.50
    target_75    := open - gap_size_raw * 0.75
    gap_up       := gap_size_raw > 0
    filled_25    := false
    filled       := false
    filled_75    := false
    fill_bar     := na
    full_filled  := false
    bounced      := false

    if not na(prev_close) and math.abs(gap_size) >= min_gap
        lc50     = gap_up ? col_50_up : col_50_dn
        lc25     = gap_up ? col_25_up : col_25_dn
        lc75     = gap_up ? col_75_up : col_75_dn
        border_c = gap_up ? color.new(#2e7d32, 25) : color.new(#8b0000, 25)
        ext_r    = extend_lines ? extend.right : extend.none

        if show_gap_box
            b = box.new(bar_index, math.max(open, prev_close), bar_index + box_width_bars, math.min(open, prev_close), border_color = border_c, border_width = 2, bgcolor = gap_up ? col_gap_up : col_gap_dn)
            array.push(gap_boxes, b)
        if show_pc_line
            l = line.new(bar_index, prev_close, bar_index + line_ext_bars, prev_close, color = col_pc, width = 2, style = line.style_dashed, extend = ext_r)
            array.push(pc_lines, l)
        if show_25_line
            l25 = line.new(bar_index, target_25, bar_index + line_ext_bars, target_25, color = lc25, width = 1, style = line.style_dotted, extend = ext_r)
            array.push(target_lines, l25)
            if show_labels
                array.push(all_labels, label.new(bar_index, target_25, text = '25%: ' + str.tostring(target_25, format.mintick), style = label.style_label_right, color = color.new(lc25, 55), textcolor = color.white, size = size.small))
        if show_50_line
            l50 = line.new(bar_index, target_50, bar_index + line_ext_bars, target_50, color = lc50, width = 2, style = line.style_solid, extend = ext_r)
            array.push(target_lines, l50)
            if show_labels
                dir_str = gap_up ? ' ▲ Gap Up' : ' ▼ Gap Dn'
                array.push(all_labels, label.new(bar_index, target_50, text = '50%: ' + str.tostring(target_50, format.mintick) + dir_str, style = label.style_label_right, color = color.new(lc50, 65), textcolor = color.white, size = size.normal))
        if show_75_line
            l75 = line.new(bar_index, target_75, bar_index + line_ext_bars, target_75, color = lc75, width = 1, style = line.style_dotted, extend = ext_r)
            array.push(target_lines, l75)
            if show_labels
                array.push(all_labels, label.new(bar_index, target_75, text = '75%: ' + str.tostring(target_75, format.mintick), style = label.style_label_right, color = color.new(lc75, 55), textcolor = color.white, size = size.small))

// ─── Fill detection ───────────────────────────────────────────────────────────
if in_rth_window and not na(target_50) and math.abs(gap_size) >= min_gap
    if not filled_25
        if gap_up and low <= target_25
            filled_25 := true
        if not gap_up and high >= target_25
            filled_25 := true
    if not filled
        if gap_up and low <= target_50
            filled   := true
            fill_bar := bar_index
        if not gap_up and high >= target_50
            filled   := true
            fill_bar := bar_index
    if not filled_75
        if gap_up and low <= target_75
            filled_75 := true
        if not gap_up and high >= target_75
            filled_75 := true

// ─── Fill labels ──────────────────────────────────────────────────────────────
if filled_25 and not filled_25[1] and show_labels
    lc25 = gap_up ? col_25_up : col_25_dn
    array.push(all_labels, label.new(bar_index, target_25, text = '✓ 25%', style = gap_up ? label.style_label_up : label.style_label_down, color = color.new(lc25, 35), textcolor = color.white, size = size.small))

if not na(fill_bar) and bar_index == fill_bar and show_labels
    lc50   = gap_up ? col_50_up : col_50_dn
    offset = (high - low) * 0.15
    array.push(all_labels, label.new(bar_index, gap_up ? target_50 - offset : target_50 + offset, text = '✓ 50%', style = gap_up ? label.style_label_up : label.style_label_down, color = color.new(lc50, 35), textcolor = color.white, size = size.normal))

if filled_75 and not filled_75[1] and show_labels
    lc75 = gap_up ? col_75_up : col_75_dn
    array.push(all_labels, label.new(bar_index, target_75, text = '✓ 75%', style = gap_up ? label.style_label_up : label.style_label_down, color = color.new(lc75, 35), textcolor = color.white, size = size.small))

// ─── Bounce detection ─────────────────────────────────────────────────────────
if in_rth_window and filled and not bounced and not na(fill_bar)
    if bar_index - fill_bar <= bounce_bars
        if gap_up and high >= target_50 + bounce_min_pts
            bounced := true
        if not gap_up and low <= target_50 - bounce_min_pts
            bounced := true

if bounced and not bounced[1] and show_labels and show_bounce_label
    b_y = gap_up ? high + (high - low) * 0.5 : low - (high - low) * 0.5
    array.push(all_labels, label.new(bar_index, b_y, text = '↩ BOUNCE', style = gap_up ? label.style_label_down : label.style_label_up, color = color.new(#7cb342, 25), textcolor = color.white, size = size.small))

// ─── 100% fill detection ──────────────────────────────────────────────────────
if in_rth_window and filled and not full_filled and not na(prev_close)
    if gap_up and low <= prev_close
        full_filled := true
    if not gap_up and high >= prev_close
        full_filled := true

if full_filled and not full_filled[1] and show_labels and show_100_label
    array.push(all_labels, label.new(bar_index, prev_close, text = '100% FILL', style = gap_up ? label.style_label_up : label.style_label_down, color = color.new(col_pc, 15), textcolor = color.white, size = size.small))

// ─── Stat accumulators ────────────────────────────────────────────────────────
var int tot = 0
f25 = 0
f50 = 0
f75 = 0
f100 = 0
bnc = 0
up_n = 0
dn_n = 0

// ─── Gap size bucket accumulators [0=small, 1=med, 2=large] ──────────────────
var array<int> bkt_n      = array.new<int>(3, 0)
var array<int> bkt_up_n   = array.new<int>(3, 0)
var array<int> bkt_dn_n   = array.new<int>(3, 0)
var array<int> bkt_f25    = array.new<int>(3, 0)
var array<int> bkt_f50    = array.new<int>(3, 0)
var array<int> bkt_f75    = array.new<int>(3, 0)
var array<int> bkt_f100   = array.new<int>(3, 0)
var array<int> bkt_up_f25 = array.new<int>(3, 0)
var array<int> bkt_up_f50 = array.new<int>(3, 0)
var array<int> bkt_up_f75 = array.new<int>(3, 0)
var array<int> bkt_up_f100= array.new<int>(3, 0)
var array<int> bkt_dn_f25 = array.new<int>(3, 0)
var array<int> bkt_dn_f50 = array.new<int>(3, 0)
var array<int> bkt_dn_f75 = array.new<int>(3, 0)
var array<int> bkt_dn_f100= array.new<int>(3, 0)

up_f25  = 0
dn_f25  = 0
up_f50  = 0
dn_f50  = 0
up_f75  = 0
dn_f75  = 0
up_f100 = 0
dn_f100 = 0
bnc_up  = 0
bnc_dn  = 0
baf     = 0
baf_up  = 0
baf_dn  = 0
total_sessions = 0

var array<int> dw_tot      = array.new<int>(5, 0)
var array<int> dw_up_n     = array.new<int>(5, 0)
var array<int> dw_dn_n     = array.new<int>(5, 0)
var array<int> dw_f25      = array.new<int>(5, 0)
var array<int> dw_up_f25   = array.new<int>(5, 0)
var array<int> dw_dn_f25   = array.new<int>(5, 0)
var array<int> dw_f50      = array.new<int>(5, 0)
var array<int> dw_up_f50   = array.new<int>(5, 0)
var array<int> dw_dn_f50   = array.new<int>(5, 0)
var array<int> dw_f75      = array.new<int>(5, 0)
var array<int> dw_up_f75   = array.new<int>(5, 0)
var array<int> dw_dn_f75   = array.new<int>(5, 0)
var array<int> dw_f100     = array.new<int>(5, 0)
var array<int> dw_up_f100  = array.new<int>(5, 0)
var array<int> dw_dn_f100  = array.new<int>(5, 0)
var array<int> dw_bnc      = array.new<int>(5, 0)

if barstate.islast
    tot            := 0
    f25            := 0
    f50            := 0
    f75            := 0
    f100           := 0
    bnc            := 0
    up_n           := 0
    dn_n           := 0
    total_sessions := 0
    up_f25         := 0
    dn_f25         := 0
    up_f50         := 0
    dn_f50         := 0
    up_f75         := 0
    dn_f75         := 0
    up_f100        := 0
    dn_f100        := 0
    bnc_up         := 0
    bnc_dn         := 0
    baf            := 0
    baf_up         := 0
    baf_dn         := 0
    array.fill(bkt_n,      0)
    array.fill(bkt_up_n,   0)
    array.fill(bkt_dn_n,   0)
    array.fill(bkt_f25,    0)
    array.fill(bkt_f50,    0)
    array.fill(bkt_f75,    0)
    array.fill(bkt_f100,   0)
    array.fill(bkt_up_f25, 0)
    array.fill(bkt_up_f50, 0)
    array.fill(bkt_up_f75, 0)
    array.fill(bkt_up_f100,0)
    array.fill(bkt_dn_f25, 0)
    array.fill(bkt_dn_f50, 0)
    array.fill(bkt_dn_f75, 0)
    array.fill(bkt_dn_f100,0)
    array.fill(dw_tot,     0)
    array.fill(dw_up_n,    0)
    array.fill(dw_dn_n,    0)
    array.fill(dw_f25,     0)
    array.fill(dw_up_f25,  0)
    array.fill(dw_dn_f25,  0)
    array.fill(dw_f50,     0)
    array.fill(dw_up_f50,  0)
    array.fill(dw_dn_f50,  0)
    array.fill(dw_f75,     0)
    array.fill(dw_up_f75,  0)
    array.fill(dw_dn_f75,  0)
    array.fill(dw_f100,    0)
    array.fill(dw_up_f100, 0)
    array.fill(dw_dn_f100, 0)
    array.fill(dw_bnc,     0)

    sz    = array.size(log_gap)
    start = lookback_days > 0 ? math.max(0, sz - lookback_days) : 0

    for i = start to sz - 1
        ga  = array.get(log_gap, i)
        total_sessions := total_sessions + 1
        if ga >= min_gap
            d    = array.get(log_dir,  i)
            s25  = array.get(log_f25,  i)
            s50  = array.get(log_f50,  i)
            s75  = array.get(log_f75,  i)
            s100 = array.get(log_f100, i)
            sb   = array.get(log_bnc,  i)
            dw   = array.get(log_dw,   i)
            di   = dw == 2 ? 0 : dw == 3 ? 1 : dw == 4 ? 2 : dw == 5 ? 3 : 4
            isup = d == 'UP'

            tot := tot + 1
            array.set(dw_tot, di, array.get(dw_tot, di) + 1)
            if isup
                up_n := up_n + 1
                array.set(dw_up_n, di, array.get(dw_up_n, di) + 1)
            else
                dn_n := dn_n + 1
                array.set(dw_dn_n, di, array.get(dw_dn_n, di) + 1)

            if s25
                f25 := f25 + 1
                array.set(dw_f25, di, array.get(dw_f25, di) + 1)
                if isup
                    up_f25 := up_f25 + 1
                    array.set(dw_up_f25, di, array.get(dw_up_f25, di) + 1)
                else
                    dn_f25 := dn_f25 + 1
                    array.set(dw_dn_f25, di, array.get(dw_dn_f25, di) + 1)

            if s50
                f50 := f50 + 1
                array.set(dw_f50, di, array.get(dw_f50, di) + 1)
                if isup
                    up_f50 := up_f50 + 1
                    array.set(dw_up_f50, di, array.get(dw_up_f50, di) + 1)
                else
                    dn_f50 := dn_f50 + 1
                    array.set(dw_dn_f50, di, array.get(dw_dn_f50, di) + 1)
                if sb
                    bnc := bnc + 1
                    array.set(dw_bnc, di, array.get(dw_bnc, di) + 1)
                    if isup
                        bnc_up := bnc_up + 1
                    else
                        bnc_dn := bnc_dn + 1

            if s75
                f75 := f75 + 1
                array.set(dw_f75, di, array.get(dw_f75, di) + 1)
                if isup
                    up_f75 := up_f75 + 1
                    array.set(dw_up_f75, di, array.get(dw_up_f75, di) + 1)
                else
                    dn_f75 := dn_f75 + 1
                    array.set(dw_dn_f75, di, array.get(dw_dn_f75, di) + 1)

            if s100
                f100 := f100 + 1
                array.set(dw_f100, di, array.get(dw_f100, di) + 1)
                if isup
                    up_f100 := up_f100 + 1
                    array.set(dw_up_f100, di, array.get(dw_up_f100, di) + 1)
                else
                    dn_f100 := dn_f100 + 1
                    array.set(dw_dn_f100, di, array.get(dw_dn_f100, di) + 1)
                if s50 and sb
                    baf := baf + 1
                    if isup
                        baf_up := baf_up + 1
                    else
                        baf_dn := baf_dn + 1

            // ── Gap size bucket counting ──────────────────────────────────
            _bi = ga < sz_small_max ? 0 : ga < sz_large_min ? 1 : 2
            array.set(bkt_n, _bi, array.get(bkt_n, _bi) + 1)
            if isup
                array.set(bkt_up_n, _bi, array.get(bkt_up_n, _bi) + 1)
            else
                array.set(bkt_dn_n, _bi, array.get(bkt_dn_n, _bi) + 1)
            if s25
                array.set(bkt_f25, _bi, array.get(bkt_f25, _bi) + 1)
                if isup
                    array.set(bkt_up_f25, _bi, array.get(bkt_up_f25, _bi) + 1)
                else
                    array.set(bkt_dn_f25, _bi, array.get(bkt_dn_f25, _bi) + 1)
            if s50
                array.set(bkt_f50, _bi, array.get(bkt_f50, _bi) + 1)
                if isup
                    array.set(bkt_up_f50, _bi, array.get(bkt_up_f50, _bi) + 1)
                else
                    array.set(bkt_dn_f50, _bi, array.get(bkt_dn_f50, _bi) + 1)
            if s75
                array.set(bkt_f75, _bi, array.get(bkt_f75, _bi) + 1)
                if isup
                    array.set(bkt_up_f75, _bi, array.get(bkt_up_f75, _bi) + 1)
                else
                    array.set(bkt_dn_f75, _bi, array.get(bkt_dn_f75, _bi) + 1)
            if s100
                array.set(bkt_f100, _bi, array.get(bkt_f100, _bi) + 1)
                if isup
                    array.set(bkt_up_f100, _bi, array.get(bkt_up_f100, _bi) + 1)
                else
                    array.set(bkt_dn_f100, _bi, array.get(bkt_dn_f100, _bi) + 1)

// ─── Stats table ─────────────────────────────────────────────────────────────
if show_table and barstate.islast
    t = table.new(t_pos, NCOLS, TOTAL_ROWS, bgcolor = #0a0a0a, border_color = #1a1a1a, border_width = 1, frame_color = #222222, frame_width = 1)

    [c_hdr, c_sub, c_row, c_alt, c_txt, c_mut, c_up, c_dn, c_amb] = get_chrome()
    [c_heat_hi, c_heat_mid, c_heat_low, c_heat_none] = get_heat()
    c_wht = #ffffff

    r = 0

    // ── Row 0: title + info ───────────────────────────────────────────────
    _sz        = array.size(log_time)
    _start_idx = lookback_days > 0 ? math.max(0, _sz - lookback_days) : 0
    _first_t   = _sz > 0 ? array.get(log_time, _start_idx) : na
    _last_t    = _sz > 0 ? array.get(log_time, _sz - 1) : na
    _date_from = not na(_first_t) ? str.format('{0,date,MMM d \'\'yy}', _first_t) : '—'
    _date_to   = not na(_last_t)  ? str.format('{0,date,MMM d \'\'yy}', _last_t)  : '—'
    _freq_pct  = total_sessions > 0 ? math.round(tot / total_sessions * 100) : 0
    _lb_str    = lookback_days > 0 ? 'last ' + str.tostring(lookback_days) + 'd' : 'all hist'
    _min_gap_str = str.tostring(min_gap, is_pct ? '#.##' : '#.#') + unit_suffix
    _sess_str  = str.tostring(tot) + '/' + str.tostring(total_sessions) + ' (' + str.tostring(_freq_pct) + '%≥' + _min_gap_str + ')'
    _span_str  = _date_from + '–' + _date_to + ' ' + _lb_str
    table.cell(t, 0, r, 'OVERNIGHT GAP', text_color = c_wht, bgcolor = c_hdr, text_size = tbl_sz, text_halign = text.align_left)
    table.cell(t, 1, r, '',              text_color = c_wht, bgcolor = c_hdr, text_size = size.tiny)
    table.cell(t, 2, r, _sess_str,       text_color = c_wht, bgcolor = c_hdr, text_size = tbl_sz, text_halign = text.align_right)
    table.cell(t, 3, r, _span_str,       text_color = c_wht, bgcolor = c_hdr, text_size = tbl_sz, text_halign = text.align_right)
    r := r + 1

    // ── Row 1: column labels ──────────────────────────────────────────────
    table.cell(t, 0, r, '',       text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_left)
    table.cell(t, 1, r, 'ALL',    text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
    if show_dir_up
        table.cell(t, 2, r, 'GAP UP', text_color = c_up, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
    else
        table.cell(t, 2, r, '', bgcolor = c_sub, text_size = tbl_sz)
    if show_dir_dn
        table.cell(t, 3, r, 'GAP DN', text_color = c_dn, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
    else
        table.cell(t, 3, r, '', bgcolor = c_sub, text_size = tbl_sz)
    r := r + 1

    // ── Fill level rows ───────────────────────────────────────────────────
    fc = 0
    if show_25_stat
        bg = fc % 2 == 0 ? c_row : c_alt
        table.cell(t, 0, r, '25% Fill',       text_color = c_txt, bgcolor = bg, text_size = tbl_sz, text_halign = text.align_left)
        table.cell(t, 1, r, pct_n(f25, tot),  text_color = c_wht, bgcolor = heat(f25, tot, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        if show_dir_up
            table.cell(t, 2, r, pct_n(up_f25, up_n), text_color = c_wht, bgcolor = heat(up_f25, up_n, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 2, r, '', bgcolor = bg, text_size = tbl_sz)
        if show_dir_dn
            table.cell(t, 3, r, pct_n(dn_f25, dn_n), text_color = c_wht, bgcolor = heat(dn_f25, dn_n, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 3, r, '', bgcolor = bg, text_size = tbl_sz)
        r := r + 1
        fc := fc + 1

    if show_50_stat
        bg = fc % 2 == 0 ? c_row : c_alt
        table.cell(t, 0, r, '50% Fill',       text_color = c_txt, bgcolor = bg, text_size = tbl_sz, text_halign = text.align_left)
        table.cell(t, 1, r, pct_n(f50, tot),  text_color = c_wht, bgcolor = heat(f50, tot, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        if show_dir_up
            table.cell(t, 2, r, pct_n(up_f50, up_n), text_color = c_wht, bgcolor = heat(up_f50, up_n, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 2, r, '', bgcolor = bg, text_size = tbl_sz)
        if show_dir_dn
            table.cell(t, 3, r, pct_n(dn_f50, dn_n), text_color = c_wht, bgcolor = heat(dn_f50, dn_n, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 3, r, '', bgcolor = bg, text_size = tbl_sz)
        r := r + 1
        fc := fc + 1

    if show_75_stat
        bg = fc % 2 == 0 ? c_row : c_alt
        table.cell(t, 0, r, '75% Fill',       text_color = c_txt, bgcolor = bg, text_size = tbl_sz, text_halign = text.align_left)
        table.cell(t, 1, r, pct_n(f75, tot),  text_color = c_wht, bgcolor = heat(f75, tot, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        if show_dir_up
            table.cell(t, 2, r, pct_n(up_f75, up_n), text_color = c_wht, bgcolor = heat(up_f75, up_n, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 2, r, '', bgcolor = bg, text_size = tbl_sz)
        if show_dir_dn
            table.cell(t, 3, r, pct_n(dn_f75, dn_n), text_color = c_wht, bgcolor = heat(dn_f75, dn_n, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 3, r, '', bgcolor = bg, text_size = tbl_sz)
        r := r + 1
        fc := fc + 1

    if show_100_stat
        bg = fc % 2 == 0 ? c_row : c_alt
        table.cell(t, 0, r, '100% Fill',       text_color = c_txt, bgcolor = bg, text_size = tbl_sz, text_halign = text.align_left)
        table.cell(t, 1, r, pct_n(f100, tot),  text_color = c_wht, bgcolor = heat(f100, tot, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        if show_dir_up
            table.cell(t, 2, r, pct_n(up_f100, up_n), text_color = c_wht, bgcolor = heat(up_f100, up_n, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 2, r, '', bgcolor = bg, text_size = tbl_sz)
        if show_dir_dn
            table.cell(t, 3, r, pct_n(dn_f100, dn_n), text_color = c_wht, bgcolor = heat(dn_f100, dn_n, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 3, r, '', bgcolor = bg, text_size = tbl_sz)
        r := r + 1

    // ── AFTER 50% TOUCH section ───────────────────────────────────────────
    show_after50 = show_50_stat and (show_bounce_stat or show_cont_stat)
    if show_after50
        table.cell(t, 0, r, 'AFTER 50% TOUCH', text_color = c_amb, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_left)
        table.cell(t, 1, r, 'ALL',              text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
        if show_dir_up
            table.cell(t, 2, r, 'GAP UP', text_color = c_up, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 2, r, '', bgcolor = c_sub, text_size = tbl_sz)
        if show_dir_dn
            table.cell(t, 3, r, 'GAP DN', text_color = c_dn, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
        else
            table.cell(t, 3, r, '', bgcolor = c_sub, text_size = tbl_sz)
        r := r + 1
        ac = 0
        bounce_lbl = '↩ Bounce (' + str.tostring(bounce_bars) + 'b/' + str.tostring(bounce_min_pts) + 'pt)'
        if show_bounce_stat
            bg = ac % 2 == 0 ? c_row : c_alt
            table.cell(t, 0, r, bounce_lbl,           text_color = c_amb, bgcolor = bg, text_size = tbl_sz, text_halign = text.align_left)
            table.cell(t, 1, r, pct_n(bnc, f50),      text_color = c_wht, bgcolor = heat(bnc, f50, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
            if show_dir_up
                table.cell(t, 2, r, pct_n(bnc_up, up_f50), text_color = c_wht, bgcolor = heat(bnc_up, up_f50, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
            else
                table.cell(t, 2, r, '', bgcolor = bg, text_size = tbl_sz)
            if show_dir_dn
                table.cell(t, 3, r, pct_n(bnc_dn, dn_f50), text_color = c_wht, bgcolor = heat(bnc_dn, dn_f50, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
            else
                table.cell(t, 3, r, '', bgcolor = bg, text_size = tbl_sz)
            r := r + 1
            ac := ac + 1
        if show_cont_stat
            bg = ac % 2 == 0 ? c_row : c_alt
            table.cell(t, 0, r, '→ Cont to 100%',       text_color = c_txt, bgcolor = bg, text_size = tbl_sz, text_halign = text.align_left)
            table.cell(t, 1, r, pct_n(f100, f50),        text_color = c_wht, bgcolor = heat(f100, f50, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
            if show_dir_up
                table.cell(t, 2, r, pct_n(up_f100, up_f50), text_color = c_wht, bgcolor = heat(up_f100, up_f50, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
            else
                table.cell(t, 2, r, '', bgcolor = bg, text_size = tbl_sz)
            if show_dir_dn
                table.cell(t, 3, r, pct_n(dn_f100, dn_f50), text_color = c_wht, bgcolor = heat(dn_f100, dn_f50, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
            else
                table.cell(t, 3, r, '', bgcolor = bg, text_size = tbl_sz)
            r := r + 1

    // ── DOW UP/DN split blocks ────────────────────────────────────────────
    dow_names = array.from('Mon', 'Tue', 'Wed', 'Thu', 'Fri')

    if show_25_75_dow
        // GAP UP block
        if show_dir_up
            table.cell(t, 0, r, 'DOW — GAP UP', text_color = c_up, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_left)
            dc = 1
            if show_25_stat
                table.cell(t, dc, r, '▲25%',  text_color = c_up, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
                dc := dc + 1
            if show_50_stat
                table.cell(t, dc, r, '▲50%',  text_color = c_up, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
                dc := dc + 1
            if show_75_stat
                table.cell(t, dc, r, '▲75%',  text_color = c_up, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
                dc := dc + 1
            if show_100_stat
                table.cell(t, dc, r, '▲100%', text_color = c_up, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
            r := r + 1

            for i = 0 to 4
                rn  = i % 2 == 0 ? c_row : c_alt
                nut = array.get(dw_up_n, i)
                table.cell(t, 0, r, array.get(dow_names, i), text_color = c_txt, bgcolor = rn, text_size = tbl_sz, text_halign = text.align_left)
                dc := 1
                if show_25_stat
                    nf = array.get(dw_up_f25, i)
                    table.cell(t, dc, r, pct_n(nf, nut), text_color = c_wht, bgcolor = heat(nf, nut, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                    dc := dc + 1
                if show_50_stat
                    nf = array.get(dw_up_f50, i)
                    table.cell(t, dc, r, pct_n(nf, nut), text_color = c_wht, bgcolor = heat(nf, nut, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                    dc := dc + 1
                if show_75_stat
                    nf = array.get(dw_up_f75, i)
                    table.cell(t, dc, r, pct_n(nf, nut), text_color = c_wht, bgcolor = heat(nf, nut, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                    dc := dc + 1
                if show_100_stat
                    nf = array.get(dw_up_f100, i)
                    table.cell(t, dc, r, pct_n(nf, nut), text_color = c_wht, bgcolor = heat(nf, nut, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                r := r + 1

        // GAP DN block
        if show_dir_dn
            table.cell(t, 0, r, 'DOW — GAP DN', text_color = c_dn, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_left)
            dc2 = 1
            if show_25_stat
                table.cell(t, dc2, r, '▼25%',  text_color = c_dn, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
                dc2 := dc2 + 1
            if show_50_stat
                table.cell(t, dc2, r, '▼50%',  text_color = c_dn, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
                dc2 := dc2 + 1
            if show_75_stat
                table.cell(t, dc2, r, '▼75%',  text_color = c_dn, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
                dc2 := dc2 + 1
            if show_100_stat
                table.cell(t, dc2, r, '▼100%', text_color = c_dn, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
            r := r + 1

            for i = 0 to 4
                rn  = i % 2 == 0 ? c_row : c_alt
                ndt = array.get(dw_dn_n, i)
                table.cell(t, 0, r, array.get(dow_names, i), text_color = c_txt, bgcolor = rn, text_size = tbl_sz, text_halign = text.align_left)
                dc2 := 1
                if show_25_stat
                    nf = array.get(dw_dn_f25, i)
                    table.cell(t, dc2, r, pct_n(nf, ndt), text_color = c_wht, bgcolor = heat(nf, ndt, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                    dc2 := dc2 + 1
                if show_50_stat
                    nf = array.get(dw_dn_f50, i)
                    table.cell(t, dc2, r, pct_n(nf, ndt), text_color = c_wht, bgcolor = heat(nf, ndt, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                    dc2 := dc2 + 1
                if show_75_stat
                    nf = array.get(dw_dn_f75, i)
                    table.cell(t, dc2, r, pct_n(nf, ndt), text_color = c_wht, bgcolor = heat(nf, ndt, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                    dc2 := dc2 + 1
                if show_100_stat
                    nf = array.get(dw_dn_f100, i)
                    table.cell(t, dc2, r, pct_n(nf, ndt), text_color = c_wht, bgcolor = heat(nf, ndt, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                r := r + 1

    // ── Gap size breakdown (optional) ─────────────────────────────────────
    if show_size_bkt
        _small_lbl = str.tostring(sz_small_max, is_pct ? '#.##' : '#.#') + unit_suffix
        _large_lbl = str.tostring(sz_large_min, is_pct ? '#.##' : '#.#') + unit_suffix
        bkt_labels = array.from(
             'Small (<'  + _small_lbl + ')',
             'Med ('     + _small_lbl + '–' + _large_lbl + ')',
             'Large (≥'  + _large_lbl + ')')

        table.cell(t, 0, r, 'GAP SIZE', text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_left)
        sdc = 1
        if sz_bkt_25
            table.cell(t, sdc, r, '25%',  text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
            sdc := sdc + 1
        if sz_bkt_50
            table.cell(t, sdc, r, '50%',  text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
            sdc := sdc + 1
        if sz_bkt_75
            table.cell(t, sdc, r, '75%',  text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
            sdc := sdc + 1
        if sz_bkt_100
            table.cell(t, sdc, r, '100%', text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
        r := r + 1

        for bi = 0 to 2
            rn = bi % 2 == 0 ? c_row : c_alt
            bn = array.get(bkt_n, bi)
            table.cell(t, 0, r, array.get(bkt_labels, bi), text_color = c_wht, bgcolor = rn, text_size = tbl_sz, text_halign = text.align_left)
            sdc = 1
            if sz_bkt_25
                nf = array.get(bkt_f25, bi)
                table.cell(t, sdc, r, pct_n(nf, bn), text_color = c_wht, bgcolor = heat(nf, bn, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                sdc := sdc + 1
            if sz_bkt_50
                nf = array.get(bkt_f50, bi)
                table.cell(t, sdc, r, pct_n(nf, bn), text_color = c_wht, bgcolor = heat(nf, bn, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                sdc := sdc + 1
            if sz_bkt_75
                nf = array.get(bkt_f75, bi)
                table.cell(t, sdc, r, pct_n(nf, bn), text_color = c_wht, bgcolor = heat(nf, bn, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
                sdc := sdc + 1
            if sz_bkt_100
                nf = array.get(bkt_f100, bi)
                table.cell(t, sdc, r, pct_n(nf, bn), text_color = c_wht, bgcolor = heat(nf, bn, c_heat_hi, c_heat_mid, c_heat_low, c_heat_none), text_size = tbl_sz, text_halign = text.align_center)
            r := r + 1

    // ── TODAY ─────────────────────────────────────────────────────────────
    today_dow = dayofweek == dayofweek.monday ? 'Mon' : dayofweek == dayofweek.tuesday ? 'Tue' : dayofweek == dayofweek.wednesday ? 'Wed' : dayofweek == dayofweek.thursday ? 'Thu' : 'Fri'
    has_gap   = not na(gap_size) and math.abs(gap_size) >= min_gap
    pend_str  = gap_up ? '▲' : '▼'

    table.cell(t, 0, r, 'TODAY',   text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_left)
    table.cell(t, 1, r, 'TARGET',  text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t, 2, r, 'GAP',     text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t, 3, r, 'STATUS',  text_color = c_wht, bgcolor = c_sub, text_size = tbl_sz, text_halign = text.align_center)
    r := r + 1

    tgt_str = has_gap ? str.tostring(target_50, format.mintick) : '—'
    gap_str = has_gap ? str.tostring(math.round(math.abs(gap_size) * 100) / 100) + unit_suffix : '—'
    gap_col = not na(gap_size) ? (gap_up ? c_up : c_dn) : c_mut

    status_str = '—'
    status_col = c_mut
    if has_gap
        if full_filled
            status_str := '100% ✓'
            status_col := c_up
        else if filled_75
            status_str := '75% ✓ ' + pend_str + '100%'
            status_col := c_up
        else if filled
            status_str := '50% ✓ ' + pend_str + '75%'
            status_col := c_up
        else if filled_25
            status_str := '25% ✓ ' + pend_str + '50%'
            status_col := c_amb
        else
            status_str := pend_str + ' 25%'
            status_col := c_mut

    table.cell(t, 0, r, today_dow,   text_color = c_txt,       bgcolor = c_row, text_size = tbl_sz, text_halign = text.align_left)
    table.cell(t, 1, r, tgt_str,     text_color = c_wht,       bgcolor = c_row, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t, 2, r, gap_str,     text_color = gap_col,     bgcolor = c_row, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t, 3, r, status_str,  text_color = status_col,  bgcolor = c_row, text_size = tbl_sz, text_halign = text.align_center)
    r := r + 1

    // ── Signal row ────────────────────────────────────────────────────────
    _sig_col = c_mut
    _sig_str = '—'
    if has_gap
        _di       = dayofweek == 2 ? 0 : dayofweek == 3 ? 1 : dayofweek == 4 ? 2 : dayofweek == 5 ? 3 : 4
        _dup      = array.get(dw_up_n,   _di)
        _ddn      = array.get(dw_dn_n,   _di)
        _dup_f    = array.get(dw_up_f50, _di)
        _ddn_f    = array.get(dw_dn_f50, _di)
        _fill_pct = gap_size > 0 ? (_dup > 0 ? math.round(_dup_f / _dup * 100) : 0) : (_ddn > 0 ? math.round(_ddn_f / _ddn * 100) : 0)
        _fill_n   = gap_size > 0 ? _dup : _ddn
        _dir_str  = gap_size > 0 ? '▲' : '▼'
        _sig_str  = today_dow + ' gap ' + _dir_str + ' → 50% fills ' + str.tostring(_fill_pct) + '% of time (' + str.tostring(_fill_n) + ' sess)'
        _sig_col  = _fill_pct >= 80 ? c_heat_hi : _fill_pct >= 60 ? c_heat_mid : c_heat_low

    table.cell(t, 0, r, _sig_str, text_color = _sig_col, bgcolor = #0e0e0e, text_size = tbl_sz, text_halign = text.align_left)
    for _sc = 1 to NCOLS - 1
        table.cell(t, _sc, r, '', text_color = c_mut, bgcolor = #0e0e0e, text_size = size.tiny)
    r := r + 1

    // ── Footer ────────────────────────────────────────────────────────────
    table.cell(t, 0, r, 'Min gap: ' + _min_gap_str, text_color = c_wht,     bgcolor = c_hdr, text_size = tbl_sz, text_halign = text.align_left)
    table.cell(t, 1, r, '■ ≥80%',                    text_color = c_heat_hi,  bgcolor = c_hdr, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t, 2, r, '■ ≥60%',                    text_color = c_heat_mid, bgcolor = c_hdr, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t, 3, r, '■ <60%',                    text_color = c_heat_low, bgcolor = c_hdr, text_size = tbl_sz, text_halign = text.align_center)
````
