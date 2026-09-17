<!-- tradingview-pine-id: PUB;3641f494fdee416b8d830a1f163c1dd1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_knn

Source: https://www.tradingview.com/script/guYsgptu-ml-knn/

## Description

ml_knn is a dependency-free library for Pine v6 that replaces a hand-set rule with a data-driven analog forecast. Instead of "buy when RSI < 30," it asks the empirical question: the last time conditions looked like they do right now, what happened next? It keeps a rolling library of past feature-vectors with their realized outcomes and predicts the current bar from a distance-weighted vote of its k nearest neighbours.

How it works

You own two persistent arrays — a flattened feature store (N × dim) and a labels array (N). Each time a forward outcome resolves, you push the signal bar's feature vector and its realized label (a forward return, or +1/−1, whatever you're forecasting). Each bar, you predict your current feature vector: the library measures Euclidean distance to every stored analog, takes the k nearest, and returns their distance-weighted mean label.

The functions
dist2(a, b) — squared Euclidean distance between two equal-length vectors. The similarity primitive.
push(feats, labels, vec, label, dim, maxN) — append one analog: the dim values of vec onto the flattened feats store and label onto labels, ring-trimmed to the newest maxN. Call on a resolved outcome with the signal bar's features and its realized label. Returns the library size.
predict(feats, labels, query, dim, k) — the distance-weighted k-NN prediction for query: the k nearest analogs, each weighted 1/(dist²+ε), return their weighted-mean label. na until the store has samples.
predictConf(feats, labels, query, dim, k) — as predict, and also a confidence in [0,1] = how strongly the k neighbours agree on the label's sign (1 = unanimous, 0.5 = split), plus the effective neighbour count. Returns [prediction, confidence, neighbours], so a mixed neighbourhood reads as low conviction.
How to use

Log an analog on each resolution, and read the forecast each bar:

//@version=6
indicator("Example — analog forecast", overlay = false)
import Market_Logic_India/ml_knn/1 as knn

var feats  = array.new<float>()
var labels = array.new<float>()

// standardized features (use a robust z so scales are comparable) …
f1 = (close - ta.sma(close,20)) / ta.stdev(close,20)
f2 = ta.rsi(close,14)/50 - 1
query = array.from(f1, f2)

// when a 10-bar outcome resolves, push the features FROM 10 bars ago with the realized label:
if barstate.isconfirmed and not na(close[10])
    knn.push(feats, labels, array.from(f1[10], f2[10]), math.sign(close - close[10]), 2, 300)

[pred, conf, nn] = knn.predictConf(feats, labels, query, 2, 12)
plot(pred, "Analog forecast", color = conf > 0.7 ? color.teal : color.gray)
Notes
Standardize your features. Euclidean distance is scale-sensitive, so z-score each feature first (e.g. a robust z from ml_robuststats) — otherwise a large-scale feature dominates the neighbour search and the analogs are meaningless.
Non-repainting: pure functions of the arrays you pass; the library only grows forward as you push on resolved outcomes (barstate.isconfirmed). Never push an unresolved label.
Cost: predict is O(N·dim + k·N) per call. Keep maxN modest (a few hundred) and the feature count small; that's plenty of history for a stable neighbourhood and stays light.
Types: array<float> for the store, labels, vector and query; simple int for dim, k, maxN; series float for the label you push.
Concept credits

k-nearest-neighbour / analog forecasting is a classic non-parametric method; distance-weighted kNN and neighbour-agreement confidence follow standard practice. This library is an original, dependency-free Pine v6 packaging of those public techniques; it is not affiliated with, nor endorsed by, any originator.

License

Mozilla Public License 2.0 — as required for TradingView libraries (open source). Free to import and build on.

Library  "ml_knn"

dist2(a, b)
  Parameters:
    a (array<float>)
    b (array<float>)

push(feats, labels, vec, label, dim, maxN)
  Parameters:
    feats (array<float>)
    labels (array<float>)
    vec (array<float>)
    label (float)
    dim (simple int)
    maxN (simple int)

predict(feats, labels, query, dim, k)
  Parameters:
    feats (array<float>)
    labels (array<float>)
    query (array<float>)
    dim (simple int)
    k (simple int)

predictConf(feats, labels, query, dim, k)
  Parameters:
    feats (array<float>)
    labels (array<float>)
    query (array<float>)
    dim (simple int)
    k (simple int)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_knn — Pattern-analog (k-nearest-neighbour) prediction  (Wave D foundation library)
// Instead of a fixed rule, ask: "the last time the tape LOOKED like it does now, what happened
// next?" This library keeps a rolling library of past feature-vectors with their realized
// outcomes, and predicts the current bar by a distance-weighted vote of its nearest analogs.
//   import Market_Logic_India/ml_knn/1 as knn
//
// HOW IT WORKS  You own two persistent arrays — a FLATTENED feature store (N×dim) and a LABELS
// array (N). Each time a forward outcome resolves, `push` the SIGNAL bar's feature vector and its
// realized label (e.g. the forward return, or +1/−1). Each bar, `predict` your current feature
// vector: it measures Euclidean distance to every stored analog, takes the k nearest, and returns
// their distance-weighted mean label — a data-driven expectation, not a hand-set threshold.
//
// USE STANDARDIZED FEATURES  Distance is scale-sensitive, so standardize each feature first (e.g.
// a robust z from ml_robuststats) — otherwise a large-scale feature dominates the neighbour search.
//
// NON-REPAINT / COST  Pure functions of the arrays you pass; state only grows forward as you push
// on resolved (barstate.isconfirmed) outcomes. `predict` is O(N·dim + k·N) per call — keep the
// library size (maxN) modest (a few hundred) and it stays light.
//
// CONCEPT CREDIT  k-nearest-neighbour / analog forecasting is a classic non-parametric method;
// distance-weighted kNN follows standard practice. Original, dependency-free Pine v6 packaging.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_knn", overlay = false)

// ── DISTANCE ────────────────────────────────────────────────────────────────────
// Squared Euclidean distance between two equal-length vectors (over the shorter length).
export dist2(array<float> a, array<float> b) =>
    float s = 0.0
    int n = math.min(a.size(), b.size())
    if n > 0
        for i = 0 to n - 1
            float d = array.get(a, i) - array.get(b, i)
            s += d * d
    s

// ── STORE ───────────────────────────────────────────────────────────────────────
// Append one analog: push the `dim` values of `vec` onto the flattened `feats` store and `label`
// onto `labels`, then ring-trim both to the newest `maxN` samples. Call on a RESOLVED outcome with
// the SIGNAL bar's feature vector and its realized label. Returns the library size after the push.
export push(array<float> feats, array<float> labels, array<float> vec, series float label, simple int dim, simple int maxN) =>
    if vec.size() >= dim and not na(label)
        for j = 0 to dim - 1
            array.push(feats, array.get(vec, j))
        array.push(labels, label)
        while labels.size() > maxN
            labels.shift()
            for j = 0 to dim - 1
                feats.shift()
    labels.size()

// ── PREDICT ─────────────────────────────────────────────────────────────────────
// Distance-weighted k-NN prediction for `query` (a dim-vector) against the stored analogs:
// the k nearest by Euclidean distance, each weighted 1/(dist²+ε), return their weighted-mean label.
// na until the store has samples. Feed standardized features so distances are comparable.
export predict(array<float> feats, array<float> labels, array<float> query, simple int dim, simple int k) =>
    int n = labels.size()
    float result = na
    if n > 0 and query.size() >= dim
        array<float> d = array.new<float>(n, 0.0)
        for i = 0 to n - 1
            float s = 0.0
            for j = 0 to dim - 1
                float diff = array.get(feats, i * dim + j) - array.get(query, j)
                s += diff * diff
            array.set(d, i, s)
        array<bool> used = array.new<bool>(n, false)
        float wsum = 0.0
        float lsum = 0.0
        int kk = math.min(k, n)
        for pass = 0 to kk - 1
            int bi = -1
            float bd = 1e30
            for i = 0 to n - 1
                if not array.get(used, i) and array.get(d, i) < bd
                    bd := array.get(d, i)
                    bi := i
            if bi >= 0
                array.set(used, bi, true)
                float w = 1.0 / (bd + 1e-9)
                wsum += w
                lsum += w * array.get(labels, bi)
        result := wsum > 0.0 ? lsum / wsum : na
    result

// ── PREDICT + CONFIDENCE ────────────────────────────────────────────────────────
// As predict, but also returns a confidence in [0,1] = the AGREEMENT of the k neighbours on the
// sign of the label (1 = all agree, 0.5 = split) — so a mixed neighbourhood reads as low conviction.
// Returns [prediction, confidence, effectiveNeighbours].
export predictConf(array<float> feats, array<float> labels, array<float> query, simple int dim, simple int k) =>
    int n = labels.size()
    float pred = na
    float conf = na
    int used_k = 0
    if n > 0 and query.size() >= dim
        array<float> d = array.new<float>(n, 0.0)
        for i = 0 to n - 1
            float s = 0.0
            for j = 0 to dim - 1
                float diff = array.get(feats, i * dim + j) - array.get(query, j)
                s += diff * diff
            array.set(d, i, s)
        array<bool> used = array.new<bool>(n, false)
        float wsum = 0.0
        float lsum = 0.0
        int pos = 0
        int neg = 0
        int kk = math.min(k, n)
        for pass = 0 to kk - 1
            int bi = -1
            float bd = 1e30
            for i = 0 to n - 1
                if not array.get(used, i) and array.get(d, i) < bd
                    bd := array.get(d, i)
                    bi := i
            if bi >= 0
                array.set(used, bi, true)
                float w = 1.0 / (bd + 1e-9)
                wsum += w
                float lb = array.get(labels, bi)
                lsum += w * lb
                pos += lb > 0.0 ? 1 : 0
                neg += lb < 0.0 ? 1 : 0
                used_k += 1
        pred := wsum > 0.0 ? lsum / wsum : na
        conf := used_k > 0 ? math.max(pos, neg) / float(used_k) : na
    [pred, conf, used_k]

// ── demo output (library preview only) ──
// A self-contained tiny analog forecast: features = [1-bar return, bar range]; label = next return
// sign. Predicts the current bar from its nearest ~8 analogs over a rolling 200-sample library.
var array<float> _f = array.new<float>()
var array<float> _l = array.new<float>()
var array<float> _pend = array.new<float>()   // pending feature vector awaiting its next-bar label
if barstate.isconfirmed
    if _pend.size() >= 2
        push(_f, _l, _pend, math.sign(close - close[1]), 2, 200)
    _pend := array.from(close[1] - close[2], high[1] - low[1])
plot(predict(_f, _l, array.from(close - close[1], high - low), 2, 8), "kNN analog forecast (demo)", color = color.new(#6f9bd8, 0))
````
