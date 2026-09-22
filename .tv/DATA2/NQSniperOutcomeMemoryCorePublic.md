<!-- tradingview-pine-id: PUB;d17693a6f0434796aa5d69d64f40f071 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# NQSniperOutcomeMemoryCorePublic

Source: https://www.tradingview.com/script/vGgisFmT-NQSniperOutcomeMemoryCorePublic/

## Description

Library  "NQSniperOutcomeMemoryCorePublic"

makeKey(direction, model, qualityFlags, score, extensionATR, entryRR)
  Parameters:
    direction (int)
    model (int)
    qualityFlags (int)
    score (int)
    extensionATR (float)
    entryRR (float)

record(key, resultR, keys, wins, losses, rSums)
  Parameters:
    key (int)
    resultR (float)
    keys (array<int>)
    wins (array<int>)
    losses (array<int>)
    rSums (array<float>)

stats(key, keys, wins, losses, rSums)
  Parameters:
    key (int)
    keys (array<int>)
    wins (array<int>)
    losses (array<int>)
    rSums (array<float>)

summary(key, keys, wins, losses, rSums)
  Parameters:
    key (int)
    keys (array<int>)
    wins (array<int>)
    losses (array<int>)
    rSums (array<float>)

---

## Source Code

````pine
//@version=6
library("NQSniperOutcomeMemoryCorePublic", overlay=false)

// Generic historical outcome memory.
// Receives already-computed entry context. Does not discover setups or place trades.

f_sessionCode(bool asia, bool london, bool nyPre, bool nyAM, bool nyPM) =>
    asia ? 1 : london ? 2 : nyPre ? 3 : nyAM ? 4 : nyPM ? 5 : 0

f_bool(bool v) =>
    v ? 1 : 0

export makeKey(int direction, int model, int qualityFlags, int score, float extensionATR, float entryRR) =>
    int dirCode = direction > 0 ? 1 : 0
    int modelCode = math.min(math.abs(model), 15)
    int flagCode = math.min(math.max(qualityFlags, 0), 63)
    int scoreBucket = score >= 95 ? 4 : score >= 90 ? 3 : score >= 85 ? 2 : score >= 80 ? 1 : 0
    int extBucket = extensionATR > 3.0 ? 3 : extensionATR > 2.0 ? 2 : extensionATR > 1.0 ? 1 : 0
    int rrBucket = entryRR >= 4.0 ? 3 : entryRR >= 3.0 ? 2 : entryRR >= 2.0 ? 1 : 0
    dirCode * 1000000 + modelCode * 100000 + flagCode * 1000 + scoreBucket * 100 + extBucket * 10 + rrBucket

// Richer entry-time signature. This uses only context that already exists when the trade is created.
export makeRichKey(int direction, int model, int qualityFlags, int score, float extensionATR, float entryRR,
     bool asia, bool london, bool nyPre, bool nyAM, bool nyPM,
     int bullLiquidityTier, int bearLiquidityTier,
     int bullNarrativeState, int bearNarrativeState,
     bool hasBPR, bool hasOB, bool bullMSS, bool bearMSS) =>
    int baseKey = makeKey(direction, model, qualityFlags, score, extensionATR, entryRR)
    int session = f_sessionCode(asia, london, nyPre, nyAM, nyPM)
    int liqTier = direction > 0 ? bullLiquidityTier : bearLiquidityTier
    int narrative = direction > 0 ? bullNarrativeState : bearNarrativeState
    int mss = direction > 0 ? f_bool(bullMSS) : f_bool(bearMSS)
    // Keep the integer compact while materially separating different entry contexts.
    baseKey * 100000 +
     math.min(math.max(session, 0), 7) * 10000 +
     math.min(math.max(liqTier, 0), 7) * 1000 +
     math.min(math.max(narrative, 0), 15) * 40 +
     f_bool(hasBPR) * 20 +
     f_bool(hasOB) * 10 +
     mss

export record(int key, float resultR,
     array<int> keys, array<int> wins, array<int> losses, array<float> rSums) =>
    int idx = -1
    if array.size(keys) > 0
        for i = 0 to array.size(keys)-1
            if array.get(keys, i) == key
                idx := i
    if idx == -1
        array.push(keys, key)
        array.push(wins, resultR > 0 ? 1 : 0)
        array.push(losses, resultR <= 0 ? 1 : 0)
        array.push(rSums, resultR)
    else
        if resultR > 0
            array.set(wins, idx, array.get(wins, idx) + 1)
        else
            array.set(losses, idx, array.get(losses, idx) + 1)
        array.set(rSums, idx, array.get(rSums, idx) + resultR)

export stats(int key, array<int> keys, array<int> wins, array<int> losses, array<float> rSums) =>
    int sample = 0
    int w = 0
    int l = 0
    float avgR = 0.0
    if array.size(keys) > 0
        for i = 0 to array.size(keys)-1
            if array.get(keys, i) == key
                w := array.get(wins, i)
                l := array.get(losses, i)
                sample := w + l
                avgR := sample > 0 ? array.get(rSums, i) / sample : 0.0
    float wr = sample > 0 ? w * 100.0 / sample : 0.0
    [sample, w, l, wr, avgR]

export summary(int key, array<int> keys, array<int> wins, array<int> losses, array<float> rSums) =>
    [n, w, l, wr, avgR] = stats(key, keys, wins, losses, rSums)
    n == 0 ? "MEM NEW" :
     "MEM " + str.tostring(n) + "T " + str.tostring(w) + "W/" + str.tostring(l) + "L " +
     str.tostring(wr, "#.0") + "% " + str.tostring(avgR, "#.##") + "R"

// Observation-only interpretation. No veto or order authority.
export qualityLabel(int key, array<int> keys, array<int> wins, array<int> losses, array<float> rSums) =>
    [n, w, l, wr, avgR] = stats(key, keys, wins, losses, rSums)
    n < 3 ? "LEARNING" :
     wr >= 65 and avgR > 0 ? "HIST STRONG" :
     wr <= 40 or avgR < 0 ? "HIST WEAK" :
     "HIST MIXED"
````
