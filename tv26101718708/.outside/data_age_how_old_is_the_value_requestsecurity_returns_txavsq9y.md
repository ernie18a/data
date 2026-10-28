# Data Age: How Old Is the Value request.security Returns?

- url: https://www.tradingview.com/script/txAVsq9Y-Data-Age-How-Old-Is-the-Value-request-security-Returns/
- type: indicator
- pine_id: PUB;a4f0bb2c859a4ab490089c9d375aa479
- version: 1.0

## Description

WHAT IT DOES
Data Age takes up to three symbol and timeframe pairs and requests each one with request.security at its defaults, gaps = barmerge.gaps_off and lookahead = barmerge.lookahead_off. With gaps off, when the requested symbol prints no bar for a chart bar, the function repeats the last value it has: market closed, weekend, holiday, illiquid symbol, or requested bars that do not line up with the chart's. The repeated number looks like any other, so a ratio, a spread or a correlation that mixes symbols can compute on old prices without any sign of it. The indicator measures, on every confirmed chart bar, how old the returned value is, and counts the result per request.

WHAT IS ORIGINAL HERE
It does not request a price. It requests the close time of the bar that request.security returns, so the value itself says which bar came back. That age falls into three classes. Fresh: the returned bar closed together with the chart bar. Lag: it closed less than one period earlier, as a higher timeframe does by design while its bar forms, or when the requested bars open at :30 against a chart whose bars open at :00. Stale: it closed one full period or more earlier, so the requested symbol printed no bar and the value was carried forward. Keeping lag and stale apart separates the delay a request has by construction from the one the gaps setting hides. The longest stale run shows how far a carried value reaches: a stock on a 24/7 chart stays stale from Friday's close to Monday's first in-session bar.

HOW THE AGE IS MEASURED
- One request.security call per request, at global scope, with gaps off, lookahead off and ignore_invalid_symbol on, requesting the bar's time_close.
- On every confirmed chart bar: no returned value counts as "no data"; otherwise the age is the chart bar's time_close minus the returned time_close, clamped at 0.
- The period is the longer of the requested and the chart timeframe, from timeframe.in_seconds; an empty timeframe means the chart's. Fresh is age 0, lag is above 0 and below one period, stale is one period or more.
- Per request: bars and share per class over the bars with data, mean age, maximum age with its chart bar, longest run of stale bars in bars and as a time span, and the age on the last confirmed bar.
- Counters move only on confirmed bars; the table is drawn on the last bar. No look-ahead, no other request.* call. Charts without time-based bars show a note instead. The shading of request 1's stale bars is drawn on every bar, including the realtime one.

HOW TO USE IT
1. Open a time-based chart. The defaults suit a 24/7 chart such as BINANCE:BTCUSDT on 1 hour: BATS:SPY on 60 shows stock hours against it, TVC:DXY on 60 FX hours, BINANCE:BTCUSDT on D an ordinary higher-timeframe request.
2. Replace the three requests with the symbols and timeframes your own script requests, on the chart it runs on.
3. Read the Stale row. Red means at least one confirmed bar received a carried value; the longest stale run says for how long and the shading shows where.
4. Control: request the chart symbol on the chart timeframe. Every bar must be fresh.

HOW TO READ THE TABLE
Header: symbol and timeframe of each request, bars with a value and bars with none.
Fresh, Lag, Stale: bars per class and their share of the bars with data. Stale is red with at least one stale bar, green with none.
Mean age and Max age: over the bars with data; the maximum names its chart bar, in the chart symbol's exchange time.
Longest stale run: consecutive stale bars, in bars and as a time span.
Age on last bar: the age on the last confirmed bar.

LIMITATIONS
- It shows what these requests return on this chart; it does not read the code of any other script.
- A plain symbol string requests its regular session; extended hours need a ticker built with ticker.new.
- On the realtime bar, request.security returns the requested series' forming bar, whose close lies in the future; the age is clamped at 0, so a bar fresh in realtime can read as lag once the chart is reloaded. The historical counts are the record.
- The period comes from timeframe.in_seconds, so a daily request counts 24 hours even for a symbol whose daily bar covers a shorter session.
- Ages are measured in whole bars from close times; nothing inside a bar is seen.
- Only loaded bars are counted, so history depth, symbol and timeframe change every number. Counts, not a trading rule. Not financial advice.

The chart shows BINANCE:BTCUSDT on the 1 hour timeframe with the default settings. The table is in the bottom right.

## Source Code

````pine
//@version=6
indicator("Data Age: How Old Is the Value request.security Returns?", shorttitle = "DATA-AGE", overlay = true, behind_chart = false)

// Data Age
// 1) Requests, for up to three symbol and timeframe pairs, the close time of the bar that
//    request.security returns, with the function's defaults gaps = barmerge.gaps_off and
//    lookahead = barmerge.lookahead_off. With gaps off the function repeats its last value whenever the
//    requested symbol prints no bar: market closed, weekend, holiday, illiquid symbol, or bar boundaries
//    that do not line up with the chart's.
// 2) On every confirmed chart bar, measures how old that value is: the chart bar's close time minus the
//    returned bar's close time. Classes it as fresh (both bars close together), lag (the returned bar
//    closed less than one period ago) or stale (one period or more: the requested
//    symbol printed no bar, so the value is carried forward).
// 3) Counts bars and shares per class, the mean and maximum age, the longest run of stale bars and the
//    age on the last confirmed bar, one column per request.
// The result is a table of counts for these requests on this chart, not a rule.

// ───────────────────────── Inputs ─────────────────────────
on1 = input.bool(true, "1", group = "Requests", inline = "1")
sym1In = input.symbol("BATS:SPY", "", group = "Requests", inline = "1")
tf1In = input.timeframe("60", "", group = "Requests", inline = "1", tooltip = "Request 1: on/off, symbol and timeframe. An empty timeframe means the chart timeframe. A plain symbol requests its regular session. The chart bars are shaded where this request is stale.")
on2 = input.bool(true, "2", group = "Requests", inline = "2")
sym2In = input.symbol("TVC:DXY", "", group = "Requests", inline = "2")
tf2In = input.timeframe("60", "", group = "Requests", inline = "2", tooltip = "Request 2: on/off, symbol and timeframe. An empty timeframe means the chart timeframe.")
on3 = input.bool(true, "3", group = "Requests", inline = "3")
sym3In = input.symbol("BINANCE:BTCUSDT", "", group = "Requests", inline = "3")
tf3In = input.timeframe("D", "", group = "Requests", inline = "3", tooltip = "Request 3: on/off, symbol and timeframe. An empty timeframe means the chart timeframe.")

shade = input.bool(true, "Shade bars where request 1 is stale", group = "Display", tooltip = "Red tint: on this bar request 1 returned a bar that closed one period or more before the chart bar (the longer of the requested and the chart timeframe), so the value is carried forward from an older bar.")
tablePos = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display")
textSize = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], group = "Display")

// ───────────────────────── Data ─────────────────────────
// Only time-based bars have a close time to compare. On other chart types the table says so and nothing
// is counted.
bool timeBased = not na(time_close)

// Effective symbol and timeframe of each request. An empty timeframe stands for the chart timeframe,
// written out here so that timeframe.in_seconds() receives an explicit string.
string sym1 = sym1In == "" ? syminfo.tickerid : sym1In
string sym2 = sym2In == "" ? syminfo.tickerid : sym2In
string sym3 = sym3In == "" ? syminfo.tickerid : sym3In
string tf1 = tf1In == "" ? timeframe.period : tf1In
string tf2 = tf2In == "" ? timeframe.period : tf2In
string tf3 = tf3In == "" ? timeframe.period : tf3In

// Threshold between lag and stale, in milliseconds: one period of the request or of the chart, whichever
// is longer. A request on a timeframe below the chart's returns its last intrabar, which closes before the
// chart bar does; judged against its own short period it would read stale on every bar.
int chartPeriod = timeframe.in_seconds(timeframe.period) * 1000
int period1 = math.max(timeframe.in_seconds(tf1) * 1000, chartPeriod)
int period2 = math.max(timeframe.in_seconds(tf2) * 1000, chartPeriod)
int period3 = math.max(timeframe.in_seconds(tf3) * 1000, chartPeriod)

// One call per request, at global scope as Pine requires; a disabled request is still called and then
// ignored. The expression is the requested bar's own close time, so the value says which bar came back.
// gaps_off repeats the last value when the requested symbol prints no bar; lookahead_off never returns a
// bar before it has closed. An unknown symbol returns na instead of stopping the script.
int tClose1 = request.security(sym1, tf1, time_close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
int tClose2 = request.security(sym2, tf2, time_close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
int tClose3 = request.security(sym3, tf3, time_close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// Age of a returned value on this chart bar: how long before the chart bar's close the returned bar
// closed. na when nothing came back. Clamped at 0 because on the realtime bar the requested series'
// forming bar is returned, and that bar closes in the future.
ageOf(int reqClose) =>
    na(reqClose) ? int(na) : math.max(0, time_close - reqClose)

int age1 = ageOf(tClose1)
int age2 = ageOf(tClose2)
int age3 = ageOf(tClose3)

// ───────────────────────── Ledger state ─────────────────────────
// Per request (index 0 to 2): bars per class, the sum of ages behind the mean, the maximum age with the
// open time of the chart bar where it was measured, the current and longest stale runs, and the age on
// the last confirmed bar.
var array<int> nFresh = array.new<int>(3, 0)
var array<int> nLag = array.new<int>(3, 0)
var array<int> nStale = array.new<int>(3, 0)
var array<int> nNoData = array.new<int>(3, 0)
var array<float> ageSum = array.new<float>(3, 0.0)
var array<int> ageMax = array.new<int>(3, na)
var array<int> ageMaxTime = array.new<int>(3, na)
var array<int> runBars = array.new<int>(3, 0)
var array<int> runStart = array.new<int>(3, na)
var array<int> runMaxBars = array.new<int>(3, 0)
var array<int> runMaxSpan = array.new<int>(3, 0)
var array<int> lastAge = array.new<int>(3, na)

// ───────────────────────── Ledger update ─────────────────────────
// Records one confirmed bar for request i. A bar with no returned value is counted apart and ends any
// stale run; it has no age.
record(int i, int age, int periodMs) =>
    if na(age)
        array.set(nNoData, i, array.get(nNoData, i) + 1)
        array.set(runBars, i, 0)
    else
        array.set(ageSum, i, array.get(ageSum, i) + age)
        if na(array.get(ageMax, i)) or age > array.get(ageMax, i)
            array.set(ageMax, i, age)
            array.set(ageMaxTime, i, time)
        if age == 0
            array.set(nFresh, i, array.get(nFresh, i) + 1)
        else if age < periodMs
            array.set(nLag, i, array.get(nLag, i) + 1)
        else
            array.set(nStale, i, array.get(nStale, i) + 1)
        // A stale run starts on the first stale bar and ends on the first bar of any other class. Its span
        // runs from the open of its first bar to the close of its last one.
        if age >= periodMs
            if array.get(runBars, i) == 0
                array.set(runStart, i, time)
            array.set(runBars, i, array.get(runBars, i) + 1)
            if array.get(runBars, i) > array.get(runMaxBars, i)
                array.set(runMaxBars, i, array.get(runBars, i))
                array.set(runMaxSpan, i, time_close - array.get(runStart, i))
        else
            array.set(runBars, i, 0)
    array.set(lastAge, i, age)

// Only confirmed time-based bars update the ledger, so a realtime bar never counts twice and no count
// changes after a bar has closed.
if barstate.isconfirmed and timeBased
    if on1
        record(0, age1, period1)
    if on2
        record(1, age2, period2)
    if on3
        record(2, age3, period3)

// ───────────────────────── Shading ─────────────────────────
// Drawn on every bar, including the realtime bar. The counts above are the confirmed-bar record.
bool stale1 = on1 and timeBased and not na(age1) and age1 >= period1
bgcolor(shade and stale1 ? color.new(color.red, 85) : na, title = "Stale bars of request 1")

// ───────────────────────── Table ─────────────────────────
tPos = switch tablePos
    "Top right" => position.top_right
    "Bottom right" => position.bottom_right
    "Top left" => position.top_left
    => position.bottom_left

tSize = switch textSize
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

// Four columns: the measure names and one column per enabled request. Ten rows: header, seven
// measures, two footer rows.
var table tbl = table.new(tPos, 4, 10, border_width = 1)

// Opaque cell colors blended from the chart background, so candles do not show through the table
// on a light or a dark theme.
cellBg = color.from_gradient(0.12, 0.0, 1.0, chart.bg_color, color.gray)
hdrBg = color.from_gradient(0.30, 0.0, 1.0, chart.bg_color, color.gray)
badBg = color.from_gradient(0.40, 0.0, 1.0, chart.bg_color, color.red)
goodBg = color.from_gradient(0.40, 0.0, 1.0, chart.bg_color, color.green)

setCell(int col, int row, string txt, color bg = na, string align = text.align_center) =>
    table.cell(tbl, col, row, txt, text_color = chart.fg_color, text_size = tSize, text_halign = align, bgcolor = na(bg) ? cellBg : bg)

// "45 s", "30 min", "2.5 h" or "2.7 d" from an age in milliseconds, "n/a" when there is none.
fmtAge(int ms) =>
    if na(ms)
        "n/a"
    else if ms < 60000
        str.tostring(ms / 1000.0, "0") + " s"
    else if ms < 3600000
        str.tostring(ms / 60000.0, "0.#") + " min"
    else if ms < 86400000
        str.tostring(ms / 3600000.0, "0.#") + " h"
    else
        str.tostring(ms / 86400000.0, "0.#") + " d"

// "1,234 · 12.3%" from a class count and the number of bars with data.
fmtClass(int n, int total) =>
    total > 0 ? str.tostring(n, "#,##0") + " · " + str.tostring(float(n) / total * 100.0, "0.0") + "%" : "0"

// One table column for request i: header with the symbol, the timeframe and the bar counts, then the
// seven measures.
writeCol(int col, int i, string sym, string tf) =>
    int nF = array.get(nFresh, i)
    int nL = array.get(nLag, i)
    int nS = array.get(nStale, i)
    int nData = nF + nL + nS
    setCell(col, 0, sym + " · " + tf + "\n" + str.tostring(nData, "#,##0") + " bars · " + str.tostring(array.get(nNoData, i), "#,##0") + " no data", hdrBg)
    setCell(col, 1, fmtClass(nF, nData))
    setCell(col, 2, fmtClass(nL, nData))
    // Red as soon as one bar is stale. Green only once there is a bar with data to judge.
    setCell(col, 3, fmtClass(nS, nData), nS > 0 ? badBg : nData > 0 ? goodBg : na)
    setCell(col, 4, nData > 0 ? fmtAge(math.round(array.get(ageSum, i) / nData)) : "n/a")
    int mx = array.get(ageMax, i)
    setCell(col, 5, na(mx) ? "n/a" : fmtAge(mx) + " · " + str.format_time(array.get(ageMaxTime, i), "yyyy-MM-dd HH:mm", syminfo.timezone))
    int rb = array.get(runMaxBars, i)
    setCell(col, 6, rb == 0 ? "none" : str.tostring(rb, "#,##0") + " bars · " + fmtAge(array.get(runMaxSpan, i)))
    setCell(col, 7, fmtAge(array.get(lastAge, i)))

// Column of each enabled request: the enabled ones fill columns 1 onward without gaps.
int col1 = 1
int col2 = 1 + (on1 ? 1 : 0)
int col3 = 1 + (on1 ? 1 : 0) + (on2 ? 1 : 0)
int lastCol = (on1 ? 1 : 0) + (on2 ? 1 : 0) + (on3 ? 1 : 0)

// Merged rows are merged once: merging cells that are already merged on every realtime tick is avoided.
var bool merged = false

if barstate.islast
    if not timeBased
        setCell(0, 0, "Use a time-based chart", hdrBg, text.align_left)
    else if lastCol == 0
        setCell(0, 0, "Enable at least one request", hdrBg, text.align_left)
    else
        setCell(0, 0, "Measure", hdrBg, text.align_left)
        setCell(0, 1, "Fresh · age 0", na, text.align_left)
        setCell(0, 2, "Lag · under 1 period", na, text.align_left)
        setCell(0, 3, "Stale · 1 period or more", na, text.align_left)
        setCell(0, 4, "Mean age", na, text.align_left)
        setCell(0, 5, "Max age · chart bar", na, text.align_left)
        setCell(0, 6, "Longest stale run", na, text.align_left)
        setCell(0, 7, "Age on last bar", na, text.align_left)

        if on1
            writeCol(col1, 0, sym1, tf1)
        if on2
            writeCol(col2, 1, sym2, tf2)
        if on3
            writeCol(col3, 2, sym3, tf3)

        setCell(0, 8, "Dates in the chart symbol's exchange time · " + syminfo.timezone, hdrBg, text.align_left)
        setCell(0, 9, "Counts on confirmed bars. Not advice.", hdrBg, text.align_left)
        for c = 1 to lastCol
            setCell(c, 8, "", hdrBg)
            setCell(c, 9, "", hdrBg)
        if not merged
            table.merge_cells(tbl, 0, 8, lastCol, 8)
            table.merge_cells(tbl, 0, 9, lastCol, 9)
            merged := true
````
