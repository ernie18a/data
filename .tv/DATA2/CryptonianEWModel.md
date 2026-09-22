<!-- tradingview-pine-id: PUB;6fbac31ef43d42ba8044a1ebd19520df -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CryptonianEWModel

Source: https://www.tradingview.com/script/uHHXiiJQ-CryptonianEWModel/

## Description

Library  "CryptonianEWModel"
Cryptonian Elliott Wave shared data-model library. v1 contains schema only: no Elliott methodology, no trading rules and no rendering. It provides request-safe UDT contracts used by Core, Forecast, Runtime, Trade, Audit and UI libraries so the main indicator can remain a thin host.

CandidateState
  Full diagnostic result for one motive candidate evaluated by Core.
  Fields:
    valid (series bool)
    key (series string)
    direction (series int)
    stage (series int)
    score (series float)
    wave2Depth (series float)
    wave3Extension (series float)
    wave4Depth (series float)
    wave5ToWave1 (series float)
    invalidation (series float)
    invalidationType (series string)
    failure (series string)
    motiveType (series string)
    extensionType (series string)
    diagonalShape (series string)
    rule3Applicable (series bool)
    truncatedWave5 (series bool)

DegreeState
  Canonical motive-degree state. It is deliberately broad enough for Primary,
  Fields:
    active (series bool)
    key (series string)
    name (series string)
    direction (series int)
    stage (series int)
    score (series float)
    invalidation (series float)
    diagonal (series bool)
    provisional (series bool)
    motiveType (series string)
    extensionType (series string)
    rule3Applicable (series bool)
    truncatedWave5 (series bool)
    wave2Depth (series float)
    wave3Extension (series float)
    wave4Depth (series float)
    wave5ToWave1 (series float)
    modelScore (series float)
    nestedScore (series float)
    guidelineScore (series float)
    p0 (series float)
    p1 (series float)
    p2 (series float)
    p3 (series float)
    p4 (series float)
    p5 (series float)
    b0 (series int)
    b1 (series int)
    b2 (series int)
    b3 (series int)
    b4 (series int)
    b5 (series int)
    t0 (series int)
    t1 (series int)
    t2 (series int)
    t3 (series int)
    t4 (series int)
    t5 (series int)

CorrectionState
  Corrective structure state after a completed motive count.
  Fields:
    active (series bool)
    confirmed (series bool)
    hasProvisional (series bool)
    sequenceIntact (series bool)
    sourceKey (series string)
    sourceDirection (series int)
    sourceEndPivotId (series int)
    sourceWave1Length (series float)
    sourceMotive (series string)
    originPrice (series float)
    originBar (series int)
    originTime (series int)
    priorWave4 (series float)
    committedCount (series int)
    confirmedLegs (series int)
    confirmedEndPrice (series float)
    confirmedEndBar (series int)
    completeBar (series int)
    correctionType (series string)
    state (series string)
    familyWatch (series string)
    quality (series float)
    bRetracement (series float)
    bLiveRetracement (series float)
    cToA (series float)
    cProgress (series float)
    xRetracement (series float)
    confirmationLevel (series float)
    confirmationLabel (series string)
    c1 (series float)
    c2 (series float)
    c3 (series float)
    c4 (series float)
    c5 (series float)
    c6 (series float)
    c7 (series float)
    cb1 (series int)
    cb2 (series int)
    cb3 (series int)
    cb4 (series int)
    cb5 (series int)
    cb6 (series int)
    cb7 (series int)
    ct1 (series int)
    ct2 (series int)
    ct3 (series int)
    ct4 (series int)
    ct5 (series int)
    ct6 (series int)
    ct7 (series int)
    cp1 (series bool)
    cp2 (series bool)
    cp3 (series bool)
    cp4 (series bool)
    cp5 (series bool)
    cp6 (series bool)
    cp7 (series bool)

BootstrapState
  Bottom-up provisional parent hypothesis used only when a chart-TF Primary
  Fields:
    active (series bool)
    direction (series int)
    stage (series int)
    score (series float)
    invalidation (series float)
    status (series string)

ParentHypothesis
  Parent Wave-3 hypothesis produced by coarse/base structural searches.
  Fields:
    valid (series bool)
    score (series float)
    wave1Origin (series float)
    wave1End (series float)
    wave2End (series float)
    wave2Depth (series float)
    wave3Extension (series float)
    wave1OriginBar (series int)
    wave1EndBar (series int)
    wave2Bar (series int)
    usesBase (series bool)

DegreeResolutionState
  Result of local-vs-parent degree resolution.
  Fields:
    code (series int)
    confidence (series float)
    status (series string)
    nextWatch (series string)
    localInsideParent (series bool)
    localW5Provisional (series bool)
    localW5PullbackPct (series float)

ForecastState
  Local Potential-EW forecast plus its forward roadmap.
  Fields:
    active (series bool)
    key (series string)
    sourceKey (series string)
    forecastType (series string)
    pointType (series int)
    forecastBar (series int)
    forecastPrice (series float)
    score (series float)
    invalidation (series float)
    invalidationSide (series int)
    targetText (series string)
    correctionForecast (series bool)
    roadmapCode (series int)
    roadmapStartBar (series int)
    roadmapStartPrice (series float)
    roadmapPrice1 (series float)
    roadmapPrice2 (series float)
    roadmapPrice3 (series float)
    lifecycleState (series string)
    birthBar (series int)

ContextForecastState
  Higher-timeframe analytical Context EW roadmap. It never activates a trade.
  Fields:
    active (series bool)
    direction (series int)
    path (series string)
    score (series float)
    protectedLevel (series float)
    target1 (series float)
    target2 (series float)
    target3 (series float)
    tag1 (series string)
    tag2 (series string)
    tag3 (series string)
    lifecycleState (series string)

TradeSetup
  One immutable Elliott trade opportunity/plan. The same contract is used by
  Fields:
    active (series bool)
    waiting (series bool)
    live (series bool)
    countertrend (series bool)
    preferred (series bool)
    id (series string)
    sourceKey (series string)
    degree (series string)
    setupType (series string)
    state (series string)
    wave (series int)
    direction (series int)
    bornBar (series int)
    activatedBar (series int)
    score (series float)
    trigger (series float)
    zoneTop (series float)
    zoneBottom (series float)
    entry (series float)
    stop (series float)
    invalidation (series float)
    tp1 (series float)
    tp2 (series float)
    rr (series float)

TradeBridgePack
  Three-degree native higher-timeframe bridge in one requestable object.
  Fields:
    primary (TradeSetup)
    secondary (TradeSetup)
    subSecondary (TradeSetup)

TradeResolution
  Per-bar active-trade lifecycle resolution returned by Trade.
  Fields:
    eventCode (series int)
    state (series string)
    exitReason (series string)
    finalR (series float)
    exitPrice (series float)
    effectiveStop (series float)
    nextTp1Hit (series bool)
    nextBreakEvenArmed (series bool)
    nextBankedR (series float)
    tp1Event (series bool)
    tp2Event (series bool)
    stopEvent (series bool)
    breakEvenEvent (series bool)
    countInvalidEvent (series bool)

MtfState
  Runtime multi-timeframe state. Runtime /1 owns profile selection, Context,
  Fields:
    enabled (series bool)
    profileMode (series string)
    hierarchy (series string)
    contextTimeframe (series string)
    executionTimeframe (series string)
    confirmationTimeframe (series string)
    contextValid (series bool)
    executionValid (series bool)
    confirmationValid (series bool)
    contextDirection (series int)
    contextStage (series int)
    contextQuality (series float)
    contextInvalidation (series float)
    contextDiagonal (series bool)
    ltfDirection (series int)
    ltfSignalTime (series int)
    ltfAgeBars (series int)
    ltfFresh (series bool)
    motiveGatePass (series bool)
    correctionGatePass (series bool)
    gateText (series string)

EventState
  Compact event/audit packet. Audit /1 will own event generation and return only
  Fields:
    code (series int)
    lastEvent (series string)
    currentCountKey (series string)
    lastInvalidCountKey (series string)
    forecastKey (series string)
    tradeId (series string)
    countStarted (series bool)
    countRevised (series bool)
    countInvalidated (series bool)
    forecastNew (series bool)
    forecastRevised (series bool)
    forecastInvalidated (series bool)
    tradeWaiting (series bool)
    tradeActivated (series bool)
    tradeResolved (series bool)
    tradeCountInvalidExit (series bool)

EngineState
  Unified state graph used by the eventual thin 11.8c host. Runtime /1 will
  Fields:
    primary (DegreeState)
    secondary (DegreeState)
    subSecondary (DegreeState)
    correction (CorrectionState)
    bootstrap (BootstrapState)
    parent (ParentHypothesis)
    degreeResolution (DegreeResolutionState)
    forecast (ForecastState)
    contextForecast (ContextForecastState)
    mtf (MtfState)
    htfTrade (TradeBridgePack)
    events (EventState)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AYEHAN

//@version=6
// @description Cryptonian Elliott Wave shared data-model library. v1 contains schema only: no Elliott methodology, no trading rules and no rendering. It provides request-safe UDT contracts used by Core, Forecast, Runtime, Trade, Audit and UI libraries so the main indicator can remain a thin host.
library("CryptonianEWModel", overlay = true)

// ═════════════════════════════════════════════════════════════════════════════
// CRYPTONIAN ELLIOTT WAVE · SHARED MODEL /1
//
// Design rule:
// · This library owns DATA CONTRACTS only.
// · No Elliott interpretation may be changed here.
// · No trade decision may be created here.
// · No chart object is created here.
// · Requestable objects contain only request.security()-compatible fields.
//
// The purpose is to stop large tuple contracts and duplicate host variables from
// consuming the main indicator's compiled-token budget.
// ═════════════════════════════════════════════════════════════════════════════

// @type Full diagnostic result for one motive candidate evaluated by Core.
export type CandidateState
    bool valid = false
    string key = ""
    int direction = 0
    int stage = 0
    float score
    float wave2Depth
    float wave3Extension
    float wave4Depth
    float wave5ToWave1
    float invalidation
    string invalidationType = ""
    string failure = ""
    string motiveType = ""
    string extensionType = ""
    string diagonalShape = ""
    bool rule3Applicable = true
    bool truncatedWave5 = false

// @type Canonical motive-degree state. It is deliberately broad enough for Primary,
// Secondary, Sub-Secondary, Context and Bridge degrees. Unused fields remain na/empty.
export type DegreeState
    bool active = false
    string key = ""
    string name = ""
    int direction = 0
    int stage = 0
    float score
    float invalidation
    bool diagonal = false
    bool provisional = false
    string motiveType = ""
    string extensionType = ""
    bool rule3Applicable = true
    bool truncatedWave5 = false
    float wave2Depth
    float wave3Extension
    float wave4Depth
    float wave5ToWave1
    float modelScore
    float nestedScore
    float guidelineScore
    float p0
    float p1
    float p2
    float p3
    float p4
    float p5
    int b0
    int b1
    int b2
    int b3
    int b4
    int b5
    int t0
    int t1
    int t2
    int t3
    int t4
    int t5

// @type Corrective structure state after a completed motive count.
// Supports ABC, triangles and W-X-Y without forcing every caller to maintain its own
// parallel correction-variable block.
export type CorrectionState
    bool active = false
    bool confirmed = false
    bool hasProvisional = false
    bool sequenceIntact = true
    string sourceKey = ""
    int sourceDirection = 0
    int sourceEndPivotId
    float sourceWave1Length
    string sourceMotive = ""
    float originPrice
    int originBar
    int originTime
    float priorWave4
    int committedCount = 0
    int confirmedLegs = 0
    float confirmedEndPrice
    int confirmedEndBar
    int completeBar
    string correctionType = "—"
    string state = "NO COMPLETED IMPULSE"
    string familyWatch = "WAIT B"
    float quality
    float bRetracement
    float bLiveRetracement
    float cToA
    float cProgress
    float xRetracement
    float confirmationLevel
    string confirmationLabel = "—"
    float c1
    float c2
    float c3
    float c4
    float c5
    float c6
    float c7
    int cb1
    int cb2
    int cb3
    int cb4
    int cb5
    int cb6
    int cb7
    int ct1
    int ct2
    int ct3
    int ct4
    int ct5
    int ct6
    int ct7
    bool cp1 = false
    bool cp2 = false
    bool cp3 = false
    bool cp4 = false
    bool cp5 = false
    bool cp6 = false
    bool cp7 = false

// @type Bottom-up provisional parent hypothesis used only when a chart-TF Primary
// count does not yet exist.
export type BootstrapState
    bool active = false
    int direction = 0
    int stage = 0
    float score
    float invalidation
    string status = ""

// @type Parent Wave-3 hypothesis produced by coarse/base structural searches.
export type ParentHypothesis
    bool valid = false
    float score
    float wave1Origin
    float wave1End
    float wave2End
    float wave2Depth
    float wave3Extension
    int wave1OriginBar
    int wave1EndBar
    int wave2Bar
    bool usesBase = false

// @type Result of local-vs-parent degree resolution.
// code preserves the current contract:
// 0 local only, 1 HTF W3 continuation, 2 HTF W5 continuation,
// 3 HTF impulse complete, 4 degree conflict.
export type DegreeResolutionState
    int code = 0
    float confidence
    string status = "LOCAL DEGREE ONLY"
    string nextWatch = "STANDARD COMPLETION / CORRECTION"
    bool localInsideParent = false
    bool localW5Provisional = false
    float localW5PullbackPct

// @type Local Potential-EW forecast plus its forward roadmap.
export type ForecastState
    bool active = false
    string key = ""
    string sourceKey = ""
    string forecastType = "—"
    int pointType = 0
    int forecastBar
    float forecastPrice
    float score
    float invalidation
    int invalidationSide = 0
    string targetText = "—"
    bool correctionForecast = false
    int roadmapCode = 0
    int roadmapStartBar
    float roadmapStartPrice
    float roadmapPrice1
    float roadmapPrice2
    float roadmapPrice3
    string lifecycleState = "NONE"
    int birthBar

// @type Higher-timeframe analytical Context EW roadmap. It never activates a trade.
export type ContextForecastState
    bool active = false
    int direction = 0
    string path = "NONE"
    float score
    float protectedLevel
    float target1
    float target2
    float target3
    string tag1 = ""
    string tag2 = ""
    string tag3 = ""
    string lifecycleState = "NONE"

// @type One immutable Elliott trade opportunity/plan. The same contract is used by
// local universal opportunities and HTF bridge candidates.
export type TradeSetup
    bool active = false
    bool waiting = false
    bool live = false
    bool countertrend = false
    bool preferred = false
    string id = ""
    string sourceKey = ""
    string degree = ""
    string setupType = ""
    string state = "IDLE"
    int wave = 0
    int direction = 0
    int bornBar
    int activatedBar
    float score
    float trigger
    float zoneTop
    float zoneBottom
    float entry
    float stop
    float invalidation
    float tp1
    float tp2
    float rr

// @type Three-degree native higher-timeframe bridge in one requestable object.
// Trade /13 will replace the current 24 primitive bridge fields with this nested pack.
export type TradeBridgePack
    TradeSetup primary
    TradeSetup secondary
    TradeSetup subSecondary

// @type Per-bar active-trade lifecycle resolution returned by Trade.
// Event codes preserve the current Trade /12 state machine contract.
export type TradeResolution
    int eventCode = 0
    string state = ""
    string exitReason = ""
    float finalR
    float exitPrice
    float effectiveStop
    bool nextTp1Hit = false
    bool nextBreakEvenArmed = false
    float nextBankedR
    bool tp1Event = false
    bool tp2Event = false
    bool stopEvent = false
    bool breakEvenEvent = false
    bool countInvalidEvent = false

// @type Runtime multi-timeframe state. Runtime /1 owns profile selection, Context,
// Execution and Confirmation state and returns this object to the host.
export type MtfState
    bool enabled = false
    string profileMode = ""
    string hierarchy = ""
    string contextTimeframe = ""
    string executionTimeframe = ""
    string confirmationTimeframe = ""
    bool contextValid = false
    bool executionValid = false
    bool confirmationValid = false
    int contextDirection = 0
    int contextStage = 0
    float contextQuality
    float contextInvalidation
    bool contextDiagonal = false
    int ltfDirection = 0
    int ltfSignalTime
    int ltfAgeBars
    bool ltfFresh = false
    bool motiveGatePass = false
    bool correctionGatePass = false
    string gateText = ""

// @type Compact event/audit packet. Audit /1 will own event generation and return only
// this packet instead of leaving event bookkeeping spread throughout the main script.
export type EventState
    int code = 0
    string lastEvent = ""
    string currentCountKey = ""
    string lastInvalidCountKey = ""
    string forecastKey = ""
    string tradeId = ""
    bool countStarted = false
    bool countRevised = false
    bool countInvalidated = false
    bool forecastNew = false
    bool forecastRevised = false
    bool forecastInvalidated = false
    bool tradeWaiting = false
    bool tradeActivated = false
    bool tradeResolved = false
    bool tradeCountInvalidExit = false

// @type Unified state graph used by the eventual thin 11.8c host. Runtime /1 will
// progressively become the owner of constructing this graph as migration proceeds.
export type EngineState
    DegreeState primary
    DegreeState secondary
    DegreeState subSecondary
    CorrectionState correction
    BootstrapState bootstrap
    ParentHypothesis parent
    DegreeResolutionState degreeResolution
    ForecastState forecast
    ContextForecastState contextForecast
    MtfState mtf
    TradeBridgePack htfTrade
    EventState events
````
