<!-- tradingview-pine-id: PUB;9d9315166b064e6ea576cd8e417e2dbb -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_calib

Source: https://www.tradingview.com/script/XyQekeKp-ml-calib/

## Description

ml_calib is a dependency-free library for Pine v6 that supplies two things every signal study needs but usually re-implements ad-hoc: a regime lens to decide when a signal should be trusted, and an audited confidence number to say how well it has actually worked. Importing one shared implementation means "regime-filtered" and "proven edge" mean the same thing across every script you build.

It splits into a regime half and a calibration half. Each function takes a series source and simple parameters, so it drops into any study.

Regime lens
efficiencyRatio(src, len) — Kaufman efficiency ratio (0..1): |net move| ÷ summed |bar move|. High = trending, low = choppy / mean-reverting. The shared trend-vs-range read.
regimeState(src, len, thr) — the efficiency ratio collapsed to a state: +1 trending, −1 ranging, 0 warming.
regimeGate(sig, src, len, thr, mode) — filters a boolean directional signal by the regime. mode: "Off" (pass through), "Favor trending" (fire only when trending), "Favor reverting" (fire only when ranging). Use this one gate everywhere so a "regime-filtered" signal is defined identically across the suite — mean-reversion tools favour reverting, breakout tools favour trending.
turbulence(ret, len) — squared standardized return: a simple financial-turbulence proxy. High = unusual, fat-tailed conditions (widen stops, distrust mean reversion).
turbulencePct(ret, len, rankLen) — that turbulence percentile-ranked against its own history, so "how unusual is now" self-calibrates per symbol and timeframe.
Calibration (audited confidence)

The forward-test event queue lives in your script (it logs each signal and resolves it at your horizon into wins / total). These functions turn those counts into an honest, comparable confidence:

wilsonLo(wins, n, z) — Wilson score-interval LOWER bound (%). The honest floor on a hit rate: the worst it plausibly is given this many observations. On a modest sample it sits well below the point estimate — which is the point.
wilsonHalf(wins, n, z) — the ± half-width of that interval, for a "62% ±9" style readout.
hitRate(wins, n) — the point hit rate (%).
edge(hitPct, basePct) — hit rate minus the unconditional base rate (percentage points).
edgeLB(wins, n, basePct, z) — the Wilson-floored hit rate minus the base rate. Only a POSITIVE value is evidence the signal beats the base rate; a positive point estimate alone is not.
edgeProven(wins, n, basePct, minN, z) — a boolean gate: the edge lower bound clears zero on an adequate sample. Use it to colour a signal "proven" only when it has actually earned it.
stars(wins, n, basePct, minN, z) — a "— / ★ / ★★ / ★★★" rating comparing the Wilson-floored hit rate to the base rate, for a dashboard.

Pass z = 1.96 for a 95% interval, or a larger z (e.g. 2.24) for a stricter survival test.

How to use

Gate a signal by regime and score it with an honest confidence:

//@version=6
indicator("Example — regime-gated, calibrated", overlay = false)
import Market_Logic_India/ml_calib/1 as cal

len  = input.int(20,  "Regime window")
thr  = input.float(0.40, "Trend threshold")
mode = input.string("Favor reverting", "Regime gate", options = ["Off","Favor trending","Favor reverting"])

rawLong = ta.crossover(ta.rsi(close, 3), 10)         // your raw signal
long    = cal.regimeGate(rawLong, close, len, thr, mode)   // shared regime filter

// forward-test bookkeeping (host-side): resolve `long` at your horizon into wins/total …
var float wins = 0.0, var float n = 0.0, var float baseUp = 50.0
// … your resolution logic increments wins / n / baseUp …

hit  = cal.hitRate(wins, n)
lb   = cal.edgeLB(wins, n, baseUp, 1.96)
ok   = cal.edgeProven(wins, n, baseUp, 20, 1.96)
plotshape(long, "Long", shape.triangleup, location.bottom, color.new(ok ? color.green : color.gray, 0))
Notes
Non-repainting: the estimators use only closed historical bars. The confidence stats are pure functions of the counts you pass — resolve your forward test on barstate.isconfirmed so those counts never repaint.
Types: pass simple int windows, simple float thresholds and z, and a simple string gate mode.
The turbulence proxy is a standardized-return measure, not a full covariance turbulence — it needs no matrix and works on a single series; treat it as a fast "unusualness" flag.
Concept credits

The efficiency ratio is Perry Kaufman's. The Wilson score interval is Edwin B. Wilson's. Forward-testing / triple-barrier-style outcome labelling and the base-rate edge framing follow standard practice in quantitative finance (e.g. López de Prado). Financial turbulence as a standardized-distance measure follows Kritzman & Li; the single-series proxy here is a simplification. This library is an original Pine v6 packaging of those public techniques; it is not affiliated with, nor endorsed by, any originator.

License

Mozilla Public License 2.0 — as required for TradingView libraries (open source). Free to import and build on.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_calib — Regime-gate & calibration toolkit  (Wave C foundation library)
// One shared regime lens (Kaufman efficiency ratio + turbulence) and one audited
// confidence number (Wilson lower-bound on a forward-tested hit rate, edge vs base,
// star rating). Import once so every signal engine gates and scores the same way:
//   import Market_Logic_India/ml_calib/2 as cal
// The forward-test event queue is HOST-side (each script logs its own signals and
// resolves them at its horizon); this library standardizes the STATS on those counts
// and the REGIME classification, so numbers are comparable across the suite.
//
// v2 (Batch-1 "Honest Measurement" foundation) ADDS a validation block — all additive,
// nothing above changed, so existing importers keep working:
//   • Bucketed, Wilson-bounded CONDITIONAL hit-rate  (edge given context)
//   • Walk-forward phase engine  (In-Sample / Out-of-Sample / Forward + degradation)
//   • Path-honest intrabar fill sequencing  (which of stop/target hit FIRST)
//   • PendingEval deferred-outcome queue + last-N rolling win-rate ring
//   • Runs-test Z (win/loss clustering) + windowed Sharpe
// State lives HOST-side (you own the arrays); the library owns the math, so numbers
// stay comparable across every script that imports it.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_calib", overlay = false)

// ── REGIME LENS ───────────────────────────────────────────────────────────────
// Kaufman efficiency ratio (0..1): |net move| / summed |bar move|. High = trending,
// low = choppy/mean-reverting. The shared trend/range read for the whole suite.
export efficiencyRatio(series float src, simple int len) =>
    float net  = math.abs(src - src[len])
    float path = math.sum(math.abs(src - src[1]), len)
    path > 0.0 ? net / path : 0.0

// Regime state from the efficiency ratio: +1 trending, -1 ranging, 0 warming (na ER).
export regimeState(series float src, simple int len, simple float thr) =>
    float er = efficiencyRatio(src, len)
    na(er) ? 0 : er >= thr ? 1 : -1

// Regime GATE for a directional signal. mode: "Off" | "Favor trending" | "Favor reverting".
// Returns the signal unchanged (Off), or only when the regime agrees. Use one shared gate
// so "regime-filtered" means the same thing on every engine.
export regimeGate(series bool sig, series float src, simple int len, simple float thr, simple string mode) =>
    float er = efficiencyRatio(src, len)
    bool trending = not na(er) and er >= thr
    mode == "Off" ? sig : mode == "Favor trending" ? (sig and trending) : mode == "Favor reverting" ? (sig and not trending) : sig

// Turbulence: squared standardized return over a window — a simple financial-turbulence
// proxy. High = unusual / fat-tailed conditions (widen stops, distrust mean-reversion).
export turbulence(series float ret, simple int len) =>
    float m  = ta.sma(ret, len)
    float sd = ta.stdev(ret, len)
    sd > 0.0 ? math.pow((ret - m) / sd, 2.0) : 0.0

// Turbulence percentile (0..100) — self-calibrating "how unusual is now" against its own history.
export turbulencePct(series float ret, simple int len, simple int rankLen) =>
    ta.percentrank(turbulence(ret, len), rankLen)

// ── CALIBRATION (audited confidence on a forward-tested hit rate) ───────────────
// Wilson score-interval LOWER bound (%) for `wins` out of `n`, at critical value z
// (1.96 = 95%). The honest floor on a hit rate: what is the WORST it plausibly is,
// given this many observations. A modest sample pulls this well below the point estimate.
export wilsonLo(series float wins, series float n, simple float z) =>
    float outv = na
    if n > 0.0
        float p   = wins / n
        float ctr = p + z * z / (2.0 * n)
        float hlf = z * math.sqrt((p * (1.0 - p) + z * z / (4.0 * n)) / n)
        outv := math.max(0.0, (ctr - hlf) / (1.0 + z * z / n)) * 100.0
    outv

// Wilson interval HALF-WIDTH (%) — the ± uncertainty band around the hit rate.
export wilsonHalf(series float wins, series float n, simple float z) =>
    float outv = na
    if n > 0.0
        float p   = wins / n
        float hlf = z * math.sqrt((p * (1.0 - p) + z * z / (4.0 * n)) / n) / (1.0 + z * z / n)
        outv := hlf * 100.0
    outv

// Point hit rate (%).
export hitRate(series float wins, series float n) =>
    n > 0.0 ? wins / n * 100.0 : na

// EDGE (percentage points) = conditional hit rate − unconditional base rate.
export edge(series float hitPct, series float basePct) =>
    (not na(hitPct) and not na(basePct)) ? hitPct - basePct : na

// EDGE lower bound = Wilson-floored hit rate − base rate. Only a POSITIVE value is evidence
// the signal clears the base rate; a positive point estimate alone is not.
export edgeLB(series float wins, series float n, series float basePct, simple float z) =>
    float lo = wilsonLo(wins, n, z)
    (not na(lo) and not na(basePct)) ? lo - basePct : na

// PROVEN gate: the edge lower bound clears zero on an adequate sample.
export edgeProven(series float wins, series float n, series float basePct, simple int minN, simple float z) =>
    float lb = edgeLB(wins, n, basePct, z)
    not na(lb) and lb > 0.0 and n >= minN

// Star rating for a dashboard: compares the Wilson-floored hit rate to the base rate.
// "—" below sample; then ★ / ★★ / ★★★ as the floor clears base by widening margins.
export stars(series float wins, series float n, series float basePct, simple int minN, simple float z) =>
    float lo = wilsonLo(wins, n, z)
    string s = "—"
    if n >= minN and not na(lo) and not na(basePct)
        s := lo > basePct + 5.0 ? "★★★" : lo > basePct ? "★★" : lo > basePct - 5.0 ? "★" : "—"
    s

// ══════════════════════════════════════════════════════════════════════════════
// v2 ▸ VALIDATION BLOCK — the "measure, don't assume" foundation
// State is HOST-side: you create the arrays (var float[] / var bool[] / var int[]),
// pass them in, and the library mutates/reads them. Same arrays → comparable numbers.
// ══════════════════════════════════════════════════════════════════════════════

// ── 1) BUCKETED CONDITIONAL HIT-RATE ────────────────────────────────────────────
// The edge is rarely one number — it depends on context (VIX tier, time-of-day, RSI
// decile, volume-Z). Bucket the context, learn each bucket's win rate live, and read
// it Wilson-floored so a thin bucket can't masquerade as a sure thing.
//
// Host owns two aligned arrays sized to nBuckets:
//   var float[] bWins = array.new_float(K, 0.0)
//   var float[] bN    = array.new_float(K, 0.0)

// Map a context value into a bucket index [0 .. nBuckets-1] by linear binning of [lo,hi].
// Returns na if value is na. Use for deciles (nBuckets=10), VIX tiers, ToD slots, etc.
export bucketOf(series float value, simple float lo, simple float hi, simple int nBuckets) =>
    int idx = na
    if not na(value) and hi > lo and nBuckets > 0
        float f = (value - lo) / (hi - lo)
        idx := math.max(0, math.min(nBuckets - 1, int(math.floor(f * nBuckets))))
    idx

// Record one resolved outcome into its bucket. Call on the RESOLUTION bar (not the
// signal bar) with the bucket the signal was in and whether it won.
export bucketRecord(array<float> wins, array<float> n, series int bucketIdx, series bool win) =>
    if not na(bucketIdx) and bucketIdx >= 0 and bucketIdx < n.size()
        n.set(bucketIdx, n.get(bucketIdx) + 1.0)
        if win
            wins.set(bucketIdx, wins.get(bucketIdx) + 1.0)

// Wilson-floored hit rate (%) for the CURRENT context bucket — the honest "what's my
// edge given where we are now."
export bucketWilsonLo(array<float> wins, array<float> n, series int bucketIdx, simple float z) =>
    (not na(bucketIdx) and bucketIdx >= 0 and bucketIdx < n.size()) ? wilsonLo(wins.get(bucketIdx), n.get(bucketIdx), z) : na

// Point hit rate (%) for a bucket.
export bucketHitRate(array<float> wins, array<float> n, series int bucketIdx) =>
    (not na(bucketIdx) and bucketIdx >= 0 and bucketIdx < n.size()) ? hitRate(wins.get(bucketIdx), n.get(bucketIdx)) : na

// Sample size held in a bucket (for showing N / confidence alongside the rate).
export bucketN(array<float> n, series int bucketIdx) =>
    (not na(bucketIdx) and bucketIdx >= 0 and bucketIdx < n.size()) ? n.get(bucketIdx) : na

// ── 2) WALK-FORWARD PHASE ENGINE ────────────────────────────────────────────────
// Split history by TIME into In-Sample (optimize here) / Out-of-Sample (holdout) /
// Forward (most recent, never touched). Report the IS→OOS degradation — the single
// honest "did the edge survive out of sample" number. Host supplies the two split
// timestamps (input.time). Phase codes: 1 = IS, 2 = OOS, 3 = Forward.
export phaseOf(series int t, simple int isEndTime, simple int oosEndTime) =>
    t <= isEndTime ? 1 : t <= oosEndTime ? 2 : 3

// Degradation (percentage points) = In-Sample hit − Out-of-Sample hit. Large positive =
// overfit (looked good in-sample, faded out of sample). Near zero = the edge travels.
export degradation(series float hitIS, series float hitOOS) =>
    (not na(hitIS) and not na(hitOOS)) ? hitIS - hitOOS : na

// Tip: reuse the bucket arrays with nBuckets = 3 and bucketIdx = phaseOf(...) - 1 to get
// per-phase win/N for free, then feed bucketHitRate(IS) & bucketHitRate(OOS) to degradation().

// ── 3) PATH-HONEST INTRABAR FILL SEQUENCING ─────────────────────────────────────
// When BOTH stop and target sit inside one chart bar, assuming target-first inflates
// every win rate. Walk the bar's lower-timeframe candles and return which was actually
// touched FIRST. Host fetches the LTF arrays at GLOBAL scope and passes them in, e.g.:
//   [lh, ll] = request.security_lower_tf(syminfo.tickerid, "1", [high, low])
// Returns  1 = target first · -1 = stop first · 0 = neither hit this bar.
// If an LTF candle straddles both levels (can't resolve finer), `pessimistic=true`
// counts it as the stop (the anti-inflation default); false counts it as the target.
export firstHit(array<float> ltfHigh, array<float> ltfLow, series float stop, series float target, series bool isLong, simple bool pessimistic) =>
    int outv = 0
    if not na(ltfHigh) and ltfHigh.size() > 0 and not na(ltfLow) and ltfLow.size() == ltfHigh.size()
        for i = 0 to ltfHigh.size() - 1
            float h = ltfHigh.get(i)
            float l = ltfLow.get(i)
            bool hitT = isLong ? h >= target : l <= target
            bool hitS = isLong ? l <= stop   : h >= stop
            if hitT and hitS
                outv := pessimistic ? -1 : 1
                break
            else if hitT
                outv := 1
                break
            else if hitS
                outv := -1
                break
    outv

// ── 4) PENDING-EVAL QUEUE + ROLLING WIN-RATE RING ───────────────────────────────
// Honest live scoring = decide the outcome LATER, at the signal's horizon, not on the
// signal bar. Arm each signal; resolve it N bars on; push the result into a last-cap
// ring for a rolling win rate (Wilson-floored). Host owns:
//   var int[]   dueIdx  = array.new_int()
//   var float[] entryPx = array.new_float()
//   var int[]   dirSign = array.new_int()      // +1 long-thesis, -1 short-thesis
//   var bool[]  ring    = array.new_bool()

// Arm a signal for evaluation `horizon` bars from now.
export pendingArm(array<int> dueIdx, array<float> entryPx, array<int> dirSign, simple int horizon, series float entry, series int dir) =>
    dueIdx.push(bar_index + horizon)
    entryPx.push(entry)
    dirSign.push(dir)

// Resolve everything now due (dueIdx <= bar_index): a "win" is price having moved in the
// thesis direction vs the armed entry. Resolved outcomes are pushed into `ring` (trimmed
// to `cap`) and removed from the queue. Returns [resolvedCount, winsCount] for this bar.
export pendingResolve(array<int> dueIdx, array<float> entryPx, array<int> dirSign, array<bool> ring, simple int cap, series float priceNow) =>
    int res  = 0
    int wins = 0
    if dueIdx.size() > 0
        for i = dueIdx.size() - 1 to 0
            if dueIdx.get(i) <= bar_index
                int d = dirSign.get(i)
                bool w = (priceNow - entryPx.get(i)) * d > 0.0
                ring.push(w)
                if ring.size() > cap
                    ring.shift()
                res  += 1
                wins += w ? 1 : 0
                dueIdx.remove(i)
                entryPx.remove(i)
                dirSign.remove(i)
    [res, wins]

// Rolling win rate (%) over the ring (e.g. last 100 resolved trades).
export ringRate(array<bool> ring) =>
    float outv = na
    int sz = ring.size()
    if sz > 0
        int w = 0
        for i = 0 to sz - 1
            if ring.get(i)
                w += 1
        outv := w / float(sz) * 100.0
    outv

// Wilson-floored rolling win rate (%) — the honest floor on the recent record.
export ringWilsonLo(array<bool> ring, simple float z) =>
    float outv = na
    int sz = ring.size()
    if sz > 0
        int w = 0
        for i = 0 to sz - 1
            if ring.get(i)
                w += 1
        outv := wilsonLo(w, sz, z)
    outv

// Push a resolved outcome into a ring by hand (when you resolve outcomes yourself).
export ringPush(array<bool> ring, series bool win, simple int cap) =>
    ring.push(win)
    if ring.size() > cap
        ring.shift()

// ── 5) SERIAL-DEPENDENCE & RISK-ADJUSTED DIAGNOSTICS ────────────────────────────
// Wald–Wolfowitz runs-test Z over a win/loss ring. |Z| small ≈ independent trades;
// Z < -2 = wins/losses CLUSTER (streaky — one edge, not many); Z > 2 = alternating.
// A clustered record means fewer effective independent bets than the raw count implies.
export runsTestZ(array<bool> seq) =>
    float z = na
    int nn = seq.size()
    if nn >= 2
        int n1   = 0
        int runs = 1
        for i = 0 to nn - 1
            if seq.get(i)
                n1 += 1
            if i > 0 and seq.get(i) != seq.get(i - 1)
                runs += 1
        int n2 = nn - n1
        if n1 > 0 and n2 > 0
            float mu = 2.0 * n1 * n2 / nn + 1.0
            float vr = 2.0 * n1 * n2 * (2.0 * n1 * n2 - nn) / (float(nn) * nn * (nn - 1))
            z := vr > 0.0 ? (runs - mu) / math.sqrt(vr) : na
    z

// Windowed Sharpe on a per-bar return stream. `annualize` = sqrt(bars-per-year) to
// annualize (e.g. ~sqrt(98280) for NIFTY 1-min RTH), or 1.0 for the raw per-bar ratio.
export sharpeWin(series float ret, simple int len, simple float annualize) =>
    float mu = ta.sma(ret, len)
    float sd = ta.stdev(ret, len)
    sd > 0.0 ? mu / sd * annualize : na

// ── demo output (library preview only) ──
plot(efficiencyRatio(close, 20), "Efficiency ratio (demo)", color = color.new(#6f9bd8, 0))
````
