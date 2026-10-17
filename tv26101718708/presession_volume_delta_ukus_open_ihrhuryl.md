# Pre-Session Volume Delta [UK/US Open]

- url: https://www.tradingview.com/script/IHRHurYl-Pre-Session-Volume-Delta-UK-US-Open/
- type: indicator
- pine_id: PUB;0cdb73ace2494700a707d04d9fcc8f7e
- version: 1.0

## Description

Short Description
Predict early-session market direction using institutional order flow analysis. Tracks buy/sell volume delta in the hours before UK (08:00) or US (09:30) market opens to forecast follow-through bias with confidence scoring.


Full Description
🔍 WHAT IT DOES
This indicator analyzes granular order flow (buy vs. sell volume) during the pre-market window to predict directional bias for the opening session. By measuring institutional positioning before the bell, it helps traders anticipate whether the market is likely to follow through bullish or bearish in the first hour.

⚡ KEY FEATURES

✓ Smart DST-Aware Timing — Automatically handles timezone shifts between London and New York
✓ Order Flow Delta — Calculates net buy/sell imbalance using footprint data
✓ Weighted Probability Engine — Composite confidence score from 3 factors:
   • Delta Magnitude (45%) — Size of volume imbalance
   • Bar Ratio (35%) — Consistency of directional bars
   • Spike Skew (20%) — Quality of institutional block trades
✓ Historical Hit Rate — Tracks last 10 sessions to validate prediction accuracy
✓ Session Comparison — Today's volume vs. historical average

📊 DASHBOARD DISPLAY
• Real-time Buy/Sell volume totals
• Net Delta with directional coloring
• Bias prediction (BULLISH/BEARISH) with confidence level
• Factor score progress bars
• Session win rate statistics

🎯 BEST USED FOR
• Intraday traders planning pre-market bias
• Order flow traders tracking institutional positioning
• Session-open momentum strategies
• Validating directional conviction before key opens

⚙️ INPUTS & CUSTOMIZATION
• Target Session: UK (08:00) or US (09:30) open
• Lookback Hours: 1-12 hours of pre-session analysis (default: 4)
• Probability Weights: Adjust factor importance
• Ticks Per Row: Footprint granularity control
• Value Area %: Volume profile threshold

📈 HOW TO READ
GREEN Net Delta + BULLISH Bias = Expect upside follow-through
RED Net Delta + BEARISH Bias = Expect downside follow-through
Confidence Rating: Low (<50%), Medium (50-70%), High (>70%)

🔔 HIT RATE TRACKING
A "Hit" is recorded when price moves in the predicted direction during the first hour of the session. Monitor the dashboard stats to gauge current reliability.

📝 NOTES
• Requires volume/footprint data (works on forex, futures, indices)
• Best on 15m-1H charts
• Higher confidence = stronger conviction, not guarantee
• Use with other confluence factors (S/R, trend, news)

--
Developed for traders who want to see what "Smart Money" is doing before the bell rings.
📖 User Guide
Getting Started
Add to Chart — Click "Add to Chart" on the indicator
Select Your Session — In settings, choose UK (London) or US (New York) open
Adjust Lookback — Default 4 hours; increase for more data, decrease for recent bias only
Position Dashboard — Toggle between Top-Right or Bottom-Right display
Dashboard Explained
Section	What It Shows
Pre-Session Window	Start/end times of the analysis period
Volume Metrics	Buy Vol / Sell Vol / Net Delta (color-coded)
Bias Prediction	Direction + Confidence % + Visual meter
Factor Scores	Individual scores (0-100) for each weighting factor
Session History	Last 10 predictions with hit/miss tracking
Comparison	Today's delta vs. historical average
Understanding the Bias Prediction
Confidence	Interpretation	Action
Low (<50%)	Weak conviction, mixed signals	Wait for clarity or reduce size
Medium (50-70%)	Moderate directional edge	Trade with standard risk
High (>70%)	Strong institutional positioning	Higher confidence in directional setup
The Three Factors
Delta Magnitude — How large is the net buy/sell imbalance?

Higher = more conviction
Weight: 45% (default)
Bar Ratio — How many bars were bullish vs. bearish?

Measures consistency, not just size
Weight: 35% (default)
Spike Skew — Were the largest volume spikes buying or selling?

Catches institutional block trades
Weight: 20% (default)
Hit Rate Tracking
Bullish Hit Rate — % of bullish predictions that succeeded
Bearish Hit Rate — % of bearish predictions that succeeded
Overall — Combined accuracy across all predictions
A "Hit" = price moved in predicted direction during the first hour of the session

Pro Tips
✓ Combine with price action — Look for the bias to align with your S/R levels or trend direction
✓ Watch for extremes — Very high delta readings often mean early exhaustion; medium-high is the sweet spot
✓ Check both sessions — Compare UK vs. US bias for confluence or divergence
✓ Monitor your hit rate — If bearish predictions are performing better recently, weight those more heavily
✓ Adjust for volatility — In low-vol periods, reduce lookback hours to capture only recent flow

Settings Reference
Setting	Default	Range	Purpose
Target Session	US	UK/US	Which market open to analyze
Lookback Hours	4	1-12	Pre-session analysis window
Delta Weight	45	0-100	Importance of volume magnitude
Ratio Weight	35	0-100	Importance of bar consistency
Skew Weight	35	0-100	Importance of spike quality
Ticks Per Row	50	1-500	Footprint granularity
Value Area %	70	50-95	Volume profile threshold
Dashboard Position	Bottom Right	Top/Bottom	Table placement

## Source Code

````pine
// @title Pre-Session Volume Delta [UK/US Open] — Institutional Order Flow Predictor
// @description Predict early-session market direction using institutional order flow analysis. Tracks buy/sell volume delta in the hours before UK (08:00) or US (09:30) market opens to forecast follow-through bias with confidence scoring.
//
// 🔍 WHAT IT DOES
// This indicator analyzes granular order flow (buy vs. sell volume) during the pre-market window to predict directional bias for the opening session.
//
// ⚡ KEY FEATURES
// • Smart DST-Aware Timing — Automatically handles timezone shifts
// • Order Flow Delta — Calculates net buy/sell imbalance
// • Weighted Probability Engine — Composite confidence from Delta (45%), Bar Ratio (35%), Spike Skew (20%)
// • Historical Hit Rate — Tracks last 10 sessions
//
// 📊 DASHBOARD
// • Real-time Buy/Sell volume totals
// • Net Delta with directional coloring
// • Bias prediction (BULLISH/BEARISH) with confidence
// • Session win rate statistics
//
// 🎯 BEST FOR: Intraday traders, order flow analysis, session-open momentum
// 📈 TIMEFRAME: 15m-1H recommended
//
// @author Tonsil
// @version 1.0

//@version=6
indicator("Pre-Session Volume Delta [UK/US Open]", overlay = true, max_labels_count = 500)

// ═══════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════
var string G1 = "Session Settings"
session_choice = input.string("UK Open (08:00)",
     title   = "Target Session",
     options = ["UK Open (08:00)", "US Open (09:30 NY)"],
     group   = G1)
lookback_hours = input.int(4,
     title   = "Lookback Hours Before Open",
     minval  = 1, maxval = 12,
     group   = G1)
hist_sessions  = input.int(10,
     title   = "Historical Sessions To Compare",
     minval  = 2, maxval = 50,
     group   = G1,
     tooltip = "Number of previous sessions stored for comparison. Max 50.")

var string G2 = "Footprint Settings"
ticks_per_row  = input.int(10,
     title   = "Ticks Per Row",
     minval  = 1, maxval = 500,
     group   = G2,
     tooltip = "Price range per footprint row in ticks. Lower = more granular.")
va_pct         = input.int(70,
     title   = "Value Area %",
     minval  = 50, maxval = 95,
     group   = G2)

var string G3 = "Probability Weights"
w_delta        = input.int(45,
     title   = "Weight: Net Delta Magnitude",
     minval  = 0, maxval = 100, group = G3,
     tooltip = "How large the cumulative buy/sell imbalance is relative to total volume.")
w_bars         = input.int(35,
     title   = "Weight: Bull/Bear Bar Ratio",
     minval  = 0, maxval = 100, group = G3,
     tooltip = "How many bars had positive vs negative delta.")
w_skew         = input.int(20,
     title   = "Weight: Delta Spike Skew",
     minval  = 0, maxval = 100, group = G3,
     tooltip = "Whether the biggest delta spikes were bullish or bearish.")
show_factors   = input.bool(true,
     title   = "Show Individual Factor Scores",
     group   = G3)

var string G4 = "Display"
table_pos      = input.string("Bottom Right",
     title   = "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group   = G4)

// ═══════════════════════════════════════════════════════
//  SESSION TIMING — dual timezone approach
//  UK open : detected in Europe/London  (08:00 London)
//  US open : detected in America/New_York (09:30 NY)
//  Correctly handles the March/November mismatch weeks
//  when US and UK DST switches fall on different dates.
// ═══════════════════════════════════════════════════════
string TZ_LON     = "Europe/London"
string TZ_NY      = "America/New_York"
bool   is_uk      = session_choice == "UK Open (08:00)"

int    lon_h      = hour(time, TZ_LON)
int    lon_m      = minute(time, TZ_LON)
int    lon_mins   = lon_h * 60 + lon_m

int    ny_h       = hour(time, TZ_NY)
int    ny_m       = minute(time, TZ_NY)

int    bar_dow    = dayofweek(time, TZ_LON)
bool   is_weekday = bar_dow != dayofweek.saturday and bar_dow != dayofweek.sunday

// Open bar — UK uses London time, US uses NY time natively
bool   is_open_bar = is_weekday and (
     is_uk ?
     (lon_h == 8  and lon_m == 0) :
     (ny_h  == 9  and ny_m  == 30))

// First-hour close bar
bool   is_fh_bar = is_weekday and (
     is_uk ?
     (lon_h == 9  and lon_m == 0) :
     (ny_h  == 10 and ny_m  == 30))

// Pre-session window in London-equivalent minutes
// For the US session we capture the actual London time of the NY open
// each day so the window shifts correctly during DST mismatch weeks
var int us_open_lon_mins = 14 * 60 + 30   // sensible default (BST)

if not is_uk and is_open_bar
    us_open_lon_mins := lon_mins

int    effective_open  = is_uk ? (8 * 60) : us_open_lon_mins
int    effective_start = effective_open - lookback_hours * 60

bool   in_window = is_weekday and lon_mins >= effective_start and lon_mins < effective_open
bool   is_reset  = is_weekday and lon_mins == effective_start

// ═══════════════════════════════════════════════════════
//  FOOTPRINT DATA
// ═══════════════════════════════════════════════════════
footprint fp   = request.footprint(ticks_per_row, va_percent = va_pct)

float bar_buy  = na(fp) ? na : footprint.buy_volume(fp)
float bar_sell = na(fp) ? na : footprint.sell_volume(fp)
float bar_delta= na(fp) ? na : footprint.delta(fp)

// ═══════════════════════════════════════════════════════
//  PRE-SESSION ACCUMULATORS
// ═══════════════════════════════════════════════════════
var float cum_buy   = 0.0
var float cum_sell  = 0.0
var float cum_delta = 0.0
var float cum_vol   = 0.0
var int   bull_bars = 0
var int   bear_bars = 0
var float max_delta = 0.0
var float min_delta = 0.0

if is_reset
    cum_buy   := 0.0
    cum_sell  := 0.0
    cum_delta := 0.0
    cum_vol   := 0.0
    bull_bars := 0
    bear_bars := 0
    max_delta := 0.0
    min_delta := 0.0

if in_window and not na(bar_delta)
    cum_buy   += bar_buy
    cum_sell  += bar_sell
    cum_delta += bar_delta
    cum_vol   += volume
    bull_bars += bar_delta > 0.0 ? 1 : 0
    bear_bars += bar_delta < 0.0 ? 1 : 0
    max_delta := math.max(max_delta, bar_delta)
    min_delta := math.min(min_delta, bar_delta)

// ═══════════════════════════════════════════════════════
//  FACTOR SCORES  (0.0 – 1.0)
// ═══════════════════════════════════════════════════════
int   total_bars  = bull_bars + bear_bars
float vol_guard   = math.max(cum_vol, 1.0)

float f_delta     = math.abs(math.max(math.min(cum_delta / vol_guard, 1.0), -1.0))
float f_bars      = total_bars > 0 ?
     (cum_delta >= 0.0 ? float(bull_bars) / float(total_bars)
                       : float(bear_bars) / float(total_bars)) : 0.5
float delta_range = math.abs(max_delta) + math.abs(min_delta)
float raw_skew    = delta_range > 0.0 ?
     (math.abs(max_delta) - math.abs(min_delta)) / delta_range : 0.0
float f_skew      = cum_delta >= 0.0 ?
     math.max(raw_skew, 0.0) : math.max(-raw_skew, 0.0)

// ═══════════════════════════════════════════════════════
//  WEIGHTED PROBABILITY
// ═══════════════════════════════════════════════════════
float w_total   = math.max(float(w_delta) + float(w_bars) + float(w_skew), 1.0)
float w_d       = float(w_delta) / w_total
float w_b       = float(w_bars)  / w_total
float w_s       = float(w_skew)  / w_total
float composite = f_delta * w_d + f_bars * w_b + f_skew * w_s

bool  is_bull   = cum_delta >= 0.0
float bull_prob = is_bull ? 50.0 + composite * 50.0 : 50.0 - composite * 50.0
float bear_prob = 100.0 - bull_prob

string conf_str = composite >= 0.70 ? "████ HIGH" :
                 composite >= 0.50 ? "███░ MED-HIGH" :
                 composite >= 0.35 ? "██░░ MEDIUM" :
                                     "█░░░ LOW"

// ═══════════════════════════════════════════════════════
//  SESSION HISTORY ARRAYS
//  Snapshot stored at open bar. Outcome filled at fh bar.
// ═══════════════════════════════════════════════════════
var array<float> h_bull_prob  = array.new<float>()
var array<bool>  h_is_bull    = array.new<bool>()
var array<float> h_delta      = array.new<float>()
var array<float> h_buy        = array.new<float>()
var array<float> h_sell       = array.new<float>()
var array<float> h_composite  = array.new<float>()
var array<float> h_open_px    = array.new<float>()
var array<float> h_fh_px      = array.new<float>()
var array<int>   h_outcome    = array.new<int>()   // 1=hit  0=miss  -1=pending

if is_open_bar
    array.push(h_bull_prob, bull_prob)
    array.push(h_is_bull,   is_bull)
    array.push(h_delta,     cum_delta)
    array.push(h_buy,       cum_buy)
    array.push(h_sell,      cum_sell)
    array.push(h_composite, composite)
    array.push(h_open_px,   close)
    array.push(h_fh_px,     float(na))
    array.push(h_outcome,   -1)

    int max_sz = hist_sessions + 1
    for i = 0 to math.max(array.size(h_bull_prob) - max_sz, 0) - 1
        if array.size(h_bull_prob) <= max_sz
            break
        array.shift(h_bull_prob)
        array.shift(h_is_bull)
        array.shift(h_delta)
        array.shift(h_buy)
        array.shift(h_sell)
        array.shift(h_composite)
        array.shift(h_open_px)
        array.shift(h_fh_px)
        array.shift(h_outcome)

if is_fh_bar and array.size(h_open_px) > 0
    int last = array.size(h_open_px) - 1
    if array.get(h_outcome, last) == -1
        float open_p = array.get(h_open_px, last)
        float fh_p   = close
        bool  bull_b = array.get(h_is_bull, last)
        bool  hit    = (bull_b and fh_p > open_p) or (not bull_b and fh_p < open_p)
        array.set(h_fh_px, last, fh_p)
        array.set(h_outcome, last, hit ? 1 : 0)

// ————— Session Labels —————
// Removed per user request to keep chart clean.
// The calculations and dashboard remain intact.

// ═══════════════════════════════════════════════════════
//  HISTORICAL STATISTICS
// ═══════════════════════════════════════════════════════
int   hist_size     = math.max(array.size(h_outcome) - 1, 0)
int   completed     = 0
int   hits          = 0
float avg_prob      = 0.0
float avg_delta     = 0.0
float avg_buy       = 0.0
float avg_sell      = 0.0
float avg_comp      = 0.0
int   hist_bull_cnt = 0
int   hist_bear_cnt = 0
int   bull_hits     = 0
int   bear_hits     = 0

if hist_size > 0
    for i = 0 to hist_size - 1
        int outcome = array.get(h_outcome, i)
        if outcome != -1
            completed     += 1
            hits          += outcome
            avg_prob      += array.get(h_bull_prob, i)
            avg_delta     += array.get(h_delta, i)
            avg_buy       += array.get(h_buy, i)
            avg_sell      += array.get(h_sell, i)
            avg_comp      += array.get(h_composite, i)
            if array.get(h_is_bull, i)
                hist_bull_cnt += 1
                bull_hits     += outcome
            else
                hist_bear_cnt += 1
                bear_hits     += outcome

    if completed > 0
        avg_prob  /= float(completed)
        avg_delta /= float(completed)
        avg_buy   /= float(completed)
        avg_sell  /= float(completed)
        avg_comp  /= float(completed)

float hit_rate      = completed > 0 ? float(hits)      / float(completed)     * 100.0 : 0.0
float bull_hit_rate = hist_bull_cnt > 0 ? float(bull_hits) / float(hist_bull_cnt) * 100.0 : 0.0
float bear_hit_rate = hist_bear_cnt > 0 ? float(bear_hits) / float(hist_bear_cnt) * 100.0 : 0.0

float today_prob = is_bull ? bull_prob : bear_prob
string vs_prob   = today_prob > avg_prob + 5.0 ? "▲ Stronger than avg" :
                   today_prob < avg_prob - 5.0 ? "▼ Weaker than avg"   :
                                                  "≈ In line with avg"
string vs_delta  = math.abs(cum_delta) > math.abs(avg_delta) * 1.1 ? "▲ Above avg" :
                   math.abs(cum_delta) < math.abs(avg_delta) * 0.9 ? "▼ Below avg" :
                                                                       "≈ Average"

// ═══════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════
_score_bar(float v) =>
    int    filled = math.round(v * 8.0)
    string s      = ""
    for i = 0 to 7
        s += i < filled ? "█" : "░"
    s

_pct_bar(float v) =>
    int    filled = math.round(v / 100.0 * 8.0)
    string s      = ""
    for i = 0 to 7
        s += i < filled ? "█" : "░"
    s

// ═══════════════════════════════════════════════════════
//  TABLE
// ═══════════════════════════════════════════════════════
string tablePos = switch table_pos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    =>                position.bottom_left

int base_rows   = show_factors ? 17 : 14
int hist_rows   = 12
int total_rows  = base_rows + hist_rows

var table tbl = na
if barstate.isfirst
    tbl := table.new(tablePos, 2, total_rows,
         bgcolor      = color.new(#0d0d0d, 5),
         border_color = color.new(#3a3a3a, 0),
         border_width = 1,
         frame_color  = color.new(#555555, 0),
         frame_width  = 2)

_cell(int col, int row, string txt, color tc, bool is_header) =>
    table.cell(tbl, col, row, txt,
         text_color  = tc,
         text_size   = size.small,
         bgcolor     = is_header ? color.new(#1a1a2e, 0) : color.new(#0d0d0d, 0),
         text_halign = col == 0 ? text.align_left : text.align_right)

if not na(tbl) and barstate.islast
    color  bull_col = #00e676
    color  bear_col = #ff5252
    color  neut_col = #b0bec5
    color  head_col = #ffd54f
    color  info_col = #80cbc4
    color  warn_col = #ffb74d
    color  bias_col = is_bull ? bull_col : bear_col
    string flag     = is_uk ? "🇬🇧" : "🇺🇸"
    string sess_lbl = is_uk ? "UK Open  08:00 LON" : "US Open  09:30 NY"
    string bias_str = is_bull ? "▲  BULLISH" : "▼  BEARISH"

    // ── TODAY ──────────────────────────────────────────
    _cell(0, 0,  "PRE-SESSION ANALYSER",  head_col, true)
    _cell(1, 0,  flag + "  " + sess_lbl,  head_col, true)

    _cell(0, 1,  "── Window ──",          neut_col, false)
    _cell(1, 1,  str.tostring(lookback_hours) + "h before open", neut_col, false)

    _cell(0, 2,  "Buy Volume",            neut_col, false)
    _cell(1, 2,  str.tostring(math.round(cum_buy),   format.volume), bull_col, false)

    _cell(0, 3,  "Sell Volume",           neut_col, false)
    _cell(1, 3,  str.tostring(math.round(cum_sell),  format.volume), bear_col, false)

    _cell(0, 4,  "Net Delta",             neut_col, false)
    _cell(1, 4,  str.tostring(math.round(cum_delta), format.volume),
         cum_delta >= 0.0 ? bull_col : bear_col, false)

    _cell(0, 5,  "Total Volume",          neut_col, false)
    _cell(1, 5,  str.tostring(math.round(cum_vol),   format.volume), neut_col, false)

    _cell(0, 6,  "Bull / Bear Bars",      neut_col, false)
    _cell(1, 6,  str.tostring(bull_bars) + " / " + str.tostring(bear_bars), neut_col, false)

    _cell(0, 7,  "Max / Min Delta",       neut_col, false)
    _cell(1, 7,  str.tostring(math.round(max_delta), format.volume)
                 + " / "
                 + str.tostring(math.round(min_delta), format.volume), neut_col, false)

    _cell(0, 8,  "── Bias ──",            head_col, true)
    _cell(1, 8,  bias_str,                bias_col, true)

    _cell(0, 9,  "Bull Probability",      neut_col, false)
    _cell(1, 9,  str.tostring(math.round(bull_prob, 1)) + "%", bull_col, false)

    _cell(0, 10, "Bear Probability",      neut_col, false)
    _cell(1, 10, str.tostring(math.round(bear_prob, 1)) + "%", bear_col, false)

    _cell(0, 11, "Confidence",            neut_col, false)
    _cell(1, 11, conf_str,                bias_col, false)

    _cell(0, 12, "Weights  Δ/Bars/Skew",  neut_col, false)
    _cell(1, 12, str.tostring(math.round(w_d * 100.0)) + "/"
                 + str.tostring(math.round(w_b * 100.0)) + "/"
                 + str.tostring(math.round(w_s * 100.0)) + "%", info_col, false)

    if show_factors
        _cell(0, 13, "── Factor Scores ──",  head_col, true)
        _cell(1, 13, "0%  ←  →  100%",       head_col, true)

        _cell(0, 14, "Delta Magnitude",       neut_col, false)
        _cell(1, 14, _score_bar(f_delta) + " "
                     + str.tostring(math.round(f_delta * 100.0)) + "%",
             f_delta >= 0.5 ? bias_col : neut_col, false)

        _cell(0, 15, "Bar Ratio",             neut_col, false)
        _cell(1, 15, _score_bar(f_bars) + " "
                     + str.tostring(math.round(f_bars * 100.0)) + "%",
             f_bars >= 0.5 ? bias_col : neut_col, false)

        _cell(0, 16, "Spike Skew",            neut_col, false)
        _cell(1, 16, _score_bar(f_skew) + " "
                     + str.tostring(math.round(f_skew * 100.0)) + "%",
             f_skew >= 0.5 ? bias_col : neut_col, false)

    // ── HISTORY ────────────────────────────────────────
    int hr = base_rows

    _cell(0, hr, "── History  ("
                 + str.tostring(completed) + "/"
                 + str.tostring(hist_sessions) + " sessions) ──", head_col, true)
    _cell(1, hr, "1st Hour Follow-Through",  head_col, true)

    color hr_col  = hit_rate >= 60.0 ? bull_col : hit_rate >= 45.0 ? warn_col : bear_col
    _cell(0, hr + 1, "Overall Hit Rate",     neut_col, false)
    _cell(1, hr + 1, _pct_bar(hit_rate) + " "
                     + str.tostring(math.round(hit_rate, 1)) + "%", hr_col, false)

    color bhr_col = bull_hit_rate >= 60.0 ? bull_col : bull_hit_rate >= 45.0 ? warn_col : bear_col
    _cell(0, hr + 2, "Bull Bias Hit Rate",   neut_col, false)
    _cell(1, hr + 2, hist_bull_cnt > 0 ?
         _pct_bar(bull_hit_rate) + " "
         + str.tostring(math.round(bull_hit_rate, 1)) + "%"
         + "  (" + str.tostring(hist_bull_cnt) + ")"
         : "No data yet", bhr_col, false)

    color behr_col = bear_hit_rate >= 60.0 ? bull_col : bear_hit_rate >= 45.0 ? warn_col : bear_col
    _cell(0, hr + 3, "Bear Bias Hit Rate",   neut_col, false)
    _cell(1, hr + 3, hist_bear_cnt > 0 ?
         _pct_bar(bear_hit_rate) + " "
         + str.tostring(math.round(bear_hit_rate, 1)) + "%"
         + "  (" + str.tostring(hist_bear_cnt) + ")"
         : "No data yet", behr_col, false)

    _cell(0, hr + 4, "── Avg Pre-Session ──", head_col, true)
    _cell(1, hr + 4, str.tostring(hist_sessions) + " session avg", head_col, true)

    _cell(0, hr + 5, "Avg Buy Volume",        neut_col, false)
    _cell(1, hr + 5, completed > 0 ? str.tostring(math.round(avg_buy), format.volume) : "No data", bull_col, false)

    _cell(0, hr + 6, "Avg Sell Volume",       neut_col, false)
    _cell(1, hr + 6, completed > 0 ? str.tostring(math.round(avg_sell), format.volume) : "No data", bear_col, false)

    _cell(0, hr + 7, "Avg Net Delta",         neut_col, false)
    _cell(1, hr + 7, completed > 0 ? str.tostring(math.round(avg_delta), format.volume) : "No data", neut_col, false)

    _cell(0, hr + 8, "Avg Confidence",        neut_col, false)
    _cell(1, hr + 8, completed > 0 ? str.tostring(math.round(avg_comp * 100.0, 1)) + "%" : "No data", neut_col, false)

    _cell(0, hr + 9, "── Today vs Avg ──",   head_col, true)
    _cell(1, hr + 9, "Comparison",           head_col, true)

    _cell(0, hr + 10, "Probability vs Avg",   neut_col, false)
    _cell(1, hr + 10, vs_prob, completed > 0 ? (today_prob > avg_prob ? bull_col : bear_col) : neut_col, false)

    _cell(0, hr + 11, "Delta vs Avg",         neut_col, false)
    _cell(1, hr + 11, vs_delta, completed > 0 ? (math.abs(cum_delta) > math.abs(avg_delta) ? bull_col : bear_col) : neut_col, false)
````
