# Darvas Box Ladder [ITA]

- url: https://www.tradingview.com/script/6kCBXCdW-Darvas-Box-Ladder-ITA/
- type: indicator
- pine_id: PUB;e504562dd8e64a8a802b9543b64af2f0
- version: 1.0

## Description

🟠 OVERVIEW

Darvas Box Ladder plots the rectangle Nicolas Darvas traded, and then keeps plotting the ones that follow it. Darvas did not buy a box and sell it - he rode a ladder of them, staying in as each breakout built a new box higher and lifting his stop to the floor of the newest one. He got out when a box finally broke down.

The script builds each box the way Darvas built it, as a sequence of confirmations rather than a rectangle fitted after the fact, and keeps the completed rungs on the chart so the whole run stays visible.

🟠 CONCEPTS

A Darvas box has an order to it. The ceiling comes first: price makes a new high, and that high has to survive a set number of bars unbeaten before it counts. Only then does the floor form, from the lowest low printed since the ceiling, and it has to survive the same test.

That order matters. A rectangle drawn around any quiet stretch of price is just a consolidation range. A Darvas box is a leader pausing after a run to new highs, and the ceiling-then-floor sequence is what separates the two.

Because both levels come from confirmed structure, they are fixed once drawn and do not move afterwards.

🟠 FEATURES

🔹 The full ladder, not one box - completed rungs stay on the chart so you can see the whole advance rather than the current pause in isolation

🔹 Stop line under the active box - a dashed line at the floor, which is where Darvas kept his

🔹 Measured-move target - one box height projected above the ceiling

🔹 Volume-confirmed breakouts - a close above the ceiling only counts when volume beats its 20-bar average by your chosen multiple

🔹 Box under construction - a dashed ceiling shows while the box is still forming, so you can see one coming before it completes

🔹 New-high filter - boxes may only start from a high that is the highest of the lookback window, keeping the script on leaders instead of drawing rectangles inside downtrends

🔹 Height limits - boxes outside your minimum and maximum are discarded

🔹 Alerts on both the breakout and the box breaking down

🟠 HOW TO USE

Add it to a daily chart of a stock that has been making new highs - that is the setup Darvas was looking for, and the new-high filter will keep the script quiet on anything else.

Watch for the dashed ceiling. That is a box forming. When the floor confirms, the box turns solid and the stop line appears underneath it.

A green box with a triangle below the bar is a confirmed breakout on volume, and the next box begins from there. Each new rung is a chance to lift the stop to the newer, higher floor.

A red box marks the end of the run - price closed below the floor.

Confirmation Bars is the main setting. Darvas used 3. Higher values give fewer, cleaner boxes; lower values react faster and produce more of them.

🟠 CONCLUSION

The box is the easy part. The ladder is what Darvas actually traded, and it is what tells you whether a breakout is the start of a run or the end of one.

## Source Code

````pine
//@version=6
// =============================================================================
// Darvas Box Ladder [ITA]
//
// Nicolas Darvas did not trade a single box. He rode a LADDER of them: each
// time price broke out of one box and built the next one higher, he stayed in
// and lifted his stop to the floor of the newest box. He sold when a box
// finally broke down.
//
// Every Darvas script I could find draws one rectangle. This one draws the
// whole ladder, keeps the stop under the active box, and marks the box that
// ended the run.
//
// The box is built the way Darvas built it - a state machine, not a rectangle
// fitted after the fact:
//   1. Price makes a new high for the lookback  -> tentative ceiling
//   2. That high survives N bars unbeaten       -> ceiling confirmed
//   3. The lowest low after it survives N bars  -> floor confirmed, box is live
//   4. Close above the ceiling                  -> breakout, next rung begins
//   5. Close below the floor                    -> the ladder is over
//
// Levels are set from confirmed structure only and never move once drawn.
// =============================================================================

indicator("Darvas Box Ladder [ITA]", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─── Inputs ──────────────────────────────────────────────────────────────────
grpBox = "Box Construction"
confirmBars = input.int(3, "Confirmation Bars", minval = 1, maxval = 20, group = grpBox,
     tooltip = "How many bars a high must survive unbeaten before it becomes the ceiling, and the same for the floor. Darvas used 3.")
lookback = input.int(100, "New-High Lookback", minval = 20, maxval = 500, group = grpBox,
     tooltip = "A box may only start from a high that is the highest of this many bars. Darvas only traded leaders making new highs.")
minHeight = input.float(3.0, "Min Box Height %", minval = 0.5, maxval = 50, step = 0.5, group = grpBox)
maxHeight = input.float(25.0, "Max Box Height %", minval = 1.0, maxval = 100, step = 0.5, group = grpBox,
     tooltip = "Anything wider than this is a consolidation range, not a Darvas box.")

grpBreak = "Breakout"
breakBuffer = input.float(0.1, "Breakout Buffer %", minval = 0.0, maxval = 5.0, step = 0.05, group = grpBreak,
     tooltip = "How far above the ceiling a close must be to count as a breakout.")
markVolume = input.bool(true, "Mark Volume-Backed Breakouts", group = grpBreak,
     tooltip = "A close above the ceiling always ends the box - that is what a breakout is. This only controls whether breakouts that also came on heavy volume get a filled marker instead of a hollow one.")
volMult = input.float(1.5, "Volume x Average", minval = 1.0, maxval = 10, step = 0.1, group = grpBreak,
     tooltip = "Volume needed for a breakout to count as heavy, as a multiple of the 20-bar average.")

grpShow = "Display"
ladderDepth = input.int(6, "Rungs To Keep", minval = 1, maxval = 30, group = grpShow,
     tooltip = "How many completed boxes stay on the chart.")
showStop = input.bool(true, "Stop Line Under Active Box", group = grpShow)
showSteps = input.bool(true, "Rising Stop Staircase", group = grpShow,
     tooltip = "Draws where the stop sat at every rung of the current ladder, so the staircase Darvas climbed stays visible.")
showTarget = input.bool(true, "Measured-Move Target", group = grpShow,
     tooltip = "One box height projected above the ceiling.")
showLabels = input.bool(true, "Box Labels", group = grpShow)
showBuilding = input.bool(true, "Show Box Being Built", group = grpShow,
     tooltip = "Dashed ceiling line while the box is still forming.")

grpCol = "Colors"
liveCol = input.color(#E5C56B, "Active Box", group = grpCol)
breakCol = input.color(#089981, "Breakout", group = grpCol)
failCol = input.color(#F23645, "Box Broken", group = grpCol)
fillAlpha = input.int(88, "Box Fill Transparency", minval = 50, maxval = 100, group = grpCol)

// ─── State ───────────────────────────────────────────────────────────────────
// 0 = seeking a new high
// 1 = ceiling pending confirmation
// 2 = floor pending confirmation
// 3 = box is live
var int   state        = 0
var float ceiling      = na
var float floorLvl     = na
var float lowSinceCeil = na
var int   ceilBar      = na
var int   boxStart     = na
var int   countdown    = 0
var int   rungs        = 0
var float prevFloor    = na   // floor of the rung below, the old stop level

var box   liveBox    = na
var label liveLabel  = na
var line  stopLine   = na
var line  targetLine = na
var line  buildLine  = na

var box[]   oldBoxes  = array.new_box()
var label[] oldLabels = array.new_label()
var line[]  stopSteps = array.new_line()   // the rising stop, one step per rung

avgVol    = ta.sma(volume, 20)
isNewHigh = high >= ta.highest(high, lookback)

// Park a finished box on the ladder and drop the oldest rung once it is full.
// Only array contents are touched here, never a global assignment.
retire(box b, label l) =>
    array.push(oldBoxes, b)
    array.push(oldLabels, l)
    if array.size(oldBoxes) > ladderDepth
        box.delete(array.shift(oldBoxes))
        label gone = array.shift(oldLabels)
        if not na(gone)
            label.delete(gone)
    array.size(oldBoxes)

// ─── State machine ───────────────────────────────────────────────────────────
// Runs on every bar. Pine rolls `var` state back on each realtime tick, so the
// machine only ever advances once per confirmed bar.
brokeOut  = false
brokeDown = false
heavyVol  = false

// ── 0: waiting for a leader to print a new high ──
if state == 0
    if isNewHigh
        ceiling      := high
        ceilBar      := bar_index
        lowSinceCeil := low
        countdown    := confirmBars
        state        := 1

// ── 1: does the ceiling hold? ──
else if state == 1
    lowSinceCeil := math.min(lowSinceCeil, low)
    if high > ceiling
        ceiling      := high
        ceilBar      := bar_index
        lowSinceCeil := low
        countdown    := confirmBars
    else
        countdown -= 1
        if countdown <= 0
            floorLvl  := lowSinceCeil
            countdown := confirmBars
            state     := 2

// ── 2: does the floor hold? ──
else if state == 2
    if high > ceiling
        // ceiling taken out before the box ever closed - restart higher
        ceiling      := high
        ceilBar      := bar_index
        lowSinceCeil := low
        countdown    := confirmBars
        state        := 1
    else if low < floorLvl
        floorLvl  := low
        countdown := confirmBars
    else
        countdown -= 1
        if countdown <= 0
            boxH = (ceiling - floorLvl) / floorLvl * 100
            if boxH >= minHeight and boxH <= maxHeight
                // A rung only counts if it sits above the one below it. That is
                // the whole point - Darvas raised his stop to each new floor.
                // A box whose floor is no higher is not a rung, it is the start
                // of a new ladder.
                if rungs > 0 and floorLvl <= prevFloor
                    rungs := 0
                prevFloor := floorLvl
                boxStart  := ceilBar
                state     := 3

                // stop staircase: a fresh ladder wipes the old steps, and each
                // new rung closes off the step below it and opens its own
                if showSteps
                    if rungs == 0
                        while array.size(stopSteps) > 0
                            line.delete(array.shift(stopSteps))
                    else if array.size(stopSteps) > 0
                        line.set_x2(array.get(stopSteps, array.size(stopSteps) - 1), ceilBar)
                    array.push(stopSteps, line.new(ceilBar, floorLvl, bar_index, floorLvl,
                         color = failCol, style = line.style_dashed, width = 2))
                liveBox   := box.new(boxStart, ceiling, bar_index, floorLvl,
                     border_color = liveCol, border_width = 2,
                     bgcolor = color.new(liveCol, fillAlpha))
                if showLabels
                    liveLabel := label.new(bar_index, ceiling,
                         "RUNG " + str.tostring(rungs + 1) + "   " + str.tostring(boxH, "#.#") + "%",
                         style = label.style_label_down, color = liveCol,
                         textcolor = color.black, size = size.small)
            else
                // wrong shape for a Darvas box - hunt for a fresh high
                state := 0

// ── 3: the box is live ──
else if state == 3 and not na(liveBox)
    box.set_right(liveBox, bar_index)
    if not na(liveLabel)
        label.set_x(liveLabel, bar_index)

    // A close above the ceiling IS the breakout - it always ends the box.
    // Volume only decides whether the move gets marked as heavy.
    if close > ceiling * (1 + breakBuffer / 100)
        brokeOut := true
        heavyVol := volume >= avgVol * volMult
        rungs    += 1
        box.set_border_color(liveBox, breakCol)
        box.set_bgcolor(liveBox, color.new(breakCol, fillAlpha))
        if not na(liveLabel)
            label.set_color(liveLabel, breakCol)
            label.set_textcolor(liveLabel, color.white)
            label.set_text(liveLabel, "RUNG " + str.tostring(rungs) + (heavyVol ? "  ▲VOL" : ""))
        retire(liveBox, liveLabel)
        liveBox   := na
        liveLabel := na
        if not na(stopLine)
            line.delete(stopLine)
            stopLine := na
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na
        // the breakout bar's high seeds the next rung
        ceiling      := high
        ceilBar      := bar_index
        lowSinceCeil := low
        countdown    := confirmBars
        state        := 1

    else if close < floorLvl
        brokeDown := true
        box.set_border_color(liveBox, failCol)
        box.set_bgcolor(liveBox, color.new(failCol, fillAlpha))
        if not na(liveLabel)
            label.set_color(liveLabel, failCol)
            label.set_textcolor(liveLabel, color.white)
            // "ladder over" only means something if a ladder was actually built
            label.set_text(liveLabel, rungs > 0 ? "LADDER OVER  " + str.tostring(rungs) + " RUNGS" : "BOX BROKEN")
        retire(liveBox, liveLabel)
        liveBox   := na
        liveLabel := na
        if not na(stopLine)
            line.delete(stopLine)
            stopLine := na
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na
        rungs     := 0
        prevFloor := na
        state     := 0

// ─── Live overlays ───────────────────────────────────────────────────────────
if barstate.islast
    // stop under the floor of the active box
    if state == 3 and showStop and not na(floorLvl)
        if na(stopLine)
            stopLine := line.new(boxStart, floorLvl, bar_index + 10, floorLvl,
                 color = failCol, style = line.style_dashed, width = 1)
        else
            line.set_xy1(stopLine, boxStart, floorLvl)
            line.set_xy2(stopLine, bar_index + 10, floorLvl)

    // one box height projected above the ceiling
    if state == 3 and showTarget and not na(ceiling)
        tgt = ceiling + (ceiling - floorLvl)
        if na(targetLine)
            targetLine := line.new(boxStart, tgt, bar_index + 10, tgt,
                 color = breakCol, style = line.style_dotted, width = 1)
        else
            line.set_xy1(targetLine, boxStart, tgt)
            line.set_xy2(targetLine, bar_index + 10, tgt)

    // dashed ceiling while the box is still being built
    building = showBuilding and (state == 1 or state == 2) and not na(ceiling)
    if building
        if na(buildLine)
            buildLine := line.new(ceilBar, ceiling, bar_index + 6, ceiling,
                 color = color.new(liveCol, 40), style = line.style_dashed, width = 1)
        else
            line.set_xy1(buildLine, ceilBar, ceiling)
            line.set_xy2(buildLine, bar_index + 6, ceiling)
    else if not na(buildLine)
        line.delete(buildLine)
        buildLine := na

// ─── Markers and alerts ──────────────────────────────────────────────────────
plotshape(brokeOut and (heavyVol or not markVolume), title = "Breakout (heavy volume)",
     style = shape.triangleup, location = location.belowbar,
     color = breakCol, size = size.small)
plotshape(brokeOut and markVolume and not heavyVol, title = "Breakout (light volume)",
     style = shape.triangleup, location = location.belowbar,
     color = color.new(breakCol, 55), size = size.tiny)
plotshape(brokeDown, title = "Box Broken", style = shape.triangledown,
     location = location.abovebar, color = failCol, size = size.tiny)

alertcondition(brokeOut, "Darvas Breakout",
     "Price closed above the Darvas box ceiling - a new rung begins")
alertcondition(brokeOut and heavyVol, "Darvas Breakout on Volume",
     "Price closed above the Darvas box ceiling on above-average volume")
alertcondition(brokeDown, "Darvas Box Broken",
     "Price closed below the Darvas box floor - the ladder is over")
````
