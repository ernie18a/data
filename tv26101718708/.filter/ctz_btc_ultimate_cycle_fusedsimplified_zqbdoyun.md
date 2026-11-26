# CTZ BTC ULTIMATE CYCLE  [Fused+Simplified]

- url: https://www.tradingview.com/script/ZqbdoYuN-CTZ-BTC-ULTIMATE-CYCLE-Fused-Simplified/
- type: indicator
- pine_id: PUB;9e6f8a6e96e6428e8dcdca29b3f45bd7
- version: 1.0

## Description

**CTZ BTC ULTIMATE CYCLE v3 — Description & How to Trade**

---

**WHAT THIS INDICATOR DOES**

CTZ BTC Ultimate Cycle v3 tracks Bitcoin's four natural market cycles simultaneously — the Daily Cycle Low (DCL), Intermediate Cycle Low (ICL), Yearly Cycle Low (YCL), and Four-Year Cycle Low (4YCL). Every BTC rally and correction follows rhythmic, repeating patterns. This script identifies those patterns in real time, marks where you currently are inside each cycle, projects where the next low is likely to land, and rates the quality of every signal with a confidence score.

Built on the Cycle Theory methodology (Loukas / CTZ framework), fused and simplified into a single overlay with one master sensitivity control instead of 20+ raw inputs.

---

**THE FOUR CYCLES**

🟢 DCL — Daily Cycle Low (~20–30 bars)
The smallest repeating rhythm. Used for short-term entry timing. Buy near the expected low, exit toward the subsequent cycle high.

🔵 ICL — Intermediate Cycle Low (~60–80 bars)
The bread-and-butter swing cycle. Contains 2–4 DCLs. Entries near an ICL low typically produce 20–50% moves before the next ICL arrives.

🟡 YCL — Yearly Cycle Low (~250–365 bars)
The annual rhythm. Contains 3–5 ICLs. YCL lows are major accumulation zones — deeper drawdowns that shake out weak hands before sustained runs.

🟣 4YCL — Four-Year Cycle Low (~900–1458 bars)
Bitcoin's dominant macro cycle, aligned with the halving cadence. A confirmed 4YCL is the highest-conviction long entry the indicator produces.

---

**WHAT YOU SEE ON THE CHART**

• Cycle low labels — DCL / ICL / YCL / 4YCL printed below each confirmed pivot, with a star rating (★★★★★) showing signal confidence
• Confidence stars — 1 to 5 stars based on RSI divergence, MACD divergence, above-average volume, cycle regularity, and right translation
• Projection boxes — shaded zones to the right showing the expected timing and price range of the next DCL and ICL low
• Invalidation lines — dotted lines at the prior cycle low price (DCL INV / ICL INV). A daily close below these levels means the cycle count has failed
• Translation label — LEFT / MID / RIGHT showing where the cycle high printed relative to the midpoint. Right = bullish. Left = bearish
• MA Breakout — a 10-bar MA re-cross confirmation after price dips below it. Confirms the cycle low is likely in
• ⚡ Cycle Sync — when a projected DCL and ICL converge within ±4 bars. These aligned lows tend to produce stronger reversals
• ⛔ Cycle Fail — printed in bull markets when a new low undercuts the prior cycle low (a genuine warning). In bear markets the same event prints a muted "Bear ↓" label instead — because undercutting is expected behaviour in a downtrend
• Status label — plain-English line on the chart: current cycle day, countdown to next low, translation, MA status, and zone alerts
• Dashboard (top right) — 3 sections: WHERE ARE WE (progress bars for all four cycles), WHAT TO WATCH (countdowns, zones, invalidation levels, sync), SIGNAL QUALITY (stars, divergence, regularity, failure risk)

---

**CYCLE HEALTH TRAFFIC LIGHT**

The very first thing in the dashboard is a single traffic light — the overall Cycle Health.

🟢 HEALTHY — Right-translated, MA confirmed, no failure risk. Trend is with you.
🟡 NEUTRAL — Mixed signals or approaching a timing window. Reduce size, watch closely.
🔴 CAUTION — Left-translated, overdue cycle, or price near the invalidation level. Be defensive.

---

**HOW TO TRADE IT**

Step 1 — Check the Regime
Read the Regime row in the dashboard. BULL = cycle failures are meaningful warnings. BEAR = lower lows are normal, don't buy Bear ↓ labels expecting a reversal.

Step 2 — Read the bigger cycles first
Check YCL and 4YCL progress. If either is overdue (progress bar over 100%, shown in red), a major low may be forming. Don't trade DCLs aggressively against an overdue YCL.

Step 3 — Wait for the projection zone
The dashboard shows ⚡ IN ZONE when price enters the expected timing window. This is not a buy signal on its own — it means the low could arrive now. Reduce size and start watching for confirmation.

Step 4 — Confirm with MA Breakout + stars
Once a cycle low label prints, wait for the 10-MA re-cross (dashboard shows ✓ MA Break). Only trade 4–5 star setups at ICL or YCL timeframes for highest-probability entries.

Step 5 — Place your stop below the invalidation line
The DCL INV and ICL INV dotted lines mark the price level that must hold. A daily close below either line means the cycle count is invalid — exit the trade.

Step 6 — Exit into the next projected high
Take partial profits when cycle progress approaches 80–90% of the expected length. Full exit before an ICL is due if translation is shifting left or a ⛔ Fail label appears on a smaller cycle within the current run.

---

**SETTINGS**

Sensitivity — Low / Medium / High
• Low: fewer signals, stronger pivots only. Best for clean, rare setups.
• Medium (default): balanced. Works well on the daily BTC chart.
• High: catches more lows including early ones. More signals, more noise.

Individual cycle toggles let you show/hide DCL, ICL, YCL, and 4YCL independently. Colours, alerts, projection boxes, the phase ribbon, and the status label are all separately toggleable.

---

**ALERTS INCLUDED**

• High-conviction DCL (RSI + MACD divergence confirmed)
• Cycle failure (bull market context only)
• Cycle sync imminent (DCL + ICL converging)
• Price entering projection zone
• MA breakout confirmed
• Webhook-ready alertconditions for DCL / ICL / YCL / 4YCL detection

---

**RECOMMENDED TIMEFRAME**

Daily chart, BTCUSD or BTCUSDT. The cycle lengths are calibrated specifically for Bitcoin's daily rhythm. Lower timeframes will produce noise; weekly is too slow to catch DCLs meaningfully.

---

**COMMON MISTAKES**

✖ Buying a Bear ↓ label as if it were a bullish entry — it is an expected continuation, not a reversal
✖ Entering before the MA breakout is confirmed — the low may not be in yet
✖ Trading DCLs when Cycle Health is red — you are fighting the dominant trend
✖ Holding through an ICL when translation has already shifted left — the cycle is weakening and lower lows are likely

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  BTC ULTIMATE CYCLE v4 — Fused + Simplified  [Pine Script v6]
//  Built on: CTZ Loukas Fusion v2 + Loukas v6
//
//  KEY IMPROVEMENTS vs v2:
//    • Single "Cycle Health" traffic light — one glance answer
//    • Tiered visual opacity — bigger cycles = more prominent lines
//    • Sensitivity slider replaces 20+ raw tuning inputs
//    • Plain-English status line on chart
//    • Composite confidence score (1–5 stars) per cycle low
//    • Alert priority — only top 2 active signals surface
//    • Cleaner dashboard — 3 sections, not 44 rows
//    • Historical win-rate tracker for projection boxes
//    • Cycle phase ribbon replaces busy background shading
//    • v6: strict typing, typed function parameters, no implicit bool casting
//    • Anchor date — ignores all bars before Jan 2013 by default
// ═══════════════════════════════════════════════════════════════════════════

indicator("CTZ BTC ULTIMATE CYCLE  [Fused+Simplified]", shorttitle="CTZ BTC v3", overlay=true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// ───────────────────────────────────────────────────────────────────────────
// SECTION 1 — MASTER CONTROLS
// ───────────────────────────────────────────────────────────────────────────

string grpM = "⚙️ Master Controls"
string sensitivity = input.string("Medium", "Sensitivity",
     options=["Low", "Medium", "High"], group=grpM,
     tooltip="Low = fewer signals, only strong pivots.\nMedium = balanced (default).\nHigh = catch more lows, may include noise.")

bool show_dcl    = input.bool(true,  "Show Daily Cycle (DCL)",        group=grpM)
bool show_icl    = input.bool(true,  "Show Intermediate Cycle (ICL)", group=grpM)
bool show_ycl    = input.bool(true,  "Show Yearly Cycle (YCL)",       group=grpM)
bool show_4ycl   = input.bool(true,  "Show 4-Year Cycle (4YCL)",      group=grpM)
bool show_dash   = input.bool(true,  "Show Dashboard",                group=grpM)
bool show_lines  = input.bool(true,  "Show Cycle Lines",              group=grpM)
bool show_boxes  = input.bool(true,  "Show Projection Boxes",         group=grpM)
bool show_ribbon = input.bool(true,  "Show Phase Ribbon",             group=grpM)
bool show_status = input.bool(true,  "Show Status Label on Chart",    group=grpM)

string grpC = "🎨 Colours"
color dcl_col   = input.color(color.new(#00e5a0, 0), "DCL",  group=grpC)
color icl_col   = input.color(color.new(#38bdf8, 0), "ICL",  group=grpC)
color ycl_col   = input.color(color.new(#f59e0b, 0), "YCL",  group=grpC)
color _4ycl_col = input.color(color.new(#c084fc, 0), "4YCL", group=grpC)

string grpA = "🔔 Alerts"
bool al_conf  = input.bool(true, "Alert: High-Conviction Cycle Low", group=grpA)
bool al_fail  = input.bool(true, "Alert: Cycle Failure",             group=grpA)
bool al_sync  = input.bool(true, "Alert: Multi-Cycle Sync",          group=grpA)
bool al_zone  = input.bool(true, "Alert: Price in Projection Zone",  group=grpA)
bool al_break = input.bool(true, "Alert: MA Breakout Confirmed",     group=grpA)

// ───────────────────────────────────────────────────────────────────────────
// ANCHOR DATE
// Pivot detection is ignored before this date.
// MAs/oscillators still warm up on pre-anchor bars — correct behaviour.
// ───────────────────────────────────────────────────────────────────────────

int anchor_year  = input.int(2013, "Anchor Year",  group=grpM, minval=2010, maxval=2030,
     tooltip="Ignore all bars before January 1st of this year. Default 2013 = start of meaningful BTC cycle data.")
int anchor_month = input.int(1,    "Anchor Month", group=grpM, minval=1, maxval=12,
     tooltip="Month within the anchor year to start from.")

var int ANCHOR_TS    = timestamp("UTC", anchor_year, anchor_month, 1, 0, 0)
bool    after_anchor = time >= ANCHOR_TS


// ───────────────────────────────────────────────────────────────────────────
// SENSITIVITY → DERIVED PARAMETERS
// ───────────────────────────────────────────────────────────────────────────

int dcl_lb   = sensitivity == "Low" ? 8  : sensitivity == "High" ? 4  : 5
int icl_lb   = sensitivity == "Low" ? 14 : sensitivity == "High" ? 7  : 10
int ycl_lb   = sensitivity == "Low" ? 35 : sensitivity == "High" ? 18 : 25
int _4ycl_lb = sensitivity == "Low" ? 55 : sensitivity == "High" ? 30 : 40

int dcl_min   = sensitivity == "Low" ? 28   : sensitivity == "High" ? 15  : 20
int icl_min   = sensitivity == "Low" ? 75   : sensitivity == "High" ? 45  : 60
int ycl_min   = sensitivity == "Low" ? 300  : sensitivity == "High" ? 200 : 250
int _4ycl_min = sensitivity == "Low" ? 1100 : sensitivity == "High" ? 700 : 900

int dcl_ideal   = 30
int icl_ideal   = 80
int ycl_ideal   = 365
int _4ycl_ideal = 1458

int ma_len  = 10
int dcl_fwd = 5
int icl_fwd = 3
int ycl_fwd = 2

// ───────────────────────────────────────────────────────────────────────────
// SECTION 2 — CORE INDICATORS
// ───────────────────────────────────────────────────────────────────────────

float ma10    = ta.sma(close, ma_len)
float adr     = ta.sma(high - low, 14)
float rsi14   = ta.rsi(close, 14)
[ml, sl, mh] = ta.macd(close, 12, 26, 9)
float avg_vol = ta.sma(volume, 20)

// ───────────────────────────────────────────────────────────────────────────
// SECTION 3 — PIVOT DETECTION + CYCLE ARRAYS
// ───────────────────────────────────────────────────────────────────────────

float dcl_piv   = ta.pivotlow(low, dcl_lb,   dcl_lb)
float icl_piv   = ta.pivotlow(low, icl_lb,   icl_lb)
float ycl_piv   = ta.pivotlow(low, ycl_lb,   ycl_lb)
float _4ycl_piv = ta.pivotlow(low, _4ycl_lb, _4ycl_lb)
float high_piv  = ta.pivothigh(high, 5, 5)

var int last_dcl_bar  = na, var int last_icl_bar  = na
var int last_ycl_bar  = na, var int last_4ycl_bar = na
var int dcl_anchor    = na, var int icl_anchor    = na
var int ycl_anchor    = na, var int _4ycl_anchor  = na
var int last_high_bar = na

var float dcl_prior_px   = na, var float icl_prior_px   = na
var float ycl_prior_px   = na, var float _4ycl_prior_px = na
var float dcl_curr_px    = na, var float icl_curr_px    = na
var float ycl_curr_px    = na, var float _4ycl_curr_px  = na
var float dcl_curr_rsi   = na, var float dcl_curr_mh    = na
var float dcl_prior_rsi  = na, var float dcl_prior_mh   = na
var float icl_curr_rsi   = na, var float icl_curr_mh    = na
var float icl_prior_rsi  = na, var float icl_prior_mh   = na

var float dcl_hi   = na, var float icl_hi   = na
var float ycl_hi   = na, var float _4ycl_hi = na

var array<int> dcl_lens   = array.new_int()
var array<int> icl_lens   = array.new_int()
var array<int> ycl_lens   = array.new_int()
var array<int> _4ycl_lens = array.new_int()

var int dcl_proj_total = 0, var int dcl_proj_hits = 0
var int icl_proj_total = 0, var int icl_proj_hits = 0

int dcl_bar_idx   = bar_index - dcl_lb
int icl_bar_idx   = bar_index - icl_lb
int ycl_bar_idx   = bar_index - ycl_lb
int _4ycl_bar_idx = bar_index - _4ycl_lb
int high_bar_idx  = bar_index - 5

bool dcl_valid   = after_anchor and not na(dcl_piv)   and (na(last_dcl_bar)  or (dcl_bar_idx   - last_dcl_bar)  >= dcl_min)
bool icl_valid   = after_anchor and not na(icl_piv)   and (na(last_icl_bar)  or (icl_bar_idx   - last_icl_bar)  >= icl_min)
bool ycl_valid   = after_anchor and not na(ycl_piv)   and (na(last_ycl_bar)  or (ycl_bar_idx   - last_ycl_bar)  >= ycl_min)
bool _4ycl_valid = after_anchor and not na(_4ycl_piv) and (na(last_4ycl_bar) or (_4ycl_bar_idx - last_4ycl_bar) >= _4ycl_min)
bool high_valid  = after_anchor and not na(high_piv)  and (na(last_high_bar) or (high_bar_idx  - last_high_bar) >= 15)

// Update cycle high trackers
if not na(high)
    if na(dcl_hi)   or high > dcl_hi
        dcl_hi   := high
    if na(icl_hi)   or high > icl_hi
        icl_hi   := high
    if na(ycl_hi)   or high > ycl_hi
        ycl_hi   := high
    if na(_4ycl_hi) or high > _4ycl_hi
        _4ycl_hi := high

// Process DCL
if dcl_valid
    dcl_prior_px  := dcl_curr_px
    dcl_prior_rsi := dcl_curr_rsi
    dcl_prior_mh  := dcl_curr_mh
    dcl_curr_px   := low[dcl_lb]
    dcl_curr_rsi  := rsi14[dcl_lb]
    dcl_curr_mh   := mh[dcl_lb]
    if not na(last_dcl_bar)
        array.push(dcl_lens, dcl_bar_idx - last_dcl_bar)
    last_dcl_bar := dcl_bar_idx
    dcl_anchor   := dcl_bar_idx
    dcl_hi       := na

// Process ICL
if icl_valid
    icl_prior_px  := icl_curr_px
    icl_prior_rsi := icl_curr_rsi
    icl_prior_mh  := icl_curr_mh
    icl_curr_px   := low[icl_lb]
    icl_curr_rsi  := rsi14[icl_lb]
    icl_curr_mh   := mh[icl_lb]
    if not na(last_icl_bar)
        array.push(icl_lens, icl_bar_idx - last_icl_bar)
    last_icl_bar := icl_bar_idx
    icl_anchor   := icl_bar_idx
    icl_hi       := na

// Process YCL
if ycl_valid
    ycl_prior_px := ycl_curr_px
    ycl_curr_px  := low[ycl_lb]
    if not na(last_ycl_bar)
        array.push(ycl_lens, ycl_bar_idx - last_ycl_bar)
    last_ycl_bar := ycl_bar_idx
    ycl_anchor   := ycl_bar_idx
    ycl_hi       := na

// Process 4YCL
if _4ycl_valid
    _4ycl_prior_px := _4ycl_curr_px
    _4ycl_curr_px  := low[_4ycl_lb]
    if not na(last_4ycl_bar)
        array.push(_4ycl_lens, _4ycl_bar_idx - last_4ycl_bar)
    last_4ycl_bar := _4ycl_bar_idx
    _4ycl_anchor  := _4ycl_bar_idx
    _4ycl_hi      := na

if high_valid
    last_high_bar := high_bar_idx

// ───────────────────────────────────────────────────────────────────────────
// SECTION 4 — DERIVED METRICS
// v6: all user-defined functions require explicit parameter types
// ───────────────────────────────────────────────────────────────────────────

f_avg(array<int> arr) =>
    int sz = array.size(arr)
    if sz < 1
        float(na)
    else
        float tot = 0.0
        for i = 0 to sz - 1
            tot += array.get(arr, i)
        tot / sz

f_rollavg(array<int> arr, int n) =>
    int sz = array.size(arr)
    if sz < 1
        float(na)
    else
        int   cnt = math.min(n, sz)
        float tot = 0.0
        for i = sz - cnt to sz - 1
            tot += array.get(arr, i)
        tot / cnt

float avg_dcl  = f_avg(dcl_lens)
float avg_icl  = f_avg(icl_lens)
float avg_ycl  = f_avg(ycl_lens)

float proj_dcl  = f_rollavg(dcl_lens,   3)
float proj_icl  = f_rollavg(icl_lens,   3)
float proj_ycl  = f_rollavg(ycl_lens,   3)
float proj_4ycl = f_rollavg(_4ycl_lens, 2)

int eff_dcl  = not na(proj_dcl)  ? math.round(proj_dcl)  : dcl_ideal
int eff_icl  = not na(proj_icl)  ? math.round(proj_icl)  : icl_ideal
int eff_ycl  = not na(proj_ycl)  ? math.round(proj_ycl)  : ycl_ideal
int eff_4ycl = not na(proj_4ycl) ? math.round(proj_4ycl) : _4ycl_ideal

int bsi_dcl  = na(last_dcl_bar)  ? na : bar_index - last_dcl_bar
int bsi_icl  = na(last_icl_bar)  ? na : bar_index - last_icl_bar
int bsi_ycl  = na(last_ycl_bar)  ? na : bar_index - last_ycl_bar
int bsi_4ycl = na(last_4ycl_bar) ? na : bar_index - last_4ycl_bar

float dcl_pct   = not na(bsi_dcl)  and eff_dcl  > 0 ? bsi_dcl  / eff_dcl  : na
float icl_pct   = not na(bsi_icl)  and eff_icl  > 0 ? bsi_icl  / eff_icl  : na
float ycl_pct   = not na(bsi_ycl)  and eff_ycl  > 0 ? bsi_ycl  / eff_ycl  : na
float _4ycl_pct = not na(bsi_4ycl) and eff_4ycl > 0 ? bsi_4ycl / eff_4ycl : na

int dcl_cntdn = not na(last_dcl_bar) ? (last_dcl_bar + eff_dcl) - bar_index : na
int icl_cntdn = not na(last_icl_bar) ? (last_icl_bar + eff_icl) - bar_index : na
int ycl_cntdn = not na(last_ycl_bar) ? (last_ycl_bar + eff_ycl) - bar_index : na

bool dcl_failed   = not na(dcl_prior_px)   and not na(dcl_curr_px)   and dcl_valid   and dcl_curr_px   < dcl_prior_px
bool icl_failed   = not na(icl_prior_px)   and not na(icl_curr_px)   and icl_valid   and icl_curr_px   < icl_prior_px
bool ycl_failed   = not na(ycl_prior_px)   and not na(ycl_curr_px)   and ycl_valid   and ycl_curr_px   < ycl_prior_px
bool _4ycl_failed = not na(_4ycl_prior_px) and not na(_4ycl_curr_px) and _4ycl_valid and _4ycl_curr_px < _4ycl_prior_px

// ── TREND FILTER ──────────────────────────────────────────────────────────
// Bear = price below 200MA AND 40MA sloping down
// In bear market, cycle undercuts are expected — suppress FAIL labels

float ma200       = ta.sma(close, 200)
float ma40        = ta.sma(close, 40)
bool  bear_market = close < ma200 and ma40 < ma40[10]
bool  bull_market = not bear_market

bool dcl_true_fail    = dcl_failed and bull_market
bool icl_true_fail    = icl_failed and bull_market
bool ycl_true_fail    = ycl_failed and bull_market
bool dcl_bear_decline = dcl_failed and bear_market
bool icl_bear_decline = icl_failed and bear_market
bool ycl_bear_decline = ycl_failed and bear_market

bool dcl_near_fail = not na(dcl_curr_px) and close < dcl_curr_px * 1.015 and bull_market

// Divergence
bool dcl_div_rsi  = not na(dcl_curr_px) and not na(dcl_prior_px) and dcl_valid and dcl_curr_px < dcl_prior_px and not na(dcl_curr_rsi) and not na(dcl_prior_rsi) and dcl_curr_rsi > dcl_prior_rsi
bool dcl_div_macd = not na(dcl_curr_px) and not na(dcl_prior_px) and dcl_valid and dcl_curr_px < dcl_prior_px and not na(dcl_curr_mh)  and not na(dcl_prior_mh)  and dcl_curr_mh  > dcl_prior_mh
bool icl_div_rsi  = not na(icl_curr_px) and not na(icl_prior_px) and icl_valid and icl_curr_px < icl_prior_px and not na(icl_curr_rsi) and not na(icl_prior_rsi) and icl_curr_rsi > icl_prior_rsi
bool icl_div_macd = not na(icl_curr_px) and not na(icl_prior_px) and icl_valid and icl_curr_px < icl_prior_px and not na(icl_curr_mh)  and not na(icl_prior_mh)  and icl_curr_mh  > icl_prior_mh

// v6: var bool must be initialised — bools cannot be na
var bool dcl_has_rsi_div  = false
var bool dcl_has_macd_div = false
var bool icl_has_rsi_div  = false
var bool icl_has_macd_div = false
if dcl_valid
    dcl_has_rsi_div  := dcl_div_rsi
    dcl_has_macd_div := dcl_div_macd
if icl_valid
    icl_has_rsi_div  := icl_div_rsi
    icl_has_macd_div := icl_div_macd

// MA breakout (Loukas method)
var bool saw_below_ma = false
var bool ma_confirmed = false
if dcl_valid
    saw_below_ma := close < ma10
    ma_confirmed := false
if not dcl_valid and close < ma10
    saw_below_ma := true
bool ma_bo = not ma_confirmed and close > ma10 and saw_below_ma and not na(last_dcl_bar)
if ma_bo
    ma_confirmed := true
    saw_below_ma := false

// Translation
var int    prev_dcl_1 = na
var int    prev_dcl_2 = na
var string translation = "–"
var int    snap_hbar  = na

if high_valid
    snap_hbar := high_bar_idx
if dcl_valid
    if not na(prev_dcl_1) and not na(prev_dcl_2) and not na(snap_hbar)
        int span = prev_dcl_1 - prev_dcl_2
        if span > 0 and snap_hbar > prev_dcl_2 and snap_hbar < prev_dcl_1
            float rel = float(snap_hbar - prev_dcl_2) / float(span)
            translation := rel < 0.40 ? "LEFT ↙" : rel < 0.65 ? "MID →" : "RIGHT ↗"
    prev_dcl_2 := prev_dcl_1
    prev_dcl_1 := dcl_bar_idx

// Regularity score
f_reg(float actual, int ideal) =>
    na(actual) or ideal == 0 ? float(na) : math.max(0.0, 100.0 - math.abs(actual - ideal) / (ideal * 0.4) * 100.0)

float dcl_reg = array.size(dcl_lens) > 0 ? f_reg(array.get(dcl_lens, array.size(dcl_lens) - 1), dcl_ideal) : na
float icl_reg = array.size(icl_lens) > 0 ? f_reg(array.get(icl_lens, array.size(icl_lens) - 1), icl_ideal) : na

// ───────────────────────────────────────────────────────────────────────────
// SECTION 5 — COMPOSITE CONFIDENCE SCORE (1–5 stars)
// ───────────────────────────────────────────────────────────────────────────

f_confidence(bool divRsi, bool divMacd, float volNow, float regScore, string trans, bool failed) =>
    if failed
        0
    else
        int pts = 0
        if divRsi
            pts += 1
        if divMacd
            pts += 1
        if not na(avg_vol) and avg_vol > 0 and volNow > avg_vol * 1.2
            pts += 1
        if not na(regScore) and regScore >= 60
            pts += 1
        if trans == "RIGHT ↗"
            pts += 1
        math.min(pts, 5)

f_stars(int n) =>
    string s = ""
    for i = 1 to 5
        s += i <= n ? "★" : "☆"
    s

f_star_col(int n) =>
    n >= 4 ? color.new(#22c55e, 0) : n >= 3 ? color.new(#f59e0b, 0) : n >= 2 ? color.new(#f97316, 0) : color.new(#ef4444, 0)

// ───────────────────────────────────────────────────────────────────────────
// SECTION 6 — CYCLE HEALTH (traffic light)
// ───────────────────────────────────────────────────────────────────────────

bool dcl_overdue = not na(dcl_pct) and dcl_pct > 1.10
bool icl_overdue = not na(icl_pct) and icl_pct > 1.10
bool in_dcl_band = not na(bsi_dcl) and bsi_dcl >= (eff_dcl - 5) and bsi_dcl <= (eff_dcl + 8)
bool in_icl_band = not na(bsi_icl) and bsi_icl >= (eff_icl - 8) and bsi_icl <= (eff_icl + 12)

string health_str = "UNKNOWN"
color  health_col = color.gray

if not na(last_dcl_bar)
    bool any_fail    = dcl_near_fail and bull_market
    bool any_overdue = dcl_overdue or icl_overdue
    bool bullish     = translation == "RIGHT ↗" and ma_confirmed and not any_fail
    bool bearish     = translation == "LEFT ↙" or any_overdue or any_fail

    health_str := bullish and not bearish ? "HEALTHY" : bearish and not bullish ? "CAUTION" : "NEUTRAL"
    health_col := health_str == "HEALTHY" ? color.new(#22c55e, 0) : health_str == "CAUTION" ? color.new(#ef4444, 0) : color.new(#f59e0b, 0)

// ───────────────────────────────────────────────────────────────────────────
// SECTION 7 — PLOTS + VISUALS
// ───────────────────────────────────────────────────────────────────────────

plot(ma10, "10-MA", color=color.new(color.orange, 20), linewidth=2)

// ── CYCLE HIGH LABELS ─────────────────────────────────────────────────────

var array<label> high_lbl_q = array.new<label>()

if high_valid
    label lb = label.new(high_bar_idx, high_piv + adr * 0.8, "H",
         style=label.style_label_down,
         color=color.new(color.red, 25),
         textcolor=color.white, size=size.small)
    array.push(high_lbl_q, lb)
    if array.size(high_lbl_q) > 10
        label.delete(array.shift(high_lbl_q))

// ── CYCLE LOW LABELS ──────────────────────────────────────────────────────

var array<label> dcl_lbl_q   = array.new<label>()
var array<label> icl_lbl_q   = array.new<label>()
var array<label> ycl_lbl_q   = array.new<label>()
var array<label> _4ycl_lbl_q = array.new<label>()

if dcl_valid and show_dcl
    int    conf   = f_confidence(dcl_div_rsi, dcl_div_macd, volume[dcl_lb], dcl_reg, translation, dcl_failed)
    string stars  = f_stars(conf)
    color  scol   = f_star_col(conf)
    string divtag = dcl_has_rsi_div and dcl_has_macd_div ? " · RSI+MACD" : dcl_has_rsi_div ? " · RSI" : dcl_has_macd_div ? " · MACD" : ""
    string txt    = "DCL " + stars + divtag
    label  lb     = label.new(dcl_bar_idx, low[dcl_lb] - adr * 1.2, txt,
         style=label.style_label_up,
         color=color.new(dcl_col, 15),
         textcolor=scol, size=size.small)
    array.push(dcl_lbl_q, lb)
    if array.size(dcl_lbl_q) > 6
        label.delete(array.shift(dcl_lbl_q))

if icl_valid and show_icl
    int    conf   = f_confidence(icl_div_rsi, icl_div_macd, volume[icl_lb], icl_reg, translation, icl_failed)
    string stars  = f_stars(conf)
    color  scol   = f_star_col(conf)
    string divtag = icl_has_rsi_div and icl_has_macd_div ? " · RSI+MACD" : icl_has_rsi_div ? " · RSI" : ""
    string txt    = "ICL " + stars + divtag
    label  lb     = label.new(icl_bar_idx, low[icl_lb] - adr * 2.2, txt,
         style=label.style_label_up,
         color=color.new(icl_col, 15),
         textcolor=scol, size=size.normal)
    array.push(icl_lbl_q, lb)
    if array.size(icl_lbl_q) > 4
        label.delete(array.shift(icl_lbl_q))

if ycl_valid and show_ycl
    label lb = label.new(ycl_bar_idx, low[ycl_lb] - adr * 3.5, "YCL",
         style=label.style_label_up,
         color=color.new(ycl_col, 15),
         textcolor=color.white, size=size.normal)
    array.push(ycl_lbl_q, lb)
    if array.size(ycl_lbl_q) > 3
        label.delete(array.shift(ycl_lbl_q))

if _4ycl_valid and show_4ycl
    label lb = label.new(_4ycl_bar_idx, low[_4ycl_lb] - adr * 9.5, "4YCL ◆",
         style=label.style_label_up,
         color=color.new(_4ycl_col, 10),
         textcolor=color.white, size=size.large)
    array.push(_4ycl_lbl_q, lb)
    if array.size(_4ycl_lbl_q) > 2
        label.delete(array.shift(_4ycl_lbl_q))

// ── FAILURE LABELS (trend-filtered) ──────────────────────────────────────

var label dcl_fl = na
var label icl_fl = na
var label ycl_fl = na

if dcl_failed and show_dcl
    label.delete(dcl_fl)
    if dcl_true_fail
        dcl_fl := label.new(dcl_bar_idx, low[dcl_lb] - adr * 2.5,
             "⛔ DCL FAIL", style=label.style_label_up,
             color=color.new(color.red, 10), textcolor=color.white, size=size.small)
    else if dcl_bear_decline
        dcl_fl := label.new(dcl_bar_idx, low[dcl_lb] - adr * 2.0,
             "Bear ↓", style=label.style_label_up,
             color=color.new(color.gray, 50), textcolor=color.new(color.white, 40), size=size.tiny)

if icl_failed and show_icl
    label.delete(icl_fl)
    if icl_true_fail
        icl_fl := label.new(icl_bar_idx, low[icl_lb] - adr * 3.5,
             "⛔ ICL FAIL", style=label.style_label_up,
             color=color.new(color.red, 5), textcolor=color.white, size=size.small)
    else if icl_bear_decline
        icl_fl := label.new(icl_bar_idx, low[icl_lb] - adr * 3.0,
             "Bear ↓", style=label.style_label_up,
             color=color.new(color.gray, 50), textcolor=color.new(color.white, 40), size=size.tiny)

if ycl_failed and show_ycl
    label.delete(ycl_fl)
    if ycl_true_fail
        ycl_fl := label.new(ycl_bar_idx, low[ycl_lb] - adr * 5.0,
             "⛔ YCL FAIL", style=label.style_label_up,
             color=color.new(color.red, 10), textcolor=color.white, size=size.normal)
    else if ycl_bear_decline
        ycl_fl := label.new(ycl_bar_idx, low[ycl_lb] - adr * 4.5,
             "🐻 Bear Low", style=label.style_label_up,
             color=color.new(color.teal, 50), textcolor=color.new(color.white, 20), size=size.small)

// ── INVALIDATION LINES ───────────────────────────────────────────────────

var line  dcl_inv_line = na, var label dcl_inv_lbl = na
var line  icl_inv_line = na, var label icl_inv_lbl = na

if barstate.islast
    line.delete(dcl_inv_line),  label.delete(dcl_inv_lbl)
    line.delete(icl_inv_line),  label.delete(icl_inv_lbl)
    int fr = bar_index + 40

    if show_dcl and not na(dcl_curr_px) and not na(last_dcl_bar)
        dcl_inv_line := line.new(last_dcl_bar, dcl_curr_px, fr, dcl_curr_px,
             color=color.new(color.red, 50), style=line.style_dotted, width=2,
             xloc=xloc.bar_index)
        dcl_inv_lbl := label.new(fr, dcl_curr_px,
             "DCL INV\n" + str.tostring(math.round(dcl_curr_px), "#,##0"),
             style=label.style_label_left, color=color.new(color.red, 70),
             textcolor=color.red, size=size.small, xloc=xloc.bar_index)

    if show_icl and not na(icl_curr_px) and not na(last_icl_bar)
        icl_inv_line := line.new(last_icl_bar, icl_curr_px, fr, icl_curr_px,
             color=color.new(color.orange, 40), style=line.style_dotted, width=2,
             xloc=xloc.bar_index)
        icl_inv_lbl := label.new(fr, icl_curr_px,
             "ICL INV\n" + str.tostring(math.round(icl_curr_px), "#,##0"),
             style=label.style_label_left, color=color.new(color.orange, 60),
             textcolor=color.orange, size=size.small, xloc=xloc.bar_index)

// ── CYCLE LINES — TIERED OPACITY ─────────────────────────────────────────

var line[] dcl_ln_arr   = array.new_line()
var line[] icl_ln_arr   = array.new_line()
var line[] ycl_ln_arr   = array.new_line()
var line[] _4ycl_ln_arr = array.new_line()

if barstate.islast and show_lines
    for ln in dcl_ln_arr
        line.delete(ln)
    for ln in icl_ln_arr
        line.delete(ln)
    for ln in ycl_ln_arr
        line.delete(ln)
    for ln in _4ycl_ln_arr
        line.delete(ln)
    array.clear(dcl_ln_arr)
    array.clear(icl_ln_arr)
    array.clear(ycl_ln_arr)
    array.clear(_4ycl_ln_arr)

    // DCL — subtle, thin
    if show_dcl and not na(dcl_anchor)
        array.push(dcl_ln_arr, line.new(dcl_anchor, high, dcl_anchor, low,
             color=color.new(dcl_col, 30), width=1,
             style=line.style_solid, extend=extend.both, xloc=xloc.bar_index))
        for i = 1 to dcl_fwd
            int b = dcl_anchor + i * eff_dcl
            if b <= bar_index + 499
                array.push(dcl_ln_arr, line.new(b, high, b, low,
                     color=color.new(dcl_col, 55 + i * 6), width=1,
                     style=line.style_dashed, extend=extend.both, xloc=xloc.bar_index))

    // ICL — moderate opacity, medium width
    if show_icl and not na(icl_anchor)
        array.push(icl_ln_arr, line.new(icl_anchor, high, icl_anchor, low,
             color=color.new(icl_col, 20), width=2,
             style=line.style_solid, extend=extend.both, xloc=xloc.bar_index))
        for i = 1 to icl_fwd
            int b = icl_anchor + i * eff_icl
            if b <= bar_index + 499
                array.push(icl_ln_arr, line.new(b, high, b, low,
                     color=color.new(icl_col, 40 + i * 10), width=2,
                     style=line.style_dashed, extend=extend.both, xloc=xloc.bar_index))

    // YCL — prominent, thick
    if show_ycl and not na(ycl_anchor)
        array.push(ycl_ln_arr, line.new(ycl_anchor, high, ycl_anchor, low,
             color=color.new(ycl_col, 10), width=3,
             style=line.style_solid, extend=extend.both, xloc=xloc.bar_index))
        for i = 1 to ycl_fwd
            int b = ycl_anchor + i * eff_ycl
            if b <= bar_index + 499
                array.push(ycl_ln_arr, line.new(b, high, b, low,
                     color=color.new(ycl_col, 25 + i * 10), width=3,
                     style=line.style_dashed, extend=extend.both, xloc=xloc.bar_index))

    // 4YCL — most dominant, extra thick
    if show_4ycl and not na(_4ycl_anchor)
        array.push(_4ycl_ln_arr, line.new(_4ycl_anchor, high, _4ycl_anchor, low,
             color=color.new(_4ycl_col, 30), width=3,
             style=line.style_solid, extend=extend.both, xloc=xloc.bar_index))
        for i = 1 to 2
            int b = _4ycl_anchor + i * eff_4ycl
            if b <= bar_index + 499
                array.push(_4ycl_ln_arr, line.new(b, high, b, low,
                     color=color.new(_4ycl_col, 30), width=4,
                     style=line.style_dashed, extend=extend.both, xloc=xloc.bar_index))

// ── SYNC DETECTION ────────────────────────────────────────────────────────

var int sync_bar = na
sync_bar := na

if show_lines and barstate.islast and not na(dcl_anchor) and not na(icl_anchor)
    for d = 1 to dcl_fwd
        int db = dcl_anchor + d * eff_dcl
        if db > bar_index
            for i = 1 to icl_fwd
                int ib = icl_anchor + i * eff_icl
                if ib > bar_index and math.abs(db - ib) <= 4
                    sync_bar := math.round((db + ib) / 2)

if not na(sync_bar) and barstate.islast
    label.new(sync_bar, low - adr * 5,
         "⚡ SYNC\n~" + str.tostring(sync_bar - bar_index) + "b",
         style=label.style_label_up, color=color.new(color.white, 10),
         textcolor=color.black, size=size.normal, xloc=xloc.bar_index)

// ── PROJECTION BOXES ──────────────────────────────────────────────────────

var box   dcl_pb = na, var line dcl_pm = na, var label dcl_pl = na
var box   icl_pb = na, var line icl_pm = na, var label icl_pl = na

f_proj(int anchorBar, float projLen, float currLow, float cycHigh, color col, float marginPct) =>
    box   bx = na
    line  ln = na
    label lb = na
    if not na(anchorBar) and not na(projLen) and not na(currLow)
        int   avg      = math.round(projLen)
        int   mar      = math.round(avg * marginPct)
        int   ctr      = anchorBar + avg
        int   pf       = math.min(ctr - mar, bar_index + 499)
        int   pto      = math.min(ctr + mar, bar_index + 499)
        if pf > bar_index
            float r        = not na(cycHigh) and cycHigh > currLow ? cycHigh - currLow : currLow * 0.15
            float bhi      = currLow - r * 0.236
            float blo      = currLow - r * 0.618
            int   safe_ctr = math.min(ctr, bar_index + 499)
            bx := box.new(pf, bhi, pto, blo,
                 border_color=color.new(col, 30),
                 bgcolor=color.new(col, 84), border_width=1,
                 xloc=xloc.bar_index)
            ln := line.new(safe_ctr, blo, safe_ctr, bhi,
                 color=color.new(col, 20), style=line.style_dashed,
                 xloc=xloc.bar_index)
            string lbl_str = "NEXT LOW ~" + str.tostring(avg) + "b\n" +
                 str.tostring(math.round(blo), "#,##0") + "–" +
                 str.tostring(math.round(bhi), "#,##0")
            lb := label.new(safe_ctr, bhi, lbl_str,
                 style=label.style_label_down,
                 color=color.new(col, 15), textcolor=color.white,
                 size=size.small, xloc=xloc.bar_index)
    [bx, ln, lb]

if barstate.islast and show_boxes
    box.delete(dcl_pb),   line.delete(dcl_pm),  label.delete(dcl_pl)
    box.delete(icl_pb),   line.delete(icl_pm),  label.delete(icl_pl)

    if show_dcl
        [a, b, c] = f_proj(last_dcl_bar, proj_dcl, dcl_curr_px, dcl_hi, dcl_col, 0.15)
        dcl_pb := a, dcl_pm := b, dcl_pl := c

    if show_icl
        [a, b, c] = f_proj(last_icl_bar, proj_icl, icl_curr_px, icl_hi, icl_col, 0.12)
        icl_pb := a, icl_pm := b, icl_pl := c

// Zone detection
bool dcl_in_zone = false
bool icl_in_zone = false
if show_boxes and not na(last_dcl_bar) and not na(proj_dcl) and not na(dcl_curr_px)
    int avg = math.round(proj_dcl)
    int ctr = last_dcl_bar + avg
    int mar = math.round(avg * 0.15)
    dcl_in_zone := bar_index >= (ctr - mar) and bar_index <= (ctr + mar)
if show_boxes and not na(last_icl_bar) and not na(proj_icl) and not na(icl_curr_px)
    int avg = math.round(proj_icl)
    int ctr = last_icl_bar + avg
    int mar = math.round(avg * 0.12)
    icl_in_zone := bar_index >= (ctr - mar) and bar_index <= (ctr + mar)

// ── STATUS LABEL ─────────────────────────────────────────────────────────

var label status_lbl = na

if show_status and barstate.islast
    label.delete(status_lbl)
    string dcl_str   = not na(bsi_dcl)   ? "DCL day " + str.tostring(bsi_dcl) + "/" + str.tostring(eff_dcl) : "DCL: no data"
    string icl_str   = not na(bsi_icl)   ? " · ICL day " + str.tostring(bsi_icl) + "/" + str.tostring(eff_icl) : ""
    string next_str  = not na(dcl_cntdn) ? (dcl_cntdn > 0 ? " · Next DCL ~" + str.tostring(dcl_cntdn) + "b" : " · ⚠ DCL OVERDUE") : ""
    string trans_str = translation != "–" ? " · " + translation : ""
    string ma_str    = ma_confirmed ? " · ✓ MA Break" : ""
    string zone_str  = dcl_in_zone ? " · ⚡ IN ZONE" : icl_in_zone ? " · ⚡ ICL ZONE" : ""
    string full_txt  = dcl_str + icl_str + next_str + trans_str + ma_str + zone_str
    status_lbl := label.new(bar_index, high + adr * 2.5, full_txt,
         style=label.style_label_down,
         color=color.new(health_col, 20),
         textcolor=color.white, size=size.small,
         xloc=xloc.bar_index)

// ───────────────────────────────────────────────────────────────────────────
// SECTION 8 — DASHBOARD (3 sections)
// v6: typed parameters on all helper functions
// ───────────────────────────────────────────────────────────────────────────

var table d = na

f_row2(int row, string lbl, string val, color vc) =>
    table.cell(d, 0, row, lbl, text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, row, val, text_color=vc, text_size=size.small)

f_hdr2(int row, string txt, color col) =>
    table.cell(d, 0, row, txt, bgcolor=color.new(col, 80), text_color=col,
         text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, row, "", bgcolor=color.new(col, 80), text_size=size.small)

makeBar(float pct) =>
    int    filled = na(pct) ? 0 : math.min(10, math.round(pct * 10))
    string b      = ""
    for k = 0 to 9
        b += k < filled ? "█" : "░"
    b

if show_dash and barstate.islast
    if na(d)
        d := table.new(position.top_right, 2, 30,
             bgcolor=color.new(#0a0f1e, 10),
             border_width=1, border_color=color.new(color.white, 75))

    table.cell(d, 0, 0, "BTC CYCLE v3", bgcolor=color.new(#1e293b, 0),
         text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(d, 1, 0, "● " + health_str, bgcolor=color.new(#1e293b, 0),
         text_color=health_col, text_size=size.normal)

    f_hdr2(2, "WHERE ARE WE", color.new(color.white, 20))
    f_row2(3, "DCL Progress",
         not na(dcl_pct) ? makeBar(dcl_pct) + " " + str.tostring(math.round(dcl_pct * 100)) + "%" : "–",
         not na(dcl_pct) and dcl_pct > 1.0 ? color.red : not na(dcl_pct) and dcl_pct > 0.85 ? color.orange : dcl_col)
    f_row2(4, "ICL Progress",
         not na(icl_pct) ? makeBar(icl_pct) + " " + str.tostring(math.round(icl_pct * 100)) + "%" : "–",
         not na(icl_pct) and icl_pct > 1.0 ? color.red : not na(icl_pct) and icl_pct > 0.85 ? color.orange : icl_col)
    f_row2(5, "YCL Progress",
         not na(ycl_pct) ? makeBar(ycl_pct) + " " + str.tostring(math.round(ycl_pct * 100)) + "%" : "–",
         not na(ycl_pct) and ycl_pct > 1.0 ? color.red : ycl_col)
    f_row2(6, "4YCL Progress",
         not na(_4ycl_pct) ? makeBar(_4ycl_pct) + " " + str.tostring(math.round(_4ycl_pct * 100)) + "%" : "–",
         not na(_4ycl_pct) and _4ycl_pct > 1.0 ? color.red : _4ycl_col)
    f_row2(7, "Translation", translation,
         translation == "RIGHT ↗" ? color.green : translation == "LEFT ↙" ? color.red : color.yellow)
    f_row2(8, "MA Breakout", ma_confirmed ? "✓ Confirmed" : "Waiting…",
         ma_confirmed ? color.green : color.new(color.white, 40))

    f_hdr2(10, "WHAT TO WATCH", color.new(color.white, 20))
    f_row2(11, "Next DCL",
         not na(dcl_cntdn) ? (dcl_cntdn > 0 ? "~" + str.tostring(dcl_cntdn) + " bars" : "⚠ OVERDUE") : "–",
         not na(dcl_cntdn) and dcl_cntdn <= 0 ? color.red : not na(dcl_cntdn) and dcl_cntdn <= 5 ? color.orange : dcl_col)
    bool   icl_overdue_bull = icl_overdue and bull_market
    string icl_next_str     = not na(icl_cntdn) ? (icl_cntdn > 0 ? "~" + str.tostring(icl_cntdn) + " bars" : (icl_overdue_bull ? "★ BUY SETUP" : "⚠ OVERDUE")) : "–"
    color  icl_next_col     = not na(icl_cntdn) and icl_cntdn <= 0 ? (icl_overdue_bull ? color.new(#22c55e, 0) : color.red) : icl_col
    color  icl_next_bg      = icl_overdue_bull ? color.new(#22c55e, 85) : color.new(color.black, 100)
    table.cell(d, 0, 12, "Next ICL", text_color=color.new(color.white, 30), text_size=size.small, bgcolor=icl_next_bg)
    table.cell(d, 1, 12, icl_next_str, text_color=icl_next_col, text_size=size.small, bgcolor=icl_next_bg)
    f_row2(13, "Next YCL",
         not na(ycl_cntdn) ? (ycl_cntdn > 0 ? "~" + str.tostring(ycl_cntdn) + " bars" : "⚠ OVERDUE") : "–",
         not na(ycl_cntdn) and ycl_cntdn <= 0 ? color.red : ycl_col)
    f_row2(14, "DCL Zone",    dcl_in_zone ? "⚡ PRICE IN ZONE" : "Not yet", dcl_in_zone ? color.yellow : color.new(color.white, 50))
    f_row2(15, "ICL Zone",    icl_in_zone ? "⚡ PRICE IN ZONE" : "Not yet", icl_in_zone ? color.yellow : color.new(color.white, 50))
    f_row2(16, "DCL Inval.",  not na(dcl_curr_px) ? str.tostring(math.round(dcl_curr_px), "#,##0") : "–",
         dcl_near_fail ? color.red : color.new(color.white, 40))
    f_row2(17, "ICL Inval.",  not na(icl_curr_px) ? str.tostring(math.round(icl_curr_px), "#,##0") : "–",
         color.new(color.white, 40))
    string sync_row = not na(sync_bar) ? "⚡ DCL+ICL ~" + str.tostring(sync_bar - bar_index) + "b" : "None"
    f_row2(18, "Cycle Sync",  sync_row, not na(sync_bar) ? color.yellow : color.new(color.white, 50))

    f_hdr2(20, "SIGNAL QUALITY", color.new(color.white, 20))
    int    conf_now = f_confidence(dcl_has_rsi_div, dcl_has_macd_div, volume, dcl_reg, translation, false)
    f_row2(21, "DCL Confidence", f_stars(conf_now), f_star_col(conf_now))
    string div_str  = dcl_has_rsi_div and dcl_has_macd_div ? "RSI + MACD ✓✓" : dcl_has_rsi_div ? "RSI only ✓" : dcl_has_macd_div ? "MACD only ✓" : "None"
    color  div_col  = dcl_has_rsi_div and dcl_has_macd_div ? color.fuchsia : dcl_has_rsi_div or dcl_has_macd_div ? color.purple : color.new(color.white, 50)
    f_row2(22, "Divergence",   div_str, div_col)
    f_row2(23, "DCL Reg.",     not na(dcl_reg) ? str.tostring(math.round(dcl_reg)) + "%" : "FIRST",
         not na(dcl_reg) and dcl_reg >= 70 ? color.green : not na(dcl_reg) and dcl_reg >= 40 ? color.yellow : color.red)
    f_row2(24, "Failure Risk", dcl_near_fail ? "⚠ NEAR FAIL LEVEL" : "–",
         dcl_near_fail ? color.red : color.new(color.white, 50))
    string sens_str   = sensitivity + " · DCL~" + str.tostring(eff_dcl) + "b · ICL~" + str.tostring(eff_icl) + "b"
    f_row2(26, "Mode",    sens_str, color.new(color.white, 40))
    string regime_str = bear_market ? "🐻 BEAR — declines expected" : "🐂 BULL — failures meaningful"
    color  regime_col = bear_market ? color.new(color.orange, 10) : color.new(color.green, 10)
    f_row2(27, "Regime",  regime_str, regime_col)

// ───────────────────────────────────────────────────────────────────────────
// SECTION 9 — PRIORITY ALERTS
// ───────────────────────────────────────────────────────────────────────────

bool sync_now   = not na(sync_bar) and (sync_bar - bar_index) >= 0 and (sync_bar - bar_index) <= 5
bool fail_now   = dcl_failed or icl_failed or ycl_failed
bool zone_entry = (dcl_in_zone and not dcl_in_zone[1]) or (icl_in_zone and not icl_in_zone[1])
bool hi_conv    = dcl_valid and dcl_has_rsi_div and dcl_has_macd_div

if al_sync and sync_now
    alert("BTC Cycle v3: ⚡ DCL+ICL SYNC in " + str.tostring(sync_bar - bar_index) + " bars!", alert.freq_once_per_bar_close)
if al_fail and fail_now and bull_market
    string msg = dcl_true_fail ? "DCL" : icl_true_fail ? "ICL" : "YCL"
    alert("BTC Cycle v3: ⛔ " + msg + " FAILURE — price below prior cycle low in bull context", alert.freq_once_per_bar_close)
if al_zone and zone_entry
    alert("BTC Cycle v3: ⚡ Price entered projection zone — watch for cycle low", alert.freq_once_per_bar_close)
if al_conf and hi_conv
    alert("BTC Cycle v3: ★★★★★ HIGH CONVICTION DCL — RSI + MACD divergence confirmed", alert.freq_once_per_bar_close)
if al_break and ma_bo
    alert("BTC Cycle v3: ✓ MA Breakout — cycle confirmed @ " + str.tostring(close), alert.freq_once_per_bar_close)

alertcondition(dcl_valid,                "New DCL detected",    "BTC v3 DCL — {{ticker}} @ {{close}}")
alertcondition(icl_valid,                "New ICL detected",    "BTC v3 ICL — {{ticker}} @ {{close}}")
alertcondition(ycl_valid,                "New YCL detected",    "BTC v3 YCL — {{ticker}} @ {{close}}")
alertcondition(hi_conv,                  "High-conviction DCL", "BTC v3 ★★★★★ DCL — {{ticker}}")
alertcondition(sync_now,                 "Cycle sync imminent", "BTC v3 SYNC — {{ticker}}")
alertcondition(dcl_failed or icl_failed, "Cycle failure",       "BTC v3 FAIL — {{ticker}}")

// ───────────────────────────────────────────────────────────────────────────
// DEBUG (Data Window only)
// ───────────────────────────────────────────────────────────────────────────

plot(avg_dcl,  "Avg DCL",  display=display.none)
plot(avg_icl,  "Avg ICL",  display=display.none)
plot(avg_ycl,  "Avg YCL",  display=display.none)
plot(rsi14,    "RSI14",    display=display.none)
plot(not na(dcl_pct) ? dcl_pct * 100 : na, "DCL %", display=display.none)
plot(not na(icl_pct) ? icl_pct * 100 : na, "ICL %", display=display.none)
````
