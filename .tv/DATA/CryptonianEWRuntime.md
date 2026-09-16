<!-- tradingview-pine-id: PUB;22db88549ae64df7874ebc3c898611b5 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# CryptonianEWRuntime

Source: https://www.tradingview.com/script/ILVudE50-CryptonianEWRuntime/

## Description

Library  "CryptonianEWRuntime"
Cryptonian Elliott Wave Runtime /1. Owns adaptive MTF profile selection, compact context/bridge request expressions, lower-timeframe confirmation processing, MTF trade gates, bottom-up bootstrap assembly, Context EW forecast assembly, HTF trade-bridge request expressions, nested-pivot request expressions, production gates and final engine-state packing. Methodology is preserved from Elliott Wave Engine 11.8b2; this library is an architecture migration, not a rules rewrite.

autoContextTimeframe(chartSeconds)
  Parameters:
    chartSeconds (int)

autoConfirmationTimeframe(chartSeconds)
  Parameters:
    chartSeconds (int)

autoBridgeTimeframe(chartSeconds)
  Parameters:
    chartSeconds (int)

profileState(enabled, autoProfile, manualContextTimeframe, manualExecutionTimeframe, manualConfirmationTimeframe, chartTimeframe, chartSeconds)
  Builds the timeframe/profile portion of Model.MtfState.
It deliberately does not perform any data request.
  Parameters:
    enabled (bool)
    autoProfile (bool)
    manualContextTimeframe (string)
    manualExecutionTimeframe (string)
    manualConfirmationTimeframe (string)
    chartTimeframe (string)
    chartSeconds (int)

bridgeTimeframe(autoProfile, manualConfirmationTimeframe, chartSeconds)
  Returns the active lower bridge timeframe used by the existing
bottom-up Elliott bootstrap. This remains separate because Model /1 MtfState
intentionally stores only Context / Execution / Confirmation.
  Parameters:
    autoProfile (bool)
    manualConfirmationTimeframe (string)
    chartSeconds (int)

bridgeTimeframeValid(bridgeTf, chartSeconds)
  Parameters:
    bridgeTf (string)
    chartSeconds (int)

contextPack(mtfPivotStrength, atrLength, mtfMinimumSwingAtr, allowDiagonals, allowTruncation, truncationMinimumPct, contextPivotStrength, contextMinimumSwingAtr, candidateStarts, minimumNewCandidateScore, extensionThreshold, diagonalTolerance, invalidationMode)
  Exact 11.8b2 higher-timeframe context packet.
mtfConfirmedSnapshot() retains the old trade-context methodology while
contextConfirmedSnapshot() retains the separate Context-EW forecast geometry.
  Parameters:
    mtfPivotStrength (int)
    atrLength (simple int)
    mtfMinimumSwingAtr (float)
    allowDiagonals (bool)
    allowTruncation (bool)
    truncationMinimumPct (float)
    contextPivotStrength (int)
    contextMinimumSwingAtr (float)
    candidateStarts (int)
    minimumNewCandidateScore (float)
    extensionThreshold (float)
    diagonalTolerance (float)
    invalidationMode (string)

mtfContextState(pack)
  Converts ContextPack's MTF branch into the shared DegreeState contract.
  Parameters:
    pack (ContextPack)

contextForecastDegreeState(pack)
  Converts ContextPack's full Context-EW branch into DegreeState.
  Parameters:
    pack (ContextPack)

bridgeDegreeState(pivotStrength, atrLength, minimumSwingAtr, candidateStarts, minimumNewScore, allowDiagonals, allowTruncation, truncationMinimumPct, extensionThreshold, diagonalTolerance, invalidationMode)
  Exact lower-bridge structural expression, object form.
  Parameters:
    pivotStrength (int)
    atrLength (simple int)
    minimumSwingAtr (float)
    candidateStarts (int)
    minimumNewScore (float)
    allowDiagonals (bool)
    allowTruncation (bool)
    truncationMinimumPct (float)
    extensionThreshold (float)
    diagonalTolerance (float)
    invalidationMode (string)

ltfMomentumSignal(fastLength, slowLength)
  Exact lower-timeframe momentum expression used by 11.8b2.
  Parameters:
    fastLength (simple int)
    slowLength (simple int)

nestedPivotEvent(strength, atrLength)
  Exact Part 9.2 lower-degree confirmed pivot event expression.
  Parameters:
    strength (int)
    atrLength (simple int)

htfTradeBridgeState(enabled, degreeEngineOn, secondaryEnabled, subSecondaryEnabled, primaryPivotStrength, secondaryPivotStrength, subSecondaryPivotStrength, atrLength, primaryMinimumSwingAtr, secondaryMinimumSwingAtr, subSecondaryMinimumSwingAtr, candidateStarts, minimumNewScore, allowDiagonals, allowTruncation, truncationMinimumPct, extensionThreshold, diagonalTolerance, invalidationMode, minimumModelScore, stopBufferAtr)
  Native HTF trade bridge request expression. Candidate discovery,
first-seen geometry freezing and W2/W3/W4/W5 classification remain in Trade /13.
  Parameters:
    enabled (bool)
    degreeEngineOn (bool)
    secondaryEnabled (bool)
    subSecondaryEnabled (bool)
    primaryPivotStrength (int)
    secondaryPivotStrength (int)
    subSecondaryPivotStrength (int)
    atrLength (simple int)
    primaryMinimumSwingAtr (float)
    secondaryMinimumSwingAtr (float)
    subSecondaryMinimumSwingAtr (float)
    candidateStarts (int)
    minimumNewScore (float)
    allowDiagonals (bool)
    allowTruncation (bool)
    truncationMinimumPct (float)
    extensionThreshold (float)
    diagonalTolerance (float)
    invalidationMode (string)
    minimumModelScore (float)
    stopBufferAtr (float)

updateMtfState(previous, enabled, autoProfile, manualContextTimeframe, manualExecutionTimeframe, manualConfirmationTimeframe, chartTimeframe, chartSeconds, gateMode, requireExecutionTimeframe, ltfConfirmationMaximumAge, realtimeBar, context, ltfSignalValues, ltfSignalTimes, primaryDirection, correctionDirection)
  Updates one persistent Model.MtfState object from the current profile,
requested context packet and request.security_lower_tf() signal/time arrays.
Pass a persistent initialized object from the host, then assign the returned object
back to it on every bar. The function intentionally ignores the realtime chart
bar's final LTF intrabar, exactly as 11.8b2 did.
  Parameters:
    previous (MtfState type from AYEHAN/CryptonianEWModel/1)
    enabled (bool)
    autoProfile (bool)
    manualContextTimeframe (string)
    manualExecutionTimeframe (string)
    manualConfirmationTimeframe (string)
    chartTimeframe (string)
    chartSeconds (int)
    gateMode (string)
    requireExecutionTimeframe (bool)
    ltfConfirmationMaximumAge (int)
    realtimeBar (bool)
    context (ContextPack)
    ltfSignalValues (array<int>)
    ltfSignalTimes (array<int>)
    primaryDirection (int)
    correctionDirection (int)

runtimeEvents(current, previous, primaryDirection, correctionDirection)
  Small event helper that replaces host history expressions with object
history applied correctly by the caller: pass current and previous Runtime states.
  Parameters:
    current (MtfState type from AYEHAN/CryptonianEWModel/1)
    previous (MtfState type from AYEHAN/CryptonianEWModel/1)
    primaryDirection (int)
    correctionDirection (int)

bootstrapState(chartPrimaryMissing, bridge, context, chartClose, chartAtr)
  Parameters:
    chartPrimaryMissing (bool)
    bridge (DegreeState type from AYEHAN/CryptonianEWModel/1)
    context (DegreeState type from AYEHAN/CryptonianEWModel/1)
    chartClose (float)
    chartAtr (float)

contextForecastState(enabled, contextTimeframeValid, context, armScore)
  Parameters:
    enabled (bool)
    contextTimeframeValid (bool)
    context (ContextPack)
    armScore (float)

processNested(eventTypes, eventPrices, eventTimes, eventAtrs, barTimes, pivotPrices, pivotTimes, pendingType, pendingPrice, pendingTime, pendingAtr, lastEventTime, coverageStartTime, coverageEndTime, minimumSwingAtr, enabled)
  Parameters:
    eventTypes (array<int>)
    eventPrices (array<float>)
    eventTimes (array<int>)
    eventAtrs (array<float>)
    barTimes (array<int>)
    pivotPrices (array<float>)
    pivotTimes (array<int>)
    pendingType (int)
    pendingPrice (float)
    pendingTime (int)
    pendingAtr (float)
    lastEventTime (int)
    coverageStartTime (int)
    coverageEndTime (int)
    minimumSwingAtr (float)
    enabled (bool)

nestedLeg(pivotPrices, pivotTimes, coverageStartTime, coverageEndTime, engineOn, timeframeValid, t0, y0, t1, y1, direction, motive, diagonal, confirmed)
  Parameters:
    pivotPrices (array<float>)
    pivotTimes (array<int>)
    coverageStartTime (int)
    coverageEndTime (int)
    engineOn (bool)
    timeframeValid (bool)
    t0 (int)
    y0 (float)
    t1 (int)
    y1 (float)
    direction (int)
    motive (bool)
    diagonal (bool)
    confirmed (bool)

structuralProductionGate(productionMode, confirmOnClose, barConfirmed)
  Parameters:
    productionMode (bool)
    confirmOnClose (bool)
    barConfirmed (bool)

tradeActivationProductionGate(productionMode, confirmOnClose, barConfirmed)
  Parameters:
    productionMode (bool)
    confirmOnClose (bool)
    barConfirmed (bool)

packEngineState(primary, secondary, subSecondary, correction, bootstrap, parent, degreeResolution, forecast, contextForecast, mtf, htfTrade, events)
  Parameters:
    primary (DegreeState type from AYEHAN/CryptonianEWModel/1)
    secondary (DegreeState type from AYEHAN/CryptonianEWModel/1)
    subSecondary (DegreeState type from AYEHAN/CryptonianEWModel/1)
    correction (CorrectionState type from AYEHAN/CryptonianEWModel/1)
    bootstrap (BootstrapState type from AYEHAN/CryptonianEWModel/1)
    parent (ParentHypothesis type from AYEHAN/CryptonianEWModel/1)
    degreeResolution (DegreeResolutionState type from AYEHAN/CryptonianEWModel/1)
    forecast (ForecastState type from AYEHAN/CryptonianEWModel/1)
    contextForecast (ContextForecastState type from AYEHAN/CryptonianEWModel/1)
    mtf (MtfState type from AYEHAN/CryptonianEWModel/1)
    htfTrade (TradeBridgePack type from AYEHAN/CryptonianEWModel/1)
    events (EventState type from AYEHAN/CryptonianEWModel/1)

ContextPack
  One request-safe higher-timeframe packet containing both legacy MTF
  Fields:
    mtfDirection (series int)
    mtfStage (series int)
    mtfQuality (series float)
    mtfInvalidation (series float)
    mtfDiagonal (series bool)
    forecastDirection (series int)
    forecastStage (series int)
    forecastScore (series float)
    forecastInvalidation (series float)
    forecastDiagonal (series bool)
    p0 (series float)
    p1 (series float)
    p2 (series float)
    p3 (series float)
    p4 (series float)
    p5 (series float)
    confirmedClose (series float)

RuntimeEvents
  Small host-facing diagnostic packet for runtime transitions.
  Fields:
    contextChanged (series bool)
    motiveGateReady (series bool)
    correctionGateReady (series bool)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AYEHAN

//@version=6
// @description Cryptonian Elliott Wave Runtime /2. Owns adaptive MTF profile selection, compact context/bridge request expressions, lower-timeframe confirmation processing, MTF trade gates, bottom-up bootstrap assembly, Context EW forecast assembly, HTF trade-bridge request expressions, nested-pivot request expressions, production gates and final engine-state packing. Methodology is preserved from Elliott Wave Engine 11.8b2; this library is an architecture migration, not a rules rewrite.
library("CryptonianEWRuntime", overlay = true, dynamic_requests = true)

import AYEHAN/CryptonianEWModel/1 as ewModel
import AYEHAN/CryptonianEWCore/10 as ewCore
import AYEHAN/CryptonianEWForecast/11 as ewForecast
import AYEHAN/CryptonianEWTrade/14 as ewTrade

// ═════════════════════════════════════════════════════════════════════════════
// CRYPTONIAN ELLIOTT WAVE · RUNTIME /2
//
// Architecture rule:
// · Host owns inputs and the request.* call sites.
// · Runtime owns the heavy expressions and state assembly used by those requests.
// · Request expressions remain inside exported pure functions because TradingView
//   libraries cannot use exported-function parameters inside request expressions.
// · No Elliott methodology is intentionally changed here.
// · No chart drawings are created here.
//
// 11.8b2 parity covered in /1:
// · Adaptive Context / Execution / Confirmation / Bridge profile
// · Existing MTF confirmed-context snapshot
// · Existing Context-EW structural snapshot
// · Existing lower-TF momentum signal + completed-intrabar processing
// · Existing motive/correction MTF gating
// · Existing lower bridge snapshot + bottom-up bootstrap
// · Existing Context EW forecast state assembly
// · Trade /14 native HTF bridge expression
// · Nested-EW pivot-event expression + nested processing wrappers
// · Production close-gates
// · Unified EngineState packing
// ═════════════════════════════════════════════════════════════════════════════

// @type One request-safe higher-timeframe packet containing both legacy MTF
// context methodology and Context-EW geometry. Keeping these together lets the
// future host replace two wide request tuples with one object request.
export type ContextPack
    int mtfDirection = 0
    int mtfStage = 0
    float mtfQuality
    float mtfInvalidation
    bool mtfDiagonal = false
    int forecastDirection = 0
    int forecastStage = 0
    float forecastScore
    float forecastInvalidation
    bool forecastDiagonal = false
    float p0
    float p1
    float p2
    float p3
    float p4
    float p5
    float confirmedClose

// @type Small host-facing diagnostic packet for runtime transitions.
export type RuntimeEvents
    bool contextChanged = false
    bool motiveGateReady = false
    bool correctionGateReady = false

// ─────────────────────────────────────────────────────────────────────────────
// ADAPTIVE TIMEFRAME PROFILE · EXACT 11.8b2 MAPPING
// ─────────────────────────────────────────────────────────────────────────────

export autoContextTimeframe(int chartSeconds) =>
    chartSeconds <= 60 ? "5" :
     chartSeconds <= 300 ? "30" :
     chartSeconds <= 900 ? "60" :
     chartSeconds <= 1800 ? "240" :
     chartSeconds <= 3600 ? "240" :
     chartSeconds <= 14400 ? "D" :
     chartSeconds <= 86400 ? "W" :
     chartSeconds <= 259200 ? "W" :
     chartSeconds <= 604800 ? "M" :
     chartSeconds <= 2678400 ? "3M" : "12M"

export autoConfirmationTimeframe(int chartSeconds) =>
    chartSeconds <= 60 ? "1" :
     chartSeconds <= 300 ? "1" :
     chartSeconds <= 900 ? "5" :
     chartSeconds <= 1800 ? "5" :
     chartSeconds <= 3600 ? "15" :
     chartSeconds <= 14400 ? "30" :
     chartSeconds <= 86400 ? "240" :
     chartSeconds <= 259200 ? "D" :
     chartSeconds <= 604800 ? "D" :
     chartSeconds <= 2678400 ? "W" : "M"

export autoBridgeTimeframe(int chartSeconds) =>
    chartSeconds <= 60 ? "1" :
     chartSeconds <= 300 ? "1" :
     chartSeconds <= 900 ? "5" :
     chartSeconds <= 1800 ? "15" :
     chartSeconds <= 3600 ? "30" :
     chartSeconds <= 14400 ? "60" :
     chartSeconds <= 86400 ? "240" :
     chartSeconds <= 259200 ? "D" :
     chartSeconds <= 604800 ? "3D" :
     chartSeconds <= 2678400 ? "W" : "M"

// @function Builds the timeframe/profile portion of Model.MtfState.
// It deliberately does not perform any data request.
export profileState(bool enabled, bool autoProfile,
     string manualContextTimeframe, string manualExecutionTimeframe, string manualConfirmationTimeframe,
     string chartTimeframe, int chartSeconds) =>

    string contextTf = autoProfile ? autoContextTimeframe(chartSeconds) : manualContextTimeframe
    string executionTf = autoProfile ? chartTimeframe : manualExecutionTimeframe
    string confirmationTf = autoProfile ? autoConfirmationTimeframe(chartSeconds) : manualConfirmationTimeframe

    int contextSeconds = timeframe.in_seconds(contextTf)
    int executionSeconds = timeframe.in_seconds(executionTf)
    int confirmationSeconds = timeframe.in_seconds(confirmationTf)

    ewModel.MtfState result = ewModel.MtfState.new()
    result.enabled := enabled
    result.profileMode := autoProfile ? "AUTO" : "MANUAL"
    result.hierarchy := contextTf + " → " + executionTf + " → " + confirmationTf
    result.contextTimeframe := contextTf
    result.executionTimeframe := executionTf
    result.confirmationTimeframe := confirmationTf
    result.contextValid := contextSeconds > chartSeconds
    result.executionValid := executionSeconds == chartSeconds
    result.confirmationValid := confirmationSeconds < chartSeconds
    result

// @function Returns the active lower bridge timeframe used by the existing
// bottom-up Elliott bootstrap. This remains separate because Model /1 MtfState
// intentionally stores only Context / Execution / Confirmation.
export bridgeTimeframe(bool autoProfile, string manualConfirmationTimeframe, int chartSeconds) =>
    autoProfile ? autoBridgeTimeframe(chartSeconds) : manualConfirmationTimeframe

export bridgeTimeframeValid(string bridgeTf, int chartSeconds) =>
    timeframe.in_seconds(bridgeTf) < chartSeconds

// ─────────────────────────────────────────────────────────────────────────────
// REQUEST EXPRESSIONS
// These functions contain NO request.* call. The future thin host requests them.
// This avoids the Pine library restriction that request expressions inside an
// exported function cannot depend on exported-function parameters.
// ─────────────────────────────────────────────────────────────────────────────

// @function Exact 11.8b2 higher-timeframe context packet.
// mtfConfirmedSnapshot() retains the old trade-context methodology while
// contextConfirmedSnapshot() retains the separate Context-EW forecast geometry.
export contextPack(
     int mtfPivotStrength, int atrLength, float mtfMinimumSwingAtr,
     bool allowDiagonals, bool allowTruncation, float truncationMinimumPct,
     int contextPivotStrength, float contextMinimumSwingAtr, int candidateStarts,
     float minimumNewCandidateScore, float extensionThreshold, float diagonalTolerance,
     string invalidationMode) =>

    [mtfDirection, mtfStage, mtfQuality, mtfInvalidation, mtfDiagonal] =
         ewCore.mtfConfirmedSnapshot(mtfPivotStrength, atrLength, mtfMinimumSwingAtr,
             allowDiagonals, allowTruncation, truncationMinimumPct)

    [forecastDirection, forecastStage, forecastScore, forecastInvalidation, forecastDiagonal,
     p0, p1, p2, p3, p4, p5] =
         ewCore.contextConfirmedSnapshot(contextPivotStrength, atrLength, contextMinimumSwingAtr,
             candidateStarts, minimumNewCandidateScore, allowDiagonals, allowTruncation,
             truncationMinimumPct, extensionThreshold, diagonalTolerance, invalidationMode)

    ContextPack result = ContextPack.new()
    result.mtfDirection := mtfDirection
    result.mtfStage := mtfStage
    result.mtfQuality := mtfQuality
    result.mtfInvalidation := mtfInvalidation
    result.mtfDiagonal := mtfDiagonal
    result.forecastDirection := forecastDirection
    result.forecastStage := forecastStage
    result.forecastScore := forecastScore
    result.forecastInvalidation := forecastInvalidation
    result.forecastDiagonal := forecastDiagonal
    result.p0 := p0
    result.p1 := p1
    result.p2 := p2
    result.p3 := p3
    result.p4 := p4
    result.p5 := p5
    // request.security(..., lookahead_on) evaluates this in the requested context.
    // close[1] therefore preserves the old confirmed-context-close contract.
    result.confirmedClose := close[1]
    result

// @function Converts ContextPack's MTF branch into the shared DegreeState contract.
export mtfContextState(ContextPack pack) =>
    ewModel.DegreeState result = ewModel.DegreeState.new()
    result.active := pack.mtfDirection != 0 and pack.mtfStage != 0
    result.name := "MTF CONTEXT"
    result.direction := pack.mtfDirection
    result.stage := pack.mtfStage
    result.score := pack.mtfQuality
    result.invalidation := pack.mtfInvalidation
    result.diagonal := pack.mtfDiagonal
    result.rule3Applicable := not pack.mtfDiagonal
    result

// @function Converts ContextPack's full Context-EW branch into DegreeState.
export contextForecastDegreeState(ContextPack pack) =>
    ewModel.DegreeState result = ewModel.DegreeState.new()
    result.active := pack.forecastDirection != 0 and pack.forecastStage != 0
    result.name := "CONTEXT"
    result.direction := pack.forecastDirection
    result.stage := pack.forecastStage
    result.score := pack.forecastScore
    result.invalidation := pack.forecastInvalidation
    result.diagonal := pack.forecastDiagonal
    result.rule3Applicable := not pack.forecastDiagonal
    result.p0 := pack.p0
    result.p1 := pack.p1
    result.p2 := pack.p2
    result.p3 := pack.p3
    result.p4 := pack.p4
    result.p5 := pack.p5
    result

// @function Exact lower-bridge structural expression, object form.
export bridgeDegreeState(int pivotStrength, int atrLength, float minimumSwingAtr,
     int candidateStarts, float minimumNewScore, bool allowDiagonals, bool allowTruncation,
     float truncationMinimumPct, float extensionThreshold, float diagonalTolerance,
     string invalidationMode) =>
    ewCore.bridgeDegreeState(pivotStrength, atrLength, minimumSwingAtr, candidateStarts,
        minimumNewScore, allowDiagonals, allowTruncation, truncationMinimumPct,
        extensionThreshold, diagonalTolerance, invalidationMode)

// @function Exact lower-timeframe momentum expression used by 11.8b2.
export ltfMomentumSignal(int fastLength, int slowLength) =>
    ewCore.ltfMomentumSignal(fastLength, slowLength)

// @function Exact Part 9.2 lower-degree confirmed pivot event expression.
export nestedPivotEvent(int strength, int atrLength) =>
    ewCore.nestedPivotEvent(strength, atrLength)

// @function Native HTF trade bridge request expression. Candidate discovery,
// first-seen geometry freezing and W2/W3/W4/W5 classification remain in Trade /14.
export htfTradeBridgeState(bool enabled, bool degreeEngineOn, bool secondaryEnabled, bool subSecondaryEnabled,
     int primaryPivotStrength, int secondaryPivotStrength, int subSecondaryPivotStrength,
     int atrLength, float primaryMinimumSwingAtr, float secondaryMinimumSwingAtr, float subSecondaryMinimumSwingAtr,
     int candidateStarts, float minimumNewScore, bool allowDiagonals, bool allowTruncation,
     float truncationMinimumPct, float extensionThreshold, float diagonalTolerance,
     string invalidationMode, float minimumModelScore, float stopBufferAtr) =>

    ewTrade.nativeHtfTradeBridgeState(enabled, degreeEngineOn, secondaryEnabled, subSecondaryEnabled,
        primaryPivotStrength, secondaryPivotStrength, subSecondaryPivotStrength,
        atrLength, primaryMinimumSwingAtr, secondaryMinimumSwingAtr, subSecondaryMinimumSwingAtr,
        candidateStarts, minimumNewScore, allowDiagonals, allowTruncation,
        truncationMinimumPct, extensionThreshold, diagonalTolerance,
        invalidationMode, minimumModelScore, stopBufferAtr)

// ─────────────────────────────────────────────────────────────────────────────
// LOWER-TIMEFRAME COMPLETED-INTRABAR PROCESSING + MTF GATES
// Replaces the host-side array loop and gate block from 11.8b2.
// ─────────────────────────────────────────────────────────────────────────────

// @function Updates one persistent Model.MtfState object from the current profile,
// requested context packet and request.security_lower_tf() signal/time arrays.
// Pass a persistent initialized object from the host, then assign the returned object
// back to it on every bar. The function intentionally ignores the realtime chart
// bar's final LTF intrabar, exactly as 11.8b2 did.
export updateMtfState(
     ewModel.MtfState previous,
     bool enabled, bool autoProfile,
     string manualContextTimeframe, string manualExecutionTimeframe, string manualConfirmationTimeframe,
     string chartTimeframe, int chartSeconds,
     string gateMode, bool requireExecutionTimeframe, int ltfConfirmationMaximumAge,
     bool realtimeBar,
     ContextPack context,
     array<int> ltfSignalValues, array<int> ltfSignalTimes,
     int primaryDirection, int correctionDirection) =>

    ewModel.MtfState result = profileState(enabled, autoProfile,
        manualContextTimeframe, manualExecutionTimeframe, manualConfirmationTimeframe,
        chartTimeframe, chartSeconds)

    result.contextDirection := context.mtfDirection
    result.contextStage := context.mtfStage
    result.contextQuality := context.mtfQuality
    result.contextInvalidation := context.mtfInvalidation
    result.contextDiagonal := context.mtfDiagonal

    int ltfDirection = previous.ltfDirection
    int ltfSignalTime = previous.ltfSignalTime
    int ltfAgeBars = na(previous.ltfAgeBars) ? 1000000 : previous.ltfAgeBars + 1

    int intrabarCount = math.min(array.size(ltfSignalValues), array.size(ltfSignalTimes))
    int usableIntrabarCount = intrabarCount
    if realtimeBar and usableIntrabarCount > 0
        usableIntrabarCount -= 1

    if enabled and result.confirmationValid and usableIntrabarCount > 0
        for intrabarIndex = 0 to usableIntrabarCount - 1
            int intrabarSignal = array.get(ltfSignalValues, intrabarIndex)
            if intrabarSignal != 0
                ltfDirection := intrabarSignal
                ltfSignalTime := array.get(ltfSignalTimes, intrabarIndex)
                ltfAgeBars := 0

    bool ltfFresh = enabled and result.confirmationValid and ltfAgeBars <= ltfConfirmationMaximumAge
    bool requiresHtf = enabled and (gateMode == "Require HTF alignment" or gateMode == "Require HTF + LTF confirmation")
    bool requiresLtf = enabled and gateMode == "Require HTF + LTF confirmation"
    bool executionPass = not requireExecutionTimeframe or result.executionValid

    bool primaryHtfPass = not requiresHtf or (result.contextValid and primaryDirection != 0 and context.mtfDirection == primaryDirection)
    bool primaryLtfPass = not requiresLtf or (result.confirmationValid and ltfFresh and primaryDirection != 0 and ltfDirection == primaryDirection)
    bool motiveGatePass = not enabled or gateMode == "Off" or gateMode == "Context only" or (executionPass and primaryHtfPass and primaryLtfPass)

    bool correctionHtfPass = not requiresHtf or (result.contextValid and correctionDirection != 0 and context.mtfDirection == correctionDirection)
    bool correctionLtfPass = not requiresLtf or (result.confirmationValid and ltfFresh and correctionDirection != 0 and ltfDirection == correctionDirection)
    bool correctionGatePass = not enabled or gateMode == "Off" or gateMode == "Context only" or (executionPass and correctionHtfPass and correctionLtfPass)

    result.ltfDirection := ltfDirection
    result.ltfSignalTime := ltfSignalTime
    result.ltfAgeBars := ltfAgeBars
    result.ltfFresh := ltfFresh
    result.motiveGatePass := motiveGatePass
    result.correctionGatePass := correctionGatePass
    result.gateText := gateMode == "Off" ? "OFF" : gateMode == "Context only" ? "CONTEXT ONLY" : motiveGatePass and correctionGatePass ? "PASS" : motiveGatePass or correctionGatePass ? "MIXED" : "BLOCKED"
    result

// @function Small event helper that replaces host history expressions with object
// history applied correctly by the caller: pass current and previous Runtime states.
export runtimeEvents(ewModel.MtfState current, ewModel.MtfState previous,
     int primaryDirection, int correctionDirection) =>
    RuntimeEvents result = RuntimeEvents.new()
    result.contextChanged := current.enabled and current.contextValid and current.contextDirection != 0 and
         (current.contextDirection != previous.contextDirection or current.contextStage != previous.contextStage)
    result.motiveGateReady := current.motiveGatePass and not previous.motiveGatePass and primaryDirection != 0
    result.correctionGateReady := current.correctionGatePass and not previous.correctionGatePass and correctionDirection != 0
    result

// ─────────────────────────────────────────────────────────────────────────────
// BOOTSTRAP + CONTEXT FORECAST ASSEMBLY
// ─────────────────────────────────────────────────────────────────────────────

export bootstrapState(bool chartPrimaryMissing, ewModel.DegreeState bridge, ewModel.DegreeState context,
     float chartClose, float chartAtr) =>
    ewCore.bootstrapState(chartPrimaryMissing,
        bridge.direction, bridge.stage, bridge.score, bridge.invalidation, bridge.diagonal,
        context.direction, context.stage, context.score,
        chartClose, chartAtr)

export contextForecastState(bool enabled, bool contextTimeframeValid,
     ContextPack context, float armScore) =>
    ewModel.DegreeState degree = contextForecastDegreeState(context)
    ewModel.ContextForecastState result = ewForecast.contextForecastState(enabled and contextTimeframeValid, degree, context.confirmedClose)
    result.lifecycleState := not result.active ? "IDLE" : result.score >= armScore ? "ARMED" : "FORMING"
    result

// ─────────────────────────────────────────────────────────────────────────────
// NESTED-EW PROCESSING WRAPPERS
// Host retains only the persistent pivot arrays/pending primitives until the
// future nested-state object revision. Heavy processing stays in Core /10.
// ─────────────────────────────────────────────────────────────────────────────

export processNested(array<int> eventTypes, array<float> eventPrices, array<int> eventTimes,
     array<float> eventAtrs, array<int> barTimes,
     array<float> pivotPrices, array<int> pivotTimes,
     int pendingType, float pendingPrice, int pendingTime, float pendingAtr,
     int lastEventTime, int coverageStartTime, int coverageEndTime,
     float minimumSwingAtr, bool enabled) =>

    ewCore.processNested(eventTypes, eventPrices, eventTimes, eventAtrs, barTimes,
        pivotPrices, pivotTimes,
        pendingType, pendingPrice, pendingTime, pendingAtr,
        lastEventTime, coverageStartTime, coverageEndTime,
        minimumSwingAtr, enabled)

export nestedLeg(array<float> pivotPrices, array<int> pivotTimes,
     int coverageStartTime, int coverageEndTime,
     bool engineOn, bool timeframeValid,
     int t0, float y0, int t1, float y1, int direction,
     bool motive, bool diagonal, bool confirmed) =>

    ewCore.nestedLeg(pivotPrices, pivotTimes, coverageStartTime, coverageEndTime,
        engineOn, timeframeValid,
        t0, y0, t1, y1, direction, motive, diagonal, confirmed)

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION GATES
// ─────────────────────────────────────────────────────────────────────────────

export structuralProductionGate(bool productionMode, bool confirmOnClose, bool barConfirmed) =>
    not productionMode or not confirmOnClose or barConfirmed

export tradeActivationProductionGate(bool productionMode, bool confirmOnClose, bool barConfirmed) =>
    not productionMode or not confirmOnClose or barConfirmed

// ─────────────────────────────────────────────────────────────────────────────
// UNIFIED ENGINE PACKING
// This is glue only. It gives the eventual 11.8c host one canonical state graph.
// ─────────────────────────────────────────────────────────────────────────────

export packEngineState(
     ewModel.DegreeState primary,
     ewModel.DegreeState secondary,
     ewModel.DegreeState subSecondary,
     ewModel.CorrectionState correction,
     ewModel.BootstrapState bootstrap,
     ewModel.ParentHypothesis parent,
     ewModel.DegreeResolutionState degreeResolution,
     ewModel.ForecastState forecast,
     ewModel.ContextForecastState contextForecast,
     ewModel.MtfState mtf,
     ewModel.TradeBridgePack htfTrade,
     ewModel.EventState events) =>

    ewModel.EngineState result = ewModel.EngineState.new()
    result.primary := primary
    result.secondary := secondary
    result.subSecondary := subSecondary
    result.correction := correction
    result.bootstrap := bootstrap
    result.parent := parent
    result.degreeResolution := degreeResolution
    result.forecast := forecast
    result.contextForecast := contextForecast
    result.mtf := mtf
    result.htfTrade := htfTrade
    result.events := events
    result
````
