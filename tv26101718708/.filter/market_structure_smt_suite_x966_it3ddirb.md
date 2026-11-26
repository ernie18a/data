# Market Structure & SMT Suite X966

- url: https://www.tradingview.com/script/It3ddiRb-Market-Structure-SMT-Suite-X966/
- type: indicator
- pine_id: PUB;0c6b281bed0f4e389f879e1520b8f9c9
- version: 1.0

## Description

## Market Structure & SMT Suite X966 

X966 Market Structure & SMT Suite is a multi-module Pine Script v6 indicator designed to organize market structure, higher-timeframe context, and intermarket divergence analysis within a single chart workflow.

### STDV / CISD Market Structure

This module identifies selected structural price events and plots related reference levels.

Forming conditions and completed events are displayed separately so users can distinguish developing information from confirmed historical structure.

Projected levels should be treated as analytical price references, not guaranteed targets, trade entries, or forecasts.

### Higher-Timeframe Context

The HTF module displays higher-timeframe candle information and optional structural reference levels alongside the active chart.

Its purpose is to provide broader market context without requiring the trader to repeatedly switch chart timeframes.

Developing higher-timeframe candles can change until their respective timeframe closes and should therefore not be interpreted as confirmed historical candles.

### Multi-Timeframe SMT Divergence

The SMT module compares the chart symbol with one or two configurable reference markets and identifies differences in relative swing behavior.

This can help highlight situations where related markets fail to confirm each other's highs or lows.

Reference-symbol relationships are market-dependent. Users should verify that the selected symbols, trading sessions, and underlying market relationships are appropriate for the instrument being analyzed.

If comparison-symbol data is unavailable or unsupported, some SMT calculations may not be displayed.

### How the Modules Work Together

The three modules provide different layers of context:

- **STDV / CISD** highlights local structural events and reference levels.
- **HTF Context** provides broader timeframe structure and candle context.
- **SMT Divergence** compares relative behavior between related markets.

Combining these modules allows users to evaluate price action from structural, higher-timeframe, and intermarket perspectives within one coordinated interface.

Agreement between multiple modules does not imply a specific probability of success and should not be considered a trade recommendation.

### Usage

Add the indicator to a standard candlestick chart and use the **X966 Modules** settings to enable or disable individual components.

Users can configure module visibility, higher-timeframe selections, SMT comparison symbols, and available visual preferences.

The indicator can be evaluated across different chart timeframes because structural detail, higher-timeframe confirmation, and visible drawing density will vary depending on the active timeframe and market.

### Originality and Purpose

X966 is designed as a unified analytical workflow rather than a simple collection of unrelated indicators.

Its purpose is to combine local market structure, higher-timeframe context, and cross-market SMT divergence into one coordinated framework so users can study how these analytical perspectives interact without maintaining several separate chart tools.

### Limitations

- Developing candles and unconfirmed market structure can change before bar close.
- Higher-timeframe information depends on the confirmation timing of the referenced timeframe.
- SMT divergence depends on the validity and availability of the selected comparison markets.
- Drawing objects are subject to TradingView platform limits, so older visual objects may be removed when limits are reached.
- Market relationships can change over time, meaning a historically related comparison symbol may not remain equally relevant in future conditions.
- The indicator does not execute trades.
- This edition does not include built-in alerts.
- It does not claim to identify institutional order flow or predict future prices.

Higher-timeframe calculations are structured to use confirmed historical values where required. Some previous-period HTF references use confirmed prior-bar data to avoid relying on unfinished future information.

X966 should be used as an analytical and contextual tool rather than as an automated trading or prediction system.

## Source Code

````pine
//@version=6
// X966-Version: 2.1.0
// X966 curated edition: STDV/CISD + HTF Context + Multi-Timeframe SMT.
indicator("X966 Market Structure & SMT Suite", shorttitle="X966 Structure SMT", overlay=true, format=format.price,
     max_bars_back=2500, max_lines_count=500, max_labels_count=500, max_boxes_count=500,
     dynamic_requests=true)
const string X966_MODULE_GROUP = "X966 Modules"
bool x966ModuleStdv = input.bool(true, "STDV & CISD", group=X966_MODULE_GROUP)
bool x966ModuleHtf = input.bool(true, "HTF Context", group=X966_MODULE_GROUP)
bool x966ModuleSmt = input.bool(true, "Multi-Timeframe SMT", group=X966_MODULE_GROUP)

// =============================================================================
// QUICK TOGGLES — high-use on/off switches stay at the very top.
// Colors, times, sizes, symbols, and advanced rules remain in their sections.
// =============================================================================
const string X966_QUICK_STDV = "Quick Toggles · STDV / CISD"
bool extendConfirmedCisd = x966ModuleStdv and input.bool(false, "Extend CISD", inline="QSTDV0", group=X966_QUICK_STDV)
bool showCisdText = x966ModuleStdv and input.bool(true, "CISD Text", inline="QSTDV0", group=X966_QUICK_STDV)
bool showPendingCisd = x966ModuleStdv and input.bool(true, "Forming CISD", inline="QSTDV0", group=X966_QUICK_STDV)
bool showZero = x966ModuleStdv and input.bool(true, "0", inline="QSTDV1", group=X966_QUICK_STDV)
bool showOne = x966ModuleStdv and input.bool(true, "1", inline="QSTDV1", group=X966_QUICK_STDV)
bool showMinusOne = x966ModuleStdv and input.bool(true, "-1", inline="QSTDV1", group=X966_QUICK_STDV)
bool showMinusOnePointFive = x966ModuleStdv and input.bool(false, "-1.5", inline="QSTDV1", group=X966_QUICK_STDV)
bool showMinusTwo = x966ModuleStdv and input.bool(true, "-2", inline="QSTDV2", group=X966_QUICK_STDV)
bool showMinusTwoPointFive = x966ModuleStdv and input.bool(true, "-2.5", inline="QSTDV2", group=X966_QUICK_STDV)
bool showMinusThreePointFive = x966ModuleStdv and input.bool(true, "-3.5", inline="QSTDV2", group=X966_QUICK_STDV)
bool showMinusFour = x966ModuleStdv and input.bool(true, "-4", inline="QSTDV2", group=X966_QUICK_STDV)
bool fillMinusOneZone = x966ModuleStdv and input.bool(false, "Fill -1/-1.5", inline="QSTDV3", group=X966_QUICK_STDV)
bool fillMinusTwoZone = x966ModuleStdv and input.bool(true, "Fill -2/-2.5", inline="QSTDV3", group=X966_QUICK_STDV)
bool fillMinusThreePointFiveZone = x966ModuleStdv and input.bool(true, "Fill -3.5/-4", inline="QSTDV3", group=X966_QUICK_STDV)

const string X966_QUICK_HTF = "Quick Toggles · HTF"
bool showLaneLabels = x966ModuleHtf and input.bool(true, "HTF Labels", inline="QHTF1", group=X966_QUICK_HTF)
bool showLaneCountdown = x966ModuleHtf and input.bool(true, "Countdown", inline="QHTF1", group=X966_QUICK_HTF)
bool showAdaptiveMidpoints = x966ModuleHtf and input.bool(true, "Midpoints", inline="QHTF2", group=X966_QUICK_HTF)
bool showCloseBackSweeps = x966ModuleHtf and input.bool(true, "Sweep Lines", inline="QHTF2", group=X966_QUICK_HTF)
bool showHtfRangeLevels = x966ModuleHtf and input.bool(true, "HTF 25/50/75 + H/L", inline="QHTF3", group=X966_QUICK_HTF)

const string X966_QUICK_SMT = "Quick Toggles · SMT"
bool useComparison1 = x966ModuleSmt and input.bool(true, "Comparison 1", inline="QSMT0", group=X966_QUICK_SMT)
bool useComparison2 = x966ModuleSmt and input.bool(false, "Comparison 2", inline="QSMT0", group=X966_QUICK_SMT)
bool showBearish = x966ModuleSmt and input.bool(true, "Bearish", inline="QSMT0", group=X966_QUICK_SMT)
bool showBullish = x966ModuleSmt and input.bool(true, "Bullish", inline="QSMT0", group=X966_QUICK_SMT)
bool tfW_on = x966ModuleSmt and input.bool(true, "W", inline="QSMT1", group=X966_QUICK_SMT)
bool tfD_on = x966ModuleSmt and input.bool(true, "D", inline="QSMT1", group=X966_QUICK_SMT)
bool tf4H_on = x966ModuleSmt and input.bool(true, "4H", inline="QSMT1", group=X966_QUICK_SMT)
bool tf1H_on = x966ModuleSmt and input.bool(true, "1H", inline="QSMT1", group=X966_QUICK_SMT)
bool tf30_on = x966ModuleSmt and input.bool(false, "30m", inline="QSMT2", group=X966_QUICK_SMT)
bool tf15_on = x966ModuleSmt and input.bool(true, "15m", inline="QSMT2", group=X966_QUICK_SMT)
bool tf5_on = x966ModuleSmt and input.bool(false, "5m", inline="QSMT2", group=X966_QUICK_SMT)
bool tf1_on = x966ModuleSmt and input.bool(false, "1m", inline="QSMT2", group=X966_QUICK_SMT)
type Candidate
    int direction
    int referenceTime
    float referencePrice
    int firstSweepTime
    int extremeTime
    float extreme
    int extremeBar
    int startBar
    int competitionStart
    float cisd
    int cisdOriginTime
    int cisdConfirmTime
    float cisdConfirmClose
    int cisdConfirmBar
    float swing
    int swingTime
    int stage                       // 0 = wait for CISD, 1 = wait for prior-swing breach
    float liquidityImportance
    float deliveryQuality
type LayerSnapshot
    int bullRevision
    int bullWindow
    int bullConfirmTime
    int bullFirstSweepTime
    int bullA0Time
    float bullA0
    int bullA1Time
    float bullA1
    int bullCisdOriginTime
    int bullCisdConfirmTime
    float bullCisd
    int bullReferenceTime
    float bullReferencePrice
    float bullScore
    int bearRevision
    int bearWindow
    int bearConfirmTime
    int bearFirstSweepTime
    int bearA0Time
    float bearA0
    int bearA1Time
    float bearA1
    int bearCisdOriginTime
    int bearCisdConfirmTime
    float bearCisd
    int bearReferenceTime
    float bearReferencePrice
    float bearScore
    int bullPendingId
    float bullPendingCisd
    int bearPendingId
    float bearPendingCisd
    int nativeTime
    float nativeHigh
    float nativeLow
    float nativeClose
type Projection
    int layer
    int direction                  // 1 bullish, -1 bearish
    string confirmationTf
    string liquidityTf
    string competitionTf
    int competitionStart
    int revision
    int confirmationTime
    int firstSweepTime
    int anchor0Time
    float anchor0
    int anchor1Time
    float anchor1
    int cisdOriginTime
    int cisdConfirmTime
    float cisd
    int referenceTime
    float referencePrice
    string eventId
    float projectionRange
    float selectionScore
    int status                     // 0 active, 1 anchor invalidated, 2 -4 exhausted, 3 superseded
    int endTime
    int lastLifecycleTime
    int firstObjectiveHitTime      // first touch of the -2 to -2.5 objective zone (triggered at -2)
    array<float> ratios
    array<line> ratioLines
    array<label> ratioLabels
    array<box> ratioBoxes
    box liveMinusTwoBox
    box liveMinusFourBox
    line cisdLine
    label cisdLabel
string GROUP_DETECTION = "Core rule"
string htfViolationMode = input.string("Wick", "Liquidity sweep uses", options=["Wick", "Body close"], group=GROUP_DETECTION)
string anchorInvalidationMode = input.string("Wick", "Anchor invalidation", options=["Wick", "Body close", "Disabled"],
     tooltip="Deletes the entire CISD, anchor, and STDV set when the manipulation anchor is breached.", group=GROUP_DETECTION)
string minusFourCompletionMode = input.string("Wick", "At -4 objective", options=["Wick", "Body close", "Keep visible"],
     tooltip="Controls when a completed -4 projection is deleted.", group=GROUP_DETECTION)
bool protectCompetitionExtremes = x966ModuleStdv and input.bool(true, "Protect current-window extremes",
     tooltip="Always displays the lowest bullish and highest bearish valid CISDs in the active competition window.", group=GROUP_DETECTION)
const int sweepToleranceTicks = 1
bool includeDeliveryDoji = false
bool includeDeliveryInside = true
int deliverySearchGap = 1
bool requireStructureClose = false
bool requireRapidReclaim = true
bool requireRapidSwingBreak = true
int maxBarsCisdToSwing = 8
int swingStrength = 2
int swingSearchBars = 30
bool useNearestSwingFallback = false
string swingBreachMode = "Body close"
const int MIN_DELIVERY_CANDLES = 2
const int DELIVERY_SCAN_LIMIT = 12
string group1StartTf = "1"
string group1MaxTf = "5"
string group3StartTf = "60"
string group4StartTf = "240"
string group5StartTf = "D"
string REF_NORMAL = "Normal completed highs/lows"
string SELECT_RECENT = "Most recent"
string SELECT_SCORE = "Strongest composite score"
string GROUP_SIMPLE = "Simple display"
int maxVisibleSets = input.int(4, "Maximum visible sets", minval=2, maxval=10, group=GROUP_SIMPLE)
string layer6LiquidityTf = "15"
string layer6ConfirmationTf = "1"
int layer6NormalLookback = 12
int layer6CandidateLifetime = 24
int layer6CisdLifetime = 8
string layer6CompetitionTf = "90"
int layer6Retention = 1500
int layer6MaxStored = 20
int layer6MarkerBars = 5
string layer0LiquidityTf = "60"
string layer0ConfirmationTf = "5"
int layer0NormalLookback = 12
int layer0CandidateLifetime = 24
int layer0CisdLifetime = 8
string layer0CompetitionTf = "240"
int layer0Retention = 1000
int layer0MaxStored = 20
int layer0MarkerBars = 5
string layer1LiquidityTf = "240"
string layer1ConfirmationTf = "15"
int layer1NormalLookback = 12
int layer1CandidateLifetime = 24
int layer1CisdLifetime = 8
string layer1CompetitionTf = "D"
int layer1Retention = 1000
int layer1MaxStored = 20
int layer1MarkerBars = 5
string layer2LiquidityTf = "240"
string layer2ConfirmationTf = "60"
int layer2NormalLookback = 12
int layer2CandidateLifetime = 24
int layer2CisdLifetime = 5
string layer2CompetitionTf = "D"
int layer2Retention = 750
int layer2MaxStored = 20
int layer2MarkerBars = 5
string layer3LiquidityTf = "D"
string layer3ConfirmationTf = "240"
int layer3NormalLookback = 12
int layer3CandidateLifetime = 48
int layer3CisdLifetime = 12
string layer3CompetitionTf = "W"
int layer3Retention = 500
int layer3MaxStored = 20
int layer3MarkerBars = 6
string layer4LiquidityTf = "D"
string layer4ConfirmationTf = "D"
int layer4NormalLookback = 20
int layer4CandidateLifetime = 60
int layer4CisdLifetime = 20
string layer4CompetitionTf = "M"
int layer4Retention = 500
int layer4MaxStored = 20
int layer4MarkerBars = 6
float relevanceDistanceRanges = 1.0
int duplicateToleranceTicks = 2
string GROUP_LEVELS = "STDV levels"
color stdvZoneColor = input.color(color.rgb(156, 156, 156), "Zone color", inline="zone", group=GROUP_LEVELS)
int stdvZoneTransparency = input.int(83, "Transparency", minval=0, maxval=100, inline="zone", group=GROUP_LEVELS)
string GROUP_VISUAL = "Colors & lines"
string labelSizeInput = input.string("Tiny", "Number size", options=["Tiny", "Small", "Normal"], group=GROUP_VISUAL)
color stdvColor = input.color(color.rgb(148, 163, 184), "STDV lines & numbers", group=GROUP_VISUAL)
string stdvLineStyleInput = input.string("Dotted", "STDV line style", options=["Solid", "Dotted", "Dashed"], inline="stdv", group=GROUP_VISUAL)
int stdvLineWidth = input.int(1, "Thickness", minval=1, maxval=4, inline="stdv", group=GROUP_VISUAL)
color anchorLineColor = input.color(color.rgb(100, 116, 139), "Anchor lines", group=GROUP_VISUAL)
string anchorLineStyleInput = input.string("Dotted", "Anchor line style", options=["Solid", "Dotted", "Dashed"], inline="anchor", group=GROUP_VISUAL)
int anchorLineWidth = input.int(1, "Thickness", minval=1, maxval=4, inline="anchor", group=GROUP_VISUAL)
color bullishCisdColor = input.color(color.rgb(245, 127, 23), "Bullish CISD", inline="cisd", group=GROUP_VISUAL)
color bearishCisdColor = input.color(color.rgb(245, 127, 23), "Bearish CISD", inline="cisd", group=GROUP_VISUAL)
string cisdLineStyleInput = input.string("Solid", "CISD line style", options=["Solid", "Dotted", "Dashed"], inline="cisd_line", group=GROUP_VISUAL)
int cisdLineWidth = input.int(2, "Thickness", minval=1, maxval=4, inline="cisd_line", group=GROUP_VISUAL)
bool useChartForeground = false
safeTfSeconds(string tf) =>
    float seconds = timeframe.in_seconds(tf)
    na(seconds) ? 1 : int(math.max(1.0, seconds))
ratioText(float ratio) =>
    ratio == 0.0 ? "0" :
     ratio == 1.0 ? "1" :
     ratio == -1.0 ? "-1" :
     ratio == -1.5 ? "-1.5" :
     ratio == -2.0 ? "-2" :
     ratio == -2.5 ? "-2.5" :
     ratio == -3.5 ? "-3.5" : "-4"
projectionPrice(float anchor0, float anchor1, float ratio) =>
    anchor0 + ratio * (anchor1 - anchor0)
labelSizeFromString(string value) =>
    value == "Small" ? size.small : value == "Normal" ? size.normal : size.tiny
lineStyleFromString(string value) =>
    value == "Dotted" ? line.style_dotted : value == "Dashed" ? line.style_dashed : line.style_solid
ratioEnabled(float ratio) =>
    ratio == 0.0 ? showZero :
     ratio == 1.0 ? showOne :
     ratio == -1.0 ? showMinusOne :
     ratio == -1.5 ? showMinusOnePointFive :
     ratio == -2.0 ? showMinusTwo :
     ratio == -2.5 ? showMinusTwoPointFive :
     ratio == -3.5 ? showMinusThreePointFive : showMinusFour
arrayHasInt(array<int> values, int target) =>
    bool found = false
    if values.size() > 0
        for i = 0 to values.size() - 1
            if values.get(i) == target
                found := true
                break
    found
candidateIndexByReference(array<Candidate> values, int referenceTime) =>
    int found = na
    if values.size() > 0
        for i = 0 to values.size() - 1
            Candidate candidate = values.get(i)
            if candidate.referenceTime == referenceTime
                found := i
                break
    found
rememberConsumedReference(array<int> values, int referenceTime) =>
    if not arrayHasInt(values, referenceTime)
        values.push(referenceTime)
        if values.size() > 200
            values.shift()
    0
isBearDeliveryAt(int offset) =>
    close[offset] < open[offset] or (includeDeliveryDoji and close[offset] == open[offset])
isBullDeliveryAt(int offset) =>
    close[offset] > open[offset] or (includeDeliveryDoji and close[offset] == open[offset])
isInsideCandleAt(int offset) =>
    not na(high[offset + 1]) and high[offset] <= high[offset + 1] and low[offset] >= low[offset + 1]
isBearDeliveryMemberAt(int offset) =>
    isBearDeliveryAt(offset) or
     (includeDeliveryInside and isInsideCandleAt(offset) and
      (isBearDeliveryAt(offset + 1) or (offset > 0 and isBearDeliveryAt(offset - 1))))
isBullDeliveryMemberAt(int offset) =>
    isBullDeliveryAt(offset) or
     (includeDeliveryInside and isInsideCandleAt(offset) and
      (isBullDeliveryAt(offset + 1) or (offset > 0 and isBullDeliveryAt(offset - 1))))
isPivotHighAt(int offset, int strength) =>
    bool valid = offset >= strength and not na(high[offset + strength]) and not na(high[offset - strength])
    if valid
        for n = 1 to strength
            valid := valid and high[offset] > high[offset - n] and high[offset] >= high[offset + n]
    valid
isPivotLowAt(int offset, int strength) =>
    bool valid = offset >= strength and not na(low[offset + strength]) and not na(low[offset - strength])
    if valid
        for n = 1 to strength
            valid := valid and low[offset] < low[offset - n] and low[offset] <= low[offset + n]
    valid
bearishDeliveryRun(int baseOffset, int gapLimit) =>
    int firstDelivery = na
    for gap = 0 to gapLimit
        int offset = baseOffset + gap
        if not na(close[offset]) and isBearDeliveryMemberAt(offset)
            firstDelivery := offset
            break
    float cisd = na
    int cisdDefiningOffset = na
    int oldestOffset = na
    int memberCount = 0
    int genuineCount = 0
    bool hasStructureClose = false
    if not na(firstDelivery)
        for n = 0 to DELIVERY_SCAN_LIMIT - 1
            int offset = firstDelivery + n
            if not na(close[offset]) and isBearDeliveryMemberAt(offset)
                if close[offset] < open[offset]
                    genuineCount += 1
                    float bodyTop = open[offset]
                    if na(cisd) or bodyTop > cisd
                        cisd := bodyTop
                        cisdDefiningOffset := offset
                    hasStructureClose := hasStructureClose or
                         (not na(low[offset + 1]) and close[offset] < low[offset + 1])
                oldestOffset := offset
                memberCount += 1
            else
                break
    [cisd, oldestOffset, memberCount, genuineCount, firstDelivery, cisdDefiningOffset, hasStructureClose]
bullishDeliveryRun(int baseOffset, int gapLimit) =>
    int firstDelivery = na
    for gap = 0 to gapLimit
        int offset = baseOffset + gap
        if not na(close[offset]) and isBullDeliveryMemberAt(offset)
            firstDelivery := offset
            break
    float cisd = na
    int cisdDefiningOffset = na
    int oldestOffset = na
    int memberCount = 0
    int genuineCount = 0
    bool hasStructureClose = false
    if not na(firstDelivery)
        for n = 0 to DELIVERY_SCAN_LIMIT - 1
            int offset = firstDelivery + n
            if not na(close[offset]) and isBullDeliveryMemberAt(offset)
                if close[offset] > open[offset]
                    genuineCount += 1
                    float bodyBottom = open[offset]
                    if na(cisd) or bodyBottom < cisd
                        cisd := bodyBottom
                        cisdDefiningOffset := offset
                    hasStructureClose := hasStructureClose or
                         (not na(high[offset + 1]) and close[offset] > high[offset + 1])
                oldestOffset := offset
                memberCount += 1
            else
                break
    [cisd, oldestOffset, memberCount, genuineCount, firstDelivery, cisdDefiningOffset, hasStructureClose]
closestPriorSwingHigh(int finalDeliveryOffset, int searchWindow) =>
    float swing = na
    int swingTime = na
    if not na(finalDeliveryOffset)
        int firstOffset = math.max(finalDeliveryOffset + 1, swingStrength)
        int lastOffset = firstOffset + searchWindow - 1
        for offset = firstOffset to lastOffset
            if isPivotHighAt(offset, swingStrength)
                swing := high[offset]
                swingTime := time[offset]
                break
        if na(swing) and useNearestSwingFallback and not na(high[firstOffset])
            swing := high[firstOffset]
            swingTime := time[firstOffset]
    [swing, swingTime]
closestPriorSwingLow(int finalDeliveryOffset, int searchWindow) =>
    float swing = na
    int swingTime = na
    if not na(finalDeliveryOffset)
        int firstOffset = math.max(finalDeliveryOffset + 1, swingStrength)
        int lastOffset = firstOffset + searchWindow - 1
        for offset = firstOffset to lastOffset
            if isPivotLowAt(offset, swingStrength)
                swing := low[offset]
                swingTime := time[offset]
                break
        if na(swing) and useNearestSwingFallback and not na(low[firstOffset])
            swing := low[firstOffset]
            swingTime := time[firstOffset]
    [swing, swingTime]
detectLayer(string liquidityTf, int normalLookback, int candidateLifetime, int cisdLifetime, string competitionTf) =>
    float nativeSecondsRaw = timeframe.in_seconds(timeframe.period)
    bool higherTimeframeNative = not na(nativeSecondsRaw) and nativeSecondsRaw >= 14400.0
    float sensitivityMultiplier = 1.0
    int baseDeliveryGap = higherTimeframeNative ? math.max(deliverySearchGap, 2) : deliverySearchGap
    int baseSwingSearchBars = higherTimeframeNative ? math.max(swingSearchBars, 30) : swingSearchBars
    int baseCandidateLifetime = higherTimeframeNative ? math.max(candidateLifetime, 48) : candidateLifetime
    int baseCisdLifetime = higherTimeframeNative ? math.max(cisdLifetime, 12) : cisdLifetime
    int baseSwingBreakBars = higherTimeframeNative ? math.max(maxBarsCisdToSwing, 10) : maxBarsCisdToSwing
    int effectiveDeliveryGap = baseDeliveryGap
    int effectiveSwingSearchBars = math.max(10, int(math.round(baseSwingSearchBars * sensitivityMultiplier)))
    int effectiveCandidateLifetime = math.max(4, int(math.round(baseCandidateLifetime * sensitivityMultiplier)))
    int effectiveCisdLifetime = math.max(2, int(math.round(baseCisdLifetime * sensitivityMultiplier)))
    int effectiveSwingBreakBars = math.max(2, int(math.round(baseSwingBreakBars * sensitivityMultiplier)))
    bool effectiveRequireStructureClose = requireStructureClose and not higherTimeframeNative
    bool relaxCompetitionSwingWindow = not na(nativeSecondsRaw) and
         (nativeSecondsRaw == 15.0 * 60.0 or nativeSecondsRaw == 60.0 * 60.0)
    var array<Candidate> bullCandidates = array.new<Candidate>()
    var array<Candidate> bearCandidates = array.new<Candidate>()
    var array<int> consumedBullReferences = array.new_int()
    var array<int> consumedBearReferences = array.new_int()
    var int buildingLiquidityTime = na
    var float buildingLiquidityHigh = na
    var float buildingLiquidityLow = na
    var array<int> completedLiquidityTimes = array.new_int()
    var array<float> completedLiquidityHighs = array.new_float()
    var array<float> completedLiquidityLows = array.new_float()
    var array<int> bullWinnerWindows = array.new_int()
    var array<float> bullWinnerScores = array.new_float()
    var array<float> bullWinnerCisds = array.new_float()
    var array<int> bearWinnerWindows = array.new_int()
    var array<float> bearWinnerScores = array.new_float()
    var array<float> bearWinnerCisds = array.new_float()
    var int bullRevision = 0
    var int bullWindow = na
    var int bullConfirmTime = na
    var int bullFirstSweepTime = na
    var int bullA0Time = na
    var float bullA0 = na
    var int bullA1Time = na
    var float bullA1 = na
    var int bullCisdOriginTime = na
    var int bullCisdConfirmTime = na
    var float bullEventCisd = na
    var int bullReferenceTime = na
    var float bullReferencePrice = na
    var float bullEventScore = na
    var int bearRevision = 0
    var int bearWindow = na
    var int bearConfirmTime = na
    var int bearFirstSweepTime = na
    var int bearA0Time = na
    var float bearA0 = na
    var int bearA1Time = na
    var float bearA1 = na
    var int bearCisdOriginTime = na
    var int bearCisdConfirmTime = na
    var float bearEventCisd = na
    var int bearReferenceTime = na
    var float bearReferencePrice = na
    var float bearEventScore = na
    var int lastProcessedTime = na
    int processedTime = time[1]
    float processedHigh = high[1]
    float processedLow = low[1]
    float processedClose = close[1]
    float nativeAtrSeries = ta.atr(14)
    int processedBarIndex = bar_index[1]
    bool processBar = not na(processedTime) and (na(lastProcessedTime) or processedTime != lastProcessedTime)
    if processBar
        lastProcessedTime := processedTime
        int processedLiquidityTime = time(liquidityTf)[1]
        if not na(processedLiquidityTime)
            if na(buildingLiquidityTime)
                buildingLiquidityTime := processedLiquidityTime
                buildingLiquidityHigh := processedHigh
                buildingLiquidityLow := processedLow
            else if processedLiquidityTime != buildingLiquidityTime
                completedLiquidityTimes.push(buildingLiquidityTime)
                completedLiquidityHighs.push(buildingLiquidityHigh)
                completedLiquidityLows.push(buildingLiquidityLow)
                if completedLiquidityTimes.size() > 128
                    completedLiquidityTimes.shift()
                    completedLiquidityHighs.shift()
                    completedLiquidityLows.shift()
                buildingLiquidityTime := processedLiquidityTime
                buildingLiquidityHigh := processedHigh
                buildingLiquidityLow := processedLow
            else
                buildingLiquidityHigh := na(buildingLiquidityHigh) ? processedHigh : math.max(buildingLiquidityHigh, processedHigh)
                buildingLiquidityLow := na(buildingLiquidityLow) ? processedLow : math.min(buildingLiquidityLow, processedLow)
        int liquidityCount = completedLiquidityTimes.size()
        array<int> referenceHighTimes = array.new_int()
        array<float> referenceHighPrices = array.new_float()
        array<int> referenceLowTimes = array.new_int()
        array<float> referenceLowPrices = array.new_float()
        if liquidityCount > 0
            int firstNormalIndex = math.max(0, liquidityCount - normalLookback)
            for referenceIndex = firstNormalIndex to liquidityCount - 1
                float candidateHigh = completedLiquidityHighs.get(referenceIndex)
                float candidateLow = completedLiquidityLows.get(referenceIndex)
                bool highUnresolved = true
                bool lowUnresolved = true
                if referenceIndex < liquidityCount - 1
                    for newerIndex = referenceIndex + 1 to liquidityCount - 1
                        highUnresolved := highUnresolved and completedLiquidityHighs.get(newerIndex) < candidateHigh
                        lowUnresolved := lowUnresolved and completedLiquidityLows.get(newerIndex) > candidateLow
                if highUnresolved
                    referenceHighTimes.push(completedLiquidityTimes.get(referenceIndex))
                    referenceHighPrices.push(candidateHigh)
                if lowUnresolved
                    referenceLowTimes.push(completedLiquidityTimes.get(referenceIndex))
                    referenceLowPrices.push(candidateLow)
        if bullCandidates.size() > 0
            for candidateIndex = 0 to bullCandidates.size() - 1
                Candidate activeCandidate = bullCandidates.get(candidateIndex)
                if not arrayHasInt(referenceLowTimes, activeCandidate.referenceTime)
                    referenceLowTimes.push(activeCandidate.referenceTime)
                    referenceLowPrices.push(activeCandidate.referencePrice)
        if bearCandidates.size() > 0
            for candidateIndex = 0 to bearCandidates.size() - 1
                Candidate activeCandidate = bearCandidates.get(candidateIndex)
                if not arrayHasInt(referenceHighTimes, activeCandidate.referenceTime)
                    referenceHighTimes.push(activeCandidate.referenceTime)
                    referenceHighPrices.push(activeCandidate.referencePrice)
        float sweepTolerance = sweepToleranceTicks * syminfo.mintick
        float nativeAtr = nativeAtrSeries[1]
        const float importance = 2.0
        float bullMeasure = htfViolationMode == "Body close" ? processedClose : processedLow
        float bearMeasure = htfViolationMode == "Body close" ? processedClose : processedHigh
        float priorBullMeasure = htfViolationMode == "Body close" ? close[2] : low[2]
        float priorBearMeasure = htfViolationMode == "Body close" ? close[2] : high[2]
        [bullRunCisd, bullDeliveryOldestOffset, bullDeliveryMemberCount, bullGenuineDeliveryCount,
             bullFirstDeliveryOffset, bullCisdDefiningOffset, bullHasStructureClose] = bearishDeliveryRun(1, effectiveDeliveryGap)
        [bullSwingHigh, bullSwingHighTime] = closestPriorSwingHigh(bullFirstDeliveryOffset, effectiveSwingSearchBars)
        int bullCisdOrigin = not na(bullCisdDefiningOffset) ? time[bullCisdDefiningOffset] : na
        bool bullSetupBaseValid = bullGenuineDeliveryCount >= MIN_DELIVERY_CANDLES and
             (not effectiveRequireStructureClose or bullHasStructureClose) and not na(bullRunCisd) and not na(bullCisdOrigin) and
             not na(bullSwingHigh) and not na(bullSwingHighTime) and bullSwingHigh > processedLow
        float bullDeliveryQuality = bullSetupBaseValid ?
             math.max(0.0, 1.0 - (bullFirstDeliveryOffset - 1) * 0.20) + math.max(0.0, 1.0 - math.abs(bullGenuineDeliveryCount - 2) * 0.20) : 0.0
        [bearRunCisd, bearDeliveryOldestOffset, bearDeliveryMemberCount, bearGenuineDeliveryCount,
             bearFirstDeliveryOffset, bearCisdDefiningOffset, bearHasStructureClose] = bullishDeliveryRun(1, effectiveDeliveryGap)
        [bearSwingLow, bearSwingLowTime] = closestPriorSwingLow(bearFirstDeliveryOffset, effectiveSwingSearchBars)
        int bearCisdOrigin = not na(bearCisdDefiningOffset) ? time[bearCisdDefiningOffset] : na
        bool bearSetupBaseValid = bearGenuineDeliveryCount >= MIN_DELIVERY_CANDLES and
             (not effectiveRequireStructureClose or bearHasStructureClose) and not na(bearRunCisd) and not na(bearCisdOrigin) and
             not na(bearSwingLow) and not na(bearSwingLowTime) and bearSwingLow < processedHigh
        float bearDeliveryQuality = bearSetupBaseValid ?
             math.max(0.0, 1.0 - (bearFirstDeliveryOffset - 1) * 0.20) + math.max(0.0, 1.0 - math.abs(bearGenuineDeliveryCount - 2) * 0.20) : 0.0
        if referenceLowTimes.size() > 0
            for referenceIndex = 0 to referenceLowTimes.size() - 1
                int referenceLowTime = referenceLowTimes.get(referenceIndex)
                float referenceLow = referenceLowPrices.get(referenceIndex)
                float bullThreshold = referenceLow - sweepTolerance
                bool bullViolated = bullMeasure < bullThreshold
                bool freshBullSweep = referenceLowTime < processedTime and bullViolated and
                     not na(priorBullMeasure) and priorBullMeasure >= bullThreshold
                if not arrayHasInt(consumedBullReferences, referenceLowTime)
                    int candidateIndex = candidateIndexByReference(bullCandidates, referenceLowTime)
                    bool createCandidate = na(candidateIndex) and freshBullSweep
                    bool deepenCandidate = false
                    if not na(candidateIndex)
                        Candidate existing = bullCandidates.get(candidateIndex)
                        deepenCandidate := bullViolated and processedLow < existing.extreme
                    if createCandidate or deepenCandidate
                        int competitionStart = time(competitionTf)[1]
                        int candidateCompetitionStart = createCandidate ? competitionStart : bullCandidates.get(candidateIndex).competitionStart
                        bool swingInCompetition = higherTimeframeNative or relaxCompetitionSwingWindow or
                             (not na(candidateCompetitionStart) and bullSwingHighTime >= candidateCompetitionStart)
                        bool bullSetupValid = bullSetupBaseValid and swingInCompetition
                        if createCandidate
                            Candidate fresh = Candidate.new(1, referenceLowTime, referenceLow, processedTime, processedTime,
                                 processedLow, processedBarIndex, processedBarIndex, competitionStart,
                                 bullSetupValid ? bullRunCisd : na, bullSetupValid ? bullCisdOrigin : na,
                                 na, na, na, bullSetupValid ? bullSwingHigh : na, bullSetupValid ? bullSwingHighTime : na,
                                 0, importance, bullDeliveryQuality)
                            bullCandidates.push(fresh)
                            if bullCandidates.size() > 64
                                Candidate removed = bullCandidates.shift()
                        else
                            Candidate updated = bullCandidates.get(candidateIndex)
                            updated.extreme := processedLow
                            updated.extremeTime := processedTime
                            updated.extremeBar := processedBarIndex
                            updated.cisd := bullSetupValid ? bullRunCisd : na
                            updated.cisdOriginTime := bullSetupValid ? bullCisdOrigin : na
                            updated.cisdConfirmTime := na
                            updated.cisdConfirmClose := na
                            updated.cisdConfirmBar := na
                            updated.swing := bullSetupValid ? bullSwingHigh : na
                            updated.swingTime := bullSetupValid ? bullSwingHighTime : na
                            updated.stage := 0
                            updated.liquidityImportance := importance
                            updated.deliveryQuality := bullDeliveryQuality
                            bullCandidates.set(candidateIndex, updated)
        if referenceHighTimes.size() > 0
            for referenceIndex = 0 to referenceHighTimes.size() - 1
                int referenceHighTime = referenceHighTimes.get(referenceIndex)
                float referenceHigh = referenceHighPrices.get(referenceIndex)
                float bearThreshold = referenceHigh + sweepTolerance
                bool bearViolated = bearMeasure > bearThreshold
                bool freshBearSweep = referenceHighTime < processedTime and bearViolated and
                     not na(priorBearMeasure) and priorBearMeasure <= bearThreshold
                if not arrayHasInt(consumedBearReferences, referenceHighTime)
                    int candidateIndex = candidateIndexByReference(bearCandidates, referenceHighTime)
                    bool createCandidate = na(candidateIndex) and freshBearSweep
                    bool deepenCandidate = false
                    if not na(candidateIndex)
                        Candidate existing = bearCandidates.get(candidateIndex)
                        deepenCandidate := bearViolated and processedHigh > existing.extreme
                    if createCandidate or deepenCandidate
                        int competitionStart = time(competitionTf)[1]
                        int candidateCompetitionStart = createCandidate ? competitionStart : bearCandidates.get(candidateIndex).competitionStart
                        bool swingInCompetition = higherTimeframeNative or relaxCompetitionSwingWindow or
                             (not na(candidateCompetitionStart) and bearSwingLowTime >= candidateCompetitionStart)
                        bool bearSetupValid = bearSetupBaseValid and swingInCompetition
                        if createCandidate
                            Candidate fresh = Candidate.new(-1, referenceHighTime, referenceHigh, processedTime, processedTime,
                                 processedHigh, processedBarIndex, processedBarIndex, competitionStart,
                                 bearSetupValid ? bearRunCisd : na, bearSetupValid ? bearCisdOrigin : na,
                                 na, na, na, bearSetupValid ? bearSwingLow : na, bearSetupValid ? bearSwingLowTime : na,
                                 0, importance, bearDeliveryQuality)
                            bearCandidates.push(fresh)
                            if bearCandidates.size() > 64
                                Candidate removed = bearCandidates.shift()
                        else
                            Candidate updated = bearCandidates.get(candidateIndex)
                            updated.extreme := processedHigh
                            updated.extremeTime := processedTime
                            updated.extremeBar := processedBarIndex
                            updated.cisd := bearSetupValid ? bearRunCisd : na
                            updated.cisdOriginTime := bearSetupValid ? bearCisdOrigin : na
                            updated.cisdConfirmTime := na
                            updated.cisdConfirmClose := na
                            updated.cisdConfirmBar := na
                            updated.swing := bearSetupValid ? bearSwingLow : na
                            updated.swingTime := bearSetupValid ? bearSwingLowTime : na
                            updated.stage := 0
                            updated.liquidityImportance := importance
                            updated.deliveryQuality := bearDeliveryQuality
                            bearCandidates.set(candidateIndex, updated)
        if relaxCompetitionSwingWindow
            if bullCandidates.size() > 0
                for refreshIndex = 0 to bullCandidates.size() - 1
                    Candidate pending = bullCandidates.get(refreshIndex)
                    bool needsStructure = pending.stage == 0 and (na(pending.cisd) or na(pending.swing))
                    bool afterSweepExtreme = processedTime > pending.extremeTime
                    bool swingAllowed = higherTimeframeNative or relaxCompetitionSwingWindow or
                         (not na(pending.competitionStart) and bullSwingHighTime >= pending.competitionStart)
                    if needsStructure and afterSweepExtreme and bullSetupBaseValid and swingAllowed
                        pending.cisd := bullRunCisd
                        pending.cisdOriginTime := bullCisdOrigin
                        pending.swing := bullSwingHigh
                        pending.swingTime := bullSwingHighTime
                        pending.deliveryQuality := bullDeliveryQuality
                        bullCandidates.set(refreshIndex, pending)
            if bearCandidates.size() > 0
                for refreshIndex = 0 to bearCandidates.size() - 1
                    Candidate pending = bearCandidates.get(refreshIndex)
                    bool needsStructure = pending.stage == 0 and (na(pending.cisd) or na(pending.swing))
                    bool afterSweepExtreme = processedTime > pending.extremeTime
                    bool swingAllowed = higherTimeframeNative or relaxCompetitionSwingWindow or
                         (not na(pending.competitionStart) and bearSwingLowTime >= pending.competitionStart)
                    if needsStructure and afterSweepExtreme and bearSetupBaseValid and swingAllowed
                        pending.cisd := bearRunCisd
                        pending.cisdOriginTime := bearCisdOrigin
                        pending.swing := bearSwingLow
                        pending.swingTime := bearSwingLowTime
                        pending.deliveryQuality := bearDeliveryQuality
                        bearCandidates.set(refreshIndex, pending)
        if bullCandidates.size() > 0
            int candidateIndex = bullCandidates.size() - 1
            while candidateIndex >= 0
                Candidate candidate = bullCandidates.get(candidateIndex)
                bool removeCandidate = false
                bool expired = processedBarIndex - candidate.startBar > effectiveCandidateLifetime
                bool cisdExpired = requireRapidReclaim and candidate.stage == 0 and
                     processedBarIndex - candidate.startBar > effectiveCisdLifetime
                bool swingBreakExpired = requireRapidSwingBreak and candidate.stage == 1 and
                     not na(candidate.cisdConfirmBar) and
                     processedBarIndex - candidate.cisdConfirmBar > effectiveSwingBreakBars
                bool afterExtreme = processedTime > candidate.extremeTime
                if expired or cisdExpired or swingBreakExpired
                    removeCandidate := true
                else if afterExtreme and not na(candidate.cisd) and not na(candidate.swing)
                    if candidate.stage == 0 and processedClose > candidate.cisd
                        candidate.stage := 1
                        candidate.cisdConfirmTime := processedTime
                        candidate.cisdConfirmClose := processedClose
                        candidate.cisdConfirmBar := processedBarIndex
                    bool swingBreached = candidate.stage == 1 and
                         (swingBreachMode == "Body close" ? processedClose > candidate.swing : processedHigh > candidate.swing)
                    if swingBreached
                        float projectionRange = candidate.swing - candidate.extreme
                        bool orientationValid = projectionRange > 0.0
                        if orientationValid
                            float normalizer = not na(nativeAtr) and nativeAtr > 0.0 ? nativeAtr : math.max(syminfo.mintick, projectionRange)
                            float sweepDepth = math.max(0.0, candidate.referencePrice - candidate.extreme) / normalizer
                            float cisdDisplacement = math.max(0.0, candidate.cisdConfirmClose - candidate.cisd) / normalizer
                            float swingDisplacement = math.max(0.0, processedHigh - candidate.swing) / normalizer
                            float candidateScore = candidate.liquidityImportance * 100.0 + candidate.deliveryQuality * 15.0 +
                                 sweepDepth * 12.0 + cisdDisplacement * 10.0 + swingDisplacement * 8.0 +
                                 projectionRange / normalizer * 5.0
                            int winnerIndex = bullWinnerWindows.indexof(candidate.competitionStart)
                            bool windowStillOpen = time(competitionTf)[1] == candidate.competitionStart
                            bool moreExtremeCisd = winnerIndex != -1 and candidate.cisd < bullWinnerCisds.get(winnerIndex)
                            bool winsCompetition = protectCompetitionExtremes or winnerIndex == -1 or
                                 (windowStillOpen and (protectCompetitionExtremes ? moreExtremeCisd : candidateScore > bullWinnerScores.get(winnerIndex)))
                            if winsCompetition
                                if winnerIndex == -1
                                    bullWinnerWindows.push(candidate.competitionStart)
                                    bullWinnerScores.push(candidateScore)
                                    bullWinnerCisds.push(candidate.cisd)
                                    if bullWinnerWindows.size() > 40
                                        bullWinnerWindows.shift()
                                        bullWinnerScores.shift()
                                        bullWinnerCisds.shift()
                                else if not protectCompetitionExtremes or moreExtremeCisd
                                    bullWinnerScores.set(winnerIndex, candidateScore)
                                    bullWinnerCisds.set(winnerIndex, candidate.cisd)
                                bullRevision += 1
                                bullWindow := candidate.competitionStart
                                bullConfirmTime := processedTime
                                bullFirstSweepTime := candidate.firstSweepTime
                                bullA0Time := candidate.swingTime
                                bullA0 := candidate.swing
                                bullA1Time := candidate.extremeTime
                                bullA1 := candidate.extreme
                                bullCisdOriginTime := candidate.cisdOriginTime
                                bullCisdConfirmTime := candidate.cisdConfirmTime
                                bullEventCisd := candidate.cisd
                                bullReferenceTime := candidate.referenceTime
                                bullReferencePrice := candidate.referencePrice
                                bullEventScore := candidateScore
                                rememberConsumedReference(consumedBullReferences, candidate.referenceTime)
                        removeCandidate := true
                if removeCandidate
                    bullCandidates.remove(candidateIndex)
                else
                    bullCandidates.set(candidateIndex, candidate)
                candidateIndex -= 1
        if bearCandidates.size() > 0
            int candidateIndex = bearCandidates.size() - 1
            while candidateIndex >= 0
                Candidate candidate = bearCandidates.get(candidateIndex)
                bool removeCandidate = false
                bool expired = processedBarIndex - candidate.startBar > effectiveCandidateLifetime
                bool cisdExpired = requireRapidReclaim and candidate.stage == 0 and
                     processedBarIndex - candidate.startBar > effectiveCisdLifetime
                bool swingBreakExpired = requireRapidSwingBreak and candidate.stage == 1 and
                     not na(candidate.cisdConfirmBar) and
                     processedBarIndex - candidate.cisdConfirmBar > effectiveSwingBreakBars
                bool afterExtreme = processedTime > candidate.extremeTime
                if expired or cisdExpired or swingBreakExpired
                    removeCandidate := true
                else if afterExtreme and not na(candidate.cisd) and not na(candidate.swing)
                    if candidate.stage == 0 and processedClose < candidate.cisd
                        candidate.stage := 1
                        candidate.cisdConfirmTime := processedTime
                        candidate.cisdConfirmClose := processedClose
                        candidate.cisdConfirmBar := processedBarIndex
                    bool swingBreached = candidate.stage == 1 and
                         (swingBreachMode == "Body close" ? processedClose < candidate.swing : processedLow < candidate.swing)
                    if swingBreached
                        float projectionRange = candidate.extreme - candidate.swing
                        bool orientationValid = projectionRange > 0.0
                        if orientationValid
                            float normalizer = not na(nativeAtr) and nativeAtr > 0.0 ? nativeAtr : math.max(syminfo.mintick, projectionRange)
                            float sweepDepth = math.max(0.0, candidate.extreme - candidate.referencePrice) / normalizer
                            float cisdDisplacement = math.max(0.0, candidate.cisd - candidate.cisdConfirmClose) / normalizer
                            float swingDisplacement = math.max(0.0, candidate.swing - processedLow) / normalizer
                            float candidateScore = candidate.liquidityImportance * 100.0 + candidate.deliveryQuality * 15.0 +
                                 sweepDepth * 12.0 + cisdDisplacement * 10.0 + swingDisplacement * 8.0 +
                                 projectionRange / normalizer * 5.0
                            int winnerIndex = bearWinnerWindows.indexof(candidate.competitionStart)
                            bool windowStillOpen = time(competitionTf)[1] == candidate.competitionStart
                            bool moreExtremeCisd = winnerIndex != -1 and candidate.cisd > bearWinnerCisds.get(winnerIndex)
                            bool winsCompetition = protectCompetitionExtremes or winnerIndex == -1 or
                                 (windowStillOpen and (protectCompetitionExtremes ? moreExtremeCisd : candidateScore > bearWinnerScores.get(winnerIndex)))
                            if winsCompetition
                                if winnerIndex == -1
                                    bearWinnerWindows.push(candidate.competitionStart)
                                    bearWinnerScores.push(candidateScore)
                                    bearWinnerCisds.push(candidate.cisd)
                                    if bearWinnerWindows.size() > 40
                                        bearWinnerWindows.shift()
                                        bearWinnerScores.shift()
                                        bearWinnerCisds.shift()
                                else if not protectCompetitionExtremes or moreExtremeCisd
                                    bearWinnerScores.set(winnerIndex, candidateScore)
                                    bearWinnerCisds.set(winnerIndex, candidate.cisd)
                                bearRevision += 1
                                bearWindow := candidate.competitionStart
                                bearConfirmTime := processedTime
                                bearFirstSweepTime := candidate.firstSweepTime
                                bearA0Time := candidate.swingTime
                                bearA0 := candidate.swing
                                bearA1Time := candidate.extremeTime
                                bearA1 := candidate.extreme
                                bearCisdOriginTime := candidate.cisdOriginTime
                                bearCisdConfirmTime := candidate.cisdConfirmTime
                                bearEventCisd := candidate.cisd
                                bearReferenceTime := candidate.referenceTime
                                bearReferencePrice := candidate.referencePrice
                                bearEventScore := candidateScore
                                rememberConsumedReference(consumedBearReferences, candidate.referenceTime)
                        removeCandidate := true
                if removeCandidate
                    bearCandidates.remove(candidateIndex)
                else
                    bearCandidates.set(candidateIndex, candidate)
                candidateIndex -= 1
    int bullPendingId = na
    float bullPendingCisd = na
    int latestBullPendingExtremeTime = na
    if bullCandidates.size() > 0
        for i = 0 to bullCandidates.size() - 1
            Candidate candidate = bullCandidates.get(i)
            if not na(candidate.cisd) and (na(latestBullPendingExtremeTime) or candidate.extremeTime > latestBullPendingExtremeTime)
                bullPendingId := candidate.cisdOriginTime
                bullPendingCisd := candidate.cisd
                latestBullPendingExtremeTime := candidate.extremeTime
    int bearPendingId = na
    float bearPendingCisd = na
    int latestBearPendingExtremeTime = na
    if bearCandidates.size() > 0
        for i = 0 to bearCandidates.size() - 1
            Candidate candidate = bearCandidates.get(i)
            if not na(candidate.cisd) and (na(latestBearPendingExtremeTime) or candidate.extremeTime > latestBearPendingExtremeTime)
                bearPendingId := candidate.cisdOriginTime
                bearPendingCisd := candidate.cisd
                latestBearPendingExtremeTime := candidate.extremeTime
    LayerSnapshot.new(
         bullRevision, bullWindow, bullConfirmTime, bullFirstSweepTime,
         bullA0Time, bullA0, bullA1Time, bullA1, bullCisdOriginTime, bullCisdConfirmTime, bullEventCisd,
         bullReferenceTime, bullReferencePrice, bullEventScore,
         bearRevision, bearWindow, bearConfirmTime, bearFirstSweepTime,
         bearA0Time, bearA0, bearA1Time, bearA1, bearCisdOriginTime, bearCisdConfirmTime, bearEventCisd,
         bearReferenceTime, bearReferencePrice, bearEventScore,
         bullPendingId, bullPendingCisd, bearPendingId, bearPendingCisd,
         processedTime, processedHigh, processedLow, processedClose)
layerLiquidityTf(int layer) =>
    layer == 0 ? layer0LiquidityTf : layer == 1 ? layer1LiquidityTf : layer == 2 ? layer2LiquidityTf :
     layer == 3 ? layer3LiquidityTf : layer == 4 ? layer4LiquidityTf : layer6LiquidityTf
layerConfirmationTf(int layer) =>
    layer == 0 ? layer0ConfirmationTf : layer == 1 ? layer1ConfirmationTf : layer == 2 ? layer2ConfirmationTf :
     layer == 3 ? layer3ConfirmationTf : layer == 4 ? layer4ConfirmationTf : layer6ConfirmationTf
layerCompetitionTf(int layer) =>
    layer == 0 ? layer0CompetitionTf : layer == 1 ? layer1CompetitionTf : layer == 2 ? layer2CompetitionTf :
     layer == 3 ? layer3CompetitionTf : layer == 4 ? layer4CompetitionTf : layer6CompetitionTf
layerCompetitionStart(int layer) =>
    layer == 0 ? time(layer0CompetitionTf) : layer == 1 ? time(layer1CompetitionTf) : layer == 2 ? time(layer2CompetitionTf) :
     layer == 3 ? time(layer3CompetitionTf) : layer == 4 ? time(layer4CompetitionTf) : time(layer6CompetitionTf)
layerRetentionBars(int layer) =>
    layer == 0 ? layer0Retention : layer == 1 ? layer1Retention : layer == 2 ? layer2Retention :
     layer == 3 ? layer3Retention : layer == 4 ? layer4Retention : layer6Retention
layerMarkerBars(int layer) =>
    layer == 0 ? layer0MarkerBars : layer == 1 ? layer1MarkerBars : layer == 2 ? layer2MarkerBars :
     layer == 3 ? layer3MarkerBars : layer == 4 ? layer4MarkerBars : layer6MarkerBars
float chartSecondsRaw = timeframe.in_seconds(timeframe.period)
int chartSeconds = na(chartSecondsRaw) ? 0 : int(chartSecondsRaw)
int group1StartSeconds = safeTfSeconds(group1StartTf)
int oneMinuteMaxSeconds = safeTfSeconds(layer6ConfirmationTf)
int group1MaxSeconds = safeTfSeconds(group1MaxTf)
int group3StartSeconds = safeTfSeconds(group3StartTf)
int group4StartSeconds = safeTfSeconds(group4StartTf)
int group5StartSeconds = safeTfSeconds(group5StartTf)
bool chartBoundariesValid = group1StartSeconds <= oneMinuteMaxSeconds and oneMinuteMaxSeconds < group1MaxSeconds and
     group1MaxSeconds < group3StartSeconds and group3StartSeconds < group4StartSeconds and group4StartSeconds < group5StartSeconds
bool supportedChart = not na(chartSecondsRaw) and chartSeconds >= group1StartSeconds and chartBoundariesValid
int mappedLayer = chartSeconds <= oneMinuteMaxSeconds ? 6 : chartSeconds <= group1MaxSeconds ? 0 :
     chartSeconds < group3StartSeconds ? 1 : chartSeconds < group4StartSeconds ? 2 :
     chartSeconds < group5StartSeconds ? 3 : 4
layerPrimaryVisible(int layer) =>
    supportedChart and x966ModuleStdv and layer == mappedLayer
layerConfigurationValid(int layer) =>
    safeTfSeconds(layerLiquidityTf(layer)) >= safeTfSeconds(layerConfirmationTf(layer)) and
     safeTfSeconds(layerCompetitionTf(layer)) > safeTfSeconds(layerConfirmationTf(layer))
var array<Projection> projections = array.new<Projection>()
var array<int> lastBullRevision = array.new_int(7, 0)
var array<int> lastBearRevision = array.new_int(7, 0)
var array<int> pendingBullId = array.new_int(7)
var array<float> pendingBullCisd = array.new_float(7)
var array<int> pendingBearId = array.new_int(7)
var array<float> pendingBearCisd = array.new_float(7)
var array<line> pendingBullLines = array.new_line(7)
var array<line> pendingBearLines = array.new_line(7)
var array<label> pendingBullLabels = array.new_label(7)
var array<label> pendingBearLabels = array.new_label(7)
var array<int> pendingBullDrawnId = array.new_int(7)
var array<int> pendingBearDrawnId = array.new_int(7)
int GLOBAL_PROJECTION_LIMIT = 140
buildRatios() =>
    array<float> ratios = array.new<float>()
    array<float> allRatios = array.from(0.0, 1.0, -1.0, -1.5, -2.0, -2.5, -3.5, -4.0)
    for i = 0 to allRatios.size() - 1
        float ratio = allRatios.get(i)
        if ratioEnabled(ratio)
            ratios.push(ratio)
    ratios
structureColor(int layer) =>
    useChartForeground ? chart.fg_color : stdvColor
deleteProjectionDrawings(Projection projection) =>
    Projection result = projection
    if result.ratioLines.size() > 0
        for i = 0 to result.ratioLines.size() - 1
            line.delete(result.ratioLines.get(i))
    if result.ratioLabels.size() > 0
        for i = 0 to result.ratioLabels.size() - 1
            label ratioLabel = result.ratioLabels.get(i)
            if not na(ratioLabel)
                label.delete(ratioLabel)
    if result.ratioBoxes.size() > 0
        for i = 0 to result.ratioBoxes.size() - 1
            box ratioBox = result.ratioBoxes.get(i)
            if not na(ratioBox)
                box.delete(ratioBox)
    result.ratioLines.clear()
    result.ratioLabels.clear()
    result.ratioBoxes.clear()
    if not na(result.liveMinusTwoBox)
        box.delete(result.liveMinusTwoBox)
        result.liveMinusTwoBox := na
    if not na(result.liveMinusFourBox)
        box.delete(result.liveMinusFourBox)
        result.liveMinusFourBox := na
    if not na(result.cisdLine)
        line.delete(result.cisdLine)
        result.cisdLine := na
    if not na(result.cisdLabel)
        label.delete(result.cisdLabel)
        result.cisdLabel := na
    result
buildEventId(int layer, int direction, string liquidityTf, int referenceTime, float referencePrice,
             int firstSweepTime, int anchor1Time, float anchor1, int cisdConfirmTime, int confirmationTime) =>
    str.tostring(layer) + "|" + str.tostring(direction) + "|" + liquidityTf + "|" + str.tostring(referenceTime) + "|" +
         str.tostring(referencePrice, format.mintick) + "|" + str.tostring(firstSweepTime) + "|" + str.tostring(anchor1Time) + "|" +
         str.tostring(anchor1, format.mintick) + "|" + str.tostring(cisdConfirmTime) + "|" + str.tostring(confirmationTime)
newProjection(int layer, int direction, int competitionStart, int revision, int confirmationTime, int firstSweepTime,
              int anchor0Time, float anchor0, int anchor1Time, float anchor1,
              int cisdOriginTime, int cisdConfirmTime, float cisd,
              int referenceTime, float referencePrice, float winnerScore) =>
    Projection.new(layer, direction, layerConfirmationTf(layer), layerLiquidityTf(layer), layerCompetitionTf(layer),
         competitionStart, revision, confirmationTime, firstSweepTime, anchor0Time, anchor0, anchor1Time, anchor1,
         cisdOriginTime, cisdConfirmTime, cisd, referenceTime, referencePrice,
         buildEventId(layer, direction, layerLiquidityTf(layer), referenceTime, referencePrice, firstSweepTime,
         anchor1Time, anchor1, cisdConfirmTime, confirmationTime),
         math.abs(anchor0 - anchor1), winnerScore, 0, na, confirmationTime, na,
         buildRatios(), array.new_line(), array.new_label(), array.new<box>(), na, na, na, na)
findSameWinner(int layer, int direction, int competitionStart) =>
    int found = na
    if projections.size() > 0
        for i = 0 to projections.size() - 1
            Projection projection = projections.get(i)
            if projection.layer == layer and projection.direction == direction and projection.competitionStart == competitionStart
                found := i
                break
    found
findNearDuplicate(int layer, int direction, int referenceTime, float referencePrice, int anchor1Time, float anchor0, float anchor1) =>
    int found = na
    float tolerance = duplicateToleranceTicks * syminfo.mintick
    float newRange = math.abs(anchor0 - anchor1)
    float newMinusTwoPointFive = projectionPrice(anchor0, anchor1, -2.5)
    if projections.size() > 0
        for i = 0 to projections.size() - 1
            Projection projection = projections.get(i)
            bool sameReference = projection.layer == layer and projection.direction == direction and
                 projection.referenceTime == referenceTime and math.abs(projection.referencePrice - referencePrice) <= tolerance
            bool sameSweep = projection.layer == layer and projection.direction == direction and projection.anchor1Time == anchor1Time
            bool nearAnchors = projection.layer == layer and projection.direction == direction and
                 math.abs(projection.anchor0 - anchor0) <= tolerance and math.abs(projection.anchor1 - anchor1) <= tolerance
            float oldMinusTwoPointFive = projectionPrice(projection.anchor0, projection.anchor1, -2.5)
            float objectiveTolerance = math.max(tolerance, math.min(newRange, projection.projectionRange) * 0.10)
            bool overlappingObjective = not protectCompetitionExtremes and projection.layer == layer and projection.direction == direction and
                 projection.status == 0 and math.abs(oldMinusTwoPointFive - newMinusTwoPointFive) <= objectiveTolerance
            if sameReference or sameSweep or nearAnchors or overlappingObjective
                found := i
                break
    found
upsertWinner(int layer, int direction, int revision, int competitionStart, int confirmationTime, int firstSweepTime,
             int anchor0Time, float anchor0, int anchor1Time, float anchor1,
             int cisdOriginTime, int cisdConfirmTime, float cisd,
             int referenceTime, float referencePrice, float winnerScore) =>
    bool valid = layerPrimaryVisible(layer) and layerConfigurationValid(layer) and
         not na(revision) and revision > 0 and not na(competitionStart) and not na(confirmationTime) and not na(firstSweepTime) and
         not na(anchor0Time) and not na(anchor0) and not na(anchor1Time) and not na(anchor1) and
         not na(cisdOriginTime) and not na(cisdConfirmTime) and not na(cisd) and
         not na(referenceTime) and not na(referencePrice) and not na(winnerScore) and
         (direction == 1 ? anchor0 > anchor1 : anchor0 < anchor1)
    if valid
        int sameWindow = findSameWinner(layer, direction, competitionStart)
        int duplicate = findNearDuplicate(layer, direction, referenceTime, referencePrice, anchor1Time, anchor0, anchor1)
        int target = protectCompetitionExtremes ? duplicate : (not na(sameWindow) ? sameWindow : duplicate)
        bool shouldUse = na(target)
        if not na(target)
            Projection old = projections.get(target)
            bool replacesWindowExtreme = direction == 1 ? cisd < old.cisd : cisd > old.cisd
            shouldUse := old.status != 0 or
                 (not na(sameWindow) ? (protectCompetitionExtremes ? replacesWindowExtreme : winnerScore > old.selectionScore) :
                 winnerScore > old.selectionScore)
        if shouldUse
            Projection fresh = newProjection(layer, direction, competitionStart, revision, confirmationTime, firstSweepTime,
                 anchor0Time, anchor0, anchor1Time, anchor1, cisdOriginTime, cisdConfirmTime, cisd,
                 referenceTime, referencePrice, winnerScore)
            if not na(target)
                Projection old = projections.get(target)
                old := deleteProjectionDrawings(old)
                projections.set(target, fresh)
            else
                projections.unshift(fresh)
            int storedForLayer = 0
            int storedLimit = layer == 0 ? layer0MaxStored : layer == 1 ? layer1MaxStored : layer == 2 ? layer2MaxStored :
                 layer == 3 ? layer3MaxStored : layer == 4 ? layer4MaxStored : layer6MaxStored
            if projections.size() > 0
                for i = 0 to projections.size() - 1
                    Projection storedProjection = projections.get(i)
                    if storedProjection.layer == layer
                        storedForLayer += 1
            if storedForLayer > storedLimit
                int trimIndex = projections.size() - 1
                while trimIndex >= 0 and storedForLayer > storedLimit
                    Projection oldProjection = projections.get(trimIndex)
                    if oldProjection.layer == layer
                        Projection removedLayerProjection = projections.remove(trimIndex)
                        removedLayerProjection := deleteProjectionDrawings(removedLayerProjection)
                        storedForLayer -= 1
                    trimIndex -= 1
            while projections.size() > GLOBAL_PROJECTION_LIMIT
                Projection removed = projections.pop()
                removed := deleteProjectionDrawings(removed)
    0
projectionRetentionMs(Projection projection) =>
    safeTfSeconds(projection.confirmationTf) * 1000 * layerRetentionBars(projection.layer)
projectionNearPrice(Projection projection) =>
    float minusFour = projectionPrice(projection.anchor0, projection.anchor1, -4.0)
    float lowBound = math.min(projection.anchor1, minusFour)
    float highBound = math.max(projection.anchor1, minusFour)
    float padding = projection.projectionRange * relevanceDistanceRanges
    close >= lowBound - padding and close <= highBound + padding
projectionObjectiveDistance(Projection projection) =>
    float d2 = math.abs(close - projectionPrice(projection.anchor0, projection.anchor1, -2.0))
    float d25 = math.abs(close - projectionPrice(projection.anchor0, projection.anchor1, -2.5))
    float d35 = math.abs(close - projectionPrice(projection.anchor0, projection.anchor1, -3.5))
    float d4 = math.abs(close - projectionPrice(projection.anchor0, projection.anchor1, -4.0))
    math.min(math.min(d2, d25), math.min(d35, d4))
projectionCompositeRank(Projection projection) =>
    float safeRange = math.max(syminfo.mintick, projection.projectionRange)
    float ageNativeBars = math.max(0.0, float(time - projection.confirmationTime) /
         float(safeTfSeconds(projection.confirmationTf) * 1000))
    float recencyScore = 100.0 / (1.0 + ageNativeBars / 50.0)
    float objectiveScore = 80.0 / (1.0 + projectionObjectiveDistance(projection) / safeRange)
    float unresolvedScore = projection.status == 0 ? 250.0 : 0.0
    projection.selectionScore + unresolvedScore + recencyScore + objectiveScore
selectedContains(array<int> selected, int projectionIndex) =>
    selected.indexof(projectionIndex) != -1
selectedDirectionCount(array<int> selected, int direction) =>
    int count = 0
    if selected.size() > 0
        for i = 0 to selected.size() - 1
            Projection selectedProjection = projections.get(selected.get(i))
            if selectedProjection.direction == direction
                count += 1
    count
bestProjectionIndex(array<int> candidates, array<int> selected, int layer, string criterion) =>
    int bestIndex = na
    float bestValue = na
    int bestTime = na
    if candidates.size() > 0
        for i = 0 to candidates.size() - 1
            int projectionIndex = candidates.get(i)
            if not selectedContains(selected, projectionIndex)
                Projection candidate = projections.get(projectionIndex)
                int directionCap = 3
                bool directionAvailable = selectedDirectionCount(selected, candidate.direction) < directionCap
                if directionAvailable
                    float criterionValue = criterion == SELECT_RECENT ? float(candidate.confirmationTime) : projectionCompositeRank(candidate)
                    if na(bestValue) or criterionValue > bestValue or
                         (criterionValue == bestValue and (na(bestTime) or candidate.confirmationTime > bestTime))
                        bestValue := criterionValue
                        bestTime := candidate.confirmationTime
                        bestIndex := projectionIndex
    bestIndex
newZoneBox(float anchor0, float anchor1, float ratioA, float ratioB,
           int markerStart, int markerEnd, color zoneDraw) =>
    float priceA = projectionPrice(anchor0, anchor1, ratioA)
    float priceB = projectionPrice(anchor0, anchor1, ratioB)
    box.new(left=markerStart, top=math.max(priceA, priceB), right=markerEnd, bottom=math.min(priceA, priceB),
         xloc=xloc.bar_time, border_color=color.new(zoneDraw, 100), border_width=1, bgcolor=zoneDraw)
updateZoneBox(box zoneBox, float anchor0, float anchor1, float ratioA, float ratioB,
              int markerStart, int markerEnd, color zoneDraw) =>
    float priceA = projectionPrice(anchor0, anchor1, ratioA)
    float priceB = projectionPrice(anchor0, anchor1, ratioB)
    box.set_left(zoneBox, markerStart)
    box.set_right(zoneBox, markerEnd)
    box.set_top(zoneBox, math.max(priceA, priceB))
    box.set_bottom(zoneBox, math.min(priceA, priceB))
    box.set_bgcolor(zoneBox, zoneDraw)
    box.set_border_color(zoneBox, color.new(zoneDraw, 100))
    0
projectionTargetTouched(Projection projection, float ratio, float barHigh, float barLow) =>
    float target = projectionPrice(projection.anchor0, projection.anchor1, ratio)
    projection.direction == 1 ? barHigh >= target : barLow <= target
renderProjection(Projection projection, bool visible, int transparency, int primaryWindowZoneRole, bool liveExtensionOwner) =>
    Projection result = projection
    if not visible
        result := deleteProjectionDrawings(result)
    else
        color baseStructure = color.new(structureColor(result.layer), transparency)
        color anchorDraw = color.new(anchorLineColor, transparency)
        color cisdBase = result.direction == 1 ? bullishCisdColor : bearishCisdColor
        color cisdDraw = color.new(cisdBase, math.min(85, transparency))
        int historicalZoneFade = int(math.round(transparency * 0.50))
        int effectiveZoneTransparency = primaryWindowZoneRole == 1 ? stdvZoneTransparency :
             primaryWindowZoneRole == -1 ? math.min(100, stdvZoneTransparency + math.max(12, historicalZoneFade)) :
             math.min(100, stdvZoneTransparency + historicalZoneFade)
        color zoneDraw = color.new(stdvZoneColor, effectiveZoneTransparency)
        int nativeMs = safeTfSeconds(result.confirmationTf) * 1000
        int markerStart = result.anchor1Time
        int markerEnd = markerStart + layerMarkerBars(result.layer) * nativeMs
        labelSize = labelSizeFromString(labelSizeInput)
        if result.ratioLines.size() == 0
            for i = 0 to result.ratios.size() - 1
                float ratio = result.ratios.get(i)
                float price = projectionPrice(result.anchor0, result.anchor1, ratio)
                bool anchorRatio = ratio == 0.0 or ratio == 1.0
                int x1 = ratio == 0.0 ? result.anchor0Time : ratio == 1.0 ? result.anchor1Time : markerStart
                int x2 = anchorRatio ? result.confirmationTime + nativeMs : markerEnd
                lineStyle = anchorRatio ? lineStyleFromString(anchorLineStyleInput) : lineStyleFromString(stdvLineStyleInput)
                int width = anchorRatio ? anchorLineWidth : stdvLineWidth
                color ratioDraw = anchorRatio ? anchorDraw : baseStructure
                line ratioLine = line.new(x1=x1, y1=price, x2=x2, y2=price, xloc=xloc.bar_time,
                     extend=extend.none, color=ratioDraw, style=lineStyle, width=width)
                label ratioLabel = na
                if not anchorRatio
                    int labelX = x1 - int(nativeMs * 0.25)
                    ratioLabel := label.new(x=labelX, y=price, text=ratioText(ratio),
                         xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none,
                         color=color.new(color.white, 100), textcolor=ratioDraw, size=labelSize,
                         text_font_family=font.family_monospace, textalign=text.align_right)
                result.ratioLines.push(ratioLine)
                result.ratioLabels.push(ratioLabel)
            if fillMinusOneZone and showMinusOne and showMinusOnePointFive
                result.ratioBoxes.push(newZoneBox(result.anchor0, result.anchor1, -1.0, -1.5, markerStart, markerEnd, zoneDraw))
            if fillMinusTwoZone and showMinusTwo and showMinusTwoPointFive
                result.ratioBoxes.push(newZoneBox(result.anchor0, result.anchor1, -2.0, -2.5, markerStart, markerEnd, zoneDraw))
            if fillMinusThreePointFiveZone and showMinusThreePointFive and showMinusFour
                result.ratioBoxes.push(newZoneBox(result.anchor0, result.anchor1, -3.5, -4.0, markerStart, markerEnd, zoneDraw))
            int cisdEnd = extendConfirmedCisd ? (result.status == 0 ? time_close : result.endTime) : result.cisdConfirmTime + nativeMs
            result.cisdLine := line.new(x1=result.cisdOriginTime, y1=result.cisd, x2=cisdEnd, y2=result.cisd,
                 xloc=xloc.bar_time, extend=extend.none, color=cisdDraw, style=lineStyleFromString(cisdLineStyleInput), width=cisdLineWidth)
            if showCisdText
                result.cisdLabel := label.new(x=result.cisdOriginTime, y=result.cisd, text="CISD",
                     xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none,
                     color=color.new(color.white, 100), textcolor=cisdDraw, size=size.tiny)
        else
            for i = 0 to result.ratioLines.size() - 1
                float ratio = result.ratios.get(i)
                bool anchorRatio = ratio == 0.0 or ratio == 1.0
                color ratioDraw = anchorRatio ? anchorDraw : baseStructure
                line.set_color(result.ratioLines.get(i), ratioDraw)
                label ratioLabel = result.ratioLabels.get(i)
                if not na(ratioLabel)
                    label.set_textcolor(ratioLabel, ratioDraw)
                line.set_style(result.ratioLines.get(i), anchorRatio ? lineStyleFromString(anchorLineStyleInput) : lineStyleFromString(stdvLineStyleInput))
                line.set_width(result.ratioLines.get(i), anchorRatio ? anchorLineWidth : stdvLineWidth)
            int zoneIndex = 0
            if fillMinusOneZone and showMinusOne and showMinusOnePointFive
                if zoneIndex < result.ratioBoxes.size()
                    updateZoneBox(result.ratioBoxes.get(zoneIndex), result.anchor0, result.anchor1, -1.0, -1.5, markerStart, markerEnd, zoneDraw)
                zoneIndex += 1
            if fillMinusTwoZone and showMinusTwo and showMinusTwoPointFive
                if zoneIndex < result.ratioBoxes.size()
                    updateZoneBox(result.ratioBoxes.get(zoneIndex), result.anchor0, result.anchor1, -2.0, -2.5, markerStart, markerEnd, zoneDraw)
                zoneIndex += 1
            if fillMinusThreePointFiveZone and showMinusThreePointFive and showMinusFour
                if zoneIndex < result.ratioBoxes.size()
                    updateZoneBox(result.ratioBoxes.get(zoneIndex), result.anchor0, result.anchor1, -3.5, -4.0, markerStart, markerEnd, zoneDraw)
                zoneIndex += 1
            int cisdEnd = extendConfirmedCisd ? (result.status == 0 ? time_close : result.endTime) : result.cisdConfirmTime + nativeMs
            if not na(result.cisdLine)
                line.set_x2(result.cisdLine, cisdEnd)
                line.set_color(result.cisdLine, cisdDraw)
                line.set_style(result.cisdLine, lineStyleFromString(cisdLineStyleInput))
                line.set_width(result.cisdLine, cisdLineWidth)
            if not na(result.cisdLabel)
                label.set_textcolor(result.cisdLabel, cisdDraw)
        bool useLiveExtensions = liveExtensionOwner and result.status == 0
        color liveZoneDraw = color.new(stdvZoneColor, math.min(100, effectiveZoneTransparency + 9))
        bool showLiveMinusTwo = useLiveExtensions and fillMinusTwoZone and showMinusTwo and showMinusTwoPointFive
        int liveMinusTwoStart = markerEnd
        int liveMinusTwoEnd = not na(result.firstObjectiveHitTime) ?
             math.max(liveMinusTwoStart, result.firstObjectiveHitTime) : time_close
        if showLiveMinusTwo and liveMinusTwoEnd > liveMinusTwoStart
            if na(result.liveMinusTwoBox)
                result.liveMinusTwoBox := newZoneBox(result.anchor0, result.anchor1, -2.0, -2.5,
                     liveMinusTwoStart, liveMinusTwoEnd, liveZoneDraw)
            else
                updateZoneBox(result.liveMinusTwoBox, result.anchor0, result.anchor1, -2.0, -2.5,
                     liveMinusTwoStart, liveMinusTwoEnd, liveZoneDraw)
        else if not na(result.liveMinusTwoBox)
            box.delete(result.liveMinusTwoBox)
            result.liveMinusTwoBox := na
        bool showLiveMinusFour = useLiveExtensions and fillMinusThreePointFiveZone and
             showMinusThreePointFive and showMinusFour and not na(result.firstObjectiveHitTime)
        int liveMinusFourStart = markerEnd
        int liveMinusFourEnd = time_close
        if showLiveMinusFour and liveMinusFourEnd > liveMinusFourStart
            if na(result.liveMinusFourBox)
                result.liveMinusFourBox := newZoneBox(result.anchor0, result.anchor1, -3.5, -4.0,
                     liveMinusFourStart, liveMinusFourEnd, liveZoneDraw)
            else
                updateZoneBox(result.liveMinusFourBox, result.anchor0, result.anchor1, -3.5, -4.0,
                     liveMinusFourStart, liveMinusFourEnd, liveZoneDraw)
        else if not na(result.liveMinusFourBox)
            box.delete(result.liveMinusFourBox)
            result.liveMinusFourBox := na
    result
ingestSnapshot(int layer, LayerSnapshot snapshot) =>
    if not na(snapshot)
        if not na(snapshot.nativeTime)
            int seenBull = lastBullRevision.get(layer)
            int seenBear = lastBearRevision.get(layer)
            if snapshot.bullRevision > seenBull
                upsertWinner(layer, 1, snapshot.bullRevision, snapshot.bullWindow, snapshot.bullConfirmTime,
                     snapshot.bullFirstSweepTime,
                     snapshot.bullA0Time, snapshot.bullA0, snapshot.bullA1Time, snapshot.bullA1,
                     snapshot.bullCisdOriginTime, snapshot.bullCisdConfirmTime, snapshot.bullCisd,
                     snapshot.bullReferenceTime, snapshot.bullReferencePrice, snapshot.bullScore)
                lastBullRevision.set(layer, snapshot.bullRevision)
            if snapshot.bearRevision > seenBear
                upsertWinner(layer, -1, snapshot.bearRevision, snapshot.bearWindow, snapshot.bearConfirmTime,
                     snapshot.bearFirstSweepTime,
                     snapshot.bearA0Time, snapshot.bearA0, snapshot.bearA1Time, snapshot.bearA1,
                     snapshot.bearCisdOriginTime, snapshot.bearCisdConfirmTime, snapshot.bearCisd,
                     snapshot.bearReferenceTime, snapshot.bearReferencePrice, snapshot.bearScore)
                lastBearRevision.set(layer, snapshot.bearRevision)
            pendingBullId.set(layer, snapshot.bullPendingId)
            pendingBullCisd.set(layer, snapshot.bullPendingCisd)
            pendingBearId.set(layer, snapshot.bearPendingId)
            pendingBearCisd.set(layer, snapshot.bearPendingCisd)
            if projections.size() > 0
                for i = 0 to projections.size() - 1
                    Projection projection = projections.get(i)
                    if projection.layer == layer and snapshot.nativeTime > projection.lastLifecycleTime
                        if projection.status == 0 and snapshot.nativeTime > projection.confirmationTime
                            if na(projection.firstObjectiveHitTime) and
                                 projectionTargetTouched(projection, -2.0, snapshot.nativeHigh, snapshot.nativeLow)
                                projection.firstObjectiveHitTime := snapshot.nativeTime
                        if projection.status == 0 and snapshot.nativeTime > projection.confirmationTime
                            float minusFour = projectionPrice(projection.anchor0, projection.anchor1, -4.0)
                            bool wickInvalid = projection.direction == 1 ? snapshot.nativeLow < projection.anchor1 : snapshot.nativeHigh > projection.anchor1
                            bool closeInvalid = projection.direction == 1 ? snapshot.nativeClose < projection.anchor1 : snapshot.nativeClose > projection.anchor1
                            bool invalidated = anchorInvalidationMode == "Wick" ? wickInvalid :
                                 anchorInvalidationMode == "Body close" ? closeInvalid : false
                            bool minusFourWick = projection.direction == 1 ? snapshot.nativeHigh >= minusFour : snapshot.nativeLow <= minusFour
                            bool minusFourClose = projection.direction == 1 ? snapshot.nativeClose >= minusFour : snapshot.nativeClose <= minusFour
                            bool exhausted = minusFourCompletionMode == "Wick" ? minusFourWick :
                                 minusFourCompletionMode == "Body close" ? minusFourClose : false
                            if exhausted
                                projection.status := 2
                                projection.endTime := snapshot.nativeTime
                            else if invalidated
                                projection.status := 1
                                projection.endTime := snapshot.nativeTime
                        projection.lastLifecycleTime := snapshot.nativeTime
                        projections.set(i, projection)
    0
ingestSnapshotArray(int layer, array<LayerSnapshot> snapshots) =>
    if snapshots.size() > 0
        for snapshotIndex = 0 to snapshots.size() - 1
            LayerSnapshot snapshot = snapshots.get(snapshotIndex)
            ingestSnapshot(layer, snapshot)
    0
detectConfiguredLayer() =>
    int nativeSec = safeTfSeconds(timeframe.period)
    string liquidityTf = nativeSec == safeTfSeconds(layer6ConfirmationTf) ? layer6LiquidityTf :
         nativeSec == safeTfSeconds(layer0ConfirmationTf) ? layer0LiquidityTf :
         nativeSec == safeTfSeconds(layer1ConfirmationTf) ? layer1LiquidityTf :
         nativeSec == safeTfSeconds(layer2ConfirmationTf) ? layer2LiquidityTf :
         nativeSec == safeTfSeconds(layer3ConfirmationTf) ? layer3LiquidityTf : layer4LiquidityTf
    int normalLookback = nativeSec == safeTfSeconds(layer4ConfirmationTf) ? layer4NormalLookback : 12
    int candidateLifetime = nativeSec == safeTfSeconds(layer3ConfirmationTf) ? layer3CandidateLifetime :
         nativeSec == safeTfSeconds(layer4ConfirmationTf) ? layer4CandidateLifetime : 24
    int cisdLifetime = nativeSec == safeTfSeconds(layer2ConfirmationTf) ? layer2CisdLifetime :
         nativeSec == safeTfSeconds(layer3ConfirmationTf) ? layer3CisdLifetime :
         nativeSec == safeTfSeconds(layer4ConfirmationTf) ? layer4CisdLifetime : 8
    string competitionTf = nativeSec == safeTfSeconds(layer6ConfirmationTf) ? layer6CompetitionTf :
         nativeSec == safeTfSeconds(layer0ConfirmationTf) ? layer0CompetitionTf :
         nativeSec == safeTfSeconds(layer1ConfirmationTf) ? layer1CompetitionTf :
         nativeSec == safeTfSeconds(layer2ConfirmationTf) ? layer2CompetitionTf :
         nativeSec == safeTfSeconds(layer3ConfirmationTf) ? layer3CompetitionTf : layer4CompetitionTf
    detectLayer(liquidityTf, normalLookback, candidateLifetime, cisdLifetime, competitionTf)
// Current-chart STDV/CISD only: run the single primary preset for this chart.
// Higher-timeframe STDV/CISD context was removed to reduce Pine compile complexity.
if x966ModuleStdv and layerPrimaryVisible(mappedLayer) and layerConfigurationValid(mappedLayer)
    string primaryConfirmationTf = layerConfirmationTf(mappedLayer)
    int primaryConfirmationSeconds = safeTfSeconds(primaryConfirmationTf)
    // Run natively when the chart already matches the confirmation timeframe.
    // Returning the large LayerSnapshot UDT through request.security() on every
    // one-minute bar duplicates its history and can exceed TradingView memory.
    if primaryConfirmationSeconds == chartSeconds
        int nativeDetectionBars = mappedLayer == 6 ? 768 : 512
        bool insideNativeDetectionWindow = bar_index >= math.max(0, last_bar_index - nativeDetectionBars)
        if insideNativeDetectionWindow
            LayerSnapshot primarySnapshot = detectConfiguredLayer()
            ingestSnapshot(mappedLayer, primarySnapshot)
    else if primaryConfirmationSeconds < chartSeconds
        array<LayerSnapshot> primarySnapshots = request.security_lower_tf(
             syminfo.tickerid, primaryConfirmationTf, detectConfiguredLayer(),
             ignore_invalid_timeframe=true, calc_bars_count=1500)
        ingestSnapshotArray(mappedLayer, primarySnapshots)
    else
        LayerSnapshot primarySnapshot = request.security(
             syminfo.tickerid, primaryConfirmationTf, detectConfiguredLayer(),
             gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=1500)
        ingestSnapshot(mappedLayer, primarySnapshot)
if projections.size() > 0
    int lifecycleIndex = projections.size() - 1
    while lifecycleIndex >= 0
        Projection projection = projections.get(lifecycleIndex)
        bool chartCanInvalidateLive = chartSeconds <= safeTfSeconds(projection.confirmationTf)
        bool afterConfirmation = time > projection.confirmationTime
        if projection.status == 0 and chartCanInvalidateLive and afterConfirmation
            if na(projection.firstObjectiveHitTime) and projectionTargetTouched(projection, -2.0, high, low)
                projection.firstObjectiveHitTime := time
            float minusFour = projectionPrice(projection.anchor0, projection.anchor1, -4.0)
            bool anchorWickThrough = anchorInvalidationMode == "Wick" and
                 (projection.direction == 1 ? low < projection.anchor1 : high > projection.anchor1)
            bool minusFourWickThrough = minusFourCompletionMode == "Wick" and
                 (projection.direction == 1 ? high >= minusFour : low <= minusFour)
            if minusFourWickThrough
                projection.status := 2
                projection.endTime := time
            else if anchorWickThrough
                projection.status := 1
                projection.endTime := time
            projections.set(lifecycleIndex, projection)
        Projection checkedProjection = projections.get(lifecycleIndex)
        if checkedProjection.status != 0
            Projection removedProjection = projections.remove(lifecycleIndex)
            removedProjection := deleteProjectionDrawings(removedProjection)
        lifecycleIndex -= 1
if barstate.islast
    int layer = mappedLayer
    bool visibleLayer = layerPrimaryVisible(layer) and layerConfigurationValid(layer)
    int bullId = pendingBullId.get(layer)
    float bullCisd = pendingBullCisd.get(layer)
    int bearId = pendingBearId.get(layer)
    float bearCisd = pendingBearCisd.get(layer)
    line bullLine = pendingBullLines.get(layer)
    label bullLabel = pendingBullLabels.get(layer)
    int bullDrawnId = pendingBullDrawnId.get(layer)
    bool showBull = visibleLayer and showPendingCisd and not na(bullId) and not na(bullCisd)
    if not showBull
        if not na(bullLine)
            line.delete(bullLine)
            pendingBullLines.set(layer, na)
        if not na(bullLabel)
            label.delete(bullLabel)
            pendingBullLabels.set(layer, na)
        pendingBullDrawnId.set(layer, na)
    else if na(bullLine) or bullId != bullDrawnId
        if not na(bullLine)
            line.delete(bullLine)
        if not na(bullLabel)
            label.delete(bullLabel)
        line freshBullLine = line.new(x1=bullId, y1=bullCisd, x2=time_close, y2=bullCisd,
             xloc=xloc.bar_time, extend=extend.right, color=bullishCisdColor, style=line.style_dashed, width=1)
        label freshBullLabel = label.new(x=time_close, y=bullCisd, text="forming CISD",
             xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none,
             color=color.new(color.white, 100), textcolor=bullishCisdColor, size=size.tiny)
        pendingBullLines.set(layer, freshBullLine)
        pendingBullLabels.set(layer, freshBullLabel)
        pendingBullDrawnId.set(layer, bullId)
    else
        line.set_x2(bullLine, time_close)
        line.set_y1(bullLine, bullCisd)
        line.set_y2(bullLine, bullCisd)
        if not na(bullLabel)
            label.set_xy(bullLabel, time_close, bullCisd)
            label.set_textcolor(bullLabel, bullishCisdColor)
    line bearLine = pendingBearLines.get(layer)
    label bearLabel = pendingBearLabels.get(layer)
    int bearDrawnId = pendingBearDrawnId.get(layer)
    bool showBear = visibleLayer and showPendingCisd and not na(bearId) and not na(bearCisd)
    if not showBear
        if not na(bearLine)
            line.delete(bearLine)
            pendingBearLines.set(layer, na)
        if not na(bearLabel)
            label.delete(bearLabel)
            pendingBearLabels.set(layer, na)
        pendingBearDrawnId.set(layer, na)
    else if na(bearLine) or bearId != bearDrawnId
        if not na(bearLine)
            line.delete(bearLine)
        if not na(bearLabel)
            label.delete(bearLabel)
        line freshBearLine = line.new(x1=bearId, y1=bearCisd, x2=time_close, y2=bearCisd,
             xloc=xloc.bar_time, extend=extend.right, color=bearishCisdColor, style=line.style_dashed, width=1)
        label freshBearLabel = label.new(x=time_close, y=bearCisd, text="forming CISD",
             xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none,
             color=color.new(color.white, 100), textcolor=bearishCisdColor, size=size.tiny)
        pendingBearLines.set(layer, freshBearLine)
        pendingBearLabels.set(layer, freshBearLabel)
        pendingBearDrawnId.set(layer, bearId)
    else
        line.set_x2(bearLine, time_close)
        line.set_y1(bearLine, bearCisd)
        line.set_y2(bearLine, bearCisd)
        if not na(bearLabel)
            label.set_xy(bearLabel, time_close, bearCisd)
            label.set_textcolor(bearLabel, bearishCisdColor)
var array<bool> selectedProjection = array.new_bool()
selectedProjection.clear()
int primaryLowestExtremeIndex = na
int primaryHighestExtremeIndex = na
if projections.size() > 0
    for i = 0 to projections.size() - 1
        selectedProjection.push(false)
    int layer = mappedLayer
    int activeCompetitionStart = layerCompetitionStart(layer)
    array<int> candidates = array.new_int()
    for i = 0 to projections.size() - 1
        Projection projection = projections.get(i)
        bool withinRetention = time <= projection.confirmationTime + projectionRetentionMs(projection)
        bool unresolvedAndRelevant = projection.status == 0 and (withinRetention or projectionNearPrice(projection))
        bool protectedWindowSet = protectCompetitionExtremes and projection.status == 0 and projection.competitionStart == activeCompetitionStart
        if projection.layer == layer and (unresolvedAndRelevant or protectedWindowSet)
            candidates.push(i)
    array<int> selected = array.new_int()
    int effectiveMaxTotal = maxVisibleSets
    if protectCompetitionExtremes and candidates.size() > 0
        int protectedLow = na
        int protectedHigh = na
        float lowestCisd = na
        float highestCisd = na
        for candidatePosition = 0 to candidates.size() - 1
            int candidateIndex = candidates.get(candidatePosition)
            Projection candidateProjection = projections.get(candidateIndex)
            if na(lowestCisd) or candidateProjection.cisd < lowestCisd
                lowestCisd := candidateProjection.cisd
                protectedLow := candidateIndex
            if na(highestCisd) or candidateProjection.cisd > highestCisd
                highestCisd := candidateProjection.cisd
                protectedHigh := candidateIndex
        if not na(protectedLow)
            selected.push(protectedLow)
            primaryLowestExtremeIndex := protectedLow
        if not na(protectedHigh)
            primaryHighestExtremeIndex := protectedHigh
            if not selectedContains(selected, protectedHigh)
                selected.push(protectedHigh)
    int targetCount = math.min(effectiveMaxTotal, candidates.size())
    for pick = 0 to 1
        if selected.size() < targetCount
            int bestRecent = bestProjectionIndex(candidates, selected, layer, SELECT_RECENT)
            if not na(bestRecent)
                selected.push(bestRecent)
    for pick = 0 to 1
        if selected.size() < targetCount
            int bestStrong = bestProjectionIndex(candidates, selected, layer, SELECT_SCORE)
            if not na(bestStrong)
                selected.push(bestStrong)
    for fill = 0 to 9
        if selected.size() < targetCount
            int bestFill = bestProjectionIndex(candidates, selected, layer, SELECT_SCORE)
            if not na(bestFill)
                selected.push(bestFill)
    if selected.size() > 0
        for i = 0 to selected.size() - 1
            selectedProjection.set(selected.get(i), true)
    int livePrimaryBullIndex = na
    int livePrimaryBearIndex = na
    int livePrimaryBullTime = na
    int livePrimaryBearTime = na
    for i = 0 to projections.size() - 1
        if selectedProjection.get(i)
            Projection liveCandidate = projections.get(i)
            bool currentTfCandidate = liveCandidate.status == 0 and layerPrimaryVisible(liveCandidate.layer)
            if currentTfCandidate
                if liveCandidate.direction == 1 and
                     (na(livePrimaryBullTime) or liveCandidate.confirmationTime > livePrimaryBullTime)
                    livePrimaryBullIndex := i
                    livePrimaryBullTime := liveCandidate.confirmationTime
                if liveCandidate.direction == -1 and
                     (na(livePrimaryBearTime) or liveCandidate.confirmationTime > livePrimaryBearTime)
                    livePrimaryBearIndex := i
                    livePrimaryBearTime := liveCandidate.confirmationTime
    for i = 0 to projections.size() - 1
        Projection projection = projections.get(i)
        bool visible = selectedProjection.get(i)
        int newerSelected = 0
        if visible
            for j = 0 to projections.size() - 1
                if i != j and selectedProjection.get(j)
                    Projection other = projections.get(j)
                    if other.layer == projection.layer and other.confirmationTime > projection.confirmationTime
                        newerSelected += 1
        int transparency = newerSelected == 0 ? 0 :
             math.min(90, 15 + (newerSelected - 1) * 8)
        int primaryWindowZoneRole = 0
        if protectCompetitionExtremes and layerPrimaryVisible(projection.layer) and projection.status == 0
            bool isPrimaryExtreme = i == primaryLowestExtremeIndex or i == primaryHighestExtremeIndex
            primaryWindowZoneRole := isPrimaryExtreme ? 1 : -1
        bool liveExtensionOwner = i == livePrimaryBullIndex or i == livePrimaryBearIndex
        projection := renderProjection(projection, visible, transparency, primaryWindowZoneRole, liveExtensionOwner)
        projections.set(i, projection)
const int TEMPLATE_LINE_BUDGET = 70
const string GROUP_AUTO = "Auto Mode"
const string GROUP_HTF = "HTF Candle Sets"
const string GROUP_STYLE = "HTF Candle Style"
const string GROUP_TEMPLATE = "HTF Structure Tools"
// PSP / HTF directional-comparison engine removed from the all-in-one build.
const int lane1Count = 4
const int lane2Count = 4
const int lane3Count = 4
const int lane4Count = 3
const int lane5Count = 2
int requestedBaseOffset = input.int(28, "HTF Base Canvas Offset", minval = 20, maxval = 150, group = GROUP_HTF, tooltip = "Future bar offset where HTF candle lanes start, safely decoupled from intraday projections.")
const int requestedSetGap = 5
const int requestedCandleGap = 1
const int requestedBodyWidth = 2
const int futureDrawingLimit = 490
color bullBodyColor = input.color(color.rgb(165, 194, 165), "Bull body", group = GROUP_STYLE)
color bearBodyColor = input.color(color.rgb(51, 65, 85), "Bear body", group = GROUP_STYLE)
color dojiBodyColor = color.gray
color bullBorderColor = input.color(color.rgb(100, 116, 139), "Bull border", group = GROUP_STYLE)
color bearBorderColor = input.color(color.rgb(100, 116, 139), "Bear border", group = GROUP_STYLE)
color dojiBorderColor = color.gray
color bullWickColor = input.color(color.rgb(148, 163, 184), "Bull wick", group = GROUP_STYLE)
color bearWickColor = input.color(color.rgb(148, 163, 184), "Bear wick", group = GROUP_STYLE)
color dojiWickColor = color.gray
color laneLabelColor = input.color(color.rgb(203, 213, 225), "HTF label color", group = GROUP_STYLE)
string laneLabelSize = input.string("Tiny", "HTF label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GROUP_STYLE)
color htfRangeHighLowColor = input.color(color.rgb(203, 213, 225), "HTF Range H/L", inline="HTFRANGE", group = GROUP_STYLE)
color htfRangeQuarterColor = input.color(color.rgb(41, 98, 255), "25 / 75", inline="HTFRANGE", group = GROUP_STYLE)
color htfRangeMidColor = input.color(color.rgb(242, 54, 69), "50", inline="HTFRANGE", group = GROUP_STYLE)
color templateGuideColor = input.color(color.rgb(148, 163, 184), "Midpoint / sweep line color", group = GROUP_TEMPLATE)
type HtfBar
    float openPrice
    float highPrice
    float lowPrice
    float closePrice
    int identity
    box bodyBox
    line upperWick
    line lowerWick
type HtfLane
    array<HtfBar> bars
    array<line> templateLines
    array<line> rangeLines
    array<label> rangeLabels
    label timeframeLabel
newLane() =>
    HtfLane.new(
         array.new<HtfBar>(0),
         array.new_line(0),
         array.new_line(0),
         array.new_label(0),
         na)
var HtfLane lane1 = newLane()
var HtfLane lane2 = newLane()
var HtfLane lane3 = newLane()
var HtfLane lane4 = newLane()
var HtfLane lane5 = newLane()
transparentColor() =>
    color.new(color.white, 100)
textSize(string choice) =>
    string result = size.normal
    if choice == "Tiny"
        result := size.tiny
    else if choice == "Small"
        result := size.small
    else if choice == "Large"
        result := size.large
    else if choice == "Huge"
        result := size.huge
    result
candleDirection(float openValue, float closeValue) =>
    int result = 0
    if closeValue > openValue
        result := 1
    else if closeValue < openValue
        result := -1
    result
formattedTimeframe(string selectedTf) =>
    float seconds = timeframe.in_seconds(selectedTf)
    string result = selectedTf
    if not na(seconds)
        if seconds < 60
            result := str.tostring(int(seconds)) + "S"
        else if seconds < 3600
            result := str.tostring(int(seconds / 60)) + "M"
        else if seconds < 86400
            result := str.tostring(int(seconds / 3600)) + "H"
        else if seconds < 604800
            result := str.tostring(int(seconds / 86400)) + "D"
    result
twoDigitTimePart(int value) =>
    value < 10 ? "0" + str.tostring(value) : str.tostring(value)
remainingTimeText(string selectedTf) =>
    int selectedClose = time_close(selectedTf)
    string result = ""
    if not na(selectedClose)
        int remainingMs = math.max(selectedClose - timenow, 0)
        int totalSeconds = int(math.floor(remainingMs / 1000.0))
        int totalHours = int(math.floor(totalSeconds / 3600.0))
        int minutes = int(math.floor((totalSeconds % 3600) / 60.0))
        int seconds = totalSeconds % 60
        string minuteText = twoDigitTimePart(minutes)
        string secondText = twoDigitTimePart(seconds)
        result := totalHours > 0 ? str.tostring(totalHours) + ":" + minuteText + ":" + secondText : minuteText + ":" + secondText
    result
validCandleTimeframe(string selectedTf) =>
    float htfChartSeconds = timeframe.in_seconds()
    float selectedSeconds = timeframe.in_seconds(selectedTf)
    not na(htfChartSeconds) and not na(selectedSeconds) and selectedSeconds > htfChartSeconds
autoLaneTimeframe(int laneNumber) =>
    float htfAutoChartSeconds = timeframe.in_seconds()
    string result = ""
    if timeframe.isintraday
        if htfAutoChartSeconds <= 5.0 * 60.0
            result := laneNumber == 1 ? "30" : laneNumber == 2 ? "60" : laneNumber == 3 ? "240" : laneNumber == 4 ? "1D" : ""
        else if htfAutoChartSeconds <= 15.0 * 60.0
            result := laneNumber == 1 ? "30" : laneNumber == 2 ? "60" : laneNumber == 3 ? "240" : laneNumber == 4 ? "1D" : laneNumber == 5 ? "1W" : ""
        else if htfAutoChartSeconds < 60.0 * 60.0
            result := laneNumber == 1 ? "60" : laneNumber == 2 ? "240" : laneNumber == 3 ? "1D" : laneNumber == 4 ? "1W" : ""
        else if htfAutoChartSeconds <= 60.0 * 60.0
            result := laneNumber == 1 ? "240" : laneNumber == 2 ? "1D" : laneNumber == 3 ? "1W" : ""
        else if htfAutoChartSeconds < 4.0 * 60.0 * 60.0
            result := laneNumber == 1 ? "240" : laneNumber == 2 ? "1D" : laneNumber == 3 ? "1W" : laneNumber == 4 ? "1M" : ""
        else
            result := laneNumber == 1 ? "1D" : laneNumber == 2 ? "1W" : laneNumber == 3 ? "1M" : ""
    else if timeframe.isdaily
        result := laneNumber == 1 ? "1W" : laneNumber == 2 ? "1M" : laneNumber == 3 ? "3M" : ""
    else if timeframe.isweekly
        result := laneNumber == 1 ? "1M" : laneNumber == 2 ? "3M" : laneNumber == 3 ? "12M" : ""
    else if timeframe.ismonthly
        result := timeframe.multiplier < 3 ? (laneNumber == 1 ? "3M" : laneNumber == 2 ? "12M" : "") : timeframe.multiplier < 12 ? (laneNumber == 1 ? "12M" : "") : ""
    result
htfPrimaryRangeTimeframe() =>
    float seconds = timeframe.in_seconds()
    timeframe.isintraday ? (seconds <= 5.0 * 60.0 ? "240" : seconds <= 60.0 * 60.0 ? "1D" : "1W") :
     timeframe.isdaily ? "1M" :
     timeframe.isweekly ? "3M" :
     timeframe.ismonthly ? "3M" : "3M"
htfMacroRangeTimeframe() =>
    float seconds = timeframe.in_seconds()
    timeframe.isintraday ? (seconds <= 5.0 * 60.0 ? "1D" : seconds <= 60.0 * 60.0 ? "1W" : "1M") :
     timeframe.isdaily ? "3M" :
     timeframe.isweekly ? "12M" :
     timeframe.ismonthly ? "12M" : "12M"
adaptiveMidpoint(float highValue, float lowValue, float openValue, float closeValue) =>
    float result = (highValue + lowValue) / 2.0
    if highValue > 0 and lowValue > 0 and openValue > 0 and closeValue > 0
        float logHigh = math.log(highValue)
        float logLow = math.log(lowValue)
        float logOpen = math.log(openValue)
        float logClose = math.log(closeValue)
        float bodyMagnitude = math.abs(logClose - logOpen)
        float upperMagnitude = logHigh - math.max(logOpen, logClose)
        float lowerMagnitude = math.min(logOpen, logClose) - logLow
        float logResult = (logHigh + logLow) / 2.0
        if math.max(upperMagnitude, lowerMagnitude) > bodyMagnitude
            logResult := upperMagnitude > lowerMagnitude ? logHigh - upperMagnitude / 2.0 : logLow + lowerMagnitude / 2.0
        result := math.exp(logResult)
    result
barCenter(HtfBar candle) =>
    int((box.get_left(candle.bodyBox) + box.get_right(candle.bodyBox)) / 2.0)
deleteRenderedBar(HtfBar candle) =>
    if not na(candle.bodyBox)
        box.delete(candle.bodyBox)
    if not na(candle.upperWick)
        line.delete(candle.upperWick)
    if not na(candle.lowerWick)
        line.delete(candle.lowerWick)
baseBodyColor(int direction) =>
    direction == 1 ? bullBodyColor : direction == -1 ? bearBodyColor : dojiBodyColor
baseBorderColor(int direction) =>
    direction == 1 ? bullBorderColor : direction == -1 ? bearBorderColor : dojiBorderColor
baseWickColor(int direction) =>
    direction == 1 ? bullWickColor : direction == -1 ? bearWickColor : dojiWickColor
setCandleVerticalGeometry(HtfBar candle) =>
    int direction = candleDirection(candle.openPrice, candle.closePrice)
    float topValue = math.max(candle.openPrice, candle.closePrice)
    float bottomValue = math.min(candle.openPrice, candle.closePrice)
    if direction == 0
        float halfTick = math.max(syminfo.mintick * 0.5, math.abs(candle.closePrice) * 0.00000001)
        topValue := candle.closePrice + halfTick
        bottomValue := candle.closePrice - halfTick
    box.set_top(candle.bodyBox, topValue)
    box.set_bottom(candle.bodyBox, bottomValue)
    line.set_y1(candle.upperWick, candle.highPrice)
    line.set_y2(candle.upperWick, topValue)
    line.set_y1(candle.lowerWick, bottomValue)
    line.set_y2(candle.lowerWick, candle.lowPrice)
paintBaseCandle(HtfBar candle) =>
    int direction = candleDirection(candle.openPrice, candle.closePrice)
    setCandleVerticalGeometry(candle)
    box.set_bgcolor(candle.bodyBox, baseBodyColor(direction))
    box.set_border_color(candle.bodyBox, baseBorderColor(direction))
    line.set_color(candle.upperWick, baseWickColor(direction))
    line.set_color(candle.lowerWick, baseWickColor(direction))
method openLaneBar(HtfLane lane, int maximumBars) =>
    HtfBar candle = HtfBar.new()
    candle.openPrice := open
    candle.highPrice := high
    candle.lowPrice := low
    candle.closePrice := close
    candle.identity := bar_index
    float initialTop = math.max(open, close)
    float initialBottom = math.min(open, close)
    if open == close
        float halfTick = math.max(syminfo.mintick * 0.5, math.abs(close) * 0.00000001)
        initialTop := close + halfTick
        initialBottom := close - halfTick
    candle.bodyBox := box.new(
         left = bar_index,
         top = initialTop,
         right = bar_index + 1,
         bottom = initialBottom,
         xloc = xloc.bar_index,
         border_color = baseBorderColor(candleDirection(open, close)),
         border_width = 1,
         bgcolor = baseBodyColor(candleDirection(open, close)))
    candle.upperWick := line.new(
         x1 = bar_index,
         y1 = high,
         x2 = bar_index,
         y2 = initialTop,
         xloc = xloc.bar_index,
         color = baseWickColor(candleDirection(open, close)))
    candle.lowerWick := line.new(
         x1 = bar_index,
         y1 = initialBottom,
         x2 = bar_index,
         y2 = low,
         xloc = xloc.bar_index,
         color = baseWickColor(candleDirection(open, close)))
    array.unshift(lane.bars, candle)
    while array.size(lane.bars) > maximumBars
        HtfBar discarded = array.pop(lane.bars)
        deleteRenderedBar(discarded)
    lane
method updateLaneBar(HtfLane lane) =>
    if array.size(lane.bars) > 0
        HtfBar candle = array.get(lane.bars, 0)
        candle.highPrice := math.max(candle.highPrice, high)
        candle.lowPrice := math.min(candle.lowPrice, low)
        candle.closePrice := close
        array.set(lane.bars, 0, candle)
        paintBaseCandle(candle)
    lane
method ingestLane(
     HtfLane lane,
     bool periodChanged,
     int visibleBars) =>
    bool alreadyHasBars = array.size(lane.bars) > 0
    if periodChanged or not alreadyHasBars
        lane.openLaneBar(visibleBars)
    else
        lane.updateLaneBar()
    lane

method layoutLane(
     HtfLane lane,
     int startOffset,
     int reservedCount,
     int slotWidth,
     int bodyWidth,
     int gapAfterLane,
     string selectedTf) =>
    int availableBars = math.min(reservedCount, array.size(lane.bars))
    float highestDisplayed = na
    if availableBars > 0
        for index = 0 to availableBars - 1
            HtfBar candle = array.get(lane.bars, index)
            int positionInLane = reservedCount - 1 - index
            int leftX = bar_index + startOffset + positionInLane * slotWidth
            int rightX = leftX + bodyWidth
            int middleX = int((leftX + rightX) / 2.0)
            box.set_left(candle.bodyBox, leftX)
            box.set_right(candle.bodyBox, rightX)
            line.set_x1(candle.upperWick, middleX)
            line.set_x2(candle.upperWick, middleX)
            line.set_x1(candle.lowerWick, middleX)
            line.set_x2(candle.lowerWick, middleX)
            highestDisplayed := na(highestDisplayed) ? candle.highPrice : math.max(highestDisplayed, candle.highPrice)
    if showLaneLabels and availableBars > 0
        int labelX = bar_index + startOffset + int(((reservedCount - 1) * slotWidth + bodyWidth) / 2.0)
        string labelText = formattedTimeframe(selectedTf)
        if showLaneCountdown
            string countdownText = remainingTimeText(selectedTf)
            if str.length(countdownText) > 0
                labelText += " · " + countdownText
        if na(lane.timeframeLabel)
            lane.timeframeLabel := label.new(
                 x = labelX,
                 y = highestDisplayed,
                 text = labelText,
                 xloc = xloc.bar_index,
                 color = transparentColor(),
                 textcolor = laneLabelColor,
                 style = label.style_label_down,
                 size = textSize(laneLabelSize),
                 text_font_family = font.family_monospace)
        else
            label.set_xy(lane.timeframeLabel, labelX, highestDisplayed)
            label.set_text(lane.timeframeLabel, labelText)
            label.set_textcolor(lane.timeframeLabel, laneLabelColor)
            label.set_size(lane.timeframeLabel, textSize(laneLabelSize))
    else if not na(lane.timeframeLabel)
        label.delete(lane.timeframeLabel)
        lane.timeframeLabel := na
    startOffset + reservedCount * slotWidth + gapAfterLane
writeTemplateLine(
     array<line> pool,
     int index,
     int x1,
     float y1,
     int x2,
     float y2,
     color drawingColor,
     string drawingStyle) =>
    if index < array.size(pool)
        line existing = array.get(pool, index)
        line.set_xy1(existing, x1, y1)
        line.set_xy2(existing, x2, y2)
        line.set_color(existing, drawingColor)
        line.set_style(existing, drawingStyle)
    else
        line created = line.new(
             x1 = x1,
             y1 = y1,
             x2 = x2,
             y2 = y2,
             xloc = xloc.bar_index,
             color = drawingColor,
             width = 1,
             style = drawingStyle)
        array.push(pool, created)
trimLinePool(array<line> pool, int keepCount) =>
    while array.size(pool) > keepCount
        line.delete(array.pop(pool))

htfRangePrefix(string selectedTf) =>
    selectedTf == "240" ? "4H" : selectedTf == "1D" ? "D" : selectedTf == "1W" ? "W" : selectedTf == "1M" ? "M" : selectedTf == "3M" ? "3M" : formattedTimeframe(selectedTf)

method clearRangeLevels(HtfLane lane) =>
    while array.size(lane.rangeLines) > 0
        line.delete(array.pop(lane.rangeLines))
    while array.size(lane.rangeLabels) > 0
        label.delete(array.pop(lane.rangeLabels))
    lane

method syncRangeLevels(HtfLane lane, int visibleBars, string selectedTf, bool rangeLane) =>
    int count = math.min(visibleBars, array.size(lane.bars))
    if not showHtfRangeLevels or not rangeLane or count < 2
        lane.clearRangeLevels()
    else
        HtfBar previous = array.get(lane.bars, 1)
        float rangeSize = previous.highPrice - previous.lowPrice
        if na(rangeSize) or rangeSize <= 0
            lane.clearRangeLevels()
        else
            HtfBar oldestShown = array.get(lane.bars, count - 1)
            HtfBar newestShown = array.get(lane.bars, 0)
            int leftX = box.get_left(oldestShown.bodyBox)
            int rightX = box.get_right(newestShown.bodyBox) + 1
            int labelX = rightX + 1
            float level25 = previous.highPrice - rangeSize * 0.25
            float level50 = previous.highPrice - rangeSize * 0.50
            float level75 = previous.highPrice - rangeSize * 0.75
            array<float> prices = array.from(previous.highPrice, level25, level50, level75, previous.lowPrice)
            array<color> colors = array.from(htfRangeHighLowColor, htfRangeQuarterColor, htfRangeMidColor, htfRangeQuarterColor, htfRangeHighLowColor)
            string prefix = htfRangePrefix(selectedTf)
            array<string> captions = array.from("P" + prefix + "H", prefix + " 25%", prefix + " 50%", prefix + " 75%", "P" + prefix + "L")
            for i = 0 to 4
                float y = array.get(prices, i)
                color c = array.get(colors, i)
                int levelWidth = i == 0 or i == 4 or i == 2 ? 2 : 1
                if i < array.size(lane.rangeLines)
                    line ln = array.get(lane.rangeLines, i)
                    line.set_xy1(ln, leftX, y)
                    line.set_xy2(ln, rightX, y)
                    line.set_color(ln, c)
                    line.set_width(ln, levelWidth)
                    line.set_style(ln, line.style_solid)
                else
                    array.push(lane.rangeLines, line.new(leftX, y, rightX, y, xloc=xloc.bar_index, color=c, width=levelWidth))
                if i < array.size(lane.rangeLabels)
                    label lb = array.get(lane.rangeLabels, i)
                    label.set_xy(lb, labelX, y)
                    label.set_text(lb, array.get(captions, i))
                    label.set_textcolor(lb, c)
                    label.set_size(lb, size.tiny)
                else
                    array.push(lane.rangeLabels, label.new(labelX, y, array.get(captions, i), xloc=xloc.bar_index, style=label.style_label_left, color=transparentColor(), textcolor=c, size=size.tiny, text_font_family=font.family_monospace))
            while array.size(lane.rangeLines) > 5
                line.delete(array.pop(lane.rangeLines))
            while array.size(lane.rangeLabels) > 5
                label.delete(array.pop(lane.rangeLabels))
    lane

method syncTemplateDrawings(HtfLane lane, int visibleBars, int lineCap) =>
    int usedLines = 0
    int count = math.min(visibleBars, array.size(lane.bars))
    if count > 1 and showAdaptiveMidpoints
        for index = 1 to count - 1
            HtfBar older = array.get(lane.bars, index)
            HtfBar newer = array.get(lane.bars, index - 1)
            if usedLines < lineCap
                float midpoint = adaptiveMidpoint(older.highPrice, older.lowPrice, older.openPrice, older.closePrice)
                writeTemplateLine(lane.templateLines, usedLines, barCenter(older), midpoint, barCenter(newer), midpoint, templateGuideColor, line.style_dashed)
                usedLines += 1
    if count > 1 and showCloseBackSweeps
        for index = 0 to count - 2
            HtfBar current = array.get(lane.bars, index)
            HtfBar prior = array.get(lane.bars, index + 1)
            if current.highPrice > prior.highPrice and current.closePrice < prior.highPrice and usedLines < lineCap
                writeTemplateLine(lane.templateLines, usedLines, barCenter(prior), prior.highPrice, box.get_right(current.bodyBox), prior.highPrice, templateGuideColor, line.style_solid)
                usedLines += 1
            if current.lowPrice < prior.lowPrice and current.closePrice > prior.lowPrice and usedLines < lineCap
                writeTemplateLine(lane.templateLines, usedLines, barCenter(prior), prior.lowPrice, box.get_right(current.bodyBox), prior.lowPrice, templateGuideColor, line.style_solid)
                usedLines += 1
    trimLinePool(lane.templateLines, usedLines)
    0
string effectiveLane1Tf = autoLaneTimeframe(1)
string effectiveLane2Tf = autoLaneTimeframe(2)
string effectiveLane3Tf = autoLaneTimeframe(3)
string effectiveLane4Tf = autoLaneTimeframe(4)
string effectiveLane5Tf = autoLaneTimeframe(5)
bool effectiveLane1Enabled = x966ModuleHtf and str.length(effectiveLane1Tf) > 0
bool effectiveLane2Enabled = x966ModuleHtf and str.length(effectiveLane2Tf) > 0
bool effectiveLane3Enabled = x966ModuleHtf and str.length(effectiveLane3Tf) > 0
bool effectiveLane4Enabled = x966ModuleHtf and str.length(effectiveLane4Tf) > 0
bool effectiveLane5Enabled = x966ModuleHtf and str.length(effectiveLane5Tf) > 0
bool lane1TfValid = effectiveLane1Enabled and validCandleTimeframe(effectiveLane1Tf)
bool lane2TfValid = effectiveLane2Enabled and validCandleTimeframe(effectiveLane2Tf)
bool lane3TfValid = effectiveLane3Enabled and validCandleTimeframe(effectiveLane3Tf)
bool lane4TfValid = effectiveLane4Enabled and validCandleTimeframe(effectiveLane4Tf)
bool lane5TfValid = effectiveLane5Enabled and validCandleTimeframe(effectiveLane5Tf)
bool lane1Active = effectiveLane1Enabled and lane1TfValid
bool lane2Active = effectiveLane2Enabled and lane2TfValid
bool lane3Active = effectiveLane3Enabled and lane3TfValid
bool lane4Active = effectiveLane4Enabled and lane4TfValid
bool lane5Active = effectiveLane5Enabled and lane5TfValid
int activeLaneCount =
     (lane1Active ? 1 : 0) +
     (lane2Active ? 1 : 0) +
     (lane3Active ? 1 : 0) +
     (lane4Active ? 1 : 0) +
     (lane5Active ? 1 : 0)
int reservedCandleCount =
     (lane1Active ? lane1Count : 0) +
     (lane2Active ? lane2Count : 0) +
     (lane3Active ? lane3Count : 0) +
     (lane4Active ? lane4Count : 0) +
     (lane5Active ? lane5Count : 0)
int candleFutureLimit = math.max(80, futureDrawingLimit)
int desiredSlotWidth = requestedBodyWidth + requestedCandleGap
int minimumGapTotal = math.max(activeLaneCount - 1, 0)
int maximumBaseOffset = activeLaneCount > 0 ? math.max(1, candleFutureLimit - reservedCandleCount - minimumGapTotal) : candleFutureLimit
int effectiveBaseOffset = activeLaneCount > 0 ? math.max(25, math.min(requestedBaseOffset, maximumBaseOffset)) : requestedBaseOffset
int layoutRoom = candleFutureLimit - effectiveBaseOffset
int effectiveSetGap = requestedSetGap
if activeLaneCount > 1
    int maximumSetGap = math.max(1, int(math.floor((layoutRoom - reservedCandleCount) / (activeLaneCount - 1))))
    effectiveSetGap := math.min(requestedSetGap, maximumSetGap)
int candleRoom = layoutRoom - minimumGapTotal * effectiveSetGap
int maximumSlotWidth = reservedCandleCount > 0 ? math.max(1, int(math.floor(candleRoom / reservedCandleCount))) : desiredSlotWidth
int effectiveSlotWidth = math.min(desiredSlotWidth, maximumSlotWidth)
int effectiveBodyWidth = math.min(requestedBodyWidth, effectiveSlotWidth)
int templateLinesPerLane = activeLaneCount > 0 ? math.max(1, int(math.floor(TEMPLATE_LINE_BUDGET / activeLaneCount))) : TEMPLATE_LINE_BUDGET
bool newLane1Bar = false
bool newLane2Bar = false
bool newLane3Bar = false
bool newLane4Bar = false
bool newLane5Bar = false
if lane1Active
    newLane1Bar := ta.change(time(effectiveLane1Tf)) != 0
if lane2Active
    newLane2Bar := ta.change(time(effectiveLane2Tf)) != 0
if lane3Active
    newLane3Bar := ta.change(time(effectiveLane3Tf)) != 0
if lane4Active
    newLane4Bar := ta.change(time(effectiveLane4Tf)) != 0
if lane5Active
    newLane5Bar := ta.change(time(effectiveLane5Tf)) != 0
if lane1Active
    lane1.ingestLane(newLane1Bar, lane1Count)
if lane2Active
    lane2.ingestLane(newLane2Bar, lane2Count)
if lane3Active
    lane3.ingestLane(newLane3Bar, lane3Count)
if lane4Active
    lane4.ingestLane(newLane4Bar, lane4Count)
if lane5Active
    lane5.ingestLane(newLane5Bar, lane5Count)
string htfPrimaryRangeTf = htfPrimaryRangeTimeframe()
string htfMacroRangeTf = htfMacroRangeTimeframe()
if barstate.islast or barstate.isrealtime
    int laneCursor = effectiveBaseOffset
    if lane1Active
        laneCursor := lane1.layoutLane(laneCursor, lane1Count, effectiveSlotWidth, effectiveBodyWidth, effectiveSetGap, effectiveLane1Tf)
        lane1.syncTemplateDrawings(lane1Count, templateLinesPerLane)
        lane1.syncRangeLevels(lane1Count, effectiveLane1Tf, effectiveLane1Tf == htfPrimaryRangeTf or effectiveLane1Tf == htfMacroRangeTf)
    else
        lane1.clearRangeLevels()
    if lane2Active
        laneCursor := lane2.layoutLane(laneCursor, lane2Count, effectiveSlotWidth, effectiveBodyWidth, effectiveSetGap, effectiveLane2Tf)
        lane2.syncTemplateDrawings(lane2Count, templateLinesPerLane)
        lane2.syncRangeLevels(lane2Count, effectiveLane2Tf, effectiveLane2Tf == htfPrimaryRangeTf or effectiveLane2Tf == htfMacroRangeTf)
    else
        lane2.clearRangeLevels()
    if lane3Active
        laneCursor := lane3.layoutLane(laneCursor, lane3Count, effectiveSlotWidth, effectiveBodyWidth, effectiveSetGap, effectiveLane3Tf)
        lane3.syncTemplateDrawings(lane3Count, templateLinesPerLane)
        lane3.syncRangeLevels(lane3Count, effectiveLane3Tf, effectiveLane3Tf == htfPrimaryRangeTf or effectiveLane3Tf == htfMacroRangeTf)
    else
        lane3.clearRangeLevels()
    if lane4Active
        laneCursor := lane4.layoutLane(laneCursor, lane4Count, effectiveSlotWidth, effectiveBodyWidth, effectiveSetGap, effectiveLane4Tf)
        lane4.syncTemplateDrawings(lane4Count, templateLinesPerLane)
        lane4.syncRangeLevels(lane4Count, effectiveLane4Tf, effectiveLane4Tf == htfPrimaryRangeTf or effectiveLane4Tf == htfMacroRangeTf)
    else
        lane4.clearRangeLevels()
    if lane5Active
        laneCursor := lane5.layoutLane(laneCursor, lane5Count, effectiveSlotWidth, effectiveBodyWidth, effectiveSetGap, effectiveLane5Tf)
        lane5.syncTemplateDrawings(lane5Count, templateLinesPerLane)
        lane5.syncRangeLevels(lane5Count, effectiveLane5Tf, effectiveLane5Tf == htfPrimaryRangeTf or effectiveLane5Tf == htfMacroRangeTf)
    else
        lane5.clearRangeLevels()
max_bars_back(time, 5000)
groupSymbols = "Symbols"
bool autoDetectSmt = input.bool(true, "Auto-Detect Pair (Crypto: ETH/BTC · FX: EUR/GBP · Futures: MES)", group=groupSymbols, tooltip="When enabled, automatically matches Bitcoin with Ethereum, EUR with GBP, and Indices with MES. Uncheck to force manual symbols.")
comparisonSymbol1 = input.symbol("CME_MINI:MES1!", "Comparison Symbol 1 (Manual)", group=groupSymbols)
comparisonSymbol2 = input.symbol("COMEX_MINI:SIL1!", "Comparison Symbol 2", group=groupSymbols)

string autoCrypto1 = str.contains(str.upper(syminfo.ticker), "ETH") ? "BINANCE:BTCUSDT" : "BINANCE:ETHUSDT"
string autoForex1  = str.contains(str.upper(syminfo.ticker), "GBP") ? "FX:EURUSD" : "FX:GBPUSD"
string effectiveSymbol1 = autoDetectSmt ?
     (syminfo.type == "crypto" ? autoCrypto1 :
      syminfo.type == "forex"  ? autoForex1 : comparisonSymbol1) :
     comparisonSymbol1
groupTF = "Multi-Timeframe SMT"
const string tfW = "1W"
const string tfD = "1D"
const string tf4H = "240"
const string tf1H = "60"
const string tf30 = "30"
const string tf15 = "15"
const string tf5 = "5"
const string tf1 = "1"
groupLogic = "SMT Logic"
const int maxPerDirection = 2
const int dedupeTicks = 2
const bool requireCloseBack = false
bool persistAfterClose = x966ModuleSmt
bool deleteBroken = x966ModuleSmt
groupLookback = "Per-TF Lookbacks"
const int lookbackW = 14
const int lookbackD = 10
const int lookback4H = 14
const int lookback1H = 6
const int lookback30 = 4
const int lookback15 = 4
const int lookback5 = 4
const int lookback1 = 6
groupLTF = "LTF Clutter Control"
bool enableLtfCaps = x966ModuleSmt
const int maxM1PerDirection = 2
const int maxM5PerDirection = 2
const int maxFastLtfTotal = 6
const int maxLtf15Total = 8
groupRetention = "SMT Retention / Cleanup"
bool cleanupInvalidLive = x966ModuleSmt
bool enablePerTfRetention = x966ModuleSmt
const bool enableFractalCleanup = true
const bool keepChildIfNewer = true
const bool keepChildIfExtreme = true
const bool requireBothChildRules = true
const int childExtremeTicks = 0
const int maxKeepFastPerTfDir = 2
const int maxKeepMidPerTfDir = 2
const int maxKeepHourPerTfDir = 2
const int maxKeepHtfPerTfDir = 2
const int maxKeepDWPerTfDir = 2
groupStyle = "Style"
const int X966_SMT_SAFE_DRAWING_CAP = 440
bearColor      = input.color(color.rgb(228, 68, 72), "Bearish Line", group=groupStyle)
bullColor      = input.color(color.rgb(99, 154, 242), "Bullish Line", group=groupStyle)
smtOpacity     = input.int(45, "SMT Line Opacity %", minval=0, maxval=100, group=groupStyle, tooltip="100 = fully visible / max opacity. 0 = invisible.")
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle)
lineWidth      = input.int(1, "Line Width", minval=1, maxval=5, group=groupStyle)
const int maxIndexBack = 4500
labelTextColor = input.color(color.rgb(74, 74, 74), "Label Text", group=groupStyle)
labelBgColor   = input.color(color.new(color.rgb(54, 58, 69), 100), "Label Background", group=groupStyle)
maxDrawings    = input.int(300, "Max SMT Drawings To Keep", minval=20, maxval=X966_SMT_SAFE_DRAWING_CAP, group=groupStyle, tooltip="The 440-drawing safety ceiling reserves line and label capacity so tracked SMT pairs cannot be silently garbage-collected.")
groupLabelSizes = "Label Sizes By Timeframe"
sizeFastTF   = input.string("Tiny", "m1–m5 Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupLabelSizes)
sizeMidTF    = input.string("Tiny", "m6–m15 Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupLabelSizes)
sizeNormalTF = input.string("Small", "m16–1hr Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupLabelSizes)
sizeHTFTF    = input.string("Small", ">1hr Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupLabelSizes)
f_lineStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid
f_labelSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.tiny
f_tfSizeString(string tf) =>
    int sec = timeframe.in_seconds(tf)
    string out = sizeHTFTF
    if sec <= 5 * 60
        out := sizeFastTF
    else if sec <= 15 * 60
        out := sizeMidTF
    else if sec <= 60 * 60
        out := sizeNormalTF
    else
        out := sizeHTFTF
    out
f_shortSymbol(string s) =>
    string out = s
    string[] parts = str.split(s, ":")
    if array.size(parts) > 1
        out := array.get(parts, array.size(parts) - 1)
    out := str.replace_all(out, "1!", "")
    out := str.replace_all(out, "2!", "")
    out
f_logoSymbol(string s) =>
    string out = str.upper(f_shortSymbol(s))
    if out == "MES" or out == "ES"
        out := "es"
    else if out == "MNQ" or out == "NQ"
        out := "nq"
    else if out == "MYM" or out == "YM"
        out := "ym"
    else if out == "M2K" or out == "RTY"
        out := "rty"
    else if out == "MGC" or out == "GC"
        out := "gc"
    else if out == "MSI" or out == "SI"
        out := "si"
    else if out == "MCL" or out == "CL"
        out := "cl"
    else
        out := str.lower(out)
    out
f_tfLogo(string tf) =>
    int sec = timeframe.in_seconds(tf)
    string out = tf
    if sec < 60
        out := str.tostring(sec) + "s"
    else if sec < 3600
        out := "m" + str.tostring(int(sec / 60))
    else if sec < 86400
        out := str.tostring(int(sec / 3600)) + "hr"
    else if sec == 86400
        out := "1d"
    else if sec == 604800
        out := "1w"
    else
        out := str.lower(tf)
    out
f_labelLogo(string tf, string suffix) =>
    f_tfLogo(tf) + "/" + suffix
f_compSuffix(bool c1, bool c2) =>
    string out = ""
    if c1
        out := f_logoSymbol(effectiveSymbol1)
    if c2
        out := str.length(out) > 0 ? out + "+" + f_logoSymbol(comparisonSymbol2) : f_logoSymbol(comparisonSymbol2)
    out
f_enabledCompSuffix() =>
    string out = ""
    if useComparison1
        out := f_logoSymbol(effectiveSymbol1)
    if useComparison2
        out := str.length(out) > 0 ? out + "+" + f_logoSymbol(comparisonSymbol2) : f_logoSymbol(comparisonSymbol2)
    out
f_levelAlreadyUsed(float[] levels, float level, float tolerance) =>
    bool used = false
    if array.size(levels) > 0 and tolerance > 0
        for i = 0 to array.size(levels) - 1
            if math.abs(array.get(levels, i) - level) <= tolerance
                used := true
                break
    used
f_endpointAlreadyUsed(int[] xs, float[] ys, int x, float y, float tolerance) =>
    bool used = false
    int n = math.min(array.size(xs), array.size(ys))
    if n > 0
        for i = 0 to n - 1
            bool sameX = array.get(xs, i) == x
            bool sameY = math.abs(array.get(ys, i) - y) <= tolerance
            if sameX and sameY
                used := true
                break
    used
f_useIndexX(int x1Idx) =>
    int dist = not na(x1Idx) ? bar_index - x1Idx : na
    not na(dist) and dist >= 0 and dist <= math.min(maxIndexBack, 4900)
f_getComparisonTicker(string sym) =>
    ticker.modify(ticker.inherit(syminfo.tickerid, sym), backadjustment=backadjustment.on)
type SMTDraw
    string key
    string tf
    int    tfSec
    int    dir
    int    refStart
    int    curStart
    int    lastSeenBar
    float  anchor
    int    x1Time
    int    x2Time
    int    x1Idx
    int    x2Idx
    float  y1
    float  y2
    bool   useIndexX
    line   ln
    label  lb
var SMTDraw[] smtEvents = array.new<SMTDraw>(0)
f_findEvent(string key) =>
    int idx = -1
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.key == key
                idx := i
                break
    idx
f_deleteEventAt(int idx) =>
    if idx >= 0 and idx < array.size(smtEvents)
        SMTDraw ev = array.get(smtEvents, idx)
        if not na(ev.ln)
            line.delete(ev.ln)
        if not na(ev.lb)
            label.delete(ev.lb)
        array.remove(smtEvents, idx)
f_deleteEventByKey(string key) =>
    int idx = f_findEvent(key)
    if idx != -1
        f_deleteEventAt(idx)
f_deleteEventsByTFStart(string tf, int curStart) =>
    if array.size(smtEvents) > 0
        for i = array.size(smtEvents) - 1 to 0
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tf == tf and ev.curStart == curStart
                f_deleteEventAt(i)
f_deleteAllEventsByTF(string tf) =>
    if array.size(smtEvents) > 0
        for i = array.size(smtEvents) - 1 to 0
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tf == tf
                f_deleteEventAt(i)
f_deleteSameEndpointEvents(string tf, int curStart, int dir, int x2Time, float y2, float tolerance, string keepKey) =>
    if array.size(smtEvents) > 0
        for i = array.size(smtEvents) - 1 to 0
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tf == tf and ev.curStart == curStart and ev.dir == dir and ev.key != keepKey
                bool sameEndpoint = ev.x2Time == x2Time and math.abs(ev.y2 - y2) <= tolerance
                if sameEndpoint
                    f_deleteEventAt(i)
f_deleteSameReferenceEvents(string tf, int dir, int x1Time, float y1, float tolerance, string keepKey) =>
    bool protectDailyWeekly = timeframe.in_seconds(tf) >= 24 * 60 * 60
    if not protectDailyWeekly and array.size(smtEvents) > 0
        for i = array.size(smtEvents) - 1 to 0
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tf == tf and ev.dir == dir and ev.key != keepKey
                bool sameReference = ev.x1Time == x1Time and math.abs(ev.y1 - y1) <= tolerance
                if sameReference
                    f_deleteEventAt(i)
f_childMoreExtreme(int dir, float childY2, float parentY2) =>
    float buf = childExtremeTicks * syminfo.mintick
    dir == -1 ? childY2 > parentY2 + buf : childY2 < parentY2 - buf
f_childUsefulAgainstParent(int dir, int childX2Time, float childY2, int parentX2Time, float parentY2) =>
    bool rawNewer = childX2Time > parentX2Time
    bool rawExtreme = f_childMoreExtreme(dir, childY2, parentY2)
    bool newerPass = not keepChildIfNewer or rawNewer
    bool extremePass = not keepChildIfExtreme or rawExtreme
    bool anyRuleEnabled = keepChildIfNewer or keepChildIfExtreme
    bool eitherPass = (keepChildIfNewer and rawNewer) or (keepChildIfExtreme and rawExtreme)
    bool bothPass = newerPass and extremePass
    anyRuleEnabled and (requireBothChildRules ? bothPass : eitherPass)
f_childInsideParent(SMTDraw parent, int childX1Time, int childX2Time) =>
    int parentRefEnd = parent.refStart + parent.tfSec * 1000
    int parentCurEnd = parent.curStart + parent.tfSec * 1000
    bool refInside = childX1Time >= parent.refStart and childX1Time < parentRefEnd
    bool curInside = childX2Time >= parent.curStart and childX2Time < parentCurEnd
    refInside and curInside
f_childInsideHigherWindow(int higherTfSec, int higherRefStart, int higherCurStart, int childX1Time, int childX2Time) =>
    int higherRefEnd = higherRefStart + higherTfSec * 1000
    int higherCurEnd = higherCurStart + higherTfSec * 1000
    bool refInside = childX1Time >= higherRefStart and childX1Time < higherRefEnd
    bool curInside = childX2Time >= higherCurStart and childX2Time < higherCurEnd
    refInside and curInside
f_isSuppressedByHigherTF(int dir, int tfSec, int x1Time, float y1, int x2Time, float y2, float tolerance) =>
    bool suppressed = false
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.dir == dir and ev.tfSec > tfSec
                bool sameEndpoint = ev.x2Time == x2Time and math.abs(ev.y2 - y2) <= tolerance
                bool sameReference = ev.x1Time == x1Time and math.abs(ev.y1 - y1) <= tolerance
                bool useful = f_childUsefulAgainstParent(dir, x2Time, y2, ev.x2Time, ev.y2)
                bool endpointDuplicate = sameEndpoint
                bool referenceDuplicate = sameReference and not useful
                bool nestedDuplicate = false
                if enableFractalCleanup and tfSec <= 60 * 60
                    bool nested = f_childInsideParent(ev, x1Time, x2Time)
                    nestedDuplicate := nested and not useful
                if endpointDuplicate or referenceDuplicate or nestedDuplicate
                    suppressed := true
                    break
    suppressed
f_deleteLowerTFEventsCoveredByHigher(int tfSec, int dir, int refStart, int curStart, int x1Time, float y1, int x2Time, float y2, float tolerance, string keepKey) =>
    if array.size(smtEvents) > 0
        for i = array.size(smtEvents) - 1 to 0
            SMTDraw ev = array.get(smtEvents, i)
            if ev.key != keepKey and ev.dir == dir and ev.tfSec < tfSec
                bool sameEndpoint = ev.x2Time == x2Time and math.abs(ev.y2 - y2) <= tolerance
                bool sameReference = ev.x1Time == x1Time and math.abs(ev.y1 - y1) <= tolerance
                bool useful = f_childUsefulAgainstParent(dir, ev.x2Time, ev.y2, x2Time, y2)
                bool endpointDuplicate = sameEndpoint
                bool referenceDuplicate = sameReference and not useful
                bool nestedDuplicate = false
                if enableFractalCleanup and ev.tfSec <= 60 * 60
                    bool nested = f_childInsideHigherWindow(tfSec, refStart, curStart, ev.x1Time, ev.x2Time)
                    nestedDuplicate := nested and not useful
                if endpointDuplicate or referenceDuplicate or nestedDuplicate
                    f_deleteEventAt(i)
f_prepareDrawingPair() =>
    while array.size(smtEvents) >= maxDrawings
        f_deleteEventAt(array.size(smtEvents) - 1)
f_countBucket(int minSecExclusive, int maxSec, int dir) =>
    int count = 0
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tfSec > minSecExclusive and ev.tfSec <= maxSec and ev.dir == dir
                count += 1
    count
f_deleteOldestBucket(int minSecExclusive, int maxSec, int dir) =>
    int oldestIdx = -1
    int oldestTime = na
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tfSec > minSecExclusive and ev.tfSec <= maxSec and ev.dir == dir
                if oldestIdx == -1 or ev.x2Time < oldestTime
                    oldestIdx := i
                    oldestTime := ev.x2Time
    if oldestIdx != -1
        f_deleteEventAt(oldestIdx)
f_enforceBucketCap(int minSecExclusive, int maxSec, int dir, int cap) =>
    int guard = 0
    while f_countBucket(minSecExclusive, maxSec, dir) > cap and guard < 100
        f_deleteOldestBucket(minSecExclusive, maxSec, dir)
        guard += 1
f_countFastLtfTotal() =>
    int count = 0
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tfSec <= 5 * 60
                count += 1
    count
f_deleteOldestFastLtf() =>
    int oldestIdx = -1
    int oldestTime = na
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tfSec <= 5 * 60
                if oldestIdx == -1 or ev.x2Time < oldestTime
                    oldestIdx := i
                    oldestTime := ev.x2Time
    if oldestIdx != -1
        f_deleteEventAt(oldestIdx)
f_countLtfThrough(int maxSec) =>
    int count = 0
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tfSec <= maxSec
                count += 1
    count
f_deleteOldestLtfThrough(int maxSec) =>
    int oldestIdx = -1
    int oldestTime = na
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tfSec <= maxSec
                if oldestIdx == -1 or ev.x2Time < oldestTime
                    oldestIdx := i
                    oldestTime := ev.x2Time
    if oldestIdx != -1
        f_deleteEventAt(oldestIdx)
f_countExactTFDirection(string tf, int dir) =>
    int count = 0
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tf == tf and ev.dir == dir
                count += 1
    count
f_deleteOldestExactTFDirection(string tf, int dir) =>
    int oldestIdx = -1
    int oldestTime = na
    if array.size(smtEvents) > 0
        for i = 0 to array.size(smtEvents) - 1
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tf == tf and ev.dir == dir
                if oldestIdx == -1 or ev.x2Time < oldestTime
                    oldestIdx := i
                    oldestTime := ev.x2Time
    if oldestIdx != -1
        f_deleteEventAt(oldestIdx)
f_retentionCapForSec(int tfSec) =>
    int cap = maxKeepHtfPerTfDir
    if tfSec <= 5 * 60
        cap := maxKeepFastPerTfDir
    else if tfSec <= 15 * 60
        cap := maxKeepMidPerTfDir
    else if tfSec <= 60 * 60
        cap := maxKeepHourPerTfDir
    else if tfSec >= 24 * 60 * 60
        cap := maxKeepDWPerTfDir
    else
        cap := maxKeepHtfPerTfDir
    cap
f_enforceExactTFRetention(string tf) =>
    bool changed = false
    if enablePerTfRetention
        int tfSec = timeframe.in_seconds(tf)
        int cap = f_retentionCapForSec(tfSec)
        int guardBear = 0
        while f_countExactTFDirection(tf, -1) > cap and guardBear < 100
            f_deleteOldestExactTFDirection(tf, -1)
            guardBear += 1
            changed := true
        int guardBull = 0
        while f_countExactTFDirection(tf, 1) > cap and guardBull < 100
            f_deleteOldestExactTFDirection(tf, 1)
            guardBull += 1
            changed := true
    changed
f_enforceLtfCaps() =>
    if enableLtfCaps
        f_enforceBucketCap(0, 60, -1, maxM1PerDirection)
        f_enforceBucketCap(0, 60, 1, maxM1PerDirection)
        f_enforceBucketCap(60, 5 * 60, -1, maxM5PerDirection)
        f_enforceBucketCap(60, 5 * 60, 1, maxM5PerDirection)
        if maxFastLtfTotal > 0
            int guardFast = 0
            while f_countFastLtfTotal() > maxFastLtfTotal and guardFast < 100
                f_deleteOldestFastLtf()
                guardFast += 1
        if maxLtf15Total > 0
            int guard15 = 0
            while f_countLtfThrough(15 * 60) > maxLtf15Total and guard15 < 100
                f_deleteOldestLtfThrough(15 * 60)
                guard15 += 1
f_makeLine(bool useIndexX, int x1Time, int x1Idx, float y1, int x2Time, int x2Idx, float y2, color lnColor) =>
    line ln = na
    if useIndexX
        ln := line.new(x1Idx, y1, x2Idx, y2, xloc=xloc.bar_index, color=lnColor, width=lineWidth, style=f_lineStyle(lineStyleInput))
    else
        ln := line.new(x1Time, y1, x2Time, y2, xloc=xloc.bar_time, color=lnColor, width=lineWidth, style=f_lineStyle(lineStyleInput))
    ln
f_makeLabel(bool useIndexX, int x1Time, int x1Idx, float y1, int x2Time, int x2Idx, float y2, int dir, string txt, string tip, string labelSizeStr) =>
    int labelX = useIndexX ? int(math.round((x1Idx + x2Idx) / 2.0)) : int(math.round((x1Time + x2Time) / 2.0))
    float midY = (y1 + y2) / 2.0
    float off = math.max(syminfo.mintick * 10.0, math.abs(y2 - y1) * 0.35)
    float labelY = dir == -1 ? midY + off : midY - off
    label_style = dir == -1 ? label.style_label_down : label.style_label_up
    label lb = na
    if useIndexX
        lb := label.new(labelX, labelY, txt, xloc=xloc.bar_index, color=labelBgColor, textcolor=labelTextColor, style=label_style, size=f_labelSize(labelSizeStr), text_font_family=font.family_monospace)
    else
        lb := label.new(labelX, labelY, txt, xloc=xloc.bar_time, color=labelBgColor, textcolor=labelTextColor, style=label_style, size=f_labelSize(labelSizeStr), text_font_family=font.family_monospace)
    label.set_tooltip(lb, tip)
    lb
f_updateLabel(label lb, bool useIndexX, int x1Time, int x1Idx, float y1, int x2Time, int x2Idx, float y2, int dir, string txt, string tip, string labelSizeStr) =>
    int labelX = useIndexX ? int(math.round((x1Idx + x2Idx) / 2.0)) : int(math.round((x1Time + x2Time) / 2.0))
    float midY = (y1 + y2) / 2.0
    float off = math.max(syminfo.mintick * 10.0, math.abs(y2 - y1) * 0.35)
    float labelY = dir == -1 ? midY + off : midY - off
    label_style = dir == -1 ? label.style_label_down : label.style_label_up
    label.set_xy(lb, labelX, labelY)
    label.set_text(lb, txt)
    label.set_textcolor(lb, labelTextColor)
    label.set_color(lb, labelBgColor)
    label.set_style(lb, label_style)
    label.set_size(lb, f_labelSize(labelSizeStr))
    label.set_tooltip(lb, tip)
f_drawOrUpdate(string key, string tf, int tfSec, int dir, int refStart, int curStart, int x1Time, int x1Idx, float y1, int x2Time, int x2Idx, float y2, float anchor, string txt, string tip, float endpointTol, string labelSizeStr) =>
    bool drawn = false
    if f_isSuppressedByHigherTF(dir, tfSec, x1Time, y1, x2Time, y2, endpointTol)
        f_deleteEventByKey(key)
        drawn := false
    else
        f_deleteSameEndpointEvents(tf, curStart, dir, x2Time, y2, endpointTol, key)
        f_deleteSameReferenceEvents(tf, dir, x1Time, y1, endpointTol, key)
        int transp = 100 - smtOpacity
        color lnColor = dir == -1 ? color.new(bearColor, transp) : color.new(bullColor, transp)
        bool useIndexX = f_useIndexX(x1Idx)
        int idx = f_findEvent(key)
        if idx == -1
            f_prepareDrawingPair()
            line ln = f_makeLine(useIndexX, x1Time, x1Idx, y1, x2Time, x2Idx, y2, lnColor)
            label lb = f_makeLabel(useIndexX, x1Time, x1Idx, y1, x2Time, x2Idx, y2, dir, txt, tip, labelSizeStr)
            SMTDraw ev = SMTDraw.new()
            ev.key := key
            ev.tf := tf
            ev.tfSec := tfSec
            ev.dir := dir
            ev.refStart := refStart
            ev.curStart := curStart
            ev.lastSeenBar := bar_index
            ev.anchor := anchor
            ev.x1Time := x1Time
            ev.x2Time := x2Time
            ev.x1Idx := x1Idx
            ev.x2Idx := x2Idx
            ev.y1 := y1
            ev.y2 := y2
            ev.useIndexX := useIndexX
            ev.ln := ln
            ev.lb := lb
            array.unshift(smtEvents, ev)
        else
            SMTDraw ev = array.get(smtEvents, idx)
            bool recreate = ev.useIndexX != useIndexX or na(ev.ln) or na(ev.lb)
            if recreate
                if not na(ev.ln)
                    line.delete(ev.ln)
                if not na(ev.lb)
                    label.delete(ev.lb)
                ev.ln := f_makeLine(useIndexX, x1Time, x1Idx, y1, x2Time, x2Idx, y2, lnColor)
                ev.lb := f_makeLabel(useIndexX, x1Time, x1Idx, y1, x2Time, x2Idx, y2, dir, txt, tip, labelSizeStr)
                ev.useIndexX := useIndexX
            else
                line.set_xy1(ev.ln, useIndexX ? x1Idx : x1Time, y1)
                line.set_xy2(ev.ln, useIndexX ? x2Idx : x2Time, y2)
                line.set_color(ev.ln, lnColor)
                line.set_width(ev.ln, lineWidth)
                line.set_style(ev.ln, f_lineStyle(lineStyleInput))
                f_updateLabel(ev.lb, useIndexX, x1Time, x1Idx, y1, x2Time, x2Idx, y2, dir, txt, tip, labelSizeStr)
            ev.lastSeenBar := bar_index
            ev.anchor := anchor
            ev.refStart := refStart
            ev.curStart := curStart
            ev.x1Time := x1Time
            ev.x2Time := x2Time
            ev.x1Idx := x1Idx
            ev.x2Idx := x2Idx
            ev.y1 := y1
            ev.y2 := y2
            array.set(smtEvents, idx, ev)
        f_deleteLowerTFEventsCoveredByHigher(tfSec, dir, refStart, curStart, x1Time, y1, x2Time, y2, endpointTol, key)
        drawn := true
    drawn
f_deleteUnseenCurrentTF(string tf, int curStart) =>
    if cleanupInvalidLive and array.size(smtEvents) > 0
        for i = array.size(smtEvents) - 1 to 0
            SMTDraw ev = array.get(smtEvents, i)
            if ev.tf == tf and ev.curStart == curStart and ev.lastSeenBar != bar_index
                f_deleteEventAt(i)
f_purgeBroken() =>
    if deleteBroken and array.size(smtEvents) > 0
        for i = array.size(smtEvents) - 1 to 0
            SMTDraw ev = array.get(smtEvents, i)
            bool laterBar = bar_index > ev.lastSeenBar
            bool brokeHigh = ev.dir == -1 and high > ev.anchor
            bool brokeLow = ev.dir == 1 and low < ev.anchor
            bool broken = laterBar and (brokeHigh or brokeLow)
            if broken
                f_deleteEventAt(i)
comparisonTicker1 = f_getComparisonTicker(effectiveSymbol1)
comparisonTicker2 = f_getComparisonTicker(comparisonSymbol2)
smtRequestChartComparison(string requestedSymbol) =>
    request.security(requestedSymbol, timeframe.period, [time, time_close, high, low],
         gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
int cmp1TimeChart = na
int cmp1CloseTimeChart = na
float cmp1HighRaw = na
float cmp1LowRaw = na
int cmp2TimeChart = na
int cmp2CloseTimeChart = na
float cmp2HighRaw = na
float cmp2LowRaw = na
if useComparison1
    [cmp1TimeReq, cmp1CloseTimeReq, cmp1HighReq, cmp1LowReq] = smtRequestChartComparison(comparisonTicker1)
    cmp1TimeChart := cmp1TimeReq
    cmp1CloseTimeChart := cmp1CloseTimeReq
    cmp1HighRaw := cmp1HighReq
    cmp1LowRaw := cmp1LowReq
if useComparison2
    [cmp2TimeReq, cmp2CloseTimeReq, cmp2HighReq, cmp2LowReq] = smtRequestChartComparison(comparisonTicker2)
    cmp2TimeChart := cmp2TimeReq
    cmp2CloseTimeChart := cmp2CloseTimeReq
    cmp2HighRaw := cmp2HighReq
    cmp2LowRaw := cmp2LowReq
bool cmp1IntervalAligned = not na(cmp1TimeChart) and not na(cmp1CloseTimeChart) and cmp1TimeChart == time and cmp1CloseTimeChart == time_close
bool cmp2IntervalAligned = not na(cmp2TimeChart) and not na(cmp2CloseTimeChart) and cmp2TimeChart == time and cmp2CloseTimeChart == time_close
float cmp1HighChart = useComparison1 and cmp1IntervalAligned and not na(cmp1HighRaw) and not na(cmp1LowRaw) ? cmp1HighRaw : na
float cmp1LowChart = useComparison1 and cmp1IntervalAligned and not na(cmp1HighRaw) and not na(cmp1LowRaw) ? cmp1LowRaw : na
float cmp2HighChart = useComparison2 and cmp2IntervalAligned and not na(cmp2HighRaw) and not na(cmp2LowRaw) ? cmp2HighRaw : na
float cmp2LowChart = useComparison2 and cmp2IntervalAligned and not na(cmp2HighRaw) and not na(cmp2LowRaw) ? cmp2LowRaw : na
float chartDPrevH = na
float chartDPrevL = na
float chartWPrevH = na
float chartWPrevL = na
float cmp1DPrevHRaw = na
float cmp1DPrevLRaw = na
float cmp1WPrevHRaw = na
float cmp1WPrevLRaw = na
float cmp2DPrevHRaw = na
float cmp2DPrevLRaw = na
float cmp2WPrevHRaw = na
float cmp2WPrevLRaw = na
float cmp1_4HPrevHRaw = na
float cmp1_4HPrevLRaw = na
float cmp1_1HPrevHRaw = na
float cmp1_1HPrevLRaw = na
float cmp1_30PrevHRaw = na
float cmp1_30PrevLRaw = na
float cmp1_15PrevHRaw = na
float cmp1_15PrevLRaw = na
float cmp1_5PrevHRaw = na
float cmp1_5PrevLRaw = na
float cmp1_1PrevHRaw = na
float cmp1_1PrevLRaw = na
float cmp2_4HPrevHRaw = na
float cmp2_4HPrevLRaw = na
float cmp2_1HPrevHRaw = na
float cmp2_1HPrevLRaw = na
float cmp2_30PrevHRaw = na
float cmp2_30PrevLRaw = na
float cmp2_15PrevHRaw = na
float cmp2_15PrevLRaw = na
float cmp2_5PrevHRaw = na
float cmp2_5PrevLRaw = na
float cmp2_1PrevHRaw = na
float cmp2_1PrevLRaw = na
smtRequestPreviousRange(string requestedSymbol, string requestedTf) =>
    request.security(requestedSymbol, requestedTf, [high[1], low[1]],
         gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
var array<string> x966SmtRequestTfs = array.from(tfD, tfW, tf4H, tf1H, tf30, tf15, tf5, tf1)
var array<bool> x966SmtRequestEnabled = array.from(tfD_on, tfW_on, tf4H_on, tf1H_on, tf30_on, tf15_on, tf5_on, tf1_on)
for requestIndex = 0 to 1
    if x966SmtRequestEnabled.get(requestIndex)
        string requestedTf = x966SmtRequestTfs.get(requestIndex)
        [vH, vL] = smtRequestPreviousRange(syminfo.tickerid, requestedTf)
        if requestIndex == 0
            chartDPrevH := vH
            chartDPrevL := vL
        else
            chartWPrevH := vH
            chartWPrevL := vL
if useComparison1
    for requestIndex = 0 to x966SmtRequestTfs.size() - 1
        if x966SmtRequestEnabled.get(requestIndex)
            string requestedTf = x966SmtRequestTfs.get(requestIndex)
            [vH, vL] = smtRequestPreviousRange(comparisonTicker1, requestedTf)
            if requestIndex == 0
                cmp1DPrevHRaw := vH
                cmp1DPrevLRaw := vL
            else if requestIndex == 1
                cmp1WPrevHRaw := vH
                cmp1WPrevLRaw := vL
            else if requestIndex == 2
                cmp1_4HPrevHRaw := vH
                cmp1_4HPrevLRaw := vL
            else if requestIndex == 3
                cmp1_1HPrevHRaw := vH
                cmp1_1HPrevLRaw := vL
            else if requestIndex == 4
                cmp1_30PrevHRaw := vH
                cmp1_30PrevLRaw := vL
            else if requestIndex == 5
                cmp1_15PrevHRaw := vH
                cmp1_15PrevLRaw := vL
            else if requestIndex == 6
                cmp1_5PrevHRaw := vH
                cmp1_5PrevLRaw := vL
            else
                cmp1_1PrevHRaw := vH
                cmp1_1PrevLRaw := vL
if useComparison2
    for requestIndex = 0 to x966SmtRequestTfs.size() - 1
        if x966SmtRequestEnabled.get(requestIndex)
            string requestedTf = x966SmtRequestTfs.get(requestIndex)
            [vH, vL] = smtRequestPreviousRange(comparisonTicker2, requestedTf)
            if requestIndex == 0
                cmp2DPrevHRaw := vH
                cmp2DPrevLRaw := vL
            else if requestIndex == 1
                cmp2WPrevHRaw := vH
                cmp2WPrevLRaw := vL
            else if requestIndex == 2
                cmp2_4HPrevHRaw := vH
                cmp2_4HPrevLRaw := vL
            else if requestIndex == 3
                cmp2_1HPrevHRaw := vH
                cmp2_1HPrevLRaw := vL
            else if requestIndex == 4
                cmp2_30PrevHRaw := vH
                cmp2_30PrevLRaw := vL
            else if requestIndex == 5
                cmp2_15PrevHRaw := vH
                cmp2_15PrevLRaw := vL
            else if requestIndex == 6
                cmp2_5PrevHRaw := vH
                cmp2_5PrevLRaw := vL
            else
                cmp2_1PrevHRaw := vH
                cmp2_1PrevLRaw := vL
float cmp1DPrevH = useComparison1 ? cmp1DPrevHRaw : na
float cmp1DPrevL = useComparison1 ? cmp1DPrevLRaw : na
float cmp1WPrevH = useComparison1 ? cmp1WPrevHRaw : na
float cmp1WPrevL = useComparison1 ? cmp1WPrevLRaw : na
float cmp2DPrevH = useComparison2 ? cmp2DPrevHRaw : na
float cmp2DPrevL = useComparison2 ? cmp2DPrevLRaw : na
float cmp2WPrevH = useComparison2 ? cmp2WPrevHRaw : na
float cmp2WPrevL = useComparison2 ? cmp2WPrevLRaw : na
float cmp1_4HPrevH = useComparison1 ? cmp1_4HPrevHRaw : na
float cmp1_4HPrevL = useComparison1 ? cmp1_4HPrevLRaw : na
float cmp1_1HPrevH = useComparison1 ? cmp1_1HPrevHRaw : na
float cmp1_1HPrevL = useComparison1 ? cmp1_1HPrevLRaw : na
float cmp1_30PrevH = useComparison1 ? cmp1_30PrevHRaw : na
float cmp1_30PrevL = useComparison1 ? cmp1_30PrevLRaw : na
float cmp1_15PrevH = useComparison1 ? cmp1_15PrevHRaw : na
float cmp1_15PrevL = useComparison1 ? cmp1_15PrevLRaw : na
float cmp1_5PrevH = useComparison1 ? cmp1_5PrevHRaw : na
float cmp1_5PrevL = useComparison1 ? cmp1_5PrevLRaw : na
float cmp1_1PrevH = useComparison1 ? cmp1_1PrevHRaw : na
float cmp1_1PrevL = useComparison1 ? cmp1_1PrevLRaw : na
float cmp2_4HPrevH = useComparison2 ? cmp2_4HPrevHRaw : na
float cmp2_4HPrevL = useComparison2 ? cmp2_4HPrevLRaw : na
float cmp2_1HPrevH = useComparison2 ? cmp2_1HPrevHRaw : na
float cmp2_1HPrevL = useComparison2 ? cmp2_1HPrevLRaw : na
float cmp2_30PrevH = useComparison2 ? cmp2_30PrevHRaw : na
float cmp2_30PrevL = useComparison2 ? cmp2_30PrevLRaw : na
float cmp2_15PrevH = useComparison2 ? cmp2_15PrevHRaw : na
float cmp2_15PrevL = useComparison2 ? cmp2_15PrevLRaw : na
float cmp2_5PrevH = useComparison2 ? cmp2_5PrevHRaw : na
float cmp2_5PrevL = useComparison2 ? cmp2_5PrevLRaw : na
float cmp2_1PrevH = useComparison2 ? cmp2_1PrevHRaw : na
float cmp2_1PrevL = useComparison2 ? cmp2_1PrevLRaw : na
chartShort = f_shortSymbol(syminfo.ticker)
comp1Short = f_shortSymbol(effectiveSymbol1)
comp2Short = f_shortSymbol(comparisonSymbol2)
f_processTF(bool enabled, string tf, int slotLookback, float cmp1H, float cmp1L, float cmp2H, float cmp2L, float nativePrevH, float nativePrevL, float nativePrevCmp1H, float nativePrevCmp1L, float nativePrevCmp2H, float nativePrevCmp2L) =>
    bool bearPrinted = false
    bool bullPrinted = false
    int tfSec = timeframe.in_seconds(tf)
    int chartSec = timeframe.in_seconds(timeframe.period)
    bool run = enabled and tfSec >= chartSec
    int activeLookback = slotLookback
    var float curH = na
    var float curL = na
    var int   curHT = na
    var int   curLT = na
    var int   curHI = na
    var int   curLI = na
    var int   curStart = na
    var float curCmp1H = na
    var float curCmp1L = na
    var float curCmp2H = na
    var float curCmp2L = na
    var bool  curCmp1Valid = false
    var bool  curCmp2Valid = false
    var float[] hHist = array.new_float(0)
    var float[] lHist = array.new_float(0)
    var int[]   hTimeHist = array.new_int(0)
    var int[]   lTimeHist = array.new_int(0)
    var int[]   hIdxHist = array.new_int(0)
    var int[]   lIdxHist = array.new_int(0)
    var int[]   startHist = array.new_int(0)
    var float[] cmp1HHist = array.new_float(0)
    var float[] cmp1LHist = array.new_float(0)
    var float[] cmp2HHist = array.new_float(0)
    var float[] cmp2LHist = array.new_float(0)
    if run
        int thisStart = time(tf)
        if na(curStart)
            curStart := thisStart
            curH := high
            curL := low
            curHT := time
            curLT := time
            curHI := bar_index
            curLI := bar_index
            curCmp1H := cmp1H
            curCmp1L := cmp1L
            curCmp2H := cmp2H
            curCmp2L := cmp2L
            curCmp1Valid := not na(cmp1H) and not na(cmp1L)
            curCmp2Valid := not na(cmp2H) and not na(cmp2L)
        else
            bool newTF = thisStart != curStart
            if newTF
                if not persistAfterClose
                    f_deleteEventsByTFStart(tf, curStart)
                array.unshift(hHist, curH)
                array.unshift(lHist, curL)
                array.unshift(hTimeHist, curHT)
                array.unshift(lTimeHist, curLT)
                array.unshift(hIdxHist, curHI)
                array.unshift(lIdxHist, curLI)
                array.unshift(startHist, curStart)
                array.unshift(cmp1HHist, curCmp1Valid ? curCmp1H : na)
                array.unshift(cmp1LHist, curCmp1Valid ? curCmp1L : na)
                array.unshift(cmp2HHist, curCmp2Valid ? curCmp2H : na)
                array.unshift(cmp2LHist, curCmp2Valid ? curCmp2L : na)
                while array.size(hHist) > activeLookback + 10
                    array.pop(hHist)
                    array.pop(lHist)
                    array.pop(hTimeHist)
                    array.pop(lTimeHist)
                    array.pop(hIdxHist)
                    array.pop(lIdxHist)
                    array.pop(startHist)
                    array.pop(cmp1HHist)
                    array.pop(cmp1LHist)
                    array.pop(cmp2HHist)
                    array.pop(cmp2LHist)
                curStart := thisStart
                curH := high
                curL := low
                curHT := time
                curLT := time
                curHI := bar_index
                curLI := bar_index
                curCmp1H := cmp1H
                curCmp1L := cmp1L
                curCmp2H := cmp2H
                curCmp2L := cmp2L
                curCmp1Valid := not na(cmp1H) and not na(cmp1L)
                curCmp2Valid := not na(cmp2H) and not na(cmp2L)
            else
                if high > curH or na(curH)
                    curH := high
                    curHT := time
                    curHI := bar_index
                if low < curL or na(curL)
                    curL := low
                    curLT := time
                    curLI := bar_index
                if not na(cmp1H)
                    curCmp1H := na(curCmp1H) ? cmp1H : math.max(curCmp1H, cmp1H)
                if not na(cmp1L)
                    curCmp1L := na(curCmp1L) ? cmp1L : math.min(curCmp1L, cmp1L)
                if not na(cmp2H)
                    curCmp2H := na(curCmp2H) ? cmp2H : math.max(curCmp2H, cmp2H)
                if not na(cmp2L)
                    curCmp2L := na(curCmp2L) ? cmp2L : math.min(curCmp2L, cmp2L)
                bool cmp1SampleValid = not na(cmp1H) and not na(cmp1L)
                bool cmp2SampleValid = not na(cmp2H) and not na(cmp2L)
                bool tolerantComparisonSampling = tfSec > 60 * 60
                if tolerantComparisonSampling
                    curCmp1Valid := curCmp1Valid or cmp1SampleValid
                    curCmp2Valid := curCmp2Valid or cmp2SampleValid
                else
                    curCmp1Valid := curCmp1Valid and cmp1SampleValid
                    curCmp2Valid := curCmp2Valid and cmp2SampleValid
        float minSweep = 0.0
        float dedupe = dedupeTicks * syminfo.mintick
        float endpointTol = math.max(syminfo.mintick, dedupe)
        string tfSize = f_tfSizeString(tf)
        float[] usedBearLevels = array.new_float(0)
        float[] usedBullLevels = array.new_float(0)
        int[] usedBearX = array.new_int(0)
        float[] usedBearY = array.new_float(0)
        int[] usedBullX = array.new_int(0)
        float[] usedBullY = array.new_float(0)
        int bearCount = 0
        int bullCount = 0
        int histSize = array.size(hHist)
        int lb = math.min(activeLookback, histSize)
        if lb > 0
            for refIdx = 0 to lb - 1
                float refH = array.get(hHist, refIdx)
                float refL = array.get(lHist, refIdx)
                int refHT = array.get(hTimeHist, refIdx)
                int refLT = array.get(lTimeHist, refIdx)
                int refHI = array.get(hIdxHist, refIdx)
                int refLI = array.get(lIdxHist, refIdx)
                int refStart = array.get(startHist, refIdx)
                float refCmp1H = array.get(cmp1HHist, refIdx)
                float refCmp1L = array.get(cmp1LHist, refIdx)
                float refCmp2H = array.get(cmp2HHist, refIdx)
                float refCmp2L = array.get(cmp2LHist, refIdx)
                bool useNativePrev = refIdx == 0
                if useNativePrev
                    if not na(nativePrevH) and not na(nativePrevL)
                        refH := nativePrevH
                        refL := nativePrevL
                    if useComparison1 and not na(nativePrevCmp1H) and not na(nativePrevCmp1L)
                        refCmp1H := nativePrevCmp1H
                        refCmp1L := nativePrevCmp1L
                    if useComparison2 and not na(nativePrevCmp2H) and not na(nativePrevCmp2L)
                        refCmp2H := nativePrevCmp2H
                        refCmp2L := nativePrevCmp2L
                bool untouchedHigh = true
                bool untouchedLow = true
                if refIdx > 0
                    for checkIdx = 0 to refIdx - 1
                        if array.get(hHist, checkIdx) >= refH
                            untouchedHigh := false
                        if array.get(lHist, checkIdx) <= refL
                            untouchedLow := false
                bool validHigh = untouchedHigh
                bool validLow = untouchedLow
                bool endpointBearUsed = f_endpointAlreadyUsed(usedBearX, usedBearY, curHT, curH, endpointTol)
                if showBearish and validHigh and bearCount < maxPerDirection and not endpointBearUsed and not f_levelAlreadyUsed(usedBearLevels, refH, dedupe)
                    bool chartTookHigh = curH > refH + minSweep
                    bool haveCmp1H = useComparison1 and curCmp1Valid and not na(curCmp1H) and not na(refCmp1H)
                    bool haveCmp2H = useComparison2 and curCmp2Valid and not na(curCmp2H) and not na(refCmp2H)
                    bool cmp1TookHigh = haveCmp1H and curCmp1H > refCmp1H + minSweep
                    bool cmp2TookHigh = haveCmp2H and curCmp2H > refCmp2H + minSweep
                    bool cmp1DivH = haveCmp1H and chartTookHigh != cmp1TookHigh
                    bool cmp2DivH = haveCmp2H and chartTookHigh != cmp2TookHigh
                    int validCompsH = (haveCmp1H ? 1 : 0) + (haveCmp2H ? 1 : 0)
                    bool anyComparisonMode = useComparison1 or useComparison2
                    bool eitherDivH = validCompsH > 0 and (cmp1DivH or cmp2DivH)
                    bool isBear = anyComparisonMode ? eitherDivH : chartTookHigh
                    bool closeOk = not requireCloseBack or close < refH
                    if isBear and closeOk
                        string suffix = anyComparisonMode ? f_compSuffix(cmp1DivH, cmp2DivH) : f_logoSymbol(syminfo.ticker)
                        if str.length(suffix) == 0
                            suffix := f_enabledCompSuffix()
                        string txt = f_labelLogo(tf, suffix)
                        string tip = anyComparisonMode ? "Bearish SMT vs " + suffix : chartShort + " swept its own HTF high."
                        float y1 = refH
                        float y2 = curH
                        int x1Time = refHT
                        int x2Time = curHT
                        int x1Idx = refHI
                        int x2Idx = curHI
                        float anchor = chartTookHigh ? curH : refH
                        string key = tf + "|BEAR|" + str.tostring(refStart) + "|" + str.tostring(curStart)
                        bool drawn = f_drawOrUpdate(key, tf, tfSec, -1, refStart, curStart, x1Time, x1Idx, y1, x2Time, x2Idx, y2, anchor, txt, tip, endpointTol, tfSize)
                        if drawn
                            bearPrinted := true
                            bearCount += 1
                            array.push(usedBearLevels, refH)
                            array.push(usedBearY, curH)
                            array.push(usedBearX, curHT)
                bool endpointBullUsed = f_endpointAlreadyUsed(usedBullX, usedBullY, curLT, curL, endpointTol)
                if showBullish and validLow and bullCount < maxPerDirection and not endpointBullUsed and not f_levelAlreadyUsed(usedBullLevels, refL, dedupe)
                    bool chartTookLow = curL < refL - minSweep
                    bool haveCmp1L = useComparison1 and curCmp1Valid and not na(curCmp1L) and not na(refCmp1L)
                    bool haveCmp2L = useComparison2 and curCmp2Valid and not na(curCmp2L) and not na(refCmp2L)
                    bool cmp1TookLow = haveCmp1L and curCmp1L < refCmp1L - minSweep
                    bool cmp2TookLow = haveCmp2L and curCmp2L < refCmp2L - minSweep
                    bool cmp1DivL = haveCmp1L and chartTookLow != cmp1TookLow
                    bool cmp2DivL = haveCmp2L and chartTookLow != cmp2TookLow
                    int validCompsL = (haveCmp1L ? 1 : 0) + (haveCmp2L ? 1 : 0)
                    bool anyComparisonMode = useComparison1 or useComparison2
                    bool eitherDivL = validCompsL > 0 and (cmp1DivL or cmp2DivL)
                    bool isBull = anyComparisonMode ? eitherDivL : chartTookLow
                    bool closeOk = not requireCloseBack or close > refL
                    if isBull and closeOk
                        string suffix = anyComparisonMode ? f_compSuffix(cmp1DivL, cmp2DivL) : f_logoSymbol(syminfo.ticker)
                        if str.length(suffix) == 0
                            suffix := f_enabledCompSuffix()
                        string txt = f_labelLogo(tf, suffix)
                        string tip = anyComparisonMode ? "Bullish SMT vs " + suffix : chartShort + " swept its own HTF low."
                        float y1 = refL
                        float y2 = curL
                        int x1Time = refLT
                        int x2Time = curLT
                        int x1Idx = refLI
                        int x2Idx = curLI
                        float anchor = chartTookLow ? curL : refL
                        string key = tf + "|BULL|" + str.tostring(refStart) + "|" + str.tostring(curStart)
                        bool drawn = f_drawOrUpdate(key, tf, tfSec, 1, refStart, curStart, x1Time, x1Idx, y1, x2Time, x2Idx, y2, anchor, txt, tip, endpointTol, tfSize)
                        if drawn
                            bullPrinted := true
                            bullCount += 1
                            array.push(usedBullLevels, refL)
                            array.push(usedBullY, curL)
                            array.push(usedBullX, curLT)
        f_deleteUnseenCurrentTF(tf, curStart)
    else
        f_deleteAllEventsByTF(tf)
    [bearPrinted, bullPrinted]
[bW, uW] = f_processTF(tfW_on, tfW, lookbackW, cmp1HighChart, cmp1LowChart, cmp2HighChart, cmp2LowChart, chartWPrevH, chartWPrevL, cmp1WPrevH, cmp1WPrevL, cmp2WPrevH, cmp2WPrevL)
[bD, uD] = f_processTF(tfD_on, tfD, lookbackD, cmp1HighChart, cmp1LowChart, cmp2HighChart, cmp2LowChart, chartDPrevH, chartDPrevL, cmp1DPrevH, cmp1DPrevL, cmp2DPrevH, cmp2DPrevL)
[b4H, u4H] = f_processTF(tf4H_on, tf4H, lookback4H, cmp1HighChart, cmp1LowChart, cmp2HighChart, cmp2LowChart, na, na, cmp1_4HPrevH, cmp1_4HPrevL, cmp2_4HPrevH, cmp2_4HPrevL)
[b1H, u1H] = f_processTF(tf1H_on, tf1H, lookback1H, cmp1HighChart, cmp1LowChart, cmp2HighChart, cmp2LowChart, na, na, cmp1_1HPrevH, cmp1_1HPrevL, cmp2_1HPrevH, cmp2_1HPrevL)
[b30, u30] = f_processTF(tf30_on, tf30, lookback30, cmp1HighChart, cmp1LowChart, cmp2HighChart, cmp2LowChart, na, na, cmp1_30PrevH, cmp1_30PrevL, cmp2_30PrevH, cmp2_30PrevL)
[b15, u15] = f_processTF(tf15_on, tf15, lookback15, cmp1HighChart, cmp1LowChart, cmp2HighChart, cmp2LowChart, na, na, cmp1_15PrevH, cmp1_15PrevL, cmp2_15PrevH, cmp2_15PrevL)
[b5, u5] = f_processTF(tf5_on, tf5, lookback5, cmp1HighChart, cmp1LowChart, cmp2HighChart, cmp2LowChart, na, na, cmp1_5PrevH, cmp1_5PrevL, cmp2_5PrevH, cmp2_5PrevL)
[b1, u1] = f_processTF(tf1_on, tf1, lookback1, cmp1HighChart, cmp1LowChart, cmp2HighChart, cmp2LowChart, na, na, cmp1_1PrevH, cmp1_1PrevL, cmp2_1PrevH, cmp2_1PrevL)
f_purgeBroken()
f_enforceLtfCaps()
f_enforceExactTFRetention(tfW)
f_enforceExactTFRetention(tfD)
f_enforceExactTFRetention(tf4H)
f_enforceExactTFRetention(tf1H)
f_enforceExactTFRetention(tf30)
f_enforceExactTFRetention(tf15)
f_enforceExactTFRetention(tf5)
f_enforceExactTFRetention(tf1)
// No alert conditions supplied in this edition.

// END OF SCRIPT — STDV/CISD + HTF Context + Multi-Timeframe SMT
````
