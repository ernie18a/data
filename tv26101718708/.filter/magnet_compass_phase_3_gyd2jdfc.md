# Magnet Compass Phase 3

- url: https://www.tradingview.com/script/gyD2jdFC-Magnet-Compass-Phase-3/
- type: indicator
- pine_id: PUB;e926c0ade56b44a1896e913a695c09a6
- version: 1.0

## Description

MAGNET COMPASS
An intraday scalping system for NQ, ES, and GC futures, designed for a 30-second chart. It identifies 15-minute "magnet" candles at key session times — moments when one extreme of the candle has a measurable empirical bias to get tagged within the next 15 minutes — and arms trades only when live conditions agree with that bias.
═══════════════════════════════
THE IDEA IN ONE LINE
At each 15-minute close in a known magnet bucket, the indicator checks whether live features (close location, VWAP side, HTF trend) agree with the historical first-hit bias for that bucket. If they agree and the close sits in the mid-band of its range, it arms a trade toward the bias-side extreme.
═══════════════════════════════
WHY TWO LAYERS (PRIOR + LIVE)
The historical bias alone gives a 5–19 percentage-point edge on which extreme gets tagged first — real, but too small to trade on. A live-feature filter that vetoes the days when current conditions argue the other way is what turns the prior into a tradable setup.
From the underlying feature analysis:

Close location only matters in the middle of the range. At the extremes it's geometric noise ("close at the high → high gets hit trivially").
VWAP side and the bucket prior carry the real signal. HTF EMA trend is near-noise but kept as a tiebreaker.

So an entry fires only when: armed bucket + prior agrees with live score + close in mid-band + |score| ≥ 2.
═══════════════════════════════
SYMBOL COVERAGE
Auto-detects from chart symbol — no input changes needed.

NQ1! — 16 buckets (London 03:45, RTH 09:30–14:00, Asia 20:00–21:15)
ES1! — 19 buckets (London 03:00–04:00, RTH 09:30–14:00, Asia 20:00–21:15)
GC1! — 12 buckets (RTH 09:30–15:00, no London/Asia)

All times ET.
═══════════════════════════════
HOW TO READ THE CHART
Every 15 minutes an info label appears on the magnet candle:
Bkt 11:30 AM   ARM ↑HIGH
Prior HIGH +19.3 | clLoc 0.42 | vwap +1 | htf +1 | score +4

Bkt — the 15-minute close time
ARM / SKIP — armed direction, or skip reason
Prior — bias side and signed edge (percentage points)
clLoc — close location in the candle (0 = low, 1 = high). Tradable band is 0.30–0.70.
vwap / htf — feature scores (−1, 0, or +1, signed toward HIGH-first)
score — sum of features. Need |score| ≥ 2 and same sign as prior to arm.

Lines drawn at each armed window:

Aqua solid — magnet high and low (anchored to the actual bars that made the extremes)
Gray dashed — midline (50% of magnet range)
On entry: yellow entry, lime target, red stop
WIN / LOSS labels at exit

The execution window is background-shaded only when the system armed for that bucket.
═══════════════════════════════
ARM CONDITIONS
All must hold at the confirmed 15-minute close:

Bucket has a non-zero prior
Prior and live features agree (same sign)
clLoc is between 0.30 and 0.70
|live score| ≥ 2
If "NY only" mode is on, bucket falls between 09:30 and 15:45 ET

═══════════════════════════════
ENTRY AND EXIT
Entry fires on the first confirmed 30-second bar after the 15-minute close (~30 seconds after). Skipped if that bar already wicks the bias-side extreme.
Stop styles (5 options):

Opposite extreme (default) — widest stops, ≈1:1 R:R, highest win-rate
Midline — half the loss size, but more stop-outs
Fixed ticks — entry ± N ticks
ATR — k × 15-minute ATR
Nearest unswept swing — closest swing past entry that hasn't been violated since forming; falls back to opposite extreme if none available

Target: bias-side magnet extreme by default, or midline (toggle).
Window close: if the trade is still open at the next 15-minute close, it's classified by the last 30-second close vs entry. Past entry = WIN, otherwise LOSS. Ties count as LOSS.
═══════════════════════════════
SCALP MODE (SETUP A — SWEEP FADE)
Optional toggle that flips the model for fade-style scalps. Instead of trading toward the bias-side magnet, it fades it: bias HIGH → resting SHORT limit at magnet high + buffer, targeting the midline. Fixed point-based stops/targets (default 12/12). Optional half-off at 1R, breakeven shift, and runner scale.
Backed by an extended-stat finding that the midpoint mean-reverts ~79% of the time after the magnet candle.
═══════════════════════════════
NON-REPAINTING
Uses request.security with [1] and lookahead_on — the canonical non-repainting pattern for HTF data. All state changes are gated to barstate.isconfirmed. Signals are identical in historical and real-time/replay.
Trade-off: entries fire on the first confirmed 30-second bar after the 15-minute close (~30s later) rather than instantly.
═══════════════════════════════
CUSTOMIZATION

Every visible element has its own color picker (magnet lines, midline, entry/stop/target, ARM/SKIP backgrounds, label text, table colors).
Both tables — live stats and reference bucket list — have 8-position placement dropdowns.
Toggles for every visual: lines, info labels, WIN/LOSS labels, window shading, both tables.

═══════════════════════════════
HONEST CAVEATS

This is a win-rate-dependent system with ~1:1 R:R, not a payoff-dependent one. A small drop in win-rate kills the edge.
The leaderboard priors are snapshots from a specific data window. They need periodic refresh as more data accumulates.
Window-close reclassification slightly understates loss magnitude when the exit lands near entry (fees and slippage not modeled).
Forward-test on sim until you've logged 50+ resolved trades. Small samples don't tell you much.

═══════════════════════════════
DISCLAIMER
For educational and research purposes only. Not financial advice. Past performance of any backtested setup does not guarantee future results. Trade your own account.

## Source Code

````pine
//@version=5
// ============================================================================
// Magnet Compass — Phase 3 (v12)
// New in v12 — Setup A: Magnet Sweep Fade (scalp mode)
//   - Optional scalp_mode that REPLACES the swing-target entry logic with:
//       * Bias side INVERTED: bias HIGH → place SELL limit at magH+buf
//         (we fade the tag back toward midline, not trade toward it).
//       * Fixed point-based target/stop (default 12/12 NQ pts).
//       * Resting limit entry (no market fill on first bar).
//       * Optional scale-out: half at 1R → stop to BE → runner.
//       * Magnet-range gate: skip buckets whose H-L is below threshold so
//         the 12pt target stays a clean fade (not a chase past opposite extreme).
//   - Data backing: 78.92% midpoint mean-reversion (extended-stats #6) +
//     +15 first-hit bias for timing of which side tags first.
//   - Stats split into wins / partial-wins / losses to keep scalp accounting
//     separate from the swing-mode v11 tracker.
//   - Swing-mode entry path (v11) is preserved; toggle scalp_mode to switch.
// ============================================================================
indicator("Magnet Compass — Phase 3", overlay=true, max_lines_count=500, max_labels_count=500)

// ---- Inputs: entry rules ----------------------------------------------------
i_min_score     = input.int   (2,    "Min |live_score| to arm (1-4)", minval=1, maxval=4, group="Entry rules")
i_mid_low       = input.float (0.30, "Mid-band low (clLoc)",  minval=0.0, maxval=0.5, step=0.05, group="Entry rules")
i_mid_high      = input.float (0.70, "Mid-band high (clLoc)", minval=0.5, maxval=1.0, step=0.05, group="Entry rules")

// ---- Inputs: stop / target --------------------------------------------------
i_stop_style    = input.string("Opposite extreme", "Stop style", options=["Opposite extreme","Midline","Fixed ticks","ATR (15m × k)","Nearest swing low/high"], group="Stop / target")
i_stop_buf_tk   = input.int   (1,    "Buffer beyond stop level (ticks)", minval=0, maxval=50, group="Stop / target")
i_stop_fixed_tk = input.int   (16,   "Fixed-ticks stop distance",  minval=1, maxval=400, group="Stop / target")
i_stop_atr_k    = input.float (0.5,  "ATR multiplier (15m)", minval=0.1, maxval=3.0, step=0.1, group="Stop / target")
i_swing_left    = input.int   (1,    "Swing pivot left bars",  minval=1, maxval=10, group="Stop / target")
i_swing_right   = input.int   (1,    "Swing pivot right bars", minval=1, maxval=10, group="Stop / target")
i_target_at_mid = input.bool  (false,"Target at midline instead of opposite extreme", group="Stop / target")
i_ny_only       = input.bool  (false,"Restrict to NY session only (9:30am - 4:00pm ET)", group="Entry rules")

// ---- Inputs: display toggles + table positions ------------------------------
i_show_lines    = input.bool  (true, "Draw magnet H/L extended lines", group="Display")
i_show_label    = input.bool  (true, "Show info label per window",     group="Display")
i_show_outcome  = input.bool  (true, "Plot WIN/LOSS labels",           group="Display")
i_show_window_bg = input.bool (true, "Shade execution-window background", group="Display")
i_show_stats    = input.bool  (true, "Show rolling stats table",       group="Display")
i_show_buckets  = input.bool  (true, "Show reference-candle list",     group="Display")
i_stats_pos     = input.string("top_right", "Stats table position", options=["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group="Display")
i_bucket_pos    = input.string("bottom_right", "Reference-list position", options=["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group="Display")

// ---- Inputs: scalp mode (Setup A — Sweep Fade) ------------------------------
i_scalp_mode       = input.bool (false, "Scalp mode (fade magnet sweep, fixed pts)", group="Scalp mode", tooltip="REPLACES swing-target entry. Bias side is INVERTED — bias HIGH means we SELL at the magnet high to fade the tag back toward midline. Data backing: 78.92% midpoint mean-reversion + +15 first-hit bias.")
i_scalp_target_pts = input.float(12.0, "Target (points)",        minval=1.0, maxval=50.0, step=0.25, group="Scalp mode")
i_scalp_stop_pts   = input.float(12.0, "Stop (points)",          minval=1.0, maxval=50.0, step=0.25, group="Scalp mode")
i_scalp_buf_ticks  = input.int  (2,    "Limit offset beyond magnet (ticks)", minval=0, maxval=20, group="Scalp mode", tooltip="Limit price is placed buf*mintick beyond magH (for short) or below magL (for long). NQ mintick = 0.25, so 2 ticks = 0.5 pt.")
i_scalp_min_range  = input.float(16.0, "Min magnet range required (points)", minval=0.0, maxval=100.0, step=1.0, group="Scalp mode", tooltip="Skip armed buckets whose magnet H-L is below this. Keeps the 12pt fade target inside the magnet structure rather than a blind chase past opposite extreme.")
i_scalp_scale      = input.bool (false, "Scale: half at 1R, stop→BE, runner", group="Scalp mode")
i_scalp_runner_pts = input.float(22.0, "Runner target (points)", minval=1.0, maxval=80.0, step=0.5, group="Scalp mode", tooltip="Only used when scale is on. After 1R partial and BE move, full target shifts here.")

// ---- Inputs: style colors (Inputs tab — TV won't let line/label colors live in Style tab) ----
i_col_magnet    = input.color(color.aqua,           "Magnet H/L lines",       group="Style")
i_col_midline   = input.color(color.new(color.gray, 30), "Midline",           group="Style")
i_col_window_bg = input.color(color.new(color.blue, 92), "Execution-window bg", group="Style")
i_col_entry     = input.color(color.yellow,         "Entry line",             group="Style")
i_col_stop      = input.color(color.red,            "Stop line / LOSS",       group="Style")
i_col_target    = input.color(color.lime,           "Target line / WIN",      group="Style")
i_col_long      = input.color(color.new(color.green, 0), "LONG label",        group="Style")
i_col_short     = input.color(color.new(color.red, 0),   "SHORT label",       group="Style")
i_col_arm       = input.color(color.new(color.green, 20), "ARM info bg",      group="Style")
i_col_skip      = input.color(color.new(color.gray, 60),  "SKIP info bg",     group="Style")
i_col_text      = input.color(color.white,          "Label text color",       group="Style")
i_col_high_side = input.color(color.aqua,           "Bias HIGH (table)",      group="Style")
i_col_low_side  = input.color(color.fuchsia,        "Bias LOW (table)",       group="Style")
i_col_edge      = input.color(color.yellow,         "Edge value (table)",     group="Style")
i_col_tbl_bg    = input.color(color.new(color.black, 60), "Table background", group="Style")

tz = "America/New_York"

// ---- Symbol detection -------------------------------------------------------
sym  = syminfo.ticker
isNQ = str.contains(sym, "NQ")
isES = str.contains(sym, "ES")
isGC = str.contains(sym, "GC")

// ---- Bias prior table -------------------------------------------------------
bias_prior(bool _isNQ, bool _isES, bool _isGC, int bkt) =>
    float e = 0.0
    if _isNQ
        if      bkt ==  345
            e := 7.30
        else if bkt ==  930
            e := 4.62
        else if bkt ==  945
            e := 11.22
        else if bkt == 1000
            e := 15.56
        else if bkt == 1015
            e := 13.68
        else if bkt == 1030
            e := -5.44
        else if bkt == 1045
            e := 11.50
        else if bkt == 1100
            e := 5.02
        else if bkt == 1130
            e := 19.30
        else if bkt == 1200
            e := 8.56
        else if bkt == 1300
            e := 5.34
        else if bkt == 1400
            e := 9.32
        else if bkt == 2000
            e := 17.27
        else if bkt == 2030
            e := 6.36
        else if bkt == 2045
            e := 10.91
        else if bkt == 2115
            e := 11.41
    if _isES
        if      bkt ==  300
            e := 3.10
        else if bkt ==  330
            e := 11.12
        else if bkt ==  345
            e := 16.56
        else if bkt ==  400
            e := 5.42
        else if bkt ==  930
            e := 5.02
        else if bkt ==  945
            e := 8.67
        else if bkt == 1000
            e := 6.85
        else if bkt == 1015
            e := 7.30
        else if bkt == 1030
            e := -3.65
        else if bkt == 1045
            e := 4.11
        else if bkt == 1130
            e := 15.22
        else if bkt == 1200
            e := 10.36
        else if bkt == 1300
            e := 8.38
        else if bkt == 1400
            e := 9.64
        else if bkt == 2000
            e := 21.14
        else if bkt == 2030
            e := 12.14
        else if bkt == 2045
            e := 13.26
        else if bkt == 2100
            e := 6.84
        else if bkt == 2115
            e := 11.24
    if _isGC
        if      bkt ==  930
            e := 8.44
        else if bkt ==  945
            e := 5.48
        else if bkt == 1000
            e := 7.50
        else if bkt == 1015
            e := 13.10
        else if bkt == 1030
            e := 5.14
        else if bkt == 1045
            e := 9.08
        else if bkt == 1100
            e := 13.14
        else if bkt == 1130
            e := 9.08
        else if bkt == 1200
            e := -7.34
        else if bkt == 1230
            e := 8.28
        else if bkt == 1400
            e := 12.82
        else if bkt == 1500
            e := 14.80
    // NY session filter: 9:30 AM - 4:00 PM ET (last ref candle is 15:45)
    if i_ny_only and (bkt < 930 or bkt > 1545)
        e := 0.0
    e

// ---- 12-hour time formatters ------------------------------------------------
fmt_bkt_12(int b) =>
    int h = b / 100
    int m = b - h * 100
    int h12 = h % 12 == 0 ? 12 : h % 12
    string ampm = h < 12 ? "AM" : "PM"
    str.tostring(h12) + ":" + (m < 10 ? "0" + str.tostring(m) : str.tostring(m)) + " " + ampm

fmt_window_12(int b) =>
    int h = int(math.floor(b / 100))
    int m = b - h * 100
    int m2 = m + 15
    int h2 = h + (m2 >= 60 ? 1 : 0)
    int mEnd = m2 % 60
    int hEnd = h2 % 24
    int hStart12 = h % 12 == 0 ? 12 : h % 12
    int hEnd12 = hEnd % 12 == 0 ? 12 : hEnd % 12
    string ampStart = h < 12 ? "AM" : "PM"
    string ampEnd   = hEnd < 12 ? "AM" : "PM"
    string a = str.tostring(hStart12) + ":" + (m < 10 ? "0" + str.tostring(m) : str.tostring(m))
    string c = str.tostring(hEnd12) + ":" + (mEnd < 10 ? "0" + str.tostring(mEnd) : str.tostring(mEnd))
    ampStart == ampEnd ? (a + "→" + c + " " + ampStart) : (a + ampStart + "→" + c + ampEnd)

// Edge formatter — Pine's "+#.#" format outputs "-+5.4" for negative values.
// Workaround: build the sign manually.
fmt_edge(float e) =>
    (e >= 0 ? "+" : "") + str.tostring(e, "#.#")

get_pos(string s) =>
    switch s
        "top_left" => position.top_left
        "top_center" => position.top_center
        "top_right" => position.top_right
        "middle_left" => position.middle_left
        "middle_right" => position.middle_right
        "bottom_left" => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right" => position.bottom_right
        => position.top_right

// ---- HTF context (NON-REPAINTING) -------------------------------------------
htf = "15"
[h15, l15, c15, o15, t15] = request.security(syminfo.tickerid, htf, [high[1], low[1], close[1], open[1], time[1]], lookahead=barmerge.lookahead_on)
ema20_15 = request.security(syminfo.tickerid, htf, ta.ema(close, 20)[1], lookahead=barmerge.lookahead_on)
ema50_15 = request.security(syminfo.tickerid, htf, ta.ema(close, 50)[1], lookahead=barmerge.lookahead_on)
atr15    = request.security(syminfo.tickerid, htf, ta.atr(14)[1],        lookahead=barmerge.lookahead_on)
v30 = ta.vwap(hlc3)
isNew15m = timeframe.change(htf)

// ---- Swing-high / swing-low UNSWEPT tracker --------------------------------
// "A swing high is a candle with lower highs on both sides." Confirmed
// `rightbars` after the pivot forms — non-repainting.
// "Unswept" = price has not retraced through the swing since it formed.
//   - A swing LOW at price P is swept when a later bar's low <= P.
//   - A swing HIGH at price P is swept when a later bar's high >= P.
// We keep arrays of still-active swing prices and remove on sweep.
var array<float> swingLows  = array.new<float>()
var array<float> swingHighs = array.new<float>()
ph = ta.pivothigh(high, i_swing_left, i_swing_right)
pl = ta.pivotlow (low,  i_swing_left, i_swing_right)
if barstate.isconfirmed
    if not na(pl)
        array.unshift(swingLows, pl)
        if array.size(swingLows) > 50
            array.pop(swingLows)
    if not na(ph)
        array.unshift(swingHighs, ph)
        if array.size(swingHighs) > 50
            array.pop(swingHighs)
    // Sweep removal — walk backwards so removals don't break indices
    if array.size(swingLows) > 0
        for i = array.size(swingLows) - 1 to 0
            if low <= array.get(swingLows, i)
                array.remove(swingLows, i)
    if array.size(swingHighs) > 0
        for i = array.size(swingHighs) - 1 to 0
            if high >= array.get(swingHighs, i)
                array.remove(swingHighs, i)

// Nearest unswept swing low BELOW reference (highest active < ref) — for long stop
nearest_unswept_low(float ref) =>
    float best = na
    if array.size(swingLows) > 0
        for i = 0 to array.size(swingLows) - 1
            float v = array.get(swingLows, i)
            if v < ref and (na(best) or v > best)
                best := v
    best

// Nearest unswept swing high ABOVE reference (lowest active > ref) — for short stop
nearest_unswept_high(float ref) =>
    float best = na
    if array.size(swingHighs) > 0
        for i = 0 to array.size(swingHighs) - 1
            float v = array.get(swingHighs, i)
            if v > ref and (na(best) or v < best)
                best := v
    best

// ---- Active-window state ----------------------------------------------------
var int    w_magTime    = na
var float  w_magH       = na
var float  w_magL       = na
var float  w_magC       = na
var float  w_magMid     = na
var float  w_magAtr     = na
var int    w_bkt        = na
var float  w_priorEdge  = na
var int    w_priorSign  = 0
var float  w_clLoc      = na
var int    w_vwapSide   = 0
var int    w_htfTrend   = 0
var int    w_liveScore  = 0
var bool   w_armed      = false
var int    w_armSide    = 0
var int    w_bars       = na
var bool   w_entered    = false
var float  w_entryPx    = na
var float  w_stopPx     = na
var float  w_tgtPx      = na
var int    w_entryBar   = na
var string w_outcome    = na

var line lnH = na
var line lnL = na
var line lnMid = na
var line lnEntry = na
var line lnStop = na
var line lnTgt = na
var label infoLab = na

var int s_armed = 0
var int s_entered = 0
var int s_wins = 0
var int s_losses = 0

// ---- Scalp-mode state (Setup A) --------------------------------------------
var float w_limitPx       = na
var float w_1rPx          = na
var bool  w_partial_taken = false
var line  lnLimit         = na
var int   s_scalp_armed    = 0
var int   s_scalp_filled   = 0
var int   s_scalp_wins     = 0    // full target hit (or runner if scale)
var int   s_scalp_partials = 0    // partial taken then stopped at BE
var int   s_scalp_losses   = 0    // stopped before 1R

del_line(line ln) =>
    if not na(ln)
        line.delete(ln)
del_label(label lb) =>
    if not na(lb)
        label.delete(lb)

// ---- Stop calculator (uses globals: i_stop_*, lastSwing*) -------------------
calc_stop(int side, float magH, float magL, float magMid, float magAtr, float entryPx) =>
    float buf = i_stop_buf_tk * syminfo.mintick
    float s = na
    if i_stop_style == "Opposite extreme"
        s := side > 0 ? (magL - buf) : (magH + buf)
    else if i_stop_style == "Midline"
        s := side > 0 ? (magMid - buf) : (magMid + buf)
    else if i_stop_style == "Fixed ticks"
        float dist = i_stop_fixed_tk * syminfo.mintick + buf
        s := side > 0 ? (entryPx - dist) : (entryPx + dist)
    else if i_stop_style == "ATR (15m × k)"
        float dist = (na(magAtr) ? 0.0 : magAtr) * i_stop_atr_k + buf
        s := side > 0 ? (entryPx - dist) : (entryPx + dist)
    else if i_stop_style == "Nearest swing low/high"
        if side > 0
            float sl = nearest_unswept_low(entryPx)
            s := na(sl) ? (magL - buf) : (sl - buf)
        else
            float sh = nearest_unswept_high(entryPx)
            s := na(sh) ? (magH + buf) : (sh + buf)
    s

// =============================================================================
// Main loop (confirmed bars only)
// =============================================================================
if barstate.isconfirmed
    if isNew15m
        // Window just ended. If the trade was entered but didn't hit
        // target or stop, classify by end-of-window price vs entry:
        //   LONG : close[1] > entry → WIN, else LOSS
        //   SHORT: close[1] < entry → WIN, else LOSS
        // close[1] is the close of the last 30s bar of the just-ended window.
        if w_entered and na(w_outcome)
            float endPx = close[1]
            float diff = endPx - w_entryPx
            bool _isLong = w_armSide > 0
            // Partial already locked in +0.5R; runner flattening at endPx
            // remains a WIN net unless endPx is enough worse to drown the partial.
            bool _win = w_partial_taken or (_isLong ? diff > 0 : diff < 0)
            if i_scalp_mode
                if _win
                    w_outcome := "WIN"
                    s_scalp_wins += 1
                    if i_show_outcome
                        label.new(bar_index - 1, endPx, "WIN +" + str.tostring(math.abs(diff), format.mintick), style=label.style_label_left, color=i_col_target, textcolor=color.black, size=size.tiny)
                else
                    w_outcome := "LOSS"
                    s_scalp_losses += 1
                    if i_show_outcome
                        label.new(bar_index - 1, endPx, "LOSS -" + str.tostring(math.abs(diff), format.mintick), style=label.style_label_left, color=i_col_stop, textcolor=i_col_text, size=size.tiny)
            else
                if _isLong ? diff > 0 : diff < 0
                    w_outcome := "WIN"
                    s_wins += 1
                    if i_show_outcome
                        label.new(bar_index - 1, endPx, "WIN +" + str.tostring(math.abs(diff), format.mintick), style=label.style_label_left, color=i_col_target, textcolor=color.black, size=size.tiny)
                else
                    w_outcome := "LOSS"
                    s_losses += 1
                    if i_show_outcome
                        label.new(bar_index - 1, endPx, "LOSS -" + str.tostring(math.abs(diff), format.mintick), style=label.style_label_left, color=i_col_stop, textcolor=i_col_text, size=size.tiny)
        del_line(lnH)
        del_line(lnL)
        del_line(lnMid)
        del_line(lnEntry)
        del_line(lnStop)
        del_line(lnTgt)
        del_label(infoLab)
        w_magTime   := t15
        w_magH      := h15
        w_magL      := l15
        w_magC      := c15
        w_magAtr    := atr15
        rng         = w_magH - w_magL
        w_magMid    := (w_magH + w_magL) / 2.0
        w_clLoc     := rng > 0 ? (w_magC - w_magL) / rng : 0.5
        w_bkt       := hour(w_magTime, tz) * 100 + minute(w_magTime, tz)
        w_priorEdge := bias_prior(isNQ, isES, isGC, w_bkt)
        w_priorSign := w_priorEdge > 0 ? 1 : w_priorEdge < 0 ? -1 : 0
        w_vwapSide  := not na(v30[1]) ? (w_magC > v30[1] ? 1 : -1) : 0
        w_htfTrend  := not na(ema20_15) and not na(ema50_15) ? (ema20_15 > ema50_15 ? 1 : (ema20_15 < ema50_15 ? -1 : 0)) : 0
        score_loc   = w_clLoc >= 0.6 ? 1 : (w_clLoc <= 0.4 ? -1 : 0)
        score_vwap  = w_vwapSide
        score_htf   = w_htfTrend
        score_prior = w_priorSign
        w_liveScore := score_loc + score_vwap + score_htf + score_prior
        has_prior     = w_priorSign != 0
        agree         = math.sign(w_liveScore) == w_priorSign
        in_mid_band   = w_clLoc >= i_mid_low and w_clLoc <= i_mid_high
        strong_enough = math.abs(w_liveScore) >= i_min_score
        w_armed   := has_prior and agree and in_mid_band and strong_enough
        // Scalp-mode extra gate: magnet must be wide enough that 12pt fade
        // doesn't blow past the opposite extreme.
        if i_scalp_mode and w_armed
            float rng_pts = w_magH - w_magL
            if rng_pts < i_scalp_min_range
                w_armed := false
        // In scalp mode we FADE the bias side. Bias HIGH (priorSign=+1) means
        // we expect HIGH to be tagged → place SELL limit there → armSide = -1.
        w_armSide := w_armed ? (i_scalp_mode ? -w_priorSign : w_priorSign) : 0
        w_bars    := 0
        w_entered := false
        w_entryPx := na
        w_stopPx  := na
        w_tgtPx   := na
        w_1rPx    := na
        w_entryBar := na
        w_outcome := w_armed ? na : "SKIP"
        w_partial_taken := false
        del_line(lnLimit)
        // Pre-place the scalp limit at the magnet sweep level
        if i_scalp_mode and w_armed
            float buf = i_scalp_buf_ticks * syminfo.mintick
            w_limitPx := w_armSide < 0 ? (w_magH + buf) : (w_magL - buf)
            lnLimit := line.new(bar_index, w_limitPx, bar_index + 30, w_limitPx, color=i_col_entry, width=1, style=line.style_dotted)
            s_scalp_armed += 1
        else
            w_limitPx := na
        if w_armed and not i_scalp_mode
            s_armed += 1

        // ---- Draw magnet H/L lines anchored to actual high/low bars --------
        if i_show_lines
            int hOff = 30
            int lOff = 30
            float bestHigh = na
            float bestLow  = na
            for i = 1 to 30
                if na(bestHigh) or high[i] > bestHigh
                    bestHigh := high[i]
                    hOff := i
                if na(bestLow) or low[i] < bestLow
                    bestLow := low[i]
                    lOff := i
            int xEnd = bar_index + 30
            lnH   := line.new(bar_index - hOff, w_magH,   xEnd, w_magH,   color=i_col_magnet, width=2)
            lnL   := line.new(bar_index - lOff, w_magL,   xEnd, w_magL,   color=i_col_magnet, width=2)
            lnMid := line.new(bar_index,        w_magMid, xEnd, w_magMid, color=i_col_midline, style=line.style_dashed)

        if i_show_label
            prior_side_txt = w_priorSign > 0 ? "HIGH" : w_priorSign < 0 ? "LOW" : "—"
            verb           = i_scalp_mode ? "FADE " : "ARM "
            arm_txt        = w_armed ? verb + (w_armSide > 0 ? "↑LONG" : "↓SHORT") : "SKIP"
            small_range    = i_scalp_mode and has_prior and agree and in_mid_band and strong_enough and (w_magH - w_magL) < i_scalp_min_range
            skip_reason    = not has_prior ? "no prior" : not agree ? "disagree" : not in_mid_band ? "edge band" : not strong_enough ? "weak score" : small_range ? "tight range" : ""
            vwap_txt = w_vwapSide > 0 ? "+1" : w_vwapSide < 0 ? "-1" : "0"
            htf_txt  = w_htfTrend > 0 ? "+1" : w_htfTrend < 0 ? "-1" : "0"
            score_txt = w_liveScore > 0 ? "+" + str.tostring(w_liveScore) : str.tostring(w_liveScore)
            line_a = "Bkt " + str.tostring(w_bkt) + "  " + arm_txt + (w_armed ? "" : " (" + skip_reason + ")")
            line_b = "Prior " + prior_side_txt + " " + fmt_edge(w_priorEdge) + " | clLoc " + str.tostring(w_clLoc, "#.##") + " | vwap " + vwap_txt + " | htf " + htf_txt + " | score " + score_txt
            infoLab := label.new(bar_index, w_magH, line_a + "\n" + line_b, style=label.style_label_lower_left, color=w_armed ? i_col_arm : i_col_skip, textcolor=i_col_text, size=size.small, textalign=text.align_left)

    else if not na(w_magTime)
        w_bars := na(w_bars) ? 1 : w_bars + 1

        // ===== SCALP MODE branch (Setup A — Sweep Fade) =====
        if i_scalp_mode
            // ---- limit fill check ----
            if w_armed and not w_entered and not na(w_limitPx)
                bool is_short_fade = w_armSide < 0
                bool filled = is_short_fade ? (high >= w_limitPx) : (low <= w_limitPx)
                if filled
                    w_entered  := true
                    w_entryPx  := w_limitPx
                    w_entryBar := bar_index
                    float full_dist = i_scalp_scale ? i_scalp_runner_pts : i_scalp_target_pts
                    w_stopPx := is_short_fade ? (w_entryPx + i_scalp_stop_pts) : (w_entryPx - i_scalp_stop_pts)
                    w_tgtPx  := is_short_fade ? (w_entryPx - full_dist)        : (w_entryPx + full_dist)
                    w_1rPx   := i_scalp_scale ? (is_short_fade ? (w_entryPx - i_scalp_target_pts) : (w_entryPx + i_scalp_target_pts)) : na
                    s_scalp_filled += 1
                    int x2 = bar_index + math.max(1, 30 - w_bars)
                    lnEntry := line.new(bar_index, w_entryPx, x2, w_entryPx, color=i_col_entry, width=2)
                    lnStop  := line.new(bar_index, w_stopPx,  x2, w_stopPx,  color=i_col_stop,  width=1, style=line.style_dashed)
                    lnTgt   := line.new(bar_index, w_tgtPx,   x2, w_tgtPx,   color=i_col_target,width=1, style=line.style_dashed)
                    label.new(bar_index, w_entryPx, (is_short_fade ? "▼ FADE SHORT" : "▲ FADE LONG") + " @" + str.tostring(w_entryPx, format.mintick), style=is_short_fade ? label.style_label_down : label.style_label_up, color=is_short_fade ? i_col_short : i_col_long, textcolor=i_col_text, size=size.small)

            // ---- trade management ----
            if w_entered and na(w_outcome)
                bool is_long_s = w_armSide > 0
                // Same-bar precedence: if a single 30s bar straddles both stop
                // and target, count it as LOSS (conservative).
                bool hit_stop_s   = is_long_s ? low  <= w_stopPx : high >= w_stopPx
                bool hit_target_s = is_long_s ? high >= w_tgtPx  : low  <= w_tgtPx
                bool hit_1r       = i_scalp_scale and not w_partial_taken and not na(w_1rPx) and (is_long_s ? high >= w_1rPx : low <= w_1rPx)

                // Scale: take partial at 1R FIRST (before stop check),
                // then move stop to BE for the remainder.
                if hit_1r and not hit_stop_s
                    w_partial_taken := true
                    w_stopPx        := w_entryPx
                    s_scalp_partials += 1
                    if i_show_outcome
                        label.new(bar_index, w_1rPx, "1R +" + str.tostring(i_scalp_target_pts, "#.#"), style=label.style_label_left, color=i_col_target, textcolor=color.black, size=size.tiny)

                if hit_stop_s
                    // Stop after partial = BE for the runner (+0.5R net from partial → WIN classification)
                    if w_partial_taken
                        w_outcome := "WIN"
                        s_scalp_wins += 1
                        if i_show_outcome
                            label.new(bar_index, w_stopPx, "BE (+" + str.tostring(i_scalp_target_pts / 2.0, "#.#") + "R net)", style=label.style_label_left, color=i_col_target, textcolor=color.black, size=size.tiny)
                    else
                        w_outcome := "LOSS"
                        s_scalp_losses += 1
                        if i_show_outcome
                            label.new(bar_index, w_stopPx, "LOSS -" + str.tostring(math.abs(w_stopPx - w_entryPx), format.mintick), style=label.style_label_left, color=i_col_stop, textcolor=i_col_text, size=size.tiny)
                else if hit_target_s
                    w_outcome := "WIN"
                    s_scalp_wins += 1
                    if i_show_outcome
                        label.new(bar_index, w_tgtPx, "WIN +" + str.tostring(math.abs(w_tgtPx - w_entryPx), format.mintick), style=label.style_label_left, color=i_col_target, textcolor=color.black, size=size.tiny)

        // ===== SWING MODE branch (v11 behavior, unchanged) =====
        else
            if w_armed and not w_entered and w_bars == 1
                already_hit = w_armSide > 0 ? high >= w_magH : low <= w_magL
                if not already_hit
                    w_entered  := true
                    w_entryPx  := open
                    w_entryBar := bar_index
                    target_px  = i_target_at_mid ? w_magMid : (w_armSide > 0 ? w_magH : w_magL)
                    w_stopPx   := calc_stop(w_armSide, w_magH, w_magL, w_magMid, w_magAtr, w_entryPx)
                    w_tgtPx    := target_px
                    s_entered  += 1
                    x2 = bar_index + (30 - w_bars)
                    lnEntry := line.new(bar_index, w_entryPx, x2, w_entryPx, color=i_col_entry, width=2)
                    lnStop  := line.new(bar_index, w_stopPx,  x2, w_stopPx,  color=i_col_stop,  width=1, style=line.style_dashed)
                    lnTgt   := line.new(bar_index, w_tgtPx,   x2, w_tgtPx,   color=i_col_target,width=1, style=line.style_dashed)
                    label.new(bar_index, w_entryPx, (w_armSide > 0 ? "▲ LONG" : "▼ SHORT") + " @" + str.tostring(w_entryPx, format.mintick), style=w_armSide > 0 ? label.style_label_up : label.style_label_down, color=w_armSide > 0 ? i_col_long : i_col_short, textcolor=i_col_text, size=size.small)

            if w_entered and na(w_outcome)
                is_long    = w_armSide > 0
                hit_target = is_long ? high >= w_tgtPx  : low  <= w_tgtPx
                hit_stop   = is_long ? low  <= w_stopPx : high >= w_stopPx
                if hit_stop
                    w_outcome := "LOSS"
                    s_losses += 1
                    if i_show_outcome
                        label.new(bar_index, w_stopPx, "LOSS -" + str.tostring(math.abs(w_stopPx - w_entryPx), format.mintick), style=label.style_label_left, color=i_col_stop, textcolor=i_col_text, size=size.tiny)
                else if hit_target
                    w_outcome := "WIN"
                    s_wins += 1
                    if i_show_outcome
                        label.new(bar_index, w_tgtPx, "WIN +" + str.tostring(math.abs(w_tgtPx - w_entryPx), format.mintick), style=label.style_label_left, color=i_col_target, textcolor=color.black, size=size.tiny)

// =============================================================================
// Execution-window background shading
// On a 30s chart, a new 15m reference candle closes every 30 bars, so EVERY
// bar is inside some +15m window — shading all of them would tint everything.
// Instead, only shade windows where the system is ARMED (a trade can fire).
// =============================================================================
in_window = not na(w_magTime) and not na(w_bars) and w_armed and w_bars >= 0 and w_bars <= 30
bgcolor(i_show_window_bg and in_window ? i_col_window_bg : na)

// =============================================================================
// Stats table — user-positioned
// =============================================================================
var table stbl = table.new(get_pos(i_stats_pos), columns=2, rows=8, bgcolor=i_col_tbl_bg, border_width=1)
if i_show_stats and barstate.islast
    table.set_position(stbl, get_pos(i_stats_pos))
    table.cell(stbl, 0, 0, "Magnet Compass", text_color=i_col_text, text_size=size.small)
    table.cell(stbl, 1, 0, i_scalp_mode ? "v12 SCALP" : "v12 swing", text_color=color.gray, text_size=size.small)
    if i_scalp_mode
        int s_decided = s_scalp_wins + s_scalp_losses
        float s_wr = s_decided > 0 ? (s_scalp_wins / float(s_decided)) * 100.0 : na
        string tgt_str = i_scalp_scale ? (str.tostring(i_scalp_target_pts, "#.#") + "→" + str.tostring(i_scalp_runner_pts, "#.#")) : str.tostring(i_scalp_target_pts, "#.#")
        table.cell(stbl, 0, 1, "tgt / stop", text_color=i_col_text)
        table.cell(stbl, 1, 1, tgt_str + " / " + str.tostring(i_scalp_stop_pts, "#.#") + "pt", text_color=i_col_text)
        table.cell(stbl, 0, 2, "armed",    text_color=i_col_text)
        table.cell(stbl, 1, 2, str.tostring(s_scalp_armed), text_color=i_col_text)
        table.cell(stbl, 0, 3, "filled",   text_color=i_col_text)
        table.cell(stbl, 1, 3, str.tostring(s_scalp_filled), text_color=i_col_text)
        table.cell(stbl, 0, 4, "wins",     text_color=i_col_target)
        table.cell(stbl, 1, 4, str.tostring(s_scalp_wins),   text_color=i_col_target)
        table.cell(stbl, 0, 5, "partials", text_color=i_col_target)
        table.cell(stbl, 1, 5, str.tostring(s_scalp_partials), text_color=i_col_target)
        table.cell(stbl, 0, 6, "losses",   text_color=i_col_stop)
        table.cell(stbl, 1, 6, str.tostring(s_scalp_losses), text_color=i_col_stop)
        table.cell(stbl, 0, 7, "win%",     text_color=i_col_edge)
        table.cell(stbl, 1, 7, na(s_wr) ? "—" : str.tostring(s_wr, "#.#") + "%", text_color=i_col_edge)
    else
        int decided = s_wins + s_losses
        float wr = decided > 0 ? (s_wins / float(decided)) * 100.0 : na
        table.cell(stbl, 0, 1, "stop",     text_color=i_col_text)
        table.cell(stbl, 1, 1, i_stop_style, text_color=i_col_text)
        table.cell(stbl, 0, 2, "armed",    text_color=i_col_text)
        table.cell(stbl, 1, 2, str.tostring(s_armed), text_color=i_col_text)
        table.cell(stbl, 0, 3, "entered",  text_color=i_col_text)
        table.cell(stbl, 1, 3, str.tostring(s_entered), text_color=i_col_text)
        table.cell(stbl, 0, 4, "wins",     text_color=i_col_target)
        table.cell(stbl, 1, 4, str.tostring(s_wins),   text_color=i_col_target)
        table.cell(stbl, 0, 5, "losses",   text_color=i_col_stop)
        table.cell(stbl, 1, 5, str.tostring(s_losses), text_color=i_col_stop)
        table.cell(stbl, 0, 6, "win%",     text_color=i_col_edge)
        table.cell(stbl, 1, 6, na(wr) ? "—" : str.tostring(wr, "#.#") + "%", text_color=i_col_edge)

// =============================================================================
// Reference candles + trading windows (12-hour AM/PM)
// =============================================================================
all_buckets = array.from(300, 330, 345, 400, 930, 945, 1000, 1015, 1030, 1045, 1100, 1130, 1200, 1230, 1300, 1400, 1500, 2000, 2030, 2045, 2100, 2115)

var table btbl = table.new(get_pos(i_bucket_pos), columns=3, rows=25, bgcolor=i_col_tbl_bg, border_width=1)
if i_show_buckets and barstate.islast
    table.set_position(btbl, get_pos(i_bucket_pos))
    table.cell(btbl, 1, 0, "Side", text_color=i_col_text, text_size=size.small)
    table.cell(btbl, 2, 0, "Edge", text_color=i_col_text, text_size=size.small)
    int row = 1
    for i = 0 to array.size(all_buckets) - 1
        int b = array.get(all_buckets, i)
        float e = bias_prior(isNQ, isES, isGC, b)
        if e != 0 and row < 25
            string side = e > 0 ? "HIGH" : "LOW"
            color sideCol = e > 0 ? i_col_high_side : i_col_low_side
            table.cell(btbl, 0, row, fmt_window_12(b), text_color=i_col_text, text_size=size.tiny)
            table.cell(btbl, 1, row, side, text_color=sideCol, text_size=size.tiny)
            table.cell(btbl, 2, row, fmt_edge(e), text_color=i_col_edge, text_size=size.tiny)
            row += 1
    table.cell(btbl, 0, 0, sym + " ref → +15m  (" + str.tostring(row - 1) + ")", text_color=i_col_text, text_size=size.small)
````
