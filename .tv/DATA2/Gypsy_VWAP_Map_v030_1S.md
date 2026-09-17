<!-- tradingview-pine-id: PUB;fa029e5d0df2460abcd1534308779926 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Gypsy VWAP Map v0.30 1S

Source: https://www.tradingview.com/script/Wl9x7fWz-Gypsy-VWAP-Map-v0-30-Premium-TradingView-Req/

## Description

Gypsy VWAP Map is a descriptive spatial map built around session-anchored VWAP. It is designed to show how price occupies and traverses recurring VWAP-relative displacement regions—not to generate buy/sell signals or predict reactions.

VWAP can reset at the Globex, London, and/or New York session anchors. I personally use all three, there is also an option for just NY + Globex.

The automatic map learns four independent relationships:

• Above VWAP — Adaptive
• Above VWAP — Persistent
• Below VWAP — Adaptive
• Below VWAP — Persistent

Adaptive relationships emphasize newer evidence and can migrate more quickly when recent excursion behavior changes. Persistent relationships retain more historical evidence and adjust more slowly. Adaptive does not necessarily mean nearer, and Persistent does not necessarily mean farther; the relationships may converge, diverge, overlap, or cross.

There are manual entries for static lines away from VWAP, I change these every once in a while to match current price action (like once a day maybe) but the defaults are a good starting point. Previously the top and bottom lines were locked into the same interval, but separating them allows mapping of nonidentical relationships relative to vwap. 

Compare mode combines the automatic relationships with independently configured Manual boundaries. All available boundaries are sorted by their actual distance from VWAP. The colored fields represent fixed spatial intervals between those boundaries, rather than the identity of any particular line or a directional market opinion.

You can use only manual, only auto, or compare mode. Ironically Compare was made for testing, but I ended up liking both sets of lines so I use Compare exclusively.

Candle highs and lows determine which portions of the field have physically been reached. Automatic evidence is admitted only after its selected calculation bar closes. The indicator does not project future structures or complete shapes beyond observed price action.

The 1-second build uses a one-second main calculation stream, with Adaptive defaulting to 30-second evidence and Persistent defaulting to 1-minute evidence. It requires access to TradingView second-based data.

The 1-minute build requires no second-data access. Both Adaptive and Persistent relationships use confirmed one-minute evidence, producing a slower and more conservative map.

Changing indicator inputs causes TradingView to recalculate the loaded history using the new configuration. For consistent comparison, leave the native Calculation timeframe at the build’s designated value: 1 second for the 1S version or 1 minute for the 1M version. Personally I find 1s too busy, I generally use the 5s on a 5s and 5m chart. 

This indicator is intended as a neutral framework for studying VWAP-relative market behavior alongside the user’s own structure and analysis.

v0.30

• Promoted the tested Adaptive/Persistent research model to the production 1S and 1M builds.

• Replaced the earlier Near/Far automatic model with four independently learned relationships.

• Added stable spatial color ranking in Compare mode.

• Overlapping boundaries now retain their ranking positions without recoloring or stretching farther zones.

• Added separate high-resolution 1S and broadly compatible 1M versions.

---

## Source Code

````pine
//@version=6
indicator("Gypsy VWAP Map v0.30 1S", shorttitle = "VWAP 1S", overlay = true, behind_chart = true, format = format.price, max_bars_back = 5000, timeframe = "1S", timeframe_gaps = false)

// Every band is a neutral VWAP-relative reference. The soft field accumulates
// outward from VWAP: reaching a farther displacement also paints every nearer
// layer beneath it. It does not assign support/resistance, predict a path, or
// complete future shapes.

// ── Display ──────────────────────────────────────────────────────────────────
mode = input.string("Compare", "Mode", options = ["Manual", "Auto", "Compare"], display = display.none)

manualColor     = input.color(color.new(#9C27B0, 63), "Manual lines", group = "Display")
adaptiveColor   = input.color(color.new(#F57F17, 42), "Adaptive relationships", group = "Display")
persistentColor = input.color(color.new(#64B5F6, 42), "Persistent relationships", group = "Display")
vwapColor       = input.color(color.new(#6B7280, 0), "VWAP", group = "Display")
bandWidth       = input.int(1, "Band width", minval = 1, maxval = 4, group = "Display", display = display.none)

showManual = mode == "Manual" or mode == "Compare"
showAuto   = mode == "Auto" or mode == "Compare"

// ── Manual displacements (points, all independent) ──────────────────────────
manualUpperNear = input.float(50.0,  "Upper 1", minval = 0.0, step = 0.25, group = "Manual displacements", display = display.none)
manualUpperFar  = input.float(300.0, "Upper 2", minval = 0.0, step = 0.25, group = "Manual displacements", display = display.none)
manualLowerNear = input.float(50.0,  "Lower 1", minval = 0.0, step = 0.25, group = "Manual displacements", display = display.none)
manualLowerFar  = input.float(300.0, "Lower 2", minval = 0.0, step = 0.25, group = "Manual displacements", display = display.none)

// ── Selected VWAP anchors ────────────────────────────────────────────────────
// Every selected reset begins a distinct VWAP and automatic-calibration segment.
string vwapTimezone = input.string("America/New_York", "Reset timezone", group = "VWAP", display = display.none)
string vwapAnchorMode = input.string("Globex + London + New York", "VWAP anchors", options = ["Globex only", "New York only", "Globex + New York", "Globex + London + New York"], tooltip = "Testing selector. Globex resets at 18:00 ET, London at 03:00 ET, and New York at 09:30 ET. Combined modes reset at each named anchor.", group = "VWAP", display = display.none)
int shiftedTime = time + 6 * 60 * 60 * 1000
bool newVwapDay = ta.change(dayofmonth(shiftedTime, vwapTimezone)) != 0
int nyResetTimestamp = timestamp(vwapTimezone, year(time, vwapTimezone), month(time, vwapTimezone), dayofmonth(time, vwapTimezone), 9, 30)
int londonResetTimestamp = timestamp(vwapTimezone, year(time, vwapTimezone), month(time, vwapTimezone), dayofmonth(time, vwapTimezone), 3, 0)
bool newNySession = time >= nyResetTimestamp and nz(time[1], time - 1) < nyResetTimestamp
bool newLondonSession = time >= londonResetTimestamp and nz(time[1], time - 1) < londonResetTimestamp
bool newVwapAnchor = vwapAnchorMode == "Globex only" ? newVwapDay : vwapAnchorMode == "New York only" ? newNySession : vwapAnchorMode == "Globex + London + New York" ? newVwapDay or newLondonSession or newNySession : newVwapDay or newNySession

// The live segment is identified from the latest selected scheduled anchor, not
// from a futures trade date. This keeps London/New York segments distinct when
// a combined anchor mode creates more than one VWAP segment in the same day.
f_mostRecentDailyAnchor(int referenceTime, int anchorHour, int anchorMinute, string timezone) =>
    int sameDayAnchor = timestamp(timezone, year(referenceTime, timezone), month(referenceTime, timezone), dayofmonth(referenceTime, timezone), anchorHour, anchorMinute)
    int previousDayProbe = referenceTime - 24 * 60 * 60 * 1000
    int previousDayAnchor = timestamp(timezone, year(previousDayProbe, timezone), month(previousDayProbe, timezone), dayofmonth(previousDayProbe, timezone), anchorHour, anchorMinute)
    referenceTime >= sameDayAnchor ? sameDayAnchor : previousDayAnchor

int latestGlobexAnchor = f_mostRecentDailyAnchor(last_bar_time, 18, 0, vwapTimezone)
int latestLondonAnchor = f_mostRecentDailyAnchor(last_bar_time, 3, 0, vwapTimezone)
int latestNewYorkAnchor = f_mostRecentDailyAnchor(last_bar_time, 9, 30, vwapTimezone)
int latestSelectedAnchorStart = vwapAnchorMode == "Globex only" ? latestGlobexAnchor : vwapAnchorMode == "New York only" ? latestNewYorkAnchor : vwapAnchorMode == "Globex + London + New York" ? math.max(latestGlobexAnchor, math.max(latestLondonAnchor, latestNewYorkAnchor)) : math.max(latestGlobexAnchor, latestNewYorkAnchor)
bool isLiveVwapSegment = time >= latestSelectedAnchorStart

var int vwapSegmentId = 0

if barstate.isfirst or newVwapAnchor
    vwapSegmentId += 1

var float cumulativePV = na
var float cumulativeVolume = na

if barstate.isfirst or newVwapAnchor
    cumulativePV := hlc3 * volume
    cumulativeVolume := volume
else
    cumulativePV += hlc3 * volume
    cumulativeVolume += volume

float sessionVwap = cumulativeVolume > 0 ? cumulativePV / cumulativeVolume : na

// ── Automatic relationships ────────────────────────────────────────────────
// Adaptive and Persistent are independent estimators. Neither role implies a
// distance ordering. Both currently use confirmed same-side pivots as the sole
// provisional evidence event; traversal/confidence semantics come later.
const string ADAPTIVE_GROUP = "ADAPTIVE RELATIONSHIP"
adaptiveTimeframe     = input.string("30S", "Calculation timeframe", options = ["1S", "5S", "15S", "30S", "1"], group = ADAPTIVE_GROUP, display = display.none)
adaptivePivotLeft     = input.int(3, "Bars left", minval = 1, maxval = 20, group = ADAPTIVE_GROUP, display = display.none)
adaptivePivotRight    = input.int(3, "Bars right (confirmation delay)", minval = 1, maxval = 20, group = ADAPTIVE_GROUP, display = display.none)
adaptiveMemory        = input.int(24, "Retained interactions per side", minval = 4, maxval = 250, group = ADAPTIVE_GROUP, display = display.none)
adaptiveMinimumCount  = input.int(4, "Minimum interactions", minval = 2, maxval = 50, group = ADAPTIVE_GROUP, display = display.none)
adaptiveMaximumCV     = input.float(0.85, "Maximum evidence variation", minval = 0.05, maxval = 3.0, step = 0.05, group = ADAPTIVE_GROUP, display = display.none)
adaptiveRecentWeight  = input.float(3.0, "Newest/oldest evidence weight", minval = 1.0, maxval = 10.0, step = 0.25, group = ADAPTIVE_GROUP, display = display.none)
adaptiveRecalcEvery   = input.int(1, "New interactions before recalculation", minval = 1, maxval = 20, group = ADAPTIVE_GROUP, display = display.none)
adaptiveMaxStep       = input.float(25.0, "Maximum migration per recalculation (%)", minval = 1.0, maxval = 100.0, step = 1.0, group = ADAPTIVE_GROUP, display = display.none) / 100.0

const string PERSISTENT_GROUP = "PERSISTENT RELATIONSHIP"
persistentTimeframe    = input.string("1", "Calculation timeframe", options = ["1S", "5S", "15S", "30S", "1"], group = PERSISTENT_GROUP, display = display.none)
persistentPivotLeft    = input.int(3, "Bars left", minval = 1, maxval = 20, group = PERSISTENT_GROUP, display = display.none)
persistentPivotRight   = input.int(3, "Bars right (confirmation delay)", minval = 1, maxval = 20, group = PERSISTENT_GROUP, display = display.none)
persistentMemory       = input.int(80, "Retained interactions per side", minval = 4, maxval = 250, group = PERSISTENT_GROUP, display = display.none)
persistentMinimumCount = input.int(8, "Minimum interactions", minval = 2, maxval = 50, group = PERSISTENT_GROUP, display = display.none)
persistentMaximumCV    = input.float(0.70, "Maximum evidence variation", minval = 0.05, maxval = 3.0, step = 0.05, group = PERSISTENT_GROUP, display = display.none)
persistentRecentWeight = input.float(1.25, "Newest/oldest evidence weight", minval = 1.0, maxval = 10.0, step = 0.25, group = PERSISTENT_GROUP, display = display.none)
persistentRecalcEvery  = input.int(4, "New interactions before recalculation", minval = 1, maxval = 20, group = PERSISTENT_GROUP, display = display.none)
persistentMaxStep      = input.float(6.0, "Maximum migration per recalculation (%)", minval = 1.0, maxval = 100.0, step = 1.0, group = PERSISTENT_GROUP, display = display.none) / 100.0

showRelationshipDebug = input.bool(false, "Show relationship diagnostics in Data Window", group = "DIAGNOSTICS")

// ── Cumulative VWAP field ────────────────────────────────────────────────────
// Colors identify displacement depth, never direction. Farther layers are
// added outside nearer layers; they never replace them or float independently.
// Compare mode preserves every Manual and Auto line as a separate step in one
// spatially ordered ladder. Source identity never chooses or deletes a step.
const string BODY_GROUP = "CUMULATIVE VWAP FIELD"
showBehaviorBodies = input.bool(true, "Show cumulative shading", group = BODY_GROUP)
nearLayerColor = input.color(color.new(#E78C99, 76), "Layer 1 - VWAP to first band", group = BODY_GROUP)
compareStepOneColor = input.color(color.new(#B894C8, 64), "Compare Layer 2 - first added interval", tooltip = "Only used in Compare mode. This is the first extra spatial step created when the Manual and Auto levels are both retained.", group = BODY_GROUP)
middleLayerColor = input.color(color.new(#26C6DA, 77), "Middle displacement layer", group = BODY_GROUP)
compareStepTwoColor = input.color(color.new(#4CAF50, 88), "Compare Layer 4 - second added interval", tooltip = "Only used in Compare mode. This is the second extra spatial step created when the Manual and Auto levels are both retained.", group = BODY_GROUP)
farLayerColor = input.color(color.new(#FF6D00, 88), "Outermost displacement layer", group = BODY_GROUP)
probeTransparency = input.int(93, "Unconfirmed probe transparency", minval = 88, maxval = 99, tooltip = "A boundary touch appears immediately but remains faint until transition evidence establishes the neighboring displacement state.", group = BODY_GROUP, display = display.none)
showBoundaryInvasion = input.bool(true, "Show contested boundary invasion", tooltip = "After repeated straddles, the incumbent layer color persists across the challenged boundary until the contest flips or fails.", group = BODY_GROUP)
maximumInvasionOpacity = input.int(14, "Maximum invasion opacity (%)", minval = 2, maxval = 35, tooltip = "Controls only the incumbent-color ribbon inside a contested neighboring layer.", group = BODY_GROUP, display = display.none)
bodyAtrLength = input.int(30, "ATR normalization", minval = 5, maxval = 200, group = BODY_GROUP, display = display.none)
minimumOccupationAtr = input.float(0.06, "Minimum field depth (ATR)", minval = 0.0, maxval = 2.0, step = 0.01, tooltip = "Suppresses visually meaningless slivers while retaining wick-based interactions. This is not a close confirmation.", group = BODY_GROUP, display = display.none)

const string TRANSITION_GROUP = "REFERENCE TRANSITIONS"
volumeLookback = input.int(50, "Relative-volume lookback", minval = 10, maxval = 500, group = TRANSITION_GROUP, display = display.none)
volumeInfluence = input.float(0.35, "Volume influence", minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "Zero resolves contested boundaries from time alone. One gives relative volume and candle occupation maximum influence. Missing volume automatically falls back to time.", group = TRANSITION_GROUP, display = display.none)
evidenceMemory = input.int(10, "Contest evidence memory", minval = 2, maxval = 100, group = TRANSITION_GROUP, display = display.none)
minimumCandidateBars = input.int(3, "Minimum occupied bars to switch", minval = 2, maxval = 20, tooltip = "A single candle can never complete a color/reference switch, regardless of its volume.", group = TRANSITION_GROUP, display = display.none)
transitionDominance = input.float(1.35, "Evidence required to switch", minval = 1.0, maxval = 5.0, step = 0.05, group = TRANSITION_GROUP, display = display.none)
maximumContestBars = input.int(14, "Maximum contested bars", minval = 3, maxval = 100, group = TRANSITION_GROUP, display = display.none)

// The source function runs wholly inside the requested canonical context. Its
// [1] inputs plus lookahead_on expose only the last closed source bar. VWAP,
// pivot detection, segment identity, and the evidence distance therefore share
// one canonical stream and cannot inherit the host chart timeframe.
f_sourceEvidence(int leftBars, int rightBars) =>
    bool sourceReset = newVwapAnchor[1]
    bool sourceValid = not na(time[1]) and not na(hlc3[1]) and not na(volume[1])
    var int sourceSegmentId = 0
    var float sourceCumulativePV = na
    var float sourceCumulativeVolume = na
    if sourceValid
        if na(sourceCumulativePV) or sourceReset
            sourceSegmentId += 1
            sourceCumulativePV := hlc3[1] * volume[1]
            sourceCumulativeVolume := volume[1]
        else
            sourceCumulativePV += hlc3[1] * volume[1]
            sourceCumulativeVolume += volume[1]
    float sourceVwap = sourceCumulativeVolume > 0 ? sourceCumulativePV / sourceCumulativeVolume : na
    float sourceConfirmedHigh = ta.pivothigh(high[1], leftBars, rightBars)
    float sourceConfirmedLow = ta.pivotlow(low[1], leftBars, rightBars)
    float sourcePivotVwap = sourceVwap[rightBars]
    int sourcePivotSegmentId = sourceSegmentId[rightBars]
    bool sourcePivotBelongs = not na(sourcePivotSegmentId) and sourcePivotSegmentId == sourceSegmentId
    float aboveEvidence = sourcePivotBelongs and not na(sourceConfirmedHigh) and not na(sourcePivotVwap) and sourceConfirmedHigh > sourcePivotVwap ? sourceConfirmedHigh - sourcePivotVwap : na
    float belowEvidence = sourcePivotBelongs and not na(sourceConfirmedLow) and not na(sourcePivotVwap) and sourceConfirmedLow < sourcePivotVwap ? sourcePivotVwap - sourceConfirmedLow : na
    [aboveEvidence, belowEvidence, time_close[1], sourceVwap]

[adaptiveAboveEvidence, adaptiveBelowEvidence, adaptiveEvidenceTime, adaptiveSourceVwap] = request.security(syminfo.tickerid, adaptiveTimeframe, f_sourceEvidence(adaptivePivotLeft, adaptivePivotRight), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[persistentAboveEvidence, persistentBelowEvidence, persistentEvidenceTime, persistentSourceVwap] = request.security(syminfo.tickerid, persistentTimeframe, f_sourceEvidence(persistentPivotLeft, persistentPivotRight), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

bool adaptiveSourceBarClosed = not na(adaptiveEvidenceTime) and (na(adaptiveEvidenceTime[1]) or adaptiveEvidenceTime != adaptiveEvidenceTime[1])
bool persistentSourceBarClosed = not na(persistentEvidenceTime) and (na(persistentEvidenceTime[1]) or persistentEvidenceTime != persistentEvidenceTime[1])

var array<float> aboveAdaptiveSamples = array.new_float()
var array<int> aboveAdaptiveTimes = array.new_int()
var array<float> belowAdaptiveSamples = array.new_float()
var array<int> belowAdaptiveTimes = array.new_int()
var array<float> abovePersistentSamples = array.new_float()
var array<int> abovePersistentTimes = array.new_int()
var array<float> belowPersistentSamples = array.new_float()
var array<int> belowPersistentTimes = array.new_int()

var int aboveAdaptiveSinceUpdate = 0
var int belowAdaptiveSinceUpdate = 0
var int abovePersistentSinceUpdate = 0
var int belowPersistentSinceUpdate = 0
var float aboveAdaptiveDistance = na
var float belowAdaptiveDistance = na
var float abovePersistentDistance = na
var float belowPersistentDistance = na
var bool aboveAdaptiveReady = false
var bool belowAdaptiveReady = false
var bool abovePersistentReady = false
var bool belowPersistentReady = false
var float aboveAdaptiveCV = na
var float belowAdaptiveCV = na
var float abovePersistentCV = na
var float belowPersistentCV = na
var int aboveAdaptiveLastRecalc = na
var int belowAdaptiveLastRecalc = na
var int abovePersistentLastRecalc = na
var int belowPersistentLastRecalc = na

f_pushEvidence(array<float> samples, array<int> timestamps, float value, int eventTime, int limit) =>
    if not na(value) and value > syminfo.mintick and not na(eventTime)
        array.push(samples, value)
        array.push(timestamps, eventTime)
        if array.size(samples) > limit
            array.shift(samples)
            array.shift(timestamps)

// A role estimates one relationship from its own evidence population. Linear
// recency weighting is intentionally simple and configurable. There is
// no second center, distance rank, proportional pair, or separation test.
f_relationshipEstimate(array<float> samples, int minimumCount, float allowedCV, float newestWeight) =>
    int size = array.size(samples)
    bool qualified = false
    float center = na
    float cv = na
    if size >= minimumCount
        float weightedSum = 0.0
        float totalWeight = 0.0
        for i = 0 to size - 1
            float progress = size > 1 ? i * 1.0 / (size - 1) : 1.0
            float weight = 1.0 + (newestWeight - 1.0) * progress
            weightedSum += array.get(samples, i) * weight
            totalWeight += weight
        center := totalWeight > 0 ? weightedSum / totalWeight : na
        float weightedSquared = 0.0
        for i = 0 to size - 1
            float progress = size > 1 ? i * 1.0 / (size - 1) : 1.0
            float weight = 1.0 + (newestWeight - 1.0) * progress
            weightedSquared += math.pow(array.get(samples, i) - center, 2) * weight
        float deviation = totalWeight > 0 ? math.sqrt(weightedSquared / totalWeight) : na
        cv := center > 0 ? deviation / center : na
        qualified := not na(cv) and cv <= allowedCV
    [qualified, center, cv, size]

f_cappedUpdate(float current, float candidate, float capPercent) =>
    float result = candidate
    if not na(current)
        float maximumStep = math.max(current * capPercent, syminfo.mintick)
        result := current + math.max(-maximumStep, math.min(maximumStep, candidate - current))
    result

f_evidenceAge(array<int> timestamps, bool newest, int referenceTime) =>
    float result = na
    int size = array.size(timestamps)
    if size > 0
        int evidenceTime = newest ? array.get(timestamps, size - 1) : array.get(timestamps, 0)
        result := math.max(referenceTime - evidenceTime, 0) / 1000.0
    result

f_timestampAge(int timestampValue, int referenceTime) =>
    not na(timestampValue) ? math.max(referenceTime - timestampValue, 0) / 1000.0 : na

// Relationship evidence is segment-local. Reset before admitting a source event
// so the closed source bar immediately preceding an anchor cannot seed the new
// segment. Each role and side qualifies, migrates, and disappears independently.
if barstate.isfirst or newVwapAnchor
    array.clear(aboveAdaptiveSamples)
    array.clear(aboveAdaptiveTimes)
    array.clear(belowAdaptiveSamples)
    array.clear(belowAdaptiveTimes)
    array.clear(abovePersistentSamples)
    array.clear(abovePersistentTimes)
    array.clear(belowPersistentSamples)
    array.clear(belowPersistentTimes)
    aboveAdaptiveSinceUpdate := 0
    belowAdaptiveSinceUpdate := 0
    abovePersistentSinceUpdate := 0
    belowPersistentSinceUpdate := 0
    aboveAdaptiveDistance := na
    belowAdaptiveDistance := na
    abovePersistentDistance := na
    belowPersistentDistance := na
    aboveAdaptiveReady := false
    belowAdaptiveReady := false
    abovePersistentReady := false
    belowPersistentReady := false
    aboveAdaptiveCV := na
    belowAdaptiveCV := na
    abovePersistentCV := na
    belowPersistentCV := na
    aboveAdaptiveLastRecalc := na
    belowAdaptiveLastRecalc := na
    abovePersistentLastRecalc := na
    belowPersistentLastRecalc := na

if adaptiveSourceBarClosed and not newVwapAnchor
    if not na(adaptiveAboveEvidence)
        f_pushEvidence(aboveAdaptiveSamples, aboveAdaptiveTimes, adaptiveAboveEvidence, adaptiveEvidenceTime, adaptiveMemory)
        aboveAdaptiveSinceUpdate += 1
    if not na(adaptiveBelowEvidence)
        f_pushEvidence(belowAdaptiveSamples, belowAdaptiveTimes, adaptiveBelowEvidence, adaptiveEvidenceTime, adaptiveMemory)
        belowAdaptiveSinceUpdate += 1

if persistentSourceBarClosed and not newVwapAnchor
    if not na(persistentAboveEvidence)
        f_pushEvidence(abovePersistentSamples, abovePersistentTimes, persistentAboveEvidence, persistentEvidenceTime, persistentMemory)
        abovePersistentSinceUpdate += 1
    if not na(persistentBelowEvidence)
        f_pushEvidence(belowPersistentSamples, belowPersistentTimes, persistentBelowEvidence, persistentEvidenceTime, persistentMemory)
        belowPersistentSinceUpdate += 1

if aboveAdaptiveSinceUpdate >= adaptiveRecalcEvery
    [candidateReady, candidateDistance, candidateCV, candidateCount] = f_relationshipEstimate(aboveAdaptiveSamples, adaptiveMinimumCount, adaptiveMaximumCV, adaptiveRecentWeight)
    aboveAdaptiveReady := candidateReady
    aboveAdaptiveCV := candidateCV
    if candidateReady
        aboveAdaptiveDistance := f_cappedUpdate(aboveAdaptiveDistance, candidateDistance, adaptiveMaxStep)
    else
        aboveAdaptiveDistance := na
    aboveAdaptiveLastRecalc := adaptiveEvidenceTime
    aboveAdaptiveSinceUpdate := 0

if belowAdaptiveSinceUpdate >= adaptiveRecalcEvery
    [candidateReady, candidateDistance, candidateCV, candidateCount] = f_relationshipEstimate(belowAdaptiveSamples, adaptiveMinimumCount, adaptiveMaximumCV, adaptiveRecentWeight)
    belowAdaptiveReady := candidateReady
    belowAdaptiveCV := candidateCV
    if candidateReady
        belowAdaptiveDistance := f_cappedUpdate(belowAdaptiveDistance, candidateDistance, adaptiveMaxStep)
    else
        belowAdaptiveDistance := na
    belowAdaptiveLastRecalc := adaptiveEvidenceTime
    belowAdaptiveSinceUpdate := 0

if abovePersistentSinceUpdate >= persistentRecalcEvery
    [candidateReady, candidateDistance, candidateCV, candidateCount] = f_relationshipEstimate(abovePersistentSamples, persistentMinimumCount, persistentMaximumCV, persistentRecentWeight)
    abovePersistentReady := candidateReady
    abovePersistentCV := candidateCV
    if candidateReady
        abovePersistentDistance := f_cappedUpdate(abovePersistentDistance, candidateDistance, persistentMaxStep)
    else
        abovePersistentDistance := na
    abovePersistentLastRecalc := persistentEvidenceTime
    abovePersistentSinceUpdate := 0

if belowPersistentSinceUpdate >= persistentRecalcEvery
    [candidateReady, candidateDistance, candidateCV, candidateCount] = f_relationshipEstimate(belowPersistentSamples, persistentMinimumCount, persistentMaximumCV, persistentRecentWeight)
    belowPersistentReady := candidateReady
    belowPersistentCV := candidateCV
    if candidateReady
        belowPersistentDistance := f_cappedUpdate(belowPersistentDistance, candidateDistance, persistentMaxStep)
    else
        belowPersistentDistance := na
    belowPersistentLastRecalc := persistentEvidenceTime
    belowPersistentSinceUpdate := 0

// ── Plots ────────────────────────────────────────────────────────────────────
vwapPlot = plot(sessionVwap, "VWAP", color = vwapColor, linewidth = 2, style = plot.style_linebr, display = display.all - display.status_line)

bool aboveHasAnyAuto = aboveAdaptiveReady or abovePersistentReady
bool belowHasAnyAuto = belowAdaptiveReady or belowPersistentReady

// Manual is intentionally a live-segment source only. In Auto mode its labeled
// lines remain visible only while that side has no qualified automatic boundary.
bool showLiveManualUpper = isLiveVwapSegment and (showManual or mode == "Auto" and not aboveHasAnyAuto)
bool showLiveManualLower = isLiveVwapSegment and (showManual or mode == "Auto" and not belowHasAnyAuto)
manualU1Plot = plot(showLiveManualUpper ? sessionVwap + manualUpperNear : na, "Manual U1", color = manualColor, linewidth = bandWidth, style = plot.style_linebr, display = display.all - display.status_line)
manualU2Plot = plot(showLiveManualUpper ? sessionVwap + manualUpperFar : na, "Manual U2", color = manualColor, linewidth = bandWidth, style = plot.style_linebr, display = display.all - display.status_line)
manualL1Plot = plot(showLiveManualLower ? sessionVwap - manualLowerNear : na, "Manual L1", color = manualColor, linewidth = bandWidth, style = plot.style_linebr, display = display.all - display.status_line)
manualL2Plot = plot(showLiveManualLower ? sessionVwap - manualLowerFar : na, "Manual L2", color = manualColor, linewidth = bandWidth, style = plot.style_linebr, display = display.all - display.status_line)

// Each relationship exists only after its own evidence population qualifies.
// Adaptive and Persistent are independent and can cross, converge, or exist
// alone. No missing relationship receives a manufactured companion.
bool showAutoForSegment = not isLiveVwapSegment or showAuto
float aboveAdaptivePath = showAutoForSegment and aboveAdaptiveReady ? sessionVwap + aboveAdaptiveDistance : na
float abovePersistentPath = showAutoForSegment and abovePersistentReady ? sessionVwap + abovePersistentDistance : na
float belowAdaptivePath = showAutoForSegment and belowAdaptiveReady ? sessionVwap - belowAdaptiveDistance : na
float belowPersistentPath = showAutoForSegment and belowPersistentReady ? sessionVwap - belowPersistentDistance : na

aboveAdaptivePlot = plot(aboveAdaptivePath, "Above Adaptive", color = adaptiveColor, linewidth = bandWidth, style = plot.style_linebr, display = display.all - display.status_line)
abovePersistentPlot = plot(abovePersistentPath, "Above Persistent", color = persistentColor, linewidth = bandWidth, style = plot.style_linebr, display = display.all - display.status_line)
belowAdaptivePlot = plot(belowAdaptivePath, "Below Adaptive", color = adaptiveColor, linewidth = bandWidth, style = plot.style_linebr, display = display.all - display.status_line)
belowPersistentPlot = plot(belowPersistentPath, "Below Persistent", color = persistentColor, linewidth = bandWidth, style = plot.style_linebr, display = display.all - display.status_line)

// Phase-one diagnostics live only in TradingView's Data Window. The visible
// relationship/VWAP plots already expose current prices, and the selected
// calculation intervals remain visible in Settings, so those redundant debug
// plots are omitted to remain below Pine's 64-plot-count ceiling.
int diagnosticTime = time_close
plot(showRelationshipDebug ? array.size(aboveAdaptiveSamples) : na, "Debug Above Adaptive evidence count", display = display.data_window)
plot(showRelationshipDebug ? f_evidenceAge(aboveAdaptiveTimes, true, diagnosticTime) : na, "Debug Above Adaptive newest evidence age (s)", display = display.data_window)
plot(showRelationshipDebug ? f_timestampAge(aboveAdaptiveLastRecalc, diagnosticTime) : na, "Debug Above Adaptive last recalculation age (s)", display = display.data_window)

plot(showRelationshipDebug ? array.size(belowAdaptiveSamples) : na, "Debug Below Adaptive evidence count", display = display.data_window)
plot(showRelationshipDebug ? f_evidenceAge(belowAdaptiveTimes, true, diagnosticTime) : na, "Debug Below Adaptive newest evidence age (s)", display = display.data_window)
plot(showRelationshipDebug ? f_timestampAge(belowAdaptiveLastRecalc, diagnosticTime) : na, "Debug Below Adaptive last recalculation age (s)", display = display.data_window)

plot(showRelationshipDebug ? array.size(abovePersistentSamples) : na, "Debug Above Persistent evidence count", display = display.data_window)
plot(showRelationshipDebug ? f_evidenceAge(abovePersistentTimes, true, diagnosticTime) : na, "Debug Above Persistent newest evidence age (s)", display = display.data_window)
plot(showRelationshipDebug ? f_timestampAge(abovePersistentLastRecalc, diagnosticTime) : na, "Debug Above Persistent last recalculation age (s)", display = display.data_window)

plot(showRelationshipDebug ? array.size(belowPersistentSamples) : na, "Debug Below Persistent evidence count", display = display.data_window)
plot(showRelationshipDebug ? f_evidenceAge(belowPersistentTimes, true, diagnosticTime) : na, "Debug Below Persistent newest evidence age (s)", display = display.data_window)
plot(showRelationshipDebug ? f_timestampAge(belowPersistentLastRecalc, diagnosticTime) : na, "Debug Below Persistent last recalculation age (s)", display = display.data_window)

// ── Ordered Manual/Auto displacement ladder ─────────────────────────────────
// Only real, available boundaries enter this sorter. Missing Auto values stay na
// and never participate in sorting or field construction. Overlapping values
// retain separate rank slots so every farther spatial color remains stable.
f_pushBoundary(array<float> boundaries, float value) =>
    if not na(value)
        array.push(boundaries, value)

// Two boundaries within one minimum tick share one field coordinate but keep
// both positions in the ordered ladder. Their intervening zone therefore has
// zero width instead of disappearing and renumbering every farther zone.
f_collapseOverlappingBoundarySlots(array<float> boundaries) =>
    int size = array.size(boundaries)
    if size > 1
        for i = 1 to size - 1
            float previousBoundary = array.get(boundaries, i - 1)
            float currentBoundary = array.get(boundaries, i)
            if math.abs(currentBoundary - previousBoundary) <= syminfo.mintick
                array.set(boundaries, i, previousBoundary)

f_sortAvailableFour(float value1, float value2, float value3, float value4, bool descending) =>
    array<float> available = array.new_float()
    f_pushBoundary(available, value1)
    f_pushBoundary(available, value2)
    f_pushBoundary(available, value3)
    f_pushBoundary(available, value4)
    if descending
        array.sort(available, order.descending)
    else
        array.sort(available, order.ascending)
    f_collapseOverlappingBoundarySlots(available)
    int sortedCount = array.size(available)
    float sortedFirst = na
    float sortedSecond = na
    float sortedThird = na
    float sortedFourth = na
    if sortedCount > 0
        sortedFirst := array.get(available, 0)
    if sortedCount > 1
        sortedSecond := array.get(available, 1)
    if sortedCount > 2
        sortedThird := array.get(available, 2)
    if sortedCount > 3
        sortedFourth := array.get(available, 3)
    [sortedFirst, sortedSecond, sortedThird, sortedFourth, sortedCount]

float manualFieldU1 = sessionVwap + manualUpperNear
float manualFieldU2 = sessionVwap + manualUpperFar
float manualFieldL1 = sessionVwap - manualLowerNear
float manualFieldL2 = sessionVwap - manualLowerFar
float adaptiveFieldAbove = aboveAdaptiveReady ? sessionVwap + aboveAdaptiveDistance : na
float persistentFieldAbove = abovePersistentReady ? sessionVwap + abovePersistentDistance : na
float adaptiveFieldBelow = belowAdaptiveReady ? sessionVwap - belowAdaptiveDistance : na
float persistentFieldBelow = belowPersistentReady ? sessionVwap - belowPersistentDistance : na

// In live Auto mode Manual supplies the field only until that side produces its
// first qualified Auto boundary. Compare retains every available source line.
// Historical segments never admit Manual candidates.
bool useManualUpperField = isLiveVwapSegment and (mode == "Manual" or mode == "Compare" or mode == "Auto" and not aboveHasAnyAuto)
bool useManualLowerField = isLiveVwapSegment and (mode == "Manual" or mode == "Compare" or mode == "Auto" and not belowHasAnyAuto)
bool useAutoUpperField = showAutoForSegment and aboveHasAnyAuto
bool useAutoLowerField = showAutoForSegment and belowHasAnyAuto

float upperCandidate1 = useManualUpperField ? manualFieldU1 : na
float upperCandidate2 = useManualUpperField ? manualFieldU2 : na
float upperCandidate3 = useAutoUpperField and aboveAdaptiveReady ? adaptiveFieldAbove : na
float upperCandidate4 = useAutoUpperField and abovePersistentReady ? persistentFieldAbove : na
float lowerCandidate1 = useManualLowerField ? manualFieldL1 : na
float lowerCandidate2 = useManualLowerField ? manualFieldL2 : na
float lowerCandidate3 = useAutoLowerField and belowAdaptiveReady ? adaptiveFieldBelow : na
float lowerCandidate4 = useAutoLowerField and belowPersistentReady ? persistentFieldBelow : na

[activeU1Path, activeU2Path, activeU3Path, activeU4Path, upperActiveCount] = f_sortAvailableFour(upperCandidate1, upperCandidate2, upperCandidate3, upperCandidate4, false)
[activeL1Path, activeL2Path, activeL3Path, activeL4Path, lowerActiveCount] = f_sortAvailableFour(lowerCandidate1, lowerCandidate2, lowerCandidate3, lowerCandidate4, true)

bool fieldAnyAvailable = upperActiveCount > 0 or lowerActiveCount > 0

// Field colors represent fixed spatial ranks, never Manual/Auto identity,
// relationship identity, boundary count, or a directional judgment. Missing
// outer ranks simply leave their colors unused; remaining ranks do not compress.
f_spatialDepthColor(int depth, color layer1, color compareOne, color middle, color compareTwo, color far) =>
    depth <= 0 ? layer1 : depth == 1 ? compareOne : depth == 2 ? middle : depth == 3 ? compareTwo : far

// ── Cumulative-field transition state ───────────────────────────────────────
// A crossing makes a neighboring spatial state eligible; time, occupied candle
// fraction, and relative volume decide whether it takes control. The winner
// becomes the incumbent until a later price-driven fight. Moving or crossing
// lines away from current price cannot create a body by themselves.
f_zone(float price, int upperCount, int lowerCount, float upper1, float upper2, float upper3, float upper4, float lower1, float lower2, float lower3, float lower4) =>
    int result = 0
    if upperCount >= 4 and price >= upper4
        result := 4
    else if upperCount >= 3 and price >= upper3
        result := 3
    else if upperCount >= 2 and price >= upper2
        result := 2
    else if upperCount >= 1 and price >= upper1
        result := 1
    else if lowerCount >= 4 and price <= lower4
        result := -4
    else if lowerCount >= 3 and price <= lower3
        result := -3
    else if lowerCount >= 2 and price <= lower2
        result := -2
    else if lowerCount >= 1 and price <= lower1
        result := -1
    result

f_pathAtDepth(int depth, float path1, float path2, float path3, float path4) =>
    depth == 1 ? path1 : depth == 2 ? path2 : depth == 3 ? path3 : depth == 4 ? path4 : na

f_zoneFraction(int zone, float barLow, float barHigh, int upperCount, int lowerCount, float upper1, float upper2, float upper3, float upper4, float lower1, float lower2, float lower3, float lower4) =>
    float span = math.max(barHigh - barLow, syminfo.mintick)
    float occupied = 0.0
    if zone == 0
        float localUpper = upperCount > 0 ? upper1 : barHigh
        float localLower = lowerCount > 0 ? lower1 : barLow
        occupied := math.max(math.min(barHigh, localUpper) - math.max(barLow, localLower), 0.0)
    else if zone > 0 and zone <= upperCount
        float zoneLower = f_pathAtDepth(zone, upper1, upper2, upper3, upper4)
        float zoneUpper = zone < upperCount ? f_pathAtDepth(zone + 1, upper1, upper2, upper3, upper4) : barHigh
        occupied := math.max(math.min(barHigh, zoneUpper) - math.max(barLow, zoneLower), 0.0)
    else if zone < 0 and -zone <= lowerCount
        int depth = -zone
        float zoneUpper = f_pathAtDepth(depth, lower1, lower2, lower3, lower4)
        float zoneLower = depth < lowerCount ? f_pathAtDepth(depth + 1, lower1, lower2, lower3, lower4) : barLow
        occupied := math.max(math.min(barHigh, zoneUpper) - math.max(barLow, zoneLower), 0.0)
    math.min(occupied / span, 1.0)

// Boundary invasion is deliberately adjacent-only. A clean displacement across
// several thresholds does not fabricate a separate fight at every passed line.
f_sharedBoundary(int firstZone, int secondZone, float vwap, int upperCount, int lowerCount, float upper1, float upper2, float upper3, float upper4, float lower1, float lower2, float lower3, float lower4) =>
    int lowerZone = math.min(firstZone, secondZone)
    int upperZone = math.max(firstZone, secondZone)
    float result = na
    if lowerCount >= 4 and lowerZone == -4 and upperZone == -3
        result := lower4
    else if lowerCount >= 3 and lowerZone == -3 and upperZone == -2
        result := lower3
    else if lowerCount >= 2 and lowerZone == -2 and upperZone == -1
        result := lower2
    else if lowerCount >= 1 and lowerZone == -1 and upperZone == 0
        result := lower1
    else if upperCount >= 1 and lowerZone == 0 and upperZone == 1
        result := upper1
    else if upperCount >= 2 and lowerZone == 1 and upperZone == 2
        result := upper2
    else if upperCount >= 3 and lowerZone == 2 and upperZone == 3
        result := upper3
    else if upperCount >= 4 and lowerZone == 3 and upperZone == 4
        result := upper4
    result

f_sharedSpan(int firstZone, int secondZone, float vwap, int upperCount, int lowerCount, float upper1, float upper2, float upper3, float upper4, float lower1, float lower2, float lower3, float lower4) =>
    int lowerZone = math.min(firstZone, secondZone)
    int upperZone = math.max(firstZone, secondZone)
    float result = na
    if lowerCount >= 4 and lowerZone == -4 and upperZone == -3
        result := lower3 - lower4
    else if lowerCount >= 3 and lowerZone == -3 and upperZone == -2
        result := lower2 - lower3
    else if lowerCount >= 2 and lowerZone == -2 and upperZone == -1
        result := lower1 - lower2
    else if lowerCount >= 1 and lowerZone == -1 and upperZone == 0
        result := vwap - lower1
    else if upperCount >= 1 and lowerZone == 0 and upperZone == 1
        result := upper1 - vwap
    else if upperCount >= 2 and lowerZone == 1 and upperZone == 2
        result := upper2 - upper1
    else if upperCount >= 3 and lowerZone == 2 and upperZone == 3
        result := upper3 - upper2
    else if upperCount >= 4 and lowerZone == 3 and upperZone == 4
        result := upper4 - upper3
    result

f_zoneColor(int zone, color layer1, color compareOne, color middle, color compareTwo, color far) =>
    int depth = math.abs(zone)
    f_spatialDepthColor(depth, layer1, compareOne, middle, compareTwo, far)

int observedZone = f_zone(hl2, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float localFraction = f_zoneFraction(0, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float upperZone1Fraction = f_zoneFraction(1, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float upperZone2Fraction = f_zoneFraction(2, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float upperZone3Fraction = f_zoneFraction(3, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float upperZone4Fraction = f_zoneFraction(4, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float lowerZone1Fraction = f_zoneFraction(-1, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float lowerZone2Fraction = f_zoneFraction(-2, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float lowerZone3Fraction = f_zoneFraction(-3, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
float lowerZone4Fraction = f_zoneFraction(-4, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)

var int activeReference = 0
var bool contestActive = false
var int contestedReference = 0
var float activeEvidence = 0.0
var float candidateEvidence = 0.0
var int candidateOccupiedBars = 0
var int contestAge = 0
var float boundaryCrossEvidence = 0.0
var float boundaryPenetration = 0.0

// The challenger is the non-active state occupying the largest part of the
// current candle. Proximity without physical occupation has no standing.
int enteredReference = activeReference
float enteredFraction = 0.0
if activeReference != 0 and localFraction > enteredFraction
    enteredReference := 0
    enteredFraction := localFraction
if activeReference != 1 and upperZone1Fraction > enteredFraction
    enteredReference := 1
    enteredFraction := upperZone1Fraction
if activeReference != 2 and upperZone2Fraction > enteredFraction
    enteredReference := 2
    enteredFraction := upperZone2Fraction
if activeReference != 3 and upperZone3Fraction > enteredFraction
    enteredReference := 3
    enteredFraction := upperZone3Fraction
if activeReference != 4 and upperZone4Fraction > enteredFraction
    enteredReference := 4
    enteredFraction := upperZone4Fraction
if activeReference != -1 and lowerZone1Fraction > enteredFraction
    enteredReference := -1
    enteredFraction := lowerZone1Fraction
if activeReference != -2 and lowerZone2Fraction > enteredFraction
    enteredReference := -2
    enteredFraction := lowerZone2Fraction
if activeReference != -3 and lowerZone3Fraction > enteredFraction
    enteredReference := -3
    enteredFraction := lowerZone3Fraction
if activeReference != -4 and lowerZone4Fraction > enteredFraction
    enteredReference := -4
    enteredFraction := lowerZone4Fraction

bool enteredAnotherZone = enteredReference != activeReference and enteredFraction > 0

float averageVolume = ta.sma(volume, volumeLookback)
bool usableVolume = not na(volume) and volume > 0 and not na(averageVolume) and averageVolume > 0
float relativeVolume = usableVolume ? math.min(volume / averageVolume, 3.0) : 1.0
float effectiveVolumeInfluence = usableVolume ? volumeInfluence : 0.0
float evidenceDecay = (evidenceMemory - 1.0) / evidenceMemory

f_evidence(int zone, float fraction, int timeZone, float relativeVol, float volInfluence) =>
    float timeComponent = timeZone == zone ? 1.0 : 0.0
    float volumeComponent = fraction * relativeVol
    (1.0 - volInfluence) * timeComponent + volInfluence * volumeComponent

if barstate.isfirst or newVwapAnchor
    activeReference := observedZone
    contestActive := false
    contestedReference := observedZone
    activeEvidence := 0.0
    candidateEvidence := 0.0
    candidateOccupiedBars := 0
    contestAge := 0
    boundaryCrossEvidence := 0.0
    boundaryPenetration := 0.0
else
    if not contestActive and enteredAnotherZone
        contestActive := true
        contestedReference := enteredReference
        activeEvidence := 0.0
        candidateEvidence := 0.0
        candidateOccupiedBars := 0
        contestAge := 0
        boundaryCrossEvidence := 0.0
        boundaryPenetration := 0.0
    else if contestActive and enteredAnotherZone and enteredReference != contestedReference
        float existingCandidateFraction = f_zoneFraction(contestedReference, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
        if enteredFraction > existingCandidateFraction + 0.05
            contestedReference := enteredReference
            activeEvidence := 0.0
            candidateEvidence := 0.0
            candidateOccupiedBars := 0
            contestAge := 0
            boundaryCrossEvidence := 0.0
            boundaryPenetration := 0.0

    if contestActive
        float currentFraction = f_zoneFraction(activeReference, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
        float contestedFraction = f_zoneFraction(contestedReference, low, high, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
        activeEvidence := activeEvidence * evidenceDecay + f_evidence(activeReference, currentFraction, observedZone, relativeVolume, effectiveVolumeInfluence)
        candidateEvidence := candidateEvidence * evidenceDecay + f_evidence(contestedReference, contestedFraction, observedZone, relativeVolume, effectiveVolumeInfluence)
        candidateOccupiedBars += contestedFraction >= 0.12 ? 1 : 0
        contestAge += 1

        float liveContestBoundary = f_sharedBoundary(activeReference, contestedReference, sessionVwap, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path)
        bool adjacentContest = not na(liveContestBoundary)
        bool candidateSideUp = contestedReference > activeReference
        bool boundaryStraddled = adjacentContest and low <= liveContestBoundary and high >= liveContestBoundary
        float livePenetration = adjacentContest ? (candidateSideUp ? math.max(high - liveContestBoundary, 0.0) : math.max(liveContestBoundary - low, 0.0)) : 0.0
        boundaryCrossEvidence := boundaryCrossEvidence * evidenceDecay + (boundaryStraddled ? 1.0 : 0.0)
        boundaryPenetration := math.max(boundaryPenetration * evidenceDecay, livePenetration)

        bool candidateCanWin = candidateOccupiedBars >= minimumCandidateBars
        bool candidateDominant = candidateEvidence >= activeEvidence * transitionDominance
        bool activeDominant = activeEvidence >= candidateEvidence * transitionDominance

        if candidateCanWin and candidateDominant
            activeReference := contestedReference
            contestActive := false
        else if contestAge >= minimumCandidateBars and activeDominant and observedZone == activeReference
            contestActive := false
        else if contestAge >= maximumContestBars
            if candidateCanWin and candidateEvidence > activeEvidence
                activeReference := contestedReference
            contestActive := false

        if not contestActive
            contestedReference := activeReference
            activeEvidence := 0.0
            candidateEvidence := 0.0
            candidateOccupiedBars := 0
            contestAge := 0
            boundaryCrossEvidence := 0.0
            boundaryPenetration := 0.0

float bodyAtr = ta.atr(bodyAtrLength)
float minimumBodyDepth = nz(bodyAtr, 0.0) * minimumOccupationAtr
float totalContestEvidence = activeEvidence + candidateEvidence
float candidateShare = contestActive and totalContestEvidence > 0 ? candidateEvidence / totalContestEvidence : 0.0

// Incumbent-color invasion only appears after repeated straddles of one live
// shared boundary. It follows observed penetration; it never shades a complete
// line-to-line corridor or projects beyond the current candle.
float contestBoundary = contestActive ? f_sharedBoundary(activeReference, contestedReference, sessionVwap, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path) : na
float contestSpan = contestActive ? f_sharedSpan(activeReference, contestedReference, sessionVwap, upperActiveCount, lowerActiveCount, activeU1Path, activeU2Path, activeU3Path, activeU4Path, activeL1Path, activeL2Path, activeL3Path, activeL4Path) : na
bool invasionTowardHigherPrices = contestActive and contestedReference > activeReference
float invasionMaturityDivisor = math.max(minimumCandidateBars - 1.0, 1.0)
float invasionMaturity = math.max(0.0, math.min((boundaryCrossEvidence - 1.0) / invasionMaturityDivisor, 1.0))
float incumbentShare = 1.0 - candidateShare
float invasionStrength = invasionMaturity * (0.55 + 0.45 * incumbentShare)
float invasionDepth = not na(contestSpan) ? math.min(boundaryPenetration, math.max(contestSpan, 0.0)) * invasionMaturity : 0.0
bool invasionVisible = fieldAnyAvailable and showBehaviorBodies and showBoundaryInvasion and contestActive and not na(contestBoundary) and invasionMaturity > 0 and invasionDepth > syminfo.mintick
float invasionBase = invasionVisible ? contestBoundary : na
float invasionEdge = invasionVisible ? contestBoundary + (invasionTowardHigherPrices ? invasionDepth : -invasionDepth) : na
color incumbentZoneColor = f_zoneColor(activeReference, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor)
int invasionTransparency = int(math.round(100.0 - maximumInvasionOpacity * invasionStrength))
color invasionPaint = color.new(incumbentZoneColor, invasionTransparency)

// An established state paints at the chosen opacity. A physically reached but
// unconfirmed farther state is still visible immediately, only fainter. This
// keeps the map continuous without letting a single candle flip its emphasis.
f_layerPaint(bool established, bool candidateIncludesLayer, bool contest, color baseColor, int probeFade, float buildShare) =>
    int baseTransparency = int(math.round(color.t(baseColor)))
    int faintTransparency = math.max(probeFade, baseTransparency)
    int establishedFade = int(math.round(baseTransparency + buildShare * (faintTransparency - baseTransparency)))
    int candidateBuild = int(math.round(faintTransparency - buildShare * (faintTransparency - baseTransparency)))
    color result = color.new(baseColor, faintTransparency)
    if established
        result := contest and not candidateIncludesLayer ? color.new(baseColor, establishedFade) : baseColor
    else if contest and candidateIncludesLayer
        result := color.new(baseColor, candidateBuild)
    result

bool upperLayer2Established = activeReference >= 1
bool upperLayer3Established = activeReference >= 2
bool upperLayer4Established = activeReference >= 3
bool upperLayer5Established = activeReference == 4
bool lowerLayer2Established = activeReference <= -1
bool lowerLayer3Established = activeReference <= -2
bool lowerLayer4Established = activeReference <= -3
bool lowerLayer5Established = activeReference == -4
bool upperLayer2Candidate = contestActive and contestedReference >= 1
bool upperLayer3Candidate = contestActive and contestedReference >= 2
bool upperLayer4Candidate = contestActive and contestedReference >= 3
bool upperLayer5Candidate = contestActive and contestedReference == 4
bool lowerLayer2Candidate = contestActive and contestedReference <= -1
bool lowerLayer3Candidate = contestActive and contestedReference <= -2
bool lowerLayer4Candidate = contestActive and contestedReference <= -3
bool lowerLayer5Candidate = contestActive and contestedReference == -4

color upperLayer2Paint = f_layerPaint(upperLayer2Established, upperLayer2Candidate, contestActive, f_spatialDepthColor(1, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor), probeTransparency, candidateShare)
color upperLayer3Paint = f_layerPaint(upperLayer3Established, upperLayer3Candidate, contestActive, f_spatialDepthColor(2, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor), probeTransparency, candidateShare)
color upperLayer4Paint = f_layerPaint(upperLayer4Established, upperLayer4Candidate, contestActive, f_spatialDepthColor(3, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor), probeTransparency, candidateShare)
color upperLayer5Paint = f_layerPaint(upperLayer5Established, upperLayer5Candidate, contestActive, f_spatialDepthColor(4, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor), probeTransparency, candidateShare)
color lowerLayer2Paint = f_layerPaint(lowerLayer2Established, lowerLayer2Candidate, contestActive, f_spatialDepthColor(1, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor), probeTransparency, candidateShare)
color lowerLayer3Paint = f_layerPaint(lowerLayer3Established, lowerLayer3Candidate, contestActive, f_spatialDepthColor(2, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor), probeTransparency, candidateShare)
color lowerLayer4Paint = f_layerPaint(lowerLayer4Established, lowerLayer4Candidate, contestActive, f_spatialDepthColor(3, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor), probeTransparency, candidateShare)
color lowerLayer5Paint = f_layerPaint(lowerLayer5Established, lowerLayer5Candidate, contestActive, f_spatialDepthColor(4, nearLayerColor, compareStepOneColor, middleLayerColor, compareStepTwoColor, farLayerColor), probeTransparency, candidateShare)

// ── Candle-shaped cumulative geometry ───────────────────────────────────────
// Every interval is clipped to the current candle's reached extreme. If price
// reaches a farther step, all nearer steps remain filled so there is no white
// gap back to VWAP. There is no independent rectangle and no future extension.
bool upperLayer2Reached = upperActiveCount >= 1 and high > activeU1Path
bool upperLayer3Reached = upperActiveCount >= 2 and high > activeU2Path
bool upperLayer4Reached = upperActiveCount >= 3 and high > activeU3Path
bool upperLayer5Reached = upperActiveCount >= 4 and high > activeU4Path
bool lowerLayer2Reached = lowerActiveCount >= 1 and low < activeL1Path
bool lowerLayer3Reached = lowerActiveCount >= 2 and low < activeL2Path
bool lowerLayer4Reached = lowerActiveCount >= 3 and low < activeL3Path
bool lowerLayer5Reached = lowerActiveCount >= 4 and low < activeL4Path

bool upperLayer1Visible = upperActiveCount > 0 and showBehaviorBodies and high > sessionVwap and (upperLayer2Reached or high - sessionVwap >= minimumBodyDepth)
bool upperLayer2Visible = showBehaviorBodies and upperLayer2Reached
bool upperLayer3Visible = showBehaviorBodies and upperLayer3Reached
bool upperLayer4Visible = showBehaviorBodies and upperLayer4Reached
bool upperLayer5Visible = showBehaviorBodies and upperLayer5Reached
bool lowerLayer1Visible = lowerActiveCount > 0 and showBehaviorBodies and low < sessionVwap and (lowerLayer2Reached or sessionVwap - low >= minimumBodyDepth)
bool lowerLayer2Visible = showBehaviorBodies and lowerLayer2Reached
bool lowerLayer3Visible = showBehaviorBodies and lowerLayer3Reached
bool lowerLayer4Visible = showBehaviorBodies and lowerLayer4Reached
bool lowerLayer5Visible = showBehaviorBodies and lowerLayer5Reached

float upperLayer1Base = upperLayer1Visible ? sessionVwap : na
float upperLayer1Edge = upperLayer1Visible ? math.min(high, activeU1Path) : na
float upperLayer2Base = upperLayer2Visible ? activeU1Path : na
float upperLayer2Edge = upperLayer2Visible ? upperActiveCount >= 2 ? math.min(high, activeU2Path) : high : na
float upperLayer3Base = upperLayer3Visible ? activeU2Path : na
float upperLayer3Edge = upperLayer3Visible ? upperActiveCount >= 3 ? math.min(high, activeU3Path) : high : na
float upperLayer4Base = upperLayer4Visible ? activeU3Path : na
float upperLayer4Edge = upperLayer4Visible ? upperActiveCount >= 4 ? math.min(high, activeU4Path) : high : na
float upperLayer5Base = upperLayer5Visible ? activeU4Path : na
float upperLayer5Edge = upperLayer5Visible ? high : na
float lowerLayer1Base = lowerLayer1Visible ? sessionVwap : na
float lowerLayer1Edge = lowerLayer1Visible ? math.max(low, activeL1Path) : na
float lowerLayer2Base = lowerLayer2Visible ? activeL1Path : na
float lowerLayer2Edge = lowerLayer2Visible ? lowerActiveCount >= 2 ? math.max(low, activeL2Path) : low : na
float lowerLayer3Base = lowerLayer3Visible ? activeL2Path : na
float lowerLayer3Edge = lowerLayer3Visible ? lowerActiveCount >= 3 ? math.max(low, activeL3Path) : low : na
float lowerLayer4Base = lowerLayer4Visible ? activeL3Path : na
float lowerLayer4Edge = lowerLayer4Visible ? lowerActiveCount >= 4 ? math.max(low, activeL4Path) : low : na
float lowerLayer5Base = lowerLayer5Visible ? activeL4Path : na
float lowerLayer5Edge = lowerLayer5Visible ? low : na

upperLayer1BasePlot = plot(upperLayer1Base, "Cumulative upper Layer 1 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer1EdgePlot = plot(upperLayer1Edge, "Cumulative upper Layer 1 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer2BasePlot = plot(upperLayer2Base, "Cumulative upper Layer 2 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer2EdgePlot = plot(upperLayer2Edge, "Cumulative upper Layer 2 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer3BasePlot = plot(upperLayer3Base, "Cumulative upper Layer 3 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer3EdgePlot = plot(upperLayer3Edge, "Cumulative upper Layer 3 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer4BasePlot = plot(upperLayer4Base, "Cumulative upper Layer 4 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer4EdgePlot = plot(upperLayer4Edge, "Cumulative upper Layer 4 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer5BasePlot = plot(upperLayer5Base, "Cumulative upper Layer 5 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
upperLayer5EdgePlot = plot(upperLayer5Edge, "Cumulative upper Layer 5 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer1BasePlot = plot(lowerLayer1Base, "Cumulative lower Layer 1 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer1EdgePlot = plot(lowerLayer1Edge, "Cumulative lower Layer 1 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer2BasePlot = plot(lowerLayer2Base, "Cumulative lower Layer 2 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer2EdgePlot = plot(lowerLayer2Edge, "Cumulative lower Layer 2 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer3BasePlot = plot(lowerLayer3Base, "Cumulative lower Layer 3 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer3EdgePlot = plot(lowerLayer3Edge, "Cumulative lower Layer 3 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer4BasePlot = plot(lowerLayer4Base, "Cumulative lower Layer 4 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer4EdgePlot = plot(lowerLayer4Edge, "Cumulative lower Layer 4 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer5BasePlot = plot(lowerLayer5Base, "Cumulative lower Layer 5 base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
lowerLayer5EdgePlot = plot(lowerLayer5Edge, "Cumulative lower Layer 5 candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
invasionBasePlot = plot(invasionBase, "Incumbent boundary invasion base", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)
invasionEdgePlot = plot(invasionEdge, "Incumbent boundary invasion candle edge", color = color.new(color.white, 100), style = plot.style_linebr, display = display.none)

fill(upperLayer1BasePlot, upperLayer1EdgePlot, color = nearLayerColor, title = "Cumulative upper Layer 1", fillgaps = false)
fill(upperLayer2BasePlot, upperLayer2EdgePlot, color = upperLayer2Paint, title = "Cumulative upper Layer 2", fillgaps = false)
fill(upperLayer3BasePlot, upperLayer3EdgePlot, color = upperLayer3Paint, title = "Cumulative upper Layer 3", fillgaps = false)
fill(upperLayer4BasePlot, upperLayer4EdgePlot, color = upperLayer4Paint, title = "Cumulative upper Layer 4", fillgaps = false)
fill(upperLayer5BasePlot, upperLayer5EdgePlot, color = upperLayer5Paint, title = "Cumulative upper Layer 5", fillgaps = false)
fill(lowerLayer1BasePlot, lowerLayer1EdgePlot, color = nearLayerColor, title = "Cumulative lower Layer 1", fillgaps = false)
fill(lowerLayer2BasePlot, lowerLayer2EdgePlot, color = lowerLayer2Paint, title = "Cumulative lower Layer 2", fillgaps = false)
fill(lowerLayer3BasePlot, lowerLayer3EdgePlot, color = lowerLayer3Paint, title = "Cumulative lower Layer 3", fillgaps = false)
fill(lowerLayer4BasePlot, lowerLayer4EdgePlot, color = lowerLayer4Paint, title = "Cumulative lower Layer 4", fillgaps = false)
fill(lowerLayer5BasePlot, lowerLayer5EdgePlot, color = lowerLayer5Paint, title = "Cumulative lower Layer 5", fillgaps = false)
fill(invasionBasePlot, invasionEdgePlot, color = invasionPaint, title = "Incumbent color invading contested zone", fillgaps = false)

// Further experimental relationship changes continue on the research branch.
````
