# Gann Mass Pressure

- url: https://www.tradingview.com/script/UvuKRLYD-Gann-Mass-Pressure/
- type: indicator
- pine_id: PUB;d2b6bec70872431d8017c3e83951a30a
- version: 2.0

## Description

█ OVERVIEW

The Gann Mass Pressure indicator projects a seasonal price forecast for the remainder of the calendar year. It averages historical closes from the same calendar date across multiple past decades to produce a composite trend line that extends forward from the current bar through December 31. The method was documented by Constance Brown in [i]The 32nd Jewel: Gann Analysis, Part 2, Price and Time[/i] (Chapter VII, Section L), reproducing W.D. Gann's original six-term formula with lookback intervals of 10, 20, 30, 40, 60, and 80 years.


█ [b]HOW IT WORKS[/b]

For each calendar date, the indicator:

1 — Identifies the month and day.
2 — Looks back to that same calendar date at each of the six configurable intervals
   (default: 10, 20, 30, 40, 60, and 80 years).
3 — Finds the closest matching trading day within a ±15-bar scan window
   to handle weekends, holidays, and calendar drift.
4 — Averages all available (non-na) closes into a single Mass Pressure value.

On historical bars, this value is plotted as a colored line (gold when rising, blue when falling). On the last bar, the indicator generates a forward projection by computing Mass Pressure for every remaining weekday through December 31 and drawing it as a continuous line extending beyond the chart's current data. A label marks the final projected value at year-end.

The info table in the top-right corner shows each lookback term's resolved value, the bar count required to reach it, and whether it is active, unavailable, or beyond Pine Script's history limit. A forecast row displays the number of projected data points.


█ [b]HOW TO USE[/b]

The forward projection line is the primary output. It maps the dominant seasonal tendency for the rest of the year based on the composite behavior of the selected historical intervals. When the projection trends upward, historical precedent favors rising prices for that calendar period. When it trends downward, the seasonal composite points to weakness.

[b]Recommended timeframe: Weekly.[/b] On weekly charts, all six Gann lookback intervals (including the 60-year and 80-year terms) resolve within Pine Script's 10,000-bar history limit, giving you the complete formula as Gann intended. On daily charts, only the 10-year, 20-year, and 30-year terms will typically be available due to the bar limit. The indicator handles this gracefully and plots with whatever terms resolve, but fewer terms reduce the composite's reliability.

[b]Confluence with other timing methods:[/b] Brown notes that Mass Pressure maps seasonal trends under normal conditions and is not suited for precise timing. It is most powerful when used in confluence with independent timing methods (cycle analysis, planetary geometry, Gann time counts) to confirm or filter signals from those primary tools.

[b]Key inputs:[/b]
• [i]Lookback 1 through 6[/i]: The six year intervals. Defaults match Gann's original
   formula (10, 20, 30, 40, 60, 80). Adjustable for experimentation.
• [i]Min valid terms to plot[/i]: The minimum number of non-na lookback values required
   before the indicator will plot. Default is 2. Increase to 3 or 4 for higher
   confidence from more contributing terms.
• [i]Smoothing[/i]: Optional SMA smoothing applied to the historical Mass Pressure line.
   Default is 1 (no smoothing). Increase to reduce noise on volatile instruments.
• [i]Forecast line color[/i]: Separate color for the forward projection (default: gold
   with slight transparency to distinguish it from the historical plot).
• [i]Colors and line width[/i]: Customizable rising/falling/flat colors and line thickness.


█ [b]LIMITATIONS[/b]

[b]Pine Script 10,000-bar history cap.[/b] Pine enforces a maximum of 10,000 bars for any history-referencing operator. At approximately 252 trading days per year on daily charts, this caps effective lookback depth at roughly 39 years. The 40-year term is borderline, and the 60-year and 80-year terms will return na on daily timeframes. Switching to weekly charts (52 bars/year) brings the 80-year lookback down to approximately 4,160 bars, well within the limit.

[b]Insufficient chart data.[/b] The indicator will not appear on charts where the symbol lacks enough historical price data to satisfy the minimum number of lookback terms. Newer instruments (ETFs, crypto, recent IPOs) may have less than 10 years of data, in which case no terms resolve and nothing plots. The background shades red when available terms fall below the configured minimum. The info table always shows exactly which terms are active and which are not.

[b]Calendar-date matching is approximate.[/b] The scan window of ±15 bars around the target offset matches the nearest available trading day when the exact calendar date falls on a weekend or holiday. In rare cases at the boundary of long market closures, the matched date could be slightly offset from the true anniversary.

[b]Forward projection uses weekday estimates.[/b] The forecast line generates dates for Monday through Friday via Zeller's congruence. It does not account for market-specific holidays (e.g., Thanksgiving, exchange closures), so the projected point count may slightly exceed the actual number of remaining trading days.

[b]Seasonal trend, not timing.[/b] As Brown notes, this indicator maps seasonal tendencies under normal conditions. It does not predict exact turning points. Divergences between Mass Pressure direction and actual price often occur around major non-seasonal events. The Time Factor and independent timing tools should always take precedence for entry/exit decisions. Brown also observes that for some instruments (Soybeans is cited), the indicator may display an inverse relationship to actual market trends.


█ [b]NOTES[/b]

The formula and methodology are drawn directly from Constance Brown's [i]The 32nd Jewel: Gann Analysis, Part 2, Price and Time[/i] (Chapter VII, Section L). Brown provides worked examples for DJIA and Cotton, documents the six default lookback intervals, and includes critical caveats about data sufficiency, seasonal-year offsets, and the distinction between seasonal trend indication and precise timing.

The info table provides full transparency into the indicator's internal state. Red "OVER 10K" entries indicate that a lookback exceeds Pine's bar limit at the current timeframe. Red "n/a" entries indicate the chart does not have data going back that far. Green term counts confirm the indicator is computing with adequate data. The forecast row shows the number of forward-projected points through December 31.

Background shading on historical bars provides an additional visual cue: a faint yellow tint indicates computation with fewer than all six terms, and a faint red tint indicates the term count has fallen below the configured minimum threshold.


█ [b]THANKS[/b]

Constance Brown, for her meticulous documentation of Gann's methods in [i]The 32nd Jewel[/i]. Her treatment of the Mass Pressure Chart, including its strengths, limitations, and the critical warning about data sufficiency, made this implementation possible.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Ben, Gann Mass Pressure Chart v4
// Method: average of closes on the same calendar date 10, 20, 30, 40, 60, and 80 years ago
// Reference: Constance Brown, "The 32nd Jewel", Chapter VII, Section L
//
// v4 changes
// 1. Normalized mode (default). Each lookback year is rebased to its own first close of
//    the year, so every term is expressed as percent change since Jan 1 of that year.
//    Years are chained end to end: each new year starts where the previous year's
//    composite finished, so the line is continuous and its slope on any date is the
//    average percent move of the six lookback years on that date. The level is not
//    meaningful, only the direction and steepness.
//    Brown's raw average is dominated by the 10-year term (the 80-year term is two
//    orders of magnitude smaller), which flattens the line into the secular trend.
//    Rebasing gives all six terms equal weight and exposes the seasonal path.
//    "Raw average" mode reproduces Brown's literal formula.
// 2. All date lookups run against per-bar arrays instead of close[idx], so the
//    10,000-bar history cap no longer applies. All six terms resolve on daily charts
//    when the symbol has the history.
// 3. Forward forecast steps by one calendar week on weekly charts and one month on
//    monthly charts. v3 stepped one weekday per bar regardless of timeframe, which on
//    a weekly chart pushed the Dec 31 point out to 2028.

//@version=6
indicator("Gann Mass Pressure", overlay=false, precision=2, max_lines_count=500)

// ---- Inputs ----
i_lb1      = input.int(10, "Lookback 1 (years)", minval=1)
i_lb2      = input.int(20, "Lookback 2 (years)", minval=1)
i_lb3      = input.int(30, "Lookback 3 (years)", minval=1)
i_lb4      = input.int(40, "Lookback 4 (years)", minval=1)
i_lb5      = input.int(60, "Lookback 5 (years)", minval=1)
i_lb6      = input.int(80, "Lookback 6 (years)", minval=1)
i_mode     = input.string("Normalized (chained % path)", "Mode", options=["Normalized (chained % path)", "Raw average (Brown literal)"])
i_minTerms = input.int(2, "Min valid terms to plot", minval=1, maxval=6)
i_smooth   = input.int(1, "Smoothing (1 = none)", minval=1, maxval=50)
i_colUp    = input.color(color.new(#C9A84C, 0), "Color (rising)")
i_colDn    = input.color(color.new(#2E5EAA, 0), "Color (falling)")
i_colFlat  = input.color(color.gray, "Color (flat)")
i_colFwd   = input.color(color.new(#C9A84C, 30), "Forecast line color")
i_lineW    = input.int(2, "Line width", minval=1, maxval=4)
i_showTbl  = input.bool(false, "Show info table")

bool NORM = i_mode == "Normalized (chained % path)"

// ---- Per-bar history arrays ----
var array<int>   barM  = array.new_int(0)
var array<int>   barD  = array.new_int(0)
var array<float> barC  = array.new_float(0)
var array<int>   yrList  = array.new_int(0)   // calendar years present in the data
var array<int>   yrStart = array.new_int(0)   // array index of the first bar of each year

array.push(barM, month(time))
array.push(barD, dayofmonth(time))
array.push(barC, close)
int totalBars = array.size(barC)

// Register a new year at its first bar. The first year in the data is only registered
// if the data actually begins in January, otherwise its Jan 1 base would be wrong.
int ySize = array.size(yrList)
if (ySize == 0 and month(time) == 1) or (ySize > 0 and array.get(yrList, ySize - 1) != year(time))
    array.push(yrList, year(time))
    array.push(yrStart, totalBars - 1)

// ---- Date helpers ----
dayOfYear(int m, int d) =>
    int cum = m == 1 ? 0 : m == 2 ? 31 : m == 3 ? 59 : m == 4 ? 90 : m == 5 ? 120 : m == 6 ? 151 : m == 7 ? 181 : m == 8 ? 212 : m == 9 ? 243 : m == 10 ? 273 : m == 11 ? 304 : 334
    cum + d

daysInMonth(int m, int y) =>
    int r = 31
    if m == 4 or m == 6 or m == 9 or m == 11
        r := 30
    else if m == 2
        bool leap = (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)
        r := leap ? 29 : 28
    r

// Zeller: 0=Sat, 1=Sun, 2=Mon ... 6=Fri
zellerDow(int y, int m, int d) =>
    int adjY = m < 3 ? y - 1 : y
    int adjM = m < 3 ? m + 12 : m
    (d + math.floor((13 * (adjM + 1)) / 5) + adjY + math.floor(adjY / 4) - math.floor(adjY / 100) + math.floor(adjY / 400)) % 7

// ---- Lookup: close nearest to (y, m, d) within that year's bars ----
closeOnDate(int y, int m, int d) =>
    float best = na
    int yi = array.indexof(yrList, y)
    if yi >= 0
        int s = array.get(yrStart, yi)
        int e = yi + 1 < array.size(yrList) ? array.get(yrStart, yi + 1) - 1 : totalBars - 1
        int yearLen = e - s + 1
        int approx = s + math.round(yearLen * dayOfYear(m, d) / 365.0)
        int lo = math.max(s, approx - 10)
        int hi = math.min(e, approx + 10)
        int bestDist = 999
        if lo <= hi
            for i = lo to hi
                int dist = math.abs(array.get(barM, i) - m) * 31 + math.abs(array.get(barD, i) - d)
                if dist < bestDist
                    bestDist := dist
                    best     := array.get(barC, i)
    best

baseOfYear(int y) =>
    int yi = array.indexof(yrList, y)
    yi >= 0 ? array.get(barC, array.get(yrStart, yi)) : na

// One term: value of lookback year y on calendar date (m, d), in the selected mode
termValue(int y, int m, int d) =>
    float c = closeOnDate(y, m, d)
    float v = na
    if not na(c)
        if NORM
            float b = baseOfYear(y)
            v := b > 0 ? 100.0 * (c / b - 1.0) : na
        else
            v := c
    v

var array<int> lookbacks = array.from(i_lb1, i_lb2, i_lb3, i_lb4, i_lb5, i_lb6)

// Composite for calendar date (m, d) measured from reference year refY
composite(int refY, int m, int d) =>
    float s = 0.0
    int   c = 0
    for k = 0 to 5
        float v = termValue(refY - array.get(lookbacks, k), m, d)
        if not na(v)
            s += v
            c += 1
    [c >= i_minTerms ? s / c : na, c]

// ---- Historical plot ----
[avgPct, hCount] = composite(year(time), month(time), dayofmonth(time))

// Chain years so the normalized line never resets. yrOff is the composite value at the
// end of the previous year; the current year's percent path is added on top of it.
bool newYear = year(time) != year(time[1])
var float yrOff    = 0.0
var float lastGood = na
if NORM and newYear
    yrOff := nz(lastGood, yrOff)
float rawMP = NORM ? yrOff + avgPct : avgPct
if not na(rawMP)
    lastGood := rawMP

float smoothMP = ta.sma(rawMP, i_smooth)
float mp = i_smooth > 1 ? smoothMP : rawMP
color lineCol = mp > mp[1] ? i_colUp : mp < mp[1] ? i_colDn : i_colFlat

plot(mp, "Mass Pressure", color=lineCol, linewidth=i_lineW)

// ---- Forward forecast through Dec 31 ----
var array<line>  fwdLines = array.new<line>(0)
var label        fwdLabel = na
var int          fwdN     = 0

if barstate.islast
    // clear prior forecast on realtime recompute
    if array.size(fwdLines) > 0
        for i = 0 to array.size(fwdLines) - 1
            line.delete(array.get(fwdLines, i))
    array.clear(fwdLines)
    if not na(fwdLabel)
        label.delete(fwdLabel)

    int curY = year(time)
    int walkM = month(time)
    int walkD = dayofmonth(time)

    // step per bar in calendar days; 0 means advance one month
    int stepDays = timeframe.isweekly ? 7 : timeframe.ismonthly ? 0 : 1

    float prevVal = rawMP
    int   prevX   = bar_index
    int   n       = 0
    float lastVal = na
    int   lastM   = walkM
    int   lastD   = walkD

    bool done = false
    while not done and n < 490
        // advance the calendar
        if stepDays == 0
            walkM += 1
            if walkM <= 12
                walkD := math.min(walkD, daysInMonth(walkM, curY))
        else
            walkD += stepDays
            while walkM <= 12 and walkD > daysInMonth(walkM, curY)
                walkD -= daysInMonth(walkM, curY)
                walkM += 1
        if walkM > 12
            done := true
        else
            // daily charts skip weekends; weekly and monthly do not need to
            bool tradable = true
            if stepDays == 1
                int dow = zellerDow(curY, walkM, walkD)
                tradable := dow >= 2 and dow <= 6
            if tradable
                n += 1
                [pctVal, cnt] = composite(curY, walkM, walkD)
                float curVal = NORM ? yrOff + pctVal : pctVal
                int curX = bar_index + n
                if not na(prevVal) and not na(curVal)
                    array.push(fwdLines, line.new(prevX, prevVal, curX, curVal, color=i_colFwd, width=i_lineW))
                prevVal := curVal
                prevX   := curX
                if not na(curVal)
                    lastVal := curVal
                    lastM   := walkM
                    lastD   := walkD

    fwdN := n
    if not na(lastVal)
        float ytd = lastVal - yrOff
        string valTxt = NORM ? "YTD " + (ytd >= 0 ? "+" : "") + str.tostring(ytd, "#.##") + "%" : str.tostring(lastVal, "#.##")
        string txt = str.tostring(lastM) + "/" + str.tostring(lastD) + "\n" + valTxt
        fwdLabel := label.new(prevX, lastVal, txt, color=color.new(#0A1628, 50), textcolor=#C9A84C, style=label.style_label_left, size=size.small)

// ---- Info table ----
var table infoTbl = na
if barstate.islast and i_showTbl
    if na(infoTbl)
        infoTbl := table.new(position.top_right, 4, 9, bgcolor=color.new(#0A1628, 85), border_color=color.new(#C9A84C, 60), border_width=1)
    table.cell(infoTbl, 0, 0, "Lookback", text_color=#C9A84C, text_size=size.small)
    table.cell(infoTbl, 1, 0, "Year",     text_color=#C9A84C, text_size=size.small)
    table.cell(infoTbl, 2, 0, "Close",    text_color=#C9A84C, text_size=size.small)
    table.cell(infoTbl, 3, 0, "% YTD",    text_color=#C9A84C, text_size=size.small)
    int curYr = year(time)
    int curMo = month(time)
    int curDy = dayofmonth(time)
    for k = 0 to 5
        int lb = array.get(lookbacks, k)
        int y  = curYr - lb
        float c = closeOnDate(y, curMo, curDy)
        float b = baseOfYear(y)
        float pct = not na(c) and b > 0 ? 100.0 * (c / b - 1.0) : na
        color tc = na(c) ? color.red : color.white
        table.cell(infoTbl, 0, k + 1, str.tostring(lb) + "y", text_color=color.white, text_size=size.tiny)
        table.cell(infoTbl, 1, k + 1, str.tostring(y), text_color=tc, text_size=size.tiny)
        table.cell(infoTbl, 2, k + 1, na(c) ? "n/a" : str.tostring(c, "#.##"), text_color=tc, text_size=size.tiny)
        table.cell(infoTbl, 3, k + 1, na(pct) ? "n/a" : (pct >= 0 ? "+" : "") + str.tostring(pct, "#.#") + "%", text_color=tc, text_size=size.tiny)
    table.cell(infoTbl, 0, 7, "Terms", text_color=#C9A84C, text_size=size.small)
    table.cell(infoTbl, 1, 7, str.tostring(hCount) + "/6", text_color=hCount >= i_minTerms ? color.green : color.red, text_size=size.small)
    table.cell(infoTbl, 2, 7, hCount >= i_minTerms ? "OK" : "LOW", text_color=hCount >= i_minTerms ? color.green : color.red, text_size=size.small)
    table.cell(infoTbl, 3, 7, NORM ? "% mode" : "raw", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 0, 8, "Forecast", text_color=#C9A84C, text_size=size.small)
    table.cell(infoTbl, 1, 8, str.tostring(fwdN) + " pts", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 2, 8, "to Dec 31", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 3, 8, "", text_color=color.white, text_size=size.small)

// ---- Timeframe notice ----
// Pine cannot show a popup on add, so this draws a banner in the pane on any chart
// that is not weekly. It clears itself when the chart is switched to weekly.
var table tfNote = na
if barstate.islast and not timeframe.isweekly
    if na(tfNote)
        tfNote := table.new(position.middle_center, 1, 1, bgcolor=color.new(#0A1628, 20), border_color=#C9A84C, border_width=1)
    table.cell(tfNote, 0, 0, "Gann Mass Pressure: use this indicator on a WEEKLY chart", text_color=#C9A84C, text_size=size.large)

// ---- Background: warn when degraded ----
bgcolor(hCount > 0 and hCount < i_minTerms ? color.new(color.red, 95) : hCount >= i_minTerms and hCount < 6 ? color.new(color.yellow, 97) : na)
````
