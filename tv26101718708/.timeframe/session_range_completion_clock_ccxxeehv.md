# Session Range Completion Clock

- url: https://www.tradingview.com/script/CCXxeEhV-Session-Range-Completion-Clock/
- type: indicator
- pine_id: PUB;b15ae6312cab42c7a649ab8130382780
- version: 2.0

## Description

This indicator measures WHEN, inside a chosen intraday session, that session's range is actually
built. It answers a question that session tools normally skip: by a given time of day, how much of
the day's eventual range is typically already spent, and has the extreme that will define the day
usually already printed?

It draws no levels, marks nothing on price, and produces no signals. It is a measurement
instrument that reports descriptive statistics over the sessions in your loaded history.

THE UNDERLYING PRINCIPLE

A session's range is not built at a constant rate, and how it is built differs by symbol, by
session and by contract. The script assumes nothing about the shape - it measures it on whatever
instrument and window you point it at.

"How much range is left" and "is the extreme already in" are two different statistics, and the
script keeps them separate. For every completed session in the loaded history it records the
running high and low at the end of each time bucket, then waits for the session to close so the
FINAL range is known. It then attributes, for each bucket:

- the fraction of the final range that had been traversed by the end of that bucket;
- whether the session's high had already been made at or before that bucket;
- whether the session's low had already been made;
- whether both were already in place, meaning the range was finished and everything afterwards
  happened inside it;
- the traversed range expressed in units of daily ATR or of the previous day's range, which makes
  the figure comparable across volatility regimes.

These are accumulated across sessions and reported as means and frequencies.

HOW TO READ THE TABLE

The table is drawn once, on the last bar of the chart. Each row is a point in time, labelled with
the clock time at the end of that bucket.

"n" is the number of sessions contributing to that row. "Range built" is the mean percentage of
the session's final range already traversed. "High set" and "Low set" are the percentage of
sessions in which that extreme was already established. "Both set" is the percentage of sessions
in which the entire range was already complete; that column is shaded by value. "Range/unit" is
the mean range so far in the normalization unit selected in the inputs, which is named in the
bottom-right cell.

If the session contains more buckets than the row limit, buckets are sampled at an even stride so
the table still ends on the session's final bucket.

The pane also plots two lines during a live session: the current session's range so far, and the
mean range so far of all prior qualifying sessions at the same point in the session, both in the
same unit. That is a like-for-like comparison at equal elapsed session time. It is not a
projection and the script does not extend either line forward.

On a daily or higher chart the table prints a message instead of statistics: the whole measurement
is defined on intraday bars and there is nothing to compute.

WHAT IT DOES NOT DO

It does not predict where price will go, does not identify breakouts, and does not mark levels. A
high "Both set" figure at a given time means only that historically, on this symbol and this
session, the range was usually already complete by then. It is a frequency over past sessions, not
a statement about today, and nothing in the script says whether acting on it would be a good idea.

METHOD, AND WHY IT DOES NOT REPAINT

A session is folded into the statistics only after it has closed, so the session in progress never
contributes to its own statistics.

Historical values are never recalculated. The statistics accumulate forward in time, which means
the historical-mean line on early bars was computed from a smaller sample than the same line on
recent bars. That is deliberate; the alternative would be a curve that silently rewrites its own
past.

The daily normalization unit comes from a single bundled request on the daily timeframe. The
requested expression is offset by one bar and the request uses lookahead, which is the pair the
Pine Script documentation specifies for confirmed higher-timeframe values: the offset discards the
daily bar that is still forming and returns the one before it, which was already final. Historical
and realtime bars therefore receive the same value. This matters more here than it looks, because
the unit is latched once at session start and then used for that whole session - a unit that
differed between live and reloaded charts would give a session two different "Range/unit" figures
depending on when you looked at it.

Time buckets are anchored to the declared session start time rather than to the first bar
observed. This keeps the time-of-day axis stable on illiquid symbols, on sessions that run through
midnight, and on continuous 24-hour sessions where there is no gap between sessions to detect. A
session string containing more than one range, such as 0900-1130,1230-1500, is treated as a single
window running from the first start to the last end; buckets falling inside the break carry the
pre-break state forward, which is what you want, because the range does not reset over lunch. An
optional day mask such as 0930-1600:23456 is respected.

SETTINGS

Session and Session time zone define the window. Use the exchange's own time zone so buckets stay
aligned across daylight-saving changes.

Bucket size should be a multiple of the chart timeframe. A bucket narrower than the chart
timeframe contains no bars of its own and simply carries the previous bucket's state forward.

Minimum session completeness excludes half-days, early closes and partially loaded history, which
would otherwise depress the late-session figures. Lower it if a market you are studying
legitimately has short sessions.

Normalise range by chooses between daily ATR and the previous day's range. ATR is smoother; the
previous day's range reacts faster.

ORIGINALITY

The session and time-of-day category on this platform is overwhelmingly made of level-drawing
tools: opening-range boxes, session high/low lines, session shading. Those draw where. Very little
published measures when, and the two are different objects - this script plots nothing on price at
all.

There is a small existing family of scripts that chart the distribution of the hour at which the
daily high or low prints, and the "High set" and "Low set" columns overlap with that idea. This is
not a reskin of any of them: the accumulator here is cumulative by elapsed session time rather
than a histogram of one timestamp, it is folded only on session close, it is keyed to a
user-supplied session string with mid-session-break handling and a day mask, and it is combined
with final-range-fraction and volatility normalization. No code is borrowed from any published
script.

LIMITATIONS

Requires an intraday chart timeframe.

The sample is whatever history the chart has loaded, which on lower timeframes may be only a few
hundred sessions - check "n" before reading anything into a row.

Results are sensitive to the chart timeframe, because the exact bar on which an extreme prints is
resolution-dependent. Coarser timeframes will place extremes in later buckets than they truly
occurred.

The "Range/unit" column can be based on a smaller sample than the percentage columns, because the
earliest sessions in the loaded history have no completed daily bar to normalize against and are
skipped for that column only.

Sessions spanning a daylight-saving transition can be misattributed by one hour for a single day.

On non-standard chart types - Heikin Ashi, Renko, Kagi, Point and Figure, Range - the highs and
lows are synthetic, so the statistics describe the synthetic series rather than traded prices.

The statistics describe the loaded history only and carry no assumption that the distribution is
stable over time.

Source is open and commented.

## Source Code

````pine
//@version=6
// Session Range Completion Clock
// Open-source. Measures WHEN, inside a chosen session, the day's range is
// actually built - and when the session high and low are typically already in
// place. Descriptive statistics only. No signals, no forecasts.

indicator("Session Range Completion Clock", "SRCC", overlay = false, precision = 2)

// ============================================================================
// Inputs
// ============================================================================
const string G_SESS = "Session window"
const string G_BUCK = "Time buckets and sampling"
const string G_NORM = "Normalisation"
const string G_TBL  = "Statistics table"

sessSpec = input.session("0930-1600", "Session", group = G_SESS,
     tooltip = "The intraday window measured, in the time zone selected below. " +
     "Examples: 0930-1600 for US cash equities, 0800-1630 for LSE, 1800-1700 " +
     "for a CME overnight-to-close session. Sessions that cross midnight are " +
     "supported. A session with a mid-day break, for example 0900-1130,1230-1500, " +
     "is treated as one window running from the first start to the last end; " +
     "buckets inside the break carry the pre-break state forward. An optional " +
     "day mask such as 0930-1600:23456 is respected.")

sessTz = input.string("America/New_York", "Session time zone", group = G_SESS,
     tooltip = "IANA time zone name used to interpret the session above, for " +
     "example America/New_York, Europe/London, Asia/Tokyo, or a UTC offset such " +
     "as GMT-5. Using the exchange's own zone keeps the buckets aligned across " +
     "daylight-saving changes.")

bucketMin = input.int(15, "Bucket size (minutes)", minval = 1, maxval = 720, step = 5,
     group = G_BUCK,
     tooltip = "Width of each time-of-day bucket. Statistics are reported at the " +
     "end of every bucket. Set this to a multiple of the chart timeframe: " +
     "buckets narrower than the chart timeframe will contain no bars of their " +
     "own and simply carry the previous bucket's state forward.")

minCompletePct = input.int(80, "Minimum session completeness (%)", minval = 0, maxval = 100,
     group = G_BUCK,
     tooltip = "A session is included in the statistics only if bars are present " +
     "up to at least this share of the session window. This excludes half-days, " +
     "early closes and partially loaded history, which would otherwise drag the " +
     "late-session numbers down. Set to 0 to include every session.")

normMode = input.string("Daily ATR", "Normalise range by",
     options = ["Daily ATR", "Previous day range"], group = G_NORM,
     tooltip = "Unit used to make the range comparable across volatility regimes. " +
     "Daily ATR is smoother; previous day range reacts faster. Both are taken " +
     "from completed daily bars only.")

atrLen = input.int(14, "Daily ATR length", minval = 1, group = G_NORM,
     tooltip = "Length of the Average True Range computed on the daily timeframe. " +
     "Only used when 'Normalise range by' is set to Daily ATR.")

showPlots = input.bool(true, "Plot current session against historical mean", group = G_NORM,
     tooltip = "Draws the live session's range-so-far and the mean range-so-far of " +
     "all prior qualifying sessions at the same point in the session, both in the " +
     "normalisation unit chosen above.")

showTable = input.bool(true, "Show statistics table", group = G_TBL,
     tooltip = "Displays the completion clock. Statistics are drawn once, on the " +
     "last bar of the chart.")

tblPos = input.string("Top right", "Table position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"],
     group = G_TBL, tooltip = "Where the table is anchored in the pane.")

maxRows = input.int(20, "Maximum table rows", minval = 4, maxval = 40, group = G_TBL,
     tooltip = "If the session contains more buckets than this, buckets are sampled " +
     "at an even stride so the table still ends on the session's final bucket.")

tblSize = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"],
     group = G_TBL, tooltip = "Font size used for the table.")

// ============================================================================
// Session clock
// ============================================================================
// Buckets are anchored to the session's declared start time rather than to the
// first bar seen. That keeps the time-of-day axis stable on illiquid symbols,
// on sessions that run through midnight, and on continuous 24-hour sessions
// where there is no gap to detect.

const int MAX_BUCKETS = 1440

//@function     Convert an "HHMM" token to minutes from midnight.
//@param  token Four-character clock token, for example "0930".
//@returns      Minutes from midnight in 0..1439, or -1 if the token is invalid.
hmToMin(string token) =>
    float v = str.length(token) == 4 ? str.tonumber(token) : na
    int hh = na(v) ? -1 : int(math.floor(v / 100))
    int mm = na(v) ? -1 : int(v) % 100
    (hh < 0 or hh > 24 or mm < 0 or mm > 59) ? -1 : (hh * 60 + mm) % 1440

//@function    Strip an optional ":dayMask" suffix from a session string.
//@param  spec Session string, for example "0900-1130,1230-1500:23456".
//@returns     The time-ranges portion, for example "0900-1130,1230-1500".
sessBody(string spec) =>
    array.get(str.split(spec, ":"), 0)

//@function    Start of the FIRST time range of a session string.
//@param  spec Session string.
//@returns     Minutes from midnight, or -1 if it cannot be parsed.
sessFirstStart(string spec) =>
    array<string> parts = str.split(array.get(str.split(sessBody(spec), ","), 0), "-")
    string token = ""
    if array.size(parts) > 0
        token := array.get(parts, 0)
    hmToMin(token)

//@function    End of the LAST time range of a session string.
//@param  spec Session string.
//@returns     Minutes from midnight, or -1 if it cannot be parsed.
sessLastEnd(string spec) =>
    array<string> ranges = str.split(sessBody(spec), ",")
    array<string> parts = str.split(array.get(ranges, array.size(ranges) - 1), "-")
    string token = ""
    if array.size(parts) > 1
        token := array.get(parts, 1)
    hmToMin(token)

//@function            Format minutes-from-midnight as HH:MM, wrapping across midnight.
//@param  minutesOfDay Minutes from midnight; may exceed 1440 or be negative.
//@returns             Zero-padded HH:MM string.
fmtHM(int minutesOfDay) =>
    int m = ((minutesOfDay % 1440) + 1440) % 1440
    int hh = int(math.floor(m / 60.0))
    int mm = m % 60
    (hh < 10 ? "0" : "") + str.tostring(hh) + ":" + (mm < 10 ? "0" : "") + str.tostring(mm)

// The session string never changes during a run, so it is parsed once.
var int sessStartMin = sessFirstStart(sessSpec)
var int sessEndMin = sessLastEnd(sessSpec)

bool specOk = sessStartMin >= 0 and sessEndMin >= 0

int sessLenMin = 1440
if specOk
    sessLenMin := sessEndMin > sessStartMin ? sessEndMin - sessStartMin : sessEndMin + 1440 - sessStartMin

int nBuckets = math.min(MAX_BUCKETS, math.max(1, int(math.ceil(sessLenMin / math.max(1.0, bucketMin)))))

bool tfOk = timeframe.isintraday
int barMinOfDay = hour(time, sessTz) * 60 + minute(time, sessTz)
int elapsedMin = specOk ? (barMinOfDay - sessStartMin + 1440) % 1440 : 0
int bIdx = math.max(0, math.min(nBuckets - 1, int(math.floor(elapsedMin / float(bucketMin)))))

// A bar inside one of the declared time ranges, on a day the optional mask allows.
bool isSessBar = tfOk and specOk and not na(time(timeframe.period, sessSpec, sessTz))
// A bar anywhere inside the outer window, including any mid-session break.
bool inWindow = tfOk and specOk and elapsedMin < sessLenMin

// ============================================================================
// Daily normalisation unit - one bundled request, lookahead_on paired with the [1]
// ============================================================================
//@function   Bundle the daily-timeframe values this script needs.
//@param  len ATR length evaluated in the daily context.
//@returns    [ATR of the last completed daily bar, range of the last completed daily bar]
dailyBundle(simple int len) =>
    [ta.atr(len)[1], high[1] - low[1]]

[atrD, prevDayRange] = request.security(syminfo.tickerid, "D", dailyBundle(atrLen),
     lookahead = barmerge.lookahead_on)

float normUnit = normMode == "Daily ATR" ? atrD : prevDayRange

// ============================================================================
// Accumulators
// ============================================================================
// Per bucket, over every completed qualifying session:
//   sumFrac  - sum of (range built by end of bucket / that session's final range)
//   sumNorm  - sum of (range built by end of bucket / that session's normalisation unit)
//   cntSess  - sessions that reached the bucket
//   cntNorm  - sessions that reached the bucket AND had a valid normalisation unit
//   cntHiSet - sessions whose high was already in place at the bucket
//   cntLoSet - sessions whose low was already in place
//   cntBoth  - sessions whose high and low were both already in place
var array<float> sumFrac = array.new<float>(MAX_BUCKETS, 0.0)
var array<float> sumNorm = array.new<float>(MAX_BUCKETS, 0.0)
var array<int> cntSess = array.new<int>(MAX_BUCKETS, 0)
var array<int> cntNorm = array.new<int>(MAX_BUCKETS, 0)
var array<int> cntHiSet = array.new<int>(MAX_BUCKETS, 0)
var array<int> cntLoSet = array.new<int>(MAX_BUCKETS, 0)
var array<int> cntBoth = array.new<int>(MAX_BUCKETS, 0)

// Running state of the session in progress
var array<float> runHi = array.new<float>(MAX_BUCKETS, float(na))
var array<float> runLo = array.new<float>(MAX_BUCKETS, float(na))

var float sessHi = na
var float sessLo = na
var int hiBucket = 0
var int loBucket = 0
var int barsInSess = 0
var int maxBucketThis = 0
var float sessNorm = na
var bool haveSess = false
var float prevElapsed = -1.0
var int sessionsUsed = 0
var int globalMaxB = 0

// Elapsed minutes rise monotonically inside a session, so a fall marks a wrap.
// A session is closed when a new one begins or when the outer window ends. Using
// the outer window - not "this bar is a session bar" - is what stops a mid-session
// break (for example a lunch break) from being counted as two separate sessions.
bool startedNew = isSessBar and (not haveSess or elapsedMin < prevElapsed)
bool closePrev = haveSess and (startedNew or not inWindow)

if tfOk
    // ---- fold the session that just ended into the statistics -------------
    if closePrev
        float finalRange = nz(sessHi) - nz(sessLo)
        bool complete = (maxBucketThis + 1) * 100 >= nBuckets * minCompletePct
        if finalRange > 0 and barsInSess >= 2 and complete
            float lastHi = na
            float lastLo = na
            int lastB = math.max(hiBucket, loBucket)
            for b = 0 to maxBucketThis
                float hb = array.get(runHi, b)
                if not na(hb)
                    lastHi := hb
                    lastLo := array.get(runLo, b)
                if not na(lastHi) and not na(lastLo)
                    array.set(sumFrac, b, array.get(sumFrac, b) + (lastHi - lastLo) / finalRange)
                    array.set(cntSess, b, array.get(cntSess, b) + 1)
                    if b >= hiBucket
                        array.set(cntHiSet, b, array.get(cntHiSet, b) + 1)
                    if b >= loBucket
                        array.set(cntLoSet, b, array.get(cntLoSet, b) + 1)
                    if b >= lastB
                        array.set(cntBoth, b, array.get(cntBoth, b) + 1)
                    if not na(sessNorm) and sessNorm > 0
                        array.set(sumNorm, b, array.get(sumNorm, b) + (lastHi - lastLo) / sessNorm)
                        array.set(cntNorm, b, array.get(cntNorm, b) + 1)
            sessionsUsed += 1
            globalMaxB := math.max(globalMaxB, maxBucketThis)
        haveSess := false

    // ---- start a new session ---------------------------------------------
    if startedNew
        array.fill(runHi, float(na))
        array.fill(runLo, float(na))
        sessHi := na
        sessLo := na
        hiBucket := 0
        loBucket := 0
        barsInSess := 0
        maxBucketThis := 0
        sessNorm := normUnit
        haveSess := true

    // ---- update the session in progress ----------------------------------
    if isSessBar and haveSess
        if na(sessHi) or high > sessHi
            sessHi := high
            hiBucket := bIdx
        if na(sessLo) or low < sessLo
            sessLo := low
            loBucket := bIdx
        barsInSess += 1
        maxBucketThis := math.max(maxBucketThis, bIdx)
        array.set(runHi, bIdx, sessHi)
        array.set(runLo, bIdx, sessLo)
        prevElapsed := elapsedMin

// ============================================================================
// Plots - live session against the mean of prior sessions at the same clock time
// ============================================================================
int nNormAtB = array.get(cntNorm, bIdx)

float curNorm = na
if showPlots and isSessBar and haveSess and not na(sessNorm) and sessNorm > 0
    curNorm := (sessHi - sessLo) / sessNorm

float histNorm = na
if showPlots and isSessBar and nNormAtB > 0
    histNorm := array.get(sumNorm, bIdx) / nNormAtB

plot(curNorm, "Session range so far (normalised)", color = #2962ff, linewidth = 2,
     style = plot.style_linebr)
plot(histNorm, "Mean at same time of day (normalised)", color = #787b86, linewidth = 1,
     style = plot.style_linebr)
bgcolor(isSessBar ? color.new(color.gray, 92) : color(na), title = "Session background")

// ============================================================================
// Table
// ============================================================================
//@function Map the position input to a position constant.
posOf(string p) =>
    switch p
        "Top left" => position.top_left
        "Bottom right" => position.bottom_right
        "Bottom left" => position.bottom_left
        "Middle right" => position.middle_right
        => position.top_right

//@function Map the text-size input to a size constant.
sizeOf(string s) =>
    switch s
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

//@function Format a percentage, or a dash when the sample is empty.
pctTxt(float v) =>
    na(v) ? "-" : str.tostring(v, "0.0") + "%"

// force_overlay draws the table on the price pane. In its own pane it collides
// with the two comparison plots, which is unreadable at any pane height.
var table tbl = table.new(posOf(tblPos), 7, maxRows + 3, border_width = 1,
     frame_color = color.new(color.gray, 60), frame_width = 1,
     border_color = color.new(color.gray, 70), force_overlay = true)

if barstate.islast and showTable
    table.clear(tbl, 0, 0, 6, maxRows + 2)
    color hdrBg = color.new(color.gray, 80)
    string ts = sizeOf(tblSize)

    if not tfOk
        table.cell(tbl, 0, 0, "Session Range Completion Clock needs an intraday chart timeframe.",
             text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
    else if not specOk
        table.cell(tbl, 0, 0, "Session string could not be read. Use a form such as 0930-1600.",
             text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
    else if sessionsUsed < 1
        table.cell(tbl, 0, 0, "No completed session in the loaded history matches this window and completeness filter.",
             text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
    else
        table.cell(tbl, 0, 0, "By", text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
        table.cell(tbl, 1, 0, "n", text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
        table.cell(tbl, 2, 0, "Range built", text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
        table.cell(tbl, 3, 0, "High set", text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
        table.cell(tbl, 4, 0, "Low set", text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
        table.cell(tbl, 5, 0, "Both set", text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)
        table.cell(tbl, 6, 0, "Range/unit", text_color = chart.fg_color, text_size = ts, bgcolor = hdrBg)

        int totalB = globalMaxB + 1
        int stride = math.max(1, int(math.ceil(totalB / float(maxRows))))
        int nRows = math.max(1, int(math.ceil(totalB / float(stride))))

        for k = 0 to nRows - 1
            int b = math.min(globalMaxB, (k + 1) * stride - 1)
            int r = k + 1
            int n = array.get(cntSess, b)
            int endMin = sessStartMin + math.min(sessLenMin, (b + 1) * bucketMin)
            float fBuilt = n > 0 ? 100.0 * array.get(sumFrac, b) / n : na
            float fHigh = n > 0 ? 100.0 * array.get(cntHiSet, b) / n : na
            float fLow = n > 0 ? 100.0 * array.get(cntLoSet, b) / n : na
            float fBoth = n > 0 ? 100.0 * array.get(cntBoth, b) / n : na
            int nN = array.get(cntNorm, b)
            string normTxt = nN > 0 ? str.tostring(array.get(sumNorm, b) / nN, "0.00") : "-"
            color rowBg = color(na)
            if not na(fBoth)
                rowBg := color.from_gradient(fBoth, 0, 100, color.new(color.gray, 90), color.new(#2962ff, 70))
            table.cell(tbl, 0, r, fmtHM(endMin), text_color = chart.fg_color, text_size = ts)
            table.cell(tbl, 1, r, str.tostring(n), text_color = chart.fg_color, text_size = ts)
            table.cell(tbl, 2, r, pctTxt(fBuilt), text_color = chart.fg_color, text_size = ts)
            table.cell(tbl, 3, r, pctTxt(fHigh), text_color = chart.fg_color, text_size = ts)
            table.cell(tbl, 4, r, pctTxt(fLow), text_color = chart.fg_color, text_size = ts)
            table.cell(tbl, 5, r, pctTxt(fBoth), text_color = chart.fg_color, text_size = ts, bgcolor = rowBg)
            table.cell(tbl, 6, r, normTxt, text_color = chart.fg_color, text_size = ts)

        int footR = nRows + 1
        string unitTxt = normMode == "Daily ATR" ? "ATR(" + str.tostring(atrLen) + ")D" : "Prev D range"
        // One merged, self-describing footer. Seven bare values across seven
        // columns read as an eighth data row, which is misleading - the numbers
        // in it are settings, not statistics.
        string footTxt = str.tostring(sessionsUsed) + " sessions  |  " + sessSpec +
             " " + sessTz + "  |  chart " + timeframe.period +
             "  |  bucket " + str.tostring(bucketMin) + "m  |  unit " + unitTxt
        table.cell(tbl, 0, footR, footTxt, text_color = color.new(chart.fg_color, 25),
             text_size = ts, bgcolor = hdrBg, text_halign = text.align_left)
        for c = 1 to 6
            table.cell(tbl, c, footR, "", bgcolor = hdrBg)
        table.merge_cells(tbl, 0, footR, 6, footR)
````
