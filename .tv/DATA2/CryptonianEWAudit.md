<!-- tradingview-pine-id: PUB;4f9f74720fb24a099c546ba2ba18e247 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CryptonianEWAudit

Source: https://www.tradingview.com/script/UaFqPw3y-CryptonianEWAudit/

## Description

Library  "CryptonianEWAudit"
Cryptonian Elliott Wave Audit /1. Owns production integrity auditing, compact event-state construction, universal-event aggregation and alert deduplication for the library-first Elliott architecture. The audit rules are migrated from Elliott Wave Engine 11.8b2 without changing Elliott or trade methodology.

addUniqueLimited(values, value, maximumSize)
  Adds one unique string and caps the registry size.
  Parameters:
    values (array<string>)
    value (string)
    maximumSize (int)

eventOnce(eventRegistry, eventCondition, eventName, sourceKey, maximumSize, deduplicate)
  Generic event de-duplication helper. This preserves the 11.8b2 event
key contract: eventName | sourceKey | time.
  Parameters:
    eventRegistry (array<string>)
    eventCondition (bool)
    eventName (string)
    sourceKey (string)
    maximumSize (int)
    deduplicate (bool)

eventState(lastEvent, currentCountKey, lastInvalidCountKey, forecastKey, tradeId, countStarted, countRevised, countInvalidated, forecastNew, forecastRevised, forecastInvalidated, tradeWaiting, tradeActivated, tradeResolved, tradeCountInvalidExit)
  Creates the shared Model.EventState. The code field is a bit-mask for
future audit/UI use; the named booleans remain the authoritative contract.
  Parameters:
    lastEvent (string)
    currentCountKey (string)
    lastInvalidCountKey (string)
    forecastKey (string)
    tradeId (string)
    countStarted (bool)
    countRevised (bool)
    countInvalidated (bool)
    forecastNew (bool)
    forecastRevised (bool)
    forecastInvalidated (bool)
    tradeWaiting (bool)
    tradeActivated (bool)
    tradeResolved (bool)
    tradeCountInvalidExit (bool)

tradeLifecycleEvent(resolution)
  True when Trade's per-bar resolution contains any lifecycle event.
TP1 is intentionally included even when the trade remains live because 11.8b2
treats TP1 as an alert-worthy lifecycle event.
  Parameters:
    resolution (TradeResolution type from AYEHAN/CryptonianEWModel/1)

productionAudit(pivotPrices, pivotBars, pivotTimes, pivotTypes, pivotIds, nestedPivotPrices, nestedPivotTimes, fvgOriginalTops, fvgOriginalBottoms, fvgLiveTops, fvgLiveBottoms, fvgDirections, fvgBirthBars, tradeActivationCount, tradeResolutionCount, tradeProfitableResolutions, tradeLosingResolutions, tradeFlatResolutions, tradeCancelled, tradeWaitingCancellationCount, tradeTp1ReachedCount, tradeTp2ReachedCount, tradeLive, tradeSetupId, tradeDirection, tradeEntry, tradeStop, tradeTp1)
  Runs the original 11.8b2 production audit and owns persistent issue
history internally. Call this once per host bar.
  Parameters:
    pivotPrices (array<float>)
    pivotBars (array<int>)
    pivotTimes (array<int>)
    pivotTypes (array<int>)
    pivotIds (array<int>)
    nestedPivotPrices (array<float>)
    nestedPivotTimes (array<int>)
    fvgOriginalTops (array<float>)
    fvgOriginalBottoms (array<float>)
    fvgLiveTops (array<float>)
    fvgLiveBottoms (array<float>)
    fvgDirections (array<int>)
    fvgBirthBars (array<int>)
    tradeActivationCount (int)
    tradeResolutionCount (int)
    tradeProfitableResolutions (int)
    tradeLosingResolutions (int)
    tradeFlatResolutions (int)
    tradeCancelled (int)
    tradeWaitingCancellationCount (int)
    tradeTp1ReachedCount (int)
    tradeTp2ReachedCount (int)
    tradeLive (bool)
    tradeSetupId (string)
    tradeDirection (int)
    tradeEntry (float)
    tradeStop (float)
    tradeTp1 (float)

universalEventRaw(events, committedPivotNow, impulseCompletedNow, correctionCompletedNow, freshFvgConfluenceNow, mtfContextChangedNow, mtfPrimaryGateReadyNow, tradeLifecycleNow, forecastAuditTargetHit, primaryW5TargetHitNow, productionStructuralGate, productionTradeActivationGate, productionAuditChangedNow)
  Reproduces the 11.8b2 universal-event OR tree using the compact shared
EventState plus the few event families not represented by Model /1.
  Parameters:
    events (EventState type from AYEHAN/CryptonianEWModel/1)
    committedPivotNow (bool)
    impulseCompletedNow (bool)
    correctionCompletedNow (bool)
    freshFvgConfluenceNow (bool)
    mtfContextChangedNow (bool)
    mtfPrimaryGateReadyNow (bool)
    tradeLifecycleNow (bool)
    forecastAuditTargetHit (bool)
    primaryW5TargetHitNow (bool)
    productionStructuralGate (bool)
    productionTradeActivationGate (bool)
    productionAuditChangedNow (bool)

universalAlert(rawEvent, maximumSize, deduplicate)
  Stateful universal alert. The registry lives in Audit /1 rather than
the indicator host. This preserves 11.8b2's ANY_EW_EVENT | bar_index | time key.
Call once per host bar, then feed .fire to the single alertcondition().
  Parameters:
    rawEvent (bool)
    maximumSize (int)
    deduplicate (bool)

processUniversalAlert(events, committedPivotNow, impulseCompletedNow, correctionCompletedNow, freshFvgConfluenceNow, mtfContextChangedNow, mtfPrimaryGateReadyNow, tradeLifecycleNow, forecastAuditTargetHit, primaryW5TargetHitNow, productionStructuralGate, productionTradeActivationGate, productionAuditChangedNow, maximumSize, deduplicate)
  Convenience wrapper: aggregate + deduplicate in one host call.
  Parameters:
    events (EventState type from AYEHAN/CryptonianEWModel/1)
    committedPivotNow (bool)
    impulseCompletedNow (bool)
    correctionCompletedNow (bool)
    freshFvgConfluenceNow (bool)
    mtfContextChangedNow (bool)
    mtfPrimaryGateReadyNow (bool)
    tradeLifecycleNow (bool)
    forecastAuditTargetHit (bool)
    primaryW5TargetHitNow (bool)
    productionStructuralGate (bool)
    productionTradeActivationGate (bool)
    productionAuditChangedNow (bool)
    maximumSize (int)
    deduplicate (bool)

ProductionAuditState
  Complete production-integrity result. Individual checks are retained so
  Fields:
    pass (series bool)
    status (series string)
    currentIssue (series string)
    signature (series string)
    unresolvedActivations (series int)
    issueCount (series int)
    lastIssue (series string)
    changedNow (series bool)
    pivotArraysAligned (series bool)
    nestedArraysAligned (series bool)
    fvgArraysAligned (series bool)
    tradeAccounting (series bool)
    tradeResultAccounting (series bool)
    cancellationAccounting (series bool)
    liveIdentity (series bool)
    liveOrdering (series bool)
    tp1Accounting (series bool)

UniversalEventState
  Compact result from the universal Elliott event aggregator.
  Fields:
    raw (series bool)
    fire (series bool)
    key (series string)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AYEHAN

//@version=6
// @description Cryptonian Elliott Wave Audit /1. Owns production integrity auditing, compact event-state construction, universal-event aggregation and alert deduplication for the library-first Elliott architecture. The audit rules are migrated from Elliott Wave Engine 11.8b2 without changing Elliott or trade methodology.
library("CryptonianEWAudit", overlay = true)

import AYEHAN/CryptonianEWModel/1 as ewModel

// ═════════════════════════════════════════════════════════════════════════════
// CRYPTONIAN ELLIOTT WAVE · AUDIT /1
//
// Architecture rule:
// · This library does NOT decide Elliott counts.
// · This library does NOT create trade setups.
// · This library does NOT draw chart objects.
// · It owns runtime integrity checks, event packing and alert deduplication.
// · 11.8b2 production-audit conditions are preserved exactly.
// · The future host should need one audit call + one universal alertcondition.
// ═════════════════════════════════════════════════════════════════════════════

// @type Complete production-integrity result. Individual checks are retained so
// Detailed UI / Data Window diagnostics can be added later without rebuilding the
// audit methodology in the host.
export type ProductionAuditState
    bool pass = true
    string status = "PASS"
    string currentIssue = "NONE"
    string signature = ""
    int unresolvedActivations = 0
    int issueCount = 0
    string lastIssue = "NONE"
    bool changedNow = false
    bool pivotArraysAligned = true
    bool nestedArraysAligned = true
    bool fvgArraysAligned = true
    bool tradeAccounting = true
    bool tradeResultAccounting = true
    bool cancellationAccounting = true
    bool liveIdentity = true
    bool liveOrdering = true
    bool tp1Accounting = true

// @type Compact result from the universal Elliott event aggregator.
export type UniversalEventState
    bool raw = false
    bool fire = false
    string key = ""

// ─────────────────────────────────────────────────────────────────────────────
// GENERIC REGISTRY HELPERS
// ─────────────────────────────────────────────────────────────────────────────

// @function Adds one unique string and caps the registry size.
export addUniqueLimited(array<string> values, string value, int maximumSize) =>
    if value != "" and not array.includes(values, value)
        array.push(values, value)
        while array.size(values) > maximumSize
            array.shift(values)
    0

// @function Generic event de-duplication helper. This preserves the 11.8b2 event
// key contract: eventName | sourceKey | time.
export eventOnce(array<string> eventRegistry, bool eventCondition, string eventName,
     string sourceKey, int maximumSize, bool deduplicate) =>
    bool fireEvent = false
    if eventCondition
        string resolvedSource = sourceKey == "" ? str.tostring(time) : sourceKey
        string eventKey = eventName + "|" + resolvedSource + "|" + str.tostring(time)
        bool unseenEvent = not array.includes(eventRegistry, eventKey)
        if not deduplicate or unseenEvent
            fireEvent := true
        if unseenEvent
            array.push(eventRegistry, eventKey)
            while array.size(eventRegistry) > maximumSize
                array.shift(eventRegistry)
    fireEvent

// ─────────────────────────────────────────────────────────────────────────────
// MODEL EVENT PACKING
// ─────────────────────────────────────────────────────────────────────────────

// @function Creates the shared Model.EventState. The code field is a bit-mask for
// future audit/UI use; the named booleans remain the authoritative contract.
export eventState(string lastEvent, string currentCountKey, string lastInvalidCountKey,
     string forecastKey, string tradeId,
     bool countStarted, bool countRevised, bool countInvalidated,
     bool forecastNew, bool forecastRevised, bool forecastInvalidated,
     bool tradeWaiting, bool tradeActivated, bool tradeResolved,
     bool tradeCountInvalidExit) =>

    int code =
         (countStarted ? 1 : 0) +
         (countRevised ? 2 : 0) +
         (countInvalidated ? 4 : 0) +
         (forecastNew ? 8 : 0) +
         (forecastRevised ? 16 : 0) +
         (forecastInvalidated ? 32 : 0) +
         (tradeWaiting ? 64 : 0) +
         (tradeActivated ? 128 : 0) +
         (tradeResolved ? 256 : 0) +
         (tradeCountInvalidExit ? 512 : 0)

    ewModel.EventState result = ewModel.EventState.new()
    result.code := code
    result.lastEvent := lastEvent
    result.currentCountKey := currentCountKey
    result.lastInvalidCountKey := lastInvalidCountKey
    result.forecastKey := forecastKey
    result.tradeId := tradeId
    result.countStarted := countStarted
    result.countRevised := countRevised
    result.countInvalidated := countInvalidated
    result.forecastNew := forecastNew
    result.forecastRevised := forecastRevised
    result.forecastInvalidated := forecastInvalidated
    result.tradeWaiting := tradeWaiting
    result.tradeActivated := tradeActivated
    result.tradeResolved := tradeResolved
    result.tradeCountInvalidExit := tradeCountInvalidExit
    result

// @function True when Trade's per-bar resolution contains any lifecycle event.
// TP1 is intentionally included even when the trade remains live because 11.8b2
// treats TP1 as an alert-worthy lifecycle event.
export tradeLifecycleEvent(ewModel.TradeResolution resolution) =>
    resolution.tp1Event or resolution.tp2Event or resolution.stopEvent or
     resolution.breakEvenEvent or resolution.countInvalidEvent

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION INTEGRITY AUDIT · EXACT 11.8b2 RULES
// ─────────────────────────────────────────────────────────────────────────────

// @function Runs the original 11.8b2 production audit and owns persistent issue
// history internally. Call this once per host bar.
export productionAudit(
     array<float> pivotPrices, array<int> pivotBars, array<int> pivotTimes,
     array<int> pivotTypes, array<int> pivotIds,
     array<float> nestedPivotPrices, array<int> nestedPivotTimes,
     array<float> fvgOriginalTops, array<float> fvgOriginalBottoms,
     array<float> fvgLiveTops, array<float> fvgLiveBottoms,
     array<int> fvgDirections, array<int> fvgBirthBars,
     int tradeActivationCount, int tradeResolutionCount,
     int tradeProfitableResolutions, int tradeLosingResolutions, int tradeFlatResolutions,
     int tradeCancelled, int tradeWaitingCancellationCount,
     int tradeTp1ReachedCount, int tradeTp2ReachedCount,
     bool tradeLive, string tradeSetupId, int tradeDirection,
     float tradeEntry, float tradeStop, float tradeTp1) =>

    bool pivotArraysAligned =
         array.size(pivotPrices) == array.size(pivotBars) and
         array.size(pivotPrices) == array.size(pivotTimes) and
         array.size(pivotPrices) == array.size(pivotTypes) and
         array.size(pivotPrices) == array.size(pivotIds)

    bool nestedArraysAligned = array.size(nestedPivotPrices) == array.size(nestedPivotTimes)

    bool fvgArraysAligned =
         array.size(fvgOriginalTops) == array.size(fvgOriginalBottoms) and
         array.size(fvgOriginalTops) == array.size(fvgLiveTops) and
         array.size(fvgOriginalTops) == array.size(fvgLiveBottoms) and
         array.size(fvgOriginalTops) == array.size(fvgDirections) and
         array.size(fvgOriginalTops) == array.size(fvgBirthBars)

    int unresolvedActivations = tradeActivationCount - tradeResolutionCount
    bool tradeAccounting = unresolvedActivations == (tradeLive ? 1 : 0)
    bool tradeResultAccounting = tradeResolutionCount == tradeProfitableResolutions + tradeLosingResolutions + tradeFlatResolutions
    bool cancellationAccounting = tradeCancelled == tradeWaitingCancellationCount
    bool liveIdentity = not tradeLive or (tradeSetupId != "" and tradeDirection != 0 and not na(tradeEntry) and not na(tradeStop) and not na(tradeTp1))
    bool liveOrdering = not tradeLive or ((tradeEntry - tradeStop) * tradeDirection > 0.0 and (tradeTp1 - tradeEntry) * tradeDirection > 0.0)
    bool tp1Accounting = tradeTp1ReachedCount <= tradeActivationCount and tradeTp2ReachedCount <= tradeTp1ReachedCount

    bool auditPass = pivotArraysAligned and nestedArraysAligned and fvgArraysAligned and
         tradeAccounting and tradeResultAccounting and cancellationAccounting and
         liveIdentity and liveOrdering and tp1Accounting

    string currentIssue =
         not pivotArraysAligned ? "PIVOT ARRAY MISALIGNMENT" :
         not nestedArraysAligned ? "NESTED ARRAY MISALIGNMENT" :
         not fvgArraysAligned ? "FVG ARRAY MISALIGNMENT" :
         not tradeAccounting ? "OPEN TRADE ACCOUNTING" :
         not tradeResultAccounting ? "TRADE RESULT ACCOUNTING" :
         not cancellationAccounting ? "CANCELLATION ACCOUNTING" :
         not liveIdentity ? "LIVE TRADE IDENTITY" :
         not liveOrdering ? "LIVE LEVEL ORDER" :
         not tp1Accounting ? "TP1 ACCOUNTING" : "NONE"

    string status = auditPass ? "PASS" : "WARN · " + currentIssue
    string signature = auditPass ? "" : currentIssue

    // These three persistent values replace 11.8b2 host globals:
    // productionAuditIssueCount / productionLastAuditIssue / productionLastAuditSignature.
    var int issueCount = 0
    var string lastIssue = "NONE"
    var string lastSignature = ""

    bool changedNow = not auditPass and signature != lastSignature
    if changedNow
        issueCount += 1
        lastIssue := currentIssue

    lastSignature := signature

    ProductionAuditState result = ProductionAuditState.new()
    result.pass := auditPass
    result.status := status
    result.currentIssue := currentIssue
    result.signature := signature
    result.unresolvedActivations := unresolvedActivations
    result.issueCount := issueCount
    result.lastIssue := lastIssue
    result.changedNow := changedNow
    result.pivotArraysAligned := pivotArraysAligned
    result.nestedArraysAligned := nestedArraysAligned
    result.fvgArraysAligned := fvgArraysAligned
    result.tradeAccounting := tradeAccounting
    result.tradeResultAccounting := tradeResultAccounting
    result.cancellationAccounting := cancellationAccounting
    result.liveIdentity := liveIdentity
    result.liveOrdering := liveOrdering
    result.tp1Accounting := tp1Accounting
    result

// ─────────────────────────────────────────────────────────────────────────────
// UNIVERSAL ELLIOTT EVENT + ALERT DEDUPLICATION
// ─────────────────────────────────────────────────────────────────────────────

// @function Reproduces the 11.8b2 universal-event OR tree using the compact shared
// EventState plus the few event families not represented by Model /1.
export universalEventRaw(ewModel.EventState events,
     bool committedPivotNow, bool impulseCompletedNow, bool correctionCompletedNow,
     bool freshFvgConfluenceNow, bool mtfContextChangedNow, bool mtfPrimaryGateReadyNow,
     bool tradeLifecycleNow, bool forecastAuditTargetHit, bool primaryW5TargetHitNow,
     bool productionStructuralGate, bool productionTradeActivationGate,
     bool productionAuditChangedNow) =>

    (committedPivotNow and productionStructuralGate) or
     (events.countStarted and productionStructuralGate) or
     (events.countRevised and productionStructuralGate) or
     (events.countInvalidated and productionStructuralGate) or
     (impulseCompletedNow and productionStructuralGate) or
     (correctionCompletedNow and productionStructuralGate) or
     (freshFvgConfluenceNow and productionStructuralGate) or
     (mtfContextChangedNow and productionStructuralGate) or
     (mtfPrimaryGateReadyNow and productionStructuralGate) or
     (events.tradeWaiting and productionTradeActivationGate) or
     events.tradeActivated or
     tradeLifecycleNow or
     events.tradeResolved or
     events.tradeCountInvalidExit or
     events.forecastNew or
     events.forecastRevised or
     events.forecastInvalidated or
     forecastAuditTargetHit or
     primaryW5TargetHitNow or
     productionAuditChangedNow

// @function Stateful universal alert. The registry lives in Audit /1 rather than
// the indicator host. This preserves 11.8b2's ANY_EW_EVENT | bar_index | time key.
// Call once per host bar, then feed .fire to the single alertcondition().
export universalAlert(bool rawEvent, int maximumSize, bool deduplicate) =>
    var array<string> registry = array.new_string()

    UniversalEventState result = UniversalEventState.new()
    result.raw := rawEvent

    if rawEvent
        string sourceKey = str.tostring(bar_index)
        string eventKey = "ANY_EW_EVENT|" + sourceKey + "|" + str.tostring(time)
        bool unseenEvent = not array.includes(registry, eventKey)
        bool fireEvent = not deduplicate or unseenEvent

        if unseenEvent
            array.push(registry, eventKey)
            while array.size(registry) > maximumSize
                array.shift(registry)

        result.fire := fireEvent
        result.key := eventKey

    result

// @function Convenience wrapper: aggregate + deduplicate in one host call.
export processUniversalAlert(ewModel.EventState events,
     bool committedPivotNow, bool impulseCompletedNow, bool correctionCompletedNow,
     bool freshFvgConfluenceNow, bool mtfContextChangedNow, bool mtfPrimaryGateReadyNow,
     bool tradeLifecycleNow, bool forecastAuditTargetHit, bool primaryW5TargetHitNow,
     bool productionStructuralGate, bool productionTradeActivationGate,
     bool productionAuditChangedNow, int maximumSize, bool deduplicate) =>

    bool rawEvent = universalEventRaw(events,
         committedPivotNow, impulseCompletedNow, correctionCompletedNow,
         freshFvgConfluenceNow, mtfContextChangedNow, mtfPrimaryGateReadyNow,
         tradeLifecycleNow, forecastAuditTargetHit, primaryW5TargetHitNow,
         productionStructuralGate, productionTradeActivationGate,
         productionAuditChangedNow)

    universalAlert(rawEvent, maximumSize, deduplicate)
````
