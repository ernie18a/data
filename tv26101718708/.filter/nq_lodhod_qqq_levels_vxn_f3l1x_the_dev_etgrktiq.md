# NQ - LOD\HOD + QQQ levels + VXN   [ F3L1X the DEV ] 

- url: https://www.tradingview.com/script/ETgRkTIq-NQ-LOD-HOD-QQQ-levels-VXN-F3L1X-the-DEV/
- type: indicator
- pine_id: PUB;8188f97da7a7475ab69792538340001e
- version: 1.0

## Description

[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] [symbol="NASDAQ:NDX"]NASDAQ:NDX[/symbol] [symbol="CBOE:VXN"]CBOE:VXN[/symbol] [symbol="CME_MINI:NQ1!"]CME_MINI:NQ1![/symbol] 

A session-planning indicator for QQQ, NDX, and NQ that combines frozen daily high/low forecast zones, mapped QQQ price levels, and a separate live volatility reference.
The indicator separates the outlook available before the US cash open from information that develops during the session. The main forecast freezes at 09:25 New York time, while the live reference updates using confirmed market data.
What the indicator displays
1. Frozen HOD / LOD forecast zones
Before the cash session opens, the model estimates zones for the upcoming regular-session High of Day (HOD) and Low of Day (LOD).
Each zone contains three levels:
- Lower boundary
- Median estimate
- Upper boundary
The forecast uses historical session behavior, overnight range information, and a volatility model. It freezes at 09:25 New York time and remains fixed for that session.
The boundaries represent estimated 20th and 80th quantiles, with a median estimate between them. These are forecast ranges—not guaranteed support, resistance, or reversal levels.
The underlying forecast is calculated from NQ. On QQQ and NDX charts, the indicator converts that forecast into the selected instrument’s price units.
2. QQQ price-level mapping
The QQQ grid displays nearby round-number QQQ levels on supported charts.
- On QQQ, these are native QQQ price levels.
- On NQ, the levels are converted using synchronized QQQ and NQ prices.
- On NDX, live mapping requires synchronized QQQ and NDX prices.
You can choose between a frozen mapping and a live mapping. Frozen mapping provides a stable reference; live mapping reflects changes in the relationship between instruments.
These are price-based reference levels. They are not measured option positioning, gamma exposure, or confirmed option walls.
3. Separate live IV reference
The live volatility reference is independent of the frozen HOD/LOD forecast. It estimates a price-move range for the time remaining in the regular cash session.
Two inputs are available:
- VXN proxy: Uses Nasdaq-100 implied volatility as a broad volatility reference.
- Manual QQQ 0DTE IV: Lets you enter a current QQQ same-day implied-volatility reading and its timestamp.
VXN measures approximately 30-day implied volatility; it is not a direct 0DTE IV feed. The manual input requires an external source and must be updated by the user.
The displayed range is a volatility-based approximation. It is not a calibrated probability interval or a prediction of where price must finish.
4. Nasdaq NOII timing box
The compact NOII box identifies the scheduled Nasdaq opening and closing imbalance windows:
Window	New York time
Opening — early	09:25–09:28
Opening — full	09:28–09:30
Closing — early	15:50–15:55
Closing — full	15:55–16:00


This is a timing reference, not a live NOII data feed. It does not display actual imbalance direction, imbalance size, paired shares, or indicative auction prices.
How to use it
1. Open a standard QQQ, NDX, or NQ1! chart on the 1-minute or 5-minute timeframe.
2. Allow sufficient historical data to load.
3. After 09:25 New York time, check that the frozen forecast is available.
4. Use the HOD/LOD zones to frame the session’s potential extremes.
5. Use mapped QQQ levels as additional price references.
6. During regular trading hours, monitor the separate live IV reference and its data timestamp.
7. Check the status panel for missing, stale, or unsynchronized data before interpreting a level.
For example, if price approaches the upper HOD zone near a mapped QQQ level, that identifies an area worth observing. It does not automatically imply a short entry. Price action, execution rules, and risk management remain separate decisions.
Important differences between instruments
QQQ: Native QQQ levels are displayed alongside the converted NQ forecast.
NQ: The forecast uses the back-adjusted continuous NQ contract. Contract rolls and differences between data feeds can affect cross-instrument relationships.
NDX: The cash index is not available at 09:25. Its frozen forecast therefore uses a prior synchronized cash-session relationship and is explicitly a prior-cash-basis projection.
The three displays are linked projections, not three independently trained forecasting models.
Reading the statistics
The optional audit panel reports historical NQ forecast coverage:
- HOD coverage: How often the session high fell inside the predicted HOD zone.
- LOD coverage: How often the session low fell inside the predicted LOD zone.
- Joint coverage: How often both extremes fell inside their respective zones.
These statistics are not a trading win rate. They do not measure profit, transaction costs, slippage, or the performance of a defined entry-and-exit strategy. Results depend on the available history, settings, and data feed.
QQQ and NDX projections should not be interpreted as independently validated performance statistics for those instruments.
Data and research limitations
The indicator is designed to support session analysis, including 0DTE-oriented workflows, but it does not ingest a live options chain, dealer positions, gamma exposure, or actual NOII messages.
Research did not establish a statistically reliable improvement from adding the tested IV feature directly to the core forecast. IV is therefore retained as a separate contextual reference.
Live calculations use confirmed data and may lag the currently forming bar. Delayed subscriptions, closed cash markets, and mismatched timestamps can make some references unavailable. The panel exposes these conditions rather than silently treating stale values as current.
Use this indicator as an analytical tool—not as a standalone trading system or a guarantee of future results.
Credits
The cross-instrument price-mapping concept was informed by QQQ NDX NQ Price by PtGambler. This implementation adds a shared frozen forecast, timestamp checks, separate live IV context, and session-status information.

## Source Code

````pine
//@version=6
indicator("F3L1X v0.6 QQQ Bridge + IV", "F3L1X v0.6", overlay=true, max_bars_back=500, max_lines_count=50, max_labels_count=50, dynamic_requests=true)
// Audit extension of the v0.4 causal engine; no frozen all-sample coefficients.
// Only confirmed [1] 5m bars enter the engine. No orders or options feed.
// INCUMBENT = exact v0.4 ON HAR defaults: fit 500 / pool 60 / age 365.
// Both engines score only their common eligible sessions on the same source data.
// Forward monitoring is a date filter, NOT proof of an untouched historical holdout.
// Selected 500/250/400 parameters were tuned retrospectively on reused CFD proxy data.
// This is NOT an independently validated NQ improvement; assess the paired NQ scores.
string TZ = "America/New_York"
const string EXCLUDED_DATES = "2019-01-01,2019-01-21,2019-02-18,2019-04-19,2019-05-27,2019-07-03,2019-07-04,2019-09-02,2019-11-28,2019-11-29,2019-12-24,2019-12-25,2020-01-01,2020-01-20,2020-02-17,2020-04-10,2020-05-25,2020-07-03,2020-09-07,2020-11-26,2020-11-27,2020-12-24,2020-12-25,2021-01-01,2021-01-18,2021-02-15,2021-04-02,2021-05-31,2021-07-05,2021-09-06,2021-11-25,2021-11-26,2021-12-24,2022-01-17,2022-02-21,2022-04-15,2022-05-30,2022-06-20,2022-07-04,2022-09-05,2022-11-24,2022-11-25,2022-12-26,2023-01-02,2023-01-16,2023-02-20,2023-04-07,2023-05-29,2023-06-19,2023-07-03,2023-07-04,2023-09-04,2023-11-23,2023-11-24,2023-12-25,2024-01-01,2024-01-15,2024-02-19,2024-03-29,2024-05-27,2024-06-19,2024-07-03,2024-07-04,2024-09-02,2024-11-28,2024-11-29,2024-12-24,2024-12-25,2025-01-01,2025-01-09,2025-01-20,2025-02-17,2025-04-18,2025-05-26,2025-06-19,2025-07-03,2025-07-04,2025-09-01,2025-11-27,2025-11-28,2025-12-24,2025-12-25,2026-01-01,2026-01-19,2026-02-16,2026-04-03,2026-05-25,2026-06-19,2026-07-03,2026-09-07,2026-11-26,2026-11-27,2026-12-24,2026-12-25,2027-01-01,2027-01-18,2027-02-15,2027-03-26,2027-05-31,2027-06-18,2027-07-05,2027-09-06,2027-11-25,2027-11-26,2027-12-24,2028-01-17,2028-02-21,2028-04-14,2028-05-29,2028-06-19,2028-07-03,2028-07-04,2028-09-04,2028-11-23,2028-11-24,2028-12-25"
string model = input.string("ON HAR", "Model", options=["Base", "ON HAR", "EWMA"], group="Research")
int fitWindow = input.int(500, "HAR completed sessions", minval=100, maxval=1000, group="Research")
const int fitMin = 100  // Fixed v0.4 design: same for candidate and incumbent.
const int onMin = 150
float decay = input.float(0.8, "EWMA lambda (no clean holdout)", minval=0.01, maxval=0.99, group="Research")
const int scaleDays = 5
int lookback = input.int(250, "Normalized sample window", minval=10, maxval=252, group="Model")
const int minSamples = 10
const float coverage = 60  // Marginal target for each interval, not joint coverage.
const int minTicks = 4
int maxAge = input.int(400, "Maximum sample age (days)", minval=30, maxval=3650, group="Model")
int modelStart = input.time(timestamp("01 Jan 2019 00:00 +0000"), "Model start", group="Data")
int evalStart = input.time(timestamp("01 Jan 2023 00:00 -0500"), "Historical evaluation from", group="Data")
int forwardStart = input.time(timestamp("30 Sep 2026 00:00 -0400"), "Forward monitoring from (not a holdout claim)", group="Data")
string extraDates = input.string("", "Excluded NY dates, YYYY-MM-DD comma separated", group="Data")
int historyBars = input.int(100000, "5m source bars requested (available history may be shorter)", minval=5000, maxval=100000, group="Data")
bool showTable = input.bool(true, "Compact dashboard", group="Display")
bool showAudit = input.bool(false, "Expanded NQ model audit", group="Display")
bool showIncumbent = input.bool(false, "Show incumbent medians", group="Display")
float TICK = 0.25

type Band
    float lo = na
    float mid = na
    float hi = na

f_band(array<float> samples, float anchor, float scale) =>
    array<float> sorted = array.copy(samples)
    array.sort(sorted)
    float tail = (100 - coverage) / 2
    float mid = anchor + scale * array.percentile_linear_interpolation(sorted, 50)
    float lo = math.min(anchor + scale * array.percentile_linear_interpolation(sorted, tail), mid - minTicks * TICK / 2)
    float hi = math.max(anchor + scale * array.percentile_linear_interpolation(sorted, 100 - tail), mid + minTicks * TICK / 2)
    Band.new(math.floor(lo / TICK) * TICK, math.floor(mid / TICK + 0.5) * TICK, math.ceil(hi / TICK) * TICK)

// Partial-pivot elimination of the same 3x3 normal equations as the Python OLS.
f_har(array<float> xs, array<float> zs, array<float> ys, float base, float overnight) =>
    array<float> a = array.new_float(12, 0)
    for r = 0 to array.size(xs) - 1
        array<float> x = array.from(1.0, array.get(xs, r), array.get(zs, r))
        for i = 0 to 2
            array.set(a, i * 4 + 3, array.get(a, i * 4 + 3) + array.get(x, i) * array.get(ys, r))
            for j = 0 to 2
                array.set(a, i * 4 + j, array.get(a, i * 4 + j) + array.get(x, i) * array.get(x, j))
    bool valid = true
    for i = 0 to 2
        int pivot = i
        for r = i to 2
            if math.abs(array.get(a, r * 4 + i)) > math.abs(array.get(a, pivot * 4 + i))
                pivot := r
        if math.abs(array.get(a, pivot * 4 + i)) < 1e-12
            valid := false
            break
        for c = 0 to 3
            float tmp = array.get(a, i * 4 + c)
            array.set(a, i * 4 + c, array.get(a, pivot * 4 + c))
            array.set(a, pivot * 4 + c, tmp)
        for r = 0 to 2
            if r != i
                float factor = array.get(a, r * 4 + i) / array.get(a, i * 4 + i)
                for c = i to 3
                    array.set(a, r * 4 + c, array.get(a, r * 4 + c) - factor * array.get(a, i * 4 + c))
    float result = na
    if valid
        result := math.exp(array.get(a, 3) / array.get(a, 0) + array.get(a, 7) / array.get(a, 5) * math.log(base) + array.get(a, 11) / array.get(a, 10) * math.log(overnight))
    result

type Day
    int key
    int cut
    int opening
    int ending
    bool excluded
    bool done = false
    bool seen = false
    bool published = false
    bool pairTrainingEligible = false
    bool pairReady = false
    bool fallback = true
    bool continuous = true
    int bars = 0
    int lastEnd = na
    int samples = 0
    int onBars = 0
    float anchor = na
    float base = na
    float scale = na
    float onRange = na
    float actualH = na
    float actualL = na
    Band h
    Band l
    Band bh
    Band bl

type Engine
    Day d
    array<float> ranges
    array<int> rangeDates
    array<int> dates
    array<float> hs
    array<float> ls
    array<float> bhs
    array<float> bls
    array<float> xs
    array<float> zs
    array<float> ys
    array<int> ot
    array<float> oh
    array<float> ol
    array<int> pairRangeDates
    array<int> pairDates
    string mode
    int fitWindowN
    int poolWindow
    int ageDays
    int commonAge
    float ewma = na
    int scored = 0
    int incomplete = 0
    int fallbackN = 0
    float hHit = 0
    float lHit = 0
    float both = 0
    float score = 0
    float hAbs = 0
    float lAbs = 0
    float hWidth = 0
    float lWidth = 0
    int firstLoaded = na
    int lastLoaded = na
    int firstScored = na
    int lastScored = na
    int forwardScored = 0
    float forwardHHit = 0
    float forwardLHit = 0
    float forwardBoth = 0
    float forwardScore = 0

f_score(float actual, Band b) =>
    (b.hi - b.lo + 2 / (1 - coverage / 100) * math.max(b.lo - actual, actual - b.hi, 0)) / TICK

method evict(Engine e) =>
    array.shift(e.dates)
    array.shift(e.hs)
    array.shift(e.ls)
    array.shift(e.bhs)
    array.shift(e.bls)

method finish(Engine e) =>
    Day d = e.d
    if not na(d) and not d.done
        d.done := true
        bool complete = d.continuous and d.bars == 78 and d.lastEnd == d.ending and d.actualH > d.actualL
        if not d.excluded and complete
            // Score BEFORE training; the common queue uses the stricter sample age.
            // This keeps both request.security engines on identical scoring dates.
            if d.published and d.pairReady and d.cut >= evalStart
                bool hh = d.actualH >= d.h.lo and d.actualH <= d.h.hi
                bool lh = d.actualL >= d.l.lo and d.actualL <= d.l.hi
                float dayScore = (f_score(d.actualH, d.h) + f_score(d.actualL, d.l)) / 2
                if d.cut >= forwardStart
                    e.forwardScored += 1
                    e.forwardHHit += hh ? 1 : 0
                    e.forwardLHit += lh ? 1 : 0
                    e.forwardBoth += hh and lh ? 1 : 0
                    e.forwardScore += dayScore
                else
                    e.scored += 1
                    e.firstScored := na(e.firstScored) ? d.cut : e.firstScored
                    e.lastScored := d.cut
                    e.hHit += hh ? 1 : 0
                    e.lHit += lh ? 1 : 0
                    e.both += hh and lh ? 1 : 0
                    e.score += dayScore
                    e.hAbs += math.abs(d.h.mid - d.actualH) / TICK
                    e.lAbs += math.abs(d.l.mid - d.actualL) / TICK
                    e.hWidth += (d.h.hi - d.h.lo) / TICK
                    e.lWidth += (d.l.hi - d.l.lo) / TICK
                    e.fallbackN += e.mode == "ON HAR" and d.fallback ? 1 : 0
            // Canonical availability is independent of each model's fitted scale.
            if d.seen and d.pairTrainingEligible
                array.push(e.pairDates, d.cut)
                if array.size(e.pairDates) > minSamples
                    array.shift(e.pairDates)
            array.push(e.pairRangeDates, d.ending)
            if array.size(e.pairRangeDates) > scaleDays
                array.shift(e.pairRangeDates)
            float dayRange = d.actualH - d.actualL
            if d.seen and not na(d.base) and d.base > 0
                array.push(e.hs, (d.actualH - d.anchor) / d.scale)
                array.push(e.ls, (d.actualL - d.anchor) / d.scale)
                array.push(e.bhs, (d.actualH - d.anchor) / d.base)
                array.push(e.bls, (d.actualL - d.anchor) / d.base)
                array.push(e.dates, d.cut)
                if array.size(e.dates) > e.poolWindow
                    e.evict()
                if not na(d.onRange) and d.onRange > 0 and d.onBars >= onMin
                    array.push(e.xs, math.log(d.base))
                    array.push(e.zs, math.log(d.onRange))
                    array.push(e.ys, math.log(dayRange))
                    if array.size(e.xs) > e.fitWindowN
                        array.shift(e.xs)
                        array.shift(e.zs)
                        array.shift(e.ys)
            array.push(e.ranges, dayRange)
            array.push(e.rangeDates, d.ending)
            if array.size(e.ranges) > scaleDays
                array.shift(e.ranges)
                array.shift(e.rangeDates)
            e.ewma := na(e.ewma) ? dayRange : decay * e.ewma + (1 - decay) * dayRange
        else if not d.excluded
            e.incomplete += 1

method publish(Engine e, float anchor) =>
    Day d = e.d
    d.seen := true
    d.anchor := anchor
    while array.size(e.dates) > 0
        if d.cut - array.first(e.dates) <= e.ageDays * 86400000
            break
        e.evict()
    while array.size(e.rangeDates) > 0
        if d.cut - array.first(e.rangeDates) <= 365 * 86400000
            break
        array.shift(e.rangeDates)
        array.shift(e.ranges)
    // Scale ranges retain the studied fixed 365-day age in both engines.
    // Common residual eligibility uses the shorter candidate/incumbent age.
    while array.size(e.pairRangeDates) > 0
        if d.cut - array.first(e.pairRangeDates) <= 365 * 86400000
            break
        array.shift(e.pairRangeDates)
    while array.size(e.pairDates) > 0
        if d.cut - array.first(e.pairDates) <= e.commonAge * 86400000
            break
        array.shift(e.pairDates)
    d.pairTrainingEligible := array.size(e.pairRangeDates) >= scaleDays
    d.pairReady := d.pairTrainingEligible and array.size(e.pairDates) >= minSamples
    d.samples := array.size(e.dates)
    int start = timestamp(TZ, year(d.cut, TZ), month(d.cut, TZ), dayofmonth(d.cut, TZ) - 1, 18, 0)
    float onH = na
    float onL = na
    if array.size(e.ot) > 0
        for i = 0 to array.size(e.ot) - 1
            int stamp = array.get(e.ot, i)
            if stamp >= start and stamp < d.cut
                onH := na(onH) ? array.get(e.oh, i) : math.max(onH, array.get(e.oh, i))
                onL := na(onL) ? array.get(e.ol, i) : math.min(onL, array.get(e.ol, i))
                d.onBars += 1
    d.onRange := onH - onL
    if array.size(e.ranges) >= scaleDays
        d.base := array.avg(e.ranges)
        d.scale := e.mode == "EWMA" ? e.ewma : d.base
        if e.mode == "ON HAR" and d.onRange > 0 and d.onBars >= onMin and array.size(e.xs) >= fitMin
            float fitted = f_har(e.xs, e.zs, e.ys, d.base, d.onRange)
            if not na(fitted) and fitted > 0
                d.scale := fitted
                d.fallback := false
        if d.base > 0 and d.scale > 0 and d.samples >= minSamples
            d.h := f_band(e.hs, anchor, d.scale)
            d.l := f_band(e.ls, anchor, d.scale)
            d.bh := f_band(e.bhs, anchor, d.base)
            d.bl := f_band(e.bls, anchor, d.base)
            if d.h.lo < d.l.lo or d.h.mid < d.l.mid or d.h.hi < d.l.hi
                runtime.error("HOD/LOD interval order violated")
            d.published := true

f_engine(string engineModel, int engineFitWindow, int enginePool, int engineAge, int pairedAge) =>
    // Each written call owns independent persistent state in its security context.
    var Engine e = Engine.new(d=na, ranges=array.new_float(), rangeDates=array.new_int(), dates=array.new_int(), hs=array.new_float(), ls=array.new_float(), bhs=array.new_float(), bls=array.new_float(), xs=array.new_float(), zs=array.new_float(), ys=array.new_float(), ot=array.new_int(), oh=array.new_float(), ol=array.new_float(), pairRangeDates=array.new_int(), pairDates=array.new_int(), mode=engineModel, fitWindowN=engineFitWindow, poolWindow=enginePool, ageDays=engineAge, commonAge=pairedAge)
    int bo = time[1]
    int be = time_close[1]
    if not na(bo) and bo >= modelStart
        e.firstLoaded := na(e.firstLoaded) ? bo : e.firstLoaded
        e.lastLoaded := be
        array.push(e.ot, bo)
        array.push(e.oh, high[1])
        array.push(e.ol, low[1])
        if array.size(e.ot) > 400
            array.shift(e.ot)
            array.shift(e.oh)
            array.shift(e.ol)
        int yy = year(bo, TZ)
        int mm = month(bo, TZ)
        int dd = dayofmonth(bo, TZ)
        int key = yy * 10000 + mm * 100 + dd
        if na(e.d) or e.d.key != key
            e.finish()
            string ds = str.format_time(bo, "yyyy-MM-dd", TZ)
            int dow = dayofweek(bo, TZ)
            bool excluded = yy < 2019 or yy > 2028 or dow == dayofweek.saturday or dow == dayofweek.sunday or str.contains("," + EXCLUDED_DATES + ",", "," + ds + ",") or str.contains("," + str.replace_all(extraDates, " ", "") + ",", "," + ds + ",")
            e.d := Day.new(key, timestamp(TZ, yy, mm, dd, 9, 25), timestamp(TZ, yy, mm, dd, 9, 30), timestamp(TZ, yy, mm, dd, 16, 0), excluded)
        Day d = e.d
        if not d.done
            if d.excluded
                if be >= d.ending
                    e.finish()
            else
                // Current bar TIME is known at its open; current OHLC is never read.
                if be == d.cut and time == d.cut
                    e.publish(close[1])
                if bo >= d.opening and be <= d.ending
                    int expected = d.bars == 0 ? d.opening : d.lastEnd
                    d.continuous := d.continuous and bo == expected
                    d.bars += 1
                    d.lastEnd := be
                    d.actualH := na(d.actualH) ? high[1] : math.max(d.actualH, high[1])
                    d.actualL := na(d.actualL) ? low[1] : math.min(d.actualL, low[1])
                    if be == d.ending
                        e.finish()
                else if bo >= d.ending
                    e.finish()
    Day d = e.d
    bool ready = false
    string status = "Waiting for history"
    if not na(d)
        ready := d.published
        status := d.excluded ? "Excluded session" : not d.seen ? (time > d.cut ? "Missing 09:25 cutoff" : "Waiting for 09:25 NY") : not ready ? "Warmup" : e.mode == "ON HAR" and d.fallback ? "ON HAR -> BASE fallback" : "Frozen at 09:25 NY"
    // Return only scalars, never persistent arrays/objects across security contexts.
    [ready ? d.h.lo : na, ready ? d.h.mid : na, ready ? d.h.hi : na, ready ? d.l.lo : na, ready ? d.l.mid : na, ready ? d.l.hi : na, na(d) ? na : d.cut, na(d) ? na : d.anchor, na(d) ? na : d.scale, na(d) ? 0 : d.samples, na(d) ? 0 : d.onBars, array.size(e.xs), e.scored, e.hHit, e.lHit, e.both, e.score, e.hAbs, e.lAbs, e.fallbackN, e.incomplete, e.hWidth, e.lWidth, e.firstLoaded, e.lastLoaded, e.firstScored, e.lastScored, e.forwardScored, e.forwardHHit, e.forwardLHit, e.forwardBoth, e.forwardScore, status]


// v0.6: unchanged v0.5 NQ forecast. Other instruments are unit projections.
// Price-ratio level concept: PtGambler's QQQ NDX NQ Price Converter (MPL 2.0).
// New implementation adds exact timestamp matching, frozen anchors and source ages.
// Round QQQ levels are NOT option strikes/OI/gamma. VXN is NOT 0DTE IV.
string nqSymbol = input.symbol("CME_MINI:NQ1!", "NQ model source (continuous, B-ADJ)", group="Sources")
string qSymbol = input.symbol("NASDAQ:QQQ", "QQQ source (extended)", group="Sources")
string xSymbol = input.symbol("NASDAQ:NDX", "NDX cash source", group="Sources")
string ivSymbol = input.symbol("CBOE:VXN", "30-day IV proxy", group="Sources")
bool showGrid = input.bool(true, "QQQ round-price levels", group="QQQ Levels")
float gridStep = input.float(1.0, "QQQ level spacing ($)", minval=0.25, step=0.25, group="QQQ Levels")
int gridCount = input.int(3, "Levels each side", minval=1, maxval=6, group="QQQ Levels")
string gridMode = input.string("Live confirmed", "Level conversion", options=["Live confirmed", "09:25 frozen"], group="QQQ Levels")
bool showLive = input.bool(true, "Separate remaining-session IV envelope", group="IV / 0DTE")
bool liveHistory = input.bool(false, "Show historical live-IV paths", group="Display")
string ivMode = input.string("VXN 30d proxy", "IV source", options=["VXN 30d proxy", "Manual QQQ 0DTE IV"], group="IV / 0DTE")
float manualIV = input.float(0, "Manual ATM IV % (annualized, calendar 365)", minval=0, maxval=500, group="IV / 0DTE")
int manualAsOf = input.time(timestamp("29 Sep 2026 09:30 -0400"), "Manual QQQ IV snapshot time", group="IV / 0DTE")
bool showNOII = input.bool(true, "Nasdaq QQQ auction / NOII box", group="Display")
color highColor = input.color(color.rgb(209, 146, 143), "HOD", group="Display")
color lowColor = input.color(color.rgb(133, 182, 172), "LOD", group="Display")
color liveColor = input.color(color.rgb(181, 188, 199), "Live IV", group="Display")

bool isQ = syminfo.ticker == "QQQ"
bool isX = syminfo.ticker == "NDX"
bool isN = syminfo.ticker == "NQ1!"
if barstate.isfirst
    if not chart.is_standard or not timeframe.isminutes or (timeframe.multiplier != 1 and timeframe.multiplier != 5)
        runtime.error("Use standard 1-minute or 5-minute candles.")
    if not (isQ or isX or isN)
        runtime.error("Use QQQ, NDX or NQ1!. Forecast engine remains NQ; QQQ/NDX are mapped projections.")
    if forwardStart < evalStart
        runtime.error("Forward date must not precede historical evaluation.")

string source = ticker.modify(nqSymbol, session=session.extended, backadjustment=backadjustment.on)
string qSource = ticker.modify(qSymbol, session=session.extended, adjustment=adjustment.none)
// All quote inputs are confirmed [1] bars. Internal state is evaluated on NQ
// so the 09:25 snapshot also exists when the chart is cash NDX (opens 09:30).
f_bridge() =>
    if barstate.isfirst and syminfo.root != "NQ"
        runtime.error("The model source must be an NQ futures ticker.")
    [q, qt] = request.security(qSource, "5", [close[1], time_close[1]], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    [x, xt] = request.security(xSymbol, "5", [close[1], time_close[1]], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    [iv, it] = request.security(ivSymbol, "5", [close[1], time_close[1]], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    float n = close[1]
    int nt = time_close[1]
    int cut = timestamp(TZ, year(time,TZ), month(time,TZ), dayofmonth(time,TZ), 9, 25)
    var float previousXRatio = na
    var int previousXTime = na
    var float fq = na
    var float fx = na
    var float fn = na
    var int fc = na
    var int fxt = na
    var float frozenIV = na
    var int frozenIVTime = na
    // Strict synchronized 16:00 closes; never mix today's NQ with stale NDX.
    if nt == xt and hour(nt,TZ) == 16 and minute(nt,TZ) == 0 and n > 0 and x > 0
        previousXRatio := x / n
        previousXTime := nt
    if time == cut and nt == cut
        fc := cut
        fn := n
        fq := qt == nt and q > 0 ? q : na
        fx := not na(previousXTime) and cut - previousXTime < 5 * 86400000 ? n * previousXRatio : na
        fxt := previousXTime
        frozenIV := not na(it) and it <= cut and cut - it < 5 * 86400000 ? iv : na
        frozenIVTime := it
    [q, qt, x, xt, n, nt, iv, it, fq, fx, fn, fc, fxt, frozenIV, frozenIVTime]

[q, qt, x, xt, n, nt, iv, it, fq, fx, fn, fc, fxt, frozenIV, frozenIVTime] = request.security(source, "5", f_bridge(), lookahead=barmerge.lookahead_on, calc_bars_count=historyBars)
// Local live layers do not wait on the NQ feed when the chart is QQQ/NDX.
[qNow, qtNow] = request.security(qSource,"5",[close[1],time_close[1]],lookahead=barmerge.lookahead_on,ignore_invalid_symbol=true)
[xNow, xtNow] = request.security(xSymbol,"5",[close[1],time_close[1]],lookahead=barmerge.lookahead_on,ignore_invalid_symbol=true)
[ivNow, itNow] = request.security(ivSymbol,"5",[close[1],time_close[1]],lookahead=barmerge.lookahead_on,ignore_invalid_symbol=true)
int pairedAge = math.min(maxAge, 365)
[hl, hm, hh, ll, lm, lh, cutoff, anchor, scale, samples, onBars, fitN, scored, hHit, lHit, both, score, hAbs, lAbs, fallbackN, incomplete, hWidth, lWidth, firstLoaded, lastLoaded, firstScored, lastScored, forwardScored, forwardHHit, forwardLHit, forwardBoth, forwardScore, status] = request.security(source, "5", f_engine(model, fitWindow, lookback, maxAge, pairedAge), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=historyBars)
[ihl, ihm, ihh, ill, ilm, ilh, iCutoff, iAnchor, iScale, iSamples, iOnBars, iFitN, iScored, iHHit, iLHit, iBoth, iScore, iHAbs, iLAbs, iFallbackN, iIncomplete, iHWidth, iLWidth, iFirstLoaded, iLastLoaded, iFirstScored, iLastScored, iForwardScored, iForwardHHit, iForwardLHit, iForwardBoth, iForwardScore, iStatus] = request.security(source, "5", f_engine("ON HAR", 500, 60, 365, pairedAge), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=historyBars)

// Projection uses only the frozen same-day anchor ratio. It never follows spot.
float factor = isN ? 1.0 : fc == cutoff and fn > 0 ? (isQ ? fq : fx) / fn : na
bool visible = not na(hm) and not na(lm) and not na(cutoff) and time >= cutoff and time < cutoff + 395 * 60000 and not na(factor)
f_down(float z) =>
    math.floor(z / syminfo.mintick) * syminfo.mintick
f_up(float z) =>
    math.ceil(z / syminfo.mintick) * syminfo.mintick
f_mid(float z) =>
    math.round_to_mintick(z)
phl = plot(visible ? f_down(hl*factor) : na, "09:25 HOD lower", color.new(highColor, 65), style=plot.style_linebr)
plot(visible ? f_mid(hm*factor) : na, "09:25 HOD median", highColor, 2, plot.style_linebr)
phh = plot(visible ? f_up(hh*factor) : na, "09:25 HOD upper", color.new(highColor, 65), style=plot.style_linebr)
pll = plot(visible ? f_down(ll*factor) : na, "09:25 LOD lower", color.new(lowColor, 65), style=plot.style_linebr)
plot(visible ? f_mid(lm*factor) : na, "09:25 LOD median", lowColor, 2, plot.style_linebr)
plh = plot(visible ? f_up(lh*factor) : na, "09:25 LOD upper", color.new(lowColor, 65), style=plot.style_linebr)
fill(phl, phh, color.new(highColor, 94), "Frozen HOD interval", fillgaps=false)
fill(pll, plh, color.new(lowColor, 94), "Frozen LOD interval", fillgaps=false)
plot(visible and showIncumbent ? f_mid(ihm*factor) : na, "Incumbent HOD", color.gray, 1, plot.style_linebr)
plot(visible and showIncumbent ? f_mid(ilm*factor) : na, "Incumbent LOD", color.gray, 1, plot.style_linebr)

int ending = timestamp(TZ, year(time,TZ), month(time,TZ), dayofmonth(time,TZ), 16, 0)
int opening = ending - 390*60000
bool nqFresh = nt <= time and time - nt < 5*60000
bool qSync = nqFresh and qt == nt and q > 0 and n > 0
bool xSync = nqFresh and xt == nt and x > 0 and n > 0
int liveTime = isN ? nt : isQ ? qtNow : xtNow
bool nativeFresh = liveTime<=time and time-liveTime<5*60000
float spot = nativeFresh ? (isN?n:isQ?qNow:xNow) : na
// Each live envelope expires at 16:00; this is a variance-time approximation,
// NOT a calibrated HOD/LOD interval, not a probability or a trading signal.
string chartDate = str.format_time(time,"yyyy-MM-dd",TZ)
bool sessionExcluded = str.contains(","+EXCLUDED_DATES+",",","+chartDate+",") or str.contains(","+str.replace_all(extraDates," ","")+",",","+chartDate+",") or dayofweek(time,TZ)==dayofweek.saturday or dayofweek(time,TZ)==dayofweek.sunday
bool rth = not sessionExcluded and liveTime >= opening and liveTime < ending and time >= opening and time < ending
float remaining = math.max(0.0, (ending-liveTime)/60000.0)
bool proxyFresh = not na(itNow) and itNow <= liveTime and liveTime-itNow <= 15*60000 and ivNow > 0
bool manualFresh = manualIV > 0 and manualAsOf >= opening and manualAsOf <= liveTime and liveTime-manualAsOf <= 30*60000
bool useManual = ivMode == "Manual QQQ 0DTE IV"
float activeIV = useManual ? (manualFresh ? manualIV : na) : (proxyFresh ? ivNow : na)
float varianceTime = useManual ? remaining/(365.0*1440) : remaining/(252.0*390)
float liveMove = spot*activeIV/100*math.sqrt(varianceTime)
bool liveReady = showLive and rth and not na(spot) and not na(activeIV)
plot(liveReady and liveHistory ? f_up(spot+liveMove) : na, "LIVE IV upper - uncalibrated", color.new(liveColor, 10), 1, plot.style_linebr)
plot(liveReady and liveHistory ? f_down(spot-liveMove) : na, "LIVE IV lower - uncalibrated", color.new(liveColor, 10), 1, plot.style_linebr)

f_num(float z) =>
    na(z) ? "--" : str.tostring(z, "#.##")
f_pct(float z, int count) =>
    count > 0 ? str.tostring(100*z/count,"#.0")+"%" : "--"
f_stamp(int z) =>
    na(z) ? "--" : str.format_time(z,"MM-dd HH:mm",TZ)
f_date(int z) =>
    na(z) ? "--" : str.format_time(z,"yyyy-MM-dd",TZ)

// Last-bar drawings only: seven restrained QQQ levels by default.
var array<line> gridLines = array.new_line()
var array<label> gridLabels = array.new_label()
if barstate.islast
    while array.size(gridLines)>0
        line.delete(array.pop(gridLines))
    while array.size(gridLabels)>0
        label.delete(array.pop(gridLabels))
    bool fixedGrid = gridMode == "09:25 frozen"
    bool localGridSync = nativeFresh and (isN?qSync:isQ?true:qtNow==xtNow)
    float gridQ = fixedGrid ? (fc == cutoff ? fq : na) : (localGridSync ? (isN?q:qNow) : na)
    float gridTarget = fixedGrid ? (isN ? fn : isQ ? fq : fx) : spot
    bool gridReady = showGrid and gridQ > 0 and not na(gridTarget) and (fixedGrid ? visible : localGridSync)
    if gridReady
        float baseLevel = math.round(gridQ/gridStep)*gridStep
        for k = -gridCount to gridCount
            float levelQ = baseLevel+k*gridStep
            float mapped = f_mid(levelQ*gridTarget/gridQ)
            array.push(gridLines,line.new(bar_index-35,mapped,bar_index+8,mapped,color=color.new(color.silver,k==0?40:72),style=line.style_dotted))
            array.push(gridLabels,label.new(bar_index+8,mapped,"QQQ "+f_num(levelQ)+(fixedGrid?" · 09:25":" · LIVE"),style=label.style_label_left,color=color.new(chart.bg_color,100),textcolor=color.silver,size=size.tiny))
    if liveReady
        for direction in array.from(-1.0,1.0)
            float y = f_mid(spot+direction*liveMove)
            array.push(gridLines,line.new(bar_index-20,y,bar_index+8,y,color=liveColor,style=line.style_dashed))
            array.push(gridLabels,label.new(bar_index+8,y,"IV "+(useManual?"0DTE input":"30d proxy"),style=label.style_label_left,color=color.new(chart.bg_color,100),textcolor=liveColor,size=size.tiny))

var table panel = table.new(position.top_right,2,10,bgcolor=color.rgb(16,18,22),frame_color=color.new(color.gray,65),frame_width=1)
var table audit = table.new(position.top_left,2,9,bgcolor=color.rgb(16,18,22))
var table noii = table.new(position.bottom_right,2,3,bgcolor=color.rgb(16,18,22),frame_color=color.new(color.gray,70),frame_width=1)
if barstate.islast
    if showTable
        string projection = isN ? "NQ model · B-ADJ" : isQ ? "QQQ / NQ · 09:25 ratio" : "NDX · prior cash basis projection"
        float driftBps = qSync and fq > 0 and fn > 0 and fc == cutoff ? 10000*((n/q)/(fn/fq)-1) : na
        string frozenState = (visible ? "09:25 FIXED" : not na(hm) and time>=cutoff+395*60000 ? "RTH closed · "+f_date(cutoff) : status)+(not na(driftBps) and math.abs(driftBps)>25 ? " · BASIS DRIFT "+f_num(driftBps)+"bp" : "")
        if not isN and na(factor)
            frozenState := "No valid mapping snapshot"
        string ivState = useManual ? "Manual QQQ 0DTE" : "VXN 30d proxy"
        string liveState = liveReady ? f_num(spot-liveMove)+" / "+f_num(spot+liveMove)+" · "+str.format_time(liveTime,"HH:mm",TZ) : (not rth ? "Outside full RTH session" : "Waiting for aligned price / IV")
        array<string> labels = array.from("F3L1X  /  0.6", "Frozen model", "HOD 20 / 50 / 80", "LOD 20 / 50 / 80", "QQQ / NDX / NQ", "Aligned quote as-of NY", "IV source / as-of NY", "LIVE IV envelope", "NQ audit H / L / joint", "Research status")
        array<string> vals = array.from(projection, frozenState, visible ? f_num(hl*factor)+" / "+f_num(hm*factor)+" / "+f_num(hh*factor) : "--", visible ? f_num(ll*factor)+" / "+f_num(lm*factor)+" / "+f_num(lh*factor) : "--",f_num(q)+" / "+f_num(x)+" / "+f_num(n),f_stamp(nt)+(qSync?" · Q✓":" · Q stale")+(xSync?" X✓":" X stale"),ivState+" "+f_num(useManual?manualIV:ivNow)+"% · "+f_stamp(useManual?manualAsOf:itNow),liveState,f_pct(hHit,scored)+" / "+f_pct(lHit,scored)+" / "+f_pct(both,scored)+" · n="+str.tostring(scored),"Mapped forecasts; IV uncalibrated")
        for row=0 to 9
            table.cell(panel,0,row,array.get(labels,row),text_color=color.gray,text_size=size.tiny,text_halign=text.align_left)
            table.cell(panel,1,row,array.get(vals,row),text_color=row==2?highColor:row==3?lowColor:color.silver,text_size=size.tiny,text_halign=text.align_right)
    else
        table.clear(panel,0,0,1,9)
    if showAudit
        array<string> ak = array.from("NQ ONLY · model audit", "Loaded history", "Scored history", "Pool / HAR / fallback", "Score C / I (NQ ticks)", "Width H / L (ticks)", "Forward n / joint", "09:25 IV context", "NDX frozen basis as-of")
        array<string> av = array.from(model+" · "+str.tostring(fitWindow)+"/"+str.tostring(lookback)+" · "+nqSymbol+" B-ADJ",f_date(firstLoaded)+" → "+f_date(lastLoaded),f_date(firstScored)+" → "+f_date(lastScored),str.tostring(samples)+" / "+str.tostring(fitN)+" / "+str.tostring(fallbackN),f_num(scored>0?score/scored:na)+" / "+f_num(iScored>0?iScore/iScored:na),f_num(scored>0?hWidth/scored:na)+" / "+f_num(scored>0?lWidth/scored:na),str.tostring(forwardScored)+" / "+f_pct(forwardBoth,forwardScored),f_num(frozenIV)+"% · "+f_stamp(frozenIVTime),f_stamp(fxt))
        for row=0 to 8
            table.cell(audit,0,row,array.get(ak,row),text_color=color.gray,text_size=size.tiny,text_halign=text.align_left)
            table.cell(audit,1,row,array.get(av,row),text_color=color.silver,text_size=size.tiny,text_halign=text.align_right)
    else
        table.clear(audit,0,0,1,8)
    if showNOII
        int mn = hour(timenow,TZ)*60+minute(timenow,TZ)
        string today = str.format_time(timenow,"yyyy-MM-dd",TZ)
        bool offDay = dayofweek(timenow,TZ)==dayofweek.saturday or dayofweek(timenow,TZ)==dayofweek.sunday or str.contains(","+EXCLUDED_DATES+",",","+today+",")
        string phase = offDay?"Holiday / special schedule":mn>=565 and mn<568?"OPEN early · 10s":mn>=568 and mn<570?"OPEN full · 1s":mn>=950 and mn<955?"CLOSE early · 10s":mn>=955 and mn<960?"CLOSE full · 1s":"Outside auction window"
        table.cell(noii,0,0,"NASDAQ NOII",text_color=color.silver,text_size=size.tiny,text_halign=text.align_left)
        table.cell(noii,1,0,"QQQ · NY clock "+str.format_time(timenow,"HH:mm",TZ),text_color=color.gray,text_size=size.tiny)
        table.cell(noii,0,1,"Auction phase",text_color=color.gray,text_size=size.tiny,text_halign=text.align_left)
        table.cell(noii,1,1,phase,text_color=color.silver,text_size=size.tiny)
        table.cell(noii,0,2,"Imbalance / paired shares",text_color=color.gray,text_size=size.tiny,text_halign=text.align_left)
        table.cell(noii,1,2,"--  NOII feed unavailable",text_color=color.silver,text_size=size.tiny)
    else
        table.clear(noii,0,0,1,2)
bool newForecast = visible and not na(hm) and (na(hm[1]) or cutoff!=cutoff[1])
alertcondition(newForecast,"09:25 frozen forecast","F3L1X v0.6 09:25 bands frozen. QQQ/NDX are mapped NQ projections; live IV is separate. Check source status.")
````
