# Markov Regime Transition Matrix [Jayadev Rana]

- url: https://www.tradingview.com/script/mSGbMG0h-Markov-Regime-Transition-Matrix-Jayadev-Rana/
- type: indicator
- pine_id: PUB;4c254c0f91de4430bc6f9fa492a47abe
- version: 1.0

## Description

WHAT IT IS

Markov Regime Transition Matrix turns price action into a sequence of four market states and estimates how the market moves between them. Instead of asking "what is the trend", it asks "given the state we are in, where does this market usually go next, how long does it usually stay, and how predictable is that". It is an information tool: there are no entry or exit signals.

THE FOUR STATES

Every bar is assigned one state from two features:
- Kaufman efficiency ratio over N bars (net move divided by the sum of bar-to-bar moves). Above the trend threshold the bar is trending, with direction taken from the sign of the net move: Trend up or Trend down.
- When the efficiency ratio is below the threshold the bar is ranging. The ATR percentile against a longer window splits ranging bars into Quiet range (low percentile) and Volatile range (high percentile).

THE MARKOV ESTIMATE

The script keeps the state of the last W bars (input, default 500) and counts every transition from one state to the next inside that window. Older transitions roll out as new ones arrive, so the matrix adapts to the recent character of the market. From the counts it derives:
- Transition matrix: the probability of moving from each state to each other state, shown as a colour-coded 4x4 table with the number of observations per row.
- Stationary distribution: the long-run share of time the chain spends in each state, found by power iteration.
- Expected dwell time per state: 1 / (1 - probability of staying), in bars.
- Entropy rate of the chain in bits per transition and a predictability percentage (100% means the next state is certain, 0% means all four are equally likely).
- For the current state: bars already spent in it, the stay probability, the most likely next state and its probability.
- Forecast hit rate: on each bar the script records which state it expected next and checks it against what actually happened; the rolling hit rate over the hit-rate window is shown next to the 25% random baseline. This is a live out-of-sample check of the matrix.

PANE AND TABLE

The pane plots the stay probability, the chain predictability, the forecast hit rate and the next-state probability, with 25% and 50% reference lines, and a colour lane showing the current state. The pane background can be shaded by state. The table shows the full matrix, stationary shares, dwell times, and the current-state summary. Data-window plots expose the state code, efficiency ratio, ATR percentile, bars in state and the entropy rate.

INPUTS

State features: efficiency ratio length and trend threshold, ATR length, ATR percentile window and volatile threshold.
Markov estimation: transition window, forecast hit-rate window, stationary-distribution iterations.
Display: table on/off and position, background shading, state colours.

ALERTS

State changed, and one alert per state entered. Informational only.

INTENDED USE

Any symbol and timeframe. Use it to judge whether the current regime is likely to persist (high stay probability, long dwell) or to break (low stay probability), and to see how predictable this market has been lately. It works as a context layer for other tools rather than as a signal source.

LIMITATIONS

The states are a deliberately simple discretisation; different thresholds give different chains. The matrix is estimated from a finite window, so rows with few observations are noisy (the n column shows how many transitions back each row). A first-order Markov assumption ignores longer memory. The hit rate measures the forecast of the state label only, not price direction or profitability. Values are computed on confirmed bars; the current bar can change state until it closes.

This is an educational and analytical tool, not financial advice. Past regime behaviour does not guarantee future regime behaviour.

## Source Code

````pine
//@version=6
// ============================================================================
//  Markov Regime Transition Matrix [Jayadev Rana]
//  Discretises every bar into one of four market states, estimates the
//  rolling first-order Markov transition matrix between them, and reports
//  the stationary distribution, entropy rate, expected dwell time, the most
//  likely next state and a live out-of-sample hit rate of that forecast.
//  Information tool only: no entry or exit signals are produced.
// ============================================================================
indicator("Markov Regime Transition Matrix [Jayadev Rana]", shorttitle = "MRTM", overlay = false, precision = 1)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gF = "State features"
erLen   = input.int(10, "Efficiency ratio length", minval = 3, maxval = 100, group = gF, tooltip = "Kaufman efficiency ratio: net move divided by the sum of bar-to-bar moves. High values mean price travelled in a straight line.")
erThr   = input.float(0.30, "Trend threshold (ER)", minval = 0.05, maxval = 0.95, step = 0.05, group = gF, tooltip = "Efficiency ratio above this = trending state (up or down by the sign of the net move). Below = ranging state.")
volLen  = input.int(14, "ATR length", minval = 2, maxval = 100, group = gF)
rankLen = input.int(100, "ATR percentile window", minval = 20, maxval = 1000, group = gF, tooltip = "Ranging bars are split into quiet vs volatile by the ATR percentile against this window.")
volThr  = input.float(50, "Volatile threshold (ATR percentile)", minval = 10, maxval = 90, step = 5, group = gF)

gM = "Markov estimation"
window  = input.int(500, "Transition window (bars)", minval = 50, maxval = 5000, group = gM, tooltip = "Number of most recent transitions used to estimate the matrix. Older transitions roll out of the counts.")
hitLen  = input.int(200, "Forecast hit-rate window", minval = 20, maxval = 2000, group = gM)
iters   = input.int(40, "Stationary distribution iterations", minval = 5, maxval = 200, group = gM)

gD = "Display"
showTbl = input.bool(true, "Transition matrix table", group = gD)
showBg  = input.bool(true, "Colour pane background by state", group = gD)
tblPos  = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = gD)
c0 = input.color(color.new(#26a69a, 0), "Trend up", group = gD)
c1 = input.color(color.new(#ef5350, 0), "Trend down", group = gD)
c2 = input.color(color.new(#2962ff, 0), "Quiet range", group = gD)
c3 = input.color(color.new(#ff9800, 0), "Volatile range", group = gD)

// ───────────────────────────── 2. State discretisation ─────────────────────────────
netMove = math.abs(close - close[erLen])
pathLen = math.sum(math.abs(close - close[1]), erLen)
er      = pathLen > 0 ? netMove / pathLen : 0.0
atrV    = ta.atr(volLen)
atrPct  = ta.percentrank(atrV, rankLen)
dirUp   = close > close[erLen]
// 0 trend up, 1 trend down, 2 quiet range, 3 volatile range
state   = er > erThr ? (dirUp ? 0 : 1) : (atrPct < volThr ? 2 : 3)
stName(int s) => s == 0 ? "Trend up" : s == 1 ? "Trend down" : s == 2 ? "Quiet range" : "Volatile range"
stCol(int s)  => s == 0 ? c0 : s == 1 ? c1 : s == 2 ? c2 : c3

// ───────────────────────────── 3. Rolling transition counts ─────────────────────────────
var int[]   seq = array.new_int()
var float[] cnt = array.new_float(16, 0.0)
var int runLen = 0
runLen := state == state[1] ? runLen + 1 : 1

if not na(state)
    array.push(seq, state)
    n = array.size(seq)
    if n >= 2
        a = array.get(seq, n - 2)
        b = array.get(seq, n - 1)
        array.set(cnt, a * 4 + b, array.get(cnt, a * 4 + b) + 1)
    if n > window + 1
        a0 = array.get(seq, 0)
        b0 = array.get(seq, 1)
        array.set(cnt, a0 * 4 + b0, math.max(0.0, array.get(cnt, a0 * 4 + b0) - 1))
        array.shift(seq)

// transition probabilities
float[] rowTot = array.new_float(4, 0.0)
for i = 0 to 3
    float t = 0.0
    for j = 0 to 3
        t += array.get(cnt, i * 4 + j)
    array.set(rowTot, i, t)
prob(int i, int j) =>
    rt = array.get(rowTot, i)
    rt > 0 ? array.get(cnt, i * 4 + j) / rt : 0.25

// stationary distribution by power iteration
float[] pi = array.new_float(4, 0.25)
for it = 1 to iters
    float[] nx = array.new_float(4, 0.0)
    for j = 0 to 3
        float s = 0.0
        for i = 0 to 3
            s += array.get(pi, i) * prob(i, j)
        array.set(nx, j, s)
    for j = 0 to 3
        array.set(pi, j, array.get(nx, j))

// entropy rate (bits per transition) and predictability
float hRate = 0.0
for i = 0 to 3
    float hi = 0.0
    for j = 0 to 3
        p = prob(i, j)
        if p > 0
            hi -= p * math.log(p) / math.log(2)
    hRate += array.get(pi, i) * hi
predict = (1 - hRate / 2.0) * 100.0        // 2 bits = maximum entropy for 4 states

// current-state figures
pStay   = prob(state, state) * 100.0
dwell   = pStay < 100 ? 1.0 / (1.0 - pStay / 100.0) : 999.0
int   nextSt = 0
float nextP  = -1.0
for j = 0 to 3
    pj = prob(state, j)
    if pj > nextP
        nextP  := pj
        nextSt := j
// forecast made on the previous bar vs what happened
hit     = nextSt[1] == state ? 1.0 : 0.0
hitRate = ta.sma(hit, hitLen) * 100.0
baseRate = 25.0

// ───────────────────────────── 4. Plots ─────────────────────────────
plot(pStay, "Stay probability %", color.new(color.white, 0), 2)
plot(predict, "Chain predictability %", color.new(#ffeb3b, 0), 1)
plot(hitRate, "Forecast hit rate %", color.new(#00e5ff, 0), 1)
plot(nextP * 100.0, "Next-state probability %", color.new(#e040fb, 30), 1, plot.style_circles)
hline(50, "50", color.new(color.gray, 60), hline.style_dotted)
hline(baseRate, "Random (25%)", color.new(color.gray, 60), hline.style_dashed)
plot(state * 10.0 + 5.0, "State lane", stCol(state), 3, plot.style_circles)
bgcolor(showBg ? color.new(stCol(state), 92) : na)
plot(state, "State code", display = display.data_window)
plot(er, "Efficiency ratio", display = display.data_window)
plot(atrPct, "ATR percentile", display = display.data_window)
plot(runLen, "Bars in state", display = display.data_window)
plot(hRate, "Entropy rate (bits)", display = display.data_window)

// ───────────────────────────── 5. Table ─────────────────────────────
var table tbl = na
pc(float x) => str.tostring(x * 100.0, "#.#") + "%"
cell(int c, int r, string s, color tc = color.white, color bg = na) =>
    table.cell(tbl, c, r, s, text_color = tc, bgcolor = bg, text_size = size.small)
hdrRow(int r, string a, string b) =>
    cell(0, r, a, color.white, color.new(color.gray, 40))
    table.merge_cells(tbl, 1, r, 5, r)
    cell(1, r, b)
heat(float p) => color.new(color.from_gradient(p, 0.0, 0.8, #1e222d, #ff9800), 0)
if showTbl and barstate.islast
    pos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : position.bottom_left
    if na(tbl)
        tbl := table.new(pos, 6, 14, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
    cell(0, 0, "from \\ to", color.white, color.new(color.gray, 40))
    for j = 0 to 3
        cell(j + 1, 0, stName(j), stCol(j), color.new(color.gray, 40))
    cell(5, 0, "n", color.white, color.new(color.gray, 40))
    for i = 0 to 3
        cell(0, i + 1, stName(i), stCol(i), i == state ? color.new(stCol(i), 75) : na)
        for j = 0 to 3
            p = prob(i, j)
            cell(j + 1, i + 1, pc(p), i == j ? color.white : color.new(color.white, 20), heat(p))
        cell(5, i + 1, str.tostring(array.get(rowTot, i), "#"))
    cell(0, 5, "Stationary share", color.white, color.new(color.gray, 40))
    for j = 0 to 3
        cell(j + 1, 5, pc(array.get(pi, j)), stCol(j))
    cell(5, 5, "")
    cell(0, 6, "Expected dwell (bars)", color.white, color.new(color.gray, 40))
    for j = 0 to 3
        pj = prob(j, j)
        cell(j + 1, 6, str.tostring(pj < 1 ? 1.0 / (1.0 - pj) : 999, "#.#"))
    cell(5, 6, "")
    hdrRow(7, "Current state", stName(state) + "  (" + str.tostring(runLen) + " bars, expected dwell " + str.tostring(dwell, "#.#") + ")")
    hdrRow(8, "Most likely next state", stName(nextSt) + "  " + pc(nextP))
    hdrRow(9, "Stay probability", pc(pStay / 100.0))
    hdrRow(10, "Entropy rate", str.tostring(hRate, "#.##") + " bits  (predictability " + str.tostring(predict, "#") + "%)")
    hdrRow(11, "Forecast hit rate", str.tostring(hitRate, "#.#") + "% over " + str.tostring(hitLen) + " bars  (random 25%)")
    hdrRow(12, "Transitions counted", str.tostring(array.sum(rowTot), "#") + " of max " + str.tostring(window))
    hdrRow(13, "Features", "ER " + str.tostring(er, "#.##") + " (thr " + str.tostring(erThr, "#.##") + ")   ATR pct " + str.tostring(atrPct, "#") + " (thr " + str.tostring(volThr, "#") + ")")

// ───────────────────────────── 6. Alerts (informational) ─────────────────────────────
stChange = state != state[1]
alertcondition(stChange, "State changed", "Markov Regime: market state changed")
alertcondition(stChange and state == 0, "Entered trend up", "Markov Regime: entered Trend up state")
alertcondition(stChange and state == 1, "Entered trend down", "Markov Regime: entered Trend down state")
alertcondition(stChange and state == 2, "Entered quiet range", "Markov Regime: entered Quiet range state")
alertcondition(stChange and state == 3, "Entered volatile range", "Markov Regime: entered Volatile range state")
````
