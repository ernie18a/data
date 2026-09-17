<!-- tradingview-pine-id: PUB;ac9e484a1f0e4641b4043313a8e8dbe5 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Time-of-day volume normalizer

Source: https://www.tradingview.com/script/XfIwYG1Z-Time-of-day-volume-normalizer/

## Description

High volume at 9:31 is not high volume. See each bar against its own time of day.

Description

Raw volume is not comparable across the trading day. The first minutes of the regular session routinely print several times the volume of a midday bar, so reading "high volume" off the raw histogram usually just tells you that it is early in the session. Most relative volume tools compare a bar against a trailing average of the last N bars regardless of clock time, which carries the same problem forward.

This compares each bar's volume only against the same clock time on prior sessions, and returns the result as a z-score.

How it calculates

Every bar is assigned to a time slot from its minute of the day, in the time zone you choose, and the chart timeframe. Each slot keeps an independent rolling history of volume, one observation per prior session. For the current bar the script reads that slot's cached center and spread and returns how far current volume sits from the center in spread units. The cache is refreshed only when the slot receives a new observation, so the current bar is never part of its own baseline. Median with median absolute deviation, scaled by 1.4826, is the default. Mean with population standard deviation is the alternative.

How to read it

A reading of 0 means this bar is doing what this time of day normally does. A reading of +2 means it is two spread units above its own slot's history. Green marks readings above the norm, amber marks unusually high, and a lighter grey marks unusually quiet. The pane shades faintly while a slot is still warming or has no spread. The table shows the current slot, its warmup state, its norm, and the current reading.

Repainting

Closed bars do not repaint. The live bar updates until it closes. History is written on confirmed bars only.

Originality and attribution

The z-score is textbook. What is original here is the slot-keyed baseline: one independent rolling history per minute-of-day bucket, with the current bar excluded from its own baseline, and per-slot statistics cached and recomputed only when that slot's history changes. This is not derived from and does not reuse code from any existing published script.

Honest limitations

Nothing plots until a slot reaches the minimum sample count. The table reports warmup progress.
If a slot's stored volumes are near-identical the spread collapses to zero and no z-score is defined. The table reports this as flat.
Half days, holidays, and session changes pollute a slot's history.
Futures roll and contract changes shift volume levels.
Slots and the session filter both key to the time zone you choose.
Requires an intraday timeframe of 1 minute or higher and a symbol that reports volume.
This is not a signal, it says nothing about direction, and a high reading is not inherently bullish or bearish.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  Time-of-day volume normalizer
//  Same-clock-time relative volume with robust, session-consistent baselines.
//
//  CORE QUESTION
//  Is this completed bar's volume unusual for this exact time slot, on this
//  instrument and timeframe, relative to prior complete sessions?
//
//  DATA INTEGRITY
//  • Confirmed bars only enter the plotted anomaly series and alerts.
//  • The live table may show a clearly labeled provisional estimate, but a
//    partial live bar is never presented as a completed-bar observation.
//  • Prior sessions are committed atomically only when every expected session
//    slot is present. Partial first days, early closes, half days, and data gaps
//    are excluded from every slot together.
//  • Every slot therefore uses the same set of historical sessions. The 10:00
//    baseline cannot silently represent different dates from the 14:00 baseline.
//  • The current session remains excluded from every baseline until it completes.
//  • Session boundaries and chart timeframe must align exactly. No bar can leak
//    across adjacent clock slots.
//  • Log-volume modeling is the default to reduce positive skew and contract-roll
//    scale shocks. Raw-volume modeling remains available explicitly.
//  • Robust mode uses median/MAD and falls back to IQR/1.349 when MAD collapses.
//  • Extreme plotted z-scores are capped visually without altering raw table,
//    data-window, or alert values.
//
//  OUTPUTS
//  Z-score     standardized distance from the slot-specific center.
//  RVOL        current volume / historical slot median.
//  Percentile  mid-rank of current volume within that slot's history.
//  IQR         historical 25th-75th percentile raw-volume interval.
//
//  LIMITATIONS
//  • Nothing here is a signal. This describes participation, not direction:
//    high volume is not bullish and low volume is not bearish.
//  • Z-scores are descriptive. Volume distributions are not perfectly normal.
//  • A full-session baseline intentionally excludes early-close sessions rather
//    than attempting to infer missing afternoon activity.
//  • A session cannot cross midnight in the selected time zone.
//  • Slots multiplied by the rolling window is bounded to protect execution time.
//
//  TIMEFRAME REQUIREMENTS
//  • Intraday, whole-minute timeframes only.
//  • The timeframe must divide the session start and length exactly. For a
//    09:30 to 16:00 session that is 1, 2, 3, 5, 6, 10, 15, or 30 minutes. This
//    follows the session, it is not a fixed ceiling: a session starting on the
//    hour also accepts 20 and 60 minutes.
//  • Slots multiplied by rolling sessions is capped at 25,000. A 390-minute
//    session on 1 minute therefore supports 60 rolling sessions; on 5 minutes
//    it supports the full 250.
// =============================================================================

indicator("Time-of-day volume normalizer", shorttitle = "TOD Vol", overlay = false, precision = 2)

color MZ_GREEN = #54c98a
color MZ_AMBER = #d98a2b
color MZ_LIT   = #f5f4f0
color MZ_LIT2  = #b9b8b2
color MZ_MUTE  = #8b8983
color MZ_INK   = #16181c

groupSession = "Session"
tzIn = input.string("America/New_York", "Time zone", group = groupSession,
     tooltip = "Use an IANA time zone. Enter exchange to use the symbol's exchange time zone.")
sStartH = input.int(9, "Start hour", minval = 0, maxval = 23, group = groupSession, inline = "s")
sStartM = input.int(30, "Start minute", minval = 0, maxval = 59, group = groupSession, inline = "s")
sEndH = input.int(16, "End hour", minval = 0, maxval = 23, group = groupSession, inline = "e")
sEndM = input.int(0, "End minute", minval = 0, maxval = 59, group = groupSession, inline = "e")

groupModel = "Baseline"
historyWindow = input.int(60, "Rolling complete sessions", options = [20, 40, 60, 120, 250], group = groupModel)
minSamples = input.int(20, "Minimum complete sessions", minval = 3, maxval = 250, group = groupModel)
scaleMode = input.string("Log volume", "Scale", options = ["Log volume", "Raw volume"], group = groupModel,
     tooltip = "Log volume is usually superior because raw volume is strongly right-skewed.")
centerMode = input.string("Median / MAD", "Estimator", options = ["Median / MAD", "Mean / StdDev"], group = groupModel,
     tooltip = "Median/MAD is robust to abnormal sessions. If MAD is zero, the engine falls back to IQR/1.349.")

groupDisplay = "Display"
plotCap = input.float(5.0, "Visual z-score cap", minval = 2.0, maxval = 10.0, step = 0.5, group = groupDisplay,
     tooltip = "Only the plotted column is capped. Table, alerts, and Data Window retain the uncapped value.")
alertThreshold = input.float(2.0, "Anomaly alert threshold", minval = 1.0, maxval = 6.0, step = 0.25, group = groupDisplay)
shadeUnavailable = input.bool(true, "Shade warming or flat slots", group = groupDisplay)
showTable = input.bool(true, "Show slot detail", group = groupDisplay)
tblSize = input.string(size.small, "Table text size", options = [size.tiny, size.small, size.normal], group = groupDisplay)
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
        runtime.error("Time-of-day volume normalizer requires an intraday chart. Comparing a bar against the same clock time has no meaning on daily or higher.")
    if tfSec < 60 or tfSec % 60 != 0
        runtime.error("Use a whole-minute chart timeframe of 1 minute or higher.")
    if endMin <= startMin
        runtime.error("The selected session must end after it starts and cannot cross midnight.")
    if startMin % tfMin != 0 or sessionMinutes % tfMin != 0
        runtime.error("Session start and length must align exactly with the chart timeframe. For a 09:30 to 16:00 session use 1, 2, 3, 5, 6, 10, 15, or 30 minutes.")
    if slotCount > 400
        runtime.error("This configuration creates more than 400 time slots. Shorten the session or increase chart timeframe.")
    if slotCount * historyWindow > 25000
        runtime.error("Slots multiplied by the rolling window exceeds the execution budget. Reduce the rolling session count or increase the chart timeframe. A 390-minute session on 1 minute supports 60 sessions; on 5 minutes it supports 250.")

int numSlots = slotCount
int MAX_HISTORY = 250

int hh = hour(time, tz)
int mm = minute(time, tz)
int minuteOfDay = hh * 60 + mm
bool inSession = minuteOfDay >= startMin and minuteOfDay < endMin
int slotNow = inSession ? int(math.floor((minuteOfDay - startMin) / tfMin)) : -1
int sessionId = year(time, tz) * 400 + month(time, tz) * 32 + dayofmonth(time, tz)

var matrix<float> volumeHistory = matrix.new<float>(numSlots, MAX_HISTORY, na)
var array<int> meta = array.from(0, 0, 0)
var array<float> stagedVolume = array.new_float(numSlots, na)
var array<int> stagedBars = array.new_int(numSlots, 0)
var int activeSession = -1
var bool sessionCommitted = true

pad2(int n) =>
    n < 10 ? "0" + str.tostring(n) : str.tostring(n)

slotLabel(int slot) =>
    int mins = startMin + slot * tfMin
    pad2(int(math.floor(mins / 60))) + ":" + pad2(mins % 60)

historyIndex(int age) =>
    int p = array.get(meta, 0)
    (p - 1 - age + MAX_HISTORY * 2) % MAX_HISTORY

usableSessions() =>
    math.min(array.get(meta, 1), historyWindow)

transformVolume(float value) =>
    scaleMode == "Log volume" ? math.log(1.0 + math.max(0.0, value)) : value

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

// Reusable workspaces. Rebuilding three arrays on every bar was the single
// largest avoidable cost on long intraday histories.
var array<float> rawScratch = array.new_float()
var array<float> modelScratch = array.new_float()
var array<float> devScratch = array.new_float()

slotStats(int slot, float currentVolume) =>
    array.clear(rawScratch)
    array.clear(modelScratch)
    float sum = 0.0
    float sumSquares = 0.0
    int less = 0
    int equal = 0
    int useN = usableSessions()

    if useN > 0
        for age = 0 to useN - 1
            float raw = matrix.get(volumeHistory, slot, historyIndex(age))
            if not na(raw)
                float modeled = transformVolume(raw)
                array.push(rawScratch, raw)
                array.push(modelScratch, modeled)
                sum += modeled
                sumSquares += modeled * modeled
                if not na(currentVolume)
                    if raw < currentVolume
                        less += 1
                    else if raw == currentVolume
                        equal += 1

    array.sort(rawScratch)
    array.sort(modelScratch)
    int n = array.size(rawScratch)
    float rawQ1 = quantileSorted(rawScratch, 0.25)
    float rawMedian = quantileSorted(rawScratch, 0.50)
    float rawQ3 = quantileSorted(rawScratch, 0.75)
    float center = na
    float spread = na

    if n > 0
        if centerMode == "Median / MAD"
            center := quantileSorted(modelScratch, 0.50)
            array.clear(devScratch)
            for i = 0 to n - 1
                array.push(devScratch, math.abs(array.get(modelScratch, i) - center))
            array.sort(devScratch)
            spread := quantileSorted(devScratch, 0.50) * 1.4826
            // Discrete or quiet symbols often produce MAD=0. IQR is a robust,
            // statistically interpretable fallback rather than declaring defeat.
            if na(spread) or spread <= 0
                float modelQ1 = quantileSorted(modelScratch, 0.25)
                float modelQ3 = quantileSorted(modelScratch, 0.75)
                spread := not na(modelQ1) and not na(modelQ3) ? (modelQ3 - modelQ1) / 1.349 : na
        else
            center := sum / n
            float variance = math.max(0.0, sumSquares / n - center * center)
            spread := math.sqrt(variance)

    float percentile = n > 0 and not na(currentVolume) ? (less + 0.5 * equal) / n : na
    [center, spread, rawMedian, rawQ1, rawQ3, n, percentile]

fmtVolume(float value) =>
    string out = "—"
    if not na(value)
        if value >= 1e9
            out := str.tostring(value / 1e9, "0.##") + "B"
        else if value >= 1e6
            out := str.tostring(value / 1e6, "0.##") + "M"
        else if value >= 1e3
            out := str.tostring(value / 1e3, "0.#") + "K"
        else
            out := str.tostring(value, "0")
    out

pct(float value) =>
    na(value) ? "—" : str.tostring(math.round(value * 1000.0) / 10.0) + "%"

resetStage() =>
    array.fill(stagedVolume, na)
    array.fill(stagedBars, 0)

commitStagedSession() =>
    bool complete = true
    for slot = 0 to numSlots - 1
        complete := complete and array.get(stagedBars, slot) == 1 and not na(array.get(stagedVolume, slot))
    if complete
        int p = array.get(meta, 0)
        for slot = 0 to numSlots - 1
            matrix.set(volumeHistory, slot, p, array.get(stagedVolume, slot))
        array.set(meta, 0, (p + 1) % MAX_HISTORY)
        array.set(meta, 1, math.min(MAX_HISTORY, array.get(meta, 1) + 1))
    complete

// Baseline read occurs before the current confirmed bar can be staged or the
// completed session can be committed. Structural self-exclusion holds by construction.
float currentVolume = inSession and not na(volume) ? volume : na
float modelCenter = na
float modelSpread = na
float slotMedian = na
float slotQ1 = na
float slotQ3 = na
float percentile = na
int samples = 0

if slotNow >= 0 and slotNow < numSlots
    [centerRead, spreadRead, medianRead, q1Read, q3Read, nRead, percentileRead] = slotStats(slotNow, currentVolume)
    modelCenter := centerRead
    modelSpread := spreadRead
    slotMedian := medianRead
    slotQ1 := q1Read
    slotQ3 := q3Read
    samples := nRead
    percentile := percentileRead

bool warming = samples < minSamples
bool degenerate = not warming and (na(modelSpread) or modelSpread <= 0)
bool plottable = inSession and not warming and not degenerate and not na(currentVolume)
float rawZ = plottable ? (transformVolume(currentVolume) - modelCenter) / modelSpread : na
float rvol = plottable and not na(slotMedian) and slotMedian > 0 ? currentVolume / slotMedian : na
float cappedZ = na(rawZ) ? na : math.max(-plotCap, math.min(plotCap, rawZ))
float confirmedZ = barstate.isconfirmed ? cappedZ : na

if barstate.isconfirmed
    bool newSession = inSession and sessionId != activeSession
    if newSession
        if activeSession != -1 and not sessionCommitted
            array.set(meta, 2, array.get(meta, 2) + 1)
        resetStage()
        activeSession := sessionId
        sessionCommitted := false

    if inSession and sessionId == activeSession and slotNow >= 0 and slotNow < numSlots
        array.set(stagedBars, slotNow, array.get(stagedBars, slotNow) + 1)
        if not na(volume)
            array.set(stagedVolume, slotNow, volume)
        if minuteOfDay + tfMin >= endMin and not sessionCommitted
            bool accepted = commitStagedSession()
            if not accepted
                array.set(meta, 2, array.get(meta, 2) + 1)
            sessionCommitted := true

// Above the norm reads green, unusually high reads amber, unusually quiet reads
// a lighter grey. Nothing here carries direction; the pane describes
// participation only.
color zColor = color.new(MZ_MUTE, 30)
if na(confirmedZ)
    zColor := color.new(MZ_MUTE, 100)
else if rawZ >= 2.0
    zColor := MZ_AMBER
else if rawZ >= 1.0
    zColor := color.new(MZ_GREEN, 5)
else if rawZ <= -1.0
    zColor := color.new(MZ_LIT2, 25)

bgcolor(shadeUnavailable and inSession and (warming or degenerate) ? color.new(MZ_MUTE, 92) : na,
     title = "Warming or degenerate slot")

plot(confirmedZ, "Confirmed slot z-score (visually capped)", color = zColor, style = plot.style_columns)
plot(rawZ, "Raw uncapped slot z-score", color = color.new(MZ_MUTE, 100), display = display.data_window)
plot(rvol, "Same-slot RVOL", color = color.new(MZ_MUTE, 100), display = display.data_window)
plot(percentile * 100.0, "Same-slot percentile", color = color.new(MZ_MUTE, 100), display = display.data_window)

hline(0, "Slot norm", color = color.new(MZ_MUTE, 40), linestyle = hline.style_solid)
hline(1, "+1", color = color.new(MZ_MUTE, 70), linestyle = hline.style_dotted)
hline(2, "+2", color = color.new(MZ_MUTE, 55), linestyle = hline.style_dashed)
hline(-1, "-1", color = color.new(MZ_MUTE, 70), linestyle = hline.style_dotted)
hline(-2, "-2", color = color.new(MZ_MUTE, 55), linestyle = hline.style_dashed)

var table info = table.new(tblPos, 2, 9, border_width = 1, frame_width = 1,
     frame_color = color.new(MZ_MUTE, 60), border_color = color.new(MZ_MUTE, 75))

tableLabel(int row, string value) =>
    table.cell(info, 0, row, value, text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)

tableValue(int row, string value, color valueColor) =>
    table.cell(info, 1, row, value, text_size = tblSize, text_color = valueColor, bgcolor = MZ_INK)

if barstate.islast
    if showTable
        string observationState = barstate.isconfirmed ? "confirmed" : "provisional"
        string historyState = warming ? str.tostring(samples) + "/" + str.tostring(minSamples) + " warming" :
             degenerate ? "flat distribution" : str.tostring(samples) + " complete sessions"
        historyState += " · " + str.tostring(array.get(meta, 2)) + " excluded"
        string zText = na(rawZ) ? "—" : str.tostring(rawZ, "0.00") + (math.abs(rawZ) > plotCap ? " · plot capped" : "")
        color zTextColor = na(rawZ) ? MZ_MUTE : math.abs(rawZ) >= 2.0 ? MZ_AMBER : MZ_LIT
        string rangeText = fmtVolume(slotQ1) + "-" + fmtVolume(slotQ3)
        string modelText = (scaleMode == "Log volume" ? "log · " : "raw · ") +
             (centerMode == "Median / MAD" ? "median/MAD" : "mean/stdev")

        tableLabel(0, "Slot")
        tableValue(0, slotNow >= 0 ? slotLabel(slotNow) : "outside session", slotNow >= 0 ? MZ_AMBER : MZ_MUTE)
        tableLabel(1, "Observation")
        tableValue(1, observationState, barstate.isconfirmed ? MZ_LIT2 : MZ_AMBER)
        tableLabel(2, "History")
        tableValue(2, historyState, warming or degenerate ? MZ_MUTE : MZ_LIT)
        tableLabel(3, "Model")
        tableValue(3, modelText, MZ_LIT2)
        tableLabel(4, "Slot median")
        tableValue(4, fmtVolume(slotMedian), MZ_LIT)
        tableLabel(5, "Historical IQR")
        tableValue(5, rangeText, MZ_LIT)
        tableLabel(6, "This bar")
        tableValue(6, fmtVolume(currentVolume), MZ_LIT)
        tableLabel(7, "Z / RVOL")
        tableValue(7, zText + " / " + (na(rvol) ? "—" : str.tostring(rvol, "0.00") + "x"), zTextColor)
        tableLabel(8, "Percentile")
        tableValue(8, pct(percentile), not na(percentile) and percentile >= 0.95 ? MZ_AMBER : MZ_LIT)
    else
        table.clear(info, 0, 0, 1, 8)

alertcondition(barstate.isconfirmed and not na(rawZ) and rawZ >= alertThreshold,
     "Unusually high time-slot volume",
     "Confirmed bar volume exceeded the configured positive same-clock-time z-score threshold.")
alertcondition(barstate.isconfirmed and not na(rawZ) and rawZ <= -alertThreshold,
     "Unusually low time-slot volume",
     "Confirmed bar volume exceeded the configured negative same-clock-time z-score threshold.")
````
