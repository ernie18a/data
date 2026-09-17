<!-- tradingview-pine-id: PUB;f7a670a3dd5044d28ee6ce007b650780 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Dynamic ZigZag with Real-Time Confirmation Stats

Source: https://www.tradingview.com/script/xjhZIQNz-ATR-Dynamic-ZigZag-with-Real-Time-Confirmation-Stats/

## Description

This Pine Script indicator, "ATR Dynamic ZigZag with Real-Time Confirmation Stats", is a sophisticated tool that combines a volatility‑adjusted ZigZag with a statistical dashboard. Below is a clear breakdown of its purpose, mechanics, and how to interpret the data it provides.

🎯 What It Does
Dynamic ZigZag: Plots swing highs/lows only when price moves by a user‑defined multiple of Average True Range (ATR) – this filters out minor noise and adapts to current volatility.

Real‑Time Confirmation Stats: Tracks every confirmed swing and displays a live table with:

Theoretical vs. actual (confirmed) move percentages.

ATR lag cost (how much of the move was missed due to the confirmation rule).

System health diagnostics to help you tune the ATR multiplier.

Visual Overlays: Optionally shows Bollinger Bands, an EMA, and price/percentage labels on each ZigZag pivot.

⚙️ How It Works (Core Logic)
ATR Threshold

Calculates threshold = ATR(14) × Multiplier (default 2.0).

A new swing is confirmed only when price moves away from the current extreme by at least this amount.

Direction Tracking

Bullish mode (dir = 1): Tracks new highs. If price drops below extreme_high - threshold, the swing ends, and a new bearish swing begins.

Bearish mode (dir = -1): Tracks new lows. If price rises above extreme_low + threshold, the swing ends, and a new bullish swing begins.

Data Capture on Confirmation
When a swing completes, the script records:

Theoretical Move: % change between the two extreme pivot prices.

Confirmed (Real) Move: % change from the confirmation bar’s close to the new pivot (simulating an entry at the moment the reversal is confirmed).

Lag Cost: The difference between the two (i.e., missed profit due to waiting for ATR confirmation).

📊 Dashboard (Table) Interpretation
The table (top‑right) updates on the last bar and shows:

Row	Metric	What It Tells You
Count	Number of completed swings	Sample size for the stats.
Average / Max / Min Move	Theoretical vs. Confirmed	
If confirmed averages are much lower than theoretical, the ATR multiplier may be too large (lag) or too small (whipsaw).
Total Cum. Return	Sum of all theoretical & confirmed % moves	
A quick view of overall performance.
Positive = net upward swings, negative = net downward swings.
Recent Trades	
Last 2 swings with direction (▲ BULL / ▼ BEAR)	
Shows the most recent trade performance in detail.

ATR System Health	Diagnostic status	
Green = healthy edge (confirmed profits > lag).
Orange/Red = weak or unprofitable – adjust the ATR Multiplier.

🧠 How to Use & Optimize
Tuning the ATR Multiplier:

Too low → many small swings (whipsaw) – diagnostic will show “UNPROFITABLE EDGE”.

Too high → late entries (high lag) – diagnostic will show “WEAK EDGE”.

Aim for a value where “HEALTHY EDGE” appears and confirmed profits remain strong.

Visual Confirmation:

ZigZag lines change colour (green/red) based on direction.

Labels show the pivot price, theoretical %, and confirmed %. This helps you see if the system would have captured a move in real time.

Date Range: You can restrict the analysis to a specific period (e.g., only recent data) using the Start/End Date inputs.

🔧 Key Inputs You Can Adjust
Input	Default	Effect
ATR Length	14	Sensitivity of volatility measurement.
ATR Multiplier	2.0	Most important – controls the minimum swing size.
Show Zig Lines	On	Toggle the ZigZag drawing.
Show Percentage & Price Labels	On	Shows labels on each pivot.
EMA Length / Source	5, close	
Used only for colour logic and reference (not for signals).
⚠️ Important Caveats
Not a standalone entry signal – it’s a post‑facto swing tracker that shows what would have happened. Use it to evaluate your ATR multiplier, not as a direct buy/sell trigger.

Confirmation price is the close of the bar where the reversal threshold is hit – in real trading, slippage and execution delays may increase the actual lag.

Stats accumulate from the start date; reset by changing the date range or reloading the chart.

✅ Summary
This indicator is an educational and diagnostic tool for traders who:

Want to see how an ATR‑based swing system performs historically.

Need to tune their volatility‑adjusted stop/reversal parameters.

Prefer a visual representation of “what would have been captured” vs. “what was actually captured” with a realistic confirmation delay.

By monitoring the System Health row and comparing theoretical vs. confirmed stats, you can systematically optimise the ATR multiplier for the asset and timeframe you are trading.

FOR EDUCATIONAL PURPOSES ONLY
NOT A FINANCIAL ADVICE

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gogaz

//@version=6
indicator("ATR Dynamic ZigZag with Real-Time Confirmation Stats", overlay=true, max_lines_count=500, max_labels_count=500)

// ============ INPUTS ============ //
atrLen    = input.int(14, "ATR Length", minval=1, group="ZigZag Settings")
atrMult   = input.float(2.0, "ATR Reversal Multiplier", minval=0.5, step=0.1, tooltip="Pivots confirm as soon as price moves this many ATRs away from peak high/low.", group="ZigZag Settings")
showprice = input.bool(false, "Show Standalone Price Labels", group="ZigZag Style")
showperc  = input.bool(true, "Show Percentage & Price Labels", group="ZigZag Style")
showline  = input.bool(true, "Show Zig Lines", group="ZigZag Style")
upcolor   = input.color(color.green, "Zig Zag Up Color", group="ZigZag Style")
downcolor = input.color(color.red, "Zig Zag Down Color", group="ZigZag Style")
txtcol    = input.color(color.white, "Text Color", group="ZigZag Style")
zigstyle  = input.string("Solid", "Zig Zag Line Style", options=["Solid", "Dotted"], group="ZigZag Style")
zigwidth  = input.int(3, "Zig zag Line Width", minval=1, group="ZigZag Style")

// Global Table Background Color
tableBgCol = input.color(color.black, "Table Background Color", group="Table Settings")

// ============ TABLE 1: CORE STATS ============ //
t1_show = input.bool(true,  "Show", group="Table 1 – Core Stats")
t1_pos  = input.string("Top Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 1 – Core Stats")
t1_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 1 – Core Stats")

// ============ TABLE 2: SWING GEOMETRY ============ //
t2_show = input.bool(true,  "Show", group="Table 2 – Swing Geometry")
t2_pos  = input.string("Middle Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 2 – Swing Geometry")
t2_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 2 – Swing Geometry")

// ============ TABLE 3: TIME METRICS ============ //
t3_show = input.bool(true,  "Show", group="Table 3 – Time Metrics")
t3_pos  = input.string("Bottom Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 3 – Time Metrics")
t3_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 3 – Time Metrics")

// ============ TABLE 4: MOMENTUM / EFFICIENCY ============ //
t4_show = input.bool(true,  "Show", group="Table 4 – Momentum & Efficiency")
t4_pos  = input.string("Top Left", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 4 – Momentum & Efficiency")
t4_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 4 – Momentum & Efficiency")

// ============ TABLE 5: VOLATILITY REGIME ============ //
t5_show = input.bool(true,  "Show", group="Table 5 – Volatility Regime")
t5_pos  = input.string("Middle Left", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 5 – Volatility Regime")
t5_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 5 – Volatility Regime")

// ============ TABLE 6: RISK & QUALITY ============ //
t6_show = input.bool(true,  "Show", group="Table 6 – Risk & Quality")
t6_pos  = input.string("Bottom Left", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 6 – Risk & Quality")
t6_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 6 – Risk & Quality")

// Rolling lookback for current-vs-avg comparisons
rollingLookback = input.int(20, "Rolling Lookback (swings)", minval=2, group="Table Settings")

// Date Range Inputs
startDate   = input.time(timestamp("01 Jan 2020 00:00 +0000"), "Start Date", group="Date Filter")
endDate     = input.time(timestamp("31 Dec 2030 23:59 +0000"), "End Date", group="Date Filter")
inDateRange = time >= startDate and time <= endDate

// ============ INDICATORS ============ //
atrVal = ta.atr(atrLen)

// EMA Overlay
len = input.int(5, "EMA Length", minval=1, group="Overlay Indicators")
src = input.source(close, "EMA Source", group="Overlay Indicators")
out = ta.ema(src, len)

// Bollinger Bands
emaSource    = close
emaPeriod    = 20
devMultiple  = 2
baseline     = ta.sma(emaSource, emaPeriod)
plot(baseline, title="BB Mid Line", color=color.red, display=display.none)
stdDeviation = devMultiple * ta.stdev(emaSource, emaPeriod)
upperBand    = baseline + stdDeviation
lowerBand    = baseline - stdDeviation
p1           = plot(upperBand, title="BB Top", color=#4dd0e1)
p2           = plot(lowerBand, title="BB Bottom", color=#ce93d8)
fill(p1, p2, color=color.new(color.blue, 90))

// Hidden Plot for Reference
plot(out, title="EMA Invis", color=color.blue, display=display.none)

// ============ HELPER FUNCTIONS ============ //
get_table_pos(pos_str) =>
    switch pos_str
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

get_table_size(size_str) =>
    switch size_str
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

truncate(number, decimals) =>
    factor = math.pow(10, decimals)
    math.floor(number * factor) / factor

percent(n1, n2) =>
    n2 != 0 ? ((n1 - n2) / n2) * 100.0 : 0.0

calc_average(arr) => array.size(arr) > 0 ? array.sum(arr) / array.size(arr) : na
calc_max(arr)     => array.size(arr) > 0 ? array.max(arr) : na
calc_min(arr)     => array.size(arr) > 0 ? array.min(arr) : na
calc_average_int(arr) => array.size(arr) > 0 ? array.sum(arr) / array.size(arr) : na
calc_stdev(arr)   => array.size(arr) > 1 ? array.stdev(arr) : na

// Rolling average excluding the most recent entry
calc_rolling_avg_excl_last(arr, lookback) =>
    int sz = array.size(arr)
    if sz < 2
        na
    else
        int start_idx = math.max(0, sz - 1 - lookback)
        float sum = 0.0
        int cnt = 0
        for i = start_idx to sz - 2
            sum += array.get(arr, i)
            cnt += 1
        cnt > 0 ? sum / cnt : na

// ============ ATR-BASED ZIGZAG ENGINE ============ //
var int dir = 0
var float last_pivot_p = na
var int last_pivot_b   = na
var float extreme_p    = na
var int extreme_b      = na

// Array layout: [pivot_value, bar_index, confirm_close]
var ziggyzags = array.new_float(0)

add_to_zigzag(pointer, value, bindex, confirm_close) =>
    array.unshift(pointer, confirm_close)
    array.unshift(pointer, bindex)
    array.unshift(pointer, value)

update_zigzag(pointer, value, bindex, confirm_close) =>
    if array.size(pointer) == 0
        add_to_zigzag(pointer, value, bindex, confirm_close)
    else
        array.set(pointer, 0, value)
        array.set(pointer, 1, bindex)
        array.set(pointer, 2, confirm_close)

bool dirchanged = false

bool inputChanged = bar_index > 0 and (
     (not na(ta.change(int(startDate))) and ta.change(int(startDate)) != 0) or 
     (not na(ta.change(int(endDate)))   and ta.change(int(endDate)) != 0) or 
     (not na(ta.change(atrLen))         and ta.change(atrLen) != 0) or 
     (not na(ta.change(atrMult))        and ta.change(atrMult) != 0)
     )

if inputChanged
    array.clear(ziggyzags)

if bar_index == 0
    dir := 1
    last_pivot_p := high
    last_pivot_b := 0
    extreme_p    := high
    extreme_b    := 0
    add_to_zigzag(ziggyzags, high, 0, close)

float thresh = atrVal * atrMult

if dir == 1
    if high > extreme_p
        extreme_p := high
        extreme_b := bar_index
        update_zigzag(ziggyzags, extreme_p, extreme_b, close)
    else if low <= extreme_p - thresh
        dir := -1
        dirchanged := true
        last_pivot_p := extreme_p
        last_pivot_b := extreme_b
        extreme_p    := low
        extreme_b    := bar_index
        add_to_zigzag(ziggyzags, extreme_p, extreme_b, close)
else
    if low < extreme_p
        extreme_p := low
        extreme_b := bar_index
        update_zigzag(ziggyzags, extreme_p, extreme_b, close)
    else if high >= extreme_p + thresh
        dir := 1
        dirchanged := true
        last_pivot_p := extreme_p
        last_pivot_b := extreme_b
        extreme_p    := high
        extreme_b    := bar_index
        add_to_zigzag(ziggyzags, extreme_p, extreme_b, close)

// ============ STATISTICAL TRACKING ============ //
var array<float> theoretical_moves = array.new_float(0)
var array<float> confirmed_moves   = array.new_float(0)
var array<float> lag_costs         = array.new_float(0)

var array<float> swing_heights     = array.new_float(0)
var array<int>   swing_durations   = array.new_int(0)
var array<float> swing_heights_pct = array.new_float(0)

// NEW tracking arrays
var array<int>   swing_directions     = array.new_int(0)   // +1 up-swing, -1 down-swing
var array<int>   bars_to_confirm      = array.new_int(0)   // bars from pivot to confirmation
var array<float> efficiency_ratios    = array.new_float(0) // abs(net move) / path length
var array<float> expansion_streak_arr = array.new_float(0) // reserved (unused) — kept for compatibility

// Current compression/expansion counters
var int compression_streak = 0
var int expansion_streak   = 0

if inputChanged
    array.clear(theoretical_moves)
    array.clear(confirmed_moves)
    array.clear(lag_costs)
    array.clear(swing_heights)
    array.clear(swing_durations)
    array.clear(swing_heights_pct)
    array.clear(swing_directions)
    array.clear(bars_to_confirm)
    array.clear(efficiency_ratios)
    compression_streak := 0
    expansion_streak   := 0

// Track path length within current swing for efficiency ratio
var float path_length = 0.0
var float swing_start_price = na

if dirchanged
    path_length := 0.0
    swing_start_price := na

// Accumulate path length on every bar
if na(swing_start_price)
    swing_start_price := close
path_length += math.abs(close - nz(close[1], close))

// Capture stats at confirmation
if dirchanged and array.size(ziggyzags) >= 6 and inDateRange
    float prev_pivot_val = array.get(ziggyzags, 3)
    float curr_pivot_val = array.get(ziggyzags, 0)
    float confirm_price  = close

    if not na(prev_pivot_val) and not na(curr_pivot_val) and prev_pivot_val != curr_pivot_val
        float theo_perc = percent(curr_pivot_val, prev_pivot_val)
        array.push(theoretical_moves, theo_perc)

        float conf_perc = percent(curr_pivot_val, confirm_price)
        array.push(confirmed_moves, conf_perc)

        float lag_cost = math.abs(theo_perc) - math.abs(conf_perc)
        array.push(lag_costs, lag_cost)

        float swing_height = math.abs(curr_pivot_val - prev_pivot_val)
        array.push(swing_heights, swing_height)

        float swing_height_pct = prev_pivot_val != 0 ? (swing_height / prev_pivot_val) * 100.0 : 0.0
        array.push(swing_heights_pct, swing_height_pct)

        int prev_pivot_bar = math.round(array.get(ziggyzags, 4))
        int curr_pivot_bar = math.round(array.get(ziggyzags, 1))
        int swing_duration = math.abs(curr_pivot_bar - prev_pivot_bar)
        array.push(swing_durations, swing_duration)

        // Direction: did price move UP from prev pivot to curr pivot?
        int swing_dir = curr_pivot_val > prev_pivot_val ? 1 : -1
        array.push(swing_directions, swing_dir)

        // Bars to confirm: from the pivot bar to the confirmation bar
        // Note: on the confirmation bar, the "extreme" is the pivot, and current bar is confirm
        int pivot_bar = math.round(array.get(ziggyzags, 1)) // extreme bar of the just-finished swing
        int bars_to_conf = bar_index - pivot_bar
        array.push(bars_to_confirm, bars_to_conf)

        // Efficiency ratio: net move / path traveled within the swing
        if path_length > 0
            float eff = swing_height / path_length
            array.push(efficiency_ratios, eff)
        else
            array.push(efficiency_ratios, na)

        // Update compression / expansion streaks (using rolling average)
        float roll_avg = calc_rolling_avg_excl_last(swing_heights, rollingLookback)
        if not na(roll_avg) and roll_avg > 0
            if swing_height < roll_avg * 0.7
                compression_streak += 1
                expansion_streak := 0
            else if swing_height > roll_avg * 1.3
                expansion_streak += 1
                compression_streak := 0
            else
                compression_streak := 0
                expansion_streak := 0

// ============ TABLE 1: CORE STATS ============ //
var table t1 = table.new(get_table_pos(t1_pos), 4, 10, bgcolor=color.new(tableBgCol, 15), border_width=1, border_color=color.gray)

// ============ TABLE 2: SWING GEOMETRY ============ //
var table t2 = table.new(get_table_pos(t2_pos), 4, 5, bgcolor=color.new(tableBgCol, 15), border_width=1, border_color=color.gray)

// ============ TABLE 3: TIME METRICS ============ //
var table t3 = table.new(get_table_pos(t3_pos), 3, 7, bgcolor=color.new(tableBgCol, 15), border_width=1, border_color=color.gray)

// ============ TABLE 4: MOMENTUM / EFFICIENCY ============ //
var table t4 = table.new(get_table_pos(t4_pos), 3, 7, bgcolor=color.new(tableBgCol, 15), border_width=1, border_color=color.gray)

// ============ TABLE 5: VOLATILITY REGIME ============ //
var table t5 = table.new(get_table_pos(t5_pos), 3, 7, bgcolor=color.new(tableBgCol, 15), border_width=1, border_color=color.gray)

// ============ TABLE 6: RISK & QUALITY ============ //
var table t6 = table.new(get_table_pos(t6_pos), 3, 7, bgcolor=color.new(tableBgCol, 15), border_width=1, border_color=color.gray)

if barstate.islast
    // =========================
    // TABLE 1 – CORE STATS
    // =========================
    if t1_show
        table.set_position(t1, get_table_pos(t1_pos))
        sz = get_table_size(t1_size)
        bg = tableBgCol

        table.cell(t1, 0, 0, "Metric", bgcolor=color.new(color.blue, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 1, 0, "Theoretical", bgcolor=color.new(color.blue, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 2, 0, "Confirmed", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 3, 0, "Lag Cost", bgcolor=color.new(color.orange, 70), text_color=color.white, text_size=sz)

        table.cell(t1, 0, 1, "Count", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 1, 1, str.tostring(array.size(theoretical_moves)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 2, 1, str.tostring(array.size(confirmed_moves)), bgcolor=bg, text_color=color.yellow, text_size=sz)
        table.cell(t1, 3, 1, "-", bgcolor=bg, text_color=color.silver, text_size=sz)

        float avg_theo = calc_average(theoretical_moves)
        float avg_conf = calc_average(confirmed_moves)
        float avg_lag  = calc_average(lag_costs)

        table.cell(t1, 0, 2, "Average Move", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 1, 2, str.tostring(truncate(avg_theo, 2)) + "%", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 2, 2, str.tostring(truncate(avg_conf, 2)) + "%", bgcolor=bg, text_color=color.yellow, text_size=sz)
        table.cell(t1, 3, 2, str.tostring(truncate(avg_lag, 2)) + "%", bgcolor=bg, text_color=color.orange, text_size=sz)

        table.cell(t1, 0, 3, "Max Move", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 1, 3, str.tostring(truncate(calc_max(theoretical_moves), 2)) + "%", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 2, 3, str.tostring(truncate(calc_max(confirmed_moves), 2)) + "%", bgcolor=bg, text_color=color.yellow, text_size=sz)
        table.cell(t1, 3, 3, str.tostring(truncate(calc_max(lag_costs), 2)) + "%", bgcolor=bg, text_color=color.orange, text_size=sz)

        table.cell(t1, 0, 4, "Min Move", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 1, 4, str.tostring(truncate(calc_min(theoretical_moves), 2)) + "%", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 2, 4, str.tostring(truncate(calc_min(confirmed_moves), 2)) + "%", bgcolor=bg, text_color=color.yellow, text_size=sz)
        table.cell(t1, 3, 4, str.tostring(truncate(calc_min(lag_costs), 2)) + "%", bgcolor=bg, text_color=color.orange, text_size=sz)

        float total_theo = array.size(theoretical_moves) > 0 ? array.sum(theoretical_moves) : 0.0
        float total_conf = array.size(confirmed_moves) > 0 ? array.sum(confirmed_moves) : 0.0

        table.cell(t1, 0, 5, "Total Cum. Return", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 1, 5, str.tostring(truncate(total_theo, 2)) + "%", bgcolor=bg, text_color=total_theo > 0 ? color.green : color.red, text_size=sz)
        table.cell(t1, 2, 5, str.tostring(truncate(total_conf, 2)) + "%", bgcolor=bg, text_color=total_conf > 0 ? color.green : color.red, text_size=sz)
        table.cell(t1, 3, 5, str.tostring(truncate(total_theo - total_conf, 2)) + "%", bgcolor=bg, text_color=color.orange, text_size=sz)

        table.cell(t1, 0, 6, "Recent Trades", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 1, 6, "Theo", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 2, 6, "Real", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 3, 6, "Lag", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=sz)

        if array.size(ziggyzags) >= 9
            float t1c = array.get(ziggyzags, 0)
            float t1p = array.get(ziggyzags, 3)
            float t1x = array.get(ziggyzags, 5)
            float t1t = percent(t1c, t1p)
            float t1r = percent(t1c, t1x)
            float t1l = math.abs(t1t) - math.abs(t1r)
            string t1d = t1t > 0 ? "▲ BULL" : "▼ BEAR"

            table.cell(t1, 0, 7, "Trade #1 (" + t1d + ")", bgcolor=bg, text_color=color.white, text_size=sz)
            table.cell(t1, 1, 7, (t1t > 0 ? "+" : "") + str.tostring(truncate(t1t, 2)) + "%", bgcolor=bg, text_color=t1t > 0 ? color.green : color.red, text_size=sz)
            table.cell(t1, 2, 7, (t1r > 0 ? "+" : "") + str.tostring(truncate(t1r, 2)) + "%", bgcolor=bg, text_color=t1r > 0 ? color.yellow : color.orange, text_size=sz)
            table.cell(t1, 3, 7, str.tostring(truncate(t1l, 2)) + "%", bgcolor=bg, text_color=color.orange, text_size=sz)

        if array.size(ziggyzags) >= 12
            float t2c = array.get(ziggyzags, 3)
            float t2p = array.get(ziggyzags, 6)
            float t2x = array.get(ziggyzags, 8)
            float t2t = percent(t2c, t2p)
            float t2r = percent(t2c, t2x)
            float t2l = math.abs(t2t) - math.abs(t2r)
            string t2d = t2t > 0 ? "▲ BULL" : "▼ BEAR"

            table.cell(t1, 0, 8, "Trade #2 (" + t2d + ")", bgcolor=bg, text_color=color.white, text_size=sz)
            table.cell(t1, 1, 8, (t2t > 0 ? "+" : "") + str.tostring(truncate(t2t, 2)) + "%", bgcolor=bg, text_color=t2t > 0 ? color.green : color.red, text_size=sz)
            table.cell(t1, 2, 8, (t2r > 0 ? "+" : "") + str.tostring(truncate(t2r, 2)) + "%", bgcolor=bg, text_color=t2r > 0 ? color.yellow : color.orange, text_size=sz)
            table.cell(t1, 3, 8, str.tostring(truncate(t2l, 2)) + "%", bgcolor=bg, text_color=color.orange, text_size=sz)

        int sample_size = array.size(confirmed_moves)
        string diag_status = "INSUFFICIENT DATA"
        color diag_color = color.gray
        string diag_tip = "Need at least 5 completed ATR swings to calculate diagnostics."

        if sample_size >= 5 and not na(avg_conf) and not na(avg_lag)
            float edge_ratio = avg_lag > 0 ? (avg_conf / avg_lag) : 0.0
            if avg_conf <= 0
                diag_status := "UNPROFITABLE EDGE"
                diag_color := color.red
                diag_tip := "ATR Multiplier is too low (whipsawing) or too high (lagging)."
            else if edge_ratio < 1.0
                diag_status := "WEAK EDGE (HIGH LAG)"
                diag_color := color.orange
                diag_tip := "ATR Lag eats >50% of move."
            else
                diag_status := "HEALTHY EDGE"
                diag_color := color.green
                diag_tip := "Strong confirmed profits relative to ATR lag."

        table.cell(t1, 0, 9, "System Health", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t1, 1, 9, diag_status, bgcolor=color.new(diag_color, 85), text_color=diag_color, text_size=sz, tooltip=diag_tip)
        table.cell(t1, 2, 9, "Ratio: " + (avg_lag > 0 ? str.tostring(truncate(avg_conf / avg_lag, 2)) + "x" : "N/A"), bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t1, 3, 9, sample_size >= 5 ? "N=" + str.tostring(sample_size) : "Low Sample", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    // =========================
    // TABLE 2 – SWING GEOMETRY
    // =========================
    if t2_show
        table.set_position(t2, get_table_pos(t2_pos))
        sz = get_table_size(t2_size)
        bg = tableBgCol

        table.cell(t2, 0, 0, "Geometry", bgcolor=color.new(color.teal, 70), text_color=color.white, text_size=sz)
        table.cell(t2, 1, 0, "Height", bgcolor=color.new(color.teal, 70), text_color=color.white, text_size=sz)
        table.cell(t2, 2, 0, "Duration", bgcolor=color.new(color.teal, 70), text_color=color.white, text_size=sz)
        table.cell(t2, 3, 0, "Height %", bgcolor=color.new(color.teal, 70), text_color=color.white, text_size=sz)

        float avg_height     = calc_average(swing_heights)
        float avg_duration   = calc_average_int(swing_durations)
        float avg_height_pct = calc_average(swing_heights_pct)

        table.cell(t2, 0, 1, "Average", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 1, 1, na(avg_height) ? "-" : str.tostring(truncate(avg_height, 2)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 2, 1, na(avg_duration) ? "-" : str.tostring(truncate(avg_duration, 0)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 3, 1, na(avg_height_pct) ? "-" : str.tostring(truncate(avg_height_pct, 2)) + "%", bgcolor=bg, text_color=color.white, text_size=sz)

        table.cell(t2, 0, 2, "Max", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 1, 2, na(calc_max(swing_heights)) ? "-" : str.tostring(truncate(calc_max(swing_heights), 2)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 2, 2, array.size(swing_durations) > 0 ? str.tostring(array.max(swing_durations)) : "-", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 3, 2, na(calc_max(swing_heights_pct)) ? "-" : str.tostring(truncate(calc_max(swing_heights_pct), 2)) + "%", bgcolor=bg, text_color=color.white, text_size=sz)

        table.cell(t2, 0, 3, "Min", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 1, 3, na(calc_min(swing_heights)) ? "-" : str.tostring(truncate(calc_min(swing_heights), 2)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 2, 3, array.size(swing_durations) > 0 ? str.tostring(array.min(swing_durations)) : "-", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t2, 3, 3, na(calc_min(swing_heights_pct)) ? "-" : str.tostring(truncate(calc_min(swing_heights_pct), 2)) + "%", bgcolor=bg, text_color=color.white, text_size=sz)

        // Current vs Avg Height
        int h_count = array.size(swing_heights)
        string h_status = "N/A"
        color h_color = color.gray
        string h_tip = "Need at least 2 confirmed swings."
        float h_ratio = na
        float h_current = h_count > 0 ? array.get(swing_heights, h_count - 1) : na

        if h_count >= 2
            float avg_prior = calc_rolling_avg_excl_last(swing_heights, rollingLookback)
            if not na(avg_prior) and avg_prior > 0
                h_ratio := h_current / avg_prior
                if h_ratio >= 1.5
                    h_status := "MUCH ABOVE AVG ▲▲"
                    h_color := color.lime
                    h_tip := "Current swing 50%+ larger than rolling avg — strong expansion."
                else if h_ratio > 1.05
                    h_status := "ABOVE AVG ▲"
                    h_color := color.green
                    h_tip := "Larger than rolling avg — mild expansion."
                else if h_ratio >= 0.95
                    h_status := "AT AVG ●"
                    h_color := color.yellow
                    h_tip := "In line with rolling avg."
                else if h_ratio >= 0.5
                    h_status := "BELOW AVG ▼"
                    h_color := color.orange
                    h_tip := "Smaller than rolling avg — mild contraction."
                else
                    h_status := "MUCH BELOW AVG ▼▼"
                    h_color := color.red
                    h_tip := "Less than half the rolling avg — strong contraction."

        table.cell(t2, 0, 4, "Current vs Avg Height", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t2, 1, 4, h_status, bgcolor=color.new(h_color, 85), text_color=h_color, text_size=sz, tooltip=h_tip)
        table.cell(t2, 2, 4, na(h_ratio) ? "N/A" : str.tostring(truncate(h_ratio, 2)) + "x", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t2, 3, 4, na(h_current) ? "-" : str.tostring(truncate(h_current, 2)), bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    // =========================
    // TABLE 3 – TIME METRICS
    // =========================
    if t3_show
        table.set_position(t3, get_table_pos(t3_pos))
        sz = get_table_size(t3_size)
        bg = tableBgCol

        table.cell(t3, 0, 0, "Time Metric", bgcolor=color.new(color.aqua, 70), text_color=color.black, text_size=sz)
        table.cell(t3, 1, 0, "Value", bgcolor=color.new(color.aqua, 70), text_color=color.black, text_size=sz)
        table.cell(t3, 2, 0, "Note", bgcolor=color.new(color.aqua, 70), text_color=color.black, text_size=sz)

        // Bars per unit height
        float avg_h = calc_average(swing_heights)
        float avg_d = calc_average_int(swing_durations)
        float bars_per_height = (not na(avg_h) and avg_h > 0 and not na(avg_d)) ? avg_d / avg_h : na

        // Time symmetry
        float avg_up_dur = na
        float avg_dn_dur = na
        if array.size(swing_directions) > 0 and array.size(swing_durations) == array.size(swing_directions)
            float sum_up = 0.0, sum_dn = 0.0
            int cnt_up = 0, cnt_dn = 0
            for i = 0 to array.size(swing_directions) - 1
                if array.get(swing_directions, i) == 1
                    sum_up += array.get(swing_durations, i)
                    cnt_up += 1
                else
                    sum_dn += array.get(swing_durations, i)
                    cnt_dn += 1
            avg_up_dur := cnt_up > 0 ? sum_up / cnt_up : na
            avg_dn_dur := cnt_dn > 0 ? sum_dn / cnt_dn : na

        float time_sym = (not na(avg_up_dur) and not na(avg_dn_dur) and avg_dn_dur > 0) ? avg_up_dur / avg_dn_dur : na

        // Avg bars to confirm
        float avg_bars_conf = calc_average_int(bars_to_confirm)

        // Current vs Avg Duration
        int d_count = array.size(swing_durations)
        float avg_dur_prior = d_count >= 2 ? calc_rolling_avg_excl_last(swing_durations, rollingLookback) : na
        float cur_dur = d_count > 0 ? array.get(swing_durations, d_count - 1) : na
        float dur_ratio = (not na(avg_dur_prior) and avg_dur_prior > 0) ? cur_dur / avg_dur_prior : na

        table.cell(t3, 0, 1, "Bars per Height Unit", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 1, na(bars_per_height) ? "-" : str.tostring(truncate(bars_per_height, 4)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 2, 1, "Lower = faster", bgcolor=bg, text_color=color.silver , text_size=sz)

        table.cell(t3, 0, 2, "Avg Bars to Confirm", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 2, na(avg_bars_conf) ? "-" : str.tostring(truncate(avg_bars_conf, 1)), bgcolor=bg, text_color=color.yellow, text_size=sz)
        table.cell(t3, 2, 2, "ATR lag (bars)", bgcolor=bg, text_color=color.silver , text_size=sz)

        table.cell(t3, 0, 3, "Avg Up Duration", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 3, na(avg_up_dur) ? "-" : str.tostring(truncate(avg_up_dur, 1)), bgcolor=bg, text_color=color.green, text_size=sz)
        table.cell(t3, 2, 3, "bars", bgcolor=bg, text_color=color.silver , text_size=sz)

        table.cell(t3, 0, 4, "Avg Down Duration", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 4, na(avg_dn_dur) ? "-" : str.tostring(truncate(avg_dn_dur, 1)), bgcolor=bg, text_color=color.red, text_size=sz)
        table.cell(t3, 2, 4, "bars", bgcolor=bg, text_color=color.silver, text_size=sz)

        table.cell(t3, 0, 5, "Time Symmetry", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 5, na(time_sym) ? "-" : str.tostring(truncate(time_sym, 2)) + "x", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 2, 5, "Up/Down duration ratio", bgcolor=bg, text_color=color.silver, text_size=sz)

        table.cell(t3, 0, 6, "Current vs Avg Duration", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t3, 1, 6, na(dur_ratio) ? "N/A" : str.tostring(truncate(dur_ratio, 2)) + "x", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t3, 2, 6, na(cur_dur) ? "-" : str.tostring(cur_dur) + " bars", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    // =========================
    // TABLE 4 – MOMENTUM / EFFICIENCY
    // =========================
    if t4_show
        table.set_position(t4, get_table_pos(t4_pos))
        sz = get_table_size(t4_size)
        bg = tableBgCol

        table.cell(t4, 0, 0, "Momentum", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=sz)
        table.cell(t4, 1, 0, "Value", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=sz)
        table.cell(t4, 2, 0, "Note", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=sz)

        float avg_eff = calc_average(efficiency_ratios)

        // Directional bias
        float avg_up_h = na
        float avg_dn_h = na
        if array.size(swing_directions) > 0 and array.size(swing_heights) == array.size(swing_directions)
            float sum_up = 0.0, sum_dn = 0.0
            int cnt_up = 0, cnt_dn = 0
            for i = 0 to array.size(swing_directions) - 1
                if array.get(swing_directions, i) == 1
                    sum_up += array.get(swing_heights, i)
                    cnt_up += 1
                else
                    sum_dn += array.get(swing_heights, i)
                    cnt_dn += 1
            avg_up_h := cnt_up > 0 ? sum_up / cnt_up : na
            avg_dn_h := cnt_dn > 0 ? sum_dn / cnt_dn : na

        float dir_bias = (not na(avg_up_h) and not na(avg_dn_h) and avg_dn_h > 0) ? avg_up_h / avg_dn_h : na

        // Continuation ratio
        int h_count_m = array.size(swing_heights)
        float cont_ratio = na
        if h_count_m >= 2
            float cur_h = array.get(swing_heights, h_count_m - 1)
            float prev_h = array.get(swing_heights, h_count_m - 2)
            if prev_h > 0
                cont_ratio := cur_h / prev_h

        // Cumulative directional movement
        float cum_dir_mv = na
        if not na(avg_up_h) and not na(avg_dn_h) and array.size(swing_directions) > 0
            float total_up = 0.0, total_dn = 0.0
            for i = 0 to array.size(swing_directions) - 1
                if array.get(swing_directions, i) == 1
                    total_up += array.get(swing_heights, i)
                else
                    total_dn += array.get(swing_heights, i)
            cum_dir_mv := total_up - total_dn

        table.cell(t4, 0, 1, "Avg Efficiency Ratio", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 1, 1, na(avg_eff) ? "-" : str.tostring(truncate(avg_eff, 3)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 2, 1, "Net/Path (1.0 = perfect)", bgcolor=bg, text_color=color.silver , text_size=sz)

        table.cell(t4, 0, 2, "Avg Up Height", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 1, 2, na(avg_up_h) ? "-" : str.tostring(truncate(avg_up_h, 2)), bgcolor=bg, text_color=color.green, text_size=sz)
        table.cell(t4, 2, 2, "Up swings avg", bgcolor=bg, text_color=color.silver, text_size=sz)

        table.cell(t4, 0, 3, "Avg Down Height", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 1, 3, na(avg_dn_h) ? "-" : str.tostring(truncate(avg_dn_h, 2)), bgcolor=bg, text_color=color.red, text_size=sz)
        table.cell(t4, 2, 3, "Down swings avg", bgcolor=bg, text_color=color.silver , text_size=sz) 

        string bias_note = "Balanced"
        color bias_col = color.white
        if not na(dir_bias)
            if dir_bias > 1.15
                bias_note := "Bull bias"
                bias_col := color.green
            else if dir_bias < 0.87
                bias_note := "Bear bias"
                bias_col := color.red

        table.cell(t4, 0, 4, "Directional Bias", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 1, 4, na(dir_bias) ? "-" : str.tostring(truncate(dir_bias, 2)) + "x", bgcolor=bg, text_color=bias_col, text_size=sz)
        table.cell(t4, 2, 4, bias_note, bgcolor=bg, text_color=bias_col, text_size=sz)

        table.cell(t4, 0, 5, "Continuation Ratio", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 1, 5, na(cont_ratio) ? "-" : str.tostring(truncate(cont_ratio, 2)) + "x", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 2, 5, "Curr / Prev height", bgcolor=bg, text_color=color.gray, text_size=sz)

        table.cell(t4, 0, 6, "Cum. Directional Move", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t4, 1, 6, na(cum_dir_mv) ? "-" : str.tostring(truncate(cum_dir_mv, 2)), bgcolor=color.new(color.blue, 90), text_color=cum_dir_mv > 0 ? color.green : color.red, text_size=sz)
        table.cell(t4, 2, 6, "Up − Down total", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    // =========================
    // TABLE 5 – VOLATILITY REGIME
    // =========================
    if t5_show
        table.set_position(t5, get_table_pos(t5_pos))
        sz = get_table_size(t5_size)
        bg = tableBgCol

        table.cell(t5, 0, 0, "Volatility", bgcolor=color.new(color.olive, 70), text_color=color.white, text_size=sz)
        table.cell(t5, 1, 0, "Value", bgcolor=color.new(color.olive, 70), text_color=color.white, text_size=sz)
        table.cell(t5, 2, 0, "Note", bgcolor=color.new(color.olive, 70), text_color=color.white, text_size=sz)

        float h_stdev = calc_stdev(swing_heights)
        float h_avg   = calc_average(swing_heights)
        float h_cv    = (not na(h_stdev) and not na(h_avg) and h_avg > 0) ? h_stdev / h_avg : na

        // Height trend slope (simple linear regression over last N swings)
        float h_slope = na
        int h_sz = array.size(swing_heights)
        if h_sz >= 5
            int lookback = math.min(rollingLookback, h_sz)
            int start_i = h_sz - lookback
            float sum_x = 0.0, sum_y = 0.0, sum_xy = 0.0, sum_x2 = 0.0
            for i = 0 to lookback - 1
                float x = i
                float y = array.get(swing_heights, start_i + i)
                sum_x += x
                sum_y += y
                sum_xy += x * y
                sum_x2 += x * x
            float n = lookback
            float denom = n * sum_x2 - sum_x * sum_x
            h_slope := denom != 0 ? (n * sum_xy - sum_x * sum_y) / denom : na

        // Expansion / compression streaks
        string streak_status = "Neutral"
        color streak_col = color.gray
        if compression_streak >= 3
            streak_status := "COMPRESSION x" + str.tostring(compression_streak)
            streak_col := color.orange
        else if expansion_streak >= 3
            streak_status := "EXPANSION x" + str.tostring(expansion_streak)
            streak_col := color.lime
        else if compression_streak > 0
            streak_status := "Compressing x" + str.tostring(compression_streak)
            streak_col := color.yellow
        else if expansion_streak > 0
            streak_status := "Expanding x" + str.tostring(expansion_streak)
            streak_col := color.aqua

        table.cell(t5, 0, 1, "Swing Height StDev", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t5, 1, 1, na(h_stdev) ? "-" : str.tostring(truncate(h_stdev, 2)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t5, 2, 1, "Absolute dispersion", bgcolor=bg, text_color=color.silver, text_size=sz)

        table.cell(t5, 0, 2, "Coeff. of Variation", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t5, 1, 2, na(h_cv) ? "-" : str.tostring(truncate(h_cv, 3)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t5, 2, 2, "StDev / Avg", bgcolor=bg, text_color=color.silver , text_size=sz)

        string slope_note = "Flat"
        color slope_col = color.white
        if not na(h_slope)
            if h_slope > 0
                slope_note := "Expanding"
                slope_col := color.lime
            else if h_slope < 0
                slope_note := "Contracting"
                slope_col := color.orange

        table.cell(t5, 0, 3, "Height Trend Slope", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t5, 1, 3, na(h_slope) ? "-" : str.tostring(truncate(h_slope, 3)), bgcolor=bg, text_color=slope_col, text_size=sz)
        table.cell(t5, 2, 3, slope_note, bgcolor=bg, text_color=slope_col, text_size=sz)

        table.cell(t5, 0, 4, "Expansion Streak", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t5, 1, 4, str.tostring(expansion_streak), bgcolor=bg, text_color=expansion_streak >= 3 ? color.lime : color.white, text_size=sz)
        table.cell(t5, 2, 4, "Consec. >1.3x avg", bgcolor=bg, text_color=color.silver, text_size=sz)

        table.cell(t5, 0, 5, "Compression Streak", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t5, 1, 5, str.tostring(compression_streak), bgcolor=bg, text_color=compression_streak >= 3 ? color.orange : color.white, text_size=sz)
        table.cell(t5, 2, 5, "Consec. <0.7x avg", bgcolor=bg, text_color=color.silver , text_size=sz)

        table.cell(t5, 0, 6, "Regime Status", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t5, 1, 6, streak_status, bgcolor=color.new(streak_col, 85), text_color=streak_col, text_size=sz)
        table.cell(t5, 2, 6, compression_streak >= 3 ? "Breakout watch" : "—", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    // =========================
    // TABLE 6 – RISK & QUALITY
    // =========================
    if t6_show
        table.set_position(t6, get_table_pos(t6_pos))
        sz = get_table_size(t6_size)
        bg = tableBgCol

        table.cell(t6, 0, 0, "Risk/Quality", bgcolor=color.new(color.maroon, 70), text_color=color.white, text_size=sz)
        table.cell(t6, 1, 0, "Value", bgcolor=color.new(color.maroon, 70), text_color=color.white, text_size=sz)
        table.cell(t6, 2, 0, "Note", bgcolor=color.new(color.maroon, 70), text_color=color.white, text_size=sz)

        // Win rate & profit factor from confirmed moves
        int n_conf = array.size(confirmed_moves)
        int wins = 0
        int losses = 0
        float gross_win = 0.0
        float gross_loss = 0.0
        if n_conf > 0
            for i = 0 to n_conf - 1
                float m = array.get(confirmed_moves, i)
                if m > 0
                    wins += 1
                    gross_win += m
                else if m < 0
                    losses += 1
                    gross_loss += math.abs(m)
        float win_rate = n_conf > 0 ? (wins * 100.0) / n_conf : na
        float profit_factor = gross_loss > 0 ? gross_win / gross_loss : na

        // Expectancy
        float avg_win = wins > 0 ? gross_win / wins : 0.0
        float avg_loss = losses > 0 ? gross_loss / losses : 0.0
        float expectancy = na
        if n_conf > 0
            float p_win = wins / n_conf
            float p_loss = losses / n_conf
            expectancy := (p_win * avg_win) - (p_loss * avg_loss)

        // Worst confirmed move
        float worst_move = calc_min(confirmed_moves)

        // Max consecutive losers
        int max_consec_loss = 0
        int cur_consec_loss = 0
        if n_conf > 0
            for i = 0 to n_conf - 1
                if array.get(confirmed_moves, i) < 0
                    cur_consec_loss += 1
                    if cur_consec_loss > max_consec_loss
                        max_consec_loss := cur_consec_loss
                else
                    cur_consec_loss := 0

        // Whipsaw count: swings shorter than 1 ATR
        int whipsaws = 0
        if array.size(swing_heights) > 0 and not na(atrVal)
            for i = 0 to array.size(swing_heights) - 1
                if array.get(swing_heights, i) < atrVal
                    whipsaws += 1

        table.cell(t6, 0, 1, "Win Rate", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t6, 1, 1, na(win_rate) ? "-" : str.tostring(truncate(win_rate, 1)) + "%", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t6, 2, 1, str.tostring(wins) + "W / " + str.tostring(losses) + "L", bgcolor=bg, text_color=color.gray, text_size=sz)

        color pf_col = color.white
        if not na(profit_factor)
            pf_col := profit_factor >= 1.5 ? color.green : profit_factor >= 1.0 ? color.yellow : color.red

        table.cell(t6, 0, 2, "Profit Factor", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t6, 1, 2, na(profit_factor) ? "-" : str.tostring(truncate(profit_factor, 2)) + "x", bgcolor=bg, text_color=pf_col, text_size=sz)
        table.cell(t6, 2, 2, "Gross Win / Loss", bgcolor=bg, text_color=color.silver, text_size=sz)

        table.cell(t6, 0, 3, "Expectancy", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t6, 1, 3, na(expectancy) ? "-" : str.tostring(truncate(expectancy, 2)) + "%", bgcolor=bg, text_color=expectancy > 0 ? color.green : color.red, text_size=sz)
        table.cell(t6, 2, 3, "% per swing", bgcolor=bg, text_color=color.silver, text_size=sz)

        table.cell(t6, 0, 4, "Worst Move", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t6, 1, 4, na(worst_move) ? "-" : str.tostring(truncate(worst_move, 2)) + "%", bgcolor=bg, text_color=color.red, text_size=sz)
        table.cell(t6, 2, 4, "Min confirmed", bgcolor=bg, text_color=color.silver, text_size=sz)

        table.cell(t6, 0, 5, "Max Consec. Losses", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t6, 1, 5, str.tostring(max_consec_loss), bgcolor=bg, text_color=max_consec_loss >= 3 ? color.orange : color.white, text_size=sz)
        table.cell(t6, 2, 5, "Longest losing run", bgcolor=bg, text_color=color.silver , text_size=sz)

        table.cell(t6, 0, 6, "Whipsaw Count", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t6, 1, 6, str.tostring(whipsaws), bgcolor=color.new(color.blue, 90), text_color=whipsaws > array.size(swing_heights) * 0.5 ? color.orange : color.white, text_size=sz)
        table.cell(t6, 2, 6, "Swings < 1 ATR", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

// ============ ZIGZAG VISUAL DRAWING ============ //
var line cur_line = na
var label cur_label = na

if array.size(ziggyzags) >= 6 and inDateRange
    float val          = array.get(ziggyzags, 0)
    int point          = math.round(array.get(ziggyzags, 1))
    float confirm_curr = array.get(ziggyzags, 2)

    float val1         = array.get(ziggyzags, 3)
    int point1         = math.round(array.get(ziggyzags, 4))
    float confirm_prev = array.get(ziggyzags, 5)

    if dirchanged
        cur_line := na
        cur_label := na

    if showline
        line.delete(cur_line)
        cur_line := line.new(
             x1=point1, y1=val1, x2=point, y2=val, 
             color=dir == 1 ? upcolor : downcolor, 
             width=zigwidth, 
             style=zigstyle == "Solid" ? line.style_solid : line.style_dotted
         )

    if showperc
        label.delete(cur_label)
        
        float theo_perc = percent(val, val1)
        float real_perc = percent(val, confirm_prev)
        
        float height    = math.abs(val - val1)
        int   duration  = math.abs(point - point1)

        string price_str = str.tostring(val, "#.##") 
        string theo_str  = "Theo: " + (theo_perc > 0 ? "+" : "") + str.tostring(truncate(theo_perc, 2)) + "%"
        string real_str  = "Real: " + (real_perc > 0 ? "+" : "") + str.tostring(truncate(real_perc, 2)) + "%"
        string geo_str   = "H: " + str.tostring(truncate(height, 2)) + " | D: " + str.tostring(duration) + " bars"
        
        string plabel    = price_str + "\n" + theo_str + "\n" + real_str + "\n" + geo_str
        color labelcol   = dir == 1 ? (val > out ? upcolor : downcolor) : (val < out ? downcolor : upcolor)

        cur_label := label.new(
             x=point, y=val, 
             text=plabel, 
             color=labelcol, 
             textcolor=txtcol, 
             style=dir == 1 ? label.style_label_down : label.style_label_up
         )
````
