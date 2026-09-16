<!-- tradingview-pine-id: PUB;e5f0ba762e2548ba8b59cd9a779e8475 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Cycle Grid

Source: https://www.tradingview.com/script/qZCznS2P-Cycle-Grid/

## Description

CYCLE GRID

Cycle Grid takes the same Gann-style time projections as the Cycles indicator and lays them out as a clean grid in its own pane, one row per method. Instead of lines on your price chart, each method becomes a row of cells: every cell is one cycle interval, so you can read the rhythm of each cycle and see the countdown to the next turn at a glance, without cluttering price.

WHAT YOU SEE

A stacked grid, one row per enabled method (Gann, Harmonics, Anniversaries, Square-the-Range, and the three intraday methods). Reading left to right along a row, each cell is one cycle interval; the number in a cell is the cycle count that closed it. The right edge of each row shows the running total and a countdown to the next turn. Cell fill is green / pink / blue depending on whether price closed above, below, or level across that interval. A dotted anchor line marks the origin. An optional info table reports the cycle unit, bars-per-unit, the anchor bar, and the measured Master Time Factor.

HOW IT WORKS

From one swing (auto-detected, or highest-high / lowest-low) on the Cycle Timeframe, it projects each method's turning points and tiles the space between them into cells. Method numbers are unit counts, and the Cycle Unit setting makes them timeframe-adaptive: 1 unit = 1 chart bar on intraday, 1 calendar day on daily and above, so the grid stays readable on everything from 1m to weekly.

READING IT

This is a timing map, not a signal. A row's countdown tells you how far to its next turn; when several rows are due to close near the same date, that is the higher-odds window. Cells are context: the rhythm and the run-up to the next turn, while price direction still comes from your own structure.

NOTES

Runs in its own pane and does not require the Cycles overlay (they share the same method engine). Redraws on the last bar. Cell borders share a single colour (set in Colour > Border Color); turn off Single Border Color to give each method its own colour. Timeframe-adaptive across 1m to Weekly.

THE CYCLES EXPLAINED

Every method below starts from the same origin: one swing (an anchor high or low) found on the Cycle Timeframe. From that anchor it projects forward the dates the market is "due" to turn again, each method using a different Gann or Jenkins principle. Numbers are counted in UNITS, and the Cycle Unit setting decides what one unit is: one chart bar on intraday charts, one calendar day on daily and higher. That is what keeps the same geometry meaningful whether you are scalping or swing trading.

TIME METHODS

Anniversaries (45 / 90 / 144 / 180 / 270 / 360 / 720 / 1080)
The market's tendency to return to a turning point at natural time anniversaries of a prior high or low. 360 is one full time cycle; 180 is the half-cycle; 90 and 270 are the quarter turns; 45 the eighth. 144 is Gann's "square of 12" (12 x 12), one of the strongest time counts he used. 720 and 1080 extend the same rhythm out two and three cycles. When price arrives at one of these anniversaries of the anchor, it is a natural window for a change in trend.

Harmonic Angles (30 / 45 / 60 / 72 / 120 / 144 / 216 / 288 degrees)
The 360-degree cycle divided into its harmonic fractions, each degree read as one unit of time. 90 is a quarter of the circle, 120 a third, 72 a fifth, 60 a sixth, 45 an eighth, 30 a twelfth. These are the same angular divisions Gann drew on the Square of Nine and the circle chart, applied here to time rather than price. Turns tend to cluster where several harmonics of the anchor line up.

Gann Doubly-Strong Circle Levels (22.5-degree steps: 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180)
Gann called the 22.5-degree increments the "doubly strong" angles because they mark both an eighth and a sixteenth division of the circle at once, so both scales reinforce the same point. Counting these steps in time from the anchor gives the dates where the time-wheel returns to a doubly-supported angle. 90 (a square) and 180 (an opposition) are the strongest of the set.

Square the Range (price converted into time)
Gann's core idea that price and time are the same thing measured on two axes: a market "squares out" when the amount of time elapsed equals the size of the price range. Cycle Grid measures the anchor swing's high-to-low range, reduces it to natural units with an automatic price scale, and projects that many time units forward at 1/4, 1/2, 1x and 2x. When time catches up to the range (the 1x turn), the swing has squared and is prone to reverse.

INTRADAY METHODS (Jenkins)

Square of Nine Time
Michael Jenkins' method of running the Gann Square of Nine on time instead of price. The measured time swing (the bar count between the anchor high and low) is placed on the wheel, and each turn is one rotation around the square: a full 360-degree rotation adds 2.0 to the SQUARE ROOT of the count (so 180 adds 1.0, 90 adds 0.5, 45 adds 0.25). Because the base is measured in chart bars, it self-scales to any timeframe with no calendar conversion, which makes it well suited to intraday work.

Price Spins Out Time
Jenkins' price-into-time rule: a price magnitude "spins out" an equal number of time units. A market that made a 50 high spins out 50 units of time; a 17 low spins out 17. The anchor price is reduced to natural units with the same automatic scale Square the Range uses, then projected forward at 1/2, 1x, 2x and 3x. Unlike Square the Range, which uses the high-to-low RANGE, this uses the anchor PRICE itself.

Master Time Factor
Jenkins' dominant measured cycle: rather than a fixed number, it reads the market's own current rhythm. It takes the bar distance between the last two confirmed pivot highs and the last two confirmed pivot lows, averages them, and projects that cycle forward at 1/2, 1x, 1.5x, 2x and 3x from the anchor. Measured directly in bars, it adapts to whatever the market is doing right now, and is often the most useful of the three on scalp charts.

HOW TO USE THEM TOGETHER
Each method is a different lens on the same swing. Where several methods project a turn onto the same date, that clustering is the higher-odds timing window. Trade the cluster, not any single line, and confirm direction with your own price structure - these methods time the WHEN, not the which-way.

---

## Source Code

````pine
//@version=6
indicator('Cycle Grid', overlay = false, max_boxes_count = 500, max_labels_count = 200, max_lines_count = 50, max_bars_back = 5000)

lock_cycle_tf = input.bool(true, 'Lock Cycles to Timeframe', group = 'Anchor', tooltip = 'Compute the origin on Cycle Timeframe so 1m/4m match the 4h overlay. Lock only applies when Cycle Timeframe is STRICTLY higher than the chart. Set Cycle Timeframe to 4 hours or Daily, not 4 minutes.')
cycle_tf = input.timeframe('240', 'Cycle Timeframe', group = 'Anchor', tooltip = 'Default 4 hours. Pine \'4\' is 4 minutes. Use 240 (4h) or D on 1m/4m so the origin is the same swing as Cycles, not this week\'s 1m high.')
time_anchor_source = input.string('Auto Swing', 'Anchor Source', options = ['Auto Swing', 'Highest High', 'Lowest Low'], group = 'Anchor')
time_lookback = input.int(5000, 'Anchor Lookback (bars of Cycle TF)', minval = 50, maxval = 5000, group = 'Anchor')

use_anniversaries = input.bool(true, 'Anniversaries (45/90/144/180/270/360/720d)', group = 'Time Methods')
use_square_range = input.bool(true, 'Square the Range (price<->time)', group = 'Time Methods')
use_harmonic_angles = input.bool(true, 'Harmonic Angles (30/45/60/72/120/144 deg)', group = 'Time Methods')
use_gann_circles = input.bool(true, 'Gann Doubly-Strong Circle Levels', group = 'Time Methods')

color_by = input.string('Cell Open', 'Colour By', options = ['Cell Open', 'Anchor Price'], group = 'Colour', tooltip = 'CELL OPEN: green if the cell\'s close is above its open, pink if below, blue if unchanged. ANCHOR PRICE: same test against the swing price.')
col_above = input.color(color.rgb(186, 224, 196), 'Price Above', group = 'Colour')
col_below = input.color(color.rgb(242, 198, 198), 'Price Below', group = 'Colour')
col_flat = input.color(color.rgb(196, 214, 232), 'Unchanged', group = 'Colour')
fill_transp = input.int(10, 'Fill Transparency', minval = 0, maxval = 95, group = 'Colour')

max_cells = input.int(24, 'Max Cells per Method', minval = 4, maxval = 80, group = 'Display', tooltip = 'Boxes always run from the origin. Cycle numbers hide when a row has more cells than this across the span, so a fine Square row stays readable.')
show_live_cell = input.bool(true, 'Show Forming Cell', group = 'Display', tooltip = 'Extend the last open cell from the latest turn to the current bar, using the live close.')
show_row_labels = input.bool(true, 'Row Labels', group = 'Display')
show_info_table = input.bool(false, 'Show Info Table', group = 'Display')

show_cell_numbers = input.bool(true, 'Show Cycle Numbers', group = 'Labels', tooltip = 'Centre the cycle number (the turn that closed) inside each closed cell.')
num_size = input.string('small', 'Number Size', options = ['tiny', 'small', 'normal', 'large'], group = 'Labels')
num_color = input.color(color.white, 'Number Color', group = 'Labels')
cd_size = input.string('small', 'Countdown Size', options = ['tiny', 'small', 'normal', 'large'], group = 'Labels')
cd_color = input.color(color.rgb(255, 193, 7), 'Countdown Color', group = 'Labels')
cd_style = input.string('Boxed', 'Countdown Style', options = ['Plain', 'Boxed'], group = 'Labels', tooltip = 'PLAIN: text only. BOXED: a small label plate so the open cell reads differently from a closed number.')
cd_unit = input.string('Auto', 'Countdown Unit', options = ['Auto', 'Days', 'Bars'], group = 'Labels')
row_lab_size = input.string('tiny', 'Row Label Size', options = ['tiny', 'small', 'normal', 'large'], group = 'Labels')
row_lab_color = input.color(color.gray, 'Row Label Color', group = 'Labels')
gann_unit = input.string('Auto (Cycle Unit)', 'Gann Time Unit', options = ['Auto (Cycle Unit)', 'Days', 'Session 24h', 'Hours', 'Chart bars'], group = 'Gann', tooltip = 'AUTO: follow the Cycle Unit input below, so 22.5 is 22.5 chart bars on intraday and 22.5 calendar days on daily+. DAYS: 22.5 calendar days from the swing (the pre-v1.7.0 default; on 1m that is 32,400 bars and the row collapses). SESSION 24h: 360=one UTC day so 22.5=90 minutes from the day open. HOURS: 22.5 hours from the swing. CHART BARS: 22.5 bars from the swing.')

// APPENDED at in_32 so in_0..in_31 keep their slots. This is the timeframe fix:
// Anniversary / Harmonic / Square count UNITS, and this decides how many chart
// bars one unit is worth.
cycle_unit_mode = input.string('Auto (TF-adaptive)', 'Cycle Unit', options = ['Auto (TF-adaptive)', 'Calendar Day', 'Chart Bar', 'Hour'], group = 'Anchor', tooltip = 'What one cycle unit means. The method numbers (45/90/144/180/270/360, 30-288 deg, 22.5 deg) are UNIT counts. AUTO: one unit = one chart bar on intraday, one calendar day on daily and higher - this is what makes the grid readable on 1m through W. CALENDAR DAY: the pre-v1.7.0 behaviour, which on 1m puts the first turn 64,800 bars away so every row becomes one flat cell. CHART BAR: force bar counts on any TF. HOUR: one unit = one hour of chart time.')

// --- Intraday cycle methods (all default OFF) --------------------
// Same three methods as Cycles v1.3.0, rendered as extra grid rows.
use_jenkins_sq9 = input.bool(false, 'Square of Nine Time', group = 'Intraday Cycles', tooltip = 'Gann Square of Nine applied to TIME. The measured time swing (bars between the lookback high and low) is rotated around the square: one full 360 deg rotation adds 2 to the SQUARE ROOT of the bar count. Turns are measured from the swing START but the row is drawn from the grid anchor, so it tiles like every other row. Measured in chart bars, so it needs no unit conversion and adapts to every timeframe.')
jenkins_sq9_deg = input.string('90', 'Sq9 Degrees per Step', options = ['45', '90', '180', '360'], group = 'Intraday Cycles', tooltip = 'Rotation per step. 360 deg = +2.0 on the square root, 180 = +1.0, 90 = +0.5, 45 = +0.25.')
jenkins_sq9_steps = input.int(8, 'Sq9 Steps', minval = 1, maxval = 24, group = 'Intraday Cycles')
use_jenkins_price_time = input.bool(false, 'Price Spins Out Time', group = 'Intraday Cycles', tooltip = 'Price-into-time rule: a 50 high spins out 50 time units, a 17 low spins out 17. The anchor price is reduced to natural units with the same internal auto scale Square the Range uses, then projected at 1/2, 1x, 2x and 3x. Unlike Square the Range this uses the anchor PRICE, not the high-low range.')
use_jenkins_mtf = input.bool(false, 'Master Time Factor', group = 'Intraday Cycles', tooltip = 'The dominant measured cycle: the bar distance between the last two confirmed pivot highs and the last two confirmed pivot lows, averaged. Tiled at half-cycle steps from the anchor. Measured directly in chart bars, so it is timeframe-adaptive by construction.')
jenkins_mtf_pivot_len = input.int(10, 'Master Time Factor Pivot Strength', minval = 2, maxval = 50, group = 'Intraday Cycles', tooltip = 'Bars either side required to confirm a pivot. Smaller = faster, noisier cycle measurement.')
jenkins_max_cells = input.int(40, 'Max Cells per Row', minval = 4, maxval = 80, group = 'Intraday Cycles', tooltip = 'Hard cap on ladder steps for these rows so a small measured cycle on a scalp chart cannot blow through the 500-box budget.')

// APPENDED LAST (v1.7.4) so every existing in_N slot keeps its saved value. group="Colour"
// puts these in the existing Colour section visually. SINGLE BORDER COLOR (default ON):
// every cell border uses one colour instead of each method's own hardcoded colour.
use_single_border = input.bool(true, 'Single Border Color', group = 'Colour', tooltip = 'ON: every cell border across all rows uses the Border Color below. OFF: each method keeps its own colour (the pre-v1.7.4 look).')
grid_border_col = input.color(color.rgb(41, 98, 255), 'Border Color', group = 'Colour', tooltip = 'One colour for every cell border when Single Border Color is on.')

row_count = (use_gann_circles ? 1 : 0) + (use_harmonic_angles ? 1 : 0) + (use_anniversaries ? 1 : 0) + (use_square_range ? 1 : 0) + (use_jenkins_sq9 ? 1 : 0) + (use_jenkins_price_time ? 1 : 0) + (use_jenkins_mtf ? 1 : 0)
plot(0.0, 'grid_lo', color = color.new(color.white, 100), display = display.pane)
plot(math.max(1.0, float(row_count)), 'grid_hi', color = color.new(color.white, 100), display = display.pane)

base_levels_doubly_strong = array.from(22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180)

get_auto_multiplier(price_input) =>
    current_price = price_input
    if current_price >= 1000000
        if current_price >= 1000000000000
            math.pow(10, math.floor(math.log10(current_price)) - 2)
        else if current_price >= 1000000000
            math.pow(10, math.floor(math.log10(current_price)) - 3)
        else
            math.pow(10, math.floor(math.log10(current_price)) - 4)
    else
        multipliers = array.from(0.00001, 0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000)
        best_multiplier = 1.0
        min_distance = math.abs(current_price)
        for i = 0 to array.size(multipliers) - 1 by 1
            test_mult = array.get(multipliers, i)
            for j = 0 to array.size(base_levels_doubly_strong) - 1 by 1
                test_level = array.get(base_levels_doubly_strong, j) * test_mult
                distance = math.abs(current_price - test_level)
                relative_distance = distance / current_price
                if relative_distance < 0.5 and distance < min_distance
                    min_distance := distance
                    best_multiplier := test_mult
                    best_multiplier
        best_multiplier

get_bars_per_day() =>
    secs = timeframe.in_seconds(timeframe.period)
    secs > 0 ? 86400.0 / secs : 1.0

// How many chart bars one cycle unit is worth. THIS is the timeframe adaptivity.
// Auto: intraday counts bars (Gann intraday practice - a 90 turn is 90
// bars), daily and higher counts calendar days (a 90 turn is 90 days).
get_bars_per_unit() =>
    secs = timeframe.in_seconds(timeframe.period)
    bpd = secs > 0 ? 86400.0 / secs : 1.0
    switch cycle_unit_mode
        'Calendar Day' => bpd
        'Chart Bar' => 1.0
        'Hour' => secs > 0 ? 3600.0 / secs : 1.0
        => timeframe.isintraday ? 1.0 : bpd

get_unit_name() =>
    switch cycle_unit_mode
        'Calendar Day' => 'day'
        'Chart Bar' => 'bar'
        'Hour' => 'hour'
        => timeframe.isintraday ? 'bar' : 'day'

gann_bars_per_unit(bpd_in, bpu_in) =>
    switch gann_unit
        'Days' => bpd_in
        'Hours' => bpd_in / 24.0
        'Chart bars' => 1.0
        'Session 24h' => bpd_in / 360.0
        => bpu_in

// One 360 deg rotation of the Square of Nine adds 2.0 to the square root.
get_sq9_root_step() =>
    switch jenkins_sq9_deg
        '45' => 0.25
        '90' => 0.5
        '180' => 1.0
        '360' => 2.0
        => 0.5

time_to_bar(t) =>
    secs = timeframe.in_seconds(timeframe.period)
    out = int(na)
    if not na(t) and secs > 0
        out := int(math.round(float(last_bar_index) - float(time - t) / (float(secs) * 1000.0)))
        out
    out

resolve_anchor_bar(walked, t) =>
    b = walked
    if na(b)
        b := time_to_bar(t)
        b
    b

pick_size(s) =>
    switch s
        'tiny' => size.tiny
        'small' => size.small
        'normal' => size.normal
        'large' => size.large
        => size.small

fmt_cycle(v) =>
    txt = ''
    if not na(v)
        if math.abs(v - math.round(v)) < 0.05
            txt := str.tostring(math.round(v), '#')
            txt
        else
            txt := str.tostring(v, '#.#')
            txt
    txt

fmt_countdown(bars_left, bpd) =>
    txt = ''
    if bars_left > 0
        days_left = bars_left / math.max(bpd, 0.0001)
        if cd_unit == 'Bars' or cd_unit == 'Auto' and days_left < 1.0
            txt := str.tostring(bars_left, '#') + 'b'
            txt
        else
            dshow = days_left >= 10 ? math.ceil(days_left) : math.round(days_left * 10) / 10
            if math.abs(dshow - math.round(dshow)) < 0.05
                txt := str.tostring(math.round(dshow), '#') + 'd'
                txt
            else
                txt := str.tostring(dshow, '#.#') + 'd'
                txt
    txt

htf_anchor_data() =>
    lb = math.max(1, math.min(time_lookback, bar_index))
    h_off = math.abs(ta.highestbars(high, lb))
    l_off = math.abs(ta.lowestbars(low, lb))
    [high[h_off], time[h_off], low[l_off], time[l_off]]

cycle_tf_eff = lock_cycle_tf and timeframe.in_seconds(cycle_tf) > timeframe.in_seconds(timeframe.period) ? cycle_tf : timeframe.period
[cyc_hh_val, cyc_hh_time, cyc_ll_val, cyc_ll_time] = request.security(syminfo.tickerid, cycle_tf_eff, htf_anchor_data())

var int hh_bar = na
var int ll_bar = na
if not na(cyc_hh_time) and time <= cyc_hh_time
    hh_bar := bar_index
    hh_bar
if not na(cyc_ll_time) and time <= cyc_ll_time
    ll_bar := bar_index
    ll_bar

var int sess_open_bar = na
if na(sess_open_bar) or ta.change(time('D')) != 0
    sess_open_bar := bar_index
    sess_open_bar

// Chart-TF fallback swing. With the 4h Cycle TF locked on a 1m chart the HTF
// swing sits ~200,000 bars back, further than the chart has loaded, so the walk
// never latches and time_to_bar returns a bar index far outside the drawable
// window. Everything then clipped onto one cell per row. Computed every bar,
// with no variable-offset indexing.
loc_lb = math.max(1, math.min(math.min(time_lookback, 4900), bar_index))
loc_hh_bar = bar_index - math.abs(ta.highestbars(high, loc_lb))
loc_ll_bar = bar_index - math.abs(ta.lowestbars(low, loc_lb))
loc_hh_val = ta.highest(high, loc_lb)
loc_ll_val = ta.lowest(low, loc_lb)

var int auto_anchor_bar = na
var float auto_anchor_price = na
var float auto_anchor_range = na
var int auto_swing_start_bar = na
var float auto_swing_bars = na
var bool anchor_is_local = false

if barstate.islast
    htf_hh_bar = resolve_anchor_bar(hh_bar, cyc_hh_time)
    htf_ll_bar = resolve_anchor_bar(ll_bar, cyc_ll_time)
    win_lo = last_bar_index - 4900
    anchor_is_local := na(cyc_hh_val) or na(cyc_ll_val) or na(htf_hh_bar) or na(htf_ll_bar) or htf_hh_bar < win_lo or htf_ll_bar < win_lo
    eff_hh_bar = anchor_is_local ? loc_hh_bar : htf_hh_bar
    eff_ll_bar = anchor_is_local ? loc_ll_bar : htf_ll_bar
    eff_hh_val = anchor_is_local ? loc_hh_val : cyc_hh_val
    eff_ll_val = anchor_is_local ? loc_ll_val : cyc_ll_val
    auto_anchor_range := eff_hh_val - eff_ll_val
    // The measured time swing, for Square of Nine Time. The count starts at the
    // EARLIER of the two extremes, not at the anchor.
    auto_swing_start_bar := math.min(eff_hh_bar, eff_ll_bar)
    auto_swing_bars := math.abs(eff_hh_bar - eff_ll_bar)
    if time_anchor_source == 'Highest High'
        auto_anchor_bar := eff_hh_bar
        auto_anchor_price := eff_hh_val
        auto_anchor_price
    else if time_anchor_source == 'Lowest Low'
        auto_anchor_bar := eff_ll_bar
        auto_anchor_price := eff_ll_val
        auto_anchor_price
    // Auto Swing: the more recent of the two extremes. Bar index works for
    else // both the HTF walk and the local fallback, so no time compare needed.
        if eff_hh_bar > eff_ll_bar
            auto_anchor_bar := eff_hh_bar
            auto_anchor_price := eff_hh_val
            auto_anchor_price
        else
            auto_anchor_bar := eff_ll_bar
            auto_anchor_price := eff_ll_val
            auto_anchor_price

// Master Time Factor input: the measured distance between the last two confirmed
// pivots of each kind. Must run on every bar, so it lives outside the islast block.
jen_ph = ta.pivothigh(high, jenkins_mtf_pivot_len, jenkins_mtf_pivot_len)
jen_pl = ta.pivotlow(low, jenkins_mtf_pivot_len, jenkins_mtf_pivot_len)
var int jen_ph_bar1 = na
var int jen_ph_bar2 = na
var int jen_pl_bar1 = na
var int jen_pl_bar2 = na
if not na(jen_ph)
    jen_ph_bar2 := jen_ph_bar1
    jen_ph_bar1 := bar_index - jenkins_mtf_pivot_len
    jen_ph_bar1
if not na(jen_pl)
    jen_pl_bar2 := jen_pl_bar1
    jen_pl_bar1 := bar_index - jenkins_mtf_pivot_len
    jen_pl_bar1

get_master_time_factor() =>
    h_span = na(jen_ph_bar1) or na(jen_ph_bar2) ? float(na) : jen_ph_bar1 - jen_ph_bar2
    l_span = na(jen_pl_bar1) or na(jen_pl_bar2) ? float(na) : jen_pl_bar1 - jen_pl_bar2
    mtf = na(h_span) ? l_span : na(l_span) ? h_span : (h_span + l_span) / 2.0
    na(mtf) or mtf < 1 ? float(na) : mtf

var array<int> cycBarBook = array.new_int()
var array<float> cycCloseBook = array.new_float()
if barstate.isconfirmed
    array.push(cycBarBook, bar_index)
    array.push(cycCloseBook, close)
    if array.size(cycBarBook) > 5000
        array.shift(cycBarBook)
        array.shift(cycCloseBook)

lookup_close(bar_x) =>
    px = float(na)
    n = array.size(cycBarBook)
    if n > 0
        if bar_x >= last_bar_index
            px := close
            px
        else
            for i = n - 1 to 0 by 1
                bx = array.get(cycBarBook, i)
                if bx == bar_x or bx <= bar_x
                    px := array.get(cycCloseBook, i)
                    break
    px

var array<box> gridBoxes = array.new_box()
var array<label> gridLabels = array.new_label()
var array<line> gridLines = array.new_line()

cell_fill(open_px, close_px, anchor_px) =>
    ref = color_by == 'Anchor Price' ? anchor_px : open_px
    c = col_flat
    if not na(ref) and not na(close_px)
        if close_px > ref
            c := col_above
            c
        else if close_px < ref
            c := col_below
            c
    color.new(c, fill_transp)

// Pine rejects a box/line/label whose bar index is more than max_bars_back
// behind or ~500 ahead of the current bar (RE10026). v1.6.2 clipped only at 0,
// so on a 1m chart a calendar-day turn produced left=0 against bar 22000+ and
// the whole pane died with a runtime error. Clip into the legal window instead.
clip_bar(x) =>
    lo = math.max(0, last_bar_index - 4900)
    hi = last_bar_index + 490
    na(x) ? int(na) : int(math.max(lo, math.min(hi, x)))

draw_cell(x1, x2, y_top, y_bot, border_c, fill_c, txt, tcol, tsize) =>
    if not na(x1) and not na(x2)
        x1c = clip_bar(x1)
        x2c = clip_bar(x2)
        if x2c > x1c
            t = str.length(txt) > 0 ? txt : ''
            eff_border = use_single_border ? grid_border_col : border_c
            array.push(gridBoxes, box.new(x1c, y_top, x2c, y_bot, bgcolor = fill_c, border_color = eff_border, border_width = 1, text = t, text_size = tsize, text_color = tcol, text_halign = text.align_center, text_valign = text.align_center))

record_turn(bars_arr, prices_arr, vals_arr, bar_x, float price_override, float cyc_val) =>
    if not na(bar_x) and bar_x <= last_bar_index
        px = not na(price_override) ? price_override : lookup_close(bar_x)
        if na(px)
            px := nz(auto_anchor_price, close)
            px
        array.push(bars_arr, bar_x)
        array.push(prices_arr, px)
        array.push(vals_arr, cyc_val)

sort_triple(bars_arr, prices_arr, vals_arr) =>
    n = array.size(bars_arr)
    if n > 1
        for i = 1 to n - 1 by 1
            key_bar = array.get(bars_arr, i)
            key_price = array.get(prices_arr, i)
            key_val = array.get(vals_arr, i)
            j = i - 1
            keep_shifting = true
            while j >= 0 and keep_shifting
                if array.get(bars_arr, j) > key_bar
                    array.set(bars_arr, j + 1, array.get(bars_arr, j))
                    array.set(prices_arr, j + 1, array.get(prices_arr, j))
                    array.set(vals_arr, j + 1, array.get(vals_arr, j))
                    j := j - 1
                    j
                else
                    keep_shifting := false
                    keep_shifting
            array.set(bars_arr, j + 1, key_bar)
            array.set(prices_arr, j + 1, key_price)
            array.set(vals_arr, j + 1, key_val)

draw_method_row(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, border_c, name, row_from_top, n_rows, anchor_px, bpd) =>
    y_bot = float(n_rows - 1 - row_from_top)
    y_top = y_bot + 1.0
    y_mid = (y_top + y_bot) * 0.5
    n = math.min(array.size(bars_arr), array.size(prices_arr))
    if n > 1
        start_i = 0
        x_left = array.get(bars_arr, start_i)
        min_w = math.max(1, int(math.round((last_bar_index - x_left) / float(math.max(4, max_cells)))))
        for i = start_i to n - 2 by 1
            x1 = array.get(bars_arr, i)
            y1 = array.get(prices_arr, i)
            x2 = array.get(bars_arr, i + 1)
            y2 = array.get(prices_arr, i + 1)
            if x2 <= last_bar_index
                cell_txt = ''
                if show_cell_numbers and x2 - x1 >= min_w
                    cyc_n = array.size(vals_arr) > i + 1 ? array.get(vals_arr, i + 1) : float(na)
                    cell_txt := fmt_cycle(cyc_n)
                    cell_txt
                draw_cell(x1, x2, y_top, y_bot, border_c, cell_fill(y1, y2, anchor_px), cell_txt, num_color, pick_size(num_size))
    nf = array.size(fut_vals)
    if show_live_cell and n > 0
        last_i = n - 1
        lx = array.get(bars_arr, last_i)
        ly = array.get(prices_arr, last_i)
        if lx < last_bar_index
            draw_cell(lx, last_bar_index, y_top, y_bot, border_c, cell_fill(ly, close, anchor_px), '', cd_color, pick_size(cd_size))
        if nf > 0
            num = fmt_cycle(array.get(fut_vals, 0))
            cd = fmt_countdown(math.max(1, array.get(fut_bars, 0) - last_bar_index), bpd)
            txt = str.length(num) > 0 and str.length(cd) > 0 ? num + ' ' + cd : str.length(num) > 0 ? num : cd
            if str.length(txt) > 0
                array.push(gridLabels, label.new(last_bar_index, y_mid, txt, style = label.style_label_left, color = color.new(color.white, 100), textcolor = cd_color, size = pick_size(cd_size), textalign = text.align_left))
    if show_row_labels and not na(auto_anchor_bar)
        array.push(gridLabels, label.new(clip_bar(auto_anchor_bar), y_mid, name, style = label.style_label_right, color = color.new(color.white, 100), textcolor = row_lab_color, size = pick_size(row_lab_size)))

push_off(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, anchor_bar, bpd, off) =>
    taken = false
    if array.size(fut_vals) == 0
        target = anchor_bar + math.round(off * bpd)
        if target <= last_bar_index
            record_turn(bars_arr, prices_arr, vals_arr, target, float(na), off)
        else
            array.push(fut_bars, target)
            array.push(fut_vals, off)
        taken := true
        taken
    taken

add_offsets(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, anchor_bar, bpd, array<float> offsets) =>
    for i = 0 to array.size(offsets) - 1 by 1
        push_off(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, anchor_bar, bpd, array.get(offsets, i))

add_step_ladder(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, anchor_bar, bpd, step, max_n) =>
    if step > 0
        for n = 1 to max_n by 1
            if array.size(fut_vals) > 0
                break
            push_off(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, anchor_bar, bpd, step * n)
        if array.size(fut_vals) == 0
            last_v = array.size(vals_arr) > 0 ? array.get(vals_arr, array.size(vals_arr) - 1) : 0.0
            off = last_v + step
            target = math.max(last_bar_index + 1, anchor_bar + int(math.round(off * bpd)))
            array.push(fut_bars, target)
            array.push(fut_vals, off)

add_wrapped(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, anchor_bar, bpd, array<float> base_arr, span, max_oct) =>
    if span > 0
        for k = 0 to max_oct by 1
            if array.size(fut_vals) > 0
                break
            if k > 0
                push_off(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, anchor_bar, bpd, span * k)
            for i = 0 to array.size(base_arr) - 1 by 1
                if array.size(fut_vals) > 0
                    break
                push_off(bars_arr, prices_arr, vals_arr, fut_bars, fut_vals, anchor_bar, bpd, span * k + array.get(base_arr, i))

if barstate.islast
    for b in gridBoxes
        box.delete(b)
    array.clear(gridBoxes)
    for lb in gridLabels
        label.delete(lb)
    array.clear(gridLabels)
    for ln in gridLines
        line.delete(ln)
    array.clear(gridLines)

    n_rows = row_count
    if n_rows > 0 and not na(auto_anchor_bar)
        bpd = get_bars_per_day()
        bpu = get_bars_per_unit()
        g_bpu = gann_bars_per_unit(bpd, bpu)
        g_origin = gann_unit == 'Session 24h' ? sess_open_bar : auto_anchor_bar
        sqr_mult = get_auto_multiplier(nz(auto_anchor_price, close))
        anchor_px = nz(auto_anchor_price, close)
        row = 0

        anchor_x = clip_bar(auto_anchor_bar)
        if not na(anchor_x)
            array.push(gridLines, line.new(anchor_x, 0.0, anchor_x, float(n_rows), color = color.white, style = line.style_dotted, width = 1))

        if use_gann_circles and not na(g_origin)
            array<int> g_bars = array.new_int()
            array<float> g_px = array.new_float()
            array<float> g_vals = array.new_float()
            record_turn(g_bars, g_px, g_vals, g_origin, lookup_close(g_origin), 0.0)
            array<int> g_fb = array.new_int()
            array<float> g_fv = array.new_float()
            add_step_ladder(g_bars, g_px, g_vals, g_fb, g_fv, g_origin, g_bpu, 22.5, 80)
            sort_triple(g_bars, g_px, g_vals)
            draw_method_row(g_bars, g_px, g_vals, g_fb, g_fv, color.rgb(255, 235, 59), 'Gann', row, n_rows, anchor_px, bpd)
            row := row + 1
            row

        if use_harmonic_angles
            array<int> h_bars = array.new_int()
            array<float> h_px = array.new_float()
            array<float> h_vals = array.new_float()
            record_turn(h_bars, h_px, h_vals, auto_anchor_bar, auto_anchor_price, 0.0)
            array<int> h_fb = array.new_int()
            array<float> h_fv = array.new_float()
            add_wrapped(h_bars, h_px, h_vals, h_fb, h_fv, auto_anchor_bar, bpu, array.from(30.0, 45.0, 60.0, 72.0, 120.0, 144.0, 216.0, 288.0), 360.0, 8)
            sort_triple(h_bars, h_px, h_vals)
            draw_method_row(h_bars, h_px, h_vals, h_fb, h_fv, color.rgb(33, 150, 243), 'Harm', row, n_rows, anchor_px, bpd)
            row := row + 1
            row

        if use_anniversaries
            array<int> a_bars = array.new_int()
            array<float> a_px = array.new_float()
            array<float> a_vals = array.new_float()
            record_turn(a_bars, a_px, a_vals, auto_anchor_bar, auto_anchor_price, 0.0)
            array<int> a_fb = array.new_int()
            array<float> a_fv = array.new_float()
            add_offsets(a_bars, a_px, a_vals, a_fb, a_fv, auto_anchor_bar, bpu, array.from(45.0, 90.0, 144.0, 180.0, 270.0, 360.0, 720.0, 1080.0))
            sort_triple(a_bars, a_px, a_vals)
            draw_method_row(a_bars, a_px, a_vals, a_fb, a_fv, color.rgb(76, 175, 80), 'Anniv', row, n_rows, anchor_px, bpd)
            row := row + 1
            row

        if use_square_range and auto_anchor_range > 0 and sqr_mult > 0
            array<int> s_bars = array.new_int()
            array<float> s_px = array.new_float()
            array<float> s_vals = array.new_float()
            record_turn(s_bars, s_px, s_vals, auto_anchor_bar, auto_anchor_price, 0.0)
            natural = auto_anchor_range / sqr_mult
            array<int> s_fb = array.new_int()
            array<float> s_fv = array.new_float()
            add_step_ladder(s_bars, s_px, s_vals, s_fb, s_fv, auto_anchor_bar, bpu, natural * 0.25, 80)
            sort_triple(s_bars, s_px, s_vals)
            draw_method_row(s_bars, s_px, s_vals, s_fb, s_fv, color.rgb(244, 67, 54), 'Sq', row, n_rows, anchor_px, bpd)
            row := row + 1
            row

        // --- Intraday cycle rows, all default OFF --------------------------
        // 1. Square of Nine applied to TIME. The measured swing t0 seeds the
        // square: root0 = sqrt(t0), and every rotation of the wheel moves that
        // ROOT by 2.0 per 360 deg. Turns are (root0 +/- j*step)^2 bars from the
        // swing START, already in chart bars, so bpu = 1.
        // v1.7.1 FIX: v1.7.0 anchored the row at the swing start and began the
        // ladder at k=1, whose turn is t0 + 2*root0*step - i.e. barely past the
        // swing itself. The first cell therefore spanned the WHOLE measured
        // swing (one ~3800-bar box hanging off the left of the grid) instead of
        // a progressive interval. The row now shares the grid's left edge with
        // every other row (auto_anchor_bar) and keeps only turns that fall
        // inside that window. j runs NEGATIVE as well: rotating BACK around the
        // square from the seed root is the same construction (smaller squares,
        // progressively tighter turns) and it fills the space between the anchor
        // and t0 whenever the anchor sits at the swing start instead of its end
        // (Highest High / Lowest Low anchor modes), so no giant leading cell can
        // reappear there either. The ladder is then capped to Max Cells
        // per Row, keeping the MOST RECENT turns; when that cap bites, the row
        // starts at its first kept turn rather than paving a wide filler cell
        // back to the anchor.
        if use_jenkins_sq9 and not na(auto_swing_start_bar) and not na(auto_swing_bars) and auto_swing_bars >= 1
            array<int> j_bars = array.new_int()
            array<float> j_px = array.new_float()
            array<float> j_vals = array.new_float()
            array<int> j_fb = array.new_int()
            array<float> j_fv = array.new_float()
            root0 = math.sqrt(auto_swing_bars)
            rstep = get_sq9_root_step()
            // Offsets are rebased onto the anchor so the row tiles like its peers.
            j_lead = float(auto_anchor_bar - auto_swing_start_bar)
            // Backward rotations that still land at least one bar past the anchor.
            // root0 <= sqrt(4900) = 70 and rstep >= 0.25, so 400 always terminates.
            j_back = 0
            for m = 1 to 400 by 1
                r_b = root0 - m * rstep
                if r_b <= 0 or math.pow(r_b, 2) - j_lead < 1
                    break
                j_back := m
                j_back
            array<float> sq9_offsets = array.new_float()
            for j = -j_back to jenkins_sq9_steps by 1
                off_j = math.pow(root0 + j * rstep, 2) - j_lead
                if off_j >= 1
                    array.push(sq9_offsets, off_j)
            // Budget: keep the most recent turns, drop the oldest.
            sq9_trimmed = array.size(sq9_offsets) > jenkins_max_cells
            while array.size(sq9_offsets) > jenkins_max_cells
                array.shift(sq9_offsets)
            // The anchor is the row's left edge only when the ladder reaches it.
            if not sq9_trimmed
                record_turn(j_bars, j_px, j_vals, auto_anchor_bar, auto_anchor_price, 0.0)
            add_offsets(j_bars, j_px, j_vals, j_fb, j_fv, auto_anchor_bar, 1.0, sq9_offsets)
            sort_triple(j_bars, j_px, j_vals)
            draw_method_row(j_bars, j_px, j_vals, j_fb, j_fv, color.rgb(245, 166, 49), 'Sq9', row, n_rows, anchor_px, bpd)
            row := row + 1
            row

        // 2. Price spins out time: the anchor price reduced to natural units by
        // the same auto scale Square the Range uses, projected in UNITS.
        if use_jenkins_price_time and not na(auto_anchor_price) and auto_anchor_price > 0 and sqr_mult > 0
            array<int> p_bars = array.new_int()
            array<float> p_px = array.new_float()
            array<float> p_vals = array.new_float()
            record_turn(p_bars, p_px, p_vals, auto_anchor_bar, auto_anchor_price, 0.0)
            array<int> p_fb = array.new_int()
            array<float> p_fv = array.new_float()
            natural_p = auto_anchor_price / sqr_mult
            add_offsets(p_bars, p_px, p_vals, p_fb, p_fv, auto_anchor_bar, bpu, array.from(natural_p * 0.5, natural_p, natural_p * 2.0, natural_p * 3.0))
            sort_triple(p_bars, p_px, p_vals)
            draw_method_row(p_bars, p_px, p_vals, p_fb, p_fv, color.rgb(245, 110, 49), 'P>T', row, n_rows, anchor_px, bpd)
            row := row + 1
            row

        // 3. Master Time Factor: the dominant measured cycle, already in chart
        // bars, tiled at half-cycle steps. bpu = 1, capped by Max Cells.
        mtf_bars = get_master_time_factor()
        if use_jenkins_mtf and not na(mtf_bars) and mtf_bars >= 1
            array<int> m_bars = array.new_int()
            array<float> m_px = array.new_float()
            array<float> m_vals = array.new_float()
            record_turn(m_bars, m_px, m_vals, auto_anchor_bar, auto_anchor_price, 0.0)
            array<int> m_fb = array.new_int()
            array<float> m_fv = array.new_float()
            add_step_ladder(m_bars, m_px, m_vals, m_fb, m_fv, auto_anchor_bar, 1.0, mtf_bars * 0.5, jenkins_max_cells)
            sort_triple(m_bars, m_px, m_vals)
            draw_method_row(m_bars, m_px, m_vals, m_fb, m_fv, color.rgb(49, 200, 160), 'MTF', row, n_rows, anchor_px, bpd)

var table debug_table = table.new(position.top_right, 2, 4, bgcolor = color.new(color.black, 80))
if barstate.islast
    if show_info_table
        table.cell(debug_table, 0, 0, 'Rows:', text_color = color.white, text_size = size.tiny)
        table.cell(debug_table, 1, 0, str.tostring(row_count), text_color = color.white, text_size = size.tiny)
        table.cell(debug_table, 0, 1, 'Anchor:', text_color = color.white, text_size = size.tiny)
        table.cell(debug_table, 1, 1, (na(auto_anchor_bar) ? 'na' : str.tostring(auto_anchor_bar)) + (anchor_is_local ? ' (local)' : ' (htf)'), text_color = color.white, text_size = size.tiny)
        table.cell(debug_table, 0, 2, 'Unit:', text_color = color.white, text_size = size.tiny)
        table.cell(debug_table, 1, 2, '1 ' + get_unit_name() + ' = ' + str.tostring(get_bars_per_unit(), '#.###') + 'b', text_color = color.white, text_size = size.tiny)
        mtf_disp = get_master_time_factor()
        table.cell(debug_table, 0, 3, 'MTF bars:', text_color = color.white, text_size = size.tiny)
        table.cell(debug_table, 1, 3, na(mtf_disp) ? 'na' : str.tostring(mtf_disp, '#.#'), text_color = color.white, text_size = size.tiny)
    else
        table.clear(debug_table, 0, 0, 1, 3)
````
