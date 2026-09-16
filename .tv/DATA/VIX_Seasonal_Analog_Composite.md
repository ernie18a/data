<!-- tradingview-pine-id: PUB;ac0a6ca10e2243f49ade878210713d98 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VIX Seasonal Analog Composite

Source: https://www.tradingview.com/script/tE4gb7rF-VIX-Seasonal-Analog-Composite/

## Description

█ OVERVIEW

VIX Seasonal Analog Composite draws three lines in a separate pane: the average seasonal path of all complete years of VIX history, a composite of the historical years whose year-to-date VIX path most closely resembles the current year, and the current year's own VIX path. The script requests CBOE:VIX daily closes directly, so it displays VIX seasonality on any chart symbol: applied to an S&P 500 chart, the pane still shows the VIX. All lines are expressed as a percentage of each year's first daily VIX close, and both seasonal lines are projected forward to the end of the current calendar year. The thesis is that the remainder of a VIX year can be contextualized by the average behavior of prior years, and more specifically by the subset of prior years that have tracked the current year most closely so far.

█ HISTORY / BACKGROUND

Seasonal averaging is a long-standing technique in technical analysis: normalize each historical year to a common starting point, average across years by position in the calendar, and read the result as the instrument's typical annual path. Applied to the VIX Index, it captures the well-documented tendency of implied volatility to trough in summer and firm into autumn. Its main weakness is that every year receives equal weight, so years with no resemblance to current conditions dilute the picture.

The analog-year refinement addresses this. Instead of averaging all history, it ranks past years by their similarity to the current year's realized path and averages only the closest matches. Variants of this approach appear in institutional volatility research. The specific similarity metric, selection count, and construction details vary by practitioner and are generally not disclosed. This script implements one explicit, reproducible version of the method for the VIX with all parameters exposed as inputs.

█ HOW IT WORKS

The script runs a single accumulation pass over the chart's daily history and defers all computation and drawing to the last bar.

1. On every chart bar, the script requests the CBOE:VIX daily close through `request.security`. Calendar-year boundaries are detected with `year(time)`. The first available VIX close of each year becomes that year's anchor. Every subsequent VIX close is stored as close divided by the anchor, indexed by trading-day-of-year (0 to 252), in a persistent matrix with one row per year. Bars where the VIX returns no data, such as chart history predating 1990, are skipped.

2. On the last bar, completed years are screened for eligibility: a year must contain at least the minimum number of observations (default 200 trading days) to enter any calculation. The current year is always excluded from the historical pools.

3. The seasonal average is computed per trading-day index as the arithmetic mean of the normalized values of all eligible years at that index.

4. Analog ranking begins once the current year has at least the minimum elapsed days (default 10). For each eligible year, the script computes the root mean square error between that year's normalized path and the current year's normalized path over the trading days elapsed so far, skipping missing pairs. Years are ranked by ascending RMSE and the closest N (default 10) are selected. The analog composite is the per-day mean of the selected years across the full 253-day span, including days the current year has not yet reached.

5. Both seasonal lines are drawn as polylines anchored to bar time: actual bar times for elapsed days, then projected dates stepped one calendar day at a time with weekends skipped for the remainder of the year.

6. The current-year line is drawn over elapsed days only. By default it is linearly rescaled so that its year-to-date range maps onto the vertical range of the two seasonal curves, emulating a second axis within a single-scale pane. A label at its last point shows the true unrescaled year-to-date percentage.

7. A table in the top right lists the selected analog years and their RMSE scores.

Ranking is recomputed on every update, so the analog set can rotate as the current year develops.

█ HOW TO USE

Apply the indicator to any daily chart of a symbol that trades on the US equity session calendar, such as an S&P 500 index chart or the VIX itself. The pane always displays VIX seasonality regardless of the chart symbol, which allows the seasonal context to sit directly beneath the index you are analyzing. The logic counts trading days within calendar years using the chart's bars, so it is designed for the daily timeframe only; other resolutions will produce meaningless day indexing. VIX daily history extends to 1990, so a chart with sufficient loaded history builds seasonal pools from roughly three and a half decades of complete years.

The gray line is the unconditional seasonal script: what an average year looks like. The colored composite line is the conditional version: what years resembling this one looked like, including how they finished. The red line is the current year. Divergence between the current year and the composite indicates the year is departing from its closest historical precedents; the table shows which years those precedents are and how tight the fits are (lower RMSE means closer). A rotating analog table across weeks means the current year lacks a stable historical match, which is itself information.

The projected segments beyond the current date are historical averages extended in time. They describe how past years behaved from this calendar point onward. They are not forecasts.

█ SETTINGS

 • Top analog years: number of closest historical years in the composite. Default 10.
 • Min trading days for an eligible year: observation floor for a year to enter any pool. Default 200.
 • Min elapsed days before analog ranking: current-year data required before ranking begins. Default 10.
 • Show all-year seasonal average: toggles the gray average line. Default on.
 • Show top-N analog composite: toggles the composite line. Default on.
 • Show current-year YTD line: toggles the current-year path. Default on.
 • Rescale YTD onto seasonal range (RHS-style): maps the current-year line onto the seasonal
   curves' vertical range for readability. Default on.
 • Project remainder of year: extends the seasonal lines to year end. Default on.
 • Show analog year table: toggles the analog list with RMSE scores. Default on.
 • Average color, Analog composite color, YTD color: line colors.
 • Line width: width of all three lines. Default 2.

█ WHAT MAKES IT ORIGINAL

Published seasonality scripts typically plot a single all-year average. This script adds a similarity-ranked analog layer computed entirely on the chart: it maintains a full year-by-trading-day matrix of normalized paths, scores every eligible historical year against the current year by RMSE on each update, and averages only the closest matches, so the composite is conditional on how the current year has actually traded rather than on the calendar alone. The construction is fully disclosed and parameterized, including the similarity metric, the selection count, and the eligibility gates. The forward projection is drawn with time-anchored polylines so both seasonal paths extend beyond the last bar to year end, and the current-year line uses an optional range-mapping transform to keep all three curves readable on a single pane scale, with a label preserving the true value.

█ NOTES / LIMITATIONS

 • Daily timeframe only. The trading-day indexing that underlies every calculation assumes one bar
   per trading day.
 • The analog set is re-ranked on every recalculation using the current year's realized path. The
   composite line therefore changes shape as the year develops, including its already-drawn portion.
   This is inherent to the method, and it means the line you see today is not the line you would
   have seen a month ago. Treat it as a conditional historical average, not a signal history.
 • The pane always shows the VIX. The chart symbol supplies only the bar grid and timeline.
 • Trading-day indexing follows the chart symbol's bars. Chart symbols whose sessions differ from
   the US equity calendar, such as symbols with weekend bars or non-US holiday schedules, will
   misalign the day indexing. Use a chart symbol on the US equity session.
 • The seasonal pools depend on the chart's loaded bar depth and on VIX data availability from
   1990. A chart with shallow history averages over fewer years, and less than two complete years
   of overlap draws no seasonal lines at all. Chart bars predating 1990 contribute nothing.
 • Partial first years, and any year below the observation floor, are excluded by the eligibility
   gate.
 • Years are capped at 253 trading days; any bars beyond that index within a year are ignored.
 • Forward projection steps calendar days and skips weekends but not exchange holidays, so
   projected dates drift a few days long by December. Alignment between curves is by trading-day
   index and is unaffected.
 • With rescaling on, the pane axis is literal for the seasonal lines only. The current-year line's
   axis position is a range mapping; read its true value from the label at its endpoint. Early in
   a year, a small realized range makes the rescaled line visually exaggerated.
 • All output is drawn over the current calendar year plus its projection. The pane is empty over
   prior history, which is expected: prior years are inputs to the curves, not drawn objects.
 • The script draws with polylines, a label, and a table only, and declares no plot series, so the
   pane scale derives from the drawings.
 • Nothing in this script is validated as predictive. Both curves are descriptive averages of
   historical paths.

---

## Source Code

````pine
//@version=6
indicator("VIX Seasonal Analog Composite", "VIX Seasonal", overlay = false, format = format.percent, max_polylines_count = 6)

// ── Inputs ─────────────────────────────────────────────────────────────
int    topN       = input.int(10, "Top analog years", minval = 1, maxval = 30)
int    minObs     = input.int(200, "Min trading days for an eligible year", minval = 50, maxval = 253)
int    minElapsed = input.int(10, "Min elapsed days before analog ranking", minval = 2, maxval = 100)
bool   showAvg    = input.bool(true, "Show all-year seasonal average")
bool   showTop    = input.bool(true, "Show top-N analog composite")
bool   showYtd    = input.bool(true, "Show current-year YTD line")
bool   rescaleYtd = input.bool(true, "Rescale YTD onto seasonal range (RHS-style)")
bool   project    = input.bool(true, "Project remainder of year")
bool   showTable  = input.bool(true, "Show analog year table")
color  avgColor   = input.color(color.new(color.gray, 0), "Average color")
color  topColor   = input.color(color.new(#2962FF, 0), "Analog composite color")
color  ytdColor   = input.color(color.new(color.red, 0), "YTD color")
int    lw         = input.int(2, "Line width", minval = 1, maxval = 5)

int MAXTD = 253

// ── Data: always the VIX, regardless of chart symbol ───────────────────
float vix = request.security("CBOE:VIX", "D", close)

// ── Accumulation (one pass, persistent state) ──────────────────────────
// paths: rows = years, cols = trading-day-of-year, values = VIX close / first VIX close of year
var matrix<float> paths    = matrix.new<float>(0, MAXTD, na)
var array<int>    yearNums = array.new<int>()
var array<int>    curTimes = array.new<int>(MAXTD, na)
var int           td       = -1
var float         yStart   = na

bool newYear = bar_index == 0 or year(time) != year(time[1])
if newYear
    matrix.add_row(paths, matrix.rows(paths), array.new<float>(MAXTD, na))
    array.push(yearNums, year(time))
    array.fill(curTimes, na)
    td     := 0
    yStart := vix
else
    td += 1

if na(yStart) and not na(vix)
    yStart := vix

if td < MAXTD and not na(vix) and not na(yStart)
    matrix.set(paths, matrix.rows(paths) - 1, td, vix / yStart)
    array.set(curTimes, td, time)

// ── Computation and drawing on last bar ────────────────────────────────
var polyline plAvg = na
var polyline plTop = na
var polyline plYtd = na
var label    lbYtd = na
var table    tbl   = na

if barstate.islast
    int cur    = matrix.rows(paths) - 1
    int curLen = math.min(td, MAXTD - 1)

    // Eligible completed years (exclude current year, require minObs)
    array<int> elig = array.new<int>()
    if cur >= 1
        for r = 0 to cur - 1
            int cnt = 0
            for c = 0 to MAXTD - 1
                if not na(matrix.get(paths, r, c))
                    cnt += 1
            if cnt >= minObs
                array.push(elig, r)
    int nElig = array.size(elig)

    // All-year seasonal average per trading day
    array<float> avgPath = array.new<float>(MAXTD, na)
    if nElig > 0
        for c = 0 to MAXTD - 1
            float s = 0.0
            int   n = 0
            for i = 0 to nElig - 1
                float v = matrix.get(paths, array.get(elig, i), c)
                if not na(v)
                    s += v
                    n += 1
            if n > 0
                array.set(avgPath, c, s / n)

    // Analog ranking: RMSE of each eligible year vs current YTD normalized path
    array<int>   selRows   = array.new<int>()
    array<float> selScores = array.new<float>()
    if nElig > 0 and curLen >= minElapsed
        array<float> scores = array.new<float>()
        for i = 0 to nElig - 1
            int   r  = array.get(elig, i)
            float se = 0.0
            int   n  = 0
            for c = 0 to curLen
                float a = matrix.get(paths, r, c)
                float b = matrix.get(paths, cur, c)
                if not na(a) and not na(b)
                    se += (a - b) * (a - b)
                    n  += 1
            array.push(scores, n >= minElapsed ? math.sqrt(se / n) : na)
        for j = 1 to topN
            float best = na
            int   bi   = -1
            for i = 0 to array.size(scores) - 1
                float sc = array.get(scores, i)
                if not na(sc) and (na(best) or sc < best)
                    best := sc
                    bi   := i
            if bi >= 0
                array.push(selRows, array.get(elig, bi))
                array.push(selScores, best)
                array.set(scores, bi, na)

    // Top-N analog composite per trading day
    array<float> topPath = array.new<float>(MAXTD, na)
    int nSel = array.size(selRows)
    if nSel > 0
        for c = 0 to MAXTD - 1
            float s = 0.0
            int   n = 0
            for i = 0 to nSel - 1
                float v = matrix.get(paths, array.get(selRows, i), c)
                if not na(v)
                    s += v
                    n += 1
            if n > 0
                array.set(topPath, c, s / n)

    // X-axis times per trading-day index: actual bar times, then projected
    array<int> xs = array.new<int>(MAXTD, na)
    int lastFilled = -1
    for c = 0 to MAXTD - 1
        int tt = array.get(curTimes, c)
        if not na(tt)
            array.set(xs, c, tt)
            lastFilled := c
    if project and lastFilled >= 0 and lastFilled < MAXTD - 1
        int t = array.get(xs, lastFilled)
        for c = lastFilled + 1 to MAXTD - 1
            t += 86400000
            while dayofweek(t) == dayofweek.saturday or dayofweek(t) == dayofweek.sunday
                t += 86400000
            array.set(xs, c, t)

    // Draw in percentage terms (first VIX close of year = 100%)
    if not na(plAvg)
        polyline.delete(plAvg)
    if not na(plTop)
        polyline.delete(plTop)
    if not na(plYtd)
        polyline.delete(plYtd)
    if not na(lbYtd)
        label.delete(lbYtd)
    if showAvg
        array<chart.point> pts = array.new<chart.point>()
        for c = 0 to MAXTD - 1
            float v = array.get(avgPath, c)
            int   tt = array.get(xs, c)
            if not na(v) and not na(tt)
                array.push(pts, chart.point.from_time(tt, v * 100))
        if array.size(pts) > 1
            plAvg := polyline.new(pts, false, false, xloc.bar_time, avgColor, line_width = lw)
    if showTop
        array<chart.point> pts = array.new<chart.point>()
        for c = 0 to MAXTD - 1
            float v = array.get(topPath, c)
            int   tt = array.get(xs, c)
            if not na(v) and not na(tt)
                array.push(pts, chart.point.from_time(tt, v * 100))
        if array.size(pts) > 1
            plTop := polyline.new(pts, false, false, xloc.bar_time, topColor, line_width = lw)
    if showYtd and curLen >= 1
        // Seasonal curve range over the drawn span (rescale target)
        float minS = na
        float maxS = na
        for c = 0 to MAXTD - 1
            if not na(array.get(xs, c))
                float a = array.get(avgPath, c)
                float b = array.get(topPath, c)
                if not na(a)
                    minS := na(minS) ? a : math.min(minS, a)
                    maxS := na(maxS) ? a : math.max(maxS, a)
                if not na(b)
                    minS := na(minS) ? b : math.min(minS, b)
                    maxS := na(maxS) ? b : math.max(maxS, b)
        // Raw YTD range
        float minY = na
        float maxY = na
        for c = 0 to curLen
            float v = matrix.get(paths, cur, c)
            if not na(v)
                minY := na(minY) ? v : math.min(minY, v)
                maxY := na(maxY) ? v : math.max(maxY, v)
        bool canMap = rescaleYtd and not na(minS) and not na(maxS) and not na(minY) and not na(maxY) and maxY > minY and maxS > minS
        array<chart.point> pts = array.new<chart.point>()
        float lastRaw = na
        float lastY   = na
        int   lastT   = na
        for c = 0 to curLen
            float v  = matrix.get(paths, cur, c)
            int   tt = array.get(curTimes, c)
            if not na(v) and not na(tt)
                float y = canMap ? minS + (v - minY) / (maxY - minY) * (maxS - minS) : v
                array.push(pts, chart.point.from_time(tt, y * 100))
                lastRaw := v
                lastY   := y
                lastT   := tt
        if array.size(pts) > 1
            plYtd := polyline.new(pts, false, false, xloc.bar_time, ytdColor, line_width = lw)
            lbYtd := label.new(lastT, lastY * 100, "YTD " + str.tostring(lastRaw * 100, "#.#") + "%", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(ytdColor, 20), textcolor = color.white, size = size.small)

    // Analog year table
    if showTable
        if na(tbl)
            tbl := table.new(position.top_right, 2, topN + 1, border_width = 1)
        table.clear(tbl, 0, 0, 1, topN)
        table.cell(tbl, 0, 0, "Analog", text_size = size.small, bgcolor = color.new(color.gray, 70))
        table.cell(tbl, 1, 0, "RMSE", text_size = size.small, bgcolor = color.new(color.gray, 70))
        if nSel > 0
            for i = 0 to nSel - 1
                table.cell(tbl, 0, i + 1, str.tostring(array.get(yearNums, array.get(selRows, i))), text_size = size.small)
                table.cell(tbl, 1, i + 1, str.tostring(array.get(selScores, i), "#.####"), text_size = size.small)
````
