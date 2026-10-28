# FX Decision Panel Discretionary decision tool with TM module

- url: https://www.tradingview.com/script/EXZmqAf9-FX-Decision-Panel-Discretionary-decision-tool-with-TM-module/
- type: indicator
- pine_id: PUB;386c1ff777a546ddbbad27c2208a966c
- version: 2.0

## Description

Discretionary decision panel for FX and multi-asset. Tells you WHAT the market 
is doing, WHERE you are in structure, WHEN setups arm, and the QUALITY of each 
moment via a 🟢🟡🔴 confidence light. Not a signal generator. Not financial advice.

═══════════════════════════════════════════════════════════
FX DECISION PANEL v4.13 — Discretionary Decision Tool
═══════════════════════════════════════════════════════════

🎯 WHAT THIS IS

A single-panel decision support tool for discretionary traders.
It does NOT trade. It answers four questions:

- WHAT the market is doing (trend / range / ambiguous)
- WHERE you are in structure (pullback / expansion / extended)
- WHEN a setup triggers (but not whether to take it)
- QUALITY of the moment via 🟢🟡🔴 confidence light

The decision stays yours. Context is the panel's job.


❌ WHAT THIS IS NOT

- Not a signal generator
- Not a strategy with entries and exits
- Not a backtest-ready system
- Not financial advice


🔑 CORE FEATURES

▸ Regime detection
  TREND / RANGE / ambiguous classification based on ADX + ATR.

▸ HTF regime gate
  Bias comes from higher timeframe, but only when HTF itself has 
  a regime. Eliminates phantom bias on lower timeframes.

▸ Dynamic trade zones
  Three boxes recalculate every bar: blue pullback zone, red stop, 
  green target. Labels show exact prices on right edge.

▸ Setup state machine
  NONE → NO PULLBACK → WEAK SETUP → READY → ENTER
  With INVALIDATED state when stop breaches.

▸ Confidence Light 🟢🟡🔴
  Single-glance filter: HIGH (all aligned), MED (partial),
  LOW (stand aside).

▸ Trade Management Module (opt-in, off by default)
  — Auto or manual entry detection
  — PnL in pips + % (adaptive per instrument)
  — MFE / MAE tracking
  — Chandelier trailing stop, armed after +1R
  — Deterioration warnings: EMA breach, ADX drop, MFE drawdown
  — Auto-close on stop / target / bias flip
  — Last trade persists for post-trade review

▸ Multi-instrument
  FX shows pips. Crypto / stocks / futures show absolute currency 
  units + percentage. Detected automatically.


⏱ RECOMMENDED TIMEFRAMES

★★★★★  1H — HTF 4H, the sweet spot
★★★★★  4H — HTF Daily, swing trading
★★★★    15m / 30m — active session intraday
★★★     5m — scalping
★★      1m — marginal
★★      Daily — usable with Max Stop cap
★       Weekly — not recommended

HTF auto-mapping (non-configurable by design):
  1m/5m → 45m | 15m → 1H | 30m/45m/1H → 4H
  2H → 4H | 3H–12H → D | D → W | W → M


📊 READING THE PANEL

Four sections, read top to bottom:

  DECISION BLOCK
  • ACTION — the one-line answer
  • Setup — state machine position
  • Next — what to watch
  • Quality — 🟢🟡🔴 confidence

  MARKET STATE BLOCK
  • Mode — TREND / RANGE / —
  • Bias — LONG / SHORT / FLAT + source
  • ATR — value + HIGH/NORMAL/LOW
  • Trend Quality — expansion in ATR multiples

  ENTRY BLOCK
  • Entry Zone — EMA20 ± 0.5×ATR
  • Optimal Entry — EMA20 price
  • Stop / Target — with R:R validation

  TRADE MANAGEMENT BLOCK (when enabled)
  • Trade — direction + entry
  • PnL — amount / % / R
  • MFE / MAE
  • Trail Stop
  • Status — OK / warnings / CLOSED


🎛 KEY SETTINGS

All defaults are sensible. Touch only if you know why.

  • ADX: Trend Above (20)
  • ATR Min Ratio (0.7)
  • Pullback Zone × ATR (0.5)
  • ATR Stop Ref × (1.5)
  • Max Stop × ATR (3.0)
  • R:R Reference (1.5)


🔔 ALERTS AVAILABLE

- Long / Short Trigger Printed
- Trend Mode / Range Mode activated
- Long / Short Pullback Active
- Setup Invalidated
- TM Trade Opened / Closed
- TM Trail Armed
- TM Warning (deterioration)


⚠ KNOWN LIMITATIONS

- Daily/Weekly: Max Stop cap works but structural stops not 
  implemented. Supplement with manual structure analysis.
- Manual mode: if entry price > 0 and mode = Auto, footer shows 
  yellow warning. Set mode to Manual to use it.
- Single trade only. No scaling in/out.
- Close-based exits (not intrabar high/low).


📜 PHILOSOPHY

The 80% of FX edge is NOT entering. The panel's best contribution 
is telling you when to stand aside. When it says WAIT or 🔴, trust it.


🛠 BUILT BY

ClauFer Research Lab — April 2026
Free indicator. Use at your own risk. Read the code if you want 
to verify any logic.

Full manual with screenshots and details:
[link to your hosted HTML manual or GitHub]

═══════════════════════════════════════════════════════════

## Source Code

````pine
// ============================================================================
// FX DECISION PANEL v4.14 — INDICATOR ONLY
// ClauFer Research Lab — April 2026
// Pine Script v5 | Non-Repainting
// ============================================================================
//
// CHANGELOG v4.14: Confidence Light refinement — actionable semantics.
//   - HIGH 🟢 now requires setup_state in {READY, ENTER}, not just macro alignment.
//   - MED 🟡 covers macro-aligned but no actionable setup (NO PULLBACK, WEAK, EXTENDED).
//   - LOW 🔴 covers no regime / bias flat / invalidated.
//   - Resolves inconsistency: "HIGH aligned" while "NO PULLBACK" (v4.12/v4.13 bug).
//   - Detail text now more specific: "ready", "waiting for pullback", etc.
// CHANGELOG v4.13: Manual Entry UX fix.
//   - If Manual Entry Price > 0 while mode is Auto, footer shows warning:
//     "⚠ Manual price set but mode=Auto". Prevents silent user confusion.
//   - No logic change — pure UX guard.
// CHANGELOG v4.12: Confidence Light (🟢🟡🔴).
//   - New panel row (under ACTION): QUALITY semaphore.
//   - HIGH 🟢: regime active + bias set + exp in bias dir + not extended + HTF regime OK.
//   - MED 🟡: regime active + bias set, but missing expansion / extended / HTF weak.
//   - LOW 🔴: no regime / bias flat / invalidated.
//   - Purpose: single-glance decision filter. No new logic, just aggregation.
// CHANGELOG v4.11: Instrument-adaptive units (crypto/stocks support).
//   - Detects instrument type (FX vs non-FX).
//   - FX: PnL in pips (unchanged behavior).
//   - Non-FX (crypto/stocks/futures): PnL in absolute price units.
//   - Change% shown alongside in both cases (universal metric).
//   - Label on chart and panel row 15 adapted to instrument type.
//   - Fixed residual "v4.9" in panel header (cosmetic).
// CHANGELOG v4.10: Trade Management Module (opt-in).
//   - New group TRADE MANAGEMENT (disabled by default).
//   - Auto-detects entries from trigger_l/trigger_s OR manual entry price.
//   - Tracks PnL (pips + R), MFE/MAE (price + R).
//   - Chandelier Exit trailing stop, armed only after +1R.
//   - Exit warnings: EMA breach, ADX drop from entry, MFE drawdown >50%.
//   - Auto-closes on: stop/trail hit, target hit, bias flip.
//   - "Last Trade" persists after close until manual reset.
//   - Visual: entry line, trail line, floating PnL label.
//   - New panel rows (14-18): Trade / PnL / Trail / Warnings / Close Reason.
// CHANGELOG v4.9: Entry Zone redefinition.
//   - Entry Zone in table now = ema20 ± (i_pbZone × ATR).
//   - Coherent with the blue Pullback box on chart (same range).
//   - Optimal Entry = ema20 is now the CENTER of Entry Zone, not the edge.
//   - Fixes absurd Entry Zone ranges on higher TFs (Daily/Weekly).
// CHANGELOG v4.8: Max Stop Cap.
//   - New input: "Max Stop (× ATR)" default 3.0.
//   - ref_stop now capped so it's never farther than Max Stop × ATR from entry.
//   - Prevents absurd stops on Daily/Weekly where structural floor is distant.
// CHANGELOG v4.7: Setup Invalidation + Proximity Warning.
// CHANGELOG v4.6: Labels with price + thicker bands.
// CHANGELOG v4.5: Transparencies as inputs.
// CHANGELOG v4.4: Dynamic trade zones.
// CHANGELOG v4.3: HTF regime gate for trend bias.
// CHANGELOG v4.2: HTF map — 1m/5m → 45m.
//
// ============================================================================

//@version=5
indicator("FX Decision Panel v4.14", overlay=true, max_bars_back=500, max_boxes_count=50, max_labels_count=50, max_lines_count=10)

// ============================================================================
// INPUTS
// ============================================================================

grp_regime = "═══ REGIME ═══"
i_adxLen     = input.int(14,    "ADX Length",              minval=7,   maxval=25,  group=grp_regime)
i_adxTrend   = input.float(20,  "ADX: Trend Above",       minval=12,  maxval=35,  group=grp_regime)
i_atrLen     = input.int(14,    "ATR Length",              minval=7,   maxval=21,  group=grp_regime)
i_atrAvg     = input.int(50,    "ATR Average Length",      minval=20,  maxval=100, group=grp_regime)
i_atrMin     = input.float(0.7, "ATR Min Ratio",           minval=0.3, maxval=1.0, step=0.1, group=grp_regime)
i_emaSlopeK  = input.float(0.3, "EMA200 Flat Threshold (× ATR)", minval=0.1, maxval=1.0, step=0.1, group=grp_regime)

grp_trend = "═══ TREND MODE ═══"
i_htfEmaLen  = input.int(200,   "HTF EMA Length",          minval=50,  maxval=300, group=grp_trend)
i_expLookback= input.int(20,    "Expansion Lookback",      minval=5,   maxval=50,  group=grp_trend)
i_expMult    = input.float(2.5, "Expansion Min (× ATR)",   minval=1.0, maxval=4.0, step=0.25, group=grp_trend)

grp_range = "═══ RANGE MODE ═══"
i_zonePeriod = input.int(200,   "Zone Lookback (bars)",    minval=50,  maxval=500, group=grp_range)
i_zoneLowPct = input.float(20,  "Zone Floor Percentile",   minval=5,   maxval=40,  group=grp_range)
i_zoneHiPct  = input.float(80,  "Zone Ceiling Percentile", minval=60,  maxval=95,  group=grp_range)

grp_trig = "═══ PULLBACK ═══"
i_ltfEmaLen  = input.int(20,    "EMA Length",              minval=10,  maxval=50,  group=grp_trig)
i_pbZone     = input.float(0.5, "Pullback Zone (× ATR)",   minval=0.1, maxval=2.0, step=0.1, group=grp_trig)
i_pbMemory   = input.int(5,     "Pullback Memory (bars)",  minval=1,   maxval=15,  group=grp_trig)

grp_risk = "═══ RISK REFERENCE ═══"
i_stopMult   = input.float(1.5, "ATR Stop Ref (×)",        minval=0.5, maxval=3.0, step=0.25, group=grp_risk)
i_stopMaxATR = input.float(3.0, "Max Stop (× ATR)",        minval=1.0, maxval=6.0, step=0.25, group=grp_risk)
i_targetR    = input.float(1.5, "R:R Reference",           minval=1.0, maxval=5.0, step=0.25, group=grp_risk)

grp_inv = "═══ INVALIDATION ═══"
i_invRecoverATR  = input.float(0.3, "Recovery Threshold (× ATR)", minval=0.1, maxval=1.0, step=0.05, group=grp_inv)
i_proxWarnATR    = input.float(0.5, "Proximity Warning (× ATR)",  minval=0.1, maxval=2.0, step=0.1,  group=grp_inv)

grp_tz = "═══ TRADE ZONES ═══"
i_showTradeZones   = input.bool(true,  "Show Trade Zones (pullback/stop/target)", group=grp_tz)
i_tzShowLabels     = input.bool(true,  "Show Zone Labels (with price)",            group=grp_tz)
i_tzForward        = input.int(20,     "Forward Bars",                            minval=5,  maxval=100, group=grp_tz)
i_tzStopBand       = input.float(0.40, "Stop Band (× ATR)",                       minval=0.05, maxval=1.0, step=0.05, group=grp_tz)
i_tzTgtBand        = input.float(0.40, "Target Band (× ATR)",                     minval=0.05, maxval=1.0, step=0.05, group=grp_tz)
i_tzPbActiveTrp    = input.int(40,     "Transparency: Pullback ACTIVE",           minval=0,  maxval=100, group=grp_tz)
i_tzPbInactiveTrp  = input.int(65,     "Transparency: Pullback INACTIVE",         minval=0,  maxval=100, group=grp_tz)
i_tzStopTrp        = input.int(55,     "Transparency: Stop Zone",                 minval=0,  maxval=100, group=grp_tz)
i_tzTgtTrp         = input.int(55,     "Transparency: Target Zone",               minval=0,  maxval=100, group=grp_tz)

grp_dash = "═══ DASHBOARD ═══"
i_showDash   = input.bool(true, "Show Dashboard",          group=grp_dash)
i_dashPos    = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp_dash)
i_showZones  = input.bool(true, "Show Structural Zones / Lines", group=grp_dash)
i_showEma    = input.bool(true, "Show EMA 20",             group=grp_dash)

grp_tm = "═══ TRADE MANAGEMENT ═══"
i_tmEnable         = input.bool(false,   "Enable Trade Management",                 group=grp_tm)
i_tmEntryMode      = input.string("Auto", "Entry Detection",                        options=["Auto","Manual"], group=grp_tm)
i_tmManualEntry    = input.float(0.0,    "Manual Entry Price (Manual mode)",        group=grp_tm)
i_tmManualDir      = input.string("Long","Manual Direction",                        options=["Long","Short"], group=grp_tm)
i_tmChandLen       = input.int(10,       "Chandelier Lookback (bars)",              minval=3, maxval=50, group=grp_tm)
i_tmChandATR       = input.float(2.5,    "Chandelier Multiplier (× ATR)",           minval=1.0, maxval=5.0, step=0.25, group=grp_tm)
i_tmTrailArmR      = input.float(1.0,    "Trail Arm Threshold (× R)",               minval=0.5, maxval=3.0, step=0.25, group=grp_tm)
i_tmAdxDropThr     = input.float(5.0,    "ADX Drop Warning (points)",               minval=1.0, maxval=20.0, step=1.0, group=grp_tm)
i_tmMfeDrawdownPct = input.float(50.0,   "MFE Drawdown Warning (%)",                minval=20.0, maxval=90.0, step=5.0, group=grp_tm)
i_tmResetTrade     = input.bool(false,   "⟲ Reset / Hide Last Trade",               group=grp_tm)
i_tmShowVisuals    = input.bool(true,    "Show Chart Visuals (entry/trail/PnL)",    group=grp_tm)

// ============================================================================
// CALCULATIONS
// ============================================================================

atr_val   = ta.atr(i_atrLen)
atr_avg   = ta.sma(atr_val, i_atrAvg)
atr_ratio = atr_avg > 0 ? atr_val / atr_avg : 1.0

[diplus, diminus, adx_val] = ta.dmi(i_adxLen, i_adxLen)

ema20 = ta.ema(close, i_ltfEmaLen)

f_pipSize() =>
    syminfo.mintick >= 0.001 ? 0.01 : 0.0001
pip_size = f_pipSize()

// Instrument type detection (v4.11) — adapts PnL units
bool   is_fx       = syminfo.type == "forex"
float  unit_size   = is_fx ? pip_size : 1.0          // divisor for amount (pips or absolute)
string unit_label  = is_fx ? "pips"   : syminfo.currency

f_fmtPrice(float p) =>
    str.tostring(p, format.mintick)

// ============================================================================
// HTF — NON-REPAINTING
// ============================================================================

f_getHTF() =>
    if timeframe.isintraday
        int m = timeframe.multiplier
        if m <= 5
            "45"
        else if m <= 15
            "60"
        else if m <= 60
            "240"
        else if m <= 120
            "240"
        else
            "D"
    else if timeframe.period == "D"
        "W"
    else if timeframe.period == "W"
        "M"
    else
        "M"

htf = f_getHTF()

htf_ema = request.security(syminfo.tickerid, htf, ta.ema(close, i_htfEmaLen),
     lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
htf_close = request.security(syminfo.tickerid, htf, close,
     lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

f_htf_adx() =>
    [_dip, _dim, _adx] = ta.dmi(i_adxLen, i_adxLen)
    _adx

htf_adx = request.security(syminfo.tickerid, htf, f_htf_adx(),
     lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

bool htf_has_regime = not na(htf_adx) and htf_adx >= i_adxTrend

float ema200_local = ta.ema(close, i_htfEmaLen)
float ema200_slope = ema200_local - ema200_local[10]
bool  ema200_flat  = math.abs(ema200_slope) < atr_val * i_emaSlopeK

// ============================================================================
// REGIME SWITCH
// ============================================================================

var bool is_trend_mode = true
var bool is_range_mode = false

if barstate.isconfirmed
    bool adx_trending = adx_val >= i_adxTrend
    bool atr_alive    = atr_ratio >= i_atrMin

    if adx_trending and atr_alive
        is_trend_mode := true
        is_range_mode := false
    else if ema200_flat
        is_trend_mode := false
        is_range_mode := true
    else
        is_trend_mode := false
        is_range_mode := false

// ============================================================================
// BIAS
// ============================================================================

var int trend_bias = 0
if barstate.isconfirmed
    if not na(htf_close) and not na(htf_ema) and htf_has_regime
        trend_bias := htf_close > htf_ema ? 1 : htf_close < htf_ema ? -1 : 0
    else
        trend_bias := 0

float zone_floor   = ta.percentile_nearest_rank(close, i_zonePeriod, i_zoneLowPct)
float zone_ceiling = ta.percentile_nearest_rank(close, i_zonePeriod, i_zoneHiPct)

var int range_bias = 0
if barstate.isconfirmed
    if close <= zone_floor
        range_bias := 1
    else if close >= zone_ceiling
        range_bias := -1
    else
        range_bias := 0

var int bias = 0
var int bias_prev = 0
if barstate.isconfirmed
    bias_prev := bias
    if is_trend_mode
        bias := trend_bias
    else if is_range_mode
        bias := range_bias
    else
        bias := 0

// ============================================================================
// EXPANSION CHECK
// ============================================================================

float dist_high = ta.highest(high, i_expLookback) - ema20
float dist_low  = ema20 - ta.lowest(low, i_expLookback)
bool exp_ok_long  = dist_high > atr_val * i_expMult
bool exp_ok_short = dist_low  > atr_val * i_expMult

// ============================================================================
// PULLBACK STATE
// ============================================================================

var bool   pb_active_l = false
var bool   pb_active_s = false
var float  sig_high    = na
var float  sig_low     = na
var int    pb_bars_l   = 0
var int    pb_bars_s   = 0
var bool   trigger_l   = false
var bool   trigger_s   = false

if barstate.isconfirmed
    float pb_dist = atr_val * i_pbZone

    bool touched_l = bias > 0 and low <= ema20 + pb_dist and close > ema20
    if touched_l
        pb_active_l := true
        sig_high    := high
        pb_bars_l   := 0
    else if pb_active_l
        pb_bars_l += 1
        if low <= ema20 + pb_dist and close > ema20
            sig_high  := high
            pb_bars_l := 0
        if pb_bars_l > i_pbMemory
            pb_active_l := false
            sig_high    := na

    bool touched_s = bias < 0 and high >= ema20 - pb_dist and close < ema20
    if touched_s
        pb_active_s := true
        sig_low     := low
        pb_bars_s   := 0
    else if pb_active_s
        pb_bars_s += 1
        if high >= ema20 - pb_dist and close < ema20
            sig_low   := low
            pb_bars_s := 0
        if pb_bars_s > i_pbMemory
            pb_active_s := false
            sig_low     := na

    trigger_l := pb_active_l and not na(sig_high) and close > sig_high
    trigger_s := pb_active_s and not na(sig_low) and close < sig_low

    if trigger_l
        pb_active_l := false
        sig_high    := na
    if trigger_s
        pb_active_s := false
        sig_low     := na

// ============================================================================
// RISK REFERENCE  (v4.8: max stop cap applied)
// ============================================================================

float stop_ref  = atr_val * i_stopMult
float tgt_ref   = stop_ref * i_targetR
float stop_pips = stop_ref / pip_size
float tgt_pips  = tgt_ref / pip_size

float ref_entry = ema20
float ref_stop  = bias > 0 ? math.min(zone_floor - atr_val * 0.2, ref_entry - stop_ref) : bias < 0 ? math.max(zone_ceiling + atr_val * 0.2, ref_entry + stop_ref) : na
// Validation: force correct structure
if bias > 0 and not na(ref_stop) and ref_stop >= ref_entry
    ref_stop := ref_entry - atr_val * 1.0
if bias < 0 and not na(ref_stop) and ref_stop <= ref_entry
    ref_stop := ref_entry + atr_val * 1.0
// v4.8: cap max stop distance (prevents absurd stops on higher TFs)
float max_stop_dist = atr_val * i_stopMaxATR
if bias > 0 and not na(ref_stop) and (ref_entry - ref_stop) > max_stop_dist
    ref_stop := ref_entry - max_stop_dist
if bias < 0 and not na(ref_stop) and (ref_stop - ref_entry) > max_stop_dist
    ref_stop := ref_entry + max_stop_dist
float ref_stop_dist = not na(ref_stop) ? math.abs(ref_entry - ref_stop) : na
float ref_target = bias > 0 and not na(ref_stop_dist) ? ref_entry + ref_stop_dist * i_targetR : bias < 0 and not na(ref_stop_dist) ? ref_entry - ref_stop_dist * i_targetR : na

// ============================================================================
// SETUP INVALIDATION
// ============================================================================

var bool setup_invalidated_l = false
var bool setup_invalidated_s = false
var bool invalidation_event  = false

if barstate.isconfirmed
    invalidation_event := false

    if bias != bias_prev
        setup_invalidated_l := false
        setup_invalidated_s := false

    if bias > 0 and not na(ref_stop)
        if not setup_invalidated_l and close <= ref_stop
            setup_invalidated_l := true
            invalidation_event  := true
        else if setup_invalidated_l and close >= ref_stop + atr_val * i_invRecoverATR
            setup_invalidated_l := false
    else
        setup_invalidated_l := false

    if bias < 0 and not na(ref_stop)
        if not setup_invalidated_s and close >= ref_stop
            setup_invalidated_s := true
            invalidation_event  := true
        else if setup_invalidated_s and close <= ref_stop - atr_val * i_invRecoverATR
            setup_invalidated_s := false
    else
        setup_invalidated_s := false

bool setup_invalidated = setup_invalidated_l or setup_invalidated_s

bool stop_proximity = false
if bias > 0 and not na(ref_stop) and not setup_invalidated_l
    stop_proximity := close <= ref_stop + atr_val * i_proxWarnATR
else if bias < 0 and not na(ref_stop) and not setup_invalidated_s
    stop_proximity := close >= ref_stop - atr_val * i_proxWarnATR

// ============================================================================
// TRADE MANAGEMENT MODULE (v4.10 — opt-in)
// ============================================================================
// Persistent trade state. All calculations isolated, no coupling to other logic.

var int    trade_dir          = 0     // 0 = none, 1 = long, -1 = short
var float  trade_entry        = na
var int    trade_entry_bar    = na
var float  trade_stop_init    = na    // stop at entry (fixed R reference)
var float  trade_target_init  = na
var float  trade_init_risk    = na    // |entry - stop_init|, for R calc
var float  trade_mfe_price    = na
var float  trade_mae_price    = na
var bool   trade_trail_armed  = false
var float  trade_trail_stop   = na
var float  trade_entry_adx    = na
var bool   trade_closed_flag  = false
var string trade_close_reason = ""
var float  trade_close_price  = na
var float  trade_close_pnl_r  = 0.0
var float  trade_close_mfe_r  = 0.0

// Live metrics (recomputed each confirmed bar while trade is active)
var float  trade_pnl_price  = 0.0
var float  trade_pnl_pips   = 0.0      // legacy alias, kept for clarity in FX mode
var float  trade_pnl_amount = 0.0      // v4.11: adaptive — pips for FX, absolute for non-FX
var float  trade_pnl_pct    = 0.0      // v4.11: % change from entry
var float  trade_pnl_r      = 0.0
var float  trade_mfe_r      = 0.0
var float  trade_mae_r      = 0.0

// Event flags (one-shot, reset each bar)
var bool trade_just_opened = false
var bool trade_just_closed = false

// Warning flags (recomputed each bar)
var bool trade_warn_ema = false
var bool trade_warn_adx = false
var bool trade_warn_mfe = false

if barstate.isconfirmed and i_tmEnable

    // Reset event flags each bar
    trade_just_opened := false
    trade_just_closed := false

    // --- RESET (manual) ---
    if i_tmResetTrade
        trade_dir          := 0
        trade_entry        := na
        trade_stop_init    := na
        trade_target_init  := na
        trade_init_risk    := na
        trade_mfe_price    := na
        trade_mae_price    := na
        trade_trail_armed  := false
        trade_trail_stop   := na
        trade_entry_adx    := na
        trade_closed_flag  := false
        trade_close_reason := ""
        trade_close_price  := na
        trade_pnl_price    := 0.0
        trade_pnl_pips     := 0.0
        trade_pnl_r        := 0.0
        trade_mfe_r        := 0.0
        trade_mae_r        := 0.0
        trade_close_pnl_r  := 0.0
        trade_close_mfe_r  := 0.0
        trade_warn_ema     := false
        trade_warn_adx     := false
        trade_warn_mfe     := false

    // --- ENTRY DETECTION (only if not currently in a trade) ---
    if trade_dir == 0 and not i_tmResetTrade

        bool open_l = false
        bool open_s = false
        float open_price = na

        if i_tmEntryMode == "Auto"
            if trigger_l and bias > 0 and not setup_invalidated
                open_l := true
                open_price := close
            else if trigger_s and bias < 0 and not setup_invalidated
                open_s := true
                open_price := close
        else if i_tmEntryMode == "Manual" and i_tmManualEntry > 0
            // Manual opens immediately on first bar user activates it
            if i_tmManualDir == "Long"
                open_l := true
                open_price := i_tmManualEntry
            else
                open_s := true
                open_price := i_tmManualEntry

        if (open_l or open_s) and not na(ref_stop) and not na(ref_target)
            trade_dir          := open_l ? 1 : -1
            trade_entry        := open_price
            trade_entry_bar    := bar_index
            trade_stop_init    := ref_stop
            trade_target_init  := ref_target
            trade_init_risk    := math.abs(open_price - ref_stop)
            trade_mfe_price    := open_price
            trade_mae_price    := open_price
            trade_entry_adx    := adx_val
            trade_trail_armed  := false
            trade_trail_stop   := na
            trade_closed_flag  := false
            trade_close_reason := ""
            trade_close_price  := na
            trade_just_opened  := true

    // --- TRACKING (if trade active) ---
    if trade_dir != 0

        // MFE / MAE (use high/low for realistic extremes)
        if trade_dir == 1
            trade_mfe_price := math.max(nz(trade_mfe_price, high), high)
            trade_mae_price := math.min(nz(trade_mae_price, low), low)
        else
            trade_mfe_price := math.min(nz(trade_mfe_price, low), low)
            trade_mae_price := math.max(nz(trade_mae_price, high), high)

        // PnL instant
        trade_pnl_price  := trade_dir == 1 ? close - trade_entry : trade_entry - close
        trade_pnl_pips   := trade_pnl_price / pip_size
        trade_pnl_amount := trade_pnl_price / unit_size
        trade_pnl_pct    := trade_entry > 0 ? (trade_pnl_price / trade_entry) * 100.0 : 0.0
        trade_pnl_r      := trade_init_risk > 0 ? trade_pnl_price / trade_init_risk : 0.0

        // MFE / MAE en R
        float mfe_delta = trade_dir == 1 ? trade_mfe_price - trade_entry : trade_entry - trade_mfe_price
        float mae_delta = trade_dir == 1 ? trade_mae_price - trade_entry : trade_entry - trade_mae_price
        trade_mfe_r := trade_init_risk > 0 ? mfe_delta / trade_init_risk : 0.0
        trade_mae_r := trade_init_risk > 0 ? mae_delta / trade_init_risk : 0.0

        // Arm trailing when reaches threshold
        if not trade_trail_armed and trade_pnl_r >= i_tmTrailArmR
            trade_trail_armed := true

        // Chandelier trail (only if armed) — ta.* calls outside conditional
        float chand_long  = ta.highest(high, i_tmChandLen) - atr_val * i_tmChandATR
        float chand_short = ta.lowest(low,  i_tmChandLen) + atr_val * i_tmChandATR
        if trade_trail_armed
            if trade_dir == 1
                trade_trail_stop := na(trade_trail_stop) ? chand_long : math.max(trade_trail_stop, chand_long)
            else
                trade_trail_stop := na(trade_trail_stop) ? chand_short : math.min(trade_trail_stop, chand_short)

        // Warnings
        trade_warn_ema := (trade_dir == 1 and close < ema20) or (trade_dir == -1 and close > ema20)
        trade_warn_adx := not na(trade_entry_adx) and (adx_val < trade_entry_adx - i_tmAdxDropThr)
        trade_warn_mfe := trade_mfe_r > 0 and trade_pnl_r < trade_mfe_r * (1.0 - i_tmMfeDrawdownPct / 100.0)

        // Effective stop (max of init and trail for long, min for short)
        float effective_stop = trade_trail_armed and not na(trade_trail_stop) ?
             (trade_dir == 1 ? math.max(trade_stop_init, trade_trail_stop) : math.min(trade_stop_init, trade_trail_stop)) :
             trade_stop_init

        // Close conditions (close-based, consistent with invalidation logic)
        bool hit_stop   = trade_dir == 1 ? close <= effective_stop : close >= effective_stop
        bool hit_target = trade_dir == 1 ? close >= trade_target_init : close <= trade_target_init
        bool bias_flip  = bias == 0 or (trade_dir == 1 and bias < 0) or (trade_dir == -1 and bias > 0)

        if hit_stop
            trade_close_reason := trade_trail_armed ? "TRAIL STOPPED" : "STOPPED"
            trade_close_price  := close
            trade_close_pnl_r  := trade_pnl_r
            trade_close_mfe_r  := trade_mfe_r
            trade_closed_flag  := true
            trade_dir          := 0
            trade_just_closed  := true
        else if hit_target
            trade_close_reason := "TARGET HIT"
            trade_close_price  := close
            trade_close_pnl_r  := trade_pnl_r
            trade_close_mfe_r  := trade_mfe_r
            trade_closed_flag  := true
            trade_dir          := 0
            trade_just_closed  := true
        else if bias_flip
            trade_close_reason := "BIAS FLIP"
            trade_close_price  := close
            trade_close_pnl_r  := trade_pnl_r
            trade_close_mfe_r  := trade_mfe_r
            trade_closed_flag  := true
            trade_dir          := 0
            trade_just_closed  := true

// Aggregate warning flag (for panel display)
bool any_trade_warning = trade_warn_ema or trade_warn_adx or trade_warn_mfe

// Final in_trade flag (used by chart visuals and panel)
bool in_trade = trade_dir != 0

// ============================================================================
// CHART VISUALS
// ============================================================================

plot(i_showEma ? ema20 : na, "EMA 20 (Optimal Entry)", color=color.new(#42A5F5, 0), linewidth=2)

plot(i_showZones ? zone_floor   : na, "Structural Floor",   color=color.new(#00C853, 70), style=plot.style_linebr, linewidth=1)
plot(i_showZones ? zone_ceiling : na, "Structural Ceiling", color=color.new(#FF1744, 70), style=plot.style_linebr, linewidth=1)

var box structBox = na

if barstate.isconfirmed
    if not na(structBox)
        box.delete(structBox)
    structBox := na

    if i_showZones and bias != 0 and (is_trend_mode or is_range_mode)
        color box_clr = bias > 0 ? #00C853 : #FF1744
        structBox := box.new(bar_index - 30, zone_ceiling, bar_index + 5, zone_floor,
             border_color=color.new(box_clr, 80),
             bgcolor=color.new(box_clr, 95))

// ============================================================================
// DYNAMIC TRADE ZONES
// ============================================================================

var box   pb_zone_box   = na
var box   stop_zone_box = na
var box   tgt_zone_box  = na
var label pb_zone_lbl   = na
var label stop_zone_lbl = na
var label tgt_zone_lbl  = na

if barstate.isconfirmed
    if not na(pb_zone_box)
        box.delete(pb_zone_box)
    if not na(stop_zone_box)
        box.delete(stop_zone_box)
    if not na(tgt_zone_box)
        box.delete(tgt_zone_box)
    if not na(pb_zone_lbl)
        label.delete(pb_zone_lbl)
    if not na(stop_zone_lbl)
        label.delete(stop_zone_lbl)
    if not na(tgt_zone_lbl)
        label.delete(tgt_zone_lbl)

    pb_zone_box   := na
    stop_zone_box := na
    tgt_zone_box  := na
    pb_zone_lbl   := na
    stop_zone_lbl := na
    tgt_zone_lbl  := na

    if i_showTradeZones and bias != 0 and (is_trend_mode or is_range_mode) and not setup_invalidated

        int right_edge = bar_index + i_tzForward

        float pb_band = atr_val * i_pbZone
        float pb_low  = bias > 0 ? ema20 : ema20 - pb_band
        float pb_high = bias > 0 ? ema20 + pb_band : ema20
        float pb_mid  = (pb_low + pb_high) / 2.0
        bool  pb_hot  = (bias > 0 and pb_active_l) or (bias < 0 and pb_active_s)
        int   pb_trp  = pb_hot ? i_tzPbActiveTrp : i_tzPbInactiveTrp
        int   pb_bord = pb_hot ? 15 : 35
        pb_zone_box := box.new(bar_index, pb_high, right_edge, pb_low,
             border_color=color.new(#42A5F5, pb_bord),
             bgcolor=color.new(#42A5F5, pb_trp))

        if i_tzShowLabels
            string pb_txt = (pb_hot ? "PB ● " : "PB  ") + f_fmtPrice(ema20)
            pb_zone_lbl := label.new(right_edge, pb_mid, pb_txt,
                 color=color.new(#42A5F5, 0),
                 textcolor=color.white,
                 style=label.style_label_left,
                 size=size.normal)

        if not na(ref_stop)
            float stop_band = atr_val * i_tzStopBand
            float stop_low  = ref_stop - stop_band
            float stop_high = ref_stop + stop_band
            stop_zone_box := box.new(bar_index, stop_high, right_edge, stop_low,
                 border_color=color.new(#FF1744, 25),
                 bgcolor=color.new(#FF1744, i_tzStopTrp))

            if i_tzShowLabels
                stop_zone_lbl := label.new(right_edge, ref_stop, "STOP  " + f_fmtPrice(ref_stop),
                     color=color.new(#FF1744, 0),
                     textcolor=color.white,
                     style=label.style_label_left,
                     size=size.normal)

        if not na(ref_target)
            float tgt_band = atr_val * i_tzTgtBand
            float tgt_low  = ref_target - tgt_band
            float tgt_high = ref_target + tgt_band
            tgt_zone_box := box.new(bar_index, tgt_high, right_edge, tgt_low,
                 border_color=color.new(#00C853, 25),
                 bgcolor=color.new(#00C853, i_tzTgtTrp))

            if i_tzShowLabels
                tgt_zone_lbl := label.new(right_edge, ref_target, "TGT  " + f_fmtPrice(ref_target),
                     color=color.new(#00C853, 0),
                     textcolor=color.white,
                     style=label.style_label_left,
                     size=size.normal)

bgcolor(setup_invalidated    ? color.new(#FF1744, 90) :
         pb_active_l         ? color.new(#00C853, 95) :
         pb_active_s         ? color.new(#FF1744, 95) : na,
     title="State Background")

plot(pb_active_l and not na(sig_high) and not setup_invalidated ? sig_high : na, "Trigger Line Long",  color=color.new(#FFD600, 0), style=plot.style_linebr, linewidth=2)
plot(pb_active_s and not na(sig_low)  and not setup_invalidated ? sig_low  : na, "Trigger Line Short", color=color.new(#FFD600, 0), style=plot.style_linebr, linewidth=2)

plotshape(trigger_l and not setup_invalidated, "Trigger Long",  shape.triangleup,   location.belowbar, color.new(#00C853, 0), size=size.small)
plotshape(trigger_s and not setup_invalidated, "Trigger Short", shape.triangledown,  location.abovebar, color.new(#FF1744, 0), size=size.small)

plot(i_showZones and bias > 0 and not na(ref_stop)   and not setup_invalidated ? ref_stop   : na, "Ref Stop L",   color=color.new(#FF1744, 50), style=plot.style_linebr, linewidth=1)
plot(i_showZones and bias > 0 and not na(ref_target) and not setup_invalidated ? ref_target : na, "Ref Target L", color=color.new(#00C853, 50), style=plot.style_linebr, linewidth=1)
plot(i_showZones and bias < 0 and not na(ref_stop)   and not setup_invalidated ? ref_stop   : na, "Ref Stop S",   color=color.new(#FF1744, 50), style=plot.style_linebr, linewidth=1)
plot(i_showZones and bias < 0 and not na(ref_target) and not setup_invalidated ? ref_target : na, "Ref Target S", color=color.new(#00C853, 50), style=plot.style_linebr, linewidth=1)

// ============================================================================
// TRADE MANAGEMENT VISUALS (v4.10)
// ============================================================================

plot(i_tmEnable and i_tmShowVisuals and in_trade and not na(trade_entry) ? trade_entry : na,
     "Trade Entry", color=color.new(#FFFFFF, 20), style=plot.style_linebr, linewidth=1)

plot(i_tmEnable and i_tmShowVisuals and in_trade and trade_trail_armed and not na(trade_trail_stop) ? trade_trail_stop : na,
     "Trail Stop", color=color.new(#FFD600, 0), style=plot.style_linebr, linewidth=2)

// Floating PnL label (dynamic, refreshed each bar)
var label tm_pnl_lbl = na

if barstate.isconfirmed
    if not na(tm_pnl_lbl)
        label.delete(tm_pnl_lbl)
    tm_pnl_lbl := na

    if i_tmEnable and i_tmShowVisuals and in_trade and not na(trade_entry)
        color pnl_clr = trade_pnl_r >= 0 ? color.new(#00C853, 0) : color.new(#FF1744, 0)
        string amount_str = is_fx ? str.tostring(math.round(trade_pnl_pips, 1)) + "p" : str.tostring(math.round(trade_pnl_amount, 2))
        string pct_str    = str.tostring(math.round(trade_pnl_pct, 2)) + "%"
        string pnl_txt = (trade_dir == 1 ? "▲ " : "▼ ") +
             amount_str + "  " +
             pct_str + "  " +
             str.tostring(math.round(trade_pnl_r, 2)) + "R" +
             (any_trade_warning ? "  ⚠" : "")
        tm_pnl_lbl := label.new(bar_index + 3, trade_entry, pnl_txt,
             color=pnl_clr,
             textcolor=color.white,
             style=label.style_label_left,
             size=size.normal)

// ============================================================================
// DASHBOARD
// ============================================================================

color C_grn = color.new(#00C853, 0)
color C_red = color.new(#FF1744, 0)
color C_ylw = color.new(#FFD600, 0)
color C_gry = color.new(#9E9E9E, 0)
color C_wht = color.new(#ffffff, 0)
color C_dim = color.new(#888888, 0)
color C_hdr = color.new(#16213e, 0)
color C_row = color.new(#0f0f23, 10)
color C_sep = color.new(#333355, 30)
color C_htx = color.new(#e0e0e0, 0)
color C_blu = color.new(#42A5F5, 0)
color C_org = color.new(#FF6F00, 0)

var table t = table.new(
     i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : i_dashPos == "Bottom Left" ? position.bottom_left : position.top_right,
     3, 22,
     bgcolor=color.new(#1a1a2e, 5), border_width=1,
     border_color=color.new(#333355, 20), frame_width=2,
     frame_color=color.new(#333355, 10))

if i_showDash and barstate.islast

    bool regime_active = is_trend_mode or is_range_mode
    bool exp_gate_l = is_trend_mode ? exp_ok_long : true
    bool exp_gate_s = is_trend_mode ? exp_ok_short : true
    float ema_dist = atr_val > 0 ? math.abs(close - ema20) / atr_val : 0.0
    bool is_extended = ema_dist > 2.0
    bool entry_now_l = trigger_l and bias > 0 and regime_active and exp_gate_l and not setup_invalidated
    bool entry_now_s = trigger_s and bias < 0 and regime_active and exp_gate_s and not setup_invalidated

    bool quality_ok_dir = bias > 0 ? exp_ok_long : bias < 0 ? exp_ok_short : false

    // Entry Zone (v4.9: ema20 ± pbZone×ATR, coherent with Pullback box)
    float ez_band = atr_val * i_pbZone
    float ez_low  = ema20 - ez_band
    float ez_high = ema20 + ez_band
    bool  in_zone = bias != 0 ? (close >= ez_low and close <= ez_high) : false

    string setup_state = "NONE"
    if setup_invalidated
        setup_state := "INVALIDATED"
    else if entry_now_l or entry_now_s
        setup_state := "ENTER"
    else if ((pb_active_l and bias > 0) or (pb_active_s and bias < 0)) and quality_ok_dir
        setup_state := "READY"
    else if ((pb_active_l and bias > 0) or (pb_active_s and bias < 0)) and not quality_ok_dir
        setup_state := "WEAK SETUP"
    else if bias != 0 and regime_active and not is_extended
        setup_state := "NO PULLBACK"

    // === CONFIDENCE LIGHT (v4.14) — actionable semantics ===
    // HIGH: setup is READY or ENTER (operable right now)
    // MED:  macro conditions aligned but no actionable setup yet
    // LOW:  invalidated, no regime, bias flat, or htf weak
    string quality_lvl = "LOW"
    string quality_ico = "🔴"
    string quality_det = "no trade"

    if setup_invalidated
        quality_lvl := "LOW"
        quality_ico := "🔴"
        quality_det := "invalidated"
    else if not regime_active
        quality_lvl := "LOW"
        quality_ico := "🔴"
        quality_det := "no regime"
    else if bias == 0
        quality_lvl := "LOW"
        quality_ico := "🔴"
        quality_det := is_trend_mode and not htf_has_regime ? "htf weak" : "no bias"
    else if setup_state == "READY" or setup_state == "ENTER"
        quality_lvl := "HIGH"
        quality_ico := "🟢"
        quality_det := setup_state == "ENTER" ? "trigger fired" : "ready to trigger"
    else
        // MED: macro aligned but no actionable setup — explain why
        quality_lvl := "MED"
        quality_ico := "🟡"
        if is_extended
            quality_det := "extended — wait"
        else if setup_state == "WEAK SETUP"
            quality_det := "weak — no expansion"
        else if setup_state == "NO PULLBACK"
            quality_det := "waiting for pullback"
        else if is_trend_mode and not htf_has_regime
            quality_det := "htf partial"
        else
            quality_det := "aligned — no setup"
    color quality_clr = quality_lvl == "HIGH" ? C_grn : quality_lvl == "MED" ? C_ylw : C_red

    // === ROW 0: HEADER ===
    table.cell(t, 0, 0, "FX DECISION PANEL v4.14", text_color=C_htx, bgcolor=C_hdr, text_size=size.small)
    table.merge_cells(t, 0, 0, 2, 0)

    // === ROW 1: ACTION ===
    string act_lbl = "WAIT"
    color  act_clr = C_gry

    if setup_invalidated
        act_lbl := "⚠ SETUP INVALIDATED — STOP BREACHED"
        act_clr := C_red
    else if entry_now_l
        act_lbl := "▲ LONG TRIGGER PRINTED"
        act_clr := C_grn
    else if entry_now_s
        act_lbl := "▼ SHORT TRIGGER PRINTED"
        act_clr := C_red
    else if stop_proximity
        act_lbl := "⚠ APPROACHING STOP"
        act_clr := C_org
    else if setup_state == "READY"
        act_lbl := "SETUP ARMED — WATCH"
        act_clr := C_blu

    table.cell(t, 0, 1, act_lbl, text_color=act_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(t, 0, 1, 2, 1)

    // === ROW 2: SETUP STATE ===
    color ss_clr = setup_state == "INVALIDATED" ? C_red : setup_state == "ENTER" ? C_grn : setup_state == "READY" ? C_blu : setup_state == "WEAK SETUP" ? C_ylw : setup_state == "NO PULLBACK" ? C_dim : C_gry
    table.cell(t, 0, 2, "Setup", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 2, setup_state, text_color=ss_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    string ss_det = setup_invalidated ? "stop broken" : pb_active_l ? str.tostring(i_pbMemory - pb_bars_l) + " bars" : pb_active_s ? str.tostring(i_pbMemory - pb_bars_s) + " bars" : ""
    table.cell(t, 2, 2, ss_det, text_color=C_dim, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === ROW 3: NEXT ===
    string next_lbl = "—"
    color  next_clr = C_dim

    if setup_invalidated
        float recov_target = bias > 0 ? ref_stop + atr_val * i_invRecoverATR : ref_stop - atr_val * i_invRecoverATR
        next_lbl := "WAIT FOR RECOVERY (" + f_fmtPrice(recov_target) + ") OR BIAS FLIP"
        next_clr := C_red
    else if entry_now_l
        next_lbl := "LONG SIGNAL — EVALUATE CONTEXT"
        next_clr := C_grn
    else if entry_now_s
        next_lbl := "SHORT SIGNAL — EVALUATE CONTEXT"
        next_clr := C_red
    else if not regime_active
        bool adx_pass = adx_val >= i_adxTrend
        bool atr_pass = atr_ratio >= i_atrMin
        next_lbl := "NO REGIME: " + (adx_pass ? "ADX ✓" : "ADX ✗") + " " + (atr_pass ? "ATR ✓" : "ATR ✗")
        next_clr := C_gry
    else if bias == 0
        if is_trend_mode and not htf_has_regime
            next_lbl := "HTF NO REGIME (ADX " + str.tostring(math.round(nz(htf_adx), 1)) + ")"
            next_clr := C_ylw
        else
            next_lbl := "WAIT FOR DIRECTION"
            next_clr := C_gry
    else if stop_proximity
        next_lbl := "STOP NEAR (" + f_fmtPrice(ref_stop) + ") — REDUCE RISK"
        next_clr := C_org
    else if is_extended
        next_lbl := "EXTENDED — WAIT (" + str.tostring(math.round(ema_dist, 1)) + "× ATR)"
        next_clr := C_ylw
    else if (pb_active_l or pb_active_s) and not quality_ok_dir
        next_lbl := "WAIT — NO EXPANSION (weak setup)"
        next_clr := C_ylw
    else if pb_active_l
        next_lbl := "LONG TRIGGER AT " + str.tostring(math.round(nz(sig_high), 5))
        next_clr := C_blu
    else if pb_active_s
        next_lbl := "SHORT TRIGGER AT " + str.tostring(math.round(nz(sig_low), 5))
        next_clr := C_blu
    else if bias > 0
        next_lbl := "PULLBACK TO ZONE (" + str.tostring(math.round(ez_low, 5)) + " — " + str.tostring(math.round(ez_high, 5)) + ")"
        next_clr := color.new(#69F0AE, 0)
    else if bias < 0
        next_lbl := "PULLBACK TO ZONE (" + str.tostring(math.round(ez_low, 5)) + " — " + str.tostring(math.round(ez_high, 5)) + ")"
        next_clr := color.new(#FF8A80, 0)

    table.cell(t, 0, 3, next_lbl, text_color=next_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    table.merge_cells(t, 0, 3, 2, 3)

    // === ROW 4: CONFIDENCE LIGHT (v4.12) — replaces old separator ===
    string qual_display = quality_ico + "  " + quality_lvl + "  —  " + quality_det
    table.cell(t, 0, 4, qual_display, text_color=quality_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(t, 0, 4, 2, 4)

    // === ROW 5: MODE + ADX ===
    string mode_lbl = is_trend_mode ? "TREND" : is_range_mode ? "RANGE" : "—"
    color  mode_clr = is_trend_mode ? C_grn : is_range_mode ? C_blu : C_gry
    table.cell(t, 0, 5, "Mode", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 5, mode_lbl, text_color=mode_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    table.cell(t, 2, 5, "ADX " + str.tostring(math.round(adx_val, 1)), text_color=C_dim, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === ROW 6: BIAS + SOURCE ===
    string bias_lbl = bias > 0 ? "LONG" : bias < 0 ? "SHORT" : "FLAT"
    color  bias_clr = setup_invalidated ? C_dim : bias > 0 ? C_grn : bias < 0 ? C_red : C_gry
    string bias_src = "—"
    if is_trend_mode
        bias_src := htf_has_regime ? "EMA " + htf : "HTF WEAK (" + str.tostring(math.round(nz(htf_adx), 1)) + ")"
    else if is_range_mode
        bias_src := "ZONE"
    color bias_src_clr = (is_trend_mode and not htf_has_regime) ? C_ylw : C_dim
    table.cell(t, 0, 6, "Bias", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 6, bias_lbl, text_color=bias_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    table.cell(t, 2, 6, bias_src, text_color=bias_src_clr, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === ROW 7: ATR ===
    string atr_status = atr_ratio >= 1.3 ? "HIGH" : atr_ratio >= i_atrMin ? "NORMAL" : "LOW"
    color  atr_clr = atr_ratio >= 1.3 ? C_grn : atr_ratio >= i_atrMin ? C_wht : C_ylw
    table.cell(t, 0, 7, "ATR", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 7, str.tostring(math.round(atr_val, 5)), text_color=C_wht, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    table.cell(t, 2, 7, atr_status, text_color=atr_clr, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === ROW 8: TREND QUALITY ===
    bool exp_dir_ok = bias > 0 ? exp_ok_long : bias < 0 ? exp_ok_short : false
    string tq_lbl = "—"
    color  tq_clr = C_dim
    if not regime_active
        tq_lbl := "NO REGIME"
        tq_clr := C_gry
    else if bias == 0
        tq_lbl := "—"
        tq_clr := C_dim
    else if is_extended and exp_dir_ok
        tq_lbl := "STRONG BUT EXTENDED"
        tq_clr := C_ylw
    else if exp_dir_ok
        tq_lbl := "STRONG"
        tq_clr := C_grn
    else if not is_extended
        tq_lbl := "WEAK"
        tq_clr := C_ylw
    else
        tq_lbl := "WEAK + EXTENDED"
        tq_clr := C_red

    table.cell(t, 0, 8, "Trend Quality", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 8, tq_lbl, text_color=tq_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    table.cell(t, 2, 8, str.tostring(math.round(ema_dist, 1)) + "× ATR", text_color=C_dim, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === SEPARATOR ===
    table.cell(t, 0, 9, "", bgcolor=C_sep)
    table.cell(t, 1, 9, "", bgcolor=C_sep)
    table.cell(t, 2, 9, "", bgcolor=C_sep)

    // === ROW 10: ENTRY ZONE (v4.9: ema20 ± pbZone×ATR, coherent with PB box) ===
    string ez_range = bias != 0 ? str.tostring(math.round(ez_low, 5)) + " — " + str.tostring(math.round(ez_high, 5)) : "—"
    string ez_status = setup_invalidated ? "INVALID" : in_zone ? "IN ZONE" : bias != 0 ? str.tostring(math.round(ema_dist, 1)) + "× ATR" : ""
    color ez_clr = setup_invalidated ? C_dim : bias > 0 ? C_grn : bias < 0 ? C_red : C_gry
    table.cell(t, 0, 10, "Entry Zone", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 10, ez_range, text_color=ez_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    table.cell(t, 2, 10, ez_status, text_color=setup_invalidated ? C_red : in_zone ? C_grn : C_dim, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === ROW 11: OPTIMAL ENTRY ===
    table.cell(t, 0, 11, "Optimal Entry", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 11, str.tostring(math.round(ema20, 5)), text_color=setup_invalidated ? C_dim : C_blu, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    table.cell(t, 2, 11, "EMA " + str.tostring(i_ltfEmaLen), text_color=C_dim, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === ROW 12: STOP / TARGET ===
    bool risk_valid = bias > 0 ? (not na(ref_stop) and ref_stop < ref_entry and ref_target > ref_entry) : bias < 0 ? (not na(ref_stop) and ref_stop > ref_entry and ref_target < ref_entry) : false

    string stop_str = not na(ref_stop)   ? str.tostring(math.round(ref_stop, 5))   : "—"
    string tgt_str  = not na(ref_target) ? str.tostring(math.round(ref_target, 5)) : "—"
    string rr_str   = setup_invalidated ? "  ⚠ BROKEN" : risk_valid ? "  R:" + str.tostring(i_targetR) : "  ⚠ INVALID"
    color  rr_clr   = setup_invalidated ? C_red : risk_valid ? C_grn : C_red

    table.cell(t, 0, 12, "Stop / Target", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
    table.cell(t, 1, 12, stop_str, text_color=C_red, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
    table.cell(t, 2, 12, tgt_str + rr_str, text_color=rr_clr, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === TRADE MANAGEMENT ROWS (14-19) — populated only when module enabled ===
    if i_tmEnable and (in_trade or trade_closed_flag)

        // === ROW 13: SEPARATOR ===
        table.cell(t, 0, 13, "", bgcolor=C_sep)
        table.cell(t, 1, 13, "", bgcolor=C_sep)
        table.cell(t, 2, 13, "", bgcolor=C_sep)

        // === ROW 14: TRADE STATUS ===
        string tr_dir_lbl = in_trade ? (trade_dir == 1 ? "▲ LONG" : "▼ SHORT") : ("LAST: " + trade_close_reason)
        color  tr_dir_clr = in_trade ? (trade_dir == 1 ? C_grn : C_red) : C_dim
        string tr_entry_str = not na(trade_entry) ? "@ " + f_fmtPrice(trade_entry) : "—"
        table.cell(t, 0, 14, "Trade", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
        table.cell(t, 1, 14, tr_dir_lbl, text_color=tr_dir_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
        table.cell(t, 2, 14, tr_entry_str, text_color=C_dim, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

        // === ROW 15: PnL (live or final) — v4.11 adaptive units ===
        float show_pnl_r   = in_trade ? trade_pnl_r   : trade_close_pnl_r
        // Derive amount and pct: live vs closed
        float show_pnl_amount = 0.0
        float show_pnl_pct    = 0.0
        if in_trade
            show_pnl_amount := trade_pnl_amount
            show_pnl_pct    := trade_pnl_pct
        else if trade_init_risk > 0 and not na(trade_entry) and not na(trade_close_price)
            float closed_price_delta = trade_close_pnl_r * trade_init_risk
            show_pnl_amount := closed_price_delta / unit_size
            show_pnl_pct    := trade_entry > 0 ? (closed_price_delta / trade_entry) * 100.0 : 0.0
        color pnl_clr_tbl = show_pnl_r >= 0 ? C_grn : C_red
        string pnl_amount_str = is_fx ? str.tostring(math.round(show_pnl_amount, 1)) + " pips" : str.tostring(math.round(show_pnl_amount, 2)) + " " + unit_label
        string pnl_pct_str    = str.tostring(math.round(show_pnl_pct, 2)) + "%"
        string pnl_main_str   = pnl_amount_str + "  /  " + pnl_pct_str
        string pnl_r_str = str.tostring(math.round(show_pnl_r, 2)) + "R"
        table.cell(t, 0, 15, "PnL", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
        table.cell(t, 1, 15, pnl_main_str, text_color=pnl_clr_tbl, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
        table.cell(t, 2, 15, pnl_r_str, text_color=pnl_clr_tbl, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

        // === ROW 16: MFE / MAE ===
        float show_mfe_r = in_trade ? trade_mfe_r : trade_close_mfe_r
        string mfe_str = str.tostring(math.round(show_mfe_r, 2)) + "R"
        string mae_str = str.tostring(math.round(trade_mae_r, 2)) + "R"
        table.cell(t, 0, 16, "MFE / MAE", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
        table.cell(t, 1, 16, mfe_str, text_color=C_grn, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
        table.cell(t, 2, 16, mae_str, text_color=C_red, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

        // === ROW 17: TRAIL STOP ===
        string trail_str = in_trade and trade_trail_armed and not na(trade_trail_stop) ? f_fmtPrice(trade_trail_stop) : (in_trade ? "not armed" : "—")
        color  trail_clr = in_trade and trade_trail_armed ? C_ylw : C_dim
        string trail_det = in_trade and trade_trail_armed ? "Chandelier" : (in_trade ? "arms at +" + str.tostring(i_tmTrailArmR) + "R" : "")
        table.cell(t, 0, 17, "Trail Stop", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
        table.cell(t, 1, 17, trail_str, text_color=trail_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
        table.cell(t, 2, 17, trail_det, text_color=C_dim, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

        // === ROW 18: WARNINGS ===
        string warn_str = "—"
        color  warn_clr = C_dim
        if in_trade and any_trade_warning
            string w = ""
            if trade_warn_ema
                w := w + "EMA "
            if trade_warn_adx
                w := w + "ADX "
            if trade_warn_mfe
                w := w + "MFE"
            warn_str := "⚠ " + w
            warn_clr := C_org
        else if not in_trade and trade_closed_flag
            warn_str := "CLOSED"
            warn_clr := C_dim
        else if in_trade
            warn_str := "OK"
            warn_clr := C_grn
        table.cell(t, 0, 18, "Status", text_color=C_htx, bgcolor=C_row, text_halign=text.align_left, text_size=size.small)
        table.cell(t, 1, 18, warn_str, text_color=warn_clr, bgcolor=C_row, text_halign=text.align_center, text_size=size.small)
        table.cell(t, 2, 18, "", text_color=C_dim, bgcolor=C_row, text_halign=text.align_right, text_size=size.small)

    // === ROW 20: FOOTER (moved from row 13 in v4.10) ===
    bool tm_config_mismatch = i_tmEnable and i_tmEntryMode == "Auto" and i_tmManualEntry > 0
    string tm_warn = tm_config_mismatch ? " | ⚠ Manual price set but mode=Auto" : ""
    string ftr = syminfo.ticker + " | " + timeframe.period + " | HTF:" + htf + " | " + mode_lbl + (setup_invalidated ? " | ⚠ INV" : "") + (i_tmEnable and in_trade ? " | TM" : "") + tm_warn
    color ftr_clr = tm_config_mismatch ? C_ylw : C_dim
    table.cell(t, 0, 20, ftr, text_color=ftr_clr, bgcolor=C_hdr, text_halign=text.align_left, text_size=size.small)
    table.merge_cells(t, 0, 20, 2, 20)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(trigger_l and bias > 0 and not setup_invalidated, "Long Trigger Printed", "FX Panel: ▲ LONG trigger printed on {{ticker}} {{interval}} — evaluate context")
alertcondition(trigger_s and bias < 0 and not setup_invalidated, "Short Trigger Printed", "FX Panel: ▼ SHORT trigger printed on {{ticker}} {{interval}} — evaluate context")
alertcondition(is_trend_mode and not is_trend_mode[1], "Trend Mode", "FX Panel: Switched to TREND mode on {{ticker}}")
alertcondition(is_range_mode and not is_range_mode[1], "Range Mode", "FX Panel: Switched to RANGE mode on {{ticker}}")
alertcondition(pb_active_l and not pb_active_l[1], "Long Pullback Active", "FX Panel: Long pullback active on {{ticker}} — watching")
alertcondition(pb_active_s and not pb_active_s[1], "Short Pullback Active", "FX Panel: Short pullback active on {{ticker}} — watching")
alertcondition(invalidation_event, "Setup Invalidated", "FX Panel: ⚠ Setup INVALIDATED on {{ticker}} {{interval}} — stop breached")
alertcondition(trade_just_opened, "TM Trade Opened", "FX Panel [TM]: Trade OPENED on {{ticker}} {{interval}}")
alertcondition(trade_just_closed, "TM Trade Closed", "FX Panel [TM]: Trade CLOSED on {{ticker}} {{interval}}")
alertcondition(i_tmEnable and trade_trail_armed and not trade_trail_armed[1], "TM Trail Armed", "FX Panel [TM]: Trail stop ARMED on {{ticker}} — protecting profit")
alertcondition(i_tmEnable and in_trade and any_trade_warning and not any_trade_warning[1], "TM Warning", "FX Panel [TM]: ⚠ Trade deterioration warning on {{ticker}}")

// ============================================================================
// END
// ============================================================================
````
