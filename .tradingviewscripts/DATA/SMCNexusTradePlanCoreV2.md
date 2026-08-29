<!-- tradingview-pine-id: PUB;d42464c677794153bb6c735ef51d818e -->
<!-- tradingviewscripts-format: 1 -->
# SMCNexusTradePlanCoreV2

Source: https://www.tradingview.com/script/cvF7O1Gp/

## Description

SMCNexusTradePlanCoreV2 is an open-source, non-visual Pine Script library for deterministic candidate-plan geometry.

The library receives already-detected market facts from an importing indicator and resolves candidate Entry, protective Stop Loss, real target clusters, risk-to-reward values, confluence and fail-closed plan validity.

It does not scan the chart independently, predict future prices, generate guaranteed signals, place orders or fabricate missing levels. The importing indicator remains responsible for detecting and confirming market structure, zones, liquidity, pivots and other market facts.

ORIGINAL CONCEPT AND PURPOSE

The library converts confirmed analytical facts into auditable candidate-plan geometry using fixed source priorities and strict validation rules.

Every Entry, Stop Loss and target must originate from a real level supplied by the importing indicator. Missing or contradictory information remains unavailable instead of being replaced with a synthetic price.

ENTRY RESOLUTION

The candidate direction is derived from the primary bias supplied by the importing indicator.

For a BUY candidate, the Entry zone is selected from the first available source in this fixed order:

1. Bullish Order Block  
2. Bullish Fair Value Gap  
3. Discount half of the current dealing range  
4. S1 pivot

For a SELL candidate, the fixed order is:

1. Bearish Order Block  
2. Bearish Fair Value Gap  
3. Premium half of the current dealing range  
4. R1 pivot

The candidate Entry is the midpoint of the selected zone. A single-price pivot remains a single-price zone.

The library does not search for the best historical result and does not reorder sources according to later price movement.

STOP LOSS RESOLUTION

Stop Loss candidates are checked using a fixed protective hierarchy.

For BUY candidates, a valid Stop Loss must be below Entry. For SELL candidates, it must be above Entry.

The available candidates are checked in this order:

1. Opposite-side liquidity level  
2. Direction-matching Order Block edge  
3. Dealing-range edge  
4. Directional pivot

A candidate located on the wrong side of Entry is skipped without changing the priority of the remaining sources.

If no supplied level is directionally valid, Stop Loss remains unavailable. The library never creates a Stop Loss from a fixed percentage or an arbitrary distance.

REAL TARGET SELECTION

Targets must be genuine levels supplied by the importing indicator.

Possible sources may include:

• liquidity pools,  
• opposing Order Blocks,  
• opposing Fair Value Gaps,  
• confirmed swing levels,  
• pivots,  
• Premium, Discount or Equilibrium levels.

The importing indicator owns one bounded TargetCandidate array and decides which confirmed levels are eligible.

Each candidate contains:

• real price,  
• source identifier,  
• origin type,  
• stable origin key,  
• confirmation bar,  
• direction,  
• active state.

Candidates located on the wrong side of Entry are rejected. The origin used for Entry or Stop Loss can also be excluded from the target collection.

TARGET CLUSTERING

Several analytical sources may describe practically the same price area. The library groups nearby candidates into separate clusters using a caller-provided distance.

The distance can be calculated from ATR using clusterDistance(). ATR controls cluster separation only. It never creates, moves or estimates a target price.

The nearest real representative from the first separate cluster becomes TP1. The nearest representative outside the TP1 cluster becomes TP2. The nearest representative outside the first two clusters becomes TP3.

Every selected target is therefore an actual price supplied by the importing indicator.

STABLE ORIGIN KEYS

The library provides helpers for creating auditable source identities:

• zoneKey(...)  
• liquidityKey(...)  
• swingKey(...)  
• pdKey(...)  
• pivotKey(...)

These keys help the importing indicator identify duplicate sources and prevent the same analytical object from being reused incorrectly.

FINAL VALIDATION

The final resolver calculates:

• risk distance,  
• reward to TP1, TP2 and TP3,  
• RR1, RR2 and RR3,  
• candidate order type,  
• latest structural confirmation,  
• directional confluence,  
• final sanity status.

The geometry must satisfy all required conditions:

• Entry and Stop Loss are available,  
• Stop Loss is on the protective side of Entry,  
• targets are on the correct side of Entry,  
• targets are ordered nearest-to-farthest,  
• required target data is complete.

Invalid geometry returns a specific fail-closed status instead of displaying an apparently valid plan.

PUBLIC API

Typed records:

• EntryResult  
• TargetCandidate  
• TargetSelection  
• FinalResult

Exported functions:

• resolveEntry(...)  
• sameLevel(...)  
• zoneKey(...)  
• liquidityKey(...)  
• swingKey(...)  
• pdKey(...)  
• pivotKey(...)  
• addCandidate(...)  
• selectTargets(...)  
• clusterDistance(...)  
• riskDistance(...)  
• resolveFinal(...)

INTENDED USE

The importing indicator should:

1. Detect and confirm its own structure, zones, liquidity and pivots.
2. Pass the current facts to resolveEntry().
3. Add only genuine eligible levels to one bounded candidate array.
4. Call selectTargets() using an explicit cluster distance.
5. Pass Entry, Stop Loss, targets and contextual facts to resolveFinal().
6. Display a candidate only when the returned validity state permits it.

Conceptual example:

```pine
import AreXoN_/SMCNexusTradePlanCoreV2/1 as plan

plan.EntryResult entry = plan.resolveEntry(
    primaryBias,
    bullishObActive, bullishObHigh, bullishObLow,
    bearishObActive, bearishObHigh, bearishObLow,
    bullishFvgActive, bullishFvgHigh, bullishFvgLow,
    bearishFvgActive, bearishFvgHigh, bearishFvgLow,
    dealingRangeValid, dealingRangeHigh, dealingRangeLow,
    equilibrium,
    pivotS1Available, pivotS1,
    pivotR1Available, pivotR1,
    lastSsl, lastBsl)

array<plan.TargetCandidate> candidates =
    array.new<plan.TargetCandidate>()

// Add only confirmed real levels detected by the importing indicator.

float distance = plan.clusterDistance(atrValue, 0.55)

plan.TargetSelection targets =
    plan.selectTargets(
        candidates,
        entry.isBuy ? 1 : -1,
        distance)
```

The example import path should be replaced with the exact path assigned by TradingView after publication.

WHY THE CHART IS CLEAN

This is a non-visual calculation library. It intentionally creates no plots, labels, tables, lines or boxes.

The publication chart is therefore intentionally clean and contains no additional indicators, drawings or unexplained visual elements. Visual presentation is the responsibility of an importing indicator.

LIMITATIONS

• The result depends entirely on the confirmed facts supplied by the importing indicator.  
• It is a mechanical analytical candidate, not a recommendation.  
• It cannot verify live spread, slippage, broker StopLevel or execution rules.  
• It does not provide native bid/ask order flow.  
• It does not place, modify or close orders.  
• Missing real levels produce an incomplete result by design.  
• Risk-to-reward values describe supplied geometry and do not predict outcome.  
• It produces no chart output by itself.

This library is an analytical and software-development component. It is not investment advice, a trading recommendation or an automated trading system.

---

## Source Code

````pine
//@version=6
library("SMCNexusTradePlanCoreV2", overlay = true)

// Open-source non-visual plan-geometry library. See docs/TRADINGVIEW_LIBRARY_REPUBLICATION.md.
// It contains only deterministic M16/M37 resolution. Every live market and
// module value is supplied by the importing indicator through typed arguments.

export type EntryResult
    string direction
    bool isBuy
    bool isSell
    bool bullishObAvailable
    bool bearishObAvailable
    bool bullishFvgAvailable
    bool bearishFvgAvailable
    bool buyPdAvailable
    bool sellPdAvailable
    bool buyPivotAvailable
    bool sellPivotAvailable
    float entryZoneLow
    float entryZoneHigh
    float entry
    float sl
    bool slDirectionValid

export type TargetCandidate
    float price
    string sourceId
    string originKind
    string originKey
    int confirmedBar
    int direction
    bool active
    int priceRank

export type TargetSelection
    float tp1
    string tp1SourceId
    string tp1OriginKey
    float tp2
    string tp2SourceId
    string tp2OriginKey
    float tp3
    string tp3SourceId
    string tp3OriginKey
    int validTargetCount

export type FinalResult
    bool tpOrderValid
    float riskPoints
    float rewardTp1
    float rewardTp2
    float rewardTp3
    float rr1
    float rr2
    float rr3
    bool entryAtMarket
    string orderType
    bool hasBosConfirmation
    bool hasMssConfirmation
    bool latestStructureIsMss
    string latestStructureDirection
    bool confluenceDirectional
    bool confluenceBiasPass
    bool confluenceTrendPass
    bool confluenceZonePass
    bool confluencePdPass
    bool confluenceStructurePass
    bool confluenceVolumePass
    int confluenceTotal
    int confluenceCount
    string confluenceText
    string sanityStatus
    string sanityReason
    bool completeForDashboard
    string plannerStatus

slCandidateValid(float candidate, float entry, bool isBuy, bool isSell) =>
    not na(candidate) and not na(entry) and (isBuy ? candidate < entry : isSell ? candidate > entry : false)

firstValidSl(float candidate1, float candidate2, float candidate3, float candidate4, float entry, bool isBuy, bool isSell) =>
    float selected = na
    if slCandidateValid(candidate1, entry, isBuy, isSell)
        selected := candidate1
    else if slCandidateValid(candidate2, entry, isBuy, isSell)
        selected := candidate2
    else if slCandidateValid(candidate3, entry, isBuy, isSell)
        selected := candidate3
    else if slCandidateValid(candidate4, entry, isBuy, isSell)
        selected := candidate4
    selected

export resolveEntry(string primaryBias, bool bullishObActive, float bullishObHigh, float bullishObLow, bool bearishObActive, float bearishObHigh, float bearishObLow, bool bullishFvgActive, float bullishFvgHigh, float bullishFvgLow, bool bearishFvgActive, float bearishFvgHigh, float bearishFvgLow, bool pdRangeValid, float pdRangeHigh, float pdRangeLow, float pdEquilibrium, bool pivotS1Available, float pivotS1, bool pivotR1Available, float pivotR1, float lastSslLevel, float lastBslLevel) =>
    string direction = str.contains(primaryBias, "BUY") ? "BUY" : str.contains(primaryBias, "SELL") ? "SELL" : "NEUTRAL"
    bool isBuy = direction == "BUY"
    bool isSell = direction == "SELL"
    bool bullishObAvailable = bullishObActive and not na(bullishObHigh) and not na(bullishObLow)
    bool bearishObAvailable = bearishObActive and not na(bearishObHigh) and not na(bearishObLow)
    bool bullishFvgAvailable = bullishFvgActive and not na(bullishFvgHigh) and not na(bullishFvgLow)
    bool bearishFvgAvailable = bearishFvgActive and not na(bearishFvgHigh) and not na(bearishFvgLow)
    bool buyPdAvailable = pdRangeValid and not na(pdRangeLow) and not na(pdEquilibrium)
    bool sellPdAvailable = pdRangeValid and not na(pdRangeHigh) and not na(pdEquilibrium)
    bool buyPivotAvailable = pivotS1Available
    bool sellPivotAvailable = pivotR1Available
    float entryZoneLow = isBuy ? bullishObAvailable ? math.min(bullishObLow, bullishObHigh) : bullishFvgAvailable ? math.min(bullishFvgLow, bullishFvgHigh) : buyPdAvailable ? math.min(pdRangeLow, pdEquilibrium) : buyPivotAvailable ? pivotS1 : na : isSell ? bearishObAvailable ? math.min(bearishObLow, bearishObHigh) : bearishFvgAvailable ? math.min(bearishFvgLow, bearishFvgHigh) : sellPdAvailable ? math.min(pdEquilibrium, pdRangeHigh) : sellPivotAvailable ? pivotR1 : na : na
    float entryZoneHigh = isBuy ? bullishObAvailable ? math.max(bullishObLow, bullishObHigh) : bullishFvgAvailable ? math.max(bullishFvgLow, bullishFvgHigh) : buyPdAvailable ? math.max(pdRangeLow, pdEquilibrium) : buyPivotAvailable ? pivotS1 : na : isSell ? bearishObAvailable ? math.max(bearishObLow, bearishObHigh) : bearishFvgAvailable ? math.max(bearishFvgLow, bearishFvgHigh) : sellPdAvailable ? math.max(pdEquilibrium, pdRangeHigh) : sellPivotAvailable ? pivotR1 : na : na
    float entry = not na(entryZoneLow) and not na(entryZoneHigh) ? (entryZoneLow + entryZoneHigh) / 2.0 : na
    float sl = isBuy ? firstValidSl(lastSslLevel, bullishObAvailable ? bullishObLow : na, pdRangeValid ? pdRangeLow : na, buyPivotAvailable ? pivotS1 : na, entry, isBuy, isSell) : isSell ? firstValidSl(lastBslLevel, bearishObAvailable ? bearishObHigh : na, pdRangeValid ? pdRangeHigh : na, sellPivotAvailable ? pivotR1 : na, entry, isBuy, isSell) : na
    bool slDirectionValid = not na(entry) and not na(sl) and (isBuy ? sl < entry : isSell ? sl > entry : false)
    EntryResult.new(direction, isBuy, isSell, bullishObAvailable, bearishObAvailable, bullishFvgAvailable, bearishFvgAvailable, buyPdAvailable, sellPdAvailable, buyPivotAvailable, sellPivotAvailable, entryZoneLow, entryZoneHigh, entry, sl, slDirectionValid)

export sameLevel(float a, float b, float minimumTick) =>
    not na(a) and not na(b) and math.abs(a - b) <= minimumTick * 0.5

export zoneKey(string kind, int direction, int createdBar) =>
    kind + ":" + str.tostring(direction) + ":" + str.tostring(createdBar)

export liquidityKey(string side, int originBar, float price) =>
    "LIQ_" + side + ":" + str.tostring(originBar) + ":" + str.tostring(price, format.mintick)

export swingKey(string side, int originBar, float price) =>
    "SWING_" + side + ":" + str.tostring(originBar) + ":" + str.tostring(price, format.mintick)

export pdKey(int rangeHighBar, int rangeLowBar) =>
    "PD:" + str.tostring(rangeHighBar) + ":" + str.tostring(rangeLowBar)

export pivotKey(string anchorCode, string familyCode, string sourceId, int anchorPeriodOpenTime) =>
    "PIVOT:" + anchorCode + ":" + familyCode + ":" + sourceId + ":" + str.tostring(anchorPeriodOpenTime)

candidateDirectionValid(float price, float entry, int direction) =>
    not na(price) and not na(entry) and (direction == 1 ? price > entry : direction == -1 ? price < entry : false)

export addCandidate(array<TargetCandidate> candidates, int candidateCap, float price, string sourceId, string originKind, string originKey, int confirmedBar, int direction, bool active, float entry, string entryOriginKey, string slOriginKey) =>
    bool eligible = active and candidateDirectionValid(price, entry, direction) and originKey != entryOriginKey and originKey != slOriginKey
    if eligible and array.size(candidates) < candidateCap
        array.push(candidates, TargetCandidate.new(price=price, sourceId=sourceId, originKind=originKind, originKey=originKey, confirmedBar=confirmedBar, direction=direction, active=true, priceRank=0))
    eligible

selectClusterRepresentative(array<TargetCandidate> candidates, int direction, float clusterDistance, float previousRepresentative1, float previousRepresentative2) =>
    float selectedPrice = na
    string selectedSourceId = "NONE"
    string selectedOriginKey = "NONE"
    if not na(clusterDistance) and clusterDistance >= 0 and array.size(candidates) > 0
        for selectionIndex = 0 to array.size(candidates) - 1
            TargetCandidate candidate = array.get(candidates, selectionIndex)
            bool outsideFirstCluster = na(previousRepresentative1) or math.abs(candidate.price - previousRepresentative1) > clusterDistance
            bool outsideSecondCluster = na(previousRepresentative2) or math.abs(candidate.price - previousRepresentative2) > clusterDistance
            bool nearerThanSelected = na(selectedPrice) or (direction == 1 ? candidate.price < selectedPrice : candidate.price > selectedPrice)
            if candidate.active and outsideFirstCluster and outsideSecondCluster and nearerThanSelected
                selectedPrice := candidate.price
                selectedSourceId := candidate.sourceId
                selectedOriginKey := candidate.originKey
    [selectedPrice, selectedSourceId, selectedOriginKey]

export selectTargets(array<TargetCandidate> candidates, int direction, float clusterDistance) =>
    [tp1, tp1SourceId, tp1OriginKey] = selectClusterRepresentative(candidates, direction, clusterDistance, na, na)
    [tp2, tp2SourceId, tp2OriginKey] = selectClusterRepresentative(candidates, direction, clusterDistance, tp1, na)
    [tp3, tp3SourceId, tp3OriginKey] = selectClusterRepresentative(candidates, direction, clusterDistance, tp1, tp2)
    int validTargetCount = (not na(tp1) ? 1 : 0) + (not na(tp2) ? 1 : 0) + (not na(tp3) ? 1 : 0)
    TargetSelection.new(tp1, tp1SourceId, tp1OriginKey, tp2, tp2SourceId, tp2OriginKey, tp3, tp3SourceId, tp3OriginKey, validTargetCount)

export clusterDistance(float atrValue, float multiplier) =>
    not na(atrValue) and atrValue > 0 ? atrValue * multiplier : na

export riskDistance(bool slDirectionValid, float entry, float sl) =>
    slDirectionValid ? math.abs(entry - sl) : na

export resolveFinal(string direction, bool isBuy, bool isSell, float entry, float sl, bool slDirectionValid, float tp1, float tp2, float tp3, int validTargetCount, float currentClose, float minimumTick, string currentBias, string primaryTrend, bool bullishObAvailable, bool bearishObAvailable, bool bullishFvgAvailable, bool bearishFvgAvailable, string premiumDiscountZone, bool volumeEnabled, string volumeState, string bosType, int bosBarIndex, string bosDirection, string mssType, int mssBarIndex, string mssDirection) =>
    bool tpOrderValid = not na(entry) and not na(tp1) and not na(tp2) and not na(tp3) and (isBuy ? entry < tp1 and tp1 < tp2 and tp2 < tp3 : isSell ? entry > tp1 and tp1 > tp2 and tp2 > tp3 : false)
    float riskPoints = slDirectionValid and tpOrderValid ? isBuy ? entry - sl : isSell ? sl - entry : na : na
    float rewardTp1 = tpOrderValid ? isBuy ? tp1 - entry : isSell ? entry - tp1 : na : na
    float rewardTp2 = tpOrderValid ? isBuy ? tp2 - entry : isSell ? entry - tp2 : na : na
    float rewardTp3 = tpOrderValid ? isBuy ? tp3 - entry : isSell ? entry - tp3 : na : na
    float rr1 = not na(riskPoints) and riskPoints > 0 and not na(rewardTp1) and rewardTp1 > 0 ? rewardTp1 / riskPoints : na
    float rr2 = not na(riskPoints) and riskPoints > 0 and not na(rewardTp2) and rewardTp2 > 0 ? rewardTp2 / riskPoints : na
    float rr3 = not na(riskPoints) and riskPoints > 0 and not na(rewardTp3) and rewardTp3 > 0 ? rewardTp3 / riskPoints : na
    bool entryAtMarket = not na(entry) and math.abs(currentClose - entry) <= minimumTick
    string orderType = not (isBuy or isSell) or na(entry) ? "—" : isBuy ? entryAtMarket ? "MARKET BUY" : entry < currentClose ? "BUY LIMIT" : "BUY STOP" : entryAtMarket ? "MARKET SELL" : entry > currentClose ? "SELL LIMIT" : "SELL STOP"
    bool hasBosConfirmation = bosType != "na" and not na(bosBarIndex)
    bool hasMssConfirmation = mssType != "na" and not na(mssBarIndex)
    bool latestStructureIsMss = hasMssConfirmation and (not hasBosConfirmation or mssBarIndex >= bosBarIndex)
    string latestStructureDirection = latestStructureIsMss ? mssDirection : hasBosConfirmation ? bosDirection == "up" ? "bullish" : bosDirection == "down" ? "bearish" : "na" : "na"
    bool confluenceDirectional = isBuy or isSell
    bool confluenceBiasPass = isBuy ? str.contains(currentBias, "BUY") : isSell ? str.contains(currentBias, "SELL") : false
    bool confluenceTrendPass = isBuy ? primaryTrend == "BUY" or primaryTrend == "STRONG BUY" : isSell ? primaryTrend == "SELL" or primaryTrend == "STRONG SELL" : false
    bool confluenceZonePass = isBuy ? bullishObAvailable or bullishFvgAvailable : isSell ? bearishObAvailable or bearishFvgAvailable : false
    bool confluencePdPass = isBuy ? premiumDiscountZone == "DISCOUNT" : isSell ? premiumDiscountZone == "PREMIUM" : false
    bool confluenceStructurePass = isBuy ? latestStructureDirection == "bullish" : isSell ? latestStructureDirection == "bearish" : false
    bool confluenceVolumePass = volumeEnabled and volumeState == "CONFIRMED"
    int confluenceTotal = volumeEnabled ? 6 : 5
    int confluenceCount = confluenceDirectional ? (confluenceBiasPass ? 1 : 0) + (confluenceTrendPass ? 1 : 0) + (confluenceZonePass ? 1 : 0) + (confluencePdPass ? 1 : 0) + (confluenceStructurePass ? 1 : 0) + (volumeEnabled and confluenceVolumePass ? 1 : 0) : 0
    string confluenceText = confluenceDirectional ? str.tostring(confluenceCount) + "/" + str.tostring(confluenceTotal) : "—"
    string sanityStatus = direction == "NEUTRAL" or na(entry) or na(sl) ? "INCOMPLETE" : not slDirectionValid ? "INVALID_SL_DIRECTION" : validTargetCount < 3 ? "INSUFFICIENT_TARGETS" : not tpOrderValid ? "INVALID_TP_ORDER" : "VALID"
    string sanityReason = sanityStatus == "VALID" ? "Trade plan entry, SL and three real clustered targets are valid." : sanityStatus == "INVALID_SL_DIRECTION" ? "SL is on the wrong side of Entry for the selected direction." : sanityStatus == "INVALID_TP_ORDER" ? "TP levels are not ordered nearest-to-farthest from Entry." : sanityStatus == "INSUFFICIENT_TARGETS" ? "Fewer than three separate real target clusters exist on the correct side of Entry." : "Direction, Entry or SL is missing."
    bool completeForDashboard = sanityStatus == "VALID"
    string plannerStatus = sanityStatus == "VALID" ? "PLANNING_READY_WITH_WARNINGS" : sanityStatus
    FinalResult.new(tpOrderValid, riskPoints, rewardTp1, rewardTp2, rewardTp3, rr1, rr2, rr3, entryAtMarket, orderType, hasBosConfirmation, hasMssConfirmation, latestStructureIsMss, latestStructureDirection, confluenceDirectional, confluenceBiasPass, confluenceTrendPass, confluenceZonePass, confluencePdPass, confluenceStructurePass, confluenceVolumePass, confluenceTotal, confluenceCount, confluenceText, sanityStatus, sanityReason, completeForDashboard, plannerStatus)
````
