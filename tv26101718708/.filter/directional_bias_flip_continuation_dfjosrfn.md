# Directional Bias, Flip & Continuation

- url: https://www.tradingview.com/script/dfjosrfn-Directional-Bias-Flip-Continuation/
- type: indicator
- pine_id: PUB;1344cfb17ac24360858f721c099090b7
- version: 2.0

## Description

█ OVERVIEW

Directional Bias, Flip & Continuation is a single decision instrument that answers one question at a time — "which side, and is this a FLIP (reversal) or a CONTINUATION?" — and draws the exact levels that define the read: Trigger, stop, and two targets. Its loudest and most frequent output is STAND ASIDE: by design it spends most of its time telling you there is no clean read, rather than manufacturing one. It issues no buy/sell order and makes no promise; the confidence it shows is an in-script, past-only forward self-test with a Wilson lower bound on THIS chart, not a trained probability.

█ HOW IT WORKS

The tool resolves ONE of four states each confirmed bar, in strict priority order, so the states never contradict each other:

STAND ASIDE (checked first, fires most) — a chaos / extreme-volatility regime, a toxic-tape reading, or price sitting mid-range with no level nearby. This is the default; it is information, not a failure.
FLIP — a confirmed swing trend-flip that occurs AT a graded major level, with order flow not strongly opposed. The side is the flip direction.
CONTINUATION — a trending regime PLUS a confirmed structural break carrying strength PLUS higher-timeframe agreement PLUS price not already stretched into a level. The side is the trend.
CONFLICT — the engines disagree; shown transparently, with no side taken.

Each stage names the method it uses, and every calibrated block shares one scale rather than being independent indicators bolted together:

Regime brain — efficiency ratio (fast vs slow) + ADX with separate trend and strong-trend floors + a self-excitation / volatility-cluster gauge + a variance-ratio random-walk test + an Ornstein-Uhlenbeck mean-reversion read. A trend must clear BOTH persistence (ER) and strength (ADX) floors, so ordinary chop never reads as a strong trend.
Flip engine — a swing-structure trend flip scored by a composite (structure, momentum, location) with a kill state that vetoes flips in the wrong regime.
Continuation engine — a convex-hull channel break, validated for strength and for higher-timeframe alignment, with a stretch guard so a break into an opposing level is not chased.
Levels & targets — a multi-anchor VWAP / anchored-volume-profile ladder that snaps the Trigger, stop and two targets to real liquidity rather than fixed multiples.
Barriers & confidence — a volatility-scaled, regime-asymmetric profit-target / stop geometry, and a forward reject-vs-continue self-test (two-barrier race) that reports each mode's hit rate with a Wilson 95% lower bound and against a matched base rate; it stays "uncalibrated / warming" until the sample is large enough.
Flow proxy — a lower-timeframe signed-volume CVD estimate (Bulk-Volume-Classification fallback) used only to veto a side that fights strong opposing flow; it abstains on no-volume symbols.

█ HOW TO USE

Read the panel top-down: the state (STAND ASIDE / FLIP / CONTINUATION / CONFLICT) and side, then the confidence line, then the four levels. When a FLIP or CONTINUATION is live, the Trigger / SL / TP1 / TP2 are the levels that define it; when the state is STAND ASIDE they read "—" on purpose. The confidence line shows that mode's own forward-tested floor with its sample size, and says "uncalibrated" until there is enough history — treat a warming or low-confidence read as a reason to wait. The dashboard defaults to Compact (state, side, confidence and the four levels only); switch Dashboard detail to Pro to add the regime, engine-agreement, flow-toxicity and free-text detail rows, and enable the backtest strip to see each mode's forward win% and average R. STAND ASIDE dominating the tape is the tool working, not failing. Horizon and position sizing are yours; it places no orders.

█ INPUTS

00 · Data & Source — price source, borrow-volume symbol for volume-less instruments.
01 · Regime brain — ER fast/slow horizons, ADX length and trend / strong-trend floors, ER floors, volatility-cluster length.
02–05 · Flip / Continuation / Structure — swing length, break validation, HTF timeframe and agreement, stretch guard.
06 · Levels & targets — VWAP / AVP anchors, ladder, snap tolerance, barrier multiples.
07 · Confidence & calibration — reject/continue barrier size, horizon, minimum sample, edge-gate window.
08 · Flow proxy — LTF granularity, classifier, toxicity gate.
09 · Display — dashboard detail (Compact default / Pro), backtest strip, regime breakdown, markers, panel position.
10 · Style — Dark / Light theme.

█ HONESTY & LIMITATIONS

This is a study, not a strategy. The confidence figure is an in-sample, descriptive, forward self-test on visible history with fixed barriers and no costs or slippage — it is not a backtest and not a probability of your next trade working. Order-flow side is an OHLCV estimate and abstains on symbols without volume. Non-repaint by construction: all higher- and lower-timeframe reads use lookahead-off; pivots confirm several bars late; the verdict, its levels, and the outcome tracking all resolve on confirmed bars only, and prior-period levels use the standard non-repainting prior-bar idiom. When the sample is small the confidence is shown as uncalibrated and the read is discounted; when there is no clean setup the tool says STAND ASIDE rather than inventing one. No edge shown is honest, not broken.

█ ORIGINALITY

One coherent decision object, not a signal stack. The original contribution is the strict-priority four-state resolution — STAND ASIDE is evaluated first and dominates, so FLIP and CONTINUATION can only fire when the regime, structure, location and flow all agree — paired with a per-mode confidence that is measured on the chart by a Wilson-bounded forward self-test rather than asserted. Each block (regime, flip, continuation, levels, barriers, flow) exists only to feed that single verdict and its levels; none is presented as a standalone indicator. That combination — a location-aware, regime-gated flip-vs-continuation decision that grades and honestly discounts its own confidence, and whose default answer is "stand aside" — is what distinguishes it from a trend filter, a breakout signal, or a bundle of oscillators.

█ CREDITS

Efficiency ratio — Kaufman. ADX / DMI — Wilder. Variance-ratio random-walk test — Lo & MacKinlay. Mean reversion — Ornstein & Uhlenbeck. Self-exciting clustering — Hawkes. Volume-weighted average price / value-area concepts — Market Profile lineage. Bulk Volume Classification — Easley, López de Prado & O'Hara. Trade-side tick rule — Lee & Ready (1991). Two-barrier forward test — López de Prado. Wilson score interval — Wilson (1927). Code written from scratch; no external script reused.

This script is for analysis and education. It is not financial advice.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
//  Directional Bias, Flip & Continuation                                   v0.3
//  shorttitle: DBFC                                                Pine Script v6
// ──────────────────────────────────────────────────────────────────────────────
//  v0.3 — adds MTF FLOW ALIGNMENT LADDER (group 10): a 3-rung agreement stack (chart + 3× + 5×) of
//    robust-z net-buying pressure, richer than the 2 HTF bias frames. Its signed agreement (−3..+3) and
//    a fused 0–100 conviction filter signals that FIGHT the multi-timeframe flow (a flip or continuation
//    is suppressed when the ladder is strongly opposed). Shown on the panel ("MTF flow" + an M flag on
//    the Agreement row). Non-repainting (HTF pulled lookahead-off).
//  v0.2 — adds FLOW/PRICE LEAD-LAG (Lévy area, group 06): the signed area of the joint flow/price path
//    reads WHO MOVES FIRST — FLOW leads (participation precedes price) vs PRICE leads (flow chasing).
//    Shown on the panel ("Flow lead") and used to suppress a CHASE-break continuation when price is
//    leading (the squeeze / failed-break trap). Single-instrument, self-calibrated, non-repainting.
// ──────────────────────────────────────────────────────────────────────────────
//  WHAT THIS IS
//    A SELF-CONTAINED decision instrument. It answers one question at a time —
//    "which side, and is this a FLIP (reversal) or a CONTINUATION?" — and draws
//    the precise levels that define it (Trigger / SL / TP1 / TP2). Its loudest,
//    most frequent output is STAND ASIDE: the read that keeps you off the wrong
//    side of the tape.
//
//  THE FOUR-STATE DECISION CORE (resolved in strict order)
//    1 STAND ASIDE — chaos/extreme-vol regime, toxic tape, or price mid-range
//                    with no level nearby. Fires often, by design.
//    2 FLIP        — SW50 trend flip confirmed AT a major level, graded, with
//                    flow not strongly opposed. Side = flip direction.
//    3 CONTINUATION— trending regime + confirmed structural break with strength
//                    + HTF agreement + not stretched into a level. Side = trend.
//    4 CONFLICT    — engines disagree; shown, no side taken.
//
//  SELF-CONTAINED — recomputes its own regime, HTF bias, VWAP/POC, swing
//    structure, convex-hull channel, order-flow proxy and barriers internally.
//    No external inputs, no bus. Every calibrated block is transplanted from the
//    author's own forward-tested engines (see MODULE CREDITS below).
//
//  MODULE CREDITS (transplanted, calibrated blocks — author's own prior work)
//    Regime brain      ← Trend Efficiency Exhaustion (ER+ADX+Hawkes+VR+OU)
//    Flip engine       ← NIFTY Apex (SW50 flip, composite score, kill state)
//    Continuation      ← Self-Calibrating Channel Breaks (convex hull + harness)
//    Levels / TP       ← author's multi-anchor VWAP engine (VWAP, AVP, ladder, snap)
//    Barriers / conf.  ← AEGIS v2 (vol-scaled regime-asymmetric PT/SL, Wilson)
//    Flow proxy        ← VFDO (LTF signed-volume CVD, BVC fallback)
//
//  NON-REPAINT
//    All HTF/LTF reads use lookahead_off; pivots confirm pivotLen bars late;
//    the verdict and its outcome tracking resolve on confirmed bars only.
//
//  DISCLAIMER
//    EDUCATIONAL / INFORMATIONAL only. NOT financial advice, NOT a signal, NOT a
//    recommendation. Confidence is an in-script forward self-test (Wilson-bounded
//    hit rate on THIS chart), not a trained probability or a guarantee. Forward
//    stats are in-sample, fixed-barrier, no costs/slippage. Markets carry risk;
//    you alone are responsible for your decisions.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Directional Bias, Flip & Continuation", "DBFC",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 300,
     max_bars_back    = 5000,
     dynamic_requests = true)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 0 — INPUTS
// ══════════════════════════════════════════════════════════════════════════════
gSrc = "00 · Data & Source"
src        = input.source(hlc3, "Price source", group = gSrc)
volBorrow  = input.symbol("", "Borrow volume from symbol (no-volume fix)", group = gSrc, tooltip = "For volume-less symbols (e.g. spot index). Leave blank to use native volume.")

gReg = "01 · Regime brain"
erFastL  = input.int(10, "ER fast horizon", minval = 3, maxval = 60, group = gReg)
erSlowL  = input.int(30, "ER slow horizon", minval = 10, maxval = 200, group = gReg)
adxLen   = input.int(14, "ADX length", minval = 5, maxval = 50, group = gReg)
adxTrend = input.float(20, "ADX: trend floor", minval = 12, maxval = 30, step = 1, group = gReg, tooltip = "ADX below this = no trend (chop). 20 is the classic threshold.")
adxStrong= input.float(28, "ADX: strong-trend floor", minval = 22, maxval = 45, step = 1, group = gReg, tooltip = "ADX at/above this AND rising = strong trend. Set well above 25 so ordinary chop (ADX 20-27) never reads as STRONG.")
erTrendMin = input.float(0.35, "ER: trend floor", minval = 0.15, maxval = 0.6, step = 0.02, group = gReg, tooltip = "Efficiency-ratio floor for a trend. ER and ADX must BOTH clear their floors — a trend needs persistence and strength, not just one.")
erStrongMin= input.float(0.50, "ER: strong-trend floor", minval = 0.3, maxval = 0.8, step = 0.02, group = gReg)
hvLen    = input.int(20, "Vol-cluster TR-MA", minval = 5, maxval = 100, group = gReg)
hvShock  = input.float(1.6, "Vol shock (×TR-MA)", minval = 1.1, maxval = 4.0, step = 0.1, group = gReg)
hvBeta   = input.float(0.08, "Vol-cluster decay (β)", minval = 0.02, maxval = 1.0, step = 0.01, group = gReg, tooltip = "Lower = longer memory / less twitchy. Raised memory (0.08) stops quiet tape reading as CHAOS.")
chaosPct = input.float(92, "Chaos percentile", minval = 50, maxval = 99, step = 1, group = gReg, tooltip = "Vol-cluster intensity above this percentile = CHAOS. Higher = CHAOS reserved for genuine shocks.")
vrLen    = input.int(120, "Variance-ratio window", minval = 30, maxval = 400, group = gReg)
vrQ      = input.int(4, "Variance-ratio period q", minval = 2, maxval = 16, group = gReg)
ouLen    = input.int(60, "OU half-life window", minval = 20, maxval = 300, group = gReg)

gHTF = "02 · Higher-timeframe bias"
useHTF   = input.bool(true, "Use HTF bias (2 frames)", group = gHTF)
htf1Mult = input.int(5,  "HTF1 = chart ×", minval = 2, maxval = 20, group = gHTF)
htf2Mult = input.int(15, "HTF2 = chart ×", minval = 3, maxval = 60, group = gHTF)
htfEmaLen= input.int(50, "HTF trend length", minval = 10, maxval = 200, group = gHTF)

gFlip = "03 · Flip engine"
useFlip     = input.bool(true, "Enable flip engine", group = gFlip)
swLen       = input.int(50, "SW50 lookback", minval = 5, group = gFlip)
sw150Len    = input.int(150, "SW150 lookback", minval = 10, group = gFlip)
sw200Len    = input.int(200, "SW200 lookback", minval = 10, group = gFlip)
flipMinTier = input.string("A", "Min flip tier", options = ["S","A","B","C","D","OFF"], group = gFlip)
flipMinExt  = input.float(0.8, "Min move into pivot (× ATR)", minval = 0.0, maxval = 3.0, step = 0.1, group = gFlip, tooltip = "Reject flips off a shallow swing — the leg into the pivot must span at least this many ATR. Kills 1m/2m noise-flips off tiny wiggles.")
flipProx    = input.float(0.8, "Flip level proximity (× ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = gFlip, tooltip = "How close the flip pivot must be to a major level to count as at-level. High-tier (S/A) flips fire even without a level.")
flipLTF     = input.bool(true, "Check LTF flip cascade (2 sec. calls)", group = gFlip)
flipLTF1Div = input.string("/3", "LTF1 divisor", options = ["/2","/3","/4","/5"], group = gFlip)
flipLTF2Div = input.string("/5", "LTF2 divisor", options = ["/3","/4","/5","/10"], group = gFlip)
flipLTFrec  = input.int(3, "LTF flip recency (bars)", minval = 1, maxval = 20, group = gFlip)

gCont = "04 · Continuation engine (convex hull)"
useCont    = input.bool(true, "Enable continuation engine", group = gCont)
contMode   = input.string("Fade failed break", "Break behaviour", options = ["Fade failed break", "Chase break"], group = gCont, tooltip = "On Nifty, chasing breaks bled ~-0.3R (breaks mean-revert). 'Fade failed break' fires when a break reclaims back inside the channel within the fade window, and takes the reversion side. Switch to 'Chase break' to compare on the strip.")
fadeWin    = input.int(10, "Failed-break window (bars)", minval = 1, maxval = 30, group = gCont, tooltip = "A break that closes back inside the channel within this many bars = failed break → fade it. Wider = more fades.")
autoPivot  = input.bool(true, "Auto-scale pivots to timeframe", group = gCont)
pivotMin   = input.int(40, "Target structure window (min)", minval = 5, maxval = 240, group = gCont)
pivManual  = input.int(8, "Pivot length (manual)", minval = 2, maxval = 50, group = gCont)
hullWin    = input.int(20, "Hull window (recent pivots)", minval = 4, maxval = 60, group = gCont)
minSlope   = input.float(0.02, "Min slope (ATR/bar)", minval = 0.0, maxval = 1.0, step = 0.01, group = gCont)
maxSlope   = input.float(2.0, "Max slope (ATR/bar)", minval = 0.2, maxval = 10.0, step = 0.1, group = gCont)
touchTol   = input.float(0.5, "Touch tolerance (× ATR)", minval = 0.1, maxval = 2.0, step = 0.1, group = gCont)
breakBuf   = input.float(0.15, "Break buffer (× ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = gCont)
dispATR    = input.float(1.0, "Displacement (× ATR)", minval = 0.2, maxval = 3.0, step = 0.1, group = gCont)
antiWick   = input.float(0.55, "Anti-wick close position (0-1)", minval = 0.5, maxval = 0.9, step = 0.05, group = gCont)

gLev = "05 · Levels & TP anchors"
showAVP    = input.bool(true, "Anchored volume profile (POC/VAH/VAL)", group = gLev)
avpLookback= input.int(150, "AVP lookback (bars)", minval = 20, maxval = 1500, group = gLev)
vpBins     = input.int(24, "Profile bins", minval = 10, maxval = 80, group = gLev)
vaPctIn    = input.float(70, "Value-area %", minval = 50, maxval = 95, step = 1, group = gLev)
showLadder = input.bool(true, "Prior day/week ladder (PDH/PDL/PWH/PWL)", group = gLev)
stretchZ   = input.float(2.0, "Stretched-into-level (σ)", minval = 1.0, maxval = 4.0, step = 0.5, group = gLev)

gFlow = "06 · Flow proxy"
useFlow    = input.bool(true, "Use LTF signed-volume flow", group = gFlow)
lowerTF    = input.timeframe("1", "Lower timeframe", group = gFlow)
bvcLen     = input.int(20, "Fallback estimate window", minval = 5, maxval = 100, group = gFlow)
toxWin     = input.int(50, "Toxicity (VPIN) window", minval = 10, group = gFlow)
toxHigh    = input.float(0.50, "Toxic-tape veto level", minval = 0.1, maxval = 0.95, step = 0.05, group = gFlow)
// ── Flow/price lead-lag (Lévy area) — ported from the Lévy-Area Flow Sequencer / MADP engine ──
leadOn     = input.bool(true, "Flow/price lead-lag (Lévy area)", group = gFlow, tooltip = "Signed (Lévy) area of the joint flow/price path — a path-signature read of WHO MOVES FIRST. A>0 = FLOW leads (participation precedes price; breakouts better backed); A<0 = PRICE leads (flow chasing — squeeze / stop-run character). Shown on the panel; optionally filters chase-continuations. Single-instrument, non-repainting, self-calibrated. Sequencing tendency, not causation.")
levyWin    = input.int(50, "  Lévy window (bars)", minval = 10, maxval = 300, group = gFlow)
levySmooth = input.int(3, "  Lévy smoothing", minval = 1, maxval = 20, group = gFlow)
levyLook   = input.int(300, "  Lévy self-calibration lookback", minval = 50, maxval = 2000, group = gFlow)
levySigLvl = input.float(75.0, "  Lead declared above (|area| pct)", minval = 50.0, maxval = 99.0, step = 1.0, group = gFlow)
leadFiltC  = input.bool(true, "  Filter chase-continuations when PRICE leads", group = gFlow, tooltip = "When ON and the read is PRICE-leads (flow chasing), a 'Chase break' continuation is suppressed — chasing a break while flow is chasing price is the squeeze / failed-break trap. Fade-mode continuations and flips are unaffected.")

gBar = "07 · Barriers / SL·TP (AEGIS)"
bU       = input.float(1.5, "Profit-take ×σ", minval = 0.2, maxval = 10.0, step = 0.1, group = gBar)
bD       = input.float(1.5, "Stop-loss ×σ", minval = 0.2, maxval = 10.0, step = 0.1, group = gBar)
volMode  = input.string("ATR", "σ source", options = ["ATR", "EWMA returns"], group = gBar)
volLenB  = input.int(14, "σ length", minval = 5, group = gBar)
regAsym  = input.bool(true, "Regime-asymmetric widths", group = gBar)
tp2Mult  = input.float(2.2, "TP2 = TP1 ×", minval = 1.2, maxval = 4.0, step = 0.1, group = gBar)
snapTP   = input.bool(true, "Snap TP to nearest level", group = gBar)
snapTol  = input.float(0.6, "Snap tolerance (× ATR)", minval = 0.1, maxval = 2.0, step = 0.1, group = gBar)
flipTPmul= input.float(0.7, "FLIP profit-take × (of PT)", minval = 0.3, maxval = 1.5, step = 0.05, group = gBar, tooltip = "Reversals pay quick then fade — flip TP is this fraction of the base PT. <1 books faster.")
flipHorMul= input.float(0.6, "FLIP timeout × (of horizon)", minval = 0.2, maxval = 1.5, step = 0.1, group = gBar, tooltip = "Flips time out faster than continuations. <1 = shorter reversal hold.")
useConf   = input.bool(true, "Conformal exits (adaptive TP/SL from realized errors)", group = gBar, tooltip = "Sizes TP/SL from the EMPIRICAL distribution of recent forecast errors (conformal prediction) instead of a fixed vol-multiple. TP at a coverage quantile the move usually reaches; SL at a tighter one. Adapts to the symbol's own behaviour. Transplanted from Self-Calibrating Probability Channel.")
confWinN  = input.int(200, "Conformal: error window", minval = 40, maxval = 1000, group = gBar, tooltip = "How many recent forecast errors size the bands.")
confTPq   = input.float(0.70, "Conformal: TP coverage", minval = 0.5, maxval = 0.95, step = 0.05, group = gBar, tooltip = "TP placed at this quantile of favorable moves — where price usually reaches. Higher = further TP, lower hit-rate.")
confSLq   = input.float(0.85, "Conformal: SL coverage", minval = 0.6, maxval = 0.98, step = 0.02, group = gBar, tooltip = "SL placed at this quantile of adverse moves — beyond normal noise. Higher = wider stop, fewer premature stops.")

gDec = "08 · Decision core"
contMinStrength = input.int(2, "Continuation: min hull touches", minval = 1, maxval = 6, group = gDec, tooltip = "Break line must have at least this many touches to count as strength.")
flowVeto   = input.bool(true, "Veto FLIP when flow strongly opposes", group = gDec)
requireHTFcont = input.bool(true, "Continuation requires HTF agreement", group = gDec)
calHorizon = input.int(20, "Confidence: forward horizon (bars)", minval = 5, maxval = 100, group = gDec)
calMinSamp = input.int(5, "Confidence: min samples", minval = 3, maxval = 50, group = gDec)
edgeGate   = input.bool(false, "Edge-gate: mute a mode that stops paying", group = gDec, tooltip = "OFF by default during data-gathering — the whole-mode gate starved signals by muting a mode whose losses were concentrated in ONE regime. Turn on once the regime grid is populated. Uses a ROLLING window with hysteresis (auto-un-mute).")
edgeWin    = input.int(25, "Edge-gate: rolling window (verdicts)", minval = 8, maxval = 100, group = gDec, tooltip = "Only the last N decisive verdicts of each mode count toward the gate.")
edgeMute   = input.float(0.34, "Edge-gate: MUTE below win-rate", minval = 0.0, maxval = 0.9, step = 0.02, group = gDec, tooltip = "Mute a mode when its rolling win-rate falls below this. Below break-even (~0.40 at 1.5:1) with margin so a losing streak has to be real.")
edgeUnmute = input.float(0.44, "Edge-gate: UN-MUTE above win-rate", minval = 0.0, maxval = 0.95, step = 0.02, group = gDec, tooltip = "Un-mute once rolling win-rate recovers above this. Gap vs MUTE = hysteresis, stops on/off flicker.")

gVis = "09 · Visuals"
drawLevels = input.bool(true, "Draw Trigger / SL / TP lines", group = gVis, tooltip = "Off = verdict panel only (clean chart); levels still shown in the panel text.")
showPanel  = input.bool(true, "Show verdict panel", group = gVis)
dashMode   = input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = gVis, tooltip = "Compact (default): side/state, confidence, and Trigger/SL/TP1/TP2 only — a clean minimal panel. Pro: adds Regime·vol, Agreement, Flow·toxicity and Detail rows.")
showBT     = input.bool(true, "Show backtest strip (win% + avg R by mode)", group = gVis, tooltip = "Bottom-left. Forward triple-barrier outcomes of latched FLIP/CONT verdicts on THIS chart. In-sample, fixed-barrier, no costs — a study aid, not a live P&L.")
showRegBrk = input.bool(true, "Show regime × mode breakdown", group = gVis, tooltip = "Extends the strip with Avg R split by regime (Trend / Neutral / Reversion). This is the map for deciding WHERE each engine should be allowed to fire.")
panelPos   = input.string("Top Right", "Panel position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gVis)
panelTheme = input.string("Auto", "Panel theme", options = ["Auto","Dark","Light"], group = gVis)
colBull    = input.color(#21dfac, "Bullish", group = gVis)
colBear    = input.color(#df216d, "Bearish", group = gVis)
colFlat    = input.color(#8b949e, "Neutral", group = gVis)

gMTF = "10 · MTF alignment (ladder)"
mtfOn      = input.bool(true, "Cross-timeframe flow alignment", group = gMTF, tooltip = "A ladder of net buying-pressure z-scores on the CHART timeframe and its 3× / 5× higher multiples (a proper agreement stack, richer than the 2 HTF bias frames). Their agreement (mtfAlign, −3..+3) and a fused conviction (0–100) filter signals that fight the multi-timeframe flow. Single-instrument, non-repainting (HTF pulled with lookahead off).")
mtfLen     = input.int(20, "  Flow z window", minval = 5, maxval = 100, group = gMTF, tooltip = "Robust-z (median/MAD) window for each rung's candle-geometry delta.")
mtfNeut    = input.float(0.25, "  Neutral deadzone (|z|)", minval = 0.0, maxval = 1.5, step = 0.05, group = gMTF, tooltip = "A rung reads neutral (neither side) while its |z| is below this — stops tiny flickers from counting as agreement.")
mtfLoGain  = input.float(0.9, "  Conviction gain", minval = 0.2, maxval = 3.0, step = 0.1, group = gMTF, tooltip = "Log-odds gain converting the mean ladder z into a 0–100 conviction.")
mtfGate    = input.bool(true, "  Suppress signals that fight the stack", group = gMTF, tooltip = "ON: a flip or continuation is blocked when the ladder is STRONGLY opposed to it (alignment against the trade by at least the threshold below). 'Trade with the multi-timeframe flow, not against it.'")
mtfOppose  = input.int(2, "  Oppose threshold (of 3)", minval = 1, maxval = 3, group = gMTF, tooltip = "How many rungs must be against the trade for the gate to block it. 2 = a clear majority of the 3-rung ladder opposes.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — PURE HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_luma(color c) => na(c) ? 0.0 : color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114

// seed-EMA (starts at first real value, no long warmup) — for the Lévy-area smoothing
f_emaSeed(float x, simple int len) =>
    var float e = na
    float a = 2.0 / (len + 1)
    e := na(x) ? e : na(e) ? x : e + a * (x - e)
    e

// MTF ladder helpers — per-timeframe net-buying-pressure z (candle-geometry delta, robust z), so each
// rung can be evaluated on any timeframe via request.security without nested intrabar requests.
f_tfFlowZ(simple int len) =>
    float rng = high - low
    float ev  = na(volume) or volume == 0 ? 1.0 : volume
    float d   = rng > 0 ? ev * ((close - low) - (high - close)) / rng : 0.0
    float med = ta.median(d, len)
    float mad = ta.median(math.abs(d - med), len)
    float z   = mad > 1e-10 ? (d - med) / (1.4826 * mad) : 0.0
    math.max(-4.0, math.min(4.0, z))
// chart-TF × mult as a standard timeframe string (exact minutes, capped at Daily)
f_tfMul(int mult) =>
    float mm = (timeframe.in_seconds() / 60.0) * mult
    mm >= 1440.0 ? "D" : str.tostring(math.max(1, int(math.round(mm))))

f_ncdf(float x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float d = 0.3989422804014327 * math.exp(-x * x / 2.0)
    float p = d * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    x >= 0.0 ? 1.0 - p : p

f_er(float s, int len) =>
    float net  = math.abs(s - s[len])
    float path = math.sum(math.abs(ta.change(s)), len)
    path > 0 ? net / path : 0.0

f_wilsonLo(float w, float t, float zc) =>
    float r = na
    if t > 0.0
        float p = w / t
        float d = 1.0 + zc * zc / t
        float c = (p + zc * zc / (2.0 * t)) / d
        float m = zc * math.sqrt(p * (1.0 - p) / t + zc * zc / (4.0 * t * t)) / d
        r := c - m
    r

// empirical quantile over the most-recent k values of an array (transplant: ConfChan f_quant).
// This is the conformal core — the band is exactly as wide as the data's own recent errors.
f_quant(float[] a, int k, float p) =>
    int n = array.size(a)
    float out = na
    if n >= 1
        int start = math.max(0, n - k)
        float[] s = array.new_float(0)
        for i = start to n - 1
            array.push(s, array.get(a, i))
        array.sort(s, order.ascending)
        int m = array.size(s)
        float idx = math.max(0.0, math.min(p, 1.0)) * (m - 1)
        int lo = math.max(0, math.min(m - 1, int(math.floor(idx))))
        int hi = math.max(0, math.min(m - 1, int(math.ceil(idx))))
        float fr = idx - lo
        out := array.get(s, lo) * (1.0 - fr) + array.get(s, hi) * fr
    out


f_vr(float s, int q, int N) =>
    float vr = na
    float z  = na
    if N > q + 2
        float mu = 0.0
        for i = 0 to N - 1
            mu += s[i] - s[i + 1]
        mu := mu / N
        float sa = 0.0
        for i = 0 to N - 1
            float d = (s[i] - s[i + 1]) - mu
            sa += d * d
        sa := sa / (N - 1)
        float sc = 0.0
        for t = 0 to N - q
            float R = 0.0
            for j = 0 to q - 1
                R += s[t + j] - s[t + j + 1]
            float d = R - q * mu
            sc += d * d
        float m = q * (N - q + 1) * (1.0 - q / float(N))
        if m > 0 and sa > 0
            sc := sc / m
            vr := sc / (q * sa)
            float phi = 2.0 * (2.0 * q - 1.0) * (q - 1.0) / (3.0 * q)
            z := phi > 0 ? math.sqrt(float(N)) * (vr - 1.0) / math.sqrt(phi) : na
    [vr, z]

// convex-hull edge (monotone chain) → last edge  (transplanted from SC-Breaks)
f_hullEdge(xs, ys, upper) =>
    float rx1 = na, float ry1 = na, float rx2 = na, float ry2 = na
    int n = array.size(xs)
    if n >= 2
        hx = array.new<float>(), hy = array.new<float>()
        for i = 0 to n - 1
            px = array.get(xs, i), py = array.get(ys, i)
            bool cont = true
            while cont and array.size(hx) >= 2
                int m = array.size(hx)
                ax = array.get(hx, m - 2), ay = array.get(hy, m - 2)
                bx = array.get(hx, m - 1), byy = array.get(hy, m - 1)
                cross = (bx - ax) * (py - ay) - (byy - ay) * (px - ax)
                bool pop = upper ? (cross >= 0.0) : (cross <= 0.0)
                if pop
                    array.pop(hx), array.pop(hy)
                else
                    cont := false
            array.push(hx, px), array.push(hy, py)
        int mm = array.size(hx)
        if mm >= 2
            rx1 := array.get(hx, mm - 2), ry1 := array.get(hy, mm - 2)
            rx2 := array.get(hx, mm - 1), ry2 := array.get(hy, mm - 1)
    [rx1, ry1, rx2, ry2]

f_touches(xs, ys, x1, y1, x2, y2, tol) =>
    int c = 0
    if x2 != x1
        slope = (y2 - y1) / (x2 - x1)
        int n = array.size(xs)
        if n > 0
            for i = 0 to n - 1
                px = array.get(xs, i)
                if px >= x1
                    py = array.get(ys, i)
                    ly = y1 + slope * (px - x1)
                    if math.abs(py - ly) <= tol
                        c += 1
    c

// higher-TF string from a multiple of the chart timeframe
f_tfMult(int m) =>
    float s = timeframe.in_seconds(timeframe.period) * m
    s < 60 ? str.tostring(math.round(s)) + "S" : s < 86400 ? str.tostring(math.round(s / 60.0)) : s < 604800 ? str.tostring(math.round(s / 86400.0)) + "D" : str.tostring(math.round(s / 604800.0)) + "W"

f_snapTF(float target_min) =>
    target_min <= 1 ? "1" : target_min <= 3 ? "3" : target_min <= 5 ? "5" : target_min <= 15 ? "15" : target_min <= 30 ? "30" : target_min <= 45 ? "45" : target_min <= 60 ? "60" : target_min <= 120 ? "120" : target_min <= 180 ? "180" : target_min <= 240 ? "240" : "D"

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — VOLUME + CORE SERIES
// ══════════════════════════════════════════════════════════════════════════════
var bool nativeVolSeen = false
if volume > 0
    nativeVolSeen := true
useBorrow  = str.length(volBorrow) > 0 and not nativeVolSeen
volBorrowR = request.security(str.length(volBorrow) > 0 ? volBorrow : syminfo.tickerid, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
volEff = useBorrow and not na(volBorrowR) ? volBorrowR : volume
volW   = na(volEff) or volEff < 0 ? 0.0 : volEff

float atr      = ta.atr(14)
float atrSafe  = atr > 0 ? atr : close * 0.001
float rng      = math.max(high - low, syminfo.mintick)
float bodyR    = math.abs(close - open) / rng
float volMa    = ta.sma(volW, 20)
float volZ     = volMa > 0 ? (volW - volMa) / math.max(volMa, 1e-9) : 0.0
[diP, diM, adxV] = ta.dmi(adxLen, adxLen)

// ── CONFORMAL RESIDUAL STORE ──────────────────────────────────────────────────
// Transplant of ConfChan's vol-normalised error store, adapted to Compass's need:
// we record, per bar, how far price actually travelled over the next H bars in ATR
// units — separately up and down. These empirical distributions size TP/SL: TP at a
// quantile favorable moves usually reach, SL at a quantile that clears normal noise.
var float[] favBuf = array.new<float>()   // favorable H-bar excursion, ATR units
var float[] advBuf = array.new<float>()   // adverse   H-bar excursion, ATR units
int confH = calHorizon
if barstate.isconfirmed and bar_index > confH and atrSafe > 0
    float a0 = atrSafe[confH]
    if a0 > 0
        float e0 = close[confH]
        float up = 0.0, float dn = 0.0
        for j = 0 to confH - 1
            up := math.max(up, high[j] - e0)
            dn := math.max(dn, e0 - low[j])
        array.push(favBuf, math.max(up, 0.0) / a0)
        array.push(advBuf, math.max(dn, 0.0) / a0)
        while array.size(favBuf) > confWinN
            array.shift(favBuf)
        while array.size(advBuf) > confWinN
            array.shift(advBuf)
bool confReady = array.size(favBuf) >= 40
// conformal distances in PRICE units for the current bar
float confTP = confReady ? f_quant(favBuf, confWinN, confTPq) * atrSafe : na
float confSL = confReady ? f_quant(advBuf, confWinN, confSLq) * atrSafe : na

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — REGIME BRAIN   (transplant: Trend Efficiency Exhaustion)
// ══════════════════════════════════════════════════════════════════════════════
float erFast = f_er(src, erFastL)
float erSlow = f_er(src, erSlowL)

// Hawkes self-exciting vol-cluster intensity
float trv  = ta.tr(true)
float trMA = ta.sma(trv, hvLen)
bool  volShock = not na(trMA) and trMA > 0 and trv > trMA * hvShock
var float hawkVol = 0.0
if barstate.isconfirmed
    hawkVol := hawkVol * math.exp(-hvBeta) + (volShock ? 1.0 : 0.0)
float hawkPct = ta.percentrank(hawkVol, 200)

// Lo–MacKinlay variance ratio (second regime lens)
[vr, vrZ] = f_vr(src, vrQ, vrLen)

// OU mean-reversion half-life
float dP    = src - src[1]
float pLag  = src[1]
float ouCor = ta.correlation(dP, pLag, ouLen)
float ouSdY = ta.stdev(dP, ouLen)
float ouSdX = ta.stdev(pLag, ouLen)
float ouB   = (not na(ouCor) and ouSdX > 0) ? ouCor * ouSdY / ouSdX : na
float halfLife = (not na(ouB) and ouB < 0 and (1.0 + ouB) > 0) ? -math.log(2.0) / math.log(1.0 + ouB) : na

// ── REGIME CLASSIFIER (rebuilt) ──────────────────────────────────────────────
// The old blend (0.5·ER + 0.5·(ADX/40)) mislabeled chop as STRONG TREND: ADX≈25
// (weak/no trend) normalized to 0.63, near the strong threshold on its own. Fixes:
//   1. ADX read on its own scale with proper bands (no-trend <20, trend 20-25,
//      strong ≥ adxStrong) — not a linear /40.
//   2. ER and ADX must AGREE (both high) for a trend, not average — averaging let
//      one lens drag the label. A trend needs directional persistence AND strength.
//   3. ADX must be RISING for STRONG (a falling ADX from a high is a dying trend).
//   4. Hysteresis: once STRONG, need a clearer drop to leave it (stops flip-flop).
float adxRise = adxV - nz(adxV[3], adxV)
bool  adxNoTrend = nz(adxV) < adxTrend
bool  erTrending = erSlow >= erTrendMin
bool  strongRaw  = nz(adxV) >= adxStrong and erSlow >= erStrongMin and adxRise > 0
bool  trendRaw   = nz(adxV) >= adxTrend  and erTrending and not strongRaw
// CHAOS requires BOTH high relative intensity AND a genuine recent vol shock.
bool  recentShock = nz(ta.barssince(volShock), 999) <= hvLen
bool  chaosNow   = not na(hawkPct) and hawkPct >= chaosPct and recentShock
// REVERSION: mean-reverting tape (variance ratio < 1) with weak directional trend.
bool  revertNow  = (na(vr) or vr < 1.0) and adxNoTrend and erSlow < 0.35
// hysteresis on STRONG TREND: hold it until ADX clearly falls back below the band
var int prevRegID = 3
bool holdStrong = prevRegID == 1 and nz(adxV) >= adxStrong - 3 and erSlow >= erStrongMin - 0.05
int regID = chaosNow ? 5 : (strongRaw or holdStrong) ? 1 : trendRaw ? 2 : revertNow ? 4 : 3
prevRegID := regID
f_regName(int id) => id == 1 ? "STRONG TREND" : id == 2 ? "TREND" : id == 3 ? "NEUTRAL" : id == 4 ? "REVERSION" : "CHAOS"
bool regTrend = regID == 1 or regID == 2
bool regChaos = regID == 5

// ATR-percentile vol state (Low/Normal/Extreme)
float atrPct = ta.percentrank(atr, 100)
string volState = atrPct >= 85 ? "Extreme" : atrPct <= 20 ? "Low" : "Normal"
bool volExtreme = atrPct >= 90

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — HTF BIAS   (transplant: Apex / Phase — 2 confirmed frames)
// ══════════════════════════════════════════════════════════════════════════════
f_htfBias() =>
    float ema  = ta.ema(close, htfEmaLen)
    float emaP = ta.ema(close, htfEmaLen)[1]
    close > ema and ema >= emaP ? 1 : close < ema and ema <= emaP ? -1 : 0

string htf1tf = f_tfMult(htf1Mult)
string htf2tf = f_tfMult(htf2Mult)
int htf1Raw = request.security(syminfo.tickerid, htf1tf, f_htfBias(), lookahead = barmerge.lookahead_off)
int htf2Raw = request.security(syminfo.tickerid, htf2tf, f_htfBias(), lookahead = barmerge.lookahead_off)
int htf1Bias = useHTF ? nz(htf1Raw) : 0
int htf2Bias = useHTF ? nz(htf2Raw) : 0
int htfSum   = htf1Bias + htf2Bias        // -2..+2 (structural HTF2 weighted equally here)
bool htfConflict = htf1Bias != 0 and htf2Bias != 0 and htf1Bias != htf2Bias

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — LEVELS   (transplant: author's multi-anchor VWAP engine / Apex)
// ══════════════════════════════════════════════════════════════════════════════
bool newSess = ta.change(time("D")) != 0
bool newWeek = ta.change(time("W")) != 0
bool newMo   = ta.change(time("M")) != 0
float sessVwap = ta.vwap(hlc3, newSess)
float weekVwap = ta.vwap(hlc3, newWeek)
float moVwap   = ta.vwap(hlc3, newMo)

// session volume-weighted σ (for stretch read)
var float svPV = 0.0, var float svV = 0.0, var float svP2V = 0.0
if newSess
    svPV := 0.0, svV := 0.0, svP2V := 0.0
float _svp = hlc3
svPV += _svp * volW, svV += volW, svP2V += _svp * _svp * volW
float sessSd = svV > 0 ? math.sqrt(math.max(svP2V / svV - math.pow(svPV / svV, 2), 0.0)) : na
float zStretch = (not na(sessSd) and sessSd > 0) ? (close - sessVwap) / sessSd : 0.0

// SW50 swing engine (flip pivots)  — transplant Apex §3
var bool  swTrend = true
var int   hi_idx = 0, var float hi_val = high
var int   lo_idx = 0, var float lo_val = low
float phSW = ta.highest(swLen)
float plSW = ta.lowest(swLen)
bool phConf = high[1] == phSW[1] and high < phSW
bool plConf = low[1]  == plSW[1] and low  > plSW
if phConf
    hi_idx := bar_index - 1, hi_val := high[1]
if plConf
    lo_idx := bar_index - 1, lo_val := low[1]
h_vwap = ta.vwap(high, phConf)
l_vwap = ta.vwap(low, plConf)
if high == phSW
    swTrend := true
if low == plSW
    swTrend := false
bool flipBull = swTrend and swTrend != swTrend[1]
bool flipBear = not swTrend and swTrend != swTrend[1]
float sw50 = swTrend ? l_vwap : h_vwap

// SW150 / SW200 anchors (level proximity)
f_swVwap(int L) =>
    float ph = ta.highest(L)
    float pl = ta.lowest(L)
    bool phc = high[1] == ph[1] and high < ph
    bool plc = low[1]  == pl[1] and low  > pl
    var bool tr = true
    if high == ph
        tr := true
    if low == pl
        tr := false
    float hv = ta.vwap(high, phc)
    float lv = ta.vwap(low, plc)
    tr ? lv : hv
float sw150 = f_swVwap(sw150Len)
float sw200 = f_swVwap(sw200Len)

// Anchored Volume Profile (POC / VAH / VAL) — transplant Apex §5 / author's AVP engine
var float pocPrice = na, var float vahPrice = na, var float valPrice = na
if showAVP and barstate.islast
    int win = math.max(2, math.min(bar_index + 1, avpLookback))
    float hiP = high, float loP = low
    for ii = 0 to win - 1
        hiP := math.max(hiP, high[ii])
        loP := math.min(loP, low[ii])
    float step = math.max((hiP - loP) / vpBins, syminfo.mintick)
    bk = array.new<float>(vpBins, 0.0)
    for ii = 0 to win - 1
        int idx = math.max(0, math.min(vpBins - 1, int(math.floor((nz(hlc3[ii], close[ii]) - loP) / step))))
        array.set(bk, idx, array.get(bk, idx) + nz(volW[ii]))
    int pocBin = array.indexof(bk, array.max(bk))
    pocPrice := loP + (pocBin + 0.5) * step
    float tot = array.sum(bk), float acc = array.get(bk, pocBin)
    int upB = pocBin, int dnB = pocBin
    float target = tot * (vaPctIn / 100.0), int safety = 0
    while acc < target and (upB < vpBins - 1 or dnB > 0) and safety < vpBins * 2
        safety += 1
        float uV = upB < vpBins - 1 ? array.get(bk, upB + 1) : -1.0
        float dV = dnB > 0 ? array.get(bk, dnB - 1) : -1.0
        if uV < 0 and dV < 0
            break
        if uV >= dV
            upB += 1, acc += uV
        else
            dnB -= 1, acc += dV
    vahPrice := loP + (upB + 1) * step
    valPrice := loP + dnB * step

// prior day / week ladder
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)

// nearest-level distance (for stand-aside "mid-range" test) + level name
float pxDist = flipProx * atrSafe
fnear(lvl) => not na(lvl) and math.abs(close - lvl) < pxDist
bool nearAny = fnear(sessVwap) or fnear(weekVwap) or fnear(moVwap) or fnear(pocPrice) or fnear(vahPrice) or fnear(valPrice) or fnear(sw50) or fnear(sw150) or fnear(sw200) or fnear(pdh) or fnear(pdl) or fnear(pwh) or fnear(pwl)

// snap a raw target to the nearest structural level
f_snap(float raw, float tol) =>
    float best = raw, float bestD = tol, string tag = ""
    cv = array.from(pocPrice, vahPrice, valPrice, moVwap, weekVwap, sw150, sw200, pdh, pdl, pwh, pwl)
    cn = array.from("POC", "VAH", "VAL", "MO", "WK", "SW150", "SW200", "PDH", "PDL", "PWH", "PWL")
    for i = 0 to array.size(cv) - 1
        float c = array.get(cv, i)
        if not na(c)
            float d = math.abs(c - raw)
            if d < bestD
                bestD := d, best := c, tag := array.get(cn, i)
    [best, tag]

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — FLOW PROXY   (transplant: VFDO — LTF signed volume + BVC fallback)
// ══════════════════════════════════════════════════════════════════════════════
f_bvcDelta() =>
    float ret = close - nz(close[1], close)
    float sd  = ta.stdev(close - close[1], bvcLen)
    float z   = sd > 0 ? ret / sd : 0.0
    float bf  = math.max(0.0, math.min(1.0, f_ncdf(z)))
    volW * (2.0 * bf - 1.0)

[ltfH, ltfL, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, lowerTF, [high, low, close, volume])
float svLTF = na
bool  ltfOK = false
if array.size(ltfV) > 0
    float s = 0.0
    for i = 0 to array.size(ltfV) - 1
        float rr = array.get(ltfH, i) - array.get(ltfL, i)
        float bf = rr == 0 ? 0.5 : math.max(0.0, math.min(1.0, (array.get(ltfC, i) - array.get(ltfL, i)) / rr))
        s += array.get(ltfV, i) * (2.0 * bf - 1.0)
    svLTF := s, ltfOK := true
float svBVC = f_bvcDelta()
float sv = (useFlow and ltfOK) ? svLTF : svBVC
float cvd = ta.cum(sv)
float cvdEma = ta.ema(cvd, 10)
int flowDir = cvd >= cvdEma ? 1 : -1                        // +1 buy pressure, -1 sell
float buyVol = volW * math.max(0.0, math.min(1.0, 0.5 + 0.5 * (volW > 0 ? sv / math.max(volW, 1e-9) : 0.0)))
float sellVol = volW - buyVol
float vpin = ta.sma(math.abs(buyVol - sellVol), toxWin) / math.max(ta.sma(buyVol + sellVol, toxWin), 1e-9)
bool toxic = not na(vpin) and vpin >= toxHigh

// ── FLOW/PRICE LEAD-LAG (Lévy area) — signed area of the joint (flow sv, price) path ──
// A > 0 → FLOW leads (participation precedes price); A < 0 → PRICE leads (flow chasing). Reuses the
// per-bar signed delta `sv` as the flow increment and `src` as the price increment; self-calibrated
// significance percentile, seed-EMA smoothing, non-repaint (evaluated on confirmed bars).
float levyPc  = src - nz(src[1], src)
float levySdx = ta.stdev(sv, levyWin)
float levySdy = ta.stdev(levyPc, levyWin)
f_levyArea() =>
    float a = na
    if bar_index >= levyWin + 2 and levySdx > 0 and levySdy > 0
        float acc = 0.0
        float Xp  = 0.0
        float Yp  = 0.0
        for k = 0 to levyWin - 1
            int off = levyWin - 1 - k
            float dx = nz(sv[off]) / levySdx
            float dy = nz(levyPc[off]) / levySdy
            acc += Xp * dy - Yp * dx
            Xp += dx
            Yp += dy
        a := acc / levyWin
    a
var float levyRaw = na
if leadOn and barstate.isconfirmed
    levyRaw := f_levyArea()
float levyArea  = leadOn ? f_emaSeed(levyRaw, levySmooth) : na
float levyRank  = not na(levyArea) ? ta.percentrank(nz(math.abs(levyArea), 0.0), levyLook) : na
bool  levyReady = leadOn and not na(levyRank) and bar_index > levyWin + levyLook / 2
bool  levySig   = levyReady and levyRank >= levySigLvl
int   leadState = not levyReady ? -9 : levySig ? (levyArea > 0 ? 1 : -1) : 0
bool  priceLeading = leadState == -1

// ── MTF FLOW ALIGNMENT LADDER (chart + 3× + 5×) — cross-timeframe agreement + fused conviction ──
// A proper 3-rung agreement stack (richer than the 2 HTF bias frames): each rung is a robust-z of
// candle-geometry net-buying pressure. Their signed agreement (mtfAlign, −3..+3) and a log-odds fused
// conviction (0–100) let signals be filtered when they fight the multi-timeframe flow. HTF rungs are
// pulled with lookahead OFF → non-repainting.
string mtfR2 = f_tfMul(3)
string mtfR3 = f_tfMul(5)
float mz1 = f_tfFlowZ(mtfLen)
float mz2 = request.security(syminfo.tickerid, mtfR2, f_tfFlowZ(mtfLen), lookahead = barmerge.lookahead_off)
float mz3 = request.security(syminfo.tickerid, mtfR3, f_tfFlowZ(mtfLen), lookahead = barmerge.lookahead_off)
int mtfS1 = na(mz1) ? 0 : mz1 > mtfNeut ? 1 : mz1 < -mtfNeut ? -1 : 0
int mtfS2 = na(mz2) ? 0 : mz2 > mtfNeut ? 1 : mz2 < -mtfNeut ? -1 : 0
int mtfS3 = na(mz3) ? 0 : mz3 > mtfNeut ? 1 : mz3 < -mtfNeut ? -1 : 0
int   mtfAlign = mtfS1 + mtfS2 + mtfS3
float mtfMean  = (nz(mz1) + nz(mz2) + nz(mz3)) / 3.0
float mtfPUp   = 1.0 / (1.0 + math.exp(-mtfLoGain * mtfMean))
float mtfConf  = 100.0 * math.abs(2.0 * mtfPUp - 1.0)
bool  mtfOpposeLong  = mtfOn and mtfGate and mtfAlign <= -mtfOppose
bool  mtfOpposeShort = mtfOn and mtfGate and mtfAlign >= mtfOppose

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — FLIP ENGINE   (transplant: Apex §13.9F composite score + kill)
// ══════════════════════════════════════════════════════════════════════════════
// kill switch (Apex §7, trimmed)
bool killSess  = timeframe.isintraday and ((hour == 9 and minute < 45) or (hour == 15 and minute >= 15))
float atrAvg50 = ta.sma(atr, 50)
bool killATR   = atrAvg50 > 0 and atr / atrAvg50 > 3.5
bool killADX   = (adxV - nz(adxV[5], adxV)) > 7.0
bool killed    = killSess or killATR or killADX or regChaos

// flip level grade
bool fAplus = fnear(moVwap) or fnear(pocPrice) or fnear(sw200)      // (yr/qtr not tracked here → MO/POC/SW200 top tier)
bool fA     = fnear(vahPrice) or fnear(valPrice) or fnear(weekVwap)
bool fB     = fnear(sw150) or fnear(pdh) or fnear(pdl)
bool fC     = fnear(sessVwap)
bool fAny   = fAplus or fA or fB or fC
string flipLevelName = fnear(moVwap) ? "MO" : fnear(pocPrice) ? "POC" : fnear(sw200) ? "SW200" : fnear(weekVwap) ? "WK" : fnear(vahPrice) ? "VAH" : fnear(valPrice) ? "VAL" : fnear(sw150) ? "SW150" : fnear(pdh) ? "PDH" : fnear(pdl) ? "PDL" : fnear(sessVwap) ? "SESS" : "—"

// composite score metrics
float flipPivot = flipBull ? lo_val : flipBear ? hi_val : na
int   _fbback   = flipBull ? math.max(bar_index - lo_idx, 0) : flipBear ? math.max(bar_index - hi_idx, 0) : 0
float _fvwapPiv = _fbback >= 0 and _fbback < 5000 ? sessVwap[_fbback] : na
float flipExt   = (flipBull or flipBear) and atr > 0 and not na(_fvwapPiv) ? (flipBull ? (_fvwapPiv - lo_val) / atr : (hi_val - _fvwapPiv) / atr) : 0.0
float _fmove    = (flipBull or flipBear) ? (hi_val - lo_val) : 0.0
int   _fbars    = flipBull ? (lo_idx - hi_idx) : flipBear ? (hi_idx - lo_idx) : 0
float flipVel   = (flipBull or flipBear) and _fbars > 0 and atr > 0 ? math.min((_fmove / _fbars) / atr, 2.0) : 0.0
float flipVolR  = volMa > 0 ? volW / volMa : 1.0

// LTF cascade
float _chartSec = math.max(timeframe.in_seconds(), 60)
float _l1 = flipLTF1Div == "/2" ? 2.0 : flipLTF1Div == "/3" ? 3.0 : flipLTF1Div == "/4" ? 4.0 : 5.0
float _l2 = flipLTF2Div == "/3" ? 3.0 : flipLTF2Div == "/4" ? 4.0 : flipLTF2Div == "/5" ? 5.0 : 10.0
string ltf1tf = f_snapTF((_chartSec / 60.0) / _l1)
string ltf2tf = f_snapTF((_chartSec / 60.0) / _l2)
f_ltfFlip(int L) =>
    float ph = ta.highest(high, L)
    float pl = ta.lowest(low, L)
    var bool t = true
    if high == ph
        t := true
    if low == pl
        t := false
    [t and t != t[1], not t and t != t[1]]
[l1Bull, l1Bear] = request.security(syminfo.tickerid, ltf1tf, f_ltfFlip(swLen), lookahead = barmerge.lookahead_off)
[l2Bull, l2Bear] = request.security(syminfo.tickerid, ltf2tf, f_ltfFlip(swLen), lookahead = barmerge.lookahead_off)
var int _l1sb = 9999, var int _l1ss = 9999, var int _l2sb = 9999, var int _l2ss = 9999
_l1sb := l1Bull ? 0 : _l1sb + 1
_l1ss := l1Bear ? 0 : _l1ss + 1
_l2sb := l2Bull ? 0 : _l2sb + 1
_l2ss := l2Bear ? 0 : _l2ss + 1
bool l1conf = flipLTF and ((flipBull and _l1sb <= flipLTFrec) or (flipBear and _l1ss <= flipLTFrec))
bool l2conf = flipLTF and ((flipBull and _l2sb <= flipLTFrec) or (flipBear and _l2ss <= flipLTFrec))
int cascade = (l1conf ? 1 : 0) + (l2conf ? 1 : 0)

// composite score (0-10) — exact Apex weights
float scLevel = fAplus ? 3.0 : fA ? 2.0 : fB ? 1.0 : fC ? 0.5 : 0.0
float scExt   = flipExt >= 2.0 ? 3.0 : flipExt >= 1.0 ? 2.0 : flipExt >= 0.3 ? 1.0 : flipExt >= 0.0 ? 0.5 : 0.0
float scVol   = flipVolR >= 2.5 ? 2.0 : flipVolR >= 1.5 ? 1.5 : flipVolR >= 0.7 ? 1.0 : 0.0
float scCasc  = cascade == 2 ? 1.5 : cascade == 1 ? 0.75 : 0.0
float scVel   = flipVel >= 0.30 ? 0.5 : flipVel >= 0.15 ? 0.3 : flipVel >= 0.05 ? 0.15 : 0.0
float flipScore = scLevel + scExt + scVol + scCasc + scVel
string flipTier = flipScore >= 8.0 ? "S" : flipScore >= 6.0 ? "A" : flipScore >= 4.0 ? "B" : flipScore >= 2.0 ? "C" : "D"
int flipTierN   = flipTier == "S" ? 5 : flipTier == "A" ? 4 : flipTier == "B" ? 3 : flipTier == "C" ? 2 : 1
int flipMinN    = flipMinTier == "OFF" ? 99 : flipMinTier == "S" ? 5 : flipMinTier == "A" ? 4 : flipMinTier == "B" ? 3 : flipMinTier == "C" ? 2 : 1

// FLIP fires when: (a) it's at a level (any qualifying tier), OR (b) it's a
// high-tier reversal (S/A) even away from a level. In BOTH cases the leg into
// the pivot must clear flipMinExt ATR — this kills noise-flips off tiny wiggles.
bool flipDeep  = flipExt >= flipMinExt
bool flipGate  = (fAny or flipTierN >= 4) and flipDeep
bool flipLong  = useFlip and flipBull and flipGate and flipTierN >= flipMinN and not killed
bool flipShort = useFlip and flipBear and flipGate and flipTierN >= flipMinN and not killed

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — CONTINUATION ENGINE   (transplant: SC-Breaks convex hull + harness)
// ══════════════════════════════════════════════════════════════════════════════
int chartMin = math.max(1, int(timeframe.in_seconds() / 60))
int pivLen   = autoPivot ? math.max(3, math.min(50, int(math.round(pivotMin / chartMin)))) : pivManual

var float[] phX = array.new<float>(), var float[] phY = array.new<float>()
var float[] plX = array.new<float>(), var float[] plY = array.new<float>()
float phC = ta.pivothigh(high, pivLen, pivLen)
float plC = ta.pivotlow(low, pivLen, pivLen)

var float resX1 = na, var float resY1 = na, var float resX2 = na, var float resY2 = na
var bool resOK = false, var int resTouch = 0, var bool resBroken = false
if not na(phC)
    array.push(phX, float(bar_index - pivLen)), array.push(phY, phC)
    while array.size(phX) > hullWin
        array.shift(phX), array.shift(phY)
    [ex1, ey1, ex2, ey2] = f_hullEdge(phX, phY, true)
    bool ok = false
    if not na(ex1) and ex2 != ex1
        slA = (ey2 - ey1) / (ex2 - ex1) / atrSafe
        if slA <= -minSlope and slA >= -maxSlope
            ok := true
    bool changed = ex1 != resX1 or ey1 != resY1 or ex2 != resX2 or ey2 != resY2
    resX1 := ex1, resY1 := ey1, resX2 := ex2, resY2 := ey2, resOK := ok
    if ok
        resTouch := f_touches(phX, phY, ex1, ey1, ex2, ey2, touchTol * atrSafe)
    if changed
        resBroken := false

var float supX1 = na, var float supY1 = na, var float supX2 = na, var float supY2 = na
var bool supOK = false, var int supTouch = 0, var bool supBroken = false
if not na(plC)
    array.push(plX, float(bar_index - pivLen)), array.push(plY, plC)
    while array.size(plX) > hullWin
        array.shift(plX), array.shift(plY)
    [ex1, ey1, ex2, ey2] = f_hullEdge(plX, plY, false)
    bool ok = false
    if not na(ex1) and ex2 != ex1
        slA = (ey2 - ey1) / (ex2 - ex1) / atrSafe
        if slA >= minSlope and slA <= maxSlope
            ok := true
    bool changed = ex1 != supX1 or ey1 != supY1 or ex2 != supX2 or ey2 != supY2
    supX1 := ex1, supY1 := ey1, supX2 := ex2, supY2 := ey2, supOK := ok
    if ok
        supTouch := f_touches(plX, plY, ex1, ey1, ex2, ey2, touchTol * atrSafe)
    if changed
        supBroken := false

float resNow = (resOK and resX2 != resX1) ? resY1 + (resY2 - resY1) / (resX2 - resX1) * (bar_index - resX1) : na
float supNow = (supOK and supX2 != supX1) ? supY1 + (supY2 - supY1) / (supX2 - supX1) * (bar_index - supX1) : na
bool disp = (high - low) >= dispATR * atrSafe and bodyR >= 0.5

bool resBreak = false
if resOK and not na(resNow)
    bool aw = (close - low) / rng >= antiWick
    if not resBroken and barstate.isconfirmed and close > resNow + breakBuf * atrSafe and disp and aw
        resBreak := true, resBroken := true
bool supBreak = false
if supOK and not na(supNow)
    bool aw = (high - close) / rng >= antiWick
    if not supBroken and barstate.isconfirmed and close < supNow - breakBuf * atrSafe and disp and aw
        supBreak := true, supBroken := true
int rawBreakDir = resBreak ? 1 : supBreak ? -1 : 0
int rawBreakTouch = resBreak ? resTouch : supBreak ? supTouch : 0
float rawBreakLine = resBreak ? resNow : supBreak ? supNow : na

// ── FAILED-BREAK detection (fade donor: author's ORB failed-break reversal engine) ──
// A break that closes back INSIDE the channel within fadeWin bars = failed break.
// author's ORB geometry, adapted to the hull channel: on failure the reversal STOP is
// the break's failure extreme (its high/low water mark), and the TARGET is the
// OPPOSITE channel edge — not a vol-multiple. On Nifty, chasing breaks bled ~-0.3R.
var int   upBreakBar = -100000, var float upBreakLine = na, var float upFailExt = na
var int   dnBreakBar = -100000, var float dnBreakLine = na, var float dnFailExt = na
if resBreak
    upBreakBar := bar_index, upBreakLine := resNow, upFailExt := high
if supBreak
    dnBreakBar := bar_index, dnBreakLine := supNow, dnFailExt := low
// track the failure extreme while the break is live (author's ORB failExt)
if bar_index - upBreakBar > 0 and bar_index - upBreakBar <= fadeWin and not na(upFailExt)
    upFailExt := math.max(upFailExt, high)
if bar_index - dnBreakBar > 0 and bar_index - dnBreakBar <= fadeWin and not na(dnFailExt)
    dnFailExt := math.min(dnFailExt, low)
// resistance break fails when price closes back below that line within the window → fade SHORT
bool failUp = barstate.isconfirmed and bar_index - upBreakBar > 0 and bar_index - upBreakBar <= fadeWin and not na(upBreakLine) and close < upBreakLine - breakBuf * atrSafe
// support break fails when price closes back above that line within the window → fade LONG
bool failDn = barstate.isconfirmed and bar_index - dnBreakBar > 0 and bar_index - dnBreakBar <= fadeWin and not na(dnBreakLine) and close > dnBreakLine + breakBuf * atrSafe
// capture the reversal stop (failure extreme) and target (opposite hull edge) at fire
float fadeStop = failUp ? upFailExt : failDn ? dnFailExt : na
float fadeTgt  = failUp ? nz(supNow, na) : failDn ? nz(resNow, na) : na    // opposite channel edge
// consume the failure so it fires once
if failUp
    upBreakBar := -100000
if failDn
    dnBreakBar := -100000

// resolve continuation-engine output by mode
bool fadeMode = contMode == "Fade failed break"
int breakDir   = fadeMode ? (failUp ? -1 : failDn ? 1 : 0) : rawBreakDir
int breakTouch = fadeMode ? (failUp ? resTouch : failDn ? supTouch : 0) : rawBreakTouch
float breakLine= fadeMode ? (failUp ? upBreakLine : failDn ? dnBreakLine : na) : rawBreakLine
bool resBreakEff = fadeMode ? failDn : resBreak     // effective "long-side" continuation event
bool supBreakEff = fadeMode ? failUp : supBreak     // effective "short-side" continuation event

// break follow-through harness (Wilson-floored continuation rate, regime-bucketed)
var int[] contHit = array.new_int(6, 0)   // idx = regBucket(0 chop,1 trend)*... simplified to regID buckets 0..4
var int[] contTot = array.new_int(6, 0)
type Brk
    int dir
    int reg
    float entry
    float atr0
    int bidx
    bool done
var array<Brk> pendC = array.new<Brk>()
if breakDir != 0 and barstate.isconfirmed and atr > 0
    pendC.push(Brk.new(breakDir, regID, close, atr, bar_index, false))
if barstate.isconfirmed and pendC.size() > 0
    for i = pendC.size() - 1 to 0
        Brk p = pendC.get(i)
        if not p.done
            float favor   = p.dir > 0 ? (high - p.entry) : (p.entry - low)
            float adverse = p.dir > 0 ? (p.entry - low)  : (high - p.entry)
            bool cHit = favor   >= 1.5 * p.atr0
            bool fHit = adverse >= 1.0 * p.atr0
            bool tmOut= bar_index - p.bidx >= calHorizon
            if cHit or fHit or tmOut
                p.done := true
                int b = math.max(0, math.min(5, p.reg))
                array.set(contTot, b, array.get(contTot, b) + 1)
                if cHit and not fHit
                    array.set(contHit, b, array.get(contHit, b) + 1)
                pendC.remove(i)
int _cb = math.max(0, math.min(5, regID))
float contWL = array.get(contTot, _cb) >= calMinSamp ? f_wilsonLo(array.get(contHit, _cb), array.get(contTot, _cb), 1.96) : na
float contRate = array.get(contTot, _cb) > 0 ? array.get(contHit, _cb) / float(array.get(contTot, _cb)) : na

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — BARRIERS (SL/TP)   (transplant: AEGIS v2 vol-scaled, regime-asym)
// ══════════════════════════════════════════════════════════════════════════════
float rB = na(close[1]) ? 0.0 : math.log(close / close[1])
float aB = 2.0 / (volLenB + 1)
var float ewVar = na
ewVar := na(ewVar) ? rB * rB : aB * rB * rB + (1.0 - aB) * ewVar
float sigPx = volMode == "ATR" ? ta.atr(volLenB) : close * math.sqrt(math.max(ewVar, 0.0))
float ptMul = regAsym ? (regID == 1 ? 1.4 : regID == 2 ? 1.2 : regID == 4 ? 0.8 : 1.0) : 1.0
float slMul = regAsym ? (regID == 4 ? 0.85 : regID == 5 ? 1.15 : 1.0) : 1.0

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — DECISION CORE  (STAND ASIDE / FLIP / CONTINUATION / CONFLICT)
// ══════════════════════════════════════════════════════════════════════════════
// flow agreement per side — SOFT: opposition down-grades, never hard-blocks flip
bool flowOpposesLong  = flowDir < 0
bool flowOpposesShort = flowDir > 0
bool stretchedIntoLevel = math.abs(zStretch) >= stretchZ and nearAny

// EDGE-GATE: mute flags are set by the outcome tracker (below) and read here on
// the NEXT bar. A mode mutes when its ROLLING win-rate drops below edgeMute, and
// auto-un-mutes when it recovers above edgeUnmute (hysteresis).
var bool flipMuted = false
var bool contMuted = false
bool flipAllowed = not (edgeGate and flipMuted)
bool contAllowed = not (edgeGate and contMuted)

// candidate FLIP — a graded flip at a level. Flow veto only bites when it's TOXIC
// AND opposing (a hard veto on every sell-pressure bar was starving flips entirely).
// EVIDENCE RULE (Phase-3 finding): FLIP in a strong-trend regime was negative on
// every timeframe with samples (−0.15 to −0.61). Suppress it. Flipping WITH a mild
// trend or in reversion is still allowed; only regID==1 (STRONG TREND) is barred.
bool flipRegimeOK = not (regID == 1)
bool flipSideLong  = flipLong  and flipAllowed and flipRegimeOK and not (flowVeto and toxic and flowOpposesLong) and not mtfOpposeLong
bool flipSideShort = flipShort and flipAllowed and flipRegimeOK and not (flowVeto and toxic and flowOpposesShort) and not mtfOpposeShort

// global signal cooldown (both directions) — kills all label stacking incl. opposite-side
var int lastSigBar = -100000
int sigCool = math.max(pivLen + 2, 5)

// candidate CONTINUATION — uses the effective event (fade or chase). A break in
// the OPPOSITE direction to a very recent flip is that flip's thrust → suppress.
// Regime gate: chase wants trending; fade wants NON-trending (reversion/neutral).
int barsSinceFlipUp = ta.barssince(flipBull)
int barsSinceFlipDn = ta.barssince(flipBear)
bool contRegimeOK = fadeMode ? (regID != 1) : regTrend   // fade: anywhere but strong-trend; chase: trending only
// Lévy filter: suppress a CHASE-break continuation when PRICE is leading (flow chasing) — the squeeze /
// failed-break trap. Fade-mode continuations and flips are unaffected.
bool leadBlocksChase = leadFiltC and priceLeading and not fadeMode
bool contLongRaw  = useCont and contAllowed and resBreakEff and breakTouch >= contMinStrength and contRegimeOK and (not requireHTFcont or fadeMode or htfSum > 0) and not toxic and not leadBlocksChase and not mtfOpposeLong and not (nz(barsSinceFlipDn, 999) <= sigCool)
bool contShortRaw = useCont and contAllowed and supBreakEff and breakTouch >= contMinStrength and contRegimeOK and (not requireHTFcont or fadeMode or htfSum < 0) and not toxic and not leadBlocksChase and not mtfOpposeShort and not (nz(barsSinceFlipUp, 999) <= sigCool)

// per-direction cooldown vars removed — global cooldown handled below

// ── resolve THIS-BAR verdict in strict order ──────────────────────────────
// FLIP takes priority over CONTINUATION: a confirmed reversal at a level is the
// more decision-relevant event; a same-bar break usually IS the flip's thrust.
int   rawMode = 0
int   rawSide = 0
bool flipFire = flipSideLong or flipSideShort
bool contFire = contLongRaw or contShortRaw
bool standAsideNow = regChaos or volExtreme or toxic
bool bothDisagree = (flipSideLong and contShortRaw) or (flipSideShort and contLongRaw)

if standAsideNow and not flipFire
    rawMode := 1
else if flipFire
    rawMode := 2
    rawSide := flipSideLong ? 1 : -1
else if bothDisagree
    rawMode := 4
else if contFire
    rawMode := 3
    rawSide := contLongRaw ? 1 : -1
else if not nearAny
    rawMode := 1                       // mid-range, no level, no signal → stand aside
else
    rawMode := 0

// GLOBAL cooldown — any directional signal within sigCool of the last one is
// suppressed (both directions), which removes CONTCONT / adjacent stacking.
bool blockedByCool = bar_index - lastSigBar < sigCool
if (rawMode == 2 or rawMode == 3) and blockedByCool
    rawMode := 0
    rawSide := 0
if barstate.isconfirmed and (rawMode == 2 or rawMode == 3)
    lastSigBar := bar_index

// ── LATCH: hold the active verdict + levels until SL/TP hit or replaced ────
// Without this the panel/lines go blank the bar after a signal. The active
// verdict persists; a new opposite-or-stronger signal replaces it; price hitting
// SL or TP2 closes it back to the live (stand-aside/neutral) read.
var int   actMode = 0
var int   actSide = 0
var float actTrig = na, var float actSL = na, var float actT1 = na, var float actT2 = na
var string actT1Tag = "", var string actT2Tag = "", var string actDetail = ""

f_levels(int m, int sd) =>
    float tr = na, float sl = na, float p1 = na, float p2 = na
    string g1t = "", string g2t = ""
    if m == 2 and sd != 0
        tr := not na(flipPivot) ? flipPivot : (sd > 0 ? low : high)
        sl := sd > 0 ? tr - 0.5 * atrSafe : tr + 0.5 * atrSafe
    else if m == 3 and sd != 0
        tr := breakLine
        // fade mode → author's ORB geometry: SL = failure extreme, TP1 = opposite edge
        sl := fadeMode and not na(fadeStop) ? fadeStop : (sd > 0 ? math.min(nz(supNow, close - bD * slMul * sigPx), close - bD * slMul * sigPx) : math.max(nz(resNow, close + bD * slMul * sigPx), close + bD * slMul * sigPx))
    float tpm = m == 2 ? flipTPmul : 1.0     // flips book faster
    // base TP/SL distances: conformal (empirical) when ready+enabled, else vol-multiple
    bool cOK = useConf and confReady and not na(confTP) and not na(confSL)
    float tpDist = cOK ? confTP * tpm : bU * ptMul * tpm * sigPx
    float slDist = cOK ? confSL : bD * slMul * sigPx
    // apply conformal SL when no better structural stop already set
    if na(sl)
        sl := sd > 0 ? close - slDist : close + slDist
    else if cOK and m == 2
        sl := sd > 0 ? tr - slDist : tr + slDist     // flips: conformal-sized stop off the pivot
    float t1r = sd > 0 ? close + tpDist : close - tpDist
    float t2r = sd > 0 ? close + tpDist * tp2Mult : close - tpDist * tp2Mult
    // fade mode → TP1 snaps to the opposite hull edge (author's ORB reversal target)
    if m == 3 and fadeMode and not na(fadeTgt)
        t1r := fadeTgt
        t2r := sd > 0 ? fadeTgt + (fadeTgt - close) * (tp2Mult - 1.0) : fadeTgt - (close - fadeTgt) * (tp2Mult - 1.0)
    [s1v, s1g] = f_snap(t1r, snapTol * atrSafe)
    [s2v, s2g] = f_snap(t2r, snapTol * atrSafe)
    p1 := snapTP ? s1v : t1r, g1t := snapTP ? s1g : ""
    p2 := snapTP ? s2v : t2r, g2t := snapTP ? s2g : ""
    [tr, sl, p1, p2, g1t, g2t]

// close the active latch if SL or TP2 reached
bool latchClosed = false
if actMode != 0 and barstate.isconfirmed
    bool slHit = actSide > 0 ? low <= actSL  : high >= actSL
    bool tpHit = actSide > 0 ? high >= actT2 : low  <= actT2
    if slHit or tpHit
        latchClosed := true
        actMode := 0, actSide := 0
        actTrig := na, actSL := na, actT1 := na, actT2 := na, actT1Tag := "", actT2Tag := "", actDetail := ""

// a fresh directional verdict latches (replaces any active one — newest wins)
bool freshSignal = (rawMode == 2 or rawMode == 3) and rawSide != 0 and barstate.isconfirmed
if freshSignal
    [tr, sl, p1, p2, g1t, g2t] = f_levels(rawMode, rawSide)
    actMode := rawMode, actSide := rawSide
    actTrig := tr, actSL := sl, actT1 := p1, actT2 := p2, actT1Tag := g1t, actT2Tag := g2t
    actDetail := rawMode == 2 ? ("Flip " + flipTier + " @ " + flipLevelName) : ("Break · " + str.tostring(breakTouch) + " touches" + (na(contRate) ? "" : " · cont " + str.tostring(math.round(contRate * 100)) + "%"))

// ── what the panel/lines show: latched verdict if active, else live read ───
int    mode   = actMode != 0 ? actMode : rawMode
int    side   = actMode != 0 ? actSide : rawSide
float  trigger= actMode != 0 ? actTrig : na
float  slLvl  = actMode != 0 ? actSL   : na
float  tp1    = actMode != 0 ? actT1   : na
float  tp2    = actMode != 0 ? actT2   : na
string tp1Tag = actMode != 0 ? actT1Tag : ""
string tp2Tag = actMode != 0 ? actT2Tag : ""

string modeTxt = mode == 1 ? "STAND ASIDE" : mode == 2 ? "FLIP" : mode == 3 ? "CONTINUATION" : mode == 4 ? "CONFLICT" : "NEUTRAL"
string biasTxt = side > 0 ? "LONG" : side < 0 ? "SHORT" : "FLAT"
color  sideCol = side > 0 ? colBull : side < 0 ? colBear : colFlat
string liveDetail = actMode != 0 ? (actDetail + (latchClosed ? "" : " · active")) : (rawMode == 1 ? (regChaos ? "chaos" : volExtreme ? "extreme vol" : toxic ? "toxic tape" : "mid-range") : rawMode == 4 ? "engines disagree" : "no setup")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — CONFIDENCE  (transplant: AEGIS/SC-Breaks Wilson, on verdict dir)
// ══════════════════════════════════════════════════════════════════════════════
// unified verdict-outcome tracker (triple-barrier on the entry direction).
// Records regime-bucketed hit-rate (for the panel confidence chip) AND per-MODE
// win/loss/timeout + realized R (for the v0.2 backtest strip).
type Vd
    int dir
    int reg
    int md          // 2 FLIP · 3 CONT
    float entry
    float atr0
    int bidx
    float tpD
    float slD
    bool done
var array<Vd> pendV = array.new<Vd>()
var int[] vHit = array.new_int(6, 0)      // regime-bucketed hits (panel confidence)
var int[] vTot = array.new_int(6, 0)
// per-mode accounting: index 0 = FLIP, 1 = CONT
var int[]   mW  = array.new_int(2, 0)     // wins (TP hit)
var int[]   mL  = array.new_int(2, 0)     // losses (SL hit)
var int[]   mTO = array.new_int(2, 0)     // timeouts
var float[] mR  = array.new_float(2, 0.0) // sum realized R
// regime × mode accounting (Phase 1): regime CLASS 0=Trend(1,2) 1=Neutral(3) 2=Reversion(4).
// CHAOS(5) is excluded (stand-aside). 6 cells = 2 modes × 3 classes, flattened as mi*3+rc.
var int[]   rmW = array.new_int(6, 0)     // wins
var int[]   rmL = array.new_int(6, 0)     // losses
var int[]   rmN = array.new_int(6, 0)     // total resolved (incl timeout)
var float[] rmR = array.new_float(6, 0.0) // sum realized R
f_regClass(int reg) => (reg == 1 or reg == 2) ? 0 : reg == 3 ? 1 : reg == 4 ? 2 : -1
// rolling recent-outcome buffers per mode (1 = win, 0 = loss; timeouts excluded).
// Used ONLY by the edge-gate so it reflects RECENT behaviour and can auto-un-mute.
var array<int> rollFlip = array.new<int>()
var array<int> rollCont = array.new<int>()
f_mi(int md) => md == 2 ? 0 : 1
f_roll(int mi) => mi == 0 ? rollFlip : rollCont

bool newVerdict = freshSignal and rawSide != 0
if newVerdict and atr > 0
    float tpmN = rawMode == 2 ? flipTPmul : 1.0
    bool  cOKn = useConf and confReady and not na(confTP) and not na(confSL)
    float tpDn = cOKn ? confTP * tpmN : bU * ptMul * tpmN * sigPx
    float slDn = cOKn ? confSL : bD * slMul * sigPx
    pendV.push(Vd.new(rawSide, regID, rawMode, close, atr, bar_index, tpDn, slDn, false))
if barstate.isconfirmed and pendV.size() > 0
    for i = pendV.size() - 1 to 0
        Vd p = pendV.get(i)
        if not p.done
            int   horO = p.md == 2 ? math.max(3, int(calHorizon * flipHorMul)) : calHorizon
            float favor   = p.dir > 0 ? (high - p.entry) : (p.entry - low)
            float adverse = p.dir > 0 ? (p.entry - low)  : (high - p.entry)
            bool cHit = favor   >= p.tpD
            bool fHit = adverse >= p.slD
            bool tmOut= bar_index - p.bidx >= horO
            if cHit or fHit or tmOut
                p.done := true
                int b  = math.max(0, math.min(5, p.reg))
                int mi = f_mi(p.md)
                int rc = f_regClass(p.reg)
                int rmc = rc >= 0 ? mi * 3 + rc : -1
                array.set(vTot, b, array.get(vTot, b) + 1)
                float rr = p.slD > 0 ? p.tpD / p.slD : 1.0        // realized reward:risk of the actual barriers
                if rmc >= 0
                    array.set(rmN, rmc, array.get(rmN, rmc) + 1)
                if fHit and not cHit
                    // stop first (STOP-first on same-bar tie) → loss of 1R
                    array.set(mL, mi, array.get(mL, mi) + 1)
                    array.set(mR, mi, array.get(mR, mi) - 1.0)
                    array.push(f_roll(mi), 0)
                    if rmc >= 0
                        array.set(rmL, rmc, array.get(rmL, rmc) + 1)
                        array.set(rmR, rmc, array.get(rmR, rmc) - 1.0)
                else if cHit
                    array.set(vHit, b, array.get(vHit, b) + 1)
                    array.set(mW, mi, array.get(mW, mi) + 1)
                    array.set(mR, mi, array.get(mR, mi) + rr)
                    array.push(f_roll(mi), 1)
                    if rmc >= 0
                        array.set(rmW, rmc, array.get(rmW, rmc) + 1)
                        array.set(rmR, rmc, array.get(rmR, rmc) + rr)
                else
                    // timeout → realized R = forward move / risk unit
                    float fwd = p.dir > 0 ? (close - p.entry) : (p.entry - close)
                    float rTO = p.slD > 0 ? fwd / p.slD : 0.0
                    array.set(mTO, mi, array.get(mTO, mi) + 1)
                    array.set(mR, mi, array.get(mR, mi) + rTO)
                    if fwd >= p.tpD
                        array.set(vHit, b, array.get(vHit, b) + 1)   // count as a soft win for confidence
                    if rmc >= 0
                        array.set(rmR, rmc, array.get(rmR, rmc) + rTO)
                // cap the rolling buffer to the gate window
                while array.size(f_roll(mi)) > edgeWin
                    array.shift(f_roll(mi))
                pendV.remove(i)
float confWL = array.get(vTot, _cb) >= calMinSamp ? f_wilsonLo(array.get(vHit, _cb), array.get(vTot, _cb), 1.96) : na
int   confN  = array.get(vTot, _cb)
string confTxt = confN < calMinSamp ? "uncalibrated (" + str.tostring(confN) + "/" + str.tostring(calMinSamp) + ")" : str.tostring(math.round(nz(confWL) * 100)) + "% floor (n" + str.tostring(confN) + ")"

// per-mode summary helpers for the backtest strip
f_modeN(int mi) => array.get(mW, mi) + array.get(mL, mi) + array.get(mTO, mi)
f_modeWin(int mi) =>
    int n = f_modeN(mi)
    int decisive = array.get(mW, mi) + array.get(mL, mi)     // exclude timeouts from win-rate
    decisive > 0 ? array.get(mW, mi) / float(decisive) : na
f_modeAvgR(int mi) =>
    int n = f_modeN(mi)
    n > 0 ? array.get(mR, mi) / n : na
// per-mode confidence for the panel (Wilson floor on the CURRENT mode's decisive record)
f_modeWL(int mi) =>
    int decisive = array.get(mW, mi) + array.get(mL, mi)
    decisive >= calMinSamp ? f_wilsonLo(array.get(mW, mi), decisive, 1.96) : na

// update edge-gate mute flags from the ROLLING window with hysteresis.
// A mode mutes when its recent win-rate drops below edgeMute, and un-mutes when it
// recovers above edgeUnmute — so a mode that starts paying again comes back on its
// own. Needs a full-ish window before it can mute (avoids muting on a cold start).
f_rollWin(int mi) =>
    a = f_roll(mi)
    int n = array.size(a)
    n > 0 ? array.sum(a) / float(n) : na
int   flipRN = array.size(rollFlip)
int   contRN = array.size(rollCont)
float flipRW = f_rollWin(0)
float contRW = f_rollWin(1)
int   edgeMin = math.max(calMinSamp, int(edgeWin * 0.5))   // need half a window to act
if flipRN >= edgeMin
    if not na(flipRW) and flipRW < edgeMute
        flipMuted := true
    else if not na(flipRW) and flipRW >= edgeUnmute
        flipMuted := false
if contRN >= edgeMin
    if not na(contRW) and contRW < edgeMute
        contMuted := true
    else if not na(contRW) and contRW >= edgeUnmute
        contMuted := false

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 12 — DRAW LEVELS  (Trigger / SL / TP1 / TP2)
// ══════════════════════════════════════════════════════════════════════════════
var line lnTrig = na, var line lnSL = na, var line lnT1 = na, var line lnT2 = na
var label lbTrig = na, var label lbSL = na, var label lbT1 = na, var label lbT2 = na
f_setLine(line ln, float y, color c, string st) =>
    line r = ln
    if na(y)
        if not na(ln)
            line.delete(ln)
            r := na
    else
        if na(ln)
            r := line.new(bar_index, y, bar_index + 25, y, color = c, width = 2, style = st, extend = extend.none)
        else
            line.set_xy1(ln, bar_index, y), line.set_xy2(ln, bar_index + 25, y), line.set_color(ln, c)
    r
f_setLbl(label lb, float y, string txt, color c) =>
    label r = lb
    if na(y)
        if not na(lb)
            label.delete(lb)
            r := na
    else
        if na(lb)
            r := label.new(bar_index + 25, y, txt, style = label.style_label_left, color = color.new(c, 15), textcolor = color.white, size = size.small)
        else
            label.set_xy(lb, bar_index + 25, y), label.set_text(lb, txt), label.set_color(lb, color.new(c, 15))
    r
if barstate.islast
    bool show = drawLevels and (mode == 2 or mode == 3)
    lnTrig := f_setLine(lnTrig, show ? trigger : na, color.new(#ffd166, 0), line.style_solid)
    lnSL   := f_setLine(lnSL,   show ? slLvl : na,   color.new(colBear, 0), line.style_dashed)
    lnT1   := f_setLine(lnT1,   show ? tp1 : na,     color.new(colBull, 0), line.style_dashed)
    lnT2   := f_setLine(lnT2,   show ? tp2 : na,     color.new(colBull, 30), line.style_dashed)
    lbTrig := f_setLbl(lbTrig, show ? trigger : na, "Trigger " + str.tostring(trigger, format.mintick), #ffd166)
    lbSL   := f_setLbl(lbSL,   show ? slLvl : na,   "SL " + str.tostring(slLvl, format.mintick), colBear)
    lbT1   := f_setLbl(lbT1,   show ? tp1 : na,     "TP1 " + str.tostring(tp1, format.mintick) + (tp1Tag == "" ? "" : " ›" + tp1Tag), colBull)
    lbT2   := f_setLbl(lbT2,   show ? tp2 : na,     "TP2 " + str.tostring(tp2, format.mintick) + (tp2Tag == "" ? "" : " ›" + tp2Tag), colBull)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 13 — VERDICT PANEL
// ══════════════════════════════════════════════════════════════════════════════
f_prow(table tb, int r, string k, string v, color kc, color vc, color rb) =>
    table.cell(tb, 0, r, k, text_color = kc, bgcolor = rb, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, v, text_color = vc, bgcolor = rb, text_size = size.small, text_halign = text.align_right)

var table pnl = table.new(f_pos(panelPos), 2, 12, border_width = 1, frame_width = 1)
if showPanel and barstate.islast
    color bg = chart.bg_color
    bool dark = panelTheme == "Auto" ? (na(bg) or f_luma(bg) < 140) : panelTheme == "Dark"
    color cP = dark ? color.rgb(13, 17, 23) : color.rgb(244, 246, 248)
    color cS = dark ? color.rgb(22, 27, 34) : color.rgb(233, 237, 242)
    color cT = dark ? color.rgb(226, 232, 240) : color.rgb(20, 26, 38)
    color cD = dark ? color.rgb(150, 160, 174) : color.rgb(96, 104, 116)
    color cTrig = dark ? #ffd166 : #9a6b00   // theme-aware Trigger text: light yellow reads poorly on a Light panel, so darken it there
    color modeBg = mode == 1 ? color.new(colFlat, 0) : mode == 4 ? color.new(#d29922, 0) : side > 0 ? color.new(colBull, 0) : side < 0 ? color.new(colBear, 0) : color.new(colFlat, 0)
    table.cell(pnl, 0, 0, "DBFC", text_color = color.white, bgcolor = modeBg, text_size = size.small, text_halign = text.align_left)
    table.cell(pnl, 1, 0, biasTxt + " · " + modeTxt, text_color = color.white, bgcolor = modeBg, text_size = size.small, text_halign = text.align_right)
    // confidence: when a FLIP/CONT is active, show THAT mode's floor; else the pooled regime floor
    int    liveMi = (mode == 2 or mode == 3) ? f_mi(mode) : -1
    float  modeFl = liveMi >= 0 ? f_modeWL(liveMi) : na
    int    modeDe = liveMi >= 0 ? array.get(mW, liveMi) + array.get(mL, liveMi) : 0
    string confShow = liveMi >= 0 ? (modeDe < calMinSamp ? "uncalibrated (" + str.tostring(modeDe) + "/" + str.tostring(calMinSamp) + ")" : (mode == 2 ? "FLIP " : "CONT ") + str.tostring(math.round(nz(modeFl) * 100)) + "% floor (n" + str.tostring(modeDe) + ")") : confTxt
    // COMPACT (default): the essential decision rows only — side/state (row 0), confidence, Trigger/SL/TP1/TP2.
    f_prow(pnl, 1, "Confidence", confShow, cD, cT, cS)
    f_prow(pnl, 2, "Trigger", (mode == 2 or mode == 3) and not na(trigger) ? str.tostring(trigger, format.mintick) : "—", cD, cTrig, cP)
    f_prow(pnl, 3, "SL", (mode == 2 or mode == 3) and not na(slLvl) ? str.tostring(slLvl, format.mintick) : "—", cD, colBear, cS)
    f_prow(pnl, 4, "TP1", (mode == 2 or mode == 3) and not na(tp1) ? str.tostring(tp1, format.mintick) + (tp1Tag == "" ? "" : " ›" + tp1Tag) : "—", cD, colBull, cP)
    f_prow(pnl, 5, "TP2", (mode == 2 or mode == 3) and not na(tp2) ? str.tostring(tp2, format.mintick) + (tp2Tag == "" ? "" : " ›" + tp2Tag) : "—", cD, colBull, cS)
    // PRO: append the detail/internals rows (regime, agreement, flow, detail). Left blank in Compact.
    if dashMode == "Pro"
        f_prow(pnl, 6, "Regime · vol", f_regName(regID) + " · " + volState, cD, regTrend ? colBull : regChaos ? colBear : cD, cP)
        string agree = "R" + (regTrend ? "✓" : "·") + " F" + ((flipFire) ? "✓" : "·") + " B" + (breakDir != 0 ? "✓" : "·") + " H" + (htfSum > 0 ? "▲" : htfSum < 0 ? "▼" : "·") + " M" + (mtfAlign > 0 ? "▲" : mtfAlign < 0 ? "▼" : "·")
        f_prow(pnl, 7, "Agreement", agree, cD, cT, cS)
        string flowShow = (flowDir > 0 ? "▲ buy" : "▼ sell") + " · tox " + (na(vpin) ? "—" : str.tostring(math.round(vpin * 100)) + "%") + (toxic ? " ⚠" : "")
        f_prow(pnl, 8, "Flow · toxicity", flowShow, cD, flowDir > 0 ? colBull : colBear, cP)
        string leadShow = not leadOn ? "off" : leadState == -9 ? "warming" : leadState == 1 ? "▲ FLOW leads" : leadState == -1 ? "▼ PRICE leads" : "· balanced"
        f_prow(pnl, 9, "Flow lead", leadShow + (levyReady and leadState != -9 ? " · p" + str.tostring(math.round(levyRank)) : ""), cD, leadState == 1 ? colBull : leadState == -1 ? colBear : cD, cP)
        string mtfShow = not mtfOn ? "off" : (mtfAlign >= 0 ? "+" : "") + str.tostring(mtfAlign) + "/3 · conv " + str.tostring(mtfConf, "0")
        f_prow(pnl, 10, "MTF flow", mtfShow, cD, mtfAlign > 0 ? colBull : mtfAlign < 0 ? colBear : cD, cP)
        f_prow(pnl, 11, "Detail", liveDetail, cD, cD, cS)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 13b — BACKTEST STRIP  (win% + avg R by mode, forward triple-barrier)
// ══════════════════════════════════════════════════════════════════════════════
f_btRow(table tb, int r, string lbl, int mi, color rb, color cT2, color cD2, color colB, color colBr, int minS, bool muted) =>
    int n = f_modeN(mi)
    float w = f_modeWin(mi)
    float ar = f_modeAvgR(mi)
    int dec = array.get(mW, mi) + array.get(mL, mi)
    string ws = dec < minS ? "warming" : str.tostring(math.round(nz(w) * 100)) + "%"
    string rs = n < minS ? "—" : (nz(ar) >= 0 ? "+" : "") + str.tostring(ar, "0.00")
    color arc = n < minS ? cD2 : nz(ar) > 0 ? colB : colBr
    string lblShow = muted ? lbl + " ⊘" : lbl
    table.cell(tb, 0, r, lblShow, text_color = muted ? colBr : cT2, bgcolor = rb, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, str.tostring(n), text_color = cD2, bgcolor = rb, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 2, r, ws, text_color = dec >= minS and nz(w) >= 0.5 ? colB : cT2, bgcolor = rb, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 3, r, rs, text_color = arc, bgcolor = rb, text_size = size.small, text_halign = text.align_right)

var table bt = table.new(position.bottom_left, 4, 4, border_width = 1, frame_width = 1)
if showBT and barstate.islast
    color bg2 = chart.bg_color
    bool dk2 = panelTheme == "Auto" ? (na(bg2) or f_luma(bg2) < 140) : panelTheme == "Dark"
    color cP2 = dk2 ? color.rgb(13, 17, 23) : color.rgb(244, 246, 248)
    color cS2 = dk2 ? color.rgb(22, 27, 34) : color.rgb(233, 237, 242)
    color cT2 = dk2 ? color.rgb(226, 232, 240) : color.rgb(20, 26, 38)
    color cD2 = dk2 ? color.rgb(150, 160, 174) : color.rgb(96, 104, 116)
    color hd2 = dk2 ? color.rgb(30, 38, 60) : color.rgb(222, 228, 236)
    // header
    table.cell(bt, 0, 0, "DBFC EDGE", text_color = color.white, bgcolor = hd2, text_size = size.small, text_halign = text.align_left)
    table.cell(bt, 1, 0, "n", text_color = cD2, bgcolor = hd2, text_size = size.small, text_halign = text.align_right)
    table.cell(bt, 2, 0, "Win%", text_color = cD2, bgcolor = hd2, text_size = size.small, text_halign = text.align_right)
    table.cell(bt, 3, 0, "Avg R", text_color = cD2, bgcolor = hd2, text_size = size.small, text_halign = text.align_right)
    f_btRow(bt, 1, "FLIP", 0, cP2, cT2, cD2, colBull, colBear, calMinSamp, edgeGate and flipMuted)
    f_btRow(bt, 2, "CONT", 1, cS2, cT2, cD2, colBull, colBear, calMinSamp, edgeGate and contMuted)
    // combined footer
    int allN = f_modeN(0) + f_modeN(1)
    int allDec = array.get(mW, 0) + array.get(mL, 0) + array.get(mW, 1) + array.get(mL, 1)
    int allW = array.get(mW, 0) + array.get(mW, 1)
    float allR = allN > 0 ? (array.get(mR, 0) + array.get(mR, 1)) / allN : na
    string allWs = allDec < calMinSamp ? "warming" : str.tostring(math.round(allW / float(allDec) * 100)) + "%"
    string allRs = allN < calMinSamp ? "—" : (nz(allR) >= 0 ? "+" : "") + str.tostring(allR, "0.00")
    table.cell(bt, 0, 3, "ALL", text_color = cD2, bgcolor = hd2, text_size = size.small, text_halign = text.align_left)
    table.cell(bt, 1, 3, str.tostring(allN), text_color = cD2, bgcolor = hd2, text_size = size.small, text_halign = text.align_right)
    table.cell(bt, 2, 3, allWs, text_color = cD2, bgcolor = hd2, text_size = size.small, text_halign = text.align_right)
    table.cell(bt, 3, 3, allRs, text_color = allN < calMinSamp ? cD2 : nz(allR) > 0 ? colBull : colBear, bgcolor = hd2, text_size = size.small, text_halign = text.align_right)

// ── regime × mode grid (Avg R by regime class) ──
f_rmCell(int mi, int rc) =>
    int idx = mi * 3 + rc
    int n = array.get(rmN, idx)
    float r = n > 0 ? array.get(rmR, idx) / n : na
    [n, r]
f_rgRow(table tb, int r, string lbl, int mi, color rb, color cT, color cDd, color cB, color cBr, int minS) =>
    table.cell(tb, 0, r, lbl, text_color = cT, bgcolor = rb, text_size = size.small, text_halign = text.align_left)
    for rc = 0 to 2
        [n, ar] = f_rmCell(mi, rc)
        string s = n < minS ? (n == 0 ? "·" : "n" + str.tostring(n)) : (nz(ar) >= 0 ? "+" : "") + str.tostring(ar, "0.00")
        color c = n < minS ? cDd : nz(ar) > 0 ? cB : cBr
        table.cell(tb, rc + 1, r, s, text_color = c, bgcolor = rb, text_size = size.small, text_halign = text.align_right)
var table rg = table.new(position.bottom_left, 4, 3, border_width = 1, frame_width = 1)
if showBT and showRegBrk and barstate.islast
    color bg3 = chart.bg_color
    bool dk3 = panelTheme == "Auto" ? (na(bg3) or f_luma(bg3) < 140) : panelTheme == "Dark"
    color cP3 = dk3 ? color.rgb(13, 17, 23) : color.rgb(244, 246, 248)
    color cS3 = dk3 ? color.rgb(22, 27, 34) : color.rgb(233, 237, 242)
    color cT3 = dk3 ? color.rgb(226, 232, 240) : color.rgb(20, 26, 38)
    color cD3 = dk3 ? color.rgb(150, 160, 174) : color.rgb(96, 104, 116)
    color hd3 = dk3 ? color.rgb(30, 38, 60) : color.rgb(222, 228, 236)
    table.cell(rg, 0, 0, "AvgR by regime", text_color = color.white, bgcolor = hd3, text_size = size.small, text_halign = text.align_left)
    table.cell(rg, 1, 0, "Trend", text_color = cD3, bgcolor = hd3, text_size = size.small, text_halign = text.align_right)
    table.cell(rg, 2, 0, "Neut", text_color = cD3, bgcolor = hd3, text_size = size.small, text_halign = text.align_right)
    table.cell(rg, 3, 0, "Rev", text_color = cD3, bgcolor = hd3, text_size = size.small, text_halign = text.align_right)
    f_rgRow(rg, 1, "FLIP", 0, cP3, cT3, cD3, colBull, colBear, calMinSamp)
    f_rgRow(rg, 2, "CONT", 1, cS3, cT3, cD3, colBull, colBear, calMinSamp)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 14 — SIGNAL MARKERS + ALERTS
// ══════════════════════════════════════════════════════════════════════════════
plotshape(freshSignal and rawMode == 2 and rawSide > 0, "Flip Long",  shape.triangleup,   location.belowbar, color.new(colBull, 0), size = size.small, text = "FLIP")
plotshape(freshSignal and rawMode == 2 and rawSide < 0, "Flip Short", shape.triangledown, location.abovebar, color.new(colBear, 0), size = size.small, text = "FLIP")
plotshape(freshSignal and rawMode == 3 and rawSide > 0, "Cont Long",  shape.triangleup,   location.belowbar, color.new(colBull, 20), size = size.tiny, text = "CONT")
plotshape(freshSignal and rawMode == 3 and rawSide < 0, "Cont Short", shape.triangledown, location.abovebar, color.new(colBear, 20), size = size.tiny, text = "CONT")

alertcondition(freshSignal and rawMode == 2 and rawSide > 0, "DBFC FLIP Long",  "DBFC: FLIP long")
alertcondition(freshSignal and rawMode == 2 and rawSide < 0, "DBFC FLIP Short", "DBFC: FLIP short")
alertcondition(freshSignal and rawMode == 3 and rawSide > 0, "DBFC CONT Long",  "DBFC: continuation long")
alertcondition(freshSignal and rawMode == 3 and rawSide < 0, "DBFC CONT Short", "DBFC: continuation short")
alertcondition(latchClosed, "DBFC Trade Closed", "DBFC: SL/TP reached")
````
