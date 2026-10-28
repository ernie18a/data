# Distributional Shift Sentinel  Wasserstein Regime Monitor

- url: https://www.tradingview.com/script/malN2e4O-Distributional-Shift-Sentinel-Wasserstein-Regime-Monitor/
- type: indicator
- pine_id: PUB;3041bc33647946fdaf22a0a1d56e3fbe
- version: 2.0

## Description

Distributional-Shift Sentinel — Wasserstein Regime Monitor

Detects when the SHAPE of returns changes — not just the average or the variance. It claims a change, never a direction.

What it does

Most regime tools watch a moving average or a volatility band, so they only react to changes in LEVEL or SPREAD. But a market can keep the same mean and variance while its return distribution quietly changes shape — skew flips, tails fatten, the character of the auction turns. Those are the shifts that moment-based tools see late. This sentinel compares the recent return distribution against a reference window using the Wasserstein-1 ("earth-mover") distance — a metric sensitive to the whole shape — and raises a flag when the shape has moved unusually far.

How it works, and why these components together

This is a deliberate synthesis of three parts, each covering the previous one's weakness:


The Wasserstein-1 distance (optimal-transport statistics: Monge; Kantorovich). For one-dimensional data it is simply the average gap between the two windows' matched order-statistics: sort both return windows and average the absolute differences. Unlike KL/JS divergence it registers both the location and the magnitude of the difference, so a fattening tail or a skew flip shows up even when mean and variance are unchanged. Weakness it leaves open: the raw number is meaningless in isolation — "0.4" is not a shift.
A self-calibrated alarm. The distance is normalized by the reference dispersion (comparable across symbols) and ranked against its own recent history; a shift is flagged only when the reading is unusually large for this symbol and timeframe (percentile input). No fixed magic threshold. Weakness it leaves open: readings near the alarm line flicker.
A minimum-dwell announcement filter (the standard anti-chattering design from switched-systems control): SHIFT/STABLE is announced only after surviving a set number of confirmed bars. Cost: that many bars of lag — stated and adjustable.


When a shift fires, the dashboard decomposes it into what moved — location (median), scale (dispersion), shape (skew) — so the flag is informative, not just a light.

How to read it (all visuals)


Shift lane — the thin strip at the pane bottom: amber = distribution shifted, green = stable. Alert colors (change/normal), never direction. The one-glance read.
Dashboard — SHIFT/STABLE headline; shift rank; normalized distance; DRIVER (loc/scale/shape); STABILITY (% of the last 50 bars in the current state); PENDING (a forming state with countdown); windows and alarm settings.
HTF STACK — the raw shift state on three higher timeframes derived as multiples of the chart (defaults 3×, 5×, 15× — a 5m chart reads 15m/25m/75m automatically). ✓ = every timeframe agrees; ⚠ = a higher timeframe has shifted while the chart looks stable — a shape change above your resolution. Note: the deeper slots need many bars of their own timeframe (reference + calibration windows), so they warm up slowly on intraday charts; "—" for a while is correct.
SHIFT tags print on announced changes; a subtle background tint marks shifted spans.


How to use it

Treat a SHIFT as an early warning to widen stops, cut size, or re-evaluate any model or setup that assumed the old regime — not as a buy or sell. It pairs naturally with trend, structure, and fragility tools: they tell you what the regime is; this tells you when the regime's distributional character stopped being what it was. Alerts fire on shift start and shift end.

Non-repaint

Windows, the distance, the alarm, and all state announcements advance only on CONFIRMED bars; the live bar is provisional. Higher-timeframe requests use lookahead-off. No lower-timeframe data is used anywhere, so the script runs identically on every plan and symbol.

Use on any market

Price source, return type, window lengths, and the alarm percentile are all inputs; the metric is scale-relative (normalized by reference dispersion). Defaults suit liquid intraday index futures.

Originality & credits

The synthesis — sorted-sample Wasserstein-1 on a rolling chart window, dispersion normalization, self-calibrated percentile alarm, dwell-filtered state, driver decomposition, and the multi-timeframe stack — is original work for this publication. Concept credits: optimal transport / earth-mover distance — G. Monge, L. Kantorovich; Wasserstein two-sample comparison for change/drift detection — standard optimal-transport statistics literature. Implementation and charting design are the author's own.

Disclaimer

Research and education only. NOT financial advice, NOT a signal service, NOT a guarantee of future results. A detected shift is a descriptive statement about the past distribution on this chart; it does not predict direction or magnitude. Regimes change without warning. Validate independently and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  DISTRIBUTIONAL-SHIFT SENTINEL                                            v1.1
//  Detects when the SHAPE of returns changes — not just the average or variance.
// -----------------------------------------------------------------------------
//  v1.1 — House-standard pass (no engine change):
//    • Replaced two conditional ta.ema calls (na(x) ? na : ta.ema) with a seed-on-first-valid
//      manual EMA that runs every bar — clears CW10004; output is unchanged after warm-up.
//    • Added the MPL-2.0 licence header and an EXP_ Data-Window export bus.
//    • No cost model: this is a descriptive regime monitor, not a directional signal tool.
// -----------------------------------------------------------------------------
//  THE IDEA
//    Most "regime" tools watch a moving average or a volatility band, so they
//    only react to changes in LEVEL or SPREAD. But a market can keep the same
//    mean and variance while its return distribution quietly changes SHAPE —
//    skew flips, tails fatten, the character of the auction turns. Those are the
//    shifts that precede the nasty surprises moment-based tools see late.
//    This sentinel compares the recent return distribution against a reference
//    window using the WASSERSTEIN-1 distance ("earth-mover" distance) — a metric
//    sensitive to the whole shape, not only the first two moments — and raises a
//    flag when the shape has moved unusually far. It claims a CHANGE, never a
//    direction.
//
//  HOW IT WORKS (and why this metric)
//    For one-dimensional data the Wasserstein-1 distance is simply the average
//    work needed to turn one sorted sample into the other: sort both windows and
//    average the absolute gap between matched order-statistics. Unlike KL / JS
//    divergence it accounts for both the location AND the magnitude of the
//    difference, so a fattening tail or a skew flip registers even when mean and
//    variance are unchanged. The two windows are equal length, so the estimate is
//    a clean mean-absolute-difference of sorted samples.
//
//  THE HONESTY STEP — SELF-CALIBRATED ALARM
//    A raw Wasserstein number is meaningless in isolation ("0.4" is not a shift).
//    The empirical distance also converges slowly, so a fixed threshold would be
//    arbitrary. Instead the sentinel ranks the current distance against its OWN
//    recent history (a percentile), and flags a shift only when it is unusually
//    large for this symbol and timeframe. The alarm self-tunes; you set how rare
//    "unusual" should be.
//
//  DIAGNOSTIC BREAKDOWN
//    When a shift fires, the dashboard decomposes it into what moved —
//    LOCATION (median), SCALE (dispersion) and SHAPE (skew) — so the flag is
//    informative, not just a light.
//
//  HOW TO READ IT (price overlay)
//    A shaded background marks bars where the return distribution is unusually
//    far from its reference. Treat it as an early-warning to widen stops, cut
//    size, or re-evaluate any model that assumed the old regime — not as a buy or
//    sell. Pairs naturally with trend, structure and fragility tools.
//
//  NON-REPAINT
//    Windows, the distance and the alarm advance only on CONFIRMED bars; the live
//    bar is provisional.
//
//  USE ON ANY MARKET
//    Return source, window lengths and the alarm percentile are all inputs; the
//    metric is scale-relative. Defaults suit liquid intraday futures.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Optimal transport / earth-mover distance — G. Monge; L. Kantorovich.
//    • Wasserstein two-sample comparison for change / drift detection — standard
//      optimal-transport statistics literature.
//    Implementation and charting design are the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. A detected shift is a descriptive
//    statement about the past distribution on this chart; it does not predict
//    direction or magnitude. Validate independently and manage your own risk.
// =============================================================================
indicator("Distributional-Shift Sentinel — Wasserstein Regime Monitor", "Shift Sentinel",
     overlay = true, max_labels_count = 200, max_bars_back = 5000)

// ═════════════════════════ 00 · DATA SOURCE ═════════════════════════════════
g0 = "00 · Data source"
srcPrice = input.source(close, "Price source", group = g0,
     tooltip = "Series whose returns are monitored. Default close; change for spreads or custom symbols.")
retMode  = input.string("Log return", "Return type", options = ["Log return", "Percent", "Price change"], group = g0,
     tooltip = "How each bar's return is measured before comparing distributions.")

// ═════════════════════════ 01 · WINDOWS ═════════════════════════════════════
g1 = "01 · Comparison windows"
recentLen = input.int(50,  "Recent window", minval = 10, maxval = 500, group = g1,
     tooltip = "The just-happened distribution: the most recent N returns.")
refLen    = input.int(250, "Reference window", minval = 30, maxval = 2000, group = g1,
     tooltip = "The baseline distribution the recent window is compared against (older returns, ending where the recent window begins).")

// ═════════════════════════ 02 · ALARM (self-calibrated) ═════════════════════
g2 = "02 · Alarm"
alarmPct = input.float(90.0, "Alarm percentile", minval = 50.0, maxval = 99.9, step = 1.0, group = g2,
     tooltip = "A shift is flagged when the current distance ranks above this percentile of its own recent history. 90 = the most extreme ~10% of readings. Higher = rarer, stronger flags.")
alarmLook= input.int(300, "Alarm calibration lookback", minval = 50, maxval = 2000, group = g2,
     tooltip = "How far back the distance percentile is measured, so the alarm self-tunes to this symbol / timeframe.")
smoothLen= input.int(3, "Distance smoothing", minval = 1, maxval = 20, group = g2,
     tooltip = "Light smoothing of the raw distance to reduce single-bar jitter.")

// ═════════════════════════ 03 · STABILITY & OUTPUT ══════════════════════════
g3 = "03 · Stability & output"
minDwell = input.int(5, "Confirm state after (bars)", minval = 1, maxval = 50, group = g3,
     tooltip = "Minimum-dwell debounce (standard anti-chattering design): SHIFT/STABLE is ANNOUNCED only after it survives this many confirmed bars. Removes flicker at the alarm threshold at the cost of this many bars of lag — both stated.")
showLane = input.bool(true, "Shift lane (strip at pane bottom)", group = g3,
     tooltip = "A thin colored strip along the bottom: amber = distribution shifted, green = stable. Alert colors (change/normal), never direction.")
showTint  = input.bool(true, "Background shift tint", group = g3)
showTag   = input.bool(true, "Tag on new shift", group = g3)
showDist  = input.bool(true, "Plot distance in status line", group = g3,
     tooltip = "Adds the (scaled) distance and its alarm level as hidden plots for the status line / data window.")

// ═════════════════════════ 04 · DASHBOARD ═══════════════════════════════════
g4 = "04 · Dashboard"
showDash  = input.bool(true, "Show main dashboard", group = g4)
compactTbl= input.bool(false, "Compact dashboard", group = g4)
dashPos   = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g4)
showId    = input.bool(false, "Show name / symbol / timeframe label (separate table)", group = g4)

// ═════════════════════════ 05 · MULTI-TIMEFRAME ═════════════════════════════
g5m = "05 · Multi-timeframe stack"
mtfOn = input.bool(true, "Show higher-timeframe shift states", group = g5m,
     tooltip = "Computes the RAW shift state (no dwell — higher timeframes are inherently slower) on three higher timeframes derived as MULTIPLES of the chart. NOTE: the deepest slots need many bars of their own timeframe (reference + calibration windows), so they warm up slowly on intraday charts — '—' for a while is correct. Standard HTF requests — every plan and symbol.")
mtfM1 = input.int(3,  "HTF multiple 1 (× chart)", minval = 2, maxval = 100, group = g5m)
mtfM2 = input.int(5,  "HTF multiple 2 (× chart)", minval = 2, maxval = 200, group = g5m)
mtfM3 = input.int(15, "HTF multiple 3 (× chart)", minval = 2, maxval = 500, group = g5m)

// ═════════════════════════ 06 · STYLE ═══════════════════════════════════════
g5 = "06 · Style"
themeOpt = input.string("Auto (match chart)", "Theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g5)

// ───────────────────────── PALETTE / THEME (adaptive, institution) ──────────
var color COL_MID  = #f7c948
var color COL_INFO = #3d6cf0

f_lumaDark(color c) =>
    na(c) ? true : (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) < 140
bool isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lumaDark(chart.bg_color)
color tBord  = isDark ? color.new(#3a4250, 0)  : color.new(#c2c8d0, 0)
color tLbl   = isDark ? #9aa3b2 : #515a67
color tVal   = isDark ? #f2f4f8 : #10151d
color cBull  = isDark ? #2dd4bf : #0e9e76
color cWarn  = isDark ? #ffa94d : #b56a00
color cMute  = isDark ? #6b7480 : #98a0ab
color zebraA = isDark ? color.new(#141a26, 0) : color.new(#eef1f6, 0)
color zebraB = isDark ? color.new(#0e131d, 0) : color.new(#f8fafc, 0)
color frameCl = tBord

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

// EMA that seeds on the first valid input and holds through gaps. Runs every bar (no conditional
// ta.*), so it clears CW10004 and replicates the intended `na(x) ? na : ta.ema(x, len)` behaviour
// exactly — the average never sees the pre-warm-up na values.
f_emaSeed(float x, simple int len) =>
    var float e = na
    float a = 2.0 / (len + 1)
    e := na(x) ? e : na(e) ? x : e + a * (x - e)
    e

// ───────────────────────── MTF RAW SHIFT (higher timeframes) ────────────────
// Same sorted-sample Wasserstein-1 logic in a higher-timeframe context. Raw
// (no dwell). Returns -1 warming, 0 stable, 1 shift.
f_shiftStateMTF() =>
    float r_ = switch retMode
        "Percent"      => srcPrice != srcPrice[1] and srcPrice[1] != 0 ? (srcPrice - srcPrice[1]) / srcPrice[1] * 100.0 : 0.0
        "Price change" => srcPrice - nz(srcPrice[1], srcPrice)
        => srcPrice[1] > 0 and srcPrice > 0 ? math.log(srcPrice / srcPrice[1]) : 0.0
    float d0 = na
    if bar_index >= refLen + recentLen + 2
        float[] rec = array.new_float(0)
        float[] rf  = array.new_float(0)
        for i = 0 to recentLen - 1
            array.push(rec, nz(r_[i]))
        for j = 0 to refLen - 1
            array.push(rf, nz(r_[recentLen + j]))
        array.sort(rec, order.ascending)
        array.sort(rf,  order.ascending)
        float acc = 0.0
        for i = 0 to recentLen - 1
            float q = recentLen > 1 ? i / float(recentLen - 1) : 0.0
            int idx = int(math.round(q * (refLen - 1)))
            idx := math.max(0, math.min(refLen - 1, idx))
            acc += math.abs(array.get(rec, i) - array.get(rf, idx))
        d0 := acc / recentLen
    float dS = f_emaSeed(d0, smoothLen)
    float rSd = ta.stdev(r_, refLen)
    float dN = (not na(dS) and rSd > 0) ? dS / rSd : na
    float rk = ta.percentrank(nz(dN, 0.0), alarmLook)
    bool rdy = not na(dN) and bar_index >= refLen + recentLen + alarmLook / 2
    int st = not rdy ? -1 : rk >= alarmPct ? 1 : 0
    st

f_tfFromMult(int m) =>
    int secs = timeframe.in_seconds() * m
    secs % 604800 == 0 ? str.tostring(secs / 604800) + "W" : secs % 86400 == 0 ? str.tostring(secs / 86400) + "D" : secs % 60 == 0 ? str.tostring(secs / 60) : str.tostring(secs) + "S"
string htfTf1 = f_tfFromMult(mtfM1)
string htfTf2 = f_tfFromMult(mtfM2)
string htfTf3 = f_tfFromMult(mtfM3)
int htfSh1 = request.security(syminfo.tickerid, htfTf1, f_shiftStateMTF(), lookahead = barmerge.lookahead_off)
int htfSh2 = request.security(syminfo.tickerid, htfTf2, f_shiftStateMTF(), lookahead = barmerge.lookahead_off)
int htfSh3 = request.security(syminfo.tickerid, htfTf3, f_shiftStateMTF(), lookahead = barmerge.lookahead_off)
f_shShort(int r) =>
    r == 1 ? "SHIFT" : r == 0 ? "STAB" : "—"

// ───────────────────────── RETURNS ──────────────────────────────────────────
float ret = switch retMode
    "Percent"      => srcPrice != srcPrice[1] and srcPrice[1] != 0 ? (srcPrice - srcPrice[1]) / srcPrice[1] * 100.0 : 0.0
    "Price change" => srcPrice - nz(srcPrice[1], srcPrice)
    => srcPrice[1] > 0 and srcPrice > 0 ? math.log(srcPrice / srcPrice[1]) : 0.0

// ───────────────────────── WASSERSTEIN-1 (sorted-sample) ────────────────────
// Build the recent and reference windows, sort both, and average the absolute
// gap between matched order-statistics (equal-length resampling of the reference
// onto the recent window's rank positions). This is the 1-D earth-mover distance.
f_w1() =>
    float d = na
    if bar_index >= refLen + recentLen + 2
        float[] recent = array.new_float(0)
        float[] refer  = array.new_float(0)
        for i = 0 to recentLen - 1
            array.push(recent, nz(ret[i]))
        for j = 0 to refLen - 1
            array.push(refer, nz(ret[recentLen + j]))
        array.sort(recent, order.ascending)
        array.sort(refer,  order.ascending)
        // match the reference (length refLen) onto recent's ranks (length recentLen)
        float s = 0.0
        for i = 0 to recentLen - 1
            float q = recentLen > 1 ? i / float(recentLen - 1) : 0.0
            int idx = int(math.round(q * (refLen - 1)))
            idx := math.max(0, math.min(refLen - 1, idx))
            s += math.abs(array.get(recent, i) - array.get(refer, idx))
        d := s / recentLen
    d

var float w1raw = na
if barstate.isconfirmed
    w1raw := f_w1()
float w1 = f_emaSeed(w1raw, smoothLen)

// scale-normalize by the reference dispersion so the number is comparable across symbols
float refStd = ta.stdev(ret, refLen)
float w1n = (not na(w1) and refStd > 0) ? w1 / refStd : na

// ───────────────────────── SELF-CALIBRATED ALARM ────────────────────────────
float w1rankRaw = ta.percentrank(nz(w1n, 0.0), alarmLook)
float w1rank = not na(w1n) ? w1rankRaw : na
bool readyR = not na(w1rank) and bar_index >= refLen + recentLen + alarmLook / 2
int rawState = not readyR ? -1 : w1rank >= alarmPct ? 1 : 0
// minimum-dwell debounce: SHIFT/STABLE announced only after surviving
// minDwell confirmed bars (anti-chattering; lag = dwell bars, stated)
var int sstate = -1
var int scand  = -1
var int scAge  = 0
if barstate.isconfirmed
    if rawState == sstate
        scand := sstate
        scAge := 0
    else
        if rawState == scand
            scAge += 1
        else
            scand := rawState
            scAge := 1
        if scAge >= minDwell or sstate == -1
            sstate := rawState
            scand := rawState
            scAge := 0
bool ready = sstate != -1
bool shiftOn = sstate == 1
bool shiftNew = barstate.isconfirmed and shiftOn and nz(sstate[1], -2) != 1
bool shiftEnd = barstate.isconfirmed and ready and not shiftOn and nz(sstate[1], -2) == 1
int stabWin = 50
int stabSame = 0
for k = 0 to stabWin - 1
    if nz(sstate[k], -9) == sstate
        stabSame += 1
float stabPct = ready ? stabSame * 100.0 / stabWin : na

// ───────────────────────── DIAGNOSTIC DECOMPOSITION ─────────────────────────
// what moved: location (mean), scale (stdev), shape (skew), recent vs reference —
// all from cheap rolling moments (no extra sorting, to keep the script light).
float medRec = ta.sma(ret, recentLen)
float medRef = ta.sma(ret, refLen)
float sdRec  = ta.stdev(ret, recentLen)
float sdRef  = refStd
f_skew(float src, int len) =>
    float m = ta.sma(src, len)
    float sd = ta.stdev(src, len)
    float s3 = ta.sma(math.pow(src - m, 3), len)
    sd > 0 ? s3 / math.pow(sd, 3) : 0.0
float skRec = f_skew(ret, recentLen)
float skRef = f_skew(ret, refLen)

string drivers = ""
if ready
    bool locMove = not na(medRec) and not na(medRef) and sdRef > 0 and math.abs(medRec - medRef) > 0.5 * sdRef
    bool sclMove = sdRef > 0 and (sdRec / sdRef > 1.5 or sdRec / sdRef < 0.67)
    bool shpMove = math.abs(skRec - skRef) > 0.5
    drivers := (locMove ? "loc " : "") + (sclMove ? "scale " : "") + (shpMove ? "shape" : "")
    drivers := str.length(drivers) == 0 ? "mixed" : drivers

// ───────────────────────── PLOTS (price overlay) ────────────────────────────
// subtle tint: the lane and tags carry the state; tint is context only (90–95 band)
int tintTransp = ready and not na(w1rank) ? int(math.max(90.0, 97.0 - w1rank * 0.05)) : 100
bgcolor(showTint and shiftOn ? color.new(COL_MID, tintTransp) : na, title = "Distribution-shift tint")

// shift lane: thin colored strip at the pane bottom (alert glance-read)
color laneC = shiftOn ? color.new(COL_MID, 0) : color.new(cBull, 40)
plotshape(showLane and ready, "Shift lane", style = shape.square, location = location.bottom, color = laneC, size = size.tiny)

var label[] tags = array.new<label>()
if showTag and shiftNew
    lb = label.new(bar_index, high, "SHIFT", style = label.style_label_down, color = color.new(COL_MID, 10), textcolor = color.white, size = size.small, tooltip = "Return distribution unusually far from its reference. A change of regime shape — not a direction.")
    array.push(tags, lb)
    if array.size(tags) > 50
        label.delete(array.shift(tags))

plot(showDist and ready ? w1n : na, "Distance Status", color = color.new(COL_INFO, 0), display = display.status_line)
plot(showDist and ready ? w1rank : na, "Percentile Status", color = color.new(COL_MID, 0), display = display.status_line)

// ───────────────────────── DASHBOARD (institution, adaptive) ─────────────────
f_setRow(table t, int r, string lbl, string val, color vc, color lc, color bg) =>
    table.cell(t, 0, r, lbl, text_color = lc, text_size = size.tiny,  text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, val, text_color = vc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

string stateTxt = not ready ? "WARMING" : shiftOn ? "SHIFT" : "STABLE"

var table dash = na
if showDash and barstate.islast
    color stBg = not ready ? color.new(cMute, 0) : shiftOn ? color.new(cWarn, 0) : color.new(cBull, 0)
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, compactTbl ? 4 : 11, border_width = 1, frame_color = frameCl, frame_width = 1)
    table.set_frame_color(dash, frameCl)
    table.set_border_color(dash, frameCl)
    table.cell(dash, 0, 0, " SHIFT SENTINEL", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = stBg, tooltip = "Wasserstein-1 distance of recent returns from a reference window, ranked against its own history. Flags a change in distribution SHAPE. Descriptive of the past; not a direction.")
    table.cell(dash, 1, 0, stateTxt + " ", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = stBg)
    string rankTxt = not ready or na(w1rank) ? "warming" : "p" + str.tostring(math.round(w1rank))
    color  rankCol = not ready ? cMute : shiftOn ? cWarn : cBull
    f_setRow(dash, 1, "SHIFT RANK", rankTxt, rankCol, tLbl, zebraA)
    f_setRow(dash, 2, "DISTANCE (norm)", na(w1n) ? "-" : str.tostring(w1n, "0.000"), tVal, tLbl, zebraB)
    if compactTbl
        f_setRow(dash, 3, "DRIVER", ready and shiftOn ? drivers : "-", ready and shiftOn ? cWarn : cMute, tLbl, zebraA)
    else
        f_setRow(dash, 3, "DRIVER", ready ? (shiftOn ? drivers : "stable") : "-", ready and shiftOn ? cWarn : cMute, tLbl, zebraA)
        f_setRow(dash, 4, "STABILITY", na(stabPct) ? "-" : str.tostring(math.round(stabPct)) + "% of last " + str.tostring(stabWin), na(stabPct) ? cMute : stabPct >= 80 ? cBull : stabPct >= 50 ? tVal : cWarn, tLbl, zebraB)
        string pendTxt = ready and scand != sstate and scAge > 0 ? f_shShort(scand) + " in " + str.tostring(minDwell - scAge) + " bars" : "none"
        f_setRow(dash, 5, "PENDING", pendTxt, pendTxt == "none" ? cMute : cWarn, tLbl, zebraA)
        f_setRow(dash, 6, "SCALE recent/ref", (not na(sdRec) and sdRef > 0) ? "× " + str.tostring(sdRec / sdRef, "0.00") : "-", tVal, tLbl, zebraB)
        f_setRow(dash, 7, "SKEW rec / ref", str.tostring(skRec, "0.0") + " / " + str.tostring(skRef, "0.0"), tVal, tLbl, zebraA)
        if mtfOn
            bool mtfAgree = ready and htfSh1 == sstate and htfSh2 == sstate and htfSh3 == sstate
            bool mtfWarnHi = ready and sstate == 0 and (htfSh1 == 1 or htfSh2 == 1 or htfSh3 == 1)
            string mtfTxt = str.tostring(mtfM1) + "× " + f_shShort(htfSh1) + " · " + str.tostring(mtfM2) + "× " + f_shShort(htfSh2) + " · " + str.tostring(mtfM3) + "× " + f_shShort(htfSh3) + (mtfAgree ? "  ✓" : mtfWarnHi ? "  ⚠" : "")
            f_setRow(dash, 8, "HTF STACK", mtfTxt, mtfAgree ? cBull : mtfWarnHi ? cWarn : tVal, tLbl, zebraB)
        else
            f_setRow(dash, 8, "HTF STACK", "off", cMute, tLbl, zebraB)
        f_setRow(dash, 9, "WINDOWS", str.tostring(recentLen) + " vs " + str.tostring(refLen) + " · dwell " + str.tostring(minDwell), tVal, tLbl, zebraA)
        f_setRow(dash, 10, "ALARM", "p" + str.tostring(math.round(alarmPct)), tVal, tLbl, zebraB)

// identity label (separate toggle)
var table idTbl = na
if showId and barstate.islast
    if na(idTbl)
        idTbl := table.new(position.bottom_center, 1, 1)
    table.cell(idTbl, 0, 0, "Shift Sentinel  ·  " + syminfo.ticker + "  " + timeframe.period, text_color = color.new(tLbl, 15), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────── EXPORTS (Data Window · generic names) ────────────
plot(w1n,    "EXP_ShiftDistance",   display = display.data_window)
plot(w1rank, "EXP_ShiftPercentile", display = display.data_window)
plot(ready ? sstate : na, "EXP_ShiftFlag", display = display.data_window)
plot(stabPct, "EXP_ShiftStability", display = display.data_window)
plot(mtfOn ? htfSh1 : na, "EXP_ShiftHTF1", display = display.data_window)
plot(mtfOn ? htfSh2 : na, "EXP_ShiftHTF2", display = display.data_window)
plot(mtfOn ? htfSh3 : na, "EXP_ShiftHTF3", display = display.data_window)
plot(not na(sdRec) and sdRef > 0 ? sdRec / sdRef : na, "EXP_ScaleRatio", display = display.data_window)
plot(skRec,  "EXP_SkewRecent",      display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(shiftNew, "Distribution shift", "Distributional-Shift Sentinel: return-shape regime change detected")
alertcondition(shiftEnd, "Shift ended", "Distributional-Shift Sentinel: return shape back in line with reference")
````
