# Richard Dennis Turtle Breakout System [Jayadev Rana]

- url: https://www.tradingview.com/script/9SjoOwFl-Richard-Dennis-Turtle-Breakout-System-Jayadev-Rana/
- type: indicator
- pine_id: PUB;c7c004930e7b457c90117889b677ac62
- version: 1.0

## Description

WHAT IT IS

A channel-breakout trend-following signal indicator in the tradition of the famous 1980s trading experiment: enter on a breakout of an N-bar price channel, size and manage the position in units of volatility (N), add units as the trend extends, and exit on a shorter reverse channel. Every BUY and SELL is printed with its stop-loss and target, unit adds are marked with the new stop, the levels are drawn as lines until the signal resolves, and every exit is labelled with its result.

HOW IT WORKS

1. Systems. System 1 signals on a 20-bar breakout and exits on a 10-bar reverse breakout; System 2 uses 55 and 20; custom lengths are available. N is a 20-bar average true range.
2. Signals. BUY when the high exceeds the highest high of the previous entry-channel bars; SELL when the low breaks the lowest low. The entry price is the channel edge. An optional skip rule ignores a System 1 breakout when the previous breakout was a winner.
3. Stop-loss and target. Stop = entry minus two N (input). Target = entry plus a chosen number of N (default six). The original rules relied on the exit channel instead of a target; the target here is an addition so that every signal shows a reward level.
4. Unit adds. Every half N (input) in the signal's favour another unit is marked, up to the maximum, and the stop for the whole position moves to two N below the newest unit. A circle and a label show each add with the new stop.
5. Exits. The active stop is the closer of the N-based stop and the exit channel. The signal closes on that stop, or on the target. Exit labels say STOP, CHANNEL or TARGET.

ON THE CHART

Entry channel lines with a shaded channel, exit channel circles, 2N bands around price for scale, next-unit level circles while a signal is open, breakout labels with N and the exit channel value, BUY / SELL labels with entry, stop and target, entry / stop / target lines with risk and reward fills, add labels, exit labels, a status table (system, N, breakout levels, open signal and units, stop and target, next add) and the journal table (signals, hits, win rate, average R, best and worst, open signal R).

INPUTS

System choice and custom lengths, N length, skip rule, long and short switches, stop distance, target distance, add step, maximum units, display toggles.

ALERTS

BUY, SELL, add unit, target hit, stop hit, channel exit.

INTENDED USE

Daily and 4-hour charts of futures, forex, crypto and trending stocks. Trend following takes many small stops and a few large winners; the journal table makes that profile visible.

LIMITATIONS

Breakouts are known only when price trades through the channel, so a live fill may differ from the printed channel price. The journal counts signals on the loaded history without costs or sizing. Educational tool, not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
//  Richard Dennis Turtle Breakout System [Jayadev Rana]
//  Signal indicator. Channel breakouts with volatility-based unit adds.
//  System 1 signals on a 20-bar breakout and exits on a 10-bar reverse
//  breakout; System 2 uses 55 and 20. N is a 20-bar average true range.
//  Each BUY / SELL carries a stop-loss two N from the entry and a target
//  measured in N. A unit is added every half N in the signal's favour (up
//  to a maximum) and the stop moves to two N below the newest unit. The
//  signal is closed on the stop, on the exit-channel breakout, or on the
//  target.
// ============================================================================
indicator("Richard Dennis Turtle Breakout System [Jayadev Rana]", shorttitle = "RDTB", overlay = true, max_labels_count = 300, max_lines_count = 300)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gS = "System"
sysMode  = input.string("System 1 (20 / 10)", "System", options = ["System 1 (20 / 10)", "System 2 (55 / 20)", "Custom"], group = gS)
cEntry   = input.int(20, "Custom entry channel", minval = 5, maxval = 500, group = gS)
cExit    = input.int(10, "Custom exit channel", minval = 3, maxval = 500, group = gS)
nLen     = input.int(20, "N length (ATR)", minval = 5, maxval = 100, group = gS)
useFilter = input.bool(false, "System 1 skip rule: ignore the breakout after a winning breakout", group = gS, tooltip = "The original System 1 skipped an entry when the previous System 1 breakout had been profitable.")
allowL   = input.bool(true, "Long signals", group = gS)
allowS   = input.bool(true, "Short signals", group = gS)

gR = "Units, stop and target"
stopN    = input.float(2.0, "Stop-loss distance (N)", minval = 0.5, maxval = 10, step = 0.5, group = gR)
tgtN     = input.float(6.0, "Target distance (N)", minval = 1, maxval = 30, step = 0.5, group = gR, tooltip = "The original system had no fixed target and relied on the exit channel. The target here is an addition so every signal shows a reward level.")
addN     = input.float(0.5, "Add a unit every (N)", minval = 0.25, maxval = 5, step = 0.25, group = gR)
maxUnits = input.int(4, "Max units", minval = 1, maxval = 5, group = gR)
showTbl  = input.bool(true, "Status table", group = "Display")
showLvl  = input.bool(true, "Stop and target lines", group = "Display")

// ───────────────────────────── 2. Channels and N ─────────────────────────────
entryLen = sysMode == "System 1 (20 / 10)" ? 20 : sysMode == "System 2 (55 / 20)" ? 55 : cEntry
exitLen  = sysMode == "System 1 (20 / 10)" ? 10 : sysMode == "System 2 (55 / 20)" ? 20 : cExit
N     = ta.atr(nLen)
entHi = ta.highest(high, entryLen)[1]
entLo = ta.lowest(low, entryLen)[1]
exHi  = ta.highest(high, exitLen)[1]
exLo  = ta.lowest(low, exitLen)[1]

// ───────────────────────────── 3. Signal state ─────────────────────────────
var int   pos = 0
var int   units = 0
var float lastAdd = na
var float entryPx = na
var float slPx = na
var float tpPx = na
var bool  lastWin = false
bool exitSig = false
string exitWhy = ""
bool addSig = false
skip = useFilter and sysMode == "System 1 (20 / 10)" and lastWin

if pos != 0
    chanStop = pos == 1 ? math.max(slPx, exLo) : math.min(slPx, exHi)
    hitStop = pos == 1 ? low <= chanStop : high >= chanStop
    hitTP = pos == 1 ? high >= tpPx : low <= tpPx
    if hitStop
        exitSig := true
        exitWhy := pos == 1 ? (exLo > slPx ? "CHANNEL" : "STOP") : (exHi < slPx ? "CHANNEL" : "STOP")
    else if hitTP
        exitSig := true
        exitWhy := "TARGET"
    else if units < maxUnits
        addPx = pos == 1 ? lastAdd + addN * N : lastAdd - addN * N
        if pos == 1 ? high >= addPx : low <= addPx
            addSig := true
            units += 1
            lastAdd := addPx
            slPx := pos == 1 ? addPx - stopN * N : addPx + stopN * N
if exitSig
    lastWin := exitWhy == "TARGET" or (pos == 1 ? close > entryPx : close < entryPx)
    pos := 0
    units := 0
buySig  = pos == 0 and allowL and not skip and high > entHi
sellSig = pos == 0 and allowS and not skip and low < entLo and not buySig
if buySig
    pos := 1
    units := 1
    entryPx := entHi
    lastAdd := entHi
    slPx := entHi - stopN * N
    tpPx := entHi + tgtN * N
if sellSig
    pos := -1
    units := 1
    entryPx := entLo
    lastAdd := entLo
    slPx := entLo + stopN * N
    tpPx := entLo - tgtN * N
inPos = pos != 0
activeStop = pos == 1 ? math.max(slPx, exLo) : pos == -1 ? math.min(slPx, exHi) : na

// ───────────────────────────── 4. Visuals ─────────────────────────────
cUp = color.new(#26a69a, 0)
cDn = color.new(#ef5350, 0)
f(float x) => str.tostring(x, format.mintick)
pCH = plot(entHi, "Entry channel high", color.new(cUp, 30), 1)
pCL = plot(entLo, "Entry channel low", color.new(cDn, 30), 1)
fill(pCH, pCL, color.new(color.gray, 94), "Entry channel")
plot(inPos and units < maxUnits ? (pos == 1 ? lastAdd + addN * N : lastAdd - addN * N) : na, "Next unit level", color.new(#ffeb3b, 20), 1, plot.style_circles)
plot(close + stopN * N, "Upper N band (2N)", color.new(color.gray, 85), 1)
plot(close - stopN * N, "Lower N band (2N)", color.new(color.gray, 85), 1)
if addSig
    label.new(bar_index, pos == 1 ? low : high, "ADD unit " + str.tostring(units) + " @ " + f(lastAdd) + "\nstop -> " + f(slPx), style = pos == 1 ? label.style_label_up : label.style_label_down, color = color.new(#ffeb3b, 30), textcolor = color.black, size = size.tiny)
if buySig or sellSig
    label.new(bar_index, buySig ? high : low, str.tostring(entryLen) + "-bar breakout\nN " + f(N) + "  exit channel " + f(buySig ? exLo : exHi), style = buySig ? label.style_label_down : label.style_label_up, color = color.new(color.gray, 40), textcolor = color.white, size = size.tiny)
plot(exHi, "Exit channel high", color.new(cDn, 70), 1, plot.style_circles)
plot(exLo, "Exit channel low", color.new(cUp, 70), 1, plot.style_circles)
pSL = plot(showLvl and inPos ? activeStop : na, "Stop-loss (active)", cDn, 2, plot.style_linebr)
pTP = plot(showLvl and inPos ? tpPx : na, "Target", cUp, 1, plot.style_linebr)
pEN = plot(showLvl and inPos ? entryPx : na, "Entry", color.new(color.gray, 20), 1, plot.style_linebr)
fill(pEN, pTP, color.new(cUp, 90), "Reward")
fill(pEN, pSL, color.new(cDn, 90), "Risk")
plotshape(buySig, "BUY", shape.labelup, location.belowbar, cUp, text = "BUY", textcolor = color.white, size = size.small)
plotshape(sellSig, "SELL", shape.labeldown, location.abovebar, cDn, text = "SELL", textcolor = color.white, size = size.small)
plotshape(addSig, "ADD UNIT", shape.circle, location.absolute, color.new(#ffeb3b, 0), size = size.tiny)
plotshape(exitSig and exitWhy == "TARGET", "TARGET HIT", shape.circle, location.abovebar, cUp, text = "TP", textcolor = cUp, size = size.tiny)
plotshape(exitSig and exitWhy == "STOP", "STOP HIT", shape.circle, location.belowbar, cDn, text = "SL", textcolor = cDn, size = size.tiny)
plotshape(exitSig and exitWhy == "CHANNEL", "CHANNEL EXIT", shape.xcross, location.absolute, color.new(#ffeb3b, 0), size = size.tiny)
if buySig
    label.new(bar_index, low, "BUY " + f(entHi) + "\nSL " + f(slPx) + "  (" + str.tostring(stopN, "#.#") + "N)\nTP " + f(tpPx) + "  (" + str.tostring(tgtN, "#.#") + "N)", style = label.style_label_up, color = color.new(cUp, 20), textcolor = color.white, size = size.small)
if sellSig
    label.new(bar_index, high, "SELL " + f(entLo) + "\nSL " + f(slPx) + "  (" + str.tostring(stopN, "#.#") + "N)\nTP " + f(tpPx) + "  (" + str.tostring(tgtN, "#.#") + "N)", style = label.style_label_down, color = color.new(cDn, 20), textcolor = color.white, size = size.small)
plot(N, "N (ATR)", display = display.data_window)
plot(units, "Units", display = display.data_window)
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
    row(0, "System", str.tostring(entryLen) + " in / " + str.tostring(exitLen) + " out   N " + f(N))
    row(1, "Breakout levels", f(entHi) + " / " + f(entLo) + (skip ? "  (skipping after a winner)" : ""))
    row(2, "Signal", pos == 1 ? "LONG " + str.tostring(units) + " unit(s) from " + f(entryPx) : pos == -1 ? "SHORT " + str.tostring(units) + " unit(s) from " + f(entryPx) : "none open", pos == 1 ? cUp : pos == -1 ? cDn : color.white)
    row(3, "Stop / target", inPos ? f(activeStop) + " / " + f(tpPx) : "-")
    row(4, "Next add", inPos and units < maxUnits ? f(pos == 1 ? lastAdd + addN * N : lastAdd - addN * N) : inPos ? "max units" : "-")
    row(5, "Last breakout", lastWin ? "winner" : "loser or none")

// ───────────────────────────── 5. Alerts ─────────────────────────────
alertcondition(buySig, "BUY", "Turtle Breakout: BUY breakout")
alertcondition(sellSig, "SELL", "Turtle Breakout: SELL breakout")
alertcondition(addSig, "Add unit", "Turtle Breakout: add a unit")
alertcondition(exitSig and exitWhy == "TARGET", "Target hit", "Turtle Breakout: target reached")
alertcondition(exitSig and exitWhy == "STOP", "Stop hit", "Turtle Breakout: stop-loss hit")
alertcondition(exitSig and exitWhy == "CHANNEL", "Channel exit", "Turtle Breakout: exit-channel breakout")
````
