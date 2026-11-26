# Levy Area Flow Sequencer  Flow Price Lead Lag

- url: https://www.tradingview.com/script/xdbT7OAw-Levy-Area-Flow-Sequencer-Flow-Price-Lead-Lag/
- type: indicator
- pine_id: PUB;376d5e25094146118ce23817dd189e32
- version: 2.0

## Description

Lévy-Area Flow Sequencer — Flow/Price Lead-Lag

What it is

Correlation says flow and price move together; it cannot say which moves first. But the sequencing is the interesting part: when aggressive flow precedes price, moves are being built by participation before they print; when price precedes flow, price is running ahead and flow is chasing — squeeze / stop-run character. Traced together, the two series form a path in the plane, and the signed (Lévy) area that path encloses measures its rotation — a scale-free, lag-free read of lead–lag, including non-linear lead–lag that fixed-lag cross-correlation misses. This is the most experimental tool of this suite, and it is framed that way.

The mathematics (signature lead–lag metric)

The metric is the antisymmetric part of the second-level path signature of the pair (flow, price): the window sum of (X·dy − Y·dx), with both increment series normalized to unit scale so the area is dimensionless. Per the literature's interpretation, the metric is positive and grows when moves in the first series are followed by same-direction moves in the second. The first series here is cumulative order-flow delta (from lower-timeframe signed volume, with bar-shape fallback) and the second is price, so AREA > 0 → FLOW LEADS and AREA < 0 → PRICE LEADS.

The honesty steps


Significance gate — a raw signed area is noisy, so the reading is ranked against its own recent history, and a lead is declared only when rotation is unusually strong for this symbol/timeframe. Otherwise the state is BALANCED: no claim.
Sequencing ≠ causation — the literature is explicit that a signed area alone cannot establish causal direction. This tool reports a temporal-ordering tendency of past bars; treat it as tape character.
Known limitation, stated — persistent inverse co-movement between flow and price can contaminate the sign. On liquid futures they co-move and the read behaves; on instruments where they reliably anti-correlate, don't trust it.


The stability & multi-timeframe layer


States are dwell-filtered (standard anti-chattering): FLOW LEADS / PRICE LEADS / BALANCED is announced only after surviving a set number of confirmed bars, so the read doesn't flip-flop. STABILITY shows how settled it is; PENDING shows a forming state with a countdown. Cost: a few bars of lag — stated and adjustable.
The lead lane — a thin strip at the pane bottom — gives the glance-read: green = flow leads (moves better backed), amber = price leads (flow chasing, be sceptical), gray = balanced. Trust/caution colors, never direction.
The HTF STACK row shows the raw lead state on three higher timeframes derived as multiples of the chart (defaults 3×, 5×, 15×). Honesty note: lower-timeframe data cannot be requested inside a higher-timeframe request, so the HTF slots use the bar-shape delta proxy — a stated approximation. ✓ = all timeframes agree on the same significant lead; ⚠ = a higher timeframe shows the opposite lead.


How to use it


Add to a liquid intraday chart. Read the dashboard: FLOW LEADS → breakouts/drives carry more weight (participation came first); PRICE LEADS → be sceptical of extensions (flow is chasing); BALANCED → the tool makes no claim.
Tags print when the lead flips while significant; alerts fire on flips.
Use it as context alongside order-flow and structure tools — never as a standalone signal.


What makes it original

Path-signature methods are frontier quantitative machinery (rough-path theory) that has reached systematic trading but, to the author's knowledge, not chart platforms. Applying the signature lead-lag metric to the flow-vs-price pair — the pair an order-flow trader actually cares about — with an honest significance gate and stated limitations, is the contribution.

Concept credits

Signed area of stochastic paths — P. Lévy. Rough-path / signature theory — T. Lyons; Levin, Lyons & Ni (2016). Signature lead-lag metric and interpretation — I. Chevyrev & A. Kormilitzin (2016). Market applications — Bennett, Cucuringu & Reinert (2022); Cartea, Cucuringu & Jin (2023). Implementation and charting design are the author's own.

Important disclaimer

Research and education only. Not financial advice, not a signal service, not a guarantee of future results. The area measures a sequencing tendency in past data; it is not causal proof and not a prediction. Validate independently and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  LÉVY-AREA FLOW SEQUENCER                                                 v1.1
//  v1.1 — House-standard pass (no engine change): a seed-on-first-valid EMA replaces two conditional
//         ta.ema calls (clears CW10004; output unchanged after warm-up); added the MPL-2.0 header and
//         an EXP_ export bus. No cost model — this is a descriptive lead-lag read, not a signal tool.
//  Who moves first — flow or price? A rotational (path-signature) read of the
//  sequencing between order flow and price. The most experimental tool of this
//  suite, and framed that way.
// -----------------------------------------------------------------------------
//  THE IDEA
//    Correlation says flow and price move together; it cannot say WHICH MOVES
//    FIRST. But that sequencing is the interesting part: when aggressive flow
//    precedes price, moves are being built by participation before they print;
//    when price precedes flow, price is running ahead and flow is chasing —
//    squeeze / stop-run character. The two series traced together form a path
//    in the plane, and the SIGNED (LÉVY) AREA that path encloses measures its
//    rotation — a scale-free, lag-free way to read lead–lag, including
//    non-linear lead–lag that cross-correlation at fixed lags misses.
//
//  THE MATHEMATICS (signature lead–lag metric)
//    The metric is the antisymmetric part of the second-level path signature of
//    the pair (flow, price):  A = Σ over the window of (X·dy − Y·dx), with both
//    increment series normalized to unit scale so the area is dimensionless.
//    Interpretation from the literature: the metric is positive and grows when
//    moves in the FIRST series are followed by same-direction moves in the
//    second. Here the first series is cumulative order-flow delta and the
//    second is price, so:
//        AREA > 0  →  FLOW LEADS (participation precedes price)
//        AREA < 0  →  PRICE LEADS (price precedes participation)
//
//  THE HONESTY STEPS (this tool earns trust by admitting limits)
//    • SIGNIFICANCE GATE — a raw area is noisy, so the reading is ranked
//      against its own recent history and a lead is declared only when the
//      rotation is unusually strong for this symbol and timeframe. Otherwise
//      the state is BALANCED (no claim).
//    • SEQUENCING, NOT CAUSATION — a signed area indicates temporal ordering
//      tendency, not cause. The literature is explicit that sign alone cannot
//      establish causal direction; treat this as tape character.
//    • KNOWN LIMITATION — persistent INVERSE co-movement can contaminate the
//      sign. On instruments where flow and price reliably anti-correlate the
//      read is unreliable; on liquid futures they co-move and the read behaves.
//    • MOST EXPERIMENTAL — this is a research instrument for reading tape
//      character. It makes no performance claim of any kind.
//
//  HOW TO READ IT (price overlay)
//    Dashboard states FLOW LEADS / PRICE LEADS / BALANCED with the rotation
//    strength. Tags print when the lead flips while significant. Typical use:
//    breakouts and drives carry more weight when FLOW LEADS (participation
//    first); be more sceptical of extensions when PRICE LEADS (flow chasing).
//    Context for your own process — never a signal.
//
//  NON-REPAINT
//    Delta accumulates on confirmed bars from closed lower-timeframe data; the
//    area is computed on confirmed bars. The live bar is provisional.
//
//  USE ON ANY MARKET
//    Volume source and lower timeframe are selectable with an automatic
//    bar-shape fallback; the area is scale-free. Defaults suit liquid index
//    futures.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Signed area of stochastic paths — P. Lévy. Rough-path / signature
//      theory — T. Lyons; Levin, Lyons & Ni (2016).
//    • Signature lead–lag metric and interpretation — I. Chevyrev &
//      A. Kormilitzin (2016); applications to markets — Bennett, Cucuringu &
//      Reinert (2022); Cartea, Cucuringu & Jin (2023).
//    Implementation and charting design are the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. The area measures a sequencing tendency
//    in past data; it is not causal proof and not a prediction. Validate
//    independently and manage your own risk.
// =============================================================================
indicator("Lévy-Area Flow Sequencer — Flow/Price Lead-Lag", "Flow Sequencer",
     overlay = true, max_labels_count = 200, max_bars_back = 5000)

// ═════════════════════════ 00 · DATA SOURCE ═════════════════════════════════
g0 = "00 · Data source"
srcPrice = input.source(close, "Price source", group = g0)
volSrc = input.source(volume, "Volume source", group = g0,
     tooltip = "Volume series used to build signed order-flow delta.")
useLtf = input.bool(true, "Delta from lower-timeframe volume", group = g0,
     tooltip = "ON = build signed delta from finer intrabar candles (truer order flow). Automatic bar-shape fallback where intrabar data is unavailable.")
ltfPick = input.string("Auto (finest)", "Lower timeframe for delta",
     options = ["Auto (finest)", "1 second", "5 seconds", "1 minute"], group = g0)

// ═════════════════════════ 01 · ROTATION MEASURE ════════════════════════════
g1 = "01 · Rotation measure"
areaWin = input.int(50, "Area window (bars)", minval = 10, maxval = 300, group = g1,
     tooltip = "How many bars of the joint flow/price path the signed area is measured over.")
aSmooth = input.int(3, "Area smoothing", minval = 1, maxval = 20, group = g1)

// ═════════════════════════ 02 · SIGNIFICANCE ════════════════════════════════
g2 = "02 · Significance"
sigLevel = input.float(75.0, "Lead declared above (|area| percentile)", minval = 50.0, maxval = 99.0, step = 1.0, group = g2,
     tooltip = "A lead is claimed only when the rotation strength ranks above this percentile of its own history. Below it, the state is BALANCED — no claim.")
sigLook  = input.int(300, "Self-calibration lookback", minval = 50, maxval = 2000, group = g2)

// ═════════════════════════ 03 · STABILITY & OUTPUT ══════════════════════════
g3 = "03 · Stability & output"
minDwell = input.int(5, "Confirm state after (bars)", minval = 1, maxval = 50, group = g3,
     tooltip = "Minimum-dwell debounce (standard anti-chattering design): a new FLOW LEADS / PRICE LEADS / BALANCED state is ANNOUNCED only after it survives this many confirmed bars. Removes flip-flop at the cost of this many bars of lag — both stated.")
showLane = input.bool(true, "Lead lane (strip at pane bottom)", group = g3,
     tooltip = "A thin colored strip along the bottom: green = flow leads (moves better backed), amber = price leads (flow chasing, be sceptical), gray = balanced. Trust/caution colors, never direction.")
showTag  = input.bool(true, "Tag on lead flip", group = g3)
showTint = input.bool(true, "Background tint while a lead is significant", group = g3)

// ═════════════════════════ 04 · DASHBOARD ═══════════════════════════════════
g4 = "04 · Dashboard"
showDash  = input.bool(true, "Show main dashboard", group = g4)
compactTbl= input.bool(false, "Compact dashboard", group = g4)
dashPos   = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g4)
showId    = input.bool(false, "Show name / symbol / timeframe label (separate table)", group = g4)

// ═════════════════════════ 05 · MULTI-TIMEFRAME ═════════════════════════════
g5m = "05 · Multi-timeframe stack"
mtfOn = input.bool(true, "Show higher-timeframe lead states", group = g5m,
     tooltip = "Computes the RAW lead state (no dwell — higher timeframes are inherently slower) on three higher timeframes derived as MULTIPLES of the chart. NOTE: lower-timeframe data cannot be requested inside a higher-timeframe request, so the HTF slots use the bar-shape delta proxy — a stated approximation. Standard HTF requests — available on every plan and symbol.")
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
var color COL_COOL = #2ebd85

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

// ───────────────────────── MTF RAW LEAD (higher timeframes) ─────────────────
// Same signed-area logic in a higher-timeframe context. Uses the BAR-SHAPE
// delta proxy (lower-timeframe data cannot be requested inside a higher-
// timeframe request — a stated approximation). Raw, no dwell. Returns
// -9 warming, 0 balanced, +1 flow leads, -1 price leads.
f_leadStateMTF() =>
    float bs = (high - low) > 0 ? nz(volSrc, 0.0) * ((close - low) - (high - close)) / (high - low) : 0.0
    float pc = srcPrice - nz(srcPrice[1], srcPrice)
    float sx = ta.stdev(bs, areaWin)
    float sy = ta.stdev(pc, areaWin)
    float a0 = na
    if bar_index >= areaWin + 2 and sx > 0 and sy > 0
        float acc = 0.0
        float Xp = 0.0
        float Yp = 0.0
        for k = 0 to areaWin - 1
            int off = areaWin - 1 - k
            float dx = nz(bs[off]) / sx
            float dy = nz(pc[off]) / sy
            acc += Xp * dy - Yp * dx
            Xp += dx
            Yp += dy
        a0 := acc / areaWin
    float aS = f_emaSeed(a0, aSmooth)
    float rr = ta.percentrank(nz(math.abs(aS), 0.0), sigLook)
    bool rdy = not na(aS) and bar_index > areaWin + sigLook / 2
    int st = not rdy ? -9 : rr >= sigLevel ? (aS > 0 ? 1 : -1) : 0
    st

f_tfFromMult(int m) =>
    int secs = timeframe.in_seconds() * m
    secs % 604800 == 0 ? str.tostring(secs / 604800) + "W" : secs % 86400 == 0 ? str.tostring(secs / 86400) + "D" : secs % 60 == 0 ? str.tostring(secs / 60) : str.tostring(secs) + "S"
string htfTf1 = f_tfFromMult(mtfM1)
string htfTf2 = f_tfFromMult(mtfM2)
string htfTf3 = f_tfFromMult(mtfM3)
int htfLead1 = request.security(syminfo.tickerid, htfTf1, f_leadStateMTF(), lookahead = barmerge.lookahead_off)
int htfLead2 = request.security(syminfo.tickerid, htfTf2, f_leadStateMTF(), lookahead = barmerge.lookahead_off)
int htfLead3 = request.security(syminfo.tickerid, htfTf3, f_leadStateMTF(), lookahead = barmerge.lookahead_off)
f_ldShort(int r) =>
    r == 1 ? "FLOW" : r == -1 ? "PRICE" : r == 0 ? "BAL" : "—"

// ───────────────────────── ORDER-FLOW DELTA (finest LTF, fallback) ──────────
f_ltfSel() =>
    switch ltfPick
        "1 second"  => "1S"
        "5 seconds" => "5S"
        "1 minute"  => "1"
        => "1S"
string ltfTf = f_ltfSel()
f_signedVol() => math.sign(close - close[1]) * volume
float[] ltfArr = request.security_lower_tf(syminfo.tickerid, ltfTf, f_signedVol())
float ltfSum = 0.0
if array.size(ltfArr) > 0
    for v in ltfArr
        ltfSum += nz(v)
bool ltfOk = useLtf and array.size(ltfArr) > 0
float barShape = (high - low) > 0 ? nz(volSrc, 0.0) * ((close - low) - (high - close)) / (high - low) : 0.0
float delta = ltfOk ? ltfSum : barShape
string deltaMode = ltfOk ? ("LTF " + ltfTf) : "bar-shape"

// ───────────────────────── SIGNED (LÉVY) AREA ───────────────────────────────
// Antisymmetric second-level signature of the (flow, price) increment pair over
// the window. Increments: dx = delta (flow), dy = price change; both normalized
// by their window dispersion so the area is dimensionless. Single pass, oldest
// to newest, running path prefixes — no arrays. Gated to confirmed bars.
float priceChg = srcPrice - nz(srcPrice[1], srcPrice)
float sdx = ta.stdev(delta,    areaWin)
float sdy = ta.stdev(priceChg, areaWin)

f_levyArea() =>
    float a = na
    if bar_index >= areaWin + 2 and sdx > 0 and sdy > 0
        float acc = 0.0
        float Xp = 0.0
        float Yp = 0.0
        for k = 0 to areaWin - 1
            int off = areaWin - 1 - k   // oldest bar first
            float dx = nz(delta[off]) / sdx
            float dy = nz(priceChg[off]) / sdy
            acc += Xp * dy - Yp * dx
            Xp += dx
            Yp += dy
        a := acc / areaWin
    a

var float areaRaw = na
if barstate.isconfirmed
    areaRaw := f_levyArea()
float area = f_emaSeed(areaRaw, aSmooth)

// ───────────────────────── SIGNIFICANCE (self-calibrated) ───────────────────
float absArea = math.abs(area)
float rotRankRaw = ta.percentrank(nz(absArea, 0.0), sigLook)
float rotRank = not na(area) ? rotRankRaw : na
bool readyR = not na(rotRank) and bar_index > areaWin + sigLook / 2
bool sigR = readyR and rotRank >= sigLevel
int rawLead = not readyR ? -9 : sigR ? (area > 0 ? 1 : -1) : 0
// minimum-dwell debounce: a new state is announced only after it survives
// minDwell confirmed bars (anti-chattering; lag = dwell bars, stated)
var int lead  = -9
var int lcand = -9
var int lcAge = 0
if barstate.isconfirmed
    if rawLead == lead
        lcand := lead
        lcAge := 0
    else
        if rawLead == lcand
            lcAge += 1
        else
            lcand := rawLead
            lcAge := 1
        if lcAge >= minDwell or lead == -9
            lead := rawLead
            lcand := rawLead
            lcAge := 0
bool ready = lead != -9
bool sig = ready and lead != 0
int stabWin = 50
int stabSame = 0
for k = 0 to stabWin - 1
    if nz(lead[k], -8) == lead
        stabSame += 1
float stabPct = ready ? stabSame * 100.0 / stabWin : na
string stateTxt = not ready ? "WARMING" : lead == 1 ? "FLOW LEADS" : lead == -1 ? "PRICE LEADS" : "BALANCED"
string readTxt = not ready ? "-" :
     lead == 1 ? "participation precedes price · moves better backed" :
     lead == -1 ? "price precedes flow · flow chasing, be sceptical" :
     "no significant rotation · no claim"
bool leadFlip = ready and lead != 0 and lead != nz(lead[1]) and barstate.isconfirmed

// ───────────────────────── PLOTS (price overlay) ────────────────────────────
color tintC = not sig ? na : lead == 1 ? color.new(COL_COOL, 93) : color.new(COL_MID, 93)
bgcolor(showTint ? tintC : na, title = "Lead tint")

// lead lane: thin colored strip at the pane bottom (trust/caution glance-read)
color laneC = lead == 1 ? color.new(COL_COOL, 0) : lead == -1 ? color.new(COL_MID, 0) : color.new(cMute, 30)
plotshape(showLane and ready, "Lead lane", style = shape.square, location = location.bottom, color = laneC, size = size.tiny)

var label[] tags = array.new<label>()
if showTag and leadFlip
    string tagTxt = lead == 1 ? "FLOW→PRICE" : "PRICE→FLOW"
    color tagCl = lead == 1 ? color.new(COL_COOL, 10) : color.new(COL_MID, 10)
    lb = label.new(bar_index, high, tagTxt, style = label.style_label_down, color = tagCl, textcolor = color.white, size = size.small, tooltip = "Lead-lag rotation flipped while significant. A sequencing tendency of past bars — not causation, not a direction.")
    array.push(tags, lb)
    if array.size(tags) > 50
        label.delete(array.shift(tags))

// ───────────────────────── DASHBOARD (institution, adaptive) ─────────────────
f_setRow(table t, int r, string lbl, string val, color vc, color lc, color bg) =>
    table.cell(t, 0, r, lbl, text_color = lc, text_size = size.tiny,  text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, val, text_color = vc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

var table dash = na
if showDash and barstate.islast
    color stBg = not ready ? color.new(cMute, 0) : lead == 1 ? color.new(cBull, 0) : lead == -1 ? color.new(cWarn, 0) : color.new(COL_INFO, 0)
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, compactTbl ? 4 : 10, border_width = 1, frame_color = frameCl, frame_width = 1)
    table.set_frame_color(dash, frameCl)
    table.set_border_color(dash, frameCl)
    table.cell(dash, 0, 0, " FLOW SEQUENCER", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = stBg, tooltip = "Signed (Lévy) area of the joint flow/price path: who tends to move first. Sequencing tendency, not causation. Experimental research context — never a direction.")
    table.cell(dash, 1, 0, stateTxt + " ", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = stBg)
    f_setRow(dash, 1, "READ", readTxt, ready ? tVal : cMute, tLbl, zebraA)
    f_setRow(dash, 2, "ROTATION", na(rotRank) ? "-" : "p" + str.tostring(math.round(rotRank)) + (sig ? " · significant" : " · weak"), sig ? cBull : cMute, tLbl, zebraB)
    if not compactTbl
        f_setRow(dash, 3, "STABILITY", na(stabPct) ? "-" : str.tostring(math.round(stabPct)) + "% of last " + str.tostring(stabWin), na(stabPct) ? cMute : stabPct >= 80 ? cBull : stabPct >= 50 ? tVal : cWarn, tLbl, zebraA)
        string pendTxt = ready and lcand != lead and lcAge > 0 ? f_ldShort(lcand) + " in " + str.tostring(minDwell - lcAge) + " bars" : "none"
        f_setRow(dash, 4, "PENDING", pendTxt, pendTxt == "none" ? cMute : cWarn, tLbl, zebraB)
        f_setRow(dash, 5, "AREA", na(area) ? "-" : str.tostring(area, "0.000"), na(area) ? cMute : area > 0 ? cBull : cWarn, tLbl, zebraA)
        f_setRow(dash, 6, "DELTA SOURCE", deltaMode, ltfOk ? cBull : cWarn, tLbl, zebraB)
        if mtfOn
            bool actionable = lead == 1 or lead == -1
            bool mtfAgree = actionable and htfLead1 == lead and htfLead2 == lead and htfLead3 == lead
            bool mtfOppose = actionable and (((htfLead1 == 1 or htfLead1 == -1) and htfLead1 != lead) or ((htfLead2 == 1 or htfLead2 == -1) and htfLead2 != lead) or ((htfLead3 == 1 or htfLead3 == -1) and htfLead3 != lead))
            string mtfTxt = str.tostring(mtfM1) + "× " + f_ldShort(htfLead1) + " · " + str.tostring(mtfM2) + "× " + f_ldShort(htfLead2) + " · " + str.tostring(mtfM3) + "× " + f_ldShort(htfLead3) + (mtfAgree ? "  ✓" : mtfOppose ? "  ⚠" : "")
            f_setRow(dash, 7, "HTF STACK", mtfTxt, mtfAgree ? cBull : mtfOppose ? cWarn : tVal, tLbl, zebraA)
        else
            f_setRow(dash, 7, "HTF STACK", "off", cMute, tLbl, zebraA)
        f_setRow(dash, 8, "WINDOW", str.tostring(areaWin) + " bars · dwell " + str.tostring(minDwell), tVal, tLbl, zebraB)
        f_setRow(dash, 9, "NOTE", "experimental · sequencing ≠ causation", cMute, tLbl, zebraA)

// identity label (separate toggle)
var table idTbl = na
if showId and barstate.islast
    if na(idTbl)
        idTbl := table.new(position.bottom_center, 1, 1)
    table.cell(idTbl, 0, 0, "Flow Sequencer  ·  " + syminfo.ticker + "  " + timeframe.period, text_color = color.new(tLbl, 15), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────── EXPORTS (Data Window · generic names) ────────────
plot(area,    "EXP_LevyArea",      display = display.data_window)
plot(rotRank, "EXP_RotationRank",  display = display.data_window)
plot(ready ? lead : na, "EXP_LeadState", display = display.data_window)
plot(delta,   "EXP_SignedDelta",   display = display.data_window)
plot(stabPct, "EXP_LeadStability", display = display.data_window)
plot(mtfOn ? htfLead1 : na, "EXP_LeadHTF1", display = display.data_window)
plot(mtfOn ? htfLead2 : na, "EXP_LeadHTF2", display = display.data_window)
plot(mtfOn ? htfLead3 : na, "EXP_LeadHTF3", display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(leadFlip and lead == 1,  "Flow leads", "Flow Sequencer: rotation flipped — flow now precedes price")
alertcondition(leadFlip and lead == -1, "Price leads", "Flow Sequencer: rotation flipped — price now precedes flow")
````
