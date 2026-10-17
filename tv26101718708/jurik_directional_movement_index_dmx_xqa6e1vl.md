# Jurik Directional Movement Index (DMX)

- url: https://www.tradingview.com/script/Xqa6E1VL-Jurik-Directional-Movement-Index-DMX/
- type: indicator
- pine_id: PUB;9704a7dbf5514773860b5fced23ad21f
- version: 1.0

## Description

The Jurik Directional Movement Index (DMX) is a low-lag, bipolar trend oscillator that combines J. Welles Wilder’s classical directional movement framework with Jurik Moving Average (JMA) smoothing. While standard Average Directional Index (ADX) discards directional polarity to measure raw trend strength, DMX retains the sign of range expansion, producing a smooth, zero-centered oscillator nominally bounded between -100 and +100. By eliminating the destructive lag and jagged noise inherent in Wilder's original calculations, DMX provides earlier inflection points, cleaner zero-line transitions, and distinct exhaustion signals.

HISTORICAL CONTEXT

In 1978, J. Welles Wilder published the Directional Movement system (+DI, -DI, DX, and ADX) in New Concepts in Technical Trading Systems. Although revolutionary, classical ADX takes the absolute value of the difference between +DI and -DI, stripping out directional sign. As a result, ADX measures only whether a trend is strong, but cannot tell whether buyers or sellers are in control. Furthermore, Wilder’s cumulative smoothing (RMA) introduces significant phase delay, often signaling a trend long after the optimal trade entry has passed.

Mark Jurik of Jurik Research resolved these issues by introducing "Bipolar DMI" and filtering it with the proprietary Jurik Moving Average (JMA). Removing the absolute value from the directional ratio preserves market polarity: positive during upward expansions and negative during downward expansions. Smoothing this signed series with JMA eliminates false whipsaws common to raw +DI/-DI crossovers without the sluggish phase lag of standard moving averages.

HOW IT WORKS

Stage 1: Directional Movement and True Range
The script measures directional expansion by comparing the current bar's range against the previous bar (+DM and -DM), normalized against the True Range (TR). Wilder’s smoothing accumulates these components across the specified Period to compute the positive and negative directional indicators (+DI and -DI).

Stage 2: Bipolar DMI Formulation
Unlike classical DX, which computes the absolute difference between directional indicators, DMX calculates a signed bipolar ratio:
Bipolar = (+DI - -DI) / (+DI + -DI)
This maps directional balance into a continuous, normalized range from -1 to +1. A value of +1 represents pure upward expansion, -1 represents pure downward expansion, and 0 marks complete directional equilibrium.

Stage 3: JMA Adaptive Smoothing
The raw bipolar series passes into an integrated Jurik Moving Average (JMA) using the same Period parameter. JMA’s internal volatility-distribution tracking suppresses high-frequency noise and rogue price spikes while reacting instantaneously to genuine inflection points. In Pine Script, the output is scaled to -100 to +100 for intuitive threshold charting alongside conventional momentum levels.

INPUTS & PARAMETERS

Period: The lookback length used for both the directional movement indicators (+DI/-DI) and the adaptive JMA smoother. Default: 14.

HOW TO USE

Zero-Line Crossings & Trend Bias
DMX oscillates symmetrically around a zero baseline, indicating which market participant is in control:

Bullish Bias: DMX > 0 indicates buyers dominate directional expansion.

Bearish Bias: DMX < 0 indicates sellers dominate directional expansion.

Trend Inversion Signal: A cross above zero signals an emerging bullish regime; a cross below zero marks an emerging bearish breakdown.

Slope Reversals and Early Exhaustion
Because JMA filters out minor noise without introducing lag, slope reversals in DMX carry strong predictive utility:

Bullish Exhaustion: DMX curling downward from positive extreme zones (e.g., above +60) warns of fading momentum bars before price tops out.

Bearish Exhaustion: DMX hooking upward from negative extreme zones (e.g., below -60) signals that selling pressure is dissipating.

Directional Saturation Zones
Readings approaching ±60 to ±80 highlight powerful, efficient directional runs. Persistent readings near these extremes confirm a dominant trend, while divergences between price (e.g., higher highs) and DMX peaks (lower highs) alert to hidden momentum decay.

LIMITATIONS

Dynamic Overshoot: Because JMA adapts dynamically to volatility with minimal phase delay, violent price shocks can cause the smoothed oscillator to briefly overshoot beyond the nominal -100 to +100 boundaries.
Warmup Time: The calculation requires initialization of both Wilder’s RMA accumulator and JMA’s internal 128-sample volatility distribution. Output during the early warmup window is uninitialized and should be disregarded.
Congestion Chop: During tight, low-volatility trading ranges where +DI and -DI converge toward near-equal values, DMX will hover tightly around zero. Use a secondary volatility or trend filter to avoid false signals in flat markets.
Proprietary Reconstruction: Mark Jurik’s commercial DMX binaries are proprietary. This implementation reconstructs the published architecture using open mathematical formulations and defensible JMA logic, which may show subtle numerical differences from closed-source commercial releases.

REFERENCES

Wilder, J. W. New Concepts in Technical Trading Systems. Trend Research, 1978.
Jurik Research. Product Guide: Software Tools for Market Technicians. Jurik Research, 1999.
Jurik, M. "The Jurik Moving Average (JMA)." Jurik Research Technical Documentation, 2000.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj
//@version=6
indicator("Jurik Directional Movement Index (DMX)", "DMX", overlay=false)

// JMA implementation copied from lib/trends_IIR/jma/jma.pine.
jma_filter(series float source, simple int period, simple int phase = 0) =>
    simple float _PHASE      = phase < -100 ? 0.5 : phase > 100 ? 2.5 : (phase * 0.01) + 1.5
    simple float _LEN0       = period < 1.0000000002 ? 1e-10 : (period - 1.0) / 2.0
    simple float _LOG_PARAM  = math.max(math.log(math.sqrt(_LEN0)) / math.log(2.0) + 2.0, 0.0)
    simple float _SQRT_PARAM = math.sqrt(_LEN0) * _LOG_PARAM
    simple float _LEN_ADJ    = _LEN0 * 0.9
    simple float _LEN_DIV    = _LEN_ADJ / (_LEN_ADJ + 2.0)
    simple float _SQRT_DIV   = _SQRT_PARAM / (_SQRT_PARAM + 1.0)
    simple float _P_EXP      = math.max(_LOG_PARAM - 2.0, 0.5)

    simple int _CORE_LO  = 32
    simple int _CORE_HI  = 96
    simple int _CORE_CNT = 65
    simple int _REFRESH  = 1024

    var float paramA      = na
    var float paramB      = na
    var float lastC0      = na
    var float lastC8      = na
    var float lastA8      = na
    var float lastJma     = na
    var int bars          = 0

    var float cycleDelta = 0.0
    var int volIndex     = 0
    var int volCount     = 0
    var array<float> volWindow = array.new_float(10, 0.0)

    var array<float> chrono    = array.new_float(128, 0.0)
    var array<float> sortedArr = array.new_float(0)
    var int chronoIdx          = 0
    var int distCount          = 0
    var float coreSum          = 0.0
    var int refreshTick        = 0

    float current_jma = na

    if not na(source)
        bars += 1

        if bars == 1
            paramA := source
            paramB := source
            lastC0 := source
            lastC8 := 0.0
            lastA8 := 0.0
            lastJma := source
            current_jma := source
        else
            float diffA = source - paramA
            float diffB = source - paramB
            float absA = math.abs(diffA)
            float absB = math.abs(diffB)
            float absValue = absA > absB ? absA : absB
            float dLocal = absValue + 1e-10

            float oldVol = array.get(volWindow, volIndex)
            cycleDelta += dLocal - oldVol
            array.set(volWindow, volIndex, dLocal)
            volIndex += 1
            if volIndex >= 10
                volIndex := 0
            if volCount < 10
                volCount += 1
            float highD = volCount > 0 ? cycleDelta / (volCount < 10 ? volCount : 10) : dLocal

            float dRef = highD

            if distCount < 128
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
                    int drop = (distCount - slice) / 2
                    int idxLo = math.max(drop, 0)
                    int idxHi = math.min(drop + slice - 1, distCount - 1)
                    float sWarm = 0.0
                    for i = idxLo to idxHi
                        sWarm += array.get(sortedArr, i)
                    dRef := sWarm / float(idxHi - idxLo + 1)
            else
                float oldVal = array.get(chrono, chronoIdx)

                int rLo = 0
                int rHi = 128
                while rLo < rHi
                    int rMid = int((rLo + rHi) / 2)
                    if array.get(sortedArr, rMid) < oldVal
                        rLo := rMid + 1
                    else
                        rHi := rMid

                float dRem = 0.0
                if rLo <= _CORE_HI
                    float displaced = rLo < _CORE_LO ? array.get(sortedArr, _CORE_LO) : oldVal
                    dRem := array.get(sortedArr, _CORE_HI + 1) - displaced
                array.remove(sortedArr, rLo)

                int iLo = 0
                int iHi = 127
                while iLo < iHi
                    int iMid = int((iLo + iHi) / 2)
                    if array.get(sortedArr, iMid) > highD
                        iHi := iMid
                    else
                        iLo := iMid + 1

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

            float ratio = absValue / dRef
            if ratio < 0.0
                ratio := 0.0
            float d = math.pow(ratio, _P_EXP)
            d := math.min(math.max(d, 1.0), _LOG_PARAM)

            float adapt = math.pow(_SQRT_DIV, math.sqrt(d))
            if source > paramA
                paramA := source
            else
                paramA := source - (source - paramA) * adapt
            if source < paramB
                paramB := source
            else
                paramB := source - (source - paramB) * adapt

            float prevJma = na(lastJma) ? source : lastJma
            float alpha = math.pow(_LEN_DIV, d)
            float alpha2 = alpha * alpha
            float c0 = (1.0 - alpha) * source + alpha * lastC0
            float c8 = (source - c0) * (1.0 - _LEN_DIV) + _LEN_DIV * lastC8
            float a8 = (_PHASE * c8 + c0 - prevJma) * (alpha * -2.0 + alpha2 + 1.0) + alpha2 * lastA8
            float jmaVal = prevJma + a8

            lastC0 := c0
            lastC8 := c8
            lastA8 := a8
            lastJma := jmaVal
            current_jma := jmaVal

    current_jma

//@function Calculates DMX as JMA-smoothed bipolar DMI
//@param period Number of bars used in the calculation
//@returns [DMX, raw bipolar DMI] in the range -1..1
dmx(simple int period = 14) =>
    if period <= 0
        runtime.error("Period must be greater than 0")
    [plus_di, minus_di, _] = ta.dmi(period, period)
    float di_sum = plus_di + minus_di
    float source = di_sum != 0.0 ? (plus_di - minus_di) / di_sum : 0.0

    float dmx_value = jma_filter(source, period)
    [dmx_value, source]

// Inputs
i_period = input.int(14, "Period", minval=1, tooltip="Number of bars used in the calculation")

// Use the same DI and ADX lengths as DMI; ADX itself is not part of the DMX formula.
[dmx_value, raw_bipolar_dmi] = dmx(i_period)
i_showRaw = input.bool(true, "Show raw bipolar DMI")

// Scale plots to compare with DMI's 0..100 lines; the calculation remains in -1..1.
plot(dmx_value * 100.0, "DMX x100", color=color.yellow, linewidth=2)
plot(i_showRaw ? raw_bipolar_dmi * 100.0 : na, "Raw bipolar DMI x100", color=color.gray, linewidth=1)
````
