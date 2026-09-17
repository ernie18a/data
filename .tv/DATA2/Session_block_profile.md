<!-- tradingview-pine-id: PUB;3c2a1e39fe04401e8d0561718d8abcf4 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Session block profile

Source: https://www.tradingview.com/script/saANzxEB-Session-block-profile/

## Description

Every part of the trading day has a personality. See yours in one table.

Description

Splits the trading session into fixed-length blocks and, for each block, keeps a rolling history of what that part of the day has done over the last N sessions. Three descriptive measures per block: how large its range tends to be relative to the average block, how much volume it tends to carry relative to the average block, and how directional it tends to be, measured as the average of the block's body over its range.

How it calculates

Each bar is assigned to a block from its minute of the day in the chosen time zone. A block's high, low, open, close, and volume accumulate on confirmed bars. When the first confirmed bar of a different block or a different day arrives, the completed block is written into its rolling history and that block's means are recomputed once. Range and volume indices are each block's mean divided by the average across all blocks with enough history, so 1.00 is an average block. Body ratio is the mean of |close - open| divided by (high - low) for the block, so 0 is a doji and 1 is a full-body bar.

How to read it

Range and volume shade toward green as they rise above the average block. Body shades toward amber as blocks become more directional. The current block's label is amber. Alternate blocks can be shaded on the chart so the grid is visible against price. This is a description of what each part of the day has tended to do. It is not a forecast.

Repainting

Closed blocks do not repaint. History is written only when a block completes. The current block is marked but its partial values are not shown as a statistic.

Originality and attribution

Session statistics by time of day are a familiar idea. What is original here is the block-keyed rolling history with cached per-block means, the three-measure normalization against the session's own average block, and the heat-table presentation. This is not derived from and does not reuse code from any existing published script.

Honest limitations

The session must start and end on the same calendar day in the chosen time zone. Sessions that cross midnight are not supported.
A partial first day in chart history contributes a partial block. The minimum-sessions setting exists to absorb that.
Half days, holidays, and early closes pollute a block's history for as many sessions as the lookback.
Range and volume are relative to the average block within this session window, so the indices are only comparable inside one configuration.
Body ratio is not a trend measure. A block can have a high body ratio and still be a small, meaningless move.
Nothing here is a signal. A high-range block is not a direction.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  Session block profile
//  Robust time-of-day structure for range, volume, efficiency, and direction.
//
//  CORE QUESTION
//  Which equal-duration parts of the selected session consistently carry range,
//  participation, directional efficiency, and directional bias?
//
//  DATA INTEGRITY
//  • Confirmed bars only.
//  • Sessions are committed atomically only after every expected block and bar
//    is present. Partial history days, early closes, half days, and data gaps are
//    excluded instead of quietly polluting individual rows.
//  • Session start, end, block length, and chart timeframe must align exactly.
//    No bar can leak post-boundary data into an earlier block.
//  • Range and volume are normalized inside each completed session before they
//    enter history. Every session therefore receives equal statistical weight;
//    unusually volatile or high-volume days cannot dominate the profile merely
//    because their raw scale was larger.
//  • Raw range and volume medians remain visible beside normalized intensities.
//  • Median/IQR is the default robust estimator. Mean is available explicitly.
//  • Direction and up-close probability are separated from body efficiency.
//
//  METRICS
//  Range intensity  = block range / that session's average block range.
//  Volume intensity = block volume / that session's average block volume.
//  Efficiency       = abs(block close - block open) / block range.
//  Direction        = (block close - block open) / block range, in [-1, +1].
//  Up probability   = P(block close > block open | non-flat completed block).
//
//  LIMITATIONS
//  • This is a descriptive clock-time profile, not a signal or forecast.
//  • Equal block duration is enforced. Choose a block length that divides the
//    session exactly; for 09:30-16:00, 30 minutes is valid and 60 is not.
//  • Volume is unavailable on symbols whose feed does not provide valid volume.
//  • Block ranges overlap economically because price paths continue through the
//    day. Range intensity is a relative activity measure, not variance addition.
//  • Wilson intervals for up probability are descriptive and do not correct for
//    serial dependence or scanning many blocks.
//  • Emphasis marks a departure from an even split in EITHER direction. The
//    sign lives in the number, never in the colour alone.
//
//  TIMEFRAME REQUIREMENTS
//  • Intraday, whole-minute timeframes only.
//  • The timeframe must divide the session start, the session length, and the
//    block length exactly. For a 09:30 to 16:00 session with 30-minute blocks
//    that is 1, 2, 3, 5, 6, 10, 15, or 30 minutes. This follows the session, it
//    is not a fixed ceiling: a session starting on the hour also accepts 20
//    and 60 minutes where the block length permits.
//  • The block length must divide the session exactly. For 390 minutes that is
//    5, 6, 10, 13, 15, 26, 30, 39, 65, 78 and so on. 60 is not a divisor of 390.
// =============================================================================

indicator("Session block profile", shorttitle = "Blocks", overlay = true)

color MZ_GREEN = #54c98a
color MZ_AMBER = #d98a2b
color MZ_LIT   = #f5f4f0
color MZ_LIT2  = #b9b8b2
color MZ_MUTE  = #8b8983
color MZ_INK   = #16181c

groupSession = "Session"
blockMin = input.int(30, "Equal block length (minutes)", minval = 5, maxval = 120, step = 5, group = groupSession)
tzIn = input.string("America/New_York", "Time zone", group = groupSession,
     tooltip = "Use an IANA time zone. Enter exchange to use the symbol's exchange time zone.")
sStartH = input.int(9, "Start hour", minval = 0, maxval = 23, group = groupSession, inline = "s")
sStartM = input.int(30, "Start minute", minval = 0, maxval = 59, group = groupSession, inline = "s")
sEndH = input.int(16, "End hour", minval = 0, maxval = 23, group = groupSession, inline = "e")
sEndM = input.int(0, "End minute", minval = 0, maxval = 59, group = groupSession, inline = "e")

groupStats = "Statistics"
historyWindow = input.int(60, "Rolling completed sessions", options = [20, 40, 60, 120, 250], group = groupStats)
minSamples = input.int(20, "Minimum completed sessions", minval = 3, maxval = 250, group = groupStats)
centerMode = input.string("Median", "Central estimate", options = ["Median", "Mean"], group = groupStats,
     tooltip = "Median is robust to event days. Mean preserves arithmetic expectation but is more sensitive to outliers.")
showIQR = input.bool(true, "Show interquartile range", group = groupStats)

groupDisplay = "Display"
showHeat = input.bool(true, "Tint cell backgrounds", group = groupDisplay)
showGrid = input.bool(true, "Shade alternate blocks", group = groupDisplay)
showTable = input.bool(true, "Show profile table", group = groupDisplay)
showMarkers = input.bool(false, "Mark historically active block starts", group = groupDisplay)
activityThreshold = input.float(1.20, "Active-block threshold", minval = 1.0, maxval = 3.0, step = 0.05, group = groupDisplay,
     tooltip = "Marker/alert requires both historical range and volume intensity to meet this threshold.")
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

if barstate.isfirst
    if not timeframe.isintraday
        runtime.error("Session block profile requires an intraday chart. A clock-time profile has no meaning on daily or higher.")
    if tfSec < 60 or tfSec % 60 != 0
        runtime.error("Use a whole-minute chart timeframe of 1 minute or higher.")
    if endMin <= startMin
        runtime.error("The session must end after it starts and cannot cross midnight.")
    if tfMin > blockMin
        runtime.error("Block length must be at least one chart bar long.")
    if startMin % tfMin != 0 or sessionMinutes % tfMin != 0 or blockMin % tfMin != 0
        runtime.error("Session boundaries and block length must align exactly with the chart timeframe.")
    if sessionMinutes % blockMin != 0
        runtime.error("Block length must divide the session exactly. A 09:30 to 16:00 session is 390 minutes, so use 5, 10, 15, 30, 65 or another exact divisor. 60 does not divide 390.")
    if sessionMinutes / blockMin > 40
        runtime.error("This configuration creates more than 40 blocks. Increase block length to protect Pine collection and table limits.")

int numBlocks = int(sessionMinutes / blockMin)
int barsPerBlock = int(blockMin / tfMin)
// Sized to the reachable window rather than a fixed maximum.
int MAX_HISTORY = historyWindow

int hh = hour(time, tz)
int mm = minute(time, tz)
int minuteOfDay = hh * 60 + mm
bool inSession = minuteOfDay >= startMin and minuteOfDay < endMin
int blockNow = inSession ? int(math.floor((minuteOfDay - startMin) / blockMin)) : -1
int sessionId = year(time, tz) * 400 + month(time, tz) * 32 + dayofmonth(time, tz)

var matrix<float> rangeIndexH = matrix.new<float>(numBlocks, MAX_HISTORY, na)
var matrix<float> volumeIndexH = matrix.new<float>(numBlocks, MAX_HISTORY, na)
var matrix<float> rawRangeH = matrix.new<float>(numBlocks, MAX_HISTORY, na)
var matrix<float> rawVolumeH = matrix.new<float>(numBlocks, MAX_HISTORY, na)
var matrix<float> efficiencyH = matrix.new<float>(numBlocks, MAX_HISTORY, na)
var matrix<float> directionH = matrix.new<float>(numBlocks, MAX_HISTORY, na)
var matrix<int> directionSignH = matrix.new<int>(numBlocks, MAX_HISTORY, 0)
var array<int> meta = array.from(0, 0, 0)

var array<float> stageHigh = array.new_float(numBlocks, na)
var array<float> stageLow = array.new_float(numBlocks, na)
var array<float> stageVolume = array.new_float(numBlocks, 0.0)
var array<float> stageOpen = array.new_float(numBlocks, na)
var array<float> stageClose = array.new_float(numBlocks, na)
var array<int> stageBars = array.new_int(numBlocks, 0)
var array<int> stageVolumeBars = array.new_int(numBlocks, 0)

var int activeSession = -1
var bool sessionCommitted = true
bool activeBlockPulse = false

pad2(int n) =>
    n < 10 ? "0" + str.tostring(n) : str.tostring(n)

blockLabel(int b) =>
    int s = startMin + b * blockMin
    int e = s + blockMin
    pad2(int(math.floor(s / 60))) + ":" + pad2(s % 60) + "-" +
         pad2(int(math.floor(e / 60))) + ":" + pad2(e % 60)

resetStage() =>
    array.fill(stageHigh, na)
    array.fill(stageLow, na)
    array.fill(stageVolume, 0.0)
    array.fill(stageOpen, na)
    array.fill(stageClose, na)
    array.fill(stageBars, 0)
    array.fill(stageVolumeBars, 0)

historyIndex(int age) =>
    int p = array.get(meta, 0)
    (p - 1 - age + MAX_HISTORY * 2) % MAX_HISTORY

usableSessions() =>
    math.min(array.get(meta, 1), historyWindow)

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

var array<float> statScratch = array.new_float()

metricStats(matrix<float> source, int b) =>
    array.clear(statScratch)
    float sum = 0.0
    int useN = usableSessions()
    if useN > 0
        for age = 0 to useN - 1
            float value = matrix.get(source, b, historyIndex(age))
            if not na(value)
                array.push(statScratch, value)
                sum += value
    array.sort(statScratch)
    int n = array.size(statScratch)
    float center = na
    if n > 0
        center := centerMode == "Mean" ? sum / n : quantileSorted(statScratch, 0.50)
    float q1 = quantileSorted(statScratch, 0.25)
    float q3 = quantileSorted(statScratch, 0.75)
    [center, q1, q3, n]

upStats(int b) =>
    int up = 0
    int nonflat = 0
    int useN = usableSessions()
    if useN > 0
        for age = 0 to useN - 1
            int sign = matrix.get(directionSignH, b, historyIndex(age))
            if sign != 0
                nonflat += 1
                if sign == 1
                    up += 1
    [up, nonflat]

wilsonBounds(int successes, int trials) =>
    float lo = na
    float hi = na
    if trials > 0
        float z = 1.95996398454
        float n = trials
        float phat = successes / n
        float den = 1.0 + z * z / n
        float center = (phat + z * z / (2.0 * n)) / den
        float margin = z * math.sqrt((phat * (1.0 - phat) + z * z / (4.0 * n)) / n) / den
        lo := math.max(0.0, center - margin)
        hi := math.min(1.0, center + margin)
    [lo, hi]

pct(float value) =>
    na(value) ? "—" : str.tostring(math.round(value * 1000.0) / 10.0) + "%"

signedNumber(float value) =>
    na(value) ? "—" : (value > 0 ? "+" : "") + str.tostring(math.round(value * 100.0) / 100.0)

indexText(float center, float q1, float q3) =>
    string out = na(center) ? "—" : str.tostring(center, "0.00") + "x"
    if showIQR and not na(q1) and not na(q3)
        out += "\n" + str.tostring(q1, "0.00") + "-" + str.tostring(q3, "0.00")
    out

valueText(float center, float q1, float q3, bool priceValue) =>
    string out = "—"
    if not na(center)
        out := priceValue ? str.tostring(center, format.mintick) : str.tostring(center, format.volume)
        if showIQR and not na(q1) and not na(q3)
            out += "\n" + (priceValue ? str.tostring(q1, format.mintick) + "-" + str.tostring(q3, format.mintick) :
                 str.tostring(q1, format.volume) + "-" + str.tostring(q3, format.volume))
    out

heatText(float value, float lo, float mid, float hi, color accent) =>
    color out = MZ_MUTE
    if not na(value)
        out := value <= mid ? color.from_gradient(value, lo, mid, MZ_MUTE, MZ_LIT) :
             color.from_gradient(value, mid, hi, MZ_LIT, accent)
    out

heatBack(float value, float mid, float hi, color accent) =>
    color out = MZ_INK
    if showHeat and not na(value) and value > mid
        out := color.from_gradient(value, mid, hi, MZ_INK, color.new(accent, 72))
    out

commitStagedSession() =>
    bool complete = true
    float sumRange = 0.0
    float sumVolume = 0.0
    bool volumeComplete = true

    for b = 0 to numBlocks - 1
        int bars = array.get(stageBars, b)
        float hi = array.get(stageHigh, b)
        float lo = array.get(stageLow, b)
        complete := complete and bars == barsPerBlock and not na(hi) and not na(lo)
        volumeComplete := volumeComplete and array.get(stageVolumeBars, b) == barsPerBlock
        if not na(hi) and not na(lo)
            sumRange += math.max(0.0, hi - lo)
        sumVolume += array.get(stageVolume, b)

    complete := complete and sumRange > 0

    if complete
        int p = array.get(meta, 0)
        for b = 0 to numBlocks - 1
            float hi = array.get(stageHigh, b)
            float lo = array.get(stageLow, b)
            float op = array.get(stageOpen, b)
            float cl = array.get(stageClose, b)
            float blockRange = hi - lo
            float vol = array.get(stageVolume, b)
            float rangeIndex = numBlocks * blockRange / sumRange
            float volumeIndex = volumeComplete and sumVolume > 0 ? numBlocks * vol / sumVolume : na
            float efficiency = blockRange > 0 ? math.abs(cl - op) / blockRange : 0.0
            float direction = blockRange > 0 ? (cl - op) / blockRange : 0.0
            int sign = cl > op ? 1 : cl < op ? -1 : 0
            matrix.set(rangeIndexH, b, p, rangeIndex)
            matrix.set(volumeIndexH, b, p, volumeIndex)
            matrix.set(rawRangeH, b, p, blockRange)
            matrix.set(rawVolumeH, b, p, volumeComplete ? vol : na)
            matrix.set(efficiencyH, b, p, efficiency)
            matrix.set(directionH, b, p, direction)
            matrix.set(directionSignH, b, p, sign)
        array.set(meta, 0, (p + 1) % MAX_HISTORY)
        array.set(meta, 1, math.min(MAX_HISTORY, array.get(meta, 1) + 1))
    complete

if barstate.isconfirmed
    bool newSession = inSession and sessionId != activeSession

    if newSession
        if activeSession != -1 and not sessionCommitted
            array.set(meta, 2, array.get(meta, 2) + 1)
        resetStage()
        activeSession := sessionId
        sessionCommitted := false

    if inSession and sessionId == activeSession and blockNow >= 0 and blockNow < numBlocks
        int priorBars = array.get(stageBars, blockNow)
        if priorBars == 0
            array.set(stageOpen, blockNow, open)
            activeBlockPulse := true
        float oldHigh = array.get(stageHigh, blockNow)
        float oldLow = array.get(stageLow, blockNow)
        array.set(stageHigh, blockNow, na(oldHigh) ? high : math.max(oldHigh, high))
        array.set(stageLow, blockNow, na(oldLow) ? low : math.min(oldLow, low))
        array.set(stageClose, blockNow, close)
        array.set(stageBars, blockNow, priorBars + 1)
        if not na(volume)
            array.set(stageVolume, blockNow, array.get(stageVolume, blockNow) + volume)
            array.set(stageVolumeBars, blockNow, array.get(stageVolumeBars, blockNow) + 1)
        if minuteOfDay + tfMin >= endMin and not sessionCommitted
            bool accepted = commitStagedSession()
            if not accepted
                array.set(meta, 2, array.get(meta, 2) + 1)
            sessionCommitted := true

bool historicalActivityPulse = false
if barstate.isconfirmed and activeBlockPulse and blockNow >= 0
    [rCenterPulse, rQ1Pulse, rQ3Pulse, rNPulse] = metricStats(rangeIndexH, blockNow)
    [vCenterPulse, vQ1Pulse, vQ3Pulse, vNPulse] = metricStats(volumeIndexH, blockNow)
    historicalActivityPulse := rNPulse >= minSamples and vNPulse >= minSamples and
         rCenterPulse >= activityThreshold and vCenterPulse >= activityThreshold

bgcolor(showGrid and inSession and blockNow % 2 == 0 ? color.new(MZ_MUTE, 94) : na,
     title = "Alternate session blocks")

plotshape(showMarkers and historicalActivityPulse, title = "Historically active block",
     style = shape.square, location = location.bottom, color = MZ_AMBER, size = size.tiny, text = "A")

var table info = table.new(tblPos, 6, numBlocks + 3, border_width = 1, frame_width = 1,
     frame_color = color.new(MZ_MUTE, 50), border_color = color.new(MZ_MUTE, 75))
var bool headerMerged = false

if barstate.islast
    if showTable
        int stored = array.get(meta, 1)
        int used = usableSessions()
        int excluded = array.get(meta, 2)
        string estimator = centerMode == "Median" ? "median / IQR" : "mean / IQR"
        table.cell(info, 0, 0, "Session block profile", text_size = tblSize,
             text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(info, 0, 1,
             str.tostring(used) + " sessions · " + str.tostring(blockMin) + "m blocks · " + estimator + " · " + str.tostring(excluded) + " excluded",
             text_size = tblSize, text_color = MZ_LIT2, bgcolor = MZ_INK,
             tooltip = "Stored complete sessions: " + str.tostring(stored) + "\nRolling window used: " + str.tostring(used) + "\nExcluded incomplete sessions: " + str.tostring(excluded))
        if not headerMerged
            table.merge_cells(info, 0, 0, 5, 0)
            table.merge_cells(info, 0, 1, 5, 1)
            headerMerged := true

        table.cell(info, 0, 2, "Block", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(info, 1, 2, "Range", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Historical range intensity. Cell tooltip includes raw range in price units.")
        table.cell(info, 2, 2, "Volume", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Historical volume intensity. Cell tooltip includes raw block volume.")
        table.cell(info, 3, 2, "Efficiency", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "abs(close-open) / range. High efficiency means the block closed far from its open relative to its full range.")
        table.cell(info, 4, 2, "Direction", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Signed efficiency: (close-open) / range. The sign is in the number. Emphasis marks magnitude, not direction.")
        table.cell(info, 5, 2, "P(up)", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Share of non-flat completed blocks that closed above their open, with a 95% Wilson interval. Emphasis marks an interval that excludes 50%, in either direction.")

        for b = 0 to numBlocks - 1
            [ri, riQ1, riQ3, riN] = metricStats(rangeIndexH, b)
            [vi, viQ1, viQ3, viN] = metricStats(volumeIndexH, b)
            [rr, rrQ1, rrQ3, rrN] = metricStats(rawRangeH, b)
            [rv, rvQ1, rvQ3, rvN] = metricStats(rawVolumeH, b)
            [ef, efQ1, efQ3, efN] = metricStats(efficiencyH, b)
            [di, diQ1, diQ3, diN] = metricStats(directionH, b)
            [upCount, upN] = upStats(b)

            bool ready = riN >= minSamples and efN >= minSamples
            bool volumeReady = viN >= minSamples
            bool isCurrent = b == blockNow
            color labelColor = isCurrent ? MZ_AMBER : ready ? MZ_LIT2 : MZ_MUTE

            string rangeCell = ready ? indexText(ri, riQ1, riQ3) : str.tostring(riN) + "/" + str.tostring(minSamples)
            string volumeCell = volumeReady ? indexText(vi, viQ1, viQ3) : viN > 0 ? str.tostring(viN) + "/" + str.tostring(minSamples) : "n/a"
            string efficiencyCell = ready ? str.tostring(ef, "0.00") + (showIQR ? "\n" + str.tostring(efQ1, "0.00") + "-" + str.tostring(efQ3, "0.00") : "") : "—"
            string directionCell = ready ? signedNumber(di) + (showIQR ? "\n" + signedNumber(diQ1) + "-" + signedNumber(diQ3) : "") : "—"

            string upCell = "—"
            color upColor = MZ_MUTE
            if upN > 0
                float upRate = upCount / float(upN)
                [upLo, upHi] = wilsonBounds(upCount, upN)
                upCell := pct(upRate) + " · n=" + str.tostring(upN) + "\n" + pct(upLo) + "-" + pct(upHi)
                bool separated = upLo > 0.5 or upHi < 0.5
                upColor := upN < minSamples ? MZ_MUTE : separated ? MZ_AMBER : MZ_LIT

            float liveRange = b == blockNow and not na(array.get(stageHigh, b)) and not na(array.get(stageLow, b)) ?
                 array.get(stageHigh, b) - array.get(stageLow, b) : na
            float liveVolume = b == blockNow ? array.get(stageVolume, b) : na
            string liveTip = b == blockNow ? "\nCurrent partial block — range: " +
                 (na(liveRange) ? "—" : str.tostring(liveRange, format.mintick)) + ", volume: " +
                 (na(liveVolume) ? "—" : str.tostring(liveVolume, format.volume)) + ", bars: " +
                 str.tostring(array.get(stageBars, b)) + "/" + str.tostring(barsPerBlock) : ""

            table.cell(info, 0, b + 3, blockLabel(b), text_size = tblSize, text_color = labelColor, bgcolor = MZ_INK,
                 tooltip = "Equal-duration block." + liveTip)
            table.cell(info, 1, b + 3, rangeCell, text_size = tblSize,
                 text_color = ready ? heatText(ri, 0.50, 1.00, 1.80, MZ_GREEN) : MZ_MUTE,
                 bgcolor = ready ? heatBack(ri, 1.00, 1.80, MZ_GREEN) : MZ_INK,
                 tooltip = "Raw range " + str.lower(centerMode) + ": " + valueText(rr, rrQ1, rrQ3, true) + "\nNormalized n=" + str.tostring(riN) + liveTip)
            table.cell(info, 2, b + 3, volumeCell, text_size = tblSize,
                 text_color = volumeReady ? heatText(vi, 0.50, 1.00, 1.80, MZ_GREEN) : MZ_MUTE,
                 bgcolor = volumeReady ? heatBack(vi, 1.00, 1.80, MZ_GREEN) : MZ_INK,
                 tooltip = "Raw volume " + str.lower(centerMode) + ": " + valueText(rv, rvQ1, rvQ3, false) + "\nNormalized n=" + str.tostring(viN) + liveTip)
            table.cell(info, 3, b + 3, efficiencyCell, text_size = tblSize,
                 text_color = ready ? heatText(ef, 0.10, 0.35, 0.75, MZ_AMBER) : MZ_MUTE,
                 bgcolor = ready ? heatBack(ef, 0.35, 0.75, MZ_AMBER) : MZ_INK)
            table.cell(info, 4, b + 3, directionCell, text_size = tblSize,
                 text_color = ready ? heatText(math.abs(di), 0.02, 0.10, 0.30, MZ_AMBER) : MZ_MUTE,
                 bgcolor = ready ? heatBack(math.abs(di), 0.10, 0.30, MZ_AMBER) : MZ_INK)
            table.cell(info, 5, b + 3, upCell, text_size = tblSize, text_color = upColor,
                 bgcolor = showHeat and upColor == MZ_AMBER ? color.new(MZ_AMBER, 84) : MZ_INK)
    else
        table.clear(info, 0, 0, 5, numBlocks + 2)

float currentBlockRange = blockNow >= 0 and not na(array.get(stageHigh, blockNow)) and not na(array.get(stageLow, blockNow)) ?
     array.get(stageHigh, blockNow) - array.get(stageLow, blockNow) : na
float currentBlockVolume = blockNow >= 0 ? array.get(stageVolume, blockNow) : na

plot(blockNow + 1, "Current block number", display = display.data_window)
plot(currentBlockRange, "Current partial block range", display = display.data_window)
plot(currentBlockVolume, "Current partial block volume", display = display.data_window)

alertcondition(historicalActivityPulse, "Historically active block started",
     "A session block whose historical range and volume intensities exceed the configured threshold has started.")
````
