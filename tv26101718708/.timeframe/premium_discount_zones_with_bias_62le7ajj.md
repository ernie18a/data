# Premium & Discount Zones with Bias

- url: https://www.tradingview.com/script/62le7AJJ-Premium-Discount-Zones-with-Bias/
- type: indicator
- pine_id: PUB;521f1b8d8ca54292873c00d712175e35
- version: 4.0

## Description

═══════════════════════════════════════════════
PREMIUM & DISCOUNT ZONES WITH BIAS
═══════════════════════════════════════════════
A statistical mean-reversion framework that identifies premium (sell) and discount (buy) zones on your entry timeframe, derived from higher-timeframe structure. Built for intraday traders who want meaningful, stable reference levels without the noise of lower-timeframe volatility.

WHAT IT DOES
─────────────────────────────────────────────
This indicator projects five statistical zones from higher-timeframe candle distributions:
• Upper Sell Zone (95th percentile) — extreme premium, mean reversion likely
• Sell Zone (75th percentile) — standard premium zone
• EQ / Equilibrium (50th percentile) — the statistical midpoint, natural target
• Buy Zone (25th percentile) — standard discount zone
• Lower Buy Zone (5th percentile) — extreme discount, mean reversion likely
The zones are calculated from the distribution of recent higher-timeframe candles (default: 18 × 4H candles = 3 days of structure) using Monte Carlo projection. A Naive Bayes classifier runs on the current chart timeframe to produce a directional bias based on relative volume and momentum.
The key advantage: zones update only when a new HTF candle closes, giving you stable reference levels that stay fixed for hours at a time. No more chasing shifting lines on a 1m chart.

INSPIRATION & CREDIT
─────────────────────────────────────────────
This indicator is inspired by and builds on "Monte Carlo CT [SS]" by © Steversteves, published on TradingView under Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
The original script provided the mathematical foundation of Monte Carlo price projection combined with a Naive Bayes directional classifier. This version reimagines that concept as a premium/discount zone framework: instead of projecting bands forward across the chart, zones are derived from higher-timeframe structure and displayed as stable horizontal reference levels on the entry timeframe. Session awareness, bias table, and full visual customisation have been added for intraday traders.
Full credit and thanks to Steversteves for the original work.

HOW TO USE IT
─────────────────────────────────────────────
RECOMMENDED SETUP
Apply to your entry timeframe (1m, 3m, or 5m recommended). The zones will reflect your chosen higher timeframe (default 4H), giving you structural context without cluttering the entry chart.
CORE CONCEPT
The indicator identifies where price is statistically extended relative to recent structure. When price enters a buy or sell zone, it has a statistical tendency to revert toward the EQ (equilibrium). This is NOT a signal to blindly buy or sell — it is a confluence tool that tells you whether your chosen entry is at a statistically favourable location.

EXAMPLE SETUPS
─────────────────────────────────────────────
BULLISH SETUP (long from discount)
Wait for London or NY kill zone — the Session cell in the table will turn active
Price trades down into the Buy Zone (25th percentile) or Lower Buy Zone (5th percentile)
Check the Bias table — is it showing LONG with elevated probability?
Confirm with your own entry trigger (sweep + reclaim, break of structure, CISD, order block, etc.)
Enter long, targeting EQ as first target or the opposing Sell Zone as runner target
Why this works: you are entering long at a statistically discounted price with directional bias confirmation, targeting the statistical mean or opposing extreme.

BEARISH SETUP (short from premium)
Wait for an active kill zone
Price trades up into the Sell Zone (75th percentile) or Upper Sell Zone (95th percentile)
Check the Bias table — is it showing SHORT with elevated probability?
Confirm with your own entry trigger (failure to break, rejection candle, bearish CISD, etc.)
Enter short, targeting EQ as first target or the opposing Buy Zone as runner target
Why this works: you are selling at a statistically premium price against the likely mean reversion move.

WHAT NOT TO DO
─────────────────────────────────────────────
• Do not trade against the Bias signal. If price is in the Buy Zone but Bias shows SHORT, the setup lacks confluence — skip it
• Do not trade outside active kill zones unless you have another strong edge — the zones are most reliable during high-volume sessions
• Do not treat this indicator as a standalone entry signal. It is a confluence filter that works best combined with your existing framework
• Do not expect zones to hold every time. These are statistical probabilities, not guarantees

SETTINGS EXPLAINED
─────────────────────────────────────────────
ZONE CALCULATION
• Higher Timeframe — Controls which timeframe the zones are derived from. Default 240 (4H) balances structure and responsiveness. For longer-term reference, try Daily. For faster updates, try 60 or 120.
• HTF Candles Lookback — How many HTF candles feed the distribution. Default 18 = 3 days of 4H data. Minimum 10-12 for statistical significance. Higher values give smoother zones; lower values adapt faster to regime changes.
• Use Monte Carlo Projection — ON uses Monte Carlo simulation for distribution projection (more robust, slightly slower). OFF uses direct percentile calculation of historical returns (faster, tighter zones).
• Monte Carlo Simulations — Number of simulation runs when MC is enabled. 200 is the sweet spot. More sims give smoother bands but slower calculation.
• MC Forecast Horizon — How many HTF candles ahead to project. Default 6 × 4H = 24 hours. Increase for longer-term projection, decrease for closer zones.
• Line Offset — How far right the horizontal zone lines extend on your chart. Adjust for visual preference.

BIAS CLASSIFIER SETTINGS
• NB Train Lookback — Training window in current chart bars for the Naive Bayes classifier. Default 240.
• NB Momentum Period — ROC period for the momentum feature. Higher = smoother and less noisy on low timeframes. Default 30.

KILL ZONES
• London and NY kill zone windows in NY time. Adjust if you trade different sessions or different time zones.

COLOURS
• Fully customisable for both the zone lines and the bias table. Separate controls for background, borders, header text, label text, value text, and all highlight colours. Works on both light and dark chart themes.

TABLE DISPLAY
• Toggle table on/off
• Six position options (top/middle/bottom × left/right)
• Three size options: Normal, Small, Tiny

ALERTS
─────────────────────────────────────────────
Two alert conditions are available:
• Price entered BUY ZONE — when close drops below the 25th percentile line
• Price entered SELL ZONE — when close rises above the 75th percentile line
Set these as audio alerts if you want to focus on other charts and be notified only when price reaches a zone.

INSTRUMENTS & TIMEFRAMES
─────────────────────────────────────────────
This indicator is designed for:
• Futures (Gold, Silver, Indices, Oil, etc.)
• Forex majors
• Major crypto pairs
Best performance on liquid instruments with consistent volume. Recommended entry timeframes: 1m, 3m, 5m. Recommended higher timeframe for zones: 4H (default), 2H for faster updates, Daily for swing trading.

FINAL NOTES
─────────────────────────────────────────────
This is a confluence indicator, not a signal generator. Use it in combination with your own entry methodology — order flow reading, structure analysis, liquidity concepts, or any systematic entry framework.
The zones tell you WHERE. Your framework tells you WHEN.
Feedback and suggestions welcome. Trade safe.

## Source Code

````pine
// @version=6
// Premium & Discount Zones with Bias v7.2
//
// Based on "Monte Carlo CT [SS]" by © Steversteves
// Licensed under Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// v7.2 — 27 Apr 2026 — ATR filter inversion
//
// Targeted audit on TZ-corrected data (n=5,108 entries)
// found ATR regime filter direction was inverted.
//
// Below 1.4 (Pine v7.1 "tradeable"):  PF 2.44, E 3.34 pts
// Above 1.4 (Pine v7.1 "filtered"):   PF 4.28, E 9.00 pts
//
// Sanity-check splits all robust:
//  - News vs no-news: both positive (+0.78 no-news lift)
//  - Long vs short: both positive (asymmetric — short
//    fades benefit more)
//  - H1 vs H2 stability: both positive, mild compression
//    in H2 (lift 2.33 → 1.57)
//
// CHANGES IN v7.2:
//  - ATR comparison flipped: atr_ratio >= 1.4 now
//    tradeable (was <1.4)
//  - Vol regime label and color updated to match
//    inverted filter (EXPANSION at >=1.4 ATR is now
//    visually marked as the tradeable regime, not
//    warning red)
//  - Comment block updated with corrected research
//  - Disclaimer added: counter-intuitive finding,
//    verify before live use
//
// PAPER-TRADE GATE: indicator marked with "BACKTEST
// FINDING — verify before live use" warning. Drop in
// v7.3 once live behavior confirmed.
//
// CAVEATS:
//  - Direction asymmetry: short fades benefit more
//    (+7.55 PF) than long fades (+0.80 PF)
//  - H2 (Sep 2025-Apr 2026) shows mild edge compression
//    vs H1
//  - Re-audit recommended in 3-6 months to confirm edge
//    persists
//
// The vol_regime label has been renamed and color-
// aligned: EXPANSION (>=1.4) is now visually marked
// as the tradeable regime. UI matches filter behavior.
//
// v7.1 — 27 Apr 2026 — TZ-corrected research refresh
//
// The original P&D Zones research (zone_validation.cjs,
// 24 Apr) had a timezone bug: getNY function treated
// CSV timestamps as UTC instead of Europe/London. During
// BST periods (~7 months/year), session windows were
// shifted by 1 hour from intent. The shifted bucketing
// pulled NY-lunch consolidation bars into the NY_PM
// bucket, inflating its apparent edge.
//
// Re-running the validation script with proper TZ
// handling (Europe/London → US/Eastern via Intl
// DateTimeFormat) produced corrected research:
//
// SESSION RANKINGS (corrected):
//   NY:        PF 2.96 (was 3.39, n=1502)  — strongest
//   LONDON:    PF 2.18 (was untested as KZ, n=1103)
//   NY_PM:     PF 1.79 (was 6.52 inflated, n=990)
//   ASIA:      PF 1.72 (n=1995)
//
// HTF CONTRARIAN FILTER (vindicated):
//   BUY zones + 4H bearish:  PF 7.48
//   SELL zones + 4H bullish: PF 9.98
//   Both within original "PF 5-9x" claim
//
// CHANGES IN v7.1:
//  - Session highlights: REMOVED NY_PM, ADDED LONDON KZ
//    (NY_PM PF 1.79 below LONDON KZ 2.18 — doesn't
//    justify highlight)
//  - Comment block updated with TZ-corrected numbers
//  - Architecture unchanged (zone calculation, HTF
//    contrarian filter, ATR regime gate all preserved)
//
// PENDING (not addressed in v7.1) — RESOLVED IN v7.2:
//  - ATR threshold (1.4) — needs its own targeted
//    re-derivation on TZ-corrected data; not addressed
//    by zone_validation.cjs
//    → v7.2 found the filter direction was inverted,
//      not the threshold value. See v7.2 block above.
//
// v7 updates based on data-driven research (16 months GC data):
// - REMOVED: Naive Bayes classifier (50% accuracy = random)
// - ADDED: HTF 4H contrarian direction filter
//   (PF 7.48 BUY zones + 4H bearish; PF 9.98 SELL zones + 4H bullish — VINDICATED at 5-9x)
// - ADDED: ATR regime warning (ATR > 1.4 degrades signals)  [SUPERSEDED IN v7.2 — direction was inverted; high ATR strengthens fade-zone signals]
// - ADDED: Session context with NY highlighting
// - ADDED: Zone touch tracker per HTF cycle
indicator("Premium & Discount Zones with Bias", overlay = true, max_lines_count = 20, max_labels_count = 10)

// ═══════════════════════════════════════════════
// USER INPUTS
// ═══════════════════════════════════════════════

grp_zones = "Zone Calculation"
htf        = input.timeframe("240", "Higher Timeframe", options = ["60", "120", "180", "240", "360", "480", "720", "D"], group = grp_zones)
htf_back   = input.int(18, "HTF Candles Lookback", minval = 6, maxval = 100, group = grp_zones)
use_mc     = input.bool(true, "Use Monte Carlo Projection", group = grp_zones)
sims       = input.int(200, "Monte Carlo Simulations", minval = 10, maxval = 500, group = grp_zones)
forx       = input.int(6, "MC Forecast Horizon (HTF bars)", minval = 2, maxval = 24, group = grp_zones)
line_offset = input.int(20, "Line Offset (bars)", minval = 5, maxval = 200, group = grp_zones)

grp_sessions = "Kill Zones (NY Time)"
use_asia     = input.bool(true, "Enable Asia Kill Zone", group = grp_sessions)
asia_start   = input.int(20, "Asia Start Hour", minval = 0, maxval = 23, group = grp_sessions)
asia_end     = input.int(2,  "Asia End Hour",   minval = 0, maxval = 23, group = grp_sessions)
use_london   = input.bool(true, "Enable London Kill Zone", group = grp_sessions)
london_start = input.int(2,  "London Start Hour", minval = 0, maxval = 23, group = grp_sessions)
london_end   = input.int(5,  "London End Hour",   minval = 0, maxval = 23, group = grp_sessions)
use_ny       = input.bool(true, "Enable NY Kill Zone", group = grp_sessions)
ny_start_h   = input.int(8,  "NY Start Hour",     minval = 0, maxval = 23, group = grp_sessions)
ny_start_m   = input.int(30, "NY Start Minute",   minval = 0, maxval = 59, group = grp_sessions)
ny_end       = input.int(11, "NY End Hour",       minval = 0, maxval = 23, group = grp_sessions)

grp_line_colours = "Zone Line Colours"
col_buy  = input.color(color.new(#20cf46, 0), "Buy Zone",  group = grp_line_colours)
col_sell = input.color(color.new(#ff5252, 0), "Sell Zone", group = grp_line_colours)
col_eq   = input.color(color.new(#888888, 0), "EQ",        group = grp_line_colours)

grp_table_display = "Table Display"
showtbl      = input.bool(true, "Show Table", group = grp_table_display)
tbl_position = input.string("top_right", "Table Position", options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right", "middle_left"], group = grp_table_display)
tbl_size     = input.string("Normal", "Table Size", options = ["Normal", "Small", "Tiny"], group = grp_table_display)

grp_table_colours = "Table Colours"
tbl_bg          = input.color(color.new(color.black, 20), "Background",        group = grp_table_colours)
tbl_border      = input.color(color.gray,                 "Border",            group = grp_table_colours)
tbl_header_bg   = input.color(color.new(color.black, 0),  "Header Background", group = grp_table_colours)
tbl_header_txt  = input.color(color.white,                "Header Text",       group = grp_table_colours)
tbl_label_txt   = input.color(color.white,                "Label Text",        group = grp_table_colours)
tbl_value_txt   = input.color(color.white,                "Value Text",        group = grp_table_colours)
tbl_bull_bg     = input.color(color.new(color.green, 20), "Bullish",           group = grp_table_colours)
tbl_bear_bg     = input.color(color.new(color.red, 20),   "Bearish",           group = grp_table_colours)
tbl_neutral_bg  = input.color(color.new(color.gray, 50),  "Neutral",           group = grp_table_colours)
tbl_session_on  = input.color(color.new(color.blue, 30),  "Session Active",    group = grp_table_colours)
tbl_session_off = input.color(color.new(color.gray, 50),  "Session Off",       group = grp_table_colours)
tbl_warn_bg     = input.color(color.new(color.orange, 20),"Warning",           group = grp_table_colours)
tbl_tradeable   = input.color(color.new(#00C853, 20),     "Tradeable Signal",  group = grp_table_colours)

// ═══════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════

f_pos(s) =>
    switch s
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        "middle_right" => position.middle_right
        "middle_left"  => position.middle_left
        =>                position.top_right

f_header_size(s) =>
    switch s
        "Normal" => size.large
        "Small"  => size.normal
        "Tiny"   => size.small
        =>          size.large

f_body_size(s) =>
    switch s
        "Normal" => size.normal
        "Small"  => size.small
        "Tiny"   => size.tiny
        =>          size.normal

get_percentile(array<float> arr, float p) =>
    array<float> sorted = arr.copy()
    sorted.sort()
    idx = math.floor(p * (sorted.size() - 1))
    sorted.get(idx)

// ═══════════════════════════════════════════════
// HTF DATA FETCH — log returns from HTF candles
// ═══════════════════════════════════════════════

float htf_close = request.security(syminfo.tickerid, htf, close[1], lookahead = barmerge.lookahead_off)
float htf_prev  = request.security(syminfo.tickerid, htf, close[2], lookahead = barmerge.lookahead_off)

bool new_htf_bar = ta.change(time(htf)) != 0

var array<float> htf_returns = array.new_float()
if new_htf_bar and not na(htf_close) and not na(htf_prev) and htf_prev > 0
    htf_returns.push(math.log(htf_close / htf_prev))
    if htf_returns.size() > htf_back
        htf_returns.shift()

// ═══════════════════════════════════════════════
// HTF 4H DIRECTION (developing candle)
// ═══════════════════════════════════════════════

float htf_open_dev  = request.security(syminfo.tickerid, htf, open, lookahead = barmerge.lookahead_on)
float htf_close_dev = close

bool h4_bullish = not na(htf_open_dev) and htf_close_dev > htf_open_dev
bool h4_bearish = not na(htf_open_dev) and htf_close_dev < htf_open_dev

// ═══════════════════════════════════════════════
// ATR REGIME
// ═══════════════════════════════════════════════

float atr_fast = ta.atr(14)
float atr_slow = ta.atr(50)
float atr_ratio = not na(atr_slow) and atr_slow > 0 ? atr_fast / atr_slow : 1.0

// v7.2 UI alignment: labels match filter direction.
// EXPANSION (>=1.4) is the tradeable regime per inverted filter — green.
// NORMAL (1.0-1.4) is moderate edge — neutral.
// QUIET (<1.0) is weakest edge — muted/off.
string vol_regime = atr_ratio >= 1.4 ? "EXPANSION" : atr_ratio >= 1.0 ? "NORMAL" : "QUIET"
color vol_regime_col = atr_ratio >= 1.4 ? tbl_tradeable : atr_ratio >= 1.0 ? tbl_neutral_bg : tbl_session_off

// ═══════════════════════════════════════════════
// ZONE CALCULATION
// ═══════════════════════════════════════════════

var float cur_p95 = na
var float cur_p75 = na
var float cur_p50 = na
var float cur_p25 = na
var float cur_p05 = na

var int touches_p95 = 0
var int touches_p05 = 0
var bool was_in_sell = false
var bool was_in_buy  = false

if new_htf_bar and htf_returns.size() >= 6
    float avg_ret = htf_returns.avg()
    float std_ret = htf_returns.stdev()
    float anchor  = htf_close

    if use_mc
        matrix<float> results = matrix.new<float>(forx, sims, anchor)
        for s = 0 to sims - 1
            float cur_p = anchor
            for t = 1 to forx - 1
                float z = math.sqrt(-2.0 * math.log(math.random(0.01, 0.99))) * math.cos(2.0 * math.pi * math.random(0.01, 0.99))
                cur_p *= math.exp(avg_ret + std_ret * z)
                results.set(t, s, cur_p)

        array<float> col_end = results.row(forx - 1)
        cur_p95 := get_percentile(col_end, 0.95)
        cur_p75 := get_percentile(col_end, 0.75)
        cur_p50 := get_percentile(col_end, 0.50)
        cur_p25 := get_percentile(col_end, 0.25)
        cur_p05 := get_percentile(col_end, 0.05)
    else
        cur_p95 := anchor * math.exp(get_percentile(htf_returns, 0.95) * forx)
        cur_p75 := anchor * math.exp(get_percentile(htf_returns, 0.75) * forx)
        cur_p50 := anchor * math.exp(get_percentile(htf_returns, 0.50) * forx)
        cur_p25 := anchor * math.exp(get_percentile(htf_returns, 0.25) * forx)
        cur_p05 := anchor * math.exp(get_percentile(htf_returns, 0.05) * forx)

    touches_p95 := 0
    touches_p05 := 0
    was_in_sell := false
    was_in_buy  := false

// ═══════════════════════════════════════════════
// DRAW ZONE LINES
// ═══════════════════════════════════════════════

var line l_p95 = na, var line l_p75 = na, var line l_p50 = na, var line l_p25 = na, var line l_p05 = na
var label lbl_p95 = na, var label lbl_p75 = na, var label lbl_p50 = na, var label lbl_p25 = na, var label lbl_p05 = na

if barstate.islast and not na(cur_p95)
    line.delete(l_p95), line.delete(l_p75), line.delete(l_p50), line.delete(l_p25), line.delete(l_p05)
    label.delete(lbl_p95), label.delete(lbl_p75), label.delete(lbl_p50), label.delete(lbl_p25), label.delete(lbl_p05)

    int ls = bar_index, int le = bar_index + line_offset

    l_p95 := line.new(ls, cur_p95, le, cur_p95, color = col_sell, width = 2)
    l_p75 := line.new(ls, cur_p75, le, cur_p75, color = col_sell, width = 1, style = line.style_dashed)
    l_p50 := line.new(ls, cur_p50, le, cur_p50, color = col_eq,   width = 1)
    l_p25 := line.new(ls, cur_p25, le, cur_p25, color = col_buy,  width = 1, style = line.style_dashed)
    l_p05 := line.new(ls, cur_p05, le, cur_p05, color = col_buy,  width = 2)

    lbl_p95 := label.new(le, cur_p95, "Sell Zone", color = color.new(color.black, 100), textcolor = col_sell, style = label.style_label_left, size = size.small)
    lbl_p75 := label.new(le, cur_p75, "Sell Zone", color = color.new(color.black, 100), textcolor = col_sell, style = label.style_label_left, size = size.small)
    lbl_p50 := label.new(le, cur_p50, "EQ",        color = color.new(color.black, 100), textcolor = col_eq,   style = label.style_label_left, size = size.small)
    lbl_p25 := label.new(le, cur_p25, "Buy Zone",  color = color.new(color.black, 100), textcolor = col_buy,  style = label.style_label_left, size = size.small)
    lbl_p05 := label.new(le, cur_p05, "Buy Zone",  color = color.new(color.black, 100), textcolor = col_buy,  style = label.style_label_left, size = size.small)

// ═══════════════════════════════════════════════
// ZONE STATE + TOUCH TRACKING
// ═══════════════════════════════════════════════

bool in_sell_zone = not na(cur_p75) and close > cur_p75
bool in_buy_zone  = not na(cur_p25) and close < cur_p25
bool in_extreme_sell = not na(cur_p95) and close > cur_p95
bool in_extreme_buy  = not na(cur_p05) and close < cur_p05

if in_extreme_sell and not was_in_sell
    touches_p95 += 1
if in_extreme_buy and not was_in_buy
    touches_p05 += 1
was_in_sell := in_extreme_sell
was_in_buy  := in_extreme_buy

// ═══════════════════════════════════════════════
// SESSION DETECTION (NY time)
// ═══════════════════════════════════════════════

int ny_hour    = hour(time, "America/New_York")
int ny_minute  = minute(time, "America/New_York")
int ny_time_min = ny_hour * 60 + ny_minute

bool in_asia = false
if use_asia
    if asia_start <= asia_end
        in_asia := ny_hour >= asia_start and ny_hour < asia_end
    else
        in_asia := ny_hour >= asia_start or ny_hour < asia_end

bool in_london = use_london and ny_hour >= london_start and ny_hour < london_end
bool in_ny     = use_ny and ny_time_min >= (ny_start_h * 60 + ny_start_m) and ny_hour < ny_end
bool in_ny_pm  = ny_hour >= 12 and ny_hour < 17

string session_label = in_ny ? "NY KZ" : in_london ? "LONDON KZ" : in_asia ? "ASIA KZ" : in_ny_pm ? "NY PM" : "OFF"
// NY KZ and LONDON KZ get green highlight (TZ-corrected PF 2.96 NY / 2.18 LONDON KZ)
// NY_PM downgraded — TZ-corrected PF 1.79 vs prior 6.52 was a TZ artifact
color  session_col = (in_ny or in_london) ? tbl_tradeable : (in_ny_pm or in_asia) ? tbl_session_on : tbl_session_off

// ═══════════════════════════════════════════════
// CONTRARIAN BIAS LOGIC
// ═══════════════════════════════════════════════

string zone_bias = "NEUTRAL"
color bias_col = tbl_neutral_bg

if in_sell_zone
    if h4_bullish
        zone_bias := "SELL — CONTRARIAN — TRADEABLE"
        bias_col := tbl_tradeable
    else
        zone_bias := "SELL — HTF ALIGNED — SKIP"
        bias_col := tbl_bear_bg
else if in_buy_zone
    if h4_bearish
        zone_bias := "BUY — CONTRARIAN — TRADEABLE"
        bias_col := tbl_tradeable
    else
        zone_bias := "BUY — HTF ALIGNED — SKIP"
        bias_col := tbl_bull_bg
else
    zone_bias := "NEUTRAL — wait for zone"
    bias_col := tbl_neutral_bg

// ATR regime filter (v7.2): atr_ratio >= 1.4 required for tradeable signals.
//
// BACKTEST FINDING — VERIFY BEFORE LIVE USE: research shows higher ATR
// ratios at zone extremes correlate with stronger mean reversion (PF 4.28
// above 1.4 vs PF 2.44 below 1.4, n=5108). Counter-intuitive: standard
// logic says high ATR = expansion = fades get run over. Data says opposite
// for entries specifically AT zone extremes — likely because high vol at
// extremes marks exhaustion, not continuation. Verify behavior on paper
// or sim before sizing live.
//
// Tradeable = in extreme zone + contrarian HTF + ATR expansion (>=1.4) + NY/LONDON KZ
bool tradeable_short = in_sell_zone and h4_bullish and atr_ratio >= 1.4 and (in_ny or in_london)
bool tradeable_long  = in_buy_zone and h4_bearish and atr_ratio >= 1.4 and (in_ny or in_london)


// ═══════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════

var bool prev_sell = false, var bool prev_buy = false
bool enter_sell = in_sell_zone and not prev_sell
bool enter_buy  = in_buy_zone  and not prev_buy
prev_sell := in_sell_zone
prev_buy  := in_buy_zone

alertcondition(enter_buy,  title = "Price entered BUY ZONE",  message = "Price has entered the BUY ZONE")
alertcondition(enter_sell, title = "Price entered SELL ZONE", message = "Price has entered the SELL ZONE")
alertcondition(tradeable_long,  title = "Tradeable BUY signal",  message = "BUY ZONE + 4H bearish + ATR >= 1.4 + NY/LONDON KZ — TRADEABLE")
alertcondition(tradeable_short, title = "Tradeable SELL signal", message = "SELL ZONE + 4H bullish + ATR >= 1.4 + NY/LONDON KZ — TRADEABLE")
alertcondition(atr_ratio < 1.0, title = "Low volatility regime", message = "ATR regime QUIET (<1.0) — fade-the-zone edge weakest in this regime per v7.2 research")

// ═══════════════════════════════════════════════
// TABLE
// ═══════════════════════════════════════════════

if showtbl and barstate.islast
    var table t = table.new(f_pos(tbl_position), 2, 6, bgcolor = tbl_bg, border_width = 1, border_color = tbl_border)

    header_size = f_header_size(tbl_size)
    body_size   = f_body_size(tbl_size)

    table.cell(t, 0, 0, "ZONES",  bgcolor = tbl_header_bg, text_color = tbl_header_txt, text_size = header_size)
    table.cell(t, 1, 0, "STATUS", bgcolor = tbl_header_bg, text_color = tbl_header_txt, text_size = header_size)

    table.cell(t, 0, 1, "Session", text_color = tbl_label_txt, text_size = body_size)
    table.cell(t, 1, 1, session_label, bgcolor = session_col, text_color = tbl_value_txt, text_size = body_size)

    string h4_txt = h4_bullish ? "BULLISH" : h4_bearish ? "BEARISH" : "FLAT"
    color h4_col = h4_bullish ? tbl_bull_bg : h4_bearish ? tbl_bear_bg : tbl_neutral_bg
    table.cell(t, 0, 2, "HTF 4H", text_color = tbl_label_txt, text_size = body_size)
    table.cell(t, 1, 2, h4_txt, bgcolor = h4_col, text_color = tbl_value_txt, text_size = body_size)

    string cur_zone = in_extreme_sell ? "SELL ZONE (P95)" : in_sell_zone ? "SELL ZONE" : in_extreme_buy ? "BUY ZONE (P05)" : in_buy_zone ? "BUY ZONE" : "NEUTRAL"
    color  zone_col = in_sell_zone ? tbl_bear_bg : in_buy_zone ? tbl_bull_bg : tbl_neutral_bg
    table.cell(t, 0, 3, "Current Zone", text_color = tbl_label_txt, text_size = body_size)
    table.cell(t, 1, 3, cur_zone, bgcolor = zone_col, text_color = tbl_value_txt, text_size = body_size)

    table.cell(t, 0, 4, "Zone Bias", text_color = tbl_label_txt, text_size = body_size)
    table.cell(t, 1, 4, zone_bias, bgcolor = bias_col, text_color = tbl_value_txt, text_size = body_size)

    string vol_txt = vol_regime + " (" + str.tostring(atr_ratio, "#.##") + "x)"
    table.cell(t, 0, 5, "Vol Regime", text_color = tbl_label_txt, text_size = body_size)
    table.cell(t, 1, 5, vol_txt, bgcolor = vol_regime_col, text_color = tbl_value_txt, text_size = body_size)
````
