# Seasonality vs Shuffled Calendar: Is the Best Month Real?

- url: https://www.tradingview.com/script/5RcwXxp7-Seasonality-vs-Shuffled-Calendar-Is-the-Best-Month-Real/
- type: indicator
- pine_id: PUB;ad29f5f1b7b04f5e9eb4428afa6358ae
- version: 1.0

## Description

WHAT IT DOES
Seasonality Shuffle builds a seasonality board for the chart, by month of the year or by day of the week, and tests its best row against a shuffled calendar. For every bucket the table shows the number of completed periods, the mean return, the hit rate (share of periods with a positive return) and a z-score of the bucket mean against the mean of all periods. Footer rows give the best bucket, the shuffled-calendar result and a plain verdict.

WHAT IS ORIGINAL HERE
Any seasonality table has a highest row, even when the returns are pure noise: with 12 months, one of them has to come first. The useful question is whether the best bucket is higher than a random calendar would give. The script keeps the real return of every completed period and reassigns those returns to buckets at random, many times. The returns and the number of periods per bucket stay exactly as they are; only the calendar labels move. Each shuffle records its own best bucket mean. The share of shuffles that reach the observed best is an empirical p-value for "the best bucket", not for one bucket picked in advance, so the choice among 12 (or 7) candidates is already counted. The generator is deterministic with a seed you set, so the number is repeatable.

HOW THE TEST WORKS
1. The chart is split into calendar periods: one per month in Month of year mode, one per day in Day of week mode. A period's return is the close of its last bar divided by the close of the previous period's last bar, minus 1. The first, partial period and the current, unfinished one are not counted.
2. Each return gets a label: the calendar month (Jan to Dec) or the weekday (Sun to Sat).
3. Per bucket: n, mean, hit rate and z = (bucket mean - mean of all periods) / (sample standard deviation of all periods / square root of n). The z needs the minimum number of periods you set; below it the cell reads "few".
4. The best bucket is the one with the highest mean, among buckets with at least one period.
5. The labels are shuffled at random (Fisher-Yates), the returns stay put, and the best bucket mean is recomputed. This repeats for the number of runs you choose.
6. p = (runs that reach the observed best + 1) / (runs + 1). A p below 0.05 reads "unlikely to be chance"; otherwise "within random range". With fewer periods than twice the number of buckets, the test is not run: "too few periods".

HOW TO USE IT
1. Add it to a chart with as much history as your plan loads. Use a timeframe shorter than the period: daily or lower for months, intraday or daily for days.
2. Choose the buckets: Month of year or Day of week.
3. Choose the number of shuffled calendars (50 to 2000), the seed and the minimum periods per bucket for a z-score.
Every symbol, timeframe and mode you try is another look at the data.

HOW TO READ THE TABLE
Bucket: the month or the weekday. The highlighted row is the best bucket.
Periods: completed periods in that bucket. "-" means none.
Mean %: mean return per period, in percent.
Hit rate: share of periods with a return above zero.
z vs all: distance between the bucket mean and the mean of all periods, in standard errors. "few" means fewer periods than the minimum.
Footer 1: the best bucket, the number of periods and the mean of all periods.
Footer 2: how often a shuffled calendar produced a best bucket at least as good, and the verdict. Green means "unlikely to be chance".

LIMITATIONS
The test treats periods as interchangeable. It ignores trends, volatility clustering and any link between one period and the next, which shuffled labels do not preserve.
It tests the highest mean only, not the worst bucket, the ranking, or a month chosen before looking at the data.
The z-score is descriptive; the p-value does not depend on it.
About 1 test in 20 reads "unlikely to be chance" when there is no seasonality at all, and no correction is applied across symbols, timeframes or modes.
Only bars loaded on the chart count, so history depth and timeframe change the number of periods. A period is counted once the first bar of the next period has closed. Day of week mode uses calendar days in the exchange time zone.
Many runs on a long history in Day of week mode are heavy; lower the runs if TradingView reports a runtime limit.
The script reports counts and a permutation test on past data, not a forecast or a trading rule, and it is not financial advice.

The chart shows SPY on the daily timeframe with the default settings. The table is in the bottom right.

## Source Code

````pine
//@version=6
indicator("Seasonality vs Shuffled Calendar: Is the Best Month Real?", shorttitle = "SEASON-SHUFFLE", overlay = true, max_bars_back = 500)

// Seasonality Shuffle
// 1) Splits the chart into calendar periods (months or days) and stores one close-to-close return
//    per completed period, together with its bucket (calendar month or weekday).
// 2) Shows the board: periods, mean return, hit rate and a z-score for every bucket.
// 3) Tests the best bucket against a shuffled calendar: the bucket labels are permuted at random,
//    the returns stay as they are, and the best bucket mean is recomputed for every shuffle.
//    The share of shuffles that reach the observed best is the p-value of "the best bucket".
// The result is a table of counts and a permutation test, not a trading rule.

// ───────────────────────── Inputs ─────────────────────────
bucketMode = input.string("Month of year", "Buckets", options = ["Month of year", "Day of week"], group = "Buckets", tooltip = "Month of year: one return per calendar month, bucketed Jan to Dec. Day of week: one return per calendar day, bucketed Sun to Sat. Use a chart timeframe shorter than the period: daily or lower for months, intraday or daily for days.")

nShuffles = input.int(500, "Shuffled calendars (runs)", minval = 50, maxval = 2000, group = "Test", tooltip = "How many times the bucket labels are shuffled. More runs give a steadier p-value and take longer to calculate.")
seed = input.int(12345, "Random seed", minval = 1, maxval = 2147483647, group = "Test", tooltip = "Starting value of the built-in random generator. The same seed on the same chart always gives the same p-value.")
minN = input.int(10, "Minimum periods per bucket for z", minval = 2, group = "Test", tooltip = "Below this many periods a bucket shows 'few' instead of a z-score.")

tablePos = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display")

// ───────────────────────── Period logic ─────────────────────────
// Every history reference stays at global scope, so every bar evaluates it the same way.
// Month mode: one period per calendar month, bucket = month 0..11.
// Day mode: one period per calendar day (year, month, day), bucket = weekday 0..6 (Sun..Sat).
bool isMonth = bucketMode == "Month of year"
int nB = isMonth ? 12 : 7

int key = isMonth ? year(time) * 12 + month(time) : year(time) * 10000 + month(time) * 100 + dayofmonth(time)
int bucketNow = isMonth ? month(time) - 1 : dayofweek(time) - 1
bool newPeriod = key != key[1]
float prevClose = close[1]
int prevBucket = bucketNow[1]

// ───────────────────────── Period state ─────────────────────────
// periodStartClose: close of the last bar of the previous completed period.
// rets / buckets: one element per completed period, in time order.
var float periodStartClose = na
var array<float> rets = array.new<float>()
var array<int> buckets = array.new<int>()

// Only confirmed bars update the state, so a realtime bar never counts twice.
// When a new period starts, the previous bar closed the period before it.
// The first, partial period is skipped (periodStartClose is still na) and the current, unfinished period is never stored.
if barstate.isconfirmed and newPeriod and bar_index > 0
    if not na(periodStartClose) and periodStartClose > 0 and not na(prevClose) and not na(prevBucket)
        array.push(rets, prevClose / periodStartClose - 1.0)
        array.push(buckets, prevBucket)
    periodStartClose := prevClose

// ───────────────────────── Statistics ─────────────────────────
// Recomputed only on the last bar and only when the number of periods changed.
// The results live in var containers, so the table can be redrawn on every tick cheaply.
int nP = array.size(rets)

var int lastN = -1
var float meanAll = na
var float sdAll = na
var float obsBest = na
var int bestIdx = -1
var float pVal = na

var array<int> bCnt = array.new<int>(12, 0)
var array<int> bWin = array.new<int>(12, 0)
var array<float> bSum = array.new<float>(12, 0.0)
var array<float> bMean = array.new<float>(12, float(na))
var array<float> bHit = array.new<float>(12, float(na))
var array<float> bZ = array.new<float>(12, float(na))

if barstate.islast and nP != lastN
    lastN := nP
    array.fill(bCnt, 0)
    array.fill(bWin, 0)
    array.fill(bSum, 0.0)
    array.fill(bMean, float(na))
    array.fill(bHit, float(na))
    array.fill(bZ, float(na))

    // Pass 1: per-bucket counts, sums and hits, plus the overall sum.
    float sumAll = 0.0
    if nP > 0
        for i = 0 to nP - 1
            float r = array.get(rets, i)
            int b = array.get(buckets, i)
            array.set(bCnt, b, array.get(bCnt, b) + 1)
            array.set(bSum, b, array.get(bSum, b) + r)
            if r > 0
                array.set(bWin, b, array.get(bWin, b) + 1)
            sumAll += r
    meanAll := nP > 0 ? sumAll / nP : na

    // Pass 2: sample standard deviation of all periods, around the overall mean.
    float ssAll = 0.0
    if nP > 1
        for i = 0 to nP - 1
            float d = array.get(rets, i) - meanAll
            ssAll += d * d
    sdAll := nP > 1 ? math.sqrt(ssAll / (nP - 1)) : na

    // Per bucket: mean, hit rate and z = (bucket mean - overall mean) / (sd / sqrt(n)). z needs at least minN periods.
    float best = na
    int bi = -1
    for b = 0 to nB - 1
        int cntB = array.get(bCnt, b)
        if cntB > 0
            float mb = array.get(bSum, b) / cntB
            array.set(bMean, b, mb)
            array.set(bHit, b, float(array.get(bWin, b)) / cntB)
            if cntB >= minN and not na(sdAll) and sdAll > 0
                array.set(bZ, b, (mb - meanAll) / (sdAll / math.sqrt(cntB)))
            // Observed best bucket: the highest mean among buckets with at least one period.
            if na(best) or mb > best
                best := mb
                bi := b
    obsBest := best
    bestIdx := bi

    // Permutation test. The returns stay where they are; only the bucket labels move.
    // Counts per bucket do not change under a permutation, so only the sums are rebuilt.
    // Random numbers: LCG state := (state * 1103515245 + 12345) % 2147483648 (the product fits a 64-bit int).
    // The index is taken from the high bits of the state: j = floor(state / 2^31 * (i + 1)), always in [0, i].
    // Fisher-Yates runs from the last position down; a position is final once it is swapped, so its return is added in the same pass.
    pVal := na
    if nP >= 2 * nB and not na(best)
        int nGE = 0
        int st = seed % 2147483648
        array<int> work = array.copy(buckets)
        array<float> shSum = array.new<float>(nB, 0.0)
        for s = 1 to nShuffles
            array.fill(shSum, 0.0)
            for k = 0 to nP - 2
                int i = nP - 1 - k
                st := (st * 1103515245 + 12345) % 2147483648
                int j = math.min(int(math.floor(st / 2147483648.0 * (i + 1))), i)
                int lj = array.get(work, j)
                array.set(work, j, array.get(work, i))
                array.set(work, i, lj)
                array.set(shSum, lj, array.get(shSum, lj) + array.get(rets, i))
            int l0 = array.get(work, 0)
            array.set(shSum, l0, array.get(shSum, l0) + array.get(rets, 0))

            // Best bucket mean of this shuffle, over buckets with at least one period.
            float shBest = na
            for q = 0 to nB - 1
                int nq = array.get(bCnt, q)
                if nq > 0
                    float mq = array.get(shSum, q) / nq
                    if na(shBest) or mq > shBest
                        shBest := mq
            // The tiny tolerance keeps float rounding from breaking a tie with the observed best.
            if shBest >= best - 1.0e-12
                nGE += 1
        pVal := (nGE + 1.0) / (nShuffles + 1.0)

// The visible output is the table below. This hidden plot only gives the script a plot output.
plot(na, "hidden", display = display.none)

// ───────────────────────── Table ─────────────────────────
tPos = switch tablePos
    "Top right" => position.top_right
    "Bottom right" => position.bottom_right
    "Top left" => position.top_left
    => position.bottom_left

// Columns: bucket, periods, mean %, hit rate, z. Rows: header, one per bucket, three footers.
var table tbl = table.new(tPos, 5, nB + 4, border_width = 1)

cellBg = color.new(color.gray, 85)
hdrBg = color.new(color.gray, 65)
bestBg = color.new(color.blue, 75)
okBg = color.new(color.green, 70)

var array<string> monthNames = array.from("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
var array<string> dowNames = array.from("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

bucketLabel(int b) =>
    isMonth ? array.get(monthNames, b) : array.get(dowNames, b)

setCell(int col, int row, string txt, color bg = na, string align = text.align_center) =>
    table.cell(tbl, col, row, txt, text_color = chart.fg_color, text_size = size.small, text_halign = align, bgcolor = na(bg) ? cellBg : bg)

// Share as a plain percentage with one decimal.
fmtPct(float v) =>
    na(v) ? "n/a" : str.tostring(v * 100.0, "0.0") + "%"

// Return as a percentage with two decimals and an explicit sign (no percent sign).
fmtSigned(float v) =>
    string out = "n/a"
    if not na(v)
        float p = math.round(v * 100.0, 2)
        out := (p >= 0 ? "+" : "-") + str.tostring(math.abs(p), "0.00")
    out

// z-score with two decimals and an explicit sign.
fmtZ(float v) =>
    string out = "n/a"
    if not na(v)
        float q = math.round(v, 2)
        out := (q >= 0 ? "+" : "-") + str.tostring(math.abs(q), "0.00")
    out

// p-value as a percentage: two decimals below 1%, one decimal otherwise.
fmtP(float v) =>
    na(v) ? "n/a" : (v < 0.01 ? str.tostring(v * 100.0, "0.00") : str.tostring(v * 100.0, "0.0")) + "%"

// Merged rows are merged once: merging cells that are already merged on every realtime tick is avoided.
// Inputs cannot change without a full recalculation, so the footer rows never move.
var bool merged = false

if barstate.islast
    int nPer = array.size(rets)
    bool enough = nPer >= 2 * nB

    setCell(0, 0, "Bucket", hdrBg, text.align_left)
    setCell(1, 0, "Periods", hdrBg)
    setCell(2, 0, "Mean %", hdrBg)
    setCell(3, 0, "Hit rate", hdrBg)
    setCell(4, 0, "z vs all", hdrBg)

    for b = 0 to nB - 1
        int cntB = array.get(bCnt, b)
        color rowBg = b == bestIdx ? bestBg : na
        string zTxt = "-"
        if cntB > 0
            float zb = array.get(bZ, b)
            zTxt := cntB < minN ? "few" : fmtZ(zb)
        setCell(0, b + 1, bucketLabel(b), rowBg, text.align_left)
        setCell(1, b + 1, cntB > 0 ? str.tostring(cntB) : "-", rowBg)
        setCell(2, b + 1, cntB > 0 ? fmtSigned(array.get(bMean, b)) : "-", rowBg)
        setCell(3, b + 1, cntB > 0 ? fmtPct(array.get(bHit, b)) : "-", rowBg)
        setCell(4, b + 1, zTxt, rowBg)

    // Verdict for the best bucket.
    string verdict = "too few periods"
    color verdictBg = hdrBg
    if enough and not na(pVal)
        if pVal < 0.05
            verdict := "unlikely to be chance"
            verdictBg := okBg
        else
            verdict := "within random range"

    string bestTxt = bestIdx >= 0 ? "Best: " + bucketLabel(bestIdx) + " " + fmtSigned(obsBest) + "%" : "Best: n/a"
    string f1 = bestTxt + " · all periods: " + str.tostring(nPer) + " · mean " + (nPer > 0 ? fmtSigned(meanAll) + "%" : "n/a")
    string f2Head = str.tostring(nShuffles) + " shuffles (seed " + str.tostring(seed) + "): "
    string f2 = enough ? f2Head + "best this high in " + fmtP(pVal) + " -> " + verdict : f2Head + "not run, " + str.tostring(nPer) + " periods (at least " + str.tostring(2 * nB) + " needed) -> " + verdict

    int fr = nB + 1
    setCell(0, fr, f1, hdrBg, text.align_left)
    setCell(0, fr + 1, f2, verdictBg, text.align_left)
    setCell(0, fr + 2, "One return per completed period. Counts, not advice.", hdrBg, text.align_left)
    for c = 1 to 4
        setCell(c, fr, "", hdrBg)
        setCell(c, fr + 1, "", verdictBg)
        setCell(c, fr + 2, "", hdrBg)
    if not merged
        table.merge_cells(tbl, 0, fr, 4, fr)
        table.merge_cells(tbl, 0, fr + 1, 4, fr + 1)
        table.merge_cells(tbl, 0, fr + 2, 4, fr + 2)
        merged := true
````
