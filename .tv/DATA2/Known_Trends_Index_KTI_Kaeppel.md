<!-- tradingview-pine-id: PUB;1fb0b5a9d9fc4796aad6499c342d1af7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Known Trends Index (KTI) - Kaeppel

Source: https://www.tradingview.com/script/xgdVs5nE-KTI-Known-Trends-Index/

## Description

█ OVERVIEW

The KTI (Known Trends Index) is a daily composite that counts how many of thirteen calendar-based seasonal stock market trends are in force on each trading day, plots the count as a histogram in a separate pane, and, because every component is a pure function of the calendar, also draws the index forward for every future trading day through January 31 of the following year. The thesis is that days on which several independent seasonal patterns are simultaneously favorable have historically behaved differently from days on which few or none are, and that this condition can be known entirely in advance.

█ HISTORY / BACKGROUND

The index implements the "Known Trends Index" defined by Jay Kaeppel in his book "Seasonal Stock Market Trends" (2008), Table 9.1. Kaeppel built the composite from seasonal patterns he either researched himself or credited to earlier analysts:

[*]Yale Hirsch: the November to May favorable period.
[*]Norman Fosback: the favorable trading days at the turn of each month.
[*]Dick Stoken: the favorable window inside the four-year presidential election cycle.
[*]Peter Eliades: the 212-week cycle.

The remaining components, including the midmonth trading days, the intradecade windows, the September penalty, and the mini summer rally, are from Kaeppel's own research in the same book. The conceptual basis is twofold. Some components have a proposed mechanism: recurring cash flows into the market at the turn and middle of each month from payroll-driven retirement contributions, sentiment effects around market holidays, and the political incentives of the election cycle. Others, such as the fixed-length 40-week and 212-week cycles, have no known cause and are included only because of their historical regularity. Kaeppel deliberately restricted the composite to trends whose status is knowable in advance, excluding his January barometer and MACD-filtered methods, which require waiting for market data.

█ HOW IT WORKS

On every daily bar the script evaluates the thirteen components below and sums them. Each favorable component adds one point; September subtracts one point.

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

Because several components are defined in trading days rather than calendar days, the script reconstructs the US equity exchange holiday calendar in code rather than hardcoding dates. All date arithmetic uses GMT noon timestamps so that day differences are exact multiples of one day. The calendar engine computes nth-weekday holidays, last-weekday holidays, observed dates for fixed-date holidays (Saturday observed Friday, Sunday observed Monday), the rule that January 1 falling on a Saturday is not observed, and Good Friday from the Gregorian Easter algorithm. Martin Luther King Jr. Day (from 1998) and Juneteenth (from 2022) are treated as market closures for trading-day counting but are not KTI holiday windows, matching the book. Holiday lists, holiday-window boundaries, the midterm election window, and each month's last two trading days are cached once per year and once per month; a trading-day-of-month counter increments per bar.

The entire component evaluation lives in one function that takes an arbitrary date. The historical plot calls it with the current bar's date. The forward projection calls the same function: on the last bar, the script walks the calendar from the first of the current month (so the trading-day counter is exact) through January 31 of the next year, computes the KTI for every future trading day, and draws each nonzero value as a semi-transparent box at its future timestamp. The projection is rebuilt once per day, not on every tick, and rolls forward automatically at each new year.

█ HOW TO USE

Apply the script to a daily chart of a broad US large-cap index or its tracking fund. The book's benchmark was the Dow Jones Industrial Average. The logic is designed for the daily timeframe only, because every component is defined in exchange trading days; on any other timeframe the script plots nothing and the on-chart table shows a warning.

Visual elements:

[*]Columns: the historical KTI reading. Red for readings of 1 or less, gray for 2, blue for 3 to 4, teal for 5 or more. These color bands correspond to the zones Kaeppel used in his Chapter 9 models: readings of 3 or more marked his long zone, 5 or more his most favorable zone, 2 neutral, and 1 or less his least favorable zone.
[*]Dotted horizontal lines at 2 and 5 mark those zone boundaries; a solid line marks zero.
[*]Semi-transparent boxes to the right of the last bar: the projected KTI for each future trading day through January 31 of next year, in the same colors. A small "projected" label marks where history ends. Future days with a reading of zero draw no box.
[*]Top-right table: the current reading and a line-by-line list of which components are active today.

Four alert conditions are provided for crossings into and out of the reading zones (entering 3 or more, entering 5 or more, dropping below 3, dropping to 1 or less).

To see the projection, give the chart right-side margin in the chart settings or by dragging the price scale. The index is a seasonal context tool, not a trade signal generator; readings describe how many calendar patterns are active, nothing more.

█ SETTINGS

[*]Show active components (default: on): toggles the top-right table listing the current reading and each active component.
[*]Project KTI through Jan 31 of next year (default: on): toggles the forward-drawn boxes and the "projected" label.

█ WHAT MAKES IT ORIGINAL

The script is a complete, self-contained implementation of Kaeppel's published composite rather than a single seasonal filter. Three things distinguish it from typical seasonality scripts. First, it computes the exchange holiday calendar internally, including the Easter computation for Good Friday and observed-date rules, so components defined in trading days ("third trading day of May," "three trading days before Thanksgiving," "five trading days before the midterm election") are evaluated exactly rather than approximated with calendar days. Second, the same date-parameterized function produces both the historical plot and the forward projection, so the projected values are guaranteed to equal what the indicator will print when those dates arrive, barring an unscheduled exchange closure. Third, the forward projection itself: because Kaeppel restricted the index to trends knowable in advance, the script draws the full seasonal map for the year ahead, which is the property that makes this composite useful and which a bar-by-bar indicator cannot show.

█ NOTES / LIMITATIONS

[*]Daily timeframe only. On any other resolution the plot returns na and the table displays a warning.
[*]The projection is date-bounded: it always ends on January 31 of the year after the chart's last bar and is redrawn when a new daily bar prints.
[*]Unscheduled exchange closures (for example September 2001, the 2012 hurricane closure, national days of mourning) are not modeled. Trading-day counts in those specific weeks, historical or future, can be off by one day.
[*]Market closures on election days before 1970 are not modeled, which slightly shifts the earliest historical midterm windows.
[*]The book's "six months" after each 212-week cycle start is implemented as 184 calendar days, chosen to match the entry and exit dates published in the book.
[*]The 40-week component contributes nothing before its April 1967 anchor and the 212-week component nothing before May 1938, matching the periods over which Kaeppel defined them.
[*]The holiday calendar is the US equity exchange calendar, so the script is meaningful only on US index or US ETF symbols with regular sessions.
[*]The projection uses up to roughly 270 boxes when run early in a year; the script reserves 500 box objects, so no ceiling is hit, but other drawing-heavy scripts on the same pane are unaffected either way.
[*]No claim is made about future results. The index counts calendar conditions; whether the historical tendencies Kaeppel documented persist is unknowable, a caution he repeats throughout the source text.

---

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
// Use on a DAILY chart of DJI or DIA (the book's benchmark). SPX also works.
//
// FORWARD PROJECTION: because every KTI component is knowable in advance,
// the script draws the KTI for all future trading days from the current bar
// through January 31 of NEXT year as semi-transparent columns in the right
// margin of the chart. The window rolls forward automatically each year.
// Scroll right / add right margin (chart settings) to see it. Zero-value
// future days draw no box.
//
// Approximations vs. the book:
// - NYSE special closures (9/11/2001, hurricane closures, days of mourning)
//   are not modeled; trading-day counts in those weeks are off by a day.
// - Pre-1970 election-day market closures are not modeled.
// - "6 months" after each 212-week cycle start is implemented as 184
//   calendar days, matching the book's published entry and exit dates.
// - MLK (1998+) and Juneteenth (2022+) count as market holidays for
//   trading-day math but are NOT KTI holiday windows, per the book.
// - If Jan 1 falls on a Saturday, NYSE does not observe it; handled.

const int MS_DAY = 86400000
const string TZ = "GMT"

showTable = input.bool(true, "Show active components")
showProj = input.bool(true, "Project KTI through Jan 31 of next year")

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

// Gregorian Easter (anonymous algorithm) minus 2 days
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

// Sat -> observed Friday, Sun -> observed Monday
f_observed(int y, int m, int d) =>
    t = f_ts(y, m, d)
    wd = f_wd(t)
    wd == 7 ? t - MS_DAY : wd == 1 ? t + MS_DAY : t

// Returns -1 when Jan 1 is a Saturday (NYSE does not observe it)
f_newYear(int y) =>
    wd = f_wd(f_ts(y, 1, 1))
    wd == 7 ? -1 : wd == 1 ? f_ts(y, 1, 2) : f_ts(y, 1, 1)

// All NYSE closures, used for trading-day math
f_mktHolidays(int y) =>
    arr = array.new<int>()
    ny = f_newYear(y)
    if ny > 0
        array.push(arr, ny)
    if y >= 1998
        array.push(arr, f_nthWd(y, 1, 3, 2))   // MLK: 3rd Monday of January
    array.push(arr, f_nthWd(y, 2, 3, 2))       // Presidents Day
    array.push(arr, f_goodFriday(y))
    array.push(arr, f_lastWd(y, 5, 2))         // Memorial Day
    if y >= 2022
        array.push(arr, f_observed(y, 6, 19))  // Juneteenth
    array.push(arr, f_observed(y, 7, 4))       // Independence Day
    array.push(arr, f_nthWd(y, 9, 1, 2))       // Labor Day
    array.push(arr, f_nthWd(y, 11, 4, 5))      // Thanksgiving
    array.push(arr, f_observed(y, 12, 25))     // Christmas
    arr

// The book's 8 major holidays only (Table 3.1; MLK excluded)
f_ktiHolidays(int y) =>
    arr = array.new<int>()
    ny = f_newYear(y)
    if ny > 0
        array.push(arr, ny)
    array.push(arr, f_nthWd(y, 2, 3, 2))
    array.push(arr, f_goodFriday(y))
    array.push(arr, f_lastWd(y, 5, 2))
    array.push(arr, f_observed(y, 7, 4))
    array.push(arr, f_nthWd(y, 9, 1, 2))
    array.push(arr, f_nthWd(y, 11, 4, 5))
    array.push(arr, f_observed(y, 12, 25))
    arr

// ---------------- caches ----------------
var array<int> holCal  = array.new<int>() // market holidays, year-1 .. year+1
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
        for i = 0 to array.size(a) - 1
            array.push(holCal, array.get(a, i))
    // KTI holiday windows: this year's 8 majors plus next year's New Year.
    // Covers every date through Jan 31 of next year (projection horizon).
    hwStart := array.new<int>()
    hwEnd := array.new<int>()
    kh = f_ktiHolidays(year)
    nyNext = f_newYear(year + 1)
    if nyNext > 0
        array.push(kh, nyNext)
    for i = 0 to array.size(kh) - 1
        h = array.get(kh, i)
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
    d40 = (t - f_ts(1967, 4, 21)) / MS_DAY
    c40 = d40 > 0 and (d40 - 1) % 280 < 140 ? 1 : 0
    d212 = (t - f_ts(1938, 5, 16)) / MS_DAY
    c212 = d212 > 0 and (d212 - 1) % 1484 < 184 ? 1 : 0
    ydF = yy % 10
    cMd = (ydF == 4 and mm >= 10) or ydF == 5 or (ydF == 6 and mm <= 3) ? 1 : 0
    cLd = (ydF == 8 and mm >= 3) or (ydF == 9 and mm <= 9) ? 1 : 0
    c20 = (yy / 10) % 2 == 0 and ((ydF == 2 and mm >= 10) or (ydF >= 3 and ydF <= 5)) ? 1 : 0
    cHo = 0
    for i = 0 to array.size(hwStart) - 1
        if t >= array.get(hwStart, i) and t <= array.get(hwEnd, i)
            cHo := 1
            break
    [cMo, cNm, cSu, cSe, cE1, cE2, cE3, cMj, cMi, c40, c212, cMd, cLd, c20, cHo]

// ---------------- per-bar ----------------
t0 = f_ts(year, month, dayofmonth)

var int tdom = 0
tdom := na(month[1]) or month != month[1] or year != year[1] ? 1 : tdom + 1

[cMonthly, cNovMay, cSummer, cSep, cEc1, cEc2, cEc3, cMarJul, cMid, c40, c212, cMidDec, cLateDec, c20yr, cHol] = f_ktiAt(t0, tdom, lastTd, secondLastTd)

kti = cMonthly + cNovMay + cSummer + cSep + cEc1 + cEc2 + cEc3 + cMarJul + cMid + c40 + c212 + cMidDec + cLateDec + c20yr + cHol
ktiPlot = timeframe.isdaily ? kti : na

// ---------------- forward projection ----------------
f_col(int k) =>
    k <= 1 ? color.red : k == 2 ? color.gray : k <= 4 ? color.blue : color.teal

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
hline(2, "Long threshold (>= 3)", color = color.gray, linestyle = hline.style_dotted)
hline(5, "Leverage threshold (>= 5)", color = color.teal, linestyle = hline.style_dotted)
hline(0, "Zero", color = color.silver)

var table tbl = table.new(position.top_right, 1, 2, border_width = 1)
if barstate.islast
    if not timeframe.isdaily
        table.cell(tbl, 0, 0, "KTI requires a daily chart", text_color = color.white, bgcolor = color.red)
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
        table.cell(tbl, 0, 1, txt == "" ? "(no trends active)" : txt, text_size = size.small, text_halign = text.align_left, text_color = color.gray)

alertcondition(ta.crossover(ktiPlot, 2.5), "KTI enters long zone", "KTI >= 3: long zone")
alertcondition(ta.crossover(ktiPlot, 4.5), "KTI enters leverage zone", "KTI >= 5: leverage zone")
alertcondition(ta.crossunder(ktiPlot, 2.5), "KTI exits long zone", "KTI < 3: cash/short zone")
alertcondition(ta.crossunder(ktiPlot, 1.5), "KTI enters short zone", "KTI <= 1: JUSB short zone")
````
