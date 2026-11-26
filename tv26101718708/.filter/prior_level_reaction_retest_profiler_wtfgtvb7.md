# Prior Level Reaction & Retest Profiler

- url: https://www.tradingview.com/script/WTfGTvb7-Prior-Level-Reaction-Retest-Profiler/
- type: indicator
- pine_id: PUB;888670e3d54143cba30de901a3b6b165
- version: 1.0

## Description

[b]Short description[/b]
An evidence-based profiler for first touches, reactions, breakouts, and confirmed retests at previous-day and previous-week highs and lows, with ATR-normalized outcomes and volatility-regime statistics.

[b]Overview[/b]
Previous-day and previous-week highs and lows are widely used as support, resistance, breakout references, and liquidity levels. However, drawing these levels does not answer the practical question: how has this symbol historically behaved after first reaching them?
Prior Level Reaction & Retest Profiler converts each first interaction with PDH, PDL, PWH, and PWL into a measurable event. It records whether price moved away from the level, continued through it, produced a false-break reaction, remained unresolved, or formed a confirmed breakout retest. All distances are normalized with the previous completed daily ATR so observations remain comparable across changing volatility conditions.
This is a descriptive research and decision-support tool. It does not issue automatic buy or sell signals, and historical frequencies are not presented as predictions.
[b]
What the indicator measures[/b]
For every enabled level, the script selects one first-touch observation during that level's valid daily or weekly period. At the moment of contact, it freezes both the level and the previous completed daily ATR.
For a prior high:
Movement below the level is measured as reaction excursion.
Movement above the level is measured as breakout excursion.
For a prior low, those directions are reversed.
The event is then classified as:
Reaction: The configured reaction threshold is reached first.
Breakout: The configured breakout threshold is reached first.
False-break reaction: Price closes through the level but reaches the reaction threshold before the breakout threshold.
Ambiguous: Both thresholds are reached on the same evaluation bar, so their order cannot be determined from OHLC data.
Unresolved: Neither threshold is reached before the evaluation horizon ends or the source level expires.
Reaction and breakout percentages use directionally resolved observations as their denominator. The dashboard also displays the total sample, ambiguous observations, unresolved observations, and average maximum excursions in daily ATR units.

[b]Why evaluation begins after the touch bar[/b]
Historical OHLC bars do not reveal whether the high or low occurred first. Counting the touch bar could therefore invent a sequence that is not present in the data. This script begins outcome evaluation on the following bar and explicitly preserves same-bar dual-threshold outcomes as ambiguous rather than guessing.

[b]Breakout retest engine[/b]
When completed history favors breakout over reaction for a level, the optional retest engine follows a confirmed close through that level using a transparent state sequence:
Retest pending: A breakout close occurred and the engine is waiting for price to return.
Retest in progress: Price entered the ATR-normalized retest zone but has not yet confirmed.
Retest confirmed: Price touched the zone and produced a confirmed close back in the breakout direction. Users can optionally require a directional confirmation candle.
Target reached or invalidated: After confirmation, the script records whether the configured ATR target was traded before a confirmed close beyond the invalidation boundary.
Only confirmed chart bars change retest states. A confirmation by itself is not counted as a successful retest. Retest success is calculated only from completed post-confirmation target and invalidation outcomes.

[b]Volatility-conditioned evidence[/b]
Retests are not assumed to behave identically in every volatility environment. When regime conditioning is enabled, the script stores the volatility regime present when the breakout setup begins and maintains separate target/invalidation histories for:
Low volatility: Previous daily ATR is at or below 0.80 of its 100-day average.
Normal volatility: The ratio is between 0.80 and 1.20.
High volatility: Previous daily ATR is at or above 1.20 of its 100-day average.
The live decision gate uses only the matching regime's completed retests. It does not borrow confidence from unrelated volatility conditions.

[b]Evidence gate[/b]
The simple dashboard prevents attractive headline statistics from being mistaken for a tradable edge.
Observe only: The matching volatility regime has fewer completed retests than the configured minimum.
Stand aside: The sample is sufficient, but target-before-invalidation success is below the configured requirement.
Retest pending / in progress: The evidence gate passes, but confirmation is not complete.
Retest confirmed: The evidence gate passes and the required retest close is confirmed.
Target reached / invalidated: The live confirmed setup has completed.
For example, a level can have a high general breakout rate while its low-volatility retests have a poor success rate. In that situation, the dashboard shows Stand Aside rather than promoting the broader breakout statistic.

[b]Display modes[/b]
Simple mode is the default. It shows only the current level segments and a plain-language decision card containing:
Setup
Active level
What to do now
Required confirmation
Invalidation condition
Supporting sample and regime evidence
Only the latest confirmed retest marker is displayed by default. Historical markers can be enabled for auditing.
Evidence mode shows the complete PDH, PDL, PWH, and PWL matrix with sample count, reaction rate, breakout rate, false-break rate, ambiguous and unresolved shares, and average excursions.
[b]
Main settings[/b]
Daily ATR length
Reaction and breakout thresholds in ATR units
Evaluation horizon in chart bars
Previous-day and previous-week level toggles
Retest-zone width and retest window
Optional directional confirmation candle
Minimum completed retest sample
Minimum acceptable retest success rate
Volatility-regime conditioning
Simple or Evidence display mode
Static and dynamic alerts
Changing chart timeframe changes the real duration represented by the bar-based evaluation and retest windows. Statistics should therefore be compared only when symbol, timeframe, and settings are consistent.

[b]Alerts[/b]
Named alerts are available for:
First level touch
Reaction or breakout outcome
False-break reaction
Ambiguous outcome
Breakout close with retest pending
Retest confirmation
Retest failure or expiry
Confirmed-retest target reached
Confirmed-retest invalidation
Dynamic messages can be used by enabling the dynamic-alert setting and creating an alert with Any alert() function call.

[b]Repainting and data behavior[/b]
Previous-day, previous-week, daily ATR, and ATR-average values are requested with a one-period offset. Only completed higher-timeframe values are used; no future data is accessed.
Retest state changes require confirmed chart bars. Once a historical event or retest outcome is finalized, its classification does not change. Active events can update as new bars close.

[b]Limitations[/b]
Designed primarily for intraday charts.
OHLC data does not reveal intrabar high/low order; ambiguous cases are retained explicitly.
Gap openings can cross a level without trading every intervening price.
Available chart history and data-feed differences affect samples.
Regime-filtered samples can be considerably smaller than overall samples.
The reference target uses traded price, while post-confirmation invalidation requires a confirmed close.
Spread, slippage, commissions, liquidity, position sizing, and execution constraints are not modeled.
Historical behavior does not guarantee future results.
This indicator is not financial advice.

## Source Code

````pine
//@version=6
indicator("Prior Level Reaction & Retest Profiler", "PLR Retest", overlay = true, max_labels_count = 200, max_bars_back = 5000)

// Measures first-touch outcomes at previous-day and previous-week extremes.
// Evaluation starts after the touch bar so unknown intrabar sequencing cannot
// bias the result.

string GROUP_ENGINE = "Event engine"
int atrLength = input.int(14, "Daily ATR length", minval = 5, maxval = 100, group = GROUP_ENGINE)
float reactionTargetAtr = input.float(0.50, "Reaction target (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = GROUP_ENGINE)
float breakTargetAtr = input.float(0.50, "Break target (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = GROUP_ENGINE)
int evaluationBars = input.int(30, "Evaluation horizon (bars)", minval = 2, maxval = 500, group = GROUP_ENGINE)
bool requireCloseTouch = input.bool(false, "Require close through level", group = GROUP_ENGINE,
     tooltip = "When enabled, wick-only contacts are ignored and the touch bar must close beyond the level.")

string GROUP_RETEST = "Breakout retest"
bool enableRetestEngine = input.bool(true, "Enable retest confirmation", group = GROUP_RETEST)
bool showRetestMarker = input.bool(true, "Show latest retest marker", group = GROUP_RETEST)
bool showHistoricalRetestMarkers = input.bool(false, "Show historical retest markers", group = GROUP_RETEST)
float retestToleranceAtr = input.float(0.10, "Retest zone (ATR)", minval = 0.02, maxval = 0.50, step = 0.01, group = GROUP_RETEST,
     tooltip = "Half-width of the retest zone around the tested level, measured with the frozen daily ATR.")
int retestWindowBars = input.int(12, "Retest window (bars)", minval = 2, maxval = 100, group = GROUP_RETEST)
bool requireDirectionalCandle = input.bool(true, "Require directional confirmation candle", group = GROUP_RETEST)
bool conditionByVolatility = input.bool(true, "Condition evidence by volatility regime", group = GROUP_RETEST,
     tooltip = "Uses separate Low, Normal, and High volatility retest histories for the decision gate.")
int minimumRetestSamples = input.int(20, "Minimum completed retests", minval = 5, maxval = 200, group = GROUP_RETEST)
float minimumRetestSuccess = input.float(50.0, "Minimum retest success (%)", minval = 10.0, maxval = 90.0, step = 1.0, group = GROUP_RETEST,
     tooltip = "Simple mode stands aside when enough completed retests exist but their target-before-invalidation rate is below this value.")

string GROUP_LEVELS = "Levels"
bool showDaily = input.bool(true, "Previous day high / low", group = GROUP_LEVELS)
bool showWeekly = input.bool(false, "Previous week high / low", group = GROUP_LEVELS)
bool showTouchMarkers = input.bool(false, "Touch markers", group = GROUP_LEVELS)
bool showResolutionMarkers = input.bool(false, "Outcome markers", group = GROUP_LEVELS)

string GROUP_DASH = "Dashboard"
string displayMode = input.string("Simple", "Display mode", options = ["Simple", "Evidence"], group = GROUP_DASH,
     tooltip = "Simple shows a plain-language decision card. Evidence shows the complete statistical table.")
bool showDashboard = input.bool(true, "Show dashboard", group = GROUP_DASH)
string dashboardPosition = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_DASH)
string dashboardSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = GROUP_DASH)

string GROUP_ALERTS = "Alerts"
bool dynamicAlerts = input.bool(false, "Enable dynamic alert() messages", group = GROUP_ALERTS)

// Only completed higher-timeframe values are requested.
float pdh = request.security(syminfo.tickerid, "D", high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float pdl = request.security(syminfo.tickerid, "D", low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float pwh = request.security(syminfo.tickerid, "W", high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float pwl = request.security(syminfo.tickerid, "W", low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(atrLength)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float dailyAtrMean = request.security(syminfo.tickerid, "D", ta.sma(ta.atr(atrLength), 100)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

bool newDay = nz(ta.change(time("D"))) != 0
bool newWeek = nz(ta.change(time("W"))) != 0
var int dayStartBar = bar_index
var int weekStartBar = bar_index
if newDay
    dayStartBar := bar_index
if newWeek
    weekStartBar := bar_index
var bool dayCycleReady = false
var bool weekCycleReady = false
if newDay
    dayCycleReady := true
if newWeek
    weekCycleReady := true
bool validAtr = not na(dailyAtr) and dailyAtr > 0
float volatilityRatio = validAtr and not na(dailyAtrMean) and dailyAtrMean > 0 ? dailyAtr / dailyAtrMean : na
int currentRegimeCode = na(volatilityRatio) ? -1 : volatilityRatio >= 1.20 ? 2 : volatilityRatio <= 0.80 ? 0 : 1
string volatilityRegime = currentRegimeCode == -1 ? "Warming up" : currentRegimeCode == 2 ? "High" : currentRegimeCode == 0 ? "Low" : "Normal"

// Indices: 0 PDH, 1 PDL, 2 PWH, 3 PWL. side 1 = high, -1 = low.
int LEVEL_COUNT = 4
var string[] levelNames = array.from("PDH", "PDL", "PWH", "PWL")
var int[] levelSides = array.from(1, -1, 1, -1)
var bool[] periodTouched = array.new_bool(LEVEL_COUNT, false)
var bool[] eventActive = array.new_bool(LEVEL_COUNT, false)
var int[] eventStartBar = array.new_int(LEVEL_COUNT, 0)
var float[] eventLevel = array.new_float(LEVEL_COUNT, na)
var float[] eventAtr = array.new_float(LEVEL_COUNT, na)
var bool[] eventEverClosedBeyond = array.new_bool(LEVEL_COUNT, false)
var float[] eventMaxReaction = array.new_float(LEVEL_COUNT, 0.0)
var float[] eventMaxBreak = array.new_float(LEVEL_COUNT, 0.0)
var string[] lastOutcome = array.new_string(LEVEL_COUNT, "WAITING")

// Retest states: 0 idle, 1 waiting, 2 testing zone, 3 confirmed/live,
// 4 failed before confirmation, 5 target reached, 6 invalidated after confirmation.
var int[] retestState = array.new_int(LEVEL_COUNT, 0)
var int[] retestStartBar = array.new_int(LEVEL_COUNT, 0)
var float[] retestLevel = array.new_float(LEVEL_COUNT, na)
var float[] retestAtr = array.new_float(LEVEL_COUNT, na)
var int[] retestAttemptCount = array.new_int(LEVEL_COUNT, 0)
var int[] retestConfirmedCount = array.new_int(LEVEL_COUNT, 0)
var int[] retestFailedCount = array.new_int(LEVEL_COUNT, 0)
var int[] retestTargetCount = array.new_int(LEVEL_COUNT, 0)
var int[] retestInvalidatedCount = array.new_int(LEVEL_COUNT, 0)
var int[] retestRegimeCode = array.new_int(LEVEL_COUNT, -1)
// Flattened [level * 3 + regime], where regimes are 0 Low, 1 Normal, 2 High.
var int[] regimeRetestTargetCount = array.new_int(LEVEL_COUNT * 3, 0)
var int[] regimeRetestInvalidatedCount = array.new_int(LEVEL_COUNT * 3, 0)
var int lastRetestConfirmBar = na
var float lastRetestConfirmPrice = na
var int lastRetestConfirmSide = 0
var int lastRetestConfirmIndex = -1

var int[] sampleCount = array.new_int(LEVEL_COUNT, 0)
var int[] reactionCount = array.new_int(LEVEL_COUNT, 0)
var int[] breakoutCount = array.new_int(LEVEL_COUNT, 0)
var int[] falseBreakCount = array.new_int(LEVEL_COUNT, 0)
var int[] ambiguousCount = array.new_int(LEVEL_COUNT, 0)
var int[] unresolvedCount = array.new_int(LEVEL_COUNT, 0)
var float[] reactionExcursionSum = array.new_float(LEVEL_COUNT, 0.0)
var float[] breakExcursionSum = array.new_float(LEVEL_COUNT, 0.0)

float[] levels = array.from(pdh, pdl, pwh, pwl)
bool[] enabled = array.from(showDaily, showDaily, showWeekly, showWeekly)

bool anyTouch = false
bool anyReaction = false
bool anyBreakout = false
bool anyFalseBreak = false
bool anyAmbiguous = false
bool anyRetestStarted = false
bool anyRetestConfirmed = false
bool anyRetestFailed = false
bool anyRetestTarget = false
bool anyRetestInvalidated = false
bool bullishRetestConfirmed = false
bool bearishRetestConfirmed = false
string eventMessage = ""
string retestMessage = ""

// Finalize an event whose daily/weekly source level is expiring.
if newDay
    for i = 0 to 1
        if lastRetestConfirmIndex == i
            lastRetestConfirmBar := na
            lastRetestConfirmPrice := na
            lastRetestConfirmSide := 0
            lastRetestConfirmIndex := -1
        int oldRetestState = array.get(retestState, i)
        if oldRetestState == 1 or oldRetestState == 2
            array.set(retestFailedCount, i, array.get(retestFailedCount, i) + 1)
        if array.get(eventActive, i)
            float atrSnap = array.get(eventAtr, i)
            array.set(sampleCount, i, array.get(sampleCount, i) + 1)
            array.set(unresolvedCount, i, array.get(unresolvedCount, i) + 1)
            array.set(reactionExcursionSum, i, array.get(reactionExcursionSum, i) + array.get(eventMaxReaction, i) / atrSnap)
            array.set(breakExcursionSum, i, array.get(breakExcursionSum, i) + array.get(eventMaxBreak, i) / atrSnap)
            array.set(eventActive, i, false)
            array.set(lastOutcome, i, "UNRESOLVED")
        array.set(periodTouched, i, false)
        array.set(lastOutcome, i, "WAITING")
        array.set(retestState, i, 0)
        array.set(retestRegimeCode, i, -1)

if newWeek
    for i = 2 to 3
        if lastRetestConfirmIndex == i
            lastRetestConfirmBar := na
            lastRetestConfirmPrice := na
            lastRetestConfirmSide := 0
            lastRetestConfirmIndex := -1
        int oldRetestState = array.get(retestState, i)
        if oldRetestState == 1 or oldRetestState == 2
            array.set(retestFailedCount, i, array.get(retestFailedCount, i) + 1)
        if array.get(eventActive, i)
            float atrSnap = array.get(eventAtr, i)
            array.set(sampleCount, i, array.get(sampleCount, i) + 1)
            array.set(unresolvedCount, i, array.get(unresolvedCount, i) + 1)
            array.set(reactionExcursionSum, i, array.get(reactionExcursionSum, i) + array.get(eventMaxReaction, i) / atrSnap)
            array.set(breakExcursionSum, i, array.get(breakExcursionSum, i) + array.get(eventMaxBreak, i) / atrSnap)
            array.set(eventActive, i, false)
            array.set(lastOutcome, i, "UNRESOLVED")
        array.set(periodTouched, i, false)
        array.set(lastOutcome, i, "WAITING")
        array.set(retestState, i, 0)
        array.set(retestRegimeCode, i, -1)

// Evaluate after the touch bar. Dual hits on one bar are explicitly ambiguous.
for i = 0 to LEVEL_COUNT - 1
    if array.get(eventActive, i) and bar_index > array.get(eventStartBar, i)
        int side = array.get(levelSides, i)
        float lvl = array.get(eventLevel, i)
        float atrSnap = array.get(eventAtr, i)
        float reactionExcursion = math.max(side == 1 ? lvl - low : high - lvl, 0.0)
        float breakExcursion = math.max(side == 1 ? high - lvl : lvl - low, 0.0)
        float maxReaction = math.max(array.get(eventMaxReaction, i), reactionExcursion)
        float maxBreak = math.max(array.get(eventMaxBreak, i), breakExcursion)
        bool everBeyond = array.get(eventEverClosedBeyond, i) or (side == 1 ? close > lvl : close < lvl)
        array.set(eventMaxReaction, i, maxReaction)
        array.set(eventMaxBreak, i, maxBreak)
        array.set(eventEverClosedBeyond, i, everBeyond)

        bool closedBeyondNow = side == 1 ? close > lvl : close < lvl
        bool breakoutHistoricallyFavored = array.get(breakoutCount, i) > array.get(reactionCount, i)
        if enableRetestEngine and barstate.isconfirmed and (not conditionByVolatility or currentRegimeCode >= 0) and breakoutHistoricallyFavored and closedBeyondNow and array.get(retestState, i) == 0
            array.set(retestState, i, 1)
            array.set(retestStartBar, i, bar_index)
            array.set(retestLevel, i, lvl)
            array.set(retestAtr, i, atrSnap)
            array.set(retestRegimeCode, i, currentRegimeCode >= 0 ? currentRegimeCode : 1)
            array.set(retestAttemptCount, i, array.get(retestAttemptCount, i) + 1)
            anyRetestStarted := true
            retestMessage := array.get(levelNames, i) + " breakout closed; waiting for retest"

        bool reactionHit = maxReaction >= reactionTargetAtr * atrSnap
        bool breakHit = maxBreak >= breakTargetAtr * atrSnap
        bool horizonExpired = bar_index - array.get(eventStartBar, i) >= evaluationBars

        if reactionHit or breakHit or horizonExpired
            int barsUsed = bar_index - array.get(eventStartBar, i)
            array.set(sampleCount, i, array.get(sampleCount, i) + 1)
            array.set(reactionExcursionSum, i, array.get(reactionExcursionSum, i) + maxReaction / atrSnap)
            array.set(breakExcursionSum, i, array.get(breakExcursionSum, i) + maxBreak / atrSnap)
            string outcome = ""
            if reactionHit and breakHit
                array.set(ambiguousCount, i, array.get(ambiguousCount, i) + 1)
                anyAmbiguous := true
                outcome := "AMBIGUOUS"
            else if reactionHit
                array.set(reactionCount, i, array.get(reactionCount, i) + 1)
                anyReaction := true
                if everBeyond
                    array.set(falseBreakCount, i, array.get(falseBreakCount, i) + 1)
                    anyFalseBreak := true
                    outcome := "FALSE BREAK -> REACTION"
                else
                    outcome := "REACTION"
            else if breakHit
                array.set(breakoutCount, i, array.get(breakoutCount, i) + 1)
                anyBreakout := true
                outcome := "BREAKOUT"
            else
                array.set(unresolvedCount, i, array.get(unresolvedCount, i) + 1)
                outcome := "UNRESOLVED"
            eventMessage := array.get(levelNames, i) + " " + outcome + " after " + str.tostring(barsUsed) + " bars"
            array.set(lastOutcome, i, outcome)
            array.set(eventActive, i, false)

// Register one first touch per source period.
for i = 0 to LEVEL_COUNT - 1
    float lvl = array.get(levels, i)
    int side = array.get(levelSides, i)
    bool reached = side == 1 ? high >= lvl : low <= lvl
    bool closedThrough = side == 1 ? close > lvl : close < lvl
    bool completeSourceCycle = i < 2 ? dayCycleReady : weekCycleReady
    bool qualifies = completeSourceCycle and array.get(enabled, i) and validAtr and not na(lvl) and reached and (not requireCloseTouch or closedThrough)
    if qualifies and not array.get(periodTouched, i) and not array.get(eventActive, i)
        bool initialBeyond = side == 1 ? close > lvl : close < lvl
        bool gapBeyond = side == 1 ? open > lvl and close[1] <= lvl : open < lvl and close[1] >= lvl
        array.set(periodTouched, i, true)
        array.set(eventActive, i, true)
        array.set(eventStartBar, i, bar_index)
        array.set(eventLevel, i, lvl)
        array.set(eventAtr, i, dailyAtr)
        array.set(eventEverClosedBeyond, i, initialBeyond)
        array.set(eventMaxReaction, i, 0.0)
        array.set(eventMaxBreak, i, 0.0)
        array.set(lastOutcome, i, "ACTIVE")
        bool breakoutHistoricallyFavored = array.get(breakoutCount, i) > array.get(reactionCount, i)
        if enableRetestEngine and barstate.isconfirmed and (not conditionByVolatility or currentRegimeCode >= 0) and breakoutHistoricallyFavored and initialBeyond and array.get(retestState, i) == 0
            array.set(retestState, i, 1)
            array.set(retestStartBar, i, bar_index)
            array.set(retestLevel, i, lvl)
            array.set(retestAtr, i, dailyAtr)
            array.set(retestRegimeCode, i, currentRegimeCode >= 0 ? currentRegimeCode : 1)
            array.set(retestAttemptCount, i, array.get(retestAttemptCount, i) + 1)
            anyRetestStarted := true
            retestMessage := array.get(levelNames, i) + " breakout closed; waiting for retest"
        anyTouch := true
        eventMessage := array.get(levelNames, i) + " first touch" + (gapBeyond ? " (gap beyond)" : initialBeyond ? " (close through)" : " (wick/reclaim)")

// Breakout-retest state engine. It is independent of the broader event outcome,
// so a retest can remain active after the original excursion target resolves.
if enableRetestEngine
    for i = 0 to LEVEL_COUNT - 1
        int side = array.get(levelSides, i)
        int state = array.get(retestState, i)
        float activeLvl = array.get(eventLevel, i)
        float activeAtr = array.get(eventAtr, i)
        bool breakoutHistoricallyFavored = array.get(breakoutCount, i) > array.get(reactionCount, i)
        bool eventHasBreakClose = barstate.isconfirmed and (not conditionByVolatility or currentRegimeCode >= 0) and breakoutHistoricallyFavored and array.get(eventActive, i) and not na(activeLvl) and (side == 1 ? close > activeLvl : close < activeLvl)

        if state == 0 and eventHasBreakClose
            array.set(retestState, i, 1)
            array.set(retestStartBar, i, bar_index)
            array.set(retestLevel, i, activeLvl)
            array.set(retestAtr, i, activeAtr)
            array.set(retestRegimeCode, i, currentRegimeCode >= 0 ? currentRegimeCode : 1)
            array.set(retestAttemptCount, i, array.get(retestAttemptCount, i) + 1)
            anyRetestStarted := true
            retestMessage := array.get(levelNames, i) + " breakout closed; waiting for retest"
            state := 1

        if (state == 1 or state == 2) and barstate.isconfirmed
            float lvl = array.get(retestLevel, i)
            float atrSnap = array.get(retestAtr, i)
            float tolerance = retestToleranceAtr * atrSnap
            int barsSinceBreak = bar_index - array.get(retestStartBar, i)
            bool zoneTouched = high >= lvl - tolerance and low <= lvl + tolerance
            bool closesBeyond = side == 1 ? close > lvl : close < lvl
            bool directionalCandle = not requireDirectionalCandle or (side == 1 ? close > open : close < open)
            bool failedClose = side == 1 ? close < lvl - tolerance : close > lvl + tolerance
            bool confirmedNow = bar_index > array.get(retestStartBar, i) and ((zoneTouched and closesBeyond and directionalCandle) or (state == 2 and closesBeyond and directionalCandle))
            bool expired = barsSinceBreak > retestWindowBars

            if failedClose
                array.set(retestState, i, 4)
                array.set(retestFailedCount, i, array.get(retestFailedCount, i) + 1)
                anyRetestFailed := true
                retestMessage := array.get(levelNames, i) + " retest failed"
            else if confirmedNow
                array.set(retestState, i, 3)
                array.set(retestConfirmedCount, i, array.get(retestConfirmedCount, i) + 1)
                anyRetestConfirmed := true
                bullishRetestConfirmed := side == 1
                bearishRetestConfirmed := side == -1
                lastRetestConfirmBar := bar_index
                lastRetestConfirmPrice := side == 1 ? low : high
                lastRetestConfirmSide := side
                lastRetestConfirmIndex := i
                retestMessage := array.get(levelNames, i) + " breakout retest confirmed"
            else if expired
                array.set(retestState, i, 4)
                array.set(retestFailedCount, i, array.get(retestFailedCount, i) + 1)
                anyRetestFailed := true
                retestMessage := array.get(levelNames, i) + " retest window expired"
            else if zoneTouched and bar_index > array.get(retestStartBar, i)
                array.set(retestState, i, 2)

        if state == 3 and barstate.isconfirmed
            float lvl = array.get(retestLevel, i)
            float atrSnap = array.get(retestAtr, i)
            float targetPrice = lvl + side * breakTargetAtr * atrSnap
            float invalidationPrice = lvl - side * retestToleranceAtr * atrSnap
            bool targetHit = side == 1 ? high >= targetPrice : low <= targetPrice
            bool invalidated = side == 1 ? close < invalidationPrice : close > invalidationPrice
            if targetHit
                array.set(retestState, i, 5)
                array.set(retestTargetCount, i, array.get(retestTargetCount, i) + 1)
                int regimeCode = array.get(retestRegimeCode, i)
                if regimeCode >= 0
                    int regimeIndex = i * 3 + regimeCode
                    array.set(regimeRetestTargetCount, regimeIndex, array.get(regimeRetestTargetCount, regimeIndex) + 1)
                anyRetestTarget := true
                retestMessage := array.get(levelNames, i) + " confirmed retest reached target"
            else if invalidated
                array.set(retestState, i, 6)
                array.set(retestInvalidatedCount, i, array.get(retestInvalidatedCount, i) + 1)
                int regimeCode = array.get(retestRegimeCode, i)
                if regimeCode >= 0
                    int regimeIndex = i * 3 + regimeCode
                    array.set(regimeRetestInvalidatedCount, regimeIndex, array.get(regimeRetestInvalidatedCount, regimeIndex) + 1)
                anyRetestInvalidated := true
                retestMessage := array.get(levelNames, i) + " confirmed retest invalidated"

// Select the most actionable retest for the simple dashboard and guide lines.
int guideRetestIndex = -1
int guideRetestPriority = -1
for i = 0 to LEVEL_COUNT - 1
    int state = array.get(retestState, i)
    int priority = state == 3 ? 5 : state == 2 ? 4 : state == 1 ? 3 : (state == 5 or state == 6) ? 2 : state == 4 ? 1 : 0
    if array.get(enabled, i) and priority > guideRetestPriority
        guideRetestIndex := i
        guideRetestPriority := priority
if guideRetestPriority == 0
    guideRetestIndex := -1

// Evidence mode retains historical step plots. Simple mode draws only the live
// daily/weekly segments below.
plot(displayMode == "Evidence" and showDaily ? pdh : na, "Previous Day High", color = color.new(#EF5350, 35), linewidth = 1, style = plot.style_stepline)
plot(displayMode == "Evidence" and showDaily ? pdl : na, "Previous Day Low", color = color.new(#26A69A, 35), linewidth = 1, style = plot.style_stepline)
plot(displayMode == "Evidence" and showWeekly ? pwh : na, "Previous Week High", color = color.new(#AB47BC, 30), linewidth = 2, style = plot.style_stepline)
plot(displayMode == "Evidence" and showWeekly ? pwl : na, "Previous Week Low", color = color.new(#42A5F5, 30), linewidth = 2, style = plot.style_stepline)
plotshape(showTouchMarkers and anyTouch, "First level touch", shape.circle, location.abovebar, color.yellow, size = size.tiny, text = "T", textcolor = color.black)
plotshape(showResolutionMarkers and anyReaction and not anyFalseBreak, "Reaction resolved", shape.triangleup, location.belowbar, color.lime, size = size.tiny, text = "R")
plotshape(showResolutionMarkers and anyFalseBreak, "False break resolved", shape.diamond, location.belowbar, color.aqua, size = size.tiny, text = "F")
plotshape(showResolutionMarkers and anyBreakout, "Breakout resolved", shape.triangledown, location.abovebar, color.orange, size = size.tiny, text = "B")
plotshape(showResolutionMarkers and anyAmbiguous, "Ambiguous outcome", shape.xcross, location.abovebar, color.gray, size = size.tiny, text = "?")
plotshape(showHistoricalRetestMarkers and bullishRetestConfirmed, "Bullish retest confirmed", shape.labelup, location.belowbar, color.lime, size = size.tiny, text = "RETEST\nOK", textcolor = color.black)
plotshape(showHistoricalRetestMarkers and bearishRetestConfirmed, "Bearish retest confirmed", shape.labeldown, location.abovebar, color.orange, size = size.tiny, text = "RETEST\nOK", textcolor = color.black)

// In Simple mode, name the live levels directly on the right edge so users do
// not need to memorize the color scheme.
var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na
var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var line targetLine = na
var line invalidationLine = na
var label targetLabel = na
var label invalidationLabel = na
var label latestRetestLabel = na
if barstate.islast
    label.delete(pdhLabel)
    label.delete(pdlLabel)
    label.delete(pwhLabel)
    label.delete(pwlLabel)
    line.delete(pdhLine)
    line.delete(pdlLine)
    line.delete(pwhLine)
    line.delete(pwlLine)
    line.delete(targetLine)
    line.delete(invalidationLine)
    label.delete(targetLabel)
    label.delete(invalidationLabel)
    label.delete(latestRetestLabel)
    if showRetestMarker and not na(lastRetestConfirmBar)
        latestRetestLabel := label.new(lastRetestConfirmBar, lastRetestConfirmPrice, "LATEST\nRETEST OK", xloc = xloc.bar_index,
             style = lastRetestConfirmSide == 1 ? label.style_label_up : label.style_label_down,
             color = lastRetestConfirmSide == 1 ? color.lime : color.orange, textcolor = color.black, size = size.tiny)
    if displayMode == "Simple"
        if showDaily and not na(pdh)
            pdhLine := line.new(dayStartBar, pdh, bar_index + 2, pdh, xloc = xloc.bar_index, color = color.new(#EF5350, 20), width = 1)
            pdhLabel := label.new(bar_index + 2, pdh, "PDH  " + str.tostring(pdh, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = #EF5350, textcolor = color.white, size = size.tiny)
        if showDaily and not na(pdl)
            pdlLine := line.new(dayStartBar, pdl, bar_index + 2, pdl, xloc = xloc.bar_index, color = color.new(#26A69A, 20), width = 1)
            pdlLabel := label.new(bar_index + 2, pdl, "PDL  " + str.tostring(pdl, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = #26A69A, textcolor = color.white, size = size.tiny)
        if showWeekly and not na(pwh)
            pwhLine := line.new(weekStartBar, pwh, bar_index + 2, pwh, xloc = xloc.bar_index, color = color.new(#AB47BC, 20), width = 1)
            pwhLabel := label.new(bar_index + 2, pwh, "PWH  " + str.tostring(pwh, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = #AB47BC, textcolor = color.white, size = size.tiny)
        if showWeekly and not na(pwl)
            pwlLine := line.new(weekStartBar, pwl, bar_index + 2, pwl, xloc = xloc.bar_index, color = color.new(#42A5F5, 20), width = 1)
            pwlLabel := label.new(bar_index + 2, pwl, "PWL  " + str.tostring(pwl, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = #42A5F5, textcolor = color.white, size = size.tiny)
        if guideRetestIndex >= 0 and array.get(retestState, guideRetestIndex) == 3
            int retestSide = array.get(levelSides, guideRetestIndex)
            float confirmedLevel = array.get(retestLevel, guideRetestIndex)
            float confirmedAtr = array.get(retestAtr, guideRetestIndex)
            float targetPrice = confirmedLevel + retestSide * breakTargetAtr * confirmedAtr
            float invalidationPrice = confirmedLevel - retestSide * retestToleranceAtr * confirmedAtr
            targetLine := line.new(bar_index, targetPrice, bar_index + 10, targetPrice, xloc = xloc.bar_index, color = color.new(color.lime, 20), style = line.style_dashed)
            invalidationLine := line.new(bar_index, invalidationPrice, bar_index + 10, invalidationPrice, xloc = xloc.bar_index, color = color.new(color.red, 20), style = line.style_dashed)
            targetLabel := label.new(bar_index + 10, targetPrice, "Target  " + str.tostring(targetPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.lime, 10), textcolor = color.black, size = size.tiny)
            invalidationLabel := label.new(bar_index + 10, invalidationPrice, "Invalid  " + str.tostring(invalidationPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.red, 10), textcolor = color.white, size = size.tiny)

f_tablePosition(string selected) => selected == "Top Left" ? position.top_left : selected == "Bottom Right" ? position.bottom_right : selected == "Bottom Left" ? position.bottom_left : position.top_right
f_tableTextSize(string selected) => selected == "Tiny" ? size.tiny : selected == "Normal" ? size.normal : size.small
var table dashboard = table.new(f_tablePosition(dashboardPosition), 9, 7, border_width = 1)

f_pct(int numerator, int denominator) => denominator > 0 ? str.tostring(100.0 * numerator / denominator, "#.0") + "%" : "-"
f_avg(float total, int denominator) => denominator > 0 ? str.tostring(total / denominator, "#.00") : "-"

if barstate.islast
    table.clear(dashboard, 0, 0, 8, 6)

if barstate.islast and showDashboard and displayMode == "Evidence"
    string tableTextSize = f_tableTextSize(dashboardSize)
    color headerBg = color.rgb(31, 41, 55)
    color bodyBg = color.new(color.rgb(17, 24, 39), 8)
    color muted = color.rgb(156, 163, 175)
    string[] headers = array.from("Level", "N", "Reaction", "Break", "False", "Ambig", "Unres", "Avg Rx", "Avg Br")
    for col = 0 to 8
        table.cell(dashboard, col, 0, array.get(headers, col), bgcolor = headerBg, text_color = color.white, text_size = tableTextSize)
    for i = 0 to LEVEL_COUNT - 1
        int samples = array.get(sampleCount, i)
        int directional = array.get(reactionCount, i) + array.get(breakoutCount, i)
        color nameColor = i == 0 ? #EF5350 : i == 1 ? #26A69A : i == 2 ? #AB47BC : #42A5F5
        table.cell(dashboard, 0, i + 1, array.get(levelNames, i), bgcolor = bodyBg, text_color = nameColor, text_size = tableTextSize)
        table.cell(dashboard, 1, i + 1, str.tostring(samples), bgcolor = bodyBg, text_color = samples >= 30 ? color.white : color.yellow, text_size = tableTextSize)
        table.cell(dashboard, 2, i + 1, f_pct(array.get(reactionCount, i), directional), bgcolor = bodyBg, text_color = color.lime, text_size = tableTextSize)
        table.cell(dashboard, 3, i + 1, f_pct(array.get(breakoutCount, i), directional), bgcolor = bodyBg, text_color = color.orange, text_size = tableTextSize)
        table.cell(dashboard, 4, i + 1, f_pct(array.get(falseBreakCount, i), samples), bgcolor = bodyBg, text_color = color.aqua, text_size = tableTextSize)
        table.cell(dashboard, 5, i + 1, f_pct(array.get(ambiguousCount, i), samples), bgcolor = bodyBg, text_color = muted, text_size = tableTextSize)
        table.cell(dashboard, 6, i + 1, f_pct(array.get(unresolvedCount, i), samples), bgcolor = bodyBg, text_color = muted, text_size = tableTextSize)
        table.cell(dashboard, 7, i + 1, f_avg(array.get(reactionExcursionSum, i), samples), bgcolor = bodyBg, text_color = color.white, text_size = tableTextSize)
        table.cell(dashboard, 8, i + 1, f_avg(array.get(breakExcursionSum, i), samples), bgcolor = bodyBg, text_color = color.white, text_size = tableTextSize)
    int activeEvents = 0
    for i = 0 to LEVEL_COUNT - 1
        activeEvents += array.get(eventActive, i) ? 1 : 0
    table.merge_cells(dashboard, 0, 5, 8, 5)
    table.cell(dashboard, 0, 5, "Regime: " + volatilityRegime + " | Active: " + str.tostring(activeEvents), bgcolor = headerBg, text_color = color.white, text_size = tableTextSize)
    table.merge_cells(dashboard, 0, 6, 8, 6)
    table.cell(dashboard, 0, 6, not timeframe.isintraday ? "Designed for intraday charts" : "Yellow N = fewer than 30 observations", bgcolor = color.new(color.black, 8), text_color = not timeframe.isintraday ? color.orange : muted, text_size = tableTextSize)

if barstate.islast and showDashboard and displayMode == "Simple"
    string tableTextSize = f_tableTextSize(dashboardSize)
    color headerBg = color.rgb(31, 41, 55)
    color keyBg = color.new(color.rgb(17, 24, 39), 8)
    color valueBg = color.new(color.rgb(31, 41, 55), 8)
    color muted = color.rgb(156, 163, 175)

    int nearestIndex = -1
    float nearestDistance = na
    int activeIndex = -1
    for i = 0 to LEVEL_COUNT - 1
        float lvl = array.get(levels, i)
        if array.get(enabled, i) and not na(lvl)
            float distance = math.abs(close - lvl)
            if nearestIndex == -1 or distance < nearestDistance
                nearestIndex := i
                nearestDistance := distance
        if array.get(enabled, i) and array.get(eventActive, i)
            activeIndex := i

    int focusIndex = guideRetestIndex >= 0 ? guideRetestIndex : activeIndex >= 0 ? activeIndex : nearestIndex
    string focusName = focusIndex >= 0 ? array.get(levelNames, focusIndex) : "-"
    float focusLevel = focusIndex >= 0 ? array.get(levels, focusIndex) : na
    int samples = focusIndex >= 0 ? array.get(sampleCount, focusIndex) : 0
    int reactions = focusIndex >= 0 ? array.get(reactionCount, focusIndex) : 0
    int breakouts = focusIndex >= 0 ? array.get(breakoutCount, focusIndex) : 0
    int directional = reactions + breakouts
    float reactionPct = directional > 0 ? 100.0 * reactions / directional : na
    float breakoutPct = directional > 0 ? 100.0 * breakouts / directional : na
    bool favorsReaction = not na(reactionPct) and reactionPct >= breakoutPct
    string tendency = directional == 0 ? "Collecting evidence" : favorsReaction ? "Reaction " + str.tostring(reactionPct, "#.0") + "%" : "Breakout " + str.tostring(breakoutPct, "#.0") + "%"
    color tendencyColor = directional == 0 ? muted : favorsReaction ? color.lime : color.orange
    string confidenceWord = samples < 30 ? "low" : samples < 100 ? "fair" : "good"
    int focusRetestState = focusIndex >= 0 ? array.get(retestState, focusIndex) : 0
    int evidenceRegimeCode = focusIndex >= 0 and focusRetestState > 0 ? array.get(retestRegimeCode, focusIndex) : currentRegimeCode
    bool useRegimeEvidence = conditionByVolatility and focusIndex >= 0 and evidenceRegimeCode >= 0
    int regimeStatsIndex = useRegimeEvidence ? focusIndex * 3 + evidenceRegimeCode : -1
    int retestWins = useRegimeEvidence ? array.get(regimeRetestTargetCount, regimeStatsIndex) : focusIndex >= 0 ? array.get(retestTargetCount, focusIndex) : 0
    int retestLosses = useRegimeEvidence ? array.get(regimeRetestInvalidatedCount, regimeStatsIndex) : focusIndex >= 0 ? array.get(retestInvalidatedCount, focusIndex) : 0
    int completedRetests = retestWins + retestLosses
    float retestSuccessPct = completedRetests > 0 ? 100.0 * retestWins / completedRetests : na
    bool retestSampleReady = completedRetests >= minimumRetestSamples
    bool retestEdgeQualified = retestSampleReady and retestSuccessPct >= minimumRetestSuccess
    string evidenceRegimeName = evidenceRegimeCode == 2 ? "High" : evidenceRegimeCode == 0 ? "Low" : evidenceRegimeCode == 1 ? "Normal" : "All"
    string retestEvidence = completedRetests > 0 ? " | " + evidenceRegimeName + " retest " + str.tostring(retestSuccessPct, "#.0") + "% N=" + str.tostring(completedRetests) : " | " + evidenceRegimeName + " retest N=0"
    string evidenceText = tendency + " | N=" + str.tostring(samples) + " (" + confidenceWord + ")" + retestEvidence
    int focusSide = focusIndex >= 0 ? array.get(levelSides, focusIndex) : 0
    bool closedBeyondFocus = focusIndex >= 0 and (focusSide == 1 ? close > focusLevel : close < focusLevel)
    bool focusAlreadyUsed = focusIndex >= 0 and array.get(periodTouched, focusIndex) and activeIndex < 0
    string reactionDirection = focusSide == 1 ? "BEARISH" : "BULLISH"
    string breakoutDirection = focusSide == 1 ? "BULLISH" : "BEARISH"
    string setupText = directional == 0 ? "WAIT - INSUFFICIENT DATA" : favorsReaction ? reactionDirection + " REACTION WATCH" : breakoutDirection + " BREAKOUT WATCH"
    color setupColor = directional == 0 ? muted : favorsReaction ? color.lime : color.orange
    string actionText = ""
    string confirmationText = ""
    string invalidationText = ""
    color actionColor = color.yellow

    if focusIndex < 0
        actionText := "No enabled level"
        confirmationText := "Enable daily or weekly levels"
        invalidationText := "-"
    else if focusRetestState == 5
        setupText := "RETEST TARGET REACHED"
        setupColor := color.lime
        actionText := "PLAN COMPLETE"
        actionColor := color.lime
        confirmationText := "Historical target was reached"
        invalidationText := "Wait for the next level period"
    else if focusRetestState == 6
        setupText := "CONFIRMED RETEST INVALIDATED"
        setupColor := color.red
        actionText := "NO SETUP"
        actionColor := color.red
        confirmationText := "Price did not hold beyond the level"
        invalidationText := "Wait for the next level period"
    else if focusRetestState == 4
        setupText := "RETEST FAILED"
        setupColor := color.red
        actionText := "NO SETUP"
        actionColor := color.red
        confirmationText := "Wait for the next level period"
        invalidationText := "Breakout did not hold"
    else if focusRetestState > 0 and not retestSampleReady
        setupText := "RETEST DATA INSUFFICIENT"
        setupColor := color.orange
        actionText := "OBSERVE ONLY - DO NOT RELY ON EDGE"
        actionColor := color.orange
        confirmationText := str.tostring(completedRetests) + " of " + str.tostring(minimumRetestSamples) + " outcomes collected"
        invalidationText := "Wait for a reliable sample"
    else if focusRetestState > 0 and not retestEdgeQualified
        setupText := "LOW-QUALITY RETEST"
        setupColor := color.red
        actionText := "STAND ASIDE"
        actionColor := color.red
        confirmationText := "Success " + str.tostring(retestSuccessPct, "#.0") + "% below " + str.tostring(minimumRetestSuccess, "#.0") + "%"
        invalidationText := "No statistical edge at current settings"
    else if focusRetestState == 3
        float planTarget = focusLevel + focusSide * breakTargetAtr * array.get(retestAtr, focusIndex)
        float planInvalidation = focusLevel - focusSide * retestToleranceAtr * array.get(retestAtr, focusIndex)
        setupText := breakoutDirection + " RETEST CONFIRMED"
        setupColor := color.lime
        actionText := "CONFIRMED - APPLY YOUR RISK PLAN"
        actionColor := color.lime
        confirmationText := "Reference target " + str.tostring(planTarget, format.mintick)
        invalidationText := (focusSide == 1 ? "Close below " : "Close above ") + str.tostring(planInvalidation, format.mintick)
    else if focusRetestState == 2
        setupText := breakoutDirection + " RETEST IN PROGRESS"
        setupColor := color.yellow
        actionText := "WAIT FOR CONFIRMING CLOSE"
        confirmationText := focusSide == 1 ? "Bullish close back above " + focusName : "Bearish close back below " + focusName
        invalidationText := focusSide == 1 ? "Close below retest zone" : "Close above retest zone"
    else if focusRetestState == 1
        setupText := breakoutDirection + " BREAKOUT - RETEST PENDING"
        setupColor := color.orange
        actionText := "WAIT FOR PRICE TO RETEST " + focusName
        confirmationText := focusSide == 1 ? "Touch zone, then bullish close above" : "Touch zone, then bearish close below"
        invalidationText := focusSide == 1 ? "Close below retest zone" : "Close above retest zone"
    else if focusAlreadyUsed
        actionText := "NO NEW SETUP - event complete"
        confirmationText := "Last result: " + array.get(lastOutcome, focusIndex)
        invalidationText := "Wait for the next level period"
        setupText := "COMPLETED"
        setupColor := muted
    else if activeIndex >= 0
        if favorsReaction
            actionText := closedBeyondFocus ? "WAIT FOR RECLAIM" : "WAIT FOR REJECTION CLOSE"
            confirmationText := focusSide == 1 ? "Close below " + focusName + " and move away" : "Close above " + focusName + " and move away"
            invalidationText := focusSide == 1 ? "Price holds above " + focusName : "Price holds below " + focusName
        else
            actionText := closedBeyondFocus ? "WAIT FOR RETEST / FOLLOW-THROUGH" : "WAIT FOR CLOSE THROUGH " + focusName
            confirmationText := focusSide == 1 ? "Close above " + focusName + " and hold" : "Close below " + focusName + " and hold"
            invalidationText := focusSide == 1 ? "Close back below " + focusName : "Close back above " + focusName
    else
        actionText := "WAIT FOR PRICE TO TEST " + focusName
        confirmationText := favorsReaction ? "Then watch rejection away from level" : "Then watch close through level"
        invalidationText := "No trade before the test"

    table.cell(dashboard, 0, 0, "LEVEL DECISION GUIDE", bgcolor = headerBg, text_color = color.white, text_size = tableTextSize)
    table.cell(dashboard, 1, 0, volatilityRegime + " volatility", bgcolor = headerBg, text_color = muted, text_size = tableTextSize)
    table.cell(dashboard, 0, 1, "Setup", bgcolor = keyBg, text_color = muted, text_size = tableTextSize)
    table.cell(dashboard, 1, 1, setupText, bgcolor = valueBg, text_color = setupColor, text_size = tableTextSize)
    table.cell(dashboard, 0, 2, "Level", bgcolor = keyBg, text_color = muted, text_size = tableTextSize)
    table.cell(dashboard, 1, 2, focusName + (na(focusLevel) ? "" : " @ " + str.tostring(focusLevel, format.mintick)), bgcolor = valueBg, text_color = color.white, text_size = tableTextSize)
    table.cell(dashboard, 0, 3, "Do now", bgcolor = keyBg, text_color = muted, text_size = tableTextSize)
    table.cell(dashboard, 1, 3, actionText, bgcolor = valueBg, text_color = actionColor, text_size = tableTextSize)
    table.cell(dashboard, 0, 4, "Confirmation", bgcolor = keyBg, text_color = muted, text_size = tableTextSize)
    table.cell(dashboard, 1, 4, confirmationText, bgcolor = valueBg, text_color = color.white, text_size = tableTextSize)
    table.cell(dashboard, 0, 5, "Invalidation", bgcolor = keyBg, text_color = muted, text_size = tableTextSize)
    table.cell(dashboard, 1, 5, invalidationText, bgcolor = valueBg, text_color = color.red, text_size = tableTextSize)
    table.cell(dashboard, 0, 6, "Evidence", bgcolor = keyBg, text_color = muted, text_size = tableTextSize)
    table.cell(dashboard, 1, 6, evidenceText, bgcolor = valueBg, text_color = tendencyColor, text_size = tableTextSize)

alertcondition(anyTouch, "First level touch", "A tracked prior-day or prior-week level received its first touch.")
alertcondition(anyReaction, "Reaction outcome", "A level event reached its reaction threshold first.")
alertcondition(anyBreakout, "Breakout outcome", "A level event reached its breakout threshold first.")
alertcondition(anyFalseBreak, "False-break reaction", "A close-through event later reached its reaction threshold first.")
alertcondition(anyAmbiguous, "Ambiguous outcome", "Both thresholds were reached on the same bar; sequence is unknown.")
alertcondition(anyRetestStarted, "Breakout closed - retest pending", "A historically favored breakout closed through its level; wait for a retest.")
alertcondition(anyRetestConfirmed, "Breakout retest confirmed", "A breakout retest touched its zone and produced a confirming close.")
alertcondition(anyRetestFailed, "Breakout retest failed", "A pending breakout retest failed or expired.")
alertcondition(anyRetestTarget, "Confirmed retest target reached", "A confirmed breakout retest reached its ATR-normalized reference target.")
alertcondition(anyRetestInvalidated, "Confirmed retest invalidated", "A confirmed breakout retest closed beyond its invalidation boundary.")

if dynamicAlerts and (anyTouch or anyReaction or anyBreakout or anyFalseBreak or anyAmbiguous or anyRetestStarted or anyRetestConfirmed or anyRetestFailed or anyRetestTarget or anyRetestInvalidated)
    alert("Prior Level Profiler | " + syminfo.ticker + " | " + timeframe.period + " | " + (retestMessage != "" ? retestMessage : eventMessage), alert.freq_once_per_bar_close)
````
