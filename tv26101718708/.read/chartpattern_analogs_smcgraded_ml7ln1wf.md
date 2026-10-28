# Chart-Pattern Analogs SMC-Graded 

- url: https://www.tradingview.com/script/ml7Ln1Wf-Chart-Pattern-Analogs-SMC-Graded/
- type: indicator
- pine_id: PUB;df132a8a46464cecbd4916c7959f530e
- version: 2.0

## Description

Chart-Pattern Analogs — Empirical Matching, SMC-Graded & Calibrated

## What it is

A chart-pattern engine that does not trust textbook shapes — it predicts from **precedent**. Instead of asking "does this look like a Head & Shoulders?", it asks "**how did the closest historical shapes on this symbol actually resolve?**" and answers from data.

A PIP (Perceptually Important Points) skeleton of the recent window is matched by **Dynamic Time Warping** against a live memory of past shapes, each labelled by what happened next. The direction, probability and target come from the *k* nearest analogs. Each completed pattern is then graded with Smart-Money context (liquidity sweeps, premium/discount location, breakout quality), and its forward outcome is tracked **per family, per regime, with Wilson confidence intervals**. Templates and geometry survive only to *name* the family.

## Why these components belong in ONE script (not a stack of indicators)

This matters because the components form **one closed loop**, where each answers a question the others cannot:

- **PIP skeleton + Ehlers-adaptive window** reduce price to its structurally important turning points, over a window sized by the live dominant cycle so the skeleton tracks the market's actual rhythm rather than a fixed bar count.
- **DTW analog matching** replaces fixed templates: the current skeleton is compared to a memory of *resolved* shapes, and the forward outcome of its nearest neighbours **is** the prediction. Empirical, not assumed.
- **SMC context** (liquidity sweeps, EQH/EQL pools, premium/discount, breakout quality) answers *"is this the right place?"* — a pattern that forms after a real liquidity grab, in the correct half of the dealing range, is graded higher; one firing into opposing liquidity is withheld. Shape alone cannot tell you location.
- **Regime** (efficiency ratio) conditions trust: a family's edge is measured separately in trend vs chop, because the same shape behaves differently in each.
- **Calibration** closes the loop: per-family, per-regime hit-rate versus an unconditional directional base rate, recency-weighted, with Wilson 95% intervals — so reliability is *earned on this instrument*, not claimed.

The skeleton says **what**, the analogs say **how it resolved before**, SMC says **whether the location is right**, the grade **fuses** them, and calibration keeps the whole thing **honest**. Remove any layer and the read loses a dimension it cannot recover.

## How it works (mechanics)

On bar close, the PIP skeleton is extracted and matched by DTW k-NN to the analog memory. The consensus direction and probability, plus the single nearest analog's forward path (the **ghost overlay**), are drawn. The pattern is graded **A/B/C** from the calibrated probability + quality + sweep + location, and gated by a minimum grade and a location veto. Every directional emission locks entry and ATR, tracks MFE/MAE in R, and at the horizon records a win if the close moved the chosen ATR multiple in its direction — feeding both the analog memory and the per-family/per-regime calibration tables.

Detection, drawing and resolution happen **on bar close over closed bars only** — no `request.security`, no dynamic-length `ta()`, no intrabar revision. Patterns are drawn once and never moved.

## How to use

1. Read the dashboard: the active pattern's **analog probability**, its **A/B/C setup grade**, **sweep validation** and **premium/discount location**.
2. Favour higher grades — a calibrated-positive family, sweep-validated, in the correct half of the range, with the ghost pointing your way.
3. Check **"This family"** — the regime-conditional and recent hit-rate is the number that matters *now*; the Pro table lists every family with Wilson confidence intervals.
4. The **ghost** shows the single closest historical precedent; the **target** is the analog mean.
5. Everything here is descriptive, probabilistic context — never an instruction.

## Use on any market

Works on any symbol and timeframe. The **Data Source** inputs (High / Low / Close) drive the entire engine — PIP skeleton, pivots, liquidity, premium/discount — from any series, so you can run it on standard candles, Heikin-Ashi, or another instrument. All thresholds are **ATR-relative**, the detection window is **cycle-adaptive**, and the analog memory and calibration rebuild **per instrument** — nothing is hard-coded to a price scale or a single market. Defaults are set for NIFTY index-futures intraday; change the sources or lengths for other assets.


## Credits

This engine builds on established, published concepts:

- **Perceptually Important Points** — Chung, Fu, Luk & Ng
- **Dynamic Time Warping** — Sakoe & Chiba
- **Homodyne-discriminator dominant cycle / adaptive windows** — John F. Ehlers
- **Efficiency Ratio** (trend vs noise) — Perry Kaufman
- **Wilson score confidence interval** — Edwin B. Wilson
- **Liquidity, premium/discount and order-block context** — smart-money / auction-market concepts (Wyckoff lineage; popularised in the ICT body of work)

The empirical analog loop (label-by-outcome DTW matching), the SMC location-grading, and the per-family/per-regime Wilson-bounded calibration framework are the author's original implementation.

## Originality

The contribution is the **closed loop**, not the objects: empirical DTW analog matching (label by outcome, not by template), SMC location-grading, and per-family/per-regime Wilson-bounded calibration, fused into one self-prioritising read with a nearest-precedent ghost overlay. The shape is only the index into history.

## Limitations (honest)

The analog memory and calibration are **in-sample, close-to-close at a fixed horizon, with no costs, slippage or stops** — a study aid, not a backtest, and not a probability of future results. The engine needs to build memory before it leaves bootstrap (watch the "Analog mem" counter). Volume-derived quality degrades on symbols without real volume. Past behaviour of a pattern does not assure future behaviour.

## Disclaimer

Educational / informational study for chart analysis only. **NOT financial advice, NOT a strategy, NOT a recommendation.** It places no orders and guarantees no outcome. Markets carry risk; do your own research and manage your own risk. Paper-trade before risking real money.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ══════════════════════════════════════════════════════════════════════════════
//  © Market_Logic_India                                                  MPL-2.0
//  CHART-PATTERN ANALOGS — Empirical Matching, SMC-Graded & Calibrated       v2.0
//  shorttitle: Pattern Analogs                                      Pine Script v6
// ──────────────────────────────────────────────────────────────────────────────
//  v2.0 — WHAT'S NEW
//    • EMPIRICAL ANALOG CONE — instead of only the single nearest "ghost", the
//      forward outcomes of the k nearest precedents are turned into an empirical
//      distribution and drawn as a fan (25th / median / 75th percentile of where
//      price actually went after similar shapes). It shows the real spread of
//      outcomes, downside included — not a single optimistic path.
//    • MATRIX-PROFILE MOTIF SCORE — the nearest-neighbour distance (the matrix-
//      profile value of the current window) grades how strong the precedent is:
//      a low distance = a genuine MOTIF (repeated shape), a high one = a DISCORD
//      (novel) that is trusted less and can be gated out.
//    • HARNESS+ — a uniqueness-weighted effective sample size, an in-sample /
//      out-of-sample split on the overall edge, and a multiple-testing-deflated
//      significance bar on the per-family test.
//    • Added the MPL licence header; resolved a conditional stateful ta.* call.
//  WHAT THIS IS
//    A chart-pattern engine that does not trust textbook shapes — it predicts from
//    PRECEDENT. A PIP (Perceptually Important Points) skeleton of the recent window
//    is matched by Dynamic Time Warping against a live memory of PAST shapes on the
//    same symbol, each labelled by WHAT ACTUALLY HAPPENED NEXT. The direction,
//    probability and target come from the k closest historical analogs — not from a
//    fixed template. Templates and geometry are kept only to NAME the family.
//    Each completed pattern is then graded with Smart-Money context (liquidity
//    sweeps, premium/discount location, breakout quality) and its forward outcome
//    is tracked per family, per regime, with Wilson confidence intervals.
//
//  WHY THESE COMPONENTS ARE COMBINED  (mashup rationale)
//    These are not independent tools stacked together; they form one closed loop
//    that turns a shape into a calibrated, located, graded read:
//      * PIP SKELETON + EHLERS-ADAPTIVE WINDOW reduce price to its structurally
//        important turning points, over a window sized by the live dominant cycle
//        so the skeleton tracks the market's actual rhythm.
//      * DTW ANALOG MATCHING replaces fixed templates: the current skeleton is
//        compared to a memory of resolved shapes, and the forward outcome of its
//        nearest neighbours IS the prediction. This is empirical, not assumed.
//      * SMC CONTEXT (sweeps, EQH/EQL liquidity, premium/discount, breakout
//        quality) answers "is this the right place?" — a pattern firing after a
//        liquidity grab, in the correct half of the range, is graded higher; one
//        firing into opposing liquidity is withheld. Shape alone cannot tell you.
//      * REGIME (efficiency ratio) conditions trust: a family's edge is measured
//        per regime, because the same shape behaves differently in trend vs chop.
//      * CALIBRATION closes the loop: per-family, per-regime hit-rate vs an
//        unconditional directional base rate, recency-weighted, with Wilson 95%
//        intervals — so reliability is earned on this instrument, not claimed.
//    In short: the skeleton says what, the analogs say how it resolved before, SMC
//    says whether the location is right, the grade fuses them, and calibration
//    keeps the whole thing honest.
//
//  HOW IT WORKS (mechanics)
//    On bar close, the PIP skeleton is extracted and matched (DTW k-NN) to the
//    analog memory. The consensus direction/probability and the nearest analog's
//    forward path (the "ghost") are shown. The pattern is graded A/B/C from the
//    calibrated probability + quality + sweep + location, and gated by a minimum
//    grade and a location veto. Every directional emission locks entry/ATR, tracks
//    MFE/MAE in R, and at the horizon records a win if the close moved moveATR×ATR
//    in its direction — feeding both the analog memory and the per-family/regime
//    calibration tables.
//
//  HOW TO USE
//    1. Read the dashboard: the active pattern's analog probability, its A/B/C
//       setup grade, sweep validation and premium/discount location.
//    2. Favour higher grades: a calibrated-positive family, sweep-validated, in the
//       correct half of the range, with the analog ghost pointing your way.
//    3. Check "This family" — the regime-conditional + recent hit-rate is the
//       number that matters now; the Pro table shows every family with Wilson CIs.
//    4. The ghost shows the single closest precedent; the target is the analog mean.
//    5. Everything here is descriptive, probabilistic context — never an instruction.
//
//  USE ON ANY MARKET
//    Works on any symbol/timeframe. All thresholds are ATR-relative; the window is
//    cycle-adaptive; the memory and calibration are rebuilt per instrument.
//
//  ORIGINALITY
//    The contribution is the closed loop: empirical DTW analog matching (label by
//    outcome, not by template), SMC location-grading, and per-family/per-regime
//    Wilson-bounded calibration, fused into one self-prioritising read with a
//    nearest-precedent ghost overlay. The shape is only the index into history.
//
//  NON-REPAINT
//    Detection, drawing and resolution happen on bar close over closed bars only.
//    No request.security, no dynamic-length ta(), no intrabar revision. Patterns
//    are drawn once and never moved.
//
//  EXPORTS (Data Window)
//    EXP_PatCode · EXP_PatDir · EXP_FitPct · EXP_Target · EXP_FamHitPct ·
//    EXP_FamEdge · EXP_AnalogP · EXP_AnalogMem · EXP_Grade · EXP_Quality ·
//    EXP_Swept · EXP_PremDisc · EXP_Motif · EXP_ConeMed · EXP_EdgeOOS ·
//    EXP_EffN — consume from another script via input.source().
//
//  CREDITS (concepts this engine builds on)
//    • Perceptually Important Points — Chung, Fu, Luk & Ng.
//    • Dynamic Time Warping — Sakoe & Chiba.
//    • Matrix Profile / motif-discord (nearest-neighbour distance) — Keogh, Mueen;
//      STOMP — Zhu et al. Sample-uniqueness weighting & out-of-sample evaluation —
//      Marcos López de Prado (2018).
//    • Homodyne-discriminator dominant cycle & adaptive windows — John F. Ehlers.
//    • Efficiency Ratio (trend vs noise) — Perry Kaufman.
//    • Wilson score confidence interval — Edwin B. Wilson.
//    • Liquidity, premium/discount & order-block context — smart-money / auction
//      market concepts (Wyckoff lineage; popularised in the ICT body of work).
//    Implementation, the empirical analog loop and the calibration framework are
//    original work by the author.
//
//  DISCLAIMER
//    EDUCATIONAL / INFORMATIONAL only. NOT financial advice, NOT a strategy, NOT a
//    recommendation. The forward-resolution and calibration stats are in-sample,
//    close-to-close at a fixed horizon, with no costs, slippage or stops — a study
//    aid, not a backtest, and not a probability of future results. Past behaviour
//    of a pattern does not assure its future behaviour. You alone are responsible
//    for your decisions. Paper-trade before risking real money.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Chart-Pattern Analogs — Empirical Matching, SMC-Graded & Calibrated", "Pattern Analogs",
     overlay             = true,
     max_lines_count     = 300,
     max_labels_count    = 300,
     max_bars_back       = 1000)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 1 — INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gSrc = "1 · Data Source (any market)"
srcHigh  = input.source(high,  "High source",  group = gSrc, tooltip = "Drives the PIP skeleton, pivots, liquidity and premium/discount. Swap to an alternate series (e.g. Heikin-Ashi) to run the engine on any market or candle type. Defaults to the chart's own High.")
srcLow   = input.source(low,   "Low source",   group = gSrc)
srcClose = input.source(close, "Close source", group = gSrc, tooltip = "Used to build the pattern skeleton and to place price within the dealing range.")

g1 = "2 · Detection Window"
winLen   = input.int(90, "PIP Window (bars)", minval = 30, maxval = 200, group = g1, tooltip = "Base / fallback window the PIP skeleton is built from. With the adaptive window ON this is the cap.")
useAdaptiveWin = input.bool(true, "Adaptive Window (Ehlers cycle)", group = g1, tooltip = "Size the PIP window from the live dominant cycle (Ehlers homodyne discriminator) × the multiplier below, clamped — so the skeleton tracks the market's actual rhythm instead of a fixed bar count. OFF uses the fixed window above.")
cycMult  = input.float(3.0, "Window = cycle ×", minval = 1.0, maxval = 8.0, step = 0.5, group = g1)
cycMin   = input.int(8,  "Min Cycle Clamp", minval = 4, maxval = 40, group = g1)
cycMax   = input.int(60, "Max Cycle Clamp", minval = 20, maxval = 120, group = g1)
minGap   = input.int(8,  "Min Bars Between Detections", minval = 1, maxval = 60, group = g1, tooltip = "Cooldown so a sliding window doesn't re-fire the same pattern every bar.")
freshBars= input.int(6,  "Completion Recency (bars)", minval = 1, maxval = 30, group = g1, tooltip = "The pattern's final pivot must sit within this many bars of the right edge — i.e. it just completed.")

g2 = "3 · Pattern Fit Gates"
tplTol   = input.float(0.34, "Template Tolerance (RMSE)", minval = 0.10, maxval = 0.60, step = 0.02, group = g2, tooltip = "Engine A. Membership = max(0, 1 − RMSE/tol). Lower = stricter template match.")
minTplFit= input.float(0.55, "Min Template Fit", minval = 0.30, maxval = 0.95, step = 0.05, group = g2, tooltip = "Engine A gate. Reversal templates below this fit are discarded.")
minR2    = input.float(0.55, "Min Trend-line R²", minval = 0.20, maxval = 0.95, step = 0.05, group = g2, tooltip = "Engine B gate. Upper AND lower line must fit their PIP pivots at least this well, else the geometric pattern is discarded.")
flatATR  = input.float(0.04, "Flat-Slope Threshold (ATR/bar)", minval = 0.01, maxval = 0.20, step = 0.01, group = g2, tooltip = "Engine B. |slope| below this (in ATR per bar) is treated as a horizontal trend line.")
minPatATR= input.float(1.5, "Min Pattern Height (×ATR)", minval = 0.2, maxval = 8.0, step = 0.1, group = g2, tooltip = "Reject patterns whose total high-low span is smaller than this many ATR. Stops micro-wiggles in chop from qualifying.")

gA = "4 · Analog Engine (DTW)"
useAnalog = input.bool(true, "Empirical Analog Engine", group = gA, tooltip = "Replace the fixed chart-pattern templates with k-NN over a memory of PAST shapes, each labelled by what actually happened next. The prediction (direction, probability, target) is the forward outcome of the closest historical analogs, matched by Dynamic Time Warping. Templates/geometry are kept only to NAME the family.")
analogK   = input.int(12, "Analog Neighbours (k)", minval = 3, maxval = 50, group = gA)
analogMin = input.int(25, "Min Memory to Trust", minval = 10, maxval = 250, group = gA, tooltip = "Until the analog memory holds this many resolved shapes, fall back to the template / geometric direction (bootstrap).")
memSize   = input.int(300, "Analog Memory Size", minval = 50, maxval = 600, group = gA, tooltip = "How many recent resolved shapes the engine remembers.")
motifMin  = input.float(0.0, "Min motif strength (0 = off)", minval = 0.0, maxval = 0.9, step = 0.05, group = gA, tooltip = "MATRIX-PROFILE gate. The motif score is how much closer the nearest precedent is than a typical one (1 = strong repeated shape, 0 = novel/discord). Require at least this to emit — so novel shapes with no real precedent are withheld. 0 keeps every pattern.")

g3 = "5 · Forward Resolution & Calibration"
horizon  = input.int(20,  "Resolution Horizon (bars)", minval = 5, maxval = 200, group = g3, tooltip = "Bars after a pattern confirms at which its outcome is scored.")
moveATR  = input.float(1.0,"Follow-through Size (×ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = g3, tooltip = "A pattern is a WIN if the close moves this many ATR in its implied direction by the horizon. Also defines the base rate.")
atrLen   = input.int(14,  "ATR Length (R unit)", minval = 5, maxval = 50, group = g3)
useVeto  = input.bool(true, "Regime Veto (context filter)", group = g3, tooltip = "ON (default): suppress reversal patterns in strong trends and continuation patterns in chop, using the efficiency-ratio regime. A pattern's edge is regime-conditional. OFF: emit every gated pattern (unfiltered stats).")
vetoRange= input.bool(true, "Veto Range Patterns in Chop", group = g3, tooltip = "ON (default): also suppress non-directional patterns (Broadening, Sym Triangle) when the regime is Chop — in a chop regime they merely re-describe the chop and flood the chart.")
erLen    = input.int(20,  "Regime Efficiency-Ratio Length", minval = 5, maxval = 60, group = g3)
recencyHL= input.int(40,  "Calibration Recency Half-Life", minval = 5, maxval = 300, group = g3, tooltip = "Recency-weighted family hit-rate decays older resolutions toward this half-life (in samples), so a family whose behaviour has drifted is reflected faster than its all-time rate.")
harTrainN= input.int(40,  "HARNESS+ in-sample events (then OOS)", minval = 10, group = g3, tooltip = "The first N resolved patterns train (in-sample); every later one is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one.")
nTests   = input.int(6,   "Edge significance · N tests (deflation)", minval = 1, maxval = 14, group = g3, tooltip = "Raise the per-family significance bar for the number of families tested (Bonferroni-style z), so a lucky family isn't flagged as a real edge.")

gM = "6 · SMC Context & Gating"
useSMC    = input.bool(true, "SMC Context Layer", group = gM, tooltip = "Grade and gate each pattern with Smart-Money context — liquidity sweeps, premium/discount location and breakout quality. Ported from the Market Structure & Liquidity framework. The probability stays the calibrated analog P; these add a setup grade and withhold patterns firing into opposing liquidity.")
smcSwing  = input.int(10, "Liquidity Swing Length", minval = 3, maxval = 40, group = gM)
eqTol     = input.float(0.10, "Equal-Level Tolerance (×ATR)", minval = 0.02, maxval = 1.0, step = 0.02, group = gM, tooltip = "Two swings within this ATR distance form an EQH/EQL liquidity pool.")
sweepLook = input.int(10, "Sweep Validation Lookback (bars)", minval = 2, maxval = 40, group = gM, tooltip = "A pattern is sweep-validated when resting liquidity (EQH/EQL) was swept in its favour within this many bars before completion — the inducement→sweep→shift sequence.")
useLocVeto= input.bool(true, "Location Gate (veto into opposing liquidity)", group = gM, tooltip = "Withhold a long firing in deep premium, and a short firing in deep discount, relative to the dealing range.")
pdGate    = input.float(0.75, "Premium / Discount Veto Threshold", minval = 0.55, maxval = 0.95, step = 0.05, group = gM, tooltip = "Veto a long above this fraction of the dealing range (premium); veto a short below 1−this (discount).")
useQuality= input.bool(true, "Breakout Quality into Grade", group = gM, tooltip = "Fold displacement strength, body dominance and volume confirmation into the A/B/C setup grade.")
minGrade  = input.string("C", "Min Grade to Emit", options = ["A+","A","B","C","-"], group = gM, tooltip = "Suppress patterns whose fused setup grade is below this. '-' emits everything.")

g4 = "7 · Visuals"
showPattern = input.bool(true,  "Draw Patterns", group = g4)
showTarget  = input.bool(true,  "Draw Measured-Move Target", group = g4, tooltip = "Estimated measured move (height projected from the breakout / neckline). An estimate, labeled as such.")
showGhost   = input.bool(true,  "Analog Ghost Overlay", group = g4, tooltip = "Project how the single closest historical analog (nearest DTW match) resolved — a faint dotted path to its forward endpoint, with the move in R. Shows the precedent the prediction rests on.")
showCone    = input.bool(true,  "Empirical Analog Cone", group = g4, tooltip = "Draw the forward distribution of the k nearest precedents as a fan — median plus the 25th/75th-percentile paths of where price actually went after similar shapes. The honest spread of outcomes, downside included.")
showSkeleton= input.bool(false, "Draw PIP Skeleton (diagnostic)", group = g4)
maxDraw     = input.int(6, "Keep Last N Patterns Drawn", minval = 1, maxval = 20, group = g4)
bullClr     = input.color(#21D7AC, "Bullish", inline = "c", group = g4)
bearClr     = input.color(#F2547B, "Bearish", inline = "c", group = g4)
neuClr      = input.color(#E3B341, "Neutral", inline = "c", group = g4)

g5 = "8 · Dashboard & Theme"
showPanel = input.bool(true, "Show Panel", group = g5)
panelMode = input.string("Compact", "Detail", options = ["Compact","Pro"], group = g5, tooltip = "Compact: active pattern + best-edge family. Pro: also the full per-family calibration table.")
panelPos  = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g5)
themeOpt  = input.string("Auto", "Theme", options = ["Auto","Dark","Light"], group = g5, tooltip = "Auto reads chart-background luminance so the panel stays legible on any color scheme.")
calRows   = input.int(8, "Calibration Rows (Pro)", minval = 3, maxval = 14, group = g5)

g6 = "9 · Alerts"
alPattern = input.bool(true,  "New Pattern Confirmed", group = g6)
alEdge    = input.bool(true,  "New Significant-Edge Family", group = g6, tooltip = "Fires when a family first crosses 95% significance with positive edge.")

gE = "10 · Exports (Data Window)"
showEXP = input.bool(true, "Emit EXP_* exports", group = gE, tooltip = "Hidden data-window series for input.source() consumption by other scripts. Turn off to reclaim plot slots.")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 2 — THEME, HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Darken a color toward black, preserving transparency (for light backgrounds).
darken(color c, float f) => color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f, color.t(c))

// A/B/C setup grade from a 0..100 fused score, and its rank for gating.
f_grade(float s) => s >= 80 ? "A+" : s >= 68 ? "A" : s >= 55 ? "B" : s >= 45 ? "C" : "—"
f_gradeRank(string g) => g == "A+" ? 4 : g == "A" ? 3 : g == "B" ? 2 : g == "C" ? 1 : 0

// Compact number formatting: 1,250,000 -> 1.3M
fmtNum(float x) =>
    float a = math.abs(x)
    a >= 1e12 ? str.tostring(x/1e12,"0.0")+"T" : a >= 1e9 ? str.tostring(x/1e9,"0.0")+"B" : a >= 1e6 ? str.tostring(x/1e6,"0.0")+"M" : a >= 1e3 ? str.tostring(x/1e3,"0.0")+"K" : str.tostring(x,"#,###")

// Adaptive theme: read background luminance, pick light/dark palette.
color _cbg   = chart.bg_color
float _bgLum = na(_cbg) ? 20.0 : (0.299*color.r(_cbg) + 0.587*color.g(_cbg) + 0.114*color.b(_cbg))
bool  isLight = themeOpt == "Light" or (themeOpt == "Auto" and _bgLum > 140)
color cTxt  = isLight ? #0E1014 : #E6EDF3
color cSub  = isLight ? color.new(#3A4048, 0) : color.new(color.silver, 25)
color cDim  = isLight ? #6B7280 : #8B92A0
color cAcc  = isLight ? #16438C : #58A6FF
color cHdr  = isLight ? color.new(#E3E8EF, 0) : color.new(#161B22, 0)
color cRow  = isLight ? color.new(#F4F6F9, 0) : color.new(#0D1117, 15)
color cRowA = isLight ? color.new(#ECF0F5, 0) : color.new(#11161F, 15)
color cPan  = isLight ? color.new(#FFFFFF, 0) : color.new(#0D1117, 0)
color cBull = isLight ? darken(bullClr, 0.52) : bullClr
color cBear = isLight ? darken(bearClr, 0.58) : bearClr
color cNeu  = isLight ? darken(neuClr, 0.55) : neuClr
color cFlat = isLight ? #8A9099 : #5B6470

string parsedPos = switch panelPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    => position.top_right

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 3 — CONSTANTS, FAMILIES, TEMPLATES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int PN    = 7        // PIP points (template length)
int NFAM  = 14       // family ids 1..14

// Family ids:
//  1 Double Top    2 Double Bottom   3 Head & Shoulders  4 Inverse H&S
//  5 Triple Top    6 Triple Bottom   7 Asc Triangle      8 Desc Triangle
//  9 Sym Triangle 10 Rising Wedge   11 Falling Wedge    12 Asc Channel
// 13 Desc Channel 14 Broadening
famName(int id) =>
    switch id
        1  => "Double Top"
        2  => "Double Bottom"
        3  => "Head & Shoulders"
        4  => "Inverse H&S"
        5  => "Triple Top"
        6  => "Triple Bottom"
        7  => "Asc Triangle"
        8  => "Desc Triangle"
        9  => "Sym Triangle"
        10 => "Rising Wedge"
        11 => "Falling Wedge"
        12 => "Asc Channel"
        13 => "Desc Channel"
        14 => "Broadening"
        => "—"

famShort(int id) =>
    switch id
        1=>"DT"
        2=>"DB"
        3=>"H&S"
        4=>"iH&S"
        5=>"3T"
        6=>"3B"
        7=>"AscTri"
        8=>"DesTri"
        9=>"SymTri"
        10=>"RWdg"
        11=>"FWdg"
        12=>"AscCh"
        13=>"DesCh"
        14=>"Broad"
        =>"—"

// Implied direction by family (0 = bilateral / informational, no calibration).
famDir(int id) =>
    switch id
        1=>-1
        2=>1
        3=>-1
        4=>1
        5=>-1
        6=>1
        7=>1
        8=>-1
        10=>-1
        11=>1
        12=>1
        13=>-1
        => 0

// Reversal templates (normalized 0..1, oldest→newest). Engine A matches against these.
var float[] TPL_DT  = array.from(0.10, 0.55, 1.00, 0.50, 1.00, 0.55, 0.10) // Double Top
var float[] TPL_DB  = array.from(0.90, 0.45, 0.00, 0.50, 0.00, 0.45, 0.90) // Double Bottom
var float[] TPL_HS  = array.from(0.20, 0.65, 0.45, 1.00, 0.45, 0.65, 0.20) // Head & Shoulders
var float[] TPL_IHS = array.from(0.80, 0.35, 0.55, 0.00, 0.55, 0.35, 0.80) // Inverse H&S
var float[] TPL_TT  = array.from(0.10, 1.00, 0.45, 1.00, 0.45, 1.00, 0.10) // Triple Top
var float[] TPL_TB  = array.from(0.90, 0.00, 0.55, 0.00, 0.55, 0.00, 0.90) // Triple Bottom

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 4 — CONTEXT (ATR, regime)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float atr = ta.atr(atrLen)

// Efficiency ratio (Kaufman): trend vs chop. 1 = clean trend, ~0 = chop.
float erNet  = math.abs(close - close[erLen])
float erPath = math.sum(math.abs(close - close[1]), erLen)
float er     = erPath > 0 ? erNet / erPath : 0.0
bool  trendy = er > 0.45
bool  choppy = er < 0.25
string regimeTxt = trendy ? "Trend" : choppy ? "Chop" : "Mixed"
color  regimeCol = trendy ? cAcc : choppy ? cNeu : cDim
int    regID = trendy ? 1 : choppy ? 2 : 3
f_regName(int rg) => rg == 1 ? "Trend" : rg == 2 ? "Chop" : "Mixed"

// ── Ehlers homodyne dominant cycle → adaptive PIP window ──────────────────────
float cyPrice = hl2
var float ehSm  = 0.0
var float ehDt  = 0.0
var float ehI1  = 0.0
var float ehQ1  = 0.0
var float ehJI  = 0.0
var float ehJQ  = 0.0
var float ehI2  = 0.0
var float ehQ2  = 0.0
var float ehRe  = 0.0
var float ehIm  = 0.0
var float ehPer = 0.0
var float ehSmPer = 0.0
if bar_index > 6
    float a = 0.075 * nz(ehPer[1]) + 0.54
    ehSm := (4.0 * cyPrice + 3.0 * cyPrice[1] + 2.0 * cyPrice[2] + cyPrice[3]) / 10.0
    ehDt := (0.0962 * ehSm + 0.5769 * nz(ehSm[2]) - 0.5769 * nz(ehSm[4]) - 0.0962 * nz(ehSm[6])) * a
    ehQ1 := (0.0962 * ehDt + 0.5769 * nz(ehDt[2]) - 0.5769 * nz(ehDt[4]) - 0.0962 * nz(ehDt[6])) * a
    ehI1 := nz(ehDt[3])
    ehJI := (0.0962 * ehI1 + 0.5769 * nz(ehI1[2]) - 0.5769 * nz(ehI1[4]) - 0.0962 * nz(ehI1[6])) * a
    ehJQ := (0.0962 * ehQ1 + 0.5769 * nz(ehQ1[2]) - 0.5769 * nz(ehQ1[4]) - 0.0962 * nz(ehQ1[6])) * a
    float i2t = ehI1 - ehJQ
    float q2t = ehQ1 + ehJI
    ehI2 := 0.2 * i2t + 0.8 * nz(ehI2[1])
    ehQ2 := 0.2 * q2t + 0.8 * nz(ehQ2[1])
    float ret = ehI2 * nz(ehI2[1]) + ehQ2 * nz(ehQ2[1])
    float imt = ehI2 * nz(ehQ2[1]) - ehQ2 * nz(ehI2[1])
    ehRe := 0.2 * ret + 0.8 * nz(ehRe[1])
    ehIm := 0.2 * imt + 0.8 * nz(ehIm[1])
    float per = nz(ehPer[1])
    if ehIm != 0.0 and ehRe != 0.0
        per := 2.0 * math.pi / math.atan(ehIm / ehRe)
    float pp = nz(ehPer[1])
    if pp > 0.0
        per := math.min(per, 1.5 * pp)
        per := math.max(per, 0.67 * pp)
    per := math.max(float(cycMin), math.min(float(cycMax), per))
    ehPer   := 0.2 * per + 0.8 * nz(ehPer[1])
    ehSmPer := 0.33 * ehPer + 0.67 * nz(ehSmPer[1])
float domCycle = bar_index > 6 and ehSmPer > 0.0 ? ehSmPer : na
int Lwin = useAdaptiveWin and not na(domCycle) ? math.max(30, math.min(winLen, int(math.round(domCycle * cycMult)))) : winLen

// ── SMC CONTEXT — liquidity sweeps, premium/discount, breakout quality ───────
float atrSafe = atr > 0 ? atr : close * 0.001
float volSma20 = ta.sma(volume, 20)
float volSd20  = ta.stdev(volume, 20)
float volZ    = nz((volume - volSma20) / (volSd20 == 0 ? 1.0 : volSd20), 0.0)
float bodyRat = (high - low) > 0 ? math.abs(close - open) / (high - low) : 0.0
float dispAtr = ta.tr(true) / atrSafe

// swing pivots → EQH/EQL resting-liquidity pools + dealing range
float phSm = ta.pivothigh(srcHigh, smcSwing, smcSwing)
float plSm = ta.pivotlow(srcLow,  smcSwing, smcSwing)
var float lastPH = na
var float prevPH = na
var float lastPL = na
var float prevPL = na
if not na(phSm)
    prevPH := lastPH
    lastPH := phSm
if not na(plSm)
    prevPL := lastPL
    lastPL := plSm
float eqDist = eqTol * atrSafe
var float eqhLvl = na
var float eqlLvl = na
if not na(phSm) and not na(prevPH) and math.abs(lastPH - prevPH) <= eqDist
    eqhLvl := math.max(lastPH, prevPH)
if not na(plSm) and not na(prevPL) and math.abs(lastPL - prevPL) <= eqDist
    eqlLvl := math.min(lastPL, prevPL)

// sweeps — wick beyond resting liquidity / last swing, close back inside (stop run)
bool sweepHi = (not na(eqhLvl) and srcHigh > eqhLvl and srcClose < eqhLvl) or (not na(lastPH) and srcHigh > lastPH and srcClose < lastPH and close < open)
bool sweepLo = (not na(eqlLvl) and srcLow  < eqlLvl and srcClose > eqlLvl) or (not na(lastPL) and srcLow  < lastPL and srcClose > lastPL and close > open)
var int lastSweepLoBar = na   // buy-side taken (bullish)
var int lastSweepHiBar = na   // sell-side taken (bearish)
if sweepLo
    lastSweepLoBar := bar_index
if sweepHi
    lastSweepHiBar := bar_index

// premium / discount position within the dealing range (last swing high↔low)
float rngHi = lastPH
float rngLo = lastPL
float pdPos = (not na(rngHi) and not na(rngLo) and (rngHi - rngLo) > 0) ? (srcClose - rngLo) / (rngHi - rngLo) : na
string pdZone = na(pdPos) ? "—" : pdPos > 0.62 ? "Premium" : pdPos < 0.38 ? "Discount" : "Equilibrium"

// breakout-quality score (displacement · body · volume · sweep), 0..1
f_quality(float disp, float body, float vz, bool swept) =>
    float dS = math.min(1.0, disp / 2.0)
    float bS = math.min(1.0, body / 0.8)
    float vS = math.min(1.0, math.max(0.0, (vz + 0.5) / 2.5))
    float sS = swept ? 1.0 : 0.0
    0.34 * dS + 0.20 * bS + 0.20 * vS + 0.26 * sS

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 5 — PIP EXTRACTION  (Perceptually Important Points)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Returns window-coord indices (0=oldest .. L-1=newest) of the PN most important
// points and their prices, by iterative max-vertical-distance insertion.

f_pip(int L) =>
    array<int>   sel  = array.new<int>()
    array<float> selP = array.new<float>()
    if L >= PN and bar_index >= L
        sel.push(0)
        sel.push(L - 1)
        bool go = true
        while sel.size() < PN and go
            float bestD   = -1.0
            int   bestW   = -1
            int   bestPos = -1
            for s = 0 to sel.size() - 2
                int a = sel.get(s)
                int b = sel.get(s + 1)
                if b - a >= 2
                    float Pa = srcClose[(L - 1) - a]
                    float Pb = srcClose[(L - 1) - b]
                    for w = a + 1 to b - 1
                        float t     = (w - a) / float(b - a)
                        float lineY = Pa + (Pb - Pa) * t
                        float d     = math.abs(srcClose[(L - 1) - w] - lineY)
                        if d > bestD
                            bestD   := d
                            bestW   := w
                            bestPos := s + 1
            if bestW < 0
                go := false
            else
                sel.insert(bestPos, bestW)
        if sel.size() == PN
            for i = 0 to PN - 1
                selP.push(srcClose[(L - 1) - sel.get(i)])
    [sel, selP]

// Least-squares line through (xs,ys): returns [slope, intercept, r2].
f_fit(array<float> xs, array<float> ys) =>
    int n = xs.size()
    float bb = na
    float aa = na
    float r2 = na
    if n >= 2
        float sx = 0.0
        float sy = 0.0
        float sxx = 0.0
        float sxy = 0.0
        float syy = 0.0
        for i = 0 to n - 1
            float x = xs.get(i)
            float y = ys.get(i)
            sx += x
            sy += y
            sxx += x * x
            sxy += x * y
            syy += y * y
        float den = n * sxx - sx * sx
        bb := den != 0 ? (n * sxy - sx * sy) / den : 0.0
        aa := (sy - bb * sx) / n
        float ssTot = syy - sy * sy / n
        float ssRes = syy - aa * sy - bb * sxy
        r2 := ssTot > 0 ? math.max(0.0, 1.0 - ssRes / ssTot) : 0.0
    [bb, aa, r2]

// RMSE of a normalized PIP vector against a template.
f_rmse(array<float> v, array<float> t) =>
    float s = 0.0
    for i = 0 to PN - 1
        float d = v.get(i) - t.get(i)
        s += d * d
    math.sqrt(s / PN)

// Engine A: best fuzzy template match over the six reversal templates.
// Membership = max(0, 1 − RMSE/tplTol). Returns [familyId, fit].
f_bestTpl(array<float> v) =>
    float bf   = 0.0
    int   bfam = 0
    float f1 = math.max(0.0, 1.0 - f_rmse(v, TPL_DT)  / tplTol)
    if f1 > bf
        bf := f1
        bfam := 1
    float f2 = math.max(0.0, 1.0 - f_rmse(v, TPL_DB)  / tplTol)
    if f2 > bf
        bf := f2
        bfam := 2
    float f3 = math.max(0.0, 1.0 - f_rmse(v, TPL_HS)  / tplTol)
    if f3 > bf
        bf := f3
        bfam := 3
    float f4 = math.max(0.0, 1.0 - f_rmse(v, TPL_IHS) / tplTol)
    if f4 > bf
        bf := f4
        bfam := 4
    float f5 = math.max(0.0, 1.0 - f_rmse(v, TPL_TT)  / tplTol)
    if f5 > bf
        bf := f5
        bfam := 5
    float f6 = math.max(0.0, 1.0 - f_rmse(v, TPL_TB)  / tplTol)
    if f6 > bf
        bf := f6
        bfam := 6
    [bfam, bf]

// Dynamic Time Warping distance between a PN-vector `a` and a PN-slice of a flat
// memory array starting at `off`. Normalized to ~0..1. Lower = closer analog.
// Uses a shared scratch buffer (dtwD) so the hot loop allocates nothing.
var float[] dtwD = array.new<float>(PN * PN, 0.0)
f_dtwFlat(array<float> a, array<float> mem, int off) =>
    int n = PN
    dtwD.set(0, math.abs(a.get(0) - mem.get(off)))
    for i = 1 to n - 1
        dtwD.set(i * n, math.abs(a.get(i) - mem.get(off)) + dtwD.get((i - 1) * n))
    for j = 1 to n - 1
        dtwD.set(j, math.abs(a.get(0) - mem.get(off + j)) + dtwD.get(j - 1))
    for i = 1 to n - 1
        for j = 1 to n - 1
            float c  = math.abs(a.get(i) - mem.get(off + j))
            float mn = math.min(dtwD.get((i - 1) * n + j), math.min(dtwD.get(i * n + j - 1), dtwD.get((i - 1) * n + j - 1)))
            dtwD.set(i * n + j, c + mn)
    dtwD.get(n * n - 1) / float(2 * n)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 6 — DRAW POOLS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<line>  pLines  = array.new<line>()
var array<label> pLabels = array.new<label>()

f_pushLine(line l) =>
    pLines.push(l)
    if pLines.size() > maxDraw * 9
        line.delete(pLines.shift())

f_pushLabel(label lb) =>
    pLabels.push(lb)
    if pLabels.size() > maxDraw * 2
        label.delete(pLabels.shift())

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 7 — CALIBRATION STATE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

type Pend
    int   fam
    int   dir
    float entry
    float atr0
    int   bidx
    float mfe
    float mae
    bool  done
    array<float> shape
    int   reg
    float uniq

type Base
    float entry
    float atr0
    int   bidx

var array<Pend> pend = array.new<Pend>()
var array<Base> bq   = array.new<Base>()

int NREG = 3
// per-family × regime hit tables (flat idx = fam*(NREG+1) + reg) + recency-weighted hit
var int[]   regFamN = array.new<int>((NFAM + 1) * (NREG + 1), 0)
var int[]   regFamW = array.new<int>((NFAM + 1) * (NREG + 1), 0)
var float[] famNd   = array.new<float>(NFAM + 1, 0.0)
var float[] famWd   = array.new<float>(NFAM + 1, 0.0)
float recDecay = math.pow(0.5, 1.0 / recencyHL)

// Wilson 95% half-width of a hit proportion
f_wilsonHalf(int w, int n) =>
    float r = na
    if n > 0
        float z = 1.96
        float p = w / float(n)
        float den = 1.0 + z * z / n
        r := z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n)) / den
    r

// ── ANALOG MEMORY — resolved shapes labelled by what happened next ──
var float[] memShape = array.new<float>()   // PN normalized points per entry (flat)
var int[]   memFam   = array.new<int>()
var float[] memFwd   = array.new<float>()    // signed forward move at horizon, in R
var float[] memMFEv  = array.new<float>()    // peak excursion in the realized direction, in R

// Analog consensus for a fresh normalized vector v:
//   [dir, winProb, meanPeakMFE, kUsed] over the k nearest resolved shapes by DTW.
f_analog(array<float> v, bool run) =>
    int   m   = memFwd.size()
    int   dir = 0
    float p   = na
    float mfe = na
    int   kk  = 0
    float bestFwd = na     // nearest single analog — for the ghost overlay
    float bestMfe = na
    float motif   = na     // matrix-profile: nearest-neighbour distance vs typical (1 = strong precedent)
    array<float> nnFwd = array.new<float>()   // forward moves (R) of the k nearest — the empirical cone
    if run and useAnalog and m >= analogMin
        array<float> dist = array.new<float>()
        float distSum = 0.0
        for e = 0 to m - 1
            float d = f_dtwFlat(v, memShape, e * PN)
            dist.push(d)
            distSum += d
        float distMean = m > 0 ? distSum / m : na
        int K = math.min(analogK, m)
        array<bool> used = array.new<bool>(m, false)
        float sumFwd = 0.0
        float sumMfe = 0.0
        float bestDist = na
        for s = 0 to K - 1
            float best = 1e18
            int   bi   = -1
            for e = 0 to m - 1
                if not used.get(e) and dist.get(e) < best
                    best := dist.get(e)
                    bi   := e
            if bi >= 0
                used.set(bi, true)
                sumFwd += memFwd.get(bi)
                sumMfe += memMFEv.get(bi)
                nnFwd.push(memFwd.get(bi))
                if s == 0
                    bestFwd := memFwd.get(bi)
                    bestMfe := memMFEv.get(bi)
                    bestDist := best
                kk += 1
        if kk > 0
            float meanFwd = sumFwd / kk
            mfe := sumMfe / kk
            dir := meanFwd > 0 ? 1 : meanFwd < 0 ? -1 : 0
            int agree = 0
            for e = 0 to m - 1
                if used.get(e)
                    float fe = memFwd.get(e)
                    int   se = fe > 0 ? 1 : fe < 0 ? -1 : 0
                    if dir != 0 and se == dir and math.abs(fe) >= moveATR
                        agree += 1
            p := agree / float(kk)
        motif := (not na(distMean) and distMean > 0.0 and not na(bestDist)) ? math.max(0.0, 1.0 - bestDist / distMean) : na
    [dir, p, mfe, kk, bestFwd, bestMfe, motif, nnFwd]

var int[]   famN   = array.new<int>(NFAM + 1, 0)
var int[]   famW   = array.new<int>(NFAM + 1, 0)
var float[] famMFE = array.new<float>(NFAM + 1, 0.0)
var float[] famMAE = array.new<float>(NFAM + 1, 0.0)
var bool[]  famSig = array.new<bool>(NFAM + 1, false)   // already-announced significant edge

var int baseUpN = 0
var int baseUpW = 0
var int baseDnN = 0
var int baseDnW = 0

// HARNESS+ — uniqueness-weighted effective-N + in-sample / out-of-sample overall edge
var float harTotW = 0.0
var float harHitW = 0.0
var int   harIsTot = 0
var int   harIsHit = 0
var int   harOosTot = 0
var int   harOosHit = 0
var int   harResolved = 0

var int   lastEmitBar = -100000
var int   lastFam     = 0

// active-pattern state (for panel + EXP)
var int   actFam   = 0
var int   actDir   = 0
var float actFit   = 0.0
var float actTgt   = na
var int   actBar   = na
var float actAnP   = na      // analog win-probability of the active pattern
var int   actAnK   = 0       // analog neighbours used
var bool  actBoot  = false   // bootstrap (memory immature) vs analog-driven
var string actGrade = "—"    // fused A/B/C setup grade
var float actQ     = na      // breakout quality 0..1
var bool  actSwept = false   // sweep-validated
var int   actPdC   = 0       // location: +1 discount (good for long), -1 premium
var int   actReg   = 3       // regime at emit (1 Trend, 2 Chop, 3 Mixed)
var float actGhostEnd  = na  // nearest analog forward endpoint price
var float actGhostPeak = na  // nearest analog peak price
var float actMotif   = na    // matrix-profile motif strength of the active pattern
var float actConeMed = na    // empirical analog cone: median forward (R)
var float actConeLo  = na    // 25th-percentile forward (R)
var float actConeHi  = na    // 75th-percentile forward (R)

// one-sample z of family proportion vs base proportion p2
f_z(int w1, int n1, float p2) =>
    float z = na
    if n1 >= 5 and not na(p2) and p2 > 0 and p2 < 1
        float p1 = w1 / float(n1)
        float se = math.sqrt(p2 * (1.0 - p2) / n1)
        z := se > 0 ? (p1 - p2) / se : na
    z

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 8 — DETECT, CLASSIFY, EMIT   (confirmed bars only — non-repaint)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

newSig = false
edgeSigFam = 0

if barstate.isconfirmed
    [sel, selP] = f_pip(Lwin)

    if sel.size() == PN
        // normalize PIP prices to 0..1 over the pattern's own range
        float pLo = selP.min()
        float pHi = selP.max()
        float rng = pHi - pLo

        // diagnostic skeleton
        if showSkeleton
            for i = 0 to PN - 2
                int xa = bar_index - ((Lwin - 1) - sel.get(i))
                int xb = bar_index - ((Lwin - 1) - sel.get(i + 1))
                f_pushLine(line.new(xa, selP.get(i), xb, selP.get(i + 1), color = color.new(cDim, 40), style = line.style_dotted, width = 1))

        int   detFam = 0
        int   detDir = 0
        float detFit = 0.0

        if rng > 0
            array<float> v = array.new<float>()
            for i = 0 to PN - 1
                v.push((selP.get(i) - pLo) / rng)

            // ── ENGINE A · fuzzy template match ───────────────────────────────
            [bestFam, bestFit] = f_bestTpl(v)
            if bestFit >= minTplFit
                detFam := bestFam
                detDir := famDir(bestFam)
                detFit := bestFit

            // ── ENGINE B · geometric trend-line fit ───────────────────────────
            // collect PIP local highs/lows (interior points), x in window coords
            array<float> hx = array.new<float>()
            array<float> hy = array.new<float>()
            array<float> lx = array.new<float>()
            array<float> ly = array.new<float>()
            for i = 1 to PN - 2
                float vv = selP.get(i)
                float vl = selP.get(i - 1)
                float vr = selP.get(i + 1)
                if vv > vl and vv > vr
                    hx.push(float(sel.get(i)))
                    hy.push(vv)
                if vv < vl and vv < vr
                    lx.push(float(sel.get(i)))
                    ly.push(vv)

            if hx.size() >= 2 and lx.size() >= 2
                [bH, aH, r2H] = f_fit(hx, hy)
                [bL, aL, r2L] = f_fit(lx, ly)
                float geoR2 = math.min(r2H, r2L)
                if geoR2 >= minR2
                    float xL = math.min(hx.min(), lx.min())
                    float xR = math.max(hx.max(), lx.max())
                    float upL = aH + bH * xL
                    float upR = aH + bH * xR
                    float loL = aL + bL * xL
                    float loR = aL + bL * xR
                    float wL = upL - loL
                    float wR = upR - loR
                    float conv = wL > 0 ? wR / wL : 1.0
                    float sH = bH / math.max(atr, syminfo.mintick)   // ATR/bar
                    float sL = bL / math.max(atr, syminfo.mintick)
                    bool flatH = math.abs(sH) < flatATR
                    bool flatL = math.abs(sL) < flatATR

                    int   gFam = 0
                    int   gDir = 0
                    if conv > 1.5
                        gFam := 14                                   // broadening
                        gDir := 0
                    else if flatH and sL > 0
                        gFam := 7                                    // asc triangle
                        gDir := 1
                    else if flatL and sH < 0
                        gFam := 8                                    // desc triangle
                        gDir := -1
                    else if sH < 0 and sL > 0
                        gFam := 9                                    // sym triangle
                        gDir := 0
                    else if sH > 0 and sL > 0
                        gFam := conv < 0.72 ? 10 : 12                // rising wedge / asc channel
                        gDir := conv < 0.72 ? -1 : 1
                    else if sH < 0 and sL < 0
                        gFam := conv < 0.72 ? 11 : 13                // falling wedge / desc channel
                        gDir := conv < 0.72 ? 1 : -1

                    // geometric confidence: R², but penalized when a line has only
                    // 2 pivots (a 2-point line fits perfectly by construction → fake 100%)
                    float nPen = math.min(hx.size(), lx.size()) >= 3 ? 1.0 : 0.6
                    float gFit = geoR2 * nPen
                    if gFam != 0 and gFit > detFit
                        detFam := gFam
                        detDir := gDir
                        detFit := gFit

            // optional regime veto (family-type based) — cheap, computed BEFORE the
            // analog so the heavy DTW search only runs on genuine emit candidates
            bool isReversal = detFam == 1 or detFam == 2 or detFam == 3 or detFam == 4 or detFam == 5 or detFam == 6 or detFam == 10 or detFam == 11
            bool isCont     = detFam == 7 or detFam == 8 or detFam == 12 or detFam == 13
            bool isRange    = detFam == 9 or detFam == 14                 // sym triangle, broadening
            bool vetoed     = useVeto and ((isReversal and trendy) or (isCont and choppy) or (vetoRange and isRange and choppy))

            // size gate: reject patterns smaller than minPatATR · ATR
            bool bigEnough = rng >= minPatATR * math.max(atr, syminfo.mintick)

            // recency + cooldown (hard floor — no family-change bypass, which let
            // alternating families re-fire the same pattern every few bars)
            int lastW = sel.get(PN - 1)
            bool fresh = (Lwin - 1) - lastW <= freshBars
            bool cool  = (bar_index - lastEmitBar) >= minGap
            bool cheapPass = detFam != 0 and fresh and cool and bigEnough and not vetoed

            // ── ANALOG CONSENSUS · empirical forward-labelled neighbours ──────
            // DTW over the memory is the expensive step — run it ONLY when the cheap
            // gates have already passed (typically once per cooldown, not every bar).
            [anDir, anP, anMFE, anK, anBestFwd, anBestMfe, anMotif, anNNFwd] = f_analog(v, cheapPass)
            bool  memMature = useAnalog and anK >= 1 and not na(anP)
            int   emitDir   = memMature ? anDir : detDir
            float emitConf  = memMature ? nz(anP) : detFit
            // matrix-profile motif gate: withhold novel shapes with no real precedent
            bool  motifOK   = motifMin <= 0.0 or not memMature or (not na(anMotif) and anMotif >= motifMin)

            // ── SMC GATING — sweep validation · breakout quality · location · grade ──
            bool  sweptDir = useSMC and ((emitDir > 0 and not na(lastSweepLoBar) and (bar_index - lastSweepLoBar) <= sweepLook) or (emitDir < 0 and not na(lastSweepHiBar) and (bar_index - lastSweepHiBar) <= sweepLook))
            float patQ     = f_quality(dispAtr, bodyRat, volZ, sweptDir)
            bool  locVeto  = useSMC and useLocVeto and not na(pdPos) and ((emitDir > 0 and pdPos > pdGate) or (emitDir < 0 and pdPos < 1.0 - pdGate))
            bool  locGood  = na(pdPos) ? false : (emitDir > 0 and pdPos < 0.5) or (emitDir < 0 and pdPos > 0.5)
            float wQ       = useQuality ? 0.30 : 0.0
            float wSum     = 0.50 + wQ + 0.10 + 0.10
            float gradeScore = 100.0 * (0.50 * emitConf + wQ * patQ + 0.10 * (sweptDir ? 1.0 : 0.0) + 0.10 * (locGood ? 1.0 : 0.0)) / wSum
            string grade   = emitDir == 0 ? "—" : f_grade(gradeScore)
            bool   gradeOK = (not useSMC) or minGrade == "-" or f_gradeRank(grade) >= f_gradeRank(minGrade)

            // ── EMIT ──────────────────────────────────────────────────────────
            if cheapPass and not locVeto and gradeOK and motifOK
                lastEmitBar := bar_index
                lastFam     := detFam
                actFam      := detFam
                actDir      := emitDir
                actFit      := emitConf
                actBar      := bar_index
                actAnP      := anP
                actAnK      := anK
                actBoot     := not memMature
                actGrade    := grade
                actQ        := patQ
                actSwept    := sweptDir
                actPdC      := na(pdPos) ? 0 : pdPos < 0.38 ? 1 : pdPos > 0.62 ? -1 : 0
                actReg      := regID
                actGhostEnd  := (memMature and not na(anBestFwd)) ? close + anBestFwd * atr : na
                actGhostPeak := (memMature and not na(anBestMfe) and emitDir != 0) ? close + emitDir * anBestMfe * atr : na
                // empirical analog cone — the forward distribution of the k nearest precedents
                actMotif := anMotif
                if memMature and anNNFwd.size() >= 4
                    actConeLo  := array.percentile_linear_interpolation(anNNFwd, 25.0)
                    actConeMed := array.percentile_linear_interpolation(anNNFwd, 50.0)
                    actConeHi  := array.percentile_linear_interpolation(anNNFwd, 75.0)
                else
                    actConeLo  := na
                    actConeMed := na
                    actConeHi  := na

                // target — EMPIRICAL MFE from analogs, else geometric measured move (bootstrap)
                float tgt = na
                if emitDir != 0 and memMature and not na(anMFE)
                    tgt := close + emitDir * anMFE * atr
                else if emitDir != 0
                    if detFam == 1 or detFam == 3 or detFam == 5
                        float neck = selP.min()
                        tgt := neck - (pHi - neck)
                    else if detFam == 2 or detFam == 4 or detFam == 6
                        float neck = selP.max()
                        tgt := neck + (neck - pLo)
                    else
                        tgt := emitDir > 0 ? close + rng : close - rng
                actTgt := tgt

                // colors
                color dc = emitDir > 0 ? cBull : emitDir < 0 ? cBear : cNeu

                // draw the PIP polyline — width & opacity scale with grade/confidence
                if showPattern
                    int   gr   = useSMC ? f_gradeRank(grade) : (emitConf >= 0.6 ? 3 : emitConf >= 0.5 ? 2 : 1)
                    int   lw   = gr >= 4 ? 3 : gr >= 3 ? 2 : 1
                    int   ltrans = gr >= 4 ? 0 : gr >= 3 ? 12 : gr >= 2 ? 30 : 52
                    for i = 0 to PN - 2
                        int xa = bar_index - ((Lwin - 1) - sel.get(i))
                        int xb = bar_index - ((Lwin - 1) - sel.get(i + 1))
                        f_pushLine(line.new(xa, selP.get(i), xb, selP.get(i + 1), color = color.new(dc, ltrans), width = lw))

                    // label at the final pivot — grade + analog probability + sweep tag
                    string arrow  = emitDir > 0 ? "▲" : emitDir < 0 ? "▼" : "◆"
                    string srcTag = memMature ? "P " + str.tostring(emitConf * 100, "0") + "%" : "fit " + str.tostring(emitConf * 100, "0") + "%"
                    string gradeTag = useSMC and emitDir != 0 ? "[" + grade + "] " : ""
                    string swpTag = sweptDir ? " ⚡swept" : ""
                    string ltxt   = arrow + " " + gradeTag + famName(detFam) + "  ·  " + srcTag + swpTag
                    f_pushLabel(label.new(bar_index, emitDir < 0 ? pHi : pLo, ltxt, style = emitDir < 0 ? label.style_label_down : label.style_label_up, color = color.new(dc, gr >= 3 ? 12 : 35), textcolor = isLight ? color.white : #0A0A0A, size = size.small))

                    // ── GHOST OVERLAY — how the single closest historical analog resolved ──
                    if showGhost and memMature and not na(actGhostEnd)
                        int gx = bar_index + horizon
                        f_pushLine(line.new(bar_index, close, gx, actGhostEnd, color = color.new(dc, 62), style = line.style_dotted, width = 1))
                        if not na(actGhostPeak)
                            f_pushLabel(label.new(gx, actGhostPeak, "ghost ▸ " + (anBestFwd >= 0 ? "+" : "") + str.tostring(anBestFwd, "0.0") + "R", style = label.style_label_left, color = color.new(dc, 80), textcolor = cDim, size = size.tiny))

                    // ── EMPIRICAL CONE — forward distribution (25/50/75) of the k nearest precedents ──
                    if showCone and memMature and not na(actConeMed)
                        int cx = bar_index + horizon
                        f_pushLine(line.new(bar_index, close, cx, close + actConeMed * atr, color = color.new(dc, 40), style = line.style_solid,  width = 1))
                        f_pushLine(line.new(bar_index, close, cx, close + actConeHi  * atr, color = color.new(dc, 74), style = line.style_dotted, width = 1))
                        f_pushLine(line.new(bar_index, close, cx, close + actConeLo  * atr, color = color.new(dc, 74), style = line.style_dotted, width = 1))
                        f_pushLabel(label.new(cx, close + actConeMed * atr, "cone " + (actConeLo >= 0 ? "+" : "") + str.tostring(actConeLo, "0.0") + "…" + (actConeHi >= 0 ? "+" : "") + str.tostring(actConeHi, "0.0") + "R", style = label.style_label_left, color = color.new(dc, 86), textcolor = cDim, size = size.tiny))

                    // target line + tag
                    if showTarget and not na(tgt)
                        int tx = bar_index + int(math.round(horizon * 0.75))
                        line tl = line.new(bar_index, tgt, tx, tgt, color = color.new(dc, 30), style = line.style_dashed, width = 1)
                        f_pushLine(tl)
                        f_pushLabel(label.new(tx, tgt, "⌖ " + str.tostring(tgt, format.mintick) + (memMature ? " (analog)" : " (est)"), style = label.style_label_left, color = color.new(dc, 70), textcolor = cTxt, size = size.tiny))

                // queue forward resolution (directional only) — carry the shape for the analog memory
                if emitDir != 0 and not na(atr) and atr > 0.0
                    float uw = 1.0 / (1.0 + pend.size())
                    pend.push(Pend.new(detFam, emitDir, close, atr, bar_index, 0.0, 0.0, false, v, regID, uw))

                newSig := true

// ── per-bar: update & resolve pending patterns ────────────────────────────────
if barstate.isconfirmed and pend.size() > 0
    for i = pend.size() - 1 to 0
        Pend p = pend.get(i)
        if not p.done
            float favor   = p.dir > 0 ? (high - p.entry) : (p.entry - low)
            float adverse = p.dir > 0 ? (p.entry - low)  : (high - p.entry)
            p.mfe := p.atr0 > 0.0 ? math.max(p.mfe, favor   / p.atr0) : p.mfe
            p.mae := p.atr0 > 0.0 ? math.max(p.mae, adverse / p.atr0) : p.mae
            if bar_index - p.bidx >= horizon
                p.done := true
                float fwd = p.dir > 0 ? (close - p.entry) : (p.entry - close)
                bool  win = p.atr0 > 0.0 and fwd >= moveATR * p.atr0
                // HARNESS+ overall: uniqueness-weighted + in-sample / out-of-sample split
                harTotW += p.uniq
                harHitW := win ? harHitW + p.uniq : harHitW
                if harResolved < harTrainN
                    harIsTot += 1
                    harIsHit := win ? harIsHit + 1 : harIsHit
                else
                    harOosTot += 1
                    harOosHit := win ? harOosHit + 1 : harOosHit
                harResolved += 1
                famN.set(p.fam, famN.get(p.fam) + 1)
                if win
                    famW.set(p.fam, famW.get(p.fam) + 1)
                famMFE.set(p.fam, famMFE.get(p.fam) + p.mfe)
                famMAE.set(p.fam, famMAE.get(p.fam) + p.mae)
                // regime-conditional + recency-weighted hit
                int rg = p.reg >= 1 and p.reg <= NREG ? p.reg : 3
                int ri = p.fam * (NREG + 1) + rg
                regFamN.set(ri, regFamN.get(ri) + 1)
                if win
                    regFamW.set(ri, regFamW.get(ri) + 1)
                famNd.set(p.fam, famNd.get(p.fam) * recDecay + 1.0)
                famWd.set(p.fam, famWd.get(p.fam) * recDecay + (win ? 1.0 : 0.0))
                // ── feed the analog memory: this shape, labelled by what happened next ──
                if p.atr0 > 0.0 and p.shape.size() == PN
                    float fwdR     = (close - p.entry) / p.atr0
                    int   realDir  = fwdR > 0 ? 1 : fwdR < 0 ? -1 : 0
                    float peakReal = realDir == p.dir ? p.mfe : p.mae
                    for q = 0 to PN - 1
                        memShape.push(p.shape.get(q))
                    memFam.push(p.fam)
                    memFwd.push(fwdR)
                    memMFEv.push(peakReal)
                    while memFwd.size() > memSize
                        memFwd.shift()
                        memMFEv.shift()
                        memFam.shift()
                        for q = 0 to PN - 1
                            memShape.shift()
                pend.remove(i)

// ── per-bar: base-rate sampling ───────────────────────────────────────────────
if barstate.isconfirmed
    bq.push(Base.new(close, atr, bar_index))
    if bq.size() > 0
        for i = bq.size() - 1 to 0
            Base b = bq.get(i)
            if bar_index - b.bidx >= horizon
                float up = close - b.entry
                float dn = b.entry - close
                baseUpN += 1
                if up >= moveATR * b.atr0
                    baseUpW += 1
                baseDnN += 1
                if dn >= moveATR * b.atr0
                    baseDnW += 1
                bq.remove(i)

float baseUp = baseUpN > 0 ? baseUpW / float(baseUpN) : na
float baseDn = baseDnN > 0 ? baseDnW / float(baseDnN) : na

// HARNESS+ overall metrics — effective sample size, in-sample and out-of-sample edge
float harBaseAvg = (not na(baseUp) and not na(baseDn)) ? (baseUp + baseDn) / 2.0 * 100.0 : na
float harEffN    = harTotW
float harIsHitP  = harIsTot  > 0 ? harIsHit  / float(harIsTot)  * 100.0 : na
float harOosHitP = harOosTot > 0 ? harOosHit / float(harOosTot) * 100.0 : na
float harOosEdge = (not na(harOosHitP) and not na(harBaseAvg)) ? harOosHitP - harBaseAvg : na
float harOosCi   = f_wilsonHalf(harOosHit, harOosTot) * 100.0
bool  harOosStar = harOosTot >= 10 and not na(harOosHitP) and not na(harBaseAvg) and (harOosHitP - harOosCi) > harBaseAvg
// multiple-testing deflated z bar for the per-family significance test
float zDeflFam = nTests <= 1 ? 1.96 : nTests == 2 ? 2.24 : nTests == 3 ? 2.39 : nTests == 4 ? 2.50 : nTests <= 6 ? 2.64 : nTests <= 9 ? 2.77 : 2.94

// detect a newly-significant positive-edge family (deflated bar) (for alert)
if barstate.isconfirmed
    for id = 1 to NFAM
        int d = famDir(id)
        if d != 0 and famN.get(id) >= 5 and not famSig.get(id)
            float bp = d > 0 ? baseUp : baseDn
            float z  = f_z(famW.get(id), famN.get(id), bp)
            float hit = famW.get(id) / float(famN.get(id))
            if not na(z) and z > zDeflFam and not na(bp) and hit > bp
                famSig.set(id, true)
                edgeSigFam := id

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 9 — DASHBOARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// best-edge family (significant first, then by edge)
f_bestEdge() =>
    int   bId = 0
    float bEdge = -1e9
    for id = 1 to NFAM
        int d = famDir(id)
        if d != 0 and famN.get(id) >= 5
            float bp = d > 0 ? baseUp : baseDn
            if not na(bp)
                float hit = famW.get(id) / float(famN.get(id))
                float edge = (hit - bp) * 100.0
                if edge > bEdge
                    bEdge := edge
                    bId := id
    [bId, bEdge]

if showPanel and barstate.islast
    table dash = table.new(parsedPos, 6, 22, bgcolor = cPan, frame_color = isLight ? color.new(#D5DBE2,0) : color.new(#21262D,0), frame_width = 1, border_color = isLight ? color.new(#E3E8EF,0) : color.new(#161B22,0), border_width = 1)
    int r = 0

    table.cell(dash, 0, r, "  PATTERN ANALOGS", text_color = cAcc, bgcolor = cHdr, text_size = size.normal, text_halign = text.align_left, text_formatting = text.format_bold)
    table.cell(dash, 1, r, "", bgcolor = cHdr)
    table.cell(dash, 2, r, "", bgcolor = cHdr)
    table.cell(dash, 3, r, syminfo.ticker + " · " + timeframe.period + " · " + regimeTxt + "  ", text_color = cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 4, r, "", bgcolor = cHdr)
    table.cell(dash, 5, r, "", bgcolor = cHdr)
    table.merge_cells(dash, 0, r, 2, r)
    table.merge_cells(dash, 3, r, 5, r)
    r += 1

    // active pattern
    color adc = actDir > 0 ? cBull : actDir < 0 ? cBear : cNeu
    string aArrow = actDir > 0 ? "▲" : actDir < 0 ? "▼" : actFam == 0 ? "·" : "◆"
    string aTxt = actFam == 0 ? "— none yet" : aArrow + " " + famName(actFam)
    int aAge = na(actBar) ? -1 : bar_index - actBar
    table.cell(dash, 0, r, "  Active", text_color = cDim, bgcolor = cRow, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, aTxt, text_color = adc, bgcolor = cRow, text_size = size.small, text_halign = text.align_left, text_formatting = text.format_bold)
    table.cell(dash, 2, r, "", bgcolor = cRow)
    table.cell(dash, 3, r, actFam == 0 ? "" : (actBoot ? "fit " + str.tostring(actFit*100,"0") + "%" : "P " + str.tostring(actFit*100,"0") + "%" + (na(actMotif) ? "" : " ·m" + str.tostring(actMotif*100,"0"))), text_color = actBoot ? cTxt : adc, bgcolor = cRow, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 4, r, "", bgcolor = cRow)
    table.cell(dash, 5, r, actFam == 0 or aAge < 0 ? "" : str.tostring(aAge) + "b ago ", text_color = cDim, bgcolor = cRow, text_size = size.small, text_halign = text.align_right)
    table.merge_cells(dash, 1, r, 2, r)
    table.merge_cells(dash, 3, r, 4, r)
    r += 1

    table.cell(dash, 0, r, "  Target " + (actBoot ? "(est)" : "(analog)"), text_color = cDim, bgcolor = cRowA, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, (na(actTgt) ? "—" : str.tostring(actTgt, format.mintick)) + (na(actConeMed) ? "" : "  cone " + str.tostring(actConeLo,"0.0") + "…" + str.tostring(actConeHi,"0.0") + "R"), text_color = cTxt, bgcolor = cRowA, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 2, r, "", bgcolor = cRowA)
    table.cell(dash, 3, r, "Analog mem", text_color = cDim, bgcolor = cRowA, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 4, r, "", bgcolor = cRowA)
    table.cell(dash, 5, r, str.tostring(memFwd.size()) + (memFwd.size() >= analogMin ? " ✓ " : " · "), text_color = memFwd.size() >= analogMin ? cBull : cDim, bgcolor = cRowA, text_size = size.small, text_halign = text.align_right)
    table.merge_cells(dash, 1, r, 2, r)
    r += 1

    // best-edge family summary
    [beId, beEdge] = f_bestEdge()
    string beTxt = beId == 0 ? "warming up…" : famName(beId) + "  " + str.tostring(famW.get(beId)) + "/" + str.tostring(famN.get(beId))
    color  beCol = beId == 0 ? cDim : (beEdge > 0 ? cBull : cBear)
    table.cell(dash, 0, r, "  Best edge", text_color = cDim, bgcolor = cRow, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, beTxt, text_color = beCol, bgcolor = cRow, text_size = size.small, text_halign = text.align_left, text_formatting = text.format_bold)
    table.cell(dash, 2, r, "", bgcolor = cRow)
    table.cell(dash, 3, r, beId == 0 ? "" : (beEdge >= 0 ? "+" : "") + str.tostring(beEdge,"0.0") + " ", text_color = beCol, bgcolor = cRow, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 4, r, "", bgcolor = cRow)
    table.cell(dash, 5, r, beId == 0 ? "" : (famSig.get(beId) ? "95%* " : ""), text_color = cAcc, bgcolor = cRow, text_size = size.small, text_halign = text.align_right)
    table.merge_cells(dash, 1, r, 2, r)
    table.merge_cells(dash, 3, r, 4, r)
    r += 1

    // SMC setup grade · quality · sweep validation · location
    if useSMC
        color  grC = (actGrade == "A+" or actGrade == "A") ? cBull : actGrade == "B" ? cAcc : actGrade == "C" ? cNeu : cDim
        string locTxt = actPdC > 0 ? "Discount" : actPdC < 0 ? "Premium" : "Equil"
        color  locC = actPdC > 0 ? cBull : actPdC < 0 ? cBear : cDim
        table.cell(dash, 0, r, "  Setup grade", text_color = cDim, bgcolor = cRowA, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, r, actFam == 0 ? "—" : actGrade + (na(actQ) ? "" : "  Q" + str.tostring(math.round(actQ * 100))), text_color = grC, bgcolor = cRowA, text_size = size.small, text_halign = text.align_left, text_formatting = text.format_bold)
        table.cell(dash, 2, r, "", bgcolor = cRowA)
        table.cell(dash, 3, r, actFam == 0 ? "" : (actSwept ? "⚡ swept" : "no sweep"), text_color = actSwept ? cBull : cDim, bgcolor = cRowA, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 4, r, "", bgcolor = cRowA)
        table.cell(dash, 5, r, (actFam == 0 ? "—" : locTxt) + " ", text_color = locC, bgcolor = cRowA, text_size = size.small, text_halign = text.align_right)
        table.merge_cells(dash, 1, r, 2, r)
        table.merge_cells(dash, 3, r, 4, r)
        r += 1

    // active family — regime-conditional + recency-weighted hit (the calibration that matters now)
    if actFam != 0
        int    ri  = actFam * (NREG + 1) + actReg
        int    rn  = regFamN.get(ri)
        int    rw  = regFamW.get(ri)
        float  rh  = rn > 0 ? rw / float(rn) * 100.0 : na
        float  rwl = f_wilsonHalf(rw, rn)
        float  rec = famNd.get(actFam) >= 1.0 ? famWd.get(actFam) / famNd.get(actFam) * 100.0 : na
        string rcTxt = "in " + f_regName(actReg) + ": " + (na(rh) ? "·" : str.tostring(rh,"0") + "%" + (na(rwl) ? "" : "±" + str.tostring(rwl*100,"0")) + " (" + str.tostring(rn) + ")")
        table.cell(dash, 0, r, "  This family", text_color = cDim, bgcolor = cRow, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, r, rcTxt, text_color = na(rh) ? cDim : cTxt, bgcolor = cRow, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 2, r, "", bgcolor = cRow)
        table.cell(dash, 3, r, "recent", text_color = cDim, bgcolor = cRow, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 4, r, "", bgcolor = cRow)
        table.cell(dash, 5, r, (na(rec) ? "· " : str.tostring(rec,"0") + "% "), text_color = na(rec) ? cDim : cTxt, bgcolor = cRow, text_size = size.small, text_halign = text.align_right)
        table.merge_cells(dash, 1, r, 2, r)
        table.merge_cells(dash, 3, r, 4, r)
        r += 1

    // ── Pro: full calibration table ──────────────────────────────────────────
    if panelMode == "Pro"
        table.cell(dash, 0, r, "  Pattern", text_color = cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, r, "n",    text_color = cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 2, r, "Hit%", text_color = cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 3, r, "Base%",text_color = cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 4, r, "Edge", text_color = cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 5, r, "MFE/MAE ", text_color = cDim, bgcolor = cHdr, text_size = size.small, text_halign = text.align_right)
        r += 1

        // rank directional families by edge
        array<int>   rid = array.new<int>()
        array<float> red = array.new<float>()
        for id = 1 to NFAM
            int d = famDir(id)
            if d != 0 and famN.get(id) > 0
                float bp = d > 0 ? baseUp : baseDn
                float hit = famW.get(id) / float(famN.get(id))
                float edge = na(bp) ? -1e8 : (hit - bp) * 100.0
                rid.push(id)
                red.push(edge)
        // simple selection sort (small n)
        int m = rid.size()
        if m > 1
            for i = 0 to m - 2
                for j = 0 to m - 2 - i
                    if red.get(j) < red.get(j + 1)
                        float te = red.get(j)
                        red.set(j, red.get(j + 1))
                        red.set(j + 1, te)
                        int ti = rid.get(j)
                        rid.set(j, rid.get(j + 1))
                        rid.set(j + 1, ti)

        int shown = math.min(calRows, m)
        if shown > 0
            for k = 0 to shown - 1
                int id = rid.get(k)
                int d  = famDir(id)
                int n  = famN.get(id)
                float hit = famW.get(id) / float(n)
                float bp  = d > 0 ? baseUp : baseDn
                float edge = na(bp) ? na : (hit - bp) * 100.0
                float z = f_z(famW.get(id), n, bp)
                bool sig = not na(z) and math.abs(z) > 1.96
                float mfe = famMFE.get(id) / n
                float mae = famMAE.get(id) / n
                color rbg = k % 2 == 0 ? cRow : cRowA
                color ec  = na(edge) ? cFlat : (sig ? (edge > 0 ? cBull : cBear) : cFlat)
                string warm = n < 5 ? "·" : ""
                table.cell(dash, 0, r, "  " + (d > 0 ? "▲ " : "▼ ") + famShort(id), text_color = cTxt, bgcolor = rbg, text_size = size.tiny, text_halign = text.align_left)
                table.cell(dash, 1, r, str.tostring(n) + warm, text_color = cSub, bgcolor = rbg, text_size = size.tiny, text_halign = text.align_right)
                table.cell(dash, 2, r, str.tostring(hit*100,"0") + "%" + (n >= 5 and not na(f_wilsonHalf(famW.get(id), n)) ? "±" + str.tostring(f_wilsonHalf(famW.get(id), n)*100,"0") : ""), text_color = cTxt, bgcolor = rbg, text_size = size.tiny, text_halign = text.align_right)
                table.cell(dash, 3, r, na(bp) ? "—" : str.tostring(bp*100,"0") + "%", text_color = cSub, bgcolor = rbg, text_size = size.tiny, text_halign = text.align_right)
                table.cell(dash, 4, r, na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(edge,"0.0") + (sig ? "*" : ""), text_color = ec, bgcolor = rbg, text_size = size.tiny, text_halign = text.align_right)
                table.cell(dash, 5, r, str.tostring(mfe,"0.0") + "/" + str.tostring(mae,"0.0") + " ", text_color = cSub, bgcolor = rbg, text_size = size.tiny, text_halign = text.align_right)
                r += 1

        table.cell(dash, 0, r, "  Hit% ±Wilson95 · Edge=Hit−Base · *=95% sig · MFE/MAE in R · ·=n<5", text_color = cDim, bgcolor = cPan, text_size = size.tiny, text_halign = text.align_left)
        for cc = 1 to 5
            table.cell(dash, cc, r, "", bgcolor = cPan)
        table.merge_cells(dash, 0, r, 5, r)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 10 — ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if alPattern and newSig and barstate.isconfirmed
    alert("Pattern Analogs: " + famName(actFam) + " confirmed (" + (actDir > 0 ? "bull" : actDir < 0 ? "bear" : "neutral") + ", fit " + str.tostring(actFit*100,"0") + "%) on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

if alEdge and edgeSigFam != 0 and barstate.isconfirmed
    alert("Pattern Analogs: " + famName(edgeSigFam) + " crossed 95% significance with positive edge on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 11 — EXPORTS (Data Window)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float expFamHit = actFam != 0 and famN.get(actFam) > 0 ? famW.get(actFam) / float(famN.get(actFam)) * 100.0 : na
float expEdge   = na
if actFam != 0 and famDir(actFam) != 0 and famN.get(actFam) >= 5
    float bp = famDir(actFam) > 0 ? baseUp : baseDn
    expEdge := na(bp) ? na : (famW.get(actFam)/float(famN.get(actFam)) - bp) * 100.0

plot(showEXP ? actFam : na,            "EXP_PatCode",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? actDir : na,            "EXP_PatDir",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? actFit * 100.0 : na,    "EXP_FitPct",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? actTgt : na,            "EXP_Target",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expFamHit : na,         "EXP_FamHitPct", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expEdge : na,           "EXP_FamEdge",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (na(actAnP) ? na : actAnP * 100.0) : na, "EXP_AnalogP", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(memFwd.size()) : na, "EXP_AnalogMem", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(f_gradeRank(actGrade)) : na, "EXP_Grade",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (na(actQ) ? na : actQ * 100.0) : na,  "EXP_Quality", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (actSwept ? 1.0 : 0.0) : na,          "EXP_Swept",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(actPdC) : na,                   "EXP_PremDisc",color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (na(actMotif) ? na : actMotif * 100.0) : na, "EXP_Motif", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? actConeMed : na,                      "EXP_ConeMed", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? harOosEdge : na,                      "EXP_EdgeOOS", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? harEffN : na,                         "EXP_EffN",    color = color.new(color.gray, 100), display = display.data_window)
````
