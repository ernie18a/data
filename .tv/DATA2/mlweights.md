<!-- tradingview-pine-id: PUB;1c8eb0921c694168b07afcdb52966a49 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_weights

Source: https://www.tradingview.com/script/Rw8f6V5I-ml-weights/

## Description

ml_weights is a dependency-free library for Pine v6 for the one thing most confluence engines never do: change their factor weights. A typical composite sums five or ten factors with hand-set weights that stay fixed forever, whether or not each factor actually predicts anything on your instrument. This library lets those weights learn from the forward test — and, just as importantly, gives you the guardrails to keep the learning honest.

The progression

It follows the standard escalation, each piece usable on its own:

rankWeight — a static, normalized weight from an importance rank (a Best-Worst-Method-style floor). The hand-set baseline the learner starts from.
reliability — an online EMA of "when this factor spoke, did the outcome agree." The simplest learned weight: a live hit rate.
adamWeight — a single factor's weight learned by the Adam optimizer, stepped on each resolved forward-test outcome.
blend — mix a learned weight with the static base by a capped fraction, so an unlucky stretch can't dominate. The anti-overfit control.
normalize / dot — turn a weight set into a bounded weighted composite.
The functions
rankWeight(rank, n) — inverse-rank weight (1 = most important) among n factors, normalized so the set sums to 1.
reliability(resolve, agreed, alpha, floorW) — trust score in [floorW, 1]. Call every bar; set resolve = true on the bar a forward outcome resolves, with agreed = (the factor's direction matched the realized move). alpha ≈ 2/(N+1) sets the memory. A factor that keeps being right drifts toward 1; one that's coin-flip sits near 0.5.
adamWeight(resolve, scoreAtSignal, win, lr, cap, w0) — the factor's weight learned by Adam, bounded to [0, cap]. On each resolved outcome the gradient is g = (win ? +1 : −1) · scoreAtSignal (the factor's score on the signal bar); Adam adapts the step size from the running gradient moments. Deterministic and repaint-free. w0 is the starting weight.
blend(base, learned, frac) — (1−frac)·base + frac·learned. Keep frac modest (0.3–0.5) so the learned component is a nudge, not a takeover.
normalize(w) — normalize a weight array to sum to 1 (negatives floored at 0; all-equal if the sum is 0).
dot(scores, weights) — the weighted composite Σ scoreᵢ·weightᵢ. Pass a normalized weight array for a bounded result.
How to use

Weight three factors by their learned reliability, blended onto a rank floor:

//@version=6
indicator("Example — adaptive confluence", overlay = false)
import Market_Logic_India/ml_weights/1 as wt

// your three factor scores in [-1,+1] and their directional agreement at resolution …
f1 = ta.rsi(close,14)/50 - 1, f2 = ta.cci(close,20)/200, f3 = math.sign(ta.change(close,5))

// forward-test resolution (host-side): set resolve=true when an outcome resolves, and each
// factor's `agreed` = did it point the right way. Here shown schematically:
resolve = barstate.isconfirmed
r1 = wt.reliability(resolve, math.sign(f1[10]) == math.sign(close-close[10]), 0.05, 0.1)
r2 = wt.reliability(resolve, math.sign(f2[10]) == math.sign(close-close[10]), 0.05, 0.1)
r3 = wt.reliability(resolve, math.sign(f3[10]) == math.sign(close-close[10]), 0.05, 0.1)

// blend each learned weight onto a Best-Worst rank floor, normalize, and combine
w = array.from(wt.blend(wt.rankWeight(1,3), r1, 0.4),
               wt.blend(wt.rankWeight(2,3), r2, 0.4),
               wt.blend(wt.rankWeight(3,3), r3, 0.4))
wn = wt.normalize(w)
composite = wt.dot(array.from(f1, f2, f3), wn)
plot(composite, "Adaptive composite")
Notes
Non-repainting: weights advance only on the bars you mark resolve, which you should drive from a forward-test resolution on barstate.isconfirmed. No ta.* inside, so nothing short-circuits; each call keeps its own state, so give every factor its own call site.
Anti-overfit is your job too: keep the blend fraction modest, cap adamWeight, and always render the live forward-test edge next to the weighted vote so a learned weight is never trusted blindly.
Types: simple for the ranks, learning rate, cap and blend fraction; series for the scores and resolution flags; array<float> for normalize / dot.
Gradient-boosting is intentionally omitted — it doesn't fit Pine's execution model; the Adam + reliability path covers the useful, transparent middle.
Concept credits

The Best-Worst-Method for deriving weights from importance ranks is Jafar Rezaei's. The Adam optimizer is Kingma & Ba (2015). Reliability / inverse-variance weighting and forward-testing follow standard quantitative practice. This library is an original, dependency-free Pine v6 packaging of those public techniques; it is not affiliated with, nor endorsed by, any originator.

License

Mozilla Public License 2.0 — as required for TradingView libraries (open source). Free to import and build on.

Library  "ml_weights"

rankWeight(rank, n)
  Parameters:
    rank (simple int)
    n (simple int)

reliability(resolve, agreed, alpha, floorW)
  Parameters:
    resolve (bool)
    agreed (bool)
    alpha (simple float)
    floorW (simple float)

adamWeight(resolve, scoreAtSignal, win, lr, cap, w0)
  Parameters:
    resolve (bool)
    scoreAtSignal (float)
    win (bool)
    lr (simple float)
    cap (simple float)
    w0 (simple float)

blend(base, learned, frac)
  Parameters:
    base (simple float)
    learned (float)
    frac (simple float)

normalize(w)
  Parameters:
    w (array<float>)

dot(scores, weights)
  Parameters:
    scores (array<float>)
    weights (array<float>)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_weights — Adaptive factor weighting  (Wave D foundation library)
// Confluence engines usually SUM their factors with hand-set weights that never change.
// This library lets those weights LEARN from the forward test: factors that keep pointing the
// right way earn more weight, factors that don't lose it — with guardrails so a noisy history
// can't run away with the vote.
//   import Market_Logic_India/ml_weights/1 as wt
//
// THE PROGRESSION  (Best-Worst-Method floor → online Adam SGD → capped blend)
//   • rankWeight  — a static, normalized weight from an importance rank (the BWM-style floor).
//   • reliability — an online EMA of "did this factor agree with the winning outcome" (0..1).
//   • adamWeight  — an Adam-optimizer scalar weight stepped on each resolved forward-test outcome.
//   • blend       — mix a learned weight with the static base by a CAPPED fraction (anti-overfit).
//   • normalize / dot — turn a weight set into a bounded weighted composite.
//
// HONEST SCOPE  These are transparent, bounded online updaters — not a black box. Learned weights
// overfit if trusted blindly, so blend a fixed fraction, cap the influence, and ALWAYS show the
// live forward-test next to the vote. Gradient-boosting is deliberately out of scope for Pine.
//
// NON-REPAINT / STATE  All updates advance only on the bars you mark `resolve` (drive that from a
// forward-test resolution on barstate.isconfirmed). No ta.* inside — nothing to short-circuit;
// each call keeps its own persistent state, so give each factor its own call site.
//
// CONCEPT CREDIT  Best-Worst-Method (Rezaei) for rank weights; Adam (Kingma & Ba) for the online
// step; inverse-reliability weighting and forward-testing follow standard quantitative practice.
// Original, dependency-free Pine v6 packaging.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_weights", overlay = false)

// ── STATIC FLOOR ────────────────────────────────────────────────────────────────
// Best-Worst-Method-style weight from an importance RANK (1 = most important) among n factors.
// Inverse-rank, normalized so the full set sums to 1. The hand-set baseline the learner starts from.
export rankWeight(simple int rank, simple int n) =>
    float num = math.max(0.0, n - rank + 1.0)
    float den = n * (n + 1.0) / 2.0
    den > 0.0 ? num / den : 0.0

// ── ONLINE RELIABILITY ─────────────────────────────────────────────────────────
// EMA of "when this factor spoke, did the outcome agree" → a trust score in [floor, 1]. Call every
// bar; set resolve=true on the bar a forward outcome resolves, with agreed = (the factor's direction
// matched the realized move). alpha ≈ 2/(N+1) memory. The simplest learned weight — a live hit rate.
export reliability(series bool resolve, series bool agreed, simple float alpha, simple float floorW) =>
    var float r = 0.5
    if resolve
        r := r + alpha * ((agreed ? 1.0 : 0.0) - r)
    math.max(floorW, math.min(1.0, r))

// ── ONLINE ADAM WEIGHT ──────────────────────────────────────────────────────────
// A single factor's weight learned by the Adam optimizer, bounded to [0, cap]. On each resolved
// outcome the gradient is g = (win ? +1 : -1) · scoreAtSignal (the factor's score on the signal bar);
// Adam adapts the step from the running moments. Deterministic, no ta.*. w0 = starting weight.
export adamWeight(series bool resolve, series float scoreAtSignal, series bool win, simple float lr, simple float cap, simple float w0) =>
    var float w = w0
    var float m = 0.0
    var float v = 0.0
    var float t = 0.0
    if resolve and not na(scoreAtSignal)
        float g = (win ? 1.0 : -1.0) * scoreAtSignal
        t := t + 1.0
        m := 0.9 * m + 0.1 * g
        v := 0.999 * v + 0.001 * g * g
        float mh = m / (1.0 - math.pow(0.9, t))
        float vh = v / (1.0 - math.pow(0.999, t))
        w := math.max(0.0, math.min(cap, w + lr * mh / (math.sqrt(vh) + 1e-8)))
    w

// ── GUARDRAIL ───────────────────────────────────────────────────────────────────
// Blend a LEARNED weight with the static BASE by a capped fraction: (1−frac)·base + frac·learned.
// Keep frac modest (0.3–0.5) so an unlucky history can't dominate — the anti-overfit control.
export blend(simple float base, series float learned, simple float frac) =>
    float fr = math.max(0.0, math.min(1.0, frac))
    (1.0 - fr) * base + fr * learned

// ── COMBINE ─────────────────────────────────────────────────────────────────────
// Normalize a weight array to sum to 1 (negatives floored at 0; all-equal if the sum is 0).
export normalize(array<float> w) =>
    float s = 0.0
    for x in w
        s += math.max(0.0, x)
    int n = w.size()
    array<float> o = array.new<float>(n, 0.0)
    if s > 0.0
        for i = 0 to n - 1
            array.set(o, i, math.max(0.0, array.get(w, i)) / s)
    else if n > 0
        float eq = 1.0 / n
        for i = 0 to n - 1
            array.set(o, i, eq)
    o

// Weighted composite score: Σ score_i · weight_i over the shorter of the two arrays. Pass a
// normalized weight array for a bounded result.
export dot(array<float> scores, array<float> weights) =>
    float s = 0.0
    int n = math.min(scores.size(), weights.size())
    if n > 0
        for i = 0 to n - 1
            s += array.get(scores, i) * array.get(weights, i)
    s

// ── demo output (library preview only) ──
// The online reliability of "up-close follows through to the next bar" — a live learned trust in [0.1,1].
plot(reliability(barstate.isconfirmed, close > close[1], 0.05, 0.1), "Reliability EMA (demo)", color = color.new(#6f9bd8, 0))
````
