# Liquidity Sweep + FVG [Leon/RussellTech] v2

- url: https://www.tradingview.com/script/66xSzCz9-Liquidity-Sweep-FVG-Leon-RussellTech-v2/
- type: indicator
- pine_id: PUB;88056623b7fe472bb6cdb5f7ffa8231a
- version: 1.0

## Description

[b]Liquidity Sweep + FVG Indicator[/b]
A multi-confluence day-trading indicator that identifies institutional stop-hunts (liquidity sweeps) followed by displacement Fair Value Gaps, then plans precise entries with automatic stop-loss and take-profit placement.

[b]How It Works[/b]
The indicator uses a state machine that progresses through a strict sequence. Every signal must pass through all 7 confluence layers — if any single layer fails, no signal fires. This is what prevents false signals and maintains quality.

[b]State Machine Lifecycle[/b]
Idle — The indicator monitors swing pivot highs and lows using the configured lookback period. Up to 4 recent levels are tracked.
Sweep Detected — Price wicks beyond a tracked swing level and (if required) closes back inside. A sweep marker (▲ or ▼) appears on the chart.
Armed — Within the Sweep→FVG Window (10 bars), a valid FVG forms in the sweep direction. The status panel shows "armed (long)" or "armed (short)".
Entry — Within the FVG→Entry Window (24 bars), price retraces into the FVG zone, the entry candle shows momentum, and all filters pass. Signal fires with Entry, SL, and TP drawn.
Tracking — The indicator tracks whether price hits the TP, SL, or times out, then returns to Idle.

[b]The 7 Confluence Layers[/b]
Every signal must pass through all seven layers. This multi-confluence approach is what separates this indicator from simple FVG detectors or sweep scanners.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Liquidity Sweep + FVG  [Leon/RussellTech]  —  INDICATOR v2 (discretionary)
//
// Same logic as the v2 STRATEGY, but as a decision-aid: it detects setups, draws
// the trade plan, shows the multi-timeframe picture, and fires alerts — it does
// NOT place or simulate orders. This is the day-to-day, top-down tool.
//
// THE MODEL:
//   1. SWEEP      price wicks BEYOND a prior swing (hunts stops) then closes back.
//   2. DISPLACE   a strong move the other way leaves a Fair Value Gap.
//   3. ENTER      on the retrace into that FVG, in the reversal direction.
//   4. TARGET     the opposite liquidity pool.  STOP = beyond the sweep extreme.
//   + Session (killzone) filter, and a MTF dashboard + HTF levels for top-down.
//
// Every signal is "a setup to EVALUATE," not "an order to take." The automated
// edge is unproven — you are the filter. Use the dashboard/HTF context to judge.
// ─────────────────────────────────────────────────────────────────────────────
indicator("Liquidity Sweep + FVG [Leon/RussellTech] v2", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ── INPUTS ───────────────────────────────────────────────────────────────────
grp_liq = "Liquidity / Structure"
liq_show  = input.bool(true, "Show Liquidity Levels", group=grp_liq)
liq_lb    = input.int(5, "Swing Lookback", group=grp_liq, minval=2, maxval=20,
             tooltip="Pivot strength for swing highs/lows. These swings are the liquidity pools (where stops rest). 5 = 4H default.")

grp_sweep = "Sweep Trigger"
require_close_back = input.bool(true, "Require Close Back Inside", group=grp_sweep,
             tooltip="ON (recommended): the sweep candle must wick beyond the swing but CLOSE back inside it — a rejected stop-run. OFF: any wick beyond counts (weaker).")
sweep_window = input.int(10, "Sweep→FVG Window (bars)", group=grp_sweep, minval=1, maxval=30,
             tooltip="How many bars after a sweep a displacement FVG must form to arm the setup.")
entry_window = input.int(24, "FVG→Entry Window (bars)", group=grp_sweep, minval=1, maxval=50,
             tooltip="How many bars an armed setup waits for price to retrace into the FVG before it expires.")

grp_fvg = "Fair Value Gap (displacement)"
fvg_show     = input.bool(true, "Show FVGs", group=grp_fvg)
fvg_min_atr  = input.float(0.15, "Min FVG Size (ATR mult)", group=grp_fvg, step=0.05, minval=0.0,
              tooltip="Minimum displacement-gap size as a fraction of ATR(14). Portable across instruments.")
fvg_max_atr  = input.float(3.0,  "Max FVG Size (ATR mult, 0=off)", group=grp_fvg, step=0.25, minval=0.0,
              tooltip="Reject oversized news-spike gaps. 0 = unlimited.")
momentum_pct = input.float(0.25, "Entry Momentum Body %", group=grp_fvg, step=0.05, minval=0.1, maxval=0.9,
              tooltip="The retrace/entry candle body must be at least this fraction of its range, closing in trade direction.")
near_miss_pct = input.float(0.25, "Near-Miss Tolerance %", group=grp_fvg, step=0.05, minval=0.0, maxval=1.0,
              tooltip="Expand the FVG touch zone by this % of the gap on each edge.")

grp_entry = "Entry / Plan"
entry_mode = input.string("Limit at FVG Edge", "Planned Entry", options=["Market on Close", "Limit at FVG Edge"], group=grp_entry,
              tooltip="Where the planned entry is drawn. Limit at FVG Edge sits inside the gap for a better price.")
limit_fill_pct = input.float(0.5, "Entry Depth % (of FVG)", group=grp_entry, step=0.1, minval=0.0, maxval=1.0,
              tooltip="0 = proximal edge, 1 = far edge (best price), 0.5 = midpoint.")
target_mode = input.string("Opposite Liquidity", "Target", options=["Opposite Liquidity", "Fixed R:R"], group=grp_entry,
              tooltip="Opposite Liquidity = aim for the nearest opposite swing; falls back to Fixed R:R if none is beyond the min. Fixed R:R = always use the R multiple below.")
target_rr = input.float(2.0, "Target R:R (fixed / fallback)", group=grp_entry, step=0.25, minval=0.5)
stop_buf_atr = input.float(0.1, "Stop Buffer (ATR mult)", group=grp_entry, step=0.05, minval=0.0,
              tooltip="Extra distance beyond the sweep extreme for the stop, in ATR.")
use_atr_sl = input.bool(true, "Cap Risk to ATR", group=grp_entry,
              tooltip="Skip setups whose stop distance exceeds the ATR multiple below.")
atr_sl_mult = input.float(2.0, "Max Risk (ATR mult)", group=grp_entry, step=0.1, minval=0.5, maxval=5.0)
use_breakeven = input.bool(false, "Break-Even in plan tracking", group=grp_entry,
              tooltip="Move the tracked stop to entry once price reaches the BE R:R (affects when a tracked setup clears).")
be_rr = input.float(1.0, "Break-Even at R:R", group=grp_entry, step=0.25, minval=0.25)
use_time_stop = input.bool(true, "Clear stale setup after N bars", group=grp_entry,
              tooltip="Stop tracking a setup after N bars so a new one can arm.")
max_bars = input.int(16, "Max Bars to Track", group=grp_entry, minval=2, step=2)

grp_sess = "Session Filter"
use_session = input.bool(true, "Only Signal in Killzones", group=grp_sess,
              tooltip="ON: only fire signals inside the session window below (London/NY). OFF: 24h.")
sess_str = input.session("0200-1500", "Killzone (exchange time)", group=grp_sess,
              tooltip="Default 02:00–15:00 New York time ≈ London open through NY afternoon close.")
sess_tz = input.string("America/New_York", "Session Timezone", group=grp_sess)

grp_flt = "Optional Filters"
use_htf_bias = input.bool(false, "HTF Trend Filter", group=grp_flt,
              tooltip="OFF by default (a sweep is often counter-trend). ON: only longs above the MA / shorts below.")
htf_ma_len = input.int(50, "Trend MA Period", group=grp_flt, minval=10, maxval=500)

grp_disp = "Display"
show_markers = input.bool(true, "Show Signal Markers", group=grp_disp)
show_sweeps  = input.bool(true, "Show Sweep Markers", group=grp_disp)
ladder_len   = input.int(24, "Trade Level Length (bars)", group=grp_disp, minval=4, step=2)
max_setups   = input.int(20, "Max Ladders to Keep", group=grp_disp, minval=1, maxval=60)
show_zones   = input.bool(true, "Show R/R Zones (shaded)", group=grp_disp)
show_status  = input.bool(true, "Show Status Panel", group=grp_disp)

grp_col = "Colors"
col_bull_fvg = input.color(color.new(#00C853, 80), "Bullish FVG",  group=grp_col)
col_bear_fvg = input.color(color.new(#FF1744, 80), "Bearish FVG",  group=grp_col)
col_liq_h    = input.color(color.new(#FFD600, 70), "Liq High",     group=grp_col)
col_liq_l    = input.color(color.new(#29B6F6, 70), "Liq Low",      group=grp_col)
col_entry    = input.color(#00E676,                "Entry",        group=grp_col)
col_sl       = input.color(#FF1744,                "Stop Loss",    group=grp_col)
col_tp       = input.color(#00BCD4,                "Target",       group=grp_col)
col_risk_z   = input.color(color.new(#FF1744, 88), "Risk Zone",    group=grp_col)
col_rew_z    = input.color(color.new(#00E676, 90), "Reward Zone",  group=grp_col)
col_htf_h        = input.color(color.new(#FF6D00, 20), "HTF Liq High",  group=grp_col)
col_htf_l        = input.color(color.new(#2979FF, 20), "HTF Liq Low",   group=grp_col)
col_htf_bull_fvg = input.color(color.new(#00C853, 88), "HTF Bull FVG",  group=grp_col)
col_htf_bear_fvg = input.color(color.new(#FF1744, 88), "HTF Bear FVG",  group=grp_col)

grp_mtf = "Multi-Timeframe (top-down)"
show_dashboard  = input.bool(true, "Show MTF Bias Dashboard", group=grp_mtf,
                   tooltip="Table (top-left) showing trend bias + recent sweep direction for 15m/30m/1h/4h/1D at once. Non-repainting.")
show_htf_levels = input.bool(true, "Show HTF Liquidity Levels", group=grp_mtf,
                   tooltip="Overlay the higher-timeframe swing highs/lows on THIS chart.")
show_htf_fvg    = input.bool(true, "Show HTF FVG Zones", group=grp_mtf,
                   tooltip="Shade the most recent unfilled higher-timeframe FVGs on this chart.")
auto_htf        = input.bool(true, "Auto-Pick HTF", group=grp_mtf,
                   tooltip="ON: HTF = one major step above the chart (≤15m→1H, ≤1H→4H, ≤4H→D, else W). OFF: manual below.")
htf_manual      = input.timeframe("240", "Manual HTF", group=grp_mtf)
dash_ma         = input.int(50, "Dashboard Bias MA", group=grp_mtf, minval=5)

// ── TIMEFRAME AUTO-SCALING ────────────────────────────────────────────────────
tf_min   = timeframe.in_seconds() / 60
tf_ratio = 240.0 / math.max(1, tf_min)
eff_liq_lb = int(math.max(2, math.min(20, math.round(liq_lb * math.pow(tf_ratio, 0.3)))))
eff_htf_ma = int(math.max(10, math.min(500, math.round(htf_ma_len * tf_ratio))))

// ── ATR & TREND ──────────────────────────────────────────────────────────────
atr14   = ta.atr(14)
htf_ma  = ta.sma(close, eff_htf_ma)
above_ma = close > htf_ma
below_ma = close < htf_ma
in_session = not use_session or not na(time(timeframe.period, sess_str, sess_tz))

// ── MULTI-TIMEFRAME (top-down) ───────────────────────────────────────────────
htf_tf = auto_htf ? (tf_min <= 15 ? "60" : tf_min <= 60 ? "240" : tf_min <= 240 ? "D" : "W") : htf_manual

f_tf_state(malen, lb, win) =>
    biasbull = close > ta.sma(close, malen)
    sh = ta.pivothigh(high, lb, lb)
    sl = ta.pivotlow(low, lb, lb)
    var float lh = na
    var float ll = na
    if not na(sh)
        lh := sh
    if not na(sl)
        ll := sl
    bswp = not na(ll) and low < ll and close > ll
    sswp = not na(lh) and high > lh and close < lh
    var int lastb = na
    var int dr = 0
    if bswp
        lastb := bar_index
        dr := 1
    if sswp
        lastb := bar_index
        dr := -1
    swp = (not na(lastb) and (bar_index - lastb) <= win) ? dr : 0
    [biasbull, swp]

f_htf_swings(lb) =>
    sh = ta.pivothigh(high, lb, lb)
    sl = ta.pivotlow(low, lb, lb)
    var float lh = na
    var float ll = na
    if not na(sh)
        lh := sh
    if not na(sl)
        ll := sl
    [lh, ll]

f_htf_fvg() =>
    bg = low - high[2]
    sg = low[2] - high
    var float bt = na
    var float bb = na
    var float st = na
    var float sb = na
    if bg > 0
        bt := low
        bb := high[2]
    if not na(bb) and close < bb
        bt := na
        bb := na
    if sg > 0
        st := low[2]
        sb := high
    if not na(st) and close > st
        st := na
        sb := na
    [bt, bb, st, sb]

[b15, s15]   = request.security(syminfo.tickerid, "15",  f_tf_state(dash_ma, 5, 8), lookahead=barmerge.lookahead_off)
[b30, s30]   = request.security(syminfo.tickerid, "30",  f_tf_state(dash_ma, 5, 8), lookahead=barmerge.lookahead_off)
[b60, s60]   = request.security(syminfo.tickerid, "60",  f_tf_state(dash_ma, 5, 8), lookahead=barmerge.lookahead_off)
[b240, s240] = request.security(syminfo.tickerid, "240", f_tf_state(dash_ma, 5, 8), lookahead=barmerge.lookahead_off)
[bD, sD]     = request.security(syminfo.tickerid, "D",   f_tf_state(dash_ma, 5, 8), lookahead=barmerge.lookahead_off)

[hLevH, hLevL]       = request.security(syminfo.tickerid, htf_tf, f_htf_swings(liq_lb), lookahead=barmerge.lookahead_off)
[hbt, hbb, hst, hsb] = request.security(syminfo.tickerid, htf_tf, f_htf_fvg(),          lookahead=barmerge.lookahead_off)

plot(show_htf_levels ? hLevH : na, "HTF Liq High", color=col_htf_h, linewidth=2, style=plot.style_linebr)
plot(show_htf_levels ? hLevL : na, "HTF Liq Low",  color=col_htf_l, linewidth=2, style=plot.style_linebr)
pbt = plot(show_htf_fvg ? hbt : na, "HTF Bull FVG Top", color=na)
pbb = plot(show_htf_fvg ? hbb : na, "HTF Bull FVG Bot", color=na)
fill(pbt, pbb, color=col_htf_bull_fvg, title="HTF Bull FVG")
pst = plot(show_htf_fvg ? hst : na, "HTF Bear FVG Top", color=na)
psb = plot(show_htf_fvg ? hsb : na, "HTF Bear FVG Bot", color=na)
fill(pst, psb, color=col_htf_bear_fvg, title="HTF Bear FVG")

// ── LIQUIDITY (swing pivots) — MULTI-LEVEL ───────────────────────────────────
// Track up to 4 recent swing highs and lows so sweeps of older levels
// are not missed. Also keep last_swing_h/l for backward-compatible targeting.
swingH = ta.pivothigh(high, eff_liq_lb, eff_liq_lb)
swingL = ta.pivotlow(low,  eff_liq_lb, eff_liq_lb)

MAX_SWINGS = 4
var float[] swing_highs = array.new_float(0)
var float[] swing_lows  = array.new_float(0)
var float last_swing_h = na
var float last_swing_l = na
if not na(swingH)
    last_swing_h := swingH
    // avoid duplicates (same level from consecutive pivots)
    if array.size(swing_highs) == 0 or math.abs(nz(array.get(swing_highs, array.size(swing_highs) - 1)) - swingH) > atr14 * 0.05
        array.push(swing_highs, swingH)
        if array.size(swing_highs) > MAX_SWINGS
            array.shift(swing_highs)
if not na(swingL)
    last_swing_l := swingL
    if array.size(swing_lows) == 0 or math.abs(nz(array.get(swing_lows, array.size(swing_lows) - 1)) - swingL) > atr14 * 0.05
        array.push(swing_lows, swingL)
        if array.size(swing_lows) > MAX_SWINGS
            array.shift(swing_lows)

var line[]  liq_lines  = array.new_line()
var label[] liq_labels = array.new_label()
MAX_LIQ = 16
if not na(swingH) and liq_show
    ln = line.new(bar_index[eff_liq_lb], swingH, bar_index + 10, swingH, color=col_liq_h, width=1, style=line.style_dashed)
    lb = label.new(bar_index[eff_liq_lb], swingH, "LIQ H", color=color.new(#FFD600, 60), textcolor=#000000, size=size.tiny, style=label.style_label_right)
    array.push(liq_lines, ln)
    array.push(liq_labels, lb)
if not na(swingL) and liq_show
    ln = line.new(bar_index[eff_liq_lb], swingL, bar_index + 10, swingL, color=col_liq_l, width=1, style=line.style_dashed)
    lb = label.new(bar_index[eff_liq_lb], swingL, "LIQ L", color=color.new(#29B6F6, 60), textcolor=#000000, size=size.tiny, style=label.style_label_right)
    array.push(liq_lines, ln)
    array.push(liq_labels, lb)
if array.size(liq_lines) > MAX_LIQ
    line.delete(array.shift(liq_lines))
    label.delete(array.shift(liq_labels))

// ── SWEEP DETECTION — MULTI-LEVEL + DELAYED CLOSE-BACK ──────────────────────
// Change 2 + Change 4: Check sweep against ALL stored swing levels (not just
// the last one). Also detect delayed close-back: if the prior bar broke the
// level and the current bar closes back inside, that counts as a valid sweep.

// Helper: check if price swept any swing low (bullish sweep)
f_any_swept_low() =>
    swept = false
    swept_price = float(na)
    if array.size(swing_lows) > 0
        for i = 0 to array.size(swing_lows) - 1
            lvl = array.get(swing_lows, i)
            // Direct sweep: current bar wicks below and closes back
            if low < lvl and (not require_close_back or close > lvl)
                swept := true
                swept_price := na(swept_price) ? low : math.min(swept_price, low)
            // Delayed close-back: prior bar broke below, current bar closes back above
            if require_close_back and low[1] < lvl and close[1] < lvl and close > lvl
                swept := true
                swept_price := na(swept_price) ? low[1] : math.min(swept_price, low[1])
    [swept, swept_price]

// Helper: check if price swept any swing high (bearish sweep)
f_any_swept_high() =>
    swept = false
    swept_price = float(na)
    if array.size(swing_highs) > 0
        for i = 0 to array.size(swing_highs) - 1
            lvl = array.get(swing_highs, i)
            // Direct sweep: current bar wicks above and closes back
            if high > lvl and (not require_close_back or close < lvl)
                swept := true
                swept_price := na(swept_price) ? high : math.max(swept_price, high)
            // Delayed close-back: prior bar broke above, current bar closes back below
            if require_close_back and high[1] > lvl and close[1] > lvl and close < lvl
                swept := true
                swept_price := na(swept_price) ? high[1] : math.max(swept_price, high[1])
    [swept, swept_price]

[bull_sweep, bull_sweep_price] = f_any_swept_low()
[bear_sweep, bear_sweep_price] = f_any_swept_high()

var float sw_lo_price = na
var int   sw_lo_bar   = na
var float sw_hi_price = na
var int   sw_hi_bar   = na
if bull_sweep
    sw_lo_price := bull_sweep_price
    sw_lo_bar   := bar_index
if bear_sweep
    sw_hi_price := bear_sweep_price
    sw_hi_bar   := bar_index

plotshape(show_sweeps and bull_sweep, title="Bull Sweep", style=shape.triangleup,   location=location.belowbar, color=color.new(#29B6F6, 0), size=size.tiny)
plotshape(show_sweeps and bear_sweep, title="Bear Sweep", style=shape.triangledown, location=location.abovebar, color=color.new(#FFD600, 0), size=size.tiny)

// ── FVG (displacement gap) — WITH 2-BAR IMBALANCE ───────────────────────────
// Change 5: Standard 3-bar FVG (low - high[2]) plus a 2-bar imbalance check
// (low - high[1]) for V-reversals where sweep and displacement are adjacent.
bull_gap_3 = low - high[2]
bear_gap_3 = low[2] - high
bull_gap_2 = low - high[1]
bear_gap_2 = low[1] - high
fvg_min_thr = fvg_min_atr * atr14
fvg_max_thr = fvg_max_atr * atr14

f_gap_ok(float gap) =>
    gap > 0 and gap >= fvg_min_thr and (fvg_max_thr == 0 or gap <= fvg_max_thr)

bull_fvg_3 = f_gap_ok(bull_gap_3)
bear_fvg_3 = f_gap_ok(bear_gap_3)
bull_fvg_2 = f_gap_ok(bull_gap_2)
bear_fvg_2 = f_gap_ok(bear_gap_2)
bull_fvg = bull_fvg_3 or bull_fvg_2
bear_fvg = bear_fvg_3 or bear_fvg_2

// FVG zone coordinates (prefer the 3-bar gap; fall back to 2-bar)
bull_fvg_top = bull_fvg_3 ? low      : low
bull_fvg_bot = bull_fvg_3 ? high[2]  : high[1]
bear_fvg_top = bear_fvg_3 ? low[2]   : low[1]
bear_fvg_bot = bear_fvg_3 ? high     : high

var box[] fvg_boxes = array.new_box()
MAX_FVGBOX = 40
if bull_fvg and fvg_show
    array.push(fvg_boxes, box.new(bar_index[1], bull_fvg_top, bar_index + 6, bull_fvg_bot, border_color=color.new(#00C853, 70), bgcolor=col_bull_fvg))
if bear_fvg and fvg_show
    array.push(fvg_boxes, box.new(bar_index[1], bear_fvg_top, bar_index + 6, bear_fvg_bot, border_color=color.new(#FF1744, 70), bgcolor=col_bear_fvg))
if array.size(fvg_boxes) > MAX_FVGBOX
    box.delete(array.shift(fvg_boxes))

// ── ARMED SETUP STATE MACHINE — OVERRIDE-CAPABLE ─────────────────────────────
// Change 3: New setups always override stale armed/tracking states. No more
// "not armed_bull"/"not in_trade" guards blocking new opportunities.
// Session-aware sweep window: off-session bars don't count toward the window.
var bool  in_trade   = false
var bool  be_on      = false
var bool  armed_bull = false
var bool  armed_bear = false
var float set_top    = na
var float set_bot    = na
var float set_stop   = na
var int   set_bar    = na

// Change 3: Session-aware sweep window — count only in-session bars elapsed
var int sess_bars_since_bull_sweep = 0
var int sess_bars_since_bear_sweep = 0
if bull_sweep
    sess_bars_since_bull_sweep := 0
else if in_session
    sess_bars_since_bull_sweep += 1
// off-session: counter does NOT increment (window is paused)
if bear_sweep
    sess_bars_since_bear_sweep := 0
else if in_session
    sess_bars_since_bear_sweep += 1

bull_sweep_recent = not na(sw_lo_bar) and sess_bars_since_bull_sweep <= sweep_window
bear_sweep_recent = not na(sw_hi_bar) and sess_bars_since_bear_sweep <= sweep_window

// Arm on FVG + recent sweep — no blocking guards (new setup overrides old)
if bull_fvg and bull_sweep_recent
    armed_bull := true
    armed_bear := false
    set_top    := bull_fvg_top
    set_bot    := bull_fvg_bot
    set_stop   := sw_lo_price - stop_buf_atr * atr14
    set_bar    := bar_index
    // If we were tracking a stale trade, clear it so this new setup can fire
    if in_trade
        in_trade := false
        be_on    := false
if bear_fvg and bear_sweep_recent
    armed_bear := true
    armed_bull := false
    set_top    := bear_fvg_top
    set_bot    := bear_fvg_bot
    set_stop   := sw_hi_price + stop_buf_atr * atr14
    set_bar    := bar_index
    if in_trade
        in_trade := false
        be_on    := false

if armed_bull
    if (bar_index - set_bar) > entry_window or low < set_stop
        armed_bull := false
if armed_bear
    if (bar_index - set_bar) > entry_window or high > set_stop
        armed_bear := false

// ── ENTRY (signal) ───────────────────────────────────────────────────────────
bull_mom = close > open and (close - open) / (high - low + 1e-9) > momentum_pct
bear_mom = close < open and (open - close) / (high - low + 1e-9) > momentum_pct

var float pos_ent  = na
var float pos_stop = na
var float pos_tgt  = na
var float pos_risk = na
var bool  pos_bull = true
var int   entry_bar = na
// persistent "last signal" for the status panel
var bool  has_sig      = false
var bool  last_sig_bull = true
var float last_sig_ent  = na

bull_fired = false
bear_fired = false

// Helper: find nearest opposite liquidity from swing arrays
f_nearest_above(float ref) =>
    best = float(na)
    for i = 0 to math.max(0, array.size(swing_highs) - 1)
        v = array.get(swing_highs, i)
        if v > ref and (na(best) or v < best)
            best := v
    best

f_nearest_below(float ref) =>
    best = float(na)
    for i = 0 to math.max(0, array.size(swing_lows) - 1)
        v = array.get(swing_lows, i)
        if v < ref and (na(best) or v > best)
            best := v
    best

f_arm_long() =>
    nm  = (set_top - set_bot) * near_miss_pct
    tap = low <= (set_top + nm) and high >= (set_bot - nm)
    ent = entry_mode == "Limit at FVG Edge" ? set_top - (set_top - set_bot) * limit_fill_pct : close
    risk = ent - set_stop
    tgt_liq = f_nearest_above(ent)
    tgt_fix = ent + risk * target_rr
    tgt = target_mode == "Opposite Liquidity" and not na(tgt_liq) and tgt_liq > ent + risk * target_rr ? tgt_liq : tgt_fix
    ok = tap and bull_mom and close > set_bot and in_session and risk > 0 and (not use_atr_sl or risk <= atr14 * atr_sl_mult) and (not use_htf_bias or above_ma)
    [ok, ent, risk, tgt]

f_arm_short() =>
    nm  = (set_top - set_bot) * near_miss_pct
    tap = low <= (set_top + nm) and high >= (set_bot - nm)
    ent = entry_mode == "Limit at FVG Edge" ? set_bot + (set_top - set_bot) * limit_fill_pct : close
    risk = set_stop - ent
    tgt_liq = f_nearest_below(ent)
    tgt_fix = ent - risk * target_rr
    tgt = target_mode == "Opposite Liquidity" and not na(tgt_liq) and tgt_liq < ent - risk * target_rr ? tgt_liq : tgt_fix
    ok = tap and bear_mom and close < set_top and in_session and risk > 0 and (not use_atr_sl or risk <= atr14 * atr_sl_mult) and (not use_htf_bias or below_ma)
    [ok, ent, risk, tgt]

// Entry checks — no "not in_trade" guard; new signals always fire
if armed_bull
    [ok, ent, risk, tgt] = f_arm_long()
    if ok
        bull_fired := true
        in_trade := true
        pos_ent := ent
        pos_stop := set_stop
        pos_risk := risk
        pos_tgt := tgt
        pos_bull := true
        entry_bar := bar_index
        be_on := false
        armed_bull := false
        has_sig := true
        last_sig_bull := true
        last_sig_ent := ent

if armed_bear
    [ok, ent, risk, tgt] = f_arm_short()
    if ok
        bear_fired := true
        in_trade := true
        pos_ent := ent
        pos_stop := set_stop
        pos_risk := risk
        pos_tgt := tgt
        pos_bull := false
        entry_bar := bar_index
        be_on := false
        armed_bear := false
        has_sig := true
        last_sig_bull := false
        last_sig_ent := ent

// ── TRADE-STATE RESOLUTION (no orders — just clears the tracker) ──────────────
// Marks a tracked setup resolved when price hits the stop, the target, or the
// time limit, so the next setup can arm. Stop checked first (conservative).
if in_trade and not na(pos_stop)
    if use_breakeven and not be_on and ((pos_bull and high >= pos_ent + pos_risk * be_rr) or (not pos_bull and low <= pos_ent - pos_risk * be_rr))
        be_on := true
    cur = be_on ? pos_ent : pos_stop
    hit_stop = pos_bull ? low <= cur : high >= cur
    hit_tgt  = pos_bull ? high >= pos_tgt : low <= pos_tgt
    timeout  = use_time_stop and not na(entry_bar) and (bar_index - entry_bar) >= max_bars
    if hit_stop or hit_tgt or timeout
        in_trade := false
        be_on := false

// ── ALERTS ───────────────────────────────────────────────────────────────────
if bull_fired
    alert("SWEEP LONG " + syminfo.ticker + " " + timeframe.period + " Entry " + str.tostring(pos_ent, format.mintick) + " SL " + str.tostring(pos_stop, format.mintick) + " TP " + str.tostring(pos_tgt, format.mintick), alert.freq_once_per_bar_close)
if bear_fired
    alert("SWEEP SHORT " + syminfo.ticker + " " + timeframe.period + " Entry " + str.tostring(pos_ent, format.mintick) + " SL " + str.tostring(pos_stop, format.mintick) + " TP " + str.tostring(pos_tgt, format.mintick), alert.freq_once_per_bar_close)
alertcondition(bull_fired, "Sweep LONG",  "Sweep+FVG LONG {{ticker}} {{interval}}")
alertcondition(bear_fired, "Sweep SHORT", "Sweep+FVG SHORT {{ticker}} {{interval}}")
alertcondition(bull_fired or bear_fired, "Any Sweep Setup", "Sweep+FVG setup {{ticker}} {{interval}}")

// ── MARKERS ──────────────────────────────────────────────────────────────────
plotshape(show_markers and bull_fired, title="Long Entry", style=shape.labelup,   location=location.belowbar, color=col_entry, size=size.small, text="LONG",  textcolor=color.white)
plotshape(show_markers and bear_fired, title="Short Entry", style=shape.labeldown, location=location.abovebar, color=col_sl,    size=size.small, text="SHORT", textcolor=color.white)

// ── TRADE-LEVEL LADDER + R/R ZONES ───────────────────────────────────────────
var line[]  t_lines = array.new_line()
var label[] t_labs  = array.new_label()
var box[]   t_zones = array.new_box()

if (bull_fired or bear_fired)
    is_bull = pos_bull
    e  = pos_ent
    s  = pos_stop
    tg = pos_tgt
    bx = bar_index
    x2 = bx + ladder_len
    lx = x2 + 1
    r  = math.abs(e - s)
    if show_zones
        array.push(t_zones, box.new(bx, is_bull ? e : s, x2, is_bull ? s : e, bgcolor=col_risk_z, border_color=color.new(col_sl, 70)))
        array.push(t_zones, box.new(bx, is_bull ? tg : e, x2, is_bull ? e : tg, bgcolor=col_rew_z, border_color=color.new(col_tp, 70)))
    array.push(t_lines, line.new(bx, e, x2, e, color=col_entry, width=2))
    array.push(t_labs,  label.new(lx, e, (is_bull ? "▲ E " : "▼ E ") + str.tostring(e, format.mintick), color=col_entry, textcolor=color.black, size=size.small, style=label.style_label_left))
    array.push(t_lines, line.new(bx, s, x2, s, color=col_sl, width=1, style=line.style_dashed))
    array.push(t_labs,  label.new(lx, s, "SL " + str.tostring(s, format.mintick) + " (risk " + str.tostring(r, format.mintick) + ")", color=col_sl, textcolor=color.white, size=size.small, style=label.style_label_left))
    rr_shown = r > 0 ? math.abs(tg - e) / r : 0
    array.push(t_lines, line.new(bx, tg, x2, tg, color=col_tp, width=2))
    array.push(t_labs,  label.new(lx, tg, "TP " + str.tostring(tg, format.mintick) + "  (" + str.tostring(rr_shown, "#.#") + "R)", color=col_tp, textcolor=color.black, size=size.small, style=label.style_label_left))
    while array.size(t_lines) > max_setups * 3
        line.delete(array.shift(t_lines))
    while array.size(t_labs) > max_setups * 3
        label.delete(array.shift(t_labs))
    while array.size(t_zones) > max_setups * 2
        box.delete(array.shift(t_zones))

// ── STATUS PANEL ─────────────────────────────────────────────────────────────
var table tbl = table.new(position.bottom_right, 2, 6, bgcolor=color.new(#1A1A2E, 10), border_color=color.new(#FFFFFF, 60), border_width=1, frame_color=#FFFFFF, frame_width=2)
if barstate.islast and show_status
    table.cell(tbl, 0, 0, "SWEEP+FVG v2", text_color=#AAAAAA, text_size=size.small, bgcolor=#1A1A2E)
    table.cell(tbl, 1, 0, in_session ? "● in session" : "○ off-session", text_color=in_session ? #00C853 : #AAAAAA, text_size=size.small, bgcolor=#1A1A2E)
    armed_txt = armed_bull ? "▲ armed (long)" : armed_bear ? "▼ armed (short)" : "—"
    armed_col = armed_bull ? #00C853 : armed_bear ? #FF1744 : #AAAAAA
    table.cell(tbl, 0, 1, "Setup", text_color=color.white, text_size=size.normal, bgcolor=#1A1A2E)
    table.cell(tbl, 1, 1, armed_txt, text_color=armed_col, text_size=size.normal, bgcolor=#1A1A2E)
    table.cell(tbl, 0, 2, "Tracking", text_color=color.white, text_size=size.normal, bgcolor=#1A1A2E)
    table.cell(tbl, 1, 2, in_trade ? (pos_bull ? "▲ LONG live" : "▼ SHORT live") : "flat", text_color=in_trade ? (pos_bull ? #00C853 : #FF1744) : #AAAAAA, text_size=size.normal, bgcolor=#1A1A2E)
    table.cell(tbl, 0, 3, "Last Signal", text_color=color.white, text_size=size.normal, bgcolor=#1A1A2E)
    table.cell(tbl, 1, 3, has_sig ? (last_sig_bull ? "▲ L " : "▼ S ") + str.tostring(last_sig_ent, format.mintick) : "none", text_color=has_sig ? (last_sig_bull ? #00C853 : #FF1744) : #AAAAAA, text_size=size.normal, bgcolor=#1A1A2E)
    table.cell(tbl, 0, 4, "HTF", text_color=#AAAAAA, text_size=size.small, bgcolor=#1A1A2E)
    table.cell(tbl, 1, 4, htf_tf, text_color=#AAAAAA, text_size=size.small, bgcolor=#1A1A2E)
    table.cell(tbl, 0, 5, "Timeframe", text_color=#AAAAAA, text_size=size.small, bgcolor=#1A1A2E)
    table.cell(tbl, 1, 5, timeframe.period, text_color=#AAAAAA, text_size=size.small, bgcolor=#1A1A2E)

// ── MTF BIAS DASHBOARD (top-left) ────────────────────────────────────────────
var table dash = table.new(position.top_right, 3, 6, bgcolor=color.new(#1A1A2E, 10), border_color=color.new(#FFFFFF, 60), border_width=1, frame_color=#FFFFFF, frame_width=2)

f_dash_row(int r, string tflab, bool bias, int swp) =>
    table.cell(dash, 0, r, tflab, text_color=color.white, text_size=size.normal, bgcolor=#1A1A2E)
    table.cell(dash, 1, r, bias ? "▲ BULL" : "▼ BEAR", text_color=bias ? #00C853 : #FF1744, text_size=size.normal, bgcolor=#1A1A2E)
    swptxt = swp == 1 ? "▲ swept low" : swp == -1 ? "▼ swept high" : "—"
    swpcol = swp == 1 ? #29B6F6 : swp == -1 ? #FFD600 : #AAAAAA
    table.cell(dash, 2, r, swptxt, text_color=swpcol, text_size=size.normal, bgcolor=#1A1A2E)

if barstate.islast and show_dashboard
    table.cell(dash, 0, 0, "TF",    text_color=#AAAAAA, text_size=size.small, bgcolor=#1A1A2E)
    table.cell(dash, 1, 0, "BIAS",  text_color=#AAAAAA, text_size=size.small, bgcolor=#1A1A2E)
    table.cell(dash, 2, 0, "SWEEP", text_color=#AAAAAA, text_size=size.small, bgcolor=#1A1A2E)
    f_dash_row(1, "15m", b15,  s15)
    f_dash_row(2, "30m", b30,  s30)
    f_dash_row(3, "1H",  b60,  s60)
    f_dash_row(4, "4H",  b240, s240)
    f_dash_row(5, "1D",  bD,   sD)
````
