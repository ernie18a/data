# Absorption Shelf  Dwell-Coil Reversal Levels

- url: https://www.tradingview.com/script/HWn4gTdW-Absorption-Shelf-Dwell-Coil-Reversal-Levels/
- type: indicator
- pine_id: PUB;44d3c6bcad6b4364ad9d0dbe435d566b
- version: 2.0

## Description

█ OVERVIEW

Absorption Shelf finds reversal LEVELS the opposite way round from a pivot or a profile POC: it starts from TIME. A price band becomes a "shelf" because price DWELT there — an anomalous amount of occupation time — while its range COILED (volatility compressed). Only then do orthogonal order-flow lenses CONFIRM whether that shelf is genuinely ABSORBING flow rather than merely balancing, and a confirmed close back out of the band is treated as the reversal. It asserts no signal and no win-rate; it shows, honestly and past-only, how often price has actually rejected off these shelves versus a matched base rate.

█ HOW IT WORKS

Substrate — one lower-timeframe stream (request.security_lower_tf) supplies a per-bar buy/sell split (BVC-Normal / Tick / Geometry) for delta and signed order flow; it falls back to the chart bar when no intrabar data exists. The method in force is shown (REAL / EST).
Dwell field (the level generator) — a rolling, fixed-tick OCCUPATION-TIME map: each confirmed bar adds time to every price level its range covers, and the bar leaving the window subtracts it exactly (a reversible ring buffer). Levels at or above a self-set percentile κ are "hot"; adjacent hot levels merge into candidate BANDS.
Coil + containment (the stall trigger) — a band is promoted to an ACTIVE shelf only when compression (1 − ATRfast/ATRslow) clears a threshold AND enough recent closes sat inside the band. Dwell + coil together are what make a quiet band a shelf — this is the part a pivot- or profile-based level does not have.
Confirmation lenses (on the band only) — Effort-vs-Result √-law residual (E: heavy volume, little price result = absorption), localized Kyle-λ collapse (K: price barely moves per unit signed flow), Dwell-decay (D: the band has stopped accreting time = primed to release), Rejection-wick clustering (W: Wilson-floored), and CVD divergence (V). Each abstains cleanly on missing data.
Fusion — the active lenses combine by correlation-aware Bayesian log-odds: each is reliability-shrunk by its own past edge and Kish-decorrelated so the absorption family (E, K, D) contributes about one lens' worth, not three, then squashed to P_abs → BALANCE / ABSORBING / PRIMED. Shelves are down-weighted in strong trend (a built-in efficiency-ratio regime gauge, or a consumed external one).
Flip + lifecycle — a confirmed close out of the band against the approach is the reversal (a ▲ bullish or ▼ bearish flip, coloured by direction). Shelves carry a lifecycle: forming → active → flipped → spent → naked (kept until retested).
Reject calibration (honesty layer) — when price first touches an active shelf, the script forward-tests whether it REJECTS (turns back by k·ATR) BEFORE it CONTINUES through by k·ATR, versus the matched unconditional reject-vs-continue base rate: reject% (n, Wilson 95% lower bound) vs base% → edge, broken out by tag (does PRIMED out-reject ABSORBING out-reject BALANCE?), split in-sample / out-of-sample, and Bonferroni-deflated. Past-only, non-repaint.

█ HOW TO USE

Read the shelves as context, not as entries. A teal band below price is a support shelf (price is being held from below); a red band above is a resistance shelf. Brightness tracks how strongly the band was dwelt. The tag tells you what the flow says about it — BALANCE is just a quiet level, ABSORBING and PRIMED mean the lenses agree a wall is soaking flow there. A ▲/▼ flip marks where price actually closed back out of a shelf against its approach. The calibration line is the honest part: it tells you, on this symbol and timeframe, how often tagging a shelf has preceded a real rejection versus random — and shows nothing when the sample is small. A flat read with no active shelf is a genuine "no location here", not a broken one. The dashboard defaults to Compact (shelf, tag, dwell %, flip); switch it to Pro for the lens-by-lens glyphs and the calibration breakout. Horizon and holding are yours to decide; it emits no orders.

█ INPUTS

01 · Data & Trade-Side — LTF granularity, classifier, BVC sharpness.
02 · Dwell Field — ticks-per-level, dwell window, hot-level percentile κ, band merge gap, min band width.
03 · Coil & Stall — fast/slow ATR, minimum coil to promote, containment lookback / fraction / buffer.
04 · Confirmation Lenses — enable E / K / D / W / V and their sensitivities.
05 · Fusion — Kish decorrelation, self-set tag percentiles (absorbing / primed).
06 · Flip & Lifecycle — flip distance (×ATR), ghost retention, max shelves tracked.
07 · Regime & Self-Cal — trend down-weight (built-in efficiency ratio, or consume an external regime).
08 · Calibration — reject size (×ATR), horizon, Bonferroni, in/out-of-sample split.
09 · Microstructure Links (optional) — consume external Toxicity or Kyle λ; never recomputed.
10 · Display — bands, how far back to draw, badge, lens glyphs, flip markers, naked shelves, dwell heat spine, dashboard detail (Compact default / Pro).
11 · Style — Auto / Dark / Light theme.
12 · Exports — shelf levels, tag, P_abs, dwell percentile, coil, flip direction, naked levels, reject edge, active lenses.

█ HONESTY & LIMITATIONS

Descriptive, not predictive. Order-flow side is an OHLCV ESTIMATE (BVC / tick / geometry), not a Level-2 book; on symbols with no volume the flow lenses (E, K, V) abstain and the shelf runs on dwell + coil + wick alone, stated in the dashboard. Coil is measured chart-wide (ATR ratio) while containment is per band. The reject calibration is a past-only, first-touch two-barrier (reject-vs-continue) forward test against a matched base rate with a Wilson lower bound, tag buckets, an in/out-of-sample split and a Bonferroni deflation; a small sample is discounted automatically and no edge shown means honest, not broken. Non-repaint by construction: dwell and coil accrue on confirmed bars, shelves promote from confirmed history, the flip fires on a confirmed close, calibration events resolve only after the horizon, and the render recomputes once per confirmed bar. For runtime the script processes the most recent ~5000 bars and gates the calibration engine behind its own toggle. It prints no verdict and no win-rate.

█ ORIGINALITY

One coherent object: a reversal level whose EXISTENCE comes from occupation time plus volatility compression, with order flow demoted to confirmation on that band. This is deliberately distinct from a volume/footprint profile (those build the level from volume-at-price and fire sweeps event-by-event), from pivot- or kernel-based support/resistance (those build the level from swing geometry), and from a potential-well or mean-reversion model (those are price-dynamics with no time-at-price). The dwell-time + coil "absorption shelf" as the level generator, the dwell-decay lens that only this occupation field makes possible, and the correlation-aware fusion that explicitly discounts absorption-lens redundancy are the specific original contributions. Every block was written from scratch for this tool; the lenses feed one decision (is this band absorbing?) rather than being independent indicators stapled together.

█ CREDITS

Occupation-time / TPO at price — Steidlmayer / Market Profile. Price-impact λ (delta-response) — Kyle (1985). Square-root market-impact law — Almgren; Tóth, Bouchaud et al. Bulk Volume Classification — Easley, López de Prado & O'Hara. Trade-side tick rule — Lee & Ready (1991). Two-barrier / triple-barrier forward test — López de Prado. Wilson score interval — Wilson (1927). Design-effect / effective sample — Kish (1965). Code written from scratch; no external script reused.

This script is for analysis and education. It is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// =============================================================================
//  © Market_Logic_India                                          MPL-2.0 · v1.1
//  Absorption Shelf — Dwell-Coil Reversal Levels,
//  Order-Flow Confirmed                                          Pine Script v6
//  shorttitle: ABS-SHELF
// -----------------------------------------------------------------------------
//  CHANGELOG
//    v1.1 — VSA bar-event confluence (optional, default ON; additive — the dwell-coil
//      engine, the five fusion lenses and the calibration harness are byte-for-byte v1.0):
//      • Named Wyckoff / effort-vs-result bar events marked on the chart — Upthrust,
//        Shakeout, Stopping Volume, Buying/Selling Climax, and (opt-in) No-Demand/
//        No-Supply. They pair with the shelves: an Upthrust into a resistance shelf, or
//        Stopping Volume on a support shelf, is strong confluence for the flip. Markers
//        use plotshape only — the label/box pools the shelf bands use are untouched.
//      • Optional TIME-OF-DAY volume baseline: judges the VSA volume reads against the
//        same wall-clock slot on prior sessions, so a normal-for-the-open bar is not a
//        false climax and a heavy-for-lunch bar is caught (default OFF; state-safe, no ta.*).
//      • New export EXP_VSABias (+1 bullish / −1 bearish / 0) and alerts for the trap /
//        stopping / climax events. Toggle the whole layer off in group 13.
// -----------------------------------------------------------------------------
//  WHAT IT IS
//    A reversal-LEVEL detector built the other way round from the rest of the
//    library. It does NOT start from a pivot, a POC or a kernel. It starts from
//    TIME: a price BAND becomes a "shelf" because price DWELT there (anomalous
//    occupation time) while its range COILED (volatility compressed). Only THEN
//    do orthogonal order-flow lenses CONFIRM whether that shelf is genuinely
//    ABSORBING (a wall soaking flow) rather than merely balancing — and a close
//    back out of the band is treated as the reversal.
//
//  WHY THIS IS A NEW OBJECT (not a duplicate of the level / order-flow suite)
//    • Order-Flow Profile already fuses absorption / Kyle-λ / CVD-divergence /
//      rejection wicks / Hawkes into event-by-event SWEEPS at profile & pivot
//      bins. This tool does NOT headline flow fusion — it demotes the flow
//      lenses to CONFIRMATION on a band it located from dwell + coil FIRST.
//    • S/R Confluence and Fractal Swing Levels already draw levels and calibrate
//      a hold/respect rate — but they build the level from pivots / kernels /
//      HTF. NEITHER builds the level from OCCUPATION TIME + volatility COIL.
//    That occupation-time-defined, coil-triggered "absorption shelf" — where the
//    level EXISTS because of dwell + compression — is the coherent, uncovered
//    core. Flow only says whether the shelf is absorbing or just quiet.
//
//  HOW IT WORKS
//    L0  Substrate   : request.security_lower_tf → intrabar OHLCV for a per-bar
//                      delta (BVC-Normal / Tick / Geometry); chart-bar fallback.
//    L1  Dwell field : a rolling, fixed-tick OCCUPATION-TIME map (TPO-time
//                      generalised to a windowed field). Hot levels (≥ percentile
//                      κ of the field) merge into candidate BANDS.  ★ the level.
//    L2  Coil        : range compression (ATR-fast/slow) + containment; a band is
//                      promoted to an ACTIVE shelf only when dwell-hot AND coiled.
//    L3  Lenses      : on the band only — Effort-vs-Result √-law residual (E),
//                      localized Kyle-λ collapse (K), dwell-decay (D), rejection-
//                      wick clustering (W), CVD divergence (V). Each abstains on
//                      missing data; "+" means "supports a reversal off the band".
//    L4  Fusion      : correlation-aware Bayesian log-odds — reliability-shrunk
//                      per lens, Kish-decorrelated (absorption lenses are not
//                      independent), squashed to P_abs → BALANCE/ABSORBING/PRIMED.
//    L5  Flip        : a confirmed close out of the band against the approach is
//                      the reversal; shelves carry a lifecycle (forming→active→
//                      flipped→spent→ghost).
//    L6  Regime      : self-calibrating percentile thresholds; absorption shelves
//                      down-weighted in strong trend (built-in, or consume EXP_).
//    L7  Calibration : first-touch REJECT-vs-CONTINUE two-barrier race on active
//                      shelves vs a matched base rate — reject% (n, Wilson LB) vs
//                      base% → edge, bucketed by tag, IS/OOS split, Bonferroni.
//
//  HONESTY / NON-REPAINT
//    A study, not a signal. It asserts NO buy/sell and NO win-rate. Order-flow
//    side from OHLCV is an ESTIMATE (method shown; lenses abstain on no-volume).
//    Everything accrues on confirmed bars; shelves are drawn from confirmed
//    history; the flip fires on a confirmed close; calibration events resolve
//    only after their horizon; the render recomputes once per confirmed bar. No
//    request.security lookahead; no dynamic-length ta().
//
//  EXPORTS (Data Window) — consume via input.source():
//    EXP_ShelfHi · EXP_ShelfLo · EXP_ShelfMid · EXP_ShelfTag · EXP_ShelfPabs ·
//    EXP_DwellPctile · EXP_Coil · EXP_FlipDir · EXP_NakedShelfAbove ·
//    EXP_NakedShelfBelow · EXP_RejectEdge · EXP_ActiveLenses
//
//  CONCEPT CREDITS (methods operationalised — original Pine, no script reused)
//    Occupation-time / TPO at price ................ Steidlmayer / Market Profile
//    Price-impact λ (delta-response) ............... Kyle (1985)
//    √-law market impact ........................... Almgren; Tóth-Bouchaud et al.
//    Bulk Volume Classification (BVC) .............. Easley, López de Prado & O'Hara
//    Trade-side tick rule .......................... Lee & Ready (1991)
//    Two-barrier / triple-barrier forward test ..... López de Prado
//    Wilson score interval ......................... Wilson (1927)
//    Design-effect / effective sample .............. Kish (1965)
//
//  DISCLOSURE / HONESTY (house-standard block — keep in every script)
//    This is a study/indicator for analysis and education. It is NOT a strategy,
//    NOT a signal service, and NOT financial advice. Any figure shown is
//    descriptive statistics on visible history — not a backtest, not a promise.
//    When a measured edge is absent, the script shows that plainly.
// =============================================================================

//@version=6
indicator("Absorption Shelf — Dwell-Coil Reversal Levels, Order-Flow Confirmed", "ABS-SHELF",
     overlay          = true,
     max_lines_count  = 300,
     max_labels_count = 500,
     max_boxes_count  = 500,
     max_bars_back    = 500,
     calc_bars_count  = 5000)

// =============================================================================
// HELPERS  (UDFs use their args + built-ins only, never globals — house rule)
// =============================================================================
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))

f_tanh(float x) =>
    xx = f_clamp(x, -20.0, 20.0)
    e  = math.exp(2.0 * xx)
    (e - 1.0) / (e + 1.0)

f_erf(x) =>
    t = 1.0 / (1.0 + 0.3275911 * math.abs(x))
    y = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * math.exp(-x * x)
    x >= 0 ? y : -y

f_ncdf(z) => 0.5 * (1.0 + f_erf(z / math.sqrt(2.0)))

// Wilson score lower bound at confidence z for w wins in n trials; na if n=0.
// (z=1.959964 → 95%. A larger z is passed for a Bonferroni-deflated bound.)
f_wilsonLBz(int w, int n, float z) =>
    float res = na
    if n > 0
        p  = w / float(n)
        z2 = z * z
        res := (p + z2 / (2.0 * n) - z * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / (1.0 + z2 / n)
    res

// Nearest-rank percentile of a copied+sorted array; na if empty.
f_pctile(array<float> src, float p) =>
    n = src.size()
    float res = na
    if n > 0
        c = src.copy()
        c.sort()
        res := c.get(math.max(0, math.min(n - 1, int(math.floor(p / 100.0 * (n - 1))))))
    res

f_luma(color c)  => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_pos(string s)  => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right
f_bin(float price, float binTick) => int(math.floor(price / binTick))
f_buyFrac(string mode, float o, float h, float l, float c, float sharp) =>
    rng = math.max(h - l, syminfo.mintick)
    z   = (c - o) / rng * sharp
    float bf = mode == "Tick" ? (c > o ? 1.0 : c < o ? 0.0 : 0.5) : mode == "Geometry" ? (c - l) / rng : f_ncdf(z)
    f_clamp(bf, 0.0, 1.0)

// Lens-mask bit tests (Pine has no bitwise ops — decode by division/modulo).
// mask = E·1 + K·2 + D·4 + W·8 + V·16
f_hasE(int m) => m % 2 == 1
f_hasK(int m) => int(math.floor(m / 2))  % 2 == 1
f_hasD(int m) => int(math.floor(m / 4))  % 2 == 1
f_hasW(int m) => int(math.floor(m / 8))  % 2 == 1
f_hasV(int m) => int(math.floor(m / 16)) % 2 == 1

// =============================================================================
// TYPES
// =============================================================================
// One persistent shelf. Bands are matched to shelves across bars so the shelf
// carries a lifecycle and per-band lens accumulators (updated while price is on
// the band). Drawing objects are NOT stored here — they live in render pools.
type Shelf
    float lo             = na       // band low  price
    float hi             = na       // band high price
    float anchor         = na       // dwell-weighted centroid
    float dwell          = 0.0      // occupation mass of the band (field units)
    float dwellPct       = 0.0      // percentile rank of that mass (0..100)
    float coil           = 0.0      // 0..1 compression at promotion
    int   birth          = 0
    int   lastSeen       = 0
    int   state          = 0        // 0 forming · 1 active · 2 flipped · 3 spent
    int   role           = 0        // +1 support (below px) · -1 resistance (above)
    int   appr           = 0        // approach at first touch: +1 tested as support · -1 as resistance
    int   miss           = 0        // consecutive bars the band was not re-found
    // lens accumulators (per current on-band episode)
    float effV           = 0.0      // effort  = volume transacted on band
    float resSum         = 0.0      // |displacement| produced while on band
    float entryPx        = na
    float sumPD          = 0.0      // Σ (Δprice · OFI)   — for local Kyle λ
    float sumO2          = 0.0      // Σ (OFI²)
    int   touches        = 0
    int   rejects        = 0
    float cvdRef         = na       // CVD at episode entry
    float pxExtreme      = na       // extreme reached into the band
    int   onBars         = 0
    float dwellPrev      = na       // for dwell-decay slope
    float dwellGrow      = 0.0      // EMA of per-update dwell increments
    // fused lens scores + verdict
    float sE             = 0.0
    float sK             = 0.0
    float sD             = 0.0
    float sW             = 0.0
    float sV             = 0.0
    int   lensMask       = 0        // which lenses contributed (E1 K2 D4 W8 V16)
    float pabs           = 0.5
    int   tag            = 0        // 0 balance · 1 absorbing · 2 primed
    bool  evOpen         = false    // a calibration event is live for this shelf
    int   flipDir        = 0        // last flip direction (+1 up · -1 down)

// =============================================================================
// INPUTS
// =============================================================================
gData = "01 · Data & Trade-Side"
gDwl  = "02 · Dwell Field"
gCoil = "03 · Coil & Stall"
gLens = "04 · Confirmation Lenses"
gFus  = "05 · Fusion"
gFlip = "06 · Flip & Lifecycle"
gReg  = "07 · Regime & Self-Cal"
gCal  = "08 · Calibration"
gLink = "09 · Microstructure Links (optional)"
gDisp = "10 · Display"
gStyle= "11 · Style"
gExp  = "12 · Exports"

ltfMode  = input.string("Auto", "Lower-Timeframe Granularity", options = ["Auto", "1S", "1", "3", "5", "15"], group = gData, tooltip = "Intrabar resolution for the per-bar delta. Auto scales to the chart timeframe. The dwell field itself runs on chart bars — this only sharpens the flow lenses.")
sideMode = input.string("BVC-Normal", "Trade-Side Classifier", options = ["BVC-Normal", "Tick", "Geometry"], group = gData, tooltip = "How each (intra)bar is split buy vs sell for delta / OFI. BVC-Normal = normal-CDF of the standardized return (default). Tick = sign(close-open). Geometry = close position in range. All are OHLCV ESTIMATES, not the true tape.")
bvcSharp = input.float(1.0, "BVC Sharpness", minval = 0.3, maxval = 4.0, step = 0.1, group = gData, active = sideMode == "BVC-Normal")

fineTk   = input.int(8, "Ticks per Price Level", minval = 1, maxval = 200, group = gDwl, tooltip = "Fixed-tick grid = mintick × this. Larger = coarser bands, fewer levels, lighter.")
dwlWin   = input.int(300, "Dwell Window (bars)", minval = 40, maxval = 2000, group = gDwl, tooltip = "Rolling lookback over which occupation time is accumulated. Contributions older than this are removed exactly (reversible ring buffer).")
dwlPct   = input.float(90, "Hot-Level Percentile κ", minval = 60, maxval = 99, step = 1, group = gDwl, tooltip = "A level is 'hot' (part of a shelf) when its occupation time is at or above this percentile of the whole field. Higher = fewer, stronger shelves.")
mergeGap = input.int(2, "Merge Gap (levels)", minval = 0, maxval = 10, group = gDwl, tooltip = "Adjacent hot levels within this gap are merged into one band.")
minBandW = input.int(1, "Min Band Width (levels)", minval = 1, maxval = 20, group = gDwl)

atrFast  = input.int(10, "Coil ATR — fast", minval = 2, maxval = 50, group = gCoil)
atrSlow  = input.int(50, "Coil ATR — slow", minval = 10, maxval = 300, group = gCoil)
coilMin  = input.float(0.15, "Min Coil to Promote", minval = 0.0, maxval = 0.9, step = 0.05, group = gCoil, tooltip = "coil = 1 − ATRfast/ATRslow. A band is only promoted to an ACTIVE shelf when compression is at least this. 0 = accept any.")
contM    = input.int(20, "Containment Lookback (bars)", minval = 5, maxval = 100, group = gCoil)
contFrac = input.float(0.6, "Min Containment Fraction", minval = 0.2, maxval = 1.0, step = 0.05, group = gCoil, tooltip = "Fraction of the last N closes that must sit within the band (± buffer) for it to count as a genuine shelf, not a fly-through.")
contBuf  = input.float(0.5, "Containment Buffer (×ATR)", minval = 0.0, maxval = 3.0, step = 0.25, group = gCoil)

useE = input.bool(true,  "Effort-vs-Result residual (E)", group = gLens, tooltip = "√-law absorption: heavy volume on the band producing little price result.")
useK = input.bool(true,  "Kyle-λ collapse (K)", group = gLens, tooltip = "Local price-impact slope on the band far below ambient = a wall absorbing signed flow.")
useD = input.bool(true,  "Dwell-decay (D)", group = gLens, tooltip = "The band has stopped accreting time while price is still on it = primed to release. Free — reuses the field.")
useW = input.bool(true,  "Rejection-wick cluster (W)", group = gLens, tooltip = "Clustered rejection wicks against the approach, Wilson-floored.")
useV = input.bool(false, "CVD divergence (V)", group = gLens, tooltip = "Price makes a fresh band extreme while cumulative delta fails to confirm. Opt-in (needs volume).")
lamE = input.float(1.0, "  E sensitivity", minval = 0.2, maxval = 4.0, step = 0.1, group = gLens, active = useE)
lamK = input.float(1.0, "  K sensitivity", minval = 0.2, maxval = 4.0, step = 0.1, group = gLens, active = useK)
lamD = input.float(1.0, "  D sensitivity", minval = 0.2, maxval = 4.0, step = 0.1, group = gLens, active = useD)
wickR = input.float(1.0, "  Wick/Body ratio", minval = 0.3, maxval = 5.0, step = 0.1, group = gLens, active = useW)
wickA = input.float(0.25,"  Min Wick (×ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = gLens, active = useW)

useKish  = input.bool(true, "Kish decorrelation (redundant lenses)", group = gFus, tooltip = "Absorption lenses (E,K,D) are not independent. The correlation-aware weight discounts a redundant pack so it contributes ~one lens' worth, not five.")
tagP1    = input.float(60, "Absorbing tag percentile", minval = 40, maxval = 90, step = 5, group = gFus, tooltip = "Self-set on the rolling distribution of P_abs. Above this = ABSORBING.")
tagP2    = input.float(85, "Primed tag percentile", minval = 60, maxval = 99, step = 1, group = gFus, tooltip = "Above this (and coiled, dwell plateauing) = PRIMED.")

flipK    = input.float(0.5, "Flip distance (×ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gFlip, tooltip = "A confirmed close this far OUT of the band against the approach = the reversal (flip).")
ghostKeep= input.int(200, "Ghost retention (bars)", minval = 20, maxval = 1000, group = gFlip, tooltip = "How long a spent / untested shelf is kept as a naked (dashed) level before it is dropped.")
maxTrack = input.int(30, "Max shelves tracked", minval = 6, maxval = 60, group = gFlip)

useReg   = input.bool(true, "Down-weight shelves in strong trend", group = gReg, tooltip = "Absorption shelves matter most in balance/chop. A built-in efficiency-ratio trend gauge shrinks P_abs in strong trend. Turn off to treat all regimes equally.")
regLen   = input.int(20, "Regime efficiency length", minval = 5, maxval = 100, group = gReg, active = useReg)
useRegExt= input.bool(false, "Consume external regime instead", inline = "rg", group = gReg)
srcReg   = input.source(close, "src", inline = "rg", group = gReg, tooltip = "Map a suite EXP_REGIME here (higher = more trending). Overrides the built-in gauge when enabled.")

showCalib= input.bool(true, "Show reject calibration", group = gCal, tooltip = "When price first touches an ACTIVE shelf, does it REJECT (turn back against the approach by k·ATR) BEFORE CONTINUING through by k·ATR — vs the matched unconditional reject-vs-continue base rate? Past-only, Wilson-bounded, non-repaint. No edge shown = honest, not broken.")
calK     = input.float(1.0, "Reject size (×ATR)", minval = 0.25, maxval = 5.0, step = 0.25, group = gCal)
calH     = input.int(20, "Reject horizon (bars)", minval = 3, maxval = 200, group = gCal)
calBonf  = input.bool(true, "Bonferroni-deflate the Wilson bound", group = gCal, tooltip = "Widen the confidence for the number of tag buckets tested, so multiple-comparison inflation is discounted.")
showOOS  = input.bool(true, "Split in-sample / out-of-sample", group = gCal, tooltip = "The earlier half self-sets thresholds; the later half is reported separately as out-of-sample.")

useTox   = input.bool(false, "Annotate flow quality from Toxicity", inline = "t", group = gLink)
srcTox   = input.source(close, "src", inline = "t", group = gLink, tooltip = "Map your VPIN engine's EXP_Toxicity here (0..1). Annotates only; never recomputed.")
useKyleX = input.bool(false, "Use external Kyle λ for lens K", inline = "k", group = gLink)
srcKyle  = input.source(close, "src", inline = "k", group = gLink, tooltip = "Map Order-Flow Profile's EXP_Kyle here to avoid re-deriving it.")

showBands= input.bool(true, "Show shelf bands", group = gDisp)
maxShow  = input.int(6, "Max shelves shown", minval = 1, maxval = 20, group = gDisp, tooltip = "Only the top shelves by fused conviction are drawn, so price never clutters.")
dispLook = input.int(2000, "Draw shelves back to (bars)", minval = 100, maxval = 5000, group = gDisp, tooltip = "How far back a shelf band is drawn from its birth bar, so you can see where past shelves formed and how price reacted.")
showBadge= input.bool(true, "Badge (tag + reject%)", group = gDisp)
showGlyph= input.bool(true, "Lens glyphs on badge (Pro)", group = gDisp)
showFlip = input.bool(true, "Flip markers", group = gDisp)
showGhost= input.bool(true, "Naked (ghost) shelves", group = gDisp)
showHeat = input.bool(false, "Dwell heat spine (left margin)", group = gDisp)
showDash = input.bool(true, "Show Dashboard", group = gDisp)
dashMode = input.string("Compact", "Dashboard Detail", options = ["Compact", "Pro"], group = gDisp)
dashPosIn= input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDisp)

// ── Style (HOUSE STANDARD palette — verbatim) ──
themeOpt = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = gStyle)
isLight  = themeOpt == "Auto" ? f_luma(chart.bg_color) > 128 : themeOpt == "Light"
C_UP     = #26a69a
C_DN     = #ef5350
C_BULL   = #26a69a
C_BEAR   = #ef5350
C_MACD   = #2962ff
C_SIGNAL = #ff6d00
C_POS    = #1b5e20
C_NEG    = #7f1d1d
C_TEXT   = isLight ? color.new(#111318, 0) : color.new(#e8eaed, 0)
C_MUTED  = isLight ? color.new(#5f6368, 0) : color.new(#9aa0a6, 0)
C_BG     = isLight ? color.new(#ffffff, 8) : color.new(#0e1116, 10)
C_HEADER = color.new(#2962ff, 0)
C_GRID   = color.new(color.gray, 55)

expOn = input.bool(true, "Emit EXP_* exports", group = gExp)

// ── VSA bar events (Wave D · ml_vsa taxonomy, inlined) ──
gVsa    = "13 · VSA bar events (Wave D)"
vsaOn   = input.bool(true,  "Mark VSA bar events", group = gVsa, tooltip = "Named Wyckoff/VSA effort-vs-result events on each bar (Upthrust, Shakeout, Stopping Volume, Buying/Selling Climax). They pair with the shelves: an Upthrust into a resistance shelf, or Stopping Volume on a support shelf, is strong confluence for the flip. Purely additive — the shelf engine, fusion and calibration are unchanged.")
vsaMinor= input.bool(false, "Also mark No-Demand / No-Supply", group = gVsa, tooltip = "The low-volume 'no interest' events. Off by default — they are frequent and noisier than the trap/climax events.")
vsaLen  = input.int(50, "VSA history window", minval = 10, maxval = 300, group = gVsa, tooltip = "Bars over which each bar's spread and volume are percentile-ranked to decide 'wide/narrow' and 'high/low'.")
vsaPiv  = input.int(5,  "New-extreme lookback", minval = 2, maxval = 50, group = gVsa, tooltip = "A bar is a 'new high/low' for the trap events (Upthrust/Shakeout) if it exceeds the prior this-many bars.")
vsaTod  = input.bool(false, "Time-of-day volume (Wave D · U11)", group = gVsa, tooltip = "OFF: 'high volume' is judged against a flat rolling window (original). ON: judge volume against the SAME time-of-day slot on prior sessions — so a normal-for-the-open bar is not a false climax, and a genuinely heavy-for-lunch bar is caught. Uses the ml_session per-slot baseline (inlined). Default off.")
vsaTodMin = input.int(5,  "  Slot size (minutes)", minval = 1, maxval = 60, group = gVsa, tooltip = "Time-of-day bucket size for the volume baseline.")
vsaTodSes = input.int(20, "  Session memory", minval = 3, maxval = 200, group = gVsa, tooltip = "How many sessions of memory the per-slot volume baseline keeps.")

// =============================================================================
// L0 — SUBSTRATE + PER-BAR DELTA / OFI  (one LTF stream; chart-bar fallback)
// =============================================================================
ltf = switch ltfMode
    "Auto" => timeframe.isseconds ? "1S" : timeframe.isintraday ? (timeframe.multiplier >= 60 ? "5" : "1") : "60"
    => ltfMode

[aH, aL, aO, aC, aV] = request.security_lower_tf(syminfo.tickerid, ltf, [high, low, open, close, volume])

// Per-bar buy/sell/volume and signed order flow (OFI = buy − sell)
var float barBuy  = 0.0
var float barSell = 0.0
barBuy  := 0.0
barSell := 0.0
if aH.size() > 0
    for i = 0 to aH.size() - 1
        v  = nz(aV.get(i))
        bf = f_buyFrac(sideMode, aO.get(i), aH.get(i), aL.get(i), aC.get(i), bvcSharp)
        barBuy  += v * bf
        barSell += v * (1.0 - bf)
else
    // chart-bar fallback when no intrabar data is available
    v  = nz(volume)
    bf = f_buyFrac(sideMode, open, high, low, close, bvcSharp)
    barBuy  := v * bf
    barSell := v * (1.0 - bf)

barVol   = barBuy + barSell
barOFI   = barBuy - barSell                 // signed volume (order-flow imbalance)
hasVol   = barVol > 0
binTick  = math.max(syminfo.mintick, syminfo.mintick * fineTk)
atrC     = ta.atr(14)
atrCoil  = 1.0 - f_clamp(ta.atr(atrFast) / math.max(ta.atr(atrSlow), 1e-9), 0.0, 1.0)
// hoisted rolling normalizers (ta.* must be evaluated every bar, never inside loops)
avgVol50 = ta.sma(barVol, 50)
avgOFI50 = ta.sma(math.abs(barOFI), 50)

var float cvdCont = 0.0
if barstate.isconfirmed
    cvdCont := cvdCont + barOFI

// Ambient (global) Kyle λ — slow running slope of Δprice on signed flow.
var float ambPD = 0.0
var float ambO2 = 0.0
if barstate.isconfirmed
    dP = close - close[1]
    ambPD := ambPD * 0.995 + dP * barOFI
    ambO2 := ambO2 * 0.995 + barOFI * barOFI
lamAmbient = ambO2 > 1e-12 ? ambPD / ambO2 : na

// Built-in regime: Kaufman efficiency ratio (0 chop … 1 strong trend)
effNum = math.abs(close - close[regLen])
effDen = math.sum(math.abs(close - close[1]), regLen)
regBuiltin = f_clamp(effDen > 0 ? effNum / effDen : 0.0, 0.0, 1.0)
regime = useRegExt ? f_clamp(nz(srcReg), 0.0, 1.0) : regBuiltin

// =============================================================================
// VSA BAR EVENTS  (Wave D · U9 — ml_vsa effort-vs-result taxonomy, inlined)
//   Self-contained, non-repainting one-bar classifications. All ta.* here are
//   evaluated UNCONDITIONALLY (never inside a branch) so their state is clean.
//   Volume-dependent events fire only when the bar has real volume (hasVol).
// =============================================================================
// U11 (Wave D): optional time-of-day volume baseline (ml_session slotMean, inlined). Judges
// volume against the same wall-clock slot on prior sessions, so "heavy" means heavy FOR THIS TIME.
// State advances every bar (array EMA, no ta.*) so the baseline stays warm whether or not it's used.
int   vsaNSlots = math.max(1, int(math.ceil(1440.0 / math.max(vsaTodMin, 1))))
float vsaTodA   = 2.0 / (math.max(vsaTodSes, 1) + 1.0)
int   vsaSlot   = vsaTodMin > 0 ? int((hour * 60 + minute) / vsaTodMin) : 0
var array<float> vsaSlotVol = array.new<float>(vsaNSlots, na)
int   vsaSlotI  = (vsaSlot >= 0 and vsaSlot < vsaNSlots) ? vsaSlot : 0
float vsaSlotPv = array.get(vsaSlotVol, vsaSlotI)
float vsaSlotCv = na(volume) ? vsaSlotPv : na(vsaSlotPv) ? volume : vsaSlotPv + vsaTodA * (volume - vsaSlotPv)
array.set(vsaSlotVol, vsaSlotI, vsaSlotCv)
float vsaVolRatio = (not na(vsaSlotCv) and vsaSlotCv > 0.0) ? volume / vsaSlotCv : 1.0
float vsaVolUse   = vsaTod ? vsaVolRatio : volume         // ToD-relative volume when opted in
float vsaSp  = ta.percentrank(high - low, vsaLen)          // spread percentile 0..100
float vsaVp  = ta.percentrank(vsaVolUse,  vsaLen)          // volume percentile 0..100 (ToD-aware if on)
float vsaVpk = ta.highest(vsaVolUse, vsaLen)               // heaviest volume in the window (peak)
float vsaRng = high - low
float vsaCp  = vsaRng > 0.0 ? (close - low) / vsaRng : 0.5 // close position in range
float vsaPHi = ta.highest(high, vsaPiv)[1]                 // prior-window high
float vsaPLo = ta.lowest(low,  vsaPiv)[1]                  // prior-window low
bool  vsaUp  = close > close[1]
bool  vsaDn  = close < close[1]
bool  vsaUpthrust = hasVol and (high >= vsaPHi) and vsaCp <= 0.35 and vsaVp >= 60.0   // trap ↑ → bearish
bool  vsaShakeout = hasVol and (low  <= vsaPLo) and vsaCp >= 0.65 and vsaVp >= 60.0   // trap ↓ → bullish
bool  vsaStopping = hasVol and vsaDn and vsaSp >= 60.0 and vsaVp >= 80.0 and vsaCp >= 0.45  // demand steps in → bullish
bool  vsaClimaxUp = hasVol and vsaUp and vsaVolUse >= vsaVpk and vsaSp >= 70.0        // buying climax (peak vol, ToD-aware if on) → bearish exhaustion
bool  vsaClimaxDn = hasVol and vsaDn and vsaVolUse >= vsaVpk and vsaSp >= 70.0        // selling climax (peak vol, ToD-aware if on) → bullish exhaustion
bool  vsaNoDemand = hasVol and vsaUp and vsaSp <= 35.0 and vsaVp <= 35.0              // no effort up → bearish
bool  vsaNoSupply = hasVol and vsaDn and vsaSp <= 35.0 and vsaVp <= 35.0              // no effort down → bullish
int   vsaBiasVal  = (vsaClimaxDn or vsaShakeout or vsaStopping or vsaNoSupply) ? 1 : (vsaClimaxUp or vsaUpthrust or vsaNoDemand) ? -1 : 0
// DISPLAY priority — at most ONE marker per bar (climax > trap > stopping > no-demand/supply) so
// the text tags never overlap when several events qualify on the same bar.
bool  mClimaxUp = vsaClimaxUp
bool  mClimaxDn = vsaClimaxDn
bool  mUpthrust = vsaUpthrust and not (mClimaxUp or mClimaxDn)
bool  mShakeout = vsaShakeout and not (mClimaxUp or mClimaxDn)
bool  mStopping = vsaStopping and not (mClimaxUp or mClimaxDn or mShakeout)
bool  mNoDemand = vsaNoDemand and not (mClimaxUp or mClimaxDn or mUpthrust)
bool  mNoSupply = vsaNoSupply and not (mClimaxDn or mClimaxUp or mShakeout or mStopping)

// =============================================================================
// L1 — DWELL FIELD  (rolling occupation-time; reversible ring-buffer window)
// =============================================================================
// Uniform-across-span occupation (consistent with the house map pattern and
// exactly reversible): each confirmed bar adds 1/span time to every fixed-tick
// level its [low,high] covers; the bar leaving the window subtracts the same.
var map<int, float> dwellM = map.new<int, float>()
var array<int> ringBot = array.new<int>()
var array<int> ringTop = array.new<int>()

f_spanAdd(map<int, float> m, int botLv, int topLv, float w) =>
    span = topLv - botLv + 1
    if span > 0 and span <= 800
        inc = w / span
        for lv = botLv to topLv
            nv = nz(m.get(lv)) + inc
            if nv <= 1e-9
                m.remove(lv)
            else
                m.put(lv, nv)

if barstate.isconfirmed
    bot = f_bin(low, binTick)
    top = f_bin(high, binTick)
    if top - bot + 1 > 800
        mid = f_bin(hl2, binTick)
        bot := mid
        top := mid
    f_spanAdd(dwellM, bot, top, 1.0)
    ringBot.push(bot)
    ringTop.push(top)
    while ringBot.size() > dwlWin
        ob = ringBot.shift()
        ot = ringTop.shift()
        f_spanAdd(dwellM, ob, ot, -1.0)

// =============================================================================
// L1b — CANDIDATE BANDS  (hot levels → merged bands, this confirmed bar)
// =============================================================================
var array<float> bandLo  = array.new<float>()
var array<float> bandHi  = array.new<float>()
var array<float> bandAnc = array.new<float>()
var array<float> bandMas = array.new<float>()
var array<float> bandPct = array.new<float>()

if barstate.isconfirmed
    bandLo.clear(), bandHi.clear(), bandAnc.clear(), bandMas.clear(), bandPct.clear()
    vals = dwellM.values()
    if vals.size() >= 3
        thr    = f_pctile(vals, dwlPct)
        maxDw  = f_pctile(vals, 100)
        // hot levels, sorted ascending
        hot = array.new<int>()
        for [k, v] in dwellM
            if v >= thr
                hot.push(k)
        hot.sort()
        if hot.size() > 0
            // merge adjacent (within mergeGap) into bands
            runLo = hot.get(0)
            runHi = hot.get(0)
            i = 1
            while i <= hot.size()
                bool atEnd = i >= hot.size()
                int cur = runHi
                if not atEnd
                    cur := hot.get(i)
                if not atEnd and cur - runHi <= mergeGap + 1
                    runHi := cur
                else
                    if runHi - runLo + 1 >= minBandW
                        // mass + dwell-weighted centroid over the run
                        float mass = 0.0
                        float cen  = 0.0
                        for lv = runLo to runHi
                            dv = nz(dwellM.get(lv))
                            mass += dv
                            cen  += dv * (lv + 0.5) * binTick
                        if mass > 0
                            bandLo.push(runLo * binTick)
                            bandHi.push((runHi + 1) * binTick)
                            bandAnc.push(cen / mass)
                            bandMas.push(mass)
                            bandPct.push(f_clamp(maxDw > 0 ? mass / (maxDw * (runHi - runLo + 1)) * 100.0 : 0.0, 0.0, 100.0))
                    if i < hot.size()
                        runLo := cur
                        runHi := cur
                i += 1

// =============================================================================
// L2/L3/L4 — SHELF LIFECYCLE + LENSES + FUSION  (confirmed bars, non-repaint)
// =============================================================================
var array<Shelf> shelves = array.new<Shelf>()

// pooled correlation accumulators for the absorption family (E,K,D) — Kish ρ̄
var float cN = 0.0, var float cE = 0.0, var float cK = 0.0, var float cD = 0.0
var float cEE = 0.0, var float cKK = 0.0, var float cDD = 0.0
var float cEK = 0.0, var float cED = 0.0, var float cKD = 0.0

// per-lens reliability feedback (edge vs base) — populated by the calibrator
var int   lnN_E = 0, var int lnW_E = 0
var int   lnN_K = 0, var int lnW_K = 0
var int   lnN_D = 0, var int lnW_D = 0
var int   lnN_W = 0, var int lnW_W = 0
var int   lnN_V = 0, var int lnW_V = 0

// rolling P_abs sample for self-set tag thresholds
var array<float> pabsSample = array.new<float>()

// calibration base rate (set later; used as fusion prior)
var int baseN = 0, var int baseW = 0

f_overlap(float alo, float ahi, float blo, float bhi) => alo <= bhi and blo <= ahi

bool promotedFlag = false
if barstate.isconfirmed
    baseRate = baseN > 0 ? baseW / float(baseN) : 0.5
    // ---- 1) match current bands to shelves / create new ----
    matched = array.new<bool>(shelves.size(), false)
    if bandLo.size() > 0
        for bi = 0 to bandLo.size() - 1
            blo = bandLo.get(bi)
            bhi = bandHi.get(bi)
            int hit = -1
            if shelves.size() > 0
                for si = 0 to shelves.size() - 1
                    s = shelves.get(si)
                    if not matched.get(si) and f_overlap(blo, bhi, s.lo, s.hi)
                        hit := si
                        break
            if hit >= 0
                s = shelves.get(hit)
                s.lo := blo
                s.hi := bhi
                s.anchor := bandAnc.get(bi)
                s.dwellPct := bandPct.get(bi)
                float gInc = bandMas.get(bi) - nz(s.dwellPrev, bandMas.get(bi))
                s.dwellGrow := s.dwellGrow * 0.8 + gInc * 0.2
                s.dwellPrev := bandMas.get(bi)
                s.dwell := bandMas.get(bi)
                s.miss := 0
                s.lastSeen := bar_index
                matched.set(hit, true)
            else if shelves.size() < maxTrack
                ns = Shelf.new()
                ns.lo := blo
                ns.hi := bhi
                ns.anchor := bandAnc.get(bi)
                ns.dwell := bandMas.get(bi)
                ns.dwellPrev := bandMas.get(bi)
                ns.dwellPct := bandPct.get(bi)
                ns.birth := bar_index
                ns.lastSeen := bar_index
                shelves.push(ns)
                matched.push(true)

    // ---- 2) age unmatched shelves; drop stale ghosts ----
    if shelves.size() > 0
        for si = shelves.size() - 1 to 0
            s = shelves.get(si)
            if si < matched.size() and not matched.get(si)
                s.miss += 1
            // retire: long-unseen and not a useful ghost
            gone = (bar_index - s.lastSeen) > ghostKeep or (s.state == 3 and s.miss > contM)
            if gone
                shelves.remove(si)

    // ---- 3) per-shelf: role, promotion, on-band lens accumulation ----
    if shelves.size() > 0
        for si = 0 to shelves.size() - 1
            s = shelves.get(si)
            // role vs current price
            s.role := s.hi < close ? 1 : s.lo > close ? -1 : 0
            onBand = f_overlap(low, high, s.lo, s.hi)
            // promotion: coiled + contained
            if s.state == 0
                contained = 0
                if contM > 0
                    for j = 0 to contM - 1
                        cpx = close[j]
                        if not na(cpx) and cpx >= s.lo - contBuf * atrC and cpx <= s.hi + contBuf * atrC
                            contained += 1
                contOK = (contained / float(math.max(contM, 1))) >= contFrac
                if atrCoil >= coilMin and contOK
                    s.state := 1
                    s.coil := atrCoil
                    promotedFlag := true
            // on-band accumulation (price terms always; flow terms need volume)
            if s.state == 1 and onBand
                if na(s.entryPx)
                    s.entryPx := close
                    s.cvdRef := cvdCont
                    s.pxExtreme := close
                    s.appr := close[1] >= s.anchor ? 1 : -1   // came from above = support test
                s.onBars += 1
                if hasVol
                    s.effV += barVol
                    dP = close - close[1]
                    s.sumPD += dP * barOFI
                    s.sumO2 += barOFI * barOFI
                s.touches += 1
                body = math.max(math.abs(close - open), syminfo.mintick)
                upW  = high - math.max(open, close)
                loW  = math.min(open, close) - low
                approachUp = s.role >= 0                 // support (or on-band): expect lower-wick reject
                wick = approachUp ? loW : upW
                if wick >= wickR * body and wick >= wickA * atrC
                    s.rejects += 1
                // track extreme into the band for divergence
                s.pxExtreme := s.role >= 0 ? math.min(nz(s.pxExtreme, low), low) : math.max(nz(s.pxExtreme, high), high)

            // ---- lens scores (bounded; abstain → 0 and mask bit clear) ----
            float sE = 0.0, float sK = 0.0, float sD = 0.0, float sW = 0.0, float sV = 0.0
            int mask = 0
            volNorm = math.max(avgVol50 * math.max(s.onBars, 1), 1e-9)
            // E — √-law effort-vs-result residual
            if useE and s.onBars >= 2 and s.effV > 0
                effScaled = s.effV / volNorm
                resScaled = math.abs(close - nz(s.entryPx, close)) / math.max(atrC, 1e-9)
                sE := f_tanh(lamE * (math.sqrt(math.max(effScaled, 0.0)) - resScaled))
                mask := mask + 1
            // K — localized Kyle-λ collapse vs ambient (external λ optional)
            if useK and not na(lamAmbient) and lamAmbient > 1e-9 and (useKyleX or s.sumO2 > 1e-9)
                lamB = useKyleX ? nz(srcKyle) : s.sumPD / s.sumO2
                if lamB >= 0
                    sK := f_tanh(lamK * ((lamAmbient - lamB) / lamAmbient))
                    mask := mask + 2
            // D — dwell-decay (plateau while on band = primed)
            if useD and s.state == 1 and s.dwell > 0
                thrG    = 2.0 / math.max(dwlWin, 1)
                growN   = s.dwellGrow / math.max(s.dwell, 1e-9)
                sD := f_tanh(lamD * (thrG - growN) / math.max(thrG, 1e-9))
                mask := mask + 4
            // W — rejection-wick cluster (Wilson-floored)
            if useW and s.touches >= 3
                lbW = f_wilsonLBz(s.rejects, s.touches, 1.959964)
                sW := f_clamp(2.0 * nz(lbW) - 1.0, -1.0, 1.0)
                mask := mask + 8
            // V — CVD divergence across the shelf
            if useV and hasVol and s.onBars >= 3 and not na(s.cvdRef)
                roleSign = s.role >= 0 ? 1.0 : -1.0
                cvdMove  = (cvdCont - s.cvdRef) / math.max(math.abs(s.cvdRef) + avgOFI50 * math.max(s.onBars, 1), 1e-9)
                sV := f_clamp(roleSign * cvdMove, -1.0, 1.0)
                mask := mask + 16
            s.sE := sE, s.sK := sK, s.sD := sD, s.sW := sW, s.sV := sV
            s.lensMask := mask

            // pooled correlation update for absorption family (only when all 3 on)
            if useKish and f_hasE(mask) and f_hasK(mask) and f_hasD(mask)
                cN += 1
                cE += sE, cK += sK, cD += sD
                cEE += sE * sE, cKK += sK * sK, cDD += sD * sD
                cEK += sE * sK, cED += sE * sD, cKD += sK * sD

            // ---- fusion: correlation-aware Bayesian log-odds ----
            if s.state == 1 and mask != 0
                // ρ̄ over the absorption family
                float rhoAbs = 0.0
                if useKish and cN > 20
                    mE = cE / cN, mK = cK / cN, mD = cD / cN
                    vE = math.max(cEE / cN - mE * mE, 1e-9)
                    vK = math.max(cKK / cN - mK * mK, 1e-9)
                    vD = math.max(cDD / cN - mD * mD, 1e-9)
                    rEK = (cEK / cN - mE * mK) / math.sqrt(vE * vK)
                    rED = (cED / cN - mE * mD) / math.sqrt(vE * vD)
                    rKD = (cKD / cN - mK * mD) / math.sqrt(vK * vD)
                    rhoAbs := f_clamp((math.abs(rEK) + math.abs(rED) + math.abs(rKD)) / 3.0, 0.0, 0.95)
                // assemble active lenses
                scores = array.new<float>()
                rels   = array.new<float>()
                absFam = array.new<bool>()
                if f_hasE(mask)
                    scores.push(sE), rels.push(lnN_E > 12 ? f_clamp(0.5 + (lnW_E / float(lnN_E) - baseRate), 0.05, 0.99) : 0.5), absFam.push(true)
                if f_hasK(mask)
                    scores.push(sK), rels.push(lnN_K > 12 ? f_clamp(0.5 + (lnW_K / float(lnN_K) - baseRate), 0.05, 0.99) : 0.5), absFam.push(true)
                if f_hasD(mask)
                    scores.push(sD), rels.push(lnN_D > 12 ? f_clamp(0.5 + (lnW_D / float(lnN_D) - baseRate), 0.05, 0.99) : 0.5), absFam.push(true)
                if f_hasW(mask)
                    scores.push(sW), rels.push(lnN_W > 12 ? f_clamp(0.5 + (lnW_W / float(lnN_W) - baseRate), 0.05, 0.99) : 0.5), absFam.push(false)
                if f_hasV(mask)
                    scores.push(sV), rels.push(lnN_V > 12 ? f_clamp(0.5 + (lnW_V / float(lnN_V) - baseRate), 0.05, 0.99) : 0.5), absFam.push(false)
                N = scores.size()
                // ρ̄ over the active set: absorption-family pairs use rhoAbs, others 0
                int famCnt = 0
                for fi = 0 to absFam.size() - 1
                    if absFam.get(fi)
                        famCnt += 1
                int totPairs = N * (N - 1) / 2
                int famPairs = famCnt * (famCnt - 1) / 2
                float rhoBar = totPairs > 0 ? rhoAbs * famPairs / totPairs : 0.0
                float nEff = N / (1.0 + (N - 1) * rhoBar)
                float wLens = N > 0 ? nEff / N : 1.0
                // prior from base rate
                float L = math.log(f_clamp(baseRate, 0.02, 0.98) / (1.0 - f_clamp(baseRate, 0.02, 0.98)))
                for li = 0 to N - 1
                    p    = 0.5 * (1.0 + scores.get(li))
                    ptil = f_clamp(0.5 + (p - 0.5) * rels.get(li), 0.02, 0.98)
                    L += wLens * math.log(ptil / (1.0 - ptil))
                float pab = 1.0 / (1.0 + math.exp(-L))
                // regime down-weight
                if useReg
                    pab := 0.5 + (pab - 0.5) * (1.0 - 0.7 * regime)
                s.pabs := f_clamp(pab, 0.0, 1.0)
                pabsSample.push(s.pabs)
                while pabsSample.size() > 500
                    pabsSample.shift()

    // ---- 4) tag ladder (self-set percentile thresholds) ----
    t1 = pabsSample.size() > 30 ? f_pctile(pabsSample, tagP1) : 0.55
    t2 = pabsSample.size() > 30 ? f_pctile(pabsSample, tagP2) : 0.68
    if shelves.size() > 0
        for si = 0 to shelves.size() - 1
            s = shelves.get(si)
            if s.state == 1
                primed = s.pabs >= t2 and s.coil >= coilMin and s.sD > 0
                s.tag := primed ? 2 : s.pabs >= t1 ? 1 : 0

// =============================================================================
// L5 — FLIP TRIGGER + LIFECYCLE  (confirmed close out of the band = reversal)
// =============================================================================
var array<int>   flipBar = array.new<int>()
var array<float> flipPx  = array.new<float>()
var array<int>   flipDr  = array.new<int>()
var int lastFlipBar = -1
var int lastFlipDir = 0

if barstate.isconfirmed and shelves.size() > 0
    for si = 0 to shelves.size() - 1
        s = shelves.get(si)
        if s.state == 1 and s.touches > 0
            fUp = close > s.hi + flipK * atrC and low[1] <= s.hi + flipK * atrC
            fDn = close < s.lo - flipK * atrC and high[1] >= s.lo - flipK * atrC
            if s.appr >= 0 and fUp            // support held → bullish flip
                s.state := 2, s.flipDir := 1
                flipBar.push(bar_index), flipPx.push(s.hi), flipDr.push(1)
                lastFlipBar := bar_index, lastFlipDir := 1
            else if s.appr < 0 and fDn        // resistance held → bearish flip
                s.state := 2, s.flipDir := -1
                flipBar.push(bar_index), flipPx.push(s.lo), flipDr.push(-1)
                lastFlipBar := bar_index, lastFlipDir := -1
            else if (s.appr >= 0 and fDn) or (s.appr < 0 and fUp)   // pushed through
                s.state := 3
            while flipBar.size() > 200
                flipBar.shift(), flipPx.shift(), flipDr.shift()

// =============================================================================
// L7 — CALIBRATION  first-touch REJECT-vs-CONTINUE two-barrier race vs base
// =============================================================================
var array<int>   evBar  = array.new<int>()
var array<float> evRef  = array.new<float>()
var array<float> evAtr  = array.new<float>()
var array<int>   evDir  = array.new<int>()
var array<int>   evOut  = array.new<int>()
var array<int>   evTag  = array.new<int>()
var array<int>   evMask = array.new<int>()
var int reactN = 0, var int reactW = 0
var int reactN_is = 0, var int reactW_is = 0
var int reactN_oos = 0, var int reactW_oos = 0
var array<int> nTag = array.from(0, 0, 0)
var array<int> wTag = array.from(0, 0, 0)
var array<int>   bBar = array.new<int>()
var array<float> bRef = array.new<float>()
var array<float> bAtr = array.new<float>()
var array<int>   bDir = array.new<int>()
var array<int>   bOut = array.new<int>()

// open one event on a shelf's first touch (dir = the reversal we're testing for)
if barstate.isconfirmed and showCalib and shelves.size() > 0
    for si = 0 to shelves.size() - 1
        s = shelves.get(si)
        if s.state == 1 and not s.evOpen and s.touches >= 1
            dir = s.appr >= 0 ? 1 : -1
            ref = s.appr >= 0 ? s.hi : s.lo
            evBar.push(bar_index), evRef.push(ref), evAtr.push(math.max(atrC, 1e-9))
            evDir.push(dir), evOut.push(0), evTag.push(s.tag), evMask.push(s.lensMask)
            s.evOpen := true

// base control: every 4th confirmed bar, same race from close
dBase = math.sign(close - close[1])
if barstate.isconfirmed and showCalib and dBase != 0 and bar_index % 4 == 0
    bBar.push(bar_index), bRef.push(close), bAtr.push(math.max(atrC, 1e-9)), bDir.push(int(dBase)), bOut.push(0)

// resolve (reject-first = 1 ; continue = -1 ; timeout → non-reject)
if barstate.isconfirmed and showCalib
    splitPt = int(last_bar_index * 0.5)
    if evRef.size() > 0
        for i = 0 to evRef.size() - 1
            if evOut.get(i) == 0
                d  = evDir.get(i)
                bk = calK * evAtr.get(i)
                rj = evRef.get(i) + d * bk
                cn = evRef.get(i) - d * bk
                hitRej = d > 0 ? high >= rj : low <= rj
                hitCon = d > 0 ? low <= cn : high >= cn
                if hitRej and not hitCon
                    evOut.set(i, 1)
                else if hitCon
                    evOut.set(i, -1)
        for i = evRef.size() - 1 to 0
            if bar_index - evBar.get(i) >= calH
                rjw = evOut.get(i) == 1 ? 1 : 0
                reactN += 1, reactW := reactW + rjw
                tg = evTag.get(i)
                nTag.set(tg, nTag.get(tg) + 1), wTag.set(tg, wTag.get(tg) + rjw)
                if evBar.get(i) <= splitPt
                    reactN_is += 1, reactW_is := reactW_is + rjw
                else
                    reactN_oos += 1, reactW_oos := reactW_oos + rjw
                mk = evMask.get(i)
                if f_hasE(mk)
                    lnN_E += 1, lnW_E := lnW_E + rjw
                if f_hasK(mk)
                    lnN_K += 1, lnW_K := lnW_K + rjw
                if f_hasD(mk)
                    lnN_D += 1, lnW_D := lnW_D + rjw
                if f_hasW(mk)
                    lnN_W += 1, lnW_W := lnW_W + rjw
                if f_hasV(mk)
                    lnN_V += 1, lnW_V := lnW_V + rjw
                evBar.remove(i), evRef.remove(i), evAtr.remove(i), evDir.remove(i), evOut.remove(i), evTag.remove(i), evMask.remove(i)
    if bRef.size() > 0
        for i = 0 to bRef.size() - 1
            if bOut.get(i) == 0
                d2  = bDir.get(i)
                bk2 = calK * bAtr.get(i)
                rj2 = bRef.get(i) + d2 * bk2
                cn2 = bRef.get(i) - d2 * bk2
                hr2 = d2 > 0 ? high >= rj2 : low <= rj2
                hc2 = d2 > 0 ? low <= cn2 : high >= cn2
                if hr2 and not hc2
                    bOut.set(i, 1)
                else if hc2
                    bOut.set(i, -1)
        for i = bRef.size() - 1 to 0
            if bar_index - bBar.get(i) >= calH
                baseN += 1, baseW := baseW + (bOut.get(i) == 1 ? 1 : 0)
                bBar.remove(i), bRef.remove(i), bAtr.remove(i), bDir.remove(i), bOut.remove(i)

// nearest active/ghost shelf above & below price (for magnets + exports)
var float shelfAbove = na, var float shelfBelow = na
shelfAbove := na
shelfBelow := na
if shelves.size() > 0
    for si = 0 to shelves.size() - 1
        s = shelves.get(si)
        if s.state == 1 or s.state == 2
            if s.lo > close and (na(shelfAbove) or s.lo < shelfAbove)
                shelfAbove := s.anchor
            if s.hi < close and (na(shelfBelow) or s.hi > shelfBelow)
                shelfBelow := s.anchor

// =============================================================================
// RENDER — once per confirmed bar (throttle)
// =============================================================================
var array<box>   dBoxes  = array.new<box>()
var array<line>  dLines  = array.new<line>()
var array<label> dLabels = array.new<label>()

var int drawnBar = -1
doDraw = barstate.islast and (bar_index != drawnBar or barstate.isconfirmed)

f_tagTxt(int t) => t == 2 ? "PRIMED" : t == 1 ? "ABSORBING" : "BALANCE"
f_lensGlyph(int m) => (f_hasE(m) ? "E" : "·") + (f_hasK(m) ? "K" : "·") + (f_hasD(m) ? "D" : "·") + (f_hasW(m) ? "W" : "·") + (f_hasV(m) ? "V" : "·")
f_tp(array<int> nT, array<int> wT, int i) => nT.get(i) > 0 ? str.tostring(wT.get(i) / float(nT.get(i)) * 100.0, "#") + "%(" + str.tostring(nT.get(i)) + ")" : "—"
zBonf = calBonf ? 2.394 : 1.959964   // ~95% Bonferroni-deflated across 3 tag buckets

if doDraw
    drawnBar := bar_index
    for b in dBoxes
        b.delete()
    dBoxes.clear()
    for l in dLines
        l.delete()
    dLines.clear()
    for lb in dLabels
        lb.delete()
    dLabels.clear()

    // rank active/flipped shelves by conviction, show top maxShow
    if (showBands or showGhost) and shelves.size() > 0
        idx = array.new<int>()
        conv = array.new<float>()
        for si = 0 to shelves.size() - 1
            s = shelves.get(si)
            vis = (showBands and (s.state == 1 or s.state == 2)) or (showGhost and (s.state == 2 or s.state == 3))
            if vis
                idx.push(si)
                conv.push(s.state == 1 ? s.pabs + s.dwellPct / 1000.0 : 0.2)
        // simple selection of top maxShow by conviction
        shown = 0
        used = array.new<bool>(idx.size(), false)
        while shown < maxShow and shown < idx.size()
            best = -1
            bestV = -1.0
            for j = 0 to idx.size() - 1
                if not used.get(j) and conv.get(j) > bestV
                    bestV := conv.get(j)
                    best := j
            if best < 0
                break
            used.set(best, true)
            shown += 1
            s = shelves.get(idx.get(best))
            active = s.state == 1
            ghost  = not active
            // movement-trend colour: support (expect bounce UP) = teal, resistance
            // (expect reject DOWN) = red; a flipped shelf carries its FLIP direction.
            roleC  = s.role >= 0 ? C_UP : C_DN
            flipC  = s.flipDir > 0 ? C_UP : C_DN
            bcol   = s.state == 2 ? flipC : roleC
            fillC  = s.state == 2 ? flipC : roleC
            fillT  = active ? int(f_clamp(90 - s.dwellPct * 0.35, 60, 92)) : 90
            // span the shelf over its actual life: birth → death (or now, extended)
            int bLeft  = math.max(s.birth, bar_index - dispLook)
            int bRight = active ? bar_index + 10 : math.min(bar_index, math.max(s.lastSeen, s.birth + 1))
            if showBands and active
                dBoxes.push(box.new(bLeft, s.hi, bRight, s.lo, border_color = color.new(roleC, 35), bgcolor = color.new(fillC, fillT), border_width = 1))
            else if showGhost and ghost
                dBoxes.push(box.new(bLeft, s.hi, bRight, s.lo, border_color = color.new(bcol, 55), bgcolor = color.new(bcol, 94), border_style = line.style_dashed, border_width = 1))
            // badge at the shelf's right end (active → chart edge; ghost → where it died)
            if showBadge and (active or showGhost)
                rp = reactN > 4 ? str.tostring(reactW / float(reactN) * 100.0, "#") + "%" : "…"
                gl = showGlyph ? "  " + f_lensGlyph(s.lensMask) : ""
                btxt = (active ? f_tagTxt(s.tag) : s.state == 2 ? "FLIP " + (s.flipDir > 0 ? "▲" : "▼") : "naked") + (active ? "  " + str.tostring(s.pabs * 100.0, "#") + "  rej " + rp : "") + gl
                txtC = active ? (s.tag == 0 ? C_MUTED : roleC) : (s.state == 2 ? flipC : C_MUTED)
                dLabels.push(label.new(bRight, s.anchor, btxt, style = label.style_label_left, color = color.new(C_BG, 10), textcolor = txtC, size = active ? size.small : size.tiny))

    // flip markers
    if showFlip and flipBar.size() > 0
        for i = 0 to flipBar.size() - 1
            fb = flipBar.get(i)
            if last_bar_index - fb <= dispLook
                fdir = flipDr.get(i)
                fCol = fdir > 0 ? C_UP : C_DN
                dLabels.push(label.new(fb, flipPx.get(i), fdir > 0 ? "▲" : "▼", style = fdir > 0 ? label.style_label_up : label.style_label_down, color = color.new(fCol, 0), textcolor = color.new(#ffffff, 0), size = size.tiny))

    // dwell heat spine (left margin) — faint occupation histogram
    if showHeat and dwellM.size() > 0
        hv = dwellM.values()
        hmax = f_pctile(hv, 100)
        if not na(hmax) and hmax > 0
            xh0 = bar_index - 60
            for [lv, dv] in dwellM
                if dv > 0
                    py = (lv + 0.5) * binTick
                    wln = int(math.round(dv / hmax * 12))
                    if wln >= 1
                        dLines.push(line.new(xh0, py, xh0 + wln, py, color = color.new(C_MUTED, 70), width = 1))

// =============================================================================
// EXPORT SCAN — nearest active shelf to price (for Data Window + dashboard)
// =============================================================================
var float nrMid = na, var float nrHi = na, var float nrLo = na
var float nrPabs = na, var int nrTag = -1, var int nrMask = 0, var float nrDwl = na
nrMid := na, nrHi := na, nrLo := na, nrPabs := na, nrTag := -1, nrMask := 0, nrDwl := na
if shelves.size() > 0
    float bestD = 1e18
    for si = 0 to shelves.size() - 1
        s = shelves.get(si)
        if s.state == 1
            d = math.abs(close - s.anchor)
            if d < bestD
                bestD := d
                nrMid := s.anchor, nrHi := s.hi, nrLo := s.lo
                nrPabs := s.pabs, nrTag := s.tag, nrMask := s.lensMask, nrDwl := s.dwellPct

// =============================================================================
// DASHBOARD
// =============================================================================
var table dash = table.new(f_pos(dashPosIn), 4, 12, bgcolor = C_BG, border_color = C_GRID, border_width = 1, frame_color = C_GRID, frame_width = 1)

if doDraw and showDash
    table.clear(dash, 0, 0, 3, 11)
    pro = dashMode == "Pro"
    table.cell(dash, 0, 0, "ABS-SHELF", text_color = C_TEXT, text_size = size.small, bgcolor = C_HEADER)
    table.cell(dash, 1, 0, "Tag",  text_color = C_TEXT, text_size = size.small, bgcolor = C_HEADER)
    table.cell(dash, 2, 0, "P",    text_color = C_TEXT, text_size = size.small, bgcolor = C_HEADER)
    table.cell(dash, 3, 0, pro ? "Lens" : "Dw%", text_color = C_TEXT, text_size = size.small, bgcolor = C_HEADER)
    // list up to 5 active shelves, nearest first
    order = array.new<int>()
    dist  = array.new<float>()
    if shelves.size() > 0
        for si = 0 to shelves.size() - 1
            s = shelves.get(si)
            if s.state == 1
                order.push(si), dist.push(math.abs(close - s.anchor))
    int rr = 1
    int placed = 0
    usedD = array.new<bool>(order.size(), false)
    while placed < 5 and placed < order.size()
        bIx = -1
        bV = 1e18
        for j = 0 to order.size() - 1
            if not usedD.get(j) and dist.get(j) < bV
                bV := dist.get(j)
                bIx := j
        if bIx < 0
            break
        usedD.set(bIx, true)
        s = shelves.get(order.get(bIx))
        roleC = s.role >= 0 ? C_UP : C_DN
        tagC  = s.tag == 0 ? C_MUTED : roleC
        table.cell(dash, 0, rr, (s.role >= 0 ? "S " : "R ") + str.tostring(s.anchor, format.mintick), text_color = C_TEXT, text_size = size.tiny, text_halign = text.align_left)
        table.cell(dash, 1, rr, f_tagTxt(s.tag), text_color = tagC, text_size = size.tiny)
        table.cell(dash, 2, rr, str.tostring(s.pabs * 100.0, "#"), text_color = C_TEXT, text_size = size.tiny)
        table.cell(dash, 3, rr, pro ? f_lensGlyph(s.lensMask) : str.tostring(s.dwellPct, "#"), text_color = C_MUTED, text_size = size.tiny)
        rr += 1
        placed += 1
    if placed == 0
        table.cell(dash, 0, 1, "no active shelf", text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_left)
        rr := 2
    // footer block
    fr = rr < 6 ? 6 : rr
    method = sideMode == "BVC-Normal" ? "EST·BVC" : sideMode == "Tick" ? "EST·tick" : "EST·geo"
    string foot = "study · not a signal · " + method + (not hasVol ? " · no-vol: E/K/V off" : "")
    foot := useTox and math.abs(srcTox) <= 100 ? foot + " · tox " + str.tostring(srcTox, "#.##") : foot
    table.cell(dash, 0, fr, foot, text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_left)
    // calibration line
    if showCalib and reactN > 4
        rp = reactW / float(reactN) * 100.0
        bp = baseN > 0 ? baseW / float(baseN) * 100.0 : na
        lb = nz(f_wilsonLBz(reactW, reactN, zBonf)) * 100.0
        edge = na(bp) ? float(na) : rp - bp
        es = na(edge) ? "" : " vs base " + str.tostring(bp, "#") + "% → edge " + (edge >= 0 ? "+" : "") + str.tostring(edge, "#")
        ctxt = "shelf reject " + str.tostring(rp, "#") + "% (n" + str.tostring(reactN) + ", LB " + str.tostring(lb, "#") + "%)" + es
        table.cell(dash, 0, fr + 1, ctxt, text_color = na(edge) ? C_MUTED : (edge > 0 ? C_POS : C_NEG), text_size = size.tiny, text_halign = text.align_left)
        // per-tag ranking
        table.cell(dash, 0, fr + 2, "PRIMED " + f_tp(nTag, wTag, 2) + " · ABS " + f_tp(nTag, wTag, 1) + " · BAL " + f_tp(nTag, wTag, 0), text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_left)
        if showOOS and reactN_oos > 0
            op = reactW_oos / float(reactN_oos) * 100.0
            table.cell(dash, 0, fr + 3, "OOS reject " + str.tostring(op, "#") + "% (n" + str.tostring(reactN_oos) + ")", text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_left)
    else if showCalib
        table.cell(dash, 0, fr + 1, "shelf reject: learning…", text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_left)
    if useReg
        table.cell(dash, 0, fr + 4, "regime " + str.tostring(regime, "#.##") + (regime > 0.5 ? " · trend (down-wt)" : " · balance"), text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_left)

// =============================================================================
// EXPORTS & ALERTS
// =============================================================================
plot(expOn ? nrHi   : na, "EXP_ShelfHi",  display = display.data_window)
plot(expOn ? nrLo   : na, "EXP_ShelfLo",  display = display.data_window)
plot(expOn ? nrMid  : na, "EXP_ShelfMid", display = display.data_window)
plot(expOn ? nrTag  : na, "EXP_ShelfTag", display = display.data_window)
plot(expOn ? nrPabs : na, "EXP_ShelfPabs",display = display.data_window)
plot(expOn ? nrDwl  : na, "EXP_DwellPctile", display = display.data_window)
plot(expOn ? atrCoil: na, "EXP_Coil",     display = display.data_window)
plot(expOn ? lastFlipDir : na, "EXP_FlipDir", display = display.data_window)
plot(expOn ? shelfAbove : na, "EXP_NakedShelfAbove", display = display.data_window)
plot(expOn ? shelfBelow : na, "EXP_NakedShelfBelow", display = display.data_window)
plot(expOn and reactN > 4 and baseN > 0 ? (reactW / float(reactN) - baseW / float(baseN)) * 100.0 : na, "EXP_RejectEdge", display = display.data_window)
plot(expOn ? nrMask : na, "EXP_ActiveLenses", display = display.data_window)

flipUpNow = lastFlipBar == bar_index and lastFlipDir == 1
flipDnNow = lastFlipBar == bar_index and lastFlipDir == -1
primedTag = nrTag == 2 and not na(nrLo) and low <= nrHi and high >= nrLo

alertcondition(promotedFlag, "Shelf promoted",  "ABS-SHELF: a dwell-coil absorption shelf was promoted to active.")
alertcondition(flipUpNow, "Shelf flip up",   "ABS-SHELF: price held an absorption shelf and closed back up (bullish flip).")
alertcondition(flipDnNow, "Shelf flip down", "ABS-SHELF: price held an absorption shelf and closed back down (bearish flip).")
alertcondition(primedTag, "On a PRIMED shelf","ABS-SHELF: price is trading on a PRIMED absorption shelf.")

// ── VSA event markers (Wave D) — plotshape only, so the label/box pools are untouched ──
plotshape(vsaOn and mUpthrust,  "VSA Upthrust",       shape.triangledown, location.abovebar, color.new(C_DN, 0),    text = "UT",   textcolor = color.new(C_DN, 0),   size = size.tiny)
plotshape(vsaOn and mShakeout,  "VSA Shakeout",       shape.triangleup,   location.belowbar, color.new(C_UP, 0),    text = "SO",   textcolor = color.new(C_UP, 0),   size = size.tiny)
plotshape(vsaOn and mStopping,  "VSA Stopping Vol",   shape.square,       location.belowbar, color.new(C_UP, 0),    text = "SV",   textcolor = color.new(C_UP, 0),   size = size.tiny)
plotshape(vsaOn and mClimaxUp,  "VSA Buying climax",  shape.triangledown, location.abovebar, color.new(#ff6d00, 0), text = "BC", textcolor = color.new(#ff6d00, 0), size = size.tiny)
plotshape(vsaOn and mClimaxDn,  "VSA Selling climax", shape.triangleup,   location.belowbar, color.new(#ff6d00, 0), text = "SC", textcolor = color.new(#ff6d00, 0), size = size.tiny)
plotshape(vsaOn and vsaMinor and mNoDemand, "VSA No demand", shape.xcross, location.abovebar, color.new(C_MUTED, 0), text = "nd", textcolor = color.new(C_MUTED, 0), size = size.tiny)
plotshape(vsaOn and vsaMinor and mNoSupply, "VSA No supply", shape.cross,  location.belowbar, color.new(C_MUTED, 0), text = "ns", textcolor = color.new(C_MUTED, 0), size = size.tiny)
plot(expOn ? vsaBiasVal : na, "EXP_VSABias", display = display.data_window)
alertcondition(vsaOn and vsaUpthrust, "VSA Upthrust",       "ABS-SHELF: Upthrust — new high rejected on volume (bearish trap).")
alertcondition(vsaOn and vsaShakeout, "VSA Shakeout",       "ABS-SHELF: Shakeout — new low reclaimed on volume (bullish trap).")
alertcondition(vsaOn and vsaStopping, "VSA Stopping Volume","ABS-SHELF: Stopping Volume — wide down-bar closing off the low (demand stepping in).")
alertcondition(vsaOn and vsaClimaxUp, "VSA Buying climax",  "ABS-SHELF: Buying climax — peak-volume wide up-bar (bearish exhaustion).")
alertcondition(vsaOn and vsaClimaxDn, "VSA Selling climax", "ABS-SHELF: Selling climax — peak-volume wide down-bar (bullish exhaustion).")

// This script is for analysis and education. It is not financial advice.
````
