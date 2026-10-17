# Best of N Lengths vs Shuffled Data: Is the Optimum Real?

- url: https://www.tradingview.com/script/9i6KR53K-Best-of-N-Lengths-vs-Shuffled-Data-Is-the-Optimum-Real/
- type: indicator
- pine_id: PUB;c47af63128cf4e789c79a2650689201c
- version: 1.0

## Description

WHAT IT DOES
Scan a moving-average rule over several lengths and one of them comes out on top. This indicator asks whether that top length found something in the order of the bars or is just the luckiest of N tries. It scores one rule, long when the close is above SMA(L) and flat otherwise, for N lengths (10 lengths from 10 to 100 by default) on the last M confirmed bars (1,500 by default). Then it scores the same N lengths on K shuffled copies of the same bar returns (30 by default) and compares the real best with the best of each shuffle. The table shows the best real length, the spread of the shuffled bests, a p-value and a verdict.

WHAT IS ORIGINAL HERE
Parameter heatmaps and optimizers show which length did best; they do not show how good the best of N looks when there is nothing to find. A shuffle keeps every return, so the volatility, the fat tails and the buy-and-hold result stay the same, but it destroys the order the rule trades on: trends, momentum, regimes. If the real best sits among the shuffled bests, the scan found what any reordering of these returns produces. The real returns and every shuffle go through one scoring function, so the null is computed exactly like the result it is compared with. Buy-and-hold is the same on every shuffle because a permutation keeps the sum of the log returns: every shuffled path starts and ends at the same price, only the path between differs.

HOW IT IS MEASURED
- Data: one log return per confirmed bar, log(close / close[1]). The last M are scored; the 99 before them (longest length minus one) let every average start on the first scored bar.
- Rule: the position decided at a bar's close earns the next bar's return. The score of a length is its total log return over the M bars, shown as a percent.
- Shuffles: a seeded Fisher-Yates shuffle reorders the M scored returns and leaves the warm-up in place; seed 7 by default.
- p = (1 + shuffles whose best >= the real best) / (1 + K).
- Verdict: "beats shuffled data" at p <= 0.05, "within what shuffled data produces" above 0.10, "borderline" between.
- The test runs once, on the last confirmed historical bar. No request.security call, no future data.

HOW TO USE IT
1. Set the lengths and the bars you would optimize over; keep K at 30 or more.
2. Read the p-value row first, then compare the real best with the shuffled 90th percentile and maximum.
3. The long/short toggle doubles the bet on the same signal: the best length, p and the verdict stay the same, only the rule's returns change.
4. If TradingView stops the script with a loop time error ("Loop is too long"), lower Shuffles K first, then Scored bars M.

HOW TO READ THE TABLE
Header: symbol, timeframe, rule, lengths, M, K and seed.
Data window: first and last scored bar.
Real data: best length, its total return, median of the N lengths.
Shuffled bests: median, 90th percentile and maximum of the K shuffled bests.
p-value: p and how many shuffles reached the real best.
Lengths above shuffled 90th: real lengths that beat the shuffled 90th percentile.
Buy and hold: total return over the scored bars, the same on every shuffle.
Verdict: one of the three readings above, or why the test did not run.

LIMITATIONS
- One rule family and one score, total log return: no costs, no slippage, no sizing.
- A shuffle removes every kind of order at once; the test says the order mattered, not which order, and not that it will last.
- With K = 30, p cannot go below 1/31 and one shuffle moves it by 0.032. On returns with no order information it reads "beats" about 1 time in 31.
- Bars that close after the chart loads are added on the next reload.
- Only the last M + longest length bars are used, so history depth, symbol and timeframe change the result. Counts, not a trading rule. Not financial advice.

The chart shows SPY on the 1D timeframe with the default settings. The table is in the bottom right.

## Source Code

````pine
//@version=6
indicator("Best of N Lengths vs Shuffled Data: Is the Optimum Real?", shorttitle = "BEST-OF-N-SHUFFLED", overlay = true, behind_chart = false)

// Best of N Lengths vs Shuffled Data
// 1) On every confirmed bar, stores the bar's log return, log(close / close[1]), in a rolling window of the last
//    M + Lmax - 1 returns: Lmax - 1 warm-up returns, so the longest average exists at the first scored bar, and
//    the M scored returns.
// 2) Scores one rule for N lengths from Lmin to Lmax: long when close > SMA(L), flat otherwise (short otherwise
//    with the long/short toggle). The position decided at a bar's close is applied to the next bar's log return,
//    and the score of a length is the total log return over the M scored bars. The prices are rebuilt from the
//    returns, so the same function can score any order of them.
// 3) Runs that same function on K shuffled copies of the returns. A seeded Fisher-Yates shuffle moves the M
//    scored returns only: every copy has the same returns, the same buy-and-hold and the same warm-up, in another
//    order. The best score of each copy is what the best of N looks like when the order carries no information.
// 4) Everything runs once, on the last confirmed historical bar, and the results are kept: the table shows the
//    best real length, the shuffled bests, p = (1 + shuffles whose best >= the real best) / (1 + K) and a verdict.
// The result is a permutation test on this chart's bars, not a trading rule.

// ───────────────────────── Inputs ─────────────────────────
lMin = input.int(10, "Shortest length", minval = 2, maxval = 499, group = "Lengths", tooltip = "Shortest SMA length scanned. The N lengths are spread evenly from this one to the longest one and rounded to whole bars.")
lMax = input.int(100, "Longest length", minval = 3, maxval = 500, group = "Lengths", tooltip = "Longest SMA length scanned. Longest minus shortest must be at least N - 1, so no length repeats. The window also holds this many bars minus one before the scored bars, so every average exists at the first scored bar.")
nLen = input.int(10, "Number of lengths N", minval = 2, maxval = 20, group = "Lengths", tooltip = "How many lengths are scanned. The best of them is the one tested; more lengths make the best of N higher on shuffled data too.")

longShort = input.bool(false, "Long/short (short when not above)", group = "Rule", tooltip = "Off: long when close > SMA, flat otherwise. On: long when close > SMA, short otherwise. The short side doubles the bet on the same signal: the best length, p and the verdict stay the same, the returns change.")

mBars = input.int(1500, "Scored bars M", minval = 200, maxval = 3000, group = "Data", tooltip = "The rule is scored on the last M confirmed bars. The chart needs M + longest length bars in a row with a positive close.")

nShuf = input.int(30, "Shuffles K", minval = 20, maxval = 100, group = "Shuffles", tooltip = "How many shuffled copies of the returns are scored. p can go down to 1 / (K + 1). The work grows with (K + 1) x N x M and is capped at 1,000,000; if TradingView stops the script with a loop time error ('Loop is too long'), lower K first, then M.")
seed = input.int(7, "Seed", minval = 0, maxval = 2147483647, group = "Shuffles", tooltip = "Seed of the generator that shuffles the returns. The same seed on the same bars gives the same shuffles and the same p.")

tablePos = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display")
textSize = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], group = "Display")

// ───────────────────────── Settings checks ─────────────────────────
// All the work runs on one bar. Pine limits every loop on a bar to 500 ms, and the shuffles run inside one outer
// loop: about 560,000 loop iterations at the defaults; (K + 1) x N x M = 465,000 is the proxy the cap uses.
int warm = lMax - 1
int need = mBars + warm
int steps = (nShuf + 1) * nLen * mBars

// The N lengths, evenly spaced and rounded half up; built once.
var array<int> lens = array.new<int>()
if barstate.isfirst
    if lMax - lMin < nLen - 1
        runtime.error("Longest length minus shortest length is " + str.tostring(lMax - lMin) + "; it must be at least N - 1 = " + str.tostring(nLen - 1) + " so that no length repeats. Raise the longest length or lower N.")
    if steps > 1000000
        runtime.error("(K + 1) x N x M = " + str.tostring(steps, "#,##0") + " steps, above the cap of 1,000,000. The cap limits the work; Pine's own loop time limit still applies. Lower Shuffles K, Scored bars M or N.")
    for j = 0 to nLen - 1
        array.push(lens, lMin + int(math.floor(float(j * (lMax - lMin)) / (nLen - 1) + 0.5)))

// ───────────────────────── Data ─────────────────────────
// One log return per confirmed bar, oldest first, with the bar's open time; the window keeps the last `need`.
// A non-positive close has no log return, so it clears the window and the collection starts again after it.
float prevClose = close[1]
var array<float> rets = array.new<float>()
var array<int> retTime = array.new<int>()

if barstate.isconfirmed and not na(prevClose)
    if close > 0 and prevClose > 0
        array.push(rets, math.log(close / prevClose))
        array.push(retTime, time)
        if array.size(rets) > need
            array.shift(rets)
            array.shift(retTime)
    else
        array.clear(rets)
        array.clear(retTime)

// ───────────────────────── Scoring ─────────────────────────
// Next state of the linear congruential generator state = (1103515245 * state + 12345) % 2^31. The product is
// taken in two parts that each stay below 2^53, so it is exact in a 64-bit int or a float:
// 1103515245 = 16838 * 65536 + 20077. A uniform in [0, 1) is state / 2^31.
nextState(int state) =>
    int hi = (16838 * state) % 32768
    (hi * 65536 + 20077 * state + 12345) % 2147483648

// The one scoring function, for the real returns and for every shuffle. retsIn holds w warm-up returns and then
// m scored ones. Prices are rebuilt from them with a base of 1.0: price i + 1 = exp(sum of returns 0 .. i); the
// rule compares a price with an average of prices, so the scale does not matter. For each length: the running
// sum of the last `ln` prices is the SMA times ln; the position decided at price i (long when price * ln > sum,
// else flat, or short when longShortIn is on) earns return i, the move from price i to price i + 1. Fills
// scoresOut with one total log return per length and returns the largest.
scoreAll(array<float> retsIn, array<float> pxBuf, array<int> lensIn, array<float> scoresOut, int w, int m, bool longShortIn) =>
    float lp = 0.0
    array.set(pxBuf, 0, 1.0)
    for i = 0 to w + m - 1
        lp += array.get(retsIn, i)
        array.set(pxBuf, i + 1, math.exp(lp))
    float best = na
    for j = 0 to array.size(lensIn) - 1
        int ln = array.get(lensIn, j)
        float runSum = 0.0
        for k = w - ln + 1 to w
            runSum += array.get(pxBuf, k)
        float total = 0.0
        float pNow = array.get(pxBuf, w)
        for t = w to w + m - 1
            float pNext = array.get(pxBuf, t + 1)
            float rt = array.get(retsIn, t)
            if pNow * ln > runSum
                total += rt
            else if longShortIn
                total -= rt
            runSum += pNext - array.get(pxBuf, t - ln + 1)
            pNow := pNext
        array.set(scoresOut, j, total)
        if na(best) or total > best
            best := total
    best

// Median of an array: the middle value of a sorted copy, or the mean of the two middle values.
medianOf(array<float> src) =>
    array<float> v = array.copy(src)
    array.sort(v, order.ascending)
    int n = array.size(v)
    int h = int(n / 2)
    n % 2 == 1 ? array.get(v, h) : (array.get(v, h - 1) + array.get(v, h)) / 2

// 90th percentile by nearest rank: the ceil(0.9 * n)-th smallest value, rank (9 * n + 9) / 10 rounded down.
nearestRank90(array<float> src) =>
    array<float> v = array.copy(src)
    array.sort(v, order.ascending)
    array.get(v, int((9 * array.size(v) + 9) / 10) - 1)

// ───────────────────────── Test, once ─────────────────────────
// Results, kept in var so the realtime bars only redraw the table.
var string status = "waiting for the last confirmed bar"
var array<float> realScores = array.new<float>(nLen, 0.0)
var float realBest = float(na)
var int bestLen = int(na)
var float realMed = float(na)
var float shMed = float(na)
var float shQ90 = float(na)
var float shMax = float(na)
var int nReached = int(na)
var float pVal = float(na)
var int nAbove = int(na)
var float buyHold = float(na)
var int tFrom = int(na)
var int tTo = int(na)

// barstate.islastconfirmedhistory is true on one bar only: the last bar when the market is closed, or the bar
// before the realtime bar when it is open. The return of that bar is already in the window (block above).
if barstate.islastconfirmedhistory
    int have = array.size(rets)
    if have < need
        status := "not enough bars: needs " + str.tostring(need, "#,##0") + " returns in a row (M + longest length - 1), has " + str.tostring(have, "#,##0") + "; lower M or the longest length"
    else
        array<float> px = array.new<float>(need + 1, 0.0)
        realBest := scoreAll(rets, px, lens, realScores, warm, mBars, longShort)
        // The best length is the first one with the largest score.
        int bi = 0
        for j = 1 to nLen - 1
            if array.get(realScores, j) > array.get(realScores, bi)
                bi := j
        bestLen := array.get(lens, bi)
        realMed := medianOf(realScores)
        // Buy-and-hold over the scored bars is the sum of their returns; a permutation keeps the sum.
        float bhSum = 0.0
        for i = warm to need - 1
            bhSum += array.get(rets, i)
        buyHold := bhSum
        tFrom := array.get(retTime, warm)
        tTo := array.get(retTime, need - 1)
        // K Fisher-Yates passes over the scored positions warm .. need - 1, from the last position down; each pass
        // shuffles the previous arrangement again, and each arrangement is scored by the same function. The index
        // comes from the high bits of the state, j = floor(state / 2^31 * (k + 1)), always in [0, k].
        array<float> work = array.copy(rets)
        array<float> shScores = array.new<float>(nLen, 0.0)
        array<float> shBests = array.new<float>()
        int st = seed
        int reached = 0
        float maxBest = na
        for sh = 1 to nShuf
            for q = 0 to mBars - 2
                int k = mBars - 1 - q
                st := nextState(st)
                int jj = math.min(int(math.floor(st / 2147483648.0 * (k + 1))), k)
                float tmp = array.get(work, warm + k)
                array.set(work, warm + k, array.get(work, warm + jj))
                array.set(work, warm + jj, tmp)
            float shBest = scoreAll(work, px, lens, shScores, warm, mBars, longShort)
            array.push(shBests, shBest)
            if na(maxBest) or shBest > maxBest
                maxBest := shBest
            // The tiny tolerance keeps float rounding from breaking a tie with the real best.
            if shBest >= realBest - 1.0e-12
                reached += 1
        shMed := medianOf(shBests)
        shQ90 := nearestRank90(shBests)
        shMax := maxBest
        nReached := reached
        pVal := (1.0 + reached) / (1.0 + nShuf)
        int above = 0
        for j = 0 to nLen - 1
            if array.get(realScores, j) > shQ90
                above += 1
        nAbove := above
        status := "ok"

// The visible output is the table below. This hidden plot only gives the script a plot output.
plot(na, "hidden", display = display.none)

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

// Four columns: the row names and up to three values. Nine rows: header, seven measures, footer.
var table tbl = table.new(tPos, 4, 9, border_width = 1)

// Opaque cell colors blended from the chart background, so candles do not show through the table
// on a light or a dark theme.
cellBg = color.from_gradient(0.12, 0.0, 1.0, chart.bg_color, color.gray)
hdrBg = color.from_gradient(0.30, 0.0, 1.0, chart.bg_color, color.gray)
goodBg = color.from_gradient(0.40, 0.0, 1.0, chart.bg_color, color.green)

setCell(int col, int row, string txt, color bg = na, string align = text.align_center) =>
    table.cell(tbl, col, row, txt, text_color = chart.fg_color, text_size = tSize, text_halign = align, bgcolor = na(bg) ? cellBg : bg)

// "+35.2%" or "-4.1%" from a total log return, shown as the simple return exp(s) - 1; "n/a" when there is none.
fmtRet(float s) =>
    float v = na(s) ? float(na) : (math.exp(s) - 1) * 100
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "0.0") + "%"

// The bar's open time in the chart symbol's exchange time, with the clock on intraday charts; "n/a" when none.
fmtTime(int t) =>
    na(t) ? "n/a" : str.format_time(t, timeframe.isintraday ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd", syminfo.timezone)

// Merged rows are merged once: merging cells that are already merged on every realtime tick is avoided.
var bool merged = false

if barstate.islast
    bool ok = status == "ok"
    // Verdict on p: at most 0.05 beats shuffled data, above 0.10 is within it, borderline between.
    string verdict = not ok ? status : pVal <= 0.05 ? "beats shuffled data" : pVal > 0.10 ? "within what shuffled data produces" : "borderline"
    string rule = longShort ? "long/short" : "long/flat"
    // ticker.standard gives the plain "prefix:ticker" form; syminfo.tickerid can carry the session, adjustment
    // and currency modifiers in an encoded form.
    setCell(0, 0, ticker.standard(syminfo.tickerid) + " · " + timeframe.period + " · close > SMA, " + rule + " · SMA " + str.tostring(lMin) + "-" + str.tostring(lMax) + " x" + str.tostring(nLen) + " · M " + str.tostring(mBars) + " · K " + str.tostring(nShuf) + " · seed " + str.tostring(seed), hdrBg, text.align_left)
    setCell(0, 1, "Data window", na, text.align_left)
    setCell(1, 1, "from " + fmtTime(tFrom))
    setCell(2, 1, "to " + fmtTime(tTo))
    setCell(3, 1, str.tostring(mBars, "#,##0") + " bars scored")
    setCell(0, 2, "Real data", na, text.align_left)
    setCell(1, 2, "best SMA " + (na(bestLen) ? "n/a" : str.tostring(bestLen)))
    setCell(2, 2, "best " + fmtRet(realBest))
    setCell(3, 2, "median of " + str.tostring(nLen) + " " + fmtRet(realMed))
    setCell(0, 3, "Shuffled bests", na, text.align_left)
    setCell(1, 3, "median " + fmtRet(shMed))
    setCell(2, 3, "90th pct " + fmtRet(shQ90))
    setCell(3, 3, "max " + fmtRet(shMax))
    setCell(0, 4, "p-value", na, text.align_left)
    setCell(1, 4, "p " + (na(pVal) ? "n/a" : str.tostring(pVal, "0.000")))
    setCell(2, 4, na(nReached) ? "n/a" : str.tostring(nReached) + " of " + str.tostring(nShuf) + " shuffles reached the real best", na, text.align_left)
    setCell(3, 4, "")
    setCell(0, 5, "Lengths above shuffled 90th", na, text.align_left)
    setCell(1, 5, na(nAbove) ? "n/a" : str.tostring(nAbove) + " of " + str.tostring(nLen), na, text.align_left)
    setCell(2, 5, "")
    setCell(3, 5, "")
    setCell(0, 6, "Buy and hold", na, text.align_left)
    setCell(1, 6, fmtRet(buyHold))
    setCell(2, 6, "same on every shuffle", na, text.align_left)
    setCell(3, 6, "")
    // Green only when the real best beats shuffled data; the other verdicts are plain.
    setCell(0, 7, "Verdict", na, text.align_left)
    setCell(1, 7, verdict, ok and pVal <= 0.05 ? goodBg : na, text.align_left)
    setCell(2, 7, "")
    setCell(3, 7, "")
    setCell(0, 8, "Computed once on the last confirmed bar. Shuffles reorder the scored returns. Not advice. Dates in the chart symbol's exchange time · " + syminfo.timezone, hdrBg, text.align_left)
    for c = 1 to 3
        setCell(c, 0, "", hdrBg)
        setCell(c, 8, "", hdrBg)
    if not merged
        table.merge_cells(tbl, 0, 0, 3, 0)
        table.merge_cells(tbl, 2, 4, 3, 4)
        table.merge_cells(tbl, 1, 5, 3, 5)
        table.merge_cells(tbl, 2, 6, 3, 6)
        table.merge_cells(tbl, 1, 7, 3, 7)
        table.merge_cells(tbl, 0, 8, 3, 8)
        merged := true
````
