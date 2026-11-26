# EMA Bot Signals + VPoC

- url: https://www.tradingview.com/script/PYQ6RGR1-EMA-Bot-Signals-VPoC/
- type: indicator
- pine_id: PUB;4b43b4a601ad4eda994b8cf130b77c57
- version: 1.0

## Description

EMA Bot Signals + VPoC

A swing-trading toolkit built around a 9/21 EMA crossover, graded by trend slope and volume, with a Volume Point of Control (VPoC) used as a dynamic target. It visualizes a full entry → stop → target lifecycle on the chart, plus candlestick reversals and a higher-timeframe trend filter, so you can see why a setup qualifies — not just that the EMAs crossed.

What it does

- EMA cross signals (9/21): marks bullish crosses, and "anticipate" entries just before a cross when the fast EMA is already turning up inside a tight gap.
- Signal strength: every entry is graded Strong / Moderate / Weak from EMA slope (%/bar) and volume vs. its average, so weak crosses are visibly de-emphasized.
- VPoC: plots the heaviest-volume price level over a configurable lookback. When VPoC sits >=8% above the recent crossover average, it is used as the T1 target (otherwise targets are derived from EMA spread). Optional historical daily-session VPoC lines on intraday charts.
- Trade lifecycle: on a signal it tracks entry, stop, T1, T2, moves the stop to breakeven once T1 is hit, and marks the exit (T2, stop, breakeven-stop, or bear cross).
- Exit context: flags stalling (slope fading + below-average volume), momentum collapse, and T1-recovery (slope turning back up inside the T1 zone).
- Daily-trend filter: while the daily trend is up (daily EMA9 > EMA21 and rising), soft exits are held and the background tints green — hard stop/targets always fire.
- Candlestick reversals: marks Engulfing, Hammer/Shooting Star, Morning/Evening Star, Piercing/Dark Cloud, and Harami (bullish below the bar, bearish above).
- Corner table: live read of alignment, slope, volume ratio, signal strength, VPoC distance, pattern, and daily trend.

How to use it

Add to any symbol/timeframe (designed for swing timeframes like 1h-1D). Use the graded entry triangles with the corner table to filter for Strong/Moderate setups in the direction of the daily trend, and treat the plotted stop/T1/T2 and VPoC as a planning guide. Inputs let you tune EMA lengths, stop %, anticipate %, target lookback, VPoC bars/levels, and which overlays to show.

Notes

Hover any marker for a tooltip with the entry/stop/targets/VPoC/slope/volume detail behind it. Best on liquid markets where volume is meaningful for the VPoC calculation.

This is an analysis and education tool, not financial advice. It does not place orders and past behavior of any signal does not guarantee future results. Always do your own research and manage risk.

## Source Code

````pine
// EMA Bot Signals + Volume Point of Control (VPoC)
// Matches doge_ema_bot.py exactly. VPoC used as T1 target when ≥8% above entry.
//@version=6
indicator("EMA Bot Signals + VPoC", overlay=true, max_lines_count=50, max_labels_count=500, max_bars_back=502)

// ── INPUTS ────────────────────────────────────────────────────────────────────
fast_len       = input.int(9,     "Fast EMA",        minval=1)
slow_len       = input.int(21,    "Slow EMA",        minval=1)
sl_pct         = input.float(3.0, "Stop Loss %",     step=0.1, minval=1.0, maxval=5.0) / 100
anticipate_pct = input.float(1.0, "Anticipate %",    step=0.1, minval=0.0) / 100
lookback       = input.int(500,   "Target Lookback", minval=50, maxval=500)
slope_bars     = input.int(5,     "Slope Bars",      minval=2,  maxval=20)
vol_bars       = input.int(6,     "Vol Trend Bars",  minval=3,  maxval=20)
show_patterns  = input.bool(true, "Show Candlestick Patterns", group="Patterns")
show_daily     = input.bool(true, "Show Daily-Trend Exit Filter", group="Exit Filter")
daily_bg       = input.bool(true, "Tint background when daily uptrend holds exits", group="Exit Filter")

// VPoC inputs
show_vpoc      = input.bool(true,  "Show VPoC",           group="VPoC")
vpoc_n_bars    = input.int(100,    "VPoC Lookback Bars",  minval=20, maxval=500, group="VPoC")
vpoc_levels    = input.int(20,     "VPoC Price Levels",   minval=10, maxval=40,  group="VPoC")
show_vpoc_hist = input.bool(true,  "Show Daily VPoC History", group="VPoC")
vpoc_sessions  = input.int(5,      "History Sessions",    minval=1,  maxval=10,  group="VPoC")

// ── EMAs ──────────────────────────────────────────────────────────────────────
ema_fast = ta.ema(close, fast_len)
ema_slow = ta.ema(close, slow_len)
// (v6) historical buffer is set via max_bars_back= in indicator() above, so the
// lookback loop can reference ema_fast[lookback+1] without per-variable calls.

// ── DAILY-TREND EXIT FILTER ─────────────────────────────────────────────────────
// Mirrors doge_ema_bot.daily_uptrend(): while the DAILY trend is up (daily EMA9 >
// EMA21 and EMA21 rising), the bot HOLDS its soft exits (momentum / pattern /
// bear-cross). Stop & targets always fire. This panel shows when that hold is active.
// htf_res = never request a timeframe LOWER than the chart (so this also works on
// Daily/Weekly charts, where it simply uses the chart's own trend).
htf_res = timeframe.in_seconds() >= timeframe.in_seconds("1D") ? timeframe.period : "1D"
[d_ema_fast, d_ema_slow, d_ema_slow_prev] = request.security(syminfo.tickerid, htf_res, [ta.ema(close, fast_len), ta.ema(close, slow_len), ta.ema(close, slow_len)[slope_bars]])
daily_up = d_ema_fast > d_ema_slow and (d_ema_slow - d_ema_slow_prev) >= 0
bgcolor(show_daily and daily_bg and daily_up ? color.new(#00e676, 92) : na, title="Daily uptrend — soft exits held")

// ── SLOPE ─────────────────────────────────────────────────────────────────────
slope_raw = (ema_slow - ema_slow[slope_bars]) / ema_slow[slope_bars] * 100
slope_pct = slope_raw / slope_bars

// ── VOLUME TREND ──────────────────────────────────────────────────────────────
vol_sma   = ta.sma(volume, vol_bars)
vol_ratio = volume / vol_sma

// ── SIGNAL STRENGTH ───────────────────────────────────────────────────────────
slope_good = slope_pct >= 0.05
vol_good   = vol_ratio >= 1.0
sig_score  = (slope_good ? 1 : 0) + (vol_good ? 1 : 0)

// ── SIGNALS ───────────────────────────────────────────────────────────────────
bull_cross = ta.crossover(ema_fast,  ema_slow)
bear_cross = ta.crossunder(ema_fast, ema_slow)

gap_pct         = ema_fast < ema_slow ? (ema_slow - ema_fast) / ema_slow : 1.0
anticipate_cond = anticipate_pct > 0 and not bull_cross and ema_fast < ema_slow and gap_pct <= anticipate_pct and ema_fast > ema_fast[1]

// ── VPOC CALCULATION ─────────────────────────────────────────────────────────
// Rolling VPoC over last vpoc_n_bars — computed on final bar only
var float vpoc = na
var float vpoc_t1 = na   // VPoC-based T1 (when ≥8% above last bull cross)

if barstate.islast and show_vpoc
    float ph = ta.highest(high, vpoc_n_bars)
    float pl = ta.lowest(low,  vpoc_n_bars)
    float lh = (ph - pl) / vpoc_levels
    float[] vols = array.new_float(vpoc_levels, 0.0)
    for i = 0 to vpoc_n_bars - 1
        for lv = 0 to vpoc_levels - 1
            lv_lo = pl + lh * lv
            lv_hi = pl + lh * (lv + 1)
            if low[i] < lv_hi and high[i] > lv_lo
                ol = math.max(low[i], lv_lo)
                oh = math.min(high[i], lv_hi)
                array.set(vols, lv, array.get(vols, lv) + volume[i] * (oh - ol) / lh)
    max_lv = array.indexof(vols, array.max(vols))
    vpoc := pl + lh * (max_lv + 0.5)

// ── HISTORICAL DAILY VPoC ────────────────────────────────────────────────────
// Detect daily session boundaries and store the last N VPoC prices
var float[] hist_vpocs = array.new_float(0)
var int[]   hist_bars  = array.new_int(0)

// Use daily bar_index to detect day changes. On Daily/Weekly charts htf_res equals
// the chart TF (never lower), so this degrades to a no-op instead of erroring.
day_bar = request.security(syminfo.tickerid, htf_res, bar_index, lookahead=barmerge.lookahead_on)
is_new_day = day_bar != day_bar[1]

// Count bars in current daily session
var int session_bar_count = 0
if is_new_day
    // Compute VPoC for the just-completed session
    if show_vpoc_hist and session_bar_count > 2
        float s_ph = ta.highest(high, session_bar_count)
        float s_pl = ta.lowest(low,  session_bar_count)
        float s_lh = (s_ph - s_pl) / vpoc_levels
        if s_lh > 0
            float[] s_vols = array.new_float(vpoc_levels, 0.0)
            int n = math.min(session_bar_count, 500)
            for i = 0 to n - 1
                for lv = 0 to vpoc_levels - 1
                    lv_lo = s_pl + s_lh * lv
                    lv_hi = s_pl + s_lh * (lv + 1)
                    if low[i] < lv_hi and high[i] > lv_lo
                        ol = math.max(low[i], lv_lo)
                        oh = math.min(high[i], lv_hi)
                        array.set(s_vols, lv, array.get(s_vols, lv) + volume[i] * (oh - ol) / s_lh)
            s_max_lv = array.indexof(s_vols, array.max(s_vols))
            s_vpoc   = s_pl + s_lh * (s_max_lv + 0.5)
            array.unshift(hist_vpocs, s_vpoc)
            array.unshift(hist_bars,  bar_index)
            // Keep only what we need
            if array.size(hist_vpocs) > vpoc_sessions
                array.pop(hist_vpocs)
                array.pop(hist_bars)
    session_bar_count := 1
else
    session_bar_count += 1

// ── DYNAMIC TARGETS (EMA spread) ──────────────────────────────────────────────
float scan_sum = 0.0
int   scan_cnt = 0
float scan_max = 0.0

for i = 1 to lookback
    ef_now  = ema_fast[i]
    es_now  = ema_slow[i]
    ef_prev = ema_fast[i + 1]
    es_prev = ema_slow[i + 1]
    if ef_prev <= es_prev and ef_now > es_now
        scan_sum += open[i]
        scan_cnt += 1
    if ef_now > es_now
        if high[i] > scan_max
            scan_max := high[i]

float cross_avg = scan_cnt > 0 ? scan_sum / scan_cnt : na
float spread    = not na(cross_avg) and scan_max > cross_avg ? scan_max - cross_avg : na
float ema_t1    = not na(spread) ? cross_avg + spread * 0.5 : na
float ema_t2    = not na(spread) ? cross_avg + spread       : na

// VPoC-based T1: use VPoC when ≥8% above most recent crossover avg
float bull_t1 = ema_t1
float bull_t2 = ema_t2
bool  vpoc_t1_active = false
if show_vpoc and not na(vpoc) and not na(cross_avg) and vpoc > cross_avg * 1.08
    vpoc_t1_active := true
    float vs = vpoc - cross_avg
    bull_t1 := vpoc
    bull_t2 := cross_avg + vs * 2

// ── POSITION STATE ────────────────────────────────────────────────────────────
var bool  in_pos   = false
var float p_entry  = na
var float p_sl     = na
var float p_t1     = na
var float p_t2     = na
var bool  p_t1_hit = false

was_in_pos = in_pos
was_t1_hit = p_t1_hit

// ── EXIT CONDITIONS ───────────────────────────────────────────────────────────
t2_exit      = was_in_pos and high >= p_t2
t1_milestone = was_in_pos and not was_t1_hit and high >= p_t1 and not t2_exit
sl_exit      = was_in_pos and low  <= p_sl   and not t2_exit
bear_exit    = was_in_pos and bear_cross      and not t2_exit and not sl_exit

// ── ENTRY CONDITIONS ──────────────────────────────────────────────────────────
buy_entry        = bull_cross      and not was_in_pos and not na(bull_t1)
anticipate_entry = anticipate_cond and not was_in_pos and not na(bull_t1)
cross_confirmed  = bull_cross      and was_in_pos

// (TREND_BUY continuation marker removed — too noisy on the chart; the live bot still uses it)

// ── STALL DETECTION ───────────────────────────────────────────────────────────
slope_weakening = slope_pct < slope_pct[1]
vol_below_avg   = volume < vol_sma
stalling        = was_in_pos and slope_weakening and vol_below_avg
stall_start     = stalling and not stalling[1]   // (v6) bool is never na, nz() not needed

// ── MOMENTUM EXIT ─────────────────────────────────────────────────────────────
momentum_collapse = was_in_pos and slope_pct < 0.0 and vol_ratio < 0.7
momentum_exit_sig = momentum_collapse and momentum_collapse[1]

// ── T1 RECOVERY ───────────────────────────────────────────────────────────────
t1_zone          = not na(bull_t1) and close >= bull_t1 * 0.95 and close <= bull_t1 * 1.15
slope_recovering = slope_pct > 0.0 and slope_pct > slope_pct[1] and slope_pct[1] <= 0.02
vol_recovering   = vol_ratio >= 0.7 and vol_ratio >= vol_ratio[1]
t1_recovery_raw  = ema_fast > ema_slow and t1_zone and slope_recovering and vol_recovering and sig_score >= 1
t1_recovery      = t1_recovery_raw and not t1_recovery_raw[1]

// ── NEAR STOP ─────────────────────────────────────────────────────────────────
near_stop = was_in_pos and close <= p_sl * 1.02 and not sl_exit

// ── BACKGROUND ───────────────────────────────────────────────────────────────
bg_color = near_stop ? color.new(color.red, 85) : momentum_exit_sig ? color.new(color.red, 78) : stalling ? color.new(color.orange, 85) : ema_fast > ema_slow ? color.new(color.green, 92) : na
bgcolor(bg_color, title="Background")

// ── PLOTS ─────────────────────────────────────────────────────────────────────
plot(ema_fast, "Fast EMA", color=color.new(color.aqua,   0), linewidth=2)
plot(ema_slow, "Slow EMA", color=color.new(color.orange, 0), linewidth=2)
plot(was_in_pos ? p_t2 : na, "T2",   color=color.new(color.lime,   20), linewidth=1)
plot(was_in_pos ? p_t1 : na, "T1",   color=color.new(color.yellow, 20), linewidth=1)
plot(was_in_pos ? p_sl : na, "Stop", color=color.red, linewidth=2, style=plot.style_linebr)

// VPoC line
plot(show_vpoc ? vpoc : na, "VPoC", color=color.new(#dd44ff, 0), linewidth=3, style=plot.style_line)

// ── VPOC LABEL ────────────────────────────────────────────────────────────────
var label vpoc_lbl = na
label.delete(vpoc_lbl)
if barstate.islast and show_vpoc and not na(vpoc)
    string vpoc_src = vpoc_t1_active ? " ← T1" : ""
    vpoc_lbl := label.new(bar_index + 1, vpoc, "VPoC " + str.tostring(vpoc, "#.######") + vpoc_src,
                           xloc=xloc.bar_index, yloc=yloc.price,
                           color=color.new(#dd44ff, 10), style=label.style_label_left,
                           textcolor=color.white, size=size.small)

// ── HISTORICAL VPOC LINES ─────────────────────────────────────────────────────
var line[] hist_lines  = array.new_line()
var label[] hist_lbls  = array.new_label()

// Daily-session VPoC history only makes sense on intraday charts; skip on 1D/1W
// (where hist_vpocs is empty) so array.get() never indexes an empty array.
if barstate.islast and show_vpoc_hist and timeframe.isintraday and array.size(hist_vpocs) > 0
    // Clear old drawings
    for ln in hist_lines
        line.delete(ln)
    for lb in hist_lbls
        label.delete(lb)
    array.clear(hist_lines)
    array.clear(hist_lbls)
    int n_hist = math.min(array.size(hist_vpocs), vpoc_sessions)
    for i = 0 to n_hist - 1
        hv = array.get(hist_vpocs, i)
        ln = line.new(bar_index - 200, hv, bar_index + 3, hv,
                      color=color.new(#dd44ff, 30), style=line.style_dotted, width=2)
        lb = label.new(bar_index + 3, hv,
                       "D-" + str.tostring(i + 1) + " VPoC",
                       xloc=xloc.bar_index, yloc=yloc.price,
                       color=color.new(#dd44ff, 40), style=label.style_label_left,
                       textcolor=color.white, size=size.tiny)
        array.push(hist_lines, ln)
        array.push(hist_lbls,  lb)

// ── STOP LABEL ────────────────────────────────────────────────────────────────
var label sl_lbl = na
label.delete(sl_lbl)
sl_lbl := na
if was_in_pos
    sl_lbl := label.new(bar_index + 1, p_sl, "SL " + str.tostring(p_sl, "#.000000"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.red, 10), style=label.style_label_left, textcolor=color.white, size=size.small)

// ── ENTRY LABELS ─────────────────────────────────────────────────────────────
if anticipate_entry
    string stxt = sig_score == 2 ? "STRONG (slope+vol)" : sig_score == 1 ? "MODERATE" : "WEAK"
    string t1_src = vpoc_t1_active ? " [VPoC]" : " [EMA]"
    string tip = "ANTICIPATE BUY  " + stxt
    tip := tip + "\nEntry:  " + str.tostring(close, "#.000000")
    tip := tip + "\nSL:     " + str.tostring(close * (1 - sl_pct), "#.000000")
    tip := tip + "\nT1:     " + str.tostring(bull_t1, "#.000000") + t1_src
    tip := tip + "\nT2:     " + str.tostring(bull_t2, "#.000000")
    tip := tip + "\nVPoC:   " + (not na(vpoc) ? str.tostring(vpoc, "#.000000") : "n/a")
    tip := tip + "\nGap:    " + str.tostring(gap_pct * 100, "#.00") + "%"
    tip := tip + "\nSlope:  " + str.tostring(math.round(slope_pct, 4)) + "%/c"
    tip := tip + "\nVol:    " + str.tostring(math.round(vol_ratio, 2)) + "x avg"
    color ecol = sig_score == 2 ? color.new(color.lime, 0) : sig_score == 1 ? color.new(color.green, 0) : color.new(color.green, 55)
    string esz = sig_score == 2 ? size.normal : sig_score == 1 ? size.small : size.tiny
    label.new(bar_index, na, text="", tooltip=tip, xloc=xloc.bar_index, yloc=yloc.belowbar, color=ecol, textcolor=color.white, style=label.style_triangleup, size=esz)

if buy_entry
    string stxt = sig_score == 2 ? "STRONG (slope+vol)" : sig_score == 1 ? "MODERATE" : "WEAK"
    string t1_src = vpoc_t1_active ? " [VPoC]" : " [EMA]"
    string tip = "BUY (crossover)  " + stxt
    tip := tip + "\nEntry:  " + str.tostring(close, "#.000000")
    tip := tip + "\nSL:     " + str.tostring(close * (1 - sl_pct), "#.000000")
    tip := tip + "\nT1:     " + str.tostring(bull_t1, "#.000000") + t1_src
    tip := tip + "\nT2:     " + str.tostring(bull_t2, "#.000000")
    tip := tip + "\nVPoC:   " + (not na(vpoc) ? str.tostring(vpoc, "#.000000") : "n/a")
    tip := tip + "\nSlope:  " + str.tostring(math.round(slope_pct, 4)) + "%/c"
    tip := tip + "\nVol:    " + str.tostring(math.round(vol_ratio, 2)) + "x avg"
    color ecol = sig_score == 2 ? color.new(color.lime, 0) : sig_score == 1 ? color.new(color.green, 0) : color.new(color.green, 55)
    string esz = sig_score == 2 ? size.normal : sig_score == 1 ? size.small : size.tiny
    label.new(bar_index, na, text="", tooltip=tip, xloc=xloc.bar_index, yloc=yloc.belowbar, color=ecol, textcolor=color.white, style=label.style_triangleup, size=esz)

if cross_confirmed
    label.new(bar_index, na, text="", tooltip="Crossover confirmed (already in via anticipate)\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.belowbar, color=color.new(color.green, 40), textcolor=color.white, style=label.style_circle, size=size.tiny)

// ── T1 RECOVERY LABEL ────────────────────────────────────────────────────────
if t1_recovery
    string stxt = sig_score == 2 ? "STRONG" : "MODERATE"
    string t1_src = vpoc_t1_active ? " [VPoC]" : " [EMA]"
    string tip = "T1 RECOVERY — slope turning up in T1 zone  " + stxt
    tip := tip + "\nEntry:  " + str.tostring(close, "#.000000")
    tip := tip + "\nSL:     " + str.tostring(close * (1 - sl_pct), "#.000000")
    tip := tip + "\nT1:     " + str.tostring(bull_t1, "#.000000") + t1_src
    tip := tip + "\nT2:     " + str.tostring(bull_t2, "#.000000")
    tip := tip + "\nVPoC:   " + (not na(vpoc) ? str.tostring(vpoc, "#.000000") : "n/a")
    tip := tip + "\nSlope:  " + str.tostring(math.round(slope_pct, 4)) + "%/c  (was " + str.tostring(math.round(slope_pct[1], 4)) + ")"
    tip := tip + "\nVol:    " + str.tostring(math.round(vol_ratio, 2)) + "x avg"
    label.new(bar_index, na, text="", tooltip=tip, xloc=xloc.bar_index, yloc=yloc.belowbar, color=color.new(#ff9800, 0), textcolor=color.black, style=label.style_triangleup, size=size.normal)

// ── STALL MARKER ─────────────────────────────────────────────────────────────
if stall_start
    string tip = "STALLING - momentum fading before T1"
    tip := tip + "\nSlope:  " + str.tostring(math.round(slope_pct, 4)) + "%/c (weakening)"
    tip := tip + "\nVol:    " + str.tostring(math.round(vol_ratio, 2)) + "x avg (below avg)"
    label.new(bar_index, na, text="", tooltip=tip, xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(color.orange, 0), textcolor=color.black, style=label.style_xcross, size=size.small)

// ── MOMENTUM EXIT ─────────────────────────────────────────────────────────────
if momentum_exit_sig and not momentum_exit_sig[1]
    string tip = "MOMENTUM EXIT — slope negative + vol drying up (2 bars)"
    tip := tip + "\nSlope:  " + str.tostring(math.round(slope_pct, 4)) + "%/c"
    tip := tip + "\nVol:    " + str.tostring(math.round(vol_ratio, 2)) + "x avg"
    label.new(bar_index, na, text="EXIT", tooltip=tip, xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(color.red, 0), textcolor=color.white, style=label.style_label_down, size=size.small)

// ── EXIT LABELS ───────────────────────────────────────────────────────────────
if t2_exit
    label.new(bar_index, na, text="", tooltip="T2 EXIT\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(color.lime, 0), textcolor=color.black, style=label.style_triangledown, size=size.small)

if t1_milestone
    label.new(bar_index, na, text="", tooltip="T1 HIT - stop to breakeven\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(color.yellow, 0), textcolor=color.black, style=label.style_diamond, size=size.tiny)

if sl_exit and not was_t1_hit
    label.new(bar_index, na, text="", tooltip="STOP LOSS\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.belowbar, color=color.new(color.red, 0), textcolor=color.white, style=label.style_circle, size=size.small)

if sl_exit and was_t1_hit
    label.new(bar_index, na, text="", tooltip="BREAKEVEN STOP\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.belowbar, color=color.new(color.orange, 0), textcolor=color.white, style=label.style_circle, size=size.small)

if bear_exit
    label.new(bar_index, na, text="", tooltip="SELL - bear cross\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(color.red, 0), textcolor=color.white, style=label.style_triangledown, size=size.small)

if bear_cross and not was_in_pos
    label.new(bar_index, na, text="", tooltip="Bear cross (no position)\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(color.red, 60), textcolor=color.white, style=label.style_triangledown, size=size.tiny)

// ── CANDLESTICK REVERSAL PATTERNS ──────────────────────────────────────────────
// Mirrors krakenbot's pattern scanner (detect_patterns): 5 reversal families,
// bullish below the bar, bearish above. The bot's pattern-EXIT acts only on the
// weight-≥3 bearish ones (Engulfing / Dark Cloud / Evening Star).
p_body0  = math.abs(close - open)
p_rng0   = math.max(high - low, 1e-12)
p_upper0 = high - math.max(open, close)
p_lower0 = math.min(open, close) - low
p_body1  = math.abs(close[1] - open[1])
p_mid1   = (open[1] + close[1]) / 2
p_hi1    = math.max(open[1], close[1])
p_lo1    = math.min(open[1], close[1])
p_body2  = math.abs(close[2] - open[2])
p_rng2   = math.max(high[2] - low[2], 1e-12)
p_mid2   = (open[2] + close[2]) / 2
p_inside = math.max(open, close) <= p_hi1 and math.min(open, close) >= p_lo1

// Bullish reversals
bull_engulf = close > open and close[1] < open[1] and p_body0 > p_body1 and close >= open[1] and open <= close[1]
hammer      = p_body0 <= p_rng0 * 0.35 and p_lower0 >= p_rng0 * 0.6 and p_upper0 <= p_rng0 * 0.15
morning     = p_body2 >= p_rng2 * 0.5 and p_body1 <= p_body2 * 0.5 and close[2] < open[2] and close > open and close > p_mid2 and p_body0 > p_body1
piercing    = close[1] < open[1] and close > open and open < close[1] and close > p_mid1 and close < open[1]
bull_harami = p_body1 > 0 and p_body0 < p_body1 * 0.7 and close[1] < open[1] and close > open and p_inside

// Bearish reversals
bear_engulf = close < open and close[1] > open[1] and p_body0 > p_body1 and open >= close[1] and close <= open[1]
shooting    = p_body0 <= p_rng0 * 0.35 and p_upper0 >= p_rng0 * 0.6 and p_lower0 <= p_rng0 * 0.15
evening     = p_body2 >= p_rng2 * 0.5 and p_body1 <= p_body2 * 0.5 and close[2] > open[2] and close < open and close < p_mid2 and p_body0 > p_body1
darkcloud   = close[1] > open[1] and close < open and open > close[1] and close < p_mid1 and close > open[1]
bear_harami = p_body1 > 0 and p_body0 < p_body1 * 0.7 and close[1] > open[1] and close < open and p_inside

// Strongest per direction (weight: Star 4 > Engulf/Piercing/DarkCloud 3 > Hammer/Star/Harami 2)
bull_name = morning ? "Morning Star" : bull_engulf ? "Bullish Engulfing" : piercing ? "Piercing Line" : hammer ? "Hammer" : bull_harami ? "Bullish Harami" : na
bear_name = evening ? "Evening Star" : bear_engulf ? "Bearish Engulfing" : darkcloud ? "Dark Cloud Cover" : shooting ? "Shooting Star" : bear_harami ? "Bearish Harami" : na
bear_exit_grade = evening or bear_engulf or darkcloud

if show_patterns and not na(bull_name)
    label.new(bar_index, na, text="🕯", tooltip="Bullish: " + bull_name + "\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.belowbar, color=color.new(#26a69a, 0), textcolor=color.white, style=label.style_label_up, size=size.tiny)
if show_patterns and not na(bear_name)
    label.new(bar_index, na, text="🕯", tooltip="Bearish: " + bear_name + (bear_exit_grade ? "  (bot exits on this)" : "  (alert only)") + "\nPrice: " + str.tostring(close, "#.000000"), xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(#ef5350, 0), textcolor=color.white, style=label.style_label_down, size=size.tiny)

// ── CORNER TABLE ──────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 9, border_width=1)

if barstate.islast
    color align_col = ema_fast > ema_slow ? color.new(#00e676, 10) : color.new(#ff7043, 10)
    string align_txt = ema_fast > ema_slow ? "Fast > Slow" : "Fast < Slow"

    color slope_col = slope_pct >= 0.05 ? color.new(#00e676, 20) : slope_pct >= 0.0 ? color.new(#bdbdbd, 40) : color.new(#ff7043, 20)
    string slope_txt = str.tostring(math.round(slope_pct, 4)) + "%"

    color vol_col = vol_ratio >= 1.0 ? color.new(#00e676, 20) : vol_ratio >= 0.7 ? color.new(#bdbdbd, 40) : color.new(#ff7043, 20)
    string vol_txt = str.tostring(math.round(vol_ratio, 2)) + "x"

    color str_col = sig_score == 2 ? color.new(#00e676, 0) : sig_score == 1 ? color.new(#ffeb3b, 20) : color.new(#ff7043, 20)
    string str_txt = sig_score == 2 ? "Strong" : sig_score == 1 ? "Moderate" : "Weak"

    color stall_col = momentum_exit_sig ? color.new(color.red, 10) : t1_recovery_raw ? color.new(#ff9800, 10) : stalling ? color.new(color.orange, 20) : color.new(color.gray, 60)
    string stall_txt = momentum_exit_sig ? "EXIT" : t1_recovery_raw ? "T1 Recovery" : stalling ? "Stalling" : "No"
    color stall_tc = (momentum_exit_sig or t1_recovery_raw or stalling) ? color.black : color.white

    // VPoC row
    float vpoc_dist_pct = not na(vpoc) ? (vpoc - close) / close * 100 : na
    color vpoc_col = na(vpoc) ? color.new(color.gray, 60) : vpoc > close ? color.new(#00e676, 20) : color.new(#ff7043, 20)
    string vpoc_txt = na(vpoc) ? "—" : str.tostring(vpoc, "#.######") + " (" + (vpoc > close ? "+" : "") + str.tostring(math.round(vpoc_dist_pct, 1)) + "%)"
    string vpoc_t1_txt = vpoc_t1_active ? "VPoC" : "EMA"
    color t1_src_col = vpoc_t1_active ? color.new(#dd44ff, 10) : color.new(color.gray, 60)

    table.cell(t, 0, 0, "Alignment", bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, align_txt,   bgcolor=align_col,                  text_color=color.black, text_size=size.small)
    table.cell(t, 0, 1, "Slope/c",   bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, slope_txt,   bgcolor=slope_col,                  text_color=color.black, text_size=size.normal)
    table.cell(t, 0, 2, "Vol Ratio", bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, vol_txt,     bgcolor=vol_col,                    text_color=color.black, text_size=size.normal)
    table.cell(t, 0, 3, "Signal",    bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3, str_txt,     bgcolor=str_col,                    text_color=color.black, text_size=size.normal)
    table.cell(t, 0, 4, "Stalling",  bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 4, stall_txt,   bgcolor=stall_col,                  text_color=stall_tc,    text_size=size.small)
    table.cell(t, 0, 5, "VPoC",      bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 5, vpoc_txt,    bgcolor=vpoc_col,                   text_color=color.black, text_size=size.small)
    table.cell(t, 0, 6, "T1 Source", bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 6, vpoc_t1_txt, bgcolor=t1_src_col,                 text_color=color.white, text_size=size.small)

    string pat_txt = not na(bull_name) ? "▲ " + bull_name : not na(bear_name) ? "▼ " + bear_name : "—"
    color  pat_col = not na(bull_name) ? color.new(#00e676, 10) : not na(bear_name) ? color.new(#ff7043, 10) : color.new(color.gray, 60)
    table.cell(t, 0, 7, "Pattern",   bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 7, pat_txt,     bgcolor=pat_col,                    text_color=color.black, text_size=size.small)

    string dt_txt = daily_up ? "▲ Up · exits held" : "▼ Down/flat · exits live"
    color  dt_col = daily_up ? color.new(#00e676, 10) : color.new(#ff7043, 20)
    table.cell(t, 0, 8, "Daily Trend", bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 8, dt_txt,        bgcolor=dt_col,                    text_color=color.black, text_size=size.small)

// ── POSITION STATE MANAGEMENT ─────────────────────────────────────────────────
if buy_entry or anticipate_entry or (t1_recovery and not was_in_pos)
    in_pos   := true
    p_entry  := close
    p_sl     := close * (1 - sl_pct)
    p_t1     := bull_t1
    p_t2     := bull_t2
    p_t1_hit := false

if was_in_pos
    if not na(bull_t2) and bull_t2 > p_t2
        p_t2 := bull_t2
    if not na(bull_t1) and not was_t1_hit and bull_t1 > p_t1
        p_t1 := bull_t1
    if t2_exit
        in_pos := false
    else if t1_milestone
        p_t1_hit := true
        p_sl     := p_entry
    else if sl_exit or bear_exit
        in_pos := false
````
