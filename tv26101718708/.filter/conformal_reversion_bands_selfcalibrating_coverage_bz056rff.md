# Conformal Reversion Bands  Self-Calibrating Coverage

- url: https://www.tradingview.com/script/bz056rFF-Conformal-Reversion-Bands-Self-Calibrating-Coverage/
- type: indicator
- pine_id: PUB;11749931a10049e2b83ef7a2751fb489
- version: 2.0

## Description

Conformal Reversion Bands — Self-Calibrating Coverage

What it is

Ordinary bands lie about themselves. A Bollinger "2σ" band or an ATR band asserts a coverage it does not deliver — real price isn't Gaussian, so the band that's supposed to contain 95% of bars might actually contain 88% or 98%, and that fraction drifts as volatility changes. The label and the chart disagree.

Conformal Reversion Bands fix this. You choose the coverage you want (e.g. 90%), and the band's half-width is a nonconformity quantile that is tracked online so the realised coverage actually converges to your target — and self-corrects when it drifts. The indicator then displays target vs realised coverage live, so you can see the guarantee holding instead of taking it on faith. A breach of a calibrated 95% band means something precise: price did what it does under about 5% of the time — a genuine rare excursion, and a mean-reversion (fade) candidate back toward fair value.

How it works (and why this specific method)

Centre — a fair-value line the bands revert to: session VWAP by default (auto-fallback to a robust rolling median on symbols without reliable volume), or EMA / median by choice.
Score — the absolute deviation of price from the centre. Its running quantile is the band half-width.

Online calibration — this uses the quantile tracker ("conformal P control") of Angelopoulos, Candès & Tibshirani (2023), with an optional error integrator ("PI control"). This is deliberately chosen over the older Adaptive Conformal Inference (ACI): ACI adapts the significance level and can occasionally produce infinite or null intervals; tracking the quantile on the scale of the scores cannot degenerate that way, so the bands stay finite and well-behaved on live charts. ACI is in fact a special case of the tracker.

Volatility-normalized scores (locally adaptive) — scores are normalized by a local volatility estimate before calibration (the Papadopoulos–Gammerman–Vovk normalized-nonconformity idea), so the band width breathes with volatility bar-by-bar. This targets conditional coverage — not too wide in calm tape, not too narrow in fast tape — instead of only a global average.

Decaying step size — the learning step shrinks as calibration matures (Angelopoulos–Barber–Bates) for tighter long-run coverage, floored so the bands never stop adapting to new regimes.

Self-check — a trailing window measures realised coverage for both bands and reports how closely it tracks target. That readout is the whole point: it makes the band's core claim verifiable on your own chart. Note the honest theoretical ceiling: exact conditional coverage is impossible distribution-free; normalization gets most of the practical way there at negligible cost.

Everything advances only on confirmed bars: the band shown on a bar is calibrated on scores up to the previous bar, then that bar is tested against it — no hindsight fitting.

How to use it

Add to any liquid symbol/timeframe; set the coverage you want for the inner and outer bands. Defaults suit index futures; change the price/volume sources in Data source for any other market.

Read the dashboard headline first: it states CALIBRATED / ADAPTING / WARMING in plain language, with a colour anyone can read at a glance. When the inner and outer rows show target and realised % matching (✓), the bands are provably doing their job.
Treat an outer-band breach as a statistically rare excursion — a fade-toward-centre candidate (optional close-back-inside confirmation).

Watch COMPRESSION: a low band-width percentile means the bands are unusually tight (a volatility squeeze — expansion often follows); a high percentile means unusually wide.
Divergences (price vs the band's own normalized deviation, or RSI — your choice) are drawn as lines on price for context.

The dashboard and the identity label are separate toggles; the price/volume sources, coverage targets and every window are adjustable. Works as an honest, self-calibrating replacement for Bollinger/Keltner/ATR bands anywhere you use deviation bands.

What makes it original

Almost nothing on TradingView ships real conformal prediction, and — as far as the author is aware — nothing ships the modern quantile-tracker / PI-control variant with a live coverage readout that proves the band's claim on-chart. The contribution is bringing a 2023-frontier uncertainty-quantification method to price bands in a form a trader can verify at a glance, rather than a σ-multiplier that only pretends to a coverage level. The band-width compression read and the band-native divergence are natural, honest by-products of the same construction — context, not a signal service.

Concept credits

Conformal prediction — V. Vovk, A. Gammerman, G. Shafer. Normalized nonconformity — H. Papadopoulos, A. Gammerman, V. Vovk (2008). Adaptive Conformal Inference — I. Gibbs & E. Candès (2021). Quantile tracker / Conformal PID control — A. Angelopoulos, E. Candès & R. Tibshirani (2023). Decaying step — A. Angelopoulos, R. Barber, S. Bates (2024). VWAP — classical. Implementation and charting design are the author's own.

Important disclaimer

Research and education only. Not financial advice, not a signal service, not a guarantee of future results. Coverage is a statistical property of the band width — it is not a claim that fading breaches is profitable. The readout is descriptive of the past on the current chart, not a forward guarantee. Validate independently, apply realistic costs and slippage, and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  CONFORMAL REVERSION BANDS                                                v1.1
//  Self-calibrating deviation bands with a PROVABLE, displayed coverage rate.
// -----------------------------------------------------------------------------
//  v1.1 — House-standard pass (no engine change):
//    • Added the MPL-2.0 licence header and an EXP_ Data-Window export bus.
//    • No correctness fix needed — no conditional ta.* in this script.
//    • No cost model: this is a coverage/interval tool, not a directional signal.
// -----------------------------------------------------------------------------
//  THE PROBLEM WITH ORDINARY BANDS
//    Bollinger (kσ) and ATR bands assert a coverage they do not deliver. Real
//    price is not Gaussian, so a "2σ" band might actually contain 88% or 97% of
//    bars, and that fraction drifts as volatility regime changes. The number on
//    the label is not the number on the chart.
//
//  WHAT THIS DOES INSTEAD (conformal prediction, online)
//    You choose the coverage you want (say 90%). The band's half-width is a
//    nonconformity quantile that is TRACKED ONLINE so the realised coverage
//    actually converges to your target — and self-corrects when it drifts. A
//    breach of a calibrated 95% band then means something precise: price did
//    what it does under ~5% of the time. The panel shows TARGET vs REALISED
//    coverage live, so the guarantee is visible, not asserted.
//
//  METHOD (why this specific algorithm)
//    Uses the QUANTILE TRACKER ("conformal P control") of Angelopoulos, Candès &
//    Tibshirani (2023), with an optional error INTEGRATOR ("PI control"). This is
//    the current state of the art and is chosen deliberately over the older
//    Adaptive Conformal Inference (ACI, Gibbs & Candès 2021): ACI adapts the
//    significance level and can output infinite or null intervals when it drifts;
//    tracking the quantile on the SCALE OF THE SCORES cannot degenerate that way,
//    so the bands stay finite and well-behaved on live data. ACI is in fact a
//    special case of the tracker. The score is the absolute deviation of price
//    from a fair-value centre; its (1−α) quantile is the band half-width.
//
//  HOW TO READ IT
//    Centre line = fair value (VWAP by default). Inner + outer calibrated bands
//    around it. A tag marks a breach of the OUTER band = a statistically rare
//    excursion → mean-reversion (fade) candidate, back toward the centre. The
//    coverage panel is the point: if "target 90 / actual ~90" holds, the tool is
//    provably doing its job — no edge assumption required.
//
//  NON-REPAINT
//    The band shown on bar t uses a width calibrated on scores up to t−1; bar t's
//    deviation is then tested against it and feeds the next update. All state
//    advances only on CONFIRMED bars, so nothing is fitted with hindsight.
//
//  USE ON ANY MARKET
//    Price and volume sources are selectable. VWAP centre falls back to a robust
//    rolling median automatically on symbols without reliable volume.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Conformal prediction — V. Vovk, A. Gammerman, G. Shafer.
//    • Adaptive Conformal Inference (ACI) — I. Gibbs & E. Candès (2021).
//    • Quantile tracker / Conformal PID control — A. Angelopoulos, E. Candès &
//      R. Tibshirani (2023).
//    • Normalized nonconformity (volatility-scaled scores) — H. Papadopoulos,
//      A. Gammerman & V. Vovk (2008).
//    • Decaying online step size — A. Angelopoulos, R. Barber & S. Bates (2024).
//    • Volume-weighted average price — classical.
//    Implementation and charting design are the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. Coverage is a statistical property of the
//    band width; it is not a claim that fading breaches is profitable. Validate
//    independently, apply realistic costs, and manage your own risk.
// =============================================================================
indicator("Conformal Reversion Bands — Self-Calibrating Coverage", "Conformal Bands",
     overlay = true, max_labels_count = 500, max_lines_count = 200, max_bars_back = 5000)

// ═════════════════════════ 00 · DATA SOURCE (any market) ════════════════════
g0 = "00 · Data source"
srcPrice = input.source(close,  "Price source", group = g0,
     tooltip = "Series the bands are built around. Default 'close'. Change for spreads or custom symbols.")
volSrc   = input.source(volume, "Volume source", group = g0,
     tooltip = "Volume for the VWAP centre. On symbols with no reliable volume the centre falls back to a rolling median automatically.")

// ═════════════════════════ 01 · CENTRE (fair value) ═════════════════════════
g1 = "01 · Centre line"
centreMode = input.string("VWAP (auction fair value)", "Centre",
     options = ["VWAP (auction fair value)", "EMA", "Rolling median"], group = g1,
     tooltip = "What the bands revert to. VWAP is session fair value (default). EMA is smooth/familiar. Rolling median is robust to spikes.")
emaLen = input.int(20, "EMA length",    minval = 2, group = g1)
medLen = input.int(20, "Median length", minval = 3, group = g1)

// ═════════════════════════ 02 · CONFORMAL CALIBRATION ═══════════════════════
g2 = "02 · Conformal calibration"
covIn   = input.float(0.80, "Inner band coverage", minval = 0.50, maxval = 0.99, step = 0.01, group = g2,
     tooltip = "Target fraction of bars the INNER band should contain (e.g. 0.80 = 80%).")
covOut  = input.float(0.95, "Outer band coverage", minval = 0.60, maxval = 0.999, step = 0.005, group = g2,
     tooltip = "Target fraction for the OUTER band. A breach of this band is the rare-excursion / fade signal.")
lr      = input.float(0.10, "Tracker learning rate", minval = 0.005, maxval = 1.0, step = 0.005, group = g2,
     tooltip = "How fast the band half-width chases its target coverage (quantile-tracker step). Higher = tighter coverage, more width movement.")
normOn  = input.bool(true, "Volatility-normalized (locally adaptive)", group = g2,
     tooltip = "ON = scores are normalized by local volatility, so the band breathes with volatility bar-by-bar (better CONDITIONAL coverage: not too wide in calm tape, not too narrow in fast tape). This is the Papadopoulos–Gammerman–Vovk normalized-nonconformity idea. OFF = a single global width.")
sigLen  = input.int(20, "Local volatility length", minval = 3, maxval = 200, group = g2,
     tooltip = "Lookback for the local volatility estimate used to normalize scores.")
decayOn = input.bool(true, "Decaying step size", group = g2,
     tooltip = "Shrinks the learning step as calibration matures (Angelopoulos–Barber–Bates), for tighter long-run coverage while still adapting.")
useIntg = input.bool(true, "Integrator (PI control)", group = g2,
     tooltip = "Adds an error-integrating term that removes slow, persistent under/over-coverage the proportional tracker leaves behind. The 'I' in PID control.")
intgGain = input.float(0.05, "Integrator gain", minval = 0.0, maxval = 0.5, step = 0.01, group = g2)
scoreWin = input.int(250, "Calibration window (seed & scale)", minval = 30, maxval = 1000, group = g2,
     tooltip = "How many recent scores seed the initial quantiles and set the scale.")
minWATR  = input.float(0.10, "Minimum band half-width (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = g2,
     tooltip = "Floor on band width so it never collapses to zero.")

// ═════════════════════════ 03 · SIGNALS ═════════════════════════════════════
g3 = "03 · Signals"
showBreak = input.bool(true, "Fade arrows on outer-band breach", group = g3,
     tooltip = "Marks a statistically rare excursion beyond the outer band — a mean-reversion (fade) candidate back toward the centre.")
needClose = input.bool(false, "Require close back inside to confirm", group = g3,
     tooltip = "ON = only mark a fade once price closes back inside the outer band (fewer, later, cleaner). OFF = mark the breach as it happens.")
showDiv   = input.bool(true, "Divergences (price vs oscillator)", group = g3,
     tooltip = "Regular divergence between price and the chosen oscillator, drawn as lines on price. Bull = price lower low, oscillator higher low; Bear = price higher high, oscillator lower high.")
divSrcOpt = input.string("Band deviation", "Divergence oscillator",
     options = ["Band deviation", "RSI"], group = g3,
     tooltip = "Band deviation = the band's own normalized deviation from fair value (native to this tool). RSI = the classic momentum oscillator.")
rsiLen    = input.int(14, "RSI length (if used)", minval = 2, maxval = 100, group = g3)
pvL       = input.int(5, "Divergence pivot left",  minval = 2, maxval = 20, group = g3)
pvR       = input.int(3, "Divergence pivot right", minval = 1, maxval = 10, group = g3)
divKeep   = input.int(10, "Divergence lines to keep", minval = 1, maxval = 50, group = g3)

// ═════════════════════════ 04 · COVERAGE & COMPRESSION ══════════════════════
g4 = "04 · Coverage & compression"
covWin  = input.int(300, "Realised-coverage window", minval = 50, maxval = 2000, group = g4,
     tooltip = "Trailing window over which realised coverage is measured for the dashboard — the tool's live self-check.")
bwWin   = input.int(250, "Compression lookback", minval = 20, maxval = 1000, group = g4,
     tooltip = "Window for the band-width percentile. A low percentile = the bands are unusually tight (a volatility squeeze — expansion often follows); a high percentile = unusually wide.")

// ═════════════════════════ 05 · DASHBOARD ═══════════════════════════════════
g5 = "05 · Dashboard"
showDash  = input.bool(true, "Show main dashboard", group = g5)
compactTbl= input.bool(false, "Compact dashboard (off = full institution table)", group = g5)
dashPos   = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g5)
showId    = input.bool(false, "Show name / symbol / timeframe label (separate table)", group = g5,
     tooltip = "A small identity tag at the bottom of the chart. Independent of the main dashboard.")

// ═════════════════════════ 06 · STYLE ═══════════════════════════════════════
g6 = "06 · Style"
showFill = input.bool(true, "Fill bands (reversion-heat)", group = g6)
tintBasis= input.bool(true, "Tint centre line by price side", group = g6)
themeOpt = input.string("Auto (match chart)", "Theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g6)

// ───────────────────────── PALETTE / THEME (adaptive, institution) ──────────
var color COL_BULL = #2ebd85
var color COL_BEAR = #f6465d
var color COL_MID  = #f7c948
var color COL_INFO = #3d6cf0

f_lumaDark(color c) =>
    na(c) ? true : (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) < 140
bool isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lumaDark(chart.bg_color)
// institution palette (adaptive light/dark)
color tBord  = isDark ? color.new(#3a4250, 0)  : color.new(#c2c8d0, 0)
color tLbl   = isDark ? #9aa3b2 : #515a67
color tVal   = isDark ? #f2f4f8 : #10151d
color cBull  = isDark ? #2dd4bf : #0e9e76
color cBear  = isDark ? #ff6b6b : #d32f2f
color cWarn  = isDark ? #ffa94d : #b56a00
color cInfo  = isDark ? #ffd43b : #9a7400
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

// empirical quantile of an array (linear index), used only to seed
f_quantile(float[] a, float q) =>
    float r = na
    int n = array.size(a)
    if n > 0
        float[] b = array.copy(a)
        array.sort(b, order.ascending)
        int idx = int(math.round(q * (n - 1)))
        idx := math.max(0, math.min(n - 1, idx))
        r := array.get(b, idx)
    r

// ───────────────────────── CENTRE (fair value + fallback) ───────────────────
float volAvg = ta.sma(nz(volSrc), 20)
bool volOK = not na(volSrc) and volAvg > 0
float cVwap = ta.vwap(hlc3)
float cEma  = ta.ema(srcPrice, emaLen)
float cMed  = ta.median(srcPrice, medLen)
float centre = centreMode == "EMA" ? cEma : centreMode == "Rolling median" ? cMed : (volOK ? cVwap : cMed)
string centreUsed = centreMode == "EMA" ? "EMA" : centreMode == "Rolling median" ? "Median" : (volOK ? "VWAP" : "Median (no vol)")
float atrV = ta.atr(14)
float minW = minWATR * atrV

// ───────────────────────── CONFORMAL QUANTILE TRACKER ───────────────────────
// Score = |deviation from centre| normalized by local volatility, so the band
// adapts to heteroscedastic tape (better conditional coverage). Two coverage
// quantiles of that score are tracked online (Angelopoulos–Candès–Tibshirani):
// one for the inner band, one for the outer. Because both are quantiles of the
// same non-negative score, the outer band always encloses the inner.
float dev    = srcPrice - centre                       // signed deviation
float sigRaw = ta.ema(math.abs(dev), sigLen)           // local deviation scale
float minWv  = nz(minW, 0.0)                            // ATR floor (0 while ATR warms up)
float sigN   = nz(sigRaw[1], sigRaw)                    // lagged local scale
float sig    = normOn ? (na(sigN) or sigN <= 0 ? na : math.max(sigN, minWv)) : 1.0
float sAbs   = (na(sig) or sig <= 0 or na(dev)) ? na : math.abs(dev) / sig   // normalized score
float scaleE = normOn ? 1.0 : math.max(nz(sigRaw, 0.0), math.max(minWv, 1.0))

var float qIn    = na                                  // cov-quantile of sAbs (inner)
var float qOut   = na                                  // cov-quantile of sAbs (outer)
var float intIn  = 0.0
var float intOut = 0.0
var int   updN   = 0
var bool  seeded = false
var float[] sArr = array.new_float(0)
var int[] flagIn  = array.new_int(0)
var int[] flagOut = array.new_int(0)

// Bands drawn this bar use widths calibrated on PRIOR bars (non-repainting).
// Outer >= inner is guaranteed: both are quantiles of the SAME non-negative
// score and covOut > covIn implies qOut >= qIn (a safety floor also enforces it).
float halfIn  = seeded and not na(sig) ? math.max(qIn  * sig, minWv) : na
float halfOut = seeded and not na(sig) ? math.max(qOut * sig, minWv) : na
float upIn  = na(halfIn)  ? na : centre + halfIn
float loIn  = na(halfIn)  ? na : centre - halfIn
float upOut = na(halfOut) ? na : centre + halfOut
float loOut = na(halfOut) ? na : centre - halfOut

if barstate.isconfirmed and not na(centre) and not na(sAbs)
    if seeded
        // coverage measured directly on the calibrated score (matches the drawn
        // band): inside inner iff sAbs <= qIn, inside outer iff sAbs <= qOut.
        bool insIn  = sAbs <= qIn
        bool insOut = sAbs <= qOut
        array.push(flagIn,  insIn  ? 1 : 0)
        array.push(flagOut, insOut ? 1 : 0)
        if array.size(flagIn)  > covWin
            array.shift(flagIn)
        if array.size(flagOut) > covWin
            array.shift(flagOut)
        // decaying step (floored so it never stops adapting)
        float dfac = decayOn ? math.max(0.35, math.sqrt(scoreWin / float(scoreWin + updN))) : 1.0
        float step = lr * scaleE * dfac
        // quantile-tracker:  q += step*(cov - 1{sAbs < q}); equilibrium P(sAbs<q)=cov
        float indIn  = sAbs < qIn  ? 1.0 : 0.0
        float indOut = sAbs < qOut ? 1.0 : 0.0
        intIn  += covIn  - indIn
        intOut += covOut - indOut
        float satIn  = useIntg ? intgGain * scaleE * (2.0 / math.pi) * math.atan(intIn  / 20.0) : 0.0
        float satOut = useIntg ? intgGain * scaleE * (2.0 / math.pi) * math.atan(intOut / 20.0) : 0.0
        qIn  := math.max(qIn  + step * (covIn  - indIn)  + satIn, 0.0)
        qOut := math.max(qOut + step * (covOut - indOut) + satOut, qIn)   // outer >= inner
        updN += 1
    // record only FINITE scores; seed the two quantiles once the window is full
    array.push(sArr, sAbs)
    if array.size(sArr) > scoreWin
        array.shift(sArr)
    if not seeded and array.size(sArr) >= scoreWin
        qIn  := nz(f_quantile(sArr, covIn), 0.0)
        qOut := math.max(nz(f_quantile(sArr, covOut), qIn), qIn)
        seeded := true

// realised coverage
int nCov = array.size(flagOut)
float covRealIn  = array.size(flagIn)  > 0 ? array.sum(flagIn)  / float(array.size(flagIn))  : na
float covRealOut = array.size(flagOut) > 0 ? array.sum(flagOut) / float(array.size(flagOut)) : na
bool warm = seeded and nCov >= math.min(covWin, 50)

// compression / squeeze: percentile of the outer band width (volatility state)
float bandW  = seeded and not na(upOut) and centre != 0 ? (upOut - loOut) / centre : na
float bwRaw  = ta.percentrank(nz(bandW, 0.0), bwWin)
float bwPct  = seeded and not na(bandW) ? bwRaw : na
string bwState = na(bwPct) ? "—" : bwPct <= 15 ? "SQUEEZE" : bwPct >= 85 ? "EXPANDED" : "normal"

// ───────────────────────── SIGNALS (rare-excursion fades) ───────────────────
bool brkUp = seeded and srcPrice > upOut
bool brkDn = seeded and srcPrice < loOut
bool fadeShort = needClose ? (brkUp[1] and srcPrice <= upOut) : brkUp
bool fadeLong  = needClose ? (brkDn[1] and srcPrice >= loOut) : brkDn

// ───────────────────────── DIVERGENCE (price vs oscillator) ─────────────────
float rsiV   = ta.rsi(srcPrice, rsiLen)
float zDev   = dev / nz(sig, 1.0)                    // band-native normalized deviation
float oscDiv = divSrcOpt == "RSI" ? rsiV : zDev
float phv = ta.pivothigh(oscDiv, pvL, pvR)
float plv = ta.pivotlow(oscDiv, pvL, pvR)
var float lpH = na
var float ppH = na
var float lpHp = na
var float ppHp = na
var int   lpHx = na
var int   ppHx = na
if not na(phv)
    ppH  := lpH
    ppHp := lpHp
    ppHx := lpHx
    lpH  := phv
    lpHp := srcPrice[pvR]
    lpHx := bar_index - pvR
var float lpL = na
var float ppL = na
var float lpLp = na
var float ppLp = na
var int   lpLx = na
var int   ppLx = na
if not na(plv)
    ppL  := lpL
    ppLp := lpLp
    ppLx := lpLx
    lpL  := plv
    lpLp := srcPrice[pvR]
    lpLx := bar_index - pvR
bool bearDiv = showDiv and not na(ppH) and not na(phv) and lpHp > ppHp and lpH < ppH
bool bullDiv = showDiv and not na(ppL) and not na(plv) and lpLp < ppLp and lpL > ppL
int  divDir  = bullDiv ? 1 : bearDiv ? -1 : 0

// ───────────────────────── PLOTS (price overlay) ────────────────────────────
color basisCol = tintBasis ? (srcPrice >= centre ? color.new(COL_BULL, 0) : color.new(COL_BEAR, 0)) : color.new(COL_INFO, 0)
plot(centre, "Centre", color = basisCol, linewidth = 2)
pUpIn  = plot(upIn,  "Band Upper Inner", color = color.new(COL_MID, 40))
pLoIn  = plot(loIn,  "Band Lower Inner", color = color.new(COL_MID, 40))
pUpOut = plot(upOut, "Band Upper Outer", color = color.new(COL_BEAR, 20))
pLoOut = plot(loOut, "Band Lower Outer", color = color.new(COL_BULL, 20))
fill(pUpIn,  pLoIn,  color = showFill ? color.new(COL_INFO, 92) : na, title = "Inner fill")
fill(pUpOut, pUpIn,  color = showFill ? color.new(COL_BEAR, 90) : na, title = "Upper outer fill")
fill(pLoIn,  pLoOut, color = showFill ? color.new(COL_BULL, 90) : na, title = "Lower outer fill")

plotshape(showBreak and fadeShort, "Fade short", style = shape.triangledown, location = location.abovebar, color = COL_BEAR, size = size.tiny)
plotshape(showBreak and fadeLong,  "Fade long",  style = shape.triangleup,   location = location.belowbar, color = COL_BULL, size = size.tiny)

// divergence lines on price (kept history, capped at divKeep)
var array<line>  divLines  = array.new<line>()
var array<label> divLabels = array.new<label>()
if bearDiv and not na(ppHx)
    array.push(divLines,  line.new(ppHx, ppHp, lpHx, lpHp, xloc.bar_index, color = color.new(COL_BEAR, 0), width = 2))
    array.push(divLabels, label.new(lpHx, lpHp, "Bear", style = label.style_label_down, color = color.new(COL_BEAR, 15), textcolor = color.white, size = size.tiny))
if bullDiv and not na(ppLx)
    array.push(divLines,  line.new(ppLx, ppLp, lpLx, lpLp, xloc.bar_index, color = color.new(COL_BULL, 0), width = 2))
    array.push(divLabels, label.new(lpLx, lpLp, "Bull", style = label.style_label_up, color = color.new(COL_BULL, 15), textcolor = color.white, size = size.tiny))
while array.size(divLines) > divKeep
    line.delete(array.shift(divLines))
    label.delete(array.shift(divLabels))

// ───────────────────────── DASHBOARD (institution, adaptive) ─────────────────
f_setRow(table t, int r, string lbl, string val, color vc, color lc, color bg) =>
    table.cell(t, 0, r, lbl, text_color = lc, text_size = size.tiny,  text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, val, text_color = vc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

float posInBand = (seeded and not na(upOut) and (upOut - loOut) != 0) ? (srcPrice - loOut) / (upOut - loOut) * 100.0 : na
bool  calibrated = warm and not na(covRealIn) and not na(covRealOut) and math.abs(covRealIn - covIn) <= 0.05 and math.abs(covRealOut - covOut) <= 0.05
string statusTxt = not warm ? "WARMING" : calibrated ? "CALIBRATED" : "ADAPTING"
string methodTxt = "Vol-norm" + (normOn ? "" : " off") + (useIntg ? " · PI" : " · P") + (decayOn ? " · decay" : "")
string divTxt    = divDir > 0 ? "BULL" : divDir < 0 ? "BEAR" : "none"
string sigTxt    = fadeLong ? "FADE LONG" : fadeShort ? "FADE SHORT" : brkUp ? "outside upper" : brkDn ? "outside lower" : "inside bands"

var table dash = na
if showDash and barstate.islast
    color statusBg = not warm ? color.new(cWarn, 0) : calibrated ? color.new(cBull, 0) : color.new(cInfo, 0)
    color divCol   = divDir > 0 ? cBull : divDir < 0 ? cBear : cMute
    color sigCol   = fadeLong ? cBull : fadeShort ? cBear : cMute
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, compactTbl ? 5 : 12, border_width = 1, frame_color = frameCl, frame_width = 1)
    table.set_frame_color(dash, frameCl)
    table.set_border_color(dash, frameCl)
    table.cell(dash, 0, 0, " CONFORMAL BANDS", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = statusBg, tooltip = "Self-calibrating bands. Coverage rows show target and realised %; when they match, a band breach is a genuinely rare, calibrated event. Descriptive of the past on this chart, not a profit claim.")
    table.cell(dash, 1, 0, statusTxt + " ", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = statusBg)
    // coverage rows (color logic in global scope, not inside a UDF)
    string inVt  = not warm or na(covRealIn)  ? "warming" : str.tostring(math.round(covIn*100))  + " → " + str.tostring(math.round(covRealIn*100))  + "%"
    float  inD   = na(covRealIn)  ? na : math.abs(covRealIn - covIn)
    color  inC   = not warm or na(inD)  ? cMute : inD  <= 0.03 ? cBull : inD  <= 0.06 ? cInfo : cWarn
    string inFit = not warm or na(inD)  ? "" : inD  <= 0.03 ? "  ✓" : inD  <= 0.06 ? "  ~" : "  ⟳"
    f_setRow(dash, 1, "INNER BAND", inVt + inFit, inC, tLbl, zebraA)
    string ouVt  = not warm or na(covRealOut) ? "warming" : str.tostring(math.round(covOut*100)) + " → " + str.tostring(math.round(covRealOut*100)) + "%"
    float  ouD   = na(covRealOut) ? na : math.abs(covRealOut - covOut)
    color  ouC   = not warm or na(ouD) ? cMute : ouD <= 0.03 ? cBull : ouD <= 0.06 ? cInfo : cWarn
    string ouFit = not warm or na(ouD) ? "" : ouD <= 0.03 ? "  ✓" : ouD <= 0.06 ? "  ~" : "  ⟳"
    f_setRow(dash, 2, "OUTER BAND", ouVt + ouFit, ouC, tLbl, zebraB)
    if compactTbl
        f_setRow(dash, 3, "CENTRE", centreUsed + " · N" + str.tostring(nCov), tVal, tLbl, zebraA)
        f_setRow(dash, 4, "METHOD", methodTxt, tVal, tLbl, zebraB)
    else
        f_setRow(dash, 3, "CENTRE",     centreUsed, tVal, tLbl, zebraA)
        f_setRow(dash, 4, "LOCAL VOL",  str.tostring(sig, format.mintick), tVal, tLbl, zebraB)
        f_setRow(dash, 5, "STRETCH",    (zDev >= 0 ? "+" : "") + str.tostring(zDev, "0.00") + "σ", math.abs(zDev) >= 2 ? cWarn : tVal, tLbl, zebraA)
        f_setRow(dash, 6, "POSITION",   na(posInBand) ? "-" : str.tostring(math.round(posInBand)) + "% of band", tVal, tLbl, zebraB)
        f_setRow(dash, 7, "METHOD",     methodTxt, tVal, tLbl, zebraA)
        f_setRow(dash, 8, "SAMPLES",    str.tostring(nCov) + " / " + str.tostring(covWin), tVal, tLbl, zebraB)
        f_setRow(dash, 9, "DIVERGENCE", divTxt + " (" + (divSrcOpt == "RSI" ? "RSI" : "band") + ")", divCol, tLbl, zebraA)
        color bwCol = bwState == "SQUEEZE" ? cInfo : bwState == "EXPANDED" ? cWarn : tVal
        f_setRow(dash, 10, "COMPRESSION", na(bwPct) ? "-" : "p" + str.tostring(math.round(bwPct)) + " · " + bwState, bwCol, tLbl, zebraB)
        f_setRow(dash, 11,"SIGNAL",     sigTxt, sigCol, tLbl, zebraA)

// identity label
var table idTbl = na
if showId and barstate.islast
    if na(idTbl)
        idTbl := table.new(position.bottom_center, 1, 1)
    table.cell(idTbl, 0, 0, "Conformal Bands  ·  " + syminfo.ticker + "  " + timeframe.period, text_color = color.new(tLbl, 15), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────── EXPORTS ──────────────────────────────────────────
plot(centre, "EXP_CentreLine",       display = display.data_window)
plot(upIn,   "EXP_UpperInner",       display = display.data_window)
plot(loIn,   "EXP_LowerInner",       display = display.data_window)
plot(upOut,  "EXP_UpperOuter",       display = display.data_window)
plot(loOut,  "EXP_LowerOuter",       display = display.data_window)
plot(seeded ? upOut - centre : na, "EXP_OuterHalfWidth",  display = display.data_window)
plot(covRealOut, "EXP_CoverageOuter", display = display.data_window)
plot(covRealIn,  "EXP_CoverageInner", display = display.data_window)
plot(bwPct,      "EXP_BandWidthPercentile", display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(fadeLong,  "Fade long (outer breach below)",  "Conformal Bands: price below outer band — rare downside excursion")
alertcondition(fadeShort, "Fade short (outer breach above)", "Conformal Bands: price above outer band — rare upside excursion")
````
