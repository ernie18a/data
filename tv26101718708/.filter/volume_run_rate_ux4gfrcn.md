# Volume Run Rate

- url: https://www.tradingview.com/script/UX4gFrCN-Volume-Run-Rate/
- type: indicator
- pine_id: PUB;599d47ab885544aa9181edbadbd467dd
- version: 1.0

## Description

<h1>Volume Run Rate</h1>

<h2>What it does</h2>

<p>This indicator answers a simple question that raw volume bars can't: <b>"At this point in the trading day, are we trading more or less than usual?"</b></p>

<p>It accumulates volume from the start of each day, expresses that running total as a percentage of the average full-day volume over a lookback window, and then compares the current reading to where the run rate typically sits at the same time of day historically. When today's pace pushes meaningfully above that historical norm (default: more than 2 standard deviations), the background highlights yellow.</p>

<p>Three lines are plotted:</p>

<ul>
<li><b>Green stepline</b> — today's cumulative volume so far, as a % of the average daily total over the lookback window.</li>
<li><b>Gray line</b> — the average run rate at this same time-of-day across the lookback days.</li>
<li><b>Orange crosses</b> — the upper threshold (historical same-time mean + N standard deviations). When the green line breaks above it, the day is participating unusually heavily for this point in the session.</li>
</ul>

<h2>Why intraday cumulative volume vs. history beats looking at volume alone</h2>

<p>A single volume bar tells you only what happened in the last 5 minutes (or 15, or whatever your timeframe is). That's a noisy, low-context signal. Volume is naturally lumpy intraday — the open and close are always heavy, lunch is always thin — so a "big" bar at 10:00 might be completely normal, and a "small" bar at 14:30 might actually be elevated for that time slot. Eyeballing bar height tells you almost nothing about whether real interest is building.</p>

<p>Cumulative volume from the day's open smooths out that bar-to-bar noise and captures a more meaningful quantity: <b>how much total participation has shown up so far today</b>. But "a lot" or "a little" only means something when measured against a baseline. Comparing today's cumulative volume at 11:00 to the typical cumulative volume at 11:00 over the last 20 days gives you a like-for-like read on whether today is unusually busy <i>for where we are in the session</i>. Two standard deviations above that historical mean is statistically rare — roughly the top 2-3% of historical readings at this time slot — which is why it's a useful alert level.</p>

<h2>How to use it</h2>

<p>Volume tends to confirm or contradict price moves. The run rate makes that confirmation legible in real time:</p>

<ul>
<li><b>Breakout validation.</b> Price breaks a key level intraday and the run rate is already running hot above the threshold — participation is real, the move has fuel behind it. Same breakout on a depressed run rate is much more likely to fail or fade.</li>
<li><b>Trend day vs. chop day, early.</b> If the run rate pushes through the upper threshold in the first hour or two, the day is on track for an above-average volume session, which historically correlates with directional follow-through. A run rate stuck near or below the historical average suggests a low-conviction, mean-reverting tape — fade the edges, don't chase.</li>
<li><b>News and event reaction.</b> When something hits the tape, the question isn't "did volume go up" (it almost always does for one bar) but "is the market actually engaging with this." A run rate that gaps above the threshold and stays there says yes. A spike that immediately reverts says the market dismissed it.</li>
<li><b>Distribution and accumulation timing.</b> Sustained elevated run rate at a price plateau, especially near prior highs or lows, suggests something larger going on than the price action alone reveals.</li>
<li><b>Avoiding low-conviction setups.</b> If your trade thesis depends on participation but the run rate is well below average for this time of day, that's a real signal to size down or skip.</li>
</ul>

<h2>Inputs</h2>

<ul>
<li><b>Lookback days</b> — how many prior days to use as the historical baseline. Default 20 (≈ one trading month).</li>
<li><b>Std Dev threshold</b> — how many standard deviations above the historical same-time mean triggers the elevated-volume background. Default 2.0.</li>
<li><b>Exclude weekends</b> — turn on for crypto or other 24/7 markets where weekend sessions have structurally different volume profiles than weekdays. Off by default (correct for traditional Mon-Fri markets).</li>
</ul>

<h2>Notes</h2>

<ul>
<li>Use on intraday timeframes only (anything lower than Daily). On Daily or higher, an error message is shown — the "cumulative vs. history at the same time of day" comparison only makes sense within a day.</li>
<li>The indicator stores every intraday bar's run rate in persistent arrays, which lets it look back further than Pine's standard 5000-bar history limit and compare apples to apples across the full lookback window.</li>
<li>The historical comparison uses the bar's position within the day (1st bar, 2nd bar, etc.), so it works on any intraday timeframe automatically.</li>
</ul>

## Source Code

````pine
//@version=6
indicator("Volume Run Rate", overlay=false)

// ── Inputs ──────────────────────────────────────────────────────────────────
lookback_period  = input.int(defval=20, title="Lookback days", minval=2, step=1)
std_threshold    = input.float(defval=2.0, title="Std Dev threshold", minval=0.1, step=0.1)
exclude_weekends = input.bool(defval=false, title="Exclude weekends (for crypto/24-7 markets)")

var reference_tf = "D"

// ── Timeframe guard ─────────────────────────────────────────────────────────
// This indicator compares intraday cumulative volume to history at the same
// time-of-day. On daily or higher TFs, "intraday cumulative" collapses to a
// single bar's volume and the same-time-of-day comparison loses meaning.
tfTooHigh = timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds("D")

// ── Accumulate intraday volume ──────────────────────────────────────────────
var float vol_since_day_start = 0.0

is_new_day = timeframe.change(reference_tf)

if is_new_day
    vol_since_day_start := volume
else
    vol_since_day_start += volume

// ── Day-of-week check using integers ────────────────────────────────────────
// Pine dayofweek: 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday,
//                 5=Thursday, 6=Friday, 7=Saturday
is_weekend_today = dayofweek == 1 or dayofweek == 7

// ── Compute daily average from same-timeframe end-of-day totals ─────────────
var daily_totals = array.new<float>(0)
var float prev_day_total = na
var bool prev_day_was_weekend = false

if is_new_day
    // Record the previous day's total, skipping weekends if enabled
    if not na(prev_day_total) and prev_day_total > 0
        bool skip = exclude_weekends and prev_day_was_weekend
        if not skip
            array.unshift(daily_totals, prev_day_total)
            if array.size(daily_totals) > lookback_period
                array.pop(daily_totals)
    prev_day_total := vol_since_day_start
    prev_day_was_weekend := is_weekend_today

if not is_new_day
    prev_day_total := vol_since_day_start

float daily_avg_vol = array.size(daily_totals) > 0 ? array.avg(daily_totals) : na

vol_run_rate = daily_avg_vol > 0 ? 100.0 * vol_since_day_start / daily_avg_vol : 0.0

// ── Track intra-day bar index ───────────────────────────────────────────────
var int intraday_bar_idx = 0

if is_new_day
    intraday_bar_idx := 0
else
    intraday_bar_idx += 1

// ── Store every bar's run rate and day-of-week in persistent arrays ─────────
// Avoids vol_run_rate[offset] lookups and the 5000-bar history limit.
var all_run_rates = array.new<float>(0)
var all_day_of_week = array.new<int>(0)
array.push(all_run_rates, vol_run_rate)
array.push(all_day_of_week, dayofweek)

// ── Track day boundaries (index into all_run_rates) ─────────────────────────
// Buffer must account for weekends being stored but skipped during lookup,
// so we need more day-starts than lookback_period to find enough valid days.
var int max_day_starts = lookback_period * 2 + 5
var day_start_indices = array.new<int>(0)

if is_new_day
    array.unshift(day_start_indices, array.size(all_run_rates) - 1)
    if array.size(day_start_indices) > max_day_starts
        array.pop(day_start_indices)

// ── Collect historical same-time-of-day run rates ───────────────────────────
var int last_processed_bar = -1
var historical_rates = array.new<float>(0)

if bar_index != last_processed_bar
    last_processed_bar := bar_index
    array.clear(historical_rates)

    int days_collected = 0
    int num_day_starts = array.size(day_start_indices)

    if num_day_starts > 1
        for d = 1 to num_day_starts - 1
            if days_collected >= lookback_period
                break

            int prev_day_start = array.get(day_start_indices, d)

            // Skip weekend days if enabled (check day-of-week at that day's first bar)
            if exclude_weekends and prev_day_start < array.size(all_day_of_week)
                int dow = array.get(all_day_of_week, prev_day_start)
                if dow == 1 or dow == 7
                    continue

            // Day length = next newer day's start - this day's start
            int next_day_start = array.get(day_start_indices, d - 1)
            int prev_day_bar_count = next_day_start - prev_day_start

            // Check if that day had a bar at the same intra-day position
            if intraday_bar_idx < prev_day_bar_count
                int target_idx = prev_day_start + intraday_bar_idx
                if target_idx >= 0 and target_idx < array.size(all_run_rates)
                    float past_rate = array.get(all_run_rates, target_idx)
                    if past_rate > 0
                        array.push(historical_rates, past_rate)
                        days_collected += 1

// ── Simple mean and std dev ─────────────────────────────────────────────────
int n_samples = array.size(historical_rates)

float hist_mean  = n_samples > 0 ? array.avg(historical_rates) : vol_run_rate
float hist_stdev = n_samples > 1 ? array.stdev(historical_rates) : 0.0

// ── Threshold and alert ─────────────────────────────────────────────────────
upper_threshold = hist_mean + (std_threshold * hist_stdev)
is_elevated = vol_run_rate > upper_threshold and hist_stdev > 0

// ── Visual output ───────────────────────────────────────────────────────────
// Suppress all plots/bgcolor on daily+ TF; show error table instead.
bgcolor(not tfTooHigh and is_elevated ? color.new(color.yellow, 70) : na, title="Elevated Volume Alert")

plot(tfTooHigh ? na : vol_run_rate,     "Vol Run Rate %",              color=color.lime,   linewidth=2, style=plot.style_stepline)
plot(tfTooHigh ? na : hist_mean,        "Historical Avg at This Time",  color=color.gray,   linewidth=1)
plot(tfTooHigh ? na : upper_threshold,  "Threshold (+N σ)",             color=color.orange, linewidth=1, style=plot.style_cross)

if tfTooHigh and barstate.islast
    errorTable = table.new(position.middle_center, 1, 1, color.red)
    table.cell(errorTable, 0, 0, "Use an intraday timeframe (lower than Daily). This indicator measures how today's cumulative volume compares to history at the same time-of-day — meaningless on Daily or higher.", text_size = size.large, text_color = color.white)
````
