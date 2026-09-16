<!-- tradingview-pine-id: PUB;64c1f77ddc464a35ae1c87e1c47a43e3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Streak statistics

Source: https://www.tradingview.com/script/W0Bn2RTf-Streak-statistics/

## Description

After four red bars, what actually happens? Your chart already knows.

Description

Counts every run of consecutive up closes and consecutive down closes on the loaded chart and reports, for each exact streak length, how often that streak extended by one more bar. The instrument's own base rate of up and down closes is shown alongside, so every continuation frequency can be read against what an ordinary bar does rather than against an imagined 50%.

How it calculates

Direction is close against prior close. Each time a streak reaches a length, that length's denominator increments; each time it extends by one more bar, the numerator increments. The figure at length three therefore answers exactly: of the streaks that reached three, what share became four. The final row pools every resolved opportunity at or beyond the configured cap.

Right-censoring is handled correctly. A streak enters a denominator only when its next bar is known, so the unfinished streak sitting at the chart edge is never silently counted as a failed continuation. Reset boundaries censor the preceding streak rather than treating the boundary or the overnight gap as a failure. A flat close terminates a streak without extending either side.

The sample is a precise rolling number of observed comparisons rather than an unknown quantity determined only by your chart plan's history allowance, and the date range actually in the window is reported in the header tooltip. The window is rebuilt when the sample changes, once per bar close, not on every price tick.

Each continuation rate carries its sample size and an optional 95% Wilson interval. A separate base-rate-centered stabilized estimate is available and is never substituted for the empirical frequency; both are shown.

How to read it

The first row shows the current streak and, when a resolved sample exists for that state, its historical continuation, opposite, and flat shares plus the lift against base. The base row shows the share of all observed moves that were up, down, and flat. Each length row shows the continuation share, the sample size, the interval, and the stabilized estimate, per direction, with the lift in percentage points beside it.

Emphasis marks a cell that is both materially different from its base rate and interval-separated from it. It marks a departure in either direction; the sign is carried by the lift column, never by colour alone.

Repainting

Closed bars do not repaint. The live bar never enters the sample.

Timeframe requirements

Any intraday timeframe when a reset mode is active. Calendar-day reset and custom-session reset both require an intraday chart, because on daily or higher a calendar-day reset would exclude every bar. Set reset mode to Never to run on daily and above.

Originality and attribution

Run counting is elementary probability. What is original here is the treatment: continuation frequency by exact streak length and direction, conditioned so each length's denominator is the number of streaks that actually reached it, correct right-censoring at the chart edge and at reset boundaries, a bounded rolling sample in observed moves rather than in chart history, and base rate, interval, and sample size shown rather than implied. This is not derived from and does not reuse code from any existing published script.

Honest limitations

Descriptive frequencies are not forecasts, signals, or proof of an edge.
Serial dependence means the Wilson intervals are descriptive uncertainty bands, not a complete market-microstructure hypothesis test.
Looking across many rows creates multiple-comparison risk. Emphasis requires both interval separation and a minimum effect you set, but that does not eliminate data-mining risk.
Rare long streaks stay rare. Stabilization reduces visual overreaction; it cannot manufacture information that is not in the sample.
Close-to-close direction counts overnight gaps unless a reset mode is on.
The rolling window is measured in observed comparisons, not clock time.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  Streak statistics
//  Empirical close-to-close transition statistics by exact streak state.
//
//  CORE QUESTION
//  After L consecutive up or down closes, what did the next observed bar do?
//  Continue, move the opposite way, or close flat? How different was that
//  continuation rate from the instrument's own directional base rate?
//
//  DATA INTEGRITY
//  • Confirmed bars only. The live bar never enters the sample.
//  • Right-censoring is handled correctly. A streak enters the denominator only
//    when its next bar is known; the unfinished streak at the chart edge is not
//    silently counted as a failed continuation.
//  • Reset boundaries censor the preceding streak instead of treating the
//    boundary or overnight gap as a failure.
//  • The sample is a precise rolling number of observed moves, not an unknown
//    quantity determined only by the user's chart-plan history allowance.
//  • Statistics are rebuilt when the sample changes, not on every price tick.
//  • Every raw percentage carries n. Wilson intervals communicate uncertainty.
//  • A base-rate-centered stabilized estimate is shown separately and never
//    substituted for the empirical frequency.
//
//  DEFINITIONS
//  Up move: current close > prior close.
//  Down move: current close < prior close.
//  Flat move: current close == prior close; flat terminates the active streak.
//  Length L: the state immediately before the next observed bar.
//  Final K+ row: all resolved bar-state opportunities whose length was >= K.
//  Lift: continuation frequency minus that direction's unconditional base rate.
//
//  LIMITATIONS
//  • Descriptive frequencies are not forecasts, signals, or proof of an edge.
//  • Serial dependence means Wilson intervals are descriptive uncertainty bands,
//    not a complete market-microstructure hypothesis test.
//  • Looking across many rows creates multiple-comparison risk. Emphasis
//    requires both interval separation and a user-defined minimum effect, but
//    this does not eliminate data-mining risk.
//  • Emphasis marks a cell as differing materially from its base rate. The sign
//    of that difference is carried by the lift column, never by colour alone.
//  • Rare long streaks remain rare. Stabilization reduces visual overreaction;
//    it cannot manufacture information that is not in the sample.
//  • The rolling window is measured in observed comparisons, not clock time.
// =============================================================================

indicator("Streak statistics", shorttitle = "Streaks", overlay = true)

// ─────────────────────────────────────────────────────────────────────────────
// Palette. Green is the label voice, amber is attention, grey is absence.
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
groupModel = "Model"
K = input.int(8, "Longest exact streak", minval = 4, maxval = 12, group = groupModel,
     tooltip = "Lengths below K are exact states. The final K+ row pools every resolved opportunity whose streak length was K or greater.")
sampleMoves = input.int(5000, "Rolling observed moves", options = [500, 1000, 2500, 5000, 10000], group = groupModel,
     tooltip = "The newest N valid close-to-close comparisons retained by the engine. Larger windows are rebuilt once per bar close, not per tick, but very large windows still cost time on fast charts.")
minSamples = input.int(30, "Minimum observations for emphasis", minval = 5, maxval = 500, group = groupModel)
priorStrength = input.float(20.0, "Stabilization strength", minval = 0.0, maxval = 200.0, step = 5.0, group = groupModel,
     tooltip = "Pseudo-observation strength of a Beta prior centered on the direction's base rate. Set to 0 to make the stabilized estimate equal the raw rate.")
minEffectPP = input.float(5.0, "Minimum lift for emphasis (pp)", minval = 0.0, maxval = 30.0, step = 0.5, group = groupModel)

groupReset = "Boundaries"
resetMode = input.string("Calendar day", "Reset mode",
     options = ["Never", "Calendar day", "Custom session"], group = groupReset,
     tooltip = "Never includes every close-to-close move. Calendar day excludes the first comparison of each selected-time-zone day. Custom session counts only consecutive bars inside that session.")
tzIn = input.string("exchange", "Time zone", group = groupReset,
     tooltip = "Enter exchange or an IANA zone such as America/New_York.")
customSession = input.session("0930-1600", "Custom active session", group = groupReset)

groupDisplay = "Display"
showCI = input.bool(true, "Show 95% Wilson intervals", group = groupDisplay)
showStabilized = input.bool(true, "Show stabilized estimate", group = groupDisplay)
showMarkers = input.bool(false, "Tint bars at the threshold streak length", group = groupDisplay)
alertLength = input.int(4, "Marker / alert length", minval = 2, maxval = 20, group = groupDisplay)
showTable = input.bool(true, "Show transition table", group = groupDisplay)
tblSize = input.string(size.tiny, "Table text size", options = [size.tiny, size.small, size.normal], group = groupDisplay)
tblPos = input.string(position.top_right, "Table position",
     options = [position.top_right, position.top_left, position.middle_right, position.middle_left,
                 position.bottom_right, position.bottom_left], group = groupDisplay)

string tz = tzIn == "exchange" ? syminfo.timezone : tzIn

if barstate.isfirst
    if resetMode == "Custom session" and not timeframe.isintraday
        runtime.error("Custom-session mode requires an intraday chart.")
    if resetMode == "Calendar day" and not timeframe.isintraday
        runtime.error("Calendar-day reset would exclude every bar on a daily-or-higher chart. Use Never on that timeframe.")

// ─────────────────────────────────────────────────────────────────────────────
// Event store
// Each column is one observed comparison.
// Row 0: resulting move direction (-1, 0, +1)
// Row 1: active streak direction before that move (-1, 0, +1)
// Row 2: active streak length before that move (uncapped)
// Row 3: continuation flag
// Row 4: event timestamp
// Only rows with prior direction != 0 are continuation opportunities.
// ─────────────────────────────────────────────────────────────────────────────
int MAX_EVENTS = 10000
var matrix<int> events = matrix.new<int>(5, MAX_EVENTS, 0)
// meta[0] = next write position, meta[1] = stored event count
var array<int> meta = array.from(0, 0)

var int currentDirection = 0
var int currentLength = 0
bool thresholdPulse = false

storeEvent(int moveDirection, int priorDirection, int priorLength, int continued, int stamp) =>
    int p = array.get(meta, 0)
    matrix.set(events, 0, p, moveDirection)
    matrix.set(events, 1, p, priorDirection)
    matrix.set(events, 2, p, priorLength)
    matrix.set(events, 3, p, continued)
    matrix.set(events, 4, p, stamp)
    array.set(meta, 0, (p + 1) % MAX_EVENTS)
    array.set(meta, 1, math.min(MAX_EVENTS, array.get(meta, 1) + 1))

eventIndex(int age) =>
    int p = array.get(meta, 0)
    (p - 1 - age + MAX_EVENTS * 2) % MAX_EVENTS

// ─────────────────────────────────────────────────────────────────────────────
// Boundary engine
// ─────────────────────────────────────────────────────────────────────────────
int dateId = year(time, tz) * 400 + month(time, tz) * 32 + dayofmonth(time, tz)
bool newCalendarDay = bar_index > 0 and dateId != dateId[1]
bool inCustomSession = not na(time(timeframe.period, customSession, tz))
bool newCustomSession = inCustomSession and (bar_index == 0 or not inCustomSession[1])

var bool sampleChanged = false
sampleChanged := false

if barstate.isconfirmed
    bool active = resetMode != "Custom session" or inCustomSession
    bool boundary = false
    if resetMode == "Calendar day"
        boundary := newCalendarDay
    if resetMode == "Custom session"
        boundary := newCustomSession

    if not active
        // The last in-session state is censored, not scored as a failure.
        currentDirection := 0
        currentLength := 0
    else if boundary
        // Skip the boundary comparison so an overnight gap never enters the run.
        currentDirection := 0
        currentLength := 0
    else if bar_index > 0 and not na(close[1])
        int moveDirection = close > close[1] ? 1 : close < close[1] ? -1 : 0
        int priorDirection = currentDirection
        int priorLength = currentLength
        int continued = priorDirection != 0 and moveDirection == priorDirection ? 1 : 0

        // The prior state is now resolved. If there was no prior state, this
        // event still belongs in the base-rate sample but not a streak denominator.
        storeEvent(moveDirection, priorDirection, priorLength, continued, time)
        sampleChanged := true

        if moveDirection == 0
            currentDirection := 0
            currentLength := 0
        else if moveDirection == priorDirection
            currentLength += 1
        else
            currentDirection := moveDirection
            currentLength := 1

        thresholdPulse := currentLength == alertLength

// ─────────────────────────────────────────────────────────────────────────────
// Statistical helpers
// ─────────────────────────────────────────────────────────────────────────────
percentText(float p) =>
    na(p) ? "—" : str.tostring(math.round(p * 1000.0) / 10.0) + "%"

ppText(float delta) =>
    string out = "—"
    if not na(delta)
        float pp = math.round(delta * 1000.0) / 10.0
        out := (pp > 0 ? "+" : "") + str.tostring(pp) + " pp"
    out

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

// Emphasis marks a material, interval-separated departure from the base rate in
// EITHER direction. The sign is carried by the lift column, never by hue alone.
cellColor(int n, int extensions, float baseRate) =>
    color out = MZ_MUTE
    if n >= minSamples and n > 0 and not na(baseRate)
        float raw = extensions / float(n)
        [lo, hi] = wilsonBounds(extensions, n)
        bool material = math.abs(raw - baseRate) * 100.0 >= minEffectPP
        bool separated = lo > baseRate or hi < baseRate
        out := material and separated ? MZ_AMBER : MZ_LIT
    out

rateCell(int n, int extensions, float baseRate) =>
    string out = "—"
    color cc = MZ_MUTE
    if n > 0
        float raw = extensions / float(n)
        float stabilized = (extensions + baseRate * priorStrength) / (n + priorStrength)
        out := percentText(raw) + " · n=" + str.tostring(n)
        if showCI
            [lo, hi] = wilsonBounds(extensions, n)
            out += "\nCI " + percentText(lo) + "–" + percentText(hi)
        if showStabilized
            out += "\nS " + percentText(stabilized)
        cc := cellColor(n, extensions, baseRate)
    [out, cc]

liftCell(int n, int extensions, float baseRate) =>
    string out = "—"
    color cc = MZ_MUTE
    if n > 0
        out := ppText(extensions / float(n) - baseRate)
        cc := cellColor(n, extensions, baseRate)
    [out, cc]

// ─────────────────────────────────────────────────────────────────────────────
// Rolling statistics, cached.
// The window is rebuilt when the sample actually changes: once on arrival at
// the last bar, then once per bar close. Live ticks render the cached counters
// instead of re-walking thousands of events on every price update.
// ─────────────────────────────────────────────────────────────────────────────
var array<int> reachUp = array.new_int(K, 0)
var array<int> contUp  = array.new_int(K, 0)
var array<int> oppUp   = array.new_int(K, 0)
var array<int> flatUp  = array.new_int(K, 0)
var array<int> reachDn = array.new_int(K, 0)
var array<int> contDn  = array.new_int(K, 0)
var array<int> oppDn   = array.new_int(K, 0)
var array<int> flatDn  = array.new_int(K, 0)

var float upBase = na
var float downBase = na
var float flatBase = na
var int usedMoves = 0
var int completedUpRuns = 0
var int completedDnRuns = 0
var int maxUpRunLength = 0
var int maxDnRunLength = 0
var float meanUpRun = na
var float meanDnRun = na
var int oldestStamp = na
var int newestStamp = na
var bool statsBuilt = false

bool rebuildNow = barstate.islast and (not statsBuilt or sampleChanged)

if rebuildNow
    statsBuilt := true
    array.fill(reachUp, 0)
    array.fill(contUp, 0)
    array.fill(oppUp, 0)
    array.fill(flatUp, 0)
    array.fill(reachDn, 0)
    array.fill(contDn, 0)
    array.fill(oppDn, 0)
    array.fill(flatDn, 0)

    int available = array.get(meta, 1)
    usedMoves := math.min(available, sampleMoves)
    int upMoves = 0
    int downMoves = 0
    int flatMoves = 0
    int sumUpRunLength = 0
    int sumDnRunLength = 0
    completedUpRuns := 0
    completedDnRuns := 0
    maxUpRunLength := 0
    maxDnRunLength := 0

    if usedMoves > 0
        for age = 0 to usedMoves - 1
            int idx = eventIndex(age)
            int moveDirection = matrix.get(events, 0, idx)
            int priorDirection = matrix.get(events, 1, idx)
            int priorLength = matrix.get(events, 2, idx)
            int continued = matrix.get(events, 3, idx)

            if moveDirection == 1
                upMoves += 1
            else if moveDirection == -1
                downMoves += 1
            else
                flatMoves += 1

            if priorDirection != 0 and priorLength > 0
                int bucket = math.min(priorLength, K) - 1
                if priorDirection == 1
                    array.set(reachUp, bucket, array.get(reachUp, bucket) + 1)
                    if continued == 1
                        array.set(contUp, bucket, array.get(contUp, bucket) + 1)
                    else
                        completedUpRuns += 1
                        sumUpRunLength += priorLength
                        maxUpRunLength := math.max(maxUpRunLength, priorLength)
                        if moveDirection == -1
                            array.set(oppUp, bucket, array.get(oppUp, bucket) + 1)
                        else
                            array.set(flatUp, bucket, array.get(flatUp, bucket) + 1)
                else
                    array.set(reachDn, bucket, array.get(reachDn, bucket) + 1)
                    if continued == 1
                        array.set(contDn, bucket, array.get(contDn, bucket) + 1)
                    else
                        completedDnRuns += 1
                        sumDnRunLength += priorLength
                        maxDnRunLength := math.max(maxDnRunLength, priorLength)
                        if moveDirection == 1
                            array.set(oppDn, bucket, array.get(oppDn, bucket) + 1)
                        else
                            array.set(flatDn, bucket, array.get(flatDn, bucket) + 1)

    int totalMoves = upMoves + downMoves + flatMoves
    upBase := totalMoves > 0 ? upMoves / float(totalMoves) : na
    downBase := totalMoves > 0 ? downMoves / float(totalMoves) : na
    flatBase := totalMoves > 0 ? flatMoves / float(totalMoves) : na
    meanUpRun := completedUpRuns > 0 ? sumUpRunLength / float(completedUpRuns) : na
    meanDnRun := completedDnRuns > 0 ? sumDnRunLength / float(completedDnRuns) : na
    oldestStamp := usedMoves > 0 ? matrix.get(events, 4, eventIndex(usedMoves - 1)) : na
    newestStamp := usedMoves > 0 ? matrix.get(events, 4, eventIndex(0)) : na

// ─────────────────────────────────────────────────────────────────────────────
// Transition table
// ─────────────────────────────────────────────────────────────────────────────
var table info = table.new(tblPos, 5, K + 4, border_width = 1, frame_width = 1,
     frame_color = color.new(MZ_MUTE, 50), border_color = color.new(MZ_MUTE, 75))
var bool headerMerged = false

if barstate.islast
    if showTable
        string sampleDates = usedMoves > 0 ? str.format_time(oldestStamp, "yyyy-MM-dd", tz) + " → " + str.format_time(newestStamp, "yyyy-MM-dd", tz) : "warming"
        string runDiagnostics = "Completed runs in window — up: n=" + str.tostring(completedUpRuns) +
             ", mean=" + (na(meanUpRun) ? "—" : str.tostring(math.round(meanUpRun * 10.0) / 10.0)) +
             ", max=" + str.tostring(maxUpRunLength) + " | down: n=" + str.tostring(completedDnRuns) +
             ", mean=" + (na(meanDnRun) ? "—" : str.tostring(math.round(meanDnRun * 10.0) / 10.0)) +
             ", max=" + str.tostring(maxDnRunLength)

        string currentText = resetMode == "Custom session" and not inCustomSession ? "outside active session" : "no active streak"
        color currentColor = MZ_MUTE
        if currentDirection != 0 and currentLength > 0
            int currentBucket = math.min(currentLength, K) - 1
            bool isUp = currentDirection == 1
            int nNow = isUp ? array.get(reachUp, currentBucket) : array.get(reachDn, currentBucket)
            int cNow = isUp ? array.get(contUp, currentBucket) : array.get(contDn, currentBucket)
            int oNow = isUp ? array.get(oppUp, currentBucket) : array.get(oppDn, currentBucket)
            int fNow = isUp ? array.get(flatUp, currentBucket) : array.get(flatDn, currentBucket)
            float baseNow = isUp ? upBase : downBase
            currentText := "current · " + str.tostring(currentLength) + " " + (isUp ? "up" : "down")
            if nNow > 0
                currentText += "  ·  cont " + percentText(cNow / float(nNow)) +
                     "  ·  opp " + percentText(oNow / float(nNow)) +
                     "  ·  flat " + percentText(fNow / float(nNow)) +
                     "  ·  Δ " + ppText(cNow / float(nNow) - baseNow) + "  ·  n=" + str.tostring(nNow)
            else
                currentText += "  ·  no resolved sample"
            currentColor := MZ_AMBER

        table.cell(info, 0, 0, "Streak transitions", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Correctly resolved next-bar outcomes. The unfinished current state is never entered as a failure.")
        table.cell(info, 0, 1, currentText, text_size = tblSize, text_color = currentColor, bgcolor = MZ_INK)
        table.cell(info, 0, 2,
             "base  up " + percentText(upBase) + " · down " + percentText(downBase) + " · flat " + percentText(flatBase) + "  |  " + str.tostring(usedMoves) + " moves",
             text_size = tblSize, text_color = MZ_LIT2, bgcolor = MZ_INK,
             tooltip = "Sample: " + sampleDates + "\n" + runDiagnostics + "\nEvery continuation rate should be read against its same-direction base rate, not automatically against 50%.")

        // Cells exist before the merge, so the merge cannot reference empty cells.
        if not headerMerged
            table.merge_cells(info, 0, 0, 4, 0)
            table.merge_cells(info, 0, 1, 4, 1)
            table.merge_cells(info, 0, 2, 4, 2)
            headerMerged := true

        table.cell(info, 0, 3, "State", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(info, 1, 3, "Up cont.", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Raw continuation frequency, resolved sample n, Wilson interval, and optional base-centered stabilized estimate S.")
        table.cell(info, 2, 3, "Up Δ base", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)
        table.cell(info, 3, 3, "Down cont.", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK,
             tooltip = "Raw continuation frequency, resolved sample n, Wilson interval, and optional base-centered stabilized estimate S.")
        table.cell(info, 4, 3, "Down Δ base", text_size = tblSize, text_color = MZ_GREEN, bgcolor = MZ_INK)

        for length = 1 to K
            int b = length - 1
            int uN = array.get(reachUp, b)
            int uC = array.get(contUp, b)
            int uO = array.get(oppUp, b)
            int uF = array.get(flatUp, b)
            int dN = array.get(reachDn, b)
            int dC = array.get(contDn, b)
            int dO = array.get(oppDn, b)
            int dF = array.get(flatDn, b)
            string stateText = length == K ? str.tostring(K) + "+" : str.tostring(length)
            bool currentRow = currentLength > 0 and math.min(currentLength, K) == length
            color stateColor = currentRow ? MZ_AMBER : MZ_LIT2
            [uRateText, uRateColor] = rateCell(uN, uC, upBase)
            [uLiftText, uLiftColor] = liftCell(uN, uC, upBase)
            [dRateText, dRateColor] = rateCell(dN, dC, downBase)
            [dLiftText, dLiftColor] = liftCell(dN, dC, downBase)
            string uTip = "After up state " + stateText + ": continued=" + str.tostring(uC) +
                 ", opposite=" + str.tostring(uO) + ", flat=" + str.tostring(uF) + ", total=" + str.tostring(uN)
            string dTip = "After down state " + stateText + ": continued=" + str.tostring(dC) +
                 ", opposite=" + str.tostring(dO) + ", flat=" + str.tostring(dF) + ", total=" + str.tostring(dN)

            table.cell(info, 0, length + 3, stateText, text_size = tblSize, text_color = stateColor, bgcolor = MZ_INK,
                 tooltip = length == K ? "K+ pools resolved opportunities at every streak state of length K or greater." : "Exact streak state length.")
            table.cell(info, 1, length + 3, uRateText, text_size = tblSize, text_color = uRateColor, bgcolor = MZ_INK, tooltip = uTip)
            table.cell(info, 2, length + 3, uLiftText, text_size = tblSize, text_color = uLiftColor, bgcolor = MZ_INK)
            table.cell(info, 3, length + 3, dRateText, text_size = tblSize, text_color = dRateColor, bgcolor = MZ_INK, tooltip = dTip)
            table.cell(info, 4, length + 3, dLiftText, text_size = tblSize, text_color = dLiftColor, bgcolor = MZ_INK)
    else
        table.clear(info, 0, 0, 4, K + 3)

// ─────────────────────────────────────────────────────────────────────────────
// Data-window diagnostics and alerts
// The threshold mark is a non-directional bar tint. This tool describes what
// streaks have done; it does not point anywhere, so it draws no arrows.
// ─────────────────────────────────────────────────────────────────────────────
plot(currentLength, "Current streak length", display = display.data_window)
plot(currentDirection, "Current streak direction", display = display.data_window)

bgcolor(showMarkers and thresholdPulse ? color.new(MZ_AMBER, 88) : na, title = "Threshold streak reached")

alertcondition(thresholdPulse and currentDirection == 1, "Up streak threshold",
     "An up-close streak reached the configured threshold on a confirmed bar.")
alertcondition(thresholdPulse and currentDirection == -1, "Down streak threshold",
     "A down-close streak reached the configured threshold on a confirmed bar.")
````
