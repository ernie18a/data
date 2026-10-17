# Volatility Drag Oscillator

- url: https://www.tradingview.com/script/Vjicio5d-Volatility-Drag-Oscillator/
- type: indicator
- pine_id: PUB;0358f217c6e34d2cb5840cee7359a45f
- version: 2.0

## Description

Volatility Drag Oscillator — what is holding exposure costing you, and what does leverage do to it?

Compound growth is g = μ − σ²/2; under leverage, g(L) = L·μ − L²·σ²/2. Return scales with L, drag scales
with L² — which is the whole reason leverage does not raise your probability of success. Volatility is
estimable in hundreds of bars; drift needs decades. So this tool measures only the knowable half:

- DRAG = σ²/2 annualised (Yang-Zhang by default; Close-to-close / Parkinson / Garman-Klass /
  Rogers-Satchell selectable to see estimator disagreement = gap-risk information), EWMA-smoothed and
  ranked into a percentile so you know if today is a cheap or expensive time to hold.

- DRAG DECOMPOSITION — realised drag split into its exact cumulant pieces: variance (σ²/2) + skew +
  excess-kurtosis, shown as "σ² · skw · tail" in %/yr. A fat-tail warning tells you HOW MUCH of your
  drag is tails, not just that they exist — and it compares realised drag to its own Gaussian part, so
  it can't be fooled by estimator choice.

- LEVERAGE CURVE — drag at 1×/2×/3×, plus break-even L_be = 2μ/σ² and Kelly = μ/σ², shown ONLY as
  conditionals on an edge YOU enter. The script never estimates drift, and says why.

READ IT how you like: a familiar 0-100 percentile OSCILLATOR in the pane (cheap<20, expensive>80,
midline 50, like an RSI of holding-cost), or the absolute drag %/yr line. On price, a heat-RIBBON and
green/red regime triangles show cheap→expensive to hold — VOLATILITY regime, direction-agnostic. A red
marker means "expensive, size down", never "go short".

No directional claim and no backtest — there is nothing here to fit. Descriptive risk context, not advice.
Leverage magnifies losses; this shows one cost of it, not all risks.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// VOLATILITY DRAG OSCILLATOR                                                                  v1.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT ANSWERS
//  "What is holding exposure costing me right now, and what does sizing up do to that?"
//   Panel headline, e.g.:  Drag 4.2%/yr · 78th pctile · at 2× costs 16.8% · negative beyond 3.4×
//
// THE MATHEMATICS (and the one design decision that matters)
//   The time-average (compound) growth of a multiplicative process is g = μ − σ²/2. Under leverage L
//   it becomes g(L) = L·μ − L²·σ²/2. The return term scales with L; the DRAG term scales with L².
//   μ (drift) and σ (volatility) are NOT equally estimable: volatility converges in hundreds of bars,
//   drift needs decades — which is exactly why estimated-drift strategies fail. So this tool is built
//   entirely on the half that is measurable:
//     • DRAG = σ²/2 (annualised) — the headline. Robust, needs no drift.
//     • LEVERAGE ASYMMETRY — return ∝ L, drag ∝ L². Needs no drift at all, and is the whole reason
//       leverage does not raise your probability of success.
//     • BREAK-EVEN leverage L_be = 2μ/σ² and KELLY L* = μ/σ² — shown ONLY as conditionals on an edge
//       YOU supply. This script never estimates μ, and the header says why.
//
// THE SELF-VALIDATING PIECE — DECOMPOSED
//   Empirical drag = (arithmetic − geometric) realised return ≈ σ²/2. But the exact realised drag is a
//   CUMULANT series:  drag ≈ κ2/2 + κ3/6 + κ4/24 + …  where κ2 = variance, κ3 = skew, κ4 = excess
//   kurtosis of the return. This tool breaks the realised drag into those three pieces so you see not
//   just THAT tails are inflating your drag but HOW MUCH:  "0.5%/yr = 0.35 variance − 0.02 skew + 0.17
//   tail". The Gaussian σ²/2 is only the first term; the rest is what the normal model misses. The
//   fat-tail flag compares realised drag to its OWN Gaussian part (same series), so it can't be fooled
//   by estimator disagreement. EXP_TailDrag exports the non-Gaussian (skew+kurtosis) portion.
//
// ESTIMATORS  &  SMOOTHING
//   Yang-Zhang (default): σ² = σ²_overnight + k·σ²_open-close + (1−k)·σ²_Rogers-Satchell — uses gaps,
//   so it captures overnight risk. Also Close-to-close / Parkinson / Garman-Klass / Rogers-Satchell —
//   switch to SEE estimator disagreement (genuine gap-risk information).
//   SMOOTHING is EWMA (RiskMetrics, exponential) by DEFAULT: a big bar decays smoothly rather than
//   sitting on a flat plateau for N bars and dropping off a cliff — easier to read, standard practice.
//   A robust cap clips a single bar's squared return at a multiple of the running variance, so an
//   overnight gap on an intraday chart cannot dominate. "Simple rolling" remains available.
//   NOTE (intraday): Yang-Zhang's overnight term captures the true session gap once per day; on an
//   intraday chart that single event is annualised per-bar, so it reads high. EWMA + cap tame it, but
//   for a pure within-session read choose Rogers-Satchell or Close-to-close.
//
// HOW YOU READ IT — NOT a directional signal
//   PANE: choose a familiar 0-100 percentile OSCILLATOR (cheap<20, expensive>80, midline 50 — read it
//   like an RSI of holding-cost) or the absolute drag %/yr line. PRICE CHART: a bold heat-RIBBON along
//   the bottom shows the whole regime spectrum (cheap/calm → expensive/stressed) without covering the
//   candles; green ▲ / red ▼ triangles mark the moment drag enters its cheap or expensive zone
//   (debounced). All of it is VOLATILITY-REGIME context — "cheap vs expensive to hold", direction-
//   agnostic. A red ▼ means "expensive, size down", never "go short". Background-shade and candle-tint
//   modes are also available.
//
// ALL-TIMEFRAME
//   Bar-based lookbacks; per-bar variance is annualised via timeframe.in_seconds(). Drag is a pure
//   variance transform, so it is timeframe-agnostic by construction — no session anchors.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Drag (%/yr) · EXP_DragPct (percentile 0-100) · EXP_LevBE · EXP_LevKelly · EXP_DragEmp (%/yr) ·
//   EXP_TailDrag (%/yr, the non-Gaussian skew+kurtosis portion of realised drag)
//
// CONCEPT CREDIT
//   Volatility drag / geometric-vs-arithmetic growth — standard result (the "variance drain",
//   T. Messmore; Fernholz-Shay stochastic portfolio theory). Kelly criterion — J. L. Kelly (1956).
//   EWMA variance — RiskMetrics (J.P. Morgan, 1996). Cumulant/Cornish-Fisher moment expansion — classic.
//   Volatility estimators — F. Black / M. Parkinson (1980) / Garman-Klass (1980) / Rogers-Satchell
//   (1991) / Yang-Zhang (2000). The drag panel, the empirical cross-check, the cumulant drag
//   decomposition and the leverage-curve presentation are the author's own. No third-party code reused.
//
// HONEST FRAMING
//   NO directional claim and NO forward harness — there is nothing here to backtest. Break-even and
//   Kelly are conditional on an edge YOU provide; the script deliberately refuses to estimate drift.
//   Figures are in-sample descriptions of realised variance, annualised by a convention you can set.
//   Not financial advice. Leverage magnifies losses; this tool shows one cost of it, not all risks.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Volatility Drag Oscillator", "Vol Drag", overlay = false, precision = 2, max_labels_count = 50)

// ═════════════════════════ INPUTS ═══════════════════════════════════════════════════════════════
gV = "01 · Volatility"
estMode = input.string("Yang-Zhang", "Estimator", options = ["Yang-Zhang","Close-to-close","Parkinson","Garman-Klass","Rogers-Satchell"], group = gV, tooltip = "Yang-Zhang (default) uses overnight gaps + intraday + Rogers-Satchell, so it captures gap risk. Switch estimators to see how much they disagree — that disagreement is real information about gap/tail risk.")
smoothMode = input.string("EWMA", "Smoothing", options = ["EWMA","Simple rolling"], group = gV, tooltip = "EWMA (default, RiskMetrics-style exponential): a big bar decays smoothly, no blocky plateaus. Simple rolling: a flat N-bar average — one big bar holds a plateau for N bars then drops off a cliff.")
volLen  = input.int(20,  "Lookback / EWMA span (bars)", minval = 5,  maxval = 500,  group = gV, tooltip = "Bars the variance is measured over (Simple), or the EWMA span (α = 2/(span+1)). Volatility converges fast, so 20-60 is usually enough.")
robustCap = input.float(10.0, "Robust outlier cap (× est., 0 = off)", minval = 0.0, maxval = 50.0, step = 1.0, group = gV, tooltip = "EWMA only. Clip a single bar's squared return at this multiple of the running variance, so an overnight gap or a fat bar can't dominate the estimate. 10 rarely touches a normal move (a 3σ bar ≈ 9×) but caps true outliers. 0 disables.")
pctLen  = input.int(250, "Percentile window",   minval = 30, maxval = 2000, group = gV, tooltip = "History the current drag is ranked against — is today a cheap or expensive time to hold exposure?")

gA = "01b · Annualisation"
daysPerYear = input.float(252, "Trading days / year", minval = 1, maxval = 366, step = 1, group = gA, tooltip = "Used to annualise per-bar variance. 252 = equities/futures; 365 for 24/7 markets.")
sessHours   = input.float(6.5, "Intraday hours / session", minval = 0.5, maxval = 24.0, step = 0.25, group = gA, tooltip = "INTRADAY charts only: hours the market trades per session, to convert per-bar variance to per-year. NSE ≈ 6.25 · US equity 6.5 · 24h (crypto/FX) 24. Ignored on daily+ charts.")

gL = "02 · Leverage"
edgePct = input.float(0.0, "Assumed annual edge % (μ) — YOU supply", minval = 0.0, maxval = 300.0, step = 0.5, group = gL, tooltip = "YOUR OWN estimate of annual expected return (drift). The script NEVER estimates this — drift needs decades of data to pin down. Break-even and Kelly leverage are shown ONLY as conditionals on this number. Leave at 0 to see pure drag with no leverage optimum.")
levA = input.float(1.0, "Leverage A (your current)", minval = 0.25, maxval = 20.0, step = 0.25, group = gL)
levB = input.float(2.0, "Leverage B", minval = 0.25, maxval = 20.0, step = 0.25, group = gL)
levC = input.float(3.0, "Leverage C", minval = 0.25, maxval = 20.0, step = 0.25, group = gL)

gX = "03 · Empirical cross-check & decomposition"
empOn  = input.bool(true, "Empirical drag cross-check (self-validating)", group = gX, tooltip = "Measure realised (arithmetic mean − geometric mean) return and compare it to the Gaussian σ²/2. Agreement validates the model live; empirical ≫ theoretical is a FAT-TAIL warning — your true drag is higher than the formula says.")
empLen = input.int(250, "Empirical / decomposition lookback (bars)", minval = 30, maxval = 3000, group = gX)
divThr = input.float(1.5, "Fat-tail flag (realised / Gaussian ×)", minval = 1.05, maxval = 5.0, step = 0.05, group = gX, tooltip = "Flag fat tails when the REALISED drag exceeds its own Gaussian (variance) part by at least this ratio — i.e. skew + tails are adding materially to your drag. This compares like with like (both from the same close-to-close series), so it can't be fooled by estimator disagreement.")

gD = "04 · Display & theme"
showPanel   = input.bool(true, "Show dashboard", group = gD)
panelMode   = input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = gD)
panelPos    = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gD)
themeOpt    = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = gD)
showBands   = input.bool(true, "Regime bands in pane (cheap/expensive)", group = gD, tooltip = "Faint green when drag is in its bottom quintile (cheap to hold), faint red when top quintile (expensive) — an instant regime read behind the drag line.")
priceMark   = input.string("Bottom ribbon", "Regime on PRICE chart", options = ["Bottom ribbon","Background (high-drag)","Colour candles (high-drag)","Off"], group = gD, tooltip = "How the volatility-DRAG regime is shown on your price chart. This is NOT bullish/bearish — drag is a cost of holding, direction-agnostic.\n• Bottom ribbon (recommended): a thin heat-strip along the BOTTOM of the price pane, coloured across the WHOLE spectrum — cheap/calm at one end, expensive/stressed at the other. Shows both sides, never covers the candles, and can't be misread as a bear signal.\n• Background (high-drag): faint shading only when drag is in its top decile.\n• Colour candles (high-drag): tints the candles in high-drag bars.\n• Off.")
hiDragThr   = input.int(90, "High-drag ON threshold (pctile)", minval = 50, maxval = 100, group = gD, tooltip = "A high-drag zone STARTS when drag rises to this percentile.")
hiDragOff   = input.int(70, "High-drag OFF threshold (pctile)", minval = 30, maxval = 99, group = gD, tooltip = "Hysteresis: once started, a high-drag zone stays on until drag falls below THIS percentile — so it doesn't flicker on and off bar-to-bar in choppy tape. Set equal to the ON threshold for no hysteresis.")
paneView    = input.string("Percentile oscillator (0-100)", "Pane view", options = ["Percentile oscillator (0-100)","Drag %/yr (absolute)"], group = gD, tooltip = "Percentile oscillator (recommended): plots drag ranked 0-100 like an RSI — cheap zone below 20, expensive above 80, midline at 50. Familiar to read and comparable across timeframes. Drag %/yr (absolute): the raw annualised cost, which carries magnitude but whose scale varies by timeframe.")
showTri     = input.bool(true, "Regime triangles on price", group = gD, tooltip = "Green ▲ (below price) when drag DROPS into its cheap/calm zone; red ▼ (above price) when it RISES into its expensive/stressed zone. Debounced regime-change markers. NOTE: these mark VOLATILITY regime, not direction — drag costs the same whether you're long or short.")
ribbonBold  = input.bool(true, "Bold ribbon colour", group = gD, tooltip = "Fully saturate the thick bottom ribbon's colours (intense). Off = softer / translucent. The ribbon is a solid block either way.")
showLevCurve= input.bool(false, "Plot leverage-scaled drag (B / C)", group = gD, tooltip = "Overlay drag at Leverage B and C — you SEE the quadratic: 2× leverage is 4× the drag, 3× is 9×. Off by default to keep the pane clean (the values are in the panel).")
showEmp     = input.bool(true, "Overlay empirical drag line", group = gD)
colCheap = input.color(#2ebd85, "Cheap to hold", inline = "c", group = gD)
colExp   = input.color(#f6465d, "Expensive",     inline = "c", group = gD)
colEmp   = input.color(#42a5f5, "Empirical",     inline = "c", group = gD)

// ═════════════════════════ SMOOTHING HELPERS (EWMA / rolling, both run every bar) ═══════════════
// robust EWMA variance of a return series r: σ²_t = λσ²_{t-1} + (1−λ)·min(r², cap·σ²_{t-1}).
// ta.variance runs UNCONDITIONALLY (top of function body); the ternary only selects a precomputed float.
f_rvar(series float r, simple int len, simple bool ew, simple float cap) =>
    float vSimple = ta.variance(r, len)                 // always evaluated (no conditional ta.*)
    float a  = 2.0 / (len + 1.0)
    float x  = r * r
    var float e = na
    float xc = (cap > 0.0 and not na(e) and not na(x)) ? math.min(x, cap * e) : x
    e := na(xc) ? e : na(e) ? xc : e + a * (xc - e)
    ew ? e : vSimple

// robust EWMA of an already-variance-like per-bar proxy p (Parkinson/GK/RS bars).
f_rmean(series float p, simple int len, simple bool ew, simple float cap) =>
    float mSimple = ta.sma(p, len)                      // always evaluated
    float a  = 2.0 / (len + 1.0)
    var float e = na
    float pc = (cap > 0.0 and not na(e) and not na(p)) ? math.min(p, cap * e) : p
    e := na(pc) ? e : na(e) ? pc : e + a * (pc - e)
    ew ? e : mSimple

// ═════════════════════════ VOLATILITY ENGINE (per-bar variance) ═════════════════════════════════
bool  useEwma = smoothMode == "EWMA"
float capRS   = 0.0                                     // RS/GK bars can be negative → no cap on them
float ln2  = math.log(2.0)
float lrcc = math.log(close / close[1])   // close-to-close log return
float lroc = math.log(close / open)       // open-to-close
float lrco = math.log(open  / close[1])   // overnight (prior close-to-open)

// Close-to-close
float vCC = f_rvar(lrcc, volLen, useEwma, robustCap)
// Parkinson (high-low range)
float pkBar = math.pow(math.log(high / low), 2.0)
float vPark = f_rmean(pkBar, volLen, useEwma, robustCap) / (4.0 * ln2)
// Garman-Klass
float gkBar = 0.5 * math.pow(math.log(high / low), 2.0) - (2.0 * ln2 - 1.0) * math.pow(math.log(close / open), 2.0)
float vGK = f_rmean(gkBar, volLen, useEwma, capRS)
// Rogers-Satchell (drift-independent)
float rsBar = math.log(high / close) * math.log(high / open) + math.log(low / close) * math.log(low / open)
float vRS = f_rmean(rsBar, volLen, useEwma, capRS)
// Yang-Zhang = overnight + k·open-close + (1−k)·Rogers-Satchell
float vO  = f_rvar(lrco, volLen, useEwma, robustCap)   // overnight variance
float vOC = f_rvar(lroc, volLen, useEwma, robustCap)   // open-close variance
float kYZ = 0.34 / (1.34 + (volLen + 1.0) / math.max(volLen - 1.0, 1.0))
float vYZ = vO + kYZ * vOC + (1.0 - kYZ) * vRS

float varBar = estMode == "Close-to-close" ? vCC : estMode == "Parkinson" ? vPark : estMode == "Garman-Klass" ? vGK : estMode == "Rogers-Satchell" ? vRS : vYZ
varBar := math.max(nz(varBar, 0.0), 0.0)  // small-sample estimates can go slightly negative; floor at 0

// ── annualisation (per-bar variance → per-year) ──
float tfSec = timeframe.in_seconds()
float barsPerYear = tfSec >= 2419200 ? daysPerYear / 21.0 : tfSec >= 604800 ? daysPerYear / 5.0 : tfSec >= 86400 ? daysPerYear : daysPerYear * (sessHours * 3600.0) / math.max(tfSec, 1.0)
float varAnn   = varBar * barsPerYear
float sigAnn   = math.sqrt(varAnn)
float dragAnn  = varAnn / 2.0                 // drag as a fraction / yr
float dragYr   = dragAnn * 100.0              // drag % / yr  (the headline)
float dragRank = ta.percentrank(dragAnn, pctLen)

// ═════════════════════════ EMPIRICAL DRAG + CUMULANT DECOMPOSITION ══════════════════════════════
// realised (arithmetic − geometric) growth — the total realised drag
float gross     = close / close[1]
float arithG    = ta.sma(gross, empLen)
float geoG      = math.exp(ta.sma(math.log(gross), empLen))
float empDragBar= arithG - geoG               // ≈ κ2/2 + κ3/6 + κ4/24 + … per bar
float empDragAnn= empDragBar * barsPerYear     // fraction / yr
float empDragYr = empDragAnn * 100.0
// central moments of the log return over the same window → cumulant pieces of the drag
float muX   = ta.sma(lrcc, empLen)
float dev   = lrcc - muX
float m2    = ta.sma(dev * dev, empLen)                 // κ2 = variance
float m3    = ta.sma(dev * dev * dev, empLen)           // κ3 = 3rd central moment
float m4    = ta.sma(dev * dev * dev * dev, empLen)     // 4th central moment
float k4    = m4 - 3.0 * m2 * m2                         // κ4 = excess-kurtosis cumulant
float varDragYr  = (m2 / 2.0)  * barsPerYear * 100.0    // variance drag  (Gaussian term)
float skewDragYr = (m3 / 6.0)  * barsPerYear * 100.0    // skew drag  (<0 if positively skewed)
float kurtDragYr = (k4 / 24.0) * barsPerYear * 100.0    // tail (kurtosis) drag  (>0 for fat tails)
float tailDragYr = skewDragYr + kurtDragYr              // non-Gaussian portion → EXP_TailDrag
float decompYr   = varDragYr + skewDragYr + kurtDragYr  // ≈ empDragYr (consistency check)
// compare REALISED drag to its OWN Gaussian (variance) part — the excess IS the skew+tail the
// decomposition quantifies. (Comparing to the Yang-Zhang drag instead would let mere estimator
// disagreement masquerade as fat tails; comparing like-with-like keeps the flag honest.)
float divRatio  = (varDragYr > 0 and not na(empDragYr)) ? empDragYr / varDragYr : na
bool  fatTail   = empOn and not na(divRatio) and divRatio >= divThr

// ═════════════════════════ LEVERAGE CURVE (conditional on YOUR edge) ════════════════════════════
float mu    = edgePct / 100.0
float Lbe   = (varAnn > 0 and mu > 0) ? 2.0 * mu / varAnn : na    // break-even: g(L)=0
float Lkel  = (varAnn > 0 and mu > 0) ? mu / varAnn : na          // Kelly optimum
float Lhalf = na(Lkel) ? na : Lkel / 2.0
float dragA = levA * levA * dragYr                                // drag % at each leverage (quadratic)
float dragB = levB * levB * dragYr
float dragC = levC * levC * dragYr

// ═════════════════════════ REGIME FLAGS ═════════════════════════════════════════════════════════
// high-drag with HYSTERESIS: turns ON at the ON percentile, stays on until drag falls below the OFF
// percentile — so the zone doesn't flicker on/off bar-to-bar in choppy tape.
float onThr  = hiDragThr
float offThr = math.min(hiDragOff, hiDragThr - 1.0)
var bool hiDrag = false
if not na(dragRank)
    hiDrag := hiDrag ? (dragRank >= offThr) : (dragRank >= onThr)
// cheap / calm regime with its own hysteresis (mirror of high-drag): on ≤20, stays on until >35
var bool loDrag = false
if not na(dragRank)
    loDrag := loDrag ? (dragRank <= 35.0) : (dragRank <= 20.0)
bool cheap   = not na(dragRank) and dragRank <= 20.0
bool expensv = not na(dragRank) and dragRank >= 80.0

// ═════════════════════════ PLOTS ════════════════════════════════════════════════════════════════
bool  oscView = paneView == "Percentile oscillator (0-100)"
color dragCol = na(dragRank) ? color.gray : color.from_gradient(dragRank, 0.0, 100.0, colCheap, colExp)
// faint regime bands in the pane (cheap green / expensive red) — RSI-style OB/OS shading in oscillator view
bgcolor(showBands and expensv ? color.new(colExp, 90) : showBands and cheap ? color.new(colCheap, 90) : na, title = "Regime band")

// —— Percentile-oscillator view (0-100, familiar RSI-like: cheap<20, expensive>80, midline 50) ——
plot(oscView ? 80.0 : na, "Expensive line (80)", color = color.new(colExp, 45),    linewidth = 1)
plot(oscView ? 50.0 : na, "Midline (50)",        color = color.new(color.gray, 55), linewidth = 1)
plot(oscView ? 20.0 : na, "Cheap line (20)",     color = color.new(colCheap, 45),   linewidth = 1)
plot(oscView ? dragRank : na, "Drag percentile", color = dragCol, linewidth = 2)

// —— Absolute drag %/yr view ——
plot(oscView ? na : dragYr, "Drag %/yr", color = dragCol, linewidth = 2)
plot(oscView or not showLevCurve ? na : dragB, "Drag at Lev B", color = color.new(colExp, 45), linewidth = 1)
plot(oscView or not showLevCurve ? na : dragC, "Drag at Lev C", color = color.new(colExp, 70), linewidth = 1)
plot(oscView or not (showEmp and empOn) ? na : empDragYr, "Empirical drag %/yr", color = color.new(colEmp, 0), linewidth = 1)
hline(0, "Zero", color = color.new(color.gray, 60))

// ═══════════ PRICE-CHART REGIME — direction-agnostic risk context, NOT a bull/bear signal ══════════
bool markRibbon = priceMark == "Bottom ribbon"
bool markBg     = priceMark == "Background (high-drag)"
bool markBar    = priceMark == "Colour candles (high-drag)"
// continuous heat-strip along the BOTTOM of the price pane: cheap/calm → expensive/stressed (both sides)
color cLo    = ribbonBold ? color.new(colCheap, 0) : color.new(colCheap, 30)
color cHi    = ribbonBold ? color.new(colExp,   0) : color.new(colExp,   20)
color ribCol = na(dragRank) ? na : color.from_gradient(dragRank, 0.0, 100.0, cLo, cHi)
plotchar(markRibbon, "Regime ribbon (price)", "█", location.bottom, ribCol, size = size.small, force_overlay = true)
// optional high-drag-only callouts
bgcolor(markBg and hiDrag ? color.new(colExp, 88) : na, title = "High-drag zone (price)", force_overlay = true)
barcolor(markBar and hiDrag ? color.new(colExp, 15) : na, title = "High-drag candles")
// regime-change triangles: cheap = green ▲ below price, expensive = red ▼ above price. Debounced, entry-only.
bool expEntry = hiDrag and not hiDrag[1]
bool chpEntry = loDrag and not loDrag[1]
plotshape(showTri and expEntry, "Entered expensive regime", shape.triangledown, location.abovebar, color.new(colExp, 0),   size = size.tiny, force_overlay = true)
plotshape(showTri and chpEntry, "Entered cheap regime",     shape.triangleup,   location.belowbar, color.new(colCheap, 0), size = size.tiny, force_overlay = true)

// ═════════════════════════ THEME (background-adaptive) ══════════════════════════════════════════
f_lum(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
bool darkUI   = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color cCheap2 = darkUI ? colCheap : color.rgb(14, 124, 90)
color cExp2   = darkUI ? colExp   : color.rgb(198, 40, 64)

f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

// ═════════════════════════ DASHBOARD ═══════════════════════════════════════════════════════════
bool isPro = panelMode == "Pro"
var table t = table.new(f_pos(panelPos), 2, 14, frame_width = 1, border_width = 1)
f_row(int r, string k, string v, color vc, color bg) =>
    table.cell(t, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, v, text_color = vc,     text_size = size.small, text_halign = text.align_right, bgcolor = bg)

if showPanel and barstate.islast
    table.set_bgcolor(t, panelBg)
    table.set_frame_color(t, frameC)
    table.set_border_color(t, frameC)
    color hdrBg  = na(dragRank) ? color.gray : color.from_gradient(dragRank, 0.0, 100.0, colCheap, colExp)
    color hdrTxt = f_lum(hdrBg) > 140 ? color.rgb(10, 10, 10) : color.white
    string headline = na(dragYr) ? "warming" : str.tostring(dragYr, "0.0") + "%/yr · " + str.tostring(dragRank, "0") + "%ile"
    string beTxt = na(Lbe) ? "set an edge" : "negative beyond " + str.tostring(Lbe, "0.0") + "×"
    string estTxt = estMode == "Yang-Zhang" ? "Yang-Zhang" : estMode == "Close-to-close" ? "Close-to-close" : estMode == "Parkinson" ? "Parkinson" : estMode == "Garman-Klass" ? "Garman-Klass" : "Rogers-Satchell"
    string smTxt  = (useEwma ? "EWMA" : "Simple") + " · span " + str.tostring(volLen, "0")
    string divTxt = not empOn ? "off" : na(divRatio) ? "warming" : str.tostring(empDragYr, "0.0") + "% vs " + str.tostring(varDragYr, "0.0") + "%  (×" + str.tostring(divRatio, "0.00") + (fatTail ? " ⚠ fat tails" : "") + ")"
    color  divCol = (not empOn or na(divRatio)) ? txtMut : fatTail ? cExp2 : txtMain
    string decTxt = na(decompYr) ? "warming" : "σ² " + str.tostring(varDragYr, "0.00") + " · skw " + str.tostring(skewDragYr, "0.00") + " · tail " + str.tostring(kurtDragYr, "0.00")
    color  decCol = na(decompYr) ? txtMut : fatTail ? cExp2 : txtMain

    table.cell(t, 0, 0, "VOL DRAG", text_color = hdrTxt, bgcolor = hdrBg, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 0, headline, text_color = hdrTxt, bgcolor = hdrBg, text_size = size.small, text_halign = text.align_right)
    f_row(1, "Drag (hold cost)", na(dragYr) ? "warming" : str.tostring(dragYr, "0.0") + " %/yr", dragRank >= 80 ? cExp2 : dragRank <= 20 ? cCheap2 : txtMain, rowAlt)
    f_row(2, "Percentile", na(dragRank) ? "—" : str.tostring(dragRank, "0") + "th  (" + (dragRank >= 80 ? "expensive" : dragRank <= 20 ? "cheap" : "normal") + ")", dragRank >= 80 ? cExp2 : dragRank <= 20 ? cCheap2 : txtMain, panelBg)
    f_row(3, "At " + str.tostring(levB, "0.##") + "× costs", na(dragB) ? "—" : str.tostring(dragB, "0.0") + " %/yr", cExp2, rowAlt)
    f_row(4, "Break-even leverage", beTxt, na(Lbe) ? txtMut : txtMain, panelBg)
    if isPro
        f_row(5, "At " + str.tostring(levA, "0.##") + "× costs", na(dragA) ? "—" : str.tostring(dragA, "0.0") + " %/yr", txtMain, rowAlt)
        f_row(6, "At " + str.tostring(levC, "0.##") + "× costs", na(dragC) ? "—" : str.tostring(dragC, "0.0") + " %/yr", cExp2, panelBg)
        f_row(7, "Kelly / half-Kelly", na(Lkel) ? "set an edge" : str.tostring(Lkel, "0.0") + "× / " + str.tostring(Lhalf, "0.0") + "×", na(Lkel) ? txtMut : txtMain, rowAlt)
        f_row(8, "Realised vs Gaussian", divTxt, divCol, panelBg)
        f_row(9, "Drag split (%/yr)", decTxt, decCol, rowAlt)
        f_row(10, "Annualised σ", na(sigAnn) ? "—" : str.tostring(sigAnn * 100.0, "0.0") + " %", txtMain, panelBg)
        f_row(11, "Estimator / smoothing", estTxt + " · " + smTxt, txtSub, rowAlt)
        f_row(12, "Note", "no drift estimated · not advice", txtMut, panelBg)
    else
        f_row(5, "Realised vs Gaussian", divTxt, divCol, rowAlt)
        f_row(6, "Drag split (%/yr)", decTxt, decCol, panelBg)
        f_row(7, "Note", "cost of holding · not advice", txtMut, rowAlt)

// ═════════════════════════ EXPORTS (Data Window) ═══════════════════════════════════════════════
color exC = color.new(color.gray, 100)
plot(dragYr,     "EXP_Drag",      exC, display = display.data_window)   // drag % / yr
plot(dragRank,   "EXP_DragPct",   exC, display = display.data_window)   // percentile 0-100
plot(Lbe,        "EXP_LevBE",     exC, display = display.data_window)   // break-even leverage (na if no edge)
plot(Lkel,       "EXP_LevKelly",  exC, display = display.data_window)   // Kelly leverage (na if no edge)
plot(empDragYr,  "EXP_DragEmp",   exC, display = display.data_window)   // empirical drag % / yr
plot(tailDragYr, "EXP_TailDrag",  exC, display = display.data_window)   // non-Gaussian (skew+kurtosis) drag % / yr

// ═════════════════════════ ALERTS ═══════════════════════════════════════════════════════════════
// ta.crossunder is stateful — hoist it so it runs every bar (Lbe is na until an edge is set), then gate.
bool beCross = ta.crossunder(Lbe, levA)
alertcondition(ta.crossover(dragRank, 90.0),  "Drag entered top decile",    "Vol Drag: holding cost entered its top decile — an expensive time to hold exposure.")
alertcondition(ta.crossunder(dragRank, 10.0), "Drag entered bottom decile", "Vol Drag: holding cost entered its bottom decile — a cheap time to hold exposure.")
alertcondition(fatTail and not fatTail[1],    "Fat-tail divergence",        "Vol Drag: empirical drag exceeds the Gaussian estimate — fat tails, true drag is understated.")
alertcondition(not na(Lbe) and beCross,       "Leverage crossed break-even", "Vol Drag: break-even leverage fell below your Leverage A — at this volatility your leverage is now growth-negative.")
````
