# Mark Minervini Trend Template VCP Breakout [Jayadev Rana]

- url: https://www.tradingview.com/script/3hvdaUOO-Mark-Minervini-Trend-Template-VCP-Breakout-Jayadev-Rana/
- type: indicator
- pine_id: PUB;74f25ae4e03644fabf569a875d8c8bab
- version: 1.0

## Description

WHAT IT IS

A long-side signal indicator that implements a classic stage-two momentum method: a strict trend template decides whether the symbol is in a healthy uptrend at all, a volatility-contraction base decides whether it is ready, and a volume-confirmed close through the base pivot prints the BUY. Every BUY is printed with its stop-loss and target, the levels are drawn as lines until the signal resolves, and each exit is labelled with its result in percent and R-multiples. A checklist table shows the eight template points live and a journal table keeps running statistics.

THE EIGHT-POINT TREND TEMPLATE

1. Price above the medium (150) and long (200) averages.
2. Medium average above the long average.
3. Long average rising over the last month (bars input).
4. Short (50) average above both longer averages.
5. Price above the short average.
6. Price at least X% above its 52-week low (default 25).
7. Price within X% of its 52-week high (default 25).
8. Relative strength rank at or above a threshold (default 70): the symbol's return over the lookback minus the benchmark's return, ranked against the last 52 weeks. The benchmark is chosen automatically by asset class or can be set.
The number of points required is an input (default seven of eight, so one weak point is tolerated; set eight for the strict version).

THE CONTRACTION BASE

Three nested windows (full base, half, quarter) are measured as high-low depth in percent. The base qualifies when each window is tighter than the one before it and the final contraction is below a maximum (default 12%), and when 5-bar volume is not above a ratio of 50-bar volume (default 1.2, i.e. volume is not expanding inside the base). The base is drawn as a box with a label giving the three contraction depths, the volume ratio and the pivot.

SIGNAL, STOP AND TARGET

BUY: a close above the base pivot (highest high of the base) that is not extended more than a few percent above it (default 8%), on volume at least the 50-bar average (multiplier input, default 1.0). Stop-loss: the base low, but never further than the maximum stop percentage (default 8%). Target: a fixed percentage above entry (default 20%). The signal is closed when the stop or target is touched, or on a close below the short average. Exits are labelled STOP, TARGET or EXIT with the percent result and R-multiple.

ON THE CHART

Three moving averages, the 52-week high and low, the shaded template price zone (between the minimum distance above the low and the maximum distance below the high), the contraction box, the pivot line, labels when the template is gained or lost, entry / stop / target lines from entry to exit with risk and reward fills, BUY and exit labels, and two tables: the live checklist and the signal journal (signals, target and stop hits, win rate, average R, best and worst R, open signal R).

INPUTS

Trend template lengths and thresholds, benchmark and relative strength lookback, base window and contraction limits, volume ratios, maximum extension, stop and target percentages, moving-average exit, display toggles.

ALERTS

BUY, target hit, stop hit, moving-average exit, base qualified.

INTENDED USE

Daily charts of stocks and ETFs are the natural home of this method; it also runs on crypto and index futures. Signals are infrequent by design because every point must line up.

LIMITATIONS

All conditions are evaluated on confirmed bars. The statistics in the journal are counted from the signals visible on the loaded history and are not a backtest with costs or sizing. Relative strength depends on the benchmark chosen. Past signals do not predict future ones. This is an educational tool, not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
//  Mark Minervini Trend Template VCP Breakout [Jayadev Rana]
//  Signal indicator (long side). A symbol must pass an eight-point trend
//  template: moving-average stack, rising long average, distance from the
//  52-week low and high, and relative strength versus a benchmark. Inside
//  that uptrend the script looks for a volatility contraction base, where
//  nested windows contract progressively and volume dries up. A BUY prints
//  on a close through the base pivot on expanding volume. Each BUY carries
//  its stop-loss (base low, capped at a maximum percentage) and target
//  (percentage above entry); the trade is closed on the stop, the target or
//  a close below the short moving average.
// ============================================================================
indicator("Mark Minervini Trend Template VCP Breakout [Jayadev Rana]", shorttitle = "MMVCP", overlay = true, max_labels_count = 300, max_boxes_count = 100, max_lines_count = 300)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gT = "Trend template"
len50    = input.int(50, "Short average", minval = 5, group = gT)
len150   = input.int(150, "Medium average", minval = 20, group = gT)
len200   = input.int(200, "Long average", minval = 50, group = gT)
riseBars = input.int(21, "Long average must be rising over (bars)", minval = 5, maxval = 120, group = gT)
yearLen  = input.int(250, "52-week window (bars)", minval = 50, maxval = 500, group = gT)
lowPct   = input.float(25, "Min % above 52-week low", minval = 0, maxval = 200, step = 5, group = gT)
highPct  = input.float(25, "Max % below 52-week high", minval = 1, maxval = 60, step = 1, group = gT)
benchIn  = input.string("", "Benchmark for relative strength (blank = auto)", group = gT, tooltip = "Relative strength compares the symbol's return over the lookback with the benchmark's and ranks the spread against the last 52 weeks. Blank = an index chosen by asset class.")
rsLen    = input.int(63, "Relative strength lookback", minval = 10, maxval = 250, group = gT)
rsMin    = input.float(70, "Min relative strength rank (0-100)", minval = 0, maxval = 99, step = 5, group = gT)
minScore = input.int(7, "Template points required (of 8)", minval = 4, maxval = 8, group = gT)

gV = "Volatility contraction base"
baseLen  = input.int(40, "Base window (bars)", minval = 20, maxval = 250, group = gV, tooltip = "Three nested windows (full, half, quarter) are measured. Each must be tighter than the one before it.")
maxFinal = input.float(12, "Max final contraction %", minval = 1, maxval = 30, step = 0.5, group = gV)
dryRatio = input.float(1.2, "Volume dry-up ratio (5-bar / 50-bar)", minval = 0.2, maxval = 1.2, step = 0.05, group = gV)
volMult  = input.float(1.0, "Breakout volume (x 50-bar average)", minval = 0.5, maxval = 5, step = 0.1, group = gV)
maxExt   = input.float(8, "Max extension above pivot %", minval = 0.5, maxval = 20, step = 0.5, group = gV)

gR = "Stop and target"
stopPct  = input.float(8, "Max stop-loss %", minval = 1, maxval = 25, step = 0.5, group = gR)
useBaseLow = input.bool(true, "Use base low when tighter than max stop", group = gR)
tgtPct   = input.float(20, "Target %", minval = 5, maxval = 100, step = 1, group = gR)
exitMA   = input.bool(true, "Exit on close below short average", group = gR)
showTbl  = input.bool(true, "Checklist table", group = "Display")
showLvl  = input.bool(true, "Stop and target lines", group = "Display")

// ───────────────────────────── 2. Trend template ─────────────────────────────
sma50  = ta.sma(close, len50)
sma150 = ta.sma(close, len150)
sma200 = ta.sma(close, len200)
hi52   = ta.highest(high, yearLen)
lo52   = ta.lowest(low, yearLen)
autoBench = syminfo.type == "crypto" ? "CRYPTOCAP:TOTAL" : syminfo.type == "forex" ? "TVC:DXY" : "SP:SPX"
bench  = benchIn == "" ? autoBench : benchIn
bRaw   = request.security(bench, timeframe.period, close, lookahead = barmerge.lookahead_off)
bClose = fixnan(bRaw)
rsSpread = (close / close[rsLen] - 1) - (bClose / bClose[rsLen] - 1)
rsRank = ta.percentrank(rsSpread, yearLen)
c1 = close > sma150 and close > sma200
c2 = sma150 > sma200
c3 = sma200 > sma200[riseBars]
c4 = sma50 > sma150 and sma50 > sma200
c5 = close > sma50
c6 = close >= lo52 * (1 + lowPct / 100)
c7 = close >= hi52 * (1 - highPct / 100)
c8 = rsRank >= rsMin
score = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) + (c5 ? 1 : 0) + (c6 ? 1 : 0) + (c7 ? 1 : 0) + (c8 ? 1 : 0)
templateOk = score >= minScore

// ───────────────────────────── 3. Volatility contraction ─────────────────────────────
w2 = math.max(5, math.round(baseLen / 2))
w3 = math.max(3, math.round(baseLen / 4))
hh1 = ta.highest(high, baseLen)[1]
ll1 = ta.lowest(low, baseLen)[1]
hh2 = ta.highest(high, w2)[1]
ll2 = ta.lowest(low, w2)[1]
hh3 = ta.highest(high, w3)[1]
ll3 = ta.lowest(low, w3)[1]
d1 = hh1 > 0 ? (hh1 - ll1) / hh1 * 100 : na
d2 = hh2 > 0 ? (hh2 - ll2) / hh2 * 100 : na
d3 = hh3 > 0 ? (hh3 - ll3) / hh3 * 100 : na
contracting = d1 > d2 and d2 > d3 and d3 <= maxFinal
vol5  = ta.sma(volume, 5)
vol50 = ta.sma(volume, 50)
dryUp = vol50 > 0 ? vol5[1] <= vol50[1] * dryRatio : true
pivot = hh1
baseLow = ll3
breakout = close > pivot and close <= pivot * (1 + maxExt / 100) and (vol50 > 0 ? volume >= vol50 * volMult : true)
setup = templateOk and contracting and dryUp

// ───────────────────────────── 4. Signal state ─────────────────────────────
var int   pos = 0
var float entryPx = na
var float slPx = na
var float tpPx = na
var int   entryBar = 0
buySig = pos == 0 and setup and breakout and bar_index > yearLen
bool exitSig = false
string exitWhy = ""
if pos == 1
    if low <= slPx
        exitSig := true
        exitWhy := "STOP"
    else if high >= tpPx
        exitSig := true
        exitWhy := "TARGET"
    else if exitMA and close < sma50
        exitSig := true
        exitWhy := "MA EXIT"
if exitSig
    pos := 0
if buySig
    pos := 1
    entryPx := close
    maxStop = close * (1 - stopPct / 100)
    slPx := useBaseLow ? math.max(maxStop, baseLow * 0.995) : maxStop
    tpPx := close * (1 + tgtPct / 100)
    entryBar := bar_index
inPos = pos == 1

// ───────────────────────────── 5. Visuals ─────────────────────────────
cUp = color.new(#26a69a, 0)
cDn = color.new(#ef5350, 0)
f(float x) => str.tostring(x, format.mintick)
plot(sma50, "Short average", color.new(#2962ff, 0), 1)
plot(sma150, "Medium average", color.new(#ff9800, 0), 1)
plot(sma200, "Long average", color.new(#ef5350, 0), 2)
plot(setup and pos == 0 ? pivot : na, "Base pivot", color.new(#ffeb3b, 0), 1, plot.style_linebr)
pSL = plot(showLvl and inPos ? slPx : na, "Stop-loss", cDn, 1, plot.style_linebr)
pTP = plot(showLvl and inPos ? tpPx : na, "Target", cUp, 1, plot.style_linebr)
pEN = plot(showLvl and inPos ? entryPx : na, "Entry", color.new(color.gray, 20), 1, plot.style_linebr)
fill(pEN, pTP, color.new(cUp, 90), "Reward")
fill(pEN, pSL, color.new(cDn, 90), "Risk")
plotshape(buySig, "BUY", shape.labelup, location.belowbar, cUp, text = "BUY", textcolor = color.white, size = size.small)
plotshape(exitSig and exitWhy == "TARGET", "TARGET HIT", shape.labeldown, location.abovebar, cUp, text = "TP", textcolor = color.white, size = size.small)
plotshape(exitSig and exitWhy == "STOP", "STOP HIT", shape.labeldown, location.abovebar, cDn, text = "SL", textcolor = color.white, size = size.small)
plotshape(exitSig and exitWhy == "MA EXIT", "MA EXIT", shape.labeldown, location.abovebar, color.new(#ffeb3b, 0), text = "EXIT", textcolor = color.black, size = size.small)
bgcolor(setup and pos == 0 ? color.new(#ffeb3b, 92) : templateOk ? color.new(cUp, 95) : na)
// context: 52-week frame and the template price zone
plot(hi52, "52-week high", color.new(#ff9800, 40), 1, plot.style_stepline)
plot(lo52, "52-week low", color.new(#ef5350, 60), 1, plot.style_stepline)
pZlo = plot(lo52 * (1 + lowPct / 100), "Template zone floor", color.new(color.gray, 70), 1, plot.style_stepline)
pZhi = plot(hi52 * (1 - highPct / 100), "Template zone ceiling", color.new(color.gray, 70), 1, plot.style_stepline)
fill(pZlo, pZhi, color.new(cUp, 96), "Template price zone")
// the contraction base as a box with its measurements
var box baseBox = na
if setup and not setup[1]
    baseBox := box.new(bar_index - baseLen, hh1, bar_index, ll1, border_color = color.new(#ffeb3b, 30), bgcolor = color.new(#ffeb3b, 92))
    label.new(bar_index, hh1, "VCP base " + str.tostring(baseLen) + " bars\ncontractions " + str.tostring(d1, "#") + "% > " + str.tostring(d2, "#") + "% > " + str.tostring(d3, "#.#") + "%\nvolume " + (vol50 > 0 ? str.tostring(vol5 / vol50, "#.##") : "-") + "x average\npivot " + f(pivot), style = label.style_label_down, color = color.new(#ffeb3b, 30), textcolor = color.black, size = size.small)
else if setup and not na(baseBox)
    box.set_right(baseBox, bar_index)
if templateOk and not templateOk[1]
    label.new(bar_index, low, "Trend template " + str.tostring(score) + "/8\nRS rank " + str.tostring(rsRank, "#"), style = label.style_label_up, color = color.new(cUp, 55), textcolor = color.white, size = size.tiny)
if not templateOk and templateOk[1]
    label.new(bar_index, high, "Template lost (" + str.tostring(score) + "/8)", style = label.style_label_down, color = color.new(cDn, 55), textcolor = color.white, size = size.tiny)
if buySig
    label.new(bar_index, low, "BUY " + f(close) + "\nSL " + f(slPx) + "  (" + str.tostring((close / slPx - 1) * 100, "#.#") + "%)\nTP " + f(tpPx) + "  (+" + str.tostring(tgtPct, "#") + "%)", style = label.style_label_up, color = color.new(cUp, 20), textcolor = color.white, size = size.small, yloc = yloc.belowbar)
plot(score, "Template score", display = display.data_window)
plot(d3, "Final contraction %", display = display.data_window)
plot(rsRank, "RS rank", display = display.data_window)
plot(pos, "In trade", display = display.data_window)

sellSig = false

// ───────────────────────────── Trade journal: lines from entry to exit, result labels, running statistics ─────────────────────────────
var line  lnE = na
var line  lnS = na
var line  lnT = na
var int   nSig = 0
var int   nWin = 0
var int   nLoss = 0
var float sumR = 0.0
var float bestR = 0.0
var float worstR = 0.0
var int   sigDir = 0
var float sigEntry = na
var float sigRisk = na
var float jSL = na
var float jTP = na
entered = buySig or sellSig
if exitSig and not na(sigEntry)
    exitPx = exitWhy == "TARGET" ? jTP : exitWhy == "STOP" ? jSL : close
    r = sigRisk > 0 ? (sigDir == 1 ? exitPx - sigEntry : sigEntry - exitPx) / sigRisk : 0.0
    pct = (sigDir == 1 ? exitPx / sigEntry - 1 : 1 - exitPx / sigEntry) * 100
    sumR += r
    bestR := math.max(bestR, r)
    worstR := math.min(worstR, r)
    if r > 0
        nWin += 1
    else
        nLoss += 1
    label.new(bar_index, sigDir == 1 ? high : low, exitWhy + "\n" + (pct >= 0 ? "+" : "") + str.tostring(pct, "#.##") + "%  " + str.tostring(r, "#.##") + "R", style = sigDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(r >= 0 ? cUp : cDn, 30), textcolor = color.white, size = size.small)
    if not na(lnE)
        line.set_x2(lnE, bar_index)
        line.set_x2(lnS, bar_index)
        line.set_x2(lnT, bar_index)
if entered
    nSig += 1
    sigDir := pos
    sigEntry := entryPx
    sigRisk := math.abs(entryPx - slPx)
    jSL := slPx
    jTP := tpPx
    lnE := line.new(bar_index, entryPx, bar_index + 1, entryPx, color = color.new(color.gray, 0), style = line.style_dashed)
    lnS := line.new(bar_index, slPx, bar_index + 1, slPx, color = cDn, width = 2)
    lnT := line.new(bar_index, tpPx, bar_index + 1, tpPx, color = cUp, width = 2)
else if inPos
    jSL := slPx
    jTP := tpPx
    if not na(lnE)
        line.set_x2(lnE, bar_index + 1)
        line.set_x2(lnS, bar_index + 1)
        line.set_x2(lnT, bar_index + 1)
        line.set_y1(lnS, slPx)
        line.set_y2(lnS, slPx)
        line.set_y1(lnT, tpPx)
        line.set_y2(lnT, tpPx)
openR = inPos and sigRisk > 0 ? (sigDir == 1 ? close - sigEntry : sigEntry - close) / sigRisk : na
plot(openR, "Open signal R", display = display.data_window)
var table jt = na
jrow(int r, string a, string b, color tc = color.white) =>
    table.cell(jt, 0, r, a, text_color = color.new(color.white, 20), text_halign = text.align_left, text_size = size.small)
    table.cell(jt, 1, r, b, text_color = tc, text_size = size.small)
if showTbl and barstate.islast
    if na(jt)
        jt := table.new(position.bottom_right, 2, 6, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
    closedN = nWin + nLoss
    jrow(0, "Signals on chart", str.tostring(nSig) + "  (" + str.tostring(closedN) + " closed)")
    jrow(1, "Target hits / stop hits", str.tostring(nWin) + " / " + str.tostring(nLoss), nWin >= nLoss ? cUp : cDn)
    jrow(2, "Win rate", closedN > 0 ? str.tostring(nWin / closedN * 100, "#.#") + "%" : "-")
    jrow(3, "Average R per signal", closedN > 0 ? str.tostring(sumR / closedN, "#.##") + "R  (total " + str.tostring(sumR, "#.#") + "R)" : "-")
    jrow(4, "Best / worst", closedN > 0 ? str.tostring(bestR, "#.#") + "R / " + str.tostring(worstR, "#.#") + "R" : "-")
    jrow(5, "Open signal", inPos ? str.tostring(openR, "#.##") + "R so far" : "none", inPos ? (openR >= 0 ? cUp : cDn) : color.white)

var table tbl = na
row(int r, string a, bool ok, string v) =>
    table.cell(tbl, 0, r, a, text_color = color.new(color.white, 20), text_halign = text.align_left, text_size = size.small)
    table.cell(tbl, 1, r, ok ? "PASS" : "fail", text_color = ok ? cUp : cDn, text_size = size.small)
    table.cell(tbl, 2, r, v, text_color = color.white, text_size = size.small)
if showTbl and barstate.islast
    if na(tbl)
        tbl := table.new(position.top_right, 3, 14, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
    row(0, "Price above medium and long avg", c1, "")
    row(1, "Medium avg above long avg", c2, "")
    row(2, "Long avg rising", c3, str.tostring((sma200 / sma200[riseBars] - 1) * 100, "#.##") + "%")
    row(3, "Short avg above both", c4, "")
    row(4, "Price above short avg", c5, "")
    row(5, "Above 52-week low", c6, str.tostring((close / lo52 - 1) * 100, "#") + "%")
    row(6, "Near 52-week high", c7, str.tostring((1 - close / hi52) * 100, "#") + "% below")
    row(7, "Relative strength rank", c8, str.tostring(rsRank, "#"))
    row(8, "Template score", templateOk, str.tostring(score) + " / 8")
    row(9, "Contractions tightening", contracting, str.tostring(d1, "#") + " > " + str.tostring(d2, "#") + " > " + str.tostring(d3, "#.#") + "%")
    row(10, "Volume dry-up", dryUp, vol50 > 0 ? str.tostring(vol5 / vol50, "#.##") + "x" : "-")
    row(11, "Pivot / base low", setup, f(pivot) + " / " + f(baseLow))
    row(12, "Trade", inPos, inPos ? "LONG from " + f(entryPx) : "no open signal")
    row(13, "Stop / target", inPos, inPos ? f(slPx) + " / " + f(tpPx) : "-")

// ───────────────────────────── 6. Alerts ─────────────────────────────
alertcondition(buySig, "BUY", "Trend Template VCP: BUY breakout")
alertcondition(exitSig and exitWhy == "TARGET", "Target hit", "Trend Template VCP: target reached")
alertcondition(exitSig and exitWhy == "STOP", "Stop hit", "Trend Template VCP: stop-loss hit")
alertcondition(exitSig and exitWhy == "MA EXIT", "MA exit", "Trend Template VCP: close below short average, exit")
alertcondition(setup and not setup[1], "Base qualified", "Trend Template VCP: contraction base qualified, watch the pivot")
````
