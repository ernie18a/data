# RPFXBYDAN - 3-Phase Gap Retest

- url: https://www.tradingview.com/script/fyLD75ht-RPFXBYDAN-3-Phase-Gap-Retest/
- type: indicator
- pine_id: PUB;cf2ca680ee3c44d099ba5bb6cd29181b
- version: 2.0

## Description

This indicator identifies a three-phase price cycle — consolidation, liquidity sweep, and directional expansion — and highlights price imbalance zones created during the expansion phase. Entry signals are generated when price retests these imbalance zones from the correct side. Optional VWAP and trend filters help align signals with broader market bias. Designed for futures and index markets on intraday timeframes.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════
//  RPFXBYDAN - 3-Phase Gap Retest ENTRY MODEL — RAWPIPSFXBYDAN
//  Consolidation → Liquidity Sweep → Structure Break → Gap Zone → Expansion
//
//  v6 improvements over v5:
//  1. Structure Break Strictness input (Strict / Midpoint / Basic)
//     • Strict   — close > acc_hi  (bull) / close < acc_lo  (bear)
//     • Midpoint — close > range midpoint (DEFAULT — best balance)
//     • Basic    — close > acc_lo  (bull) / close < acc_hi  (bear)
//     The Strict default in v5 was the biggest signal killer.
//
//  2. Configurable Structure Break timeout (was hardcoded at 20 bars)
//     Default raised to 30 bars.
//
//  3. Relaxed retest gate: close[1] >= ifvg_lo (was >= ifvg_hi)
//     Old rule blocked retests if any intermediate bar closed
//     below the gap zone top.  New rule: previous bar just needs
//     to have been above the gap zone bottom — far more practical.
//
//  4. Optional displacement requirement (toggle)
//     When OFF, any valid price gap after structure break qualifies.
//     Start OFF on new charts to maximise signal count, then enable.
//
//  5. Gap zone upgrade in state 4
//     While waiting for the retest, if a WIDER gap zone forms in the
//     same direction, the zone is updated to the better one.
//     You always enter on the freshest, widest imbalance.
//
//  Default adjustments:
//     manip_wick_min  0.4 → 0.3  (catch more wicks)
//     disp_body_min   0.5 → 0.4  (less strict displacement)
//     fvg_bars        15  → 20   (more time to find gap zone)
//     ifvg_bars       30  → 40   (more time for retest)
//     require_disp    —   → OFF  (no displacement required by default)
// ══════════════════════════════════════════════════════════════
indicator("RPFXBYDAN - 3-Phase Gap Retest", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ──────────────────────────────────────────────────────────────
//  INPUTS — Detection
// ──────────────────────────────────────────────────────────────
accum_len      = input.int(10,    "Accumulation Min Bars",           minval=3,   maxval=50,   group="Detection")
accum_mult     = input.float(2.0, "Accumulation Range  ATR x",       minval=0.3, maxval=5.0,  group="Detection")
manip_pct      = input.float(0.5, "Manipulation Spike  ATR x",       minval=0.1, maxval=5.0,  group="Detection")
manip_wick_min = input.float(0.3, "Manipulation Min Wick Ratio",     minval=0.0, maxval=0.95, group="Detection", tooltip="Minimum recovery wick fraction on spike candle.  0 = disabled.")
mss_mode       = input.string("Midpoint", "Structure Break Strictness", options=["Strict", "Midpoint", "Basic"], group="Detection", tooltip="Strict = close through the full consolidation boundary (acc_hi bull / acc_lo bear).  Midpoint = close through the range midpoint.  Basic = close back inside the consolidation range.  Midpoint is the best balance of quality and signal count.")
mss_timeout    = input.int(30,    "Max Bars: Structure Break After Sweep", minval=5, maxval=100, group="Detection")
require_disp   = input.bool(false,"Require Displacement Candle",     group="Detection", tooltip="When ON, the gap zone candle (bar[0] or bar[1]) must be a large-body bar.  Start OFF to maximise signal count.")
disp_body_min  = input.float(0.4, "Displacement Body Ratio",         minval=0.1, maxval=1.0,  group="Detection", tooltip="Body / range ratio required when displacement is ON.  0.4 = body >= 40% of candle range.")
use_vol_filter = input.bool(false,"Volume Confirmation on Spike",    group="Detection", tooltip="Spike bar volume must exceed the volume MA.")
vol_ma_len     = input.int(20,    "Volume MA Length",                minval=1,   maxval=100,  group="Detection")
min_fvg_gap    = input.float(0.05,"Min Gap Size  ATR x",             minval=0.0, maxval=5.0,  group="Detection")
fvg_bars       = input.int(20,    "Max Bars: Gap After Structure Break", minval=1, maxval=50,  group="Detection", tooltip="Bars after structure break to find the displacement gap zone.")
ifvg_bars      = input.int(40,    "Max Bars: Retest After Gap",      minval=1,   maxval=100,  group="Detection", tooltip="Bars after gap zone detection to wait for the retest entry.")
ifvg_break_mode = input.bool(false, "Signal on Gap Break (not Touch)", group="Detection", tooltip="OFF (default) = signal fires when price first TOUCHES the gap zone from the correct side (retest entry).\nON = signal fires only after price has entered the zone AND then BREAKS back out through the zone boundary — confirming the zone held.\nBull break: price enters zone then closes > gap zone top.\nBear break: price enters zone then closes < gap zone bottom.\nEntry is fixed at the break level (gap top for bull, bottom for bear).")
use_htf_atr    = input.bool(false,"Use 5-min ATR for Thresholds",   group="Detection")

// ──────────────────────────────────────────────────────────────
//  INPUTS — Visuals
// ──────────────────────────────────────────────────────────────
show_acc_box   = input.bool(true, "Show Consolidation Box",        group="Visuals")
show_manip_lbl = input.bool(true, "Show Sweep Label",              group="Visuals")
show_mss_lbl   = input.bool(true, "Show Structure Break Label + Line", group="Visuals")
show_fvg_box   = input.bool(true, "Show Gap Setup Box",            group="Visuals")
show_ifvg_zone = input.bool(true, "Show Gap Signal Zone",          group="Visuals")
show_dist_lbl  = input.bool(true, "Show Expansion Label",          group="Visuals")

// ──────────────────────────────────────────────────────────────
//  INPUTS — SL / TP
// ──────────────────────────────────────────────────────────────
show_sl_tp    = input.bool(true,  "Show SL / TP Lines",   group="SL/TP")
entry_mode    = input.string("iFVG Mid", "Entry Level",   options=["iFVG Top", "iFVG Mid", "iFVG Bottom"], group="SL/TP")
rr_ratio      = input.float(2.0,  "Risk / Reward Ratio",  minval=0.1, maxval=20.0, group="SL/TP")
sl_buffer_atr = input.float(0.25, "SL Buffer  ATR x",     minval=0.0, maxval=2.0,  group="SL/TP")

// ──────────────────────────────────────────────────────────────
//  INPUTS — Trend Filter
// ──────────────────────────────────────────────────────────────
trend_on      = input.bool(false,    "Enable HTF Trend Filter", group="Trend Filter", tooltip="Start OFF to see all signals.  Enable once comfortable with signal frequency.")
trend_tf      = input.timeframe("D", "Trend Timeframe",         group="Trend Filter")
trend_ema1_ln = input.int(34,  "EMA 1 Length", minval=1, maxval=500, group="Trend Filter")
trend_ema2_ln = input.int(50,  "EMA 2 Length", minval=1, maxval=500, group="Trend Filter")
trend_ema3_ln = input.int(200, "EMA 3 Length", minval=1, maxval=500, group="Trend Filter")

// ──────────────────────────────────────────────────────────────
//  INPUTS — VWAP
// ──────────────────────────────────────────────────────────────
show_vwap      = input.bool(true,  "Show VWAP Line",                   group="VWAP")
show_vwap_band = input.bool(true,  "Show VWAP Bands (+/- 1 and 2 SD)", group="VWAP")
vwap_band_mult = input.float(1.0,  "Band Multiplier", minval=0.1, maxval=5.0, group="VWAP")
vwap_filter    = input.bool(false, "VWAP Signal Filter (long above / short below)", group="VWAP")

// ──────────────────────────────────────────────────────────────
//  ATR
// ──────────────────────────────────────────────────────────────
atr_cur = ta.atr(14)
atr_5m  = request.security(syminfo.tickerid, "5", ta.atr(14))
atr_ref = use_htf_atr ? atr_5m : atr_cur

// ──────────────────────────────────────────────────────────────
//  TREND FILTER
// ──────────────────────────────────────────────────────────────
trend_close = request.security(syminfo.tickerid, trend_tf, close)
trend_e1    = request.security(syminfo.tickerid, trend_tf, ta.ema(close, trend_ema1_ln))
trend_e2    = request.security(syminfo.tickerid, trend_tf, ta.ema(close, trend_ema2_ln))
trend_e3    = request.security(syminfo.tickerid, trend_tf, ta.ema(close, trend_ema3_ln))
trend_up    = trend_close > trend_e1 and trend_close > trend_e2 and trend_close > trend_e3
trend_down  = trend_close < trend_e1 and trend_close < trend_e2 and trend_close < trend_e3

// ──────────────────────────────────────────────────────────────
//  VWAP  (session-anchored, cumulative variance bands)
// ──────────────────────────────────────────────────────────────
vwap_src = hlc3
vwap_val = ta.vwap(vwap_src)
var float _spv  = 0.0
var float _sv   = 0.0
var float _spv2 = 0.0
if ta.change(time("D")) != 0
    _spv  := 0.0
    _sv   := 0.0
    _spv2 := 0.0
_spv  := _spv  + vwap_src * volume
_sv   := _sv   + volume
_spv2 := _spv2 + vwap_src * vwap_src * volume
_vwap2  = _spv / _sv
_var    = (_spv2 / _sv) - (_vwap2 * _vwap2)
_stdev  = math.sqrt(math.max(_var, 0.0))
vwap_u1 = vwap_val + 1.0 * vwap_band_mult * _stdev
vwap_d1 = vwap_val - 1.0 * vwap_band_mult * _stdev
vwap_u2 = vwap_val + 2.0 * vwap_band_mult * _stdev
vwap_d2 = vwap_val - 2.0 * vwap_band_mult * _stdev

allow_bull = (not trend_on or trend_up)   and (not vwap_filter or close > vwap_val)
allow_bear = (not trend_on or trend_down) and (not vwap_filter or close < vwap_val)

// ──────────────────────────────────────────────────────────────
//  VOLUME MA
// ──────────────────────────────────────────────────────────────
vol_ma = ta.sma(volume, vol_ma_len)
vol_ok = not use_vol_filter or volume > vol_ma

// ──────────────────────────────────────────────────────────────
//  STATE MACHINE VARIABLES
// ──────────────────────────────────────────────────────────────
var int   fsm       = 0
var float acc_hi    = na
var float acc_lo    = na
var int   acc_start = na
var int   acc_end   = na
var int   acc_count = 0
var bool  bull_dir  = false
var int   manip_bar = na
var float manip_ext = na
var float mss_lvl   = na
var int   mss_bar   = na
var float ifvg_hi   = na
var float ifvg_lo   = na
var int   ifvg_bar  = na
var box   fvg_box_v   = na
var line  mss_line    = na
var bool  ifvg_touched = false   // true once price has entered the iFVG zone (break mode)

// ── Helper: compute MSS level based on selected mode
get_mss_lvl(is_bull, hi, lo) =>
    mid = (hi + lo) / 2.0
    if mss_mode == "Strict"
        is_bull ? hi : lo
    else if mss_mode == "Basic"
        is_bull ? lo : hi
    else
        mid

// ──────────────────────────────────────────────────────────────
//  DAILY RESET
// ──────────────────────────────────────────────────────────────
if ta.change(time("D")) != 0
    if not na(fvg_box_v)
        box.set_right(fvg_box_v, bar_index)
    if not na(mss_line)
        line.set_x2(mss_line, bar_index)
    fsm       := 0
    acc_hi    := na
    acc_lo    := na
    acc_start := na
    acc_end   := na
    acc_count := 0
    manip_bar := na
    manip_ext := na
    mss_lvl   := na
    mss_bar   := na
    ifvg_hi   := na
    ifvg_lo   := na
    ifvg_bar  := na
    fvg_box_v    := na
    mss_line     := na
    ifvg_touched := false

// ──────────────────────────────────────────────────────────────
//  ROLLING RANGE  (State 0 → 1 trigger)
// ──────────────────────────────────────────────────────────────
roll_hi    = ta.highest(high, accum_len)
roll_lo    = ta.lowest(low,   accum_len)
is_ranging = (roll_hi - roll_lo) < accum_mult * atr_ref

// ──────────────────────────────────────────────────────────────
//  STATE 0 → 1
// ──────────────────────────────────────────────────────────────
if fsm == 0 and is_ranging
    fsm       := 1
    acc_hi    := roll_hi
    acc_lo    := roll_lo
    acc_start := bar_index - accum_len + 1
    acc_end   := bar_index
    acc_count := accum_len

// ──────────────────────────────────────────────────────────────
//  STATE 1  Extend consolidation; detect liquidity sweep spike
//  Good spike  → C box + S label → State 2
//  Poor spike  → absorb into range, remain in State 1
//  Both sides  → ambiguous, reset to State 0
// ──────────────────────────────────────────────────────────────
if fsm == 1
    broke_lo   = low  < acc_lo - manip_pct * atr_ref
    broke_hi   = high > acc_hi + manip_pct * atr_ref
    both_sides = broke_lo and broke_hi
    c_rng      = math.max(high - low, 0.0001)
    wick_bull  = (close - low)  / c_rng >= manip_wick_min
    wick_bear  = (high - close) / c_rng >= manip_wick_min

    if not broke_lo and not broke_hi
        acc_hi    := math.max(acc_hi, high)
        acc_lo    := math.min(acc_lo, low)
        acc_end   := bar_index
        acc_count += 1

    else if broke_lo and not both_sides
        if wick_bull and vol_ok
            bull_dir  := true
            manip_bar := bar_index
            manip_ext := low
            mss_lvl   := get_mss_lvl(true, acc_hi, acc_lo)
            fsm       := 2
            if show_acc_box
                box.new(acc_start, acc_hi, acc_end, acc_lo, bgcolor=color.new(color.blue, 88), border_color=color.new(color.blue, 40), border_width=1)
                label.new(acc_start, acc_hi, "C", style=label.style_label_right, color=color.new(color.blue, 40), textcolor=color.white, size=size.small)
            if show_manip_lbl
                label.new(bar_index, low, "S", style=label.style_label_up, color=color.orange, textcolor=color.white, size=size.small)
        else
            acc_lo    := math.min(acc_lo, low)
            acc_hi    := math.max(acc_hi, high)
            acc_end   := bar_index
            acc_count += 1

    else if broke_hi and not both_sides
        if wick_bear and vol_ok
            bull_dir  := false
            manip_bar := bar_index
            manip_ext := high
            mss_lvl   := get_mss_lvl(false, acc_hi, acc_lo)
            fsm       := 2
            if show_acc_box
                box.new(acc_start, acc_hi, acc_end, acc_lo, bgcolor=color.new(color.blue, 88), border_color=color.new(color.blue, 40), border_width=1)
                label.new(acc_start, acc_hi, "C", style=label.style_label_right, color=color.new(color.blue, 40), textcolor=color.white, size=size.small)
            if show_manip_lbl
                label.new(bar_index, high, "S", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.small)
        else
            acc_lo    := math.min(acc_lo, low)
            acc_hi    := math.max(acc_hi, high)
            acc_end   := bar_index
            acc_count += 1
    else
        fsm := 0

// ──────────────────────────────────────────────────────────────
//  STATE 2  Wait for Structure Break
//
//  Break level is set by mss_mode:
//    Strict   → acc_hi (bull) / acc_lo (bear)
//    Midpoint → (acc_hi + acc_lo) / 2
//    Basic    → acc_lo (bull) / acc_hi (bear)
//
//  Timeout is configurable via mss_timeout input.
// ──────────────────────────────────────────────────────────────
if fsm == 2
    mss_hit = bull_dir ? close > mss_lvl : close < mss_lvl
    if mss_hit
        mss_bar := bar_index
        fsm     := 3
        if show_mss_lbl
            mss_line := line.new(bar_index, mss_lvl, bar_index + 40, mss_lvl, color=color.new(color.teal, 20), style=line.style_dashed, width=1)
            label.new(bar_index, mss_lvl, "Break", style=bull_dir ? label.style_label_up : label.style_label_down, color=color.teal, textcolor=color.white, size=size.small)

    if not na(manip_bar) and bar_index - manip_bar > mss_timeout
        fsm       := 0
        manip_bar := na
        manip_ext := na
        mss_lvl   := na

// ──────────────────────────────────────────────────────────────
//  STATE 3  Seek Price Imbalance Gap Zone
//
//  The gap zone is a 3-bar price imbalance formed in the expansion
//  direction after the structure break.
//  Displacement check (when enabled) looks at bar[0] OR bar[1]:
//    Case A: bar[-2] setup, bar[-1] displacement, bar[0] seals gap
//    Case B: bar[-2] setup, bar[-1] any,          bar[0] displacement + gap
//
//  Bull gap: low[0] > high[2]
//  Bear gap: high[0] < low[2]
// ──────────────────────────────────────────────────────────────
bars_since_mss = na(mss_bar) ? 999 : bar_index - mss_bar

if fsm == 3
    body0     = math.abs(close - open)
    rng0      = math.max(high  - low,  0.0001)
    body1     = math.abs(close[1] - open[1])
    rng1      = math.max(high[1]  - low[1], 0.0001)
    disp_bull = not require_disp or (bull_dir     and ((close > open     and body0 / rng0 >= disp_body_min) or (close[1] > open[1] and body1 / rng1 >= disp_body_min)))
    disp_bear = not require_disp or (not bull_dir and ((close < open     and body0 / rng0 >= disp_body_min) or (close[1] < open[1] and body1 / rng1 >= disp_body_min)))

    b_gap = low   - high[2]
    s_gap = low[2] - high
    b_ok  = b_gap >= min_fvg_gap * atr_ref and bull_dir     and disp_bull and bars_since_mss >= 1
    s_ok  = s_gap >= min_fvg_gap * atr_ref and not bull_dir and disp_bear and bars_since_mss >= 1

    if b_ok
        ifvg_hi      := low
        ifvg_lo      := high[2]
        ifvg_bar     := bar_index
        ifvg_touched := false
        fsm          := 4
        if show_fvg_box
            fvg_box_v := box.new(bar_index - 2, ifvg_hi, bar_index + 60, ifvg_lo, bgcolor=color.new(color.lime, 83), border_color=color.new(color.lime, 40), border_width=1)
            label.new(bar_index, ifvg_lo, "Gap", style=label.style_label_up, color=color.new(color.lime, 25), textcolor=color.white, size=size.tiny)

    else if s_ok
        ifvg_hi      := low[2]
        ifvg_lo      := high
        ifvg_bar     := bar_index
        ifvg_touched := false
        fsm          := 4
        if show_fvg_box
            fvg_box_v := box.new(bar_index - 2, ifvg_hi, bar_index + 60, ifvg_lo, bgcolor=color.new(color.red, 83), border_color=color.new(color.red, 40), border_width=1)
            label.new(bar_index, ifvg_hi, "Gap", style=label.style_label_down, color=color.new(color.red, 25), textcolor=color.white, size=size.tiny)

if fsm == 3 and bars_since_mss > fvg_bars
    fsm := 0

// ──────────────────────────────────────────────────────────────
//  STATE 4  Gap Zone Retest + Zone Upgrade
//
//  Retest conditions:
//    Bull: close[1] >= ifvg_lo  (was above zone bottom — relaxed from v5)
//          low      <= ifvg_hi  (bar touches zone from above)
//          close    >= ifvg_lo  (bar holds zone as support)
//
//    Bear: close[1] <= ifvg_hi  (was below zone top — relaxed from v5)
//          high     >= ifvg_lo  (bar touches zone from below)
//          close    <= ifvg_hi  (bar holds zone as resistance)
//
//  Zone upgrade: if a WIDER gap forms in the same direction
//  while waiting for the retest, update to the better zone.
//  The gap box is redrawn to reflect the upgrade.
// ──────────────────────────────────────────────────────────────
bars_since_ifvg = na(ifvg_bar) ? 999 : bar_index - ifvg_bar

// ── Zone upgrade check (state 4 only)
if fsm == 4
    body0u    = math.abs(close - open)
    rng0u     = math.max(high  - low,  0.0001)
    body1u    = math.abs(close[1] - open[1])
    rng1u     = math.max(high[1]  - low[1], 0.0001)
    disp_u_bull = not require_disp or (bull_dir     and ((close > open     and body0u / rng0u >= disp_body_min) or (close[1] > open[1] and body1u / rng1u >= disp_body_min)))
    disp_u_bear = not require_disp or (not bull_dir and ((close < open     and body0u / rng0u >= disp_body_min) or (close[1] < open[1] and body1u / rng1u >= disp_body_min)))

    new_b_gap = low   - high[2]
    new_s_gap = low[2] - high
    new_b_ok  = new_b_gap >= min_fvg_gap * atr_ref and bull_dir     and disp_u_bull and new_b_gap > (ifvg_hi - ifvg_lo)
    new_s_ok  = new_s_gap >= min_fvg_gap * atr_ref and not bull_dir and disp_u_bear and new_s_gap > (ifvg_hi - ifvg_lo)

    if new_b_ok
        ifvg_hi      := low
        ifvg_lo      := high[2]
        ifvg_bar     := bar_index
        ifvg_touched := false
        if not na(fvg_box_v)
            box.set_top(fvg_box_v,    ifvg_hi)
            box.set_bottom(fvg_box_v, ifvg_lo)
            box.set_left(fvg_box_v,   bar_index - 2)
            box.set_right(fvg_box_v,  bar_index + 60)

    else if new_s_ok
        ifvg_hi      := low[2]
        ifvg_lo      := high
        ifvg_bar     := bar_index
        ifvg_touched := false
        if not na(fvg_box_v)
            box.set_top(fvg_box_v,    ifvg_hi)
            box.set_bottom(fvg_box_v, ifvg_lo)
            box.set_left(fvg_box_v,   bar_index - 2)
            box.set_right(fvg_box_v,  bar_index + 60)

// ── VWAP zone-position filter
//    The original allow_bull/bear checked close vs VWAP at retest time,
//    but that allowed a bearish zone sitting ABOVE VWAP to fire a short
//    signal when price retested from below — a counter-trend entry.
//
//    Fix: the GAP ZONE ITSELF must be on the correct side of VWAP.
//      Bull: ifvg_lo > vwap_val  — bottom of zone is above VWAP
//      Bear: ifvg_hi < vwap_val  — top   of zone is below VWAP
//    When vwap_filter is OFF this check is skipped (passes through).
vwap_zone_bull = not vwap_filter or (not na(ifvg_lo) and ifvg_lo > vwap_val)
vwap_zone_bear = not vwap_filter or (not na(ifvg_hi) and ifvg_hi < vwap_val)

// ── Track zone touches (break mode only)
if fsm == 4 and ifvg_break_mode and not ifvg_touched
    if bull_dir     and low  <= ifvg_hi
        ifvg_touched := true
    if not bull_dir and high >= ifvg_lo
        ifvg_touched := true

// ── Retest mode (default): signal on the first qualifying touch from the correct side
//    close[1] >= ifvg_lo = previous bar was above the gap zone bottom (outside / above)
//    low      <= ifvg_hi = current bar enters the zone from above
//    close    >= ifvg_lo = current bar closes without breaking through the zone bottom
bull_retest = not ifvg_break_mode and fsm == 4 and bull_dir and bars_since_ifvg >= 1 and bars_since_ifvg <= ifvg_bars and close[1] >= ifvg_lo and low <= ifvg_hi and close >= ifvg_lo and allow_bull and vwap_zone_bull
bear_retest = not ifvg_break_mode and fsm == 4 and not bull_dir and bars_since_ifvg >= 1 and bars_since_ifvg <= ifvg_bars and close[1] <= ifvg_hi and high >= ifvg_lo and close <= ifvg_hi and allow_bear and vwap_zone_bear

// ── Break mode: signal fires only AFTER a zone touch, when price closes back through
//    the zone boundary in the expansion direction — confirming the zone held.
//    Bull break: price touched zone (ifvg_touched) then closes > gap zone top
//    Bear break: price touched zone (ifvg_touched) then closes < gap zone bottom
//    Entry is fixed at the break level (gap top bull / gap bottom bear) regardless of entry_mode.
bull_break = ifvg_break_mode and fsm == 4 and bull_dir and ifvg_touched and bars_since_ifvg >= 1 and bars_since_ifvg <= ifvg_bars and close > ifvg_hi and allow_bull and vwap_zone_bull
bear_break = ifvg_break_mode and fsm == 4 and not bull_dir and ifvg_touched and bars_since_ifvg >= 1 and bars_since_ifvg <= ifvg_bars and close < ifvg_lo and allow_bear and vwap_zone_bear

bull_sig = bull_retest or bull_break
bear_sig = bear_retest or bear_break

// ── State 4 timeout
if fsm == 4 and bars_since_ifvg > ifvg_bars
    if not na(fvg_box_v)
        box.set_right(fvg_box_v, bar_index)
    fsm          := 0
    ifvg_hi      := na
    ifvg_lo      := na
    ifvg_bar     := na
    ifvg_touched := false

// ──────────────────────────────────────────────────────────────
//  PERSISTENT SL/TP LINES
// ──────────────────────────────────────────────────────────────
EXTEND = 25

var line  ln_entry = na
var line  ln_sl    = na
var line  ln_tp    = na
var label lb_entry = na
var label lb_sl    = na
var label lb_tp    = na

clear_levels() =>
    if not na(ln_entry)
        line.delete(ln_entry)
    if not na(ln_sl)
        line.delete(ln_sl)
    if not na(ln_tp)
        line.delete(ln_tp)
    if not na(lb_entry)
        label.delete(lb_entry)
    if not na(lb_sl)
        label.delete(lb_sl)
    if not na(lb_tp)
        label.delete(lb_tp)

// ──────────────────────────────────────────────────────────────
//  BULLISH SIGNAL
// ──────────────────────────────────────────────────────────────
if bull_sig
    ifvg_mid = (ifvg_hi + ifvg_lo) / 2.0
    float entry = na
    if ifvg_break_mode
        entry := ifvg_hi   // break mode: always enter at the level just broken (gap zone top)
    else if entry_mode == "iFVG Top"
        entry := ifvg_hi
    else if entry_mode == "iFVG Bottom"
        entry := ifvg_lo
    else
        entry := ifvg_mid
    sl   = math.min(manip_ext, ifvg_lo) - sl_buffer_atr * atr_ref
    risk = math.abs(entry - sl)
    tp   = entry + risk * rr_ratio
    if not na(fvg_box_v)
        box.set_right(fvg_box_v, bar_index)
    if show_ifvg_zone
        box.new(bar_index, ifvg_hi, bar_index + EXTEND, ifvg_lo, bgcolor=color.new(color.lime, 58), border_color=color.lime, border_width=2)
        label.new(bar_index, ifvg_lo, "Gap Long", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.small)
    if show_sl_tp
        clear_levels()
        ln_entry := line.new(bar_index, entry, bar_index + 1, entry, color=color.yellow, style=line.style_dotted, width=1, extend=extend.right)
        ln_sl    := line.new(bar_index, sl,    bar_index + 1, sl,    color=color.red,    style=line.style_dashed, width=2, extend=extend.right)
        ln_tp    := line.new(bar_index, tp,    bar_index + 1, tp,    color=color.green,  style=line.style_dashed, width=2, extend=extend.right)
        lb_entry := label.new(bar_index, entry, "Long Entry " + str.tostring(entry, "#.##"),                                       style=label.style_label_right, color=color.yellow, textcolor=color.black, size=size.small)
        lb_sl    := label.new(bar_index, sl,    "Long SL "    + str.tostring(sl,    "#.##"),                                       style=label.style_label_right, color=color.red,    textcolor=color.white, size=size.small)
        lb_tp    := label.new(bar_index, tp,    "Long TP "    + str.tostring(rr_ratio, "#.##") + "R  " + str.tostring(tp, "#.##"), style=label.style_label_right, color=color.green,  textcolor=color.white, size=size.small)
    if show_dist_lbl
        label.new(bar_index + 2, ifvg_hi, "D", style=label.style_label_down, color=color.new(color.lime, 20), textcolor=color.white, size=size.small)
    ifvg_touched := false
    fsm          := 0

// ──────────────────────────────────────────────────────────────
//  BEARISH SIGNAL
// ──────────────────────────────────────────────────────────────
if bear_sig
    ifvg_mid = (ifvg_hi + ifvg_lo) / 2.0
    float entry = na
    if ifvg_break_mode
        entry := ifvg_lo   // break mode: always enter at the level just broken (gap zone bottom)
    else if entry_mode == "iFVG Bottom"
        entry := ifvg_lo
    else if entry_mode == "iFVG Top"
        entry := ifvg_hi
    else
        entry := ifvg_mid
    sl   = math.max(manip_ext, ifvg_hi) + sl_buffer_atr * atr_ref
    risk = math.abs(sl - entry)
    tp   = entry - risk * rr_ratio
    if not na(fvg_box_v)
        box.set_right(fvg_box_v, bar_index)
    if show_ifvg_zone
        box.new(bar_index, ifvg_hi, bar_index + EXTEND, ifvg_lo, bgcolor=color.new(color.red, 58), border_color=color.red, border_width=2)
        label.new(bar_index, ifvg_hi, "Gap Short", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    if show_sl_tp
        clear_levels()
        ln_entry := line.new(bar_index, entry, bar_index + 1, entry, color=color.yellow, style=line.style_dotted, width=1, extend=extend.right)
        ln_sl    := line.new(bar_index, sl,    bar_index + 1, sl,    color=color.red,    style=line.style_dashed, width=2, extend=extend.right)
        ln_tp    := line.new(bar_index, tp,    bar_index + 1, tp,    color=color.green,  style=line.style_dashed, width=2, extend=extend.right)
        lb_entry := label.new(bar_index, entry, "Short Entry " + str.tostring(entry, "#.##"),                                        style=label.style_label_right, color=color.yellow, textcolor=color.black, size=size.small)
        lb_sl    := label.new(bar_index, sl,    "Short SL "    + str.tostring(sl,    "#.##"),                                        style=label.style_label_right, color=color.red,    textcolor=color.white, size=size.small)
        lb_tp    := label.new(bar_index, tp,    "Short TP "    + str.tostring(rr_ratio, "#.##") + "R  " + str.tostring(tp, "#.##"), style=label.style_label_right, color=color.green,  textcolor=color.white, size=size.small)
    if show_dist_lbl
        label.new(bar_index + 2, ifvg_lo, "D", style=label.style_label_up, color=color.new(color.red, 20), textcolor=color.white, size=size.small)
    ifvg_touched := false
    fsm          := 0

// ──────────────────────────────────────────────────────────────
//  SIGNAL SHAPES
// ──────────────────────────────────────────────────────────────
plotshape(bull_sig, "Bull Cycle Gap Entry", shape.triangleup,   location.belowbar, color.lime, size=size.normal)
plotshape(bear_sig, "Bear Cycle Gap Entry", shape.triangledown, location.abovebar, color.red,  size=size.normal)

// ──────────────────────────────────────────────────────────────
//  VWAP PLOTS
// ──────────────────────────────────────────────────────────────
plot(show_vwap      ? vwap_val : na, "VWAP",    color=color.new(color.white,   0), linewidth=2, style=plot.style_line)
plot(show_vwap_band ? vwap_u1  : na, "VWAP +1", color=color.new(color.aqua,   30), linewidth=1, style=plot.style_line)
plot(show_vwap_band ? vwap_d1  : na, "VWAP -1", color=color.new(color.aqua,   30), linewidth=1, style=plot.style_line)
plot(show_vwap_band ? vwap_u2  : na, "VWAP +2", color=color.new(color.purple, 30), linewidth=1, style=plot.style_line)
plot(show_vwap_band ? vwap_d2  : na, "VWAP -2", color=color.new(color.purple, 30), linewidth=1, style=plot.style_line)

// ──────────────────────────────────────────────────────────────
//  GAP ZONE CREATION ALERTS
//  Fires on the exact bar where the gap zone is first established
//  (state 3 → 4 transition, bars_since_ifvg == 0).
//  Also fires when the zone upgrades to a wider gap in state 4.
//  Use these to be notified early — BEFORE the entry signal fires.
//
//  FIX: allow_bull / allow_bear are now included so that gap zone
//  creation alerts respect the VWAP filter and trend filter exactly
//  the same way the entry signals do.  Previously these fired
//  regardless of filter state, making it appear signals were
//  bypassing the VWAP filter.
// ──────────────────────────────────────────────────────────────
bull_ifvg_created = fsm == 4 and bull_dir     and bars_since_ifvg == 0 and allow_bull and vwap_zone_bull
bear_ifvg_created = fsm == 4 and not bull_dir and bars_since_ifvg == 0 and allow_bear and vwap_zone_bear

// ──────────────────────────────────────────────────────────────
//  ALERTS
// ──────────────────────────────────────────────────────────────
alertcondition(bull_ifvg_created, "Bull Gap Zone Created", "Bullish gap zone created — watch for retest to enter long")
alertcondition(bear_ifvg_created, "Bear Gap Zone Created", "Bearish gap zone created — watch for retest to enter short")
alertcondition(bull_sig, "Bull Cycle Gap Entry", "Bullish cycle gap retest — Long entry signal confirmed")
alertcondition(bear_sig, "Bear Cycle Gap Entry", "Bearish cycle gap retest — Short entry signal confirmed")
````
