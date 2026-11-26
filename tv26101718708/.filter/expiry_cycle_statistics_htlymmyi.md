# Expiry Cycle Statistics

- url: https://www.tradingview.com/script/HtLYmMyI-Expiry-Cycle-Statistics/
- type: indicator
- pine_id: PUB;fe01a2d974994d8c9d3e9409f166807e
- version: 2.0

## Description

[b]Expiry Cycle Statistics[/b]

[b]OVERVIEW[/b]
This script measures how NIFTY and SENSEX have historically behaved at each stage of their weekly options expiry cycle. Every completed trading day is grouped by its number of trading days to the next weekly expiry (DTE 0 to 4), and the results are summarised in a table. Optional lines show the historical percentile levels for the current day around the previous close.

The script answers questions such as:
- How large is the typical daily range on an expiry day compared with two or three days before expiry?
- From the start of a given DTE day, how far has the index usually been from the previous close by the expiry-day close?
- How far has it usually swung, above or below the previous close, before that expiry?

[b]HOW IT WORKS[/b][b][/b]
1. Index detection
The script detects whether the chart shows NIFTY or SENSEX (index or continuous futures) and applies that index's weekly expiry schedule. On any other symbol it shows a message asking to open a NIFTY or SENSEX chart and draws nothing.

2. Expiry schedule
The weekday on which weekly contracts expired has changed over time. The following history is built in:
- NIFTY: Thursday (weekly options from 11 Feb 2019), Tuesday from 1 Sep 2025.
- SENSEX: Friday (weekly contracts from 15 May 2023), Tuesday from 1 Jan 2025, Thursday from 1 Sep 2025.
Days before weekly options existed for the index are excluded from the statistics.

3. Finding past expiry days
Past expiry days are identified from the price data itself. For each calendar week, the expiry is the last trading day on or before the scheduled weekday. Expiries that were moved earlier because of an exchange holiday are therefore placed on the correct day without needing a historical holiday list.

4. Measuring each day
For every completed day, the script records its trading days to the next expiry (DTE) and calculates:
- Day range: (high − low) ÷ previous close
- Close-to-close change: close ÷ previous close − 1
- Move to expiry: the absolute change from the previous close to the expiry-day close
- Maximum swing: the largest distance from the previous close reached by any high or low from that day up to and including the expiry day

5. Today
During market hours the current day's DTE row is highlighted. Outside market hours, from midnight IST, the script shows the next trading session's DTE and uses the last close as the reference. Upcoming exchange holidays can be entered so that the current DTE is correct in holiday weeks.

All values use completed daily bars only, so historical results do not repaint.

[b]TABLE COLUMNS[/b]
- DTE: trading days to the next weekly expiry (0 = expiry day)
- Days: number of days in the sample for that DTE
- Avg range: average day range as a % of the previous close
- Avg |chg|: average absolute close-to-close change
- Up close: share of days that closed above the previous close
- |chg| ≥ X%: share of days whose absolute change was at least the chosen threshold
- Pxx to expiry: chosen percentile of the absolute move from the previous close to the expiry-day close
- Pxx max swing: chosen percentile of the maximum swing before the expiry close

The row below the table compares today's range so far with the average for today's DTE, and converts the percentile move to expiry into index points from the previous close.

[b]CHART LINES (OPTIONAL)[/b]
- Dotted line: the reference close (previous close, or the last close outside market hours)
- Solid lines: reference ± the percentile move to expiry for the current DTE
- Dashed lines: reference ± the percentile maximum swing for the current DTE

[b]SETTINGS[/b]
- Upcoming exchange holidays (YYYY-MM-DD, comma separated). Only used for the current DTE.
- Look-back in years
- Percentile (50, 70, 80, 90 or 95)
- Threshold for the "|chg| ≥ X%" column
- Show or hide the chart lines and the max-swing lines, and how far they extend to the right
- All colours, line widths, label sizes, table position and text size

[b]HOW TO USE[/b]
- Use the Daily timeframe for the longest and most reliable sample. On intraday timeframes the sample is limited to the history loaded on the chart.
- Check the "Days" column. Small samples, such as SENSEX in its early history or DTE rows affected by holiday weeks, are less reliable.
- Changing the look-back period shows how behaviour differs across market conditions.

[b]LIMITATIONS[/b]
- Statistics describe past behaviour only. Market conditions, volatility regimes and exchange rules change, and past distributions may not repeat.
- Percentiles are calculated from a limited number of expiries and should be read as approximate.
- The weekly expiry schedule is built into the script. If an exchange changes its expiry day again, the script will need an update.
- Index data may differ slightly between data sources.

[b]DISCLAIMER[/b]
This script is published for educational and informational purposes only. It does not provide trading or investment advice, recommendations or signals to buy or sell any security, futures or options contract. Past performance and historical statistics do not guarantee future results. Trading in derivatives involves substantial risk of loss. Users are solely responsible for their own trading decisions and should consult a qualified financial adviser where appropriate.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Expiry Cycle Statistics", shorttitle = "Expiry Stats", overlay = true, max_lines_count = 20, max_labels_count = 20)

// ─────────────────────────────────────────────────────────────────────────────
// WHAT IT DOES
// Groups every past trading day by its trading days to the next weekly expiry (DTE 0–4)
// and shows how the index has actually behaved at each stage of the expiry cycle:
//   • average day range and average close-to-close change
//   • share of up-closes and of "big" days (|change| above a threshold)
//   • percentile of the move from the previous close to the expiry close
//   • percentile of the largest swing (high or low) reached before expiry
// Expiry days are found from the data itself (the last trading day on or before the
// scheduled weekday), so past holiday-shifted expiries are handled automatically.
// Works on NIFTY and SENSEX (index or continuous futures) and switches automatically.
// Built-in weekly expiry history:
//   NIFTY : Thursday (weekly options from 11 Feb 2019) → Tuesday from 1 Sep 2025
//   SENSEX: Friday (weekly relaunch 15 May 2023) → Tuesday from 1 Jan 2025 → Thursday from 1 Sep 2025
// Historical statistics only — not a forecast and not a trade recommendation.
// ─────────────────────────────────────────────────────────────────────────────

tz  = "Asia/Kolkata"
DAY = 86400000

// ── Inputs ── (display.none keeps input values out of the chart's status line)
grpE   = "Expiry schedule"
holStr = input.string("", "Upcoming exchange holidays (YYYY-MM-DD, comma separated)", group = grpE, tooltip = "Only needed for today's DTE. Past holidays are detected from the data.", display = display.none)

grpS   = "Statistics"
yrs    = input.int(3, "Look-back (years)", minval = 1, maxval = 15, group = grpS, tooltip = "Use the Daily timeframe for the longest history. On intraday charts the sample is limited to the loaded intraday bars.", display = display.none)
pctl   = input.int(80, "Percentile", options = [50, 70, 80, 90, 95], group = grpS, display = display.none)
bigTh  = input.float(1.0, "Big day if |change| ≥ (%)", step = 0.1, minval = 0.1, group = grpS, display = display.none)

grpB   = "Chart bands (today)"
showB  = input.bool(true, "Show percentile bands for today", group = grpB, display = display.none)
showSw = input.bool(true, "Also show max-swing bands", group = grpB, display = display.none)
extB   = input.int(20, "Extend bands right (bars)", minval = 0, maxval = 200, group = grpB, display = display.none)
cBand  = input.color(#42A5F5, "Expiry-close band", group = grpB, inline = "b1", display = display.none)
wBand  = input.int(2, "width", minval = 1, maxval = 4, group = grpB, inline = "b1", display = display.none)
cSw    = input.color(#FF9800, "Max-swing band", group = grpB, inline = "b2", display = display.none)
wSw    = input.int(1, "width", minval = 1, maxval = 4, group = grpB, inline = "b2", display = display.none)
cRef   = input.color(color.new(#9E9E9E, 30), "Reference (prev close)", group = grpB, display = display.none)
lblSz  = input.string("Small", "Band label size", options = ["Tiny", "Small", "Normal", "Large"], group = grpB, display = display.none)
cLblTx = input.color(#FFFFFF, "Band label text", group = grpB, display = display.none)

grpT    = "Table"
showTbl = input.bool(true, "Show table", group = grpT, display = display.none)
tblPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpT, display = display.none)
tblSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpT, display = display.none)
cTBg    = input.color(color.new(#131722, 5), "Background", group = grpT, inline = "t1", display = display.none)
cTHdBg  = input.color(color.new(#1E222D, 0), "Header bg", group = grpT, inline = "t1", display = display.none)
cTHdTx  = input.color(#FFFFFF, "Header text", group = grpT, inline = "t2", display = display.none)
cTKey   = input.color(#A3A6AF, "Label text", group = grpT, inline = "t2", display = display.none)
cTVal   = input.color(#D1D4DC, "Value text", group = grpT, inline = "t3", display = display.none)
cTNow   = input.color(color.new(#42A5F5, 75), "Today's row bg", group = grpT, inline = "t3", display = display.none)
cTUp    = input.color(#4ADE80, "Up text", group = grpT, inline = "t5", display = display.none)
cTDn    = input.color(#FF6B6B, "Down / big text", group = grpT, inline = "t5", display = display.none)
cTFrame = input.color(color.new(#787B86, 70), "Frame", group = grpT, inline = "t4", display = display.none)
cTGrid  = input.color(color.new(#787B86, 85), "Grid lines", group = grpT, inline = "t4", display = display.none)

// ── Helpers ──
f_size(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large
f_dayStart(int t) => timestamp(tz, year(t, tz), month(t, tz), dayofmonth(t, tz), 0, 0)
f_parseHol(string s) =>
    arr = array.new<string>()
    for p in str.split(s, ",")
        t = str.trim(p)
        if str.length(t) == 10
            array.push(arr, t)
    arr
f_isTrading(int t, array<string> hol) =>
    dw = dayofweek(t, tz)
    dw != dayofweek.saturday and dw != dayofweek.sunday and not array.includes(hol, str.format_time(t, "yyyy-MM-dd", tz))
f_prevTrading(int t, array<string> hol) =>
    tt = t
    for i = 0 to 10
        if f_isTrading(tt, hol)
            break
        tt -= DAY
    tt
f_nextTrading(int t, array<string> hol) =>
    tt = t
    for i = 0 to 10
        if f_isTrading(tt, hol)
            break
        tt += DAY
    tt
f_weekly(int sess, int wd, array<string> hol) =>
    int exp = na
    for k = 0 to 3
        t = sess + k * 7 * DAY
        for d = 0 to 6
            if dayofweek(t, tz) == wd
                break
            t += DAY
        e = f_prevTrading(t, hol)
        if e >= sess
            exp := e
            break
    exp
f_tradingDte(int sess, int exp, array<string> hol) =>
    n = 0
    if not na(exp)
        t = sess + DAY
        for i = 0 to 60
            if t > exp
                break
            n += f_isTrading(t, hol) ? 1 : 0
            t += DAY
    n
f_pct(float v) => na(v) ? "—" : str.tostring(v, "0.00") + "%"

hol   = f_parseHol(holStr)

// ── Index detection & built-in expiry schedule ──
tick     = syminfo.ticker
isNifty  = tick == "NIFTY" or tick == "NIFTY1!" or tick == "NIFTY2!"
isSensex = tick == "SENSEX" or tick == "SENSEX1!" or tick == "SENSEX2!" or tick == "BSX1!"
okSym    = isNifty or isSensex
idxName  = isNifty ? "NIFTY" : isSensex ? "SENSEX" : ""
T_N0  = timestamp(tz, 2019, 2, 11, 0, 0)
T_S0  = timestamp(tz, 2023, 5, 15, 0, 0)
T_S1  = timestamp(tz, 2025, 1, 1, 0, 0)
T_SEP = timestamp(tz, 2025, 9, 1, 0, 0)
// weekly expiry weekday in force on a given day (na = no weekly expiry then)
f_wdAt(int ds) =>
    int w = na
    if isNifty
        w := ds < T_N0 ? na : ds < T_SEP ? dayofweek.thursday : dayofweek.tuesday
    else if isSensex
        w := ds < T_S0 ? na : ds < T_S1 ? dayofweek.friday : ds < T_SEP ? dayofweek.tuesday : dayofweek.thursday
    w
eraStart = isNifty ? T_N0 : T_S0

// ── Completed daily bars (previous days only → no repainting) ──
[dT, dH, dL, dC] = request.security(syminfo.tickerid, "D", [time[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[tH, tL, tC]     = request.security(syminfo.tickerid, "D", [high, low, close], lookahead = barmerge.lookahead_on)

var array<int>   aT = array.new<int>()
var array<float> aH = array.new<float>()
var array<float> aL = array.new<float>()
var array<float> aC = array.new<float>()
if not na(dT) and not na(dC) and (array.size(aT) == 0 or dT > array.last(aT))
    array.push(aT, dT)
    array.push(aH, dH)
    array.push(aL, dL)
    array.push(aC, dC)

// ── Results per DTE (0–4) ──
var array<int>   rCnt  = array.new<int>(5, 0)
var array<float> rRng  = array.new<float>(5, na)
var array<float> rCC   = array.new<float>(5, na)
var array<float> rUp   = array.new<float>(5, na)
var array<float> rBig  = array.new<float>(5, na)
var array<float> rToE  = array.new<float>(5, na)
var array<float> rSw   = array.new<float>(5, na)
var int   nExp    = 0
var int   sampleT = na
var int   lastN   = 0

if okSym and barstate.islast and array.size(aT) > 30 and array.size(aT) != lastN
    lastN := array.size(aT)
    n = array.size(aT)
    tEnd = array.get(aT, n - 1)
    s0 = 1
    for i = 1 to n - 1
        if array.get(aT, i) >= math.max(tEnd - yrs * 365 * DAY, eraStart)
            s0 := i
            break
    sampleT := array.get(aT, s0)

    // 1) find actual expiry days: last trading day of each week on or before the scheduled weekday
    exps = array.new<int>()
    int curWk = na
    int cand = na
    for i = s0 to n - 1
        t  = array.get(aT, i)
        ds = f_dayStart(t)
        dw = dayofweek(t, tz)
        wk = ds - ((dw + 5) % 7) * DAY
        wd = f_wdAt(ds)
        if na(curWk) or wk != curWk
            if not na(cand)
                array.push(exps, cand)
            curWk := wk
            cand := na
        if not na(wd) and dw <= wd
            cand := i
    if not na(cand)
        dsl  = f_dayStart(array.get(aT, n - 1))
        wdl  = f_wdAt(dsl)
        sched = curWk + (nz(wdl, 2) - 2) * DAY
        if not na(wdl) and f_prevTrading(sched, hol) <= dsl
            array.push(exps, cand)
    nExp := array.size(exps)

    // 2) measure every day by its trading days to the next expiry
    dteA = array.new<int>()
    rngA = array.new<float>()
    ccA  = array.new<float>()
    toA  = array.new<float>()
    swA  = array.new<float>()
    if nExp > 0
        p = 0
        for i = s0 to n - 1
            while p < nExp and array.get(exps, p) < i
                p += 1
            if p >= nExp
                break
            e = array.get(exps, p)
            k = e - i
            if k <= 4
                pc = array.get(aC, i - 1)
                array.push(dteA, k)
                array.push(rngA, (array.get(aH, i) - array.get(aL, i)) / pc * 100)
                array.push(ccA, (array.get(aC, i) / pc - 1) * 100)
                array.push(toA, math.abs(array.get(aC, e) / pc - 1) * 100)
                mx = 0.0
                for j = i to e
                    mx := math.max(mx, math.max(array.get(aH, j) / pc - 1, 1 - array.get(aL, j) / pc) * 100)
                array.push(swA, mx)

    // 3) aggregate per DTE
    m = array.size(dteA)
    for k = 0 to 4
        cnt = 0
        up = 0
        big = 0
        sR = 0.0
        sC = 0.0
        tArr = array.new<float>()
        wArr = array.new<float>()
        if m > 0
            for q = 0 to m - 1
                if array.get(dteA, q) == k
                    c = array.get(ccA, q)
                    cnt += 1
                    up += c > 0 ? 1 : 0
                    big += math.abs(c) >= bigTh ? 1 : 0
                    sR += array.get(rngA, q)
                    sC += math.abs(c)
                    array.push(tArr, array.get(toA, q))
                    array.push(wArr, array.get(swA, q))
        array.set(rCnt, k, cnt)
        array.set(rRng, k, cnt > 0 ? sR / cnt : na)
        array.set(rCC,  k, cnt > 0 ? sC / cnt : na)
        array.set(rUp,  k, cnt > 0 ? 100.0 * up / cnt : na)
        array.set(rBig, k, cnt > 0 ? 100.0 * big / cnt : na)
        array.set(rToE, k, cnt > 0 ? array.percentile_nearest_rank(tArr, pctl) : na)
        array.set(rSw,  k, cnt > 0 ? array.percentile_nearest_rank(wArr, pctl) : na)

// ── Today ──
// After the last session's date has passed (from midnight IST), switch to the next session
lastDay   = f_dayStart(time)
nowDay    = f_dayStart(timenow)
// Only switch to the next session when the last bar is recent. In Bar Replay (or when scrolled to an old
// point) the last bar is old, so the script treats that bar's own date as "today".
preOpen   = nowDay > lastDay and (timenow - time) < 6 * 86400000
todaySess = preOpen ? f_nextTrading(nowDay, hol) : lastDay
wdToday   = nz(f_wdAt(todaySess), dayofweek.tuesday)
expToday  = okSym ? f_weekly(todaySess, wdToday, hol) : na
dteToday  = f_tradingDte(todaySess, expToday, hol)
kT        = math.min(dteToday, 4)
prevC     = preOpen ? tC : array.size(aC) > 0 ? array.last(aC) : na

dChg   = ta.change(time("D"))
newDay = timeframe.isintraday ? dChg != 0 : true
var int dayBar = na
if newDay
    dayBar := bar_index

// ── Bands ──
var array<line>  bl = array.new<line>()
var array<label> bt = array.new<label>()
f_band(float y, color c, int w, string st, string txt) =>
    array.push(bl, line.new(preOpen ? bar_index : dayBar, y, bar_index + extB, y, color = c, width = w, style = st))
    if txt != ""
        array.push(bt, label.new(bar_index + extB, y, txt, style = label.style_label_left, size = f_size(lblSz), color = color.new(c, 15), textcolor = cLblTx))

if barstate.islast
    for l in bl
        line.delete(l)
    for l in bt
        label.delete(l)
    array.clear(bl)
    array.clear(bt)
    pT = array.get(rToE, kT)
    pS = array.get(rSw, kT)
    if okSym and showB and not na(prevC) and not na(pT)
        tag = "P" + str.tostring(pctl) + " DTE " + str.tostring(kT)
        f_band(prevC, cRef, 1, line.style_dotted, "")
        f_band(prevC * (1 + pT / 100), cBand, wBand, line.style_solid, tag + " expiry close +" + str.tostring(pT, "0.00") + "%")
        f_band(prevC * (1 - pT / 100), cBand, wBand, line.style_solid, tag + " expiry close −" + str.tostring(pT, "0.00") + "%")
        if showSw and not na(pS)
            f_band(prevC * (1 + pS / 100), cSw, wSw, line.style_dashed, tag + " max swing +" + str.tostring(pS, "0.00") + "%")
            f_band(prevC * (1 - pS / 100), cSw, wSw, line.style_dashed, tag + " max swing −" + str.tostring(pS, "0.00") + "%")

// ── Table ──
pos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : position.bottom_left
tsz = f_size(tblSize)
var table tb = table.new(pos, 8, 14, border_width = 1, frame_width = 1, frame_color = cTFrame, border_color = cTGrid)

f_cell(int c, int r, string s, color tc, color bg) =>
    table.cell(tb, c, r, s, text_color = tc, bgcolor = bg, text_size = tsz)

if barstate.islast and showTbl
    table.clear(tb, 0, 0, 7, 13)
    table.cell(tb, 0, 0, "EXPIRY CYCLE STATISTICS · " + (okSym ? idxName : syminfo.ticker), text_color = cTHdTx, bgcolor = cTHdBg, text_size = tsz, text_halign = text.align_left)
    table.merge_cells(tb, 0, 0, 7, 0)
if barstate.islast and showTbl and not okSym
    table.cell(tb, 0, 1, "Open a NIFTY or SENSEX chart to use this indicator.", text_color = cTVal, bgcolor = cTBg, text_size = tsz, text_halign = text.align_left)
    table.merge_cells(tb, 0, 1, 7, 1)
if barstate.islast and showTbl and okSym
    nextTxt = na(expToday) ? "—" : str.format_time(expToday, "dd MMM yyyy (EEE)", tz)
    table.cell(tb, 0, 1, "Next expiry: " + nextTxt + (preOpen ? "  ·  Next session is DTE " : "  ·  Today is DTE ") + str.tostring(dteToday) + (dteToday == 0 ? " (expiry day)" : ""), text_color = cTVal, bgcolor = cTBg, text_size = tsz, text_halign = text.align_left)
    table.merge_cells(tb, 0, 1, 7, 1)
    table.cell(tb, 0, 2, "Sample: since " + (na(sampleT) ? "—" : str.format_time(sampleT, "dd MMM yyyy", tz)) + "  ·  " + str.tostring(nExp) + " expiries", text_color = cTKey, bgcolor = cTBg, text_size = tsz, text_halign = text.align_left)
    table.merge_cells(tb, 0, 2, 7, 2)
    hdr = array.from("DTE", "Days", "Avg range", "Avg |chg|", "Up close", "|chg| ≥ " + str.tostring(bigTh, "0.0") + "%", "P" + str.tostring(pctl) + " to expiry", "P" + str.tostring(pctl) + " max swing")
    for c = 0 to 7
        f_cell(c, 3, array.get(hdr, c), cTKey, cTHdBg)
    for k = 4 to 0
        r = 4 + (4 - k)
        isNow = k == kT
        bg = isNow ? cTNow : cTBg
        up = array.get(rUp, k)
        f_cell(0, r, str.tostring(k) + (k == 0 ? " (expiry)" : ""), isNow ? cTHdTx : cTVal, bg)
        f_cell(1, r, str.tostring(array.get(rCnt, k)), cTVal, bg)
        f_cell(2, r, f_pct(array.get(rRng, k)), cTVal, bg)
        f_cell(3, r, f_pct(array.get(rCC, k)), cTVal, bg)
        f_cell(4, r, na(up) ? "—" : str.tostring(up, "0") + "%", na(up) ? cTVal : up >= 50 ? cTUp : cTDn, bg)
        f_cell(5, r, na(array.get(rBig, k)) ? "—" : str.tostring(array.get(rBig, k), "0") + "%", cTDn, bg)
        f_cell(6, r, "±" + f_pct(array.get(rToE, k)), cTVal, bg)
        f_cell(7, r, "±" + f_pct(array.get(rSw, k)), cTVal, bg)
    if preOpen and not na(prevC)
        pT0 = array.get(rToE, kT)
        txt0 = "Next session " + str.format_time(todaySess, "dd MMM (EEE)", tz) + " · reference = last close " + str.tostring(prevC, "#,##0.00")
        if not na(pT0)
            txt0 += "  ·  P" + str.tostring(pctl) + " to expiry ≈ ±" + str.tostring(prevC * pT0 / 100, "#,##0") + " pts"
        table.cell(tb, 0, 9, txt0, text_color = cTVal, bgcolor = cTBg, text_size = tsz, text_halign = text.align_left)
        table.merge_cells(tb, 0, 9, 7, 9)
    else if not na(prevC)
        todayRng = (tH - tL) / prevC * 100
        avgR = array.get(rRng, kT)
        pT = array.get(rToE, kT)
        txt = "Today's range so far " + f_pct(todayRng) + " vs DTE " + str.tostring(kT) + " average " + f_pct(avgR)
        if not na(pT)
            txt += "  ·  P" + str.tostring(pctl) + " to expiry ≈ ±" + str.tostring(prevC * pT / 100, "#,##0") + " pts from prev close"
        table.cell(tb, 0, 9, txt, text_color = cTVal, bgcolor = cTBg, text_size = tsz, text_halign = text.align_left)
        table.merge_cells(tb, 0, 9, 7, 9)
    table.cell(tb, 0, 10, "Moves measured from the previous close. Historical statistics, not a forecast.", text_color = cTKey, bgcolor = cTBg, text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(tb, 0, 10, 7, 10)
````
