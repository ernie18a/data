# Session DST Audit: Does a Fixed-Offset Session Drift?

- url: https://www.tradingview.com/script/EMa1CDGm-Session-DST-Audit-Does-a-Fixed-Offset-Session-Drift/
- type: indicator
- pine_id: PUB;fcf53176da98436681396d36ab3a065c
- version: 1.0

## Description

WHAT IT DOES
Session DST Audit takes one session string, such as 0930-1600, and checks it twice on every bar of an intraday chart: once in a DST-aware reference zone, for example America/New_York, and once in the zone under test, for example the fixed offset UTC-5. A session string is a local wall-clock window, so the two readings agree only while the two zones share the same UTC offset. When daylight saving time moves the reference clock and the fixed offset stays put, the tested window drifts: with the defaults, from March to November the UTC-5 window runs from 10:30 to 17:00 New York time, so it skips the first hour of the session and adds an hour after the close. The table counts the bars and days affected on the loaded history and compares the missed bars with the added ones.

WHAT IS ORIGINAL HERE
It does not inspect any script's code. It takes the session and the two zones you give it and shows what that pair does on this chart: the same string evaluated in both zones bar by bar, each bar classed as inside both windows, inside the reference window only (missed) or inside the tested window only (added). Each zone's UTC offset is computed at every bar's time, so the offset changes it reports are the ones that fall inside the loaded history. Missed and added bars are kept apart, each with its mean volume and mean range, because an hour at the open and an hour after the close are not the same hour.

HOW THE WINDOWS ARE COMPARED
- On every bar the session is tested in both zones with the bar's open time: a bar is inside a window when that time falls in the session in that zone.
- Three classes: both windows, reference only (missed), tested only (added). Bars in neither window are ignored.
- The UTC offset of a zone on a bar is the bar's wall clock in that zone minus its UTC time, in minutes. Each change across the loaded bars is counted; the last change is shown with its date and both offsets.
- Days are keyed in the reference zone. A session day has at least one bar in either window; a mismatch day has at least one bar in exactly one window. A day is counted when the next one begins, so the current day never is.
- Per class: bar count, mean volume over the bars that have volume, and mean range as (high - low) / close in percent.
- Counters move only on confirmed bars; no count changes after a bar closes, and no other timeframe is requested. Shading is drawn on every bar, including the realtime one.
- The word exchange as the zone under test stands for the chart symbol's exchange timezone.

HOW TO USE IT
1. Open an intraday chart. On daily or higher timeframes the table only says to use an intraday chart.
2. Enter the session string as the script or alert you are checking writes it, and the zone it is meant for.
3. Enter the zone that script or alert actually uses: a fixed offset such as UTC-5, UTC, an IANA name, or exchange.
4. Read the table. Blue bars are inside the reference window only, orange bars inside the tested window only. With both zones equal every count is zero.

HOW TO READ THE TABLE
Session: the string under test, read as a local wall clock.
Reference zone and Zone under test: name, offset on the last bar, number of offset changes on the loaded bars, and the last change with its date and both offsets.
Session days (completed): days with at least one bar in either window, with the first and last date.
Days where the windows differ: days with at least one bar in exactly one window, as a share of session days. Red when there is at least one, green when there are session days and none differ.
Bars in both windows, missed by the tested zone, added by the tested zone: bar counts per class, each with its mean volume and mean range.
Volume, missed vs added: mean volume of the missed bars over that of the added bars.

LIMITATIONS
- The result depends on the loaded history and on the symbol's trading hours: a symbol that does not trade in the added hour shows no added bars, and a short history may hold no offset change.
- Volume is the data vendor's volume for this symbol and feed.
- An unrecognized timezone string stops the script with an error; it is the user's input to check.
- The tool does not read the code of any script or alert. It only shows what one session string with one pair of zones does on this chart.
- Bars are classed by their open time, so a bar that straddles a window boundary counts on the side of its open.
- Counts on loaded bars, not a trading rule. Not financial advice.

The chart shows ES1! (CME) on the 15 minute timeframe with the default settings. The table is in the bottom right.

## Source Code

````pine
//@version=6
indicator("Session DST Audit: Does a Fixed-Offset Session Drift?", shorttitle = "SESSION-DST", overlay = true, behind_chart = false)

// Session DST Audit
// 1) Takes one session string, meant as a local wall-clock window, and checks it twice on every bar:
//    once in a DST-aware reference zone (an IANA name) and once in the zone under test, for example
//    a fixed offset such as "UTC-5".
// 2) Classes each bar: inside both windows, inside the reference window only (missed by the tested
//    zone), or inside the tested window only (added by the tested zone).
// 3) Counts bars and days per class, the UTC offset changes each zone shows on the loaded bars, and
//    the mean volume and range of the missed bars against the added ones.
// The result is a table of counts for this session and this pair of zones on this chart, not a rule.

// ───────────────────────── Inputs ─────────────────────────
sess = input.session("0930-1600:23456", "Session (local wall clock)", group = "Session", tooltip = "The session string as the script or alert you are checking writes it, in the local clock of the reference zone. The ':23456' suffix limits it to Monday to Friday.")
tzRef = input.string("America/New_York", "Reference timezone (DST-aware)", group = "Session", tooltip = "An IANA name such as America/New_York, Europe/London or Asia/Tokyo. This is the local clock the session string is meant for.")
tzTestIn = input.string("UTC-5", "Timezone under test", group = "Session", tooltip = "The zone the script or alert actually uses: a fixed offset such as UTC-5 or UTC, an IANA name, or the word exchange, which means the chart symbol's exchange timezone (syminfo.timezone).")

shade = input.bool(true, "Shade mismatched bars", group = "Display", tooltip = "Blue tint: the bar is inside the session in the reference zone only, so the tested zone misses it. Orange tint: inside the session in the tested zone only, so the tested zone adds it.")
tablePos = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display")

// ───────────────────────── Data ─────────────────────────
// Daily and higher bars have no session window to compare: the table says so and nothing is counted.
bool intraday = timeframe.isintraday

// The tested zone. "exchange" stands for the chart symbol's exchange timezone.
string tzTest = tzTestIn == "exchange" ? syminfo.timezone : tzTestIn

// time() returns na when the bar's open time is outside the session in the given zone.
bool inRef = intraday and not na(time(timeframe.period, sess, tzRef))
bool inTest = intraday and not na(time(timeframe.period, sess, tzTest))

// 0: both windows. 1: reference only (missed by the tested zone). 2: tested only (added). -1: neither.
int cls = inRef and inTest ? 0 : inRef ? 1 : inTest ? 2 : -1

// UTC offset of a zone on this bar, in minutes. The bar's open time is read as a wall clock in `tz`,
// that wall clock is stamped again as if it were UTC, and the difference to the real open time is
// the zone's offset at that instant: -240 for New York in summer, -300 in winter, 0 for UTC.
utcOffsetMin(string tz) =>
    int wall = timestamp("UTC", year(time, tz), month(time, tz), dayofmonth(time, tz), hour(time, tz), minute(time, tz), second(time, tz))
    math.round((wall - time) / 60000.0)

// Day key of this bar in a zone: 20260308 for 8 March 2026.
dayKey(string tz) =>
    year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)

int refOff = utcOffsetMin(tzRef)
int testOff = utcOffsetMin(tzTest)
int dayRef = dayKey(tzRef)
int dayTest = dayKey(tzTest)

// ───────────────────────── Ledger state ─────────────────────────
// Per class (index 0 both, 1 missed, 2 added): bar count, volume sum and number of bars with volume,
// range sum (high - low as a percentage of the close) and number of bars with a range.
var array<int> cnt = array.new<int>(3, 0)
var array<float> volSum = array.new<float>(3, 0.0)
var array<int> volN = array.new<int>(3, 0)
var array<float> rngSum = array.new<float>(3, 0.0)
var array<int> rngN = array.new<int>(3, 0)

// Days, keyed in the reference zone. The open day is finalized when the key changes, so the current
// (incomplete) day is never counted.
var int curDay = na
var bool curSession = false
var bool curMismatch = false
var int sessionDays = 0
var int mismatchDays = 0
var int firstDay = na
var int lastDay = na

// Offset ledger per zone: last offset seen, number of changes, and the day and offsets of the last one.
var int refPrevOff = na
var int refChanges = 0
var int refChangeDay = na
var int refChangeFrom = na
var int refChangeTo = na
var int testPrevOff = na
var int testChanges = 0
var int testChangeDay = na
var int testChangeFrom = na
var int testChangeTo = na

// ───────────────────────── Ledger update ─────────────────────────
// Only confirmed intraday bars update the ledger, so a realtime bar never counts twice and no count
// changes after a bar has closed.
if barstate.isconfirmed and intraday
    // 1) Bars per class, with the sums behind the mean volume and the mean range.
    if cls >= 0
        array.set(cnt, cls, array.get(cnt, cls) + 1)
        if not na(volume)
            array.set(volSum, cls, array.get(volSum, cls) + volume)
            array.set(volN, cls, array.get(volN, cls) + 1)
        float rng = close > 0 ? (high - low) / close * 100.0 : na
        if not na(rng)
            array.set(rngSum, cls, array.get(rngSum, cls) + rng)
            array.set(rngN, cls, array.get(rngN, cls) + 1)

    // 2) Days. A session day has at least one bar in either window; a mismatch day has at least one
    //    bar in exactly one window. The previous day is settled on the first bar of a new day.
    if not na(curDay) and dayRef != curDay
        if curSession
            sessionDays += 1
            mismatchDays += curMismatch ? 1 : 0
            if na(firstDay)
                firstDay := curDay
            lastDay := curDay
        curSession := false
        curMismatch := false
    curDay := dayRef
    curSession := curSession or inRef or inTest
    curMismatch := curMismatch or (inRef != inTest)

    // 3) Offset changes, one ledger per zone. The day recorded is the first day seen with the new offset.
    if not na(refPrevOff) and refOff != refPrevOff
        refChanges += 1
        refChangeDay := dayRef
        refChangeFrom := refPrevOff
        refChangeTo := refOff
    refPrevOff := refOff
    if not na(testPrevOff) and testOff != testPrevOff
        testChanges += 1
        testChangeDay := dayTest
        testChangeFrom := testPrevOff
        testChangeTo := testOff
    testPrevOff := testOff

// ───────────────────────── Shading ─────────────────────────
// Drawn on every bar, including the realtime bar. The counts above are the confirmed-bar record.
color shadeCol = not shade ? na : cls == 1 ? color.new(color.blue, 80) : cls == 2 ? color.new(color.orange, 80) : na
bgcolor(shadeCol, title = "Mismatched bars")

// ───────────────────────── Table ─────────────────────────
tPos = switch tablePos
    "Top right" => position.top_right
    "Bottom right" => position.bottom_right
    "Top left" => position.top_left
    => position.bottom_left

var table tbl = table.new(tPos, 3, 12, border_width = 1)

// Opaque cell colors blended from the chart background, so candles do not show through the table
// on a light or a dark theme.
cellBg = color.from_gradient(0.12, 0.0, 1.0, chart.bg_color, color.gray)
hdrBg = color.from_gradient(0.30, 0.0, 1.0, chart.bg_color, color.gray)
badBg = color.from_gradient(0.40, 0.0, 1.0, chart.bg_color, color.red)
goodBg = color.from_gradient(0.40, 0.0, 1.0, chart.bg_color, color.green)

setCell(int col, int row, string txt, color bg = na, string align = text.align_center) =>
    table.cell(tbl, col, row, txt, text_color = chart.fg_color, text_size = size.small, text_halign = align, bgcolor = na(bg) ? cellBg : bg)

// "UTC-4", "UTC+5:30" or "UTC+0" from an offset in minutes.
fmtOffset(int m) =>
    int a = math.abs(m)
    int mm = a % 60
    string txt = "UTC" + (m < 0 ? "-" : "+") + str.tostring((a - mm) / 60, "0")
    mm > 0 ? txt + ":" + str.tostring(mm, "00") : txt

// "2026-03-08" from a day key, "n/a" when there is none.
fmtDay(int k) =>
    if na(k)
        "n/a"
    else
        int d = k % 100
        int ym = int((k - d) / 100)
        int m = ym % 100
        int y = int((ym - m) / 100)
        str.tostring(y, "0000") + "-" + str.tostring(m, "00") + "-" + str.tostring(d, "00")

// Note of a zone row: the offset on the last bar and the offset changes seen on the chart.
zoneNote(int nowOff, int changes, int day, int offBefore, int offAfter) =>
    string head = "now " + fmtOffset(nowOff) + " · "
    changes == 0 ? head + "no offset change on chart" : head + str.tostring(changes) + " offset change" + (changes == 1 ? "" : "s") + ", last " + fmtDay(day) + " (" + fmtOffset(offBefore) + " → " + fmtOffset(offAfter) + ")"

// Note of a class row: the mean volume and the mean range of that class, "n/a" when no bar has them.
classNote(int i) =>
    int n = array.get(volN, i)
    int r = array.get(rngN, i)
    string v = n > 0 ? str.tostring(array.get(volSum, i) / n, "#,##0.##") : "n/a"
    string g = r > 0 ? str.tostring(array.get(rngSum, i) / r, "0.000") + "%" : "n/a"
    "mean vol " + v + " · mean range " + g

// Merged rows are merged once: merging cells that are already merged on every realtime tick is avoided.
var bool merged = false

if barstate.islast
    if not intraday
        setCell(0, 0, "Use an intraday chart", hdrBg, text.align_left)
        setCell(1, 0, "", hdrBg)
        setCell(2, 0, "", hdrBg)
        if not merged
            table.merge_cells(tbl, 0, 0, 2, 0)
            merged := true
    else
        int nBoth = array.get(cnt, 0)
        int nMissed = array.get(cnt, 1)
        int nAdded = array.get(cnt, 2)
        float meanVolMissed = array.get(volN, 1) > 0 ? array.get(volSum, 1) / array.get(volN, 1) : na
        float meanVolAdded = array.get(volN, 2) > 0 ? array.get(volSum, 2) / array.get(volN, 2) : na
        float volRatio = not na(meanVolMissed) and not na(meanVolAdded) and meanVolAdded > 0 ? meanVolMissed / meanVolAdded : na
        float shMismatch = sessionDays > 0 ? float(mismatchDays) / sessionDays * 100.0 : na

        setCell(0, 0, "Measure", hdrBg, text.align_left)
        setCell(1, 0, "Value", hdrBg)
        setCell(2, 0, "Note", hdrBg)

        setCell(0, 1, "Session", na, text.align_left)
        setCell(1, 1, sess)
        setCell(2, 1, "local wall clock")

        setCell(0, 2, "Reference zone", na, text.align_left)
        setCell(1, 2, tzRef)
        setCell(2, 2, zoneNote(refOff, refChanges, refChangeDay, refChangeFrom, refChangeTo))

        setCell(0, 3, "Zone under test", na, text.align_left)
        setCell(1, 3, tzTest)
        setCell(2, 3, zoneNote(testOff, testChanges, testChangeDay, testChangeFrom, testChangeTo))

        setCell(0, 4, "Session days (completed)", na, text.align_left)
        setCell(1, 4, str.tostring(sessionDays))
        setCell(2, 4, sessionDays > 0 ? fmtDay(firstDay) + " to " + fmtDay(lastDay) : "no completed session day")

        // Red as soon as one day differs. Green only once there is a completed session day to judge.
        color misBg = mismatchDays > 0 ? badBg : sessionDays > 0 ? goodBg : na
        setCell(0, 5, "Days where the windows differ", na, text.align_left)
        setCell(1, 5, str.tostring(mismatchDays), misBg)
        setCell(2, 5, na(shMismatch) ? "n/a" : str.tostring(shMismatch, "0.0") + "% of session days", misBg)

        setCell(0, 6, "Bars in both windows", na, text.align_left)
        setCell(1, 6, str.tostring(nBoth))
        setCell(2, 6, classNote(0))

        setCell(0, 7, "Bars missed by the tested zone", na, text.align_left)
        setCell(1, 7, str.tostring(nMissed))
        setCell(2, 7, classNote(1))

        setCell(0, 8, "Bars added by the tested zone", na, text.align_left)
        setCell(1, 8, str.tostring(nAdded))
        setCell(2, 8, classNote(2))

        setCell(0, 9, "Volume, missed vs added", na, text.align_left)
        setCell(1, 9, na(volRatio) ? "n/a" : str.tostring(volRatio, "0.00") + "×")
        setCell(2, 9, "mean volume of missed / added")

        setCell(0, 10, "Reference " + tzRef + " vs test " + tzTest + " · session in each zone's local clock", hdrBg, text.align_left)
        setCell(0, 11, "Counts on loaded bars. Not advice.", hdrBg, text.align_left)
        for c = 1 to 2
            setCell(c, 10, "", hdrBg)
            setCell(c, 11, "", hdrBg)
        if not merged
            table.merge_cells(tbl, 0, 10, 2, 10)
            table.merge_cells(tbl, 0, 11, 2, 11)
            merged := true
````
