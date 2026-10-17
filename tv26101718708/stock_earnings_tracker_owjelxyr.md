# Stock Earnings Tracker

- url: https://www.tradingview.com/script/OWjELXYR-Stock-Earnings-Tracker/
- type: indicator
- pine_id: PUB;3fe6697530d241ff8ff7ca295c216aa8
- version: 2.0

## Description

This indicator tracks a stock's earnings history directly on the chart. Each time an earnings report is detected, it calculates the price reaction over a defined window, keeps a running record of past earnings reactions, and displays a live statistics table summarizing win rate, average return, sample size, and days elapsed since the last report.

How it works

Earnings detection: The script pulls TradingView's built-in earnings calendar data (via the ESD: ticker syntax) to identify the exact bar on which a company reported earnings. This only works on symbols of type stock or dr (depositary receipts); other instrument types will show no data.
Pre-earnings window return: On each detected earnings day, the script measures the percentage change from the prior day's open to the earnings day's close. This approximates the market's immediate reaction to the report.
Historical sample tracking: Each new earnings-day return is stored in an array (default: last 20 events, adjustable up to 100). Older samples are dropped once the limit is reached, so statistics reflect a rolling recent history rather than the stock's entire earnings record.
Win rate / average return: From the stored sample set, the script calculates the percentage of earnings events with a positive reaction ("win rate") and the average reaction size across all stored samples.
Days since labels: A label is placed at each earnings event; when the next earnings event occurs, the prior label is updated to show how many calendar days elapsed between the two reports.
Visual cues: Labels and a subtle background tint are color-graded (green/red/gray) based on the magnitude of the earnings-day return, and a table in the top-right corner summarizes the current statistics in real time.

Inputs

Show Days Since Last Earnings Labels—toggles the days-since labeling feature on/off.
Max Historical Earnings Samples to Track—controls how many past earnings events (5–100) are retained for the win-rate/average-return calculations.

Limitations

Only functions on stocks and depositary receipts with available earnings-calendar data; results will show "N/A" elsewhere.
Statistics are based on a limited, rolling sample and may carry low statistical significance for stocks with infrequent or sparse earnings history.
The "pre-earnings window" return captures open-to-close price action around the report, not the full multi-day drift some stocks exhibit after earnings.

Recommended Usage: Weekly Timeframe

While the script will run on any timeframe, it's best suited for the WEEKLY chart:

Matches earnings cadence. Public companies report roughly once per quarter (~13 weeks apart). On a daily chart, that's 60+ bars of space between each earnings label—the weekly chart compresses this into a handful of bars, making the historical pattern of reactions much easier to read at a glance.
Cleaner statistics table context. Because max_samples defaults to a rolling window of past events, viewing on weekly lets a 20-sample lookback span roughly 5 years of earnings history in a single, uncluttered view—versus a daily chart where the same 20 samples are scattered across a much wider, harder-to-navigate range.
Less label overlap. The "Pre-E Window" and "Days Since" labels are less likely to visually collide with price action or with each other when spaced out across weekly bars.

Disclaimer

This script is provided for informational and educational purposes only. Past earnings-day performance shown by this indicator does not predict or guarantee future results. It is not financial advice and should not be used as the sole basis for any trading decision. Always combine with your own analysis and risk management.

This description was written with the assistance of AI and reviewed by the author before publishing.

Original code © patinum, licensed under the Mozilla Public License 2.0.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © patinum

//@version=6
indicator("Earnings Tracker", overlay = true)

// =====================================
// User Inputs
// =====================================
show_days_since = input.bool(true, title="Show Days Since Last Earnings Labels")
max_samples     = input.int(20, minval=5, maxval=100, title="Max Historical Earnings Samples to Track")

// =====================================
// Earnings Detection
// =====================================
new_earnings = (syminfo.type == 'stock' or syminfo.type == 'dr') 
     ? request.security('ESD:' + syminfo.prefix + ';' + syminfo.ticker + ';EARNINGS', 'D', close, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off) 
     : na

is_earnings_day = not na(new_earnings)

// =====================================
// Historical Engine & Likelihood Calculation
// =====================================
var float[] historical_returns = array.new_float()
var int last_earnings_time = na

setup_return = is_earnings_day and bar_index > 0 ? ((close - open[1]) / open[1]) * 100 : na

if is_earnings_day and not na(setup_return)
    array.unshift(historical_returns, setup_return)
    if array.size(historical_returns) > max_samples
        array.pop(historical_returns)

var float win_rate = na
var float avg_return = na
sample_size = array.size(historical_returns)

if sample_size > 0
    int win_count = 0
    float total_return = 0.0
    
    for i = 0 to sample_size - 1
        float r = array.get(historical_returns, i)
        total_return += r
        if r > 0
            win_count += 1
    
    win_rate := (win_count / sample_size) * 100
    avg_return := total_return / sample_size

// =====================================
// "Days Since" Historical Label Engine
// =====================================
var label prior_earnings_label = na

if is_earnings_day
    
    if not na(prior_earnings_label) and not na(last_earnings_time)
        days_since = math.round((time - last_earnings_time) / (1000 * 60 * 60 * 24))
        
        label.set_text(
             prior_earnings_label,
             str.tostring(days_since) + " days\nsince earnings"
         )
    
    if show_days_since
        prior_earnings_label := label.new(
             x=bar_index,
             y=ta.lowest(5),
             text="Latest Earnings\n(Tracking...)",
             style=label.style_none,
             textcolor=color.orange,
             size=size.small
         )
    
    last_earnings_time := time

// =====================================
// Visual Plots (Performance Labels & Bg)
// =====================================
get_change_color(change_pct) =>
    if change_pct >= 5.0
        color.green
    else if change_pct <= -5.0
        color.red
    else if math.abs(change_pct) < 0.01
        color.gray
    else if change_pct > 0
        intensity = math.min(change_pct / 5.0, 1.0)
        color.new(color.green, math.round(100 - (intensity * 100)))
    else
        intensity = math.min(math.abs(change_pct) / 5.0, 1.0)
        color.new(color.red, math.round(100 - (intensity * 100)))

if is_earnings_day
    chart_high = ta.highest(high, 5)
    chart_low = ta.lowest(low, 5)
    chart_range = chart_high - chart_low
    label_y = chart_high + (chart_range * 0.15)
    
    label.new(
         x=bar_index,
         y=label_y,
         text=str.tostring(setup_return, "#.##") + "%\nE-Window",
         style=label.style_none,
         textcolor=get_change_color(setup_return),
         size=size.normal
     )

bgcolor(is_earnings_day ? color.new(get_change_color(setup_return), 80) : na)

// =====================================
// Statistics Dashboard Table
// =====================================
var table stats_table = table.new(
     position.top_right,
     2,
     4,
     bgcolor=color.new(color.black, 80),
     border_color=color.gray,
     border_width=1
 )

if barstate.islast
    
    // Live calculation of days since most recent earnings
    current_days_since = not na(last_earnings_time) ? 
         math.round((time - last_earnings_time) / (1000 * 60 * 60 * 24)) : na

    table.cell(
         stats_table,
         0,
         0,
         "Likelihood of Increase (Win %)",
         text_color=color.white
     )
    
    table.cell(
         stats_table,
         1,
         0,
         na(win_rate) ? "N/A" : str.tostring(win_rate, "#.0") + "%",
         text_color=win_rate >= 50 ? color.green : color.red
     )

    table.cell(
         stats_table,
         0,
         1,
         "Avg Window Return",
         text_color=color.white
     )
    
    table.cell(
         stats_table,
         1,
         1,
         na(avg_return) ? "N/A" : str.tostring(avg_return, "#.00") + "%",
         text_color=avg_return >= 0 ? color.green : color.red
     )

    table.cell(
         stats_table,
         0,
         2,
         "Earnings Samples Tracked",
         text_color=color.white
     )
    
    table.cell(
         stats_table,
         1,
         2,
         str.tostring(sample_size),
         text_color=color.white
     )
    
    table.cell(
         stats_table,
         0,
         3,
         "Days Since Last Earnings",
         text_color=color.white
     )
    
    table.cell(
         stats_table,
         1,
         3,
         na(current_days_since) ? "N/A" : str.tostring(current_days_since) + " days",
         text_color=color.yellow
     )
````
