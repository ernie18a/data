# Nick's IB Break/Extension/Retest v3

- url: https://www.tradingview.com/script/xB4JV02s-Nick-s-IB-Break-Extension-Retest-v3/
- type: indicator
- pine_id: PUB;9ef8b6fd2cf94f24bee0034bf6a81c1c
- version: 1.0

## Description

Initial Balance — Break / Extension / Retest (with continuation odds)
This indicator turns the first-hour Initial Balance behavior into a live decision-support tool. It marks the IB (09:30–10:30 ET by default), watches for the post-10:30 break, tracks how far price extends beyond the IB in fractions of the IB range (1.1× to 1.5×), and flags the first retest back to the IB level — then stamps the historical continuation base rate for the extension that was reached, colored by depth (shallow retests = green/likely re-entry, deep retests = red/likely top).
The continuation percentages are drawn from TradingStats 12-year NQ IB study. They are reach/continuation rates, not win rates — no stops or targets are modeled. Treat the numbers as context for a discretionary decision, not a signal with a proven edge.
Filters (all optional, all toggleable): a regime-EMA gate (only flag breaks that agree with the trend), a break-timing window, a minimum-extension requirement, MACD divergence (pre-kill before the retest + post-void after), and a MACD slope/level kill with an immediate-slope reprieve. Killed setups are tagged with the reason so you can see which filter acted. An optional RSI pop/dip trigger flags a precise entry after a valid retest.
Intrabar note (important): break/extension/retest/entry are detected by walking the 1-minute path inside each chart bar, so the sequence is read in true order rather than inferred from bar OHLC. As a result, signals on the currently-forming bar update as 1-minute bars print and are final only on bar close. Historical signals do not change. Run on a 3–15 minute chart (the chart timeframe must be higher than the intrabar timeframe).

Credits: continuation statistics from the TradingStats 12-year NQ first-hour IB study.

## Source Code

````pine
//@version=6
indicator(title="Nick's IB Break/Extension/Retest v3", shorttitle="Nick's IB BXR v3", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ═════════════════════════════════════════════════════════════════════
//  NICK'S IB BREAK / EXTENSION / RETEST  —  V3
//  V2 + three things:
//   • 1-MINUTE INTRABAR WALK. Break / extension / retest / entry are now
//     detected by walking the 1-min path INSIDE each chart bar, in order —
//     so a same-bar break→extend→retest is seen correctly, not guessed from
//     bar OHLC. Detection is 1-min accurate; labels sit on the containing bar.
//   • RSI ENTRY TRIGGER. After a VALID retest, watch fast RSI (len 4). A dip
//     to ≤15 (after up-break) fires LONG; a pop to ≥85 (after down-break)
//     fires SHORT. This is the actionable entry with a definable stop — the
//     retest gives the zone/odds, the RSI extreme gives the timing.
//   • IB SHADING = noop42 style. Shades only the IB high→low box over the
//     formation hour (not a full-height vertical band).
//
//  Still a context/odds tool — the study models no stops. INTRABAR CAVEAT:
//  on the live forming bar, intrabar signals update as 1-min bars print and
//  are final only on chart-bar close (inherent to any intrabar method).
//  Chart timeframe must be ≥ the intrabar timeframe (run on 3–15 min).
// ═════════════════════════════════════════════════════════════════════

// ── Session
grpS = "Session"
tz       = input.string("America/New_York", "Timezone", group=grpS)
ib_sess  = input.session("0930-1030", "Initial Balance window", group=grpS)
rth_sess = input.session("0930-1600", "RTH window", group=grpS)

// ── Core logic
grpL = "Logic"
tol_sel  = input.string("25% band", "Retest tolerance", options=["10% band", "25% band"], group=grpL)
min_ext  = input.float(1.1, "Min extension to flag retest (1.x)", minval=1.0, step=0.1, group=grpL)

// ── Intrabar
grpI = "Intrabar Walk"
use_intrabar = input.bool(true, "Walk intrabar (1-min path inside each bar)", group=grpI)
ltf          = input.timeframe("1", "Intrabar timeframe", group=grpI, tooltip="Must be lower than the chart timeframe. 1-min matches the study's break detection.")

// ── RSI entry
grpE = "RSI Entry (after retest)"
use_rsi_entry = input.bool(false, "Enable RSI pop/dip entry", group=grpE)
rsi_len       = input.int(4, "Fast RSI length", minval=1, group=grpE)
rsi_long_th   = input.float(15, "Long: RSI dips to ≤", minval=1, maxval=50, group=grpE)
rsi_short_th  = input.float(85, "Short: RSI pops to ≥", minval=50, maxval=99, group=grpE)
entry_window  = input.int(20, "Entry valid for N bars after retest", minval=1, group=grpE)

// ── 1. Regime EMA gate
grpR = "1 · Regime EMA Gate"
use_ema_gate  = input.bool(true, "Enable regime-EMA gate", group=grpR)
regime_len    = input.int(50, "Regime EMA length", minval=2, group=grpR)
regime_slope_lb = input.int(10, "Regime slope lookback (bars)", minval=1, group=grpR)

// ── 2. Timing window
grpT = "2 · Timing Window"
use_timing    = input.bool(true, "Enable timing window", group=grpT)
break_window  = input.session("1030-1300", "Break must occur within this window", group=grpT)

// ── 4. MACD + divergence
grpM = "4 · MACD + Divergence"
macd_fast = input.int(12, "MACD fast", minval=1, group=grpM)
macd_slow = input.int(26, "MACD slow", minval=1, group=grpM)
macd_sig  = input.int(9,  "MACD signal", minval=1, group=grpM)
div_lbL   = input.int(5, "Divergence pivot left", minval=1, group=grpM)
div_lbR   = input.int(5, "Divergence pivot right", minval=1, group=grpM)
use_div_prekill = input.bool(true, "PRE-KILL on against-divergence before the retest", group=grpM)
use_div_void    = input.bool(true, "POST-VOID on against-divergence within N bars after", group=grpM)
div_void_n      = input.int(10, "Void window (bars after signal)", minval=1, group=grpM)

// ── 5. MACD slope/level kill
grpK = "5 · MACD Slope / Level Kill"
use_slope_kill = input.bool(true, "Enable MACD slope/level kill", group=grpK)
kill_level     = input.float(40, "MACD extreme level (±)", step=1, group=grpK)
slope_n        = input.int(10, "Slope lookback N (bars)", minval=1, group=grpK)
use_slope_reprieve = input.bool(true, "Reprieve: skip the kill if the IMMEDIATE MACD slope has turned favorable", group=grpK, tooltip="The kill catches MACD rolling over from an extreme. But if MACD has already curled back the signal's way by the time it fires, cancel the kill. Uses a short immediate-slope lookback.")
slope_recent_n     = input.int(1, "Immediate slope lookback (bars)", minval=1, group=grpK, tooltip="1 = compare MACD to the prior bar. Raise to 2-3 if a single up/down tick reprieves too eagerly.")

// ── Visuals
grpV = "Visuals"
show_ib_zone = input.bool(false, "Shade IB window vertically (calc period)", group=grpV)
show_ib_fill = input.bool(true,  "Shade IB high→low box (noop42 style)", group=grpV)
show_ladder  = input.bool(true, "Show extension ladder", group=grpV)
show_lvl_lbl = input.bool(true, "Label ladder lines", group=grpV)
lvl_lbl_size = input.string("Normal", "Ladder label size", options=["Tiny","Small","Normal","Large"], group=grpV)
show_band    = input.bool(true, "Shade retest tolerance band", group=grpV)
show_break   = input.bool(true, "Break label", group=grpV)
show_retest  = input.bool(true, "Retest label (with odds)", group=grpV)
show_killed  = input.bool(true, "Mark killed retests (Void + reason)", group=grpV)
col_ib    = input.color(color.new(#673ab7, 81), "IB calc-period band", group=grpV)
col_ibfill= input.color(color.new(#b8851f, 76), "IB high→low box", group=grpV)
col_lvl   = input.color(color.new(color.blue, 0),   "IB high/low", group=grpV)
col_ext   = input.color(color.new(color.purple, 0), "Extension ladder", group=grpV)
col_good  = input.color(color.new(color.lime, 0),   "Shallow retest", group=grpV)
col_mid   = input.color(color.new(color.yellow, 0), "Mid retest", group=grpV)
col_bad   = input.color(color.new(color.red, 0),    "Deep retest", group=grpV)
col_void  = input.color(color.new(color.red, 0),    "VOID / kill", group=grpV)
col_long  = input.color(color.new(#00e676, 0),      "LONG entry", group=grpV)
col_short = input.color(color.new(#ff1744, 0),      "SHORT entry", group=grpV)
lvlsz = lvl_lbl_size == "Tiny" ? size.tiny : lvl_lbl_size == "Small" ? size.small : lvl_lbl_size == "Large" ? size.large : size.normal

// ═════════════════════════════════════════════
//  TIME / SESSION
// ═════════════════════════════════════════════
bool in_ib  = not na(time(timeframe.period, ib_sess,  tz))
bool in_rth = not na(time(timeframe.period, rth_sess, tz))
bool ib_start_now = in_ib and not in_ib[1]
bool ib_end_now   = not in_ib and in_ib[1]
float tol_frac = tol_sel == "10% band" ? 0.10 : 0.25
int   tol_pct  = tol_sel == "10% band" ? 10 : 25

// ═════════════════════════════════════════════
//  CHART-TF CONTEXT: MACD + divergence, regime, slope kill
// ═════════════════════════════════════════════
[macd_line, macd_signal, macd_hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)

oscPH = ta.pivothigh(macd_line, div_lbL, div_lbR)
oscPL = ta.pivotlow(macd_line, div_lbL, div_lbR)
var float lastOscPH = na
var float lastPxPH   = na
var float lastOscPL = na
var float lastPxPL   = na
bool bearDiv = false
bool bullDiv = false
if not na(oscPH)
    if not na(lastOscPH)
        bearDiv := oscPH < lastOscPH and high[div_lbR] > lastPxPH
    lastOscPH := oscPH
    lastPxPH  := high[div_lbR]
if not na(oscPL)
    if not na(lastOscPL)
        bullDiv := oscPL > lastOscPL and low[div_lbR] < lastPxPL
    lastOscPL := oscPL
    lastPxPL  := low[div_lbR]

regime_ema   = ta.ema(close, regime_len)
regime_slope = regime_ema - regime_ema[regime_slope_lb]

bool macd_was_above = ta.highest(macd_line, slope_n) >=  kill_level
bool macd_was_below = ta.lowest(macd_line, slope_n)  <= -kill_level
// immediate slope: is MACD already curling back the signal's way at fire time?
bool recent_up   = macd_line > macd_line[slope_recent_n]
bool recent_down = macd_line < macd_line[slope_recent_n]
bool up_reprieve   = use_slope_reprieve and recent_up    // long: MACD turning up now
bool down_reprieve = use_slope_reprieve and recent_down  // short: MACD turning down now
bool up_slope_kill   = macd_was_above and macd_line < macd_line[slope_n] and not up_reprieve
bool down_slope_kill = macd_was_below and macd_line > macd_line[slope_n] and not down_reprieve

// ═════════════════════════════════════════════
//  IB STATE (levels computed on chart bars; walk uses intrabar path)
// ═════════════════════════════════════════════
var float ib_high   = na
var float ib_low    = na
var float ib_range  = na
var bool  ib_locked = false
var int   ib_start_bar = na
var int   break_dir = 0
var int   break_bar = na
var bool  break_in_window = false
var float max_ext   = 1.0
var bool  retested  = false
var bool  div_against_pending = false
// entry + void state
var bool  await_entry = false
var int   entry_dir = 0
var int   entry_arm_bar = na
var bool  entry_done = false
var float prev_rsi = na
var bool  void_pending = false
var int   void_bar = na
var int   void_dir = 0
var float void_px  = na

if ib_start_now
    ib_high := high
    ib_low  := low
    ib_range := na
    ib_locked := false
    ib_start_bar := bar_index
    break_dir := 0
    max_ext := 1.0
    retested := false
    div_against_pending := false
    await_entry := false
    entry_done := false

if in_ib and not ib_start_now
    ib_high := math.max(ib_high, high)
    ib_low  := math.min(ib_low, low)

if ib_end_now
    ib_locked := true
    ib_range  := ib_high - ib_low

bool active = ib_locked and in_rth and not in_ib and ib_range > 0

// ═════════════════════════════════════════════
//  ODDS LOOKUP
// ═════════════════════════════════════════════
f_band(e) => e < 1.15 ? 1.1 : e < 1.25 ? 1.2 : e < 1.35 ? 1.3 : e < 1.45 ? 1.4 : 1.5
f_tradeable(e) =>
    b = f_band(e)
    tol_pct == 25 ? (b == 1.1 ? 62 : b == 1.2 ? 49 : b == 1.3 ? 38 : b == 1.4 ? 30 : 25) : (b == 1.1 ? 45 : b == 1.2 ? 32 : b == 1.3 ? 24 : b == 1.4 ? 19 : 16)
f_eventually(e) =>
    b = f_band(e)
    b == 1.1 ? 82 : b == 1.2 ? 70 : b == 1.3 ? 59 : b == 1.4 ? 49 : 40
f_depthcol(e) =>
    b = f_band(e)
    b <= 1.2 ? col_good : b == 1.3 ? col_mid : col_bad

// ═════════════════════════════════════════════
//  INTRABAR ARRAYS
// ═════════════════════════════════════════════
array<float> a_high = request.security_lower_tf(syminfo.tickerid, ltf, high)
array<float> a_low  = request.security_lower_tf(syminfo.tickerid, ltf, low)
array<float> a_rsi  = request.security_lower_tf(syminfo.tickerid, ltf, ta.rsi(close, rsi_len))
float rsi_ctf = ta.rsi(close, rsi_len)

int  n_sub  = array.size(a_high)
bool use_arr = use_intrabar and n_sub > 0
int  iters   = use_arr ? n_sub : 1

// ═════════════════════════════════════════════
//  THE WALK — break / extension / retest / entry, in intrabar order
// ═════════════════════════════════════════════
if active
    for i = 0 to iters - 1
        float hh = use_arr ? array.get(a_high, i) : high
        float ll = use_arr ? array.get(a_low, i)  : low
        float rr = use_arr ? array.get(a_rsi, i)  : rsi_ctf
        if not na(hh) and not na(ll)
            // BREAK (first only)
            if break_dir == 0
                if hh > ib_high
                    break_dir := 1
                    break_bar := bar_index
                    break_in_window := not na(time(timeframe.period, break_window, tz))
                else if ll < ib_low
                    break_dir := -1
                    break_bar := bar_index
                    break_in_window := not na(time(timeframe.period, break_window, tz))
            // EXTENSION
            if break_dir == 1 and hh > ib_high
                max_ext := math.max(max_ext, 1 + (hh - ib_high) / ib_range)
            if break_dir == -1 and ll < ib_low
                max_ext := math.max(max_ext, 1 + (ib_low - ll) / ib_range)
            // RETEST (first pullback back to the IB level, after arming)
            bool armed = max_ext >= min_ext
            if not retested and armed and ((break_dir == 1 and ll <= ib_high) or (break_dir == -1 and hh >= ib_low))
                retested := true
                float e = max_ext
                bool clean = break_dir == 1 ? ll >= ib_high - tol_frac * ib_range : hh <= ib_low + tol_frac * ib_range
                bool regime_ok = not use_ema_gate or (break_dir == 1 ? regime_slope > 0 : regime_slope < 0)
                bool timing_ok = not use_timing or break_in_window
                bool ext_ok    = max_ext >= min_ext
                bool killed_div   = use_div_prekill and div_against_pending
                bool killed_slope = use_slope_kill and (break_dir == 1 ? up_slope_kill : down_slope_kill)
                bool valid = regime_ok and timing_ok and ext_ok and not killed_div and not killed_slope
                if valid and show_retest
                    int trd = f_tradeable(e)
                    int evt = f_eventually(e)
                    string txt = (clean ? "Retest ✓ " : "Retest ✗ ") + str.tostring(f_band(e), "#.0") + "x → " + str.tostring(trd) + "% (" + str.tostring(tol_pct) + "% band) · " + str.tostring(evt) + "% evt"
                    label.new(bar_index, break_dir == 1 ? ll : hh, txt, color=f_depthcol(e), textcolor=color.black, style=break_dir == 1 ? label.style_label_up : label.style_label_down, size=size.small)
                else if not valid and show_killed
                    string why = not regime_ok ? "regime conflict" : not timing_ok ? "late break" : not ext_ok ? "shallow extension" : killed_div ? "MACD divergence" : "MACD slope conflict"
                    label.new(bar_index, break_dir == 1 ? ll : hh, "Void " + why, color=col_void, textcolor=color.white, style=break_dir == 1 ? label.style_label_up : label.style_label_down, size=size.normal)
                if valid
                    await_entry := true
                    entry_dir := break_dir
                    entry_arm_bar := bar_index
                    entry_done := false
                    void_pending := true
                    void_bar := bar_index
                    void_dir := break_dir
                    void_px  := break_dir == 1 ? ll : hh
            // RSI ENTRY (after a valid retest, within the window)
            if use_rsi_entry and await_entry and not entry_done and not na(prev_rsi)
                bool long_trig  = entry_dir == 1  and prev_rsi > rsi_long_th  and rr <= rsi_long_th
                bool short_trig = entry_dir == -1 and prev_rsi < rsi_short_th and rr >= rsi_short_th
                if long_trig
                    label.new(bar_index, ll, "▲ LONG", color=col_long, textcolor=color.white, style=label.style_label_up, size=size.normal)
                    entry_done := true
                    await_entry := false
                if short_trig
                    label.new(bar_index, hh, "▼ SHORT", color=col_short, textcolor=color.white, style=label.style_label_down, size=size.normal)
                    entry_done := true
                    await_entry := false
            prev_rsi := rr

// entry window expiry (chart-bar level)
if await_entry and (bar_index - entry_arm_bar) > entry_window
    await_entry := false

// against-divergence between break and retest (chart-TF divergence)
if active and break_dir != 0 and not retested
    if (break_dir == 1 and bearDiv) or (break_dir == -1 and bullDiv)
        div_against_pending := true

// POST-VOID: against-divergence confirmed within N bars after a valid signal
if void_pending and (bar_index - void_bar) > div_void_n
    void_pending := false
bool against_div_now = void_dir == 1 ? bearDiv : bullDiv
if use_div_void and void_pending and bar_index > void_bar and against_div_now and (bar_index - void_bar) <= div_void_n
    label.new(void_bar, void_px, "Void divergence", color=col_void, textcolor=color.white, style=void_dir == 1 ? label.style_label_up : label.style_label_down, size=size.normal)
    void_pending := false

// ═════════════════════════════════════════════
//  VISUALS
// ═════════════════════════════════════════════
// optional full-height vertical band (off by default)
bgcolor(show_ib_zone and in_ib ? col_ib : na, title="IB calc window")

// IB high→low box over the formation hour (noop42 style) — one per day, kept
if ib_end_now and show_ib_fill
    box.new(ib_start_bar, ib_high, bar_index, ib_low, border_color=color.new(col_lvl, 55), bgcolor=col_ibfill)

// IB high/low lines (extend right across the session)
plot(active ? ib_high : na, "IB High", color=col_lvl, style=plot.style_linebr, linewidth=2)
plot(active ? ib_low  : na, "IB Low",  color=col_lvl, style=plot.style_linebr, linewidth=2)

// extension ladder
f_lvl(x) => break_dir == 1 ? ib_high + x * ib_range : break_dir == -1 ? ib_low - x * ib_range : na
bool ladder_on = show_ladder and active and break_dir != 0
plot(ladder_on ? f_lvl(0.1) : na, "1.1x", color=col_ext, style=plot.style_linebr)
plot(ladder_on ? f_lvl(0.2) : na, "1.2x", color=col_ext, style=plot.style_linebr)
plot(ladder_on ? f_lvl(0.3) : na, "1.3x", color=col_ext, style=plot.style_linebr)
plot(ladder_on ? f_lvl(0.4) : na, "1.4x", color=col_ext, style=plot.style_linebr)
plot(ladder_on ? f_lvl(0.5) : na, "1.5x", color=col_ext, style=plot.style_linebr)

// ladder labels — once per day at the break bar (shows on every day)
bool break_fired = active and break_dir != 0 and break_dir[1] == 0
if show_ladder and show_lvl_lbl and break_fired
    label.new(bar_index, f_lvl(0.1), "1.1x", color=color.new(col_ext, 75), textcolor=color.white, style=label.style_label_left, size=lvlsz)
    label.new(bar_index, f_lvl(0.2), "1.2x", color=color.new(col_ext, 75), textcolor=color.white, style=label.style_label_left, size=lvlsz)
    label.new(bar_index, f_lvl(0.3), "1.3x", color=color.new(col_ext, 75), textcolor=color.white, style=label.style_label_left, size=lvlsz)
    label.new(bar_index, f_lvl(0.4), "1.4x", color=color.new(col_ext, 75), textcolor=color.white, style=label.style_label_left, size=lvlsz)
    label.new(bar_index, f_lvl(0.5), "1.5x", color=color.new(col_ext, 75), textcolor=color.white, style=label.style_label_left, size=lvlsz)

// tolerance band
float band_near = break_dir == 1 ? ib_high : break_dir == -1 ? ib_low : na
float band_far  = break_dir == 1 ? ib_high - tol_frac * ib_range : break_dir == -1 ? ib_low + tol_frac * ib_range : na
p_near = plot(show_band and ladder_on ? band_near : na, "Band near", color=color.new(col_lvl, 60), style=plot.style_linebr)
p_far  = plot(show_band and ladder_on ? band_far  : na, "Band far",  color=color.new(col_lvl, 60), style=plot.style_linebr)
fill(p_near, p_far, show_band and ladder_on ? color.new(col_lvl, 92) : na, title="Tolerance band")

// break label
if show_break and break_fired
    label.new(bar_index, break_dir == 1 ? ib_high : ib_low, (break_dir == 1 ? "▲ Break" : "▼ Break") + "  " + str.format_time(time, "HH:mm", tz), color=color.new(color.gray, 20), textcolor=color.white, style=break_dir == 1 ? label.style_label_down : label.style_label_up, size=size.small)

// ── Data window
plot(ib_range, "IB Range (R)", display=display.data_window)
plot(max_ext,  "Max extension (1.x)", display=display.data_window)
plot(rsi_ctf,  "Fast RSI (chart TF)", display=display.data_window)
plot(n_sub,    "Intrabar sub-bars", display=display.data_window)
plot(regime_slope, "Regime slope", display=display.data_window)
````
