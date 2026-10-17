# RSI Divergence vs Random Bars: Does It Call the Turn?

- url: https://www.tradingview.com/script/LxAhwOxK-RSI-Divergence-vs-Random-Bars-Does-It-Call-the-Turn/
- type: indicator
- pine_id: PUB;03ee9822fe94468ba9fcd8e90c6b7aee
- version: 1.0

## Description

WHAT IT DOES
A regular RSI divergence is a price low below the previous low while the RSI makes a higher low, or a price high above the previous high while the RSI makes a lower high. It is read as a sign that price is about to turn. This indicator counts whether it does. It finds pivot lows and pivot highs on the RSI the way the built-in Divergence Indicator finds them and compares each with the previous pivot of the same kind. Every regular divergence becomes an event at the bar where it confirms, with the close as entry and a direction: up after a bullish divergence, down after a bearish one. N bars later the event is a hit when the close moved that way. The table on the last bar shows the divergences' hit rate with a 95% confidence interval next to two baselines measured on the same bars.

WHAT IS ORIGINAL HERE
A hit rate alone cannot tell whether the RSI added anything: on a random walk half of the moves after any signal go the right way, and after a sharp swing price may bounce whatever the RSI did. This script keeps two baselines inside the measurement. The first is a matched swing control: every pivot where price made a lower low (or a higher high) but the RSI did not diverge. Same price shape, same pivot settings, only the RSI reading differs, so the gap between the two groups is what the RSI adds. The second is a random baseline: a seeded generator picks about two bars in a hundred with a random direction each, resolved with the same rule. The divergence has to beat both. If it beats the random bars but not the swing control, the turn comes from the swing, not from the RSI. The verdict row says which case applies.

HOW IT IS MEASURED
- RSI: ta.rsi(close, length), 14 by default.
- Pivots: ta.pivotlow and ta.pivothigh on the RSI, 5 bars left and 5 right by default; a pivot confirms 5 bars after its bar, and its price is that bar's low or high.
- Classification, when 5 to 60 bars lie between the pivot and the previous one of the same kind: price lower low and RSI higher low is a bullish divergence, price lower low and RSI lower low is the swing control; price higher high and RSI lower high is a bearish divergence, price higher high and RSI higher high is the swing control.
- Events: entry is the close of the confirmation bar; N bars later (10 by default) move = direction * (close / entry - 1), a hit when positive.
- Random bars: two seeded draws per bar, one for the bar and one for the direction; bars already carrying a divergence or control event are skipped.
- Statistics: rate = hits / n, interval = rate +- 1.96 * sqrt(rate * (1 - rate) / n).
- Counters move only on confirmed bars; events still open on the last bar are not counted. No request.security call.

HOW TO USE IT
1. Keep the defaults first; the pivot settings are the built-in's. Then set the horizon to the bars you would hold after a divergence.
2. Read the "Difference" row: the divergence rate minus the swing control, and minus the random bars, in points.
3. Read the "Verdict" row: "adds information" when the lower bound of the divergence interval clears both baselines, "no edge over the same swing" when the divergence rate sits inside or below the control's interval, "borderline" between; "(small sample)" under 30 divergences on a side.
4. Set the horizon to 1 and to 50: all groups should move together.

HOW TO READ THE TABLE
Header: symbol, timeframe, RSI length, pivot lookbacks, range, horizon.
Bullish divergence, Bearish divergence: events resolved, hit rate, 95% confidence interval.
All divergences: both sides pooled, hit rate, mean move in percent.
Same swing, no divergence and Random bars: the two baselines, same three figures.
Difference: divergence rate minus control and minus random, in points; bars counted.
Verdict: one of the three readings above, or "not enough events yet".
Last divergence: type, bar time in the chart symbol's exchange time, outcome or pending.

LIMITATIONS
- Regular divergences only, found the way the built-in finds them; hidden divergences are out of scope.
- The horizon is one number and the outcome is the sign of a close-to-close move: no stops, no targets, no costs.
- The swing control shares the divergences' pivot settings; change them and both change.
- A random walk gives about 50% to every group; a difference of a few points is noise.
- Only loaded bars count, so history depth, symbol and timeframe change the result. Counts, not a trading rule. Not financial advice.

The chart shows BINANCE:BTCUSDT on the 1 hour timeframe with the default settings. The table is in the bottom right.

## Source Code

````pine
//@version=6
indicator("RSI Divergence vs Random Bars: Does It Call the Turn?", shorttitle = "DIV-VS-RANDOM", overlay = true, behind_chart = false)

// RSI Divergence vs Random Bars
// 1) Finds pivot lows and pivot highs on the RSI with ta.pivotlow and ta.pivothigh, lbL bars to the left and
//    lbR to the right, the way the built-in Divergence Indicator finds them. A pivot confirms lbR bars after
//    its bar. When rangeLower to rangeUpper bars lie between it and the previous pivot of the same kind (the
//    built-in's lookback range), the new one is classified: price lower low with RSI higher low is a bullish
//    divergence; price lower low with RSI lower low is the same swing with no divergence, the swing control.
//    Mirrored for highs: price higher high with RSI lower high is a bearish divergence, with RSI higher high
//    the control. Other shapes are ignored.
// 2) Every classified pivot is an event at the bar where it confirms: entry = close, direction +1 (bullish
//    side) or -1 (bearish side). On every bar a seeded generator also draws a random event with a small
//    probability and a random direction; a bar taken by a divergence or control event is skipped. N bars
//    later each event resolves: move = direction * (close / entry - 1), a hit when the move is positive.
// 3) On the last bar the table shows n, hit rate and 95% interval for the bullish, the bearish and all
//    divergences, n, hit rate and mean move for the swing control and the random bars, the differences in
//    points and a verdict. When the divergences do no better than the same swing without divergence, the RSI
//    adds nothing to the shape of price on this chart.
// The result is a table of counts for this symbol on this chart, not a rule.

// ───────────────────────── Inputs ─────────────────────────
rsiLen = input.int(14, "RSI length", minval = 2, group = "RSI", tooltip = "Length of ta.rsi(close, length). The pivots are found on this series, not on price.")

lbL = input.int(5, "Pivot lookback left", minval = 1, maxval = 100, group = "Pivots", tooltip = "Bars to the left that an RSI pivot must exceed. 5 and 5 are the defaults of the built-in Divergence Indicator.")
lbR = input.int(5, "Pivot lookback right", minval = 1, maxval = 100, group = "Pivots", tooltip = "Bars to the right that an RSI pivot must exceed. A pivot confirms this many bars after its bar, and the event is created there.")
rangeLower = input.int(5, "Min bars between pivots", minval = 1, group = "Pivots", tooltip = "At least this many bars must lie between the new pivot and the previous one of the same kind, as in the built-in's lookback range, or nothing is classified.")
rangeUpper = input.int(60, "Max bars between pivots", minval = 2, group = "Pivots", tooltip = "At most this many bars may lie between the new pivot and the previous one of the same kind, as in the built-in's lookback range, or nothing is classified.")

horizon = input.int(10, "Horizon N (bars)", minval = 1, maxval = 200, group = "Outcome", tooltip = "An event resolves N bars after its bar: move = direction * (close / entry - 1). It is a hit when the move is positive.")

randRate = input.float(2.0, "Random bars per 100 bars", minval = 0.1, maxval = 50, step = 0.5, group = "Random baseline", tooltip = "Probability, in percent, that a bar carries a random event with a random direction. Bars taken by a divergence or control event are skipped.")
seed = input.int(7, "Seed", minval = 0, maxval = 2147483647, group = "Random baseline", tooltip = "Seed of the generator that draws the random bars. The same seed draws the same candidate bars on every chart; change it to draw others.")

showMarks = input.bool(true, "Mark divergences", group = "Display", tooltip = "A small triangle at the bar where each divergence confirms: up below the bar for bullish, down above the bar for bearish.")
tablePos = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display")
textSize = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], group = "Display")

// ───────────────────────── RSI and pivots ─────────────────────────
// The pivots are found on the RSI: a pivot confirms lbR bars after its bar, its RSI value is osc[lbR] and it is
// paired with the price of its bar, low[lbR] for a pivot low and high[lbR] for a pivot high.
float osc = ta.rsi(close, rsiLen)
float ph = ta.pivothigh(osc, lbL, lbR)
float pl = ta.pivotlow(osc, lbL, lbR)

// The previous pivot of each kind: RSI value, price and bar index.
var float prevHighOsc = float(na)
var float prevHighPrice = float(na)
var int prevHighBar = int(na)
var float prevLowOsc = float(na)
var float prevLowPrice = float(na)
var int prevLowBar = int(na)

// ───────────────────────── Ledger state ─────────────────────────
// Groups: 0 bullish divergence, 1 bearish divergence, 2 swing control (both sides), 3 random bars. Per group:
// events resolved, hits and the sum of the moves in percent.
var array<int> grpN = array.new<int>(4, 0)
var array<int> grpHits = array.new<int>(4, 0)
var array<float> grpMove = array.new<float>(4, 0.0)

// Pending events, oldest first: bar index, direction, group and entry. An event leaves the arrays when it
// resolves, N bars after its bar, so they never hold more than the events of the last N bars.
var array<int> evBar = array.new<int>()
var array<int> evDir = array.new<int>()
var array<int> evGroup = array.new<int>()
var array<float> evEntry = array.new<float>()

// Bars counted, the generator state, and the last divergence: direction, confirmation bar and its time, and
// the move once it resolves.
var int nBars = 0
var int rngState = seed
var int lastDivDir = int(na)
var int lastDivBar = int(na)
var int lastDivTime = int(na)
var float lastDivMove = float(na)

// True on the bar where a bullish or a bearish divergence confirms; the markers read them.
bool bullHere = false
bool bearHere = false

// Appends an event at the current bar with its direction and group; the entry is the close.
addEvent(int dir, int grp) =>
    array.push(evBar, bar_index)
    array.push(evDir, dir)
    array.push(evGroup, grp)
    array.push(evEntry, close)

// Next state of the linear congruential generator state = (1103515245 * state + 12345) % 2^31. The product is
// taken in two parts that each stay below 2^53, so it is exact whatever the width of the int:
// 1103515245 = 16838 * 65536 + 20077. A uniform in [0, 1) is state / 2^31.
nextState(int state) =>
    int hi = (16838 * state) % 32768
    (hi * 65536 + 20077 * state + 12345) % 2147483648

// ───────────────────────── Ledger update ─────────────────────────
// Everything counts on confirmed bars only: on the realtime bar ta.pivothigh and ta.pivotlow still read the
// forming RSI value, and the close an event resolves on is not final. The order on a bar: resolve the events
// whose N bars are up, classify the pivots that confirm (the high first, then the low, as in the simulation),
// then the random draw.
if barstate.isconfirmed
    nBars += 1
    // Events are appended in bar order, so the due ones are at the front.
    while array.size(evBar) > 0
        if bar_index - array.get(evBar, 0) < horizon
            break
        int b = array.shift(evBar)
        int d = array.shift(evDir)
        int g = array.shift(evGroup)
        float e = array.shift(evEntry)
        float move = d * (close / e - 1) * 100
        array.set(grpN, g, array.get(grpN, g) + 1)
        if move > 0
            array.set(grpHits, g, array.get(grpHits, g) + 1)
        array.set(grpMove, g, array.get(grpMove, g) + move)
        if g < 2 and b == lastDivBar and d == lastDivDir
            lastDivMove := move
    int evBefore = array.size(evBar)
    int pivBar = bar_index - lbR
    // Pivot high of the RSI, paired with high[lbR]. With a previous pivot high in range: price higher high and
    // RSI lower high is a bearish divergence, RSI higher high is the swing control; anything else is ignored.
    // The previous pivot is replaced either way. The gap is the bars strictly between the two pivot bars, which
    // is what the built-in's ta.barssince(phFound[1]) counts on the confirmation bar.
    if not na(ph)
        if not na(prevHighBar)
            int gapH = pivBar - prevHighBar - 1
            if gapH >= rangeLower and gapH <= rangeUpper and high[lbR] > prevHighPrice
                if ph < prevHighOsc
                    addEvent(-1, 1)
                    bearHere := true
                else if ph > prevHighOsc
                    addEvent(-1, 2)
        prevHighOsc := ph
        prevHighPrice := high[lbR]
        prevHighBar := pivBar
    // Pivot low of the RSI, paired with low[lbR]: price lower low and RSI higher low is a bullish divergence,
    // RSI lower low is the swing control.
    if not na(pl)
        if not na(prevLowBar)
            int gapL = pivBar - prevLowBar - 1
            if gapL >= rangeLower and gapL <= rangeUpper and low[lbR] < prevLowPrice
                if pl > prevLowOsc
                    addEvent(1, 0)
                    bullHere := true
                else if pl < prevLowOsc
                    addEvent(1, 2)
        prevLowOsc := pl
        prevLowPrice := low[lbR]
        prevLowBar := pivBar
    // The "Last divergence" row; when both sides confirm on one bar, the bullish one is kept.
    if bullHere or bearHere
        lastDivDir := bullHere ? 1 : -1
        lastDivBar := bar_index
        lastDivTime := time
        lastDivMove := float(na)
    // Random event: two draws on every bar, whatever it carries, so the same seed gives the same candidate bars
    // and directions on every chart. The first draw picks the bar, the second its direction, and a candidate
    // bar taken by a divergence or control event is skipped.
    rngState := nextState(rngState)
    float u1 = rngState / 2147483648.0
    rngState := nextState(rngState)
    float u2 = rngState / 2147483648.0
    if u1 < randRate / 100 and array.size(evBar) == evBefore
        addEvent(u2 < 0.5 ? 1 : -1, 3)

// ───────────────────────── Markers ─────────────────────────
plotshape(showMarks and bullHere, "Bullish divergence", style = shape.triangleup, location = location.belowbar, color = color.new(color.teal, 0), size = size.small, display = display.pane)
plotshape(showMarks and bearHere, "Bearish divergence", style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.small, display = display.pane)

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

// Four columns: the row names and up to three values. Ten rows: header, eight measures, footer.
var table tbl = table.new(tPos, 4, 10, border_width = 1)

// Opaque cell colors blended from the chart background, so candles do not show through the table
// on a light or a dark theme.
cellBg = color.from_gradient(0.12, 0.0, 1.0, chart.bg_color, color.gray)
hdrBg = color.from_gradient(0.30, 0.0, 1.0, chart.bg_color, color.gray)
goodBg = color.from_gradient(0.40, 0.0, 1.0, chart.bg_color, color.green)

setCell(int col, int row, string txt, color bg = na, string align = text.align_center) =>
    table.cell(tbl, col, row, txt, text_color = chart.fg_color, text_size = tSize, text_halign = align, bgcolor = na(bg) ? cellBg : bg)

// hits / n as a rate in [0, 1], na when there is no event.
rateOf(int hits, int n) =>
    n > 0 ? float(hits) / n : float(na)

// Half width of the 95% normal interval on a rate, 1.96 * sqrt(p * (1 - p) / n), na when there is no event.
ciHalf(float p, int n) =>
    n > 0 ? 1.96 * math.sqrt(p * (1 - p) / n) : float(na)

// sum / n as a mean move in percent, na when there is no event.
meanOf(float sum, int n) =>
    n > 0 ? sum / n : float(na)

// "48.3%" from a rate in [0, 1], "n/a" when there is none.
fmtRate(float r) =>
    na(r) ? "n/a" : str.tostring(r * 100, "0.0") + "%"

// "40.1% - 56.5%" from a rate and the half width of its interval, clipped to [0, 1], "n/a" when there is none.
fmtCi(float p, float h) =>
    na(p) ? "n/a" : fmtRate(math.max(p - h, 0)) + " - " + fmtRate(math.min(p + h, 1))

// "+1.2 pts" or "-1.2 pts" from a signed difference in percentage points, "n/a" when there is none.
fmtPts(float v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "0.0") + " pts"

// "+0.42%" or "-0.42%" from a move in percent, "n/a" when there is none.
fmtMove(float m) =>
    na(m) ? "n/a" : (m > 0 ? "+" : "") + str.tostring(m, "0.00") + "%"

// The bar's open time in the chart symbol's exchange time, "n/a" when there is none.
fmtTime(int t) =>
    na(t) ? "n/a" : str.format_time(t, "yyyy-MM-dd HH:mm", syminfo.timezone)

// Merged rows are merged once: merging cells that are already merged on every realtime tick is avoided.
var bool merged = false

if barstate.islast
    int nBull = array.get(grpN, 0)
    int nBear = array.get(grpN, 1)
    int nDiv = nBull + nBear
    int nCtl = array.get(grpN, 2)
    int nRnd = array.get(grpN, 3)
    float pBull = rateOf(array.get(grpHits, 0), nBull)
    float pBear = rateOf(array.get(grpHits, 1), nBear)
    float pDiv = rateOf(array.get(grpHits, 0) + array.get(grpHits, 1), nDiv)
    float pCtl = rateOf(array.get(grpHits, 2), nCtl)
    float pRnd = rateOf(array.get(grpHits, 3), nRnd)
    float hDiv = ciHalf(pDiv, nDiv)
    float hCtl = ciHalf(pCtl, nCtl)
    // Verdict: the divergences add information when the lower bound of their interval clears both the control
    // rate and the random rate; they have no edge over the same swing when their rate lies within or below the
    // control's interval; borderline otherwise. Under 30 divergences on either side the verdict says so.
    bool adds = nDiv > 0 and nCtl > 0 and nRnd > 0 and pDiv - hDiv > pCtl and pDiv - hDiv > pRnd
    string verdict = nDiv == 0 or nCtl == 0 or nRnd == 0 ? "not enough events yet" : adds ? "adds information" : pDiv <= pCtl + hCtl ? "no edge over the same swing" : "borderline"
    if nDiv > 0 and (nBull < 30 or nBear < 30)
        verdict += " (small sample)"
    string lastType = na(lastDivDir) ? "n/a" : lastDivDir == 1 ? "bullish" : "bearish"
    string lastOutcome = na(lastDivDir) ? "n/a" : na(lastDivMove) ? "pending" : (lastDivMove > 0 ? "hit " : "miss ") + fmtMove(lastDivMove)
    // ticker.standard gives the plain "prefix:ticker" form; syminfo.tickerid can carry the session, adjustment
    // and currency modifiers in an encoded form.
    setCell(0, 0, ticker.standard(syminfo.tickerid) + " · " + timeframe.period + " · RSI " + str.tostring(rsiLen) + " · pivots " + str.tostring(lbL) + "/" + str.tostring(lbR) + " · range " + str.tostring(rangeLower) + "-" + str.tostring(rangeUpper) + " · horizon " + str.tostring(horizon), hdrBg, text.align_left)
    setCell(0, 1, "Bullish divergence", na, text.align_left)
    setCell(1, 1, "n " + str.tostring(nBull, "#,##0"))
    setCell(2, 1, "hit rate " + fmtRate(pBull))
    setCell(3, 1, "95% CI " + fmtCi(pBull, ciHalf(pBull, nBull)))
    setCell(0, 2, "Bearish divergence", na, text.align_left)
    setCell(1, 2, "n " + str.tostring(nBear, "#,##0"))
    setCell(2, 2, "hit rate " + fmtRate(pBear))
    setCell(3, 2, "95% CI " + fmtCi(pBear, ciHalf(pBear, nBear)))
    setCell(0, 3, "All divergences", na, text.align_left)
    setCell(1, 3, "n " + str.tostring(nDiv, "#,##0"))
    setCell(2, 3, "hit rate " + fmtRate(pDiv))
    setCell(3, 3, "mean move " + fmtMove(meanOf(array.get(grpMove, 0) + array.get(grpMove, 1), nDiv)))
    setCell(0, 4, "Same swing, no divergence", na, text.align_left)
    setCell(1, 4, "n " + str.tostring(nCtl, "#,##0"))
    setCell(2, 4, "hit rate " + fmtRate(pCtl))
    setCell(3, 4, "mean move " + fmtMove(meanOf(array.get(grpMove, 2), nCtl)))
    setCell(0, 5, "Random bars", na, text.align_left)
    setCell(1, 5, "n " + str.tostring(nRnd, "#,##0"))
    setCell(2, 5, "hit rate " + fmtRate(pRnd))
    setCell(3, 5, "mean move " + fmtMove(meanOf(array.get(grpMove, 3), nRnd)))
    setCell(0, 6, "Difference", na, text.align_left)
    setCell(1, 6, "vs swing control " + fmtPts((pDiv - pCtl) * 100))
    setCell(2, 6, "vs random " + fmtPts((pDiv - pRnd) * 100))
    setCell(3, 6, str.tostring(nBars, "#,##0") + " bars counted")
    // Green only when the divergences add information; the other verdicts are plain.
    setCell(0, 7, "Verdict", na, text.align_left)
    setCell(1, 7, verdict, adds ? goodBg : na, text.align_left)
    setCell(2, 7, "")
    setCell(3, 7, "")
    setCell(0, 8, "Last divergence", na, text.align_left)
    setCell(1, 8, lastType)
    setCell(2, 8, "bar " + fmtTime(lastDivTime))
    setCell(3, 8, lastOutcome)
    setCell(0, 9, "Counts on confirmed bars. Not advice. Dates in the chart symbol's exchange time · " + syminfo.timezone, hdrBg, text.align_left)
    for c = 1 to 3
        setCell(c, 0, "", hdrBg)
        setCell(c, 9, "", hdrBg)
    if not merged
        table.merge_cells(tbl, 0, 0, 3, 0)
        table.merge_cells(tbl, 1, 7, 3, 7)
        table.merge_cells(tbl, 0, 9, 3, 9)
        merged := true
````
