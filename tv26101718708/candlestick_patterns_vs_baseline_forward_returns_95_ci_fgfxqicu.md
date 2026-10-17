# Candlestick Patterns vs Baseline: Forward Returns, 95% CI

- url: https://www.tradingview.com/script/fGFxqicu-Candlestick-Patterns-vs-Baseline-Forward-Returns-95-CI/
- type: indicator
- pine_id: PUB;594e5be647fe4c00a546a7bb93669255
- version: 1.0

## Description

WHAT IT DOES
Candlestick Patterns vs Baseline detects six classic candlestick patterns and measures what price did over the next N bars after each one. It measures the same thing after every bar on the chart and compares the two. For each pattern the table shows the number of occurrences, the hit rate, the mean forward return, the difference against the baseline with a 95% confidence interval, and a plain verdict.

WHAT IS ORIGINAL HERE
Marking a pattern says nothing about how often it is followed by the move it suggests. This script adds the missing reference point: every confirmed bar contributes one forward return to a baseline. Each pattern's returns are signed by its direction, so a bearish pattern is scored on the short side, and are compared with the baseline signed the same way. The comparison is a difference of means whose standard error combines the variance of both samples (Welch style), shown as a 95% interval. The verdict calls a difference only when the whole interval sits on one side of zero.
Forward returns use no look-ahead: on each confirmed bar the script looks back N bars at the signal and measures to the current close. The entry can be the next bar's open or the signal bar's close.

PATTERN DEFINITIONS
Anatomy: body = |close - open|, range = high - low, upper wick = high - max(open, close), lower wick = min(open, close) - low.
Prior trend (optional): bullish patterns need the close before the pattern to be below the close "trend length" bars earlier, bearish ones above it. Three-bar patterns shift the test two bars back.
Bullish engulfing (long): previous bar down, current bar up, open at or below the previous close, close at or above the previous open, body larger than the previous body, after a decline.
Bearish engulfing (short): the mirror image, after a rise.
Hammer (long): non-zero body, lower wick at least 2 times the body, upper wick at most 25% of the range, after a decline.
Shooting star (short): the mirror image, after a rise.
Morning star (long): first bar down with a body of at least 50% of its range, middle bar with a body of at most 30% of its range, last bar up and closing above the midpoint of the first bar's body, after a decline.
Evening star (short): the mirror image, after a rise.
Patterns are evaluated on the closed bar. Thresholds are fixed, not tuned.

HOW TO USE IT
1. Add it to a chart with as much history as your plan loads. Sample size drives everything.
2. Set the horizon, the number of bars between the signal and the exit.
3. Choose the entry: the next bar's open or the signal bar's close.
4. Keep the prior trend filter on to score reversals, or turn it off to score the candle shape alone.
5. Set the minimum number of occurrences before a verdict is shown.
Every setting you try is another comparison, so count them.

HOW TO READ THE TABLE
n: signals that had a full forward window.
Hit rate (base): share of signals with a direction-signed return above zero; in brackets, the same share over all bars.
Mean fwd % (base): mean direction-signed forward return in percent, and in brackets the mean over all bars signed the same way. For a bearish pattern a positive number means price fell.
Diff vs base, 95% CI: pattern mean minus baseline mean, in percentage points, with the 95% interval (1.96 standard errors) in square brackets.
Verdict: "beats baseline" (green) or "worse than baseline" (red) when the interval excludes zero, "no evidence" when it includes zero, "too few" below the minimum number of occurrences (30 by default).

LIMITATIONS
Overlapping windows: above a horizon of 1, consecutive windows share bars and patterns cluster in time, so returns are not independent and the interval is too narrow.
The baseline is every bar, not only bars after the same prior trend. With the filter on, a difference may come from the trend context, not the candle shape.
Six patterns and many settings mean many comparisons; about 1 interval in 20 excludes zero by chance.
The interval is a normal approximation, weak with fat tails or small samples.
Only bars loaded on the chart count, so history depth, symbol and timeframe change n.
Returns include no fees, spreads or slippage. The next open is a chart price, not a guaranteed fill.
The script reports counts and differences, not a trading rule, and it is not financial advice.

The chart shows SPY on the daily timeframe with the default settings, over all the history the chart loads (a baseline of about 8,500 bars). The table is in the bottom right, and the triangles mark the pattern signals.

## Source Code

````pine
//@version=6
indicator("Candlestick Patterns vs Baseline: Forward Returns, 95% CI", shorttitle = "CANDLE-BASE", overlay = true, max_bars_back = 500)

// Candlestick Base Rates
// 1) Detects six classic candlestick patterns on the closed bar.
// 2) For every confirmed bar, measures the forward return over the next N bars
//    (no look-ahead: the script looks BACK N bars at the signal, then measures
//    from there to the current close).
// 3) Compares each pattern's direction-signed forward returns with the same
//    measure taken over ALL bars (the baseline), with a 95% confidence interval.
// The result is a table of counts and differences, not a trading rule.

// ───────────────────────── Inputs ─────────────────────────
horizon = input.int(5, "Forward bars (horizon)", minval = 1, maxval = 100, group = "Forward return", tooltip = "Number of bars between the signal and the exit. The exit is always the close of the bar N bars after the signal bar.")
entryMode = input.string("Next bar open", "Entry", options = ["Next bar open", "Signal bar close"], group = "Forward return", tooltip = "Next bar open: the entry is the open of the bar after the signal bar. Signal bar close: the entry is the close of the signal bar.")

useTrend = input.bool(true, "Require prior trend for reversal patterns", group = "Patterns", tooltip = "Bullish patterns need a prior decline, bearish patterns a prior rise. The trend test compares two closes that are 'Trend length' bars apart, ending just before the pattern.")
trendLen = input.int(5, "Trend length (bars)", minval = 1, maxval = 100, group = "Patterns")

minN = input.int(30, "Minimum occurrences for a verdict", minval = 2, group = "Statistics", tooltip = "Below this many occurrences a pattern's verdict is 'too few'.")

showMarks = input.bool(true, "Mark pattern signals on the chart", group = "Display")
tablePos = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display")

// ───────────────────────── Candle anatomy ─────────────────────────
float body = math.abs(close - open)
float rng = high - low
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low

// ───────────────────────── Prior trend ─────────────────────────
// Single candle and engulfing patterns look at the bar before the signal bar.
// Star patterns have three bars, so their trend test is shifted by two more bars.
// With the filter off, all four tests are true.
bool downBefore = not useTrend or close[1] < close[1 + trendLen]
bool upBefore = not useTrend or close[1] > close[1 + trendLen]
bool downBefore3 = not useTrend or close[3] < close[3 + trendLen]
bool upBefore3 = not useTrend or close[3] > close[3 + trendLen]

// ───────────────────────── Patterns ─────────────────────────
// Evaluated on every bar, using only the current and earlier bars.
bool bullEngulf = close[1] < open[1] and close > open and open <= close[1] and close >= open[1] and body > body[1] and downBefore
bool bearEngulf = close[1] > open[1] and close < open and open >= close[1] and close <= open[1] and body > body[1] and upBefore
bool hammer = rng > 0 and body > 0 and lowerWick >= 2 * body and upperWick <= 0.25 * rng and downBefore
bool shootStar = rng > 0 and body > 0 and upperWick >= 2 * body and lowerWick <= 0.25 * rng and upBefore
bool morningStar = close[2] < open[2] and body[2] >= 0.5 * rng[2] and body[1] <= 0.3 * rng[1] and close > open and close > (open[2] + close[2]) / 2 and downBefore3
bool eveningStar = close[2] > open[2] and body[2] >= 0.5 * rng[2] and body[1] <= 0.3 * rng[1] and close < open and close < (open[2] + close[2]) / 2 and upBefore3

// ───────────────────────── Forward return without look-ahead ─────────────────────────
// On the current bar the "signal bar" is the bar `horizon` bars back.
//   Next bar open:     entry = open of the bar after the signal bar = open[horizon - 1]
//   Signal bar close:  entry = close of the signal bar              = close[horizon]
// The exit is the current close, so the holding period is `horizon` bars either way.
// All history references stay at global scope, so every bar evaluates them the same way.
float entryOpen = open[horizon - 1]
float entryClose = close[horizon]
float entryPx = entryMode == "Next bar open" ? entryOpen : entryClose
float fwdRet = entryPx > 0 ? close / entryPx - 1.0 : na

// Did each pattern fire on the signal bar? One flag per pattern, same order as the arrays below.
array<bool> signals = array.from(bullEngulf[horizon], bearEngulf[horizon], hammer[horizon], shootStar[horizon], morningStar[horizon], eveningStar[horizon])

// ───────────────────────── Statistics state ─────────────────────────
// Pattern order: 0 bullish engulfing, 1 bearish engulfing, 2 hammer, 3 shooting star, 4 morning star, 5 evening star.
// stats holds 4 numbers per pattern: count, sum of x, sum of x squared, hits (x > 0),
// where x = direction * forward return, so a bearish pattern is scored on the short side.
var array<string> names = array.from("Bullish engulfing", "Bearish engulfing", "Hammer", "Shooting star", "Morning star", "Evening star")
var array<int> dirs = array.from(1, -1, 1, -1, 1, -1)
var array<float> stats = array.new<float>(24, 0.0)

// Baseline: every confirmed bar with a valid forward return, unsigned.
var float baseN = 0.0
var float baseSum = 0.0
var float baseSq = 0.0
var float basePos = 0.0
var float baseNeg = 0.0

// Adds one observation x to pattern i. The caller guarantees x is not na.
addStat(array<float> st, int i, float x) =>
    int k = i * 4
    array.set(st, k, array.get(st, k) + 1.0)
    array.set(st, k + 1, array.get(st, k + 1) + x)
    array.set(st, k + 2, array.get(st, k + 2) + x * x)
    array.set(st, k + 3, array.get(st, k + 3) + (x > 0 ? 1.0 : 0.0))

// Only confirmed bars with a valid forward return update the state, so a realtime bar never counts twice
// and a bar without a full lookback window never enters the sample.
if barstate.isconfirmed and not na(fwdRet)
    baseN += 1.0
    baseSum += fwdRet
    baseSq += fwdRet * fwdRet
    if fwdRet > 0
        basePos += 1.0
    else if fwdRet < 0
        baseNeg += 1.0
    for i = 0 to 5
        if array.get(signals, i)
            addStat(stats, i, array.get(dirs, i) * fwdRet)

// ───────────────────────── Plots ─────────────────────────
// A mark is drawn only on a confirmed bar, so a realtime bar never shows a mark that later disappears.
bool markOk = showMarks and barstate.isconfirmed
plotshape(markOk and bullEngulf, "Bullish engulfing", shape.triangleup, location.belowbar, color.new(color.teal, 10), size = size.tiny, display = display.pane, text = "BuE", textcolor = color.teal)
plotshape(markOk and bearEngulf, "Bearish engulfing", shape.triangledown, location.abovebar, color.new(color.orange, 10), size = size.tiny, display = display.pane, text = "BeE", textcolor = color.orange)
plotshape(markOk and hammer, "Hammer", shape.triangleup, location.belowbar, color.new(color.blue, 10), size = size.tiny, display = display.pane, text = "H", textcolor = color.blue)
plotshape(markOk and shootStar, "Shooting star", shape.triangledown, location.abovebar, color.new(color.maroon, 10), size = size.tiny, display = display.pane, text = "SS", textcolor = color.maroon)
plotshape(markOk and morningStar, "Morning star", shape.triangleup, location.belowbar, color.new(color.green, 10), size = size.tiny, display = display.pane, text = "MS", textcolor = color.green)
plotshape(markOk and eveningStar, "Evening star", shape.triangledown, location.abovebar, color.new(color.purple, 10), size = size.tiny, display = display.pane, text = "ES", textcolor = color.purple)

// ───────────────────────── Table ─────────────────────────
tPos = switch tablePos
    "Top right" => position.top_right
    "Bottom right" => position.bottom_right
    "Top left" => position.top_left
    => position.bottom_left

var table tbl = table.new(tPos, 6, 9, border_width = 1)

cellBg = color.new(color.gray, 85)
hdrBg = color.new(color.gray, 65)
okBg = color.new(color.green, 70)
badBg = color.new(color.red, 65)

setCell(int col, int row, string txt, color bg = na, string align = text.align_center) =>
    table.cell(tbl, col, row, txt, text_color = chart.fg_color, text_size = size.small, text_halign = align, bgcolor = na(bg) ? cellBg : bg)

// Hit rate as a plain percentage with one decimal.
fmtPct(float v) =>
    na(v) ? "n/a" : str.tostring(v * 100.0, "0.0") + "%"

// Return or difference as a percentage with two decimals and an explicit sign.
fmtSigned(float v) =>
    string out = "n/a"
    if not na(v)
        float p = math.round(v * 100.0, 2)
        out := (p >= 0 ? "+" : "-") + str.tostring(math.abs(p), "0.00")
    out

// Merged rows are merged once: merging cells that are already merged on every realtime tick is avoided.
var bool merged = false

if barstate.islast
    setCell(0, 0, "Pattern", hdrBg, text.align_left)
    setCell(1, 0, "n", hdrBg)
    setCell(2, 0, "Hit rate (base)", hdrBg)
    setCell(3, 0, "Mean fwd % (base)", hdrBg)
    setCell(4, 0, "Diff vs base, 95% CI", hdrBg)
    setCell(5, 0, "Verdict", hdrBg)

    // Baseline variance. The direction sign does not change it.
    float varB = baseN >= 2 ? math.max(0.0, (baseSq - baseSum * baseSum / baseN) / (baseN - 1)) : na

    for i = 0 to 5
        int d = array.get(dirs, i)
        int k = i * 4
        float n = array.get(stats, k)
        float s = array.get(stats, k + 1)
        float q = array.get(stats, k + 2)
        float h = array.get(stats, k + 3)

        float meanP = n > 0 ? s / n : na
        float varP = n >= 2 ? math.max(0.0, (q - s * s / n) / (n - 1)) : na
        float hitP = n > 0 ? h / n : na
        float meanB = baseN > 0 ? d * baseSum / baseN : na
        float hitB = baseN > 0 ? (d > 0 ? basePos : baseNeg) / baseN : na

        float diff = meanP - meanB
        float se = math.sqrt(varP / n + varB / baseN)
        float ci = 1.96 * se

        string verdict = "no evidence"
        color verdictBg = na
        if n < minN
            verdict := "too few"
        else if diff - ci > 0
            verdict := "beats baseline"
            verdictBg := okBg
        else if diff + ci < 0
            verdict := "worse than baseline"
            verdictBg := badBg

        string diffTxt = na(ci) ? "n/a" : fmtSigned(diff) + " [" + fmtSigned(diff - ci) + ", " + fmtSigned(diff + ci) + "]"

        setCell(0, i + 1, array.get(names, i), na, text.align_left)
        setCell(1, i + 1, str.tostring(math.round(n)))
        setCell(2, i + 1, fmtPct(hitP) + " (" + fmtPct(hitB) + ")")
        setCell(3, i + 1, fmtSigned(meanP) + " (" + fmtSigned(meanB) + ")")
        setCell(4, i + 1, diffTxt)
        setCell(5, i + 1, verdict, verdictBg)

    string trendTxt = useTrend ? "on (len " + str.tostring(trendLen) + ")" : "off"
    setCell(0, 7, "Horizon " + str.tostring(horizon) + " bars · entry: " + entryMode + " · baseline n = " + str.tostring(math.round(baseN)) + " · trend filter " + trendTxt, hdrBg, text.align_left)
    setCell(0, 8, "Overlapping windows: the CI is optimistic. Counts, not advice.", hdrBg, text.align_left)
    for c = 1 to 5
        setCell(c, 7, "", hdrBg)
        setCell(c, 8, "", hdrBg)
    if not merged
        table.merge_cells(tbl, 0, 7, 5, 7)
        table.merge_cells(tbl, 0, 8, 5, 8)
        merged := true
````
