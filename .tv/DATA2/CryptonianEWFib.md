<!-- tradingview-pine-id: PUB;7592ecd2ec394a3796c773321658d26d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CryptonianEWFib

Source: https://www.tradingview.com/script/4uPak2ta-CryptonianEWFib/

## Description

Library  "CryptonianEWFib"
Cryptonian Elliott Wave Fib /1. Stage-aware Fibonacci model, corrective projection geometry and Fresh-FVG lifecycle/confluence. Extracted from the proven 11.8c/11.8d host without methodology changes.

evaluate(goldProfile, ticker, chartTimeframeSeconds, fvgMinAtr, fvgMaxAgeBars, fibEngineOn, fvgEngineOn, fvgRequireSourceLeg, maxStoredFvgs, fvgMinRemainingPct, atrValue, mintick, currentBar, currentHigh, currentLow, currentClose, p0, p1, p2, p3, p4, pb0, pb1, pb2, pb3, primaryKey, primaryLockedCount, primaryDirection, primaryW2Depth, primaryW3Extension, primaryW4Depth, primaryW5Ratio, primaryQuality, correctionSourceKey, correctionCommittedCount, correctionOriginPrice, correctionSourceDirection, c1, cp1, c2, cp2, cb2, correctionConfirmed, correctionHasProvisional, fvgOriginalTops, fvgOriginalBottoms, fvgLiveTops, fvgLiveBottoms, fvgDirections, fvgBirthBars)
  Parameters:
    goldProfile (bool)
    ticker (string)
    chartTimeframeSeconds (int)
    fvgMinAtr (float)
    fvgMaxAgeBars (int)
    fibEngineOn (bool)
    fvgEngineOn (bool)
    fvgRequireSourceLeg (bool)
    maxStoredFvgs (int)
    fvgMinRemainingPct (float)
    atrValue (float)
    mintick (float)
    currentBar (int)
    currentHigh (float)
    currentLow (float)
    currentClose (float)
    p0 (float)
    p1 (float)
    p2 (float)
    p3 (float)
    p4 (float)
    pb0 (int)
    pb1 (int)
    pb2 (int)
    pb3 (int)
    primaryKey (string)
    primaryLockedCount (int)
    primaryDirection (int)
    primaryW2Depth (float)
    primaryW3Extension (float)
    primaryW4Depth (float)
    primaryW5Ratio (float)
    primaryQuality (float)
    correctionSourceKey (string)
    correctionCommittedCount (int)
    correctionOriginPrice (float)
    correctionSourceDirection (int)
    c1 (float)
    cp1 (bool)
    c2 (float)
    cp2 (bool)
    cb2 (int)
    correctionConfirmed (bool)
    correctionHasProvisional (bool)
    fvgOriginalTops (array<float>)
    fvgOriginalBottoms (array<float>)
    fvgLiveTops (array<float>)
    fvgLiveBottoms (array<float>)
    fvgDirections (array<int>)
    fvgBirthBars (array<int>)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AYEHAN

//@version=6
// @description Cryptonian Elliott Wave Fib /1. Stage-aware Fibonacci model, corrective projection geometry and Fresh-FVG lifecycle/confluence. Extracted from the proven 11.8c/11.8d host without methodology changes.
library("CryptonianEWFib", overlay = true)

import AYEHAN/CryptonianEWCore/10 as ewCore

_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

_pct(float value) =>
    na(value) ? "—" : str.tostring(value, "#.0") + "%"

_findBestFvg(
     array<float> originalTops,
     array<float> originalBottoms,
     array<float> liveTops,
     array<float> liveBottoms,
     array<int> directions,
     array<int> birthBars,
     bool fvgEngineOn,
     float zoneTop,
     float zoneBottom,
     int wantedDirection,
     int sourceStartBar,
     int sourceEndBar,
     bool requireSourceLeg,
     int effectiveFvgMaxAge,
     float mintick,
     int currentBar) =>

    float selectedTop = na
    float selectedBottom = na
    int selectedBirthBar = na
    float selectedRemainingPct = na
    int selectedAge = na
    float selectedRank = na

    if fvgEngineOn and not na(zoneTop) and not na(zoneBottom) and wantedDirection != 0 and array.size(originalTops) > 0
        for searchIndex = array.size(originalTops) - 1 to 0
            int gapDirection = array.get(directions, searchIndex)
            int gapBirthBar = array.get(birthBars, searchIndex)
            bool directionMatches = gapDirection == wantedDirection
            bool sourceMatches = not requireSourceLeg or
                 (not na(sourceStartBar) and not na(sourceEndBar) and
                  gapBirthBar >= sourceStartBar and gapBirthBar <= sourceEndBar)

            if directionMatches and sourceMatches
                float originalTop = array.get(originalTops, searchIndex)
                float originalBottom = array.get(originalBottoms, searchIndex)
                float liveTop = array.get(liveTops, searchIndex)
                float liveBottom = array.get(liveBottoms, searchIndex)
                float overlapSize = math.min(zoneTop, liveTop) - math.max(zoneBottom, liveBottom)

                if overlapSize > 0.0
                    float originalSize = math.max(originalTop - originalBottom, mintick)
                    float liveSize = math.max(liveTop - liveBottom, 0.0)
                    float remainingPct = liveSize / originalSize * 100.0
                    int gapAge = math.max(currentBar - gapBirthBar, 0)
                    float overlapShare = overlapSize / math.max(zoneTop - zoneBottom, mintick) * 100.0
                    float freshnessShare = 100.0 - math.min(gapAge * 100.0 / math.max(effectiveFvgMaxAge, 1), 100.0)
                    float rank = remainingPct * 0.50 + overlapShare * 0.30 + freshnessShare * 0.20

                    if na(selectedRank) or rank > selectedRank
                        selectedTop := liveTop
                        selectedBottom := liveBottom
                        selectedBirthBar := gapBirthBar
                        selectedRemainingPct := remainingPct
                        selectedAge := gapAge
                        selectedRank := rank

    [selectedTop, selectedBottom, selectedBirthBar, selectedRemainingPct, selectedAge, selectedRank]


// Full Part-5 state evaluation. The six FVG arrays are owned by the indicator
// and mutated here, preserving exactly one persistent FVG store per indicator instance.
export evaluate(
     bool goldProfile,
     string ticker,
     int chartTimeframeSeconds,
     float fvgMinAtr,
     int fvgMaxAgeBars,
     bool fibEngineOn,
     bool fvgEngineOn,
     bool fvgRequireSourceLeg,
     int maxStoredFvgs,
     float fvgMinRemainingPct,
     float atrValue,
     float mintick,
     int currentBar,
     float currentHigh,
     float currentLow,
     float currentClose,
     float p0,
     float p1,
     float p2,
     float p3,
     float p4,
     int pb0,
     int pb1,
     int pb2,
     int pb3,
     string primaryKey,
     int primaryLockedCount,
     int primaryDirection,
     float primaryW2Depth,
     float primaryW3Extension,
     float primaryW4Depth,
     float primaryW5Ratio,
     float primaryQuality,
     string correctionSourceKey,
     int correctionCommittedCount,
     float correctionOriginPrice,
     int correctionSourceDirection,
     float c1,
     bool cp1,
     float c2,
     bool cp2,
     int cb2,
     bool correctionConfirmed,
     bool correctionHasProvisional,
     array<float> fvgOriginalTops,
     array<float> fvgOriginalBottoms,
     array<float> fvgLiveTops,
     array<float> fvgLiveBottoms,
     array<int> fvgDirections,
     array<int> fvgBirthBars) =>

    bool isGoldInstrument = str.contains(ticker, "XAU") or str.contains(ticker, "GOLD")
    bool goldProfileActive = goldProfile and isGoldInstrument

    float effectiveFvgMinAtr =
         goldProfileActive ?
         (chartTimeframeSeconds <= 1800 ? 0.10 :
          chartTimeframeSeconds <= 14400 ? 0.14 : 0.18) :
         fvgMinAtr

    int effectiveFvgMaxAge =
         goldProfileActive ?
         (chartTimeframeSeconds <= 1800 ? 160 :
          chartTimeframeSeconds <= 14400 ? 120 : 90) :
         fvgMaxAgeBars

    // Active motive Fibonacci levels.
    float fibW2_382 = not na(p0) and not na(p1) ? ewCore.fibPrice(p1, p0, 38.2) : na
    float fibW2_500 = not na(p0) and not na(p1) ? ewCore.fibPrice(p1, p0, 50.0) : na
    float fibW2_618 = not na(p0) and not na(p1) ? ewCore.fibPrice(p1, p0, 61.8) : na
    float fibW2_786 = not na(p0) and not na(p1) ? ewCore.fibPrice(p1, p0, 78.6) : na

    float fibW3_1618 = not na(p0) and not na(p1) and not na(p2) ? p2 + (p1 - p0) * 1.618 : na
    float fibW3_2618 = not na(p0) and not na(p1) and not na(p2) ? p2 + (p1 - p0) * 2.618 : na

    float fibW4_236 = not na(p2) and not na(p3) ? ewCore.fibPrice(p3, p2, 23.6) : na
    float fibW4_382 = not na(p2) and not na(p3) ? ewCore.fibPrice(p3, p2, 38.2) : na
    float fibW4_500 = not na(p2) and not na(p3) ? ewCore.fibPrice(p3, p2, 50.0) : na
    float fibW4_618 = not na(p2) and not na(p3) ? ewCore.fibPrice(p3, p2, 61.8) : na

    float fibW5_equalW1 = not na(p4) and not na(p0) and not na(p1) ? p4 + (p1 - p0) : na
    float fibW5_618Net03 = not na(p4) and not na(p0) and not na(p3) ? p4 + (p3 - p0) * 0.618 : na

    // ABC projection model.
    bool correctionAConfirmed =
         correctionSourceKey != "" and correctionCommittedCount >= 1 and not na(c1) and not cp1
    bool correctionBConfirmed =
         correctionSourceKey != "" and correctionCommittedCount >= 2 and not na(c2) and not cp2

    float correctionB382 =
         correctionAConfirmed ? ewCore.fibPrice(c1, correctionOriginPrice, 38.2) : na
    float correctionB500 =
         correctionAConfirmed ? ewCore.fibPrice(c1, correctionOriginPrice, 50.0) : na
    float correctionB618 =
         correctionAConfirmed ? ewCore.fibPrice(c1, correctionOriginPrice, 61.8) : na
    float correctionB786 =
         correctionAConfirmed ? ewCore.fibPrice(c1, correctionOriginPrice, 78.6) : na
    float correctionB900 =
         correctionAConfirmed ? ewCore.fibPrice(c1, correctionOriginPrice, 90.0) : na
    float correctionB100 = correctionAConfirmed ? correctionOriginPrice : na

    float correctionANormal =
         correctionAConfirmed ?
         ewCore.correctionProgress(correctionOriginPrice, c1, correctionSourceDirection) : na
    float correctionBNormal =
         correctionAConfirmed and not na(c2) ?
         ewCore.correctionProgress(correctionOriginPrice, c2, correctionSourceDirection) : na

    // Track furthest LIVE B excursion. These local var values persist across
    // calls of this exported function and therefore replace the host globals.
    var string correctionLiveBSource = ""
    var float correctionLiveBExtreme = na

    bool trackingDevelopingB =
         correctionAConfirmed and correctionCommittedCount == 1 and correctionHasProvisional

    if correctionSourceKey != correctionLiveBSource or not trackingDevelopingB
        correctionLiveBSource := correctionSourceKey
        correctionLiveBExtreme :=
             trackingDevelopingB ?
             (correctionSourceDirection == 1 ? currentHigh : currentLow) : na
    else
        correctionLiveBExtreme :=
             correctionSourceDirection == 1 ?
             math.max(nz(correctionLiveBExtreme, currentHigh), currentHigh) :
             math.min(nz(correctionLiveBExtreme, currentLow), currentLow)

    float correctionBLiveNormal =
         trackingDevelopingB and not na(correctionLiveBExtreme) ?
         ewCore.correctionProgress(correctionOriginPrice, correctionLiveBExtreme, correctionSourceDirection) :
         correctionBNormal

    float correctionBLiveRetracement =
         not na(correctionANormal) and correctionANormal > mintick and not na(correctionBLiveNormal) ?
         (correctionANormal - correctionBLiveNormal) / correctionANormal * 100.0 : na

    bool correctionBExtremeReassess =
         trackingDevelopingB and not na(correctionBLiveRetracement) and
         correctionBLiveRetracement > 161.8

    string correctionFamilyWatch =
         na(correctionBLiveRetracement) ? "WAIT B" :
         correctionBLiveRetracement >= 23.6 and correctionBLiveRetracement <= 78.6 ? "ZIGZAG WATCH" :
         correctionBLiveRetracement >= 90.0 and correctionBLiveRetracement <= 100.0 ? "FLAT WATCH" :
         correctionBLiveRetracement > 100.0 and correctionBLiveRetracement <= 161.8 ? "EXPANDED / RUNNING FLAT WATCH" :
         correctionBLiveRetracement > 161.8 ? "REASSESS · B >161.8% A" :
         "UNCLASSIFIED B"

    bool correctionForecastSequenceIntact =
         (correctionCommittedCount == 1 and not na(c1) ?
             (currentClose - c1) * correctionSourceDirection >= 0 :
          correctionCommittedCount == 2 and not na(c2) ?
             (currentClose - c2) * correctionSourceDirection <= 0 :
          true) and not correctionBExtremeReassess

    float correctionC618 =
         correctionBConfirmed ? c2 + (c1 - correctionOriginPrice) * 0.618 : na
    float correctionC100 =
         correctionBConfirmed ? c2 + (c1 - correctionOriginPrice) : na
    float correctionC1618 =
         correctionBConfirmed ? c2 + (c1 - correctionOriginPrice) * 1.618 : na

    bool correctionC618Consumed =
         correctionBConfirmed and
         ewCore.levelBrokenAfter(cb2, correctionC618, -correctionSourceDirection, "Wick break")
    bool correctionC100Consumed =
         correctionBConfirmed and
         ewCore.levelBrokenAfter(cb2, correctionC100, -correctionSourceDirection, "Wick break")
    bool correctionC1618Consumed =
         correctionBConfirmed and
         ewCore.levelBrokenAfter(cb2, correctionC1618, -correctionSourceDirection, "Wick break")

    // Fibonacci quality.
    float primaryFibQuality = na
    float fibScoreAccumulator = 0.0
    int fibScoreKnownCount = 0

    if fibEngineOn and primaryKey != ""
        if primaryLockedCount >= 3 and not na(primaryW2Depth)
            float w2FibScore =
                 ewCore.relationScore(primaryW2Depth, 50.0, 61.8, 38.2, 78.6)
            fibScoreAccumulator += w2FibScore
            fibScoreKnownCount += 1

        if primaryLockedCount >= 4 and not na(primaryW3Extension)
            float w3FibScore =
                 ewCore.relationScore(primaryW3Extension, 161.8, 261.8, 100.0, 361.8)
            fibScoreAccumulator += w3FibScore
            fibScoreKnownCount += 1

        if primaryLockedCount >= 5 and not na(primaryW4Depth)
            float w4FibScore =
                 ewCore.relationScore(primaryW4Depth, 23.6, 50.0, 14.6, 61.8)
            fibScoreAccumulator += w4FibScore
            fibScoreKnownCount += 1

        if primaryLockedCount >= 6 and not na(primaryW5Ratio)
            float w5FibScore =
                 ewCore.relationScore(primaryW5Ratio, 80.0, 120.0, 61.8, 161.8)
            fibScoreAccumulator += w5FibScore
            fibScoreKnownCount += 1

        if fibScoreKnownCount > 0
            primaryFibQuality := fibScoreAccumulator / fibScoreKnownCount

    string activeFibStage = "N/A"
    float activeFibZoneTop = na
    float activeFibZoneBottom = na
    int activeFvgSourceStartBar = na
    int activeFvgSourceEndBar = na
    int activeFvgDirection = 0

    if primaryKey != "" and (primaryLockedCount == 2 or primaryLockedCount == 3)
        activeFibStage := "WAVE 2 ZONE"
        activeFibZoneTop := math.max(fibW2_500, fibW2_618)
        activeFibZoneBottom := math.min(fibW2_500, fibW2_618)
        activeFvgSourceStartBar := pb0
        activeFvgSourceEndBar := pb1
        activeFvgDirection := primaryDirection
    else if primaryKey != "" and (primaryLockedCount == 4 or primaryLockedCount == 5)
        activeFibStage := "WAVE 4 ZONE"
        activeFibZoneTop := math.max(fibW4_236, fibW4_500)
        activeFibZoneBottom := math.min(fibW4_236, fibW4_500)
        activeFvgSourceStartBar := pb2
        activeFvgSourceEndBar := pb3
        activeFvgDirection := primaryDirection
    else if correctionSourceKey != "" and not correctionConfirmed
        if correctionCommittedCount == 0
            activeFibStage := correctionHasProvisional ?
                 "A DEVELOPING · WAIT A CONFIRM" : "WAIT A"
        else if correctionCommittedCount == 1
            activeFibStage := "B POTENTIAL · 38.2-78.6% A"
            activeFibZoneTop := math.max(correctionB382, correctionB786)
            activeFibZoneBottom := math.min(correctionB382, correctionB786)
        else if correctionCommittedCount == 2
            activeFibStage := "C TARGETS · 61.8 / 100 / 161.8% A"
        else
            activeFibStage := "CORRECTION VALIDATION"

    // Update retained FVG lifecycle.
    if array.size(fvgOriginalTops) > 0
        for fvgIndex = array.size(fvgOriginalTops) - 1 to 0
            float originalTop = array.get(fvgOriginalTops, fvgIndex)
            float originalBottom = array.get(fvgOriginalBottoms, fvgIndex)
            float liveTop = array.get(fvgLiveTops, fvgIndex)
            float liveBottom = array.get(fvgLiveBottoms, fvgIndex)
            int gapDirection = array.get(fvgDirections, fvgIndex)
            int birthBar = array.get(fvgBirthBars, fvgIndex)
            bool fullyFilled = false

            if currentBar > birthBar
                if gapDirection == 1
                    if currentLow <= originalBottom
                        fullyFilled := true
                    else if currentLow < liveTop
                        array.set(fvgLiveTops, fvgIndex, math.max(originalBottom, currentLow))
                else
                    if currentHigh >= originalTop
                        fullyFilled := true
                    else if currentHigh > liveBottom
                        array.set(fvgLiveBottoms, fvgIndex, math.min(originalTop, currentHigh))

            bool expired = currentBar - birthBar > effectiveFvgMaxAge

            if fullyFilled or expired
                array.remove(fvgOriginalTops, fvgIndex)
                array.remove(fvgOriginalBottoms, fvgIndex)
                array.remove(fvgLiveTops, fvgIndex)
                array.remove(fvgLiveBottoms, fvgIndex)
                array.remove(fvgDirections, fvgIndex)
                array.remove(fvgBirthBars, fvgIndex)

    float fvgThreshold = effectiveFvgMinAtr * atrValue
    bool newBullFvg =
         fvgEngineOn and currentBar >= 2 and high[2] < low and
         low - high[2] >= fvgThreshold
    bool newBearFvg =
         fvgEngineOn and currentBar >= 2 and low[2] > high and
         low[2] - high >= fvgThreshold

    if newBullFvg
        array.push(fvgOriginalTops, currentLow)
        array.push(fvgOriginalBottoms, high[2])
        array.push(fvgLiveTops, currentLow)
        array.push(fvgLiveBottoms, high[2])
        array.push(fvgDirections, 1)
        array.push(fvgBirthBars, currentBar)

    if newBearFvg
        array.push(fvgOriginalTops, low[2])
        array.push(fvgOriginalBottoms, currentHigh)
        array.push(fvgLiveTops, low[2])
        array.push(fvgLiveBottoms, currentHigh)
        array.push(fvgDirections, -1)
        array.push(fvgBirthBars, currentBar)

    while array.size(fvgOriginalTops) > maxStoredFvgs
        array.shift(fvgOriginalTops)
        array.shift(fvgOriginalBottoms)
        array.shift(fvgLiveTops)
        array.shift(fvgLiveBottoms)
        array.shift(fvgDirections)
        array.shift(fvgBirthBars)

    [selectedFvgTop,
     selectedFvgBottom,
     selectedFvgBirthBar,
     selectedFvgRemainingPct,
     selectedFvgAge,
     selectedFvgRank] =
         _findBestFvg(
             fvgOriginalTops,
             fvgOriginalBottoms,
             fvgLiveTops,
             fvgLiveBottoms,
             fvgDirections,
             fvgBirthBars,
             fvgEngineOn,
             activeFibZoneTop,
             activeFibZoneBottom,
             activeFvgDirection,
             activeFvgSourceStartBar,
             activeFvgSourceEndBar,
             fvgRequireSourceLeg,
             effectiveFvgMaxAge,
             mintick,
             currentBar)

    bool primaryFreshFvgPresent =
         not na(selectedFvgTop) and not na(selectedFvgBottom) and
         not na(selectedFvgRemainingPct) and
         selectedFvgRemainingPct >= fvgMinRemainingPct

    float primaryFvgScore = na

    if not na(selectedFvgRemainingPct)
        float ageScore =
             100.0 -
             math.min(
                 nz(selectedFvgAge, effectiveFvgMaxAge) * 100.0 /
                 math.max(effectiveFvgMaxAge, 1),
                 100.0)
        primaryFvgScore :=
             _clamp(
                 selectedFvgRemainingPct * 0.70 +
                 ageScore * 0.30,
                 0.0,
                 100.0)

    string primaryFvgStatus =
         not fvgEngineOn ? "OFF" :
         activeFvgDirection == 0 ? "N/A" :
         na(selectedFvgRemainingPct) ? "NO SOURCE-LEG FVG" :
         primaryFreshFvgPresent ?
             "FRESH +FVG  " + _pct(selectedFvgRemainingPct) :
             "WEAK / FILLED  " + _pct(selectedFvgRemainingPct)

    float primaryModelScore = na

    if primaryKey != "" and not na(primaryQuality)
        if not na(primaryFibQuality) and not na(primaryFvgScore) and activeFvgDirection != 0
            primaryModelScore :=
                 primaryQuality * 0.45 +
                 primaryFibQuality * 0.35 +
                 primaryFvgScore * 0.20
        else if not na(primaryFibQuality)
            primaryModelScore =
                 primaryQuality * 0.58 +
                 primaryFibQuality * 0.42
        else
            primaryModelScore := primaryQuality

        primaryModelScore := _clamp(primaryModelScore, 0.0, 100.0)

    bool freshFvgConfluenceNow =
         primaryFreshFvgPresent and not primaryFreshFvgPresent[1]

    [fibW2_382, fibW2_500, fibW2_618, fibW2_786,
     fibW3_1618, fibW3_2618,
     fibW4_236, fibW4_382, fibW4_500, fibW4_618,
     fibW5_equalW1, fibW5_618Net03,
     correctionAConfirmed, correctionBConfirmed,
     correctionB382, correctionB500, correctionB618, correctionB786,
     correctionB900, correctionB100,
     correctionBLiveRetracement, correctionBExtremeReassess,
     correctionFamilyWatch, correctionForecastSequenceIntact,
     correctionC618, correctionC100, correctionC1618,
     correctionC618Consumed, correctionC100Consumed, correctionC1618Consumed,
     primaryFibQuality,
     activeFibStage, activeFibZoneTop, activeFibZoneBottom,
     activeFvgSourceStartBar,
     selectedFvgTop, selectedFvgBottom, selectedFvgBirthBar,
     selectedFvgRemainingPct, selectedFvgAge,
     primaryFreshFvgPresent, primaryFvgScore, primaryFvgStatus,
     primaryModelScore, freshFvgConfluenceNow]
````
