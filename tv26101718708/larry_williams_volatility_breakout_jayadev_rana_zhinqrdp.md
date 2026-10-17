# Larry Williams Volatility Breakout [Jayadev Rana]

- url: https://www.tradingview.com/script/ZHInQrDP-Larry-Williams-Volatility-Breakout-Jayadev-Rana/
- type: indicator
- pine_id: PUB;1f0f148477594b26ae35c4b1eab3c18b
- version: 1.0

## Description

WHAT IT IS

A short-term range-expansion signal indicator built on the classic volatility-breakout idea: project a band above and below the bar open at a fraction of the recent range, and treat the first trade through the band as the start of an expansion day. Every BUY and SELL is printed with a stop-loss and a target measured in range units, the levels are drawn as lines until the signal resolves, and every exit is labelled with its result in percent and R-multiples. A status table and a journal table complete the picture.

HOW IT WORKS

1. Reference range. Previous bar range (default), the average range of the last N bars, or an N-bar average true range.
2. Trigger band. Upper trigger = open + k x range; lower trigger = open - k x range (k default 0.5). The band is drawn every bar as circles with shaded zones above and below the open.
3. Signals. BUY when the bar's high reaches the upper trigger; SELL when the low reaches the lower trigger. The entry price is the trigger itself. Optional filters: trade only with the moving-average trend, and require the previous bar to be narrow or an inside bar (compression before expansion).
4. Stop and target. Stop-loss = entry minus (stop multiple x range); target = entry plus (target multiple x range); mirrored for shorts.
5. Exits. The signal closes on the stop, on the target, at the first bar that opens in profit (the bail-out rule, optional) or after a maximum number of bars. Exit labels say which one.

ON THE CHART

Trigger band with shaded zones, optional trend average, diamonds on range-expansion bars (range at least twice the reference), markers on narrow bars when that filter is on, coloured signal bars, BUY / SELL labels with entry, stop and target, entry / stop / target lines with risk and reward fills, exit labels, the status table (range, triggers, filters, open signal, bars held) and the journal table (signals, target and stop hits, win rate, average R, best and worst, open signal R).

INPUTS

Range multiple, reference range mode and N, long and short switches, trend filter and length, narrow-bar filter, stop and target multiples, bail-out, maximum holding bars, display toggles.

ALERTS

BUY, SELL, target hit, stop hit, bail-out or time exit.

INTENDED USE

Daily charts of futures, index CFDs, forex and crypto, and intraday charts of liquid instruments. Short holding periods: the method is about catching the expansion, not riding a trend.

LIMITATIONS

The band is computed from the bar open, so the signal is only known once price has travelled to the band; the printed entry is the band price, which a live order may not get exactly. Statistics in the journal count the signals on the loaded history without costs or sizing. Choppy, low-range markets produce many stop hits. Educational tool, not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
//  Larry Williams Volatility Breakout [Jayadev Rana]
//  Signal indicator. A trigger band is projected from the bar open at a
//  fraction of the reference range (previous bar range, N-bar average or
//  ATR). The first bar that trades through the upper band prints BUY, the
//  first through the lower band prints SELL, each with a range-based
//  stop-loss and target. The signal is closed at the first profitable open
//  (bail-out), on the stop, on the target or after a maximum holding time.
// ============================================================================
indicator("Larry Williams Volatility Breakout [Jayadev Rana]", shorttitle = "LWVB", overlay = true, max_labels_count = 300, max_lines_count = 300)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gS = "Breakout band"
k        = input.float(0.5, "Range multiple (k)", minval = 0.1, maxval = 2, step = 0.05, group = gS, tooltip = "Trigger distance from the open = k x reference range.")
rngMode  = input.string("Previous bar", "Reference range", options = ["Previous bar", "Average of N bars", "True range average"], group = gS)
rngN     = input.int(3, "N for averages", minval = 2, maxval = 50, group = gS)
allowL   = input.bool(true, "Long signals", group = gS)
allowS   = input.bool(true, "Short signals", group = gS)

gF = "Filters"
useTrend = input.bool(false, "Only with the moving-average trend", group = gF)
trendLen = input.int(50, "Trend average length", minval = 5, maxval = 400, group = gF)
useNarrow = input.bool(false, "Require a narrow or inside previous bar", group = gF, tooltip = "Compression before expansion: previous range below its N-bar average, or an inside bar.")

gX = "Stop, target and exit"
stopMult = input.float(1.0, "Stop-loss (x range)", minval = 0.2, maxval = 5, step = 0.1, group = gX)
tgtMult  = input.float(1.5, "Target (x range)", minval = 0.2, maxval = 10, step = 0.1, group = gX)
bailout  = input.bool(true, "Close at the first profitable open", group = gX)
maxHold  = input.int(3, "Max holding bars", minval = 1, maxval = 50, group = gX)
showTbl  = input.bool(true, "Status table", group = "Display")
showLvl  = input.bool(true, "Stop and target lines", group = "Display")

// ───────────────────────────── 2. Band ─────────────────────────────
rngPrev = high[1] - low[1]
rngAvg  = ta.sma(high - low, rngN)[1]
rngTR   = ta.atr(rngN)[1]
rng = rngMode == "Previous bar" ? rngPrev : rngMode == "Average of N bars" ? rngAvg : rngTR
ma = ta.sma(close, trendLen)
trendL = not useTrend or close > ma
trendS = not useTrend or close < ma
avgRng = ta.sma(high - low, rngN)[2]
narrow = not useNarrow or rngPrev < avgRng or (high[1] <= high[2] and low[1] >= low[2])
upBand = open + k * rng
dnBand = open - k * rng
brkL = high >= upBand
brkS = low <= dnBand

// ───────────────────────────── 3. Signal state ─────────────────────────────
var int   pos = 0
var float entryPx = na
var float slPx = na
var float tpPx = na
var int   entryBar = 0
bool exitSig = false
string exitWhy = ""
if pos != 0
    profitOpen = pos == 1 ? open > entryPx : open < entryPx
    hitSL = pos == 1 ? low <= slPx : high >= slPx
    hitTP = pos == 1 ? high >= tpPx : low <= tpPx
    if hitSL
        exitSig := true
        exitWhy := "STOP"
    else if hitTP
        exitSig := true
        exitWhy := "TARGET"
    else if bailout and profitOpen
        exitSig := true
        exitWhy := "BAILOUT"
    else if bar_index - entryBar >= maxHold
        exitSig := true
        exitWhy := "TIME"
if exitSig
    pos := 0
buySig  = pos == 0 and allowL and trendL and narrow and brkL and not (brkS and close < open)
sellSig = pos == 0 and allowS and trendS and narrow and brkS and not buySig
if buySig
    pos := 1
    entryPx := upBand
    slPx := upBand - stopMult * rng
    tpPx := upBand + tgtMult * rng
    entryBar := bar_index
if sellSig
    pos := -1
    entryPx := dnBand
    slPx := dnBand + stopMult * rng
    tpPx := dnBand - tgtMult * rng
    entryBar := bar_index
inPos = pos != 0

// ───────────────────────────── 4. Visuals ─────────────────────────────
cUp = color.new(#26a69a, 0)
cDn = color.new(#ef5350, 0)
f(float x) => str.tostring(x, format.mintick)
pU = plot(upBand, "Upper trigger", color.new(cUp, 40), 1, plot.style_circles)
pD = plot(dnBand, "Lower trigger", color.new(cDn, 40), 1, plot.style_circles)
pO = plot(open, "Open reference", color.new(color.gray, 70), 1, plot.style_circles)
fill(pU, pO, color.new(cUp, 94), "Upper band")
fill(pO, pD, color.new(cDn, 94), "Lower band")
expansion = (high - low) >= 2 * rng
plotshape(expansion and not inPos, "Range expansion bar", shape.diamond, location.abovebar, color.new(#ffeb3b, 40), size = size.tiny)
plotchar(useNarrow and narrow and not inPos and not expansion, "Narrow or inside bar", "n", location.belowbar, color.new(#ffeb3b, 20), size = size.tiny)
barcolor(buySig ? cUp : sellSig ? cDn : na)
plot(useTrend ? ma : na, "Trend average", color.new(color.gray, 40), 1)
pSL = plot(showLvl and inPos ? slPx : na, "Stop-loss", cDn, 1, plot.style_linebr)
pTP = plot(showLvl and inPos ? tpPx : na, "Target", cUp, 1, plot.style_linebr)
pEN = plot(showLvl and inPos ? entryPx : na, "Entry", color.new(color.gray, 20), 1, plot.style_linebr)
fill(pEN, pTP, color.new(cUp, 90), "Reward")
fill(pEN, pSL, color.new(cDn, 90), "Risk")
plotshape(buySig, "BUY", shape.labelup, location.belowbar, cUp, text = "BUY", textcolor = color.white, size = size.small)
plotshape(sellSig, "SELL", shape.labeldown, location.abovebar, cDn, text = "SELL", textcolor = color.white, size = size.small)
plotshape(exitSig and exitWhy == "TARGET", "TARGET HIT", shape.circle, location.abovebar, cUp, text = "TP", textcolor = cUp, size = size.tiny)
plotshape(exitSig and exitWhy == "STOP", "STOP HIT", shape.circle, location.belowbar, cDn, text = "SL", textcolor = cDn, size = size.tiny)
plotshape(exitSig and (exitWhy == "BAILOUT" or exitWhy == "TIME"), "EXIT", shape.xcross, location.absolute, color.new(#ffeb3b, 0), size = size.tiny)
if buySig
    label.new(bar_index, low, "BUY " + f(upBand) + "\nSL " + f(slPx) + "\nTP " + f(tpPx), style = label.style_label_up, color = color.new(cUp, 20), textcolor = color.white, size = size.small)
if sellSig
    label.new(bar_index, high, "SELL " + f(dnBand) + "\nSL " + f(slPx) + "\nTP " + f(tpPx), style = label.style_label_down, color = color.new(cDn, 20), textcolor = color.white, size = size.small)
plot(rng, "Reference range", display = display.data_window)
plot(pos, "Signal state", display = display.data_window)


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
row(int r, string a, string b, color tc = color.white) =>
    table.cell(tbl, 0, r, a, text_color = color.new(color.white, 20), text_halign = text.align_left, text_size = size.small)
    table.cell(tbl, 1, r, b, text_color = tc, text_size = size.small)
if showTbl and barstate.islast
    if na(tbl)
        tbl := table.new(position.top_right, 2, 6, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
    row(0, "Reference range", f(rng) + "  (k " + str.tostring(k, "#.##") + ")")
    row(1, "Triggers this bar", f(upBand) + " / " + f(dnBand))
    row(2, "Filters", (trendL ? "long ok" : "long blocked") + " / " + (trendS ? "short ok" : "short blocked") + (narrow ? "" : " / waiting for narrow bar"))
    row(3, "Signal", pos == 1 ? "LONG from " + f(entryPx) : pos == -1 ? "SHORT from " + f(entryPx) : "none open", pos == 1 ? cUp : pos == -1 ? cDn : color.white)
    row(4, "Stop / target", inPos ? f(slPx) + " / " + f(tpPx) : "-")
    row(5, "Bars held", inPos ? str.tostring(bar_index - entryBar) + " of " + str.tostring(maxHold) : "-")

// ───────────────────────────── 5. Alerts ─────────────────────────────
alertcondition(buySig, "BUY", "Volatility Breakout: BUY")
alertcondition(sellSig, "SELL", "Volatility Breakout: SELL")
alertcondition(exitSig and exitWhy == "TARGET", "Target hit", "Volatility Breakout: target reached")
alertcondition(exitSig and exitWhy == "STOP", "Stop hit", "Volatility Breakout: stop-loss hit")
alertcondition(exitSig and (exitWhy == "BAILOUT" or exitWhy == "TIME"), "Exit", "Volatility Breakout: bail-out or time exit")
````
