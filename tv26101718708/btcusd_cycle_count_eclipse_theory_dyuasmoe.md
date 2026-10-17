# BTCUSD Cycle Count + Eclipse Theory

- url: https://www.tradingview.com/script/DyUAsmoE-BTCUSD-Cycle-Count-Eclipse-Theory/
- type: indicator
- pine_id: PUB;aa6f95ffff5246118a91e6c674e7810f
- version: 2.0

## Description

BTCUSD Cycle Count + Eclipse Theory that predicts future cycles using past information

## Source Code

````pine
//@version=6
indicator("BTCUSD Cycle Count + Eclipse Theory", overlay=true, max_bars_back=5000)

// =============================================================================
//  BTCUSD CYCLE COUNT + ECLIPSE THEORY  v3.0
//  Camel Finance / Hurst cycles + Waters Above eclipse theory
//
//  Working scenario: Nov 2026 Accumulation Watch -> Aug 2027 Acceleration Watch
//                    -> late-2028 Top Watch (CONDITIONAL -- see astro caution layer)
//
//  v3.0 changes vs v2.6:
//  1. Bug fix: 2021-11-19 removed from LUNAR (was 97.4% partial, NOT total blood moon)
//  2. Bug fix: Drought dates corrected -- DROUGHT_S = Mar 4 2026, DROUGHT_E = Dec 31 2028
//  3. Bug fix: Solar eclipse array now has separate SOLAR_A array for annular events
//  4. New: Partial/penumbral lunar eclipse array PARTIAL (informational markers)
//  5. New: Astro caution layer -- retrogrades, stations, Mars-Saturn aspects
//  6. New: Experimental caution score (additive weights, labeled unvalidated)
//  7. New: Price confirmation state machine (4 states, price-driven not calendar-driven)
//  8. New: Caution shading within projected bull scenario zone
//  9. Softened: Hardcoded BUY/SELL language -> Watch / Scenario language
//  10. New: 5 additional alerts for caution layer
//
//  Supported timeframes: Daily (1D) recommended. Works on 4H / Weekly.
//  Pivot signal lag: i_piv_r bars after actual low -- NOT a real-time signal.
//  All dates UTC. Astro caution score is EXPERIMENTAL -- not a trade signal.
//  BTC-astro correlations have not been rigorously backtested.
//  Not compiled. Syntax follows Pine Script v6 conventions, manually reviewed.
// =============================================================================

// â”€â”€ INPUTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var string G1 = "Cycle Settings"
var string G2 = "Pivot Detection"
var string G3 = "Eclipse / Waters Above"
var string G4 = "Display"
var string G5 = "Future Projections"
var string G6 = "Astro Caution Layer (Experimental)"
var string G7 = "Price Confirmation"
var string G8 = "Risk Calendar (Event Watch)"

i_dc_min     = input.int(54,    "Daily Cycle Min (days)",         minval=10,  maxval=150, group=G1)
i_dc_max     = input.int(66,    "Daily Cycle Max (days)",         minval=10,  maxval=200, group=G1)
i_dc_tol     = input.float(0.20,"Tolerance -- 0.20 = ~79d max",  minval=0.0, maxval=0.5, step=0.01, group=G1)
i_wc_min     = input.int(22,    "Weekly Cycle Min (weeks)",       minval=5,   maxval=60,  group=G1)
i_wc_max     = input.int(42,    "Weekly Cycle Max (weeks)",       minval=10,  maxval=80,  group=G1)
i_4y_yr      = input.int(2022,  "Last 4yr Low -- Year",           minval=2009,maxval=2030,group=G1)
i_4y_mo      = input.int(11,    "Last 4yr Low -- Month",          minval=1,   maxval=12,  group=G1)
i_4y_dy      = input.int(21,    "Last 4yr Low -- Day",            minval=1,   maxval=31,  group=G1)
i_4y_len     = input.int(1461,  "4yr Cycle Length (days)",        minval=1000,maxval=1800,group=G1)

i_piv_l      = input.int(10,    "Pivot Left Bars",                minval=2,   maxval=50,  group=G2)
i_piv_r      = input.int(10,    "Pivot Right Bars",               minval=2,   maxval=50,  group=G2)
i_min_sep    = input.int(45,    "Min Days Between Lows",          minval=10,  maxval=100, group=G2)
i_show_early_dcl = input.bool(true, "Show Early DCL Watch (Stage 1)", group=G2)
i_early_piv_l    = input.int(3,     "Early DCL Left Bars",            minval=1,   maxval=10,  group=G2)
i_early_piv_r    = input.int(2,     "Early DCL Lag Bars",             minval=1,   maxval=5,   group=G2,
                     tooltip="Fast confirmation lag: number of closed bars after a local low inside the cycle window (default 2 bars).")

i_wa_before  = input.int(42,    "WA Window: Days Before Eclipse", minval=14,  maxval=90,  group=G3)
i_wa_after   = input.int(21,    "WA Window: Days After Eclipse",  minval=7,   maxval=60,  group=G3)

i_show_dcbg  = input.bool(true, "Daily Cycle Background",         group=G4)
i_show_wcbg  = input.bool(true, "Weekly Cycle Background",        group=G4)
i_show_wa    = input.bool(true, "Eclipse / WA Background",        group=G4)
i_show_dcl   = input.bool(true, "Cycle Low Labels",               group=G4)
i_show_emkr  = input.bool(true, "Eclipse Day Markers",            group=G4)
i_show_tbl   = input.bool(true, "Dashboard Table",                group=G4)
i_tbl_pos    = input.string("bottom_right", "Table Position",
     options=["bottom_right","bottom_left","top_right","top_left"], group=G4)

i_show_bull    = input.bool(true,  "Bull Scenario Projection Box", group=G5)
i_show_proj    = input.bool(true,  "Future Event Labels",          group=G5)
i_show_drought = input.bool(true,  "Eclipse Drought Zone",         group=G5)
i_show_dcl_proj = input.bool(true,  "DCL Projection Window",         group=G5)
i_dc_avg_len    = input.int(28,     "DC Average Length (days)",       minval=14, maxval=60, group=G5)

i_show_caution  = input.bool(true,  "Show Caution Windows",               group=G6)
i_caution_hi    = input.int(5,      "High Caution Threshold (score)",      minval=1, maxval=15, group=G6)
i_caution_lo    = input.int(2,      "Caution Threshold (score)",           minval=1, maxval=15, group=G6)
i_w_mrx         = input.int(1,      "Mercury Rx Weight",                   minval=0, maxval=3,  group=G6)
i_w_vrx         = input.int(2,      "Venus Rx Weight",                     minval=0, maxval=3,  group=G6)
i_w_marsx       = input.int(2,      "Mars Rx Weight",                      minval=0, maxval=3,  group=G6)
i_w_mars_sat    = input.int(3,      "Mars-Saturn Conjunction Weight",       minval=0, maxval=5,  group=G6)
i_w_mars_sq     = input.int(2,      "Mars-Saturn Square Weight",            minval=0, maxval=5,  group=G6)
i_w_saturn_sd   = input.int(1,      "Saturn Station-Direct Weight",         minval=0, maxval=3,  group=G6)
i_w_uranus_sd   = input.int(2,      "Uranus Station-Direct Weight",         minval=0, maxval=3,  group=G6)
i_w_partial_lun = input.int(1,      "Partial Lunar Eclipse Weight",         minval=0, maxval=3,  group=G6)
i_aspect_days   = input.int(3,      "Aspect/Station Window Half-Width (d)", minval=2, maxval=21, group=G6)
i_show_cau_lbl  = input.bool(true,  "Show Caution Score Labels",            group=G6)
i_dynamic_bg    = input.bool(true,  "Dynamic Highlight Intensity & Tapering", group=G6)

i_show_price_st = input.bool(true,  "Show Price State",        group=G7)
i_ma_fast       = input.int(50,     "Fast MA (bars)",           minval=10, maxval=200, group=G7)
i_ma_slow       = input.int(200,    "Slow MA (bars)",           minval=50, maxval=500, group=G7)
i_swing_len     = input.int(20,     "Swing Low Lookback (bars)", minval=5, maxval=60,  group=G7)
i_recovery_bars = input.int(3,      "MA Recovery Bars Needed",  minval=1, maxval=10,  group=G7)

i_show_rc     = input.bool(true, "Show Risk Calendar Windows",               group=G8)
i_show_rc_lbl = input.bool(false, "Show Risk Calendar Labels",                 group=G8)
i_rc_days     = input.int(45,    "Show Future Labels Within N Days",          minval=7, maxval=180, group=G8)

// ── BACKGROUND COLOR SYSTEM (4 states) ────────────────────────────────────────
// Priority (high to low): CAUTION_HI > CAUTION_LO > CONVERGENCE > CYCLE > RC
// CAUTION_HI : vivid red    -- multiple astro events stacked (score >= threshold)
// CAUTION_LO : dim red      -- single astro caution event active
// CONVERGENCE: bright green -- cycle window AND eclipse window both open (best watch zone)
// CYCLE      : subtle green -- any cycle window open (DC, WC, or eclipse WA standalone)
// RC         : faint amber  -- scheduled macro event watch window
// NOTHING    : neutral      -- outside all windows (most common state)
color BG_CAUTION_HI = color.new(#D50000, 55)  // vivid red    -- high caution
color BG_CAUTION_LO = color.new(#B71C1C, 76)  // dim red      -- low caution
color BG_CONV       = color.new(#00C853, 68)  // bright green -- convergence (DC + eclipse)
color BG_CYCLE      = color.new(#1B5E20, 84)  // subtle green -- any cycle window open
color BG_RC         = color.new(#FF8F00, 87)  // faint amber  -- risk calendar
// Future projection boxes (barstate.islast only)
color BG_BULL       = color.new(#1B5E20, 91)
color BG_BEAR       = color.new(#B71C1C, 92)


color C_BUY      = color.new(#00E676, 0)
color C_SELL     = color.new(#FF1744, 0)
color C_WATCH    = color.new(#FFD740, 0)
color C_SOLAR    = color.new(#FFEA00, 0)
color C_PROJ     = color.new(#448AFF, 0)
color C_INFO     = color.new(#90A4AE, 0)
color C_CAUTION  = color.new(#FF6F00, 0)
color C_RC       = color.new(#FFAB40, 0)  // amber for risk calendar

color LBG_BUY    = color.new(#003300, 8)
color LBG_SELL   = color.new(#330000, 8)
color LBG_WATCH  = color.new(#332200, 8)
color LBG_SOLAR  = color.new(#332600, 8)
color LBG_PROJ   = color.new(#001133, 8)
color LBG_INFO   = color.new(#111111, 8)
color LBG_CAUT   = color.new(#2A1000, 8)
color LBG_RC     = color.new(#1A1000, 8)  // amber-dark background for RC labels

// â”€â”€ CONSTANTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
float MS_DAY  = 86400000.0
float DC_HI_F = float(i_dc_max) * (1.0 + i_dc_tol)
float WC_LO_F = float(i_wc_min) * 7.0
float WC_HI_F = float(i_wc_max) * 7.0 * (1.0 + i_dc_tol)
int   YR4_TS  = timestamp(i_4y_yr, i_4y_mo, i_4y_dy, 0, 0)
int   PROJ_LOW  = YR4_TS + i_4y_len * int(MS_DAY)
int   PROJ_LOW2 = PROJ_LOW + i_4y_len * int(MS_DAY)
// v3.0 bug fix: drought dates corrected
int   DROUGHT_S = timestamp(2026,  3,  4, 0, 0)   // day after last blood moon (Mar 3 2026)
int   DROUGHT_E = timestamp(2028, 12, 31, 0, 0)   // the blood moon date itself

// â”€â”€ ECLIPSE ARRAYS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var int[] LUNAR   = array.new_int(0)  // total lunar only (blood moons)
var int[] SOLAR   = array.new_int(0)  // total solar only
var int[] SOLAR_A = array.new_int(0)  // annular solar (separate from total -- v3.0)
var int[] PARTIAL = array.new_int(0)  // partial/penumbral lunar (informational)

// â”€â”€ ASTRO CAUTION ARRAYS (parallel arrays for caution windows) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var int[]    CAU_S   = array.new_int(0)     // window start timestamp
var int[]    CAU_E   = array.new_int(0)     // window end timestamp
var string[] CAU_LBL = array.new_string(0)  // short display label
var int[]    CAU_CAT = array.new_int(0)     // category: 1=MRx 2=VRx 3=MarsRx 4=MS-Conj 5=MS-Sq 6=Sat-sD 7=Ura-sD 8=PartLun

// â”€â”€ RISK CALENDAR ARRAYS (macro/event watch windows -- separate from astro CAU) â”€â”€
// Add new events here in barstate.isfirst block. Keep small (< 20 events).
var int[]    RC_S   = array.new_int(0)     // window start timestamp
var int[]    RC_E   = array.new_int(0)     // window end timestamp (inclusive)
var string[] RC_LBL = array.new_string(0)  // short bar label (keep under 12 chars)
var string[] RC_TIP = array.new_string(0)  // full tooltip text

// â”€â”€ UTILITY FUNCTIONS (must be declared before use in barstate.isfirst) â”€â”€â”€â”€â”€â”€â”€â”€
f_on_eclipse(int[] dates) =>
    bool hit = false
    for i = 0 to array.size(dates) - 1
        if math.abs((time - array.get(dates, i)) / MS_DAY) <= 1.0
            hit := true
            break
    hit

f_in_wa(int[] dates, float bd, float ad) =>
    bool hit = false
    for i = 0 to array.size(dates) - 1
        float d = (time - array.get(dates, i)) / MS_DAY
        if d >= -bd and d <= ad
            hit := true
            break
    hit

f_wa_prox(int[] dates, float bd, float ad) =>
    float best_prox = 0.0
    int n = array.size(dates)
    if n > 0
        for i = 0 to n - 1
            float d = (time - array.get(dates, i)) / MS_DAY
            if d >= -bd and d <= ad
                float span = d <= 0.0 ? bd : ad
                float dist = math.abs(d)
                float p = math.max(0.25, 1.0 - math.min(1.0, dist / span) * 0.75)
                if p > best_prox
                    best_prox := p
    best_prox

f_next_ecl(int[] dates) =>
    int res = na
    for i = 0 to array.size(dates) - 1
        int ts = array.get(dates, i)
        if ts > time
            if na(res) or ts < res
                res := ts
    res

f_cat_weight(int cat) =>
    int w = 0
    if cat == 1
        w := i_w_mrx
    else if cat == 2
        w := i_w_vrx
    else if cat == 3
        w := i_w_marsx
    else if cat == 4
        w := i_w_mars_sat
    else if cat == 5
        w := i_w_mars_sq
    else if cat == 6
        w := i_w_saturn_sd
    else if cat == 7
        w := i_w_uranus_sd
    else if cat == 8
        w := i_w_partial_lun
    w

// Caution score: sum weights of active windows, one weight per category (no double-count)
f_caution_score() =>
    int score = 0
    // track which of 8 categories have been counted (cat 1..8 -> index 0..7)
    bool seen1 = false, bool seen2 = false, bool seen3 = false, bool seen4 = false
    bool seen5 = false, bool seen6 = false, bool seen7 = false, bool seen8 = false
    int n = array.size(CAU_S)
    for i = 0 to n - 1
        int ts = array.get(CAU_S, i)
        int te = array.get(CAU_E, i)
        if time >= ts and time <= te
            int cat = array.get(CAU_CAT, i)
            bool already = (cat == 1 and seen1) or (cat == 2 and seen2) or
                           (cat == 3 and seen3) or (cat == 4 and seen4) or
                           (cat == 5 and seen5) or (cat == 6 and seen6) or
                           (cat == 7 and seen7) or (cat == 8 and seen8)
            if not already
                score += f_cat_weight(cat)
                if cat == 1
                    seen1 := true
                else if cat == 2
                    seen2 := true
                else if cat == 3
                    seen3 := true
                else if cat == 4
                    seen4 := true
                else if cat == 5
                    seen5 := true
                else if cat == 6
                    seen6 := true
                else if cat == 7
                    seen7 := true
                else if cat == 8
                    seen8 := true
    score

// Dynamic Caution Orb: calculates proximity-weighted continuous caution intensity
// Each active window contributes (weight * proximity factor), peaking at window center and tapering to edges
f_dynamic_caution_orb() =>
    float orb_sum = 0.0
    bool seen1 = false, bool seen2 = false, bool seen3 = false, bool seen4 = false
    bool seen5 = false, bool seen6 = false, bool seen7 = false, bool seen8 = false
    int n = array.size(CAU_S)
    for i = 0 to n - 1
        int ts = array.get(CAU_S, i)
        int te = array.get(CAU_E, i)
        if time >= ts and time <= te
            int cat = array.get(CAU_CAT, i)
            bool already = (cat == 1 and seen1) or (cat == 2 and seen2) or
                           (cat == 3 and seen3) or (cat == 4 and seen4) or
                           (cat == 5 and seen5) or (cat == 6 and seen6) or
                           (cat == 7 and seen7) or (cat == 8 and seen8)
            if not already
                float dur  = float(te - ts)
                float hw   = math.max(MS_DAY, dur * 0.5)
                float mid  = float(ts) + hw
                float dist = math.abs(time - mid)
                float prox = math.max(0.25, 1.0 - (dist / hw) * 0.75)
                orb_sum += float(f_cat_weight(cat)) * prox
                if cat == 1
                    seen1 := true
                else if cat == 2
                    seen2 := true
                else if cat == 3
                    seen3 := true
                else if cat == 4
                    seen4 := true
                else if cat == 5
                    seen5 := true
                else if cat == 6
                    seen6 := true
                else if cat == 7
                    seen7 := true
                else if cat == 8
                    seen8 := true
    orb_sum

f_next_caution_ts() =>
    int res = na
    int n = array.size(CAU_S)
    for i = 0 to n - 1
        int ts = array.get(CAU_S, i)
        if ts > time
            if na(res) or ts < res
                res := ts
    res

f_next_caution_lbl() =>
    string res = "none"
    int best   = na
    int n = array.size(CAU_S)
    for i = 0 to n - 1
        int ts = array.get(CAU_S, i)
        if ts > time
            if na(best) or ts < best
                best := ts
                res  := array.get(CAU_LBL, i)
    res

// â”€â”€ POPULATE ARRAYS (barstate.isfirst) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if barstate.isfirst

    // TOTAL LUNAR ECLIPSES (Blood Moons) -- NASA Eclipse Catalog
    // v3.0: 2021-11-19 removed (97.4% umbral partial, NOT total)
    array.push(LUNAR, timestamp(2018,  1, 31, 0, 0))
    array.push(LUNAR, timestamp(2018,  7, 27, 0, 0))
    array.push(LUNAR, timestamp(2019,  1, 21, 0, 0))
    array.push(LUNAR, timestamp(2021,  5, 26, 0, 0))
    array.push(LUNAR, timestamp(2022,  5, 16, 0, 0))
    array.push(LUNAR, timestamp(2022, 11,  8, 0, 0))
    array.push(LUNAR, timestamp(2025,  3, 14, 0, 0))
    array.push(LUNAR, timestamp(2025,  9,  7, 0, 0))
    array.push(LUNAR, timestamp(2026,  3,  3, 0, 0))   // last before 33-month drought
    array.push(LUNAR, timestamp(2028, 12, 31, 0, 0))   // first after drought -- top watch
    array.push(LUNAR, timestamp(2029,  6, 26, 0, 0))
    array.push(LUNAR, timestamp(2029, 12, 20, 0, 0))

    // TOTAL SOLAR ECLIPSES -- NASA Eclipse Catalog
    array.push(SOLAR, timestamp(2017,  8, 21, 0, 0))
    array.push(SOLAR, timestamp(2019,  7,  2, 0, 0))
    array.push(SOLAR, timestamp(2020, 12, 14, 0, 0))
    array.push(SOLAR, timestamp(2021, 12,  4, 0, 0))
    array.push(SOLAR, timestamp(2023,  4, 20, 0, 0))
    array.push(SOLAR, timestamp(2024,  4,  8, 0, 0))
    array.push(SOLAR, timestamp(2026,  8, 12, 0, 0))   // total -- Greenland/Spain
    array.push(SOLAR, timestamp(2027,  8,  2, 0, 0))   // total -- longest of century (6m23s)
    array.push(SOLAR, timestamp(2028,  7, 22, 0, 0))   // total -- Australia
    array.push(SOLAR, timestamp(2030, 11, 25, 0, 0))

    // ANNULAR SOLAR ECLIPSES -- NASA Eclipse Catalog (v3.0 -- separate array)
    // Annular = ring of fire; weaker WA signal than total
    array.push(SOLAR_A, timestamp(2026,  2, 17, 0, 0))
    array.push(SOLAR_A, timestamp(2027,  2,  6, 0, 0))
    array.push(SOLAR_A, timestamp(2028,  1, 26, 0, 0))

    // PARTIAL / PENUMBRAL LUNAR ECLIPSES -- NASA (informational; partial get weight, penumbral do not)
    array.push(PARTIAL, timestamp(2021, 11, 19, 0, 0))  // 97.4% umbral -- was mistakenly in LUNAR v2.6
    array.push(PARTIAL, timestamp(2026,  8, 28, 0, 0))  // partial ~45% umbral -- gets caution weight
    array.push(PARTIAL, timestamp(2027,  2, 20, 0, 0))  // penumbral -- informational only
    array.push(PARTIAL, timestamp(2027,  7, 18, 0, 0))  // penumbral
    array.push(PARTIAL, timestamp(2027,  8, 17, 0, 0))  // penumbral -- near Aug 2 solar eclipse
    array.push(PARTIAL, timestamp(2028,  1, 12, 0, 0))  // partial ~60% umbral -- gets caution weight
    array.push(PARTIAL, timestamp(2028,  7,  6, 0, 0))  // partial -- near Jul 22 solar eclipse

    // â”€â”€ ASTRO CAUTION EVENTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Caution window = event_date +/- i_aspect_days (user-adjustable)
    // Aspect/station windows use wd (half-width in ms); Rx periods use exact start/end dates.
    // Source: Astro-Seek ephemeris, AstrologyKing, Swiss Ephemeris cross-check.
    // All dates UTC. Historical crypto validation: NOT performed for most events.
    // Category codes: 1=MRx 2=VRx 3=MarsRx 4=MS-Conj 5=MS-Sq 6=Sat-sD 7=Ura-sD 8=PartLun

    int wd = i_aspect_days * int(MS_DAY)

    // MERCURY RETROGRADE (cat 1) -- 3x/year ~23 days. Evidence: mixed, no consistent bias.
    // 2026
    array.push(CAU_S,   timestamp(2026,  2, 26, 0, 0))
    array.push(CAU_E,   timestamp(2026,  3, 20, 0, 0))
    array.push(CAU_LBL, "MRx Feb-Mar 2026")
    array.push(CAU_CAT, 1)
    array.push(CAU_S,   timestamp(2026,  6, 29, 0, 0))
    array.push(CAU_E,   timestamp(2026,  7, 23, 0, 0))
    array.push(CAU_LBL, "MRx Jun-Jul 2026")
    array.push(CAU_CAT, 1)
    array.push(CAU_S,   timestamp(2026, 10, 24, 0, 0))
    array.push(CAU_E,   timestamp(2026, 11, 13, 0, 0))
    array.push(CAU_LBL, "MRx Oct-Nov 2026")
    array.push(CAU_CAT, 1)
    // 2027
    array.push(CAU_S,   timestamp(2027,  2,  9, 0, 0))
    array.push(CAU_E,   timestamp(2027,  3,  3, 0, 0))
    array.push(CAU_LBL, "MRx Feb-Mar 2027")
    array.push(CAU_CAT, 1)
    array.push(CAU_S,   timestamp(2027,  6, 10, 0, 0))
    array.push(CAU_E,   timestamp(2027,  7,  4, 0, 0))
    array.push(CAU_LBL, "MRx Jun-Jul 2027")
    array.push(CAU_CAT, 1)
    array.push(CAU_S,   timestamp(2027, 10,  7, 0, 0))
    array.push(CAU_E,   timestamp(2027, 10, 28, 0, 0))
    array.push(CAU_LBL, "MRx Oct 2027")
    array.push(CAU_CAT, 1)
    // 2028
    array.push(CAU_S,   timestamp(2028,  1, 24, 0, 0))
    array.push(CAU_E,   timestamp(2028,  2, 14, 0, 0))
    array.push(CAU_LBL, "MRx Jan-Feb 2028")
    array.push(CAU_CAT, 1)
    array.push(CAU_S,   timestamp(2028,  5, 21, 0, 0))
    array.push(CAU_E,   timestamp(2028,  6, 14, 0, 0))
    array.push(CAU_LBL, "MRx May-Jun 2028")
    array.push(CAU_CAT, 1)
    array.push(CAU_S,   timestamp(2028,  9, 19, 0, 0))
    array.push(CAU_E,   timestamp(2028, 10, 11, 0, 0))
    array.push(CAU_LBL, "MRx Sep-Oct 2028")
    array.push(CAU_CAT, 1)

    // VENUS RETROGRADE (cat 2) -- not every year, ~42 days. Evidence: some equity studies; crypto untested.
    // Opposing view: accumulation zones can form during Venus Rx.
    array.push(CAU_S,   timestamp(2026, 10,  3, 0, 0))
    array.push(CAU_E,   timestamp(2026, 11, 14, 0, 0))
    array.push(CAU_LBL, "VRx Oct-Nov 2026")
    array.push(CAU_CAT, 2)
    // No Venus Rx in 2027
    array.push(CAU_S,   timestamp(2028,  5, 10, 0, 0))
    array.push(CAU_E,   timestamp(2028,  6, 22, 0, 0))
    array.push(CAU_LBL, "VRx May-Jun 2028")
    array.push(CAU_CAT, 2)

    // MARS RETROGRADE (cat 3) -- once per ~26 months, ~80 days. Often marks trend reversal zones.
    // Shadow extends further; only Rx period coded as caution.
    array.push(CAU_S,   timestamp(2027,  1, 10, 0, 0))
    array.push(CAU_E,   timestamp(2027,  4,  1, 0, 0))
    array.push(CAU_LBL, "Mars Rx Jan-Apr 2027")
    array.push(CAU_CAT, 3)

    // MARS-SATURN CONJUNCTION (cat 4) -- wd window around exact date.
    // Apr 19 2026: conjunction in Aries. Conflicting: can mark new cycle start (bullish read).
    array.push(CAU_S,   timestamp(2026,  4, 19, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2026,  4, 19, 0, 0) + wd)
    array.push(CAU_LBL, "Mars-Saturn CNJ Apr 2026")
    array.push(CAU_CAT, 4)
    // Apr 30 2028: conjunction overlaps Venus Rx / Mercury Rx cluster
    array.push(CAU_S,   timestamp(2028,  4, 30, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2028,  4, 30, 0, 0) + wd)
    array.push(CAU_LBL, "Mars-Saturn CNJ Apr 2028")
    array.push(CAU_CAT, 4)

    // MARS-SATURN SQUARE (cat 5) -- wd window around exact date.
    // Evidence: some studies find elevated volatility; no confirmed crash signal.
    array.push(CAU_S,   timestamp(2026,  9,  1, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2026,  9,  1, 0, 0) + wd)
    array.push(CAU_LBL, "Mars-Saturn SQ Sep 2026")
    array.push(CAU_CAT, 5)
    array.push(CAU_S,   timestamp(2027, 12, 22, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2027, 12, 22, 0, 0) + wd)
    array.push(CAU_LBL, "Mars-Saturn SQ Dec 2027")
    array.push(CAU_CAT, 5)
    array.push(CAU_S,   timestamp(2028,  9, 21, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2028,  9, 21, 0, 0) + wd)
    array.push(CAU_LBL, "Mars-Saturn SQ Sep 2028")
    array.push(CAU_CAT, 5)

    // SATURN STATION-DIRECT (cat 6) -- wd window around sD date. Marks end of Saturn Rx.
    array.push(CAU_S,   timestamp(2026, 12, 10, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2026, 12, 10, 0, 0) + wd)
    array.push(CAU_LBL, "Saturn sD Dec 2026")
    array.push(CAU_CAT, 6)
    array.push(CAU_S,   timestamp(2027, 12, 24, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2027, 12, 24, 0, 0) + wd)
    array.push(CAU_LBL, "Saturn sD Dec 2027")
    array.push(CAU_CAT, 6)
    array.push(CAU_S,   timestamp(2029,  1,  5, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2029,  1,  5, 0, 0) + wd)
    array.push(CAU_LBL, "Saturn sD Jan 2029")
    array.push(CAU_CAT, 6)

    // URANUS STATION-DIRECT (cat 7) -- wd window. Uranus = sudden shocks; sD can mark resolution.
    array.push(CAU_S,   timestamp(2027,  2,  8, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2027,  2,  8, 0, 0) + wd)
    array.push(CAU_LBL, "Uranus sD Feb 2027")
    array.push(CAU_CAT, 7)
    array.push(CAU_S,   timestamp(2028,  2, 12, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2028,  2, 12, 0, 0) + wd)
    array.push(CAU_LBL, "Uranus sD Feb 2028")
    array.push(CAU_CAT, 7)
    array.push(CAU_S,   timestamp(2029,  2, 16, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2029,  2, 16, 0, 0) + wd)
    array.push(CAU_LBL, "Uranus sD Feb 2029")
    array.push(CAU_CAT, 7)

    // PARTIAL LUNAR ECLIPSES -- umbral partials only (cat 8); penumbrals not weighted
    array.push(CAU_S,   timestamp(2026,  8, 28, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2026,  8, 28, 0, 0) + wd)
    array.push(CAU_LBL, "Partial Lun Aug 2026")
    array.push(CAU_CAT, 8)
    array.push(CAU_S,   timestamp(2028,  1, 12, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2028,  1, 12, 0, 0) + wd)
    array.push(CAU_LBL, "Partial Lun Jan 2028")
    array.push(CAU_CAT, 8)
    array.push(CAU_S,   timestamp(2028,  7,  6, 0, 0) - wd)
    array.push(CAU_E,   timestamp(2028,  7,  6, 0, 0) + wd)
    array.push(CAU_LBL, "Partial Lun Jul 2028")
    array.push(CAU_CAT, 8)

    // â”€â”€ RISK CALENDAR EVENTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Macro / event watch windows. Direction is NEVER implied.
    // Each push must fill RC_S, RC_E, RC_LBL, RC_TIP in exact sync.
    // â”€ Oct 1-5 2026: Gann/Astro T-square watch (focus: Oct 3) â”€
    // -- Oct 1-2 2025: TOKEN2049 Singapore 2025 (historical reference)
    array.push(RC_S,   timestamp(2025, 10,  1, 0, 0))
    array.push(RC_E,   timestamp(2025, 10,  2, 23, 59))
    array.push(RC_LBL, "TOKEN2049 25")
    array.push(RC_TIP,
         "Oct 1-2 2025 -- TOKEN2049 Singapore 2025\n" +
         "Major crypto conference. Historical reference marker.\n\n" +
         "Context: Occurred during the Sep 2025 blood moon cluster.\n" +
         "BTC was in a cycle window approaching the Nov 2025 DCL.\n\n" +
         "No directional bias implied. Marked for historical comparison\n" +
         "with the Oct 2026 TOKEN2049 event.")
    array.push(RC_S,   timestamp(2026, 10,  1, 0, 0))
    array.push(RC_E,   timestamp(2026, 10,  5, 23, 59))
    array.push(RC_LBL, "Oct3 T-Sq?")
    array.push(RC_TIP,
         "Oct 1-5 2026 -- Gann/Astro Watch Window\n" +
         "Focus: October 3, 2026\n" +
         "Olga Morales identifies a Mars-Mercury-Pluto T-square aligned with her BTC chart.\n" +
         "She explicitly states it could mark either a HIGH or a LOW.\n\n" +
         "This is a timing flag, NOT a directional signal.\n\n" +
         "Bullish read requires: sweep/reclaim or breakout/retest on confirmed 4H/6H candles,\n" +
         "  with supporting ETH/BTC ratio and broad alt market confirmation.\n\n" +
         "Bearish read requires: failed breakout or support loss, plus risk-off confirmation\n" +
         "  (e.g. rising USDT.D, equity weakness, risk-off macro flow).\n\n" +
         "Context: Venus Rx starts Oct 3. Combined astro density is notable.\n" +
         "No automated cross-market check -- use this checklist manually.")
    // â”€ Oct 7-11 2026: TOKEN2049 + Singapore F1 â”€
    array.push(RC_S,   timestamp(2026, 10,  7, 0, 0))
    array.push(RC_E,   timestamp(2026, 10, 11, 23, 59))
    array.push(RC_LBL, "TOKEN2049+F1")
    array.push(RC_TIP,
         "Oct 7-11 2026 -- Event Liquidity Watch\n" +
         "TOKEN2049 Singapore: Oct 7-8 (major crypto conference)\n" +
         "Singapore Grand Prix (F1): Oct 9-11\n\n" +
         "Watch for: sustained breakout with volume confirmation, OR\n" +
         "  Wyckoff upthrust and rejection pattern (UTAD -- Up-Thrust After Distribution).\n\n" +
         "Event-driven liquidity events can produce sharp moves in both directions.\n" +
         "Confirmation requires completed 4H or 6H candle closes, not intrabar wicks.\n\n" +
         "No directional bias. Observe and react; do not predict.")
    // â”€ Nov 3 2026: Midterm election watch â”€
    array.push(RC_S,   timestamp(2026, 11,  3, 0, 0))
    array.push(RC_E,   timestamp(2026, 11,  3, 23, 59))
    array.push(RC_LBL, "Election Watch")
    array.push(RC_TIP,
         "November 3, 2026 -- US Midterm Election Day\n\n" +
         "Historical note: crypto has shown macro sensitivity around US elections,\n" +
         "but the direction and timing of any reaction are not reliable in advance.\n\n" +
         "This date overlaps the projected 4-year cycle low zone (~Nov 20 2026)\n" +
         "and the Mercury Rx window (Oct 24 - Nov 13 2026).\n\n" +
         "Watch for: volatility expansion, trend continuation or reversal.\n" +
         "No automated signal here -- watch price structure around this date.\n\n" +
         "Context: Fed, macro risk sentiment, and crypto regulatory landscape all matter.\n" +
         "This is a calendar reminder, not a trade setup.")

    // -- Oct 24-25 2026: Mercury Rx Station (stations retrograde)
    array.push(RC_S,   timestamp(2026, 10, 24, 0, 0))
    array.push(RC_E,   timestamp(2026, 10, 25, 23, 59))
    array.push(RC_LBL, "MRx Start")
    array.push(RC_TIP,
         "Oct 24-25 2026 -- Mercury Stations Retrograde\n" +
         "Mercury begins retrograde in Scorpio. Overlaps active Venus Rx.\n\n" +
         "Historical tendency: Mercury Rx in Scorpio correlates with\n" +
         "information reversals, contract delays, and risk-off sentiment.\n\n" +
         "Combined with Venus Rx: double retrograde period (Oct 24 - Nov 13).\n" +
         "Watch for: failed breakouts, sudden reversals on low-conviction moves.\n\n" +
         "No directional signal -- calendar flag only. Price confirmation required.")

    // -- Nov 13 2026: Venus Rx + Mercury Rx both end (double direct station)
    array.push(RC_S,   timestamp(2026, 11, 13, 0, 0))
    array.push(RC_E,   timestamp(2026, 11, 14, 23, 59))
    array.push(RC_LBL, "VRx+MRx End")
    array.push(RC_TIP,
         "Nov 13-14 2026 -- Double Direct Station\n" +
         "Both Venus and Mercury station direct within days of each other.\n\n" +
         "Station-direct days can see volatility as momentum resumes.\n" +
         "Watch for: trend clarification after weeks of chop.\n\n" +
         "Context: Venus Rx ends Nov 13. Mercury Rx ends ~Nov 13.\n" +
         "If BTC held structure through the double-Rx, watch for follow-through.\n\n" +
         "No directional signal -- calendar flag only.")

    // -- Dec 21 2026: Winter Solstice + Saturn-Neptune approaching conjunction
    array.push(RC_S,   timestamp(2026, 12, 20, 0, 0))
    array.push(RC_E,   timestamp(2026, 12, 22, 23, 59))
    array.push(RC_LBL, "Solstice")
    array.push(RC_TIP,
         "Dec 20-22 2026 -- Winter Solstice\n" +
         "Solstice dates mark Gann cycle turning points.\n\n" +
         "Context: Mars is retrograde. Saturn-Neptune conjunction forming in 2027.\n" +
         "Astro density is elevated in this window.\n\n" +
         "Gann: Dec 21-22 is a recurring seasonal inflection window.\n" +
         "No directional signal -- calendar flag only.")

    // -- Feb 6 2027: Annular Solar Eclipse (Aquarius)
    array.push(RC_S,   timestamp(2027,  2,  5, 0, 0))
    array.push(RC_E,   timestamp(2027,  2,  7, 23, 59))
    array.push(RC_LBL, "Solar Eclipse")
    array.push(RC_TIP,
         "Feb 5-7 2027 -- Annular Solar Eclipse (Aquarius)\n" +
         "Solar eclipses mark major cycle inflection points.\n" +
         "This eclipse falls in Aquarius -- historically linked to tech/crypto themes.\n\n" +
         "Context: Mars is still retrograde through Feb 23. Combined eclipse + Mars Rx\n" +
         "creates elevated astro density. Watch price structure carefully.\n\n" +
         "Solar eclipses can mark either highs or lows -- price leads.\n" +
         "No directional signal -- calendar flag only. Confirm with 4H structure.")

    // -- Feb 23 2027: Mars Stations Direct
    array.push(RC_S,   timestamp(2027,  2, 22, 0, 0))
    array.push(RC_E,   timestamp(2027,  2, 24, 23, 59))
    array.push(RC_LBL, "Mars Direct")
    array.push(RC_TIP,
         "Feb 22-24 2027 -- Mars Stations Direct\n" +
         "Mars resumes direct motion after ~2.5 months retrograde.\n\n" +
         "Station-direct is often a volatility expansion trigger.\n" +
         "If the 4-year cycle low is nearby, Mars Direct could signal a momentum shift.\n\n" +
         "Context: Follows the Feb 6 solar eclipse window.\n" +
         "The week around Mars Direct can see sharp directional moves.\n\n" +
         "No directional signal -- calendar flag only. Price confirmation required.")

    // -- Aug 2 2027: Total Solar Eclipse (Leo) -- high astro density
    array.push(RC_S,   timestamp(2027,  8,  1, 0, 0))
    array.push(RC_E,   timestamp(2027,  8,  3, 23, 59))
    array.push(RC_LBL, "Total Solar")
    array.push(RC_TIP,
         "Aug 1-3 2027 -- Total Solar Eclipse (Leo)\n" +
         "Major total solar eclipse. Totality visible across parts of the Middle East,\n" +
         "North Africa, and Asia. Leo eclipse can coincide with leadership/risk themes.\n\n" +
         "Context: Next major eclipse after the 2027-8 drought zone.\n" +
         "Historically, total solar eclipses in Leo have preceded large market moves.\n\n" +
         "No directional signal -- calendar flag only. Watch price structure leading in.")

// â”€â”€ PIVOT DETECTION â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// DC and WC share same pivot anchor by design (a DCL is also a WCL candidate).
// Signal lag: confirmed i_piv_r bars after the actual price low. Not a real-time signal.
var int  last_low_time = na
var bool is_cycle_low  = false
is_cycle_low := false

float raw_piv = ta.pivotlow(low, i_piv_l, i_piv_r)
if not na(raw_piv)
    int   cand_ts = time[i_piv_r]
    float gap     = na(last_low_time) ? 9999.0 : (cand_ts - last_low_time) / MS_DAY
    if gap >= float(i_min_sep)
        last_low_time := cand_ts
        is_cycle_low  := true

// â”€â”€ CYCLE MATH â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
float days_since  = na(last_low_time) ? float(na) : (time - last_low_time) / MS_DAY
float weeks_since = na(days_since)    ? float(na) : days_since / 7.0
float d4yr        = (time - YR4_TS) / MS_DAY
float pct4yr      = math.round(d4yr / float(i_4y_len) * 1000.0) / 10.0
float left4yr     = math.max(0.0, float(i_4y_len) - d4yr)
bool  late4yr     = d4yr >= float(i_4y_len) * 0.80
bool  bot4yr      = d4yr >= float(i_4y_len) * 0.95

bool in_dc      = not na(days_since) and days_since >= float(i_dc_min) and days_since <= DC_HI_F
bool in_wc      = not na(days_since) and days_since >= WC_LO_F and days_since <= WC_HI_F
bool in_both    = in_dc and in_wc
bool on_lunar   = f_on_eclipse(LUNAR)
bool on_solar   = f_on_eclipse(SOLAR)
bool on_solar_a = f_on_eclipse(SOLAR_A)
bool on_partial = f_on_eclipse(PARTIAL)
bool in_wa      = f_in_wa(LUNAR, float(i_wa_before), float(i_wa_after))
bool conv       = (in_dc or in_wc) and in_wa
bool in_drought = i_show_drought and time >= DROUGHT_S and time <= DROUGHT_E

// ── STAGE 1: EARLY DCL REVERSAL ENGINE ──────────────────────────────────────
// Fast 2-bar pivot detection inside the cycle timing window (in_dc, in_wc, or in_wa)
// Gives an early alert ~2 bars after the local low, before formal 10-bar DCL confirmation.
float early_raw_piv = ta.pivotlow(low, i_early_piv_l, i_early_piv_r)
bool  early_window_eligible = in_dc or in_wc or in_wa

var bool  early_dcl_active = false
var float early_dcl_low    = na
var int   early_dcl_time   = na
bool      early_dcl_fired  = false

// Formal DCL confirmed (Stage 2) -> reset early state
if is_cycle_low
    early_dcl_active := false
    early_dcl_low    := na

// If price closes below previous early low, invalidate probe so a new one can form
if early_dcl_active and not na(early_dcl_low) and close < early_dcl_low
    early_dcl_active := false
    early_dcl_low    := na

if i_show_early_dcl and not na(early_raw_piv) and early_window_eligible and not early_dcl_active
    bool bull_candle = close > open or close > close[1]
    if bull_candle
        early_dcl_fired  := true
        early_dcl_active := true
        early_dcl_low    := early_raw_piv
        early_dcl_time   := time[i_early_piv_r]

// â”€â”€ CAUTION SCORE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
int  caution_score  = i_show_caution ? f_caution_score() : 0
bool caution_active = caution_score >= i_caution_lo
bool caution_high   = caution_score >= i_caution_hi
bool caution_open   = caution_active and not caution_active[1]
bool caution_close  = not caution_active and caution_active[1]
bool caution_escalate = caution_high and not caution_high[1]

// Per-category active flags (one per event type, for individual alerts)
// Fires on the first bar the window becomes active -- edge-detect with [1] in alertcondition
bool cat1_on = false  // Mercury Rx
bool cat2_on = false  // Venus Rx
bool cat3_on = false  // Mars Rx
bool cat4_on = false  // Mars-Saturn Conjunction
bool cat5_on = false  // Mars-Saturn Square
bool cat6_on = false  // Saturn Station-Direct
bool cat7_on = false  // Uranus Station-Direct
bool cat8_on = false  // Partial Lunar Eclipse
if i_show_caution
    int _nc = array.size(CAU_S)
    for _i = 0 to _nc - 1
        if time >= array.get(CAU_S, _i) and time <= array.get(CAU_E, _i)
            int _c = array.get(CAU_CAT, _i)
            if _c == 1
                cat1_on := true
            else if _c == 2
                cat2_on := true
            else if _c == 3
                cat3_on := true
            else if _c == 4
                cat4_on := true
            else if _c == 5
                cat5_on := true
            else if _c == 6
                cat6_on := true
            else if _c == 7
                cat7_on := true
            else if _c == 8
                cat8_on := true

// â”€â”€ PRICE CONFIRMATION STATE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// 4 states: 0=BULL_INTACT  1=CAUTION_WATCH  2=CONFIRMED_WEAK  3=INVALIDATED
// Calendar date alone does NOT change price state. Price must confirm.
float ma_fast   = ta.sma(close, i_ma_fast)
float ma_slow   = ta.sma(close, i_ma_slow)
float swing_lo  = ta.lowest(low, i_swing_len)

var int recovery_count = 0
recovery_count := close > ma_fast ? recovery_count + 1 : 0
bool recovering       = recovery_count >= i_recovery_bars
bool price_above_fast = close > ma_fast
bool price_above_slow = close > ma_slow
bool golden_cross     = ma_fast > ma_slow
bool swing_lo_broken  = close < swing_lo[1]

int price_state = 0
if price_above_fast and price_above_slow and golden_cross
    price_state := 0  // BULL_INTACT
else if caution_active and (not price_above_fast or swing_lo_broken)
    price_state := 1  // CAUTION_WATCH
else if not price_above_fast and not golden_cross
    price_state := 2  // CONFIRMED_WEAK
else
    price_state := 0

string price_state_str = ""
color  price_state_cl  = C_INFO
if price_state == 0
    price_state_str := "BULL INTACT"
    price_state_cl  := C_BUY
else if price_state == 1
    price_state_str := "CAUTION WATCH  (astro + price)"
    price_state_cl  := C_WATCH
else
    price_state_str := "CONFIRMED WEAK  (price leads)"
    price_state_cl  := C_SELL

bool price_state_weakening = price_state >= 2 and not (price_state[1] >= 2)
bool price_state_recovering = recovering and not recovering[1]

// ── RISK CALENDAR PER-BAR STATE ───────────────────────────────────────────────
// Check if current bar falls inside any RC window (for bgcolor + alert edge)
bool rc_active = false
int  rc_active_idx = -1   // index of the matching RC event (-1 = none)
if i_show_rc
    int _nrc = array.size(RC_S)
    for _ri = 0 to _nrc - 1
        if time >= array.get(RC_S, _ri) and time <= array.get(RC_E, _ri)
            rc_active    := true
            rc_active_idx := _ri
            break
bool rc_open = rc_active and not rc_active[1]  // rising edge for alert

// ── DYNAMIC HIGHLIGHT & TAPERING MATH ──────────────────────────────────────────
// Red Caution Dynamic Intensity:
// Continuous orb sum weights each active window by proximity to its peak center.
// Low caution / boundary easing = transparent red (~88), peak storm/double Rx = deep vivid red (~45).
float cau_orb_sum = i_show_caution ? f_dynamic_caution_orb() : 0.0
float cau_norm    = math.min(1.0, math.max(0.0, (cau_orb_sum - 0.25) / 3.75))
int   cau_transp  = int(math.round(88.0 - cau_norm * 43.0))
color DYN_CAUTION = cau_orb_sum >= 2.5 ? color.new(#D50000, cau_transp) : color.new(#B71C1C, cau_transp)

// Green Cycle / Confluence Dynamic Intensity:
// Peaks at the center of the Daily Cycle low window (day 28) and near eclipse dates.
// Eases in at window opening and tapers out smoothly as the cycle advances.
float dc_mid  = float(i_dc_avg_len)
float dc_hw   = math.max(8.0, float(i_dc_avg_len) - float(i_dc_min))
float dc_dist = math.abs(days_since - dc_mid)
float dc_prox = not na(days_since) ? math.max(0.20, 1.0 - math.min(1.0, dc_dist / dc_hw) * 0.80) : 0.0
float wa_prox = in_wa ? f_wa_prox(LUNAR, float(i_wa_before), float(i_wa_after)) : 0.0

float green_score = 0.0
if conv
    // Convergence: cycle low window AND eclipse accumulation window both open
    green_score := 1.8 + (in_both ? 0.6 : 0.0) + dc_prox * 0.9 + wa_prox * 0.5
else if in_both
    // Dual cycle: DC and WC both open
    green_score := 1.3 + dc_prox * 0.7
else if in_dc
    // Daily cycle low window
    green_score := 0.7 + dc_prox * 0.6
else if in_wc
    // Weekly cycle low window
    green_score := 0.8
else if in_wa
    // Standalone eclipse window
    green_score := 0.5 + wa_prox * 0.5

float grn_norm   = math.min(1.0, math.max(0.0, (green_score - 0.5) / 3.0))
int   grn_transp = int(math.round(86.0 - grn_norm * 38.0))
color DYN_GREEN  = green_score >= 1.8 ? color.new(#00E676, grn_transp) : color.new(#1B5E20, grn_transp)

// ── UNIFIED BACKGROUND COLOR (mutually exclusive, priority ranked) ────────────
// Priority (high to low): CAUTION_HIGH > CONVERGENCE > CAUTION_LOW > CYCLE > RISK_CALENDAR
// Smoothly tapers off to transparent (color(na)) as conditions ease up.
color active_bg = color(na)
if i_show_caution and caution_high
    active_bg := i_dynamic_bg ? DYN_CAUTION : BG_CAUTION_HI
else if i_show_wa and conv
    active_bg := i_dynamic_bg ? DYN_GREEN : BG_CONV
else if i_show_caution and caution_active
    active_bg := i_dynamic_bg ? DYN_CAUTION : BG_CAUTION_LO
else if (i_show_dcbg and in_dc) or (i_show_wcbg and in_wc) or (i_show_wa and in_wa)
    active_bg := i_dynamic_bg ? DYN_GREEN : BG_CYCLE
else if i_show_rc and rc_active
    active_bg := BG_RC

bgcolor(active_bg, title="Dynamic Background Highlight (Aspect Intensity & Tapering)")

// â”€â”€ CYCLE LOW MARKERS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// ── STAGE 1: EARLY DCL MARKER ────────────────────────────────────────────────
plotshape(i_show_early_dcl and early_dcl_fired,
     style=shape.diamond, location=location.belowbar,
     color=color.new(#00E676, 0), size=size.small, offset=-i_early_piv_r, title="Early DCL Diamond")

if i_show_early_dcl and early_dcl_fired
    float el_base = early_dcl_low
    string el_date = str.tostring(year(early_dcl_time)) + "-" + str.tostring(month(early_dcl_time)) + "-" + str.tostring(dayofmonth(early_dcl_time))
    label.new(bar_index - i_early_piv_r, el_base * 0.988,
         text="EARLY\nDCL?\n" + el_date,
         style=label.style_label_up,
         color=color.new(#003314, 15), textcolor=color.new(#00E676, 0), size=size.tiny,
         tooltip="STAGE 1: Early DCL Watch\n" +
                 "Detected " + str.tostring(i_early_piv_r) + " bars after low: $" + str.tostring(early_dcl_low, "#,###") + "\n" +
                 "Date of low: " + el_date + "\n" +
                 "Cycle accumulation window is OPEN.\n\n" +
                 "Formal DCL confirmation (Stage 2) requires " + str.tostring(i_piv_r) + " bars without breaking this low.\n" +
                 "Invalidated if price closes below $" + str.tostring(early_dcl_low, "#,###") + ".")

plotshape(i_show_dcl and is_cycle_low,
     style=shape.triangleup, location=location.belowbar,
     color=C_BUY, size=size.normal, offset=-i_piv_r, title="DCL Triangle")

if i_show_dcl and is_cycle_low
    float base    = low[i_piv_r]
    float rng     = (high[i_piv_r] - low[i_piv_r]) / low[i_piv_r]
    float lbl_y   = base * (1.0 - math.max(0.015, rng * 0.5))
    string date_s = str.tostring(year(last_low_time)) + "-" + str.tostring(month(last_low_time)) + "-" + str.tostring(dayofmonth(last_low_time))
    string dcl_pfx = conv ? "CONVERGENCE ACTIVE\n" : in_wa ? "WA Eclipse Window\n" : ""
    string tip    = dcl_pfx + "DCL: " + date_s + "\nNOTE: signal available ~" + str.tostring(i_piv_r) + " bars after actual low (pivot-right lag)"
    label.new(bar_index - i_piv_r, lbl_y,
         text="DCL\n" + date_s,
         style=label.style_label_up,
         color=LBG_BUY, textcolor=C_BUY, size=size.small, tooltip=tip)

// â”€â”€ ECLIPSE MARKERS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if i_show_emkr and on_lunar
    string date_s = str.tostring(year(time)) + "-" + str.tostring(month(time)) + "-" + str.tostring(dayofmonth(time))
    label.new(bar_index, high * 1.005,
         text="BLOOD\nMOON",
         style=label.style_label_down,
         color=LBG_SELL, textcolor=C_SELL, size=size.small,
         tooltip="Total Lunar Eclipse (Blood Moon): " + date_s +
                 "\nWA: bottom watch window opens\nWatch for DCL within " +
                 str.tostring(i_wa_after) + " days")

if i_show_emkr and on_solar
    string date_s = str.tostring(year(time)) + "-" + str.tostring(month(time)) + "-" + str.tostring(dayofmonth(time))
    label.new(bar_index, high * 1.005,
         text="TOTAL\nSOLAR",
         style=label.style_label_down,
         color=LBG_SOLAR, textcolor=C_SOLAR, size=size.small,
         tooltip="Total Solar Eclipse: " + date_s +
                 "\nWA framework: bullish catalyst (unvalidated)\nOpposing view: near-term volatility also common")

if i_show_emkr and on_solar_a
    string date_s = str.tostring(year(time)) + "-" + str.tostring(month(time)) + "-" + str.tostring(dayofmonth(time))
    label.new(bar_index, high * 1.005,
         text="ANNULAR\nSOLAR",
         style=label.style_label_down,
         color=LBG_SOLAR, textcolor=color.new(C_SOLAR, 35), size=size.tiny,
         tooltip="Annular Solar Eclipse: " + date_s +
                 "\nAnnular -- ring of fire, NOT total\nWeaker WA signal than total solar eclipse")

if i_show_emkr and on_partial
    string date_s = str.tostring(year(time)) + "-" + str.tostring(month(time)) + "-" + str.tostring(dayofmonth(time))
    label.new(bar_index, high * 1.008,
         text="PART\nLUN",
         style=label.style_label_down,
         color=LBG_INFO, textcolor=C_INFO, size=size.tiny,
         tooltip="Partial/Penumbral Lunar Eclipse: " + date_s +
                 "\nInformational. Umbral partials get minor caution weight.\nPenumbrals are not weighted.")

// â”€â”€ CAUTION SCORE ON-BAR LABEL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if i_show_cau_lbl and caution_active
    color cau_c = caution_high ? C_SELL : C_CAUTION
    color cau_b = caution_high ? LBG_SELL : LBG_CAUT
    label.new(bar_index, low * 0.992,
         text="CAU\n" + str.tostring(caution_score),
         style=label.style_label_up,
         color=cau_b, textcolor=cau_c, size=size.tiny,
         tooltip="Experimental Caution Score: " + str.tostring(caution_score) +
                 "\nLo threshold: " + str.tostring(i_caution_lo) +
                 "  Hi threshold: " + str.tostring(i_caution_hi) +
                 "\nScore is NOT a validated trade signal." +
                 "\nPrice confirmation required before acting on caution windows." +
                 "\nA calendar date alone cannot declare a bear market or trigger a sell.")

// â”€â”€ FUTURE MARKERS + TABLE (barstate.islast only) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if barstate.islast

    // Bull scenario box + bear scenario box
    if i_show_bull
        box.new(
             left=timestamp(2026, 11, 1, 0, 0), top=9999999.0,
             right=timestamp(2028, 12, 31, 0, 0), bottom=0.0,
             xloc=xloc.bar_time, bgcolor=BG_BULL,
             border_color=color.new(C_BUY, 40), border_width=2,
             border_style=line.style_solid)

        box.new(
             left=timestamp(2029, 1, 1, 0, 0), top=9999999.0,
             right=timestamp(2029, 12, 31, 0, 0), bottom=0.0,
             xloc=xloc.bar_time, bgcolor=BG_BEAR,
             border_color=color.new(C_SELL, 40), border_width=2,
             border_style=line.style_solid)


    // -- PROJECTED BULL PHASE BACKDROP (green zones) ---------------------
    // Green boxes sit behind the red caution bands. The red overlays show
    // specific risk periods WITHIN the broader bull backdrop.
    if i_show_caution
        // Phase 1: 4YR Bottom + Accumulation Watch (Oct 2026 - Mar 2027)
        box.new(left=timestamp(2026, 10, 15, 0, 0), right=timestamp(2027, 3, 28, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#00C853, 88), border_color=color.new(#00C853, 70), border_width=1)
        label.new(timestamp(2026, 10, 15, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="ACCUM", style=label.style_label_right, size=size.tiny,
                 color=color.new(#00C853, 60), textcolor=color.white,
                 tooltip="PROJECTED Phase 1 -- Accumulation Watch\nOct 2026 - Mar 2027\n\nProjected 4YR cycle low zone. Buy-the-dip window.\nKey risks: Venus Rx Oct-Nov 2026, Mars Rx Jan-Apr 2027.\nGreen = bull backdrop. Red overlays = caution within the phase.\nPrice confirmation required before entering.")

        // Phase 2: Markup (Apr 2027 - Aug 2027)
        box.new(left=timestamp(2027, 3, 28, 0, 0), right=timestamp(2027, 8, 2, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#00C853, 85), border_color=color.new(#00C853, 65), border_width=1)
        label.new(timestamp(2027, 3, 28, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MARKUP", style=label.style_label_right, size=size.tiny,
                 color=color.new(#00C853, 55), textcolor=color.white,
                 tooltip="PROJECTED Phase 2 -- Markup\nApr 2027 - Aug 2027\n\nMars Direct Apr 1 -- momentum expected to resume.\nBull trend phase. Ride with trailing stops.\nPhase ends at Total Solar Eclipse Aug 2 2027 -- watch for acceleration or top signals.")

        // Phase 3: Blow-off / Top Watch (Aug 2027 - Dec 2028)
        box.new(left=timestamp(2027, 8, 2, 0, 0), right=timestamp(2028, 12, 31, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#00C853, 90), border_color=color.new(#00C853, 75), border_width=1)
        label.new(timestamp(2027, 8, 2, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="BLOW-OFF", style=label.style_label_right, size=size.tiny,
                 color=color.new(#00C853, 50), textcolor=color.white,
                 tooltip="PROJECTED Phase 3 -- Blow-off / Top Watch\nAug 2027 - Dec 2028\n\nPost-solar eclipse acceleration phase. Historically volatile.\nMajor caution cluster May-Jun 2028: Venus Rx + Mercury Rx overlapping.\nBlood Moon Dec 2028 -- top watch. Begin scaling out.\nAll targets conditional on bull scenario holding.")

    // -- Retrograde station HIGHLIGHT BANDS ----------------------------------
    // Filled bands show the full retrograde period visually.
    // Mercury Rx = subtle red tint (minor caution, happens 3-4x/year)
    // Venus Rx   = medium red band (money planet, ~18 months apart)
    // Mars Rx    = strongest band  (major ~80-day caution, once per ~26 months)
    if i_show_caution
        int _d = int(MS_DAY)   // one day in milliseconds

        // Mercury Rx periods -- subtle red tint spanning full retrograde window
        box.new(left=timestamp(2026, 10, 24, 0, 0),
                right=timestamp(2026, 11, 13, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 82), border_color=color.new(#D50000, 70), border_width=1)
        label.new(timestamp(2026, 10, 24, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MRx", style=label.style_label_up, size=size.tiny,
                 color=color.new(#D50000, 60), textcolor=color.white,
                 tooltip="Oct 24 - Nov 13 2026 -- Mercury Retrograde\nOverlaps Venus Rx. Watch for failed breakouts and reversals.\nCalendar flag only -- no directional signal.")

        box.new(left=timestamp(2027,  2,  9, 0, 0),
                right=timestamp(2027,  3,  3, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 82), border_color=color.new(#D50000, 70), border_width=1)
        label.new(timestamp(2027,  2,  9, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MRx", style=label.style_label_up, size=size.tiny,
                 color=color.new(#D50000, 60), textcolor=color.white,
                 tooltip="Feb 9 - Mar 3 2027 -- Mercury Retrograde\nOverlaps Mars Rx + Solar Eclipse window. Elevated risk density.\nCalendar flag only -- no directional signal.")

        box.new(left=timestamp(2027,  6, 10, 0, 0),
                right=timestamp(2027,  7,  4, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 82), border_color=color.new(#D50000, 70), border_width=1)
        label.new(timestamp(2027,  6, 10, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MRx", style=label.style_label_up, size=size.tiny,
                 color=color.new(#D50000, 60), textcolor=color.white,
                 tooltip="Jun 10 - Jul 4 2027 -- Mercury Retrograde\nMid-bull phase. Calendar flag only.")

        box.new(left=timestamp(2027, 10,  7, 0, 0),
                right=timestamp(2027, 10, 28, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 82), border_color=color.new(#D50000, 70), border_width=1)
        label.new(timestamp(2027, 10,  7, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MRx", style=label.style_label_up, size=size.tiny,
                 color=color.new(#D50000, 60), textcolor=color.white,
                 tooltip="Oct 7 - Oct 28 2027 -- Mercury Retrograde\nNear Mars-Saturn Sq Dec 2027. Calendar flag only.")

        box.new(left=timestamp(2028,  1, 24, 0, 0),
                right=timestamp(2028,  2, 14, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 82), border_color=color.new(#D50000, 70), border_width=1)
        label.new(timestamp(2028,  1, 24, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MRx", style=label.style_label_up, size=size.tiny,
                 color=color.new(#D50000, 60), textcolor=color.white,
                 tooltip="Jan 24 - Feb 14 2028 -- Mercury Retrograde\nOverlaps Partial Lunar Jan 12 + Uranus sD Feb 12. Calendar flag only.")

        box.new(left=timestamp(2028,  5, 21, 0, 0),
                right=timestamp(2028,  6, 14, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 82), border_color=color.new(#D50000, 70), border_width=1)
        label.new(timestamp(2028,  5, 21, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MRx", style=label.style_label_up, size=size.tiny,
                 color=color.new(#D50000, 60), textcolor=color.white,
                 tooltip="May 21 - Jun 14 2028 -- Mercury Retrograde\nOverlaps Venus Rx. Highest caution density of the cycle. Calendar flag only.")

        box.new(left=timestamp(2028,  9, 19, 0, 0),
                right=timestamp(2028, 10, 11, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 82), border_color=color.new(#D50000, 70), border_width=1)
        label.new(timestamp(2028,  9, 19, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MRx", style=label.style_label_up, size=size.tiny,
                 color=color.new(#D50000, 60), textcolor=color.white,
                 tooltip="Sep 19 - Oct 11 2028 -- Mercury Retrograde\nOverlaps Mars-Saturn Sq Sep 21. Calendar flag only.")

        // Venus Rx periods -- medium red band, more prominent than Mercury
        // Base band has soft easing opacity (78)
        box.new(left=timestamp(2026, 10,  3, 0, 0),
                right=timestamp(2026, 11, 13, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#B71C1C, 78), border_color=color.new(#B71C1C, 60), border_width=1)
        label.new(timestamp(2026, 10,  3, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="VRx", style=label.style_label_up, size=size.small,
                 color=color.new(#B71C1C, 45), textcolor=color.white,
                 tooltip="Oct 3 - Nov 13 2026 -- Venus Retrograde (Scorpio)\nVenus rules money and markets. The 2018 Venus Rx in Scorpio overlapped a sharp Q4 crypto decline.\nMercury also goes Rx Oct 24 -- double retrograde from Oct 24.\nNo directional signal. Price confirmation required.")

        // Peak Double Retrograde Highlight Box: Oct 24 - Nov 13, 2026
        // Prominent deep crimson highlight (transparency 56, border 25) where Venus Rx + Mercury Rx overlap
        box.new(left=timestamp(2026, 10, 24, 0, 0),
                right=timestamp(2026, 11, 13, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 56), border_color=color.new(#D50000, 25), border_width=2)
        label.new(timestamp(2026, 10, 24, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="DOUBLE Rx\nVenus + Mercury\nPEAK CAUTION", style=label.style_label_up, size=size.small,
                 color=color.new(#D50000, 40), textcolor=color.white,
                 tooltip="Oct 24 - Nov 13 2026 -- Double Retrograde (Venus Rx + Mercury Rx overlapping)\nPeak astro caution density in Q4 2026.\nOverlaps the projected 4YR Cycle Low window.\nStrong negative aspect cluster: failed breakouts, erratic liquidity.\nPrice confirmation required before entering.")

        // Base 2028 Venus Rx with soft easing opacity (78)
        box.new(left=timestamp(2028,  5, 10, 0, 0),
                right=timestamp(2028,  6, 22, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#B71C1C, 78), border_color=color.new(#B71C1C, 60), border_width=1)
        label.new(timestamp(2028,  5, 10, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="VRx", style=label.style_label_up, size=size.small,
                 color=color.new(#B71C1C, 45), textcolor=color.white,
                 tooltip="May 10 - Jun 22 2028 -- Venus Retrograde\nOverlaps Mercury Rx May 21. Mars-Saturn Conj Apr 30 also nearby.\nHighest combined caution density of the projected bull cycle.\nNo directional signal. Price confirmation required.")

        // Peak Double Retrograde Overlay: May 21 - Jun 14, 2028
        // Prominent deep crimson highlight where Venus Rx and Mercury Rx overlap
        box.new(left=timestamp(2028,  5, 21, 0, 0),
                right=timestamp(2028,  6, 14, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#D50000, 52), border_color=color.new(#D50000, 20), border_width=2)
        label.new(timestamp(2028,  5, 21, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="DOUBLE Rx\nVenus + Mercury\n(2028 Peak)", style=label.style_label_up, size=size.small,
                 color=color.new(#D50000, 35), textcolor=color.white,
                 tooltip="May 21 - Jun 14 2028 -- Double Retrograde (Venus Rx + Mercury Rx 2028)\nCombined caution density during late bull phase.\nMars-Saturn Conj Apr 30 nearby.")

        // Mars Rx full period -- base band with soft easing opacity (78)
        box.new(left=timestamp(2027,  1, 10, 0, 0),
                right=timestamp(2027,  4,  1, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#7B0000, 78), border_color=color.new(#B71C1C, 55), border_width=1)
        label.new(timestamp(2027,  1, 10, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="Mars Rx", style=label.style_label_up, size=size.small,
                 color=color.new(#7B0000, 45), textcolor=color.white,
                 tooltip="Jan 10 - Apr 1 2027 -- Mars Retrograde (Leo/Cancer, ~80 days)\nMars Rx = most significant planetary caution period.\nMars rules action, momentum, aggression. Rx = stalls, reversals, failed breakouts.\nOverlaps: Solar Eclipse Feb 6, Mercury Rx Feb 9-Mar 3, Uranus sD Feb 8.\nJan-Feb 2027 has the highest astro risk density of the near-term window.\nBull scenario can still proceed through Mars Rx -- watch for sharp corrections.\nPrice must confirm before treating as a correction signal.")

        // Mars Rx Peak Risk Cluster Box: Feb 1 - Feb 25, 2027
        // Prominent deep highlight where Mars Rx + Solar Eclipse + Uranus sD + Mercury Rx converge
        box.new(left=timestamp(2027,  2,  1, 0, 0),
                right=timestamp(2027,  2, 25, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#7B0000, 50), border_color=color.new(#D50000, 20), border_width=2)
        label.new(timestamp(2027,  2,  1, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="MARS Rx PEAK\nEclipse + MRx + Uranus", style=label.style_label_up, size=size.small,
                 color=color.new(#7B0000, 35), textcolor=color.white,
                 tooltip="Feb 1 - Feb 25 2027 -- Mars Rx Peak Risk Cluster\nMultiple simultaneous events: Solar Eclipse Feb 6, Uranus sD Feb 8, Mercury Rx Feb 9 - Mar 3 inside Mars Rx.\nHighest astrological caution density of early 2027.\nTapers off into March as planets station direct.")

        // Phase dividers -- thin highlight bands (no dotted lines)
        // Markup phase start: Mars Direct Apr 1 2027
        box.new(left=timestamp(2027, 3, 28, 0, 0), right=timestamp(2027, 4, 5, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#00C853, 80), border_color=color.new(#00C853, 50), border_width=1)
        label.new(timestamp(2027, 3, 28, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="", style=label.style_label_up, size=size.tiny,
                 color=color.new(#00C853, 80), textcolor=color.white,
                 tooltip="Mars Direct ~ Apr 1 2027\nEnd of Mars Rx. Mars resumes forward motion -- caution window closes.\nWatch for momentum resumption. Phase divider: Accum > Markup.")

        // Total Solar Eclipse Aug 2 2027 -- gold highlight band
        box.new(left=timestamp(2027, 7, 30, 0, 0), right=timestamp(2027, 8, 5, 0, 0),
                top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                bgcolor=color.new(#FFC400, 72), border_color=color.new(#FFC400, 45), border_width=1)
        label.new(timestamp(2027, 7, 30, 0, 0), low * 0.82, xloc=xloc.bar_time,
                 text="", style=label.style_label_up, size=size.tiny,
                 color=color.new(#FFC400, 72), textcolor=color.white,
                 tooltip="Total Solar Eclipse -- Aug 2 2027\nSaros 136. WA (Wickoff Accumulation) eclipse event.\nHistorically: Total solar eclipses mark major inflection zones.\nPhase divider: Markup > Blow-off Watch.\nPrice action around this date expected to be decisive.")

        label.new(timestamp(2027, 7, 15, 0, 0), low * 0.82, xloc=xloc.bar_time,
             text="BULL SCENARIO\n~24 MONTHS\nNov 2026 - Dec 2028",
             style=label.style_label_up,
             color=LBG_BUY, textcolor=C_BUY, size=size.large,
             tooltip="PROJECTED Bull Scenario: Nov 2026 - Dec 2028\n" +
                     "CONDITIONAL -- multiple caution windows exist within this period\n\n" +
                     "Phase 1 Accum Watch: Nov 2026 - Mar 2027\n" +
                     "  Key caution: Mars Rx Jan-Apr 2027 overlaps this phase\n" +
                     "  Also: Venus Rx + Mercury Rx near the projected 4yr low (Oct-Nov 2026)\n\n" +
                     "Phase 2 Markup Watch: Mar 2027 - Aug 2027\n" +
                     "  Mars-Saturn Sq Dec 2027 arrives near end of this phase\n\n" +
                     "Phase 3 Blow-off Watch: Aug 2027 - Dec 2028\n" +
                     "  Major 2028 caution cluster: Venus Rx + Mercury Rx May-Jun 2028\n" +
                     "  Mars-Saturn Conj Apr 2028 + Sq Sep 2028\n\n" +
                     "Scenario intact while price holds key MAs.\n" +
                     "Price must confirm before interpreting caution as correction.")

        label.new(timestamp(2029, 6, 15, 0, 0), low * 0.82, xloc=xloc.bar_time,
             text="BEAR SCENARIO\n2x BLOOD MOONS\n2029",
             style=label.style_label_up,
             color=LBG_SELL, textcolor=C_SELL, size=size.normal,
             tooltip="2029: Two total lunar eclipses (Jun 26 + Dec 20)\n" +
                     "Sustained WA bearish pressure scenario\n" +
                     "Scenario timing conditional on 2028 bull resolution")

    // -- DCL PROJECTION WINDOW -----------------------------------------------
    // Projects the NEXT expected DCL window using the last confirmed DCL date.
    // Window = last_low_time + DC_min ... last_low_time + DC_HI_F (max days).
    // Center line = last_low_time + i_dc_avg_len days.
    // Only drawn when center is still in the future. NOT a price prediction.
    if i_show_dcl_proj and not na(last_low_time)
        int   _proj_start  = last_low_time + int(float(i_dc_min)  * MS_DAY)
        int   _proj_center = last_low_time + int(float(i_dc_avg_len) * MS_DAY)
        int   _proj_end    = last_low_time + int(DC_HI_F * MS_DAY)
        bool  _proj_future = _proj_center > time
        bool  _proj_active = time >= _proj_start and time <= _proj_end

        // Only draw if window has not fully passed
        if _proj_end > time
            // Box color: active (we're inside window now) vs upcoming
            color _box_bg    = _proj_active ?
                 color.new(#00BCD4, 75) :   // teal, more opaque = INSIDE window now
                 color.new(#00BCD4, 88)      // teal, more transparent = upcoming
            color _box_bdr   = _proj_active ?
                 color.new(#00BCD4, 30) :
                 color.new(#00BCD4, 50)

            box.new(
                 left=_proj_start, top=9999999.0,
                 right=_proj_end, bottom=0.0,
                 xloc=xloc.bar_time,
                 bgcolor=_box_bg,
                 border_color=_box_bdr, border_width=1,
                 border_style=line.style_solid)

            // Center marker -- thin highlighted band instead of dashed line
            int _center_half = int(MS_DAY) // half-day each side
            box.new(left=_proj_center - _center_half, right=_proj_center + _center_half,
                    top=9999999.0, bottom=0.0, xloc=xloc.bar_time,
                    bgcolor=color.new(#00BCD4, 50), border_color=color.new(#00BCD4, 20), border_width=2)
            label.new(_proj_center - _center_half, low * 0.82, xloc=xloc.bar_time,
                     text="", style=label.style_label_up, size=size.tiny,
                     color=color.new(#00BCD4, 50), textcolor=color.white,
                     tooltip="DCL Expected Center -- " + str.tostring(i_dc_avg_len) + "d after last confirmed DCL\nThis is the median of the historical Daily Cycle length.\nNot a price prediction -- a TIME ZONE. Entry requires price confirmation.")

            // Label at bottom of box
            string _proj_lbl = _proj_active ? "DCL WATCH\n(INSIDE WINDOW)" : "DCL WATCH\n(PROJECTED)"
            string _last_dcl_date = str.tostring(year(last_low_time)) + "-" +
                 str.tostring(month(last_low_time)) + "-" +
                 str.tostring(dayofmonth(last_low_time))

            label.new(_proj_center, low * 0.82, xloc=xloc.bar_time,
                 text=_proj_lbl,
                 style=label.style_label_up,
                 color=color.new(#00BCD4, 50),
                 textcolor=color.white,
                 size=size.small,
                 tooltip="Projected Next DCL Window\n" +
                         "Last confirmed DCL: " + _last_dcl_date + "\n" +
                         "Window start: DCL + " + str.tostring(i_dc_min) + "d\n" +
                         "Window center: DCL + " + str.tostring(i_dc_avg_len) + "d (avg)\n" +
                         "Window end: DCL + " + str.tostring(math.round(DC_HI_F)) + "d (max)\n\n" +
                         "IMPORTANT: This is a TIME window, NOT a price target.\n" +
                         "A DCL is most likely to form somewhere in this zone.\n" +
                         "Price and structure MUST confirm before entering.\n" +
                         "Look for: failed swing low, MA reclaim, volume dry-up.")

    if i_show_proj
        label.new(timestamp(2026, 11, 20, 0, 0), low * 0.75, xloc=xloc.bar_time,
             text="4YR LOW\n~Nov 2026\nACCUM WATCH",
             style=label.style_label_up,
             color=LBG_PROJ, textcolor=C_PROJ, size=size.normal,
             tooltip="Projected 4-Year Cycle Low ~Nov 20 2026 (Nov 21 2022 + 1461 days)\n" +
                     "WATCH: Venus Rx (Oct 3 - Nov 14) active near this date\n" +
                     "WATCH: Mercury Rx (Oct 24 - Nov 13) also active\n" +
                     "Requires DCL confirmation and MA reclaim before acting")

        label.new(timestamp(2027, 2, 15, 0, 0), low * 0.85, xloc=xloc.bar_time,
             text="MARS Rx\nJan-Apr 2027\nCAUTION",
             style=label.style_label_up,
             color=LBG_CAUT, textcolor=C_CAUTION, size=size.small,
             tooltip="Mars Retrograde Jan 10 - Apr 1 2027 (Virgo/Leo)\n" +
                     "Largest caution window in the early bull phase.\n" +
                     "Overlaps: Mercury Rx Feb-Mar 2027, Uranus sD Feb 2027\n" +
                     "Bull scenario can still proceed -- watch for sharp corrections\n" +
                     "Price state determines whether caution = correction or consolidation")

        label.new(timestamp(2027, 8, 2, 0, 0), high * 1.10, xloc=xloc.bar_time,
             text="TOTAL SOLAR\nAug 2027\nACCEL WATCH",
             style=label.style_label_down,
             color=LBG_SOLAR, textcolor=C_SOLAR, size=size.normal,
             tooltip="Total Solar Eclipse Aug 2 2027 (longest of century: 6min 23sec)\n" +
                     "WA Theory: bullish catalyst -- acceleration watch\n" +
                     "Conditional on price remaining above key MAs at this date\n" +
                     "No major caution events directly overlap this specific week")

        label.new(timestamp(2028, 5, 16, 0, 0), high * 1.05, xloc=xloc.bar_time,
             text="DBL Rx\nMay-Jun 2028\nCAUTION",
             style=label.style_label_down,
             color=LBG_CAUT, textcolor=C_CAUTION, size=size.small,
             tooltip="Double Retrograde Caution Cluster: May-Jun 2028\n" +
                     "Venus Rx: May 10 - Jun 22 2028\n" +
                     "Mercury Rx: May 21 - Jun 14 2028 (overlapping)\n" +
                     "Mars-Saturn Conjunction: Apr 30 2028 (also nearby)\n" +
                     "Highest combined caution score window of the projected bull phase\n" +
                     "Price structure must confirm any directional bias")

        label.new(timestamp(2028, 7, 22, 0, 0), high * 1.10, xloc=xloc.bar_time,
             text="TOTAL SOLAR\nJul 2028\nREDUCE RISK",
             style=label.style_label_down,
             color=LBG_SOLAR, textcolor=C_SOLAR, size=size.small,
             tooltip="Total Solar Eclipse Jul 22 2028 (Australia)\n" +
                     "Late bull phase -- begin reducing risk\n" +
                     "Near Partial Lunar Eclipse Jul 6 2028\n" +
                     "~5 months before projected Dec blood moon")

        label.new(timestamp(2028, 9, 21, 0, 0), high * 1.14, xloc=xloc.bar_time,
             text="Mars-Sat SQ\nSep 2028",
             style=label.style_label_down,
             color=LBG_CAUT, textcolor=C_CAUTION, size=size.tiny,
             tooltip="Mars-Saturn Square Sep 21 2028\n" +
                     "Overlaps Mercury Rx Sep-Oct 2028\n" +
                     "Late bull caution cluster -- tighten stops")

        label.new(timestamp(2028, 12, 31, 0, 0), high * 1.05, xloc=xloc.bar_time,
             text="BLOOD MOON\nDec 2028\nTOP WATCH",
             style=label.style_label_down,
             color=LBG_SELL, textcolor=C_SELL, size=size.normal,
             tooltip="Blood Moon Dec 31 2028 -- first since Mar 2026 (33-month drought ends)\n" +
                     "WA Theory: TOP WATCH -- scale out of longs IF price confirms\n" +
                     "This is a watch signal, NOT an automatic sell\n" +
                     "If price is still constructive on Dec 31 2028, reassess\n" +
                     "Invalidation of bull scenario requires price-confirmed weakness")

        label.new(timestamp(2029, 6, 26, 0, 0), high * 1.05, xloc=xloc.bar_time,
             text="BLOOD MOON\nJun 2029\nBEAR WATCH",
             style=label.style_label_down,
             color=LBG_SELL, textcolor=C_SELL, size=size.small,
             tooltip="Blood Moon Jun 26 2029\n" +
                     "WA: bear confirmation watch if Dec 2028 scenario played out\n" +
                     "If Dec 2028 was NOT the top, reassess bull scenario")

        label.new(timestamp(2029, 12, 20, 0, 0), high * 1.05, xloc=xloc.bar_time,
             text="BLOOD MOON\nDec 2029\nBEAR WATCH",
             style=label.style_label_down,
             color=LBG_SELL, textcolor=C_SELL, size=size.small,
             tooltip="Blood Moon Dec 20 2029 (2 of 2 in 2029)")

        label.new(timestamp(2030, 11, 20, 0, 0), low * 0.80, xloc=xloc.bar_time,
             text="4YR LOW\n~Nov 2030\nNEXT ACCUM",
             style=label.style_label_up,
             color=LBG_PROJ, textcolor=C_PROJ, size=size.small,
             tooltip="Next 4-Year Cycle Low ~Nov 2030\nWatch for accumulation if 2028-2029 scenario played out")

    // â”€â”€ RISK CALENDAR FUTURE LABELS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Only draw for events that are in the future AND within i_rc_days from now.
    // Labels created only on barstate.islast -- no per-bar accumulation.
    if i_show_rc and i_show_rc_lbl
        int _nrc2 = array.size(RC_S)
        for _ri2 = 0 to _nrc2 - 1
            int _rcs = array.get(RC_S, _ri2)
            int _rce = array.get(RC_E, _ri2)
            int _mid = _rcs + (_rce - _rcs) / 2
            float _days_away = (_rcs - time) / MS_DAY
            // Show: future events within the configured window, OR currently active events
            bool _in_window  = _days_away >= -1.0 and _days_away <= float(i_rc_days)
            bool _is_active  = time >= _rcs and time <= _rce
            if _in_window or _is_active
                label.new(_mid, low * 0.96, xloc=xloc.bar_time,
                     text=array.get(RC_LBL, _ri2),
                     style=label.style_label_up,
                     color=LBG_RC, textcolor=C_RC, size=size.small,
                     tooltip=array.get(RC_TIP, _ri2))

    // -- DASHBOARD TABLE (8-row actionable layout) ---------------------------
    if i_show_tbl
        table t = table.new(
             i_tbl_pos == "bottom_left" ? position.bottom_left :
             i_tbl_pos == "top_right"   ? position.top_right   :
             i_tbl_pos == "top_left"    ? position.top_left    :
                                          position.bottom_right,
             2, 8,
             bgcolor      = color.new(#0A0A10, 6),
             border_color = color.new(#1E1E2E, 0), border_width=1,
             frame_color  = color.new(#2E2E4E, 0), frame_width=2)

        // -- ROW 0: Header ---------------------------------------------------
        string _tf_str = timeframe.isdaily ? "1D" : timeframe.isweekly ? "1W" :
             timeframe.period == "120" ? "2H" : timeframe.period == "240" ? "4H" :
             timeframe.period
        table.cell(t, 0, 0, "B4S CYCLE + ECLIPSE",
             text_color=color.white, text_size=size.small, text_halign=text.align_left,
             bgcolor=color.new(#0D0D20, 0))
        table.cell(t, 1, 0, "BTCUSD  " + _tf_str,
             text_color=C_INFO, text_size=size.small, text_halign=text.align_right,
             bgcolor=color.new(#0D0D20, 0))

        // -- ROW 1: ACTION (the single most important call) ------------------
        // Priority: AVOID (high caution + price weak) > CAUTION > WATCH > HOLD > BUY ZONE
        int    sig    = (in_dc ? 1 : 0) + (in_wc ? 1 : 0) + (in_wa ? 1 : 0) + (bot4yr ? 1 : 0)
        string _action_str = ""
        color  _action_cl  = C_INFO
        color  _action_bg  = color.new(#0D0D12, 0)
        if caution_high and price_state >= 2
            _action_str := "AVOID"
            _action_cl  := C_SELL
            _action_bg  := color.new(#2D0000, 5)
        else if caution_high
            _action_str := "HIGH CAUTION -- HOLD"
            _action_cl  := color.new(#FF4444, 0)
            _action_bg  := color.new(#200000, 5)
        else if caution_active and price_state >= 2
            _action_str := "CAUTION -- REDUCE"
            _action_cl  := C_CAUTION
            _action_bg  := color.new(#1A0800, 5)
        else if caution_active
            _action_str := "CAUTION -- TIGHTEN EXITS"
            _action_cl  := C_CAUTION
            _action_bg  := color.new(#1A0800, 5)
        else if sig >= 2 and in_dc
            _action_str := "BUY ZONE  -- CONFLUENCE"
            _action_cl  := C_BUY
            _action_bg  := color.new(#003300, 5)
        else if in_dc
            _action_str := "WATCH  -- DCL WINDOW OPEN"
            _action_cl  := C_WATCH
            _action_bg  := color.new(#001A00, 5)
        else if price_state >= 2
            _action_str := "WAIT  -- PRICE WEAK"
            _action_cl  := color.orange
            _action_bg  := color.new(#1A0D00, 5)
        else
            _action_str := "HOLD  -- NO WINDOW YET"
            _action_cl  := C_INFO
            _action_bg  := color.new(#0D0D12, 0)
        table.cell(t, 0, 1, "ACTION",
             text_color=_action_cl, text_size=size.normal, text_halign=text.align_left,
             bgcolor=_action_bg)
        table.cell(t, 1, 1, _action_str,
             text_color=_action_cl, text_size=size.normal, text_halign=text.align_right,
             bgcolor=_action_bg)

        // -- ROW 2: Confluence (how many cycle windows + eclipse are open) ----
        // Only count 3 (DC + WC + Eclipse) for the score -- 4YR is context not timing
        int    _conf3     = (in_dc ? 1 : 0) + (in_wc ? 1 : 0) + (in_wa ? 1 : 0)
        string _conf_tags = (in_dc ? "DC " : "") + (in_wc ? "WC " : "") + (in_wa ? "Eclipse " : "")
        string _conf_str = ""
        if _conf3 == 0
            _conf_str := "0/3  No cycle window open"
        else if _conf3 == 1
            _conf_str := "1/3  " + _conf_tags + "-- wait for more"
        else if _conf3 == 2
            _conf_str := "2/3  " + _conf_tags + "-- strong setup"
        else
            _conf_str := "3/3  " + _conf_tags + "-- MAX"
        color  _conf_cl   = _conf3 >= 2 ? C_BUY : _conf3 == 1 ? C_WATCH : C_INFO
        table.cell(t, 0, 2, "Confluence",
             text_color=C_INFO, text_size=size.small, text_halign=text.align_left)
        table.cell(t, 1, 2, _conf_str,
             text_color=_conf_cl, text_size=size.small, text_halign=text.align_right,
             bgcolor=_conf3 >= 2 ? color.new(#003300, 5) : color.new(#0D0D12, 0))

        // -- ROW 3: Trend  (price state -- what the chart is telling us) ------
        string _trend_str = ""
        if price_state == 0
            _trend_str := "BULL INTACT"
        else if price_state == 1
            _trend_str := "CAUTION WATCH"
        else
            _trend_str := "CONFIRMED WEAK"
        string _trend_sub = ""
        if price_state == 0
            _trend_sub := "  above MA50 + MA200  golden X"
        else if price_state == 1
            _trend_sub := "  astro caution + price slipping"
        else
            _trend_sub := "  below MA50  no golden X"
        color  _trend_cl  = price_state_cl
        table.cell(t, 0, 3, "Trend",
             text_color=_trend_cl, text_size=size.small, text_halign=text.align_left,
             bgcolor=price_state >= 2 ? color.new(#200000, 5) : color.new(#00100A, 0))
        table.cell(t, 1, 3, _trend_str + _trend_sub,
             text_color=_trend_cl, text_size=size.small, text_halign=text.align_right,
             bgcolor=price_state >= 2 ? color.new(#200000, 5) : color.new(#00100A, 0))

        // -- ROW 4: Astro Risk (caution level + active event) -----------------
        int _ev_cnt = 0
        string _ev_name = ""
        for _ci = 0 to array.size(CAU_S) - 1
            if time >= array.get(CAU_S, _ci) and time <= array.get(CAU_E, _ci)
                if _ev_cnt == 0
                    _ev_name := array.get(CAU_LBL, _ci)
                _ev_cnt += 1

        string _cau_str = "CLEAR"
        color  _cau_cl  = C_BUY
        if caution_high
            _cau_str := "HIGH CAUTION"
            _cau_cl  := C_SELL
        else if caution_active
            _cau_str := "CAUTION ACTIVE"
            _cau_cl  := C_CAUTION
        else if _ev_cnt > 0
            _cau_str := "ELEVATED"
            _cau_cl  := C_WATCH

        string _cau_detail = _ev_cnt > 0 ? "  " + _ev_name + (_ev_cnt > 1 ? " +" + str.tostring(_ev_cnt - 1) + " more" : "") + " (score " + str.tostring(caution_score) + ")" : "  no active astro events"

        table.cell(t, 0, 4, "Astro Risk",
             text_color=_ev_cnt > 0 ? _cau_cl : C_INFO, text_size=size.small, text_halign=text.align_left,
             bgcolor=caution_high ? color.new(#200000, 5) : caution_active ? color.new(#1A0800, 5) : _ev_cnt > 0 ? color.new(#1A1200, 5) : color.new(#001200, 5))
        table.cell(t, 1, 4, _cau_str + _cau_detail,
             text_color=_cau_cl, text_size=size.small, text_halign=text.align_right,
             bgcolor=caution_high ? color.new(#200000, 5) : caution_active ? color.new(#1A0800, 5) : _ev_cnt > 0 ? color.new(#1A1200, 5) : color.new(#001200, 5))

        // -- ROW 5: DCL Window status ----------------------------------------
        string dc_val2  = na(days_since) ? "no pivot yet" : str.tostring(math.round(days_since)) + "d since last DCL"
        string dc_status = ""
        if not na(days_since)
            if in_dc
                dc_status := "  IN WINDOW  -- look for entry"
            else if days_since < float(i_dc_min)
                dc_status := "  opens in " + str.tostring(math.round(float(i_dc_min) - days_since)) + "d"
            else
                dc_status := "  overrun +" + str.tostring(math.round(days_since - DC_HI_F)) + "d -- watch for reset"
        color _dc_cl2 = in_dc ? C_BUY : not na(days_since) and days_since > DC_HI_F ? color.orange : C_INFO
        if early_dcl_active and not na(early_dcl_low)
            dc_status := " [EARLY DCL: $" + str.tostring(early_dcl_low, "#,###") + "]"
        table.cell(t, 0, 5, "DCL Window",
             text_color=_dc_cl2, text_size=size.small, text_halign=text.align_left,
             bgcolor=in_dc ? color.new(#003300, 5) : color.new(#0D0D12, 0))
        table.cell(t, 1, 5, dc_val2 + dc_status,
             text_color=_dc_cl2, text_size=size.small, text_halign=text.align_right,
             bgcolor=in_dc ? color.new(#003300, 5) : color.new(#0D0D12, 0))

        // -- ROW 6: Next Event (nearest upcoming caution or RC event) ---------
        // Pick the sooner of: next CAU window start, next RC window start
        int    _ncau_ts  = f_next_caution_ts()
        string _ncau_lbl = f_next_caution_lbl()
        int    _nrc_ts   = na
        string _nrc_lbl  = ""
        if i_show_rc
            int _nn = array.size(RC_S)
            for _rr = 0 to _nn - 1
                int _rts = array.get(RC_S, _rr)
                if _rts >= time and (na(_nrc_ts) or _rts < _nrc_ts)
                    _nrc_ts  := _rts
                    _nrc_lbl := array.get(RC_LBL, _rr)
        string _next_evt_str = "none found"
        color  _next_evt_cl  = C_INFO
        if not na(_ncau_ts) and not na(_nrc_ts)
            if _ncau_ts <= _nrc_ts
                _next_evt_str := _ncau_lbl + "  (in " + str.tostring(int(math.round((_ncau_ts - time) / MS_DAY))) + "d)"
                _next_evt_cl  := C_CAUTION
            else
                _next_evt_str := _nrc_lbl + "  (in " + str.tostring(int(math.round((_nrc_ts - time) / MS_DAY))) + "d)"
                _next_evt_cl  := C_RC
        else if not na(_ncau_ts)
            _next_evt_str := _ncau_lbl + "  (in " + str.tostring(int(math.round((_ncau_ts - time) / MS_DAY))) + "d)"
            _next_evt_cl  := C_CAUTION
        else if not na(_nrc_ts)
            _next_evt_str := _nrc_lbl + "  (in " + str.tostring(int(math.round((_nrc_ts - time) / MS_DAY))) + "d)"
            _next_evt_cl  := C_RC
        table.cell(t, 0, 6, "Next Event",
             text_color=C_INFO, text_size=size.small, text_halign=text.align_left)
        table.cell(t, 1, 6, _next_evt_str,
             text_color=_next_evt_cl, text_size=size.small, text_halign=text.align_right)

        // -- ROW 7: Key Date  (4YR zone, or next eclipse if no 4YR zone) ------
        string _key_str = ""
        color  _key_cl  = C_INFO
        int    _d_low2  = int(math.round((PROJ_LOW - time) / MS_DAY))
        if bot4yr
            _key_str := "4YR BOTTOM ZONE -- " + str.tostring(math.round(left4yr)) + "d left  -- accumulate on DCL"
            _key_cl  := C_PROJ
        else if late4yr
            _key_str := "4YR LATE CYCLE -- " + str.tostring(math.round(left4yr)) + "d left  -- watch for top"
            _key_cl  := color.orange
        else if _d_low2 > 0
            _key_str := "4YR Low ~Nov 2026  (in " + str.tostring(_d_low2) + "d)  -- accum target"
            _key_cl  := C_PROJ
        else
            // Fall back to next eclipse
            int _nlu2 = f_next_ecl(LUNAR)
            int _nso2 = f_next_ecl(SOLAR)
            if not na(_nlu2) or not na(_nso2)
                bool _lu_first2 = not na(_nlu2) and (na(_nso2) or _nlu2 <= _nso2)
                int  _ne_ts2    = _lu_first2 ? _nlu2 : _nso2
                string _ne_lbl2 = _lu_first2 ? "Blood Moon" : "Total Solar"
                _key_str := _ne_lbl2 + "  " + str.tostring(year(_ne_ts2)) + "-" + str.tostring(month(_ne_ts2)) + "  (in " + str.tostring(int(math.round((_ne_ts2 - time) / MS_DAY))) + "d)"

                _key_cl  := _lu_first2 ? C_SELL : C_SOLAR
        table.cell(t, 0, 7, "Key Date",
             text_color=_key_cl, text_size=size.small, text_halign=text.align_left,
             bgcolor=bot4yr ? color.new(#000A1E, 5) : color.new(#0D0D12, 0))
        table.cell(t, 1, 7, _key_str,
             text_color=_key_cl, text_size=size.small, text_halign=text.align_right,
             bgcolor=bot4yr ? color.new(#000A1E, 5) : color.new(#0D0D12, 0))



// â”€â”€ ALERTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Existing cycle alerts (preserved from v2.6)
alertcondition(is_cycle_low,             title="DCL Confirmed",          message="BTC Daily Cycle Low confirmed. Signal lags pivot-right bars.")
alertcondition(early_dcl_fired,          title="Early DCL Reversal (Stage 1)", message="BTC Early DCL Watch triggered inside cycle window. Potential early bottom forming.")
alertcondition(in_dc and not in_dc[1],  title="Daily Window Open",      message="BTC Daily Cycle Window OPEN.")
alertcondition(in_wc and not in_wc[1],  title="Weekly Window Open",     message="BTC Weekly Cycle Window OPEN.")
alertcondition(in_wa and not in_wa[1],  title="Eclipse Window Open",    message="WA eclipse bottom window ACTIVE.")
alertcondition(conv  and not conv[1],   title="CONVERGENCE Active",     message="Cycle + Eclipse windows both active.")
alertcondition(on_lunar,                title="Blood Moon Today",        message="Total Lunar Eclipse today -- WA watch window.")
alertcondition(on_solar,                title="Solar Eclipse Today",     message="Total Solar Eclipse today.")
// v3.0 composite caution alerts
alertcondition(caution_open,            title="Astro Caution Opens",    message="Astro caution window opened. Score >= threshold. Price confirmation required.")
alertcondition(caution_escalate,        title="Astro Caution HIGH",     message="Astro caution escalated to HIGH. Multiple events overlapping. Watch price structure.")
alertcondition(caution_close,           title="Astro Caution Closed",   message="Astro caution window closed. Score dropped below threshold.")
alertcondition(price_state_weakening,   title="Price Scenario Weakening", message="Price state: CONFIRMED WEAK. Bull scenario at risk. Astro caution may now be meaningful.")
alertcondition(price_state_recovering,  title="Price Recovering",        message="Price recovering above fast MA. Caution window may not produce a correction.")
// v3.0 per-category alerts (fires once when that specific window first opens)
alertcondition(cat1_on and not cat1_on[1], title="CAU: Mercury Rx Opens",           message="Mercury Retrograde caution window opened. Calendar-only -- price confirmation required.")
alertcondition(cat2_on and not cat2_on[1], title="CAU: Venus Rx Opens",             message="Venus Retrograde caution window opened. Calendar-only -- price confirmation required.")
alertcondition(cat3_on and not cat3_on[1], title="CAU: Mars Rx Opens",              message="Mars Retrograde caution window opened. Largest single-event caution window. Watch price structure.")
alertcondition(cat4_on and not cat4_on[1], title="CAU: Mars-Saturn Conjunction",    message="Mars-Saturn Conjunction caution window opened. Calendar-only -- price confirmation required.")
alertcondition(cat5_on and not cat5_on[1], title="CAU: Mars-Saturn Square",         message="Mars-Saturn Square caution window opened. Calendar-only -- price confirmation required.")
alertcondition(cat6_on and not cat6_on[1], title="CAU: Saturn Station-Direct",      message="Saturn Station-Direct caution window opened. Calendar-only -- price confirmation required.")
alertcondition(cat7_on and not cat7_on[1], title="CAU: Uranus Station-Direct",      message="Uranus Station-Direct caution window opened. Calendar-only -- price confirmation required.")
alertcondition(cat8_on and not cat8_on[1], title="CAU: Partial Lunar Eclipse",      message="Partial Lunar Eclipse caution window opened. Calendar-only -- price confirmation required.")
// v3.1 Risk Calendar alert (fires on rising edge of ANY RC window)
// rc_open = first bar of a Risk Calendar window becoming active
alertcondition(rc_open,                    title="RC: Risk Calendar Window Opens",   message="Risk Calendar watch window has opened. Timing flag only -- no directional signal. Check price structure, ETH/BTC, and USDT.D before forming a directional view.")

// v3.1 additional signal alerts
// Eclipse variants
alertcondition(on_solar_a,                        title="Annular Solar Eclipse Today",      message="Annular Solar Eclipse today. Major cycle inflection window.")
alertcondition(on_partial,                        title="Partial Lunar Eclipse Today",      message="Partial Lunar Eclipse today. Minor eclipse window.")
// 4-year cycle proximity
alertcondition(late4yr and not late4yr[1],        title="4YR: Entering Late Zone (80%+)",   message="4-year cycle is 80%+ complete. Accumulation watch zone approaching.")
alertcondition(bot4yr and not bot4yr[1],          title="4YR: Bottom Zone Active (95%+)",   message="4-year cycle is 95%+ complete. High-probability bottom watch zone.")
// Cycle window combinations
alertcondition(in_both and not in_both[1],        title="DC + WC Windows Both Open",        message="Daily AND Weekly cycle windows both open simultaneously. Strong cycle confluence.")
alertcondition(conv and in_both and not (conv[1] and in_both[1]), title="FULL CONVERGENCE: DC+WC+Eclipse", message="Daily cycle + Weekly cycle + Eclipse window all active. Maximum cycle confluence.")
// Price structure alerts
alertcondition(golden_cross and not golden_cross[1],   title="Price: Golden Cross",          message="Fast MA crossed above slow MA. Bull price structure reinforced.")
alertcondition(not golden_cross and golden_cross[1],   title="Price: Death Cross",           message="Fast MA crossed below slow MA. Bull price structure weakened.")
alertcondition(swing_lo_broken and not swing_lo_broken[1], title="Price: Swing Low Broken", message="Price closed below prior swing low. Caution -- potential structure break.")
alertcondition(price_above_slow and not price_above_slow[1], title="Price: Reclaimed Slow MA", message="Price reclaimed the slow MA. Watch for confirmation close above.")
alertcondition(not price_above_slow and price_above_slow[1], title="Price: Lost Slow MA",    message="Price dropped below slow MA. Bull case under pressure.")
// Caution + cycle window overlap (high-interest combination)
alertcondition(caution_active and in_dc and not (caution_active[1] and in_dc[1]), title="WATCH: Caution + Cycle Window Overlap", message="Astro caution window active while inside daily cycle window. Watch for a sweep-and-reclaim pattern.")
// Drought zone
alertcondition(in_drought and not in_drought[1],  title="Eclipse Drought Zone Entered",     message="Entered eclipse drought zone -- no blood moons expected in this window.")
alertcondition(not in_drought and in_drought[1],  title="Eclipse Drought Zone Exited",      message="Eclipse drought zone ended. Blood moon tracking resumes.")
// RC individual window (per-window fires via rc_open which is already alerted)
// caution_active edge (in case user wants raw active state, not just opens/closes)
alertcondition(caution_active,                    title="CAU: Caution Active (Any Bar)",   message="Astro caution is active on this bar. For use with 'Once Per Bar' trigger type.")
alertcondition(caution_high,                      title="CAU: High Caution Active (Any Bar)", message="High astro caution is active on this bar. Multiple events stacked.")

// -- MASTER ALERT() SYSTEM ------------------------------------------------
// These alert() calls create the 'Any alert() function call' option in
// TradingView's alert dialog. Set ONE alert on that option to receive
// ALL signals below without creating 37 separate alerts.
// Each message includes what fired so you can identify it on your phone.
// Frequency: once_per_bar_close -- fires only on confirmed candle close.

// Cycle window alerts
if is_cycle_low
    alert("[BTC CYCLE] DCL CONFIRMED -- Daily Cycle Low confirmed. Check 4H structure for entry.", alert.freq_once_per_bar_close)
if early_dcl_fired
    alert("[BTC CYCLE] EARLY DCL WATCH -- Stage 1 reversal detected inside cycle window. Potential bottom forming.", alert.freq_once_per_bar_close)
if in_dc and not in_dc[1]
    alert("[BTC CYCLE] Daily Window OPEN -- Inside daily cycle window. Watch for DCL pattern.", alert.freq_once_per_bar_close)
if in_wc and not in_wc[1]
    alert("[BTC CYCLE] Weekly Window OPEN -- Inside weekly cycle window.", alert.freq_once_per_bar_close)
if in_both and not in_both[1]
    alert("[BTC CYCLE] DC + WC BOTH OPEN -- Daily and weekly windows active simultaneously. Strong confluence.", alert.freq_once_per_bar_close)
if conv and not conv[1]
    alert("[BTC CYCLE] CONVERGENCE -- Cycle + Eclipse windows both active. Maximum confluence.", alert.freq_once_per_bar_close)
if in_wa and not in_wa[1]
    alert("[BTC CYCLE] Eclipse Window OPEN -- WA blood moon window active.", alert.freq_once_per_bar_close)

// Eclipse alerts
if on_lunar
    alert("[ECLIPSE] BLOOD MOON -- Total lunar eclipse today. WA cycle watch window.", alert.freq_once_per_bar_close)
if on_solar
    alert("[ECLIPSE] TOTAL SOLAR ECLIPSE -- Major cycle inflection window.", alert.freq_once_per_bar_close)
if on_solar_a
    alert("[ECLIPSE] ANNULAR SOLAR ECLIPSE -- Cycle inflection window.", alert.freq_once_per_bar_close)
if on_partial
    alert("[ECLIPSE] PARTIAL LUNAR ECLIPSE -- Minor eclipse caution window.", alert.freq_once_per_bar_close)

// 4-year cycle proximity
if late4yr and not late4yr[1]
    alert("[4YR CYCLE] Entering LATE ZONE (80%+) -- Accumulation watch window approaching.", alert.freq_once_per_bar_close)
if bot4yr and not bot4yr[1]
    alert("[4YR CYCLE] BOTTOM ZONE ACTIVE (95%+) -- High-probability accumulation zone.", alert.freq_once_per_bar_close)

// Caution window alerts
if caution_open
    alert("[CAUTION OPENS] Astro caution window opened. Score >= threshold. Check price structure before acting.", alert.freq_once_per_bar_close)
if caution_escalate
    alert("[CAUTION HIGH] Astro caution escalated to HIGH. Multiple events stacking. Watch closely.", alert.freq_once_per_bar_close)
if caution_close
    alert("[CAUTION CLOSED] Astro caution window closed. Reduced risk.", alert.freq_once_per_bar_close)

// Per-category caution alerts
if cat1_on and not cat1_on[1]
    alert("[ASTRO] Mercury Rx window OPENED. Calendar flag -- price confirmation required.", alert.freq_once_per_bar_close)
if cat2_on and not cat2_on[1]
    alert("[ASTRO] Venus Rx window OPENED. Money/value planet retrograde. Watch risk assets.", alert.freq_once_per_bar_close)
if cat3_on and not cat3_on[1]
    alert("[ASTRO] Mars Rx window OPENED. Major caution period (~80 days). Watch momentum stalls.", alert.freq_once_per_bar_close)
if cat4_on and not cat4_on[1]
    alert("[ASTRO] Mars-Saturn Conjunction window OPENED. High caution weight.", alert.freq_once_per_bar_close)
if cat5_on and not cat5_on[1]
    alert("[ASTRO] Mars-Saturn Square window OPENED. Volatility risk elevated.", alert.freq_once_per_bar_close)
if cat6_on and not cat6_on[1]
    alert("[ASTRO] Saturn Station-Direct window OPENED. Saturn resumes direct motion.", alert.freq_once_per_bar_close)
if cat7_on and not cat7_on[1]
    alert("[ASTRO] Uranus Station-Direct window OPENED. Sudden shock risk.", alert.freq_once_per_bar_close)
if cat8_on and not cat8_on[1]
    alert("[ASTRO] Partial Lunar Eclipse window OPENED.", alert.freq_once_per_bar_close)

// Risk calendar
if rc_open
    alert("[RC] Risk Calendar window opened. Timing flag -- check price structure before acting.", alert.freq_once_per_bar_close)

// Price state alerts
if price_state_weakening
    alert("[PRICE] CONFIRMED WEAK -- Bull scenario at risk. Astro caution may now be meaningful.", alert.freq_once_per_bar_close)
if price_state_recovering
    alert("[PRICE] RECOVERING -- Price reclaiming fast MA. Caution window may not produce correction.", alert.freq_once_per_bar_close)
if golden_cross and not golden_cross[1]
    alert("[PRICE] GOLDEN CROSS -- Fast MA crossed above slow MA. Bull structure reinforced.", alert.freq_once_per_bar_close)
if not golden_cross and golden_cross[1]
    alert("[PRICE] DEATH CROSS -- Fast MA crossed below slow MA. Bull structure weakened.", alert.freq_once_per_bar_close)
if swing_lo_broken and not swing_lo_broken[1]
    alert("[PRICE] SWING LOW BROKEN -- Closed below prior swing low. Possible structure break.", alert.freq_once_per_bar_close)

// High-value combinations
if caution_active and in_dc and not (caution_active[1] and in_dc[1])
    alert("[COMBO] CAUTION + CYCLE WINDOW -- Astro caution active inside daily cycle window. Prime sweep-and-reclaim watch.", alert.freq_once_per_bar_close)
if in_drought and not in_drought[1]
    alert("[ECLIPSE] Drought zone entered -- no blood moons expected in this window.", alert.freq_once_per_bar_close)
````
