# Break quality: level breaks read against candle structure

- url: https://www.tradingview.com/script/JTSfKKYB-Break-quality-level-breaks-read-against-candle-structure/
- type: indicator
- pine_id: PUB;a89d83f04e77405ebce6ca9a938e32b2
- version: 2.0

## Description

Two bars can close in exactly the same place after taking out a recent high. One is buyers absorbing supply. The other is a trap. This reads the bar that did the breaking to tell them apart.

[b]What it does[/b]

It watches the highest high and lowest low of the last few bars. When price closes beyond one of them, that is a break, and the script then asks two questions about the bar that produced it: did enough volume show up, and did the bar's own shape agree with the direction it just moved.

A break on strong volume with nothing contradicting it is marked as supported. A break on thin volume is marked as unconfirmed. A break where the same bar printed a reversal pattern pointing the other way is marked as contradicted, in its own colour, because that is the case worth stopping on.

[b]Why these things are in one script[/b]

This is not a breakout tool and a pattern scanner merged for convenience. They were two separate scripts and the reason for combining them is that neither answers the question on its own.

A break is a liquidity event. Price trades through a level where resting orders sat, those orders get filled, and the close tells you the level was crossed. It does not tell you who did the crossing or whether they intend to stay. Continuation and a stop run produce the same closing price.

What separates them is visible on the breaking bar itself. Continuation looks like a decisive body with participation behind it. A trap looks like a long rejection wick, or an engulfing bar in the opposite direction, printed on volume that never arrived. That evidence exists for exactly one bar, at exactly one location, and scanning for it independently across the whole chart produces hundreds of marks that have nothing to do with any level.

So the candle structure here is subordinate to the break. It is not reported unless a level was taken. That subordination is the entire design, and it is why this is one script and not two.

There is also a plain engineering reason. Both halves needed relative volume against the same average, and as separate indicators that average was computed twice from identical data on every bar. Here it is computed once and both readings share it.

[b]How it works[/b]

The level is the highest high or lowest low of the prior bars, deliberately excluding the current one. Including it would let the level move with the bar trying to break it, and nothing could ever exceed it.

A break is a close beyond that level. In a trending market a new high is set on almost every bar, so only the first break of a run is treated as an event, and a spacing setting stops a strong trend from covering the chart in labels. Bar colouring stays continuous through the run, so you still see the whole move.

Volume is compared to its own moving average. At or above the strong threshold the break is treated as participated; below one times average it is treated as thin.

The candle structure read covers engulfing, hammer and shooting star, piercing and dark cloud, harami, and harami cross. Each family has its own toggle. A shape pointing against the break direction is what triggers the contradicted reading. The doji used by the harami cross is defined by a body no larger than a set fraction of the bar's range, and that fraction is a setting rather than a hidden constant.

The broken level is drawn forward as a dashed line and removed when price trades back to it, because a level that has been revisited has stopped being a reference.

Everything confirms on bar close by default.

[b]How to use it[/b]

Works on any symbol and timeframe that reports volume.

The reading to act on is not the break itself but the label under it. Supported, unconfirmed and contradicted are three different situations that look identical if you only watch price close beyond a line.

Contradicted breaks are the reason the script exists. A break that prints a reversal shape on its own bar is not automatically a fade, but it is a break that has not yet proven anything, and treating it identically to a supported one is how breakout traders get taken apart.

Raise the lookback for fewer and more significant levels. Raise the spacing setting if a trending instrument is still producing too many marks. Turn the structure read off entirely and it becomes a plain break-and-volume tool with nothing else changed.

[b]What it cannot do[/b]

A contradicted break is a description of one bar, not a forecast. Some traps reverse immediately and some run for days before they do. The label says the evidence on that bar conflicts, and nothing more.

Candlestick patterns are shape definitions with no universally agreed thresholds. The definitions used here are listed above so you can check them against your own rather than trust mine. Piercing and dark cloud are implemented in the strict form requiring a genuine gap beyond the prior bar's extreme, which means they fire rarely on intraday charts where gaps are uncommon.

The level is a recent high or low and nothing more. It carries no weight from prior sessions, no volume profile, no higher timeframe context. A five-bar high on a quiet afternoon and a five-bar high at a weekly extreme are treated identically.

There are no entries, exits, targets or stops in this script, and no performance of any kind is claimed, measured or implied.

[b]On authorship[/b]

Swing breakouts, relative volume and the classic candlestick reversal patterns are all public methodology and I have said so plainly. The implementation is not borrowed. Every line is written from scratch and no code in it is copied or adapted from another author's script, on this platform or anywhere else.

[b]Settings[/b]

Lookback for the level, confirm-on-close and minimum spacing between marked breaks; volume average length and the strong-participation multiple; a master switch for the structure read plus a toggle per pattern family and the doji body fraction; and display options for the level lines, labels, plotted levels, bar colouring, label size and colours.

## Source Code

````pine
//@version=6
// =============================================================================
//  Break quality
//  Confirmed level breaks, contemporaneous evidence, and forward acceptance.
//
//  CORE QUESTION
//  When price closes through a prior range or confirmed pivot, what evidence did
//  the break bar provide, and did price subsequently accept or reject the level?
//
//  THREE SEPARATE CLAIMS
//  1. Event: price confirmed a close beyond a known prior level.
//  2. Initial grade: the break bar was supported, neutral, or contradicted by
//     same-clock participation, close location, penetration, and candle shape.
//  3. Outcome: price either survived a fixed confirmation horizon or closed back
//     through the level. Initial contradiction is never mislabeled as failure.
//
//  DATA INTEGRITY
//  • All events, outcomes, labels, and alerts require confirmed bars.
//  • Rolling levels exclude the current bar. Pivot levels activate only after
//    right-side confirmation and therefore do not repaint.
//  • Current volume is excluded from every baseline. The prior-bar SMA option
//    also excludes the current bar from its denominator.
//  • Same-clock volume history is committed only for complete sessions. Half
//    days, partial first days, missing bars, and early closes are excluded.
//  • One unresolved event per direction prevents cascading trend bars from being
//    counted as independent evidence.
//  • Unresolved events at session boundaries or the chart edge are censored and
//    never counted as wins or losses.
//  • Outcome rates show Wilson intervals and resolved sample size.
//
//  OUTCOME DEFINITION
//  Failure: a confirmed close returns through the broken level +/- tolerance
//  before the evaluation horizon ends.
//  Survival: the horizon ends without such a confirmed close.
//  Target: price reaches the configured ATR extension before resolution.
//
//  TIMEFRAME REQUIREMENTS
//  • Intraday, whole-minute chart timeframes only.
//  • The timeframe must divide the session start and length exactly. For a
//    09:30 to 16:00 session that is 1, 2, 3, 5, 6, 10, 15, or 30 minutes. This
//    follows the session; a session starting on the hour also accepts 20 and 60.
//
//  LIMITATIONS
//  • Survival is structural acceptance, not trade profitability.
//  • A target touch uses bar extremes and does not imply a realizable fill.
//  • Candle definitions are configurable geometry, not universal truths.
//  • Same-clock volume needs complete historical sessions to warm up.
//  • Grades describe the break bar's evidence. They are not trade instructions
//    and nothing here forecasts direction.
//  • Results depend on symbol, timeframe, level model, tolerance, and horizon.
// =============================================================================

indicator("Break quality", shorttitle = "Break Q", overlay = true,
     max_lines_count = 100, max_labels_count = 300)

// Green is the label voice, amber is attention, grey is absence. Nothing here
// encodes direction by hue; every grade also carries its word.
color MZ_GREEN = #54c98a
color MZ_AMBER = #d98a2b
color MZ_LIT   = #f5f4f0
color MZ_LIT2  = #b9b8b2
color MZ_MUTE  = #8b8983
color MZ_INK   = #16181c

groupLevel = "Level detection"
levelMode = input.string("Rolling prior range", "Level model",
     options = ["Rolling prior range", "Confirmed pivots"], group = groupLevel)
lookback = input.int(10, "Rolling prior bars", minval = 2, maxval = 100, group = groupLevel)
pivotLeft = input.int(3, "Pivot left bars", minval = 1, maxval = 20, group = groupLevel, inline = "p")
pivotRight = input.int(3, "Pivot right bars", minval = 1, maxval = 20, group = groupLevel, inline = "p")
toleranceMode = input.string("Ticks", "Break tolerance", options = ["Ticks", "ATR"], group = groupLevel)
toleranceTicks = input.int(1, "Ticks", minval = 0, maxval = 100, group = groupLevel, inline = "t")
toleranceATR = input.float(0.03, "ATR x", minval = 0.0, maxval = 1.0, step = 0.01, group = groupLevel, inline = "t")
minBarsBetween = input.int(5, "Directional cooldown bars", minval = 0, maxval = 100, group = groupLevel)
showSweeps = input.bool(true, "Mark wick sweeps that close back inside", group = groupLevel)

groupSession = "Session"
signalsOnlyInSession = input.bool(true, "Restrict events and evaluation to session", group = groupSession)
tzIn = input.string("America/New_York", "Time zone", group = groupSession)
sStartH = input.int(9, "Start hour", minval = 0, maxval = 23, group = groupSession, inline = "s")
sStartM = input.int(30, "Start minute", minval = 0, maxval = 59, group = groupSession, inline = "s")
sEndH = input.int(16, "End hour", minval = 0, maxval = 23, group = groupSession, inline = "e")
sEndM = input.int(0, "End minute", minval = 0, maxval = 59, group = groupSession, inline = "e")

groupVolume = "Participation"
volumeModel = input.string("Same-clock robust", "Volume baseline",
     options = ["Same-clock robust", "Prior-bar SMA"], group = groupVolume)
volumeSessions = input.int(60, "Same-clock sessions", options = [20, 40, 60, 120], group = groupVolume)
minVolumeSamples = input.int(20, "Minimum same-clock samples", minval = 3, maxval = 120, group = groupVolume)
volumeSMALength = input.int(20, "Prior-bar SMA length", minval = 5, maxval = 200, group = groupVolume)
strongRVOL = input.float(1.50, "Participated RVOL", minval = 1.0, maxval = 5.0, step = 0.05, group = groupVolume)
thinRVOL = input.float(0.80, "Thin RVOL", minval = 0.1, maxval = 1.0, step = 0.05, group = groupVolume)

groupQuality = "Break-bar evidence"
strongCloseLocation = input.float(0.70, "Strong directional close", minval = 0.50, maxval = 1.0, step = 0.05, group = groupQuality)
weakCloseLocation = input.float(0.45, "Contradictory directional close", minval = 0.0, maxval = 0.60, step = 0.05, group = groupQuality)
minimumBodyEfficiency = input.float(0.45, "Minimum body efficiency", minval = 0.0, maxval = 1.0, step = 0.05, group = groupQuality)
minimumPenetrationATR = input.float(0.05, "Minimum close penetration (ATR)", minval = 0.0, maxval = 1.0, step = 0.01, group = groupQuality)
usePatterns = input.bool(true, "Use opposing reversal geometry", group = groupQuality)
showEngulfing = input.bool(true, "Engulfing", group = groupQuality, inline = "p1")
showWickPatterns = input.bool(true, "Hammer / star", group = groupQuality, inline = "p1")
showPiercing = input.bool(true, "Piercing / cloud", group = groupQuality, inline = "p2")
showHarami = input.bool(true, "Harami", group = groupQuality, inline = "p2")
showHaramiCross = input.bool(true, "Harami cross", group = groupQuality)
dojiRatio = input.float(0.10, "Doji body / range", minval = 0.01, maxval = 0.50, step = 0.01, group = groupQuality)

groupOutcome = "Outcome ledger"
evaluationBars = input.int(5, "Acceptance horizon bars", minval = 1, maxval = 50, group = groupOutcome)
targetATR = input.float(0.50, "Extension target (ATR)", minval = 0.10, maxval = 5.0, step = 0.10, group = groupOutcome)
outcomeWindow = input.int(250, "Rolling resolved breaks", options = [50, 100, 250, 500, 1000], group = groupOutcome)
minOutcomeSamples = input.int(20, "Minimum outcomes for emphasis", minval = 5, maxval = 200, group = groupOutcome)

groupDisplay = "Display"
showLines = input.bool(true, "Draw evaluated break levels", group = groupDisplay)
showLabels = input.bool(true, "Label confirmed events", group = groupDisplay)
showLevels = input.bool(true, "Plot watched levels", group = groupDisplay)
colorBars = input.bool(true, "Color event bars", group = groupDisplay)
showTable = input.bool(true, "Show acceptance ledger", group = groupDisplay)
tblSize = input.string(size.tiny, "Table text size", options = [size.tiny, size.small, size.normal], group = groupDisplay)
tblPos = input.string(position.top_right, "Table position",
     options = [position.top_right, position.top_left, position.middle_right, position.middle_left,
                 position.bottom_right, position.bottom_left], group = groupDisplay)

float tfSec = timeframe.in_seconds()
int tfMin = int(math.round(tfSec / 60.0))
string tz = tzIn == "exchange" ? syminfo.timezone : tzIn
int startMin = sStartH * 60 + sStartM
int endMin = sEndH * 60 + sEndM
int sessionMinutes = endMin - startMin
int slotCount = sessionMinutes > 0 and tfMin > 0 ? int(sessionMinutes / tfMin) : 0

if barstate.isfirst
    if not timeframe.isintraday
        runtime.error("Break quality requires an intraday chart. The same-clock volume baseline and session logic have no meaning on daily or higher.")
    if tfSec < 60 or tfSec % 60 != 0
        runtime.error("Use a whole-minute chart timeframe of 1 minute or higher.")
    if endMin <= startMin
        runtime.error("The selected session must end after it starts and cannot cross midnight.")
    if startMin % tfMin != 0 or sessionMinutes % tfMin != 0
        runtime.error("Session start and length must align exactly with the chart timeframe. For a 09:30 to 16:00 session use 1, 2, 3, 5, 6, 10, 15, or 30 minutes.")
    if slotCount > 400
        runtime.error("This configuration creates more than 400 same-clock slots. Shorten the session or increase timeframe.")

int minuteOfDay = hour(time, tz) * 60 + minute(time, tz)
bool inSession = minuteOfDay >= startMin and minuteOfDay < endMin
bool eventWindow = not signalsOnlyInSession or inSession
int sessionId = year(time, tz) * 400 + month(time, tz) * 32 + dayofmonth(time, tz)
bool sessionStartPulse = inSession and (bar_index == 0 or not inSession[1] or sessionId != sessionId[1])
bool sessionEndPulse = bar_index > 0 and not inSession and inSession[1]

float atr = ta.atr(14)
bool atrReady = not na(atr) and atr > 0
float breakTolerance = toleranceMode == "Ticks" ? syminfo.mintick * toleranceTicks : atr * toleranceATR

int numSlots = slotCount
int MAX_VOLUME_HISTORY = 120
var matrix<float> volumeHistory = matrix.new<float>(numSlots, MAX_VOLUME_HISTORY, na)
var array<int> volMeta = array.from(0, 0, 0)
var array<float> stagedVolume = array.new_float(numSlots, na)
var array<int> stagedVolumeBars = array.new_int(numSlots, 0)
var array<float> clockRawScratch = array.new_float()
var array<float> clockLogScratch = array.new_float()
var array<float> clockDevScratch = array.new_float()
var int volumeSession = -1
var bool volumeSessionCommitted = true

volumeHistoryIndex(int age) =>
    int p = array.get(volMeta, 0)
    (p - 1 - age + MAX_VOLUME_HISTORY * 2) % MAX_VOLUME_HISTORY

quantileSorted(array<float> values, float q) =>
    float out = na
    int n = array.size(values)
    if n > 0
        float pos = (n - 1) * q
        int lo = int(math.floor(pos))
        int hi = int(math.ceil(pos))
        float weight = pos - lo
        out := array.get(values, lo) * (1.0 - weight) + array.get(values, hi) * weight
    out

pct(float value) =>
    na(value) ? "—" : str.tostring(math.round(value * 1000.0) / 10.0) + "%"

sameClockBaseline(int slot) =>
    array.clear(clockRawScratch)
    array.clear(clockLogScratch)
    array.clear(clockDevScratch)
    int useN = math.min(array.get(volMeta, 1), volumeSessions)
    if useN > 0
        for age = 0 to useN - 1
            float value = matrix.get(volumeHistory, slot, volumeHistoryIndex(age))
            if not na(value)
                array.push(clockRawScratch, value)
                array.push(clockLogScratch, math.log(1.0 + math.max(0.0, value)))
    array.sort(clockRawScratch)
    array.sort(clockLogScratch)
    int n = array.size(clockRawScratch)
    float medianRaw = quantileSorted(clockRawScratch, 0.50)
    float center = quantileSorted(clockLogScratch, 0.50)
    float spread = na
    if n > 0 and not na(center)
        for i = 0 to n - 1
            array.push(clockDevScratch, math.abs(array.get(clockLogScratch, i) - center))
        array.sort(clockDevScratch)
        spread := quantileSorted(clockDevScratch, 0.50) * 1.4826
        if na(spread) or spread <= 0
            float q1 = quantileSorted(clockLogScratch, 0.25)
            float q3 = quantileSorted(clockLogScratch, 0.75)
            spread := not na(q1) and not na(q3) ? (q3 - q1) / 1.349 : na
    [medianRaw, center, spread, n]

resetVolumeStage() =>
    array.fill(stagedVolume, na)
    array.fill(stagedVolumeBars, 0)

commitVolumeSession() =>
    bool complete = true
    for slot = 0 to numSlots - 1
        complete := complete and array.get(stagedVolumeBars, slot) == 1 and not na(array.get(stagedVolume, slot))
    if complete
        int p = array.get(volMeta, 0)
        for slot = 0 to numSlots - 1
            matrix.set(volumeHistory, slot, p, array.get(stagedVolume, slot))
        array.set(volMeta, 0, (p + 1) % MAX_VOLUME_HISTORY)
        array.set(volMeta, 1, math.min(MAX_VOLUME_HISTORY, array.get(volMeta, 1) + 1))
    complete

int slotNow = inSession ? int(math.floor((minuteOfDay - startMin) / tfMin)) : -1
// varip preserves the baseline computed on the opening update of a live bar.
// Current volume can then update RVOL and z-score on every tick without
// rescanning and resorting the historical same-clock sample.
varip int clockSlotCache = -1
varip int clockNCache = 0
varip float clockMedianCache = na
varip float clockCenterCache = na
varip float clockSpreadCache = na

if barstate.isnew
    clockSlotCache := slotNow
    clockNCache := 0
    clockMedianCache := na
    clockCenterCache := na
    clockSpreadCache := na
    if slotNow >= 0 and slotNow < numSlots
        [medianCache, centerCache, spreadCache, nCache] = sameClockBaseline(slotNow)
        clockMedianCache := medianCache
        clockCenterCache := centerCache
        clockSpreadCache := spreadCache
        clockNCache := nCache

float sameClockRVOL = na
float sameClockZ = na
int sameClockN = 0
if slotNow >= 0 and slotNow == clockSlotCache
    sameClockN := clockNCache
    if clockNCache >= minVolumeSamples and not na(volume)
        sameClockRVOL := not na(clockMedianCache) and clockMedianCache > 0 ? volume / clockMedianCache : na
        sameClockZ := not na(clockCenterCache) and not na(clockSpreadCache) and clockSpreadCache > 0 ?
             (math.log(1.0 + math.max(0.0, volume)) - clockCenterCache) / clockSpreadCache : na

float priorVolumeAverage = ta.sma(volume, volumeSMALength)[1]
float priorBarRVOL = not na(priorVolumeAverage) and priorVolumeAverage > 0 and not na(volume) ? volume / priorVolumeAverage : na
float selectedRVOL = volumeModel == "Same-clock robust" ? sameClockRVOL : priorBarRVOL
float selectedVolumeZ = volumeModel == "Same-clock robust" ? sameClockZ : na
bool volumeReady = not na(selectedRVOL)
bool volumeHeavy = volumeReady and selectedRVOL >= strongRVOL
bool volumeThin = volumeReady and selectedRVOL < thinRVOL

if barstate.isconfirmed
    bool newVolumeSession = inSession and sessionId != volumeSession
    if newVolumeSession
        if volumeSession != -1 and not volumeSessionCommitted
            array.set(volMeta, 2, array.get(volMeta, 2) + 1)
        resetVolumeStage()
        volumeSession := sessionId
        volumeSessionCommitted := false

    if inSession and sessionId == volumeSession and slotNow >= 0 and slotNow < numSlots
        array.set(stagedVolumeBars, slotNow, array.get(stagedVolumeBars, slotNow) + 1)
        if not na(volume)
            array.set(stagedVolume, slotNow, volume)
        if minuteOfDay + tfMin >= endMin and not volumeSessionCommitted
            bool acceptedVolumeSession = commitVolumeSession()
            if not acceptedVolumeSession
                array.set(volMeta, 2, array.get(volMeta, 2) + 1)
            volumeSessionCommitted := true

float rollingHigh = ta.highest(high[1], lookback)
float rollingLow = ta.lowest(low[1], lookback)
float pivotHighFound = ta.pivothigh(high, pivotLeft, pivotRight)
float pivotLowFound = ta.pivotlow(low, pivotLeft, pivotRight)
var float confirmedPivotHigh = na
var float confirmedPivotLow = na
var bool pivotHighConsumed = false
var bool pivotLowConsumed = false

if barstate.isconfirmed and not na(pivotHighFound)
    confirmedPivotHigh := pivotHighFound
    pivotHighConsumed := false
if barstate.isconfirmed and not na(pivotLowFound)
    confirmedPivotLow := pivotLowFound
    pivotLowConsumed := false

float watchedHigh = levelMode == "Rolling prior range" ? rollingHigh : confirmedPivotHigh
float watchedLow = levelMode == "Rolling prior range" ? rollingLow : confirmedPivotLow

float candleRange = high - low
float body = math.abs(close - open)
float bodyPrevious = math.abs(close[1] - open[1])
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float closeLocationUp = candleRange > 0 ? (close - low) / candleRange : 0.5
float closeLocationDown = candleRange > 0 ? (high - close) / candleRange : 0.5
float bodyEfficiency = candleRange > 0 ? body / candleRange : 0.0
bool doji = candleRange > 0 and body <= dojiRatio * candleRange

bool bullishEngulfing = showEngulfing and close > open and close[1] < open[1] and body > bodyPrevious and open <= close[1] and close >= open[1]
bool bearishEngulfing = showEngulfing and close < open and close[1] > open[1] and body > bodyPrevious and open >= close[1] and close <= open[1]
bool hammer = showWickPatterns and body > 0 and lowerWick >= 2.0 * body and upperWick <= body
bool shootingStar = showWickPatterns and body > 0 and upperWick >= 2.0 * body and lowerWick <= body
bool piercing = showPiercing and close[1] < open[1] and close > open and open < low[1] and close >= (open[1] + close[1]) / 2.0
bool darkCloud = showPiercing and close[1] > open[1] and close < open and open > high[1] and close <= (open[1] + close[1]) / 2.0
bool bullishHarami = showHarami and close[1] < open[1] and close > open and open > close[1] and close < open[1]
bool bearishHarami = showHarami and close[1] > open[1] and close < open and open < close[1] and close > open[1]
bool bullishHaramiCross = showHaramiCross and close[1] < open[1] and doji and math.max(open, close) < open[1] and math.min(open, close) > close[1]
bool bearishHaramiCross = showHaramiCross and close[1] > open[1] and doji and math.max(open, close) < close[1] and math.min(open, close) > open[1]
bool bullishShape = usePatterns and (bullishEngulfing or hammer or piercing or bullishHarami or bullishHaramiCross)
bool bearishShape = usePatterns and (bearishEngulfing or shootingStar or darkCloud or bearishHarami or bearishHaramiCross)

shapeName(bool upBreak) =>
    string out = ""
    if upBreak
        out := bearishEngulfing ? "bearish engulfing" : shootingStar ? "shooting star" :
             darkCloud ? "dark cloud" : bearishHarami ? "bearish harami" :
             bearishHaramiCross ? "bearish harami cross" : ""
    else
        out := bullishEngulfing ? "bullish engulfing" : hammer ? "hammer" :
             piercing ? "piercing" : bullishHarami ? "bullish harami" :
             bullishHaramiCross ? "bullish harami cross" : ""
    out

// Grade codes: 0 contradicted, 1 neutral, 2 supported.
gradeBreak(bool upBreak, float level) =>
    float directionalClose = upBreak ? closeLocationUp : closeLocationDown
    float penetration = not na(atr) and atr > 0 ? (upBreak ? close - level : level - close) / atr : 0.0
    bool opposing = upBreak ? bearishShape : bullishShape
    bool contradicted = opposing or directionalClose <= weakCloseLocation
    bool supported = volumeHeavy and directionalClose >= strongCloseLocation and
         bodyEfficiency >= minimumBodyEfficiency and penetration >= minimumPenetrationATR and not opposing
    contradicted ? 0 : supported ? 2 : 1

gradeText(int grade) =>
    grade == 2 ? "supported" : grade == 1 ? "neutral" : "contradicted"

// Green marks the fully supported grade, amber marks contradiction, grey is the
// unremarkable middle. The word is always present beside the colour.
gradeColor(int grade) =>
    grade == 2 ? MZ_GREEN : grade == 1 ? MZ_LIT2 : MZ_AMBER

bool validHighLevel = not na(watchedHigh)
bool validLowLevel = not na(watchedLow)
bool crossedHigh = barstate.isconfirmed and eventWindow and atrReady and validHighLevel and
     close > watchedHigh + breakTolerance and close[1] <= watchedHigh + breakTolerance
bool crossedLow = barstate.isconfirmed and eventWindow and atrReady and validLowLevel and
     close < watchedLow - breakTolerance and close[1] >= watchedLow - breakTolerance

if levelMode == "Confirmed pivots"
    crossedHigh := crossedHigh and not pivotHighConsumed
    crossedLow := crossedLow and not pivotLowConsumed

bool sweptHigh = barstate.isconfirmed and eventWindow and atrReady and showSweeps and validHighLevel and
     high > watchedHigh + breakTolerance and close <= watchedHigh and high[1] <= watchedHigh + breakTolerance
bool sweptLow = barstate.isconfirmed and eventWindow and atrReady and showSweeps and validLowLevel and
     low < watchedLow - breakTolerance and close >= watchedLow and low[1] >= watchedLow - breakTolerance

type ActiveEvent
    bool active
    float level
    float anchorATR
    float tolerance
    int startBar
    int grade
    float mfe
    float mae
    bool targetHit
    line guide
    int lastMarkBar

newActiveEvent() =>
    ActiveEvent.new(false, na, na, na, -1, 1, 0.0, 0.0, false, na, -1000000)

var array<ActiveEvent> activeEvents = array.from(newActiveEvent(), newActiveEvent())

int BREAK_LABEL_MAX = 240
int RESOLVED_LINE_MAX = 90
var array<label> breakLabels = array.new<label>()
var array<line> resolvedLines = array.new<line>()

manageBreakLabel(label id) =>
    if not na(id)
        array.push(breakLabels, id)
        if array.size(breakLabels) > BREAK_LABEL_MAX
            label.delete(array.shift(breakLabels))

manageResolvedLine(line id) =>
    if not na(id)
        array.push(resolvedLines, id)
        if array.size(resolvedLines) > RESOLVED_LINE_MAX
            line.delete(array.shift(resolvedLines))

int MAX_OUTCOMES = 1000
var matrix<float> outcomeHistory = matrix.new<float>(7, MAX_OUTCOMES, na)
var array<int> outcomeMeta = array.from(0, 0, 0)
var array<float> outcomeMfeScratch = array.new_float()
var array<float> outcomeMaeScratch = array.new_float()

recordOutcome(int grade, int direction, bool survived, bool targetHit, int duration, float mfeATR, float maeATR) =>
    int p = array.get(outcomeMeta, 0)
    matrix.set(outcomeHistory, 0, p, float(grade))
    matrix.set(outcomeHistory, 1, p, float(direction))
    matrix.set(outcomeHistory, 2, p, survived ? 1.0 : 0.0)
    matrix.set(outcomeHistory, 3, p, targetHit ? 1.0 : 0.0)
    matrix.set(outcomeHistory, 4, p, float(duration))
    matrix.set(outcomeHistory, 5, p, mfeATR)
    matrix.set(outcomeHistory, 6, p, maeATR)
    array.set(outcomeMeta, 0, (p + 1) % MAX_OUTCOMES)
    array.set(outcomeMeta, 1, math.min(MAX_OUTCOMES, array.get(outcomeMeta, 1) + 1))

outcomeIndex(int age) =>
    int p = array.get(outcomeMeta, 0)
    (p - 1 - age + MAX_OUTCOMES * 2) % MAX_OUTCOMES

finishLine(int index, color resultColor, string resultStyle) =>
    ActiveEvent state = array.get(activeEvents, index)
    line ln = state.guide
    if not na(ln)
        line.set_x2(ln, bar_index)
        line.set_color(ln, resultColor)
        line.set_style(ln, resultStyle)
        manageResolvedLine(ln)
        state.guide := na

censorActiveEvents() =>
    for i = 0 to 1
        ActiveEvent state = array.get(activeEvents, i)
        if state.active
            finishLine(i, color.new(MZ_MUTE, 60), line.style_dotted)
            state.active := false
            array.set(outcomeMeta, 2, array.get(outcomeMeta, 2) + 1)

if barstate.isconfirmed and signalsOnlyInSession and (sessionStartPulse or sessionEndPulse)
    censorActiveEvents()

bool resolvedSurvivalPulse = false
bool resolvedFailurePulse = false
if barstate.isconfirmed
    for i = 0 to 1
        ActiveEvent state = array.get(activeEvents, i)
        if state.active and (not signalsOnlyInSession or inSession)
            int direction = i == 0 ? 1 : -1
            float level = state.level
            float atrAtEvent = state.anchorATR
            float toleranceAtEvent = state.tolerance
            int age = bar_index - state.startBar
            float favorable = direction == 1 ? high - level : level - low
            float adverse = direction == 1 ? level - low : high - level
            float mfe = atrAtEvent > 0 ? math.max(0.0, favorable) / atrAtEvent : 0.0
            float mae = atrAtEvent > 0 ? math.max(0.0, adverse) / atrAtEvent : 0.0
            bool failed = direction == 1 ? close < level - toleranceAtEvent : close > level + toleranceAtEvent
            // A failure bar may touch both the target and invalidation intrabar.
            // OHLC cannot reveal which happened first, so it receives no new MFE
            // or target credit. MAE still records the observed adverse excursion.
            if failed
                state.mae := math.max(state.mae, mae)
            else
                state.mfe := math.max(state.mfe, mfe)
                state.mae := math.max(state.mae, mae)
                state.targetHit := state.targetHit or mfe >= targetATR
            bool targetHit = state.targetHit
            bool horizonDone = age >= evaluationBars

            if failed or horizonDone
                bool survived = not failed
                recordOutcome(state.grade, direction, survived, targetHit, age, state.mfe, state.mae)
                resolvedSurvivalPulse := resolvedSurvivalPulse or survived
                resolvedFailurePulse := resolvedFailurePulse or failed
                finishLine(i, survived ? color.new(MZ_GREEN, 20) : color.new(MZ_LIT2, 25), line.style_solid)
                state.active := false

ActiveEvent upEvent = array.get(activeEvents, 0)
ActiveEvent downEvent = array.get(activeEvents, 1)
bool cooldownUp = bar_index - upEvent.lastMarkBar >= minBarsBetween
bool cooldownDown = bar_index - downEvent.lastMarkBar >= minBarsBetween
bool markAbove = crossedHigh and cooldownUp and not upEvent.active
bool markBelow = crossedLow and cooldownDown and not downEvent.active
int gradeAbove = markAbove ? gradeBreak(true, watchedHigh) : na
int gradeBelow = markBelow ? gradeBreak(false, watchedLow) : na

startEvent(int index, int grade, float level) =>
    ActiveEvent state = array.get(activeEvents, index)
    state.active := true
    state.level := level
    state.anchorATR := atr
    state.tolerance := breakTolerance
    state.startBar := bar_index
    state.grade := grade
    state.mfe := 0.0
    state.mae := 0.0
    state.targetHit := false
    state.lastMarkBar := bar_index
    if showLines
        line ln = line.new(bar_index, level, bar_index + 1, level, color = color.new(gradeColor(grade), 25),
             style = line.style_dashed, width = 1)
        state.guide := ln

if markAbove
    startEvent(0, gradeAbove, watchedHigh)
    if levelMode == "Confirmed pivots"
        pivotHighConsumed := true
if markBelow
    startEvent(1, gradeBelow, watchedLow)
    if levelMode == "Confirmed pivots"
        pivotLowConsumed := true

if barstate.isconfirmed
    for i = 0 to 1
        ActiveEvent state = array.get(activeEvents, i)
        line ln = state.guide
        if state.active and not na(ln)
            line.set_x2(ln, bar_index)

volumeText() =>
    string out = volumeReady ? str.tostring(selectedRVOL, "0.00") + "x RVOL" : "volume warming"
    if not na(selectedVolumeZ)
        out += " · z " + str.tostring(selectedVolumeZ, "0.00")
    if not barstate.isconfirmed
        out += " · provisional"
    out

if showLabels and (markAbove or markBelow)
    bool up = markAbove
    int grade = up ? gradeAbove : gradeBelow
    float level = up ? watchedHigh : watchedLow
    float directionalClose = up ? closeLocationUp : closeLocationDown
    float penetration = atr > 0 ? (up ? close - level : level - close) / atr : 0.0
    string pattern = shapeName(up)
    string labelText = (up ? "break up" : "break down") + " · " + gradeText(grade) +
         "\n" + volumeText() + " · close " + pct(directionalClose) +
         "\npenetration " + str.tostring(penetration, "0.00") + " ATR" +
         (pattern == "" ? "" : "\n" + pattern)
    label breakLabel = label.new(bar_index, up ? low : high, labelText,
         style = up ? label.style_label_up : label.style_label_down,
         color = color.new(gradeColor(grade), 15), textcolor = MZ_INK, size = size.tiny)
    manageBreakLabel(breakLabel)

// Sweep annotations have constant text, so plots preserve the full loaded
// history without consuming the finite label-object budget.
plotshape(showLabels and sweptHigh and not markAbove, title = "High sweep annotation",
     style = shape.labeldown, location = location.abovebar, color = color.new(MZ_AMBER, 20),
     text = "sweep", textcolor = MZ_INK, size = size.tiny)
plotshape(showLabels and sweptLow and not markBelow, title = "Low sweep annotation",
     style = shape.labelup, location = location.belowbar, color = color.new(MZ_AMBER, 20),
     text = "sweep", textcolor = MZ_INK, size = size.tiny)

plot(showLevels ? watchedHigh : na, "Watched high", color = color.new(MZ_LIT2, 70), style = plot.style_circles)
plot(showLevels ? watchedLow : na, "Watched low", color = color.new(MZ_LIT2, 70), style = plot.style_circles)

color eventBarColor = na
if colorBars
    eventBarColor := markAbove ? gradeColor(gradeAbove) : markBelow ? gradeColor(gradeBelow) :
         sweptHigh or sweptLow ? MZ_AMBER : na
barcolor(eventBarColor, title = "Confirmed break/sweep bars")

wilsonBounds(int successes, int trials) =>
    float lo = na
    float hi = na
    if trials > 0
        float z = 1.95996398454
        float n = trials
        float p = successes / n
        float den = 1.0 + z * z / n
        float center = (p + z * z / (2.0 * n)) / den
        float margin = z * math.sqrt((p * (1.0 - p) + z * z / (4.0 * n)) / n) / den
        lo := math.max(0.0, center - margin)
        hi := math.min(1.0, center + margin)
    [lo, hi]

outcomeStats(int grade) =>
    int n = 0
    int survived = 0
    int targeted = 0
    array.clear(outcomeMfeScratch)
    array.clear(outcomeMaeScratch)
    int useN = math.min(array.get(outcomeMeta, 1), outcomeWindow)
    if useN > 0
        for age = 0 to useN - 1
            int idx = outcomeIndex(age)
            if int(matrix.get(outcomeHistory, 0, idx)) == grade
                n += 1
                survived += int(matrix.get(outcomeHistory, 2, idx))
                targeted += int(matrix.get(outcomeHistory, 3, idx))
                array.push(outcomeMfeScratch, matrix.get(outcomeHistory, 5, idx))
                array.push(outcomeMaeScratch, matrix.get(outcomeHistory, 6, idx))
    array.sort(outcomeMfeScratch)
    array.sort(outcomeMaeScratch)
    float medianMFE = quantileSorted(outcomeMfeScratch, 0.50)
    float medianMAE = quantileSorted(outcomeMaeScratch, 0.50)
    [n, survived, targeted, medianMFE, medianMAE]

// Cached aggregation. Resolved statistics are rebuilt once after the initial
// historical pass and thereafter only on a closing update that resolves an
// event. The table itself may still redraw intrabar using these stable values.
var array<int> ledgerN = array.new_int(3, 0)
var array<int> ledgerSurvived = array.new_int(3, 0)
var array<int> ledgerTargeted = array.new_int(3, 0)
var array<float> ledgerMedMFE = array.new_float(3, na)
var array<float> ledgerMedMAE = array.new_float(3, na)
var bool ledgerStatsReady = false

bool refreshLedgerStats = barstate.islastconfirmedhistory or
     (barstate.islast and barstate.isconfirmed and (resolvedSurvivalPulse or resolvedFailurePulse))

if showTable and refreshLedgerStats
    for grade = 0 to 2
        [nCache, survivedCache, targetedCache, medMFECache, medMAECache] = outcomeStats(grade)
        array.set(ledgerN, grade, nCache)
        array.set(ledgerSurvived, grade, survivedCache)
        array.set(ledgerTargeted, grade, targetedCache)
        array.set(ledgerMedMFE, grade, medMFECache)
        array.set(ledgerMedMAE, grade, medMAECache)
    ledgerStatsReady := true

var table ledger = table.new(tblPos, 6, 6, border_width = 1, frame_width = 1,
     frame_color = color.new(MZ_MUTE, 50), border_color = color.new(MZ_MUTE, 75))
var bool ledgerMerged = false

if barstate.islast
    if showTable
        string activeText = "no active break"
        ActiveEvent tableUpEvent = array.get(activeEvents, 0)
        ActiveEvent tableDownEvent = array.get(activeEvents, 1)
        if tableUpEvent.active or tableDownEvent.active
            string upText = tableUpEvent.active ? "up " + gradeText(tableUpEvent.grade) +
                 " · age " + str.tostring(bar_index - tableUpEvent.startBar) : ""
            string downText = tableDownEvent.active ? "down " + gradeText(tableDownEvent.grade) +
                 " · age " + str.tostring(bar_index - tableDownEvent.startBar) : ""
            activeText := upText + (upText != "" and downText != "" ? " | " : "") + downText
        activeText += "  ·  " + volumeText()
        activeText += "  ·  " + str.tostring(array.get(outcomeMeta, 2)) + " censored"

        table.cell(ledger, 0, 0, "Break acceptance ledger", text_size = tblSize,
             text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(ledger, 0, 1, activeText, text_size = tblSize, text_color = MZ_AMBER, bgcolor = MZ_INK,
             tooltip = "Resolved outcomes only. Censored current and session-edge events are excluded.")
        if not ledgerMerged
            table.merge_cells(ledger, 0, 0, 5, 0)
            table.merge_cells(ledger, 0, 1, 5, 1)
            ledgerMerged := true

        table.cell(ledger, 0, 2, "Initial grade", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(ledger, 1, 2, "Resolved", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(ledger, 2, 2, "Survival", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Share of resolved breaks of this grade that completed the horizon without closing back through the level, with a 95% Wilson interval.")
        table.cell(ledger, 3, 2, "Target", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(ledger, 4, 2, "Med MFE", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(ledger, 5, 2, "Med MAE", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)

        for grade = 0 to 2
            int n = ledgerStatsReady ? array.get(ledgerN, grade) : 0
            int survived = ledgerStatsReady ? array.get(ledgerSurvived, grade) : 0
            int targeted = ledgerStatsReady ? array.get(ledgerTargeted, grade) : 0
            float medMFE = ledgerStatsReady ? array.get(ledgerMedMFE, grade) : na
            float medMAE = ledgerStatsReady ? array.get(ledgerMedMAE, grade) : na
            float survivalRate = n > 0 ? survived / float(n) : na
            float targetRate = n > 0 ? targeted / float(n) : na
            [survivalLo, survivalHi] = wilsonBounds(survived, n)
            string survivalText = n > 0 ? pct(survivalRate) + "\n" + pct(survivalLo) + "-" + pct(survivalHi) : "—"
            color sampleColor = n >= minOutcomeSamples ? MZ_LIT : MZ_MUTE
            int row = grade + 3
            table.cell(ledger, 0, row, gradeText(grade), text_size = tblSize,
                 text_color = gradeColor(grade), bgcolor = MZ_INK)
            table.cell(ledger, 1, row, str.tostring(n), text_size = tblSize, text_color = sampleColor, bgcolor = MZ_INK)
            table.cell(ledger, 2, row, survivalText, text_size = tblSize, text_color = sampleColor, bgcolor = MZ_INK)
            table.cell(ledger, 3, row, pct(targetRate), text_size = tblSize, text_color = sampleColor, bgcolor = MZ_INK)
            table.cell(ledger, 4, row, na(medMFE) ? "—" : str.tostring(medMFE, "0.00") + " ATR",
                 text_size = tblSize, text_color = sampleColor, bgcolor = MZ_INK)
            table.cell(ledger, 5, row, na(medMAE) ? "—" : str.tostring(medMAE, "0.00") + " ATR",
                 text_size = tblSize, text_color = sampleColor, bgcolor = MZ_INK)
    else
        table.clear(ledger, 0, 0, 5, 5)

alertcondition(markAbove, "Confirmed break above", "Price confirmed a close above the watched level.")
alertcondition(markBelow, "Confirmed break below", "Price confirmed a close below the watched level.")
alertcondition(markAbove and gradeAbove == 2, "Supported break above", "Break above met all configured participation and structure requirements.")
alertcondition(markBelow and gradeBelow == 2, "Supported break below", "Break below met all configured participation and structure requirements.")
alertcondition(markAbove and gradeAbove == 0, "Contradicted break above", "Break above carried opposing break-bar evidence.")
alertcondition(markBelow and gradeBelow == 0, "Contradicted break below", "Break below carried opposing break-bar evidence.")
alertcondition(sweptHigh and not markAbove, "High sweep", "Price swept above the watched high and closed back inside.")
alertcondition(sweptLow and not markBelow, "Low sweep", "Price swept below the watched low and closed back inside.")
alertcondition(resolvedSurvivalPulse, "Break survived horizon", "An evaluated break completed its configured horizon without closing back through the level.")
alertcondition(resolvedFailurePulse, "Break acceptance failed", "An evaluated break closed back through its frozen level tolerance before the horizon ended.")
````
