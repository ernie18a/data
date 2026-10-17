# ATR Dynamic ZigZag with Real-Time Confirmation Stats

- url: https://www.tradingview.com/script/xjhZIQNz-ATR-Dynamic-ZigZag-with-Real-Time-Confirmation-Stats/
- type: indicator
- pine_id: PUB;f7a670a3dd5044d28ee6ce007b650780
- version: 4.0

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

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gogaz

//@version=6
indicator("ATR Dynamic ZigZag with Real-Time Confirmation Stats + Similarity Engine", overlay=true, max_lines_count=500, max_labels_count=500)

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

tableBgCol = input.color(color.black, "Table Background Color", group="Table Settings")

t1_show = input.bool(true,  "Show", group="Table 1 – Core Stats")
t1_pos  = input.string("Top Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 1 – Core Stats")
t1_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 1 – Core Stats")

t2_show = input.bool(true,  "Show", group="Table 2 – Swing Geometry")
t2_pos  = input.string("Middle Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 2 – Swing Geometry")
t2_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 2 – Swing Geometry")

t3_show = input.bool(true,  "Show", group="Table 3 – Time Metrics")
t3_pos  = input.string("Bottom Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 3 – Time Metrics")
t3_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 3 – Time Metrics")

t4_show = input.bool(true,  "Show", group="Table 4 – Momentum & Efficiency")
t4_pos  = input.string("Top Left", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 4 – Momentum & Efficiency")
t4_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 4 – Momentum & Efficiency")

t5_show = input.bool(true,  "Show", group="Table 5 – Volatility Regime")
t5_pos  = input.string("Middle Left", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 5 – Volatility Regime")
t5_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 5 – Volatility Regime")

t6_show = input.bool(true,  "Show", group="Table 6 – Risk & Quality")
t6_pos  = input.string("Bottom Left", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table 6 – Risk & Quality")
t6_size = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table 6 – Risk & Quality")

rollingLookback = input.int(20, "Rolling Lookback (swings)", minval=2, group="Table Settings")
maxSwings       = input.int(400, "Max Stored Swings", minval=20, maxval=2000, group="Table Settings")

sim_show      = input.bool(true, "Enable Similarity Engine", group="Similarity Engine")
sim_lookback = input.int(80, "Compare Last N Swings", minval=10, maxval=300, group="Similarity Engine")
sim_k         = input.int(5, "K Nearest Neighbors", minval=1, maxval=20, group="Similarity Engine")
sim_threshold = input.float(0.75, "Min Similarity Score (0-1)", minval=0.0, maxval=1.0, step=0.05, group="Similarity Engine")
sim_showTable = input.bool(true, "Show Similarity Table", group="Similarity Engine")
sim_pos       = input.string("Bottom Center", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group="Similarity Engine")
sim_size      = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large","Huge"], group="Similarity Engine")
sim_showLines = input.bool(true, "Highlight Analog Swings on Chart", group="Similarity Engine")
sim_maxLines  = input.int(3, "Max Analog Markers to Draw", minval=1, maxval=10, group="Similarity Engine")
sim_dateFmt   = input.string("yyyy-MM-dd HH:mm", "Date Format", options=["yyyy-MM-dd", "yyyy-MM-dd HH:mm", "dd MMM yyyy", "dd MMM yyyy HH:mm"], group="Similarity Engine")

sim_w_height = input.float(1.0, "Weight: Height %",    minval=0.0, step=0.1, group="Similarity Engine")
sim_w_dur    = input.float(0.7, "Weight: Duration",     minval=0.0, step=0.1, group="Similarity Engine")
sim_w_eff    = input.float(1.0, "Weight: Efficiency",   minval=0.0, step=0.1, group="Similarity Engine")
sim_w_dir    = input.float(0.5, "Weight: Direction",    minval=0.0, step=0.1, group="Similarity Engine")
sim_w_atr    = input.float(0.8, "Weight: ATR Multiple", minval=0.0, step=0.1, group="Similarity Engine")

alertPivot       = input.bool(true, "Alert on Any Pivot Confirmation",           group="Alerts")
alertBullPivot   = input.bool(true, "Alert on Bullish Pivot",                    group="Alerts")
alertBearPivot   = input.bool(true, "Alert on Bearish Pivot",                    group="Alerts")
alertCompression = input.bool(true, "Alert on Compression Breakout Watch (3+)",  group="Alerts")
alertExpansion   = input.bool(true, "Alert on Volatility Expansion (≥1.5x avg)", group="Alerts")
alertWhipsaw     = input.bool(true, "Alert on Whipsaw (< 1 ATR)",                group="Alerts")
alertHealth      = input.bool(true, "Alert on System Health Change",             group="Alerts")
alertBiasShift   = input.bool(true, "Alert on Directional Bias Shift",           group="Alerts")
alertSimMatch    = input.bool(true, "Alert on Strong Similarity Match (>85%)",   group="Alerts")

startDate   = input.time(timestamp("01 Jan 2020 00:00 +0000"), "Start Date", group="Date Filter")
endDate     = input.time(timestamp("31 Dec 2030 23:59 +0000"), "End Date", group="Date Filter")
inDateRange = time >= startDate and time <= endDate

// ============ INDICATORS ============ //
atrVal = ta.atr(atrLen)

len = input.int(5, "EMA Length", minval=1, group="Overlay Indicators")
src = input.source(close, "EMA Source", group="Overlay Indicators")
out = ta.ema(src, len)

emaSource    = close
emaPeriod    = 20
devMultiple  = 2
baseline     = ta.sma(emaSource, emaPeriod)
plot(baseline, title="BB Mid Line", color=color.red, display=display.none)
stdDeviation = devMultiple * ta.stdev(emaSource, emaPeriod)
upperBand    = baseline + stdDeviation
lowerBand    = baseline - stdDeviation
p1           = plot(upperBand, title="BB Top", color=#4dd0e1, display=display.none)
p2           = plot(lowerBand, title="BB Bottom", color=#ce93d8, display=display.none)
fill(p1, p2, color=color.new(color.blue, 90), display=display.none)
plot(out, title="EMA Invis", color=color.blue, display=display.none)

// ============ HELPERS ============ //
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

calc_rolling_avg_excl_last(array<float> arr, int lookback) =>
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

calc_rolling_avg_excl_last_int(array<int> arr, int lookback) =>
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

build_feature_vector(int dir_in, float height_pct, int duration, float efficiency, float atr_mult) =>
    float dur_f  = math.min(duration, 500) / 500.0
    float h_f    = math.min(math.abs(height_pct), 20.0) / 20.0
    float eff_f  = nz(efficiency, 0.0)
    float atr_f  = math.min(atr_mult, 5.0) / 5.0
    float speed  = duration > 0 ? math.abs(height_pct) / duration : 0.0
    float spd_f  = math.min(speed, 1.0)
    float dir_f  = dir_in > 0 ? 1.0 : 0.0
    array.from(dir_f, h_f, dur_f, eff_f, atr_f, spd_f)
feature_distance_at(array<float> vecs, array<float> q, int idx) =>
    int base = idx * 6
    float d = 0.0
    d += sim_w_dir    * math.pow(array.get(q, 0) - array.get(vecs, base), 2)
    d += sim_w_height * math.pow(array.get(q, 1) - array.get(vecs, base + 1), 2)
    d += sim_w_dur    * math.pow(array.get(q, 2) - array.get(vecs, base + 2), 2)
    d += sim_w_eff    * math.pow(array.get(q, 3) - array.get(vecs, base + 3), 2)
    d += sim_w_atr    * math.pow(array.get(q, 4) - array.get(vecs, base + 4), 2)
    d += sim_w_height * math.pow(array.get(q, 5) - array.get(vecs, base + 5), 2)
    math.sqrt(d)
   

distance_to_similarity(float d) =>
    math.max(0.0, 1.0 - d / 2.5)

// ============ ZIGZAG ENGINE ============ //
var int   dir          = 0
var float last_pivot_p = na
var int   last_pivot_b = na
var float extreme_p    = na
var int   extreme_b    = na
var int   extreme_t    = na

var ziggyzags = array.new_float(0)

add_to_zigzag(array<float> pointer, float value, float bindex, float confirm_close) =>
    array.unshift(pointer, confirm_close)
    array.unshift(pointer, bindex)
    array.unshift(pointer, value)
    if array.size(pointer) > maxSwings * 3
        array.pop(pointer)
    0

update_zigzag(array<float> pointer, float value, float bindex, float confirm_close) =>
    if array.size(pointer) == 0
        add_to_zigzag(pointer, value, bindex, confirm_close)
    else
        array.set(pointer, 0, value)
        array.set(pointer, 1, bindex)
        array.set(pointer, 2, confirm_close)
    0

bool dirchanged = false

if bar_index == 0
    dir := 1
    last_pivot_p := high
    last_pivot_b := 0
    extreme_p    := high
    extreme_b    := 0
    extreme_t    := time
    add_to_zigzag(ziggyzags, high, 0, close)

float thresh = atrVal * atrMult

float locked_p = na
int   locked_b = na
int   locked_t = na

if dir == 1
    if high > extreme_p
        extreme_p := high
        extreme_b := bar_index
        extreme_t := time
        update_zigzag(ziggyzags, extreme_p, extreme_b, close)
    else if low <= extreme_p - thresh
        locked_p := extreme_p
        locked_b := extreme_b
        locked_t := extreme_t
        dir := -1
        dirchanged := true
        last_pivot_p := extreme_p
        last_pivot_b := extreme_b
        extreme_p := low
        extreme_b := bar_index
        extreme_t := time
        add_to_zigzag(ziggyzags, extreme_p, extreme_b, close)
        if array.size(ziggyzags) >= 6
            array.set(ziggyzags, 5, close)
else
    if low < extreme_p
        extreme_p := low
        extreme_b := bar_index
        extreme_t := time
        update_zigzag(ziggyzags, extreme_p, extreme_b, close)
    else if high >= extreme_p + thresh
        locked_p := extreme_p
        locked_b := extreme_b
        locked_t := extreme_t
        dir := 1
        dirchanged := true
        last_pivot_p := extreme_p
        last_pivot_b := extreme_b
        extreme_p := high
        extreme_b := bar_index
        extreme_t := time
        add_to_zigzag(ziggyzags, extreme_p, extreme_b, close)
        if array.size(ziggyzags) >= 6
            array.set(ziggyzags, 5, close)

// ============ STAT ARRAYS ============ //
var array<float> theoretical_moves = array.new_float(0)
var array<float> confirmed_moves   = array.new_float(0)
var array<float> lag_costs         = array.new_float(0)
var array<float> swing_heights     = array.new_float(0)
var array<int>   swing_durations   = array.new_int(0)
var array<float> swing_heights_pct = array.new_float(0)
var array<int>   swing_directions  = array.new_int(0)
var array<int>   bars_to_confirm   = array.new_int(0)
var array<float> efficiency_ratios = array.new_float(0)

var int compression_streak = 0
var int expansion_streak   = 0

var array<float> sim_vectors = array.new_float(0)
var array<int>   sim_bars    = array.new_int(0)
var array<int>   sim_times   = array.new_int(0)
var array<int>   sim_dirs    = array.new_int(0)
var array<float> sim_heights = array.new_float(0)
var array<float> sim_prices  = array.new_float(0)

trim_swings() =>
    while array.size(sim_bars) > maxSwings
        array.shift(sim_bars)
        array.shift(sim_times)
        array.shift(sim_dirs)
        array.shift(sim_heights)
        array.shift(sim_prices)
        for _j = 0 to 5
            array.shift(sim_vectors)
    while array.size(theoretical_moves) > maxSwings
        array.shift(theoretical_moves)
        array.shift(confirmed_moves)
        array.shift(lag_costs)
        array.shift(swing_heights)
        array.shift(swing_durations)
        array.shift(swing_heights_pct)
        array.shift(swing_directions)
        array.shift(bars_to_confirm)
        array.shift(efficiency_ratios)
    0

var float path_length = 0.0
var float swing_start_price = na

if na(swing_start_price)
    swing_start_price := close
path_length += math.abs(close - nz(close[1], close))

var string prev_health_status     = ""
var float  prev_dir_bias          = na
var bool   prev_compression_watch = false

// ============ SCANNER STATE ============ //
var bool scan_pivot_confirmed = false
var bool scan_bull_pivot      = false
var bool scan_bear_pivot      = false
var bool scan_compression     = false
var bool scan_expansion       = false
var bool scan_whipsaw         = false
var bool scan_health_change   = false
var bool scan_bias_bull_shift = false
var bool scan_bias_bear_shift = false
var bool scan_sim_match       = false
var float  scan_dir_bias   = na
var string scan_health     = "INSUFFICIENT DATA"
var float  scan_last_swing = na
var float  scan_atr        = na

scan_pivot_confirmed := false
scan_bull_pivot      := false
scan_bear_pivot      := false
scan_compression     := false
scan_expansion       := false
scan_whipsaw         := false
scan_health_change   := false
scan_bias_bull_shift := false
scan_bias_bear_shift := false
scan_sim_match       := false

// ============ CONFIRMATION STATS ============ //
if dirchanged and array.size(ziggyzags) >= 9 and inDateRange
    float end_p   = array.get(ziggyzags, 3)
    float start_p = array.get(ziggyzags, 6)
    float start_confirm = array.get(ziggyzags, 8)
    int   end_b   = math.round(array.get(ziggyzags, 4))
    int   start_b = math.round(array.get(ziggyzags, 7))

    if not na(start_p) and not na(end_p) and start_p != end_p
        float theo_perc = percent(end_p, start_p)
        array.push(theoretical_moves, theo_perc)

        float conf_perc = percent(close, start_confirm)
        array.push(confirmed_moves, conf_perc)

        float lag_cost = math.abs(theo_perc) - math.abs(conf_perc)
        array.push(lag_costs, lag_cost)

        float swing_height = math.abs(end_p - start_p)
        array.push(swing_heights, swing_height)

        float swing_height_pct = start_p != 0 ? (swing_height / start_p) * 100.0 : 0.0
        array.push(swing_heights_pct, swing_height_pct)

        int swing_duration = math.abs(end_b - start_b)
        array.push(swing_durations, swing_duration)

        int swing_dir = end_p > start_p ? 1 : -1
        array.push(swing_directions, swing_dir)

        int bars_to_conf = bar_index - end_b
        array.push(bars_to_confirm, bars_to_conf)

        float eff_val = path_length > 0 ? swing_height / path_length : na
        array.push(efficiency_ratios, eff_val)

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

        if sim_show
            float atr_mult_val = atrVal > 0 ? swing_height / atrVal : 0.0
            array<float> fv = build_feature_vector(swing_dir, swing_height_pct, swing_duration, nz(eff_val, 0.0), atr_mult_val)
            for i = 0 to array.size(fv) - 1
                array.push(sim_vectors, array.get(fv, i))
            array.push(sim_bars, end_b)
            array.push(sim_dirs, swing_dir)
            array.push(sim_heights, theo_perc)
            array.push(sim_prices, end_p)
            array.push(sim_times, nz(locked_t, time))

        trim_swings()

        int sample_size = array.size(confirmed_moves)
        string cur_health = "INSUFFICIENT DATA"
        if sample_size >= 5
            float a_c = calc_average(confirmed_moves)
            float a_l = calc_average(lag_costs)
            if not na(a_c) and not na(a_l)
                if a_c <= 0
                    cur_health := "UNPROFITABLE"
                else if a_l > 0 and (a_c / a_l) < 1.0
                    cur_health := "WEAK"
                else
                    cur_health := "HEALTHY"
        scan_health := cur_health
        if alertHealth and cur_health != prev_health_status and prev_health_status != ""
            alert("ATR System Health changed: " + prev_health_status + " → " + cur_health, alert.freq_once_per_bar_close)
            scan_health_change := true
        prev_health_status := cur_health

        if array.size(swing_directions) > 0 and array.size(swing_heights) == array.size(swing_directions)
            float sum_up = 0.0
            float sum_dn = 0.0
            int cnt_up = 0
            int cnt_dn = 0
            for i = 0 to array.size(swing_directions) - 1
                if array.get(swing_directions, i) == 1
                    sum_up += array.get(swing_heights, i)
                    cnt_up += 1
                else
                    sum_dn += array.get(swing_heights, i)
                    cnt_dn += 1
            float avg_up = cnt_up > 0 ? sum_up / cnt_up : na
            float avg_dn = cnt_dn > 0 ? sum_dn / cnt_dn : na
            if not na(avg_up) and not na(avg_dn) and avg_dn > 0
                float bias = avg_up / avg_dn
                scan_dir_bias := bias
                if alertBiasShift and not na(prev_dir_bias)
                    bool crossed_bull = prev_dir_bias <= 1.15 and bias > 1.15
                    bool crossed_bear = prev_dir_bias >= 0.87 and bias < 0.87
                    if crossed_bull
                        alert("Directional Bias Shifted BULLISH: " + str.tostring(truncate(bias, 2)) + "x", alert.freq_once_per_bar_close)
                        scan_bias_bull_shift := true
                    if crossed_bear
                        alert("Directional Bias Shifted BEARISH: " + str.tostring(truncate(bias, 2)) + "x", alert.freq_once_per_bar_close)
                        scan_bias_bear_shift := true
                prev_dir_bias := bias

if dirchanged
    path_length := 0.0
    swing_start_price := close


// ============ SIMILARITY MATCH ============ //
var float  sim_best_score  = na
var int    sim_match_count = 0
var float  sim_avg_follow  = na
var float  sim_bull_agree  = na
var string sim_verdict     = "N/A"
var color  sim_verdict_col = color.gray
var array<int>   sim_analog_bars   = array.new_int(0)
var array<int>   sim_analog_times  = array.new_int(0)
var array<float> sim_analog_scores = array.new_float(0)
var array<int>   sim_analog_dirs   = array.new_int(0)
var array<float> sim_analog_prices = array.new_float(0)
var array<float> sim_analog_swings = array.new_float(0)
var array<float> sim_analog_next   = array.new_float(0)

if barstate.islast and sim_show and array.size(sim_bars) >= 3
    int n_swings = array.size(sim_bars)
    int q_idx = n_swings - 1
    int from_i = math.max(0, n_swings - 1 - sim_lookback)

    array<float> q_vec = array.new_float(0)
    for j = 0 to 5
        array.push(q_vec, array.get(sim_vectors, q_idx * 6 + j))

    array<float> best_d = array.new_float(0)
    array<int>   best_i = array.new_int(0)

    for i = from_i to n_swings - 2
        int base = i * 6
        float d = 0.0
        d += sim_w_dir    * math.pow(array.get(q_vec, 0) - array.get(sim_vectors, base), 2)
        d += sim_w_height * math.pow(array.get(q_vec, 1) - array.get(sim_vectors, base + 1), 2)
        d += sim_w_dur    * math.pow(array.get(q_vec, 2) - array.get(sim_vectors, base + 2), 2)
        d += sim_w_eff    * math.pow(array.get(q_vec, 3) - array.get(sim_vectors, base + 3), 2)
        d += sim_w_atr    * math.pow(array.get(q_vec, 4) - array.get(sim_vectors, base + 4), 2)
        d += sim_w_height * math.pow(array.get(q_vec, 5) - array.get(sim_vectors, base + 5), 2)
        d := math.sqrt(d)
        int slot = array.size(best_d)
        if slot < sim_k
            array.push(best_d, d)
            array.push(best_i, i)
        else
            int worst = 0
            float worst_d = array.get(best_d, 0)
            if slot > 1
                for w = 1 to slot - 1
                    float dw = array.get(best_d, w)
                    if dw > worst_d
                        worst_d := dw
                        worst := w
            if d < worst_d
                array.set(best_d, worst, d)
                array.set(best_i, worst, i)

    int m = array.size(best_d)
    if m > 1
        for a = 0 to m - 2
            for b = a + 1 to m - 1
                if array.get(best_d, b) < array.get(best_d, a)
                    float td = array.get(best_d, a)
                    array.set(best_d, a, array.get(best_d, b))
                    array.set(best_d, b, td)
                    int ti = array.get(best_i, a)
                    array.set(best_i, a, array.get(best_i, b))
                    array.set(best_i, b, ti)

    float score_sum = 0.0
    float follow_sum = 0.0
    int   follow_cnt = 0
    int   bull_next  = 0
    int   valid_matches = 0
    array.clear(sim_analog_bars)
    array.clear(sim_analog_times)
    array.clear(sim_analog_scores)
    array.clear(sim_analog_dirs)
    array.clear(sim_analog_prices)
    array.clear(sim_analog_swings)
    array.clear(sim_analog_next)

    if m > 0
        for k = 0 to m - 1
            float s = distance_to_similarity(array.get(best_d, k))
            if s >= sim_threshold
                valid_matches += 1
                score_sum += s
                int src_idx = array.get(best_i, k)
                array.push(sim_analog_bars,   array.get(sim_bars, src_idx))
                array.push(sim_analog_times,  array.get(sim_times, src_idx))
                array.push(sim_analog_scores, s)
                array.push(sim_analog_dirs,   array.get(sim_dirs, src_idx))
                array.push(sim_analog_prices, array.get(sim_prices, src_idx))
                array.push(sim_analog_swings, array.get(sim_heights, src_idx))
                float next_pct = src_idx + 1 < n_swings ? array.get(sim_heights, src_idx + 1) : na
                array.push(sim_analog_next, next_pct)
                if src_idx + 1 < n_swings
                    follow_sum += next_pct
                    follow_cnt += 1
                    if array.get(sim_dirs, src_idx + 1) == 1
                        bull_next += 1

    sim_match_count := valid_matches
    sim_best_score  := valid_matches > 0 ? score_sum / valid_matches : na
    sim_avg_follow  := follow_cnt > 0 ? follow_sum / follow_cnt : na
    sim_bull_agree  := follow_cnt > 0 ? (bull_next * 100.0) / follow_cnt : na

    if valid_matches == 0
        sim_verdict := "NO ANALOGS"
        sim_verdict_col := color.silver
    else if not na(sim_avg_follow)
        if sim_avg_follow > 0.3
            sim_verdict := "BULLISH FOLLOW-THROUGH"
            sim_verdict_col := color.green
        else if sim_avg_follow < -0.3
            sim_verdict := "BEARISH FOLLOW-THROUGH"
            sim_verdict_col := color.orange
        else
            sim_verdict := "NEUTRAL / MIXED"
            sim_verdict_col := color.yellow
    else
        sim_verdict := "INSUFFICIENT HISTORY"
        sim_verdict_col := color.silver

    if alertSimMatch and not na(sim_best_score) and sim_best_score > 0.85 and sim_match_count >= 2
        scan_sim_match := true
        alert("Strong Similarity Match: " + str.tostring(truncate(sim_best_score * 100, 1)) + "% across " + str.tostring(sim_match_count) + " analogs — verdict: " + sim_verdict, alert.freq_once_per_bar_close)
// ============ PIVOT ALERTS ============ //
if dirchanged and inDateRange
    float alert_price = close
    string completed_swing = dir == 1 ? "Bearish swing (low pivot locked)" : "Bullish swing (high pivot locked)"
    scan_pivot_confirmed := true
    if dir == -1
        scan_bull_pivot := true
    if dir == 1
        scan_bear_pivot := true

    if alertPivot
        alert("ZigZag Pivot Confirmed: " + completed_swing + " @ " + str.tostring(alert_price, "#.##"), alert.freq_once_per_bar_close)
    if alertBullPivot and dir == -1
        alert("Bullish ZigZag Pivot Confirmed @ " + str.tostring(alert_price, "#.##"), alert.freq_once_per_bar_close)
    if alertBearPivot and dir == 1
        alert("Bearish ZigZag Pivot Confirmed @ " + str.tostring(alert_price, "#.##"), alert.freq_once_per_bar_close)

    bool cur_compression_watch = compression_streak >= 3
    if alertCompression and cur_compression_watch and not prev_compression_watch
        alert("Compression Breakout Watch: " + str.tostring(compression_streak) + " consecutive compressed swings — breakout likely", alert.freq_once_per_bar_close)
    if cur_compression_watch and not prev_compression_watch
        scan_compression := true
    prev_compression_watch := cur_compression_watch

    if alertExpansion and array.size(swing_heights) >= 2
        float avg_prior = calc_rolling_avg_excl_last(swing_heights, rollingLookback)
        if not na(avg_prior) and avg_prior > 0
            float cur_h = array.get(swing_heights, array.size(swing_heights) - 1)
            float ratio = cur_h / avg_prior
            if ratio >= 1.5
                alert("Volatility Expansion: swing is " + str.tostring(truncate(ratio, 2)) + "x rolling avg height", alert.freq_once_per_bar_close)
                scan_expansion := true

    if array.size(swing_heights) > 0 and not na(atrVal)
        float last_h = array.get(swing_heights, array.size(swing_heights) - 1)
        scan_last_swing := last_h
        scan_atr := atrVal
        if last_h < atrVal
            if alertWhipsaw
                alert("Whipsaw Warning: swing height " + str.tostring(truncate(last_h, 2)) + " < 1 ATR (" + str.tostring(truncate(atrVal, 2)) + ")", alert.freq_once_per_bar_close)
            scan_whipsaw := true

// ============ TABLES ============ //
var table t1 = table.new(position.top_right,    4, 10, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
var table t2 = table.new(position.middle_right, 4, 5,  bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
var table t3 = table.new(position.bottom_right, 3, 7,  bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
var table t4 = table.new(position.top_left,     3, 7,  bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
var table t5 = table.new(position.middle_left,  3, 7,  bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
var table t6 = table.new(position.bottom_left,  3, 7,  bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
var table t7 = table.new(position.bottom_center, 6, 23, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)

if barstate.islast
    if t1_show
        table.set_position(t1, get_table_pos(t1_pos))
        sz = get_table_size(t1_size)
        bg = tableBgCol
        table.cell(t1, 0, 0, "ZZ Metric", bgcolor=color.new(color.blue, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 1, 0, "Theoretical", bgcolor=color.new(color.blue, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 2, 0, "Confirmed", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 3, 0, "Lag Cost", bgcolor=color.new(color.orange, 70), text_color=color.white, text_size=sz)
        table.cell(t1, 0, 1, "Count", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 1, 1, str.tostring(array.size(theoretical_moves)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t1, 2, 1, str.tostring(array.size(confirmed_moves)), bgcolor=bg, text_color=color.yellow, text_size=sz)
        table.cell(t1, 3, 1, "-", bgcolor=bg, text_color=color.gray, text_size=sz)

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

        if array.size(theoretical_moves) >= 1
            float t1t = array.get(theoretical_moves, array.size(theoretical_moves) - 1)
            float t1r = array.get(confirmed_moves, array.size(confirmed_moves) - 1)
            float t1l = array.get(lag_costs, array.size(lag_costs) - 1)
            string t1d = t1t > 0 ? "▲ BULL" : "▼ BEAR"
            table.cell(t1, 0, 7, "Trade #1 (" + t1d + ")", bgcolor=bg, text_color=color.white, text_size=sz)
            table.cell(t1, 1, 7, (t1t > 0 ? "+" : "") + str.tostring(truncate(t1t, 2)) + "%", bgcolor=bg, text_color=t1t > 0 ? color.green : color.red, text_size=sz)
            table.cell(t1, 2, 7, (t1r > 0 ? "+" : "") + str.tostring(truncate(t1r, 2)) + "%", bgcolor=bg, text_color=t1r > 0 ? color.yellow : color.orange, text_size=sz)
            table.cell(t1, 3, 7, str.tostring(truncate(t1l, 2)) + "%", bgcolor=bg, text_color=color.orange, text_size=sz)
        if array.size(theoretical_moves) >= 2
            float t2t = array.get(theoretical_moves, array.size(theoretical_moves) - 2)
            float t2r = array.get(confirmed_moves, array.size(confirmed_moves) - 2)
            float t2l = array.get(lag_costs, array.size(lag_costs) - 2)
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
                diag_tip := "Confirmed close-to-close result is not positive."
            else if edge_ratio < 1.0
                diag_status := "WEAK EDGE (HIGH LAG)"
                diag_color := color.orange
                diag_tip := "ATR lag eats more than the confirmed result."
            else
                diag_status := "HEALTHY EDGE"
                diag_color := color.green
                diag_tip := "Confirmed result is larger than ATR lag."
        table.cell(t1, 0, 9, "System Health", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t1, 1, 9, diag_status, bgcolor=color.new(diag_color, 85), text_color=diag_color, text_size=sz, tooltip=diag_tip)
        table.cell(t1, 2, 9, "Ratio: " + (avg_lag > 0 ? str.tostring(truncate(avg_conf / avg_lag, 2)) + "x" : "N/A"), bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t1, 3, 9, sample_size >= 5 ? "N=" + str.tostring(sample_size) : "Low Sample", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    if t2_show
        table.set_position(t2, get_table_pos(t2_pos))
        sz = get_table_size(t2_size)
        bg = tableBgCol
        table.cell(t2, 0, 0, "ZZ Geometry", bgcolor=color.new(color.teal, 70), text_color=color.white, text_size=sz)
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

    if t3_show
        table.set_position(t3, get_table_pos(t3_pos))
        sz = get_table_size(t3_size)
        bg = tableBgCol
        table.cell(t3, 0, 0, "ZZ Time Metric", bgcolor=color.new(color.aqua, 70), text_color=color.white, text_size=sz)
        table.cell(t3, 1, 0, "Value", bgcolor=color.new(color.aqua, 70), text_color=color.white, text_size=sz)
        table.cell(t3, 2, 0, "Note", bgcolor=color.new(color.aqua, 70), text_color=color.white, text_size=sz)
        float avg_h = calc_average(swing_heights)
        float avg_d = calc_average_int(swing_durations)
        float bars_per_height = (not na(avg_h) and avg_h > 0 and not na(avg_d)) ? avg_d / avg_h : na
        float avg_up_dur = na
        float avg_dn_dur = na
        if array.size(swing_directions) > 0 and array.size(swing_durations) == array.size(swing_directions)
            float sum_up = 0.0
            float sum_dn = 0.0
            int cnt_up = 0
            int cnt_dn = 0
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
        float avg_bars_conf = calc_average_int(bars_to_confirm)
        int d_count = array.size(swing_durations)
        float avg_dur_prior = d_count >= 2 ? calc_rolling_avg_excl_last_int(swing_durations, rollingLookback) : na
        float cur_dur = d_count > 0 ? array.get(swing_durations, d_count - 1) : na
        float dur_ratio = (not na(avg_dur_prior) and avg_dur_prior > 0) ? cur_dur / avg_dur_prior : na
        table.cell(t3, 0, 1, "Bars per Height Unit", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 1, na(bars_per_height) ? "-" : str.tostring(truncate(bars_per_height, 4)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 2, 1, "Lower = faster", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t3, 0, 2, "Avg Bars to Confirm", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 2, na(avg_bars_conf) ? "-" : str.tostring(truncate(avg_bars_conf, 1)), bgcolor=bg, text_color=color.yellow, text_size=sz)
        table.cell(t3, 2, 2, "ATR lag (bars)", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t3, 0, 3, "Avg Up Duration", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 3, na(avg_up_dur) ? "-" : str.tostring(truncate(avg_up_dur, 1)), bgcolor=bg, text_color=color.green, text_size=sz)
        table.cell(t3, 2, 3, "bars", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t3, 0, 4, "Avg Down Duration", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 4, na(avg_dn_dur) ? "-" : str.tostring(truncate(avg_dn_dur, 1)), bgcolor=bg, text_color=color.red, text_size=sz)
        table.cell(t3, 2, 4, "bars", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t3, 0, 5, "Time Symmetry", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 1, 5, na(time_sym) ? "-" : str.tostring(truncate(time_sym, 2)) + "x", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t3, 2, 5, "Up/Down duration ratio", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t3, 0, 6, "Current vs Avg Duration", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t3, 1, 6, na(dur_ratio) ? "N/A" : str.tostring(truncate(dur_ratio, 2)) + "x", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t3, 2, 6, na(cur_dur) ? "-" : str.tostring(cur_dur) + " bars", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    if t4_show
        table.set_position(t4, get_table_pos(t4_pos))
        sz = get_table_size(t4_size)
        bg = tableBgCol
        table.cell(t4, 0, 0, "ZZ Momentum", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=sz)
        table.cell(t4, 1, 0, "Value", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=sz)
        table.cell(t4, 2, 0, "Note", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=sz)
        float avg_eff = calc_average(efficiency_ratios)
        float avg_up_h = na
        float avg_dn_h = na
        if array.size(swing_directions) > 0 and array.size(swing_heights) == array.size(swing_directions)
            float sum_up = 0.0
            float sum_dn = 0.0
            int cnt_up = 0
            int cnt_dn = 0
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
        int h_count_m = array.size(swing_heights)
        float cont_ratio = na
        if h_count_m >= 2
            float cur_h = array.get(swing_heights, h_count_m - 1)
            float prev_h = array.get(swing_heights, h_count_m - 2)
            if prev_h > 0
                cont_ratio := cur_h / prev_h
        float cum_dir_mv = na
        if not na(avg_up_h) and not na(avg_dn_h) and array.size(swing_directions) > 0
            float total_up = 0.0
            float total_dn = 0.0
            for i = 0 to array.size(swing_directions) - 1
                if array.get(swing_directions, i) == 1
                    total_up += array.get(swing_heights, i)
                else
                    total_dn += array.get(swing_heights, i)
            cum_dir_mv := total_up - total_dn
        table.cell(t4, 0, 1, "Avg Efficiency Ratio", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 1, 1, na(avg_eff) ? "-" : str.tostring(truncate(avg_eff, 3)), bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 2, 1, "Net/Path (1.0 = perfect)", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t4, 0, 2, "Avg Up Height", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 1, 2, na(avg_up_h) ? "-" : str.tostring(truncate(avg_up_h, 2)), bgcolor=bg, text_color=color.green, text_size=sz)
        table.cell(t4, 2, 2, "Up swings avg", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t4, 0, 3, "Avg Down Height", bgcolor=bg, text_color=color.white, text_size=sz)
        table.cell(t4, 1, 3, na(avg_dn_h) ? "-" : str.tostring(truncate(avg_dn_h, 2)), bgcolor=bg, text_color=color.red, text_size=sz)
        table.cell(t4, 2, 3, "Down swings avg", bgcolor=bg, text_color=color.silver, text_size=sz)
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

    if t5_show
        table.set_position(t5, get_table_pos(t5_pos))
        sz = get_table_size(t5_size)
        bg = tableBgCol
        table.cell(t5, 0, 0, "ZZ Volatility", bgcolor=color.new(color.olive, 70), text_color=color.white, text_size=sz)
        table.cell(t5, 1, 0, "Value", bgcolor=color.new(color.olive, 70), text_color=color.white, text_size=sz)
        table.cell(t5, 2, 0, "Note", bgcolor=color.new(color.olive, 70), text_color=color.white, text_size=sz)
        float h_stdev = calc_stdev(swing_heights)
        float h_avg   = calc_average(swing_heights)
        float h_cv    = (not na(h_stdev) and not na(h_avg) and h_avg > 0) ? h_stdev / h_avg : na
        float h_slope = na
        int h_sz = array.size(swing_heights)
        if h_sz >= 5
            int lookback = math.min(rollingLookback, h_sz)
            int start_i = h_sz - lookback
            float sum_x = 0.0
            float sum_y = 0.0
            float sum_xy = 0.0
            float sum_x2 = 0.0
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
        table.cell(t5, 2, 2, "StDev / Avg", bgcolor=bg, text_color=color.silver, text_size=sz)
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
        table.cell(t5, 2, 5, "Consec. <0.7x avg", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t5, 0, 6, "Regime Status", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t5, 1, 6, streak_status, bgcolor=color.new(streak_col, 85), text_color=streak_col, text_size=sz)
        table.cell(t5, 2, 6, compression_streak >= 3 ? "Breakout watch" : "—", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    if t6_show
        table.set_position(t6, get_table_pos(t6_pos))
        sz = get_table_size(t6_size)
        bg = tableBgCol
        table.cell(t6, 0, 0, "ZZ Risk/Quality", bgcolor=color.new(color.maroon, 70), text_color=color.white, text_size=sz)
        table.cell(t6, 1, 0, "Value", bgcolor=color.new(color.maroon, 70), text_color=color.white, text_size=sz)
        table.cell(t6, 2, 0, "Note", bgcolor=color.new(color.maroon, 70), text_color=color.white, text_size=sz)
        int n_conf = array.size(confirmed_moves)
        int wins = 0
        int losses = 0
        float gross_win = 0.0
        float gross_loss = 0.0
        if n_conf > 0
            for i = 0 to n_conf - 1
                float mv = array.get(confirmed_moves, i)
                if mv > 0
                    wins += 1
                    gross_win += mv
                else if mv < 0
                    losses += 1
                    gross_loss += math.abs(mv)
        float win_rate = n_conf > 0 ? (wins * 100.0) / n_conf : na
        float profit_factor = gross_loss > 0 ? gross_win / gross_loss : na
        float avg_win = wins > 0 ? gross_win / wins : 0.0
        float avg_loss = losses > 0 ? gross_loss / losses : 0.0
        float expectancy = na
        if n_conf > 0
            expectancy := ((wins / n_conf) * avg_win) - ((losses / n_conf) * avg_loss)
        float worst_move = calc_min(confirmed_moves)
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
        table.cell(t6, 2, 5, "Longest losing run", bgcolor=bg, text_color=color.silver, text_size=sz)
        table.cell(t6, 0, 6, "Whipsaw Count", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)
        table.cell(t6, 1, 6, str.tostring(whipsaws), bgcolor=color.new(color.blue, 90), text_color=whipsaws > array.size(swing_heights) * 0.5 ? color.orange : color.white, text_size=sz)
        table.cell(t6, 2, 6, "Swings < 1 ATR", bgcolor=color.new(color.blue, 90), text_color=color.white, text_size=sz)

    if sim_showTable and sim_show
        table.set_position(t7, get_table_pos(sim_pos))
        sz = get_table_size(sim_size)
        bg = tableBgCol
        table.cell(t7, 0, 0, "Similarity", bgcolor=color.new(color.fuchsia, 70), text_color=color.white, text_size=sz)
        table.cell(t7, 1, 0, "Date (UTC)", bgcolor=color.new(color.fuchsia, 70), text_color=color.white, text_size=sz)
        table.cell(t7, 2, 0, "Dir", bgcolor=color.new(color.fuchsia, 70), text_color=color.white, text_size=sz)
        table.cell(t7, 3, 0, "Score", bgcolor=color.new(color.fuchsia, 70), text_color=color.white, text_size=sz)
        table.cell(t7, 4, 0, "Swing %", bgcolor=color.new(color.fuchsia, 70), text_color=color.white, text_size=sz)
        table.cell(t7, 5, 0, "Next %", bgcolor=color.new(color.fuchsia, 70), text_color=color.white, text_size=sz)

        string q_date = array.size(sim_times) > 0 ? str.format_time(array.get(sim_times, array.size(sim_times) - 1), sim_dateFmt, "UTC") : "-"
        int q_dir = array.size(sim_dirs) > 0 ? array.get(sim_dirs, array.size(sim_dirs) - 1) : 0
        float q_pct = array.size(sim_heights) > 0 ? array.get(sim_heights, array.size(sim_heights) - 1) : na
        table.cell(t7, 0, 1, "Query", bgcolor=color.new(color.blue, 80), text_color=color.white, text_size=sz)
        table.cell(t7, 1, 1, q_date, bgcolor=color.new(color.blue, 80), text_color=color.white, text_size=sz)
        table.cell(t7, 2, 1, q_dir > 0 ? "▲" : "▼", bgcolor=color.new(color.blue, 80), text_color=q_dir > 0 ? color.lime : color.red, text_size=sz)
        table.cell(t7, 3, 1, "—", bgcolor=color.new(color.blue, 80), text_color=color.gray, text_size=sz)
        table.cell(t7, 4, 1, na(q_pct) ? "-" : str.tostring(truncate(q_pct, 2)) + "%", bgcolor=color.new(color.blue, 80), text_color=q_pct > 0 ? color.lime : color.red, text_size=sz)
        table.cell(t7, 5, 1, "open", bgcolor=color.new(color.blue, 80), text_color=color.gray, text_size=sz)

        int n_rows = math.min(array.size(sim_analog_times), sim_k)
        for k = 0 to sim_k - 1
            int row = k + 2
            if k < n_rows
                int d = array.get(sim_analog_dirs, k)
                float sc = array.get(sim_analog_scores, k) * 100
                float sw = array.get(sim_analog_swings, k)
                float nx = array.get(sim_analog_next, k)
                table.cell(t7, 0, row, "#" + str.tostring(k + 1), bgcolor=bg, text_color=color.white, text_size=sz)
                table.cell(t7, 1, row, str.format_time(array.get(sim_analog_times, k), sim_dateFmt, "UTC"), bgcolor=bg, text_color=color.silver, text_size=sz)
                table.cell(t7, 2, row, d > 0 ? "▲" : "▼", bgcolor=bg, text_color=d > 0 ? color.lime : color.red, text_size=sz)
                table.cell(t7, 3, row, str.tostring(truncate(sc, 0)) + "%", bgcolor=bg, text_color=color.aqua, text_size=sz)
                table.cell(t7, 4, row, str.tostring(truncate(sw, 2)) + "%", bgcolor=bg, text_color=sw > 0 ? color.lime : color.red, text_size=sz)
                table.cell(t7, 5, row, na(nx) ? "n/a" : str.tostring(truncate(nx, 2)) + "%", bgcolor=bg, text_color=na(nx) ? color.gray : (nx > 0 ? color.lime : color.red), text_size=sz)
            else
                table.cell(t7, 0, row, "", bgcolor=bg, text_color=color.gray, text_size=sz)
                table.cell(t7, 1, row, "", bgcolor=bg, text_color=color.gray, text_size=sz)
                table.cell(t7, 2, row, "", bgcolor=bg, text_color=color.gray, text_size=sz)
                table.cell(t7, 3, row, "", bgcolor=bg, text_color=color.gray, text_size=sz)
                table.cell(t7, 4, row, "", bgcolor=bg, text_color=color.gray, text_size=sz)
                table.cell(t7, 5, row, "", bgcolor=bg, text_color=color.gray, text_size=sz)

        int foot = sim_k + 2
        //var table t7 = table.new(position.bottom_center, 6, sim_k + 3, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)
        table.cell(t7, 1, foot, sim_verdict, bgcolor=color.new(sim_verdict_col, 85), text_color=sim_verdict_col, text_size=sz)
        table.cell(t7, 2, foot, "n=" + str.tostring(sim_match_count), bgcolor=color.new(sim_verdict_col, 85), text_color=color.white, text_size=sz)
        table.cell(t7, 3, foot, na(sim_best_score) ? "-" : str.tostring(truncate(sim_best_score * 100, 1)) + "%", bgcolor=color.new(sim_verdict_col, 85), text_color=color.white, text_size=sz)
        table.cell(t7, 4, foot, "avg next", bgcolor=color.new(sim_verdict_col, 85), text_color=color.white, text_size=sz)
        table.cell(t7, 5, foot, na(sim_avg_follow) ? "-" : str.tostring(truncate(sim_avg_follow, 2)) + "%", bgcolor=color.new(sim_verdict_col, 85), text_color=sim_avg_follow > 0 ? color.lime : color.red, text_size=sz)

// ============ ZIGZAG DRAWING ============ //
var line  cur_line  = na
var label cur_label = na

if array.size(ziggyzags) >= 6 and inDateRange
    float val          = array.get(ziggyzags, 0)
    int   point        = math.round(array.get(ziggyzags, 1))
    float val1         = array.get(ziggyzags, 3)
    int   point1       = math.round(array.get(ziggyzags, 4))
    float confirm_prev = array.get(ziggyzags, 5)

    if dirchanged
        cur_line := na
        cur_label := na

    if showline
        line.delete(cur_line)
        cur_line := line.new(x1=point1, y1=val1, x2=point, y2=val, color=dir == 1 ? upcolor : downcolor, width=zigwidth, style=zigstyle == "Solid" ? line.style_solid : line.style_dotted)

    if showperc
        label.delete(cur_label)
        float theo_perc = percent(val, val1)
        float real_perc = percent(close, confirm_prev)
        float height    = math.abs(val - val1)
        int   duration  = math.abs(point - point1)
        string plabel = str.tostring(val, "#.##") + "\nTheo: " + (theo_perc > 0 ? "+" : "") + str.tostring(truncate(theo_perc, 2)) + "%\nReal: " + (real_perc > 0 ? "+" : "") + str.tostring(truncate(real_perc, 2)) + "%\nH: " + str.tostring(truncate(height, 2)) + " | D: " + str.tostring(duration) + " bars"
        color labelcol = dir == 1 ? (val > out ? upcolor : downcolor) : (val < out ? downcolor : upcolor)
        cur_label := label.new(x=point, y=val, text=plabel, color=labelcol, textcolor=txtcol, style=dir == 1 ? label.style_label_down : label.style_label_up)

// ============ ANALOG MARKERS ============ //
var array<line>  sim_lines  = array.new_line(0)
var array<label> sim_labels = array.new_label(0)

if barstate.islast and sim_show and sim_showLines
    if array.size(sim_lines) > 0
        for i = 0 to array.size(sim_lines) - 1
            line.delete(array.get(sim_lines, i))
        array.clear(sim_lines)
    if array.size(sim_labels) > 0
        for i = 0 to array.size(sim_labels) - 1
            label.delete(array.get(sim_labels, i))
        array.clear(sim_labels)

    int n_draw = math.min(array.size(sim_analog_bars), sim_maxLines)
    if n_draw > 0
        for i = 0 to n_draw - 1
            int   b  = array.get(sim_analog_bars, i)
            int   t  = array.get(sim_analog_times, i)
            float sc = array.get(sim_analog_scores, i)
            int   d  = array.get(sim_analog_dirs, i)
            float p  = array.get(sim_analog_prices, i)
            float sw = array.size(sim_analog_swings) > i ? array.get(sim_analog_swings, i) : na
            float nx = array.size(sim_analog_next) > i ? array.get(sim_analog_next, i) : na
            line ln = line.new(x1=b, y1=p * 0.997, x2=b, y2=p * 1.003, color=color.new(color.fuchsia, 20), width=2, style=line.style_dotted)
            array.push(sim_lines, ln)
            string txt = "#" + str.tostring(i + 1) + "  " + str.tostring(truncate(sc * 100, 0)) + "%\n" + str.format_time(t, sim_dateFmt, "UTC") + "\nSwing " + (na(sw) ? "-" : str.tostring(truncate(sw, 2)) + "%") + "  Next " + (na(nx) ? "n/a" : str.tostring(truncate(nx, 2)) + "%")
            label lb = label.new(x=b, y=p, text=txt, color=color.new(color.fuchsia, 20), textcolor=color.white, style=d > 0 ? label.style_label_down : label.style_label_up, size=size.small)
            array.push(sim_labels, lb)

// ============ ALERTCONDITIONS + SCREENER PLOTS ============ //
bool np_pivot_confirmed = scan_pivot_confirmed and barstate.isconfirmed
bool np_bull_pivot      = scan_bull_pivot      and barstate.isconfirmed
bool np_bear_pivot      = scan_bear_pivot      and barstate.isconfirmed
bool np_compression     = scan_compression     and barstate.isconfirmed
bool np_expansion       = scan_expansion       and barstate.isconfirmed
bool np_whipsaw         = scan_whipsaw         and barstate.isconfirmed
bool np_health_change   = scan_health_change   and barstate.isconfirmed
bool np_bias_bull_shift = scan_bias_bull_shift and barstate.isconfirmed
bool np_bias_bear_shift = scan_bias_bear_shift and barstate.isconfirmed
bool np_sim_match       = scan_sim_match       and barstate.isconfirmed

alertcondition(np_pivot_confirmed, title="ZZ Pivot Confirmed",            message="ATR ZigZag Pivot Confirmed (closed bar)")
alertcondition(np_bull_pivot,      title="ZZ Bullish Pivot",              message="ATR ZigZag Bullish Pivot (closed bar)")
alertcondition(np_bear_pivot,      title="ZZ Bearish Pivot",              message="ATR ZigZag Bearish Pivot (closed bar)")
alertcondition(np_compression,     title="ZZ Compression Breakout Watch", message="Compression streak 3+ — breakout watch (closed bar)")
alertcondition(np_expansion,       title="ZZ Volatility Expansion",       message="Swing >= 1.5x rolling avg (closed bar)")
alertcondition(np_whipsaw,         title="ZZ Whipsaw (<1 ATR)",           message="Swing height < 1 ATR (closed bar)")
alertcondition(np_health_change,   title="ZZ System Health Change",       message="ATR system health status changed (closed bar)")
alertcondition(np_bias_bull_shift, title="ZZ Bias Shift Bullish",         message="Directional bias shifted bullish (closed bar)")
alertcondition(np_bias_bear_shift, title="ZZ Bias Shift Bearish",         message="Directional bias shifted bearish (closed bar)")
alertcondition(np_sim_match,       title="ZZ Similarity Match",           message="Strong similarity match with historical swings (closed bar)")

plot(np_pivot_confirmed ? 1 : 0, "ZZ Pivot Confirmed",   display=display.none)
plot(np_bull_pivot      ? 1 : 0, "ZZ Bullish Pivot",     display=display.none)
plot(np_bear_pivot      ? 1 : 0, "ZZ Bearish Pivot",     display=display.none)
plot(np_compression     ? 1 : 0, "ZZ Compression Watch", display=display.none)
plot(np_expansion       ? 1 : 0, "ZZ Expansion",         display=display.none)
plot(np_whipsaw         ? 1 : 0, "ZZ Whipsaw",           display=display.none)
plot(np_health_change   ? 1 : 0, "ZZ Health Change",     display=display.none)
plot(np_bias_bull_shift ? 1 : 0, "ZZ Bias Bull Shift",   display=display.none)
plot(np_bias_bear_shift ? 1 : 0, "ZZ Bias Bear Shift",   display=display.none)
plot(np_sim_match       ? 1 : 0, "ZZ Similarity Match",  display=display.none)

var float np_dir_bias   = na
var float np_last_swing = na
var float np_atr        = na
var float np_sim_score  = na
var float np_sim_follow = na

if barstate.isconfirmed
    np_dir_bias   := scan_dir_bias
    np_last_swing := scan_last_swing
    np_atr        := scan_atr
    np_sim_score  := sim_best_score
    np_sim_follow := sim_avg_follow

plot(np_dir_bias,   "ZZ Directional Bias",  display=display.none)
plot(np_last_swing, "ZZ Last Swing Height", display=display.none)
plot(np_atr,        "ZZ ATR",               display=display.none)
plot(np_sim_score,  "ZZ Sim Best Score",    display=display.none)
plot(np_sim_follow, "ZZ Sim Avg Follow",    display=display.none)
````
