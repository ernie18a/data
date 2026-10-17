# KTI (Known Trends Index)

- url: https://www.tradingview.com/script/xgdVs5nE-KTI-Known-Trends-Index/
- type: indicator
- pine_id: PUB;1fb0b5a9d9fc4796aad6499c342d1af7
- version: 2.0

## Description

█ OVERVIEW

The KTI (Known Trends Index) is a daily composite that counts how many of thirteen calendar-based seasonal stock market trends are in force on each trading day, plots the count as a histogram in a separate pane, and, because every component is a pure function of the calendar, also draws the index forward for every future trading day through January 31 of the following year. The thesis is that days on which several independent seasonal patterns are simultaneously favorable have historically behaved differently from days on which few or none are, and that this condition can be known entirely in advance.


█ HISTORY / BACKGROUND

The index implements the "Known Trends Index" defined by Jay Kaeppel in his book "Seasonal Stock Market Trends" (2008), Table 9.1. Kaeppel built the composite from seasonal patterns he either researched himself or credited to earlier analysts:

[list]
[*]Yale Hirsch: the November to May favorable period.
[*]Norman Fosback: the favorable trading days at the turn of each month.
[*]Dick Stoken: the favorable window inside the four-year presidential election cycle.
[*]Peter Eliades: the 212-week cycle.
[/list]

The remaining components, including the midmonth trading days, the intradecade windows, the September penalty, and the mini summer rally, are from Kaeppel's own research in the same book. The conceptual basis is twofold. Some components have a proposed mechanism: recurring cash flows into the market at the turn and middle of each month from payroll-driven retirement contributions, sentiment effects around market holidays, and the political incentives of the election cycle. Others, such as the fixed-length 40-week and 212-week cycles, have no known cause and are included only because of their historical regularity. Kaeppel deliberately restricted the composite to trends whose status is knowable in advance, excluding his January barometer and MACD-filtered methods, which require waiting for market data.


█ HOW IT WORKS

On every daily bar the script evaluates the thirteen components below and sums them. Each favorable component adds one point; September subtracts one point.

[list]
[*]Days of the month: trading day 1, 2, 3, 4, 9, 10, 11, or 12, or the last or next-to-last trading day of the month.
[*]November to May: any day from November 1 through the third trading day of May.
[*]Mini summer rally: the last three trading days of June and the first nine trading days of July.
[*]September: every trading day in September counts minus one.
[*]Election cycle window: October 1 of a midterm year through September 30 of the preelection year.
[*]Election cycle window: November 1 through December 31 of the preelection year.
[*]Election cycle window: June 1 through December 31 of the election year.
[*]March 1 through July 31 of the preelection year.
[*]Midterm election days: five trading days before through three trading days after the midterm election day, which the script computes as the Tuesday after the first Monday of November.
[*]40-week cycle: the first 140 calendar days of each 280-day cycle anchored at the close of April 21, 1967.
[*]212-week cycle: the first 184 calendar days of each 1,484-day cycle anchored at May 16, 1938.
[*]Intradecade windows: October 1 of year 4 through March 31 of year 6; March 1 of year 8 through September 30 of year 9; and, in even-numbered decades only, October 1 of year 2 through December 31 of year 5.
[*]Holiday window: within three trading days before through three trading days after each of the eight major market holidays used in the book (New Year's Day, Presidents' Day, Good Friday, Memorial Day, Independence Day, Labor Day, Thanksgiving, Christmas).
[/list]

Because several components are defined in trading days rather than calendar days, the script reconstructs the US equity exchange holiday calendar in code rather than hardcoding dates. All date arithmetic uses GMT noon timestamps so that day differences are exact multiples of one day. The calendar engine computes nth-weekday holidays, last-weekday holidays, observed dates for fixed-date holidays (Saturday observed Friday, Sunday observed Monday), the rule that January 1 falling on a Saturday is not observed, and Good Friday from the Gregorian Easter algorithm. Martin Luther King Jr. Day (from 1998) and Juneteenth (from 2022) are treated as market closures for trading-day counting but are not KTI holiday windows, matching the book. Holiday lists, holiday-window boundaries, the midterm election window, and each month's last two trading days are cached once per year and once per month; a trading-day-of-month counter increments per bar.

The entire component evaluation lives in one function that takes an arbitrary date. The historical plot calls it with the current bar's date. The forward projection calls the same function: on the last bar, the script walks the calendar from the first of the current month (so the trading-day counter is exact) through January 31 of the next year, computes the KTI for every future trading day, and draws each nonzero value as a semi-transparent box at its future timestamp. The projection is rebuilt once per day, not on every tick, and rolls forward automatically at each new year.


█ HOW TO USE

Apply the script to a daily chart of a broad US large-cap index or its tracking fund. The book's benchmark was the Dow Jones Industrial Average. The logic is designed for the daily timeframe only, because every component is defined in exchange trading days; on any other timeframe the script plots nothing and the on-chart table shows a warning.

Visual elements:

[list]
[*]Columns: the historical KTI reading. Red for readings of 1 or less, gray for 2, blue for 3 to 4, teal for 5 or more. These color bands correspond to the zones Kaeppel used in his Chapter 9 models: readings of 3 or more marked his long zone, 5 or more his most favorable zone, 2 neutral, and 1 or less his least favorable zone.
[*]Dotted horizontal lines at 2 and 5 mark those zone boundaries; a solid line marks zero.
[*]Semi-transparent boxes to the right of the last bar: the projected KTI for each future trading day through January 31 of next year, in the same colors. A small "projected" label marks where history ends. Future days with a reading of zero draw no box.
[*]Top-right table: the current reading and a line-by-line list of which components are active today.
[/list]

Four alert conditions are provided for crossings into and out of the reading zones (entering 3 or more, entering 5 or more, dropping below 3, dropping to 1 or less).

To see the projection, give the chart right-side margin in the chart settings or by dragging the price scale. The index is a seasonal context tool, not a trade signal generator; readings describe how many calendar patterns are active, nothing more.


█ SETTINGS

[list]
[*]Show active components (default: on): toggles the top-right table listing the current reading and each active component.
[*]Project KTI through Jan 31 of next year (default: on): toggles the forward-drawn boxes and the "projected" label.
[/list]


█ WHAT MAKES IT ORIGINAL

The script is a complete, self-contained implementation of Kaeppel's published composite rather than a single seasonal filter. Three things distinguish it from typical seasonality scripts. First, it computes the exchange holiday calendar internally, including the Easter computation for Good Friday and observed-date rules, so components defined in trading days ("third trading day of May," "three trading days before Thanksgiving," "five trading days before the midterm election") are evaluated exactly rather than approximated with calendar days. Second, the same date-parameterized function produces both the historical plot and the forward projection, so the projected values are guaranteed to equal what the indicator will print when those dates arrive, barring an unscheduled exchange closure. Third, the forward projection itself: because Kaeppel restricted the index to trends knowable in advance, the script draws the full seasonal map for the year ahead, which is the property that makes this composite useful and which a bar-by-bar indicator cannot show.


█ NOTES / LIMITATIONS

[list]
[*]Daily timeframe only. On any other resolution the plot returns na and the table displays a warning.
[*]The projection is date-bounded: it always ends on January 31 of the year after the chart's last bar and is redrawn when a new daily bar prints.
[*]Unscheduled exchange closures (for example September 2001, the 2012 hurricane closure, national days of mourning) are not modeled. Trading-day counts in those specific weeks, historical or future, can be off by one day.
[*]Market closures on election days before 1970 are not modeled, which slightly shifts the earliest historical midterm windows.
[*]The book's "six months" after each 212-week cycle start is implemented as 184 calendar days, chosen to match the entry and exit dates published in the book.
[*]The 40-week component contributes nothing before its April 1967 anchor and the 212-week component nothing before May 1938, matching the periods over which Kaeppel defined them.
[*]The holiday calendar is the US equity exchange calendar, so the script is meaningful only on US index or US ETF symbols with regular sessions.
[*]The projection uses up to roughly 270 boxes when run early in a year; the script reserves 500 box objects, so no ceiling is hit, but other drawing-heavy scripts on the same pane are unaffected either way.
[*]No claim is made about future results. The index counts calendar conditions; whether the historical tendencies Kaeppel documented persist is unknowable, a caution he repeats throughout the source text.
[/list]

## Source Code

````pine
//@version=6
indicator("Known Trends Index (KTI) - Kaeppel", shorttitle = "KTI", overlay = false, max_boxes_count = 500)

// Implements the Known Trends Index from Jay Kaeppel, "Seasonal Stock Market
// Trends" (2008), Table 9.1. Sums the seasonal trends in force on each
// trading day. Book model thresholds (Ch. 9):
//   KTI >= 5  -> long 2x (LOPL / JUSB)
//   KTI 3-4   -> long, no leverage
//   KTI = 2   -> cash
//   KTI <= 1  -> short (JUSB only)
//
// The book scores each day's close-to-close return by that day's KTI, so a
// position for session N has to be in place at the close of session N-1.
// The script therefore also computes the NEXT session's KTI on every bar and
// the alerts fire on the close BEFORE a zone change.
//
// Use on a DAILY (1D) chart of DJI or DIA (the book's benchmark). SPX also works.
//
// FORWARD PROJECTION: every component is knowable in advance, so the script
// draws the KTI for all future trading days through January 31 of NEXT year
// as semi-transparent columns in the right margin. Add right margin in chart
// settings to see it. Zero-value future days draw no box.
//
// Exchange calendar:
// - Rule-based NYSE holidays including the pre-1971 dates (Washington's
//   Birthday Feb 22, Memorial Day May 30), Lincoln's Birthday (to 1953),
//   Columbus Day (1909-1953), Armistice/Veterans Day (1934-1953), Election
//   Day (to 1968 and 1972/76/80), and era-specific Thanksgiving/observance rules.
// - Unscheduled full-day closures since 1930 are hardcoded (ADHOC).
// - Rules plus ADHOC reproduce the NYSE weekday session calendar exactly
//   for 1930-2026 (checked against pandas_market_calendars).
// - Not modeled: Saturday sessions before Sep 1952; future unscheduled closures.
// - MLK (1998+) and Juneteenth (2022+) count as closures for trading-day math
//   but are NOT KTI holiday windows, per the book.
//
// 40/212-week cycles: by default they run backward from their anchors, which
// reproduces the reading distribution in the book's Table 9.2. The book's
// "6 months" after each 212-week start is 184 calendar days, matching its
// published exit dates.

const int MS_DAY = 86400000
const string TZ = "GMT"

showTable = input.bool(true, "Show active components")
showProj  = input.bool(true, "Project KTI through Jan 31 of next year")
extCycles = input.bool(true, "Extend 40/212-week cycles before anchor dates", tooltip = "On: the cycles run backward from Apr 21 1967 and May 16 1938. This reproduces the KTI distribution in the book's Table 9.2. Off: neither cycle contributes before its anchor.")

// ---------------- date helpers (all timestamps are GMT noon) ----------------
f_ts(int y, int m, int d) =>
    timestamp(TZ, y, m, d, 12, 0)

f_wd(int t) =>
    dayofweek(t, TZ) // 1=Sun ... 7=Sat

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

// Gregorian Easter (anonymous algorithm) minus 2 days.
// Pine v6 int / int returns a fractional result; int() restores integer division.
f_goodFriday(int y) =>
    a = y % 19
    b = int(y / 100)
    c = y % 100
    d = int(b / 4)
    e = b % 4
    f = int((b + 8) / 25)
    g = int((b - f + 1) / 3)
    h = (19 * a + b - d - g + 15) % 30
    i = int(c / 4)
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = int((a + 11 * h + 22 * l) / 451)
    n = h + l - 7 * m + 114
    f_ts(y, int(n / 31), n % 31 + 1) - 2 * MS_DAY

// Sunday -> Monday
f_sunToMon(int t) =>
    f_wd(t) == 1 ? t + MS_DAY : t

// Saturday -> Friday, Sunday -> Monday
f_nearest(int t) =>
    wd = f_wd(t)
    wd == 7 ? t - MS_DAY : wd == 1 ? t + MS_DAY : t

f_thanksgiving(int y) =>
    lt = f_lastWd(y, 11, 5)
    y >= 1942 ? f_nthWd(y, 11, 4, 5) : y >= 1939 ? lt - 7 * MS_DAY : lt

f_presidentsClose(int y) =>
    y >= 1971 ? f_nthWd(y, 2, 3, 2) : y >= 1964 ? f_nearest(f_ts(y, 2, 22)) : f_sunToMon(f_ts(y, 2, 22))

f_memorialClose(int y) =>
    y >= 1971 ? f_lastWd(y, 5, 2) : y >= 1964 and y <= 1969 ? f_nearest(f_ts(y, 5, 30)) : f_sunToMon(f_ts(y, 5, 30))

// Unscheduled full-day NYSE closures since 1930 (yyyymmdd): 1933 bank
// holiday, V-J Day, 1968 paperwork crisis, funerals and days of mourning,
// 1977 blackout, Hurricane Gloria, Sept 11, Hurricane Sandy, and others.
var array<int> ADHOC = array.from(19330306, 19330307, 19330308, 19330309, 19330310, 19330313, 19330314, 19450815,
     19450816, 19451224, 19561224, 19581226, 19610529, 19631125, 19680212, 19680409,
     19680612, 19680619, 19680626, 19680705, 19680710, 19680717, 19680724, 19680731,
     19680807, 19680814, 19680821, 19680828, 19680911, 19680918, 19680925, 19681002,
     19681009, 19681016, 19681023, 19681030, 19681111, 19681120, 19681204, 19681211,
     19681218, 19690210, 19690331, 19690721, 19721228, 19730125, 19770714, 19850927,
     19940427, 20010911, 20010912, 20010913, 20010914, 20040611, 20070102, 20121029,
     20121030, 20181205, 20250109)

// All weekday NYSE closures in year y, used for trading-day math.
// Jan 1 on a Saturday is never moved to Friday (month/year-end rule).
f_mktHolidays(int y) =>
    arr = array.new<int>()
    array.push(arr, f_sunToMon(f_ts(y, 1, 1)))
    if y >= 1998
        array.push(arr, f_nthWd(y, 1, 3, 2))                        // MLK
    array.push(arr, f_presidentsClose(y))
    if y >= 1896 and y <= 1953
        array.push(arr, f_sunToMon(f_ts(y, 2, 12)))                 // Lincoln's Birthday
    array.push(arr, f_goodFriday(y))
    array.push(arr, f_memorialClose(y))
    if y >= 2022
        array.push(arr, f_nearest(f_ts(y, 6, 19)))                  // Juneteenth
    array.push(arr, y >= 1954 ? f_nearest(f_ts(y, 7, 4)) : f_sunToMon(f_ts(y, 7, 4)))
    array.push(arr, f_nthWd(y, 9, 1, 2))                            // Labor Day
    if y >= 1909 and y <= 1953
        array.push(arr, f_sunToMon(f_ts(y, 10, 12)))                // Columbus Day
    if y <= 1968 or y == 1972 or y == 1976 or y == 1980
        array.push(arr, f_nthWd(y, 11, 1, 2) + MS_DAY)              // Election Day
    if y >= 1934 and y <= 1953
        array.push(arr, f_sunToMon(f_ts(y, 11, 11)))                // Armistice/Veterans Day
    array.push(arr, f_thanksgiving(y))
    array.push(arr, y >= 1954 ? f_nearest(f_ts(y, 12, 25)) : f_sunToMon(f_ts(y, 12, 25)))
    for v in ADHOC
        if int(v / 10000) == y
            array.push(arr, f_ts(y, int(v / 100) % 100, v % 100))
    arr

// KTI holiday anchors (Table 3.1; MLK excluded). Anchors use the calendar
// date, so a Saturday Jan 1 still gets its window; for every other holiday
// the calendar date and the observed closure give identical windows.
// Pre-1971: Washington's Birthday Feb 22 and Memorial Day May 30.
// Through 1953 Lincoln's Birthday is a separate February holiday.
f_ktiHolidays(int y) =>
    arr = array.from(f_ts(y, 1, 1), y >= 1971 ? f_nthWd(y, 2, 3, 2) : f_ts(y, 2, 22), f_goodFriday(y), y >= 1971 ? f_lastWd(y, 5, 2) : f_ts(y, 5, 30), f_ts(y, 7, 4), f_nthWd(y, 9, 1, 2), f_thanksgiving(y), f_ts(y, 12, 25))
    if y >= 1896 and y <= 1953
        array.push(arr, f_ts(y, 2, 12))
    arr

// ---------------- caches ----------------
var array<int> holCal  = array.new<int>() // market closures, year-1 .. year+1
var array<int> hwStart = array.new<int>() // KTI holiday window starts
var array<int> hwEnd   = array.new<int>() // KTI holiday window ends
var int cachedYear   = -1
var int jun3rdLastTd = 0
var int midStart     = 0
var int midEnd       = 0

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

// refresh yearly caches
if year != cachedYear
    cachedYear := year
    holCal := array.new<int>()
    for yy = year - 1 to year + 1
        a = f_mktHolidays(yy)
        for h in a
            array.push(holCal, h)
    // KTI holiday windows: this year's anchors plus next year's New Year.
    // Covers every date through Jan 31 of next year (projection horizon).
    hwStart := array.new<int>()
    hwEnd := array.new<int>()
    kh = f_ktiHolidays(year)
    array.push(kh, f_ts(year + 1, 1, 1))
    for h in kh
        array.push(hwStart, f_addTd(h, -3))
        array.push(hwEnd, f_addTd(h, 3))
    // boundary of the last 3 trading days of June (mini summer rally)
    jun3rdLastTd := f_addTd(f_lastTd(year, 6), -2)
    // midterm election window: 5 TDs before through 3 TDs after election day
    if year % 4 == 2
        eday = f_nthWd(year, 11, 1, 2) + MS_DAY // Tuesday after first Monday
        midStart := f_addTd(eday, -5)
        midEnd := f_addTd(eday, 3)
    else
        midStart := 0
        midEnd := 0

// refresh monthly cache
var int cachedMonth  = -1
var int lastTd       = 0
var int secondLastTd = 0
if year * 100 + month != cachedMonth
    cachedMonth := year * 100 + month
    lastTd := f_lastTd(year, month)
    secondLastTd := f_addTd(lastTd, -1)

// ---------------- KTI for an arbitrary date ----------------
// t: GMT-noon timestamp; td: trading day number within its month;
// lTd/sTd: last and second-to-last trading day of its month.
// Uses cached hwStart/hwEnd, midStart/midEnd, jun3rdLastTd, which cover
// every date from the current year through Jan 31 of next year.
int T40_ANCHOR  = timestamp(TZ, 1967, 4, 21, 12, 0)
int T212_ANCHOR = timestamp(TZ, 1938, 5, 16, 12, 0)

f_ktiAt(int t, int td, int lTd, int sTd) =>
    yy = year(t, TZ)
    mm = month(t, TZ)
    cMo = td <= 4 or (td >= 9 and td <= 12) or t == lTd or t == sTd ? 1 : 0
    cNm = mm >= 11 or mm <= 4 or (mm == 5 and td <= 3) ? 1 : 0
    cSu = (mm == 6 and t >= jun3rdLastTd) or (mm == 7 and td <= 9) ? 1 : 0
    cSe = mm == 9 ? -1 : 0
    ymF = yy % 4
    cE1 = (ymF == 2 and mm >= 10) or (ymF == 3 and mm <= 9) ? 1 : 0
    cE2 = ymF == 3 and mm >= 11 ? 1 : 0
    cE3 = ymF == 0 and mm >= 6 ? 1 : 0
    cMj = ymF == 3 and mm >= 3 and mm <= 7 ? 1 : 0
    cMi = midStart > 0 and t >= midStart and t <= midEnd ? 1 : 0
    // Day 1 is the session after the anchor close. The double modulo keeps
    // the phase non-negative for dates before the anchor.
    d40 = int((t - T40_ANCHOR) / MS_DAY)
    p40 = ((d40 - 1) % 280 + 280) % 280
    c40 = (extCycles or d40 > 0) and p40 < 140 ? 1 : 0
    d212 = int((t - T212_ANCHOR) / MS_DAY)
    p212 = ((d212 - 1) % 1484 + 1484) % 1484
    c212 = (extCycles or d212 > 0) and p212 < 184 ? 1 : 0
    ydF = yy % 10
    cMd = (ydF == 4 and mm >= 10) or ydF == 5 or (ydF == 6 and mm <= 3) ? 1 : 0
    cLd = (ydF == 8 and mm >= 3) or (ydF == 9 and mm <= 9) ? 1 : 0
    c20 = int(yy / 10) % 2 == 0 and ((ydF == 2 and mm >= 10) or (ydF >= 3 and ydF <= 5)) ? 1 : 0
    cHo = 0
    for i = 0 to array.size(hwStart) - 1
        if t >= array.get(hwStart, i) and t <= array.get(hwEnd, i)
            cHo := 1
            break
    [cMo, cNm, cSu, cSe, cE1, cE2, cE3, cMj, cMi, c40, c212, cMd, cLd, c20, cHo]

// ---------------- per-bar ----------------
isD1 = timeframe.isdaily and timeframe.multiplier == 1
t0 = f_ts(year, month, dayofmonth)

var int tdom = 0
tdom := na(month[1]) or month != month[1] or year != year[1] ? 1 : tdom + 1

[cMonthly, cNovMay, cSummer, cSep, cEc1, cEc2, cEc3, cMarJul, cMid, c40, c212, cMidDec, cLateDec, c20yr, cHol] = f_ktiAt(t0, tdom, lastTd, secondLastTd)
kti = cMonthly + cNovMay + cSummer + cSep + cEc1 + cEc2 + cEc3 + cMarJul + cMid + c40 + c212 + cMidDec + cLateDec + c20yr + cHol

// Next session's KTI: what a position taken at today's close is exposed to.
tNext = f_addTd(t0, 1)
nMo = month(tNext, TZ)
sameMo = nMo == month
tdNext = sameMo ? tdom + 1 : 1
lNext = sameMo ? lastTd : f_lastTd(year(tNext, TZ), nMo)
sNext = sameMo ? secondLastTd : f_addTd(lNext, -1)
[n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15] = f_ktiAt(tNext, tdNext, lNext, sNext)
ktiNext = n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8 + n9 + n10 + n11 + n12 + n13 + n14 + n15

ktiPlot = isD1 ? kti : na
ktiNextPlot = isD1 ? ktiNext : na

// ---------------- forward projection ----------------
f_col(int k) =>
    k <= 1 ? color.red : k == 2 ? color.gray : k <= 4 ? color.blue : color.teal

var array<box> projBoxes = array.new<box>()
var label projLabel = na

// Rebuilt on every execution of the last bar (realtime ticks included); the
// walk is a few hundred calendar days, so the cost is negligible.
if barstate.islast and isD1 and showProj
    for b in projBoxes
        box.delete(b)
    array.clear(projBoxes)
    if not na(projLabel)
        label.delete(projLabel)
    endT = f_ts(year + 1, 1, 31)
    // walk from the 1st of the current month so the trading-day counter and
    // month boundaries are correct; draw only dates after the current bar
    tt = f_ts(year, month, 1)
    tdF = 0
    curKey = -1
    lTdF = 0
    sTdF = 0
    firstProj = -1
    while tt <= endT
        yy = year(tt, TZ)
        mm = month(tt, TZ)
        if yy * 100 + mm != curKey
            curKey := yy * 100 + mm
            tdF := 0
            lTdF := f_lastTd(yy, mm)
            sTdF := f_addTd(lTdF, -1)
        if f_isTd(tt)
            tdF += 1
            if tt > t0
                [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15] = f_ktiAt(tt, tdF, lTdF, sTdF)
                k = p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9 + p10 + p11 + p12 + p13 + p14 + p15
                if k != 0
                    c = f_col(k)
                    array.push(projBoxes, box.new(left = tt - 6 * 3600000, top = math.max(k, 0), right = tt + 6 * 3600000, bottom = math.min(k, 0), xloc = xloc.bar_time, bgcolor = color.new(c, 60), border_color = color.new(c, 45)))
                if firstProj < 0
                    firstProj := tt
        tt += MS_DAY
    if firstProj > 0
        projLabel := label.new(x = firstProj, y = 8, text = "projected ->", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.gray, 80), textcolor = color.gray, size = size.small)

// ---------------- output ----------------
plot(ktiPlot, style = plot.style_columns, color = f_col(kti), title = "KTI")
plot(ktiNextPlot, "KTI next session", display = display.data_window)
hline(1.5, "Short zone boundary (<= 1)", color = color.red, linestyle = hline.style_dotted)
hline(2.5, "Long zone boundary (>= 3)", color = color.gray, linestyle = hline.style_dotted)
hline(4.5, "Leverage zone boundary (>= 5)", color = color.teal, linestyle = hline.style_dotted)
hline(0, "Zero", color = color.silver)

// Components in the Data Window, for attribution and chart-data export.
plot(isD1 ? cMonthly : na, "Days of month", display = display.data_window)
plot(isD1 ? cNovMay : na, "Nov-May", display = display.data_window)
plot(isD1 ? cSummer : na, "Mini summer rally", display = display.data_window)
plot(isD1 ? cSep : na, "September", display = display.data_window)
plot(isD1 ? cEc1 : na, "Election: Oct midterm-Sep pre", display = display.data_window)
plot(isD1 ? cEc2 : na, "Election: Nov-Dec pre", display = display.data_window)
plot(isD1 ? cEc3 : na, "Election: Jun-Dec election yr", display = display.data_window)
plot(isD1 ? cMarJul : na, "Mar-Jul preelection", display = display.data_window)
plot(isD1 ? cMid : na, "Midterm election days", display = display.data_window)
plot(isD1 ? c40 : na, "40-week cycle", display = display.data_window)
plot(isD1 ? c212 : na, "212-week cycle", display = display.data_window)
plot(isD1 ? cMidDec : na, "Mid-decade Y4-Y6", display = display.data_window)
plot(isD1 ? cLateDec : na, "Late decade Y8-Y9", display = display.data_window)
plot(isD1 ? c20yr : na, "Even decade Y2-Y5", display = display.data_window)
plot(isD1 ? cHol : na, "Holiday window", display = display.data_window)

var table tbl = table.new(position.top_right, 1, 3, border_width = 1)
if barstate.islast
    if not isD1
        table.cell(tbl, 0, 0, "KTI requires a 1D chart", text_color = color.white, bgcolor = color.red)
    else if showTable
        txt = ""
        txt += cMonthly == 1 ? "+1 monthly days\n" : ""
        txt += cNovMay == 1 ? "+1 Nov-May\n" : ""
        txt += cSummer == 1 ? "+1 mini summer rally\n" : ""
        txt += cSep == -1 ? "-1 September\n" : ""
        txt += cEc1 == 1 ? "+1 election window (14-mo)\n" : ""
        txt += cEc2 == 1 ? "+1 election window (Nov-Dec pre)\n" : ""
        txt += cEc3 == 1 ? "+1 election window (Jun-Dec elec)\n" : ""
        txt += cMarJul == 1 ? "+1 Mar-Jul preelection\n" : ""
        txt += cMid == 1 ? "+1 midterm election days\n" : ""
        txt += c40 == 1 ? "+1 40-week cycle\n" : ""
        txt += c212 == 1 ? "+1 212-week cycle\n" : ""
        txt += cMidDec == 1 ? "+1 mid-decade (Y4-Y6)\n" : ""
        txt += cLateDec == 1 ? "+1 late decade (Y8-Y9)\n" : ""
        txt += c20yr == 1 ? "+1 20-year (Y2-Y5)\n" : ""
        txt += cHol == 1 ? "+1 holiday window\n" : ""
        table.cell(tbl, 0, 0, "KTI = " + str.tostring(kti), text_color = color.white, bgcolor = f_col(kti))
        table.cell(tbl, 0, 1, "Next session " + str.format_time(tNext, "yyyy-MM-dd", TZ) + ": " + str.tostring(ktiNext), text_color = color.white, bgcolor = f_col(ktiNext), text_size = size.small)
        table.cell(tbl, 0, 2, txt == "" ? "(no trends active)" : txt, text_size = size.small, text_halign = text.align_left, text_color = color.gray)

// Alerts evaluate on the bar close and look one session ahead, so they arrive
// in time to act at today's close (or tomorrow's open) for tomorrow's session.
alertcondition(isD1 and kti < 3 and ktiNext >= 3, "KTI enters long zone next session", "KTI next session >= 3: long zone")
alertcondition(isD1 and kti < 5 and ktiNext >= 5, "KTI enters leverage zone next session", "KTI next session >= 5: leverage zone")
alertcondition(isD1 and kti >= 5 and ktiNext < 5, "KTI exits leverage zone next session", "KTI next session < 5: leverage off")
alertcondition(isD1 and kti >= 3 and ktiNext < 3, "KTI exits long zone next session", "KTI next session < 3: cash/short zone")
alertcondition(isD1 and kti > 1 and ktiNext <= 1, "KTI enters short zone next session", "KTI next session <= 1: JUSB short zone")
````
