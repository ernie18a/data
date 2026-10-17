# Jurik Composite Fractal Behavior (CFB)

- url: https://www.tradingview.com/script/XylngWro-Jurik-Composite-Fractal-Behavior-CFB/
- type: indicator
- pine_id: PUB;f723268dbdbe4c4a851081d6a41c58a4
- version: 1.0

## Description

Jurik Composite Fractal Behavior (CFB) is a multi-scale signal processing pipeline that measures how long price has been trending efficiently. Rather than evaluating velocity, overbought extremes, or trend direction, it acts as an objective stopwatch for market persistence by scanning price displacement against path length across a ladder of fractal depths. The resulting single integer metric tracks trend age in bars, providing a dynamic lookback parameter that self-tunes other indicators to the prevailing market regime.

HISTORICAL CONTEXT

Developed by Mark Jurik of Jurik Research, CFB was created to resolve the static lookback dilemma inherent in modern technical analysis. Traditional indicators rely on arbitrary fixed lookbacks (such as 14-period RSI or 20-period moving averages), which inevitably lag during cycle expansions or get whipsawed during consolidations.

Unlike standard momentum oscillators or volatility bands that gauge the speed or magnitude of price moves, CFB asks an entirely different structural question: how long has the market traveled in an efficient line? This implementation builds on the public reconstruction of Jurik’s algorithm, featuring an intentional enhancement: each depth’s efficiency is smoothed using the Jurik Moving Average (JMA) instead of a simple moving average (SMA). This eliminates significant phase delay and enables the composite to react to trend collapses bars ahead of traditional reconstructions, but makes this indicator very computationally intensive.

HOW IT WORKS

Stage 1: Multi-Scale Fractal Efficiency Ladder
The algorithm evaluates price displacement simultaneously across a fixed ladder of 14 fractal depths (spanning lengths 2 through 192). At each depth, it calculates an efficiency ratio: net price change divided by cumulative path length (weighted linearly so that recent bars exert greater influence). Both components update via running sums, maintaining strict O(1) computational complexity per bar. Pure straight-line movement yields an efficiency of 1.0, while random chop collapses toward zero.

Stage 2: JMA Smoothing and Dual Geometric Chains
Each depth's raw efficiency passes through an independent JMA smoother to eliminate transient noise without adding lag. The smoothed efficiencies are then allocated across two interleaved geometric chains that alternate between even and odd depth indices. Depths are evaluated from longest to shortest; each depth consumes weight proportional to its efficiency and passes the residual weight down to shorter horizons. Persistent trends concentrate weight at the longest depths, whereas choppy action cascades weight down to the shortest bricks.

Stage 3: Composite Synthesis and Adaptive Cascade Filtering
The engine computes a power-weighted composite across active depths. To ensure smooth transitions between discrete ladder rungs, the composite passes through a six-stage cascade of paired exponential moving averages featuring 1.5 / -0.5 lag-canceling combinations. The cascade's smoothing window dynamically contracts and expands based on the composite's own path length. The final output is truncated to an integer representing the effective trend duration.

INPUTS & PARAMETERS

Lengths: The ladder of fractal lookback horizons evaluated by the engine. Can be configured using Jurik's standard depth spans (24, 48, 96, 192). Default: 14-depth ladder (2 to 192).
Smooth: The lookback length for the JMA applied to each individual depth’s efficiency. Filters high-frequency chop out of the ladder. Default: 8.
Phase: Controls the lead/lag profile of the per-depth JMA smoothers (-100 to +100). Positive values increase responsiveness; negative values prioritize smoothness. Default: 0.
SmoothResult: Base period of the adaptive output cascade filter. Controls the smoothness of duration transitions. Setting this to 1 disables the output filter entirely. Default: 5.

HOW TO USE

Self-Tuning Indicator Period Modulator
CFB is designed primarily as an adaptive controller rather than a standalone trigger. Substitute CFB directly into the lookback parameter of standard indicators (e.g., RSI(CFB) or Stochastic(CFB)). In an extended, persistent trend, CFB automatically widens the calculation window to prevent premature reversal signals; during choppy consolidation, it collapses the window, maintaining rapid sensitivity.

Trend Duration and Exhaustion Timing
Plotting CFB directly shows the verified duration of the prevailing trend in bars. Readings that climb toward the maximum span (e.g., 80 to 160+) reveal mature, persistent trends approaching potential exhaustion, while a sudden collapse toward baseline signals structural regime breakdown.

Direction-Agnostic Complementarity
Because CFB measures path efficiency rather than direction, an explosive rally and an identical panic selloff register the exact same value. Pair CFB with directional indicators (such as RSX, MACD, or directional bias filters) to determine trade orientation, using CFB exclusively to manage lookback horizons, trailing stop widths, or trend persistence requirements.

LIMITATIONS

Direction Blindness: CFB tracks structural efficiency, not trend polarity. A parabolic bull run and a catastrophic market crash produce identical rising duration readings.
Extended Warmup Time: Due to the 192-bar depth ladder, per-depth JMA initialization, and the adaptive cascade filter, CFB requires up to 395 bars to reach its fully settled operational state (IsHot). Values before bar 192 remain pinned at 1.
Regime Discontinuities: Because weight shifts geometrically between discrete rungs of the depth ladder, the composite can make abrupt, stepped jumps when the dominant trend scale changes.
Computational Overhead: Updating 14 fractal depths, 14 parallel JMA filter instances, and an adaptive cascade filter on every bar makes CFB considerably more resource-intensive than basic single-line moving averages.

REFERENCES

Jurik, M. "Composite Fractal Behavior (CFB)." Jurik Research Technical Notes, 1999.
Jurik, M. "The Jurik Moving Average (JMA) & Adaptive Smoothing." Jurik Research, 2000.
Mladen. "JCFB Reference Implementation." Wealth-Lab Systems, 2007.
Loxx. "Jurik CFB Reconstruction for Pine Script." TradingView, 2021.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj
//@version=6
indicator("Jurik Composite Fractal Behavior (CFB)", "CFB", overlay=false)

// JMA copied verbatim from lib/trends_IIR/jma/jma.pine (used when Smooth Type = JMA).
//@function Spectrally correct JMA (decompiled-style, Kositsin/AmiBroker port)
//@param   source Series to calculate JMA from
//@param   period Number of bars used in the calculation (>= 1)
//@param   phase  Phase shift (-100 to 100). Negative = smoother, positive = more leading
//@returns JMA value with Jurik-style spectral volatility adaptation
//
// The 128-bar volatility distribution is held permanently sorted and mutated by one
// binary-searched remove + insert per bar, and the middle-65 trimmed mean is carried as a
// running sum updated by boundary-crossing deltas. This replaces the per-bar rebuild,
// array.sort() and 65-element summation of the naive formulation.
jma(series float source, simple int period, simple int phase = 0) =>
    // ---- Precomputed length/phase parameters (constant per series) ----
    simple float _PHASE      = phase < -100 ? 0.5 : phase > 100 ? 2.5 : (phase * 0.01) + 1.5
    simple float _LEN0       = period < 1.0000000002 ? 1e-10 : (period - 1.0) / 2.0
    simple float _LOG_PARAM  = math.max(math.log(math.sqrt(_LEN0)) / math.log(2.0) + 2.0, 0.0)
    simple float _SQRT_PARAM = math.sqrt(_LEN0) * _LOG_PARAM
    simple float _LEN_ADJ    = _LEN0 * 0.9
    simple float _LEN_DIV    = _LEN_ADJ / (_LEN_ADJ + 2.0)
    simple float _SQRT_DIV   = _SQRT_PARAM / (_SQRT_PARAM + 1.0)
    simple float _P_EXP      = math.max(_LOG_PARAM - 2.0, 0.5)

    // Trimmed-mean core: middle 65 of the 128 sorted volatility samples -> ranks 32..96
    simple int _CORE_LO  = 32
    simple int _CORE_HI  = 96
    simple int _CORE_CNT = 65
    simple int _REFRESH  = 1024   // periodic exact re-sum to bound float drift

    // ---- Internal state (persists across bars) ----
    var float  paramA      = na
    var float  paramB      = na
    var float  lastC0      = na
    var float  lastC8      = na
    var float  lastA8      = na
    var float  lastJma     = na
    var int    bars        = 0

    // 10-bar local deviation window
    var float  cycleDelta  = 0.0
    var int    volIndex    = 0
    var int    volCount    = 0
    var array<float> volWindow  = array.new_float(10, 0.0)

    // 128-bar volatility distribution, held as a permanently sorted array plus a
    // chronological circular buffer that only identifies the expiring sample.
    var array<float> chrono    = array.new_float(128, 0.0)
    var array<float> sortedArr = array.new_float(0)
    var int    chronoIdx   = 0
    var int    distCount   = 0
    var float  coreSum     = 0.0
    var int    refreshTick = 0

    float current_jma = na

    if not na(source)
        bars += 1

        // ---- First bar: initialize anchors and filter state ----
        if bars == 1
            paramA  := source
            paramB  := source
            lastC0  := source
            lastC8  := 0.0
            lastA8  := 0.0
            lastJma := source
            current_jma := source
        else
            // 1) Local deviation vs. ParamA / ParamB
            float diffA    = source - paramA
            float diffB    = source - paramB
            float absA     = math.abs(diffA)
            float absB     = math.abs(diffB)
            float absValue = absA > absB ? absA : absB
            float dLocal   = absValue + 1e-10

            // 2) 10-bar SMA of local deviation -> highD
            float oldVol = array.get(volWindow, volIndex)
            cycleDelta  += dLocal - oldVol
            array.set(volWindow, volIndex, dLocal)
            volIndex += 1
            if volIndex >= 10
                volIndex := 0
            if volCount < 10
                volCount += 1
            float highD = volCount > 0 ? cycleDelta / (volCount < 10 ? volCount : 10) : dLocal

            // 3) 128-bar volatility distribution + trimmed mean
            float dRef = highD

            if distCount < 128
                // Warmup: insert in order; trim boundaries are still expanding every bar.
                int wLo = 0
                int wHi = distCount
                while wLo < wHi
                    int wMid = int((wLo + wHi) / 2)
                    if array.get(sortedArr, wMid) > highD
                        wHi := wMid
                    else
                        wLo := wMid + 1
                array.insert(sortedArr, wLo, highD)
                array.set(chrono, chronoIdx, highD)
                chronoIdx := (chronoIdx + 1) % 128
                distCount += 1

                if distCount == 128
                    float sSeed = 0.0
                    for i = _CORE_LO to _CORE_HI
                        sSeed += array.get(sortedArr, i)
                    coreSum := sSeed
                    refreshTick := 0
                    dRef := coreSum / float(_CORE_CNT)
                else if distCount >= 16
                    int slice = int(math.max(5.0, math.round(distCount * 0.5)))
                    int drop  = (distCount - slice) / 2
                    int idxLo = math.max(drop, 0)
                    int idxHi = math.min(drop + slice - 1, distCount - 1)
                    float sWarm = 0.0
                    for i = idxLo to idxHi
                        sWarm += array.get(sortedArr, i)
                    dRef := sWarm / float(idxHi - idxLo + 1)
            else
                // Steady state: one delete + one insert, O(1) core-sum update.
                float oldVal = array.get(chrono, chronoIdx)

                // Leftmost rank holding oldVal (any equal element yields the same multiset).
                int rLo = 0
                int rHi = 128
                while rLo < rHi
                    int rMid = int((rLo + rHi) / 2)
                    if array.get(sortedArr, rMid) < oldVal
                        rLo := rMid + 1
                    else
                        rHi := rMid

                // Deletion delta against the current 128-element sorted array.
                float dRem = 0.0
                if rLo <= _CORE_HI
                    float displaced = rLo < _CORE_LO ? array.get(sortedArr, _CORE_LO) : oldVal
                    dRem := array.get(sortedArr, _CORE_HI + 1) - displaced
                array.remove(sortedArr, rLo)

                // Insertion rank in the 127-element post-deletion array.
                int iLo = 0
                int iHi = 127
                while iLo < iHi
                    int iMid = int((iLo + iHi) / 2)
                    if array.get(sortedArr, iMid) > highD
                        iHi := iMid
                    else
                        iLo := iMid + 1

                // Insertion delta against that same 127-element array.
                float dIns = 0.0
                if iLo <= _CORE_HI
                    float entering = iLo < _CORE_LO ? array.get(sortedArr, _CORE_LO - 1) : highD
                    dIns := entering - array.get(sortedArr, _CORE_HI)
                array.insert(sortedArr, iLo, highD)

                array.set(chrono, chronoIdx, highD)
                chronoIdx := (chronoIdx + 1) % 128

                coreSum += dRem + dIns
                refreshTick += 1
                if refreshTick >= _REFRESH
                    refreshTick := 0
                    float sFix = 0.0
                    for i = _CORE_LO to _CORE_HI
                        sFix += array.get(sortedArr, i)
                    coreSum := sFix
                dRef := coreSum / float(_CORE_CNT)

            if dRef <= 0.0
                dRef := dLocal

            // 4) Jurik dynamic exponent
            float ratio = absValue / dRef
            if ratio < 0.0
                ratio := 0.0
            float d = math.pow(ratio, _P_EXP)
            d := math.min(math.max(d, 1.0), _LOG_PARAM)

            // 5) Update ParamA / ParamB via sqrtDivider ^ sqrt(d)
            float adapt = math.pow(_SQRT_DIV, math.sqrt(d))
            if source > paramA
                paramA := source
            else
                paramA := source - (source - paramA) * adapt
            if source < paramB
                paramB := source
            else
                paramB := source - (source - paramB) * adapt

            // 6) 2-pole IIR core (C0/C8/A8) with Jurik alpha
            float prevJma = na(lastJma) ? source : lastJma
            float alpha  = math.pow(_LEN_DIV, d)
            float alpha2 = alpha * alpha
            float c0 = (1.0 - alpha) * source + alpha * lastC0
            float c8 = (source - c0) * (1.0 - _LEN_DIV) + _LEN_DIV * lastC8
            float a8 = (_PHASE * c8 + c0 - prevJma) * (alpha * -2.0 + alpha2 + 1.0) + alpha2 * lastA8
            float jmaVal = prevJma + a8

            lastC0  := c0
            lastC8  := c8
            lastA8  := a8
            lastJma := jmaVal
            current_jma := jmaVal

    current_jma

// ---------------------------------------------------------------------------------------------
// Jurik's master depth ladder.
//
// Jurik restricted CFB to four "span sizes" (24, 48, 96, 192) because scanning every possible
// fractal size is combinatorially expensive. Each span size is the leading (shortest) prefix of
// this ladder, so span 24 scans 8 depths, 48 scans 10, 96 scans 12 and 192 scans all 14.
// Depth 2 and depth 3 are "basic bricks": they feed the composite but are too short to express a
// trend on their own.
//
//@function depth
//@param   i Index into Jurik's depth ladder, 0 = shortest.
//@returns  Fractal depth in bars.
depth(int i) =>
    switch i
        0 => 2
        1 => 3
        2 => 4
        3 => 6
        4 => 8
        5 => 12
        6 => 16
        7 => 24
        8 => 32
        9 => 48
        10 => 64
        11 => 96
        12 => 128
        => 192

// ---------------------------------------------------------------------------------------------
// CFB.
//
// For each depth D the fractal efficiency of the trailing window is
//
//     |D*P[t] - sum(P[t-D] .. P[t-1])|  /  sum((D-i) * |P[t-i] - P[t-i-1]|)
//
// The numerator is the sum of the window's signed legs (how much of each individual step survived
// in the direction of travel). The denominator is the total path length with the most recent bar
// weighted D and the oldest weighted 1. By the triangle inequality the ratio is bounded to [0,1] and
// equals exactly 1 on a straight line. Both terms are running sums, so a depth costs O(1) per bar.
//
// Each efficiency series is then smoothed with its own JMA of length `smooth`, clamped to [0,1] because
// the weight chain below needs weights in that range. Depths are walked from
// longest to shortest along two interleaved geometric chains; every longer depth already walked on
// a chain donates (1 - its weight) to the depths below it, so a clean trend concentrates weight on
// the longest depth of each chain and choppy action pushes weight toward the shortest. The
// composite is a squared-weight mean of the depths, run through a six-stage adaptive average whose
// period stretches with how far the composite has moved against its own recent path, and finally
// truncated to an integer period in [1, maxDepth].
//
//@function Calculates Jurik Composite Fractal Behavior (Trend Duration Index)
//@param   source       Series to calculate CFB from.
//@param   spanSize     Jurik composite span size; one of 24, 48, 96 or 192 bars.
//@param   smooth       JMA length applied to each depth's efficiency. Jurik's default is 8.
//@param   smoothResult Base period of the adaptive result filter. 1 disables the filter.
//@param   phase        JMA phase (-100 to 100) applied to each depth's efficiency smoother.
//@returns CFB value: integer trend duration in bars, or 1 while the scan is still warming up.
cfb(series float source, simple int spanSize, simple int smooth, simple int smoothResult, simple int phase) =>
    int depthCount = spanSize == 24 ? 8 : spanSize == 48 ? 10 : spanSize == 96 ? 12 : 14
    int maxDepth = depth(depthCount - 1)
    int historySize = smoothResult <= 1 ? 1 : int(math.ceil(smoothResult * 0.5 * 5.0))
    float minResultPeriod = smoothResult * 0.5
    int t = bar_index

    // Rolling state, one slot per ladder entry.
    var array<float> sumAbsChange = array.new_float(14, 0.0)
    var array<float> sumWeighted = array.new_float(14, 0.0)
    var array<float> sumPrice = array.new_float(14, 0.0)
    var array<float> smoothed = array.new_float(14, 0.0)
    var array<float> efficiencyNow = array.new_float(14, na)
    var array<int> ladder = array.from(2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192)

    // Recent unfiltered composites, consumed by the adaptive result filter.
    var array<float> rawHistory = array.new_float(0)
    var float rawComposite = 0.0
    var float e1 = 0.0
    var float e2 = 0.0
    var float e3 = 0.0
    var float e4 = 0.0
    var float e5 = 0.0
    var float e6 = 0.0

    float price = source
    float roc = t == 0 ? 0.0 : math.abs(price - source[1])

    bool deepestReady = true

    for i = 0 to depthCount - 1
        int d = array.get(ladder, i)
        float previousAbsChange = array.get(sumAbsChange, i)
        array.set(sumWeighted, i, array.get(sumWeighted, i) + d * roc - previousAbsChange)
        float absChange = previousAbsChange + roc
        absChange := t >= d ? absChange - roc[d] : absChange
        array.set(sumAbsChange, i, absChange)

        float priceSum = array.get(sumPrice, i)
        priceSum += t > 0 ? price[1] : 0.0
        priceSum -= t > d ? price[d + 1] : 0.0
        array.set(sumPrice, i, priceSum)

        if t < d
            deepestReady := false
            array.set(efficiencyNow, i, na)
            continue

        float denominator = array.get(sumWeighted, i)
        float numerator = math.abs(d * price - priceSum)
        float efficiency = denominator > 0.0 ? math.min(numerator / denominator, 1.0) : 0.0

        array.set(efficiencyNow, i, efficiency)

    // One JMA per depth. Each call site keeps its own state, so these cannot be a loop.
    float jma0 = jma(array.get(efficiencyNow, 0), smooth, phase)
    float jma1 = jma(array.get(efficiencyNow, 1), smooth, phase)
    float jma2 = jma(array.get(efficiencyNow, 2), smooth, phase)
    float jma3 = jma(array.get(efficiencyNow, 3), smooth, phase)
    float jma4 = jma(array.get(efficiencyNow, 4), smooth, phase)
    float jma5 = jma(array.get(efficiencyNow, 5), smooth, phase)
    float jma6 = jma(array.get(efficiencyNow, 6), smooth, phase)
    float jma7 = jma(array.get(efficiencyNow, 7), smooth, phase)
    float jma8 = jma(array.get(efficiencyNow, 8), smooth, phase)
    float jma9 = jma(array.get(efficiencyNow, 9), smooth, phase)
    float jma10 = jma(array.get(efficiencyNow, 10), smooth, phase)
    float jma11 = jma(array.get(efficiencyNow, 11), smooth, phase)
    float jma12 = jma(array.get(efficiencyNow, 12), smooth, phase)
    float jma13 = jma(array.get(efficiencyNow, 13), smooth, phase)
    array.set(smoothed, 0, math.min(math.max(nz(jma0), 0.0), 1.0))
    array.set(smoothed, 1, math.min(math.max(nz(jma1), 0.0), 1.0))
    array.set(smoothed, 2, math.min(math.max(nz(jma2), 0.0), 1.0))
    array.set(smoothed, 3, math.min(math.max(nz(jma3), 0.0), 1.0))
    array.set(smoothed, 4, math.min(math.max(nz(jma4), 0.0), 1.0))
    array.set(smoothed, 5, math.min(math.max(nz(jma5), 0.0), 1.0))
    array.set(smoothed, 6, math.min(math.max(nz(jma6), 0.0), 1.0))
    array.set(smoothed, 7, math.min(math.max(nz(jma7), 0.0), 1.0))
    array.set(smoothed, 8, math.min(math.max(nz(jma8), 0.0), 1.0))
    array.set(smoothed, 9, math.min(math.max(nz(jma9), 0.0), 1.0))
    array.set(smoothed, 10, math.min(math.max(nz(jma10), 0.0), 1.0))
    array.set(smoothed, 11, math.min(math.max(nz(jma11), 0.0), 1.0))
    array.set(smoothed, 12, math.min(math.max(nz(jma12), 0.0), 1.0))
    array.set(smoothed, 13, math.min(math.max(nz(jma13), 0.0), 1.0))

    float result = 1.0

    if deepestReady
        float accumulatorEven = 1.0
        float accumulatorOdd = 1.0
        float weightedDepth = 0.0
        float weightTotal = 0.0

        for i = depthCount - 1 to 0
            bool evenChain = (depthCount - 1 - i) % 2 == 0
            float accumulator = evenChain ? accumulatorEven : accumulatorOdd
            float weight = accumulator * array.get(smoothed, i)
            float donated = accumulator * (1.0 - weight)
            if evenChain
                accumulatorEven := donated
            else
                accumulatorOdd := donated

            float squared = weight * weight
            weightedDepth += array.get(ladder, i) * squared
            weightTotal += squared

        bool trending = weightTotal > 0.0
        float composite = trending ? weightedDepth / weightTotal : rawComposite
        rawComposite := trending ? composite : rawComposite
        float value = composite

        if smoothResult > 1
            int endPeriod = historySize
            int available = array.size(rawHistory)
            float period = float(smoothResult)
            if available >= endPeriod and endPeriod > 1
                float signal = math.abs(value - array.get(rawHistory, available - endPeriod))
                float noise = 1e-11
                for k = 1 to endPeriod - 1
                    noise += math.abs(value - array.get(rawHistory, available - k))
                period := (signal / noise) * (minResultPeriod * 4.0) + minResultPeriod

            float alpha = (2.0 + 3.0) / (1.0 + 3.0 + period)
            e1 += alpha * (value - e1)
            e2 += alpha * (e1 - e2)
            float stage1 = 1.5 * e1 - 0.5 * e2
            e3 += alpha * (stage1 - e3)
            e4 += alpha * (e3 - e4)
            float stage2 = 1.5 * e3 - 0.5 * e4
            e5 += alpha * (stage2 - e5)
            e6 += alpha * (e5 - e6)
            value := 1.5 * e5 - 0.5 * e6

            array.push(rawHistory, rawComposite)
            while array.size(rawHistory) > endPeriod
                array.shift(rawHistory)

        result := math.min(math.max(math.floor(value), 1.0), float(maxDepth))

    result

// ---------- Main ----------

i_spanSize = input.int(192, "Span Size", options=[24, 48, 96, 192], tooltip="Jurik composite span size. Controls how deep the fractal scan reaches.")
i_smooth = input.int(8, "Smooth", minval=1, tooltip="JMA length applied to each depth's efficiency. Higher is smoother and slower.")
i_smoothResult = input.int(5, "Smooth Result", minval=1, tooltip="Base period of the adaptive result filter. Set to 1 to disable it.")
i_phase = input.int(0, "JMA Phase", minval=-100, maxval=100, step=10, tooltip="JMA phase for the per-depth smoother. Negative is smoother, positive is more leading.")
i_source = input.source(close, "Source")

cfbValue = cfb(i_source, i_spanSize, i_smooth, i_smoothResult, i_phase)

plot(cfbValue, "CFB", color=color.yellow, linewidth=2)
hline(1, "Min", color=color.gray, linestyle=hline.style_dotted)
````
