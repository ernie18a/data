# Nicolas Darvas Box Breakout [Jayadev Rana]

- url: https://www.tradingview.com/script/SeHcB4CF-Nicolas-Darvas-Box-Breakout-Jayadev-Rana/
- type: indicator
- pine_id: PUB;a043072a6f15418d9b3e1f35be8f47a8
- version: 1.0

## Description

WHAT IT IS

A box-theory breakout signal indicator. A box forms when a high is not exceeded for a set number of bars (the top) and a later low is not undercut for the same number of bars (the bottom). A BUY prints when price breaks the box top, with the stop-loss just under the box bottom and a target at a multiple of the box height. As new boxes complete above the old ones the stop trails under each new bottom and add points are marked. Every signal carries its levels as lines until it resolves and every exit is labelled with its result.

HOW IT WORKS

1. Box construction. Hunting a top: the highest high so far becomes the candidate; when it survives the confirmation bars (default 3) it is fixed. Hunting a bottom: the lowest low after the top becomes the candidate; when it survives the confirmation bars the box is complete and drawn, with a label giving its height in percent, its levels and its length in bars. A top exceeded before the bottom confirms restarts the hunt.
2. Signals. BUY when price trades above a completed box top. Optional filters: a minimum box height and a requirement that the box sits within a percentage of the 52-week high. Short signals on breakdowns can be enabled (off by default; the original method was long only).
3. Stop-loss and target. Stop = box bottom minus a small buffer (default 0.5%). Target = box top plus a multiple of the box height (default 2x).
4. Trailing and adds. When a new box completes above the entry, the stop is raised under its bottom (never lowered). When price breaks a new box above the entry, an ADD marker and label print with the new stop, up to a maximum number of adds, and the target is raised to the new box's projection.
5. Exits. Stop or target, labelled with the percent and R result.

ON THE CHART

Boxes with their labels, box top and bottom lines while a box is complete, the 52-week high as a step line, BUY / SELL labels with entry, stop and target, entry / stop / target lines with risk and reward fills, add markers and labels, exit labels, a status table (box state and levels, breakout trigger, open signal and adds, stop and target, 52-week high) and the journal table (signals, hits, win rate, average R, best and worst, open signal R).

INPUTS

Confirmation bars, minimum box height, 52-week-high filter and window, short switch, stop buffer, target multiple, maximum adds, display toggles.

ALERTS

Box completed, BUY, SELL, add, target hit, stop hit.

INTENDED USE

Daily and weekly charts of stocks and crypto in strong uptrends, which is where the method was designed to work. It also runs on intraday charts, where boxes are smaller and more frequent.

LIMITATIONS

A box is only known after its confirmation bars, so a breakout immediately after a bottom confirms is the earliest possible signal. Narrow boxes in choppy markets produce frequent stops; the minimum height filter helps. The journal counts signals on the loaded history without costs or sizing. Educational tool, not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
//  Nicolas Darvas Box Breakout [Jayadev Rana]
//  Signal indicator. A box top is a high that is not exceeded for a set
//  number of bars; the box bottom is the following low that is not undercut
//  for the same number of bars. A BUY prints when price breaks the box top,
//  with the stop-loss just under the box bottom and a target at a multiple
//  of the box height. As new boxes complete above the old ones the stop is
//  trailed under each new bottom and ADD markers show pyramid points.
//  Long-only by default with an optional mirrored short side and an optional
//  52-week-high proximity filter.
// ============================================================================
indicator("Nicolas Darvas Box Breakout [Jayadev Rana]", shorttitle = "NDBB", overlay = true, max_boxes_count = 200, max_labels_count = 300, max_lines_count = 300)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gB = "Box rules"
confBars  = input.int(3, "Confirmation bars", minval = 2, maxval = 10, group = gB, tooltip = "A high becomes a box top when it is not exceeded for this many following bars; the bottom is confirmed the same way.")
minBoxPct = input.float(0, "Minimum box height % (0 = any)", minval = 0, maxval = 20, step = 0.5, group = gB)
nearHigh  = input.bool(false, "Only boxes near the 52-week high", group = gB)
nearPct   = input.float(10, "Within % of 52-week high", minval = 1, maxval = 50, step = 1, group = gB)
yearLen   = input.int(250, "52-week window (bars)", minval = 50, maxval = 500, group = gB)
allowS    = input.bool(false, "Short signals (mirror rules)", group = gB)

gR = "Stop and target"
stopBuf  = input.float(0.5, "Stop-loss below box bottom (%)", minval = 0, maxval = 5, step = 0.1, group = gR)
tgtMult  = input.float(2.0, "Target (x box height above the top)", minval = 0.5, maxval = 10, step = 0.5, group = gR)
maxAdds  = input.int(2, "Max ADD markers on new boxes", minval = 0, maxval = 5, group = gR)
showBoxes = input.bool(true, "Draw boxes", group = "Display")
showTbl   = input.bool(true, "Status table", group = "Display")
showLvl   = input.bool(true, "Stop and target lines", group = "Display")

// ───────────────────────────── 2. Box state machine ─────────────────────────────
var int   state  = 0            // 0 hunting a top, 1 hunting a bottom, 2 box complete
var float topC   = na
var int   topBar = 0
var int   topCnt = 0
var float botC   = na
var int   botCnt = 0
var float boxTop = na
var float boxBot = na
var int   boxStart = 0
var box   bx = na
bool newBox = false
bool brokeUp = false
bool brokeDn = false
lowWin = ta.lowest(low, confBars + 1)

if state == 0
    if na(topC) or high > topC
        topC := high
        topBar := bar_index
        topCnt := 0
    else
        topCnt += 1
    if topCnt >= confBars
        state := 1
        botC := lowWin
        botCnt := 0
else if state == 1
    if high > topC
        state := 0
        topC := high
        topBar := bar_index
        topCnt := 0
    else
        if low < botC
            botC := low
            botCnt := 0
        else
            botCnt += 1
        if botCnt >= confBars
            boxTop := topC
            boxBot := botC
            boxStart := topBar
            state := 2
            newBox := true
            if showBoxes
                bx := box.new(boxStart, boxTop, bar_index, boxBot, border_color = color.new(#2962ff, 20), bgcolor = color.new(#2962ff, 88))
else
    if high > boxTop
        brokeUp := true
        state := 0
        topC := high
        topBar := bar_index
        topCnt := 0
    else if low < boxBot
        brokeDn := true
        state := 0
        topC := high
        topBar := bar_index
        topCnt := 0
    else if not na(bx) and showBoxes
        box.set_right(bx, bar_index)

hi52 = ta.highest(high, yearLen)
// the box that was just broken (values from the previous bar's state)
bTop = boxTop[1]
bBot = boxBot[1]
boxValid = state[1] == 2 and (minBoxPct == 0 or (bTop - bBot) / bTop * 100 >= minBoxPct) and (not nearHigh or bTop >= hi52 * (1 - nearPct / 100))

// ───────────────────────────── 3. Signal state ─────────────────────────────
var int   pos = 0
var float entryPx = na
var float slPx = na
var float tpPx = na
var int   adds = 0
bool exitSig = false
string exitWhy = ""
bool addSig = false
if pos != 0
    hitSL = pos == 1 ? low <= slPx : high >= slPx
    hitTP = pos == 1 ? high >= tpPx : low <= tpPx
    if hitSL
        exitSig := true
        exitWhy := "STOP"
    else if hitTP
        exitSig := true
        exitWhy := "TARGET"
    else if pos == 1 and brokeUp and boxValid and bBot > entryPx and adds < maxAdds
        addSig := true
        adds += 1
        slPx := math.max(slPx, bBot * (1 - stopBuf / 100))
        tpPx := math.max(tpPx, bTop + tgtMult * (bTop - bBot))
    else if pos == -1 and brokeDn and boxValid and bTop < entryPx and adds < maxAdds
        addSig := true
        adds += 1
        slPx := math.min(slPx, bTop * (1 + stopBuf / 100))
        tpPx := math.min(tpPx, bBot - tgtMult * (bTop - bBot))
    else if newBox
        // trail under each newly completed box above the entry (never lower the stop)
        if pos == 1 and boxBot * (1 - stopBuf / 100) > slPx
            slPx := boxBot * (1 - stopBuf / 100)
        if pos == -1 and boxTop * (1 + stopBuf / 100) < slPx
            slPx := boxTop * (1 + stopBuf / 100)
if exitSig
    pos := 0
    adds := 0
buySig  = pos == 0 and brokeUp and boxValid
sellSig = pos == 0 and allowS and brokeDn and boxValid
if buySig
    pos := 1
    entryPx := bTop
    slPx := bBot * (1 - stopBuf / 100)
    tpPx := bTop + tgtMult * (bTop - bBot)
    adds := 0
if sellSig
    pos := -1
    entryPx := bBot
    slPx := bTop * (1 + stopBuf / 100)
    tpPx := bBot - tgtMult * (bTop - bBot)
    adds := 0
inPos = pos != 0

// ───────────────────────────── 4. Visuals ─────────────────────────────
cUp = color.new(#26a69a, 0)
cDn = color.new(#ef5350, 0)
f(float x) => str.tostring(x, format.mintick)
plot(state == 2 ? boxTop : na, "Box top", color.new(#2962ff, 0), 2, plot.style_linebr)
plot(state == 2 ? boxBot : na, "Box bottom", color.new(#2962ff, 0), 2, plot.style_linebr)
pSL = plot(showLvl and inPos ? slPx : na, "Stop-loss (trailing)", cDn, 1, plot.style_linebr)
pTP = plot(showLvl and inPos ? tpPx : na, "Target", cUp, 1, plot.style_linebr)
pEN = plot(showLvl and inPos ? entryPx : na, "Entry", color.new(color.gray, 20), 1, plot.style_linebr)
fill(pEN, pTP, color.new(cUp, 90), "Reward")
fill(pEN, pSL, color.new(cDn, 90), "Risk")
plotshape(buySig, "BUY", shape.labelup, location.belowbar, cUp, text = "BUY", textcolor = color.white, size = size.small)
plotshape(sellSig, "SELL", shape.labeldown, location.abovebar, cDn, text = "SELL", textcolor = color.white, size = size.small)
plotshape(addSig, "ADD", shape.circle, location.absolute, color.new(#ffeb3b, 0), size = size.tiny)
plotshape(exitSig and exitWhy == "TARGET", "TARGET HIT", shape.circle, location.abovebar, cUp, text = "TP", textcolor = cUp, size = size.tiny)
plotshape(exitSig and exitWhy == "STOP", "STOP HIT", shape.circle, location.belowbar, cDn, text = "SL", textcolor = cDn, size = size.tiny)
plotshape(newBox, "Box completed", shape.square, location.abovebar, color.new(#2962ff, 40), size = size.tiny)
plot(hi52, "52-week high", color.new(#ff9800, 40), 1, plot.style_stepline)
if newBox
    label.new(bar_index, boxTop, "Box " + str.tostring((boxTop - boxBot) / boxTop * 100, "#.#") + "%\n" + f(boxTop) + " / " + f(boxBot) + "\n" + str.tostring(bar_index - boxStart) + " bars", style = label.style_label_down, color = color.new(#2962ff, 40), textcolor = color.white, size = size.tiny)
if addSig
    label.new(bar_index, pos == 1 ? low : high, "ADD @ " + f(pos == 1 ? bTop : bBot) + "\nstop -> " + f(slPx), style = pos == 1 ? label.style_label_up : label.style_label_down, color = color.new(#ffeb3b, 30), textcolor = color.black, size = size.tiny)
if buySig
    label.new(bar_index, low, "BUY " + f(entryPx) + "\nSL " + f(slPx) + "\nTP " + f(tpPx), style = label.style_label_up, color = color.new(cUp, 20), textcolor = color.white, size = size.small)
if sellSig
    label.new(bar_index, high, "SELL " + f(entryPx) + "\nSL " + f(slPx) + "\nTP " + f(tpPx), style = label.style_label_down, color = color.new(cDn, 20), textcolor = color.white, size = size.small)
plot(state, "Box state", display = display.data_window)
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
    row(0, "Box state", state == 0 ? "hunting a top (" + str.tostring(topCnt) + "/" + str.tostring(confBars) + ")" : state == 1 ? "hunting a bottom (" + str.tostring(botCnt) + "/" + str.tostring(confBars) + ")" : "box complete")
    row(1, "Box top / bottom", state == 2 ? f(boxTop) + " / " + f(boxBot) : "-", state == 2 ? color.new(#2962ff, 0) : color.white)
    row(2, "Breakout trigger", state == 2 ? f(boxTop) : "-")
    row(3, "Signal", pos == 1 ? "LONG from " + f(entryPx) + " +" + str.tostring(adds) + " add(s)" : pos == -1 ? "SHORT from " + f(entryPx) + " +" + str.tostring(adds) + " add(s)" : "none open", pos == 1 ? cUp : pos == -1 ? cDn : color.white)
    row(4, "Stop / target", inPos ? f(slPx) + " / " + f(tpPx) : "-")
    row(5, "52-week high", f(hi52) + (nearHigh ? "  (filter on)" : ""))

// ───────────────────────────── 5. Alerts ─────────────────────────────
alertcondition(newBox, "Box completed", "Darvas Box: new box completed")
alertcondition(buySig, "BUY", "Darvas Box: BUY breakout")
alertcondition(sellSig, "SELL", "Darvas Box: SELL breakdown")
alertcondition(addSig, "Add", "Darvas Box: new box broken, add point")
alertcondition(exitSig and exitWhy == "TARGET", "Target hit", "Darvas Box: target reached")
alertcondition(exitSig and exitWhy == "STOP", "Stop hit", "Darvas Box: stop-loss hit")
````
