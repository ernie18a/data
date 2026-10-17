# Auction Regime Router  Entropy Gate & Hurst Memory

- url: https://www.tradingview.com/script/5IkVGM0Q-Auction-Regime-Router-Entropy-Gate-Hurst-Memory/
- type: indicator
- pine_id: PUB;03a1d7d5096f424db63f1f6ddfe3ff26
- version: 3.0

## Description

Auction Regime Router — Entropy Gate & Hurst Memory

What it is

Every structure playbook fails in the wrong regime. Fading the value-area edge works when price is anti-persistent (stretches snap back); riding a breakout works when price is persistent (moves feed on themselves); and nothing structural works when the tape is noise. This tool measures two things — how much structure exists, and what kind it is — and routes to a plain-language answer: FADES VIABLE / BREAKOUTS VIABLE / STAND ASIDE. It decides which of your tools to trust, never buy or sell.

The two measurements (and how they work together)

Permutation entropy (Bandt–Pompe 2002) — the gate. It measures how disordered the recent price sequence is from the frequencies of ordinal patterns (which of the 6 orderings each price triplet takes). High entropy = all patterns equally likely = noise = no structural edge. The gate is self-calibrated: entropy is ranked against its own recent history, so "noisy" means noisy for this symbol and timeframe.

Hurst exponent (Hurst 1951; Mandelbrot) — the router. Memory via diffusion scaling: how the dispersion of K-bar returns grows with K. H > 0.5 = persistent → continuation regime; H < 0.5 = anti-persistent → reversion regime. Research supports the routing: mean reversion is empirically more probable and faster during anti-persistent periods.

The mashup logic is a hierarchy, not a mixture: the entropy gate overrides the Hurst read. If the tape is noise, the router says STAND ASIDE regardless of what H says — because a memory estimate on noise is meaningless.

The honesty steps

A dead zone around H = 0.5 (default 0.45–0.55): near a random walk the memory read is unreliable, so the router says MIXED rather than pretending. Practitioners commonly require a margin before activating a playbook; both thresholds are inputs.
A minimum-dwell filter (the standard anti-chattering design from switched-systems control): a new regime is announced only after it survives a set number of confirmed bars, so the read doesn't flip-flop bar to bar. The cost is that many bars of lag — stated, and adjustable.
Estimates are proxies from bar data with overlapping windows — descriptive of the recent past, not a prediction. The dashboard shows the state, how long it has persisted (regime age), how dominant it has been recently (stability %), and any pending regime with a countdown — nothing more.

How to use it

Add to any liquid symbol/timeframe; defaults suit intraday index futures. The script requests no external data of any kind, so it runs on every plan and every symbol.
Glance at the regime lane — the thin colored strip at the bottom of the pane: blue = continuation, violet = reversion, amber = noise, gray = mixed. The palette is deliberately direction-neutral — no green or red anywhere in regime coding, so nothing can be misread as a buy or sell.

The HTF STACK row shows the raw regime on three higher timeframes derived as multiples of the chart (defaults 3×, 5×, 15× — so a 5m chart reads 15m/25m/75m automatically, adapting to any chart). A ✓ in green = every timeframe agrees on the same actionable regime (strongest context). A ⚠ in amber = a higher timeframe reads NOISE or the opposite regime while the chart claims a playbook (weakest — reduce or wait).

Read the dashboard for detail: REVERSION → your value-area fade / band-reversion tools are in their element; CONTINUATION → your breakout / drive tools are; NOISE → the gate is closed, stand aside; MIXED → no clear routing, reduce. STABILITY shows how settled the read is; PENDING shows a forming regime with a countdown.

Regime-change tags print only on announced (dwell-confirmed) changes; alerts fire on entering each state.
Best used as the selector above your structure toolkit rather than as a standalone display.

What makes it original

Hurst and entropy oscillators exist. What this adds: (1) the hierarchy — a self-calibrated entropy gate that can veto the memory read, instead of two numbers side by side; (2) routing to auction playbooks in plain language (fade vs breakout viability), not a raw statistic; (3) honest dead zones, a minimum-dwell announcement filter, and stability/pending context instead of a binary flip at H = 0.500. It is a decision-hygiene tool for structure traders.

Concept credits

Ordinal-pattern (permutation) entropy — C. Bandt & B. Pompe (2002). Long-memory / rescaled-range analysis — H. E. Hurst (1951); fractal market framing — B. Mandelbrot. Regime-gated strategy selection — standard quantitative practice. Implementation and charting design are the author's own.

Important disclaimer

Research and education only. Not financial advice, not a signal service, not a guarantee of future results. Regime labels are descriptive statistics of recent bars; regimes change without warning and estimates are proxies. Validate independently and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  AUCTION REGIME ROUTER                                                    v1.1
//  v1.1 — House-standard pass (no engine change): a seed-on-first-valid EMA replaces two conditional
//         ta.ema calls (clears CW10004; output unchanged after warm-up); added the MPL-2.0 header and
//         an EXP_ export bus. No cost model — this is a regime gate, not a directional signal tool.
//  Answers one question: WHICH kind of structure play is viable right now —
//  value-area fades, breakout continuation, or neither. A gate, not a signal.
// -----------------------------------------------------------------------------
//  THE IDEA
//    Every structure playbook fails in the wrong regime. Fading the value-area
//    edge works when price is anti-persistent (stretches snap back); riding a
//    breakout works when price is persistent (moves feed on themselves); and
//    NOTHING structural works when the tape is pure noise. This tool measures
//    two things — how much structure exists (entropy) and what kind it is
//    (memory) — and routes to a plain-language answer: FADES VIABLE /
//    BREAKOUTS VIABLE / STAND ASIDE. It never says buy or sell.
//
//  THE TWO MEASUREMENTS
//    • PERMUTATION ENTROPY (Bandt–Pompe 2002) — how disordered the recent
//      sequence of prices is, measured from the frequencies of ordinal patterns
//      (which of the 6 possible orderings each triplet of prices takes). High
//      entropy = patterns equally likely = noise = no structural edge. The gate
//      is SELF-CALIBRATED: entropy is ranked against its own recent history, so
//      "noisy" means noisy for THIS symbol and timeframe.
//    • HURST EXPONENT (Hurst 1951; Mandelbrot) — the memory of returns via
//      diffusion scaling: how the dispersion of K-bar returns grows with K.
//      H > 0.5 = persistent (moves continue: continuation regime);
//      H < 0.5 = anti-persistent (moves revert: reversion regime).
//      Research note: reversion is empirically more probable and faster in
//      anti-persistent periods — which is exactly what this router exploits.
//
//  THE HONESTY STEPS
//    • A DEAD ZONE around H = 0.5 (default 0.45–0.55): near a random walk the
//      memory read is not reliable, so the router says MIXED rather than
//      pretending. Practitioners commonly require a margin (e.g. >0.55) before
//      activating a playbook; the thresholds are inputs.
//    • The entropy gate OVERRIDES the Hurst read: if the tape is noise, the
//      router says STAND ASIDE no matter what H says.
//    • Estimates are proxies from bar data with overlapping windows; they are
//      descriptive of the recent past, not a prediction.
//
//  HOW TO READ IT (price overlay)
//    The dashboard states the regime and the viable play in plain language; a
//    subtle background tint marks regime (cool = reversion, blue = continuation,
//    none = noise/mixed); a small tag prints when the regime CHANGES. Use it to
//    choose WHICH of your structure tools to trust — value-area fades and
//    band-reversion tools in REVERSION, breakout / POC-drive tools in
//    CONTINUATION, and reduced activity in NOISE.
//
//  NON-REPAINT
//    Entropy and Hurst are computed on CONFIRMED bars; the live bar is
//    provisional. No lookahead anywhere.
//
//  USE ON ANY MARKET
//    Price source and every window/threshold are inputs; both measures are
//    scale-free. Defaults suit liquid intraday index futures.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Ordinal-pattern (permutation) entropy — C. Bandt & B. Pompe (2002).
//    • Long-memory / rescaled-range analysis — H. E. Hurst (1951); fractal
//     market framing — B. Mandelbrot. Regime-gated strategy selection —
//     standard quantitative-finance practice.
//    Implementation and charting design are the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. Regime labels are descriptive
//    statistics of recent bars; regimes change without warning. Validate
//    independently and manage your own risk.
// =============================================================================
indicator("Auction Regime Router — Entropy Gate & Hurst Memory", "Regime Router",
     overlay = true, max_labels_count = 200, max_bars_back = 5000)

// ═════════════════════════ 00 · DATA SOURCE ═════════════════════════════════
g0 = "00 · Data source"
srcPrice = input.source(close, "Price source", group = g0,
     tooltip = "Series the regime is measured on. Default close.")

// ═════════════════════════ 01 · ENTROPY GATE ════════════════════════════════
g1 = "01 · Entropy gate (structure vs noise)"
peWin  = input.int(100, "Pattern window (bars)", minval = 30, maxval = 400, group = g1,
     tooltip = "How many recent bars the ordinal-pattern frequencies are measured over.")
peTau  = input.int(2, "Pattern spacing (bars)", minval = 1, maxval = 10, group = g1,
     tooltip = "Spacing between the three points of each ordinal pattern. Larger = coarser structure.")
noiseLevel = input.float(70.0, "Noise above (entropy percentile)", minval = 50.0, maxval = 95.0, step = 5.0, group = g1,
     tooltip = "When entropy ranks above this percentile of its own history, the tape is flagged NOISE and the router says stand aside.")
peLook = input.int(300, "Entropy self-calibration lookback", minval = 50, maxval = 2000, group = g1)

// ═════════════════════════ 02 · MEMORY ROUTER (Hurst) ═══════════════════════
g2 = "02 · Memory router (Hurst)"
hurstWin = input.int(150, "Hurst window (bars)", minval = 50, maxval = 1000, group = g2,
     tooltip = "Window for the diffusion-scaling estimate of the Hurst exponent.")
hUp   = input.float(0.55, "Continuation above (H)", minval = 0.50, maxval = 0.80, step = 0.01, group = g2,
     tooltip = "Hurst above this = persistent tape → breakout / continuation playbook viable. The gap between the two thresholds is the honest dead zone.")
hDown = input.float(0.45, "Reversion below (H)", minval = 0.20, maxval = 0.50, step = 0.01, group = g2,
     tooltip = "Hurst below this = anti-persistent tape → value-area fade / reversion playbook viable.")
hSmooth = input.int(5, "Hurst smoothing", minval = 1, maxval = 30, group = g2)

// ═════════════════════════ 03 · STABILITY & OUTPUT ══════════════════════════
g3 = "03 · Stability & output"
minDwell = input.int(5, "Confirm regime after (bars)", minval = 1, maxval = 50, group = g3,
     tooltip = "Minimum-dwell debounce (standard anti-chattering design from switched-systems control): a new regime is ANNOUNCED only after it survives this many confirmed bars. Removes label spam and flip-flop at the cost of this many bars of lag — both stated. Raise on fast charts.")
showLane = input.bool(true, "Regime lane (strip at pane bottom)", group = g3,
     tooltip = "A thin colored strip along the bottom: blue = continuation, green = reversion, amber = noise, gray = mixed. The cleanest at-a-glance regime read.")
showTint = input.bool(true, "Background regime tint", group = g3)
showTag  = input.bool(true, "Tag on regime change", group = g3)

// ═════════════════════════ 04 · DASHBOARD ═══════════════════════════════════
g4 = "04 · Dashboard"
showDash  = input.bool(true, "Show main dashboard", group = g4)
compactTbl= input.bool(false, "Compact dashboard", group = g4)
dashPos   = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g4)
showId    = input.bool(false, "Show name / symbol / timeframe label (separate table)", group = g4)

// ═════════════════════════ 05 · MULTI-TIMEFRAME ═════════════════════════════
g5m = "05 · Multi-timeframe stack"
mtfOn = input.bool(true, "Show higher-timeframe regimes", group = g5m,
     tooltip = "Computes the RAW regime (no dwell filter — higher timeframes are inherently slower) on three higher timeframes derived as MULTIPLES of the chart timeframe, so the stack adapts to any chart (1m → 3/5/15m; 5m → 15/25/75m). Standard higher-timeframe requests — available on every plan and symbol.")
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
var color COL_REV  = #a06cf0

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

// ───────────────────────── PERMUTATION ENTROPY (ordinal patterns) ───────────
// Frequencies of the 6 orderings of (oldest, middle, newest) price triplets over
// the window, normalized Shannon entropy in [0,1]. Heavy loop gated to confirmed
// bars for chart-load safety.
f_permEntropy(int win, int tau) =>
    float pe = na
    if bar_index >= win + 2 * tau + 2
        int[] cnt = array.new_int(6, 0)
        for i = 0 to win - 1
            float a = srcPrice[i + 2 * tau]   // oldest
            float b = srcPrice[i + tau]       // middle
            float c = srcPrice[i]             // newest
            int p = a <= b ? (b <= c ? 0 : a <= c ? 1 : 2) : (b > c ? 5 : a > c ? 4 : 3)
            array.set(cnt, p, array.get(cnt, p) + 1)
        float h = 0.0
        for k = 0 to 5
            int ck = array.get(cnt, k)
            if ck > 0
                float pk = ck / float(win)
                h -= pk * math.log(pk)
        pe := h / math.log(6.0)
    pe

var float peRaw = na
if barstate.isconfirmed
    peRaw := f_permEntropy(peWin, peTau)
float peRankRaw = ta.percentrank(nz(peRaw, 0.0), peLook)
float peRank = not na(peRaw) ? peRankRaw : na
bool noisy = not na(peRank) and peRank >= noiseLevel

// ───────────────────────── HURST (diffusion scaling) ────────────────────────
// H from how the dispersion of K-bar returns grows with K: for a random walk
// sd(K) = sd(1)·K^0.5; persistent tapes scale faster, anti-persistent slower.
// Two scales averaged; overlapping windows make this a proxy, stated as such.
float ret1  = srcPrice > 0 and srcPrice[1] > 0 ? math.log(srcPrice / srcPrice[1]) : 0.0
float ret4  = srcPrice > 0 and srcPrice[4] > 0 ? math.log(srcPrice / srcPrice[4]) : 0.0
float ret16 = srcPrice > 0 and srcPrice[16] > 0 ? math.log(srcPrice / srcPrice[16]) : 0.0
float sd1  = ta.stdev(ret1,  hurstWin)
float sd4  = ta.stdev(ret4,  hurstWin)
float sd16 = ta.stdev(ret16, hurstWin)
float h4  = (sd1 > 0 and sd4  > 0) ? math.log(sd4  / sd1) / math.log(4.0)  : na
float h16 = (sd1 > 0 and sd16 > 0) ? math.log(sd16 / sd1) / math.log(16.0) : na
float hurstRaw = na(h4) or na(h16) ? na : math.max(0.0, math.min(1.0, (h4 + h16) / 2.0))
float hurst = f_emaSeed(hurstRaw, hSmooth)

// ───────────────────────── MTF RAW REGIME (higher timeframes) ───────────────
// Same entropy-gate + Hurst logic evaluated in a higher-timeframe context.
// Raw (no dwell): HTF bars are already slow. Called unconditionally at top
// level via request.security (lookahead off) — works on every plan/symbol.
f_rawRegimeMTF() =>
    float pe = na
    if bar_index >= peWin + 2 * peTau + 2
        int[] cnt = array.new_int(6, 0)
        for i = 0 to peWin - 1
            float a = srcPrice[i + 2 * peTau]
            float b = srcPrice[i + peTau]
            float c = srcPrice[i]
            int p = a <= b ? (b <= c ? 0 : a <= c ? 1 : 2) : (b > c ? 5 : a > c ? 4 : 3)
            array.set(cnt, p, array.get(cnt, p) + 1)
        float h = 0.0
        for k = 0 to 5
            int ck = array.get(cnt, k)
            if ck > 0
                float pk = ck / float(peWin)
                h -= pk * math.log(pk)
        pe := h / math.log(6.0)
    float peRk = ta.percentrank(nz(pe, 0.0), peLook)
    bool nz2 = not na(pe) and peRk >= noiseLevel
    float r1 = srcPrice > 0 and srcPrice[1] > 0 ? math.log(srcPrice / srcPrice[1]) : 0.0
    float r4 = srcPrice > 0 and srcPrice[4] > 0 ? math.log(srcPrice / srcPrice[4]) : 0.0
    float r16 = srcPrice > 0 and srcPrice[16] > 0 ? math.log(srcPrice / srcPrice[16]) : 0.0
    float s1 = ta.stdev(r1, hurstWin)
    float s4 = ta.stdev(r4, hurstWin)
    float s16 = ta.stdev(r16, hurstWin)
    float hh4 = (s1 > 0 and s4 > 0) ? math.log(s4 / s1) / math.log(4.0) : na
    float hh16 = (s1 > 0 and s16 > 0) ? math.log(s16 / s1) / math.log(16.0) : na
    float hR = na(hh4) or na(hh16) ? na : math.max(0.0, math.min(1.0, (hh4 + hh16) / 2.0))
    float hS = f_emaSeed(hR, hSmooth)
    bool rdy = not na(pe) and not na(hS) and bar_index > math.max(peLook / 2, hurstWin)
    int rr = not rdy ? -1 : nz2 ? 0 : hS >= hUp ? 3 : hS <= hDown ? 2 : 1
    rr

// build a valid timeframe string from chart-seconds × multiplier (handles
// seconds, minutes, daily and weekly bases correctly)
f_tfFromMult(int m) =>
    int secs = timeframe.in_seconds() * m
    secs % 604800 == 0 ? str.tostring(secs / 604800) + "W" : secs % 86400 == 0 ? str.tostring(secs / 86400) + "D" : secs % 60 == 0 ? str.tostring(secs / 60) : str.tostring(secs) + "S"
string htfTf1 = f_tfFromMult(mtfM1)
string htfTf2 = f_tfFromMult(mtfM2)
string htfTf3 = f_tfFromMult(mtfM3)
int htfReg1 = request.security(syminfo.tickerid, htfTf1, f_rawRegimeMTF(), lookahead = barmerge.lookahead_off)
int htfReg2 = request.security(syminfo.tickerid, htfTf2, f_rawRegimeMTF(), lookahead = barmerge.lookahead_off)
int htfReg3 = request.security(syminfo.tickerid, htfTf3, f_rawRegimeMTF(), lookahead = barmerge.lookahead_off)

// ───────────────────────── ROUTING (dwell-debounced) ────────────────────────
bool ready = not na(peRank) and not na(hurst) and bar_index > math.max(peLook / 2, hurstWin)
// raw regime each bar: entropy gate overrides memory (noise → aside regardless of H)
int rawRegime = not ready ? -1 : noisy ? 0 : hurst >= hUp ? 3 : hurst <= hDown ? 2 : 1
// minimum-dwell debounce: a NEW regime is announced only after it survives
// minDwell confirmed bars (standard anti-chattering: the rule to switch is
// stricter than the rule to hold). Cost = minDwell bars of lag, stated.
var int regime  = -1
var int cand    = -1
var int candAge = 0
if barstate.isconfirmed
    if rawRegime == regime
        cand := regime
        candAge := 0
    else
        if rawRegime == cand
            candAge += 1
        else
            cand := rawRegime
            candAge := 1
        if candAge >= minDwell or regime == -1
            regime := rawRegime
            cand := rawRegime
            candAge := 0

f_regName(int r) =>
    r == 0 ? "NOISE" : r == 2 ? "REVERSION" : r == 3 ? "CONTINUATION" : r == 1 ? "MIXED" : "—"
f_regShort(int r) =>
    r == 0 ? "NOISE" : r == 2 ? "REV" : r == 3 ? "CONT" : r == 1 ? "MIX" : "—"
string regimeTxt = regime == -1 ? "WARMING" : f_regName(regime)
string playTxt = regime == -1 ? "-" :
     regime == 0 ? "stand aside · no structural edge" :
     regime == 3 ? "breakout / drive plays viable" :
     regime == 2 ? "value-area fades viable" : "no clear routing · reduce"

var int regimeAge = 0
if barstate.isconfirmed
    regimeAge := regime == nz(regime[1], -2) ? regimeAge + 1 : 0
bool regimeChange = ready and regime != regime[1] and barstate.isconfirmed

// ───────────────────────── PLOTS (price overlay) ────────────────────────────
color tintC = not ready ? na : regime == 3 ? color.new(COL_INFO, 92) : regime == 2 ? color.new(COL_REV, 92) : na
bgcolor(showTint ? tintC : na, title = "Regime tint")

// regime lane: thin colored strip at the pane bottom (the primary glance-read)
color laneC = regime == 3 ? color.new(COL_INFO, 0) : regime == 2 ? color.new(COL_REV, 0) : regime == 0 ? color.new(COL_MID, 0) : color.new(cMute, 30)
plotshape(showLane and ready, "Regime lane", style = shape.square, location = location.bottom, color = laneC, size = size.tiny)

// stability: share of the recent window spent in the current announced regime
int stabWin = 50
int stabSame = 0
for k = 0 to stabWin - 1
    if nz(regime[k], -9) == regime
        stabSame += 1
float stabPct = ready ? stabSame * 100.0 / stabWin : na

var label[] tags = array.new<label>()
if showTag and regimeChange and regime != 1
    string tagTxt = regime == 0 ? "NOISE" : regime == 3 ? "CONTINUATION" : "REVERSION"
    color tagCl = regime == 0 ? color.new(COL_MID, 10) : regime == 3 ? color.new(COL_INFO, 10) : color.new(COL_REV, 10)
    lb = label.new(bar_index, high, tagTxt, style = label.style_label_down, color = tagCl, textcolor = color.white, size = size.small, tooltip = "Regime changed. This routes WHICH playbook is viable — it is not a buy/sell signal.")
    array.push(tags, lb)
    if array.size(tags) > 50
        label.delete(array.shift(tags))

// ───────────────────────── DASHBOARD (institution, adaptive) ─────────────────
f_setRow(table t, int r, string lbl, string val, color vc, color lc, color bg) =>
    table.cell(t, 0, r, lbl, text_color = lc, text_size = size.tiny,  text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, val, text_color = vc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

var table dash = na
if showDash and barstate.islast
    color stBg = not ready ? color.new(cMute, 0) : regime == 0 ? color.new(cWarn, 0) : regime == 3 ? color.new(COL_INFO, 0) : regime == 2 ? color.new(COL_REV, 0) : color.new(cMute, 0)
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, compactTbl ? 4 : 10, border_width = 1, frame_color = frameCl, frame_width = 1)
    table.set_frame_color(dash, frameCl)
    table.set_border_color(dash, frameCl)
    table.cell(dash, 0, 0, " REGIME ROUTER", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = stBg, tooltip = "Entropy gate (structure vs noise) + Hurst memory (continuation vs reversion), announced only after surviving the dwell filter. Routes WHICH structure playbook is viable. Descriptive gate — never a direction.")
    table.cell(dash, 1, 0, regimeTxt + " ", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = stBg)
    f_setRow(dash, 1, "PLAY", playTxt, ready ? tVal : cMute, tLbl, zebraA)
    f_setRow(dash, 2, "REGIME AGE", ready ? str.tostring(regimeAge) + " bars" : "-", tVal, tLbl, zebraB)
    if not compactTbl
        f_setRow(dash, 3, "STABILITY", na(stabPct) ? "-" : str.tostring(math.round(stabPct)) + "% of last " + str.tostring(stabWin), na(stabPct) ? cMute : stabPct >= 80 ? cBull : stabPct >= 50 ? tVal : cWarn, tLbl, zebraA)
        string pendTxt = ready and cand != regime and candAge > 0 ? f_regName(cand) + " in " + str.tostring(minDwell - candAge) + " bars" : "none"
        f_setRow(dash, 4, "PENDING", pendTxt, pendTxt == "none" ? cMute : cWarn, tLbl, zebraB)
        f_setRow(dash, 5, "ENTROPY (rank)", na(peRank) ? "-" : "p" + str.tostring(math.round(peRank)) + (noisy ? " · noisy" : " · structured"), noisy ? cWarn : cBull, tLbl, zebraA)
        f_setRow(dash, 6, "HURST H", na(hurst) ? "-" : str.tostring(hurst, "0.00") + (hurst >= hUp ? " · persistent" : hurst <= hDown ? " · anti-persistent" : " · dead zone"), na(hurst) ? cMute : hurst >= hUp ? COL_INFO : hurst <= hDown ? COL_REV : cMute, tLbl, zebraB)
        f_setRow(dash, 7, "GATE", noisy ? "entropy overrides → aside" : "structure present", noisy ? cWarn : tVal, tLbl, zebraA)
        f_setRow(dash, 8, "WINDOWS", str.tostring(peWin) + " / " + str.tostring(hurstWin) + " · dwell " + str.tostring(minDwell), tVal, tLbl, zebraB)
        if mtfOn
            bool actionable = regime == 2 or regime == 3
            bool mtfAgree = actionable and htfReg1 == regime and htfReg2 == regime and htfReg3 == regime
            bool htfNoiseCaut = actionable and (htfReg1 == 0 or htfReg2 == 0 or htfReg3 == 0)
            bool htfOppose = actionable and (((htfReg1 == 2 or htfReg1 == 3) and htfReg1 != regime) or ((htfReg2 == 2 or htfReg2 == 3) and htfReg2 != regime) or ((htfReg3 == 2 or htfReg3 == 3) and htfReg3 != regime))
            bool mtfCaution = htfNoiseCaut or htfOppose
            string mtfTxt = str.tostring(mtfM1) + "× " + f_regShort(htfReg1) + " · " + str.tostring(mtfM2) + "× " + f_regShort(htfReg2) + " · " + str.tostring(mtfM3) + "× " + f_regShort(htfReg3) + (mtfAgree ? "  ✓" : mtfCaution ? "  ⚠" : "")
            f_setRow(dash, 9, "HTF STACK", mtfTxt, mtfAgree ? cBull : mtfCaution ? cWarn : tVal, tLbl, zebraA)
        else
            f_setRow(dash, 9, "HTF STACK", "off", cMute, tLbl, zebraA)

// identity label (separate toggle)
var table idTbl = na
if showId and barstate.islast
    if na(idTbl)
        idTbl := table.new(position.bottom_center, 1, 1)
    table.cell(idTbl, 0, 0, "Regime Router  ·  " + syminfo.ticker + "  " + timeframe.period, text_color = color.new(tLbl, 15), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────── EXPORTS (Data Window · generic names) ────────────
plot(peRank, "EXP_EntropyRank",    display = display.data_window)
plot(hurst,  "EXP_HurstExponent",  display = display.data_window)
plot(ready ? regime : na, "EXP_RegimeState", display = display.data_window)
plot(ready ? regimeAge : na, "EXP_RegimeAge", display = display.data_window)
plot(stabPct, "EXP_RegimeStability", display = display.data_window)
plot(mtfOn ? htfReg1 : na, "EXP_RegimeHTF1", display = display.data_window)
plot(mtfOn ? htfReg2 : na, "EXP_RegimeHTF2", display = display.data_window)
plot(mtfOn ? htfReg3 : na, "EXP_RegimeHTF3", display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(ready and regime == 2 and regime[1] != 2, "Reversion regime", "Regime Router: anti-persistent tape — value-area fade playbook viable")
alertcondition(ready and regime == 3 and regime[1] != 3, "Continuation regime", "Regime Router: persistent tape — breakout / drive playbook viable")
alertcondition(ready and regime == 0 and regime[1] != 0, "Noise regime", "Regime Router: entropy gate closed — stand aside")
````
