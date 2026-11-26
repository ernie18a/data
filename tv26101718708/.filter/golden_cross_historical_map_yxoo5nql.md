# Golden Cross Historical Map

- url: https://www.tradingview.com/script/yxoO5NQL-Golden-Cross-Historical-Map/
- type: indicator
- pine_id: PUB;6298e66bd26242818bef43d58eb3ca6b
- version: 1.0

## Description

[b]Quick start[/b]
Golden Cross Historical Map compares the latest confirmed daily golden-cross cycle with earlier cycles from the same market. It is a descriptive indicator, not a trading strategy or price forecast.
[list=1]
[*]Use a standard, UTC-aligned, 24-hour crypto chart on 1D. Synthetic charts and session-based daily feeds are unsupported.
[*]Chart-follow is enabled by default; use KRAKEN:BTCUSD for the intended Bitcoin/USD comparison. Disable chart-follow to choose an independent study source; the manual fallback is KRAKEN:BTCUSD.
[*]Defaults: SMA50/200, Post-2013, 90-day view, live display, historical prices and milestone summary on. Cohort comparison, individual paths and alerts are off; Post-2015, full available history and a 180-day view are selectable.
[/list]

[b]What does this indicator help you understand?[/b]
A golden cross identifies a change in the moving-average trend, but it does not tell you how the following weeks will unfold. This indicator adds historical context: it compares the current cycle with earlier golden-cross cycles from the same selected market, aligned by days since the cross.

It helps answer several practical questions:

[list]
[*][b]Is the current cycle stronger or weaker than previous cycles at this stage?[/b] Compare its return with the historical median and percentile bands at the same elapsed day.
[*][b]How varied were the historical outcomes?[/b] The bands show the spread between earlier cycles. Wide bands indicate that similar starting events produced substantially different results.
[*][b]Is the current pullback unusually deep?[/b] Maximum drawdown compares the current cycle's worst daily-close decline from a preceding peak with historical drawdowns through the same day.
[*][b]What happened at later milestones?[/b] The day 30/60/90/180 summary shows historical median returns, available sample counts and the proportion of outcomes above their cross-day starting price.
[*][b]How sensitive is the picture to the historical sample?[/b] Comparing date cohorts helps reveal whether older cycles materially change the reference.
[/list]

[b]Can it predict what happens next?[/b]
The historical paths provide a reference for possible scenarios, rather than a validated prediction of the current cycle. They show what followed comparable events previously; they do not establish that today's market will repeat those outcomes.

For example, a historical median of +20% at day 60 means the median eligible prior-cycle return was +20% from its own cross-day close. It does not predict a further 20% rise from today's price.

Likewise, an 80% percentile band is a historical range at each individual day—not an 80% probability that the current cycle will remain inside the band throughout the entire period. The Positive percentage is an observed historical frequency, not a forecast success rate.

Use the indicator to judge relative strength, historical variability and experienced drawdown, and to frame expectations with context. Small, overlapping samples and changing market conditions limit how confidently those observations can be carried forward.

[b]Reading the chart[/b]
[list]
[*][b]Aqua median:[/b] the historical median return at each elapsed day.
[*][b]P25-P75 / P10-P90:[/b] the middle 50% / 80% percentile ranges of prior-cycle returns, using linear interpolation. These describe historical spread, not confidence intervals or forecast probabilities.
[*][b]Solid orange:[/b] confirmed current-cycle closes, normalized to its cross-day close. Endpoint labels and day markers identify the observed day.
[*][b]Live orange point:[/b] a provisional selected-source quote; an adjacent-day dashed extension never bridges missing dates.
[/list]

[b]Dashboard and milestones[/b]
[list]
[*][b]Difference:[/b] displayed return minus same-day median, in percentage points.
[*][b]Rank and context:[/b] descriptive comparisons with available peers, not trading signals. Exact ties are disclosed; percentile-band boundaries are inclusive.
[*][b]Price references:[/b] anchor multiplied by one plus the historical return, in the selected source's currency. They are historical equivalents, not targets; USD and USDT feeds are distinct and never pooled.
[*][b]n:[/b] earlier cycles with an available outcome on that exact day, excluding the current cycle.
[*][b]Positive:[/b] count of closing returns strictly above zero from each cycle's own cross close, divided by n for the displayed percentage. Equal counts at different horizons need not involve the same cycles or imply forecast probabilities.
[/list]
The milestone summary retains days 30, 60, 90 and 180 in either view.

[b]How the historical sample is built[/b]
A cross occurs when daily SMA50 exceeds SMA200 after being at or below it on the previous source bar; both lengths are configurable. Available pre-cutoff data provides moving-average warmup.
[list]
[*]Day 0 is the cross close; returns are percentage changes from that anchor on exact calendar dates.
[*]The current cycle is excluded. References freeze at its confirmed cross close: only earlier outcomes already available then contribute.
[*]Missing outcomes stay unavailable, so counts vary. Overlapping crosses are retained and observations are dependent; date cutoffs are comparison choices, not proven maturity boundaries.
[/list]

[b]Live view and drawdown[/b]
Live return, rank and context can fluctuate without changing confirmed events, closed paths or frozen references. Manual quotes refresh with host-chart updates, not a guaranteed independent source tickstream; stale or non-forming quotes are not labelled live.
[b]Maximum drawdown[/b] is the worst negative daily-close peak-to-trough return since the cross, including its anchor. Its historical median is calculated from individual cycles through the same day, not from the median curve; complete daily-close windows are required.
Missing current history is marked observed only. A live quote acts as a provisional next close without mutating confirmed drawdown.

[b]Optional features and alerts[/b]
Cohort comparison shares one source, anchor, day and freeze date. Optional gray paths show up to ten newest prior cycles; missing/unmatured dates remain gaps and omitted fragmented paths are disclosed.
[list=1]
[*]Enable the alert master and desired milestone, median-cross or P10-P90 exit types.
[*]Create a TradingView alert using Any alert() function call.
[*]Recreate it after changing script settings or source/code.
[/list]
Alerts use confirmed source closes, available at the next source day opening. Initial attachment arms silently; skipped days do not produce retrospective notifications.

[b]Limits[/b]
Requested history is capped at 20,000 bars and 100 retained crosses; optional paths have a 64-segment budget. Historical paths and drawdown peers stop at day 180, while current observed drawdown continues.
Samples may be small; feed composition, provider revisions and coverage affect results. Replay, full source rollover/reconnect behaviour and actual server-alert delivery remain unverified; past observations do not guarantee future results.

[b]Inspiration[/b]
Conceptual inspiration: Krown's discussion of golden-cross historical paths. This independent implementation uses no Krown code or private dataset and claims no affiliation or endorsement.

## Source Code

````pine
//@version=6
indicator("Golden Cross Historical Map", overlay = false, max_polylines_count = 100, max_labels_count = 20, max_lines_count = 10)

// A daily, source-selectable historical study. All observations commit on closed bars.
string chosenSymbol = input.symbol("KRAKEN:BTCUSD", "Study source", tooltip = "Used when Use chart symbol instead is off. Its own daily history is studied independently of the chart symbol; for example, KRAKEN:BTCUSD on another crypto chart.", group = "Sample")
bool useChart = input.bool(true, "Use chart symbol instead", tooltip = "Default: study the chart symbol. Turn off to study the manually selected source on this chart.", group = "Sample")
string cohort = input.string("Post-2013", "Cross-date cohort", options = ["Post-2015", "Post-2013", "Full loaded history"], group = "Sample")
int fastLength = input.int(50, "Fast daily SMA", minval = 2, maxval = 250, group = "Method")
int slowLength = input.int(200, "Slow daily SMA", minval = 3, maxval = 500, group = "Method")
string view = input.string("90 days", "Path view", options = ["90 days", "180 days"], group = "Display")
bool showDetails = input.bool(false, "Show detailed dashboard", group = "Display")
int horizon = view == "90 days" ? 90 : 180
bool showOuter = input.bool(true, "Show P10–P90 band", tooltip = "For each day since the cross, shows the 10th to 90th percentiles of prior cycles' percentage RETURNS from their cross-day closes: the middle 80% of the historical return distribution. Descriptive spread, not a confidence band or forecast probability.", group = "Display")
bool showInner = input.bool(true, "Show P25–P75 band", tooltip = "For each day since the cross, shows the 25th to 75th percentiles of prior cycles' percentage RETURNS from their cross-day closes: the middle 50% of the historical return distribution. Descriptive spread, not a confidence band or forecast probability.", group = "Display")
bool liveMode = input.bool(true, "Show provisional live cycle", tooltip = "Shows the selected source's forming daily quote separately. It can fluctuate intraday; closed events and historical bands remain frozen. Quote refresh follows host chart updates.", group = "Display")
bool showPrices = input.bool(true, "Show historical price references", tooltip = "Converts the same-day historical median and P25–P75 returns using this selected source cycle's anchor. Historical references, not targets; currency belongs to the selected source.", group = "Display")
bool compareCohorts = input.bool(false, "Compare date cohorts", tooltip = "Shows Post-2013, Post-2015 and Full source-history same-day medians with available n at the same latest-cross freeze date. Feeds are never pooled.", group = "Display")
bool showHistoricalPaths = input.bool(false, "Show individual historical paths", tooltip = "Adds the newest selected prior cycles as thin gray return paths. Current cycle is excluded; only outcomes known at its cross are shown. Missing dates remain gaps.", group = "Display")
int maxHistoricalPaths = input.int(10, "Maximum historical paths", minval = 1, maxval = 10, tooltip = "Newest prior cycles first. Fragmented paths may be skipped to reserve drawing capacity for the main bands and curves.", group = "Display", display = display.none)
bool showMilestoneSummary = input.bool(true, "Show milestone summary", tooltip = "Shows frozen prior-cycle median returns and strictly positive outcomes at days30/60/90/180, even in the90-day view. Counts refer to available exact-day outcomes.", group = "Display")
bool enableAlerts = input.bool(false, "Enable confirmed-source alerts", tooltip = "Off by default. Configure a TradingView alert on Any alert() function call yourself. Arms on the first realtime update without alerting stale data; uses newly available closed source days only, never provisional quotes.", group = "Alerts")
bool alertMilestones = input.bool(true, "Alert exact milestones", tooltip = "Under the master switch: confirmed source days30/60/90/180, with no skipped monitored/source dates. Reports reference unavailable when n=0.", group = "Alerts")
bool alertMedianCross = input.bool(true, "Alert median crossings", tooltip = "Under the master switch: compares consecutive confirmed returns against each day's frozen median. An exact prior-day tie can cross; a current-day tie does not.", group = "Alerts")
bool alertBandExit = input.bool(true, "Alert P10–P90 exits", tooltip = "Under the master switch: yesterday's confirmed return inside inclusive P10–P90, today's below P10 or above P90. Re-entry permits a later exit alert.", group = "Alerts")
int DAY = 86400000
int storageHorizon = math.max(horizon, 180)
int cutoff = cohort == "Post-2015" ? timestamp("UTC", 2015, 1, 1, 0, 0) : cohort == "Post-2013" ? timestamp("UTC", 2013, 1, 1, 0, 0) : 0
string source = ticker.standard(useChart ? syminfo.tickerid : chosenSymbol)
if not timeframe.isdaily or timeframe.multiplier != 1
    runtime.error("Use a 1D chart. This study commits confirmed daily source bars only.")
if not chart.is_standard
    runtime.error("Use standard candles or bars, not a synthetic chart type.")
if time % DAY != 0 or time_close - time != DAY
    runtime.error("Use a UTC-aligned 24/7 crypto 1D host chart.")
if fastLength >= slowLength
    runtime.error("Fast SMA length must be smaller than slow SMA length.")

type Event
    int started
    float anchor
    array<float> path
    float trough
    int troughDay
    int lowCount
    float closingPeak
    float maxDrawdown
    int closeCount
    array<float> drawdowns

// Only a bounded display snapshot crosses the request boundary, not event histories.
type Snapshot
    int firstTime
    int lastTime
    int firstUsable
    int observed
    int missingDays
    int droppedEvents
    int eventCount
    int started
    float anchor
    int age
    float currentReturn
    float trough
    int troughDay
    int lowCount
    array<float> path
    array<float> median
    array<float> p10
    array<float> p25
    array<float> p75
    array<float> p90
    array<int> counts
    array<float> rankValues
    int livePeerDay
    array<float> liveRankValues
    array<float> horizonMedians
    array<int> horizonNs
    array<int> horizonPositives
    array<float> cohortClosedMedians
    array<int> cohortClosedNs
    array<float> cohortLiveMedians
    array<int> cohortLiveNs
    float closingPeak
    float maxDrawdown
    bool completeClosedCloses
    float closedDrawdownMedian
    int closedDrawdownN
    float liveDrawdownMedian
    int liveDrawdownN
    array<float> historicalFlat
    int historicalCount
    int historicalEligible
    int previousSourceTime
    float previousReturn
    float previousMedian
    float previousP10
    float previousP90
    int previousN

f_quantile(array<float> sorted, float p) =>
    int n = array.size(sorted)
    float result = na
    if n > 0
        float rank = (n - 1) * p
        int lower = int(math.floor(rank))
        int upper = int(math.ceil(rank))
        result := array.get(sorted, lower) + (array.get(sorted, upper) - array.get(sorted, lower)) * (rank - lower)
    result

// Eligibility is frozen at the latest cross, including which horizon outcomes existed then.
f_values(array<Event> events, int d, int frozenAt, int eventCutoff) =>
    array<float> values = array.new<float>()
    if array.size(events) > 1
        for i = 0 to array.size(events) - 2
            Event e = array.get(events, i)
            if e.started >= eventCutoff and e.started + d * DAY <= frozenAt
                float value = array.get(e.path, d)
                if not na(value)
                    array.push(values, value)
    array.sort(values)
    values

// Median of INDIVIDUAL daily-close maximum drawdowns, never of the median return curve.
f_drawdown_values(array<Event> events, int d, int frozenAt, int eventCutoff) =>
    array<float> values = array.new<float>()
    if d >= 0 and d <= storageHorizon and array.size(events) > 1
        for i = 0 to array.size(events) - 2
            Event e = array.get(events, i)
            if e.started >= eventCutoff and e.started + d * DAY <= frozenAt
                float value = array.get(e.drawdowns, d)
                if not na(value)
                    array.push(values, value)
    array.sort(values)
    values

f_pct(float value) =>
    na(value) ? "n/a" : (value > 0 ? "+" : "") + str.tostring(value, "#.##") + "%"

f_date(int value) =>
    na(value) ? "n/a" : str.format_time(value, "yyyy-MM-dd", "UTC")

f_pp(float value) =>
    na(value) ? "n/a" : (value > 0 ? "+" : "") + str.tostring(value, "#.##") + " pp"

f_price_number(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#,###.##")

f_price(float value, string currency) =>
    na(value) ? "n/a" : f_price_number(value) + " " + (currency == "" ? "source units" : currency)

// Boundaries are inclusive; an exact median tie is separate from above/below.
f_status(float value, array<float> peers) =>
    string result = "n/a: no same-day prior peers"
    if array.size(peers) > 0 and not na(value)
        float q10 = f_quantile(peers, 0.1)
        float q25 = f_quantile(peers, 0.25)
        float q50 = f_quantile(peers, 0.5)
        float q75 = f_quantile(peers, 0.75)
        float q90 = f_quantile(peers, 0.9)
        string relation = value < q50 ? "Below median" : value > q50 ? "Above median" : "At median"
        string band = value >= q25 and value <= q75 ? "within middle 50%" : value >= q10 and value <= q90 ? "within outer 80%" : value < q10 ? "below P10" : "above P90"
        result := relation + " · " + band
    result

f_endpoint(array<label> labels, array<float> values, int started, string title, color ink, bool beforePoint = false, float verticalOffset = 0.0) =>
    int lastVisible = na
    for d = 0 to array.size(values) - 1
        if not na(array.get(values, d))
            lastVisible := d
    if not na(lastVisible)
        float value = array.get(values, lastVisible)
        array.push(labels, label.new(started + (lastVisible + (beforePoint ? -2 : 2)) * DAY, value + verticalOffset, title + " · day " + str.tostring(lastVisible) + "\n" + f_pct(value), xloc = xloc.bar_time, style = beforePoint ? label.style_label_right : label.style_label_left, color = color.new(color.black, 25), textcolor = ink, size = size.small))
    lastVisible

f_marker(array<line> lines, array<label> labels, int started, int day, float lower, float upper, bool current) =>
    color ink = current ? color.orange : color.new(color.gray, 65)
    array.push(lines, line.new(started + day * DAY, lower, started + day * DAY, upper, xloc = xloc.bar_time, color = ink, style = line.style_dashed))
    array.push(labels, label.new(started + day * DAY, current ? upper : lower, "Day " + str.tostring(day) + (current ? " · closed" : ""), xloc = xloc.bar_time, style = current ? label.style_label_down : label.style_label_up, color = color.new(color.black, 100), textcolor = current ? color.orange : color.silver, size = size.tiny))

f_row(table t, int row, string title, string value) =>
    table.cell(t, 0, row, title, text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, row, value, text_color = color.white, text_size = size.small, text_halign = text.align_left)

// Separate contiguous segments prevent lines/fills from implying missing observations.
f_emit(array<polyline> drawings, array<chart.point> points, bool closed, color stroke, color fill, int width = 2, int budget = 96) =>
    bool omitted = false
    if array.size(points) >= (closed ? 4 : 2)
        if array.size(drawings) < budget
            array.push(drawings, polyline.new(points, curved = false, closed = closed, xloc = xloc.bar_time, line_color = stroke, fill_color = fill, line_width = width))
        else
            omitted := true
    omitted

f_line(array<polyline> drawings, array<float> values, int started, color stroke, int width = 2, int budget = 96) =>
    array<chart.point> points = array.new<chart.point>()
    bool omitted = false
    for d = 0 to array.size(values) - 1
        float value = array.get(values, d)
        if not na(value)
            array.push(points, chart.point.from_time(started + d * DAY, value))
        else
            omitted := f_emit(drawings, points, false, stroke, na, width, budget) or omitted
            array.clear(points)
    omitted := f_emit(drawings, points, false, stroke, na, width, budget) or omitted
    omitted

f_segment_count(array<float> values) =>
    int count = 0
    int run = 0
    for d = 0 to array.size(values) - 1
        if not na(array.get(values, d))
            run += 1
        else
            count += run >= 2 ? 1 : 0
            run := 0
    count + (run >= 2 ? 1 : 0)

f_band(array<polyline> drawings, array<float> lower, array<float> upper, int started, color fill) =>
    array<chart.point> bottom = array.new<chart.point>()
    array<chart.point> top = array.new<chart.point>()
    bool omitted = false
    for d = 0 to array.size(lower)
        bool valid = false
        if d < array.size(lower)
            valid := not na(array.get(lower, d)) and not na(array.get(upper, d))
        if valid
            array.push(bottom, chart.point.from_time(started + d * DAY, array.get(lower, d)))
            array.push(top, chart.point.from_time(started + d * DAY, array.get(upper, d)))
        else if array.size(bottom) > 0
            for j = array.size(top) - 1 to 0
                array.push(bottom, array.get(top, j))
            omitted := f_emit(drawings, bottom, true, color.new(fill, 100), fill) or omitted
            array.clear(bottom)
            array.clear(top)
    omitted

// Evaluate the event ledger in the selected SOURCE context, independently of host bars.
// Each source bar consumes the previous source bar only: confirmed by construction.
// lookahead_on is safe here because every price, date, SMA and cross is offset [1].
f_source_engine() =>
    int srcTime = time[1]
    int srcEnd = time_close[1]
    float srcClose = close[1]
    float srcLow = low[1]
    float fastRaw = ta.sma(close, fastLength)
    float slowRaw = ta.sma(close, slowLength)
    float srcFast = fastRaw[1]
    float srcSlow = slowRaw[1]
    bool srcCross = ta.crossover(fastRaw, slowRaw)[1]
    var array<Event> events = array.new<Event>()
    var array<float> median = array.new<float>(horizon + 1, na)
    var array<float> p10 = array.new<float>(horizon + 1, na)
    var array<float> p25 = array.new<float>(horizon + 1, na)
    var array<float> p75 = array.new<float>(horizon + 1, na)
    var array<float> p90 = array.new<float>(horizon + 1, na)
    var array<int> counts = array.new<int>(horizon + 1, 0)
    var int lastTime = na
    var int firstTime = na
    var int firstUsable = na
    var int observed = 0
    var int missingDays = 0
    var int droppedEvents = 0
    var float latestReturn = na
    var int latestDay = na
    bool accepted = not na(srcTime) and not na(srcClose) and (na(lastTime) or srcTime > lastTime)
    if accepted
        // Selected source must itself use UTC-aligned 24-hour daily bars.
        if srcTime % DAY != 0 or srcEnd - srcTime != DAY
            runtime.error("Use a UTC-aligned 24/7 crypto 1D chart and source. Session-based daily feeds are unsupported.")
        if not na(lastTime)
            missingDays += math.max(0, int((srcTime - lastTime) / DAY) - 1)
        lastTime := srcTime
        firstTime := na(firstTime) ? srcTime : firstTime
        observed += 1
        if not na(srcFast) and not na(srcSlow) and na(firstUsable)
            firstUsable := srcTime
        if array.size(events) > 0
            for i = 0 to array.size(events) - 1
                Event e = array.get(events, i)
                int age = int((srcTime - e.started) / DAY)
                if age > 0
                    e.closeCount += 1
                    e.closingPeak := math.max(e.closingPeak, srcClose)
                    e.maxDrawdown := math.min(e.maxDrawdown, 100 * (srcClose / e.closingPeak - 1))
                if age > 0 and age <= storageHorizon
                    array.set(e.path, age, 100 * (srcClose / e.anchor - 1))
                    // A missing source day makes this and all subsequent full-window peers unavailable.
                    array.set(e.drawdowns, age, e.closeCount == age + 1 ? e.maxDrawdown : na)
                if age >= 1 and age <= 30 and not na(srcLow)
                    e.lowCount += 1
                    if na(e.trough) or srcLow < e.trough
                        e.trough := srcLow
                        e.troughDay := age
        if srcCross
            // Preserve overlapping events. A visible 100-event cap bounds nested-array memory.
            if array.size(events) >= 100
                array.shift(events)
                droppedEvents += 1
            array<float> path = array.new<float>(storageHorizon + 1, na)
            array<float> drawdowns = array.new<float>(storageHorizon + 1, na)
            array.set(path, 0, 0.0)
            array.set(drawdowns, 0, 0.0)
            array.push(events, Event.new(srcTime, srcClose, path, na, na, 0, srcClose, 0.0, 1, drawdowns))
            if srcTime >= cutoff
                for d = 0 to horizon
                    array<float> values = f_values(events, d, srcTime, cutoff)
                    array.set(counts, d, array.size(values))
                    array.set(median, d, f_quantile(values, 0.5))
                    array.set(p10, d, f_quantile(values, 0.1))
                    array.set(p25, d, f_quantile(values, 0.25))
                    array.set(p75, d, f_quantile(values, 0.75))
                    array.set(p90, d, f_quantile(values, 0.9))
        if array.size(events) > 0
            Event latest = array.get(events, array.size(events) - 1)
            latestDay := int((srcTime - latest.started) / DAY)
            latestReturn := 100 * (srcClose / latest.anchor - 1)
    

    Snapshot result = na
    // At most the last two requested bars export bounded arrays. Copying collections
    // on every historical source bar would exhaust Pine's request memory budget.
    if bar_index >= last_bar_index - 1 and not na(lastTime)
        result := Snapshot.new()
        result.firstTime := firstTime
        result.lastTime := lastTime
        result.firstUsable := firstUsable
        result.observed := observed
        result.missingDays := missingDays
        result.droppedEvents := droppedEvents
        result.eventCount := 0
        if array.size(events) > 0
            for i = 0 to array.size(events) - 1
                if array.get(events, i).started >= cutoff
                    result.eventCount += 1
        result.median := array.copy(median)
        result.p10 := array.copy(p10)
        result.p25 := array.copy(p25)
        result.p75 := array.copy(p75)
        result.p90 := array.copy(p90)
        result.counts := array.copy(counts)
        result.path := array.new<float>(storageHorizon + 1, na)
        result.rankValues := array.new<float>()
        result.liveRankValues := array.new<float>()
        result.horizonMedians := array.new<float>(4, na)
        result.horizonNs := array.new<int>(4, 0)
        result.horizonPositives := array.new<int>(4, 0)
        result.cohortClosedMedians := array.new<float>(3, na)
        result.cohortClosedNs := array.new<int>(3, 0)
        result.cohortLiveMedians := array.new<float>(3, na)
        result.cohortLiveNs := array.new<int>(3, 0)
        result.historicalFlat := array.new<float>()
        result.historicalCount := 0
        result.historicalEligible := 0
        if result.eventCount > 0
            Event latest = array.get(events, array.size(events) - 1)
            result.started := latest.started
            result.anchor := latest.anchor
            result.age := latestDay
            result.currentReturn := latestReturn
            result.trough := latest.trough
            result.troughDay := latest.troughDay
            result.lowCount := latest.lowCount
            result.closingPeak := latest.closingPeak
            result.maxDrawdown := latest.maxDrawdown
            result.completeClosedCloses := latest.closeCount == latestDay + 1
            result.path := array.copy(latest.path)
            result.rankValues := latestDay <= storageHorizon ? f_values(events, latestDay, latest.started, cutoff) : array.new<float>()
            // Current source TIME selects frozen prior peers; current PRICE never enters this ledger.
            result.livePeerDay := int((time - latest.started) / DAY)
            result.liveRankValues := result.livePeerDay >= 0 and result.livePeerDay <= storageHorizon ? f_values(events, result.livePeerDay, latest.started, cutoff) : array.new<float>()
            array<float> closedDrawdowns = f_drawdown_values(events, latestDay, latest.started, cutoff)
            array<float> liveDrawdowns = f_drawdown_values(events, result.livePeerDay, latest.started, cutoff)
            result.closedDrawdownMedian := f_quantile(closedDrawdowns, 0.5)
            result.closedDrawdownN := array.size(closedDrawdowns)
            result.liveDrawdownMedian := f_quantile(liveDrawdowns, 0.5)
            result.liveDrawdownN := array.size(liveDrawdowns)
            result.previousSourceTime := time[2]
            if not na(time[2]) and time[2] >= latest.started
                int previousDay = int((time[2] - latest.started) / DAY)
                result.previousReturn := 100 * (close[2] / latest.anchor - 1)
                array<float> previousPeers = previousDay <= storageHorizon ? f_values(events, previousDay, latest.started, cutoff) : array.new<float>()
                result.previousMedian := f_quantile(previousPeers, 0.5)
                result.previousP10 := f_quantile(previousPeers, 0.1)
                result.previousP90 := f_quantile(previousPeers, 0.9)
                result.previousN := array.size(previousPeers)
            if showHistoricalPaths and array.size(events) > 1
                for i = array.size(events) - 2 to 0
                    Event past = array.get(events, i)
                    if past.started >= cutoff
                        result.historicalEligible += 1
                        if result.historicalCount < maxHistoricalPaths
                            for d = 0 to horizon
                                array.push(result.historicalFlat, past.started + d * DAY <= latest.started ? array.get(past.path, d) : na)
                            result.historicalCount += 1
            array<int> horizons = array.from(30, 60, 90, 180)
            for i = 0 to 3
                array<float> values = f_values(events, array.get(horizons, i), latest.started, cutoff)
                int positive = 0
                if array.size(values) > 0
                    for j = 0 to array.size(values) - 1
                        positive += array.get(values, j) > 0 ? 1 : 0
                array.set(result.horizonMedians, i, f_quantile(values, 0.5))
                array.set(result.horizonNs, i, array.size(values))
                array.set(result.horizonPositives, i, positive)
            if compareCohorts
                array<int> cuts = array.from(timestamp("UTC", 2013, 1, 1, 0, 0), timestamp("UTC", 2015, 1, 1, 0, 0), 0)
                for i = 0 to 2
                    array<float> closedPeers = latestDay >= 0 and latestDay <= storageHorizon ? f_values(events, latestDay, latest.started, array.get(cuts, i)) : array.new<float>()
                    array<float> livePeers = result.livePeerDay >= 0 and result.livePeerDay <= storageHorizon ? f_values(events, result.livePeerDay, latest.started, array.get(cuts, i)) : array.new<float>()
                    array.set(result.cohortClosedMedians, i, f_quantile(closedPeers, 0.5))
                    array.set(result.cohortClosedNs, i, array.size(closedPeers))
                    array.set(result.cohortLiveMedians, i, f_quantile(livePeers, 0.5))
                    array.set(result.cohortLiveNs, i, array.size(livePeers))
    result

Snapshot snapshot = request.security(source, "1D", f_source_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, calc_bars_count = 20000)
// Separate, explicitly provisional selected-source quote; never ingested by the event engine.
[quoteTime, quoteEnd, quoteClose, sourceCurrency] = request.security(source, "1D", [time, time_close, close, syminfo.currency], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
var array<polyline> drawings = array.new<polyline>()
var array<label> labels = array.new<label>()
var array<line> markers = array.new<line>()
int baseRows = liveMode ? 9 : 7
int compactRows = baseRows + 2 + (showPrices ? 1 : 0)
var table dashboard = table.new(position.top_right, 2, showDetails ? compactRows + (liveMode ? 15 : 14) : compactRows, bgcolor = color.new(color.black, 15))
var table cohortTable = table.new(position.bottom_right, 2, 6, bgcolor = color.new(color.black, 15))
var table milestoneTable = table.new(position.middle_left, 4, 5, bgcolor = color.new(color.black, 15))
var table historicalTable = table.new(position.top_center, 1, 2, bgcolor = color.new(color.black, 15))
// Delivery cursors alone use varip to survive realtime rollback. No statistical state does.
varip bool alertsArmed = false
varip int seenSourceDate = na
varip int seenCrossDate = na
hline(0, "Cross-day close = 0%", color = color.new(color.gray, 60))
// Hidden confirmed series supplies pane autoscaling alongside the drawing objects.
plot(barstate.islast and not na(snapshot) ? snapshot.currentReturn : na, "Confirmed cycle return (%)", color = color.new(color.orange, 100), display = display.pane)
bool render = barstate.islast and not na(snapshot)
if render
    int latestDay = snapshot.age
    float latestReturn = snapshot.currentReturn
    int firstTime = snapshot.firstTime
    int lastTime = snapshot.lastTime
    int firstUsable = snapshot.firstUsable
    int observed = snapshot.observed
    int missingDays = snapshot.missingDays
    int droppedEvents = snapshot.droppedEvents
    array<float> median = snapshot.median
    array<float> p10 = snapshot.p10
    array<float> p25 = snapshot.p25
    array<float> p75 = snapshot.p75
    array<float> p90 = snapshot.p90
    array<int> counts = snapshot.counts
    if array.size(drawings) > 0
        for i = 0 to array.size(drawings) - 1
            polyline.delete(array.get(drawings, i))
        array.clear(drawings)
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
        array.clear(labels)
    if array.size(markers) > 0
        for i = 0 to array.size(markers) - 1
            line.delete(array.get(markers, i))
        array.clear(markers)
    f_row(dashboard, 0, "Study source / cohort", source + (useChart ? " [chart] / " : " [manual] / ") + cohort)
    if snapshot.eventCount > 0
        Snapshot latest = snapshot
        bool liveAvailable = liveMode and not na(quoteClose) and quoteTime == time and quoteTime % DAY == 0 and quoteEnd - quoteTime == DAY and quoteTime <= timenow and quoteEnd > timenow
        int liveDay = liveAvailable ? int((quoteTime - latest.started) / DAY) : na
        float liveReturn = liveAvailable ? 100 * (quoteClose / latest.anchor - 1) : na
        bool liveInView = liveAvailable and liveDay >= 0 and liveDay <= horizon
        bool omitted = false
        int historicalDrawn = 0
        int historicalSkipped = 0
        if showHistoricalPaths and snapshot.historicalCount > 0
            for i = 0 to snapshot.historicalCount - 1
                array<float> pastPath = array.new<float>()
                for d = 0 to horizon
                    array.push(pastPath, array.get(snapshot.historicalFlat, i * (horizon + 1) + d))
                int segments = f_segment_count(pastPath)
                if segments > 0 and array.size(drawings) + segments <= 64
                    f_line(drawings, pastPath, latest.started, color.new(color.gray, 75), 1, 64)
                    historicalDrawn += 1
                else
                    historicalSkipped += 1
        if showHistoricalPaths
            table.cell(historicalTable, 0, 0, "Historical paths: " + str.tostring(historicalDrawn) + " drawn / " + str.tostring(snapshot.historicalEligible) + " eligible", text_color = color.silver, text_size = size.small)
            table.cell(historicalTable, 0, 1, "Newest " + str.tostring(snapshot.historicalCount) + "; " + str.tostring(historicalSkipped) + " skipped; frozen at cross", text_color = color.silver, text_size = size.tiny)
        if showOuter
            omitted := f_band(drawings, p10, p90, latest.started, color.new(color.blue, 90)) or omitted
        if showInner
            omitted := f_band(drawings, p25, p75, latest.started, color.new(color.aqua, 82)) or omitted
        omitted := f_line(drawings, median, latest.started, color.aqua) or omitted
        array<float> currentPath = array.new<float>(horizon + 1, na)
        float lower = 0.0
        float upper = 0.0
        for d = 0 to horizon
            float value = array.get(latest.path, d)
            array.set(currentPath, d, value)
            if not na(value)
                lower := math.min(lower, value)
                upper := math.max(upper, value)
            if not na(array.get(p10, d))
                lower := math.min(lower, array.get(p10, d))
            if not na(array.get(p90, d))
                upper := math.max(upper, array.get(p90, d))
        if liveInView
            lower := math.min(lower, liveReturn)
            upper := math.max(upper, liveReturn)
        float padding = math.max(1.0, (upper - lower) * 0.06)
        lower -= padding
        upper += padding
        array<int> markerDays = array.from(0, 30, 60, 90, 180)
        bool currentOnMilestone = false
        for i = 0 to array.size(markerDays) - 1
            int d = array.get(markerDays, i)
            if d <= horizon
                bool current = d == latestDay
                f_marker(markers, labels, latest.started, d, lower, upper, current)
                currentOnMilestone := currentOnMilestone or current
        if latestDay <= horizon and not currentOnMilestone
            f_marker(markers, labels, latest.started, latestDay, lower, upper, true)
        omitted := f_line(drawings, currentPath, latest.started, color.orange) or omitted
        f_endpoint(labels, median, latest.started, "Historical median", color.aqua)
        int closedEndpoint = f_endpoint(labels, currentPath, latest.started, "Closed cycle", color.orange, liveInView, liveInView ? padding * 1.5 : 0.0)
        if liveInView
            if not na(closedEndpoint)
                float closedValue = array.get(currentPath, closedEndpoint)
                array.push(markers, line.new(latest.started + closedEndpoint * DAY, closedValue, latest.started + (closedEndpoint - 2) * DAY, closedValue + padding * 1.5, xloc = xloc.bar_time, color = color.new(color.orange, 50), style = line.style_dotted))
            // Only an adjacent closed source day can connect to the live quote. No gap bridge.
            if quoteTime == snapshot.lastTime + DAY and latestDay >= 0 and latestDay <= horizon
                array.push(markers, line.new(snapshot.lastTime, latestReturn, quoteTime, liveReturn, xloc = xloc.bar_time, color = color.orange, style = line.style_dashed, width = 2))
            array.push(labels, label.new(quoteTime, liveReturn, "●", xloc = xloc.bar_time, style = label.style_label_center, color = color.new(color.orange, 100), textcolor = color.orange, size = 24))
            float liveLabelY = liveReturn - padding * 1.5
            array.push(markers, line.new(quoteTime, liveReturn, quoteTime + 2 * DAY, liveLabelY, xloc = xloc.bar_time, color = color.new(color.orange, 50), style = line.style_dotted))
            array.push(labels, label.new(quoteTime + 2 * DAY, liveLabelY, "Live · day " + str.tostring(liveDay) + "\n" + f_pct(liveReturn) + " · provisional", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 25), textcolor = color.orange, size = size.small))
        bool livePeersMatch = liveAvailable and snapshot.livePeerDay == liveDay
        array<float> rankValues = liveAvailable ? (livePeersMatch ? snapshot.liveRankValues : array.new<float>()) : snapshot.rankValues
        float displayReturn = liveAvailable ? liveReturn : latestReturn
        int displayDay = liveAvailable ? liveDay : latestDay
        if showMilestoneSummary
            array<string> headers = array.from("Day", "Median", "Positive", "n")
            for column = 0 to 3
                table.cell(milestoneTable, column, 0, array.get(headers, column), text_color = color.silver, text_size = size.small)
            array<int> summaryDays = array.from(30, 60, 90, 180)
            for i = 0 to 3
                int n = array.get(snapshot.horizonNs, i)
                int positives = array.get(snapshot.horizonPositives, i)
                table.cell(milestoneTable, 0, i + 1, str.tostring(array.get(summaryDays, i)), text_color = color.white, text_size = size.small)
                table.cell(milestoneTable, 1, i + 1, f_pct(array.get(snapshot.horizonMedians, i)), text_color = color.white, text_size = size.small)
                table.cell(milestoneTable, 2, i + 1, n > 0 ? str.tostring(100.0 * positives / n, "#.##") + "% (" + str.tostring(positives) + "/" + str.tostring(n) + ")" : "n/a", text_color = color.white, text_size = size.small)
                table.cell(milestoneTable, 3, i + 1, str.tostring(n), text_color = color.white, text_size = size.small)
        int rankN = array.size(rankValues)
        int below = 0
        int ties = 0
        if rankN > 0
            for i = 0 to rankN - 1
                float value = array.get(rankValues, i)
                below += value < displayReturn ? 1 : 0
                ties += value == displayReturn ? 1 : 0
        float dayMedian = f_quantile(rankValues, 0.5)
        string rankText = rankN > 0 ? str.tostring(below) + " of " + str.tostring(rankN) + " below" + (ties > 0 ? "; " + str.tostring(ties) + " tied" : "") : "n/a"
        f_row(dashboard, 1, "Cross / closed day", f_date(latest.started) + " / " + str.tostring(latestDay))
        f_row(dashboard, 2, "Closed cycle", f_pct(latestReturn) + (showPrices ? " / " + f_price(latest.anchor * (1 + latestReturn / 100), sourceCurrency) : ""))
        if liveMode
            f_row(dashboard, 3, "Live · provisional", liveAvailable ? "Day " + str.tostring(liveDay) + " / " + f_pct(liveReturn) + (showPrices ? " / " + f_price(quoteClose, sourceCurrency) : "") : "Unavailable: no current forming source bar")
            table.cell_set_text_color(dashboard, 1, 3, color.orange)
        int medianRow = liveMode ? 4 : 3
        f_row(dashboard, medianRow, (liveAvailable ? "Live-day" : "Closed-day") + " median / difference", f_pct(dayMedian) + " / " + f_pp(displayReturn - dayMedian))
        f_row(dashboard, medianRow + 1, "Historical rank", rankText)
        f_row(dashboard, medianRow + 2, "Prior peers", str.tostring(rankN) + "; descriptive, not probability")
        array<int> horizons = array.from(30, 60, 90, 180)
        int nextDay = na
        for i = 0 to 3
            int d = array.get(horizons, i)
            if d > displayDay and na(nextDay)
                nextDay := d
        int nextIndex = not na(nextDay) ? array.indexof(horizons, nextDay) : -1
        float nextMedian = nextIndex >= 0 ? array.get(snapshot.horizonMedians, nextIndex) : na
        int nextN = nextIndex >= 0 ? array.get(snapshot.horizonNs, nextIndex) : 0
        string warning = omitted ? "; drawing cap" : droppedEvents > 0 ? "; dropped " + str.tostring(droppedEvents) : missingDays > 0 ? "; gaps: details" : ""
        f_row(dashboard, liveMode ? 7 : 6, "Next milestone", (not na(nextDay) ? "Day " + str.tostring(nextDay) + " median " + f_pct(nextMedian) + " (n=" + str.tostring(nextN) + ")" : "Beyond day180") + warning)
        if liveMode
            f_row(dashboard, 8, "Confirmation", liveAvailable ? (liveInView ? "Live varies; closed path/bands frozen" : "Live outside view; closed path/bands frozen") : "Closed reference shown; live unavailable")
        f_row(dashboard, baseRows, liveAvailable ? "Live context" : "Closed context", f_status(displayReturn, rankValues))
        if showPrices
            float medianPrice = latest.anchor * (1 + dayMedian / 100)
            float p25Price = latest.anchor * (1 + f_quantile(rankValues, 0.25) / 100)
            float p75Price = latest.anchor * (1 + f_quantile(rankValues, 0.75) / 100)
            f_row(dashboard, baseRows + 1, "Historical references (" + (sourceCurrency == "" ? "source units" : sourceCurrency) + ")", "Median " + f_price_number(medianPrice) + " · P25–75 " + f_price_number(p25Price) + "–" + f_price_number(p75Price))
        float currentDrawdown = liveAvailable ? math.min(snapshot.maxDrawdown, 100 * (quoteClose / math.max(snapshot.closingPeak, quoteClose) - 1)) : snapshot.maxDrawdown
        bool currentDrawdownComplete = snapshot.completeClosedCloses and (not liveAvailable or quoteTime == snapshot.lastTime + DAY)
        float peerDrawdownMedian = liveAvailable ? (livePeersMatch ? snapshot.liveDrawdownMedian : na) : snapshot.closedDrawdownMedian
        int peerDrawdownN = liveAvailable ? (livePeersMatch ? snapshot.liveDrawdownN : 0) : snapshot.closedDrawdownN
        f_row(dashboard, baseRows + 1 + (showPrices ? 1 : 0), "Max drawdown · " + (liveAvailable ? "live" : "closed"), "Current " + f_pct(currentDrawdown) + " / median " + f_pct(peerDrawdownMedian) + " (n=" + str.tostring(peerDrawdownN) + ")" + (currentDrawdownComplete ? "" : " · observed only"))
        table.cell_set_tooltip(dashboard, 0, baseRows + 1 + (showPrices ? 1 : 0), "Worst daily-CLOSE peak-to-trough fall since the cross, including day0. Median is of prior individual cycles' worst falls through this same day, not drawdown of the median curve. Historical peers require every daily close and outcomes known at this cycle's cross. Live is provisional; observed-only current data can miss a worse fall on missing dates.")
        if compareCohorts
            f_row(cohortTable, 0, "Same-source cohorts", source + " · " + (liveAvailable ? "live" : "closed") + " day " + str.tostring(displayDay))
            array<string> cohortNames = array.from("Post-2013", "Post-2015", "Full source history")
            array<float> cohortMedians = liveAvailable ? snapshot.cohortLiveMedians : snapshot.cohortClosedMedians
            array<int> cohortNs = liveAvailable ? snapshot.cohortLiveNs : snapshot.cohortClosedNs
            for i = 0 to 2
                bool comparisonAvailable = not liveAvailable or livePeersMatch
                f_row(cohortTable, i + 1, array.get(cohortNames, i), comparisonAvailable ? f_pct(array.get(cohortMedians, i)) + " (n=" + str.tostring(array.get(cohortNs, i)) + ")" : "n/a: snapshot day mismatch (n=0)")
            f_row(cohortTable, 4, "Shared anchor / freeze", f_price(latest.anchor, sourceCurrency) + " / " + f_date(latest.started))
            f_row(cohortTable, 5, "Interpretation", "Descriptive; current excluded" + (droppedEvents > 0 ? "; source cap dropped " + str.tostring(droppedEvents) : ""))
        if showDetails
            f_row(dashboard, compactRows, "Closed source coverage", f_date(firstTime) + " → " + f_date(lastTime))
            f_row(dashboard, compactRows + 1, "Bars / gaps / SMA ready", str.tostring(observed) + " / " + str.tostring(missingDays) + " days / " + f_date(firstUsable))
            f_row(dashboard, compactRows + 2, "Selected events / raw dropped", str.tostring(snapshot.eventCount) + " / " + str.tostring(droppedEvents))
            f_row(dashboard, compactRows + 3, "Anchor / reference frozen", str.tostring(latest.anchor, "#.##") + " / cross close; latest excluded")
            for i = 0 to 3
                int d = array.get(horizons, i)
                int n = array.get(snapshot.horizonNs, i)
                int positives = array.get(snapshot.horizonPositives, i)
                string rate = n > 0 ? " (" + str.tostring(100.0 * positives / n, "#.##") + "%)" : ""
                f_row(dashboard, compactRows + 4 + i, "Day " + str.tostring(d) + " median / positive", f_pct(array.get(snapshot.horizonMedians, i)) + " / " + str.tostring(positives) + "/" + str.tostring(n) + rate)
            bool completeLow = latestDay >= 30 and latest.lowCount == 30
            string lowStatus = completeLow ? "Final" : latestDay < 30 ? "Provisional" : "Incomplete"
            f_row(dashboard, compactRows + 8, "Days1–30 intraday low", lowStatus + ": " + f_pct(100 * (latest.trough / latest.anchor - 1)) + " at day " + str.tostring(latest.troughDay))
            f_row(dashboard, compactRows + 9, "Low-window observations", str.tostring(latest.lowCount) + "/30; earliest exact tie")
            int minN = 100000
            int maxN = 0
            for d = 0 to horizon
                minN := math.min(minN, array.get(counts, d))
                maxN := math.max(maxN, array.get(counts, d))
            f_row(dashboard, compactRows + 10, "Path n / percentile", str.tostring(minN) + "–" + str.tostring(maxN) + "; midrank " + (rankN > 0 ? str.tostring(100.0 * (below + 0.5 * ties) / rankN, "#.##") : "n/a"))
            f_row(dashboard, compactRows + 11, "Bands / warnings", "P25–75 / P10–90; " + (omitted ? "drawing cap reached" : "not forecast probabilities"))
            f_row(dashboard, compactRows + 12, "Interpretation", "Small, dependent samples; half-weight rank ties")
            f_row(dashboard, compactRows + 13, "Host / source history", syminfo.tickerid + " / up to20,000 source bars")
            if liveMode
                f_row(dashboard, compactRows + 14, "Live source quote / date", liveAvailable ? str.tostring(quoteClose, "#.##") + " / " + f_date(quoteTime) + " (host refresh)" : "Unavailable")
        // Closed-source results appear when the next source day opens, not at host close.
        if barstate.isrealtime
            bool freshSourceDay = quoteTime == time and quoteTime <= timenow and quoteEnd > timenow and quoteEnd - quoteTime == DAY and snapshot.lastTime + DAY == quoteTime
            if not alertsArmed
                seenSourceDate := snapshot.lastTime
                seenCrossDate := latest.started
                alertsArmed := true
            else if snapshot.lastTime > seenSourceDate
                bool consecutive = snapshot.lastTime - snapshot.previousSourceTime == DAY and snapshot.previousSourceTime == seenSourceDate
                bool sameCycle = seenCrossDate == latest.started and snapshot.previousSourceTime >= latest.started
                bool validPeers = snapshot.previousN > 0 and array.size(snapshot.rankValues) > 0
                string triggers = ""
                if enableAlerts and freshSourceDay and consecutive and sameCycle
                    float closedMedian = f_quantile(snapshot.rankValues, 0.5)
                    float closedP10 = f_quantile(snapshot.rankValues, 0.1)
                    float closedP90 = f_quantile(snapshot.rankValues, 0.9)
                    if alertMilestones and (latestDay == 30 or latestDay == 60 or latestDay == 90 or latestDay == 180)
                        triggers += "Reached day " + str.tostring(latestDay) + "; "
                    if alertMedianCross and validPeers and snapshot.previousReturn <= snapshot.previousMedian and latestReturn > closedMedian
                        triggers += "Crossed above historical median; "
                    if alertMedianCross and validPeers and snapshot.previousReturn >= snapshot.previousMedian and latestReturn < closedMedian
                        triggers += "Crossed below historical median; "
                    bool wasInside = snapshot.previousReturn >= snapshot.previousP10 and snapshot.previousReturn <= snapshot.previousP90
                    if alertBandExit and validPeers and wasInside and latestReturn < closedP10
                        triggers += "Exited below historical P10; "
                    if alertBandExit and validPeers and wasInside and latestReturn > closedP90
                        triggers += "Exited above historical P90; "
                    if triggers != ""
                        alert(source + " | cross " + f_date(latest.started) + " | source close " + f_date(snapshot.lastTime) + " | day " + str.tostring(latestDay) + " | return " + f_pct(latestReturn) + " | median " + f_pct(closedMedian) + " (n=" + str.tostring(array.size(snapshot.rankValues)) + ") | " + triggers, alert.freq_once_per_bar)
                seenSourceDate := snapshot.lastTime
                seenCrossDate := latest.started
    else
        if compareCohorts
            for row = 0 to 5
                f_row(cohortTable, row, row == 0 ? "Same-source cohorts" : "", row == 0 ? "No selected eligible cycle" : "")
        for row = 1 to (showDetails ? compactRows + (liveMode ? 14 : 13) : compactRows - 1)
            f_row(dashboard, row, row == 1 ? "Latest cross" : "", row == 1 ? "No eligible cross in requested source history" : "")
````
