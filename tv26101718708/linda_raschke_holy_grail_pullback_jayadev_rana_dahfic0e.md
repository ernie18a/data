# Linda Raschke Holy Grail Pullback [Jayadev Rana]

- url: https://www.tradingview.com/script/DAHFic0E-Linda-Raschke-Holy-Grail-Pullback-Jayadev-Rana/
- type: indicator
- pine_id: PUB;f7f04d9f2f894724846c7f05b575dc67
- version: 1.0

## Description

WHAT IT IS

A trend-pullback signal indicator built on a well-known ADX pullback setup: wait for a strong and still-rising ADX, let price retrace to the 20-period average, and enter when price turns back in the trend direction through the touch bar's extreme. Every BUY and SELL is printed with its stop-loss and swing target, the levels are drawn as lines until the signal resolves, and every exit is labelled with its result. Labels on the trend start and on each pullback touch show the numbers behind the setup.

HOW IT WORKS

1. Trend. ADX (default 14) must be above the minimum (default 30) and higher than it was a few bars ago, and optionally +DI must be above -DI for longs (-DI above +DI for shorts). The background is tinted while a trend qualifies and a label marks the bar where it started, with ADX and both DI values.
2. Pullback touch. In an uptrend, the first bar whose low reaches the 20-period average after closing above it is the setup bar. A label shows the trigger (the touch bar high), the stop candidate, the swing target and the reward-to-risk ratio.
3. Trigger. BUY when a later bar trades above the touch bar high within the valid window (default 5 bars). While waiting, the stop candidate follows the lowest low of the pullback. The setup is cancelled if the window expires or price closes below the pullback low. Shorts are mirrored.
4. Stop and target. Stop-loss = pullback extreme minus an ATR buffer. Target = the highest high of the bars before the pullback (default 20-bar lookback). Setups whose reward-to-risk is below a minimum are skipped.
5. Exits. Stop or target; after the target is reached the remainder of the signal can trail until a close back through the average.

ON THE CHART

The pullback average coloured by trend, a slower average with a trend ribbon fill, the prior swing high and low as step lines, pending trigger circles, setup triangles, BUY / SELL labels with entry, stop and target, entry / stop / target lines with risk and reward fills, exit labels, a status table (ADX, trend, setup, stop and target, reward-to-risk) and the journal table (signals, hits, win rate, average R, best and worst, open signal R).

INPUTS

ADX length, minimum and rising bars, DI agreement, average length and type, setup validity, swing lookback, stop buffer, minimum reward-to-risk, long and short switches, trail after target, display toggles.

ALERTS

Long setup, short setup, BUY, SELL, target hit, stop hit, average exit.

INTENDED USE

Any liquid market from 15-minute to daily charts. The method needs a trending market; in ranges ADX stays low and the indicator prints nothing.

LIMITATIONS

ADX lags, so the first pullback of a trend can be missed. Targets at the prior swing can be close, which the reward-to-risk filter handles. Journal statistics count the signals on the loaded history without costs or sizing. Educational tool, not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
//  Linda Raschke Holy Grail Pullback [Jayadev Rana]
//  Signal indicator. A strong, rising ADX defines the trend; the first
//  retrace that touches the 20-period average is the setup; the trigger is
//  a move above the high (long) or below the low (short) of the touch bar.
//  Each BUY / SELL carries a stop-loss beyond the pullback extreme and a
//  target at the swing extreme that preceded the pullback. The signal is
//  closed on the stop, on the target, or on a close back through the
//  average after the target.
// ============================================================================
indicator("Linda Raschke Holy Grail Pullback [Jayadev Rana]", shorttitle = "LRHG", overlay = true, max_labels_count = 300, max_lines_count = 300)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gT = "Trend"
adxLen   = input.int(14, "ADX length", minval = 2, maxval = 100, group = gT)
adxMin   = input.float(30, "ADX minimum", minval = 10, maxval = 60, step = 1, group = gT)
riseBars = input.int(3, "ADX rising over (bars)", minval = 1, maxval = 20, group = gT)
useDI    = input.bool(true, "Require directional index agreement (+DI / -DI)", group = gT)
maLen    = input.int(20, "Pullback average length", minval = 5, maxval = 200, group = gT)
maType   = input.string("EMA", "Average type", options = ["EMA", "SMA"], group = gT)

gE = "Setup and trigger"
validBars = input.int(5, "Setup valid for (bars)", minval = 1, maxval = 30, group = gE)
swingLen  = input.int(20, "Prior swing lookback for the target", minval = 5, maxval = 100, group = gE)
bufAtr    = input.float(0.25, "Stop buffer beyond the pullback (ATR x)", minval = 0, maxval = 2, step = 0.05, group = gE)
minRR     = input.float(1.0, "Minimum reward to risk", minval = 0.2, maxval = 5, step = 0.1, group = gE, tooltip = "Setups whose target is closer than this many risk units are skipped.")
allowL    = input.bool(true, "Long signals", group = gE)
allowS    = input.bool(true, "Short signals", group = gE)
trailMA   = input.bool(true, "After the target, exit on a close through the average", group = gE)
showTbl   = input.bool(true, "Status table", group = "Display")
showLvl   = input.bool(true, "Stop and target lines", group = "Display")

// ───────────────────────────── 2. Trend and pullback ─────────────────────────────
[diP, diM, adx] = ta.dmi(adxLen, adxLen)
ma  = maType == "EMA" ? ta.ema(close, maLen) : ta.sma(close, maLen)
atr = ta.atr(14)
adxOk   = adx > adxMin and adx > adx[riseBars]
trendUp = adxOk and (not useDI or diP > diM)
trendDn = adxOk and (not useDI or diM > diP)
touchL = trendUp and low <= ma and close[1] > ma[1] and high > ma
touchS = trendDn and high >= ma and close[1] < ma[1] and low < ma
priorHi = ta.highest(high, swingLen)[1]
priorLo = ta.lowest(low, swingLen)[1]

// ───────────────────────────── 3. Setup and signal state ─────────────────────────────
var int   setupDir = 0
var int   setupBar = 0
var float trigPx = na
var float pullExt = na
var float swingTgt = na
var int   pos = 0
var float entryPx = na
var float slPx = na
var float tpPx = na
var bool  tpHit = false
bool exitSig = false
string exitWhy = ""

// manage an open signal first
if pos != 0
    hitSL = pos == 1 ? low <= slPx : high >= slPx
    hitTP = pos == 1 ? high >= tpPx : low <= tpPx
    if hitSL
        exitSig := true
        exitWhy := "STOP"
    else if hitTP and not tpHit
        tpHit := true
        if not trailMA
            exitSig := true
            exitWhy := "TARGET"
    else if trailMA and tpHit and (pos == 1 ? close < ma : close > ma)
        exitSig := true
        exitWhy := "MA EXIT"
if exitSig
    pos := 0

// arm a setup on the touch bar
if pos == 0 and touchL and allowL
    setupDir := 1
    setupBar := bar_index
    trigPx := high
    pullExt := low
    swingTgt := priorHi
else if pos == 0 and touchS and allowS
    setupDir := -1
    setupBar := bar_index
    trigPx := low
    pullExt := high
    swingTgt := priorLo
// keep the pullback extreme while waiting (bars after the touch bar)
if pos == 0 and setupDir == 1 and bar_index > setupBar
    pullExt := math.min(pullExt, low)
if pos == 0 and setupDir == -1 and bar_index > setupBar
    pullExt := math.max(pullExt, high)
stopCand = setupDir == 1 ? pullExt - bufAtr * atr : setupDir == -1 ? pullExt + bufAtr * atr : na
riskCand = setupDir == 1 ? trigPx - stopCand : setupDir == -1 ? stopCand - trigPx : na
rewardCand = setupDir == 1 ? swingTgt - trigPx : setupDir == -1 ? trigPx - swingTgt : na
rrOk = riskCand > 0 and rewardCand >= minRR * riskCand

// trigger on a later bar
buySig  = pos == 0 and setupDir == 1 and bar_index > setupBar and high >= trigPx and rrOk
sellSig = pos == 0 and setupDir == -1 and bar_index > setupBar and low <= trigPx and rrOk
if buySig or sellSig
    pos := buySig ? 1 : -1
    entryPx := trigPx
    slPx := stopCand
    tpPx := swingTgt
    tpHit := false
    setupDir := 0
// expiry / invalidation of a waiting setup
if pos == 0 and setupDir != 0 and (bar_index - setupBar > validBars or (setupDir == 1 and close < pullExt) or (setupDir == -1 and close > pullExt))
    setupDir := 0
inPos = pos != 0

// ───────────────────────────── 4. Visuals ─────────────────────────────
cUp = color.new(#26a69a, 0)
cDn = color.new(#ef5350, 0)
f(float x) => str.tostring(x, format.mintick)
plot(ma, "Pullback average", trendUp ? cUp : trendDn ? cDn : color.new(color.gray, 30), 2)
plot(pos == 0 and setupDir != 0 ? trigPx : na, "Pending trigger", color.new(#ffeb3b, 0), 1, plot.style_circles)
pSL = plot(showLvl and inPos ? slPx : na, "Stop-loss", cDn, 1, plot.style_linebr)
pTP = plot(showLvl and inPos ? tpPx : na, "Target", cUp, 1, plot.style_linebr)
pEN = plot(showLvl and inPos ? entryPx : na, "Entry", color.new(color.gray, 20), 1, plot.style_linebr)
fill(pEN, pTP, color.new(cUp, 90), "Reward")
fill(pEN, pSL, color.new(cDn, 90), "Risk")
plotshape(touchL and pos == 0, "Long setup", shape.triangleup, location.belowbar, color.new(cUp, 50), size = size.tiny)
plotshape(touchS and pos == 0, "Short setup", shape.triangledown, location.abovebar, color.new(cDn, 50), size = size.tiny)
plotshape(buySig, "BUY", shape.labelup, location.belowbar, cUp, text = "BUY", textcolor = color.white, size = size.small)
plotshape(sellSig, "SELL", shape.labeldown, location.abovebar, cDn, text = "SELL", textcolor = color.white, size = size.small)
plotshape(exitSig and exitWhy == "TARGET", "TARGET HIT", shape.circle, location.abovebar, cUp, text = "TP", textcolor = cUp, size = size.tiny)
plotshape(tpHit and not tpHit[1] and trailMA, "Target reached", shape.circle, location.abovebar, cUp, text = "TP", textcolor = cUp, size = size.tiny)
plotshape(exitSig and exitWhy == "STOP", "STOP HIT", shape.circle, location.belowbar, cDn, text = "SL", textcolor = cDn, size = size.tiny)
plotshape(exitSig and exitWhy == "MA EXIT", "EXIT", shape.xcross, location.absolute, color.new(#ffeb3b, 0), size = size.tiny)
bgcolor(trendUp ? color.new(cUp, 94) : trendDn ? color.new(cDn, 94) : na)
// context: slow average ribbon and the prior swing levels used as targets
maSlow = maType == "EMA" ? ta.ema(close, maLen * 2) : ta.sma(close, maLen * 2)
pFast = plot(ma, "Pullback average (ribbon)", na)
pSlow = plot(maSlow, "Slow average", color.new(color.gray, 50), 1)
fill(pFast, pSlow, color.new(trendUp ? cUp : trendDn ? cDn : color.gray, 90), "Trend ribbon")
plot(priorHi, "Prior swing high", color.new(cUp, 55), 1, plot.style_stepline)
plot(priorLo, "Prior swing low", color.new(cDn, 55), 1, plot.style_stepline)
if trendUp and not trendUp[1]
    label.new(bar_index, low, "Trend UP\nADX " + str.tostring(adx, "#.#") + "  +DI " + str.tostring(diP, "#") + " / -DI " + str.tostring(diM, "#"), style = label.style_label_up, color = color.new(cUp, 55), textcolor = color.white, size = size.tiny)
if trendDn and not trendDn[1]
    label.new(bar_index, high, "Trend DOWN\nADX " + str.tostring(adx, "#.#") + "  +DI " + str.tostring(diP, "#") + " / -DI " + str.tostring(diM, "#"), style = label.style_label_down, color = color.new(cDn, 55), textcolor = color.white, size = size.tiny)
if (touchL or touchS) and pos == 0
    label.new(bar_index, touchL ? low : high, "Pullback touch\ntrigger " + f(trigPx) + "\nstop " + f(stopCand) + "\ntarget " + f(swingTgt) + (riskCand > 0 ? "\nRR " + str.tostring(rewardCand / riskCand, "#.#") : ""), style = touchL ? label.style_label_up : label.style_label_down, color = color.new(#ffeb3b, 30), textcolor = color.black, size = size.tiny)
if buySig
    label.new(bar_index, low, "BUY " + f(entryPx) + "\nSL " + f(slPx) + "\nTP " + f(tpPx), style = label.style_label_up, color = color.new(cUp, 20), textcolor = color.white, size = size.small)
if sellSig
    label.new(bar_index, high, "SELL " + f(entryPx) + "\nSL " + f(slPx) + "\nTP " + f(tpPx), style = label.style_label_down, color = color.new(cDn, 20), textcolor = color.white, size = size.small)
plot(adx, "ADX", display = display.data_window)
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
    row(0, "ADX", str.tostring(adx, "#.#") + (adxOk ? "  strong and rising" : "  weak or falling"), adxOk ? cUp : color.white)
    row(1, "Trend", trendUp ? "UP" : trendDn ? "DOWN" : "none", trendUp ? cUp : trendDn ? cDn : color.white)
    row(2, "Setup", setupDir == 1 ? "long, trigger " + f(trigPx) : setupDir == -1 ? "short, trigger " + f(trigPx) : "waiting for a touch of the average", setupDir == 1 ? cUp : setupDir == -1 ? cDn : color.white)
    row(3, "Signal", pos == 1 ? "LONG from " + f(entryPx) : pos == -1 ? "SHORT from " + f(entryPx) : "none open", pos == 1 ? cUp : pos == -1 ? cDn : color.white)
    row(4, "Stop / target", inPos ? f(slPx) + " / " + f(tpPx) + (tpHit ? "  (target reached, trailing)" : "") : setupDir != 0 ? f(stopCand) + " / " + f(swingTgt) : "-")
    row(5, "Reward to risk", setupDir != 0 and riskCand > 0 ? str.tostring(rewardCand / riskCand, "#.##") : inPos ? str.tostring(math.abs(tpPx - entryPx) / math.abs(entryPx - slPx), "#.##") : "-")

// ───────────────────────────── 5. Alerts ─────────────────────────────
alertcondition(touchL and pos == 0, "Long setup", "Holy Grail Pullback: long setup armed")
alertcondition(touchS and pos == 0, "Short setup", "Holy Grail Pullback: short setup armed")
alertcondition(buySig, "BUY", "Holy Grail Pullback: BUY triggered")
alertcondition(sellSig, "SELL", "Holy Grail Pullback: SELL triggered")
alertcondition((exitSig and exitWhy == "TARGET") or (tpHit and not tpHit[1]), "Target hit", "Holy Grail Pullback: target reached")
alertcondition(exitSig and exitWhy == "STOP", "Stop hit", "Holy Grail Pullback: stop-loss hit")
alertcondition(exitSig and exitWhy == "MA EXIT", "MA exit", "Holy Grail Pullback: closed through the average, exit")
````
