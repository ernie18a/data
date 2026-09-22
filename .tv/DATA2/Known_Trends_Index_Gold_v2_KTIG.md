<!-- tradingview-pine-id: PUB;5d9cef2fe8f7401197c2f089a5467522 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Known Trends Index - Gold v2 (KTI-G)

Source: https://www.tradingview.com/script/hcOC7CCA-KTI-G-Known-Trends-Index-Gold/

## Description

█ OVERVIEW

Known Trends Index - Gold (KTI-G) plots, in a separate pane, a daily integer score that sums the calendar patterns in force on each trading day of a gold chart. The thesis is that gold's seasonal tendencies are better tested by letting the chart's own history define the profile, with a hard in-sample cutoff, than by hardcoding windows taken from published sources.

█ HISTORY / BACKGROUND

The index design follows the Known Trends Index that Jay Kaeppel described for the US equity market: each known seasonal trend contributes one point while it is active, and the sum is read as a favorable, neutral, or unfavorable climate rather than as a trade signal. This script applies that summation structure to gold and changes what the components are.

The literature on gold seasonality has not aged well at the level of specific months. A 2013 academic study of London gold prices from 1980 to 2010 found September and November to be the only months with positive and statistically significant returns. A 2024 replication reported a structural break around December 2010, after which those two months turned negative and January became the significant month. Practitioner windows for gold, including Kaeppel's own trading-day-of-year windows for gold futures, describe the same broad second-half and winter tendency with dates that differ by source.

The one part of the story with a physical mechanism is demand. Indian jewelry buying peaks around Diwali and the wedding season that follows it, and Chinese buying rises in the weeks before the lunar new year. Both festivals move on the lunar calendar, so fixed calendar dates describe them poorly.

The script therefore keeps three fixed components with a stated rationale (physical demand with lunar dates, turn of month, and September as a contested pattern), keeps Kaeppel's windows only as an optional comparison overlay, and gives the largest role to an empirical profile learned from the chart with no lookahead.

█ HOW IT WORKS

All date arithmetic runs on GMT-noon timestamps built from the bar's year, month, and day, so the logic is independent of the chart's exchange timezone. A US market holiday calendar is generated for the current year plus one year on either side (New Year's Day, Martin Luther King Day from 1998, Presidents Day, Good Friday by the Gregorian Easter algorithm, Memorial Day, Juneteenth from 2022, Independence Day, Labor Day, Thanksgiving, Christmas). A trading day is a weekday not in that calendar.

Two counters are maintained per bar: the trading day of month (TDOM) and the trading day of year (TDY). TDY is computed by counting calendar trading days between consecutive bars, so it stays correct across missing bars in the chart data.

The components are computed in this order.

1. Empirical profile. Two arrays of 252 slots accumulate the sum and count of daily returns (close divided by prior close, minus one) by TDY. On each bar the component is scored first, using only what has already been accumulated, and the bar's own return is added afterward. The score compares the smoothed profile for the bar's TDY against the unconditional mean daily return: the smoothed value is the mean return over a circular window of plus or minus the smoothing half-width in TDY slots. The score is +1 when the smoothed value exceeds the unconditional mean by the threshold, -1 when it falls below the mean by the threshold, and 0 otherwise. No score is produced until the accumulated count reaches the minimum number of years multiplied by 250. Accumulation stops after the training end date when the freeze option is on; otherwise it continues as an expanding window. TDY values above 252 fold into slot 252.

2. Physical demand. Diwali is computed for the prior and current year as the new moon nearest November 1, taken as a date in India Standard Time. Chinese New Year is computed for the current and next year as the second new moon after December 21 of the preceding year, taken as a date in Beijing time. New moon instants come from the Meeus mean-phase series with the fourteen largest periodic corrections. The component is +1 from 15 calendar days before Diwali through 45 days after it, and from 30 calendar days before Chinese New Year through the day before it. Overlapping windows do not add.

3. Turn of month. +1 on the last two trading days of a month and the first trading day of the next month.

4. September. The user-set September weight on every bar in September, 0 by default.

5. Kaeppel overlay. Off by default. When on, +1 for TDY 250 through year end and TDY 1 through 38, -1 for TDY 39 through 134, +1 for TDY 135 through 188, -1 for TDY 189 through 249.

KTI-G is the sum of the five components. With default settings the possible range is -3 to +4.

On the last bar of a daily chart the script walks every calendar day from January 1 of the current year through February 28 of the next year, rebuilding TDOM and TDY along the way, evaluates the same component function for each future trading day after the current bar, and draws one box per nonzero value in the right margin. The projection uses the profile arrays as they stand on the last bar. The boxes are deleted and redrawn once per new trading day.

█ HOW TO USE

Apply the script to a daily chart of a gold futures continuous contract, a gold bullion fund, or a gold miner proxy. The code is written for daily bars because every component is defined per trading day; on any other timeframe the main plot returns na and the table shows a notice.

The column plot is the index. Teal columns are readings of 2 or higher, gray columns are 0 or 1, red columns are -1 or lower. Two dotted horizontal lines mark the boundaries at 1.5 and -0.5, and a solid line marks zero. These zone cutoffs are the author's choice and are not taken from any published source; they should be re-examined after inspecting the distribution of readings on the chosen symbol.

The semi-transparent boxes to the right of the last bar are the projected index for each future trading day through February 28 of next year, colored by the same zone rule. A small label marks the first projected day. Zero-value future days draw no box.

The table in the top right shows the current reading, the value and sign of each active component, the profile deviation from the mean in basis points per day, the TDY, whether the bar is in-sample or out-of-sample relative to the training end, the number of training days accumulated, and the computed dates of the current year's Diwali and next year's Chinese New Year.

Eight hidden series are available in the Data Window and in chart data export: each of the five components, the profile deviation in basis points, the TDY, and an in-sample flag. These exist so that the components active during any drawdown can be inspected bar by bar.

The intended use is diagnostic. With the freeze option on, every bar after the training end date is a clean out-of-sample test of whether the seasonal shape learned from the earlier period persisted on that symbol. Comparing the frozen result against the expanding-window result shows whether the shape moved.

█ SETTINGS

Show active components (on): draws the table.

Project through Feb 28 of next year (on): draws the forward projection boxes and label.

Empirical profile
• Empirical TDY profile (on): includes the empirical component in the sum.
• Training end (2010-12-31): last date whose return is accumulated into the profile when freezing is on. The default is the break date reported in the 2024 replication study.
• Freeze profile at training end (on): stops accumulation after the training end. Off gives an expanding window that keeps learning.
• Smoothing half-width (10): number of TDY slots on each side of the current slot averaged together, 0 to 40.
• Threshold vs. mean (3.0 bps/day): the profile must differ from the unconditional mean by this amount to score +1 or -1.
• Minimum years before scoring (10): the empirical component returns 0 until this many years of daily returns, at 250 per year, have been accumulated.

Fixed components
• Physical demand, lunar Diwali + CNY (on).
• Turn of month (on).
• September weight (0): -1, 0, or +1 applied on September bars.
• Kaeppel TDY windows overlay (off).

█ WHAT MAKES IT ORIGINAL

The script combines four things that are not, to the author's knowledge, found together in a published gold seasonality indicator.

First, the seasonal profile is learned from the chart with no lookahead and a user-set in-sample cutoff, so the out-of-sample record of gold seasonality on any symbol can be read directly from the plot rather than inferred from a fixed set of published dates.

Second, the demand component uses computed lunar dates for Diwali and Chinese New Year, generated in the script from a new-moon series, instead of fixed Gregorian windows that drift against the festivals by up to a month.

Third, the trading-day-of-year and trading-day-of-month counters are built from a generated holiday calendar and count calendar trading days between bars, so the index is robust to gaps in the symbol's data and can be projected forward for dates that have no bars yet.

Fourth, every component is exposed as its own series so that a reading can be decomposed on any historical bar, which is the step needed to find out which pattern was active when the index was wrong.

█ NOTES / LIMITATIONS

• The empirical component needs at least the minimum years of daily history before the training end date to score at all. A symbol whose data begins after the training end never scores that component while freezing is on; lower the minimum, move the training end, or turn freezing off. The table's training-day count shows how much history has been used.

• The main plot is na on any timeframe other than daily, and the table displays a notice.

• There is no request.security call and no lookahead. The empirical score on a bar uses only returns from earlier bars. The projection boxes and table are rebuilt on the last bar only; historical columns do not repaint.

• The forward projection is date-bounded at February 28 of the year after the chart's last bar. It rolls forward each calendar year and is not extended beyond that date.

• The projection uses the profile as it stands on the last bar. With freezing off, the projected values can change from day to day as the profile continues to learn.

• Trading-day math uses a US exchange holiday calendar. Gold futures trade on a calendar that differs by a day in some years, and special unscheduled closures are not modeled, so TDY values can be offset by one relative to a futures exchange count in those years.

• Diwali and Chinese New Year dates are computed astronomically and can differ from the observed festival by one day. Rare lunar leap-month cases for Chinese New Year are not handled.

• The zone thresholds and the demand window lengths are the author's constructions. Published seasonal patterns have shown decay after publication, and nothing in this script should be read as a forecast.

• The script uses up to 500 boxes for the projection; a projection window of roughly 300 trading days stays within that ceiling. Per-bar loops are bounded by the smoothing window (at most 81 slots) and the calendar-day gap between consecutive bars.

---

## Source Code

````pine
//@version=6
indicator("Known Trends Index - Gold v2 (KTI-G)", shorttitle = "KTI-G", overlay = false, max_boxes_count = 500)

// Gold seasonality index, second design. Differences from v1:
//
// 1. EMPIRICAL PROFILE replaces the stacked literature windows. The script
//    accumulates the chart's own daily returns by trading day of year (TDY)
//    with no lookahead: the score on any bar uses only returns from bars
//    before it. Accumulation stops at "Training end" (default 2010-12-31,
//    the Potrykus & Augustynowicz break date). Everything after that is a
//    true out-of-sample test of gold seasonality on this symbol. Uncheck
//    "Freeze at training end" for an expanding-window walk-forward instead.
//    Score: +1 where the smoothed profile exceeds the unconditional mean by
//    the threshold, -1 where it falls short by the threshold, else 0.
//
// 2. ONE DEMAND COMPONENT with lunar dates. Diwali (new moon nearest Nov 1,
//    IST) and Chinese New Year (second new moon after the winter solstice,
//    Beijing) are computed with the Meeus new-moon series; expect +/-1 day
//    vs. the observed festival. Windows: Diwali -15d to +45d (Dhanteras
//    run-up through peak wedding season), CNY -30d to -1d (restocking;
//    demand fades after the holiday). Akshaya Tritiya (Apr/May) omitted.
//
// 3. TURN OF MONTH and SEPTEMBER kept as their own components. September
//    defaults to 0 because its sign flipped after 2010.
//
// 4. KAEPPEL TDY WINDOWS kept as an optional comparison overlay (off by
//    default) so the literature rule can be scored against the empirical
//    profile on the same chart.
//
// 5. EVERY COMPONENT is a hidden plot (Data Window + CSV export) for
//    drawdown diagnostics.
//
// Components sum to the index. Default range is -3 to +4. Zones (mine, not
// published): >= 2 favorable, -1 or below unfavorable, else neutral.
// Use on a DAILY chart of GC1!, GLD, or a miner proxy. Miner profiles
// differ from bullion; the empirical component adapts automatically, the
// fixed components do not.
//
// Approximations: NYSE holiday calendar for trading-day math (COMEX differs
// by a day in some years); TDY slots above 252 fold into slot 252.

const int MS_DAY = 86400000
const string TZ = "GMT"
const int NSLOT = 252

showTable = input.bool(true, "Show active components")
showProj = input.bool(true, "Project through Feb 28 of next year")

grpE = "Empirical profile"
useEm = input.bool(true, "Empirical TDY profile (+1 / -1)", group = grpE)
trainEnd = input.time(timestamp("2010-12-31T12:00:00+0000"), "Training end", group = grpE)
freezeAt = input.bool(true, "Freeze profile at training end", group = grpE, tooltip = "Off = expanding window walk-forward, profile keeps learning after training end.")
smoothW = input.int(10, "Smoothing half-width (trading days)", minval = 0, maxval = 40, group = grpE)
thrBps = input.float(3.0, "Threshold vs. mean (bps/day)", minval = 0, step = 0.5, group = grpE)
minYrs = input.int(10, "Minimum years before scoring", minval = 1, group = grpE)

grpF = "Fixed components"
useDe = input.bool(true, "Physical demand, lunar Diwali + CNY (+1)", group = grpF)
useTm = input.bool(true, "Turn of month (+1)", group = grpF)
sepW = input.int(0, "September weight", minval = -1, maxval = 1, group = grpF)
useKp = input.bool(false, "Kaeppel TDY windows overlay (+1 / -1)", group = grpF)

// ---------------- date helpers (all timestamps are GMT noon) ----------------
f_ts(int y, int m, int d) =>
    timestamp(TZ, y, m, d, 12, 0)

f_wd(int t) =>
    dayofweek(t, TZ)

f_leap(int y) =>
    (y % 4 == 0 and y % 100 != 0) or y % 400 == 0

f_dim(int y, int m) =>
    m == 2 ? (f_leap(y) ? 29 : 28) : m == 4 or m == 6 or m == 9 or m == 11 ? 30 : 31

f_nthWd(int y, int m, int nth, int wd) =>
    off = (wd - f_wd(f_ts(y, m, 1)) + 7) % 7
    f_ts(y, m, 1 + off + (nth - 1) * 7)

f_lastWd(int y, int m, int wd) =>
    dl = f_dim(y, m)
    f_ts(y, m, dl - (f_wd(f_ts(y, m, dl)) - wd + 7) % 7)

f_goodFriday(int y) =>
    a = y % 19
    b = y / 100
    c = y % 100
    d = b / 4
    e = b % 4
    f = (b + 8) / 25
    g = (b - f + 1) / 3
    h = (19 * a + b - d - g + 15) % 30
    i = c / 4
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) / 451
    emo = (h + l - 7 * m + 114) / 31
    eda = (h + l - 7 * m + 114) % 31 + 1
    f_ts(y, emo, eda) - 2 * MS_DAY

f_observed(int y, int m, int d) =>
    t = f_ts(y, m, d)
    wd = f_wd(t)
    wd == 7 ? t - MS_DAY : wd == 1 ? t + MS_DAY : t

f_newYear(int y) =>
    wd = f_wd(f_ts(y, 1, 1))
    wd == 7 ? -1 : wd == 1 ? f_ts(y, 1, 2) : f_ts(y, 1, 1)

f_mktHolidays(int y) =>
    arr = array.new<int>()
    ny = f_newYear(y)
    if ny > 0
        array.push(arr, ny)
    if y >= 1998
        array.push(arr, f_nthWd(y, 1, 3, 2))
    array.push(arr, f_nthWd(y, 2, 3, 2))
    array.push(arr, f_goodFriday(y))
    array.push(arr, f_lastWd(y, 5, 2))
    if y >= 2022
        array.push(arr, f_observed(y, 6, 19))
    array.push(arr, f_observed(y, 7, 4))
    array.push(arr, f_nthWd(y, 9, 1, 2))
    array.push(arr, f_nthWd(y, 11, 4, 5))
    array.push(arr, f_observed(y, 12, 25))
    arr

// ---------------- lunar helpers (Meeus, Astronomical Algorithms ch. 49) ----------------
// Julian Ephemeris Day of the k-th new moon since 2000 Jan 6
f_newMoonJD(float k) =>
    T = k / 1236.85
    jde = 2451550.09766 + 29.530588861 * k + 0.00015437 * T * T
    E = 1 - 0.002516 * T
    M = math.toradians(2.5534 + 29.10535670 * k)
    Mp = math.toradians(201.5643 + 385.81693528 * k)
    F = math.toradians(160.7108 + 390.67050284 * k)
    corr = -0.40720 * math.sin(Mp) + 0.17241 * E * math.sin(M) + 0.01608 * math.sin(2 * Mp) + 0.01039 * math.sin(2 * F) + 0.00739 * E * math.sin(Mp - M) - 0.00514 * E * math.sin(Mp + M) + 0.00208 * E * E * math.sin(2 * M) - 0.00111 * math.sin(Mp - 2 * F) - 0.00057 * math.sin(Mp + 2 * F) + 0.00056 * E * math.sin(2 * Mp + M) - 0.00042 * math.sin(3 * Mp) + 0.00042 * E * math.sin(M + 2 * F) + 0.00038 * E * math.sin(M - 2 * F) - 0.00024 * E * math.sin(2 * Mp - M)
    jde + corr

// unix ms of a JD
f_jdToMs(float jd) =>
    int((jd - 2440587.5) * MS_DAY)

// GMT-noon timestamp of the calendar date holding unix ms t, shifted by tzHours
f_dateOf(int t, float tzHours) =>
    tl = t + int(tzHours * 3600000)
    f_ts(year(tl, TZ), month(tl, TZ), dayofmonth(tl, TZ))

// new moon nearest to timestamp t
f_newMoonNear(int t) =>
    yf = 2000 + (t - f_ts(2000, 1, 1)) / (365.25 * MS_DAY)
    k = math.round((yf - 2000) * 12.3685)
    best = f_jdToMs(f_newMoonJD(k))
    for dk = -1 to 1
        cand = f_jdToMs(f_newMoonJD(k + dk))
        if math.abs(cand - t) < math.abs(best - t)
            best := cand
    best

// Diwali (Kartik Amavasya): new moon nearest Nov 1, IST date
f_diwali(int y) =>
    f_dateOf(f_newMoonNear(f_ts(y, 11, 1)), 5.5)

// Chinese New Year: second new moon after the winter solstice of y-1, Beijing date
f_cny(int y) =>
    sol = f_ts(y - 1, 12, 21)
    nm = f_newMoonNear(sol)
    yf = 2000 + (nm - f_ts(2000, 1, 1)) / (365.25 * MS_DAY)
    k = math.round((yf - 2000) * 12.3685)
    while f_jdToMs(f_newMoonJD(k)) <= sol
        k += 1
    while f_jdToMs(f_newMoonJD(k - 1)) > sol
        k -= 1
    f_dateOf(f_jdToMs(f_newMoonJD(k + 1)), 8)

// ---------------- caches ----------------
var array<int> holCal = array.new<int>()
var int cachedYear = -1
var int diwPrev = 0
var int diwCur = 0
var int cnyCur = 0
var int cnyNext = 0

f_isTd(int t) =>
    wd = f_wd(t)
    wd >= 2 and wd <= 6 and not array.includes(holCal, t)

f_addTd(int t, int n) =>
    tt = t
    rem = math.abs(n)
    stp = n >= 0 ? MS_DAY : -MS_DAY
    while rem > 0
        tt += stp
        if f_isTd(tt)
            rem -= 1
    tt

f_lastTd(int y, int m) =>
    t = f_ts(y, m, f_dim(y, m))
    while not f_isTd(t)
        t -= MS_DAY
    t

f_countTd(int fromExcl, int toIncl) =>
    n = 0
    tt = fromExcl + MS_DAY
    while tt <= toIncl
        if f_isTd(tt)
            n += 1
        tt += MS_DAY
    n

if year != cachedYear
    cachedYear := year
    holCal := array.new<int>()
    for yy = year - 1 to year + 1
        a = f_mktHolidays(yy)
        for i = 0 to array.size(a) - 1
            array.push(holCal, array.get(a, i))
    diwPrev := f_diwali(year - 1)
    diwCur := f_diwali(year)
    cnyCur := f_cny(year)
    cnyNext := f_cny(year + 1)

var int cachedMonth = -1
var int lastTd = 0
var int secondLastTd = 0
if year * 100 + month != cachedMonth
    cachedMonth := year * 100 + month
    lastTd := f_lastTd(year, month)
    secondLastTd := f_addTd(lastTd, -1)

// ---------------- empirical profile ----------------
var array<float> slotSum = array.new<float>(NSLOT + 1, 0.0)
var array<int> slotCnt = array.new<int>(NSLOT + 1, 0)
var float totSum = 0.0
var int totCnt = 0

f_slot(int tdy) =>
    math.min(math.max(tdy, 1), NSLOT)

// smoothed mean daily return (as a fraction) for a TDY, circular window
f_profile(int tdy) =>
    s = 0.0
    n = 0
    for i = -smoothW to smoothW
        idx = ((f_slot(tdy) - 1 + i) % NSLOT + NSLOT) % NSLOT + 1
        s += array.get(slotSum, idx)
        n += array.get(slotCnt, idx)
    n > 0 ? s / n : na

f_empScore(int tdy) =>
    if not useEm or totCnt < minYrs * 250
        [0, float(na)]
    else
        p = f_profile(tdy)
        mean = totSum / totCnt
        thr = thrBps / 10000
        sc = na(p) ? 0 : p > mean + thr ? 1 : p < mean - thr ? -1 : 0
        [sc, (p - mean) * 10000]

// ---------------- KTI-G for an arbitrary date ----------------
f_ktigAt(int t, int td, int tdy, int lTd, int sTd) =>
    mm = month(t, TZ)
    [cEm, pBps] = f_empScore(tdy)
    inDiw = (t >= diwPrev - 15 * MS_DAY and t <= diwPrev + 45 * MS_DAY) or (t >= diwCur - 15 * MS_DAY and t <= diwCur + 45 * MS_DAY)
    inCny = (t >= cnyCur - 30 * MS_DAY and t < cnyCur) or (t >= cnyNext - 30 * MS_DAY and t < cnyNext)
    cDe = useDe and (inDiw or inCny) ? 1 : 0
    cTm = useTm and (td == 1 or t == lTd or t == sTd) ? 1 : 0
    cSe = mm == 9 ? sepW : 0
    cKp = not useKp ? 0 : tdy >= 250 or tdy <= 38 ? 1 : tdy <= 134 ? -1 : tdy <= 188 ? 1 : -1
    [cEm, cDe, cTm, cSe, cKp, pBps]

// ---------------- per-bar ----------------
t0 = f_ts(year, month, dayofmonth)

var int tdom = 0
tdom := na(month[1]) or month != month[1] or year != year[1] ? 1 : tdom + 1

var int tdy = 0
var int prevT0 = -1
if prevT0 < 0 or year(prevT0, TZ) != year
    tdy := f_countTd(f_ts(year, 1, 1) - MS_DAY, t0)
else
    tdy := tdy + f_countTd(prevT0, t0)
prevT0 := t0

// score first (uses only prior returns), then accumulate this bar's return
[cEm, cDe, cTm, cSe, cKp, pBps] = f_ktigAt(t0, tdom, tdy, lastTd, secondLastTd)
ktig = cEm + cDe + cTm + cSe + cKp
ktigPlot = timeframe.isdaily ? ktig : na

ret = close / close[1] - 1
if timeframe.isdaily and not na(ret) and (not freezeAt or time <= trainEnd)
    sl = f_slot(tdy)
    array.set(slotSum, sl, array.get(slotSum, sl) + ret)
    array.set(slotCnt, sl, array.get(slotCnt, sl) + 1)
    totSum += ret
    totCnt += 1

// ---------------- forward projection ----------------
f_col(int k) =>
    k <= -1 ? color.red : k <= 1 ? color.gray : color.teal

var array<box> projBoxes = array.new<box>()
var label projLabel = na
var int lastProjDay = -1

if barstate.islast and timeframe.isdaily and showProj and t0 != lastProjDay
    lastProjDay := t0
    for b in projBoxes
        box.delete(b)
    array.clear(projBoxes)
    if not na(projLabel)
        label.delete(projLabel)
    endT = f_ts(year + 1, 2, 28)
    tt = f_ts(year, 1, 1)
    tdF = 0
    tdyF = 0
    curKey = -1
    curYr = -1
    lTdF = 0
    sTdF = 0
    firstProj = -1
    while tt <= endT
        yy = year(tt, TZ)
        mm = month(tt, TZ)
        if yy != curYr
            curYr := yy
            tdyF := 0
        if yy * 100 + mm != curKey
            curKey := yy * 100 + mm
            tdF := 0
            lTdF := f_lastTd(yy, mm)
            sTdF := f_addTd(lTdF, -1)
        if f_isTd(tt)
            tdF += 1
            tdyF += 1
            if tt > t0
                [p1, p2, p3, p4, p5, pb] = f_ktigAt(tt, tdF, tdyF, lTdF, sTdF)
                k = p1 + p2 + p3 + p4 + p5
                if k != 0
                    c = f_col(k)
                    array.push(projBoxes, box.new(left = tt - 6 * 3600000, top = math.max(k, 0), right = tt + 6 * 3600000, bottom = math.min(k, 0), xloc = xloc.bar_time, bgcolor = color.new(c, 60), border_color = color.new(c, 45)))
                if firstProj < 0
                    firstProj := tt
        tt += MS_DAY
    if firstProj > 0
        projLabel := label.new(x = firstProj, y = 4, text = "projected ->", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.gray, 80), textcolor = color.gray, size = size.small)

// ---------------- output ----------------
plot(ktigPlot, style = plot.style_columns, color = f_col(ktig), title = "KTI-G")
hline(1.5, "Favorable threshold (>= 2)", color = color.teal, linestyle = hline.style_dotted)
hline(-0.5, "Unfavorable threshold (<= -1)", color = color.red, linestyle = hline.style_dotted)
hline(0, "Zero", color = color.silver)

// hidden component series for Data Window and export
plot(timeframe.isdaily ? cEm : na, "c_empirical", display = display.data_window)
plot(timeframe.isdaily ? cDe : na, "c_demand", display = display.data_window)
plot(timeframe.isdaily ? cTm : na, "c_turn_of_month", display = display.data_window)
plot(timeframe.isdaily ? cSe : na, "c_september", display = display.data_window)
plot(timeframe.isdaily ? cKp : na, "c_kaeppel", display = display.data_window)
plot(timeframe.isdaily ? pBps : na, "profile_vs_mean_bps", display = display.data_window)
plot(timeframe.isdaily ? tdy : na, "tdy", display = display.data_window)
plot(timeframe.isdaily ? (time <= trainEnd ? 1 : 0) : na, "in_sample", display = display.data_window)

var table tbl = table.new(position.top_right, 1, 2, border_width = 1)
if barstate.islast
    if not timeframe.isdaily
        table.cell(tbl, 0, 0, "KTI-G requires a daily chart", text_color = color.white, bgcolor = color.red)
    else if showTable
        txt = ""
        txt += cEm == 1 ? "+1 empirical profile (" + str.tostring(pBps, "#.0") + " bps vs mean)\n" : cEm == -1 ? "-1 empirical profile (" + str.tostring(pBps, "#.0") + " bps vs mean)\n" : useEm ? "0 empirical profile (" + str.tostring(pBps, "#.0") + " bps vs mean)\n" : ""
        txt += cDe == 1 ? "+1 physical demand window\n" : ""
        txt += cTm == 1 ? "+1 turn of month\n" : ""
        txt += cSe == 1 ? "+1 September\n" : cSe == -1 ? "-1 September\n" : ""
        txt += cKp == 1 ? "+1 Kaeppel favorable\n" : cKp == -1 ? "-1 Kaeppel unfavorable\n" : ""
        txt += "TDY " + str.tostring(tdy) + ", " + (time <= trainEnd ? "in-sample" : "out-of-sample") + ", " + str.tostring(totCnt) + " training days\n"
        txt += "Diwali " + str.format_time(diwCur, "yyyy-MM-dd", TZ) + ", CNY " + str.format_time(cnyNext, "yyyy-MM-dd", TZ)
        table.cell(tbl, 0, 0, "KTI-G = " + str.tostring(ktig), text_color = color.white, bgcolor = f_col(ktig))
        table.cell(tbl, 0, 1, txt, text_size = size.small, text_halign = text.align_left, text_color = color.gray)

alertcondition(ta.crossover(ktigPlot, 1.5), "KTI-G enters favorable zone", "KTI-G >= 2: favorable zone")
alertcondition(ta.crossunder(ktigPlot, 1.5), "KTI-G exits favorable zone", "KTI-G < 2")
alertcondition(ta.crossunder(ktigPlot, -0.5), "KTI-G enters unfavorable zone", "KTI-G <= -1: unfavorable zone")
````
