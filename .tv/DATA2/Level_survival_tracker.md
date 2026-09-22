<!-- tradingview-pine-id: PUB;90926b29cc8942358976b3121415b344 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Level survival tracker

Source: https://www.tradingview.com/script/uqxo7Vc2-Level-survival-tracker/

## Description

Everyone trades PDH. Almost nobody knows their own numbers on it.

Description

Tracks six session reference levels every day: prior day high, prior day low, overnight high, overnight low, opening range high, opening range low. For each, over a rolling window of sessions, it reports the probability the level gets tested, the probability it breaks given a test, how failure probability changes with repeated tests, and the median rejection distance and time from first touch to break.

How it calculates

Prior day levels come from the last completed exchange daily bar via the documented non-repainting request idiom, or optionally from the previous custom chart session. Overnight high and low accumulate outside the session and freeze at the open; the opening range freezes when its window completes, and the bars that built it cannot also test it. A touch is a bar overlapping the level within a tolerance frozen at the session open, counted in episodes. A break is a confirmed close beyond the level plus tolerance, after a touch. A session whose open is already beyond a level, or where price closed through it without any bar ever overlapping it, is recorded as opened-beyond and excluded from every rate, because that level was never fairly testable. Completed sessions are written once, after the session ends.

The tolerance can be defined in ticks, points, a fraction of prior daily ATR, or a fraction of chart ATR. Statistics can be conditioned on the session's opening gap against the prior daily range, or on prior daily volatility versus its own 20-day mean. The break rate can display a 95% Wilson interval so the uncertainty is visible next to the point estimate. Break rates and touch-failure rates require their own minimum number of actual tests before anything is shown.

How to read it

Today's column shows each level's live state: untested, testing with its touch count, broke with the touch it broke on and the time, or opened beyond. P(test) is tests over eligible sessions. P(break | test) is breaks over actual tests, with the interval underneath if enabled. Touch failure answers: of past sessions that reached this many touches on this level, how often did the level eventually break. Reaction and time are the median rejection distance in points and the median minutes from first touch to confirmed break. Every figure carries its sample size, and figures below the minimums show the count instead of a percentage.

Repainting

Closed bars do not repaint. Touches and breaks are decided on confirmed bars only, and a session's outcomes enter history only after the session completes.

Originality and attribution

The levels are common knowledge. What is original is the survival accounting: episode-counted touches, conditional failure by touch number, opened-beyond exclusion, frozen per-session tolerance, regime conditioning, and interval-honest break rates with sample sizes shown. This is not derived from and does not reuse code from any existing published script.

Honest limitations

These are empirical frequencies, not forecasts or trade signals.
Intrabar path is unknowable from OHLC bars. A same-bar touch and break records as a first-touch break with zero measured rejection.
Overnight rows need extended-hours bars on the chart.
The session must not cross midnight in the chosen time zone.
Previous-RTH prior levels need one completed chart session to warm.
The chart timeframe must divide the session start and length exactly, so bars align to the session boundaries. For a 09:30 to 16:00 session that is 1, 2, 3, 5, 6, 10, 15, or 30 minutes. This is not a fixed ceiling: it follows your session. A session starting on the hour, such as 09:00 to 16:00 or 08:00 to 17:00, also accepts 20 and 60 minutes. Misaligned timeframes are refused rather than measured against fuzzy session boundaries, because a bar straddling the open would corrupt the opened-beyond classification, which reads the session-open price.
The opening range is rounded up to a whole number of chart bars, so no bar can straddle its boundary. On a 2-minute chart a 15-minute range becomes 16. The effective value is in the table header tooltip.
Results depend on instrument, session, tolerance, timeframe, and sample. Change any one and the numbers change.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  Level survival tracker
//  Empirical session-level survival analytics for PDH, PDL, ONH, ONL, ORH, ORL.
//
//  CORE QUESTION
//  When price reaches a commonly watched reference level, how often does that
//  level survive, how does failure probability change after repeated tests,
//  how far does rejection travel, and how long does failure usually take?
//
//  DATA INTEGRITY
//  • Decisions are made on confirmed bars only.
//  • Completed sessions are written once, after the session ends.
//  • "Opened beyond" uses the actual session-open price, never a closing price.
//  • Opened-beyond sessions are excluded from reachable/test denominators.
//  • Break statistics require their own minimum number of actual tests.
//  • Touch counting stops at failure, so post-break retests cannot corrupt Tn.
//  • The opening range is rounded up to a whole number of chart bars, so no
//    bar can straddle its boundary and leak post-range data into it.
//  • Prior exchange-daily requests use [1] + lookahead_on: completed bars only.
//
//  DEFINITIONS
//  Touch: the bar overlaps level ± frozen session tolerance.
//  New touch episode: contact begins after at least one bar outside the band.
//  Break: after a touch, a confirmed close exceeds level ± tolerance.
//  Tn failure: historical P(session eventually breaks | session reached touch n).
//  Rejection: maximum favorable excursion after first touch and before failure.
//  Opened beyond: session open is already through the level by more than
//    tolerance, or price later closed through it without any bar ever
//    overlapping it. Either way the level was never fairly testable.
//
//  LIMITATIONS
//  • These are empirical frequencies, not forecasts or trade signals.
//  • Intrabar path is unknowable from OHLC bars. A same-bar touch and break is
//    recorded as a T1 break with zero measured pre-break rejection.
//  • Overnight levels require extended-hours data on the chart.
//  • Custom sessions cannot cross midnight in the selected time zone.
//  • RTH-derived prior levels need one completed chart session to warm up.
//  • The chart timeframe must divide the session start and length exactly.
//    For a 09:30 to 16:00 session that is 1, 2, 3, 5, 6, 10, 15, or 30
//    minutes. This follows the session, it is not a fixed ceiling: a
//    session starting on the hour also accepts 20 and 60 minutes.
//  • Results depend on instrument, session, tolerance, timeframe, and sample.
// =============================================================================

indicator("Level survival tracker", shorttitle = "Levels", overlay = true,
     max_lines_count = 20, max_labels_count = 20)

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────
color MZ_GREEN = #54c98a
color MZ_AMBER = #d98a2b
color MZ_LIT   = #f5f4f0
color MZ_LIT2  = #b9b8b2
color MZ_MUTE  = #8b8983
color MZ_INK   = #16181c

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
groupSession = "Session"
tzIn    = input.string("America/New_York", "Time zone", group = groupSession,
     tooltip = "Use an IANA time zone. Enter exchange to use the symbol's exchange time zone.")
sStartH = input.int(9,  "Start hour",   minval = 0, maxval = 23, group = groupSession, inline = "s")
sStartM = input.int(30, "Start minute", minval = 0, maxval = 59, group = groupSession, inline = "s")
sEndH   = input.int(16, "End hour",     minval = 0, maxval = 23, group = groupSession, inline = "e")
sEndM   = input.int(0,  "End minute",   minval = 0, maxval = 59, group = groupSession, inline = "e")
orMin   = input.int(15, "Opening range (minutes)", minval = 5, maxval = 120, step = 5, group = groupSession)
pdMode  = input.string("Exchange daily", "Prior-day definition",
     options = ["Exchange daily", "Previous RTH"], group = groupSession,
     tooltip = "Exchange daily uses the last completed exchange daily candle. Previous RTH uses the preceding custom chart session.")

groupTolerance = "Tolerance"
tolMethod = input.string("Ticks", "Method",
     options = ["Ticks", "Points", "Daily ATR", "Intraday ATR"], group = groupTolerance)
tolTicks  = input.int(2, "Ticks", minval = 0, maxval = 100, group = groupTolerance, inline = "tv")
tolPoints = input.float(1.0, "Points", minval = 0.0, step = 0.25, group = groupTolerance, inline = "tv")
tolDatr   = input.float(0.02, "Daily ATR ×", minval = 0.0, maxval = 1.0, step = 0.01, group = groupTolerance, inline = "av")
tolIatr   = input.float(0.10, "Chart ATR ×", minval = 0.0, maxval = 1.0, step = 0.01, group = groupTolerance, inline = "av",
     tooltip = "Ticks, Points, and Daily ATR remain consistent when chart timeframe changes. Intraday ATR is chart-timeframe dependent.")

groupStats = "Statistics"
window      = input.int(60, "Rolling sessions", options = [20, 40, 60, 120, 250], group = groupStats)
minEligible = input.int(20, "Minimum eligible sessions", minval = 3, maxval = 250, group = groupStats)
minTests    = input.int(15, "Minimum actual tests", minval = 3, maxval = 250, group = groupStats)
regime      = input.string("All", "Condition sample on",
     options = ["All", "Gap above prior range", "Gap below prior range", "Inside prior range",
                 "High volatility", "Normal volatility", "Low volatility"], group = groupStats,
     tooltip = "Gap is classified from the session open versus the completed exchange-daily range. Volatility compares prior daily ATR(14) with its 20-day mean.")

groupDisplay = "Display"
showLines = input.bool(true, "Draw today's levels", group = groupDisplay)
showTable = input.bool(true, "Show survival table", group = groupDisplay)
showCI    = input.bool(true, "Show 95% Wilson interval", group = groupDisplay)
tblSize   = input.string(size.tiny, "Table text size", options = [size.tiny, size.small, size.normal], group = groupDisplay)
tblPos    = input.string(position.top_right, "Table position",
     options = [position.top_right, position.top_left, position.middle_right, position.middle_left,
                 position.bottom_right, position.bottom_left], group = groupDisplay)

// ─────────────────────────────────────────────────────────────────────────────
// Guards and clock
// ─────────────────────────────────────────────────────────────────────────────
float tfSec = timeframe.in_seconds()
int tfMin = int(math.round(tfSec / 60.0))
string tz = tzIn == "exchange" ? syminfo.timezone : tzIn
int startMin = sStartH * 60 + sStartM
int endMin = sEndH * 60 + sEndM
// The opening range is rounded UP to a whole number of chart bars. A bar
// that straddled the range boundary would leak post-range data into the
// high and low, so the range ends where a bar ends. On an aligned chart
// this changes nothing; on a 2-minute chart a 15-minute range becomes 16.
// The effective value is reported in the table header.
int effOR = int(math.ceil(float(orMin) / float(tfMin))) * tfMin
int orEnd = startMin + effOR

if barstate.isfirst
    if not timeframe.isintraday
        runtime.error("Level survival tracker requires an intraday chart. Session reference levels have no meaning on daily or higher.")
    if tfSec < 60 or tfSec % 60 != 0
        runtime.error("Use a whole-minute chart timeframe of 1 minute or higher.")
    if endMin <= startMin
        runtime.error("The selected session must end after it starts and cannot cross midnight in the chosen time zone.")
    if startMin % tfMin != 0 or (endMin - startMin) % tfMin != 0
        runtime.error("The chart timeframe must divide both the session start and the session length exactly, so that bars align to the session boundaries. For a 09:30 to 16:00 session use 1, 2, 3, 5, 6, 10, 15, or 30 minutes.")
    if orEnd >= endMin
        runtime.error("The opening range must finish before the session ends. Shorten the range or lengthen the session.")

int hh = hour(time, tz)
int mm = minute(time, tz)
int minuteOfDay = hh * 60 + mm
bool inSess = minuteOfDay >= startMin and minuteOfDay < endMin
int dateId = year(time, tz) * 400 + month(time, tz) * 32 + dayofmonth(time, tz)

// ─────────────────────────────────────────────────────────────────────────────
// Stable higher-timeframe references
// ─────────────────────────────────────────────────────────────────────────────
[exPDH, exPDL, prevDATR, prevDATRMean] = request.security(
     syminfo.tickerid, "D",
     [high[1], low[1], ta.atr(14)[1], ta.sma(ta.atr(14), 20)[1]],
     lookahead = barmerge.lookahead_on)

float chartATR = ta.atr(14)

// ─────────────────────────────────────────────────────────────────────────────
// Storage
// outcome: -1 empty, 0 untested, 1 held, 2 broke, 3 opened beyond
// gap: -1 below prior range, 0 inside prior range, 1 above prior range
// vol: -1 low, 0 normal, 1 high
// ─────────────────────────────────────────────────────────────────────────────
int NL = 6
int MAX_HISTORY = 250

var matrix<int> histOutcome = matrix.new<int>(NL, MAX_HISTORY, -1)
var matrix<int> histTouches = matrix.new<int>(NL, MAX_HISTORY, 0)
var matrix<int> histBreakT  = matrix.new<int>(NL, MAX_HISTORY, 0)
var matrix<int> histTTB     = matrix.new<int>(NL, MAX_HISTORY, -1)
var matrix<float> histMFE   = matrix.new<float>(NL, MAX_HISTORY, na)
var matrix<int> histGap     = matrix.new<int>(NL, MAX_HISTORY, 0)
var matrix<int> histVol     = matrix.new<int>(NL, MAX_HISTORY, 0)

var array<int> writePtr = array.new_int(NL, 0)
var array<int> storedN  = array.new_int(NL, 0)

var array<string> lvlNames = array.from("PDH", "PDL", "ONH", "ONL", "ORH", "ORL")
var array<bool> lvlUpper = array.from(true, false, true, false, true, false)

// Live per-level state
var array<float> lvlPx       = array.new_float(NL, na)
var array<bool> lvlOn        = array.new_bool(NL, false)
var array<bool> tTouched     = array.new_bool(NL, false)
var array<bool> tBroken      = array.new_bool(NL, false)
var array<bool> tOpenedPast  = array.new_bool(NL, false)
var array<int> tTouches      = array.new_int(NL, 0)
var array<bool> tInContact   = array.new_bool(NL, false)
var array<int> tFirstTime    = array.new_int(NL, -1)
var array<int> tBreakTime    = array.new_int(NL, -1)
var array<int> tBreakTouch   = array.new_int(NL, 0)
var array<int> tTTB          = array.new_int(NL, -1)
var array<float> tMFE        = array.new_float(NL, na)

var int currentSession = -1
var int sessionStartBar = -1
var float sessionOpen = na
var float frozenTol = na
var float overnightHigh = na
var float overnightLow = na
var float openingHigh = na
var float openingLow = na
var bool openingDone = false
var int openingActivationBar = -1
var bool sessionCommitted = true
var int currentGap = 0
var int currentVol = 0

// Completed custom-session range for Previous RTH mode
var float sessionHigh = na
var float sessionLow = na
var float priorRTHHigh = na
var float priorRTHLow = na

// Per-bar alert pulses
bool anyNewTouch = false
bool anyBreak = false

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
pad2(int n) =>
    n < 10 ? "0" + str.tostring(n) : str.tostring(n)

clockText(int mod) =>
    mod < 0 ? "—" : pad2(int(math.floor(mod / 60))) + ":" + pad2(mod % 60)

pct(float n, float d) =>
    d > 0 ? str.tostring(math.round(100.0 * n / d)) + "%" : "—"

wilson(int successes, int trials) =>
    string out = "—"
    if trials > 0
        float z = 1.95996398454
        float nn = trials
        float phat = successes / nn
        float den = 1.0 + z * z / nn
        float center = (phat + z * z / (2.0 * nn)) / den
        float margin = z * math.sqrt((phat * (1.0 - phat) + z * z / (4.0 * nn)) / nn) / den
        int lo = int(math.round(100.0 * math.max(0.0, center - margin)))
        int hi = int(math.round(100.0 * math.min(1.0, center + margin)))
        out := str.tostring(lo) + "–" + str.tostring(hi) + "%"
    out

passesRegime(int g, int v) =>
    bool ok = regime == "All"
    if regime == "Gap above prior range"
        ok := g == 1
    if regime == "Gap below prior range"
        ok := g == -1
    if regime == "Inside prior range"
        ok := g == 0
    if regime == "High volatility"
        ok := v == 1
    if regime == "Normal volatility"
        ok := v == 0
    if regime == "Low volatility"
        ok := v == -1
    ok

historyIndex(int li, int age) =>
    int p = array.get(writePtr, li)
    (p - 1 - age + MAX_HISTORY * 2) % MAX_HISTORY

sampleCount(int li) =>
    math.min(array.get(storedN, li), window)

resetLive() =>
    for li = 0 to NL - 1
        array.set(lvlPx, li, na)
        array.set(lvlOn, li, false)
        array.set(tTouched, li, false)
        array.set(tBroken, li, false)
        array.set(tOpenedPast, li, false)
        array.set(tTouches, li, 0)
        array.set(tInContact, li, false)
        array.set(tFirstTime, li, -1)
        array.set(tBreakTime, li, -1)
        array.set(tBreakTouch, li, 0)
        array.set(tTTB, li, -1)
        array.set(tMFE, li, na)

activateLevel(int li, float px, bool classifyOpen) =>
    bool ok = not na(px) and not na(frozenTol)
    array.set(lvlPx, li, px)
    array.set(lvlOn, li, ok)
    if ok and classifyOpen
        bool upper = array.get(lvlUpper, li)
        bool past = upper ? sessionOpen > px + frozenTol : sessionOpen < px - frozenTol
        array.set(tOpenedPast, li, past)

commitLevel(int li) =>
    if array.get(lvlOn, li)
        int outcome = array.get(tOpenedPast, li) ? 3 : array.get(tBroken, li) ? 2 : array.get(tTouched, li) ? 1 : 0
        int p = array.get(writePtr, li)
        matrix.set(histOutcome, li, p, outcome)
        matrix.set(histTouches, li, p, array.get(tTouches, li))
        matrix.set(histBreakT, li, p, array.get(tBreakTouch, li))
        matrix.set(histTTB, li, p, array.get(tTTB, li))
        matrix.set(histMFE, li, p, array.get(tMFE, li))
        matrix.set(histGap, li, p, currentGap)
        matrix.set(histVol, li, p, currentVol)
        array.set(writePtr, li, (p + 1) % MAX_HISTORY)
        array.set(storedN, li, math.min(MAX_HISTORY, array.get(storedN, li) + 1))

commitSession() =>
    for li = 0 to NL - 1
        commitLevel(li)

// Returns: total qualifying sessions, opened beyond, eligible, tested, broken.
baseStats(int li) =>
    int total = 0
    int ob = 0
    int eligible = 0
    int tested = 0
    int broken = 0
    int count = sampleCount(li)
    if count > 0
        for age = 0 to count - 1
            int idx = historyIndex(li, age)
            int code = matrix.get(histOutcome, li, idx)
            int g = matrix.get(histGap, li, idx)
            int v = matrix.get(histVol, li, idx)
            if code >= 0 and passesRegime(g, v)
                total += 1
                if code == 3
                    ob += 1
                else
                    eligible += 1
                    if code == 1 or code == 2
                        tested += 1
                    if code == 2
                        broken += 1
    [total, ob, eligible, tested, broken]

// Eventual failure probability among sessions that reached touch threshold.
touchStats(int li, int threshold) =>
    int reached = 0
    int failed = 0
    int count = sampleCount(li)
    if count > 0
        for age = 0 to count - 1
            int idx = historyIndex(li, age)
            int code = matrix.get(histOutcome, li, idx)
            int g = matrix.get(histGap, li, idx)
            int v = matrix.get(histVol, li, idx)
            int touches = matrix.get(histTouches, li, idx)
            if passesRegime(g, v) and (code == 1 or code == 2) and touches >= threshold
                reached += 1
                if code == 2
                    failed += 1
    [failed, reached]

medianMetric(int li, bool timeMetric) =>
    var array<float> vals = array.new_float(0)
    array.clear(vals)
    int count = sampleCount(li)
    if count > 0
        for age = 0 to count - 1
            int idx = historyIndex(li, age)
            int code = matrix.get(histOutcome, li, idx)
            int g = matrix.get(histGap, li, idx)
            int v = matrix.get(histVol, li, idx)
            if passesRegime(g, v)
                float value = timeMetric ? float(matrix.get(histTTB, li, idx)) : matrix.get(histMFE, li, idx)
                bool valid = timeMetric ? code == 2 and value >= 0 : (code == 1 or code == 2) and not na(value)
                if valid
                    array.push(vals, value)
    float med = na
    int n = array.size(vals)
    if n > 0
        array.sort(vals)
        int mid = int(math.floor(n / 2))
        med := n % 2 == 1 ? array.get(vals, mid) : (array.get(vals, mid - 1) + array.get(vals, mid)) / 2.0
    med

// ─────────────────────────────────────────────────────────────────────────────
// Confirmed-bar session engine
// ─────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    // Build the next session's overnight range only outside the selected RTH.
    if not inSess
        overnightHigh := na(overnightHigh) ? high : math.max(overnightHigh, high)
        overnightLow  := na(overnightLow)  ? low  : math.min(overnightLow, low)

    bool newSession = inSess and dateId != currentSession

    if newSession
        // Charts with no out-of-session bars commit the prior day here.
        if currentSession != -1 and not sessionCommitted
            commitSession()
            sessionCommitted := true

        // Preserve the completed custom session before resetting it.
        if currentSession != -1 and not na(sessionHigh) and not na(sessionLow)
            priorRTHHigh := sessionHigh
            priorRTHLow := sessionLow

        resetLive()
        currentSession := dateId
        sessionStartBar := bar_index
        sessionOpen := open
        sessionHigh := high
        sessionLow := low

        frozenTol := switch tolMethod
            "Ticks"        => syminfo.mintick * tolTicks
            "Points"       => tolPoints
            "Daily ATR"    => prevDATR * tolDatr
            => chartATR * tolIatr

        currentGap := not na(exPDH) and sessionOpen > exPDH ? 1 : not na(exPDL) and sessionOpen < exPDL ? -1 : 0
        float volRatio = not na(prevDATR) and not na(prevDATRMean) and prevDATRMean > 0 ? prevDATR / prevDATRMean : 1.0
        currentVol := volRatio >= 1.20 ? 1 : volRatio <= 0.80 ? -1 : 0

        float pdh = pdMode == "Previous RTH" ? priorRTHHigh : exPDH
        float pdl = pdMode == "Previous RTH" ? priorRTHLow : exPDL
        activateLevel(0, pdh, true)
        activateLevel(1, pdl, true)
        activateLevel(2, overnightHigh, true)
        activateLevel(3, overnightLow, true)

        overnightHigh := na
        overnightLow := na
        openingHigh := high
        openingLow := low
        openingDone := false
        openingActivationBar := -1
        sessionCommitted := false

    // A visible post-session bar commits immediately. Otherwise next open does it.
    if not inSess and currentSession == dateId and currentSession != -1 and not sessionCommitted
        commitSession()
        sessionCommitted := true

    if inSess and dateId == currentSession
        sessionHigh := math.max(sessionHigh, high)
        sessionLow := math.min(sessionLow, low)

        // Because divisibility is guarded, the final included bar closes exactly
        // at orEnd; no post-OR data can leak into the range.
        if not openingDone and minuteOfDay < orEnd
            openingHigh := math.max(openingHigh, high)
            openingLow := math.min(openingLow, low)
            if minuteOfDay + tfMin >= orEnd
                openingDone := true
                openingActivationBar := bar_index
                activateLevel(4, openingHigh, false)
                activateLevel(5, openingLow, false)

        for li = 0 to NL - 1
            // The bars used to construct ORH/ORL cannot also test those levels.
            if li >= 4 and bar_index == openingActivationBar
                continue

            if array.get(lvlOn, li) and not array.get(tOpenedPast, li) and not array.get(tBroken, li)
                float px = array.get(lvlPx, li)
                bool contact = low <= px + frozenTol and high >= px - frozenTol
                bool newEpisode = contact and not array.get(tInContact, li)

                if newEpisode
                    int nextTouch = array.get(tTouches, li) + 1
                    array.set(tTouches, li, nextTouch)
                    array.set(tTouched, li, true)
                    anyNewTouch := true
                    if array.get(tFirstTime, li) < 0
                        array.set(tFirstTime, li, minuteOfDay)
                        array.set(tMFE, li, 0.0)

                array.set(tInContact, li, contact)

                bool upper = array.get(lvlUpper, li)
                bool crossed = upper ? close > px + frozenTol : close < px - frozenTol

                if crossed and not array.get(tTouched, li)
                    // Price closed through the level without any bar ever
                    // overlapping it (halt reopen, limit move). The level was
                    // never fairly testable, so it joins the opened-beyond
                    // class and is excluded from the rates.
                    array.set(tOpenedPast, li, true)
                else if crossed and array.get(tTouched, li)
                    array.set(tBroken, li, true)
                    array.set(tBreakTime, li, minuteOfDay)
                    array.set(tBreakTouch, li, array.get(tTouches, li))
                    int firstMod = array.get(tFirstTime, li)
                    array.set(tTTB, li, firstMod >= 0 ? math.max(0, minuteOfDay - firstMod) : 0)
                    anyBreak := true
                else if array.get(tTouched, li)
                    float favorable = upper ? math.max(0.0, px - low) : math.max(0.0, high - px)
                    float oldMFE = array.get(tMFE, li)
                    array.set(tMFE, li, na(oldMFE) ? favorable : math.max(oldMFE, favorable))

// ─────────────────────────────────────────────────────────────────────────────
// Today's chart levels
// ─────────────────────────────────────────────────────────────────────────────
var array<line> levelLines = array.new<line>(0)
var array<label> levelLabels = array.new<label>(0)

if barstate.islast
    if array.size(levelLines) == 0
        for li = 0 to NL - 1
            array.push(levelLines, line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index,
                 color = color.new(MZ_MUTE, 100), width = 1))
            array.push(levelLabels, label.new(bar_index, close, "", xloc = xloc.bar_index,
                 style = label.style_label_left, color = color.new(MZ_INK, 100), textcolor = MZ_LIT2, size = size.tiny))

    for li = 0 to NL - 1
        line ln = array.get(levelLines, li)
        label lb = array.get(levelLabels, li)
        bool visible = showLines and array.get(lvlOn, li)
        if visible
            float px = array.get(lvlPx, li)
            color lc = color.new(MZ_MUTE, 35)
            string ls = line.style_dotted
            if array.get(tOpenedPast, li)
                lc := color.new(MZ_MUTE, 70)
                ls := line.style_dashed
            else if array.get(tBroken, li)
                lc := color.new(MZ_LIT2, 45)
                ls := line.style_solid
            else if array.get(tTouched, li)
                lc := color.new(MZ_AMBER, 10)
                ls := line.style_solid
            line.set_xy1(ln, sessionStartBar, px)
            line.set_xy2(ln, bar_index + 8, px)
            line.set_color(ln, lc)
            line.set_style(ln, ls)
            label.set_xy(lb, bar_index + 8, px)
            label.set_text(lb, array.get(lvlNames, li))
            label.set_textcolor(lb, lc)
        else
            line.set_xy1(ln, bar_index, close)
            line.set_xy2(ln, bar_index, close)
            line.set_color(ln, color.new(MZ_MUTE, 100))
            label.set_text(lb, "")

// ─────────────────────────────────────────────────────────────────────────────
// Survival table
// ─────────────────────────────────────────────────────────────────────────────
var table info = table.new(tblPos, 6, NL + 2, border_width = 1, frame_width = 1,
     frame_color = color.new(MZ_MUTE, 50), border_color = color.new(MZ_MUTE, 75))

if barstate.isfirst
    table.merge_cells(info, 0, 0, 5, 0)

if barstate.islast
    if showTable
        string regimeShort = regime == "All" ? "all" : regime
        string headTip = "Rolling window: " + str.tostring(window) + " sessions. Opening range in use: " + str.tostring(effOR) + " minutes" + (effOR != orMin ? " (rounded up from " + str.tostring(orMin) + " to fit whole chart bars)" : "") + ". Condition: " + regimeShort + "."
        table.cell(info, 0, 0, "Level survival", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK, tooltip = headTip)
        table.cell(info, 0, 1, "Level", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(info, 1, 1, "Today", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(info, 2, 1, "P(test)", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Tests / eligible sessions. Opened-beyond sessions are excluded.")
        table.cell(info, 3, 1, "P(break | test)", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Breaks / actual tests. The optional second line is a 95% Wilson confidence interval.")
        table.cell(info, 4, 1, "Touch failure", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "P(eventual session break | the session reached the displayed touch number). This is empirical conditional failure, not a forecast.")
        table.cell(info, 5, 1, "Reaction / time", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Median maximum favorable rejection in price points / median minutes from first touch to confirmed break.")

        for li = 0 to NL - 1
            [total, ob, eligible, tested, broken] = baseStats(li)
            int touchesNow = array.get(tTouches, li)
            int hazardTouch = math.max(1, touchesNow)
            [touchFailed, touchReached] = touchStats(li, hazardTouch)

            string today = "warming"
            color todayColor = MZ_MUTE
            if array.get(lvlOn, li)
                if array.get(tOpenedPast, li)
                    today := "opened beyond"
                else if array.get(tBroken, li)
                    today := "broke · T" + str.tostring(array.get(tBreakTouch, li)) + " · " + clockText(array.get(tBreakTime, li))
                    todayColor := MZ_LIT2
                else if array.get(tTouched, li)
                    today := "testing · T" + str.tostring(touchesNow)
                    todayColor := MZ_AMBER
                else
                    today := "untested"

            bool enoughEligible = eligible >= minEligible
            bool enoughTests = tested >= minTests
            string testText = enoughEligible ? pct(tested, eligible) + " · n=" + str.tostring(eligible) : str.tostring(eligible) + "/" + str.tostring(minEligible)
            string breakText = enoughTests ? pct(broken, tested) + " · n=" + str.tostring(tested) : str.tostring(tested) + "/" + str.tostring(minTests)
            if enoughTests and showCI
                breakText += "\n" + wilson(broken, tested)

            string hazardText = touchReached >= minTests ? "T" + str.tostring(hazardTouch) + "  " + pct(touchFailed, touchReached) + " · n=" + str.tostring(touchReached) : "T" + str.tostring(hazardTouch) + "  " + str.tostring(touchReached) + "/" + str.tostring(minTests)
            float medMFE = medianMetric(li, false)
            float medTTB = medianMetric(li, true)
            string reactionText = (na(medMFE) ? "—" : str.tostring(medMFE, format.mintick) + " pt") + " / " + (na(medTTB) ? "—" : str.tostring(math.round(medTTB)) + "m")

            table.cell(info, 0, li + 2, array.get(lvlNames, li), text_size = tblSize, text_color = MZ_LIT2, bgcolor = MZ_INK)
            table.cell(info, 1, li + 2, today, text_size = tblSize, text_color = todayColor, bgcolor = MZ_INK)
            table.cell(info, 2, li + 2, testText, text_size = tblSize, text_color = enoughEligible ? MZ_LIT : MZ_MUTE, bgcolor = MZ_INK,
                 tooltip = "Qualifying sessions: " + str.tostring(total) + " | Opened beyond: " + str.tostring(ob) + " | Regime: " + regimeShort)
            table.cell(info, 3, li + 2, breakText, text_size = tblSize, text_color = enoughTests ? MZ_LIT : MZ_MUTE, bgcolor = MZ_INK)
            table.cell(info, 4, li + 2, hazardText, text_size = tblSize, text_color = touchReached >= minTests ? MZ_LIT : MZ_MUTE, bgcolor = MZ_INK)
            table.cell(info, 5, li + 2, reactionText, text_size = tblSize, text_color = MZ_LIT2, bgcolor = MZ_INK)
    else
        table.clear(info, 0, 0, 5, NL + 1)

// ─────────────────────────────────────────────────────────────────────────────
// Alerts. Create a TradingView alert using either condition.
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(anyNewTouch, "New level touch", "A tracked level began a new touch episode.")
alertcondition(anyBreak, "Confirmed level break", "A tracked level closed through its frozen tolerance after being tested.")
````
