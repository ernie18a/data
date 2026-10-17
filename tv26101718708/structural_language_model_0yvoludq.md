# Structural Language Model

- url: https://www.tradingview.com/script/0YVoLUDQ-Structural-Language-Model/
- type: indicator
- pine_id: PUB;ad8567e9fcba40a0890d34bc86bc547c
- version: 2.0

## Description

Overview

Structural Language Model treats price action as a language. Each bar is tokenised into one of five structural symbols, and a low-order Markov model learns the grammar — the probability of what comes next given the recent context. Instead of "match the nearest historical shape" (fragile, overfit-prone k-NN), it estimates P(next token | last k tokens): a nonparametric conditional-move model that proves or disproves itself, live, on your symbol. It is a research/forecast read, not a signal service.

The five-symbol grammar

Every bar becomes one token, built from robust intrabar primitives (gap-immune, no fragile sweep/FVG detection), with adaptive thresholds so the alphabet stays balanced across symbols and timeframes:


X− down impulse · d ordinary down · c compression / indecision · u ordinary up · X+ up impulse


The model then learns grammar like c → X+ (breakout), X+ → X− (reversal), runs of u/X+ (trend), X+ → c (exhaustion), using order-1 or order-2 transition counts with Laplace smoothing, updated online.

Why these parts are one tool


The tokeniser turns raw OHLC into a balanced, information-rich alphabet — without it the Markov counts are dominated by whatever token is most common.
The Markov model reads out, each bar, a directional bias (P up-ish − P down-ish), a predictability score (how peaked the next-token distribution is, via normalized entropy), a structural-surprise spike (−log P of the token that just printed — a grammar break), and the full next-bar probability ladder.
The harness is the part that makes it honest. It's prequential (predict-then-update: each transition is scored from counts that exclude its own outcome, so every score is out-of-sample), it runs a walk-forward in-sample vs out-of-sample split with Wilson 95% intervals, and it draws a reliability curve — binning OOS predictions by predicted P(up) and showing the realized up-rate per bin. A rising, significant curve = real calibrated information; a flat one = none. Remove any part and you can no longer answer "is this model actually calibrated on this market?"


How to use it

Read the directional bias line against its conviction bands as context, not a trigger, and check predictability for how peaked the forecast is. Then read the harness — the model is only worth trusting where the out-of-sample up-lean lift is above 1 and/or the reliability spread is positive and significant (✓sig). A flat or insignificant curve means there's no calibrated edge here; treat it as descriptive only, or try another symbol/timeframe. The dashboard has a Compact layout (default: forecast + the one calibration line that matters) and a Pro layout (the full ladder, in/out-of-sample lift, and the three-bin reliability curve). Bias-turn crosses are optionally mirrored on the price chart. It is never a standalone signal.

Non-repainting

Tokens and counts update only on confirmed bars, and the score for bar t uses counts as they stood before bar t's transition was added — nothing reads its own future. The live next-bar forecast naturally refines as the current bar forms (it's a forecast, not a settled statistic). All harness figures are out-of-sample by construction.

Honest limits

OHLCV only. A per-bar tokeniser maximises samples but is coarser than a swing/event grammar (a documented future extension). Any edge is typically modest and market/timeframe-dependent — directional forecasting on noisy price is hard, and no indicator has an inherent edge. That's exactly why the harness is built in: validate it before trusting it.

Outputs for other scripts

Generic EXP_* plots — bias, predictability, structural surprise, live P(next up-ish), and the OOS lift — are published to the Data Window for use from other scripts via input.source().

Concept credits


Markov chains / n-gram language models — A. Markov (1913); C. Shannon (1948)
Prequential (predict-then-update) evaluation — A. P. Dawid (1984)
Additive (Laplace) smoothing — P.-S. Laplace
Entropy — C. Shannon (1948)
Wilson score interval — E. B. Wilson (1927)


Synthesis and Pine implementation are the author's own; no third-party Pine code reused.

Disclaimer

Research and education only. Not financial advice, not a signal service, not a guarantee of future results. Validate with your own testing, apply realistic costs, and manage risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// STRUCTURAL LANGUAGE MODEL  (SLM)                                                            v1.2
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.2 — Correctness + theme + cost pass (no model change):
//   • Correctness: the "ignore first session bar" guard called ta.change from behind a short-circuiting
//     `and`, so it was skipped when the toggle was off (CW10004). Hoisted to run every bar; output same.
//   • The dashboard theme is now BACKGROUND-ADAPTIVE (Auto / Dark / Light) reading chart.bg_color,
//     replacing the manual dark-only toggle — legible on any chart.
//   • Cost model for a forecaster: the calibration measures directional ACCURACY, so v1.2 adds the
//     tradeable question — on high-conviction OUT-OF-SAMPLE bars, the average next-bar return in the
//     model's leaned direction, NET of a round-trip cost input, in bps/bar. Positive = the forecast
//     survives costs. Shown in the panel and exported (EXP_NetEdgeBps). Non-repainting: the lean is
//     known at the prior close; the return is realised on the next bar.
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   Treats price action as a LANGUAGE. Each bar is tokenised into one of five structural symbols,
//   and a low-order Markov model learns the GRAMMAR — the probability of what comes next given the
//   recent context. Instead of "pattern match the nearest historical shape" (fragile, overfit-prone
//   k-NN), it estimates P(next token | last k tokens): a nonparametric conditional-move model.
//
//   TOKENISER (5-symbol bar grammar, built from robust INTRABAR primitives — gap-immune, no fragile
//   sweep/FVG detection). Thresholds are ADAPTIVE (range percentile vs recent history) so the five
//   symbols stay balanced across symbols/timeframes, maximising the grammar's information:
//        X-  down impulse      (wide range, down body)
//        d   ordinary down
//        c   compression / indecision   (narrow range, or wide range with tiny body)
//        u   ordinary up
//        X+  up impulse        (wide range, up body)
//   Grammar examples the model can learn: c -> X+  (breakout),  X+ -> X-  (reversal),
//   runs of u/X+ (trend),  X+ -> c  (exhaustion).
//
//   MODEL: order-1 or order-2 Markov transition counts with Laplace smoothing, learned ONLINE.
//   Read-outs each bar (colour scheme: GREEN bullish / YELLOW neutral / RED bearish):
//        • DIRECTIONAL BIAS  (-100..+100): P(next up-ish) - P(next down-ish).
//        • PREDICTABILITY    (0..100): how peaked the next-token distribution is (1 - norm. entropy).
//        • STRUCTURAL SURPRISE: -log P(the token that just occurred) — spikes = grammar break.
//        • PROBABILITY LADDER: the full next-bar distribution over the five tokens.
//
// THE FALSIFIABLE CLAIM (and the harness that tests it)
//   Claim: the model's predicted P(next up-ish) is CALIBRATED — bars where it predicts a higher
//   up-probability actually resolve up-ish more often. The harness is PREQUENTIAL (predict-then-
//   update): each transition is predicted from counts that EXCLUDE its own outcome, so every score
//   is out-of-sample. On top of that it runs a WALK-FORWARD split (in-sample vs out-of-sample) with
//   Wilson 95% intervals, and a RELIABILITY CURVE that bins out-of-sample predictions by predicted
//   P(up) and shows the realized up-rate per bin. A rising, significant curve = real calibrated
//   information; a flat curve = none. The model proves or disproves itself on YOUR symbol/timeframe.
//
// HOW TO USE
//   Read the directional bias line against its conviction bands (context, not a trade trigger), and
//   check PREDICTABILITY for how peaked the forecast is. Then read the harness: the model is only
//   worth trusting where the OUT-OF-SAMPLE up-lean lift is above 1 and/or the reliability spread is
//   positive AND significant (✓sig). A flat/insignificant curve means no calibrated edge here — try
//   another symbol/timeframe or treat it as descriptive only. The dashboard has a COMPACT (default)
//   and a PRO layout. Never a standalone signal.
//
// NON-REPAINT
//   Tokens and counts update only on CONFIRMED bars. The score for bar t uses counts as they stood
//   BEFORE bar t's transition was added — nothing reads its own future. The live next-bar forecast
//   naturally refines as the current bar forms (it is a forecast, not a settled statistic).
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Bias · EXP_Predict · EXP_Surprise · EXP_PUp (live P next up-ish) · EXP_LiftOOS ·
//   EXP_NetEdgeBps (net-of-cost directional return, bps/bar, on high-conviction OOS bars)
//
// HONEST LIMITS
//   OHLCV only. A per-bar tokeniser maximises samples but is coarser than a swing/event grammar
//   (a documented future extension). Any edge is typically MODEST and market/timeframe-dependent —
//   directional forecasting on noisy price is hard. No indicator has an inherent edge. Validate it.
//
// CONCEPT CREDITS
//   • Markov chains / n-gram language models — A. Markov (1913); C. Shannon (1948).
//   • Prequential (predict-then-update) evaluation — A. P. Dawid (1984).
//   • Additive (Laplace) smoothing — P.-S. Laplace.
//   • Entropy — C. Shannon (1948).
//   • Wilson score interval — E. B. Wilson (1927).
//   Synthesis and Pine implementation are the author's own.
//
// DISCLAIMER
//   Research and education only. NOT financial advice, NOT a signal service, NOT a guarantee of
//   future results. Validate with your own testing, apply realistic costs, and manage risk.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Structural Language Model", "SLM", overlay = false, max_bars_back = 5000,
     max_labels_count = 100, precision = 2)

// ═════════════════════════ 00 · DATA ══════════════════════════════════════════════════════════
g0       = "00 · Data"
useRTH   = input.bool(false, "Ignore first bar of session", group = g0,
     tooltip = "Skips tokenising the first bar of each intraday session (often an outlier). Off = tokenise every bar.")

// ═════════════════════════ 01 · TOKENISER (bar grammar) ═══════════════════════════════════════
g1       = "01 · Tokeniser (bar grammar)"
atrLen   = input.int(20, "Range-average length", minval = 5, maxval = 200, group = g1,
     tooltip = "Baseline average bar range (ATR-style) that 'normal' is measured against.")
expHi    = input.float(1.6, "Impulse threshold (range / avg)", minval = 1.1, maxval = 4.0, step = 0.1, group = g1,
     tooltip = "A bar whose range exceeds this multiple of the average, with a decisive body, is an IMPULSE (X+/X-).")
compLo   = input.float(0.6, "Compression threshold (range / avg)", minval = 0.1, maxval = 1.0, step = 0.05, group = g1,
     tooltip = "A bar whose range is below this multiple of the average is COMPRESSION (c).")
bodyMin  = input.float(0.35, "Min body fraction for impulse", minval = 0.0, maxval = 1.0, step = 0.05, group = g1,
     tooltip = "An impulse needs a body at least this fraction of its range. A wide-range bar with a tiny body (rejection/doji) is treated as compression instead.")
adaptTok = input.bool(true, "Adaptive thresholds (balanced alphabet)", group = g1,
     tooltip = "ON: impulse/compression are judged by the bar range's PERCENTILE vs recent history, so the five tokens stay balanced across symbols/timeframes (more information per symbol). OFF: use the fixed multiples above.")
tokBase  = input.int(500, "Adaptive baseline (bars)", minval = 100, maxval = 3000, group = g1,
     tooltip = "History used to rank the current bar's range when adaptive thresholds are on.")
pHi      = input.float(0.70, "Impulse percentile", minval = 0.5, maxval = 0.95, step = 0.05, group = g1,
     tooltip = "Range at/above this percentile of its history counts as an impulse (0.70 = the widest ~30% of bars).")
pLo      = input.float(0.35, "Compression percentile", minval = 0.05, maxval = 0.5, step = 0.05, group = g1,
     tooltip = "Range at/below this percentile counts as compression (0.35 = the narrowest ~35% of bars).")

// ═════════════════════════ 02 · MARKOV MODEL ══════════════════════════════════════════════════
g2       = "02 · Markov model"
order    = input.int(2, "Context order (k)", minval = 1, maxval = 2, group = g2,
     tooltip = "How many recent tokens define the context. 1 = last token; 2 = last two tokens (25 contexts, needs more history but richer grammar).")
alpha    = input.float(0.5, "Laplace smoothing", minval = 0.0, maxval = 5.0, step = 0.1, group = g2,
     tooltip = "Pseudo-count added to every transition. Stabilises thin contexts; higher = the model trusts data less and stays near uniform.")
minCtxN  = input.int(20, "Min samples for a live forecast", minval = 1, maxval = 500, group = g2,
     tooltip = "The live forecast is greyed as 'thin' until the current context has been seen at least this many times.")

// ═════════════════════════ 03 · READOUT ═══════════════════════════════════════════════════════
g3       = "03 · Read-out"
biasThr  = input.float(0.20, "Conviction threshold |bias|", minval = 0.02, maxval = 0.9, step = 0.02, group = g3,
     tooltip = "The model is 'confident' when directional bias exceeds this (bias is P(up-ish)-P(down-ish), range -1..+1). Used for the harness and alerts.")
surpLen  = input.int(200, "Surprise baseline (bars)", minval = 30, maxval = 2000, group = g3,
     tooltip = "History used to judge whether the latest structural surprise is unusually high (grammar break).")

// ═════════════════════════ 04 · CALIBRATION HARNESS ═══════════════════════════════════════════
g4       = "04 · Calibration harness"
wfMode   = input.string("Fraction of history", "Walk-forward split by", options = ["Fraction of history", "Date"], group = g4,
     tooltip = "Fraction = most recent X% of loaded bars are out-of-sample (auto-adapts; recommended). Date = fixed timestamp split.")
wfFrac   = input.float(0.5, "OOS = most recent fraction", minval = 0.1, maxval = 0.9, step = 0.05, group = g4)
wfSplit  = input.time(timestamp("01 Jan 2025 00:00 +0000"), "Split date (Date mode only)", group = g4)
relDelta = input.float(0.03, "Reliability bin half-width", minval = 0.01, maxval = 0.15, step = 0.01, group = g4,
     tooltip = "Reliability bins are centered on the model's average predicted P(up): 'below' = more than this far under the average, 'above' = more than this far over. Auto-adapts to any symbol's base rate.")
costBps  = input.float(1.0, "Round-trip cost (bps) — for net edge", minval = 0.0, maxval = 50.0, step = 0.5, group = g4,
     tooltip = "Round-trip trading cost (brokerage + STT + slippage) in basis points, used for the NET EDGE read: on high-conviction (|bias| ≥ conviction threshold) out-of-sample bars, the average next-bar return in the model's leaned direction MINUS this cost, in bps/bar. Positive = the directional forecast survives costs. Descriptive (in-sample OOS split, one-bar hold) — not a live backtest.")

// ═════════════════════════ 05 · VISUALS ═══════════════════════════════════════════════════════
g5       = "05 · Visuals"
themeOpt = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g5, tooltip = "Auto reads the chart background and adapts the dashboard for contrast on any theme. Dark / Light force it.")
showTable= input.bool(true, "Show dashboard", group = g5)
tblMode  = input.string("Compact", "Dashboard detail", options = ["Compact", "Pro"], group = g5,
     tooltip = "Compact (default) = forecast + the one calibration line that matters. Pro = the full next-bar ladder, in/out-of-sample lift and the 3-bin reliability curve.")
tblPos   = input.string("Bottom right", "Dashboard position",
     options = ["Bottom right", "Bottom left", "Top right", "Top left"], group = g5)
showOvl  = input.bool(true, "Mark bias turns on price (overlay)", group = g5,
     tooltip = "Draw a small triangle on the price chart when the model's directional bias crosses the conviction threshold up or down.")

// ═════════════════════════ CONSTANTS & HELPERS ════════════════════════════════════════════════
K = 5                                    // alphabet size: 0=X- 1=d 2=c 3=u 4=X+
TOKENS = array.from("X-", "d", "c", "u", "X+")

// theme (background-adaptive): Auto reads chart luma; Dark / Light force it
f_lum(color cc) => na(cc) ? 0.0 : (0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc))
bool darkUI = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140

// Wilson score interval -> [p, lo, hi]
f_wilson(k, n, z) =>
    float p  = na
    float lo = na
    float hi = na
    if n > 0
        ph  = k / n
        den = 1.0 + z * z / n
        ctr = (ph + z * z / (2.0 * n)) / den
        hlf = (z * math.sqrt(ph * (1.0 - ph) / n + z * z / (4.0 * n * n))) / den
        p  := ph
        lo := math.max(0.0, ctr - hlf)
        hi := math.min(1.0, ctr + hlf)
    [p, lo, hi]

// ═════════════════════════ 01 · TOKENISE ══════════════════════════════════════════════════════
bool newSession = ta.change(time("D")) != 0   // hoisted: runs every bar (was behind a short-circuiting `and`)
skipBar = useRTH and timeframe.isintraday and newSession
rng   = high - low
avgR  = ta.rma(rng, atrLen)
xr    = avgR > 0 ? rng / avgR : 1.0
xrPct = ta.percentrank(xr, tokBase) / 100.0
body  = close - open
bodyF = rng > 0 ? math.abs(body) / rng : 0.0
up    = body >= 0
impCut  = adaptTok ? xrPct >= pHi : xr >= expHi
compCut = adaptTok ? xrPct <= pLo : xr <= compLo
isImp = impCut and bodyF >= bodyMin
// 0=X- 1=d 2=c 3=u 4=X+
int tok = isImp and up ? 4 : isImp and not up ? 0 : (compCut or bodyF < bodyMin) ? 2 : up ? 3 : 1
if skipBar
    tok := na

// ═════════════════════════ 02 · MARKOV COUNTS ═════════════════════════════════════════════════
nCtx = order == 2 ? K * K : K
var counts = array.new_float(nCtx * K, 0.0)   // flat [ctx*K + nextToken]
var float totalTrans = 0.0

// contexts (na-safe: default missing tokens to compression=2)
t0 = tok
t0s = nz(tok, 2)
t1 = nz(tok[1], 2)
t2 = nz(tok[2], 2)
ctxPrev = order == 2 ? t2 * K + t1 : t1     // context ending at t-1 -> predicts token t
ctxNow  = order == 2 ? t1 * K + t0s : t0s   // context ending at t   -> predicts token t+1

// read a smoothed distribution over next token from a context row
f_dist(ctx) =>
    d = array.new_float(K, 0.0)
    tot = 0.0
    for j = 0 to K - 1
        c = array.get(counts, ctx * K + j) + alpha
        array.set(d, j, c)
        tot += c
    if tot > 0
        for j = 0 to K - 1
            array.set(d, j, array.get(d, j) / tot)
    d

// samples seen in a context row (excludes smoothing)
f_ctxN(ctx) =>
    s = 0.0
    for j = 0 to K - 1
        s += array.get(counts, ctx * K + j)
    s

// ═════════════════════════ PREQUENTIAL STEP (confirmed bars only) ══════════════════════════════
var float surprise    = na
var float predBiasPrev= na          // model's forecast (made at t-1) for THIS bar's direction
var float predUpP     = na          // predicted P(next up-ish) from ctxPrev
scored = false
if barstate.isconfirmed and not na(t0) and bar_index > order + 2
    // 1) predict token t from ctxPrev, using counts BEFORE this transition is added
    pd = f_dist(ctxPrev)
    surprise := -math.log(math.max(array.get(pd, t0), 1e-6))
    predUpP := array.get(pd, 3) + array.get(pd, 4)
    predBiasPrev := predUpP - (array.get(pd, 0) + array.get(pd, 1))
    scored := f_ctxN(ctxPrev) >= minCtxN  // only score predictions from an ESTABLISHED context
    // 2) update counts with the observed transition (ctxPrev -> t0)
    idx = ctxPrev * K + t0
    array.set(counts, idx, array.get(counts, idx) + 1.0)
    totalTrans += 1.0

// ═════════════════════════ 03 · LIVE READ-OUT ═════════════════════════════════════════════════
ld    = f_dist(ctxNow)
pXm   = array.get(ld, 0)
pdn   = array.get(ld, 1)
pc    = array.get(ld, 2)
pu    = array.get(ld, 3)
pXp   = array.get(ld, 4)
liveUp = pu + pXp
liveDn = pXm + pdn
bias  = 100.0 * (liveUp - liveDn)                 // -100..+100
ent   = 0.0
for j = 0 to K - 1
    p = array.get(ld, j)
    if p > 0
        ent -= p * math.log(p)
predict = 100.0 * (1.0 - ent / math.log(K))        // 0..100 predictability
ctxNnow = f_ctxN(ctxNow)
thin    = ctxNnow < minCtxN
surpRank= nz(ta.percentrank(nz(surprise), surpLen)) / 100.0
surpHigh= not na(surprise) and surpRank > 0.90     // grammar break flag

// ═════════════════════════ 04 · HARNESS (walk-forward, prequential) ════════════════════════════
splitIdx = last_bar_index * (1.0 - wfFrac)
isOOS = wfMode == "Date" ? (time >= wfSplit) : (bar_index >= splitIdx)

outUp   = not na(t0) and t0 >= 3                    // observed: next bar up-ish
leanUp  = not na(predBiasPrev) and predBiasPrev > 0 // model leaned up (sign, no magnitude threshold)

var int cAllI = 0
var int cUpI  = 0        // base-rate numerator (up-ish outcomes), in-sample
var int cCIu  = 0        // up-lean predictions, in-sample
var int cCIuH = 0        // up-lean that were up-ish, in-sample
var int cAllO = 0
var int cUpO  = 0
var int cCOu  = 0
var int cCOuH = 0
// reliability curve: bin OOS predictions by predicted P(up), CENTERED on the model's own running
// average prediction (auto-adapts to any symbol's base rate) -> realized up-rate per bin
var relN  = array.new_float(3, 0.0)
var relUp = array.new_float(3, 0.0)
var float sumPred = 0.0
var float cntPred = 0.0
var float retSum = 0.0   // Σ net-of-cost directional return (bps) on high-conviction OOS bars
var int   retN   = 0     // count of those bars
predMean = cntPred > 200 ? sumPred / cntPred : 0.25            // running mean of predicted P(up)
relB = na(predUpP) ? 1 : predUpP < predMean - relDelta ? 0 : predUpP > predMean + relDelta ? 2 : 1
if scored
    sumPred += nz(predUpP)
    cntPred += 1
    if isOOS
        cAllO += 1
        cUpO  += outUp ? 1 : 0
        if leanUp
            cCOu  += 1
            cCOuH += outUp ? 1 : 0
        array.set(relN,  relB, array.get(relN, relB) + 1.0)
        array.set(relUp, relB, array.get(relUp, relB) + (outUp ? 1.0 : 0.0))
        // net-of-cost directional return on high-conviction bars — does the forecast survive costs?
        // the lean was knowable at the prior close; realise the return on this bar (non-repainting).
        if not na(predBiasPrev) and math.abs(predBiasPrev) >= biasThr and not na(close[1]) and close[1] != 0
            float ret1 = (close - close[1]) / close[1] * 10000.0
            retSum += (predBiasPrev > 0 ? ret1 : -ret1) - costBps
            retN += 1
    else
        cAllI += 1
        cUpI  += outUp ? 1 : 0
        if leanUp
            cCIu  += 1
            cCIuH += outUp ? 1 : 0

baseP = (cAllI + cAllO) > 0 ? (cUpI + cUpO) / (cAllI + cAllO) : na
[upPi, upLoi, upHii] = f_wilson(cCIuH, cCIu, 1.96)
[upPo, upLoo, upHio] = f_wilson(cCOuH, cCOu, 1.96)
liftI = not na(baseP) and baseP > 0 and not na(upPi) ? upPi / baseP : na
liftO = not na(baseP) and baseP > 0 and not na(upPo) ? upPo / baseP : na
// reliability rates, Wilson CIs, and monotonic spread (top bin up-rate minus bottom bin up-rate)
[relRlo, rLoL, rLoH] = f_wilson(array.get(relUp, 0), array.get(relN, 0), 1.96)
[relRmd, rMdL, rMdH] = f_wilson(array.get(relUp, 1), array.get(relN, 1), 1.96)
[relRhi, rHiL, rHiH] = f_wilson(array.get(relUp, 2), array.get(relN, 2), 1.96)
relSpread = not na(relRlo) and not na(relRhi) ? relRhi - relRlo : na
relHiSig  = not na(rHiL) and not na(baseP) and rHiL > baseP   // high bin significantly above base
relLoSig  = not na(rLoH) and not na(baseP) and rLoH < baseP   // low bin significantly below base
relSig    = relHiSig or relLoSig                              // at least one tail separates from base
// cost model: net-of-cost directional return per high-conviction OOS bar (bps). + = survives costs.
float netEdgeBps = retN > 0 ? retSum / retN : na

// ═════════════════════════ VISUALS ════════════════════════════════════════════════════════════
// Colour scheme: GREEN = bullish, YELLOW = neutral, RED = bearish (applied consistently).
cBull = color.new(#26a69a, 0)
cBear = color.new(#ef5350, 0)
cNeut = color.new(#f2b01e, 0)      // amber/yellow = neutral
cUp2  = cBull
cUp1  = color.new(#26a69a, 35)
cDn2  = cBear
cDn1  = color.new(#ef5350, 35)
biasCol = bias >= biasThr * 100 ? cBull : bias <= -biasThr * 100 ? cBear : cNeut

pBias = plot(bias, "Directional bias", color = biasCol, linewidth = 2)
pZero = plot(0, "zero", color = color.new(color.gray, 100), display = display.none, editable = false)
fill(pBias, pZero, color = color.new(biasCol, 82), title = "Bias fill")
hline(0, "Neutral", color = color.new(#f2b01e, 40))
hline(biasThr * 100,  "Conviction+", color = color.new(#26a69a, 55), linestyle = hline.style_dotted)
hline(-biasThr * 100, "Conviction-", color = color.new(#ef5350, 55), linestyle = hline.style_dotted)
tintCol = bias >= biasThr * 100 ? cBull : bias <= -biasThr * 100 ? cBear : na
bgcolor(na(tintCol) ? na : color.new(tintCol, 88), title = "Conviction tint")
plotshape(surpHigh, "Structural surprise", shape.diamond, location.top, cNeut, size = size.tiny)
// bias-turn marks mirrored onto the price chart
bool leanUpTurn = bias >= biasThr * 100 and bias[1] < biasThr * 100
bool leanDnTurn = bias <= -biasThr * 100 and bias[1] > -biasThr * 100
plotshape(showOvl and leanUpTurn, "Lean up (price)",   shape.triangleup,   location.belowbar, cBull, size = size.tiny, force_overlay = true)
plotshape(showOvl and leanDnTurn, "Lean down (price)", shape.triangledown, location.abovebar, cBear, size = size.tiny, force_overlay = true)

// ── Dashboard ──
f_pct(x) => na(x) ? "—" : str.tostring(x * 100.0, "#.#") + "%"
f_bar(p) =>
    n = math.round(p * 10)
    s = ""
    for i = 1 to 10
        s := s + (i <= n ? "█" : "·")
    s
if showTable and barstate.islast and tblMode == "Pro"
    pos = tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom left" ? position.bottom_left : tblPos == "Top right" ? position.top_right : position.top_left
    bg  = darkUI ? color.new(#0e1420, 0) : color.new(#f5f7fa, 0)
    fg  = darkUI ? color.new(#d6dde8, 0) : color.new(#1b2430, 0)
    hd  = darkUI ? color.new(#8aa0bf, 0) : color.new(#5a6b82, 0)
    t = table.new(pos, 2, 20, bgcolor = bg, border_color = color.new(color.gray, 70), border_width = 1, frame_color = color.new(color.gray, 60), frame_width = 1)
    ctxTxt = order == 2 ? (array.get(TOKENS, t1) + "→" + array.get(TOKENS, t0s)) : array.get(TOKENS, t0s)
    table.cell(t, 0, 0, "STRUCTURAL LANGUAGE MODEL", text_color = fg, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 0, thin ? "THIN" : "OK", text_color = color.new(color.white, 0), bgcolor = thin ? cNeut : cBull, text_size = size.small)
    table.cell(t, 0, 1, "Context (last " + str.tostring(order) + ")", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 1, ctxTxt + "   (n=" + str.tostring(ctxNnow, "#") + ")", text_color = fg, text_size = size.small)
    table.cell(t, 0, 2, "Directional bias", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 2, (bias >= 0 ? "+" : "") + str.tostring(bias, "#") + "  " + (bias >= biasThr*100 ? "UP" : bias <= -biasThr*100 ? "DOWN" : "—"), text_color = biasCol, text_size = size.small)
    table.cell(t, 0, 3, "Predictability", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 3, str.tostring(predict, "#") + " / 100", text_color = fg, text_size = size.small)
    table.cell(t, 0, 4, "Structural surprise", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 4, na(surprise) ? "—" : str.tostring(surprise, "#.##") + (surpHigh ? "  BREAK" : ""), text_color = surpHigh ? cNeut : fg, text_size = size.small)
    table.cell(t, 0, 5, "── NEXT-BAR LADDER ──", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 5, "", text_color = hd, text_size = size.small)
    table.cell(t, 0, 6, "X+  up impulse", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 6, f_bar(pXp) + " " + f_pct(pXp), text_color = cUp2, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 0, 7, "u   up", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 7, f_bar(pu) + " " + f_pct(pu), text_color = cUp1, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 0, 8, "c   compression", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 8, f_bar(pc) + " " + f_pct(pc), text_color = cNeut, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 0, 9, "d   down", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 9, f_bar(pdn) + " " + f_pct(pdn), text_color = cDn1, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 0, 10, "X-  down impulse", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 10, f_bar(pXm) + " " + f_pct(pXm), text_color = cDn2, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 0, 11, "── CALIBRATION (walk-fwd) ──", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 11, "learned: " + str.tostring(totalTrans, "#"), text_color = hd, text_size = size.small)
    table.cell(t, 0, 12, "Base rate P(next up)", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 12, f_pct(baseP), text_color = fg, text_size = size.small)
    upTxtI = na(upPi) ? "—" : f_pct(upPi) + " [" + f_pct(upLoi) + "–" + f_pct(upHii) + "]" + (na(liftI) ? "" : " ×" + str.tostring(liftI, "#.##")) + "  n=" + str.tostring(cCIu)
    upTxtO = na(upPo) ? "—" : f_pct(upPo) + " [" + f_pct(upLoo) + "–" + f_pct(upHio) + "]" + (na(liftO) ? "" : " ×" + str.tostring(liftO, "#.##")) + "  n=" + str.tostring(cCOu)
    table.cell(t, 0, 13, "Up-lean IS", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 13, upTxtI, text_color = na(liftI) ? cNeut : (liftI >= 1.05 ? cBull : liftI <= 0.95 ? cBear : cNeut), text_size = size.small)
    table.cell(t, 0, 14, "Up-lean OOS", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 14, upTxtO, text_color = na(liftO) ? cNeut : (liftO >= 1.05 ? cBull : liftO <= 0.95 ? cBear : cNeut), text_size = size.small)
    table.cell(t, 0, 15, "── RELIABILITY OOS ──", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 15, na(relSpread) ? "spread —" : ("spread " + (relSpread >= 0 ? "+" : "") + str.tostring(relSpread * 100, "#.#") + "pp " + (relSig ? "✓sig" : "(ns)")), text_color = na(relSpread) ? cNeut : (relSig and relSpread > 0 ? cBull : relSig and relSpread < 0 ? cBear : cNeut), text_size = size.small)
    loCol = na(relRlo) or na(baseP) ? fg : rLoH < baseP ? cBear : rLoL > baseP ? cBull : cNeut
    mdCol = na(relRmd) or na(baseP) ? fg : rMdH < baseP ? cBear : rMdL > baseP ? cBull : cNeut
    hiCol = na(relRhi) or na(baseP) ? fg : rHiH < baseP ? cBear : rHiL > baseP ? cBull : cNeut
    dpp = str.tostring(relDelta * 100, "#.#")
    table.cell(t, 0, 16, "pred < avg−" + dpp + "pp", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 16, na(relRlo) ? "—" : f_pct(relRlo) + " [" + f_pct(rLoL) + "–" + f_pct(rLoH) + "] n=" + str.tostring(array.get(relN,0), "#"), text_color = loCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 0, 17, "near avg (±" + dpp + "pp)", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 17, na(relRmd) ? "—" : f_pct(relRmd) + " [" + f_pct(rMdL) + "–" + f_pct(rMdH) + "] n=" + str.tostring(array.get(relN,1), "#"), text_color = mdCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 0, 18, "pred > avg+" + dpp + "pp", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 18, na(relRhi) ? "—" : f_pct(relRhi) + " [" + f_pct(rHiL) + "–" + f_pct(rHiH) + "] n=" + str.tostring(array.get(relN,2), "#"), text_color = hiCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 0, 19, "Net edge OOS (bps/bar)", text_color = hd, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 19, retN < 20 ? "warming (" + str.tostring(retN) + ")" : (na(netEdgeBps) ? "—" : (netEdgeBps >= 0 ? "+" : "") + str.tostring(netEdgeBps, "#.#") + " bps  (cost " + str.tostring(costBps, "#.#") + ")"), text_color = retN < 20 ? hd : netEdgeBps > 0 ? cBull : cBear, text_size = size.small, text_halign = text.align_left)

// ── Compact dashboard (default) ──
if showTable and barstate.islast and tblMode == "Compact"
    posC = tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom left" ? position.bottom_left : tblPos == "Top right" ? position.top_right : position.top_left
    bgC  = darkUI ? color.new(#0e1420, 0) : color.new(#f5f7fa, 0)
    fgC  = darkUI ? color.new(#d6dde8, 0) : color.new(#1b2430, 0)
    hdC  = darkUI ? color.new(#8aa0bf, 0) : color.new(#5a6b82, 0)
    tc = table.new(posC, 2, 7, bgcolor = bgC, border_color = color.new(color.gray, 70), border_width = 1, frame_color = color.new(color.gray, 60), frame_width = 1)
    float topP = math.max(pXm, math.max(pdn, math.max(pc, math.max(pu, pXp))))
    string topName = topP == pXp ? "X+ up impulse" : topP == pu ? "u up" : topP == pc ? "c compression" : topP == pdn ? "d down" : "X- down impulse"
    color  topCol  = topP == pXp ? cUp2 : topP == pu ? cUp1 : topP == pc ? cNeut : topP == pdn ? cDn1 : cDn2
    string oosTxt = na(relSpread) ? (na(liftO) ? "warming…" : "lift ×" + str.tostring(liftO, "#.##")) : ("spread " + (relSpread >= 0 ? "+" : "") + str.tostring(relSpread * 100, "#.#") + "pp " + (relSig ? "✓sig" : "(ns)"))
    color  oosCol = na(relSpread) ? (na(liftO) ? hdC : (liftO >= 1.05 ? cBull : liftO <= 0.95 ? cBear : cNeut)) : (relSig and relSpread > 0 ? cBull : relSig and relSpread < 0 ? cBear : cNeut)
    table.cell(tc, 0, 0, "SLM", text_color = fgC, text_size = size.small, text_halign = text.align_left)
    table.cell(tc, 1, 0, thin ? "THIN" : "OK", text_color = color.new(color.white, 0), bgcolor = thin ? cNeut : cBull, text_size = size.small)
    table.cell(tc, 0, 1, "Directional bias", text_color = hdC, text_size = size.small, text_halign = text.align_left)
    table.cell(tc, 1, 1, (bias >= 0 ? "+" : "") + str.tostring(bias, "#") + "  " + (bias >= biasThr*100 ? "UP" : bias <= -biasThr*100 ? "DOWN" : "—"), text_color = biasCol, text_size = size.small)
    table.cell(tc, 0, 2, "Predictability", text_color = hdC, text_size = size.small, text_halign = text.align_left)
    table.cell(tc, 1, 2, str.tostring(predict, "#") + " / 100", text_color = fgC, text_size = size.small)
    table.cell(tc, 0, 3, "Next-bar top", text_color = hdC, text_size = size.small, text_halign = text.align_left)
    table.cell(tc, 1, 3, topName + "  " + f_pct(topP), text_color = topCol, text_size = size.small)
    table.cell(tc, 0, 4, "OOS edge", text_color = hdC, text_size = size.small, text_halign = text.align_left)
    table.cell(tc, 1, 4, oosTxt, text_color = oosCol, text_size = size.small)
    table.cell(tc, 0, 5, "Net edge OOS", text_color = hdC, text_size = size.small, text_halign = text.align_left)
    table.cell(tc, 1, 5, retN < 20 ? "warming" : (na(netEdgeBps) ? "—" : (netEdgeBps >= 0 ? "+" : "") + str.tostring(netEdgeBps, "#.#") + " bps/bar"), text_color = retN < 20 ? hdC : netEdgeBps > 0 ? cBull : cBear, text_size = size.small)
    table.cell(tc, 0, 6, "Note", text_color = hdC, text_size = size.small, text_halign = text.align_left)
    table.cell(tc, 1, 6, "context · learned " + str.tostring(totalTrans, "#"), text_color = fgC, text_size = size.small)

// ═════════════════════════ EXPORTS (Data Window) ══════════════════════════════════════════════
plot(bias,               "EXP_Bias",     color = color.new(color.gray, 100), display = display.data_window)
plot(predict,            "EXP_Predict",  color = color.new(color.gray, 100), display = display.data_window)
plot(surprise,           "EXP_Surprise", color = color.new(color.gray, 100), display = display.data_window)
plot(liveUp,             "EXP_PUp",      color = color.new(color.gray, 100), display = display.data_window)
plot(liftO,              "EXP_LiftOOS",  color = color.new(color.gray, 100), display = display.data_window)
plot(netEdgeBps,         "EXP_NetEdgeBps",color = color.new(color.gray, 100), display = display.data_window)

// ═════════════════════════ ALERTS ═════════════════════════════════════════════════════════════
alertcondition(bias >= biasThr * 100 and bias[1] < biasThr * 100,  "Bias turned UP",   "SLM: model leans UP next bar")
alertcondition(bias <= -biasThr * 100 and bias[1] > -biasThr * 100, "Bias turned DOWN", "SLM: model leans DOWN next bar")
alertcondition(surpHigh and not surpHigh[1], "Structural surprise (grammar break)", "SLM: unusual structural surprise")
````
