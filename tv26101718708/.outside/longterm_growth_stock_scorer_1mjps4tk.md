# Long-Term Growth Stock Scorer

- url: https://www.tradingview.com/script/1Mjps4tk-Long-Term-Growth-Stock-Scorer/
- type: indicator
- pine_id: PUB;0f10a92dabf84992ba80cdf19660e983
- version: 1.0

## Description

Long-Term Growth Stock Scorer plots a 7-criterion scoring system on any stock, identifying high-quality growth setups and signaling 200 EMA retest entries. Designed for long-term investors building positions in trending stocks with confirmed strength across trend, momentum, and participation.

THE 7-CRITERION SCORECARD

Each stock is scored 0-7 based on:

Price above daily 200 EMA — primary trend
50 EMA above 200 EMA — golden cross alignment
200 EMA sloping up — confirmed long-term uptrend
Price above weekly 200 EMA — multi-timeframe confirmation
Relative strength vs benchmark (S&P 500, NASDAQ 100, TSX Composite, FTSE, ASX, Russell 2000, or any custom symbol)
RSI in healthy range (40-70) — momentum quality, not exhausted
Volume trend rising — institutional participation expanding

SIGNALS

BUY label fires when a qualified stock (score >= threshold) retests its 200 EMA on volume
WEAK label fires when a held position drops below the qualification threshold
Background highlight when current score is in the qualified zone
Three built-in alerts: buy signal, score weakening, and score strengthening (entering the qualified zone)

FEATURES

Configurable benchmark index — works for any major market or custom symbol
Live dashboard showing each criterion's pass/fail status, current RSI value, and distance from 200 EMA

Six dashboard position options
Adjustable minimum score threshold (default 5/7)
Volume confirmation toggle for retest signals

HOW TO USE

Run on any stock chart on the daily timeframe. Set your benchmark to match the stock's market (S&P 500 for US stocks, TSX Composite for Canadian stocks, etc.). Use the dashboard to scan watchlist stocks for current qualification. When a qualified stock retests its 200 EMA on rising volume, the BUY signal fires.

Best used as a confirmation layer alongside fundamental analysis — strong technical setups need strong businesses underneath.

Open-source. Feedback and forks welcome.

## Source Code

````pine
//@version=5
// =============================================================================
// Long-Term Growth Stock Scorer — v2.0
// -----------------------------------------------------------------------------
// Multi-criterion growth stock filter for long-term investors. Scores any stock
// on a 7-point scorecard combining trend (daily and weekly 200 EMA, golden
// cross, EMA slope), relative strength vs a benchmark index, momentum quality
// (RSI band), and volume participation trend. Fires a buy signal when a
// qualified stock retests its 200 EMA on volume, and a score-dropped warning
// when a held position weakens.
//
// Configurable benchmark index — works for US (S&P 500), Canadian (TSX
// Composite), UK (FTSE), Australian (ASX 200), or any custom symbol.
//
// Author: [your handle]
// Version: 2.0
// =============================================================================

indicator("Long-Term Growth Stock Scorer", shorttitle="GROWTH", overlay=true, max_lines_count=100, max_labels_count=100)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
g_score   = "Scoring & Signals"
g_bench   = "Benchmark Index"
g_filter  = "Volume Filter"
g_display = "Display"

// Scoring & Signals
min_score    = input.int(5, "Minimum Score for Buy Signal", group=g_score, minval=1, maxval=7, tooltip="Stock must hit this score for the BUY label to fire on a 200 EMA retest.")
show_ema50   = input.bool(true, "Show 50 EMA", group=g_score)
show_ema200  = input.bool(true, "Show 200 EMA", group=g_score)
show_signals = input.bool(true, "Show BUY/WEAK Labels", group=g_score)
show_bg      = input.bool(true, "Highlight Qualified Zone (background)", group=g_score)

// Benchmark Index
benchmark_choice = input.string("S&P 500", "Benchmark Index", group=g_bench, options=["S&P 500", "NASDAQ 100", "Russell 2000", "TSX Composite", "FTSE 100", "ASX 200", "Custom"])
custom_benchmark = input.symbol("SP:SPX", "Custom Benchmark Symbol", group=g_bench, tooltip="Used only when 'Custom' is selected above. Pick any index or ETF the stock should be measured against.")

// Volume Filter
use_volume     = input.bool(true,  "Require Volume on Retest", group=g_filter)
vol_sma_len    = input.int(50,     "Volume SMA Length",        group=g_filter, minval=10)
vol_multiplier = input.float(1.2,  "Volume Multiplier",        group=g_filter, step=0.1, minval=1.0, tooltip="Retest bar volume must exceed average × this multiplier.")

// Display
dash_position = input.string("Top Right", "Dashboard Position", group=g_display, options=["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"])
show_dash     = input.bool(true, "Show Score Dashboard", group=g_display)

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

// Resolve benchmark choice → symbol
get_benchmark() =>
    switch benchmark_choice
        "S&P 500"       => "SP:SPX"
        "NASDAQ 100"    => "NASDAQ:NDX"
        "Russell 2000"  => "TVC:RUT"
        "TSX Composite" => "TSX:TSX"
        "FTSE 100"      => "TVC:UKX"
        "ASX 200"       => "ASX:XJO"
        "Custom"        => custom_benchmark
        =>                 "SP:SPX"

benchmark_symbol = get_benchmark()

f_dash_pos() =>
    switch dash_position
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        =>                 position.top_right

f_pct_str(value) =>
    str.tostring(math.round(value * 100, 1)) + "%"

f_status_txt(passed) =>
    passed ? "YES" : "NO"

f_status_bg(passed) =>
    passed ? color.new(#00C853, 30) : color.new(#FF1744, 30)

// ─────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────

// Daily EMAs (current symbol)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
ema200_slope = ema200 - ema200[10]

// Weekly 200 EMA — calculated outside request.security to avoid v5 fragility
weekly_close_func()  => close
weekly_ema200_func() => ta.ema(close, 200)

[weekly_close, weekly_ema200] = request.security(syminfo.tickerid, "W", [weekly_close_func(), weekly_ema200_func()], lookahead=barmerge.lookahead_off)

// Benchmark data (calculated outside request.security)
benchmark_close_func()  => close
benchmark_ema200_func() => ta.ema(close, 200)

[bench_close, bench_ema200] = request.security(benchmark_symbol, "D", [benchmark_close_func(), benchmark_ema200_func()], lookahead=barmerge.lookahead_off)

// Relative Strength: stock's normalized position vs benchmark's normalized position
rs_ratio = (close / ema200) / (bench_close / bench_ema200)

// RSI (14)
rsi_val = ta.rsi(close, 14)

// Volume trend: current 20-day avg vs avg from 50 days ago
vol_20_now  = ta.sma(volume, 20)
vol_20_then = ta.sma(volume, 20)[50]
volume_rising = not na(vol_20_now) and not na(vol_20_then) and vol_20_now > vol_20_then

// Volume filter for entry signal
vol_sma = ta.sma(volume, vol_sma_len)
vol_ok  = not use_volume or volume > vol_sma * vol_multiplier

// ─────────────────────────────────────────────
// 7-CRITERION SCORE
// ─────────────────────────────────────────────

c1_daily_above   = close > ema200                                          // Above daily 200 EMA
c2_golden_cross  = ema50 > ema200                                          // 50 EMA above 200 EMA
c3_ema200_rising = ema200_slope > 0                                        // 200 EMA is sloping up
c4_weekly_above  = weekly_close > weekly_ema200                            // Above weekly 200 EMA
c5_rs_strong     = rs_ratio > 1.0                                          // Outperforming benchmark
c6_rsi_healthy   = rsi_val >= 40 and rsi_val <= 70                         // Momentum healthy, not exhausted
c7_volume_rising = volume_rising                                           // Participation expanding

score = (c1_daily_above ? 1 : 0) + (c2_golden_cross ? 1 : 0) + (c3_ema200_rising ? 1 : 0) + (c4_weekly_above ? 1 : 0) + (c5_rs_strong ? 1 : 0) + (c6_rsi_healthy ? 1 : 0) + (c7_volume_rising ? 1 : 0)

// ─────────────────────────────────────────────
// SIGNALS
// ─────────────────────────────────────────────

// 200 EMA retest with deduplication (avoids consecutive-bar spam during chop)
near_ema200 = low <= ema200 * 1.003 and close > ema200
retest_now  = near_ema200 and not near_ema200[1] and not near_ema200[2] and not near_ema200[3]

buy_signal = retest_now and score >= min_score and vol_ok

// Score state changes for watchlist alerts
score_dropped     = score < min_score and score[1] >= min_score
score_strengthened = score >= min_score and score[1] < min_score

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────

plot(show_ema200 ? ema200 : na, "200 EMA", color=color.orange, linewidth=2)
plot(show_ema50  ? ema50  : na, "50 EMA",  color=color.blue,   linewidth=1)

plotshape(show_signals and buy_signal,    title="Buy Signal",      style=shape.labelup,   location=location.belowbar, color=color.new(#00C853, 0), textcolor=color.white, text="BUY",  size=size.normal)
plotshape(show_signals and score_dropped, title="Score Dropped",   style=shape.labeldown, location=location.abovebar, color=color.new(#FF1744, 0), textcolor=color.white, text="WEAK", size=size.small)

bgcolor(show_bg and score >= min_score ? color.new(#00C853, 95) : na, title="Qualified Zone")

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────

var table dash = table.new(f_dash_pos(), 2, 11, border_width=1, border_color=color.new(color.gray, 60), frame_width=2, frame_color=color.new(#1F4E79, 0))

if barstate.islast and show_dash
    c_hdr  = color.new(#1F4E79, 0)
    c_txt  = color.white
    c_pass = color.new(#00C853, 30)
    c_fail = color.new(#FF1744, 30)
    c_row  = color.new(#1a1a2e, 80)

    // Header
    table.cell(dash, 0, 0, "GROWTH SCORECARD", text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.merge_cells(dash, 0, 0, 1, 0)

    // Column headers
    table.cell(dash, 0, 1, "CRITERION", text_color=c_txt, bgcolor=c_hdr, text_size=size.small)
    table.cell(dash, 1, 1, "STATUS",    text_color=c_txt, bgcolor=c_hdr, text_size=size.small)

    // Criterion rows
    table.cell(dash, 0, 2, "Above Daily 200 EMA",   text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 2, f_status_txt(c1_daily_above), text_color=c_txt, bgcolor=f_status_bg(c1_daily_above), text_size=size.small)

    table.cell(dash, 0, 3, "50 > 200 EMA (Golden)", text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 3, f_status_txt(c2_golden_cross), text_color=c_txt, bgcolor=f_status_bg(c2_golden_cross), text_size=size.small)

    table.cell(dash, 0, 4, "200 EMA Sloping Up",    text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 4, f_status_txt(c3_ema200_rising), text_color=c_txt, bgcolor=f_status_bg(c3_ema200_rising), text_size=size.small)

    table.cell(dash, 0, 5, "Above Weekly 200 EMA",  text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 5, f_status_txt(c4_weekly_above), text_color=c_txt, bgcolor=f_status_bg(c4_weekly_above), text_size=size.small)

    table.cell(dash, 0, 6, "RS vs " + benchmark_choice,  text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 6, f_status_txt(c5_rs_strong), text_color=c_txt, bgcolor=f_status_bg(c5_rs_strong), text_size=size.small)

    table.cell(dash, 0, 7, "RSI Healthy (40-70)",   text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 7, f_status_txt(c6_rsi_healthy) + " (" + str.tostring(math.round(rsi_val, 0)) + ")", text_color=c_txt, bgcolor=f_status_bg(c6_rsi_healthy), text_size=size.small)

    table.cell(dash, 0, 8, "Volume Trend Rising",   text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 8, f_status_txt(c7_volume_rising), text_color=c_txt, bgcolor=f_status_bg(c7_volume_rising), text_size=size.small)

    // Distance from 200 EMA (proximity readout)
    dist_to_ema200 = (close - ema200) / ema200
    table.cell(dash, 0, 9, "Distance from 200 EMA", text_color=c_txt, bgcolor=c_row, text_size=size.small)
    table.cell(dash, 1, 9, f_pct_str(dist_to_ema200), text_color=c_txt, bgcolor=c_row, text_size=size.small)

    // Total score (highlighted)
    score_bg = score >= min_score ? color.new(#00C853, 20) : color.new(#FF1744, 20)
    table.cell(dash, 0, 10, "TOTAL SCORE", text_color=c_txt, bgcolor=color.new(#1F4E79, 30), text_size=size.small)
    table.cell(dash, 1, 10, str.tostring(score) + " / 7", text_color=c_txt, bgcolor=score_bg, text_size=size.small)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(buy_signal,         title="Growth Buy Signal",     message="{{ticker}} — 200 EMA retest with volume confirmed, score qualified. Long-term buy candidate.")
alertcondition(score_dropped,      title="Score Weakened",        message="{{ticker}} — Growth score dropped below threshold. Review position.")
alertcondition(score_strengthened, title="Score Strengthened",    message="{{ticker}} — Growth score crossed INTO qualified zone. Add to active watchlist.")
````
