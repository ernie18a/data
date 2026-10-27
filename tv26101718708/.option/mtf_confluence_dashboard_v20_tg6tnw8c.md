# MTF Confluence Dashboard v2.0

- url: https://www.tradingview.com/script/tG6tNW8C/
- type: indicator
- pine_id: PUB;fc8b00d46e0c43fe8cc122cacb7390ad
- version: 1.0

## Description

[b]MTF Confluence Dashboard v2.0 — Multi-Timeframe Scoring Engine
Free & Open Source  | Works on Every Asset Class[/b]
 
 
What Is This?
Most traders know the rule: [b]trade with the higher timeframe trend and your win rate goes up.[/b] The problem is actually doing it. You end up with five chart tabs open — 15min, 1h, 4h, Daily, Weekly — manually checking EMA positions and RSI levels on each one, trying to hold five pictures in your head at the same time. You miss one. You misread another. You end up fighting the trend anyway.
 
MTF Confluence Dashboard solves this in one glance.
 
It is a real-time scoring engine that reads five timeframes simultaneously for up to three symbols, crunches the data down into a single weighted score per symbol, and displays everything in a compact dashboard pinned to your chart corner. In three seconds you know: is the environment aligned for a trade, how strong is that alignment, and is the signal strong enough to act on.
 
No repaint. No lookahead. No black box. Every calculation is in the open-source code.
 

 
The Core Logic — Two Independent Votes Per Timeframe
This is not a simple "count how many timeframes agree" counter. Every timeframe casts two completely independent votes, and the results are combined into a weighted composite score.
 
Vote 1 — Structure (Where is price right now?)
● Close above the 5-period EMA → +1
● Close below the 5-period EMA → −1
● Equal → 0
 
This is the fastest, cleanest measure of short-term price structure. No crossover lag. The result updates the instant the bar closes.
 
Vote 2 — Momentum (Is strength building or fading?)
This is where the indicator separates itself from 99% of MTF tools on TradingView.
 
Most indicators use a fixed RSI threshold: RSI above 55 = bullish, below 45 = bearish. The problem? In a sustained bull market, weekly RSI sits above 55 for months. The indicator gets permanently stuck on "bullish" and never gives you a short signal — even when the trend is actually rolling over.
 
We use relative RSI momentum instead:
 
● RSI above its own EMA signal line → +1
● RSI below its own EMA signal line → −1
 
This measures where RSI is going, not where it is. A weekly RSI at 65 but falling from 70 votes bearish. A weekly RSI at 40 but rising from 35 votes bullish. The logic is perfectly symmetric and has no built-in directional bias. It works identically in bull markets, bear markets, and sideways chop.
 
Per-Timeframe Raw Score
Each timeframe produces a raw score by combining both votes:
 
EMA Vote	RSI Vote	Raw Score	Meaning
+1	+1	+2	Fully bullish — both agree
+1	0 or 0	+1	Partially bullish
0	0	0	Completely neutral
−1	0 or 0	−1	Partially bearish
−1	−1	−2	Fully bearish — both agree
 

 
The Weighted Composite Score
Not all timeframes carry equal weight. Higher timeframes define the macro environment; lower timeframes only provide entry timing context.
 
Timeframe	Default Weight	Role
Weekly (TF5)	2.0×	Macro trend — defines the big picture
Daily (TF4)	2.0×	Primary trend — most important for swing traders
4h (TF3)	1.5×	Intermediate trend
1h (TF2)	1.0×	Directional context
15min (TF1)	0.5×	Entry timing only
 
Weights are automatically normalized before scoring, so the final WScore always falls on a fixed ±20 scale regardless of how you adjust the weights. The scale is controlled by the "Score Scale" input (default: 10), meaning:
 
● +20 = All five timeframes fully bullish on both EMA and RSI — maximum confluence
● −20 = All five timeframes fully bearish on both EMA and RSI — maximum confluence
● 0 = Complete neutrality
 
All five timeframes, all weights, and the Score Scale are fully adjustable in the settings panel.
 

 
Signal Generation
A signal fires when the WScore crosses the threshold with strict greater-than logic:
 
● WScore > +10 → 🟢 Green triangle below the bar (Long signal)
● WScore < −10 → 🔴 Red triangle above the bar (Short signal)
 
The default threshold of ±10 represents exactly 50% of the maximum possible score — meaning the market needs to show majority multi-timeframe confluence before a signal is issued. This is intentionally conservative. A score of exactly ±10 does not trigger.
 
You can adjust the threshold to suit your style:
 
Threshold	Effect
±7	More frequent signals, higher sensitivity, more noise
±10 (default)	Balanced — majority confluence required
±14	High conviction only, fewer signals, misses some moves
 
Signals are perfectly symmetric. The exact same logic and threshold applies to both longs and shorts. There is no hidden bullish or bearish bias built into the system.
 
Signal arrows appear only for the symbol on your current chart. The other dashboard symbols are monitoring-only.
 

 
The Dashboard
A compact table is pinned to your chosen chart corner (Top Right by default). It contains:
 
Row 0 — Status Banner
A color-coded banner showing the current data state:
● 🟢 Green: All monitored markets are open — live data
● 🟡 Yellow: Mixed — some markets open, some closed
● 🔴 Red: Base chart session closed — all data frozen at last close
 
Row 1 — Header
Column labels: Symbol | TF1 | TF2 | TF3 | TF4 | TF5 | WScore | Vol
 
Rows 2–4 — Symbol Rows
One row per symbol. Each timeframe cell shows two characters representing the EMA and RSI votes:
 
Display	Meaning	Cell Color
▲▲	Both bullish (+2)	Dark green
▲– or –▲	One bullish, one neutral (+1)	Light green
––	Both neutral (0)	Grey
▼– or –▼	One bearish, one neutral (−1)	Light red
▼▼	Both bearish (−2)	Dark red
 
The symbol name cell (leftmost) shows market status at a glance:
● Green background = Live data, market is open
● Red background = Latest closed data, market session has ended
 
Row 5 — Score Row
Full-width row showing the WScore of your current chart symbol. Turns bright green when above the long threshold, bright red when below the short threshold.
 
Row 6–7 — Footer & Legend
Quick reference for the vote notation and score range.
 

 
Symbol 1 Auto-Sync
By default, Symbol 1 always tracks your base chart ticker automatically. Switch your chart from MU to 700.HK and the first dashboard row updates instantly — no settings change required.
 
If you prefer a fixed symbol in row 1 regardless of which chart you are on, simply uncheck "Symbol 1 = Chart Symbol (auto-sync)" in the Assets settings and enter your preferred ticker manually.
 

 
Volume Filter (Optional)
The volume filter is disabled by default and is clearly labeled optional for good reason. On many assets — particularly crypto during weekends, or equities during midday lulls — volume data is unreliable and will suppress perfectly valid signals.
 
When enabled, the filter does not block signals outright. Instead, it raises the trigger threshold by a configurable multiplier (default ×1.3) when the current bar's volume is below its 20-period SMA. A strong signal still fires; only borderline signals near the threshold edge are filtered out. The Vol column in the dashboard shows:
 
● OFF — filter disabled
● OK — filter enabled, volume passes
● ×1.3 — filter active, threshold has been raised
 
Only enable this if you have verified that your asset's volume data is consistent and reliable.
 

 
Live vs. Closed Market Detection
The indicator automatically detects whether each symbol's market is currently open or closed, with no hardcoded market hours and no asset-type lists. It checks the age of each symbol's most recent bar on TF1:
 
● If the bar is more than 35 minutes old during a realtime session → symbol is flagged as closed (red background)
● Crypto symbols are never flagged as closed since they trade 24/7
● When a closed market reopens → status clears automatically, live data resumes
 
This works correctly across all asset classes and broker prefixes: US stocks, Hong Kong stocks, forex, gold, commodities, indices, crypto.
 

 
What This Indicator Is — And Is Not
✅ What it is: A multi-timeframe environment filter. It tells you whether the macro conditions are aligned for a long, a short, or neither. It processes all five timeframes simultaneously so you never have to tab between charts again.
 
❌ What it is not: A precise entry signal. It does not tell you which exact candle to enter on, where to put your stop, or how large your position should be.
 
The indicator is designed to be the first layer of your trading system. Use it to filter out counter-trend trades before you even begin looking for an entry. Combine it with your own entry method — volume spread analysis, liquidity sweeps, support/resistance levels, or any other technique you prefer.
 

 
No Repaint. No Lookahead. No Surprises.
● All request.security() calls use lookahead=barmerge.lookahead_off — future bars have zero influence on current calculations
● Signals lock permanently the moment the triggering bar closes and never change on historical bars
● Every formula, every weight, every condition is visible in the open-source Pine Script code
 

 
Settings Reference
 
Group	Parameter	Default	Description
Assets	Symbol 1 Auto-Sync	ON	Follows base chart ticker automatically
Assets	Symbol 1 / 2 / 3	BTCUSD / AAPL / SPY	Symbols to monitor in the dashboard
Timeframes	TF1–TF5	15 / 60 / 240 / D / W	Five timeframes to score (TF1 smallest → TF5 largest)
Scoring — EMA	Fast EMA Period	5	Period of the structure EMA
Scoring — RSI	RSI Period	7	RSI lookback period
Scoring — RSI	RSI Signal Period	20	EMA period applied to RSI for momentum vote
Scoring — TF Weights	Weight TF1–TF5	0.5 / 1.0 / 1.5 / 2.0 / 2.0	Relative weight per timeframe
Scoring — TF Weights	Score Scale	10	Controls the ±20 output range
Signal	Signal Threshold	10.0	WScore must strictly exceed this to fire
Signal	Show Arrows	ON	Display signal triangles on the chart
Volume Filter	Enable	OFF	Raise threshold when volume is below SMA
Volume Filter	Vol SMA Period	20	Lookback for volume average
Volume Filter	Vol Multiplier	1.3	Threshold multiplier when volume is low
Dashboard	Position	Top Right	Dashboard placement on chart
Dashboard	Show Vol Column	ON	Show/hide the Vol status column
 

 
Disclaimer
This indicator is for informational and educational purposes only. It is not financial advice or a recommendation to buy or sell any asset. Past performance does not guarantee future results. Always do your own research and manage your own risk.
 
Open Source — Mozilla Public License 2.0
Copyright © 2026 WiseManAlgo. Free to use, study, modify, and distribute with attribution.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © WiseManAlgo

//@version=6
indicator('MTF Confluence Dashboard v2.0', shorttitle = 'MTF Confluence Dashboard v2.0', overlay = true, max_lines_count = 50, max_labels_count = 50)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Assets
// ─────────────────────────────────────────────────────────────────────────────
var string GRP_ASSETS = 'Assets'

sync_sym1 = input.bool(true, 'Symbol 1 = Chart Symbol (auto-sync)', group = GRP_ASSETS, tooltip = 'When ON, Symbol 1 always follows the base chart ticker automatically. Switch OFF to set a manual symbol.', display = display.none)
sym1_manual = input.symbol('BTCUSD', 'Symbol 1 (manual override)', group = GRP_ASSETS, display = display.none)
sym1 = sync_sym1 ? syminfo.tickerid : sym1_manual

sym2 = input.symbol('AAPL', 'Symbol 2', group = GRP_ASSETS, display = display.none)
sym3 = input.symbol('SPY', 'Symbol 3', group = GRP_ASSETS, display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Timeframes
// ─────────────────────────────────────────────────────────────────────────────
var string GRP_TF = 'Timeframes (TF1 small → TF5 large)'

tf1 = input.timeframe('15', 'TF 1', options = ['1', '5', '15'], tooltip = 'Shortest timeframe for CLO detection. Must be ≤15 min.', group = GRP_TF, display = display.none)
tf2 = input.timeframe('60', 'TF 2', tooltip = 'Should be larger than TF 1', group = GRP_TF, display = display.none)
tf3 = input.timeframe('240', 'TF 3', tooltip = 'Should be larger than TF 2', group = GRP_TF, display = display.none)
tf4 = input.timeframe('D', 'TF 4', tooltip = 'Should be larger than TF 3', group = GRP_TF, display = display.none)
tf5 = input.timeframe('W', 'TF 5', tooltip = 'Should be larger than TF 4', group = GRP_TF, display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Scoring: EMA
// ─────────────────────────────────────────────────────────────────────────────
ema_fast = input.int(5, 'Fast EMA Period', minval = 1, group = 'Scoring — EMA', display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Scoring: RSI
// ─────────────────────────────────────────────────────────────────────────────
rsi_len = input.int(7, 'RSI Period', minval = 2, group = 'Scoring — RSI', display = display.none)
rsi_sma_len = input.int(20, 'RSI Signal Period', minval = 2, group = 'Scoring — RSI', display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Scoring: TF Weights
// ─────────────────────────────────────────────────────────────────────────────
var string GRP_WEIGHTS = 'Scoring — TF Weights (adjust only if you understand scoring impact)'

w1 = input.float(0.5, 'Weight TF1', minval = 0.0, step = 0.1, group = GRP_WEIGHTS, display = display.none)
w2 = input.float(1.0, 'Weight TF2', minval = 0.0, step = 0.1, group = GRP_WEIGHTS, display = display.none)
w3 = input.float(1.5, 'Weight TF3', minval = 0.0, step = 0.1, group = GRP_WEIGHTS, display = display.none)
w4 = input.float(2.0, 'Weight TF4', minval = 0.0, step = 0.1, group = GRP_WEIGHTS, display = display.none)
w5 = input.float(2.0, 'Weight TF5', minval = 0.0, step = 0.1, group = GRP_WEIGHTS, display = display.none)
score_scale = input.float(10.0, 'Score Scale', minval = 1.0, step = 0.5, group = GRP_WEIGHTS, display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Signal
// v2.0: Default threshold raised to 10.0; condition is strictly > (not >=)
// ─────────────────────────────────────────────────────────────────────────────
sig_threshold = input.float(10.0, 'Signal Threshold (±)', minval = 0.1, step = 0.5, group = 'Signal', tooltip = 'Signal fires when WScore is STRICTLY greater than this value. Default 10.0 corresponds to 50% of the ±20 scale.', display = display.none)
show_arrows = input.bool(true, 'Show Signal Arrows on Chart', group = 'Signal', display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Volume Filter
// ─────────────────────────────────────────────────────────────────────────────
use_vol_filter = input.bool(false, 'Enable Volume Filter', group = 'Volume Filter', tooltip = 'When enabled, the signal threshold is raised if volume is below its 20-period SMA. This filters low-conviction signals during thin markets. DISCLAIMER: May suppress valid signals on assets with unreliable volume data — including crypto feeds that report zero-volume bars — and on equities during mid-session low-volume periods. Recommended OFF for most assets. Default: OFF.', display = display.none)
vol_sma_len = input.int(20, 'Volume SMA Period', minval = 1, group = 'Volume Filter', display = display.none)
vol_mult = input.float(1.3, 'Vol Threshold Multiplier', minval = 1.0, step = 0.1, group = 'Volume Filter', display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — Dashboard Display
// ─────────────────────────────────────────────────────────────────────────────
var string GRP_UI = 'Dashboard'
dash_pos = input.string('Top Right', 'Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = GRP_UI, display = display.none)
show_vol_col = input.bool(true, 'Show Volume Filter Column', group = GRP_UI, display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// CORE SCORING FUNCTION
// EMA vote: +1 if close > fast EMA, -1 if close < fast EMA, 0 if equal
// RSI vote: +1 if RSI > EMA(RSI), -1 if RSI < EMA(RSI), 0 if equal
// Returns [ema_vote, rsi_vote, raw_score, time]
// ─────────────────────────────────────────────────────────────────────────────
f_tf_score(sym, tf) =>
    [c, ef, rv, rs, t] = request.security(sym, tf, [close, ta.ema(close, ema_fast), ta.rsi(close, rsi_len), ta.ema(ta.rsi(close, rsi_len), rsi_sma_len), time], lookahead = barmerge.lookahead_off)
    ema_vote = c > ef ? 1 : c < ef ? -1 : 0
    rsi_vote = rv > rs ? 1 : rv < rs ? -1 : 0
    raw_score = ema_vote + rsi_vote
    [ema_vote, rsi_vote, raw_score, t]

// ═══════════════════════════════════════════════════════════════════════════════
// STALENESS DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
STALE_MINUTES = 35

s1_type = request.security(sym1, tf1, syminfo.type)
s2_type = request.security(sym2, tf1, syminfo.type)
s3_type = request.security(sym3, tf1, syminfo.type)

s1_is_crypto = s1_type == 'crypto'
s2_is_crypto = s2_type == 'crypto'
s3_is_crypto = s3_type == 'crypto'

// ─────────────────────────────────────────────────────────────────────────────
// COMPUTE SCORES — 3 symbols × 5 timeframes
// Each call returns 4 values — ema_vote, rsi_vote, raw_score, time
// ─────────────────────────────────────────────────────────────────────────────
[s1t1_ev, s1t1_rv, s1t1_raw, s1t1_t] = f_tf_score(sym1, tf1)
[s1t2_ev, s1t2_rv, s1t2_raw, s1t2_t] = f_tf_score(sym1, tf2)
[s1t3_ev, s1t3_rv, s1t3_raw, s1t3_t] = f_tf_score(sym1, tf3)
[s1t4_ev, s1t4_rv, s1t4_raw, s1t4_t] = f_tf_score(sym1, tf4)
[s1t5_ev, s1t5_rv, s1t5_raw, s1t5_t] = f_tf_score(sym1, tf5)

[s2t1_ev, s2t1_rv, s2t1_raw, s2t1_t] = f_tf_score(sym2, tf1)
[s2t2_ev, s2t2_rv, s2t2_raw, s2t2_t] = f_tf_score(sym2, tf2)
[s2t3_ev, s2t3_rv, s2t3_raw, s2t3_t] = f_tf_score(sym2, tf3)
[s2t4_ev, s2t4_rv, s2t4_raw, s2t4_t] = f_tf_score(sym2, tf4)
[s2t5_ev, s2t5_rv, s2t5_raw, s2t5_t] = f_tf_score(sym2, tf5)

[s3t1_ev, s3t1_rv, s3t1_raw, s3t1_t] = f_tf_score(sym3, tf1)
[s3t2_ev, s3t2_rv, s3t2_raw, s3t2_t] = f_tf_score(sym3, tf2)
[s3t3_ev, s3t3_rv, s3t3_raw, s3t3_t] = f_tf_score(sym3, tf3)
[s3t4_ev, s3t4_rv, s3t4_raw, s3t4_t] = f_tf_score(sym3, tf4)
[s3t5_ev, s3t5_rv, s3t5_raw, s3t5_t] = f_tf_score(sym3, tf5)

// ─────────────────────────────────────────────────────────────────────────────
// STALENESS — derive last bar times from TF1 score calls
// ─────────────────────────────────────────────────────────────────────────────
s1_last_bar_time = s1t1_t
s2_last_bar_time = s2t1_t
s3_last_bar_time = s3t1_t

s1_bar_age_min = (timenow - s1_last_bar_time) / 60000
s2_bar_age_min = (timenow - s2_last_bar_time) / 60000
s3_bar_age_min = (timenow - s3_last_bar_time) / 60000

s1_stale = barstate.isrealtime and not s1_is_crypto and s1_bar_age_min > STALE_MINUTES
s2_stale = barstate.isrealtime and not s2_is_crypto and s2_bar_age_min > STALE_MINUTES
s3_stale = barstate.isrealtime and not s3_is_crypto and s3_bar_age_min > STALE_MINUTES

// ─────────────────────────────────────────────────────────────────────────────
// WEIGHT NORMALIZATION
// Normalize weights so total = 1, then multiply by score_scale
// Score range is always ±(2 × score_scale)
// ─────────────────────────────────────────────────────────────────────────────
total_w = w1 + w2 + w3 + w4 + w5
n1 = w1 / total_w
n2 = w2 / total_w
n3 = w3 / total_w
n4 = w4 / total_w
n5 = w5 / total_w

// ─────────────────────────────────────────────────────────────────────────────
// WEIGHTED COMPOSITE SCORES — per symbol
// ─────────────────────────────────────────────────────────────────────────────
s1_score = score_scale * (n1 * s1t1_raw + n2 * s1t2_raw + n3 * s1t3_raw + n4 * s1t4_raw + n5 * s1t5_raw)
s2_score = score_scale * (n1 * s2t1_raw + n2 * s2t2_raw + n3 * s2t3_raw + n4 * s2t4_raw + n5 * s2t5_raw)
s3_score = score_scale * (n1 * s3t1_raw + n2 * s3t2_raw + n3 * s3t3_raw + n4 * s3t4_raw + n5 * s3t5_raw)

// ─────────────────────────────────────────────────────────────────────────────
// CHART-AWARE SIGNAL SCORE
// When sync_sym1=ON, sym1 = syminfo.tickerid so this always resolves to s1_score
// ─────────────────────────────────────────────────────────────────────────────
chart_score = syminfo.tickerid == sym1 ? s1_score : syminfo.tickerid == sym2 ? s2_score : syminfo.tickerid == sym3 ? s3_score : na

// ─────────────────────────────────────────────────────────────────────────────
// VOLUME FILTER
// ─────────────────────────────────────────────────────────────────────────────
vol_ok = true
if use_vol_filter
    vol_ok := volume > ta.sma(volume, vol_sma_len)
    vol_ok

vol_label = not use_vol_filter ? 'OFF' : vol_ok ? 'OK' : '×' + str.tostring(vol_mult, '#.#')

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL CONDITIONS
// v2.0: Strictly > threshold (not >=); dynamic threshold when vol is low
// ─────────────────────────────────────────────────────────────────────────────
eff_threshold = use_vol_filter and not vol_ok ? sig_threshold * vol_mult : sig_threshold
long_signal = not na(chart_score) and chart_score > eff_threshold
short_signal = not na(chart_score) and chart_score < -eff_threshold

long_arrow = long_signal and not long_signal[1]
short_arrow = short_signal and not short_signal[1]

plot(chart_score, title = 'SignalScore', display = display.none)

plotshape(show_arrows and long_arrow, title = 'Long Signal', style = shape.triangleup, location = location.belowbar, color = color.new(color.lime, 0), size = size.normal, display = display.pane)
plotshape(show_arrows and short_arrow, title = 'Short Signal', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.normal, display = display.pane)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_vote_char(vote) =>
    vote == 1 ? '▲' : vote == -1 ? '▼' : '–'

f_tf_cell_text(ev, rv) =>
    f_vote_char(ev) + f_vote_char(rv)

f_raw_color(raw) =>
    raw == 2 ? color.new(color.lime, 10) : raw == 1 ? color.new(color.lime, 40) : raw == 0 ? color.new(color.gray, 50) : raw == -1 ? color.new(color.red, 40) : color.new(color.red, 10)

f_wscore_color(score) =>
    score > sig_threshold ? color.new(color.lime, 10) : score < -sig_threshold ? color.new(color.red, 10) : color.new(color.gray, 60)

f_vol_color(ok) =>
    ok ? color.new(color.teal, 30) : color.new(color.orange, 30)

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard table initialization
// ─────────────────────────────────────────────────────────────────────────────
tpos = switch dash_pos
    'Top Right' => position.top_right
    'Top Left' => position.top_left
    'Bottom Right' => position.bottom_right
    => position.bottom_left

n_cols = show_vol_col ? 8 : 7
var table dash = table.new(tpos, n_cols, 8, border_width = 1, border_color = color.new(color.white, 60), frame_width = 2, frame_color = color.new(color.white, 40))

C_BG = color.new(color.black, 20)
C_HEAD = color.new(color.navy, 10)
C_TXT = color.white
SZ_H = size.small
SZ_C = size.small
C_FROZEN_SYM = color.new(color.red, 40)
C_LIVE_SYM = color.new(color.green, 40)

max_possible = 2.0 * score_scale
is_realtime = barstate.isrealtime

any_stale = s1_stale and not s1_is_crypto or s2_stale and not s2_is_crypto or s3_stale and not s3_is_crypto

banner_text = not is_realtime ? '⚠ Base chart closed — data frozen' : any_stale ? 'Mixed · Green symbol: Live data, Red symbol: Latest closed data' : '✓ All markets open — live data'

banner_bg = not is_realtime ? color.rgb(160, 40, 0) : any_stale ? color.rgb(180, 150, 0) : color.rgb(0, 120, 0)

// ─────────────────────────────────────────────────────────────────────────────
// Row drawing function
// ─────────────────────────────────────────────────────────────────────────────
f_draw_row(row, sym, stale, ev1, rv1, raw1, ev2, rv2, raw2, ev3, rv3, raw3, ev4, rv4, raw4, ev5, rv5, raw5, score, frozen) =>
    sym_bg = frozen ? C_FROZEN_SYM : C_LIVE_SYM
    table.cell(table_id = dash, column = 0, row = row, text = sym, bgcolor = sym_bg, text_color = color.black, text_size = SZ_C)
    table.cell(table_id = dash, column = 1, row = row, text = f_tf_cell_text(ev1, rv1), bgcolor = f_raw_color(raw1), text_color = C_TXT, text_size = SZ_C)
    table.cell(table_id = dash, column = 2, row = row, text = f_tf_cell_text(ev2, rv2), bgcolor = f_raw_color(raw2), text_color = C_TXT, text_size = SZ_C)
    table.cell(table_id = dash, column = 3, row = row, text = f_tf_cell_text(ev3, rv3), bgcolor = f_raw_color(raw3), text_color = C_TXT, text_size = SZ_C)
    table.cell(table_id = dash, column = 4, row = row, text = f_tf_cell_text(ev4, rv4), bgcolor = f_raw_color(raw4), text_color = C_TXT, text_size = SZ_C)
    table.cell(table_id = dash, column = 5, row = row, text = f_tf_cell_text(ev5, rv5), bgcolor = f_raw_color(raw5), text_color = C_TXT, text_size = SZ_C)
    table.cell(table_id = dash, column = 6, row = row, text = str.tostring(score, '#.#'), bgcolor = f_wscore_color(score), text_color = C_TXT, text_size = SZ_C)
    if show_vol_col
        table.cell(table_id = dash, column = 7, row = row, text = vol_label, bgcolor = f_vol_color(vol_ok), text_color = C_TXT, text_size = SZ_C)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD RENDERING
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    // Banner (row 0)
    table.cell(table_id = dash, column = 0, row = 0, text = banner_text, bgcolor = banner_bg, text_color = color.white, text_size = size.small)
    table.merge_cells(dash, 0, 0, show_vol_col ? 7 : 6, 0)

    // Header (row 1)
    table.cell(table_id = dash, column = 0, row = 1, text = 'Symbol', bgcolor = C_HEAD, text_color = C_TXT, text_size = SZ_H)
    table.cell(table_id = dash, column = 1, row = 1, text = tf1, bgcolor = C_HEAD, text_color = C_TXT, text_size = SZ_H)
    table.cell(table_id = dash, column = 2, row = 1, text = tf2, bgcolor = C_HEAD, text_color = C_TXT, text_size = SZ_H)
    table.cell(table_id = dash, column = 3, row = 1, text = tf3, bgcolor = C_HEAD, text_color = C_TXT, text_size = SZ_H)
    table.cell(table_id = dash, column = 4, row = 1, text = tf4, bgcolor = C_HEAD, text_color = C_TXT, text_size = SZ_H)
    table.cell(table_id = dash, column = 5, row = 1, text = tf5, bgcolor = C_HEAD, text_color = C_TXT, text_size = SZ_H)
    table.cell(table_id = dash, column = 6, row = 1, text = 'WScore', bgcolor = C_HEAD, text_color = C_TXT, text_size = SZ_H)
    if show_vol_col
        table.cell(table_id = dash, column = 7, row = 1, text = 'Vol', bgcolor = C_HEAD, text_color = C_TXT, text_size = SZ_H)

    // Determine frozen states (red = stale or base chart closed)
    s1_frozen = not is_realtime or s1_stale
    s2_frozen = not is_realtime or s2_stale
    s3_frozen = not is_realtime or s3_stale

    // Symbol rows (row 2, 3, 4)
    f_draw_row(2, sym1, s1_stale, s1t1_ev, s1t1_rv, s1t1_raw, s1t2_ev, s1t2_rv, s1t2_raw, s1t3_ev, s1t3_rv, s1t3_raw, s1t4_ev, s1t4_rv, s1t4_raw, s1t5_ev, s1t5_rv, s1t5_raw, s1_score, s1_frozen)

    f_draw_row(3, sym2, s2_stale, s2t1_ev, s2t1_rv, s2t1_raw, s2t2_ev, s2t2_rv, s2t2_raw, s2t3_ev, s2t3_rv, s2t3_raw, s2t4_ev, s2t4_rv, s2t4_raw, s2t5_ev, s2t5_rv, s2t5_raw, s2_score, s2_frozen)

    f_draw_row(4, sym3, s3_stale, s3t1_ev, s3t1_rv, s3t1_raw, s3t2_ev, s3t2_rv, s3t2_raw, s3t3_ev, s3t3_rv, s3t3_raw, s3t4_ev, s3t4_rv, s3t4_raw, s3t5_ev, s3t5_rv, s3t5_raw, s3_score, s3_frozen)

    // Score row (row 5)
    chart_score_show = na(chart_score) ? '–' : str.tostring(chart_score, '#.##')
    chart_score_bg = na(chart_score) ? color.new(color.gray, 60) : chart_score > sig_threshold ? color.new(color.lime, 10) : chart_score < -sig_threshold ? color.new(color.red, 10) : chart_score > 0 ? color.new(color.lime, 50) : chart_score < 0 ? color.new(color.red, 50) : color.new(color.gray, 60)
    table.cell(table_id = dash, column = 0, row = 5, text = 'Score: ' + chart_score_show, bgcolor = chart_score_bg, text_color = C_TXT, text_size = SZ_C)
    table.merge_cells(dash, 0, 5, show_vol_col ? 7 : 6, 5)

    // Footer (row 6)
    table.cell(table_id = dash, column = 0, row = 6, text = '▲▲=+2  ▲–=+1  ––=0  –▼=−1  ▼▼=−2 | WScore range ±' + str.tostring(max_possible, '#.#'), bgcolor = C_BG, text_color = color.new(color.silver, 20), text_size = size.tiny, tooltip = 'EMA vote + RSI vote per TF. Volume filter uses dynamic threshold. Green symbol = live data, Red symbol = latest closed data.')
    table.merge_cells(dash, 0, 6, show_vol_col ? 7 : 6, 6)

    // Legend row (row 7)
    table.cell(table_id = dash, column = 0, row = 7, text = 'Red symbol = latest closed data (base chart closed or asset not trading)', bgcolor = C_BG, text_color = color.new(color.silver, 20), text_size = size.tiny)
    table.merge_cells(dash, 0, 7, show_vol_col ? 7 : 6, 7)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(long_arrow, title = 'MTF v2.0 Long', message = 'MTF v2.0 LONG — {{ticker}} | Score: {{plot_0}}')
alertcondition(short_arrow, title = 'MTF v2.0 Short', message = 'MTF v2.0 SHORT — {{ticker}} | Score: {{plot_0}}')
alertcondition(long_arrow or short_arrow, title = 'MTF v2.0 Any Signal', message = 'MTF v2.0 Signal — {{ticker}} at {{time}}')
````
