# Adaptive Structural Trail  Order Flow, Imbalance & Regime

- url: https://www.tradingview.com/script/QNbvgqte-Adaptive-Structural-Trail-Order-Flow-Imbalance-Regime/
- type: indicator
- pine_id: PUB;8b38977ab47145f18af777bb48205769
- version: 3.0

## Description

Adaptive Structural Trail — Order Flow, Imbalance & Regime

What it is

Adaptive Structural Trail is a single, self-contained market-structure framework that re-clocks the chart by participation instead of time, marks the imbalances that real activity leaves behind, lets order flow decide which of those levels still matter, asks a regime filter whether trending behaviour can be trusted right now, and trails the strongest surviving level as an adaptive stop — all summarised in a plain-language dashboard that tells you, at a glance, whether the picture says ride, wait, or stand aside.

It is designed to be market-agnostic: every raw input (price, volume, and the volatility-index reference) is user-selectable, so the same logic runs on index futures, equities, FX, crypto or commodities without touching the code. Defaults are set for NIFTY index futures; change the volatility symbol and (if needed) the volume source for other instruments.

Why the components are combined (this is one tool, not a bundle)

Each layer measures a different facet of one process — activity creating structure, structure decaying or being defended, and a regime deciding whether to act. They are not independent indicators stacked for visual effect; remove any one and the others lose their meaning:


Delta clock (the substrate). A virtual bar closes only when cumulative signed volume becomes statistically significant (σ × a multiplier). Every downstream reading is therefore spaced by participation, not by the clock — a quiet 10 minutes and a violent 10 seconds are treated differently, which is the whole point.

Imbalance / fair-value-gap detection runs on those virtual bars, so a level is recorded only where genuine activity gapped price, not on arbitrary time bars.

Order-flow lifecycle (charge → decay → breaker/dead). When price returns to a level, delta adjudicates the outcome: absorbed-and-defended levels are reborn as breakers; levels that are surged through are killed. Flow decides what structure survives.

Regime gate (efficiency ratio + volatility burst). This routes everything. The trail is shown and signals arm only where trend behaviour is statistically credible; in range/transition/high-volatility states the tool deliberately stands aside.

Confidence fusion. Structure strength, cumulative-delta slope and flow toxicity (VPIN) are blended into one confidence number, which the dashboard converts into a plain instruction.


That coupling — a volume-significance clock feeding imbalance detection whose survival is adjudicated by order flow and gated by regime, fused into a single trailing level and a decision read-out — is the original contribution here.

How to use it


Add it to any liquid instrument. It is built for intraday timeframes (1–15 min is the sweet spot on index futures).

Read the dashboard top-down: the ACTION banner is the headline (e.g. LONG · ride the trail, RANGE · stand aside). Below it: bias + confidence, market state, the actual trail-stop price, order flow, flow toxicity, volatility context, and a plain "what to do" line.

Treat the coloured trail as a structure-based stop while the market state is a trend; when the state leaves trend, the trail disappears by design.

The imbalance zones show where unfilled activity sits; fresh, tapped and breaker levels are colour-coded (see the on-chart legend).

Edge-calibration panel (bottom-right): for transparency it scores past signals against a regime-matched base rate and reports EDGE = Hit − Base with a 95% confidence interval. Read the Edge column, not the raw hit-rate. This is descriptive of the past on your symbol — not a backtest and not a forward guarantee.

Key-info panel (top-left): instrument, timeframe, the live data source (see honesty note), threshold, ATR and level counts.


Honest note on data (please read)

TradingView exposes no true tick-by-tick aggressor delta and cannot build custom bars, so delta here is a proxy: signed intrabar volume taken from the finest lower timeframe your data plan returns — 1-second where available, otherwise 1-minute — falling back to bar-shape when no lower-timeframe data exists. The live source is shown as "Delta source" in the Key-info panel, so you always know which mode is active. Non-repaint: the delta clock advances and structure/regime/signals resolve only on confirmed bars; the trail line itself updates within the forming bar as a current estimate.

Originality

The novelty is the synthesis and coupling, not any single classical block. A participation clock is used to gate imbalance detection; order flow is used to adjudicate level survival; regime is used to route the entire read; and the whole thing collapses into one trailing level plus a decision dashboard and a self-calibration panel. Every raw input is user-selectable so the framework generalises across markets.

Concept credits

This tool synthesises well-established, publicly documented ideas; credit to their originators:


Information / volume-driven bars & VPIN flow toxicity — Marcos López de Prado; Easley, López de Prado & O'Hara.
Efficiency Ratio (trend vs. noise) — Perry J. Kaufman.
Trade-side classification (tick rule) — Lee & Ready.
Market impact & absorption (square-root law) — Almgren; Tóth & Bouchaud.
Wilson score interval (small-sample proportion CI) — E. B. Wilson.


Imbalance / fair-value-gap and trailing-stop concepts are long-standing, widely used market-structure ideas. The synthesis and the Pine implementation are the author's own.

Exported outputs (for use in other scripts)

Available via input.source() in any other indicator, with clean generic names: Bias Score (signed conviction, ±10), Trail Stop, Trail Direction, Regime State, Confidence, Leading Strength, CVD Slope, Flow Toxicity, Cumulative Delta, Volatility ROC, Volatility Bias.

Disclaimer

For research and education only. This is an analytical tool — not financial advice, not a signal service, and not a guarantee of future results. No indicator has an inherent edge; validate with your own testing, apply realistic costs, and manage risk. You are solely responsible for your trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  ADAPTIVE STRUCTURAL TRAIL  —  Order Flow · Imbalance · Regime            v1.1
//  v1.1 — House-standard pass (no engine change): added the MPL-2.0 header, an EXP_ export bus, and a
//         round-trip COST model. The calibration panel now shows Net R (under a symmetric ±ATR bracket
//         assumption) and exports it. No conditional ta.* — no correctness fix needed.
//  A participation-driven trailing framework for any liquid market.
// -----------------------------------------------------------------------------
//  ONE-LINE IDEA
//    Price alone is noisy. This tool re-clocks the chart by PARTICIPATION, finds
//    the imbalances that real activity leaves behind, lets order flow decide
//    which of those levels still matter, asks a regime filter whether trending
//    behaviour can be trusted right now, and trails the strongest surviving
//    level as an adaptive stop — with a plain-language dashboard that tells a
//    non-technical trader what the picture implies at a glance.
//
//  WHY THESE PARTS BELONG TOGETHER (mashup justification)
//    These are not independent indicators stacked for show; each measures one
//    facet of a SINGLE process — activity creating structure, structure decaying
//    or being defended, and a regime deciding whether to act:
//      1. DELTA CLOCK (substrate) — a virtual bar closes only when cumulative
//         signed volume becomes statistically significant, so every downstream
//         reading is spaced by participation, not by the clock.
//      2. IMBALANCE / FAIR-VALUE-GAP DETECTION runs on those virtual bars, so a
//         level is recorded only where real activity gapped price.
//      3. ORDER-FLOW LIFECYCLE (charge / decay / breaker) uses delta to decide
//         whether a revisited level is absorbed-and-defended (reborn as a
//         breaker) or surged-through (killed) — flow adjudicates structure.
//      4. REGIME GATE (efficiency ratio + volatility burst) routes everything:
//         the trail is shown and entries arm ONLY where trend behaviour is
//         statistically credible; elsewhere it stands aside.
//      5. CONFIDENCE FUSION blends structure strength, CVD slope and flow
//         toxicity (VPIN) into one number the dashboard translates to an action.
//    Remove any one layer and the others lose their meaning, which is why they
//    ship as one script rather than five.
//
//  ORIGINALITY
//    The novel part is the COUPLING: a volume-significance clock feeding imbalance
//    detection whose survival is adjudicated by order flow and gated by regime,
//    fused into a single trailing level and a decision read-out. The framework is
//    market-agnostic — every raw input (price, volume, volatility index) is
//    user-selectable, so it runs on index futures, equities, FX, crypto or
//    commodities without code changes.
//
//  HONEST LIMITS (please read)
//    TradingView exposes no true tick-by-tick aggressor delta and cannot build
//    custom bars, so DELTA HERE IS A PROXY: intrabar signed volume from the
//    finest lower timeframe your data plan returns (1-second where available,
//    else 1-minute), or bar-shape when no lower-timeframe data exists. The live
//    source is shown in the dashboard as "Data health". NON-REPAINT: the delta
//    clock advances and structure/regime/entries resolve only on CONFIRMED bars;
//    the trail line itself updates within the bar as a current estimate.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Information / volume-driven bars & VPIN flow toxicity — M. López de Prado;
//      Easley, López de Prado & O'Hara.
//    • Efficiency Ratio (trend vs noise) — Perry J. Kaufman.
//    • Trade-side classification (tick rule) — Lee & Ready.
//    • Market impact & absorption (square-root law) — Almgren; Tóth & Bouchaud.
//    • Wilson score interval (small-sample proportion CI) — E. B. Wilson.
//    Imbalance / fair-value-gap and trailing-stop concepts are long-standing,
//    widely used market-structure ideas. Synthesis & Pine implementation are the
//    author's own.
//
//  DISCLAIMER
//    For research and education only. This is an analytical tool, NOT financial
//    advice, NOT a signal service, and NOT a guarantee of future results. No
//    indicator has an inherent edge; validate with your own testing, apply
//    realistic costs, and manage risk. You are solely responsible for your
//    trading decisions.
// =============================================================================
indicator("Adaptive Structural Trail — Order Flow, Imbalance & Regime", "AST",
     overlay = true, max_boxes_count = 500, max_labels_count = 500,
     max_lines_count = 500, max_bars_back = 5000)

// ═════════════════════════ 01 · DATA & DELTA ENGINE ═════════════════════════
g1 = "01 · Data & delta engine"
srcPrice = input.source(close, "Price source", group = g1,
     tooltip = "Raw price the engine reads. Default 'close'. Change only for spreads / custom series.")
srcVol   = input.source(volume, "Volume source", group = g1,
     tooltip = "Raw volume used to build delta. Default 'volume'. For symbols with no native volume, pick a volume-proxy series here.")
useLTF   = input.bool(true, "Build delta from lower-timeframe volume (recommended)", group = g1,
     tooltip = "ON: derive signed delta from intrabar volume at the FINEST resolution your data returns — 1-second where your plan/symbol allow, otherwise 1-minute. OFF: derive delta from each bar's shape (works on every symbol, less precise). Note: true tick-by-tick aggressor delta does not exist in Pine; this is the closest robust proxy. The live source is shown as 'Data health' on the dashboard.")
ltfMode  = input.string("Auto (finest: 1s → 1m)", "Lower-timeframe resolution",
     options = ["Auto (finest: 1s → 1m)", "1 second", "1 minute"], group = g1,
     tooltip = "Auto tries 1-second intrabars first and falls back to 1-minute, then to bar-shape, depending on what your data plan returns.")
thrLen   = input.int(50, "Delta significance length", minval = 5, group = g1,
     tooltip = "Lookback for the delta standard deviation that sets the participation threshold.")
thrMult  = input.float(2.0, "Participation multiplier  (threshold = σ × mult)", step = 0.5, minval = 0.5, group = g1,
     tooltip = "THE MAIN KNOB. A virtual bar closes when cumulative signed volume exceeds σ × this. Lower it if too few levels form / the trail holds flat too long; raise it if the chart is too busy. On 1-minute index futures, 1.5–2.0 is a good start.")
fixedThr = input.float(0.0, "Fixed threshold  (0 = adaptive)", minval = 0.0, group = g1,
     tooltip = "Override the adaptive threshold with a constant. 0 keeps it adaptive (recommended).")

// ═════════════════════════ 02 · STRUCTURE & MEMORY ══════════════════════════
g2 = "02 · Structure & memory"
minGapATR  = input.float(0.25, "Minimum imbalance size  (× ATR)", step = 0.05, minval = 0.0, group = g2,
     tooltip = "Reject micro-gaps. The main cure for level spam. Raise to keep only decisive imbalances.")
impFrac    = input.float(0.40, "Impulse delta to qualify  (× threshold)", step = 0.05, group = g2)
minCharge  = input.float(0.20, "Minimum strength to keep a level", step = 0.05, group = g2)
tapDecay   = input.float(0.25, "Decay on a light touch", step = 0.05, group = g2)
ceDecay    = input.float(0.45, "Decay on a mid-level (50%) touch", step = 0.05, group = g2)
timeDecay  = input.float(0.015, "Per-bar time decay", step = 0.005, group = g2)
breakerChg = input.float(0.92, "Breaker (defended level) strength", step = 0.02, group = g2)
surgeFrac  = input.float(0.55, "Surge-through kills a level  (× threshold)", step = 0.05, group = g2)
absFrac    = input.float(0.40, "Absorption to defend a level  (× threshold)", step = 0.05, group = g2,
     tooltip = "A revisited level must FULLY reclaim AND show opposing delta this large to be reborn as a breaker. Strict, so breakers stay meaningful.")
maxGaps    = input.int(48, "Maximum tracked levels  (memory cap)", minval = 10, maxval = 200, group = g2,
     tooltip = "Hard cap on stored levels. Dead levels are pruned first. Lower = leaner chart on higher timeframes.")

// ═════════════════════════ 03 · ORDER FLOW ══════════════════════════════════
g3 = "03 · Order flow (confidence inputs)"
cvdSlopeLen = input.int(5,  "CVD slope length  (virtual bars)", minval = 1, group = g3)
vpinLen     = input.int(20, "Flow-toxicity (VPIN) window", minval = 3, group = g3)
vpinHot     = input.float(0.55, "Flow-toxicity 'hot' threshold", step = 0.05, minval = 0.0, maxval = 1.0, group = g3)

// ═════════════════════════ 04 · REGIME GATE ═════════════════════════════════
g4 = "04 · Regime gate"
regLen   = input.int(14, "Regime window  (virtual bars)", minval = 3, group = g4)
erTrend  = input.float(0.36, "Trend cutoff  (efficiency ratio)", step = 0.02, group = g4)
erRange  = input.float(0.18, "Range cutoff  (efficiency ratio)", step = 0.02, group = g4)
volMult  = input.float(2.5, "High-volatility trigger  (bar move × avg >)", step = 0.1, group = g4)
atrLen   = input.int(14, "ATR length  (scale reference)", minval = 1, group = g4)

// ═════════════════════════ 05 · SIGNALS ═════════════════════════════════════
g5 = "05 · Signals"
showTrades = input.bool(true, "Show entry / exit markers", group = g5)
minConfEnt = input.float(0.55, "Minimum confidence to arm a signal", step = 0.05, minval = 0.0, maxval = 1.0, group = g5,
     tooltip = "Higher = fewer, higher-conviction signals. Lower = more signals. Signals only arm inside a trending regime.")

// ═════════════════════════ 06 · TRAIL & ZONES ═══════════════════════════════
g6 = "06 · Trail & zones"
showTrail  = input.bool(true, "Show adaptive trail", group = g6)
glowOn     = input.bool(true, "Trail glow", group = g6)
showBoxes  = input.bool(true, "Show imbalance zones", group = g6)
distATR    = input.float(6.0, "Hide zones beyond  (× ATR from price)", step = 0.5, group = g6,
     tooltip = "Keeps the chart clean by hiding far-away levels. Lower to show only nearby structure.")
showRegimeBg = input.bool(true, "Regime background tint", group = g6,
     tooltip = "Subtle background colour by regime (green trend-up, red trend-down, neutral range). Turn off for a plain chart.")

// ═════════════════════════ 07 · DASHBOARD & THEME ═══════════════════════════
g7 = "07 · Dashboard & theme"
showDash   = input.bool(true, "Show decision dashboard", group = g7)
showKey    = input.bool(false, "Show key-info panel", group = g7)
showLegend = input.bool(false, "Show colour legend", group = g7)
dashPos    = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g7)
keyPos     = input.string("Top Left", "Key-info panel position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g7)
themeOpt   = input.string("Auto (match chart)", "Theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g7,
     tooltip = "Auto reads the chart background so panels stay readable on any colour scheme.")
colFreshIn = input.color(#3d6cf0, "Fresh",   inline = "cc", group = g7)
colTapIn   = input.color(#8a7bd8, "Tapped",  inline = "cc", group = g7)
colBrkIn   = input.color(#f7c948, "Breaker", inline = "cc", group = g7)

// ═════════════════════════ 08 · VOLATILITY CONTEXT ══════════════════════════
g8 = "08 · Volatility context (implied-vol index)"
vixOn  = input.bool(true, "Use implied-volatility context", group = g8,
     tooltip = "Folds an implied-volatility index into confidence as a risk-on / risk-off tilt. Rising vol = risk-off = penalises longs, favours shorts; falling vol = risk-on = the reverse. Context only — it never votes direction on its own, and auto-disables if the symbol returns no data.")
vixSym = input.symbol("NSE:INDIAVIX", "Volatility-index symbol", group = g8,
     tooltip = "Implied-volatility index for your market. Default NSE:INDIAVIX (for NIFTY). Examples: TVC:VIX (S&P 500), TVC:VXN (Nasdaq-100), TVC:RVX (Russell), or a vol-index future. Change this to match the instrument you trade.")
vixLen   = input.int(20, "Volatility trend length", minval = 2, maxval = 200, group = g8)
vixScale = input.float(20.0, "Volatility sensitivity", minval = 1.0, maxval = 100.0, step = 1.0, group = g8)
vixWeight = input.float(0.6, "Volatility confidence weight", minval = 0.0, maxval = 2.0, step = 0.1, group = g8,
     tooltip = "How strongly the risk-on/off context tilts confidence. 0 = shown but not applied.")

// ═════════════════════════ 09 · EDGE CALIBRATION (advanced) ═════════════════
g9 = "09 · Edge calibration (advanced)"
calEnable  = input.bool(true, "Log signals for calibration", group = g9,
     tooltip = "Scores each past signal after a horizon and compares it to a regime-matched base rate. Descriptive of the PAST on this symbol — NOT a backtest and NOT a forward prediction.")
calShowPanel = input.bool(false, "Show calibration panel", group = g9,
     tooltip = "Reports measured hit-rate vs a direction-matched base rate (EDGE = Hit − Base) with a 95% confidence interval, split Trend vs Range. Read the EDGE column, not the bare hit-rate.")
calPanelPos = input.string("Bottom Right", "Calibration panel position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g9)
calHorizon = input.int(20, "Evaluation horizon  (bars)", minval = 3, maxval = 200, group = g9)
calMoveATR = input.float(1.0, "Follow-through to count a hit  (× ATR)", step = 0.1, minval = 0.1, maxval = 5.0, group = g9)
costR      = input.float(0.30, "Round-trip cost (R) — subtracted for Net R", minval = 0.0, maxval = 3.0, step = 0.05, group = g9,
     tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) in R. NetR assumes a SYMMETRIC bracket: target = stop = the follow-through distance (×ATR). Under that assumption gross R-expectancy = 2·hit% − 1; Net R subtracts this cost. Net R > 0 = the edge is tradeable after costs. The calibration itself only tests the favourable side, so Net R is a labelled what-if, not a measured stop-out. Default 0.30 suits 1m NIFTY futures.")

// ═════════════════════════ 10 · EXTERNAL BIAS (advanced, optional) ══════════
g10 = "10 · External bias (advanced, optional)"
extBiasOn = input.bool(false, "Blend an external bias score", group = g10,
     tooltip = "OFF by default — needs wiring. Plot any indicator that EXPORTS a bias score, then connect its output below. The engine will fold it into confidence and require it to agree before arming a signal. Leave OFF unless you have such a source connected.")
extRaw    = input.source(close, "External bias score (connect a plotted output)", group = g10)
extScale  = input.float(10.0, "External score full-scale (±)", step = 1.0, minval = 1.0, group = g10,
     tooltip = "The value at which the connected score is considered fully bullish/bearish.")

// ───────────────────────── PALETTE / THEME (house style) ────────────────────
var color COL_BULL = #2ebd85
var color COL_BEAR = #f6465d
var color COL_MID  = #f7c948
var color COL_INFO = #3d6cf0

f_lumaDark(color c) =>
    na(c) ? true : (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) < 128

bool isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lumaDark(chart.bg_color)
color txtCol  = isDark ? color.new(#e8e8ea, 0) : color.new(#1a1a1a, 0)
color dimCol  = isDark ? color.new(#9aa0aa, 0) : color.new(#5a5f66, 0)
color zebraA  = isDark ? color.new(#1c2030, 18) : color.new(#eef1f6, 18)
color zebraB  = isDark ? color.new(#141826, 18) : color.new(#f8fafc, 18)
color frameCl = isDark ? color.new(#2a3142, 0)  : color.new(#c8cdd6, 0)

f_dashPos() =>
    switch dashPos
        "Top Right"     => position.top_right
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        => position.top_left

f_meter(float v) =>
    int filled = na(v) ? 0 : int(math.max(0, math.min(8, math.round(v * 8))))
    string s = ""
    for i = 1 to 8
        s += i <= filled ? "█" : "░"
    s

f_logistic(float x) =>
    1.0 / (1.0 + math.exp(-x))

// 95% Wilson score interval for a proportion -> [lo, hi] in [0,1]; [na,na] if N<5
f_score_ci(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p   = hits / float(total)
        float z   = 1.96
        float den = 1.0 + z * z / total
        float c   = (p + z * z / (2.0 * total)) / den
        float h   = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, c - h)
        hi := math.min(1.0, c + h)
    [lo, hi]

// effective visibility flags
bool effBoxes  = showBoxes
bool effLegend = showLegend
bool effBg     = showRegimeBg
bool effTrades = showTrades

// ───────────────────────── DELTA ENGINE (finest available) ──────────────────
// Signed intrabar volume from the finest lower timeframe the data plan returns:
// 1-second where available, else 1-minute; bar-shape as a universal fallback.
// True tick aggressor delta is not available in Pine — this is the closest proxy.
ltfExpr  = srcPrice > srcPrice[1] ? srcVol : srcPrice < srcPrice[1] ? -srcVol : 0.0
arrSec   = request.security_lower_tf(syminfo.tickerid, "1S", ltfExpr)
arrMin   = request.security_lower_tf(syminfo.tickerid, "1",  ltfExpr)
bool secOk = array.size(arrSec) > 0
bool minOk = array.size(arrMin) > 0

float ltfDelta = na
int   ltfUsed  = 0                     // 0 bar-shape · 1 = 1-second · 2 = 1-minute
if useLTF
    if ltfMode == "1 minute"
        if minOk
            ltfDelta := array.sum(arrMin)
            ltfUsed  := 2
    else
        if secOk
            ltfDelta := array.sum(arrSec)
            ltfUsed  := 1
        else if minOk
            ltfDelta := array.sum(arrMin)
            ltfUsed  := 2

float barRange = high - low
float polDelta = barRange > 0 ? srcVol * ((close - low) - (high - close)) / barRange : 0.0
float barDelta = (useLTF and not na(ltfDelta)) ? ltfDelta : polDelta
barDelta := na(barDelta) ? 0.0 : barDelta
string dataMode = ltfUsed == 1 ? "1-sec volume" : ltfUsed == 2 ? "1-min volume" : (useLTF ? "bar shape (no LTF)" : "bar shape")

float dynStd    = ta.stdev(barDelta, thrLen)
float atrVal    = ta.atr(atrLen)
float threshold = fixedThr > 0 ? fixedThr : (na(dynStd) ? na : math.max(dynStd * thrMult, 1.0))

// external bias (optional)
float extNorm = extBiasOn ? math.max(-1.0, math.min(1.0, extRaw / extScale)) : na
bool extOkLong  = not extBiasOn or (not na(extNorm) and extNorm > -0.2)
bool extOkShort = not extBiasOn or (not na(extNorm) and extNorm <  0.2)

// VIX volatility context (optional). request.security is called unconditionally
// at top level (no security call inside a ternary); the toggle only selects it.
float vixSrc = request.security(vixSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float vixRaw = vixOn ? vixSrc : na
bool  vixOk  = vixOn and not na(vixRaw) and not na(vixRaw[vixLen]) and vixRaw[vixLen] != 0
float vixRoc = vixOk ? (vixRaw - vixRaw[vixLen]) / vixRaw[vixLen] : na
// +1 = risk-on (VIX falling), −1 = risk-off (VIX rising); context only, no direction vote
float vixBias = na(vixRoc) ? 0.0 : -math.max(-1.0, math.min(1.0, vixRoc * vixScale))

// ───────────────────────── GAP OBJECT + METHODS ─────────────────────────────
// st: 0 fresh · 1 tapped · 2 breaker · 3 dead
type Gap
    int   id
    bool  bull
    float top
    float bottom
    int   birthBar
    int   sbi
    float charge
    int   st
    box   bx

method ce(Gap g) =>
    (g.top + g.bottom) / 2.0

method adjudicate(Gap g, float vH, float vL, float vC, float rd, float surgeT, float absT, float tapD, float ceD, float brkChg) =>
    string verdict = ""
    float c_ce = g.ce()
    if g.bull
        if vL <= g.top
            if vL <= g.bottom
                if vC < g.bottom and rd <= -surgeT
                    g.st := 3
                    g.charge := 0.0
                    verdict := "dead"
                else if vC > g.top and rd >= absT
                    g.st := 2
                    g.charge := brkChg
                    verdict := "breaker"
                else
                    g.st := 1
                    g.charge := math.max(0.0, g.charge - ceD)
            else
                g.charge := math.max(0.0, g.charge - (vL <= c_ce ? ceD : tapD))
                g.st := g.st == 0 ? 1 : g.st
    else
        if vH >= g.bottom
            if vH >= g.top
                if vC > g.top and rd >= surgeT
                    g.st := 3
                    g.charge := 0.0
                    verdict := "dead"
                else if vC < g.bottom and rd <= -absT
                    g.st := 2
                    g.charge := brkChg
                    verdict := "breaker"
                else
                    g.st := 1
                    g.charge := math.max(0.0, g.charge - ceD)
            else
                g.charge := math.max(0.0, g.charge - (vH >= c_ce ? ceD : tapD))
                g.st := g.st == 0 ? 1 : g.st
    verdict

// ───────────────────────── PERSISTENT STATE (one per line) ──────────────────
var float runDelta = 0.0
var float vO = na
var float vH = na
var float vL = na
var float vV = 0.0
var int   vTicks = 0
var float cvd = 0.0

var array<float> sH    = array.new<float>()
var array<float> sL    = array.new<float>()
var array<float> sC    = array.new<float>()
var array<float> sDlt  = array.new<float>()
var array<float> sVol  = array.new<float>()
var array<float> sCVD  = array.new<float>()
var array<Gap>   gaps  = array.new<Gap>()
var int gid = 0

var float trailVal   = na
var int   trailDir   = 0
var float leadCharge = na
var int   regime     = 0      // 1 up · -1 down · 0 range · 2 transition · 3 high-vol
var float cvdSlope   = 0.0
var float vpin       = 0.0
var float conf       = 0.0
var int   liveGaps   = 0
var int   liveBrk    = 0
var int   lastSbTicks = 0

var bool entLong = false
var bool entShort = false
var bool exitSig = false
var bool inLong = false
var bool inShort = false
var float stopLvl = na

// ---- calibration state (bucket 0 = Trend regime, 1 = Range/Other at fire) ----
var int[]   calTot = array.new_int(2, 0)
var int[]   calHit = array.new_int(2, 0)
var int[]   calUp  = array.new_int(2, 0)   // events expecting up (for matched base)
var int[]   calDn  = array.new_int(2, 0)
var int[]   pgBar  = array.new_int(0)
var float[] pgPx   = array.new_float(0)
var float[] pgAtr  = array.new_float(0)
var int[]   pgDir  = array.new_int(0)
var int[]   pgBkt  = array.new_int(0)
// direction-matched base sampler (identical horizon + net-move test), per bucket
var int[]   baseN  = array.new_int(2, 0)
var int[]   baseUp = array.new_int(2, 0)
var int[]   baseDn = array.new_int(2, 0)
var int[]   bqBar  = array.new_int(0)
var float[] bqPx   = array.new_float(0)
var float[] bqAtr  = array.new_float(0)
var int[]   bqBkt  = array.new_int(0)

var label leadLbl = na

// ───────────────────────── VIRTUAL BAR BUILD (confirmed-bar only) ────────────
// The delta clock advances and synthetic bars close ONLY on confirmed bars, so
// the substrate, gap detection and lifecycle never repaint on the forming bar.
// The trail LINE below still re-reads every bar (live estimate); committed
// structure does not move until the bar closes.
bool barOk = barstate.isconfirmed
if barOk
    if na(vO)
        vO := open
        vH := high
        vL := low
    else
        vH := math.max(vH, high)
        vL := math.min(vL, low)
    runDelta += barDelta
    vV += nz(srcVol)
    vTicks += 1
float vC = close

bool sbClosed = barOk and not na(threshold) and threshold > 0 and math.abs(runDelta) >= threshold

// reset per-bar signal flags
entLong := false
entShort := false
exitSig := false

// ───────────────────────── ON SYNTHETIC-BAR CLOSE (structure only) ───────────
if sbClosed
    array.push(sH, vH)
    array.push(sL, vL)
    array.push(sC, vC)
    array.push(sDlt, runDelta)
    array.push(sVol, vV)
    cvd += runDelta
    array.push(sCVD, cvd)
    int n   = array.size(sH)
    int sbi = n - 1
    float surgeT = surgeFrac * threshold
    float absT   = absFrac   * threshold

    // ---- FVG detection (no lookahead; 3 closed synthetic bars) + quality gate ----
    if n >= 3
        float aH = array.get(sH, n - 3)
        float aL = array.get(sL, n - 3)
        float cH = array.get(sH, n - 1)
        float cL = array.get(sL, n - 1)
        float impD = math.abs(array.get(sDlt, n - 2))
        bool impulseOK = impD >= impFrac * threshold
        float minSize = minGapATR * atrVal
        if cL > aH and (cL - aH) >= minSize and impulseOK
            gid += 1
            array.push(gaps, Gap.new(gid, true, cL, aH, bar_index, sbi, 1.0, 0, na))
        else if cH < aL and (aL - cH) >= minSize and impulseOK
            gid += 1
            array.push(gaps, Gap.new(gid, false, aL, cH, bar_index, sbi, 1.0, 0, na))

    // ---- lifecycle update vs THIS synthetic bar ----
    for g in gaps
        if g.st != 3 and sbi > g.sbi
            g.adjudicate(vH, vL, vC, runDelta, surgeT, absT, tapDecay, ceDecay, breakerChg)
            g.charge := math.max(0.0, g.charge - timeDecay)
            if g.charge <= 0.0 and g.st != 2
                g.st := 3

    // ---- regime: efficiency ratio + relative-move vol (5 states) ----
    if n > regLen
        float netv = array.get(sC, n - 1) - array.get(sC, n - 1 - regLen)
        float path = 0.0
        for k = n - regLen to n - 1
            path += math.abs(array.get(sC, k) - array.get(sC, k - 1))
        float er = path > 0 ? math.abs(netv) / path : 0.0
        float lastRet   = math.abs(array.get(sC, n - 1) - array.get(sC, n - 2))
        float avgAbsRet = path / regLen
        float volZ = avgAbsRet > 0 ? lastRet / avgAbsRet : 0.0
        if volZ > volMult
            regime := 3
        else if er >= erTrend
            regime := netv > 0 ? 1 : -1
        else if er <= erRange
            regime := 0
        else
            regime := 2

    // ---- CVD slope ----
    if n > cvdSlopeLen
        cvdSlope := array.get(sCVD, n - 1) - array.get(sCVD, n - 1 - cvdSlopeLen)

    // ---- VPIN-lite flow toxicity ----
    if n >= vpinLen
        float sd = 0.0
        float sv = 0.0
        for k = n - vpinLen to n - 1
            sd += math.abs(array.get(sDlt, k))
            sv += array.get(sVol, k)
        vpin := sv > 0 ? sd / sv : 0.0

    lastSbTicks := vTicks

    // ---- prune dead gaps (downward loop is removal-safe) ----
    if array.size(gaps) > maxGaps
        for i = array.size(gaps) - 1 to 0
            if array.size(gaps) > maxGaps and i < array.size(gaps)
                Gap gg = array.get(gaps, i)
                if gg.st == 3
                    if not na(gg.bx)
                        box.delete(gg.bx)
                    array.remove(gaps, i)

    // ---- reset virtual bar ----
    runDelta := 0.0
    vO := na
    vV := 0.0
    vTicks := 0

// ───────────────────────── EVERY BAR: TRAIL · CONFIDENCE · TRADES ────────────
// Recomputed every chart bar so the trail ratchets smoothly and clears the
// instant the live regime leaves trend (this is the v2.1 fix).
float bestSup = na
float supChg  = na
float bestRes = na
float resChg  = na
int lg = 0
int lb = 0
for g in gaps
    if g.st != 3
        lg += 1
        if g.st == 2
            lb += 1
        if g.charge >= minCharge
            float gce = g.ce()
            if g.bull and gce < close and (na(bestSup) or gce > bestSup)
                bestSup := gce
                supChg  := g.charge
            if (not g.bull) and gce > close and (na(bestRes) or gce < bestRes)
                bestRes := gce
                resChg  := g.charge
liveGaps := lg
liveBrk  := lb

if regime == 1
    trailVal := bestSup
    leadCharge := supChg
    trailDir := 1
else if regime == -1
    trailVal := bestRes
    leadCharge := resChg
    trailDir := -1
else
    trailVal := na
    leadCharge := na
    trailDir := 0

// confidence fusion (lightweight log-odds)
float lo = 0.0
lo += na(leadCharge) ? -1.0 : (leadCharge - 0.5) * 3.0
lo += (regime == 1 or regime == -1) ? 1.0 : (regime == 2 ? -0.5 : -1.2)
float cvdAgree = trailDir == 1 ? math.sign(cvdSlope) : trailDir == -1 ? -math.sign(cvdSlope) : 0.0
lo += cvdAgree * 0.9
lo -= vpin > vpinHot ? 1.1 : 0.0
float extAlign = (extBiasOn and not na(extNorm) and trailDir != 0) ? trailDir * extNorm : 0.0
lo += extAlign * 0.9
// VIX context: a long in a risk-on (falling-VIX) tape is rewarded; into rising VIX, penalised
float vixAlign = (vixOn and not na(vixRoc) and trailDir != 0) ? trailDir * vixBias : 0.0
lo += vixAlign * vixWeight
conf := f_logistic(lo)

// trades — resolved on confirmed bars only (non-repaint). Entries arm on a fresh
// synthetic close; exits are checked each confirmed bar against the live stop.
if effTrades and barOk
    if not inLong and not inShort
        if sbClosed and regime == 1 and not na(trailVal) and conf >= minConfEnt and cvdSlope > 0 and extOkLong
            inLong := true
            stopLvl := trailVal
            entLong := true
        else if sbClosed and regime == -1 and not na(trailVal) and conf >= minConfEnt and cvdSlope < 0 and extOkShort
            inShort := true
            stopLvl := trailVal
            entShort := true
    else if inLong
        if not na(trailVal)
            stopLvl := math.max(stopLvl, trailVal)
        if close < stopLvl or regime != 1
            inLong := false
            exitSig := true
            stopLvl := na
    else if inShort
        if not na(trailVal)
            stopLvl := math.min(stopLvl, trailVal)
        if close > stopLvl or regime != -1
            inShort := false
            exitSig := true
            stopLvl := na

// ───────────────────────── CALIBRATION (past-only, regime-split) ─────────────
// Logs each armed entry, resolves it after the horizon (net move >= calMoveATR x
// ATR in the entry direction = hit), and measures a DIRECTION-MATCHED base rate
// by the identical net-move test on an unconditional sample. EDGE = Hit - Base.
// Bucket 0 = Trend regime at fire, 1 = Range/Other. Confirmed bars only.
if calEnable and barOk and not na(atrVal) and atrVal > 0
    int fireBkt = (regime == 1 or regime == -1) ? 0 : 1
    if entLong
        array.push(pgBar, bar_index)
        array.push(pgPx, close)
        array.push(pgAtr, atrVal)
        array.push(pgDir, 1)
        array.push(pgBkt, fireBkt)
    if entShort
        array.push(pgBar, bar_index)
        array.push(pgPx, close)
        array.push(pgAtr, atrVal)
        array.push(pgDir, -1)
        array.push(pgBkt, fireBkt)

    // resolve pending entry events at horizon
    if array.size(pgBar) > 0
        int i = 0
        while i < array.size(pgBar)
            if bar_index - array.get(pgBar, i) >= calHorizon
                float p0 = array.get(pgPx, i)
                float a0 = array.get(pgAtr, i)
                int   dr = array.get(pgDir, i)
                int   bk = array.get(pgBkt, i)
                float net = close - p0
                bool hit = dr == 1 ? net >= calMoveATR * a0 : net <= -calMoveATR * a0
                array.set(calTot, bk, array.get(calTot, bk) + 1)
                if hit
                    array.set(calHit, bk, array.get(calHit, bk) + 1)
                if dr == 1
                    array.set(calUp, bk, array.get(calUp, bk) + 1)
                else
                    array.set(calDn, bk, array.get(calDn, bk) + 1)
                array.remove(pgBar, i)
                array.remove(pgPx, i)
                array.remove(pgAtr, i)
                array.remove(pgDir, i)
                array.remove(pgBkt, i)
            else
                i += 1

    // unconditional base sampler (one per confirmed bar), resolved the same way
    int sampleBkt = (regime == 1 or regime == -1) ? 0 : 1
    array.push(bqBar, bar_index)
    array.push(bqPx, close)
    array.push(bqAtr, atrVal)
    array.push(bqBkt, sampleBkt)
    if array.size(bqBar) > 0
        int j = 0
        while j < array.size(bqBar)
            if bar_index - array.get(bqBar, j) >= calHorizon
                float bp0 = array.get(bqPx, j)
                float ba0 = array.get(bqAtr, j)
                int   bbk = array.get(bqBkt, j)
                float bnet = close - bp0
                array.set(baseN, bbk, array.get(baseN, bbk) + 1)
                if bnet >= calMoveATR * ba0
                    array.set(baseUp, bbk, array.get(baseUp, bbk) + 1)
                if bnet <= -calMoveATR * ba0
                    array.set(baseDn, bbk, array.get(baseDn, bbk) + 1)
                array.remove(bqBar, j)
                array.remove(bqPx, j)
                array.remove(bqAtr, j)
                array.remove(bqBkt, j)
            else
                j += 1

    // bound memory
    while array.size(pgBar) > 400
        array.shift(pgBar)
        array.shift(pgPx)
        array.shift(pgAtr)
        array.shift(pgDir)
        array.shift(pgBkt)
    while array.size(bqBar) > 600
        array.shift(bqBar)
        array.shift(bqPx)
        array.shift(bqAtr)
        array.shift(bqBkt)

// Net-of-cost R (All buckets, for export) — 2·hit − 1 under a symmetric ±ATR bracket, minus cost.
float calAllTot = array.get(calTot, 0) + array.get(calTot, 1)
float calAllHit = array.get(calHit, 0) + array.get(calHit, 1)
float hitAll    = calAllTot > 0 ? calAllHit / calAllTot : na
float grossRc   = na(hitAll) ? na : 2.0 * hitAll - 1.0
float netRc     = na(grossRc) ? na : grossRc - costR

if effBoxes
    float distLim = distATR * atrVal
    for g in gaps
        bool near = math.abs(g.ce() - close) <= distLim
        bool shouldDraw = g.st != 3 and g.charge >= minCharge and near
        color cc = g.st == 2 ? colBrkIn : g.st == 1 ? colTapIn : colFreshIn
        int tp = g.st == 2 ? 62 : 80
        if shouldDraw and na(g.bx)
            g.bx := box.new(g.birthBar, g.top, bar_index, g.bottom,
                 border_color = color.new(cc, 40), bgcolor = color.new(cc, tp), border_width = 1)
        else if shouldDraw and not na(g.bx)
            box.set_right(g.bx, bar_index)
            box.set_top(g.bx, g.top)
            box.set_bottom(g.bx, g.bottom)
            box.set_bgcolor(g.bx, color.new(cc, tp))
            box.set_border_color(g.bx, color.new(cc, 40))
        else if (not shouldDraw) and not na(g.bx)
            box.delete(g.bx)
            g.bx := na
else
    for g in gaps
        if not na(g.bx)
            box.delete(g.bx)
            g.bx := na

// ───────────────────────── TRAIL (regime-gated triple glow) ─────────────────
color trailBase = trailDir == 1 ? COL_BULL : trailDir == -1 ? COL_BEAR : color.new(color.gray, 60)
int   trailTp   = na(conf) ? 55 : int(math.max(0, math.min(70, math.round(60 - conf * 55))))
color trailCol  = color.new(trailBase, trailTp)
// live-regime gate: only draw in trend, every bar (the fix)
float trailPlot = (showTrail and (regime == 1 or regime == -1)) ? trailVal : na

plot(glowOn ? trailPlot : na, "glow2", color = color.new(trailBase, 86), linewidth = 8, style = plot.style_stepline)
plot(glowOn ? trailPlot : na, "glow1", color = color.new(trailBase, 72), linewidth = 5, style = plot.style_stepline)
plot(trailPlot, "Adaptive Trail", color = trailCol, linewidth = 2, style = plot.style_stepline)

// leading-anchor label
if barstate.islast and showTrail and not na(trailVal)
    if na(leadLbl)
        leadLbl := label.new(bar_index, trailVal, "", style = label.style_label_left,
             color = color.new(trailBase, 20), textcolor = color.white, size = size.small)
    label.set_xy(leadLbl, bar_index, trailVal)
    label.set_text(leadLbl, (trailDir == 1 ? "▲ " : "▼ ") + str.tostring(na(leadCharge) ? 0 : math.round(leadCharge * 100)) + "%")
    label.set_color(leadLbl, color.new(trailBase, 20))

// ───────────────────────── TRADE MARKERS ────────────────────────────────────
plotshape(effTrades and entLong,  "Long entry",  style = shape.triangleup,   location = location.belowbar, color = COL_BULL, size = size.tiny)
plotshape(effTrades and entShort, "Short entry", style = shape.triangledown, location = location.abovebar, color = COL_BEAR, size = size.tiny)
plotshape(effTrades and exitSig,  "Exit",        style = shape.xcross,        location = location.abovebar, color = COL_MID, size = size.tiny)

color regBg = regime == 1 ? color.new(COL_BULL, 95) : regime == -1 ? color.new(COL_BEAR, 95) : regime == 3 ? color.new(COL_MID, 94) : na
bgcolor(effBg ? regBg : na)

// ───────────────────────── DASHBOARD (adaptive zebra) ───────────────────────
f_regTxt(int r) =>
    switch r
        1  => "TREND ↑"
        -1 => "TREND ↓"
        0  => "RANGE / REVERT"
        2  => "TRANSITION"
        => "HIGH VOL"

f_regCol(int r) =>
    switch r
        1  => COL_BULL
        -1 => COL_BEAR
        0  => COL_MID
        2  => color.new(#9aa0aa, 0)
        => COL_MID

f_modeTxt(int r) =>
    switch r
        1  => "Trend-follow (long trail live)"
        -1 => "Trend-follow (short trail live)"
        0  => "Mean-revert / stand aside"
        2  => "Wait for confirmation"
        => "High vol — reduce / stand aside"

// plain-language headline the whole dashboard builds toward
f_action(int r, float cf, float mn) =>
    string a = ""
    color  c = na
    if r == 1 and cf >= mn
        a := "LONG  ·  ride the trail"
        c := COL_BULL
    else if r == -1 and cf >= mn
        a := "SHORT  ·  ride the trail"
        c := COL_BEAR
    else if r == 1 or r == -1
        a := "TREND forming  ·  wait for conviction"
        c := COL_MID
    else if r == 0
        a := "RANGE  ·  fade edges / stand aside"
        c := COL_MID
    else if r == 2
        a := "TRANSITION  ·  wait for confirmation"
        c := color.new(#9aa0aa, 0)
    else
        a := "HIGH VOLATILITY  ·  reduce / stand aside"
        c := COL_BEAR
    [a, c]

// readable text colour for a given (opaque) background colour, any theme
f_txtOn(color bg) =>
    f_lumaDark(bg) ? color.new(#f5f7fa, 0) : color.new(#0d1117, 0)

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(f_dashPos(), 2, 11, border_width = 1, frame_color = frameCl, frame_width = 1)
    string toxTxt = vpin > vpinHot ? "HOT " + str.tostring(math.round(vpin * 100)) + "%" : "calm " + str.tostring(math.round(vpin * 100)) + "%"
    color  toxCol = vpin > vpinHot ? COL_BEAR : dimCol
    string cvdTxt = cvdSlope > 0 ? "buyers ↑" : cvdSlope < 0 ? "sellers ↓" : "balanced"
    color  cvdCol = cvdSlope > 0 ? COL_BULL : cvdSlope < 0 ? COL_BEAR : dimCol
    string vixTxt = not vixOn ? "off" : na(vixRoc) ? "no data" : vixBias > 0.1 ? "risk-on (vol ↓)" : vixBias < -0.1 ? "risk-off (vol ↑)" : "neutral"
    color  vixCol = (not vixOn or na(vixRoc)) ? dimCol : vixBias > 0.1 ? COL_BULL : vixBias < -0.1 ? COL_BEAR : dimCol
    [actTxt, actCol] = f_action(regime, conf, minConfEnt)
    string biasTxt = (regime == 1 and conf >= minConfEnt) ? "LONG" : (regime == -1 and conf >= minConfEnt) ? "SHORT" : "WAIT"
    color  biasCol = biasTxt == "LONG" ? COL_BULL : biasTxt == "SHORT" ? COL_BEAR : dimCol
    string stopTxt = na(trailVal) ? "— (no active trail)" : (trailDir == 1 ? "▲ " : "▼ ") + str.tostring(trailVal, format.mintick)
    color  stopCol = na(trailVal) ? dimCol : trailDir == 1 ? COL_BULL : COL_BEAR

    // row 0 — identity + live data source
    table.cell(dash, 0, 0, "ADAPTIVE STRUCTURAL TRAIL", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(dash, 1, 0, dataMode, text_color = color.new(color.white, 15), text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))

    // row 1 — HEADLINE action (the one line a non-technical user needs)
    table.cell(dash, 0, 1, "ACTION", text_color = f_txtOn(actCol), text_size = size.small, bgcolor = color.new(actCol, 8))
    table.cell(dash, 1, 1, actTxt,   text_color = f_txtOn(actCol), text_size = size.small, bgcolor = color.new(actCol, 8))

    // row 2 — bias + confidence together
    table.cell(dash, 0, 2, "Bias", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 2, biasTxt + "   " + str.tostring(math.round(conf * 100)) + "% conf", text_color = biasCol, text_size = size.tiny, bgcolor = zebraA)

    // row 3 — regime
    table.cell(dash, 0, 3, "Market state", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(dash, 1, 3, f_regTxt(regime), text_color = f_regCol(regime), text_size = size.tiny, bgcolor = zebraB)

    // row 4 — confidence meter
    table.cell(dash, 0, 4, "Confidence", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 4, f_meter(conf) + " " + str.tostring(math.round(conf * 100)) + "%", text_color = conf >= 0.6 ? COL_BULL : conf >= 0.4 ? COL_MID : COL_BEAR, text_size = size.tiny, bgcolor = zebraA)

    // row 5 — the actual trailing-stop price
    table.cell(dash, 0, 5, "Trail stop", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(dash, 1, 5, stopTxt, text_color = stopCol, text_size = size.tiny, bgcolor = zebraB)

    // row 6 — order flow
    table.cell(dash, 0, 6, "Order flow", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 6, cvdTxt, text_color = cvdCol, text_size = size.tiny, bgcolor = zebraA)

    // row 7 — flow toxicity
    table.cell(dash, 0, 7, "Flow toxicity", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(dash, 1, 7, toxTxt, text_color = toxCol, text_size = size.tiny, bgcolor = zebraB)

    // row 8 — volatility context
    table.cell(dash, 0, 8, "Volatility", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 8, vixTxt, text_color = vixCol, text_size = size.tiny, bgcolor = zebraA)

    // row 9 — structure count
    table.cell(dash, 0, 9, "Levels live / breaker", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(dash, 1, 9, str.tostring(liveGaps) + " / " + str.tostring(liveBrk), text_color = txtCol, text_size = size.tiny, bgcolor = zebraB)

    // row 10 — plain guidance
    table.cell(dash, 0, 10, "What to do", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(dash, 1, 10, f_modeTxt(regime), text_color = f_regCol(regime), text_size = size.tiny, bgcolor = zebraA)

// ───────────────────────── KEY-INFO PANEL (technical details) ────────────────
f_keyPos() =>
    switch keyPos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_left

var table keyT = na
if showKey and barstate.islast
    if na(keyT)
        keyT := table.new(f_keyPos(), 2, 9, border_width = 1, frame_color = frameCl, frame_width = 1)
    int    ltfN   = ltfUsed == 1 ? array.size(arrSec) : ltfUsed == 2 ? array.size(arrMin) : 0
    string dhTxt  = dataMode + (ltfN > 0 ? "  (" + str.tostring(ltfN) + "/bar)" : "")
    color  dhCol  = ltfUsed == 1 ? COL_BULL : ltfUsed == 2 ? COL_MID : dimCol
    string extTxt = not extBiasOn ? "off" : na(extNorm) ? "—" : extNorm > 0.1 ? "aligned +" : extNorm < -0.1 ? "opposing −" : "neutral"
    color  extCol = not extBiasOn ? dimCol : na(extNorm) ? dimCol : extNorm > 0.1 ? COL_BULL : extNorm < -0.1 ? COL_BEAR : dimCol
    float  partc  = lastSbTicks > 0 ? math.min(1.0, 3.0 / lastSbTicks) : 0.0

    table.cell(keyT, 0, 0, "KEY INFO", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_left)
    table.cell(keyT, 1, 0, syminfo.ticker, text_color = color.new(color.white, 10), text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_right)

    table.cell(keyT, 0, 1, "Timeframe", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 1, 1, timeframe.period, text_color = txtCol, text_size = size.tiny, bgcolor = zebraA)

    table.cell(keyT, 0, 2, "Delta source", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 1, 2, dhTxt, text_color = dhCol, text_size = size.tiny, bgcolor = zebraB)

    table.cell(keyT, 0, 3, "Participation", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 1, 3, f_meter(partc), text_color = COL_INFO, text_size = size.tiny, bgcolor = zebraA)

    table.cell(keyT, 0, 4, "Leading strength", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 1, 4, na(leadCharge) ? "—" : f_meter(leadCharge), text_color = COL_MID, text_size = size.tiny, bgcolor = zebraB)

    table.cell(keyT, 0, 5, "Threshold", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 1, 5, na(threshold) ? "—" : str.tostring(math.round(threshold)), text_color = txtCol, text_size = size.tiny, bgcolor = zebraA)

    table.cell(keyT, 0, 6, "ATR", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 1, 6, na(atrVal) ? "—" : str.tostring(atrVal, format.mintick), text_color = txtCol, text_size = size.tiny, bgcolor = zebraB)

    table.cell(keyT, 0, 7, "Levels tracked", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(keyT, 1, 7, str.tostring(liveGaps + liveBrk), text_color = txtCol, text_size = size.tiny, bgcolor = zebraA)

    table.cell(keyT, 0, 8, "External bias", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(keyT, 1, 8, extTxt, text_color = extCol, text_size = size.tiny, bgcolor = zebraB)

// ───────────────────────── LEGEND KEY ───────────────────────────────────────
var table legend = na
if effLegend and barstate.islast
    if na(legend)
        legend := table.new(position.bottom_left, 2, 4, border_width = 1, frame_color = frameCl, frame_width = 1)
    table.cell(legend, 0, 0, "■", text_color = colFreshIn, text_size = size.tiny, bgcolor = zebraA)
    table.cell(legend, 1, 0, "Fresh gap", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(legend, 0, 1, "■", text_color = colTapIn, text_size = size.tiny, bgcolor = zebraB)
    table.cell(legend, 1, 1, "Tapped", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)
    table.cell(legend, 0, 2, "■", text_color = colBrkIn, text_size = size.tiny, bgcolor = zebraA)
    table.cell(legend, 1, 2, "Breaker (defended)", text_color = dimCol, text_size = size.tiny, bgcolor = zebraA)
    table.cell(legend, 0, 3, "—", text_color = COL_BULL, text_size = size.tiny, bgcolor = zebraB)
    table.cell(legend, 1, 3, "Adaptive trail", text_color = dimCol, text_size = size.tiny, bgcolor = zebraB)

// ───────────────────────── CALIBRATION PANEL (off by default) ────────────────
f_calPos() =>
    switch calPanelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

var table calT = na
if calEnable and calShowPanel and barstate.islast
    if na(calT)
        calT := table.new(f_calPos(), 6, 5, border_width = 1, frame_color = frameCl, frame_width = 1)
    string tip = "Past-only, descriptive — NOT a backtest or prediction. Each armed entry is scored after " + str.tostring(calHorizon) + " bars: HIT = net move >= " + str.tostring(calMoveATR) + " x ATR in the entry direction. BASE = the same net-move rate on an unconditional, direction-matched sample in the same regime. EDGE = Hit - Base. 95% Wilson CI shown for N>=5. NetR = 2·Hit − 1 − cost (" + str.tostring(costR, "0.00") + "R), a what-if under a symmetric ±" + str.tostring(calMoveATR) + "×ATR bracket — the test only measures the favourable side, so treat NetR as a cost lens, not a measured stop-out."
    table.cell(calT, 0, 0, "Calibration (past)", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_left, tooltip = tip)
    table.cell(calT, 1, 0, "N",    text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 2, 0, "Hit",  text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 3, 0, "Edge", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 4, 0, "95% CI", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 5, 0, "NetR", text_color = color.white, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_right)

    for r = 0 to 2
        int tt = 0
        int hh = 0
        int un = 0
        int dn = 0
        int bn = 0
        int bu = 0
        int bd = 0
        if r < 2
            tt := array.get(calTot, r)
            hh := array.get(calHit, r)
            un := array.get(calUp, r)
            dn := array.get(calDn, r)
            bn := array.get(baseN, r)
            bu := array.get(baseUp, r)
            bd := array.get(baseDn, r)
        else
            tt := array.get(calTot, 0) + array.get(calTot, 1)
            hh := array.get(calHit, 0) + array.get(calHit, 1)
            un := array.get(calUp, 0) + array.get(calUp, 1)
            dn := array.get(calDn, 0) + array.get(calDn, 1)
            bn := array.get(baseN, 0) + array.get(baseN, 1)
            bu := array.get(baseUp, 0) + array.get(baseUp, 1)
            bd := array.get(baseDn, 0) + array.get(baseDn, 1)
        float hitR = tt > 0 ? hh / float(tt) : na
        float buR  = bn > 0 ? bu / float(bn) : na
        float bdR  = bn > 0 ? bd / float(bn) : na
        float mBase = (tt > 0 and (un + dn) > 0 and not na(buR)) ? (un * buR + dn * bdR) / float(un + dn) : na
        float edge = (na(hitR) or na(mBase)) ? na : hitR - mBase
        [lo, hi] = f_score_ci(hh, tt)
        string lbl  = r == 0 ? "Trend" : r == 1 ? "Range/Oth" : "All"
        string nTxt = str.tostring(tt)
        string hTxt = tt == 0 ? "—" : tt < 5 ? "warm" : str.tostring(math.round(hitR * 100)) + "%"
        string eTxt = na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(math.round(edge * 100))
        string cTxt = na(lo) ? "—" : str.tostring(math.round(lo * 100)) + "–" + str.tostring(math.round(hi * 100))
        color eCol = na(edge) ? dimCol : edge > 0 ? COL_BULL : edge < 0 ? COL_BEAR : COL_MID
        color hCol = tt < 5 ? dimCol : txtCol
        color rbg = r % 2 == 0 ? zebraA : zebraB
        float netR = na(hitR) ? na : (2.0 * hitR - 1.0) - costR
        string ntTxt = (na(netR) or tt < 5) ? "—" : (netR >= 0 ? "+" : "") + str.tostring(netR, "0.00")
        color  ntCol = na(netR) ? dimCol : netR > 0 ? COL_BULL : netR < 0 ? COL_BEAR : COL_MID
        table.cell(calT, 0, r + 1, lbl,  text_color = dimCol, text_size = size.tiny, bgcolor = rbg, text_halign = text.align_left)
        table.cell(calT, 1, r + 1, nTxt, text_color = txtCol, text_size = size.tiny, bgcolor = rbg)
        table.cell(calT, 2, r + 1, hTxt, text_color = hCol,   text_size = size.tiny, bgcolor = rbg)
        table.cell(calT, 3, r + 1, eTxt, text_color = eCol,   text_size = size.tiny, bgcolor = rbg)
        table.cell(calT, 4, r + 1, cTxt, text_color = dimCol, text_size = size.tiny, bgcolor = rbg)
        table.cell(calT, 5, r + 1, ntTxt, text_color = ntCol, text_size = size.tiny, bgcolor = rbg, text_halign = text.align_right)

    int pend = array.size(pgBar)
    table.cell(calT, 0, 4, pend > 0 ? str.tostring(pend) + " pending" : "past-only · no forward guarantee", text_color = dimCol, text_size = size.tiny, bgcolor = color.new(COL_INFO, 10), text_halign = text.align_left)
    table.cell(calT, 1, 4, "", bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 2, 4, "", bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 3, 4, "", bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 4, 4, "", bgcolor = color.new(COL_INFO, 10))
    table.cell(calT, 5, 4, "", bgcolor = color.new(COL_INFO, 10))

// ───────────────────────── EXPORTED OUTPUTS (for other scripts) ──────────────
// Clean, generic names so any indicator can read these via input.source().
float biasScore = trailDir * conf * 10.0     // signed conviction, ±10 full-scale
plot(biasScore,           "EXP_BiasScore",       display = display.data_window)
plot(trailVal,            "EXP_TrailStop",       display = display.data_window)
plot(trailDir,            "EXP_TrailDirection",  display = display.data_window)
plot(regime,              "EXP_RegimeState",     display = display.data_window)
plot(conf,                "EXP_Confidence",       display = display.data_window)
plot(na(leadCharge) ? na : leadCharge, "EXP_LeadingStrength", display = display.data_window)
plot(cvdSlope,            "EXP_CVDSlope",        display = display.data_window)
plot(vpin,                "EXP_FlowToxicity",    display = display.data_window)
plot(cvd,                 "EXP_CumulativeDelta", display = display.data_window)
plot(na(vixRoc) ? na : vixRoc,  "EXP_VolatilityROC",  display = display.data_window)
plot(na(vixRoc) ? na : vixBias, "EXP_VolatilityBias", display = display.data_window)
plot(na(grossRc) ? na : grossRc, "EXP_ExpR", display = display.data_window)
plot(na(netRc) ? na : netRc,     "EXP_NetR", display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(entLong,  "Long entry",  "AST: long trail armed")
alertcondition(entShort, "Short entry", "AST: short trail armed")
alertcondition(exitSig,  "Exit",        "AST: trail / regime exit")
````
