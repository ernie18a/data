# Crossover Optimizer Heatmap [Quantum Algo]

- url: https://www.tradingview.com/script/VEvpsGHa-Crossover-Optimizer-Heatmap-Quantum-Algo/
- type: indicator
- pine_id: PUB;33d602a91a4a4111a6c18ba048deeea1
- version: 1.0

## Description

Crossover Optimizer Heatmap [Quantum Algo]

═══════════════════════════════════════════════

🔶 OVERVIEW

Crossover Optimizer Heatmap runs sixty-four exponential moving average crossover systems at the same time, bar by bar, on the exact chart you are looking at — and renders the results as a color heatmap. Every fast/slow pair in an eight-by-eight grid is traded as a simple flip system inside a test window; the grid lights up hot where a pair has worked on this symbol and timeframe and goes cold where it has not. The best pair is drawn live on the price chart with its crossovers, and a stability score tells you whether that winner sits on a plateau of good neighbors or on an isolated lucky spike.

The question every crossover trader asks — "which lengths should I use here?" — is usually answered by habit, forums, or a single backtest. This tool answers it with sixty-four backtests, visually, in one panel.

═══════════════════════════════════════════════

🔶 WHAT IS A MOVING AVERAGE CROSSOVER?

A moving average crossover system holds a long bias while a fast moving average sits above a slow one and a short bias while it sits below. The crossover itself is the trigger. It is one of the oldest trend-following methods in technical analysis, and its entire behavior is governed by two numbers: the fast length and the slow length. Choose them well and the system rides trends; choose them badly and it whipsaws to death. Which values are "good" is different on every symbol and timeframe — which is exactly what the heatmap measures.

═══════════════════════════════════════════════

🔶 WHAT IS PARAMETER SENSITIVITY — AND WHY THE PLATEAU MATTERS?

Systems trading practice, formalized by Robert Pardo, distinguishes between parameters that sit on a plateau — surrounded by neighbors that also perform well — and parameters that sit on a spike, surrounded by failure. A spike is usually curve fit: it worked on the past by coincidence and will not survive. A plateau reflects a genuine property of the market. This tool computes a Stability score for the winning pair from its eight grid neighbors and labels it Plateau, Ridge, or Spike, so you can see at a glance whether the best cell is worth trusting.

═══════════════════════════════════════════════

🔶 WHY IS THIS ORIGINAL?

1. Sixty-four simultaneous backtests on the chart. The grid engine maintains every system's position, entry and results in parallel, with no external tools and no strategy-tester runs — the entire optimization lives inside one indicator.

2. The heatmap as the interface. Results are rendered as a color grid — fast lengths across, slow lengths down — with a three-stop gradient from cold to hot, so parameter neighborhoods are visible as shapes, not as a list of numbers.

3. A stability score, not just a winner. The best pair is graded by how much of its edge its neighbors share, turning Pardo's plateau principle into a live reading.

4. The winner drawn on price. The best pair's two averages are plotted with a directional field between them and its crossovers marked, so the optimization result is immediately tradeable — and immediately visible if it changes.

5. A fixed test window for fair comparison. Every system starts flat at the window's first bar, so all sixty-four are judged on identical history; the metric is selectable (Net Return, Win Rate, Profit Factor) and pairs with too few trades are shown but not ranked.

═══════════════════════════════════════════════

🔶 HOW IT WORKS

— Eight fast and eight slow exponential averages are maintained from configurable start and step values.
— Inside the test window, every valid pair (fast shorter than slow) runs as a flip system: a cross opens a position in the new direction and closes the previous one at that bar's close; each closed trade's percentage return is recorded.
— At the last bar, every pair's metric is computed, the grid is colored between the worst and best ranked values, and the best pair is selected.
— The Stability score compares the average metric of the winner's neighbors against the grid's range.

Systems are evaluated on confirmed bars. Results do not repaint within the window; they naturally update as new bars enter the window and old bars leave it.

═══════════════════════════════════════════════

🔶 HOW TO USE IT

— Read shapes, not cells: a broad hot region means the symbol respects crossovers in that neighborhood; a single hot cell in a cold sea is a curve fit.
— Check Stability before adopting the winner: Plateau is the reading you want; Spike is the reading that will cost you.
— Compare metrics: a pair can lead on Net Return through one huge trend and trail on Win Rate; switching the metric shows the same grid from a different angle.
— Widen the window for robustness, narrow it to see the current regime; a pair that stays hot across both is the strongest evidence this tool can give.
— Works on all markets and timeframes.

═══════════════════════════════════════════════

🔶 SETTINGS

— Grid: fast start and step, slow start and step (eight values each).
— Test: window length, metric, minimum trades to rank.
— Visuals: best-pair overlay and crossover markers, heat colors.
— Heatmap Panel: visibility, position, text size.

═══════════════════════════════════════════════

🔶 ALERTS

— Best Pair Cross Up / Cross Down — the currently best-ranked pair crossed.

═══════════════════════════════════════════════

🔶 FAQ

Q: Is the best pair a prediction?
A: No. It is the pair that performed best on the test window of this chart — an in-sample result, stated as such in the panel footer. The Stability score exists precisely to warn you when that result is fragile.

Q: Does it repaint?
A: No. Every system is evaluated on confirmed bars. The grid updates as the test window rolls forward, which is the intended behavior of a rolling optimization, not a repaint of past signals.

Q: Why are some cells marked "~" or "·"?
A: "·" means the pair is invalid (fast is not shorter than slow). "~" means the pair produced fewer trades than the minimum and is displayed but not ranked, so a single lucky trade cannot become the best cell.

Q: Why exponential averages?
A: They respond faster and are computed recursively, which keeps sixty-four parallel systems light. The grid's purpose is to compare parameters under one consistent method.

Q: Can I trade the crossover markers directly?
A: They are the best pair's raw crossovers, shown so the optimization result is visible on price. Treat them as the system's signals with all the usual crossover limitations — whipsaws in ranges included — and apply your own risk management.

═══════════════════════════════════════════════

🔶 CREDITS

The moving average crossover is a classical technical-analysis method. Exponential smoothing originates in classical statistics (Robert G. Brown and Charles C. Holt). Parameter sensitivity analysis and the plateau-versus-spike principle come from systems trading practice, formalized by Robert Pardo in Design, Testing, and Optimization of Trading Systems (1992). The simultaneous grid engine, heatmap rendering, stability score, live best-pair overlay and all code in this script are original work — no third-party or open-source script code was reused.

═══════════════════════════════════════════════

🔶 LIMITATIONS

— All results are in-sample on the chosen window; past performance of a parameter pair never guarantees its future performance.
— The flip system is deliberately simple (no stops, no costs) so that pairs are compared on the crossover logic alone; real trading results will differ.
— Sixty-four parallel systems is a heavy computation; very long windows on low timeframes may load slowly.

═══════════════════════════════════════════════

🔶 DISCLAIMER

This indicator is a research and charting tool provided for educational purposes. It is not financial advice, and nothing it displays is a recommendation to buy or sell any asset. Trading involves substantial risk of loss. Always do your own analysis and manage risk responsibly.

## Source Code

````pine
//@version=6
indicator("Crossover Optimizer Heatmap [Quantum Algo]", overlay = true, max_lines_count = 50, max_labels_count = 100, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  CROSSOVER OPTIMIZER HEATMAP
//  Sixty-four exponential moving average crossover systems run
//  simultaneously, bar by bar, on the chart you are looking at.
//  Every fast/slow pair in the grid is traded as a simple flip
//  system inside a test window, and the results are rendered as a
//  color heatmap: which parameter neighborhoods have actually
//  worked on THIS symbol and timeframe, and which are dead. The
//  best pair is drawn live on price with its crossovers, and a
//  stability score tells you whether the winner sits on a plateau
//  or on a lucky spike.
//
//  Concept credits: the moving average crossover from classical
//  technical analysis · exponential smoothing from classical
//  statistics (Brown, Holt) · parameter sensitivity analysis and
//  the plateau-versus-spike principle from systems trading
//  practice, formalized by Robert Pardo (Design, Testing, and
//  Optimization of Trading Systems, 1992). The simultaneous grid
//  engine, heatmap rendering, stability score, live best-pair
//  overlay and all code are original work — no third-party or
//  open-source script code was reused.
// ════════════════════════════════════════════════════════════════

// ─── INPUTS ─────────────────────────────────────────────────────
grpG = "Grid · 8 × 8"
fStart = input.int(5, "Fast · Start", minval = 2, group = grpG)
fStep  = input.int(5, "Fast · Step", minval = 1, group = grpG)
sStart = input.int(30, "Slow · Start", minval = 5, group = grpG)
sStep  = input.int(20, "Slow · Step", minval = 1, group = grpG, tooltip = "Rows are slow lengths, columns are fast lengths. Eight steps each — sixty-four crossover systems tested at once.")

grpT = "Test"
testWin = input.int(500, "Test Window (Bars)", minval = 100, maxval = 4000, group = grpT, tooltip = "Only the most recent bars count. Every system starts flat at the window's first bar, so all sixty-four are judged on identical history.")
metricS = input.string("Net Return", "Metric", options = ["Net Return", "Win Rate", "Profit Factor"], group = grpT)
minTrades = input.int(5, "Minimum Trades To Rank", minval = 1, group = grpT)

grpV = "Visuals"
showBest = input.bool(true, "Draw Best Pair On Price", group = grpV)
showSigs = input.bool(true, "Best Pair Crossovers", group = grpV)
hotCol  = input.color(#00897b, "Hot", group = grpV)
midCol  = input.color(#c77800, "Neutral", group = grpV)
coldCol = input.color(#e4002b, "Cold", group = grpV)
bullCol = input.color(#00897b, "Bullish", group = grpV)
bearCol = input.color(#e4002b, "Bearish", group = grpV)

grpD = "Heatmap Panel"
showMap  = input.bool(true, "Show Heatmap", group = grpD)
mapPos   = input.string("Bottom Right", "Position", options = ["Bottom Right", "Bottom Left", "Top Right", "Top Left"], group = grpD)
mapSize  = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = grpD)

// ─── ENGINE · 64 systems in arrays ─────────────────────────────
N = 8
var array<float> emaF = array.new<float>(N, na)
var array<float> emaS = array.new<float>(N, na)
var array<int>   dirA = array.new<int>(N * N, 0)
var array<float> entA = array.new<float>(N * N, na)
var array<float> retA = array.new<float>(N * N, 0.0)
var array<float> gwA  = array.new<float>(N * N, 0.0)
var array<float> glA  = array.new<float>(N * N, 0.0)
var array<int>   trA  = array.new<int>(N * N, 0)
var array<int>   wnA  = array.new<int>(N * N, 0)

for i = 0 to N - 1
    lf = fStart + i * fStep
    ls = sStart + i * sStep
    af = 2.0 / (lf + 1)
    as_ = 2.0 / (ls + 1)
    pf_ = emaF.get(i)
    ps_ = emaS.get(i)
    emaF.set(i, na(pf_) ? close : af * close + (1 - af) * pf_)
    emaS.set(i, na(ps_) ? close : as_ * close + (1 - as_) * ps_)

winStart = last_bar_index - testWin + 1
inWin = bar_index >= winStart
if bar_index == winStart
    for k = 0 to N * N - 1
        dirA.set(k, 0)
        entA.set(k, na)
        retA.set(k, 0.0)
        gwA.set(k, 0.0)
        glA.set(k, 0.0)
        trA.set(k, 0)
        wnA.set(k, 0)

f_valid(int i, int j) => (fStart + i * fStep) < (sStart + j * sStep)

if barstate.isconfirmed and inWin
    for j = 0 to N - 1
        for i = 0 to N - 1
            if f_valid(i, j)
                k = j * N + i
                f = emaF.get(i)
                s_ = emaS.get(j)
                d = f > s_ ? 1 : f < s_ ? -1 : 0
                if d != 0 and d != dirA.get(k)
                    if dirA.get(k) != 0 and not na(entA.get(k))
                        r = (close / entA.get(k) - 1) * dirA.get(k) * 100
                        retA.set(k, retA.get(k) + r)
                        trA.set(k, trA.get(k) + 1)
                        if r > 0
                            wnA.set(k, wnA.get(k) + 1)
                            gwA.set(k, gwA.get(k) + r)
                        else
                            glA.set(k, glA.get(k) - r)
                    dirA.set(k, d)
                    entA.set(k, close)

f_metric(int k) =>
    n = trA.get(k)
    metricS == "Net Return" ? retA.get(k) : metricS == "Win Rate" ? (n > 0 ? wnA.get(k) * 100.0 / n : na) : (glA.get(k) > 0 ? gwA.get(k) / glA.get(k) : gwA.get(k) > 0 ? 9.99 : na)

// ─── RANKING + STABILITY ───────────────────────────────────────
var int bestI = 0
var int bestJ = N - 1
float mMin = na
float mMax = na
float bestV = na
for j = 0 to N - 1
    for i = 0 to N - 1
        if f_valid(i, j)
            k = j * N + i
            v = f_metric(k)
            if not na(v) and trA.get(k) >= minTrades
                mMin := na(mMin) ? v : math.min(mMin, v)
                mMax := na(mMax) ? v : math.max(mMax, v)
                if na(bestV) or v > bestV
                    bestV := v
                    bestI := i
                    bestJ := j
// plateau test: how much of the winner's edge its neighbors share
float nbSum = 0.0
int nbN = 0
for dj = -1 to 1
    for di = -1 to 1
        ii = bestI + di
        jj = bestJ + dj
        if (di != 0 or dj != 0) and ii >= 0 and ii < N and jj >= 0 and jj < N and f_valid(ii, jj)
            vv = f_metric(jj * N + ii)
            if not na(vv)
                nbSum += vv
                nbN += 1
nbAvg = nbN > 0 ? nbSum / nbN : na
stability = na(nbAvg) or na(bestV) or na(mMax) or na(mMin) or mMax == mMin ? na : math.max(0.0, math.min(1.0, (nbAvg - mMin) / (mMax - mMin)))
stabName = na(stability) ? "—" : stability >= 0.6 ? "Plateau" : stability >= 0.35 ? "Ridge" : "Spike"

// ─── LIVE BEST PAIR ON PRICE ───────────────────────────────────
bestF = emaF.get(bestI)
bestS = emaS.get(bestJ)
bestUp = bestF > bestS
pF = plot(showBest ? bestF : na, "Best Fast", color = color.new(bullCol, 0), linewidth = 2)
pS = plot(showBest ? bestS : na, "Best Slow", color = color.new(bearCol, 0), linewidth = 2)
fill(pF, pS, color = showBest ? color.new(bestUp ? bullCol : bearCol, 78) : na, title = "Crossover Field")
xUp = showSigs and ta.crossover(bestF, bestS)
xDn = showSigs and ta.crossunder(bestF, bestS)
plotshape(xUp, "Best Cross Up", shape.triangleup, location.belowbar, color.new(bullCol, 0), size = size.small)
plotshape(xDn, "Best Cross Down", shape.triangledown, location.abovebar, color.new(bearCol, 0), size = size.small)

// ─── THE HEATMAP ───────────────────────────────────────────────
tPos = mapPos == "Bottom Left" ? position.bottom_left : mapPos == "Top Right" ? position.top_right : mapPos == "Top Left" ? position.top_left : position.bottom_right
tSz = mapSize == "Tiny" ? size.tiny : mapSize == "Normal" ? size.normal : size.small
var table hm = table.new(tPos, N + 1, N + 2, bgcolor = color.new(#171207, 4), frame_color = color.new(#c77800, 20), frame_width = 1, border_color = color.new(#000000, 60), border_width = 1)
f_fmt(float v) => na(v) ? "" : metricS == "Net Return" ? (v >= 0 ? "+" : "") + str.tostring(v, "#") + "%" : metricS == "Win Rate" ? str.tostring(v, "#") + "%" : str.tostring(v, "#.#")
f_heat(float v) =>
    if na(v) or na(mMin) or na(mMax) or mMax == mMin
        color.new(#37474f, 70)
    else
        mid = (mMin + mMax) / 2
        v < mid ? color.from_gradient(v, mMin, mid, coldCol, midCol) : color.from_gradient(v, mid, mMax, midCol, hotCol)
if showMap and barstate.islast
    table.cell(hm, 0, 0, "◈ " + syminfo.ticker + " · " + timeframe.period + " · " + metricS, bgcolor = color.new(#ef9a13, 0), text_color = #1a1207, text_size = tSz, text_halign = text.align_left)
    for i = 0 to N - 1
        table.cell(hm, i + 1, 0, "F" + str.tostring(fStart + i * fStep), bgcolor = color.new(#ef9a13, 0), text_color = #1a1207, text_size = tSz)
    for j = 0 to N - 1
        table.cell(hm, 0, j + 1, "S" + str.tostring(sStart + j * sStep), bgcolor = color.new(#231a08, 0), text_color = color.new(#f0c05a, 0), text_size = tSz)
        for i = 0 to N - 1
            k = j * N + i
            ok = f_valid(i, j)
            v = ok ? f_metric(k) : na
            ranked = ok and not na(v) and trA.get(k) >= minTrades
            isBest = ok and i == bestI and j == bestJ
            table.cell(hm, i + 1, j + 1, not ok ? "·" : ranked ? f_fmt(v) : "~", bgcolor = ranked ? f_heat(v) : color.new(#37474f, 80), text_color = isBest ? #ffffff : ranked ? color.new(#ffffff, 15) : color.new(#eef2f7, 60), text_size = tSz, tooltip = not ok ? "Fast must be shorter than slow" : "Fast " + str.tostring(fStart + i * fStep) + " / Slow " + str.tostring(sStart + j * sStep) + "\n" + metricS + ": " + f_fmt(v) + " · Trades " + str.tostring(trA.get(k)) + (trA.get(k) > 0 ? " · Win " + str.tostring(wnA.get(k) * 100 / trA.get(k), "#") + "%" : "") + (ranked ? "" : "\nBelow minimum trades — not ranked"))
    table.cell(hm, 0, N + 1, "Best F" + str.tostring(fStart + bestI * fStep) + "/S" + str.tostring(sStart + bestJ * sStep) + " · " + f_fmt(bestV) + " · " + stabName + (na(stability) ? "" : " " + str.tostring(stability * 100, "#") + "%") + " · " + str.tostring(testWin) + " bars · in-sample, not a forecast", bgcolor = color.new(#231a08, 0), text_color = color.new(#cdb87e, 0), text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(hm, 0, N + 1, N, N + 1)

// ─── ALERTS ────────────────────────────────────────────────────
alertcondition(xUp, "Best Pair Cross Up", "The best-ranked crossover pair crossed bullish.")
alertcondition(xDn, "Best Pair Cross Down", "The best-ranked crossover pair crossed bearish.")
````
